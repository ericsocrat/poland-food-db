-- PIPELINE (Cereals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Cereals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906827021585', '5907437368138', '5906827003802', '5900334020109', '5900563000088', '5906747176884', '5906827016536', '5900977012066', '5907437365489', '5900049004487', '5900020002730', '5902172000220', '5900617043160', '5900749610544', '5900020000774', '4056489180968', '5900049004470', '5900020000590', '5900617039262', '5900020019592', '5900020004697', '5900617037152', '5900020000538', '5907437366059', '5900020020895', '5900049822708', '5900020035899', '5900617043481', '5907437366974', '5900049011621', '5900049824238', '5902884462620', '5900020021625', '5900020035929', '5900020020635', '5907437367919', '5902884464525', '5900020013491', '5907437361474', '5900020026439', '5900749651325', '4056489254140', '4056489654261', '20346485', '20982119', '20061449', '4056489064497', '20639747')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Płatki Owsiane Górskie', null, 'Biedronka', 'none', '5906827021585'),
  ('PL', 'GO ACTIVE', 'Grocery', 'Cereals', 'GO ACTIVE  granola wysokobiałkowa', null, 'Biedronka', 'none', '5907437368138'),
  ('PL', 'Melvit', 'Grocery', 'Cereals', 'Płatki owsiane górskie', null, null, 'none', '5906827003802'),
  ('PL', 'Tymbark', 'Grocery', 'Cereals', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', null, null, 'none', '5900334020109'),
  ('PL', 'Mlyny Stoislaw', 'Grocery', 'Cereals', 'Płatki owsiane', null, null, 'none', '5900563000088'),
  ('PL', 'Kupiec', 'Grocery', 'Cereals', 'Ciasteczka zbożowe', null, null, 'none', '5906747176884'),
  ('PL', 'Melvit', 'Grocery', 'Cereals', 'Płatki owsiane Górskie XXL', null, null, 'none', '5906827016536'),
  ('PL', 'Cenos', 'Grocery', 'Cereals', 'Płatki owsiane błyskawiczne', null, null, 'none', '5900977012066'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Miami Hopki', null, 'Biedronka', 'none', '5907437365489'),
  ('PL', 'Unknown', 'Grocery', 'Cereals', 'Choco kulki', null, 'Biedronka', 'none', '5900049004487'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Cini Minis Scorțișoară', null, 'Biedronka,Lidl', 'none', '5900020002730'),
  ('PL', 'Kupiec', 'Grocery', 'Cereals', 'Płatki owsiane błyskawiczne', null, null, 'none', '5902172000220'),
  ('PL', 'Unknown', 'Grocery', 'Cereals', 'Sante granola czekolada z truskawką', null, null, 'none', '5900617043160'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Crunchy Klasyczne', null, 'Biedronka', 'none', '5900749610544'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Corn flakes', null, null, 'none', '5900020000774'),
  ('PL', 'Lidl', 'Grocery', 'Cereals', 'Crownfield Płatki owsiane górskie', null, 'Lidl', 'none', '4056489180968'),
  ('PL', 'Lubella', 'Grocery', 'Cereals', 'Chocko Muszelki', null, null, 'none', '5900049004470'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Nestle Chocapic', null, null, 'none', '5900020000590'),
  ('PL', 'GO ON', 'Grocery', 'Cereals', 'Protein granola', null, null, 'none', '5900617039262'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Corn Flakes', null, null, 'none', '5900020019592'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Nestle Corn Flakes', null, null, 'none', '5900020004697'),
  ('PL', 'sante', 'Grocery', 'Cereals', 'Sante gold granola', null, 'sultan center', 'none', '5900617037152'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Nestke Gold flakes', null, null, 'none', '5900020000538'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Choki', null, null, 'none', '5907437366059'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Fitness', null, null, 'none', '5900020020895'),
  ('PL', 'Lubella', 'Grocery', 'Cereals', 'Owsianka z bananami, kakao', null, null, 'none', '5900049822708'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Cheerios Owsiany', null, null, 'none', '5900020035899'),
  ('PL', 'GO ON', 'Grocery', 'Cereals', 'granola brownie & cherry', null, null, 'none', '5900617043481'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Vitanella owsianka mango-truskawka', null, null, 'none', '5907437366974'),
  ('PL', 'Lubella', 'Grocery', 'Cereals', 'choco piegotaki', null, null, 'none', '5900049011621'),
  ('PL', 'lubella', 'Grocery', 'Cereals', 'chrupersy', null, null, 'none', '5900049824238'),
  ('PL', 'One Day More', 'Grocery', 'Cereals', 'Porridge chocolate', null, null, 'none', '5902884462620'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Lion caramel and chocolate', null, null, 'none', '5900020021625'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Cheerios owsiany', null, null, 'none', '5900020035929'),
  ('PL', 'Nesquik', 'Grocery', 'Cereals', 'Nesquik Alphabet', null, null, 'none', '5900020020635'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Orito kakaowe', null, null, 'none', '5907437367919'),
  ('PL', 'One day more', 'Grocery', 'Cereals', 'Porridge', null, null, 'none', '5902884464525'),
  ('PL', 'Nesquik', 'Grocery', 'Cereals', 'Nesquik Mix', null, null, 'none', '5900020013491'),
  ('PL', 'Vitanella', 'Grocery', 'Cereals', 'Corn Flakes', null, null, 'none', '5907437361474'),
  ('PL', 'Nestlé', 'Grocery', 'Cereals', 'Corn flakes choco', null, null, 'none', '5900020026439'),
  ('PL', 'Ba!', 'Grocery', 'Cereals', 'Ba granola czekoladowa', null, null, 'none', '5900749651325'),
  ('PL', 'Lidl', 'Grocery', 'Cereals', 'Płatki owsiane górskie', null, null, 'none', '4056489254140'),
  ('PL', 'Lidl', 'Grocery', 'Cereals', 'Owsianka Żurawina', null, null, 'none', '4056489654261'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Płatki owsiane błyskawiczne', null, null, 'none', '20346485'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Space Cookies', null, 'Lidl', 'none', '20982119'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Goldini', null, 'Lidl', 'none', '20061449'),
  ('PL', 'Crownfield', 'Grocery', 'Cereals', 'Porridge', null, null, 'none', '4056489064497'),
  ('PL', 'Lidl', 'Grocery', 'Cereals', 'Owsiankaowoce i orzechy', null, null, 'none', '20639747')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Cereals'
  and is_deprecated is not true
  and product_name not in ('Płatki Owsiane Górskie', 'GO ACTIVE  granola wysokobiałkowa', 'Płatki owsiane górskie', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', 'Płatki owsiane', 'Ciasteczka zbożowe', 'Płatki owsiane Górskie XXL', 'Płatki owsiane błyskawiczne', 'Miami Hopki', 'Choco kulki', 'Cini Minis Scorțișoară', 'Płatki owsiane błyskawiczne', 'Sante granola czekolada z truskawką', 'Crunchy Klasyczne', 'Corn flakes', 'Crownfield Płatki owsiane górskie', 'Chocko Muszelki', 'Nestle Chocapic', 'Protein granola', 'Corn Flakes', 'Nestle Corn Flakes', 'Sante gold granola', 'Nestke Gold flakes', 'Choki', 'Fitness', 'Owsianka z bananami, kakao', 'Cheerios Owsiany', 'granola brownie & cherry', 'Vitanella owsianka mango-truskawka', 'choco piegotaki', 'chrupersy', 'Porridge chocolate', 'Lion caramel and chocolate', 'Cheerios owsiany', 'Nesquik Alphabet', 'Orito kakaowe', 'Porridge', 'Nesquik Mix', 'Corn Flakes', 'Corn flakes choco', 'Ba granola czekoladowa', 'Płatki owsiane górskie', 'Owsianka Żurawina', 'Płatki owsiane błyskawiczne', 'Space Cookies', 'Goldini', 'Porridge', 'Owsiankaowoce i orzechy');
