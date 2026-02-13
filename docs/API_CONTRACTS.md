# Poland Food DB — API Contract Documentation

> **Version:** 1.0 · **Date:** 2026-02-13
> **Stability:** Stable — these surfaces are safe for frontend consumption.

---

## Overview

All API surfaces are **read-only** PostgreSQL views or RPC functions exposed via Supabase PostgREST. They:

- Hide internal-only columns (raw ingredients, source URLs, scoring internals)
- Return deterministic, structured JSON
- Support pagination and sorting where applicable
- Include confidence and provenance info explicitly
- Convert internal text flags (`YES`/`NO`) to proper booleans

### What Is Intentionally Hidden

| Internal Column                     | Reason                           | Exposed Via                                        |
| ----------------------------------- | -------------------------------- | -------------------------------------------------- |
| `ingredients_raw`                   | Raw Polish text, not user-facing | `ingredients.count`, `ingredients.additive_names`  |
| `source_url`, `source_ean`          | Backend provenance details       | `trust.source_type`, `trust.source_confidence_pct` |
| `score_breakdown` version internals | Internal metadata                | Not exposed                                        |
| `controversies`                     | Raw text enum                    | Converted to warning in `api_score_explanation`    |
| `ingredient_concern_score`          | Scoring internal                 | Visible in `score_breakdown.factors`               |
| `score_breakdown` (raw JSONB)       | Complex structure                | Structured via `api_score_explanation`             |

---

## 1. `v_api_category_overview` (SQL View)

**Purpose:** Dashboard — one row per active category with product counts and score statistics.

**PostgREST endpoint:**
```
GET /rest/v1/v_api_category_overview?order=sort_order.asc
```

**Row count:** 20 (one per active category). **No fan-out possible.**

### Response Shape

| Field                  | Type    | Nullable | Description                                 |
| ---------------------- | ------- | -------- | ------------------------------------------- |
| `category`             | text    | No       | Internal category key (e.g. `"Chips"`)      |
| `display_name`         | text    | No       | Human-readable name (e.g. `"Chips"`)        |
| `category_description` | text    | No       | Short description of the category           |
| `icon_emoji`           | text    | No       | Emoji icon for display                      |
| `sort_order`           | integer | No       | Display order (1-20)                        |
| `product_count`        | integer | No       | Number of active products                   |
| `avg_score`            | numeric | Yes¹     | Average unhealthiness score                 |
| `min_score`            | integer | Yes¹     | Lowest score in category                    |
| `max_score`            | integer | Yes¹     | Highest score in category                   |
| `median_score`         | integer | Yes¹     | Median score in category                    |
| `pct_nutri_a_b`        | numeric | Yes¹     | % of products with Nutri-Score A or B       |
| `pct_nova_4`           | numeric | Yes¹     | % of products classified as ultra-processed |

¹ Null only if category has 0 products (theoretically impossible with current data).

### 1b. `v_api_category_overview_by_country` (SQL View) — NEW

**Purpose:** Country-dimensioned dashboard — same columns as the global view plus `country_code`.

One row per `(country, category)` pair for active countries and active categories.

| Field                 | Type | Description                       |
| --------------------- | ---- | --------------------------------- |
| `country_code`        | text | ISO 3166-1 alpha-2 (e.g. `"PL"`)  |
| *(all other columns)* |      | Same as `v_api_category_overview` |

> **Note:** Not directly accessible via PostgREST (RPC-only model). Wrap in an RPC function if frontend access is needed.

---

## 2. `api_product_detail(p_product_id bigint)` (RPC Function)

**Purpose:** Full product detail for the Product Detail screen.

**PostgREST endpoint:**
```
POST /rest/v1/rpc/api_product_detail
Body: {"p_product_id": 32}
```

**Returns:** Single JSONB object with nested sections. Returns `null` if product not found.

### Response Shape

