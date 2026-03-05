import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoreRadarChart } from "./ScoreRadarChart";
import type { ScoreBreakdownFactor } from "@/lib/types";

function makeFactor(
  name: string,
  weighted: number,
  overrides: Partial<ScoreBreakdownFactor> = {},
): ScoreBreakdownFactor {
  return {
    name,
    raw: weighted,
    input: weighted,
    weight: 1,
    weighted,
    ...overrides,
  };
}

describe("ScoreRadarChart", () => {
  it("renders an SVG with accessible label", () => {
    const breakdown = [
      makeFactor("saturated_fat", 8),
      makeFactor("sugars", 5),
      makeFactor("salt", 3),
    ];
    render(<ScoreRadarChart breakdown={breakdown} />);
    const svg = screen.getByLabelText(/radar chart/i);
    expect(svg).toBeTruthy();
    expect(svg.tagName.toLowerCase()).toBe("svg");
  });

  it("renders a polygon for data", () => {
    const breakdown = [
      makeFactor("saturated_fat", 10),
      makeFactor("sugars", 12),
    ];
    const { container } = render(<ScoreRadarChart breakdown={breakdown} />);
    const polygon = container.querySelector("polygon");
    expect(polygon).toBeTruthy();
    expect(polygon?.getAttribute("points")).toBeTruthy();
  });

  it("renders 10 axis labels", () => {
    const { container } = render(<ScoreRadarChart breakdown={[]} />);
    const labels = container.querySelectorAll("text");
    expect(labels.length).toBe(10);
  });

  it("renders concentric reference circles", () => {
    const { container } = render(<ScoreRadarChart breakdown={[]} />);
    // 3 reference rings + data points (which are circles too)
    const circles = container.querySelectorAll("circle");
    // At least 3 reference circles
    expect(circles.length).toBeGreaterThanOrEqual(3);
  });

  it("renders data points for non-zero factors", () => {
    const breakdown = [
      makeFactor("saturated_fat", 8),
      makeFactor("sugars", 5),
      makeFactor("salt", 3),
      makeFactor("calories", 0),
    ];
    const { container } = render(<ScoreRadarChart breakdown={breakdown} />);
    // 3 reference circles + 10 data point circles (one per axis, even if zero)
    const circles = container.querySelectorAll("circle");
    expect(circles.length).toBe(3 + 10);
  });

  it("handles empty breakdown gracefully", () => {
    const { container } = render(<ScoreRadarChart breakdown={[]} />);
    const polygon = container.querySelector("polygon");
    expect(polygon).toBeTruthy();
    // All points should be at center (all zero)
    expect(polygon?.getAttribute("points")).toBeTruthy();
  });

  it("renders nutrient_density bonus axis with green color", () => {
    const breakdown = [
      makeFactor("nutrient_density", -8),
    ];
    const { container } = render(<ScoreRadarChart breakdown={breakdown} />);
    // The nutrient_density label should have green class
    const labels = container.querySelectorAll("text");
    const nutrientLabel = Array.from(labels).find((l) => l.textContent === "Nutrient+");
    expect(nutrientLabel).toBeTruthy();
    expect(nutrientLabel?.getAttribute("class")).toContain("green");
  });

  it("clamps values that exceed maxWeighted", () => {
    const breakdown = [makeFactor("saturated_fat", 999)]; // Way over max
    const { container } = render(<ScoreRadarChart breakdown={breakdown} />);
    const polygon = container.querySelector("polygon");
    // Should still render without errors (value clamped to 1)
    expect(polygon).toBeTruthy();
  });
});
