import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { RecipeCard } from "./RecipeCard";
import type { RecipeSummary } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    className,
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} className={className}>
      {children}
    </a>
  ),
}));

// ─── Mock data ──────────────────────────────────────────────────────────────

const baseRecipe: RecipeSummary = {
  id: "r1",
  slug: "overnight-oats",
  title_key: "recipes.items.overnight-oats.title",
  description_key: "recipes.items.overnight-oats.description",
  category: "breakfast",
  difficulty: "easy",
  prep_time_min: 5,
  cook_time_min: 0,
  servings: 1,
  image_url: null,
  country: "PL",
  tags: ["quick", "healthy"],
  total_time: 5,
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("RecipeCard", () => {
  it("renders recipe title from i18n key", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(
      screen.getByText("Overnight Oats with Yogurt & Berries"),
    ).toBeInTheDocument();
  });

  it("renders recipe description from i18n key", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(
      screen.getByText(
        "Creamy overnight oats topped with fresh berries and a drizzle of honey.",
      ),
    ).toBeInTheDocument();
  });

  it("links to recipe detail page", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    const link = screen
      .getByText("Overnight Oats with Yogurt & Berries")
      .closest("a");
    expect(link).toHaveAttribute("href", "/app/recipes/overnight-oats");
  });

  it("renders total time", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(screen.getByText(/5 min/)).toBeInTheDocument();
  });

  it("renders difficulty label", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(screen.getByText("Easy")).toBeInTheDocument();
  });

  it("renders servings count", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(screen.getByText("1")).toBeInTheDocument();
  });

  it("renders tags as chips", () => {
    render(<RecipeCard recipe={baseRecipe} />);
    expect(screen.getByText("quick")).toBeInTheDocument();
    expect(screen.getByText("healthy")).toBeInTheDocument();
  });

  it("limits visible tags to 3", () => {
    const manyTags: RecipeSummary = {
      ...baseRecipe,
      tags: ["a", "b", "c", "d", "e"],
    };
    render(<RecipeCard recipe={manyTags} />);
    expect(screen.getByText("a")).toBeInTheDocument();
    expect(screen.getByText("b")).toBeInTheDocument();
    expect(screen.getByText("c")).toBeInTheDocument();
    expect(screen.queryByText("d")).not.toBeInTheDocument();
    expect(screen.queryByText("e")).not.toBeInTheDocument();
  });

  it("does not render tags section when empty", () => {
    const noTags: RecipeSummary = { ...baseRecipe, tags: [] };
    const { container } = render(<RecipeCard recipe={noTags} />);
    // No chip elements should be rendered
    const chips = container.querySelectorAll("[class*='chip']");
    expect(chips.length).toBe(0);
  });

  it("applies medium difficulty styling", () => {
    const medium: RecipeSummary = { ...baseRecipe, difficulty: "medium" };
    render(<RecipeCard recipe={medium} />);
    expect(screen.getByText("Medium")).toBeInTheDocument();
  });

  it("applies hard difficulty styling", () => {
    const hard: RecipeSummary = { ...baseRecipe, difficulty: "hard" };
    render(<RecipeCard recipe={hard} />);
    expect(screen.getByText("Hard")).toBeInTheDocument();
  });
});
