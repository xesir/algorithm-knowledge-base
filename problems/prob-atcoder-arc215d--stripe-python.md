---
id: prob-atcoder-arc215d
title: 'cresc.'
oj: 'AtCoder'
problemId: 'ARC215D'
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

暂无（原题：[ARC215D](https://www.luogu.com.cn/problem/AT_arc215_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$，求满足以下条件的非负整数序列 $s_1\sim s_n$ 的数目：
>
> - $s_1 \ge s_2 \ge \cdots \ge s_n$。
> - 存在序列 $a_1 \sim a_{n+1}$，满足 $a_i \in [0,m]$ 且 $\forall i \in [1,n], s_i=a_i+a_{i+1}$。
>
> $n,m \le 10^7$，2 秒，1024 MB。

:::::success[题解]

将 $s_i$ 的定义式代入合法条件
$$
a_1+a_2 \ge a_2+a_3 \ge a_3+a_4 \ge \cdots \ge a_n+a_{n+1}
$$
可以得到 $a_i$ 的约束条件：

- $a_1 \ge a_3 \ge a_5 \ge  \cdots $。
- $a_2 \ge a_4 \ge a_6 \ge \cdots$。

直接对 $a_1 \sim a_{n+1}$ 计数是错的，因为 $a \leftrightarrow s$ 不是双射。

注意到对确定的 $s_1 \sim s_n$，合法的一族 $a$ 形如 $[a_1 + \delta,a_2-\delta,a_3+\delta,\cdots]$。钦定代表元为 $\delta$ 取极限值的序列 $a$，则 $a$ 有下列约束：

- $a_1=m \lor a_x=0$。其中 $x$ 为最大的偶数下标。

消除平移后得到 $a \leftrightarrow s$ 的双射。设奇数下标数目为 $p=\left\lceil \frac{n+1}{2} \right\rceil$，偶数下标数目为 $q=\left\lfloor \frac{n+1}{2} \right\rfloor$，奇偶位置独立，可以分类计数：

- $a_1=m$ 时：
  - 奇数位对值域 $[0,m]$，长为 $p-1$ 的不降序列计数，方案数 $\dbinom{m+p-1}{m}$。
  - 偶数位对值域 $[0,m]$，长为 $q$ 的不降序列计数，方案数 $\dbinom{m+q}{m}$。
- $a_x=0$ 时，同理可得方案数 $\dbinom{m+p}{m}\dbinom{m+q-1}{m}$。
- $a_1 =m \land a_x=0$ 时，同理可得方案数 $\dbinom{m+p-1}{m}\dbinom{m+q-1}{m}$。

二元容斥即可得到答案。复杂度 $O(n+m)$。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
