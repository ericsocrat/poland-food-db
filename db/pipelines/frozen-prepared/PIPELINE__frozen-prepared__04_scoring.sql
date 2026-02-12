-- PIPELINE (Frozen & Prepared): scoring
-- Generated: 2026-02-11

-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update products p set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      p.ingredient_concern_score
  )
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 'D'),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 'C'),
    ('Koral', 'Lody śmietankowe - kostka śnieżna', 'D'),
    ('Dobra kaloria', 'Roślinna kaszanka', 'C'),
    ('Grycan', 'Lody śmietankowe', 'D'),
    ('Hortex', 'Warzywa na patelnię', 'A'),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 'A'),
    ('Dr.Oetker', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 'D'),
    ('Dr.Oetker', 'Pizza z szynką i sosem pesto, głęboko mrożona.', 'D'),
    ('Biedronka', 'Rożek z czekoladą', 'E'),
    ('Mroźna Kraina', 'Jagody leśne', 'A'),
    ('MaxTop Sławków', 'Pizza głęboko mrożona z szynką i pieczarkami.', 'D'),
    ('Hortex', 'Makaron na patelnię penne z sosem serowym', 'B'),
    ('Fish Time', 'Ryba z piekarnika z sosem brokułowym', 'B'),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 'A'),
    ('Marletto', 'Lody o smaku śmietankowym', 'D'),
    ('Iglotex', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony.', 'C'),
    ('Bracia Koral', 'Lody śmietankowe z ciasteczkami', 'D'),
    ('Feliciana', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 'D'),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 'A'),
    ('Dr. Oetker', 'Pizza z salami i chorizo, głęboko mrożona', 'D'),
    ('Gotszlik', 'Rożek Dolce Giacomo', 'D'),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 'A'),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 'A'),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 'UNKNOWN'),
    ('Mroźna Kraina', 'Kalafior różyczki', 'A'),
    ('Mroźna kraina', 'Warzywa na patelnię letnie', 'C'),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 'A'),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 'UNKNOWN'),
    ('Asia Flavours', 'Mieszanka chińska', 'A'),
    ('NewIce', 'Plombie Śnieżynka', 'UNKNOWN'),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 'A'),
    ('ABRAMCZYK', 'KAPITAŃSKIE PALUSZKI RYBNE', 'B'),
    ('Hortex', 'Maliny mrożone', 'A'),
    ('Bracia Koral', 'Lody Jak Dawniej Śmietankowe', 'E'),
    ('Frosta', 'Złote Paluszki Rybne z Fileta', 'B'),
    ('Bracia Koral', 'Lody czekoladowe z wiśniami', 'D'),
    ('Iglotex', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie.', 'C'),
    ('Diuna', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', 'D'),
    ('Unknown', 'Jagody leśne', 'A'),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', 'D'),
    ('Kilargo', 'Marletto Almond', 'E'),
    ('Zielona Budka', 'Lody Truskawkowe', 'C'),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 'A'),
    ('Unknown', 'Lody proteinowe śmietankowe go active', 'A'),
    ('Grycan', 'Lody truskawkowe', 'D'),
    ('Kilargo', 'Marletto Salted Caramel Lava', 'E'),
    ('Hortex', 'Warzywa na patelnie', 'B'),
    ('Koral', 'Lody Kukułka', 'UNKNOWN'),
    ('Mroźna kraina', 'Warzywa na patelnie', 'UNKNOWN')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', '4'),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', '4'),
    ('Koral', 'Lody śmietankowe - kostka śnieżna', '4'),
    ('Dobra kaloria', 'Roślinna kaszanka', '4'),
    ('Grycan', 'Lody śmietankowe', '4'),
    ('Hortex', 'Warzywa na patelnię', '3'),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', '1'),
    ('Dr.Oetker', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', '4'),
    ('Dr.Oetker', 'Pizza z szynką i sosem pesto, głęboko mrożona.', '4'),
    ('Biedronka', 'Rożek z czekoladą', '4'),
    ('Mroźna Kraina', 'Jagody leśne', '1'),
    ('MaxTop Sławków', 'Pizza głęboko mrożona z szynką i pieczarkami.', '4'),
    ('Hortex', 'Makaron na patelnię penne z sosem serowym', '4'),
    ('Fish Time', 'Ryba z piekarnika z sosem brokułowym', '4'),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', '1'),
    ('Marletto', 'Lody o smaku śmietankowym', '4'),
    ('Iglotex', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony.', '4'),
    ('Bracia Koral', 'Lody śmietankowe z ciasteczkami', '4'),
    ('Feliciana', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', '4'),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', '4'),
    ('Dr. Oetker', 'Pizza z salami i chorizo, głęboko mrożona', '4'),
    ('Gotszlik', 'Rożek Dolce Giacomo', '4'),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', '1'),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', '1'),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', '4'),
    ('Mroźna Kraina', 'Kalafior różyczki', '1'),
    ('Mroźna kraina', 'Warzywa na patelnię letnie', '4'),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', '1'),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', '4'),
    ('Asia Flavours', 'Mieszanka chińska', '4'),
    ('NewIce', 'Plombie Śnieżynka', '4'),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', '4'),
    ('ABRAMCZYK', 'KAPITAŃSKIE PALUSZKI RYBNE', '4'),
    ('Hortex', 'Maliny mrożone', '4'),
    ('Bracia Koral', 'Lody Jak Dawniej Śmietankowe', '4'),
    ('Frosta', 'Złote Paluszki Rybne z Fileta', '3'),
    ('Bracia Koral', 'Lody czekoladowe z wiśniami', '4'),
    ('Iglotex', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie.', '4'),
    ('Diuna', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', '4'),
    ('Unknown', 'Jagody leśne', '1'),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', '4'),
    ('Kilargo', 'Marletto Almond', '4'),
    ('Zielona Budka', 'Lody Truskawkowe', '4'),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', '4'),
    ('Unknown', 'Lody proteinowe śmietankowe go active', '4'),
    ('Grycan', 'Lody truskawkowe', '4'),
    ('Kilargo', 'Marletto Salted Caramel Lava', '4'),
    ('Hortex', 'Warzywa na patelnie', '3'),
    ('Koral', 'Lody Kukułka', '4'),
    ('Mroźna kraina', 'Warzywa na patelnie', '3')
) as d(brand, product_name, nova)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 4. Health-risk flags
update products p set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;
