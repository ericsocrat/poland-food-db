# EAN Validation Status

## Summary

**Total active products**: 867
**Products with EAN**: 839 (96.8%)
**Products without EAN**: 28 — all Żabka store-prepared items (no manufacturer barcode)
**Checksum validity**: 100% of EANs pass GS1 Modulo-10 validation (EAN-8 + EAN-13)

All EAN codes are sourced directly from the Open Food Facts API during pipeline generation. Each product's EAN is the `code` field from its OFF record. Żabka products are store-prepared convenience items that do not carry standard EAN barcodes.

## Coverage by Category

| Category                   | Products | With EAN |  Coverage |
| -------------------------- | -------: | -------: | --------: |
| Alcohol                    |       31 |       31 |    100.0% |
| Baby                       |       49 |       49 |    100.0% |
| Bread                      |       59 |       59 |    100.0% |
| Breakfast & Grain-Based    |       99 |       99 |    100.0% |
| Canned Goods               |       27 |       27 |    100.0% |
| Cereals                    |       46 |       46 |    100.0% |
| Chips                      |       28 |       28 |    100.0% |
| Condiments                 |       26 |       26 |    100.0% |
| Dairy                      |       28 |       28 |    100.0% |
| Drinks                     |       60 |       60 |    100.0% |
| Frozen & Prepared          |       35 |       35 |    100.0% |
| Instant & Frozen           |       28 |       28 |    100.0% |
| Meat                       |       27 |       27 |    100.0% |
| Nuts, Seeds & Legumes      |       28 |       28 |    100.0% |
| Plant-Based & Alternatives |       50 |       50 |    100.0% |
| Sauces                     |       98 |       98 |    100.0% |
| Seafood & Fish             |       35 |       35 |    100.0% |
| Snacks                     |       57 |       57 |    100.0% |
| Sweets                     |       28 |       28 |    100.0% |
| Żabka                      |       28 |        0 |      0.0% |
| **Total**                  |  **867** |  **839** | **96.8%** |

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
