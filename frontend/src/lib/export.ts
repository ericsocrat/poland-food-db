/**
 * Export utilities for generating CSV and plain-text files from product data.
 * All generation is client-side using the Blob API — zero server cost.
 *
 * CSV files include a UTF-8 BOM (\uFEFF) so Excel on Windows
 * correctly displays Polish characters (ą, ę, ó, ś, ź, ż, ć, ł, ń).
 */

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface ExportableProduct {
  product_name: string;
  brand: string;
  ean?: string;
  category: string;
  unhealthiness_score: number;
  nutri_score_label: string;
  nova_group: string;
  calories_kcal?: number;
  total_fat_g?: number;
  saturated_fat_g?: number;
  sugars_g?: number;
  salt_g?: number;
  protein_g?: number;
  fiber_g?: number;
  allergen_tags?: string[];
  confidence_band?: string;
}

export interface ExportOptions {
  filename: string;
  format: "csv" | "text";
  products: ExportableProduct[];
  includeHeader?: boolean; // default: true
  includeTimestamp?: boolean; // default: true
}

// ---------------------------------------------------------------------------
// CSV generation
// ---------------------------------------------------------------------------

const CSV_COLUMNS = [
  "Product Name",
  "Brand",
  "EAN",
  "Category",
  "Health Score",
  "Nutri-Score",
  "NOVA",
  "Calories (kcal)",
  "Fat (g)",
  "Sat Fat (g)",
  "Sugars (g)",
  "Salt (g)",
  "Protein (g)",
  "Fiber (g)",
  "Allergens",
  "Confidence",
] as const;

/** Escape a single CSV field value (RFC 4180). */
function escapeCSVField(value: string | number | undefined | null): string {
  if (value === undefined || value === null) return "";
  const str = String(value);
  if (str.includes('"') || str.includes(",") || str.includes("\n") || str.includes("\r")) {
    return `"${str.replaceAll('"', '""')}"`;
  }
  return str;
}

function productToCSVRow(p: ExportableProduct): string {
  const fields: (string | number | undefined)[] = [
    p.product_name,
    p.brand,
    p.ean,
    p.category,
    p.unhealthiness_score,
    p.nutri_score_label,
    p.nova_group,
    p.calories_kcal,
    p.total_fat_g,
    p.saturated_fat_g,
    p.sugars_g,
    p.salt_g,
    p.protein_g,
    p.fiber_g,
    p.allergen_tags?.join("; "),
    p.confidence_band,
  ];
  return fields.map(escapeCSVField).join(",");
}

/**
 * Generate a CSV string (with UTF-8 BOM) from an array of products.
 */
export function generateCSV(
  products: ExportableProduct[],
  options?: { includeHeader?: boolean; includeTimestamp?: boolean },
): string {
  const includeHeader = options?.includeHeader ?? true;
  const includeTimestamp = options?.includeTimestamp ?? true;

  const lines: string[] = [];

  // UTF-8 BOM
  lines.push("\uFEFF");

  if (includeHeader) {
    lines.push("# Poland Food Quality Database — Export");
    if (includeTimestamp) {
      lines.push(`# Exported: ${new Date().toISOString()}`);
    }
    lines.push(`# Items: ${products.length}`);
  }

  // Column header row
  lines.push(CSV_COLUMNS.join(","));

  // Data rows
  for (const p of products) {
    lines.push(productToCSVRow(p));
  }

  return lines.join("\r\n");
}

/**
 * Generate a comparison CSV with products as columns (transposed).
 */
