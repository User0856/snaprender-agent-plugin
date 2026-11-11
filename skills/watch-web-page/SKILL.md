---
name: watch-web-page
description: Set up SnapRender scheduled captures that screenshot a public page every hour, day or week, compare each capture with the one before and alert when the page changes. Use when the user wants to monitor a page (competitor pricing, terms, a client site, their own pages after deploys) or be told when it changes.
---

# Watch a page for changes

SnapRender runs the schedule, the browser and the comparison on its side, so nothing has to keep running on the user's machine. Each capture is stored with its SHA-256 and compared with the previous one; `diffPercent` is the share of the page that changed.

The MCP server has no schedule tool. Schedules are created in the SnapRender dashboard or with the REST API. The MCP server can create the webhook that delivers change alerts.

## When not to use it

- **Local or private addresses, or pages behind a login**: SnapRender cannot reach them, so a schedule cannot either.
- **A one-off comparison now** ("did my deploy change the header?"): use the see-web-page skill and take two screenshots instead.
- **Changes that only appear after clicking through steps**: a schedule captures one page (it can click one element first with `click_selector`).
- **Pages that change on every load** (live feeds, rotating banners, clocks): every capture would count as changed. Hide that part with `hide_selectors` or raise `change_threshold`.

## Plan limits

| Plan | Schedules | Interval | History |
|---|---|---|---|
| Free | 1 | daily or weekly | 7 days |
| Starter | 5 | hourly, daily or weekly | 14 days |
| Growth | 25 | hourly, daily or weekly | 30 days |
| Business | 100 | hourly, daily or weekly | 90 days |
| Scale | 300 | hourly, daily or weekly | 180 days |

Each capture uses one monthly capture: daily is about 30 a month, hourly about 720. Call `get_usage` (free) before suggesting hourly. Failed captures are refunded; when the month's quota runs out, captures are skipped, not charged. A schedule pauses after 10 failed captures in a row.

## Option 1: the dashboard (no code)

Send the user to https://app.snap-render.com/dashboard/schedules. They paste the URL, pick how often, and pick how big a change should alert them. The same page shows every capture and compares versions side by side.

## Option 2: the REST API

For a script or the user's own code. It needs a SnapRender API key from https://app.snap-render.com/dashboard. Never ask the user to paste the key into the chat: it belongs in their environment or secrets manager, and they run the command or code themselves.

```bash
curl -X POST "https://app.snap-render.com/v1/schedules" \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/pricing", "interval": "daily", "full_page": true, "change_threshold": 0.5}'
```

- Required: `url`, `interval` (`hourly`, `daily` or `weekly`).
- Optional: `name`, `change_threshold` (percent of the page, default 0.5), `notify_email` (Business and Scale only; other plans get `403 EMAIL_ALERTS_NOT_AVAILABLE`), and render options `device`, `full_page`, `lazy_load`, `dark_mode`, `width`, `height`, `hide_selectors`, `click_selector`, `delay`, `block_ads`, `block_cookie_banners`, `user_agent`.
- Later: `GET /v1/schedules` lists them with plan limits; `GET /v1/schedules/ID/captures` gives the history (`capturedAt`, `diffPercent`, `changed`, `sha256`, a `downloadUrl` valid for one hour); `PATCH /v1/schedules/ID` changes `name`, `interval`, `change_threshold`, `notify_email`, or `is_active` to pause or resume; `POST /v1/schedules/ID/run` captures now; `DELETE /v1/schedules/ID` removes the schedule and its captures.

Full reference: https://snap-render.com/docs (Scheduled captures).

## Choosing the threshold

- `0.005`: any change, even one changed number (the dashboard calls this "any change")
- `0.1`: a changed line of text or a new banner
- `0.5`: the default
- `2`: big changes only, such as a new section or a redesign

## Getting told about changes

- **Webhook (every plan)**: call the MCP tool `create_webhook` with `url` (a public HTTPS endpoint the user controls) and `events: ["change.detected"]`. Add `"capture.completed"` to hear about every capture. Save the returned secret: payloads are signed with HMAC-SHA256. `test_webhook` sends a test payload; `list_webhooks` and `delete_webhook` manage them. Up to 5 webhooks per account.
- **Email (Business and Scale)**: `notify_email: true` on the schedule, or the alert setting in the dashboard.
- **No endpoint**: the user checks the dashboard, or code reads `GET /v1/schedules/ID/captures`.
