# ADR-008: Nutrient Density Bonus in Scoring Formula (v3.3)

> **Date:** 2026-03-03
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The v3.2 scoring formula uses 9 penalty factors to compute an unhealthiness score (1–100). All factors are additive penalties — the formula has no mechanism to reward nutritionally positive attributes. This creates a structural blindness:

- A protein-rich Greek yogurt (12 g protein/100 g) scores identically to a sugar-matched dessert with no protein
- A high-fibre whole-grain cereal (9 g fibre/100 g) receives no credit for its fibre content
- Products with genuine nutritional value (salmon, oats, legumes) are penalized by their fat or calorie content without any offsetting credit

This contradicts established nutritional science. Both the Nutri-Score algorithm (2024 revision) and EFSA dietary reference values recognize protein and fibre as health-positive nutrients that should influence product evaluation.

Three approaches were considered:

1. **Separate positive score** — compute a separate "healthiness" score alongside the existing "unhealthiness" score. Display both in the UI.
   - ❌ Rejected: doubles UI complexity, confuses users with two competing numbers, breaks the single-axis ranking model that enables category comparisons.

2. **Reduce penalty weights to accommodate positive factors** — shrink existing weights proportionally to make room for positive factors within the same 1.00 budget.
   - ❌ Rejected: weakens penalty sensitivity for harmful nutrients (salt, sugar, sat fat). A product with 27 g sugar/100 g should be penalized at full strength regardless of its protein content.

3. **Subtracted bonus factor** — add a 10th factor that is subtracted from the penalty sum. Keep all 9 penalty weights unchanged (sum = 1.00). The bonus operates outside the penalty budget.
   - ✅ Chosen: preserves full penalty sensitivity while rewarding nutrient-dense foods. The bonus is capped to prevent gaming (max 8 points reduction). This mirrors the Nutri-Score 2024 "positive points" approach.

## Decision

Scoring v3.3 introduces a **nutrient density bonus** as the 10th factor in the formula:

```
unhealthiness_score = CLAMP(1, 100,
    penalty_sum(9 factors × weights, sum = 1.00)
  − nutrient_density_bonus(weight = 0.08)
)
```

### Bonus calculation

The bonus uses tiered thresholds rather than linear scaling:

**Protein tiers (per 100 g):**

| Protein (g) | Tier Score | Scientific Basis                  |
| ----------- | ---------- | --------------------------------- |
| ≥ 20        | 50         | EFSA DRV: excellent source        |
| ≥ 15        | 40         | High protein (EU claim threshold) |
| ≥ 10        | 30         | Source of protein                 |
| ≥ 5         | 15         | Moderate contribution             |
| < 5         | 0          | Negligible                        |

**Fibre tiers (per 100 g):**

| Fibre (g) | Tier Score | Scientific Basis                |
| --------- | ---------- | ------------------------------- |
| ≥ 8       | 50         | WHO: excellent source           |
| ≥ 5       | 35         | High fibre (EU claim threshold) |
| ≥ 3       | 20         | Source of fibre                 |
| ≥ 1       | 10         | Minimal contribution            |
| < 1       | 0          | Negligible                      |

**Combined bonus:**
```
combined_raw = LEAST(100, protein_tier + fibre_tier)
bonus_sub    = combined_raw * 0.08
```

Maximum possible bonus: `100 × 0.08 = 8 points` subtracted from the penalty sum.

### Design constraints

- **Subtracted, not added** — the bonus reduces the unhealthiness score, it does not inflate it
- **Tiered, not linear** — prevents gaming via protein/fibre fortification; diminishing returns above thresholds
- **Capped at 100** — combined tier scores cannot exceed 100 (prevents over-rewarding products with both high protein AND high fibre)
- **Weight 0.08** — equal to the prep_method and controversies weights; meaningful but not dominant
- **Clamped output** — final score remains in [1, 100] regardless of bonus magnitude
- **Penalty weights unchanged** — all 9 penalty factor weights remain at their v3.2 values (sum = 1.00)

### Implementation

- **Function:** `compute_unhealthiness_v33()` — 11 parameters (9 from v3.2 + `p_protein_g`, `p_fibre_g`)
- **Explanation:** `explain_score_v33()` — JSONB breakdown now includes the bonus factor
- **Procedure:** `score_category()` updated to call v3.3
- **Migration:** `20260302000100_scoring_v33_nutrient_density.sql`

## Consequences

### Positive

- **Nutritional fairness** — protein-rich and fibre-rich foods receive deserved credit (e.g., Skyr: 8→5, oats: 13→7)
- **Better differentiation** — products in the same category are now distinguished by nutritional quality, not just harm
- **Scientific alignment** — mirrors Nutri-Score 2024 positive points and EFSA protein/fibre DRV guidance
- **Backward compatible** — products with zero protein and fibre score identically to v3.2 (bonus = 0)
- **Transparent** — `explain_score_v33()` exposes the bonus factor in the score breakdown JSONB

### Negative

- **Score drift** — all products with protein ≥ 5 or fibre ≥ 1 per 100 g will see score reductions (up to −8 points). Regression anchor tests updated accordingly.
- **Two-input dependency** — requires `protein_g` and `fibre_g` from `nutrition_facts`; products missing these fields get zero bonus (safe degradation)
- **Complexity increase** — formula now has 10 factors (9 penalty + 1 bonus) instead of 9

### Neutral

- QA suite `QA__scoring_formula_tests.sql` updated with v3.3 regression anchors
- `explain_score_v33()` includes the bonus factor with `bonus: true` flag in the JSONB breakdown
- Scoring documentation updated: `SCORING_METHODOLOGY.md`, `SCORING_ENGINE.md`, `copilot-instructions.md §14`
