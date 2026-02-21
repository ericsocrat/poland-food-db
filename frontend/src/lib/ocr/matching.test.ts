import { describe, it, expect } from "vitest";
import { cleanOCRText, tokenise, buildSearchQuery } from "./matching";

// ─── cleanOCRText ───────────────────────────────────────────────────────────

describe("cleanOCRText", () => {
  it("trims and collapses whitespace", () => {
    expect(cleanOCRText("  hello   world  ")).toBe("hello world");
  });

  it("replaces newlines with spaces", () => {
    expect(cleanOCRText("line1\nline2\r\nline3")).toBe("line1 line2 line3");
  });

  it("corrects pipe-before-ó to ł", () => {
    // |ód → łód
    expect(cleanOCRText("K|ódź")).toContain("ł");
  });

  it("corrects Czech č to Polish ć", () => {
    expect(cleanOCRText("čwikła")).toBe("ćwikła");
  });

  it("corrects Czech š to Polish ś", () => {
    expect(cleanOCRText("šniadanie")).toBe("śniadanie");
  });

  it("corrects Czech ž to Polish ź", () => {
    expect(cleanOCRText("žródło")).toBe("źródło");
  });

  it("corrects Czech ř to Polish ż (approximate)", () => {
    expect(cleanOCRText("řołądek")).toBe("żołądek");
  });

  it("corrects ĺ to ł", () => {
    expect(cleanOCRText("maĺy")).toBe("mały");
  });

  it("removes weight/volume patterns with decimals like 2.5ml", () => {
    expect(cleanOCRText("cukier 2.5ml mąka 100.0g")).toBe("cukier mąka");
  });

  it("removes integer percentage values", () => {
    expect(cleanOCRText("tłuszczu 45% białko 12%")).toBe(
      "tłuszczu białko",
    );
  });

  it("removes inequality symbols", () => {
    expect(cleanOCRText("< 5 > 10")).toBe("5 10");
  });

  it("replaces parenthetical notes with space", () => {
    expect(cleanOCRText("cukier (brązowy) mąka")).toBe("cukier mąka");
  });

  it("handles empty input", () => {
    expect(cleanOCRText("")).toBe("");
  });

  it("handles input that is only noise", () => {
    // "100g" without decimal stays (regex requires decimal for weight pattern)
    // but percentages and parentheticals are removed
    expect(cleanOCRText("2.5ml 45% (note)")).toBe("");
  });
});

// ─── tokenise ───────────────────────────────────────────────────────────────

describe("tokenise", () => {
  it("splits on spaces", () => {
    expect(tokenise("cukier mąka masło")).toEqual(["cukier", "mąka", "masło"]);
  });

  it("splits on commas and semicolons", () => {
    expect(tokenise("cukier, mąka; masło")).toEqual(["cukier", "mąka", "masło"]);
  });

  it("filters tokens shorter than 3 characters", () => {
    expect(tokenise("a to cukier")).toEqual(["cukier"]);
  });

  it("removes Polish stop words", () => {
    expect(tokenise("składniki cukier wartość mąka")).toEqual([
      "cukier",
      "mąka",
    ]);
  });

  it("removes English stop words", () => {
    expect(tokenise("ingredients sugar nutrition flour")).toEqual([
      "sugar",
      "flour",
    ]);
  });

  it("lowercases tokens", () => {
    expect(tokenise("CUKIER Mąka")).toEqual(["cukier", "mąka"]);
  });

  it("deduplicates tokens", () => {
    expect(tokenise("cukier cukier mąka cukier")).toEqual(["cukier", "mąka"]);
  });

  it("strips non-alpha edges from tokens", () => {
    expect(tokenise("(cukier) -mąka.")).toEqual(["cukier", "mąka"]);
  });

  it("returns empty array for empty input", () => {
    expect(tokenise("")).toEqual([]);
  });

  it("returns empty array when all words are stop words", () => {
    expect(tokenise("składniki wartość odżywcze")).toEqual([]);
  });
});

// ─── buildSearchQuery ───────────────────────────────────────────────────────

describe("buildSearchQuery", () => {
  it("returns cleaned text, tokens, and query", () => {
    const result = buildSearchQuery("Cukier  mąka  masło");
    expect(result.cleaned).toBe("Cukier mąka masło");
    expect(result.tokens).toEqual(["cukier", "mąka", "masło"]);
    expect(result.query).toBe("cukier mąka masło");
  });

  it("caps query at 8 tokens", () => {
    const input = "alpha bravo charlie delta echo foxtrot golf hotel india juliet";
    const result = buildSearchQuery(input);
    const queryTokens = result.query.split(" ");
    expect(queryTokens).toHaveLength(8);
    expect(queryTokens).not.toContain("india");
    expect(queryTokens).not.toContain("juliet");
  });

  it("applies OCR corrections before tokenising", () => {
    // č → ć
    const result = buildSearchQuery("čwikła buraczana");
    expect(result.tokens).toContain("ćwikła");
    expect(result.tokens).toContain("buraczana");
  });

  it("returns empty query for noise-only input", () => {
    const result = buildSearchQuery("100g 45%");
    expect(result.query).toBe("");
    expect(result.tokens).toEqual([]);
  });

  it("handles real-world Polish ingredient list", () => {
    const raw =
      "Składniki: mąka pszenna, cukier, olej palmowy, jaja, mleko w proszku, sól";
    const result = buildSearchQuery(raw);
    expect(result.tokens).toContain("mąka");
    expect(result.tokens).toContain("pszenna");
    expect(result.tokens).toContain("cukier");
    expect(result.tokens).toContain("palmowy");
    expect(result.tokens).not.toContain("składniki");
    expect(result.tokens).toContain("sól"); // 3 chars, Polish diacritics preserved
  });

  it("returns TokenisedText type shape", () => {
    const result = buildSearchQuery("test");
    expect(result).toHaveProperty("cleaned");
    expect(result).toHaveProperty("tokens");
    expect(result).toHaveProperty("query");
  });
});
