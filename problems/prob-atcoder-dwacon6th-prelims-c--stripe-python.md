---
id: prob-atcoder-dwacon6th-prelims-c
title: 'Cookie Distribution'
oj: 'AtCoder'
problemId: 'DWACON6TH_PRELIMS_C'
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

暂无（原题：[DWACON6TH_PRELIMS_C](https://www.luogu.com.cn/problem/AT_dwacon6th_prelims_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$ 和长为 $k$ 的序列 $a_i$。重复 $k$ 次操作，第 $i$ 次操作任意选择 $a_i$ 个位置 $p_1 \sim p_{a_i}$，并将 $b_{p_x} \gets b_{p_x}+1$。求所有情况下 $\prod b_i$ 的总和。
>
> $n \le 10^3$，$k \le 20$，2.52 秒，1024 MB。

::::::success[题解]

形如 $\sum \prod b_i$ 的计数问题，可以考虑 [Product Trick](https://codeforces.com/blog/entry/98624)。

我们考察 $\prod b_i$ 的组合意义：有 $n$ 个盒子，第 $i$ 次操作选择 $a_i$ 盒子扔进一个颜色为 $i$ 的球，最后盒子里有 $b_i$ 个球。$\prod b_i$ 即为从每个盒子中选择一个球的方案数。

切换计数主体。设最终 $x_i$ 个盒子选择的球为颜色 $i$，必有 $\sum x_i=n$ 且 $x_i \le a_i$。下面构造 $x_1 \sim x_k$ 对应的操作方案。

- 将 $n$ 种盒子分配给 $k$ 种颜色，使得颜色 $i$ 被 $x_i$ 个位置钦定。方案数 $\dbinom{n}{x_1,x_2,\cdots,x_k}$。注意第一步的组合意义是分配盒子标号，相当于确定了这 $x_i$ 个位置的具体内容。
- 对于第 $i$ 次操作，其需要选择 $a_i$ 个盒子。
  - 必须选择 $x_i$ 个特定盒子满足第一步钦定，方案数 $1$。
  - 在剩余 $n-x_i$ 个盒子中，随意选择 $a_i-x_i$ 个位置，方案数 $\dbinom{n-x_i}{a_i-x_i}$。

由乘法原理合并得到

$$
\binom{n}{x_1,x_2,\cdots,x_k} \prod_{i=1}^k\binom{n-x_i}{a_i-x_i}=\boxed{n!\prod_{i=1}^k \dfrac{1}{x_i!} \binom{n-x_i}{a_i-x_i}}
$$

:::::success[代数推导]

下面给出这个式子的代数推导方法。

注意到 $\prod\limits_{j=1}^{n} b_j=\prod\limits_{j=1}^{n} \sum\limits_{i=1}^k A_{j,i}$，其中 $A_{j,i} \in \{0,1\}$ 表示第 $i$ 次操作是否选择 $j$，且 $\sum\limits_{j=1}^n A_{j,i}=a_i$。

对 $\prod\limits_{i=1}^{n} \sum\limits_{j=1}^k A_{j,i}$ 使用乘法分配律，设我们从第 $j$ 个括号中选择第 $c_j$ 项，则 $c_j \in [1,k]$ 且答案式变为
$$
\sum_{A}\sum_{c_1 \sim c_n} \prod_{j=1}^n A_{j,c_j}=\sum_{c_1 \sim c_n} \sum_{A }\prod_{j=1}^n A_{j,c_j}
$$
对固定的 $c_1 \sim c_n$，乘积 $\prod\limits_{j=1}^n A_{j,c_j}=1$ 的充要条件为 $\forall j \in [1,n], A_{j,c_j}=1$。记 $x_i=\sum \limits_{j=1}^n [c_j=i]$，则 $x_i$ 个位置强制 $A_{j,c_j}=1$ 且剩余位置自选，从而
$$
\sum_{A }\prod_{j=1}^n A_{j,c_j}=\prod_{i=1}^k \binom{n-x_i}{a_i-x_i}
$$
只要乘上 $c_1 \sim c_n$ 的选法数目。这是多重组合数的定义，系数为 $\dbinom{n}{x_1,x_2,\cdots,x_k}$。

:::::

这个形式是容易 DP 的：

- 设 $f_{i,j}$ 为满足如下条件时，所有 $x_1 \sim x_i$ 序列的 $\prod\limits_{k=1}^i \dfrac{1}{x_k!} \dbinom{n-x_k}{a_k-x_k}$ 之和：
  - 仅考虑 $x_1 \sim x_i$。
  - $\sum \limits_{k=1}^i x_k=j$。
- 转移枚举 $x_{i} \in [0,a_i]$，刷表 $\dfrac{1}{x_i!} \dbinom{n-x_i}{a_i-x_i} \times f_{i-1,j} \to f_{i,j+x_i}$。
- DP 初值为 $f_{0,0}=1$。
- 答案为 $n! \times f_{k,n}$。

DP 状态数 $O(nk)$，转移枚举量 $a_i \le n$，总复杂度 $O(n^2k)$ 可以通过。[代码](https://www.luogu.com.cn/article/6e101rnl)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
