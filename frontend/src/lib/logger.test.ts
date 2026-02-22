import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { log, logger } from "./logger";
import type { LogLevel } from "./logger";

// ─── Helpers ────────────────────────────────────────────────────────────────

let logSpy: ReturnType<typeof vi.spyOn>;
let errorSpy: ReturnType<typeof vi.spyOn>;

beforeEach(() => {
  logSpy = vi.spyOn(console, "log").mockImplementation(() => {});
  errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});
  // Default LOG_LEVEL is "info" (test env doesn't set it)
  delete process.env.LOG_LEVEL;
});

afterEach(() => {
  logSpy.mockRestore();
  errorSpy.mockRestore();
  delete process.env.LOG_LEVEL;
});

function lastLogEntry(): Record<string, unknown> | null {
  const calls = logSpy.mock.calls;
  if (calls.length === 0) return null;
  return JSON.parse(calls[calls.length - 1][0] as string);
}

function lastErrorEntry(): Record<string, unknown> | null {
  const calls = errorSpy.mock.calls;
  if (calls.length === 0) return null;
  return JSON.parse(calls[calls.length - 1][0] as string);
}

// ─── log() ──────────────────────────────────────────────────────────────────

describe("log()", () => {
  it("outputs structured JSON to console.log for info level", () => {
    log("info", "test message");
    expect(logSpy).toHaveBeenCalledTimes(1);
    const entry = lastLogEntry();
    expect(entry).not.toBeNull();
    expect(entry!.level).toBe("info");
    expect(entry!.message).toBe("test message");
  });

  it("outputs to console.error for error level", () => {
    log("error", "something broke");
    expect(errorSpy).toHaveBeenCalledTimes(1);
    expect(logSpy).not.toHaveBeenCalled();
    const entry = lastErrorEntry();
    expect(entry!.level).toBe("error");
  });

  it("outputs to console.error for fatal level", () => {
    log("fatal", "system down");
    expect(errorSpy).toHaveBeenCalledTimes(1);
    const entry = lastErrorEntry();
    expect(entry!.level).toBe("fatal");
  });

  it("outputs to console.log for debug level", () => {
    process.env.LOG_LEVEL = "debug";
    log("debug", "verbose info");
    expect(logSpy).toHaveBeenCalledTimes(1);
    const entry = lastLogEntry();
    expect(entry!.level).toBe("debug");
  });

  it("outputs to console.log for warn level", () => {
    log("warn", "heads up");
    expect(logSpy).toHaveBeenCalledTimes(1);
    const entry = lastLogEntry();
    expect(entry!.level).toBe("warn");
  });

  it("includes ISO timestamp", () => {
    log("info", "test");
    const entry = lastLogEntry();
    expect(entry!.timestamp).toBeDefined();
    expect(new Date(entry!.timestamp as string).toISOString()).toBe(
      entry!.timestamp,
    );
  });

  it("includes environment tag", () => {
    log("info", "test");
    const entry = lastLogEntry();
    // In vitest NODE_ENV is "test"
    expect(entry!.environment).toBe("test");
  });

  it("includes version tag", () => {
    log("info", "test");
    const entry = lastLogEntry();
    // No VERCEL_GIT_COMMIT_SHA in test → "local"
    expect(entry!.version).toBe("local");
  });

  it("includes optional context fields", () => {
    log("info", "request done", {
      requestId: "abc-123",
      route: "/api/health",
      method: "GET",
      status: 200,
      duration: 42,
    });
    const entry = lastLogEntry();
    expect(entry!.requestId).toBe("abc-123");
    expect(entry!.route).toBe("/api/health");
    expect(entry!.method).toBe("GET");
    expect(entry!.status).toBe(200);
    expect(entry!.duration).toBe(42);
  });

  it("includes error object in context", () => {
    log("error", "failed", {
      error: { name: "RPCError", message: "timeout", stack: "at foo.ts:1" },
    });
    const entry = lastErrorEntry();
    expect(entry!.error).toEqual({
      name: "RPCError",
      message: "timeout",
      stack: "at foo.ts:1",
    });
  });

  it("includes meta field", () => {
    log("info", "extra", { meta: { foo: "bar", count: 5 } });
    const entry = lastLogEntry();
    expect(entry!.meta).toEqual({ foo: "bar", count: 5 });
  });

  it("includes userId", () => {
    log("info", "user action", { userId: "user-uuid" });
    const entry = lastLogEntry();
    expect(entry!.userId).toBe("user-uuid");
  });
});

