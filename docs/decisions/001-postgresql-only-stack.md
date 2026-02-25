# ADR-001: Use PostgreSQL-Only Stack via Supabase

> **Date:** 2026-02-07 (retroactive — original decision at project inception)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

The project needed a backend for a food quality database with complex scoring algorithms, full-text search, allergen filtering, and ingredient analytics. Common approaches include:

1. **Traditional API layer** (Express/Fastify + ORM + PostgreSQL) — familiar but adds a server to maintain, deploy, and secure.
2. **Serverless functions** (Vercel/Netlify functions + managed DB) — auto-scaling but cold starts, limited SQL expressiveness, vendor lock-in on compute.
3. **PostgreSQL-only via Supabase** — all business logic as SQL functions, Supabase provides auth, RLS, and REST/realtime APIs out of the box.

The scoring algorithm requires multi-table JOINs, LATERAL subqueries, window functions, and JSONB aggregation. Expressing this in an ORM would be fragile and slower. The search layer uses `pg_trgm` and `tsvector` — native PostgreSQL features with no ORM equivalent.

## Decision

Use **PostgreSQL as the sole application backend**, accessed via Supabase client libraries. All business logic lives in SQL functions (`api_*` RPCs). No separate API server. No ORM.

- Frontend calls Supabase RPC functions directly
- Auth handled by Supabase Auth (GoTrue)
- Row-Level Security (RLS) enforces access control at the database layer
- Migrations managed by Supabase CLI (`supabase/migrations/`)

## Consequences

### Positive

- **Zero API server** — no Express/Fastify to maintain, deploy, or patch
- **Single source of truth** — all logic is version-controlled SQL, testable via pgTAP
- **Native performance** — scoring, search, and analytics run inside PostgreSQL without network hops
- **Strong typing** — CHECK constraints, FKs, and domain types enforce data integrity at the DB level
- **Supabase provides** auth, realtime, storage, and edge functions for free tier

### Negative

- **SQL-heavy codebase** — contributors need strong PostgreSQL skills, not just JavaScript
- **Testing requires running DB** — pgTAP tests need a live PostgreSQL instance
- **Vendor coupling** — Supabase CLI, config.toml, and migration format are specific to Supabase (though the SQL itself is portable)
- **Limited mocking** — frontend tests must mock Supabase client rather than a standard REST API

### Neutral

- Frontend uses Next.js App Router with TanStack Query for data fetching
- Pipeline (Python) generates SQL files, not direct DB writes — maintaining the SQL-first principle
