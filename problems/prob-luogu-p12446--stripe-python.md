---
id: prob-luogu-p12446
title: '[COTS 2025] 答好位 / Vrsta'
oj: '洛谷'
problemId: 'P12446'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 基础算法
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

暂无（原题：[P12446](https://www.luogu.com.cn/problem/P12446)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个 $1 \sim n$ 的排列 $p_i$。你可以进行 $K$ 次询问，给出 $l,r$ 得到区间 $[l,r]$ 中次大值的下标。
>
> 询问结束后，交互库进行 $Q$ 次询问，给出 $l,r$，你需要回答区间 $[l,r]$ 中次大值的下标。
>
> $n \le 512$，满分要求 $K=Q=2048 $，交互库非自适应。

:::::success[题解]

题意等价于 $K$ 次询问，还原所有区间的次大值下标。我们先打表观察区间次大的结构。这里以 $p=[4,7,3,6,1,5,8,2]$ 为例：

![](https://cdn.luogu.com.cn/upload/image_hosting/qzls7855.png)

**性质** 每个下标 $x$ 所在的区域必然为若干矩形。

**证明** 考虑区间 $[l_0,r_0]$，设其最大值下标为 $y$，次大值下标为 $x$，不妨设 $y<x$。易知 $l \in [l_0,y]$ 且 $r \in [x, r_0]$ 的 $[l,r]$ 的次大值位置全为 $y$。在二维平面上，这恰好是矩形 $[l_0,y] \times [x,r_0]$。

基于此编一个做法：考察全局区间 $[1,n]$，先询问得到次大值 $y$，并设法得到最大值 $x$。根据上述结论，$[1,y] \times [x,n]$ 的矩形可以被填好：

![](https://cdn.luogu.com.cn/upload/image_hosting/pqvn3tib.png)

更一般地，考虑分治处理，设计递归状态为处理区间 $[l,r]$，且已知区间 $\max$ 的位置为 $y$。对 $[l,r]$ 询问即得 $x$，将 $[l,y] \times [x,r]$ 填好。

此时相当于挖去右上角的一个矩形，问题规约到左上角和右下角的三角形区域，即 $[l,x)$ 和 $(y,r]$。

![](https://cdn.luogu.com.cn/upload/image_hosting/7y61m0qe.png)

我们分析两个区域的最大值位置：

- $[l,y)$ 区域：由于 $x \in [l,y)$，故最大值还是 $x$。
- $(x,r]$ 区域：由于 $y \in (x,r]$ 且 $y$ 是原本的次大值，故 $y$ 是新的最大值。

这表明，我们确实可以递归解决问题。判重以后这个部分只需要 $2n$ 次询问。

下面只要解决初始找全局 $\max$ 的问题。考虑增量法，初始维护 $[x,x]$，并将右端点 $r$ 不断扩展。当 $r \gets r+1$ 且次大值发生突变时，说明新加入的 $r$ 恰为全局 $\max$，对 $l$ 的扩展同理，询问次数 $n$。

总询问次数为 $3n$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 605;
int n, q, ans[N][N], vis[N][N];
int ask(int l, int r) {
    cout << "? " << l << ' ' << r << endl;
    int x; cin >> x;
    return x;
}

void solve(int l, int r, int y) {
    if (l == r) return;
    if (vis[l][r]) return;
    vis[l][r] = true;
    int x = ask(l, r);
    auto [lo, hi] = minmax(x, y);
    for (int i = l; i <= lo; i++)
        for (int j = hi; j <= r; j++) ans[i][j] = x;
    solve(l, hi - 1, lo), solve(lo + 1, r, hi);
} 

void _main() {
    cin >> n;
    int x = ask(1, n), l = x, r = x, y = -1;
    while (r < n && y == -1) if (ask(l, ++r) == x) y = r;
    while (l > 1 && y == -1) if (ask(--l, r) == x) y = l; 
    solve(1, n, y);
    cout << "!" << endl, cin >> q;
    for (int l, r; q--; ) cin >> l >> r, cout << ans[l][r] << endl;
} 
```
:::::

### 【未完成】[QOJ18206 Guess the Permutation](https://qoj.ac/problem/18206)

> 这是一道交互题。
>
> 交互库隐藏了一个 $0 \sim n$ 的排列 $p_i$，一次询问给出 $i,j$，交互库返回 $k$ 满足 $p_k=|p_i-p_j|$。
>
> 还原这个排列。
>
> 多测，$T \le 100$，$n \le 10^3$，满分询问次数 $1024$，交互库自适应。

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
