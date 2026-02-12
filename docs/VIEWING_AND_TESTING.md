# Poland Food DB — Viewing & Testing Guide

## 🔍 How to View Your Data

### Option 1: Supabase Studio (Web UI) — **RECOMMENDED**

The **easiest way** to browse your tables visually:

1. **Open Studio**: http://127.0.0.1:54323
2. **Navigate**: Click **"Table Editor"** in left sidebar
3. **Explore tables**:
   - `products` — 1,029 active products across 20 categories (variable size per category)
   - `nutrition_facts` — nutritional data per 100g
   - `product_allergen_info` — allergen/trace declarations (unified table)
4. **Run custom queries**: Click **"SQL Editor"** → paste any SQL → click **Run**

**Pro tip**: Click on `v_master` view for a denormalized "master report" with all data joined.

---

### Option 2: Command-Line Queries

For quick terminal queries, use:

```powershell
# View top 10 unhealthiest products
echo "SELECT product_name, brand, unhealthiness_score, nutri_score_label FROM v_master ORDER BY unhealthiness_score::int DESC LIMIT 10;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres

# View all chips
echo "SELECT * FROM v_master WHERE category='Chips' ORDER BY unhealthiness_score::int DESC;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -x

# View all żabka products
echo "SELECT * FROM v_master WHERE category='Żabka' ORDER BY unhealthiness_score::int DESC;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -x

# View all cereals
echo "SELECT * FROM v_master WHERE category='Cereals' ORDER BY unhealthiness_score::int DESC;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -x

# View all drinks
echo "SELECT * FROM v_master WHERE category='Drinks' ORDER BY unhealthiness_score::int DESC;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -x

# View all dairy
echo "SELECT * FROM v_master WHERE category='Dairy' ORDER BY unhealthiness_score::int DESC;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -x

# Count by category
echo "SELECT category, COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE GROUP BY category;" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres
```

---

## ✅ How to Know Everything Is Working

### 1. **Data Integrity Tests** (29 checks)
Validates foreign keys, nulls, duplicates, orphaned rows, nutrition sanity, provenance:

```powershell
Get-Content "db\qa\QA__null_checks.sql" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres --tuples-only
```

**Expected output**: Empty (zero violation rows) = ✅ PASS

---

### 2. **Scoring Formula Tests** (27 checks)
Validates v3.2 algorithm correctness, flag logic, NOVA consistency, regression checks:

```powershell
Get-Content "db\qa\QA__scoring_formula_tests.sql" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres --tuples-only
```

**Expected output**: Empty (zero violation rows) = ✅ PASS

---

### 3. **Automated Pipeline Test** (All-in-One)
Run all pipelines + QA suites automatically:

```powershell
.\RUN_LOCAL.ps1 -RunQA
```

**Expected output**:
```
================================================
  Execution Summary
================================================
  Succeeded:  70
  Failed:     0
  Duration:   ~10s

================================================
  Running QA Checks
================================================
  All QA checks passed (226/226 — zero violation rows).

  Database inventory:
  active_products | deprecated | nutrition | categories
-----------------+------------+-----------+------------
            1029 |         34 |      1032 |         20
```

---

### 4. **Standalone QA Runner** (Recommended)
Runs all 15 test suites with color-coded output:

```powershell
.\RUN_QA.ps1
```

**Expected output**:
```
Suite  1 — Data Integrity:          ✓ PASS (29/29)
Suite  2 — Scoring Formula:         ✓ PASS (27/27)
Suite  3 — Source Coverage:         ℹ INFO (8 reports)
Suite  4 — EAN Validation:          ✓ PASS (1/1)
Suite  5 — API Surfaces:            ✓ PASS (14/14)
Suite  6 — Confidence Scoring:      ✓ PASS (10/10)
Suite  7 — Data Quality:            ✓ PASS (25/25)
Suite  8 — Referential Integrity:   ✓ PASS (18/18)
Suite  9 — View Consistency:        ✓ PASS (12/12)
Suite 10 — Naming Conventions:      ✓ PASS (12/12)
Suite 11 — Nutrition Ranges:        ✓ PASS (16/16)
Suite 12 — Data Consistency:        ✓ PASS (18/18)
Suite 13 — Allergen Integrity:      ✓ PASS (14/14)
Suite 14 — Serving & Source:        ✓ PASS (16/16)
Suite 15 — Ingredient Quality:      ✓ PASS (14/14)

ALL TESTS PASSED (226/226 checks across 15 suites)
```

---

### 5. **Negative Validation Tests** (29 constraint tests)
Verifies the database correctly rejects invalid data:

```powershell
.\RUN_NEGATIVE_TESTS.ps1
```

**Expected output**: `29/29 CAUGHT, 0 MISSED`

