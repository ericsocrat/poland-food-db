<!-- ╔══════════════════════════════════════════════════════════════════╗ -->
<!-- ║  TryVit — README.md                                     ║ -->
<!-- ║  Redesigned 2026-02-28 · Issue #413                             ║ -->
<!-- ╚══════════════════════════════════════════════════════════════════╝ -->

<!-- ═══════════════════════════ 1. HERO BANNER ═══════════════════════════ -->

<p align="center">
  <img src="docs/assets/banners/readme-banner.png" alt="TryVit — Food Health Scanner" width="100%" />
</p>

<!-- ═══════════════════════════ 2. BADGES ROW ════════════════════════════ -->

<p align="center">
  <a href="https://github.com/ericsocrat/tryvit/actions/workflows/pr-gate.yml"><img src="https://img.shields.io/github/actions/workflow/status/ericsocrat/tryvit/pr-gate.yml?style=flat-square&label=build" alt="Build Status" /></a>
  <img src="https://img.shields.io/badge/QA%20checks-733%20passing-brightgreen?style=flat-square" alt="QA Checks" />
  <img src="https://img.shields.io/badge/coverage-%E2%89%A588%25-brightgreen?style=flat-square" alt="Coverage" />
  <img src="https://img.shields.io/badge/products-1%2C281-1DB954?style=flat-square" alt="Products" />
  <img src="https://img.shields.io/badge/market-Poland-1DB954?style=flat-square" alt="Market" />
  <img src="https://img.shields.io/badge/scoring-v3.2-7c3aed?style=flat-square" alt="Scoring Version" />
  <a href="LICENSE"><img src="https://img.shields.io/github/license/ericsocrat/tryvit?style=flat-square" alt="License" /></a>
  <img src="https://img.shields.io/badge/TypeScript-strict-3178c6?style=flat-square&logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL" />
</p>

<!-- ═══════════════════════════ 3. ELEVATOR PITCH ════════════════════════ -->

<p align="center">
  <strong>Scan, score &amp; compare food products with multi-axis health scoring.</strong><br />
  Every product scored on 9 independent factors. Every number traceable to its source.<br />
  Not a calorie counter. Not a Nutri-Score app. A research-grade scoring engine.
</p>

---

<!-- ═══════════════════════════ 4. FEATURE HIGHLIGHTS ════════════════════ -->

## ✨ Feature Highlights

<table>
  <tr>
    <td align="center" width="25%">
      <h3>🧬 9-Factor Scoring</h3>
      <p>Saturated fat, sugars, salt, calories, trans fat, additives, prep method, controversies, and ingredient concerns — weighted and combined into a single 1–100 score.</p>
    </td>
    <td align="center" width="25%">
      <h3>🔬 Ingredient Intelligence</h3>
      <p>2,995 canonical ingredients with EFSA concern tiers, additive classification, palm oil detection, and vegan/vegetarian flags.</p>
    </td>
    <td align="center" width="25%">
      <h3>📊 Data Confidence</h3>
      <p>Every product has a 0–100 confidence score showing data completeness — so you know how much to trust each number.</p>
    </td>
    <td align="center" width="25%">
      <h3>📱 Barcode Scanner</h3>
      <p>EAN-13 barcode lookup with 99.8% coverage. Scan any product to see its full scoring breakdown instantly.</p>
    </td>
  </tr>
</table>

---

<!-- ═══════════════════════════ 5. HOW IT DIFFERS ════════════════════════ -->

## 🔍 How It Differs

| Dimension                   | Nutri-Score Apps |                            TryVit                            |
| --------------------------- | :--------------: | :----------------------------------------------------------: |
| **Scoring axes**            |  1 (A–E letter)  | 4 independent (unhealthiness, Nutri-Score, NOVA, confidence) |
| **Additive analysis**       |        ❌         |            ✅ EFSA concern tiers + additive count             |
| **Processing level**        |        ❌         |                    ✅ NOVA 1–4 integrated                     |
| **Trans fat tracking**      |        ❌         |                  ✅ Separate weighted factor                  |
| **Controversy tracking**    |        ❌         |              ✅ Palm oil, artificial sweeteners               |
| **Data quality visibility** |      Hidden      |                ✅ Confidence score per product                |
| **Score explainability**    |       None       |             ✅ Full factor breakdown with context             |
| **Source provenance**       |      Opaque      |               ✅ Every product linked to source               |
| **Multi-country**           |      Varies      |                ✅ PL primary + DE micro-pilot                 |

