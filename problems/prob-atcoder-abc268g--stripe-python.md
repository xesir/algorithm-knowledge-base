---
id: prob-atcoder-abc268g
title: 'Random Student ID'
oj: 'AtCoder'
problemId: 'ABC268G'
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

暂无（原题：[ABC268G](https://www.luogu.com.cn/problem/AT_abc268_g)）。

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
> 对每个 $i$ 求出 $S_i$ 的字典序排名期望。
>
> $\sum |S_i| \le 5 \times 10^5$，3 秒，1024 MB。

:::::success[题解]

设所有字符串中，是 $S_i$ 的前缀的有 $a$ 个，$S_i$ 是真前缀的有 $b$ 个，其余串有 $c=n-a-b$ 个。

显然这 $a$ 个串必然 $\le S_i$，这 $b$ 个串必然 $>S_i$，而剩余 $c$ 个串各有 $\frac{1}{2}$ 的概率 $< S_i$。

注意期望的线性性不要求事件独立，可以直接拆成
$$
\mathbb{E}[r_i]=a \times 1+b \times 0+c \times \dfrac{1}{2}=\boxed{a+\frac{c}{2}}
$$
只要求出 $a,b$，哈希或 Trie 均容易实现。复杂度 $O(L)$。[代码](https://www.luogu.com.cn/article/oq1br2ra)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
