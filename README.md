# Poland Food Quality Database

A **world-class** food quality database scoring products sold in Poland using a 9-factor weighted algorithm (v3.2) based on nutritional science and EU regulatory guidelines.

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
# All tests (61 checks)
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
**Test Coverage**: 61 automated checks + 12 data quality reports
- 32 data integrity checks (nulls, orphans, foreign keys, duplicates, nutrition sanity, category invariant, view consistency, energy cross-check) + 4 informational
- 29 scoring formula validation checks (ranges, flags, NOVA, domain validation, confidence, regression tests)
- 8 source coverage & confidence tracking reports (informational, non-blocking)

**All critical tests passing**: ✅ 61/61

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
│   │   ├── QA__null_checks.sql           # 32 integrity checks
│   │   ├── QA__scoring_formula_tests.sql # 29 algorithm tests
    │   └── QA__source_coverage.sql       # 8 data quality reports
│   └── views/               # Denormalized reporting views
│       └── VIEW__master_product_view.sql # Flat API view with provenance
├── supabase/
│   ├── config.toml          # Local Supabase configuration
    └── migrations/          # Schema migrations (30 files)
├── docs/                    # Project documentation
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

Every change is validated against **61 automated checks** + 12 informational data quality reports:

### Data Integrity (32 checks)
- No missing required fields (product_name, brand, country, category)
- No orphaned foreign keys (nutrition, scores, servings, ingredients)
- No duplicate products
- All active products have servings, nutrition, scores, and ingredient rows
- Nutrition sanity (no negative values, sat_fat ≤ total_fat, sugars ≤ carbs, calories ≤ 900)
- Category invariant (exactly 28 products per active category)
- Score fields not null for active products
- View consistency (v_master row count matches products)

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

**Test files**: `db/qa/QA__*.sql` — Run via `.\RUN_QA.ps1`

Run tests after **every** schema change or data update.

### Database Constraints

19 CHECK constraints enforce domain rules at the database level:

| Table           | Constraint                       | Rule                                 |
| --------------- | -------------------------------- | ------------------------------------ |
| products        | `chk_products_country`           | country IN ('PL')                    |
| products        | `chk_products_prep_method`       | Valid prep method or null            |
| products        | `chk_products_controversies`     | controversies IN ('none','palm oil') |
| scores          | `chk_scores_unhealthiness_range` | 1–100                                |
| scores          | `chk_scores_nutri_label`         | A–E, UNKNOWN, or NOT-APPLICABLE    |
| scores          | `chk_scores_confidence`          | verified / estimated / low           |
| scores          | `chk_scores_nova`                | 1–4                                  |
| scores          | `chk_scores_processing_risk`     | Low / Moderate / High                |
| scores          | `chk_scores_*_flag`              | YES / NO (4 flags)                   |
| scores          | `chk_scores_completeness`        | 0–100                                |
| nutrition_facts | `chk_nf_non_negative` (7 cols)   | ≥ 0                                  |
| nutrition_facts | `chk_nf_sat_fat_le_total`        | saturated_fat ≤ total_fat            |
| nutrition_facts | `chk_nf_sugars_le_carbs`         | sugars ≤ carbs                       |
| servings        | `chk_servings_basis`             | 'per 100 g' or 'per serving'         |
| servings        | `chk_servings_amount_positive`   | amount > 0                           |
| ingredients     | `chk_ingredients_additives`      | additives_count ≥ 0                  |

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

Every product receives an automated confidence rating based on data completeness and source verification:

| Confidence    | Criteria                               | Meaning                                 |
| ------------- | -------------------------------------- | --------------------------------------- |
| **verified**  | ≥90% complete + ≥2 independent sources | Cross-validated across multiple sources |
| **estimated** | 70-89% complete OR single source       | Single-source data needing verification |
| **low**       | <70% complete                          | Incomplete data, use with caution       |

**Current status**: 493 `verified` (≥90% data completeness) · 67 `estimated` · 0 `low`.

Confidence is auto-computed by the `assign_confidence()` function in all scoring pipelines.

### EAN Barcode Tracking

Products include EAN-8/EAN-13 barcodes (where available) for cross-source product matching:

**Coverage**: 558/560 active products (99.6%)

EAN codes enable validation against:
- Manufacturer product pages
- Government nutrition databases (IŻŻ/NCEZ)
- Retailer catalogs (Biedronka, Lidl, Żabka)
- Physical product packaging

### Multi-Source Workflow

**Current sources**:
- Primary: Open Food Facts (openfoodfacts.org) — 560/560 active products
- Secondary: None yet — all products pending cross-validation

**Planned sources** (see [DATA_SOURCES.md](docs/DATA_SOURCES.md)):
1. Physical product labels (highest priority)
2. Manufacturer websites
3. Polish government databases (IŻŻ, NCEZ)
4. Scientific literature (NOVA classification, Nutri-Score papers)
5. Retailer websites

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
5. **Test** → `.\RUN_QA.ps1` (should be 61/61 pass)
6. **Commit** → All pipelines are idempotent & version-controlled

---

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

- [VIEWING_AND_TESTING.md](docs/VIEWING_AND_TESTING.md) — How to view data, run tests, query the DB
- [SCORING_METHODOLOGY.md](docs/SCORING_METHODOLOGY.md) — Complete v3.2 algorithm specification
- [DATA_SOURCES.md](docs/DATA_SOURCES.md) — Multi-source data hierarchy & validation workflow
- [RESEARCH_WORKFLOW.md](docs/RESEARCH_WORKFLOW.md) — Step-by-step data collection process
- [COUNTRY_EXPANSION_GUIDE.md](docs/COUNTRY_EXPANSION_GUIDE.md) — Future multi-country rules
- `copilot-instructions.md` — AI agent context & project rules

---

**Built with**: Supabase (PostgreSQL), Open Food Facts API, PowerShell automation
