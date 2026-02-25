# ADR-006: Append-Only Migration Strategy

> **Date:** 2026-02-07 (retroactive — enforced since first migration)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

Database schema evolution can be managed in two ways:

1. **Mutable migrations** — edit existing migration files to fix issues, squash migrations periodically. Simpler history but loses auditability. Risk of divergence between environments if a migration has already been applied.
2. **Append-only migrations** — never modify an existing migration file. Fixes and changes always go in a new file. Preserves full history and ensures deterministic replay.

Supabase CLI's migration system applies migrations in timestamp order and records which have been applied. Modifying an already-applied migration would cause checksum mismatches and deployment failures.

## Decision

All migrations in `supabase/migrations/` are **strictly append-only**:

- **Never modify** an existing migration file (even to fix a typo)
- **Never delete** a migration file
- **Never change** a migration's timestamp
- Fixes go in a **new migration** with the next timestamp
- Each migration uses idempotent patterns: `IF NOT EXISTS`, `CREATE OR REPLACE`, `ADD COLUMN IF NOT EXISTS`
- Every migration includes a rollback comment: `-- To roll back: DROP TABLE/COLUMN IF EXISTS ...`

Currently **137 migrations** spanning 2026-02-07 to 2026-02-15.

## Consequences

### Positive

- **Deterministic replay** — `supabase db reset` always produces the same schema
- **Environment safety** — no risk of checksum mismatch between local, staging, and production
- **Full audit trail** — every schema change is traceable to a specific timestamp and commit
- **CI-validatable** — `check_migration_conventions.py` and `check_migration_order.py` enforce naming and ordering in CI

### Negative

- **Migration count grows** — 137 files and counting; may need squashing strategy eventually
- **Small fixes are verbose** — a one-line column rename requires a full migration file
- **Rollback is manual** — no automated rollback; rollback SQL is documented in comments

### Neutral

- Convention: `YYYYMMDDHHMMSS_description.sql` (Supabase timestamp format)
- Documented in `docs/MIGRATION_CONVENTIONS.md`
- Pipeline data files (`db/pipelines/`) are separate from schema migrations
