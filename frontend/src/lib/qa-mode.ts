// ─── QA Mode — Deterministic UI for Quality Gate Audits ─────────────────────
// QA mode suppresses all sources of non-determinism:
//   - CSS transitions & animations (killed via global <style>)
//   - Tip of the Day (always shows tip[0])
//   - Analytics / telemetry calls (silently dropped)
//   - Vercel Speed Insights (not rendered)
//   - <html data-qa-mode="true"> attribute for test detection
//
// Two activation paths:
//   1. Build-time: NEXT_PUBLIC_QA_MODE=1 (env var, used in CI & Server Components)
//   2. Runtime: `qa_mode` feature flag (DB-backed, toggleable without redeploy)
//
// Issue: #173 — [Quality Gate 2/9] QA Mode Flag for Deterministic UI
// Issue: #191 — Feature Flag Framework (flag-based activation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * `true` when the env-based QA mode is active (`NEXT_PUBLIC_QA_MODE=1`).
 *
 * This constant is inlined at build time by Next.js — no runtime cost in
 * production builds where the env var is absent.
 * Used in Server Components and the root layout where DB flags aren't available
 * synchronously.
 */
export const IS_QA_MODE = process.env.NEXT_PUBLIC_QA_MODE === "1";

/**
 * Returns a deterministic (stable) value when QA mode is active,
 * otherwise returns the live value.
 *
 * Use this to wrap any non-deterministic expression that would make
 * test assertions flaky (random tips, relative timestamps, etc.).
 *
 * @example
 *   qaStable(randomTip, tips[0])   // always tips[0] in QA mode
 *   qaStable(timeAgo(ts), isoDate) // always ISO in QA mode
 */
export function qaStable<T>(liveValue: T, stableValue: T): T {
  return IS_QA_MODE ? stableValue : liveValue;
}
