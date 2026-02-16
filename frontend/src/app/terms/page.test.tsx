import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import TermsPage from "./page";

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header" />,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer" />,
}));

describe("TermsPage", () => {
  it("renders the Terms of Service heading", () => {
    render(<TermsPage />);
    expect(screen.getByText("Terms of Service")).toBeInTheDocument();
  });

  it("renders last updated date", () => {
    render(<TermsPage />);
    expect(screen.getByText(/Last updated: February 2026/)).toBeInTheDocument();
  });

  it("renders all section headings", () => {
    render(<TermsPage />);
    expect(screen.getByText("Acceptance")).toBeInTheDocument();
    expect(screen.getByText("Service Description")).toBeInTheDocument();
    expect(screen.getByText("Data Accuracy")).toBeInTheDocument();
    expect(screen.getByText("User Accounts")).toBeInTheDocument();
    expect(screen.getByText("Limitation of Liability")).toBeInTheDocument();
    expect(screen.getByText("Contact")).toBeInTheDocument();
  });

  it("mentions the service is provided as-is", () => {
    render(<TermsPage />);
    expect(screen.getByText(/as is/)).toBeInTheDocument();
  });

  it("renders contact email link", () => {
    render(<TermsPage />);
    const link = screen.getByText("legal@example.com");
    expect(link.closest("a")).toHaveAttribute(
      "href",
      "mailto:legal@example.com",
    );
  });

  it("includes Header and Footer", () => {
    render(<TermsPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });
});
