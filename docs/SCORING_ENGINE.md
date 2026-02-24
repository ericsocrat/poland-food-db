# Scoring Engine Architecture

> **Issue:** #189 — Canonical Scoring Engine  
> **Status:** Active  
> **Last updated:** 2026-02-25

---

## 1. Overview

The Canonical Scoring Engine is a versioned, auditable, multi-country scoring layer that centralises all health score computation. Every product's **Unhealthiness Score (1–100)** is now:

- **Versioned** — tracked against a model version registry
- **Auditable** — every score change logged with before/after values
- **Parameterised** — factor weights and ceilings are JSONB config, not hard-coded
- **Multi-country ready** — country-specific overrides without code duplication
- **Experimentable** — shadow scoring for A/B testing new models

---

## 2. Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                     SCORING ENGINE v2                             │
│                                                                   │
│  ┌────────────────┐  ┌────────────────┐  ┌─────────────────┐    │
│  │ Version         │  │ Country        │  │ Entry Points    │    │
│  │ Registry        │  │ Profiles       │  │                 │    │
│  │                 │  │                │  │ compute_score() │    │
│  │ v3.2 (active)   │  │ PL (baseline)  │  │ score_category()│    │
│  │ v4.0 (shadow)   │  │ DE (overrides) │  │ rescore_batch() │    │
│  │ v3.1 (retired)  │  │ CZ (overrides) │  │                 │    │
│  └───────┬────────┘  └───────┬────────┘  └────────┬────────┘    │
│          └──────────┬────────┘                     │             │
│                     ▼                              │             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  v3.2 fast path: compute_unhealthiness_v32()             │   │
│  │  vN+ config path: _compute_from_config(product, config)  │   │
│  └──────────────────────────┬───────────────────────────────┘   │
│                     ┌───────┼───────────────┐                    │
│                     ▼       ▼               ▼                    │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐         │
│  │ AUDIT LOG    │  │ SHADOW MODE  │  │ DISTRIBUTION   │         │
│  │ score_audit_ │  │ score_shadow │  │ _snapshots     │         │
│  │ log          │  │ _results     │  │                │         │
│  └──────────────┘  └──────────────┘  └───────────────┘         │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Database Objects

### Tables

| Table | Purpose | RLS |
|-------|---------|-----|
| `scoring_model_versions` | Version registry with JSONB config | service_role write, public read |
| `score_audit_log` | Immutable trail of every score change | service_role insert, authenticated read |
| `score_shadow_results` | Shadow scoring for A/B experiments | service_role all, authenticated read |
| `score_distribution_snapshots` | Daily distribution for drift detection | service_role all, authenticated read |

### Columns Added to `products`

| Column | Type | Purpose |
|--------|------|---------|
| `score_model_version` | `text DEFAULT 'v3.2'` | Which model produced the score |
| `scored_at` | `timestamptz DEFAULT now()` | When the score was last computed |

### Functions

| Function | Purpose | Access |
|----------|---------|--------|
| `compute_score(product_id, version?, country?, mode?)` | Canonical single-product scorer | authenticated + service_role |
| `rescore_batch(version?, country?, category?, mode?, batch_size?)` | Batch re-scoring | service_role |
| `validate_country_profile(version, country)` | Weight/ceiling validation | authenticated + service_role |
| `capture_score_distribution()` | Snapshot current distributions | service_role |
| `detect_score_drift(threshold_pct?)` | Compare today vs yesterday | service_role |
| `_compute_from_config(product_id, config)` | Config-driven scoring (future) | service_role |
| `_explain_from_config(product_id, config)` | Config-driven breakdown (future) | service_role |

### Admin RPCs

| RPC | Purpose |
|-----|---------|
| `admin_scoring_versions()` | List all versions with product counts |
| `admin_activate_scoring_version(version)` | Promote version to active (retires previous) |
| `admin_rescore_batch(version?, country?, category?, mode?, batch_size?)` | Safe rescore wrapper |
| `admin_score_drift_report(threshold_pct?)` | Drift analysis results |

### Public RPCs

| RPC | Purpose |
|-----|---------|
| `api_score_history(product_id, limit?)` | Score change audit trail for a product |

---

## 4. Scoring Model v3.2 Config

The active model's JSONB config mirrors `compute_unhealthiness_v32()`:

| # | Factor | Weight | Ceiling | Unit |
|---|--------|--------|---------|------|
| 1 | saturated_fat | 0.17 | 10.0 | g/100g |
| 2 | sugars | 0.17 | 27.0 | g/100g |
| 3 | salt | 0.17 | 3.0 | g/100g |
| 4 | calories | 0.10 | 600 | kcal/100g |
| 5 | trans_fat | 0.11 | 2.0 | g/100g |
| 6 | additives | 0.07 | 10 | count |
| 7 | prep_method | 0.08 | — | categorical |
| 8 | controversies | 0.08 | — | categorical |
| 9 | ingredient_concern | 0.05 | 100 | score |

**Weights sum to 1.00.** Clamped to `[1, 100]`.

---

## 5. Entry Points

### compute_score(product_id, version, country, mode)

