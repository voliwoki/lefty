/** Secrets via `wrangler secret put`. Rate limit via wrangler.jsonc ratelimits. */
interface Env {
  OPENAI_API_KEY: string;
  LEFTY_APP_SECRET: string;
  OPENAI_MODEL: string;
  TEACH_RATE_LIMITER: RateLimit;
}
