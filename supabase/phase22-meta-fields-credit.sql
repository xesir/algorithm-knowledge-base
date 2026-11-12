-- ============================================================
-- 第二十二阶段：便捷修改扩展字段 + 元数据贡献 0.02
-- 前置：phase21 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. columns 增加 cf_rating / oj / problem_id / time_complexity /
--      space_complexity / meta_override；
--   2. published_columns 暴露新字段；
--   3. admin_update_column_meta 支持新字段，并写一条 approved 审计工单；
--   4. submit_column_meta_edit 支持新字段（普通用户工单）；
--   5. AFTER UPDATE 触发器把工单里的新字段写回 columns；
--   6. author_edit_credits 排除 meta_only；新增 author_meta_credits
--      （便捷修改按作者+专栏去重，前端每条计 0.02）。
-- ============================================================

-- ---------- 1. 字段 ----------
alter table public.columns add column if not exists cf_rating text;
alter table public.columns add column if not exists oj text;
alter table public.columns add column if not exists problem_id text;
alter table public.columns add column if not exists time_complexity text;
alter table public.columns add column if not exists space_complexity text;
alter table public.columns add column if not exists meta_override boolean not null default false;

-- ---------- 2. 公开视图 ----------
create or replace view public.published_columns
with (security_invoker = false)
as
select c.column_key,
       c.column_name,
       c.category,
       c.kind,
       c.difficulty,
       c.parent_key,
       c.tags,
       c.content,
       c.relations,
       c.relations_override,
       c.created_at,
       c.updated_at,
       coalesce(nullif(p.nickname, ''), 'world-needs-sunday') as author_name,
       (coalesce(s.password_hash, d.password_hash) is not null) as locked,
       c.cf_rating,
       c.oj,
       c.problem_id,
       c.time_complexity,
       c.space_complexity,
       c.meta_override
from public.columns c
left join public.profiles p on p.id = c.owner_id
left join public.column_locks s on s.column_key = c.column_key and s.is_default = false
left join public.column_locks d on d.user_id = c.owner_id and d.is_default = true
where c.status = 'published'
  and (c.column_key like 'col-%' or c.column_key like 'sub-%');

grant select on public.published_columns to anon, authenticated;

