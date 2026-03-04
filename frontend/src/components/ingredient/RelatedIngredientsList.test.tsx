import type { RelatedIngredient } from "@/lib/types";
import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { RelatedIngredientsList } from "./RelatedIngredientsList";

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

vi.mock("./ConcernBadge", () => ({
  ConcernBadge: ({ label }: { tier: number; label: string }) => (
    <span data-testid="concern-badge">{label}</span>
  ),
}));

// ─── Test Data ──────────────────────────────────────────────────────────────

const INGREDIENTS: RelatedIngredient[] = [
  {
    ingredient_id: 1,
    name_en: "Salt",
    is_additive: false,
    concern_tier: 0,
    co_occurrence_count: 120,
  },
  {
    ingredient_id: 2,
    name_en: "E621",
    is_additive: true,
    concern_tier: 2,
    co_occurrence_count: 45,
  },
  {
    ingredient_id: 3,
    name_en: "Sugar",
    is_additive: false,
    concern_tier: 0,
    co_occurrence_count: 90,
  },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("RelatedIngredientsList", () => {
  it("renders a heading", () => {
    render(<RelatedIngredientsList ingredients={INGREDIENTS} />);
    expect(screen.getByRole("heading", { level: 2 })).toBeInTheDocument();
  });

  it("renders a list item for each ingredient", () => {
    render(<RelatedIngredientsList ingredients={INGREDIENTS} />);
    expect(screen.getByText("Salt")).toBeInTheDocument();
    expect(screen.getByText("E621")).toBeInTheDocument();
    expect(screen.getByText("Sugar")).toBeInTheDocument();
  });

  it("links each ingredient to its profile page", () => {
    render(<RelatedIngredientsList ingredients={INGREDIENTS} />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(3);
    expect(links[0]).toHaveAttribute("href", "/app/ingredient/1");
    expect(links[1]).toHaveAttribute("href", "/app/ingredient/2");
    expect(links[2]).toHaveAttribute("href", "/app/ingredient/3");
  });

  it("shows additive emoji for additives and leaf for natural", () => {
    render(<RelatedIngredientsList ingredients={INGREDIENTS} />);
    expect(screen.getByText("🧪")).toBeInTheDocument(); // E621
    expect(screen.getAllByText("🌿")).toHaveLength(2); // Salt, Sugar
  });

  it("renders concern badges for each ingredient", () => {
    render(<RelatedIngredientsList ingredients={INGREDIENTS} />);
    expect(screen.getAllByTestId("concern-badge")).toHaveLength(3);
  });

  it("renders with empty ingredients array", () => {
    const { container } = render(
      <RelatedIngredientsList ingredients={[]} />,
    );
    expect(container.querySelector("ul")).toBeInTheDocument();
  });
});
