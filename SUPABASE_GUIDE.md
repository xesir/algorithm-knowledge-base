# SUPABASE_GUIDE.md · Supabase 接入环境工作指南

> **本文件定位**：项目已接入 Supabase（Auth / Postgres / RLS / Storage / 触发器）后，**怎么在这个环境里干活、怎么加新功能**。
>
> **优先级（冲突时按此顺序取上者）**
>
> 1. `AGENTS.md`、`.trae/rules/project_rules.md`（三条铁律与入口）
> 2. `README.md`、`PROJECT_FRAMEWORK.md`（项目说明与框架手册）
> 3. **本文件**（Supabase 环境操作规范）
> 4. `docs/` 下的会话纪要、提示词、清单等参考文件
>
> 本文件只补充「后端/数据库怎么改」，**内容写作规范、加知识点/题目的流程仍以 `AGENTS.md` 与 `.trae/skills/*` 为准**，不要在这里另立一套。

---

## 1. 当前架构（事实，不是设想）

```
index.html / login.html / admin.html   纯静态前端（无框架、无 npm 依赖）
        │  supabase-js（CDN）+ supabase-config.js（只放 publishable key）
        ▼
Supabase 项目（ref: ajgixlgytxhrsmhnzsmg）
  ├─ Auth          邮箱/站内合成邮箱登录；不要求邮箱验证
  ├─ Postgres      profiles / tickets / columns / column_locks / tags
  ├─ RLS           所有业务表均开启；匿名仅可 insert 建议工单、读已发布专栏
  ├─ Storage       avatars（公开桶，目录按 auth.uid() 隔离）
  ├─ 触发器        handle_new_user / protect_profile_fields / publish_submission_ticket
  └─ RPC           set_column_password / verify_column_password / get_column_lock_status / submit_column_edit
```

**投稿→入库链路（核心业务闭环）**

```
login.html 投稿表单
   └─ insert tickets(type='submission', payload=jsonb)
          └─ 管理员在 admin.html 点「通过并入库」
                 └─ update tickets.status='approved'
                        └─ 触发器 publish_submission_ticket()
                               └─ insert/upsert columns(status='published', source_ticket_id=工单 id)
                                      └─ 标签 upsert 进 tags 表
                                             └─ 前台/专栏管理读取 columns
```

**文件分工**

| 路径 | 职责 |
|---|---|
| `supabase-config.js` | URL + publishable key（**只允许这两项**） |
| `assets/auth.js` | `window.AKB`：会话、profile、`contactToEmail`、转义、时间格式化、退出 |
| `login.html` | 登录/注册/工单（建议 + 投稿）/账号设置 |
| `admin.html` | 工单审批、用户审核、个人设置、专栏管理、我的投稿 |
| `supabase/phase*.sql` | 数据库迁移，按编号顺序执行 |
| `supabase/*.sql`（非 phase） | 一次性运维脚本（授权管理员、绑定作者专栏等） |

---

## 2. 硬性环境约定

1. **密钥分权**：前端只用 `publishable`（anon）key；`service_role` 只允许出现在本机环境变量里，**绝不写进仓库、聊天记录或文档**。
2. **数据库口令**：只从 `临时文件/数据/数据库密码.txt` 读取；本文件与任何代码都不得复制该口令。连接串、pooler 地址可以写，口令不行。
3. **PowerShell 强制约定**：项目里所有 `Invoke-WebRequest` **必须带 `-UseBasicParsing`**（用户 2026-11-06 明确要求，避免 IE 引擎解析失败/弹窗）。
4. **SQL 由用户执行**：`publishable` key 不能跑 DDL。新增迁移文件后，明确告诉用户在 Supabase SQL Editor 整段 Run，并给出顺序。
5. **测试数据必须清理**：联调产生的 `tickets` / `columns` / 测试账号 / 测试标签，测完立刻按 §7.4 清掉，不留脏数据。
6. **本地预览端口固定 8765**：`python -m http.server 8765`，前端页面的 Supabase 回调与浏览器测试都按这个端口写。
7. **node 用绝对路径**（本机 PATH 可能没有）：
   `C:\Users\admin\AppData\Roaming\secoresdk\360se6\Application\components\Node\node.exe`（v22.14.0）。

---

## 3. 数据库迁移工作流（加任何后端能力都走这里）

### 3.1 现有迁移顺序

