import { describe, it, expect } from "vitest";
import { render } from "@testing-library/react";
import {
  CategoryIcon,
  hasCategoryIcon,
  getSupportedCategorySlugs,
} from "./CategoryIcon";

describe("CategoryIcon", () => {
  // ── Rendering ─────────────────────────────────────────────────────────────

  it("renders an SVG for a known category slug", () => {
    const { container } = render(<CategoryIcon slug="dairy" />);
    expect(container.querySelector("svg")).toBeTruthy();
  });

  it("renders an SVG for an unknown category slug (fallback)", () => {
    const { container } = render(<CategoryIcon slug="unknown-nonsense" />);
    expect(container.querySelector("svg")).toBeTruthy();
  });

  // ── Size variants ─────────────────────────────────────────────────────────

  it("renders sm size (16px)", () => {
    const { container } = render(<CategoryIcon slug="dairy" size="sm" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("width")).toBe("16");
    expect(svg.getAttribute("height")).toBe("16");
  });

  it("renders md size (20px)", () => {
    const { container } = render(<CategoryIcon slug="dairy" size="md" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("width")).toBe("20");
    expect(svg.getAttribute("height")).toBe("20");
  });

  it("defaults to lg size (24px)", () => {
    const { container } = render(<CategoryIcon slug="dairy" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("width")).toBe("24");
    expect(svg.getAttribute("height")).toBe("24");
  });

  it("renders xl size (32px)", () => {
    const { container } = render(<CategoryIcon slug="dairy" size="xl" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("width")).toBe("32");
    expect(svg.getAttribute("height")).toBe("32");
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it("is decorative (aria-hidden) when no label", () => {
    const { container } = render(<CategoryIcon slug="meat" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("aria-hidden")).toBe("true");
    expect(svg.getAttribute("aria-label")).toBeNull();
    expect(svg.getAttribute("role")).toBeNull();
  });

  it("is informational (aria-label + role=img) when label provided", () => {
    const { container } = render(
      <CategoryIcon slug="meat" label="Meat products" />,
    );
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("aria-label")).toBe("Meat products");
    expect(svg.getAttribute("role")).toBe("img");
    expect(svg.getAttribute("aria-hidden")).toBeNull();
  });

  // ── All categories render ─────────────────────────────────────────────────

  const CATEGORIES = [
    "bread",
    "breakfast-grain-based",
    "canned-goods",
    "cereals",
    "chips-pl",
    "chips-de",
    "chips",
    "condiments",
    "dairy",
    "drinks",
    "frozen-prepared",
    "instant-frozen",
    "meat",
    "nuts-seeds-legumes",
    "plant-based-alternatives",
    "sauces",
    "seafood-fish",
    "snacks",
    "sweets",
    "alcohol",
    "baby",
    "zabka",
  ];

  it.each(CATEGORIES)("renders icon for category: %s", (slug) => {
    const { container } = render(<CategoryIcon slug={slug} />);
    expect(container.querySelector("svg")).toBeTruthy();
  });

  // ── CSS className passthrough ─────────────────────────────────────────────

  it("applies custom className", () => {
    const { container } = render(
      <CategoryIcon slug="dairy" className="text-red-500" />,
    );
    const svg = container.querySelector("svg")!;
    expect(svg.className.baseVal || svg.getAttribute("class")).toContain(
      "text-red-500",
    );
  });

  // ── Utility: hasCategoryIcon ──────────────────────────────────────────────

  it("hasCategoryIcon returns true for known slugs", () => {
    expect(hasCategoryIcon("dairy")).toBe(true);
    expect(hasCategoryIcon("bread")).toBe(true);
    expect(hasCategoryIcon("sweets")).toBe(true);
  });

  it("hasCategoryIcon returns false for unknown slugs", () => {
    expect(hasCategoryIcon("unknown")).toBe(false);
    expect(hasCategoryIcon("")).toBe(false);
    expect(hasCategoryIcon("pizza")).toBe(false);
  });

  // ── Utility: getSupportedCategorySlugs ────────────────────────────────────

  it("getSupportedCategorySlugs returns all category slugs", () => {
    const slugs = getSupportedCategorySlugs();
    expect(slugs.length).toBeGreaterThanOrEqual(20);
    expect(slugs).toContain("dairy");
    expect(slugs).toContain("meat");
    expect(slugs).toContain("bread");
    expect(slugs).toContain("zabka");
  });
});
