import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { IngredientProductList } from "./IngredientProductList";
import type { LinkedProduct } from "@/lib/types";

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

vi.mock("@/components/common/ScoreBadge", () => ({
  ScoreBadge: ({ score }: { score: number | null }) => (
    <span data-testid="score-badge">{score ?? "N/A"}</span>
  ),
}));

// ─── Test data ──────────────────────────────────────────────────────────────

const mockProducts: LinkedProduct[] = [
  {
    product_id: 101,
    product_name: "Oat Flakes Organic",
    brand: "BioFarm",
    unhealthiness_score: 12,
    image_url: "https://example.com/oat.jpg",
    is_primary: true,
  },
  {
    product_id: 102,
    product_name: "Quick Oats",
    brand: "Morning Best",
    unhealthiness_score: 25,
    image_url: null,
    is_primary: false,
  },
  {
    product_id: 103,
    product_name: "Oat Bran",
    brand: null,
    unhealthiness_score: null,
    image_url: null,
    is_primary: false,
  },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("IngredientProductList", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders nothing when products array is empty", () => {
    const { container } = render(<IngredientProductList products={[]} />);
    expect(container.innerHTML).toBe("");
  });

  it("shows toggle button with product count", () => {
    render(<IngredientProductList products={mockProducts} />);
    expect(
      screen.getByText("3 products available"),
    ).toBeInTheDocument();
  });

  it("toggle button has correct aria-expanded=false initially", () => {
    render(<IngredientProductList products={mockProducts} />);
    const btn = screen.getByRole("button");
    expect(btn.getAttribute("aria-expanded")).toBe("false");
  });

  it("does not show product list before expanding", () => {
    render(<IngredientProductList products={mockProducts} />);
    expect(
      screen.queryByTestId("ingredient-product-list"),
    ).not.toBeInTheDocument();
  });

  it("expands product list on click", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(
      screen.getByTestId("ingredient-product-list"),
    ).toBeInTheDocument();
  });

  it("sets aria-expanded=true after click", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(screen.getByRole("button").getAttribute("aria-expanded")).toBe(
      "true",
    );
  });

  it("collapses on second click", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(
      screen.getByTestId("ingredient-product-list"),
    ).toBeInTheDocument();
    await user.click(screen.getByRole("button"));
    expect(
      screen.queryByTestId("ingredient-product-list"),
    ).not.toBeInTheDocument();
  });

  it("shows all product names when expanded", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(screen.getByText("Oat Flakes Organic")).toBeInTheDocument();
    expect(screen.getByText("Quick Oats")).toBeInTheDocument();
    expect(screen.getByText("Oat Bran")).toBeInTheDocument();
  });

  it("shows score badges for each product", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    const badges = screen.getAllByTestId("score-badge");
    expect(badges).toHaveLength(3);
    expect(badges[0].textContent).toBe("12");
    expect(badges[1].textContent).toBe("25");
    expect(badges[2].textContent).toBe("N/A");
  });

  it("shows brand when available", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(screen.getByText("BioFarm")).toBeInTheDocument();
    expect(screen.getByText("Morning Best")).toBeInTheDocument();
  });

  it("does not render brand span when brand is null", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    // Oat Bran has null brand — should have score-badge span + product name span only (no brand, no primary)
    const items = screen.getByTestId("ingredient-product-list").querySelectorAll("li");
    expect(items[2].querySelectorAll("span")).toHaveLength(2); // score-badge + product name only
  });

  it("shows primary badge for primary products", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    expect(screen.getByText("Recommended")).toBeInTheDocument();
  });

  it("does not show primary badge for non-primary products", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    const list = screen.getByTestId("ingredient-product-list");
    const items = list.querySelectorAll("li");
    // Only first product has is_primary — verify others don't have badge
    expect(items[1].textContent).not.toContain("Recommended");
    expect(items[2].textContent).not.toContain("Recommended");
    expect(items[0].textContent).toContain("Recommended");
  });

  it("links each product to its detail page", async () => {
    const user = userEvent.setup();
    render(<IngredientProductList products={mockProducts} />);
    await user.click(screen.getByRole("button"));
    const links = screen
      .getByTestId("ingredient-product-list")
      .querySelectorAll("a");
    expect(links[0]).toHaveAttribute("href", "/app/product/101");
    expect(links[1]).toHaveAttribute("href", "/app/product/102");
    expect(links[2]).toHaveAttribute("href", "/app/product/103");
  });

  it("renders with a single product", async () => {
    const user = userEvent.setup();
    render(
      <IngredientProductList products={[mockProducts[0]]} />,
    );
    await user.click(screen.getByRole("button"));
    expect(screen.getByText("Oat Flakes Organic")).toBeInTheDocument();
  });
});
