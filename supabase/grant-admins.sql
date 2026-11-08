-- ============================================================
-- 批量授予管理员（在 Supabase SQL Editor 整段运行）
--
-- 用法：
--   1. 先在 Authentication → Users 里创建好账号（或已注册）
--   2. 把下面 VALUES 里的邮箱 / 昵称换成真实值；昵称可以留空，会取邮箱前缀
--   3. 运行整段脚本
--   4. 末尾的 SELECT 会列出当前所有管理员
--
-- 本脚本会：
--   - 找不到 auth.users 的邮箱时跳过并打印 notice
--   - profiles 行不存在时自动补建
--   - 已存在时更新 nickname / contact / role / status
-- ============================================================

do $$
declare
    t record;
    v_user_id uuid;
    v_nickname text;
begin
    for t in
        select *
        from (values
            ('admin1@example.com', '管理员一'),
            ('admin2@example.com', '管理员二')
        ) as x(email, nickname)
    loop
        select id into v_user_id
        from auth.users
        where lower(email) = lower(t.email)
        limit 1;

        if v_user_id is null then
            raise notice '跳过 %：auth.users 中不存在该邮箱', t.email;
            continue;
        end if;

        v_nickname := coalesce(nullif(t.nickname, ''), split_part(t.email, '@', 1));

        insert into public.profiles (id, nickname, contact, role, status)
        values (v_user_id, v_nickname, t.email, 'admin', 'active')
        on conflict (id) do update
        set nickname = excluded.nickname,
            contact = excluded.contact,
            role = 'admin',
            status = 'active',
            updated_at = now();

        raise notice '已设为管理员：%（%）', v_nickname, t.email;
    end loop;
end;
$$;

-- 查看当前所有管理员
select p.nickname, p.contact, u.email, p.role, p.status, p.created_at
from public.profiles p
join auth.users u on u.id = p.id
where p.role = 'admin'
order by p.created_at;

-- ============================================================
-- 备用：如果 profiles 已经存在，只想按昵称批量提权，可直接用这段
-- ============================================================
-- update public.profiles
-- set role = 'admin', status = 'active', updated_at = now()
-- where nickname in ('管理员一', '管理员二');
