import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  recordScanViaGateway,
  submitProductViaGateway,
  trackEventViaGateway,
  saveSearchViaGateway,
  createApiGateway,
  isGatewayRateLimited,
  isGatewayAuthError,
  isGatewayValidationError,
  isGatewayCaptchaRequired,
  isGatewayCaptchaFailed,
  GATEWAY_FUNCTION_NAME,
} from "@/lib/api-gateway";
import type {
  GatewayResult,
  GatewayError,
  SubmitProductParams,
  TrackEventParams,
  SaveSearchParams,
} from "@/lib/api-gateway";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockInvoke = vi.fn();
const mockRpc = vi.fn();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fakeSupabase = { functions: { invoke: mockInvoke }, rpc: mockRpc } as any;

beforeEach(() => {
  vi.clearAllMocks();
});

// ─── Constants ──────────────────────────────────────────────────────────────

describe("GATEWAY_FUNCTION_NAME", () => {
  it("should be 'api-gateway'", () => {
    expect(GATEWAY_FUNCTION_NAME).toBe("api-gateway");
  });
});

// ─── Type Guards ────────────────────────────────────────────────────────────

describe("isGatewayRateLimited", () => {
  it("should return true for rate_limit_exceeded error", () => {
    const result: GatewayError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Too many requests",
      retry_after: 3600,
    };
    expect(isGatewayRateLimited(result)).toBe(true);
  });

  it("should return false for other errors", () => {
    const result: GatewayError = {
      ok: false,
      error: "unauthorized",
      message: "Not logged in",
    };
    expect(isGatewayRateLimited(result)).toBe(false);
  });

  it("should return false for success results", () => {
    const result: GatewayResult = { ok: true, data: {} };
    expect(isGatewayRateLimited(result)).toBe(false);
  });
});

describe("isGatewayAuthError", () => {
  it("should return true for unauthorized error", () => {
    const result: GatewayError = {
      ok: false,
      error: "unauthorized",
      message: "Missing token",
    };
    expect(isGatewayAuthError(result)).toBe(true);
  });

  it("should return false for non-auth errors", () => {
    const result: GatewayError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Too many",
    };
    expect(isGatewayAuthError(result)).toBe(false);
  });

  it("should return false for success results", () => {
    const result: GatewayResult = { ok: true, data: null };
    expect(isGatewayAuthError(result)).toBe(false);
  });
});

// ─── isGatewayValidationError ───────────────────────────────────────────────

describe("isGatewayValidationError", () => {
  it("should return true for invalid_input error", () => {
    const result: GatewayError = {
      ok: false,
      error: "invalid_input",
      message: "Missing field",
    };
    expect(isGatewayValidationError(result)).toBe(true);
  });

  it("should return true for invalid_ean error", () => {
    const result: GatewayError = {
      ok: false,
      error: "invalid_ean",
      message: "Bad format",
    };
    expect(isGatewayValidationError(result)).toBe(true);
  });

  it("should return true for invalid_ean_checksum error", () => {
    const result: GatewayError = {
      ok: false,
      error: "invalid_ean_checksum",
      message: "Bad checksum",
    };
    expect(isGatewayValidationError(result)).toBe(true);
  });

  it("should return false for non-validation errors", () => {
    const result: GatewayError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Too many",
    };
    expect(isGatewayValidationError(result)).toBe(false);
  });

  it("should return false for success results", () => {
    const result: GatewayResult = { ok: true, data: {} };
    expect(isGatewayValidationError(result)).toBe(false);
  });
});

// ─── isGatewayCaptchaRequired ───────────────────────────────────────────────

describe("isGatewayCaptchaRequired", () => {
  it("should return true for captcha_required error", () => {
    const result: GatewayError & { reason: string } = {
      ok: false,
      error: "captcha_required",
      message: "CAPTCHA required",
      reason: "low_trust_score",
    };
    expect(isGatewayCaptchaRequired(result)).toBe(true);
  });

  it("should return false for other errors", () => {
    const result: GatewayError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Too many",
    };
    expect(isGatewayCaptchaRequired(result)).toBe(false);
  });

  it("should return false for success results", () => {
    const result: GatewayResult = { ok: true, data: {} };
    expect(isGatewayCaptchaRequired(result)).toBe(false);
  });
});

// ─── isGatewayCaptchaFailed ─────────────────────────────────────────────────

