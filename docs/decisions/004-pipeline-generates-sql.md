# ADR-004: Pipeline Architecture — Python Generates SQL, Never Writes Directly

> **Date:** 2026-02-07 (retroactive — original pipeline design)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The project imports food product data from Open Food Facts (OFF) API into PostgreSQL. Three pipeline approaches were considered:

1. **Direct DB writes from Python** (using psycopg2/SQLAlchemy) — fast to implement but SQL is invisible, not version-controlled, and not reproducible.
2. **ETL tool** (dbt, Airflow, Dagster) — powerful but heavy dependency for a relatively simple pipeline. Adds operational complexity.
3. **Python generates SQL files, executed separately via psql** — SQL is version-controlled, reviewable, and idempotent. Python handles only API calls and data transformation.

## Decision

The pipeline follows a **generate-then-execute** architecture:

```
OFF API → Python (pipeline/) → SQL files (db/pipelines/) → psql → PostgreSQL
```

- `pipeline/run.py` fetches data from OFF API, validates it, and calls `sql_generator.py`
- `sql_generator.py` writes 4–5 SQL files per category into `db/pipelines/{category}/`
- SQL files are committed to Git and executed via `psql` (locally or in CI)
- Python **never** connects to the database directly

File naming follows strict convention:
```
PIPELINE__{category}__01_insert_products.sql
PIPELINE__{category}__03_add_nutrition.sql
PIPELINE__{category}__04_scoring.sql
PIPELINE__{category}__05_source_provenance.sql
```

## Consequences

### Positive

- **Full auditability** — every data change is a reviewable SQL file in Git
- **Reproducibility** — `supabase db reset` + execute all pipeline SQL = exact same database state
- **Idempotency** — all SQL uses `ON CONFLICT DO UPDATE`, safe to re-run
- **Separation of concerns** — Python handles API interaction, SQL handles data operations
- **CI-friendly** — `check_pipeline_structure.py` validates folder/file structure in CI

### Negative

- **Two-step workflow** — must run Python, then execute SQL (automated via `RUN_LOCAL.ps1`)
- **Large file counts** — 21 categories × 4–5 files = ~90 SQL files to manage
- **SQL generation complexity** — `sql_generator.py` must produce correct, idempotent SQL for all edge cases

### Neutral

- Each category gets its own folder under `db/pipelines/`
- Execution order matters: products (01) → nutrition (03) → scoring (04) → provenance (05)
- `RUN_LOCAL.ps1` automates the full pipeline-then-execute-then-QA workflow
