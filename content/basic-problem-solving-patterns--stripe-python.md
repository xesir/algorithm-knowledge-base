---
id: basic-problem-solving-patterns
title: '做题套路与结论汇总'
category: '基础算法'
subcategory: '优化技巧'
tags: ["套路","结论","技巧","杂项"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
这里记录一些做题时学到的结论 & 套路 & 注意事项。

1. 区间 $[l,r]$ 内的下标 $x$ 在该区间翻转后的下标是 $l+r-x$。
2. 维护 $01$ 序列的时候，可以维护所有 $0/1$ 的下标。
3. 一个数 $v \ge 1$ 在 $O(\log \log v)$ 次开方下取整后变为 $1$。
4. 不刻意卡的 $O(\dfrac{n}{w})$ 比 $O(\log n)$ 快很多。
5. 带修莫队的块长取 $1.7n^{0.667}$ 更快。
6. bitset 优化埃氏筛比线性筛快。
7. $\operatorname{mex}$ 的值最多是 $n+1$。
8. `std::multiset` 删元素要用 `erase(find(val))`。
9. 写出类似 `for (int i = 1; i <= k; i++) v = x[v];` 的代码时都可以倍增优化到 $O(\log k)$。
10. 点权最短路和边权没什么区别。
11. 当 $x \oplus y=\gcd(x,y)=z$ 时，必有 $x-y=z$。UVA12716。
12. 经过一个点的最小环等价于次短路问题。
13. 多项式哈希的线性性：有 $\sum_{i=1}^{n} k \times s_i \times B^{n-i}+\sum_{i=1}^{n} b \times B^{n-i}=k \times h_n+b$。因此可以上线段树维护。
14. 最小化 $\text{最大}+\text{次大}$ 时，绝大部分是枚举最大找最小的次大。
15. 求 $\sum (a_i \bmod M)$ 时，不妨求 $\sum a_i+kM$。ABC378-E。
16. 删点 / 覆盖问题可以倒序做变成加点 / 去覆盖。
17. 设计 dp 时，可以考虑用两维的特征压成一维记录。P5664。
18. 环上问题可以倒着想，例如 $\max$ 变成 $\max(\max, \sum-\min)$。
19. 将奇形怪状的东西放到棋盘里，对棋盘进行黑白染色。则两种颜色的个数为 $\lfloor \dfrac{nm}{2} \rfloor$ 与 $\lceil \dfrac{nm}{2} \rceil$。
20. 类似 $2b=a+c$ 的三元组统计，考虑求多项式卷积。ABC392-G。
21. $\max(x,y)=\dfrac{x+y+|x-y|}{2}$。
22. 满足 $x_i>0, \sum_{i=1}^{n} x_i=1$ 的

$x_1+x_1x_2+x_1x_2x_3+\cdots=\sum_{i=1}^{n} \prod_{j=1}^{i} a_j$的最小值为 $3^{\frac{n}{3}}$。

1. 对于双端点询问 $[l,r]$，若有 $[1,r]-[1,l-1]$ 可变为单端点询问。
2. 对于四端点询问 $[l_1,r_1,l_2,r_2]$，若有 $[1,r]-[1,l-1]$ 可变为双端点询问 $[r_1,r_2]-[l_1-1,r_2]-[r_1,l_2-1]+[l_1-1,l_2-1]$。
3. 用 Dijkstra 求最短路，要求松弛函数 $f(dis_v,w)$ 满足两个条件：$f(dis_v,w) \ge dis_v$ 且关于 $dis_v$ 单调递增。
4. 树上问题对一条路径的边权异或，可以化边为点，等价于对端点异或。
5. 随机排列的 LIS 长度是 $O(\sqrt{n})$ 级别的。
6. 折半警报器 / 二进制警报器：P7603。
7. 将题目转化为最短哈密顿路时，往往考虑变成欧拉回路。
8. 二分图博弈的结论：存在一个点属于所有最大匹配先手必胜（且作为起点），否则先手必败。P4617。结合黑白染色。
9. dsu on tree：先 dfs 轻儿子并清空，再 dfs 重儿子不清空，然后再加入所有亲儿子的信息，复杂度为 $O(n \log n)$。
10. 对小于 / 大于某数的计数，如果小于 = 大于，考虑转化为 $\frac{\text{总数}-\text{等于}}{2}$。CF1227F2。
