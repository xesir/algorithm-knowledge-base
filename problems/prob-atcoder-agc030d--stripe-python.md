---
id: prob-atcoder-agc030d
title: 'Inversion Sum'
oj: 'AtCoder'
problemId: 'AGC030D'
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

暂无（原题：[AGC030D](https://www.luogu.com.cn/problem/AT_agc030_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$ 和 $m$ 次可选操作 $(x_i,y_i)$。对每个 $i=1,2,\cdots,m$ 依次选择交换 $a_{x_i},a_{y_i}$ 或不操作。
>
> 求 $2^m$ 种操作方案中，最终序列 $a_i$ 的逆序对数之和。
>
> $n,m \le 3 \times 10^3$，3 秒，1024 MB。

:::::success[题解]

不妨将问题视作求逆序对数的期望，乘上 $2^m$ 即为答案。

注意到 $n^2$ 的状态数可以接受，考虑在 DP 中记录每对 $(i,j)$ 的情况：

- 设 $f_{i,j}$ 为当前时刻 $a_i>a_j$ 的**条件概率**。

- 转移依次考虑每个 $(x,y)$ 操作：

  - 若 $x \ne i \land y \ne j$：$f_{i,j}$ 不变。
  - 若 $x=i \land y \ne j$：$f_{x,j} \gets \dfrac{f_{x,j}+f_{y,j}}{2}$。因为 $(x,j)$ 有 $\frac{1}{2}$ 的概率继承原状态，$\frac{1}{2}$ 的概率交换 $a_x,a_y$ 后继承 $(y,j)$ 的状态。
  - 若 $x\ne i \land y=j$：$f_{i,y} \gets \dfrac{f_{i,y}+f_{i,x}}{2}$。
  - 若 $x=i \land y=j$：$f_{x,y} \gets \dfrac{f_{x,y}+f_{y,x}}{2}$。

  注意 $(x,y)$ 的地位相同，故上述转移需要交换 $x,y$ 后再做一次。

- DP 初值为 $f_{i,j}=[a_i > a_j]$。

- 答案为 $m$ 轮转移后的 $2^m\sum \limits_{i<j} f_{i,j}$。

注意到每轮转移只会修改 $O(n)$ 个位置，总复杂度 $O(n^2+nm)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
