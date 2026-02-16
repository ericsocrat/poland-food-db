import { describe, it, expect } from "vitest";
import { queryKeys, staleTimes } from "@/lib/query-keys";

// ─── queryKeys ──────────────────────────────────────────────────────────────

describe("queryKeys", () => {
  it("preferences is a static tuple", () => {
    expect(queryKeys.preferences).toEqual(["preferences"]);
  });

  it("search produces deterministic keys", () => {
    const key = queryKeys.search("chips", { category: ["snacks"] });
    expect(key).toEqual(["search", { query: "chips", filters: { category: ["snacks"] }, page: undefined }]);
  });

  it("search key without filters", () => {
    const key = queryKeys.search("water");
    expect(key).toEqual(["search", { query: "water", filters: undefined, page: undefined }]);
  });

  it("product key for a given id", () => {
    expect(queryKeys.product(42)).toEqual(["product", 42]);
  });

  it("scan key for a given ean", () => {
    expect(queryKeys.scan("5901234123457")).toEqual([
      "scan",
      "5901234123457",
    ]);
  });

  it("categoryListing produces full key", () => {
    const key = queryKeys.categoryListing("chips", "name", "asc", 20);
    expect(key).toEqual([
      "category-listing",
      { category: "chips", sortBy: "name", sortDir: "asc", offset: 20 },
    ]);
  });

  it("categoryOverview is a static tuple", () => {
    expect(queryKeys.categoryOverview).toEqual(["category-overview"]);
  });

  it("alternatives key for a given product", () => {
    expect(queryKeys.alternatives(7)).toEqual(["alternatives", 7]);
  });

  it("scoreExplanation key for a given product", () => {
    expect(queryKeys.scoreExplanation(7)).toEqual(["score-explanation", 7]);
  });

  it("healthProfiles is a static tuple", () => {
    expect(queryKeys.healthProfiles).toEqual(["health-profiles"]);
  });

  it("activeHealthProfile is a static tuple", () => {
    expect(queryKeys.activeHealthProfile).toEqual(["active-health-profile"]);
  });

  it("healthWarnings key for a given product", () => {
    expect(queryKeys.healthWarnings(99)).toEqual(["health-warnings", 99]);
  });

  it("autocomplete key for a query string", () => {
    expect(queryKeys.autocomplete("choc")).toEqual(["autocomplete", "choc"]);
  });

  it("filterOptions is a static tuple", () => {
    expect(queryKeys.filterOptions).toEqual(["filter-options"]);
  });

  it("savedSearches is a static tuple", () => {
    expect(queryKeys.savedSearches).toEqual(["saved-searches"]);
  });

  it("dataConfidence key for a product", () => {
    expect(queryKeys.dataConfidence(5)).toEqual(["data-confidence", 5]);
  });

  it("lists is a static tuple", () => {
    expect(queryKeys.lists).toEqual(["lists"]);
  });

  it("listItems key for a list id", () => {
    expect(queryKeys.listItems("abc")).toEqual(["list-items", "abc"]);
  });

  it("sharedList key for a token", () => {
    expect(queryKeys.sharedList("tok")).toEqual(["shared-list", "tok"]);
  });

  it("avoidProductIds is a static tuple", () => {
    expect(queryKeys.avoidProductIds).toEqual(["avoid-product-ids"]);
  });

  it("favoriteProductIds is a static tuple", () => {
    expect(queryKeys.favoriteProductIds).toEqual(["favorite-product-ids"]);
  });

  it("productListMembership key for a product", () => {
    expect(queryKeys.productListMembership(3)).toEqual([
      "product-list-membership",
      3,
    ]);
  });

  it("compareProducts sorts ids deterministically", () => {
    expect(queryKeys.compareProducts([3, 1, 2])).toEqual([
      "compare-products",
      "1,2,3",
    ]);
  });

  it("savedComparisons is a static tuple", () => {
    expect(queryKeys.savedComparisons).toEqual(["saved-comparisons"]);
  });

  it("sharedComparison key for a token", () => {
    expect(queryKeys.sharedComparison("xyz")).toEqual([
      "shared-comparison",
      "xyz",
    ]);
  });

  it("scanHistory key includes page and filter", () => {
    expect(queryKeys.scanHistory(2, "food")).toEqual([
      "scan-history",
      { page: 2, filter: "food" },
    ]);
  });

  it("mySubmissions key for a page number", () => {
    expect(queryKeys.mySubmissions(1)).toEqual(["my-submissions", 1]);
  });
});

// ─── staleTimes ─────────────────────────────────────────────────────────────

describe("staleTimes", () => {
  it("preferences is 5 minutes", () => {
    expect(staleTimes.preferences).toBe(5 * 60 * 1000);
  });

  it("search is 2 minutes", () => {
    expect(staleTimes.search).toBe(2 * 60 * 1000);
  });

  it("product is 10 minutes", () => {
    expect(staleTimes.product).toBe(10 * 60 * 1000);
  });

  it("all values are positive numbers", () => {
    for (const [, value] of Object.entries(staleTimes)) {
      expect(value).toBeGreaterThan(0);
    }
  });

  it("healthProfiles is 5 minutes", () => {
    expect(staleTimes.healthProfiles).toBe(5 * 60 * 1000);
  });

  it("autocomplete is 30 seconds", () => {
    expect(staleTimes.autocomplete).toBe(30 * 1000);
  });

  it("filterOptions is 10 minutes", () => {
    expect(staleTimes.filterOptions).toBe(10 * 60 * 1000);
  });

  it("categoryListing is 5 minutes", () => {
    expect(staleTimes.categoryListing).toBe(5 * 60 * 1000);
  });

  it("categoryOverview is 10 minutes", () => {
    expect(staleTimes.categoryOverview).toBe(10 * 60 * 1000);
  });

  it("alternatives is 10 minutes", () => {
    expect(staleTimes.alternatives).toBe(10 * 60 * 1000);
  });

  it("listItems is 2 minutes", () => {
    expect(staleTimes.listItems).toBe(2 * 60 * 1000);
  });

  it("compareProducts is 5 minutes", () => {
    expect(staleTimes.compareProducts).toBe(5 * 60 * 1000);
  });

  it("scanHistory is 2 minutes", () => {
    expect(staleTimes.scanHistory).toBe(2 * 60 * 1000);
  });

  it("mySubmissions is 5 minutes", () => {
    expect(staleTimes.mySubmissions).toBe(5 * 60 * 1000);
  });

  it("has the same keys as queryKeys (completeness check)", () => {
    const qkKeys = Object.keys(queryKeys);
    const stKeys = Object.keys(staleTimes);
    // staleTimes may not cover every queryKey (some share stale times)
    // but every staleTime key should correspond to a queryKey
    for (const key of stKeys) {
      expect(qkKeys).toContain(key);
    }
  });
});
