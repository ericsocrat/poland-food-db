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

beforeEach(() => {
  vi.clearAllMocks();
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
});