| 顺序 | 文件 | 内容 |
|---|---|---|
| 1 | `supabase/phase2.sql` | profiles / tickets / column_locks、`is_admin()`、新用户触发器、基础 RLS、专栏密码函数 |
| 2 | `supabase/phase3-columns.sql` | `profiles.avatar_url`、`columns` 表、专栏密码状态/设置/校验、`avatars` 桶与 RLS |
| 3 | `supabase/phase4-submissions.sql` | **`tickets.payload`**、columns 元数据（tags/category/parent_key/difficulty/kind/status/source_ticket_id）、审批入库触发器 v1 |
| 4 | `supabase/phase5-effect-relations.sql` | 单关系字段 `relation_type` / `relation_target`，入库支持 author_id |
| 5 | `supabase/phase6-tags-relations-anon.sql` | 匿名建议 insert 策略、`tags` 表、`columns.relations jsonb`、触发器 v3（多关系 + 标签入库） |
| 6 | `supabase/phase7-column-edit-tickets.sql` | 「修改」工单：`submit_column_edit()` RPC、审批后写回 `columns.content`、禁止绕过 RPC 直插 `type='edit'` |
| 7 | `supabase/phase8-column-edit-upload-flag.sql` | 「修改」工单 payload 增加 `uploaded` 标记（替换 phase7 的 5 参 `submit_column_edit`），供后台在上传文件提交时隐藏逐行 diff |
| 8 | `supabase/phase9-published-columns-view.sql` | 公开只读视图 `published_columns`：已发布 `col-*` / `sub-*` 专栏 + 作者昵称 + `updated_at`，供首页增量覆盖静态内容 |
| 9 | `supabase/phase10-guest-access-edit-metadata.sql` | 视图增加 `locked`（游客访问控制）；`submit_column_edit` 支持 `p_tags` / `p_category` / `p_difficulty`；审批时写回元数据 |
| 10 | `supabase/phase11-edit-column-title.sql` | 「修改」工单增加 `p_column_name`，审批时写回 `columns.column_name` |
| 11 | `supabase/phase12-author-default-passwords.sql` | 除 Xesir 外，作者默认专栏密码 = `auth.users.encrypted_password`；Xesir 默认密码留空 |
| 12 | `supabase/phase13-login-by-identifier.sql` | 登录解析 RPC：昵称 / 邮箱 / QQ / 洛谷 / CF 任一标识 + 密码 → 返回登录邮箱（密码错误返回 `null`） |
| 13 | `supabase/phase14-contribution-view.sql` | `tickets.reviewed_at` + 审批时间触发器；公开视图 `author_edit_credits`（approved 修改工单按作者+专栏去重，排除 `sub-*`，供作者贡献度加权） |
| 14 | `supabase/phase15-author-avatars.sql` | 公开视图 `author_profiles`（活跃作者昵称 + 头像 URL），供作者专栏与密码门显示头像 |
| 15 | `supabase/phase16-author-profile-fields.sql` | `profiles.signature` / `profiles.honors`；重建 `author_profiles`，供作者本人编辑签名与战绩、公开页展示 |
| 16 | `supabase/phase17-existing-column-version.sql` | 投稿工单支持 `version_of`：审批通过后在已有专栏下新增 `col-<base>--<作者昵称>` 版本，不覆盖原专栏 |
| 17 | `supabase/phase18-author-admin-badge.sql` | `author_profiles` 增加 `role`，作者列表 / 主页 / 密码门显示「管理员」标识 |
| 18 | `supabase/phase19-edit-relations.sql` | `columns.relations_override`；`published_columns.relations / relations_override`；`submit_column_edit` 增加 `p_relations`；审批写回关系字段 |
| 19 | `supabase/phase20-guard-overwrites.sql` | 工单审批防覆盖守卫（`base_updated_at` / 重复作者版本）；后台上传 RPC `admin_publish_column`（insert 拒绝覆盖、update 必须带 `expected_updated_at`） |
| 20 | `supabase/phase21-meta-edit.sql` | 元数据便捷修改：管理员 `admin_update_column_meta` 直接改标题/分类/难度/标签/关系；普通用户 `submit_column_meta_edit` 提交元数据工单（正文快照不变） |
| 21 | `supabase/phase22-meta-fields-credit.sql` | 便捷修改扩展字段（CF 评分 / OJ / 题号 / 时间 / 空间复杂度）+ 元数据贡献视图 `author_meta_credits`（每条 0.02） |

> 触发器以**最后执行的那一版**为准。phase11 之后不要再单独跑 phase4/5/6/7 的 `create or replace function`，否则会退回旧逻辑（丢失「修改」工单分支、`uploaded`、元数据或标题写回）。

### 3.2 新迁移文件规范

- 命名：`supabase/phaseN-<主题>.sql`（N 递增，主题用英文短横线）。
- **必须幂等**，便于用户重复执行：
  - `alter table ... add column if not exists ...`
  - `create table if not exists ...`
  - `create or replace function ...`
  - `drop policy if exists ...; create policy ...`
  - 约束先查 `pg_constraint` 再 `add constraint`（参考 phase4 的 `do $$ ... $$`）。
- 文件头写清：**前置迁移**、**执行方式**（SQL Editor 整段 Run）。
- 文件尾附 1~2 条 `select` 自检语句。
- 涉及 RLS 时，`grant` 与 `policy` 成对出现；匿名访问必须显式 `to anon` 并 `grant ... to anon`。

### 3.3 执行后自检（必须做）

