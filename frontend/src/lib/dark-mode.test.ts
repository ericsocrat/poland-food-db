// ─── Dark mode integration tests ────────────────────────────────────────────
// Verifies that dark mode tokens exist, are properly differentiated from light
// mode, and that the ThemeScript generates valid inline JS.

import { describe, it, expect } from "vitest";
import fs from "fs";
import path from "path";

const GLOBALS_CSS = fs.readFileSync(
  path.resolve(__dirname, "../styles/globals.css"),
  "utf-8",
);

describe("Dark mode CSS tokens", () => {
  it('[data-theme="dark"] block exists in globals.css', () => {
    expect(GLOBALS_CSS).toContain('[data-theme="dark"]');
  });

  it("system preference fallback exists", () => {
    expect(GLOBALS_CSS).toContain("prefers-color-scheme: dark");
    expect(GLOBALS_CSS).toContain(':root:not([data-theme="light"])');
  });

  const darkTokens = [
    "--color-surface",
    "--color-surface-subtle",
    "--color-surface-muted",
    "--color-text-primary",
    "--color-text-secondary",
    "--color-text-inverse",
    "--color-border",
    "--color-brand",
    "--color-score-green",
    "--color-score-yellow",
    "--color-score-orange",
    "--color-score-red",
    "--color-score-darkred",
    "--color-nutri-A",
    "--color-nutri-B",
    "--color-nutri-C",
    "--color-nutri-D",
    "--color-nutri-E",
    "--color-nova-1",
    "--color-nova-2",
    "--color-nova-3",
    "--color-nova-4",
    "--color-confidence-high",
    "--color-confidence-medium",
    "--color-confidence-low",
    "--color-success",
    "--color-warning",
    "--color-error",
    "--color-info",
    "--shadow-sm",
    "--shadow-md",
    "--shadow-lg",
  ];

  // Extract the [data-theme="dark"] block content
  const darkBlockMatch = GLOBALS_CSS.match(
    /\[data-theme="dark"\]\s*\{([^}]+)\}/s,
  );
  const darkBlock = darkBlockMatch ? darkBlockMatch[1] : "";

  it.each(darkTokens)("dark mode overrides %s", (token) => {
    expect(darkBlock).toContain(token);
  });

  it("dark surface color differs from light surface color", () => {
    // Light: #ffffff, Dark: #111827
    const lightMatch = GLOBALS_CSS.match(
      /:root\s*\{[^}]*--color-surface:\s*([^;]+)/s,
    );
    const lightSurface = lightMatch ? lightMatch[1].trim() : "";
    expect(lightSurface).toBe("#ffffff");
    expect(darkBlock).toContain("#111827");
    expect(lightSurface).not.toBe("#111827");
  });

  it("dark text-primary differs from light text-primary", () => {
    const lightMatch = GLOBALS_CSS.match(
      /:root\s*\{[^}]*--color-text-primary:\s*([^;]+)/s,
    );
    const lightText = lightMatch ? lightMatch[1].trim().split("/")[0].trim() : "";
    expect(lightText).toContain("#111827");
    // Dark mode should use a light color
    expect(darkBlock).toContain("#f9fafb");
  });
});

describe("Theme transition CSS", () => {
  it("body has theme transition", () => {
    expect(GLOBALS_CSS).toContain("transition: background-color 150ms ease");
  });

  it("respects prefers-reduced-motion", () => {
    expect(GLOBALS_CSS).toContain("prefers-reduced-motion: reduce");
    expect(GLOBALS_CSS).toContain("transition: none");
  });
});

describe("ThemeScript", () => {
  it("generates valid inline script", async () => {
    // Import and render the ThemeScript component
    const { ThemeScript } = await import("@/components/ThemeScript");
    const { renderToStaticMarkup } = await import("react-dom/server");
    const html = renderToStaticMarkup(ThemeScript({}));

    expect(html).toContain("<script>");
    expect(html).toContain("localStorage");
    expect(html).toContain("data-theme");
    expect(html).toContain("prefers-color-scheme: dark");
  });
});

describe("i18n theme keys", () => {
  it("English translations include theme keys", async () => {
    const en = await import("@/../messages/en.json");
    expect(en.default.theme).toBeDefined();
    expect(en.default.theme.label).toBe("Theme preference");
    expect(en.default.theme.light).toBe("Light");
    expect(en.default.theme.dark).toBe("Dark");
    expect(en.default.theme.system).toBe("System");
  });

  it("Polish translations include theme keys", async () => {
    const pl = await import("@/../messages/pl.json");
    expect(pl.default.theme).toBeDefined();
    expect(pl.default.theme.label).toBeDefined();
    expect(pl.default.theme.light).toBeDefined();
    expect(pl.default.theme.dark).toBeDefined();
    expect(pl.default.theme.system).toBeDefined();
  });

  it("Settings section has theme label", async () => {
    const en = await import("@/../messages/en.json");
    expect(en.default.settings.theme).toBe("Theme");
  });
});
