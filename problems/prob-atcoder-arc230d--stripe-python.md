---
id: prob-atcoder-arc230d
title: 'Min Max Matrix'
oj: 'AtCoder'
problemId: 'ARC230D'
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

暂无（原题：[ARC230D](https://www.luogu.com.cn/problem/AT_arc230_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m,k$，对满足下列条件的 $n \times m$ 矩阵 $a_{i,j}$ 计数：
>
> - $\forall i\in [1,n]\land j \in [1,m], a_{i,j} \in [1,k]$。
> - $\min \limits_{i \in [1,n]} \max\limits_{j \in [1,m]} a_{i,j}=\max \limits_{j \in [1,m]} \min \limits_{i \in [1,n]} a_{i,j}$。
>
> $n,m \le 200$，$k \le 10^8$，4 秒，1024 MB。

::::::success[题解]

设 $X=\min \limits_{i \in [1,n]} \max\limits_{j \in [1,m]} a_{i,j}, Y=\max \limits_{j \in [1,m]} \min \limits_{i \in [1,n]} a_{i,j}$。

**性质** 对任意矩阵，必有 $X \ge Y$ 成立。

**证明** 取任意位置 $(i,j)$，有 $\min\limits_{i' \in [1,n]} a_{i',j} \le a_{i,j} \le \max\limits_{j'\in [1,m]} a_{i,j'}$ 恒成立。

从而 $\forall i \in [1,n], \max\limits_{j \in [1,m]}\min\limits_{i' \in [1,n]} a_{i',j} \le \max\limits_{j' \in [1,m]} a_{i,j'}$。对右侧取 $\min$ 得 $\max\limits_{j \in [1,m]}\min\limits_{i' \in [1,n]} a_{i',j} \le \min\limits_{i \in [1,n]}\max\limits_{j' \in [1,m]} a_{i,j'}$，即证 $Y \le X$。

枚举 $X=Y=t$，设 $f(x,y)$ 为 $X \ge x \land Y \le y$ 的矩阵数，二元容斥求出答案
$$
\sum_{t=1}^k \left(f(t,t)-f(t+1,t)-f(t,t-1)+f(t+1,t-1)\right)
$$
拆开 $X \ge x \land Y \le y$ 的合法条件得

- $\forall i\in [1,n],  \exists j \in [1,m],a_{i,j} \ge x$。
- $\forall j\in [1,m], \exists i \in [1,n],a_{i,j} \le y$。

对行列独立容斥，钦定突破限制的行号集合 $S \subseteq [1,n]$，列号集合 $T \subseteq [1,m]$ 使得：

- 对 $i \in S$ 满足 $\forall j \in [1,m], a_{i,j} < x$。
- 对 $j \in T$ 满足 $\forall i \in [1,n], a_{i,j}>y$。
- 对 $i \notin S \land j \notin S$ 的 $a_{i,j}$ 无限制。

容斥系数 $(-1)^{|S|} (-1)^{|T|}=(-1)^{|S|+|T|}$。对 $(i,j)$ 位置分讨：

- 若 $i \in S \land j \in T$，则 $a_{i,j} \in (y,x)$，方案数 $\max(0,x-y-1)$。
- 若 $i \in S \land j \notin T$，则 $a_{i,j} \in [1,x)$，方案数 $x-1$。
- 若 $i \notin S \land j \in T$，则 $a_{i,j} \in (y,k]$，方案数 $k-y$。
- 若 $i \notin S \land j\notin T$，则 $a_{i,j} \in [1,k]$，方案数 $k$。

特判 $x-y<1$。直接枚举 $|S|=p, |T|=q$ 得到方案数
$$
f(x,y)=\sum_{p=0}^n \sum_{q=0}^m (-1)^{p+q} \binom{n}{p} \binom{m}{q} (x-y-1)^{pq} (x-1)^{p(m-q)} (k-y)^{(n-p)q} k^{(n-p)(m-q)}
$$
复杂度 $O(nmk)$ 无法通过。根据二项式定理化简 $f$ 有
$$
\begin{aligned}
f(x,y)&=\sum_{p=0}^n (-1)^p\binom{n}{p} \sum_{q=0}^m (-1)^{q} \binom{m}{q} \left((x-y-1)^{p}\right)^{q} \left((x-1)^{p}\right)^{m-q} \left((k-y)^{n-p}\right)^q (k^{n-p})^{m-q}\\
&=\sum_{p=0}^n (-1)^p\binom{n}{p}  \sum_{q=0}^m  \binom{m}{q} \left((-1)(x-y-1)^{p} (k-y)^{n-p}\right)^q \left((x-1)^{p}k^{n-p}\right)^{m-q}\\
&=\boxed{\sum_{p=0}^n  (-1)^p\binom{n}{p} \left((x-1)^{p}k^{n-p}-(x-y-1)^{p} (k-y)^{n-p}\right)^{m}}
\end{aligned}
$$
复杂度 $O(nk \log m)$ 可以通过 [CF2048G](https://www.luogu.com.cn/problem/CF2048G)。

**观察** $f(x,y)$ 是关于 $x,y$ 的 $n\times m$ 次多项式。

求答案形如 $\sum f(t,t)$，前缀和后次数 $+1$。我们求出前 $nm+2$ 个 $f$ 后，用 Lagrange 插值线性求出 $t$ 处的点值即可。

:::::info[Lagrange 插值]

**问题** 给定 $n+1$ 个点 $(x_0,y_0) \sim (x_n,y_n)$，确定 $n$ 次多项式 $f$ 使得 $\forall i \in [0,n], f(x_i)=y_i$。

Lagrange 插值给出公式
$$
f(x)=\boxed{\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}}
$$
将 $x$ 代入可以 $O(n^2)$ 求点值。对于多点求值问题，可以暴力多项式除法算出系数做到 $O(n^2)-O(n)$。

特别地，若横坐标满足 $x_i=i$，代入插值公式
$$
\begin{aligned}
f(x)&=\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-j}{i-j}\\\
&=\sum_{i=0}^n \dfrac{y_i}{x-i}\prod_{j=0}^n (x-j) \prod_{j \ne i} \dfrac{1}{i-j}\\
&=\boxed{\sum_{i=0}^n \dfrac{y_i}{x-i} \times \dfrac{(-1)^{n-i}}{i!(n-i)!}\prod_{j=0}^n (x-j)}
\end{aligned}
$$
线性预处理 $\prod\limits_{j=0}^n (x-j)$ 及 $x-i$ 的逆元和阶乘逆，可以 $O(n)$ 单点求值。注意特判 $x \in [0,n]$ 的情形。

:::::

复杂度 $O(n^2m \log m)$ 可以通过本题。[代码](https://www.luogu.com.cn/article/1gcq46ur)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
