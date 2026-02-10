# Data Sources

> **Last updated:** 2026-02-10
> **Scope:** Poland (`PL`) only
> **Related:** See `RESEARCH_WORKFLOW.md` for the full step-by-step data collection process,
> and `SCORING_METHODOLOGY.md` for how collected data is scored.

---

## 1. Source Priority Hierarchy

When collecting nutrition and product data for a Polish product, use sources in this strict order:

| Priority | Source                                 | Type      | Confidence  | Notes                                                |
| -------- | -------------------------------------- | --------- | ----------- | ---------------------------------------------------- |
| **1**    | Physical product label (PL market)     | Primary   | `verified`  | Gold standard — EU Reg. 1169/2011 mandates this      |
| **2**    | Manufacturer's official website (PL)   | Primary   | `verified`  | Must match PL market variant, not US/UK version      |
| **3**    | Polish governmental nutrition database | Reference | `verified`  | IŻŻ / NCEZ — cross-validation for generic categories |
| **4**    | Open Food Facts (PL barcode)           | Secondary | `verified`  | Only if entry has been community-verified            |
| **5**    | Polish retailer website                | Secondary | `estimated` | Biedronka.pl, Lidl.pl product pages                  |
| **6**    | Scientific literature / EFSA opinions  | Reference | `verified`  | For methodology, thresholds, and category benchmarks |
| **7**    | Category-typical averages              | Tertiary  | `estimated` | Used only when no label data is available            |

### Rules

- **Priority 1 always wins.** If you have the physical label, override all other sources.
- **Never mix country variants.** Lay's Classic in Poland has different salt/fat content than Lay's Classic in the UK. Always confirm the product is the **Polish SKU**.
- **Governmental databases (Priority 3)** provide reference ranges, not product-specific values. Use them to **cross-validate**, not to override label data.
- **Scientific literature (Priority 6)** informs methodology and thresholds, not individual product values.
- **When using Priority 7** (category averages), clearly mark the score confidence as `estimated` and add a SQL comment explaining the estimation.
- **Every product should be traceable to ≥ 2 sources** wherever possible (e.g., OFF + manufacturer website, or OFF + governmental reference range).

---

## 2. Primary Sources — Polish Product Labels

### 2.1 EU Mandatory Nutrition Declaration

Under **Regulation (EU) No 1169/2011**, all pre-packaged food sold in Poland must display (per 100g or 100ml):

| Field                    | Required | Our column        |
| ------------------------ | -------- | ----------------- |
| Energy (kJ/kcal)         | Yes      | `calories`        |
| Fat (g)                  | Yes      | `total_fat_g`     |
| — of which saturates (g) | Yes      | `saturated_fat_g` |
| Carbohydrate (g)         | Yes      | `carbs_g`         |
| — of which sugars (g)    | Yes      | `sugars_g`        |
| Protein (g)              | Yes      | `protein_g`       |
| Salt (g)                 | Yes      | `salt_g`          |

**Voluntary but recorded when available:**

| Field         | Required | Our column    |
| ------------- | -------- | ------------- |
| Fibre (g)     | No       | `fibre_g`     |
| Trans fat (g) | No       | `trans_fat_g` |

### 2.2 Label Language

Polish labels are in **Polish**. When recording data:

- The `ingredients_raw` column stores ingredient lists in **standardized English** (cleaned ASCII, deduplicated, comma-separated). This was normalized via migrations `001200` and `001600`.
- Product names should be recorded as they appear on the Polish label, using Polish diacritics (ą, ć, ę, ł, ń, ó, ś, ź, ż).
- Brand names may remain in their international form (e.g., "Lay's", "Pringles").

---

## 3. Governmental & Institutional Sources

These databases provide **reference values** for cross-validation and category benchmarks. They do not replace product-specific label data but are essential for detecting errors in community-sourced data.

### 3.1 IŻŻ / NCEZ — Polish National Food Composition Tables

- **Institution:** Instytut Żywności i Żywienia (IŻŻ) / Narodowe Centrum Edukacji Żywieniowej (NCEZ)
- **URL:** https://ncez.pzh.gov.pl/abc-zywienia/tabele-wartosci-odzywczej/
- **Data type:** Generic food composition (e.g., "potato chips, salted" — not brand-specific)
- **Use for:**
  - Cross-validating that a product's nutrition values fall within expected ranges for its category
  - Deriving category-typical averages when no label data is available (Priority 7)
  - Validating scoring thresholds against Polish dietary reference values
