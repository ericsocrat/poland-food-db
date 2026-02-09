-- PIPELINE (Frozen & Prepared): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 5),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 1),
    ('Koral', 'Lody śmietankowe - kostka śnieżna', 5),
    ('Dobra kaloria', 'Roślinna kaszanka', 2),
    ('Grycan', 'Lody śmietankowe', 2),
    ('Hortex', 'Warzywa na patelnię', 0),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 0),
    ('Dr.Oetker', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 10),
    ('Dr.Oetker', 'Pizza z szynką i sosem pesto, głęboko mrożona.', 10),
    ('Biedronka', 'Rożek z czekoladą', 4),
    ('Mroźna Kraina', 'Jagody leśne', 0),
    ('MaxTop Sławków', 'Pizza głęboko mrożona z szynką i pieczarkami.', 3),
    ('Hortex', 'Makaron na patelnię penne z sosem serowym', 0),
    ('Fish Time', 'Ryba z piekarnika z sosem brokułowym', 4),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 0),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 0),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 0),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 0),
    ('Mroźna Kraina', 'Kalafior różyczki', 0),
    ('Mroźna kraina', 'Warzywa na patelnię letnie', 0),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 0),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 1),
    ('Asia Flavours', 'Mieszanka chińska', 0),
    ('NewIce', 'Plombie Śnieżynka', 5),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 0),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', 0),
    ('Kilargo', 'Marletto Almond', 5),
    ('Zielona Budka', 'Lody Truskawkowe', 4),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 0),
    ('Unknown', 'Lody proteinowe śmietankowe go active', 0),
    ('Grycan', 'Lody truskawkowe', 7),
    ('Kilargo', 'Marletto Salted Caramel Lava', 9),
    ('Hortex', 'Warzywa na patelnie', 0),
    ('Koral', 'Lody Kukułka', 0),
    ('Mroźna kraina', 'Warzywa na patelnie', 0)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.1)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA + processing risk
update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Unknown'
  end
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
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;
