---
id: prob-cf-938e
title: 'Max History'
oj: 'Codeforces'
problemId: 'CF938E'
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

暂无（原题：[CF938E](https://www.luogu.com.cn/problem/CF938E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$。定义序列 $a$ 的权值为，取出 $a_i$ 的所有前缀 $\max$ 为 $b_1 \sim b_k$，求和 $\sum \limits_{i=1}^{k-1} b_i$。
>
> 求 $a$ 的所有 $n!$ 种重排的权值之和。
>
> $n \le 10^6$，3 秒，250 MB。

:::::success[题解]

不妨计数所有重排的前缀 $\max$ 总和，将答案减去 $n! \times \max \limits_{i=1}^n a_i$。

将贡献拆到每个 $a_i$ 上。设 $\ge a_i$ 的数有 $k$ 个，则 $a_i$ 成为前缀 $\max$ 当且仅当 $a_i$ 是这 $k$ 个数中位置最靠前的。

事件发生的概率恰为 $\frac{1}{k}$，且所有事件独立，可得贡献 $n! \times \frac{1}{k} \times a_i$，排序后直接统计即可。

复杂度 $O(n \log n)$。[代码](https://www.luogu.com.cn/article/4m3uvjaw)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
