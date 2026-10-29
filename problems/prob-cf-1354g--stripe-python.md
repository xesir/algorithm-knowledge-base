---
id: prob-cf-1354g
title: 'Find a Gift'
oj: 'Codeforces'
problemId: 'CF1354G'
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

暂无（原题：[CF1354G](https://www.luogu.com.cn/problem/CF1354G)）。

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
> 现有 $n$ 个盒子，恰有 $k$ 个盒子中有礼物，其余盒子中只有石头。石头的重量相同，且严格大于所有类型的礼物。
>
> 你可以给出两个不交的下标集合 $S,T$，交互库比较 $S$ 中盒子的总重量和 $T$ 中盒子的总重量并返回。
>
> 找到标号最小的礼物盒。
>
> 多测，$\sum n \le 10^3$，$1 \le k \le \textcolor{red}{\frac{n}{2}}$，满分询问次数 $50$，交互库非自适应。

:::::success[题解]

注意到 $2k \le n$ 且交互库非自适应，这意味着，我们随机一个位置，有 $\frac{1}{2}$ 的概率得到石头。

考虑随 $T$ 个位置两两比较，取重量最大的位置作为石头盒 $p$，错误率 $2^{-T}$。

这样，我们将某个位置与 $p$ 进行比较，就能判定这个位置是否是礼物。特判位置 $1$ 是礼物后，考虑如下倍增：

![](https://cdn.luogu.com.cn/upload/image_hosting/ok7v7w95.png)

在第 $k$ 轮倍增时，我们已经认定前 $2^{k-1}$ 个盒子都是石头。如图对将 $[1,2^{k-1}]$ 与 $(2^{k-1},2^{k}]$ 进行比较，若二者不等，则石头必定在 $(2^{k-1},2^k]$ 中，否则继续倍增。询问次数 $\log n$。

找到石头所在的区间 $[l,r]$ 后，考虑二分答案 $m$，只要判定 $[l,m]$ 中是否有石头。这是简单的，我们取前 $m-l+1$ 个盒子与 $[l,m]$ 进行比较即可，正确性由倍增保证。

综上，总询问次数 $2\log n+T$，实现取 $T=25$ 稳定通过。

:::::

:::::info[代码]

```cpp line-numbers
int n, k;

int ask(vector<int> a, vector<int> b) {
    set<int> s(a.begin(), a.end()), c;
    for (int i : b) if (s.count(i)) c.emplace(i); 
    vector<int> x, y;
    for (int i : a) if (!c.count(i)) x.emplace_back(i);
    for (int i : b) if (!c.count(i)) y.emplace_back(i);
    if (x.empty()) return y.empty() ? 0 : -1;
    if (y.empty()) return 1; 
    cout << "? " << x.size() << ' ' << y.size() << '\n';
    for (int i : x) cout << i << ' ';
    cout << '\n'; for (int i : y) cout << i << ' ';
    cout << endl;
    string r; cin >> r;
    return r == "FIRST" ? 1 : r == "SECOND" ? -1 : 0;
}

void _main() {
    cin >> n >> k;
    int p = rand32() % n + 1;
    for (int T = 25; T--; ) {
        int q = rand32() % n + 1;
        if (ask({p}, {q}) == -1) p = q;
    }
    if (p != 1 && ask({1}, {p}) == -1) 
        return cout << "! " << 1 << endl, void(); 
    auto check = [&](int l, int r) -> bool {
        vector<int> x, y;
        for (int i = 1; i <= r - l + 1; i++) x.emplace_back(i);
        for (int i = l; i <= r; i++) y.emplace_back(i);
        return ask(x, y) == 0;
    };
    int l = 2, len = 1, r = -1;
    while (r <= n) {
        r = l + len - 1;
        if (r > n) {r = n; break;}
        if (!check(l, r)) break;
        l = r + 1, len *= 2;
    }
    int lo = l, hi = r, res = -1;
    while (lo <= hi) {
        int mid = (lo + hi) >> 1;
        if (check(lo, mid)) lo = mid + 1;
        else hi = mid - 1, res = mid;
    }
    cout << "! " << res << endl;
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
