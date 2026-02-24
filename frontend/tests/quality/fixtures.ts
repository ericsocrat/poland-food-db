/**
 * Quality Gate — Deterministic Fixtures
 *
 * Single source of truth for all product IDs, category slugs, and
 * other stable identifiers used by quality-gate tests.  Every audit
 * file imports from here — no hardcoded IDs elsewhere.
 *
 * All values support env-var overrides so CI can point to its own
 * seed data without code changes.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/172
 */

import type { APIRequestContext } from "@playwright/test";

/* ── Fixture Values ──────────────────────────────────────────────────────── */

export const FIXTURES = {
  // ── Products ──────────────────────────────────────────────────────────
  /** Product with full data (nutrition, scores, alternatives, allergens) */
  productId: process.env.QA_PRODUCT_ID ?? "1",

  /** Product that has at least one alternative */
  productWithAlternatives: process.env.QA_PRODUCT_WITH_ALT ?? "1",

  /** Product with zero alternatives */
  productNoAlternatives: process.env.QA_PRODUCT_NO_ALT ?? "2",

  /** Product with allergen warnings */
  productWithAllergens: process.env.QA_PRODUCT_WITH_ALLERGENS ?? "3",

  /** Product where Nutri-Score is null / missing */
  productMissingNutriscore: process.env.QA_PRODUCT_MISSING_NS ?? "4",

  // ── Categories ────────────────────────────────────────────────────────
  /** Category with ≥ 3 products, stable slug */
  categorySlug: process.env.QA_CATEGORY_SLUG ?? "dairy",

  // ── Ingredients ───────────────────────────────────────────────────────
  /** Ingredient that exists and has linked products */
  ingredientId: process.env.QA_INGREDIENT_ID ?? "1",

  // ── Search ────────────────────────────────────────────────────────────
  /** Query that returns results */
  searchQuery: "mleko",

  /** Query that returns zero results */
  searchQueryNoResults: "xyznonexistent99",
} as const;

/* ── Type guard ──────────────────────────────────────────────────────────── */

/** Every fixture value is a string. */
export type FixtureValues = typeof FIXTURES;
export type FixtureKey = keyof FixtureValues;

/* ── Seed Assumptions ────────────────────────────────────────────────────── */

/**
 * Documents the minimum data the CI/test environment must provide.
 * If fixture seeding is needed, add `supabase/seed/qa-fixtures.sql`.
 *
 * | Fixture                  | Requirement                                       |
 * |--------------------------|---------------------------------------------------|
 * | productId                | Full nutrition data, scores, alternatives, allergens |
 * | productWithAlternatives  | At least one alternative product                  |
 * | productNoAlternatives    | Zero alternatives                                 |
 * | productWithAllergens     | Allergen warnings present                         |
 * | productMissingNutriscore | Nutri-Score is null                               |
 * | categorySlug             | Category with ≥ 3 products                        |
 * | ingredientId             | Ingredient with linked products                   |
 */

/* ── Fixture Validation ─────────────────────────────────────────────────── */

interface FixtureCheck {
  name: string;
  path: string;
}

/**
 * Validates that required fixtures are reachable in the running app.
 * Call this **before** audit runs so missing data fails loudly instead
 * of producing silent skips or misleading screenshots.
 *
 * @throws {Error} Descriptive error naming the missing fixture
 */
export async function validateFixtures(
  request: APIRequestContext
): Promise<void> {
  const checks: FixtureCheck[] = [
    {
      name: "productId",
      path: `/app/product/${FIXTURES.productId}`,
    },
    {
      name: "categorySlug",
      path: `/app/categories/${FIXTURES.categorySlug}`,
    },
    {
      name: "ingredientId",
      path: `/app/ingredient/${FIXTURES.ingredientId}`,
    },
  ];

  const failures: string[] = [];

  for (const check of checks) {
    const response = await request.get(check.path);
    if (response.status() >= 400) {
      failures.push(
        `${check.name} (${check.path}) returned HTTP ${response.status()}`
      );
    }
  }

  if (failures.length > 0) {
    throw new Error(
      `FIXTURE VALIDATION FAILED:\n` +
        failures.map((f) => `  - ${f}`).join("\n") +
        `\n\nEnsure deterministic seed data exists. ` +
        `See tests/quality/fixtures.ts for required fixtures. ` +
        `Override IDs with QA_PRODUCT_ID, QA_CATEGORY_SLUG, QA_INGREDIENT_ID env vars.`
    );
  }
}
