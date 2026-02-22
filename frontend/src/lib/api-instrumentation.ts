// ─── API Route Instrumentation ──────────────────────────────────────────────
// Higher-order function wrapping Next.js API route handlers with:
// - X-Request-Id generation / propagation
// - Structured JSON logging (request start, completion, failure)
// - Duration measurement
// - Sentry error capture
//
// Usage:
//   import { withInstrumentation } from "@/lib/api-instrumentation";
//   export const GET = withInstrumentation(async (req) => { ... });

import { NextRequest, NextResponse } from "next/server";
import * as Sentry from "@sentry/nextjs";
import { logger } from "./logger";

/**
 * Wrap a Next.js route handler with structured logging + error telemetry.
 *
 * - Generates or forwards `X-Request-Id`
 * - Logs request completion / failure with duration
 * - Captures exceptions in Sentry with request context
 */
export function withInstrumentation(
  handler: (req: NextRequest) => Promise<NextResponse>,
) {
  return async (req: NextRequest): Promise<NextResponse> => {
    const requestId = req.headers.get("x-request-id") ?? crypto.randomUUID();
    const start = performance.now();

    try {
      const response = await handler(req);
      const duration = Math.round(performance.now() - start);

      logger.info("API request completed", {
        requestId,
        route: req.nextUrl.pathname,
        method: req.method,
        status: response.status,
        duration,
      });

      response.headers.set("x-request-id", requestId);
      return response;
    } catch (error) {
      const duration = Math.round(performance.now() - start);
      const errorObj =
        error instanceof Error
          ? { name: error.name, message: error.message, stack: error.stack }
          : { name: "Unknown", message: String(error) };

      logger.error("API request failed", {
        requestId,
        route: req.nextUrl.pathname,
        method: req.method,
        duration,
        error: errorObj,
      });

      Sentry.captureException(error, {
        tags: {
          requestId,
          route: req.nextUrl.pathname,
          method: req.method,
        },
        extra: { duration },
      });

      // Re-throw so Next.js error handling still applies
      throw error;
    }
  };
}
