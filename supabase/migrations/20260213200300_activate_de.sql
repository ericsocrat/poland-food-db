-- Activate Germany (DE) after micro-pilot validation
-- DE data imported: 51 Chips products with Nutri-Score, NOVA, nutrition, source provenance
-- Inactive validation passed: v_api_category_overview showed 0 DE rows while inactive
-- Country isolation (Suite 19): 11/11 checks passed

UPDATE country_ref
SET is_active   = true,
    notes       = 'Micro-pilot: activated after QA validation (51 Chips products)'
WHERE country_code = 'DE';
