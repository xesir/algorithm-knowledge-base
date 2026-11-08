-- ============================================================
-- 第九阶段：公开专栏视图（前端实时覆盖静态内容）
-- 前置：已执行 phase4 ~ phase8
-- 在 Supabase SQL Editor 整段运行，可重复执行。
--
-- 背景：网站正文来自静态构建产物 data.js / problems_data.js。
-- 「修改」与「投稿」工单审批后只会写数据库 columns 表，
-- 因此前端需要按 updated_at 增量拉取已发布专栏并覆盖到页面上。
--
-- 该视图以视图属主（postgres）权限执行，绕过 columns / profiles 的 RLS，
-- 但只暴露 status = 'published' 的专栏与作者昵称，匿名可读。
-- ============================================================

drop view if exists public.published_columns;

create view public.published_columns
with (security_invoker = false)
as
select
    c.column_key,
    c.column_name,
    c.category,
    c.kind,
    c.difficulty,
    c.parent_key,
    c.tags,
    c.content,
    c.created_at,
    c.updated_at,
    coalesce(nullif(p.nickname, ''), 'world-needs-sunday') as author_name
from public.columns c
left join public.profiles p on p.id = c.owner_id
where c.status = 'published'
  and (c.column_key like 'col-%' or c.column_key like 'sub-%');

grant select on public.published_columns to anon, authenticated;

comment on view public.published_columns is
    '公开只读视图：已发布专栏 + 作者昵称，供静态站前端增量覆盖正文';

-- 让 PostgREST 立即感知新视图
notify pgrst, 'reload schema';

-- 自检
select count(*) as published_column_count from public.published_columns;
