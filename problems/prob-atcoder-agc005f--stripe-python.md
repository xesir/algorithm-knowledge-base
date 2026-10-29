---
id: prob-atcoder-agc005f
title: 'Many Easy Problems'
oj: 'AtCoder'
problemId: 'AGC005F'
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

暂无（原题：[AGC005F](https://www.luogu.com.cn/problem/AT_agc005_f)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个节点的无根树。对 $k=1,2,\cdots,n$ 求出：选择 $k$ 个关键点的虚树点数之和，对 NTT 模数取模。
>
> $n \le 2\times 10^5$，5 秒，512 MB。

:::::success[题解]

将贡献拆到节点上。对点集 $S$ 和节点 $u \notin S$，点 $u$ 不属于 $S$ 的虚树，当且仅当删去 $u$ 后 $S$ 仍然连通。

设删去 $u$ 后子树大小分别为 $a_1 \sim a_m$，则 $u$ 对 $\text{ans}_k$ 的贡献为
$$
\binom{n}{k}-\sum_{i=1}^m \binom{a_i}{k}
$$
对 $a_i$ 开桶进行优化。记 $a_i=x$ 的 $(u,i)$ 对有 $c_x$ 个，那么 $x$ 对 $\text{ans}_k$ 的负贡献写作
$$
\sum_{x=1}^n c_x \binom{x}{k}=\sum_{x=1}^n \dfrac{c_x \times x!}{k!(x-k)!}
$$
其中 $\frac{1}{k!}$ 是常数，剩余部分视作 $c_x \times x!$ 和 $\frac{1}{x!}$ 的差卷积。用正贡献 $n \binom{n}{k}$ 减去即为答案。

复杂度 $O(n \log n)$。[代码](https://atcoder.jp/contests/agc005/submissions/79595197)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
