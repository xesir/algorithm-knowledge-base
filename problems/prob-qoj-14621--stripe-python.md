---
id: prob-qoj-14621
title: 'Tearing Paper'
oj: 'QOJ'
problemId: 'QOJ14621'
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

暂无（原题：[QOJ14621](https://qoj.ac/problem/14621)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 定义 $(0,0) \to (n,m)$ 的格路是合法的，当且仅当矩形 $[a,c] \times [b,d]$ 在格路同侧。求合法格路数目。
>
> 多测，$T \le 10^4$，$n \le 10^3$，$m \le 10^6$，1 秒，256 MB。

:::::success[题解]

考虑分别计数不越过射线 $x \le c \land y=b$ 和 $x=a \land y \le d$ 的格路数目，二者相加即为所求。

![](https://cdn.luogu.com.cn/upload/image_hosting/glnce3df.webp)

以 $x=a \land y \le d$ 的计数为例，枚举 $i \le a$，将格路拆成 $(0,0) \to (i,d)$ 和 $(i,d+1) \to (n,m)$ 两部分。

![](https://cdn.luogu.com.cn/upload/image_hosting/757yaw88.webp)

特判 $(0,0) \to (a,d) \to (a+1,d) \to (n,m)$ 的情形。可列得答案式
$$
\boxed{\sum_{i=0}^a \binom{i+d}{i}\binom{n-i+m-(d+1)}{n-i}}
$$
对于 $x \le c \land y=b$ 同理求解，单测复杂度 $O(n+m)$ 无法通过。

注意到 $n,m$ 不同阶，正难则反，枚举跨过 $y=b$ 的位置 $i$，将不合法格路拆成 $(0,0) \to (i,b)$ 和 $(i,b+1) \to (n,m)$ 两部分：

![](https://cdn.luogu.com.cn/upload/image_hosting/o0liykgl.webp)

根据减法原理得到
$$
\boxed{\binom{n+m}{n} - \sum_{i=0}^{c-1} \binom{i+b}{i} \binom{n-i+m-(b+1)}{n-i}}
$$
必有 $a,c \le n$，总复杂度 $O(m+Tn)$ 可以通过。[代码](https://qoj.ac/submission/3142249)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
