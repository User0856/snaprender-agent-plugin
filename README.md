<img src="assets/logo.png" alt="SnapRender" width="64" height="64">

# SnapRender for AI agents

Give your coding agent eyes on the web. [SnapRender](https://snap-render.com) renders public web pages in a real browser, so the agent can see a page the way a visitor does (desktop, phone, full page, dark theme) and read it as clean markdown before it writes code.

One repository, packaged for each client:

| Client | What this repo provides |
| --- | --- |
| Claude Code | Plugin and plugin marketplace (`.claude-plugin/`, `.mcp.json`, `skills/`) |
| Cursor | Plugin (`.cursor-plugin/plugin.json`, `mcp.json`, `skills/`, logo) |
| Codex | Plugin (`.codex-plugin/plugin.json`, `.mcp.json`, `skills/`) |
| Any agent that reads Agent Skills | The three skills in `skills/`, installable with `npx skills add` |
| Gemini CLI | Separate extension: [snaprender-gemini-extension](https://github.com/User0856/snaprender-gemini-extension) |

## What you get

**The hosted SnapRender MCP server** at `https://app.snap-render.com/mcp` (Streamable HTTP, OAuth sign-in in the browser), with 11 tools:

| Tool | What it does |
| --- | --- |
| `take_screenshot` | Capture a page as PNG, JPEG, WebP or PDF, on desktop or a phone, tablet or laptop preset, one screen or the full page |
| `extract_content` | Read a page as markdown, text, HTML, article, links or metadata |
| `batch_screenshots` | Capture up to 50 URLs in one background job |
| `get_batch_status` | Check a batch job and get its download links |
| `check_screenshot_cache` | See whether a free cached copy exists, without capturing |
| `get_usage` | Captures used and left this month, and the reset date |
| `sign_screenshot_url` | Make a signed link that renders a screenshot when opened |
| `list_webhooks`, `create_webhook`, `delete_webhook`, `test_webhook` | Manage webhook notifications, including change alerts from scheduled captures |

**Three skills:**

- `see-web-page`: screenshots a page on desktop and on a phone and reports layout problems (cut-off text, overlaps, broken navigation, unreadable text, missing images).
- `read-web-page`: reads a page as markdown, trimmed to the main content, so the agent works from the current docs instead of memory.
- `watch-web-page`: sets up scheduled captures that compare each capture with the one before and alert when the page changes (schedules are created in the SnapRender dashboard or REST API; the MCP server creates the webhook for alerts).

Ads and cookie banners are removed from captures by default.

## Install

### Claude Code

```text
/plugin marketplace add User0856/snaprender-agent-plugin
/plugin install snaprender@snaprender
```

Or from your shell:

```sh
claude plugin marketplace add User0856/snaprender-agent-plugin
claude plugin install snaprender@snaprender
```

Then run `/mcp`, pick the SnapRender server and sign in (or create a free account) in the browser. Skills show up as `/snaprender:see-web-page`, `/snaprender:read-web-page` and `/snaprender:watch-web-page`, and Claude also picks them on its own when a request fits.

### Cursor

Once the plugin is listed, install it from the Cursor Marketplace. To install it yourself now:

1. Copy this repository's contents to `~/.cursor/plugins/local/snaprender/` (the manifest must end up at `~/.cursor/plugins/local/snaprender/.cursor-plugin/plugin.json`).
2. Restart Cursor or run **Developer: Reload Window**.
3. Open **Customize**, find the SnapRender MCP server and choose **Authenticate**. Sign in to SnapRender in the browser and approve.

To add only the MCP server, put this in your Cursor MCP configuration:

```json
{
  "mcpServers": {
    "snaprender": {
      "url": "https://app.snap-render.com/mcp"
    }
  }
}
```

### Codex

```sh
codex plugin marketplace add User0856/snaprender-agent-plugin
codex plugin add snaprender@snaprender
codex mcp login snaprender
```

The last command opens the SnapRender sign-in in your browser. To add only the MCP server: `codex mcp add snaprender --url https://app.snap-render.com/mcp`, then `codex mcp login snaprender`.

### Gemini CLI

```sh
gemini extensions install https://github.com/User0856/snaprender-gemini-extension
```

See [snaprender-gemini-extension](https://github.com/User0856/snaprender-gemini-extension).

### Skills only (skills.sh)

```sh
npx skills add User0856/snaprender-agent-plugin
```

The CLI asks which skills and which agents (Claude Code, Codex, Cursor, OpenCode and many more) to install to. The skills call the SnapRender MCP tools, so connect the MCP server in that agent too.

### Any other MCP client

- Server URL: `https://app.snap-render.com/mcp` (Streamable HTTP). Clients with OAuth open the SnapRender sign-in in the browser.
- Clients without OAuth: send the header `Authorization: Bearer <your API key>`. Create a key in the dashboard at https://app.snap-render.com/dashboard.
- Local server instead: `npx -y snaprender-mcp` with the environment variable `SNAPRENDER_API_KEY` set to your API key.

Setup guides for each client: https://snap-render.com/ai-connectors

## No account yet? (AI agents)

An agent with no key can start in one call. `POST https://app.snap-render.com/v1/agent-trial` returns an `sk_trial_` key at once, with no signup:

```bash
curl -X POST https://app.snap-render.com/v1/agent-trial \
  -H "Content-Type: application/json" -d '{"agent": "my-agent"}'
```

Send the key to the hosted MCP server as `Authorization: Bearer sk_trial_...`, or as `X-API-Key` on REST calls. A trial key gets 100 captures over 7 days (30 a day), a small corner watermark and a slower lane. The developer claims it with a free account through the `claim_url` in the response (200 captures a month, no watermark), and the agent's key keeps working. Details: https://snap-render.com/docs/agent-trial

## Try it

- Screenshot https://example.com on desktop and on iPhone 15 Pro and list what looks broken on mobile
- Read the docs at https://example.com/docs as markdown and summarize the API before we write code
- Watch https://example.com/pricing every day and tell me how I get alerted when it changes
- How many SnapRender captures do I have left this month?

## Good to know

- **Public pages only.** SnapRender cannot reach localhost, private networks or pages behind a login, and it does not click through multi-step flows (it can click one element before a capture). Use a public or preview deployment URL.
- **Firewall checks.** If a capture of your own site shows a security check such as "Just a moment...", one firewall rule lets SnapRender through: https://snap-render.com/docs/allow-snaprender

## Pricing

The free plan includes 200 captures a month (25 until you verify your email), no card needed. Each screenshot or extraction uses one capture, failed renders are free, and `get_usage` and the cache check cost nothing. Paid plans: https://snap-render.com/pricing

## What the plugin sends and stores

The plugin itself runs no code on your machine. It adds the hosted MCP server and three instruction files (skills). When the agent calls a SnapRender tool, the URL and capture options it passes are sent to `https://app.snap-render.com`. SnapRender does not read your code, files or workspace. Captures are returned in the tool result and cached for a limited time so repeat requests can be served free; cached copies are deleted when the cache expires. Sign-in uses OAuth, and your client stores the tokens. Full policy: https://snap-render.com/privacy

## Links

- AI agent guide: https://snap-render.com/ai-agents
- Docs: https://snap-render.com/docs
- Support: support@snap-render.com or https://snap-render.com/support
- Terms: https://snap-render.com/terms

## License

MIT
