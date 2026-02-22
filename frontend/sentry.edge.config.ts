// ─── Sentry Edge Configuration (#183) ───────────────────────────────────────
// Initializes Sentry in edge runtime context (middleware, edge functions).

import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.VERCEL_ENV ?? "development",
  release: process.env.VERCEL_GIT_COMMIT_SHA,
  enabled: !!process.env.NEXT_PUBLIC_SENTRY_DSN,

  tracesSampleRate: parseFloat(
    process.env.SENTRY_TRACES_SAMPLE_RATE ?? "0.1",
  ),

  beforeSend(event) {
    if (event.user) {
      delete event.user.email;
      delete event.user.ip_address;
    }
    return event;
  },
});
