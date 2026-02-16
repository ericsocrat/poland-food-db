import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ComparisonGrid } from "./ComparisonGrid";
import type { CompareProduct } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/components/product/AvoidBadge", () => ({
  AvoidBadge: ({ productId }: { productId: number }) => (
    <span data-testid={`avoid-badge-${productId}`}>avoid</span>
  ),
}));

// ─── Fixtures ───────────────────────────────────────────────────────────────

const makeProduct = (
  overrides: Partial<CompareProduct> = {},
): CompareProduct => ({
  product_id: 1,
  ean: "1234567890123",
  product_name: "Product A",
  brand: "Brand A",
  category: "chips",
  category_display: "Chips",
  category_icon: "🍟",
  unhealthiness_score: 35,
  score_band: "moderate",
  nutri_score: "C",
  nova_group: "3",
  processing_risk: "moderate",
  calories: 500,
  total_fat_g: 25,
  saturated_fat_g: 10,
  trans_fat_g: 0.5,
  carbs_g: 55,
  sugars_g: 5,
  fibre_g: 3,
  protein_g: 7,
  salt_g: 1.2,
  high_salt: true,
  high_sugar: false,
  high_sat_fat: false,
  high_additive_load: false,
  additives_count: 3,
  ingredient_count: 12,
  allergen_count: 2,
  allergen_tags: "en:gluten, en:milk",
  trace_tags: null,
  confidence: "high",
  data_completeness_pct: 85,
  ...overrides,
});

const productA = makeProduct();

const productB = makeProduct({
  product_id: 2,
  product_name: "Product B",
  brand: "Brand B",
  unhealthiness_score: 60,
  score_band: "high",
  nutri_score: "D",
  nova_group: "4",
  calories: 600,
  total_fat_g: 30,
  saturated_fat_g: 15,
  sugars_g: 20,
  salt_g: 2.5,
  fibre_g: 1,
  protein_g: 4,
  high_salt: true,
  high_sugar: true,
  high_sat_fat: true,
  high_additive_load: true,
  additives_count: 8,
  allergen_count: 0,
  allergen_tags: null,
});