-- ---------- 3. 管理员直接改元数据（含新字段 + 审计工单） ----------
create or replace function public.admin_update_column_meta(p jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid uuid := auth.uid();
    v_role text;
    v_key text := nullif(btrim(coalesce(p->>'column_key', '')), '');
    v_expected timestamptz;
    v_current timestamptz;
    v_column_name text;
    v_category text;
    v_difficulty text;
    v_tags_current text[];
    v_relations_current jsonb;
    v_cf_rating text;
    v_oj text;
    v_problem_id text;
    v_time_complexity text;
    v_space_complexity text;
    v_tags text[];
    v_relations jsonb := coalesce(p->'relations', '[]'::jsonb);
    v_first jsonb;
    v_first_type text;
    v_first_target text;
    v_payload jsonb;
    v_ticket_id bigint;
begin
    if v_uid is null then
        raise exception '请先登录';
    end if;

    select role into v_role from public.profiles where id = v_uid;
    if coalesce(v_role, '') <> 'admin' then
        raise exception '仅管理员可直接修改元数据';
    end if;

    if v_key is null then
        raise exception 'column_key 不能为空';
    end if;

    if jsonb_typeof(v_relations) <> 'array' then
        raise exception 'relations 必须是数组';
    end if;
    if exists (
        select 1
        from jsonb_array_elements(v_relations) as r
        where coalesce(r->>'type', '') not in ('related', 'sequence', 'parent-child')
           or nullif(r->>'target', '') is null
    ) then
        raise exception '每条关系都必须包含类型和关联目标';
    end if;

    if jsonb_typeof(p->'tags') = 'array' then
        select coalesce(array_agg(value), array[]::text[])
        into v_tags
        from jsonb_array_elements_text(p->'tags');
    end if;

    v_first := v_relations->0;
    v_first_type := nullif(v_first->>'type', '');
    v_first_target := nullif(v_first->>'target', '');

    select updated_at, column_name, category, difficulty, tags, relations,
           cf_rating, oj, problem_id, time_complexity, space_complexity
    into v_current, v_column_name, v_category, v_difficulty, v_tags_current,
         v_relations_current, v_cf_rating, v_oj, v_problem_id,
         v_time_complexity, v_space_complexity
    from public.columns
    where column_key = v_key
    for update;

    if not found then
        raise exception '目标专栏不存在：%', v_key;
    end if;

    if nullif(p->>'expected_updated_at', '') is null then
        raise exception '缺少 expected_updated_at，拒绝覆盖';
    end if;
    begin
        v_expected := (p->>'expected_updated_at')::timestamptz;
    exception when others then
        raise exception 'expected_updated_at 格式不正确';
    end;
    if v_current > v_expected then
        raise exception '目标专栏已被更新（当前 % ，期望 % ），请重新载入后再改',
            v_current, v_expected;
    end if;

    update public.columns
    set column_name = coalesce(nullif(p->>'column_name', ''), column_name),
        category = coalesce(nullif(p->>'category', ''), category),
        difficulty = case when p ? 'difficulty' then nullif(p->>'difficulty', '') else difficulty end,
        tags = case when jsonb_typeof(p->'tags') = 'array' then v_tags else tags end,
        relations = case when p ? 'relations' then v_relations else relations end,
        relations_override = case when p ? 'relations' then true else relations_override end,
        relation_type = case when p ? 'relations' then v_first_type else relation_type end,
        relation_target = case when p ? 'relations' then v_first_target else relation_target end,
        parent_key = case
            when p ? 'relations' then (
                select nullif(r->>'target', '')
                from jsonb_array_elements(v_relations) as r
                where r->>'type' = 'parent-child'
                limit 1
            )
            else parent_key
        end,
        cf_rating = case when p ? 'cf_rating' then nullif(p->>'cf_rating', '') else cf_rating end,
        oj = case when p ? 'oj' then nullif(p->>'oj', '') else oj end,
        problem_id = case when p ? 'problem_id' then nullif(p->>'problem_id', '') else problem_id end,
        time_complexity = case when p ? 'time_complexity' then nullif(p->>'time_complexity', '') else time_complexity end,
        space_complexity = case when p ? 'space_complexity' then nullif(p->>'space_complexity', '') else space_complexity end,
        meta_override = case
            when p ? 'cf_rating' or p ? 'oj' or p ? 'problem_id'
              or p ? 'time_complexity' or p ? 'space_complexity'
            then true else meta_override end,
        updated_at = now()
    where column_key = v_key;

    if v_tags is not null then
        insert into public.tags (name)
        select unnest(v_tags)
        on conflict (name) do nothing;
    end if;

    -- 管理员直改也留一条 approved 审计工单，供 author_meta_credits 计 0.02。
    v_payload := jsonb_build_object(
        'column_key', v_key,
        'meta_only', true,
        'column_name', coalesce(nullif(p->>'column_name', ''), v_column_name),
        'category', coalesce(nullif(p->>'category', ''), v_category),
        'difficulty', case when p ? 'difficulty' then nullif(p->>'difficulty', '') else v_difficulty end,
        'tags', case when p ? 'tags' then p->'tags' else to_jsonb(v_tags_current) end,
        'relations', case when p ? 'relations' then v_relations else v_relations_current end,
        'cf_rating', case when p ? 'cf_rating' then nullif(p->>'cf_rating', '') else v_cf_rating end,
        'oj', case when p ? 'oj' then nullif(p->>'oj', '') else v_oj end,
        'problem_id', case when p ? 'problem_id' then nullif(p->>'problem_id', '') else v_problem_id end,
        'time_complexity', case when p ? 'time_complexity' then nullif(p->>'time_complexity', '') else v_time_complexity end,
        'space_complexity', case when p ? 'space_complexity' then nullif(p->>'space_complexity', '') else v_space_complexity end
    );

    insert into public.tickets (
        user_id, title, type, priority, description, status, payload, reviewed_at
    )
    values (
        v_uid,
        '元数据修改：' || coalesce(v_column_name, v_key),
        'edit',
        'mid',
        '管理员便捷修改（直接生效）',
        'approved',
        v_payload,
        now()
    )
    returning id into v_ticket_id;

    select updated_at into v_current from public.columns where column_key = v_key;
    return jsonb_build_object(
        'column_key', v_key,
        'updated_at', v_current,
        'mode', 'admin_meta',
        'ticket_id', v_ticket_id
    );
end;
$$;

revoke all on function public.admin_update_column_meta(jsonb) from public, anon;
grant execute on function public.admin_update_column_meta(jsonb) to authenticated;

-- ---------- 4. 普通用户元数据工单（含新字段） ----------
drop function if exists public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text);
drop function if exists public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text, text, text, text, text, text);

