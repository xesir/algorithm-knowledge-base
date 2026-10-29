---
id: prob-abc236ex
title: 'Distinct Multiples'
oj: '来源未考证'
problemId: 'ABC236EX'
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

暂无（原题：[ABC236EX](https://www.luogu.com.cn/problem/AT_abc236_h)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$ 和序列 $d_1 \sim d_n$。对满足以下条件的序列 $a_1 \sim a_n$ 计数：
>
> - $\forall i \in [1,n], a_i \in [1,m]$。
> - $\forall i \in [1,n], d_i \mid a_i$。
> - $a_i$ 互不相同。
>
> $n \le 16$，$m \le 10^{18}$，2 秒，1024 MB。

::::::success[题解]

对互不相同的条件容斥。枚举划分 $P$，每个等价类内部 $a$ 值相同，容斥系数 $\prod\limits_{S \in P} (-1)^{|S|-1} (|S|-1)!$。

:::::info[集合划分容斥]

考虑下面的模型：有 $n$ 个变量 $a_1 \sim a_n$，其中 $a_i \in S_i$ 且 $a_i$ 互不相同，对 $a_1 \sim a_n$ 计数。

对互不相同进行容斥。考虑建图，若 $a_i=a_j$ 则连边 $i \leftrightarrow j$，连通块内部的点值都相同，不同连通块之间无限制。

对无向图 $G=(V,E)$，设 $C(E)$ 为 $G$ 的集合划分，$F(P)$ 为划分 $P$ 对应的方案数，答案即为
$$
\sum_{E} (-1)^{|E|} F(C(E))=\sum_{P} F(P) \sum_{C(E)=P}(-1)^{|E|}
$$
设 $P=\{S_1,S_2,\cdots,S_m\}$，只要在每个 $S_i$ 内部连边并构成连通图。则容斥系数
$$
 \sum_{C(E)=P}(-1)^{|E|}=\prod_{S \in P} \sum_{G_S \text{连通}} (-1)^{|E(G_S)|}
$$
问题转化为，对 $k$ 个点的无向图，求所有连通边集 $E$ 的 $(-1)^{|E|}$ 之和，记作 $g_k$。

设 $f_k$ 为 $k$ 个点任意无向图的 $(-1)^{|E|}$ 之和，则
$$
f_k=\sum_{i=0}^{\binom{k}{2}} \binom{\binom{k}{2}}{i} (-1)^i=0^{\binom{k}{2}}
$$
故 $k \ge 2$ 时 $f_k=0$，只有 $f_0=f_1=1$。$f$ 的 EGF 为
$$
F=\sum_{k \ge 0} f_k \dfrac{x^k}{k!}=1+x
$$
根据多项式 $\exp$ 的组合意义：
$$
F=\exp G \implies G=\ln F
$$
由 Taylor 展开
$$
G=\sum_{k \ge 1} (-1)^{k-1} \dfrac{x^k}{k}
$$
提取系数得
$$
\left[\dfrac{x^k}{k!}\right]G=\dfrac{(-1)^{k-1}}{k} \implies g_k=(-1)^{k-1}(k-1)!
$$
将 $g_k$ 代入容斥系数，得到最终结论
$$
\boxed{\sum_{P} F(P) \prod_{S \in P} (-1)^{|S|-1} (|S|-1)!}
$$
:::::

记 $\underset{i\in S}{\text{lcm } } d_i=\text{lcm}(S)$。强制点集 $S$ 内 $a$ 值均为 $x$，则必有 $\text{lcm}(S) \mid x$，从而方案数为
$$
F(P)=\prod_{S \in P}\left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
答案为
$$
\sum_{P}\prod_{S \in P}(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
利用排除 $\min S$ 转移的 trick，容易 $O(2^n \log V)$ 地求出单个 $S$ 的贡献值 $f_S=(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor$。

构造集合幂级数 $F$，令 $G=\exp F$，则 $[x^U] G$ 即为所求。使用子集卷积 exp 做到 $O(n^2 2^n)$。

总复杂度 $O(n^2 2^n+2^n \log V)$。[代码](https://atcoder.jp/contests/abc236/submissions/79499553)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
