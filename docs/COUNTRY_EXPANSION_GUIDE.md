# Country Expansion Guide

> **Last updated:** 2026-02-22
> **Current status:** Poland (`PL`) is fully active (1,025 products, 20 categories). Germany (`DE`) is active as a micro-pilot (51 chips products).
> **Technical blockers resolved.** See Section 2.5 for go/no-go checklist.

---

## 1. Expansion Philosophy

This project is designed for eventual EU-wide coverage, but expansion must be **methodical, not opportunistic**. Each country introduces:

- Different product formulations (same brand, different recipe)
- Different labeling regulations (mandatory vs. voluntary fields)
- Different retail landscapes (stores, private labels)
- Different Nutri-Score adoption status
- Different food safety authorities and additive rules

**Rule:** A country is never "partially" added. Either all prerequisites are complete and the country is fully operational, or it does not exist in the database.

---

## 2. Prerequisites for Adding a Country

Before any data for country `XX` enters the database, **all** of the following must be true:

### 2.1 Regulatory Research (Documentation)

- [ ] Document which EU regulations apply to food labeling in country `XX`
- [ ] Confirm whether Nutri-Score is mandatory, voluntary, or absent
- [ ] Identify the national food safety authority (equivalent of Poland's GIS/SANEPID)
- [ ] Document any country-specific additive restrictions beyond EU baseline
- [ ] Identify label language(s) and translation requirements

### 2.2 Retail Landscape (Documentation)

- [ ] Identify the top 5–10 retailers in country `XX` by market share
- [ ] Document which retailers have online product catalogs with nutrition data
- [ ] Identify major private-label brands and their ownership
- [ ] Confirm per-100g labeling convention (vs. per-serving in non-EU contexts)

### 2.3 Data Sources (Verification)

- [ ] Confirm Open Food Facts coverage for country `XX` (number of verified products)
- [ ] Identify at least one reliable primary source for label data
- [ ] Test data collection workflow on 5–10 products before committing

### 2.4 Technical Setup (Implementation)

- [x] Create pipeline folder: `db/pipelines/<country_lower>/` or `db/pipelines/<category>_<country>/`
- [x] Verify that the `products(country, brand, product_name)` unique constraint handles the new country
- [x] Confirm that all schemas support the new country's data without migration changes
- [ ] Create `RUN_LOCAL.ps1` / `RUN_REMOTE.ps1` entries for the new pipelines
- [ ] Update `copilot-instructions.md` to list the new country as active

### 2.5 Country Expansion Readiness (Go/No-Go Bar)

All of these must be true before activating a second country:

- [x] API supports country filtering on search + listings (`p_country` param, RPC-compatible)
- [x] Auto-country resolution when `p_country` is NULL (`resolve_effective_country` — user pref → system default)
- [x] Alternatives/similarity are country-isolated (inferred from source product)
- [x] Scoring + completeness are country-parameterized (`score_category` accepts `p_country`)
- [x] Dashboard stats are country-aware (`v_api_category_overview_by_country` view)
- [x] Activation gating exists (`country_ref.is_active` enforced by QA)
- [x] `sql_generator.py` accepts `country` parameter (no more hardcoded `'PL'`)
- [x] QA checks for cross-country leakage (api_surfaces #16, #17, #18)
- [ ] Pilot country with 5–10 products: all QA passes, no cross-country leakage

---

## 3. Country Isolation Rules

### 3.1 Data Isolation

Every row in the `products` table carries a `country` column. This is the **primary isolation mechanism**.

```sql
-- All pipeline queries MUST filter by country
WHERE p.country = 'XX'
```

- Products from different countries are **never mixed** in a single pipeline file.
- A product sold in both Poland and Germany is entered as **two separate rows** with `country = 'PL'` and `country = 'DE'`, because formulations differ.
- Scores are computed per-country, never averaged across countries.

### 3.2 Pipeline Isolation

Each country's pipelines are independent:

```
db/pipelines/
├── chips/                  # PL chips (current)
├── zabka/                  # PL Żabka store (current)
├── chips_de/               # DE chips (future example)
└── rewe/                   # DE REWE store (future example)
```

**Naming convention options** — **decided: use category + country suffix for multi-country**:

| Strategy           | Example           | When to use                         | Status      |
| ------------------ | ----------------- | ----------------------------------- | ----------- |
| Category-only      | `chips/`          | Single-country (current PL)         | **Current** |
| Category + country | `chips_de/`       | When 2nd country adds same category | **Adopted** |
| Store-based        | `zabka/`, `rewe/` | Country-specific store chains       | **Adopted** |

**Transition rule:** When a second country is added for an existing category:
1. Rename the PL folder: `chips/` → `chips_pl/` (update `RUN_*.ps1` accordingly)
2. Create the new country folder: `chips_de/`
3. Both folders now follow the `<category>_<country>` pattern
4. **Do NOT rename until the second country is actually added** — premature renaming breaks the current working pipeline

### 3.3 No Cross-Country Scoring

- Unhealthiness Scores are **not comparable** across countries because:
  - Formulations differ (same brand/product, different recipe)
  - Serving conventions may differ
  - Regulatory thresholds (salt, sugar flags) may need country adjustment
- The `v_master` view operates globally but should be filtered by `country` in all queries.

---

## 4. Store Differences Across Countries

| Aspect                | Poland (PL)            | Germany (DE) — Example       |
| --------------------- | ---------------------- | ---------------------------- |
| Discount leaders      | Biedronka, Lidl        | Aldi, Lidl                   |
| Convenience           | Żabka                  | REWE To Go, Aral             |
| Hypermarkets          | Auchan, Carrefour      | Kaufland, Real               |
| Private label density | High (Biedronka, Lidl) | Very high (Aldi, Lidl, REWE) |
| Nutri-Score adoption  | Voluntary              | Voluntary (widely used)      |
| Label language        | Polish                 | German                       |

**Implication:** Store-based pipelines (like `zabka/`) are **country-specific by definition** and cannot be reused across countries. Category-based pipelines (like `chips/`) can serve as **templates** but must be duplicated and customized.

---

## 5. Pipeline Duplication Rules

When expanding to a new country, follow this process:

### Step 1: Copy the Reference Pipeline

```powershell
# Example: Adding German chips
Copy-Item -Recurse db/pipelines/chips db/pipelines/chips_de
```

### Step 2: Rename All Files

```
PIPELINE__chips_de__01_insert_products.sql
PIPELINE__chips_de__03_add_nutrition.sql
PIPELINE__chips_de__04_scoring.sql
PIPELINE__chips_de__05_source_provenance.sql
```

### Step 3: Update All Queries

In every file, change:
- `country = 'PL'` → `country = 'DE'`
- `category = 'Chips'` remains `'Chips'` (categories are language-neutral)
- Product names → German market SKUs
- Brand names → German market variants
- Store availability → German retailers
- Nutrition values → German label values

### Step 4: Add to Run Scripts

Update `RUN_LOCAL.ps1` and `RUN_REMOTE.ps1` to include the new pipeline folder.

### Step 5: Test Locally

Run the new pipeline against local Supabase. Verify:
- [ ] All products insert with `country = 'DE'`
- [ ] No conflict with existing PL products
- [ ] Scores compute correctly
- [ ] `v_master` view returns both PL and DE rows

---

## 6. Schema Considerations

The current schema is **country-agnostic by design**:

- `products.country` — discriminator column, part of the unique constraint
- `products` — stores scores, flags, confidence, and source provenance inline (`source_type`, `source_url`, `source_ean`)
- `nutrition_facts` — linked by `product_id`, inheriting country from the product
- `product_allergen_info` — linked by `product_id` for contains/traces declarations

### Potential Future Schema Changes

These changes are **not needed now** but may be required during expansion:

| Change                                                  | Trigger                                                        |
| ------------------------------------------------------- | -------------------------------------------------------------- |
| Add `country` to source reference table (if introduced) | Only if multi-source lineage is normalized to a separate table |
| Add `currency` column for price data                    | If price tracking is ever added (out of scope)                 |
| Add `regulation_ref` to `products`                      | To cite country-specific labeling regulations                  |
| Separate schema per country                             | Only if dataset exceeds millions of rows                       |

**Rule:** Any schema change requires a new Supabase migration. Never modify existing migrations.

---

## 7. Regulatory Differences to Watch

| Regulation area             | Varies by country? | Impact on scoring                 |
| --------------------------- | ------------------ | --------------------------------- |
| Mandatory nutrition fields  | Slightly           | Core 7 fields are EU-wide         |
| Nutri-Score adoption        | Yes                | Affects data availability         |
| Traffic light labeling (UK) | Post-Brexit only   | Not applicable in EU              |
| Additive restrictions       | Rarely             | Some national bans beyond EU list |
| Organic certification marks | Yes                | Different national logos          |
| Allergen labeling format    | Slightly           | Bolding vs. separate list         |
| Trans fat declaration       | Voluntary in EU    | May become mandatory              |

---

## 8. Expansion Roadmap (Indicative)

This is a **suggested** order based on data availability, market size, and Nutri-Score adoption:

| Phase | Country | Code | Rationale                                          | Status                             |
| ----- | ------- | ---- | -------------------------------------------------- | ---------------------------------- |
| 1     | Poland  | PL   | Founder's market; full access to labels            | **Active**                         |
| 2     | Germany | DE   | Largest EU market; strong Open Food Facts coverage | **Active** (micro-pilot: 51 chips) |
| 3     | France  | FR   | Nutri-Score origin country; best data quality      | Planned                            |
| 4     | Spain   | ES   | Large market; growing Nutri-Score adoption         | Future                             |
| 5     | Italy   | IT   | Complex food landscape; controversial with NS      | Future                             |
| 6     | Czechia | CZ   | Regional neighbor; similar retail landscape to PL  | Future                             |

**This roadmap is non-binding.** Expansion happens only when prerequisites in Section 2 are fully met.

---

## 9. What NOT to Do During Expansion

- ❌ Do NOT add a country "just to test" — even test data pollutes the schema
- ❌ Do NOT share pipeline files between countries — always duplicate and customize
- ❌ Do NOT assume same brand = same product across countries
- ❌ Do NOT compare Unhealthiness Scores across countries without methodology review
- ❌ Do NOT modify Polish pipelines to accommodate another country's needs
- ❌ Do NOT use non-EU data sources (USDA, etc.) for EU country products
- ❌ Do NOT add a country if Open Food Facts has < 100 verified products for it

---

## 10. Search Configuration for New Countries (#192)

When adding a new country, configure search infrastructure:

### Step 1: Add Language (if not present)

```sql
INSERT INTO language_ref (code, name_en, name_native, sort_order)
VALUES ('xx', 'Language', 'Native Name', 10)
ON CONFLICT (code) DO NOTHING;
```

### Step 2: Update `build_search_vector()`

Add a WHEN clause to the country CASE in `build_search_vector()`:

```sql
WHEN 'XX' THEN 'config_name'::regconfig
```

Available built-in configs: `simple`, `english`, `german`, `french`, `italian`,
`spanish`, `dutch`, `danish`, `swedish`, `norwegian`, `finnish`, `russian`.

### Step 3: Add Synonym Pairs

Insert bidirectional synonym pairs for common food terms:

```sql
INSERT INTO search_synonyms (term_original, term_target, language_from, language_to)
VALUES
    ('local_term', 'english_term', 'xx', 'en'),
    ('english_term', 'local_term', 'en', 'xx');
```

Aim for 40–50 bidirectional pairs covering common food categories.

### Step 4: Backfill Search Vectors

```sql
UPDATE products
SET search_vector = build_search_vector(
    product_name, product_name_en, brand, category, country
)
WHERE country = 'XX';
```

### Step 5: Verify

Run `db/qa/QA__search_architecture.sql` to confirm all tests pass.
