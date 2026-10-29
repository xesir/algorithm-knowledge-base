---
id: prob-atcoder-abc267g
title: 'Increasing K Times'
oj: 'AtCoder'
problemId: 'ABC267G'
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

暂无（原题：[ABC267G](https://www.luogu.com.cn/problem/AT_abc267_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出长为 $n$ 的序列 $a_i$，求有多少个 $1 \sim n$ 的排列 $p_i$ 满足 $\text{asc}(a_{p_i})=k$。$\text{asc}$ 为上升数目。
>
> $n \le 5\times 10^3$，2 秒，1024 MB。

:::::success[题解]

题目相当于求 $a_i$ 有多少个重排的上升数目恰为 $k$。考虑计数本质不同的重排，答案乘上 $\prod c_i!$ 即可，其中 $c_i$ 是第 $i$ 种数的出现次数。

考虑使用插入 DP 解决问题，计数顺序是从小到大插入、

- 用 $f_{n,k}$ 表示当前已经插入了 $1 \sim n$ 中的数字，上升的数目恰为 $k$ 的方案数。

- 用刷表法转移，即从 $f_{n,k}$ 转移到 $f_{n+1,k'}$。我们一次性插入所有数字 $n+1$，设其有 $c$ 个，讨论转移系数。

  - 记 $m$ 为序列长度，考虑序列 $x_1,x_2,\cdots,x_{m+1}$，其满足 $\sum \limits_{i=1}^{m+1} x_i=c$。$x_i$ 的组合意义是第 $i$ 个空位中插入了几个 $n+1$。

  - 由于所有插入的数都相同，只要讨论非零的 $x_i$ 对 $k'$ 的贡献：

    - 在原序列中，共有 $k$ 个上升空位，贡献为 $0$。
    - 在原序列中，共有 $m-1-k$ 个下降空位，贡献为 $1$。
    - 插入开头，形成一个下降，贡献为 $0$。
    - 插入结尾，形成一个上升，贡献为 $1$。

    综上，考虑枚举总贡献量 $i$，转移系数就是 $x_1 \sim x_{m-k}$ 中恰有 $i$ 个非零元素的方案数。

  - 考虑分步计数：

    - 先钦定 $i$ 个元素非零，方案数 $\dbinom{m-k}{i}$。

    - 设选出的变量为 $y_1 \sim y_i$，其余变量强制为 $0$。$x_{m-k+1} \sim x_{m+1}$ 的变量记为 $z_1 \sim z_{k+1}$。

    - 再使用不定方程模型的技巧计算。即令 $y'_i=y_i-1$，方程变为 $\left(\sum \limits_{j=1}^i y'_i\right)+\left(\sum\limits_{j=1}^{k+1} z_i \right)=c-i$。这是一个 $i+k+1$ 个变量的不定方程正整数解计数，方案数
      $$
      \binom{(c-i)+(i+k-1)-1}{(i+k+1)-1}=\binom{c+k}{i+k}
      $$

  - 综上所述，转移式 $f_{n,k} \to \dbinom{m-k}{i} \dbinom{c+k}{i+k}f_{n+1,k+1}$。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $f_{n,k} \prod c_i!$。

直观感受复杂度是 $O(n^3)$ 的。不过注意到 $i \le c$ 时转移才有意义，故 $i$ 的总枚举次数是 $\sum c_i=n$，因此复杂度只有 $O(n^2)$。[代码](https://atcoder.jp/contests/abc267/submissions/76748988)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
