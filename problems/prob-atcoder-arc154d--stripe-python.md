---
id: prob-atcoder-arc154d
title: 'A + B > C ?'
oj: 'AtCoder'
problemId: 'ARC154D'
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

暂无（原题：[ARC154D](https://www.luogu.com.cn/problem/AT_arc154_d)）。

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
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以给出 $i,j,k$，向交互库查询 $p_i+p_j > p_k$ 是否正确。
>
> 还原这个排列。
>
> $n \le 2 \times 10^3$，满分询问次数 $2.5 \times 10^4$。

:::::success[题解]
如果我们能找到一个 $1$，那么就有 $p_i+1>p_k \iff p_i \ge p_k$。

考虑得到 $p_i$ 的逆排列 $q_i$，那么就可以对 $q$ 进行基于比较的排序。次数为 $n\log n$。

问题转化为找到 $1$，而这是容易的。考虑增量法，令 $p_x=1$，若 $p_x+p_x >p_y$ 就令 $x \gets y$，$n-1$ 轮询问。

总询问次数 $n+n\log n$。注意比较卡常，需要使用 std::stable_sort 或者手写排序。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
int n, a[N], b[N];
bool ask(int i, int j, int k) {
    cout << "? " << i << ' ' << j << ' ' << k << endl;
    string s; cin >> s;
    return s == "Yes";
}

void _main() {
    cin >> n;
    int p = 1;
    for (int i = 2; i <= n; i++) {
        if (ask(p, p, i)) p = i;
    }
    iota(b + 1, b + n + 1, 1);
    stable_sort(b + 1, b + n + 1, [&](int x, int y) -> bool {
        return !ask(x, p, y);
    });
    for (int i = 1; i <= n; i++) a[b[i]] = i;
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
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
