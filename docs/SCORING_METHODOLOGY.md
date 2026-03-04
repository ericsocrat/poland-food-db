# Scoring Methodology

> **Version:** 3.3
> **Last updated:** 2026-03-03
> **Scope:** TryVit

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

The score is a **weighted sum of sub-scores**, each normalized to 0–100, then combined with the weights below. In v3.3, a 10th factor — **nutrient density bonus** — is *subtracted* from the penalty sum, rewarding products with meaningful protein and fibre content.

**Why these thresholds?** Each ceiling is set at the point where a product consumed regularly at that level would approach or exceed daily recommended limits. The per-100g ceiling represents the concentration at which ~2–3 servings would meet or exceed the WHO/EFSA daily guideline.

#### Penalty Factors (9 factors — weights sum to 1.00)

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

#### Bonus Factor (v3.3 — subtracted from penalty sum)

| Factor           | Column source           | Weight | Ceiling        | Scientific basis                                                                           |
| ---------------- | ----------------------- | ------ | -------------- | ------------------------------------------------------------------------------------------ |
| Nutrient density | `protein_g` + `fibre_g` | 0.08   | 100 (combined) | EFSA 2017 DRV for protein (0.83 g/kg/day); WHO 2015 fibre guideline (≥25 g/day). See §2.8. |

