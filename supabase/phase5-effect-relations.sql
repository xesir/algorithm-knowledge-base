-- ============================================================
-- 第五阶段：投稿自动入库支持「作者 / 关系」，并完善自动效果
-- 前置：已执行 phase2.sql、phase3-columns.sql、phase4-submissions.sql
-- 在 Supabase SQL Editor 整段运行。
-- ============================================================

alter table public.columns add column if not exists relation_type text;
alter table public.columns add column if not exists relation_target text;

do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'columns_relation_type_check'
          and conrelid = 'public.columns'::regclass
    ) then
        alter table public.columns
            add constraint columns_relation_type_check
            check (
                relation_type is null
                or relation_type in ('related', 'sequence', 'parent-child')
            );
    end if;
end;
$$;

-- 通过投稿工单时：按 payload 里的 author_id / 关系 / 难度自动写入 columns
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
    v_relation text;
    v_relation_target text;
begin
    p := coalesce(new.payload, '{}'::jsonb);

    if new.status = 'approved'
       and old.status is distinct from 'approved'
       and new.type = 'submission' then

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

        v_relation := nullif(p->>'relation_type', '');
        if v_relation is not null
           and v_relation not in ('related', 'sequence', 'parent-child') then
            raise exception '未知的专栏关系类型：%', v_relation;
        end if;
        v_relation_target := nullif(p->>'relation_target', '');

        insert into public.columns (
            owner_id, column_key, column_name, description, content,
            tags, category, parent_key, relation_type, relation_target,
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
            case when v_relation = 'parent-child' then v_relation_target else null end,
            v_relation,
            v_relation_target,
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
            difficulty = excluded.difficulty,
            kind = excluded.kind,
            status = 'published',
            source_ticket_id = excluded.source_ticket_id,
            updated_at = now();
    end if;
    return new;
end;
$$;

drop trigger if exists trg_publish_submission on public.tickets;
create trigger trg_publish_submission
after update of status on public.tickets
for each row execute function public.publish_submission_ticket();

select id, column_key, column_name, owner_id, category, relation_type, relation_target,
       difficulty, kind, status, source_ticket_id
from public.columns
order by id desc
limit 10;
