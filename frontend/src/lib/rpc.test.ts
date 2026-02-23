import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  isAuthError,
  isRateLimitError,
  callRpc,
  normalizeRpcError,
  extractBusinessError,
  AUTH_CODES,
  AUTH_MESSAGES,
  RATE_LIMIT_CODE,
  RATE_LIMIT_MESSAGES,
} from "@/lib/rpc";

// ─── AUTH constants ─────────────────────────────────────────────────────────

describe("AUTH_CODES", () => {
  it("is a readonly tuple of known auth error codes", () => {
    expect(AUTH_CODES).toContain("PGRST301");
    expect(AUTH_CODES).toContain("401");
    expect(AUTH_CODES).toContain("403");
    expect(AUTH_CODES).toContain("JWT_EXPIRED");
    expect(AUTH_CODES.length).toBe(4);
  });
});

describe("AUTH_MESSAGES", () => {
  it("is a readonly tuple of known auth substrings", () => {
    expect(AUTH_MESSAGES).toContain("JWT expired");
    expect(AUTH_MESSAGES).toContain("not authenticated");
    expect(AUTH_MESSAGES).toContain("permission denied");
    expect(AUTH_MESSAGES).toContain("Invalid JWT");
    expect(AUTH_MESSAGES.length).toBe(4);
  });
});

// ─── normalizeRpcError ──────────────────────────────────────────────────────

describe("normalizeRpcError", () => {
  it("passes through code and message when present", () => {
    const result = normalizeRpcError({ code: "42P01", message: "relation not found" });
    expect(result).toEqual({ code: "42P01", message: "relation not found" });
  });

  it("defaults code to RPC_ERROR when null", () => {
    const result = normalizeRpcError({ code: null, message: "oops" });
    expect(result.code).toBe("RPC_ERROR");
  });

  it("defaults message to Unknown error when null", () => {
    const result = normalizeRpcError({ code: "ERR", message: null });
    expect(result.message).toBe("Unknown error");
  });

  it("defaults both fields when undefined", () => {
    const result = normalizeRpcError({ code: undefined, message: undefined });
    expect(result).toEqual({ code: "RPC_ERROR", message: "Unknown error" });
  });

  it("defaults both fields when input is null", () => {
    const result = normalizeRpcError(null);
    expect(result).toEqual({ code: "RPC_ERROR", message: "Unknown error" });
  });

  it("defaults both fields when input is undefined", () => {
    const result = normalizeRpcError(undefined);
    expect(result).toEqual({ code: "RPC_ERROR", message: "Unknown error" });
  });
});

// ─── extractBusinessError ───────────────────────────────────────────────────

describe("extractBusinessError", () => {
  it("extracts error from { error: 'msg' } payload", () => {
    const result = extractBusinessError({ error: "Product not found" });
    expect(result).toEqual({ code: "BUSINESS_ERROR", message: "Product not found" });
  });

  it("stringifies non-string error values", () => {
    const result = extractBusinessError({ error: 42 });
    expect(result?.message).toBe("42");
  });

  it("returns null for a normal data payload", () => {
    expect(extractBusinessError({ products: [] })).toBeNull();
  });

  it("returns null for null data", () => {
    expect(extractBusinessError(null)).toBeNull();
  });

  it("returns null for undefined data", () => {
    expect(extractBusinessError(undefined)).toBeNull();
  });

  it("returns null for primitive data", () => {
    expect(extractBusinessError("hello")).toBeNull();
    expect(extractBusinessError(123)).toBeNull();
  });

  it("returns null for an array", () => {
    expect(extractBusinessError([1, 2, 3])).toBeNull();
  });
});

// ─── callRpc ────────────────────────────────────────────────────────────────

function createMockSupabase(rpcResult: { data: unknown; error: unknown }) {
  return {
    rpc: vi.fn().mockResolvedValue(rpcResult),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } as any;
}

function createThrowingSupabase(err: unknown) {
  return {
    rpc: vi.fn().mockRejectedValue(err),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } as any;
}

