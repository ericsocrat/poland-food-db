-- PIPELINE (Frozen & Prepared): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Dr. Oetker', 'Pizza 4 sery, głęboko mrożona.', 'https://world.openfoodfacts.org/product/5900437007137', '5900437007137'),
    ('Swojska Chata', 'Pierogi z kapustą i grzybami', 'https://world.openfoodfacts.org/product/5901398069936', '5901398069936'),
    ('Koral', 'Lody śmietankowe - kostka śnieżna', 'https://world.openfoodfacts.org/product/5902121011765', '5902121011765'),
    ('Dobra kaloria', 'Roślinna kaszanka', 'https://world.openfoodfacts.org/product/5903548004262', '5903548004262'),
    ('Grycan', 'Lody śmietankowe', 'https://world.openfoodfacts.org/product/5907439112135', '5907439112135'),
    ('Hortex', 'Warzywa na patelnię', 'https://world.openfoodfacts.org/product/5900477000846', '5900477000846'),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 'https://world.openfoodfacts.org/product/5901581232413', '5901581232413'),
    ('Dr.Oetker', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 'https://world.openfoodfacts.org/product/5900437009988', '5900437009988'),
    ('Dr.Oetker', 'Pizza z szynką i sosem pesto, głęboko mrożona.', 'https://world.openfoodfacts.org/product/5900437007113', '5900437007113'),
    ('Biedronka', 'Rożek z czekoladą', 'https://world.openfoodfacts.org/product/5907377116578', '5907377116578'),
    ('Mroźna Kraina', 'Jagody leśne', 'https://world.openfoodfacts.org/product/5902966009002', '5902966009002'),
    ('MaxTop Sławków', 'Pizza głęboko mrożona z szynką i pieczarkami.', 'https://world.openfoodfacts.org/product/5901537003142', '5901537003142'),
    ('Hortex', 'Makaron na patelnię penne z sosem serowym', 'https://world.openfoodfacts.org/product/5900477012795', '5900477012795'),
    ('Fish Time', 'Ryba z piekarnika z sosem brokułowym', 'https://world.openfoodfacts.org/product/5900972003960', '5900972003960'),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 'https://world.openfoodfacts.org/product/5901581232352', '5901581232352'),
    ('Marletto', 'Lody o smaku śmietankowym', 'https://world.openfoodfacts.org/product/5907377115113', '5907377115113'),
    ('Iglotex', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony.', 'https://world.openfoodfacts.org/product/5902162120716', '5902162120716'),
    ('Bracia Koral', 'Lody śmietankowe z ciasteczkami', 'https://world.openfoodfacts.org/product/5902121022204', '5902121022204'),
    ('Feliciana', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 'https://world.openfoodfacts.org/product/5900437005010', '5900437005010'),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 'https://world.openfoodfacts.org/product/5900972010647', '5900972010647'),
    ('Dr. Oetker', 'Pizza z salami i chorizo, głęboko mrożona', 'https://world.openfoodfacts.org/product/5900437007151', '5900437007151'),
    ('Gotszlik', 'Rożek Dolce Giacomo', 'https://world.openfoodfacts.org/product/5902729241199', '5902729241199'),
    ('Mroźna Kraina', 'Fasolka szparagowa żółta i zielona, cała', 'https://world.openfoodfacts.org/product/5901028916616', '5901028916616'),
    ('Mroźna Kraina', 'Trio warzywne z mini marchewką', 'https://world.openfoodfacts.org/product/5901028908055', '5901028908055'),
    ('Mroźna Kraina', 'Warzywa na patelnię po włosku', 'https://world.openfoodfacts.org/product/5903154542622', '5903154542622'),
    ('Mroźna Kraina', 'Kalafior różyczki', 'https://world.openfoodfacts.org/product/5901028917422', '5901028917422'),
    ('Mroźna kraina', 'Warzywa na patelnię letnie', 'https://world.openfoodfacts.org/product/5901028917941', '5901028917941'),
    ('Mroźna Kraina', 'Polskie wiśnie bez pestek', 'https://world.openfoodfacts.org/product/5901028917378', '5901028917378'),
    ('Mroźna Kraina', 'Warzywa na patelnię po meksykańsku', 'https://world.openfoodfacts.org/product/5901028913479', '5901028913479'),
    ('Asia Flavours', 'Mieszanka chińska', 'https://world.openfoodfacts.org/product/5901028917354', '5901028917354'),
    ('NewIce', 'Plombie Śnieżynka', 'https://world.openfoodfacts.org/product/5908280713045', '5908280713045'),
    ('Mroźna Kraina', 'Warzywa na patelnię po europejsku', 'https://world.openfoodfacts.org/product/5901028917972', '5901028917972'),
    ('ABRAMCZYK', 'KAPITAŃSKIE PALUSZKI RYBNE', 'https://world.openfoodfacts.org/product/5907555217431', '5907555217431'),
    ('Hortex', 'Maliny mrożone', 'https://world.openfoodfacts.org/product/5900477013747', '5900477013747'),
    ('Bracia Koral', 'Lody Jak Dawniej Śmietankowe', 'https://world.openfoodfacts.org/product/5902121018955', '5902121018955'),
    ('Frosta', 'Złote Paluszki Rybne z Fileta', 'https://world.openfoodfacts.org/product/5900972008293', '5900972008293'),
    ('Bracia Koral', 'Lody czekoladowe z wiśniami', 'https://world.openfoodfacts.org/product/5902121024116', '5902121024116'),
    ('Iglotex', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie.', 'https://world.openfoodfacts.org/product/5902162105713', '5902162105713'),
    ('Diuna', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', 'https://world.openfoodfacts.org/product/5907377114758', '5907377114758'),
    ('Unknown', 'Jagody leśne', 'https://world.openfoodfacts.org/product/5901028915541', '5901028915541'),
    ('Dr. Oetker', 'Pizza Guseppe z szynką i pieczarkami', 'https://world.openfoodfacts.org/product/5900437205137', '5900437205137'),
    ('Kilargo', 'Marletto Almond', 'https://world.openfoodfacts.org/product/5907377116646', '5907377116646'),
    ('Zielona Budka', 'Lody Truskawkowe', 'https://world.openfoodfacts.org/product/5900130015835', '5900130015835'),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 'https://world.openfoodfacts.org/product/5901028913103', '5901028913103'),
    ('Unknown', 'Lody proteinowe śmietankowe go active', 'https://world.openfoodfacts.org/product/5902533424665', '5902533424665'),
    ('Grycan', 'Lody truskawkowe', 'https://world.openfoodfacts.org/product/5907439112067', '5907439112067'),
    ('Kilargo', 'Marletto Salted Caramel Lava', 'https://world.openfoodfacts.org/product/5907377116677', '5907377116677'),
    ('Hortex', 'Warzywa na patelnie', 'https://world.openfoodfacts.org/product/5900477000839', '5900477000839'),
    ('Koral', 'Lody Kukułka', 'https://world.openfoodfacts.org/product/5902121009793', '5902121009793'),
    ('Mroźna kraina', 'Warzywa na patelnie', 'https://world.openfoodfacts.org/product/5901028913387', '5901028913387')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Frozen & Prepared' AND p.is_deprecated IS NOT TRUE;
