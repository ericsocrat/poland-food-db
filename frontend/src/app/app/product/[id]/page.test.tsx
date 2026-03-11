import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ProductDetailPage from "./page";

// ─── Feature-flag control (hoisted so vi.mock factory can reference it) ─────
const { features } = vi.hoisted(() => ({
  features: { ECO_SCORE: false },
}));

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/constants", async (importOriginal) => {
  // eslint-disable-next-line @typescript-eslint/consistent-type-imports
  const actual = await importOriginal<typeof import("@/lib/constants")>();
  return { ...actual, FEATURES: features };
});

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

vi.mock("@/components/product/WatchButton", () => ({
  WatchButton: () => <span data-testid="watch-button" />,
}));

vi.mock("@/components/product/ActionOverflowMenu", () => ({
  ActionOverflowMenu: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <div data-testid="action-overflow-menu" className={className}>
      {children}
    </div>
  ),
}));

vi.mock("@/components/product/ScoreHistoryPanel", () => ({
  ScoreHistoryPanel: () => <div data-testid="score-history-panel" />,
}));

vi.mock("@/components/product/ProductScoreHero", () => ({
  ProductScoreHero: ({
    unhealthinessScore,
    headline,
  }: {
    unhealthinessScore: number;
    headline: string;
  }) => (
    <div
      data-testid="product-score-hero"
      data-score={unhealthinessScore}
      data-headline={headline}
    />
  ),
}));

vi.mock("@/components/product/NutritionHighlights", () => ({
  NutritionHighlights: () => <div data-testid="nutrition-highlights" />,
}));

vi.mock("@/components/product/AllergenQuickBadges", () => ({
  AllergenQuickBadges: () => <div data-testid="allergen-quick-badges" />,
}));

vi.mock("@/components/common/skeletons", () => ({
  ProductProfileSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
  ProductCardSkeleton: () => (
    <div data-testid="skeleton-cards" role="status" aria-busy="true" />
  ),
}));

