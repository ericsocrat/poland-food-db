import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { NovaDistributionChart } from "./NovaDistribution";
import { AllergenAlert } from "./AllergenAlert";
import { CategoryDiversity } from "./CategoryDiversity";
import { HealthInsightsSummary } from "./HealthInsightsSummary";
import { RecentComparisons } from "./RecentComparisons";
import { getSeasonKey } from "./DashboardGreeting";
import { translate } from "@/lib/i18n";
import type {
  NovaDistribution,
  DashboardAllergenAlerts,
  DashboardCategoryDiversity,
  DashboardRecentComparison,
} from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

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

// ─── NovaDistributionChart ──────────────────────────────────────────────────

describe("NovaDistributionChart", () => {
  const distribution: NovaDistribution = { "1": 5, "2": 3, "3": 2, "4": 1 };

  it("renders an SVG bar chart", () => {
    render(<NovaDistributionChart distribution={distribution} />);
    expect(screen.getByTestId("nova-distribution")).toBeInTheDocument();
    expect(screen.getByRole("img")).toBeInTheDocument();
  });

  it("renders 4 bars for NOVA groups", () => {
    render(<NovaDistributionChart distribution={distribution} />);
    expect(screen.getByTestId("nova-bar-1")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-2")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-3")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-4")).toBeInTheDocument();
  });

  it("renders bars with proportional heights", () => {
    render(<NovaDistributionChart distribution={distribution} />);
    const bar1 = screen.getByTestId("nova-bar-1");
    const bar4 = screen.getByTestId("nova-bar-4");
    // NOVA 1 has 5 (max) → full height, NOVA 4 has 1 → 1/5 height
    expect(Number(bar1.getAttribute("height"))).toBeGreaterThan(
      Number(bar4.getAttribute("height")),
    );
  });

  it("returns null when all counts are zero", () => {
    const empty: NovaDistribution = {};
    const { container } = render(
      <NovaDistributionChart distribution={empty} />,
    );
    expect(
      container.querySelector('[data-testid="nova-distribution"]'),
    ).not.toBeInTheDocument();
  });

  it("shows percentage labels", () => {
    // Total = 11: NOVA1 = 5/11 ≈ 45%, NOVA4 = 1/11 ≈ 9%
    render(<NovaDistributionChart distribution={distribution} />);
    expect(screen.getByText("45%")).toBeInTheDocument();
    expect(screen.getByText("9%")).toBeInTheDocument();
  });

  it("shows legend with counts", () => {
    render(<NovaDistributionChart distribution={distribution} />);
    expect(screen.getByText(/Unprocessed \(5\)/)).toBeInTheDocument();
    expect(screen.getByText(/Ultra-processed \(1\)/)).toBeInTheDocument();
  });

  it("has accessible aria-label on SVG", () => {
    render(<NovaDistributionChart distribution={distribution} />);
    const svg = screen.getByRole("img");
    expect(svg).toHaveAttribute("aria-label");
  });
});

// ─── AllergenAlert ──────────────────────────────────────────────────────────

