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
    expect(screen.getByText("Image Processing")).toBeInTheDocument();
    expect(screen.getByText("Your Rights")).toBeInTheDocument();
    expect(screen.getByText("Contact")).toBeInTheDocument();
  });

  it("mentions GDPR rights", () => {
    render(<PrivacyPage />);
    const gdprElements = screen.getAllByText(/GDPR/);
    expect(gdprElements.length).toBeGreaterThanOrEqual(1);
  });

  it("renders contact section text", () => {
    render(<PrivacyPage />);
    expect(
      screen.getByText(/For questions about these terms, contact us at/),
    ).toBeInTheDocument();
  });

  it("includes Header and Footer", () => {
    render(<PrivacyPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });

  // ── Image Processing Policy (#56) ──────────────────────────────────────────

  it("renders image processing sub-headings", () => {
    render(<PrivacyPage />);
    expect(screen.getByText("What We Process")).toBeInTheDocument();
    expect(screen.getByText("How We Process Images")).toBeInTheDocument();
    expect(screen.getByText("Your Camera")).toBeInTheDocument();
    expect(screen.getByText("Data We Collect From Images")).toBeInTheDocument();
    expect(screen.getByText("Legal Basis")).toBeInTheDocument();
  });

  it("states images are never uploaded", () => {
    render(<PrivacyPage />);
    expect(
      screen.getByText(/NEVER uploaded to our servers/),
    ).toBeInTheDocument();
  });

  it("states processing happens on device", () => {
    render(<PrivacyPage />);
    expect(
      screen.getByText(/entirely on your device/),
    ).toBeInTheDocument();
  });

  it("mentions GDPR legal basis for camera feature", () => {
    render(<PrivacyPage />);
    expect(
      screen.getByText(/GDPR Article 6\(1\)\(a\)/),
    ).toBeInTheDocument();
  });
});
