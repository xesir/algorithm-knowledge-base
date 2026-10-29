---
id: graph-congruence-shortest-path
title: '同余最短路'
category: '图论'
subcategory: '最短路'
tags: ['同余最短路', '最短路', '同余', '最短路径树']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 25. 同余最短路

同余最短路是一个使用图论方法解决数论问题的 trick。

## 25.1 适用范围

当题目中存在类似 $f(i+x)=f(i)+x$ 的转移关系时，可以考虑利用同余的性质建立图论模型，在上面跑最短路求解。

常见的同余最短路的模型有：

1. 给出 $n$ 个数 $a_i$，求有多少个 $b \in [0,T]$ 且满足 $\sum_{i=1}^n a_ix_i=b$ 有非负整数解。
2. 体积模 $m$ 意义下的完全背包问题。

由于这个说法过于抽象，因此下面给出一些例题，请读者结合例题学习。另外，这里不讲转圈 trick。

## 25.2 例题

### P3403 跳楼机

就是求 $k \in [0,h)$ 时有多少个 $k$ 满足不定方程 $ax+by+cz=k$。

观察到，若 $k$ 合法，则 $k+ap < h$ 也合法。证明：$k+ap=a(x+p)+by+cz$。

注意到 $k \equiv k+ap \pmod a$，则对于合法的 $k$，满足 $k \equiv k' \pmod a$ 的所有 $k' < h$ 合法，数目为 $\lfloor \dfrac{h-k}{a} \rfloor+1$。

设 $d_i$ 表示模 $a$ 余 $i$ 的 $k$ 中的最小值，只要求出 $d_0 \sim d_{a-1}$。到这里用数论方法就做不下去了。

考虑一个数 $k$，且 $r=k \bmod a$。

- $k \gets k+a$，$r$ 不变。
- $k \gets k+b$，$r \gets (r+b) \bmod a$。
- $k \gets k+c$，$r \gets (r+c) \bmod a$。

显然第一条转移对于 $d_i$ 无影响。考虑剩下两条转移，可以写成这个形式：

$$
d_r \to d_{(r+b) \bmod a}\\
d_r \to d_{(r+c) \bmod a}\\
$$

将 $d$ 作为单源最短路的距离数组，将 $d_i$ 视为一个点，进行图论建模：

- $d_0=0$。
- $d_{1},d_{2},\cdots,d_{a-1}=+\infty$。
- $x \to (x+b) \bmod a$，边权为 $b$。
- $x \gets (x+c) \bmod c$，边权为 $c$。

由 $0$ 开始跑最短路，即可得到所有的 $d$。

到这里我们可以解释同余最短路名字的来源：一个点代表一个同余类，通过同余关系建边求得某种最小值，进而计算答案。

需要注意，由于同余最短路中是根据同余关系建边，无法使得 SPFA 达到最坏复杂度 $O(nm)$，因此可以在同余最短路中使用 SPFA 求最短路。下面给出一个省略 SPFA 板子的代码。

```cpp
#define int long long
const int N = 1e5 + 5;
int h, s[3], a, b, c;

void _main() {
	cin >> h >> s[0] >> s[1] >> s[2];
	sort(s, s + 3), a = s[0], b = s[1], c = s[2], h--;
	for (int i = 0; i < a; i++) {
		add_edge(i, (i + c) % a, c);
		add_edge(i, (i + b) % a, b);
	}
	SPFA::spfa(0);
	int res = 0;
	for (int i = 0; i < a; i++) {
		if (h >= SPFA::dis[i]) res += (h - SPFA::dis[i]) / a + 1;
	}
	cout << res;
}
```

### P2371 [国家集训队] 墨墨的等式

注意到这是上一题的 $n$ 元版本，并且对于 $b$ 有约束 $b \in [l,r]$。利用 $[l,r]=[1,r]-[1,l-1]$ 就能去掉这个限制。

先对 $a$ 排序，以 $a_1$ 为模数建立同余关系：

- $x \to (x+a_i) \bmod a_1$。其中 $i \in [2,n], x \in [0,a)$，边权为 $a_i$。

