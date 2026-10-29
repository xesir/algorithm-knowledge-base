---
id: prob-zr-3365
title: '马戏表演'
oj: '正睿'
problemId: 'ZR3365'
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

暂无（原题：[ZR3365](https://www.zhengruioi.com/problem/3365)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$。对 $1 \sim n$ 的排列 $p_i$，设 $c_i$ 表示 $p_i$ 成为了多少个区间 $\max$，形式化地 $c_i=\sum \limits_{i \in [l,r]} \left[\max \limits_{j=l}^r a_j=a_i\right]$。
>
> 求 $\forall i \in [1,n], c_i \le m$ 的 $p$ 的数目。
>
> $n \le 10^7$，$m \le \binom{n+1}{2}$，2 秒，512 MB。

:::::success[题解]

我们在大根笛卡尔树上 DP。枚举 $\max$ 的位置为 $x$，则 $c_x=x(n+1-x)$。

**性质** 若 $c_x \le m$，则 $[1,x)$ 和 $(x,n]$ 中更短的一侧必然合法。

**证明** 不妨设 $2x\le n$ 且 $i \in [1,x)$，只要证 $i(x-i) < c_x$。放缩 $i(x-i) < x^2$， 又有 $x(n+1-x) > x^2+x > x^2$ 即证。

设 $f_n$ 为长为 $n$ 的合法排列数目。若 $\left\lceil \dfrac{n}{2}\right\rceil\left(\left\lfloor \dfrac{n}{2} \right\rfloor+1\right) \le m$ 则排列必然合法，$f_n=n!$。否则按照性质进行 DP：

- 枚举最大值的位置 $x$，钦定 $2x \le n$，由对称性答案 $\times 2$ 即可。
- 从 $n$ 个数中选 $x-1$ 个数放在左侧，方案数 $A_n^{x-1}$。
- 右侧 $n-x$ 个数只关心相对大小，视作排列计数，答案为 $f_{n-x}$。

从而转移方程为
$$
f_n=2 \times \sum_{2x \le n \land x(n+1-x) \le m} A_n^{x-1} f_{n-x}
$$
拆开排列数推式子：
$$
\begin{aligned}
f_n&=2\sum_{2x \le n} [x(n+1-x) \le m] \dfrac{n!}{(n-x+1)!}f_{n-x}\\
&= \boxed{2\dfrac{n!}{n}\sum_{2x \le n} [x(n+1-x) \le m] \dfrac{f_{n-x}}{(n-x)!}}
\end{aligned}
$$
满足 $2x \le n \land x(n+1-x) \le m$ 的 $x$ 是一段前缀，可以解不等式 $O(1)$ 求出，维护 $\dfrac{f_n}{n!}$ 的前缀和即可。使用线性逆元并预处理阶乘，复杂度 $O(n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
