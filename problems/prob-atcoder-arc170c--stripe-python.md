---
id: prob-atcoder-arc170c
title: 'Prefix Mex Sequence'
oj: 'AtCoder'
problemId: 'ARC170C'
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

暂无（原题：[ARC170C](https://www.luogu.com.cn/problem/AT_arc170_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n,m$ 和长为 $n$ 的 01 串 $S$。求满足以下条件的非负整数序列 $a_1,a_2,\cdots,a_n$ 的数目：
>
> - $a_i \in [0,m]$。
> - $S_i=\tt{1}$ 是 $a_i=\operatorname{mex}(a_1,a_2,\cdots,a_{i-1})$ 的充要条件。
>
> $n \le 5000$，$m \le 10^9$，2 秒，1024 MB。

:::::success[题解]

直观的想法是考虑记录 $f_{i,j}$ 为已确定前 $i$ 个数，且当前前缀 $\operatorname{mex}$ 为 $j$ 时的方案数。但是 $j \to j'$ 通过这些信息无法转移。

考虑修改状态并重新推导转移系数：

- 记 $f_{i,k}$ 为满足如下条件时，前缀 $a_1 \sim a_i$ 的填数方案数：
  - 前缀 $a_1 \sim a_i$ 中恰有 $k$ 个不同数字。
  - 前缀 $a_1 \sim a_i$ 合法。
- 转移考虑填表，由 $f_{i-1,k}$ 转移到 $f_{i,k'}$。此时的 $k'$ 容易维护。
  - 若 $S_i=\tt{1}$，则 $a_i$ 作为前缀 $\operatorname{mex}$ 在之前没有出现，转移系数 $1$。转移式 $f_{i,k+1} \gets f_{i-1,k}$。
  - 若 $S_i=\tt{0}$：
    - 填入已出现的数字：填入任意数字都不会是 $\operatorname{mex}$，转移系数 $k$。转移式 $f_{i,k} \gets k \times f_{i-1,k}$。
    - 填入未出现的数字：共有 $m+1-k$ 个可用数字，除去恰为 $\operatorname{mex}$ 的那个，转移系数 $m-k$。转移式 $f_{i,k+1}\gets (m-k)f_{i-1,k}$。
  - 注意特判 $m<k$ 的情形。
- DP 初值为 $f_{0,0}=1$。
- 答案为 $\sum\limits_{k=1}^n f_{n,k}$。

复杂度 $O(n^2)$。[代码](https://atcoder.jp/contests/arc170/submissions/76114030)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
