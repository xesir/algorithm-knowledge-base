---
id: prob-atcoder-arc231e
title: 'Odd Inversion'
oj: 'AtCoder'
problemId: 'ARC231E'
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

暂无（原题：[ARC231E](https://www.luogu.com.cn/problem/AT_arc231_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$，对满足下列条件的 $b_1 \sim b_n$ 计数：
>
> - $\forall i \in [1,n], 1 \le b_i \le a_i$。
> - $b$ 的逆序对数为奇数。
>
> 多测，$\sum n \le 4 \times 10^5$，$a_i \le 10^9$，2 秒，1024 MB。

:::::success[题解]

设 $\text{inv}(b)$ 为偶数的序列有 $c_0$ 个，奇数的序列为 $c_1$ 个。则总方案数
$$
c_0+c_1=\prod_{i=1}^n a_i
$$
转为求解 $c_0-c_1$ 后解方程得到答案。考虑递推：

- 设 $f_i$ 为仅考虑 $b_1 \sim b_i$ 时 $c_0-c_1$ 的值。

- 转移讨论 $b_i$ 的取值：

  - 若 $b_i=b_{i-1}$，则删去 $i-1$ 和 $i$ 后奇偶性不变，转移 $a_{i-1}f_{i-2} \to f_i$。
  - 若 $b_i \ne b_{i-1}$，对 $\max(b_{i-1},b_i) \le a_{i-1}$ 的序列，将 $i-1$ 和 $i$ 交换后奇偶性 flip 故成对抵消。只需计数 $\max(b_{i-1},b_i)>a_{i-1}$ 的部分，转移 $(a_i-a_{i-1}) f_{i-1} \to f_i$。

  将两部分合并得二阶递推
  $$
  \boxed{f_i=(a_i-a_{i-1})f_{i-1}+a_{i-1}f_{i-2}}
  $$

- 初值为 $f_0=0, f_1=a_1$。

- 答案为 $c_0+c_1=f_n$。

复杂度 $O(n)$。[代码](https://atcoder.jp/contests/arc231/submissions/79797002)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
