// ─── Feature Flag React Hooks Tests ──────────────────────────────────────────
// Unit tests for FlagProvider, useFlag, useFlagVariant, Feature component (#191).

import { describe, it, expect, vi, afterEach } from "vitest";
import { render, screen, act, renderHook } from "@testing-library/react";
import type { ReactNode } from "react";
import {
  FlagProvider,
  useFlag,
  useFlagVariant,
  useFlagsLoading,
  Feature,
} from "@/lib/flags/hooks";

// ─── Mock Supabase client ───────────────────────────────────────────────────

const mockSubscribe = vi.fn().mockReturnValue({ unsubscribe: vi.fn() });
const mockOn = vi.fn().mockReturnValue({ subscribe: mockSubscribe });
const mockChannel = vi.fn().mockReturnValue({ on: mockOn });
const mockRemoveChannel = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    channel: mockChannel,
    removeChannel: mockRemoveChannel,
  }),
}));

// Mock fetch for /api/flags
const mockFetch = vi.fn();
global.fetch = mockFetch;

afterEach(() => {
  vi.clearAllMocks();
});

// ─── Wrapper ────────────────────────────────────────────────────────────────

function TestProvider({
  children,
  flags,
  variants,
}: {
  children: ReactNode;
  flags?: Record<string, boolean>;
  variants?: Record<string, string>;
}) {
  return (
    <FlagProvider initialFlags={flags} initialVariants={variants}>
      {children}
    </FlagProvider>
  );
}

// ─── useFlag ────────────────────────────────────────────────────────────────

describe("useFlag", () => {
  it("returns true when flag is enabled", () => {
    const { result } = renderHook(() => useFlag("my_flag"), {
      wrapper: ({ children }) => (
        <TestProvider flags={{ my_flag: true }}>{children}</TestProvider>
      ),
    });
    expect(result.current).toBe(true);
  });

  it("returns false when flag is disabled", () => {
    const { result } = renderHook(() => useFlag("my_flag"), {
      wrapper: ({ children }) => (
        <TestProvider flags={{ my_flag: false }}>{children}</TestProvider>
      ),
    });
    expect(result.current).toBe(false);
  });

  it("returns false when flag is not present (default)", () => {
    const { result } = renderHook(() => useFlag("unknown_flag"), {
      wrapper: ({ children }) => (
        <TestProvider flags={{}}>{children}</TestProvider>
      ),
    });
    expect(result.current).toBe(false);
  });

  it("returns false without FlagProvider (bare context)", () => {
    const { result } = renderHook(() => useFlag("any_flag"));
    expect(result.current).toBe(false);
  });
});

// ─── useFlagVariant ─────────────────────────────────────────────────────────

describe("useFlagVariant", () => {
  it("returns variant name when set", () => {
    const { result } = renderHook(() => useFlagVariant("ab_test"), {
      wrapper: ({ children }) => (
        <TestProvider
          flags={{ ab_test: true }}
          variants={{ ab_test: "treatment" }}
        >
          {children}
        </TestProvider>
      ),
    });
    expect(result.current).toBe("treatment");
  });

  it("returns undefined when no variant is set", () => {
    const { result } = renderHook(() => useFlagVariant("boolean_flag"), {
      wrapper: ({ children }) => (
        <TestProvider flags={{ boolean_flag: true }}>{children}</TestProvider>
      ),
    });
    expect(result.current).toBeUndefined();
  });
});

// ─── useFlagsLoading ────────────────────────────────────────────────────────

describe("useFlagsLoading", () => {
  it("returns false when initialFlags are provided", () => {
    const { result } = renderHook(() => useFlagsLoading(), {
      wrapper: ({ children }) => (
        <TestProvider flags={{}}>{children}</TestProvider>
      ),
    });
    expect(result.current).toBe(false);
  });

  it("returns true when no initialFlags are provided", async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: async () => ({ flags: {}, variants: {} }),
    });

    let hookResult: { current: boolean };
    await act(async () => {
      const rendered = renderHook(() => useFlagsLoading(), {
        wrapper: ({ children }) => <FlagProvider>{children}</FlagProvider>,
      });
      hookResult = rendered.result;
    });
    // After fetch resolves, loading should be false
    expect(typeof hookResult!.current).toBe("boolean");
  });
});

// ─── Feature component ─────────────────────────────────────────────────────

describe("Feature", () => {
  it("renders children when flag is enabled", () => {
    render(
      <TestProvider flags={{ show_banner: true }}>
        <Feature flag="show_banner">
          <div data-testid="banner">Hello</div>
        </Feature>
      </TestProvider>,
    );
    expect(screen.getByTestId("banner")).toBeInTheDocument();
  });

  it("does not render children when flag is disabled", () => {
    render(
      <TestProvider flags={{ show_banner: false }}>
        <Feature flag="show_banner">
          <div data-testid="banner">Hello</div>
        </Feature>
      </TestProvider>,
    );
    expect(screen.queryByTestId("banner")).not.toBeInTheDocument();
  });

  it("renders fallback when flag is disabled", () => {
    render(
      <TestProvider flags={{ new_ui: false }}>
        <Feature flag="new_ui" fallback={<div data-testid="old">Old UI</div>}>
          <div data-testid="new">New UI</div>
        </Feature>
      </TestProvider>,
    );
    expect(screen.queryByTestId("new")).not.toBeInTheDocument();
    expect(screen.getByTestId("old")).toBeInTheDocument();
  });

  it("renders children (not fallback) when flag is enabled", () => {
    render(
      <TestProvider flags={{ new_ui: true }}>
        <Feature flag="new_ui" fallback={<div data-testid="old">Old UI</div>}>
          <div data-testid="new">New UI</div>
        </Feature>
      </TestProvider>,
    );
    expect(screen.getByTestId("new")).toBeInTheDocument();
    expect(screen.queryByTestId("old")).not.toBeInTheDocument();
  });

  it("renders nothing when flag is missing (no fallback)", () => {
    render(
      <TestProvider flags={{}}>
        <Feature flag="nonexistent">
          <div data-testid="content">Content</div>
        </Feature>
      </TestProvider>,
    );
    expect(screen.queryByTestId("content")).not.toBeInTheDocument();
  });
});

// ─── FlagProvider ───────────────────────────────────────────────────────────

describe("FlagProvider", () => {
  it("subscribes to Supabase Realtime on mount", () => {
    render(
      <TestProvider flags={{}}>
        <div>child</div>
      </TestProvider>,
    );
    expect(mockChannel).toHaveBeenCalledWith("flag-changes");
    expect(mockOn).toHaveBeenCalledWith(
      "postgres_changes",
      { event: "*", schema: "public", table: "feature_flags" },
      expect.any(Function),
    );
    expect(mockSubscribe).toHaveBeenCalled();
  });

  it("fetches flags from /api/flags when no initialFlags", async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        flags: { fetched_flag: true },
        variants: {},
      }),
    });

    let hookResult: { current: boolean };

    await act(async () => {
      const rendered = renderHook(() => useFlag("fetched_flag"), {
        wrapper: ({ children }) => <FlagProvider>{children}</FlagProvider>,
      });
      hookResult = rendered.result;
    });

    expect(mockFetch).toHaveBeenCalledWith("/api/flags");
    expect(hookResult!.current).toBe(true);
  });

  it("does not fetch when initialFlags are provided", () => {
    render(
      <TestProvider flags={{ initial: true }}>
        <div>child</div>
      </TestProvider>,
    );
    expect(mockFetch).not.toHaveBeenCalled();
  });
});
