// ─── Error Reporter — Structured error logging for Error Boundaries ────────
// Captures component errors with context (component stack, URL, product data)
// and logs them in development. Production: reports to Sentry (#183).
//
// Usage:
//   import { reportBoundaryError } from "@/lib/error-reporter";
//   reportBoundaryError(error, errorInfo, { ean: "5900617043375" });

import * as Sentry from "@sentry/nextjs";
import type { ErrorInfo } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface ErrorContext {
  /** Human-readable label for where the boundary is placed. */
  boundary?: string;
  /** Boundary level — determines severity of logging. */
  level?: "page" | "section" | "component";
  /** Arbitrary context (e.g., product EAN, page name). */
  [key: string]: unknown;
}

export interface ErrorReport {
  message: string;
  stack: string | undefined;
  componentStack: string | undefined;
  context: ErrorContext;
  timestamp: string;
  url: string;
}

// ─── Reporter ───────────────────────────────────────────────────────────────

/**
 * Build a structured error report from a React error boundary catch.
 * Pure function — no side effects, testable.
 */
export function buildErrorReport(
  error: Error,
  errorInfo: ErrorInfo,
  context: ErrorContext = {},
): ErrorReport {
  return {
    message: error.message,
    stack: error.stack,
    componentStack: errorInfo.componentStack ?? undefined,
    context,
    timestamp: new Date().toISOString(),
    url: globalThis.window === undefined ? "SSR" : globalThis.location.href,
  };
}

/**
 * Log and report an error caught by a React error boundary.
 *
 * - Development: full console.error with structured report.
 * - Production: silently captured (ready for telemetry service integration).
 */
export function reportBoundaryError(
  error: Error,
  errorInfo: ErrorInfo,
  context: ErrorContext = {},
): ErrorReport {
  const report = buildErrorReport(error, errorInfo, context);

  if (process.env.NODE_ENV !== "production") {
    console.error("[ErrorBoundary]", report);
  }

  // Production: send to Sentry telemetry (#183)
  Sentry.captureException(error, {
    contexts: {
      react: { componentStack: errorInfo.componentStack },
      app: context,
    },
  });

  return report;
}
