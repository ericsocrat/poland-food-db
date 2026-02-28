import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { TrustBadge } from "./TrustBadge";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      const map: Record<string, string> = {
        "trust.badge.high": "High Trust",
        "trust.badge.moderate": "Moderate Trust",
        "trust.badge.low": "Low Trust",
        "trust.badge.highTooltip": "Data is complete and cross-validated.",
        "trust.badge.moderateTooltip":
          "Key data is present but some fields are estimated.",
        "trust.badge.lowTooltip": "Significant data gaps.",
        "trust.badge.ariaLabel": `Data trust level: ${params?.level ?? ""}`,
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("TrustBadge", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Null/undefined handling ────────────────────────────────────────────

  it("renders nothing when trustScore is null", () => {
    const { container } = render(<TrustBadge trustScore={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when trustScore is undefined", () => {
    const { container } = render(<TrustBadge trustScore={undefined} />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Trust level thresholds ─────────────────────────────────────────────

  it("renders High Trust for score >= 0.8", () => {
    render(<TrustBadge trustScore={0.85} />);
    expect(screen.getByText("High Trust")).toBeTruthy();
  });

  it("renders High Trust for exact threshold 0.8", () => {
    render(<TrustBadge trustScore={0.8} />);
    expect(screen.getByText("High Trust")).toBeTruthy();
  });

  it("renders Moderate Trust for score >= 0.5 and < 0.8", () => {
    render(<TrustBadge trustScore={0.65} />);
    expect(screen.getByText("Moderate Trust")).toBeTruthy();
  });

  it("renders Moderate Trust for exact threshold 0.5", () => {
    render(<TrustBadge trustScore={0.5} />);
    expect(screen.getByText("Moderate Trust")).toBeTruthy();
  });

  it("renders Low Trust for score < 0.5", () => {
    render(<TrustBadge trustScore={0.3} />);
    expect(screen.getByText("Low Trust")).toBeTruthy();
  });

  it("renders Low Trust for score 0", () => {
    render(<TrustBadge trustScore={0} />);
    expect(screen.getByText("Low Trust")).toBeTruthy();
  });

  // ─── Color classes ─────────────────────────────────────────────────────

  it("uses green classes for high trust", () => {
    render(<TrustBadge trustScore={0.9} />);
    const badge = screen.getByRole("status");
    expect(badge.className).toContain("text-green-700");
    expect(badge.className).toContain("bg-green-100");
  });

  it("uses amber classes for moderate trust", () => {
    render(<TrustBadge trustScore={0.6} />);
    const badge = screen.getByRole("status");
    expect(badge.className).toContain("text-amber-700");
    expect(badge.className).toContain("bg-amber-100");
  });

  it("uses gray classes for low trust (not red)", () => {
    render(<TrustBadge trustScore={0.2} />);
    const badge = screen.getByRole("status");
    expect(badge.className).toContain("text-gray-500");
    expect(badge.className).toContain("bg-gray-100");
    // Must NOT use red (unverified is uncertain, not alarming)
    expect(badge.className).not.toContain("text-red");
    expect(badge.className).not.toContain("bg-red");
  });

  // ─── Icon animation ───────────────────────────────────────────────────

  it("adds animation class to high trust icon", () => {
    render(<TrustBadge trustScore={0.9} />);
    const icon = screen.getByTestId("trust-icon");
    expect(icon.getAttribute("class")).toContain("animate-trust-verified");
  });

  it("does not animate moderate trust icon", () => {
    render(<TrustBadge trustScore={0.6} />);
    const icon = screen.getByTestId("trust-icon");
    const cls = icon.getAttribute("class") ?? "";
    expect(cls).not.toContain("animate-trust-verified");
  });

  it("does not animate low trust icon", () => {
    render(<TrustBadge trustScore={0.2} />);
    const icon = screen.getByTestId("trust-icon");
    const cls = icon.getAttribute("class") ?? "";
    expect(cls).not.toContain("animate-trust-verified");
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  it("has role=status for screen readers", () => {
    render(<TrustBadge trustScore={0.9} />);
    expect(screen.getByRole("status")).toBeTruthy();
  });

  it("has correct aria-label", () => {
    render(<TrustBadge trustScore={0.9} />);
    expect(screen.getByRole("status").getAttribute("aria-label")).toBe(
      "Data trust level: High Trust",
    );
  });

  it("has tooltip via title attribute", () => {
    render(<TrustBadge trustScore={0.6} />);
    expect(
      screen.getByTitle("Key data is present but some fields are estimated."),
    ).toBeTruthy();
  });

  it("has aria-hidden on icon", () => {
    render(<TrustBadge trustScore={0.9} />);
    const icon = screen.getByTestId("trust-icon");
    expect(icon.getAttribute("aria-hidden")).toBe("true");
  });

  // ─── Size variants ─────────────────────────────────────────────────────

  it("renders with sm size class", () => {
    render(<TrustBadge trustScore={0.9} size="sm" />);
    const badge = screen.getByRole("status");
    expect(badge.className).toContain("text-xs");
  });

  it("renders with md size class by default", () => {
    render(<TrustBadge trustScore={0.9} />);
    const badge = screen.getByRole("status");
    expect(badge.className).toContain("text-sm");
  });

  // ─── Edge cases ─────────────────────────────────────────────────────────

  it("renders High Trust for score 1.0", () => {
    render(<TrustBadge trustScore={1.0} />);
    expect(screen.getByText("High Trust")).toBeTruthy();
  });

  it("renders Low Trust for boundary 0.49", () => {
    render(<TrustBadge trustScore={0.49} />);
    expect(screen.getByText("Low Trust")).toBeTruthy();
  });

  it("renders Moderate Trust for boundary 0.79", () => {
    render(<TrustBadge trustScore={0.79} />);
    expect(screen.getByText("Moderate Trust")).toBeTruthy();
  });
});
