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

const mockGetProductProfile = vi.fn();

vi.mock("@/lib/api", () => ({
  getProductProfile: (...args: unknown[]) => mockGetProductProfile(...args),
  recordProductView: vi.fn().mockResolvedValue({ ok: true }),
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

vi.mock("@/components/common/skeletons", () => ({
  ProductProfileSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
  ProductCardSkeleton: () => (
    <div data-testid="skeleton-cards" role="status" aria-busy="true" />
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

function makeProfile(overrides: Record<string, unknown> = {}) {
  return {
    api_version: "v1",
    meta: {
      product_id: 42,
      language: "en",
      retrieved_at: "2026-01-15T10:00:00Z",
    },
    product: {
      product_id: 42,
      product_name: "Test Chips Original",
      product_name_en: null,
      product_name_display: "Test Chips Original",
      original_language: "pl",
      brand: "TestBrand",
      category: "chips",
      category_display: "Chips",
      category_icon: "🍟",
      product_type: "snack",
      country: "PL",
      ean: "5901234123457",
      prep_method: null,
      store_availability: "Żabka",
      controversies: null,
    },
    nutrition: {
      per_100g: {
        calories_kcal: 530,
        total_fat_g: 32,
        saturated_fat_g: 14,
        trans_fat_g: null,
        carbs_g: 52,
        sugars_g: 3,
        fibre_g: 4,
        protein_g: 6,
        salt_g: 1.8,
      },
      per_serving: null,
      daily_values: {
        reference_type: "standard",
        regulation: "eu_ri",
        per_100g: {
          calories: { value: 530, daily_value: 2000, pct: 26.5, level: "high" },
          total_fat: { value: 32, daily_value: 70, pct: 45.7, level: "high" },
          saturated_fat: {
            value: 14,
            daily_value: 20,
            pct: 70,
            level: "high",
          },
          carbs: {
            value: 52,
            daily_value: 260,
            pct: 20,
            level: "moderate",
          },
          sugars: { value: 3, daily_value: 90, pct: 3.3, level: "low" },
          fiber: { value: 4, daily_value: 25, pct: 16, level: "moderate" },
          protein: { value: 6, daily_value: 50, pct: 12, level: "moderate" },
          salt: { value: 1.8, daily_value: 6, pct: 30, level: "high" },
          trans_fat: null,
        },
        per_serving: null,
      },
    },
    ingredients: {
      count: 12,
      additive_count: 3,
      additive_names: "E621, E330, E250",
      has_palm_oil: true,
      vegan_status: "yes",
      vegetarian_status: "yes",
      ingredients_text: null,
      top_ingredients: [],
    },
    allergens: {
      contains: "en:gluten,en:milk",
      traces: "en:soy",
      contains_count: 2,
      traces_count: 1,
    },
    scores: {
      unhealthiness_score: 65,
      score_band: "high",
      nutri_score_label: "D",
      nutri_score_color: "#e63946",
      nova_group: "4",
      processing_risk: "high",
      score_breakdown: [
        { name: "saturated_fat", raw: 14, input: 14, weight: 1, weighted: 8.5 },
        { name: "salt", raw: 1.8, input: 1.8, weight: 1, weighted: 6.2 },
      ],
      headline:
        "This product has significant nutritional concerns across multiple factors.",
      category_context: {
        rank: 18,
        total_in_category: 42,
        category_avg_score: 55,
        relative_position: "worse_than_average",
      },
    },
    warnings: [
      {
        type: "high_salt",
        severity: "warning",
        message: "High salt content",
      },
    ],
    quality: {
      api_version: "1.0",
      confidence_band: "high",
      confidence_score: 92,
    },
    alternatives: [
      {
        product_id: 99,
        product_name: "Healthy Veggie Sticks",
        brand: "HealthBrand",
        category: "chips",
        unhealthiness_score: 25,
        score_delta: 40,
        nutri_score: "B",
        similarity: 0.8,
      },
    ],
    flags: {
      high_salt: true,
      high_sugar: false,
      high_sat_fat: true,
      high_additive_load: false,
      has_palm_oil: true,
    },
    images: {
      has_image: false,
      primary: null,
      additional: [],
    },
    ...overrides,
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
});

describe("ProductDetailPage", () => {
  // ── Loading state ───────────────────────────────────────────────────────

  it("renders skeleton loading state initially", () => {
    mockGetProductProfile.mockReturnValue(new Promise(() => {})); // never resolves
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("skeleton")).toBeInTheDocument();
  });

  // ── Error state ─────────────────────────────────────────────────────────

  it("renders error state with retry button", async () => {
    mockGetProductProfile.mockRejectedValue(new Error("API error"));
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Failed to load product.")).toBeInTheDocument();
    });
    expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
  });

  it("retries loading on retry click", async () => {
    mockGetProductProfile.mockRejectedValueOnce(new Error("fail"));
    const user = userEvent.setup();

    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Failed to load product.")).toBeInTheDocument();
    });

    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    await user.click(screen.getByRole("button", { name: "Retry" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
  });

  // ── Not found state ─────────────────────────────────────────────────────

  it("renders not found message when product is null", async () => {
    mockGetProductProfile.mockResolvedValue({ ok: true, data: null });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Product not found.")).toBeInTheDocument();
    });
  });

  // ── Success state — header ──────────────────────────────────────────────

  it("renders product name and brand", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.getByText("TestBrand")).toBeInTheDocument();
  });

  it("renders unhealthiness score badge with /100 denominator", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("65")).toBeInTheDocument();
    });
    expect(screen.getByText("/100")).toBeInTheDocument();
    expect(screen.getByLabelText("Score: 65 out of 100")).toBeInTheDocument();
  });

  it("renders nutri-score badge", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByLabelText("Nutri-Score D")).toBeInTheDocument();
    });
    expect(screen.getByText("Nutri-Score")).toBeInTheDocument();
  });

  it("renders NOVA group", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("NOVA 4")).toBeInTheDocument();
    });
  });

  it("renders EAN code", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("EAN: 5901234123457")).toBeInTheDocument();
    });
  });

  it("renders store availability", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Store: Żabka")).toBeInTheDocument();
    });
  });

  it("renders category with icon", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("🍟 Chips")).toBeInTheDocument();
    });
  });

  // ── Health flags ────────────────────────────────────────────────────────

  it("renders active health flags", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("12 ingredients")).toBeInTheDocument();
    });
    expect(screen.getByText("3 additives")).toBeInTheDocument();
    expect(screen.getByText("E621, E330, E250")).toBeInTheDocument();
  });

  it("overview shows allergen tags", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("gluten")).toBeInTheDocument();
    });
    expect(screen.getByText("milk")).toBeInTheDocument();
  });

  it("overview shows trace allergens", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("May contain:")).toBeInTheDocument();
    });
    expect(screen.getByText("soy")).toBeInTheDocument();
  });

  it("overview shows data quality info", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Confidence: high")).toBeInTheDocument();
    });
    expect(screen.getByText("Completeness: 92%")).toBeInTheDocument();
  });

  it("overview shows vegan/vegetarian status", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Vegan: yes")).toBeInTheDocument();
    });
    expect(screen.getByText("Vegetarian: yes")).toBeInTheDocument();
  });

  // ── Nutrition tab ───────────────────────────────────────────────────────

  it("nutrition tab shows macronutrient table", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({ alternatives: [] }),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByText("Saturated Fat")).toBeInTheDocument();
    });
    expect(screen.getByText("+8.5")).toBeInTheDocument();
    // "Salt" appears in both radar chart label and factors list
    expect(screen.getAllByText("Salt").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("+6.2")).toBeInTheDocument();
  });

  it("scoring tab shows summary headline", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(
        screen.getByText(
          "This product has significant nutritional concerns across multiple factors.",
        ),
      ).toBeInTheDocument();
    });
  });

  it("scoring tab shows warnings", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByText("High salt content")).toBeInTheDocument();
    });
  });

  it("scoring tab shows category context", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
      screen.getByText("Position: Worse Than Average"),
    ).toBeInTheDocument();
  });

  // ── Back button ─────────────────────────────────────────────────────────

  it("renders back button linking to search", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("health-warnings-card")).toBeInTheDocument();
    });
  });

  it("renders AvoidBadge component", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("avoid-badge")).toBeInTheDocument();
    });
  });

  it("renders CompareCheckbox component", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("compare-checkbox")).toBeInTheDocument();
    });
  });

  // ── Edge cases ──────────────────────────────────────────────────────────

  it("handles product without EAN", async () => {
    const p = makeProfile();
    p.product.ean = null;
    mockGetProductProfile.mockResolvedValue({ ok: true, data: p });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText(/EAN:/)).not.toBeInTheDocument();
  });

  it("handles product without store availability", async () => {
    const p = makeProfile();
    p.product.store_availability = null;
    mockGetProductProfile.mockResolvedValue({ ok: true, data: p });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Chips Original")).toBeInTheDocument();
    });
    expect(screen.queryByText(/Store:/)).not.toBeInTheDocument();
  });

  it("handles product with no flags set", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        allergens: {
          contains: "",
          traces: "",
          contains_count: 0,
          traces_count: 0,
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
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        scores: {
          ...makeProfile().scores,
          unhealthiness_score: 50,
          score_band: "moderate",
          nutri_score_label: null,
          nutri_score_color: "#ccc",
          nova_group: "3",
          processing_risk: "moderate",
        },
      }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByLabelText("Nutri-Score unknown")).toBeInTheDocument();
    });
  });
});