**Modes:**
- `'apply'` — computes score, persists to products table, triggers audit
- `'dry_run'` — computes score, returns result without persisting
- `'shadow'` — computes score, writes to `score_shadow_results` only

**Returns:** JSONB with `product_id`, `score`, `previous_score`, `version`, `country`, `mode`, `breakdown`, `changed`.

**v3.2 fast path:** For v3.2, delegates directly to `compute_unhealthiness_v32()` — guaranteeing bit-perfect backward compatibility.

### score_category(category, data_completeness, country)

**Pipeline entry point.** Called by every pipeline's `04_scoring.sql`. Now also sets `score_model_version` and `scored_at` during batch scoring. The audit trigger captures all changes.

### rescore_batch(version, country, category, mode, batch_size)

**Batch re-scoring.** Iterates products matching filters, calls `compute_score()` per product. Returns summary with `total_processed`, `scores_changed`.

---

## 6. Audit Trail

Every `UPDATE` on `products.unhealthiness_score` fires the `score_change_audit` trigger, which inserts into `score_audit_log`:

| Column | Source |
|--------|--------|
| `product_id` | `NEW.product_id` |
| `field_name` | `'unhealthiness_score'` |
| `old_value` | `OLD.unhealthiness_score` |
| `new_value` | `NEW.unhealthiness_score` |
| `model_version` | `NEW.score_model_version` |
| `country` | `NEW.country` |
| `trigger_type` | `current_setting('app.score_trigger')` — set by the caller |

**Trigger types:**
- `'score_category'` — pipeline batch scoring
- `'compute_score'` — single-product ad-hoc scoring
- `'pipeline'` — fallback if no context set

---

## 7. Version Lifecycle

```
draft ───► active ───► retired
  │                      ▲
  └── shadow ────────────┘
```

- **draft**: Under development, cannot score production products
- **active**: Exactly one at any time (enforced by EXCLUDE constraint)
- **shadow**: Running in parallel for A/B comparison
- **retired**: Read-only archive

Use `admin_activate_scoring_version('v4.0')` to promote — it automatically retires the current active version.

---

## 8. Multi-Country Support

Country overrides are stored as JSONB on `scoring_model_versions.country_overrides`:

```json
{
  "DE": {
    "factor_overrides": [
      {"name": "sugars", "weight": 0.18, "ceiling": 22.0},
      {"name": "salt", "weight": 0.18, "ceiling": 2.0}
    ]
  }
}
```

When `compute_score(123, NULL, 'DE')` is called, the DE overrides merge over the base config.

Validate profiles with:
```sql
SELECT validate_country_profile('v3.2', 'DE');
-- Returns: { valid: true, total_weight: 1.0, factor_count: 9, ... }
```

---

## 9. Drift Detection

1. **Capture snapshots** (run daily):
   ```sql
   SELECT capture_score_distribution();
   ```

2. **Detect drift** (compare today vs yesterday):
   ```sql
   SELECT * FROM detect_score_drift(10.0);
   -- Returns: country, category, metric, prev_val, curr_val, drift_pct
   ```

3. **Admin report:**
   ```sql
   SELECT admin_score_drift_report(10.0);
   ```

---

## 10. Frontend Integration

The score explanation API (`api_score_explanation`) now includes:

| Field | Type | Example |
|-------|------|---------|
| `model_version` | `string \| null` | `"v3.2"` |
| `scored_at` | `string \| null` | `"2026-02-25T14:30:00Z"` |

The `ScoreBreakdownPanel` displays a model version badge and freshness timestamp when available.

---

## 11. Performance

| Operation | Target | Method |
|-----------|--------|--------|
| `score_category()` batch | <5s per category | Batch UPDATE (unchanged) |
| `compute_score()` single | <10ms | Direct function call |
| `rescore_batch()` 1000 products | <30s | Loop via compute_score |
| Audit trigger overhead | <1ms/row | Single INSERT, no cascading |

The v3.2 fast path ensures zero performance regression for pipeline scoring.

---

## 12. Security

- `compute_score()`, admin RPCs: `SECURITY DEFINER SET search_path = public`
- Audit log: INSERT-only for service_role, read-only for authenticated
- Version management: service_role only (admin RPCs)
- Shadow results: service_role write, authenticated read

---

## 13. QA Tests

17 QA SQL tests in `db/qa/QA__scoring_engine.sql`:

| Test | Validates |
|------|-----------|
| T01 | v3.2 is active |
| T02 | Single active version constraint |
| T03 | v3.2 config: 9 factors, weights sum to 1.0 |
| T04 | `score_model_version` populated for all scored products |
| T05 | `scored_at` populated for all scored products |
| T06 | Audit log table exists |
| T07–T08 | Core functions exist |
| T09 | Country profile validation works |
| T10–T11 | Shadow results and snapshots tables exist |
| T12 | `api_score_explanation` includes model_version and scored_at |
| T13 | `admin_scoring_versions` returns array |
| T14 | `api_score_history` returns correct shape |
| T15 | `detect_score_drift` is callable |
| T16 | Audit trigger is installed |
| T17 | Grants are correct |
