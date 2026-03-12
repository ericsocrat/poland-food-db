import type { RecentlyViewedProduct } from "@/lib/types";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { QuickWinCard } from "./QuickWinCard";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockAlternativesData = {
  alternatives: [
    {
      product_id: 99,
      product_name: "Healthy Alternative",
      brand: "Good Brand",
      category: "chips",
      unhealthiness_score: 20,
      score_improvement: 45,
      nutri_score: "B" as const,
      similarity: 0.7,
      shared_ingredients: 3,
      is_cross_category: false,
      palm_oil_free: true,
      swap_savings: {
        score_delta: 45,
        headline: "Much healthier!",
        sat_fat_saved_g: 3,
        sugar_saved_g: 5,
        salt_saved_g: 0.5,
        calories_saved: 100,
      },
    },
  ],
  alternatives_count: 1,
  source_product: {
    product_id: 1,
    product_name: "Bad Chips",
    brand: "Junk Brand",
    category: "chips",
    unhealthiness_score: 65,
    nutri_score: "D" as const,
    has_palm_oil: true,
    saturated_fat_g: 8,
    sugars_g: 12,
    salt_g: 1.5,
    calories: 550,
  },
  search_scope: "same_category",
  filters_applied: {},
  api_version: "v1",
};

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, unknown>) => {
      const map: Record<string, string> = {
        "dashboard.quickWinTitle": "Quick Win",
        "dashboard.quickWinNone": "No swaps available right now.",
        "dashboard.quickWinLoading": "Finding a better swap…",
        "dashboard.quickWinViewSwap": "View swap",
      };
      if (key === "dashboard.quickWinSwap" && params) {
        return `Swap ${params.from} for ${params.to}`;
      }
      if (key === "dashboard.quickWinGain" && params) {
        return `+${params.points} points`;
      }
      return map[key] ?? key;
    },
  }),
}));

const mockUseAlternativesV2 = vi.fn();
vi.mock("@/hooks/use-alternatives-v2", () => ({
  useAlternativesV2: (...args: unknown[]) => mockUseAlternativesV2(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeProduct(overrides: Partial<RecentlyViewedProduct> = {}): RecentlyViewedProduct {
  return {
    product_id: 1,
    product_name: "Bad Chips",
    brand: "Junk Brand",
    category: "chips",
    country: "PL",
    unhealthiness_score: 65,
    nutri_score_label: "D",
    viewed_at: new Date().toISOString(),
    image_thumb_url: null,
    ...overrides,
  };
}

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("QuickWinCard", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUseAlternativesV2.mockReturnValue({
      data: mockAlternativesData,
      isLoading: false,
    });
  });

  it("returns null when no products", () => {
    const { container } = render(<QuickWinCard products={[]} />, {
      wrapper: createWrapper(),
    });
    expect(container.innerHTML).toBe("");
  });

  it("returns null when all scores are null", () => {
    const products = [makeProduct({ unhealthiness_score: null })];
    const { container } = render(<QuickWinCard products={products} />, {
      wrapper: createWrapper(),
    });
    expect(container.innerHTML).toBe("");
  });

  it("shows loading state", () => {
    mockUseAlternativesV2.mockReturnValue({ data: undefined, isLoading: true });
    const products = [makeProduct()];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });
    expect(screen.getByTestId("quick-win-loading")).toBeInTheDocument();
  });

  it("returns null when no alternatives available", () => {
    mockUseAlternativesV2.mockReturnValue({
      data: { alternatives: [], alternatives_count: 0 },
      isLoading: false,
    });
    const products = [makeProduct()];
    const { container } = render(<QuickWinCard products={products} />, {
      wrapper: createWrapper(),
    });
    expect(container.innerHTML).toBe("");
  });

  it("shows swap suggestion with score comparison", () => {
    const products = [makeProduct({ unhealthiness_score: 65 })];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });

    expect(screen.getByText(/Swap Bad Chips for Healthy Alternative/)).toBeInTheDocument();
    // From score: TryVit 35 (100-65), To score: TryVit 80 (100-20)
    expect(screen.getByTestId("quick-win-from-score").textContent).toBe("35");
    expect(screen.getByTestId("quick-win-to-score").textContent).toBe("80");
  });

  it("shows point gain when alternative is better", () => {
    const products = [makeProduct({ unhealthiness_score: 65 })];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });
    // Gain: TryVit(20) - TryVit(65) = 80 - 35 = 45
    expect(screen.getByTestId("quick-win-gain")).toHaveTextContent("+45 points");
  });

  it("picks the worst-scoring product", () => {
    const products = [
      makeProduct({ product_id: 1, product_name: "OK Chips", unhealthiness_score: 30 }),
      makeProduct({ product_id: 2, product_name: "Bad Chips", unhealthiness_score: 65 }),
      makeProduct({ product_id: 3, product_name: "Good Chips", unhealthiness_score: 10 }),
    ];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });

    // Hook should be called with productId of worst product (id=2, score=65)
    expect(mockUseAlternativesV2).toHaveBeenCalledWith(
      expect.objectContaining({ productId: 2, limit: 1, enabled: true }),
    );
  });

  it("links to product page", () => {
    const products = [makeProduct({ product_id: 42 })];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });

    const link = screen.getByRole("link", { name: /View swap/ });
    expect(link).toHaveAttribute("href", "/app/product/42");
  });

  it("has correct section aria-label", () => {
    const products = [makeProduct()];
    render(<QuickWinCard products={products} />, { wrapper: createWrapper() });
    expect(screen.getByLabelText("Quick Win")).toBeInTheDocument();
  });
});
