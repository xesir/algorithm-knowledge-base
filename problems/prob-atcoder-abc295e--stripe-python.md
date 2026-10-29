---
id: prob-atcoder-abc295e
title: 'Kth Number'
oj: 'AtCoder'
problemId: 'ABC295E'
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

暂无（原题：[ABC295E](https://www.luogu.com.cn/problem/AT_abc295_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$，值域为 $[0,m]$。对于每个 $a_i=0$ 的位置 $i$，独立等概率地选择 $x \in [1,m]$ 令 $a_i \gets x$。求第 $k$ 小数的期望值。
>
> $k,n,m \le 2 \times 10^3$，4 秒，1024 MB。

::::::success[题解]

01 转化 trick。观察如下代数式
$$
\sum_{a} a_k=\sum_{a}\sum_{i=1}^{m} [i \le a_k] = \sum_{i=1}^m \sum_a [i \le a_k]
$$
考虑枚举 $i \in [1,m]$，对 $i \le a_k$ 的 $a$ 序列计数。不妨计数 $a_k<i$ 的 $a$ 序列数目。

设初始空位有 $c$ 个，原本 $<i$ 的数有 $x$ 个。枚举最终 $<i$ 的位置的数目 $j$，进行分步计数：

- 从 $c$ 个空位中选择 $j-x$ 个，方案数 $\dbinom{c}{j-x}$。
- 给 $j-x$ 个空位填入 $1 \sim i-1$ 中的数，方案数 $(i-1)^{j-x}$。
- 给 $c-(j-x)$ 个空位填入 $i \sim m$ 中的数，方案数 $(m-i+1)^{c-j+x}$。

由乘法原理合并，写出答案式
$$
\boxed{\sum_{i=1}^m\left( m^c-\sum_{j =\max(x,k)}^{c+x} \binom{c}{j-x}(i-1)^{j-x}(m-i+1)^{c-j+x}\right)}
$$
除以 $m^c$ 即为期望。复杂度 $O(nm)$。

:::::info[01 转化]

代数表达是下面的式子
$$
\sum_{i=1}^n a_i=\sum_{i=1}^n \sum_{j \ge 1} [a_i \ge j]=\sum_{j \ge 1} \sum_{i=1}^n [a_i\ge j]
$$
组合意义就是枚举 $j$，将 $\ge j$ 的数视作 $1$，$<j$ 的数视作 $0$，求 01 序列总和。

对于排序 / kth / 中位数相关的题目，考察 $0/1$ 的行为，一般会比考察所有数的行为简单很多。

:::::

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
