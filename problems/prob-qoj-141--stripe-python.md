---
id: prob-qoj-141
title: '8 染色'
oj: 'QOJ'
problemId: 'QOJ141'
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

暂无（原题：[QOJ141](http://qoj.ac/problem/141/statement/default)）。

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
> - A：已知一个 $n$ 个点 $m$ 条边的无向图 $G$，并且得知 $G$ 的一个 $8$ 染色方案。可以传输一个 01 串 $S$。
> - B：已知 $n$ 个点 $m$ 条边的无向图 $G$，并且收到 $S$。要求构造一个 $8$ 染色方案。
>
> $n \le 2 \times 10^5$，$m \le 5 \times 10^5$，满分要求 $|S| \le 2.5 \times 10^5$，时限 0.45s，空限 20MB。

:::::success[题解]

A 和 B 先不断删去度数 $<8$ 的点，得到新图 $G'$。只要 A 给 B 提示了 $G'$ 的 $8$ 染色，B 是容易按逆拓扑序贪心构造的。

记 $G'$ 的点数为 $n'$，根据握手定理 $2m=\sum d_u \ge 8n'$，得 $n' \le \frac{m}{4}$。

如果每个颜色占 3bit，总的 bit 数就是 $\frac{3}{4} m =3.75 \times 10^5$，只能获得 41.3pts。

我们注意到 $2$ 染色是容易的。考虑将 $8$ 种颜色两两分组，然后传递 $4$ 个组的标号。bit 数为 $\frac{1}{2}m$ 符合要求。

可以证明，每一组在 $G'$ 中的导出子图都是二分图，因此可以黑白染色，于是 B 就得到了 $G'$ 的 $8$ 染色。

注意精细实现，否则会被卡常卡空间。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 2e5 + 5;
static int n, m, deg[N];
static bitset<N> del;
static vector<int> e[N];

vector<int> Alice(int N, int M, vector<int> U, vector<int> V, vector<int> C) {
	n = N, m = M;
    for (int i = 0; i < m; i++) {
        int u = U[i] + 1, v = V[i] + 1;
        e[u].emplace_back(v), e[v].emplace_back(u);
        deg[u]++, deg[v]++;
    }
    queue<int> q;
    for (int i = 1; i <= n; i++) if (deg[i] < 8) q.emplace(i), del[i] = true;
	while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) 
            if (--deg[v] < 8 && !del[v]) q.emplace(v), del[v] = true;
    }
    vector<int> vec;
    for (int i = 1; i <= n; i++) if (!del[i]) 
		vec.emplace_back(C[i - 1] >> 2 & 1), vec.emplace_back(C[i - 1] >> 1 & 1);
    return vec;
}
```

B：

```cpp line-numbers
const int N = 2e5 + 5;
static int n, m, deg[N];
static bitset<N> del;
static i16 typ[N], col[N];
static vector<int> e[N];

void dfs(int u, int t) {
    for (int v : e[u]) {
        if (col[v] != -1 || typ[v] != t) continue;
        col[v] = col[u] ^ 1, dfs(v, t);
    }
}

vector<int> Bob(int N, int M, vector<int> U, vector<int> V, vector<int> X) {
    n = N, m = M;
    for (int i = 0; i < m; i++) {
        int u = U[i] + 1, v = V[i] + 1;
        e[u].emplace_back(v), e[v].emplace_back(u);
        deg[u]++, deg[v]++;
    }
	stack<int> st; queue<int> q;
    for (int i = 1; i <= n; i++) if (deg[i] < 8) 
		q.emplace(i), del[i] = true, st.emplace(i);
	while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) 
            if (--deg[v] < 8 && !del[v]) 
				q.emplace(v), del[v] = true, st.emplace(v);
    }
	fill(col + 1, col + n + 1, -1), fill(typ + 1, typ + n + 1, -1);
    for (int i = 1, p = 0; i <= n; i++) {
        if (del[i]) continue;
		typ[i] = X[p] * 4 + X[p + 1] * 2, p += 2;
    }
    for (int c : {0, 2, 4, 6}) {
        for (int i = 1; i <= n; i++) 
			if (col[i] == -1 && typ[i] == c) col[i] = 0, dfs(i, c);
        for (int i = 1; i <= n; i++) 
			if (typ[i] == c) col[i] += c;
    }
	while (!st.empty()) {
		int u = st.top(); st.pop();
		int mask = (1 << 8) - 1;
		for (int v : e[u]) 
			if (col[v] != -1) mask &= ~(1 << col[v]);
		col[u] = ctz(mask);
	}
    return vector<int>(col + 1, col + n + 1);
}
```

:::::

### 【未完成】[CF1442F Differentiating Games](https://www.luogu.com.cn/problem/CF1442F)

## 博弈型

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
