-- ============================================================
-- 第二十六阶段：专栏点踩 / 评分 + 评论与赞踩通知
-- 作者：World-Needs-Sunday（AI 辅助）
-- 前置：phase23（notifications）、phase25（column_comments / column_likes）
-- 内容：
--   1. column_dislikes：专栏点踩（每个用户对每个专栏最多 1 次）
--   2. 投票互斥：点赞时移除点踩，点踩时移除点赞
--   3. column_vote_counts：公开的赞 / 踩 / 评分（好评率）视图
--   4. 触发器：新评论、新点赞、新点踩都会通知专栏作者（本人操作不通知）
-- 说明：
--   - 评分 = round(点赞 ÷ (点赞 + 点踩) × 100)，无投票时前端显示「暂无评分」；
--   - 点踩不扣作者贡献度（避免刷踩攻击），仅作为评分展示；
--   - 在 Supabase SQL Editor 整段执行；幂等，可重复执行。
-- ============================================================

-- ---------- 1. 点踩 ----------
create table if not exists public.column_dislikes (
    column_key text not null,
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (column_key, user_id)
);

create index if not exists idx_column_dislikes_key on public.column_dislikes (column_key);

alter table public.column_dislikes enable row level security;

-- ---------- 2. 投票互斥（赞 / 踩只能选一个） ----------
create or replace function public.column_vote_keep_single()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if tg_table_name = 'column_likes' then
        delete from public.column_dislikes d
        where d.column_key = new.column_key and d.user_id = new.user_id;
    else
        delete from public.column_likes l
        where l.column_key = new.column_key and l.user_id = new.user_id;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_column_like_single on public.column_likes;
create trigger trg_column_like_single
    before insert on public.column_likes
    for each row execute function public.column_vote_keep_single();

drop trigger if exists trg_column_dislike_single on public.column_dislikes;
create trigger trg_column_dislike_single
    before insert on public.column_dislikes
    for each row execute function public.column_vote_keep_single();

-- ---------- 3. 赞 / 踩 / 评分公开视图 ----------
create or replace view public.column_vote_counts
with (security_invoker = true) as
select
    column_key,
    sum(case when v > 0 then 1 else 0 end)::int as likes,
    sum(case when v < 0 then 1 else 0 end)::int as dislikes,
    round(100.0 * sum(case when v > 0 then 1 else 0 end) / count(*))::int as rating
from (
    select column_key, 1 as v from public.column_likes
    union all
    select column_key, -1 as v from public.column_dislikes
) votes
group by column_key;

grant select on public.column_vote_counts to anon, authenticated;

-- ---------- 4. 评论 / 赞 / 踩 → 通知专栏作者 ----------
create or replace function public.notify_column_engagement()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_owner uuid;
    v_name text;
    v_actor text;
    v_kind text;
    v_title text;
    v_body text;
    v_link text;
    v_hash text;
begin
    select c.owner_id, c.column_name
    into v_owner, v_name
    from public.columns c
    where c.column_key = new.column_key;

    -- 专栏没有作者、或操作者本人就是作者时，不通知
    if v_owner is null or v_owner = new.user_id then
        return new;
    end if;

    select coalesce(nullif(p.nickname, ''), '有用户')
    into v_actor
    from public.profiles p
    where p.id = new.user_id;

    v_hash := case
        when new.column_key like 'sub-%' then new.column_key
        else regexp_replace(new.column_key, '^col-', '')
    end;
    v_link := 'index.html#' || v_hash;
    v_name := coalesce(nullif(v_name, ''), left(new.column_key, 40));

    if tg_table_name = 'column_comments' then
        v_kind := 'column_comment';
        v_title := '你的专栏收到新评论';
        v_body := v_name || ' · ' || v_actor || '：' || left(btrim(new.content), 60);
    elsif tg_table_name = 'column_likes' then
        v_kind := 'column_like';
        v_title := '你的专栏收到一个赞';
        v_body := v_name || ' · 来自 ' || v_actor;
    else
        v_kind := 'column_dislike';
        v_title := '你的专栏收到一个踩';
        v_body := v_name || ' · 来自 ' || v_actor;
    end if;

    insert into public.notifications (user_id, kind, title, body, link)
    values (v_owner, v_kind, v_title, v_body, v_link);

    return new;
end;
$$;

drop trigger if exists trg_zz_notify_column_comment on public.column_comments;
create trigger trg_zz_notify_column_comment
    after insert on public.column_comments
    for each row execute function public.notify_column_engagement();

drop trigger if exists trg_zz_notify_column_like on public.column_likes;
create trigger trg_zz_notify_column_like
    after insert on public.column_likes
    for each row execute function public.notify_column_engagement();

drop trigger if exists trg_zz_notify_column_dislike on public.column_dislikes;
create trigger trg_zz_notify_column_dislike
    after insert on public.column_dislikes
    for each row execute function public.notify_column_engagement();

-- ---------- 5. RLS 策略（重复执行安全） ----------
drop policy if exists column_dislikes_read on public.column_dislikes;
create policy column_dislikes_read on public.column_dislikes
    for select to anon, authenticated using (true);

drop policy if exists column_dislikes_insert on public.column_dislikes;
create policy column_dislikes_insert on public.column_dislikes
    for insert to authenticated
    with check (user_id = auth.uid());

drop policy if exists column_dislikes_delete on public.column_dislikes;
create policy column_dislikes_delete on public.column_dislikes
    for delete to authenticated
    using (user_id = auth.uid());

-- ---------- 6. 刷新 PostgREST 缓存 ----------
notify pgrst, 'reload schema';

-- ---------- 7. 执行后检查 ----------
select 'column_dislikes' as table_name, count(*) as rows from public.column_dislikes
union all
select 'column_likes', count(*) from public.column_likes;

select column_key, likes, dislikes, rating
from public.column_vote_counts
order by likes desc
limit 10;

select proname
from pg_proc
where proname in ('column_vote_keep_single', 'notify_column_engagement')
order by proname;
