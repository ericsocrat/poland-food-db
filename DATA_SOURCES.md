# Data Sources

> **Last updated:** 2026-02-07
> **Scope:** Poland (`PL`) only
> **Related:** See `RESEARCH_WORKFLOW.md` for the full step-by-step data collection process,
> and `SCORING_METHODOLOGY.md` for how collected data is scored.

---

## 1. Source Priority Hierarchy

When collecting nutrition and product data for a Polish product, use sources in this strict order:

| Priority | Source                             | Type      | Confidence  | Notes                                           |
| -------- | ---------------------------------- | --------- | ----------- | ----------------------------------------------- |
| **1**    | Physical product label (PL market) | Primary   | `verified`  | Gold standard — EU Reg. 1169/2011 mandates this |
| **2**    | Manufacturer's official website    | Primary   | `verified`  | Must match PL market variant, not US/UK version |
| **3**    | Open Food Facts (PL barcode)       | Secondary | `verified`  | Only if entry has been community-verified       |
| **4**    | Polish retailer website            | Secondary | `estimated` | Biedronka.pl, Lidl.pl product pages             |
| **5**    | Category-typical averages          | Tertiary  | `estimated` | Used only when no label data is available       |

### Rules

- **Priority 1 always wins.** If you have the physical label, override all other sources.
- **Never mix country variants.** Lay's Classic in Poland has different salt/fat content than Lay's Classic in the UK. Always confirm the product is the **Polish SKU**.
- **When using Priority 5** (category averages), clearly mark the score confidence as `estimated` and add a SQL comment explaining the estimation.

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

- Store ingredient lists in the original Polish text in `ingredients_raw`.
- Do NOT translate ingredient lists — translation introduces errors.
- Product names should be recorded as they appear on the Polish label, using Polish diacritics (ą, ć, ę, ł, ń, ó, ś, ź, ż).
- Brand names may remain in their international form (e.g., "Lay's", "Pringles").

---

## 3. Secondary Sources

### 3.1 Open Food Facts (opendata)

- **URL:** https://world.openfoodfacts.org/
- **API v2:** `GET https://world.openfoodfacts.org/api/v2/product/{EAN}.json`
- **Polish search:** `GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&countries_tags=en:poland&json=1`
- **Filter by:** Country = Poland (`countries_tags` must include `en:poland`), or search by EAN barcode
- **Trust level:** Verify that the entry's nutrition table image matches a Polish label
- **Useful for:** Nutri-Score (pre-computed), NOVA group, barcode, ingredient lists, additive count
- **Caution:** Community-contributed data can be outdated or from wrong country variant
- **Verification criteria:** `completeness` ≥ 0.5, modified within 3 years, Polish label image present

> **Full API field mapping:** See `RESEARCH_WORKFLOW.md` §3.4 for detailed field-to-column mapping.

### 3.2 Polish Retailer Websites

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

## 3.3 Cross-Validation Protocol

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

## 4. Polish-Specific Considerations

### 4.1 Store Landscape

Poland has a distinctive retail structure relevant to product coverage:

| Store type   | Key players                  | Product access                                 |
| ------------ | ---------------------------- | ---------------------------------------------- |
| Discount     | Biedronka, Lidl, Netto       | Largest volume; many private labels            |
| Convenience  | Żabka, Orlen Stop Cafe       | Unique product lines; smaller pack sizes       |
| Hypermarket  | Auchan, Carrefour, E.Leclerc | Broadest brand selection                       |
| Cash & carry | Makro, Selgros               | Bulk/HoReCa sizes; different nutrition formats |

### 4.2 Private Labels

Polish retailers have extensive private-label ranges that must be tracked separately:

| Retailer  | Private label examples              |
| --------- | ----------------------------------- |
| Biedronka | Top Chips, Marinero, Dada           |
| Lidl      | Snack Day, Pilos, Pikok             |
| Żabka     | Żabka-branded sandwiches and snacks |

Private-label products use the **retailer name** as the brand in our database (e.g., `brand = 'Top Chips (Biedronka)'`).