```jsonc
{
  // Identity
  "product_id": 32,              // bigint
  "ean": "5900259135360",         // text, nullable
  "product_name": "Cheetos ...",  // text
  "brand": "Cheetos",             // text
  "category": "Chips",            // text (internal key)
  "category_display": "Chips",    // text (human-readable)
  "category_icon": "🍟",          // text (emoji)
  "product_type": "Grocery",      // text, nullable
  "country": "PL",                // text
  "store_availability": null,     // text, nullable
  "prep_method": "fried",         // text, nullable

  // Scores
  "scores": {
    "unhealthiness_score": 32,    // integer (1-100)
    "score_band": "moderate",     // "low" | "moderate" | "high" | "very_high"
    "nutri_score": "D",           // "A"-"E" | "UNKNOWN" | "NOT-APPLICABLE"
    "nutri_score_color": "#EE8100", // hex color from nutri_score_ref
    "nova_group": "4",            // "1"-"4" (text)
    "processing_risk": "High"     // "Low" | "Moderate" | "High"
  },

  // Flags (all boolean — converted from internal YES/NO text)
  "flags": {
    "high_salt": false,
    "high_sugar": false,
    "high_sat_fat": false,
    "high_additive_load": true,
    "has_palm_oil": false
  },

  // Nutrition per 100g
  "nutrition_per_100g": {
    "calories": 467.0,            // numeric, nullable
    "total_fat_g": 19.0,
    "saturated_fat_g": 1.7,
    "trans_fat_g": 0,
    "carbs_g": 66.0,
    "sugars_g": 4.7,
    "fibre_g": 2.1,
    "protein_g": 6.6,
    "salt_g": 1.1
  },

  // Nutrition per serving (null if no real serving data)
  "nutrition_per_serving": {      // nullable — entire object is null or present
    "serving_g": 80.0,
    "calories": 373.6,
    "total_fat_g": 15.2,
    "saturated_fat_g": 1.36,
    "trans_fat_g": 0.0,
    "carbs_g": 52.8,
    "sugars_g": 3.76,
    "fibre_g": 1.68,
    "protein_g": 5.28,
    "salt_g": 0.88
  },

  // Ingredients
  "ingredients": {
    "count": 26,                  // integer
    "additives_count": 5,         // integer
    "additive_names": "e330, ...",// text, nullable
    "vegan_status": "maybe",      // "yes" | "no" | "maybe"
    "vegetarian_status": "maybe",
    "data_quality": "complete"    // "complete" | "partial" | "missing"
  },

  // Allergens
  "allergens": {
    "count": 1,                   // integer
    "tags": "en:gluten",          // text, nullable (comma-separated)
    "trace_count": 1,
    "trace_tags": "en:soybeans"   // text, nullable
  },

  // Data trust
  "trust": {
    "confidence": "verified",               // "verified" | "estimated" | "low"
    "data_completeness_pct": 100,            // integer (0-100)
    "source_type": "off_api",                // "off_api" | "manual" | "label_scan"
    "source_confidence_pct": 90,             // integer (0-100)
    "nutrition_data_quality": "clean",       // "clean" | "suspect"
    "ingredient_data_quality": "complete"    // "complete" | "partial" | "missing"
  }
}
```

---

## 3. `api_category_listing(...)` (RPC Function)

**Purpose:** Paged product listing within a category with sort options.

**PostgREST endpoint:**
```
POST /rest/v1/rpc/api_category_listing
Body: {
  "p_category": "Chips",
  "p_sort_by": "score",
  "p_sort_dir": "asc",
  "p_limit": 20,
  "p_offset": 0
}
```

### Parameters

| Param        | Type    | Default    | Description                                                       |
| ------------ | ------- | ---------- | ----------------------------------------------------------------- |
| `p_category` | text    | *required* | Category key (must match `category_ref.category`)                 |
| `p_sort_by`  | text    | `"score"`  | Sort field: `score`, `calories`, `protein`, `name`, `nutri_score` |
| `p_sort_dir` | text    | `"asc"`    | Sort direction: `asc` or `desc`                                   |
| `p_limit`    | integer | 20         | Page size (1-100, clamped)                                        |
| `p_offset`   | integer | 0          | Offset for pagination (clamped to ≥0)                             |
| `p_country`  | text    | `null`     | Country filter — auto-resolved if NULL (see §10)                  |

### Response Shape

```jsonc
{
  "category": "Chips",
  "country": "PL",              // resolved country (never null — see §10)
  "total_count": 28,        // total products in category (for pagination)
  "limit": 20,
  "offset": 0,
  "sort_by": "score",
  "sort_dir": "asc",
  "products": [
    {
      "product_id": 1844,
      "ean": "5900259128546",
      "product_name": "Oven Baked ...",
      "brand": "Lay's",
      "unhealthiness_score": 17,
      "score_band": "low",           // "low" | "moderate" | "high" | "very_high"
      "nutri_score": "C",
      "nova_group": "4",
      "processing_risk": "High",
      "calories": 441.0,
      "total_fat_g": 14.0,
      "protein_g": 5.7,
      "sugars_g": 6.1,
      "salt_g": 0.0,
      "high_salt_flag": false,        // boolean
      "high_sugar_flag": true,
      "high_sat_fat_flag": false,
      "confidence": "estimated",
      "data_completeness_pct": 95
    }
    // ... more products
  ]
}
```

