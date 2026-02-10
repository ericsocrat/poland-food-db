# Research Workflow

> **Last updated:** 2026-02-08
> **Purpose:** Defines exactly how product data is researched, collected, validated, and entered into the database.
> **Audience:** AI agent (Copilot) and human contributors.

---

## 1. Workflow Overview

Every product batch follows this exact sequence. No shortcuts.

```
Phase 1: IDENTIFY    → Select products to research
Phase 2: COLLECT     → Gather raw data from sources
Phase 3: VALIDATE    → Cross-check, resolve conflicts
Phase 4: NORMALIZE   → Convert to database format
Phase 5: IMPLEMENT   → Write SQL pipeline files
Phase 6: VERIFY      → Run locally, pass QA
Phase 7: DOCUMENT    → Commit with provenance trail
```

---

## 2. Phase 1 — Product Identification

### 2.1 Product Selection Criteria

Before researching a product, confirm ALL of the following:

- [ ] Currently sold in Poland (not discontinued, not seasonal-only unless flagged)
- [ ] Pre-packaged with EU-mandated nutrition declaration
- [ ] Falls within an active or planned category (`chips`, `zabka`, `cereals`, `drinks`)
- [ ] Has a distinguishable SKU (not a deli/bakery item weighed at checkout)

### 2.2 Batch Planning

When adding products, work in structured batches:

| Batch type    | Size       | When to use                               |
| ------------- | ---------- | ----------------------------------------- |
| Brand sweep   | 5–15 SKUs  | All Lay's variants, all Pringles variants |
| Store sweep   | 10–30 SKUs | All chips on Biedronka's shelf            |
| Category seed | 15–25 SKUs | Initial population of a new category      |
| Gap fill      | 1–5 SKUs   | Adding missing products found during QA   |

### 2.3 Priority Matrix

When choosing which products to add first:

| Factor                  | Weight | Why                                                        |
| ----------------------- | ------ | ---------------------------------------------------------- |
| Market share            | High   | Lay's Classic outsells niche brands 50:1                   |
| Data availability       | High   | Products with multiple source coverage = higher confidence |
| Nutritional range       | Medium | Want the full spectrum, not just the worst                 |
| Private-label coverage  | Medium | Biedronka/Lidl private labels are under-tracked            |
| Reformulation relevance | Low    | Recently reformulated = fresh label data needed            |

---

## 3. Phase 2 — Data Collection

### 3.0 Source Collection Order

For every product, attempt data collection from **multiple sources** following the priority hierarchy in `DATA_SOURCES.md`:

```
1. Physical label     → Gold standard (if available)
2. Manufacturer PL site → Check brand website for PL product page
3. IŻŻ / NCEZ tables    → Cross-validate against category reference values
4. Open Food Facts     → EAN lookup + verify PL label image
5. Polish retailer     → Biedronka.pl, Lidl.pl, Auchan.pl product pages
6. Category average    → Last resort only
```

**Minimum source requirement:** Every product should be traceable to **≥ 2 independent sources** before `confidence` can be set to `verified`. A single-source product (e.g., OFF only) should be flagged for future cross-validation.

#### Manufacturer Website Lookup Steps

| Step | Action                                                    |
| ---- | --------------------------------------------------------- |
| 1    | Identify the manufacturer from the label or product brand |
| 2    | Find their PL website (see `DATA_SOURCES.md` §4 for URLs) |
| 3    | Navigate to the specific product page                     |
| 4    | Confirm nutrition table is per 100g                       |
| 5    | Extract EU-7 + any voluntary fields                       |
| 6    | Compare against OFF data — note any discrepancies         |

#### Governmental Database Cross-Check

For every category batch, look up the **generic food type** in the IŻŻ / NCEZ food composition tables to establish expected ranges:

```
Example: Adding potato chips
→ IŻŻ lookup: "chipsy ziemniaczane, solone"
→ Expected ranges: fat 30–36g, salt 0.8–1.8g, calories 480–560 kcal
→ Any product outside these ranges needs a second source or manual verification
```

