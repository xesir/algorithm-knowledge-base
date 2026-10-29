---
id: prob-loj-6669
title: 'Nauuo and Binary Tree'
oj: 'LibreOJ'
problemId: 'LOJ6669'
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

暂无（原题：[LOJ6669](https://loj.ac/p/6669)）。

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
> 交互库隐藏了一个大小为 $n$ 的二叉树，根节点为 $1$。可以向交互库询问树上两点间距离。
>
> 求出每个点的父亲。
>
> $n \le 3 \times 10^3$，满分询问次数 $3 \times 10^4$。

:::::success[题解]
可以先通过 $n-1$ 次询问求出每个点的深度。这样询问两点距离还能知道其 LCA 的深度。

将节点按深度升序排序，我们就获得了一个层序遍历。不妨直接扫描这个序列，对于每个点 $x$ 找到其父亲。

这里直接暴力是 $O(n^2)$ 的，我们可以对树进行重链剖分。每次询问 $x$ 和重链底的距离，求出其 LCA 深度以后对应到重链上的具体节点。

因为本题是二叉树，我们可以直接进入 LCA 的另一棵子树去递归，重复上述流程即可。

操作次数为 $n \log n$ 级别，且重剖带 $1/2$ 常数。每次枚举点并暴力树剖，时间复杂度 $O(n^2)$，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3005;
int n, dep[N], fa[N], sz[N], son[N], bot[N], ch[2][N];
vector<int> vec[N];
int ask(int u, int v) {
    if (u == v) return 0;
    cout << "? " << u << ' ' << v << endl;
    int x; cin >> x;
    return x;
}

#define ls ch[0][u]
#define rs ch[1][u]
void dfs(int u) {
    sz[u] = 1, bot[u] = u, son[u] = 0;
    for (int v : {ls, rs}) {
        if (v == 0) continue;
        dfs(v), sz[u] += sz[v];
        if (sz[v] > sz[son[u]]) son[u] = v;
    }
    if (son[u]) bot[u] = bot[son[u]];
}
void solve(int x) {
    int u = 1;
    while (true) {
        int d = (dep[x] + dep[bot[u]] - ask(x, bot[u])) / 2;
        while (dep[u] < d) u = son[u];
        if (dep[u] == dep[x] - 1) break;
        u = (ls != son[u] ? ls : rs);
    }
    fa[x] = u;
    if (ls == 0) ls = x;
    else rs = x;
}

void _main() {
    cin >> n;
    for (int i = 2; i <= n; i++) {
        dep[i] = ask(1, i);
        vec[dep[i]].emplace_back(i);
    }
    for (int i = 1; i <= n; i++) {
        dfs(1);
        for (int x : vec[i]) solve(x);
    }
    cout << "! ";
    for (int i = 2; i <= n; i++) cout << fa[i] << ' ';
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
