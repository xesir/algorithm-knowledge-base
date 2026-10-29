---
id: prob-zr-3554
title: '抽卡'
oj: '正睿'
problemId: 'ZR3554'
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

暂无（原题：[ZR3554](https://www.zhengruioi.com/problem/3554)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 种卡，每种卡有三种颜色，共 $3n$ 张不同卡牌。一轮抽卡包含 $m$ 次独立抽取：
>
> - 前 $m-1$ 次抽卡中，抽到第 $i$ 种卡的概率为 $p_i$，抽取失败的概率为 $1-\sum \limits_{i=1}^n p_i$。
> - 最后一次抽卡中，抽到第 $i$ 种卡的概率为 $q_i$，抽取失败的概率为 $1-\sum \limits_{i=1}^n q_i$。
> - 抽到某种卡后，等可能性地获得三种颜色之一。
>
> 求集齐 $3n$ 种不同卡牌的轮数期望，保证期望存在。
>
> $\textcolor{red}{n \le 9}$，$m \le 64$，1 秒，512 MB。

:::::success[题解]

设第 $i$ 张卡牌的抽取时间为 $t_i$，题目即求 $E(\max t_i)$。由 max-min 容斥：
$$
E\left(\max_{i \in U} t_i\right)=\sum_{S \subseteq U}(-1)^{|S|-1} E\left(\min_{i \in S} t_i\right)
$$
组合意义是，配上 $(-1)^{|S|-1}$ 的容斥系数，转而计算 $S$ 中任意卡牌被抽取的期望轮数。

设 $p=\sum \limits_{i \in S}\frac{1}{3}p_i$，$q=\sum\limits_{i \in S} \frac{1}{3}q_i$，单步容斥得一轮成功的概率为 $1-(1-p)^{m-1}(1-q)$。由几何分布，期望轮数
$$
E\left(\min_{i \in S} t_i\right)=\boxed{\dfrac{1}{1-(1-p)^{m-1}(1-q)}}
$$
直接枚举 $S$ 的复杂度为 $O(8^n)$，无法通过。利用颜色的对称性，可以用四进制数编码 $S$，枚举每种卡牌在 $S$ 中出现的次数，对应系数为 $\binom{3}{\text{cnt}}$。

复杂度 $O(4^n)$。[代码](https://www.zhengruioi.com/submission/1094623)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
