import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { CountryChip } from "./CountryChip";

// ─── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      if (key === "common.productFrom") return `Product from ${params?.country ?? ""}`;
      return key;
    },
    language: "en",
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CountryChip", () => {
  // ─── Null handling ──────────────────────────────────────────────────────

  it("renders null when country is null", () => {
    const { container } = render(<CountryChip country={null} />);
    expect(container.innerHTML).toBe("");
  });

  // ─── SVG flag rendering ────────────────────────────────────────────────

  it("renders SVG flag for PL (not emoji)", () => {
    const { container } = render(<CountryChip country="PL" />);
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    // Polish flag has white and red bands
    const rects = container.querySelectorAll("rect");
    expect(rects.length).toBe(2);
  });

  it("renders SVG flag for DE (not emoji)", () => {
    const { container } = render(<CountryChip country="DE" />);
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    // German flag has black, red, gold bands
    const rects = container.querySelectorAll("rect");
    expect(rects.length).toBe(3);
  });

  it("renders fallback SVG flag for unknown country", () => {
    const { container } = render(<CountryChip country="XX" />);
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    // Fallback has gray rect + "?" text
    expect(container.querySelector("text")?.textContent).toBe("?");
  });

  // ─── Text display ─────────────────────────────────────────────────────

  it("shows country code by default (not full name)", () => {
    render(<CountryChip country="PL" />);
    expect(screen.getByText("PL")).toBeTruthy();
    expect(screen.queryByText("Poland")).toBeNull();
  });

  it("shows full country name when showLabel=true", () => {
    render(<CountryChip country="PL" showLabel />);
    expect(screen.getByText("Poland")).toBeTruthy();
    expect(screen.queryByText("PL")).toBeNull();
  });

  it("shows DE code by default", () => {
    render(<CountryChip country="DE" />);
    expect(screen.getByText("DE")).toBeTruthy();
    expect(screen.queryByText("Germany")).toBeNull();
  });

  it("shows Germany when showLabel=true for DE", () => {
    render(<CountryChip country="DE" showLabel />);
    expect(screen.getByText("Germany")).toBeTruthy();
  });

  it("falls back to raw code for unknown country", () => {
    render(<CountryChip country="FR" />);
    expect(screen.getByText("FR")).toBeTruthy();
  });

  // ─── Size variants ─────────────────────────────────────────────────────

  it("renders sm size with text-xs class", () => {
    const { container } = render(<CountryChip country="PL" size="sm" />);
    const chip = container.querySelector("[role='img']");
    expect(chip?.className).toContain("text-xs");
  });

  it("renders md size by default with text-sm class", () => {
    const { container } = render(<CountryChip country="PL" />);
    const chip = container.querySelector("[role='img']");
    expect(chip?.className).toContain("text-sm");
  });

  it("renders smaller flag in sm size", () => {
    const { container } = render(<CountryChip country="PL" size="sm" />);
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("width")).toBe("14");
  });

  it("renders larger flag in md size", () => {
    const { container } = render(<CountryChip country="PL" size="md" />);
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("width")).toBe("16");
  });

  // ─── Accessibility ─────────────────────────────────────────────────────

  it("has role=img with aria-label for PL", () => {
    render(<CountryChip country="PL" />);
    const el = screen.getByRole("img");
    expect(el.getAttribute("aria-label")).toBe("Product from Poland");
  });

  it("has correct aria-label for DE", () => {
    render(<CountryChip country="DE" />);
    const el = screen.getByRole("img");
    expect(el.getAttribute("aria-label")).toBe("Product from Germany");
  });

  it("has aria-hidden on SVG flag", () => {
    const { container } = render(<CountryChip country="PL" />);
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("aria-hidden")).toBe("true");
  });

  // ─── Custom className ──────────────────────────────────────────────────

  it("applies custom className", () => {
    const { container } = render(<CountryChip country="PL" className="ml-2" />);
    const chip = container.querySelector("[role='img']");
    expect(chip?.className).toContain("ml-2");
  });
});
