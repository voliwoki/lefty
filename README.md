# Lefty

**Same world. Just left.**

Native iOS app for left-handed learning — RevenueCat Shipaton 2026.

## For partners

Start here: **[PLAN.md](./PLAN.md)** — full MVP build plan (must-haves, nice-to-haves, architecture, OpenAI + RevenueCat, left-hand UI rules).

## Stack

- Swift + SwiftUI (iPhone)
- SwiftData (on-device)
- RevenueCat (Lefty+)
- OpenAI vision via Cloudflare Worker (`workers/lefty-teach`) — API key never in the app
- No accounts, no custom backend database, no social

## Open in Xcode

Open `lefty.xcodeproj`. Bundle ID: `com.knk.lefty`.

## Teach Me Left-Handed secrets

1. Copy `lefty/Secrets.example.plist` → `lefty/Secrets.plist` (gitignored).
2. Set `TeachWorkerURL` to `https://lefty-teach.nina-c51.workers.dev`.
3. Set `LeftyAppSecret` to the same value as the Worker’s `LEFTY_APP_SECRET`.
4. On Cloudflare, plug in OpenAI (you do this once):

```bash
cd workers/lefty-teach
npx wrangler secret put OPENAI_API_KEY
```

Details: [workers/lefty-teach/README.md](./workers/lefty-teach/README.md).

Without `Secrets.plist`, DEBUG builds fall back to the stub guide service so the UI still runs.

## Lefty+ (RevenueCat)

Shipaton uses RevenueCat **Test Store** (no App Store Connect required).

- Entitlement: `lefty_plus`
- Packages: **$5/month** (`$rc_monthly`) · **$39/year** (`$rc_annual`)
- Free allowance: **3 Teach conversions / month**, then paywall
- Dashboard: https://app.revenuecat.com/projects/24f924fc
- Public Test Store key lives in `Secrets.example.plist` as `RevenueCatAPIKey` (and ships as a DEBUG-friendly fallback)

Open **Settings → Lefty+** to see plans / restore, or exhaust free Teach uses to hit the paywall.

Purchases open a RevenueCat Test Store dialog (Success / Fail / Cancel) — perfect for the demo video.
