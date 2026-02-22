// ─── Next.js Instrumentation Hook (#183) ────────────────────────────────────
// Next.js calls this during server startup for both Node.js and Edge runtimes.
// Used to initialize Sentry server/edge SDK before any requests are handled.

export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    await import("../sentry.server.config");
  }

  if (process.env.NEXT_RUNTIME === "edge") {
    await import("../sentry.edge.config");
  }
}

export { captureRequestError as onRequestError } from "@sentry/nextjs";
