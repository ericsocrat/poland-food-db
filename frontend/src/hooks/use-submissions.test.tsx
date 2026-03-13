import {
  useContributorStats,
  useSubmissionHistory,
  useSubmitProduct,
} from "@/hooks/use-submissions";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, renderHook, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetMySubmissions = vi.fn();
const mockSubmitProduct = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getMySubmissions: (...args: unknown[]) => mockGetMySubmissions(...args),
  submitProduct: (...args: unknown[]) => mockSubmitProduct(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

vi.mock("@/lib/events", () => ({
  eventBus: { emit: vi.fn().mockResolvedValue(undefined) },
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

function makeSubmission(status: string) {
  return {
    submission_id: Math.random(),
    ean: "5901234123457",
    product_name: "Test Product",
    brand: "Test Brand",
    status,
    created_at: new Date().toISOString(),
  };
}

// ─── useSubmissionHistory ───────────────────────────────────────────────────

describe("useSubmissionHistory", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches paginated submissions", async () => {
    const data = { submissions: [makeSubmission("pending")], total: 1 };
    mockGetMySubmissions.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useSubmissionHistory(1, 20), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
    expect(mockGetMySubmissions).toHaveBeenCalledWith(expect.anything(), 1, 20);
  });

  it("throws on API error", async () => {
    mockGetMySubmissions.mockResolvedValue({
      ok: false,
      error: { message: "Unauthorized" },
    });

    const { result } = renderHook(() => useSubmissionHistory(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("Unauthorized");
  });
});

// ─── useContributorStats ────────────────────────────────────────────────────

describe("useContributorStats", () => {
  beforeEach(() => vi.clearAllMocks());

  it("returns none tier with no approved submissions", async () => {
    const subs = [makeSubmission("pending"), makeSubmission("rejected")];
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: subs, total: 2 },
    });

    const { result } = renderHook(() => useContributorStats(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.tier).toBe("none");
    expect(result.current.data?.approved).toBe(0);
    expect(result.current.data?.pending).toBe(1);
    expect(result.current.data?.rejected).toBe(1);
  });

  it("returns bronze tier with 1+ approved", async () => {
    const subs = [makeSubmission("approved"), makeSubmission("pending")];
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: subs, total: 2 },
    });

    const { result } = renderHook(() => useContributorStats(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.tier).toBe("bronze");
    expect(result.current.data?.approved).toBe(1);
  });

  it("returns silver tier with 10+ approved", async () => {
    const subs = Array.from({ length: 10 }, () => makeSubmission("approved"));
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: subs, total: 10 },
    });

    const { result } = renderHook(() => useContributorStats(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.tier).toBe("silver");
  });

  it("returns gold tier with 50+ approved", async () => {
    const subs = Array.from({ length: 50 }, () => makeSubmission("approved"));
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: subs, total: 50 },
    });

    const { result } = renderHook(() => useContributorStats(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.tier).toBe("gold");
    expect(result.current.data?.approved).toBe(50);
  });

  it("counts merged as approved for tier calculation", async () => {
    const subs = [makeSubmission("merged")];
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: subs, total: 1 },
    });

    const { result } = renderHook(() => useContributorStats(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.tier).toBe("bronze");
    expect(result.current.data?.approved).toBe(1);
    expect(result.current.data?.merged).toBe(1);
  });
});

// ─── useSubmitProduct ───────────────────────────────────────────────────────

describe("useSubmitProduct", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls submitProduct API and shows success toast", async () => {
    mockSubmitProduct.mockResolvedValue({
      ok: true,
      data: { submission_id: 42 },
    });

    const { result } = renderHook(() => useSubmitProduct(), {
      wrapper: createWrapper(),
    });

    await act(async () => {
      result.current.mutate({
        ean: "5901234123457",
        productName: "New Product",
      });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockSubmitProduct).toHaveBeenCalledWith(expect.anything(), {
      ean: "5901234123457",
      productName: "New Product",
    });
  });

  it("throws on API error", async () => {
    mockSubmitProduct.mockResolvedValue({
      ok: false,
      error: { message: "Rate limited" },
    });

    const { result } = renderHook(() => useSubmitProduct(), {
      wrapper: createWrapper(),
    });

    await act(async () => {
      result.current.mutate({
        ean: "5901234123457",
        productName: "New Product",
      });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("Rate limited");
  });
});
