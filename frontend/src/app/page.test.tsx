import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import HomePage from "./page";

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

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header">Header</header>,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer">Footer</footer>,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HomePage", () => {
  it("renders the main heading", () => {
    render(<HomePage />);
    expect(screen.getByText(/healthier/)).toBeInTheDocument();
    expect(screen.getByText(/made simple/)).toBeInTheDocument();
  });

  it("renders the tagline", () => {
    render(<HomePage />);
    expect(
      screen.getByText(/Search, scan, and compare food products/),
    ).toBeInTheDocument();
  });

  it("renders Get started CTA linking to signup", () => {
    render(<HomePage />);
    const cta = screen.getByText("Get started");
    expect(cta.closest("a")).toHaveAttribute("href", "/auth/signup");
  });

  it("renders Sign in link to login", () => {
    render(<HomePage />);
    const link = screen.getByText("Sign in");
    expect(link.closest("a")).toHaveAttribute("href", "/auth/login");
  });

  it("renders three feature highlights", () => {
    render(<HomePage />);
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
  });

  it("renders feature descriptions", () => {
    render(<HomePage />);
    expect(
      screen.getByText("Find products by name, brand, or category"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Scan barcodes for instant product info"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("See health scores and find better alternatives"),
    ).toBeInTheDocument();
  });

  it("includes Header component", () => {
    render(<HomePage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
  });

  it("includes Footer component", () => {
    render(<HomePage />);
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });

  it("renders feature icons", () => {
    render(<HomePage />);
    expect(screen.getByText("🔍")).toBeInTheDocument();
    expect(screen.getByText("📷")).toBeInTheDocument();
    expect(screen.getByText("📊")).toBeInTheDocument();
  });
});
