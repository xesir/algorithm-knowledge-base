---
id: prob-qoj-11116
title: 'Yearning for Yonder'
oj: 'QOJ'
problemId: 'QOJ11116'
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

暂无（原题：[QOJ11116](https://qoj.ac/problem/11116)）。

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
> 交互库隐藏了一棵大小为 $n$ 的带权树，树的形态从 Prufer 序列随机，边权从 $[1,k]$ 随机，$k$ 隐藏且保证 $k \le 10^4$。可以向交互库询问树上两点距离。
>
> 还原这棵树。
>
> $n \le 10^5$，满分询问次数 $7n$，交互库非自适应。

:::::success[题解]
首先我们可以用 $2n$ 次询问找到原树的直径，并且根据距离判断出每个点是在直径上，还是在子树中。

可以将这些点划分到直径下挂的子树中，分治求解。

由于树从 Prufer 序列随机，直径上点数的期望为 $O(\sqrt{n})$，由递归式 $T(n)=\sqrt{n} \times T(\sqrt{n})+O(n)$ 得 $T(n)=O(n \log \log n)$。

由于我们知道了直径端点到子树中每个点的距离，询问次数可以变成 $n$ 次，可以通过本题。

这里有一点细节，我们详细说明一下怎么算出距离。设分治的根节点为 $r$，当前子树中距 $r$ 最远的点为 $u$，$v$ 是我们枚举到的节点。

此时，路径 $r \to u$ 是一条主链。对于点 $v$，它到主链上会有一个投影点，记为 $w$，那么我们需要求 $d(r,w)$。列出方程：

- $d(r,w)+d(v,w)=d(r,v)$；
- $d(r,w)+d(u,w)=d(u,v)$；
- $d(r,w)+d(u,w)=d(r,u)$。

解得 $d(r,w)=\frac{d(r,v)+d(r,u)-d(u,v)}{2}$。根据这个值可以就判断 $v$ 点所属的子树了。
::::: 

:::::info[代码]

```cpp line-numbers
const int N = 1e5 + 5;
int ask(int u, int v) {
    if (u == v) return 0;
    cout << "? " << u << ' ' << v << endl;
    int x; cin >> x;
    return x;
}
int n;
vector<tuple<int, int, int>> e;

using node = pair<int, int>;
void solve(int rt, vector<node>& s) {
    if (s.empty()) return;
    sort(s.begin(), s.end());
    auto [d, u] = s.back();
    vector<int> t(s.size());
    for (int i = 0; i < (int)s.size(); i++) t[i] = ask(u, s[i].second);
    map<int, int> path;
    map<int, vector<node>> sub;
    path[0] = rt;
    for (int i = 0; i < (int)s.size(); i++) {
        auto [d1, v] = s[i];
        int x = (d1 + d - t[i]) / 2;
        if (x == d1) path[d1] = v;
        else sub[x].emplace_back(d1 - x, v);
    }
    int cur = rt, pre = 0;
    for (auto& [d1, v] : path) {
        if (d1 == 0) continue;
        e.emplace_back(cur, v, d1 - pre);
        cur = v, pre = d1;
    }
    for (auto& [x, vec] : sub) solve(path[x], vec);
}

void _main() {
    cin >> n, e.clear();
    vector<node> s0;
    for (int i = 2; i <= n; i++) s0.emplace_back(ask(1, i), i);
    solve(1, s0);
    cout << "! ";
    for (auto& [u, v, w] : e) cout << u << ' ' << v << ' ' << w << ' ';
    cout << endl;
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
