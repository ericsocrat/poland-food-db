import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

// Override the global auto-mock so we test the real hook
vi.unmock("@/hooks/use-analytics");

const mockTrackEvent = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  trackEvent: (...args: unknown[]) => mockTrackEvent(...args),
}));

import { useAnalytics } from "@/hooks/use-analytics";

// ─── Helpers ────────────────────────────────────────────────────────────────

function mockSessionStorage() {
  const store: Record<string, string> = {};
  return {
    getItem: vi.fn((key: string) => store[key] ?? null),
    setItem: vi.fn((key: string, value: string) => {
      store[key] = value;
    }),
    removeItem: vi.fn((key: string) => {
      delete store[key];
    }),
    clear: vi.fn(() => {
      Object.keys(store).forEach((k) => delete store[k]);
    }),
    get length() {
      return Object.keys(store).length;
    },
    key: vi.fn(() => null),
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useAnalytics", () => {
  let sessionStorageMock: ReturnType<typeof mockSessionStorage>;

  beforeEach(() => {
    vi.clearAllMocks();
    mockTrackEvent.mockResolvedValue({ ok: true, data: { api_version: "1.0.0", tracked: true } });
    sessionStorageMock = mockSessionStorage();
    Object.defineProperty(window, "sessionStorage", {
      value: sessionStorageMock,
      writable: true,
    });
  });

  afterEach(() => {
    sessionStorageMock.clear();
  });

  it("returns a track function", () => {
    const { result } = renderHook(() => useAnalytics());
    expect(result.current.track).toBeTypeOf("function");
  });

  it("calls trackEvent with correct parameters", async () => {
    const { result } = renderHook(() => useAnalytics());

    // Wait for useEffect to run (session init)
    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("search_performed", { query: "test" });
    });

    expect(mockTrackEvent).toHaveBeenCalledTimes(1);
    const [, params] = mockTrackEvent.mock.calls[0];
    expect(params.eventName).toBe("search_performed");
    expect(params.eventData).toEqual({ query: "test" });
    expect(params.sessionId).toBeTruthy();
    expect(params.deviceType).toBeTruthy();
  });

  it("fires and forgets — does not throw on API failure", async () => {
    mockTrackEvent.mockRejectedValue(new Error("network error"));
    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    // Should not throw
    act(() => {
      result.current.track("product_viewed", { product_id: 1 });
    });

    // Give the promise time to reject (fire-and-forget)
    await act(async () => {
      await new Promise((r) => setTimeout(r, 50));
    });

    expect(mockTrackEvent).toHaveBeenCalledTimes(1);
  });

  it("tracks without eventData", async () => {
    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("dashboard_viewed");
    });

    expect(mockTrackEvent).toHaveBeenCalledTimes(1);
    const [, params] = mockTrackEvent.mock.calls[0];
    expect(params.eventName).toBe("dashboard_viewed");
    expect(params.eventData).toBeUndefined();
  });

  it("persists session ID across calls", async () => {
    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("search_performed");
    });
    act(() => {
      result.current.track("filter_applied");
    });

    expect(mockTrackEvent).toHaveBeenCalledTimes(2);
    const session1 = mockTrackEvent.mock.calls[0][1].sessionId;
    const session2 = mockTrackEvent.mock.calls[1][1].sessionId;
    expect(session1).toBe(session2);
    expect(session1).toBeTruthy();
  });

  it("reuses session ID from sessionStorage", async () => {
    sessionStorageMock.setItem("analytics_session_id", "existing-session-123");

    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("product_viewed");
    });

    expect(mockTrackEvent.mock.calls[0][1].sessionId).toBe("existing-session-123");
  });

  it("detects desktop device type for wide viewport", async () => {
    Object.defineProperty(window, "innerWidth", { value: 1440, writable: true });

    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("dashboard_viewed");
    });

    expect(mockTrackEvent.mock.calls[0][1].deviceType).toBe("desktop");
  });

  it("detects mobile device type for narrow viewport", async () => {
    Object.defineProperty(window, "innerWidth", { value: 375, writable: true });

    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("scanner_used");
    });

    expect(mockTrackEvent.mock.calls[0][1].deviceType).toBe("mobile");
  });

  it("detects tablet device type for medium viewport", async () => {
    Object.defineProperty(window, "innerWidth", { value: 800, writable: true });

    const { result } = renderHook(() => useAnalytics());

    await act(async () => {
      await new Promise((r) => setTimeout(r, 0));
    });

    act(() => {
      result.current.track("category_viewed");
    });

    expect(mockTrackEvent.mock.calls[0][1].deviceType).toBe("tablet");
  });

  it("supports all 18 event names without type errors", () => {
    const { result } = renderHook(() => useAnalytics());
    const events = [
      "search_performed", "filter_applied", "search_saved",
      "compare_opened", "list_created", "list_shared",
      "favorites_added", "list_item_added", "avoid_added",
      "scanner_used", "product_not_found", "submission_created",
      "product_viewed", "dashboard_viewed", "share_link_opened",
      "category_viewed", "preferences_updated", "onboarding_completed",
    ] as const;

    for (const name of events) {
      act(() => {
        result.current.track(name);
      });
    }

    expect(mockTrackEvent).toHaveBeenCalledTimes(18);
  });
});