const products = [productA, productB];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ComparisonGrid", () => {
  it("shows empty state with fewer than 2 products", () => {
    render(<ComparisonGrid products={[productA]} />);
    expect(
      screen.getByText("Select at least 2 products to compare"),
    ).toBeInTheDocument();
  });

  it("shows empty state with 0 products", () => {
    render(<ComparisonGrid products={[]} />);
    expect(
      screen.getByText("Select at least 2 products to compare"),
    ).toBeInTheDocument();
  });

  // Desktop + Mobile rendering (dual-render → getAllBy*)
  it("renders product names", () => {
    render(<ComparisonGrid products={products} />);
    // Appears in both desktop and mobile
    const nameA = screen.getAllByText("Product A");
    expect(nameA.length).toBeGreaterThanOrEqual(1);
    const nameB = screen.getAllByText("Product B");
    expect(nameB.length).toBeGreaterThanOrEqual(1);
  });

  it("renders brand names", () => {
    render(<ComparisonGrid products={products} />);
    const brands = screen.getAllByText("Brand A");
    expect(brands.length).toBeGreaterThanOrEqual(1);
  });

  it("renders unhealthiness scores", () => {
    render(<ComparisonGrid products={products} />);
    const scores35 = screen.getAllByText("35");
    expect(scores35.length).toBeGreaterThanOrEqual(1);
    const scores60 = screen.getAllByText("60");
    expect(scores60.length).toBeGreaterThanOrEqual(1);
  });

  it("shows winner badge for healthiest product", () => {
    render(<ComparisonGrid products={products} />);
    // Product A (35) is healthier → gets 🏆 Healthiest on desktop
    const badges = screen.getAllByText(/Healthiest/);
    expect(badges.length).toBeGreaterThanOrEqual(1);
  });

  it("renders Metric header on desktop", () => {
    render(<ComparisonGrid products={products} />);
    expect(screen.getByText("Metric")).toBeInTheDocument();
  });

  it("renders all comparison row labels", () => {
    render(<ComparisonGrid products={products} />);
    const rowLabels = [
      "Unhealthiness Score",
      "Nutri-Score",
      "NOVA Group",
      "Calories",
      "Total Fat",
      "Saturated Fat",
      "Sugars",
      "Salt",
      "Fibre",
      "Protein",
      "Carbs",
      "Additives",
      "Allergens",
    ];
    for (const label of rowLabels) {
      // Desktop has them all; mobile filters out nutri_score and nova_group
      const matches = screen.getAllByText(label);
      expect(matches.length).toBeGreaterThanOrEqual(1);
    }
  });

  it("renders formatted nutrition values", () => {
    render(<ComparisonGrid products={products} />);
    // Calories for Product A = 500 kcal
    const cals = screen.getAllByText("500 kcal");
    expect(cals.length).toBeGreaterThanOrEqual(1);
  });

  it("renders allergen tags row", () => {
    render(<ComparisonGrid products={products} />);
    // Product A has "en:gluten, en:milk" → stripped to "gluten, milk"
    const tags = screen.getAllByText("gluten, milk");
    expect(tags.length).toBeGreaterThanOrEqual(1);
    // Product B has no allergens
    const noneText = screen.getAllByText(/None/);
    expect(noneText.length).toBeGreaterThanOrEqual(1);
  });

  it("renders warnings row", () => {
    render(<ComparisonGrid products={products} />);
    // Product A has high_salt only
    const highSalt = screen.getAllByText(/High Salt/);
    expect(highSalt.length).toBeGreaterThanOrEqual(1);
    // Product B has all flags
    const highSugar = screen.getAllByText(/High Sugar/);
    expect(highSugar.length).toBeGreaterThanOrEqual(1);
  });

  it("shows nutri-score labels", () => {
    render(<ComparisonGrid products={products} />);
    const cLabels = screen.getAllByText("C");
    expect(cLabels.length).toBeGreaterThanOrEqual(1);
    const dLabels = screen.getAllByText("D");
    expect(dLabels.length).toBeGreaterThanOrEqual(1);
  });

  it("shows NOVA group labels", () => {
    render(<ComparisonGrid products={products} />);
    const n3 = screen.getAllByText(/N3/);
    expect(n3.length).toBeGreaterThanOrEqual(1);
    const n4 = screen.getAllByText(/N4/);
    expect(n4.length).toBeGreaterThanOrEqual(1);
  });

  it("renders swipe hint on mobile view", () => {
    render(<ComparisonGrid products={products} />);
    expect(screen.getByText(/Swipe to compare/)).toBeInTheDocument();
  });

  it("renders dots indicator for mobile", () => {
    const { container } = render(<ComparisonGrid products={products} />);
    // dots are small spans with rounded-full class
    const dots = container.querySelectorAll(String.raw`.rounded-full.h-1\.5.w-1\.5`);
    expect(dots.length).toBe(2); // 2 products = 2 dots
  });

  it("renders avoid badges when showAvoidBadge is true", () => {
    render(<ComparisonGrid products={products} showAvoidBadge={true} />);
    expect(
      screen.getAllByTestId("avoid-badge-1").length,
    ).toBeGreaterThanOrEqual(1);
    expect(
      screen.getAllByTestId("avoid-badge-2").length,
    ).toBeGreaterThanOrEqual(1);
  });

  it("does not render avoid badges by default", () => {
    render(<ComparisonGrid products={products} />);
    expect(screen.queryByTestId("avoid-badge-1")).not.toBeInTheDocument();
    expect(screen.queryByTestId("avoid-badge-2")).not.toBeInTheDocument();
  });

  it("renders with three products", () => {
    const productC = makeProduct({
      product_id: 3,
      product_name: "Product C",
      brand: "Brand C",
      unhealthiness_score: 15,
      score_band: "low",
      nutri_score: "A",
    });
    render(<ComparisonGrid products={[productA, productB, productC]} />);
    const nameC = screen.getAllByText("Product C");
    expect(nameC.length).toBeGreaterThanOrEqual(1);
    // Product C (15) is healthiest
    const badges = screen.getAllByText(/Healthiest/);
    expect(badges.length).toBeGreaterThanOrEqual(1);
  });
});
