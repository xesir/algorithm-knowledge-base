-- ============================================================
-- 第二十阶段：后台上传 RPC + 防止工单/后台上传互相覆盖
-- 前置：phase19 已执行（publish_submission_ticket 为最新版本）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. tickets 增加 BEFORE UPDATE 守卫触发器：
--      - 修改工单审批时校验 payload.base_updated_at，目标专栏已被更新则拒绝；
--      - 已有专栏新增作者版本时，若该版本已存在则拒绝，不再覆盖。
--   2. 新增 public.admin_publish_column(jsonb)：
--      - 后台直传专用，不走工单；insert 模式拒绝覆盖已存在的 column_key；
--      - update 模式必须带 expected_updated_at，目标已被更新则拒绝；
--      - 字段、标签、关系、锁定语义与投稿/修改工单保持一致。
--   3. 函数只授予 postgres / service_role，匿名与登录用户不可调用。
-- ============================================================

-- ---------- 1. 工单审批防覆盖守卫 ----------
create or replace function public.guard_ticket_overwrite()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    p jsonb := coalesce(new.payload, '{}'::jsonb);
    v_key text;
    v_current timestamptz;
    v_base timestamptz;
    v_version_base text;
    v_version_key text;
    v_author uuid;
    v_author_name text;
begin
    if new.status = 'approved'
       and old.status is distinct from 'approved' then

        -- 修改工单：目标专栏在提交后被更新过，则拒绝覆盖
        if new.type = 'edit' then
            v_key := nullif(p->>'column_key', '');
            if v_key is null then
                return new; -- 交给主触发器报错
            end if;

            select updated_at into v_current
            from public.columns
            where column_key = v_key
            for update;

            if not found then
                return new; -- 交给主触发器报「目标专栏不存在」
            end if;

            if nullif(p->>'base_updated_at', '') is not null then
                begin
                    v_base := (p->>'base_updated_at')::timestamptz;
                exception when others then
                    raise exception '修改工单的 base_updated_at 格式不正确';
                end;
                if v_current > v_base then
                    raise exception '目标专栏在提交后已被更新（当前 % ，工单基于 % ），请重新载入后再提交修改',
                        v_current, v_base;
                end if;
            else
                raise notice '修改工单缺少 base_updated_at，按旧逻辑执行';
            end if;

        -- 投稿：新版本 / 新专栏
        elsif new.type = 'submission' then

            -- 已有专栏新增作者版本：该版本已存在则拒绝，避免覆盖
            if nullif(p->>'version_of', '') is not null then
                v_version_base := split_part(p->>'version_of', '--', 1);
                if v_version_base not like 'col-%' then
                    return new; -- 交给主触发器报错
                end if;

                begin
                    v_author := coalesce(nullif(p->>'author_id', '')::uuid, new.user_id);
                exception when others then
                    return new;
                end;

                select nullif(btrim(nickname), '')
                into v_author_name
                from public.profiles
                where id = v_author and status = 'active';

                if v_author_name is null then
                    return new; -- 交给主触发器报「作者不存在/未激活」
                end if;

                -- 锁住基础专栏，串行化同一专栏的版本投稿
                perform 1
                from public.columns
                where column_key = v_version_base
                for update;

                if not found then
                    return new; -- 交给主触发器报「目标专栏不存在」
                end if;

                v_version_key := v_version_base || '--' || v_author_name;
                if exists (
                    select 1 from public.columns where column_key = v_version_key
                ) then
                    raise exception '该作者在该专栏下已有版本（%），请改用修改工单', v_version_key;
                end if;
            else
                -- 新专栏：sub-<ticket_id> 若已被其他来源占用，拒绝覆盖
                v_key := 'sub-' || new.id::text;
                if exists (
                    select 1
                    from public.columns
                    where column_key = v_key
                      and source_ticket_id is distinct from new.id
                ) then
                    raise exception '专栏键 % 已被其他来源占用，拒绝覆盖', v_key;
                end if;
            end if;
        end if;
    end if;

    return new;
end;
$$;

drop trigger if exists trg_guard_ticket_overwrite on public.tickets;
create trigger trg_guard_ticket_overwrite
before update on public.tickets
for each row
execute function public.guard_ticket_overwrite();