vi.mock("@/components/common/NutriScoreBadge", () => ({
  NutriScoreBadge: ({ grade }: { grade: string | null }) => {
    const display = grade?.toUpperCase() ?? "?";
    const label = ["A", "B", "C", "D", "E"].includes(display)
      ? display
      : "unknown";
    return (
      <span data-testid="nutri-score-badge" aria-label={`Nutri-Score ${label}`}>
        {display}
      </span>
    );
  },
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
      contains: "gluten,milk",
      traces: "soybeans",
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
  features.ECO_SCORE = false; // reset to default before each test
  // Set full analysis mode so all existing tab-based tests see expanded state
  localStorage.setItem("tryvit:product-full-analysis", "true");
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
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
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
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getByText("TestBrand")).toBeInTheDocument();
  });

  it("renders ProductScoreHero with unhealthiness score", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      const hero = screen.getByTestId("product-score-hero");
      expect(hero).toBeInTheDocument();
      expect(hero.getAttribute("data-score")).toBe("65");
    });
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
      expect(screen.getByText("Gluten")).toBeInTheDocument();
    });
    expect(screen.getByText("Milk")).toBeInTheDocument();
  });

  it("overview shows trace allergens", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("May contain traces")).toBeInTheDocument();
    });
    expect(screen.getByText("Soy")).toBeInTheDocument();
  });

  // ── Top ingredients — concern tier labels ───────────────────────────────

  it("renders top ingredient pills with concern tier labels", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        ingredients: {
          count: 5,
          additive_count: 1,
          additive_names: "E621",
          has_palm_oil: false,
          vegan_status: "yes",
          vegetarian_status: "yes",
          ingredients_text: null,
          top_ingredients: [
            {
              ingredient_id: 1,
              name: "Wheat Flour",
              position: 1,
              concern_tier: 0,
              is_additive: false,
              concern_reason: null,
            },
            {
              ingredient_id: 2,
              name: "Monosodium Glutamate",
              position: 2,
              concern_tier: 2,
              is_additive: true,
              concern_reason: "EFSA notes potential effects at high doses",
            },
          ],
        },
      }),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/Wheat Flour/)).toBeInTheDocument();
    });
    // Tier 0 ingredient should NOT show a tier label
    const wheatPill = screen.getByText(/Wheat Flour/);
    expect(wheatPill.textContent).not.toContain("concern");

    // Tier 2 ingredient should show "Moderate concern" label
    expect(screen.getByText(/Moderate concern/)).toBeInTheDocument();
  });

  it("renders expandable concern detail button for tier > 0 with reason", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        ingredients: {
          count: 3,
          additive_count: 1,
          additive_names: "E621",
          has_palm_oil: false,
          vegan_status: "yes",
          vegetarian_status: "yes",
          ingredients_text: null,
          top_ingredients: [
            {
              ingredient_id: 2,
              name: "Monosodium Glutamate",
              position: 1,
              concern_tier: 2,
              is_additive: true,
              concern_reason: "EFSA notes potential effects at high doses",
            },
          ],
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/Monosodium Glutamate/)).toBeInTheDocument();
    });

    // Concern detail should not be visible initially
    expect(
      screen.queryByText("EFSA notes potential effects at high doses"),
    ).not.toBeInTheDocument();

    // Click the expand button
    const expandBtn = screen.getByLabelText("Toggle concern detail");
    await user.click(expandBtn);

    // Now detail should be visible
    expect(
      screen.getByText("EFSA notes potential effects at high doses"),
    ).toBeInTheDocument();
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
    expect(screen.getByText("92%")).toBeInTheDocument();
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

    expect(screen.getByText("530 kcal / 2218 kJ")).toBeInTheDocument();
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

  // ── Nutrition per-serving toggle ────────────────────────────────────

  it("hides per-serving toggle when per_serving is null", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(), // default has per_serving: null
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));
    expect(screen.queryByRole("radiogroup")).not.toBeInTheDocument();
  });

  it("shows per-serving toggle when per_serving data exists", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        nutrition: {
          ...makeProfile().nutrition,
          per_serving: {
            serving_size: "30g",
            serving_grams: 30,
            calories_kcal: 159,
            total_fat_g: 9.6,
            saturated_fat_g: 4.2,
            trans_fat_g: null,
            carbs_g: 15.6,
            sugars_g: 0.9,
            fibre_g: 1.2,
            protein_g: 1.8,
            salt_g: 0.54,
          },
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));

    const toggle = screen.getByRole("radiogroup");
    expect(toggle).toBeInTheDocument();

    // Per 100g radio should be checked by default
    const per100gRadio = screen.getByRole("radio", { name: "Per 100 g" });
    expect(per100gRadio).toBeChecked();

    // Should show per 100g values initially
    expect(screen.getByText("530 kcal / 2218 kJ")).toBeInTheDocument();
  });

  it("switches to per-serving values on toggle click", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        nutrition: {
          ...makeProfile().nutrition,
          per_serving: {
            serving_size: "30g",
            serving_grams: 30,
            calories_kcal: 159,
            total_fat_g: 9.6,
            saturated_fat_g: 4.2,
            trans_fat_g: null,
            carbs_g: 15.6,
            sugars_g: 0.9,
            fibre_g: 1.2,
            protein_g: 1.8,
            salt_g: 0.54,
          },
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));

    // Click per serving radio
    const perServingRadio = screen.getByRole("radio", { name: "Per serving" });
    await user.click(perServingRadio);

    // Should now show per-serving values
    expect(screen.getByText("159 kcal / 665 kJ")).toBeInTheDocument();
    expect(screen.getByText("9.6 g")).toBeInTheDocument(); // total fat
    expect(screen.getByText("0.54 g")).toBeInTheDocument(); // salt
  });

  // ── Glycemic Index indicator (§4.4) ─────────────────────────────────

  it("shows low GI indicator when gi_estimate ≤ 55", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        nutrition: {
          ...makeProfile().nutrition,
          gi_estimate: 42,
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));
    const badge = screen.getByTestId("gi-badge");
    expect(badge).toHaveTextContent("Low GI");
    expect(badge).toHaveTextContent("42");
  });

  it("shows medium GI indicator when gi_estimate 56-69", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        nutrition: {
          ...makeProfile().nutrition,
          gi_estimate: 60,
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));
    const badge = screen.getByTestId("gi-badge");
    expect(badge).toHaveTextContent("Medium GI");
    expect(badge).toHaveTextContent("60");
  });

  it("shows high GI indicator when gi_estimate ≥ 70", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile({
        nutrition: {
          ...makeProfile().nutrition,
          gi_estimate: 85,
        },
      }),
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));
    const badge = screen.getByTestId("gi-badge");
    expect(badge).toHaveTextContent("High GI");
    expect(badge).toHaveTextContent("85");
  });

  it("hides GI indicator when gi_estimate is null", async () => {
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
    expect(screen.queryByTestId("gi-indicator")).not.toBeInTheDocument();
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

  // ── Breadcrumb navigation ──────────────────────────────────────────────

  it("renders breadcrumb link back to search", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("navigation", { name: "Breadcrumb" }),
      ).toBeInTheDocument();
    });
    const nav = screen.getByRole("navigation", { name: "Breadcrumb" });
    const searchLink = nav.querySelector('a[href="/app/search"]');
    expect(searchLink).toBeTruthy();
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
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });
    expect(screen.queryByText(/EAN:/)).not.toBeInTheDocument();
  });

  it("handles product without store availability", async () => {
    const p = makeProfile();
    p.product.store_availability = null;
    mockGetProductProfile.mockResolvedValue({ ok: true, data: p });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
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
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
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
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getByText(/No known allergens/)).toBeInTheDocument();
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

  // ── 4.1 Score interpretation ──────────────────────────────────────────

  it("renders score interpretation toggle button", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("What does this score mean?"),
      ).toBeInTheDocument();
    });
  });

  it("expands score interpretation on click with correct band text", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(), // score 65 → red band
    });
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("What does this score mean?"),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByText("What does this score mean?"));

    await waitFor(() => {
      expect(
        screen.getByTestId("score-interpretation-content"),
      ).toBeInTheDocument();
      expect(screen.getByText(/Poor nutritional profile/)).toBeInTheDocument();
    });
  });

  // ── 4.3 Eco-Score placeholder (feature-flagged) ────────────────────────

  it("hides eco-score placeholder when FEATURES.ECO_SCORE is false", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    // Wait for the page to fully render (allergens prove overview tab loaded)
    await waitFor(() => {
      expect(screen.getByText("Allergens")).toBeInTheDocument();
    });

    expect(screen.queryByText(/Environmental Impact/)).not.toBeInTheDocument();
    expect(
      screen.queryByText(/Eco-Score data coming soon/),
    ).not.toBeInTheDocument();
  });

  it("shows eco-score placeholder when FEATURES.ECO_SCORE is true", async () => {
    features.ECO_SCORE = true;
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/Environmental Impact/)).toBeInTheDocument();
    });
    expect(screen.getByText(/Eco-Score data coming soon/)).toBeInTheDocument();
  });

  // ── 4.5 Allergen distinction ──────────────────────────────────────────

  it("renders allergen 'Contains' label in matrix legend", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Contains")).toBeInTheDocument();
    });

    // AllergenMatrix renders contains allergens with red styling in a <table>
    const glutenCell = screen.getByText("Gluten");
    expect(glutenCell.closest("td")).toHaveClass("bg-error-bg");
  });

  it("renders allergen 'May contain traces' label in matrix legend", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("May contain traces")).toBeInTheDocument();
    });

    // AllergenMatrix renders traces allergens with amber styling in a <table>
    const soyCell = screen.getByText("Soy");
    expect(soyCell.closest("td")).toHaveClass("bg-warning-bg");
  });

  // ── Desktop split layout ─────────────────────────────────────────────────

  it("renders a 12-column grid wrapper for desktop split layout", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    // The grid wrapper should have the responsive grid classes
    const gridEl = document.querySelector(".lg\\:grid-cols-12");
    expect(gridEl).toBeInTheDocument();
    expect(gridEl).toHaveClass("lg:grid", "lg:grid-cols-12", "lg:gap-6");
  });

  it("renders left column with sticky positioning classes", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    const leftCol = document.querySelector(".lg\\:col-span-5");
    expect(leftCol).toBeInTheDocument();
    expect(leftCol).toHaveClass("lg:sticky", "lg:top-20", "lg:self-start");
  });

  it("renders right column spanning 7 columns", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    const rightCol = document.querySelector(".lg\\:col-span-7");
    expect(rightCol).toBeInTheDocument();
  });

  it("places tab bar inside the right column", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    const rightCol = document.querySelector(".lg\\:col-span-7");
    const tablist = screen.getByRole("tablist");
    expect(rightCol).toContainElement(tablist);
  });

  it("places header card inside the left column", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    const leftCol = document.querySelector(".lg\\:col-span-5");
    // Header card contains the brand name
    const brand = screen.getByText("TestBrand");
    expect(leftCol).toContainElement(brand);
  });

  it("renders nutrition table with thead on desktop", async () => {
    const user = userEvent.setup();
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    // Switch to nutrition tab
    const nutritionTab = screen.getByRole("tab", { name: /nutrition/i });
    await user.click(nutritionTab);

    // The table should have a thead element
    const table = document.querySelector("table");
    expect(table).toBeInTheDocument();
    const thead = table?.querySelector("thead");
    expect(thead).toBeInTheDocument();
  });

  it("renders ProductScoreHero with correct score", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getAllByText("Test Chips Original").length,
      ).toBeGreaterThanOrEqual(1);
    });

    // ProductScoreHero is now rendered with the unhealthiness score
    const hero = screen.getByTestId("product-score-hero");
    expect(hero).toBeInTheDocument();
    expect(hero.getAttribute("data-score")).toBe("65");
  });

  // ── #122 Single-instance rendering — no duplication on ANY tab ────────

  describe("single-instance rendering (issue #122)", () => {
    async function renderAndWait() {
      mockGetProductProfile.mockResolvedValue({
        ok: true,
        data: makeProfile(),
      });
      const user = userEvent.setup();
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getAllByText("Test Chips Original").length,
        ).toBeGreaterThanOrEqual(1);
      });

      return user;
    }

    function assertNoDuplication() {
      // Score interpretation renders exactly once
      const scoreInterpretation = screen.getAllByTestId("score-interpretation");
      expect(scoreInterpretation).toHaveLength(1);

      // Health warnings card renders exactly once
      const healthWarnings = screen.getAllByTestId("health-warnings-card");
      expect(healthWarnings).toHaveLength(1);

      // Tab bar renders exactly once
      const tabBars = screen.getAllByTestId("tab-bar");
      expect(tabBars).toHaveLength(1);

      // Tablist role renders exactly once
      const tablists = screen.getAllByRole("tablist");
      expect(tablists).toHaveLength(1);
    }

    it("renders each section exactly once on Overview tab (default)", async () => {
      await renderAndWait();
      assertNoDuplication();
    });

    it("renders each section exactly once on Nutrition tab", async () => {
      const user = await renderAndWait();
      await user.click(screen.getByRole("tab", { name: "Nutrition" }));
      assertNoDuplication();
    });

    it("renders each section exactly once on Alternatives tab", async () => {
      const user = await renderAndWait();
      await user.click(screen.getByRole("tab", { name: "Alternatives" }));
      assertNoDuplication();
    });

    it("renders each section exactly once on Scoring tab", async () => {
      const user = await renderAndWait();
      await user.click(screen.getByRole("tab", { name: "Scoring" }));
      assertNoDuplication();
    });

    it("maintains single instances when cycling through all tabs", async () => {
      const user = await renderAndWait();

      // Cycle: Overview → Nutrition → Alternatives → Scoring → Overview
      for (const tabName of [
        "Nutrition",
        "Alternatives",
        "Scoring",
        "Overview",
      ]) {
        await user.click(screen.getByRole("tab", { name: tabName }));
        assertNoDuplication();
      }
    });

    it("score-interpretation is inside the left column, not tab content", async () => {
      await renderAndWait();

      const leftCol = document.querySelector(".lg\\:col-span-5");
      const rightCol = document.querySelector(".lg\\:col-span-7");
      const scoreInterp = screen.getByTestId("score-interpretation");

      expect(leftCol).toContainElement(scoreInterp);
      expect(rightCol).not.toContainElement(scoreInterp);
    });

    it("health-warnings-card is inside the left column, not tab content", async () => {
      await renderAndWait();

      const leftCol = document.querySelector(".lg\\:col-span-5");
      const rightCol = document.querySelector(".lg\\:col-span-7");
      const healthWarnings = screen.getByTestId("health-warnings-card");

      expect(leftCol).toContainElement(healthWarnings);
      expect(rightCol).not.toContainElement(healthWarnings);
    });

    it("tab-bar is inside the right column, not the left column", async () => {
      await renderAndWait();

      const leftCol = document.querySelector(".lg\\:col-span-5");
      const rightCol = document.querySelector(".lg\\:col-span-7");
      const tabBar = screen.getByTestId("tab-bar");

      expect(rightCol).toContainElement(tabBar);
      expect(leftCol).not.toContainElement(tabBar);
    });
  });

  // ── Progressive disclosure (#576) ─────────────────────────────────────

  describe("progressive disclosure", () => {
    beforeEach(() => {
      // Clear full-analysis preference so tests start in summary mode
      localStorage.removeItem("tryvit:product-full-analysis");
      mockGetProductProfile.mockResolvedValue({
        ok: true,
        data: makeProfile(),
      });
    });

    it("shows quick summary by default when no localStorage preference", async () => {
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });

      expect(screen.queryByTestId("tab-bar")).not.toBeInTheDocument();
    });

    it("quick summary displays score interpretation text", async () => {
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });

      // Score is 65 → "red" band → scoreInterpretation.red key
      expect(screen.getByTestId("quick-summary")).toHaveTextContent(
        /Quick Summary/i,
      );
    });

    it("quick summary shows top alternatives preview", async () => {
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getByTestId("quick-summary-alternatives"),
        ).toBeInTheDocument();
      });

      expect(
        screen.getByTestId("quick-summary-alternatives"),
      ).toHaveTextContent(/Healthy Veggie Sticks/);
    });

    it("clicking 'Show full analysis' reveals tab bar and hides summary", async () => {
      const user = userEvent.setup();
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("toggle-analysis"));

      await waitFor(() => {
        expect(screen.getByTestId("tab-bar")).toBeInTheDocument();
      });
      expect(screen.queryByTestId("quick-summary")).not.toBeInTheDocument();
    });

    it("clicking 'Show summary' collapses back to quick summary", async () => {
      const user = userEvent.setup();
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      // Expand first
      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });
      await user.click(screen.getByTestId("toggle-analysis"));

      await waitFor(() => {
        expect(screen.getByTestId("tab-bar")).toBeInTheDocument();
      });

      // Collapse back
      await user.click(screen.getByTestId("toggle-analysis"));

      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });
      expect(screen.queryByTestId("tab-bar")).not.toBeInTheDocument();
    });

    it("persists full-analysis preference to localStorage", async () => {
      const user = userEvent.setup();
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("quick-summary")).toBeInTheDocument();
      });

      await user.click(screen.getByTestId("toggle-analysis"));

      await waitFor(() => {
        expect(screen.getByTestId("tab-bar")).toBeInTheDocument();
      });

      expect(localStorage.getItem("tryvit:product-full-analysis")).toBe(
        "true",
      );
    });

    it("respects stored full-analysis preference on mount", async () => {
      localStorage.setItem("tryvit:product-full-analysis", "true");
      render(<ProductDetailPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("tab-bar")).toBeInTheDocument();
      });

      expect(screen.queryByTestId("quick-summary")).not.toBeInTheDocument();
    });
  });

  // ── Responsive tab labels ───────────────────────────────────────────────

  it("tab buttons have aria-label for accessibility", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toBeInTheDocument();
    });

    const tabs = screen.getAllByRole("tab");
    expect(tabs).toHaveLength(4);
    expect(tabs[0]).toHaveAttribute("aria-label", "Overview");
    expect(tabs[1]).toHaveAttribute("aria-label", "Nutrition");
    expect(tabs[2]).toHaveAttribute("aria-label", "Alternatives");
    expect(tabs[3]).toHaveAttribute("aria-label", "Scoring");
  });

  // ── Swipe gesture navigation ────────────────────────────────────────────

  it("renders swipeable tab content container", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("tab-content")).toBeInTheDocument();
    });
  });

  it("swipe left advances to next tab", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });

    const container = screen.getByTestId("tab-content");

    // Simulate swipe left (positive diff = next tab)
    act(() => {
      container.dispatchEvent(
        new TouchEvent("touchstart", {
          bubbles: true,
          touches: [{ clientX: 200 } as Touch],
        }),
      );
      container.dispatchEvent(
        new TouchEvent("touchend", {
          bubbles: true,
          changedTouches: [{ clientX: 100 } as Touch],
        }),
      );
    });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Nutrition" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });
  });

  it("swipe right goes to previous tab", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    // First navigate to Nutrition tab via click
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Nutrition" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Nutrition" }));

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Nutrition" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });

    const container = screen.getByTestId("tab-content");

    // Simulate swipe right (negative diff = previous tab)
    act(() => {
      container.dispatchEvent(
        new TouchEvent("touchstart", {
          bubbles: true,
          touches: [{ clientX: 100 } as Touch],
        }),
      );
      container.dispatchEvent(
        new TouchEvent("touchend", {
          bubbles: true,
          changedTouches: [{ clientX: 200 } as Touch],
        }),
      );
    });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });
  });

  it("small swipe does not change tab", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });

    const container = screen.getByTestId("tab-content");

    // Swipe under threshold (< 50px)
    act(() => {
      container.dispatchEvent(
        new TouchEvent("touchstart", {
          bubbles: true,
          touches: [{ clientX: 200 } as Touch],
        }),
      );
      container.dispatchEvent(
        new TouchEvent("touchend", {
          bubbles: true,
          changedTouches: [{ clientX: 180 } as Touch],
        }),
      );
    });

    // Should still be on Overview
    expect(screen.getByRole("tab", { name: "Overview" })).toHaveAttribute(
      "aria-selected",
      "true",
    );
  });

  it("swipe left on last tab stays on last tab", async () => {
    mockGetProductProfile.mockResolvedValue({
      ok: true,
      data: makeProfile(),
    });
    localStorage.setItem("tryvit:product-full-analysis", "true");
    const user = userEvent.setup();
    render(<ProductDetailPage />, { wrapper: createWrapper() });

    // Navigate to Scoring (last tab)
    await waitFor(() => {
      expect(
        screen.getByRole("tab", { name: "Scoring" }),
      ).toBeInTheDocument();
    });
    await user.click(screen.getByRole("tab", { name: "Scoring" }));

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });

    const container = screen.getByTestId("tab-content");

    // Swipe left again — should stay on Scoring
    act(() => {
      container.dispatchEvent(
        new TouchEvent("touchstart", {
          bubbles: true,
          touches: [{ clientX: 200 } as Touch],
        }),
      );
      container.dispatchEvent(
        new TouchEvent("touchend", {
          bubbles: true,
          changedTouches: [{ clientX: 100 } as Touch],
        }),
      );
    });

    await waitFor(() => {
      expect(screen.getByRole("tab", { name: "Scoring" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    });
  });
});
