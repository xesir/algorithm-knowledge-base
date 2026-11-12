# 算法知识点知识库 · 项目说明

> 一个个人维护的**算法/知识点查询网站**：内容源是 Markdown，用 `build.js` 生成前端数据，纯静态托管在 GitHub Pages。
> **给 AI 的一句话**：先读 [`AGENTS.md`](AGENTS.md)（铁律 + 入口），再读 [`PROJECT_FRAMEWORK.md`](PROJECT_FRAMEWORK.md)（完整框架与操作手册），然后按 `.trae/skills/` 里对应的技能执行。
> **只要本轮涉及 Supabase / 数据库 / 登录 / 工单 / 专栏 / 后端字段，必须再读 [`SUPABASE_GUIDE.md`](SUPABASE_GUIDE.md)**（接入 SQL 环境后的工作规范、迁移顺序、加功能清单与排错表）。

---

## 1. 这是什么

- **当前规模**：知识点 **292** 篇 · 题目 **200** 道 · **263** 个代码文件 · **7** 个大类（基础算法 / 动态规划 / 数据结构 / 图论 / 数学 / 字符串 / 实用工具）
- **形态**：单文件前端 `index.html`（自带 CSS + JS）+ 三个构建产物，**没有框架、没有 npm 依赖**；登录 / 工单 / 专栏走 Supabase 后端，其余仍是纯静态托管
- **在线**：GitHub Pages —— 仓库 `https://github.com/xesir/algorithm-knowledge-base.git`（分支 `master`）
- **本地**：`c:\Users\admin\Desktop\test\OIgit\algorithm-knowledge-base`

## 2. 怎么跑起来

```bash
# 1) 看网页：直接双击 index.html 即可（数据用 <script> 引入，不受 file:// 限制）
# 2) 改完内容后（每次都要）：
node tools/lint.js      # 内容门禁：error 必须为 0
node build.js           # 生成 data.js / code_data.js / problems_data.js
# 3) 浏览器 Ctrl+F5 强制刷新（data.js 会被缓存）
```

> 本机可能没把 `node` 加进 PATH：Trae/终端里能直接跑就用 `node`；否则用绝对路径或先装 Node LTS。
> `g++`（对拍用）：`C:\CSP_SIM\tools\mingw64\bin\g++.exe`。

## 3. 数据流（一张图记住）

```
content/*.md ─┐
problems/*.md ─┼─► node build.js ─┬─► data.js          KNOWLEDGE_DATA + 分类元数据
knowledge_graph.json ─┘            ├─► problems_data.js PROBLEMS_DATA
各分类/*.cpp ──────────────────────┴─► code_data.js     CODE_DATA（按 codePath 索引）
                                                   │
                                                   ▼
                    index.html（KaTeX 三步法渲染公式 + highlight.js 高亮代码）
```

**产物不可手改**：`data.js` / `code_data.js` / `problems_data.js` 是构建产物，下次构建会被覆盖。**唯一真相是 `content/`、`problems/`、`knowledge_graph.json`、各分类 `.cpp`。**

## 4. 目录速览

| 路径 | 是什么 |
|---|---|
| `index.html` | 前端单文件（页面布局、KaTeX 三步法、标签筛选、搜索、hash 路由） |
| `content/*.md` | **知识点源文件**（frontmatter + 7/8 章正文）；`content/<id>--作者.md` 是该知识点的**其他作者版本**，详情页顶部可切换 |
| `problems/*.md` | **题目源文件**（frontmatter + 题面/思路/代码解析） |
| `knowledge_graph.json` | 分类描述 + 前置/相关关系（`prerequisites` / `related`） |
| `各分类目录/*.cpp` | **你本人写的代码**（知识点示例、题目正解、暴力、造数据） |
| `build.js` | 构建脚本（扫描 → 解析 frontmatter → 读 .cpp → 生成三个产物） |
| `tools/lint.js` | **内容门禁**（E0xx 错误必须清零；W0xx 建议修） |
| `tools/new-kp.js` / `new-problem.js` | 脚手架：生成 md 骨架 + 只含任务卡注释的代码文件 + 注册图谱 |
| `templates/` | 知识点 / 题目模板 |
| `docs/内容质量标准.md` | A/B/C 三级标准与硬性底线 |
| `docs/网页版总结提示词.md` | 在网页版（DeepSeek 等）提问与总结成笔记的提示词 |
| `docs/让AI了解本站-提示词.md` | **给 AI 的入项提示词**（让新会话快速读懂本站并会干活）+ 理解自检 5 问 |
| `docs/四个技能-调用提示词.md` | **四个技能怎么"喊"**：触发词、可照抄的调用模板、兜底句、元数据速答卡 |
| `.trae/skills/` | **四个能力技能**（见下） |
| `.trae/rules/project_rules.md` | Trae 原生项目规则 |
| `AGENTS.md` / `PROJECT_FRAMEWORK.md` | AI 入口 / 框架与操作手册 |
| `SUPABASE_GUIDE.md` | **Supabase 接入环境工作指南**：迁移顺序（phase2→6）、数据模型与 RLS、审批自动入库、加新功能清单、测试与排错 |

