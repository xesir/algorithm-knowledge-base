---
id: prob-cf-2164g
title: 'Pointless Machine'
oj: 'Codeforces'
problemId: 'CF2164G'
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

暂无（原题：[CF2164G](https://www.luogu.com.cn/problem/CF2164G)）。

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
> 交互库隐藏了一棵大小为 $n$ 的无根树。你可以给出一个 $1 \sim n$ 的排列 $p$，交互库对于每个 $1 \le i \le n$ 回答 $\{p_1,p_2,\cdots,p_i\}$ 的导出子图的边数。所有询问结束后交互库才会给出回答。
>
> 还原这棵树。
>
> 多测，$\sum n \le 5 \times 10^4$，满分询问次数 $31$，交互库非自适应。

:::::success[题解]
考虑毒药模型。对于第 $k$ 位，按照二进制下第 $k$ 位将所有节点分成两个集合 $V_0,V_1$。

我们进行如下两次询问：

- 构造排列 $p_0$，将 $V_0$ 放在前面，$V_1$ 放在后面。对于 $u \in V_1$，由于其前面包含了整个 $V_0$，因此通过差值可以求出 $V_0$ 中 $u$ 的邻居数目。
- 构造排列 $p_1$，将 $V_1$ 放在前面，$V_0$ 放在后面，原因同上。

经过上述询问，我们可以知道每个节点有多少个二进制第 $k$ 位不同的邻居，记为 $f(u,k)$。

考虑额外询问一次 $p=[n,n-1,\cdots,1]$，求出 $u$ 有多少个大于它的邻居。配合 $\max f(u,k)=1$ 的条件即可确定 $u$ 是否是叶子。

因此考虑拓扑排序还原树。对于零入度点 $u$，只需按位还原其邻居 $v$。

计算一下上述做法的询问次数为 $16 \times 2+1=33$ 次，无法通过。

考虑转三进制拆分。如果可行，询问次数就变成了 $10 \times 3+1=31$ 次，恰好通过。

这确实是可行的，我们给出如下三种排列：

- $p_0=[V_1,V_2,V_0]$；
- $p_1=[V_2,V_0,V_1]$；
- $p_2=[V_0,V_1,V_2]$。

多作一次差就能得到 $f(u,k)$。处理邻居时，我们无法直接拆位，因此记录一下累计偏移量，每次乘 $3^k$ 加入即可。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 5e4 + 5;
const int pw[] = {1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049, 177147};
int n, k, pos[N], cnt[N], off[N];
vector<vector<int>> a;
vector<vector<int>> q;
vector<vector<int>> val;
vector<int> s[N];
vector<array<int, 3>> b[N];
vector<pair<int, int>> e;

void addq(int i, int a, int b, int c) {
    vector<int> cur;
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == a) cur.emplace_back(u);
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == b) cur.emplace_back(u);
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == c) cur.emplace_back(u);
    q.emplace_back(cur);
}
void ask() {
    cout << q.size() << '\n';
    for (auto i : q) {
        for (auto u : i) cout << u << ' ';
        cout << '\n';
    } cout << flush;
    a.assign(q.size(), vector<int>(n + 1));
    for (int i = 0; i < (int)q.size(); i++) {
        for (int j = 1; j <= n; j++) cin >> a[i][j];
    }
}

bool vis[N];
void bfs() {
    queue<int> q;
    e.clear(), fill(vis + 1, vis + n + 1, 0);
    auto isleaf = [&](int u) -> bool {
        int v = u + off[u];
        if (v < 1 || v > n || u == v || vis[v]) return false;
        if (cnt[u] != (v > u ? 1 : 0)) return false;
        for (int i = 0; i < k; i++) {
            int d1 = u / pw[i] % 3, d2 = v / pw[i] % 3;
            if (s[u][i] != (v < u && d1 == d2 ? 1 : 0)) return false;
            for (int d = 0; d < 3; d++) {
                if (d == d1) continue;
                if (b[u][i][d] != (d2 == d ? 1 : 0)) return false;
            }
        } return true;
    };
    for (int i = 1; i <= n; i++) {
        if (isleaf(i)) q.emplace(i);
    }
    while (!q.empty()) {
        int u = q.front(), v = u + off[u]; q.pop();
        if (vis[u] || !isleaf(u)) continue;
        e.emplace_back(u, v), vis[u] = true;
        off[v] -= u - v;
        if (u > v) cnt[v]--;
        for (int i = 0; i < k; i++) {
            int d1 = u / pw[i] % 3, d2 = v / pw[i] % 3;
            if (d1 == d2) s[v][i] -= u < v;
            else b[v][i][d1]--;
        } 
        if (!vis[v] && isleaf(v)) q.emplace(v);
    }
}

void _main() {
    cin >> n; q.clear();
    for (int i = 0; pw[i] <= n; i++) addq(i, 1, 2, 0), addq(i, 2, 0, 1), addq(i, 0, 1, 2);
    k = q.size() / 3, q.emplace_back();
    for (int i = 1; i <= n; i++) q.back().emplace_back(n - i + 1);
    ask();
    val.assign(q.size(), vector<int>(n + 1));
    for (int i = 0; i < (int)q.size(); i++) {
        fill(pos, pos + n + 1, 0);
        for (int j = 0; j < n; j++) pos[q[i][j]] = j + 1;
        for (int u = 1; u <= n; u++) val[i][u] = a[i][pos[u]] - a[i][pos[u] - 1];
    }
    for (int i = 1; i <= n; i++) b[i].assign(k, {0, 0, 0});
    fill(off + 1, off + n + 1, 0);
    for (int i = 1; i <= n; i++) s[i].assign(k, 0);
    for (int u = 1; u <= n; u++) {
        for (int i = 0; i < k; i++) {
            int d = u / pw[i] % 3;
            int q0 = 3 * i + d, q1 = 3 * i + (d + 1) % 3, q2 = 3 * i + (d + 2) % 3;
            int e1 = val[q0][u] - val[q1][u], e2 = val[q1][u] - val[q2][u];
            b[u][i][(d + 1) % 3] = e1, b[u][i][(d + 2) % 3] = e2;
            off[u] += e1 * ((d + 1) % 3 - d) * pw[i] + e2 * ((d + 2) % 3 - d) * pw[i];
            s[u][i] = val[q2][u];
        }
        cnt[u] = val.back()[u];
    }
    bfs();
    for (auto& i : e) cout << i << '\n';
    cout << flush;
} 
```

:::::

## 还原图 / 图找点

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
