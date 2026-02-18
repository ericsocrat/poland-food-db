import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SavedComparisonsPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockUseSavedComparisons = vi.fn();
const mockDelete = vi.fn();
vi.mock("@/hooks/use-compare", () => ({
  useSavedComparisons: () => mockUseSavedComparisons(),
  useDeleteComparison: () => ({ mutate: mockDelete }),
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

const mockComparisons = [
  {
    comparison_id: "c1",
    title: "Healthy chips",
    product_ids: [1, 2, 3],
    share_token: "tok-abc",
    created_at: "2025-01-15T10:00:00Z",
    product_names: ["Product A", "Product B", "Product C"],
  },
  {
    comparison_id: "c2",
    title: null,
    product_ids: [4, 5],
    share_token: "",
    created_at: "2025-01-10T10:00:00Z",
    product_names: ["Product D", "Product E"],
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockUseSavedComparisons.mockReturnValue({
    data: { comparisons: mockComparisons },
    isLoading: false,
    error: null,
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SavedComparisonsPage", () => {
  it("renders page title", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(
      screen.getByRole("heading", { name: /Saved Comparisons/ }),
    ).toBeInTheDocument();
  });

  it("shows loading spinner", () => {
    mockUseSavedComparisons.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state", () => {
    mockUseSavedComparisons.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Network"),
    });
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(
      screen.getByText("Failed to load comparison data."),
    ).toBeInTheDocument();
  });

  it("shows empty state when no comparisons", () => {
    mockUseSavedComparisons.mockReturnValue({
      data: { comparisons: [] },
      isLoading: false,
      error: null,
    });
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("No saved comparisons yet")).toBeInTheDocument();
    expect(screen.getByText("Find Products").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
  });

  it("renders comparison cards with titles", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Healthy chips")).toBeInTheDocument();
  });

  it("shows fallback title when title is null", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Compare 2 products")).toBeInTheDocument();
  });

  it("renders product name chips", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Product A")).toBeInTheDocument();
    expect(screen.getByText("Product B")).toBeInTheDocument();
    expect(screen.getByText("Product C")).toBeInTheDocument();
  });

  it("links cards to compare page with IDs", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    const link = screen.getByText("Healthy chips").closest("a");
    expect(link).toHaveAttribute("href", "/app/compare?ids=1,2,3");
  });

  it("calls delete when delete button clicked", async () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();
    const deleteButtons = screen.getAllByTitle("Delete comparison");
    await user.click(deleteButtons[0]);
    expect(mockDelete).toHaveBeenCalledWith("c1");
  });

  it("renders share button only when share_token exists", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    const shareButtons = screen.getAllByTitle("Copy Share Link");
    // Only comparison c1 has a truthy share_token
    expect(shareButtons).toHaveLength(1);
  });

  it("links back to compare page", () => {
    render(<SavedComparisonsPage />, { wrapper: createWrapper() });
    const backLink = screen.getByText("Compare Products").closest("a");
    expect(backLink).toHaveAttribute("href", "/app/compare");
  });
});
