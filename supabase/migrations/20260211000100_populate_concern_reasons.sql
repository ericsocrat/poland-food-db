-- ============================================================================
-- Migration: Populate concern_reason for all tier 1-3 additives
-- Date: 2026-02-11
-- Purpose: Fill the concern_reason column with EFSA-based explanations for
--          all 53 additives that have concern_tier >= 1. This enables
--          meaningful UX tooltips explaining why an additive is flagged.
-- ============================================================================

-- ─── Tier 3 — High concern (2 additives) ────────────────────────────────────

UPDATE ingredient_ref SET concern_reason = 'Sodium nitrite — linked to formation of carcinogenic nitrosamines; EFSA 2017 re-evaluation confirmed ADI of 0.07 mg/kg bw/day'
WHERE name_en = 'e250';

UPDATE ingredient_ref SET concern_reason = 'Potassium nitrate — converts to nitrite in the body; associated with nitrosamine formation; EFSA ADI 3.7 mg/kg bw/day, exceeded by high-intake consumers'
WHERE name_en = 'e252';

-- ─── Tier 2 — Moderate concern (14 additives) ───────────────────────────────

UPDATE ingredient_ref SET concern_reason = 'Brilliant Blue FCF — synthetic azo dye; EFSA ADI 6 mg/kg bw/day; potential for hyperactivity in children (Southampton study)'
WHERE name_en = 'e133';

UPDATE ingredient_ref SET concern_reason = 'Sulphite ammonia caramel — may contain 4-MEI, a potentially carcinogenic byproduct; EFSA 2011 re-evaluation reduced group ADI to 300 mg/kg bw/day'
WHERE name_en = 'e150d';

UPDATE ingredient_ref SET concern_reason = 'Sodium benzoate — may form benzene when combined with ascorbic acid; EFSA ADI 5 mg/kg bw/day; potential hyperactivity link in children'
WHERE name_en = 'e211';

UPDATE ingredient_ref SET concern_reason = 'Sulphur dioxide — potent allergen for asthmatics; EFSA 2016 group ADI 0.7 mg/kg bw/day; frequently exceeded in sensitive populations'
WHERE name_en = 'e220';

UPDATE ingredient_ref SET concern_reason = 'Sodium metabisulphite — releases SO₂; same concerns as sulphites (E220); allergen for asthmatics; EFSA group ADI 0.7 mg/kg bw/day'
WHERE name_en = 'e223';

UPDATE ingredient_ref SET concern_reason = 'TBHQ (tert-butylhydroquinone) — synthetic antioxidant; EFSA 2004 ADI 0.7 mg/kg bw/day; high doses linked to stomach tumours in animal studies'
WHERE name_en = 'e319';

UPDATE ingredient_ref SET concern_reason = 'Calcium disodium EDTA — chelating agent; EFSA ADI 1.9 mg/kg bw/day; may deplete essential minerals at high intake; concerns for kidney function'
WHERE name_en = 'e385';

UPDATE ingredient_ref SET concern_reason = 'Carrageenan — EFSA 2018 re-evaluation set ADI 75 mg/kg bw/day; degraded carrageenan linked to intestinal inflammation in animal studies'
WHERE name_en = 'e407';

UPDATE ingredient_ref SET concern_reason = 'Carboxymethylcellulose — EFSA 2018 review; recent studies suggest possible disruption of gut microbiota and intestinal barrier function'
WHERE name_en = 'e466';

UPDATE ingredient_ref SET concern_reason = 'Monosodium glutamate — EFSA 2017 group ADI 30 mg/kg bw/day (lowered from "no limit"); headache and flushing reported in sensitive individuals'
WHERE name_en = 'e621';

UPDATE ingredient_ref SET concern_reason = 'Acesulfame K — EFSA ADI 9 mg/kg bw/day; concerns about breakdown product acetoacetamide; potential genotoxicity under review'
WHERE name_en = 'e950';

UPDATE ingredient_ref SET concern_reason = 'Aspartame — EFSA 2013 ADI 40 mg/kg bw/day confirmed safe, but IARC 2023 classified as "possibly carcinogenic" (Group 2B); ongoing debate'
WHERE name_en = 'e951';

UPDATE ingredient_ref SET concern_reason = 'Saccharin — EFSA ADI 5 mg/kg bw/day; historical bladder cancer concern in rodents (mechanism not applicable to humans); some studies suggest gut microbiome effects'
WHERE name_en = 'e954';