1. REST 探针（有列就 200，没有就 400）：
   ```powershell
   $url='https://<ref>.supabase.co'; $key='<publishable>'
   Invoke-WebRequest -UseBasicParsing -Headers @{apikey=$key; Authorization=('Bearer '+$key)} `
     -Uri ($url + '/rest/v1/tickets?select=payload&limit=1')
   ```
2. 关键对象清单：`tickets.payload`、`columns.relations`、`tags` 表、`trg_publish_submission` 触发器。
3. 真链路：投稿 → 审批 → 查 `columns where source_ticket_id = <id>`，核对 owner / tags / relations / status。

### 3.4 本机直连数据库（只读核验用）

SQL Editor 之外，本机可以用 Python + `pg8000` 直连 pooler 做只读核验（**不要用它改业务数据**，测试数据除外且必须清理）：

- pooler 主机：`aws-0-ap-northeast-1.pooler.supabase.com`（端口 6543 事务模式 / 5432 会话模式）
- 用户名：`postgres.<项目ref>`；口令从 `临时文件/数据/数据库密码.txt` 读
- 运行方式：`python -B <脚本>`（`-B` 避免沙箱写 `__pycache__` 报错）
- 直连域名 `db.<ref>.supabase.co` 可能只有 IPv6，本机不通时就走 pooler

### 3.5 迁移记录

| 日期 | 迁移 | 状态 |
|---|---|---|
| 2026-11-06 | phase4 / phase5 / phase6 | 用户已在 SQL Editor 执行，REST 与触发器均已验证 |
| 2026-11-06 | phase7-column-edit-tickets | 用户已在 SQL Editor 执行；登录 + 专栏密码、审批写回、后台 diff 联调通过 |
| 2026-11-07 | phase8-column-edit-upload-flag | 已应用：`submit_column_edit` 仅保留 5 参版本，`authenticated` 可执行；上传标记与 diff 隐藏规则已联调 |
| 2026-11-07 | phase9-published-columns-view | 已应用：匿名 REST 可读 `published_columns`（608 条已发布栏目），首页增量覆盖联调通过 |
| 2026-11-07 | phase10-guest-access-edit-metadata | 已应用：视图 `locked` 生效；修改工单 payload 含标签/分类/难度与旧值，审批写回已验证 |
| 2026-11-08 | phase11-edit-column-title | 已应用：修改工单支持改专栏标题，payload 含 `old_column_name`，审批写回已验证 |
| 2026-11-08 | phase12-author-default-passwords | 已应用：475 条非 Xesir 专栏锁定，133 条 Xesir 专栏未锁定；默认密码 hash 复制自作者登录密码 |
| 2026-11-08 | phase13-login-by-identifier | 已应用：`resolve_login_email()` 仅授予 `anon` / `authenticated`；昵称/QQ/洛谷/CF/邮箱 + 正确密码均能解析出登录邮箱，错误密码返回 `null` |
| 2026-11-08 | phase14-contribution-view | 已应用（2026-11-09 用户确认）：`tickets.reviewed_at`、`author_edit_credits` 公开视图 |
| 2026-11-08 | phase15-author-avatars | 已应用（2026-11-09 用户确认）：公开视图 `author_profiles`；作者页与密码门显示头像，未执行时回退首字母头像 |
| 2026-11-08 | phase16-author-profile-fields | 已应用（2026-11-09 用户确认）：`profiles.signature` / `profiles.honors`；重建 `author_profiles` |
| 2026-11-09 | phase17-existing-column-version | 已应用（2026-11-09 用户确认）：投稿 payload 支持 `version_of`；审批通过后新增已有专栏的作者版本，不覆盖原专栏 |
| 2026-11-09 | phase18-author-admin-badge | 已应用（2026-11-09 用户确认）：`author_profiles.role`；作者列表 / 主页 / 密码门显示管理员标识 |
| 2026-11-11 | phase19-edit-relations | **待用户在 SQL Editor 执行**：`columns.relations_override`；`published_columns.relations / relations_override`；`submit_column_edit` 增加 `p_relations`；审批写回关系字段 |
| 2026-11-11 | phase20-guard-overwrites | **待用户在 SQL Editor 执行**：工单审批防覆盖守卫；后台上传 RPC `admin_publish_column`；已在事务中验证语法与四类冲突（重复 insert / 过期 update / 过期修改工单），验证后回滚 |
| 2026-11-12 | phase21-meta-edit | **待用户在 SQL Editor 执行**：元数据便捷修改 RPC（管理员直改 / 普通用户工单）；已在事务中验证非管理员拦截、管理员直改、普通工单生成、审批后正文不变且元数据生效，验证后回滚 |
| 2026-11-12 | phase22-meta-fields-credit | **待用户在 SQL Editor 执行**：`columns` 增加 `cf_rating / oj / problem_id / time_complexity / space_complexity / meta_override`；两个 RPC 支持新字段；审批写回触发器；`author_edit_credits` 排除 `meta_only`，新增 `author_meta_credits`；已在事务中验证管理员直改、12 参工单、审批写回与两个视图，验证后回滚 |

---

## 4. 数据模型要点

### 4.1 `tickets.payload`（投稿工单结构化数据）

```json
{
  "column_name": "栏目名称",
  "author_id": "作者 profiles.id（UUID 字符串）",
  "author_name": "作者显示名（仅展示用）",
  "category": "所属大类（必填）",
  "tags": ["标签A", "自定义标签B"],
  "relations": [
    { "type": "related",       "target": "关联目标 column_key" },
    { "type": "sequence",      "target": "后置目标 column_key" },
    { "type": "parent-child",  "target": "父知识点 column_key" }
  ],
  "kind": "knowledge | problem",
  "difficulty": "仅 kind=problem 时有值",
  "content": "栏目正文（Markdown）"
}
```

- 建议工单**不写 payload**，只有 `title/description/contact`，因此匿名也能提交。
- 触发器强校验：`content` 非空、`category` 非空、`author_id` 对应 profile 必须 `active`、每条 relation 必须有 `type` + `target`。

**「修改」工单 payload（`tickets.type = 'edit'`）**

```json
{
  "column_key": "目标 columns.column_key",
  "column_name": "修改后的专栏标题",
  "old_column_name": "提交时的专栏标题",
  "kind": "knowledge | problem（快照）",
  "category": "修改后的所属大类",
  "old_category": "提交时的所属大类",
  "tags": ["修改后的标签"],
  "old_tags": ["提交时的标签"],
  "difficulty": "修改后的难度（题目；null 表示清空）",
  "old_difficulty": "提交时的难度",
  "relations": [{ "type": "related | sequence | parent-child", "target": "col-xxx" }],
  "old_relations": "提交时的关系数组",
  "relation_type": "首条关系的类型（兼容旧字段）",
  "relation_target": "首条关系的目标（兼容旧字段）",
  "parent_key": "父子关系目标（无则 null）",
  "old_content": "提交时的专栏正文快照（用于后台 diff）",
  "content": "修改后的 Markdown",
  "note": "用户填写的修改说明，可空",
  "base_updated_at": "提交时 columns.updated_at",
  "uploaded": false
}
```

- 只能通过 RPC `submit_column_edit(p_key, p_password, p_content, p_note, p_uploaded, p_tags, p_category, p_difficulty, p_column_name, p_relations)` 创建：函数内部校验 `auth.uid()` 非空，并调用 `verify_column_password()` 校验专栏密码。`p_relations = null` 表示不修改关系，`[]` 表示清空。
- RLS 已禁止 authenticated 直接 `insert type='edit'`；管理员通过后由 `publish_submission_ticket()` 写回 `columns` 的 `content` / `column_name` / `tags` / `category` / `difficulty` / `relations` / `relation_type` / `relation_target` / `parent_key` / `relations_override`，新标签同时并入 `tags` 表。
- **前端「修改」目标范围**：只列 `column_key` 以 `sub-` / `col-` 开头的实际专栏，排除 7 条作者占位专栏；选中无密码专栏时前端用空密码探测 `verify_column_password`，成功即自动载入源码。超过 10 万字符的正文不再塞进 textarea，改为下载/上传文件。
- **后台展示规则**：`uploaded = true`（上传文件提交）或 diff 修改点 > 5 处时，审核详情不渲染逐行 diff，改为「查看修改后内容」全文；其余情况仍展示逐行差异。标题 / 标签 / 分类 / 难度 / 关系有变化时在详情头部显示「旧值 → 新值」。

### 4.2 `columns` 关键字段

| 字段 | 说明 |
|---|---|
| `owner_id` | 作者（审批入库时取 `payload.author_id`，缺省为工单提交者） |
| `column_key` | 唯一键；投稿自动入库为 `sub-<ticket_id>`，作者本人专栏为作者名 |
| `column_name` | 展示名 |
| `tags text[]` | 标签数组 |
| `category` / `parent_key` / `difficulty` | 元数据 |
| `kind` | `knowledge` / `problem`（check 约束） |
| `status` | `pending` / `published` / `rejected`（check 约束） |
| `relations jsonb` | 多关系数组，默认 `[]` |
| `relation_type` / `relation_target` | 首条关系的冗余字段（旧逻辑/兼容用） |
| `source_ticket_id` | 来源工单，唯一索引防重复入库 |

### 4.3 `tags`（标签库）

- 审批入库时 `insert ... on conflict (name) do nothing`，自定义标签自动并入可选库。
- 前端可选标签 = `tags.json`（构建产物，730 个）+ `tags` 表（用户新增）。
- `tags` 表目前**没有从 `tags.json` 回填**，需要时可做一次性 seed。

### 4.4 RLS 摘要

| 表 | anon | authenticated | admin |
|---|---|---|---|
| `profiles` | 不可读 | 读自己、改自己（不能改 role/status） | 读全部、改全部 |
| `tickets` | 仅 insert 建议（`user_id is null`） | insert 自己（`type <> 'edit'`）、读自己、删自己 pending 投稿/修改 | 读全部、改全部 |
| `columns` | 读 `published` | 读 `published` + 自己全部 | 读全部、写全部 |
| `column_locks` | 只能走 RPC | 读自己 | 读全部 |
| `tags` | 读 | 读 | 读 |

### 4.5 从 `content/` / `problems/` 批量建立专栏（作者归属）

仓库里的知识点与题目原本只在 Markdown 文件里；要让「修改」工单能选到具体专栏，需要先把它们写进 `columns`。

- 生成脚本：`scripts/seed-columns-from-content.js`
- 产出目录：`supabase/seed-columns/`，共 16 个 SQL 分片，按文件名序号 `01 → 16` 在 SQL Editor 逐个执行。
- 规模（当前）：知识点 **408** 行（292 个 base + 作者版本）、题目 **200** 行（192 个 base + 作者版本），合计 **608** 行。
- 规则：
  - 主文件 `xxx.md` → `column_key = col-xxx`，作者取 `source`，识别不到归 `world-needs-sunday`；
  - 作者版本 `xxx--key.md` → `column_key = col-xxx--key`，作者按 `AUTHOR_KEYS` 映射；
  - `column_name` = 标题；作者版本追加 ` · 作者`；`content` = frontmatter 之后的正文；
  - `parent_key` 来自 `knowledge_graph.json` 的 `parent`，并加 `col-` 前缀；
  - 按 `column_key` upsert，**可重复执行**；执行前会检查所有作者在 `profiles` 中存在。
- 重新生成：

```bash
node scripts/seed-columns-from-content.js
node scripts/seed-columns-from-content.js --dry-run
node scripts/seed-columns-from-content.js --only=knowledge
```

- 执行完全部 SQL 后，`login.html` 的「修改」下拉才会出现这些 `col-*` 专栏（作者占位专栏仍被排除）。

### 4.6 公开专栏视图、前端增量覆盖与游客访问控制（phase9 / phase10）

首页正文仍然来自 `data.js` / `problems_data.js`，但工单审批后只写 `columns`。为了让改动能出现在公开页：

- `supabase/phase9-published-columns-view.sql` 建立视图 `public.published_columns`，phase10 再补充 `locked`：
  - 只含 `status='published'` 且 `column_key` 以 `col-` / `sub-` 开头的行；
  - 附带 `profiles.nickname` 作为 `author_name`（`profiles` 本身不可匿名读）；
  - `locked` 按 `coalesce(特定密码, 作者默认密码) is not null` 计算，与 `verify_column_password()` 的优先级一致；
  - 视图以属主权限执行，绕过基础表 RLS，但只暴露上述已发布数据；已 `grant select` 给 `anon` / `authenticated`。
- `build.js` 在 `data.js` 顶部写入 `DATA_BUILD_AT` 与 `AUTHOR_KEYS`。
- `index.html` 载入后调用 `syncPublishedColumns()`：
  - `col-*` 仍以 `updated_at > DATA_BUILD_AT` 增量查询；`sub-*` **始终查询**（`updated_at > DATA_BUILD_AT OR column_key like 'sub-%'`），因为它们只存在于数据库、没有静态 Markdown 对应内容；
  - `col-<base>` / `col-<base>--<key>` → 覆盖对应静态条目/作者版本的正文，并同步标签/分类/难度；
  - `sub-*` → 作为新专栏追加进 `KNOWLEDGE_DATA`（`kind=knowledge`）或 `PROBLEMS_DATA`（`kind=problem`），目录/侧栏出现「投稿」分组；
  - 打开页面时同步一次，之后每 60 秒与切回前台时再同步；同步基线只向前推进，不会被较早的 `sub-*` 时间回退。
- **游客访问控制**：
  - 打开页面时额外读取 608 条 `column_key, locked`（每 5 分钟与回到前台时补拉）；
  - 未登录游客：`locked=false` 直接看；`locked=true` 只显示「请先登录」拦截，不提供密码输入；
  - 登录用户：`locked=true` 显示密码门，调用 `verify_column_password` 验证，成功后本标签页内放行；`locked=false` 直接看；
  - 管理员（`profiles.role='admin'`）：无论 `locked` 与否都直接放行，可查看任意作者的专栏；
  - 修改专栏同样要求登录 + 密码验证（密码为空则无需输入）；
  - 密码门是前端展示层控制，正文本身仍在公开的 `data.js` 里，无法阻止直接读取静态文件。
- **登录标识（phase13）**：
  - 登录页把输入内容交给 `resolve_login_email(p_identifier, p_password)`；昵称 / 邮箱 / QQ / 洛谷 / CF 任一匹配、且 bcrypt 密码正确时才返回该账号的登录邮箱；
  - 前端拿到邮箱后再调 `signInWithPassword`（Supabase Auth 只认邮箱）；
  - 密码错误一律返回 `null`，不泄露账号是否存在，也不泄露邮箱。
- **作者默认密码（phase12）**：
  - 除 Xesir 外，每位作者的 `column_locks` 默认行（`column_key='__default__', is_default=true`）的 `password_hash` 直接复制自 `auth.users.encrypted_password`，因此作者用自己的**登录密码**即可解锁其全部专栏；
  - Xesir 的默认密码为 `null`，其 133 条专栏保持无密码；
  - 特定密码（`is_default=false`）仍优先于默认密码；当前没有特定密码行；
  - 游客访问有密码专栏只看到登录拦截，不提供密码输入；登录用户才出现密码门。
- **已知边界**：`col-*` 的正文覆盖仍以构建时间为基线；若某次修改审批发生在上一次 `node build.js` 之前、且 Markdown 源文件没有同步，重新构建后这条覆盖会被跳过，保持「先合并 Markdown 再构建发布」即可避免。`sub-*` 投稿不再受此影响：前端始终查询并追加，重新构建不会让已审批投稿消失。

### 4.7 作者贡献视图（phase14）

- `author_edit_credits` 只暴露 `editor_name / column_key / column_name / category / kind / difficulty / priority / old_len / new_len / is_self_edit / reviewed_at`，不含正文与联系方式。
- 只统计 `type='edit'`、`status='approved'`、`columns.status='published'` 且 `column_key` 不是 `sub-%` 的工单；按 `(user_id, column_key)` 去重，取 `reviewed_at` 最新一条。
- 前端加权：新建 1 篇 = 1.0；修补 1 处 = `0.4 × 难度系数 × 体量系数 × 优先级系数 × 自改系数`，单专栏上限 0.8；元数据便捷修改每条 0.02（phase22）；贡献率 = 个人加权分 ÷ 全站加权分。
- 知识点难度取 `build.js` 导出的 `versions[].level`（A/B/C）；题目难度取洛谷九档，缺档时用 `cfRating` 估算。
- `profiles.nickname` 必须能匹配静态作者显示名；匹配不上时前端会 `console.warn` 并按原名计入，需要时在 `index.html` 的 `AUTHOR_ALIASES` 补映射。
- 作者头像来自公开视图 `author_profiles`（phase15）；作者列表 / 主页 / 密码门优先显示头像，头像为空或视图未执行时回退首字母。
- 签名 / 战绩保存在 `profiles.signature` / `profiles.honors`（phase16）；作者本人在 `admin.html`「个人设置」编辑，公开视图 `author_profiles` 暴露给作者页展示；作者登录后访问自己的作者页会出现「编辑签名 / 战绩」入口。
- 作者头像有图时容器背景透明；无头像时才显示首字母 + 纯色 `#6366f1` 填充。
- `author_profiles.role`（phase18）供作者列表 / 主页 / 密码门显示「管理员」标识。
- 投稿已有专栏（phase17）：payload 带 `version_of`（base key），审批通过后新增 `col-<base>--<作者昵称>` 行，前端把它作为新 `versions[]` 追加；同一作者已写过该专栏时，登录页会提示并自动切换到「修改」工单。
- 作者页的修补数据每 30 秒自动刷新；新建计数来自静态 `data.js`，需要重新构建并部署后才会变。

