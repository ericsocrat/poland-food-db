# ADR-009: Scoring Band Calibration — Distribution Investigation

> **Date:** 2026-03-10
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The v3.3 scoring formula defines five consumer bands across the full 1–100 unhealthiness range:

| Band | Unhealthiness | Consumer Label |
|------|--------------|----------------|
| Green | 1–20 | Excellent |
| Yellow | 21–40 | Good |
| Orange | 41–60 | Moderate |
| Red | 61–80 | Poor |
| Dark Red | 81–100 | Bad |

Across 2,593 scored products (22 PL + 21 DE categories), **zero products** fall in the Red or Dark Red bands. The maximum observed score is 53 (Orange band). This raised the question: is the formula properly calibrated, or should bands or weights be adjusted?

Three paths were evaluated:

1. **Path A: Catalog limited, formula correct** — The formula is mathematically sound (theoretical max = 100). The empty upper bands reflect catalog composition — no product in the dataset simultaneously maxes all 9 penalty factors.
   - ✅ Chosen: Supported by factor analysis, theoretical simulations, and production data.

2. **Path B: Formula compression — adjust weights/ceilings** — Increase weights or lower ceilings to push scores higher.
   - ❌ Rejected: Would artificially inflate scores for products that are only moderately unhealthy — violates the principle of honest, science-backed scoring. Anchor products would drift.

3. **Path C: Narrow the band boundaries** — Redefine bands to match observed distribution (e.g., Green=1–12, Yellow=13–28, Orange=29–53).
   - ❌ Rejected: Would label products as "Poor" that are genuinely only "Moderate" by nutritional science standards. Misleads consumers and erodes trust if future catalog expansion introduces truly unhealthy products that then share a band with current "Moderate" items.

## Decision

**Retain the current band definitions and scoring formula (v3.3) without modification.** The empty Red and Dark Red bands are a correct reflection of the product catalog's composition, not a formula deficiency.

### Evidence

**Factor utilization analysis (2,593 products):**

| Factor | Weight | Avg % of Ceiling | Products at Ceiling |
|--------|--------|-----------------|--------------------:|
| Saturated fat | 0.17 | 30.0% | 357 (13.8%) |
| Sugars | 0.17 | 25.6% | 234 (9.0%) |
| Salt | 0.17 | 28.6% | 103 (4.0%) |
| Calories | 0.10 | 42.8% | 201 (7.8%) |
| Trans fat | 0.11 | **0.0%** | **0 (0%)** |

The highest-scoring product (Groovy ritter, score 53) hits ceiling on only 2 of 9 factors (saturated fat + sugars = 34% of total weight). The remaining 66% of weight capacity is largely unused.

**Trans fat utilization is zero** across the entire catalog — EU Regulation 2019/649 effectively eliminated industrially-produced trans fat from packaged foods in the EU market.

**Theoretical maximum simulations:**

| Scenario | Score | Band |
|----------|------:|------|
| All 9 factors at ceiling, no density bonus | **100** | Dark Red |
| Realistic worst food (deep-fried, additives, trans fat, palm oil) | **76** | Red |
| Actual catalog maximum (Groovy ritter sport) | **53** | Orange |

The formula produces the full 1–100 range when inputs warrant it.

**Nutrient density bonus impact:** −0.8 to −2.8 points for the worst products — not a significant compression factor.

### Why the catalog doesn't reach Red/Dark Red

Packaged supermarket foods in the PL/DE market:
- Are never deep-fried (prep_method = "not-applicable" for packaged goods)
- Have 0.0% trans fat utilization (EU regulation)
- Rarely have "serious" controversies
- Have moderate additive counts (max ~10 with enrichment)
- Never simultaneously max all 9 dimensions

The 9-factor weighted design is intentionally multi-dimensional: a product must be comprehensively unhealthy to score above 60.

## Consequences

### Positive

- **Scoring honesty preserved** — scores reflect real nutritional harm, not artificial calibration
- **Reserve capacity** — Red/Dark Red bands remain available for future product categories (fast food, energy drinks, ultra-processed convenience meals)
- **Anchor stability** — no regression risk for existing products (zero scoring code changed)
- **Consumer trust** — bands have consistent, defensible meaning regardless of catalog size

### Negative

- **Empty bands in UI** — users may question why no product scores "Poor" or "Bad" (addressed via documentation and potential future UI tooltip explaining the scoring range)
- **No immediate visual differentiation** — the 44-point gap between actual max (53) and Dark Red floor (81) is unused capacity

### Neutral

- `SCORING_METHODOLOGY.md` updated with a distribution note (§ 2.10)
- No migration, function, or frontend changes required
- No QA suite changes needed — all existing checks continue to pass

---

> **Template:** Based on [MADR 3.0](https://adr.github.io/madr/) (Markdown Any Decision Records)
