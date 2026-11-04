---
id: graph-shortest-overview
title: '最短路总览（Dijkstra / Bellman-Ford / Floyd / Johnson）'
category: '图论'
subcategory: '最短路'
tags: ['最短路', 'Dijkstra', 'SPFA', 'Floyd', '总览']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: A
noCode: true
hub: true
verified: '2026-11-01'
---

## 算法原理

本页是「最短路」的二级栏目索引：按「边权是否有负、求单源还是全源、图是否有环」选择算法。

**学习顺序**：Dijkstra（非负单源）→ Bellman-Ford/SPFA（含负权）→ DAG 最短路 → Floyd（全源）→ Johnson（负权全源）。

## 核心公式 / 状态定义与转移方程

**按场景选子栏目**：

| 场景 | 子条目 |
|---|---|
| 非负边权、单源 | Dijkstra 最短路（堆优化） |
| 含负权、单源、可判负环 | Bellman-Ford、SPFA 变体 |
| DAG 上单源 | DAG 最短路（拓扑排序） |
| 小规模全源 | Floyd-Warshall |
| 负权图全源 | Johnson 全源最短路 |
| 同余类最短路 | 同余最短路 |

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出松弛方式、正确性条件与逐行解析。

## 复杂度分析

- Dijkstra 堆优化：$O((n+m)\log n)$。
- Bellman-Ford：$O(nm)$；SPFA 为均摊更快但最坏可退化。
- DAG 最短路：$O(n+m)$。
- Floyd：$O(n^3)$。
- Johnson：一次 Bellman-Ford + $n$ 次 Dijkstra，$O(nm\log n)$。

## 适用场景

- 路径规划、差分约束转最短路。
- 负权/负环判定。
- 全源最短路（$n$ 较小用 Floyd，负权用 Johnson）。
- DAG 上的最长/最短路。

## 常见陷阱与注意事项

- Dijkstra 不能处理负权边。
- SPFA 最坏 $O(nm)$，不要默认它一定快。
- Floyd 的三重循环顺序必须是 `k, i, j`。
- 负环判定：Bellman-Ford 第 $n$ 轮仍能松弛即存在负环。
- 同余最短路的状态是「余数」，不是原图点。

## 对比与扩展

- Dijkstra vs SPFA：非负优先 Dijkstra。
- Floyd vs Johnson：小图 Floyd 更短，稀疏负权图 Johnson 更快。
- 可扩展到 k 短路、分层图最短路。
