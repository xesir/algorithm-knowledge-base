-- ============================================================
-- 第十八阶段：作者公开资料增加角色（管理员标识）
-- 前置：phase16 已执行（profiles.signature / honors）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. author_profiles 增加 role 字段；
--   2. 前端作者列表 / 作者主页 / 密码门据此显示「管理员」标识。
-- ============================================================

drop view if exists public.author_profiles;

create view public.author_profiles
with (security_invoker = false)
as
select
    coalesce(nullif(p.nickname, ''), 'unknown') as author_name,
    coalesce(nullif(p.avatar_url, ''), '') as avatar_url,
    coalesce(p.signature, '') as signature,
    coalesce(p.honors, '{}'::text[]) as honors,
    p.role
from public.profiles p
where p.status = 'active';

grant select on public.author_profiles to anon, authenticated;

comment on view public.author_profiles is
    '公开只读视图：活跃作者的昵称、头像、签名、战绩与角色（管理员标识）';

notify pgrst, 'reload schema';

-- 自检
select author_name, role, signature, array_length(honors, 1) as honor_count
from public.author_profiles
order by author_name
limit 20;
