---
id: prob-luogu-p14364
title: '[CSP-S 2025] 员工招聘'
oj: '洛谷'
problemId: 'P14364'
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

暂无（原题：[P14364](https://www.luogu.com.cn/problem/P14364)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 和长为 $n$ 的 01 串 $S$。考虑 $1\sim n$ 的排列 $p_i$，初始有变量 $x=0$，依次对 $i=1,2,\cdots,n$ 执行：
>
> - 若 $S_i=0$ 或 $x \ge c_{p_i}$，令 $x\gets x+1$。
>
> 求最终 $x \le n-m$ 的 $p_i$ 数目。
>
> $n,m \le 500$，2 秒，512 MB。

:::::success[解法一]

考虑从左到右填入的计数顺序。

注意到 $c_i \le x$ 的 $i$ 行为相同，$c_i>x$ 的 $i$ 行为相同，且转化具有单向性，故设计延迟钦定 DP：

- 设 $f_{i,x,y}$ 为满足下列条件的合法方案数：

  - 仅决策 $p_1\sim p_i$。
  - $x$ 为考虑到 $i$ 时变量的值。
  - 前缀 $1\sim i$ 中预留 $y$ 个 $c_i>x$ 的位置，这些位置的具体值待定。

- 转移令 $f_{i-1,x,y} \to f_{i,x',y'}$。对 $S_i$ 分讨：

  - 若 $S_i=0$，必然有 $x'=x+1$。此时 $c_i=x'$ 的 $i$ 移除待定部分，枚举原待定部分 $c_i=x'$ 的数目 $z \in [0,y]$，则 $y' \gets y-z$。贡献系数为：

    - 选出 $z$ 个数在原待定部分，方案数 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z}$。
    - 令 $z$ 个数任意排列，方案数 $z!$。

    设 $a_x$ 为 $c_i \le x$ 的 $i$ 的数目。讨论 $c_{p_i}$ 与 $x'$ 的大小关系：

    - 钦定 $c_{p_i} \le x'$，已用掉 $(i-1)-(y-z)$ 个 $\le x'$ 的数，可用的数目为 $a_{x+1}-(i-1-(y-z))$。

      转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z} z!(a_{x+1}-(i-1-y+z))f_{i-1,x,y} \to f_{i,x+1,y-z}$。

    - 钦定 $c_{p_i}>x'$，将 $p_i$ 扔进待定部分，转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z}z! f_{i-1,x,y} \to f_{i,x+1,y-z+1}$。

  - 若 $S_i=1$，只要讨论 $c_{p_i}$ 与 $x$ 的大小关系。

    - 若 $c_{p_i} \le x$，则 $x'=x+1$。枚举 $z$ 个 $i$ 移出待定部分，贡献系数同理。已用掉 $(i-1)-y$ 个 $\le x$ 的数，可用数目 $a_x-(i-1-y)$。

      转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z} z!(a_x-(i-1-y)) f_{i-1,x,y} \to f_{i,x+1,y-z}$。

    - 若 $c_{p_i} >x$，则 $x'=x$，将 $p_i$ 扔进待定部分，直接转移 $f_{i-1,x,y} \to f_{i,x,y+1}$。

- DP 初值为 $f_{0,0,0}=1$。

- 答案为 $\sum \limits_{x=0}^{n-m} (n-a_x)!f_{n,x,n-a_x}$，系数 $(n-a_x)!$ 表示令待定部分随意排列。

注意到 $\sum \text{cnt}=n$，故 $z$ 的总枚举次数正确，复杂度 $O(n^3)$。注意常数问题，[代码](https://qoj.ac/submission/3058467)。

:::::

:::::success[解法二]

取集合 $U=\{i \mid S_i=1\}$，设 $S \subseteq U$ 为 $x$ 不变的位置集合，只要 $|S|\ge m$。对位置 $i$ 分讨：

- 若 $i \in S$，要求 $c_i>\sum \limits_{j < i} [j \notin S]$。
- 若 $i \notin U \setminus S$，要求 $c_i \le \sum\limits_{j<i} [j \notin S]$。

限制 $c_i > *$ 是困难的，将其容斥为 $1-[c_i \le *]$。钦定 $T \subseteq S$ 满足：

- 若 $i \in T$，要求 $c_i \le \sum\limits_{j<i} [j \notin S]$。
- 若 $i \in S \setminus T$，$c_i$ 无限制。

容斥系数 $(-1)^{|T|}$。

这里 $(T,S \setminus T, U \setminus S)$ 构成 $U$ 的划分。对划分情况进行 DP：

- 设 $f_{i,u,v}$ 为满足下列情况的合法方案数：

  - 仅考虑 $1 \sim i$ 位置。
  - $|S|=u$ 且 $|T|=v$。
  - 仅考虑 $T$ 和 $U \setminus S$ 位置上填入的数。

- 转移时逐个加 $i$，令 $f_{i-1,u,v} \to f_{i,u',v'}$。

  - 若 $S_i=0$ 则 $i\notin S$，转移 $f_{i-1,u,v} \to f_{i,u,v}$。

  - 若 $S_i=1$，此时 $x=i-1-u$。剩余 $\le x$ 的点数为 $q=\sum \limits_{i=1}^n [c_i \le x]-|T|-|U \setminus S|$。

    其中 $|T|=v$，$|U\setminus S|=|U|-|S|=\sum \limits_{j <i} [S_j=1]-u$。容易预处理后算出转移系数 $q$。

    - 令 $i$ 加入 $U \setminus S$，需要 $c_i \le x$，转移 $q \times f_{i-1,u,v} \to f_{i,u,v}$。
    - 令 $i$ 加入 $T$，需要 $c_i \le x$，转移 $q \times f_{i-1,u,v} \to f_{i,u+1,v+1}$。
    - 令 $i$ 加入 $S \setminus T$，无限制，转移 $f_{i-1,u,v} \to f_{i,u+1,v}$。

- DP 初值为 $f_{0,0,0}=1$。

- 算答案时枚举 $(u,v)$ 满足 $u \ge m$。容斥系数 $(-1)^v$，剩余 $|S \setminus T|$ 个位置任意排列，方案数 $\left(n-|U|+u-v\right)!$。则答案式为
  $$
  \sum_{u=m}^n \sum_{v=0}^u (-1)^v\left(n-|U|+u-v\right)! f_{n,u,v}
  $$

复杂度 $O(n^3)$。[代码](https://qoj.ac/submission/3058752)。

带着容斥系数 DP，将 $(-1)^v$ 放到 DP 值里面就是第一篇题解的做法了。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
