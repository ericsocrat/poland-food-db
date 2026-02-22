import { describe, it, expect, vi, beforeEach } from "vitest";
import { buildErrorReport, reportBoundaryError } from "./error-reporter";
import type { ErrorInfo } from "react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@sentry/nextjs", () => ({
  captureException: vi.fn(),
}));

import * as Sentry from "@sentry/nextjs";

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeError(message: string): Error {
  const err = new Error(message);
  err.stack = "Error: " + message + "\n  at TestComponent";
  return err;
}

function makeErrorInfo(componentStack?: string): ErrorInfo {
  return { componentStack: componentStack ?? "\n  at TestComponent" } as ErrorInfo;
}

// ─── buildErrorReport ───────────────────────────────────────────────────────

describe("buildErrorReport", () => {
  it("captures error message", () => {
    const report = buildErrorReport(
      makeError("Test error"),
      makeErrorInfo(),
    );
    expect(report.message).toBe("Test error");
  });

  it("captures error stack", () => {
    const error = makeError("Stack test");
    const report = buildErrorReport(error, makeErrorInfo());
    expect(report.stack).toContain("Stack test");
    expect(report.stack).toContain("TestComponent");
  });

  it("captures component stack from ErrorInfo", () => {
    const report = buildErrorReport(
      makeError("Test"),
      makeErrorInfo("\n  at BrokenWidget\n  at Section"),
    );
    expect(report.componentStack).toContain("BrokenWidget");
    expect(report.componentStack).toContain("Section");
  });

  it("sets componentStack to undefined when absent", () => {
    const report = buildErrorReport(
      makeError("Test"),
      { componentStack: null } as unknown as ErrorInfo,
    );
    expect(report.componentStack).toBeUndefined();
  });

  it("includes context in report", () => {
    const report = buildErrorReport(
      makeError("Test"),
      makeErrorInfo(),
      { level: "section", ean: "5900617043375" },
    );
    expect(report.context.level).toBe("section");
    expect(report.context.ean).toBe("5900617043375");
  });

  it("defaults context to empty when not provided", () => {
    const report = buildErrorReport(makeError("Test"), makeErrorInfo());
    expect(report.context).toEqual({});
  });

  it("includes timestamp in ISO format", () => {
    const report = buildErrorReport(makeError("Test"), makeErrorInfo());
    // Should be a valid ISO date string
    expect(new Date(report.timestamp).toISOString()).toBe(report.timestamp);
  });

  it("includes current URL", () => {
    const report = buildErrorReport(makeError("Test"), makeErrorInfo());
    // In jsdom, window.location.href is typically "http://localhost:3000/"
    expect(report.url).toContain("http");
  });
});

// ─── reportBoundaryError ────────────────────────────────────────────────────

describe("reportBoundaryError", () => {
  let consoleErrorSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    consoleErrorSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    return () => {
      consoleErrorSpy.mockRestore();
    };
  });

  it("returns an ErrorReport object", () => {
    const report = reportBoundaryError(makeError("Report test"), makeErrorInfo());
    expect(report).toHaveProperty("message", "Report test");
    expect(report).toHaveProperty("stack");
    expect(report).toHaveProperty("componentStack");
    expect(report).toHaveProperty("timestamp");
    expect(report).toHaveProperty("url");
    expect(report).toHaveProperty("context");
  });

  it("logs to console.error in development", () => {
    reportBoundaryError(makeError("Dev log"), makeErrorInfo());
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      "[ErrorBoundary]",
      expect.objectContaining({ message: "Dev log" }),
    );
  });

  it("passes context through to report", () => {
    const report = reportBoundaryError(
      makeError("Context test"),
      makeErrorInfo(),
      { level: "page", boundary: "AppError" },
    );
    expect(report.context.level).toBe("page");
    expect(report.context.boundary).toBe("AppError");
  });

  it("handles errors with no stack", () => {
    const error = new Error("No stack");
    // Some environments might not provide a stack
    Object.defineProperty(error, "stack", { value: undefined });
    const report = reportBoundaryError(error, makeErrorInfo());
    expect(report.message).toBe("No stack");
    expect(report.stack).toBeUndefined();
  });

  it("calls Sentry.captureException with error and context", () => {
    const error = makeError("Sentry report test");
    const errorInfo = makeErrorInfo("\n  at BrokenWidget");
    reportBoundaryError(error, errorInfo, { level: "section", ean: "123" });

    expect(Sentry.captureException).toHaveBeenCalledWith(error, {
      contexts: {
        react: { componentStack: "\n  at BrokenWidget" },
        app: { level: "section", ean: "123" },
      },
    });
  });

  it("calls Sentry.captureException even without context", () => {
    const error = makeError("No context");
    reportBoundaryError(error, makeErrorInfo());

    expect(Sentry.captureException).toHaveBeenCalledWith(error, {
      contexts: {
        react: { componentStack: "\n  at TestComponent" },
        app: {},
      },
    });
  });
});
