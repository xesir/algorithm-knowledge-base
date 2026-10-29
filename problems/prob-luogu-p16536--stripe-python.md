---
id: prob-luogu-p16536
title: '[THUPC 2026 决赛] 流光解密'
oj: '洛谷'
problemId: 'P16536'
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

暂无（原题：[P16536](https://www.luogu.com.cn/problem/P16536)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和一棵节点数为 $n$ 的数。交互库逐边地给出这棵树，你需要在线地将给出的边定向。
> - B：已知这棵树，还原 $k$。
>
> 交互库非自适应，即树的形态不会随交互流程改变。
>
> 多测，$T \le 10^4$，$n \le 30$，$1 \le k \le 2^{n-1}$。

:::::success[题解]

注意到 $k \le 2^{n-1}$，考虑拆二进制，即我们需要用边的方向表示 $k-1$ 的二进制位。

我们为每个点赋一个点权，节点 $i$ 的权值定义为 $k-1$ 在二进制下第 $i-2$ 位，节点 $1$ 的权值为 $0$。

对于边 $u,v$，不妨设 $u<v$，我们约定 $u \to v$ 的边权为 $0$，$v \to u$ 的边权为 $1$。

这样定向相当于给边赋权。考虑将边权设为两个节点的异或和。B 收到树后，从节点 $1$ 开始 DFS，做一遍树上前缀和即可得到 $k-1$。

:::::

:::::info[代码]

A：

```cpp line-numbers
int n, k;
void _main() {
    cin >> n >> k, k--;
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        if (u > v) swap(u, v);
        int a = k >> (u - 2) & 1, b = k >> (v - 2) & 1;
        if (a ^ b) cout << v << ' ' << u << endl;
        else cout << u << ' ' << v << endl;
    }
}
```

B：

```cpp line-numbers
const int N = 40;
int n, k;
vector<pair<int, int>> e[N];

void dfs(int u, int fa, int p) {
    if (u > 1 && p) k |= 1 << (u - 2);
    for (auto [v, w] : e[u]) 
        if (v != fa) dfs(v, u, p ^ w);
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v, u > v), e[v].emplace_back(u, u > v);
    }
    k = 0, dfs(1, -1, 0);
    cout << k + 1 << endl;
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
