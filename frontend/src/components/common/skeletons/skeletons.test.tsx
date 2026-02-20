import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ProductCardSkeleton } from "./ProductCardSkeleton";
import { DashboardSkeleton } from "./DashboardSkeleton";
import { ProductProfileSkeleton } from "./ProductProfileSkeleton";
import { ComparisonGridSkeleton } from "./ComparisonGridSkeleton";
import { SearchResultsSkeleton } from "./SearchResultsSkeleton";
import { CategoryListingSkeleton } from "./CategoryListingSkeleton";
import { CategoryGridSkeleton } from "./CategoryGridSkeleton";
import { ListViewSkeleton } from "./ListViewSkeleton";
import { RecipeGridSkeleton } from "./RecipeGridSkeleton";

// Each skeleton must:
// 1. Render with role="status"
// 2. Have aria-busy="true"
// 3. Have an aria-label
// 4. Contain skeleton shimmer blocks

describe("ProductCardSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ProductCardSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading products");
  });

  it("renders default 3 card placeholders", () => {
    const { container } = render(<ProductCardSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(3);
  });

  it("renders custom count", () => {
    const { container } = render(<ProductCardSkeleton count={5} />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(5);
  });
});

describe("DashboardSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<DashboardSkeleton />);
    const containers = screen.getAllByRole("status");
    const dashboard = containers.find(
      (el) => el.getAttribute("aria-label") === "Loading dashboard",
    );
    expect(dashboard).toBeTruthy();
    expect(dashboard?.getAttribute("aria-busy")).toBe("true");
  });

  it("renders stats bar with 4 stat cards", () => {
    const { container } = render(<DashboardSkeleton />);
    // Stats grid has 4 card items
    const statsGrid = container.querySelector(".grid");
    const statCards = statsGrid?.querySelectorAll(".card");
    expect(statCards?.length).toBe(4);
  });
});

describe("ProductProfileSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ProductProfileSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading product");
  });

  it("renders shimmer blocks for content areas", () => {
    const { container } = render(<ProductProfileSkeleton />);
    const blocks = container.querySelectorAll(".skeleton");
    expect(blocks.length).toBeGreaterThan(5);
  });
});

describe("ComparisonGridSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ComparisonGridSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading comparison");
  });
});

describe("SearchResultsSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<SearchResultsSkeleton />);
    // Should have nested SkeletonContainer from ProductCardSkeleton + own
    const containers = screen.getAllByRole("status");
    expect(containers.length).toBeGreaterThanOrEqual(1);
  });
});

describe("CategoryListingSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<CategoryListingSkeleton />);
    const containers = screen.getAllByRole("status");
    expect(containers.length).toBeGreaterThanOrEqual(1);
  });
});

describe("CategoryGridSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<CategoryGridSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading categories");
  });

  it("renders 9 category card placeholders", () => {
    const { container } = render(<CategoryGridSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(9);
  });
});

describe("ListViewSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ListViewSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading lists");
  });

  it("renders 4 list card placeholders", () => {
    const { container } = render(<ListViewSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(4);
  });
});

describe("RecipeGridSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<RecipeGridSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading recipes");
  });

  it("renders 6 recipe card placeholders", () => {
    const { container } = render(<RecipeGridSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(6);
  });
});
