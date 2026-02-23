import { describe, expect, it, vi, beforeEach } from "vitest";
import { NextRequest } from "next/server";
import { middleware } from "./middleware";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetUser = vi.fn();
vi.mock("@/lib/supabase/middleware", () => ({
  createMiddlewareClient: () => ({
    auth: {
      getUser: () => mockGetUser(),
    },
  }),
}));

const mockLimit = vi.fn();
vi.mock("@/lib/rate-limiter", () => ({
  rateLimitEnabled: true,
  resolveRateLimitTier: (pathname: string) => {
    if (pathname.includes("/login") || pathname.includes("/signup") || pathname.startsWith("/auth/callback"))
      return "auth";
    if (pathname.startsWith("/api/health")) return "health";
    if (pathname.includes("/search")) return "search";
    return "standard";
  },
  getLimiter: () => ({ limit: mockLimit }),
  extractUserIdFromJWT: () => null,
}));

beforeEach(() => {
  vi.clearAllMocks();
  // Default: allow through rate limit
  mockLimit.mockResolvedValue({
    success: true,
    limit: 60,
    remaining: 59,
    reset: Date.now() + 60_000,
  });
});

function createRequest(pathname: string, origin = "http://localhost:3000") {
  return new NextRequest(new URL(pathname, origin));
}

