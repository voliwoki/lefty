/** Secrets are set via `wrangler secret put` — merge into generated Env. */
interface Env {
  OPENAI_API_KEY: string;
  LEFTY_APP_SECRET: string;
}
