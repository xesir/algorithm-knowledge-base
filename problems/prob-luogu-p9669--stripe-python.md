---
id: prob-luogu-p9669
title: '[ICPC 2022 Jinan R] DFS Order 2'
oj: '洛谷'
problemId: 'P9669'
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

暂无（原题：[P9669](https://www.luogu.com.cn/problem/P9669)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵节点数为 $n$ 的有根树，根节点为 $1$。对于每个 $x=1,2,\cdots,n$ 和 $p=1,2,\cdots,n$ 求出：在所有 DFS 序中，$x$ 位于 DFS 序第 $p$ 位的方案数。对 $998244353$ 取模。
>
> $n \le 500$，1.5 秒，512 MB。

:::::success[题解]
根据 DFS 的规则，访问 $x$ 之前必然访问了 $x$ 的所有祖先和排在 $x$ 之前的兄弟子树。

注意到总的 DFS 序数目为 $\prod\limits_{u=1}^n |\operatorname{son}(u)|!$，其中 $\operatorname{son}(u)$ 是 $u$ 的儿子集合。因此考虑计数转概率，计算 $x$ 位于 DFS 序第 $p$ 位的**概率**。

对于祖先节点 $u$，我们希望走向其儿子 $v$，并通向 $x$ 的方向。记 $m=|\operatorname{son}(u)|$，则我们选出 $i$ 个放在 $v$ 前面，剩下 $m-i-1$ 个放在后面。选出这种方案的概率系数为 $\frac{i!(m-i-1)!}{m!}$。

我们需要知道子树大小总和为 $k$ 的情况数。记 $f_{u,i,j}$ 为在 $u$ 的 $m$ 个儿子中选出 $i$ 个儿子且子树大小之和恰为 $j$ 的方案数。依次考虑儿子 $v$ 然后用 01 背包合并：$f_{u,i,j} \gets f_{v,i-1,j-sz_v}$。

分析向 $v$ 的路径时，我们不能算入 $v$ 自身的方案。因此使用**退背包**，算出不含 $v$ 的背包数组 $g_{u,i,j}$，复杂度 $O(n^3)$。

得到以上信息后，将 $g$ 与对应概率相乘并求和，得到总概率，答案容易计算。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 505;
int n, sz[N], dep[N];
vector<int> e[N];
mint fac[N], ifac[N], h[N][N], ans[N][N];

void dfs1(int u, int fa) {
    sz[u] = 1;
    for (int v : e[u]) {
        if (v == fa) continue;
        dep[v] = dep[u] + 1, dfs1(v, u), sz[u] += sz[v];
    }
}
void dfs2(int u, int fa) {
    if (e[u].size() == 1 && e[u][0] == fa) return;
    int m = u == 1 ? e[u].size() : e[u].size() - 1;
    vector<vector<mint>> f(m + 5, vector<mint>(sz[u] + 5));
    f[0][0] = 1;
    int sum = 0;
    for (int v : e[u]) {
        if (v == fa) continue;
        sum += sz[v];
        for (int i = m; i >= 1; i--) {
            for (int j = sum; j >= sz[v]; j--) f[i][j] += f[i - 1][j - sz[v]];
        }
    }
    for (int v : e[u]) {
        if (v == fa) continue;
        auto g = f;
        for (int i = 1; i <= m; i++) {
            for (int j = sz[v]; j <= sum; j++) g[i][j] -= g[i - 1][j - sz[v]];
        }
        vector<mint> p(sum + 5);
        for (int j = 0; j <= sum - sz[v]; j++) {
            for (int i = 0; i < m; i++) p[j] += g[i][j] * fac[i] * fac[m - i - 1] * ifac[m];
        }
        for (int i = 0; i <= n; i++) {
            for (int j = 0; j <= sum - sz[v] && i + j <= n; j++) h[v][i + j] += h[u][i] * p[j];
        }
        dfs2(v, u);
    }
}

void _main() {
    fac[0] = ifac[0] = 1;
    for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
    cin >> n;
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    h[1][0] = 1, dfs1(1, -1), dfs2(1, -1);
    mint t = fac[e[1].size()];
    for (int i = 2; i <= n; i++) t *= fac[e[i].size() - 1];
    for (int u = 1; u <= n; u++) {
        for (int i = 0; i <= n; i++) {
            int pos = 1 + dep[u] + i;
            if (pos <= n) ans[u][pos] += h[u][i] * t; 
        }
    }
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) cout << ans[i][j] << ' ';
        cout << '\n';
    }
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
