# Frontend API Map — RPC Function Reference

> Auto-generated from migration files on 2026-02-13.
> All functions are called via Supabase RPC: `supabase.rpc('function_name', { params })`.
> All return `jsonb` with `api_version: '1.0'`.
>
> **Auth-only platform:** All 9 core API functions require authentication.
> Anonymous (unauthenticated) access is blocked for all endpoints except shared views.
>
> **Canonical registry:** See [api-registry.yaml](api-registry.yaml) for the structured,
> machine-readable registry of all 107 functions with parameters, return types,
> auth requirements, domain classification, and P95 targets.
>
> **Naming conventions:** See [API_CONVENTIONS.md](API_CONVENTIONS.md) for the RPC naming
> convention, breaking change definition, and security standards.

---

## Country Resolution

All functions that accept `p_country` now use `resolve_effective_country()` internally when the value is `NULL`.

**Resolution priority (2-tier):**
1. Explicit `p_country` parameter (pass-through)
2. Authenticated user's `user_preferences.country`

If neither tier provides a country, resolution returns `NULL` — the frontend must ensure onboarding is complete (country selected) before calling product APIs.

> **Tier-3 removed:** There is no fallback to "first active country". Users must complete onboarding to set their country.

---

## 1. `api_search_products`

**Description:** Full-text + trigram search across products with optional category, country, and dietary/allergen filters.

**Source:** `20260213001600_auto_country_resolution.sql`

| Parameter             | Type      | Default | Required |
| --------------------- | --------- | ------- | -------- |
| `p_query`             | `text`    | —       | **Yes**  |
| `p_category`          | `text`    | `NULL`  | No       |
| `p_limit`             | `integer` | `20`    | No       |
| `p_offset`            | `integer` | `0`     | No       |
| `p_country`           | `text`    | `NULL`  | No       |
| `p_diet_preference`   | `text`    | `NULL`  | No       |
| `p_avoid_allergens`   | `text[]`  | `NULL`  | No       |
| `p_strict_diet`       | `boolean` | `false` | No       |
| `p_strict_allergen`   | `boolean` | `false` | No       |
| `p_treat_may_contain` | `boolean` | `false` | No       |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "query": "...",
  "category": "...|null",
  "country": "PL",          // always resolved, never null
  "total_count": 42,
  "limit": 20,
  "offset": 0,
  "results": [
    {
      "product_id": 1,
      "product_name": "...",
      "brand": "...",
      "category": "...",
      "unhealthiness_score": 35,
      "score_band": "moderate",   // low|moderate|high|very_high
      "nutri_score": "C",
      "nova_group": "3",
      "relevance": 0.85
    }
  ]
}
```

| Property                           | Details                              |
| ---------------------------------- | ------------------------------------ |
| `p_country` default                | `NULL` → auto-resolved               |
| Uses `resolve_effective_country()` | **Yes**                              |
| Limit clamping                     | `1–100`                              |
| Min query length                   | 2 characters                         |
| Auth required                      | **Yes**                              |
| Roles                              | `authenticated`, `service_role` only |
| Security                           | `SECURITY DEFINER`                   |

---

## 2. `api_category_listing`

**Description:** Paged category browse with sortable columns, optional country and dietary/allergen filters.

**Source:** `20260213001600_auto_country_resolution.sql`

| Parameter             | Type      | Default   | Required |
| --------------------- | --------- | --------- | -------- |
| `p_category`          | `text`    | —         | **Yes**  |
| `p_sort_by`           | `text`    | `'score'` | No       |
| `p_sort_dir`          | `text`    | `'asc'`   | No       |
| `p_limit`             | `integer` | `20`      | No       |
| `p_offset`            | `integer` | `0`       | No       |
| `p_country`           | `text`    | `NULL`    | No       |
| `p_diet_preference`   | `text`    | `NULL`    | No       |
| `p_avoid_allergens`   | `text[]`  | `NULL`    | No       |
| `p_strict_diet`       | `boolean` | `false`   | No       |
| `p_strict_allergen`   | `boolean` | `false`   | No       |
| `p_treat_may_contain` | `boolean` | `false`   | No       |

**Valid `p_sort_by` values:** `score`, `calories`, `protein`, `name`, `nutri_score`

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "category": "chips-pl",
  "country": "PL",
  "total_count": 18,
  "limit": 20,
  "offset": 0,
  "sort_by": "score",
  "sort_dir": "asc",
  "products": [
    {
      "product_id": 1,
      "ean": "5901234123457",
      "product_name": "...",
      "brand": "...",
      "unhealthiness_score": 42,
      "score_band": "moderate",
      "nutri_score": "D",
      "nova_group": "4",
      "processing_risk": "high",
      "calories": 530,
      "total_fat_g": 30.0,
      "protein_g": 6.5,
      "sugars_g": 1.2,
      "salt_g": 1.8,
      "high_salt_flag": true,
      "high_sugar_flag": false,
      "high_sat_fat_flag": true,
      "confidence": "high",
      "data_completeness_pct": 92
    }
  ]
}
```

