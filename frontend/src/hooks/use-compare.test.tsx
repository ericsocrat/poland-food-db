import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  useCompareProducts,
  useSavedComparisons,
  useSharedComparison,
  useSaveComparison,
  useDeleteComparison,
} from "@/hooks/use-compare";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetProductsForCompare = vi.fn();
const mockGetSavedComparisons = vi.fn();
const mockGetSharedComparison = vi.fn();
const mockSaveComparison = vi.fn();
const mockDeleteComparison = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getProductsForCompare: (...args: unknown[]) =>
    mockGetProductsForCompare(...args),
  getSavedComparisons: (...args: unknown[]) =>
    mockGetSavedComparisons(...args),
  getSharedComparison: (...args: unknown[]) =>
    mockGetSharedComparison(...args),
  saveComparison: (...args: unknown[]) => mockSaveComparison(...args),
  deleteComparison: (...args: unknown[]) => mockDeleteComparison(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useCompareProducts", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches product data when 2-4 IDs provided", async () => {
    const data = { products: [{ id: 1 }, { id: 2 }] };
    mockGetProductsForCompare.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useCompareProducts([1, 2]), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
    // Should call with sorted IDs in queryKey but original IDs in API call
    expect(mockGetProductsForCompare).toHaveBeenCalledWith(
      expect.anything(),
      [1, 2],
    );
  });

  it("does not fetch when fewer than 2 IDs", () => {
    const { result } = renderHook(() => useCompareProducts([1]), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(mockGetProductsForCompare).not.toHaveBeenCalled();
  });

  it("does not fetch when more than 4 IDs", () => {
    const { result } = renderHook(() => useCompareProducts([1, 2, 3, 4, 5]), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(mockGetProductsForCompare).not.toHaveBeenCalled();
  });

  it("throws on error result", async () => {
    mockGetProductsForCompare.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "not found" },
    });

    const { result } = renderHook(() => useCompareProducts([1, 2]), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("not found");
  });
});

describe("useSavedComparisons", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches saved comparisons", async () => {
    const data = { comparisons: [] };
    mockGetSavedComparisons.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useSavedComparisons(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("throws on error result", async () => {
    mockGetSavedComparisons.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "unauthorized" },
    });

    const { result } = renderHook(() => useSavedComparisons(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("unauthorized");
  });
});

describe("useSharedComparison", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches shared comparison by token", async () => {
    const data = { products: [], title: "Chips vs Lays" };
    mockGetSharedComparison.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useSharedComparison("tok-abc"), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("does not fetch when token is empty", () => {
    const { result } = renderHook(() => useSharedComparison(""), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useSaveComparison", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls saveComparison API and returns data", async () => {
    const data = { comparison_id: "c1", share_token: "tok-123" };
    mockSaveComparison.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useSaveComparison(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ productIds: [1, 2], title: "Test" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("throws on error result", async () => {
    mockSaveComparison.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "limit reached" },
    });

    const { result } = renderHook(() => useSaveComparison(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ productIds: [1, 2] });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("limit reached");
  });
});

describe("useDeleteComparison", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls deleteComparison API", async () => {
    mockDeleteComparison.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useDeleteComparison(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("comp-1");

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockDeleteComparison).toHaveBeenCalledWith(
      expect.anything(),
      "comp-1",
    );
  });

  it("throws on error result", async () => {
    mockDeleteComparison.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "not found" },
    });

    const { result } = renderHook(() => useDeleteComparison(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("comp-1");

    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