### 4.8 后台上传与防覆盖（phase20）

- **后台上传 RPC**：`public.admin_publish_column(p jsonb)`，只授予 `postgres` / `service_role`，匿名与登录用户不可调用。
  - `mode=insert`：`on conflict (column_key) do nothing`，key 已存在就报错，绝不覆盖；
  - `mode=update`：必须带 `expected_updated_at`，锁行并比较 `updated_at`，比预期新就报错；
  - 字段语义与工单一致：`owner_id` 必须 active、`tags` upsert、`relations` 校验、`parent_key` 派生、`status='published'`、`source_ticket_id=null`；
  - 新专栏 key 用 `sub-admin-<slug>`（前端仍按 `sub-*` 始终同步）；已有专栏新版本用 `col-<base>--<作者昵称>`；修改沿用原 key。
- **工单防覆盖守卫**：`trg_guard_ticket_overwrite`（BEFORE UPDATE on tickets，按名称先于 `trg_publish_submission` 执行）。
  - 修改工单审批：校验 `payload.base_updated_at`，目标专栏在提交后被更新过就报错；
  - 新版本投稿：若 `col-<base>--<作者昵称>` 已存在就报错，提示改用修改工单；
  - 新专栏：`sub-<ticket_id>` 若被其他来源占用就报错。
