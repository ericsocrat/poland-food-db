# Scoring Methodology

> **Version:** 3.2
> **Last updated:** 2026-02-10
> **Scope:** Poland food quality database

---

## 1. Overview

This project computes **three independent health dimensions** for every product:

| Dimension               | Range / Values               | What it measures                                       |
| ----------------------- | ---------------------------- | ------------------------------------------------------ |
| **Unhealthiness Score** | 1–100 (integer)              | Composite harmfulness estimate across all risk factors |
| **Nutri-Score Label**   | A–E, UNKNOWN, NOT-APPLICABLE | EU front-of-pack nutrient profiling (where available)  |
| **Processing Risk**     | Low, Moderate, High          | Degree of ultra-processing (NOVA-informed)             |

These three dimensions are **not interchangeable**. A product can have a decent Nutri-Score but a high Processing Risk (e.g., low-calorie diet soda: Nutri-Score B, Processing Risk High).

---

## 2. Unhealthiness Score (1–100)

### 2.1 Philosophy

The Unhealthiness Score is the project's **primary composite metric**. It answers:

> *"If a person ate this product regularly as part of their diet, how much cumulative harm potential does it carry?"*

It is explicitly called **Unhealthiness** (not "healthiness") to avoid false-positive framing. A score of 30 does not mean a product is "healthy" — it means it is **less unhealthy** than a product scoring 70.

### 2.2 Input Factors, Weights, and Scientific Justification

The score is a **weighted sum of sub-scores**, each normalized to 0–100, then combined with the weights below.

**Why these thresholds?** Each ceiling is set at the point where a product consumed regularly at that level would approach or exceed daily recommended limits. The per-100g ceiling represents the concentration at which ~2–3 servings would meet or exceed the WHO/EFSA daily guideline.

| Factor             | Column source              | Weight   | Ceiling (per 100g) | Scientific basis for ceiling                                                                              |
| ------------------ | -------------------------- | -------- | ------------------ | --------------------------------------------------------------------------------------------------------- |
| Saturated fat      | `saturated_fat_g`          | 0.17     | 10g = 100          | EFSA DRV: <10% energy (~20g/day). 10g/100g = half daily limit in one portion.                             |
| Sugars             | `sugars_g`                 | 0.17     | 27g = 100          | WHO: <10% energy (~50g/day). 27g/100g = half daily limit. Aligned with Nutri-Score max penalty.           |
| Salt               | `salt_g`                   | 0.17     | 3.0g = 100         | WHO 2023: <5g/day. 3g/100g = >50% daily limit in 100g. EU Annex XIII "high" = 1.5g/100g.                  |
| Calories (energy)  | `calories`                 | 0.10     | 600 kcal = 100     | Approx. energy density of pure fat (900) × 0.66. Products above 600 kcal/100g are extremely energy-dense. |
| Trans fat          | `trans_fat_g`              | 0.11     | 2g = 100           | EU Reg. 2019/649: max 2g trans fat per 100g of fat. WHO: eliminate industrial trans fats.                 |
| Additives count    | `additives_count`          | 0.07     | 10 = 100           | NOVA research (Monteiro 2019): ultra-processed products average 8–12 additives. 10 = firmly NOVA 4.       |
| Oil / prep method  | `prep_method`              | 0.08     | categorical        | Acrylamide/PAH/HCA formation: deep-fried > fried > smoked > grilled > baked > steamed > air-popped.       |
| Controversies      | `controversies`            | 0.08     | categorical        | E.g., palm oil (EFSA 2016: process contaminants), E171 (EFSA 2021: no longer safe).                       |
| Ingredient concern | `ingredient_concern_score` | 0.05     | 100 = 100          | EFSA additive risk tiers. Nitrites (tier 3) = high; artificial sweeteners (tier 2) = moderate.            |
|                    |                            | **1.00** |                    |                                                                                                           |