---

## 4. `api_score_explanation(p_product_id bigint)` (RPC Function)

**Purpose:** "Why this score?" modal — detailed breakdown with human-readable context.

**PostgREST endpoint:**
```
POST /rest/v1/rpc/api_score_explanation
Body: {"p_product_id": 32}
```

### Response Shape

```jsonc
{
  "product_id": 32,
  "product_name": "Cheetos Flamin Hot",
  "brand": "Cheetos",
  "category": "Chips",

  // Structured score breakdown (from explain_score_v32)
  "score_breakdown": {
    "version": "v3.2",
    "final_score": 32,
    "factors": [
      {
        "name": "saturated_fat",     // factor identifier
        "weight": 0.17,              // weight in formula (0-1)
        "raw": 17.0,                 // raw sub-score (0-100)
        "weighted": 2.89,            // weight × raw
        "input": 1.7,                // actual product value
        "ceiling": 10.0              // max reference value
      }
      // ... 8 more factors
    ]
  },

  // Human-readable summary
  "summary": {
    "score": 32,
    "score_band": "moderate",
    "headline": "This product has several areas of nutritional concern.",
    "nutri_score": "D",
    "nova_group": "4",
    "processing_risk": "High"
  },

  // Top contributing factors (sorted by weighted contribution, descending)
  "top_factors": [
    {"name": "calories", "weight": 0.10, "raw": 77.8, "weighted": 7.78, ...},
    {"name": "prep_method", "weight": 0.08, "raw": 80, "weighted": 6.40, ...}
    // ...
  ],

  // Active warnings (null if no warnings)
  "warnings": [
    {"type": "additives", "message": "This product has a high additive load."},
    {"type": "nova_4", "message": "Classified as ultra-processed (NOVA 4)."}
  ],

  // Category context — where this product sits in its category
  "category_context": {
    "category_avg_score": 31.9,     // average score in this category
    "category_rank": 8,              // rank (1 = best in category)
    "category_total": 28,
    "relative_position": "worse_than_average"
    // "much_better_than_average" | "better_than_average" |
    // "worse_than_average" | "much_worse_than_average"
  }
}
```

### Headline Logic

| Score Range | Headline                                                                     |
| ----------- | ---------------------------------------------------------------------------- |
| ≤15         | "This product scores very well. It has low levels of nutrients of concern."  |
| 16-30       | "This product has a moderate profile. Some areas could be better."           |
| 31-50       | "This product has several areas of nutritional concern."                     |
| >50         | "This product has significant nutritional concerns across multiple factors." |

### Warning Types

| Type           | Trigger                      | Message                                   |
| -------------- | ---------------------------- | ----------------------------------------- |
| `high_salt`    | `high_salt_flag = 'YES'`     | "Salt content exceeds 1.5g per 100g."     |
| `high_sugar`   | `high_sugar_flag = 'YES'`    | "Sugar content is elevated."              |
| `high_sat_fat` | `high_sat_fat_flag = 'YES'`  | "Saturated fat content is elevated."      |
| `additives`    | `high_additive_load = 'YES'` | "This product has a high additive load."  |
| `palm_oil`     | `has_palm_oil = true`        | "Contains palm oil."                      |
| `nova_4`       | `nova_classification = '4'`  | "Classified as ultra-processed (NOVA 4)." |

---

## 5. `api_better_alternatives(...)` (RPC Function)

**Purpose:** Product detail → "find healthier options" button.

**PostgREST endpoint:**
```
POST /rest/v1/rpc/api_better_alternatives
Body: {
  "p_product_id": 32,
  "p_same_category": true,
  "p_limit": 5
}
```

### Parameters

| Param             | Type    | Default    | Description                    |
| ----------------- | ------- | ---------- | ------------------------------ |
| `p_product_id`    | bigint  | *required* | Source product ID              |
| `p_same_category` | boolean | `true`     | Restrict to same category only |
| `p_limit`         | integer | 5          | Max alternatives to return     |