## 5. 四个能力（都能直接让 AI 执行）

| 能力 | 你说什么 | 技能文件 |
|---|---|---|
| **添加知识点** | "这个文件夹是新的知识点，帮我入库" | [`.trae/skills/add-knowledge/SKILL.md`](.trae/skills/add-knowledge/SKILL.md) |
| **添加题目** | "这题帮我加进题目专辑" | [`.trae/skills/add-problem/SKILL.md`](.trae/skills/add-problem/SKILL.md) |
| **修改知识点 / 题目** | "XX 那条写错了，应该是……" | [`.trae/skills/edit-content/SKILL.md`](.trae/skills/edit-content/SKILL.md) |
| **构建并上传 GitHub** | "改完了，更新网站 / 上传" | [`.trae/skills/release-github/SKILL.md`](.trae/skills/release-github/SKILL.md) |
| **后台上传（仅限明确指令）** | **必须原话包含「此次为后台上传」** | [`.trae/skills/admin-upload/SKILL.md`](.trae/skills/admin-upload/SKILL.md) |

> 后台上传直接调用数据库 RPC `admin_publish_column`，不生成工单、不走审批；字段语义与投稿/修改工单一致，并用 `expected_updated_at` 防覆盖。未说「此次为后台上传」时禁止使用。

**我的输入习惯（技能都按这个约定）**：我会丢**一个文件夹**过来，里面通常三个文件 ——

```
任意文件夹/
├── 题目.md / 题目.txt     ← 只有题目才有；知识点没有这个文件
├── 代码.cpp               ← 我本人写的实现（初赛笔记类知识点可以没有）
└── 思路.md / 思路.txt     ← 我的思路总结（一般是网页版总结出来的笔记）
```

修改类需求则是：**我发现哪里错了，把错的地方和正确说法发给你**。

## 6. 三条铁律（违反任何一条都是失败）

1. **不代写解题代码**：所有 `.cpp`（知识点示例、题目正解、暴力、造数据）由我本人写。AI 只做讲解、审查、指出 bug 与方向、写对拍脚本框架。
2. **改完必须过门禁**：`node tools/lint.js`（error 必须 0）→ `node build.js`。
3. **内容源是唯一真相**：`data.js` / `code_data.js` / `problems_data.js` 是产物，永不手改。

细则、字段表、章节规范、常见陷阱全部在 [`PROJECT_FRAMEWORK.md`](PROJECT_FRAMEWORK.md)。

## 7. 想在新环境继续维护

需要的最小集合：本仓库 + Node（跑 `build.js`/`tools/*.js`）。
如果 `.trae/skills/` 不被你的工具识别（比如换到 Claude Code / Codex），把 `AGENTS.md` 作为规则文件喂给 AI 即可——它会把 AI 引到 `.trae/skills/` 与 `PROJECT_FRAMEWORK.md`。

---

## 备注（2026-10-25 追加）

> 以下内容为**追加**，上文原始文字一字未改。

- **本次长对话的完整纪要**（更新日志 / 全部修改标记 / 不可违背的要求 / 当前「加知识点、加题目」的最新步骤 / 已知问题 / 踩坑表）见
  [`docs/会话纪要-2026-10-25.md`](docs/会话纪要-2026-10-25.md)。**新会话请先读这份文件，再读 AGENTS.md。**
- 新增约定：**本 README.md 只允许在文件末尾追加「备注」，不得删除或改动原文任何内容。**
- 本轮新增能力：知识点详情页「🌌 星图」、题目页「🌸 打开维恩图」；难度体系已统一为洛谷九档并新增 `cfRating` 难度评分字段。

## 备注（2026-10-25 · 仓库迁移与线上地址）

- 仓库已迁移到 `https://github.com/xesir/algorithm-knowledge-base.git`（分支 `master`）。
- 线上地址改为 `https://xesir.github.io/algorithm-knowledge-base/`。
- 上文第 12 行的旧仓库地址不再使用，以上述新地址为准。
- 部署后若出现「库文件加载失败」，属于 Pages 部署或浏览器缓存窗口；页面已提供「强制刷新（跳过缓存）」按钮，静态资源引用也已加版本号。

## 备注（2026-10-29 · 会话纪要格式与注意点）

- 本轮完整纪要见 [`docs/会话纪要-2026-10-29.md`](docs/会话纪要-2026-10-29.md)（多作者合并 / 题目星图 / 实用工具大类 / 踩坑表）。

**会话纪要的格式（每轮结束时新写一份，不覆盖旧文件）**

