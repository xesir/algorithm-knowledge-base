-- ============================================================
-- 数据修复：把 columns 里的「裸知识点 id」关系规范成 column_key
-- 背景：便捷修改 / 部分历史数据把 relations.target、parent_key、relation_target
--       写成了裸 id（如 ds-block-decomposition），而前端与后台上传统一使用
--       col-<id> / col-<id>--<作者> / sub-* 形式的 column_key；两者混用会造成
--       「数据库里有、页面/工单对应不到」的错觉。
-- 前置：无（只更新已有行）
-- 执行：Supabase SQL Editor 整段 Run；可重复执行。
-- 规则：优先替换为 col-<id>；若主专栏行不存在，则替换为任一存在的
--       col-<id>--<作者> 行（前端按 -- 前的基础 id 解析，语义不变）。
-- 注意：更新会触发 trg_columns_updated_at，updated_at 会变化，前端会重新同步一次。
-- ============================================================

-- ---------- 0. 执行前：列出将被规范化的目标 ----------
select c.column_key, 'relations' as field, r->>'target' as old_target,
       case
           when exists (select 1 from public.columns t where t.column_key = 'col-' || (r->>'target'))
               then 'col-' || (r->>'target')
           else (select t.column_key from public.columns t
                 where t.column_key like 'col-' || (r->>'target') || '--%'
                 order by t.column_key limit 1)
       end as new_target
from public.columns c
cross join lateral jsonb_array_elements(coalesce(c.relations, '[]'::jsonb)) r
where r->>'target' <> ''
  and r->>'target' !~ '^(col-|sub-)'
order by c.column_key, old_target;

-- ---------- 1. relations 数组：裸 id → 已存在的 column_key ----------
with fixed as (
    select c.id,
           jsonb_agg(
               case
                   when coalesce(r->>'target', '') <> ''
                        and (r->>'target') !~ '^(col-|sub-)'
                   then
                       case
                           when exists (
                               select 1 from public.columns t
                               where t.column_key = 'col-' || (r->>'target')
                           )
                           then jsonb_set(r, '{target}', to_jsonb('col-' || (r->>'target')), false)
                           when exists (
                               select 1 from public.columns t
                               where t.column_key like 'col-' || (r->>'target') || '--%'
                           )
                           then jsonb_set(r, '{target}', to_jsonb((
                               select t.column_key from public.columns t
                               where t.column_key like 'col-' || (r->>'target') || '--%'
                               order by t.column_key limit 1
                           )), false)
                           else r
                       end
                   else r
               end
               order by e.ord
           ) as relations
    from public.columns c
    cross join lateral jsonb_array_elements(coalesce(c.relations, '[]'::jsonb))
        with ordinality as e(r, ord)
    where c.relations is not null
      and jsonb_array_length(c.relations) > 0
    group by c.id
)
update public.columns c
set relations = f.relations
from fixed f
where c.id = f.id
  and c.relations is distinct from f.relations;

-- ---------- 2. parent_key：裸 id → 已存在的 column_key ----------
update public.columns c
set parent_key = coalesce(
    (select t.column_key from public.columns t where t.column_key = 'col-' || c.parent_key),
    (select t.column_key from public.columns t
     where t.column_key like 'col-' || c.parent_key || '--%'
     order by t.column_key limit 1),
    c.parent_key
)
where coalesce(c.parent_key, '') <> ''
  and c.parent_key !~ '^(col-|sub-)'
  and (
      exists (select 1 from public.columns t where t.column_key = 'col-' || c.parent_key)
      or exists (select 1 from public.columns t where t.column_key like 'col-' || c.parent_key || '--%')
  );

-- ---------- 3. relation_target（旧冗余字段）：裸 id → 已存在的 column_key ----------
update public.columns c
set relation_target = coalesce(
    (select t.column_key from public.columns t where t.column_key = 'col-' || c.relation_target),
    (select t.column_key from public.columns t
     where t.column_key like 'col-' || c.relation_target || '--%'
     order by t.column_key limit 1),
    c.relation_target
)
where coalesce(c.relation_target, '') <> ''
  and c.relation_target !~ '^(col-|sub-)'
  and (
      exists (select 1 from public.columns t where t.column_key = 'col-' || c.relation_target)
      or exists (select 1 from public.columns t where t.column_key like 'col-' || c.relation_target || '--%')
  );

-- ---------- 4. 执行后自检：以下三条应返回 0 行 ----------
select c.column_key, r->>'target' as remaining_bare_target
from public.columns c
cross join lateral jsonb_array_elements(coalesce(c.relations, '[]'::jsonb)) r
where r->>'target' <> ''
  and r->>'target' !~ '^(col-|sub-)'
order by c.column_key;

select column_key, parent_key as remaining_bare_parent
from public.columns
where coalesce(parent_key, '') <> ''
  and parent_key !~ '^(col-|sub-)'
order by column_key;

select column_key, relation_target as remaining_bare_relation_target
from public.columns
where coalesce(relation_target, '') <> ''
  and relation_target !~ '^(col-|sub-)'
order by column_key;

-- ---------- 5. 无法自动规范的行（目标 id 在 columns 里完全没有对应行，需人工处理） ----------
select c.column_key, 'relations' as field, r->>'target' as target
from public.columns c
cross join lateral jsonb_array_elements(coalesce(c.relations, '[]'::jsonb)) r
where r->>'target' <> ''
  and r->>'target' !~ '^(col-|sub-)'
  and not exists (select 1 from public.columns t where t.column_key = 'col-' || (r->>'target'))
  and not exists (select 1 from public.columns t where t.column_key like 'col-' || (r->>'target') || '--%')
union all
select c.column_key, 'parent_key', c.parent_key
from public.columns c
where coalesce(c.parent_key, '') <> ''
  and c.parent_key !~ '^(col-|sub-)'
  and not exists (select 1 from public.columns t where t.column_key = 'col-' || c.parent_key)
  and not exists (select 1 from public.columns t where t.column_key like 'col-' || c.parent_key || '--%')
union all
select c.column_key, 'relation_target', c.relation_target
from public.columns c
where coalesce(c.relation_target, '') <> ''
  and c.relation_target !~ '^(col-|sub-)'
  and not exists (select 1 from public.columns t where t.column_key = 'col-' || c.relation_target)
  and not exists (select 1 from public.columns t where t.column_key like 'col-' || c.relation_target || '--%')
order by 1, 2, 3;
