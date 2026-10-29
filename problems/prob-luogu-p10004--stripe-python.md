---
id: prob-luogu-p10004
title: '[集训队互测 2023] Permutation Counting 2'
oj: '洛谷'
problemId: 'P10004'
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

暂无（原题：[P10004](https://www.luogu.com.cn/problem/P10004)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n$，对于所有 $0 \le x,y < n$ 求有多少个 $1\sim n$ 的排列 $p_i$ 满足：
>
> - $\sum \limits_{i=1}^{n-1} [p_i<p_{i+1}]=x$。
> - $\sum \limits_{i=1}^{n-1} [q_i<q_{i+1}]=x$。
>
> $q_i$ 是 $p_i$ 的逆排列，即 $q_{p_i}=i$。
>
> $n \le 500$，5 秒，512 MB。

:::::success[题解]

如果只对 $p$ 有限制，常见做法是容斥。本题中 $p$ 与 $q$ 地位相同，因此可以同时对两维进行容斥。

设原问题的答案为 $f(x,y)$。我们钦定 $p$ 中至少有 $a$ 个上升、$q$ 中至少有 $b$ 个上升，将满足这一条件的方案数记为 $g(a,b)$。有
$$
f(x,y)=\sum_{a=x}^{n-1} \sum_{b=y}^{n-1} (-1)^{a-x} (-1)^{b-y} \dbinom{a}{x} \dbinom{b}{y} g(a,b).
$$

容斥系数 $(-1)^{a-x} (-1)^{b-y} \dbinom{a}{x} \dbinom{b}{y}$ 是超集二元二项式反演给出的。

接下来分析 $g$ 的组合意义。转二维平面分析，即考虑点 $(i,p_i)$。$p$ 的限制作用在纵轴，$q$ 的限制作用在横轴。

我们钦定的每个上升实际上将平面划分为若干个矩形。纵轴上切出 $n-a$ 段，横轴上切出 $n-b$ 段，矩形总数为 $(n-a)(n-b)$。只需在这些区域内选出 $n$ 个点，且要求没有空行和空列，记这个问题的答案为 $g_0(n-a,n-b)$。

类似第二类斯特林数的推导，可以容斥掉不存在空行空列的限制。记：

- $g_0(x,y)$ 为将 $n$ 个点放入 $x \times y$ 个不同区域中，且不存在空行空列的方案数。
- $h(x,y)$ 为 $n$ 个点放入 $x \times y$ 个不同区域中，允许空行空列的方案数。

$h \to g_0$ 的转化是子集二元二项式反演，容斥系数 $(-1)^{x-a} (-1)^{y-b} \dbinom{x}{a} \dbinom{y}{b} $。

考虑计算 $h(x,y)$。这相当于将 $n$ 个无标号球放入 $xy$ 个有标号盒的方案数，即
$$
h(x,y)=\binom{xy+n-1}{n}
$$
因此由 $h \to g_0 \to g \to f$ 即可得到 $f$。$h \to g_0$ 和 $g \to f$ 都需要做二元二项式反演，复杂度 $O(n^4)$。

考虑优化。将 $g \to f$ 的式子拆开：
$$
\begin{aligned}
f(x,y)&=\sum_{a=x}^{n-1} \sum_{b=y}^{n-1} (-1)^{x-i} (-1)^{y-j} \dbinom{a}{x} \dbinom{b}{y} g(a,b)\\
&=\boxed{\sum_{a=x}^{n-1}  (-1)^{x-i} \dbinom{a}{x}\sum_{b=y}^{n-1}  (-1)^{y-j}\dbinom{b}{y} g(a,b)}
\end{aligned}
$$
可以先枚举 $a,y$ 求出 $\sum\limits_{b=y}^{n-1}  (-1)^{y-j}\dbinom{b}{y} g(a,b)$，再枚举 $a,x$ 做外层求和，复杂度即为 $O(n^3)$。$h \to g_0$ 同理。[代码](https://qoj.ac/submission/2887240)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