---

<!-- ═══════════════════════════ 6. QUICK START ═══════════════════════════ -->

## 🚀 Quick Start

<table>
  <tr>
    <td width="33%">

**1. Clone & Start DB**

```powershell
git clone https://github.com/ericsocrat/tryvit.git
cd tryvit
supabase start
```

</td>
    <td width="33%">

**2. Run Pipelines**

```powershell
# All categories + QA
.\RUN_LOCAL.ps1 -RunQA

# Single category
.\RUN_LOCAL.ps1 -Category chips
```

</td>
    <td width="34%">

**3. Start Frontend**

```bash
cd frontend
npm ci
npm run dev
# → http://localhost:3000
```

</td>
  </tr>
</table>

<details>
<summary><strong>📋 Full Command Reference</strong></summary>

```powershell
# ── Database ──
supabase start                           # Start local Supabase
supabase db reset                        # Full rebuild (migrations + seed)

# ── Pipelines ──
.\RUN_LOCAL.ps1 -RunQA                   # All categories + QA validation
.\RUN_LOCAL.ps1 -Category dairy          # Single category
.\RUN_SEED.ps1                           # Seed reference data only

# ── Testing ──
.\RUN_QA.ps1                             # 733 QA checks across 48 suites
.\RUN_NEGATIVE_TESTS.ps1                 # 23 constraint violation tests
.\RUN_SANITY.ps1 -Env local              # Row-count + schema assertions
python validate_eans.py                  # EAN checksum validation
python check_pipeline_structure.py       # Pipeline folder/file structure

# ── Frontend ──
cd frontend
npm run dev                              # Dev server (localhost:3000)
npm run build                            # Production build
npx tsc --noEmit                         # TypeScript check
npm run lint                             # ESLint
npx vitest run                           # Unit tests (Vitest)
npm run test:coverage                    # Unit tests + v8 coverage
npx playwright test                      # E2E smoke tests (Playwright)

# ── Data Access ──
echo "SELECT * FROM v_master LIMIT 5;" | docker exec -i supabase_db_tryvit psql -U postgres -d postgres
```

</details>

---

<!-- ═══════════════════════════ 7. ARCHITECTURE ══════════════════════════ -->

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────────┐
│  Open Food Facts │────▶│  Python Pipeline │────▶│  PostgreSQL (Supabase)  │
│  API v2          │     │  sql_generator   │     │  185 migrations         │
│  (category tags, │     │  validator       │     │  25 pipeline folders    │
│   countries=PL)  │     │  off_client      │     │  products + nutrition   │
└─────────────────┘     └──────────────────┘     │  + ingredients + scores │
                                                  └───────────┬─────────────┘
                                                              │
                                                  ┌───────────▼─────────────┐
                                                  │  API Layer              │
                                                  │  30+ RPC functions      │
                                                  │  RLS + SECURITY DEFINER │
                                                  │  pg_trgm search         │
                                                  └───────────┬─────────────┘
                                                              │
                                                  ┌───────────▼─────────────┐
                                                  │  Next.js 15 Frontend    │
                                                  │  App Router + SSR       │
                                                  │  TanStack Query v5      │
                                                  │  Supabase Auth          │
                                                  └─────────────────────────┘
```

**Data flow:** OFF API → Python pipeline generates idempotent SQL → PostgreSQL stores products, nutrition, ingredients, allergens → Scoring function `compute_unhealthiness_v32()` computes scores → API functions expose structured JSONB → Next.js frontend renders.

---

<!-- ═══════════════════════════ 8. SCORING SUMMARY ═══════════════════════ -->

## 📈 Scoring Engine (v3.2)

```
unhealthiness_score (1–100) =
  sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
  trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
  controversies(0.08) + ingredient_concern(0.05)
