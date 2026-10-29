---
id: prob-luogu-p10539
title: '[APIO2024] 魔术表演'
oj: '洛谷'
problemId: 'P10539'
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

暂无（原题：[P10539](https://www.luogu.com.cn/problem/P10539)）。

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
> - A：已知一个正整数 $x$，需要传递一棵节点数为 $n$ 的树。
> - B：已知传输的树，还原 $x$。
>
> 通信过程中，至多 $\lfloor \frac{n-2}{2} \rfloor$ 条边会被交互库删除。
>
> $1 \le x \le 10^{18}$，满分要求 $n \le 5000$。

:::::success[题解]
感觉这个题有一万种做法。下面给出一个思维难度小，且比较奶龙的做法。

考虑拆二进制位。对于节点 $u$，随机一个 $d_u \in [0,60)$，然后用 $u$ 维护 $x$ 二进制下第 $d_u$ 位。

直接连边可能会有一些度数上的问题，会被交互库识别并卡掉。考虑对于 $3 \le u \le 5000$，随机 $a_u,b_u$ 为其两个备选父亲，二进制为 $1$ 则连边 $a_u \to u$，否则连边 $b_u \to u$。

只要 $n=5000$，上述做法大概率能得到树，且不会被卡掉。

随机数生成器使用相同种子，可以保证 $d_u,a_u,b_u$ 都一致。B 收到树以后简单还原即可。
:::::

:::::info[代码]
A:

```cpp line-numbers
const int N = 5005;
using node = pair<int, int>;
static mt19937 rand32(2026);
static int d[N], a[N], b[N];

vector<pair<int, int>> Alice() {
    const int n = 5000;
    for (int i = 3; i <= n; i++) {
        d[i] = rand32() % 60;
        do a[i] = rand32() % (i - 1) + 1, b[i] = rand32() % (i - 1) + 1;
        while (a[i] == b[i]);
    }
    vector<node> e;
    i64 x = setN(n);
    for (int i = 3; i <= n; i++) {
        if (x >> d[i] & 1) e.emplace_back(a[i], i);
        else e.emplace_back(b[i], i);
    }
    e.emplace_back(1, 2);
    return e;
}
```

B：

```cpp line-numbers
const int N = 5005;
using node = pair<int, int>;
static mt19937 rand32(2026);
static int d[N], a[N], b[N], has[N];

i64 Bob(vector<node> V) {
    const int n = 5000;
    for (int i = 3; i <= n; i++) {
        d[i] = rand32() % 60;
        do a[i] = rand32() % (i - 1) + 1, b[i] = rand32() % (i - 1) + 1;
        while (a[i] == b[i]);
    }
    for (auto [u, v] : V) {
        if (u == a[v]) has[v] = 1;  
        if (v == a[u]) has[u] = 1;
    }
    i64 x = 0;
    for (int i = 3; i <= n; i++) {
        if (has[i]) x |= 1LL << d[i];
    } return x;
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
