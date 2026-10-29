---
id: prob-luogu-p14514
title: '[NFLSPC #8] 如何区分北京东路和北京东路'
oj: '洛谷'
problemId: 'P14514'
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

暂无（原题：[P14514](https://www.luogu.com.cn/problem/P14514)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一个长为 $n$ 的序列 $a_i$。进行 $k$ 次操作，每次操作随机选择一个 $i$，令 $\forall j \ne i, a_j \gets a_j+\frac{a_i}{n-1}$，并且 $a_i \gets 0$。对每个 $i$ 求出 $k$ 次操作后 $a_i$ 的期望值。
>
> $n \le 10^6$，$k \le 10^9$，1 秒，128 MB。

:::::success[题解]

考虑期望递推。设 $f_i$ 为当前时刻 $a_i$ 的期望值。对于一次操作：

- 选定 $i$，则 $a_i \gets 0$。
- 选定 $j$，其中 $j \ne i$，则 $a_i \gets a_i+\frac{f_j}{n-1}$。

故单次操作的转移式为
$$
f_i \gets \sum_{j \ne i} \dfrac{1}{n} \times  \left(f_i+\dfrac{f_j}{n-1}\right)
$$
注意到操作不改变 $\sum a_i$，必有 $S=\sum \limits_{i=1}^n f_i$ 为定值。代入转移式
$$
\begin{aligned}
f_i&\gets\dfrac{n-1}{n}\left(f_{i}+\dfrac{1}{n-1}\sum_{j \ne i} f_j\right)\\
&=\dfrac{n-1}{n} f_i+\dfrac{1}{n(n-1)} \sum_{j \ne i} f_j\\
&=\dfrac{n-1}{n} f_i + \dfrac{S-f_i}{n(n-1)}\\
&= \dfrac{n-2}{n-1} f_i+\dfrac{S}{n(n-1)}
\end{aligned}
$$
解一阶线性递推得到
$$
f_i=\boxed{\dfrac{S}{n}+\left(a_i-\dfrac{S}{n}\right) \left(\dfrac{n-2}{n-1}\right)^k}
$$
::::info[一阶线性递推]

**问题** 给定递推公式 $a_{n+1}=pa_n+q$，其中 $p \ne 0 \land p\ne 1$，求 $a_n$ 的通项公式。

构造不动点 $x$ 满足 $x=px+q$，解得 $x=\dfrac{q}{1-p}$。

对递推式进行变形：
$$
\begin{aligned}
a_{n+1}&=pa_n+q\\
a_{n+1}-x &= pa_n+q-x\\
a_{n+1}-x &= p(a_n-x)
\end{aligned}
$$
记 $b_n=a_n-x$，上式给出 $b_{n+1}=p \times b_n$，从而 $b_n=b_1 p^{n-1}$。因此 $a_n$ 的通项为
$$
a_n=(a_1-x) p^{n-1}+x
$$
::::

复杂度 $O(n +\log k)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