```

<table>
  <tr>
    <td align="center" width="20%"><strong>🟢 1–20</strong><br />Low risk</td>
    <td align="center" width="20%"><strong>🟡 21–40</strong><br />Moderate</td>
    <td align="center" width="20%"><strong>🟠 41–60</strong><br />Elevated</td>
    <td align="center" width="20%"><strong>🔴 61–80</strong><br />High risk</td>
    <td align="center" width="20%"><strong>⬛ 81–100</strong><br />Very high</td>
  </tr>
</table>

**Ceilings** (per 100 g): sat fat 10 g · sugars 27 g · salt 3 g · trans fat 2 g · calories 600 kcal · additives 10

Every score is fully explainable via `api_score_explanation()` — returns the 9 factors with raw values, weights, and category context (rank, average, percentile).

📄 [Full methodology →](docs/SCORING_METHODOLOGY.md)

---

<!-- ═══════════════════════════ 9. STATS DASHBOARD ═══════════════════════ -->

## 📊 By the Numbers

<table>
  <tr>
    <td align="center" width="16%"><strong>1,281</strong><br />Active Products</td>
    <td align="center" width="16%"><strong>25</strong><br />Categories</td>
    <td align="center" width="16%"><strong>PL</strong><br />Primary Market</td>
    <td align="center" width="16%"><strong>2,995</strong><br />Ingredients</td>
    <td align="center" width="16%"><strong>99.8%</strong><br />EAN Coverage</td>
    <td align="center" width="16%"><strong>182</strong><br />Migrations</td>
  </tr>
</table>

<table>
  <tr>
    <td align="center" width="16%"><strong>733</strong><br />QA Checks</td>
    <td align="center" width="16%"><strong>48</strong><br />Test Suites</td>
    <td align="center" width="16%"><strong>23</strong><br />Negative Tests</td>
    <td align="center" width="16%"><strong>≥88%</strong><br />Line Coverage</td>
    <td align="center" width="16%"><strong>30+</strong><br />API Functions</td>
    <td align="center" width="16%"><strong>v3.2</strong><br />Scoring Engine</td>
  </tr>
</table>

---

<!-- ═══════════════════════════ 10. TECH STACK ═══════════════════════════ -->

## 🛠️ Tech Stack

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/Supabase-Database%20%2B%20Auth-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Next.js-15-000000?style=for-the-badge&logo=next.js&logoColor=white" alt="Next.js" />
  <img src="https://img.shields.io/badge/TypeScript-Strict-3178c6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Tailwind%20CSS-4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="Tailwind CSS" />
  <img src="https://img.shields.io/badge/TanStack%20Query-v5-FF4154?style=for-the-badge&logo=react-query&logoColor=white" alt="TanStack Query" />
  <img src="https://img.shields.io/badge/Python-Pipeline-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/Playwright-E2E-2EAD33?style=for-the-badge&logo=playwright&logoColor=white" alt="Playwright" />
  <img src="https://img.shields.io/badge/Vitest-Unit%20Tests-6E9F18?style=for-the-badge&logo=vitest&logoColor=white" alt="Vitest" />
  <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/SonarCloud-Quality-F3702A?style=for-the-badge&logo=sonarcloud&logoColor=white" alt="SonarCloud" />
  <img src="https://img.shields.io/badge/Sentry-Monitoring-362D59?style=for-the-badge&logo=sentry&logoColor=white" alt="Sentry" />
</p>

---

<!-- ═══════════════════════════ 11. PROJECT STRUCTURE ════════════════════ -->

## 📁 Project Structure

<details>
<summary><strong>Click to expand full directory tree</strong></summary>

```
tryvit/
├── pipeline/                        # Python OFF API → SQL generator
│   ├── run.py                       # CLI: --category, --max-products, --dry-run, --country
│   ├── off_client.py                # OFF API v2 client with retry logic
│   ├── sql_generator.py             # Generates 4–5 SQL files per category
│   ├── validator.py                 # Data validation before SQL generation
│   ├── categories.py                # 25 category definitions + OFF tag mappings
│   └── image_importer.py            # Product image import utility
│
├── db/
│   ├── pipelines/                   # 25 category folders (20 PL + 5 DE)
│   │   ├── chips-pl/                # Reference PL implementation
│   │   ├── chips-de/                # Germany micro-pilot (51 products)
│   │   ├── bread-de/                # DE Bread
│   │   ├── dairy-de/                # DE Dairy
│   │   ├── drinks-de/               # DE Drinks
│   │   ├── sweets-de/               # DE Sweets
│   │   └── ... (19 more PL)         # Variable product counts per category
│   ├── qa/                          # 48 test suites (733 checks)
│   └── views/                       # Reference view definitions
│
├── supabase/
│   ├── migrations/                  # 185 append-only schema migrations
│   ├── seed/                        # Reference data seeds
│   ├── tests/                       # pgTAP integration tests
│   └── functions/                   # Edge Functions (API gateway, push notifications)
│
├── frontend/                        # Next.js 15 App Router
│   ├── src/
│   │   ├── app/                     # Pages (App Router)
│   │   ├── components/              # React components
│   │   ├── hooks/                   # TanStack Query hooks
│   │   ├── stores/                  # Zustand stores
│   │   └── lib/                     # API clients, types, utilities
│   ├── e2e/                         # Playwright E2E tests
│   └── messages/                    # i18n dictionaries (en, pl)
│
├── docs/                            # 45+ project documents
│   ├── SCORING_METHODOLOGY.md       # v3.2 algorithm specification
│   ├── API_CONTRACTS.md             # API surface contracts
│   ├── ARCHITECTURE.md              # System architecture overview
│   ├── decisions/                   # Architecture Decision Records (MADR 3.0)
│   └── assets/                      # Brand assets (logo, banners)
│
├── .github/workflows/               # 18 CI/CD workflows
├── scripts/                         # Utility & governance scripts
├── monitoring/                      # Alert definitions
│
├── RUN_LOCAL.ps1                    # Pipeline runner (idempotent)
├── RUN_QA.ps1                       # QA test runner (733 checks)
├── RUN_NEGATIVE_TESTS.ps1           # Negative test runner (23 tests)
├── RUN_SANITY.ps1                   # Sanity checks
├── CHANGELOG.md                     # Structured changelog
├── DEPLOYMENT.md                    # Deployment procedures & rollback
└── SECURITY.md                      # Security policy
```

</details>

---

<!-- ═══════════════════════════ 12. TESTING ══════════════════════════════ -->

## 🧪 Testing

Every change is validated against **733 automated checks** across 48 QA suites plus 20 negative validation tests. No data enters the database without verification.

<table>
  <tr>
    <th>Layer</th>
    <th>Tool</th>
    <th>Checks</th>
    <th>Location</th>
  </tr>
  <tr>
    <td>Database QA</td>
    <td>Raw SQL (zero rows = pass)</td>
    <td>733</td>
    <td><code>db/qa/QA__*.sql</code></td>
  </tr>
  <tr>
    <td>Negative Tests</td>
    <td>SQL constraint validation</td>
    <td>23</td>
    <td><code>db/qa/TEST__*.sql</code></td>
  </tr>
  <tr>
    <td>Unit Tests</td>
    <td>Vitest (jsdom, v8 coverage)</td>
    <td>—</td>
    <td><code>frontend/src/**/*.test.{ts,tsx}</code></td>
  </tr>
  <tr>
    <td>E2E Tests</td>
    <td>Playwright (Chromium)</td>
    <td>—</td>
    <td><code>frontend/e2e/*.spec.ts</code></td>
  </tr>
  <tr>
    <td>pgTAP</td>
    <td>PostgreSQL TAP testing</td>
    <td>—</td>
    <td><code>supabase/tests/*.test.sql</code></td>
  </tr>
  <tr>
    <td>EAN Validation</td>
    <td>GS1 checksum verifier</td>
    <td>1</td>
    <td><code>validate_eans.py</code></td>
  </tr>
  <tr>
    <td>Code Quality</td>
    <td>SonarCloud</td>
    <td>—</td>
    <td>CI (main-gate.yml)</td>
  </tr>
</table>

**CI Pipeline** (GitHub Actions, tiered):

1. **PR Gate** — Typecheck → Lint → Build → Unit tests → Playwright smoke E2E
2. **Main Gate** — Above + Coverage → SonarCloud Quality Gate
3. **QA Gate** — Schema → Pipelines → 733 QA checks → Sanity → Confidence threshold
4. **Nightly** — Full Playwright (all projects) + Data Integrity Audit

---

<!-- ═══════════════════════════ 13. CONTRIBUTING ═════════════════════════ -->

## 🤝 Contributing

Contributions are welcome! Please follow the project conventions:

1. **Branch naming:** `feat/`, `fix/`, `docs/`, `chore/`, `schema/`, `data/`
2. **Commit messages:** [Conventional Commits](https://www.conventionalcommits.org/) — enforced on PR titles
3. **Testing:** Every change must include tests. See [copilot-instructions.md](copilot-instructions.md) §8
4. **Migrations:** Append-only. Never modify existing `supabase/migrations/` files
5. **QA:** `.\RUN_QA.ps1` must pass (733/733) before merging

---

<!-- ═══════════════════════════ 14. DOCUMENTATION ═══════════════════════ -->

## 📚 Documentation

<details>
<summary><strong>Core</strong></summary>

- [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md) — v3.2 algorithm (9 factors, ceilings, bands)
- [API_CONTRACTS.md](docs/API_CONTRACTS.md) — API surface contracts and response shapes
- [API_CONVENTIONS.md](docs/API_CONVENTIONS.md) — RPC naming, breaking changes, security standards
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — System architecture overview
- [DATA_SOURCES.md](docs/DATA_SOURCES.md) — Multi-source data hierarchy & validation
- [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) — Data collection lifecycle
- [FRONTEND_API_MAP.md](docs/FRONTEND_API_MAP.md) — Frontend ↔ API mapping
- [SCORING_ENGINE.md](docs/SCORING_ENGINE.md) — Scoring engine architecture & versioning

</details>

<details>
<summary><strong>Operations</strong></summary>

- [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) — Queries, Studio UI, test runner
- [DEPLOYMENT.md](DEPLOYMENT.md) — Deployment procedures & rollback playbook
- [ENVIRONMENT_STRATEGY.md](docs/ENVIRONMENT_STRATEGY.md) — Local / Staging / Production
- [COUNTRY_EXPANSION_GUIDE.md](docs/COUNTRY_EXPANSION_GUIDE.md) — Multi-country protocol
- [MIGRATION_CONVENTIONS.md](docs/MIGRATION_CONVENTIONS.md) — Migration safety & idempotency
- [BACKFILL_STANDARD.md](docs/BACKFILL_STANDARD.md) — Backfill orchestration
- [EAN_VALIDATION_STATUS.md](docs/EAN_VALIDATION_STATUS.md) — EAN coverage (99.8%)

</details>

<details>
<summary><strong>Quality & Security</strong></summary>

- [SECURITY.md](SECURITY.md) — Security policy & threat model
- [SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md) — Full security audit report
- [DATA_INTEGRITY_AUDITS.md](docs/DATA_INTEGRITY_AUDITS.md) — Data integrity framework
- [PRIVACY_CHECKLIST.md](docs/PRIVACY_CHECKLIST.md) — GDPR/RODO compliance
- [PERFORMANCE_REPORT.md](docs/PERFORMANCE_REPORT.md) — Performance audit & projections
- [SLO.md](docs/SLO.md) — Service Level Objectives
- [RATE_LIMITING.md](docs/RATE_LIMITING.md) — Rate limiting & abuse prevention

</details>

<details>
<summary><strong>Governance & CI</strong></summary>

- [GOVERNANCE_BLUEPRINT.md](docs/GOVERNANCE_BLUEPRINT.md) — Execution governance plan
- [CI_ARCHITECTURE_PROPOSAL.md](docs/CI_ARCHITECTURE_PROPOSAL.md) — CI pipeline design
- [CONTRACT_TESTING.md](docs/CONTRACT_TESTING.md) — API contract testing strategy
- [DRIFT_DETECTION.md](docs/DRIFT_DETECTION.md) — 8-check drift detection catalog
- [INCIDENT_RESPONSE.md](docs/INCIDENT_RESPONSE.md) — Incident playbook
- [MONITORING.md](docs/MONITORING.md) — Runtime monitoring
- [OBSERVABILITY.md](docs/OBSERVABILITY.md) — Observability strategy
- [SONAR.md](docs/SONAR.md) — SonarCloud configuration

</details>

<details>
<summary><strong>Design & UX</strong></summary>

- [UX_UI_DESIGN.md](docs/UX_UI_DESIGN.md) — Production-ready UX spec
- [UX_IMPACT_METRICS.md](docs/UX_IMPACT_METRICS.md) — UX measurement standard
- [BRAND_GUIDELINES.md](docs/BRAND_GUIDELINES.md) — Visual identity reference
- [SEARCH_ARCHITECTURE.md](docs/SEARCH_ARCHITECTURE.md) — pg_trgm + tsvector search

</details>

📄 Full index: [docs/INDEX.md](docs/INDEX.md)

---

<!-- ═══════════════════════════ 15. LICENSE & ACKNOWLEDGMENTS ════════════ -->

## 📜 License

This project is licensed under the terms in the [LICENSE](LICENSE) file.

**Data acknowledgments:**

- [Open Food Facts](https://world.openfoodfacts.org/) — Product data source (ODbL license)
- [Supabase](https://supabase.com/) — Database platform
- [EFSA](https://www.efsa.europa.eu/) — Food additive concern tier classifications

---

<!-- ═══════════════════════════ FOOTER ═══════════════════════════════════ -->

<p align="center">
  <img src="docs/assets/logo/logomark-64.png" alt="TryVit" width="32" />
  <br />
  <em>Built with science and care.</em>
</p>
