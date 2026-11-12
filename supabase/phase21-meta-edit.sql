-- ============================================================
-- 第二十一阶段：专栏/题目元数据便捷修改
-- 前置：phase20 已执行（admin_publish_column / 防覆盖守卫）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. admin_update_column_meta(jsonb)：管理员直接改非正文元数据
--      （标题 / 分类 / 难度 / 标签 / 关系），必须带 expected_updated_at；
--   2. submit_column_meta_edit(...)：普通登录用户提交元数据修改工单，
--      payload 带当前正文快照 + base_updated_at，审批时正文不变、只改元数据；
--   3. 两个函数只授予 authenticated；管理员身份在函数内校验 profiles.role。
-- ============================================================

-- ---------- 1. 管理员直接修改元数据 ----------
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
    v_tags text[];
    v_relations jsonb := coalesce(p->'relations', '[]'::jsonb);
    v_first jsonb;
    v_first_type text;
    v_first_target text;
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

    select updated_at into v_current
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
        updated_at = now()
    where column_key = v_key;

    if v_tags is not null then
        insert into public.tags (name)
        select unnest(v_tags)
        on conflict (name) do nothing;
    end if;

    select updated_at into v_current from public.columns where column_key = v_key;
    return jsonb_build_object(
        'column_key', v_key,
        'updated_at', v_current,
        'mode', 'admin_meta'
    );
end;
$$;

revoke all on function public.admin_update_column_meta(jsonb) from public, anon;
grant execute on function public.admin_update_column_meta(jsonb) to authenticated;

-- ---------- 2. 普通用户提交元数据修改工单 ----------
create or replace function public.submit_column_meta_edit(
    p_key text,
    p_column_name text,
    p_category text,
    p_difficulty text,
    p_tags text[],
    p_relations jsonb,
    p_note text
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

    select updated_at, content, column_name, kind
    into v_current, v_content, v_column_name, v_kind
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
        coalesce(nullif(btrim(coalesce(p_note, '')), ''), '元数据修改（标题 / 分类 / 难度 / 标签 / 关系）'),
        'pending',
        v_payload
    )
    returning id into v_ticket_id;

    return v_ticket_id;
end;
$$;

revoke all on function public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text) from public, anon;
grant execute on function public.submit_column_meta_edit(text, text, text, text, text[], jsonb, text) to authenticated;

notify pgrst, 'reload schema';

-- ---------- 自检 ----------
select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname in ('admin_update_column_meta', 'submit_column_meta_edit')
order by proname;
