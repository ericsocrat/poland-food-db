import type { IngredientUsage } from "@/lib/types";
import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { ProductsContainingList } from "./ProductsContainingList";

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

// ─── Test Data ──────────────────────────────────────────────────────────────

const PRODUCTS: IngredientUsage["top_products"] = [
  {
    product_id: 101,
    product_name: "Lay's Classic",
    brand: "Lay's",
    score: 45,
    category: "Chips",
  },
  {
    product_id: 102,
    product_name: "Piątnica Skyr",
    brand: "Piątnica",
    score: 8,
    category: "Dairy",
  },
  {
    product_id: 103,
    product_name: "Coca-Cola Zero",
    brand: "Coca-Cola",
    score: 13,
    category: "Drinks",
  },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ProductsContainingList", () => {
  it("renders a heading", () => {
    render(<ProductsContainingList products={PRODUCTS} />);
    expect(screen.getByRole("heading", { level: 2 })).toBeInTheDocument();
  });

  it("renders a row for each product", () => {
    render(<ProductsContainingList products={PRODUCTS} />);
    expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    expect(screen.getByText("Piątnica Skyr")).toBeInTheDocument();
    expect(screen.getByText("Coca-Cola Zero")).toBeInTheDocument();
  });

  it("links each product to its detail page", () => {
    render(<ProductsContainingList products={PRODUCTS} />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(3);
    expect(links[0]).toHaveAttribute("href", "/app/product/101");
    expect(links[1]).toHaveAttribute("href", "/app/product/102");
    expect(links[2]).toHaveAttribute("href", "/app/product/103");
  });

  it("displays score pills with numeric scores", () => {
    render(<ProductsContainingList products={PRODUCTS} />);
    expect(screen.getByText("45")).toBeInTheDocument();
    expect(screen.getByText("8")).toBeInTheDocument();
    expect(screen.getByText("13")).toBeInTheDocument();
  });

  it("shows brand and category for each product", () => {
    render(<ProductsContainingList products={PRODUCTS} />);
    expect(screen.getByText(/Lay's · Chips/)).toBeInTheDocument();
    expect(screen.getByText(/Piątnica · Dairy/)).toBeInTheDocument();
    expect(screen.getByText(/Coca-Cola · Drinks/)).toBeInTheDocument();
  });

  it("renders with empty products array", () => {
    const { container } = render(
      <ProductsContainingList products={[]} />,
    );
    expect(container.querySelector("ul")).toBeInTheDocument();
  });
});
