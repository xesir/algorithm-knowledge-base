-- ============================================================
-- 第十一阶段：「修改」工单支持改专栏标题
-- 前置：phase10 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. submit_column_edit 增加 p_column_name（第 9 个参数）；
--   2. payload 记录 column_name（新标题）与 old_column_name；
--   3. 审批「修改」工单时把 column_name 一起写回 columns。
-- ============================================================

drop function if exists public.submit_column_edit(text, text, text, text, boolean, text[], text, text);

create or replace function public.submit_column_edit(
    p_key text,
    p_password text,
    p_content text,
    p_note text default null,
    p_uploaded boolean default false,
    p_tags text[] default null,
    p_category text default null,
    p_difficulty text default null,
    p_column_name text default null
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
        'kind', v_column.kind,
        'category', coalesce(nullif(btrim(p_category), ''), v_column.category),
        'old_category', v_column.category,
        'tags', case when p_tags is null then to_jsonb(v_column.tags) else to_jsonb(v_tags) end,
        'old_tags', to_jsonb(v_column.tags),
        'difficulty', case when p_difficulty is null then v_column.difficulty else nullif(btrim(p_difficulty), '') end,
        'old_difficulty', v_column.difficulty,
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

revoke all on function public.submit_column_edit(text, text, text, text, boolean, text[], text, text, text) from public, anon;
grant execute on function public.submit_column_edit(text, text, text, text, boolean, text[], text, text, text) to authenticated;

-- ---------- 审批触发器：修改工单写回正文 + 元数据 + 标题 ----------
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
begin
    p := coalesce(new.payload, '{}'::jsonb);

    if new.status = 'approved'
       and old.status is distinct from 'approved' then

        -- ===== 投稿：新建/覆盖专栏 =====
        if new.type = 'submission' then

            if jsonb_typeof(p->'tags') = 'array' then
                select array_agg(value) into v_tags
                from jsonb_array_elements_text(p->'tags');
            end if;

            if nullif(p->>'content', '') is null then
                raise exception '投稿内容为空，无法入库';
            end if;
            if nullif(p->>'category', '') is null then
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
                tags, category, parent_key, relation_type, relation_target, relations,
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

        -- ===== 修改：把正文、标题与元数据写回目标专栏 =====
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

            update public.columns
            set content = p->>'content',
                column_name = coalesce(nullif(p->>'column_name', ''), column_name),
                tags = case when jsonb_typeof(p->'tags') = 'array' then v_edit_tags else tags end,
                category = coalesce(nullif(p->>'category', ''), category),
                difficulty = case when p ? 'difficulty' then nullif(p->>'difficulty', '') else difficulty end,
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

-- ---------- 自检 ----------
select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where proname = 'submit_column_edit';

select count(*) as published_column_count from public.published_columns;
