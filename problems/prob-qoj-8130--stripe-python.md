---
id: prob-qoj-8130
title: 'Yet Another Balanced Coloring Problem'
oj: 'QOJ'
problemId: 'QOJ8130'
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

暂无（原题：[QOJ8130](https://qoj.ac/problem/8130)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出两棵大小为 $n,m$ 的有根树，根节点分别为 $n$ 和 $m$。保证两棵树的叶子节点均为 $1,2,\cdots,k$。构造一种对叶子的黑白染色方案，使得对于每棵树，每个子树中黑点与白点的数目相差不超过 $1$。输出方案或报告无解。
>
> 多测，$\sum (n+m) \le 2 \times 10^5$，1 秒，256 MB。

:::::success[题解]
先考虑一棵树的情形。

叶向树问题，自底向上贪心。对于当前子树中未处理的叶子，我们在新图 $G$ 中将两个叶子连一条边，钦定其颜色不同。对 $G$ 做黑白染色就得到了构造，容易证明合法且有解。

两棵树的情形，考虑套用上面的做法。正确性仍然显然。

并且可以说明，这样做一定有解。注意到每个点的度数 $\le 2$，则 $G$ 中链的情况是平凡的。而 DFS 过程相当于将两个匹配合并，有环也必为偶环。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 1e5 + 5;
int n, m;
vector<int> e1[N], e2[N], e[N];

int dfs1(int u, vector<int>* et) {
    if (et[u].empty()) return u;
    vector<int> vec;
    for (int v : et[u]) {
        int x = dfs1(v, et);
        if (x != -1) vec.emplace_back(x);
    }
    while (vec.size() > 1) {
        int x = vec.back(); vec.pop_back();
        int y = vec.back(); vec.pop_back();
        e[x].emplace_back(y), e[y].emplace_back(x);
    }
    return vec.empty() ? -1 : vec[0];
}

int col[N];
void dfs2(int u) {
    for (int v : e[u]) {
        if (col[v] != -1) continue;
        col[v] = col[u] ^ 1, dfs2(v);
    }
}

void _main() {
    cin >> n >> m;
    for (int i = 1; i <= max(n, m); i++) e1[i].clear(), e2[i].clear(), e[i].clear();
    for (int v = 1, u; v < n; v++) cin >> u, e1[u].emplace_back(v);
    for (int v = 1, u; v < m; v++) cin >> u, e2[u].emplace_back(v);
    dfs1(n, e1), dfs1(m, e2);
    int k = 0;
    for (int i = 1; i <= min(n, m); i++) if (e1[i].empty()) k++;
    fill(col + 1, col + k + 1, -1);
    for (int i = 1; i <= k; i++) {
        if (col[i] != -1) continue;
        col[i] = 0, dfs2(i); 
    }
    for (int i = 1; i <= k; i++) cout << (col[i] ? 'R' : 'B');
    cout << '\n';
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
