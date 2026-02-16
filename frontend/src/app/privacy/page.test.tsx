import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import PrivacyPage from "./page";

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header" />,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer" />,
}));

describe("PrivacyPage", () => {
  it("renders the Privacy Policy heading", () => {
    render(<PrivacyPage />);
    expect(screen.getByText("Privacy Policy")).toBeInTheDocument();
  });

  it("renders last updated date", () => {
    render(<PrivacyPage />);
    expect(screen.getByText(/Last updated: February 2026/)).toBeInTheDocument();
  });

  it("renders all section headings", () => {
    render(<PrivacyPage />);
    expect(screen.getByText("Data We Collect")).toBeInTheDocument();
    expect(screen.getByText("How We Use Your Data")).toBeInTheDocument();
    expect(screen.getByText("Data Storage")).toBeInTheDocument();
    expect(screen.getByText("Your Rights")).toBeInTheDocument();
    expect(screen.getByText("Contact")).toBeInTheDocument();
  });

  it("mentions GDPR rights", () => {
    render(<PrivacyPage />);
    expect(screen.getByText(/GDPR/)).toBeInTheDocument();
  });

  it("renders contact email link", () => {
    render(<PrivacyPage />);
    const link = screen.getByText("privacy@example.com");
    expect(link.closest("a")).toHaveAttribute(
      "href",
      "mailto:privacy@example.com",
    );
  });

  it("includes Header and Footer", () => {
    render(<PrivacyPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });
});
