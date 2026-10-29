---
id: prob-luogu-p10185
title: '[YDOI R1] Necklace'
oj: '洛谷'
problemId: 'P10185'
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

暂无（原题：[P10185](https://www.luogu.com.cn/problem/P10185)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 种颜色的球，第 $i$ 种颜色的球有 $a_i$ 个，所有 $\sum a_i$ 个球互不相同。
>
> 你需要从中取出若干，设第 $i$ 种颜色取 $c_i$ 个，要求 $c_i \ge 1$，则权值为 $\sum (v_i)^{c_i}$。求所有取球方案的权值和。
>
> $n \le 2 \times 10^5$，$a_i \le 10^9$，1 秒，512 MB。

:::::success[题解]

设 $m=\sum a_i$。考虑对每个 $i$ 枚举 $c_i=j$，则 $i$ 的贡献为：

- 剩余 $m-a_i$ 个球任取，方案数 $2^{m-a_i}$。
- 从 $a_i$ 个互相区分的球里取 $j$ 个，方案数 $\binom{a_i}{j}$。

从而答案式
$$
\sum_{i=1}^n \sum_{j=1}^{a_i} 2^{m-a_i}\binom{a_i}{j}(v_i)^j
$$
由二项式定理 $\sum\limits_{j=0}^{a_i} \dbinom{a_i}{j} (v_i)^j 1^{a_i-j}=(v_i+1)^{a_i}$。于是化简为
$$
\boxed{\sum_{i=1}^n  2^{m-a_i}\left((v_i+1)^{a_i}-1\right)}
$$
复杂度 $O(n \log V)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
