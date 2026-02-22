# Poland Food DB — Performance & Scale Readiness Report

> **Generated:** 2026-02-10
> **Database:** PostgreSQL 17 (Supabase Docker)
> **Dataset:** 1,025 active products, 20 categories, 12,892 product-ingredient links

---

## 1. Current Performance Baseline

All benchmarks taken on a local Supabase Docker instance with warm caches.

### Query Latencies

| Operation                                      | Execution Time | Buffer Hits | Notes                                                  |
| ---------------------------------------------- | -------------- | ----------- | ------------------------------------------------------ |
| `v_master` (category filter + sort + limit 10) | **4.5ms**      | 569         | Uses `products_category_idx` bitmap scan               |
| `api_product_detail(id)`                       | **~5ms**       | ~500        | Single-product JSONB assembly                          |
| `api_better_alternatives(id, true, 5)`         | **6.3ms**      | 1,771       | Includes `find_similar_products` Jaccard join          |
| `find_similar_products(id, 5)`                 | **6.6ms**      | ~800        | Jaccard coefficient via `product_ingredient` self-join |
| `api_score_explanation(id)`                    | **7.5ms**      | 1,500       | Score computation + category context                   |
| `api_search_products('cola')`                  | **7.8ms**      | 422         | pg_trgm GIN index scan                                 |
| `api_category_listing(cat, sort, dir, 28, 0)`  | **~5ms**       | ~600        | Full category scan with sort                           |
| `v_product_confidence` (indexed lookup)        | **0.025ms**    | 3           | Materialized view with btree index                     |
| `compute_data_confidence(id)`                  | **~3ms**       | ~200        | Per-product confidence computation                     |
| `v_api_category_overview`                      | **~2ms**       | ~100        | 20-row view from pre-indexed data                      |

### Materialized View Refresh Times

| View                      | Refresh Time | Row Count | Strategy                          |
| ------------------------- | ------------ | --------- | --------------------------------- |
| `mv_ingredient_frequency` | **27ms**     | 1,471     | Full refresh (no unique index)    |
| `v_product_confidence`    | **31ms**     | 1,025     | `CONCURRENTLY` (has unique index) |

**Verdict:** All queries <10ms. MV refreshes <50ms. No performance issues at current scale.

---

## 2. Index Inventory (40 indexes)

### Coverage Assessment

| Table                     | Indexes                                                                  | Assessment     |
| ------------------------- | ------------------------------------------------------------------------ | -------------- |
| `products`                | 7 (PK, category, active, EAN, country+brand+name, name_trgm, brand_trgm) | ✅ Well-covered |
| `product_ingredient`      | 4 (PK, product FK, ingredient FK, sub-ingredient FK)                     | ✅ Complete     |
| `ingredient_ref`          | 5 (PK, taxonomy_id, name, additive, concern)                             | ✅ Complete     |
| `nutrition_facts`         | 1 (PK only)                                                              | ⚠️ Note below   |
| `product_allergen_info`   | 2 (product+type, tag+type)                                               | ✅ Sufficient   |
| `v_product_confidence`    | 2 (product_id unique, band+score)                                        | ✅ Complete     |
| `mv_ingredient_frequency` | 3 (ingredient_id unique, count, concern)                                 | ✅ Complete     |

### Observations

1. **`nutrition_facts`** has only a PK index. At 1,032 rows this is fine — seq scans are <1ms. An index on `(product_id)` would be redundant since the PK already provides this.

2. **No missing indexes identified.** All JOIN paths used in `v_master`, API functions, and QA checks hit indexed columns.

3. **No unused indexes detected.** At 1,025 products, all indexes are small and maintenance overhead is negligible.

---

## 3. Scale Projections

### Growth Scenarios

| Metric                       | Current | 5K Products | 50K Products | Notes                          |
| ---------------------------- | ------- | ----------- | ------------ | ------------------------------ |
| `v_master` category query    | 4.5ms   | ~20ms       | ~100ms       | Linear with category size      |
| `find_similar_products`      | 6.6ms   | ~150ms      | ~3s          | O(n²) Jaccard — **bottleneck** |
| `api_search_products`        | 7.8ms   | ~15ms       | ~50ms        | pg_trgm GIN scales well        |
| MV refresh (confidence)      | 31ms    | ~300ms      | ~3s          | Linear                         |
| MV refresh (ingredient freq) | 27ms    | ~200ms      | ~2s          | Linear                         |
| Total index storage          | ~2MB    | ~20MB       | ~200MB       | Linear                         |

