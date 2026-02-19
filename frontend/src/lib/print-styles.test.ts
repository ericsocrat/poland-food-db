// ─── Print styles compliance tests ────────────────────────────────────────
// Validates print CSS rules, no-print markers, and PrintButton component.

import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { describe, it, expect } from "vitest";

const stylesDir = join(__dirname, "../styles");
const globalsCss = readFileSync(join(stylesDir, "globals.css"), "utf-8");

/* ────────────────────── Global Print CSS ────────────────────── */

describe("Global Print Styles", () => {
  it("contains @media print block", () => {
    expect(globalsCss).toContain("@media print");
  });

  it("hides nav, footer, aside in print", () => {
    // Check that nav, footer, aside are hidden
    expect(globalsCss).toMatch(/nav,\s*\n?\s*footer,\s*\n?\s*aside/);
  });

  it("hides .no-print and [data-no-print] elements", () => {
    expect(globalsCss).toContain("[data-no-print]");
    expect(globalsCss).toContain(".no-print");
  });

  it("hides dialogs and tooltips in print", () => {
    expect(globalsCss).toContain('[role="dialog"]');
    expect(globalsCss).toContain('[role="tooltip"]');
  });

  it("hides tab bar in print", () => {
    expect(globalsCss).toContain('[role="tablist"]');
  });

  it("resets body to white background for ink saving", () => {
    expect(globalsCss).toContain("background: white !important");
    expect(globalsCss).toContain("color: black !important");
  });

  it("sets proper font size for printing (11pt)", () => {
    expect(globalsCss).toContain("font-size: 11pt");
  });

  it("removes box-shadow in print", () => {
    expect(globalsCss).toContain("box-shadow: none !important");
  });

  it("removes sticky/fixed positioning", () => {
    expect(globalsCss).toContain("position: static !important");
  });

  it("prevents page breaks inside cards", () => {
    expect(globalsCss).toContain("break-inside: avoid");
  });

  it("has page break utility class", () => {
    expect(globalsCss).toContain(".print-page-break");
    expect(globalsCss).toContain("break-before: page");
  });

  it("disables transitions and animations", () => {
    expect(globalsCss).toContain("transition: none !important");
    expect(globalsCss).toContain("animation: none !important");
  });

  it("shows URLs for external links", () => {
    expect(globalsCss).toContain('a[href^="http"]');
    expect(globalsCss).toContain("attr(href)");
  });

  it("does not show URLs for internal links", () => {
    expect(globalsCss).toContain('a[href^="/"]::after');
    expect(globalsCss).toContain("content: none");
  });

  it("has page attribution footer", () => {
    expect(globalsCss).toContain("Poland Food DB");
    expect(globalsCss).toContain("body::after");
  });

  it("sets @page margins", () => {
    expect(globalsCss).toContain("@page");
    expect(globalsCss).toContain("margin: 15mm");
  });

  it("has named @page compare with landscape and container binding", () => {
    expect(globalsCss).toContain("@page compare");
    expect(globalsCss).toContain("A4 landscape");
    expect(globalsCss).toContain(".compare-print-container");
    expect(globalsCss).toContain("page: compare");
  });

  it("preserves print color adjust for score colors", () => {
    expect(globalsCss).toContain("print-color-adjust: exact");
  });
});

/* ────────────────────── no-print in components ────────────────────── */

describe("No-print markers in pages", () => {
  const productPagePath = join(
    __dirname,
    "../app/app/product/[id]/page.tsx",
  );
  const comparePagePath = join(
    __dirname,
    "../app/app/compare/page.tsx",
  );
  const appLayoutPath = join(__dirname, "../app/app/layout.tsx");

  it("product page action buttons have no-print", () => {
    const src = readFileSync(productPagePath, "utf-8");
    // The action buttons wrapper should have no-print
    expect(src).toContain("no-print");
    // Should import PrintButton
    expect(src).toContain("PrintButton");
    expect(src).toContain("<PrintButton");
  });

  it("compare page toolbar has no-print", () => {
    const src = readFileSync(comparePagePath, "utf-8");
    expect(src).toContain("no-print");
    expect(src).toContain("PrintButton");
    expect(src).toContain("<PrintButton");
  });

  it("compare page container has compare-print-container class", () => {
    const src = readFileSync(comparePagePath, "utf-8");
    expect(src).toContain("compare-print-container");
  });

  it("app layout wraps interactive elements with no-print", () => {
    const src = readFileSync(appLayoutPath, "utf-8");
    expect(src).toContain("no-print");
  });
});

/* ────────────────────── PrintButton component ────────────────────── */

describe("PrintButton component", () => {
  const printButtonPath = join(
    __dirname,
    "../components/common/PrintButton.tsx",
  );

  it("exists", () => {
    expect(existsSync(printButtonPath)).toBe(true);
  });

  it("uses no-print class on itself", () => {
    const src = readFileSync(printButtonPath, "utf-8");
    expect(src).toContain("no-print");
  });

  it("calls window.print()", () => {
    const src = readFileSync(printButtonPath, "utf-8");
    expect(src).toContain("window.print()");
  });

  it("has accessible aria-label", () => {
    const src = readFileSync(printButtonPath, "utf-8");
    expect(src).toContain("aria-label");
  });
});

/* ────────────────────── i18n keys ────────────────────── */

describe("Print i18n keys", () => {
  const enPath = join(__dirname, "../../messages/en.json");
  const plPath = join(__dirname, "../../messages/pl.json");

  it("English has print keys", () => {
    const en = JSON.parse(readFileSync(enPath, "utf-8"));
    expect(en.print).toBeDefined();
    expect(en.print.button).toBeTruthy();
    expect(en.print.printPage).toBeTruthy();
  });

  it("Polish has print keys", () => {
    const pl = JSON.parse(readFileSync(plPath, "utf-8"));
    expect(pl.print).toBeDefined();
    expect(pl.print.button).toBeTruthy();
    expect(pl.print.printPage).toBeTruthy();
  });
});