### Response Shape

```jsonc
{
  "source_product": {
    "product_id": 32,
    "product_name": "Cheetos Flamin Hot",
    "brand": "Cheetos",
    "category": "Chips",
    "unhealthiness_score": 32,
    "nutri_score": "D"
  },
  "search_scope": "same_category",    // "same_category" | "all_categories"
  "alternatives_count": 3,
  "alternatives": [
    {
      "product_id": 1844,
      "product_name": "Oven Baked ...",
      "brand": "Lay's",
      "category": "Chips",
      "unhealthiness_score": 17,
      "score_improvement": 15,         // how many points better
      "nutri_score": "C",
      "similarity": 0.000,             // Jaccard similarity (0-1)
      "shared_ingredients": 0
    }
    // ... more alternatives, sorted by score_improvement DESC
  ]
}
```

---

## 6. `api_search_products(...)` (RPC Function)

**Purpose:** Search bar — full-text + trigram fuzzy search.

**PostgREST endpoint:**
```
POST /rest/v1/rpc/api_search_products
Body: {
  "p_query": "Lay",
  "p_category": null,
  "p_limit": 20,
  "p_offset": 0
}
```

### Parameters

| Param        | Type    | Default    | Description                                      |
| ------------ | ------- | ---------- | ------------------------------------------------ |
| `p_query`    | text    | *required* | Search string (min 2 characters)                 |
| `p_category` | text    | `null`     | Optional category filter                         |
| `p_limit`    | integer | 20         | Page size (1-100, clamped)                       |
| `p_offset`   | integer | 0          | Offset for pagination                            |
| `p_country`  | text    | `null`     | Country filter — auto-resolved if NULL (see §10) |

### Response Shape

```jsonc
{
  "query": "Lay",
  "category": null,
  "country": "PL",              // resolved country (never null — see §10)
  "total_count": 16,
  "limit": 20,
  "offset": 0,
  "results": [
    {
      "product_id": 1828,
      "product_name": "Lays Papryka",
      "brand": "Lay's",
      "category": "Chips",
      "unhealthiness_score": 20,
      "score_band": "low",
      "nutri_score": "UNKNOWN",
      "nova_group": "4",
      "relevance": 0.533             // trigram similarity (0-1)
    }
    // ... sorted by: prefix match first, then similarity, then score
  ]
}
```

### Search Behavior

1. Matches product names and brands using `ILIKE` (substring) + `pg_trgm` similarity
2. Results sorted by: exact prefix match → trigram similarity → unhealthiness score
3. Minimum query length: 2 characters (returns error JSON if shorter)
4. Uses GIN trigram indexes on `product_name` and `brand` for performance

### Error Response

```json
{"api_version": "1.0", "error": "Query must be at least 2 characters."}
```

### Country Isolation

`find_better_alternatives()` and `find_similar_products()` automatically restrict
results to the **same country** as the source product. This prevents cross-country
leakage in alternatives and similarity results.

`api_score_explanation()` computes `category_context` (rank, average, position)
only among products from the **same country** as the source product.

---

## Supported Indexes

| Index                         | Table      | Type                                      | Supports               |
| ----------------------------- | ---------- | ----------------------------------------- | ---------------------- |
| `idx_products_category_score` | `products` | btree `(category, product_id)`            | Category listings      |
| `idx_scores_unhealthiness`    | `scores`   | btree `(product_id, unhealthiness_score)` | Sorted score queries   |
| `idx_products_name_trgm`      | `products` | GIN trigram                               | Search by product name |
| `idx_products_brand_trgm`     | `products` | GIN trigram                               | Search by brand        |

---

## Usage Guidelines for Frontend Developers

### Safe Patterns (use freely)
- `v_api_category_overview` — cached dashboard data, 20 rows max
- `api_product_detail(id)` — single product lookup, fast
- `api_product_detail_by_ean(ean)` — barcode scanner lookup, fast
- `api_category_listing(cat, sort, dir, limit, offset)` — paged, max 100/page
- `api_search_products(query)` — debounce 300ms, max 100/page
- `api_data_confidence(id)` — single product confidence lookup, fast
- `api_get_user_preferences()` — authenticated user's preferences, fast
- `v_product_confidence` — materialized view, pre-computed for all 1,025 products

