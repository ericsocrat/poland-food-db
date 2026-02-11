# Poland Food Quality Database

[![QA Tests](https://github.com/ericsocrat/poland-food-db/actions/workflows/qa.yml/badge.svg)](https://github.com/ericsocrat/poland-food-db/actions/workflows/qa.yml)

A multi-axis food quality database scoring **560 products** sold in Poland using a 9-factor weighted algorithm (v3.2) based on nutritional science and EU regulatory guidelines.

## What This Project Is

A **nutritional risk database** that scores packaged food products on multiple independent axes:
- **Unhealthiness Score (1-100):** 9-factor weighted penalty score — higher = more nutritional risk factors
- **Nutri-Score (A-E):** EU-style front-of-pack nutrition grade
- **NOVA (1-4):** Processing level classification
- **Data Confidence (0-100):** How complete and verified the underlying data is

This is **not** a Nutri-Score app, a calorie counter, or a "healthy/unhealthy" binary classifier. It is a transparent, multi-dimensional scoring system where every number links back to the data and methodology that produced it.

## How It Differs From Nutri-Score Apps

| Dimension               | Nutri-Score Apps | This Project                                                      |
| ----------------------- | ---------------- | ----------------------------------------------------------------- |
| Scoring axes            | 1 (A-E letter)   | 4 independent axes (unhealthiness, nutri-score, NOVA, confidence) |
| Additive analysis       | No               | Yes — EFSA concern tiers, additive count                          |
| Processing level        | No               | Yes — NOVA 1-4 integrated into score                              |
| Trans fat tracking      | No               | Yes — separate weighted factor                                    |
| Controversy tracking    | No               | Yes — palm oil, artificial sweeteners flagged                     |
| Data quality visibility | Hidden           | Explicit — confidence score per product                           |
| Score explainability    | None             | Full factor breakdown with category context                       |
| Source provenance       | Opaque           | Tracked — every product links to its data source                  |

## 🎯 Quick Start

### 1. Start Local Database
```powershell
supabase start
```

### 2. Run Pipelines
```powershell
# Run all categories
.\RUN_LOCAL.ps1 -RunQA

# Run specific category
.\RUN_LOCAL.ps1 -Category chips -RunQA
.\RUN_LOCAL.ps1 -Category zabka -RunQA
.\RUN_LOCAL.ps1 -Category cereals -RunQA
.\RUN_LOCAL.ps1 -Category drinks -RunQA
```

### 3. View Data
- **Web UI**: Open http://127.0.0.1:54323 → **Table Editor** or **SQL Editor**
- **Command-line**: See [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) for queries

### 4. Run Tests
```powershell
# All tests (144 critical checks + 14 informational)
.\RUN_QA.ps1

# Or via pipeline runner
.\RUN_LOCAL.ps1 -RunQA
```

---

## 📊 Current Status

**Database**: 560 active products across 20 categories (28 per category, deprecated products purged)

| Category                       | Products | Brands | Score Range |
| ------------------------------ | -------: | -----: | ----------- |
| **Alcohol**                    |       28 |     25 | 5–21        |
| **Baby**                       |       28 |     20 | 8–40        |
| **Bread**                      |       28 |     15 | 17–44       |
| **Breakfast & Grain-Based**    |       28 |     16 | 18–43       |
| **Canned Goods**               |       28 |     18 | 8–33        |
| **Cereals**                    |       28 |     14 | 13–48       |
| **Chips**                      |       28 |     12 | 15–44       |
| **Condiments**                 |       28 |     10 | 8–43        |
| **Dairy**                      |       28 |     13 | 9–48        |
| **Drinks**                     |       28 |     16 | 5–15        |
| **Frozen & Prepared**          |       28 |     17 | 5–50        |
| **Instant & Frozen**           |       28 |     15 | 10–54       |
| **Meat**                       |       28 |     20 | 14–47       |
| **Nuts, Seeds & Legumes**      |       28 |     11 | 25–49       |
| **Plant-Based & Alternatives** |       28 |     22 | 6–33        |
| **Sauces**                     |       28 |     18 | 7–44        |
| **Seafood & Fish**             |       28 |     13 | 9–36        |
| **Snacks**                     |       28 |     26 | 13–55       |
| **Sweets**                     |       28 |     17 | 28–55       |
| **Żabka**                      |       28 |      3 | 15–43       |
**Test Coverage**: 144 automated critical checks + 14 data quality reports
- 35 data integrity checks (nulls, orphans, foreign keys, duplicates, nutrition sanity, category invariant, view consistency, energy cross-check, product-source provenance) + 6 informational
- 29 scoring formula validation checks (ranges, flags, NOVA, domain validation, confidence, regression tests)
- 1 EAN checksum validation (all barcodes verified)
- 14 API surface validation checks (contract validation, JSON structure, listing consistency)
- 10 confidence scoring checks (range, distribution, component totals, band assignment)
- 28 data quality checks (completeness, constraints, domains)
- 17 referential integrity checks (FK validation, domain constraints)
- 10 view consistency checks
- 8 source coverage & confidence tracking reports (informational, non-blocking)

**All critical tests passing**: ✅ 144/144

**EAN Coverage**: 558/560 active products (99.6%) have valid EAN-8/EAN-13 barcodes

---

## 🏗️ Project Structure

```
poland-food-db/
├── db/
│   ├── migrations/          # (empty — consolidated into supabase/migrations)
│   ├── pipelines/           # Category-specific data pipelines
│   │   ├── alcohol/         # 28 alcohol products (4 SQL files)
│   │   ├── baby/            # 28 baby products (4 SQL files)
│   │   ├── bread/           # 28 bread products (4 SQL files)
│   │   ├── breakfast-grain-based/ # 28 breakfast products (4 SQL files)
│   │   ├── canned-goods/    # 28 canned goods products (4 SQL files)
│   │   ├── cereals/         # 28 cereal products (4 SQL files)
    │   ├── chips/           # 28 chip products (4 SQL files)
│   │   ├── condiments/      # 28 condiment products (4 SQL files)
│   │   ├── dairy/           # 28 dairy products (4 SQL files)
│   │   ├── drinks/          # 28 beverage products (4 SQL files)
│   │   ├── frozen-prepared/ # 28 frozen & prepared products (4 SQL files)
│   │   ├── instant-frozen/  # 28 instant & frozen products (4 SQL files)
│   │   ├── meat/            # 28 meat & deli products (4 SQL files)
│   │   ├── nuts-seeds-legumes/ # 28 nuts, seeds & legumes products (4 SQL files)
│   │   ├── plant-based-alternatives/ # 28 plant-based products (4 SQL files)
│   │   ├── sauces/          # 28 sauce products (4 SQL files)
│   │   ├── seafood-fish/    # 28 seafood & fish products (4 SQL files)
│   │   ├── snacks/          # 28 snack products (4 SQL files)
│   │   ├── sweets/          # 28 sweets & chocolate products (4 SQL files)
    │   └── zabka/           # 28 convenience store products (4 SQL files)
│   ├── qa/                  # Quality assurance test suites
│   │   ├── QA__null_checks.sql           # 35 integrity checks
│   │   ├── QA__scoring_formula_tests.sql # 29 algorithm tests
│   │   ├── QA__api_surfaces.sql          # 8 API contract checks
│   │   ├── QA__confidence_scoring.sql    # 10 confidence scoring checks
│   │   ├── QA__data_quality.sql          # 28 data quality checks
│   │   ├── QA__referential_integrity.sql # 17 referential integrity checks
│   │   ├── QA__view_consistency.sql      # 10 view consistency checks
    │   └── QA__source_coverage.sql       # 8 data quality reports
│   └── views/               # Denormalized reporting views
│       └── VIEW__master_product_view.sql # Flat API view with provenance
├── supabase/
│   ├── config.toml          # Local Supabase configuration
    └── migrations/          # Schema migrations (39 files)
├── docs/                    # Project documentation
│   ├── API_CONTRACTS.md     # API surface contract documentation
│   ├── PERFORMANCE_REPORT.md # Performance audit & scale readiness
│   ├── DATA_SOURCES.md      # Multi-source data hierarchy & validation workflow
│   ├── SCORING_METHODOLOGY.md # v3.2 algorithm documentation
│   ├── RESEARCH_WORKFLOW.md # Step-by-step data collection process
│   ├── VIEWING_AND_TESTING.md # Full viewing & testing guide
│   ├── COUNTRY_EXPANSION_GUIDE.md # Future multi-country rules
│   ├── EAN_EXPANSION_PLAN.md  # EAN coverage strategy
│   └── EAN_VALIDATION_STATUS.md # Current EAN validation status
├── pipeline/                # Python data pipeline (OFF API v2 → SQL)
├── RUN_LOCAL.ps1            # Pipeline runner (idempotent)
├── RUN_QA.ps1               # Standalone test runner
└── RUN_REMOTE.ps1           # Remote deployment (with confirmation)
```

---

## 🧪 Testing Philosophy

**Principle:** No data enters the database without automated verification. No scoring change ships without regression tests proving existing products are unaffected.

Every change is validated against **144 automated critical checks** + 14 informational data quality reports:

### Data Integrity (35 checks)
- No missing required fields (product_name, brand, country, category)
- No orphaned foreign keys (nutrition, scores, servings)
- No duplicate products
- All active products have servings, nutrition, and scores rows
- Nutrition sanity (no negative values, sat_fat ≤ total_fat, sugars ≤ carbs, calories ≤ 900)
- Category invariant (exactly 28 products per active category)
- Score fields not null for active products
- View consistency (v_master row count matches products)
- Product-source provenance (every product has a source, single primary, no fan-out)

### Scoring Formula (29 checks)
- Scores in valid range [1, 100]
- Clean products score ≤ 20
- Maximum unhealthy products score high
- Identical nutrition → identical scores
- Flag logic (salt ≥1.5g, sugar ≥5g, sat fat ≥5g)
- High additive load flag consistency
- NOVA classification valid (1–4)
- Processing risk alignment with NOVA
- Scoring version = v3.2
- Nutri-Score label domain (A–E or UNKNOWN)
- Confidence domain (verified, estimated, low)
- **Regression**: Top Chips Faliste = 51±2 (palm oil)
- **Regression**: Naleśniki = 17±2 (healthiest Żabka)
- **Regression**: Melvit Płatki Owsiane = 11±2 (healthiest cereal)
- **Regression**: Coca-Cola Zero = 8±2 (lowest-scoring drink)
- **Regression**: Piątnica Skyr Naturalny = 9±2 (healthiest dairy)
- **Regression**: Mestemacher Pumpernikiel = 17±2 (traditional rye)
- **Regression**: Tarczyński Kabanosy Klasyczne = 55±2 (high-fat cured meat)
- **Regression**: Knorr Nudle Pomidorowe Pikantne = 21±2 (instant noodle, palm oil)

### Source Coverage (8 informational reports + 4 in null_checks)
- Products without source metadata
- Single-source products needing cross-validation
- High-impact products (score >40, single-source)
- EAN coverage by category
- Confidence level distribution
- Ingredient data coverage

### API Surface Validation (8 checks)
- Category overview row count matches reference table
- Product count sums match v_master
- All products return valid API JSON
- Required JSON keys present in product detail
- Score explanation covers all scored products
- Search and listing return valid structures

### Confidence Scoring (10 checks)
- Confidence scores in valid range (0-100)
- Band assignment matches score thresholds (high ≥80, medium 50-79, low <50)
- All 6 components sum to total score
- No products missing confidence data
- Distribution sanity (≥80% should be high confidence)
- Component weights match formula specification

**Test files**: `db/qa/QA__*.sql` — Run via `.\RUN_QA.ps1`

**CI**: All 144 checks run on every push to `main` via GitHub Actions. Confidence coverage threshold enforced (max 5% low-confidence products).

Run tests after **every** schema change or data update.

### Database Constraints

28 CHECK constraints enforce domain rules at the database level, plus 4 FK-backed reference tables:

**Reference Tables** (FK constraints):

| FK Constraint                | Table → Reference Table           | Purpose                             |
| ---------------------------- | --------------------------------- | ----------------------------------- |
| `fk_products_country`        | products → country_ref            | ISO 3166-1 country validation       |
| `fk_products_category`       | products → category_ref           | Category master list (20 active)    |
| `fk_scores_nutri_score`      | scores → nutri_score_ref          | Nutri-Score label definitions (A–E) |
| `fk_ingredient_concern_tier` | ingredient_ref → concern_tier_ref | EFSA concern tiers (0–3)            |

**CHECK Constraints** (19+):

| Table           | Constraint                       | Rule                                                              |
| --------------- | -------------------------------- | ----------------------------------------------------------------- |
| products        | `chk_products_country`           | country IN ('PL')                                                 |
| products        | `chk_products_prep_method`       | Valid prep method or null                                         |
| products        | `chk_products_controversies`     | controversies IN ('none','minor','moderate','serious','palm oil') |
| scores          | `chk_scores_unhealthiness_range` | 1–100                                                             |
| scores          | `chk_scores_nutri_label`         | A–E, UNKNOWN, or NOT-APPLICABLE                                   |
| scores          | `chk_scores_confidence`          | verified / estimated / low                                        |
| scores          | `chk_scores_nova`                | 1–4                                                               |
| scores          | `chk_scores_processing_risk`     | Low / Moderate / High                                             |
| scores          | `chk_scores_*_flag`              | YES / NO (4 flags)                                                |
| scores          | `chk_scores_completeness`        | 0–100                                                             |
| nutrition_facts | `chk_nf_non_negative` (7 cols)   | ≥ 0                                                               |
| nutrition_facts | `chk_nf_sat_fat_le_total`        | saturated_fat ≤ total_fat                                         |
| nutrition_facts | `chk_nf_sugars_le_carbs`         | sugars ≤ carbs                                                    |
| servings        | `chk_servings_basis`             | 'per 100 g' or 'per serving'                                      |
| servings        | `chk_servings_amount_positive`   | amount > 0                                                        |

---

## 📈 Scoring Methodology

### v3.2 Formula (9 factors)

Implemented as a reusable PostgreSQL function `compute_unhealthiness_v32()` — all category pipelines call this single function.

```
unhealthiness_score =
  sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
  trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
  controversies(0.08) + ingredient_concern(0.05)
```

**Score Bands**:
- **1–20**: Low risk
- **21–40**: Moderate risk
- **41–60**: Elevated risk
- **61–80**: High risk
- **81–100**: Very high risk

**Ceilings** (per 100g): sat fat 10g, sugars 27g, salt 3g, trans fat 2g, calories 600 kcal, additives 10

Full documentation: [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md)

---

## 🔍 Data Quality & Provenance

### Confidence Levels

Every product receives an automated **data confidence** score (0-100) measuring how complete and verified the underlying data is. This is NOT a quality or healthiness score — it tells you how much to trust the displayed numbers.

| Confidence | Score | Criteria                              | Meaning                          |
| ---------- | ----- | ------------------------------------- | -------------------------------- |
| **High**   | ≥80   | Comprehensive nutrition + ingredients | Data is reliable for scoring     |
| **Medium** | 50-79 | Some gaps (allergens, serving data)   | Score may shift as data improves |
| **Low**    | <50   | Major data gaps                       | Use with caution                 |

**Current distribution**: 493 high · 65 medium · 2 low

The 6 components of confidence: nutrition data (0-30), ingredient data (0-25), source quality (0-20), EAN coverage (0-10), allergen info (0-10), serving data (0-5). Computed by `compute_data_confidence()`.

### EAN Barcode Tracking

Products include EAN-8/EAN-13 barcodes (where available) for cross-source product matching:

**Coverage**: 558/560 active products (99.6%)

EAN codes enable validation against:
- Manufacturer product pages
- Government nutrition databases (IŻŻ/NCEZ)
- Retailer catalogs (Biedronka, Lidl, Żabka)
- Physical product packaging

### Source Provenance

All 560 products are sourced from the **Open Food Facts API** (`off_api`). Each product has a corresponding entry in the `product_sources` table with `source_type = 'off_api'`, source URL, EAN, confidence percentage, and collection timestamp.

**Research workflow**: See [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) for step-by-step data collection process.

---

## 🔗 Useful Links

| Resource                          | URL / Command                                               |
| --------------------------------- | ----------------------------------------------------------- |
| **Supabase Studio** (Database UI) | http://127.0.0.1:54323                                      |
| **Master View** (all data)        | `SELECT * FROM v_master ORDER BY unhealthiness_score DESC;` |
| **Top 10 unhealthiest**           | See [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md)   |
| **Scoring reference**             | [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md)       |
| **All queries & tests**           | [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md)       |

---

## 🚀 Development Workflow

1. **Add products** → Edit `db/pipelines/{category}/PIPELINE__{category}__01_insert_products.sql`
2. **Add nutrition** → Edit `db/pipelines/{category}/PIPELINE__{category}__03_add_nutrition.sql`
3. **Run pipelines** → `.\RUN_LOCAL.ps1 -Category {category} -RunQA`
4. **Verify** → Open Studio UI → Query `v_master`
5. **Test** → `.\RUN_QA.ps1` (should be 144/144 pass)
6. **Commit** → All pipelines are idempotent & version-controlled

---

## 📝 Ethical Positioning

- **Education over judgment** — Scores inform, they don't prescribe. "Lower concern" not "healthy."
- **Transparency over gamification** — Every number links to its source data and computation method.
- **Multi-axis over single-number** — No single score captures nutritional reality. We show 4 independent axes.
- **Confidence over certainty** — We tell you how reliable each score is. Incomplete data gets flagged, not hidden.
- **Category context over absolutes** — A score of 25 means different things in Candy vs. Water. We always show context.

## 📝 Notes

- **All data is local** — nothing is uploaded to remote Supabase (yet)
- **Pipelines are idempotent** — safe to run repeatedly
- **Data quality tracking** — All products have confidence levels (`estimated`, `verified`, or `low`)
- **EAN barcodes** — 558/560 active products (99.6%) have validated EAN-8/EAN-13 codes for cross-source matching
- **Primary source**: Open Food Facts — all products pending cross-validation
- **Scoring version**: v3.2 (2026-02-10)
- **560 active products** (28 per category × 20 categories), deprecated products periodically purged

---

## 📚 Documentation

- [API_CONTRACTS.md](docs/API_CONTRACTS.md) — API surface contracts (6 RPC endpoints + 3 views)
- [UX_UI_DESIGN.md](docs/UX_UI_DESIGN.md) — Production-ready UX spec (score disambiguation, API mapping, misinterpretation defense)
- [PERFORMANCE_REPORT.md](docs/PERFORMANCE_REPORT.md) — Performance audit & scale projections to 50K products
- [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) — How to view data, run tests, query the DB
- [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md) — Complete v3.2 algorithm specification
- [DATA_SOURCES.md](docs/DATA_SOURCES.md) — Multi-source data hierarchy & validation workflow
- [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) — Step-by-step data collection process
- [COUNTRY_EXPANSION_GUIDE.md](docs/COUNTRY_EXPANSION_GUIDE.md) — Future multi-country rules
- `copilot-instructions.md` — AI agent context & project rules

---

**Built with**: Supabase (PostgreSQL), Open Food Facts API, PowerShell automation
