# EAN Validation Status

> **Last updated:** 2026-02-28

## Summary

**Total active products**: 1,026 (PL only)
**Products with EAN**: 1,024 (99.8%)
**Products without EAN**: 2 — documented exceptions (no valid GS1 barcode exists)
**Checksum validity**: 100% of EANs pass GS1 Modulo-10 validation (EAN-8 + EAN-13)

All EAN codes are sourced directly from the Open Food Facts API during pipeline generation. Each product's EAN is the `code` field from its OFF record.

### Products Without EAN (2)

| Category         | Brand   | Product         | Reason                                                    |
| ---------------- | ------- | --------------- | --------------------------------------------------------- |
| Żabka            | Szamamm | Kotlet Drobiowy | OFF code `10471346` fails EAN-8 checksum — no valid GS1    |
| Instant & Frozen | Vifon   | Zupka hińska    | RCN `08153825` is a Restricted Circulation Number, not EAN |

Both products exist in the OFF database but their codes are not valid GS1 barcodes. These are the only non-coverable products in the database.

## Coverage by Category

| Category                   |  Products | With EAN |  Coverage |
| -------------------------- | --------: | -------: | --------: |
| Alcohol                    |        30 |       30 |    100.0% |
| Baby                       |         9 |        9 |    100.0% |
| Bread                      |        60 |       60 |    100.0% |
| Breakfast & Grain-Based    |        94 |       94 |    100.0% |
| Canned Goods               |        49 |       49 |    100.0% |
| Cereals                    |        42 |       42 |    100.0% |
| Chips                      |        50 |       50 |    100.0% |
| Condiments                 |        55 |       55 |    100.0% |
| Dairy                      |        50 |       50 |    100.0% |
| Drinks                     |        61 |       61 |    100.0% |
| Frozen & Prepared          |        50 |       50 |    100.0% |
| Instant & Frozen           |        52 |       51 |     98.1% |
| Meat                       |        49 |       49 |    100.0% |
| Nuts, Seeds & Legumes      |        44 |       44 |    100.0% |
| Plant-Based & Alternatives |        48 |       48 |    100.0% |
| Sauces                     |        98 |       98 |    100.0% |
| Seafood & Fish             |        51 |       51 |    100.0% |
| Snacks                     |        56 |       56 |    100.0% |
| Sweets                     |        50 |       50 |    100.0% |
| Żabka                      |        28 |       27 |     96.4% |
| **Total**                  | **1,026** |**1,024** | **99.8%** |

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