- **使用限制**：后台上传技能 `.trae/skills/admin-upload/SKILL.md` **只在用户明确说「此次为后台上传」时调用**；普通入库/改内容仍走工单或四个技能。
- **测试**：phase20 已在事务中验证「重复 insert / 过期 update / 过期修改工单 / 重复作者版本」四类冲突，验证后回滚；正式执行前不要在 SQL Editor 之外直接写 `columns`。

### 4.9 元数据便捷修改（phase21）

专栏/题目详情页的 Meta 栏有「✏️ 便捷修改」按钮，只改非正文部分：

- **可改字段**：标题、分类、难度（题目）、标签、关系、CF 评分 / OJ / 题号（题目）、时间复杂度 / 空间复杂度。
- **管理员**：调用 `admin_update_column_meta(jsonb)`，函数内校验 `profiles.role='admin'` 和 `expected_updated_at`，直接写 `columns` 并刷新页面。
- **普通登录用户**：调用 `submit_column_meta_edit(...)`（phase22 起为 12 参），生成 `type='edit'` 的 pending 工单；payload 带 `meta_only=true`、当前正文快照、`base_updated_at` 和元数据。审批时现有触发器把正文写回为同一快照，只改元数据。
- **关系预填**：DB `relations` 为空且 `relations_override=false` 时，前端回退展示静态 `prerequisites / related / parent`（题目为 `knowledgePoints`），保存后成为显式覆盖。
- **评分 / 复杂度**：DB 字段为空且 `meta_override=false` 时，前端回退静态 `cfRating / oj / problemId / timeComplexity / spaceComplexity`；一旦人工改过（`meta_override=true`），前端增量同步以数据库为准。
- **防覆盖**：管理员直改与工单审批都走 `updated_at` 乐观锁；目标在提交后被更新则报错。
- **前置**：phase21 / phase22 未执行时，保存会提示「请先在 SQL Editor 执行 supabase/phase21-meta-edit.sql、phase22-meta-fields-credit.sql」。

