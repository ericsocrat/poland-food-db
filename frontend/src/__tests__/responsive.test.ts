import fs from "fs";
import path from "path";
import { describe, expect, it } from "vitest";

// ─── Responsive Layout Tests ────────────────────────────────────────────────
// Verifies that breakpoint tokens, container query infrastructure, and
// touch target utilities are correctly configured.
// Issue #59: Responsive Layout Polish — Mobile-First Breakpoints + Touch Targets
//
// Tailwind v4: breakpoints and design tokens live in @theme {} inside globals.css
// (tailwind.config.ts was removed during the v4 migration).

const css = fs.readFileSync(
  path.resolve(__dirname, "../styles/globals.css"),
  "utf-8",
);

describe("Tailwind breakpoint tokens", () => {
  it("defines xs breakpoint at 375px", () => {
    expect(css).toContain("--breakpoint-xs: 375px");
  });

  it("defines sm breakpoint at 640px", () => {
    expect(css).toContain("--breakpoint-sm: 640px");
  });

  it("defines md breakpoint at 768px", () => {
    expect(css).toContain("--breakpoint-md: 768px");
  });

  it("defines lg breakpoint at 1024px", () => {
    expect(css).toContain("--breakpoint-lg: 1024px");
  });

  it("defines xl breakpoint at 1280px", () => {
    expect(css).toContain("--breakpoint-xl: 1280px");
  });

  it("defines 2xl breakpoint at 1440px", () => {
    expect(css).toContain("--breakpoint-2xl: 1440px");
  });

  it("has all 6 breakpoints", () => {
    const breakpoints = css.match(/--breakpoint-(?![\*])\S+:/g) ?? [];
    expect(breakpoints).toHaveLength(6);
  });
});

describe("Tailwind design tokens in @theme", () => {
  it("defines surface color tokens", () => {
    expect(css).toContain("--color-surface:");
    expect(css).toContain("--color-surface-muted:");
  });

  it("defines foreground color tokens", () => {
    expect(css).toContain("--color-foreground:");
    expect(css).toContain("--color-foreground-secondary:");
    expect(css).toContain("--color-foreground-muted:");
  });

  it("defines border color tokens", () => {
    expect(css).toContain("--color-border:");
  });

  it("defines brand color palette", () => {
    expect(css).toContain("--color-brand-600:");
    expect(css).toContain("--color-brand-700:");
  });
});

describe("Touch target CSS utilities", () => {
  // These test that the globals.css file defines the expected utility classes
  // by importing the stylesheet content and checking for class definitions.
  // In a jsdom environment, we verify the class definitions exist in the source.

  it("touch-target class is importable from globals.css", async () => {
    const fs = await import("fs");
    const path = await import("path");
    const cssPath = path.resolve(__dirname, "../styles/globals.css");
    const css = fs.readFileSync(cssPath, "utf-8");
    expect(css).toContain(".touch-target");
  });

  it("touch-target sets minimum 44px dimensions", async () => {
    const fs = await import("fs");
    const path = await import("path");
    const cssPath = path.resolve(__dirname, "../styles/globals.css");
    const css = fs.readFileSync(cssPath, "utf-8");
    expect(css).toContain("min-height: 44px");
    expect(css).toContain("min-width: 44px");
  });

  it("touch-target-expanded class exists with pseudo-element", async () => {
    const fs = await import("fs");
    const path = await import("path");
    const cssPath = path.resolve(__dirname, "../styles/globals.css");
    const css = fs.readFileSync(cssPath, "utf-8");
    expect(css).toContain(".touch-target-expanded");
    expect(css).toContain("::after");
  });

  it("container query types are defined", async () => {
    const fs = await import("fs");
    const path = await import("path");
    const cssPath = path.resolve(__dirname, "../styles/globals.css");
    const css = fs.readFileSync(cssPath, "utf-8");
    expect(css).toContain("container-type: inline-size");
    expect(css).toContain(".product-card-container");
    expect(css).toContain(".compare-cell-container");
  });

  it("safe area utilities are defined", async () => {
    const fs = await import("fs");
    const path = await import("path");
    const cssPath = path.resolve(__dirname, "../styles/globals.css");
    const css = fs.readFileSync(cssPath, "utf-8");
    expect(css).toContain(".safe-area-bottom");
    expect(css).toContain("safe-area-inset-bottom");
  });
});
