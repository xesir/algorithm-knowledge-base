---
id: prob-cf-2179f
title: 'Blackslex and Another RGB Walking'
oj: 'Codeforces'
problemId: 'CF2179F'
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

暂无（原题：[CF2179F](https://www.luogu.com.cn/problem/CF2179F)）。

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
> - A：已知一个 $n$ 个点 $m$ 条边的连通二分图，需要为每个节点染 `rgb` 中的一种颜色。
> - B：接到 $q$ 次询问，给出一个节点所有邻居的颜色集合，需要回答一个邻居，使得向这个邻居行动后离节点 $1$ 更近。
>
> $n,m,q \le 10^5$。

:::::success[题解]
先考虑 A。我们从 $1$ 开始 BFS 出一棵最短路树，然后用颜色来标记这棵最短路树的一些信息。不难发现可以用深度 $\bmod 3$ 来记录，分别染色为 `rgb` 即可。

对于 B，我们得到颜色集合 $S$。若 $|S|=1$，任意走一个邻居即可；否则必有 $|S|=2$。此时我们找到缺失的颜色，即当前节点颜色。

根据当前节点的颜色，我们可以知道向什么颜色走可以拉近距离。例如当前节点颜色为 `r` 时，根据染色规则我们应该往 `b` 走。

A & B 复杂度均为 $O(n+m)$。
:::::

:::::info[代码]
A：

```cpp line-numbers
int n, m, vis[N], dis[N];
vector<int> e[N];
void bfs(int u) {
    queue<int> q;
    q.emplace(u), dis[u] = 0, vis[u] = true;
    while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) {
            if (!vis[v]) dis[v] = dis[u] + 1, q.emplace(v), vis[v] = true;
        }
    }
}

void _main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int i = 1, u, v; i <= m; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    fill(vis + 1, vis + n + 1, 0), bfs(1);
    for (int i = 1; i <= n; i++) cout << "rgb"[dis[i] % 3];
    cout << '\n';
}
```

B：

```cpp line-numbers
int q;
string s;
void _main() {
    for (cin >> q; q--; ) {
        int d; string s; cin >> d >> s;
        set<char> st = {'r', 'g', 'b'};
        for (char c : s) {
            if (st.count(c)) st.erase(c);
        }
        if (st.size() == 2) {
            cout << 1 << '\n';
        } else {
            char x = *st.begin(), y = (x == 'r' ? 'b' : x == 'b' ? 'g' : 'r');
            cout << s.find(y) + 1 << '\n';
        }
    }
}
```

:::::

### 【未完成】[CF1033E Hidden Bipartite Graph](https://www.luogu.com.cn/problem/CF1033E)

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
