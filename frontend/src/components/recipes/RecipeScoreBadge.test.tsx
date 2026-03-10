import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { RecipeScoreBadge } from "./RecipeScoreBadge";
import type { RecipeScore } from "@/lib/types";

// ─── Mock data ──────────────────────────────────────────────────────────────

const baseScore: RecipeScore = {
  api_version: "v1",
  recipe_slug: "overnight-oats",
  aggregate_score: 25,
  score_band: "yellow",
  nutrition_summary: {
    avg_calories: 150.5,
    avg_total_fat_g: 6.2,
    avg_saturated_fat_g: 2.1,
    avg_sugars_g: 8.5,
    avg_salt_g: 0.3,
    avg_protein_g: 5.0,
    avg_fibre_g: 3.2,
  },
  coverage_pct: 75,
  confidence: "medium",
  ingredient_count: 4,
  linked_count: 3,
  note: "Aggregate score is the weighted average of linked product scores.",
};

const greenScore: RecipeScore = {
  ...baseScore,
  aggregate_score: 12,
  score_band: "green",
  coverage_pct: 100,
  confidence: "high",
  ingredient_count: 3,
  linked_count: 3,
};

const emptyScore: RecipeScore = {
  ...baseScore,
  aggregate_score: 0,
  score_band: "green",
  coverage_pct: 0,
  confidence: "low",
  linked_count: 0,
  nutrition_summary: {
    avg_calories: null,
    avg_total_fat_g: null,
    avg_saturated_fat_g: null,
    avg_sugars_g: null,
    avg_salt_g: null,
    avg_protein_g: null,
    avg_fibre_g: null,
  },
};

// ─── Render tests ───────────────────────────────────────────────────────────

describe("RecipeScoreBadge", () => {
  // ─── Null / undefined guard ─────────────────────────────────────────────

  it("renders nothing when score is null", () => {
    const { container } = render(<RecipeScoreBadge score={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when score is undefined", () => {
    const { container } = render(<RecipeScoreBadge score={undefined} />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Empty state (no linked products) ───────────────────────────────────

  it("renders empty state when no products are linked", () => {
    render(<RecipeScoreBadge score={emptyScore} />);
    expect(screen.getByTestId("recipe-score-empty")).toBeInTheDocument();
    expect(
      screen.getByText(/no linked products yet/i),
    ).toBeInTheDocument();
  });

  // ─── Score display ──────────────────────────────────────────────────────

  it("renders the aggregate score value", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(screen.getByText("25")).toBeInTheDocument();
  });

  it("renders band label for yellow score", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(screen.getByText("Good")).toBeInTheDocument();
  });

  it("renders band label for green score", () => {
    render(<RecipeScoreBadge score={greenScore} />);
    expect(screen.getByText("Excellent")).toBeInTheDocument();
  });

  it("renders ingredient coverage text", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(
      screen.getByText("Based on 3 of 4 ingredients"),
    ).toBeInTheDocument();
  });

  // ─── Coverage bar ───────────────────────────────────────────────────────

  it("shows coverage percentage", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(screen.getByText("75% ingredient coverage")).toBeInTheDocument();
  });

  it("renders progressbar with correct aria values", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    const bar = screen.getByRole("progressbar");
    expect(bar).toHaveAttribute("aria-valuenow", "75");
    expect(bar).toHaveAttribute("aria-valuemin", "0");
    expect(bar).toHaveAttribute("aria-valuemax", "100");
  });

  // ─── Confidence ─────────────────────────────────────────────────────────

  it("shows medium confidence for 75% coverage", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(screen.getByText("Medium confidence")).toBeInTheDocument();
  });

  it("shows high confidence for 100% coverage", () => {
    render(<RecipeScoreBadge score={greenScore} />);
    expect(screen.getByText("High confidence")).toBeInTheDocument();
  });

  // ─── Nutrition summary ────────────────────────────────────────────────

  it("hides nutrition summary by default", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(
      screen.queryByTestId("recipe-score-nutrition"),
    ).not.toBeInTheDocument();
  });

  it("shows nutrition summary when showNutrition is true", () => {
    render(<RecipeScoreBadge score={baseScore} showNutrition />);
    expect(
      screen.getByTestId("recipe-score-nutrition"),
    ).toBeInTheDocument();

    // Nutrient bars rendered with progressbar role
    const bars = screen.getAllByRole("progressbar");
    expect(bars.length).toBeGreaterThanOrEqual(3);

    // Verify specific nutrient bars exist
    expect(screen.getByTestId("nutrient-bar-calories")).toBeInTheDocument();
    expect(screen.getByTestId("nutrient-bar-protein")).toBeInTheDocument();
    expect(screen.getByTestId("nutrient-bar-salt")).toBeInTheDocument();
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  it("has accessible score label", () => {
    render(<RecipeScoreBadge score={baseScore} />);
    expect(
      screen.getByLabelText("Recipe score: 25"),
    ).toBeInTheDocument();
  });

  // ─── Custom className ─────────────────────────────────────────────────

  it("applies custom className", () => {
    render(<RecipeScoreBadge score={baseScore} className="mt-4" />);
    const badge = screen.getByTestId("recipe-score-badge");
    expect(badge.className).toContain("mt-4");
  });
});
