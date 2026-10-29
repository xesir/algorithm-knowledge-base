---
id: prob-luogu-p14012
title: '[POCamp 2023] 枫树 / Maple Tree'
oj: '洛谷'
problemId: 'P14012'
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

暂无（原题：[P14012](https://www.luogu.com.cn/problem/P14012)）。

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
> 交互库有一个大小为 $n$ 的无根树，边带权。保证任意两点距离不同，且节点度数 $\le 3$。你可以给出 $a,b,c$，向交互库查询 $\text{dis}(a,b)<\text{dis}(a,c)$ 是否成立。
>
> 还原树的形态。
>
> $n \le 10^3$，满分询问次数 $2 \times 10^4$，交互库非自适应。

:::::success[题解]
不妨将 $1$ 作为根。令 $a=1$ 后一次查询相当于比较 $b,c$ 的深度，于是可以将所有点按照深度升序排序。

这得到的是一个拓扑序。考虑按拓扑序增量构造，一次加点就是加叶子，只需确定叶子的父亲。

另一个重要观察是，可以通过一次询问排除一半子树。具体地，对于叶子 $x$ 和边 $(u,v)$，询问 $\text{dis}(u,x)$ 和 $\text{dis}(v,x)$ 可以确定 $x$ 在 $u$ 子树还是 $v$ 子树中。

注意到树是三度化的，这恰好为边分治提供了条件。于是我们用边分治挂叶子，一次加点可以做到 $\log n$ 次询问。这样总询问次数就是 $2n \log n$ 的了，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 1005;
int n, p[N], sz[N], vis[N];
vector<int> e[N];
bool ask(int x, int y, int z) {
    cout << "? " << y << ' ' << z << ' ' << x << endl;
    char c; cin >> c;
    return c == 'A';
}

void dfs1(int u, int fa) {
    sz[u] = 1;
    for (int v : e[u]) {
        if (v == fa || vis[v]) continue;
        dfs1(v, u), sz[u] += sz[v];
    }
}
void dfs2(int u, int fa) {
    vis[u] = true;
    for (int v : e[u]) {
        if (v == fa || vis[v]) continue; 
        dfs2(v, u);
    }
}
void solve(int x, int u) {
    dfs1(u, -1); int c = sz[u];
    if (c == 1) {
        e[u].emplace_back(x), e[x].emplace_back(u);
        return;
    }
    int p = -1, q = -1, mw = 1e9;
    function<void(int, int)> dfs = [&](int u, int fa) -> void {
        for (int v : e[u]) {
            if (v == fa || vis[v]) continue;
            int w = max(sz[v], c - sz[v]);
            if (w < mw) p = u, q = v, mw = w;
            dfs(v, u);
        }
    };
    dfs(u, -1);
    if (ask(x, p, q)) dfs2(q, p), solve(x, p);
    else dfs2(p, q), solve(x, q);
}

void _main() {
    cin >> n;
    iota(p + 1, p + n + 1, 1);
    stable_sort(p + 2, p + n + 1, [](int x, int y) -> bool {
        return ask(1, x, y);
    });
    for (int i = 2; i <= n; i++) {
        fill(vis + 1, vis + n + 1, 0);
        solve(p[i], 1);
    }
    cout << "!\n";
    for (int u = 1; u <= n; u++) 
        for (int v : e[u]) if (u < v) cout << u << ' ' << v << '\n';
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
