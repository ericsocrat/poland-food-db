import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ProductDetailPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/navigation", () => ({
  useParams: () => ({ id: "42" }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

const mockGetProductDetail = vi.fn();
const mockGetBetterAlternatives = vi.fn();
const mockGetScoreExplanation = vi.fn();

vi.mock("@/lib/api", () => ({
  getProductDetail: (...args: unknown[]) => mockGetProductDetail(...args),
  getBetterAlternatives: (...args: unknown[]) =>
    mockGetBetterAlternatives(...args),
  getScoreExplanation: (...args: unknown[]) => mockGetScoreExplanation(...args),
}));

vi.mock("@/components/product/HealthWarningsCard", () => ({
  HealthWarningsCard: () => <div data-testid="health-warnings-card" />,
  HealthWarningBadge: () => <span data-testid="health-warning-badge" />,
}));

vi.mock("@/components/product/AvoidBadge", () => ({
  AvoidBadge: () => <span data-testid="avoid-badge" />,
}));

vi.mock("@/components/product/AddToListMenu", () => ({
  AddToListMenu: () => <span data-testid="add-to-list" />,
}));

vi.mock("@/components/compare/CompareCheckbox", () => ({
  CompareCheckbox: () => <span data-testid="compare-checkbox" />,
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="loading-spinner" />,
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

function makeProduct(overrides: Record<string, unknown> = {}) {
  return {
    api_version: "v1",
    product_id: 42,
    ean: "5901234123457",
    product_name: "Test Chips Original",
    brand: "TestBrand",
    category: "chips",
    category_display: "Chips",
    category_icon: "🍟",
    product_type: "snack",
    country: "PL",
    store_availability: "Żabka",
    prep_method: null,
    scores: {
      unhealthiness_score: 65,
      score_band: "high",
      nutri_score: "D",
      nutri_score_color: "#e63946",
      nova_group: "4",
      processing_risk: "high",
    },
    flags: {
      high_salt: true,
      high_sugar: false,
      high_sat_fat: true,
      high_additive_load: false,
      has_palm_oil: true,
    },
    nutrition_per_100g: {
      calories: 530,
      total_fat_g: 32,
      saturated_fat_g: 14,
      trans_fat_g: null,
      carbs_g: 52,
      sugars_g: 3,
      fibre_g: 4,
      protein_g: 6,
      salt_g: 1.8,
    },
    ingredients: {
      count: 12,
      additives_count: 3,
      additive_names: ["E621", "E330", "E250"],
      vegan_status: "yes",
      vegetarian_status: "yes",
      data_quality: "good",
    },
    allergens: {
      count: 2,
      tags: ["en:gluten", "en:milk"],
      trace_count: 1,
      trace_tags: ["en:soy"],
    },
    trust: {
      confidence: "high",
      data_completeness_pct: 92,
      source_type: "openfoodfacts",
      nutrition_data_quality: "good",
      ingredient_data_quality: "good",
    },
    freshness: {
      created_at: "2025-12-01",
      updated_at: "2026-01-15",
      data_age_days: 32,
    },
    ...overrides,
  };
}

function makeAlternatives() {
  return {
    ok: true,
    data: {
      api_version: "v1",
      source_product: {
        product_id: 42,
        product_name: "Test Chips",
        brand: "TestBrand",
        category: "chips",
        unhealthiness_score: 65,
        nutri_score: "D",
      },
      search_scope: "category",
      alternatives: [
        {
          product_id: 99,
          product_name: "Healthy Veggie Sticks",
          brand: "HealthBrand",
          category: "chips",
          unhealthiness_score: 25,
          score_improvement: 40,
          nutri_score: "B",
          similarity: 0.8,
          shared_ingredients: 3,
        },
      ],
      alternatives_count: 1,
    },
  };
}

function makeScoreExplanation() {
  return {
    ok: true,
    data: {
      api_version: "v1",
      product_id: 42,
      product_name: "Test Chips",
      brand: "TestBrand",
      category: "chips",
      score_breakdown: {},
      summary: {
        score: 65,
        score_band: "high",
        headline: "This product has a high unhealthiness score.",
        nutri_score: "D",
        nova_group: "4",
        processing_risk: "high",
      },
      top_factors: [
        { factor: "Saturated fat", raw: 14, weighted: 8.5 },
        { factor: "Salt content", raw: 1.8, weighted: 6.2 },
      ],
      warnings: [{ type: "high_salt", message: "Very high salt content" }],
      category_context: {
        category_avg_score: 55,
        category_rank: 18,
        category_total: 42,
        relative_position: "worse than average",
      },
    },
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());
  mockGetScoreExplanation.mockResolvedValue(makeScoreExplanation());
});

describe("ProductDetailPage", () => {
  // ── Loading state ───────────────────────────────────────────────────────

  it("renders loading spinner initially", () => {
    mockGetProductDetail.mockReturnValue(new Promise(() => {})); // never resolves
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("loading-spinner")).toBeInTheDocument();
  });

  // ── Error state ─────────────────────────────────────────────────────────

  it("renders error state with retry button", async () => {
    mockGetProductDetail.mockRejectedValue(new Error("API error"));
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Failed to load product.")).toBeInTheDocument();
    });
    expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
  });

  it("retries loading on retry click", async () => {
    mockGetProductDetail.mockRejectedValueOnce(new Error("fail"));
    const user = userEvent.setup();

    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Failed to load product.")).toBeInTheDocument();
    });

    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    await user.click(screen.getByRole("button", { name: "Retry" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
  });

  // ── Not found state ─────────────────────────────────────────────────────

  it("renders not found message when product is null", async () => {
    mockGetProductDetail.mockResolvedValue({ ok: true, data: null });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Product not found.")).toBeInTheDocument();
    });
  });

  // ── Success state — header ──────────────────────────────────────────────

  it("renders product name and brand", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.getByText("TestBrand")).toBeInTheDocument();
  });

  it("renders unhealthiness score badge", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("65")).toBeInTheDocument();
    });
  });

  it("renders nutri-score badge", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Nutri-Score D")).toBeInTheDocument();
    });
  });

  it("renders NOVA group", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("NOVA 4")).toBeInTheDocument();
    });
  });

  it("renders EAN code", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("EAN: 5901234123457")).toBeInTheDocument();
    });
  });

  it("renders store availability", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Store: Żabka")).toBeInTheDocument();
    });
  });

  it("renders category with icon", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("🍟 Chips")).toBeInTheDocument();
    });
  });

  // ── Health flags ────────────────────────────────────────────────────────

  it("renders active health flags", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("High salt")).toBeInTheDocument();
    });
    expect(screen.getByText("High sat. fat")).toBeInTheDocument();
    expect(screen.getByText("Palm oil")).toBeInTheDocument();
    expect(screen.queryByText("High sugar")).not.toBeInTheDocument();
    expect(screen.queryByText("Many additives")).not.toBeInTheDocument();
  });

  it("shows explanation on flag click", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("High salt")).toBeInTheDocument();
    });

    await user.click(screen.getByText("High salt"));
    expect(
      screen.getByText(/Salt exceeds 1.5 g per 100 g/),
    ).toBeInTheDocument();
  });

  // ── Tabs ────────────────────────────────────────────────────────────────

  it("renders all four tabs", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toBeInTheDocument();
    });
    expect(screen.getByRole("tab", { name: "Nutrition" })).toBeInTheDocument();
    expect(
      screen.getByRole("tab", { name: "Alternatives" }),
    ).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
  });

  it("overview tab is selected by default", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });
  });

  // ── Overview tab content ────────────────────────────────────────────────

  it("overview shows ingredients info", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("12 ingredients")).toBeInTheDocument();
    });
    expect(screen.getByText("3 additives")).toBeInTheDocument();
    expect(screen.getByText("E621, E330, E250")).toBeInTheDocument();
  });

  it("overview shows allergen tags", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("gluten")).toBeInTheDocument();
    });
    expect(screen.getByText("milk")).toBeInTheDocument();
  });

  it("overview shows trace allergens", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("May contain:")).toBeInTheDocument();
    });
    expect(screen.getByText("soy")).toBeInTheDocument();
  });

  it("overview shows data quality info", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Confidence: high")).toBeInTheDocument();
    });
    expect(screen.getByText("Completeness: 92%")).toBeInTheDocument();
  });

  it("overview shows vegan/vegetarian status", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Vegan: yes")).toBeInTheDocument();
    });
    expect(screen.getByText("Vegetarian: yes")).toBeInTheDocument();
  });

  // ── Nutrition tab ───────────────────────────────────────────────────────

  it("nutrition tab shows macronutrient table", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Nutrition" }));

    expect(screen.getByText("530 kcal")).toBeInTheDocument();
    expect(screen.getByText("32 g")).toBeInTheDocument(); // total fat
    expect(screen.getByText("52 g")).toBeInTheDocument(); // carbs
    expect(screen.getByText("6 g")).toBeInTheDocument(); // protein
    expect(screen.getByText("1.8 g")).toBeInTheDocument(); // salt
  });

  it("nutrition tab shows dash for null trans fat", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Nutrition" }));
    expect(screen.getByText("—")).toBeInTheDocument();
  });

  // ── Alternatives tab ──────────────────────────────────────────────────

  it("alternatives tab shows healthier options", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Alternatives" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Alternatives" }));

    await waitFor(() => {
      expect(screen.getByText("Healthy Veggie Sticks")).toBeInTheDocument();
    });
    expect(screen.getByText("HealthBrand")).toBeInTheDocument();
    expect(screen.getByText("−40 points better")).toBeInTheDocument();
  });

  it("alternatives tab shows empty message when no alternatives", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    mockGetBetterAlternatives.mockResolvedValue({
      ok: true,
      data: {
        ...makeAlternatives().data,
        alternatives: [],
        alternatives_count: 0,
      },
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Alternatives" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Alternatives" }));

    await waitFor(() => {
      expect(
        screen.getByText("No healthier alternatives found in this category."),
      ).toBeInTheDocument();
    });
  });

  // ── Scoring tab ─────────────────────────────────────────────────────────

  it("scoring tab shows score factors", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByText("Saturated fat")).toBeInTheDocument();
    });
    expect(screen.getByText("+8.5")).toBeInTheDocument();
    expect(screen.getByText("Salt content")).toBeInTheDocument();
    expect(screen.getByText("+6.2")).toBeInTheDocument();
  });

  it("scoring tab shows summary headline", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(
        screen.getByText("This product has a high unhealthiness score."),
      ).toBeInTheDocument();
    });
  });

  it("scoring tab shows warnings", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByText("Very high salt content")).toBeInTheDocument();
    });
  });

  it("scoring tab shows category context", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByText("Rank: 18 of 42")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Position: worse than average"),
    ).toBeInTheDocument();
  });

  // ── Back button ─────────────────────────────────────────────────────────

  it("renders back button linking to search", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Back")).toBeInTheDocument();
    });
    expect(screen.getByText("Back").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
  });

  // ── Child components rendered ───────────────────────────────────────────

  it("renders HealthWarningsCard component", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-warnings-card")).toBeInTheDocument();
    });
  });

  it("renders AvoidBadge component", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("avoid-badge")).toBeInTheDocument();
    });
  });

  it("renders CompareCheckbox component", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("compare-checkbox")).toBeInTheDocument();
    });
  });

  // ── Edge cases ──────────────────────────────────────────────────────────

  it("handles product without EAN", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct({ ean: null }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText(/EAN:/)).not.toBeInTheDocument();
  });

  it("handles product without store availability", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct({ store_availability: null }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText(/Store:/)).not.toBeInTheDocument();
  });

  it("handles product with no flags set", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct({
        flags: {
          high_salt: false,
          high_sugar: false,
          high_sat_fat: false,
          high_additive_load: false,
          has_palm_oil: false,
        },
      }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText("Health flags")).not.toBeInTheDocument();
  });

  it("handles product with no allergens", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct({
        allergens: {
          count: 0,
          tags: [],
          trace_count: 0,
          trace_tags: [],
        },
      }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText("Allergens")).not.toBeInTheDocument();
  });

  it("handles null nutri_score with question mark", async () => {
    mockGetProductDetail.mockResolvedValue({
      ok: true,
      data: makeProduct({
        scores: {
          unhealthiness_score: 50,
          score_band: "moderate",
          nutri_score: null,
          nutri_score_color: "#ccc",
          nova_group: "3",
          processing_risk: "moderate",
        },
      }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Nutri-Score ?")).toBeInTheDocument();
    });
  });
});
