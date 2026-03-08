import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import ContactPage from "./page";

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header" />,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer" />,
}));

describe("ContactPage", () => {
  it("renders the Contact heading", () => {
    render(<ContactPage />);
    expect(screen.getByText("Contact")).toBeInTheDocument();
  });

  it("has main-content id on main element for skip-link target", () => {
    render(<ContactPage />);
    const main = document.querySelector("main");
    expect(main).toHaveAttribute("id", "main-content");
  });

  it("renders the feedback prompt", () => {
    render(<ContactPage />);
    expect(
      screen.getByText(/questions, feedback, or want to report/i),
    ).toBeInTheDocument();
  });

  it("renders the email link", () => {
    render(<ContactPage />);
    const link = screen.getByText("hello@example.com");
    expect(link.closest("a")).toHaveAttribute(
      "href",
      "mailto:hello@example.com",
    );
  });

  it("mentions response time", () => {
    render(<ContactPage />);
    expect(screen.getByText(/48 hours/)).toBeInTheDocument();
  });

  it("includes Header and Footer", () => {
    render(<ContactPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });
});
