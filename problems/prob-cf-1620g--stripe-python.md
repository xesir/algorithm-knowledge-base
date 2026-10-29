---
id: prob-cf-1620g
title: 'Subsequences Galore'
oj: 'Codeforces'
problemId: 'CF1620G'
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

暂无（原题：[CF1620G](https://www.luogu.com.cn/problem/CF1620G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个字符串 $A_i$，保证字符集为 $\tt{a \sim z}$，且 $A_i$ 内部每个字符按照字符集顺序升序排列。
>
> 对 $S \subseteq \{1,2,\cdots,n\}$，记 $f(S)$ 为 $\exists x \in S, B$ 是 $A_x$ 的子序列的本质不同字符串 $B$ 的数目。对每个 $S$ 求出 $f(S)$。
>
> $n \le 23$，$|A_i | \le 2 \times 10^4$，10 秒，1000 MB。

:::::success[题解]

设 $g(S)$ 为 $\forall x \in S,B$ 是 $A_x$ 的子序列的本质不同字符串 $B$ 的数目。$g$ 的组合意义是钦定至少。

考察 $g$ 的计算方法。由于每个字符串形如 $\tt{aa\cdots abb \cdots b\cdots zz \cdots z}$，设 $\text{cnt}(S,c)$ 为字符串 $S$ 中字符 $c$ 的出现次数，则 $B$ 是 $A_i$ 子序列的充要条件是 $\forall c\in \Sigma, \text{cnt}(B,c) \le \text{cnt}(A_i,c)$。 从而 $g$ 由乘法原理合并得
$$
g(S)=\prod_{c\in \Sigma} \left(1+\min_{i \in S} \text{cnt}(A_i,c)\right)
$$
朴素计算 $g$ 是 $O(|\Sigma| n2^n)$ 的。设
$$
\begin{aligned}
g_c(S)&=1+\min_{i \in S} \text{cnt}(A_i,c)\\
g(S)&=\prod_{c \in \Sigma} g_c(S)
\end{aligned}
$$
此时 $g_c$ 可以通过排除特殊元素的方法进行转移
$$
g_c(S)=\min(g_c(S \setminus \{x\}), 1+\text{cnt}(A_x,c)), x =\min S
$$
边界 $g_c(\varnothing)=+\infty$，优化到 $O(|\Sigma| 2^n)$。

$g \to f$ 的转化只要枚举 $T \subseteq S$，容斥系数 $(-1)^{|T|-1}$。形式化地
$$
f(S)=\sum_{T \subseteq S} (-1)^{|T|-1} g(T)
$$

记 $g_0(T)=(-1)^{|T|-1} g(T)$，对 $G_0$ 做一个高维前缀和得到 $F$ 即可。

复杂度 $O(nL+|\Sigma| 2^n+n2^n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
