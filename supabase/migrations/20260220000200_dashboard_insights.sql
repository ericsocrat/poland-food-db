-- 20260220000200_dashboard_insights.sql
-- Purpose: Add dashboard health-insights RPC for Issue #63.
-- Returns aggregated nutrition stats for the authenticated user:
--   avg_score, score_trend, allergen_alerts, nova_distribution,
--   category_diversity, recent_comparisons.

set search_path = public;

-- ─── api_dashboard_insights() ───────────────────────────────────────────────

create or replace function public.api_dashboard_insights()
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  v_uid         uuid := auth.uid();
  v_avg_score   numeric;
  v_trend       text;         -- 'improving' | 'worsening' | 'stable'
  v_nova        jsonb;
  v_cat_explored int;
  v_cat_total    int;
  v_allergen    jsonb;        -- { count, products: [{product_id, product_name, allergens}] }
  v_comparisons jsonb;        -- last 2 comparisons
  v_recent_avg  numeric;
  v_older_avg   numeric;
begin
  -- Auth-only
  if v_uid is null then
    return jsonb_build_object('error', 'unauthorized');
  end if;

  -- 1) Average score across all favorites
  select avg(p.unhealthiness_score)
    into v_avg_score
    from user_product_list_items li
    join user_product_lists ul on ul.id = li.list_id
    join products p on p.product_id = li.product_id
   where ul.user_id = v_uid
     and lower(ul.name) = 'favorites'
     and p.unhealthiness_score is not null;

  v_avg_score := round(coalesce(v_avg_score, 0), 1);

  -- 2) Score trend: last 10 favorites vs previous 10
  select avg(sub.unhealthiness_score) into v_recent_avg
    from (
      select p.unhealthiness_score
        from user_product_list_items li
        join user_product_lists ul on ul.id = li.list_id
        join products p on p.product_id = li.product_id
       where ul.user_id = v_uid
         and lower(ul.name) = 'favorites'
         and p.unhealthiness_score is not null
       order by li.created_at desc
       limit 10
    ) sub;

  select avg(sub.unhealthiness_score) into v_older_avg
    from (
      select p.unhealthiness_score
        from user_product_list_items li
        join user_product_lists ul on ul.id = li.list_id
        join products p on p.product_id = li.product_id
       where ul.user_id = v_uid
         and lower(ul.name) = 'favorites'
         and p.unhealthiness_score is not null
       order by li.created_at desc
       limit 10 offset 10
    ) sub;

  if v_recent_avg is null or v_older_avg is null then
    v_trend := 'stable';
  elsif v_recent_avg < v_older_avg - 3 then
    v_trend := 'improving';
  elsif v_recent_avg > v_older_avg + 3 then
    v_trend := 'worsening';
  else
    v_trend := 'stable';
  end if;

  -- 3) NOVA distribution across favorites
  select coalesce(
    jsonb_object_agg(nova, cnt),
    '{}'::jsonb
  ) into v_nova
  from (
    select coalesce(p.nova_classification, 'unknown') as nova,
           count(*) as cnt
      from user_product_list_items li
      join user_product_lists ul on ul.id = li.list_id
      join products p on p.product_id = li.product_id
     where ul.user_id = v_uid
       and lower(ul.name) = 'favorites'
     group by coalesce(p.nova_classification, 'unknown')
  ) sub;

  -- 4) Category diversity
  select count(distinct p.category) into v_cat_explored
    from user_product_views upv
    join products p on p.product_id = upv.product_id
   where upv.user_id = v_uid;

  select count(distinct p.category) into v_cat_total
    from products p
   where p.is_deprecated is not true;

  -- 5) Allergen alerts — favorites containing user's avoid_allergens
  select coalesce(
    jsonb_build_object(
      'count', count(distinct a.product_id),
      'products', jsonb_agg(distinct jsonb_build_object(
        'product_id', a.product_id,
        'product_name', p2.product_name,
        'allergen', a.tag
      ))
    ),
    jsonb_build_object('count', 0, 'products', '[]'::jsonb)
  ) into v_allergen
  from user_preferences up
  cross join lateral unnest(up.avoid_allergens) as aa(allergen_tag)
  join product_allergen_info a on a.tag = aa.allergen_tag and a.type = 'contains'
  join user_product_list_items li on li.product_id = a.product_id
  join user_product_lists ul on ul.id = li.list_id and ul.user_id = v_uid and lower(ul.name) = 'favorites'
  join products p2 on p2.product_id = a.product_id
  where up.user_id = v_uid
    and up.avoid_allergens is not null
    and array_length(up.avoid_allergens, 1) > 0;

  -- Default if no allergen data
  if v_allergen is null then
    v_allergen := jsonb_build_object('count', 0, 'products', '[]'::jsonb);
  end if;

  -- 6) Recent comparisons (last 2)
  select coalesce(jsonb_agg(sub.row_data), '[]'::jsonb)
    into v_comparisons
    from (
      select jsonb_build_object(
        'id', uc.id,
        'title', uc.title,
        'product_count', array_length(uc.product_ids, 1),
        'created_at', uc.created_at
      ) as row_data
      from user_comparisons uc
      where uc.user_id = v_uid
      order by uc.created_at desc
      limit 2
    ) sub;

  return jsonb_build_object(
    'api_version', '1.0',
    'avg_score', v_avg_score,
    'score_trend', v_trend,
    'nova_distribution', v_nova,
    'category_diversity', jsonb_build_object(
      'explored', coalesce(v_cat_explored, 0),
      'total', greatest(coalesce(v_cat_total, 20), 1)
    ),
    'allergen_alerts', v_allergen,
    'recent_comparisons', v_comparisons
  );
end;
$$;

-- Grant
grant execute on function public.api_dashboard_insights() to authenticated;
revoke execute on function public.api_dashboard_insights() from anon;