export function generateComparisonCSV(products: ExportableProduct[]): string {
  const lines: string[] = [];

  lines.push(
    "\uFEFF",
    "# Poland Food Quality Database — Comparison Export",
    `# Exported: ${new Date().toISOString()}`,
    `# Products compared: ${products.length}`,
  );

  const headers = ["Metric", ...products.map((_, i) => `Product ${i + 1}`)];
  lines.push(headers.join(","));

  const rows: [string, (p: ExportableProduct) => string | number | undefined][] = [
    ["Product Name", (p) => p.product_name],
    ["Brand", (p) => p.brand],
    ["EAN", (p) => p.ean],
    ["Category", (p) => p.category],
    ["Health Score", (p) => p.unhealthiness_score],
    ["Nutri-Score", (p) => p.nutri_score_label],
    ["NOVA", (p) => p.nova_group],
    ["Calories (kcal)", (p) => p.calories_kcal],
    ["Fat (g)", (p) => p.total_fat_g],
    ["Sat Fat (g)", (p) => p.saturated_fat_g],
    ["Sugars (g)", (p) => p.sugars_g],
    ["Salt (g)", (p) => p.salt_g],
    ["Protein (g)", (p) => p.protein_g],
    ["Fiber (g)", (p) => p.fiber_g],
    ["Allergens", (p) => p.allergen_tags?.join("; ")],
    ["Confidence", (p) => p.confidence_band],
  ];

  for (const [label, accessor] of rows) {
    const cells = [label, ...products.map((p) => accessor(p))];
    lines.push(cells.map(escapeCSVField).join(","));
  }

  return lines.join("\r\n");
}

// ---------------------------------------------------------------------------
// Plain-text generation
// ---------------------------------------------------------------------------

/**
 * Generate a plain-text export with numbered product summaries.
 */
export function generateText(
  products: ExportableProduct[],
  options?: { includeHeader?: boolean; includeTimestamp?: boolean },
): string {
  const includeHeader = options?.includeHeader ?? true;
  const includeTimestamp = options?.includeTimestamp ?? true;

  const lines: string[] = [];

  if (includeHeader) {
    lines.push("Poland Food Quality Database — Export");
    if (includeTimestamp) {
      const d = new Date();
      const pad = (n: number) => String(n).padStart(2, "0");
      lines.push(
        `Exported: ${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`,
      );
    }
    lines.push("───────────────────────────────────", "");
  }

  products.forEach((p, i) => {
    lines.push(
      `${i + 1}. ${p.product_name} (${p.brand})`,
      `   Health Score: ${p.unhealthiness_score}/100 · Nutri-Score: ${p.nutri_score_label} · NOVA: ${p.nova_group}`,
    );

    const cal = p.calories_kcal ?? "–";
    const fat = p.total_fat_g == null ? "–" : `${p.total_fat_g}g`;
    const sugar = p.sugars_g == null ? "–" : `${p.sugars_g}g`;
    const salt = p.salt_g == null ? "–" : `${p.salt_g}g`;
    lines.push(`   Per 100g: ${cal} kcal · Fat ${fat} · Sugar ${sugar} · Salt ${salt}`);

    const allergens = p.allergen_tags?.length ? p.allergen_tags.join(", ") : "none";
    lines.push(`   Allergens: ${allergens}`, "");
  });

  return lines.join("\n");
}

// ---------------------------------------------------------------------------
// Download helper
// ---------------------------------------------------------------------------

/**
 * Trigger a file download from a string content.
 * Creates a temporary <a> element with a Blob object URL.
 */
export function downloadFile(content: string, filename: string, mimeType: string): void {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();

  // Cleanup
  setTimeout(() => {
    a.remove();
    URL.revokeObjectURL(url);
  }, 100);
}

/**
 * High-level export function: generates the file and triggers download.
 */
export function exportProducts(options: ExportOptions): void {
  const { filename, format, products, includeHeader, includeTimestamp } = options;

  if (format === "csv") {
    const content = generateCSV(products, { includeHeader, includeTimestamp });
    downloadFile(content, `${filename}.csv`, "text/csv;charset=utf-8");
  } else {
    const content = generateText(products, { includeHeader, includeTimestamp });
    downloadFile(content, `${filename}.txt`, "text/plain;charset=utf-8");
  }
}

/**
 * Export a comparison as CSV (products as columns).
 */
export function exportComparison(products: ExportableProduct[], filename: string): void {
  const content = generateComparisonCSV(products);
  downloadFile(content, `${filename}.csv`, "text/csv;charset=utf-8");
}
