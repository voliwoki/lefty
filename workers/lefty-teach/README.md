# lefty-teach Worker

Proxies **Teach Me Left-Handed** to OpenAI. The OpenAI API key never ships in the iOS app.

**URL:** `https://lefty-teach.nina-c51.workers.dev`  
**Endpoint:** `POST /v1/teach`  
**Auth header:** `X-Lefty-App-Secret`

## One-time: plug in your OpenAI key

From this folder:

```bash
cd workers/lefty-teach
npx wrangler secret put OPENAI_API_KEY
```

Paste your key when prompted. Do not commit it.

`LEFTY_APP_SECRET` is already set on the Worker. Use the same value in local `lefty/Secrets.plist` (gitignored). See `Secrets.example.plist`.

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
