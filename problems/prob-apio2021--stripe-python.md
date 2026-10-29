---
id: prob-apio2021
title: 'P7600 [] 封闭道路'
oj: '来源未考证'
problemId: 'APIO2021'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 图论
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

暂无（原题：[APIO2021](https://www.luogu.com.cn/problem/P7600)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵 $n$ 个节点的无根树，边带权。对于每个 $k=0,1,\cdots,n-1$ 求出：删去一些边使得每个点的度数 $\le k$，最小化删去的边权之和。
>
> $n \le 10^5$，1 秒，1024 MB。

:::::success[题解]
将问题转化为最大化保留边的边权和。

首先是一个暴力 DP：记 $f_{u,k}$ 为不保留 $u$ 处返祖边时，子树内的答案；$g_{u,k}$ 为保留 $u$ 处返祖边时，子树内的答案。

考虑先将儿子全选 $f_{u,k}$，然后反悔，选出 $g_{v,k}+w-f_{u,k}$ 最大的若干个。$f_{u,k}$ 应该由 $u$ 子树中前 $k$ 大的值转移，$g_{u,k}$ 则由前 $k-1$ 大的值转移。

复杂度 $O(n^2 \log n)$，可以获得 [24pts](https://qoj.ac/submission/2241847)。

我们注意到，度数 $\le k$ 的点不受约束。因此考虑枚举 $k$ 时对度数 $>k$ 的点建立虚树，然后在虚树上 DP。由于每个点只会出现度数次，虚树的大小之和就是 $O(n)$ 的。

沿用 $f_u$ 和 $g_u$ 的状态。当我们位于节点 $u$ 时，其儿子被分为两类：

- 虚树外的点：权值为 $w$；
- 虚树内的点：权值为 $g_v+w-f_v$。

那么只需要维护前 $k$ 大数的和就能转移。在建虚树时修改权值，对每个节点开一棵权值线段树维护，复杂度 $O(n \log n)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 1e5 + 5, M = 1e9;
int n, deg[N];
vector<pair<int, int>> e[N];

int dn, fa[N], sz[N], dep[N], son[N], top[N], dfn[N], wei[N];
void dfs1(int u) {
    sz[u] = 1, dfn[u] = ++dn;
    for (auto [v, w] : e[u]) {
        if (v == fa[u]) continue;
        fa[v] = u, wei[v] = w, dep[v] = dep[u] + 1, dfs1(v), sz[u] += sz[v];
        if (sz[v] > sz[son[u]]) son[u] = v;
    }
}
void dfs2(int u, int t) {
    top[u] = t;
    if (son[u]) dfs2(son[u], t);
    for (auto [v, w] : e[u]) if (v != fa[u] && v != son[u]) dfs2(v, v);
}
int lca(int u, int v) {
    while (top[u] != top[v]) {
        if (dep[top[u]] < dep[top[v]]) swap(u, v);
        u = fa[top[u]];
    } return dep[u] < dep[v] ? u : v;
}

#define ls lson[rt]
#define rs rson[rt]
int tot, rt[N], lson[N << 6], rson[N << 6], cnt[N << 6];
i64 sum[N << 6]; 
void insert(i64 x, i64 l, i64 r, int& rt) {
    if (!rt) rt = ++tot;
    cnt[rt]++, sum[rt] += x;
    if (l == r) return;
    i64 mid = (l + r) >> 1;
    if (x <= mid) insert(x, l, mid, ls);
    else insert(x, mid + 1, r, rs);
}
void remove(i64 x, i64 l, i64 r, int& rt) {
    if (!rt) rt = ++tot;
    cnt[rt]--, sum[rt] -= x;
    if (l == r) return;
    i64 mid = (l + r) >> 1;
    if (x <= mid) remove(x, l, mid, ls);
    else remove(x, mid + 1, r, rs);
}
i64 ask(int k, i64 l, i64 r, int rt) {
    if (rt == 0 || k <= 0) return 0;
    if (cnt[rt] <= k) return sum[rt];
    if (l == r) return l * k;
    i64 mid = (l + r) >> 1;
    if (cnt[rs] >= k) return ask(k, mid + 1, r, rs);
    return sum[rs] + ask(k - cnt[rs], l, mid, ls);
}

bool keep[N];
vector<int> nd[N], ev[N], dr[N];
i64 f[N], g[N];

void dfs3(int u, int k) {
    f[u] = g[u] = 0;
    i64 sum = 0;
    vector<i64> son;
    for (int v : ev[u]) {
        dfs3(v, k);
        if (fa[v] == u && keep[v]) sum += f[v], son.emplace_back(g[v] + wei[v] - f[v]);
        else sum += f[v];
    }
    if (keep[u]) {
        for (i64 x : son) if (x > 0) insert(x, 1, M, rt[u]);
        f[u] = sum + ask(k, 1, M, rt[u]), g[u] = sum + ask(k - 1, 1, M, rt[u]);
        for (i64 x : son) if (x > 0) remove(x, 1, M, rt[u]);
    } else {
        f[u] = sum, g[u] = 0;
    }
}

vector<i64> minimum_closure_costs(int N, vector<int> U, vector<int> V, vector<int> W) {
    n = N; i64 sum = 0;
    for (int i = 0; i < n - 1; i++) {
        int u = U[i] + 1, v = V[i] + 1, w = W[i];
        e[u].emplace_back(v, w), e[v].emplace_back(u, w);
        deg[u]++, deg[v]++, sum += w;
    }
    for (int u = 1; u <= n; u++) {
        for (int i = 0; i < deg[u]; i++) nd[i].emplace_back(u);
        dr[deg[u]].emplace_back(u);
    }
    dfs1(1), dfs2(1, 1);
    vector<i64> ans(n); ans[0] = sum;
    i64 bas = 0;
    fill(keep + 1, keep + n + 1, true);
    for (int k = 1; k < n; k++) {
        for (int u : dr[k]) {
            keep[u] = false;
            for (auto [v, w] : e[u]) {
                if (keep[v]) insert(w, 1, M, rt[v]);
                else bas += w;
            }
        }
        vector<int>& a = nd[k];
        if (a.empty()) {
            ans[k] = sum - bas;
            continue;
        }
        sort(a.begin(), a.end(), [](int u, int v) {return dfn[u] < dfn[v];});
        int len = a.size();
        for (int i = 0; i < len - 1; i++) a.emplace_back(lca(a[i], a[i + 1]));
        sort(a.begin(), a.end(), [](int u, int v) {return dfn[u] < dfn[v];});
        a.erase(unique(a.begin(), a.end()), a.end());
        for (int i = 0; i < (int)a.size() - 1; i++) 
            ev[lca(a[i], a[i + 1])].emplace_back(a[i + 1]);
        dfs3(a[0], k);
        ans[k] = sum - bas - f[a[0]];
        for (int i : a) ev[i].clear();
    }
    return ans;
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