describe("AllergenAlert", () => {
  const alertData: DashboardAllergenAlerts = {
    count: 3,
    products: [
      { product_id: 1, product_name: "Product A", allergen: "en:milk" },
      { product_id: 2, product_name: "Product B", allergen: "en:gluten" },
      { product_id: 3, product_name: "Product C", allergen: "en:milk" },
    ],
  };

  it("renders alert when count > 0", () => {
    render(<AllergenAlert alerts={alertData} />);
    expect(screen.getByTestId("allergen-alert")).toBeInTheDocument();
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("shows allergen count in message", () => {
    render(<AllergenAlert alerts={alertData} />);
    expect(screen.getByText(/3 product/)).toBeInTheDocument();
  });

  it("deduplicates allergen names", () => {
    render(<AllergenAlert alerts={alertData} />);
    // "milk" should appear once, with "gluten"
    expect(screen.getByText(/milk, gluten/)).toBeInTheDocument();
  });

  it("renders review link to /app/lists", () => {
    render(<AllergenAlert alerts={alertData} />);
    const link = screen.getByText(/Review/);
    expect(link.closest("a")).toHaveAttribute("href", "/app/lists");
  });

  it("returns null when count is 0", () => {
    const empty: DashboardAllergenAlerts = { count: 0, products: [] };
    const { container } = render(<AllergenAlert alerts={empty} />);
    expect(
      container.querySelector('[data-testid="allergen-alert"]'),
    ).not.toBeInTheDocument();
  });
});

// ─── CategoryDiversity ──────────────────────────────────────────────────────

describe("CategoryDiversity", () => {
  const diversity: DashboardCategoryDiversity = { explored: 8, total: 20 };

  it("renders progress bar and count", () => {
    render(<CategoryDiversity diversity={diversity} />);
    expect(screen.getByTestId("category-diversity")).toBeInTheDocument();
    expect(screen.getByText("8/20")).toBeInTheDocument();
  });

  it("renders progress bar with correct aria values", () => {
    render(<CategoryDiversity diversity={diversity} />);
    const bar = screen.getByRole("progressbar");
    expect(bar).toHaveAttribute("aria-valuenow", "8");
    expect(bar).toHaveAttribute("aria-valuemax", "20");
  });

  it("shows 'Discover more' link when not all explored", () => {
    render(<CategoryDiversity diversity={diversity} />);
    const link = screen.getByText(/Discover more/);
    expect(link.closest("a")).toHaveAttribute("href", "/app/categories");
  });

  it("hides 'Discover more' link when all explored", () => {
    render(<CategoryDiversity diversity={{ explored: 20, total: 20 }} />);
    expect(screen.queryByText(/Discover more/)).not.toBeInTheDocument();
  });

  it("returns null when explored is 0", () => {
    const { container } = render(
      <CategoryDiversity diversity={{ explored: 0, total: 20 }} />,
    );
    expect(
      container.querySelector('[data-testid="category-diversity"]'),
    ).not.toBeInTheDocument();
  });
});

// ─── HealthInsightsSummary ──────────────────────────────────────────────────

describe("HealthInsightsSummary", () => {
  it("renders average score circle", () => {
    render(<HealthInsightsSummary avgScore={35} scoreTrend="stable" />);
    expect(screen.getByTestId("health-insights-summary")).toBeInTheDocument();
    expect(screen.getByTestId("avg-score-circle")).toBeInTheDocument();
    expect(screen.getByText("35")).toBeInTheDocument();
  });

  it("renders score band label for low score", () => {
    render(<HealthInsightsSummary avgScore={15} scoreTrend="improving" />);
    expect(screen.getByText(/Low risk/)).toBeInTheDocument();
  });

  it("renders score band label for high score", () => {
    render(<HealthInsightsSummary avgScore={65} scoreTrend="worsening" />);
    expect(screen.getByText(/High/)).toBeInTheDocument();
  });

  it("renders improving trend text", () => {
    render(<HealthInsightsSummary avgScore={25} scoreTrend="improving" />);
    expect(screen.getByText(/Trending healthier/)).toBeInTheDocument();
  });

  it("renders worsening trend text", () => {
    render(<HealthInsightsSummary avgScore={50} scoreTrend="worsening" />);
    expect(screen.getByText(/Trending less healthy/)).toBeInTheDocument();
  });

  it("renders stable trend text", () => {
    render(<HealthInsightsSummary avgScore={50} scoreTrend="stable" />);
    expect(screen.getByText(/Stable/)).toBeInTheDocument();
  });
});

// ─── RecentComparisons ──────────────────────────────────────────────────────

describe("RecentComparisons", () => {
  const comparisons: DashboardRecentComparison[] = [
    {
      id: "abc-123",
      title: "Chips showdown",
      product_count: 3,
      created_at: "2025-01-15T12:00:00Z",
    },
    {
      id: "def-456",
      title: null,
      product_count: 2,
      created_at: "2025-01-14T12:00:00Z",
    },
  ];

  it("renders comparison cards", () => {
    render(<RecentComparisons comparisons={comparisons} />);
    expect(screen.getByTestId("recent-comparisons")).toBeInTheDocument();
    expect(screen.getByText("Chips showdown")).toBeInTheDocument();
  });

  it("shows 'Untitled comparison' for null titles", () => {
    render(<RecentComparisons comparisons={comparisons} />);
    expect(screen.getByText("Untitled comparison")).toBeInTheDocument();
  });

  it("shows product count", () => {
    render(<RecentComparisons comparisons={comparisons} />);
    expect(screen.getByText(/3 products/)).toBeInTheDocument();
    expect(screen.getByText(/2 products/)).toBeInTheDocument();
  });

  it("links to comparisons page", () => {
    render(<RecentComparisons comparisons={comparisons} />);
    const links = screen.getAllByRole("link");
    const compareLink = links.find((l) =>
      l.getAttribute("href")?.includes("compare"),
    );
    expect(compareLink).toBeDefined();
  });

  it("returns null for empty array", () => {
    const { container } = render(<RecentComparisons comparisons={[]} />);
    expect(
      container.querySelector('[data-testid="recent-comparisons"]'),
    ).not.toBeInTheDocument();
  });
});

// ─── getSeasonKey ───────────────────────────────────────────────────────────

describe("getSeasonKey", () => {
  it("returns 'spring' for March (month 2)", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2025, 2, 15)); // March
    expect(getSeasonKey()).toBe("spring");
    vi.useRealTimers();
  });

  it("returns 'summer' for July (month 6)", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2025, 6, 15)); // July
    expect(getSeasonKey()).toBe("summer");
    vi.useRealTimers();
  });

  it("returns 'autumn' for October (month 9)", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2025, 9, 15)); // October
    expect(getSeasonKey()).toBe("autumn");
    vi.useRealTimers();
  });

  it("returns 'winter' for January (month 0)", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2025, 0, 15)); // January
    expect(getSeasonKey()).toBe("winter");
    vi.useRealTimers();
  });

  it("returns 'winter' for December (month 11)", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2025, 11, 15)); // December
    expect(getSeasonKey()).toBe("winter");
    vi.useRealTimers();
  });
});

