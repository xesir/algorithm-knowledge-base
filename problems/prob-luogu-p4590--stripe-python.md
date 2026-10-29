---
id: prob-luogu-p4590
title: '[TJOI2018] 游园会'
oj: '洛谷'
problemId: 'P4590'
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

暂无（原题：[P4590](https://www.luogu.com.cn/problem/P4590)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $k$ 的字符串 $S$。对每个 $i=0,1,\cdots,k$，求出满足如下要求的本质不同字符串 $T$ 数目：
>
> - $T$ 的字符集为 $\{\tt{N},\tt{O},\tt{I}\}$。
> - $|T|=n$。
> - $\tt{NOI}$ 不是 $T$ 的子串。
> - $\text{LCS}(S,T)=i$。
>
> $n \le 10^3$，$k \le 15$，6 秒，250 MB。

:::::success[题解]

前三条限制是容易压进 DP 状态的。我们发现 $\text{LCS}$ 难以刻画，因为直接去算两个串的 LCS 都需要 dp。

不妨考察用于计算 LCS 的 dp。记 $f_{i,j}$ 为 $T[1:i]$ 与 $S[1:j]$ 的 LCS 长度，转移为
$$
f_{i,j}=\max(f_{i-1,j},f_{i,j-1}, f_{i-1,j-1} +[T[i]=S[j]])
$$
对同一行的 $f$，根据经典结论有 $f_{i,j}-f_{i,j-1} \in \{0,1\}$，从而考虑状压差分数组，状态数是 $O(2^k)$ 的。我们将差分数组代表的 01 串作为 DFA 的节点。

这样，内层 DFA 的建立过程即为：枚举节点编码 $\text{mask}$，将其还原为 DP 数组 $f_i$，再枚举出边字符 $c$，按照 DP 规则进行转移，得到新的 DP 数组 $f'_i$。将其压缩成 $\text{mask}'$ 并记录转移边。

建立 LCS 的 DFA 后，设计如下外层 DP：

- 记 $f_{i,j,\text{mask}}$ 为满足如下条件时，合法的 $T$ 的数目：
  - $|T|=i$。
  - $T$ 的末位匹配了 $\tt{NOI}$ 的前 $j$ 位。
  - $T$ 在内层 DFA 上的对应节点为 $\text{mask}$。
- 转移 $f_{i,j,\text{mask}} \to f_{i,j',\text{mask}'}$。枚举出边字符 $c$，分别更新 $j'$ 和 $\text{mask}'$，其中 $\text{mask}'$ 由内层 DFA 走出边得到。对 $j' \ge 3$ 的转移忽略。
- DP 初值为 $f_{0,0,0}=1$，其中 $\text{mask}=0$ 为内层 DFA 起点的编码。
- 答案为 $\text{ans}_k=\sum \limits_{\text{popcount}(\text{mask})=k} \sum\limits_{j=0 }^2 f_{n,j,\text{mask}}$。利用 $\text{popcount}$ 的原因是，$\text{mask}$ 中 $1$ 的数目恰好等价于 $\text{LCS}(S,T)$。

时空复杂度 $O(2^kn)$。进一步对 $f$ 的第一维滚动数组，空间优化到 $O(2^k)$。 

实际上，对内层 DFA 的状态进行搜索，只保留有效节点，可以得到 $O(|\Sigma| n)$ 的复杂度，$|\Sigma|$ 为 DFA 有效状态数。这里 $O(2^k)$ 的状压足以通过本题。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
