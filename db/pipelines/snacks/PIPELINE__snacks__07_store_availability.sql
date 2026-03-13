-- PIPELINE (Snacks): store availability
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
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 'Biedronka'),
    ('Top', 'Popcorn o smaku maślanym', 'Biedronka'),
    ('Kopernik', 'Pierniki nadziewane w białej czekoladzie.', 'Biedronka'),
    ('E. Wedel', 'Batonik z nadzieniem o smaku śmietankowym w mlecznej czekoladzie (z dodatkiem alkoholu).', 'Auchan'),
    ('Maga', 'Surówka Colesław', 'Auchan'),
    ('Pano', 'Wafle Kukurydziane z Kaszą jaglaną i Pieprzem', 'Biedronka'),
    ('Good-food', 'Wafle kukurydziane z ziołami prowansalskimi', 'Lidl'),
    ('Lajkonik', 'Paluszki o smaku waniliowym.', 'Biedronka'),
    ('Delicje', 'Szampariskie pomaranczowe', 'Carrefour'),
    ('Vitanella', 'Superballs Kokos i kakao', 'Biedronka'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'Lidl'),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 'Biedronka'),
    ('Wafle Dzik', 'Kukurydziane - ser', 'Lidl'),
    ('Vitanella', 'Protein 30% Nugat Karmel', 'Biedronka'),
    ('Purella', 'Baton proteinowy - truskawkowa beza', 'Kaufland'),
    ('Purella', 'Baton proteinowy - Matcha & Yuzu', 'Kaufland'),
    ('Unknown', 'Ciasto francuskie', 'Auchan'),
    ('Lajkonik', 'Paluszki extra cienkie', 'Żabka'),
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', 'Kaufland'),
    ('Zmiany Zmiany', 'Sztanga', 'Rossmann'),
    ('Kopernik torun', 'Pierniki nadziewane', 'Kaufland'),
    ('Popcrop Pyramids', 'High Protein Tomato & Basil Chips', 'Kaufland'),
    ('Dan Cake', 'Sandkuchen', 'Biedronka'),
    ('Purella', 'Baton proteinowy - mango crispy rice', 'Kaufland'),
    ('Beskidzkie', 'Paluszki solone', 'Tesco'),
    ('Miami', 'Paleczki', 'Biedronka'),
    ('Good-food', 'Wafle kukyrydziane', 'Lidl'),
    ('Unknown', 'Vitanella raw', 'Biedronka'),
    ('Lidl', 'Chrupiący baton proteinowy o smaku malinowym', 'Lidl'),
    ('Vemondo', 'Roślinny batonik z tofu o smaku słonego karmelu', 'Lidl'),
    ('7 Days', 'Croissant with Cocoa Filling', 'Kaufland'),
    ('Snack Day', 'Popcorn', 'Lidl'),
    ('Lorenz', 'Monster Munch Crispy Potato-Snack Original', 'Biedronka'),
    ('Zott', 'Monte Snack', 'Biedronka'),
    ('Emco', 'Vitanella Bars', 'Biedronka'),
    ('Monte snack', 'Monte Snack', 'Dino'),
    ('Tutti', 'Batonik twarogowy Tutti w polewie czekoladowej', 'Biedronka'),
    ('GustoBello', 'Bruschette con rosmarino', 'Biedronka'),
    ('Sen Soy', 'Nori chips kimchi', 'Lidl'),
    ('Nakd', 'Blueberry Muffin Myrtilles', 'Tesco'),
    ('Vitanella', 'Barony', 'Biedronka'),
    ('Nestlé', 'Nestle Nesquik', 'Dino'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'Penny')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;
