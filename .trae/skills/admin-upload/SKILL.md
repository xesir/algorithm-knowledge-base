---
name: "admin-upload"
description: "后台上传：仅当用户明确说「此次为后台上传」时调用。通过 Supabase RPC admin_publish_column 直接写 columns，不走工单审批；字段、作者、标签、关系、锁定与投稿/修改工单保持一致，并用 expected_updated_at 防止覆盖。未说这句话时禁止使用。"
---

# 后台上传（仅限明确指令）

> **硬性触发条件**：只有用户本轮原话明确包含「**此次为后台上传**」时才执行本技能。
> 用户没有说这句话时，一律转 `add-knowledge` / `add-problem` / `edit-content` / `release-github`，**不得**用本技能。
> 本技能直接操作数据库、不生成工单、不走审批；但字段语义必须与工单路径完全一致。

## 0. 先读与前置检查

1. 读 `AGENTS.md`、`PROJECT_FRAMEWORK.md`、`SUPABASE_GUIDE.md`；本文件只讲后台上传的差异。
2. 确认 `supabase/phase20-guard-overwrites.sql` 已在 SQL Editor 执行。检查：

```sql
select proname
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname = 'admin_publish_column';
```

没有结果就**停下**，让用户先执行 phase20，不要改用直接 `insert/update columns` 绕过。

## 1. 与工单路径的一致性（逐项对照）

| 项 | 投稿/修改工单 | 后台上传（本技能） |
|---|---|---|
| 新专栏 key | `sub-<ticket_id>` | `sub-admin-<slug>`（仍以 `sub-` 开头，前端始终同步） |
| 已有专栏新作者版本 | `col-<base>--<作者昵称>` | **完全相同** |
| 修改已有专栏 | 原 `column_key` | **完全相同** |
| 作者 | `payload.author_id`，必须 `profiles.status='active'` | 同左；可传 `author_id`，或用唯一 `author_name` 解析 |
| 标题/正文/分类/标签/题型/难度 | columns 对应字段 | **完全相同** |
| 关系 | `relations jsonb` + 首条冗余到 `relation_type/target` | **完全相同** |
| 父栏目 | `parent_key`（parent-child 关系的 target） | **完全相同** |
| 发布状态 | `status='published'` | **完全相同** |
| 来源工单 | `source_ticket_id = ticket_id` | `null`（没有工单） |
| 标签库 | 审批时 upsert 进 `tags` | RPC 内 upsert，**完全相同** |
| 专栏锁定 | 继承作者默认密码 / 特定密码 | **完全相同**，RPC 不额外设置密码 |
| 静态 Markdown | 不写，只写数据库 | **不写**，只写数据库 |
| 审计 | 工单记录 | `columns.updated_at` + 执行 SQL 记录 |

> `sub-admin-*` 与 `sub-*` 在前端都被当作「投稿」分组；`col-<base>--<作者>` 会被并入对应知识点的 `versions[]`。

## 2. 防覆盖规则（最重要）

### 2.1 只允许走 RPC

禁止直接 `insert into public.columns` / `update public.columns`。唯一入口：

```sql
select public.admin_publish_column($json$ { ...payload... } $json$::jsonb);
```

RPC 已内置：

- **insert 模式**：`on conflict (column_key) do nothing`，若 key 已存在直接报错，**绝不覆盖**；
- **update 模式**：必须带 `expected_updated_at`；目标行被锁住并比较 `updated_at`，比预期新就报错，**绝不覆盖**；
- 作者必须 `active`；`relations` 必须是合法数组；标签自动 upsert。

### 2.2 修改前必须读当前版本

```sql
select column_key, column_name, category, kind, difficulty, tags,
       length(content) as content_len, updated_at
from public.columns
where column_key = '<目标 key>';
```

把这个 `updated_at` 原样放进 payload 的 `expected_updated_at`。

### 2.3 冲突时停下，不许“强行覆盖”

RPC 报「目标专栏已被更新」或「column_key 已存在」时：

1. 重新读取当前行；
2. 把当前正文/标题/标签与本次准备写入的内容做 diff；
3. 把差异给用户看，让用户决定是「基于新版本重新改」还是「放弃」；
4. **不要**删掉 `expected_updated_at`、不要改用直接 `update`、不要加 `force`。

### 2.4 与工单修改的关系

- 工单修改审批现在会校验 `payload.base_updated_at`：目标专栏在提交后被更新过，审批会直接报错，不再静默覆盖。
- 后台上传的 update 与工单修改谁先提交谁生效；后提交的一方会因为 `updated_at` 变化而失败。
- 不要为了“让工单通过”去改 `base_updated_at`；应让用户重新载入源码后再提交修改工单。

## 3. 输入与元数据

用户仍然可能丢一个文件夹（`题目.md` + `代码.cpp` + `思路.md`），按 `AGENTS.md` 的输入习惯处理：

