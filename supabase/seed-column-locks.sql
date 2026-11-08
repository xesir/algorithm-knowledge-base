-- ============================================================
-- 初始作者密码 / 专栏密码批量导入
-- 前置：
--   1) 已执行 supabase/phase2.sql
--   2) 已运行 scripts/seed-authors.js（创建 7 个作者账号）
-- 或：已有同昵称的 profile 时，本脚本单独执行即可补 column_locks。
-- ============================================================

set search_path = public, extensions;

do $$
declare
    a record;
    v_user uuid;
begin
    for a in
        select *
        from (values
            ('world-needs-sunday', 'bxworld-needs-sunday'),
            ('stripe-python',      'bxstripe-python'),
            ('Xesir',              'ququXesir'),
            ('Fohen',              'gunmuFohen'),
            ('lker',               'bxlker'),
            ('dbywsc',             'bxdbywsc'),
            ('renzhaoyang',        'bxrenzhaoyang')
        ) as t(name, pwd)
    loop
        select id into v_user
        from public.profiles
        where nickname = a.name
        limit 1;

        if v_user is null then
            raise notice '跳过 %：找不到昵称对应的 profile', a.name;
            continue;
        end if;

        -- 激活账号；站主设为管理员
        update public.profiles
        set status = 'active',
            role = case when a.name = 'world-needs-sunday' then 'admin' else role end,
            updated_at = now()
        where id = v_user;

        -- 特定专栏密码 = 该作者的登录密码
        insert into public.column_locks (user_id, column_key, column_name, password_hash, is_default)
        values (v_user, a.name, a.name, crypt(a.pwd, gen_salt('bf')), false)
        on conflict (column_key) where is_default = false
        do update set
            user_id = excluded.user_id,
            column_name = excluded.column_name,
            password_hash = excluded.password_hash,
            updated_at = now();

        -- 默认专栏密码 = 该作者的登录密码
        insert into public.column_locks (user_id, column_key, column_name, password_hash, is_default)
        values (v_user, '__default__', '默认专栏访问密码', crypt(a.pwd, gen_salt('bf')), true)
        on conflict (user_id, column_key)
        do update set
            password_hash = excluded.password_hash,
            updated_at = now();

        raise notice '已初始化 % 的登录专栏与默认专栏密码', a.name;
    end loop;
end;
$$;
