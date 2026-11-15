-- ============================================================
-- 第二十四阶段：工单结果通知 + 静态条目也能作为「新作者版本」基底
-- 前置：phase19（publish_submission_ticket 含关系写回）、
--       phase20（guard_ticket_overwrite 防覆盖守卫）、
--       phase23（notifications 表）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. 工单审批结束后通知提交者：
--      - 投稿通过 / 投稿驳回（kind = submission_approved / submission_rejected）
--      - 修改通过 / 修改驳回（kind = edit_approved / edit_rejected）
--      - 驳回时若管理员填了 tickets.admin_note，会附在通知正文里
--   2. 为已有专栏添加新作者版本时，若目标 base 专栏尚未写入 columns
--      （例如 catalog.json 里的静态知识点 / 题目还没 seed），
--      允许用 payload 自带的标题 / 分类 / 题型 / 难度 / 标签 / 关系作为继承值；
--   3. 防覆盖守卫：即使 base 专栏不存在，也检查该作者版本是否已存在，避免重复覆盖。
--
-- 说明：
--   - 「修改」工单**提交时**通知专栏作者仍由 phase23 的 notify_edit_ticket_owner 负责；
--     本文件只负责审批结果通知，两者不重复。
--   - notifications 表默认只授予 read_at 的 update 权限，本文件不改授权。
-- ============================================================

-- ---------- 1. 工单审批结果 → 通知提交者 ----------
create or replace function public.notify_ticket_result()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    p jsonb := coalesce(new.payload, '{}'::jsonb);
    v_base_key text;
    v_base_id text;
    v_target_key text;
    v_author uuid;
    v_author_name text;
    v_column_name text;
    v_title text;
    v_link text;
    v_kind text;
    v_notify_title text;
    v_body text;
    v_note text;
    v_is_version boolean := false;
begin
    if old.status is not distinct from new.status then
        return new;
    end if;
    if new.status not in ('approved', 'rejected') then
        return new;
    end if;
    if new.user_id is null then
        return new;
    end if;
    if new.type not in ('submission', 'edit') then
        return new;
    end if;

    v_note := nullif(btrim(coalesce(new.admin_note, '')), '');

    if new.type = 'submission' then
        v_base_key := nullif(btrim(coalesce(p->>'version_of', '')), '');
        if v_base_key is not null then
            v_is_version := true;
            v_base_key := split_part(v_base_key, '--', 1);
            v_base_id := case when v_base_key like 'col-%' then substr(v_base_key, 5) else v_base_key end;

            begin
                v_author := coalesce(nullif(p->>'author_id', '')::uuid, new.user_id);
            exception when others then
                v_author := new.user_id;
            end;

            select nullif(btrim(nickname), '')
            into v_author_name
            from public.profiles
            where id = v_author;

            select c.column_name
            into v_column_name
            from public.columns c
            where c.column_key = case
                when v_author_name is null then v_base_key
                else v_base_key || '--' || v_author_name
            end;

            v_title := coalesce(
                nullif(v_column_name, ''),
                nullif(btrim(coalesce(p->>'column_name', '')), ''),
                v_base_key
            );
        else
            v_title := coalesce(nullif(btrim(coalesce(p->>'column_name', '')), ''), new.title);
        end if;
    else
        v_target_key := nullif(btrim(coalesce(p->>'column_key', '')), '');
        if v_target_key like 'col-%' then
            v_base_id := substr(split_part(v_target_key, '--', 1), 5);
        end if;

        select c.column_name
        into v_column_name
        from public.columns c
        where c.column_key = v_target_key;

        v_title := coalesce(
            nullif(btrim(coalesce(p->>'column_name', '')), ''),
            nullif(v_column_name, ''),
            new.title
        );
    end if;

    if new.status = 'approved' then
        if new.type = 'submission' then
            v_kind := 'submission_approved';
            if v_is_version then
                v_notify_title := '投稿已通过（新作者版本）';
                v_body := '《' || v_title || '》已通过审批，你的作者版本已加入站点，点击查看。';
                v_link := 'index.html#' || v_base_id;
            else
                v_notify_title := '投稿已通过';
                v_body := '《' || v_title || '》已通过审批并入库，点击查看。';
                v_link := 'index.html#sub-' || new.id::text;
            end if;
        else
            v_kind := 'edit_approved';
            v_notify_title := '修改已通过';
            v_body := '你对《' || v_title || '》的修改已通过审批并生效，点击查看。';
            v_link := case
                when v_base_id is not null and v_base_id <> '' then 'index.html#' || v_base_id
                else 'admin.html?tab=profile'
            end;
        end if;
    else
        v_kind := case when new.type = 'submission' then 'submission_rejected' else 'edit_rejected' end;
        v_notify_title := case when new.type = 'submission' then '投稿未通过' else '修改未通过' end;
        v_body := case
            when new.type = 'submission' then
                '《' || v_title || '》未通过审批，可在「我的工单」查看状态，修改后重新投稿。'
            else
                '你对《' || v_title || '》的修改未通过审批，原专栏保持不变，可在「我的工单」查看状态。'
        end;
        v_link := 'admin.html?tab=profile';
    end if;

    if v_note is not null then
        v_body := v_body || ' 审核备注：' || v_note;
    end if;

    insert into public.notifications (user_id, kind, title, body, link, ticket_id)
    values (new.user_id, v_kind, v_notify_title, v_body, v_link, new.id);

    return new;
