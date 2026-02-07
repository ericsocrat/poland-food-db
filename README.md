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
# All tests (25 checks)
.\RUN_QA.ps1

# Or via pipeline runner
.\RUN_LOCAL.ps1 -RunQA
```

---

## 📊 Current Status

**Database**: 64 active products across 4 categories

| Category    | Products | Brands                                                                                 | Score Range |
| ----------- | -------- | -------------------------------------------------------------------------------------- | ----------- |
| **Chips**   | 16       | 7 (Lay's, Pringles, Crunchips, Doritos, Cheetos, Top Chips, Snack Day)                 | 27–51       |
| **Żabka**   | 16       | 3 (Żabka, Tomcio Paluch, Szamamm)                                                      | 17–43       |
| **Cereals** | 16       | 7 (Nestlé, Nesquik, Sante, Vitanella, Crownfield, Melvit, Lubella)                     | 11–49       |
| **Drinks**  | 16       | 10 (Coca-Cola, Pepsi, Fanta, Tymbark, Hortex, Tiger, 4Move, Cappy, Dawtona, Mlekovita) | 8–19        |

**Test Coverage**: 25 automated checks
- 11 data integrity checks (nulls, foreign keys, duplicates)
- 14 scoring formula validation checks (ranges, flags, NOVA, regression)

**All tests passing**: ✅ 25/25

---

## 🏗️ Project Structure

```
poland-food-db/
├── db/
│   ├── migrations/          # Supabase schema migrations
│   ├── pipelines/           # Category-specific data pipelines
│   │   ├── chips/           # 16 chip products (5 SQL files)
│   │   ├── zabka/           # 16 convenience store products (5 SQL files)
│   │   ├── cereals/         # 16 cereal products (4 SQL files)
│   │   └── drinks/          # 16 beverage products (4 SQL files)
│   ├── qa/                  # Quality assurance test suites
│   │   ├── QA__null_checks.sql           # 11 integrity checks
│   │   └── QA__scoring_formula_tests.sql # 12 algorithm tests
│   └── views/               # Denormalized reporting views
│       └── VIEW__master_product_view.sql
├── supabase/
│   ├── config.toml          # Local Supabase configuration
│   └── migrations/          # Baseline schema (3 files)
├── RUN_LOCAL.ps1            # Pipeline runner (idempotent)
├── RUN_QA.ps1               # Standalone test runner
├── VIEWING_AND_TESTING.md   # Full viewing & testing guide
└── SCORING_METHODOLOGY.md   # v3.1 algorithm documentation (421 lines)
```

---

## 🧪 Testing Philosophy

Every change is validated against **25 automated checks**:

### Data Integrity (11 checks)
- No missing required fields
- No orphaned foreign keys
- No duplicate products
- All active products have servings
- All active products have nutrition data
- All active products have scores
- All active products have ingredient rows

### Scoring Formula (14 checks)
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

Run tests after **every** schema change or data update.

---

## 📈 Scoring Methodology

### v3.1 Formula (8 factors)

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
5. **Test** → `.\RUN_QA.ps1` (should be 25/25 pass)
6. **Commit** → All pipelines are idempotent & version-controlled

---

## 📝 Notes

- **All data is local** — nothing is uploaded to remote Supabase (yet)
- **Pipelines are idempotent** — safe to run repeatedly
- **Data sourced from Open Food Facts** — EANs verified against Polish market
- **Scoring version**: v3.1 (2026-02-07)
- **64 active products**, 17 deprecated (removed from pipelines but kept in DB)

---

## 📚 Documentation

- [VIEWING_AND_TESTING.md](VIEWING_AND_TESTING.md) — How to view data, run tests, query the DB
- [SCORING_METHODOLOGY.md](SCORING_METHODOLOGY.md) — Complete v3.1 algorithm specification (421 lines)
- `copilot-instructions.md` — AI agent context & project rules

---

**Built with**: Supabase (PostgreSQL), Open Food Facts API, PowerShell automation
