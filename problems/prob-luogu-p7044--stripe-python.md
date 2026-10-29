---
id: prob-luogu-p7044
title: '「MCOI-03」括号'
oj: '洛谷'
problemId: 'P7044'
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

暂无（原题：[P7044](https://www.luogu.com.cn/problem/P7044)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 定义一个括号串的 $0$ 级权值为，将括号串修改为合法的最小操作次数。一次操作可以在任意位置插入或删除括号。
>
> 定义一个括号串的 $k$ 级权值为所有子串 $k-1$ 级权值之和。
>
> 给定长为 $n$ 的括号串，求出 $k$ 级权值。
>
> $n,k \le 10^6$，1 秒，500 MB。

:::::success[题解]

设子串 $[l,r]$ 的 $0$ 级权值对最终答案的贡献系数为 $f_{l,r}$，初始 $f_{1,n}=1$。每轮迭代 $[l,r]$ 对 $[l',r'] \subseteq [l,r]$ 有贡献，执行 $k$ 轮转移：
$$
f_{l,r} \gets \sum_{x=1}^l \sum_{y=r}^n f_{x,y}
$$
预处理 $a_i$ 为第 $i$ 个括号的匹配位置，将贡献拆到字符上：

- 若 $i$ 失配，只要 $i \in [l,r]$ 就产生贡献，答案加上 $\sum\limits_{l=1}^i \sum\limits_{r=i}^n f_{l,r}$。
- 若 $i$ 是左括号且与 $j=a_i$ 匹配，此时 $i \in [l,r] \land j \notin [l,r]$ 有贡献，答案加上 $\sum \limits_{l=1}^i \sum\limits_{r=i}^{a_i-1} f_{l,r}$。
- 若 $i$ 是右括号同理。

我们考虑 $f_{l,r}$ 的组合意义，考察一组转移序列：

- $1 \le l_1 \le l_2 \le \cdots \le l_k \le l$。等价于 $x_1+x_2+\cdots+x_{k+1}=l-1$ 的非负整数解计数，方案数 $\dbinom{l-1+k}{k}$。
- $n \ge r_1 \ge r_2 \cdots \ge r_k \ge r$。同理可得方案数 $\dbinom{n-r+k}{k}$。
- 由于 $l \le r$ 恒成立，两部分相互独立。

从而
$$
\boxed{f_{l,r}=\binom{l+k-1}{k} \binom{n-r+k}{k}}
$$
对统计答案的部分，设 $g_{x,y}$ 为 $f_{l,r}$ 的二维前缀和，那么
$$
\begin{aligned}
g_{x,y}&=\sum_{l=1}^x \sum_{r=1}^y f_{l,r}\\
&=\sum_{l=1}^ x \binom{l+k-1}{k} \sum_{r=1}^y \binom{n-r+k}{k}\\
&= \binom{x+k}{k+1} \left(\binom{n+k}{k+1}-\binom{n+k-y}{k+1}\right)
\end{aligned}
$$
预处理组合数即可 $O(1)$ 计算单个 $g$，总复杂度 $O(n+k)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
