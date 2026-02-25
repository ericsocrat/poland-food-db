import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { SearchRelevanceHint } from "./SearchRelevanceHint";
import type { SearchMatchType } from "./SearchRelevanceHint";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      const map: Record<string, string> = {
        "trust.searchRelevance.matchedName": "Matched: product name",
        "trust.searchRelevance.matchedBrand": "Matched: brand",
        "trust.searchRelevance.matchedCategory": "Matched: category",
        "trust.searchRelevance.matchedIngredient": "Matched: ingredient",
        "trust.searchRelevance.matchedBarcode": "Matched: barcode",
        "trust.searchRelevance.ariaLabel": `Search match reason: ${params?.reason ?? ""}`,
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SearchRelevanceHint", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Null/undefined handling ────────────────────────────────────────────

  it("renders nothing when matchType is null", () => {
    const { container } = render(<SearchRelevanceHint matchType={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when matchType is undefined", () => {
    const { container } = render(<SearchRelevanceHint matchType={undefined} />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Match types ──────────────────────────────────────────────────────

  it("renders name match", () => {
    render(<SearchRelevanceHint matchType="name" />);
    expect(screen.getByText("Matched: product name")).toBeTruthy();
  });

  it("renders brand match", () => {
    render(<SearchRelevanceHint matchType="brand" />);
    expect(screen.getByText("Matched: brand")).toBeTruthy();
  });

  it("renders category match", () => {
    render(<SearchRelevanceHint matchType="category" />);
    expect(screen.getByText("Matched: category")).toBeTruthy();
  });

  it("renders ingredient match", () => {
    render(<SearchRelevanceHint matchType="ingredient" />);
    expect(screen.getByText("Matched: ingredient")).toBeTruthy();
  });

  it("renders barcode match", () => {
    render(<SearchRelevanceHint matchType="barcode" />);
    expect(screen.getByText("Matched: barcode")).toBeTruthy();
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  it("has role=note", () => {
    render(<SearchRelevanceHint matchType="name" />);
    expect(screen.getByRole("note")).toBeTruthy();
  });

  it("has correct aria-label for name match", () => {
    render(<SearchRelevanceHint matchType="name" />);
    expect(screen.getByRole("note").getAttribute("aria-label")).toBe(
      "Search match reason: Matched: product name",
    );
  });

  it("has correct aria-label for brand match", () => {
    render(<SearchRelevanceHint matchType="brand" />);
    expect(screen.getByRole("note").getAttribute("aria-label")).toBe(
      "Search match reason: Matched: brand",
    );
  });

  // ─── All match types produce valid output ─────────────────────────────

  it("renders all valid match types without error", () => {
    const types: SearchMatchType[] = [
      "name",
      "brand",
      "category",
      "ingredient",
      "barcode",
    ];
    for (const mt of types) {
      const { unmount } = render(<SearchRelevanceHint matchType={mt} />);
      expect(screen.getByRole("note")).toBeTruthy();
      unmount();
    }
  });
});
