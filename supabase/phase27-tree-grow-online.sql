-- phase27-tree-grow-online.sql
-- 前置迁移：phase2.sql（profiles / is_admin / 新用户触发器）、phase26 或之前的任意版本
-- 执行方式：Supabase SQL Editor 整段 Run（幂等，可重复执行）
-- 用途：生长树：图论 联机房间、行动意图、积分榜
--
-- 设计要点：
--   1. 房主（host）固定红方，客人（guest）固定蓝方；房主是唯一权威，负责写入局面快照。
--   2. 客人只提交“行动意图”到 tree_grow_actions，由房主校验后写入 tree_grow_rooms.state。
--   3. 积分写入独立的 tree_grow_ratings，不改动 profiles，避免影响知识库业务。
--   4. 所有写操作都走 security definer RPC；前端只拿到 publishable key。

-- ============================================================
-- 1. 房间表
-- ============================================================
create table if not exists public.tree_grow_rooms (
    id uuid primary key default gen_random_uuid(),
    code text not null unique,
    host_id uuid not null references auth.users(id) on delete cascade,
    guest_id uuid references auth.users(id) on delete set null,
    host_nickname text,
    guest_nickname text,
    status text not null default 'waiting'
        check (status in ('waiting', 'base', 'playing', 'finished', 'closed')),
    map_seeds jsonb,
    red_base_id integer,
    blue_base_id integer,
    state jsonb,
    last_action jsonb,
    result jsonb,
    version integer not null default 0,
    winner text check (winner in ('red', 'blue')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    finished_at timestamptz
);

create index if not exists tree_grow_rooms_status_idx
    on public.tree_grow_rooms (status, created_at desc);
create index if not exists tree_grow_rooms_host_idx
    on public.tree_grow_rooms (host_id);

-- ============================================================
-- 2. 行动意图表（客人 -> 房主）
-- ============================================================
create table if not exists public.tree_grow_actions (
    id bigserial primary key,
    room_id uuid not null references public.tree_grow_rooms(id) on delete cascade,
    actor_id uuid not null references auth.users(id) on delete cascade,
    seq integer not null,
    payload jsonb not null,
    created_at timestamptz not null default now(),
    unique (room_id, seq)
);

create index if not exists tree_grow_actions_room_idx
    on public.tree_grow_actions (room_id, seq);

-- ============================================================
-- 3. 积分表（独立于 profiles）
-- ============================================================
create table if not exists public.tree_grow_ratings (
    user_id uuid primary key references auth.users(id) on delete cascade,
    nickname text,
    points integer not null default 1000,
    wins integer not null default 0,
    losses integer not null default 0,
    draws integer not null default 0,
    games integer not null default 0,
    updated_at timestamptz not null default now()
);

-- ============================================================
-- 4. RPC：加入房间（原子操作，避免两人同时抢座）
-- ============================================================
create or replace function public.tree_grow_join_room(p_code text)
returns public.tree_grow_rooms
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
    v_nickname text;
begin
    if auth.uid() is null then
        raise exception '请先登录';
    end if;

    select * into r
    from public.tree_grow_rooms
    where code = upper(trim(p_code))
    for update;

    if not found then
        raise exception '房间不存在或已关闭';
    end if;

    -- 房主凭房间码重进
    if r.host_id = auth.uid() then
        return r;
    end if;

    -- 已在房间里的客人重进
    if r.guest_id = auth.uid() then
        return r;
    end if;

    if r.guest_id is not null then
        raise exception '房间已满';
    end if;
    if r.status <> 'waiting' then
        raise exception '对局已经开始，无法加入';
    end if;

    select coalesce(nickname, '玩家') into v_nickname
    from public.profiles
    where id = auth.uid();

    update public.tree_grow_rooms
    set guest_id = auth.uid(),
        guest_nickname = coalesce(v_nickname, '玩家'),
        status = 'base',
        updated_at = now()
    where id = r.id
    returning * into r;

    return r;
end;
$$;

grant execute on function public.tree_grow_join_room(text) to authenticated;

-- ============================================================
-- 5. RPC：选择基地（房主先选红方，客人再选蓝方）
-- ============================================================
create or replace function public.tree_grow_set_base(p_room_id uuid, p_area_id integer)
returns public.tree_grow_rooms
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
begin
    if auth.uid() is null then
        raise exception '请先登录';
    end if;
    if p_area_id is null or p_area_id < 1 then
        raise exception '基地区域无效';
    end if;

    select * into r
    from public.tree_grow_rooms
    where id = p_room_id
    for update;

    if not found then
        raise exception '房间不存在';
    end if;
    if r.status not in ('base', 'playing') then
        raise exception '当前阶段不能选择基地';
    end if;

    if r.host_id = auth.uid() then
        if r.red_base_id is not null then
            raise exception '红方基地已经确定';
        end if;
        update public.tree_grow_rooms
        set red_base_id = p_area_id, updated_at = now()
        where id = r.id
        returning * into r;
        return r;
    end if;

    if r.guest_id = auth.uid() then
        if r.red_base_id is null then
            raise exception '请等待红方先选择基地';
        end if;
        if p_area_id = r.red_base_id then
            raise exception '该区域已被红方占用';
        end if;
        if r.blue_base_id is not null then
            raise exception '蓝方基地已经确定';
        end if;
        update public.tree_grow_rooms
        set blue_base_id = p_area_id, updated_at = now()
        where id = r.id
        returning * into r;
        return r;
    end if;

    raise exception '你不是该房间成员';
end;
$$;

grant execute on function public.tree_grow_set_base(uuid, integer) to authenticated;

-- ============================================================
-- 6. RPC：房主同步局面快照
-- ============================================================
create or replace function public.tree_grow_sync_state(
    p_room_id uuid,
    p_state jsonb,
    p_version integer,
    p_last_action jsonb default null
)
returns public.tree_grow_rooms
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
begin
    if auth.uid() is null then
        raise exception '请先登录';
    end if;

    select * into r
    from public.tree_grow_rooms
    where id = p_room_id
    for update;

    if not found then
        raise exception '房间不存在';
    end if;
    if r.host_id <> auth.uid() then
        raise exception '只有房主可以同步局面';
    end if;
    if r.status not in ('base', 'playing') then
        raise exception '当前阶段不能同步局面';
    end if;
    if r.red_base_id is null or r.blue_base_id is null then
        raise exception '双方基地尚未确定';
    end if;
    if p_state is null then
        raise exception '局面快照不能为空';
    end if;

    -- 旧版本或重复提交直接忽略，保证幂等
    if coalesce(p_version, 0) <= r.version then
        return r;
    end if;

    update public.tree_grow_rooms
    set state = p_state,
        last_action = p_last_action,
        version = p_version,
        status = 'playing',
        updated_at = now()
    where id = r.id
    returning * into r;

    return r;
end;
$$;

grant execute on function public.tree_grow_sync_state(uuid, jsonb, integer, jsonb) to authenticated;

-- ============================================================
-- 7. RPC：提交行动意图（客人 -> 房主）
-- ============================================================
create or replace function public.tree_grow_submit_intent(
    p_room_id uuid,
    p_seq integer,
    p_payload jsonb
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
begin
    if auth.uid() is null then
        raise exception '请先登录';
    end if;
    if p_seq is null or p_seq < 1 then
        raise exception '行动序号无效';
    end if;
    if p_payload is null then
        raise exception '行动内容不能为空';
    end if;

    select * into r
    from public.tree_grow_rooms
    where id = p_room_id;

    if not found then
        raise exception '房间不存在';
    end if;
    if r.host_id <> auth.uid() and coalesce(r.guest_id, '00000000-0000-0000-0000-000000000000'::uuid) <> auth.uid() then
        raise exception '你不是该房间成员';
    end if;
    if r.status <> 'playing' then
        raise exception '对局尚未开始或已经结束';
    end if;

    insert into public.tree_grow_actions (room_id, actor_id, seq, payload)
    values (p_room_id, auth.uid(), p_seq, p_payload)
    on conflict (room_id, seq) do nothing;
end;
$$;

grant execute on function public.tree_grow_submit_intent(uuid, integer, jsonb) to authenticated;

-- ============================================================
-- 8. RPC：结束对局并结算积分（仅房主可调用）
-- ============================================================
create or replace function public.tree_grow_finish_room(
    p_room_id uuid,
    p_winner text,
    p_state jsonb default null,
    p_last_action jsonb default null,
    p_result jsonb default null
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
    v_winner_id uuid;
    v_loser_id uuid;
begin
    if auth.uid() is null then
        raise exception '请先登录';
    end if;
    if p_winner is null or p_winner not in ('red', 'blue') then
        raise exception '获胜方无效';
    end if;

    select * into r
    from public.tree_grow_rooms
    where id = p_room_id
    for update;

    if not found then
        raise exception '房间不存在';
    end if;
    if r.host_id <> auth.uid() then
        raise exception '只有房主可以结算';
    end if;
    if r.status = 'finished' then
        return;
    end if;
    if r.status <> 'playing' then
        raise exception '对局尚未开始';
    end if;

    update public.tree_grow_rooms
    set status = 'finished',
        winner = p_winner,
        state = coalesce(p_state, state),
        last_action = coalesce(p_last_action, last_action),
        result = coalesce(p_result, result),
        version = version + 1,
        finished_at = now(),
        updated_at = now()
    where id = r.id;

    -- 单人房不结算积分
    if r.guest_id is null then
        return;
    end if;

    v_winner_id := case when p_winner = 'red' then r.host_id else r.guest_id end;
    v_loser_id := case when p_winner = 'red' then r.guest_id else r.host_id end;

    insert into public.tree_grow_ratings (user_id, nickname)
    values (r.host_id, coalesce(r.host_nickname, '玩家'))
    on conflict (user_id) do nothing;

    insert into public.tree_grow_ratings (user_id, nickname)
    values (r.guest_id, coalesce(r.guest_nickname, '玩家'))
    on conflict (user_id) do nothing;

    update public.tree_grow_ratings
    set points = greatest(0, points + 25),
        wins = wins + 1,
        games = games + 1,
        nickname = coalesce((select nickname from public.profiles where id = v_winner_id), nickname),
        updated_at = now()
    where user_id = v_winner_id;

    update public.tree_grow_ratings
    set points = greatest(0, points - 10),
        losses = losses + 1,
        games = games + 1,
        nickname = coalesce((select nickname from public.profiles where id = v_loser_id), nickname),
        updated_at = now()
    where user_id = v_loser_id;
end;
$$;

grant execute on function public.tree_grow_finish_room(uuid, text, jsonb, jsonb, jsonb) to authenticated;

-- ============================================================
-- 9. RPC：离开房间
-- ============================================================
create or replace function public.tree_grow_leave_room(p_room_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    r public.tree_grow_rooms;
begin
    if auth.uid() is null then
        return;
    end if;

    select * into r
    from public.tree_grow_rooms
    where id = p_room_id
    for update;

    if not found then
        return;
    end if;

    if r.host_id = auth.uid() then
        update public.tree_grow_rooms
        set status = 'closed', updated_at = now()
        where id = r.id and status <> 'finished';
        return;
    end if;

    if r.guest_id = auth.uid() then
        if r.status = 'playing' then
            update public.tree_grow_rooms
            set status = 'closed', updated_at = now()
            where id = r.id;
        elsif r.status in ('waiting', 'base') then
            -- 还没开局：清空座位与基地，让房主继续等新对手
            update public.tree_grow_rooms
            set guest_id = null,
                guest_nickname = null,
                red_base_id = null,
                blue_base_id = null,
                status = 'waiting',
                updated_at = now()
            where id = r.id;
        end if;
        return;
    end if;
end;
$$;

grant execute on function public.tree_grow_leave_room(uuid) to authenticated;

-- ============================================================
-- 10. RLS
-- ============================================================
alter table public.tree_grow_rooms enable row level security;
alter table public.tree_grow_actions enable row level security;
alter table public.tree_grow_ratings enable row level security;

-- 房间：登录用户可读（大厅列表）；仅房主可插入/修改/删除，其他写操作走 RPC
drop policy if exists tree_grow_rooms_select on public.tree_grow_rooms;
create policy tree_grow_rooms_select on public.tree_grow_rooms
    for select to authenticated using (true);

drop policy if exists tree_grow_rooms_insert on public.tree_grow_rooms;
create policy tree_grow_rooms_insert on public.tree_grow_rooms
    for insert to authenticated with check (host_id = auth.uid());

drop policy if exists tree_grow_rooms_update on public.tree_grow_rooms;
create policy tree_grow_rooms_update on public.tree_grow_rooms
    for update to authenticated
    using (host_id = auth.uid())
    with check (host_id = auth.uid());

drop policy if exists tree_grow_rooms_delete on public.tree_grow_rooms;
create policy tree_grow_rooms_delete on public.tree_grow_rooms
    for delete to authenticated using (host_id = auth.uid());

-- 行动：只有房间成员可读；写入只能走 tree_grow_submit_intent
drop policy if exists tree_grow_actions_select on public.tree_grow_actions;
create policy tree_grow_actions_select on public.tree_grow_actions
    for select to authenticated using (
        exists (
            select 1 from public.tree_grow_rooms r
            where r.id = room_id
              and (r.host_id = auth.uid() or r.guest_id = auth.uid())
        )
    );

-- 积分：公开可读，写入只走 tree_grow_finish_room
drop policy if exists tree_grow_ratings_select on public.tree_grow_ratings;
create policy tree_grow_ratings_select on public.tree_grow_ratings
    for select to anon, authenticated using (true);

grant select on public.tree_grow_rooms to authenticated;
grant select on public.tree_grow_actions to authenticated;
grant select on public.tree_grow_ratings to anon, authenticated;

revoke insert, update, delete on public.tree_grow_actions from anon, authenticated;
revoke insert, update, delete on public.tree_grow_ratings from anon, authenticated;

-- 函数默认对 PUBLIC 开放 EXECUTE；收紧为仅登录用户与 service_role 可调用
revoke execute on function public.tree_grow_join_room(text) from public, anon;
revoke execute on function public.tree_grow_set_base(uuid, integer) from public, anon;
revoke execute on function public.tree_grow_sync_state(uuid, jsonb, integer, jsonb) from public, anon;
revoke execute on function public.tree_grow_submit_intent(uuid, integer, jsonb) from public, anon;
revoke execute on function public.tree_grow_finish_room(uuid, text, jsonb, jsonb, jsonb) from public, anon;
revoke execute on function public.tree_grow_leave_room(uuid) from public, anon;

grant execute on function public.tree_grow_join_room(text) to authenticated, service_role;
grant execute on function public.tree_grow_set_base(uuid, integer) to authenticated, service_role;
grant execute on function public.tree_grow_sync_state(uuid, jsonb, integer, jsonb) to authenticated, service_role;
grant execute on function public.tree_grow_submit_intent(uuid, integer, jsonb) to authenticated, service_role;
grant execute on function public.tree_grow_finish_room(uuid, text, jsonb, jsonb, jsonb) to authenticated, service_role;
grant execute on function public.tree_grow_leave_room(uuid) to authenticated, service_role;

-- ============================================================
-- 11. Realtime 发布（房间与行动变化实时推送）
-- ============================================================
do $$
begin
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = 'tree_grow_rooms'
    ) then
        alter publication supabase_realtime add table public.tree_grow_rooms;
    end if;

    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = 'tree_grow_actions'
    ) then
        alter publication supabase_realtime add table public.tree_grow_actions;
    end if;
end $$;

-- ============================================================
-- 12. 自检
-- ============================================================
select table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in ('tree_grow_rooms', 'tree_grow_actions', 'tree_grow_ratings')
order by table_name;

select proname
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname like 'tree_grow_%'
order by proname;
