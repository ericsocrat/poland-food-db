/**
 * QA Fixture Seeder — Seeds deterministic test products into Supabase
 *
 * Creates synthetic products with full nutrition, allergen, and ingredient
 * data so the quality-gate Playwright tests have real rendered DOM to audit.
 *
 * Usage:
 *   node tests/quality/seed-fixtures.mjs
 *
 * Outputs KEY=VALUE lines to stdout for CI to capture into $GITHUB_ENV.
 * Requires NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY env vars.
 *
 * Idempotent — safe to run multiple times (upserts on unique constraints).
 *
 * @see https://github.com/ericsocrat/tryvit/issues/553
 */

import { createClient } from "@supabase/supabase-js";

/* ── Environment ─────────────────────────────────────────────────────────── */

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_KEY) {
  console.warn(
    "⚠️  Skipping QA fixture seeding — missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"
  );
  process.exit(0);
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

/* ── Helpers ──────────────────────────────────────────────────────────────── */

/**
 * Upsert a product on (country, brand, product_name) and return its product_id.
 *
 * If a column doesn't exist on the remote schema (e.g., nutri_score_source
 * on a staging DB that hasn't had all migrations pushed), retry without the
 * offending column. This makes the seeder work against any schema version.
 */
async function upsertProduct(product) {
  const payload = { ...product };
  const MAX_RETRIES = 5;

  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    const { data, error } = await supabase
      .from("products")
      .upsert(payload, { onConflict: "country,brand,product_name" })
      .select("product_id")
      .single();

    if (!error) return data.product_id;

    // Handle missing column: strip it and retry
    const match = error.message.match(
      /Could not find the '(\w+)' column/
    );
    if (match) {
      const col = match[1];
      console.warn(
        `  ⚠️  Column '${col}' not in remote schema — removing from payload`
      );
      delete payload[col];
      continue;
    }

    throw new Error(
      `Failed to upsert product "${product.product_name}": ${error.message}`
    );
  }

  throw new Error(
    `Failed to upsert product "${product.product_name}" after ${MAX_RETRIES} retries`
  );
}

/**
 * Upsert a nutrition_facts row on product_id.
 * Handles missing columns the same way as upsertProduct.
 */
async function upsertNutrition(nutrition) {
  const payload = { ...nutrition };
  const MAX_RETRIES = 5;

  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    const { error } = await supabase
      .from("nutrition_facts")
      .upsert(payload, { onConflict: "product_id" });

    if (!error) return;

    const match = error.message.match(
      /Could not find the '(\w+)' column/
    );
    if (match) {
      const col = match[1];
      console.warn(
        `  ⚠️  Column '${col}' not in nutrition_facts — removing from payload`
      );
      delete payload[col];
      continue;
    }

    throw new Error(
      `Failed to upsert nutrition for product ${nutrition.product_id}: ${error.message}`
    );
  }
}

/**
 * Upsert allergen info on (product_id, tag, type).
 */
async function upsertAllergen(allergen) {
  const { error } = await supabase
    .from("product_allergen_info")
    .upsert(allergen, { onConflict: "product_id,tag,type" });

  if (error) {
    throw new Error(
      `Failed to upsert allergen for product ${allergen.product_id}: ${error.message}`
    );
  }
}

/**
 * Look up an ingredient_ref by name_en. Returns ingredient_id or null.
 */
async function findIngredient(nameEn) {
  const { data } = await supabase
    .from("ingredient_ref")
    .select("ingredient_id")
    .eq("name_en", nameEn)
    .limit(1)
    .maybeSingle();

  return data?.ingredient_id ?? null;
}

/**
 * Upsert a product_ingredient row on (product_id, ingredient_id, position).
 */
async function upsertIngredient(row) {
  const { error } = await supabase
    .from("product_ingredient")
    .upsert(row, { onConflict: "product_id,ingredient_id,position" });

  if (error) {
    // Non-fatal — ingredient data is nice-to-have for QA
    console.warn(
      `⚠️  Failed to upsert ingredient (pos ${row.position}) for product ${row.product_id}: ${error.message}`
    );
  }
}

/* ── Fixture Definitions ─────────────────────────────────────────────────── */

/**
 * Product 1: Full data — nutrition, scores, allergens, ingredients.
 * Used for: QA_PRODUCT_ID, QA_PRODUCT_WITH_ALT, QA_PRODUCT_WITH_ALLERGENS.
 * Score ~45 means healthier alternatives exist in Dairy.
 */
