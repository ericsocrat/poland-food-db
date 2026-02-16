import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import SharedComparisonPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/navigation", () => ({
  useParams: () => ({ token: "comp-token-xyz" }),
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

const mockUseSharedComparison = vi.fn();
vi.mock("@/hooks/use-compare", () => ({
  useSharedComparison: (...args: unknown[]) => mockUseSharedComparison(...args),
}));

// Stub ComparisonGrid since it's complex and tested separately
vi.mock("@/components/compare/ComparisonGrid", () => ({
  ComparisonGrid: ({
    products,
  }: {
    products: unknown[];
  }) => <div data-testid="comparison-grid">{products.length} products</div>,
}));

beforeEach(() => {
  vi.clearAllMocks();
});

describe("SharedComparisonPage", () => {
  it("shows loading spinner while loading", () => {
    mockUseSharedComparison.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<SharedComparisonPage />);
    // Should render without crashing
    expect(screen.getByText("FoodDB", { exact: false })).toBeInTheDocument();
  });

  it("shows error message on error", () => {
    mockUseSharedComparison.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Invalid link"),
    });

    render(<SharedComparisonPage />);
    expect(screen.getByText(/invalid or has expired/i)).toBeInTheDocument();
  });

  it("shows go to FoodDB link on error", () => {
    mockUseSharedComparison.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Bad link"),
    });

    render(<SharedComparisonPage />);
    expect(screen.getByText("Go to FoodDB").closest("a")).toHaveAttribute(
      "href",
      "/",
    );
  });

  it("renders comparison data with title", () => {
    mockUseSharedComparison.mockReturnValue({
      data: {
        title: "Chips vs Drinks",
        product_count: 3,
        created_at: "2025-01-15T10:00:00Z",
        products: [
          { id: 1, name: "A" },
          { id: 2, name: "B" },
          { id: 3, name: "C" },
        ],
      },
      isLoading: false,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(screen.getByText(/Chips vs Drinks/)).toBeInTheDocument();
    expect(screen.getByText(/3 products compared/)).toBeInTheDocument();
  });

  it("renders ComparisonGrid with products", () => {
    mockUseSharedComparison.mockReturnValue({
      data: {
        title: null,
        product_count: 2,
        created_at: "2025-01-15T10:00:00Z",
        products: [
          { id: 1, name: "A" },
          { id: 2, name: "B" },
        ],
      },
      isLoading: false,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(screen.getByTestId("comparison-grid")).toBeInTheDocument();
    expect(screen.getByText("2 products")).toBeInTheDocument();
  });

  it("uses default title when none provided", () => {
    mockUseSharedComparison.mockReturnValue({
      data: {
        title: null,
        product_count: 2,
        created_at: "2025-01-15T10:00:00Z",
        products: [
          { id: 1, name: "A" },
          { id: 2, name: "B" },
        ],
      },
      isLoading: false,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(screen.getByText(/Product Comparison/)).toBeInTheDocument();
  });

  it("renders shared comparison badge", () => {
    mockUseSharedComparison.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(screen.getByText("Shared comparison")).toBeInTheDocument();
  });

  it("renders CTA section", () => {
    mockUseSharedComparison.mockReturnValue({
      data: {
        title: "Test",
        product_count: 2,
        created_at: "2025-01-15T10:00:00Z",
        products: [
          { id: 1, name: "A" },
          { id: 2, name: "B" },
        ],
      },
      isLoading: false,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(
      screen.getByText("Want to compare your own products?"),
    ).toBeInTheDocument();
    expect(screen.getByText("Sign up for free").closest("a")).toHaveAttribute(
      "href",
      "/auth/login",
    );
  });

  it("passes token to useSharedComparison", () => {
    mockUseSharedComparison.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<SharedComparisonPage />);
    expect(mockUseSharedComparison).toHaveBeenCalledWith("comp-token-xyz");
  });
});
