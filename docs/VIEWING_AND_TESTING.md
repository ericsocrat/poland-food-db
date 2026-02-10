# Poland Food DB — Viewing & Testing Guide

## 🔍 How to View Your Data

### Option 1: Supabase Studio (Web UI) — **RECOMMENDED**

The **easiest way** to browse your tables visually:

1. **Open Studio**: http://127.0.0.1:54323
2. **Navigate**: Click **"Table Editor"** in left sidebar
3. **Explore tables**:
   - `products` — 560 active products across 20 categories (28 per category)
   - `nutrition_facts` — nutritional data per 100g and per serving
   - `scores` — unhealthiness scores (v3.2), flags, Nutri-Score, NOVA, confidence
   - `ingredients` — raw ingredient text, additives count, allergens, traces
   - `servings` — 877 serving definitions (560 per-100g + 317 per-serving)
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

### 1. **Data Integrity Tests** (35 checks + 6 informational)
Validates foreign keys, nulls, duplicates, orphaned rows, energy cross-check, ingredient data coverage:

```powershell
Get-Content "db\qa\QA__null_checks.sql" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres --tuples-only
```

**Expected output**: Empty (zero violation rows) = ✅ PASS

---

### 2. **Scoring Formula Tests** (29 checks)
Validates v3.2 algorithm correctness, flag logic, NOVA consistency, regression checks:

```powershell
Get-Content "db\qa\QA__scoring_formula_tests.sql" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres --tuples-only
```

**Expected output**: Empty (zero violation rows) = ✅ PASS

---

### 3. **Automated Pipeline Test** (All-in-One)
Run all pipelines + both QA suites automatically:

```powershell
.\RUN_LOCAL.ps1 -RunQA
```

**Expected output**:
```
================================================
  Execution Summary
================================================
  Succeeded:  80
  Failed:     0
  Duration:   ~5s

================================================
  Running QA Checks
================================================
  All QA checks passed (64/64 — zero violation rows).

  Database inventory:
  total_products | deprecated | servings | nutrition | scores | ingredients
----------------+------------+----------+-----------+--------+-------------
             560 |          0 |      877 |       877 |    560 |         560
```

---

### 4. **Standalone QA Runner** (Recommended)
Runs both test suites with color-coded output:

```powershell
.\RUN_QA.ps1
```

**Expected output**:
```
✓ PASS (35/35 — zero violations)
✓ PASS (29/29 — zero violations)
ALL TESTS PASSED (64/64 checks)
```

---

### 5. **Known Regression Tests** (Embedded in formula tests)

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

**Columns available** (63 columns):
- **Identity**: `product_id`, `country`, `brand`, `product_name`, `category`, `product_type`, `ean`
- **Qualitative**: `prep_method`, `store_availability`, `controversies`
- **Scores**: `unhealthiness_score`, `scoring_version`, `scored_at`, `confidence`, `data_completeness_pct`, `score_breakdown` (JSONB)
- **Labels**: `nutri_score_label`, `nova_classification`, `processing_risk`
- **Flags**: `high_salt_flag`, `high_sugar_flag`, `high_sat_fat_flag`, `high_additive_load`
- **Nutrition (per 100g)**: `calories`, `total_fat_g`, `saturated_fat_g`, `trans_fat_g`, `carbs_g`, `sugars_g`, `fibre_g`, `protein_g`, `salt_g`
- **Nutrition (per serving)**: `serving_amount_g`, `srv_calories`, `srv_total_fat_g`, `srv_saturated_fat_g`, `srv_trans_fat_g`, `srv_carbs_g`, `srv_sugars_g`, `srv_fibre_g`, `srv_protein_g`, `srv_salt_g`
- **Ingredients**: `additives_count`, `ingredients_raw`, `ingredient_count`, `additive_names`, `ingredient_concern_score`
- **Dietary**: `vegan_status`, `vegetarian_status`
- **Allergens**: `allergen_count`, `allergen_tags`, `trace_count`, `trace_tags`
- **Sources**: `source_type`, `source_url`, `source_ean`, `source_confidence`, `source_fields`, `source_collected_at`, `source_notes`
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
