-- ============================================================
-- 后台上传：lker《图的连通性问题浅谈》PPT 拆分为 4 篇知识专栏
-- 作者：lker
-- 方式：直接调用 public.admin_publish_column(jsonb)（不走工单、不走审批）
-- 前置：phase20-guard-overwrites.sql 已执行；作者 lker 已 active
-- key：
--   col-graph-tarjan-scc--lker
--   col-graph-scc-dag-dp--lker
--   col-graph-e-dcc-condensation--lker
--   col-graph-v-dcc--lker（新 base，静态侧 content/graph-v-dcc--lker.md）
-- 同步：正文与静态 Markdown 完全一致；parent_key 统一挂 col-graph-scc-overview
-- 可重复执行：key 不存在走 insert，已存在则读取 updated_at 走 update
-- 在 Supabase SQL Editor 整段执行。
-- ============================================================

-- ---------- 执行前检查 ----------
select nickname, status, role
from public.profiles
where nickname = 'lker';

select column_key, column_name, status, updated_at
from public.columns
where column_key in (
    'col-graph-tarjan-scc--lker',
    'col-graph-scc-dag-dp--lker',
    'col-graph-e-dcc-condensation--lker',
    'col-graph-v-dcc--lker'
)
order by column_key;

select column_key, column_name
from public.columns
where column_key in ('col-graph-scc-overview', 'col-graph-tarjan-scc', 'col-graph-e-dcc-condensation', 'col-graph-scc-dag-dp')
order by column_key;

