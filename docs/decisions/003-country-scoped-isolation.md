# ADR-003: Country-Scoped Data Isolation

> **Date:** 2026-02-13 (retroactive — implemented in migration `20260213001200`)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The database started as Poland-only but needs to support multiple countries (Germany micro-pilot launched with 51 Chips products). Two architectural approaches were considered:

1. **Single global product table, filter by country at query time** — simpler schema but requires discipline to always include `WHERE country = ...` in every query, view, and function.
2. **Separate schemas or databases per country** — strong isolation but complex cross-country queries, duplicated functions, harder to maintain.

The project chose option 1 with strict enforcement mechanisms.

## Decision

All product data lives in a **single set of tables** with a `country` column on `products` that references `country_ref(country_code)`. Isolation is enforced at multiple layers:

- **Schema layer:** `country_ref` table with `is_active` flag; FK from `products.country`
- **CHECK constraint:** `chk_products_country` limits values to active country codes
- **Query layer:** All views (`v_master`, `v_api_category_overview`) and API functions filter by country parameter
- **Pipeline layer:** Each country gets its own pipeline folder (`chips-pl/`, `chips-de/`)
- **QA layer:** `QA__country_isolation.sql` (11 checks) verifies no cross-contamination
- **CI layer:** `QA__multi_country_consistency.sql` (10 checks) validates consistency rules

## Consequences

### Positive

- **Single schema** — no function duplication, shared scoring logic, unified migrations
- **Easy expansion** — adding a country is `INSERT INTO country_ref` + pipeline folder + data
- **Cross-country queries possible** — useful for comparison features (e.g., same brand in PL vs DE)
- **Well-documented** — `docs/COUNTRY_EXPANSION_GUIDE.md` provides step-by-step protocol

### Negative

- **Requires discipline** — every new query/function must include country filtering
- **Risk of data leakage** — if a developer forgets `WHERE country = $1`, users see mixed data
- **QA overhead** — 21 checks across 2 QA suites exist specifically to catch isolation failures

### Neutral

- Currently 2 active countries: PL (primary, 1,025 products) and DE (micro-pilot, 51 products)
- Pipeline auto-detects country from folder naming convention (`*-pl/`, `*-de/`)
