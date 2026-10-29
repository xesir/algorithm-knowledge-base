---
id: prob-qoj-18404
title: 'Dangerous Data'
oj: 'QOJ'
problemId: 'QOJ18404'
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

暂无（原题：[QOJ18404](http://qoj.ac/problem/18404)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和大小为 $n+k$ 的集合 $S$，保证 $S \subseteq [1,10^6]$。可以传递一个长为 $k$ 的序列 $a_i$，要求 $a_i \in [0,2^{20})$。
> - B：已知 $n,k$ 和长为 $k$ 的序列 $a_1 \sim a_k$，以及大小为 $n$ 的集合 $T$。保证 $T \subseteq S$，你需要找出 $S \setminus T$，即缺失的 $k$ 个数字。
>
> $n \le 10^5$，$k \le 10$。

:::::success[题解]

取质数 $p \in (10^6,2^{20})$，将所有数在 $\mathbb{Z}_p$ 下运算。代码取 $p=10^6+3$。

考虑构造多项式 $F(x)=\prod\limits_{v \in S} (vx+1)$，并将 $F \bmod x^{k+1}$ 的系数传递给 B。

$F$ 的组合意义是：在 $S$ 中取出所有大小为 $k$ 的子集，统计子集元素之积的总和作为 $f_k$。可以说明 $f_0 \sim f_{n+k}$ 与 $S$ 构成双射。

B 收到 $F \bmod x^{k+1}$ 后，构造 $T$ 的对应多项式 $G(x)=\prod\limits_{v \in T} (vx+1)$，将 $G$ 除掉就得到
$$
\begin{aligned}
H(x)&=\prod_{v \in (S \setminus T)} (vx+1)\\
H&\equiv \dfrac{F}{G} \pmod {x^{k+1}}
\end{aligned}
$$
又因为 $H$ 的次数不会超过 $k$，故直接有 $H=F \times G^{-1}$ 成立。

得到 $H$ 以后，令 $H(x)=0$ 求根即为 $S \setminus T$。

多项式运算使用暴力即可，复杂度 $O(nk)$。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 1.1e5;
int n, k, a[N];
mint f[20];

void _main() {
    cin >> n >> k;
    f[0] = 1;
    for (int p = 1, x; p <= n + k; p++) {
        cin >> x;
        for (int i = k; i >= 1; i--) f[i] += f[i - 1] * x;
    } 
    for (int i = 1; i <= k; i++) cout << f[i] << ' ';
}
```

B：

```cpp line-numbers
const int N = 1.1e5;
int n, k;
mint f[20], g[20], gi[20], h[20];

mint H(mint x) {
    mint res = 0;
    for (int i = k; i >= 0; i--) res = res * x + h[i];
    return res;
}
void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k; i++) cin >> f[i];
    f[0] = g[0] = gi[0] = 1;
    for (int p = 1, x; p <= n; p++) {
        cin >> x;
        for (int i = k; i >= 1; i--) g[i] += g[i - 1] * x;
    } 
    for (int i = 1; i <= k; i++) 
        for (int j = 1; j <= i; j++) gi[i] -= g[j] * gi[i - j]; 
    for (int i = 0; i <= k; i++)
        for (int j = 0; i + j <= k; j++) h[i + j] += f[i] * gi[j];
    for (int i = 1; i <= 1e6; i++)
        if (H(mint(-1) / i) == 0) cout << i << ' ';
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