const PRODUCT_FULL = {
  country: "PL",
  brand: "QA Test Brand",
  product_name: "QA Ser Żółty Gouda 45%",
  category: "Dairy",
  product_type: "cheese",
  prep_method: "not-applicable",
  controversies: "none",
  unhealthiness_score: 45,
  nutri_score_label: "D",
  nutri_score_source: "manual",
  nova_classification: "3",
  confidence: "verified",
  data_completeness_pct: 90,
  high_sugar_flag: "NO",
  high_salt_flag: "YES",
  high_sat_fat_flag: "YES",
  high_additive_load: "NO",
  ingredient_concern_score: 5,
  source_type: "manual",
  is_deprecated: false,
};

const NUTRITION_FULL = {
  calories: 356,
  total_fat_g: 27.0,
  saturated_fat_g: 17.5,
  trans_fat_g: 0.5,
  carbs_g: 0.0,
  sugars_g: 0.0,
  fibre_g: 0.0,
  protein_g: 25.0,
  salt_g: 1.8,
};

/**
 * Product 2: Healthiest dairy — very low score, no better alternatives.
 * Used for: QA_PRODUCT_NO_ALT.
 */
const PRODUCT_NO_ALT = {
  country: "PL",
  brand: "QA Test Brand",
  product_name: "QA Jogurt Naturalny 0%",
  category: "Dairy",
  product_type: "yogurt",
  prep_method: "not-applicable",
  controversies: "none",
  unhealthiness_score: 5,
  nutri_score_label: "A",
  nutri_score_source: "manual",
  nova_classification: "1",
  confidence: "verified",
  data_completeness_pct: 85,
  high_sugar_flag: "NO",
  high_salt_flag: "NO",
  high_sat_fat_flag: "NO",
  high_additive_load: "NO",
  ingredient_concern_score: 0,
  source_type: "manual",
  is_deprecated: false,
};

const NUTRITION_NO_ALT = {
  calories: 40,
  total_fat_g: 0.1,
  saturated_fat_g: 0.05,
  trans_fat_g: 0.0,
  carbs_g: 5.8,
  sugars_g: 3.5,
  fibre_g: 0.0,
  protein_g: 4.5,
  salt_g: 0.12,
};

/**
 * Product 3: With allergens — multiple allergen declarations.
 * Used for: QA_PRODUCT_WITH_ALLERGENS (also has full data).
 */
const PRODUCT_ALLERGENS = {
  country: "PL",
  brand: "QA Test Brand",
  product_name: "QA Sernik z Orzechami",
  category: "Dairy",
  product_type: "dessert",
  prep_method: "baked",
  controversies: "none",
  unhealthiness_score: 52,
  nutri_score_label: "D",
  nutri_score_source: "manual",
  nova_classification: "4",
  confidence: "estimated",
  data_completeness_pct: 80,
  high_sugar_flag: "YES",
  high_salt_flag: "NO",
  high_sat_fat_flag: "YES",
  high_additive_load: "NO",
  ingredient_concern_score: 10,
  source_type: "manual",
  is_deprecated: false,
};

const NUTRITION_ALLERGENS = {
  calories: 320,
  total_fat_g: 18.0,
  saturated_fat_g: 10.0,
  trans_fat_g: 0.2,
  carbs_g: 28.0,
  sugars_g: 22.0,
  fibre_g: 1.0,
  protein_g: 12.0,
  salt_g: 0.5,
};

/**
 * Product 4: Unknown Nutri-Score — label set to UNKNOWN.
 * Used for: QA_PRODUCT_MISSING_NS.
 */
const PRODUCT_NO_NS = {
  country: "PL",
  brand: "QA Test Brand",
  product_name: "QA Kefir Tradycyjny",
  category: "Dairy",
  product_type: "kefir",
  prep_method: "not-applicable",
  controversies: "none",
  unhealthiness_score: 12,
  nutri_score_label: "UNKNOWN",
  nutri_score_source: "unknown",
  nova_classification: "1",
  confidence: "low",
  data_completeness_pct: 55,
  high_sugar_flag: "NO",
  high_salt_flag: "NO",
  high_sat_fat_flag: "NO",
  high_additive_load: "NO",
  ingredient_concern_score: 0,
  source_type: "manual",
  is_deprecated: false,
};

const NUTRITION_NO_NS = {
  calories: 55,
  total_fat_g: 2.5,
  saturated_fat_g: 1.5,
  trans_fat_g: 0.0,
  carbs_g: 4.0,
  sugars_g: 3.0,
  fibre_g: 0.0,
  protein_g: 3.3,
  salt_g: 0.1,
};

/* ── Main ────────────────────────────────────────────────────────────────── */