describe("isGatewayCaptchaFailed", () => {
  it("should return true for captcha_failed error", () => {
    const result: GatewayError = {
      ok: false,
      error: "captcha_failed",
      message: "CAPTCHA verification failed",
    };
    expect(isGatewayCaptchaFailed(result)).toBe(true);
  });

  it("should return false for other errors", () => {
    const result: GatewayError = {
      ok: false,
      error: "unauthorized",
      message: "Not logged in",
    };
    expect(isGatewayCaptchaFailed(result)).toBe(false);
  });

  it("should return false for success results", () => {
    const result: GatewayResult = { ok: true, data: null };
    expect(isGatewayCaptchaFailed(result)).toBe(false);
  });
});

// ─── recordScanViaGateway ───────────────────────────────────────────────────

describe("recordScanViaGateway", () => {
  it("should invoke the gateway with correct action and EAN", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { scan_id: 42 } },
      error: null,
    });

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "record-scan", ean: "5901234123457" },
    });
    expect(result).toEqual({ ok: true, data: { scan_id: 42 } });
  });

  it("should return gateway error response as-is", async () => {
    const gatewayError = {
      ok: false,
      error: "invalid_ean",
      message: "EAN must be 8 or 13 digits",
    };
    mockInvoke.mockResolvedValue({ data: gatewayError, error: null });

    const result = await recordScanViaGateway(fakeSupabase, "123");
    expect(result).toEqual(gatewayError);
  });

  it("should return rate limit error with retry_after", async () => {
    const rateLimitError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Exceeded 100/day limit",
      retry_after: 43200,
    };
    mockInvoke.mockResolvedValue({ data: rateLimitError, error: null });

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rate_limit_exceeded");
      expect(result.retry_after).toBe(43200);
    }
  });

  // ── Graceful degradation: fallback to direct RPC ──────────────────────

  it("should fall back to direct RPC when gateway is unreachable", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Edge Function not found" },
    });
    mockRpc.mockResolvedValue({
      data: { scan_id: 99 },
      error: null,
    });

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");

    expect(mockRpc).toHaveBeenCalledWith("api_record_scan", {
      p_ean: "5901234123457",
    });
    expect(result).toEqual({ ok: true, data: { scan_id: 99 } });
  });

  it("should return RPC error when fallback also fails", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Gateway down" },
    });
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "RPC failed too" },
    });

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rpc_error");
      expect(result.message).toBe("RPC failed too");
    }
  });

  it("should return original gateway error when fallback throws", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Gateway down" },
    });
    mockRpc.mockRejectedValue(new Error("Network failure"));

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_unreachable");
    }
  });

  // ── Exception handling ────────────────────────────────────────────────

  it("should handle invoke throwing an exception", async () => {
    mockInvoke.mockRejectedValue(new Error("Network error"));

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_exception");
      expect(result.message).toBe("Network error");
    }
  });

  it("should handle non-Error exceptions", async () => {
    mockInvoke.mockRejectedValue("string error");

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_exception");
      expect(result.message).toContain("unexpected error");
    }
  });

  // ── Unexpected response shapes ────────────────────────────────────────

  it("should handle response without 'ok' field as success", async () => {
    mockInvoke.mockResolvedValue({
      data: { scan_id: 7, product_id: 42 },
      error: null,
    });

    const result = await recordScanViaGateway(fakeSupabase, "5901234123457");
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.data).toEqual({ scan_id: 7, product_id: 42 });
    }
  });
});

// ─── submitProductViaGateway ────────────────────────────────────────────────