**Weight rationale (v3.2):** Saturated fat, sugars, and salt share the highest weight (0.17 each, reduced from 0.18 in v3.1) because they are the three nutrients cited by WHO as primary dietary risks for NCDs. Trans fat has high weight (0.11) because trans fats have no safe level of intake (WHO). The new ingredient concern factor (0.05) captures additive safety signals from EFSA re-evaluations — separate from additive count (which measures processing degree) and controversies (which covers product-level issues like palm oil). Calories carry moderate weight because energy density alone does not indicate harm.

### 2.3 Formula

```
Unhealthiness Score = round(
    sat_fat_sub     * 0.17 +
    sugar_sub       * 0.17 +
    salt_sub        * 0.17 +
    calorie_sub     * 0.10 +
    trans_fat_sub   * 0.11 +
    additive_sub    * 0.07 +
    oil_sub         * 0.08 +
    controversy_sub * 0.08 +
    concern_sub     * 0.05
)
```

Where each sub-score is computed as:

```
sub_score = LEAST(100, (value / threshold) * 100)
```

For categorical factors (oil method, controversies, ingredient concern), use the fixed lookup values from the tables above.

**Clamping:** The final score is clamped to the range `[1, 100]`. A product with all zeroes scores 1 (not 0) to avoid implying "perfectly healthy."

**NULL handling:** If a numeric nutrition field is `NULL` or non-numeric text (e.g., `'N/A'`), that sub-score defaults to **0** and `data_completeness_pct` is reduced. The score is still computed but `confidence` is downgraded. See `RESEARCH_WORKFLOW.md` §4.3 for trace value handling (`'<0.5'` → midpoint `0.25`).

**Trace value parsing:** For text values like `'<0.5'`, the scoring pipeline extracts the numeric bound and uses the midpoint:

```sql
-- Extract numeric from trace values
CASE
  WHEN val ~ '^[0-9.]+$'  THEN val::numeric                    -- plain number
  WHEN val ~ '^<[0-9.]+$' THEN (ltrim(val, '<')::numeric / 2)  -- midpoint of range
  WHEN val = 'trace'       THEN 0                               -- negligible
  ELSE 0                                                         -- N/A, NULL, unparseable
END
```

### 2.4 PostgreSQL Function

The scoring formula is implemented as a reusable PostgreSQL function, defined in migration `20260207000501_scoring_function.sql` (v3.1 in `20260210001000`, v3.2 in `20260210001900`). All 20 category pipelines call this single function — changing weights or ceilings requires editing only one place.

**prep_method sub-score mapping:**

| Value              | Sub-score | Scientific basis                                              |
| ------------------ | --------- | ------------------------------------------------------------- |
| `'air-popped'`     | 20        | No oil, minimal thermal processing                            |
| `'steamed'`        | 30        | No oil, no browning — no acrylamide/HCA/PAH formation         |
| `'baked'`          | 40        | Moderate heat — some acrylamide formation at >120°C           |
| `'not-applicable'` | 50        | Default for products where method is irrelevant (canned, raw) |
| `'none'`           | 50        | Unclassified — conservative default                           |
| `'grilled'`        | 60        | High-temp browning — HCA formation (IARC Group 2A)            |
| `'smoked'`         | 65        | PAH exposure from wood smoke (EFSA 2008), nitrate concerns    |
| `'fried'`          | 80        | Oil absorption + acrylamide (EU Reg. 2017/2158)               |
| `'deep-fried'`     | 100       | Maximum oil absorption + acrylamide + HCA                     |

Additional valid values (`'marinated'`, `'pasteurized'`, `'fermented'`, `'dried'`, `'raw'`, `'roasted'`) all map to 50 (default). These can be differentiated in future scoring versions.

**ingredient_concern_score sub-score (v3.2):**

Each ingredient in `ingredient_ref` has a `concern_tier` (0–3) assigned from EFSA additive re-evaluations:

