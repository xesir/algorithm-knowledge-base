---
id: math-01-fractional
title: '0/1 分数规划'
category: '数学'
subcategory: '数论计数'
tags: ['分数规划', '二分答案', '最优比率']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 21. 分数规划

分数规划一般与其他算法一起出现，比如：

- 与 01 背包结合，称为最优比率背包；
- 与最小生成树结合，称为最优比率生成树；
- 与最短路结合，称为最优密度路径；
- 与 SPFA 判负环结合，称为最优比率环；
- 与网络流结合，称为最优密度子图。

## 21.1 模型

分数规划的基本模型是：有 $n$ 个物品，每种物品有两个权值 $a,b$，选出若干个最大化或最小化 $\dfrac{\sum a} {\sum b}$。

最常见的模型里每种物品只有选与不选两种可能，因而又被称作 01-分数规划。

## 21.2 解法

最值问题且满足单调性，二分启动。以最大值为例，我们二分答案 $mid$，则

由

$\dfrac{\sum a_i} {\sum b_i} > mid$可得

$\sum a_i - mid \times \sum b_i > 0$即

$\sum (a_i-mid \times b_i) > 0$由此得到二分的判定式。在分数规划的问题中，我们需要用其他方法求出 $\sum (a_i-mid \times b_i)$ 的最值并与 $0$ 比较。

## 21.3 例题

