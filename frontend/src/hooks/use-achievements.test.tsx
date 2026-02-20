import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

// ─── Hoisted mocks ─────────────────────────────────────────────────────────

const mockGetAchievements = vi.fn();
const mockIncrementProgress = vi.fn();
const mockShowToast = vi.fn();
const mockInvalidateQueries = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getAchievements: (...args: unknown[]) => mockGetAchievements(...args),
  incrementAchievementProgress: (...args: unknown[]) =>
    mockIncrementProgress(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: (...args: unknown[]) => mockShowToast(...args),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

import { useAchievements, useAchievementProgress } from "./use-achievements";

// ─── Wrapper ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  // Spy on invalidateQueries
  vi.spyOn(queryClient, "invalidateQueries").mockImplementation(
    mockInvalidateQueries,
  );
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useAchievements", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("fetches achievements and returns data", async () => {
    const mockData = {
      achievements: [
        {
          id: "a1",
          slug: "first_scan",
          category: "exploration",
          title_key: "achievement.first_scan.title",
          desc_key: "achievement.first_scan.desc",
          icon: "🔍",
          threshold: 1,
          country: null,
          sort_order: 10,
          progress: 1,
          unlocked_at: "2026-02-20T12:00:00Z",
        },
      ],
      total: 18,
      unlocked: 1,
    };

    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    const { result } = renderHook(() => useAchievements(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.total).toBe(18);
    expect(result.current.data?.unlocked).toBe(1);
    expect(result.current.data?.achievements).toHaveLength(1);
    expect(mockGetAchievements).toHaveBeenCalledOnce();
  });

  it("throws on API error", async () => {
    mockGetAchievements.mockResolvedValue({
      ok: false,
      error: { message: "Network error" },
    });

    const { result } = renderHook(() => useAchievements(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(result.current.error?.message).toBe("Network error");
  });
});

describe("useAchievementProgress", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls incrementAchievementProgress with slug", async () => {
    const mockResult = {
      slug: "first_scan",
      progress: 1,
      threshold: 1,
      unlocked: true,
      newly_unlocked: true,
    };

    mockIncrementProgress.mockResolvedValue({ ok: true, data: mockResult });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "first_scan" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockIncrementProgress).toHaveBeenCalledWith(
      {},
      "first_scan",
      undefined,
    );
  });

  it("shows success toast when newly unlocked", async () => {
    const mockResult = {
      slug: "first_scan",
      progress: 1,
      threshold: 1,
      unlocked: true,
      newly_unlocked: true,
    };

    mockIncrementProgress.mockResolvedValue({ ok: true, data: mockResult });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "first_scan" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockShowToast).toHaveBeenCalledWith({
      type: "success",
      messageKey: "achievements.unlocked",
    });
  });

  it("does not show toast when not newly unlocked", async () => {
    const mockResult = {
      slug: "first_scan",
      progress: 5,
      threshold: 10,
      unlocked: false,
      newly_unlocked: false,
    };

    mockIncrementProgress.mockResolvedValue({ ok: true, data: mockResult });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "first_scan" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockShowToast).not.toHaveBeenCalled();
  });

  it("invalidates achievements cache on success", async () => {
    mockIncrementProgress.mockResolvedValue({
      ok: true,
      data: {
        slug: "first_scan",
        progress: 1,
        threshold: 1,
        unlocked: false,
        newly_unlocked: false,
      },
    });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "first_scan" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockInvalidateQueries).toHaveBeenCalledWith({
      queryKey: ["achievements"],
    });
  });

  it("shows error toast on failure", async () => {
    mockIncrementProgress.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "first_scan" });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(mockShowToast).toHaveBeenCalledWith({
      type: "error",
      message: "achievements.progressError",
    });
  });

  it("passes custom increment value", async () => {
    mockIncrementProgress.mockResolvedValue({
      ok: true,
      data: {
        slug: "scan_10",
        progress: 5,
        threshold: 10,
        unlocked: false,
        newly_unlocked: false,
      },
    });

    const { result } = renderHook(() => useAchievementProgress(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ slug: "scan_10", increment: 5 });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockIncrementProgress).toHaveBeenCalledWith({}, "scan_10", 5);
  });
});