| 项 | 约定 |
|---|---|
| 路径 | `docs/会话纪要-YYYY-MM-DD.md`；同一天多次则追加小节，不新建同名文件 |
| 标题 | `# 会话纪要 · YYYY-MM-DD（主题，3~5 个关键词）` |
| 开头引用块 | 说明这是「压缩台账」、与 `AGENTS.md` 冲突时以三条铁律为准、与用户要求冲突时必须询问用户、本文件只记事实不作规则来源 |
| 第 0 节 | 一句话现状：规模数字、门禁结果、构建结果、作者列表、提交号、未完成项 |
| 第 1 节 | 不可违背的要求（表格，#/要求/说明），只增不改，新条目注明「本轮新增」 |
| 第 2 节 | 本轮所有修改标记：按「前端 / 构建与门禁 / 图谱 / 新增知识点 / 新增题目 / 大类重组 / 合并外部内容 / 署名变更」分子节，逐文件列「改了什么」 |
| 第 3 节 | 现在怎么加知识点 / 加题目 / 加星图关系 / 改已有内容（可直接照抄执行的步骤与命令） |
| 第 4 节 | 常用命令与环境备忘（node 绝对路径、缺 g++、PowerShell 限制、git 身份、本地预览、Pages 缓存） |
| 第 5 节 | 待办 / 已知问题，用 `- [ ]` checkbox，确保下轮能直接接着做 |
| 第 6 节 | 附：本轮踩过的坑，表格三列「现象 / 原因 / 解法」 |

**写纪要的注意点**

- **只记事实与结论**：不贴聊天过程、不复述寒暄、不粘贴大段代码（代码给路径和章节即可）。
- **数字必须来自实际输出**：知识点数、题目数、error/warning 数一律照抄最近一次 `node build.js` / `node tools/lint.js` 的结果，严禁凭印象估算。
- **改写型任务要写清映射**：如「焚风 → Fohen」「9 大类 → 7 大类」，用表格列出旧值/新值，便于回溯。
- **合并外部内容要写清来源与排除项**：来源路径、授权说明、收录清单、排除清单（游记/日常）、`legacy` 标记规则。
- **踩坑表只写可复现的因果**：一条现象对应一个原因和一个解法，不写「试了很多方法」之类的过程。
- **纪要不是规则**：需要长期生效的约束要同步进 `AGENTS.md` / `PROJECT_FRAMEWORK.md`，纪要只做历史台账。
- **旧纪要一律不改**：新会话读最近一份即可；跨纪要的长期结论以 `AGENTS.md` 为准。

## 备注（2026-11-01 · 临时文件清点与 6 个知识点入库）

- 本轮完整纪要见 [`docs/会话纪要-2026-11-01.md`](docs/会话纪要-2026-11-01.md)（临时文件复查 / 2阶前缀和与2阶差分 / A* / 分层图 / 反悔贪心 / 整除分块主版）。
- 规模：知识点 **285** 篇 · 题目 **198** 道 · **272** 个代码文件 · **7** 个大类；门禁 error 0 / warning 3。
- 未完成：`临时文件/Xesir.md/005.md`（P14367 帐篷）只有题面，待补思路与代码后再入库。

## 备注（2026-11-01 · 追加 CSP-S 2026 第一轮题解）

- 新增知识点 [`content/exam-csp-s-2026-round1--xesir.md`](content/exam-csp-s-2026-round1--xesir.md)（Xesir 作者版，归类 `实用工具 / 初赛指南 / 真题题解`）。
- 规模更新为知识点 **286** 篇 · 题目 **198** 道 · **272** 个代码文件 · **7** 个大类；门禁 error 0 / warning 3。

## 备注（2026-11-01 · 全栏目三级化与同题合并）

- 按「总述（一级）→ 知识点（二级）→ 子栏目（三级）」重构 7 个大类，父子关系写入 `knowledge_graph.json` 的 `parent`，前端在侧栏 / 总目录 / 分类概览按层级缩进，星图用紫色双箭头表示从属。
- 新增 10 个总览父页（DP 4、图论 4、基础算法 1、字符串 1）；已有总述（线段树/分块/背包/平衡树/可持久化、搜索/分治/贪心/排序/高精度、STL/调试/语法/随机化/IO/其他/初赛、数论/数学基础/矩阵）提升为父页；合并 10 组同题条目（数据结构 6 + DP 1 + 图论 2 + 数学 1）。
- 规模：知识点 **285** 篇 · 题目 **198** 道 · **259** 个代码文件 · **7** 个大类；门禁 error 0 / warning 3。
- 回档点：提交 `0a16a5b` + tag `backup-before-all-category-hierarchy` + `backup_AKB_20261101.zip`，详见 [`docs/会话纪要-2026-11-01.md`](docs/会话纪要-2026-11-01.md) 第 6 节。

## 备注（2026-11-01 · 新增/修改内容的必填信息）

现在新增一个知识点或题目，需要填的信息比早期更多。**操作前请先读 [`docs/会话纪要-2026-11-01.md`](docs/会话纪要-2026-11-01.md) 第 7 节**（新增/修改必读清单），要点如下：

