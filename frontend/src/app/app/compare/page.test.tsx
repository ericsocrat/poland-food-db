import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ComparePage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGet = vi.fn();
vi.mock("next/navigation", () => ({
  useSearchParams: () => ({ get: mockGet }),
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

const mockUseCompareProducts = vi.fn();
vi.mock("@/hooks/use-compare", () => ({
  useCompareProducts: (...args: unknown[]) => mockUseCompareProducts(...args),
}));

const mockClear = vi.fn();
vi.mock("@/stores/compare-store", () => ({
  useCompareStore: (selector: (s: { clear: () => void }) => unknown) =>
    selector({ clear: mockClear }),
}));

vi.mock("@/components/compare/ComparisonGrid", () => ({
  ComparisonGrid: ({
    products,
    showAvoidBadge,
  }: {
    products: unknown[];
    showAvoidBadge: boolean;
  }) => (
    <div data-testid="comparison-grid" data-avoid={showAvoidBadge}>
      {products.length} products
    </div>
  ),
}));

vi.mock("@/components/compare/ShareComparison", () => ({
  ShareComparison: ({ productIds }: { productIds: number[] }) => (
    <div data-testid="share-comparison">{productIds.join(",")}</div>
  ),
}));

vi.mock("@/components/common/skeletons", () => ({
  ComparisonGridSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
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
  mockGet.mockReturnValue(null);
  mockUseCompareProducts.mockReturnValue({
    data: undefined,
    isLoading: false,
    error: null,
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ComparePage", () => {
  describe("empty state (no/insufficient IDs)", () => {
    it("shows empty state when no ids param", () => {
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(
        screen.getByText("Select 2–4 products to compare"),
      ).toBeInTheDocument();
    });

    it("shows empty state when only one id", () => {
      mockGet.mockReturnValue("5");
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(
        screen.getByText("Select 2–4 products to compare"),
      ).toBeInTheDocument();
    });

    it("links to search page from empty state", () => {
      render(<ComparePage />, { wrapper: createWrapper() });
      const link = screen.getByText("Search Products");
      expect(link.closest("a")).toHaveAttribute("href", "/app/search");
    });

    it("links to saved comparisons from empty state", () => {
      render(<ComparePage />, { wrapper: createWrapper() });
      const link = screen.getByText("Saved Comparisons");
      expect(link.closest("a")).toHaveAttribute("href", "/app/compare/saved");
    });
  });

  describe("with valid IDs", () => {
    beforeEach(() => {
      mockGet.mockReturnValue("1,2,3");
    });

    it("shows skeleton loading state while fetching", () => {
      mockUseCompareProducts.mockReturnValue({
        data: undefined,
        isLoading: true,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(screen.getByTestId("skeleton")).toBeInTheDocument();
    });

    it("shows error state on failure", () => {
      mockUseCompareProducts.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: new Error("Network error"),
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(
        screen.getByText("Failed to load comparison data."),
      ).toBeInTheDocument();
      expect(screen.getByTestId("empty-state")).toHaveAttribute(
        "data-variant",
        "error",
      );
    });

    it("renders ComparisonGrid when data loaded", () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 3, products: [{}, {}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(screen.getByTestId("comparison-grid")).toBeInTheDocument();
      expect(screen.getByText("3 products")).toBeInTheDocument();
    });

    it("renders ShareComparison toolbar", () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 3, products: [{}, {}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(screen.getByTestId("share-comparison")).toBeInTheDocument();
      expect(screen.getByText("Comparing 3 products")).toBeInTheDocument();
    });

    it("shows partial results warning when some products missing", () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 2, products: [{}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(screen.getByText(/1 product\(s\) not found/)).toBeInTheDocument();
    });

    it("does not show partial warning when all products found", () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 3, products: [{}, {}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(
        screen.queryByText(/product\(s\) not found/),
      ).not.toBeInTheDocument();
    });

    it("clear button calls store clear", async () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 3, products: [{}, {}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      const user = userEvent.setup();
      await user.click(screen.getByText("Clear selection"));
      expect(mockClear).toHaveBeenCalled();
    });

    it("header links to saved comparisons", () => {
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 3, products: [{}, {}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      const link = screen.getByText("📂 Saved Comparisons");
      expect(link.closest("a")).toHaveAttribute("href", "/app/compare/saved");
    });
  });

  describe("ID parsing", () => {
    it("filters out invalid IDs (NaN, negatives)", () => {
      mockGet.mockReturnValue("1,abc,-5,3");
      mockUseCompareProducts.mockReturnValue({
        data: { product_count: 2, products: [{}, {}] },
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      // Should call useCompareProducts with [1, 3]
      expect(mockUseCompareProducts).toHaveBeenCalledWith([1, 3]);
    });

    it("caps at 4 IDs", () => {
      mockGet.mockReturnValue("1,2,3,4,5,6");
      mockUseCompareProducts.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: null,
      });
      render(<ComparePage />, { wrapper: createWrapper() });
      expect(mockUseCompareProducts).toHaveBeenCalledWith([1, 2, 3, 4]);
    });
  });
});
