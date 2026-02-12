-- PIPELINE (Cereals): scoring
-- Generated: 2026-02-09

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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Vitanella', 'Płatki Owsiane Górskie', 'A'),
    ('GO ACTIVE', 'GO ACTIVE  granola wysokobiałkowa', 'C'),
    ('Melvit', 'Płatki owsiane górskie', 'A'),
    ('Tymbark', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', 'E'),
    ('Mlyny Stoislaw', 'Płatki owsiane', 'A'),
    ('Kupiec', 'Ciasteczka zbożowe', 'C'),
    ('Melvit', 'Płatki owsiane Górskie XXL', 'A'),
    ('Cenos', 'Płatki owsiane błyskawiczne', 'A'),
    ('Vitanella', 'Miami Hopki', 'C'),
    ('Unknown', 'Choco kulki', 'E'),
    ('Nestlé', 'Cini Minis Scorțișoară', 'D'),
    ('Kupiec', 'Płatki owsiane błyskawiczne', 'UNKNOWN'),
    ('Unknown', 'Sante granola czekolada z truskawką', 'E'),
    ('Vitanella', 'Crunchy Klasyczne', 'C'),
    ('Nestlé', 'Corn flakes', 'C'),
    ('Lidl', 'Crownfield Płatki owsiane górskie', 'UNKNOWN'),
    ('Lubella', 'Chocko Muszelki', 'C'),
    ('Nestlé', 'Nestle Chocapic', 'C'),
    ('GO ON', 'Protein granola', 'A'),
    ('Nestlé', 'Corn Flakes', 'C'),
    ('Nestlé', 'Nestle Corn Flakes', 'C'),
    ('sante', 'Sante gold granola', 'C'),
    ('Nestlé', 'Nestke Gold flakes', 'D'),
    ('Vitanella', 'Choki', 'C'),
    ('Nestlé', 'Fitness', 'A'),
    ('Lubella', 'Owsianka z bananami, kakao', 'C'),
    ('Nestlé', 'Cheerios Owsiany', 'B'),
    ('GO ON', 'granola brownie & cherry', 'A'),
    ('Vitanella', 'Vitanella owsianka mango-truskawka', 'C'),
    ('Lubella', 'choco piegotaki', 'D'),
    ('lubella', 'chrupersy', 'D'),
    ('One Day More', 'Porridge chocolate', 'A'),
    ('Nestlé', 'Lion caramel and chocolate', 'D'),
    ('Nestlé', 'Cheerios owsiany', 'B'),
    ('Nesquik', 'Nesquik Alphabet', 'B'),
    ('Vitanella', 'Orito kakaowe', 'E'),
    ('One day more', 'Porridge', 'A'),
    ('Nesquik', 'Nesquik Mix', 'C'),
    ('Vitanella', 'Corn Flakes', 'D'),
    ('Nestlé', 'Corn flakes choco', 'D'),
    ('Ba!', 'Ba granola czekoladowa', 'D'),
    ('Lidl', 'Płatki owsiane górskie', 'A'),
    ('Lidl', 'Owsianka Żurawina', 'A'),
    ('Crownfield', 'Płatki owsiane błyskawiczne', 'A'),
    ('Crownfield', 'Space Cookies', 'C'),
    ('Crownfield', 'Goldini', 'D'),
    ('Crownfield', 'Porridge', 'B'),
    ('Lidl', 'Owsiankaowoce i orzechy', 'A')
) as d(brand, product_name, ns)
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Vitanella', 'Płatki Owsiane Górskie', '1'),
    ('GO ACTIVE', 'GO ACTIVE  granola wysokobiałkowa', '4'),
    ('Melvit', 'Płatki owsiane górskie', '1'),
    ('Tymbark', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', '4'),
    ('Mlyny Stoislaw', 'Płatki owsiane', '1'),
    ('Kupiec', 'Ciasteczka zbożowe', '4'),
    ('Melvit', 'Płatki owsiane Górskie XXL', '1'),
    ('Cenos', 'Płatki owsiane błyskawiczne', '1'),
    ('Vitanella', 'Miami Hopki', '4'),
    ('Unknown', 'Choco kulki', '4'),
    ('Nestlé', 'Cini Minis Scorțișoară', '4'),
    ('Kupiec', 'Płatki owsiane błyskawiczne', '4'),
    ('Unknown', 'Sante granola czekolada z truskawką', '4'),
    ('Vitanella', 'Crunchy Klasyczne', '4'),
    ('Nestlé', 'Corn flakes', '4'),
    ('Lidl', 'Crownfield Płatki owsiane górskie', '1'),
    ('Lubella', 'Chocko Muszelki', '4'),
    ('Nestlé', 'Nestle Chocapic', '4'),
    ('GO ON', 'Protein granola', '4'),
    ('Nestlé', 'Corn Flakes', '4'),
    ('Nestlé', 'Nestle Corn Flakes', '4'),
    ('sante', 'Sante gold granola', '4'),
    ('Nestlé', 'Nestke Gold flakes', '4'),
    ('Vitanella', 'Choki', '4'),
    ('Nestlé', 'Fitness', '4'),
    ('Lubella', 'Owsianka z bananami, kakao', '4'),
    ('Nestlé', 'Cheerios Owsiany', '4'),
    ('GO ON', 'granola brownie & cherry', '4'),
    ('Vitanella', 'Vitanella owsianka mango-truskawka', '3'),
    ('Lubella', 'choco piegotaki', '4'),
    ('lubella', 'chrupersy', '4'),
    ('One Day More', 'Porridge chocolate', '4'),
    ('Nestlé', 'Lion caramel and chocolate', '4'),
    ('Nestlé', 'Cheerios owsiany', '4'),
    ('Nesquik', 'Nesquik Alphabet', '4'),
    ('Vitanella', 'Orito kakaowe', '4'),
    ('One day more', 'Porridge', '4'),
    ('Nesquik', 'Nesquik Mix', '4'),
    ('Vitanella', 'Corn Flakes', '4'),
    ('Nestlé', 'Corn flakes choco', '4'),
    ('Ba!', 'Ba granola czekoladowa', '4'),
    ('Lidl', 'Płatki owsiane górskie', '1'),
    ('Lidl', 'Owsianka Żurawina', '4'),
    ('Crownfield', 'Płatki owsiane błyskawiczne', '4'),
    ('Crownfield', 'Space Cookies', '4'),
    ('Crownfield', 'Goldini', '4'),
    ('Crownfield', 'Porridge', '4'),
    ('Lidl', 'Owsiankaowoce i orzechy', '1')
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

-- 5. SET confidence level
update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;