**Weight rationale (v3.3):** The 9 penalty factors are unchanged from v3.2. Saturated fat, sugars, and salt share the highest weight (0.17 each) because they are the three nutrients cited by WHO as primary dietary risks for NCDs. Trans fat has high weight (0.11) because trans fats have no safe level of intake (WHO). The ingredient concern factor (0.05) captures additive safety signals from EFSA re-evaluations. The new nutrient density bonus (0.08, subtracted) rewards products with meaningful protein and fibre — the two positive nutrients most reliably reported on EU food labels. This follows the Nutri-Score 2024 approach of crediting positive nutrients. The bonus weight of 0.08 was chosen to produce a maximum 8-point reduction, enough to meaningfully differentiate within categories without overwhelming penalty factors.

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
    - nutrient_density_sub * 0.08
)
```

Where each **penalty** sub-score is computed as:

```
sub_score = LEAST(100, (value / threshold) * 100)
```

For categorical factors (oil method, controversies, ingredient concern), use the fixed lookup values from the tables above.

The **nutrient density** bonus sub-score is computed as:

```
nutrient_density_sub = LEAST(100, protein_tier + fibre_tier)
```

See §2.8 for the protein and fibre tier tables.

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

**controversies sub-score mapping:**

| Value        | Sub-score | Scientific basis                                                         |
| ------------ | --------- | ------------------------------------------------------------------------ |
| `'none'`     | 0         | No known controversy                                                     |
| `'minor'`    | 30        | Low-level concern (e.g., debated processing methods)                     |
| `'palm oil'` | 40        | EFSA 2016: process contaminants (3-MCPD, glycidyl esters) in refined oil |
| `'moderate'` | 60        | Notable health controversy with regulatory discussion                    |
| `'serious'`  | 100       | E.g., E171 (EFSA 2021: no longer considered safe), banned substances     |

**ingredient_concern_score sub-score (v3.2):**

Each ingredient in `ingredient_ref` has a `concern_tier` (0–3) assigned from EFSA additive re-evaluations:

| Tier | Label    | Examples                              | Score contribution |
| ---- | -------- | ------------------------------------- | ------------------ |
| 0    | None     | Water, sugar, salt, flour             | 0                  |
| 1    | Low      | Lecithins (E322), citric acid (E330)  | 15                 |
| 2    | Moderate | Artificial sweeteners, some colorants | 40                 |
| 3    | High     | Nitrites (E250), BHA (E320), azo dyes | 100                |

The per-product `ingredient_concern_score` (0–100) is computed as: `LEAST(100, SUM(concern_tier_score_per_ingredient))`. Products with no classified additives score 0. The score is stored on the `products` table and passed to `compute_unhealthiness_v33()` as the 9th parameter.

```sql
-- Function signature (returns INTEGER [1, 100])
compute_unhealthiness_v33(
    p_saturated_fat_g NUMERIC,    -- ceiling: 10g
    p_sugars_g        NUMERIC,    -- ceiling: 27g
    p_salt_g          NUMERIC,    -- ceiling: 3g
    p_calories        NUMERIC,    -- ceiling: 600 kcal
    p_trans_fat_g     NUMERIC,    -- ceiling: 2g
    p_additives_count NUMERIC,    -- ceiling: 10
    p_prep_method     TEXT,       -- categorical
    p_controversies   TEXT,       -- categorical
    p_concern_score   NUMERIC,    -- 0-100 EFSA concern score
    p_protein_g       NUMERIC,    -- nutrient density: protein (v3.3)
    p_fibre_g         NUMERIC     -- nutrient density: fibre (v3.3)
)
```

**Pipeline usage** (each category's `04_scoring.sql`):

Scoring is now consolidated into the `score_category()` procedure. Each category's
`04_scoring.sql` calls it after setting Nutri-Score and NOVA:

```sql
-- Set Nutri-Score and NOVA via data-driven UPDATE ... FROM (VALUES ...)
-- then call the consolidated scoring procedure:
CALL score_category('<CATEGORY>');
```

The `score_category()` procedure handles: ingredient concern defaults,
`compute_unhealthiness_v33()`, flag computation, data completeness, and confidence.

### ~~2.5 `scored_at` Timestamp~~ (removed — column dropped in migration 20260211000500)

> The `scored_at` column was dropped as redundant pipeline metadata. Score freshness can be tracked through migration history and pipeline run logs.

### 2.6 Score Bands

| Range  | Interpretation                              | Typical products                   |
| ------ | ------------------------------------------- | ---------------------------------- |
| 1–20   | Low concern                                 | Plain oats, raw vegetables         |
| 21–40  | Moderate — acceptable for regular use       | Whole-grain bread, basic yogurt    |
| 41–60  | Elevated — occasional consumption advised   | Baked chips, sweetened cereal      |
| 61–80  | High — frequent use is a health risk        | Fried chips, sugary drinks         |
| 81–100 | Very high — minimal consumption recommended | Deep-fried + high-salt + additives |

### ~~2.7 Scoring Version~~ (removed — column dropped in migration 20260211000500)

> The `scoring_version` column was dropped because all rows were `'v3.2'`. The version is now tracked only in `score_breakdown->>'version'` (JSONB). When methodology changes, update the function and this document.

### 2.8 Nutrient Density Bonus Factor (v3.3)

Added in v3.3, the nutrient density factor rewards products with meaningful protein and/or fibre content by **subtracting** a bonus from the penalty sum. This addresses a v3.2 limitation where nutritionally dense products (Greek yogurt, whole-grain bread, smoked fish) scored identically to nutrient-poor products at the same fat/sugar/salt levels.

#### 2.8.1 Protein Tier Table

| Protein per 100g | Tier Score | Rationale                                                    |
| ---------------- | ---------- | ------------------------------------------------------------ |
| ≥ 20 g           | 50         | High-protein (meat, fish, Greek yogurt, legumes)             |
| ≥ 15 g           | 40         | Good protein source (EU Regulation 1924/2006 "high protein") |
| ≥ 10 g           | 30         | Moderate protein (cheese, eggs, tofu)                        |
| ≥ 5 g            | 15         | Some protein contribution                                    |
| < 5 g            | 0          | Negligible protein — no bonus                                |

**Scientific basis:** EFSA (2017) Dietary Reference Values for protein — adult PRI of 0.83 g/kg body weight/day (~58 g for 70 kg adult). Products providing ≥20 g/100g deliver >34% of daily needs per 100g serving.

#### 2.8.2 Fibre Tier Table

| Fibre per 100g | Tier Score | Rationale                                                    |
| -------------- | ---------- | ------------------------------------------------------------ |
| ≥ 8 g          | 50         | Very high fibre (bran cereals, legumes)                      |
| ≥ 5 g          | 35         | High fibre — EU "high fibre" claim threshold (Reg 1924/2006) |
| ≥ 3 g          | 20         | Source of fibre — EU "source of fibre" threshold             |
| ≥ 1 g          | 10         | Some fibre contribution                                      |
| < 1 g          | 0          | Negligible fibre — no bonus                                  |

**Scientific basis:** WHO (2015) recommends ≥25 g/day dietary fibre for adults. Products providing ≥8 g/100g deliver >32% of daily needs per 100g serving.

#### 2.8.3 Combined Bonus Calculation

```
nutrient_density_sub = LEAST(100, protein_tier + fibre_tier)
bonus = nutrient_density_sub * 0.08
final_score = GREATEST(1, penalty_sum - bonus)
```

**Maximum bonus:** 8 points (when protein_tier + fibre_tier ≥ 100, e.g., 50 + 50 for a high-protein, high-fibre product like lentils).

**Design rationale:**
- **Subtracted, not added:** Protein and fibre are health-positive nutrients. Subtracting their contribution from the unhealthiness penalty rewards nutritionally dense foods.
- **Tiered, not linear:** Prevents gaming — 100g of pure protein isolate doesn't get an infinite bonus. Diminishing returns above practical thresholds.
- **Capped at 100 combined:** The combined tier score is capped at 100 before applying the 0.08 weight, ensuring the bonus never exceeds 8 points.
- **Weight of 0.08:** Chosen to provide meaningful differentiation (up to 8 points) without overwhelming the penalty factors. Approximately equal to the prep_method and controversies weights.

#### 2.8.4 Impact Examples

| Product                        | Protein | Fibre | Protein Tier | Fibre Tier | Combined | Bonus | Effect                     |
| ------------------------------ | ------- | ----- | ------------ | ---------- | -------- | ----- | -------------------------- |
| Piątnica Skyr Naturalny        | 12.0 g  | 0.0 g | 30           | 0          | 30       | 2.4   | Score reduced by ~2 points |
| Mestemacher Chleb wielozbożowy | 5.8 g   | 8.8 g | 15           | 50         | 65       | 5.2   | Score reduced by ~5 points |
| Tarczyński Kabanosy            | 26.0 g  | 0.0 g | 50           | 0          | 50       | 4.0   | Score reduced by ~4 points |
| Coca-Cola Zero                 | 0.0 g   | 0.0 g | 0            | 0          | 0        | 0.0   | No change — no nutrients   |
| Melvit Płatki owsiane          | 13.0 g  | 9.0 g | 30           | 50         | 80       | 6.4   | Score reduced by ~6 points |

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

The `products.nova_classification` column stores the **NOVA group number** as text (`'1'`, `'2'`, `'3'`, or `'4'`). The `processing_risk` label (Low/Moderate/High) is now **derived at query time** in `v_master` via a CASE expression on `nova_classification`, rather than stored as a separate column.

| `nova_classification` | Derived `processing_risk` |
| --------------------- | ------------------------- |
| `'1'`                 | `'Low'`                   |
| `'2'`                 | `'Low'`                   |
| `'3'`                 | `'Moderate'`              |
| `'4'`                 | `'High'`                  |
| `NULL`                | `'Unknown'`               |

Set `nova_classification` when: (a) Open Food Facts provides it, or (b) it can be determined from the ingredient list.

### 4.4 Why This Matters

Ultra-processed foods (NOVA 4) are independently associated with:
- Higher all-cause mortality (Schnabel et al., 2019)
- Increased cancer risk (Fiolet et al., 2018)
- Metabolic syndrome (Louzada et al., 2015)

These risks exist **even when the Nutri-Score looks acceptable**, which is why Processing Risk is a separate dimension.

---

## 5. Flag Columns

The `products` table includes binary flags for critical thresholds:

| Flag                 | Trigger condition            | Basis                                                |
| -------------------- | ---------------------------- | ---------------------------------------------------- |
| `high_salt_flag`     | Salt > 1.5 g per 100g        | EU "high salt" threshold (Reg. 1169/2011 Annex XIII) |
| `high_sugar_flag`    | Sugars > 12.5 g per 100g     | UK/EU "high sugar" threshold                         |
| `high_sat_fat_flag`  | Saturated fat > 5 g per 100g | EU "high saturated fat" threshold                    |
| `high_additive_load` | Additive count ≥ 5           | Project-defined threshold based on NOVA research     |

These flags are **informational overlays** — they do not replace the Unhealthiness Score but provide quick visual warnings.

### 5.1 Reference SQL for Flag Computation

Flags are computed by the `score_category()` procedure after nutrition facts are populated:

```sql
-- Flags are set automatically by CALL score_category('<CATEGORY>');
-- which internally computes:
--   high_salt_flag     = CASE WHEN salt_g > 1.5 THEN 'Y' ELSE 'N' END
--   high_sugar_flag    = CASE WHEN sugars_g > 12.5 THEN 'Y' ELSE 'N' END
--   high_sat_fat_flag  = CASE WHEN saturated_fat_g > 5.0 THEN 'Y' ELSE 'N' END
--   high_additive_load = CASE WHEN additives_count >= 5 THEN 'Y' ELSE 'N' END
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