describe("submitProductViaGateway", () => {
  const validParams: SubmitProductParams = {
    ean: "5901234123457",
    product_name: "Test Product",
    brand: "TestBrand",
    category: "Chips",
  };

  it("should invoke the gateway with correct action and params", async () => {
    mockInvoke.mockResolvedValue({
      data: {
        ok: true,
        data: { submission_id: "42", ean: "5901234123457", status: "pending" },
      },
      error: null,
    });

    const result = await submitProductViaGateway(fakeSupabase, validParams);

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "submit-product",
        ean: "5901234123457",
        product_name: "Test Product",
        brand: "TestBrand",
        category: "Chips",
      },
    });
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.data).toHaveProperty("submission_id");
    }
  });

  it("should return validation error for invalid EAN checksum", async () => {
    const validationError = {
      ok: false,
      error: "invalid_ean_checksum",
      message: "EAN checksum is invalid.",
    };
    mockInvoke.mockResolvedValue({ data: validationError, error: null });

    const result = await submitProductViaGateway(fakeSupabase, {
      ...validParams,
      ean: "5901234123450",
    });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("invalid_ean_checksum");
    }
  });

  it("should return validation error for missing product_name", async () => {
    const inputError = {
      ok: false,
      error: "invalid_input",
      message: "Missing or empty 'product_name' parameter.",
    };
    mockInvoke.mockResolvedValue({ data: inputError, error: null });

    const result = await submitProductViaGateway(fakeSupabase, {
      ...validParams,
      product_name: "",
    });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("invalid_input");
    }
  });

  it("should return rate limit error at 10/day", async () => {
    const rateLimitError = {
      ok: false,
      error: "rate_limit_exceeded",
      message: "Exceeded 10 requests per 24 hours",
      retry_after: 43200,
    };
    mockInvoke.mockResolvedValue({ data: rateLimitError, error: null });

    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rate_limit_exceeded");
      expect(result.retry_after).toBe(43200);
    }
  });

  // ── Graceful degradation ──────────────────────────────────────────────

  it("should fall back to direct RPC when gateway is unreachable", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Edge Function not found" },
    });
    mockRpc.mockResolvedValue({
      data: {
        api_version: "1.0",
        submission_id: "99",
        ean: "5901234123457",
        status: "pending",
      },
      error: null,
    });

    const result = await submitProductViaGateway(fakeSupabase, validParams);

    expect(mockRpc).toHaveBeenCalledWith("api_submit_product", {
      p_ean: "5901234123457",
      p_product_name: "Test Product",
      p_brand: "TestBrand",
      p_category: "Chips",
      p_photo_url: null,
      p_notes: null,
    });
    expect(result.ok).toBe(true);
  });

  it("should return RPC error when fallback also fails", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Gateway down" },
    });
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "RPC submission failed" },
    });

    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rpc_error");
      expect(result.message).toBe("RPC submission failed");
    }
  });

  it("should return original gateway error when fallback throws", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Gateway down" },
    });
    mockRpc.mockRejectedValue(new Error("Network failure"));

    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_unreachable");
    }
  });

  // ── Optional fields ───────────────────────────────────────────────────

  it("should handle params with only required fields", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { submission_id: "1" } },
      error: null,
    });

    const result = await submitProductViaGateway(fakeSupabase, {
      ean: "5901234123457",
      product_name: "Minimal Product",
    });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "submit-product",
        ean: "5901234123457",
        product_name: "Minimal Product",
      },
    });
    expect(result.ok).toBe(true);
  });

  // ── CAPTCHA integration (Phase 3) ─────────────────────────────────────

  it("should return captcha_required error when trust is low", async () => {
    const captchaError = {
      ok: false,
      error: "captcha_required",
      message: "CAPTCHA verification is required for this action.",
      reason: "low_trust_score",
    };
    mockInvoke.mockResolvedValue({ data: captchaError, error: null });

    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("captcha_required");
    }
    expect(isGatewayCaptchaRequired(result)).toBe(true);
  });

  it("should return captcha_required error when velocity is high", async () => {
    const captchaError = {
      ok: false,
      error: "captcha_required",
      message: "CAPTCHA verification is required for this action.",
      reason: "high_velocity",
    };
    mockInvoke.mockResolvedValue({ data: captchaError, error: null });

    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(false);
    expect(isGatewayCaptchaRequired(result)).toBe(true);
  });

  it("should return captcha_failed error when token is invalid", async () => {
    const captchaFailed = {
      ok: false,
      error: "captcha_failed",
      message: "CAPTCHA verification failed. Please try again.",
    };
    mockInvoke.mockResolvedValue({ data: captchaFailed, error: null });

    const result = await submitProductViaGateway(fakeSupabase, {
      ...validParams,
      turnstile_token: "invalid-token",
    });
    expect(result.ok).toBe(false);
    expect(isGatewayCaptchaFailed(result)).toBe(true);
  });

  it("should pass turnstile_token to gateway when provided", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { submission_id: "10" } },
      error: null,
    });

    const result = await submitProductViaGateway(fakeSupabase, {
      ...validParams,
      turnstile_token: "valid-captcha-token",
    });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "submit-product",
        ean: "5901234123457",
        product_name: "Test Product",
        brand: "TestBrand",
        category: "Chips",
        turnstile_token: "valid-captcha-token",
      },
    });
    expect(result.ok).toBe(true);
  });

  it("should succeed without turnstile_token for high-trust users", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { submission_id: "11" } },
      error: null,
    });

    // High-trust users bypass CAPTCHA — no turnstile_token needed
    const result = await submitProductViaGateway(fakeSupabase, validParams);
    expect(result.ok).toBe(true);
  });
});

