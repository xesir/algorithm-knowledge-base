-- ============================================================
-- 第十四阶段：作者贡献度 · 审批通过的修改工单公开视图
-- 前置：phase2 ~ phase13 已执行
-- 在 Supabase SQL Editor 整段执行，可重复执行。
--
-- 变更：
--   1. tickets 增加 reviewed_at，并在状态变为 approved / rejected 时自动写入；
--   2. 回填历史 approved / rejected 工单的 reviewed_at = updated_at；
--   3. 为「修改」工单的贡献查询增加局部索引；
--   4. 新建公开只读视图 author_edit_credits：
--      - 只包含 type='edit' 且 status='approved' 的工单；
--      - 按 (user_id, column_key) 去重，只保留 reviewed_at 最新的一条；
--      - 排除 sub-* 未同步投稿（等静态入库后再计入）；
--      - 只暴露算分与展示所需字段，不暴露正文、密码、联系方式。
-- ============================================================

-- ---------- 1. 审批时间：reviewed_at ----------
alter table public.tickets add column if not exists reviewed_at timestamptz;

create or replace function public.set_ticket_reviewed_at()
returns trigger
language plpgsql
as $$
begin
    if new.status in ('approved', 'rejected')
       and old.status is distinct from new.status then
        new.reviewed_at := now();
    end if;
    return new;
end;
$$;

drop trigger if exists trg_tickets_reviewed_at on public.tickets;
create trigger trg_tickets_reviewed_at
before update of status on public.tickets
for each row execute function public.set_ticket_reviewed_at();

-- 历史工单没有 reviewed_at：用最近一次 updated_at 近似审批时间
update public.tickets
set reviewed_at = updated_at
where status in ('approved', 'rejected')
  and reviewed_at is null;

-- ---------- 2. 贡献查询的局部索引 ----------
create index if not exists idx_tickets_edit_approved_credit
on public.tickets (user_id, (payload->>'column_key'), reviewed_at desc)
where type = 'edit' and status = 'approved';

-- ---------- 3. 公开只读视图 ----------
drop view if exists public.author_edit_credits;

create view public.author_edit_credits
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
  and c.status = 'published'
  and c.column_key not like 'sub-%'
order by t.user_id,
         c.column_key,
         coalesce(t.reviewed_at, t.updated_at) desc nulls last,
         t.id desc;

grant select on public.author_edit_credits to anon, authenticated;

comment on view public.author_edit_credits is
    '公开只读视图：审批通过的修改工单，按作者+专栏去重取最新一次，供作者贡献度加权计算；不含正文与敏感字段';

notify pgrst, 'reload schema';

-- ---------- 4. 自检 ----------
-- 4.1 已通过的修改工单数量
select count(*) as approved_edit_tickets
from public.tickets
where type = 'edit' and status = 'approved';

-- 4.2 视图前 10 条（确认去重、长度、难度、自改标记）
select editor_name, column_key, column_name, kind, difficulty,
       is_self_edit, old_len, new_len, reviewed_at
from public.author_edit_credits
order by reviewed_at desc
limit 10;
