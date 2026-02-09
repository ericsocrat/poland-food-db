-- PIPELINE (Breakfast & Grain-Based): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5907437365069', '5907437367254', '5907437366141', '5907437363331', '5907437366158', '5900617012197', '5900397006744', '5902884460244', '5900820011529', '5902884468059', '5907437364741', '5900749610537', '5900617038289', '5903034425762', '5900531000102', '5900512300146', '5902884461319', '5907437367247')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', null, 'Biedronka', 'none', '5907437365069'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Vitanella Granola z czekoladą', null, 'biedronka', 'none', '5907437367254'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli prażone z suszoną, słodzoną żurawiną.', null, 'Biedronka', 'none', '5907437366141'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', null, 'Biedronka', 'none', '5907437363331'),
  ('PL', 'vitanella', 'Grocery', 'Breakfast & Grain-Based', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', null, 'Biedronka', 'none', '5907437366158'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Masło orzechowe', null, 'Kaufland', 'none', '5900617012197'),
  ('PL', 'Łowicz', 'Grocery', 'Breakfast & Grain-Based', 'Dżem truskawkowy', null, 'Stokrotka', 'none', '5900397006744'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', null, null, 'none', '5902884460244'),
  ('PL', 'Laciaty', 'Grocery', 'Breakfast & Grain-Based', 'Serek puszysty naturalny Łaciaty', null, null, 'none', '5900820011529'),
  ('PL', 'One day more', 'Grocery', 'Breakfast & Grain-Based', 'Muesli Protein', null, 'lidl', 'none', '5902884468059'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Musli premium', null, 'Biedronka', 'none', '5907437364741'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Banana Chocolate musli', null, 'Biedronka', 'none', '5900749610537'),
  ('PL', 'GO ON', 'Grocery', 'Breakfast & Grain-Based', 'Peanut Butter Smooth', null, 'Lidl', 'none', '5900617038289'),
  ('PL', 'Mazurskie Miody', 'Grocery', 'Breakfast & Grain-Based', 'Polish Honey multiflower', null, 'Lidl', 'none', '5903034425762'),
  ('PL', 'Piątnica', 'Grocery', 'Breakfast & Grain-Based', 'Low Fat Cottage Cheese', null, 'Żabka', 'none', '5900531000102'),
  ('PL', 'Mlekovita', 'Grocery', 'Breakfast & Grain-Based', 'Oselka', null, 'Biedronka', 'none', '5900512300146'),
  ('PL', 'ONE DAY MORE', 'Grocery', 'Breakfast & Grain-Based', 'Meusli Fruits et Chocolat Blanc', null, null, 'none', '5902884461319'),
  ('PL', 'Biedronka', 'Grocery', 'Breakfast & Grain-Based', 'Granola', null, null, 'none', '5907437367247')
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
where country = 'PL' and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true
  and product_name not in ('Mieszanka płatków zbożowych z suszonymi oraz kandyzowanymi owocami', 'Vitanella Granola z czekoladą', 'Musli prażone z suszoną, słodzoną żurawiną.', 'Płatki zbożowe z suszonymi i kandyzowanymi owocami.', 'granola z kawałkami czekolady, prażonymi orzeszkami ziemnymi ilaskowymi', 'Masło orzechowe', 'Dżem truskawkowy', 'Musli z suszonymi figami i prażonymi orzeszkami ziemnymi.', 'Serek puszysty naturalny Łaciaty', 'Muesli Protein', 'Musli premium', 'Banana Chocolate musli', 'Peanut Butter Smooth', 'Polish Honey multiflower', 'Low Fat Cottage Cheese', 'Oselka', 'Meusli Fruits et Chocolat Blanc', 'Granola');
