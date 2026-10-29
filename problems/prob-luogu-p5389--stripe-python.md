---
id: prob-luogu-p5389
title: '[Cnoi2019] 数学课'
oj: '洛谷'
problemId: 'P5389'
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

暂无（原题：[P5389](https://www.luogu.com.cn/problem/P5389)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有长为 $n$ 的数列 $a_i=1+2+\cdots+i$。独立地以概率 $p_i,p_j$ 分别选出两个元素 $a_i,a_j$，并等概率地选出整数 $x \in [1,a_i], y \in [1,a_j]$，求 $x>y$ 的概率。
>
> 其中，$p_i=\dfrac{3i(i+1)}{n(n+1)(n+2)}$。$n$ 可能为 $+\infty$。
>
> $1 \le n \le 10^{18}$，或者 $n=+\infty$。1 秒，125 MB。

:::::success[题解]

注意到 $x,y$ 的地位完全相同，很自然地 $P(x<y)=P(x>y)$。那么由对称性我们只需计算 $\dfrac{1-P(x=y)}{2}$。

考虑枚举 $i,j$，然后直接列出答案式

$$
P(x=y)=\sum_{i=1}^n \sum_{j=1}^n p_ip_j \dfrac{\min(a_i,a_j)}{a_ia_j}
$$

我们发现 $\dfrac{p_i}{a_i}$ 是一个不变量，具体地：

$$
\dfrac{p_i}{a_i}=\dfrac{3i(i+1)}{n(n+1)(n+2)} \times \dfrac{2}{i(i+1)}=\dfrac{6}{n(n+1)(n+2)}
$$

记这一常数为 $C$，代入以后大力推式子

$$
\begin{aligned}
P(x=y)&=C^2\sum_{i=1}^n \sum_{j=1}^n \min(a_i,a_j)\\
&=C^2 \sum_{i=1}^n \left(\sum_{j=1}^i a_j+\sum_{j=i+1}^n a_i\right)\\
&=C^2 \sum_{i=1}^n \left(\sum_{j=1}^i \dfrac{j(j+1)}{2}+(n-i)\dfrac{i(i+1)}{2}\right)\\
&=C^2 \sum_{i=1}^n \left(\dfrac{i(i+1)(i+2)}{6}+\dfrac{i(i+1)(n-i)}{2}\right)\\
&= C^2  \sum_{i=1}^n \left(\dfrac{ni(i+1)}{2}+\dfrac{(1-i)i(i+1)}{3}\right)\\
&=C^2 \left(\dfrac{3n+2}{6}\sum_{i=1}^n i(i+1)-\dfrac{1}{3} \sum_{i=1}^n i^2 (i+1)\right)\\
&= C^2 \left(\dfrac{3n+2}{6}\times \dfrac{n(n+1)(n+2)}{3}  -\dfrac{1}{3} \times \dfrac{n(n+1)(3n^2+7n+2)}{12}\right)\\
&=\dfrac{C^2n(n+1)^2(n+2)}{12}\\
&= \dfrac{n(n+1)^2(n+2)}{12}\times  \dfrac{36}{n^2(n+1)^2(n+2)^2}\\
&=\boxed{\dfrac{3}{n(n+2)}}
\end{aligned}
$$

这里用到了一些熟知结论：

- $\sum \limits_{i=1}^n i =\dfrac{n(n+1)}{2}$。
- $\sum \limits_{i=1}^n i^2=\dfrac{n(n+1)(n+2)}{6}$。
- $\sum\limits_{i=1}^n i^3=\dfrac{n^2(n+1)^2}{4}$。

题目保证 $n,n+2$ 非零，故 $n$ 有限的情况可以 $O(\log p)$ 解决。

事实上，$\lim\limits_{n \to +\infty} \dfrac{3}{n(n+2)}=0$，故 $n$ 为正无穷的情形答案就是 $\dfrac{1}{2}$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
