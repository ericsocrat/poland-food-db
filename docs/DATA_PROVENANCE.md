# Data Provenance & Freshness Governance

> **Issue:** #193 · **Priority:** P1-High · **Labels:** architecture, database, multi-country

## Overview

Complete data provenance and freshness governance framework providing field-level
source tracking, staleness detection, conflict resolution, audit trail, and
country-specific data policies.

**Purpose:** Transform Poland Food DB from a "food database" into a "trusted
health intelligence platform" where every data point is traceable, auditable,
and governed by freshness policies.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PROVENANCE LAYER                          │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │ DATA SOURCES    │  │ FRESHNESS       │  │ CONFLICT      │  │
│  │ Registry        │  │ ENGINE          │  │ RESOLVER      │  │
│  │ 11 sources      │  │ Staleness decay │  │ Priority rules│  │
│  │ base_confidence │  │ Country cadence │  │ Auto-resolve  │  │
│  └────────┬───────┘  └────────┬───────┘  └──────┬───────┘  │
│           │                    │                   │          │
│  ┌────────▼────────────────────▼───────────────────▼───────┐ │
│  │           AUDIT TRAIL (product_change_log)               │ │
│  │   Every field change → who, when, what, why, old/new     │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │         COUNTRY POLICY ENGINE                             │ │
│  │   Per-country: source priorities, regulatory framework,   │ │
│  │   allergen strictness, refresh cadence, publish gates     │ │
│  └──────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Source Registry

| source_key              | Display Name           | Type      | Confidence | Countries      |
| ----------------------- | ---------------------- | --------- | ---------- | -------------- |
| `off_api`               | Open Food Facts API    | api       | 0.60       | PL, DE, CZ, UK |
| `off_search`            | OFF Search             | api       | 0.55       | PL, DE, CZ, UK |
| `manual`                | Manual Research        | manual    | 0.85       | PL             |
| `label_scan`            | Package / Label Scan   | manual    | 0.95       | PL, DE, CZ, UK |
| `retailer_api`          | Retailer API (generic) | retailer  | 0.80       | PL             |
| `retailer_biedronka`    | Biedronka API          | retailer  | 0.80       | PL             |
| `retailer_zabka`        | Żabka API              | retailer  | 0.80       | PL             |
| `user_contribution`     | User Contribution      | community | 0.40       | PL, DE, CZ, UK |
| `official_manufacturer` | Manufacturer Data      | official  | 0.90       | PL, DE, CZ, UK |
| `lab_test`              | Laboratory Test        | official  | 1.00       | PL, DE, CZ, UK |
| `derived_calculation`   | Derived / Calculated   | derived   | 0.70       | PL, DE, CZ, UK |

---

## Field-Level Provenance

Built on the existing `product_field_provenance` table, enhanced with:

| Column        | Type         | Purpose                         |
| ------------- | ------------ | ------------------------------- |
| `confidence`  | NUMERIC(3,2) | Source confidence (0–1)         |
| `verified_at` | TIMESTAMPTZ  | When manually verified          |
| `verified_by` | UUID         | Who verified (null = automated) |
| `notes`       | TEXT         | Additional context              |

### Recording Provenance

```sql
-- Single field
SELECT record_field_provenance(
    p_product_id := 42,
    p_field_name := 'calories_100g',
    p_source_key := 'label_scan',
    p_confidence := 0.95,
    p_notes      := 'Scanned from package in Biedronka Kraków'
);

-- Bulk (pipeline import)
SELECT record_bulk_provenance(
    p_product_id := 42,
    p_source_key := 'off_api',
    p_fields     := ARRAY['product_name', 'brand', 'calories_100g', 'sugars_100g'],
    p_notes      := 'Pipeline import: dairy'
);
```

---

## Freshness Policies

Per-country, per-field-group staleness thresholds:

| Country | Field Group | Warning  | Critical | Max Age  | Strategy      |
| ------- | ----------- | -------- | -------- | -------- | ------------- |
| PL      | nutrition   | 120 days | 150 days | 180 days | auto_api      |
| PL      | allergens   | 60 days  | 75 days  | 90 days  | manual_review |
| PL      | scoring     | 20 days  | 25 days  | 30 days  | auto_api      |
| DE      | nutrition   | 80 days  | 100 days | 120 days | auto_api      |
| DE      | allergens   | 40 days  | 50 days  | 60 days  | manual_review |

### Staleness Detection

```sql
SELECT * FROM detect_stale_products('PL', 'warning', 50);
-- Returns: product_id, product_name, stale_fields (JSONB), max_staleness_days,
--          staleness_severity, recommended_action
```

---

## Conflict Resolution

When sources disagree beyond tolerance:

1. **Detection** — `detect_conflict()` checks new values against existing data
2. **Logging** — Conflicts recorded in `data_conflicts` with severity
3. **Auto-resolve** — `resolve_conflicts_auto()` uses source priority rules
4. **Manual resolution** — Allergen conflicts (critical) always require human review

### Severity Mapping

| Field Group   | Conflict Severity |
| ------------- | ----------------- |
| `allergens`   | **critical**      |
| `nutrition`   | high              |
| `ingredients` | medium            |
| all others    | low               |

---

## Composite Confidence

`compute_provenance_confidence(product_id)` returns:

