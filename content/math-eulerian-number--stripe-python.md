---
id: math-eulerian-number
title: '欧拉数（排列上升数计数）'
category: '数学'
subcategory: '组合数学'
tags: ['欧拉数', '排列计数', '插入 DP', '容斥']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的计数基础》第 7 节。

## 7. 欧拉数

对于一个 $1 \sim n$ 的排列 $p_i$，我们称 $p_i<p_{i+1}$ 这样的结构为一个上升。**欧拉数** $\left<\begin{matrix}
n \\
k
\end{matrix}\right>$ 定义为恰有 $k$ 个上升的 $1 \sim n$ 的排列数目。将排列 $p_i$ 的上升数记为 $\text{asc}(p)$。

欧拉数是一类特殊的排列计数问题。因此我们可以用排列计数 DP 的观点来求解。欧拉数问题是非常经典的插入 DP 应用。

另外，直接将下降容斥成无限制也是可以做的，下面分别介绍这些做法。

:::::success[插入 DP 观点]

考虑**按值域插入**的 DP 视角。选择插入 DP 的原因是，上升是一个局部性质，插入数字便于刻画上升的变化，也不会对其他信息产生影响。

- 记 $\left<\begin{matrix}
  n \\
  k
  \end{matrix}\right>$ 为 $\text{asc}(p)=k$ 的排列 $p_1 \sim p_n$ 的数目。

- 转移视角为：考虑在长为 $n-1$ 的排列中插入当前最大值 $n$。此时有 $n$ 个空位可以插入。

  - 将 $n$ 插入到开头，形成 $n>a_1$，不增加上升数，方案数 $1$。
  - 将 $n$ 插入到一个原有的上升 $a_i<a_{i+1}$ 中间，形成 $a_i<n>a_{i+1}$，不增加上升数，方案数 $k$。
  - 将 $n$ 插入到结尾，形成 $a_{n-1}<n$，增加 $1$ 个上升，方案数 $1$。
  - 将 $n$ 插入到一个原有的下降 $a_i>a_{i+1}$ 中间，形成 $a_i<n>a_{i+1}$，增加 $1$ 个上升，方案数 $n-1-k$。

  综上所述，转移方程 
  $$
  \left<\begin{matrix}
  n \\
  k
  \end{matrix}\right>=(k+1)\left<\begin{matrix}
  n-1 \\
  k
  \end{matrix}\right>+(n-k)\left<\begin{matrix}
  n-1 \\
  k-1
  \end{matrix}\right>
  $$

复杂度 $O(n^2)$。

:::::

:::::success[容斥观点]

设 $f(k)=\left<\begin{matrix}
n \\
k
\end{matrix}\right>$， $f$ 的组合意义是恰好。

考虑将**恰好**容斥为**钦定至少**。定义 $g(k)$ 为钦定 $k$ 个上升的 $1\sim n$ 的排列数目，$g \to f$ 的容斥系数为 $(-1)^{i-k} \dbinom{i}{k}$。

考察 $g(k)$ 的组合意义。当我们钦定 $k$ 个特定位置时，整个排列实际上被分成 $n-k$ 段。

在一段内，所有位置的符号都是 `<`，也即段内严格递增。而在段与段之间，符号都是 `?`，也即无限制。更进一步，如果我们确定了一段内填入的数字，这些数必须自动排序，所以段内方案数为 $1$，或者说段内数字不带序。

根据上面的分析，$g(k)$ 的组合意义是：将 $n$ 个有标号球划分为 $n-k$ 个非空有标号段。根据球盒模型，我们得到
$$
g(k)=(n-k)! \left\{\begin{matrix}n\\n-k\end{matrix}\right\}
$$
配上容斥系数代入 $f$ 得
$$
\left<\begin{matrix}
n \\
k
\end{matrix}\right>=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k} (n-i)!\left\{\begin{matrix}n\\n-i\end{matrix}\right\}
$$
这就是欧拉数的通项公式。

为了获得更低的复杂度，可以代入第二类斯特林数的通项公式化简。请读者注意，这个过程隐含了第二次容斥。
$$
\begin{aligned}
\left<\begin{matrix}
n \\
k
\end{matrix}\right>&=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k} (n-i)!\left\{\begin{matrix}n\\n-i\end{matrix}\right\}\\
&=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k}\sum_{j=0}^{n-i} (-1)^{n-i-j} \binom{n-i}{j} j^n\\
&= \sum_{i=k}^n \sum_{j=0}^{n-i} (-1)^{n-k-j} \binom{i}{k} \binom{n-i}{j} j^n\\
&= \sum_{j=0}^{n-k} (-1)^{n-k-j} j^n \sum_{i=k}^{n-j} \binom{i}{k} \binom{n-i}{j}\\
&= \sum_{j=0}^{n-k} (-1)^{n-k-j} j^n \binom{n+1}{k+j+1}
\end{aligned}
$$
倒数第一步使用了范德蒙德卷积。令 $i=n-k-j$ 可以得到一个更好看的式子：
$$
\left<\begin{matrix}
n \\
k
\end{matrix}\right>=\sum_{i=0}^{n-k} (-1)^i \binom{n+1}{i} (n-k-i)^n
$$
这是一个 $O(n \log n)$ 的式子。

:::::
