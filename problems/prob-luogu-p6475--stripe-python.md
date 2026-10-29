---
id: prob-luogu-p6475
title: '[NOI Online #2 入门组] 建设城市'
oj: '洛谷'
problemId: 'P6475'
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

暂无（原题：[P6475](https://www.luogu.com.cn/problem/P6475)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m,x,y$。求满足以下条件的正整数序列 $a_1 \sim a_{2n}$ 的数目：
>
> - $a_i \in [1,m]$。
> - $a_1 \le a_2 \le \cdots \le a_n$。
> - $a_{n+1} \ge a_{n+2} \ge \cdots \ge a_{2n}$。
> - $a_x=a_y$。
>
> $n,m \le 10^5$，1 秒，128 MB。

:::::success[题解]

::::info[不降序列计数]

**问题** 对值域 $[l,r]$，长为 $n$ 的不降序列 $a_1 \sim a_n$ 计数。

我们令 $a_i \gets a_i+i$，则值域变为 $[l+1,r+n]$，只要对递增序列 $a_1 \sim a_n$ 计数。

考虑从 $[l+1,r+n]$ 中取出 $n$ 个数，这些数自动升序排序，从而方案数 $\dbinom{r-l+n}{n}=\dbinom{r-l+n}{r-l}$。

::::

考虑枚举 $a_x=a_y=k$，对 $x,y$ 的位置分类讨论：

- $x \le n \le y$：序列分为 $[1,x),(x,n], (n,y), (y,2n]$ 四段分步计数：

  - $[1,x)$ 段：$[1,x)$ 段：对值域 $[1,k]$，长为 $x-1$ 的不降序列计数，方案数 $\dbinom{k-1+x-1}{k-1}$。
  - $(x,n]$ 段：对值域 $[k,m]$，长为 $n-x$ 的不降序列计数，方案数 $\dbinom{m-k+n-x}{m-k}$。
  - $(n,y)$ 段：对值域 $[k,m]$，长为 $y-n-1$ 的不升序列计数，方案数 $\dbinom{m-k+y-n-1}{m-k}$。
  - $(y,2n]$ 段：对值域 $[1,k]$，长为 $2n-y$ 的不升序列计数，方案数 $\dbinom{k-1+2n-y}{k-1}$。
    将四段的方案数相乘得到答案

  $$
  \boxed{\sum_{k=1}^{m} \binom{k+x-2}{k-1} \binom{m-k+n-x}{m-k} \binom{m-k+y-n-1}{m-k} \binom{k+2n-y-1}{k-1}}
  $$

- $x,y \le n$：序列分为 $[1,x), (x,y), (y,n], (n,2n]$ 四段分步计数：

  - $[1,x)$ 段：对值域 $[1,k]$，长为 $x-1$ 的不降序列计数，方案数 $\dbinom{k-1+x-1}{k-1}$。
  - $(x,y)$ 段：方案数为 $1$。
  - $(y,n]$ 段：对值域 $[k,m]$，长为 $n-y$ 的不降序列计数，方案数 $\dbinom{m-k+n-y}{m-k}$。
  - $(n,2n]$ 段：对值域 $[1,m]$，长为 $n$ 的不升序列计数，方案数 $\dbinom{m-1+n}{m-1}$。
    将四段的方案数相乘得到答案

  $$
  \boxed{\binom{n+m-1}{m-1} \sum_{k=1}^{m} \binom{k+x-2}{k-1} \binom{m-k+n-y}{m-k}}
  $$

  对于 $x,y \ge n$ 的情形同理。

复杂度 $O(m)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