UPDATE ingredient_ref SET concern_reason = 'Sucralose — EFSA ADI 15 mg/kg bw/day; recent studies suggest possible DNA damage at high concentrations and gut microbiota changes'
WHERE name_en = 'e955';

-- ─── Tier 1 — Low concern (37 additives) ────────────────────────────────────

UPDATE ingredient_ref SET concern_reason = 'Acetylated distarch phosphate — modified starch; EFSA "no safety concern" at current use levels; ADI not specified (acceptable)'
WHERE name_en = 'e1420';

UPDATE ingredient_ref SET concern_reason = 'Caramel colour (plain) — EFSA group ADI 300 mg/kg bw/day for caramel colours; no specific concern for plain caramel (Class I)'
WHERE name_en = 'e150';

UPDATE ingredient_ref SET concern_reason = 'Iron oxides — EFSA 2015 re-evaluation confirmed ADI 0.5 mg/kg bw/day; potential for excess iron intake in fortified products'
WHERE name_en = 'e172';

UPDATE ingredient_ref SET concern_reason = 'Sorbic acid — EFSA ADI 25 mg/kg bw/day; generally well tolerated; rare skin sensitisation reported'
WHERE name_en = 'e200';

UPDATE ingredient_ref SET concern_reason = 'Potassium sorbate — EFSA group ADI 25 mg/kg bw/day (as sorbic acid); generally safe; minor genotoxicity flags in vitro not confirmed in vivo'
WHERE name_en = 'e202';

UPDATE ingredient_ref SET concern_reason = 'Sodium propionate — EFSA 2014 group ADI 0–not specified; animal studies showed neural tube effects only at very high doses'
WHERE name_en = 'e281';

UPDATE ingredient_ref SET concern_reason = 'Calcium propionate — same group as E281; EFSA considers safe at current use levels; potential behavioural effects debated in literature'
WHERE name_en = 'e282';

UPDATE ingredient_ref SET concern_reason = 'Phosphoric acid — EFSA 2019 revised group ADI 40 mg/kg bw/day for phosphates; excess phosphorus intake linked to cardiovascular risk'
WHERE name_en = 'e338';

UPDATE ingredient_ref SET concern_reason = 'Sodium phosphates — EFSA 2019 group ADI 40 mg/kg bw/day; high phosphate intake may impair calcium absorption and kidney health'
WHERE name_en = 'e339';

UPDATE ingredient_ref SET concern_reason = 'Potassium phosphates — EFSA 2019 group ADI 40 mg/kg bw/day; contributes to total phosphate load; concerns for renal patients'
WHERE name_en = 'e340';

UPDATE ingredient_ref SET concern_reason = 'Calcium phosphates — EFSA 2019 group ADI 40 mg/kg bw/day; part of phosphate group; generally well tolerated at food levels'
WHERE name_en = 'e341';

UPDATE ingredient_ref SET concern_reason = 'Processed eucheuma seaweed (PES) — EFSA 2018 distinct from carrageenan (E407); ADI not specified; lower molecular weight raises intestinal concerns'
WHERE name_en = 'e407a';

UPDATE ingredient_ref SET concern_reason = 'Sorbitol — EFSA: laxative effect above 20 g/day; ADI not specified; osmotic diarrhoea at high intake; bloating in sensitive individuals'
WHERE name_en = 'e420';

UPDATE ingredient_ref SET concern_reason = 'Konjac glucomannan — EFSA approved; choking hazard from gels (banned in jelly mini-cups in EU); laxative effect at high intake'
WHERE name_en = 'e425';

UPDATE ingredient_ref SET concern_reason = 'Glycerol esters of wood rosins — EFSA 2020 ADI 3 mg/kg bw/day (reduced from 12.5); used in beverages; limited toxicity data'
WHERE name_en = 'e445';

UPDATE ingredient_ref SET concern_reason = 'Diphosphates — EFSA 2019 group ADI 40 mg/kg bw/day; contributes to total phosphate intake; high intake linked to vascular calcification'
WHERE name_en = 'e450';

UPDATE ingredient_ref SET concern_reason = 'Disodium diphosphate — specific form of E450; same EFSA group ADI 40 mg/kg bw/day; phosphate excess concerns'
WHERE name_en = 'e450i';

UPDATE ingredient_ref SET concern_reason = 'Triphosphates — EFSA 2019 group ADI 40 mg/kg bw/day; same phosphate group concerns; widespread use increases cumulative exposure'
WHERE name_en = 'e451';

UPDATE ingredient_ref SET concern_reason = 'Pentasodium triphosphate — specific form of E451; EFSA group ADI 40 mg/kg bw/day; contributes to phosphate burden'
WHERE name_en = 'e451i';