### 4.10 元数据贡献（phase22）

- 管理员直改元数据时，`admin_update_column_meta` 会额外插入一条 `status='approved'`、`payload.meta_only=true` 的审计工单；普通用户工单审批通过后同样计入。
- 公开视图 `author_meta_credits` 只暴露 `editor_name / column_key / column_name / category / kind / difficulty / priority / is_self_edit / reviewed_at`，按 `(user_id, column_key)` 去重取最新。
- 前端每条元数据修改固定计 **0.02**，与修补贡献同列展示；`author_edit_credits` 已排除 `meta_only=true`，不会重复计分。
- 同一作者反复修改同一专栏只计一次（与修补贡献的去重口径一致）。

---

## 5. 添加新功能的标准流程

> 顺序不要跳：**先想清楚数据落哪张表**，再写 SQL，再写前端。

1. **定数据落点**
   - 只是展示/交互 → 纯前端，不改库。
   - 需要持久化 → 先定：加列？加表？还是塞进 `payload` / `relations`？
   - 需要审批后自动执行 → 必须走 `tickets.payload` + 触发器，不要在 admin.html 里手写第二条写入逻辑。
2. **写迁移** `supabase/phaseN-<主题>.sql`（幂等，见 §3.2），列清前置顺序。
3. **改后端语义**
   - 新字段的默认值、check 约束、唯一索引。
   - RLS：谁能读、谁能写、匿名是否需要。
   - 触发器：`publish_submission_ticket()` 用 `create or replace`，**保留已有分支**，只加新字段。
4. **改前端**
   - 表单字段加在 `login.html`（工单）或 `admin.html`（管理），同步 `collectXxx()` 与 payload。
   - 显示字段同步列表/详情/`effectLabel`；新增 UI 类写进 `assets/forms.css`。
   - 所有来自用户的文本渲染必须过 `window.AKB.escapeHtml()`。
5. **测试**（见 §7），必须覆盖：正常路径、空值、未登录、RPC/RLS 拒绝路径。
6. **收尾**：更新 `README.md` 规模数字、写当日会话纪要、跑 `node tools/lint.js` + `node build.js`。

### 5.1 例子：给投稿增加「来源链接」

1. `payload` 加 `source_url`（无需 DDL）。
2. `login.html` 投稿区加输入框，收集进 payload。
3. `admin.html` 的 `submissionDetail()` 展示它。
4. 触发器里 `columns.description` 或新列 `source_url` 落库（新列要 phaseN）。
5. 测试：提交带链接的投稿 → 审批 → 查 `columns`。

### 5.2 例子：新增工单类型（如「纠错」）

1. `tickets.type` 目前无 check 约束，直接可写新值；如要约束再加 `check`。
2. `login.html` 的 `syncTicketType()` 增加分支与字段区。
3. `admin.html` 的 `typeLabel()` / `effectLabel()` / 详情渲染加分支；`effectLabel` 无自动效果就返回「无」。
4. 若审批后要自动执行，在触发器里加 `new.type = 'fix'` 分支。
5. RLS 若需匿名，补 `tickets_insert_anonymous_*` 策略。

