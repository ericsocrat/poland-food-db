import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  recordScanViaGateway,
  submitProductViaGateway,
  createApiGateway,
  isGatewayRateLimited,
  isGatewayAuthError,
  isGatewayValidationError,
  GATEWAY_FUNCTION_NAME,
} from "@/lib/api-gateway";
import type {
  GatewayResult,
  GatewayError,
  SubmitProductParams,
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
});
