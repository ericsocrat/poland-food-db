# Poland Food Quality Database

A **world-class** food quality database scoring products sold in Poland using an 8-factor weighted algorithm (v3.1) based on nutritional science and EU regulatory guidelines.

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
- **Command-line**: See [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md) for queries

### 4. Run Tests
```powershell
# All tests (33 checks)
.\RUN_QA.ps1

# Or via pipeline runner
.\RUN_LOCAL.ps1 -RunQA
```

---

## 📊 Current Status

**Database**: 446 active products across 16 categories

| Category             | Products | Brands                                                                                                                                  | Score Range |
| -------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| **Chips**            | 28       | 7 (Lay's, Pringles, Crunchips, Doritos, Cheetos, Top Chips, Snack Day)                                                                  | 27–51       |
| **Żabka**            | 28       | 3 (Żabka, Tomcio Paluch, Szamamm)                                                                                                       | 15–43       |
| **Cereals**          | 28       | 9 (Nestlé, Nesquik, Sante, Vitanella, Crownfield, Melvit, Lubella, Kupiec, Kellogg's)                                                   | 11–49       |
| **Drinks**           | 28       | 16 (Coca-Cola, Pepsi, Fanta, Sprite, Tymbark, Hortex, Tiger, Red Bull, Monster, 4Move, Cappy, Dawtona, Mlekovita, Łaciate, Kubś, Costa) | 7–22        |
| **Dairy**            | 28       | 13 (Mlekovita, Łaciate, Danone, Zott, Piątnica, Hochland, Bakoma, Danio, Sierpc, Président, Philadelphia, Müller, Mlekpol)              | 9–48        |
| **Bread**            | 28       | 7 (Oskroba, Mestemacher, Schulstad, Klara, Wasa, Sonko, Pano, Tastino, Carrefour)                                                       | 15–30       |
| **Meat**             | 28       | 10 (Tarczyński, Berlinki, Sokołów, Krakus, Morliny, Madej Wróbel, Drosed, Indykpol, Plukon)                                             | 21–56       |
| **Sweets**           | 28       |                                                                                                                                         | 32–55       |
| **Instant & Frozen** | 28       |                                                                                                                                         | 13–30       |
| **Sauces**           | 28       |                                                                                                                                         | 8–41        |
| **Baby**             | 28       |                                                                                                                                         | 8–36        |
| **Alcohol**          | 28       |                                                                                                                                         | 5–11        |
| **Frozen & Prepared**| 28       | 11 (Dr. Oetker, Morey, Nowaco, Obiad, Mroźnia, Bonduelle, Makaronika, TVLine, Żabka Frost, Kulina, Berryland)                             | 42–64       |
| **Plant-Based & Alternatives** | 27 | 11 (Alpro, Garden Gourmet, Violife, Taifun, LikeMeat, Sojasun, Kupiec, Beyond Meat, Naturalnie, Simply V, Green Legend)                 | TBD         || **Nuts, Seeds & Legumes** | 27 | 7 (Alesto, Bakalland, Fasting, Sante, Targroch, Helio, Naturavena, Społem)                                                       | TBD         |
**Test Coverage**: 31 automated checks + 7 data quality reports
- 11 data integrity checks (nulls, foreign keys, duplicates)
- 20 scoring formula validation checks (ranges, flags, NOVA, regression)
- 7 source coverage & confidence tracking reports (informational, non-blocking)

**All critical tests passing**: ✅ 31/31

---

## 🏗️ Project Structure

```
poland-food-db/
├── db/
│   ├── migrations/          # Supabase schema migrations
│   ├── pipelines/           # Category-specific data pipelines
│   │   ├── bread/           # 28 bread products (4 SQL files)
│   │   ├── breakfast/       # 28 breakfast & grain-based products (4 SQL files)
│   │   ├── cereals/         # 28 cereal products (4 SQL files)
│   │   ├── chips/           # 28 chip products (5 SQL files)
│   │   ├── dairy/           # 28 dairy products (4 SQL files)
│   │   ├── drinks/          # 28 beverage products (4 SQL files)
│   │   ├── frozen/          # 28 frozen & prepared products (4 SQL files)
│   │   ├── instant/          # 28 instant & frozen products (4 SQL files)
│   │   ├── meat/            # 28 meat & deli products (4 SQL files)
│   │   ├── nuts-seeds/      # 27 nuts, seeds & legumes products (4 SQL files)
│   │   ├── plant-based/     # 27 plant-based & alternative products (4 SQL files)
│   │   ├── sauces/          # 28 sauces & condiments products (4 SQL files)
│   │   ├── sweets/          # 28 sweets & chocolate products (4 SQL files)
│   │   └── zabka/           # 28 convenience store products (5 SQL files)
│   ├── qa/                  # Quality assurance test suites
│   │   ├── QA__null_checks.sql           # 11 integrity checks
│   │   ├── QA__scoring_formula_tests.sql # 20 algorithm tests
│   │   └── QA__source_coverage.sql       # 7 data quality reports
│   └── views/               # Denormalized reporting views
│       └── VIEW__master_product_view.sql # Flat API view with provenance
├── supabase/
│   ├── config.toml          # Local Supabase configuration
│   └── migrations/          # Baseline schema (3 files)
├── extract_eans.py          # EAN barcode extraction script (generates migration SQL)
├── RUN_LOCAL.ps1            # Pipeline runner (idempotent)
├── RUN_QA.ps1               # Standalone test runner
├── VIEWING_AND_TESTING.md   # Full viewing & testing guide
├── DATA_SOURCES.md          # Multi-source data hierarchy & validation workflow
├── RESEARCH_WORKFLOW.md     # Step-by-step data collection process
└── SCORING_METHODOLOGY.md   # v3.1 algorithm documentation (421 lines)
```

---

## 🧪 Testing Philosophy

Every change is validated against **31 automated checks** + 7 informational data quality reports:

### Data Integrity (11 checks)
- No missing required fields
- No orphaned foreign keys
- No duplicate products
- All active products have servings
- All active products have nutrition data
- All active products have scores
- All active products have ingredient rows

### Scoring Formula (20 checks)
- Scores in valid range [1, 100]
- Clean products score ≤ 20
- Maximum unhealthy products score high
- Identical nutrition → identical scores
- Flag logic (salt ≥1.5g, sugar ≥5g, sat fat ≥5g)
- NOVA classification valid (1–4)
- Processing risk alignment with NOVA
- Scoring version = v3.1
- **Regression**: Top Chips Faliste = 51±2 (palm oil)
- **Regression**: Naleśniki = 17±2 (healthiest Żabka)
- **Regression**: Melvit Płatki Owsiane = 11±2 (healthiest cereal)
- **Regression**: Coca-Cola Zero = 8±2 (lowest-scoring drink)
- **Regression**: Piątnica Skyr Naturalny = 9±2 (healthiest dairy)
- **Regression**: Mestemacher Pumpernikiel = 17±2 (traditional rye)
- **Tarczyński Kabanosy Klasyczne = 55±2 (high-fat cured meat)
- **Regression**: Knorr Nudle Pomidorowe Pikantne = 21±2 (instant noodle, palm oil)

### Source Coverage (7 informational reports)
- Products without source metadata
- Single-source products needing cross-validation
- High-impact products (score >40, single-source)
- EAN coverage by category
- Confidence level distribution

**Test files**: `db/qa/QA__*.sql` — Run via `.\RUN_QA.ps1`

Run tests after **every** schema change or data update.

---

## 📈 Scoring Methodology

### v3.1 Formula (8 factors)

Implemented as a reusable PostgreSQL function `compute_unhealthiness_v31()` — all category pipelines call this single function.

```
unhealthiness_score =
  sat_fat(0.18) + sugars(0.18) + salt(0.18) + calories(0.10) +
  trans_fat(0.12) + additives(0.07) + prep_method(0.09) + controversies(0.08)
```

**Score Bands**:
- **1–20**: Low risk
- **21–40**: Moderate risk
- **41–60**: Elevated risk
- **61–80**: High risk
- **81–100**: Very high risk

**Ceilings** (per 100g): sat fat 10g, sugars 27g, salt 3g, trans fat 2g, calories 600 kcal, additives 10

Full documentation: [SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md)

---

## 🔍 Data Quality & Provenance

### Confidence Levels

Every product receives an automated confidence rating based on data completeness and source verification:

| Confidence    | Criteria                               | Meaning                                 |
| ------------- | -------------------------------------- | --------------------------------------- |
| **verified**  | ≥90% complete + ≥2 independent sources | Cross-validated across multiple sources |
| **estimated** | 70-89% complete OR single source       | Single-source data needing verification |
| **low**       | <70% complete                          | Incomplete data, use with caution       |

**Current status**: All 446 products are `estimated` (single-source Open Food Facts data awaiting cross-validation).

Confidence is auto-computed by the `assign_confidence()` function in all scoring pipelines.

### EAN Barcode Tracking

Products include EAN-13 barcodes (where available) for cross-source product matching:

**Coverage**: 133/336 products (39.6%)
- ✅ **100%**: Baby (28), Żabka (28), Drinks (28), Cereals (28)
- ⚠️ **75%**: Chips (21/28)
- ❌ **0%**: Sweets, Bread, Instant, Alcohol, Sauces, Dairy, Meat

EAN codes enable validation against:
- Manufacturer product pages
- Government nutrition databases (IŻŻ/NCEZ)
- Retailer catalogs (Biedronka, Lidl, Żabka)
- Physical product packaging

### Multi-Source Workflow

**Current sources**:
- Primary: Open Food Facts (openfoodfacts.org) — 336/336 products
- Secondary: None yet — all products pending cross-validation

**Planned sources** (see [DATA_SOURCES.md](DATA_SOURCES.md)):
1. Physical product labels (highest priority)
2. Manufacturer websites
3. Polish government databases (IŻŻ, NCEZ)
4. Scientific literature (NOVA classification, Nutri-Score papers)
5. Retailer websites

**Research workflow**: See [RESEARCH_WORKFLOW.md](RESEARCH_WORKFLOW.md) for step-by-step data collection process.

---

## 🔗 Useful Links

| Resource                          | URL / Command                                                    |
| --------------------------------- | ---------------------------------------------------------------- |
| **Supabase Studio** (Database UI) | http://127.0.0.1:54323                                           |
| **Master View** (all data)        | `SELECT * FROM v_master ORDER BY unhealthiness_score::int DESC;` |
| **Top 10 unhealthiest**           | See [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md)             |
| **Scoring reference**             | [SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md)                 |
| **All queries & tests**           | [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md)                 |

---

## 🚀 Development Workflow

1. **Add products** → Edit `db/pipelines/{category}/PIPELINE__{category}__01_insert_products.sql`
2. **Add nutrition** → Edit `db/pipelines/{category}/PIPELINE__{category}__03_add_nutrition.sql`
3. **Run pipelines** → `.\RUN_LOCAL.ps1 -Category {category} -RunQA`
4. **Verify** → Open Studio UI → Query `v_master`
5. **Test** → `.\RUN_QA.ps1` (should be 33/33 pass)
6. **Commit** → All pipelines are idempotent & version-controlled

---

## 📝 Notes

- **All data is local** — nothing is uploaded to remote Supabase (yet)
- **Pipelines are idempotent** — safe to run repeatedly
- **Data quality tracking** — All products have confidence levels (`estimated`, `verified`, or `low`)
- **EAN barcodes** — 133/336 products (39.6%) have EAN-13 codes for cross-source matching
- **Primary source**: Open Food Facts — all products pending cross-validation
- **Scoring version**: v3.1 (2026-02-07)
- **446 active products** (across 16 categories), 44 deprecated (kept in DB for historical tracking)

---

## 📚 Documentation

- [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md) — How to view data, run tests, query the DB
- [SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md) — Complete v3.1 algorithm specification (421 lines)
- `copilot-instructions.md` — AI agent context & project rules

---

**Built with**: Supabase (PostgreSQL), Open Food Facts API, PowerShell automation
