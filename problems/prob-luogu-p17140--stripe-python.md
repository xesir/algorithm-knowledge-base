---
id: prob-luogu-p17140
title: '[NOI 2026] 线段'
oj: '洛谷'
problemId: 'P17140'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 数学
tags: ['题解']
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
knowledgePoints: []
---

> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P17140](https://www.luogu.com.cn/problem/P17140)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 条线段 $[l_i,r_i]$，保证 $[l_i,r_i] \subseteq [1,m]$。定义线段集合 $S \subseteq \{1,2,\cdots,n\}$ 是优美的，当且仅当 $[l_u,r_u] \cap [l_v,r_v] \ne \varnothing$ 时连边 $u \leftrightarrow v$ 形成一棵树。
>
> 给定 $k \le n$，对 $i=1,2,\cdots,k$ 求出，$|S|=i$ 的优美集合数目。
>
> 多测，$T \le 20$，$n \le 3\times 10^3$，$m \le 10^3$，$\sum k \le 200$，4 秒，512 MB。

:::::success[题解]

树是连通无环图，区间图是弦图。综合两个性质得到充要条件：

- 连通：$S$ 的并集是连续线段。
- 无环：不存在某个点的覆盖次数 $\ge 3$。

将线段按左端点升序排序后逐个加入，按照条件设计 DP：

- 设 $f_{i,j,x,y}$ 为满足下列条件的合法方案数：

  - 仅考虑前 $i$ 条线段。
  - $|S|=j$。
  - 当前最大右端点位于 $x$，次大右端点位于 $y$。值 $=0$ 表示不存在。

- 若不加入 $[l_i,r_i]$ 转移 $f_{i-1,j,x,y} \to f_{i,j,x,y}$。加入 $[l_i,r_i]$ 的转移条件可画图分析：

  ![image.png](https://cdn.luogu.com.cn/upload/image_hosting/hrbcfp0t.webp)

  不难发现 $l_i>x$ 则不连通，$l_i\le y$ 则成环。特判 $x=0$，只要 $l_i \in (y,x]$ 就有转移
  $$
  f_{i-1,j,x,y} \to f_{i,j+1,x',y'}
  $$
  其中 $x',y'$ 为集合 $\{x,y,r_i\}$ 的最大 / 次大值。由 $r_i >y$ 可以写作
  $$
  f_{i-1,j,x,y} \to f_{i,j+1,\max(x,r_i),\min(x,r_i)}
  $$

- DP 初值为 $f_{0,0,0,0}=1$。

- 答案为 $\text{ans}_j=\sum\limits_{x,y} f_{n,x,y}$。

对 $i$ 维度滚动数组，$j$ 倒序枚举，时间 $O(nm^2k)$ 空间 $O(m^2k)$ 无法通过。

对 $y$ 维度动态维护前缀和
$$
s_{j,x}=\sum_{y<l_i} f_{j,x,y}
$$
转移变为
$$
f_{j+1,\max(x,r_i),\min(x,r_i)} \gets s_{j,x}
$$
注意到 $l_i$ 单调不降，当 $l_i$ 增加时更新 $s_{j,x} \gets f_{j,x,y}$ 即可。特判 $x=0$ 的相关转移。

显然 $y \le x$，空间可以折半，时间 $O(nmk)$ 空间 $O(m^2k)$，经卡常可以通过。[代码](https://qoj.ac/submission/3189361)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
