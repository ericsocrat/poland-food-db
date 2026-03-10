import type { RecentlyViewedProduct } from "@/lib/types";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { RecentlyViewed, relativeTimeAgo } from "./RecentlyViewed";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const map: Record<string, string> = {
        "dashboard.recentlyViewedCompact": "Recently Viewed",
        "dashboard.viewAll": "View all",
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeProduct(
  id: number,
  overrides: Partial<RecentlyViewedProduct> = {},
): RecentlyViewedProduct {
  return {
    product_id: id,
    product_name: `Product ${id}`,
    brand: `Brand ${id}`,
    category: "chips",
    country: "PL",
    unhealthiness_score: 40,
    nutri_score_label: "C",
    viewed_at: new Date().toISOString(),
    image_thumb_url: null,
    ...overrides,
  };
}

// ─── relativeTimeAgo unit tests ─────────────────────────────────────────────

describe("relativeTimeAgo", () => {
  it("returns 'now' for current time", () => {
    expect(relativeTimeAgo(new Date().toISOString())).toBe("now");
  });

  it("returns minutes for < 1 hour", () => {
    const thirtyMinAgo = new Date(Date.now() - 30 * 60_000).toISOString();
    expect(relativeTimeAgo(thirtyMinAgo)).toBe("30m");
  });

  it("returns hours for < 24 hours", () => {
    const fiveHoursAgo = new Date(Date.now() - 5 * 3600_000).toISOString();
    expect(relativeTimeAgo(fiveHoursAgo)).toBe("5h");
  });

  it("returns days for < 7 days", () => {
    const threeDaysAgo = new Date(Date.now() - 3 * 86400_000).toISOString();
    expect(relativeTimeAgo(threeDaysAgo)).toBe("3d");
  });

  it("returns weeks for >= 7 days", () => {
    const twoWeeksAgo = new Date(Date.now() - 14 * 86400_000).toISOString();
    expect(relativeTimeAgo(twoWeeksAgo)).toBe("2w");
  });
});

// ─── RecentlyViewed component tests ─────────────────────────────────────────

describe("RecentlyViewed", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns null for empty products", () => {
    const { container } = render(<RecentlyViewed products={[]} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders product names and brands", () => {
    const products = [makeProduct(1), makeProduct(2)];
    render(<RecentlyViewed products={products} />);

    expect(screen.getByText("Product 1")).toBeInTheDocument();
    expect(screen.getByText("Brand 1")).toBeInTheDocument();
    expect(screen.getByText("Product 2")).toBeInTheDocument();
  });

  it("limits to 5 items", () => {
    const products = Array.from({ length: 8 }, (_, i) => makeProduct(i + 1));
    render(<RecentlyViewed products={products} />);

    const items = screen.getAllByTestId("recently-viewed-item");
    expect(items).toHaveLength(5);
  });

  it("shows TryVit scores in score circles", () => {
    // unhealthiness 40 → TryVit 60
    const products = [makeProduct(1, { unhealthiness_score: 40 })];
    render(<RecentlyViewed products={products} />);

    const item = screen.getByTestId("recently-viewed-item");
    expect(item.textContent).toContain("60");
  });

  it("shows dash for null scores", () => {
    const products = [makeProduct(1, { unhealthiness_score: null })];
    render(<RecentlyViewed products={products} />);

    const item = screen.getByTestId("recently-viewed-item");
    expect(item.textContent).toContain("–");
  });

  it("links to product pages", () => {
    const products = [makeProduct(42)];
    render(<RecentlyViewed products={products} />);

    const link = screen.getByTestId("recently-viewed-item");
    expect(link).toHaveAttribute("href", "/app/product/42");
  });

  it("shows View all link", () => {
    const products = [makeProduct(1)];
    render(<RecentlyViewed products={products} />);

    const link = screen.getByRole("link", { name: /View all/ });
    expect(link).toHaveAttribute("href", "/app/search");
  });

  it("has section aria-label", () => {
    const products = [makeProduct(1)];
    render(<RecentlyViewed products={products} />);
    expect(screen.getByLabelText("Recently Viewed")).toBeInTheDocument();
  });

  it("hides brand when null", () => {
    const products = [makeProduct(1, { brand: null })];
    render(<RecentlyViewed products={products} />);

    expect(screen.getByText("Product 1")).toBeInTheDocument();
    expect(screen.queryByText("Brand 1")).not.toBeInTheDocument();
  });
});
