---
id: prob-hdu-5909
title: 'Tree Cutting'
oj: 'HDU'
problemId: 'HDU5909'
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

暂无（原题：[HDU5909](https://acm.hdu.edu.cn/showproblem.php?pid=5909)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个点的树，第 $i$ 个节点的点权为 $a_i$。对每个 $k=0,1,\cdots,m-1$ 求出，点权异或和为 $k$ 的连通块数目。
>
> 多测，$T \le 10$，$n \le 10^3$，$m \le 2^{10}$，2 秒，128 MB。

:::::success[题解]

容易得到树形背包式 DP：

- 记 $f_{u,S}$ 为满足以下条件的连通块 $C$ 数目：
  - $C \subseteq \text{subtree}(u)$。
  - $u \in C$。
  - $\bigoplus\limits_{v \in C} a_v =S$。
- 树形 DP 转移是逐子树加，对儿子 $v$ 进行讨论：
  - 不选择 $v$，则 $f'_{u,S} \gets f_{u,S}$。
  - 选择 $v$，枚举 $T$ 的转移为 $f'_{u,S \oplus T} \gets f_{u,S} f_{v,T}$。
- DP 初值为 $f_{u,a_u}=1$。
- $k$ 的答案为 $\sum\limits_{u \in T} f_{u,k}$。

注意到 $u$ 处的转移是对所有儿子做对称差卷积。设集合幂级数 $F_u(x)=\sum\limits_{S} f_{u,S} x^S$，从而
$$
F_u=x^{a_u}\prod_{v \in \text{son}(u)} (1+F_v)
$$
乘法是对称差卷积。$k$ 的答案即为 $[x^k]\sum\limits_{u \in T} F_u$。

对所有 $F$ 施加 $\text{FWT}$ 变换，卷积化为对位乘法。由 $\text{FWT}$ 的线性性，我们可以求出 $\sum\limits_{u \in T} \text{FWT}(F_u)$ 再做逆变换，总复杂度 $O(nm+m\log m)$。

一个细节是对初值 $x^{a_u}$ 做 $\text{FWT}$。根据 $\phi(S,T)=(-1)^{|S \cap T|}$ 的构造，我们直接对每个位置赋值即可，复杂度 $O(m)$。[代码](https://www.luogu.me/paste/s3gwkitd)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
