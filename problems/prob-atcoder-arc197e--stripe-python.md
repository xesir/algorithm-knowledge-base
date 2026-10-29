---
id: prob-atcoder-arc197e
title: 'Four Square Tiles'
oj: 'AtCoder'
problemId: 'ARC197E'
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

暂无（原题：[ARC197E](https://www.luogu.com.cn/problem/AT_arc197_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,H,W$，保证 $H,W \le 3n-1$。你需要将 $4$ 个 $n \times n$ 的正方形放置在 $H \times W$ 的网格上，方形不能相互覆盖，求合法摆放方案数。
>
> 认为两种方案不同，当且仅当存在一个方格在一种方案中被方形覆盖，另一个方案中未被覆盖。
>
> 多测，$T \le 2 \times 10^5$，$n,H,W \le 10^9$，2 秒，1024 MB。

:::::success[题解]

注意到 $H,W \le 3n-1$，故四个方形的排布必然如下图所示：

![](https://cdn.luogu.com.cn/upload/image_hosting/jtn2oigo.webp?x-oss-process=image/resize,m_lfit,w_300)

变量 $x_i,y_i$ 满足 $x_i \in [n, H-n+1] \land y_i \in [n,H-w+1]$。

不妨令 $x_i \gets x_i-n+1, y_i \gets y_i-n+1$，则新的范围为 $x_i \le H-2n+2$ 且 $y_i \le W-2n+2$，设这两个值为 $h,w$。由题目得到如下约束：

- $x_i \in [1,h] \land y_i \in [1,w]$。
- $x$ 轴不相交：$x_1 < x_2 \land x_4 < x_3$。
- $y$ 轴不相交：$y_1<y_4 \land y_2<y_3$。
- 方形 $1,3$ 不交：$x_3 \le x_1 \land y_3 \le y_1$ 不成立。
- 方形 $2,4$ 不交：$x_2 \le x_4 \land y_2 \ge y_4$ 不成立。

容易发现 $x,y$ 两维独立，对一维情形进行讨论即可。我们做一个二元容斥：

- 总方案数：由 $1 \le x_1 < x_2 \le h$ 得方案数 $\dbinom{h}{2}^2$。

- 突破一个限制：满足 $x_1< x_2 \land x_4<x_3 \land x_3 \le x_1$。枚举 $x_1=i$，则 $1 \le x_4 < x_3 \le i \land x_2>i$，方案数
  $$
  \sum_{i=1}^h \binom{h}{2}(n-i)=\binom{h+1}{4}
  $$

- 突破两个限制：满足 $x_1<x_2 \land x_4 < x_3 \land x_3 \le x_1 \land x_2 \le x_4$。画数轴可以发现这个条件是矛盾的，方案数 $0$。

由乘法原理合并独立的两维，答案式子
$$
\boxed{\binom{h}{2}^2 \binom{w}{2}^2 -2 \binom{h+1}{4} \binom{w+1}{4}}
$$
复杂度 $O(1)$。[代码](https://atcoder.jp/contests/arc197/submissions/79451904)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
