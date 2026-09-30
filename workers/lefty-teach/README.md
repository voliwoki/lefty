# lefty-teach Worker

Proxies **Teach Me Left-Handed** to OpenAI. The OpenAI API key never ships in the iOS app.

**URL:** `https://lefty-teach.nina-c51.workers.dev`  
**Endpoint:** `POST /v1/teach`  
**Auth header:** `X-Lefty-App-Secret`

## Security

- `OPENAI_API_KEY` and `LEFTY_APP_SECRET` are Wrangler secrets — never commit them.
- Rate limit: **20 requests / 60s** per client IP and per app-secret fingerprint (Cloudflare Rate Limiting binding).
- No open CORS (native iOS only).
- Text input capped; images capped at 4MB.

Set an OpenAI **usage/spend limit** in the OpenAI dashboard as a backstop.

## One-time: plug in your OpenAI key

```bash
cd workers/lefty-teach
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put LEFTY_APP_SECRET
```

Use the same `LEFTY_APP_SECRET` value in local `lefty/Secrets.plist` (gitignored). See `Secrets.example.plist`.

## Local dev

```bash
cp .dev.vars.example .dev.vars
# edit .dev.vars with OPENAI_API_KEY + LEFTY_APP_SECRET
npm install
npm run dev
```

## Deploy

```bash
npm run deploy
```
