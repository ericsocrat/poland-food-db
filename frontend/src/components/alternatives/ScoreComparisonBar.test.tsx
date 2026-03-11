import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { ScoreComparisonBar } from "@/components/alternatives/ScoreComparisonBar";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScoreComparisonBar", () => {
  it("renders both bars with correct TryVit scores", () => {
    // currentScore=65 → TryVit 35, alternativeScore=25 → TryVit 75
    render(<ScoreComparisonBar currentScore={65} alternativeScore={25} />);

    expect(screen.getByText("75")).toBeInTheDocument(); // alternative
    expect(screen.getByText("35")).toBeInTheDocument(); // current
  });

  it("renders accessible aria-label with scores", () => {
    render(<ScoreComparisonBar currentScore={65} alternativeScore={25} />);

    expect(
      screen.getByRole("img", {
        name: "Score comparison: alternative 75 vs current 35",
      }),
    ).toBeInTheDocument();
  });

  it("applies minimum 4% width for very low scores", () => {
    // unhealthiness 99 → TryVit 1 → should clamp to 4% width
    render(<ScoreComparisonBar currentScore={99} alternativeScore={50} />);

    const currentBar = screen.getByTestId("current-bar");
    expect(currentBar).toHaveStyle({ width: "4%" });
  });

  it("applies correct width from TryVit score", () => {
    render(<ScoreComparisonBar currentScore={40} alternativeScore={20} />);

    const altBar = screen.getByTestId("alt-bar");
    const currentBar = screen.getByTestId("current-bar");
    // alt unhealthiness 20 → TryVit 80 → width 80%
    expect(altBar).toHaveStyle({ width: "80%" });
    // current unhealthiness 40 → TryVit 60 → width 60%
    expect(currentBar).toHaveStyle({ width: "60%" });
  });

  it("handles edge case where both scores are equal", () => {
    render(<ScoreComparisonBar currentScore={50} alternativeScore={50} />);

    const bars = screen.getAllByText("50");
    expect(bars).toHaveLength(2);
  });

  it("handles zero unhealthiness (perfect score)", () => {
    render(<ScoreComparisonBar currentScore={80} alternativeScore={0} />);

    expect(screen.getByText("100")).toBeInTheDocument(); // TryVit = 100
    const altBar = screen.getByTestId("alt-bar");
    expect(altBar).toHaveStyle({ width: "100%" });
  });
});
