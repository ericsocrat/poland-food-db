// ─── PWA & Metadata compliance tests ──────────────────────────────────────
// Validates manifest.webmanifest, root metadata, and structured data setup.

import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { describe, it, expect } from "vitest";

const publicDir = join(__dirname, "../../public");
const appDir = join(__dirname, "../app");

/* ────────────────────── manifest.webmanifest ────────────────────── */

describe("PWA Manifest", () => {
  const manifestPath = join(publicDir, "manifest.webmanifest");
  const manifest = JSON.parse(readFileSync(manifestPath, "utf-8"));

  it("has required PWA fields", () => {
    expect(manifest.name).toBeTruthy();
    expect(manifest.short_name).toBeTruthy();
    expect(manifest.start_url).toBe("/app");
    expect(manifest.display).toBe("standalone");
    expect(manifest.theme_color).toBeTruthy();
    expect(manifest.background_color).toBeTruthy();
  });

  it("has app identity id field", () => {
    expect(manifest.id).toBeTruthy();
  });

  it("has description matching root metadata", () => {
    expect(manifest.description).toContain("Poland");
    expect(manifest.description).toContain("Germany");
  });

  it("has separate icon purposes (not combined 'any maskable')", () => {
    const purposes = manifest.icons.map(
      (i: { purpose: string }) => i.purpose,
    );
    // Should have separate "any" and "maskable" entries
    expect(purposes).toContain("any");
    expect(purposes).toContain("maskable");
    // Should NOT have combined "any maskable"
    expect(purposes).not.toContain("any maskable");
  });

  it("has at least 2 icon sizes", () => {
    const sizes = new Set(
      manifest.icons.map((i: { sizes: string }) => i.sizes),
    );
    expect(sizes.size).toBeGreaterThanOrEqual(2);
  });

  it("has food/health categories", () => {
    expect(manifest.categories).toContain("food");
    expect(manifest.categories).toContain("health");
  });
});

/* ────────────────────── Icon files ────────────────────── */

describe("Icon Assets", () => {
  it("icon-192.svg exists and is valid SVG", () => {
    const path = join(publicDir, "icons/icon-192.svg");
    expect(existsSync(path)).toBe(true);
    const content = readFileSync(path, "utf-8");
    expect(content).toContain("<svg");
    expect(content).toContain('width="192"');
  });

  it("icon-512.svg exists and is valid SVG", () => {
    const path = join(publicDir, "icons/icon-512.svg");
    expect(existsSync(path)).toBe(true);
    const content = readFileSync(path, "utf-8");
    expect(content).toContain("<svg");
    expect(content).toContain('width="512"');
  });
});

/* ────────────────────── Root metadata (layout.tsx) ────────────────────── */

describe("Root Layout Metadata", () => {
  const layoutPath = join(appDir, "layout.tsx");
  const layoutSrc = readFileSync(layoutPath, "utf-8");

  it("exports a title template", () => {
    expect(layoutSrc).toContain("template:");
    expect(layoutSrc).toContain("%s");
  });

  it("declares metadataBase", () => {
    expect(layoutSrc).toContain("metadataBase");
  });

  it("includes openGraph defaults", () => {
    expect(layoutSrc).toContain("openGraph:");
    expect(layoutSrc).toContain("siteName:");
  });

  it("includes twitter defaults", () => {
    expect(layoutSrc).toContain("twitter:");
    expect(layoutSrc).toContain('card: "summary"');
  });

  it("sets robots metadata", () => {
    expect(layoutSrc).toContain("robots:");
    expect(layoutSrc).toContain("index: true");
    expect(layoutSrc).toContain("follow: true");
  });

  it("includes Schema.org WebApplication JSON-LD", () => {
    expect(layoutSrc).toContain("application/ld+json");
    expect(layoutSrc).toContain("WebApplication");
  });
});

/* ────────────────────── Product Layout Schema.org ────────────────────── */

describe("Product Layout", () => {
  const productLayoutPath = join(
    appDir,
    "app/product/[id]/layout.tsx",
  );
  const productLayoutSrc = readFileSync(productLayoutPath, "utf-8");

  it("has generateMetadata for dynamic OG", () => {
    expect(productLayoutSrc).toContain("generateMetadata");
  });

  it("includes Schema.org Product JSON-LD", () => {
    expect(productLayoutSrc).toContain("application/ld+json");
    expect(productLayoutSrc).toContain('"@type": "Product"');
  });

  it("includes NutritionInformation schema", () => {
    expect(productLayoutSrc).toContain("NutritionInformation");
  });

  it("uses title template (no hardcoded suffix)", () => {
    // Should NOT contain "— FoodDB" in title (template handles it)
    expect(productLayoutSrc).not.toContain('title: `${name} — FoodDB`');
    expect(productLayoutSrc).not.toContain('title: "Product — FoodDB"');
  });
});

/* ────────────────────── Page-specific metadata layouts ────────────────────── */

describe("Page-Specific Metadata", () => {
  const pages = [
    { name: "search", path: "app/search/layout.tsx" },
    { name: "categories", path: "app/categories/layout.tsx" },
    { name: "lists", path: "app/lists/layout.tsx" },
    { name: "compare", path: "app/compare/layout.tsx" },
    { name: "settings", path: "app/settings/layout.tsx" },
    { name: "scan", path: "app/scan/layout.tsx" },
  ];

  for (const page of pages) {
    it(`${page.name} has a layout with metadata`, () => {
      const fullPath = join(appDir, page.path);
      expect(existsSync(fullPath)).toBe(true);
      const src = readFileSync(fullPath, "utf-8");
      expect(src).toContain("metadata");
      expect(src).toContain("title:");
      expect(src).toContain("description:");
    });
  }

  it("categories/[slug] has dynamic generateMetadata", () => {
    const path = join(appDir, "app/categories/[slug]/layout.tsx");
    expect(existsSync(path)).toBe(true);
    const src = readFileSync(path, "utf-8");
    expect(src).toContain("generateMetadata");
  });
});

/* ────────────────────── OG Image ────────────────────── */

describe("OpenGraph Images", () => {
  it("root opengraph-image.tsx exists", () => {
    const path = join(appDir, "opengraph-image.tsx");
    expect(existsSync(path)).toBe(true);
    const src = readFileSync(path, "utf-8");
    expect(src).toContain("ImageResponse");
    expect(src).toContain("1200");
    expect(src).toContain("630");
  });

  it("product opengraph-image.tsx exists", () => {
    const path = join(appDir, "app/product/[id]/opengraph-image.tsx");
    expect(existsSync(path)).toBe(true);
    const src = readFileSync(path, "utf-8");
    expect(src).toContain("ImageResponse");
  });
});
