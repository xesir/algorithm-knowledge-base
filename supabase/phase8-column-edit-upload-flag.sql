-- ============================================================
-- 第八阶段：修改工单支持「上传文件作为修改后内容」
-- 前置：phase7 已执行
-- 在 Supabase SQL Editor 整段执行。
--
-- 变更：
--   1. submit_column_edit 增加 p_uploaded 参数（默认 false）；
--   2. payload 写入 uploaded 标记，供后台审核判断是否隐藏逐行 diff；
--   3. 删除旧的 4 参数版本，避免 PostgREST 命中旧函数。
-- ============================================================

drop function if exists public.submit_column_edit(text, text, text, text);

create or replace function public.submit_column_edit(
    p_key text,
    p_password text,
    p_content text,
    p_note text default null,
    p_uploaded boolean default false
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
        'column_name', v_column.column_name,
        'category', v_column.category,
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
        '修改：' || v_column.column_name,
        'edit',
        'mid',
        '修改专栏 · ' || coalesce(nullif(v_column.category, ''), '未分类'),
        v_contact,
        'pending',
        v_payload
    )
    returning id into v_ticket_id;

    return v_ticket_id;
end;
$$;

revoke all on function public.submit_column_edit(text, text, text, text, boolean) from public, anon;
grant execute on function public.submit_column_edit(text, text, text, text, boolean) to authenticated;

-- 自检
select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where proname = 'submit_column_edit';
