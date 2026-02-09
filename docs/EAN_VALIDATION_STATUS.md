# EAN Validation Status

## Summary

**Total active products**: 560
**Products with EAN**: 559 (99.8%)
**Products without EAN**: 1 (Zabka Kajzerka Kebab - store-prepared item, no barcode)
**Checksum validity**: 100% of EANs pass GS1 Modulo-10 validation

All EAN codes are sourced directly from the Open Food Facts API during pipeline generation. Each product's EAN is the `code` field from its OFF record, ensuring authenticity.

## Coverage by Category

| Category                   | Products | With EAN | Coverage |
| -------------------------- | -------: | -------: | -------: |
| Alcohol                    |       28 |       28 |   100.0% |
| Baby                       |       28 |       28 |   100.0% |
| Bread                      |       28 |       28 |   100.0% |
| Breakfast & Grain-Based    |       28 |       28 |   100.0% |
| Canned Goods               |       28 |       28 |   100.0% |
| Cereals                    |       28 |       28 |   100.0% |
| Chips                      |       28 |       28 |   100.0% |
| Condiments                 |       28 |       28 |   100.0% |
| Dairy                      |       28 |       28 |   100.0% |
| Drinks                     |       28 |       28 |   100.0% |
| Frozen & Prepared          |       28 |       28 |   100.0% |
| Instant & Frozen           |       28 |       28 |   100.0% |
| Meat                       |       28 |       28 |   100.0% |
| Nuts, Seeds & Legumes      |       28 |       28 |   100.0% |
| Plant-Based & Alternatives |       28 |       28 |   100.0% |
| Sauces                     |       28 |       28 |   100.0% |
| Seafood & Fish             |       28 |       28 |   100.0% |
| Snacks                     |       28 |       28 |   100.0% |
| Sweets                     |       28 |       28 |   100.0% |
| Zabka                      |       28 |       27 |    96.4% |
| **Total**                  |  **560** |  **559** | **99.8%** |

## Validation

- **Algorithm**: GS1 Modulo-10 checksum (ISO/IEC 15420 compliant)
- **QA Suite**: `.\RUN_QA.ps1` - includes EAN validation checks
- **OFF API**: EANs sourced from `https://world.openfoodfacts.org/api/v2/search`

## Historical Notes

EAN coverage evolved significantly across sessions:

- **Session 5** (Feb 8): 133 EANs manually researched (29.8% of 446 products)
- **Session 7** (Feb 8): 267 validated EANs after removing 44 invalid legacy codes, expanding Chips (+16), Dairy (+23), Plant-Based (+11), Bread (+20), Alcohol (+22)
- **Session 8** (Feb 9): Migrated to OFF v2 API - all pipeline-generated products now include their OFF `code` as EAN automatically. Coverage jumped to 876/877 (99.9%).
- **Session 10** (Feb 10): Normalized all categories to 28 products each. Active pool shrank from 877→560 (317 deprecated). EAN coverage 559/560 (99.8%).
