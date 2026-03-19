import type { RecentlyViewedProduct } from "@/lib/types";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { HealthSummary } from "./HealthSummary";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, unknown>) => {
      const map: Record<string, string> = {
        "dashboard.healthSummaryTitle": "Health Summary",
        "dashboard.healthSummaryAvg": "Avg. TryVit Score",
        "dashboard.healthSummaryNoData": "Scan or browse products to see your health summary.",
        "score.excellent": "Excellent",
        "score.good": "Good",
        "score.moderate": "Moderate",
        "score.poor": "Poor",
        "score.bad": "Bad",
        "scoreBand.excellent": "Excellent",
        "scoreBand.good": "Good",
        "scoreBand.moderate": "Moderate",
        "scoreBand.poor": "Poor",
        "scoreBand.bad": "Bad",
      };
      if (key === "dashboard.healthSummaryProducts" && params) {
        return `across ${params.count} products`;
      }
      return map[key] ?? key;
    },
  }),
}));

vi.mock("@/components/product/ScoreGauge", () => ({
  ScoreGauge: ({ score }: { score: number }) => (
    <div data-testid="score-gauge-mock">{100 - score}</div>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeProduct(overrides: Partial<RecentlyViewedProduct> = {}): RecentlyViewedProduct {
  return {
    product_id: 1,
    product_name: "Test Product",
    brand: "Brand",
    category: "chips",
    country: "PL",
    unhealthiness_score: 40,
    nutri_score_label: "C",
    viewed_at: new Date().toISOString(),
    image_thumb_url: null,
    ...overrides,
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HealthSummary", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows empty state when no scored products", () => {
    render(<HealthSummary products={[]} />);
    expect(screen.getByText("Scan or browse products to see your health summary.")).toBeInTheDocument();
  });

  it("shows empty state when all products have null scores", () => {
    const products = [makeProduct({ unhealthiness_score: null })];
    render(<HealthSummary products={products} />);
    expect(screen.getByText(/Scan or browse/)).toBeInTheDocument();
  });

  it("renders ScoreGauge with TryVit score", () => {
    // unhealthiness 40 → TryVit 60
    const products = [makeProduct({ unhealthiness_score: 40 })];
    render(<HealthSummary products={products} />);

    const gauge = screen.getByTestId("health-score-gauge");
    expect(gauge).toBeInTheDocument();
    // ScoreGauge mock renders 100 - score = TryVit score
    expect(screen.getByTestId("score-gauge-mock").textContent).toBe("60");
  });

  it("computes average across multiple products", () => {
    // avg unhealthiness = (20 + 60) / 2 = 40 → TryVit 60
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 20 }),
      makeProduct({ product_id: 2, unhealthiness_score: 60 }),
    ];
    render(<HealthSummary products={products} />);

    expect(screen.getByTestId("score-gauge-mock").textContent).toBe("60");
  });

  it("shows product count", () => {
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 30 }),
      makeProduct({ product_id: 2, unhealthiness_score: 50 }),
      makeProduct({ product_id: 3, unhealthiness_score: 70 }),
    ];
    render(<HealthSummary products={products} />);
    expect(screen.getByText("across 3 products")).toBeInTheDocument();
  });

  it("renders distribution bar", () => {
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 10 }), // green
      makeProduct({ product_id: 2, unhealthiness_score: 30 }), // yellow
      makeProduct({ product_id: 3, unhealthiness_score: 50 }), // orange
    ];
    render(<HealthSummary products={products} />);

    const bar = screen.getByTestId("health-distribution-bar");
    expect(bar).toBeInTheDocument();
    // 3 products in 3 different bands → 3 segments
    expect(bar.children).toHaveLength(3);
  });

  it("skips empty bands in distribution bar", () => {
    // All products in green band (unhealthiness ≤ 20)
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 5 }),
      makeProduct({ product_id: 2, unhealthiness_score: 15 }),
    ];
    render(<HealthSummary products={products} />);

    const bar = screen.getByTestId("health-distribution-bar");
    // Only 1 band segment (green)
    expect(bar.children).toHaveLength(1);
  });

  it("applies rounded corners to first and last distribution bar segments", () => {
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 10 }), // green
      makeProduct({ product_id: 2, unhealthiness_score: 30 }), // yellow
      makeProduct({ product_id: 3, unhealthiness_score: 50 }), // orange
    ];
    render(<HealthSummary products={products} />);

    const bar = screen.getByTestId("health-distribution-bar");
    const firstSegment = bar.children[0] as HTMLElement;
    const lastSegment = bar.children[bar.children.length - 1] as HTMLElement;

    expect(firstSegment.className).toContain("first:rounded-l-full");
    expect(lastSegment.className).toContain("last:rounded-r-full");
  });

  it("has correct aria-label on section", () => {
    const products = [makeProduct({ unhealthiness_score: 30 })];
    render(<HealthSummary products={products} />);
    expect(screen.getByLabelText("Health Summary")).toBeInTheDocument();
  });

  it("filters null-scored products from calculations", () => {
    // Only the scored product counts: unhealthiness 20 → TryVit 80
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 20 }),
      makeProduct({ product_id: 2, unhealthiness_score: null }),
    ];
    render(<HealthSummary products={products} />);

    expect(screen.getByTestId("score-gauge-mock").textContent).toBe("80");
    expect(screen.getByText("across 1 products")).toBeInTheDocument();
  });

  it("renders distribution legend with band labels and counts", () => {
    const products = [
      makeProduct({ product_id: 1, unhealthiness_score: 10 }), // green
      makeProduct({ product_id: 2, unhealthiness_score: 30 }), // yellow
      makeProduct({ product_id: 3, unhealthiness_score: 50 }), // orange
    ];
    render(<HealthSummary products={products} />);

    const legend = screen.getByTestId("health-distribution-legend");
    expect(legend).toBeInTheDocument();
    expect(legend.textContent).toContain("Excellent (1)");
    expect(legend.textContent).toContain("Good (1)");
    expect(legend.textContent).toContain("Moderate (1)");
  });

  it("wraps gauge in scale-in animation", () => {
    const products = [makeProduct({ unhealthiness_score: 30 })];
    render(<HealthSummary products={products} />);

    const gaugeWrapper = screen.getByTestId("health-score-gauge");
    expect(gaugeWrapper.className).toContain("animate-scale-in");
  });
});
