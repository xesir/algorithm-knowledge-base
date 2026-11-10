-- ============================================================
-- 第十九阶段：修改工单支持调整「与其他知识点的关系」
-- 前置：phase10 → phase11 → phase17 → phase18 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. columns 增加 relations_override（标记关系是否被人工覆盖）；
--      published_columns 视图增加 relations / relations_override，供前端同步星图；
--   2. submit_column_edit 增加 p_relations（第 10 个参数），payload 记录
--      relations / old_relations，并同步首条关系到旧字段；
--   3. 审批「修改」工单时把 relations / relation_type / relation_target /
--      parent_key / relations_override 一起写回 columns。
-- ============================================================

-- ---------- 1. columns：关系覆盖标记 + 公开视图 ----------
alter table public.columns
    add column if not exists relations_override boolean not null default false;

drop view if exists public.published_columns;

create view public.published_columns
with (security_invoker = false)
as
select
    c.column_key,
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
    (coalesce(s.password_hash, d.password_hash) is not null) as locked
from public.columns c
left join public.profiles p on p.id = c.owner_id
left join public.column_locks s
    on s.column_key = c.column_key and s.is_default = false
left join public.column_locks d
    on d.user_id = c.owner_id and d.is_default = true
where c.status = 'published'
  and (c.column_key like 'col-%' or c.column_key like 'sub-%');

grant select on public.published_columns to anon, authenticated;

comment on view public.published_columns is
    '公开只读视图：已发布专栏 + 作者昵称 + 是否设置访问密码 + 关系，供静态站前端增量覆盖正文/关系与游客访问控制';

-- ---------- 2. 修改工单：支持关系 ----------
drop function if exists public.submit_column_edit(text, text, text, text);
drop function if exists public.submit_column_edit(text, text, text, text, boolean, text[], text, text);
drop function if exists public.submit_column_edit(text, text, text, text, boolean, text[], text, text, text);

create or replace function public.submit_column_edit(
    p_key text,
    p_password text,
    p_content text,
    p_note text default null,
    p_uploaded boolean default false,
    p_tags text[] default null,
    p_category text default null,
    p_difficulty text default null,
    p_column_name text default null,
    p_relations jsonb default null
)
returns bigint
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_user uuid := auth.uid();
    v_column public.columns%rowtype;
    v_profile public.profiles%rowtype;
    v_contact text;
    v_ticket_id bigint;
    v_payload jsonb;
    v_tags text[];
    v_name text;
    v_relations jsonb;
    v_first jsonb;
    v_first_type text;
    v_first_target text;
begin
    if v_user is null then
        raise exception '请先登录后再提交修改';
    end if;

    if nullif(btrim(coalesce(p_key, '')), '') is null then
        raise exception '请选择要修改的专栏';
    end if;

    select *
    into v_column
    from public.columns
    where column_key = p_key;

    if not found then
        raise exception '专栏不存在或无权访问';
    end if;

    if not public.verify_column_password(p_key, coalesce(p_password, '')) then
        raise exception '专栏密码不正确';
    end if;

    if nullif(btrim(coalesce(p_content, '')), '') is null then
        raise exception '修改后的内容不能为空';
    end if;

    v_name := coalesce(nullif(btrim(coalesce(p_column_name, '')), ''), v_column.column_name);

    if p_tags is not null then
        select array_agg(distinct btrim(t))
        into v_tags
        from unnest(p_tags) as t
        where btrim(t) <> '';
        if v_tags is null then
            v_tags := '{}'::text[];
        end if;
    end if;

    -- 关系：null 表示不修改；[] 表示清空
    if p_relations is not null then
        if jsonb_typeof(p_relations) <> 'array' then
            raise exception '关系格式不正确';
        end if;
        v_relations := p_relations;
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
    end if;

    select *
    into v_profile
    from public.profiles
    where id = v_user;

    v_contact := nullif(concat_ws(
        ' / ',
        nullif(v_profile.contact, ''),
        case when nullif(v_profile.qq, '') is not null then 'QQ: ' || v_profile.qq end,
        case when nullif(v_profile.luogu, '') is not null then '洛谷: ' || v_profile.luogu end,
        case when nullif(v_profile.cf, '') is not null then 'CF: ' || v_profile.cf end
    ), '');

    v_payload := jsonb_build_object(
        'column_key', v_column.column_key,
        'column_name', v_name,
        'old_column_name', v_column.column_name,
        'kind', coalesce(
            v_column.kind,
            case
                when split_part(v_column.column_key, '--', 1) like 'col-prob-%' then 'problem'
                else v_column.kind
            end
        ),
        'category', coalesce(nullif(btrim(p_category), ''), v_column.category),
        'old_category', v_column.category,
        'tags', case when p_tags is null then to_jsonb(v_column.tags) else to_jsonb(v_tags) end,
        'old_tags', to_jsonb(v_column.tags),
        'difficulty', case when p_difficulty is null then v_column.difficulty else nullif(btrim(p_difficulty), '') end,
        'old_difficulty', v_column.difficulty,
        'relations', case when p_relations is null then coalesce(v_column.relations, '[]'::jsonb) else v_relations end,
        'old_relations', coalesce(v_column.relations, '[]'::jsonb),
        'relation_type', case when p_relations is null then v_column.relation_type else v_first_type end,
        'relation_target', case when p_relations is null then v_column.relation_target else v_first_target end,
        'parent_key', case
            when p_relations is null then v_column.parent_key
            else (
                select nullif(r->>'target', '')
                from jsonb_array_elements(v_relations) as r
                where r->>'type' = 'parent-child'
                limit 1
            )
        end,
        'old_content', coalesce(v_column.content, ''),
        'content', p_content,
        'note', nullif(btrim(coalesce(p_note, '')), ''),
        'base_updated_at', v_column.updated_at,
        'uploaded', coalesce(p_uploaded, false)
    );

    insert into public.tickets (
        user_id, title, type, priority, description, contact, status, payload
    )
    values (
        v_user,
        '修改：' || v_name,
        'edit',
        'mid',
        '修改专栏 · ' || coalesce(nullif(p_category, ''), nullif(v_column.category, ''), '未分类'),
        v_contact,
        'pending',
        v_payload
    )
    returning id into v_ticket_id;

    return v_ticket_id;
end;
$$;

revoke all on function public.submit_column_edit(text, text, text, text, boolean, text[], text, text, text, jsonb) from public, anon;
grant execute on function public.submit_column_edit(text, text, text, text, boolean, text[], text, text, text, jsonb) to authenticated;

-- ---------- 3. 审批触发器：修改工单写回关系 ----------
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

                if not found then
                    select * into v_base
                    from public.columns
                    where column_key like v_version_base || '--%'
                    order by column_key
                    limit 1;
                end if;

                if not found then
                    raise exception '目标专栏不存在，无法添加版本';
                end if;

                v_base_title := coalesce(nullif(v_base.column_name, ''), '未命名专栏');
                if position(' · ' in v_base_title) > 0 then
                    v_base_title := split_part(v_base_title, ' · ', 1);
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
                    v_base.parent_key,
                    v_base.relation_type,
                    v_base.relation_target,
                    v_base.relations,
                    v_base.relations_override,
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
where proname = 'submit_column_edit';

select column_key, column_name, relations
from public.published_columns
where relations is not null and jsonb_array_length(relations) > 0
order by updated_at desc
limit 10;
