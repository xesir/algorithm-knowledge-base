-- ============================================================
-- 把现有用户按昵称绑定到同名作者专栏
-- 前置：已执行 supabase/phase3-columns.sql
-- 在 Supabase SQL Editor 整段运行。
-- ============================================================

with authors(name) as (
    values
        ('world-needs-sunday'),
        ('stripe-python'),
        ('Xesir'),
        ('Fohen'),
        ('lker'),
        ('dbywsc'),
        ('renzhaoyang')
)
insert into public.columns (owner_id, column_key, column_name)
select p.id, a.name, a.name
from public.profiles p
join authors a on lower(p.nickname) = lower(a.name)
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    updated_at = now();

-- 给每个有专栏的用户补一条“默认专栏密码”记录（空 hash = 无通用密码）
insert into public.column_locks (user_id, column_key, column_name, password_hash, is_default)
select c.owner_id, '__default__', '默认专栏访问密码', null, true
from public.columns c
on conflict (user_id, column_key) do nothing;

-- 把已有的特定专栏密码记录归到同名作者用户名下
update public.column_locks l
set user_id = c.owner_id,
    updated_at = now()
from public.columns c
where l.is_default = false
  and l.column_key = c.column_key
  and l.user_id <> c.owner_id;

-- 查看绑定结果
select c.column_key, c.column_name, p.nickname, u.email, p.role, p.status
from public.columns c
join public.profiles p on p.id = c.owner_id
join auth.users u on u.id = c.owner_id
order by c.column_key;
