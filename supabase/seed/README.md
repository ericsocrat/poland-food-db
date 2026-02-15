# Seed Data — `supabase/seed/`

## Overview

This folder contains **reference/lookup data** SQL files that populate the foundational tables required before product pipelines can run. These are separate from the main `supabase/seed.sql` (which is intentionally empty) to allow targeted seeding.

## Files

| File                     | Purpose                 | Tables                                                               |
| ------------------------ | ----------------------- | -------------------------------------------------------------------- |
| `001_reference_data.sql` | Reference/lookup tables | `country_ref`, `category_ref`, `nutri_score_ref`, `concern_tier_ref` |

## When to use

These seed files are **already embedded in migrations** (`20260210002500_reference_tables.sql`, etc.), so they are applied automatically during `supabase db reset`. The seed files here serve as a **standalone, repeatable** alternative for:

1. **Seeding a fresh cloud project** after `supabase db push` (which applies migrations but may not re-insert reference data if the table already exists from a previous partial run).
2. **Updating reference data** (e.g., adding a new country or category) without creating a new migration.
3. **Re-syncing** reference tables if they've drifted due to manual Dashboard edits.

## Usage

### Local (via Docker)

```powershell
docker exec -i supabase_db_poland-food-db psql -U postgres -d postgres -f /dev/stdin < supabase/seed/001_reference_data.sql
```

### Remote (via psql)

```powershell
$env:PGPASSWORD = $env:SUPABASE_DB_PASSWORD
psql -h db.<project-ref>.supabase.co -p 5432 -U postgres -d postgres -f supabase/seed/001_reference_data.sql
```

### Via RUN_SEED.ps1 (recommended)

```powershell
.\RUN_SEED.ps1 -Env local      # Seeds local Docker DB
.\RUN_SEED.ps1 -Env staging    # Seeds staging cloud project
.\RUN_SEED.ps1 -Env production # Seeds production (guarded)
```

## Safety

- All INSERTs use `ON CONFLICT ... DO UPDATE` — safe to run repeatedly.
- Reference data is stable and small (~30 rows total across 4 tables).
- Product data is NOT in this folder — it comes from `db/pipelines/`.