| Tier | Label    | Examples                              | Score contribution |
| ---- | -------- | ------------------------------------- | ------------------ |
| 0    | None     | Water, sugar, salt, flour             | 0                  |
| 1    | Low      | Lecithins (E322), citric acid (E330)  | 15                 |
| 2    | Moderate | Artificial sweeteners, some colorants | 40                 |
| 3    | High     | Nitrites (E250), BHA (E320), azo dyes | 100                |

The per-product `ingredient_concern_score` (0–100) is computed as: `LEAST(100, SUM(concern_tier_score_per_ingredient))`. Products with no classified additives score 0. The score is stored on the `scores` table and passed to `compute_unhealthiness_v32()` as the 9th parameter.

```sql
-- Function signature (returns INTEGER [1, 100])
compute_unhealthiness_v32(
    p_saturated_fat_g NUMERIC,    -- ceiling: 10g
    p_sugars_g        NUMERIC,    -- ceiling: 27g
    p_salt_g          NUMERIC,    -- ceiling: 3g
    p_calories        NUMERIC,    -- ceiling: 600 kcal
    p_trans_fat_g     NUMERIC,    -- ceiling: 2g
    p_additives_count NUMERIC,    -- ceiling: 10
    p_prep_method     TEXT,       -- categorical
    p_controversies   TEXT,       -- categorical
    p_concern_score   NUMERIC     -- 0-100 EFSA concern score
)
```

