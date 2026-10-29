---
id: prob-atcoder-agc005d
title: '~K Perm Counting'
oj: 'AtCoder'
problemId: 'AGC005D'
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

暂无（原题：[AGC005D](https://www.luogu.com.cn/problem/AT_agc005_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$，对满足 $\forall i \in [1,n], |a_i-i| \ne k$ 的 $1\sim n$ 的排列 $a_i$ 计数。
>
> $n \le 2\times 10^3$，2 秒，256 MB。

:::::success[题解]

将 $(i,a_i)$ 拍到二维平面上，约束即 $y=x- k$ 和 $y=x+k$ 两条直线上不能有点。 

考虑容斥，钦定 $m$ 个位置突破限制，剩余 $n-m$ 个位置随意排列，容斥系数 $(-1)^m (n-m)!$。

约束转化为，选择 $m$ 个点位于 $y=x\pm k$ 上，要求横纵坐标两两不同。我们将横纵坐标相同的点连边，则 $m$ 个点构成图的独立集。可以发现图的形态是若干条链：

![](https://cdn.luogu.com.cn/upload/image_hosting/npwddpef.webp)

我们从长为 $n$ 的链上取大小为 $k$ 的独立集，转化为在 $k$ 个选点间插入 $k-1$ 个未选点，剩余点随意，方案数 $\boxed{\dbinom{n-k+1}{k}}$。

设每条链的长度为 $b_i$，则单链的 OGF 为
$$
F_i=\sum_{k \ge 0} \binom{b_i-k+1}{k} x^k
$$
将 $O(n)$ 个 $F$ 暴力卷积后，取 $x^m$ 项系数即为容斥 $m$ 的答案。

复杂度 $O(n^2)$。[代码](https://atcoder.jp/contests/agc005/submissions/79590009)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
