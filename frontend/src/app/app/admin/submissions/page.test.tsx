import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import AdminSubmissionsPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockCallRpc = vi.fn();
vi.mock("@/lib/rpc", () => ({
  callRpc: (...args: unknown[]) => mockCallRpc(...args),
}));

const mockShowToast = vi.fn();
vi.mock("@/lib/toast", () => ({
  showToast: (...args: unknown[]) => mockShowToast(...args),
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="spinner">Loading…</div>,
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

const makeSubmission = (overrides: Record<string, unknown> = {}) => ({
  id: "sub-1",
  ean: "5901234123457",
  product_name: "Test Chips",
  brand: "TestBrand",
  category: "chips",
  photo_url: null,
  status: "pending",
  merged_product_id: null,
  notes: null,
  user_id: "user-abcd-1234-5678-xxxx",
  reviewed_at: null,
  created_at: "2025-02-01T10:00:00Z",
  updated_at: "2025-02-01T10:00:00Z",
  ...overrides,
});

const pendingSub = makeSubmission();
const approvedSub = makeSubmission({
  id: "sub-2",
  product_name: "Approved Drink",
  status: "approved",
  reviewed_at: "2025-02-05T14:00:00Z",
  notes: "Looks correct",
});
const rejectedSub = makeSubmission({
  id: "sub-3",
  product_name: "Bad Entry",
  status: "rejected",
  brand: null,
  reviewed_at: "2025-02-03T09:00:00Z",
});

const mockSubmissions = [pendingSub, approvedSub, rejectedSub];

beforeEach(() => {
  vi.clearAllMocks();
  // Default: return pending list for the query
  mockCallRpc.mockImplementation((_client: unknown, fnName: string) => {
    if (fnName === "api_admin_get_submissions") {
      return Promise.resolve({
        ok: true,
        data: {
          submissions: mockSubmissions,
          page: 1,
          pages: 1,
          total: 3,
        },
      });
    }
    if (fnName === "api_admin_review_submission") {
      return Promise.resolve({
        ok: true,
        data: { status: "approved" },
      });
    }
    return Promise.resolve({ ok: true, data: {} });
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AdminSubmissionsPage", () => {
  it("renders page title", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Admin: Submission Review")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Review and approve user-submitted products"),
    ).toBeInTheDocument();
  });

  it("renders all status tabs", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Pending")).toBeInTheDocument();
    expect(screen.getByText("Approved")).toBeInTheDocument();
    expect(screen.getByText("Rejected")).toBeInTheDocument();
    expect(screen.getByText("Merged")).toBeInTheDocument();
    expect(screen.getByText("All")).toBeInTheDocument();
  });

  it("shows loading spinner", () => {
    mockCallRpc.mockReturnValue(new Promise(() => {}));
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error with retry", async () => {
    mockCallRpc.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Failed to load.")).toBeInTheDocument();
    });
    expect(screen.getByText("Retry")).toBeInTheDocument();
  });

  it("shows empty state", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { submissions: [], page: 1, pages: 1, total: 0 },
    });
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("No pending submissions.")).toBeInTheDocument();
    });
  });

  it("renders submission cards with product names", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    expect(screen.getByText("Approved Drink")).toBeInTheDocument();
    expect(screen.getByText("Bad Entry")).toBeInTheDocument();
  });

  it("shows EAN and brand info", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // All 3 subs share the same EAN from makeSubmission
      const eans = screen.getAllByText(/5901234123457/);
      expect(eans.length).toBe(3);
    });
    // 2 subs have TestBrand (pending + approved), rejected has null brand
    const brands = screen.getAllByText(/TestBrand/);
    expect(brands.length).toBe(2);
  });

  it("shows status badges on cards", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("pending")).toBeInTheDocument();
    });
    expect(screen.getByText("approved")).toBeInTheDocument();
    expect(screen.getByText("rejected")).toBeInTheDocument();
  });

  it("shows notes when present", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Looks correct")).toBeInTheDocument();
    });
  });

  it("shows user_id snippet", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // All 3 subs share the same user_id
      const snippets = screen.getAllByText(/user-abc/);
      expect(snippets.length).toBe(3);
    });
  });

  it("shows reviewed_at date for reviewed submissions", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const reviewed = screen.getAllByText(/Reviewed:/);
      expect(reviewed.length).toBe(2); // approved + rejected
    });
  });

  it("shows approve/reject buttons only for pending", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    // Only 1 pending sub → 1 approve + 1 reject button
    expect(screen.getAllByText("Approve")).toHaveLength(1);
    expect(screen.getAllByText("Reject")).toHaveLength(1);
  });

  it("calls review mutation on approve", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Approve")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Approve"));

    await waitFor(() => {
      expect(mockCallRpc).toHaveBeenCalledWith(
        expect.anything(),
        "api_admin_review_submission",
        expect.objectContaining({
          p_submission_id: "sub-1",
          p_action: "approve",
        }),
      );
    });
  });

  it("calls review mutation on reject", async () => {
    mockCallRpc.mockImplementation((_client: unknown, fnName: string) => {
      if (fnName === "api_admin_get_submissions") {
        return Promise.resolve({
          ok: true,
          data: {
            submissions: mockSubmissions,
            page: 1,
            pages: 1,
            total: 3,
          },
        });
      }
      if (fnName === "api_admin_review_submission") {
        return Promise.resolve({
          ok: true,
          data: { status: "rejected" },
        });
      }
      return Promise.resolve({ ok: true, data: {} });
    });

    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Reject")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Reject"));

    await waitFor(() => {
      expect(mockCallRpc).toHaveBeenCalledWith(
        expect.anything(),
        "api_admin_review_submission",
        expect.objectContaining({
          p_submission_id: "sub-1",
          p_action: "reject",
        }),
      );
    });
  });

  it("shows toast on successful review", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Approve")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Approve"));

    await waitFor(() => {
      expect(mockShowToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "success",
          messageKey: "toast.submissionStatus",
          messageParams: { status: "approved" },
        }),
      );
    });
  });

  it("switches tabs when clicked", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByText("All"));

    await waitFor(() => {
      expect(mockCallRpc).toHaveBeenCalledWith(
        expect.anything(),
        "api_admin_get_submissions",
        expect.objectContaining({ p_status: "all" }),
      );
    });
  });

  it("shows pagination for multi-page", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: {
        submissions: mockSubmissions,
        page: 1,
        pages: 3,
        total: 55,
      },
    });
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("← Prev")).toBeInTheDocument();
    });
    expect(screen.getByText("Next →")).toBeInTheDocument();
    expect(screen.getByText(/1 \/ 3/)).toBeInTheDocument();
  });

  it("does not show pagination for single page", async () => {
    render(<AdminSubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    expect(screen.queryByText("← Prev")).not.toBeInTheDocument();
  });
});