- **Limitations:** Not brand-specific; updated infrequently; may not cover ultra-processed categories
- **Confidence:** `verified` when used for cross-validation; `estimated` when used as the primary data source

### 3.2 EFSA — European Food Safety Authority

- **URL:** https://www.efsa.europa.eu/
- **Key resources:**
  - [Dietary Reference Values](https://www.efsa.europa.eu/en/topics/topic/dietary-reference-values) — basis for our scoring thresholds
  - [Comprehensive European Food Consumption Database](https://www.efsa.europa.eu/en/microstrategy/food-consumption-survey) — EU-wide food composition data
  - Scientific opinions on food additives, contaminants, and novel foods
- **Use for:**
  - Justifying scoring weight rationale and threshold ceilings (already cited in `SCORING_METHODOLOGY.md`)
  - Cross-checking additive safety assessments (e.g., E171 titanium dioxide withdrawal)
  - Reference values when Polish-specific data is unavailable
- **Confidence:** `verified` for reference values and additive assessments

### 3.3 WHO — World Health Organization Guidelines

- **Key resources:**
  - [Salt reduction](https://www.who.int/news-room/fact-sheets/detail/salt-reduction) — <5g/day target
  - [Sugars intake](https://www.who.int/publications/i/item/9789241549028) — <10% energy from free sugars
  - [Trans fat elimination](https://www.who.int/news-room/fact-sheets/detail/trans-fat) — REPLACE initiative
- **Use for:** Threshold justification in scoring methodology (already referenced)
- **Confidence:** `verified` — these are the gold standard for population-level dietary targets

---

## 4. Manufacturer Official Websites (Polish Market)

Manufacturer websites are **Priority 2** sources. They often publish full per-100g nutrition tables for their Polish SKUs. When using manufacturer data:

- Confirm the website serves the **Polish market** (`.pl` domain or PL language selector)
- Verify the product page matches the current formulation (check pack design photo)
- Screenshot or archive the page for traceability
- Record the URL and access date in the `product_sources` table

### 4.1 Major Manufacturers by Category

| Manufacturer                 | PL Website                            | Categories covered                                           | Notes                                  |
| ---------------------------- | ------------------------------------- | ------------------------------------------------------------ | -------------------------------------- |
| PepsiCo Polska               | https://www.pepsico.pl                | Chips (Lay's, Doritos, Cheetos), Drinks (Pepsi, 7UP, Lipton) | Full nutrition tables on product pages |
| Lorenz Snack-World           | https://www.lorenz-snacks.pl          | Chips (Crunchips, NicNac's)                                  | Polish-specific product pages          |
| Intersnack (Funny Frisch)    | https://www.intersnack.pl             | Chips (Chio)                                                 | Limited PL web presence                |
| Maspex                       | https://www.maspex.com                | Drinks (Tymbark, Kubuś), Cereals (Lubella), Instant          | Group site with brand sub-pages        |
| Mondelēz International       | https://www.mondelezinternational.com | Sweets (Milka, Oreo, Prince Polo, Alpen Gold)                | Use PL product finder                  |
| Nestlé Polska                | https://www.nestle.pl                 | Cereals (Nestlé, Cheerios), Dairy, Sweets (KitKat)           | Full PL product catalogue              |
| Danone Polska                | https://www.danone.pl                 | Dairy (Danio, Activia, Actimel), Baby (Bebiko)               | Nutrition tabs on product pages        |
| Ferrero                      | https://www.ferrero.pl                | Sweets (Kinder, Nutella, Ferrero Rocher)                     | PL-specific pages                      |
| Mars Polska                  | https://www.mars.com/poland-pl        | Sweets (Snickers, M&M's, Twix)                               | Use PL country selector                |
| Sokołów                      | https://www.sokolow.pl                | Meat (wędliny, kabanosy)                                     | Full nutrition per product             |
| Morliny                      | https://www.morliny.pl                | Meat (parówki, kiełbasy)                                     | Detailed product pages                 |
| Tarczyński                   | https://www.tarczynski.pl             | Meat (kabanosy)                                              | Product-level nutrition                |
| Pudliszki                    | https://www.pudliszki.pl              | Sauces (ketchup, passata)                                    | Full nutrition tables                  |
| Łowicz                       | https://www.lowicz.com.pl             | Sauces (dżemy, ketchup)                                      | Product pages with nutrition           |
| Develey                      | https://www.develey.pl                | Sauces (musztarda, ketchup)                                  | PL product range                       |
| Mlekpol                      | https://www.mlekpol.com.pl            | Dairy (Łaciate)                                              | Full nutrition info                    |
| Mlekovita                    | https://www.mlekovita.com.pl          | Dairy                                                        | Product-level data                     |
| Żywiec Zdrój / Danone Waters | https://www.zywiec-zdroj.pl           | Drinks (water)                                               | Mineral composition                    |
| Coca-Cola HBC Polska         | https://www.cocacolaep.com/pl         | Drinks (Coca-Cola, Fanta, Sprite)                            | PL product pages                       |
| Red Bull Polska              | https://www.redbull.com/pl-pl         | Drinks (energy)                                              | Nutrition on product page              |
| Kompania Piwowarska          | https://www.kp.pl                     | Alcohol (Tyskie, Żubr, Lech)                                 | Limited nutrition data                 |

### 4.2 Using Manufacturer Data

| Step | Action                                                     |
| ---- | ---------------------------------------------------------- |
| 1    | Navigate to the manufacturer's PL website                  |
| 2    | Find the specific product page (match pack size + variant) |
| 3    | Confirm nutrition table is per 100g (not per serving)      |
| 4    | Extract all available fields (EU-7 + voluntary)            |
| 5    | Cross-validate against OFF and/or label if available       |
| 6    | Record URL + access date in `sources` table                |
| 7    | Set `source_type = 'manufacturer'`                         |

---

## 5. Secondary Sources

### 5.1 Open Food Facts (opendata)

- **URL:** https://world.openfoodfacts.org/
- **API v2:** `GET https://world.openfoodfacts.org/api/v2/product/{EAN}.json`
- **Polish search:** `GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&countries_tags=en:poland&json=1`
- **Filter by:** Country = Poland (`countries_tags` must include `en:poland`), or search by EAN barcode
- **Trust level:** Verify that the entry's nutrition table image matches a Polish label
- **Useful for:** Nutri-Score (pre-computed), NOVA group, barcode, ingredient lists, additive count
- **Caution:** Community-contributed data can be outdated or from wrong country variant
- **Verification criteria:** `completeness` ≥ 0.5, modified within 3 years, Polish label image present

> **Full API field mapping:** See `RESEARCH_WORKFLOW.md` §3.4 for detailed field-to-column mapping.

### 5.2 Polish Retailer Websites

| Retailer  | Website                  | Category    | Notes                              |
| --------- | ------------------------ | ----------- | ---------------------------------- |
| Biedronka | https://www.biedronka.pl | Discount    | Largest chain; has private labels  |
| Lidl      | https://www.lidl.pl      | Discount    | Good product pages with nutrition  |
| Żabka     | https://www.zabka.pl     | Convenience | Limited online product info        |
| Auchan    | https://www.auchan.pl    | Hypermarket | Detailed product pages             |
| Carrefour | https://www.carrefour.pl | Hypermarket | Nutrition info sometimes available |

**Rules for retailer data:**
- Retailer websites may lag behind label changes.
- If the website shows different values than the label, **the label wins**.
- Private-label products (e.g., "Top Chips" from Biedronka) may not appear on other retailer sites.
- Always verify the nutrition table is per 100g, not per serving.

---

## 5.3 Cross-Validation Protocol

When using any non-label source, cross-validate against at least one other source:

| Check                                 | Threshold | Action on failure                                |
| ------------------------------------- | --------- | ------------------------------------------------ |
| OFF vs label: any field differs > 10% | ±10%      | Use label value, note discrepancy in SQL comment |
| OFF entry has no Polish label image   | —         | Downgrade `confidence` to `estimated`            |
| Retailer vs label: different values   | ±10%      | Use label, flag in comment                       |
| Multiple sources agree within 5%      | ±5%       | `confidence = 'verified'`                        |
| Energy cross-check fails (±15%)       | ±15%      | Flag data entry error, investigate               |

> **Full validation rules:** See `RESEARCH_WORKFLOW.md` §4 for range sanity checks, cross-field rules, and trace value handling.

---

## 6. Scientific Literature & References

Scientific publications are used to **justify methodology**, not to provide product-specific nutrition data. All papers cited in `SCORING_METHODOLOGY.md` should also be listed here for traceability.

### 6.1 Scoring & Classification Systems

| Reference              | Citation                                                                                                                                                           | Used for                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| NOVA classification    | Monteiro CA et al. (2019). Ultra-processed foods: what they are and how to identify them. *Public Health Nutrition*, 22(5), 936–941. doi:10.1017/S1368980018003762 | `processing_risk` and `nova_classification` basis |
| Nutri-Score algorithm  | Santé publique France (2024). Nutri-Score algorithm update.                                                                                                        | `nutri_score_label` computation when not on label |
| Nutri-Score validation | Julia C, Hercberg S (2017). Development of a new front-of-pack nutrition label in France. *Eur J Public Health*, 27(suppl_3).                                      | Scientific basis for Nutri-Score adoption         |

### 6.2 Dietary Risk & Thresholds

| Reference              | Citation                                                                                  | Used for                                             |
| ---------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| WHO salt guidelines    | WHO (2023). Salt reduction. Fact sheet.                                                   | `salt_g` ceiling (3.0g/100g) in scoring              |
| WHO sugar guidelines   | WHO (2015). Guideline: Sugars intake for adults and children.                             | `sugars_g` ceiling (27g/100g) in scoring             |
| WHO trans fat          | WHO (2023). REPLACE trans fat: An action package.                                         | `trans_fat_g` ceiling (2g/100g) and weight rationale |
| EFSA saturated fat DRV | EFSA NDA Panel (2010). Scientific Opinion on DRVs for fats. *EFSA Journal*, 8(3):1461.    | `saturated_fat_g` ceiling (10g/100g)                 |
| EFSA energy DRV        | EFSA NDA Panel (2013). Scientific Opinion on DRVs for energy. *EFSA Journal*, 11(1):3005. | `calories` ceiling (600 kcal/100g)                   |

### 6.3 Ultra-Processed Food & Health Outcomes

| Reference            | Citation                                                                                                                                    | Used for                                        |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| UPF & cardiovascular | Srour B et al. (2019). Ultra-processed food intake and risk of cardiovascular disease. *BMJ*, 365:l1451. doi:10.1136/bmj.l1451              | Weight rationale for processing-related factors |
| UPF meta-analysis    | Elizabeth L et al. (2020). Ultra-Processed Foods and Health Outcomes: A Narrative Review. *Nutrients*, 12(7):1955.                          | General methodology justification               |
| Additives & UPF      | Martínez Steele E et al. (2020). The share of ultra-processed foods and the quality of the diet. *Public Health Nutrition*, 23(3), 476–485. | `additives_count` weight rationale              |

### 6.4 Food Safety & Contaminants

| Reference               | Citation                                                                                                                       | Used for                              |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------- |
| Palm oil contaminants   | EFSA CONTAM Panel (2016). Risks for human health related to the presence of 3- and 2-MCPD in food. *EFSA Journal*, 14(5):4426. | `controversies = 'palm oil'` flag     |
| Titanium dioxide (E171) | EFSA FAF Panel (2021). Safety assessment of titanium dioxide (E171). *EFSA Journal*, 19(5):6585.                               | `controversies` flag for E171         |
| Acrylamide in food      | EU Commission Regulation 2017/2158. Establishing mitigation measures for acrylamide in food.                                   | `prep_method` scoring (fried > baked) |
| Trans fat regulation    | EU Commission Regulation 2019/649. Maximum 2g industrial trans fat per 100g fat.                                               | `trans_fat_g` ceiling validation      |

### 6.5 Citing Sources in SQL

When a scoring decision or threshold is informed by a scientific reference, cite it in a SQL comment:

```sql
-- Threshold: 3.0g salt/100g = 100 (sub-score ceiling)
-- Basis: WHO (2023) recommends <5g/day; 3g/100g ≈ >50% daily limit in 100g
-- Ref: https://www.who.int/news-room/fact-sheets/detail/salt-reduction
```

---

## 7. Polish-Specific Considerations

### 7.1 Store Landscape

Poland has a distinctive retail structure relevant to product coverage:

| Store type   | Key players                  | Product access                                 |
| ------------ | ---------------------------- | ---------------------------------------------- |
| Discount     | Biedronka, Lidl, Netto       | Largest volume; many private labels            |
| Convenience  | Żabka, Orlen Stop Cafe       | Unique product lines; smaller pack sizes       |
| Hypermarket  | Auchan, Carrefour, E.Leclerc | Broadest brand selection                       |
| Cash & carry | Makro, Selgros               | Bulk/HoReCa sizes; different nutrition formats |

### 7.2 Private Labels

Polish retailers have extensive private-label ranges that must be tracked separately:

| Retailer  | Private label examples              |
| --------- | ----------------------------------- |
| Biedronka | Top Chips, Marinero, Dada           |
| Lidl      | Snack Day, Pilos, Pikok             |
| Żabka     | Żabka-branded sandwiches and snacks |

Private-label products use the **retailer name** as the brand in our database (e.g., `brand = 'Top Chips (Biedronka)'`).

### 7.3 Nutri-Score Availability in Poland

As of 2026, Nutri-Score is **voluntary** in Poland. Many products do not display it on the label. When Nutri-Score is unavailable:

1. Check Open Food Facts for a computed Nutri-Score.
2. If not available, compute from nutrition facts using the 2024 algorithm.
3. If nutrition data is insufficient to compute, set `nutri_score_label = 'UNKNOWN'`.
4. Alcohol and similar categories use `nutri_score_label = 'NOT-APPLICABLE'`.

---

## 8. Confidence Levels

Every scored product carries a `confidence` tag:

| Level       | Criteria                                                               |
| ----------- | ---------------------------------------------------------------------- |
| `verified`  | data_completeness ≥ 90% (nutrition data from label or verified source) |
| `estimated` | data_completeness 70–89% or single source needing verification         |
| `low`       | data_completeness < 70%; score is approximate                          |

> **Note:** `computed` is not a valid confidence level in the database. The CHECK constraint only allows `verified`, `estimated`, `low`.

### Confidence Workflow

```
Physical label available?
  └─ YES → All EU-7 fields present + data_completeness ≥ 90%?
              └─ YES → confidence = 'verified'
              └─ NO  → confidence = 'estimated'
  └─ NO  → Open Food Facts (verified entry)?
              └─ YES → PL label image + completeness ≥ 0.5?
                          └─ YES → confidence = 'verified'
                          └─ NO  → confidence = 'estimated'
              └─ NO  → Category averages used?
                          └─ YES → confidence = 'estimated'
                          └─ NO  → data_completeness < 70%?
                                      └─ YES → confidence = 'low'
                                      └─ NO  → confidence = 'estimated'
```

> **data_completeness_pct formula:** See `RESEARCH_WORKFLOW.md` §6.3 for the weighted computation.
> **Confidence criteria table:** See `RESEARCH_WORKFLOW.md` §6.4.

---

## 9. Translation Rules

| Data type          | Language rule                                         |
| ------------------ | ----------------------------------------------------- |
| Product name       | As printed on label (Polish market version)           |
| Brand name         | International form (e.g., "Lay's" not "Lays")         |
| Ingredient list    | Standardized English (cleaned via pipeline)           |
| Category name      | English in database (e.g., `'Chips'`, `'Cereals'`)    |
| Store name         | Original Polish name (e.g., `'Żabka'`, `'Biedronka'`) |
| EU regulation refs | English citation with EU regulation number            |
| Column names       | English, snake_case                                   |

---

## 10. What Is Explicitly NOT Used

The following sources are **excluded** and must never be used:

| Source                            | Reason                                                      |
| --------------------------------- | ----------------------------------------------------------- |
| US FDA / USDA nutrition databases | Different labeling standards; values do not match EU labels |
| UK-variant product pages          | Different formulations (sugar, salt often differ from PL)   |
| ChatGPT / AI-generated nutrition  | Unverifiable; violates reproducibility requirement          |
| Social media / blog posts         | No traceability; unreliable                                 |
| Pre-2020 label data               | Formulations change; only current labels are valid          |
| Products not sold in Poland       | Out of scope; even if the brand exists globally             |

---

## 11. Source Tracking in Database

### Product-Level Provenance (`product_sources`)

The `product_sources` table tracks provenance at the **individual product** level and is the primary source join used by `v_master`:

| Column             | Purpose                                                                                      |
| ------------------ | -------------------------------------------------------------------------------------------- |
| `product_source_id`| Primary key (identity)                                                                       |
| `product_id`       | FK → products                                                                                |
| `source_type`      | `'off_api'`, `'off_search'`, `'manual'`, `'label_scan'`, `'retailer_api'`                    |
| `source_url`       | URL to the specific product page (e.g., OFF product page)                                    |
| `source_ean`       | EAN used to look up this product                                                             |
| `fields_populated` | Array of fields sourced from this source (e.g., `{nutrition,ingredients,additives}`)          |
| `collected_at`     | When the data was collected                                                                  |
| `is_primary`       | Whether this is the primary source for the product (unique per product)                      |
| `confidence_pct`   | 0–100 confidence in data accuracy                                                            |
| `notes`            | Additional context                                                                           |

**Constraints:**
- Unique on `(product_id, source_type, source_url)` — no duplicate source entries
- At most one `is_primary = true` per product
- `confidence_pct` between 0 and 100

### Legacy Category Registry (`sources`)

The legacy `sources` table records category-level acquisition metadata (20 rows, one per category). It is **no longer joined by `v_master`** but is retained as a registry of how each category's data was originally sourced.

| Column        | Purpose                                                                                                     |
| ------------- | ----------------------------------------------------------------------------------------------------------- |
| `source_id`   | Primary key                                                                                                 |
| `brand`       | Which brand this source covers                                                                              |
| `source_type` | `'label'`, `'manufacturer'`, `'openfoodfacts'`, `'government'`, `'retailer'`, `'estimated'`, `'scientific'` |
| `ref`         | Short reference (e.g., "Biedronka label, 2026-01" or "IŻŻ food comp. tables")                               |
| `url`         | URL if applicable                                                                                           |
| `notes`       | Any caveats, version notes, or cross-validation results                                                     |

### Source Type Definitions

| `source_type`   | When to use                                                     |
| --------------- | --------------------------------------------------------------- |
| `label`         | Physical product label photographed or read in-store            |
| `manufacturer`  | Manufacturer's official PL website product page                 |
| `openfoodfacts` | Open Food Facts entry (verified PL barcode)                     |
| `government`    | IŻŻ / NCEZ / EFSA food composition tables                       |
| `retailer`      | Polish retailer website (Biedronka, Lidl, Auchan, etc.)         |
| `estimated`     | Category average or interpolated value                          |
| `scientific`    | Scientific publication (used for methodology, not product data) |

**Rule:** When adding a new product, create a corresponding `product_sources` row with the appropriate `source_type`, `source_url`, and `confidence_pct`. Set `is_primary = true` for the most authoritative source. Products sourced only from Open Food Facts should be flagged for future cross-validation against manufacturer websites or labels.

---

## 12. EAN / Barcode Handling

EAN-13 barcodes are the standard product identifier in Polish retail. They are critical for:

- **Matching** products across data sources (label ↔ Open Food Facts ↔ retailer website)
- **Deduplicating** products that appear under different names in different stores
- **Verifying** that Open Food Facts data matches the correct Polish SKU

### 12.1 Current Schema Status

The `products` table has an `ean` TEXT column (added in migration `20260208000100`). A unique conditional index prevents barcode collisions.

**Coverage:** 558/560 active products (99.6%) have validated EAN-8 or EAN-13 barcodes.

**Missing EANs (2):**
- Kajzerka Kebab (product_id 43) — custom Zabka product, no universal barcode
- Kotlet Drobiowy (product_id 804) — custom Zabka product, no universal barcode

### 12.2 Barcode Rules

- Stored as **text** (not numeric) — EAN codes have leading zeros.
- Both EAN-8 and EAN-13 formats are supported.
- `ean` is **nullable** — private-label and deli products may not have universal EANs.
- The unique index is conditional (`WHERE ean IS NOT NULL`) to allow multiple rows without barcodes.
- One barcode = one product. If a product reformulates under the same EAN, update the existing row (do not create a new row).
- Multi-pack EANs (e.g., 6-pack of chips) are **different products** from single-pack EANs.
- EAN checksums are validated by `validate_eans.py` (called by `RUN_QA.ps1`).

### 12.3 Using Barcodes for Open Food Facts Lookup

```
https://world.openfoodfacts.org/product/<EAN>
```

Always verify that the returned product page shows a **Polish label image** before trusting the data.

---

## 13. Data Update Policy

- **Labels change.** Manufacturers reformulate products (e.g., sugar reduction initiatives). Re-verify data at least annually.
- **Seasonal products** (e.g., holiday-edition chips) should be flagged and re-checked for availability.
- **Discontinued products** should be flagged `is_deprecated = true, deprecated_reason = 'Discontinued'` — never deleted.
- **Price data** is explicitly out of scope. This is a nutrition/quality database, not a price tracker.