create or replace function public.submit_column_meta_edit(
    p_key text,
    p_column_name text,
    p_category text,
    p_difficulty text,
    p_tags text[],
    p_relations jsonb,
    p_note text,
    p_cf_rating text,
    p_oj text,
    p_problem_id text,
    p_time_complexity text,
    p_space_complexity text
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid uuid := auth.uid();
    v_key text := nullif(btrim(coalesce(p_key, '')), '');
    v_current timestamptz;
    v_content text;
    v_column_name text;
    v_kind text;
    v_category text;
    v_difficulty text;
    v_tags_current text[];
    v_relations_current jsonb;
    v_cf_rating text;
    v_oj text;
    v_problem_id text;
    v_time_complexity text;
    v_space_complexity text;
    v_relations jsonb := coalesce(p_relations, '[]'::jsonb);
    v_payload jsonb;
    v_ticket_id integer;
begin
    if v_uid is null then
        raise exception '请先登录后再提交修改';
    end if;
    if v_key is null then
        raise exception 'column_key 不能为空';
    end if;

    if jsonb_typeof(v_relations) <> 'array' then
        raise exception 'relations 必须是数组';
    end if;
    if exists (
        select 1
        from jsonb_array_elements(v_relations) as r
        where coalesce(r->>'type', '') not in ('related', 'sequence', 'parent-child')
           or nullif(r->>'target', '') is null
    ) then
        raise exception '每条关系都必须包含类型和关联目标';
    end if;

    select updated_at, content, column_name, kind, category, difficulty, tags,
           relations, cf_rating, oj, problem_id, time_complexity, space_complexity
    into v_current, v_content, v_column_name, v_kind, v_category, v_difficulty,
         v_tags_current, v_relations_current, v_cf_rating, v_oj, v_problem_id,
         v_time_complexity, v_space_complexity
    from public.columns
    where column_key = v_key;

    if not found then
        raise exception '目标专栏不存在：%', v_key;
    end if;

    v_payload := jsonb_build_object(
        'column_key', v_key,
        'meta_only', true,
        'column_name', coalesce(nullif(btrim(coalesce(p_column_name, '')), ''), v_column_name),
        'category', nullif(btrim(coalesce(p_category, '')), ''),
        'difficulty', nullif(btrim(coalesce(p_difficulty, '')), ''),
        'tags', to_jsonb(coalesce(p_tags, array[]::text[])),
        'relations', v_relations,
        'cf_rating', nullif(btrim(coalesce(p_cf_rating, '')), ''),
        'oj', nullif(btrim(coalesce(p_oj, '')), ''),
        'problem_id', nullif(btrim(coalesce(p_problem_id, '')), ''),
        'time_complexity', nullif(btrim(coalesce(p_time_complexity, '')), ''),
        'space_complexity', nullif(btrim(coalesce(p_space_complexity, '')), ''),
        'old_column_name', v_column_name,
        'old_category', v_category,
        'old_difficulty', v_difficulty,
        'old_tags', to_jsonb(coalesce(v_tags_current, array[]::text[])),
        'old_relations', coalesce(v_relations_current, '[]'::jsonb),
        'old_cf_rating', v_cf_rating,
        'old_oj', v_oj,
        'old_problem_id', v_problem_id,
        'old_time_complexity', v_time_complexity,
        'old_space_complexity', v_space_complexity,
        'base_updated_at', v_current,
        'content', v_content
    );

    insert into public.tickets (
        user_id, title, type, priority, description, status, payload
    )
    values (
        v_uid,
        '元数据修改：' || coalesce(v_column_name, v_key),
        'edit',
        'mid',
        coalesce(nullif(btrim(coalesce(p_note, '')), ''), '元数据修改（标题 / 分类 / 难度 / 标签 / 关系 / 评分 / 复杂度）'),
        'pending',
        v_payload
    )
    returning id into v_ticket_id;

    return v_ticket_id;
end;
$$;

revoke all on function public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text, text, text, text, text, text) from public, anon;
grant execute on function public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text, text, text, text, text, text) to authenticated;

