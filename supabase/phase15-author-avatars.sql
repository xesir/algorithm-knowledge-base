-- ============================================================
-- 第十五阶段：公开作者头像视图
-- 前置：phase3（profiles.avatar_url / avatars 桶）、phase14 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. 新建公开只读视图 author_profiles，暴露活跃作者的昵称与头像 URL；
--   2. 供作者专栏列表 / 作者主页 / 密码门显示头像；头像为空时前端回退到首字母。
-- ============================================================

drop view if exists public.author_profiles;

create view public.author_profiles
with (security_invoker = false)
as
select
    coalesce(nullif(p.nickname, ''), 'unknown') as author_name,
    coalesce(nullif(p.avatar_url, ''), '') as avatar_url
from public.profiles p
where p.status = 'active';

grant select on public.author_profiles to anon, authenticated;

comment on view public.author_profiles is
    '公开只读视图：活跃作者的昵称与头像 URL，供作者专栏与密码门显示头像';

notify pgrst, 'reload schema';

-- 自检
select author_name, avatar_url
from public.author_profiles
order by author_name
limit 20;