**已落地例子：「修改」工单（phase7）**

1. 用 RPC `submit_column_edit()` 创建，函数内校验登录与专栏密码；RLS 禁止直接插入 `type='edit'`。
2. payload 同时保存 `old_content`（提交时快照）与 `content`（修改后），后台用两段文本做 diff。
3. 审批通过后触发器写回 `columns.content`，不新建 `columns` 行，也不改 `source_ticket_id`。

---

## 6. 常见错误与排查

| 现象 | 原因 | 解决 |
|---|---|---|
| `Could not find the 'payload' column of 'tickets'` | 没执行 `phase4-submissions.sql` | 按 phase4 → 5 → 6 顺序执行 |
| `new row violates row-level security policy` | 缺 policy 或没 `grant` | 补 `to anon, authenticated` 策略与 `grant` |
| `401 no_authorization` 调 Auth Admin API | publishable key 不是 service_role | 批量建号只能在本地用 `SUPABASE_SERVICE_ROLE_KEY` 跑 `scripts/seed-authors.js` |
| 表单字段设了 `hidden` 却仍显示 | `.form-field { display:grid }` 覆盖默认 `[hidden]` | 已在 `forms.css` 加 `[hidden]{display:none !important}` |
| 作者下拉显示成专栏名（如 `sub-*`） | 用 `columns.column_name` 按 owner 去重 | 优先非 `sub-*` 的 `column_key`（`login.html` 已修） |
| 审批后没入库 | 触发器没建 / 作者非 `active` / content、category 为空 | 查 `trg_publish_submission`，看报错文案 |
| 修改工单审批后没写回 | 没执行 phase7 / payload 缺 `column_key` 或 `content` | 执行 `phase7-column-edit-tickets.sql` 并检查 payload |
| 上传文件提交后后台仍显示 diff | 没执行 phase8 / 前端没传 `p_uploaded` | 执行 `phase8-column-edit-upload-flag.sql`，确认 payload 的 `uploaded` 为 `true` |
| 工单审批通过后公开页没变化 | 没执行 phase9 / 浏览器缓存旧 `data.js` / 改动时间早于构建时间 | 执行 `phase9-published-columns-view.sql`；Ctrl+F5；确认 `updated_at > DATA_BUILD_AT` |
| `published_columns` 404 | 视图未建或 PostgREST 未刷新 | 重跑 phase9（含 `notify pgrst, 'reload schema'`） |
| 游客看不到密码门 / 无密码专栏也要密码 | 没执行 phase10 / 视图缺 `locked` / 浏览器缓存旧 HTML | 执行 phase10；Ctrl+F5；确认 REST 返回 `locked` 字段 |
| 游客打开有密码专栏没有输入框 | 设计如此：游客不提供密码入口 | 先登录；登录后才会出现密码门 |
| 登录用户输对密码仍不显示正文 | `verify_column_password` 未授予 authenticated / 密码优先级不匹配 | 检查函数授权；密码规则为「特定 > 默认 > 无密码」 |
| 密码完全不生效、`locked` 全是 0 | 默认 `column_locks.password_hash` 为空，等于没有设置密码 | 执行 `phase12-author-default-passwords.sql`，默认密码复制自作者登录密码 |
| 用昵称 / QQ / 洛谷 / CF 登录提示密码错误 | 未执行 phase13 / 该账号没填过这个标识 / 输入的是专栏密码 | 执行 `phase13-login-by-identifier.sql`；确认注册时填过该标识，并用登录密码 |
| 管理员仍被专栏密码拦住 | `profiles.role` 不是 `admin`，或浏览器缓存旧 HTML | 查 `profiles.role`；Ctrl+F5 后重试 |
| 修改工单提示「专栏密码不正确」 | 专栏设置了特定/通用密码，输入不匹配 | 用 `column_locks` 的规则：特定 > 通用 > 无密码 |
| 修改工单提示「请先登录」 | 未登录就调 `submit_column_edit` | 先登录；该 RPC 只授予 authenticated |
| 修改工单被 RLS 拒绝 | 绕过 RPC 直接 insert `type='edit'` | 必须走 `submit_column_edit()` |
| 工单选择器仍显示 `dp-xxx` | 浏览器缓存了旧 HTML / 未构建 `titles.json` | Ctrl+F5；跑 `node build.js` 生成 `titles.json` |
| 改了页面但浏览器还是旧的 | HTML/JS 无缓存头 | 加 `?v=YYYYMMDD` 或用无缓存 URL 测试 |
| PowerShell 命令输出乱码/解析失败 | 未加 `-UseBasicParsing` | 所有 `Invoke-WebRequest` 都加上 |
| 直连 `db.<ref>.supabase.co` 超时 | 只有 IPv6 记录 | 走 §3.4 的 pooler |

---

## 7. 测试规范

### 7.1 静态门禁

```powershell
& "C:\Users\admin\AppData\Roaming\secoresdk\360se6\Application\components\Node\node.exe" tools/lint.js --quiet
& "C:\Users\admin\AppData\Roaming\secoresdk\360se6\Application\components\Node\node.exe" build.js
```

### 7.2 浏览器联调

```powershell
cd c:\Users\admin\Desktop\test\OIgit\algorithm-knowledge-base
python -m http.server 8765
```

