---
id: prob-atcoder-arc139d
title: 'Priority Queue 2'
oj: 'AtCoder'
problemId: 'ARC139D'
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

暂无（原题：[ARC139D](https://www.luogu.com.cn/problem/AT_arc139_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定多重集 $S=\{a_1,a_2,\cdots,a_n\}$，保证 $a_i \in [1,m]$。重复 $k$ 次以下操作：
>
> - 选定 $i \in [1,m]$ 加入 $S$，并从 $S$ 中删去第 $x$ 小元素。
>
> 求所有 $m^k$ 种操作方案的 $\sum\limits_{i \in S} i$ 之和。
>
> $n,m,k \le 2\times 10^3$，2 秒，1024 MB。

:::::success[题解]

根据 01 转化 trick 有
$$
\sum_{i\in S} i=\sum_{i \in S} \sum_{j=1}^m [j \le i]=\sum_{j=1}^m \sum_{i \in S} [i \ge j]
$$
枚举 $j \in [1,m]$，计算 $i \in S \land i \ge j$ 的 $i$ 的贡献。

我们将 $\ge j$ 的数视作 $1$，$<j$ 的数视作 $0$。设当前集合中 $1$ 的数目为 $c$，分析 $c$ 的变化：

- 若操作加入 $1$：
  - 若 $x \le n-c$ 则删去 $0$，$c \gets c+1$。
  - 若 $x>n-c$ 则删去 $1$，$c$ 不变。
- 若操作加入 $0$：
  - 若 $x \le n-c+1$ 则删去 $0$，$c$ 不变。
  - 若 $x>n-c+1$ 则删去 $1$，$c \gets c-1$。

设初始有 $p$ 个数 $\ge j$，操作过程中加入 $q$ 个 $\ge j$ 的数。根据上述讨论，$c$ 的取值与操作顺序无关。记 $r=n-x+1$ 则：

- 若 $p \le r$，则 $c$ 单增且 $\le r$，故 $c=\min(p+q,r)$。
- 若 $p>r$，则 $c$ 单减且 $\ge r$，故 $c=\max(p-(k-q),r)$。

对每个 $j \in [1,m]$，容易求出 $p$ 的取值后枚举 $q$，讨论贡献系数：

- 选出的 $k$ 个数中恰有 $q$ 个数 $\ge j$，方案数 $\binom{k}{q}$。
- $\ge j$ 的 $m-j+1$ 个数任取，方案数 $(m-j+1)^q$。
- $<j$ 的 $j-1$ 个数任取，方案数 $(j-1)^{k-q}$。

综上，答案式子为
$$
\boxed{\sum_{j=1}^m \sum_{q=0}^k \binom{k}{q}(m-j+1)^q (j-1)^{k-q} \times c}
$$
对 $a_i$ 排序后双指针维护 $p$，复杂度 $O(n\log n+mk)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