| Property                           | Details                              |
| ---------------------------------- | ------------------------------------ |
| `p_country` default                | `NULL` → auto-resolved               |
| Uses `resolve_effective_country()` | **Yes**                              |
| Limit clamping                     | `1–100`                              |
| Auth required                      | **Yes**                              |
| Roles                              | `authenticated`, `service_role` only |
| Security                           | `SECURITY DEFINER`                   |

---

## 3. `api_product_detail`

**Description:** Full product detail for a single product by ID. Returns identity, scores, flags, nutrition per 100g, ingredients, allergens, trust metadata, and freshness.

**Source:** `20260213001300_close_roadmap_gaps.sql`

| Parameter      | Type     | Default | Required |
| -------------- | -------- | ------- | -------- |
| `p_product_id` | `bigint` | —       | **Yes**  |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "product_id": 1,
  "ean": "5901234123457",
  "product_name": "...",
  "brand": "...",
  "category": "chips-pl",
  "category_display": "Chips (PL)",
  "category_icon": "🥔",
  "product_type": "...",
  "country": "PL",
  "store_availability": "...",
  "prep_method": "...",
  "scores": {
    "unhealthiness_score": 42,
    "score_band": "moderate",
    "nutri_score": "D",
    "nutri_score_color": "#FF6600",
    "nova_group": "4",
    "processing_risk": "high"
  },
  "flags": {
    "high_salt": true,
    "high_sugar": false,
    "high_sat_fat": true,
    "high_additive_load": false,
    "has_palm_oil": true
  },
  "nutrition_per_100g": {
    "calories": 530,
    "total_fat_g": 30.0,
    "saturated_fat_g": 12.0,
    "trans_fat_g": 0.1,
    "carbs_g": 55.0,
    "sugars_g": 1.2,
    "fibre_g": 4.5,
    "protein_g": 6.5,
    "salt_g": 1.8
  },
  "ingredients": {
    "count": 12,
    "additives_count": 3,
    "additive_names": ["E621", "E330"],
    "vegan_status": "no",
    "vegetarian_status": "yes",
    "data_quality": "good"
  },
  "allergens": {
    "count": 2,
    "tags": ["en:gluten", "en:milk"],
    "trace_count": 1,
    "trace_tags": ["en:nuts"]
  },
  "trust": {
    "confidence": "high",
    "data_completeness_pct": 92,
    "source_type": "off",
    "nutrition_data_quality": "good",
    "ingredient_data_quality": "good"
  },
  "freshness": {
    "created_at": "2026-02-10T...",
    "updated_at": "2026-02-12T...",
    "data_age_days": 1
  }
}
```

| Property                           | Details                              |
| ---------------------------------- | ------------------------------------ |
| Has `p_country`                    | **No**                               |
| Uses `resolve_effective_country()` | **No**                               |
| Auth required                      | **Yes**                              |
| Roles                              | `authenticated`, `service_role` only |
| Security                           | `SECURITY DEFINER`                   |

---

## 4. `api_product_detail_by_ean`

**Description:** Barcode scanner endpoint. Looks up a product by EAN within a resolved country, returns the full `api_product_detail` payload enriched with scanner-specific metadata (scanned EAN, found flag, alternative count).

**Source:** `20260213001600_auto_country_resolution.sql`

| Parameter   | Type   | Default | Required |
| ----------- | ------ | ------- | -------- |
| `p_ean`     | `text` | —       | **Yes**  |
| `p_country` | `text` | `NULL`  | No       |

**Returns:** `jsonb`

```jsonc
{
  // ... entire api_product_detail payload ...
  "scan": {
    "scanned_ean": "5901234123457",
    "found": true,
    "alternative_count": 3
  }
}
```

**Not-found response:**
```jsonc
{
  "api_version": "1.0",
  "ean": "5901234123457",
  "country": "PL",
  "found": false,
  "error": "Product not found for this barcode."
}
```

| Property                           | Details                                              |
| ---------------------------------- | ---------------------------------------------------- |
| `p_country` default                | `NULL` → auto-resolved                               |
| Uses `resolve_effective_country()` | **Yes**                                              |
| Internally calls                   | `api_product_detail()`, `find_better_alternatives()` |
| Auth required                      | **Yes**                                              |
| Roles                              | `authenticated`, `service_role` only                 |
| Security                           | `SECURITY DEFINER`                                   |

---

## 5. `api_better_alternatives`

**Description:** Finds healthier alternatives to a given product. Country isolation is automatic (inferred from the source product). Supports diet/allergen filtering.

**Source:** `20260213001500_user_personalization_scanner.sql`

| Parameter             | Type      | Default | Required |
| --------------------- | --------- | ------- | -------- |
| `p_product_id`        | `bigint`  | —       | **Yes**  |
| `p_same_category`     | `boolean` | `true`  | No       |
| `p_limit`             | `integer` | `5`     | No       |
| `p_diet_preference`   | `text`    | `NULL`  | No       |
| `p_avoid_allergens`   | `text[]`  | `NULL`  | No       |
| `p_strict_diet`       | `boolean` | `false` | No       |
| `p_strict_allergen`   | `boolean` | `false` | No       |
| `p_treat_may_contain` | `boolean` | `false` | No       |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "source_product": {
    "product_id": 1,
    "product_name": "...",
    "brand": "...",
    "category": "...",
    "unhealthiness_score": 65,
    "nutri_score": "D"
  },
  "search_scope": "same_category",
  "alternatives": [
    {
      "product_id": 7,
      "product_name": "...",
      "brand": "...",
      "category": "...",
      "unhealthiness_score": 30,
      "score_improvement": 35,
      "nutri_score": "B",
      "similarity": 0.45,
      "shared_ingredients": 5
    }
  ],
  "alternatives_count": 3
}
```