end;
$$;

drop trigger if exists trg_zz_notify_submission_approved on public.tickets;
drop trigger if exists trg_zz_notify_ticket_result on public.tickets;
create trigger trg_zz_notify_ticket_result
after update of status on public.tickets
for each row execute function public.notify_ticket_result();

-- 早期版本的函数已不再使用
drop function if exists public.notify_submission_approved();

-- ---------- 2. 防覆盖守卫：base 不存在时也检查重复作者版本 ----------
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
                    return new; -- 交给主触发器报「作者不存在/未激活」
                end;

                select nullif(btrim(nickname), '')
                into v_author_name
                from public.profiles
                where id = v_author and status = 'active';

                if v_author_name is null then
                    return new; -- 交给主触发器报「作者不存在/未激活」
                end if;

                -- base 专栏若已入库，锁住它串行化同一专栏的版本投稿；
                -- 静态条目（尚未 seed 到 columns）允许继续，但同样要查重。
                perform 1
                from public.columns
                where column_key = v_version_base
                for update;

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
before update of status on public.tickets
for each row execute function public.guard_ticket_overwrite();

-- ---------- 3. 审批触发器：新作者版本支持静态条目基底 ----------
create or replace function public.publish_submission_ticket()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    p jsonb;
    v_tags text[];
    v_author uuid;
    v_relations jsonb := '[]'::jsonb;
    v_first jsonb;
    v_first_type text;
    v_first_target text;
    v_edit_key text;
    v_edit_tags text[];
    v_edit_relations jsonb;
    v_edit_first jsonb;
    v_edit_first_type text;
    v_edit_first_target text;
    v_version_of text;
    v_version_base text;
    v_version_key text;
    v_version_found boolean := false;
    v_version_relations jsonb := '[]'::jsonb;
    v_version_parent text;
    v_payload_relations jsonb;
    v_base public.columns%rowtype;
    v_base_title text;
    v_author_name text;
