---
id: prob-luogu-p3479
title: '[POI 2009] GAS-Fire Extinguishers'
oj: '洛谷'
problemId: 'P3479'
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

暂无（原题：[P3479](https://www.luogu.com.cn/problem/P3479)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵节点数为 $n$ 的有根叶向树，根节点为 $1$。你需要在某些节点放置任意数量的元素，每个元素可以被分配给距离 $ \le k$ 的节点，且最多分配给 $s$ 个不同节点。要求每个节点至少被分配到一个元素。最小化放置元素的总数目并输出。
>
> $n \le 10^5$，$k \le 20$，1 秒，125 MB。

::::::success[题解]
叶向树上的问题，考虑自底向上贪心。

我们声称，元素应当尽量放置在深度较小的节点上。对于节点 $x$，若其子树中仍存在距离 $=k$ 的点 $u$ 未分配，则必须在 $x$ 处放置元素并分配给 $u$。

可以用调整法说明上述策略的正确性。假设存在最优解，将 $x$ 替换为在其子树中的点 $v$，并将 $v$ 的元素分配给 $u$。记 $d(u,v)$ 为两点间距离，则 $d(u,v)<k$。

现在将 $v$ 上的元素移动到 $x$，我们要证明这仍是一个最优解，即说明被 $v$ 覆盖的元素可以被 $x$ 覆盖：

- 对 $u$ 点：根据定义 $d(x,u)=k$，必要性成立；
- 对 $x$ 子树外：假定 $v$ 处元素还覆盖了 $x$ 子树外的节点 $w$，则满足 $d(v,w)=d(v,x)+d(x,w) \le k$。移动到 $x$ 有 $d(x,w) \le k$，故移动不会影响 $x$ 外的节点；
- 对 $x$ 子树内：反证法，若存在 $y$ 使得其原本能被 $v$ 覆盖，但不能被 $x$ 覆盖，则其满足 $d(v,y )\le k \land d(x,y) > k$。根据定义，$d(x,u)=k$ 且 $u$ 是子树内最深的未分配节点，而这里 $y$ 比 $u$ 深，矛盾。所以不存在这样的 $y$。

说明这一做法的正确性后，考虑设计树形 DP 来执行策略。

记 $f_{i,x}$ 为在 $x$ 子树内，距离 $x$ 为 $i$ 的可分配数，$g_{i,x}$ 为子树内距离为 $i$ 的需求数目。DP 转移时，讨论在 $x$ 处新增元素，并且在 $x$ 处将余量 $f_{i,x}$ 与需要 $g_{j,x}$ 进行匹配。

一种错误的策略为：将满足 $i+j \le k$ 的所有余量—需求关系在当前 LCA 全部匹配。这种贪心会将极好的余量分配给容易满足的需求，从而导致较难满足的需求只能通过放置元素来解决。

事实上，我们只应该在如下两种情况时进行匹配：

1. 在 $i+j \in \{k-1,k\}$ 时将其匹配。因为如果再往祖先移动，就有 $i \gets i+1,j \gets j+1$，此时 $i+j>k$ 失去匹配机会；
2. 存在 $g_{k,x}>0$ 时，再向上走就无法处理这一需求，所以必须在 $x$ 处新建元素 $f_{0,x}$ 将其匹配。

正确性容易说明，考虑上述过程相当于贡献延后 DP，且所有余量—需求关系最终都会在根节点正确处理。

自底向上 DFS，对于当前节点 $x$ 有：

- 首先，将儿子的需求上传到 $x$，距离增加 $1$，并在 $x$ 处新增一个距离为 $0$ 的需求：
  - $f_{i+1,x}=\sum\limits_{v \in \operatorname{son}(u)} f_{i,v}$；
  - $g_{i+1,x}=\sum\limits_{v \in \operatorname{son}(u)} g_{i,v}$；
  - $g_{0,x}=1$。
- 接下来处理第一类匹配。倒序枚举 $i = k,k-1,\cdots,0$，并考虑 $j \in \{k-i,k-i-1\}$。匹配的数目由 $\min(g_{i,u},f_{j,u})$ 决定。
- 在处理 $i=k$ 后，进行第二类匹配。计算出放置元素的数目 $a=\lceil \frac{g_{k,u}}{s} \rceil$，然后清空 $g_{k,u} \gets 0$，并将剩余元素加入 $f_{0,u}$。

注意在根节点处，我们需要进行剩余匹配。首先将所有 $i+j \le k$ 的 $g_{i,u}$ 和 $f_{j,u}$ 匹配后，求出剩余需求数目 $a$，将 $\lceil \frac{a}{s} \rceil$ 加入答案。

按照上述过程实现，可以做到 $O(nk)$。
::::::

:::::info[代码]
```cpp line-numbers
const int N = 1e5 + 5;
int n, s, k;
vector<int> e[N];
i64 ans, f[21][N], g[21][N];
void dfs(int u, int fa) {
    for (int v : e[u]) { 
        if (v == fa) continue;
        dfs(v, u);
        for (int i = 0; i < k; i++) f[i + 1][u] += f[i][v], g[i + 1][u] += g[i][v];
    }
    g[0][u] = 1;
    for (int i = k; i >= 0; i--) {
        for (int j : {k - i, k - i - 1}) {
            if (j < 0) continue;
            i64 a = min(g[i][u], f[j][u]);
            g[i][u] -= a, f[j][u] -= a;
        }
        if (i == k && g[k][u] > 0) {
            i64 a = (g[k][u] + s - 1) / s;
            ans += a, f[0][u] += a * s - g[k][u], g[k][u] = 0;
        }
    }
}

void _main() {
    cin >> n >> s >> k;
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    dfs(1, -1);
    for (int i = k; i >= 0; i--) {
        for (int j = k - i; j >= 0; j--) {
            i64 a = min(g[i][1], f[j][1]);
            g[i][1] -= a, f[j][1] -= a;
        }
    }
    i64 rem = 0;
    for (int i = 0; i <= k; i++) rem += g[i][1];
    cout << ans + (rem + s - 1) / s;
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
