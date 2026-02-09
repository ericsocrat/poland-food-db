-- PIPELINE (Canned Goods): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Canned Goods'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Nasza Spiżarnia', 'Grocery', 'Canned Goods', 'Kukurydza słodka', null, 'Biedronka', 'none', '5901713008756'),
  ('PL', 'Marinero', 'Grocery', 'Canned Goods', 'Łosoś Kawałki w sosie pomidorowym', null, 'Biedronka', 'none', '5903895631913'),
  ('PL', 'Dawtona', 'Grocery', 'Canned Goods', 'Kukurydza słodka', null, 'Kaufland', 'none', '5901713001795'),
  ('PL', 'Pudliszki', 'Grocery', 'Canned Goods', 'Pomidore krojone bez skórki w sosie pomidorowym.', null, null, 'none', '5900783002152'),
  ('PL', 'Dega', 'Grocery', 'Canned Goods', 'Fish spread with rice', null, 'Dino', 'none', '5901960048161'),
  ('PL', 'Nasza spiżarnia', 'Grocery', 'Canned Goods', 'Brzoskwinie w syropie', null, 'Biedronka', 'none', '5904378645649'),
  ('PL', 'Freshona', 'Grocery', 'Canned Goods', 'Buraczki wiórki', null, 'Lidl', 'none', '20158651'),
  ('PL', 'Nautica', 'Grocery', 'Canned Goods', 'Makrélafilé bőrrel paradicsomos szószban', null, 'Lidl', 'none', '20096410'),
  ('PL', 'Lidl', 'Grocery', 'Canned Goods', 'Buraczki zasmażane z cebulką', null, 'Lidl', 'none', '20900229'),
  ('PL', 'Kaufland', 'Grocery', 'Canned Goods', 'Sardynki w oleju słonecznikowym', null, null, 'none', '4337185451355'),
  ('PL', 'Baresa', 'Grocery', 'Canned Goods', 'Azeitonas Lidl', null, 'Lidl', 'none', '20443375'),
  ('PL', 'Freshona', 'Grocery', 'Canned Goods', 'Sonnenmais natursüß', null, 'Lidl', 'none', '20153229'),
  ('PL', 'Freshona', 'Grocery', 'Canned Goods', 'Ananas en tranches au sirop léger', null, 'Lidl', 'none', '20253929'),
  ('PL', 'Freshona', 'Grocery', 'Canned Goods', 'coconut milk', null, 'Lidl', 'none', '20561338'),
  ('PL', 'Bonduelle', 'Grocery', 'Canned Goods', 'Lunch bowl Légumes & boulgour 250g', null, 'Globus,carrefour.fr', 'none', '3083681139716'),
  ('PL', 'Baresa', 'Grocery', 'Canned Goods', 'Peeled Tomatoes in tomato juice', null, 'Lidl', 'none', '20198107'),
  ('PL', 'NIXE', 'Grocery', 'Canned Goods', 'Sardines à l''huile de tournesol', null, 'LIDL', 'none', '20041663'),
  ('PL', 'El Tequito', 'Grocery', 'Canned Goods', 'Jalapeños', null, 'Lidl', 'none', '20484804'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Morceaux de thon', null, 'carrefour market,Carrefour,carrefour.fr', 'none', '3560071000035'),
  ('PL', 'Alpen Fest style', 'Grocery', 'Canned Goods', 'Rodekool Chou rouge', null, 'Lidl', 'none', '20004408'),
  ('PL', 'Cirio', 'Grocery', 'Canned Goods', 'Pelati Geschälte Tomaten', null, 'Billa,Kaufland', 'none', '8000320010026'),
  ('PL', 'Baresa', 'Grocery', 'Canned Goods', 'Pulpe de tomates, basilic & origan', null, 'Lidl', 'none', '20198084'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Morceaux de thon au naturel', null, 'Carrefour,carrefour.fr,Match', 'none', '3560071084158'),
  ('PL', 'SOL & MAR', 'Grocery', 'Canned Goods', 'Czosnek z chilli w oleju', null, 'Lidl', 'none', '4056489210221'),
  ('PL', 'Freshona', 'Grocery', 'Canned Goods', 'Gurkensticks', null, 'LIDL', 'none', '20039486'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Morceaux de Thon', null, 'carrefour.fr,Carrefour', 'none', '3560071270605'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Olives à la farce aux anchois', null, 'Carrefour,carrefour.fr', 'none', '3560070105908'),
  ('PL', 'Carrefour', 'Grocery', 'Canned Goods', 'Miettes de thon', null, 'carrefour.fr, Carrefour', 'none', '3560071175221')
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
where country = 'PL' and category = 'Canned Goods'
  and is_deprecated is not true
  and product_name not in ('Kukurydza słodka', 'Łosoś Kawałki w sosie pomidorowym', 'Kukurydza słodka', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'Fish spread with rice', 'Brzoskwinie w syropie', 'Buraczki wiórki', 'Makrélafilé bőrrel paradicsomos szószban', 'Buraczki zasmażane z cebulką', 'Sardynki w oleju słonecznikowym', 'Azeitonas Lidl', 'Sonnenmais natursüß', 'Ananas en tranches au sirop léger', 'coconut milk', 'Lunch bowl Légumes & boulgour 250g', 'Peeled Tomatoes in tomato juice', 'Sardines à l''huile de tournesol', 'Jalapeños', 'Morceaux de thon', 'Rodekool Chou rouge', 'Pelati Geschälte Tomaten', 'Pulpe de tomates, basilic & origan', 'Morceaux de thon au naturel', 'Czosnek z chilli w oleju', 'Gurkensticks', 'Morceaux de Thon', 'Olives à la farce aux anchois', 'Miettes de thon');