| Field                  | Description                                      |
| ---------------------- | ------------------------------------------------ |
| `overall_confidence`   | Weighted average (source confidence × freshness) |
| `staleness_risk`       | fresh / aging / stale / expired                  |
| `data_completeness`    | % of 15 tracked fields with provenance           |
| `source_diversity`     | Count of distinct sources                        |
| `weakest_field`        | Field with lowest effective confidence           |
| `confidence_breakdown` | Per-field: source, base, penalty, effective conf |

### Freshness Decay Model

```
effective_confidence = base_confidence × freshness_penalty

freshness_penalty:
  ≤ warning_age_days  → 1.0  (no penalty)
  ≤ critical_age_days → 0.8
  ≤ max_age_days      → 0.5
  > max_age_days      → 0.2  (expired, minimal confidence)
```

---

## Country Data Policies

| Country | Regulatory Framework | Allergen Strictness | Active |
| ------- | -------------------- | ------------------- | ------ |
| PL      | EU FIC 1169/2011     | standard            | ✓      |
| DE      | EU FIC 1169/2011     | strict              | ✗      |
| CZ      | EU FIC 1169/2011     | standard            | ✗      |
| UK      | UK FIR               | strict              | ✗      |

### Product Country Validation

```sql
SELECT validate_product_for_country(42, 'DE');
-- Returns: ready_for_publish, issues[], overall_confidence, staleness_risk
```

Checks: minimum confidence threshold, local language name, allergen data
(strict countries), data freshness.

---

## API Endpoints

### Public

| RPC                                  | Auth   | Description                       |
| ------------------------------------ | ------ | --------------------------------- |
| `api_product_provenance(product_id)` | Public | Trust score, sources, explanation |

### Admin / Service

| RPC                                                 | Auth    | Description                    |
| --------------------------------------------------- | ------- | ------------------------------ |
| `admin_provenance_dashboard(country)`               | Admin   | Health overview per country    |
| `detect_stale_products(country, severity, limit)`   | Admin   | Staleness report               |
| `resolve_conflicts_auto(country, max_severity)`     | Service | Auto-resolve conflicts         |
| `validate_product_for_country(product_id, country)` | Admin   | Country readiness check        |
| `record_field_provenance(...)`                      | Service | Record single field provenance |
| `record_bulk_provenance(...)`                       | Service | Record batch provenance        |
| `compute_provenance_confidence(product_id)`         | Service | Composite confidence score     |
| `detect_conflict(...)`                              | Service | Check for data conflicts       |

---

## Audit Trail

The `product_change_log` table captures every tracked field change:

- **Tracked fields** (25): product_name, brand, category, all nutrition fields,
  allergens, additives, scores, confidence, etc.
- **Actor types**: pipeline, manual, user, system, conflict_resolution
- **Automatic** via `products_30_change_audit` trigger (AFTER UPDATE)
- **Immutable** — RLS restricts to service_role only

---

## Feature Flag

`data_provenance_ui` — disabled by default, 6-month expiry.
Gates trust badge and field source attribution in the UI.

---

## Database Objects

### New Tables (6)

| Table                       | Rows Est.   | RLS |
| --------------------------- | ----------- | --- |
| `data_sources`              | ~11         | ✓   |
| `product_change_log`        | ~500K/month | ✓   |
| `freshness_policies`        | ~12         | ✓   |
| `conflict_resolution_rules` | ~6          | ✓   |
| `data_conflicts`            | ~1K         | ✓   |
| `country_data_policies`     | ~4          | ✓   |

### Enhanced Table

| Table                      | Change                                          |
| -------------------------- | ----------------------------------------------- |
| `product_field_provenance` | +confidence, +verified_at, +verified_by, +notes |

### New Functions (10)

`field_to_group`, `record_field_provenance`, `record_bulk_provenance`,
`detect_stale_products`, `detect_conflict`, `resolve_conflicts_auto`,
`compute_provenance_confidence`, `validate_product_for_country`,
`api_product_provenance`, `admin_provenance_dashboard`

### New Trigger

`products_30_change_audit` → `trg_product_change_log()`

---

## QA Coverage

25 tests in `db/qa/QA__data_provenance.sql`:

- T01–T03: Data source registry integrity
- T04: Enhanced provenance columns
- T05–T06: Provenance recording (single + bulk)
- T07: field_to_group mapping
- T08–T09: Audit trail structure + trigger
- T10–T11: Freshness policies (seeding, allergen strictness)
- T12–T13: Conflict rules (seeding, allergen non-auto-resolve)
- T14: data_conflicts table
- T15–T16: Country policies (seeding, DE strictness)
- T17: Composite confidence structure
- T18: Country validation structure
- T19–T20: API responses (product provenance, admin dashboard)
- T21: Feature flag
- T22–T23: Security (anon blocked from admin, allowed on public API)
- T24: RLS on all tables
- T25: detect_stale_products exists

---

## Security

- Internal functions: REVOKE from PUBLIC + anon, GRANT to authenticated + service_role
- Admin functions: service_role only
- Public API (`api_product_provenance`): returns display_name only (not source_key)
- Audit trail: immutable, service_role-only access
- Conflict resolution: only service_role can auto-resolve
- All tables: RLS enabled + forced