// ─── i18n key coverage for new dashboard keys ───────────────────────────────

describe("Dashboard Insights i18n keys", () => {

  const flatKeys = [
    "dashboard.healthInsightsSection",
    "dashboard.healthInsightsTitle",
    "dashboard.avgScoreLabel",
    "dashboard.novaTitle",
    "dashboard.novaAria",
    "dashboard.allergenAlertTitle",
    "dashboard.allergenAlertBody",
    "dashboard.allergenAlertReview",
    "dashboard.categoryDiversityTitle",
    "dashboard.categoryDiversityBody",
    "dashboard.categoryDiversityDiscover",
    "dashboard.recentComparisons",
    "dashboard.untitledComparison",
    "dashboard.comparisonProducts",
  ];

  const nestedKeys = [
    "dashboard.season.spring",
    "dashboard.season.summer",
    "dashboard.season.autumn",
    "dashboard.season.winter",
    "dashboard.scoreBand.low",
    "dashboard.scoreBand.moderate",
    "dashboard.scoreBand.high",
    "dashboard.scoreBand.very_high",
    "dashboard.scoreTrend.improving",
    "dashboard.scoreTrend.worsening",
    "dashboard.scoreTrend.stable",
    "dashboard.nova.1",
    "dashboard.nova.2",
    "dashboard.nova.3",
    "dashboard.nova.4",
  ];

  const allKeys = [...flatKeys, ...nestedKeys];

  it.each(allKeys)("EN has %s", (key) => {
    const result = translate("en", key);
    expect(result).not.toBe(key);
    expect(result.length).toBeGreaterThan(0);
  });

  it.each(allKeys)("PL has %s", (key) => {
    const result = translate("pl", key);
    expect(result).not.toBe(key);
    expect(result.length).toBeGreaterThan(0);
  });
});
