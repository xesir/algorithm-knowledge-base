---
id: prob-luogu-p9131
title: '[USACO23FEB] Problem Setting P'
oj: '洛谷'
problemId: 'P9131'
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

暂无（原题：[P9131](https://www.luogu.com.cn/problem/P9131)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个集合 $S_i \subseteq [0,m)$。对满足 $S_{i_1} \subseteq S_{i_2}  \subseteq \cdots \subseteq S_{i_k}$ 的下标序列 $i_1 \sim i_k$ 计数。
>
> $n \le 10^5$，$m \le 20$，2 秒，512 MB。

:::::success[题解]

设 $f_S$ 表示以 $S$ 结尾的方案数。将相同集合缩起来，转移
$$
f_S \gets \left(\sum_{i=1}^k \binom{k}{i}i!\right)\sum_{T \subset S} f_T
$$
转移系数 $h_S=\sum\limits_{i=1}^k \binom{k}{i}i!$ 是内部选法数，其中 $k$ 是 $S$ 的出现次数。

直接枚举子集，复杂度 $O(3^m)$ 无法通过，[代码](https://qoj.ac/submission/3139426)。

转移 $f_S \gets h_S \sum \limits_{T \subset S} f_T$ 是**半在线 FMT**。按 $|S|$ 分层枚举，每层必然由之前的层贡献，做 $m$ 次 FMT 可以做到 $O(m^2 2^m)$。

下面介绍 $O(m2^m)$ 的算法。维护辅助数组
$$
g_{k,S}=\sum_{T \subseteq S} [T \cap [k,m)=S \cap [k,m)] f_T
$$
用人话说，$T$ 与 $S$ 在高 $k$ 位上完全相同，低于 $k$ 的数值不受限制。则 $g$ 满足逐维递推
$$
g_{k+1,S} = \left\{\begin{matrix}
g_{k,S} & k\notin S \\
g_{k,S}+g_{k,S \setminus \{k\}} & k\in S
\end{matrix}\right.
$$
边界 $g_{0,S}=f_S$。枚举并钦定 $i=\max (S \setminus T)$，则 $S$ 与 $T$ 的高 $i$ 位相同且低位无限制。按 $\max (S \setminus T)$ 分类不重不漏，于是
$$
\sum \limits_{T \subset S} f_T=\sum_{i \in S} g_{i, S \setminus \{i\}}
$$
计算完 $f$ 后立刻更新 $g$，枚举 $k$ 并递推即可。 

时空复杂度 $O(m2^m)$。[代码](https://qoj.ac/submission/3139589)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
