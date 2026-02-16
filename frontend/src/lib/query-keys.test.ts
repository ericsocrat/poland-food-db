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
});
