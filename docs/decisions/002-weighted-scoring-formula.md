# ADR-002: Weighted 9-Factor Unhealthiness Scoring Formula (v3.2)

> **Date:** 2026-02-10 (retroactive — v3.2 finalized in migration `20260210001900`)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The project needs a single composite score (1–100) to rank products by health risk. Existing systems like Nutri-Score (A–E) are useful but coarse — they don't capture processing risk, additive concerns, or preparation method impact.

Approaches considered:

1. **Use Nutri-Score directly** — simple but only 5 buckets, doesn't penalize ultra-processing or additives.
2. **Binary good/bad classification** — too simplistic for 1,000+ products across 20 categories.
3. **Custom weighted formula** — more engineering effort but captures the specific risk dimensions consumers care about.

The formula evolved through versions: v1.0 (3 factors), v2.0 (5 factors), v3.0 (7 factors), v3.1 (8 factors), v3.2 (9 factors with EFSA-based ingredient concern scoring).

## Decision

Use a **9-factor weighted sum** where each factor is normalized to 0–100 with per-100g ceilings based on WHO/EFSA daily limits, then combined:

```
unhealthiness_score =
  sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
  trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
  controversies(0.08) + ingredient_concern(0.05)
```

Implemented as `compute_unhealthiness_v32()` SQL function. Scoring is **never inlined** — always called via `score_category()` procedure which handles all 5 scoring steps.

## Consequences

### Positive

- **Fine-grained ranking** — 100-point scale enables meaningful sorting within categories
- **Transparent** — `explain_score_v32()` returns per-factor breakdowns as JSONB
- **Extensible** — adding a new factor is a weight rebalance + migration, not a rewrite
- **Science-grounded** — each ceiling tied to WHO/EFSA daily guideline thresholds
- **Regression-tested** — 11 anchor products with expected scores in QA suite

### Negative

- **Weights are editorial** — reasonable people can disagree on sat_fat vs. salt importance
- **Formula drift risk** — any change requires updating all 1,076 products; mitigated by `check_formula_drift()` and `governance_drift_check()`
- **Per-100g bias** — products consumed in small quantities (spices, condiments) may score misleadingly high

### Neutral

- Nutri-Score and NOVA are stored as separate dimensions, not replaced by this score
- Full methodology documented in `docs/SCORING_METHODOLOGY.md`
- Version history tracked in `scoring_model_versions` table with SHA-256 fingerprint
