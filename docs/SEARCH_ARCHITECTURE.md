# Search Architecture

> **Issue:** #192 · **Status:** Implemented (Phase 1–2, Phase 3 stub)
> **Last updated:** 2026-02-26

---

## Overview

Product search is the primary user interaction in Poland Food DB. This document
formalizes the search ranking model, multi-language strategy, synonym
infrastructure, quality metrics plan, and scale roadmap.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     SEARCH LAYER                            │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Query         │  │ Ranking       │  │ Quality          │  │
│  │ Parser        │  │ Engine        │  │ Monitor          │  │
│  │               │  │               │  │                  │  │
│  │ unaccent()    │  │ search_rank() │  │ search_quality   │  │
│  │ Tokenize      │  │ 5-signal      │  │ _report()        │  │
│  │ Synonym       │  │ weighted      │  │ (Phase 3/#190)   │  │
│  │ expand        │  │ composite     │  │                  │  │
│  └──────┬───────┘  └──────┬───────┘  └─────────────────┘  │
│         │                  │                                │
│         ▼                  ▼                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   PostgreSQL FTS + Trigram Hybrid                    │   │
│  │   tsvector GIN index + pg_trgm GIN index            │   │
│  │   build_search_vector() per-country tokenization     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   PHASE 3 (future): Typesense / Meilisearch         │   │
│  │   Triggered when P95 > 200ms at product count        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Ranking Model

### 5-Signal Composite Score

The `search_rank()` function computes a weighted composite of five signals:

| #   | Signal             | Weight | Range   | Source                                  |
| --- | ------------------ | ------ | ------- | --------------------------------------- |
| 1   | Full-text ts_rank  | 0.35   | 0–1     | `ts_rank(search_vector, tsquery)`       |
| 2   | Trigram similarity | 0.30   | 0–1     | `similarity()` across name/brand fields |
| 3   | Synonym match      | 0.15   | 0–1     | `ts_rank()` on expanded synonym terms   |
| 4   | Category context   | 0.10   | 0/0.5/1 | Query-category string overlap           |
| 5   | Data completeness  | 0.10   | 0–1     | `data_completeness_pct / 100`           |

**Formula:**

$$\text{score} = \sum_{i=1}^{5} w_i \cdot s_i$$

Where $w_i$ are weights from `search_ranking_config` and $s_i$ are signal values.

### Configurable Weights

Weights are stored in the `search_ranking_config` table:

```sql
SELECT config_name, weights, active
FROM search_ranking_config;
```

Only one config may be active at a time (enforced by partial unique index).
The `new_search_ranking` feature flag gates usage of `search_rank()` vs
the legacy inline ranking in `api_search_products()`.

### Legacy Ranking (fallback)

When `new_search_ranking` flag is disabled, the original 3-component additive
formula is used:

```
relevance = ts_rank(vector, query)
           + GREATEST(similarity(name), similarity(name_en), similarity(brand) * 0.8)
           + ts_rank(vector, synonym_query) * 0.9
```

---

## Multi-Language Strategy

### Text Search Configurations

| Country | Config    | Stemming | Notes                               |
| ------- | --------- | -------- | ----------------------------------- |
| PL      | `simple`  | None     | Upgrade to Polish ispell when ready |
| DE      | `german`  | Yes      | Built-in PostgreSQL German stemmer  |
| EN/UK   | `english` | Yes      | Built-in PostgreSQL English stemmer |
| CZ      | `simple`  | None     | Future: Czech stemmer               |

The `build_search_vector()` function selects the appropriate configuration
based on the product's `country` field. The trigger fires on INSERT/UPDATE
of `product_name`, `product_name_en`, `brand`, `category`, or `country`.

### Synonym Dictionary

Cross-language synonyms are stored in `search_synonyms`:

| Direction | Pairs | Example      |
| --------- | ----- | ------------ |
| PL ↔ EN   | ~50   | mleko ↔ milk |
| DE ↔ EN   | ~50   | milch ↔ milk |

The `expand_search_query()` function returns all synonym terms for a query,
enabling cross-language search without the user needing to know both languages.

#### Adding Synonyms

```sql
INSERT INTO search_synonyms (term_original, term_target, language_from, language_to)
VALUES
    ('new_term_pl', 'new_term_en', 'pl', 'en'),
    ('new_term_en', 'new_term_pl', 'en', 'pl');
```

Always add both directions for bidirectional lookup.

---

## Search Infrastructure

### Database Objects

| Object                         | Type       | Purpose                                       |
| ------------------------------ | ---------- | --------------------------------------------- |
| `products.search_vector`       | Column     | Pre-computed tsvector (GIN indexed)           |
| `build_search_vector()`        | Function   | Language-aware tsvector builder               |
| `search_rank()`                | Function   | 5-signal formalized ranking                   |
| `search_ranking_config`        | Table      | Configurable ranking weights                  |
| `search_synonyms`              | Table      | Cross-language synonym dictionary             |
| `expand_search_query()`        | Function   | Synonym expansion                             |
| `api_search_products()`        | RPC        | Main search endpoint                          |
| `api_search_autocomplete()`    | RPC        | Prefix autocomplete                           |
| `api_search_did_you_mean()`    | RPC        | Fuzzy suggestions for zero-result queries     |
| `search_quality_report()`      | RPC (stub) | Quality dashboard (pending #190)              |
| `trg_products_search_vector()` | Trigger    | Auto-updates search_vector on product changes |

### Indexes

| Index                                     | Type             | Table                 | Purpose                       |
| ----------------------------------------- | ---------------- | --------------------- | ----------------------------- |
| `idx_products_search_vector`              | GIN              | products              | Full-text search              |
| `idx_search_synonyms_lookup`              | btree            | search_synonyms       | Fast synonym lookup           |
| `idx_search_ranking_config_single_active` | unique (partial) | search_ranking_config | Enforces single active config |

### Feature Flags

| Flag                 | Type       | Default  | Purpose                             |
| -------------------- | ---------- | -------- | ----------------------------------- |
| `new_search_ranking` | boolean    | disabled | Gates `search_rank()` in search RPC |
| `new_search_ui`      | percentage | disabled | Gates frontend search UI changes    |

---

## Frontend Components

| Component          | File                                   | Purpose                       |
| ------------------ | -------------------------------------- | ----------------------------- |
| SearchAutocomplete | `components/search/SearchAutocomplete` | Debounced prefix autocomplete |
| FilterPanel        | `components/search/FilterPanel`        | Multi-facet filter sidebar    |
| ActiveFilterChips  | `components/search/ActiveFilterChips`  | Active filter chip bar        |
| DidYouMean         | `components/search/DidYouMean`         | Zero-result fuzzy suggestions |
| SaveSearchDialog   | `components/search/SaveSearchDialog`   | Save search query + filters   |

### Zod Contracts

| Contract                      | Validates                          |
| ----------------------------- | ---------------------------------- |
| `SearchProductsContract`      | `api_search_products` response     |
| `SearchAutocompleteContract`  | `api_search_autocomplete` response |
| `FilterOptionsContract`       | `api_get_filter_options` response  |
| `SavedSearchesContract`       | `api_get_saved_searches` response  |
| `SearchQualityReportContract` | `search_quality_report` response   |

---

## Performance Targets

| Operation         | Target P95 | Current (2.5K) | Approach                  |
| ----------------- | ---------- | -------------- | ------------------------- |
| Full search       | < 150ms    | ~50ms          | tsvector + trigram hybrid |
| Autocomplete      | < 50ms     | ~20ms          | Prefix index + LIMIT      |
| Synonym expansion | < 5ms      | < 2ms          | Indexed lookup            |

### Scale Tipping Points

| Scale    | Strategy                            | Trigger            |
| -------- | ----------------------------------- | ------------------ |
| < 10K    | PostgreSQL native (current)         | Now                |
| 10K–50K  | PostgreSQL + read replica           | Search P95 > 100ms |
| 50K–200K | Dedicated search engine (Typesense) | Search P95 > 200ms |
| > 200K   | Search engine + ML re-ranking       | CTR < 25%          |

---

## Quality Metrics (Phase 3 — requires #190)

The `search_quality_report()` function is deployed as a stub. When Event
Analytics (#190) provides the `analytics_events` table, it will calculate:

| Metric                | Description                       | Alert Threshold |
| --------------------- | --------------------------------- | --------------- |
| Zero-result rate      | % of queries returning 0 results  | > 15%           |
| Click-through rate    | % of searches where user clicks   | < 30%           |
| Mean Reciprocal Rank  | Average 1/position of first click | < 0.3           |
| Avg results per query | Mean result count                 | < 3             |

---

## Security

| Concern                  | Mitigation                                       |
| ------------------------ | ------------------------------------------------ |
| Query injection          | `plainto_tsquery()` / parameterized queries      |
| Search abuse (DoS)       | Rate limiting (#182) on search endpoint          |
| Data leakage             | RLS enforced; country-scoped results only        |
| Autocomplete harvesting  | Rate limited per IP                              |
| Synonym manipulation     | `search_synonyms` writable by service_role only  |
| Ranking config tampering | `search_ranking_config` writable by service_role |

---

## A/B Testing Ranking Models

1. Create a new config in `search_ranking_config` with different weights
2. Set `active = false` on the new config
3. Enable `new_search_ranking` feature flag with percentage rollout
4. Activate the new config: `UPDATE search_ranking_config SET active = true WHERE config_name = 'experiment_v1'`
5. Monitor quality metrics via `search_quality_report()` (when #190 is live)
6. Either graduate or roll back based on CTR/MRR delta

---

## Adding Search Support for a New Country

1. Add language to `language_ref` if not present
2. Add synonym pairs to `search_synonyms` (both directions)
3. Update `build_search_vector()` CASE statement if a new TSC is needed
4. Update `expand_search_query()` if language-specific logic is needed
5. Backfill `search_vector` for existing products: `UPDATE products SET search_vector = build_search_vector(...) WHERE country = 'XX'`
6. Verify with QA tests

---

## Dependencies

| Dependency           | Status    | Impact                            |
| -------------------- | --------- | --------------------------------- |
| #185 Performance     | ✅ Done    | Query monitoring for search RPCs  |
| #189 Scoring Engine  | ✅ Done    | `data_completeness_pct` signal    |
| #190 Event Analytics | ❌ Blocked | Search quality metrics (CTR, MRR) |
| #191 Feature Flags   | ✅ Done    | A/B testing ranking weights       |
| #182 Rate Limiting   | ❌ Open    | Search endpoint protection        |

---

## QA Coverage

23 SQL-based QA tests in `db/qa/QA__search_architecture.sql`:

- T01–T03: Ranking config integrity (active config, weight sum, key presence)
- T04–T06: `build_search_vector()` correctness (normal, NULL, DE)
- T07–T10: `search_rank()` behavior (positive return, exact > partial, category boost, completeness boost)
- T11–T13: German synonym pairs + expansion
- T14–T15: Feature flag existence and default state
- T16–T17: Quality report stub structure
- T18: `api_search_products()` structural validity
- T19: Partial unique index enforcement
- T20: All products have search_vector populated
- T21–T22: Security posture (anon revocation)
- T23: Trigger existence
