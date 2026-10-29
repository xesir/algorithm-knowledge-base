---
id: prob-luogu-p13275
title: '[NOI2025] 集合'
oj: '洛谷'
problemId: 'P13275'
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

暂无（原题：[P13275](https://www.luogu.com.cn/problem/P13275)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $2^n$ 的序列 $a_0 \sim a_{2^n-1}$。记 $f(S)=\underset{i \in S}{\text{and }} i$，特别地 $f(\varnothing)=2^n-1$。求
> $$
> \sum_{P, Q} [P \cap Q=\varnothing][f(P)=f(Q)] \prod_{i \in (P \cup Q)} a_i
> $$
> 其中 $P,Q \subseteq \{0,1,\cdots,2^n-1\}$。
>
> 多测，$T \le 3$，$n \le 20$，2 秒，512 MB。

:::::success[题解]

钦定 $S \subseteq f(P) \land T \subseteq f(Q)$。枚举 $f(P)=f(Q)=W$，则 $(S,T)$ 的容斥系数为 $(-1)^{| S\triangle W|} (-1)^{|T \triangle W|}=(-1)^{|S|+|T|}$。

::::success[证明]

注意到
$$
\begin{aligned}
|S \triangle W|&\equiv |S| + |W |\pmod 2\\
|T \triangle W|&\equiv |T| + |W |\pmod 2
\end{aligned}
$$
从而
$$
\begin{aligned}
|S \triangle W|+|T \triangle W| &\equiv|S|+|T|+2|W| \pmod 2\\
|S \triangle W|+|T \triangle W| &\equiv|S|+|T| \pmod 2\\
\end{aligned}
$$
故有 $(-1)^{|S \triangle W|+|T \triangle W|}=(-1)^{|S|+|T|}$ 成立，证毕。

::::

系数与 $W$ 无关，而 $ W \subseteq (S \cap T)$，则 $(S,T)$ 的容斥系数为 $2^{|S \cap T|} (-1)^{|S|+|T|}$。

设 $f(P) \subseteq S \land f(Q) \subseteq T$ 时的权值和为 $q(S,T)$。讨论 $i \in [0,2^n)$ 的选择：

- 若 $S\nsubseteq i \land T \nsubseteq i$，不能放入 $P$ 或 $Q$，系数为 $1$。
- 若 $S\subseteq i \land T \nsubseteq i$，可以放入 $P$ 或不放，系数为 $a_i+1$。
- 若 $S\nsubseteq i \land T \subseteq i$，可以放入 $Q$ 或不放，系数为 $a_i+1$。
- 若 $S\subseteq i \land T \subseteq i$，可以放入 $P$，放入 $Q$ 或不放，系数为 $2a_i+1$。

由乘法原理合并得到 $q(S,T)$。这样
$$
\begin{aligned}
q(S,T)&=\prod_{S\subseteq i \land T \nsubseteq i} (a_i+1) \prod_{S\nsubseteq i \land T \subseteq i} (a_i+1) \prod_{S\subseteq i \land T \subseteq i} (2a_i+1)\\
&=\prod_{S\subseteq i} (a_i+1) \prod_{T \subseteq i} (a_i+1) \prod_{(S \cup T) \subseteq i} \dfrac{2a_i+1}{(a_i+1)^2}
\end{aligned}
$$
使用高维后缀积预处理
$$
\begin{aligned}
f_S&=\prod_{S \subseteq i} (a_i+1)\\\
g_S&=\prod_{S \subseteq i} \dfrac{2a_i+1}{(a_i+1)^2}
\end{aligned}
$$
从而 $q(S,T)=f_S f_T g_{S \cup T}$。答案式
$$
\begin{aligned}
\sum_{S,T} 2^{|S \cap T|} (-1)^{|S|+|T|} q(S,T)&= \sum_{S,T} 2^{|S \cap T|} (-1)^{|S|+|T|}  f_S f_T g_{S \cup T}
\end{aligned}
$$
利用二元容斥 $|S \cap T|=|S|+|T|-|S \cup T|$ 将 $2^{|S \cap T|}$ 拆开
$$
\begin{aligned}
&\sum_{S,T\subseteq U} 2^{|S \cap T|} (-1)^{|S|+|T|}  f_S f_T g_{S \cup T}\\
=&\sum_{S,T\subseteq U} 2^{|S|+|T|-|S \cup T|} (-1)^{|S|+|T|}f_S f_T g_{S \cup T}\\
=&\sum_{S,T\subseteq U} (-2)^{|S|} f_S \times  (-2)^{|T|} f_T \times  2^{-|S \cup T|} g_{S \cup T}\\
=&\sum_{W\subseteq U} 2^{-|W|} g_{W} \sum_{S \cup T = W}  (-2)^{|S|} f_S \times  (-2)^{|T|} f_T
\end{aligned}
$$
构造集合幂级数 $F=\sum \limits_{S \subseteq U} (-2)^{|S|} f_S$，乘法为并卷积，从而
$$
\sum_{W\subseteq U} 2^{-|W|} g_{W} \sum_{S \cup T = W}  (-2)^{|S|} f_S \times  (-2)^{|T|} f_T=\boxed{\sum_{W\subseteq U} 2^{-|W|} g_{W}[x^W] F^2}
$$
注意处理 $a_i \equiv -1$ 的情形：使用[除零扩域](https://www.luogu.com.cn/article/d3vw3m09)的 trick，将每个数记作 $a \times 0^b$ 的形式，乘除均有良定义。

总复杂度 $O(n2^n)$。[代码](https://qoj.ac/submission/2887280)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