-- ---------- 2. 后台上传 RPC ----------
create or replace function public.admin_publish_column(p jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_mode text := coalesce(nullif(btrim(p->>'mode'), ''), 'insert');
    v_key text := nullif(btrim(coalesce(p->>'column_key', '')), '');
    v_author uuid;
    v_tags text[];
    v_relations jsonb := coalesce(p->'relations', '[]'::jsonb);
    v_first jsonb;
    v_first_type text;
    v_first_target text;
    v_expected timestamptz;
    v_current timestamptz;
    v_rows int;
begin
    if v_key is null then
        raise exception 'column_key 不能为空';
    end if;
    if nullif(p->>'content', '') is null then
        raise exception 'content 不能为空';
    end if;

    -- 作者：优先 author_id，其次 author_name；必须 active
    if nullif(p->>'author_id', '') is not null then
        begin
            v_author := (p->>'author_id')::uuid;
        exception when others then
            raise exception 'author_id 格式不正确';
        end;
    elsif nullif(p->>'author_name', '') is not null then
        select id into v_author
        from public.profiles
        where nickname = p->>'author_name' and status = 'active'
        limit 1;
        if not found then
            raise exception '作者不存在或未激活：%', p->>'author_name';
        end if;
    else
        raise exception '必须提供 author_id 或 author_name';
    end if;

    if not exists (
        select 1 from public.profiles where id = v_author and status = 'active'
    ) then
        raise exception '作者不存在或未激活';
    end if;

    if jsonb_typeof(p->'tags') = 'array' then
        select coalesce(array_agg(value), array[]::text[])
        into v_tags
        from jsonb_array_elements_text(p->'tags');
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

    v_first := v_relations->0;
    v_first_type := nullif(v_first->>'type', '');
    v_first_target := nullif(v_first->>'target', '');

    if v_mode = 'insert' then
        insert into public.columns (
            owner_id, column_key, column_name, description, content,
            tags, category, parent_key, relation_type, relation_target, relations, relations_override,
            difficulty, kind, status, source_ticket_id
        )
        values (
            v_author,
            v_key,
            coalesce(nullif(p->>'column_name', ''), v_key),
            nullif(p->>'description', ''),
            p->>'content',
            v_tags,
            nullif(p->>'category', ''),
            coalesce(nullif(p->>'parent_key', ''),
                     case when v_first_type = 'parent-child' then v_first_target else null end),
            v_first_type,
            v_first_target,
            v_relations,
            coalesce((p->>'relations_override')::boolean, false),
            nullif(p->>'difficulty', ''),
            coalesce(nullif(p->>'kind', ''), 'knowledge'),
            'published',
            null
        )
        on conflict (column_key) do nothing;

        get diagnostics v_rows = row_count;
        if v_rows = 0 then
            raise exception 'column_key 已存在（%），拒绝覆盖；如需修改请用 mode=update 并带 expected_updated_at', v_key;
        end if;

    elsif v_mode = 'update' then
        select updated_at into v_current
        from public.columns
        where column_key = v_key
        for update;

        if not found then
            raise exception '目标专栏不存在：%', v_key;
        end if;

        if nullif(p->>'expected_updated_at', '') is null then
            raise exception 'update 模式必须提供 expected_updated_at，防止覆盖他人更新';
        end if;
        begin
            v_expected := (p->>'expected_updated_at')::timestamptz;
        exception when others then
            raise exception 'expected_updated_at 格式不正确';
        end;
        if v_current > v_expected then
            raise exception '目标专栏已被更新（当前 % ，期望 % ），拒绝覆盖；请重新读取后再试',
                v_current, v_expected;
        end if;

        update public.columns
        set column_name = coalesce(nullif(p->>'column_name', ''), column_name),
            description = case when p ? 'description' then nullif(p->>'description', '') else description end,
            content = p->>'content',
            tags = case when jsonb_typeof(p->'tags') = 'array' then v_tags else tags end,
            category = coalesce(nullif(p->>'category', ''), category),
            parent_key = case
                when p ? 'parent_key' then nullif(p->>'parent_key', '')
                when p ? 'relations' then (
                    select nullif(r->>'target', '')
                    from jsonb_array_elements(v_relations) as r
                    where r->>'type' = 'parent-child'
                    limit 1
                )
                else parent_key
            end,
            relation_type = case when p ? 'relations' then v_first_type else relation_type end,
            relation_target = case when p ? 'relations' then v_first_target else relation_target end,
            relations = case when p ? 'relations' then v_relations else relations end,
            relations_override = case
                when p ? 'relations' then coalesce((p->>'relations_override')::boolean, true)
                else relations_override
            end,
            difficulty = case when p ? 'difficulty' then nullif(p->>'difficulty', '') else difficulty end,
            kind = case when p ? 'kind' then coalesce(nullif(p->>'kind', ''), kind) else kind end,
            status = 'published',
            updated_at = now()
        where column_key = v_key;

        if not found then
            raise exception '目标专栏不存在：%', v_key;
        end if;
    else
        raise exception 'mode 只能是 insert 或 update';
    end if;

    if v_tags is not null then
        insert into public.tags (name)
        select unnest(v_tags)
        on conflict (name) do nothing;
    end if;

    select updated_at into v_current from public.columns where column_key = v_key;
    return jsonb_build_object(
        'column_key', v_key,
        'mode', v_mode,
        'updated_at', v_current
    );
end;
$$;

revoke all on function public.admin_publish_column(jsonb) from public, anon, authenticated;
grant execute on function public.admin_publish_column(jsonb) to postgres;

do $$
begin
    if exists (select 1 from pg_roles where rolname = 'service_role') then
        grant execute on function public.admin_publish_column(jsonb) to service_role;
    end if;
end;
$$;

comment on function public.admin_publish_column(jsonb) is
    '后台上传专用：insert 拒绝覆盖已有 column_key；update 必须带 expected_updated_at；与投稿/修改工单字段语义一致';

-- ---------- 3. 自检 ----------
select tgname, tgenabled
from pg_trigger
where tgrelid = 'public.tickets'::regclass
  and tgname = 'trg_guard_ticket_overwrite';

select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname = 'admin_publish_column';
