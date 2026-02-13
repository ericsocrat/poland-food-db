-- Add Germany to country_ref (inactive — awaiting micro-pilot validation)
-- Phase 1: Micro DE Pilot — country entry only, no data yet
-- DE will be activated after QA validation proves country isolation

INSERT INTO country_ref (country_code, country_name, native_name, currency_code, is_active, notes)
VALUES ('DE', 'Germany', 'Deutschland', 'EUR', false, 'Micro-pilot: inactive until QA validation completes')
ON CONFLICT (country_code) DO NOTHING;