### Expensive Patterns (cache or limit)
- `api_score_explanation(id)` — computes score + category context, ~50ms
- `api_better_alternatives(id)` — joins similarity function, ~200ms for large categories
- `compute_data_confidence(id)` — dynamic computation, prefer `v_product_confidence` or `api_data_confidence()`

### Never Do
- `SELECT * FROM v_master` in frontend — exposes 63 internal columns
- Call `find_similar_products()` directly — use `api_better_alternatives()` wrapper
- Skip pagination on category listings — always pass `p_limit`

---

## 7. Data Confidence API

### `api_data_confidence(p_product_id bigint)` → JSONB

Returns a composite data confidence score (0–100) indicating how reliable the data is.

**PostgREST:** `POST /rpc/api_data_confidence` with `{ "p_product_id": 32 }`

**Response shape:**
```jsonc
{
  "product_id": 32,
  "confidence_score": 98,        // 0-100
  "confidence_band": "high",     // "high" (≥80) | "medium" (50-79) | "low" (<50)
  "components": {
    "nutrition":    { "points": 30, "max": 30 },  // 5 pts each for 6 key nutrients
    "ingredients":  { "points": 25, "max": 25 },  // 15 if raw text + 10 if normalized
    "source":       { "points": 18, "max": 20 },  // mapped from products.source_type
    "ean":          { "points": 10, "max": 10 },  // 10 if EAN present
    "allergens":    { "points": 10, "max": 10 },  // 10 if allergen declarations exist
    "serving_data": { "points": 5,  "max": 5 }   // 5 if real per-serving data exists
  },
  "data_completeness_profile": {
    "ingredients": "complete",   // "complete" | "partial" | "missing"
    "nutrition":   "full",       // "full" | "partial" | "missing"
    "allergens":   "known"       // "known" | "unknown"
  },
  "missing_data": [],            // e.g. ["ean", "allergen_declarations", "per_serving_data"]
  "explanation": "This product has comprehensive data from verified sources. The score is highly reliable."
}
```

**Confidence bands:**
| Band     | Score | Meaning                                                             |
| -------- | ----- | ------------------------------------------------------------------- |
| `high`   | ≥80   | Comprehensive data from verified sources. Score is highly reliable. |
| `medium` | 50–79 | Partial data coverage. Some fields may be estimated.                |
| `low`    | <50   | Limited data. Score may not fully reflect the product's profile.    |

### `v_product_confidence` (Materialized View)

Pre-computed confidence for all 1,025 products. Faster than calling `compute_data_confidence()` per-product.

**PostgREST:** `GET /v_product_confidence?confidence_band=eq.low`

| Column              | Type   | Description                  |
| ------------------- | ------ | ---------------------------- |
| `product_id`        | bigint | Product identifier           |
| `product_name`      | text   | Product name                 |
| `brand`             | text   | Brand name                   |
| `category`          | text   | Product category             |
| `nutrition_pts`     | int    | 0–30 nutrition completeness  |
| `ingredient_pts`    | int    | 0–25 ingredient completeness |
| `source_pts`        | int    | 0–20 source confidence       |
| `ean_pts`           | int    | 0–10 EAN presence            |
| `allergen_pts`      | int    | 0–10 allergen declarations   |
| `serving_pts`       | int    | 0–5 per-serving data         |
| `confidence_score`  | int    | 0–100 composite              |
| `confidence_band`   | text   | high/medium/low              |
| `ingredient_status` | text   | complete/partial/missing     |
| `nutrition_status`  | text   | full/partial/missing         |
| `allergen_status`   | text   | known/unknown                |

> **Refresh:** Run `REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;` after data updates.

---

## 8. Barcode Scanner: `api_product_detail_by_ean(p_ean text, p_country text DEFAULT NULL)`

**Purpose:** Barcode scanner endpoint. Looks up a product by EAN, scoped to a resolved country (see §10).

**PostgREST:** `POST /rpc/api_product_detail_by_ean` with `{ "p_ean": "5900259135360" }`

**Success Response:** Same as `api_product_detail` plus `scan` metadata:
```jsonc
{
  // ... all api_product_detail keys ...
  "scan": {
    "scanned_ean": "5900259135360",
    "found": true,
    "alternative_count": 3       // number of healthier alternatives available
  }
}
```

**Not Found Response:**
```json
{"api_version": "1.0", "ean": "0000000000000", "country": "PL", "found": false, "error": "Product not found for this barcode."}
```

**Access:** anon, authenticated, service_role

---

## 9. Preference-Aware Filtering

