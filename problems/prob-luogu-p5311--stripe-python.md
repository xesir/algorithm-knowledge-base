---
id: prob-luogu-p5311
title: '[Ynoi2011] 成都七中'
oj: '洛谷'
problemId: 'P5311'
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

暂无（原题：[P5311](https://www.luogu.com.cn/problem/P5311)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给你一个 $n$ 个节点的无根树，点有颜色，$q$ 次查询给出 $l,r, x$，求保留 $[l,r]$ 中的节点后 $x$ 所在连通块颜色数。
>
> $n,q \le 10^5$，1 秒，250 MB。

:::::success[题解]

记 $S_{x,[l,r]}$ 为保留 $[l,r]$ 后 $x$ 的可达点集，有关键观察：$\forall y \in S_{x,[l,r]}, S_{x,[l,r]}=S_{y,[l,r]}$。

点分治起手，设分治中心为 $c$，则将 $c$ 作为代表元求解子树中的问题。具体地，对于子树中的询问 $(l,r,x)$，我们判断是否有 $c \in S_{x,[l,r]}$，若满足条件则求解 $S_{c,[l,r]}$ 的答案，若不满足则作为子问题分治处理。

现在问题转化为：求从 $c$ 出发，只经过 $[l,r]$ 的可达点集中的颜色数。

设 $(u,v)$ 两点间的路径为 $p_1,p_2,\cdots,p_k$，则 $(u,v)$ 可达当且仅当 $\forall 1 \le i \le k, p_i \in [l,r]$，即 $[\min p, \max p] \subseteq [l,r]$。

于是从 $c$ 开始自顶向下维护两个值 $mx_u, mn_u$，表示 $u$ 到 $c$ 的路径上的最大 / 最小编号，此时 $u$ 带贡献的必要条件是 $l \le mn_u \le mx_u \le r$。用二维平面来刻画，将 $(mn_u,mx_u)$ 作为一个点，问题即：在 $x \le l, y\le r$ 的区域内数颜色。

将颜色去重后进行二维数点。对于同种颜色，若存在两点 $(x_1,y_1),(x_2,y_2) $ 且 $x_1 \le x_2, y_1 \le y_2$，则 $(x_2,y_2)$ 是无用的。去重以后，将查询按 $l$ 降序排序，对 $x$ 扫描线。

采用类似于 [HH 的项链](https://www.luogu.com.cn/problem/P1972)的处理方式，维护一个树状数组，同时记录每种颜色上一次出现的位置，激活新位置时要删除上一个位置。

按照上述过程实现，视 $n,q,V$ 同阶复杂度 $O(n \log^2 n)$。

::::::

:::::info[代码]

```cpp line-numbers
const int N = 1e5 + 5;
using query = tuple<int, int, int, int>;  // {l, r, x, id}
using point = tuple<int, int, int>;  // {x, y, col}

struct BIT {
    int tr[N];
    void add(int x, int c) {
        for (; x < N; x += lowbit(x)) tr[x] += c;
    }
    int ask(int x) {
        int res = 0;
        for (; x >= 1; x -= lowbit(x)) res += tr[x];
        return res;
    }
} B;

int n, q, col[N], ans[N];
vector<int> e[N];

int ctr, cur, sz[N], vis[N];
void dfs1(int u, int fa) {
    sz[u] = 1;
    for (int v : e[u]) {
        if (v == fa || vis[v]) continue;
        dfs1(v, u), sz[u] += sz[v];
    }
    if (!ctr && 2 * sz[u] >= cur) ctr = u;
}
void dfs2(int u, int fa) {
    cur++;
    for (int v : e[u]) if (v != fa && !vis[v]) dfs2(v, u);
}

int mn[N], mx[N], bel[N];
void dfs3(int u, int fa, int minv, int maxv, int b, vector<int>& vec) {
    minv = min(minv, u), maxv = max(maxv, u);
    mn[u] = minv, mx[u] = maxv, bel[u] = b, vec.emplace_back(u);
    for (int v : e[u]) if (v != fa && !vis[v]) dfs3(v, u, minv, maxv, b, vec);
} 

int last[N];
vector<query> child[N];
vector<pair<int, int>> cp[N];
void update(int u, vector<query>& q, vector<pair<int, vector<query>>>& nxt) {
    vector<int> vec = {u};
    mn[u] = u, mx[u] = u, bel[u] = -1;
    for (int v : e[u]) {
        if (!vis[v]) dfs3(v, u, u, u, v, vec);
    }
    vector<query> now;
    for (auto& [l, r, x, id] : q) {
        if (l <= mn[x] && mx[x] <= r) now.emplace_back(l, r, x, id);
        else child[bel[x]].emplace_back(l, r, x, id);
    }
    for (int v : e[u]) {   // 下传询问
        if (vis[v] || child[v].empty()) continue;
        nxt.emplace_back(v, child[v]), child[v].clear();
    }

    // 扫描线
    vector<point> p;
    for (int v : vec) cp[col[v]].emplace_back(mn[v], mx[v]);
    for (int v : vec) {   // 去重
        if (cp[col[v]].empty()) continue;
        sort(cp[col[v]].begin(), cp[col[v]].end(), greater<pair<int, int>>());
        int ymin = 1e9;
        for (auto& [x, y] : cp[col[v]]) {
            if (y < ymin) ymin = y, p.emplace_back(x, y, col[v]);
        }
        cp[col[v]].clear();
    }
    sort(now.begin(), now.end(), greater<query>());
    sort(p.begin(), p.end(), greater<point>());

    int i = 0;
    vector<int> undo;
    for (auto& [l, r, x, id] : now) {
        for (; i < (int)p.size() && get<0>(p[i]) >= l; i++) {
            auto& [_, y, c] = p[i];
            if (last[c]) B.add(last[c], -1);
            last[c] = y, B.add(last[c], 1);
            undo.emplace_back(c);
        }
        ans[id] = B.ask(r);
    }
    for (int c : undo) if (last[c]) B.add(last[c], -1), last[c] = 0;
}

void solve(int u, vector<query>& q) {
    if (q.empty()) return;
    vis[u] = true;
    vector<pair<int, vector<query>>> nxt;
    update(u, q, nxt);
    for (auto& [v, vec] : nxt) {
        cur = ctr = 0, dfs2(v, u), dfs1(v, u);
        solve(ctr, vec);
    }
}

void _main() {
    cin >> n >> q;
    for (int i = 1; i <= n; i++) cin >> col[i];
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    vector<query> vec;
    for (int i = 1, l, r, x; i <= q; i++) {
        cin >> l >> r >> x;
        vec.emplace_back(l, r, x, i);
    }
    cur = n, dfs1(1, -1), solve(ctr, vec);
    for (int i = 1; i <= q; i++) cout << ans[i] << '\n'; 
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
