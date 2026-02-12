# Table Audit Report — 2026-02-12

## Scope
Audited all public base tables in local Supabase/PostgreSQL:
- category_ref
- concern_tier_ref
- country_ref
- ingredient_ref
- nutri_score_ref
- nutrition_facts
- product_allergen_info
- product_ingredient
- products

## Structural Integrity (Schema/Constraints)
- Public tables audited: **9/9**
- Tables with primary key: **9/9**
- Constraints present and validated: **42/42** (`convalidated = true`)
- Foreign keys structurally valid (no invalid constraints): **pass**

## Cardinality Snapshot
- products: 1063 (1029 active, 34 deprecated)
- nutrition_facts: 1032
- ingredient_ref: 1132
- product_ingredient: 0
- product_allergen_info: 0
- category_ref: 20
- concern_tier_ref: 4
- country_ref: 1
- nutri_score_ref: 7

## QA Status Summary
From `RUN_QA.ps1 -Json`:
- Total checks: 226
- Passed: 221
- Failed: 5
- Warnings: 1029 (actionable source-coverage warnings)
- Overall: **fail**

Blocking failures currently observed:
1. Data Integrity (Suite 1)
   - 14 active products with missing `nutri_score_label`
   - 1132 orphan `ingredient_ref` rows (because `product_ingredient` currently empty)
2. Scoring Formula (Suite 2)
   - 1 regression check failing (`Lajkonik Paluszki` expected score band mismatch)
3. Data Quality & Plausibility (Suite 7)
   - 14 active products with `nova_classification` null
4. Data Consistency (Suite 12)
   - 1 case-insensitive duplicate product key
   - 3 deprecated products missing `deprecated_reason`

## Table-by-Table Assessment

### Reference Tables
- category_ref: structurally healthy, populated (20)
- concern_tier_ref: structurally healthy, populated (4)
- country_ref: structurally healthy, populated (1)
- nutri_score_ref: structurally healthy, populated (7)

### Core Data Tables
- products: structurally healthy, **data quality issues present** (duplicate key group, missing deprecated reason, missing score/NOVA fields)
- nutrition_facts: structurally healthy, no orphan rows

### Ingredient/Allergen Domain
- ingredient_ref: structurally healthy, **currently fully orphaned** relative to `product_ingredient` (1132/1132)
- product_ingredient: structurally healthy, empty
- product_allergen_info: structurally healthy, empty

## Audit Verdict
- **Schema integrity:** satisfied
- **Table-level data quality:** not yet satisfied (known blocking QA issues remain)

## Recommended Remediation Order
1. Backfill missing `nutri_score_label` and `nova_classification` for 14 active products.
2. Resolve the case-insensitive duplicate product group.
3. Populate missing `deprecated_reason` for 3 deprecated rows.
4. Investigate ingredient pipeline state (`product_ingredient` empty while `ingredient_ref` populated).
5. Re-run `RUN_QA.ps1 -Json` and require `overall = pass` before closing this audit.
