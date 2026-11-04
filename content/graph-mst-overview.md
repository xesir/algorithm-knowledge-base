---
id: graph-mst-overview
title: '最小生成树总览（Kruskal / Prim / Borůvka）'
category: '图论'
subcategory: '最小生成树'
tags: ['最小生成树', 'MST', 'Kruskal', 'Prim', '总览']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: A
noCode: true
hub: true
verified: '2026-11-01'
---

## 算法原理

本页是「最小生成树（MST）」的二级栏目索引：在连通无向带权图中选 $n-1$ 条边使总权最小。常用 Kruskal（按边贪心 + 并查集）、Prim（按点扩展）、Borůvka（按连通块找最小出边）。

**学习顺序**：Kruskal → Prim → Borůvka。

## 核心公式 / 状态定义与转移方程

**按场景选子栏目**：

| 场景 | 子条目 |
|---|---|
| 稀疏图、边排序方便 | Kruskal 最小生成树 |
| 稠密图、邻接矩阵 | Prim 最小生成树（堆优化） |
| 特殊题/并行求最小出边 | Borůvka 最小生成树 |

Kruskal 正确性依赖「切分性质」：跨切分的最小边一定属于某棵 MST。

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出排序、并查集/堆操作与逐行解析。

## 复杂度分析

- Kruskal：$O(m\log m)$（排序主导）。
- Prim 堆优化：$O((n+m)\log n)$。
- Borůvka：$O(m\log n)$ 级别（每轮合并连通块）。

## 适用场景

- 连通图最小代价建网。
- 稠密图 Prim、稀疏图 Kruskal。
- 需要按连通块合并的变种题。

## 常见陷阱与注意事项

- 图不连通时只能得到最小生成森林。
- Kruskal 要先按边权排序，边权相同不影响正确性。
- Prim 的 `dis` 初始为 INF，起点为 0。
- Borůvka 每轮要清空并重新找最小出边。
- 重边与自环的处理要按题意。

## 对比与扩展

- Kruskal vs Prim：稀疏图 Kruskal，稠密图 Prim。
- MST vs 最短路：前者全局连通代价最小，后者单源路径最短。
- 可扩展到次小生成树、最小树形图（朱刘算法）。
