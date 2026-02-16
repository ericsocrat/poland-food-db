import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { Footer } from "./Footer";

// Mock next/link as a simple anchor
vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

describe("Footer", () => {
  it("renders privacy link", () => {
    render(<Footer />);
    const link = screen.getByText("Privacy Policy");
    expect(link).toBeInTheDocument();
    expect(link.closest("a")).toHaveAttribute("href", "/privacy");
  });

  it("renders terms link", () => {
    render(<Footer />);
    expect(screen.getByText("Terms of Service").closest("a")).toHaveAttribute(
      "href",
      "/terms",
    );
  });

  it("renders contact link", () => {
    render(<Footer />);
    expect(screen.getByText("Contact").closest("a")).toHaveAttribute(
      "href",
      "/contact",
    );
  });

  it("renders current year in copyright", () => {
    render(<Footer />);
    const year = new Date().getFullYear().toString();
    expect(screen.getByText(new RegExp(year))).toBeInTheDocument();
  });

  it("mentions data source", () => {
    render(<Footer />);
    expect(screen.getByText(/Open Food Facts/i)).toBeInTheDocument();
  });
});
