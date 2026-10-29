---
id: prob-atcoder-agc006c
title: 'Rabbit Exercise'
oj: 'AtCoder'
problemId: 'AGC006C'
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

暂无（原题：[AGC006C](https://www.luogu.com.cn/problem/AT_agc006_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 数轴上有 $n$ 个物体，第 $i$ 个物体初始位于 $x_i$ 位置。
>
> 进行 $k$ 轮操作，每轮操作包含 $m$ 次跳跃。第 $i$ 次跳跃中，标号为 $a_i$ 的物体会等概率地选择 $a_i-1$ 或 $a_i+1$ 作为 $x$，跳跃到关于 $x$ 对称的位置，其中 $1<a_i<n$。
>
> 进行 $k$ 轮操作后，对每个物体求出最终坐标的期望值。浮点精度要求 $10^{-9}$。
>
> $n,m \le 10^5$，$k \le 10^{18}$，2 秒，256 MB。 

:::::success[题解]

考虑期望递推。设 $f_i$ 为当前时刻物体 $i$ 的期望位置，对 $x$ 进行变换时：

- 选定 $i-1$ 对称：$f_i \gets 2f_{i-1}-f_i$，概率 $\frac{1}{2}$。
- 选定 $i+1$ 对称：$f_i \gets 2f_{i+1}-f_i$，概率 $\frac{1}{2}$。

从而转移式为
$$
\begin{aligned}
f_i &\gets \dfrac{1}{2}(2f_{i-1}-f_i)+\dfrac{1}{2}(2f_{i+1}-f_i)\\
&= f_{i+1}+f_{i-1}-f_i
\end{aligned}
$$
我们得到单轮操作的转移。根据经典结论，取 $f$ 的差分 $d_i=f_i-f_{i-1}$，则对 $f_i$ 操作等价于交换 $d_i,d_{i+1}$。

不妨维护 $d$ 序列，模拟一轮操作可以得到对 $d$ 的置换，对置换做 $k$ 次幂即为最终的 $d$ 数组。

复杂度 $O(m+n \log k)$。[代码](https://atcoder.jp/contests/agc006/submissions/79264939)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
