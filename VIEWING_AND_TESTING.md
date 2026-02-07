# Poland Food DB — Viewing & Testing Guide

## 🔍 How to View Your Data

### Option 1: Supabase Studio (Web UI) — **RECOMMENDED**

The **easiest way** to browse your tables visually:

1. **Open Studio**: http://127.0.0.1:54323
2. **Navigate**: Click **"Table Editor"** in left sidebar
3. **Explore tables**:
   - `products` — 132 active products across chips, żabka, cereals, drinks, dairy, bread & meat
   - `nutrition_facts` — nutritional data per 100g
   - `scores` — unhealthiness scores, flags, Nutri-Score, NOVA
   - `ingredients` — additives count
   - `servings` — serving definitions
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

### 1. **Data Integrity Tests** (11 checks)
Validates foreign keys, nulls, duplicates, orphaned rows:

```powershell
Get-Content "db\qa\QA__null_checks.sql" | docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres --tuples-only
```

**Expected output**: Empty (zero violation rows) = ✅ PASS

---

### 2. **Scoring Formula Tests** (17 checks)
Validates v3.1 algorithm correctness, flag logic, NOVA consistency, regression checks:

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
  Succeeded:  21
  Failed:     0
  Duration:   2.2s

================================================
  Running QA Checks
================================================
  All QA checks passed (11/11 — zero violation rows).

  Database inventory:
  total_products | deprecated | servings | nutrition | scores | ingredients
----------------+------------+----------+-----------+--------+-------------
              80 |         17 |       80 |        80 |     80 |          80
```

---

### 4. **Standalone QA Runner** (Recommended)
Runs both test suites with color-coded output:

```powershell
.\RUN_QA.ps1
```

**Expected output**:
```
✓ PASS (11/11 — zero violations)
✓ PASS (17/17 — zero violations)
ALL TESTS PASSED (28/28 checks)
```

---

### 5. **Known Regression Tests** (Embedded in formula tests)

- **Top Chips Faliste** (palm oil, 16g sat fat) → Score: **51±2**
- **Naleśniki z jabłkami** (healthiest żabka) → Score: **17±2**
- **Melvit Płatki Owsiane Górskie** (whole oats, NOVA 1) → Score: **11±2**
- **Coca-Cola Zero** (zero sugar, high additives) → Score: **8±2**

If these products' scores drift outside expected ranges, the tests will flag it.

---

## 📊 Pre-Built Reports

### Master View Query
Get everything in one denormalized view:

```sql
SELECT * FROM v_master
ORDER BY unhealthiness_score::int DESC;
```

**Columns available**:
- `product_id`, `country`, `brand`, `product_name`, `category`
- `prep_method`, `store_availability`, `controversies`
- `unhealthiness_score`, `nutri_score_label`, `nova_classification`
- `processing_risk`, `high_salt_flag`, `high_sugar_flag`, `high_sat_fat_flag`
- `high_additive_load`, `data_completeness_pct`
- `additives_count`, `calories`, `total_fat_g`, `saturated_fat_g`, `trans_fat_g`
- `carbs_g`, `sugars_g`, `fibre_g`, `protein_g`, `salt_g`

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
