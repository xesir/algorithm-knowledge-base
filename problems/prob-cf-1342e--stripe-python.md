---
id: prob-cf-1342e
title: 'Placing Rooks'
oj: 'Codeforces'
problemId: 'CF1342E'
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

暂无（原题：[CF1342E](https://www.luogu.com.cn/problem/CF1342E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$。你需要在 $n \times n$ 的棋盘上放置 $n$ 个车，满足：
>
> - 所有空格子都能被至少一个车攻击。
> - 恰好有 $k$ 对车可以互相攻击。
>
> 求合法方案数。
>
> $n \le 2 \times 10^5$，$k \le \binom{n}{2}$，2 秒，500 MB。

:::::success[题解]

注意到行列的地位相同，下文只对行的形态讨论，由对称性答案 $\times 2$ 即可。

**性质** 满足空格子都能被攻击，则每行恰有一个车。

**证明** 反证法显然。

进一步，恰有 $k$ 对车互相攻击，当且仅当 $n$ 个车恰好占据 $n-k$ 个不同列。可以从 $k=0$ 开始归纳证明。

只要从 $n$ 个列中选出 $k$ 个，并将 $n$ 个有标号球放入 $n-k$ 个有标号盒子。答案为
$$
\boxed{\binom{n}{k} {n\brace n-k} (n-k)!}
$$
若 $k>n$ 无解。注意特判 $k=0$ 的情形，答案为 $n!$。

使用第二类斯特林数的通项公式，复杂度 $O(n \log n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