describe("middleware", () => {
  describe("public paths", () => {
    it("allows unauthenticated access to /", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/"));
      // Should NOT redirect (status 200)
      expect(response.status).not.toBe(307);
    });

    it("allows unauthenticated access to /contact", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/contact"));
      expect(response.status).not.toBe(307);
    });

    it("allows unauthenticated access to /privacy", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/privacy"));
      expect(response.status).not.toBe(307);
    });

    it("allows unauthenticated access to /terms", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/terms"));
      expect(response.status).not.toBe(307);
    });

    it("allows unauthenticated access to /auth/login", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/auth/login"));
      expect(response.status).not.toBe(307);
    });

    it("allows unauthenticated access to /auth/signup", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/auth/signup"));
      expect(response.status).not.toBe(307);
    });
  });

  describe("authenticated user on auth pages", () => {
    it("redirects logged-in user from /auth/login to /app/search", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1" } },
      });
      const response = await middleware(createRequest("/auth/login"));
      expect(response.status).toBe(307);
      expect(response.headers.get("location")).toBe(
        "http://localhost:3000/app/search",
      );
    });

    it("redirects logged-in user from /auth/signup to /app/search", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1" } },
      });
      const response = await middleware(createRequest("/auth/signup"));
      expect(response.status).toBe(307);
      expect(response.headers.get("location")).toBe(
        "http://localhost:3000/app/search",
      );
    });

    it("does not redirect logged-in user from /", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1" } },
      });
      const response = await middleware(createRequest("/"));
      expect(response.status).not.toBe(307);
    });
  });

  describe("protected routes", () => {
    it("redirects unauthenticated user from /app/search to login", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/app/search"));
      expect(response.status).toBe(307);
      const location = response.headers.get("location") ?? "";
      expect(location).toContain("/auth/login");
      expect(location).toContain("redirect=%2Fapp%2Fsearch");
    });

    it("redirects unauthenticated user from /app/settings to login", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/app/settings"));
      expect(response.status).toBe(307);
      const location = response.headers.get("location") ?? "";
      expect(location).toContain("/auth/login");
    });

    it("preserves query string in redirect parameter", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(
        createRequest("/app/search?q=test&page=2"),
      );
      expect(response.status).toBe(307);
      const location = response.headers.get("location") ?? "";
      // Redirect param should include both path and query
      expect(location).toContain("redirect=");
      expect(decodeURIComponent(location)).toContain("q=test");
    });

    it("allows authenticated user on protected routes", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1" } },
      });
      const response = await middleware(createRequest("/app/search"));
      expect(response.status).not.toBe(307);
    });
  });

  // ─── Rate limiting (#182) ───────────────────────────────────────────────

  describe("rate limiting — API routes", () => {
    it("returns 200 with rate limit headers when under limit", async () => {
      const response = await middleware(createRequest("/api/health"));
      expect(response.status).toBe(200);
      expect(response.headers.get("X-RateLimit-Limit")).toBe("60");
      expect(response.headers.get("X-RateLimit-Remaining")).toBe("59");
      expect(response.headers.has("X-RateLimit-Reset")).toBe(true);
    });

    it("returns 429 with Retry-After when limit exceeded", async () => {
      mockLimit.mockResolvedValue({
        success: false,
        limit: 60,
        remaining: 0,
        reset: Date.now() + 30_000,
      });

      const response = await middleware(createRequest("/api/health"));
      expect(response.status).toBe(429);

      const body = await response.json();
      expect(body.error).toBe("Too Many Requests");
      expect(body.message).toMatch(/Rate limit exceeded/);
      expect(response.headers.has("Retry-After")).toBe(true);
      expect(response.headers.get("X-RateLimit-Remaining")).toBe("0");
    });

    it("does not call Supabase auth for API routes", async () => {
      await middleware(createRequest("/api/health"));
      expect(mockGetUser).not.toHaveBeenCalled();
    });

    it("preserves x-request-id on 429 response", async () => {
      mockLimit.mockResolvedValue({
        success: false,
        limit: 10,
        remaining: 0,
        reset: Date.now() + 60_000,
      });

      const response = await middleware(createRequest("/api/health"));
      expect(response.status).toBe(429);
      expect(response.headers.get("x-request-id")).toBeTruthy();
    });

    it("passes through with rate limit headers on success", async () => {
      const response = await middleware(createRequest("/api/some-endpoint"));
      expect(response.status).toBe(200);
      expect(response.headers.get("X-RateLimit-Limit")).toBeTruthy();
    });

    it("bypasses rate limit when RATE_LIMIT_BYPASS_TOKEN matches", async () => {
      const originalEnv = process.env.RATE_LIMIT_BYPASS_TOKEN;
      process.env.RATE_LIMIT_BYPASS_TOKEN = "test-bypass-secret";

      // Set limit to fail so we can verify bypass
      mockLimit.mockResolvedValue({
        success: false,
        limit: 60,
        remaining: 0,
        reset: Date.now() + 60_000,
      });

      const req = new NextRequest(
        new URL("/api/health", "http://localhost:3000"),
        {
          headers: { "x-rate-limit-bypass": "test-bypass-secret" },
        },
      );
      const response = await middleware(req);
      // Should NOT be 429 because bypass token is valid
      expect(response.status).toBe(200);

      process.env.RATE_LIMIT_BYPASS_TOKEN = originalEnv;
    });

    it("does not bypass with wrong token", async () => {
      const originalEnv = process.env.RATE_LIMIT_BYPASS_TOKEN;
      process.env.RATE_LIMIT_BYPASS_TOKEN = "correct-secret";

      mockLimit.mockResolvedValue({
        success: false,
        limit: 60,
        remaining: 0,
        reset: Date.now() + 60_000,
      });

      const req = new NextRequest(
        new URL("/api/health", "http://localhost:3000"),
        {
          headers: { "x-rate-limit-bypass": "wrong-secret" },
        },
      );
      const response = await middleware(req);
      expect(response.status).toBe(429);

      process.env.RATE_LIMIT_BYPASS_TOKEN = originalEnv;
    });
  });

  // ─── Admin route protection (#186) ────────────────────────────────────────

  describe("admin route protection", () => {
    it("returns 403 for authenticated non-admin user on /app/admin/submissions", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "user@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).toBe(403);
      const body = await response.json();
      expect(body.error).toBe("Forbidden");
    });

    it("returns 403 for authenticated non-admin user on /app/admin/monitoring", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "user@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/monitoring"),
      );
      expect(response.status).toBe(403);
      const body = await response.json();
      expect(body.error).toBe("Forbidden");
    });

    it("returns 403 when ADMIN_EMAILS is unset (deny-by-default)", async () => {
      const originalEnv = process.env.ADMIN_EMAILS;
      delete process.env.ADMIN_EMAILS;

      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "admin@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).toBe(403);

      process.env.ADMIN_EMAILS = originalEnv;
    });

    it("allows admin user when email matches ADMIN_EMAILS", async () => {
      const originalEnv = process.env.ADMIN_EMAILS;
      process.env.ADMIN_EMAILS = "admin@example.com, admin2@example.com";

      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "admin@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).not.toBe(403);
      expect(response.status).not.toBe(307);

      process.env.ADMIN_EMAILS = originalEnv;
    });

    it("admin email check is case-insensitive", async () => {
      const originalEnv = process.env.ADMIN_EMAILS;
      process.env.ADMIN_EMAILS = "Admin@Example.com";

      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "admin@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/monitoring"),
      );
      expect(response.status).not.toBe(403);

      process.env.ADMIN_EMAILS = originalEnv;
    });

    it("returns 403 when user has no email", async () => {
      const originalEnv = process.env.ADMIN_EMAILS;
      process.env.ADMIN_EMAILS = "admin@example.com";

      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1" } },
      });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).toBe(403);

      process.env.ADMIN_EMAILS = originalEnv;
    });

    it("redirects unauthenticated user from admin route to login", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).toBe(307);
      const location = response.headers.get("location") ?? "";
      expect(location).toContain("/auth/login");
    });

    it("attaches x-request-id to 403 response", async () => {
      mockGetUser.mockResolvedValue({
        data: { user: { id: "u1", email: "user@example.com" } },
      });
      const response = await middleware(
        createRequest("/app/admin/submissions"),
      );
      expect(response.status).toBe(403);
      expect(response.headers.get("x-request-id")).toBeTruthy();
    });
  });

  // ─── Request ID correlation ─────────────────────────────────────────────

  describe("request ID", () => {
    it("generates x-request-id for page requests", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const response = await middleware(createRequest("/"));
      expect(response.headers.get("x-request-id")).toBeTruthy();
    });

    it("generates x-request-id for API requests", async () => {
      const response = await middleware(createRequest("/api/health"));
      expect(response.headers.get("x-request-id")).toBeTruthy();
    });

    it("preserves existing x-request-id", async () => {
      mockGetUser.mockResolvedValue({ data: { user: null } });
      const req = new NextRequest(new URL("/", "http://localhost:3000"), {
        headers: { "x-request-id": "existing-id-123" },
      });
      const response = await middleware(req);
      expect(response.headers.get("x-request-id")).toBe("existing-id-123");
    });
  });
});
