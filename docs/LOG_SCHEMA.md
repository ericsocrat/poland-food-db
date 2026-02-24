# Structured Log Schema & Error Taxonomy

> **Last updated:** 2026-03-04
> **Status:** Active
> **Owner issue:** [#210](https://github.com/ericsocrat/poland-food-db/issues/210)

---

## Overview

This document defines the structured log schema, error taxonomy, and severity
classification used across all workstreams. It extends the frontend structured
log format documented in [OBSERVABILITY.md](OBSERVABILITY.md) to cover backend
(pipeline, migration, scoring) and database-level operations.

**Relationship to OBSERVABILITY.md:** OBSERVABILITY.md defines the frontend/API
structured log format, Sentry integration, and health check endpoints.
LOG_SCHEMA.md defines the **error code taxonomy**, **severity escalation rules**,
**retention policy**, and **domain-specific logging requirements**.

---

## 1. Structured Log Schema

All logs — frontend, backend, and pipeline — MUST use JSON with these fields:

```json
{
  "timestamp": "2026-03-01T12:00:00.000Z",
  "level": "ERROR",
  "domain": "scoring",
  "action": "recompute_health_score",
  "message": "Division by zero in nutrient ratio calculation",
  "error_code": "SCORING_CALC_001",
  "product_id": 42,
  "country": "PL",
  "context": {
    "formula_version": "3.2",
    "nutrient": "fiber",
    "input_value": 0
  },
  "duration_ms": 45,
  "user_id": null,
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "trace-uuid-here"
}
```

### Required Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `timestamp` | ISO 8601 string | YES | When the event occurred |
| `level` | enum | YES | `DEBUG`, `INFO`, `WARN`, `ERROR`, `CRITICAL` |
| `domain` | enum | YES | One of the registered domains (see §3) |
| `action` | string | YES | What operation was being performed |
| `message` | string | YES | Human-readable description |

### Conditional Fields

| Field | Type | When Required | Description |
|---|---|---|---|
| `error_code` | string | If level ≥ ERROR | Unique error identifier (see §2) |
| `product_id` | bigint | If applicable | Which product was involved |
| `country` | string | If applicable | Which country context (PL, DE) |

### Optional Fields

| Field | Type | Description |
|---|---|---|
| `context` | object | Additional structured key-value data |
| `duration_ms` | integer | Operation duration in milliseconds |
| `user_id` | UUID | Which user triggered the operation |
| `request_id` | UUID | HTTP request correlation ID |
| `trace_id` | UUID | Distributed trace correlation ID |

---

## 2. Error Code Format & Registry

### Format

```
{DOMAIN}_{CATEGORY}_{NNN}
```

- **Domain:** SCORING, SEARCH, PROVENANCE, PIPELINE, MIGRATION, AUTH, FRONTEND, CONFIG
- **Category:** CALC, QUERY, CONFLICT, TIMEOUT, VALIDATION, IO, LOCK, TOKEN, INDEX, VERSION
- **NNN:** Three-digit sequential number within domain+category

### Error Code Registry (Starter Set)

Stored in the `error_code_registry` table for programmatic access.

| Code | Domain | Category | Severity | Description | Action |
|---|---|---|---|---|---|
| `SCORING_CALC_001` | scoring | calculation | ERROR | Division by zero in formula | Skip product, log, alert |
| `SCORING_CALC_002` | scoring | calculation | WARN | Negative score computed | Clamp to 1, log |
| `SCORING_VERSION_001` | scoring | version | ERROR | Product references non-existent scoring version | Default to active version |
| `SEARCH_QUERY_001` | search | query | WARN | Zero results returned for non-empty query | Log for analysis |
| `SEARCH_QUERY_002` | search | query | ERROR | Query exceeded timeout threshold (>2s) | Return partial results |
| `SEARCH_INDEX_001` | search | index | CRITICAL | tsvector or pg_trgm index missing/invalid | Alert immediately |
| `PROVENANCE_CONFLICT_001` | provenance | conflict | WARN | Two sources disagree on field value | Queue for resolution |
| `PROVENANCE_STALE_001` | provenance | freshness | INFO | Product data older than 90 days | Schedule re-check |
| `PIPELINE_IO_001` | pipeline | io | ERROR | OFF API unreachable | Retry with exponential backoff |
| `PIPELINE_IO_002` | pipeline | io | WARN | OFF API returned incomplete data | Log missing fields |
| `MIGRATION_LOCK_001` | migration | lock | CRITICAL | AccessExclusiveLock held >5s | Alert, prepare rollback |
| `AUTH_TOKEN_001` | auth | token | WARN | Expired JWT presented | Return 401 |
| `AUTH_RLS_001` | auth | access | ERROR | RLS policy violation / unauthorized access | Log, return 403 |

### Adding New Error Codes

1. Insert into `error_code_registry` table via migration
2. Follow the `{DOMAIN}_{CATEGORY}_{NNN}` format
3. Document the expected action (what the system should do)
4. Assign appropriate severity (see §4)

---

## 3. Domains

| Domain | Code Prefix | Description | Examples |
|---|---|---|---|
| `scoring` | `SCORING_` | Unhealthiness score computation, formula versioning | Score calculation, drift detection |
| `search` | `SEARCH_` | Product search, autocomplete, ranking | Query execution, index management |
| `provenance` | `PROVENANCE_` | Data source tracking, freshness, conflicts | Source updates, staleness checks |
| `pipeline` | `PIPELINE_` | OFF API data ingestion, SQL generation | API calls, data validation |
| `migration` | `MIGRATION_` | Schema migrations, backfills | Lock acquisition, rollback |
| `auth` | `AUTH_` | Authentication, authorization, RLS | JWT validation, role checks |
| `frontend` | `FRONTEND_` | Client-side errors, rendering failures | Component errors, API call failures |
| `config` | `CONFIG_` | Feature flags, environment configuration | Flag evaluation, config loading |

---

## 4. Severity Levels & Escalation

Stored in the `log_level_ref` table for programmatic access.

| Level | Numeric | When to Use | Escalation | Example |
|---|---|---|---|---|
| `DEBUG` | 0 | Development tracing | None | "Entered scoring calculation for product 42" |
| `INFO` | 1 | Normal operations | None | "Backfill completed: 1000 rows processed" |
| `WARN` | 2 | Unexpected but recoverable | Dashboard amber indicator | "Scoring produced value < 1, clamped to 1" |
| `ERROR` | 3 | Operation failed, system continues | Alert (Slack/email) within 15min | "Query timeout on search — returned partial results" |
| `CRITICAL` | 4 | System-wide impact, immediate action | Page on-call within 5min | "tsvector index missing, search fully degraded" |

### Escalation Rules

```
CRITICAL → Page on-call via PagerDuty/OpsGenie within 5min
           Bridge call opened if not acknowledged in 15min

ERROR    → Slack #alerts channel within 15min
           If >5 ERRORs in 1h from same domain → escalate to CRITICAL

WARN     → Dashboard indicator (amber dot)
           If >50 WARNs in 1h from same domain → escalate to ERROR

INFO     → Dashboard log viewer only
           No escalation

DEBUG    → Local dev console only
           Never stored in production
```

---

## 5. Log Retention Policy

| Level | Retention | Storage Tier | Notes |
|---|---|---|---|
| `DEBUG` | 0 days (production) | Not stored in prod | Development/local only |
| `INFO` | 30 days | Standard (Vercel Logs) | Auto-pruned after 30d |
| `WARN` | 90 days | Standard | Queryable for trend analysis |
| `ERROR` | 365 days | Standard + backup | Required for annual audit |
| `CRITICAL` | Indefinite | Standard + cold backup | Preserved for post-mortems |

### Storage Guidelines

- **Vercel Logs** (frontend/API): captured via stdout JSON, 30-day default
- **Supabase Logs** (database): `pg_stat_statements`, audit logs
- **Pipeline Logs** (Python): written to `pipeline/logs/` locally; CI artifacts preserved 90 days
- **Sentry** (errors): retained per Sentry plan (90 days default)

---

## 6. Domain-Specific Log Conventions

Each domain must log at minimum:

| Domain | INFO Events | ERROR Events |
|---|---|---|
| **Scoring** | Score computed (product_id, version, result, duration_ms) | Calculation failure, version mismatch |
| **Search** | Query executed (query, result_count, duration_ms) | Timeout, index failure |
| **Provenance** | Source update (product_id, field, old_source, new_source) | Conflict detected |
| **Pipeline** | Product imported (ean, source, category) | Import failure, API error |
| **Migration** | Migration started/completed (name, duration_ms) | Lock timeout, rollback |
| **Auth** | Login success (user_id, method) | Token expired, RLS violation |
| **Frontend** | Page loaded (route, duration_ms) | Component render failure |
| **Config** | Flag evaluated (flag_key, result) | Flag config invalid |

---

## 7. Database Schema

### Tables

Two reference tables support programmatic access to the taxonomy:

```sql
-- log_level_ref: severity level definitions
CREATE TABLE log_level_ref (
    level      text PRIMARY KEY,      -- DEBUG, INFO, WARN, ERROR, CRITICAL
    numeric_level integer NOT NULL UNIQUE,
    description text NOT NULL,
    retention_days integer,           -- NULL = indefinite
    escalation_target text            -- NULL, 'dashboard', 'slack', 'pager'
);

-- error_code_registry: all known error codes
CREATE TABLE error_code_registry (
    error_code  text PRIMARY KEY,     -- e.g., SCORING_CALC_001
    domain      text NOT NULL,
    category    text NOT NULL,
    severity    text NOT NULL REFERENCES log_level_ref(level),
    description text NOT NULL,
    action      text NOT NULL,        -- What the system should do
    created_at  timestamptz NOT NULL DEFAULT now()
);
```

### Validation Function

```sql
-- validate_log_entry(jsonb) → jsonb
-- Returns { valid: true } or { valid: false, errors: [...] }
SELECT validate_log_entry('{
    "timestamp": "2026-03-01T12:00:00Z",
    "level": "ERROR",
    "domain": "scoring",
    "action": "compute_score",
    "message": "Test"
}'::jsonb);
```

---

## 8. Integration with Existing Infrastructure

| System | Integration Point |
|---|---|
| **OBSERVABILITY.md** (frontend logs) | Shares severity levels; LOG_SCHEMA.md adds error codes and domain taxonomy |
| **Sentry** | ERROR/CRITICAL → captured as Sentry events with `error_code` tag |
| **Dashboard** | WARN → amber indicator; ERROR/CRITICAL → red with count badge |
| **INCIDENT_RESPONSE.md** | CRITICAL → triggers incident workflow defined in playbook |
| **DRIFT_DETECTION.md** | Drift check failures → logged as WARN with `CONFIG_DRIFT_001` |

---

## Related Documents

- [OBSERVABILITY.md](OBSERVABILITY.md) — Frontend structured log format, Sentry integration
- [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md) — Incident escalation playbook
- [MONITORING.md](MONITORING.md) — Runtime health checks and dashboards
- [METRICS.md](METRICS.md) — Application and infrastructure metrics catalog
