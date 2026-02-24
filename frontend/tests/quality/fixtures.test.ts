/**
 * Unit tests for the quality-gate deterministic fixtures.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/172
 */

import { describe, it, expect, vi } from "vitest";
import { FIXTURES, validateFixtures } from "./fixtures";
import type { FixtureKey } from "./fixtures";

/* ── Fixture values ──────────────────────────────────────────────────────── */

describe("FIXTURES", () => {
  it("all fixture values are strings", () => {
    for (const [, value] of Object.entries(FIXTURES)) {
      expect(typeof value).toBe("string");
    }
  });

  it("contains required keys", () => {
    const required: FixtureKey[] = [
      "productId",
      "productWithAlternatives",
      "productNoAlternatives",
      "productWithAllergens",
      "productMissingNutriscore",
      "categorySlug",
      "ingredientId",
      "searchQuery",
      "searchQueryNoResults",
    ];

    for (const key of required) {
      expect(FIXTURES[key]).toBeDefined();
      expect(FIXTURES[key].length).toBeGreaterThan(0);
    }
  });

  it("search queries are non-empty strings", () => {
    expect(FIXTURES.searchQuery.length).toBeGreaterThan(0);
    expect(FIXTURES.searchQueryNoResults.length).toBeGreaterThan(0);
  });

  it("search queries are distinct", () => {
    expect(FIXTURES.searchQuery).not.toBe(FIXTURES.searchQueryNoResults);
  });
});

/* ── validateFixtures() ──────────────────────────────────────────────────── */

describe("validateFixtures()", () => {
  function mockRequestContext(
    responses: Record<string, number>
  ): Parameters<typeof validateFixtures>[0] {
    return {
      get: vi.fn(async (path: string) => ({
        status: () => responses[path] ?? 200,
      })),
    } as unknown as Parameters<typeof validateFixtures>[0];
  }

  it("passes when all fixtures return 200", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 200,
      [`/app/categories/${FIXTURES.categorySlug}`]: 200,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 200,
    });

    await expect(validateFixtures(request)).resolves.toBeUndefined();
  });

  it("throws descriptive error when a fixture returns 404", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 404,
      [`/app/categories/${FIXTURES.categorySlug}`]: 200,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 200,
    });

    await expect(validateFixtures(request)).rejects.toThrow(
      "FIXTURE VALIDATION FAILED"
    );
    await expect(validateFixtures(request)).rejects.toThrow("productId");
    await expect(validateFixtures(request)).rejects.toThrow("HTTP 404");
  });

  it("throws descriptive error when a fixture returns 500", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 200,
      [`/app/categories/${FIXTURES.categorySlug}`]: 500,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 200,
    });

    await expect(validateFixtures(request)).rejects.toThrow("categorySlug");
    await expect(validateFixtures(request)).rejects.toThrow("HTTP 500");
  });

  it("collects all failures into a single error", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 404,
      [`/app/categories/${FIXTURES.categorySlug}`]: 500,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 503,
    });

    await expect(validateFixtures(request)).rejects.toThrow("productId");
    await expect(validateFixtures(request)).rejects.toThrow("categorySlug");
    await expect(validateFixtures(request)).rejects.toThrow("ingredientId");
  });

  it("error message mentions env var overrides", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 404,
      [`/app/categories/${FIXTURES.categorySlug}`]: 200,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 200,
    });

    await expect(validateFixtures(request)).rejects.toThrow(
      "QA_PRODUCT_ID"
    );
  });

  it("error message mentions fixtures.ts", async () => {
    const request = mockRequestContext({
      [`/app/product/${FIXTURES.productId}`]: 404,
      [`/app/categories/${FIXTURES.categorySlug}`]: 200,
      [`/app/ingredient/${FIXTURES.ingredientId}`]: 200,
    });

    await expect(validateFixtures(request)).rejects.toThrow(
      "tests/quality/fixtures.ts"
    );
  });
});
