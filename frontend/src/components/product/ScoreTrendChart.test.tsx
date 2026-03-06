import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";

import { ScoreTrendChart, type SparklinePoint } from "./ScoreTrendChart";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

beforeEach(() => {
  vi.clearAllMocks();
});

// ─── Empty State ────────────────────────────────────────────────────────────

describe("ScoreTrendChart — empty state", () => {
  it("renders the empty placeholder when history is empty", () => {
    render(<ScoreTrendChart history={[]} trend="stable" />);

    expect(screen.getByTestId("score-trend-empty")).toBeVisible();
    expect(screen.getByText("watchlist.noHistory")).toBeVisible();
  });

  it("applies custom width and height to empty state", () => {
    render(
      <ScoreTrendChart history={[]} trend="stable" width={200} height={60} />,
    );

    const el = screen.getByTestId("score-trend-empty");
    expect(el.style.width).toBe("200px");
    expect(el.style.height).toBe("60px");
  });
});

// ─── SVG Rendering ──────────────────────────────────────────────────────────

describe("ScoreTrendChart — SVG rendering", () => {
  const twoPoints: SparklinePoint[] = [
    { date: "2025-01-01", score: 20 },
    { date: "2025-02-01", score: 40 },
  ];

  it("renders an SVG with data-testid when history is non-empty", () => {
    render(<ScoreTrendChart history={twoPoints} trend="improving" />);

    const svg = screen.getByTestId("score-trend-chart");
    expect(svg).toBeVisible();
    expect(svg.tagName).toBe("svg");
  });

  it("renders a polyline element inside the SVG", () => {
    render(<ScoreTrendChart history={twoPoints} trend="stable" />);

    const svg = screen.getByTestId("score-trend-chart");
    const polyline = svg.querySelector("polyline");
    expect(polyline).not.toBeNull();
    expect(polyline?.getAttribute("points")).toBeTruthy();
  });

  it("renders a circle on the last data point", () => {
    render(<ScoreTrendChart history={twoPoints} trend="stable" />);

    const svg = screen.getByTestId("score-trend-chart");
    const circle = svg.querySelector("circle");
    expect(circle).not.toBeNull();
  });

  it("uses default width=120 and height=40", () => {
    render(<ScoreTrendChart history={twoPoints} trend="stable" />);

    const svg = screen.getByTestId("score-trend-chart");
    expect(svg.getAttribute("width")).toBe("120");
    expect(svg.getAttribute("height")).toBe("40");
  });

  it("applies custom width and height", () => {
    render(
      <ScoreTrendChart
        history={twoPoints}
        trend="stable"
        width={200}
        height={80}
      />,
    );

    const svg = screen.getByTestId("score-trend-chart");
    expect(svg.getAttribute("width")).toBe("200");
    expect(svg.getAttribute("height")).toBe("80");
  });

  it("applies custom className", () => {
    render(
      <ScoreTrendChart
        history={twoPoints}
        trend="stable"
        className="my-chart"
      />,
    );

    const svg = screen.getByTestId("score-trend-chart");
    expect(svg.classList.contains("my-chart")).toBe(true);
  });
});

// ─── Trend Color Mapping ────────────────────────────────────────────────────

describe("ScoreTrendChart — trend colors", () => {
  const point: SparklinePoint[] = [{ date: "2025-01-01", score: 50 }];

  it("uses success color for improving trend", () => {
    render(<ScoreTrendChart history={point} trend="improving" />);

    const polyline = screen
      .getByTestId("score-trend-chart")
      .querySelector("polyline");
    expect(polyline?.getAttribute("stroke")).toContain("16a34a");
  });

  it("uses error color for worsening trend", () => {
    render(<ScoreTrendChart history={point} trend="worsening" />);

    const polyline = screen
      .getByTestId("score-trend-chart")
      .querySelector("polyline");
    expect(polyline?.getAttribute("stroke")).toContain("dc2626");
  });

  it("uses secondary color for stable trend", () => {
    render(<ScoreTrendChart history={point} trend="stable" />);

    const polyline = screen
      .getByTestId("score-trend-chart")
      .querySelector("polyline");
    expect(polyline?.getAttribute("stroke")).toContain("6b7280");
  });
});

// ─── Edge Cases ─────────────────────────────────────────────────────────────

describe("ScoreTrendChart — edge cases", () => {
  it("handles a single data point (centered horizontally)", () => {
    const single: SparklinePoint[] = [{ date: "2025-06-01", score: 42 }];
    render(<ScoreTrendChart history={single} trend="stable" />);

    const polyline = screen
      .getByTestId("score-trend-chart")
      .querySelector("polyline");
    const points = polyline?.getAttribute("points") ?? "";
    // Single point should be centered: padX + plotW/2 = 4 + 56 = 60
    expect(points).toContain("60.0");
  });

  it("sorts history by date ascending regardless of input order", () => {
    const unsorted: SparklinePoint[] = [
      { date: "2025-03-01", score: 60 },
      { date: "2025-01-01", score: 20 },
      { date: "2025-02-01", score: 40 },
    ];
    render(<ScoreTrendChart history={unsorted} trend="improving" />);

    const polyline = screen
      .getByTestId("score-trend-chart")
      .querySelector("polyline");
    const points = polyline?.getAttribute("points") ?? "";
    const coords = points
      .split(" ")
      .map((p) => p.split(",").map(Number));
    // X values should be monotonically increasing
    for (let i = 1; i < coords.length; i++) {
      expect(coords[i][0]).toBeGreaterThan(coords[i - 1][0]);
    }
  });

  it("handles identical scores (range fallback to 1)", () => {
    const flat: SparklinePoint[] = [
      { date: "2025-01-01", score: 50 },
      { date: "2025-02-01", score: 50 },
    ];
    render(<ScoreTrendChart history={flat} trend="stable" />);

    // Should render without errors
    const svg = screen.getByTestId("score-trend-chart");
    expect(svg).toBeVisible();
  });
});
