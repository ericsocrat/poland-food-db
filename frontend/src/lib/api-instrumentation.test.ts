import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { NextRequest, NextResponse } from "next/server";
import { withInstrumentation } from "./api-instrumentation";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@sentry/nextjs", () => ({
  captureException: vi.fn(),
}));

vi.mock("./logger", () => ({
  logger: {
    debug: vi.fn(),
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
    fatal: vi.fn(),
  },
}));

import * as Sentry from "@sentry/nextjs";
import { logger } from "./logger";

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeRequest(url = "http://localhost:3000/api/test", headers?: Record<string, string>): NextRequest {
  const h = new Headers(headers);
  return new NextRequest(new URL(url), { headers: h });
}

beforeEach(() => {
  vi.clearAllMocks();
});

afterEach(() => {
  vi.restoreAllMocks();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("withInstrumentation", () => {
  it("returns a function", () => {
    const handler = vi.fn();
    const instrumented = withInstrumentation(handler);
    expect(typeof instrumented).toBe("function");
  });

  it("calls the original handler", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({ ok: true }));
    const instrumented = withInstrumentation(handler);
    await instrumented(makeRequest());
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it("returns the handler's response", async () => {
    const body = { status: "healthy" };
    const handler = vi.fn().mockResolvedValue(NextResponse.json(body));
    const instrumented = withInstrumentation(handler);
    const res = await instrumented(makeRequest());
    expect(res.status).toBe(200);
  });

  it("sets x-request-id header on response", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}));
    const instrumented = withInstrumentation(handler);
    const res = await instrumented(makeRequest());
    expect(res.headers.get("x-request-id")).toBeTruthy();
  });

  it("preserves incoming x-request-id", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}));
    const instrumented = withInstrumentation(handler);
    const req = makeRequest("http://localhost:3000/api/test", {
      "x-request-id": "existing-id-123",
    });
    const res = await instrumented(req);
    expect(res.headers.get("x-request-id")).toBe("existing-id-123");
  });

  it("generates UUID when no x-request-id provided", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}));
    const instrumented = withInstrumentation(handler);
    const res = await instrumented(makeRequest());
    const id = res.headers.get("x-request-id");
    expect(id).toBeTruthy();
    // UUID v4 format
    expect(id).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
    );
  });

  it("logs info on successful request", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}, { status: 200 }));
    const instrumented = withInstrumentation(handler);
    await instrumented(makeRequest("http://localhost:3000/api/health"));

    expect(logger.info).toHaveBeenCalledWith(
      "API request completed",
      expect.objectContaining({
        route: "/api/health",
        method: "GET",
        status: 200,
        duration: expect.any(Number),
        requestId: expect.any(String),
      }),
    );
  });

  it("logs error on handler exception", async () => {
    const handler = vi.fn().mockRejectedValue(new Error("DB timeout"));
    const instrumented = withInstrumentation(handler);

    await expect(
      instrumented(makeRequest("http://localhost:3000/api/health")),
    ).rejects.toThrow("DB timeout");

    expect(logger.error).toHaveBeenCalledWith(
      "API request failed",
      expect.objectContaining({
        route: "/api/health",
        method: "GET",
        duration: expect.any(Number),
        error: expect.objectContaining({
          name: "Error",
          message: "DB timeout",
        }),
      }),
    );
  });

  it("captures exception in Sentry on handler error", async () => {
    const err = new Error("Sentry test");
    const handler = vi.fn().mockRejectedValue(err);
    const instrumented = withInstrumentation(handler);

    await expect(instrumented(makeRequest())).rejects.toThrow("Sentry test");

    expect(Sentry.captureException).toHaveBeenCalledWith(
      err,
      expect.objectContaining({
        tags: expect.objectContaining({
          route: "/api/test",
          method: "GET",
        }),
        extra: expect.objectContaining({
          duration: expect.any(Number),
        }),
      }),
    );
  });

  it("does not call Sentry on successful request", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}));
    const instrumented = withInstrumentation(handler);
    await instrumented(makeRequest());
    expect(Sentry.captureException).not.toHaveBeenCalled();
  });

  it("re-throws the original error", async () => {
    const err = new TypeError("custom type error");
    const handler = vi.fn().mockRejectedValue(err);
    const instrumented = withInstrumentation(handler);

    await expect(instrumented(makeRequest())).rejects.toBe(err);
  });

  it("handles non-Error thrown values", async () => {
    const handler = vi.fn().mockRejectedValue("string error");
    const instrumented = withInstrumentation(handler);

    await expect(instrumented(makeRequest())).rejects.toBe("string error");

    expect(logger.error).toHaveBeenCalledWith(
      "API request failed",
      expect.objectContaining({
        error: { name: "Unknown", message: "string error" },
      }),
    );
  });

  it("measures duration (non-negative)", async () => {
    const handler = vi.fn().mockResolvedValue(NextResponse.json({}));
    const instrumented = withInstrumentation(handler);
    await instrumented(makeRequest());

    const call = vi.mocked(logger.info).mock.calls[0];
    const ctx = call[1] as Record<string, unknown>;
    expect(ctx.duration).toBeGreaterThanOrEqual(0);
  });
});
