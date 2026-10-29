---
id: prob-luogu-p13011
title: '【MX-X13-T6】「KDOI-12」能做到的也只不过是静等缘分耗尽的那一天。'
oj: '洛谷'
problemId: 'P13011'
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

暂无（原题：[P13011](https://www.luogu.com.cn/problem/P13011)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对于 $1 \sim n$ 的排列 $p_i$，建立其大根笛卡尔树，并断开每个点与其右儿子（如果存在）的连边，记最后所成的森林为 $T(p)$。
>
> 给出 $q$ 次询问 $n,x,y$，求所有 $1 \sim n$ 的排列中，有多少种 $p$ 满足：在 $T(p)$ 上节点 $x,y$ 位于同一颗树中。
>
> $n \le 5 \times 10^6$，$q \le 10^6$，2 秒，512 MB。

:::::success[题解]

考虑刻画合法的充要条件。

若 $x=y$ 答案显然为 $n!$，否则不妨设 $x<y$。

首先，$p_x>p_y$ 是不合法的，原因是 $y \to x$ 必然要经过一条右链。

进一步，如果 $(x,y)$ 中间有更高的数也是不合法的，如下图所示。此时 $x,y$ 会被区间 $\max$ 划分到两个子树中，而 $y$ 位于右子树。

![](https://cdn.luogu.com.cn/upload/image_hosting/c2tg28co.png)

我们考虑 $x$ 的左侧。注意到，若 $x$ 左侧存在一个更高的数 $z$，则 $x,y$ 都会被 $z$ 划分到其右子树中，且 $(x,y)$ 中间不会被打断，也即 $y \to x$ 全为左链，这是合法的。

![](https://cdn.luogu.com.cn/upload/image_hosting/eyqij8kv.png)

另一种情况是，$x$ 左侧有一个 $(p_x,p_y)$ 之间的数 $z$。

![](https://cdn.luogu.com.cn/upload/image_hosting/znmvbdls.png)

此时 $x \to z$ 全为左链，但 $x$ 被划分到 $z$ 的右子树中，也即 $y \to x$ 经过右链，这不合法。

最后一种情况是，$x$ 左侧所有数都不在 $(p_x,p_y)$ 中。容易说明，$x,y$ 要么被同时划分进右子树，要么 $x$ 被划分进 $y$ 的左子树，这是合法的。

形式化地，合法的排列 $p_i$ 同时满足以下条件：

- $p_x<p_y$。
- $\forall i \in (x,y), p_i <p_y$。
- $\exists z <x, p_z >p_y, \forall i \in (z,x), p_i \notin (p_x,p_y)$ 或 $\forall i \in[1,x), p_i \notin (p_x,p_y)$。

考虑枚举 $p_x=a,p_y=b$，枚举并钦定 $z$ 为满足条件的最大的 $z$。分析排列的结构：

- $1 \sim z-1$ 段：可以任取。
- $z$：可以取 $(b,n]$ 中的数。
- $z+1 \sim x-1$ 段：可以取 $[1,a)$ 中的数。
- $x$：可以取 $\{a\}$ 中的数。
- $x+1 \sim y-1$ 段：可以取 $[1,b)$ 中的数。
- $y$：可以取 $\{b\}$ 中的数。
- $y+1 \sim n$ 段：可以任取。

我们依次决定 $[1,a), [1,b), (b,n]$ 中数的归属，每段的方案数都是一个排列数。于是这种情况的方案数为
$$
S_2=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-(x-z-1)-1}^{y-x-1} A_{n-3-(x-z-1)-(y-x-1)}^{n-y+z-1}
$$
通过类似的讨论，可以得到另一种情况的方案数为
$$
S_1=\sum_{a=1}^n \sum_{b=a+1}^n A_{a-1}^{x-1} A_{b-1-(x-1)-1}^{y-x-1}A_{n-2-(x-1)-(y-x-1)}^{n-y}
$$
答案即为 $S_1+S_2$。至此 $O(qn^3)$。

开始大力推式子。首先，将 $S_2$ 中的排列数都变成组合数，并且对 $a$ 求和可以得到一个组合数上指标前缀和的形式：
$$
\begin{aligned}
S_2&=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-(x-z-1)-1}^{y-x-1} A_{n-3-(x-z-1)-(y-x-1)}^{n-y+z-1}\\
&=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-x+z}^{y-x-1} A_{n-y+z-1}^{n-y+z-1}\\
&= \sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{a-1}{x-z-1}\binom{b-1-x+z}{y-x-1}\\
&= \sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{b-1-x+z}{y-x-1} \sum_{a=1}^{b-1}  \binom{a-1}{x-z-1}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{b-1-x+z}{y-x-1} \binom{b-1}{x-z}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \dfrac{(b-1-x+z)!}{(y-x-1)!(b-y+z)!} \times \dfrac{(b-1)!}{(x-z)!(b-1-x+z)!}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!\dfrac{(b-1)!}{(b-y+z)!(x-z)}
\end{aligned}
$$
至此 $O(qn^2)$。

继续推。首先利用组合数上指标前缀和的结论化简 $S_1$ 有
$$
\begin{aligned}
S_1&=\sum_{a=1}^n \sum_{b=a+1}^n A_{a-1}^{x-1} A_{b-1-(x-1)-1}^{y-x-1}A_{n-2-(x-1)-(y-x-1)}^{n-y}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! \sum_{a=x}^{b-1} A_{a-1}^{x-1}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! (x-1)!\sum_{a=x}^{b-1} \binom{a-1}{x-1}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! (x-1)!\binom{b-1}{x}\\
&=\sum_{b=y}^n \frac{(b-x-1)!}{(b-y)!}  (n-y)! (x-1)! \frac{(b-1)!}{x!(b-x-1)!}\\
&= \dfrac{(n-y)!}{x} \sum_{b=y}^n \dfrac{(b-1)!}{(b-y)!}\\
&= \dfrac{(n-y)!(y-1)!}{x}  \sum_{b=y}^n \binom{b-1}{y-1}\\
&= \dfrac{(n-y)!(y-1)!}{x}\binom{n}{y}\\
&= \boxed{\dfrac{n!}{xy}}
\end{aligned}
$$
接着化简 $S_2$。考虑使用组合恒等式
$$
\sum_{b=k+1}^n (n-b) \binom{b-1}{k}=\binom{n}{k+2}
$$
其组合意义为：从 $n$ 个元素中取出 $k+2$ 个，枚举并钦定倒数第二个元素所在的位置 $b$。

将这个恒等式代入 $S_2$ 得
$$
\begin{aligned}
S_2&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!\dfrac{(b-1)!}{(b-y+z)!(x-z)}\\
&=\sum_{z=1}^{x-1} (n-y+z-1)!\sum_{b=1}^n(n-b)\dfrac{(b-1)!}{(b-y+z)!(x-z)!}\\
&=\sum_{z=1}^{x-1} (n-y+z-1)! \dfrac{(y-z-1)!}{x-z} \sum_{b=1}^n(n-b)\binom{b-1}{y-z-1}\\
&= \sum_{z=1}^{x-1} (n-y+z-1)! \dfrac{(y-z-1)!}{x-z} \binom{n}{y-z+1}\\
&= \sum_{z=1}^{x-1} (n-y+z-1)!  \dfrac{(y-z-1)!}{x-z} \dfrac{n!}{(y-z+1)! (b-y+z-1)!}\\
&= \sum_{z=1}^{x-1}  \dfrac{n!}{(x-z)!(y-z)!(y-z+1)!}
\end{aligned}
$$
至此 $O(qn)$。模拟赛时止步于此。

考虑将求和式彻底拆开。令 $k=x-z,d=y-x$，于是
$$
\begin{aligned}
S_2&= \sum_{k=1}^{x-1} \dfrac{1}{k(k+d)(k+d+1)}
\end{aligned}
$$
使用裂项的技巧：
$$
\begin{aligned}
S_2&= \sum_{k=1}^{x-1} \dfrac{1}{k(k+d)(k+d+1)}\\
&= \sum_{k=1}^{x-1} \left(\dfrac{1}{d(d+1)} \left(\dfrac{1}{k}-\dfrac{1}{k+d} \right)-\dfrac{1}{d+1} \left(\dfrac{1}{k+d}-\dfrac{1}{k+d+1}\right)\right)\\
&= \boxed{-\dfrac{n!(x-1)}{y(y-x+1)^2}+\dfrac{n!}{(y-x)(y-x+1)} (H_{x-1}+H_{y-x}-H_{y-1})}
\end{aligned}
$$
其中 $H_n$ 为调和级数 $H_n=\sum \limits_{i=1}^n i^{-1}$。

至此，使用线性逆元预处理 $H_n$ 和阶乘，复杂度 $O(q+n)$。[代码](https://www.luogu.com.cn/article/yumpahmx)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
