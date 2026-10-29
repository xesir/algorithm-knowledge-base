---
id: prob-atcoder-abc240g
title: 'Teleporting Takahashi'
oj: 'AtCoder'
problemId: 'ABC240G'
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

暂无（原题：[ABC240G](https://www.luogu.com.cn/problem/AT_abc240_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有无限大的三维网格，你初始位于 $(0,0,0)$，每步必须移动到某个相邻格点。求 $n$ 次移动后位于 $(x,y,z)$ 的路径数。
>
> $n,|x|,|y|,|z| \le 10^7$，3 秒，1024 MB。

:::::success[题解]

考虑一维情形，求移动 $n$ 步走到 $x_0$ 的路径数。相当于对
$$
\sum_{i=1}^n x_i=x_0,x_i \in \{-1,1\}
$$
的序列 $x_i$ 计数。令 $y_i=\frac{x_i+1}{2}$，则
$$
\sum_{i=1}^n y_i=\dfrac{x_0+n}{2}, y_i \in \{0,1\}
$$
故合法的 $y$ 双射 $x$，方案数 $\dbinom{n}{\frac{x_0+n}{2}}$。

考虑二维情形，难点在于 $(x,y)$ 不独立。套路地将坐标系旋转 $45\degree$，令 $(x,y) \to (x+y,x-y)$，则新的 $x',y'$ 独立，将两个组合数乘起来即可。

考虑三维情形。我们枚举 $x$ 方向上走了 $i$ 步，转化为“1+2”，将三个组合数乘起来再配上系数 $\dbinom{n}{i}$ 求和即可。

复杂度 $O(n)$。[代码](https://atcoder.jp/contests/abc240/submissions/79491819)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
