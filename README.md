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

- **Debug (Xcode):** Test Store key (`test_…`) — fake purchase dialog, no App Store Connect needed
- **TestFlight / Release:** App Store key (`appl_…`) — **required**; RevenueCat intentionally crashes if a `test_` key is used in Release

Entitlement: `lefty_plus` · Packages: **$4.99/month** · **$39.99/year** · Free: **3 Teach conversions / month**

Dashboard: https://app.revenuecat.com/projects/24f924fc

For TestFlight purchases to show real products, create matching IAPs in App Store Connect with IDs `lefty_plus_monthly` and `lefty_plus_annual`, then attach ASC credentials in RevenueCat → Apps → Lefty iOS.

Open **Settings → Lefty+** or finish onboarding to see the paywall.