### Identified Bottleneck: `find_similar_products`

The Jaccard similarity computation self-joins `product_ingredient` (~13 rows/product average). At 50K products:
- Self-join produces ~13 × 650K = 8.5M comparisons per call
- **Mitigation:** Pre-filter by category before Jaccard (already done when `p_same_category = true`)
- **Future fix:** Pre-compute pairwise similarity as a materialized view for hot categories

---

## 4. Scale Readiness Checklist

### ✅ Already Done
- [x] Indexes on all JOIN columns and WHERE predicates
- [x] pg_trgm GIN indexes for text search
- [x] Materialized views for expensive aggregations
- [x] `CONCURRENTLY` refresh support on `v_product_confidence`
- [x] Category-scoped queries in all API functions
- [x] Pagination on all listing endpoints
- [x] No N+1 query patterns in views

### 🟡 Recommended at 5K+ Products
- [x] Add `CONCURRENTLY` support to `mv_ingredient_frequency` (unique index: `idx_mv_ingredient_freq_id`)
- [x] Set up periodic MV refresh — `api_refresh_mvs()` RPC (service_role only), recommended every 15 min or after pipeline runs
- [x] Add `statement_timeout` to PostgREST config — 5s for API roles, 30s for MV refresh functions

### 🔴 Required at 50K+ Products
- [x] Pre-compute similarity matrix as materialized view — `mv_product_similarity` (Jaccard, same-category pairs)
- [ ] Partition `product_ingredient` by category
- [x] Add connection pooling (PgBouncer) — enabled in `config.toml` (transaction mode, pool_size=20)
- [ ] Consider read replicas for API traffic
- [ ] Move `v_master` to materialized view with refresh trigger

---

## 5. MV Refresh Strategy

### Current State
| View                      | Has Unique Index                    | Supports CONCURRENTLY | Refresh Frequency                      |
| ------------------------- | ----------------------------------- | --------------------- | -------------------------------------- |
| `mv_ingredient_frequency` | ✅ `idx_mv_ingredient_freq_id`       | ✅ Yes                 | After ingredient data changes          |
| `v_product_confidence`    | ✅ `idx_product_confidence_id`       | ✅ Yes                 | After scoring/nutrition/source updates |
| `mv_product_similarity`   | ✅ `mv_product_similarity_pair_uniq` | ✅ Yes                 | After product/ingredient changes       |

### Recommended Refresh Policy
```
After pipeline run (RUN_LOCAL.ps1):
  1. REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
  2. REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
  3. REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_similarity;

Estimated combined refresh time at current scale: ~100ms
```

---

## 6. Safe vs Expensive Query Patterns

### Safe (use freely in frontend)
| Pattern                                 | Why Safe                          |
| --------------------------------------- | --------------------------------- |
| `v_api_category_overview`               | 20 rows, view over indexed tables |
| `api_product_detail(id)`                | Single-row lookup, all indexed    |
| `api_data_confidence(id)`               | Single-row function               |
| `v_product_confidence` (any filter)     | Materialized, indexed             |
| `api_category_listing(..., limit ≤ 50)` | Paged, indexed                    |
| `api_search_products(query)`            | GIN index, returns max ~20        |

### Moderate (cache 60s)
| Pattern                                 | Why Moderate                      |
| --------------------------------------- | --------------------------------- |
| `api_score_explanation(id)`             | Computes score + category context |
| `api_category_listing(..., limit > 50)` | Larger result sets                |

### Expensive (cache 300s or pre-compute)
| Pattern                        | Why Expensive                    | Mitigation                           |
| ------------------------------ | -------------------------------- | ------------------------------------ |
| `api_better_alternatives(id)`  | Self-join for Jaccard similarity | Cache result, limit 5                |
| `find_similar_products(id, n)` | O(n²) ingredient comparison      | Always pass `p_same_category = true` |
| `REFRESH MATERIALIZED VIEW`    | Full table scan                  | Run during maintenance window        |

---

## 7. Guardrails Migration

The following guardrails are applied via migration `20260210003000_performance_guardrails.sql`:

1. **`statement_timeout`** on API role (5s) — prevents runaway queries
2. **Unique index on `mv_ingredient_frequency`** — enables `REFRESH CONCURRENTLY`
3. **`refresh_all_materialized_views()`** function — single call to refresh all MVs
4. **Helper function** to check MV staleness
