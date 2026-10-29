---
id: graph-cyclic-tree
title: '基环树'
category: '图论'
subcategory: '树论基础'
tags: ["基环树","环","树","图论"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 介绍

基环树，一般有 $n$ 个点 $n$ 条边的无向连通图，比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/bnwp8b9x.png)

环用红色标出，可以看到基环树就是一个环上挂了若干子树。特别地，基环树也可以退化为一个单环。

解决基环树的问题有两种思路：

1. 对环上每棵子树先处理，再处理环，最后合并答案；
2. 将基环树拆成树 + 一条边，即断环为链。

因此，基环树问题需要树上问题和环上问题的良好基础。

## 例题

## P8655 [蓝桥杯 2017 国 B] 发现环

【模板】基环树找环。

采用缩圈算法，每次删去最外圈，比如说：

![](https://cdn.luogu.com.cn/upload/image_hosting/559rbb5o.png)

这个图里黄色是第一轮删点，绿色是第二轮，最后剩的就是环了。

考虑一下怎么代码实现。发现当前入度为 $1$ 的点就是最外圈，删掉就行，写一个拓扑排序即可。复杂度 $O(n+m)$。

```cpp
const int N = 1e5 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, u, v, deg[N], tag[N];
queue<int> q;
void bfs() {
	for (int i = 1; i <= n; i++) {
		if (deg[i] == 1) q.emplace(i), tag[i] = true;
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			if (--deg[v] == 1) q.emplace(v), tag[v] = true;
		}
	}
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
		deg[u]++, deg[v]++;
	}
	bfs();
	for (int i = 1; i <= n; i++) if (!tag[i]) cout << i << ' ';
}
```

## P5022 [NOIP 2018 提高组] 旅行

抽象题。先考虑树怎么做，由于要求字典序最小，于是在 DFS 时按儿子编号从小到大走就行了。

对于基环树来说，把环找见以后采用处理方法 2，也就是枚举删去一条边，然后套用树的做法。复杂度 $O(n^2)$ 卡一卡能过，就做完了。

```cpp
const int N = 5005;
int tot = 1, head[N];  // 这里tot=1，则j和j^1互为反边
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, m, u, v, deg[N], tag[N];
queue<int> q;
void bfs() {
	for (int i = 1; i <= n; i++) {
		if (deg[i] == 1) q.emplace(i), tag[i] = true;
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			if (--deg[v] == 1) q.emplace(v), tag[v] = true;
		}
	}
}

void dfs(int u, int fa) {
	cout << u << ' ';
	vector<int> son;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		son.emplace_back(v);
	}
	sort(son.begin(), son.end());
	for (int v : son) dfs(v, u);
}

int e;  // 删掉的边
int cnt, cur[N], ans[N];
void dfs2(int u, int fa) {
	cur[++cnt] = u;
	vector<int> son;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa || j == e || j == (e ^ 1)) continue;
		son.emplace_back(v);
	}
	sort(son.begin(), son.end());
	for (int v : son) dfs2(v, u);
}
void update() {
	for (int i = 1; i <= n; i++) {
		if (cur[i] > ans[i]) return;
		if (cur[i] < ans[i]) break;
	}
	memcpy(ans, cur, sizeof(cur));
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
		deg[u]++, deg[v]++;
	}
	if (m == n - 1) return dfs(1, -1), void();
	bfs();
	unordered_set<int> ring;  // 存环上的点
	for (int i = 1; i <= n; i++) {
		if (!tag[i]) ring.emplace(i);
	}
	fill(ans + 1, ans + n + 1, 0x3f3f3f3f);
	unordered_set<long long> vis;  // 防止重复删边
	for (int u : ring) {
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			if (vis.count(1LL * u * INT_MAX + v) || vis.count(1LL * v * INT_MAX + u)) continue;
			vis.emplace(1LL * u * INT_MAX + v);
			if (!ring.count(v)) continue;
			cnt = 0, e = j, fill(cur + 1, cur + n + 1, 0x3f3f3f3f);
			dfs2(1, -1), update();
		}
	}
	for (int i = 1; i <= n; i++) cout << ans[i] << ' ';
}
```

## P1453 城市环路

这题要是在树上很好做，用 $dp_{0/1,u}$ 表示以 $u$ 为根的子树或不选的贡献，然后对于儿子 $v$，若 $u$ 选 $v$ 一定不能选，否则可选可不选。转移：

$$
dp_{0,u}=\sum _{v \in son(u)} \max(dp_{0,v},dp_{1,v})\\
dp_{1,u}=p_u+\sum _{v \in son(u)} dp_{0,v}
$$

如果只有这样这题只有黄，但是它上了基环树。

那就断环为链，找环上两点 $x,y$，各以 $x,y$ 为根跑一次 dp，然后答案在 $dp_{0,x},dp_{0,y}$ 中取最大值。

分析一下正确性：不妨设答案就是 $dp_{0,x}$，则 $x$ 不选，而 $y$ 可选可不选，与题目相符。因为这题的限制只针对相邻两点而不像上一题针对整个路径，所以也不用全部枚举一遍，仅删一条即可。

这题找环就不要用缩圈了，只需要求任意一组 $x,y$，直接维护个并查集即可。

```cpp
const int N = 1e5 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, u, v, p[N];
double k;

int fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}

int dp[2][N];
void dfs(int u, int fa) {
	dp[1][u] = p[u];
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		dp[0][u] += max(dp[0][v], dp[1][v]), dp[1][u] += dp[0][v];
	}
}

void _main() {
	cin >> n;
	iota(fa, fa + n + 1, 0);
	for (int i = 1; i <= n; i++) cin >> p[i];
	int x = -1, y = -1;
	for (int i = 1; i <= n; i++) {
		cin >> u >> v; u++, v++;
		int fu = find(u), fv = find(v);
		if (fu == fv) x = u, y = v;  // 删去这条边
		else fa[fu] = fv, add_edge(u, v), add_edge(v, u);
	} cin >> k;
	dfs(x, -1);
	int res = dp[0][x];
	memset(dp, 0, sizeof(dp)), dfs(y, -1);
	cout << fixed << setprecision(1) << k * max(res, dp[0][y]);
}
```

## P4381 [IOI 2008] Island

题目翻译：求一个基环树森林中每课基环树的直径（即最长链）长度之和。

基环树的直径有两种可能：

1. 位于挂在环上的一棵子树中；
2. 穿过环，位于挂在环上的两棵子树中。

第一种情况就是树的直径求法，再处理一下第 $x$ 棵子树中离 $x$ 最远点的距离，记作 $d_x$。

则第二种情况的答案为：

$\max (d_x+d_y+dis_{x,y})$其中 $x, y$ 为环上两点，$dis_{x,y}$ 表示这两点环上距离。对环上的边权作一个前缀和记为 $pre$，则 $dis_{x,y}=pre_x-pre_y$ 或 $tot-(pre_x-pre_y)$，其中 $tot$ 为环上边权之和。则答案为

$\max \{d_x+pre_x+d_y-pre_y, d_x-pre_x+d_y+pre_y-tot\}$由于两部分贡献独立，直接求 $\max(d_x + pre_x)$ 与 $\max(d_y - pre_y)$ 即可。最后一二种情况取最大。

细节上，注意求直径不能用 `dfs(u, fa)` 的写法，而是要记录 `vis` 数组防止在环里一直绕。

至于代码在哪，别问，问就是[没调出来](https://www.luogu.com.cn/discuss/1106524)。

## P2607 [ZJOI2008] 骑士

题意：求基环树森林中每棵基环树树上最大独立集之和。

不会树的最大独立集可以看[模板题](https://www.luogu.com.cn/problem/P1352)。考虑环上的一条边 $(u,v)$，这两个点一定不能同时取得，则用这两个点为根跑树形 dp，记为 $f_{0/1,u},g_{0/1,v}$，则贡献为 $\max(f_{0,u},g_{0,v})$，可以证明环上任意边贡献相同。
