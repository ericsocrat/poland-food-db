# Drift Detection Automation

> **Issue:** #199 — GOV-A4: Version Drift Detection Automation
> **Last updated:** 2026-03-01
> **Status:** Active — automated detection, manual remediation

---

## 1. Overview

Drift detection prevents silent architectural inconsistency. When code changes
without updating registries, documentation, or naming conventions, the system
accumulates "drift" — small mismatches that erode trust and cause hard-to-diagnose
failures.

This system provides **automated detection** at three levels:

| Level                   | Tool                               | Frequency    |
| ----------------------- | ---------------------------------- | ------------ |
| SQL runtime checks      | `governance_drift_check()`         | Every QA run |
| Documentation freshness | `scripts/check_doc_drift.py`       | Weekly / CI  |
| Migration ordering      | `scripts/check_migration_order.py` | Every commit |

---

## 2. Drift Check Catalog

### 2.1 SQL Checks (`governance_drift_check()`)

8 automated checks, each returning `pass` or `drift`:

| #   | Check Name                  | Severity | What It Detects                                      | Delegates To                    |
| --- | --------------------------- | -------- | ---------------------------------------------------- | ------------------------------- |
| 1   | `formula_weight_drift`      | critical | Active formula weights ≠ stored fingerprint          | `check_formula_drift()`         |
| 2   | `function_source_drift`     | critical | Function body modified without updating registry     | `check_function_source_drift()` |
| 3   | `scoring_version_count`     | critical | Multiple active scoring versions                     | Direct query                    |
| 4   | `search_config_count`       | critical | Multiple active search ranking configs               | Direct query                    |
| 5   | `scoring_function_exists`   | critical | `compute_unhealthiness_v32` missing from pg_proc     | Direct query                    |
| 6   | `trigger_naming_convention` | medium   | Products table triggers not following naming pattern | `pg_trigger` regex              |
| 7   | `stale_feature_flags`       | medium   | Expired feature flags still enabled                  | Direct query                    |
| 8   | `source_hashes_populated`   | medium   | `formula_source_hashes` table is empty               | Direct query                    |

**Running manually:**

```sql
SELECT * FROM governance_drift_check();
```

**Persisting results:**

```sql
SELECT log_drift_check();  -- Returns run_id UUID
```

**Querying history:**

```sql
SELECT * FROM drift_check_results
WHERE checked_at > now() - interval '30 days'
ORDER BY checked_at DESC;
```

### 2.2 Documentation Freshness (`check_doc_drift.py`)

Scans `docs/` directory and flags `.md` files not updated within a threshold.

```bash
python scripts/check_doc_drift.py              # Default 90-day threshold
python scripts/check_doc_drift.py --max-age 60 # Stricter threshold
python scripts/check_doc_drift.py --warn-only  # Non-blocking mode
```

### 2.3 Migration Ordering (`check_migration_order.py`)

Validates that all migration files have:
- Valid `YYYYMMDDHHMMSS_description.sql` naming
- Monotonically increasing timestamps (no duplicates, no out-of-order)
- Meaningful descriptions (≥ 3 characters)

```bash
python scripts/check_migration_order.py
```

---

## 3. Severity Levels & Response

| Severity     | Response Time    | Action                                           |
| ------------ | ---------------- | ------------------------------------------------ |
| **critical** | Immediate        | Block deployment. Fix before merging any PR.     |
| **medium**   | Next sprint      | Create remediation issue. Document in drift log. |
| **low**      | Quarterly review | Track for pattern analysis. No immediate action. |

**Escalation:** If a critical drift persists for > 24h, escalate per
`docs/INCIDENT_RESPONSE.md` severity definitions.

---

## 4. Trigger Naming Convention

All user-defined triggers on the `products` table must follow one of:

| Pattern                   | Example                             | Use Case          |
| ------------------------- | ----------------------------------- | ----------------- |
| `trg_products_{purpose}`  | `trg_products_search_vector_update` | Standard triggers |
| `products_{NN}_{purpose}` | `products_30_change_audit`          | Ordered execution |

Non-conforming triggers are flagged by check #6. Internal triggers
(`tgisinternal = true`) are excluded from validation.

---

## 5. CI Integration Plan

### Current State (Manual)

Drift checks run as part of `RUN_QA.ps1` via `QA__governance_drift.sql`.
Documentation and migration checks run manually.

### Target State (Automated)

```yaml
# .github/workflows/governance-drift.yml (planned)
name: Governance Drift Check
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am UTC
  workflow_dispatch: {}
  pull_request:
    paths:
      - 'supabase/migrations/**'
      - 'db/**'
      - 'docs/**'

jobs:
  drift-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }  # Full history for git log dates

      - name: Check document freshness
        run: python scripts/check_doc_drift.py --warn-only

      - name: Check migration ordering
        run: python scripts/check_migration_order.py

      # SQL drift checks run via existing qa.yml against Supabase
```

**Deployment timeline:** Activate once the governance workflow backlog clears
(target: after all GOV-* issues complete).

---

## 6. Monthly Cadence (Until CI Automated)

| Week       | Action                                                        | Owner      |
| ---------- | ------------------------------------------------------------- | ---------- |
| 1st Monday | Run `governance_drift_check()` via Supabase Studio SQL Editor | Maintainer |
| 1st Monday | Run `python scripts/check_doc_drift.py` locally               | Maintainer |
| 1st Monday | Run `python scripts/check_migration_order.py` locally         | Maintainer |
| 1st Monday | Review `drift_check_results` table for trends                 | Maintainer |

**Log results:** Use `SELECT log_drift_check();` to persist each run for trending.

---

## 7. Historical Results

The `drift_check_results` table stores all past drift check runs:

| Column       | Type        | Purpose                                             |
| ------------ | ----------- | --------------------------------------------------- |
| `id`         | bigint      | Auto-incrementing PK                                |
| `run_id`     | uuid        | Groups all checks from one `log_drift_check()` call |
| `check_name` | text        | Which check                                         |
| `severity`   | text        | critical / medium / low                             |
| `status`     | text        | pass / drift / skip                                 |
| `detail`     | text        | Human-readable description                          |
| `checked_at` | timestamptz | When the check ran                                  |

**Retention:** No automatic purging. Review quarterly for cleanup.

---

## 8. Adding New Drift Checks

To add a new check to `governance_drift_check()`:

1. Add a new `RETURN QUERY SELECT ...` block in the function body
2. Update the catalog table in this document (§2.1)
3. Update the header comment in the migration with the new count
4. Add/update QA check in `db/qa/QA__governance_drift.sql`
5. Update `copilot-instructions.md` if total QA check count changes

**Template:**

```sql
-- ── Check N: {name} ─────────────────────────────────────
RETURN QUERY
SELECT '{check_name}'::text,
       '{severity}'::text,
       CASE WHEN {condition} THEN 'drift' ELSE 'pass' END,
       '{human-readable detail}'::text;
```
