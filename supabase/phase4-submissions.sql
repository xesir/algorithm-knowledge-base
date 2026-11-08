-- ============================================================
-- 第四阶段：专栏元数据、投稿工单与审批自动入库
-- 前置：已执行 phase2.sql、phase3-columns.sql
-- 在 Supabase SQL Editor 整段运行。
-- ============================================================

-- ---------- 投稿工单 payload ----------
alter table public.tickets add column if not exists payload jsonb;

-- ---------- 专栏元数据 ----------
alter table public.columns add column if not exists tags text[];
alter table public.columns add column if not exists category text;
alter table public.columns add column if not exists parent_key text;
alter table public.columns add column if not exists difficulty text;
alter table public.columns add column if not exists kind text not null default 'knowledge';
alter table public.columns add column if not exists status text not null default 'published';
alter table public.columns add column if not exists source_ticket_id bigint;

do $$
begin
    if not exists (
        select 1 from pg_constraint
        where conname = 'columns_kind_check'
          and conrelid = 'public.columns'::regclass
    ) then
        alter table public.columns
            add constraint columns_kind_check check (kind in ('knowledge', 'problem'));
    end if;
    if not exists (
        select 1 from pg_constraint
        where conname = 'columns_status_check'
          and conrelid = 'public.columns'::regclass
    ) then
        alter table public.columns
            add constraint columns_status_check check (status in ('pending', 'published', 'rejected'));
    end if;
end;
$$;

create unique index if not exists uq_columns_source_ticket
    on public.columns (source_ticket_id)
    where source_ticket_id is not null;

-- 公开只读已发布专栏；作者本人和管理员能看到全部状态
drop policy if exists columns_select_public on public.columns;
drop policy if exists columns_select_visible on public.columns;
create policy columns_select_visible on public.columns
for select using (
    status = 'published'
    or auth.uid() = owner_id
    or public.is_admin()
);

drop policy if exists columns_delete_owner on public.columns;
create policy columns_delete_owner on public.columns
for delete to authenticated
using (auth.uid() = owner_id);

-- 用户可以撤回自己待审批的投稿
drop policy if exists tickets_delete_own_pending on public.tickets;
create policy tickets_delete_own_pending on public.tickets
for delete to authenticated
using (
    auth.uid() = user_id
    and status = 'pending'
    and type = 'submission'
);

-- ---------- 工单通过后自动按原文写入 columns ----------
create or replace function public.publish_submission_ticket()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    p jsonb;
    v_tags text[];
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

        insert into public.columns (
            owner_id, column_key, column_name, description, content,
            tags, category, parent_key, difficulty, kind, status, source_ticket_id
        )
        values (
            new.user_id,
            'sub-' || new.id::text,
            coalesce(nullif(p->>'column_name', ''), new.title),
            nullif(p->>'description', ''),
            coalesce(p->>'content', ''),
            v_tags,
            nullif(p->>'category', ''),
            nullif(p->>'parent_key', ''),
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

-- ---------- 结果检查 ----------
select id, title, type, status, payload
from public.tickets
where type = 'submission'
order by id desc
limit 10;

select id, column_key, column_name, category, parent_key, difficulty, kind, status, source_ticket_id
from public.columns
order by id desc
limit 10;