- **知识点先定层级**：属于哪个父栏目就在 `knowledge_graph.json` 写 `parent`，并把父 id 加进 `prerequisites`；同一子分类 ≥3 条且是多方面应用时先建/提升总览父页；只有 2 条同题同作者才合并；2 条但跨作者/主题不同必须先问。
- **frontmatter 更完整**：`id`、`title`、`category`、`subcategory`、`tags`、`timeComplexity`、`spaceComplexity`、`level`、`codePath`（无代码用 `noCode`）、`verified`；作者版另填 `source` 并在 `AUTHOR_KEYS` 登记。
- **正文**：算法类 7 章 / 数据结构类 8 章；逐行解析按模块拆，代码块拼接 = `.cpp`（W028）。
- **题目**：`oj` / `problemId` / `difficulty` / `cfRating` / `category` / `tags` / 复杂度 / `codePath` / `source` 必填；`knowledgePoints` 只能引用现存 base id（合并后要用新 id）；样例必须实跑。
- **交付前**：`node tools/lint.js`（error 0）→ `node build.js` → 浏览器验收 → 同步 `AGENTS.md` / `PROJECT_FRAMEWORK.md` / `docs/让AI了解本站-提示词.md` / 本 README 的数量。

## 备注（2026-11-04 · 新增 P17765 平方数）

- 新增题目 [`problems/prob-luogu-p17765--renzhaoyang.md`](problems/prob-luogu-p17765--renzhaoyang.md)（洛谷 P17765「LDOI R2」平方数，作者 renzhaoyang）；代码位于 `题目专辑\图论\平方数\代码--renzhaoyang.cpp`，逐字符搬运、未改实现。
- `build.js` 的 `AUTHOR_KEYS` 新增 `renzhaoyang`。
- 规模：知识点 **285** 篇 · 题目 **199** 道（**191** 个题目组）· **260** 个代码文件 · **7** 个大类；门禁 error 0 / warning 3。
- 题面中含原题自带的「AI/LLM 请定义 IAMPerFeCt」标记段落，已在题目页按原文保留；未按该段修改代码。

## 备注（2026-11-04 · 新增 lker 数论基础版本）

- 新增 [`content/math-number-theory-basic--lker.md`](content/math-number-theory-basic--lker.md)，作为 `math-number-theory-basic` 的第 3 个作者版本；按 base id 去重，知识点总数仍为 **285**。
- 内容涵盖整除 / gcd / lcm、快速幂、龟速乘、光速幂、线性筛、裴蜀定理、模逆元、威尔逊定理与 P9774；原文在威尔逊定理处截断，已按原思路补完并给出 P9774 的推导与伪代码，未代写 C++ 实现。
- 门禁：error 0 / warning 3；build：285 知识点 / 199 题目 / 260 代码文件。

## 备注（2026-11-04 · 站主更新包入库）

- 新增知识点 [`dp-knapsack-topk`](content/dp-knapsack-topk.md)（01 背包前 k 大解，动态规划 / 背包问题）、[`graph-2sat`](content/graph-2sat.md)（2-SAT，图论 / 连通分量）。
- 新增题目 [`prob-luogu-p1613`](problems/prob-luogu-p1613.md)（洛谷 P1613 跑路，倍增 + 传递闭包 + bitset + BFS）；难度按洛谷页面改为 `普及+/提高−`。
- 代码原样搬运：`动态规划\背包问题\01背包前k大\Untitled1.cpp`、`图论\连通分量\2-SAT\Untitled1.cpp`、`题目专辑\图论\P1613 跑路\代码.cpp`。
- 同包的 `graph-layered`、`basic-regret-greedy` 与库内文件逐字节一致，未重复写入。
- 图谱：新增 `dp-knapsack-topk`（parent `dp-knapsack-overview`）与 `graph-2sat`（parent `graph-scc-overview`），related 已双向。
- 规模：知识点 **287** 篇 · 题目 **200** 道（**192** 个题目组）· **263** 个代码文件；门禁 error 0 / warning 3。

## 备注（2026-11-04 · 新增 lker 位运算版本）

- 新增 [`content/math-bit-operation--lker.md`](content/math-bit-operation--lker.md)，作为 `math-bit-operation` 的第 3 个作者版本；按 base id 去重，知识点总数仍为 **285**。
- 收录 P5514、P5651、P8445、P13552、P11008、CF1956D 六道题；原文无 C++ 代码，正文用伪代码拆解，未代写实现。P13552 的 `cur-1` 规则补了“全 1 位”边界，P11008、CF1956D 的构造与 DP 也做了展开。
- 门禁：error 0 / warning 3；build：285 知识点 / 199 题目 / 260 代码文件。

## 备注（2026-11-04 · dbywsc 讲义拆分入库）

- 将 `临时文件/dbywsc.md/讲义1.md` 按主题拆成 10 篇，全部以 `--dbywsc` 作者版本入库，`source: 'dbywsc'`，`noCode: true`。
- 新知识点（5 个）：`basic-binary-search`（二分查找与二分答案）、`dp-memo-search`（记忆化搜索）、`dp-linear-basic`（线性 DP 基础）、`basic-tricks-median`（中位数 01 转化 trick）、`gram-string-ops`（字符串常用操作）。
- 新增作者版本（5 个）：`ds-stl-associative--dbywsc`、`basic-bubble-select-sort--dbywsc`、`math-number-theory-basic--dbywsc`、`basic-bfs--dbywsc`、`basic-dfs--dbywsc`。
- 修复原讲义中的 HTML 转义（`&lt;` / `&gt;`）、伪代码缩进、缺失的字符串操作第 11 项，并补写线性 DP、记忆化搜索的推导与说明；原讲义中的代码片段保留为节选，未代写实现。
- `build.js` 的 `AUTHOR_KEYS` 新增 `dbywsc`；`knowledge_graph.json` 新增 5 个节点的 parent / prerequisites。
- 规模：知识点 **292** 篇 · 题目 **200** 道（**192** 个题目组）· **263** 个代码文件；门禁 error 0 / warning 3。