This catch-all range check helps detect OFF data entry errors, wrong-country variants, or outdated formulations.

### 3.1 Required Data Points Per Product

For every product, collect **all** of the following. Mark missing fields explicitly.

#### Identity Fields

| Field          | Source                         | Required | Example                  |
| -------------- | ------------------------------ | -------- | ------------------------ |
| `brand`        | Label front                    | Yes      | `Lay's`                  |
| `product_name` | Label front (Polish market)    | Yes      | `Lay's Klasyczne Solone` |
| `category`     | Our taxonomy                   | Yes      | `Chips`                  |
| `product_type` | Label description              | Optional | `Chipsy ziemniaczane`    |
| `ean`          | Barcode (when schema supports) | Planned  | `5900259000002`          |

#### EU Mandatory 7 (per 100g)

| Field             | Source          | Required | Store as          | Example |
| ----------------- | --------------- | -------- | ----------------- | ------- |
| Energy (kcal)     | Nutrition table | Yes      | `calories`        | `536`   |
| Total fat (g)     | Nutrition table | Yes      | `total_fat_g`     | `33.0`  |
| Saturated fat (g) | Nutrition table | Yes      | `saturated_fat_g` | `3.0`   |
| Carbohydrate (g)  | Nutrition table | Yes      | `carbs_g`         | `52.0`  |
| Sugars (g)        | Nutrition table | Yes      | `sugars_g`        | `0.5`   |
| Protein (g)       | Nutrition table | Yes      | `protein_g`       | `6.5`   |
| Salt (g)          | Nutrition table | Yes      | `salt_g`          | `1.3`   |

#### Voluntary Nutrition Fields

| Field         | Source          | Required | Store as      | Example |
| ------------- | --------------- | -------- | ------------- | ------- |
| Fibre (g)     | Nutrition table | If shown | `fibre_g`     | `4.0`   |
| Trans fat (g) | Nutrition table | If shown | `trans_fat_g` | `0.0`   |

#### Processing & Qualitative Fields

| Field           | How to determine                                     | Store as              |
| --------------- | ---------------------------------------------------- | --------------------- |
| Ingredient list | Label back (original Polish)                         | `ingredients_raw`     |
| Additive count  | Count E-numbers in ingredient list                   | `additives_count`     |
| Prep method     | Infer from label: "smażone"=fried, "pieczone"=baked  | `prep_method`         |
| Oil method      | Label: e.g., "w oleju słonecznikowym"                | `oil_method`          |
| Processing risk | Derive from NOVA group or ingredient inspection      | `processing_risk`     |
| NOVA group      | Open Food Facts or manual classification             | `nova_classification` |
| Controversies   | Known issues: palm oil, MSG, controversial additives | `controversies`       |
| Nutri-Score     | Label, OFF, or computed                              | `nutri_score_label`   |

### 3.2 Additive Counting Rules

**What counts as an additive:**
- E-numbers explicitly listed (e.g., E621, E330)
- Named additives that map to E-numbers (e.g., "kwas cytrynowy" = E330)
- Artificial flavours/colours listed generically (count as 1 each)

**What does NOT count:**
- Base ingredients (potatoes, oil, salt, sugar)
- Spices and herbs (unless they contain added extracts)
- Vitamins/minerals added for fortification

**Example:**
> Ziemniaki, olej słonecznikowy, sól, maltodekstryna, cukier, **ekstrakt drożdżowy**, **E621**, **aromat**, **E631**, **E627**, **kwas cytrynowy**

