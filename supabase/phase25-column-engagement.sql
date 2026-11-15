-- ============================================================
-- 第二十五阶段：专栏评论 / 点赞
-- 作者：World-Needs-Sunday（AI 辅助）
-- 内容：
--   1. column_comments：专栏评论（登录用户可发，本人或管理员可删）
--   2. column_likes：专栏点赞（每个用户对每个专栏最多 1 次）
--   3. column_like_counts：公开的点赞数视图
--   4. 评论作者名由触发器从 profiles.nickname 快照，前端传值无效
-- 说明：
--   - 点赞数不直接写 columns 表，前端按「每赞 +0.05、单专栏上限 1.0」
--     计入作者贡献度，避免触发器链与并发写冲突。
--   - 在 Supabase SQL Editor 整段执行；幂等，可重复执行。
-- ============================================================

-- ---------- 1. 评论 ----------
create table if not exists public.column_comments (
    id bigint generated always as identity primary key,
    column_key text not null,
    user_id uuid not null references auth.users(id) on delete cascade,
    author_name text not null default '',
    content text not null,
    created_at timestamptz not null default now(),
    constraint column_comments_content_len check (char_length(btrim(content)) between 1 and 500)
);

create index if not exists idx_column_comments_key_time
    on public.column_comments (column_key, created_at desc);

alter table public.column_comments enable row level security;

-- 评论作者名快照：忽略客户端传入的 author_name
create or replace function public.column_comment_set_author()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    new.content := btrim(new.content);
    select p.nickname into new.author_name
    from public.profiles p
    where p.id = new.user_id;
    new.author_name := coalesce(nullif(btrim(new.author_name), ''), '匿名用户');
    return new;
end;
$$;

drop trigger if exists trg_column_comment_set_author on public.column_comments;
create trigger trg_column_comment_set_author
    before insert on public.column_comments
    for each row execute function public.column_comment_set_author();

-- ---------- 2. 点赞 ----------
create table if not exists public.column_likes (
    column_key text not null,
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (column_key, user_id)
);

create index if not exists idx_column_likes_key on public.column_likes (column_key);

alter table public.column_likes enable row level security;

-- ---------- 3. 点赞数公开视图 ----------
create or replace view public.column_like_counts
with (security_invoker = true) as
select column_key, count(*)::int as likes
from public.column_likes
group by column_key;

grant select on public.column_like_counts to anon, authenticated;

-- ---------- 4. RLS 策略（重复执行安全） ----------
drop policy if exists column_comments_read on public.column_comments;
create policy column_comments_read on public.column_comments
    for select to anon, authenticated using (true);

drop policy if exists column_comments_insert on public.column_comments;
create policy column_comments_insert on public.column_comments
    for insert to authenticated
    with check (user_id = auth.uid());

drop policy if exists column_comments_delete on public.column_comments;
create policy column_comments_delete on public.column_comments
    for delete to authenticated
    using (user_id = auth.uid() or public.is_admin());

drop policy if exists column_likes_read on public.column_likes;
create policy column_likes_read on public.column_likes
    for select to anon, authenticated using (true);

drop policy if exists column_likes_insert on public.column_likes;
create policy column_likes_insert on public.column_likes
    for insert to authenticated
    with check (user_id = auth.uid());

drop policy if exists column_likes_delete on public.column_likes;
create policy column_likes_delete on public.column_likes
    for delete to authenticated
    using (user_id = auth.uid());

-- ---------- 5. 执行后检查 ----------
select 'column_comments' as table_name, count(*) as rows from public.column_comments
union all
select 'column_likes', count(*) from public.column_likes;

select column_key, likes from public.column_like_counts order by likes desc limit 10;