- 打开 `http://localhost:8765/login.html?cb=<时间戳>` 绕过缓存。
- 必测：建议（未登录）、投稿（登录）、后台审批、自动入库、专栏管理、**修改工单（登录 + 专栏密码 + 标题/标签/分类/难度）**、**后台 diff 与编辑工单**、**审批后公开页增量覆盖**、**游客无密码直看 / 有密码拦截 / 登录后密码解锁**。

### 7.3 数据库核验

```sql
select id, title, type, status, payload from public.tickets order by id desc limit 5;
select id, title, type, status, payload->>'column_key' as target_key
from public.tickets where type = 'edit' order by id desc limit 5;
select column_key, owner_id, category, tags, relations, status, source_ticket_id,
       length(content) as content_len
from public.columns order by id desc limit 5;
select name from public.tags order by name;
```

### 7.4 测试数据清理

```sql
delete from public.columns  where source_ticket_id in (<测试工单id>);
delete from public.tickets  where id in (<测试工单id>);
delete from auth.users      where email = '<测试账号邮箱>';
delete from public.tags     where name like 'QA%';
```

> 清理前先截图/记录结果作为证据；清理后再跑一次上面的查询确认无残留。

---

## 8. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-11-06 | 新建本文件；投稿 payload / 审批自动入库 / 多关系 / 标签库 / 匿名建议链路联调通过；修复作者下拉被 `sub-*` 栏目名覆盖 |
| 2026-11-06 | 新增 phase7「修改」工单：`submit_column_edit()` RPC（登录 + 专栏密码）、审批后写回 `columns.content`、后台 diff 与管理员编辑工单、工单选择器显示专栏名称（`titles.json`） |
| 2026-11-07 | 新增 phase8：`submit_column_edit()` 增加 `p_uploaded`，payload 记录 `uploaded`；登录页与专栏管理支持下载/上传专栏文件，上传提交或修改点 > 5 处时后台只展示修改后全文 |
| 2026-11-07 | 新增 phase9：公开视图 `published_columns`；`index.html` 按 `updated_at` 增量覆盖静态正文，新投稿（`sub-*`）自动进入目录，每 60 秒与回到前台时刷新 |
| 2026-11-07 | 新增 phase10：视图增加 `locked`，游客只能直接查看无密码专栏，有密码的弹出密码门；`submit_column_edit()` 支持标签/分类/难度并在审批时写回，后台可查看元数据变化 |
| 2026-11-08 | 新增 phase11：修改工单支持改专栏标题；访问控制收紧为「游客不可访问有密码专栏，登录用户需输入密码（密码为空除外）」 |
| 2026-11-08 | 新增 phase12：作者默认专栏密码 = 作者登录密码（复制 bcrypt hash），Xesir 留空；首页增加权限检查占位，避免正文在拦截前闪现 |
| 2026-11-08 | 新增 phase13：邮箱 / QQ / 洛谷 / CF / 昵称任意一个 + 密码均可登录；管理员免密码查看任意专栏；修改专栏的源码默认不展开，点按钮才写入文本框以避免卡顿 |
| 2026-11-08 | 新增 phase14：`tickets.reviewed_at` 与审批时间触发器；公开视图 `author_edit_credits`（approved 修改工单按作者+专栏去重，排除 `sub-*`）；前端作者专栏改为加权贡献（新建 1.0，修补 0.4 × 难度 × 体量 × 优先级 × 自改系数，单专栏上限 0.8） |
| 2026-11-08 | 新增 phase15：公开视图 `author_profiles`（活跃作者昵称 + 头像 URL）；作者列表/主页/密码门显示头像；作者页修补数据改为 30 秒自动刷新 |
| 2026-11-08 | 新增 phase16：`profiles.signature` / `profiles.honors`；`author_profiles` 暴露签名与战绩；作者在 `admin.html`「个人设置」编辑，自己的作者页出现编辑入口 |
| 2026-11-09 | 新增 phase17：投稿工单支持 `version_of`；审批通过后为已有专栏新增 `col-<base>--<作者昵称>` 版本；同一作者已写过时前端提示并切换到修改工单 |
| 2026-11-09 | 新增 phase18：`author_profiles.role`；作者列表 / 主页 / 密码门显示「管理员」标识；作者头像有图时透明背景，无图时才首字母 + 纯色填充 |
| 2026-11-09 | phase14–18 已由用户在 SQL Editor 执行完毕；node 路径统一为 v22.14.0；本次只修正文档事实偏差，未改核心规则 |
| 2026-11-11 | 新增 phase19：`published_columns.relations`；修改工单支持 `p_relations`（null 不改 / [] 清空），审批写回 `relations` / `relation_type` / `relation_target` / `parent_key`；前端星图题目节点按难度着色、题目专辑按档位逐档计数 |
| 2026-11-11 | 新增 phase20：工单审批防覆盖守卫（修改工单校验 `base_updated_at`、重复作者版本拒绝覆盖、`sub-<id>` 被其他来源占用拒绝）；后台上传 RPC `admin_publish_column`（insert 拒绝覆盖、update 必须 `expected_updated_at`）；新增 `.trae/skills/admin-upload/SKILL.md`（仅限用户说「此次为后台上传」） |
| 2026-11-12 | 新增 phase21：专栏/题目 Meta 栏「便捷修改」；管理员 `admin_update_column_meta` 直改标题/分类/难度/标签/关系；普通用户 `submit_column_meta_edit` 提交元数据工单（正文快照不变）；关系为空时前端回退静态图谱预填 |
| 2026-11-12 | 新增 phase22：便捷修改支持 CF 评分 / OJ / 题号 / 时间 / 空间复杂度（`meta_override` 标记人工覆盖）；管理员直改留 approved 审计工单；`author_edit_credits` 排除 `meta_only`，新增 `author_meta_credits`；前端每条元数据修改计 0.02 贡献 |
