---
id: prob-zr-3695
title: '字典'
oj: '正睿'
problemId: 'ZR3695'
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

暂无（原题：[ZR3695](https://www.zhengruioi.com/problem/3695)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个字符串 $S_i$，字符集 $\Sigma=\{{\tt{a}},{\tt{b}},\cdots,{\tt{z}}\}$。从 $\Sigma$ 的 $26!$ 种排列中随机选取一个，并按照该顺序定义字典序。
>
> 对每个 $i$ 求出 $S_i$ 的字典序排名方差。
>
> $\sum |S_i| \le 5 \times 10^5$，3 秒，1024 MB。

:::::success[题解]

考虑使用 $\text{Var}(X)=\mathbb E[(X-\mathbb E [X])^2]$ 计算方差，下文讨论 $X$ 相对均值的波动。

枚举下标对 $(i,j)$，设 $S_i$ 与 $S_j$ 在 LCP 后第一个字符为 $f(i,j)=(x,y)$。忽略 $S_i$ 或 $S_j$ 是对方前缀的情形，因为常数不影响方差。

连边 $x \to y$，边权 $w(x,y)=\sum \limits_{i=1}^n \sum \limits_{j=1}^n [f(i,j)=(x,y)]$。若 $y<x$ 则相对均值贡献 $+\frac{w}{2}$，否则贡献 $-\frac{w}{2}$。 

取两条边，设波动分别为 $u,v$，方差
$$
\mathbb E[(u+v)^2]=\mathbb E[u^2]+2\mathbb E[uv]+\mathbb E[v^2]
$$
考察边 $e_1,e_2$ 的位置关系：

- 取同一条边 $a \to b$：乘积项期望 $\frac{w^2}{4}$。
- 取不共点边 $a \to b, c\to d$：事件独立，同号与异号概率相同，期望 $0$。
- 取三角状 $a \to b, a \to c$：枚举 $6$ 种排列可算得，同号 $4$ 种异号 $2$ 种，期望 $\frac{4-2}{6}\times\frac{w_1w_2}{4}=\frac{w_1w_2}{12}$。
- 取三点链 $a \to b, b\to c$：枚举 $6$ 种排列可算得，同号 $2$ 种异号 $4$ 种，期望 $\frac{2-4}{6} \times \frac{w_1w_2}{4}=-\frac{w_1w_2}{12}$。

直接将这些值相加就是方差，不过复杂度不可接受，还需要进一步推导。

定义节点 $x$ 的出边权和减去入边权和为 $b_x$。我们发现 $T=\frac{1}{12} \sum \limits_{x \in V} b_x^2$ 其实就几乎算完了。因为 $b_x^2$ 的组合意义是将 $x$ 的两条关联边相乘，同进同出均正，而一进一出为负，恰好与上面讨论的规则相同。

唯一算漏的地方是取同一条边两次时贡献 $\frac{3w^2}{12}$，但 $T$ 中只计入了 $2w^2$。补上 $S=\sum \limits_{e \in E} w^2(e)$ 就完全正确了：
$$
\boxed {\text{Var}(r)=\dfrac{S+T}{12}}
$$
只要求出每个 $i$ 对应的 $S+T$ 即可。

维护矩阵 $D_{x,y}=w(x,y)-w(y,x)$，从而
$$
\begin{aligned}
b_x&=\sum_{y} D_{x,y}\\
S&=\sum_{x < y} D^2_{x,y}\\
T&=\sum_{x} b_x^2
\end{aligned}
$$
对 $S_1 \sim S_n$ 建立 Trie 树，逐位读入 $S_i$ 转移。设当前转移边为字符 $x$，枚举兄弟边 $y$，动态维护
$$
D_{x,y} \gets D_{x,y} + \text{sz}_{\delta(u,y)}\\
D_{y,x} \gets D_{y,x} - \text{sz}_{\delta(u,y)}
$$
在终止状态计算答案即可，容易做到 $O(L |\Sigma|^2)$。

优化是简单的，维护 $b_x$ 后对于 $D$ 的单点修改容易 $O(1)$ 更新 $S,T$。注意修改后要撤销而非清空，复杂度才是对的。

总复杂度 $O(L |\Sigma|)$。[代码](https://www.cnblogs.com/stripe-python/p/23348906)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