UPDATE ingredient_ref SET concern_reason = 'Polyphosphates — EFSA 2019 group ADI 40 mg/kg bw/day; contributes to total phosphorus load; cumulative exposure concern'
WHERE name_en = 'e452';

UPDATE ingredient_ref SET concern_reason = 'Sodium polyphosphate — specific form of E452; same EFSA phosphate group ADI; widespread use in processed foods'
WHERE name_en = 'e452i';

UPDATE ingredient_ref SET concern_reason = 'Methylcellulose — EFSA: ADI not specified; generally safe; possible laxative effect at high intake (>4.5 g/day); gut microbiome effects under study'
WHERE name_en = 'e461';

UPDATE ingredient_ref SET concern_reason = 'Mono- and diglycerides — EFSA: ADI not specified; safe at current levels; derived from fats; caloric contribution generally negligible'
WHERE name_en = 'e471';

UPDATE ingredient_ref SET concern_reason = 'Lactic acid esters of mono- and diglycerides — EFSA: no safety concern; ADI not specified; minor metabolic processing differences'
WHERE name_en = 'e472b';

UPDATE ingredient_ref SET concern_reason = 'DATEM — EFSA: no safety concerns at current use; ADI not specified; may contain trans-fatty acid residues from processing'
WHERE name_en = 'e472e';

UPDATE ingredient_ref SET concern_reason = 'Polyglycerol esters — EFSA ADI 25 mg/kg bw/day; generally safe; minor concerns about glycidyl ester contaminants in processing'
WHERE name_en = 'e475';

UPDATE ingredient_ref SET concern_reason = 'Polyglycerol polyricinoleate (PGPR) — EFSA ADI 7.5 mg/kg bw/day; safe at current levels; reversible liver enlargement at high doses in animal studies'
WHERE name_en = 'e476';

UPDATE ingredient_ref SET concern_reason = 'Sodium stearoyl-2-lactylate — EFSA group ADI 22 mg/kg bw/day; generally safe; derived from stearic and lactic acids'
WHERE name_en = 'e481';

UPDATE ingredient_ref SET concern_reason = 'Calcium stearoyl-2-lactylate — EFSA group ADI 22 mg/kg bw/day; same group as E481; generally well tolerated'
WHERE name_en = 'e482';

UPDATE ingredient_ref SET concern_reason = 'Sorbitan tristearate — EFSA group ADI 25 mg/kg bw/day; generally safe; minor concerns about impurities in processing'
WHERE name_en = 'e492';

UPDATE ingredient_ref SET concern_reason = 'Disodium guanylate — EFSA: safe at current levels; purine-based flavour enhancer; caution advised for gout patients (purine metabolism)'
WHERE name_en = 'e627';

UPDATE ingredient_ref SET concern_reason = 'Disodium inosinate — EFSA: safe at current levels; purine-based; same gout caution as E627; often used with MSG (E621)'
WHERE name_en = 'e631';

UPDATE ingredient_ref SET concern_reason = 'Disodium 5''-ribonucleotides — EFSA: safe at current levels; mixture of E627 and E631; purine load relevant for gout-prone individuals'
WHERE name_en = 'e635';

UPDATE ingredient_ref SET concern_reason = 'L-Cysteine — EFSA: generally safe; used as flour treatment agent; may be derived from animal sources (hair, feathers)'
WHERE name_en = 'e920';

UPDATE ingredient_ref SET concern_reason = 'Steviol glycosides — EFSA ADI 4 mg/kg bw/day; natural sweetener; may be exceeded by high consumers, especially children'
WHERE name_en = 'e960';

UPDATE ingredient_ref SET concern_reason = 'Stevioside — specific steviol glycoside; EFSA ADI 4 mg/kg bw/day (expressed as steviol equivalents); same intake concern as E960'
WHERE name_en = 'e960a';

UPDATE ingredient_ref SET concern_reason = 'Maltitol — EFSA: laxative effect above 30-40 g/day; ADI not specified; osmotic laxative properties; bloating and flatulence common'
WHERE name_en = 'e965';

-- ─── Verification ───────────────────────────────────────────────────────────

DO $$
DECLARE
  missing_count INT;
BEGIN
  SELECT count(*) INTO missing_count
  FROM ingredient_ref
  WHERE concern_tier >= 1
    AND (concern_reason IS NULL OR concern_reason = '');
  IF missing_count > 0 THEN
    RAISE EXCEPTION 'Migration check failed: % additives still missing concern_reason', missing_count;
  END IF;
END $$;