跑 SPFA 即可。注意特判 $a_i=0$，并且开大空间。

这里需要注意一个点：模数应该选的尽量小。在同余最短路的题目中，边数常常为 $O(nM)$ 级别，其中 $M$ 是模数。这里我们就取 $M=\min a_i$ 最好。

```cpp
#define int long long
const int N = 6e6 + 5;

int m, n, l, r, x, a[N];
long long query(long long x) {
	long long res = 0;
	for (int i = 0; i < a[1]; i++) {
		if (x >= SPFA::dis[i]) res += (x - SPFA::dis[i]) / a[1] + 1;
	} return res;
}

void _main() {
	cin >> m >> l >> r;
	for (int i = 1; i <= m; i++) {
		cin >> x;
		if (x != 0) a[++n] = x;
	}
	sort(a + 1, a + n + 1);
	for (int x = 0; x < a[1]; x++) {
		for (int i = 2; i <= n; i++) add_edge(x, (x + a[i]) % a[1], a[i]);
	}
	SPFA::spfa(0);
	cout << query(r) - query(l - 1);
}
```

### [模拟赛] 星际保安

> 给你一个由四个节点组成的环，求从节点 $2$ 出发，回到节点 $2$ 的不小于 $k$ 的最短路。
>
> $k \le 10^{18}$，环的边权 $\le 3 \times 10^4$。

赛时整了一个假的裴蜀定理解七元不定方程做法水过去了，喜提全场唯一 AK。赛后被 hack 了。

设从 $2$ 到 $2$ 的最短路为 $d$，$2$ 号节点连接的两条边的较小边权为 $w=\min(d_{1,2},d_{2,3})$，则可以进行 $x$ 次往返使得 $d+2wx \ge k$。其他往返方案也类似，这样就是一个不定方程问题。

以 $2w$ 为模数尝试同余最短路。设 $f_{x,i}$ 表示最短路模 $2w$ 的余数为 $x$，到达 $i$ 点的最短路，可以在 Dijkstra 中直接处理。此时点数为 $8w$，复杂度为 $O(w \log w)$，可以通过。最后的答案就是 $f_{x,2}$ 取合法最小值即可。

赛后改题代码。

```cpp
#define int long long
const int N = 60005;
int m, k, d[10], dis[5][N];

int tot = 0, head[N];
struct Edge {
	int next, to, dis;
} edge[N << 1];
inline void add_edge(int u, int v, int w) {
	edge[++tot].next = head[u];
	edge[tot].to = v, edge[tot].dis = w;
	head[u] = tot;
}

struct node {
	int to, dis;
	node(int x = 0, int y = 0) : to(x), dis(y) {}
	bool operator< (const node& other) const {return dis > other.dis;}
};
priority_queue<node> q;
inline void dijkstra() {
	memset(dis, 0x3f, sizeof(dis));
	dis[2][0] = 0, q.emplace(2, 0);
	while (!q.empty()) {
		int u = q.top().to, d = q.top().dis; q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to, w = edge[j].dis, c = dis[u][d % m] + w;
			if (dis[v][c % m] > c) dis[v][c % m] = c, q.emplace(v, c);
		}
	}
}

void _main() {
	cin >> k >> d[1] >> d[2] >> d[3] >> d[4];
	add_edge(1, 2, d[1]), add_edge(2, 1, d[1]);
	add_edge(2, 3, d[2]), add_edge(3, 2, d[2]);
	add_edge(3, 4, d[3]), add_edge(4, 3, d[3]);
	add_edge(4, 1, d[4]), add_edge(1, 4, d[4]);
	m = min(d[1], d[2]) * 2;
	memset(dis, 0x3f, sizeof(dis));
	dijkstra();
	int res = LLONG_MAX;
	for (int i = 0; i < m; i++) {
		if (dis[2][i] >= k) res = min(res, dis[2][i]);
		else {
			int x = k - dis[2][i], t = x / m * m + m * (x % m != 0);
			res = min(res, t + dis[2][i]);
		}
	} cout << res;
}
```

### P2662 [WC2002] 牛场围栏

