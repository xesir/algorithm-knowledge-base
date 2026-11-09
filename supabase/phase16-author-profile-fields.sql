-- ============================================================
-- 第十六阶段：作者签名 / 战绩
-- 前置：phase2（profiles）、phase3（profiles.avatar_url）、phase15（本文件会重建 author_profiles）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. profiles 增加 signature / honors；
--   2. 重建公开只读视图 author_profiles，带昵称、头像、签名、战绩；
--   3. 作者本人在 admin.html「个人设置」保存，RLS 沿用 profiles_update_self。
-- ============================================================

alter table public.profiles add column if not exists signature text;
alter table public.profiles add column if not exists honors text[] not null default '{}'::text[];

drop view if exists public.author_profiles;

create view public.author_profiles
with (security_invoker = false)
as
select
    coalesce(nullif(p.nickname, ''), 'unknown') as author_name,
    coalesce(nullif(p.avatar_url, ''), '') as avatar_url,
    coalesce(p.signature, '') as signature,
    coalesce(p.honors, '{}'::text[]) as honors
from public.profiles p
where p.status = 'active';

grant select on public.author_profiles to anon, authenticated;

comment on view public.author_profiles is
    '公开只读视图：活跃作者的昵称、头像、签名与战绩，供作者专栏显示';

notify pgrst, 'reload schema';

-- 自检
select author_name, avatar_url, signature, array_length(honors, 1) as honor_count
from public.author_profiles
order by author_name
limit 20;