async function main() {
  console.error("🌱 Seeding QA fixture data...\n");

  // ── Verify reference data exists ────────────────────────────────────────
  const { data: categoryCheck } = await supabase
    .from("category_ref")
    .select("category")
    .eq("category", "Dairy")
    .maybeSingle();

  if (!categoryCheck) {
    console.error(
      "❌ category_ref does not contain 'Dairy'. Run reference data seeds first."
    );
    process.exit(1);
  }

  // ── Upsert products ────────────────────────────────────────────────────
  const productFullId = await upsertProduct(PRODUCT_FULL);
  const productNoAltId = await upsertProduct(PRODUCT_NO_ALT);
  const productAllergensId = await upsertProduct(PRODUCT_ALLERGENS);
  const productNoNsId = await upsertProduct(PRODUCT_NO_NS);

  console.error(`  ✅ Product (full):       ID ${productFullId}`);
  console.error(`  ✅ Product (no-alt):     ID ${productNoAltId}`);
  console.error(`  ✅ Product (allergens):  ID ${productAllergensId}`);
  console.error(`  ✅ Product (no-ns):      ID ${productNoNsId}`);

  // ── Upsert nutrition ───────────────────────────────────────────────────
  await upsertNutrition({ product_id: productFullId, ...NUTRITION_FULL });
  await upsertNutrition({ product_id: productNoAltId, ...NUTRITION_NO_ALT });
  await upsertNutrition({
    product_id: productAllergensId,
    ...NUTRITION_ALLERGENS,
  });
  await upsertNutrition({ product_id: productNoNsId, ...NUTRITION_NO_NS });
  console.error("  ✅ Nutrition facts seeded for all 4 products");

  // ── Upsert allergens for product 3 ─────────────────────────────────────
  const allergens = [
    { product_id: productAllergensId, tag: "milk", type: "contains" },
    { product_id: productAllergensId, tag: "eggs", type: "contains" },
    { product_id: productAllergensId, tag: "gluten", type: "contains" },
    { product_id: productAllergensId, tag: "tree-nuts", type: "traces" },
  ];

  for (const allergen of allergens) {
    await upsertAllergen(allergen);
  }
  console.error(`  ✅ Allergens seeded (${allergens.length} entries)`);

  // ── Also add allergens to product 1 (QA_PRODUCT_WITH_ALLERGENS = full) ─
  const fullAllergens = [
    { product_id: productFullId, tag: "milk", type: "contains" },
  ];
  for (const allergen of fullAllergens) {
    await upsertAllergen(allergen);
  }
  console.error("  ✅ Allergens seeded for full product (milk)");

  // ── Upsert ingredients (best-effort — requires ingredient_ref data) ────
  const ingredientNames = ["water", "milk", "sugar", "salt", "cream"];
  const ingredientIds = {};

  for (const name of ingredientNames) {
    const id = await findIngredient(name);
    if (id) ingredientIds[name] = id;
  }

  const foundCount = Object.keys(ingredientIds).length;
  if (foundCount >= 2) {
    const entries = Object.entries(ingredientIds);
    for (let i = 0; i < entries.length; i++) {
      const [, ingredientId] = entries[i];
      await upsertIngredient({
        product_id: productFullId,
        ingredient_id: ingredientId,
        position: i + 1,
        is_sub_ingredient: false,
      });
    }
    console.error(
      `  ✅ Ingredients seeded (${foundCount} linked to full product)`
    );
  } else {
    console.warn(
      `  ⚠️  Only ${foundCount} ingredients found in ingredient_ref — skipping ingredient seeding`
    );
  }

  // ── Also find an ingredient_id to export for QA_INGREDIENT_ID ──────────
  let ingredientIdForFixture = "1"; // fallback
  if (ingredientIds.milk) {
    ingredientIdForFixture = String(ingredientIds.milk);
  } else if (foundCount > 0) {
    ingredientIdForFixture = String(Object.values(ingredientIds)[0]);
  }

  // ── Output fixture IDs (stdout only — CI captures via >> $GITHUB_ENV) ──
  console.log(`QA_PRODUCT_ID=${productFullId}`);
  console.log(`QA_PRODUCT_WITH_ALT=${productFullId}`);
  console.log(`QA_PRODUCT_NO_ALT=${productNoAltId}`);
  console.log(`QA_PRODUCT_WITH_ALLERGENS=${productAllergensId}`);
  console.log(`QA_PRODUCT_MISSING_NS=${productNoNsId}`);
  console.log(`QA_CATEGORY_SLUG=dairy`);
  console.log(`QA_INGREDIENT_ID=${ingredientIdForFixture}`);

  console.error("\n🎉 QA fixture seeding complete!\n");
}

main().catch((err) => {
  console.error(`\n❌ QA fixture seeding failed: ${err.message}`);
  process.exit(1);
});
