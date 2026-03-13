-- PIPELINE (Cereals): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-12

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Vitanella', 'Płatki Owsiane Górskie', 'Biedronka'),
    ('Dobra karma', 'Owsianka z białą czekoladą mango-marakuja', 'Żabka'),
    ('Go Active', 'GO ACTIVE granola wysokobiałkowa', 'Biedronka'),
    ('Auchan', 'Płatki ryżowe błyskawiczne', 'Auchan'),
    ('Plony Natury', 'Płatki Owsiane Górskie', 'Biedronka'),
    ('Plony natury', 'Płatki owsiane błyskawiczne', 'Biedronka'),
    ('Chaber', 'Jaśki z kremem o smaku mlecznym', 'Auchan'),
    ('Bakalland', 'Ba! fit grain - 5 zbóż i truskawka', 'Biedronka'),
    ('Bell''s', 'Bell''s Jaglanka Chia jagoda i żurawina', 'Netto'),
    ('Szczytno Premium', 'Żytnie płatki błyskawiczne instant tyle flakes', 'Carrefour'),
    ('Vitanella', 'Nutty granola', 'Biedronka'),
    ('Unknown', 'Choco kulki', 'Biedronka'),
    ('Sante', 'Granola z owocami', 'Lidl'),
    ('Vitanella', 'Crunchy Klasyczne', 'Biedronka'),
    ('Vitanella', 'Owsianka ovsena kasa', 'Biedronka'),
    ('Vitanella', 'Owsianka z owocami i orzechami', 'Biedronka'),
    ('Nestlé', 'Cini Minis Scorțișoară', 'Biedronka'),
    ('Nestlé', 'Cini Minis Scorțișoară', 'Lidl'),
    ('Nestlé', 'Lion WildCrush', 'Auchan'),
    ('Go Active', 'Owsianka Z Truskawkami I Bananem O Smaku Waniliowym', 'Biedronka'),
    ('Helpa', 'Bio Kulki Jaglano-Orkiszowe', 'Rossmann'),
    ('Vitanella', 'Red Bowl owies orkisz kuskus', 'Biedronka'),
    ('Vitanella', 'Purple bowl', 'Biedronka'),
    ('Vitanella', 'Miami Hopki', 'Biedronka'),
    ('Vitanella', 'Pink crunchy', 'Biedronka'),
    ('Nju Bajt', 'Owsianka proteinowa z karmelem', 'Lidl'),
    ('Nju Bajt', 'Owsianka proteinowa z karmelem', 'Aldi'),
    ('Nestlé', 'Cini minie Crazycrunsh', 'Auchan'),
    ('Inna Bajka', 'Owsianka kokos i ananas', 'Żabka'),
    ('Home food', 'Muslim z owocami tropikalnymi', 'Stokrotka'),
    ('Lubella', 'Carmel Trolki', 'Dino'),
    ('Go Bio', 'Chrupki Kukurydziane o Smaku Bananowym', 'Biedronka'),
    ('Auchan', 'Choco shells', 'Auchan'),
    ('Lidl', 'Crownfield Płatki owsiane górskie', 'Lidl'),
    ('Vitanella', 'Choco Granola', 'Biedronka'),
    ('Kuchnia Smaku', 'Płatki ryżowe błyskawiczne', 'Dino'),
    ('Crownfield', 'Płatki owsiane', 'Lidl'),
    ('Tesco', 'Płatki owsiane górskie', 'Tesco'),
    ('Crownfield', 'Space Cookies', 'Lidl'),
    ('Crownfield', 'Goldini', 'Lidl'),
    ('Crownfield', 'Zimtinos', 'Lidl'),
    ('Crownfield', 'Choco Balls', 'Lidl'),
    ('Crownfield', 'Kakaové lupínky', 'Lidl'),
    ('Kaufland', 'Kukuřičné lupínky', 'Kaufland'),
    ('Carrefour', 'Stylesse chocolat noir', 'Carrefour'),
    ('Carrefour BIO', 'Céréales cœur fondant', 'Carrefour'),
    ('Crownfield', 'Owsianka z nasionami chia', 'Lidl'),
    ('K-Classic', 'Porridge Schokolade', 'Kaufland'),
    ('Carrefour', 'Fibra 5 dried fruits', 'Carrefour'),
    ('Carrefour BIO', 'Cereales corn flakes', 'Carrefour'),
    ('Carrefour', 'Copos de Avena / Fiocchi d''Avena', 'Carrefour'),
    ('Carrefour', 'Pétales de maïs', 'Carrefour'),
    ('Carrefour', 'Stylesse Nature', 'Carrefour'),
    ('Carrefour', 'Corn Flakes', 'Carrefour'),
    ('Carrefour', 'Boules De CÉRÉALES', 'Carrefour'),
    ('Simpl', 'Pétales de Blé Goût Chocolat', 'Carrefour'),
    ('Carrefour', 'Stylesse Fruits rouges', 'Carrefour'),
    ('Carrefour', 'Stylesse chocolat au lait', 'Carrefour'),
    ('Carrefour', 'Cereales Form fruits rouges', 'Carrefour'),
    ('Carrefour', 'Crocks chocolat noir', 'Carrefour'),
    ('Carrefour', 'CROCKS Goût CHOCOLATE-AVELLANA', 'Carrefour'),
    ('Knusperone', 'Nougat Bits', 'Aldi')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Cereals' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
