-- PIPELINE (Cereals): scoring
-- Generated: 2026-02-09

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Vitanella', 'Płatki Owsiane Górskie', 0),
    ('GO ACTIVE', 'GO ACTIVE  granola wysokobiałkowa', 1),
    ('Melvit', 'Płatki owsiane górskie', 0),
    ('Tymbark', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', 0),
    ('Mlyny Stoislaw', 'Płatki owsiane', 0),
    ('Kupiec', 'Ciasteczka zbożowe', 3),
    ('Melvit', 'Płatki owsiane Górskie XXL', 0),
    ('Cenos', 'Płatki owsiane błyskawiczne', 0),
    ('Vitanella', 'Miami Hopki', 0),
    ('Unknown', 'Choco kulki', 0),
    ('Nestlé', 'Cini Minis Scorțișoară', 0),
    ('Kupiec', 'Płatki owsiane błyskawiczne', 0),
    ('Unknown', 'Sante granola czekolada z truskawką', 0),
    ('Vitanella', 'Crunchy Klasyczne', 1),
    ('Nestlé', 'Corn flakes', 1),
    ('Lidl', 'Crownfield Płatki owsiane górskie', 0),
    ('Lubella', 'Chocko Muszelki', 0),
    ('Nestlé', 'Nestle Chocapic', 1),
    ('GO ON', 'Protein granola', 4),
    ('Nestlé', 'Corn Flakes', 1),
    ('Nestlé', 'Nestle Corn Flakes', 0),
    ('sante', 'Sante gold granola', 2),
    ('Nestlé', 'Nestke Gold flakes', 0),
    ('Vitanella', 'Choki', 0),
    ('Nestlé', 'Fitness', 0),
    ('Lubella', 'Owsianka z bananami, kakao', 0),
    ('Nestlé', 'Cheerios Owsiany', 3),
    ('GO ON', 'granola brownie & cherry', 3),
    ('Vitanella', 'Vitanella owsianka mango-truskawka', 0),
    ('Lubella', 'choco piegotaki', 1),
    ('lubella', 'chrupersy', 0),
    ('One Day More', 'Porridge chocolate', 1),
    ('Nestlé', 'Lion caramel and chocolate', 0),
    ('Nestlé', 'Cheerios owsiany', 3),
    ('Nesquik', 'Nesquik Alphabet', 1),
    ('Vitanella', 'Orito kakaowe', 2),
    ('One day more', 'Porridge', 0),
    ('Nesquik', 'Nesquik Mix', 0),
    ('Vitanella', 'Corn Flakes', 0),
    ('Nestlé', 'Corn flakes choco', 0),
    ('Ba!', 'Ba granola czekoladowa', 0),
    ('Lidl', 'Płatki owsiane górskie', 0),
    ('Lidl', 'Owsianka Żurawina', 0),
    ('Crownfield', 'Płatki owsiane błyskawiczne', 0),
    ('Crownfield', 'Space Cookies', 2),
    ('Crownfield', 'Goldini', 1),
    ('Crownfield', 'Porridge', 1),
    ('Lidl', 'Owsiankaowoce i orzechy', 0)
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;