All major API surfaces (`api_search_products`, `api_category_listing`, `api_better_alternatives`) now accept optional preference parameters:

| Parameter             | Type    | Default | Description                                          |
| --------------------- | ------- | ------- | ---------------------------------------------------- |
| `p_diet_preference`   | text    | NULL    | `'vegan'` or `'vegetarian'` — excludes non-matching  |
| `p_avoid_allergens`   | text[]  | NULL    | Array of `en:` tags (e.g. `ARRAY['en:gluten']`)      |
| `p_strict_diet`       | boolean | false   | When true, `'maybe'`/`'unknown'` also excluded       |
| `p_strict_allergen`   | boolean | false   | When true, products with no allergen data are hidden |
| `p_treat_may_contain` | boolean | false   | When true, `'traces'` treated as unsafe              |

All parameters have defaults — existing callers are unaffected. `api_version` remains `'1.0'`.

### Internal: `check_product_preferences()`

Reusable STABLE function that returns `true` if a product passes all diet + allergen filters. Used by all preference-aware API surfaces. Not callable by anon.

---

## 10. User Preferences: `api_get_user_preferences()` / `api_set_user_preferences(...)`

**Purpose:** Manage per-user personalization settings (requires authentication).

### `api_get_user_preferences()`

**PostgREST:** `POST /rpc/api_get_user_preferences` (no body, uses JWT)

**Response (preferences set):**
```jsonc
{
  "api_version": "1.0",
  "user_id": "uuid",
  "country": "PL",
  "diet_preference": "vegan",
  "avoid_allergens": ["en:gluten", "en:milk"],
  "strict_allergen": false,
  "strict_diet": false,
  "treat_may_contain_as_unsafe": false,
  "created_at": "...",
  "updated_at": "..."
}
```

**Response (no preferences):**
```json
{"api_version": "1.0", "has_preferences": false, "message": "No preferences set. Use api_set_user_preferences to configure."}
```

### `api_set_user_preferences(...)`

| Parameter                       | Type    | Default | Notes                                  |
| ------------------------------- | ------- | ------- | -------------------------------------- |
| `p_country`                     | text    | `'PL'`  | Validated against `country_ref`        |
| `p_diet_preference`             | text    | NULL    | `'none'`, `'vegetarian'`, or `'vegan'` |
| `p_avoid_allergens`             | text[]  | NULL    | Tags must use `en:` prefix             |
| `p_strict_allergen`             | boolean | false   |                                        |
| `p_strict_diet`                 | boolean | false   |                                        |
| `p_treat_may_contain_as_unsafe` | boolean | false   |                                        |

**PostgREST:** `POST /rpc/api_set_user_preferences` with `{ "p_country": "PL", "p_diet_preference": "vegan" }`

Returns the updated preference profile (same shape as `api_get_user_preferences`).

**Access:** authenticated, service_role only (anon blocked)

### `user_preferences` Table

RLS-protected. Each user can only read/write their own row. Enforced by `auth.uid() = user_id` policies on SELECT, INSERT, UPDATE, and DELETE.

---

## 10. Auto-Country Resolution

All country-scoped API functions (`api_search_products`, `api_category_listing`, `api_product_detail_by_ean`) use `resolve_effective_country(p_country)` internally to guarantee a non-NULL country scope. The resolution order is:

1. **Explicit parameter** — if the caller passes a non-empty `p_country`, use it as-is.
2. **User preference** — if the caller is authenticated and has a row in `user_preferences`, use `user_preferences.country`.
3. **System default** — fall back to the first active country in `country_ref` (alphabetically).

**Implications:**
- The `country` field in all responses is **never null** — it always reflects the resolved value.
- Anonymous callers with no explicit `p_country` get the system default (currently `'PL'`).
- There is no "all countries" mode — every query is scoped to exactly one country.
- `api_better_alternatives` does NOT use this helper; it infers country from the source product.
- `resolve_effective_country` is an internal SECURITY DEFINER function with `SET search_path = public`: EXECUTE REVOKE'd from `PUBLIC`, `anon`, and `authenticated`.

### Allergen Tag Enforcement

All tags in `product_allergen_info` must start with `en:` (e.g., `en:gluten`, `en:milk`). This is enforced at the schema level by the `chk_allergen_tag_en_prefix` CHECK constraint. Tags that don't match the `en:` prefix are rejected by the database on INSERT/UPDATE.

