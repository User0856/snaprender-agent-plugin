# Submitting this plugin

Each portal needs the owner's own sign-in. Nothing here has been submitted yet. Order: Claude plugin bundle, Cursor, then Codex. Run the local checks first:

```sh
claude plugin validate --strict --profile directory .
./scripts/build-codex-zip.sh
```

## 1. Cursor Marketplace

- **Portal:** https://cursor.com/marketplace/publish (sign in to Cursor first; the page opens a "plugin publisher application").
- **Requirements (cursor.com/docs/reference/plugins):** public open-source repo, `.cursor-plugin/plugin.json`, lowercase kebab-case `name`, README with usage, relative paths only, tested locally. Every update is reviewed by the Cursor team.
- **Local test before submitting:** copy the repo to `~/.cursor/plugins/local/snaprender/`, run Developer: Reload Window, open Customize, check that 3 skills and the SnapRender MCP server appear, choose Authenticate and sign in.

Text to paste:

| Field | Text |
| --- | --- |
| Repository | `https://github.com/User0856/snaprender-agent-plugin` |
| Plugin name | `snaprender` |
| Display name | SnapRender |
| Publisher | SnapRender |
| Contact email | support@snap-render.com |
| Website | https://snap-render.com/ai-agents |
| Short description | Screenshot and read public web pages from Cursor. |
| Description | SnapRender renders public web pages in a real browser and returns what a visitor sees: desktop and phone screenshots, full pages, dark mode, with ads and cookie banners removed. It also reads pages as clean markdown. The plugin connects Cursor to the hosted SnapRender MCP server (OAuth sign-in in the browser, 11 tools) and adds three skills: see-web-page (desktop and phone screenshots with a short report of visual bugs), read-web-page (current docs as markdown before writing code) and watch-web-page (scheduled captures that alert when a page changes). Free plan: 200 captures a month. Public pages only: no localhost, private networks or pages behind a login. |
| Category (if asked) | Developer tools |

## 2. Claude plugin directory (Anthropic)

- **Portal:** https://claude.ai/directory/manage. Any paid claude.ai plan can submit (Pro and Max from your own account). The Company step takes a name and website as free text.
- **Status:** the hosted MCP connector (https://app.snap-render.com/mcp) was submitted on Nov 12 2026 and is in review. Next: submit this repo as a **Plugin bundle** (Submit new, Plugin bundle, repo `User0856/snaprender-agent-plugin`, path and branch empty) and link it to the connector.
- Saving an edit on a listing that is in review moves it back to Draft: click **Submit for review** again after saving.
- Data handling answers: no personal data read or stored; data goes only to `https://app.snap-render.com/mcp`; captures cached 24 hours by default; not intended for under-18s. Contact: support@snap-render.com.

## 3. OpenAI plugin portal (Codex)

- **Portal:** OpenAI Platform, Plugins (guide: https://developers.openai.com/plugins/deploy/submission). Organization owner or a member with Apps Management Write; the verified developer identity is needed to publish under the SnapRender name.
- **Upload:** run `./scripts/build-codex-zip.sh` and upload `dist/snaprender-codex-plugin-<version>.zip` with **Upload new or existing plugin**. The ZIP holds `.codex-plugin/plugin.json`, `.mcp.json`, `skills/`, `assets/`, README and LICENSE. Listing text, icons, the 5 positive and 3 negative test cases and release notes are read from `.codex-plugin/plugin.json`, so they do not need typing.
- **MCPs tab:** **Connect** `https://app.snap-render.com/mcp`. Authentication: OAuth (the server supports dynamic client registration; no client secret). Domain verification: paste the challenge token the portal shows into the existing `/.well-known/openai-apps-challenge` route on app.snap-render.com (route in `src/routes/pages.ts` of the main repo), deploy, then verify.
- **Still needed from the owner:**
  1. A demo video URL (reviewer-accessible) that runs the test cases. Add it to the package as `extensions.com.openai.review.demo_recording_url` in `.codex-plugin/plugin.json` or enter it in Review details.
  2. A dedicated reviewer test account (email and password sign-in, no magic link or 2FA, some free captures left), entered only in **Review details**, never in the ZIP.
- **Policy attestations** and **Submit for review**, then **Publish plugin** after approval.

Listing values already in the package, for reference:

| Field | Value |
| --- | --- |
| Display name | SnapRender |
| Short description | See and read any web page |
| Developer name | SnapRender |
| Category | Developer Tools |
| Website / support / privacy / terms | https://snap-render.com/ai-agents, https://snap-render.com/support, https://snap-render.com/privacy, https://snap-render.com/terms |
| Brand colors | #4F46E5 (light), #818CF8 (dark) |
| Starter prompts | 3, see `.codex-plugin/plugin.json` |

Test cases in the package (the screenshot and read flows were run against the live server on Nov 11 2026 through Claude Code; run all eight with the reviewer account in Codex before submitting):

- Positive: desktop and iPhone 15 Pro screenshots of example.com with a visual check (`take_screenshot`); read a Wikipedia page as markdown and summarize (`extract_content`); full-page dark-mode capture of github.com (`take_screenshot`); captures left this month (`get_usage`); list the links on snap-render.com/docs and find the schedules section (`extract_content`).
- Negative: screenshot of `http://localhost:3000` (ask for a public URL); screenshot of a Gmail inbox (explain login pages cannot be captured, never ask for a password); add an item to an Amazon cart and check out (decline, offer a screenshot instead).

## 4. skills.sh

No submission. The listing and ranking come from installs with `npx skills add User0856/snaprender-agent-plugin`. Put that command in docs and READMEs.
