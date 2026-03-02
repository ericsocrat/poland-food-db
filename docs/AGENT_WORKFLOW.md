# TryVit — Agent Workflow Reference

> **Purpose:** Definitive guide for AI agents and automation workflows.
> Defines execution protocol, command references, and domain-specific
> documentation loading requirements.
> **Authority:** `copilot-instructions.md` is the primary source of truth.
> This doc is a pointer and quick-reference supplement.
> **Owner:** Issue [#200](https://github.com/ericsocrat/tryvit/issues/200)
> **Last updated:** 2026-03-02

---

## Execution Protocol

Before starting ANY work, follow this sequence:

1. **Read `CURRENT_STATE.md`** — understand live project status, open PRs, recent changes
2. **Read `copilot-instructions.md`** — full context (role, architecture, schema, conventions)
3. **Load domain docs** — from the Domain Matrix below (§ below)
4. **Read §8 Testing** — non-negotiable; every change requires tests
5. **Read §13 Git Workflow** — branch naming, PR discipline, conventional commits

> Skip any step only when the relevant domain is 100% not touched by this work.

---

## Priority Definitions

| Priority | Label    | Meaning                                                    |
| -------- | -------- | ---------------------------------------------------------- |
| **P0**   | Critical | Security, data loss, production down — act immediately     |
| **P1**   | High     | Blocking user functionality, broken CI, scoring regression |
| **P2**   | Normal   | Feature work, performance improvements, doc updates        |
| **P3**   | Low      | Cosmetic, nice-to-have, deferred cleanup                   |

> P0/P1 issues must reference a GitHub issue and link to it in the commit.

---

## Quick Command Reference

### Environment

```powershell
# Load .env into session
. .\setup-env.ps1

# Load + verify connectivity
. .\setup-env.ps1 -Verify

# Load + show masked values
. .\setup-env.ps1 -ShowValues
```

### Local Supabase

```powershell
supabase start                          # Start local stack
supabase stop                           # Stop local stack
supabase db reset                       # Reset to migrations only (no seed)
supabase db reset --linked              # Reset against remote project
supabase status                         # Print local connection strings
supabase functions serve                # Serve all Edge Functions locally
supabase functions deploy <name>        # Deploy single Edge Function
```

### Testing

```powershell
# Run all DB QA suites
pwsh RUN_QA.ps1

# Run specific QA file
psql $env:DATABASE_URL -f db/qa/QA__scoring.sql

# Run pgTAP tests
supabase test db

# Run frontend unit tests
cd frontend; npx vitest run

# Run E2E tests
cd frontend; npx playwright test

# Run sanity check
pwsh RUN_SANITY.ps1
```

### Pipeline

```powershell
# Local pipeline run
pwsh RUN_LOCAL.ps1

# Seed database
pwsh RUN_SEED.ps1

# Validate EANs
python validate_eans.py

# Enrich ingredients
python enrich_ingredients.py
```

### Repo Health

```powershell
# Verify repo hygiene
pwsh scripts/repo_verify.ps1

# Audit data enrichment identity
python check_enrichment_identity.py

# Run data audit
python run_data_audit.py
```

---

## Domain Documentation Matrix

> Full matrix with doc paths: see `copilot-instructions.md` §20.

| Domain                 | Key Docs to Load First                                 |
| ---------------------- | ------------------------------------------------------ |
| Database schema        | `ARCHITECTURE.md`, `MIGRATION_CONVENTIONS.md`          |
| Migrations             | `MIGRATION_CONVENTIONS.md`, `BACKFILL_STANDARD.md`     |
| Scoring formula        | `SCORING_METHODOLOGY.md`, `SCORING_ENGINE.md`          |
| API / RPC functions    | `API_CONTRACTS.md`, `API_CONVENTIONS.md`               |
| Search / indexing      | `SEARCH_ARCHITECTURE.md`                               |
| Frontend               | `frontend/docs/DESIGN_SYSTEM.md`, `UX_UI_DESIGN.md`    |
| Security / RLS         | `SECURITY_AUDIT.md`, `PRIVACY_CHECKLIST.md`            |
| Performance            | `PERFORMANCE_GUARDRAILS.md`                            |
| Multi-market expansion | `COUNTRY_EXPANSION_GUIDE.md`                           |
| Observability          | `MONITORING.md`, `LOG_SCHEMA.md`                       |
| CI/CD                  | `copilot-instructions.md §13`, §9                      |
| Feature flags          | `FEATURE_FLAGS.md`                                     |
| Pipeline / ETL         | `DATA_SOURCES.md`, `DATA_PROVENANCE.md`                |
| EAN / barcode          | `EAN_VALIDATION_STATUS.md`                             |
| i18n / localization    | `copilot-instructions.md §15.15`                       |
| Brand / assets         | `BRAND_GUIDELINES.md`                                  |
| Governance             | `GOVERNANCE_BLUEPRINT.md`, `REPO_GOVERNANCE.md`        |
| SLOs / alerting        | `SLO.md`, `ALERT_POLICY.md`                            |
| Contract testing       | `CONTRACT_TESTING.md`, `API_CONTRACTS.md`              |
| Data integrity         | `DATA_INTEGRITY_AUDITS.md`, `EAN_VALIDATION_STATUS.md` |

---

## Invariant Documents (Always Load)

These docs apply to ALL work regardless of domain:

| Doc                           | Why                                            |
| ----------------------------- | ---------------------------------------------- |
| `CURRENT_STATE.md`            | Live project status, recent PRs, active issues |
| `copilot-instructions.md §8`  | Testing requirements — non-negotiable          |
| `copilot-instructions.md §13` | Git workflow and PR discipline                 |
| `docs/INDEX.md`               | Navigation — find the right doc fast           |

---

## See Also

- `copilot-instructions.md` — primary instructions (all 20 sections)
- `docs/INDEX.md` — complete documentation index
- `CURRENT_STATE.md` — live project status
- `docs/REPO_GOVERNANCE.md` — file hygiene and PR rules
- `docs/ARCHITECTURE.md` — system architecture overview
