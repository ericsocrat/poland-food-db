import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoreSparkline } from "./ScoreSparkline";

describe("ScoreSparkline", () => {
  it("renders SVG sparkline with correct number of bars", () => {
    render(<ScoreSparkline scores={[10, 30, 55, 80]} />);
    expect(screen.getByTestId("score-sparkline")).toBeInTheDocument();
    expect(screen.getByTestId("sparkline-bar-low")).toBeInTheDocument();
    expect(screen.getByTestId("sparkline-bar-moderate")).toBeInTheDocument();
    expect(screen.getByTestId("sparkline-bar-high")).toBeInTheDocument();
    expect(screen.getByTestId("sparkline-bar-very_high")).toBeInTheDocument();
  });

  it("renders bars with proportional heights", () => {
    // 3 low, 1 moderate, 0 high, 0 very_high
    render(<ScoreSparkline scores={[10, 15, 20, 40]} />);
    const lowBar = screen.getByTestId("sparkline-bar-low");
    const modBar = screen.getByTestId("sparkline-bar-moderate");
    const highBar = screen.getByTestId("sparkline-bar-high");

    // low has 3 (max) → full height (40px), moderate has 1 → 1/3 height
    expect(Number(lowBar.getAttribute("height"))).toBe(40);
    expect(Number(modBar.getAttribute("height"))).toBeCloseTo(40 / 3, 0);
    // high has 0 count → 0 height
    expect(Number(highBar.getAttribute("height"))).toBe(0);
  });

  it("returns null when all scores are null", () => {
    const { container } = render(
      <ScoreSparkline scores={[null, null, null]} />,
    );
    expect(container.querySelector("svg")).not.toBeInTheDocument();
    expect(screen.queryByTestId("score-sparkline")).not.toBeInTheDocument();
  });

  it("returns null for empty score array", () => {
    const { container } = render(<ScoreSparkline scores={[]} />);
    expect(container.querySelector("svg")).not.toBeInTheDocument();
  });

  it("filters out null scores and renders remaining", () => {
    render(<ScoreSparkline scores={[null, 10, null, 80, null]} />);
    expect(screen.getByTestId("score-sparkline")).toBeInTheDocument();
    const lowBar = screen.getByTestId("sparkline-bar-low");
    const vhBar = screen.getByTestId("sparkline-bar-very_high");
    expect(Number(lowBar.getAttribute("height"))).toBeGreaterThan(0);
    expect(Number(vhBar.getAttribute("height"))).toBeGreaterThan(0);
  });

  it("has accessible aria-label on SVG", () => {
    render(<ScoreSparkline scores={[50]} />);
    const svg = screen.getByTestId("score-sparkline").querySelector("svg")!;
    expect(svg).toHaveAttribute("aria-label");
  });

  it("gives empty bands low opacity", () => {
    render(<ScoreSparkline scores={[10]} />); // only low band has data
    const highBar = screen.getByTestId("sparkline-bar-high");
    expect(highBar).toHaveAttribute("opacity", "0.2");
  });

  it("gives populated bands full opacity", () => {
    render(<ScoreSparkline scores={[10]} />);
    const lowBar = screen.getByTestId("sparkline-bar-low");
    expect(lowBar).toHaveAttribute("opacity", "1");
  });
});