- **作者**：按来源文件夹判定；用户明确指定时以用户为准（例如 `临时文件/Xesir.md/**` 默认 Xesir，但用户说“以 renzhaoyang 身份”就用 renzhaoyang）。
- **新专栏 key**：`sub-admin-<slug>`；`slug` 用小写字母、数字、连字符，全局唯一。
- **已有专栏新版本**：`col-<base>--<作者昵称>`，与工单完全一致；若该 key 已存在，RPC insert 会拒绝，改用 update 流程。
- **修改**：沿用原 `column_key`，不要新建 key。
- **题型**：`kind='knowledge'` 或 `kind='problem'`；题目必须给 `difficulty`（洛谷九档）。
- **分类**：7 个大类之一；题目按考点大类填。
- **标签**：3–6 个最佳，最多 8 个；数组形式。
- **关系**：`[{"type":"related|sequence|parent-child","target":"<现有 column_key>"}]`；target 必须已存在。
- **父栏目**：知识点的 `parent_key`，与 `parent-child` 关系的 target 一致。
- **代码**：与工单路径一致，正文里放 Markdown 代码块；**不新增/不代写 `.cpp` 实现**。如果用户另外要求把 `.cpp` 放进仓库，再走 `add-knowledge`/`add-problem` 的文件流程，不要在本技能里改实现。

## 4. Payload 模板

### 4.1 新专栏

```json
{
  "mode": "insert",
  "column_key": "sub-admin-<slug>",
  "author_name": "<作者昵称>",
  "column_name": "<标题>",
  "description": "<可选>",
  "content": "<Markdown 正文>",
  "category": "<7 大类之一>",
  "tags": ["标签1", "标签2"],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [],
  "parent_key": null
}
```

题目把 `kind` 改成 `problem`，并给 `difficulty`。

### 4.2 已有专栏新作者版本

```json
{
  "mode": "insert",
  "column_key": "col-<base>--<作者昵称>",
  "author_name": "<作者昵称>",
  "column_name": "<原标题> · <作者昵称>",
  "content": "<Markdown 正文>",
  "category": "<继承基础专栏>",
  "tags": ["继承或自定义"],
  "kind": "<继承>",
  "difficulty": "<继承>",
  "relations": []
}
```

### 4.3 修改已有专栏

```json
{
  "mode": "update",
  "column_key": "<原 key>",
  "content": "<新 Markdown>",
  "column_name": "<可选，新标题>",
  "category": "<可选>",
  "tags": ["可选"],
  "difficulty": "<题目可选>",
  "relations": [],
  "expected_updated_at": "<刚才读到的 updated_at，原样复制>"
}
```

## 5. 执行步骤

### Step 1 · 准备并确认

- 读材料，列出：`column_key`、标题、作者、分类、标签、题型/难度、关系、目标 `updated_at`。
- 把 payload 摘要给用户确认；**不要**在确认前写库。

### Step 2 · 生成 SQL

默认由用户在 Supabase SQL Editor 整段执行：

```sql
select public.admin_publish_column($json$
{ ...payload... }
$json$::jsonb);
```

只有用户明确授权“你可以直接连库执行”时，才允许用本机 Python + `pg8000`：
- 口令从 `临时文件/数据/数据库密码.txt` 读，**不得**写入代码、日志或回复；
- 用事务执行，失败必须 `rollback`；
- 执行前把 SQL 给用户看。

### Step 3 · 验证

```sql
select column_key, column_name, category, kind, difficulty, tags,
       length(content) as content_len, source_ticket_id, status, updated_at
from public.columns
where column_key = '<key>';

select column_key, column_name, author_name, updated_at
from public.published_columns
where column_key = '<key>';
```

- 新专栏确认 `status='published'`、`source_ticket_id is null`；
- 修改确认 `content_len` 与预期一致、`updated_at` 已推进；
- 需要页面验收时用 `?cb=<时间戳>` 打开 `index.html`；`sub-*` 会始终同步，`col-*` 仍受 `DATA_BUILD_AT` 边界影响。

### Step 4 · 汇报

固定四段：【改动】【验证】【需要你本人做】【待确认】。必须写清：
- 是 insert 还是 update；
- `column_key` 与 `updated_at`；
- 是否与工单路径一致（作者/分类/标签/关系/锁定）；
- 是否发生冲突（有冲突必须写）。

## 6. 常见错误

| 现象 | 原因 | 处理 |
|---|---|---|
| `function public.admin_publish_column(jsonb) does not exist` | phase20 未执行 | 让用户先在 SQL Editor 执行 `supabase/phase20-guard-overwrites.sql` |
| `column_key 已存在，拒绝覆盖` | insert 撞到已有 key | 改走 update：读当前 `updated_at`，带 `expected_updated_at` |
| `目标专栏已被更新，拒绝覆盖` | 工单或其他上传已先提交 | 重新读取、做 diff、让用户决定；不要绕过 |
| `作者不存在或未激活` | 昵称不唯一或账号未 active | 改用 `author_id`；或让用户确认账号状态 |
| `每条关系都必须包含类型和关联目标` | relations 格式不对 | 用 `related/sequence/parent-child` + 现有 `column_key` |
| 页面看不到新内容 | 浏览器缓存 / `col-*` 构建基线 | `?cb=` 强刷；`sub-*` 已始终同步，`col-*` 需同步静态 Markdown 后重新构建 |
| 正文被密码门拦住 | 继承了作者默认密码 | 与工单一致；不是丢失，输入作者登录密码即可；如需公开需单独确认解锁 |

## 7. 绝对不要做

- ❌ 未听到「此次为后台上传」就使用本技能。
- ❌ 直接 `insert/update/delete public.columns` 绕过 RPC。
- ❌ 在冲突时删掉 `expected_updated_at`、强行覆盖。
- ❌ 生成/补全任何 `.cpp` 实现。
- ❌ 创建 `tickets` 工单或调用审批触发器来“模拟”后台上传。
- ❌ 在未得到用户确认前执行 DDL 或写生产库。
- ❌ 修改 `owner_id` / `source_ticket_id` 来掩盖覆盖问题。