### 4.3 Nutri-Score Availability in Poland

As of 2026, Nutri-Score is **voluntary** in Poland. Many products do not display it on the label. When Nutri-Score is unavailable:

1. Check Open Food Facts for a computed Nutri-Score.
2. If not available, compute from nutrition facts using the 2024 algorithm.
3. Set `confidence = 'computed'` in the scores table.
4. If data is insufficient to compute, leave `nutri_score_label = NULL`.

---

## 5. Confidence Levels

Every scored product carries a `confidence` tag:

| Level       | Criteria                                                        |
| ----------- | --------------------------------------------------------------- |
| `verified`  | Nutrition data from physical label or verified Open Food Facts  |
| `estimated` | Some nutrition values estimated from category or brand averages |
| `computed`  | Nutri-Score derived algorithmically, not from label             |
| `low`       | Multiple critical fields missing; score is approximate          |

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

## 6. Translation Rules

| Data type          | Language rule                                         |
| ------------------ | ----------------------------------------------------- |
| Product name       | As printed on label (Polish market version)           |
| Brand name         | International form (e.g., "Lay's" not "Lays")         |
| Ingredient list    | Original Polish — never translate                     |
| Category name      | English in database (e.g., `'Chips'`, `'Cereals'`)    |
| Store name         | Original Polish name (e.g., `'Żabka'`, `'Biedronka'`) |
| EU regulation refs | English citation with EU regulation number            |
| Column names       | English, snake_case                                   |

---

## 7. What Is Explicitly NOT Used

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

## 8. Source Tracking in Database

The `sources` table records where data came from:

| Column        | Purpose                                                  |
| ------------- | -------------------------------------------------------- |
| `source_id`   | Primary key                                              |
| `brand`       | Which brand this source covers                           |
| `source_type` | `'label'`, `'website'`, `'openfoodfacts'`, `'estimated'` |
| `ref`         | Short reference (e.g., "Biedronka label, 2026-01")       |
| `url`         | URL if applicable                                        |
| `notes`       | Any caveats or version notes                             |

**Rule:** When adding a new product batch, also add a corresponding `sources` row documenting where the data came from.

---

## 9. EAN / Barcode Handling

EAN-13 barcodes are the standard product identifier in Polish retail. They are critical for:

- **Matching** products across data sources (label ↔ Open Food Facts ↔ retailer website)
- **Deduplicating** products that appear under different names in different stores
- **Verifying** that Open Food Facts data matches the correct Polish SKU

### 9.1 Current Schema Status

The `products` table does **not yet have** a barcode column. This is a known gap.

**Planned migration** (to be added when barcode data collection begins):

```sql
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS ean TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS products_ean_uniq
  ON public.products (ean)
  WHERE ean IS NOT NULL;
```

### 9.2 Rules for When Barcodes Are Added

- Store as **text** (not numeric) — EAN-13 codes have leading zeros.
- Always store the full 13-digit code (e.g., `'5900259000002'`).
- `ean` should be **nullable** — private-label and bulk products may not have universal EANs.
- The unique index is conditional (`WHERE ean IS NOT NULL`) to allow multiple rows without barcodes.
- One barcode = one product. If a product reformulates under the same EAN, update the existing row (do not create a new row).
- Multi-pack EANs (e.g., 6-pack of chips) are **different products** from single-pack EANs.

### 9.3 Using Barcodes for Open Food Facts Lookup

```
https://world.openfoodfacts.org/product/<EAN>
```

Always verify that the returned product page shows a **Polish label image** before trusting the data.

---

## 10. Data Update Policy

- **Labels change.** Manufacturers reformulate products (e.g., sugar reduction initiatives). Re-verify data at least annually.
- **Seasonal products** (e.g., holiday-edition chips) should be flagged and re-checked for availability.
- **Discontinued products** should be flagged `is_deprecated = true, deprecated_reason = 'Discontinued'` — never deleted.
- **Price data** is explicitly out of scope. This is a nutrition/quality database, not a price tracker.