// ─── createApiGateway factory ───────────────────────────────────────────────

describe("createApiGateway", () => {
  it("should return an object with recordScan and submitProduct methods", () => {
    const gateway = createApiGateway(fakeSupabase);
    expect(gateway).toHaveProperty("recordScan");
    expect(gateway).toHaveProperty("submitProduct");
    expect(typeof gateway.recordScan).toBe("function");
    expect(typeof gateway.submitProduct).toBe("function");
  });

  it("should forward recordScan calls to recordScanViaGateway", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { scan_id: 1 } },
      error: null,
    });

    const gateway = createApiGateway(fakeSupabase);
    const result = await gateway.recordScan("5901234123457");

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "record-scan", ean: "5901234123457" },
    });
    expect(result).toEqual({ ok: true, data: { scan_id: 1 } });
  });

  it("should forward submitProduct calls to submitProductViaGateway", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { submission_id: "5" } },
      error: null,
    });

    const gateway = createApiGateway(fakeSupabase);
    const result = await gateway.submitProduct({
      ean: "5901234123457",
      product_name: "Factory Test",
    });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "submit-product",
        ean: "5901234123457",
        product_name: "Factory Test",
      },
    });
    expect(result).toEqual({ ok: true, data: { submission_id: "5" } });
  });

  it("should forward trackEvent calls to trackEventViaGateway", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { event_id: 42 } },
      error: null,
    });

    const gateway = createApiGateway(fakeSupabase);
    const result = await gateway.trackEvent({ event_name: "page_view" });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "track-event", event_name: "page_view" },
    });
    expect(result).toEqual({ ok: true, data: { event_id: 42 } });
  });

  it("should forward saveSearch calls to saveSearchViaGateway", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { search_id: 7 } },
      error: null,
    });

    const gateway = createApiGateway(fakeSupabase);
    const result = await gateway.saveSearch({ name: "My search" });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "save-search", name: "My search" },
    });
    expect(result).toEqual({ ok: true, data: { search_id: 7 } });
  });
});

// ─── trackEventViaGateway ───────────────────────────────────────────────────

describe("trackEventViaGateway", () => {
  it("should invoke gateway with track-event action", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { event_id: 99 } },
      error: null,
    });

    const result = await trackEventViaGateway(fakeSupabase, {
      event_name: "product_view",
    });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "track-event", event_name: "product_view" },
    });
    expect(result).toEqual({ ok: true, data: { event_id: 99 } });
  });

  it("should pass optional event_data, session_id, device_type", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { event_id: 100 } },
      error: null,
    });

    const params: TrackEventParams = {
      event_name: "scan_complete",
      event_data: { product_id: 42 },
      session_id: "sess-123",
      device_type: "mobile",
    };
    const result = await trackEventViaGateway(fakeSupabase, params);

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "track-event",
        event_name: "scan_complete",
        event_data: { product_id: 42 },
        session_id: "sess-123",
        device_type: "mobile",
      },
    });
    expect(result).toEqual({ ok: true, data: { event_id: 100 } });
  });

  it("should return rate limit error when rate limited", async () => {
    mockInvoke.mockResolvedValue({
      data: {
        ok: false,
        error: "rate_limit_exceeded",
        message: "Too many events",
        retry_after: 60,
      },
      error: null,
    });

    const result = await trackEventViaGateway(fakeSupabase, {
      event_name: "spam",
    });

    expect(result.ok).toBe(false);
    expect(isGatewayRateLimited(result)).toBe(true);
  });

  it("should fall back to direct RPC when gateway is unreachable", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Network error" },
    });
    mockRpc.mockResolvedValue({
      data: { event_id: 101 },
      error: null,
    });

    const result = await trackEventViaGateway(fakeSupabase, {
      event_name: "fallback_event",
      event_data: { key: "val" },
      session_id: "s1",
      device_type: "desktop",
    });

    expect(mockRpc).toHaveBeenCalledWith("api_track_event", {
      p_event_name: "fallback_event",
      p_event_data: { key: "val" },
      p_session_id: "s1",
      p_device_type: "desktop",
    });
    expect(result).toEqual({ ok: true, data: { event_id: 101 } });
  });

  it("should use defaults for optional params in fallback", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockResolvedValue({
      data: { event_id: 102 },
      error: null,
    });

    await trackEventViaGateway(fakeSupabase, { event_name: "minimal" });

    expect(mockRpc).toHaveBeenCalledWith("api_track_event", {
      p_event_name: "minimal",
      p_event_data: {},
      p_session_id: null,
      p_device_type: null,
    });
  });

  it("should return rpc_error when fallback RPC fails", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "RPC failed" },
    });

    const result = await trackEventViaGateway(fakeSupabase, {
      event_name: "fail",
    });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rpc_error");
    }
  });

  it("should return gateway error when fallback throws", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockRejectedValue(new Error("Crash"));

    const result = await trackEventViaGateway(fakeSupabase, {
      event_name: "crash",
    });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_unreachable");
    }
  });
});