| Property                           | Details                                                                      |
| ---------------------------------- | ---------------------------------------------------------------------------- |
| Has `p_country`                    | **No** (country inferred from source product via `find_better_alternatives`) |
| Uses `resolve_effective_country()` | **No** (country isolation is implicit)                                       |
| Limit clamping                     | `1–20`                                                                       |
| Auth required                      | **Yes**                                                                      |
| Roles                              | `authenticated`, `service_role` only                                         |
| Security                           | `SECURITY DEFINER`                                                           |

---

## 6. `api_score_explanation`

**Description:** Detailed breakdown of how a product's unhealthiness score was computed, including top contributing factors, health warnings, and ranking within its category+country.

**Source:** `20260213001400_country_expansion_readiness.sql`

| Parameter      | Type     | Default | Required |
| -------------- | -------- | ------- | -------- |
| `p_product_id` | `bigint` | —       | **Yes**  |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "product_id": 1,
  "product_name": "...",
  "brand": "...",
  "category": "...",
  "score_breakdown": { /* raw breakdown object */ },
  "summary": {
    "score": 42,
    "score_band": "moderate",
    "headline": "This product has several areas of nutritional concern.",
    "nutri_score": "D",
    "nova_group": "4",
    "processing_risk": "high"
  },
  "top_factors": [
    { "factor": "saturated_fat", "raw": 12, "weighted": 18.5 }
  ],
  "warnings": [
    { "type": "high_salt", "message": "Salt content exceeds 1.5g per 100g." },
    { "type": "nova_4", "message": "Classified as ultra-processed (NOVA 4)." }
  ],
  "category_context": {
    "category_avg_score": 48.3,
    "category_rank": 5,
    "category_total": 18,
    "relative_position": "better_than_average"
  }
}
```

| Property                           | Details                                                                       |
| ---------------------------------- | ----------------------------------------------------------------------------- |
| Has `p_country`                    | **No**                                                                        |
| Uses `resolve_effective_country()` | **No**                                                                        |
| Country isolation                  | `category_context` uses `m.country` from the product itself to scope rank/avg |
| Warning types                      | `high_salt`, `high_sugar`, `high_sat_fat`, `additives`, `palm_oil`, `nova_4`  |
| Auth required                      | **Yes**                                                                       |
| Roles                              | `authenticated`, `service_role` only                                          |
| Security                           | `SECURITY DEFINER`                                                            |

---

## 7. `api_data_confidence`

**Description:** Returns a detailed data confidence assessment for a product (delegating to `compute_data_confidence()`).

**Source:** `20260213001100_api_contract_versioning.sql`

| Parameter      | Type     | Default | Required |
| -------------- | -------- | ------- | -------- |
| `p_product_id` | `bigint` | —       | **Yes**  |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  // ... output of compute_data_confidence() — field-level provenance & confidence
}
```

