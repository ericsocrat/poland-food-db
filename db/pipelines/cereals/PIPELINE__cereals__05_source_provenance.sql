-- PIPELINE (Cereals): source provenance
-- Generated: 2026-02-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Ba', 'Ba granola czekoladowa', 'https://world.openfoodfacts.org/product/5900749651325', '5900749651325'),
    ('Cenos', 'Płatki owsiane błyskawiczne', 'https://world.openfoodfacts.org/product/5900977012066', '5900977012066'),
    ('Crownfield', 'Goldini', 'https://world.openfoodfacts.org/product/20061449', '20061449'),
    ('Crownfield', 'Płatki owsiane błyskawiczne', 'https://world.openfoodfacts.org/product/20346485', '20346485'),
    ('Crownfield', 'Porridge', 'https://world.openfoodfacts.org/product/4056489064497', '4056489064497'),
    ('Crownfield', 'Space Cookies', 'https://world.openfoodfacts.org/product/20982119', '20982119'),
    ('Go On', 'Protein granola', 'https://world.openfoodfacts.org/product/5900617039262', '5900617039262'),
    ('Kupiec', 'Ciasteczka zbożowe', 'https://world.openfoodfacts.org/product/5906747176884', '5906747176884'),
    ('Kupiec', 'Płatki owsiane błyskawiczne', 'https://world.openfoodfacts.org/product/5902172000220', '5902172000220'),
    ('Lidl', 'Crownfield Płatki owsiane górskie', 'https://world.openfoodfacts.org/product/4056489180968', '4056489180968'),
    ('Lidl', 'Owsianka Żurawina', 'https://world.openfoodfacts.org/product/4056489654261', '4056489654261'),
    ('Lidl', 'Owsiankaowoce i orzechy', 'https://world.openfoodfacts.org/product/20639747', '20639747'),
    ('Lidl', 'Płatki owsiane górskie', 'https://world.openfoodfacts.org/product/4056489254140', '4056489254140'),
    ('Lubella', 'Chocko Muszelki', 'https://world.openfoodfacts.org/product/5900049004470', '5900049004470'),
    ('Lubella', 'Owsianka z bananami, kakao', 'https://world.openfoodfacts.org/product/5900049822708', '5900049822708'),
    ('Melvit', 'Płatki owsiane górskie', 'https://world.openfoodfacts.org/product/5906827003802', '5906827003802'),
    ('Melvit', 'Płatki owsiane Górskie XXL', 'https://world.openfoodfacts.org/product/5906827016536', '5906827016536'),
    ('Mlyny Stoislaw', 'Płatki owsiane', 'https://world.openfoodfacts.org/product/5900563000088', '5900563000088'),
    ('Nesquik', 'Nesquik Alphabet', 'https://world.openfoodfacts.org/product/5900020020635', '5900020020635'),
    ('Nesquik', 'Nesquik Mix', 'https://world.openfoodfacts.org/product/5900020013491', '5900020013491'),
    ('Nestlé', 'Cheerios Owsiany', 'https://world.openfoodfacts.org/product/5900020035899', '5900020035899'),
    ('Nestlé', 'Cini Minis Scorțișoară', 'https://world.openfoodfacts.org/product/5900020002730', '5900020002730'),
    ('Nestlé', 'Corn flakes', 'https://world.openfoodfacts.org/product/5900020000774', '5900020000774'),
    ('Nestlé', 'Corn flakes choco', 'https://world.openfoodfacts.org/product/5900020026439', '5900020026439'),
    ('Nestlé', 'Fitness', 'https://world.openfoodfacts.org/product/5900020020895', '5900020020895'),
    ('Nestlé', 'Lion caramel and chocolate', 'https://world.openfoodfacts.org/product/5900020021625', '5900020021625'),
    ('Nestlé', 'Nestke Gold flakes', 'https://world.openfoodfacts.org/product/5900020000538', '5900020000538'),
    ('Nestlé', 'Nestle Chocapic', 'https://world.openfoodfacts.org/product/5900020000590', '5900020000590'),
    ('Nestlé', 'Nestle Corn Flakes', 'https://world.openfoodfacts.org/product/5900020004697', '5900020004697'),
    ('One Day More', 'Porridge', 'https://world.openfoodfacts.org/product/5902884464525', '5902884464525'),
    ('One Day More', 'Porridge chocolate', 'https://world.openfoodfacts.org/product/5902884462620', '5902884462620'),
    ('Sante', 'Sante gold granola', 'https://world.openfoodfacts.org/product/5900617037152', '5900617037152'),
    ('Tymbark', 'Mus wieloowocowy z dodatkiem kaszy manny i płatków owsianych', 'https://world.openfoodfacts.org/product/5900334020109', '5900334020109'),
    ('Unknown', 'Choco kulki', 'https://world.openfoodfacts.org/product/5900049004487', '5900049004487'),
    ('Unknown', 'Sante granola czekolada z truskawką', 'https://world.openfoodfacts.org/product/5900617043160', '5900617043160'),
    ('Vitanella', 'Choki', 'https://world.openfoodfacts.org/product/5907437366059', '5907437366059'),
    ('Vitanella', 'Corn Flakes', 'https://world.openfoodfacts.org/product/5907437361474', '5907437361474'),
    ('Vitanella', 'Crunchy Klasyczne', 'https://world.openfoodfacts.org/product/5900749610544', '5900749610544'),
    ('Vitanella', 'Miami Hopki', 'https://world.openfoodfacts.org/product/5907437365489', '5907437365489'),
    ('Vitanella', 'Orito kakaowe', 'https://world.openfoodfacts.org/product/5907437367919', '5907437367919'),
    ('Vitanella', 'Płatki Owsiane Górskie', 'https://world.openfoodfacts.org/product/5906827021585', '5906827021585'),
    ('Vitanella', 'Vitanella owsianka mango-truskawka', 'https://world.openfoodfacts.org/product/5907437366974', '5907437366974')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;
