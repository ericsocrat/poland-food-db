import { useState } from "react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { RouteGuard, usePreferences } from "./RouteGuard";
import { renderHook } from "@testing-library/react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

const mockGetUserPreferences = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetUserPreferences(...args),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => "mock-supabase",
}));

vi.mock("@/lib/rpc", () => ({
  isAuthError: (e: { code: string }) =>
    ["401", "403", "PGRST301"].includes(e.code),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn() },
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

beforeEach(() => {
  vi.clearAllMocks();
});

// ─── RouteGuard ─────────────────────────────────────────────────────────────

describe("RouteGuard", () => {
  it("shows loading spinner while fetching", () => {
    // never resolve
    mockGetUserPreferences.mockReturnValue(new Promise(() => {}));
    render(
      <RouteGuard>
        <p>Protected</p>
      </RouteGuard>,
      { wrapper: createWrapper() },
    );
    expect(screen.queryByText("Protected")).not.toBeInTheDocument();
  });

  it("renders children when onboarding is complete", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { onboarding_complete: true, country_code: "PL" },
    });
    render(
      <RouteGuard>
        <p>Protected</p>
      </RouteGuard>,
      { wrapper: createWrapper() },
    );
    expect(await screen.findByText("Protected")).toBeInTheDocument();
  });

  it("redirects to onboarding when incomplete", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { onboarding_complete: false, country_code: null },
    });
    render(
      <RouteGuard>
        <p>Protected</p>
      </RouteGuard>,
      { wrapper: createWrapper() },
    );
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/onboarding/region");
    });
    expect(screen.queryByText("Protected")).not.toBeInTheDocument();
  });

  it("redirects to login on auth error", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: false,
      error: { code: "401", message: "JWT expired" },
    });
    render(
      <RouteGuard>
        <p>Protected</p>
      </RouteGuard>,
      { wrapper: createWrapper() },
    );
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith(
        expect.stringContaining("/auth/login?reason=expired"),
      );
    });
  });

  it("shows toast on non-auth error", async () => {
    const { toast } = await import("sonner");
    mockGetUserPreferences.mockResolvedValue({
      ok: false,
      error: { code: "500", message: "Server error" },
    });
    render(
      <RouteGuard>
        <p>Protected</p>
      </RouteGuard>,
      { wrapper: createWrapper() },
    );
    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Failed to load preferences.");
    });
  });
});

// ─── usePreferences ─────────────────────────────────────────────────────────

describe("usePreferences", () => {
  it("returns undefined while loading", () => {
    mockGetUserPreferences.mockReturnValue(new Promise(() => {}));
    const { result } = renderHook(() => usePreferences(), {
      wrapper: createWrapper(),
    });
    expect(result.current).toBeUndefined();
  });

  it("returns preferences data on success", async () => {
    const prefs = { onboarding_complete: true, country_code: "DE" };
    mockGetUserPreferences.mockResolvedValue({ ok: true, data: prefs });
    const { result } = renderHook(() => usePreferences(), {
      wrapper: createWrapper(),
    });
    await waitFor(() => {
      expect(result.current).toEqual(prefs);
    });
  });
});