// ─── Level filtering ────────────────────────────────────────────────────────

describe("level filtering", () => {
  it("drops debug when LOG_LEVEL is info (default)", () => {
    log("debug", "should be dropped");
    expect(logSpy).not.toHaveBeenCalled();
    expect(errorSpy).not.toHaveBeenCalled();
  });

  it("passes info when LOG_LEVEL is info", () => {
    log("info", "should pass");
    expect(logSpy).toHaveBeenCalledTimes(1);
  });

  it("passes error when LOG_LEVEL is warn", () => {
    process.env.LOG_LEVEL = "warn";
    log("error", "should pass");
    expect(errorSpy).toHaveBeenCalledTimes(1);
  });

  it("drops info when LOG_LEVEL is warn", () => {
    process.env.LOG_LEVEL = "warn";
    log("info", "should be dropped");
    expect(logSpy).not.toHaveBeenCalled();
  });

  it("drops warn when LOG_LEVEL is error", () => {
    process.env.LOG_LEVEL = "error";
    log("warn", "should be dropped");
    expect(logSpy).not.toHaveBeenCalled();
  });

  it("passes fatal when LOG_LEVEL is fatal", () => {
    process.env.LOG_LEVEL = "fatal";
    log("fatal", "critical");
    expect(errorSpy).toHaveBeenCalledTimes(1);
  });

  it("drops error when LOG_LEVEL is fatal", () => {
    process.env.LOG_LEVEL = "fatal";
    log("error", "should be dropped");
    expect(errorSpy).not.toHaveBeenCalled();
  });

  it("passes debug when LOG_LEVEL is debug", () => {
    process.env.LOG_LEVEL = "debug";
    log("debug", "verbose");
    expect(logSpy).toHaveBeenCalledTimes(1);
  });

  it("treats invalid LOG_LEVEL as info", () => {
    process.env.LOG_LEVEL = "garbage";
    log("debug", "should be dropped");
    log("info", "should pass");
    expect(logSpy).toHaveBeenCalledTimes(1);
  });
});

// ─── logger convenience methods ─────────────────────────────────────────────

describe("logger", () => {
  const levels: LogLevel[] = ["debug", "info", "warn", "error", "fatal"];

  it("has all 5 level methods", () => {
    for (const level of levels) {
      expect(typeof logger[level]).toBe("function");
    }
  });

  it("logger.info delegates to log", () => {
    logger.info("test info");
    expect(logSpy).toHaveBeenCalledTimes(1);
    const entry = lastLogEntry();
    expect(entry!.level).toBe("info");
    expect(entry!.message).toBe("test info");
  });

  it("logger.error delegates to log", () => {
    logger.error("test error");
    expect(errorSpy).toHaveBeenCalledTimes(1);
    const entry = lastErrorEntry();
    expect(entry!.level).toBe("error");
  });

  it("logger.warn delegates to log", () => {
    logger.warn("test warn");
    expect(logSpy).toHaveBeenCalledTimes(1);
    const entry = lastLogEntry();
    expect(entry!.level).toBe("warn");
  });

  it("logger.debug respects level filtering", () => {
    // Default LOG_LEVEL=info, so debug should be dropped
    logger.debug("dropped");
    expect(logSpy).not.toHaveBeenCalled();
  });

  it("logger.fatal delegates to log", () => {
    logger.fatal("critical");
    expect(errorSpy).toHaveBeenCalledTimes(1);
    const entry = lastErrorEntry();
    expect(entry!.level).toBe("fatal");
  });

  it("logger methods pass context through", () => {
    logger.info("ctx test", { route: "/test", duration: 100 });
    const entry = lastLogEntry();
    expect(entry!.route).toBe("/test");
    expect(entry!.duration).toBe(100);
  });
});
