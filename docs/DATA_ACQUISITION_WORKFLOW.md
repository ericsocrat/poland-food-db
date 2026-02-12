# Data Acquisition Workflow

> **Last updated:** 2026-02-13
> **Purpose:** Step-by-step guide for adding products using the automated OFF fetcher
> **Related:** `RESEARCH_WORKFLOW.md` (manual workflow), `DATA_SOURCES.md` (source hierarchy)

---

## 1. Overview

The automated pipeline uses Open Food Facts (OFF) as the data source and generates
the 4-step pipeline SQL files that match the project's exact idempotent patterns.

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────┐
│ Discover    │───>│ Fetch from   │───>│ Generate     │───>│ Run       │
│ EANs        │    │ OFF API      │    │ pipeline SQL │    │ pipeline  │
└─────────────┘    └──────────────┘    └──────────────┘    └───────────┘
        │                                                       │
        │   ┌──────────────┐    ┌──────────────┐                │
        └──>│ Enrich       │───>│ Validate     │<───────────────┘
            │ ingredients  │    │ (QA checks)  │
            └──────────────┘    └──────────────┘
```

**Two acquisition modes:**

| Mode | Flag | Best for | Reliability |
|------|------|----------|-------------|
| EAN list | `--eans` / `--ean-file` | Known Polish products | High — per-product API lookup |
| OFF search | `--off-search` | Discovery of new products | Medium — sparse country tagging |

---

## 2. Prerequisites

- Python 3.12+ with `requests` installed (`pip install requests`)
- Docker running with `supabase_db_poland-food-db` container
- Virtual environment activated (`.venv`)

---

## 3. Step-by-Step Workflow

### Step 1: Discover EANs

Collect EAN barcodes from any of these sources:

| Source | Method |
|--------|--------|
| Store visit | Scan barcodes with a phone app |
| Retailer website | Biedronka.pl, Lidl.pl, Auchan.pl product pages |
| OFF website | Browse `world.openfoodfacts.org/cgi/search.pl` |
| Existing CSV/spreadsheet | Export from any product database |

Save EANs to a text file (one per line):

```
# eans/chips_new.txt
# Polish chips EANs — 2026-02-13
5900073020262
5905187114760
5900259128188
```

### Step 2: Preview with Dry Run

Always preview before generating SQL:

```powershell
python fetch_off_category.py `
    --country PL `
    --category Chips `
    --ean-file eans/chips_new.txt `
    --dry-run
```

Check the output for:
- ✅ All EANs found on OFF
- ✅ Brand names look correct (first brand used when multiple)
- ✅ Nutri-Score and NOVA available
- ✅ Nutrition data present

### Step 3: Generate Pipeline SQL

```powershell
python fetch_off_category.py `
    --country PL `
    --category Chips `
    --ean-file eans/chips_new.txt
```

This creates/updates 4 files in `db/pipelines/<category>/`:

| File | Purpose |
|------|---------|
| `PIPELINE__<cat>__01_insert_products.sql` | Product upsert with deprecation |
| `PIPELINE__<cat>__03_add_nutrition.sql` | Nutrition facts insert |
| `PIPELINE__<cat>__04_scoring.sql` | Nutri-Score + NOVA + `score_category()` |
| `PIPELINE__<cat>__05_source_provenance.sql` | Source tracking (OFF API) |

> **Important:** Review the generated SQL before running. Check brand names,
> product names (Polish characters), and nutrition values for reasonableness.

### Step 4: Run the Pipeline

```powershell
.\RUN_LOCAL.ps1 -Category <folder_name>
```

This executes the 4 SQL files in order against the local database.

### Step 5: Enrich Ingredients

```powershell
python enrich_ingredients.py
```

This fetches ingredient lists and allergen data from OFF for products
that don't have them yet.

### Step 6: Validate with QA

```powershell
.\RUN_QA.ps1
```

All checks must pass. Current suite: 263 checks across 17 suites.

---

## 4. Discovery Mode (OFF Search)

When you don't have specific EANs, use OFF search to discover products:

```powershell
python fetch_off_category.py `
    --country PL `
    --category Sauces `
    --off-search "en:sauces" `
    --limit 50 `
    --dry-run
```

**Limitations:**
- OFF country tagging is sparse for Poland — many products lack `countries_tags`
- Client-side filtering by EAN prefix (590x) and country tags is applied
- May return fewer products than `--limit` due to filtering
- Best used as a **supplement** to EAN-list mode, not as primary

### Combined Mode

```powershell
python fetch_off_category.py `
    --country PL `
    --category Chips `
    --ean-file eans/chips_new.txt `
    --off-search "en:chips" `
    --limit 50
```

Products from both sources are merged and deduplicated by EAN.

---

## 5. Adding a New Category

When creating a pipeline for a category that doesn't exist yet:

1. **Register the category** in `category_ref` via a migration
2. **Collect EANs** from stores or retailer websites
3. **Run the fetcher** to generate pipeline SQL
4. **Review and adjust** product types and prep methods in the generated SQL
5. **Run the pipeline** and validate with QA
6. **Run the pipeline structure guard** to verify the new folder:
   ```powershell
   python check_pipeline_structure.py
   ```

---

## 6. Adding a New Country

1. Verify the country code is in `COUNTRY_TAGS` (`fetch_off_category.py`)
2. Know the EAN prefix for that country (e.g., 400-440 = Germany)
3. Use `--country XX` flag — the fetcher handles the rest
4. See `docs/COUNTRY_EXPANSION_GUIDE.md` for full country expansion steps

---

## 7. Troubleshooting

| Problem | Solution |
|---------|----------|
| EAN not found on OFF | Product may not be in OFF database — add manually with `RESEARCH_WORKFLOW.md` |
| Wrong brand name | OFF splits brands by comma — first brand is used. Edit SQL manually if needed |
| Missing Nutri-Score | Scored as `UNKNOWN` — run `score_category()` to compute from nutrition data |
| Pipeline structure guard fails | Check that all 4 required files exist with correct naming pattern |
| `--off-search` returns 0 results | Try different category tags (e.g., `en:crisps` vs `en:chips`), or use EAN mode |

---

## 8. File Reference

| File | Purpose |
|------|---------|
| `fetch_off_category.py` | OFF product fetcher + SQL generator |
| `check_pipeline_structure.py` | CI guard for pipeline folder structure |
| `enrich_ingredients.py` | Ingredient/allergen enrichment from OFF |
| `RUN_LOCAL.ps1` | Pipeline runner (`-Category`, `-DryRun`, `-RunQA`) |
| `RUN_QA.ps1` | Full QA suite runner |
