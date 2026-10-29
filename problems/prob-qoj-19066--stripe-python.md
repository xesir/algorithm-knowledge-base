---
id: prob-qoj-19066
title: 'Historical Hits'
oj: 'QOJ'
problemId: 'QOJ19066'
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

暂无（原题：[QOJ19066](https://qoj.ac/problem/19066)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个二元组 $(a_i,b_i)$。你需要将 $n$ 个二元组随机打乱，然后进行如下操作：
>
> - 维护集合 $S$，按打乱后的顺序依次考虑每个 $i$，若 $\forall x \in S, x \notin [\min(a_i,b_i),\max(a_i,b_i)]$ 则令 $S \gets S \cup \{a_i\}$。
>
> 求 $|S|$ 的期望值。保证 $\forall i\ne j, a_i \ne a_j$ 且 $a_i \ne b_j$。
>
> $n \le 3 \times 10^3$，2 秒，1024 MB。

:::::success[题解]

考虑两个位置 $i,j$，若 $a_j \in [\min(a_i,b_i),\max(a_i,b_i)]$ 则连边 $i \to j$，表示 $i$ 可以阻止 $j$ 加入。在一般图上考虑问题，DP 状态需要记可达性等信息，状态数不可接受。

这启发我们利用区间的性质。对 $a_i$ 离散化后对 $n$ 个二元组按 $a_i$ 升序排序，则 $i \to j$ 对应的 $j$ 在新序列中构成连续段 $[x_i,y_i]$。容易证明 $i \in [x_i,y_i]$。

对 $k \in S$，所有覆盖 $k$ 的区间 $k \in [x_j,y_j]$ 都会失效。我们将一个极大空区间作为状态进行 DP：

- 记 $f_{l,r}$ 为满足下列条件时 $\Delta |S|$ 的期望：

  - $l-1 \in S \land r+1 \in S$。
  - $\forall k\in [l,r], k\notin S$。

  显然对 $|S|$ 有影响的 $i$ 必满足 $[x_i,y_i] \subseteq [l,r]$，故 $f_{l,r}$ 与外界独立。

- 区间 DP 转移考虑枚举断点 $k$。设 $c_{l,r}$ 为 $[x_i,y_i] \subseteq [l,r]$ 的 $i$ 的数目，特判 $c_{l,r}=0$ 后进行讨论：

  - 取出 $k$ 的概率为 $\frac{1}{c_{l,r}}$。
  - 根据 DP 的组合意义，$k$ 是 $[l,r]$ 内部首先处理的位置，故 $k$ 必然能成功加入 $S$。
  - $k$ 加入 $S$ 后，原区间 $[l,r]$ 分裂为 $[l,k)$ 和 $(k,r]$。

  综上所述，我们有转移式
  $$
  \boxed{f_{l,r}=1+\dfrac{1}{c_{l,r}} \sum_{k \in [l,r]\land [x_k,y_k] \subseteq [l,r]} (f_{l,k-1}+f_{k+1,r})}
  $$

- DP 初值为 $f_{l,r}=0$。

- 答案为 $f_{1,n}$。

复杂度 $O(n^3)$ 无法通过。观察转移条件，利用区间 DP 转移顺序的特殊性对其进行优化。

我们增量维护所有合法的 $k$。考虑 $r \to r+1$ 时，新增的 $k$ 必有 $y_k=r \land l \le x_k$。将 $k$ 挂在 $y_k$ 处，令 $c_{l,r}$ 继承 $c_{l,r-1}$ 后枚举 $k$ 进行转移。对后面的求和式，令
$$
p_{l,r}=\sum_{k \in [l,r] \land [x_k,y_k] \subseteq [l,r]} f_{l,k-1}\\
q_{l,r}=\sum_{k \in [l,r] \land [x_k,y_k] \subseteq [l,r]} f_{k+1,r}\\
$$
内层对 $r$ 扫描线维护 $p$，对 $l$ 扫描线维护 $q$，最后再计算每个 $f_{l,r}$ 即可。

复杂度 $O(n^2)$。[代码](https://qoj.ac/submission/2958060)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
