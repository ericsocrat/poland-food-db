// ─── A11y baseline compliance tests ──────────────────────────────────────────
// Validates structural a11y patterns introduced by Issue #49:
// - SkipLink presence on all page layouts
// - id="main-content" landmark targets
// - Focus management in dropdown components
// - ARIA combobox pattern on SearchAutocomplete
// - useReducedMotion hook existence
// - Visible focus indicators in CSS

import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { describe, it, expect } from "vitest";

const SRC = join(__dirname, "..");
const css = readFileSync(join(SRC, "styles/globals.css"), "utf-8");

/* ────────────────── SkipLink on all page layouts ────────────────── */

describe("SkipLink coverage — all pages", () => {
  const pages: [string, string][] = [
    ["Landing page", "app/page.tsx"],
    ["Terms page", "app/terms/page.tsx"],
    ["Privacy page", "app/privacy/page.tsx"],
    ["Learn hub", "app/learn/page.tsx"],
    ["Learn nutri-score", "app/learn/nutri-score/page.tsx"],
    ["Learn nova-groups", "app/learn/nova-groups/page.tsx"],
    ["Learn unhealthiness-score", "app/learn/unhealthiness-score/page.tsx"],
    ["Learn additives", "app/learn/additives/page.tsx"],
    ["Learn allergens", "app/learn/allergens/page.tsx"],
    ["Learn reading-labels", "app/learn/reading-labels/page.tsx"],
    ["Learn confidence", "app/learn/confidence/page.tsx"],
    ["Onboarding layout", "app/onboarding/layout.tsx"],
    ["Login form", "app/auth/login/LoginForm.tsx"],
    ["Signup form", "app/auth/signup/SignupForm.tsx"],
    ["Shared list page", "app/lists/shared/[token]/page.tsx"],
    ["App layout", "app/app/layout.tsx"],
  ];

  for (const [name, file] of pages) {
    it(`${name} imports SkipLink`, () => {
      const path = join(SRC, file);
      expect(existsSync(path), `${file} should exist`).toBe(true);
      const src = readFileSync(path, "utf-8");
      expect(src).toContain("SkipLink");
    });
  }

  const pagesWithMainContent: [string, string][] = [
    ["Landing page", "app/page.tsx"],
    ["Terms page", "app/terms/page.tsx"],
    ["Privacy page", "app/privacy/page.tsx"],
    ["Learn hub", "app/learn/page.tsx"],
    ["Onboarding layout", "app/onboarding/layout.tsx"],
    ["App layout", "app/app/layout.tsx"],
    ["Shared list page", "app/lists/shared/[token]/page.tsx"],
  ];

  for (const [name, file] of pagesWithMainContent) {
    it(`${name} has id="main-content"`, () => {
      const src = readFileSync(join(SRC, file), "utf-8");
      expect(src).toContain('id="main-content"');
    });
  }
});

/* ────────────────── Focus management ────────────────── */

describe("Focus management — AddToListMenu", () => {
  const menuPath = join(
    SRC,
    "components/product/AddToListMenu.tsx",
  );

  it("has triggerRef for focus return", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain("triggerRef");
  });

  it("returns focus to trigger on Escape", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain("triggerRef.current?.focus()");
  });

  it("has aria-expanded on trigger", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain("aria-expanded");
  });

  it("has aria-haspopup on trigger", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain('aria-haspopup="true"');
  });

  it("dropdown has role=menu", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain('role="menu"');
  });

  it("menu items have role=menuitem", () => {
    const src = readFileSync(menuPath, "utf-8");
    expect(src).toContain('role="menuitem"');
  });
});

/* ────────────────── ARIA combobox on SearchAutocomplete ────────────────── */

describe("SearchAutocomplete ARIA combobox", () => {
  const autocompletePath = join(
    SRC,
    "components/search/SearchAutocomplete.tsx",
  );
  const searchPagePath = join(SRC, "app/app/search/page.tsx");

  it("dropdown has role=listbox", () => {
    const src = readFileSync(autocompletePath, "utf-8");
    expect(src).toContain('role="listbox"');
  });

  it("dropdown has stable id", () => {
    const src = readFileSync(autocompletePath, "utf-8");
    expect(src).toContain('id="search-autocomplete-listbox"');
  });

  it("items have role=option", () => {
    const src = readFileSync(autocompletePath, "utf-8");
    expect(src).toContain('role="option"');
  });

  it("items have aria-selected", () => {
    const src = readFileSync(autocompletePath, "utf-8");
    expect(src).toContain("aria-selected");
  });

  it("reports active ID for aria-activedescendant", () => {
    const src = readFileSync(autocompletePath, "utf-8");
    expect(src).toContain("onActiveIdChange");
  });

  it("search input has role=combobox", () => {
    const src = readFileSync(searchPagePath, "utf-8");
    expect(src).toContain('role="combobox"');
  });

  it("search input has aria-controls pointing to listbox", () => {
    const src = readFileSync(searchPagePath, "utf-8");
    expect(src).toContain('aria-controls="search-autocomplete-listbox"');
  });

  it("search input has aria-autocomplete", () => {
    const src = readFileSync(searchPagePath, "utf-8");
    expect(src).toContain('aria-autocomplete="list"');
  });

  it("search input has aria-activedescendant", () => {
    const src = readFileSync(searchPagePath, "utf-8");
    expect(src).toContain("aria-activedescendant");
  });
});

/* ────────────────── Visible focus indicators ────────────────── */

describe("Visible focus indicators", () => {
  it("has global *:focus-visible rule", () => {
    expect(css).toContain("*:focus-visible");
    expect(css).toContain("outline: 2px solid");
    expect(css).toContain("outline-offset: 2px");
  });

  it("removes outline for non-keyboard focus", () => {
    expect(css).toContain(":focus:not(:focus-visible)");
    expect(css).toContain("outline: none");
  });
});

/* ────────────────── Reduced motion ────────────────── */

describe("Reduced motion support", () => {
  it("CSS respects prefers-reduced-motion", () => {
    expect(css).toContain("prefers-reduced-motion: reduce");
  });

  it("CSS sets all duration tokens to 0ms under reduced motion", () => {
    expect(css).toContain("--duration-instant: 0ms");
    expect(css).toContain("--duration-fast: 0ms");
    expect(css).toContain("--duration-normal: 0ms");
    expect(css).toContain("--duration-slow: 0ms");
  });

  it("useReducedMotion hook exists", () => {
    const hookPath = join(SRC, "hooks/use-reduced-motion.ts");
    expect(existsSync(hookPath)).toBe(true);
    const src = readFileSync(hookPath, "utf-8");
    expect(src).toContain("useReducedMotion");
    expect(src).toContain("prefers-reduced-motion");
  });
});

/* ────────────────── Landmark structure ────────────────── */

describe("Landmark structure", () => {
  it("app layout has <main> with id", () => {
    const src = readFileSync(join(SRC, "app/app/layout.tsx"), "utf-8");
    expect(src).toContain('<main');
    expect(src).toContain('id="main-content"');
  });

  it("navigation has aria-label", () => {
    const navPath = join(SRC, "components/layout/Navigation.tsx");
    const src = readFileSync(navPath, "utf-8");
    expect(src).toContain("aria-label");
  });

  it("search form has role=search", () => {
    const src = readFileSync(join(SRC, "app/app/search/page.tsx"), "utf-8");
    expect(src).toContain('role="search"');
  });
});