begin
    p := coalesce(new.payload, '{}'::jsonb);

    if new.status = 'approved'
       and old.status is distinct from 'approved' then

        -- ===== 投稿：新建专栏 / 已有专栏新增作者版本 =====
        if new.type = 'submission' then

            if jsonb_typeof(p->'tags') = 'array' then
                select array_agg(value) into v_tags
                from jsonb_array_elements_text(p->'tags');
            end if;

            if nullif(p->>'content', '') is null then
                raise exception '投稿内容为空，无法入库';
            end if;

            v_version_of := nullif(btrim(coalesce(p->>'version_of', '')), '');
            if v_version_of is null and nullif(p->>'category', '') is null then
                raise exception '投稿缺少从属大类，无法入库';
            end if;

            begin
                v_author := coalesce(nullif(p->>'author_id', '')::uuid, new.user_id);
            exception when invalid_text_representation then
                raise exception '投稿作者 id 格式不正确';
            end;

            if not exists (
                select 1 from public.profiles
                where id = v_author and status = 'active'
            ) then
                raise exception '投稿作者不存在或未激活';
            end if;

            -- ===== 已有专栏：新增作者版本 =====
            if v_version_of is not null then
                v_version_base := split_part(v_version_of, '--', 1);
                if v_version_base not like 'col-%' then
                    raise exception '只能向已有知识点/题目专栏添加版本';
                end if;

                select * into v_base
                from public.columns
                where column_key = v_version_base;
                v_version_found := found;

                if not v_version_found then
                    select * into v_base
                    from public.columns
                    where column_key like v_version_base || '--%'
                    order by column_key
                    limit 1;
                    v_version_found := found;
                end if;

                -- 静态条目（catalog.json 里有、但 columns 还没 seed）：
                -- 用 payload 的标题/分类/题型/难度/标签/关系作为继承值。
                if v_version_found then
                    v_base_title := coalesce(nullif(v_base.column_name, ''), '未命名专栏');
                    if position(' · ' in v_base_title) > 0 then
                        v_base_title := split_part(v_base_title, ' · ', 1);
                    end if;
                else
                    v_base_title := coalesce(
                        nullif(btrim(coalesce(p->>'base_title', '')), ''),
                        nullif(btrim(coalesce(p->>'column_name', '')), ''),
                        nullif(substr(v_version_base, 5), '')
                    );
                    if v_base_title is null or btrim(v_base_title) = '' then
                        raise exception '目标专栏不存在，无法添加版本';
                    end if;
                end if;

                select coalesce(nullif(btrim(nickname), ''), v_author::text)
                into v_author_name
                from public.profiles
                where id = v_author and status = 'active';

                if v_author_name is null then
                    raise exception '投稿作者不存在或未激活';
                end if;

                if v_tags is null or cardinality(v_tags) = 0 then
                    v_tags := v_base.tags;
                end if;

                -- 关系继承：base 已人工覆盖则以其为准；否则用 base 关系，其次 payload
                if jsonb_typeof(p->'relations') = 'array' then
                    v_payload_relations := p->'relations';
                    if exists (
                        select 1
                        from jsonb_array_elements(v_payload_relations) as r
                        where coalesce(r->>'type', '') not in ('related', 'sequence', 'parent-child')
                           or nullif(r->>'target', '') is null
                    ) then
                        raise exception '每条关系都必须包含类型和关联目标';
                    end if;
                end if;

                if v_version_found and v_base.relations_override is true then
                    v_version_relations := coalesce(v_base.relations, '[]'::jsonb);
                elsif jsonb_array_length(coalesce(v_base.relations, '[]'::jsonb)) > 0 then
                    v_version_relations := v_base.relations;
                else
                    v_version_relations := coalesce(v_payload_relations, '[]'::jsonb);
                end if;

                v_version_parent := coalesce(
                    v_base.parent_key,
                    (
                        select nullif(r->>'target', '')
                        from jsonb_array_elements(v_version_relations) as r
                        where r->>'type' = 'parent-child'
                        limit 1
                    )
                );

                v_version_key := v_version_base || '--' || v_author_name;

                insert into public.columns (
                    owner_id, column_key, column_name, description, content,
                    tags, category, parent_key, relation_type, relation_target, relations, relations_override,
                    difficulty, kind, status, source_ticket_id
                )
                values (
                    v_author,
                    v_version_key,
                    v_base_title || ' · ' || v_author_name,
                    null,
                    coalesce(p->>'content', ''),
                    v_tags,
                    coalesce(v_base.category, nullif(p->>'category', '')),
                    v_version_parent,
                    v_base.relation_type,
                    v_base.relation_target,
                    v_version_relations,
                    case when v_version_found then v_base.relations_override else true end,
                    coalesce(v_base.difficulty, nullif(p->>'difficulty', '')),
                    coalesce(v_base.kind, nullif(p->>'kind', ''), 'knowledge'),
                    'published',
                    new.id
                )
                on conflict (column_key) do update
                set owner_id = excluded.owner_id,
                    column_name = excluded.column_name,
                    content = excluded.content,
                    tags = excluded.tags,
                    category = excluded.category,
                    parent_key = excluded.parent_key,
                    relation_type = excluded.relation_type,
                    relation_target = excluded.relation_target,
                    relations = excluded.relations,
                    relations_override = excluded.relations_override,
                    difficulty = excluded.difficulty,
                    kind = excluded.kind,
                    status = 'published',
                    updated_at = now();

                if v_tags is not null then
                    insert into public.tags (name)
                    select unnest(v_tags)
                    on conflict (name) do nothing;
                end if;

                return new;
            end if;

            -- ===== 新建专栏：原有逻辑 =====
            if jsonb_typeof(p->'relations') = 'array' then
                v_relations := p->'relations';
                if exists (
                    select 1
                    from jsonb_array_elements(v_relations) as r
                    where coalesce(r->>'type', '') not in ('related', 'sequence', 'parent-child')
                       or nullif(r->>'target', '') is null
                ) then
                    raise exception '每条关系都必须包含类型和关联目标';
                end if;
            end if;

            v_first := v_relations->0;
            v_first_type := nullif(v_first->>'type', '');
            v_first_target := nullif(v_first->>'target', '');

            insert into public.columns (
                owner_id, column_key, column_name, description, content,
                tags, category, parent_key, relation_type, relation_target, relations, relations_override,
                difficulty, kind, status, source_ticket_id
            )
            values (
                v_author,
                'sub-' || new.id::text,
                coalesce(nullif(p->>'column_name', ''), new.title),
                nullif(p->>'description', ''),
                coalesce(p->>'content', ''),
                v_tags,
                nullif(p->>'category', ''),
                case when v_first_type = 'parent-child' then v_first_target else null end,
                v_first_type,
                v_first_target,
                v_relations,
                true,
                nullif(p->>'difficulty', ''),
                coalesce(nullif(p->>'kind', ''), 'knowledge'),
                'published',
                new.id
            )
            on conflict (column_key) do update
            set owner_id = excluded.owner_id,
                column_name = excluded.column_name,
                description = excluded.description,
                content = excluded.content,
                tags = excluded.tags,
                category = excluded.category,
                parent_key = excluded.parent_key,
                relation_type = excluded.relation_type,
                relation_target = excluded.relation_target,
                relations = excluded.relations,
                relations_override = excluded.relations_override,
                difficulty = excluded.difficulty,
                kind = excluded.kind,
                status = 'published',
                source_ticket_id = excluded.source_ticket_id,
                updated_at = now();

            if v_tags is not null then
                insert into public.tags (name)
                select unnest(v_tags)
                on conflict (name) do nothing;
            end if;

        -- ===== 修改：把正文、标题、元数据与关系写回目标专栏 =====
        elsif new.type = 'edit' then

            v_edit_key := nullif(p->>'column_key', '');
            if v_edit_key is null then
                raise exception '修改工单缺少目标专栏，无法生效';
            end if;
            if nullif(p->>'content', '') is null then
                raise exception '修改内容为空，无法生效';
            end if;

            if jsonb_typeof(p->'tags') = 'array' then
                select coalesce(array_agg(value), array[]::text[])
                into v_edit_tags
                from jsonb_array_elements_text(p->'tags');
            end if;

            if p ? 'relations' then
                if jsonb_typeof(p->'relations') <> 'array' then
                    raise exception '关系格式不正确';
                end if;
                v_edit_relations := p->'relations';
                if exists (
                    select 1
                    from jsonb_array_elements(v_edit_relations) as r
                    where coalesce(r->>'type', '') not in ('related', 'sequence', 'parent-child')
                       or nullif(r->>'target', '') is null
                ) then
                    raise exception '每条关系都必须包含类型和关联目标';
                end if;
                v_edit_first := v_edit_relations->0;
                v_edit_first_type := nullif(v_edit_first->>'type', '');
                v_edit_first_target := nullif(v_edit_first->>'target', '');
            end if;

            update public.columns
            set content = p->>'content',
                column_name = coalesce(nullif(p->>'column_name', ''), column_name),
                tags = case when jsonb_typeof(p->'tags') = 'array' then v_edit_tags else tags end,
                category = coalesce(nullif(p->>'category', ''), category),
                difficulty = case when p ? 'difficulty' then nullif(p->>'difficulty', '') else difficulty end,
                relation_type = case when p ? 'relations' then v_edit_first_type else relation_type end,
                relation_target = case when p ? 'relations' then v_edit_first_target else relation_target end,
                parent_key = case
                    when p ? 'relations' then (
                        select nullif(r->>'target', '')
                        from jsonb_array_elements(v_edit_relations) as r
                        where r->>'type' = 'parent-child'
                        limit 1
                    )
                    else parent_key
                end,
                relations = case when p ? 'relations' then v_edit_relations else relations end,
                relations_override = case when p ? 'relations' then true else relations_override end,
                updated_at = now()
            where column_key = v_edit_key;

            if not found then
                raise exception '目标专栏不存在，无法应用修改';
            end if;

            if v_edit_tags is not null then
                insert into public.tags (name)
                select unnest(v_edit_tags)
                on conflict (name) do nothing;
            end if;
        end if;
    end if;

    return new;
end;
$$;

drop trigger if exists trg_publish_submission on public.tickets;
create trigger trg_publish_submission
after update of status on public.tickets
for each row execute function public.publish_submission_ticket();

notify pgrst, 'reload schema';

-- ---------- 自检 ----------
select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname in ('notify_ticket_result', 'guard_ticket_overwrite', 'publish_submission_ticket')
order by proname;

select tgname, tgenabled
from pg_trigger
where tgrelid = 'public.tickets'::regclass
  and not tgisinternal
order by tgname;
