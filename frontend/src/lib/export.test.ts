import { describe, expect, it, vi, beforeEach } from "vitest";
import {
  generateCSV,
  generateText,
  generateComparisonCSV,
  downloadFile,
  type ExportableProduct,
} from "./export";

// ─── Test data ──────────────────────────────────────────────────────────────

const POLISH_PRODUCT: ExportableProduct = {
  product_name: "Piątnica Skyr Naturalny",
  brand: "Piątnica",
  ean: "5900820012345",
  category: "Dairy",
  unhealthiness_score: 9,
  nutri_score_label: "A",
  nova_group: "2",
  calories_kcal: 59,
  total_fat_g: 0.2,
  saturated_fat_g: 0.1,
  sugars_g: 3.5,
  salt_g: 0.1,
  protein_g: 10.0,
  fiber_g: 0.0,
  allergen_tags: ["milk"],
  confidence_band: "high",
};

const COMMA_PRODUCT: ExportableProduct = {
  product_name: 'Lay\'s "Classic", Salted',
  brand: "Lay's",
  category: "Chips",
  unhealthiness_score: 68,
  nutri_score_label: "D",
  nova_group: "4",
  calories_kcal: 536,
  total_fat_g: 33,
  saturated_fat_g: 3.2,
  sugars_g: 1.4,
  salt_g: 1.3,
  protein_g: 6.5,
};

const MINIMAL_PRODUCT: ExportableProduct = {
  product_name: "Simple Item",
  brand: "TestBrand",
  category: "Other",
  unhealthiness_score: 50,
  nutri_score_label: "C",
  nova_group: "3",
};

// ─── generateCSV ────────────────────────────────────────────────────────────