最大密度子图板子是 [UVA1389 Hard Life](https://www.luogu.com.cn/problem/UVA1389)，但是要用到笔者不会的网络流知识，这里就不讲了。

### P10505 Dropping Test

分数规划板子。二分不变，可以贪心地去选，按 $a_i-mid \times b_i \ge 0$ 排个序选最大的 $n-k$ 个。分数规划结合贪心。

```cpp
const double eps = 1e-8;
int n, k, a[N], b[N];
double c[N];
bool check(double x) {
	for (int i = 1; i <= n; i++) c[i] = a[i] - b[i] * x;
	sort(c + 1, c + n + 1, greater<double>());
	return accumulate(c + 1, c + n - k + 1, 0.0) >= 0.0;
}

void _main() {
	cin >> n >> k;
	if (n == 0 && k == 0) exit(0);
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	double l = 0.0, r = 1.0;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << round(l * 100.0) << '\n';
}
```

### P4377 [USACO18OPEN] Talent Show G

仔细审题可以发现，这题等价于上面的模型，加入一个 $\sum b_i \ge W$ 的限制。

$\sum b_i \ge W$ 可以想到背包的容量，于是以 $b_i$ 为重量，$a_i-mid \times b_i$ 为体积跑 01 背包即可。如果不会 01 背包推荐我的[背包笔记](https://www.luogu.com.cn/article/6gosht8f)。复杂度 $O(nw \log V)$。分数规划结合 01 背包。

```cpp
const int N = 1e5 + 5;

long long n, w, a[N], b[N];
const double eps = 1e-8;

double dp[N];
inline bool check(double x) {
	for (int i = 1; i <= w; i++) dp[i] = -1e9;
	for (int i = 1; i <= n; i++) {
		for (int j = w; j >= 0; j--) {
			dp[min(w, j + b[i])] = max(dp[min(w, j + b[i])], dp[j] + a[i] - x * b[i]);
		}
	} return dp[w] > 0;
}

void _main() {
	cin >> n >> w;
	for (int i = 1; i <= n; i++) cin >> b[i] >> a[i];
	double l = 0.0, r = 1e9;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << (long long) (1000 * l + eps);
}
```

### U589727 最优比率生成树

还是二分，接下来我们以 $a_i-mid \times b_i$ 为边权跑最小生成树，判断边权和是否大于 $0$ 即可。注意本题是完全图，用 prim 跑最小生成树更优。分数规划结合最小生成树。

```cpp
const int N = 1005;
int tot = 0, head[N];
int val[N][N], cost[N][N];
double w[N][N];

int n, m, u, v, x, y;
const double eps = 1e-4;

bool vis[N];
double dis[N];
inline bool check(double x) {
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) w[i][j] = x * cost[i][j] - val[i][j];
	}
	memset(vis, 0, sizeof(vis)), fill(dis + 1, dis + n + 1, -1e9);
	dis[1] = 0;
	for (int i = 1; i < n; i++) {
		int x = 0;
		for (int j = 1; j <= n; j++) {
			if (!vis[j] && (x == 0 || dis[j] > dis[x])) x = j;
		}
		vis[x] = true;
		for (int j = 1; j <= n; j++) {
			if (!vis[j]) dis[j] = max(dis[j], w[x][j]);
		}
	}
	double res = 0;
	for (int i = 2; i <= n; i++) res += dis[i];
	return res > 0;
}

void _main() {
	cin >> n;
	m = n * (n - 1) / 2;
	double l = 0.0, r = 5e6;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> x >> y;
		val[u][v] = val[v][u] = x;
		cost[u][v] = cost[v][u] = y;
	}
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) r = mid - eps;
		else l = mid + eps;
	} cout << fixed << setprecision(2) << l;
}
```

### P3199 [HNOI2009] 最小圈

人话就是求一个环 $C$ 使得 $\dfrac{\sum_{e \in C} w_e}{|C|}$ 最小。还是二分，这题 $b_i=1$，所以以 $a_i-mid$ 为边权。因为我们只需要判最小环是否小于 $0$，所以用 SPFA 判负环即可。分数规划结合 SPFA 判负环。

```cpp
const int N = 1e4 + 5;
const double eps = 1e-10;

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
int n, m, u, v; double w;

deque<int> q;
double dis[N]; int cnt[N];
bitset<N> vis;

inline bool spfa(int s, double x) {
	for (int i = 1; i <= n; i++) dis[i] = 1e9;
	q.clear(), memset(cnt, 0, sizeof(cnt)), vis.reset();
	q.emplace_back(s), dis[s] = 0, vis[s] = 1, cnt[s] = 1;
	while (!q.empty()) {
		int u = q.front(); q.pop_front(), vis[u] = 0;
		if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (++cnt[v] >= n) return true;
				if (vis[v]) continue;
				vis[v] = 1, q.emplace_back(v);
				if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
			}
		}
	}
	return false;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> u >> v >> w, add_edge(u, v, w);
	double l = -1e7, r = 1e7;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (spfa(1, mid)) r = mid;
		else l = mid;
	} cout << fixed << setprecision(8) << l;
}
```

但是这题即使用 SLF+swap 的 SPFA 也只有 90pts，使用玄学的 DFS-SPFA 可以水过：

> 注意：DFS-SPFA 使用必须慎重，其最差复杂度为指数级。

```cpp
double dis[N];
bool vis[N];

bool dfs(int u, double x) {
	vis[u] = true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to; double w = edge[j].dis - x;
		if (dis[v] > dis[u] + w) {
			dis[v] = dis[u] + w;
			if (vis[v] || dfs(v, x)) return true;
		}
	} return vis[u] = false;
}
inline bool check(double x) {
	fill(dis + 1, dis + n + 1, 0.0), fill(vis + 1, vis + n + 1, false);
	for (int i = 1; i <= n; i++) {
		if (dfs(i, x)) return true;
	} return false;
}
```

### P1730 最小密度路径

还是分数规划的模型，二分起手，这题 $a_i=w,b_i=1$，然后以 $w-mid$ 为边权从 $u$ 到 $v$ 跑 SPFA 最短路即可。这题是最小值，所以就是判最短路小于 $0$。因为这题 $q$ 个询问只有 $O(n^2)$ 个本质不同，打个记忆化即可。分数规划结合最短路。

```cpp
const int N = 1005;
const double eps = 1e-5;
int n, m, u, v, w, q;
double ans[N][N];

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
double dis[N];
bool vis[N];
inline bool spfa(int s, int t, double x) {
	fill(dis + 1, dis + n + 1, 1e9), memset(vis, 0, sizeof(vis));
	queue<int> q;
	q.emplace(s), dis[s] = 0, vis[s] = true;
	while (!q.empty()) {
		int u = q.front(); q.pop();
		vis[u] = false;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to; double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (vis[v]) continue;
				vis[v] = true, q.emplace(v);
			}
		}
	} return dis[t] < 0;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w;
		add_edge(u, v, w);
	} cin >> q;
	while (q--) {
		cin >> u >> v;
		if (ans[u][v] != 0) {
			if (ans[u][v] == -1) cout << "OMG!\n";
			else cout << fixed << setprecision(3) << ans[u][v] << '\n';
			continue;
		}
		double l = 0.0, r = 1e5, res = -1;
		while (r - l > eps) {
			double mid = (l + r) / 2.0;
			if (spfa(u, v, mid)) r = mid, res = r;
			else l = mid;
		}
		if (res == -1) ans[u][v] = -1, cout << "OMG!\n";
		else cout << fixed << setprecision(3) << (ans[u][v] = res) << '\n';
	}
}
```
