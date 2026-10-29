---
id: prob-atcoder-arc207a
title: 'Affinity for Artifacts'
oj: 'AtCoder'
problemId: 'ARC207A'
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

暂无（原题：[ARC207A](https://www.luogu.com.cn/problem/AT_arc207_a)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个任务，第 $i$ 个任务的成本为 $a_i$。
>
> 你初始持有变量 $x$，以任意顺序执行所有任务。执行第 $i$ 个任务时，$x \gets x-a_i$，并对 $a_j \ge 1$ 令 $a_j \gets a_j-1$。
>
> 求最终 $x \ge 0$ 的执行顺序数目。
>
> $n \le 10^2$，$a_i,x \le 10^9$，2 秒，1024 MB。

:::::success[题解]

设第 $i$ 个任务是第 $p_i$ 个被执行的，约束即为
$$
\sum_{i=1}^n \max(0,a_i-p_i+1) \le x
$$
直接对着 DP 需要记录 $\sum a_i$ 级别的信息。我们转换视角，考虑任务节省的成本。设 $k=\left(\sum \limits_{i=1}^n a_i\right) -x$，只要
$$
\sum_{i=1}^n \min(a_i,p_i-1) \ge k
$$
若 $k>\binom{n}{2}$ 无解，$k \le 0$ 答案为 $n!$，这样值域就降到 $O(n^2)$ 级别。

将 $i \to p_i$ 描述为二分图匹配，边权为 $\min(a_i,p_i-1)$，转化为对权值 $\ge k$ 的完美匹配计数。

将 $a_i$ 和 $p_i-1$ 丢到同一个数组 $b$ 中降序排序，则边权由位置靠右的点决定。设计延迟钦定配对 DP：

- 设 $f_{i,x,y,s}$ 为满足如下条件时，完美匹配的方案数：
  - 仅考虑 $b_1 \sim b_i$。
  - 当前有 $x$ 个左部点失配，$y$ 个右部点失配。
  - 已匹配边的边权和为 $s$。
- 转移时根据点的类型分讨。下面以 $b_{i+1}$ 是左部点为例说明，右部点转移同理。
  - 令 $b_{i+1}$ 暂时失配，转移 $f_{i,x,y,s} \to f_{i+1,x+1,y,s}$。
  - 令 $b_{i+1}$ 与之前某个右部点匹配，转移  $f_{i,x,y,s} \times y \to f_{i+1,x,y-1,s+b_{i+1}}$。
- DP 初值为 $f_{0,0,0,0}=1$。
- 答案为 $\sum \limits_{j=k}^{\binom{n}{2}} f_{2n,0,0,j}$。

不难发现，由于 $b_1 \sim b_i$ 的类型确定，状态中 $x,y$ 只需记录一维，另一维可以预处理后算出来。复杂度 $O(n^4)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
