# SonarCloud Configuration

## Overview

This project uses [SonarCloud](https://sonarcloud.io/) for static analysis.
The project is configured in `sonar-project.properties` at the repo root.

- **Organization:** `ericsocrat`
- **Project key:** `ericsocrat_poland-food-db`
- **Dashboard:** <https://sonarcloud.io/project/overview?id=ericsocrat_poland-food-db>

## Quality Gate Strategy

We use the **"Clean as You Code"** approach:

- **New code only** — the quality gate evaluates new/changed lines,
  not the entire legacy codebase.
- PRs must have **0 new Bugs**, **0 new Vulnerabilities**, and
  **0 unreviewed Security Hotspots** to pass.
- Coverage on new code has a starter threshold (currently low)
  that will be raised as more tests are added.

Legacy code smells are paid down opportunistically in files we touch,
not via bulk refactor PRs.

## Coverage Reporting

Unit tests are written with **Vitest** and produce an `lcov` report.

```bash
# Run tests only
cd frontend && npm test

# Run tests with coverage
cd frontend && npm run test:coverage
```

The coverage report is generated at `frontend/coverage/lcov.info`.
SonarCloud reads it via:

```properties
sonar.javascript.lcov.reportPaths=frontend/coverage/lcov.info
```

## SQL File Exclusions

All SQL pipeline and migration files are **excluded** from Sonar analysis:

| Exclusion pattern        | Reason                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------- |
| `db/pipelines/**`        | Seed-data INSERT scripts — produce ~2k false-positive "duplicate literal" warnings. |
| `db/migrations/**`       | Schema migration scripts, not application logic.                                    |
| `supabase/migrations/**` | Supabase migration scripts.                                                         |

### PL/SQL Data Dictionary Warning

SonarCloud's PL/SQL analyzer can warn:

> *"Data Dictionary is not configured for the PL/SQL analyzer…"*

This happens because SonarCloud supports deep PL/SQL analysis when
connected to a live database, but we don't configure that. Our approach:

1. **Exclude SQL files** from Sonar sources (see table above).
2. **Restrict PL/SQL file suffixes** to `.plsql`, `.pkb`, `.pks`, `.pkg`
   — our `.sql` files won't be matched by the PL/SQL analyzer.
3. If we ever need deep SQL analysis, we'd configure a data dictionary
   connection per the SonarCloud docs.

## CI Integration

The GitHub Actions workflow (`.github/workflows/build.yml`) runs:

1. `npm ci` — install dependencies
2. `npm run type-check` — TypeScript strict check
3. `npm run lint` — ESLint
4. `npm run build` — Next.js production build
5. `npm run test:coverage` — Vitest with v8 coverage → lcov
6. SonarCloud scan (reads `sonar-project.properties` + lcov)
7. Quality Gate check (blocks merge if gate fails)

## Known Accepted Issues

| Issue                                                                          | Reason                                                                                                                              | Resolution                                            |
| ------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `@supabase/ssr` deprecated overload warning (TS6387)                           | Library keeps the old overload for backward compat. Our code uses the correct `getAll`/`setAll` API.                                | Will resolve when `@supabase/ssr` v1.0 ships.         |
| Middleware matcher uses escaped `\\.` in a string (Sonar prefers `String.raw`) | Next.js requires a **plain string literal** in `config.matcher` for static analysis. `String.raw` tagged templates break the build. | Accepted with `eslint-disable` comment.               |
| ~117 legacy maintainability issues                                             | Inherited from initial rapid development.                                                                                           | Paid down gradually in touched files; not bulk-fixed. |
