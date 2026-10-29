---
id: prob-luogu-p16416
title: '【MX-X28-T5】「FAOI-R12」单人旅行'
oj: '洛谷'
problemId: 'P16416'
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

暂无（原题：[P16416](https://www.luogu.com.cn/problem/P16416)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的三个序列 $a_i,b_i,c_i$。考虑 $1 \sim n$ 的排列 $p_i$，依次对 $i=1,2,\cdots,n$ 执行如下操作：
>
> - 令 $t_i=\text{mex}\{c_{p_i},t_1,t_2,\cdots,t_{i-1}\}$。
>
> 定义排列 $p$ 的权值为 $\prod \limits_{i=1}^n (a_it_i+b_i)$，求所有排列的权值和。
>
> $n \le 5 \times 10^3$，$c_i \le 10^9$，2 秒，512 MB。

:::::success[题解]

设 $M_i=\{t_1,t_2,\cdots,t_{i-1}\}$，必有 $M_i=[1,i] \setminus \{x_i\}$，其中 $x_i$ 是当前 $\text{mex}$。对 $c_i$ 和 $x_i$ 的相等关系分讨：

- 若 $c_i\ne x_i$，则 $t_i=x_i$ 且 $x_{i+1}=i+1$。
- 若 $c_i=x_i$，则 $t_i=i+1$ 且 $x_{i+1}=x_i$。

令全集 $U=\{1,2,\cdots,n\}$，枚举 $S \subseteq U$ 满足：

- 对 $i \in S$，要求 $c_i \ne x_i$。
- 对 $i \in U \setminus S$，要求 $c_i = x_i$。

将 $[c_i \ne x_i]$ 容斥为 $1-[c_i =x_i]$。钦定 $T \subseteq S$ 使得：

- 对 $i\in T$，要求 $c_i = x_i$。
- 对 $i\in S \setminus T$ 无限制。

容斥系数 $(-1)^{|T|}$。可以发现 $(T,S \setminus T, U \setminus S)$ 构成对全集 $U$ 的划分，带着容斥系数进行 DP：

- 设 $f_{i,j}$ 为满足下列条件时，带容斥系数 $(-1)^{|T|}$ 的合法权值和：

  - 仅考虑 $1 \sim i$。
  - 第 $i$ 个位置实际上满足 $c_i \ne x_i$，则 $x_{i+1}=i+1$。
  - 序列 $c$ 中消耗了 $j$ 个带限制元素，即约束 $c_i=x_i$ 的 $c_i$。
  - 仅考虑 $T$ 和 $U \setminus S$ 位置上填入的数。

- 转移时，枚举连续 $k$ 个位置划入 $U \setminus S$，接下来第 $i+k+1$ 个位置划入 $T$ 或 $S \setminus T$。

  - 对于位置 $i+1 \sim i+k$：

    - $x$ 恒为 $i+1$，产生的 $t$ 分别为 $i+2 \sim i+k+1$。权值积 $\prod \limits_{u=1}^k \left(a_{i+u} (i+u+1)+b_{i+u}\right)$。

    - 选定 $k$ 个 $=i+1$ 的数随意排列，方案数 $\dbinom{\text{cnt}_{i+1}}{k}k!$。

    转移系数 $q=k!\dbinom{\text{cnt}_{i+1}}{k}\prod \limits_{u=1}^k \left(a_{i+u} (i+u+1)+b_{i+u}\right)$。

    特别地，若 $i+k=n$，直接将 $q \times f_{i,j}$ 累加到 $\text{ans}_{j+k}$ 中并跳出循环，表示最后一个位置落在 $U \setminus S$ 中。

  - 对于位置 $i+k+1$，产生的 $t$ 为 $i+1$，贡献系数 $w=a_{i+k+1}(i+1) + b_{i+k+1}$。

    - 划入 $T$，转移 $qw(\text{cnt}_{i+1}-k)(-1)f_{i,j} \to f_{i+k+1,j+k+1} $。其中 $\text{cnt}_{i+1}-k$ 是选法数，$-1$ 是容斥系数。
    - 划入 $S \setminus T$，转移 $qw\times f_{i,j} \to f_{i+k+1, j+k}$。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $\sum \limits_{j=0}^n (n-j)!(\text{ans}_j+f_{n,j})$。系数 $(n-j)!$ 是 $|S \setminus T|$ 个元素任意排列的方案数。

注意 $\sum \text{cnt}_i=n$，从而总复杂度 $O(n^2)$。[代码](https://www.luogu.com.cn/article/3yi78w7h)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
