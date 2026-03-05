# EAN Validation Status

> **Last updated:** 2026-03-05

## Summary

**Total active products**: 2,264 (1,198 PL + 1,066 DE across 19 PL + 19 DE categories)
**Products with EAN**: 2,261 (99.9%)
**Products without EAN**: 3 — documented exceptions (no valid GS1 barcode exists)
**Checksum validity**: 100% of EANs pass GS1 Modulo-10 validation (EAN-8 + EAN-13)

All EAN codes are sourced directly from the Open Food Facts API during pipeline generation. Each product's EAN is the `code` field from its OFF record.

### Products Without EAN (3)

| Category         | Country | Brand       | Product              | Reason                                                    |
| ---------------- | ------- | ----------- | -------------------- | --------------------------------------------------------- |
| Alcohol          | PL      | Christkindl | Christkindl Glühwein | OFF record has no valid GS1 barcode                       |
| Instant & Frozen | PL      | Ajinomoto   | Pork Ramen           | OFF record has no valid GS1 barcode                       |
| Instant & Frozen | PL      | Vifon       | Zupka hińska         | RCN `08153825` is a Restricted Circulation Number, not EAN |

All 3 products exist in the OFF database but their codes are not valid GS1 barcodes. These are the only non-coverable products in the database.

## Coverage by Category

| Category                        | Products | With EAN | Coverage |
| ------------------------------- | -------: | -------: | -------: |
| Alcohol (DE)                    |       51 |       51 |   100.0% |
| Alcohol (PL)                    |       24 |       23 |    95.8% |
| Baby (DE)                       |       51 |       51 |   100.0% |
| Baby (PL)                       |       38 |       38 |   100.0% |
| Bread (DE)                      |       51 |       51 |   100.0% |
| Bread (PL)                      |       59 |       59 |   100.0% |
| Breakfast & Grain-Based (DE)    |       51 |       51 |   100.0% |
| Breakfast & Grain-Based (PL)    |       95 |       95 |   100.0% |
| Canned Goods (DE)               |       51 |       51 |   100.0% |
| Canned Goods (PL)               |       84 |       84 |   100.0% |
| Cereals (DE)                    |       33 |       33 |   100.0% |
| Cereals (PL)                    |       42 |       42 |   100.0% |
| Chips (DE)                      |       95 |       95 |   100.0% |
| Chips (PL)                      |       49 |       49 |   100.0% |
| Condiments (DE)                 |       51 |       51 |   100.0% |
| Condiments (PL)                 |       48 |       48 |   100.0% |
| Dairy (DE)                      |       94 |       94 |   100.0% |
| Dairy (PL)                      |       92 |       92 |   100.0% |
| Drinks (DE)                     |       95 |       95 |   100.0% |
| Drinks (PL)                     |       95 |       95 |   100.0% |
| Frozen & Prepared (DE)          |       51 |       51 |   100.0% |
| Frozen & Prepared (PL)          |       50 |       50 |   100.0% |
| Instant & Frozen (DE)           |       51 |       51 |   100.0% |
| Instant & Frozen (PL)           |       50 |       48 |    96.0% |
| Meat (DE)                       |       51 |       51 |   100.0% |
| Meat (PL)                       |       92 |       92 |   100.0% |
| Nuts, Seeds & Legumes (DE)      |       51 |       51 |   100.0% |
| Nuts, Seeds & Legumes (PL)      |       46 |       46 |   100.0% |
| Plant-Based & Alternatives (DE) |       16 |       16 |   100.0% |
| Plant-Based & Alternatives (PL) |       48 |       48 |   100.0% |
| Sauces (DE)                     |       51 |       51 |   100.0% |
| Sauces (PL)                     |       96 |       96 |   100.0% |
| Seafood & Fish (DE)             |       51 |       51 |   100.0% |
| Seafood & Fish (PL)             |       92 |       92 |   100.0% |
| Snacks (DE)                     |       26 |       26 |   100.0% |
| Snacks (PL)                     |       50 |       50 |   100.0% |
| Sweets (DE)                     |       95 |       95 |   100.0% |
| Sweets (PL)                     |       48 |       48 |   100.0% |
| **Total**                       | **2,264**|**2,261** | **99.9%**|

## Validation

- **Algorithm**: GS1 Modulo-10 checksum (ISO/IEC 15420 compliant) — supports EAN-8 and EAN-13
- **QA Suite**: `.\RUN_QA.ps1` — includes EAN validation checks
- **Standalone**: `python validate_eans.py` — full EAN audit with per-product results
- **OFF API**: EANs sourced from `https://world.openfoodfacts.org/api/v2/search`

## Historical Notes

EAN coverage evolved significantly across sessions:

- **Session 5** (Feb 8): 133 EANs manually researched (29.8% of 446 products)
- **Session 7** (Feb 8): 267 validated EANs after removing 44 invalid legacy codes
- **Session 8** (Feb 9): Migrated to OFF v2 API — all pipeline products now include OFF `code` as EAN automatically. Coverage jumped to 876/877 (99.9%)
- **Session 10** (Feb 10): Normalized all categories to 28 products each. Active pool shrank from 877→560. EAN coverage 558/560 (99.6%)
- **Session 11** (Feb 11): Category expansion to variable sizes (867 active). All 19 non-Żabka categories at 100% EAN coverage. Overall 839/867 (96.8%)
- **Session 12** (Feb 12): Further category adjustments (1,025 active). 1 Instant & Frozen product without EAN. Baby category reduced (30 re-categorized). EAN coverage 997/1,025 (97.3%)
- **PR #455** (Feb 28): Populated EANs for 27/28 Żabka products from OFF API. 1 product (Szamamm Kotlet Drobiowy) has no valid GS1 code. Coverage 997/1,025 → 1,024/1,026 (99.8%). Only 2 products remain without EAN — both documented exceptions.
- **PR #593** (Mar 4): Scaled all 20 PL categories to max capacity (1,198 PL products). DE expanded from 5→19 categories (1,066 DE products). Żabka (27 products) deprecated. Total active: 2,264. EAN coverage 2,261/2,264 (99.9%). 3 products without EAN — all documented exceptions.
