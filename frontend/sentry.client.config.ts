// ─── Sentry Client-Side Configuration (#183) ───────────────────────────────
// Initializes Sentry in the browser for frontend error capture.
// PII scrubbing: no emails, IPs, or health data in error reports.

import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NEXT_PUBLIC_VERCEL_ENV ?? "development",
  release: process.env.NEXT_PUBLIC_VERCEL_GIT_COMMIT_SHA,
  enabled: !!process.env.NEXT_PUBLIC_SENTRY_DSN,

  // ── Sampling ────────────────────────────────────────────────────────────
  // 100% of errors, 10% of transactions (adjustable via env)
  tracesSampleRate: parseFloat(
    process.env.NEXT_PUBLIC_SENTRY_TRACES_SAMPLE_RATE ?? "0.1",
  ),

  // ── Session replay (disabled by default for PII safety) ───────────────
  replaysSessionSampleRate: 0.0,
  replaysOnErrorSampleRate: 0.0,

  // ── PII Scrubbing ────────────────────────────────────────────────────────
  beforeSend(event) {
    // Strip email and IP from user context
    if (event.user) {
      delete event.user.email;
      delete event.user.ip_address;
    }

    // Filter breadcrumbs referencing health data
    if (event.breadcrumbs) {
      event.breadcrumbs = event.breadcrumbs.filter(
        (b) =>
          !b.message?.includes("health_profile") &&
          !b.message?.includes("allergen") &&
          !b.message?.includes("health_condition"),
      );
    }

    return event;
  },

  // ── Noise Reduction ──────────────────────────────────────────────────────
  ignoreErrors: [
    "ResizeObserver loop",
    "ResizeObserver loop completed with undelivered notifications",
    "Non-Error promise rejection",
    /Loading chunk \d+ failed/,
    /Failed to fetch dynamically imported module/,
    "AbortError",
  ],
});
