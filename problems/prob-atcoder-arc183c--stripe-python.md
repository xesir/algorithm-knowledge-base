---
id: prob-atcoder-arc183c
title: 'Not Argmax'
oj: 'AtCoder'
problemId: 'ARC183C'
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

暂无（原题：[ARC183C](https://www.luogu.com.cn/problem/AT_arc183_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对 $1 \sim n$ 的排列 $p_i$，给定 $m$ 条限制 $(l_i,r_i,x_i)$，表示 $\max \limits_{k \in [l_i,r_i]} p_k \ne p_{x_i}$。求满足所有限制的排列数目。
>
> $n \le 500$，$m \le 10^5$，2 秒，1024 MB。

:::::success[题解]

注意到我们只关心相对大小，考虑最值分治式 DP：

- 设 $f_{l,r}$ 为 $[l,r]$ 区间的合法方案数。注意我们仅关心相对大小。

- 转移枚举 $k$ 并钦定 $k$ 为 $[l,r]$ 的区间 $\max$ 位置。先判定 $k$ 是否合法：

  - 若 $x_i=k$ 且 $[l_i,r_i] \subseteq [l,r]$ 必不合法。容易验证其余情况都合法。

  转移将 $[l,k)$ 和 $(k,r]$ 进行合并。只要重新钦定大小顺序，保证同组排名不变，选法数 $\binom{r-l}{k-l}$。转移方程
  $$
  \boxed{f_{l,r}=\sum_{k \in [l,r]} \binom{r-l}{k-1}f_{l,k-1} \times f_{k+1,r}}
  $$

- DP 初值为 $f_{i,i-1}=f_{i,i}=1$。注意特判 $l_i=r_i$ 的情形，不存在合法排列。

- 答案为 $f_{1,n}$。

预处理 $S_k=\{[l_i,r_i] \mid x_i=k\}$，只要判定 $\exists [l',r'] \in S_k, [l',r'] \subseteq [l,r]$。对每个 $S_k$ 递推出 $a_x=\min \limits_{l_i \ge x} r_i$，查询 $(l,r)$ 判断 $a_l \le r$ 是否成立即可。

复杂度 $O(m+n^3)$。[代码](https://atcoder.jp/contests/arc183/submissions/79639704)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