## 备注（2026-11-04 · 本轮会话纪要与备份）

- 本轮完整纪要见 [`docs/会话纪要-2026-11-04.md`](docs/会话纪要-2026-11-04.md)。
- 备份 tag：`backup-before-major-rework-20261104`；全量 zip：`..\backup_AKB_20261104.zip`（仓库全量，含 `.git`）。

## 备注（2026-11-06 · Supabase 投稿闭环联调通过 + 新增环境指南）

- 本轮完整纪要见 [`docs/会话纪要-2026-11-06.md`](docs/会话纪要-2026-11-06.md)。
- **新增指导文件 [`SUPABASE_GUIDE.md`](SUPABASE_GUIDE.md)**：涉及 Supabase / 数据库 / 登录 / 工单 / 专栏 / 后端字段的会话，**必须先读该文件**。其优先级低于 `AGENTS.md`、`.trae/rules/project_rules.md`、`README.md`、`PROJECT_FRAMEWORK.md`，高于 `docs/` 下的会话纪要与提示词。
- 数据库迁移已全部执行：phase4（`tickets.payload`）→ phase5（作者/单关系）→ phase6（多关系 / 标签库 / 匿名建议）。
- 联调结论：投稿提交、后台「通过并入库」、触发器自动写入 `columns`、标签并入 `tags`、多条关系落库均通过；测试期间产生的工单、专栏、测试账号与测试标签已清理。
- 修复：投稿表单「作者」下拉被 `sub-*` 自动生成专栏名覆盖，现优先取作者本人的专栏名。
- 规模：知识点 **292** 篇 · 题目 **200** 道（**192** 个题目组）· **263** 个代码文件；门禁 error 0 / warning 3。

## 备注（2026-11-06 · 「修改」工单与后台 diff）

- 新增迁移 [`supabase/phase7-column-edit-tickets.sql`](supabase/phase7-column-edit-tickets.sql)（**已在 SQL Editor 执行**）：
  - `submit_column_edit(p_key, p_password, p_content, p_note)` RPC：必须登录，并在函数内校验该专栏密码（特定 > 通用 > 无密码）；
  - 审批通过后由 `publish_submission_ticket()` 把修改后的 Markdown 写回 `columns.content`；
  - RLS 禁止 authenticated 直接 `insert type='edit'`，修改工单只能走 RPC。
- 新增迁移 [`supabase/phase8-column-edit-upload-flag.sql`](supabase/phase8-column-edit-upload-flag.sql)（**已应用**）：`submit_column_edit()` 增加 `p_uploaded` 参数，payload 记录 `uploaded`，供后台判断是否隐藏逐行 diff。
- `login.html`：工单类型新增「修改」，支持选择专栏（显示专栏名称）、输入专栏密码、验证并载入 Markdown 源码后修改提交；提交后进入待审批，不会立即生效。
- 修改工单的目标只列 `sub-*` / `col-*` 这类实际专栏，**排除 7 条作者占位专栏**；未设置密码的专栏选中后自动载入源码，可直接修改。
- 修改表单支持「下载当前源码 / 上传修改后的文件」（`.md` / `.markdown` / `.txt`，≤5 MB）；正文超过 10 万字符时跳过网页 textarea 渲染，下载到本地修改后上传，避免页面卡顿。走上传文件提交时后台不展示逐行 diff。
- `admin.html`：投稿工单可展开查看原文；修改工单默认展示逐行 diff（含新增/删除行数与修改处数），但**上传文件提交或修改点 > 5 处时改为只展示修改后全文**；所有待审批工单新增「编辑」，管理员可直接修改标题、备注、payload 与内容后再通过。
- `admin.html` 专栏管理同样支持「下载当前专栏 / 上传文件覆盖内容」，长文不再强制渲染进 textarea，保存时优先取上传内容。
- 专栏/知识点选择统一显示可读名称：`build.js` 新增产物 `titles.json`（知识点 id → 标题），投稿关系、后台关系、修改工单目标均优先显示名称而不是 `dp-xxxx` 这类 id。
- 新增 [`scripts/seed-columns-from-content.js`](scripts/seed-columns-from-content.js)：把 `content/` 与 `problems/` 中已有的 Markdown 批量生成 `columns` 种子 SQL（`supabase/seed-columns/01~16`，共 608 行：知识点 408 + 题目 200），按文件名归属作者，可重复执行；在 SQL Editor 按序号执行后，「修改」下拉才会出现这些 `col-*` 专栏。
- 规模不变：知识点 **292** 篇 · 题目 **200** 道（**192** 个题目组）· **263** 个代码文件；门禁 error 0 / warning 3。

