-- ============================================================
-- 第十二阶段：作者专栏默认密码 = 作者登录密码
-- 前置：phase3（column_locks）、phase10/11 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 规则：
--   1. 除 Xesir 外，每位作者建立/更新「默认专栏密码」，
--      password_hash 直接复制 auth.users.encrypted_password，
--      因此作者用自己的登录密码即可解锁自己的全部专栏；
--   2. Xesir 的默认专栏密码清空（null = 无密码），并删除其专栏的特定密码；
--   3. 已有「特定密码」的专栏仍然优先于默认密码，不会被覆盖。
-- ============================================================

do $$
declare
    r record;
begin
    for r in
        select p.id as user_id,
               p.nickname,
               u.encrypted_password
        from public.profiles p
        join auth.users u on u.id = p.id
        where p.nickname <> 'Xesir'
          and u.encrypted_password is not null
    loop
        insert into public.column_locks (user_id, column_key, column_name, password_hash, is_default)
        values (r.user_id, '__default__', '默认专栏访问密码', r.encrypted_password, true)
        on conflict (user_id, column_key)
        do update set password_hash = excluded.password_hash, updated_at = now();
    end loop;

    -- Xesir：默认密码留空（无密码）
    insert into public.column_locks (user_id, column_key, column_name, password_hash, is_default)
    select p.id, '__default__', '默认专栏访问密码', null, true
    from public.profiles p
    where p.nickname = 'Xesir'
    on conflict (user_id, column_key)
    do update set password_hash = null, updated_at = now();
end;
$$;

-- Xesir 的专栏不再保留特定密码
delete from public.column_locks l
using public.profiles p
where l.is_default = false
  and l.user_id = p.id
  and p.nickname = 'Xesir';

-- 作者没有登录密码时无法自动生成默认密码，列出来便于人工处理
select p.nickname, u.email
from public.profiles p
left join auth.users u on u.id = p.id
where u.encrypted_password is null
order by p.nickname;

-- 自检：各作者专栏的锁定数量（Xesir 应为 0）
select
    p.nickname,
    count(c.id) as column_count,
    count(c.id) filter (where v.locked) as locked_count
from public.profiles p
left join public.columns c
    on c.owner_id = p.id
   and c.status = 'published'
   and (c.column_key like 'col-%' or c.column_key like 'sub-%')
left join public.published_columns v on v.column_key = c.column_key
group by p.nickname
order by p.nickname;
