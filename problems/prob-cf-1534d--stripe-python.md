---
id: prob-cf-1534d
title: 'Lost Tree'
oj: 'Codeforces'
problemId: 'CF1534D'
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

暂无（原题：[CF1534D](https://www.luogu.com.cn/problem/CF1534D)）。

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
> 交互库隐藏了一个大小为 $n$ 的树。你可以给出 $u$，向交互库询问 $u$ 到所有点的距离。
>
> 还原这棵树。
>
> $n \le 2 \times 10^3$，满分询问次数 $\lceil n/2\rceil$。

:::::success[题解]
钦定 $1$ 号点为根，则可以通过一次询问得到所有点的深度。

注意到询问次数与 $n/2$ 有关，考虑将树按照深度黑白染色。

这样一来，深度为奇 / 偶的点的数目总有一个在 $n/2$ 以内。我们将这些点全部询问一次即可得到答案。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
int n, a[N], d[N];
vector<int> e[N];
void add(int u, int v) {e[u].emplace_back(v), e[v].emplace_back(u);}
void ask(int x) {
    cout << "? " << x << endl;
    for (int i = 1; i <= n; i++) cin >> a[i];
}
void dfs(int u, int fa) {
    sort(e[u].begin(), e[u].end()), e[u].erase(unique(e[u].begin(), e[u].end()), e[u].end());
    for (int v : e[u]) {
        if (v == fa) continue;
        cout << u << ' ' << v << '\n';
        dfs(v, u);
    }
}

void _main() {
    cin >> n, ask(1);
    int cnt = 0;
    for (int i = 1; i <= n; i++) cnt += a[i] & 1;
    copy(a + 1, a + n + 1, d + 1);
    if (2 * cnt < n) {
        for (int u = 2; u <= n; u++) {
            if (!(d[u] & 1)) continue;
            ask(u);
            for (int v = 1; v <= n; v++) {
                if (a[v] == 1) add(u, v);
            }
        }
    } else {
        for (int i = 1; i <= n; i++) {
            if (d[i] == 1) add(1, i);
        }
        for (int u = 2; u <= n; u++) {
            if (d[u] & 1) continue;
            ask(u);
            for (int v = 1; v <= n; v++) {
                if (a[v] == 1) add(u, v);
            }
        }
    }
    cout << "!\n", dfs(1, -1), cout << endl;
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