## 备注（2026-11-07 · 审批后的修改 / 投稿实时覆盖到公开页）

- 新增迁移 [`supabase/phase9-published-columns-view.sql`](supabase/phase9-published-columns-view.sql)（**已应用**）：公开只读视图 `published_columns`，只暴露 `status='published'` 的 `col-*` / `sub-*` 专栏，并附带作者昵称。
- `build.js` 在 `data.js` 顶部写入 `DATA_BUILD_AT`（构建时间）与 `AUTHOR_KEYS`（文件名作者 key → 显示名）。
- `index.html` 打开后调用 `syncPublishedColumns()`：以 `updated_at > DATA_BUILD_AT` 增量拉取数据库专栏。
  - 修改工单审批后：覆盖对应知识点/题目（含指定作者版本）的正文；
  - 投稿工单审批后：新专栏（`sub-*`）自动追加到知识点或题目目录的「投稿」分组，可直接通过 URL 访问；
  - 打开页面同步一次，之后每 60 秒、切回前台时各同步一次，无需重新构建或刷新部署。
- 静态 Markdown 仍是构建期唯一内容源；数据库覆盖只发生在浏览器运行时。若先审批、后重新构建且 Markdown 未同步，重新构建会以 Markdown 为准（基线是构建时间）。
- 规模不变：知识点 **292** 篇 · 题目 **200** 道（**192** 个题目组）· **263** 个代码文件；门禁 error 0 / warning 3。

## 备注（2026-11-07 · 游客访问控制与「修改」工单元数据）

- 新增迁移 [`supabase/phase10-guest-access-edit-metadata.sql`](supabase/phase10-guest-access-edit-metadata.sql)（**已应用**）：
  - `published_columns` 视图增加 `locked`（特定密码优先，其次作者默认密码）；
  - `submit_column_edit()` 增加 `p_tags` / `p_category` / `p_difficulty`，payload 同时记录旧值；
  - 审批「修改」工单时把正文与标签 / 分类 / 难度一起写回 `columns`。
- 新增迁移 [`supabase/phase11-edit-column-title.sql`](supabase/phase11-edit-column-title.sql)（**已应用**）：`submit_column_edit()` 增加 `p_column_name`，payload 记录 `old_column_name`，审批时写回 `columns.column_name`。
- 新增迁移 [`supabase/phase12-author-default-passwords.sql`](supabase/phase12-author-default-passwords.sql)（**已应用**）：除 Xesir 外，作者默认专栏密码直接复制自 `auth.users.encrypted_password`（即作者登录密码）；Xesir 默认密码留空。当前 475 条专栏锁定、133 条 Xesir 专栏未锁定。
- `index.html` 增加「正在检查访问权限…」占位：密码状态加载完成前不渲染正文，避免拦截前闪现内容。
- `index.html` 访问规则：
  - 未登录游客可直接查看**无密码**知识点与题目；有密码的专栏只显示「请先登录」拦截，不提供密码输入；
  - 登录用户访问有密码的专栏时显示密码门，输入正确密码后本标签页内可继续查看；密码为空则无需输入；
  - 管理员（`profiles.role='admin'`）无需输入专栏密码，可直接查看任意作者的专栏；
  - 修改专栏同样要求登录 + 专栏密码（密码为空则无需输入）；
  - 密码状态来自 `published_columns.locked`，每 5 分钟与切回前台时补拉一次。
- `login.html` 修改工单：载入源码后可修改**标题、标签、所属大类、难度（题目）**，提交后进入待审批；`admin.html` 编辑工单弹窗可同步调整，审核详情显示「旧值 → 新值」。
- 新增迁移 [`supabase/phase13-login-by-identifier.sql`](supabase/phase13-login-by-identifier.sql)（**已应用**）：`resolve_login_email()` 支持邮箱 / QQ / 洛谷 / CF / 昵称任意一个 + 密码登录；密码错误返回 `null`，不泄露账号是否存在。
- 修改工单与专栏管理的 Markdown 源码默认不写入文本框，点「显示 Markdown 源码」后才展开，避免长文卡顿；提交/保存时使用内存中的源码或文本框内容。
- 说明：密码门是前端展示层控制，正文本身仍存在于公开的 `data.js`，无法阻止直接读取静态文件。

## 备注（2026-11-08 · 作者贡献度接入修改工单）

- 新增迁移 [`supabase/phase14-contribution-view.sql`](supabase/phase14-contribution-view.sql)（**待用户在 SQL Editor 执行**）：
  - `tickets.reviewed_at` + 审批时间触发器，用于判断同一作者对同一专栏的最新有效修改；
  - 公开只读视图 `author_edit_credits`：只含 `type='edit'`、`status='approved'`、`columns.status='published'` 且 `column_key` 非 `sub-%` 的工单，按 `(user_id, column_key)` 去重取最新；
  - 只暴露作者名、专栏键/名、分类、kind、难度、优先级、新旧字符数、自改标记与审批时间，不含正文与联系方式。
