# 算法知识点知识库 · 项目说明

> 一个个人维护的**算法/知识点查询网站**：内容源是 Markdown，用 `build.js` 生成前端数据，纯静态托管在 GitHub Pages。
> **给 AI 的一句话**：先读 [`AGENTS.md`](AGENTS.md)（铁律 + 入口），再读 [`PROJECT_FRAMEWORK.md`](PROJECT_FRAMEWORK.md)（完整框架与操作手册），然后按 `.trae/skills/` 里对应的技能执行。

---

## 1. 这是什么

- **当前规模**：知识点 **207** 篇 · 题目 **67** 道 · **9** 个大类（基础算法 / 动态规划 / 数据结构 / 图论 / 数学 / 字符串 / 输入输出 / 初赛笔记 / 语法技巧）
- **形态**：单文件前端 `index.html`（自带 CSS + JS）+ 三个构建产物，**没有框架、没有 npm 依赖、没有后端**
- **在线**：GitHub Pages —— 仓库 `https://github.com/World-Needs-Sunday/algorithm-knowledge-base.git`（分支 `master`）
- **本地**：`C:\Users\penti\Desktop\算法 - 副本`

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

## 5. 四个能力（都能直接让 AI 执行）

| 能力 | 你说什么 | 技能文件 |
|---|---|---|
| **添加知识点** | "这个文件夹是新的知识点，帮我入库" | [`.trae/skills/add-knowledge/SKILL.md`](.trae/skills/add-knowledge/SKILL.md) |
| **添加题目** | "这题帮我加进题目专辑" | [`.trae/skills/add-problem/SKILL.md`](.trae/skills/add-problem/SKILL.md) |
| **修改知识点 / 题目** | "XX 那条写错了，应该是……" | [`.trae/skills/edit-content/SKILL.md`](.trae/skills/edit-content/SKILL.md) |
| **构建并上传 GitHub** | "改完了，更新网站 / 上传" | [`.trae/skills/release-github/SKILL.md`](.trae/skills/release-github/SKILL.md) |

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