describe("callRpc", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllEnvs();
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it("returns ok: true with data on success", async () => {
    const supabase = createMockSupabase({ data: { id: 1, name: "Chips" }, error: null });
    const result = await callRpc<{ id: number; name: string }>(supabase, "get_product", { p_id: 1 });

    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.data).toEqual({ id: 1, name: "Chips" });
    }
    expect(supabase.rpc).toHaveBeenCalledWith("get_product", { p_id: 1 });
  });

  it("passes undefined params when omitted", async () => {
    const supabase = createMockSupabase({ data: [], error: null });
    await callRpc(supabase, "list_all");
    expect(supabase.rpc).toHaveBeenCalledWith("list_all", undefined);
  });

  it("returns ok: false with normalized error on supabase error", async () => {
    const supabase = createMockSupabase({
      data: null,
      error: { code: "42P01", message: "relation does not exist" },
    });
    const result = await callRpc(supabase, "bad_fn");

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("42P01");
      expect(result.error.message).toBe("relation does not exist");
    }
  });

  it("normalizes missing code/message in supabase error", async () => {
    const supabase = createMockSupabase({
      data: null,
      error: { code: null, message: null },
    });
    const result = await callRpc(supabase, "fn");

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("RPC_ERROR");
      expect(result.error.message).toBe("Unknown error");
    }
  });

  it("detects backend business error in data payload", async () => {
    const supabase = createMockSupabase({
      data: { error: "Product not found" },
      error: null,
    });
    const result = await callRpc(supabase, "get_product", { p_id: 999 });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("BUSINESS_ERROR");
      expect(result.error.message).toBe("Product not found");
    }
  });

  it("does not treat a normal object as a business error", async () => {
    const supabase = createMockSupabase({
      data: { products: [{ id: 1 }], total: 1 },
      error: null,
    });
    const result = await callRpc(supabase, "search");

    expect(result.ok).toBe(true);
  });

  it("handles exception from supabase.rpc (Error instance)", async () => {
    const supabase = createThrowingSupabase(new Error("Network failure"));
    const result = await callRpc(supabase, "fn");

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("EXCEPTION");
      expect(result.error.message).toBe("Network failure");
    }
  });

  it("handles exception from supabase.rpc (non-Error throw)", async () => {
    const supabase = createThrowingSupabase("string error");
    const result = await callRpc(supabase, "fn");

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("EXCEPTION");
      expect(result.error.message).toBe("Unexpected error");
    }
  });

  it("returns ok: true when data is null (valid empty response)", async () => {
    const supabase = createMockSupabase({ data: null, error: null });
    const result = await callRpc(supabase, "fn");

    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.data).toBeNull();
    }
  });

  it("returns ok: true when data is an array", async () => {
    const supabase = createMockSupabase({ data: [1, 2, 3], error: null });
    const result = await callRpc<number[]>(supabase, "fn");

    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.data).toEqual([1, 2, 3]);
    }
  });

  // ─── Development logging branches ──────────────────────────────────────

  it("logs console.error in development on supabase error", async () => {
    vi.stubEnv("NODE_ENV", "development");
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});
    const supabase = createMockSupabase({
      data: null,
      error: { code: "500", message: "Internal" },
    });

    await callRpc(supabase, "failing_fn");

    expect(spy).toHaveBeenCalledWith(
      "[RPC] failing_fn failed:",
      expect.objectContaining({ code: "500" }),
    );
  });

  it("logs console.warn in development on business error", async () => {
    vi.stubEnv("NODE_ENV", "development");
    const spy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const supabase = createMockSupabase({
      data: { error: "Something wrong" },
      error: null,
    });

    await callRpc(supabase, "biz_fn");

    expect(spy).toHaveBeenCalledWith(
      "[RPC] biz_fn returned error:",
      "Something wrong",
    );
  });

  it("logs console.error in development on exception", async () => {
    vi.stubEnv("NODE_ENV", "development");
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});
    const thrown = new Error("Kaboom");
    const supabase = createThrowingSupabase(thrown);

    await callRpc(supabase, "exploding_fn");

    expect(spy).toHaveBeenCalledWith(
      "[RPC] exploding_fn exception:",
      thrown,
    );
  });
});

// ─── isAuthError ────────────────────────────────────────────────────────────

