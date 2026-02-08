# EAN Validation Status

## Summary

**Total EANs in database**: 133  
**Valid EAN-13 codes**: 133 (100%)  
**Invalid checksums**: 0 (0%)  
**EAN-8 codes (warnings)**: 8

## Recent Progress

### ✅ Completed (Feb 8, 2026)
- Created `validate_eans.py` - EAN-13 checksum validator using Modulo-10 algorithm
- Fixed 4 invalid EANs in baby, drinks, and żabka categories
- **Removed all EAN codes from frozen category** (23 invalid, 82% error rate, none verifiable)
- **Removed all EAN codes from plant-based category** (10 invalid, 37% error rate, none verifiable)
- Applied corrected EANs to database (133 products, 34.0% coverage)
- Fixed Windows UTF-8 encoding issues in validator
- Integrated EAN validation into QA suite as Test Suite 4
- **QA suite now passes: all EAN-13 checksums valid**

### 🗑️ Removed Categories

**Frozen & Prepared (28 products)**
- Reason: 82% checksum failure rate (23/28 invalid)
- None found in Open Food Facts database despite claim of verification
- EANs removed on 2026-02-08, products retained without barcodes

**Plant-Based & Alternatives (27 products)**  
- Reason: 37% checksum failure rate (10/27 invalid)
- None found in Open Food Facts database despite claim of verification
- EANs removed on 2026-02-08, products retained without barcodes

## Invalid EANs by Brand

### Bonduelle (2 products)
- **Brokuł**: `5901652014621` → Expected checksum: 7, got 1 → Correct: `5901652014627`
- **Mieszanka Warzyw Orientalna**: `5901652014645` → Expected: 1, got 5 → Correct: `5901652014641`

### Dr. Oetker (2 products)
- **Zcieżynka Margherita**: `5901821102103` → Expected: 0, got 3 → Correct: `5901821102100`
- **Zcieżynka Pepperoni**: `5901821102110` → Expected: 7, got 0 → Correct: `5901821102117`

### Morey (2 products)
- **Kluski Śląskie**: `5900779100234` → Expected: 7, got 4 → Correct: `5900779100237`
- **Kopytka Mięso**: `5900779104567` → Expected: 3, got 7 → Correct: `5900779104563`

### Nowaco (2 products)
- **Pierogi Ruskie**: `5901892000421` → Expected: 8, got 1 → Correct: `5901892000428`
- **Pierogi Mięso Kapusta**: `5901892000438` → Expected: 5, got 8 → Correct: `5901892000435`

### Obiad/Prepared Dishes (2 products)
- **Obiad Tradycyjny - Danie Mięsne Piekarsko**: `5900285004213` → Expected: 0, got 3 → Correct: `5900285004210`
- **Obiad Z Piekarni - Łazanki Mięsne**: `5900285003612` → Expected: 9, got 2 → Correct: `5900285003619`

### TV Dinners (2 products)
- **TVLine - Obiad Szybki Mięso**: `5900721002834` → Expected: 1, got 4 → Correct: `5900721002831`
- **TVDishes - Filet Drobiowy**: `5900721002841` → Expected: 8, got 1 → Correct: `5900721002848`

### Other Brands (11 products)
- **Berryland - Owocownia Mieszana**: `5901121004218` → Expected: 0, got 8 → Correct: `5901121004210`
- **Goodmills - Placki Ziemniaczane**: `5901652041237` → Expected: 4, got 7 → Correct: `5901652041234`
- **Krystal - Kotlety Mielone**: `5900121004521` → Expected: 7, got 1 → Correct: `5900121004527`
- **Kulina - Nalisniki ze Serem**: `5901822001456` → Expected: 7, got 6 → Correct: `5901822001457`
- **Makaronika - Danie z Warzywami**: `5901825000421` → Expected: 6, got 1 → Correct: `5901825000426`
- **Mielczarski - Bigos Myśliwski**: `5901121001234` → Expected: 3, got 4 → Correct: `5901121001233`
- **Mrożone Pierniki - Pierniki Tradycyjne**: `5901239004521` → Expected: 2, got 1 → Correct: `5901239004522`
- **Pani Polska - Golabki Mięso Ryż**: `5901245003842` → Expected: 7, got 2 → Correct: `5901245003847`
- **Zaleśna Góra - Paczki Mięsne**: `5900382000127` → Expected: 2, got 7 → Correct: `5900382000122`
- **Żabka Frost - Krokiety Mięsne**: `5901652030432` → Expected: 6, got 2 → Correct: `5901652030436`
- **Zwierzenica - Kielbasa Zapiekanka**: `5900481001823` → Expected: 2, got 3 → Correct: `5900481001822`

## Next Steps

### Option 1: Apply Calculated Corrections (Fast but Risky)
Use the calculated checksums above to correct all 23 EANs. ⚠️ **Risk**: If the first 12 digits are also incorrect (common with transcription errors), the calculated checksums will be wrong.

```sql
-- Example correction
UPDATE products SET ean = '5901652014627' WHERE ean = '5901652014621';
```

### Option 2: Manual Verification (Slow but Accurate)
1. Search each product on [Open Food Facts Poland](https://pl.openfoodfacts.org)
2. Cross-reference with manufacturer websites
3. Check Polish retail databases (Biedronka, Żabka, Carrefour)
4. Update pipeline SQL files with verified EANs
5. Regenerate and apply migration

### Option 3: Remove Frozen Category EANs (Conservative)
If products cannot be verified, remove EANs from frozen category and mark as `estimated` confidence:

```sql
UPDATE products 
SET ean = NULL 
WHERE category = 'Frozen & Prepared' 
  AND ean IN (SELECT ean FROM products WHERE ...[invalid list]);
```

## Recommendation

**Hybrid approach**:
1. Verify high-confidence brands (Dr. Oetker, Bonduelle, Nowaco) - these are real brands with accessible product databases
2. Apply calculated checksums for verified brands
3. Remove EANs for obscure brands (Morey, Kulina, Zaleśna Góra) that cannot be verified
4. Re-run validator to confirm 100% valid EAN rate

## Tools

- **Validator**: `python validate_eans.py` (all EANs) or `python validate_eans.py --ean <code>` (single)
- **Error report**: See `frozen_ean_errors.txt` for full list
- **Open Food Facts API**: `https://world.openfoodfacts.org/api/v0/product/{ean}.json`

## EAN-8 Warnings

8 products use EAN-8 format (valid but not standard EAN-13):
- Crownfield (Lidl): 3 products (Choco Balls, Goldini, Musli Premium)
- Szamamm: 4 products (frozen convenience foods)
- GutBio: 1 product (baby food)

These are valid but should ideally be converted to EAN-13 format if 13-digit codes are available.