---

### 6. **Known Regression Tests** (Embedded in scoring formula suite)

- **Top Chips Faliste** (palm oil, 16g sat fat) → Score: **51±2**
- **Naleśniki z jabłkami** (healthiest żabka) → Score: **17±2**
- **Melvit Płatki Owsiane Górskie** (whole oats, NOVA 1) → Score: **11±2**
- **Coca-Cola Zero** (zero sugar, high additives) → Score: **8±2**
- **Piątnica Skyr Naturalny** (healthiest dairy) → Score: **9±2**
- **Mestemacher Pumpernikiel** (traditional rye) → Score: **17±2**
- **Tarczyński Kabanosy Klasyczne** (high-fat cured meat) → Score: **55±2**
- **Knorr Nudle Pomidorowe Pikantne** (instant noodle, palm oil) → Score: **21±2**

If these products' scores drift outside expected ranges, the tests will flag it.

---

## 📊 Pre-Built Reports

### Master View Query
Get everything in one denormalized view:

```sql
SELECT * FROM v_master
ORDER BY unhealthiness_score::int DESC;
```

**Columns available** (47 columns):
- **Identity**: `product_id`, `country`, `brand`, `product_name`, `category`, `product_type`, `ean`
- **Qualitative**: `prep_method`, `store_availability`, `controversies`
- **Scores**: `unhealthiness_score`, `confidence`, `data_completeness_pct`, `score_breakdown` (JSONB)
- **Labels**: `nutri_score_label`, `nova_classification`, `processing_risk` (derived from NOVA)
- **Flags**: `high_salt_flag`, `high_sugar_flag`, `high_sat_fat_flag`, `high_additive_load`
- **Nutrition (per 100g)**: `calories`, `total_fat_g`, `saturated_fat_g`, `trans_fat_g`, `carbs_g`, `sugars_g`, `fibre_g`, `protein_g`, `salt_g`
- **Ingredients**: `additives_count`, `ingredients_raw`, `ingredient_count`, `additive_names`, `ingredient_concern_score`, `has_palm_oil`
- **Dietary**: `vegan_status`, `vegetarian_status`
- **Allergens**: `allergen_count`, `allergen_tags`, `trace_count`, `trace_tags`
- **Source**: `source_type`, `source_url`, `source_ean`
- **Data quality**: `ingredient_data_quality`, `nutrition_data_quality`

---

## 🚀 Quick Start Workflow

1. **Start Supabase** (if not already running):
   ```powershell
   supabase start
   ```

2. **Open Studio UI**: http://127.0.0.1:54323

3. **Run pipelines** (if data changed):
   ```powershell
   .\RUN_LOCAL.ps1 -RunQA
   ```

4. **Explore data visually** in Studio → Table Editor

5. **Run custom analysis** in Studio → SQL Editor

---

## 🔍 Cross-Product Analytics

### Ingredient Frequency
```sql
-- Most common ingredients across all products
SELECT name_en, product_count, usage_pct, concern_tier
FROM mv_ingredient_frequency ORDER BY product_count DESC LIMIT 20;

-- High-concern ingredients and where they appear
SELECT name_en, product_count, concern_tier, categories
FROM mv_ingredient_frequency WHERE concern_tier >= 2
ORDER BY product_count DESC;
```

### Product Similarity
```sql
-- Find 5 products most similar to product #42 by ingredient overlap
SELECT * FROM find_similar_products(42);

-- Find 10 similar products
SELECT * FROM find_similar_products(42, 10);
```

### Better Alternatives
```sql
-- Find healthier alternatives in the same category
SELECT * FROM find_better_alternatives(42);

-- Find healthier alternatives across ALL categories
SELECT * FROM find_better_alternatives(42, false);

-- Find top 10 healthier alternatives
SELECT * FROM find_better_alternatives(42, true, 10);
```

### Score Breakdown
```sql
-- See how a product's score was computed
SELECT product_name, unhealthiness_score,
       score_breakdown->'factors' AS factors
FROM v_master WHERE product_id = 42;
```

---

## 🔗 Useful URLs (Local Dev)

| Service                           | URL                                                       |
| --------------------------------- | --------------------------------------------------------- |
| **Supabase Studio** (Database UI) | http://127.0.0.1:54323                                    |
| **REST API**                      | http://127.0.0.1:54321/rest/v1                            |
| **GraphQL API**                   | http://127.0.0.1:54321/graphql/v1                         |
| **Direct Postgres**               | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |

---

## 📝 Notes

- **All data is local** — nothing is uploaded to remote Supabase unless you explicitly push it
- **Pipelines are idempotent** — safe to run repeatedly
- **QA tests run in seconds** — should be zero violations
- **Test after every schema change** — ensures scoring formula integrity
