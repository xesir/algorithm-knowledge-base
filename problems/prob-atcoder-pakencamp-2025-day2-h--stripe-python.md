---
id: prob-atcoder-pakencamp-2025-day2-h
title: 'Sunk Islands'
oj: 'AtCoder'
problemId: 'PAKENCAMP_2025_DAY2_H'
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

暂无（原题：[PAKENCAMP_2025_DAY2_H](https://www.luogu.com.cn/problem/AT_pakencamp_2025_day2_h)）。

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
> 交互库隐藏了一棵 $n$ 个点的无根树。你可以给出点集 $S$，询问 $S$ 的导出子图的直径点数。
>
> 还原树的形态。
>
> $n=256$，满分询问次数 $4600$。交互库非自适应。
>
> Bonus：询问次数 $3000$。

:::::success[题解]

取树上独立集 $S$，询问 $S \cup \{x\}$ 可以确定 $x$ 在树上的相对位置：

- 答案为 $1$，则 $x$ 与 $S$ 中任意点无边。
- 答案为 $2$，则 $S$ 中存在唯一点与 $x$ 有边。
- 答案为 $3$，则 $S$ 中存在两个点与 $x$ 有边。

考虑增量法。我们维护前缀森林，并确定新点 $x$ 的位置。

对森林黑白染色，取所有黑点和所有白点作为独立集。对独立集 $S$，若 $x $ 与 $S$ 中的点有连边，则将 $S$ 从中点处划分为两个不交子集 $S_1,S_2$ 递归下去。

考虑一条边会在 $\log n$ 次询问中产生贡献，均摊下来询问次数 $n \log n$。将加点顺序和 $S$ 的顺序随机打乱，实现后的询问次数约为 $3500$。

注意到 $S \cup \{x\}$ 的答案为 $2$ 时，$S_1$ 和 $S_2$ 有且仅有一个子集需要递归。我们先递归一侧，若 $S_1 \{x\}$ 的答案不为 $1$ 就没有必要询问 $S_2 \cup \{x\}$ 了。添加剪枝后询问次数约为 $2900$，可以通过。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 300;
int ask(vector<int> a) {
    cout << "? " << a.size() << ' ';
    for (int i : a) cout << i << ' ';
    cout << endl;
    int x; cin >> x;
    return x;
}
void answer(vector<int> u, vector<int> v) {
    cout << "! ";
    for (int i = 0; i < (int)u.size(); i++) cout << u[i] << ' ' << v[i] << ' ';
    cout << endl;
} 

vector<int> e[N];
int col[N];
void dfs(int u, int fa) {
    for (int v : e[u]) {
        if (v == fa) continue;
        col[v] = col[u] ^ 1, dfs(v, u);
    }
}

bool work(vector<int> a, int x) {
    if (a.empty()) return false;
    vector<int> b = a; b.emplace_back(x);
    int val = ask(b);
    if (val == 1) return false;
    if (a.size() == 1) {
        int y = a[0];
        e[x].emplace_back(y), e[y].emplace_back(x);
        return true;
    }
    shuffle(a.begin(), a.end(), rand32);
    int mid = a.size() / 2;
    vector<int> l(a.begin(), a.begin() + mid), r(a.begin() + mid, a.end());
    bool f1 = work(l, x);
    if (val == 2 && f1) return true;
    return work(r, x) | f1;
}

void _main() {
    int N, L; cin >> N >> L;
    vector<int> v;
    for (int i = 1; i <= N; i++) v.emplace_back(i);
    shuffle(v.begin(), v.end(), rand32);
    for (int i = 1; i < N; i++) {
        fill(col + 1, col + N + 1, -1);
        for (int j = 0; j < i; j++) if (col[v[j]] == -1)
            col[v[j]] = 0, dfs(v[j], -1);
        vector<int> a, b;
        for (int j = 0; j < i; j++) {
            if (col[v[j]] == 0) a.emplace_back(v[j]);
            else b.emplace_back(v[j]);
        }
        work(a, v[i]), work(b, v[i]);
    }
    vector<int> p, q;
    for (int u = 1; u <= N; u++)
        for (int v : e[u]) 
            if (u < v) p.emplace_back(u), q.emplace_back(v);
    answer(p, q);
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
