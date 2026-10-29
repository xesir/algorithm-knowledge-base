---
id: prob-atcoder-jsc2019-qual-f
title: 'Candy Retribution'
oj: 'AtCoder'
problemId: 'JSC2019_QUAL_F'
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

暂无（原题：[JSC2019_QUAL_F](https://www.luogu.com.cn/problem/AT_jsc2019_qual_f)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$。对满足下列条件的长为 $n$ 的序列 $a_i$ 计数：
>
> - $\forall i \in [1,n], a_i \ge 0$。
>
> - $\sum \limits_{i=1}^n a_i \in [l,r]$。
> - 将 $a$ 降序排序后，$a_m=a_{m+1}$。
>
> $n,m,l,r \le 3 \times 10^5$，2 秒，1024 MB。

:::::success[题解]

不妨令 $a_i \gets a_i+1$ 转而计数正整数序列。令 $m \gets n-m$ 转为升序排序后 $a_m=a_{m+1}$。

先将 $[l,r]$ 差分成 $[1,r] \setminus [1,l)$，变成总和有一个上限 $r$。

做一个单步容斥，用总数减去 $a_m<a_{m+1}$ 的序列数。枚举总和 $k $ 得到总数 $\sum \limits_{k=1}^r \dbinom{k+n-1}{n-1}=\dbinom{r+n}{n}$。

枚举排序后 $a_m=x$，排列被分成两段，$1 \sim m$ 段的值域为 $[1,x]$，而 $m+1 \sim n$ 段的值域为 $(x,n]$。

再来一次单步容斥：钦定 $1 \sim m$ 段的值域为 $[1,x]$，然后减掉钦定为 $[1,x-1]$ 的方案数，则 $a_m=x$ 的限制可以丢掉。

问题转化为，计数恰有 $m$ 个数 $\le a$，$n-m$ 个数 $\ge b$，总和不超过 $r$ 的序列。这个可以容斥也可以 GF 启动，下面是熔池观点。

**钦定至少** $i$ 个位置 $>a$，由二项式反演，容斥系数 $(-1)^i \dbinom{m}{i}$。

令钦定的 $i$ 个位置减去 $a$，选定的 $\ge b$ 的位置减去 $b$，总和为 $r'=r-m-i \times a-(n-m)b$。剩余选法为 $\dbinom{r'+n}{n}$。

答案即为
$$
f(a,b)=\binom{n}{m}\sum_{i=0}^{m} (-1)^i \binom{m}{i} \binom{r'+n}{n}
$$
其中 $r' \ge 0 \implies i \le \dfrac{*}{a}$，$*$ 是 $O(n)$ 级别的常数。

在外层循环枚举 $x$ 得到 $a,b$，内层循环枚举 $i$，根据 $i$ 的合法条件可知，这属于调和型枚举，复杂度是 $O(n \log n)$ 可以通过。[代码](https://www.luogu.com.cn/article/uwatuto9)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
