-- ============================================================
-- 第十七阶段：向已有专栏投稿「新作者版本」
-- 前置：phase11 已执行（本文件会重建 publish_submission_ticket）
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. 投稿工单 payload 可带 version_of（目标专栏 base key，如 col-xxx）；
--   2. 审批通过后新增 col-<base>--<作者昵称> 行，不覆盖原专栏；
--   3. 普通新建投稿与修改工单逻辑保持不变。
-- ============================================================

create index if not exists idx_columns_version_base
on public.columns ((split_part(column_key, '--', 1)));

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
                    tags, category, parent_key, relation_type, relation_target, relations,
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
where proname = 'publish_submission_ticket';

select column_key, column_name, owner_id, source_ticket_id
from public.columns
where column_key like 'col-%--%'
order by id desc
limit 10;
