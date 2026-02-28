import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  getTurnstileSiteKey,
  isTurnstileConfigured,
  verifyTurnstileToken,
  isTurnstileSuccess,
  isTurnstileFailure,
  TURNSTILE_TEST_SITE_KEY,
  VERIFY_FUNCTION_NAME,
} from "@/lib/turnstile";
import type {
  TurnstileVerifySuccess,
  TurnstileVerifyFailure,
} from "@/lib/turnstile";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockInvoke = vi.fn();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fakeSupabase = { functions: { invoke: mockInvoke } } as any;

beforeEach(() => {
  vi.clearAllMocks();
  // Reset env var for each test
  vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", "");
});

// ─── Constants ──────────────────────────────────────────────────────────────

describe("TURNSTILE_TEST_SITE_KEY", () => {
  it("should be the Cloudflare always-pass test key", () => {
    expect(TURNSTILE_TEST_SITE_KEY).toBe("1x00000000000000000000AA");
  });
});

describe("VERIFY_FUNCTION_NAME", () => {
  it("should be 'verify-turnstile'", () => {
    expect(VERIFY_FUNCTION_NAME).toBe("verify-turnstile");
  });
});

// ─── getTurnstileSiteKey ────────────────────────────────────────────────────

describe("getTurnstileSiteKey", () => {
  it("should return the test key when env var is not set", () => {
    vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", "");
    expect(getTurnstileSiteKey()).toBe(TURNSTILE_TEST_SITE_KEY);
  });

  it("should return the configured key when env var is set", () => {
    vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", "0x_real_key");
    expect(getTurnstileSiteKey()).toBe("0x_real_key");
  });
});

// ─── isTurnstileConfigured ──────────────────────────────────────────────────

describe("isTurnstileConfigured", () => {
  it("should return false when env var is empty", () => {
    vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", "");
    expect(isTurnstileConfigured()).toBe(false);
  });

  it("should return false when env var is the test key", () => {
    vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", TURNSTILE_TEST_SITE_KEY);
    expect(isTurnstileConfigured()).toBe(false);
  });

  it("should return true when env var is a real key", () => {
    vi.stubEnv("NEXT_PUBLIC_TURNSTILE_SITE_KEY", "0x_production_key");
    expect(isTurnstileConfigured()).toBe(true);
  });
});

// ─── verifyTurnstileToken ───────────────────────────────────────────────────

describe("verifyTurnstileToken", () => {
  it("should return failure for empty token", async () => {
    const result = await verifyTurnstileToken(fakeSupabase, "");
    expect(result.valid).toBe(false);
    if (!result.valid) {
      expect(result.error).toBe("Missing Turnstile token.");
    }
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it("should return failure for whitespace-only token", async () => {
    const result = await verifyTurnstileToken(fakeSupabase, "   ");
    expect(result.valid).toBe(false);
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it("should call Edge Function with correct params", async () => {
    mockInvoke.mockResolvedValueOnce({
      data: { valid: true, challenge_ts: "2026-01-01T00:00:00Z" },
      error: null,
    });

    await verifyTurnstileToken(fakeSupabase, "test-token-123");

    expect(mockInvoke).toHaveBeenCalledWith(VERIFY_FUNCTION_NAME, {
      body: { token: "test-token-123" },
    });
  });

  it("should return success when Edge Function returns valid", async () => {
    mockInvoke.mockResolvedValueOnce({
      data: {
        valid: true,
        challenge_ts: "2026-01-01T00:00:00Z",
        hostname: "example.com",
      },
      error: null,
    });

    const result = await verifyTurnstileToken(fakeSupabase, "valid-token");
    expect(result.valid).toBe(true);
    if (result.valid) {
      expect(result.challenge_ts).toBe("2026-01-01T00:00:00Z");
      expect(result.hostname).toBe("example.com");
    }
  });

  it("should return failure when Edge Function returns invalid", async () => {
    mockInvoke.mockResolvedValueOnce({
      data: {
        valid: false,
        error: "Token already used.",
        error_codes: ["timeout-or-duplicate"],
      },
      error: null,
    });

    const result = await verifyTurnstileToken(fakeSupabase, "bad-token");
    expect(result.valid).toBe(false);
    if (!result.valid) {
      expect(result.error).toBe("Token already used.");
      expect(result.error_codes).toEqual(["timeout-or-duplicate"]);
    }
  });

  it("should gracefully degrade when Edge Function is unreachable", async () => {
    const consoleSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    mockInvoke.mockResolvedValueOnce({
      data: null,
      error: { message: "Function not found" },
    });

    const result = await verifyTurnstileToken(fakeSupabase, "some-token");
    expect(result.valid).toBe(true);
    expect(consoleSpy).toHaveBeenCalledWith(
      "Turnstile verification unavailable:",
      "Function not found",
    );
    consoleSpy.mockRestore();
  });

  it("should gracefully degrade on unexpected response shape", async () => {
    const consoleSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    mockInvoke.mockResolvedValueOnce({
      data: "unexpected string",
      error: null,
    });

    const result = await verifyTurnstileToken(fakeSupabase, "some-token");
    expect(result.valid).toBe(true);
    expect(consoleSpy).toHaveBeenCalledWith(
      "Unexpected Turnstile response:",
      "unexpected string",
    );
    consoleSpy.mockRestore();
  });

  it("should gracefully degrade on network error", async () => {
    const consoleSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    mockInvoke.mockRejectedValueOnce(new Error("Network error"));

    const result = await verifyTurnstileToken(fakeSupabase, "some-token");
    expect(result.valid).toBe(true);
    expect(consoleSpy).toHaveBeenCalledWith(
      "Turnstile verification network error",
    );
    consoleSpy.mockRestore();
  });
});

// ─── Type Guards ────────────────────────────────────────────────────────────

describe("isTurnstileSuccess", () => {
  it("should return true for valid results", () => {
    const result: TurnstileVerifySuccess = { valid: true };
    expect(isTurnstileSuccess(result)).toBe(true);
  });

  it("should return false for invalid results", () => {
    const result: TurnstileVerifyFailure = {
      valid: false,
      error: "Failed",
    };
    expect(isTurnstileSuccess(result)).toBe(false);
  });
});

describe("isTurnstileFailure", () => {
  it("should return true for invalid results", () => {
    const result: TurnstileVerifyFailure = {
      valid: false,
      error: "Failed",
    };
    expect(isTurnstileFailure(result)).toBe(true);
  });

  it("should return false for valid results", () => {
    const result: TurnstileVerifySuccess = { valid: true };
    expect(isTurnstileFailure(result)).toBe(false);
  });
});
