---
id: prob-zr-3652
title: '特征值'
oj: '正睿'
problemId: 'ZR3652'
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

暂无（原题：[ZR3652](https://www.zhengruioi.com/problem/3652)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $m,k$。对数组 $a_1 \sim a_n$，定义 $f(a)$ 为：一次操作选定 $i \in [1,n]$，令 $a_i \gets a_i \pm 1$，使得 $m \mid \sum \limits_{i=1}^n a_i$ 的最小操作次数。
>
> 对数组 $a_1 \sim a_n$，定义特征值 $F(a)=\min\limits_{[l,r] \subseteq [1,n]} f(a_l \sim a_r)$。对每个 $n=1,2,\cdots,m-1$ 求出，所有长为 $n$ 的序列 $a_i$ 满足 $a_i \in [0,m)$ 的 $F^k(a)$ 之和。
>
> 多测，$T \le 20$，$m \le 2\times 10^5$，$k \le 10^9$，1 秒，128 MB。

:::::success[题解]

设 $S=\sum \limits_{i=1}^n a_i$，则 $f(a)=\min(S \bmod m, m - S \bmod m)$。代入 $F$ 的定义后，两个 $\min$ 可以拆掉，变为
$$
\begin{aligned}
F(a)&=\min\left(\min_{[l,r] \subseteq [1,n]} \left(\sum_{i=l}^r a_i\right) \bmod m, \min_{[l,r] \subseteq [1,n]} \left( \left(\sum_{i=l}^r a_i\right)-\left(\sum_{i=l}^r a_i\right) \bmod m\right)\right)\\
&=\min\left(\min_{[l,r] \subseteq [1,n]} (p_r-p_{l-1}) \bmod m, \min_{[l,r] \subseteq [1,n]} \left(p_r-p_{l-1}-(p_r-p_{l-1}) \bmod m\right)\right)
\end{aligned}
$$
其中 $p_n=\left(\sum \limits_{i=1}^n a_i\right) \bmod m$。注意到 $p_1 \sim p_n$ 和 $a_1 \sim a_n$ 是双射，转而对 $p$ 计数。

考虑枚举 $x=F(a)$ 并计数 $p_1 \sim p_n$ 的数目，乘上 $x^k$ 作为答案。不妨将恰好容斥为选择至少，记 $c(x,n)$ 为 $F(a) \ge x$ 的 $a_1 \sim a_n$ 的数目，则 $n$ 的答案为
$$
\text{ans}_n=\sum_{x=0}^n x^k (c(x,n)-c(x+1,n))
$$
下面考虑 $c$ 的求法。由 $F(a) \ge x$ 可列得约束：
$$
\forall 0\le i<j\le n,\left\{\begin{matrix}
 (p_j-p_i) \bmod m &\ge x\\
 p_j-p_i-(p_j-p_i) \bmod m &\ge x
\end{matrix}\right.
$$
令 $i=0$ 可得 $p_j \in [x,m-x]$，条件转化为 $\forall i<j, |p_i-p_j| \ge x$。

取升序序列 $s_1 \sim s_n$，满足下列两个条件：

- $\forall i\in [1,n),s_{i+1}-s_i \ge x$。
- $\forall i\in [1,n], s_i \in [x,m-x]$。

可以证明 $p_1 \sim p_n$ 的升序排列和 $s_1 \sim s_n$ 是双射。对 $s$ 计数后乘系数 $n!$ 即可。

令 $t_i=s_i-x \times i$，则 $t_i \in [0,m-x(n+1)]$ 且 $t_i \ge t_{i+1}$。令 $u=m-x(n+1)$，由不降序列计数，答案为
$$
c(x,n)=\binom{u+n}{n}n!
$$
合法条件为 $u \ge 0$，解得 $x \le \frac{m}{n+1}$。外层循环枚举 $n$，内层枚举 $x$ 到 $\frac{m}{n+1}$ 是调和型枚举。 

注意预处理 $x^k$ 的值，总复杂度 $O(m \log k+m \log m)$。[代码](https://www.zhengruioi.com/submission/1113700)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
