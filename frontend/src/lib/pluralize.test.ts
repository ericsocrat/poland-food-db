import { describe, expect, it } from "vitest";
import { pluralize, pluralizePl, selectPolishForm } from "./pluralize";

// ─── English 2-form pluralization ───────────────────────────────────────────

describe("pluralize (English)", () => {
  it("returns singular form for count 1", () => {
    expect(pluralize(1, "product", "products")).toBe("1 product");
  });

  it("returns plural form for count 0", () => {
    expect(pluralize(0, "product", "products")).toBe("0 products");
  });

  it("returns plural form for count > 1", () => {
    expect(pluralize(5, "ingredient", "ingredients")).toBe("5 ingredients");
  });

  it("handles large numbers", () => {
    expect(pluralize(1000, "result", "results")).toBe("1000 results");
  });
});

// ─── Polish 3-form pluralization ────────────────────────────────────────────

describe("pluralizePl (Polish)", () => {
  it("returns one-form for count 1", () => {
    expect(pluralizePl(1, "składnik", "składniki", "składników")).toBe(
      "1 składnik",
    );
  });

  it("returns few-form for counts 2–4", () => {
    expect(pluralizePl(2, "składnik", "składniki", "składników")).toBe(
      "2 składniki",
    );
    expect(pluralizePl(3, "składnik", "składniki", "składników")).toBe(
      "3 składniki",
    );
    expect(pluralizePl(4, "składnik", "składniki", "składników")).toBe(
      "4 składniki",
    );
  });

  it("returns many-form for counts 5–21", () => {
    expect(pluralizePl(5, "składnik", "składniki", "składników")).toBe(
      "5 składników",
    );
    expect(pluralizePl(12, "składnik", "składniki", "składników")).toBe(
      "12 składników",
    );
    expect(pluralizePl(21, "składnik", "składniki", "składników")).toBe(
      "21 składników",
    );
  });

  it("returns few-form for 22–24 (mod10 in 2-4, mod100 not teen)", () => {
    expect(pluralizePl(22, "produkt", "produkty", "produktów")).toBe(
      "22 produkty",
    );
    expect(pluralizePl(23, "produkt", "produkty", "produktów")).toBe(
      "23 produkty",
    );
    expect(pluralizePl(24, "produkt", "produkty", "produktów")).toBe(
      "24 produkty",
    );
  });

  it("returns many-form for 0", () => {
    expect(pluralizePl(0, "produkt", "produkty", "produktów")).toBe(
      "0 produktów",
    );
  });

  it("returns many-form for count 100", () => {
    expect(pluralizePl(100, "produkt", "produkty", "produktów")).toBe(
      "100 produktów",
    );
  });
});

// ─── selectPolishForm — CLDR edge cases ─────────────────────────────────────

describe("selectPolishForm", () => {
  const ONE = "one";
  const FEW = "few";
  const MANY = "many";

  it("count 1 → one", () => {
    expect(selectPolishForm(1, ONE, FEW, MANY)).toBe(ONE);
  });

  it("count 0 → many", () => {
    expect(selectPolishForm(0, ONE, FEW, MANY)).toBe(MANY);
  });

  // counts 2–4 → few
  it.each([2, 3, 4])("count %d → few", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(FEW);
  });

  // counts 5–11 → many
  it.each([5, 6, 7, 8, 9, 10, 11])("count %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  // teen numbers 12–14 → many (NOT few, despite mod10)
  it.each([12, 13, 14])("teen %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  // counts 15–21 → many
  it.each([15, 16, 17, 18, 19, 20, 21])("count %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  // counts 22–24 → few (mod10 in 2-4, mod100 not teen)
  it.each([22, 23, 24])("count %d → few", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(FEW);
  });

  // counts 25–31 → covers boundary between many→few
  it.each([25, 30, 31])("count %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  it.each([32, 33, 34])("count %d → few", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(FEW);
  });

  // 102–104 → few, 112–114 → many (teen rule applied to mod100)
  it.each([102, 103, 104])("count %d → few", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(FEW);
  });

  it.each([112, 113, 114])("teen-hundreds %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  // large round numbers → many
  it.each([100, 1000, 10_000])("count %d → many", (n) => {
    expect(selectPolishForm(n, ONE, FEW, MANY)).toBe(MANY);
  });

  // negative numbers — uses Math.abs for mod but strict === 1 check for one
  it("negative -1 → many (not one, since -1 !== 1)", () => {
    expect(selectPolishForm(-1, ONE, FEW, MANY)).toBe(MANY);
  });

  it("negative -3 (abs 3) → few", () => {
    expect(selectPolishForm(-3, ONE, FEW, MANY)).toBe(FEW);
  });

  it("negative -5 (abs 5) → many", () => {
    expect(selectPolishForm(-5, ONE, FEW, MANY)).toBe(MANY);
  });
});