describe("generateCSV", () => {
  it("includes UTF-8 BOM at the start", () => {
    const csv = generateCSV([MINIMAL_PRODUCT]);
    expect(csv.startsWith("\uFEFF")).toBe(true);
  });

  it("includes the header comment block with item count", () => {
    const csv = generateCSV([POLISH_PRODUCT, MINIMAL_PRODUCT], {
      includeTimestamp: false,
    });
    expect(csv).toContain("# Poland Food Quality Database — Export");
    expect(csv).toContain("# Items: 2");
  });

  it("includes a timestamp when includeTimestamp is true", () => {
    const csv = generateCSV([MINIMAL_PRODUCT], { includeTimestamp: true });
    expect(csv).toMatch(/# Exported: \d{4}-\d{2}-\d{2}T/);
  });

  it("produces the correct column header row", () => {
    const csv = generateCSV([MINIMAL_PRODUCT], { includeTimestamp: false });
    expect(csv).toContain(
      "Product Name,Brand,EAN,Category,Health Score,Nutri-Score,NOVA,Calories (kcal),Fat (g),Sat Fat (g),Sugars (g),Salt (g),Protein (g),Fiber (g),Allergens,Confidence",
    );
  });

  it("renders product data correctly", () => {
    const csv = generateCSV([POLISH_PRODUCT], { includeTimestamp: false });
    // Polish chars should be intact
    expect(csv).toContain("Piątnica Skyr Naturalny");
    expect(csv).toContain("Piątnica");
    expect(csv).toContain("5900820012345");
    expect(csv).toContain(",9,"); // score
    expect(csv).toContain(",milk,"); // allergens
  });

  it("escapes commas and quotes in product names", () => {
    const csv = generateCSV([COMMA_PRODUCT], { includeTimestamp: false });
    // The product name contains a quote and a comma -> must be wrapped in double quotes
    // Internal quotes are doubled
    expect(csv).toContain('"Lay\'s ""Classic"", Salted"');
  });

  it("handles empty product array", () => {
    const csv = generateCSV([], { includeTimestamp: false });
    expect(csv).toContain("# Items: 0");
    // Should still have the column header row
    expect(csv).toContain("Product Name,Brand,");
    // No data rows after the header
    const lines = csv.split("\r\n").filter((l) => l && !l.startsWith("\uFEFF") && !l.startsWith("#"));
    expect(lines).toHaveLength(1); // just the column header
  });

  it("handles products with missing optional fields", () => {
    const csv = generateCSV([MINIMAL_PRODUCT], { includeTimestamp: false });
    // Missing EAN, calories etc. should be empty
    expect(csv).toContain("Simple Item,TestBrand,,Other,50,C,3,,,,,,,,,");
  });

  it("uses CRLF line endings", () => {
    const csv = generateCSV([MINIMAL_PRODUCT], { includeTimestamp: false });
    expect(csv).toContain("\r\n");
  });

  it("can skip the header block", () => {
    const csv = generateCSV([MINIMAL_PRODUCT], { includeHeader: false });
    expect(csv).not.toContain("# Poland Food Quality Database");
    // Should still have column headers
    expect(csv).toContain("Product Name,Brand,");
  });

  it("preserves Polish diacritics (ą, ę, ó, ś, ź, ż, ć, ł, ń)", () => {
    const product: ExportableProduct = {
      product_name: "Żółć źdźbło ąę",
      brand: "Łódź ń",
      category: "Śliwki",
      unhealthiness_score: 10,
      nutri_score_label: "A",
      nova_group: "1",
    };
    const csv = generateCSV([product], { includeTimestamp: false });
    expect(csv).toContain("Żółć źdźbło ąę");
    expect(csv).toContain("Łódź ń");
    expect(csv).toContain("Śliwki");
  });
});

// ─── generateComparisonCSV ──────────────────────────────────────────────────

describe("generateComparisonCSV", () => {
  it("formats products as columns (transposed layout)", () => {
    const csv = generateComparisonCSV([POLISH_PRODUCT, MINIMAL_PRODUCT]);
    expect(csv).toContain("Metric,Product 1,Product 2");
    expect(csv).toContain("Product Name,Piątnica Skyr Naturalny,Simple Item");
    expect(csv).toContain("Brand,Piątnica,TestBrand");
    expect(csv).toContain("Health Score,9,50");
  });

  it("includes comparison header", () => {
    const csv = generateComparisonCSV([POLISH_PRODUCT]);
    expect(csv).toContain("# Poland Food Quality Database — Comparison Export");
    expect(csv).toContain("# Products compared: 1");
  });
});

// ─── generateText ───────────────────────────────────────────────────────────

describe("generateText", () => {
  it("includes the header with separator line", () => {
    const text = generateText([POLISH_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Poland Food Quality Database — Export");
    expect(text).toContain("───────────────────────────────────");
  });

  it("includes timestamp when enabled", () => {
    const text = generateText([MINIMAL_PRODUCT], { includeTimestamp: true });
    expect(text).toMatch(/Exported: \d{4}-\d{2}-\d{2} \d{2}:\d{2}/);
  });

  it("formats products as numbered list", () => {
    const text = generateText([POLISH_PRODUCT, MINIMAL_PRODUCT], {
      includeTimestamp: false,
    });
    expect(text).toContain("1. Piątnica Skyr Naturalny (Piątnica)");
    expect(text).toContain("2. Simple Item (TestBrand)");
  });

  it("includes health score, nutri-score, and NOVA per product", () => {
    const text = generateText([POLISH_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Health Score: 9/100 · Nutri-Score: A · NOVA: 2");
  });

  it("includes per-100g nutrition summary", () => {
    const text = generateText([POLISH_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Per 100g: 59 kcal · Fat 0.2g · Sugar 3.5g · Salt 0.1g");
  });

  it("uses dash for missing nutrition values", () => {
    const text = generateText([MINIMAL_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Per 100g: – kcal · Fat – · Sugar – · Salt –");
  });

  it("lists allergens", () => {
    const text = generateText([POLISH_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Allergens: milk");
  });

  it("shows 'none' when no allergens", () => {
    const text = generateText([MINIMAL_PRODUCT], { includeTimestamp: false });
    expect(text).toContain("Allergens: none");
  });

  it("can skip the header block", () => {
    const text = generateText([MINIMAL_PRODUCT], { includeHeader: false });
    expect(text).not.toContain("Poland Food Quality Database");
    expect(text).toContain("1. Simple Item (TestBrand)");
  });
});

// ─── downloadFile ───────────────────────────────────────────────────────────

describe("downloadFile", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("creates a link element and triggers click", () => {
    const createObjectURL = vi.fn(() => "blob:mock-url");
    const revokeObjectURL = vi.fn();
    Object.defineProperty(globalThis, "URL", {
      value: { createObjectURL, revokeObjectURL },
      writable: true,
    });

    const appendChild = vi.spyOn(document.body, "appendChild").mockImplementation((node) => node);
    const removeChild = vi.spyOn(document.body, "removeChild").mockImplementation((node) => node);
    const clickSpy = vi.fn();

    vi.spyOn(document, "createElement").mockReturnValue({
      href: "",
      download: "",
      click: clickSpy,
    } as unknown as HTMLAnchorElement);

    downloadFile("test content", "test.csv", "text/csv");

    expect(createObjectURL).toHaveBeenCalledOnce();
    expect(appendChild).toHaveBeenCalledOnce();
    expect(clickSpy).toHaveBeenCalledOnce();

    appendChild.mockRestore();
    removeChild.mockRestore();
  });
});
