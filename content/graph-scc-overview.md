---
id: graph-scc-overview
title: '连通分量总览（Tarjan / Kosaraju / 缩点 / 边双）'
category: '图论'
subcategory: '连通分量'
tags: ['连通分量', 'Tarjan', 'SCC', '缩点', '总览']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: A
noCode: true
hub: true
verified: '2026-11-01'
---

## 算法原理

本页是「连通分量」的二级栏目索引：强连通分量（SCC）用 Tarjan/Kosaraju 求出后缩点成 DAG；边双连通分量（E-DCC）用 Tarjan 求桥后缩点。

**学习顺序**：Tarjan SCC → Kosaraju → SCC 缩点 → 缩点 + DAG DP → 边双缩点。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 子条目 |
|---|---|
| 求有向图强连通分量 | Tarjan 强连通分量、Kosaraju |
| 把 SCC 缩成 DAG | SCC 缩点 |
| 缩点后做拓扑 DP | SCC缩点 + DAG上拓扑DP |
| 无向图边双连通分量 | 边双连通分量缩点（E-DCC） |

Tarjan 依靠 `dfn/low` 判定：`low[u] == dfn[u]` 时弹出栈内节点形成一个 SCC。

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出 `dfn/low` 更新、栈操作与逐行解析。

## 复杂度分析

- Tarjan / Kosaraju：$O(n+m)$。
- 缩点：$O(n+m)$。
- 缩点后 DAG 拓扑 DP：$O(n+m)$。

## 适用场景

- 有向图强连通性、环检测。
- 缩点后转为 DAG 做计数/最长路。
- 无向图桥、边双连通分量。

## 常见陷阱与注意事项

- 有向图与无向图的 `low` 更新方式不同（无向图要判父边）。
- 重边会影响桥的判定，需要记录边编号。
- 缩点后注意去重边。
- 递归 Tarjan 在深图上有栈溢出风险。
- 割点、桥与 SCC 是不同概念，别混用。

## 对比与扩展

- Tarjan vs Kosaraju：前者一次 DFS，后者两次 DFS 但更好写。
- SCC vs E-DCC：前者针对有向图，后者针对无向图。
- 可扩展到点双连通分量（v-DCC）与圆方树。
