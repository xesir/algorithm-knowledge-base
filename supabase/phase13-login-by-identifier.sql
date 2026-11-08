-- ============================================================
-- 第十三阶段：登录支持 用户名 / QQ / 洛谷 / CF / 邮箱 任意一个
-- 前置：phase2（profiles.nickname / contact / qq / luogu / cf）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. 新增 resolve_login_email(p_identifier, p_password)：
--      用昵称、邮箱、QQ、洛谷、CF 任一标识找到账号，
--      并用 bcrypt 校验密码；仅当密码正确时返回该账号的登录邮箱。
--   2. 前端拿返回的邮箱去 signInWithPassword（Supabase Auth 本身只认邮箱）。
--
-- 安全说明：
--   - 函数 SECURITY DEFINER 读取 auth.users.encrypted_password；
--   - 密码不正确一律返回 null，不泄露账号是否存在、也不泄露邮箱；
--   - 只允许 anon / authenticated 执行，不对 public 开放。
-- ============================================================

create or replace function public.resolve_login_email(
    p_identifier text,
    p_password text
)
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_identifier text := lower(btrim(coalesce(p_identifier, '')));
    v_email text;
begin
    if v_identifier = '' or coalesce(p_password, '') = '' then
        return null;
    end if;

    select u.email
    into v_email
    from public.profiles p
    join auth.users u on u.id = p.id
    where (
            lower(p.nickname) = v_identifier
         or lower(coalesce(p.contact, '')) = v_identifier
         or lower(coalesce(p.qq, '')) = v_identifier
         or lower(coalesce(p.luogu, '')) = v_identifier
         or lower(coalesce(p.cf, '')) = v_identifier
         or lower(u.email) = v_identifier
    )
      and u.encrypted_password is not null
      and u.encrypted_password = crypt(p_password, u.encrypted_password)
    limit 1;

    return v_email;
end;
$$;

revoke all on function public.resolve_login_email(text, text) from public;
grant execute on function public.resolve_login_email(text, text) to anon, authenticated;

-- 自检：错误密码必须返回 null；模糊查询不返回任何账号
select public.resolve_login_email('definitely-not-exists', 'wrong-password') as should_be_null;

select p.nickname,
       (p.contact is not null) as has_contact,
       (p.qq is not null) as has_qq,
       (p.luogu is not null) as has_luogu,
       (p.cf is not null) as has_cf
from public.profiles p
order by p.nickname;