`data_completeness_pct` is now computed **dynamically** by the `compute_data_completeness(product_id)` function, using 15 equal-weight checkpoints that cover the full data surface:

```sql
-- 15 checkpoints, each ~6.67%:
SELECT ROUND((
    (CASE WHEN p.ean IS NOT NULL THEN 1 ELSE 0 END) +                          -- 1. EAN
    (CASE WHEN nf.calories        IS NOT NULL THEN 1 ELSE 0 END) +             -- 2. Calories
    (CASE WHEN nf.total_fat_g     IS NOT NULL THEN 1 ELSE 0 END) +             -- 3. Total fat
    (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 1 ELSE 0 END) +             -- 4. Saturated fat
    (CASE WHEN nf.sugars_g        IS NOT NULL THEN 1 ELSE 0 END) +             -- 5. Sugars
    (CASE WHEN nf.salt_g          IS NOT NULL THEN 1 ELSE 0 END) +             -- 6. Salt
    (CASE WHEN nf.protein_g       IS NOT NULL THEN 1 ELSE 0 END) +             -- 7. Protein
    (CASE WHEN nf.carbs_g         IS NOT NULL THEN 1 ELSE 0 END) +             -- 8. Carbs
    (CASE WHEN nf.fibre_g         IS NOT NULL THEN 1 ELSE 0 END) +             -- 9. Fibre
    (CASE WHEN nf.trans_fat_g     IS NOT NULL THEN 1 ELSE 0 END) +             -- 10. Trans fat
    (CASE WHEN p.nutri_score_label != 'UNKNOWN' THEN 1 ELSE 0 END) +           -- 11. Nutri-Score (A-E or NOT-APPLICABLE)
    (CASE WHEN p.nova_classification IS NOT NULL THEN 1 ELSE 0 END) +           -- 12. NOVA
    (CASE WHEN EXISTS (...product_ingredient...) THEN 1 ELSE 0 END) +           -- 13. Ingredients
    (CASE WHEN EXISTS (...allergen OR ingredient...) THEN 1 ELSE 0 END) +       -- 14. Allergen assessment
    (CASE WHEN p.source_type IS NOT NULL THEN 1 ELSE 0 END)                     -- 15. Source provenance
)::numeric / 15.0 * 100)
```

