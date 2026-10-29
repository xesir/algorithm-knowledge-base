---
id: prob-luogu-p8329
title: '[ZJOI2022] 树'
oj: '洛谷'
problemId: 'P8329'
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

暂无（原题：[P8329](https://www.luogu.com.cn/problem/P8329)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $N$。对于每个 $n=2,3,\cdots,N$ 求出满足如下限制的有标号有根树对 $(T_1,T_2)$ 的数目：
>
> - $T_1$ 的根节点为 $1$，且 $f_i<i$。
> - $T_2$ 的根节点为 $n$，且 $f_i>i$。
> - $T_1,T_2$ 的叶子集合无交集且并集为全集。
>
> $N \le 500$，2 秒，1024 MB。

:::::success[题解]
记全集 $U=\{1,2,\cdots,n\}$，枚举 $T_1$ 的叶子集合 $S$ 和 $T_2$ 的叶子集合 $T$。记构造 $T_1$ 的方案数为 $f(S)$，构造 $T_2$ 的方案数为 $g(T)$。可以发现 $T_1,T_2$ 的构造是独立的，则答案为

$$
\sum_ {S \cap T =\varnothing \land S \cup T=U} f(S) g(T)
$$

考虑做 FMT 状物，对 $f,g$ 做超集反演。定义 $F(A)$ 为叶子集合 $\subseteq A$ 时构造 $T_1$ 的方案数，$G(B)$ 同理。答案转化为

$$
\begin{aligned}
&\sum_ {S \cap T =\varnothing \land S \cup T=U} \left(\sum_{S \subseteq A} (-1)^{|A|-|S|} F(A)\right) \left(\sum_{T \subseteq B} (-1)^{|B|-|S|} G(B)\right)\\
&=\sum_{A,B \subseteq U} F(A) G(B) \sum_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|-|S|} (-1)^{|B|-|U \setminus S|}\\
&=\sum_{A,B \subseteq U} F(A) G(B) \sum_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|+|B|-|U|}
\end{aligned}
$$

对于容斥系数 $\sum\limits_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|+|B|-|U|}$，分析其组合意义：

- 根据 $S \subseteq A \land (U \setminus S) \subseteq B$ 知 $U \subseteq (A \cup B)$，也即 $A\cup B=U$。
- 当 $A \cup B=U$ 时，由二元容斥 $|A|+|B|-|U|=|A|+|B|-|A \cup B|=|A \cap B|$，故容斥系数为 $(-1)^{|A \cap B|}$ 乘上满足 $S \subseteq A \land (U \setminus S) \subseteq B$ 的 $S$ 数目。
- 考虑元素 $x \in U$，分析 $x$ 的贡献：
  - $x \in A \land x \notin B$：必有 $x \in S$，方案数 $1$。
  - $x \in B \land x \notin A$：必有 $x \in (U \setminus S)$，方案数 $1$。
  - $x \in A \land x \in B$：$x \in S$ 或者 $x \in (U \setminus S)$ 均可，方案数 $2$。
  - $x \notin A \land x \notin B$：由 $A \cup B=U$ 知这种情况不可能出现。
- 综上所述，容斥系数 $(-1)^{|A \cap B|} 2^{|A \cap B|}=\boxed{(-2)^{|A \cap B|}}$。

现在答案转化为 $\sum \limits_{A \cup B=U} (-2)^{|A \cap B|} F(A) G(B)$。接下来考虑推导 $F,G$ 的表达式，我们仍然从组合意义的角度来说明：

- 由 $F$ 的定义式 $F(A) =\sum \limits_{A \subseteq S} f(S)$ 知 $F$ 的组合意义是**钦定至少**，即钦定 $A$ 中的节点一定是叶子，其余节点不作要求。
- 考虑从小到大加入节点 $i=2,3,\cdots,n$：
  - 在无限制时，有 $i-1$ 个父亲可以选择。
  - 钦定后，在 $[1,i)$ 中且钦定为叶子的节点不能作为 $i$ 的父亲，方案数 $i-1-|A \cap [1,i)|$。
- $G$ 的推导同理，只是节点的加入顺序不同。

根据上述分析，$F,G$ 的表达式为

$$
F(A)=\sum_{i=1}^n \left(i-1-|A \cap [1,i)|\right)\\
G(B)=\sum_{i=1}^n \left(n-i-|B \cap (i,n]|\right)
$$

我们发现 $F,G$ 可以拆成每个 $i$ 的贡献之和，且这个贡献值只与 $A$ 的前缀信息和 $B$ 的后缀信息有关。考虑带着容斥系数 DP：

- 记 $f_{i,x,y}$ 为满足下列条件的 $(-2)^{|A \cap B| } F(A) G(B)$ 之和：
  - 已确定节点 $[1,i]$ 在 $A$ 中的分布情况，并将 $A \setminus [1,i]$ 归入集合 $B$。
  - $|A \cap [1,i)|=x$。
  - $|B \cap (i,n]|=y$。
- 转移考虑刷表，从 $f_{i,x,y} $ 转移到 $f_{i+1,x',y'}$。转移系数由贡献和容斥系数两部分组成：
  - 贡献系数：
    - $F$ 的系数为 $(i+1-1-|A \cap [1,i]|)=i-x$。
    - $G$ 的系数为 $n-(i+1)-|B \cap (i+1,n]|$，即 $n-i-1-y'$。
    - 总系数 $(i-x)(n-i-1-y')$。
  - 容斥系数：根据 $|A \cup B|$ 的奇偶性变化确定。
- 讨论 $i+1$ 的归属：
  - 当 $i +1 \in (A \setminus B)$ 时：
    - $x'=x+1$ 且 $y'=y$。
    - $|A \cup B|$ 不变，转移系数 $1 \times (i-x) \times (n-i-1-y)$。
  - 当 $i+1 \in (B \setminus A)$ 时：
    - $x'=x$ 且 $y'=y-1$。
    - $|A \cup B|$ 不变，转移系数 $1 \times (i-x) \times (n-i-y)$。
  - 当 $i+1 \in (A \cap B)$ 时：
    - $x'=x+1$ 且 $y'=y-1$。
    - $|A \cup B|$ 增加 $1$，转移系数 $-2 \times (i-x)\times (n-i-y)$。
- DP 初值为 $f_{0,0,y}=1$，注意在转移时特判 $i=0$ 和 $i=n-1$ 的情形。
- 答案为 $\sum \limits_{x=0}^n f_{n,x,0}$。

在外层枚举 $n$，做一次 DP 的复杂度为 $O(n^3)$，总复杂度 $O(N^4)$，可以获得 [60 分](https://www.luogu.com.cn/record/278852527)。这个做法的问题在于，贡献系数依赖 $n$ 导致不枚举 $n$ 难以转移。

考虑记 $z=n-i-y$，然后将 DP 状态改写为 $f_{i,x,z}$，此时贡献系数简化为 $(i-x)z'$，与 $n$ 无关。

枚举 $i$ 时直接对所有 $f_{i,x,z}$ 做一轮转移。由于 $i=n-1$ 无法直接特判，考虑在计算答案时手动模拟最后一轮的转移，这样即可求出所有 $n$ 的答案。

复杂度 $O(N^3)$。[代码](https://qoj.ac/submission/2887248)。
:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
