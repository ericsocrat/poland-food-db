import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import MySubmissionsPage from "./page";

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

const mockGetMySubmissions = vi.fn();
vi.mock("@/lib/api", () => ({
  getMySubmissions: (...args: unknown[]) => mockGetMySubmissions(...args),
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

const mockSubmissions = [
  {
    id: "sub-1",
    ean: "5901234123457",
    product_name: "Test Chips",
    brand: "TestBrand",
    category: "chips",
    photo_url: null,
    status: "pending" as const,
    merged_product_id: null,
    created_at: "2025-02-01T10:00:00Z",
    updated_at: "2025-02-01T10:00:00Z",
  },
  {
    id: "sub-2",
    ean: "9876543210987",
    product_name: "Merged Drink",
    brand: null,
    category: null,
    photo_url: null,
    status: "merged" as const,
    merged_product_id: 42,
    created_at: "2025-01-20T12:00:00Z",
    updated_at: "2025-01-25T16:00:00Z",
  },
  {
    id: "sub-3",
    ean: "1111111111111",
    product_name: "Rejected Cereal",
    brand: "BadBrand",
    category: "cereals",
    photo_url: null,
    status: "rejected" as const,
    merged_product_id: null,
    created_at: "2025-01-15T08:00:00Z",
    updated_at: "2025-01-16T09:00:00Z",
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGetMySubmissions.mockResolvedValue({
    ok: true,
    data: {
      submissions: mockSubmissions,
      page: 1,
      pages: 1,
      total: 3,
    },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("MySubmissionsPage", () => {
  it("renders page title and subtitle", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /My Submissions/i })).toBeInTheDocument();
    });
    expect(
      screen.getByText("Products you've submitted for review"),
    ).toBeInTheDocument();
  });

  it("links back to scanner", () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("← Back to Scanner").closest("a")).toHaveAttribute(
      "href",
      "/app/scan",
    );
  });

  it("shows loading spinner", () => {
    mockGetMySubmissions.mockReturnValue(new Promise(() => {}));
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state with retry button", async () => {
    mockGetMySubmissions.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByText("Failed to load submissions."),
      ).toBeInTheDocument();
    });
    expect(screen.getByText("Retry")).toBeInTheDocument();
  });

  it("shows empty state", async () => {
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: { submissions: [], page: 1, pages: 1, total: 0 },
    });
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("No submissions yet")).toBeInTheDocument();
    });
    expect(screen.getByText("Start scanning →").closest("a")).toHaveAttribute(
      "href",
      "/app/scan",
    );
  });

  it("renders submission rows with product names", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    expect(screen.getByText("Merged Drink")).toBeInTheDocument();
    expect(screen.getByText("Rejected Cereal")).toBeInTheDocument();
  });

  it("shows brand and EAN info", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/TestBrand/)).toBeInTheDocument();
    });
    expect(screen.getByText(/5901234123457/)).toBeInTheDocument();
  });

  it("shows category when present", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Category: chips")).toBeInTheDocument();
    });
  });

  it("shows status badges", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Pending")).toBeInTheDocument();
    });
    expect(screen.getByText("Merged")).toBeInTheDocument();
    // "Rejected" appears in both the status badge and status timeline
    expect(screen.getAllByText("Rejected").length).toBeGreaterThanOrEqual(1);
  });

  it("shows View button for merged submissions", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("View →")).toBeInTheDocument();
    });
  });

  it("navigates to product page when clicking View", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("View →")).toBeInTheDocument();
    });

    await user.click(screen.getByText("View →"));
    expect(mockPush).toHaveBeenCalledWith("/app/product/42");
  });

  it("shows status timeline with correct steps", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    // All submissions show "Submitted" step
    const submittedLabels = screen.getAllByText("Submitted");
    expect(submittedLabels.length).toBeGreaterThanOrEqual(3);
  });

  it("shows Live step for merged submissions", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Live")).toBeInTheDocument();
    });
  });

  it("does not show pagination for single page", async () => {
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    expect(screen.queryByText("← Prev")).not.toBeInTheDocument();
  });

  it("shows pagination for multiple pages", async () => {
    mockGetMySubmissions.mockResolvedValue({
      ok: true,
      data: {
        submissions: mockSubmissions,
        page: 1,
        pages: 3,
        total: 55,
      },
    });
    render(<MySubmissionsPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("← Prev")).toBeInTheDocument();
    });
    expect(screen.getByText("Next →")).toBeInTheDocument();
    expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
  });
});