// ─── saveSearchViaGateway ───────────────────────────────────────────────────

describe("saveSearchViaGateway", () => {
  it("should invoke gateway with save-search action", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { search_id: 1 } },
      error: null,
    });

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "Healthy chips",
    });

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: { action: "save-search", name: "Healthy chips" },
    });
    expect(result).toEqual({ ok: true, data: { search_id: 1 } });
  });

  it("should pass optional query and filters", async () => {
    mockInvoke.mockResolvedValue({
      data: { ok: true, data: { search_id: 2 } },
      error: null,
    });

    const params: SaveSearchParams = {
      name: "Low sugar dairy",
      query: "yogurt",
      filters: { category: "Dairy", max_sugar: 5 },
    };
    const result = await saveSearchViaGateway(fakeSupabase, params);

    expect(mockInvoke).toHaveBeenCalledWith("api-gateway", {
      body: {
        action: "save-search",
        name: "Low sugar dairy",
        query: "yogurt",
        filters: { category: "Dairy", max_sugar: 5 },
      },
    });
    expect(result).toEqual({ ok: true, data: { search_id: 2 } });
  });

  it("should return rate limit error when rate limited", async () => {
    mockInvoke.mockResolvedValue({
      data: {
        ok: false,
        error: "rate_limit_exceeded",
        message: "Too many saves",
        retry_after: 300,
      },
      error: null,
    });

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "Spam",
    });

    expect(result.ok).toBe(false);
    expect(isGatewayRateLimited(result)).toBe(true);
  });

  it("should return validation error for invalid input", async () => {
    mockInvoke.mockResolvedValue({
      data: {
        ok: false,
        error: "invalid_input",
        message: "Missing or empty 'name' parameter.",
      },
      error: null,
    });

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "",
    });

    expect(result.ok).toBe(false);
    expect(isGatewayValidationError(result)).toBe(true);
  });

  it("should fall back to direct RPC when gateway is unreachable", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Unreachable" },
    });
    mockRpc.mockResolvedValue({
      data: { search_id: 3 },
      error: null,
    });

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "Fallback search",
      query: "chips",
      filters: { category: "Chips" },
    });

    expect(mockRpc).toHaveBeenCalledWith("api_save_search", {
      p_name: "Fallback search",
      p_query: "chips",
      p_filters: { category: "Chips" },
    });
    expect(result).toEqual({ ok: true, data: { search_id: 3 } });
  });

  it("should use defaults for optional params in fallback", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockResolvedValue({
      data: { search_id: 4 },
      error: null,
    });

    await saveSearchViaGateway(fakeSupabase, { name: "Basic" });

    expect(mockRpc).toHaveBeenCalledWith("api_save_search", {
      p_name: "Basic",
      p_query: null,
      p_filters: {},
    });
  });

  it("should return rpc_error when fallback RPC fails", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "Save failed" },
    });

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "Broken",
    });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("rpc_error");
    }
  });

  it("should return gateway error when fallback throws", async () => {
    mockInvoke.mockResolvedValue({
      data: null,
      error: { message: "Down" },
    });
    mockRpc.mockRejectedValue(new Error("Crash"));

    const result = await saveSearchViaGateway(fakeSupabase, {
      name: "Crash",
    });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("gateway_unreachable");
    }
  });
});