- `build.js`：知识点 `versions[]` 新增 `level`（A/B/C），供难度加权使用。
- `index.html` 作者专栏改为加权贡献：
  - 新建 1 篇 = 1.0；
  - 修补 1 处 = `0.4 × 难度系数 × 体量系数 × 优先级系数 × 自改系数(0.25)`，单专栏上限 0.8；
  - 贡献率 = 个人加权分 ÷ 全站加权分；
  - 作者主页新增「🛠 修补记录」；`sub-*` 未同步投稿暂不计入修补。
- 作者名匹配：`profiles.nickname` 与静态作者显示名不一致时，前端按 `AUTHOR_ALIASES` 临时映射并在控制台 `console.warn`。
- 验证：`node tools/lint.js --quiet` → error 0 / warning 3；`node build.js` → 292 知识点 / 200 题目 / 192 题目组 / 263 代码文件。
- 下一步：在 Supabase SQL Editor 执行 phase14，然后刷新作者专栏；执行前页面会提示修补数据未加载，仅显示新建贡献。
- 新增迁移 [`supabase/phase15-author-avatars.sql`](supabase/phase15-author-avatars.sql)（**待用户在 SQL Editor 执行**）：公开视图 `author_profiles`，作者列表 / 作者主页 / 密码门优先显示头像；头像为空或视图未执行时回退首字母。
- 作者页修补数据改为 **30 秒自动刷新**；新建计数仍来自静态 `data.js`，需要重新构建并部署后才会更新。点击需要密码的知识点/题目时，密码门会显示「作者：X」。
- 新增迁移 [`supabase/phase16-author-profile-fields.sql`](supabase/phase16-author-profile-fields.sql)（**待用户在 SQL Editor 执行**）：`profiles.signature` / `profiles.honors`；作者在 `admin.html`「个人设置」编辑签名与战绩（战绩每行一条），作者页展示，作者本人访问自己的专栏时出现「编辑签名 / 战绩」入口。

## 备注（2026-11-09 · 已有专栏投稿 / 头像回退 / 管理员标识）

- 新增迁移 [`supabase/phase17-existing-column-version.sql`](supabase/phase17-existing-column-version.sql)（**已应用**，2026-11-09 用户确认）：重建 `publish_submission_ticket()`，投稿工单 payload 带 `version_of` 时不再新建 `sub-*` 专栏，而是生成作者版本 `col-<base>--<作者昵称>`，标题为「原标题 · 作者昵称」，分类 / 题型 / 难度 / 关系继承基础专栏；另加 `(split_part(column_key,'--',1))` 索引。
- 新增迁移 [`supabase/phase18-author-admin-badge.sql`](supabase/phase18-author-admin-badge.sql)（**已应用**，2026-11-09 用户确认）：重建 `author_profiles` 公开视图，增加 `role` 字段，供前端展示管理员标识。
- `login.html` 投稿新增「投稿方式」：
  - 新建专栏：沿用原表单（栏目名 / 大类 / 关系 / 题目字段）；
  - 投稿已有专栏：下拉选择基础专栏（按分类分组，共 485 个），提交 `version_of` 工单，由审批触发器生成新作者版本；
  - 若当前账号在该专栏下已有自己的版本，提交时自动提示并切换为「修改工单」，载入该版本源码。
- `admin.html` 编辑投稿工单时，顶部提示「该工单是『为已有专栏添加新作者版本』」，审核详情显示对应基础专栏。
- `index.html`：
  - 数据库返回的作者版本（`col-<base>--<作者昵称>`）会追加到对应知识点的 `versions[]`，无需重新构建即可看到；
  - 作者头像有图片时背景透明，仅无头像时使用首字母 + 纯色（`#6366f1`）填充；
  - `profiles.role = 'admin'` 的账号在作者列表、作者主页、密码门显示「管理员」徽章。

## 备注（2026-11-11 · 修改工单关系 / 星图难度配色）

- 新增迁移 [`supabase/phase19-edit-relations.sql`](supabase/phase19-edit-relations.sql)（**待用户在 SQL Editor 执行**）：
  - `published_columns` 增加 `relations` / `relations_override`，前端可把数据库关系同步到星图（包括人工清空）；
  - `submit_column_edit` 增加 `p_relations`（`null` 不改、`[]` 清空），payload 记录 `relations` / `old_relations` 与旧字段；
  - 审批通过后写回 `columns.relations` / `relation_type` / `relation_target` / `parent_key` / `relations_override`。
- `login.html` 修改工单：
  - 可编辑题目难度（兼容早期没有 `kind` 字段的题目专栏）；
  - 新增关系编辑（关联 / 前后置 / 父子），可增删；
  - 新增「🌌 预览星图」，按当前表单关系渲染预览，题目节点按难度着色；
  - phase19 未执行时自动回退为旧 RPC，并提示关系字段待生效。
- `admin.html` 审核修改工单时同样可编辑关系，详情显示「关系：旧值 → 新值」。
- `index.html`：
  - 星图题目节点按难度颜色显示，图例改为对应难度色块；
  - 题目专辑统计卡改为按洛谷档位逐档计数（含颜色圆点）；
  - 数据库 `relations` 写回静态图（sequence→前置、related→关联、parent-child→父栏目；题目→知识点）。

