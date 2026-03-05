// ─── Web Vitals Collection (#621) ───────────────────────────────────────────
// Collects Core Web Vitals (CLS, INP, LCP, TTFB, FCP) and reports them to
// Sentry as custom measurements. Runs client-side only.
//
// Integration: call reportWebVitals() once in a client component (e.g. Providers).
// No-op when Sentry DSN is not configured.
//
// Metrics collected:
//   - CLS  (Cumulative Layout Shift) — visual stability
//   - INP  (Interaction to Next Paint) — responsiveness
//   - LCP  (Largest Contentful Paint) — loading performance
//   - TTFB (Time to First Byte) — server responsiveness
//   - FCP  (First Contentful Paint) — perceived load speed

import type { Metric } from "web-vitals";

// ─── SLO thresholds from docs/SLO.md ───────────────────────────────────────
// Values above these thresholds are flagged as "poor" in Sentry.

export const WEB_VITAL_THRESHOLDS = {
  CLS: 0.1, // good ≤ 0.1, needs improvement ≤ 0.25, poor > 0.25
  INP: 200, // good ≤ 200ms, needs improvement ≤ 500ms, poor > 500ms
  LCP: 2500, // good ≤ 2.5s, needs improvement ≤ 4s, poor > 4s
  TTFB: 800, // good ≤ 800ms
  FCP: 1800, // good ≤ 1.8s
} as const;

/**
 * Rating for a web vital metric.
 * "good" = within SLO, "needs-improvement" = approaching SLO, "poor" = over SLO.
 */
export type VitalRating = "good" | "needs-improvement" | "poor";

/**
 * Classify a web vital value against Google's Core Web Vitals thresholds.
 */
export function rateMetric(name: string, value: number): VitalRating {
  const threshold =
    WEB_VITAL_THRESHOLDS[name as keyof typeof WEB_VITAL_THRESHOLDS];
  if (threshold === undefined) return "good";

  if (name === "CLS") {
    if (value <= 0.1) return "good";
    if (value <= 0.25) return "needs-improvement";
    return "poor";
  }

  if (name === "INP") {
    if (value <= 200) return "good";
    if (value <= 500) return "needs-improvement";
    return "poor";
  }

  if (name === "LCP") {
    if (value <= 2500) return "good";
    if (value <= 4000) return "needs-improvement";
    return "poor";
  }

  // FCP and TTFB: simple threshold check
  if (value <= threshold) return "good";
  return "poor";
}

/**
 * Handler type for metric reporting.
 * Can be replaced in tests or for custom analytics backends.
 */
export type MetricHandler = (metric: {
  name: string;
  value: number;
  id: string;
  rating: VitalRating;
}) => void;

/**
 * Default metric handler — sends to Sentry as a custom measurement.
 * Falls back to console.debug in development when Sentry is unavailable.
 */
export const defaultMetricHandler: MetricHandler = (metric) => {
  // Dynamic import avoids pulling Sentry into non-instrumented builds
  if (typeof window !== "undefined") {
    try {
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const Sentry = require("@sentry/nextjs");
      if (Sentry && typeof Sentry.captureMessage === "function") {
        Sentry.captureMessage(`Web Vital: ${metric.name}`, {
          level: metric.rating === "poor" ? "warning" : "info",
          tags: {
            web_vital: metric.name,
            rating: metric.rating,
          },
          extra: {
            value: metric.value,
            id: metric.id,
            threshold:
              WEB_VITAL_THRESHOLDS[
                metric.name as keyof typeof WEB_VITAL_THRESHOLDS
              ],
          },
        });
      }
    } catch {
      // Sentry not available — silently skip
    }
  }

  if (process.env.NODE_ENV === "development") {
    console.debug(
      `[Web Vital] ${metric.name}: ${metric.value} (${metric.rating})`,
    );
  }
};

/**
 * Initialize Core Web Vitals collection.
 *
 * Call once in a client-side entry point (e.g., Providers.tsx useEffect).
 * Each metric fires its callback exactly once per page load.
 *
 * @param handler - Custom metric handler. Defaults to Sentry reporter.
 */
export function reportWebVitals(
  handler: MetricHandler = defaultMetricHandler,
): void {
  if (typeof window === "undefined") return;

  // Dynamic import so the module is only loaded in the browser
  import("web-vitals").then(({ onCLS, onINP, onLCP, onTTFB, onFCP }) => {
    const report = (metric: Metric) => {
      handler({
        name: metric.name,
        value: metric.value,
        id: metric.id,
        rating: rateMetric(metric.name, metric.value),
      });
    };

    onCLS(report);
    onINP(report);
    onLCP(report);
    onTTFB(report);
    onFCP(report);
  });
}
