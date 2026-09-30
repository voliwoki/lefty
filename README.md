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

## Privacy note

Guides you **save in My Lefty** stay on device. **Teach Me Left-Handed** sends the text and/or photo you submit to a Cloudflare Worker, which calls OpenAI to generate steps — then returns the guide to the app. Do not photograph faces or personal documents you do not want processed.

## Open in Xcode

Open `lefty.xcodeproj`. Bundle ID: `com.knk.lefty`.

## Teach Me Left-Handed secrets

1. Copy `lefty/Secrets.example.plist` → `lefty/Secrets.plist` (**gitignored — never commit**).
2. Set `TeachWorkerURL` to your deployed Worker URL.
3. Set `LeftyAppSecret` to the same value as the Worker’s `LEFTY_APP_SECRET`.
4. On Cloudflare:

```bash
cd workers/lefty-teach
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put LEFTY_APP_SECRET
npm run deploy
```

Details: [workers/lefty-teach/README.md](./workers/lefty-teach/README.md).

Without `Secrets.plist`, DEBUG builds fall back to the stub guide service so the UI still runs.

## Lefty+ (RevenueCat)

App Store only — **never** use a RevenueCat Test Store (`test_…`) API key.

- Public SDK key: `appl_…` (Lefty iOS app in RevenueCat) — safe to embed in the client
- Entitlement: `lefty_plus`
- Packages: **$4.99/month** (`lefty_plus_monthly`) · **$39.99/year** (`lefty_plus_annual`)
- Free: **3 Teach conversions / month**, then paywall

Open **Settings → Subscription** or finish onboarding to see the paywall.
