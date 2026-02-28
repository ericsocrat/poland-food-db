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

  it("renders a <title> element inside known icon SVGs", () => {
    const { container } = render(<CategoryIcon slug="dairy" />);
    const title = container.querySelector("svg title");
    expect(title).toBeTruthy();
    expect(title?.textContent).toBe("Dairy");
  });

  it("renders an SVG for an unknown category slug (fallback)", () => {
    const { container } = render(<CategoryIcon slug="unknown-nonsense" />);
    expect(container.querySelector("svg")).toBeTruthy();
  });

  // ── Variant ───────────────────────────────────────────────────────────────

  it("defaults to outline variant (stroke, no fill)", () => {
    const { container } = render(<CategoryIcon slug="dairy" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("fill")).toBe("none");
    expect(svg.getAttribute("stroke")).toBe("currentColor");
  });

  it("renders filled variant (fill, no stroke)", () => {
    const { container } = render(
      <CategoryIcon slug="dairy" variant="filled" />,
    );
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("fill")).toBe("currentColor");
    expect(svg.getAttribute("stroke")).toBe("none");
  });

  it("outline and filled variants produce different inner SVG content", () => {
    const { container: outlineContainer } = render(
      <CategoryIcon slug="meat" variant="outline" />,
    );
    const { container: filledContainer } = render(
      <CategoryIcon slug="meat" variant="filled" />,
    );
    const outlineG = outlineContainer.querySelector("svg g")!;
    const filledG = filledContainer.querySelector("svg g")!;
    expect(outlineG.innerHTML).not.toBe(filledG.innerHTML);
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

  it("is informational (aria-label) when label provided", () => {
    const { container } = render(
      <CategoryIcon slug="meat" label="Meat products" />,
    );
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("aria-label")).toBe("Meat products");
    expect(svg.getAttribute("aria-hidden")).toBeNull();
  });

  // ── Slug aliases ──────────────────────────────────────────────────────────

  it("resolves chips-pl alias to chips icon", () => {
    const { container: aliased } = render(<CategoryIcon slug="chips-pl" />);
    const { container: base } = render(<CategoryIcon slug="chips" />);
    const aliasedG = aliased.querySelector("svg g")!;
    const baseG = base.querySelector("svg g")!;
    expect(aliasedG.innerHTML).toBe(baseG.innerHTML);
  });

  it("resolves chips-de alias to chips icon", () => {
    const { container: aliased } = render(<CategoryIcon slug="chips-de" />);
    const { container: base } = render(<CategoryIcon slug="chips" />);
    const aliasedG = aliased.querySelector("svg g")!;
    const baseG = base.querySelector("svg g")!;
    expect(aliasedG.innerHTML).toBe(baseG.innerHTML);
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

  it.each(CATEGORIES)("renders filled variant for category: %s", (slug) => {
    const { container } = render(<CategoryIcon slug={slug} variant="filled" />);
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

  // ── ViewBox ───────────────────────────────────────────────────────────────

  it("uses 24×24 viewBox for custom icons", () => {
    const { container } = render(<CategoryIcon slug="dairy" />);
    const svg = container.querySelector("svg")!;
    expect(svg.getAttribute("viewBox")).toBe("0 0 24 24");
  });

  // ── Utility: hasCategoryIcon ──────────────────────────────────────────────

  it("hasCategoryIcon returns true for known slugs", () => {
    expect(hasCategoryIcon("dairy")).toBe(true);
    expect(hasCategoryIcon("bread")).toBe(true);
    expect(hasCategoryIcon("sweets")).toBe(true);
  });

  it("hasCategoryIcon returns true for alias slugs", () => {
    expect(hasCategoryIcon("chips-pl")).toBe(true);
    expect(hasCategoryIcon("chips-de")).toBe(true);
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

  it("getSupportedCategorySlugs includes alias slugs", () => {
    const slugs = getSupportedCategorySlugs();
    expect(slugs).toContain("chips-pl");
    expect(slugs).toContain("chips-de");
  });
});