describe("isAuthError", () => {
  it("recognises PGRST301 code", () => {
    expect(isAuthError({ code: "PGRST301", message: "some error" })).toBe(true);
  });

  it("recognises 401 code", () => {
    expect(isAuthError({ code: "401", message: "Unauthorized" })).toBe(true);
  });

  it("recognises 403 code", () => {
    expect(isAuthError({ code: "403", message: "Forbidden" })).toBe(true);
  });

  it("recognises JWT_EXPIRED code", () => {
    expect(isAuthError({ code: "JWT_EXPIRED", message: "" })).toBe(true);
  });

  it("recognises 'JWT expired' message (case-insensitive)", () => {
    expect(isAuthError({ code: "UNKNOWN", message: "jwt expired" })).toBe(true);
  });

  it("recognises 'not authenticated' message", () => {
    expect(
      isAuthError({ code: "UNKNOWN", message: "User is not authenticated" }),
    ).toBe(true);
  });

  it("recognises 'permission denied' message", () => {
    expect(
      isAuthError({ code: "42501", message: "permission denied for table" }),
    ).toBe(true);
  });

  it("recognises 'Invalid JWT' message", () => {
    expect(
      isAuthError({ code: "UNKNOWN", message: "Invalid JWT provided" }),
    ).toBe(true);
  });

  it("returns false for a non-auth error", () => {
    expect(
      isAuthError({ code: "PGRST116", message: "JSON object requested, multiple rows returned" }),
    ).toBe(false);
  });

  it("returns false for a generic business error", () => {
    expect(
      isAuthError({ code: "BUSINESS_ERROR", message: "Product not found" }),
    ).toBe(false);
  });
});

// ─── Rate limit constants (#182) ────────────────────────────────────────────

describe("RATE_LIMIT_CODE", () => {
  it("is 'RATE_LIMITED'", () => {
    expect(RATE_LIMIT_CODE).toBe("RATE_LIMITED");
  });
});

describe("RATE_LIMIT_MESSAGES", () => {
  it("contains known rate limit substrings", () => {
    expect(RATE_LIMIT_MESSAGES).toContain("rate limit");
    expect(RATE_LIMIT_MESSAGES).toContain("too many requests");
    expect(RATE_LIMIT_MESSAGES).toContain("429");
    expect(RATE_LIMIT_MESSAGES.length).toBe(3);
  });
});

// ─── isRateLimitError (#182) ────────────────────────────────────────────────

describe("isRateLimitError", () => {
  it("recognises RATE_LIMITED code", () => {
    expect(isRateLimitError({ code: "RATE_LIMITED", message: "" })).toBe(true);
  });

  it("recognises 429 code", () => {
    expect(isRateLimitError({ code: "429", message: "error" })).toBe(true);
  });

  it("recognises 'rate limit' in message (case-insensitive)", () => {
    expect(
      isRateLimitError({ code: "UNKNOWN", message: "Rate Limit exceeded" }),
    ).toBe(true);
  });

  it("recognises 'too many requests' in message", () => {
    expect(
      isRateLimitError({ code: "ERR", message: "Too Many Requests" }),
    ).toBe(true);
  });

  it("recognises '429' in message", () => {
    expect(
      isRateLimitError({ code: "ERR", message: "HTTP 429 response" }),
    ).toBe(true);
  });

  it("returns false for a non-rate-limit error", () => {
    expect(
      isRateLimitError({ code: "PGRST116", message: "not found" }),
    ).toBe(false);
  });

  it("returns false for a business error", () => {
    expect(
      isRateLimitError({ code: "BUSINESS_ERROR", message: "Product missing" }),
    ).toBe(false);
  });

  it("returns false for an auth error", () => {
    expect(
      isRateLimitError({ code: "401", message: "Unauthorized" }),
    ).toBe(false);
  });
});

// ─── callRpc — rate limit detection (#182) ──────────────────────────────────

describe("callRpc — rate limit errors", () => {
  const mockRpc = vi.fn();
  const supabase = { rpc: mockRpc } as unknown as Parameters<typeof callRpc>[0];

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns RATE_LIMITED code when Supabase returns 429 code", async () => {
    mockRpc.mockResolvedValue({
      data: null,
      error: { code: "429", message: "Too Many Requests" },
    });
    const result = await callRpc(supabase, "test_fn");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("RATE_LIMITED");
    }
  });

  it("returns RATE_LIMITED code when message contains 'too many requests'", async () => {
    mockRpc.mockResolvedValue({
      data: null,
      error: { code: "UNKNOWN", message: "too many requests from client" },
    });
    const result = await callRpc(supabase, "test_fn");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("RATE_LIMITED");
    }
  });

  it("returns RATE_LIMITED code when message contains 'rate limit'", async () => {
    mockRpc.mockResolvedValue({
      data: null,
      error: { code: "ERR", message: "Rate limit exceeded" },
    });
    const result = await callRpc(supabase, "test_fn");
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.code).toBe("RATE_LIMITED");
    }
  });
});
