-- PIPELINE (Bread): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Gursz', 'Chleb Pszenno-Żytni', 1),
    ('Lajkonik', 'Paluszki słone', 2),
    ('Dan Cake', 'Bułeczki mleczne z czekoladą', 4),
    ('Pano', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', 0),
    ('Pano', 'Hot dog pszenno-żytni', 2),
    ('Mestemacher', 'Chleb wielozbożowy żytni pełnoziarnisty', 1),
    ('Auchan', 'Bułki do Hamburgerów', 0),
    ('Auchan', 'Tost pełnoziarnisty', 0),
    ('Vital', 'Bułki śniadaniowe', 3),
    ('Pano', 'Bułka tarta', 0),
    ('Piekarnia Gwóźdź', 'Chleb z mąką krojony - pieczywo mieszane', 1),
    ('Pano', 'Bułka do hot doga', 2),
    ('Auchan', 'Tortilla Pszenno-Żytnia', 9),
    ('Pano', 'Tost pełnoziarnisty', 0),
    ('Pano', 'Tost  maślany', 0),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 0),
    ('Pano', 'Chleb żytni', 0),
    ('Dan Cake', 'Mleczne bułeczki', 1),
    ('Sonko', 'Lekkie żytnie', 1),
    ('Lantmannen Unibake', 'Bułki pszenne do hot dogów.', 1),
    ('Aksam', 'Beskidzkie paluszki z solą', 3),
    ('Wypieczone ze smakiem', 'Chleb żytni z ziarnami', 0),
    ('Pano', 'Bułeczki śniadaniowe', 3),
    ('Spółdzielnia piekarsko ciastkarska w Warszawie', 'Chleb wieloziarnisty złoty łan', 0),
    ('PANO', 'Chleb wieloziarnisty Złoty Łan', 0),
    ('Z Piekarni Regionalnej', 'Chleb zytni ze słonecznikiem', 0),
    ('Pano', 'Bułki do hamburgerów z sezamem', 2),
    ('Sonko', 'Lekkie ze słonecznikiem', 1),
    ('Mastemacher', 'Chleb żytni', 0),
    ('Sendal', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', 0),
    ('Carrefour', 'Chleb tostowy maślany', 0),
    ('Oskroba', 'Chleb żytni razowy', 0),
    ('VITAL', 'Bułki z ziarnami', 0),
    ('DAN CAKE', 'Bułki śniadaniowe', 1),
    ('Sendal', 'Chleb na maślance', 0),
    ('Lajkonik', 'Bajgle z ziołami prowansalskimi', 1),
    ('Dan cake', 'Tost pełnoziarnisty', 2),
    ('Piekarnia Wilkowo', 'Chleb pszenno-żytni', 1),
    ('Dan Cake', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku.', 3),
    ('Sendal', 'Chleb żytni bez drożdzy', 0),
    ('Piekarnia Oskrobia', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony.', 0),
    ('Mika', 'Chleb żytni razowy', 0),
    ('Putka', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', 0),
    ('Pano', 'Tortilla', 5),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 0),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 0),
    ('Bite IT', 'LAWASZ pszenny chleb', 0),
    ('Gwóźdź', 'Chleb wieloziarnisty', 0),
    ('Oskroba', 'Tost maślany', 0),
    ('Z dobrej piekarni', 'Chleb baltonowski', 0),
    ('Carrefour', 'Tortilla pszenna', 0),
    ('Z Dobrej Piekarni', 'Chleb wieloziarnisty', 0),
    ('Shulstad', 'Classic Pszenny Hot Dog', 3),
    ('Oskroba', 'Chleb żytni pełnoziarnisty pasteryzowany', 0),
    ('Dakri', 'Pinsa', 1),
    ('Żabka', 'Kajzerka kebab', 0),
    ('Asprod', 'Chleb jakubowy żytni razowy', 0),
    ('Biedronka piekarnia gwóźdź', 'Chleb żytni', 0),
    ('Piekarnia &quot;Pod Rogalem&quot;', 'Chleb Baltonowski krojony', 0),
    ('Piekarnia Jesse', 'Chleb wieloziarnisty ciemny', 2)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- 2. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  ),
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Gursz', 'Chleb Pszenno-Żytni', 'C'),
    ('Lajkonik', 'Paluszki słone', 'D'),
    ('Dan Cake', 'Bułeczki mleczne z czekoladą', 'D'),
    ('Pano', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', 'B'),
    ('Pano', 'Hot dog pszenno-żytni', 'C'),
    ('Mestemacher', 'Chleb wielozbożowy żytni pełnoziarnisty', 'B'),
    ('Auchan', 'Bułki do Hamburgerów', 'D'),
    ('Auchan', 'Tost pełnoziarnisty', 'C'),
    ('Vital', 'Bułki śniadaniowe', 'C'),
    ('Pano', 'Bułka tarta', 'A'),
    ('Piekarnia Gwóźdź', 'Chleb z mąką krojony - pieczywo mieszane', 'C'),
    ('Pano', 'Bułka do hot doga', 'D'),
    ('Auchan', 'Tortilla Pszenno-Żytnia', 'D'),
    ('Pano', 'Tost pełnoziarnisty', 'B'),
    ('Pano', 'Tost  maślany', 'C'),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 'D'),
    ('Pano', 'Chleb żytni', 'A'),
    ('Dan Cake', 'Mleczne bułeczki', 'D'),
    ('Sonko', 'Lekkie żytnie', 'B'),
    ('Lantmannen Unibake', 'Bułki pszenne do hot dogów.', 'C'),
    ('Aksam', 'Beskidzkie paluszki z solą', 'E'),
    ('Wypieczone ze smakiem', 'Chleb żytni z ziarnami', 'C'),
    ('Pano', 'Bułeczki śniadaniowe', 'D'),
    ('Spółdzielnia piekarsko ciastkarska w Warszawie', 'Chleb wieloziarnisty złoty łan', 'B'),
    ('PANO', 'Chleb wieloziarnisty Złoty Łan', 'E'),
    ('Z Piekarni Regionalnej', 'Chleb zytni ze słonecznikiem', 'C'),
    ('Pano', 'Bułki do hamburgerów z sezamem', 'C'),
    ('Sonko', 'Lekkie ze słonecznikiem', 'UNKNOWN'),
    ('Mastemacher', 'Chleb żytni', 'C'),
    ('Sendal', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', 'C'),
    ('Carrefour', 'Chleb tostowy maślany', 'C'),
    ('Oskroba', 'Chleb żytni razowy', 'C'),
    ('VITAL', 'Bułki z ziarnami', 'C'),
    ('DAN CAKE', 'Bułki śniadaniowe', 'C'),
    ('Sendal', 'Chleb na maślance', 'C'),
    ('Lajkonik', 'Bajgle z ziołami prowansalskimi', 'D'),
    ('Dan cake', 'Tost pełnoziarnisty', 'C'),
    ('Piekarnia Wilkowo', 'Chleb pszenno-żytni', 'C'),
    ('Dan Cake', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku.', 'C'),
    ('Sendal', 'Chleb żytni bez drożdzy', 'B'),
    ('Piekarnia Oskrobia', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony.', 'C'),
    ('Mika', 'Chleb żytni razowy', 'C'),
    ('Putka', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', 'B'),
    ('Pano', 'Tortilla', 'C'),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 'A'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 'C'),
    ('Bite IT', 'LAWASZ pszenny chleb', 'C'),
    ('Gwóźdź', 'Chleb wieloziarnisty', 'B'),
    ('Oskroba', 'Tost maślany', 'C'),
    ('Z dobrej piekarni', 'Chleb baltonowski', 'C'),
    ('Carrefour', 'Tortilla pszenna', 'C'),
    ('Z Dobrej Piekarni', 'Chleb wieloziarnisty', 'C'),
    ('Shulstad', 'Classic Pszenny Hot Dog', 'B'),
    ('Oskroba', 'Chleb żytni pełnoziarnisty pasteryzowany', 'C'),
    ('Dakri', 'Pinsa', 'C'),
    ('Żabka', 'Kajzerka kebab', 'D'),
    ('Asprod', 'Chleb jakubowy żytni razowy', 'A'),
    ('Biedronka piekarnia gwóźdź', 'Chleb żytni', 'D'),
    ('Piekarnia &quot;Pod Rogalem&quot;', 'Chleb Baltonowski krojony', 'C'),
    ('Piekarnia Jesse', 'Chleb wieloziarnisty ciemny', 'C')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA classification
update scores sc set
  nova_classification = d.nova
from (
  values
    ('Gursz', 'Chleb Pszenno-Żytni', '4'),
    ('Lajkonik', 'Paluszki słone', '3'),
    ('Dan Cake', 'Bułeczki mleczne z czekoladą', '4'),
    ('Pano', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', '4'),
    ('Pano', 'Hot dog pszenno-żytni', '4'),
    ('Mestemacher', 'Chleb wielozbożowy żytni pełnoziarnisty', '4'),
    ('Auchan', 'Bułki do Hamburgerów', '3'),
    ('Auchan', 'Tost pełnoziarnisty', '4'),
    ('Vital', 'Bułki śniadaniowe', '4'),
    ('Pano', 'Bułka tarta', '3'),
    ('Piekarnia Gwóźdź', 'Chleb z mąką krojony - pieczywo mieszane', '4'),
    ('Pano', 'Bułka do hot doga', '4'),
    ('Auchan', 'Tortilla Pszenno-Żytnia', '4'),
    ('Pano', 'Tost pełnoziarnisty', '4'),
    ('Pano', 'Tost  maślany', '3'),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', '3'),
    ('Pano', 'Chleb żytni', '3'),
    ('Dan Cake', 'Mleczne bułeczki', '4'),
    ('Sonko', 'Lekkie żytnie', '4'),
    ('Lantmannen Unibake', 'Bułki pszenne do hot dogów.', '3'),
    ('Aksam', 'Beskidzkie paluszki z solą', '4'),
    ('Wypieczone ze smakiem', 'Chleb żytni z ziarnami', '4'),
    ('Pano', 'Bułeczki śniadaniowe', '4'),
    ('Spółdzielnia piekarsko ciastkarska w Warszawie', 'Chleb wieloziarnisty złoty łan', '4'),
    ('PANO', 'Chleb wieloziarnisty Złoty Łan', '4'),
    ('Z Piekarni Regionalnej', 'Chleb zytni ze słonecznikiem', '1'),
    ('Pano', 'Bułki do hamburgerów z sezamem', '4'),
    ('Sonko', 'Lekkie ze słonecznikiem', '4'),
    ('Mastemacher', 'Chleb żytni', '4'),
    ('Sendal', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', '3'),
    ('Carrefour', 'Chleb tostowy maślany', '4'),
    ('Oskroba', 'Chleb żytni razowy', '4'),
    ('VITAL', 'Bułki z ziarnami', '4'),
    ('DAN CAKE', 'Bułki śniadaniowe', '4'),
    ('Sendal', 'Chleb na maślance', '4'),
    ('Lajkonik', 'Bajgle z ziołami prowansalskimi', '4'),
    ('Dan cake', 'Tost pełnoziarnisty', '3'),
    ('Piekarnia Wilkowo', 'Chleb pszenno-żytni', '4'),
    ('Dan Cake', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku.', '4'),
    ('Sendal', 'Chleb żytni bez drożdzy', '3'),
    ('Piekarnia Oskrobia', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony.', '4'),
    ('Mika', 'Chleb żytni razowy', '3'),
    ('Putka', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', '4'),
    ('Pano', 'Tortilla', '4'),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', '4'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', '3'),
    ('Bite IT', 'LAWASZ pszenny chleb', '3'),
    ('Gwóźdź', 'Chleb wieloziarnisty', '4'),
    ('Oskroba', 'Tost maślany', '4'),
    ('Z dobrej piekarni', 'Chleb baltonowski', '3'),
    ('Carrefour', 'Tortilla pszenna', '4'),
    ('Z Dobrej Piekarni', 'Chleb wieloziarnisty', '3'),
    ('Shulstad', 'Classic Pszenny Hot Dog', '4'),
    ('Oskroba', 'Chleb żytni pełnoziarnisty pasteryzowany', '4'),
    ('Dakri', 'Pinsa', '4'),
    ('Żabka', 'Kajzerka kebab', '4'),
    ('Asprod', 'Chleb jakubowy żytni razowy', '4'),
    ('Biedronka piekarnia gwóźdź', 'Chleb żytni', '4'),
    ('Piekarnia &quot;Pod Rogalem&quot;', 'Chleb Baltonowski krojony', '3'),
    ('Piekarnia Jesse', 'Chleb wieloziarnisty ciemny', '4')
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
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;