**Pipeline usage** (each category's `04_scoring.sql`):

```sql
UPDATE scores sc SET
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g::numeric,
      nf.sugars_g::numeric,
      nf.salt_g::numeric,
      nf.calories::numeric,
      nf.trans_fat_g::numeric,
      i.additives_count::numeric,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  )::text,
  scored_at = CURRENT_DATE,
  scoring_version = 'v3.2'
FROM products p
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.product_id = sc.product_id
  AND p.country = 'PL' AND p.category = '<CATEGORY>';
```

### 2.5 `scored_at` Timestamp

The `scored_at` column (type `date`) records **when the score was computed**, not when the label was read. It should be set to `CURRENT_DATE` in every scoring pipeline run. This allows tracking score freshness and identifying products that need re-scoring after methodology changes.

### 2.6 Score Bands

| Range  | Interpretation                              | Typical products                   |
| ------ | ------------------------------------------- | ---------------------------------- |
| 1–20   | Low concern                                 | Plain oats, raw vegetables         |
| 21–40  | Moderate — acceptable for regular use       | Whole-grain bread, basic yogurt    |
| 41–60  | Elevated — occasional consumption advised   | Baked chips, sweetened cereal      |
| 61–80  | High — frequent use is a health risk        | Fried chips, sugary drinks         |
| 81–100 | Very high — minimal consumption recommended | Deep-fried + high-salt + additives |

### 2.7 Scoring Version

All score records include a `scoring_version` field (currently `v3.2`). When methodology changes:

1. Increment the version (e.g., `v2.3`, `v3.0`).
2. Re-run all scoring pipelines.
3. Document the change in this file.
4. Do **not** delete historical scores — overwrite in place with the new version tag.

---

## 3. Nutri-Score (A–E)

### 3.1 What Nutri-Score Is

Nutri-Score is an **EU front-of-pack nutrient profiling system** developed by Santé Publique France and adopted (voluntarily or mandatorily) in several EU countries. It grades products A (best) to E (worst) based on:

**Negative points** (0–10 each):
- Energy (kJ)
- Sugars (g)
- Saturated fat (g)
- Salt (g)

**Positive points** (0–5 each):
- Fruits, vegetables, legumes, nuts (%)
- Fibre (g)
- Protein (g)

Final score = Negative − Positive → mapped to a letter grade.

### 3.2 Nutri-Score 2024 Point Thresholds (Solid Foods)

For **derived** Nutri-Score (when no label or Open Food Facts value exists), use these thresholds:

**Negative points (N)** — each component scores 0–10:

| Points | Energy (kJ) | Sugars (g) | Sat. fat (g) | Salt (g) |
| ------ | ----------- | ---------- | ------------ | -------- |
| 0      | ≤ 335       | ≤ 3.4      | ≤ 1.0        | ≤ 0.2    |
| 1      | > 335       | > 3.4      | > 1.0        | > 0.2    |
| 2      | > 670       | > 6.8      | > 2.0        | > 0.4    |
| 3      | > 1005      | > 10.2     | > 3.0        | > 0.6    |
| 4      | > 1340      | > 13.6     | > 4.0        | > 0.8    |
| 5      | > 1675      | > 16.9     | > 5.0        | > 1.0    |
| 6      | > 2010      | > 20.3     | > 6.0        | > 1.2    |
| 7      | > 2345      | > 23.7     | > 7.0        | > 1.4    |
| 8      | > 2680      | > 27.1     | > 8.0        | > 1.6    |
| 9      | > 3015      | > 30.5     | > 9.0        | > 1.8    |
| 10     | > 3350      | > 33.9     | > 10.0       | > 2.0    |

**Positive points (P)** — each component scores 0–5:

| Points | Fruit/veg/legumes (%) | Fibre (g) | Protein (g) |
| ------ | --------------------- | --------- | ----------- |
| 0      | ≤ 40                  | ≤ 3.0     | ≤ 2.4       |
| 1      | > 40                  | > 3.0     | > 2.4       |
| 2      | > 60                  | > 4.1     | > 4.8       |
| 3      | —                     | > 5.2     | > 7.2       |
| 4      | —                     | > 6.3     | > 9.6       |
| 5      | > 80                  | > 7.4     | > 12.0      |

**Letter grade mapping** (N − P):

| Score range | Grade |
| ----------- | ----- |
| −15 to −2   | **A** |
| −1 to 2     | **B** |
| 3 to 10     | **C** |
| 11 to 18    | **D** |
| 19 to 40    | **E** |

> **Source:** Santé Publique France, Nutri-Score algorithm update 2024.
> **Important:** Beverages and fats/oils use different threshold tables — add those when drinks/oils pipelines are created.
> When deriving Nutri-Score from nutrition facts, add a SQL comment noting the derivation.

### 3.3 Why Nutri-Score ≠ Health

Nutri-Score has **known limitations** that this project explicitly acknowledges:

| Limitation                        | Example                                                   |
| --------------------------------- | --------------------------------------------------------- |
| Ignores ultra-processing          | Diet soda scores B despite being NOVA 4 ultra-processed   |
| Per-100g basis hides serving size | Olive oil scores D despite evidence of health benefits    |
| No additive assessment            | Products with controversial additives can still score A/B |
| Category-blind in practice        | Comparing chips (D) to cereal (B) is not an equivalence   |
| Voluntary in most countries       | Not all Polish products carry Nutri-Score on labels       |

**Our position:** Nutri-Score is a **useful but incomplete signal**. We record it when available but never use it as the sole determinant of product quality. The Unhealthiness Score exists precisely to fill Nutri-Score's gaps.

### 3.4 Data Source for Nutri-Score

In order of preference:
1. **Official label** — if printed on the Polish packaging
2. **Open Food Facts** — if the product entry exists and has been verified
3. **Derived** — from nutrition facts using the 2024 Nutri-Score algorithm
4. **UNKNOWN** — if insufficient data to derive
5. **NOT-APPLICABLE** — for categories where Nutri-Score is not meaningful (e.g., alcohol)

---

## 4. Processing Risk (Low / Moderate / High)

### 4.1 NOVA Classification (Reference Framework)

We use the NOVA food classification system as a conceptual guide:

| NOVA Group | Description                       | Examples                            |
| ---------- | --------------------------------- | ----------------------------------- |
| 1          | Unprocessed / minimally processed | Fresh fruit, plain rice             |
| 2          | Processed culinary ingredients    | Olive oil, butter, salt             |
| 3          | Processed foods                   | Canned vegetables, artisan cheese   |
| 4          | Ultra-processed food products     | Chips, instant noodles, soft drinks |

### 4.2 Mapping to Processing Risk

| Processing Risk | Typical NOVA | Criteria                                                    |
| --------------- | ------------ | ----------------------------------------------------------- |
| **Low**         | 1–2          | ≤5 recognizable ingredients, no industrial additives        |
| **Moderate**    | 3            | Some processing, limited additives, recognizable base       |
| **High**        | 4            | Industrial formulations, emulsifiers, flavour systems, etc. |

### 4.3 NOVA Classification Column

The `scores.nova_classification` column stores the **NOVA group number** as text (`'1'`, `'2'`, `'3'`, or `'4'`). This is the raw NOVA group, distinct from `processing_risk` which is our simplified three-level mapping.

| `nova_classification` | `processing_risk`                   |
| --------------------- | ----------------------------------- |
| `'1'`                 | `'Low'`                             |
| `'2'`                 | `'Low'`                             |
| `'3'`                 | `'Moderate'`                        |
| `'4'`                 | `'High'`                            |
| `NULL`                | Derive from ingredients if possible |

Set `nova_classification` when: (a) Open Food Facts provides it, or (b) it can be determined from the ingredient list. If neither is possible, leave `NULL` and set `processing_risk` based on ingredient inspection.

### 4.4 Why This Matters

Ultra-processed foods (NOVA 4) are independently associated with:
- Higher all-cause mortality (Schnabel et al., 2019)
- Increased cancer risk (Fiolet et al., 2018)
- Metabolic syndrome (Louzada et al., 2015)

These risks exist **even when the Nutri-Score looks acceptable**, which is why Processing Risk is a separate dimension.

---

## 5. Flag Columns

The `scores` table includes binary flags for critical thresholds:

| Flag                 | Trigger condition            | Basis                                                |
| -------------------- | ---------------------------- | ---------------------------------------------------- |
| `high_salt_flag`     | Salt > 1.5 g per 100g        | EU "high salt" threshold (Reg. 1169/2011 Annex XIII) |
| `high_sugar_flag`    | Sugars > 12.5 g per 100g     | UK/EU "high sugar" threshold                         |
| `high_sat_fat_flag`  | Saturated fat > 5 g per 100g | EU "high saturated fat" threshold                    |
| `high_additive_load` | Additive count ≥ 5           | Project-defined threshold based on NOVA research     |

These flags are **informational overlays** — they do not replace the Unhealthiness Score but provide quick visual warnings.

### 5.1 Reference SQL for Flag Computation

Flags should be computed in the scoring pipeline, after nutrition facts are populated:

```sql
-- Compute flags from nutrition_facts (run after nutrition insert)
UPDATE scores sc SET
  high_salt_flag = CASE
    WHEN nf.salt_g ~ '^[0-9.]+$' AND nf.salt_g::numeric > 1.5 THEN 'Y' ELSE 'N'
  END,
  high_sugar_flag = CASE
    WHEN nf.sugars_g ~ '^[0-9.]+$' AND nf.sugars_g::numeric > 12.5 THEN 'Y' ELSE 'N'
  END,
  high_sat_fat_flag = CASE
    WHEN nf.saturated_fat_g ~ '^[0-9.]+$' AND nf.saturated_fat_g::numeric > 5.0 THEN 'Y' ELSE 'N'
  END,
  high_additive_load = CASE
    WHEN i.additives_count ~ '^[0-9]+$' AND i.additives_count::numeric >= 5 THEN 'Y' ELSE 'N'
  END
FROM products p
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.product_id = sc.product_id
  AND p.country = 'PL' AND p.category = '<CATEGORY>';
```

> **Note on text columns:** Because nutrition columns are `text`, we guard with a regex check (`~ '^[0-9.]+$'`) before casting. Non-numeric values (e.g., `'N/A'`, `'<0.5'`) result in `'N'` (no flag).

---

## 6. Data Completeness

Each score row tracks `data_completeness_pct` (0–100):

| Completeness | Meaning                                                   |
| ------------ | --------------------------------------------------------- |
| 100%         | All nutrition fields filled from verified label data      |
| 70–99%       | Most fields present; some estimated or missing            |
| < 70%        | Significant gaps — score should be treated as approximate |

### 6.1 Computation Formula

`data_completeness_pct` is a **weighted** field-availability check — fields that carry more scoring weight contribute more to completeness:

```sql
data_completeness_pct = round(100.0 * (
    -- EU mandatory 7 + key supplementary (weights = scoring importance)
    (CASE WHEN nf.calories        IS NOT NULL AND nf.calories        NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10%
    (CASE WHEN nf.total_fat_g     IS NOT NULL AND nf.total_fat_g     NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10%
    (CASE WHEN nf.saturated_fat_g IS NOT NULL AND nf.saturated_fat_g NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15%
    (CASE WHEN nf.carbs_g         IS NOT NULL AND nf.carbs_g         NOT IN ('N/A','') THEN 1 ELSE 0 END) *  5 +  --  5%
    (CASE WHEN nf.sugars_g        IS NOT NULL AND nf.sugars_g        NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15%
    (CASE WHEN nf.protein_g       IS NOT NULL AND nf.protein_g       NOT IN ('N/A','') THEN 1 ELSE 0 END) *  5 +  --  5%
    (CASE WHEN nf.salt_g          IS NOT NULL AND nf.salt_g          NOT IN ('N/A','') THEN 1 ELSE 0 END) * 15 +  -- 15%
    (CASE WHEN nf.trans_fat_g     IS NOT NULL AND nf.trans_fat_g     NOT IN ('N/A','') THEN 1 ELSE 0 END) * 10 +  -- 10%
    (CASE WHEN nf.fibre_g         IS NOT NULL AND nf.fibre_g         NOT IN ('N/A','') THEN 1 ELSE 0 END) *  5 +  --  5%
    (CASE WHEN i.additives_count  IS NOT NULL AND i.additives_count  NOT IN ('N/A','') THEN 1 ELSE 0 END) *  5 +  --  5% (scoring weight: 0.07)
    (CASE WHEN i.ingredients_raw  IS NOT NULL AND i.ingredients_raw  != ''              THEN 1 ELSE 0 END) *  5    --  5%
) / 100.0)
```

**Why weighted?** — Sat fat, sugars, and salt each carry 0.17 scoring weight, so their absence has the largest impact on score accuracy. Trans fat (0.11 weight) gets 10%. Fields with no direct scoring weight (carbs, protein) get minimal completeness weight (5%).

**Trace values are NOT penalized** — `'<0.5'` and `'trace'` are real label information and count as "present."

### 6.2 Energy Cross-Check

As an additional validation, every score should include an energy cross-check:

```
Computed energy = (fat × 9) + (carbs × 4) + (protein × 4) + (fibre × 2)
Tolerance       = ±15% of declared calories
```

If the computed energy falls outside the ±15% tolerance, add a SQL comment flagging the discrepancy. This catches data entry errors and label mismatches. The energy cross-check does not affect the score but serves as a quality gate.

### 6.3 Confidence Levels

The `confidence` column further qualifies the score:

| Value       | Meaning                                      |
| ----------- | -------------------------------------------- |
| `verified`  | All data from primary label source           |
| `estimated` | Some values estimated from category averages |
| `low`       | Insufficient data for reliable scoring       |

> **Note:** `computed` is not a valid confidence level. The database CHECK constraint only allows `verified`, `estimated`, `low`.

See `DATA_SOURCES.md` §5 and `RESEARCH_WORKFLOW.md` §6.4 for the full confidence determination workflow.

---

## 7. Scientific References

- **WHO guidelines on sugars intake** (2015). Guideline: Sugars intake for adults and children. Geneva: WHO.
- **WHO guidelines on sodium intake** (2023). Guideline: Sodium intake for adults and children. Geneva: WHO.
- **WHO: REPLACE trans fat** (2023). An action package to eliminate industrially-produced trans-fatty acids. Geneva: WHO.
- **EFSA scientific opinion on dietary reference values for fats** (2010). EFSA Journal 8(3):1461.
- **EFSA opinion on process contaminants in palm oil** (2016). Risks for human health related to the presence of 3- and 2-MCPD in food. EFSA Journal 14(5):4426.
- **EFSA opinion on titanium dioxide (E171)** (2021). Safety assessment of titanium dioxide (E171) as a food additive. EFSA Journal 19(5):6585.
- **EU Regulation 2019/649** on maximum levels of trans fatty acids in food.
- **EU Regulation 2017/2158** establishing mitigation measures and benchmark levels for the reduction of acrylamide in food.
- **EFSA scientific opinion on PAHs in food** (2008). Polycyclic Aromatic Hydrocarbons in Food. EFSA Journal 724, 1–114.
- **IARC Monographs Vol. 114** (2018). Red meat and processed meat — HCA/PAH classification (Group 2A probable carcinogen).
- **Monteiro et al.** (2019). Ultra-processed foods: what they are and how to identify them. Public Health Nutrition, 22(5), 936–941.
- **Schnabel et al.** (2019). Association between ultra-processed food consumption and risk of mortality. JAMA Internal Medicine, 179(4), 490–498.
- **Fiolet et al.** (2018). Consumption of ultra-processed foods and cancer risk. BMJ, 360, k322.
- **Louzada et al.** (2015). Ultra-processed foods and the nutritional dietary profile in Brazil. Revista de Saúde Pública, 49, 38.
- **Regulation (EU) No 1169/2011** on the provision of food information to consumers.
- **Regulation (EU) No 1169/2011, Annex XIII** — Reference intakes and "high" thresholds for front-of-pack declarations.
- **Nutri-Score algorithm** (2024 update). Santé Publique France.

---

## 8. Changelog

| Version | Date       | Changes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v1.0    | 2026-02-07 | Initial methodology — basic nutrient scoring                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| v2.0    | 2026-02-07 | Added NOVA, processing risk, flag columns                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| v2.2    | 2026-02-07 | Added personal lenses, data completeness, confidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| v2.3    | 2026-02-07 | Added formula, Nutri-Score thresholds, flag SQL, healthiness_score def, scored_at, nova_classification mapping                                                                                                                                                                                                                                                                                                                                                                                                            |
| v3.0    | 2026-02-07 | Scientific justification for all thresholds, trace value parsing, data_completeness formula, weight rationale, energy cross-check, version bump                                                                                                                                                                                                                                                                                                                                                                           |
| v3.1    | 2026-02-07 | Removed healthiness_score (derivable), personal lenses (unimplemented), ingredient_complexity scoring factor (redundant with additives + NOVA). Dropped cholesterol_mg, potassium_mg, aluminium_based_additives columns. Redistributed 0.04 weight to additives (0.05→0.07) and controversies (0.06→0.08). Extracted formula into `compute_unhealthiness_v31()` PostgreSQL function (migration 000501); all category pipelines now call the function instead of inline SQL.                                               |
| v3.1b   | 2026-02-10 | Expanded `prep_method` scoring: added `steamed=30`, `grilled=60`, `smoked=65` (were all 50 via ELSE). Backfilled 134 NULL prep_method values across 5 categories. Made `prep_method` NOT NULL with default `'not-applicable'`. Added scientific references for PAH (EFSA 2008), HCA (IARC Group 2A).                                                                                                                                                                                                                      |
| v3.2    | 2026-02-10 | Added 9th scoring factor: **ingredient concern** (weight 0.05) based on EFSA additive risk tiers (concern_tier 0–3 on ingredient_ref). New `compute_unhealthiness_v32()` function. Redistributed weights: sat_fat/sugars/salt 0.18→0.17, trans_fat 0.12→0.11, prep 0.09→0.08. Cleaned 375 foreign ingredient names to ASCII English. Rebuilt `ingredients_raw` from junction data (492 products). Added real serving sizes from OFF API (317 products). Fixed v_master fan-out with `serving_basis = 'per 100 g'` filter. |
