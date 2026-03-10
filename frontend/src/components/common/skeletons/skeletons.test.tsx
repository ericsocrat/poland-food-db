import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { AdminDashboardSkeleton } from "./AdminDashboardSkeleton";
import { CategoryGridSkeleton } from "./CategoryGridSkeleton";
import { CategoryListingSkeleton } from "./CategoryListingSkeleton";
import { ComparisonGridSkeleton } from "./ComparisonGridSkeleton";
import { DashboardSkeleton } from "./DashboardSkeleton";
import { IngredientDetailSkeleton } from "./IngredientDetailSkeleton";
import { ListDetailSkeleton } from "./ListDetailSkeleton";
import { ListViewSkeleton } from "./ListViewSkeleton";
import { ProductCardSkeleton } from "./ProductCardSkeleton";
import { ProductProfileSkeleton } from "./ProductProfileSkeleton";
import { RecipeGridSkeleton } from "./RecipeGridSkeleton";
import { SavedItemsSkeleton } from "./SavedItemsSkeleton";
import { ScanHistorySkeleton } from "./ScanHistorySkeleton";
import { SearchResultsSkeleton } from "./SearchResultsSkeleton";
import { SettingsSkeleton } from "./SettingsSkeleton";
import { SubmissionsSkeleton } from "./SubmissionsSkeleton";
import { WatchlistSkeleton } from "./WatchlistSkeleton";

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
    expect(blocks.length).toBeGreaterThan(10);
  });

  it("renders 2-column grid layout", () => {
    const { container } = render(<ProductProfileSkeleton />);
    const grid = container.querySelector(".lg\\:grid-cols-12");
    expect(grid).toBeTruthy();
    const leftCol = grid?.querySelector(".lg\\:col-span-5");
    const rightCol = grid?.querySelector(".lg\\:col-span-7");
    expect(leftCol).toBeTruthy();
    expect(rightCol).toBeTruthy();
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

// ─── New skeleton components (issue #687) ──────────────────────────────────────

describe("SettingsSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<SettingsSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading settings");
  });

  it("renders 3 settings card sections", () => {
    const { container } = render(<SettingsSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(3);
  });

  it("renders shimmer blocks for content areas", () => {
    const { container } = render(<SettingsSkeleton />);
    const blocks = container.querySelectorAll(".skeleton");
    expect(blocks.length).toBeGreaterThan(10);
  });
});

describe("SavedItemsSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<SavedItemsSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading saved items");
  });

  it("renders 4 saved item card placeholders", () => {
    const { container } = render(<SavedItemsSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(4);
  });
});

describe("ListDetailSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ListDetailSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading list");
  });

  it("renders header card plus 5 product item cards", () => {
    const { container } = render(<ListDetailSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(6);
  });

  it("renders shimmer blocks for content areas", () => {
    const { container } = render(<ListDetailSkeleton />);
    const blocks = container.querySelectorAll(".skeleton");
    expect(blocks.length).toBeGreaterThan(15);
  });
});

describe("ScanHistorySkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<ScanHistorySkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading scan history");
  });

  it("renders 5 scan item card placeholders", () => {
    const { container } = render(<ScanHistorySkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(5);
  });
});

describe("SubmissionsSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<SubmissionsSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading submissions");
  });

  it("renders 4 submission card placeholders", () => {
    const { container } = render(<SubmissionsSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(4);
  });
});

describe("AdminDashboardSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<AdminDashboardSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe(
      "Loading admin dashboard",
    );
  });

  it("renders metric cards and content sections", () => {
    const { container } = render(<AdminDashboardSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(7);
  });

  it("renders responsive grid layout", () => {
    const { container } = render(<AdminDashboardSkeleton />);
    const grids = container.querySelectorAll(".grid");
    expect(grids.length).toBeGreaterThanOrEqual(2);
  });
});

describe("IngredientDetailSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<IngredientDetailSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading ingredient");
  });

  it("renders header card plus 2 detail section cards", () => {
    const { container } = render(<IngredientDetailSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(3);
  });
});

describe("WatchlistSkeleton", () => {
  it("renders with correct a11y attributes", () => {
    render(<WatchlistSkeleton />);
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading watchlist");
  });

  it("renders 4 watchlist card placeholders", () => {
    const { container } = render(<WatchlistSkeleton />);
    const cards = container.querySelectorAll(".card");
    expect(cards.length).toBe(4);
  });
});
