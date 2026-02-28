-- PIPELINE (Chips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'DE'
  and category = 'Chips'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5060042641000', '5053990167807', '5053990107339', '5060042641406', '5053990155354', '5053990127726', '5053990167845', '5053990107384', '5053990127740', '5053990161966', '8410076481597', '5053990101542', '5053990161607', '5060042641420', '5060042641413', '5060042641437', '5000328015927', '3497911101129', '20952174', '4003586100313', '5053990167531', '8412600019672', '8410076481757', '8013355501506', '7610095231505', '20047900', '8008698031056', '4003586104120', '5053990167913', '5053990175949', '5060367450578', '4018077004377', '20063399', '4002359014895', '5026489490892', '8412600019689', '5053990127641', '0757528048112', '8710398162045', '7300400481823', '4003586100306', '5053990175888', '0038000138416', '4088600004167', '5060042643509', '5053990175826', '4003586100399', '5949040203000', '7310130010354', '4003586101389', '5060367450356')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Tyrrell''s', 'Grocery', 'Chips', 'Lightly sea salted crisps', 'not-applicable', null, 'none', '5060042641000'),
  ('DE', 'Kellogg''s', 'Grocery', 'Chips', 'Pringles Original', 'not-applicable', null, 'none', '5053990167807'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles', 'not-applicable', null, 'none', '5053990107339'),
  ('DE', 'Tyrrells', 'Grocery', 'Chips', 'Sea salt & cider vinegar chips', 'not-applicable', null, 'none', '5060042641406'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Sour Cream & Onion', 'not-applicable', null, 'none', '5053990155354'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Original', 'not-applicable', null, 'none', '5053990127726'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Sour Cream & Onion chips', 'not-applicable', null, 'none', '5053990167845'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles sour cream & onion', 'not-applicable', null, 'none', '5053990107384'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Sour Cream', 'not-applicable', null, 'none', '5053990127740'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Texas BBQ Sauce', 'not-applicable', null, 'none', '5053990161966'),
  ('DE', 'Old El Paso', 'Grocery', 'Chips', 'Tortilla Nachips Original', 'not-applicable', null, 'none', '8410076481597'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles hot & spicy', 'not-applicable', null, 'none', '5053990101542'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Paprika', 'not-applicable', null, 'none', '5053990161607'),
  ('DE', 'Tyrrell’s', 'Grocery', 'Chips', 'Chips sel de mer et poivre noir', 'not-applicable', null, 'none', '5060042641420'),
  ('DE', 'Tyrrell’s', 'Grocery', 'Chips', 'Tyrrell''s Sweet Chilli & Red Pepper', 'not-applicable', null, 'none', '5060042641413'),
  ('DE', 'Tyrell''s', 'Grocery', 'Chips', 'Mature Cheddar & Chive', 'not-applicable', null, 'none', '5060042641437'),
  ('DE', 'Walkers', 'Grocery', 'Chips', 'Baked Sea Salt', 'not-applicable', null, 'none', '5000328015927'),
  ('DE', 'Brets', 'Grocery', 'Chips', 'Chips saveur Poulet Braisé', 'not-applicable', null, 'none', '3497911101129'),
  ('DE', 'Lidl', 'Grocery', 'Chips', 'Lightly salted tortilla', 'not-applicable', null, 'none', '20952174'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch ungarisch', 'not-applicable', null, 'none', '4003586100313'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Salt & Vinegar', 'not-applicable', null, 'none', '5053990167531'),
  ('DE', 'Barcel', 'Grocery', 'Chips', 'Takis Fuego', 'not-applicable', null, 'none', '8412600019672'),
  ('DE', 'General Mills', 'Grocery', 'Chips', 'Tortilla chips', 'not-applicable', null, 'none', '8410076481757'),
  ('DE', 'Gran Pavesi', 'Grocery', 'Chips', 'Gpav cracker salato pav 560 gr', 'not-applicable', null, 'none', '8013355501506'),
  ('DE', 'Zweifel vaya', 'Grocery', 'Chips', 'Bean Salt Snack', 'not-applicable', null, 'none', '7610095231505'),
  ('DE', 'Harvest Basket', 'Grocery', 'Chips', 'Potato Wedges sült krumpli', 'not-applicable', null, 'none', '20047900'),
  ('DE', 'Arvid Nordquist Norge AS', 'Grocery', 'Chips', 'Curvies original gluten free', 'not-applicable', null, 'none', '8008698031056'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Linsen Chips Paprika Style', 'not-applicable', null, 'none', '4003586104120'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Hot & Spicy', 'not-applicable', null, 'none', '5053990167913'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Hot Smokin’ BBQ Ribs Flavour', 'not-applicable', null, 'none', '5053990175949'),
  ('DE', 'Mister Free''d', 'Grocery', 'Chips', 'Tortilla Chips Avocado Guacamole Flavour', 'not-applicable', null, 'none', '5060367450578'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Paprika', 'not-applicable', null, 'none', '4018077004377'),
  ('DE', 'Snack Day', 'Grocery', 'Chips', 'Nature Tortilla', 'not-applicable', null, 'none', '20063399'),
  ('DE', 'Suzi Wan', 'Grocery', 'Chips', 'Chips à la crevette', 'not-applicable', null, 'none', '4002359014895'),
  ('DE', 'Eat Real', 'Grocery', 'Chips', 'Veggie Straws - With Kale, Tomato & Spinach', 'not-applicable', null, 'none', '5026489490892'),
  ('DE', 'Barcel', 'Grocery', 'Chips', 'Takis Queso Volcano 100g', 'not-applicable', null, 'none', '8412600019689'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles Cheese & onion', 'not-applicable', null, 'none', '5053990127641'),
  ('DE', 'Takis', 'Grocery', 'Chips', 'Takis Dragon Sweet chilli', 'not-applicable', null, 'none', '0757528048112'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Doritos Sweet Chilli Pepper Flavour', 'not-applicable', null, 'none', '8710398162045'),
  ('DE', 'Wasa', 'Grocery', 'Chips', 'Sans gluten et sans lactose', 'not-applicable', null, 'none', '7300400481823'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Peperoni', 'not-applicable', null, 'none', '4003586100306'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Pringles hot cheese', 'not-applicable', null, 'none', '5053990175888'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Original', 'not-applicable', null, 'none', '0038000138416'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Chips', 'Prawn Crackers', 'not-applicable', null, 'none', '4088600004167'),
  ('DE', 'Tyrrell’s', 'Grocery', 'Chips', 'Furrows Sea Salt & Vinegar', 'not-applicable', null, 'none', '5060042643509'),
  ('DE', 'Pringles', 'Grocery', 'Chips', 'Hot Kickin'' Sour Cream Flavour', 'not-applicable', null, 'none', '5053990175826'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Oriental', 'not-applicable', null, 'none', '4003586100399'),
  ('DE', 'Elephant', 'Grocery', 'Chips', 'Baked squeezed pretzels with tomatoes and herbs', 'not-applicable', null, 'none', '5949040203000'),
  ('DE', 'Finn Crisp', 'Grocery', 'Chips', 'Finn Crisp Snacks', 'not-applicable', null, 'none', '7310130010354'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch gesalzen', 'not-applicable', null, 'none', '4003586101389'),
  ('DE', 'Mister Free''d', 'Grocery', 'Chips', 'Blue Maize Tortilla Chips', 'not-applicable', null, 'none', '5060367450356')
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
where country = 'DE' and category = 'Chips'
  and is_deprecated is not true
  and product_name not in ('Lightly sea salted crisps', 'Pringles Original', 'Pringles', 'Sea salt & cider vinegar chips', 'Sour Cream & Onion', 'Pringles Original', 'Sour Cream & Onion chips', 'Pringles sour cream & onion', 'Pringles Sour Cream', 'Texas BBQ Sauce', 'Tortilla Nachips Original', 'Pringles hot & spicy', 'Pringles Paprika', 'Chips sel de mer et poivre noir', 'Tyrrell''s Sweet Chilli & Red Pepper', 'Mature Cheddar & Chive', 'Baked Sea Salt', 'Chips saveur Poulet Braisé', 'Lightly salted tortilla', 'Chipsfrisch ungarisch', 'Pringles Salt & Vinegar', 'Takis Fuego', 'Tortilla chips', 'Gpav cracker salato pav 560 gr', 'Bean Salt Snack', 'Potato Wedges sült krumpli', 'Curvies original gluten free', 'Linsen Chips Paprika Style', 'Hot & Spicy', 'Pringles Hot Smokin’ BBQ Ribs Flavour', 'Tortilla Chips Avocado Guacamole Flavour', 'Crunchips Paprika', 'Nature Tortilla', 'Chips à la crevette', 'Veggie Straws - With Kale, Tomato & Spinach', 'Takis Queso Volcano 100g', 'Pringles Cheese & onion', 'Takis Dragon Sweet chilli', 'Doritos Sweet Chilli Pepper Flavour', 'Sans gluten et sans lactose', 'Chipsfrisch Peperoni', 'Pringles hot cheese', 'Original', 'Prawn Crackers', 'Furrows Sea Salt & Vinegar', 'Hot Kickin'' Sour Cream Flavour', 'Chipsfrisch Oriental', 'Baked squeezed pretzels with tomatoes and herbs', 'Finn Crisp Snacks', 'Chipsfrisch gesalzen', 'Blue Maize Tortilla Chips');
