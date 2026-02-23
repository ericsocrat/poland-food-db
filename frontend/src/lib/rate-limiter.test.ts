import { describe, it, expect } from "vitest";
import {
  resolveRateLimitTier,
  extractUserIdFromJWT,
  getLimiter,
  standardLimiter,
  authLimiter,
  searchLimiter,
  healthLimiter,
  authenticatedLimiter,
  rateLimitEnabled,
} from "./rate-limiter";

// ─── rateLimitEnabled ───────────────────────────────────────────────────────

describe("rateLimitEnabled", () => {
  it("is false when no Redis env vars are set", () => {
    // CI/dev environment: no UPSTASH_REDIS_REST_URL or TOKEN set
    expect(rateLimitEnabled).toBe(false);
  });
});

// ─── Limiter instances ──────────────────────────────────────────────────────

describe("limiter instances (no Redis)", () => {
  it("standardLimiter is null without Redis", () => {
    expect(standardLimiter).toBeNull();
  });

  it("authLimiter is null without Redis", () => {
    expect(authLimiter).toBeNull();
  });

  it("searchLimiter is null without Redis", () => {
    expect(searchLimiter).toBeNull();
  });

  it("healthLimiter is null without Redis", () => {
    expect(healthLimiter).toBeNull();
  });

  it("authenticatedLimiter is null without Redis", () => {
    expect(authenticatedLimiter).toBeNull();
  });
});

// ─── resolveRateLimitTier ───────────────────────────────────────────────────

describe("resolveRateLimitTier", () => {
  it("maps /auth/callback to auth tier", () => {
    expect(resolveRateLimitTier("/auth/callback")).toBe("auth");
  });

  it("maps /auth/callback?code=xyz to auth tier", () => {
    expect(resolveRateLimitTier("/auth/callback")).toBe("auth");
  });

  it("maps /login to auth tier", () => {
    expect(resolveRateLimitTier("/login")).toBe("auth");
  });

  it("maps /signup to auth tier", () => {
    expect(resolveRateLimitTier("/signup")).toBe("auth");
  });

  it("maps /auth/login to auth tier (startsWith /auth/ + contains /login)", () => {
    expect(resolveRateLimitTier("/auth/login")).toBe("auth");
  });

  it("maps /api/health to health tier", () => {
    expect(resolveRateLimitTier("/api/health")).toBe("health");
  });

  it("maps /api/health/detailed to health tier (startsWith)", () => {
    expect(resolveRateLimitTier("/api/health/detailed")).toBe("health");
  });

  it("maps /search to search tier", () => {
    expect(resolveRateLimitTier("/search")).toBe("search");
  });

  it("maps /app/search to search tier", () => {
    expect(resolveRateLimitTier("/app/search")).toBe("search");
  });

  it("maps /rpc/search_products to search tier", () => {
    expect(resolveRateLimitTier("/rpc/search_products")).toBe("search");
  });

  it("maps /api/some-endpoint to standard tier", () => {
    expect(resolveRateLimitTier("/api/some-endpoint")).toBe("standard");
  });

  it("maps / to standard tier", () => {
    expect(resolveRateLimitTier("/")).toBe("standard");
  });

  it("maps /app/product/123 to standard tier", () => {
    expect(resolveRateLimitTier("/app/product/123")).toBe("standard");
  });
});

// ─── getLimiter ─────────────────────────────────────────────────────────────

describe("getLimiter", () => {
  it("returns standardLimiter for 'standard'", () => {
    expect(getLimiter("standard")).toBe(standardLimiter);
  });

  it("returns authLimiter for 'auth'", () => {
    expect(getLimiter("auth")).toBe(authLimiter);
  });

  it("returns searchLimiter for 'search'", () => {
    expect(getLimiter("search")).toBe(searchLimiter);
  });

  it("returns healthLimiter for 'health'", () => {
    expect(getLimiter("health")).toBe(healthLimiter);
  });

  it("returns authenticatedLimiter for 'authenticated'", () => {
    expect(getLimiter("authenticated")).toBe(authenticatedLimiter);
  });

  it("returns null for all tiers when Redis is not configured", () => {
    // Without Redis, all limiters are null
    expect(getLimiter("standard")).toBeNull();
    expect(getLimiter("auth")).toBeNull();
    expect(getLimiter("search")).toBeNull();
    expect(getLimiter("health")).toBeNull();
    expect(getLimiter("authenticated")).toBeNull();
  });
});

// ─── extractUserIdFromJWT ───────────────────────────────────────────────────

describe("extractUserIdFromJWT", () => {
  /** Build a minimal JWT with given payload. No signature needed for extraction. */
  function buildJWT(payload: Record<string, unknown>): string {
    const header = btoa(JSON.stringify({ alg: "HS256", typ: "JWT" }));
    const body = btoa(JSON.stringify(payload));
    return `${header}.${body}.fakesig`;
  }

  it("returns sub claim from a valid Bearer token", () => {
    const jwt = buildJWT({ sub: "user-abc-123", role: "authenticated" });
    expect(extractUserIdFromJWT(`Bearer ${jwt}`)).toBe("user-abc-123");
  });

  it("returns null for missing Authorization header", () => {
    expect(extractUserIdFromJWT(null)).toBeNull();
  });

  it("returns null for empty string", () => {
    expect(extractUserIdFromJWT("")).toBeNull();
  });

  it("returns null without Bearer prefix", () => {
    const jwt = buildJWT({ sub: "user-1" });
    expect(extractUserIdFromJWT(jwt)).toBeNull();
  });

  it("returns null for a JWT with non-string sub", () => {
    const jwt = buildJWT({ sub: 42 });
    expect(extractUserIdFromJWT(`Bearer ${jwt}`)).toBeNull();
  });

  it("returns null for a JWT without sub claim", () => {
    const jwt = buildJWT({ role: "anon" });
    expect(extractUserIdFromJWT(`Bearer ${jwt}`)).toBeNull();
  });

  it("returns null for malformed JWT (too few parts)", () => {
    expect(extractUserIdFromJWT("Bearer abc.def")).toBeNull();
  });

  it("returns null for invalid base64 payload", () => {
    expect(extractUserIdFromJWT("Bearer aaa.!!!.ccc")).toBeNull();
  });
});