| Property                           | Details                              |
| ---------------------------------- | ------------------------------------ |
| Has `p_country`                    | **No**                               |
| Uses `resolve_effective_country()` | **No**                               |
| Auth required                      | **Yes**                              |
| Roles                              | `authenticated`, `service_role` only |
| Security                           | `SECURITY DEFINER`                   |

---

## 8. `api_get_user_preferences`

**Description:** Returns the authenticated user's preference profile. Auto-creates a default row (with `country=NULL`) on first call. Returns `onboarding_complete: false` until the user sets a country during onboarding.

**Source:** `20260213200400_auth_only_platform.sql`

| Parameter | Type | Default | Required |
| --------- | ---- | ------- | -------- |
| *(none)*  | —    | —       | —        |

**Returns:** `jsonb`

```jsonc
{
  "api_version": "1.0",
  "user_id": "uuid",
  "country": "PL",                        // null before onboarding
  "diet_preference": "vegetarian",
  "avoid_allergens": ["en:gluten", "en:milk"],
  "strict_allergen": false,
  "strict_diet": false,
  "treat_may_contain_as_unsafe": false,
  "onboarding_complete": true,            // false when country is null
  "created_at": "...",
  "updated_at": "..."
}
```

> **Onboarding flow:** On first call, a default row is auto-created with `country=NULL` and `onboarding_complete=false`. The frontend should redirect to the onboarding wizard until `onboarding_complete` is `true`.

| Property                           | Details                                           |
| ---------------------------------- | ------------------------------------------------- |
| Has `p_country`                    | **No**                                            |
| Uses `resolve_effective_country()` | **No**                                            |
| Auth required                      | **Yes** (`auth.uid()`)                            |
| Roles                              | `authenticated`, `service_role` only (NOT `anon`) |
| Security                           | `SECURITY DEFINER`                                |

---

## 9. `api_set_user_preferences`

**Description:** Creates or updates (upserts) the authenticated user's preference profile. Validates country against `country_ref` and diet preference enum. Returns the updated profile (via `api_get_user_preferences()` including `onboarding_complete`).

**Source:** `20260213200400_auth_only_platform.sql`

| Parameter                       | Type      | Default | Required |
| ------------------------------- | --------- | ------- | -------- |
| `p_country`                     | `text`    | `NULL`  | No       |
| `p_diet_preference`             | `text`    | `NULL`  | No       |
| `p_avoid_allergens`             | `text[]`  | `NULL`  | No       |
| `p_strict_allergen`             | `boolean` | `false` | No       |
| `p_strict_diet`                 | `boolean` | `false` | No       |
| `p_treat_may_contain_as_unsafe` | `boolean` | `false` | No       |

**Valid `p_diet_preference` values:** `none`, `vegetarian`, `vegan`

**Returns:** `jsonb` (the updated preference profile, same shape as `api_get_user_preferences`)

**Error responses:**
```jsonc
{ "api_version": "1.0", "error": "Authentication required." }
{ "api_version": "1.0", "error": "Country not available: XX" }
{ "api_version": "1.0", "error": "Invalid diet_preference. Use: none, vegetarian, vegan." }
```

