---
id: prob-atcoder-arc230a
title: 'Meeting on Tree'
oj: 'AtCoder'
problemId: 'ARC230A'
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

暂无（原题：[ARC230A](https://www.luogu.com.cn/problem/AT_arc230_a)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个节点的无根树。对 $S \subseteq V$，设 $f(S)=\min\limits_{u \in T} \sum\limits_{v \in S} \text{dis}(u,v)$，求所有 $S$ 的 $f$ 值之和。
>
> $n \le 3 \times 10^5$，2 秒，1024 MB。

:::::success[题解]

将贡献拆到每条边上。设删去某条边后形成两个连通块 $P,Q$，记 $x=|P|,y=|Q|$，枚举 $|S \cap P|=i$ 与 $|S \cap Q|=j$，则这条边至少被经过 $\min(i,j)$ 次。取带权重心即可取到下界。

从而 $(x,y)$ 对答案的贡献为
$$
f(x,y)=\sum_{i=0}^x \sum_{j=0}^y \min(i,j) \binom{x}{i}\binom{y}{j}
$$
答案为所有 $f$ 值求和，其中 $x+y=n$。有一个[ $O(n^{1.5})$ 做法](https://www.luogu.com.cn/article/j1bbafyd)，下面讲如何推式子。

利用恒等式 $\min(i,j)=\frac{i+j-|i-j|}{2}$ 代入得
$$
f(x,y)= \dfrac{1}{2} \sum_{i=0}^x \sum_{j=0}^y (i+j) \binom{x}{i}\binom{y}{j}-\dfrac{1}{2}\sum_{i=0}^x \sum_{j=0}^y |i-j| \binom{x}{i}\binom{y}{j}
$$
根据组合恒等式 $\sum \limits_{i=0}^x i \dbinom{x}{i}=x2^{x-1}$ 且 $\sum \limits_{j=0}^y \dbinom{y}{j}=2^y$，于是关于 $i$ 的求和部分
$$
\sum_{i=0}^x \sum_{j=0}^y i \binom{x}{i}\binom{y}{j}=x2^{x-1}2^y=x2^{x+y-1}
$$
同理可得关于 $j$ 的求和部分为 $y2^{x+y-1}$。于是第一个和式的值为 $\boxed{n2^{n-1}}$。

对于第二个和式，令 $k=i-j$ 由范德蒙德卷积
$$
\begin{aligned}
&\sum_{i=0}^x \sum_{j=0}^y |i-j| \binom{x}{i}\binom{y}{j}\\
=&\sum_{k=-y}^{x} |k| \binom{x+y}{y+k}\\
=&\sum_{u=0}^{x+y} |u-y| \binom{x+y}{u}\\
=&\sum_{u=0}^{y} (y-u) \binom{x+y}{u}+\sum_{u=y+1}^{x+y} (u-y)\binom{x+y}{u}
\end{aligned}
$$
对于左侧，根据吸收恒等式及递推公式化简
$$
\begin{aligned}
&\sum_{u=0}^{y} y \binom{x+y}{u}-\sum_{u=0}^{y} u \binom{x+y}{u}\\
=&y\sum_{u=0}^y \binom{n}{u}-n\sum_{u=0}^{y-1} \binom{n-1}{u}\\
=& \boxed {y \binom{n-1}{y} - (x-y) \sum_{u=0}^{y-1} \binom{n-1}{u}}
\end{aligned}
$$
右半段根据对称性，只要将 $x,y$ 互换即可。

预处理组合数下指标前缀和即可做到 $O(n)$。注意 $\times \frac{1}{2}$ 等细节。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
