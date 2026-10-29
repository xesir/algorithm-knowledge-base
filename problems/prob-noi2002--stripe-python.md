---
id: prob-noi2002
title: 'P4362 [] 贪吃的九头龙'
oj: '来源未考证'
problemId: 'NOI2002'
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

暂无（原题：[NOI2002](https://www.luogu.com.cn/problem/P4362)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵节点数为 $n$ 的有根树，根节点为 $1$，边带权。你需要将这棵树 $m$ 染色，满足与根节点同色的节点数恰为 $k$。代价为两端点颜色相同的边的边权和，最小化代价并输出，或报告无解。
>
> $m,k \le n \le 300$，1 秒，125 MB。

:::::success[题解]
不妨设根节点的颜色为 $1$。我们钦定 $k$ 个节点的颜色为 $1$，则剩余点形成一个森林，需要 $m-1$ 染色。

- 当 $m>2$ 时，容易构造所有边端点颜色不同的情况，比如按深度对 $m-1$ 取模染色。
- 当 $m=2$ 时，森林中所有边都有贡献。

据此设计树形 DP：$f_{0/1,u,i}$ 表示考虑 $u$ 的子树，$u$ 节点染色是否染成 $1$，子树内选择 $i$ 个染成 $1$ 的最小代价。枚举儿子 $v$ 并合并 DP 数组，转移是 $(\min,+)$ 卷积：

$$
f_{0/1,u,i+j} \gets f_{0/1,u,i}+f_{0/1,v,j}+w
$$

其中 $w$ 为转移时 $u \to v$ 的边是否产生贡献，容易根据 $m$ 是否等于 $2$ 以及 $0/1$ 维的取值计算。

注意合并 DP 时需要新建数组，不然会覆盖原本的取值。无解容易判断。

正确的实现为树形背包复杂度，复杂度 $O(n^2)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 305, inf = 0x3f3f3f3f;
int n, m, k;
vector<pair<int, int>> e[N];

int sz[N], f[2][N][N];
void dfs(int u, int fa) {
    f[0][u][0] = 0, f[1][u][1] = 0, sz[u] = 1;
    for (auto [v, w] : e[u]) {
        if (v == fa) continue;
        dfs(v, u);
        vector<int> f0(N, inf), f1(N, inf);
        for (int i = min(sz[u], k); i >= 0; i--) {
            for (int j = min(sz[v], k - i); j >= 0; j--) {
                chkmin(f0[i + j], f[0][u][i] + f[0][v][j] + (m == 2) * w);
                chkmin(f0[i + j], f[0][u][i] + f[1][v][j]);
                chkmin(f1[i + j], f[1][u][i] + f[0][v][j]);
                chkmin(f1[i + j], f[1][u][i] + f[1][v][j] + w);
            }
        }
        sz[u] += sz[v];
        copy(f0.begin(), f0.end(), f[0][u]), copy(f1.begin(), f1.end(), f[1][u]);
    }
}

void _main() {
    cin >> n >> m >> k;
    if (n - k < m - 1) return cout << -1, void();
    for (int i = 1, u, v, w; i < n; i++) {
        cin >> u >> v >> w;
        e[u].emplace_back(v, w), e[v].emplace_back(u, w);
    } 
    memset(f, 0x3f, sizeof(f)), dfs(1, -1);
    cout << f[1][1][k];
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