| Property                           | Details                                                    |
| ---------------------------------- | ---------------------------------------------------------- |
| `p_country` default                | `NULL` (not hardcoded; pass country explicitly)            |
| Uses `resolve_effective_country()` | **No**                                                     |
| Auth required                      | **Yes** (`auth.uid()`)                                     |
| Validates country                  | Against `country_ref.is_active = true`                     |
| Country COALESCE                   | Passing `NULL` preserves existing country (won't clear it) |
| Roles                              | `authenticated`, `service_role` only (NOT `anon`)          |
| Security                           | `SECURITY DEFINER`                                         |

---

## Views

### `v_api_category_overview`

**Description:** Dashboard stats per category across all active countries. One row per category.

**Source:** `20260213200200_fix_global_overview_active_country.sql`

| Column                 | Type      | Description                             |
| ---------------------- | --------- | --------------------------------------- |
| `category`             | `text`    | Category slug                           |
| `display_name`         | `text`    | Human-readable name                     |
| `category_description` | `text`    | Category description                    |
| `icon_emoji`           | `text`    | Emoji icon                              |
| `sort_order`           | `integer` | Display order                           |
| `product_count`        | `integer` | Total non-deprecated products           |
| `avg_score`            | `numeric` | Average unhealthiness score (1 decimal) |
| `min_score`            | `integer` | Lowest score in category                |
| `max_score`            | `integer` | Highest score in category               |
| `median_score`         | `integer` | Median score                            |
| `pct_nutri_a_b`        | `numeric` | % of products with Nutri-Score A or B   |
| `pct_nova_4`           | `numeric` | % of products classified NOVA 4         |

**Filters:** Only active categories (`category_ref.is_active`) and active countries (`country_ref.is_active`).

**Access:** `service_role` only (revoked from `anon`, `authenticated` — RPC-only model).

---

### `v_api_category_overview_by_country`

**Description:** Country-dimensioned dashboard stats. Same columns as `v_api_category_overview` plus `country_code`. One row per (country, category) pair.

**Source:** `20260213001400_country_expansion_readiness.sql`

| Column                 | Type      | Description                                             |
| ---------------------- | --------- | ------------------------------------------------------- |
| `country_code`         | `text`    | Country code (e.g., `PL`, `DE`)                         |
| `category`             | `text`    | Category slug                                           |
| `display_name`         | `text`    | Human-readable name                                     |
| `category_description` | `text`    | Category description                                    |
| `icon_emoji`           | `text`    | Emoji icon                                              |
| `sort_order`           | `integer` | Display order                                           |
| `product_count`        | `integer` | Total non-deprecated products for this country+category |
| `avg_score`            | `numeric` | Average unhealthiness score (1 decimal)                 |
| `min_score`            | `integer` | Lowest score                                            |
| `max_score`            | `integer` | Highest score                                           |
| `median_score`         | `integer` | Median score                                            |
| `pct_nutri_a_b`        | `numeric` | % of products with Nutri-Score A or B                   |
| `pct_nova_4`           | `numeric` | % of products classified NOVA 4                         |

**Filters:** Only active categories and active countries.

**Access:** `service_role` only (revoked from `anon`, `authenticated` — RPC-only model).

---

## Summary Matrix

| Function                    | `p_country` param | Default | `resolve_effective_country()` | Auth required | Roles         |
| --------------------------- | ----------------- | ------- | ----------------------------- | ------------- | ------------- |
| `api_search_products`       | Yes               | `NULL`  | **Yes**                       | **Yes**       | auth, service |
| `api_category_listing`      | Yes               | `NULL`  | **Yes**                       | **Yes**       | auth, service |
| `api_product_detail`        | No                | —       | No                            | **Yes**       | auth, service |
| `api_product_detail_by_ean` | Yes               | `NULL`  | **Yes**                       | **Yes**       | auth, service |
| `api_better_alternatives`   | No                | —       | No (inferred from product)    | **Yes**       | auth, service |
| `api_score_explanation`     | No                | —       | No                            | **Yes**       | auth, service |
| `api_data_confidence`       | No                | —       | No                            | **Yes**       | auth, service |
| `api_get_user_preferences`  | No                | —       | No                            | **Yes**       | auth, service |
| `api_set_user_preferences`  | Yes               | `NULL`  | No                            | **Yes**       | auth, service |

---

## Frontend Implementation Checklist

### Public pages (no auth required)
- Home / landing page
- Contact / about

### Auth pages
- Signup (Supabase Auth)
- Login (Supabase Auth)

### Onboarding wizard (post-signup, pre-product-access)

**Step 1 — Region (required):**
- Call `api_get_user_preferences()` → check `onboarding_complete`
- If `false`, show country picker (populated from active countries)
- On selection: `api_set_user_preferences(p_country: 'XX')`

**Step 2 — Dietary preferences (optional, skippable):**
- Diet preference: `none` / `vegetarian` / `vegan`
- Allergen avoidance: multi-select allergen tags
- Strict mode toggles
- On save: `api_set_user_preferences(p_diet_preference: '...', p_avoid_allergens: [...], ...)`

### Protected pages (auth + onboarding complete)
- Search (`api_search_products`)
- Category browse (`api_category_listing`)
- Product detail (`api_product_detail`)
- Barcode scanner (`api_product_detail_by_ean`)
- Better alternatives (`api_better_alternatives`)
- Score explanation (`api_score_explanation`)
- Data confidence (`api_data_confidence`)

### Route guard logic
```
if (!session) → redirect to /login
if (session && !onboarding_complete) → redirect to /onboarding
if (session && onboarding_complete) → allow access
```