Additive count = **6** (maltodekstryna is borderline — count it if it serves a technological function, not if it's a carrier for flavour)

### 3.3 Open Food Facts API Research

When researching products, query Open Food Facts **programmatically** where possible:

**Single product lookup:**
```
GET https://world.openfoodfacts.org/api/v2/product/{EAN}.json
```

**Key fields to extract:**
| API field                       | Maps to our column    | Trust level              |
| ------------------------------- | --------------------- | ------------------------ |
| `product_name`                  | `product_name`        | Verify matches PL label  |
| `nutriments.energy-kcal_100g`   | `calories`            | Cross-check with label   |
| `nutriments.fat_100g`           | `total_fat_g`         | Cross-check with label   |
| `nutriments.saturated-fat_100g` | `saturated_fat_g`     | Cross-check with label   |
| `nutriments.carbohydrates_100g` | `carbs_g`             | Cross-check with label   |
| `nutriments.sugars_100g`        | `sugars_g`            | Cross-check with label   |
| `nutriments.proteins_100g`      | `protein_g`           | Cross-check with label   |
| `nutriments.salt_100g`          | `salt_g`              | Cross-check with label   |
| `nutriments.fiber_100g`         | `fibre_g`             | If available             |
| `nutriscore_grade`              | `nutri_score_label`   | Accepted if verified     |
| `nova_group`                    | `nova_classification` | Accepted if verified     |
| `ingredients_text_pl`           | `ingredients_raw`     | Only if PL text present  |
| `additives_n`                   | `additives_count`     | Cross-check manual count |
| `countries_tags`                | Verify `en:poland`    | MUST contain Poland      |

**Validation rule:** An Open Food Facts entry is **verified** only if:
1. `countries_tags` includes `en:poland`
2. At least one product image shows a Polish-language label
3. `completeness` ≥ 0.5 (OFF's own completeness metric)
4. Data was last modified within the past 3 years

**Polish product search:**
```
GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&search_simple=1&countries_tags=en:poland&json=1
```

### 3.4 Retailer Website Research

When using retailer websites:

| Step | Action                                                            |
| ---- | ----------------------------------------------------------------- |
| 1    | Navigate to the product page on the retailer's PL website         |
| 2    | Verify the product name matches what's on shelves                 |
| 3    | Extract nutrition table (per 100g — NOT per serving unless noted) |
| 4    | Check if ingredient list is provided                              |
| 5    | Note the URL and access date for `sources` table                  |
| 6    | Flag any discrepancy with label data in a SQL comment             |

**Warning:** Retailer websites sometimes show per-serving values without clearly labeling them. Always confirm the basis is per 100g.

---

## 4. Phase 3 — Data Validation

### 4.1 Cross-Source Verification

When data comes from a non-label source, cross-validate:

| Validation check                      | Action if fails                                         |
| ------------------------------------- | ------------------------------------------------------- |
| OFF values differ from label by > 10% | Use label value, note discrepancy in SQL comment        |
| OFF entry has no Polish label image   | Downgrade confidence to `estimated`                     |
| Retailer shows different values       | Use label if available; otherwise retailer with comment |
| Category average used                 | Set `confidence = 'estimated'`, add comment             |
| Multiple sources agree within 5%      | Confidence = `verified`                                 |

### 4.2 Range Sanity Checks

Before inserting any nutrition value, verify it falls within plausible ranges:

| Field              | Min | Max       | Typical for chips | Flag if outside |
| ------------------ | --- | --------- | ----------------- | --------------- |
| Energy (kcal/100g) | 0   | 900       | 480–560           | Yes             |
| Total fat (g/100g) | 0   | 100       | 25–35             | Yes             |
| Saturated fat      | 0   | total_fat | 2–6               | Yes             |
| Carbs (g/100g)     | 0   | 100       | 48–58             | Yes             |
| Sugars (g/100g)    | 0   | carbs     | 0–3               | Yes             |
| Protein (g/100g)   | 0   | 100       | 5–8               | Yes             |
| Salt (g/100g)      | 0   | 30        | 0.8–2.0           | Yes             |
| Fibre (g/100g)     | 0   | 50        | 3–6               | Yes             |
| Trans fat (g/100g) | 0   | total_fat | 0–0.5             | Yes             |

**Cross-field rules:**
- `saturated_fat_g` ≤ `total_fat_g` (always)
- `sugars_g` ≤ `carbs_g` (always)
- `trans_fat_g` ≤ `total_fat_g` (always)
- `fat + carbs + protein + fibre + salt` should be ≤ 100g (approximately; water/minerals make up the rest)
- Energy cross-check: `(fat × 9) + (carbs × 4) + (protein × 4) + (fibre × 2)` should approximate `calories` within ±15%

### 4.3 Trace Value Handling

EU labels sometimes use imprecise values. Handle as follows:

| Label text                 | Store as  | Treat as for scoring | SQL comment required |
| -------------------------- | --------- | -------------------- | -------------------- |
| `trace` / `śladowe ilości` | `'trace'` | 0                    | Yes                  |
| `<0.5` / `<0,5`            | `'<0.5'`  | 0.25 (midpoint)      | Yes                  |
| `<0.1`                     | `'<0.1'`  | 0.05 (midpoint)      | Yes                  |
| `<1`                       | `'<1'`    | 0.5 (midpoint)       | Yes                  |
| `0` (true zero)            | `'0'`     | 0                    | No                   |
| `N/A` / not applicable     | `'N/A'`   | NULL (excluded)      | Yes                  |
| Blank / missing            | NULL      | NULL (excluded)      | Yes                  |

**Scoring rule for trace values:** When a text column contains `<X`, the scoring pipeline uses the **midpoint** (`X/2`) for that sub-score. This avoids both the optimistic assumption (0) and the pessimistic assumption (X). The `data_completeness_pct` is NOT penalized for trace values since the label did provide information.

---

## 5. Phase 4 — Data Normalization

### 5.1 Unit Standardization

All nutrition values are stored **per 100g** (solid foods) or **per 100ml** (beverages).

| If source provides      | Action                                                |
| ----------------------- | ----------------------------------------------------- |
| Per 100g                | Store directly                                        |
| Per serving (e.g., 30g) | Convert: `value_per_100g = value × (100 / serving_g)` |
| Per pack (e.g., 150g)   | Convert: `value_per_100g = value × (100 / pack_g)`    |
| Per 100ml (beverages)   | Store directly (beverages use ml basis)               |

**Always** note the conversion in a SQL comment: `-- Converted from per-30g serving: 5.1 × (100/30) = 17.0`

### 5.2 Energy Conversion

Polish labels show energy in both kJ and kcal. We store **kcal** in `calories`.

If only kJ is available: `kcal = kJ / 4.184` (round to nearest integer)

### 5.3 Salt vs. Sodium

EU labels declare **salt** (NaCl), not sodium. Some older sources may show sodium.

Conversion: `salt_g = sodium_g × 2.5`

Always store as **salt**. If converting, add a SQL comment.

---

## 6. Phase 5 — Implementation

### 6.1 SQL Pipeline Construction

For each product batch, create or update these pipeline files:

| Step | File                                      | What it does                          |
| ---- | ----------------------------------------- | ------------------------------------- |
| 01   | `PIPELINE__<cat>__01_insert_products.sql` | Upsert product identity rows          |
| 02   | `PIPELINE__<cat>__02_ensure_deps.sql`     | Create empty scores/ingredients rows  |
| 03   | `PIPELINE__<cat>__03_add_servings.sql`    | Add 'per 100 g' serving row           |
| 04   | `PIPELINE__<cat>__04_add_nutrition.sql`   | Insert nutrition facts                |
| 05   | `PIPELINE__<cat>__05_scoring.sql`         | Compute all scores, flags, confidence |
| 06   | `PIPELINE__<cat>__06_add_sources.sql`     | Source provenance rows                |

### 6.2 SQL Comment Standards

Every product insert MUST include inline provenance documentation:

```sql
-- ─── Lay's Klasyczne Solone ──────────────────────────────────────────
-- Source: Physical label, Biedronka Kraków, 2026-02-05
-- EAN: 5900259000002 (verified)
-- OFF: https://world.openfoodfacts.org/product/5900259000002
-- Notes: Per 100g values from back-of-pack nutrition table
-- Cross-check: OFF values match label within 2% on all fields
INSERT INTO products (country, brand, product_type, category, product_name, prep_method, oil_method, controversies)
VALUES ('PL', 'Lay''s', 'Chipsy ziemniaczane', 'Chips', 'Lay''s Klasyczne Solone',
        'fried', 'sunflower_oil', 'none')
ON CONFLICT (country, brand, product_name) DO UPDATE SET
  product_type = EXCLUDED.product_type,
  prep_method = EXCLUDED.prep_method,
  oil_method = EXCLUDED.oil_method,
  controversies = EXCLUDED.controversies;
```

### 6.3 data_completeness_pct Computation

Computed in the scoring pipeline as the percentage of available core fields:

```sql
-- Weighted field availability (EU mandatory 7 + key supplementary)
-- Each field contributes to total based on importance for scoring
data_completeness_pct = round(100.0 * (
    (CASE WHEN nf.calories        IS NOT NULL AND nf.calories        NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10%
    (CASE WHEN nf.total_fat_g     IS NOT NULL AND nf.total_fat_g     NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10%
    (CASE WHEN nf.saturated_fat_g IS NOT NULL AND nf.saturated_fat_g NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15% (scoring weight: 0.18)
    (CASE WHEN nf.carbs_g         IS NOT NULL AND nf.carbs_g         NOT IN ('N/A','') THEN 1 ELSE 0 END) * 5  +  -- 5%
    (CASE WHEN nf.sugars_g        IS NOT NULL AND nf.sugars_g        NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15% (scoring weight: 0.18)
    (CASE WHEN nf.protein_g       IS NOT NULL AND nf.protein_g       NOT IN ('N/A','') THEN 1 ELSE 0 END) * 5  +  -- 5%
    (CASE WHEN nf.salt_g          IS NOT NULL AND nf.salt_g          NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15% (scoring weight: 0.18)
    (CASE WHEN nf.trans_fat_g     IS NOT NULL AND nf.trans_fat_g     NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10% (scoring weight: 0.12)
    (CASE WHEN nf.fibre_g         IS NOT NULL AND nf.fibre_g         NOT IN ('N/A','') THEN 1 ELSE 0 END) * 5  +  -- 5%
    (CASE WHEN i.additives_count  IS NOT NULL AND i.additives_count  NOT IN ('N/A','') THEN 1 ELSE 0 END) * 5  +  -- 5% (scoring weight: 0.07)
    (CASE WHEN i.ingredients_raw  IS NOT NULL AND i.ingredients_raw  != ''              THEN 1 ELSE 0 END) * 5     -- 5%
) / 100.0)
```

### 6.4 Confidence Level Determination

| Condition                                              | Confidence  |
| ------------------------------------------------------ | ----------- |
| All EU-7 from verified label + data_completeness ≥ 90% | `verified`  |
| All EU-7 from Open Food Facts (verified entry)         | `verified`  |
| Most fields present, 1–2 estimated from category avg   | `estimated` |
| Nutri-Score computed algorithmically (not from label)  | `computed`  |
| data_completeness < 70% or multiple fields estimated   | `low`       |

---

## 7. Phase 6 — Verification

### 7.1 Local Pipeline Run

```powershell
.\RUN_LOCAL.ps1 -Category <category> -RunQA
```

All files must execute without error.

### 7.2 Manual Spot Checks

After pipeline run, manually verify 2–3 products:

```sql
-- Spot check: verify a product end-to-end
SELECT * FROM v_master
WHERE product_name = 'Lay''s Klasyczne Solone'
  AND country = 'PL';
```

Verify:
- [ ] All 7 mandatory nutrition fields are populated
- [ ] `unhealthiness_score` is between 1 and 100
- [ ] Flags (`high_salt_flag`, etc.) are consistent with nutrition values
- [ ] `scoring_version` is current (e.g., `v3.2`)
- [ ] `scored_at` is today's date
- [ ] `confidence` is correctly assigned

### 7.3 Energy Cross-Check

For every product, validate that declared calories are physically plausible:

```
Computed energy = (fat × 9) + (carbs × 4) + (protein × 4) + (fibre × 2)
Tolerance = ±15% of declared energy
```

If the computed energy falls outside this tolerance, add a SQL comment flagging the discrepancy. This catches data entry errors and source mismatches.

---

## 8. Phase 7 — Documentation & Commit

### 8.1 Sources Table Entry

Every product batch gets a `sources` row:

```sql
INSERT INTO sources (source_id, brand, source_type, ref, url, notes, category)
VALUES (
    nextval('sources_source_id_seq'),
    'Lay''s',
    'label',
    'Biedronka Kraków, 2026-02-05',
    NULL,
    'PL market, per 100g table, 5 SKUs verified against OFF',
    'Chips'
)
ON CONFLICT (source_id) DO NOTHING;
```

### 8.2 Git Commit

```
feat(chips): add 5 Lay's SKUs from Biedronka labels

Sources: Physical labels (Biedronka Kraków, 2026-02-05)
Cross-validated: Open Food Facts (all 5 products verified)
Data completeness: 95-100% across all products
Scoring version: v3.2
```

---

## 9. Edge Cases & Decision Rules

### 9.1 Product Variants

| Scenario                           | Rule                                                            |
| ---------------------------------- | --------------------------------------------------------------- |
| Same product, different pack sizes | One row if nutrition per 100g is identical                      |
| Same product, different flavours   | Separate rows (different nutrition profiles)                    |
| "Light" / "Less salt" variant      | Separate row with distinct `product_name`                       |
| Multi-pack vs single               | One row (nutrition per 100g is the same)                        |
| Seasonal/limited edition           | Separate row; add `eu_notes = 'Seasonal - verify availability'` |

### 9.2 When Data Conflicts

| Conflict                                      | Resolution                                          |
| --------------------------------------------- | --------------------------------------------------- |
| Label says 1.2g salt, OFF says 1.3g           | Use label (Priority 1). Note: within rounding.      |
| Label says 530 kcal, OFF says 540 kcal        | Use label. OFF may have older formulation data.     |
| Retailer site shows different values than OFF | Use whichever is more recent, flag in comment.      |
| Two label photos show different values        | Use the more recent date. Product was reformulated. |
| Product has different name on OFF vs label    | Use label name for `product_name`. Note OFF name.   |

### 9.3 Products Without Label Access

When no physical label or verified image is available:

1. Use the best available source (manufacturer website → OFF → retailer)
2. Set `confidence = 'estimated'`
3. Add SQL comment: `-- PLACEHOLDER: No verified label available. Source: <source>`
4. Flag for re-verification when label access becomes available

---

## 10. Research Checklist Template

Use this checklist for every product batch:

```
## Batch: [Category] — [Brand/Description]
## Date: YYYY-MM-DD
## Researcher: [name/agent]

### Pre-Research
- [ ] Products confirmed currently sold in Poland
- [ ] Category pipeline folder exists
- [ ] Batch size decided (brand sweep / store sweep / gap fill)

### Data Collection
- [ ] Manufacturer PL website checked for product nutrition data
- [ ] IŻŻ / NCEZ category reference ranges recorded
- [ ] Open Food Facts queried for all products (EAN where available)
- [ ] Nutrition facts collected (per 100g basis) from best available source
- [ ] Cross-validated against ≥ 2 sources where possible
- [ ] Ingredient lists recorded in original Polish
- [ ] Additives counted using counting rules
- [ ] Prep method determined
- [ ] Source URLs and access dates recorded

### Validation
- [ ] Range sanity checks passed for all values
- [ ] Cross-field rules passed (sat_fat ≤ total_fat, sugars ≤ carbs)
- [ ] Energy cross-check within ±15% tolerance
- [ ] Cross-source verification completed where applicable

### Implementation
- [ ] Product INSERT with full provenance comments
- [ ] Nutrition INSERT with correct per-100g values
- [ ] Scoring UPDATE with current formula (v3.2)
- [ ] Source INSERT with date and reference
- [ ] data_completeness_pct computed
- [ ] confidence level assigned

### Verification
- [ ] RUN_LOCAL.ps1 -Category <cat> -RunQA passes
- [ ] Spot-check 2-3 products via v_master
- [ ] unhealthiness_score passes sanity check
- [ ] Flags consistent with nutrition values

### Commit
- [ ] Descriptive commit message with source references
- [ ] No hardcoded credentials
- [ ] Documentation updated if methodology changed
```
