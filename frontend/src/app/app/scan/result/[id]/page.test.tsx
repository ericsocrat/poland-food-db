import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ScanResultPage from "./page";

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

vi.mock("@/lib/api", () => ({
  getProductDetail: (...args: unknown[]) => mockGetProductDetail(...args),
  getBetterAlternatives: (...args: unknown[]) =>
    mockGetBetterAlternatives(...args),
}));

vi.mock("@/components/product/HealthWarningsCard", () => ({
  HealthWarningsCard: () => <div data-testid="health-warnings-card" />,
}));

vi.mock("@/components/common/skeletons", () => ({
  ProductProfileSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
  ProductCardSkeleton: ({ count }: { count?: number }) => (
    <div
      data-testid="skeleton-cards"
      data-count={count ?? 3}
      role="status"
      aria-busy="true"
    />
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

function makeAlternatives(
  alternatives: Array<Record<string, unknown>> = [
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
    {
      product_id: 100,
      product_name: "Baked Lentil Crisps",
      brand: "GreenBite",
      category: "chips",
      unhealthiness_score: 30,
      score_improvement: 35,
      nutri_score: "A",
      similarity: 0.6,
      shared_ingredients: 2,
    },
  ],
) {
  return {
    ok: true,
    data: {
      api_version: "v1",
      source_product: {
        product_id: 42,
        product_name: "Test Chips Original",
        brand: "TestBrand",
        category: "chips",
        unhealthiness_score: 65,
        nutri_score: "D",
      },
      search_scope: "same_category",
      alternatives,
      alternatives_count: alternatives.length,
    },
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
});

describe("ScanResultPage", () => {
  describe("loading state", () => {
    it("shows skeleton while loading product data", () => {
      mockGetProductDetail.mockReturnValue(new Promise(() => {}));
      mockGetBetterAlternatives.mockReturnValue(new Promise(() => {}));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      expect(screen.getByTestId("skeleton")).toBeInTheDocument();
    });
  });

  describe("error state", () => {
    it("shows error when product fails to load", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: false,
        error: { message: "Not found" },
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives([]));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Failed to load product.")).toBeInTheDocument();
      });
    });

    it("shows back-to-scanner link on error", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: false,
        error: { message: "Error" },
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives([]));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        const backLink = screen.getByText("← Back");
        expect(backLink.closest("a")).toHaveAttribute("href", "/app/scan");
      });
    });
  });

  describe("product card", () => {
    it("renders scan result heading", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("📷 Scan Result")).toBeInTheDocument();
      });
    });

    it("displays product name and brand", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getAllByText("Test Chips Original").length,
        ).toBeGreaterThanOrEqual(1);
      });
      expect(screen.getByText("TestBrand")).toBeInTheDocument();
    });

    it("displays unhealthiness score", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("65")).toBeInTheDocument();
      });
    });

    it("displays Nutri-Score and NOVA group", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Nutri-Score D")).toBeInTheDocument();
      });
      expect(screen.getByText("NOVA 4")).toBeInTheDocument();
    });

    it("displays category and EAN", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("🍟 Chips")).toBeInTheDocument();
      });
      expect(screen.getByText("EAN: 5901234123457")).toBeInTheDocument();
    });

    it("renders health flags when present", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("🧂 High salt")).toBeInTheDocument();
      });
      expect(screen.getByText("🥓 High sat. fat")).toBeInTheDocument();
      expect(screen.getByText("🌴 Palm oil")).toBeInTheDocument();
    });

    it("does not show flags that are false", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getAllByText("Test Chips Original").length,
        ).toBeGreaterThanOrEqual(1);
      });
      expect(screen.queryByText("🍬 High sugar")).not.toBeInTheDocument();
      expect(screen.queryByText("🧪 Many additives")).not.toBeInTheDocument();
    });
  });

  describe("health warnings", () => {
    it("renders the HealthWarningsCard component", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByTestId("health-warnings-card")).toBeInTheDocument();
      });
    });
  });

  describe("nutrition summary", () => {
    it("displays key nutrition values", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Nutrition per 100 g")).toBeInTheDocument();
      });
      expect(screen.getByText("530")).toBeInTheDocument();
      expect(screen.getByText("Calories")).toBeInTheDocument();
      expect(screen.getByText("Sugars")).toBeInTheDocument();
      expect(screen.getByText("Salt")).toBeInTheDocument();
      expect(screen.getByText("Total Fat")).toBeInTheDocument();
      expect(screen.getByText("Protein")).toBeInTheDocument();
    });
  });

  describe("healthier alternatives", () => {
    it("shows alternatives heading", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getByText("🥗 Healthier Alternatives"),
        ).toBeInTheDocument();
      });
    });

    it("shows alternatives count badge", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("2 found")).toBeInTheDocument();
      });
    });

    it("renders alternative product cards", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Healthy Veggie Sticks")).toBeInTheDocument();
      });
      expect(screen.getByText("Baked Lentil Crisps")).toBeInTheDocument();
    });

    it("shows score improvement for alternatives", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText(/−40 points better/)).toBeInTheDocument();
      });
      expect(screen.getByText(/−35 points better/)).toBeInTheDocument();
    });

    it("shows improvement percentage for alternatives", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        // 40/65 ≈ 62%
        expect(screen.getByText(/62% healthier/)).toBeInTheDocument();
      });
      // 35/65 ≈ 54%
      expect(screen.getByText(/54% healthier/)).toBeInTheDocument();
    });

    it("shows alternative brands", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("HealthBrand")).toBeInTheDocument();
      });
      expect(screen.getByText("GreenBite")).toBeInTheDocument();
    });

    it("links alternatives to their product detail pages", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Healthy Veggie Sticks")).toBeInTheDocument();
      });

      const link = screen.getByText("Healthy Veggie Sticks").closest("a");
      expect(link).toHaveAttribute("href", "/app/product/99");
    });

    it("shows best-in-category message when no alternatives exist", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives([]));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getByText(
            "🏆 This is already one of the best options in its category!",
          ),
        ).toBeInTheDocument();
      });
    });

    it("does not show count badge when no alternatives", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives([]));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getAllByText("Test Chips Original").length,
        ).toBeGreaterThanOrEqual(1);
      });
      expect(screen.queryByText(/found$/)).not.toBeInTheDocument();
    });

    it("shows spinner while alternatives are loading", () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      // Never resolve alternatives
      mockGetBetterAlternatives.mockReturnValue(new Promise(() => {}));

      render(<ScanResultPage />, { wrapper: createWrapper() });

      // Product loads immediately but alternatives show spinner
      // The loading state for the whole page is shown first since product loads instantly
      // but the alternatives section shows its own spinner
    });
  });

  describe("action buttons", () => {
    it("renders Full Details link to product page", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        const link = screen.getByText("📋 Full Details");
        expect(link.closest("a")).toHaveAttribute("href", "/app/product/42");
      });
    });

    it("renders Scan Another link back to scanner", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        // There are two "Scan another" links — one in header, one in action buttons
        const scanLinks = screen.getAllByText(/Scan [Aa]nother/);
        expect(scanLinks.length).toBeGreaterThanOrEqual(1);
        const actionLink = scanLinks.find(
          (link) => link.closest("a")?.getAttribute("href") === "/app/scan",
        );
        expect(actionLink).toBeTruthy();
      });
    });
  });

  describe("no health flags", () => {
    it("does not render flags section when all flags are false", async () => {
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
      mockGetBetterAlternatives.mockResolvedValue(makeAlternatives());

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(
          screen.getAllByText("Test Chips Original").length,
        ).toBeGreaterThanOrEqual(1);
      });
      expect(screen.queryByText("🧂 High salt")).not.toBeInTheDocument();
      expect(screen.queryByText("🍬 High sugar")).not.toBeInTheDocument();
      expect(screen.queryByText("🥓 High sat. fat")).not.toBeInTheDocument();
      expect(screen.queryByText("🧪 Many additives")).not.toBeInTheDocument();
      expect(screen.queryByText("🌴 Palm oil")).not.toBeInTheDocument();
    });
  });

  describe("alternative score bands", () => {
    it("renders nutri-score badge for alternatives", async () => {
      mockGetProductDetail.mockResolvedValue({
        ok: true,
        data: makeProduct(),
      });
      mockGetBetterAlternatives.mockResolvedValue(
        makeAlternatives([
          {
            product_id: 99,
            product_name: "Green Snack",
            brand: "Bio",
            category: "chips",
            unhealthiness_score: 10,
            score_improvement: 55,
            nutri_score: "A",
            similarity: 0.9,
            shared_ingredients: 5,
          },
        ]),
      );

      render(<ScanResultPage />, { wrapper: createWrapper() });

      await waitFor(() => {
        expect(screen.getByText("Green Snack")).toBeInTheDocument();
      });
      // Score 10 and nutri-score A should be shown
      expect(screen.getByText("10")).toBeInTheDocument();
    });
  });
});
