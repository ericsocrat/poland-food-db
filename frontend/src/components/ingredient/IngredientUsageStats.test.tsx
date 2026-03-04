import type { IngredientUsage } from "@/lib/types";
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { IngredientUsageStats } from "./IngredientUsageStats";

// ─── Mocks ──────────────────────────────────────────────────────────────────

// No external mocks needed — component only uses useTranslation (auto-mocked)

// ─── Test Data ──────────────────────────────────────────────────────────────

const USAGE: IngredientUsage = {
  product_count: 142,
  category_breakdown: [
    { category: "Chips", count: 45 },
    { category: "Snacks", count: 30 },
    { category: "Sauces", count: 12 },
  ],
  top_products: [],
};

const EMPTY_USAGE: IngredientUsage = {
  product_count: 0,
  category_breakdown: [],
  top_products: [],
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("IngredientUsageStats", () => {
  it("renders a heading", () => {
    render(<IngredientUsageStats usage={USAGE} />);
    expect(screen.getByRole("heading", { level: 2 })).toBeInTheDocument();
  });

  it("displays the product count", () => {
    render(<IngredientUsageStats usage={USAGE} />);
    expect(screen.getByText("142")).toBeInTheDocument();
  });

  it("renders category breakdown bars", () => {
    render(<IngredientUsageStats usage={USAGE} />);
    expect(screen.getByText("Chips")).toBeInTheDocument();
    expect(screen.getByText("Snacks")).toBeInTheDocument();
    expect(screen.getByText("Sauces")).toBeInTheDocument();
  });

  it("displays count for each category", () => {
    render(<IngredientUsageStats usage={USAGE} />);
    expect(screen.getByText("45")).toBeInTheDocument();
    expect(screen.getByText("30")).toBeInTheDocument();
    expect(screen.getByText("12")).toBeInTheDocument();
  });

  it("renders with zero products and empty breakdown", () => {
    render(<IngredientUsageStats usage={EMPTY_USAGE} />);
    expect(screen.getByText("0")).toBeInTheDocument();
  });

  it("does not render category section when breakdown is empty", () => {
    const { container } = render(
      <IngredientUsageStats usage={EMPTY_USAGE} />,
    );
    // No bar chart divs
    const bars = container.querySelectorAll(".bg-brand-subtle0");
    expect(bars).toHaveLength(0);
  });

  it("renders bar widths proportional to max count", () => {
    const { container } = render(
      <IngredientUsageStats usage={USAGE} />,
    );
    const bars = container.querySelectorAll(".bg-brand-subtle0");
    expect(bars).toHaveLength(3);
    // First bar (45/45 = 100%) should have width: 100%
    expect((bars[0] as HTMLElement).style.width).toBe("100%");
  });
});