还是不定方程问题。

设可以使用的木料长度的集合为 $S$，则 $S=\{l_i-j \mid i \in [1,n], j\in [0,\min(l_i,m)] \}$，记 $\min S=p$。

观察到，$p=1$ 时不存在最大值。设 $d_i$ 表示满足 $k \equiv i \pmod p$ 的最小的 $k$。

建图：对于 $u \in [a_i-m,a_i], v \in [0,p)$，建一条 $v \to (v+u) \pmod p$ 且边权为 $u$ 的边即可。用同余最短路求出 $d_i$，答案为 $\max(d_i-m)$。如果图不连通必然无解。

实现时，并不需要求出 $S$，只要对 $a$ 排序并取 $p=\max(1,a_1-m)$ 即可。

```cpp
#define int long long
const int N = 1e6 + 5;
int n, m, p, a[N];
void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	sort(a + 1, a + n + 1);
	int p = max<int>(1, a[1] - m);
	if (p == 1) return cout << -1, void();
	for (int i = 1; i <= n; i++) {
		for (int j = max(a[i - 1] + 1, a[i] - m); j <= a[i]; j++) {
			if (j == p) continue;
			for (int k = 0; k < p; k++) add_edge(k, (k + j) % p, j);
		}
	} SPFA::spfa(0);
	int res = 0;
	for (int i = 0; i < p; i++) {
		if (SPFA::dis[i] >= 0x3f3f3f3f3f3f3f3f) return cout << -1, void();
		res = max(res, SPFA::dis[i] - p);
	} cout << res;
}
```

### AT_arc084_b [ABC077D] Small Multiple

这题做法比较多，同余最短路是经典解法。

注意到，任何一个正整数都可以由 $1$ 开始，按顺序执行若干次 $\times 10, +1$ 的操作得到，且 $+1$ 的次数就是数位和。

建立图论模型：

- $k \to 10k \bmod n$，边权为 $0$。
- $k \to (k+1) \bmod n$，边权为 $1$。

从 $1$ 走到 $0$ 的最短路即为答案。注意到连续走 $10$ 条 $+1$ 其实是不合法的，但是这个题里答案一定不优。使用 01-BFS 可得到 $O(n)$ 复杂度。

### *P9140 [THUPC 2023 初赛] 背包

同余最短路的第二类例题。

由于 $V$ 很大，$v_i$ 很小，大部分背包体积都消耗在了性价比最高的物品上。将物品按性价比排序，我们只要求出余量即可。

一个贪心的想法是，先用 $\lfloor \dfrac{V}{v_1} \rfloor$ 个 $k_1$ 填满大部分，剩下的 $V \bmod v_1$ 的体积再找其他物品填充。但事实上我们可以舍弃一些 $1$ 号物品使得代价更小。

通过这个讨论，实际上问题已经转化为体积模 $v_1$ 意义下的完全背包。记 $d_i$ 表示模 $v_1$ 余 $i$ 的最优解，建立图论模型：

- $i \to (i+v_j) \bmod v_1$，边权为 $c_j-c_1\lfloor \dfrac{i+v_j}{v_1} \rfloor$。

用 SPFA 跑出**最长路**即可，答案即为 $\lfloor \dfrac{V}{v_1} \rfloor c_1 +d_{V \bmod v_1}$。

```cpp
#define int long long
const int N = 5e6 + 5;
int n, q, x;
struct node {
	int v, c;
} a[N];

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i].v >> a[i].c;
	sort(a + 1, a + n + 1, [](const node& a, const node& b) -> bool {
		return a.c * b.v > b.c * a.v;
	});
	int m = a[1].v;
	for (int i = 0; i <= m; i++) {
		for (int j = 1; j <= n; j++) add_edge(i, (i + a[j].v) % m, a[j].c - (i + a[j].v) / m * a[1].c);
	} SPFA::spfa(0);
	while (q--) {
		cin >> x;
		if (SPFA::dis[x % m] < -1e17) {cout << -1 << '\n'; continue;}
		cout << x / m * a[1].c + SPFA::dis[x % m] << '\n';
	}
}
```
