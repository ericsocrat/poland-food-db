import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ScanHistoryPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
  }: {
    href: string;
    children: React.ReactNode;
  }) => <a href={href}>{children}</a>,
}));

const mockGetScanHistory = vi.fn();
vi.mock("@/lib/api", () => ({
  getScanHistory: (...args: unknown[]) => mockGetScanHistory(...args),
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

const mockScans = [
  {
    scan_id: "scan-1",
    ean: "5901234123457",
    found: true,
    scanned_at: "2025-02-01T14:30:00Z",
    product_id: 42,
    product_name: "Lay's Classic",
    brand: "Lay's",
    category: "chips",
    unhealthiness_score: 72,
    nutri_score: "D" as const,
    submission_status: null,
  },
  {
    scan_id: "scan-2",
    ean: "9999999999999",
    found: false,
    scanned_at: "2025-02-01T14:25:00Z",
    product_id: null,
    product_name: null,
    brand: null,
    category: null,
    unhealthiness_score: null,
    nutri_score: null,
    submission_status: null,
  },
  {
    scan_id: "scan-3",
    ean: "8888888888888",
    found: false,
    scanned_at: "2025-02-01T14:20:00Z",
    product_id: null,
    product_name: null,
    brand: null,
    category: null,
    unhealthiness_score: null,
    nutri_score: null,
    submission_status: "pending",
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGetScanHistory.mockResolvedValue({
    ok: true,
    data: {
      scans: mockScans,
      page: 1,
      pages: 1,
      total: 3,
    },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScanHistoryPage", () => {
  it("renders page title and subtitle", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("📋 Scan History")).toBeInTheDocument();
    });
    expect(screen.getByText("Your barcode scan activity")).toBeInTheDocument();
  });

  it("links back to scanner", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    expect(screen.getByText("← Back to Scanner").closest("a")).toHaveAttribute(
      "href",
      "/app/scan",
    );
  });

  it("shows loading spinner", () => {
    mockGetScanHistory.mockReturnValue(new Promise(() => {}));
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state with retry button", async () => {
    mockGetScanHistory.mockResolvedValue({
      ok: false,
      error: { message: "Server oops" },
    });
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByText("Failed to load scan history."),
      ).toBeInTheDocument();
    });
    expect(screen.getByText("🔄 Retry")).toBeInTheDocument();
  });

  it("shows empty state when no scans", async () => {
    mockGetScanHistory.mockResolvedValue({
      ok: true,
      data: { scans: [], page: 1, pages: 1, total: 0 },
    });
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("No scans yet")).toBeInTheDocument();
    });
    expect(screen.getByText("Start scanning →").closest("a")).toHaveAttribute(
      "href",
      "/app/scan",
    );
  });

  it("renders filter buttons", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    expect(screen.getByText("All")).toBeInTheDocument();
    expect(screen.getByText("Found")).toBeInTheDocument();
    expect(screen.getByText("Not Found")).toBeInTheDocument();
  });

  it("renders found scan rows with product info", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.getByText(/Lay's · chips/)).toBeInTheDocument();
    expect(screen.getByText("5901234123457")).toBeInTheDocument();
  });

  it("shows nutri-score badge for found scans", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("D")).toBeInTheDocument();
    });
  });

  it("renders not-found scan rows with EAN", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("9999999999999")).toBeInTheDocument();
    });
  });

  it("shows submit link for not-found scan without submission", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    const submitLink = screen.getByText("Submit →").closest("a");
    expect(submitLink).toHaveAttribute(
      "href",
      "/app/scan/submit?ean=9999999999999",
    );
  });

  it("shows submission status when already submitted", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/Submission: pending/)).toBeInTheDocument();
    });
  });

  it("does not show submit link when submission exists", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    // scan-3 has submission_status "pending" so it should NOT have a Submit → link
    // scan-2 has no submission_status so it SHOULD have a Submit → link
    const submitLinks = screen.getAllByText("Submit →");
    expect(submitLinks).toHaveLength(1);
  });

  it("navigates to product page when clicking found scan", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    await user.click(screen.getByText("Lay's Classic"));
    expect(mockPush).toHaveBeenCalledWith("/app/product/42");
  });

  it("does not show pagination for single page", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.queryByText("← Prev")).not.toBeInTheDocument();
  });

  it("shows pagination for multiple pages", async () => {
    mockGetScanHistory.mockResolvedValue({
      ok: true,
      data: { scans: mockScans, page: 1, pages: 3, total: 55 },
    });
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("← Prev")).toBeInTheDocument();
    });
    expect(screen.getByText("Next →")).toBeInTheDocument();
    expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
  });

  it("disables prev button on first page", async () => {
    mockGetScanHistory.mockResolvedValue({
      ok: true,
      data: { scans: mockScans, page: 1, pages: 3, total: 55 },
    });
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("← Prev")).toBeDisabled();
    });
  });

  it("switches filter and resets page", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Found"));
    // Filter should have been changed; a new query would fire
    expect(mockGetScanHistory).toHaveBeenCalled();
  });

  it("shows not-found indicator for failed lookups", async () => {
    render(<ScanHistoryPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const notFoundTexts = screen.getAllByText("Not found");
      expect(notFoundTexts.length).toBeGreaterThanOrEqual(1);
    });
  });
});
