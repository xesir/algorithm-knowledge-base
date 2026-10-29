---
id: prob-cf-1485f
title: 'Copy or Prefix Sum'
oj: 'Codeforces'
problemId: 'CF1485F'
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

暂无（原题：[CF1485F](https://www.luogu.com.cn/problem/CF1485F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $b_i$。计数序列 $a_1 \sim a_n$ 满足：
>
> - $\forall i \in [1,n], b_i=a_i$ 或 $b_i=\sum \limits_{k=1}^i a_k$。
>
> 多测，$\sum n \le 2 \times 10^5$，$|b_i| \le 10^9$，2 秒，250 MB。

:::::success[题解]

容易列得朴素 DP：

- 设 $f_{i,j}$ 为满足下列条件的方案数：

  - 仅考虑 $a_1 \sim a_i$。
  - $\sum \limits_{k=1}^i a_k=j$。

- 转移枚举 $a_{i+1}$ 的取值。

  - 取 $b_{i+1}=a_{i+1}$，转移 $f_{i,j} \to f_{i+1,j+b_{i+1}}$。
  - 取 $b_{i+1}=\sum \limits_{k=1}^{i+1} a_k$，转移 $f_{i,j} \to f_{i+1,b_{i+1}}$。

  注意特判转移重叠的情形。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $\sum \limits_{j} f_{n,j}$。

对 $f$ 滚动数组，考察上述转移：

- $f_{j} \to f'_{j+b_{i+1}}$ 是全局平移。
- $f_j\to f'_{b_{i+1}}$ 是总和对单点加法。

用哈希表维护 $f$ 数组，记录偏移量与 $\sum f$ 即可。复杂度 $O(n \log n)$。[代码](https://www.luogu.com.cn/article/juk9r4qy)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
