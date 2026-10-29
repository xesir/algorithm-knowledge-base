---
id: prob-atcoder-abc355e
title: 'Guess the Sum'
oj: 'AtCoder'
problemId: 'ABC355E'
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

暂无（原题：[ABC355E](https://www.luogu.com.cn/problem/AT_abc355_e)）。

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
> 交互库隐藏了一个排列 $a_i$，长度为 $2^n$。你可以给出 $i,j$，设 $x=2^i \times j,y=2^i \times(j+1)-1$，向交互库询问 $\left(\sum \limits_{i=x}^y a_i\right) \bmod 100$。
>
> 给出 $l,r$，通过最少询问次数求出 $\left(\sum \limits_{i=l}^r a_i\right) \bmod 100$。
>
> $n \le 18$。

:::::success[题解]
这个询问形式比较奇怪，我们画一下合法区间：

![](https://cdn.luogu.com.cn/upload/image_hosting/4zudg6ym.png)

发现这是一个倒着的线段树。于是考虑把询问像线段树一样拆成 $\log 2^n$ 段，然后喜提 WA。

错误原因在于，本题询问的信息具有可减性。因此，我们采用前缀和 trick，记 $s_i$ 为 $a_i$ 的前缀和，询问即求 $s_r-s_{l-1}$。因为是 0-index，我们让 $s$ 向后移动一位，去求 $s_{r+1}-s_l$。

我们考虑如下策略：从 $l$ 开始，不断扩展当前区间直到包含 $r$，在求和时要判断当前区间是加还是减。基于此，我们可以进行图论建模，用最短路来确定策略。对于合法区间 $[l,r]$，连边 $l \leftrightarrow r+1$，则询问即 $l$ 到 $r+1$ 的最短路。

容易用一次 BFS 记录最短路径，然后从 $r+1$ 倒推回来，判一下询问端点即可确定加减。复杂度 $O(n2^n)$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e5 + 5;
int n, l, r, pre[N], vis[N];
vector<int> e[N];

void bfs(int s, int t) {
    queue<int> q;
    q.emplace(s), pre[s] = -1, vis[s] = true;
    while (!q.empty()) {
        int u = q.front(); q.pop();
        if (u == t) return;
        for (int v : e[u]) {
            if (vis[v]) continue;
            q.emplace(v), pre[v] = u, vis[v] = true;
        }
    }
} 

void _main() {
    cin >> n >> l >> r;
    for (int i = 0; i <= n; i++) {
        for (int j = 0; j < (1 << (n - i)); j++) {
            int x = j * (1 << i), y = (j + 1) * (1 << i) - 1;
            e[y + 1].emplace_back(x), e[x].emplace_back(y + 1);
        }
    }
    r++, bfs(l, r);
    mint res = 0;
    for (int i = r, j = -1; i != -1; j = i, i = pre[i]) {
        if (j == -1) continue;
        int x = min(i, j), y = max(i, j), k = lg(y - x);
        cout << "? " << k << ' ' << (x >> k ) << endl;
        mint v; cin >> v;
        if (i < j) res += v;
        else res -= v;
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
