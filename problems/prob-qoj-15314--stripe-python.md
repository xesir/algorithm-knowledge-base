---
id: prob-qoj-15314
title: 'Menji, we miss you!'
oj: 'QOJ'
problemId: 'QOJ15314'
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

暂无（原题：[QOJ15314](https://qoj.ac/problem/15314/)）。

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
> 给出一棵节点数为 $n$ 的有根树，根节点为 $1$，保证节点儿子数目 $\le 2$。交互库有一个隐藏的点 $x$。你可以给出 $u,k$，向交互库查询 $\text{dis}(u,x) \le k$ 是否成立。
>
> 找出点 $x$。
>
> 多测，$T \le 100$，$n \le 3 \times 10^4$，满分询问次数 $40$，交互库自适应。

:::::success[题解]
考虑猜数模型，通过询问 $\text{dis}(1,x)$ 可以在 $\log n$ 次询问内得到节点 $x$ 的深度。

得到深度 $d$ 以后，可以询问 $(u,d-d_u)$ 来确定 $x \in \text{subtree}(u)$ 是否成立。考虑通过搜子树的方法找到 $x$。

可以得到一个候选集合 $S$。记 $f_u=\sum \limits_{v \in \text{subtree}(u)} [v \in S]$。有结论：必然存在子树 $u$ 使得 $f_u \ge \frac{2}{3} |S|$。由二叉树的结构易证。

考虑维护集合 $S$，每次取一个 $f_u$ 最接近 $\frac{1}{2} |S|$ 的子树继续递归，那么询问次数为 $\log_{1.5} n \approx 1.7 \log n$。总询问次数约 $2.7 \log n$ 且完全跑不满，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e4 + 5;
bool ask(int u, int k) {
    cout << "? " << u << ' ' << k << endl;
    int x; cin >> x;
    return x;
}
int n, dn, f[N], sz[N], dfn[N], dep[N];
vector<int> e[N];

void dfs1(int u) {
    sz[u] = 1, dfn[u] = ++dn;
    for (int v : e[u]) dep[v] = dep[u] + 1, dfs1(v), sz[u] += sz[v]; 
}
void dfs2(int u) {
    for (int v : e[u]) dfs2(v), f[u] += f[v];
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int v = 2, u; v <= n; v++) cin >> u, e[u].emplace_back(v);
    dn = 0, dfs1(1);
    int l = 0, r = n, d = -1;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (ask(1, mid)) d = mid, r = mid - 1;
        else l = mid + 1;
    }
    vector<int> vec;
    for (int i = 1; i <= n; i++) 
        if (dep[i] == d) vec.emplace_back(i);
    while (vec.size() > 1) {
        fill(f, f + n + 1, 0);
        for (int u : vec) f[u] = 1;
        dfs2(1);
        int u = 1, v = -1, t = vec.size() / 2;
        while (true) {
            int h = 0;
            for (int v : e[u]) if (f[v] > f[h]) h = v;
            if (f[h] <= t) {
                v = h; break;
            } u = h;
        }
        if (abs(f[u] - t) > abs(f[v] - t)) swap(u, v);
        vector<int> nxt;
        if (ask(u, d - dep[u])) {
            for (int x : vec) if (dfn[u] <= dfn[x] && dfn[x] <= dfn[u] + sz[u] - 1) 
                nxt.emplace_back(x);
        } else {
            for (int x : vec) if (!(dfn[u] <= dfn[x] && dfn[x] <= dfn[u] + sz[u] - 1)) 
                nxt.emplace_back(x);
        }
        vec.swap(nxt);
    }
    cout << "! " << vec[0] << endl;
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
