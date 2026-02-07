-- Add method + store availability tags (generic columns usable for other categories too)

alter table public.products
  add column if not exists prep_method text,              -- e.g., fried / baked / popped / unknown
  add column if not exists store_availability text;       -- e.g., 'Biedronka;Lidl;Żabka'