-- ---------- 写入 4 条 lker 作者版本 ----------
do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "col-graph-tarjan-scc--lker",
  "author_name": "lker",
  "column_name": "Tarjan 强连通分量 · lker",
  "description": "NOI 大纲复习 · 图的连通性问题浅谈（lker PPT 拆分）",
  "content": "## 算法原理\n\n有向图的连通性比无向图麻烦：一条边只能顺着走，两个点互相可达才有意义。**强连通分量（Strongly Connected Component，SCC）** 就是有向图中的极大强连通子图：分量内任意两点互相可达，再加入任何一个点都会破坏这个性质。\n\n连通分量本身只是一个工具，它的价值在于**转化**：把有向图上的环缩成 DAG，后面的拓扑排序、DAG 上 DP 才有地方落脚。这一版内容据 lker《图的连通性问题浅谈》整理，先把 SCC 的判定讲透，再在缩点一篇里接上 DAG。\n\n### 从 DFS 生成树说起\n\n在图上做一次深度优先搜索，按访问顺序保留走过的边，就得到一棵 **DFS 生成树**。有向图的边相对这棵树可以分为四类：\n\n| 边的类型 | 定义 | 对 SCC 的作用 |\n|---|---|---|\n| 树边 | DFS 生成树内部的边 | 构成搜索骨架 |\n| 前向边 | 从祖先直接指向后代、跳过若干树边 | 一般不提供额外信息 |\n| 横叉边 | 从一个子树指向另一个已经搜过的子树 | 指向已处理 SCC 时可直接忽略 |\n| 后向边 | 从后代指回祖先 | 提供“绕回去”的能力，是成环的关键 |\n\n真正有用的是**后向边**和**横叉边**。后向边让后代可以回到祖先，于是“后代 → 祖先 → 后代”形成回路；横叉边如果指向一个仍在栈中的点，本质上也会被当作前向边处理，指向已经处理完的 SCC 则没有意义。\n\n### SCC 的判定点在哪里\n\n一个很直接的事实：出现后向边时，后代能回到祖先，祖先又能顺着树边回到后代，所以这条路径上的所有点两两可达，属于同一个 SCC。问题于是变成：**哪个点是这个 SCC 的“最高点”**？\n\n答案是：在同一个 SCC 里，**最早被遍历到的那个祖先**就是最高点。反证一下：如果它不是所在 SCC 的最高点，那么它向上还应该有一条后向边把它和更高的点连在同一分量里；但按定义它已经是最早被访问的点，上面的点还没有被访问，矛盾。因此它一定是所在 SCC 的最高点。\n\n换成可计算的语言：对每个点 $u$，记它子树内的点（沿树边向下，最多再走一条横叉边）能到达的最小时间戳。如果这个最小值就是 $u$ 自己的时间戳，说明 $u$ 的子孙最多只能回到 $u$，$u$ 就是所在 SCC 的最高点。\n\n### dfn 与 low\n\n- $\\mathrm{dfn}[u]$：DFS 时间戳，第一次访问 $u$ 时递增分配。祖先的 $\\mathrm{dfn}$ 一定小于后代的 $\\mathrm{dfn}$。\n- $\\mathrm{low}[u]$：从 $u$ 的子树出发，沿树边向下、最多再走一条非树边，能到达的最小 $\\mathrm{dfn}$。\n\n转移分两类：\n\n- 对树边 $u\\to v$：先递归 $v$，再用 $\\mathrm{low}[v]$ 更新 $\\mathrm{low}[u]$；\n- 对已经访问过且**仍在栈中**的点 $v$：用 $\\mathrm{dfn}[v]$ 更新 $\\mathrm{low}[u]$。\n\n当 $\\mathrm{low}[u]=\\mathrm{dfn}[u]$ 时，栈顶到 $u$ 之间的所有点恰好构成一个 SCC。\n\n### 为什么用栈\n\nSCC 的判定需要“等所有后代都搜完”才能下结论，这天然有后效性；栈正好保存了当前 DFS 路径上尚未归属的候选点。判定点 $u$ 出现后，从栈顶不断弹出，直到把 $u$ 也弹出，这一段就是完整的 SCC。\n\n把已访问点分成三类，可以避免重复处理：\n\n1. **在栈中、dfn 已更新**：搜到了仍在当前 DFS 链上的祖先，是前向边（或树边回溯），用 $\\mathrm{dfn}$ 更新 low；\n2. **不在栈中、dfn 未更新**：还没搜过，是后代，递归处理；\n3. **不在栈中、dfn 已更新**：属于已经处理完的 SCC，是横叉边，直接忽略。\n\n还有一个容易绕进去的问题：在栈中、dfn 已更新的点有没有可能是横叉边？如果右子树指向左子树，而左子树已经处理完，它就不在栈中；如果左子树还在栈中，说明左子树是当前点的祖先方向，这条边应视为前向边而不是横叉边。两种情况都不会破坏上面的分类。\n\n## 核心公式 / 状态定义与转移方程\n\n设 $T_u$ 为 $u$ 在 DFS 树上的儿子集合，$B_u$ 为从 $u$ 出发、指向仍在栈中的已访问点的边集合，则\n\n$$\n\\mathrm{low}[u]=\\min\\left(\\mathrm{dfn}[u],\\ \\min_{v\\in T_u}\\mathrm{low}[v],\\ \\min_{v\\in B_u}\\mathrm{dfn}[v]\\right).\n$$\n\n判定：\n\n$$\nu \\text{ 是所在 SCC 的最高点}\\iff \\mathrm{low}[u]=\\mathrm{dfn}[u].\n$$\n\n伪代码如下（只保留结构，完整实现由使用者本人完成）：\n\n```\ntarjan(u):\n    dfn[u] = low[u] = ++timer\n    stack.push(u); in_stack[u] = true\n    for each edge (u, v):\n        if dfn[v] == 0:\n            tarjan(v)\n            low[u] = min(low[u], low[v])\n        else if in_stack[v]:\n            low[u] = min(low[u], dfn[v])\n    if low[u] == dfn[u]:\n        repeat:\n            y = stack.pop(); in_stack[y] = false\n            把 y 归入当前 SCC\n        until y == u\n```\n\n一个实现细节：递归返回后更新 low 时，对**祖先方向**用 $\\mathrm{dfn}[v]$ 而不是 $\\mathrm{low}[v]$。两者在当前模板里结果相同，但写成 $\\mathrm{dfn}$ 在其它 Tarjan 变体（例如割点、点双）里更不容易出错，可移植性更好。\n\n## 逐行代码解析\n\n这一版没有配套的 `.cpp`，只按模块说明实现要点；下面的片段是结构示意，不是可直接提交的完整程序。\n\n### 模块一：邻接表与时间戳\n\n用 `h[u]` 存第一条边，`ne[i]` 存下一条边，`to[i]` 存终点，`idx` 递增分配边编号。`dfn`、`low` 与 `timer` 一起初始化；`dfn[u] == 0` 用来判断是否访问过。\n\n### 模块二：递归与 low 的更新\n\n进入 `tarjan(u)` 时先压栈、置 `in_stack[u] = true`，再枚举出边。树边递归后取 `min(low[u], low[v])`；已访问且在栈中的点取 `min(low[u], dfn[v])`。这两行的顺序不能混：树边要等子树搜完，非树边只认栈内的点。\n\n### 模块三：弹栈与编号\n\n当 `low[u] == dfn[u]` 时，新建一个 SCC 编号，循环弹栈直到弹出 `u`；弹出的点同时清掉 `in_stack`，并记录它属于哪个 SCC。这样每个点只会被弹出一次，总复杂度线性。\n\n### 模块四：多起点与输出\n\n图不一定连通，主函数要对每个 `dfn[i] == 0` 的点调用一次 `tarjan(i)`。如果题目要求按升序输出每个分量（例如洛谷 B3609），弹栈后还要对每个 SCC 内部排序；输出时按编号顺序逐行给出。\n\n## 复杂度分析\n\n每个点入栈、出栈各一次，每条边被枚举一次，因此时间复杂度为 $O(n+m)$。\n\n空间上需要邻接表 $O(n+m)$、`dfn/low/in_stack` 各 $O(n)$、栈与 SCC 容器 $O(n)$，合计 $O(n+m)$。\n\n## 适用场景\n\n- 有向图的环检测、判断整张图是否强连通；\n- 缩点后转 DAG：最长路、最大权路径、可达性计数、DAG 上 DP；\n- 2-SAT 的建图与判定；\n- 需要把“环上的点可以随便走”这一性质显式化的题目。\n\n看到有向图、看到“互相可达”“环”“可以绕回去”这类信号，就可以先想 SCC 缩点。\n\n## 常见陷阱与注意事项\n\n- **只从一个点开始 DFS**：图不连通时会漏掉整个分量，必须枚举所有未访问点。\n- **非树边不看是否在栈中**：指向已处理 SCC 的横叉边如果也拿来更新 low，会把不同分量错误合并。\n- **祖先方向用 low 更新**：当前模板里可能碰巧正确，但迁移到割点/点双时容易出错，统一写 `dfn` 更稳。\n- **自环与重边**：自环不影响 SCC 划分，但会让边数变多；重边按多条边处理即可，不要误判成环之外的东西。\n- **递归深度**：链状有向图深度可达 $n$，递归实现要注意栈空间；必要时改迭代或开大栈。\n- **输出顺序**：B3609 要求分量内升序、分量之间按编号，弹栈后要额外排序，不能直接按弹栈顺序输出。\n- **SCC 与边双混淆**：SCC 针对有向图，边双针对无向图；两者的 low 更新和判定条件不同。\n- **编号从 1 开始**：`dfn` 用 0 表示未访问，节点编号最好也从 1 开始，避免 `dfn[0]` 的歧义。\n\n## 对比与扩展\n\n| 算法 | 思路 | 复杂度 | 特点 |\n|---|---|---|---|\n| Tarjan | 一次 DFS + 栈 + dfn/low | $O(n+m)$ | 常数小，可同时求 SCC 编号 |\n| Kosaraju | 正图 DFS 逆序 + 反图 DFS | $O(n+m)$ | 思路直观，需要建反图，跑两遍 |\n\nTarjan 与 Kosaraju 都能求 SCC；前者更适合顺手做缩点和后续 DP，后者在只需要“分量划分”时更好写。\n\n再往外扩展：\n\n- **SCC 缩点**：把每个分量压成一个点，原图变成 DAG，是下一篇的主角；\n- **2-SAT**：把布尔变量拆成两个点，用 SCC 判断是否存在可行赋值；\n- **边双 / 点双**：把“边或点删掉是否还连通”作为新的等价关系，判定条件分别是桥和割点。\n\n连通性问题的共同套路是：先找一个“分量”把图压缩，再在压缩后的 DAG 或树上做问题。SCC 是这条路线里最基础的一站。",
  "category": "图论",
  "tags": [
    "图论",
    "强连通分量",
    "Tarjan",
    "DFS",
    "low",
    "栈"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [],
  "parent_key": "col-graph-scc-overview"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "col-graph-scc-dag-dp--lker",
  "author_name": "lker",
  "column_name": "SCC缩点 + DAG上拓扑DP（最大权值路径） · lker",
  "description": "NOI 大纲复习 · 图的连通性问题浅谈（lker PPT 拆分）",
  "content": "## 算法原理\n\nSCC 本身只是一个划分；真正让它在比赛里好用的一步是 **缩点**：把每个强连通分量压成一个“超级点”，分量内部的点互相可达，走进去就可以全部走完；分量之间的边保留，得到一张 **DAG（有向无环图）**。\n\n为什么缩点后一定是 DAG？如果缩点后的图还有环，那么环上的所有超级点互相可达，它们原本就应该属于同一个 SCC，与“极大性”矛盾。所以缩点图必然无环，可以拓扑排序。\n\n以洛谷 P3387【模板】缩点为例：给定 $n$ 个点、$m$ 条边的有向图，每个点有点权，求一条路径，使路径经过的点权之和最大。路径可以重复经过点，但点权只算一次。缩点后：\n\n- 同一个 SCC 内的点权全部加起来，作为超级点的点权；\n- 原图里跨分量的边变成超级点之间的边；\n- 在 DAG 上按拓扑序做一遍最大权路径 DP。\n\n这里有一个贪心观察：本题点权非负，所以进入一个 SCC 后把里面所有点都走完一定不亏；因此可以把整个 SCC 的点权合并，不需要在分量内部再做选择。如果点权可能为负，这个观察就不成立，问题会变成另一类“最大权闭合子图/路径”问题，不能直接套这个模板。\n\n### 缩点的三个步骤\n\n1. **Tarjan 求 SCC**：顺便给每个点打上分量编号 `scc[u]`，并累加分量点权。\n2. **重建图**：枚举原图的每条边 $(u,v)$，若 `scc[u] != scc[v]`，在缩点图上加边 `scc[u] -> scc[v]`，同时统计入度。\n3. **拓扑 DP**：入度为 0 的超级点作为起点，按拓扑序转移，答案是所有超级点 DP 值的最大值。\n\n## 核心公式 / 状态定义与转移方程\n\n设 $c(u)$ 为点 $u$ 所属的 SCC 编号，$W_c$ 为分量 $c$ 的点权之和：\n\n$$\nW_c=\\sum_{u:\\,c(u)=c} a_u.\n$$\n\n在缩点图 $G'=(V',E')$ 上定义 $f[c]$ 为“以分量 $c$ 结尾的最大权路径”，则\n\n$$\nf[c]=W_c+\\max_{\\substack{p\\to c\\\\ p\\in V'}}\\bigl(f[p]\\bigr),\n$$\n\n没有前驱时 $f[c]=W_c$。按拓扑序递推即可。\n\n写成伪代码：\n\n```\ntarjan 求出 scc[u] 与 W[c]\n清空缩点图的邻接表\nfor each original edge (u, v):\n    x = scc[u]; y = scc[v]\n    if x != y:\n        add(x, y); indeg[y] += 1\nqueue <- all c with indeg[c] == 0\nf[c] = W[c] for all c\nwhile queue not empty:\n    p = queue.pop()\n    for each edge (p, c):\n        f[c] = max(f[c], f[p] + W[c])\n        indeg[c] -= 1\n        if indeg[c] == 0: queue.push(c)\nanswer = max(f[c])\n```\n\n## 逐行代码解析\n\n这一版没有配套的 `.cpp`，下面按模块说明 lker 模板的结构；片段是结构示意，不是完整可提交程序。\n\n### 模块一：Tarjan 与分量点权\n\n在弹栈时同时做三件事：记录点属于哪个分量、把点权累加到 `W[当前分量]`、清空 `in_stack`。分量编号从 1 开始，`W` 数组初始化为 0。弹栈的顺序不影响结果，但每个点必须恰好弹出一次。\n\n### 模块二：重建缩点图\n\n原图的边要先存进 `u[]` 和 `v[]`，因为 Tarjan 之后还要再枚举一次。重建前把 `h` 置为 -1、`ne/to` 清零、`idx` 归零，避免旧边残留。枚举时只保留 `x != y` 的边；自环在缩点后没有意义，必须跳过。\n\n### 模块三：拓扑排序\n\n缩点图的入度用 `indeg`（或复用一个清空后的 `in` 数组）统计。所有入度为 0 的分量先入队，`f` 初始化为自身点权。每次取出队首，枚举出边做转移，入度减到 0 就入队。拓扑序保证转移时前驱已经算完，不需要记忆化搜索。\n\n### 模块四：答案\n\n答案不是 `f[某个固定点]`，而是所有分量 `f` 的最大值。因为最长路径可能在任何地方结束，不能只取拓扑序最后一个点。\n\n## 复杂度分析\n\nTarjan 是 $O(n+m)$，重建图和拓扑 DP 也都是 $O(n+m)$；总时间复杂度 $O(n+m)$。\n\n空间上邻接表、`dfn/low/scc/W/f/indeg` 都是 $O(n+m)$ 级别。\n\n即使缩点后存在重边，每条边也只会让入度多加一次、转移多做一次，复杂度仍然是线性的；若担心常数，可以在重建时对边去重。\n\n## 适用场景\n\n- 有向图上的“最长路/最大权路径”，且允许重复经过点但只算一次权值；\n- 缩点后做 DAG 上的计数、可达性、方案数 DP；\n- 需要把“环上的点可以一次走完”显式建模的题目；\n- 2-SAT、强连通性判定之后的后续处理。\n\n看到“有向图 + 环 + 路径权值”这类组合，先想缩点；缩点后如果状态只依赖前驱，就按拓扑序 DP。\n\n## 常见陷阱与注意事项\n\n- **忘记保存原边**：Tarjan 会改邻接表的使用状态，重建缩点图前必须保留原图的 `u[]/v[]`。\n- **重建前没清空**：`h/ne/to/idx` 不清零会把 Tarjan 的边混进来，缩点图直接错。\n- **自环没跳过**：`scc[u] == scc[v]` 的边加进去会形成自环，污染入度和拓扑序。\n- **重边导致入度重复**：多条相同的缩点边会让入度数偏大，但每次转移都会减一次，最终仍能全部处理；若要求严格线性或去重，建议先排序去重。\n- **拓扑起点漏掉**：只把 1 号点入队会漏掉其它入度为 0 的分量；必须枚举所有分量。\n- **答案取错**：最长路径不一定在拓扑序末尾结束，要取全局最大值。\n- **负权**：本题点权非负才能“走完整个 SCC”；点权有负时要重新建模，不能直接套。\n- **递归深度**：$n$ 较大时 Tarjan 递归可能爆栈，必要时改迭代或开栈。\n\n## 对比与扩展\n\n| 做法 | 适用条件 | 复杂度 | 说明 |\n|---|---|---|---|\n| SCC 缩点 + 拓扑 DP | 有向图、点权非负、路径可重复经过点 | $O(n+m)$ | 本题模板 |\n| 直接记忆化 DFS | 图是 DAG | $O(n+m)$ | 有环时会死循环 |\n| Bellman-Ford 类松弛 | 允许负权、无正环 | $O(nm)$ | 不要求 DAG，但慢 |\n| 最长路 + 正环检测 | 一般有向图 | 多项式 | 有正环时最长路无界 |\n\n缩点是“把环消掉”的通用手段：SCC 缩点得到 DAG，边双缩点得到树，点双缩点得到圆方树。三种缩点的目标不同，但套路一致——先找分量，再在压缩后的结构上做原本做不动的问题。\n\n下一篇边双连通分量会把“无向图删边”的版本讲清楚；再下一篇点双连通分量则处理“删点”的版本。",
  "category": "图论",
  "tags": [
    "图论",
    "强连通分量",
    "缩点",
    "拓扑排序",
    "DAG DP",
    "最长路"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [],
  "parent_key": "col-graph-scc-overview"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "col-graph-e-dcc-condensation--lker",
  "author_name": "lker",
  "column_name": "边双连通分量缩点（E-DCC） · lker",
  "description": "NOI 大纲复习 · 图的连通性问题浅谈（lker PPT 拆分）",
  "content": "## 算法原理\n\n有向图用 SCC 处理“互相可达”，无向图则要处理“删掉一条边还连不连通”。**边双连通分量（Edge-Biconnected Component，E-DCC）** 是无向图里的极大边双连通子图：分量内任意两点之间，删去任意一条边都不会断开；等价地说，任意两点之间至少有两条**边不相交**的路径。\n\n这个等价性可以用最大流最小割定理证明：若两点之间不存在两条边不相交路径，则它们之间的最小割只有一条边，删掉这条边就断开。竞赛里通常直接把它当作结论使用。\n\n### 无向图 DFS 的边分类\n\n无向图做 DFS 时，边只有两类：\n\n- **树边**：DFS 生成树内部的边；\n- **返祖边**：从后代指回祖先的边。\n\n不会出现横叉边：如果一条边从一个子树指向另一个子树，那么无向边会让另一个子树在更早的时候顺着这条边搜过来，两个子树根本不会被分成两棵。正因为没有横叉边，求边双时**不需要像 SCC 那样判断点是否在栈中**。\n\n一条树边 $u\\to v$ 是**桥**，当且仅当 $v$ 的子树里没有任何返祖边能跨过这条树边回到 $u$ 或 $u$ 的祖先，也就是\n\n$$\n\\mathrm{low}[v] > \\mathrm{dfn}[u].\n$$\n\n把所有桥删掉，剩下的每个连通块就是一个 E-DCC；把每个 E-DCC 缩成一个点，桥就是缩点树上的边，缩点结果一定是**一棵树**。\n\n### 防止走回头路\n\n无向边在邻接表里会被存成两条有向边。DFS 时如果直接从 $v$ 走回 $u$，就会把来时的边当成一条“返祖边”，low 被错误更新，桥就判不出来。\n\n常见写法有两种：\n\n- 记录父节点，禁止走回父节点；\n- 记录来时的**边编号**，禁止走回同一条边。\n\n这里必须用第二种。原因是**重边**：如果 $u$ 和 $v$ 之间有两条边，那么从 $u$ 走第一条到 $v$ 后，完全可以从第二条边回到 $u$，这是一条合法的返祖边；如果只记录父节点，就会把这条合法的回去路径也禁掉，导致误判桥。\n\n### 异或配对\n\n建图时把一条无向边拆成两条有向边，编号成对分配：\n\n```\nadd(u, v):  to[idx] = v; ne[idx] = h[u]; h[u] = idx++;\nadd(v, u):  to[idx] = u; ne[idx] = h[v]; h[v] = idx++;\n```\n\n若第一条边的编号是 $i$，第二条就是 $i\\oplus 1$（异或 1 相当于翻转最低位）。DFS 进入 $u$ 时带上来时的边编号 `last`，枚举到边 $i$ 时，只要 `i == (last ^ 1)` 就说明这是来时的反向边，直接跳过。重边有各自的编号，不会被误跳。\n\n### 缩点后的树\n\n求出所有 E-DCC 后，枚举原图的每条边：若两端属于不同分量，就在缩点图上加边。由于每条这样的边都是桥，缩点图没有环，是一棵树。\n\n边双缩点后的常见套路全部是树上问题：\n\n- 求 LCA、树上倍增；\n- DFS 序、树上差分；\n- 树链剖分、线段树；\n- 树的直径、树形 DP。\n\n## 核心公式 / 状态定义与转移方程\n\n边双的 Tarjan 与 SCC 形状相似，只是多了“跳过反向边”，并且不需要栈内标记：\n\n$$\n\\mathrm{low}[u]=\\min\\left(\\mathrm{dfn}[u],\\ \\min_{v\\in T_u}\\mathrm{low}[v],\\ \\min_{v\\in B_u}\\mathrm{dfn}[v]\\right),\n$$\n\n其中 $T_u$ 是树边儿子，$B_u$ 是返祖边指向的已访问点。桥的判定是 $\\mathrm{low}[v]>\\mathrm{dfn}[u]$；当 $\\mathrm{low}[u]=\\mathrm{dfn}[u]$ 时，弹栈得到 $u$ 所在的一个 E-DCC。\n\n伪代码：\n\n```\ntarjan(u, last_edge):\n    dfn[u] = low[u] = ++timer\n    stack.push(u)\n    for each edge i from u to v:\n        if i == (last_edge ^ 1): continue      // 不走反向边\n        if dfn[v] == 0:\n            tarjan(v, i)\n            low[u] = min(low[u], low[v])\n        else:\n            low[u] = min(low[u], dfn[v])\n    if dfn[u] == low[u]:\n        repeat:\n            y = stack.pop()\n            把 y 归入当前 E-DCC\n        until y == u\n```\n\n缩点树上的两个常用结论：\n\n- 让整张图变成边双，至少需要加的边数是 $\\left\\lceil \\dfrac{\\text{叶子数}}{2}\\right\\rceil$；\n- 缩点树上两点距离：$\\mathrm{dist}(u,v)=\\mathrm{dep}[u]+\\mathrm{dep}[v]-2\\,\\mathrm{dep}[\\mathrm{lca}(u,v)]$。\n\n## 逐行代码解析\n\n这一版没有配套的 `.cpp`，下面按模块说明实现要点；片段是结构示意，不是完整可提交程序。\n\n### 模块一：成对建边\n\n`add(u, v)` 只负责把一条有向边接到 `u` 的链表头，`idx` 递增。主函数里对每条无向边连续调用两次 `add`，保证正反边编号相邻、异或为 1。\n\n### 模块二：跳过反向边\n\n`tarjan(u, last)` 的第二个参数是进入 $u$ 的边编号。枚举到 `i == (last ^ 1)` 时跳过，其余边正常处理。根节点传一个不会与任何边配对的哨兵值即可；由于边编号从 0 开始成对分配，传 0 时只会跳过编号 1 的反向边，不会误伤根的真实出边。\n\n### 模块三：low 的更新与弹栈\n\n树边递归后取 `min(low[u], low[v])`；返祖边取 `min(low[u], dfn[v])`。递归结束若 `dfn[u] == low[u]`，从栈顶弹到 $u$，这一段就是一个 E-DCC。无向图没有横叉边，所以不需要 `in_stack` 判断。\n\n### 模块四：孤立点与自环\n\n主函数枚举每个点：若 `h[i] == -1`（没有任何有效边），它自己就是一个 E-DCC；否则若未访问就调用 `tarjan(i, 0)`。自环对连通性没有贡献，读入时直接跳过，避免自环被当成反向边或重复计数。\n\n## 复杂度分析\n\nTarjan 每个点入栈、出栈各一次，每条边只枚举常数次，时间复杂度 $O(n+m)$；空间为邻接表与若干 $O(n)$ 数组，合计 $O(n+m)$。\n\n缩点后建树也是 $O(n+m)$。若在缩点树上做 LCA/树剖，单次询问 $O(\\log n)$，预处理 $O(n\\log n)$ 或 $O(n)$。\n\n## 适用场景\n\n- 求无向图的桥、边双连通分量；\n- 加最少的边使整张图边双连通（叶子配对）；\n- 路径必经边、边双缩点后的树上距离/差分；\n- 网络可靠性中“删一条边是否仍连通”的建模。\n\n看到“无向图 + 删边仍连通”“至少两条边不相交路径”“缩点后变成树”，优先考虑边双。\n\n## 常见陷阱与注意事项\n\n- **用父节点防回头**：重边会被误判成桥，必须记录边编号并用异或跳过反向边。\n- **把无向图当有向图写**：无向图没有横叉边，多写 `in_stack` 判断不会错，但会掩盖对边分类的理解；求桥时关键在反向边。\n- **自环没过滤**：自环对 E-DCC 没有贡献，读入时跳过最省事。\n- **图不保证连通**：主函数必须枚举所有未访问点；孤立点要单独算一个分量。\n- **桥的判定写反**：树边 $u\\to v$ 的桥条件是 `low[v] > dfn[u]`，不是 `>=`；等号表示还能绕回 $u$，不是桥。\n- **缩点后不判重边**：重边不影响树的连通性，但会影响度数统计；叶子数按缩点后的树统计，重复边不要重复加度数。\n- **叶子数公式的边界**：缩点树只有一个点时叶子数为 0，答案是 0；两个点时叶子数为 2，答案是 1。\n- **递归深度**：链状无向图递归深度可达 $n$，注意栈空间。\n\n## 对比与扩展\n\n| 分量 | 图类型 | 删什么仍连通 | 判定 | 缩点结果 |\n|---|---|---|---|---|\n| SCC | 有向图 | 互相可达 | `low[u] == dfn[u]` + 栈内判断 | DAG |\n| E-DCC | 无向图 | 删任意一条边 | 桥：`low[v] > dfn[u]` | 树 |\n| v-DCC | 无向图 | 删任意一个点 | 割点：`low[v] >= dfn[u]` | 圆方树 |\n\n经典例题：\n\n- **P8436【模板】边双连通分量**：输出 E-DCC 个数与每个分量的点集，注意重边、自环、图不连通；\n- **USACO06JAN Redundant Paths G**：边双缩点成树后，答案是把叶子两两配对所需的最少边数，即 $\\lceil \\text{叶子数}/2\\rceil$；\n- **P10953 逃不掉的路**：边双缩点后把询问转成树上两点距离，用 LCA/树剖计算。\n\n边双是“删边”的连通性；下一篇点双处理“删点”，缩点结果会从树升级成圆方树。",
  "category": "图论",
  "tags": [
    "图论",
    "边双连通分量",
    "桥",
    "缩点",
    "Tarjan",
    "树上问题"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [],
  "parent_key": "col-graph-scc-overview"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "col-graph-v-dcc--lker",
  "author_name": "lker",
  "column_name": "点双连通分量与割点（v-DCC） · lker",
  "description": "NOI 大纲复习 · 图的连通性问题浅谈（lker PPT 拆分）",
  "content": "## 算法原理\n\n边双关心“删掉一条边还连不连通”，点双关心的是更狠的问题：**删掉一个点还连不连通**。\n\n- **割点（关节点）**：无向图中删掉这个点（以及它连的所有边）后，图的连通分量数增加。\n- **点双连通分量（Vertex-Biconnected Component，v-DCC）**：不含割点的极大连通子图。两个点之间至少存在两条**点不相交**的路径（端点除外），它们就在同一个 v-DCC 里。\n\n点双和 SCC、边双有一个关键区别：**一个点可以同时属于多个 v-DCC**。有且仅有割点会出现在两个及以上的点双分量中；非割点只属于一个分量。正因如此，点双的弹栈条件和 SCC、边双都不一样：不能等“整个分量搜完”再统一弹，而要在每个儿子返回时就判断并弹出一段。\n\n### 圆方树\n\n把每个 v-DCC 缩成一个“方点”，把原图中的割点保留为“圆点”，方点向它包含的所有圆点连边，就得到一棵**圆方树**（Block-Cut Tree）。圆方树把无向图上的路径、必经点、连通性询问转化成树上问题，是点双最重要的后续工具。\n\nlker 在 PPT 里引用的说法是“点双缩点为圆方树，再进行树上 DP，是如今的重要图论考点”。圆方树的建树细节较多，本篇只讲点双与割点本身，圆方树留作扩展。\n\n### 求法与弹栈时机\n\n仍然用 Tarjan 的 `dfn/low`，但栈里存的是**点**，不是边。对树边 $u\\to v$：\n\n1. 递归处理 $v$；\n2. 用 $\\mathrm{low}[v]$ 更新 $\\mathrm{low}[u]$；\n3. 若 $\\mathrm{low}[v]\\ge \\mathrm{dfn}[u]$，说明 $v$ 的子树无法绕过 $u$，此时从栈顶弹到 $v$，再把 $u$ 加进去，得到一个新的 v-DCC。\n\n为什么判定写在 `for` 循环里？因为割点 $u$ 可能同时属于多个 v-DCC，必须每处理完一个儿子就检查一次；如果等 $u$ 的所有儿子都处理完再统一弹，$u$ 会被错误地只归入最后一个分量。\n\n为什么只弹到 $v$、还要把 $u$ 加回去？$u$ 是这些分量的公共割点，后面还可能和别的儿子组成新的分量，不能提前把 $u$ 弹出。只弹儿子子树，既保证当前分量完整，又保留 $u$ 给后续分量使用。\n\n### 孤立点与自环\n\n- **孤立点**：没有边的点本身就是一个 v-DCC，需要单独计数。\n- **自环**：对点连通性没有贡献，读入时直接过滤，避免它干扰栈和 low。\n\n### 关于 low[v] == dfn[u] 的写法\n\nlker 的 PPT 里提出过把判定收紧为 $\\mathrm{low}[v]=\\mathrm{dfn}[u]$，并声称可以省掉根节点特判。这个写法成立的前提是：**实现时不跳过父节点**。\n\n如果 $v$ 枚举到父节点 $u$ 时仍然执行 $\\mathrm{low}[v]=\\min(\\mathrm{low}[v],\\mathrm{dfn}[u])$，那么每条树边 $u\\to v$ 都天然满足 $\\mathrm{low}[v]\\le\\mathrm{dfn}[u]$。此时：\n\n- 子树能绕过 $u$ 时，$\\mathrm{low}[v]<\\mathrm{dfn}[u]$，不在 $u$ 处弹栈，分量留给更高的祖先；\n- 子树绕不过 $u$ 时，$\\mathrm{low}[v]=\\mathrm{dfn}[u]$，在 $u$ 处弹栈。\n\n于是 `==` 与 `>=` 在这个实现里等价，根节点也不需要额外特判：根的所有儿子都有 $\\mathrm{low}[v]=\\mathrm{dfn}[root]$，每个儿子子树会自然形成一个包含根的分量。\n\n但如果用常见的“跳过父节点”写法，$\\mathrm{low}[v]$ 可能大于 $\\mathrm{dfn}[u]$（树边是桥状连接），这时必须写 `>=`；把“跳过父节点”和 `==` 混在一起，就会漏掉分量。例如链 $u-v-w$：跳过父节点后 $\\mathrm{low}[w]=3,\\mathrm{low}[v]=2$，既不等于 $\\mathrm{dfn}[v]=2$ 也不等于 $\\mathrm{dfn}[u]=1$，`{u,v}` 与 `{v,w}` 都不会被弹出。\n\n结论：**`==` 与“不跳父节点”绑定，`>=` 与“跳父节点”绑定**，两种写法各自自洽，不要混用。本文正文按“不跳父节点 + `>=`”讲解，这种写法下 `==` 也能得到同样结果；如果改成常见的“跳父节点”写法，则必须使用 `>=`。\n\n顺便澄清一个容易混淆的点：**v-DCC 的弹栈本身不需要根节点特判**；需要根特判的是“割点计数”——根只有在有两个及以上儿子时才是割点。\n\n## 核心公式 / 状态定义与转移方程\n\n$$\n\\mathrm{low}[u]=\\min\\left(\\mathrm{dfn}[u],\\ \\min_{v\\in T_u}\\mathrm{low}[v],\\ \\min_{v\\in B_u}\\mathrm{dfn}[v]\\right).\n$$\n\nv-DCC 的弹栈条件：\n\n$$\n\\mathrm{low}[v]\\ge \\mathrm{dfn}[u]\\quad (v \\text{ 是 } u \\text{ 的树边儿子}).\n$$\n\n割点判定：\n\n- 非根节点 $u$：存在树边儿子 $v$ 使 $\\mathrm{low}[v]\\ge \\mathrm{dfn}[u]$；\n- 根节点 $u$：树边儿子数量 $\\ge 2$。\n\n伪代码：\n\n```\ntarjan(u):\n    dfn[u] = low[u] = ++timer\n    stack.push(u)\n    child_count = 0\n    for each edge (u, v):\n        if dfn[v] == 0:\n            child_count += 1\n            tarjan(v)\n            low[u] = min(low[u], low[v])\n            if low[v] >= dfn[u]:\n                // v 的子树与 u 组成一个点双\n                repeat:\n                    y = stack.pop()\n                    把 y 加入当前 v-DCC\n                until y == v\n                把 u 加入当前 v-DCC\n        else:\n            low[u] = min(low[u], dfn[v])\n    if u 是根 and child_count >= 2:\n        u 是割点\n```\n\n注意：上面的伪代码**不跳过父节点**，父边会以 $\\mathrm{dfn}[parent]$ 的形式更新 low；这正是下文 `low[v] == dfn[u]` 写法能够成立的原因。如果实现里加了“跳过父节点”，弹栈条件就要改成 `>=`。\n\n注意：上面这段伪代码在“孤立点”和“根只有一个儿子”的边界上还要补特判；完整实现需要结合题目要求处理孤立点。\n\n## 逐行代码解析\n\n这一版没有配套的 `.cpp`，下面按模块说明实现要点；片段是结构示意，不是完整可提交程序。\n\n### 模块一：栈与时间戳\n\n点双的栈存点，进入 `tarjan(u)` 时把 $u$ 压栈。`dfn/low` 的初始化与 SCC 相同；不同之处是弹栈发生在“儿子返回后”，而不是函数末尾。\n\n### 模块二：儿子返回后的判定\n\n对每个未访问的儿子 $v$：递归、更新 low，然后判断 `low[v] >= dfn[u]`。成立就循环弹栈直到 $v$，把弹出的点收进当前分量，最后再补一个 $u$。这一步保证割点 $u$ 被同时写进多个分量。\n\n### 模块三：割点计数\n\n如果题目只要求割点，可以不真正存分量，只统计每个点出现在多少个 v-DCC 里：弹栈时给每个点 `cnt++`，最后 `cnt >= 2` 的点就是割点。根节点的特殊情况可以单独用儿子数判断，也可以依赖 `cnt` 的统计结果。\n\n### 模块四：孤立点与主函数\n\n主函数枚举所有未访问点；若某个点没有任何有效边，直接把它作为一个独立的 v-DCC。自环在读入时过滤。图不连通时，每个连通块分别跑 Tarjan。\n\n## 复杂度分析\n\n每个点入栈、出栈各一次，每条边被枚举常数次，时间复杂度 $O(n+m)$；栈、`dfn/low`、分量容器都是 $O(n)$ 级别，空间复杂度 $O(n+m)$。\n\n求割点只多一个计数数组，复杂度不变。圆方树的建树也是 $O(n+m)$，后续树上 DP 通常再加 $O(n)$ 或 $O(n\\log n)$。\n\n## 适用场景\n\n- 求无向图的割点、点双连通分量；\n- 判断“删掉某个点是否断开”，以及必经点问题；\n- 圆方树建树、圆方树上 DP、路径询问；\n- 网络可靠性中“删一个站点是否仍连通”的建模。\n\n看到“删点仍连通”“一个点同时属于多个块”“必经点”，优先考虑点双与割点。\n\n## 常见陷阱与注意事项\n\n- **在函数末尾统一弹栈**：点双的割点属于多个分量，必须在每个儿子返回时判定并弹出，不能等整个函数结束。\n- **忘记把 u 加回分量**：只弹到 $v$ 后，$u$ 还要手动加入当前分量；否则每个分量都缺割点。\n- **根节点一刀切**：v-DCC 弹栈本身不需要根特判；割点计数才需要根的儿子数条件，别把两件事混在一起。\n- **孤立点漏算**：没有边的点是一个独立的 v-DCC，P8435 这类题会查。\n- **自环没过滤**：自环对点连通性没有贡献，读入时跳过。\n- **跳父节点却写 `==`**：跳过父边后 `low[v]` 可能大于 `dfn[u]`，`==` 会漏分量；要么不跳父节点用 `==`/`>=`，要么跳父节点用 `>=`，不要混搭。\n- **递归深度**：链状图递归深度可达 $n$，注意栈空间。\n- **多测/多连通块**：每个连通块单独 Tarjan，栈和计数器要按块清空或在全局正确复位。\n\n### 例题：2004 年浙江省选《嗅探器》\n\n题意大致是：在一个无向网络里有两个传输中心 $A,B$，问哪些点删掉后 $A$ 与 $B$ 不再连通。第一反应是找割点，但直接输出所有割点会错：**只有位于 $A$ 到 $B$ 路径上的割点才算答案**。\n\n处理思路：\n\n1. 先求割点；\n2. 标记 $A$ 到 $B$ 的路径：有向图可以正反建图各标记一次；无向图可以一次 DFS，找到目标后把栈里的点弹出并标记；\n3. 统计路径上同时是割点的点；\n4. 两个传输中心 $A,B$ 本身不算答案。\n\n这个例子说明：割点是全局概念，题目问的是“某两点之间”的割点，必须把路径条件加上去。\n\n## 对比与扩展\n\n| 分量 | 删什么 | 判定 | 一个点属于几个分量 | 缩点结果 |\n|---|---|---|---|---|\n| SCC | 有向图，互相可达 | `low[u] == dfn[u]` + 栈内判断 | 1 | DAG |\n| E-DCC | 删任意一条边 | 桥：`low[v] > dfn[u]` | 1 | 树 |\n| v-DCC | 删任意一个点 | 割点：`low[v] >= dfn[u]` | 割点 ≥2，其余 1 | 圆方树 |\n\n点双的后续是圆方树：把方点（v-DCC）与圆点（原图点/割点）连成一棵树后，原图上的路径必经点、连通块询问都可以转成树上问题。再往后还有仙人掌、广义圆方树等结构，但它们的根仍然是这一篇的 Tarjan 弹栈。\n\n连通性三条线到这里就齐了：有向图看 SCC，无向图删边看边双，无向图删点看点双。三者共用 `dfn/low`，区别只在“栈里存什么、什么时候弹、拿什么条件判”。",
  "category": "图论",
  "tags": [
    "图论",
    "点双连通分量",
    "割点",
    "Tarjan",
    "圆方树"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [],
  "parent_key": "col-graph-scc-overview"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

-- ---------- 执行后自检 ----------
select column_key, column_name, author_name, category, kind, tags, parent_key,
       length(content) as content_len, source_ticket_id, status, updated_at
from public.columns
where column_key in (
    'col-graph-tarjan-scc--lker',
    'col-graph-scc-dag-dp--lker',
    'col-graph-e-dcc-condensation--lker',
    'col-graph-v-dcc--lker'
)
order by column_key;

select column_key, column_name, author_name, updated_at
from public.published_columns
where column_key in (
    'col-graph-tarjan-scc--lker',
    'col-graph-scc-dag-dp--lker',
    'col-graph-e-dcc-condensation--lker',
    'col-graph-v-dcc--lker'
)
order by column_key;