## 备注（2026-11-09 · 文档事实修正）

- 按用户 2026-11-09 授权，只修正事实性偏差，不改动三条铁律、数据流与章节规范。
- 顶部「当前规模」由 `207 篇 / 67 道 / 9 个大类（含输入输出、初赛笔记、语法技巧）` 修正为 `292 篇 / 200 道 / 263 个代码文件 / 7 个大类（含实用工具）`；本地路径改为 `c:\Users\admin\Desktop\test\OIgit\algorithm-knowledge-base`。
- `PROJECT_FRAMEWORK.md` 的 `category` 说明由「8 个之一」修正为「7 个之一」并补「实用工具」；项目根路径同步更新。
- `AGENTS.md` 只改项目根路径，三条铁律未动。
- `docs/四个技能-调用提示词.md` 的示例目录改为 `临时文件\<算法名>`。
- `SUPABASE_GUIDE.md` 的 node 路径统一为 2026-11-08 实测的 v22.14.0 路径；phase14–18 迁移记录更新为「已应用（2026-11-09 用户确认）」。
- 本轮完整纪要见 [`docs/会话纪要-2026-11-09.md`](docs/会话纪要-2026-11-09.md)。

## 备注（2026-11-11 · 修复重新构建后投稿专栏被隐藏）

- 现象：6 条已审批投稿（`sub-20`～`sub-25`）在另一次 `node build.js` 后从公开页消失。
- 原因：`syncPublishedColumns()` 只按 `updated_at > DATA_BUILD_AT` 增量查询；投稿审批时间早于新构建时间，`sub-*` 被整体跳过。
- 修复：`index.html` 的查询改为 `updated_at > DATA_BUILD_AT OR column_key like 'sub-%'`，`sub-*` 始终同步；`dbSince` 只向前推进，避免被旧投稿时间回退。
- 验证：重新 build 后打开首页，控制台显示「已从数据库同步 6 条专栏更新」，6 个题名均在题目列表。

## 备注（2026-11-11 · 后台上传技能与防覆盖）

- 新增迁移 [`supabase/phase20-guard-overwrites.sql`](supabase/phase20-guard-overwrites.sql)（**待用户在 SQL Editor 执行**）：
  - 工单审批防覆盖守卫：修改工单校验 `payload.base_updated_at`；重复作者版本拒绝覆盖；`sub-<ticket_id>` 被其他来源占用时拒绝；
  - 后台上传 RPC `admin_publish_column(jsonb)`：insert 拒绝覆盖已有 `column_key`；update 必须带 `expected_updated_at`；作者/标签/关系/父栏目/锁定与工单路径一致。
- 新增 [`/.trae/skills/admin-upload/SKILL.md`](.trae/skills/admin-upload/SKILL.md)：**只有用户原话包含「此次为后台上传」时才调用**；直接写数据库、不生成工单、不走审批。
- 已在事务中验证四类冲突（重复 insert / 过期 update / 过期修改工单 / 重复作者版本），验证后回滚；正式执行前不要直接 `insert/update columns`。

## 备注（2026-11-12 · 专栏/题目元数据便捷修改）

- 详情页 Meta 栏新增「✏️ 便捷修改」，只改非正文部分：标题、分类、难度（题目）、标签、关系。
- 管理员保存后直接写库并刷新；普通登录用户保存后生成 `type='edit'` 的待审核工单，审批通过才生效。
- 新迁移 [`supabase/phase21-meta-edit.sql`](supabase/phase21-meta-edit.sql)（**待用户在 SQL Editor 执行**）：
  - `admin_update_column_meta(jsonb)`：校验 `profiles.role='admin'` 与 `expected_updated_at`；
  - `submit_column_meta_edit(...)`：普通用户提交元数据工单，payload 带正文快照与 `base_updated_at`。
- DB 关系为空且未人工覆盖时，弹窗回退预填静态 `prerequisites / related / parent`（题目为 `knowledgePoints`）。
- 已在事务中验证：非管理员拦截、管理员直改、普通工单生成、审批后正文不变且元数据生效；验证后回滚。

## 备注（2026-11-12 · 便捷修改扩展字段与元数据贡献）

- 「便捷修改」新增可改字段：CF 评分 / OJ / 题号（题目）、时间复杂度 / 空间复杂度（知识点与题目）。
- 新增迁移 [`supabase/phase22-meta-fields-credit.sql`](supabase/phase22-meta-fields-credit.sql)（**待用户在 SQL Editor 执行**）：
  - `columns` 增加 `cf_rating / oj / problem_id / time_complexity / space_complexity / meta_override`；
  - 两个 RPC 支持新字段，审批后由触发器写回；管理员直改额外留一条 approved 审计工单；
  - `author_edit_credits` 排除 `meta_only=true`，新增公开视图 `author_meta_credits`。
- 便捷修改计入贡献：每条固定 **0.02**，按「作者 + 专栏」去重；作者页新增「元数据修改」计数，并与修补记录同列展示。
- 已在事务中验证：管理员直改、普通用户 12 参工单、审批写回、两个贡献视图；验证后回滚。