**Key design decisions:**
- **Equal weights** — Each checkpoint is worth ~6.67%. This avoids over-weighting nutrition fields (which are almost always complete) at the expense of ingredient/allergen coverage.
- **Allergen assessment** (checkpoint 14) counts as passed if the product has allergen data OR ingredient data (since ingredient data implies allergen assessment was possible, even if the product is allergen-free).
- **NOT-APPLICABLE Nutri-Score** counts as "complete" — it's a valid assessment, not missing data.
- **Dynamic computation** — `score_category()` calls `compute_data_completeness()` automatically; the static `p_data_completeness` parameter is retained for backward compatibility but ignored.

**Current distribution** (1,025 active products): 791 at 100% · 68 at 93% · 110 at 87% · 55 at 80% · 1 at 73%.

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
- **EFSA Dietary Reference Values for protein** (2017). EFSA Journal 15(6):4880. PRI of 0.83 g/kg body weight/day for adults.
- **WHO guidelines on dietary fibre** (2015). Guideline: Sugars intake for adults and children (≥25 g/day fibre recommendation). Geneva: WHO.
- **Nutri-Score positive points methodology** (2024). Santé Publique France — protein and fibre as protective nutrients in front-of-pack scoring.

---

## 8. Changelog

| Version | Date       | Changes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v1.0    | 2026-02-07 | Initial methodology — basic nutrient scoring                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| v2.0    | 2026-02-07 | Added NOVA, processing risk, flag columns                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| v2.2    | 2026-02-07 | Added personal lenses, data completeness, confidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| v2.3    | 2026-02-07 | Added formula, Nutri-Score thresholds, flag SQL, healthiness_score def, scored_at, nova_classification mapping                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| v3.0    | 2026-02-07 | Scientific justification for all thresholds, trace value parsing, data_completeness formula, weight rationale, energy cross-check, version bump                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| v3.1    | 2026-02-07 | Removed healthiness_score (derivable), personal lenses (unimplemented), ingredient_complexity scoring factor (redundant with additives + NOVA). Dropped cholesterol_mg, potassium_mg, aluminium_based_additives columns. Redistributed 0.04 weight to additives (0.05→0.07) and controversies (0.06→0.08). Extracted formula into `compute_unhealthiness_v31()` PostgreSQL function (migration 000501); all category pipelines now call the function instead of inline SQL.                                                                                                                        |
| v3.1b   | 2026-02-10 | Expanded `prep_method` scoring: added `steamed=30`, `grilled=60`, `smoked=65` (were all 50 via ELSE). Backfilled 134 NULL prep_method values across 5 categories. Made `prep_method` NOT NULL with default `'not-applicable'`. Added scientific references for PAH (EFSA 2008), HCA (IARC Group 2A).                                                                                                                                                                                                                                                                                               |
| v3.2    | 2026-02-10 | Added 9th scoring factor: **ingredient concern** (weight 0.05) based on EFSA additive risk tiers (concern_tier 0–3 on ingredient_ref). New `compute_unhealthiness_v32()` function. Redistributed weights: sat_fat/sugars/salt 0.18→0.17, trans_fat 0.12→0.11, prep 0.09→0.08. Cleaned 375 foreign ingredient names to ASCII English. Rebuilt `ingredients_raw` from junction data (492 products). Added real serving sizes from OFF API (317 products). Fixed v_master fan-out with `serving_basis = 'per 100 g'` filter.                                                                          |
| v3.3    | 2026-03-03 | Added 10th factor: **nutrient density bonus** (weight 0.08, subtracted). New `compute_unhealthiness_v33()` function with 11 parameters — added `p_protein_g` and `p_fibre_g`. Protein tiered at 5/10/15/20 g thresholds; fibre tiered at 1/3/5/8 g thresholds. Combined bonus `LEAST(100, protein_tier + fibre_tier) * 0.08` subtracted from penalty sum, clamped to [1, 100]. Maximum 8-point reduction for nutrient-dense products. Penalty factor weights unchanged from v3.2. Scientific basis: EFSA 2017 protein DRV, WHO 2015 fibre guideline, Nutri-Score 2024 positive points methodology. |
