---
id: prob-luogu-p11164
title: '[BalkanOI 2023] Permutations'
oj: '洛谷'
problemId: 'P11164'
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

暂无（原题：[P11164](https://www.luogu.com.cn/problem/P11164)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $1\sim n$ 的排列 $p_i$。$q$ 次询问给出 $l,r$，求满足下列条件的 $1\sim n$ 的排列数目：
>
> - 排列的前缀为 $p_l \sim p_r$。
> - 排列的 LDS 长度 $\le 2$。LDS 为最长下降子序列。
>
> $n , q \le 3 \times 10^5$，2 秒，250 MB。

:::::success[题解]

先考虑没有前缀限制怎么做，打表发现答案数列的前几项是 $1,1,2,5,14,42,\cdots$，猜测答案为 Catalan 数 $C_n$。

我们尝试将合法排列和格路计数的模型建立双射。

首先考虑从排列构造格路。我们求出前缀最大值 $s_i=\max \limits_{j=1}^i p_i$，然后将 $(i,s_i)$ 画在平面上，先向上再向右走即可。因为 $s_i \ge i$ 必成立，所以这是一条始终在 $y=x$ 上方的格路。

接着考虑从格路构造排列。先求出每个横坐标对应的高度 $s_i$。对于 $s_i>s_{i-1}$ 的位置 $i$，必有 $p_i=s_i$，即 $p_i$ 是前缀最大值。对于非前缀最大值，我们让它们按照严格递增的顺序，依次填入剩下的空位。

在这个构造中，前缀最大值和非前缀最大值构成的子序列都是递增的。由 Dilworth 定理，$\text{LDS} \le 2$ 当且仅当排列可以被划分为至多两个递增子序列。可以看到，这确实是满足要求的。

现在我们强制排列的前缀为 $a_1,a_2,\cdots,a_k$，这相当于固定了格路的前半段。先假设我们会判定无解，下面按有解讨论。

记 $m=\max\limits_{i=1}^k a_i$，此时格路的起点变成 $(k,m)$。对于 $<m$ 的非前缀最大值，它们已经被钦定了相对顺序，即按严格递增填入空位，故不会产生贡献。我们只要关注 $>m$ 的数。用格路计数的语言来刻画，就是说从 $(k,m)$ 出发不越过 $y=x$ 走到 $(n,n)$ 的格路数目。

用单线反射容斥来算，总方案数 $\dbinom{2n-m-k}{n-k}$，将起点关于 $y=x-1$ 作对称，不合法方案数转化成 $(m+1,k-1) \to (n,n)$ 的朴素格路计数。问题的答案是
$$
\boxed{\binom{2n-m-k}{n-k}-\binom{2n-m-k}{n-m-1}}
$$
原题中 $k=r-l+1$，$m$ 是区间 $\max$。现在的难点在于判无解，这是一个和数数没有关系的纯 ds 题。

设 $[l,r]$ 的区间 $\operatorname{mex}$ 为 $x$，将 $x$ 加到 $p_r$ 后面，则前缀不合法当且仅当序列 $p_l,p_{l+1},\cdots,p_r,x$ 的 $\text{LDS}>2$。等价于下列两个条件至少有一个成立：

- $\exists l \le i<j<k \le r, p_i>p_j>p_k$。
- $\exists l \le i<j \le r, p_i>p_j>x$。

根据区间 $\operatorname{mex}$ 等于补集 $\min$ 的经典结论，$x$ 可以用前后缀 $\min$ 算出来。对上面两个条件分别讨论：

- 第一个条件：我们用单调栈求出 $f_j=\max\limits_{i<j\land  p_i >p_j} i$ 和 $g_j=\min\limits_{j < k\land p_j>p_k} k$。条件转化为 $\exists j \in [l,r], [f_j,g_j] \subseteq [l,r]$。

  这等价于 $\exists i \in [l,r],l \le \min(i,f_i) \land \max(i,g_i) \le r$。由 $i \ge f_i, i \le g_i$ 可以发现 $i \in [l,r]$ 的条件没有用。因此只要判断 $\forall i, [f_i,g_i] \subseteq [l,r]$ 成立。

  将 $(f_i,g_i)$ 画到二维平面上，询问变成 2-side 矩形数点，扫描线，维护 $x$ 坐标历史 $\max$ 直接判定即可。

- 第二个条件：仍用单调栈求得 $f_j$，条件转化为 $\exists j \in [l,r], l \le f_j \land p_j>x$。我们写成 $\max\limits_{i \in [l,r]\land f_i \ge l} p_i>x$。

  将 $(i,f_i)$ 画到二维平面上，询问是 3-side 矩形求 $\max$，扫描线，树状数组支持单点修改后缀 $\max$ 即可。

视 $n,q$ 同阶，判定部分 $O(n \log n)$，计数部分 $O(n)$。[代码](https://www.luogu.com.cn/article/somcbl4c)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
