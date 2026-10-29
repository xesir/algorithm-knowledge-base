---
id: prob-atcoder-arc174e
title: 'Existence Counting'
oj: 'AtCoder'
problemId: 'ARC174E'
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

暂无（原题：[ARC174E](https://www.luogu.com.cn/problem/AT_arc174_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$ 和长为 $n$ 的序列 $b_i$。考虑每个 $k=1,2,\cdots,m$，对满足下列条件长为 $n$ 的序列 $a_i$ 计数：
>
> - $\forall i \in [1,n], a_i \in [1,m]$。
> - $a$ 的所有元素互不相同。
> - $\exists i \in [1,n], a_i=k$。
> - $a$ 的字典序不大于序列 $b$。
>
> 保证 $b_i \in [1,m]$ 且 $b$ 的元素互不相同。
>
> $n,m \le 3 \times 10^5$，4 秒，1024 MB。

:::::success[题解]

设 $f_k$ 为数字 $k$ 的答案。我们枚举 $i=1 \to n$，钦定 $\forall j<i, a_j=b_j$ 且 $a_i<b_i$。人话就是钦定 LCP，考虑这种序列对每个 $f_k$ 的贡献。

设 $b_1 \sim b_{i-1}$ 组成集合 $S$，可填入 $a_i$ 的数有 $c$ 个，则 $c$ 是 $x \notin S \land x<b_i$ 的 $x$ 的数目。用权值树状数组维护即可。

对 $k$ 分类讨论：

- 若 $k \in S$，$a_i$ 的填法为 $c$，而 $a_{i+1} \sim a_n$ 随意填，$f_k \gets c \times A_{m-i}^{n-i}$。
- 若 $k \notin S$：
  - 将 $k$ 扔到后 $n-i$ 个位置，$a_i$ 的填法为 $c$，有 $f_k \gets c \times A_{m-i-1}^{n-i-1} \times (n-i)$，其中 $n-i$ 是选出 $k$ 所在位置的方案数。
  - 若 $k<a_i$，可以将 $k$ 填到 $a_i$，于是 $f_k \gets A_{m-i-1}^{n-i}$。

用两个差分树状数组维护 $k \in S$ 和 $k \notin S$ 的 $f_k$，支持区间加单点查询。扫描到 $b_i$ 时其从 $\notin S$ 的数组移动到 $\in S$ 的数组里。

注意特判 $a=b$ 的情况，令 $k \in S$ 的 $f_k \gets 1$。

复杂度 $O(n \log m)$。[代码](https://atcoder.jp/contests/arc174/submissions/79453271)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