-- ---------- 5. 工单审批后写回新字段 ----------
create or replace function public.apply_meta_fields_from_ticket()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.type = 'edit'
       and new.status = 'approved'
       and old.status is distinct from 'approved'
       and (
           new.payload ? 'cf_rating'
           or new.payload ? 'oj'
           or new.payload ? 'problem_id'
           or new.payload ? 'time_complexity'
           or new.payload ? 'space_complexity'
       ) then
        update public.columns
        set cf_rating = case when new.payload ? 'cf_rating' then nullif(new.payload->>'cf_rating', '') else cf_rating end,
            oj = case when new.payload ? 'oj' then nullif(new.payload->>'oj', '') else oj end,
            problem_id = case when new.payload ? 'problem_id' then nullif(new.payload->>'problem_id', '') else problem_id end,
            time_complexity = case when new.payload ? 'time_complexity' then nullif(new.payload->>'time_complexity', '') else time_complexity end,
            space_complexity = case when new.payload ? 'space_complexity' then nullif(new.payload->>'space_complexity', '') else space_complexity end,
            meta_override = true,
            updated_at = now()
        where column_key = new.payload->>'column_key';
    end if;
    return new;
end;
$$;

drop trigger if exists trg_z_apply_meta_fields on public.tickets;
create trigger trg_z_apply_meta_fields
after update of status on public.tickets
for each row execute function public.apply_meta_fields_from_ticket();

-- ---------- 6. 贡献视图 ----------
create or replace view public.author_edit_credits
with (security_invoker = false)
as
select distinct on (t.user_id, c.column_key)
    coalesce(nullif(p.nickname, ''), 'unknown') as editor_name,
    c.column_key,
    c.column_name,
    c.category,
    c.kind,
    coalesce(t.payload->>'old_difficulty',
             t.payload->>'difficulty',
             c.difficulty) as difficulty,
    t.priority,
    coalesce(length(t.payload->>'old_content'), 0) as old_len,
    coalesce(length(t.payload->>'content'), 0) as new_len,
    (c.owner_id = t.user_id) as is_self_edit,
    coalesce(t.reviewed_at, t.updated_at) as reviewed_at
from public.tickets t
join public.profiles p on p.id = t.user_id
join public.columns c on c.column_key = t.payload->>'column_key'
where t.type = 'edit'
  and t.status = 'approved'
  and t.user_id is not null
  and nullif(t.payload->>'column_key', '') is not null
  and coalesce((t.payload->>'meta_only')::boolean, false) = false
  and c.status = 'published'
  and c.column_key not like 'sub-%'
order by t.user_id,
         c.column_key,
         coalesce(t.reviewed_at, t.updated_at) desc nulls last,
         t.id desc;

grant select on public.author_edit_credits to anon, authenticated;

drop view if exists public.author_meta_credits;
create view public.author_meta_credits
with (security_invoker = false)
as
select distinct on (t.user_id, c.column_key)
    coalesce(nullif(p.nickname, ''), 'unknown') as editor_name,
    c.column_key,
    c.column_name,
    c.category,
    c.kind,
    c.difficulty,
    t.priority,
    (c.owner_id = t.user_id) as is_self_edit,
    coalesce(t.reviewed_at, t.updated_at) as reviewed_at
from public.tickets t
join public.profiles p on p.id = t.user_id
join public.columns c on c.column_key = t.payload->>'column_key'
where t.type = 'edit'
  and t.status = 'approved'
  and t.user_id is not null
  and nullif(t.payload->>'column_key', '') is not null
  and coalesce((t.payload->>'meta_only')::boolean, false) = true
  and c.status = 'published'
order by t.user_id,
         c.column_key,
         coalesce(t.reviewed_at, t.updated_at) desc nulls last,
         t.id desc;

grant select on public.author_meta_credits to anon, authenticated;

comment on view public.author_meta_credits is
    '公开只读视图：审批通过的元数据便捷修改，按作者+专栏去重取最新；前端每条计 0.02 贡献';

notify pgrst, 'reload schema';

-- ---------- 自检 ----------
select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname in ('admin_update_column_meta', 'submit_column_meta_edit')
order by proname;

select column_name, data_type
from information_schema.columns
where table_schema='public' and table_name='columns'
  and column_name in ('cf_rating','oj','problem_id','time_complexity','space_complexity','meta_override')
order by column_name;
