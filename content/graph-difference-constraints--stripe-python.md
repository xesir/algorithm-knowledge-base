---
id: graph-difference-constraints
title: '差分约束复习笔记'
category: '图论'
subcategory: '图论建模'
tags: ["差分约束","最短路","负环","SPFA"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 前言

1 个月前打 abc404，G 题一眼差分约束 debug 1h，吃了 5 发罚时，喜提 0pts。故写一篇复习笔记。

## 模型

见 [模板题](https://www.luogu.com.cn/problem/P5960) 中所描述的形式。

## 原理

对于一个约束 $x_i-x_j \le c$，移项可得 $x_i \le x_j+c$，这类似于最短路中的三角不等式 $dis_i \le dis_j+c$，如果把 $x_i,x_j$ 作为图中节点，且存在一条从 $x_j$ 到 $x_i$ 的边权为 $c$ 的有向边，则跑最短路即可得 $x$ 的一组解。

实现上，图不一定连通，一种方法是 bellman-ford，不过要骗分的情况下，还是应当设置一个超级原点，跑 spfa。这个 spfa 可以各种玄学优化。而且更多时候需要建个反边跑最长路。

我们也可以转化约束条件：

- $x_i-x_j \ge c$，不等式两边同乘 $-1$ 转化为 $x_j-x_i\le -c$；
- $x_i-x_j=c$，拆成约束 $x_i-x_j \le c$ 和 $x_i-x_j \ge c$；
- $x_i=c$，令 $x_0=0$，则 $x_i-x_0=c$。

## 板子

```cpp
template <class T, int N>
class SDC {
private:
	int tot = 0, head[N];
	struct Edge {
		int next, to; T dis;
	} edge[N * 3];
	inline void add_edge(int u, int v, const T& w) {
		edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
	}
	queue<int> q;
	T dis[N]; int cnt[N]; bool vis[N];
public:
	void clear() {
		tot = 0, memset(head, 0, sizeof(head)), memset(edge, 0, sizeof(edge));
		while (!q.empty()) q.pop();
		memset(cnt, 0, sizeof(cnt)), memset(vis, 0, sizeof(vis));
		fill(dis, dis + N, -numeric_limits<T>::max() / 2);
	}
	SDC() {clear();}
	T operator[](int idx) const {return dis[idx];}

	void add_le(int a, int b, const T& c) {add_edge(a, b, -c);}  // x[a] - x[b] <= c
	void add_ge(int a, int b, const T& c) {add_edge(b, a, c);}  // x[a] - x[b] >= c
	void add_eq(int a, int b, const T& c) {add_le(a, b, c), add_ge(a, b, c);}  // x[a] - x[b] == c
	void add_eq(int a, int b) {add_edge(a, b, 0), add_edge(b, a, 0);}  // x[a] == x[b]

	bool solve(int n) {
		for (int i = 0; i <= n; i++) add_edge(n + 1, i, 0);
		dis[n + 1] = 0, vis[n + 1] = true, cnt[n + 1] = 1, q.emplace(n + 1);
		while (!q.empty()) {
			int u = q.front(); q.pop(), vis[u] = false;
			if (++cnt[u] > n + 1) return false;
			for (int j = head[u]; j != 0; j = edge[j].next) {
				int v = edge[j].to; T w = edge[j].dis;
				if (dis[v] < dis[u] + w) {
					dis[v] = dis[u] + w;
					if (!vis[v]) q.emplace(v), vis[v] = true;
				}
			}
		}
		return true;
	}
};
```

根据本人卡题的经验，使用 SLF+LLL 优化的 SPFA 在差分约束题的平均表现最好。这里给出优化代码。

```cpp
template <class T, int N>
class SDC {
private:
	int tot = 0, head[N];
	struct Edge {
		int next, to; T dis;
	} edge[N * 3];
	inline void add_edge(int u, int v, const T& w) {
		edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
	}
	deque<int> q;
	T dis[N]; int cnt[N]; bool vis[N];
public:
	void clear() {
		q.clear();
		tot = 0, memset(head, 0, sizeof(head)), memset(edge, 0, sizeof(edge));
		memset(cnt, 0, sizeof(cnt)), memset(vis, 0, sizeof(vis));
		fill(dis, dis + N, -numeric_limits<T>::max() / 2);
	}
	SDC() {clear();}
	T operator[](int idx) const {return dis[idx];}

	void add_le(int a, int b, const T& c) {add_edge(a, b, -c);}  // x[a] - x[b] <= c
	void add_ge(int a, int b, const T& c) {add_edge(b, a, c);}  // x[a] - x[b] >= c
	void add_eq(int a, int b, const T& c) {add_le(a, b, c), add_ge(a, b, c);}  // x[a] - x[b] == c
	void add_eq(int a, int b) {add_edge(a, b, 0), add_edge(b, a, 0);}  // x[a] == x[b]

	bool solve(int n) {
		for (int i = 0; i <= n; i++) add_edge(n + 1, i, 0);
		dis[n + 1] = 0, vis[n + 1] = true, cnt[n + 1] = 1, q.emplace_back(n + 1);
		long long num = 1, sum = 0;
		while (!q.empty()) {
			int u = q.front();
			while (num * dis[u] < sum) q.pop_front(), q.emplace_back(u), u = q.front();
			q.pop_front(), vis[u] = 0, num--, sum -= dis[u];
			if (++cnt[u] > n + 1) return false;
			for (int j = head[u]; j != 0; j = edge[j].next) {
				int v = edge[j].to; T w = edge[j].dis;
				if (dis[v] < dis[u] + w) {
					dis[v] = dis[u] + w;
					if (vis[v]) continue;
					vis[v] = 1, num++, sum += dis[v];
					if (!q.empty() && dis[v] > dis[q.front()]) q.emplace_front(v);
					else q.emplace_back(v);
				}
			}
		}
		return true;
	}
};
```

## 例题

找题可以[点这个](https://www.luogu.com.cn/problem/list?tag=185&keyword=%E5%B7%AE%E5%88%86%E7%BA%A6%E6%9D%9F&type=AT%7CB%7CCF%7CP%7CSP%7CUVA&page=1)。

## P5960 【模板】差分约束

板子题没什么好说的。

```cpp
SDC<int, N> sdc;
int n, m, x, y, c;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> x >> y >> c;
		sdc.add_le(x, y, c);
	}
	if (!sdc.solve(n)) return cout << "NO", void();
	for (int i = 1; i <= n; i++) cout << sdc[i] << ' ';
}
```

## P1993 小 K 的农场

差分约束转化模板。打板子即可。

```cpp
SDC<int, N> sdc;
int n, m, opt, x, y, c;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> opt >> x >> y;
		if (opt == 1) cin >> c, sdc.add_ge(x, y, c);
		if (opt == 2) cin >> c, sdc.add_le(x, y, c);
		if (opt == 3) sdc.add_eq(x, y);
	}
	cout << (sdc.solve(n) ? "Yes" : "No");
}
```

## P2294 [HNOI2005] 狡猾的商人

对 $a$ 作一个前缀和，则每条约束变为 $pre_{t}-pre_{s-1}=v$，然后上板子即可。

```cpp
SDC<int, N> sdc;
int n, m, x, y, c;

void _main() {
	cin >> n >> m;
	sdc.clear();   // 多测清空
	for (int i = 1; i <= m; i++) {
		cin >> x >> y >> c;
		sdc.add_eq(y, x - 1, c);
	}
	cout << boolalpha << sdc.solve(n) << '\n';
}
```

## AT_abc404_g [ABC404G] Specified Range Sums

和上一题基本一样，先作前缀和，由于要求是正整数，应该有约束 $pre_i-pre_{i-1} \ge 1$，最后的总和为 $pre_n$。

```cpp
SDC<long long, N> sdc;
int n, m, x, y, c;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> x >> y >> c;
		sdc.add_eq(y, x - 1, c);
	}
	for (int i = 1; i <= n; i++) sdc.add_ge(i, i - 1, 1);
	if (!sdc.solve(n)) return cout << -1, void();
	cout << sdc[n];
}
```

## P4926 [1007] 倍杀测量者

题意：给出 $s$ 个形如

$x_a \ge (k-T) x_b$或者

$(k+T)x_a  > x_b$的不等式以及 $t$ 个 $x_i$ 的值。求最大的 $T$ 使不等式组无解。

注意到 $T$ 有单调性，进行实数二分。然后我们发现这题最大的不同在于加减变成了乘除，取一个 $\log$ 即可转化为加减形式。具体地：

$$
x_a \ge (k-T) x_b \rightarrow x_a-x_b \ge \ln(k-T)\\
(k+T)x_a  > x_b \rightarrow x_a-x_b \ge -\ln(k+T)\\
x_i = c \rightarrow x_i-x_0=\ln(c)
$$

接下来就是板子了。

```cpp
const double eps = 1e-6;
int n, s, t, c;
double b[N], x;
struct node {
	int opt, a, b;
	double k;
} a[N];

inline bool check(double x) {
	SDC<double, N> sdc;
	for (int i = 1; i <= s; i++) {
		if (a[i].opt == 1) sdc.add_ge(a[i].a, a[i].b, log(a[i].k - x));
		else sdc.add_ge(a[i].a, a[i].b, -log(a[i].k + x));
	}
	for (int i = 1; i <= n; i++) {
		if (b[i]) sdc.add_eq(i, 0, log(b[i]));
	}
	return !sdc.solve(n);
}

void _main() {
	double l = 0.0, r = 1e18, res = -1;
	cin >> n >> s >> t;
	for (int i = 1; i <= s; i++) {
		cin >> a[i].opt >> a[i].a >> a[i].b >> a[i].k;
		if (a[i].opt == 1) r = min<double>(r, a[i].k);
	}
	for (int i = 1; i <= t; i++) cin >> c >> x, b[c] = x;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid + eps, res = mid;
		else r = mid - eps;
	}
	if (res == -1) cout << -1;
	else cout << fixed << setprecision(12) << res;
}
```

## P3275 [SCOI2011] 糖果

**本题 SPFA 差分约束并非正解。**

我们用 $x,y$ 表示第 $A,B$ 个小朋友分到的糖果。

1. $x=y$，直接建约束；
2. $x<y$，转化为 $y - x \ge 1$；
3. $x\ge y$，转化为 $x-y \ge 0$；
4. $x>y$，转化为 $x-y \ge 1$；
5. $x \le y$，转化为 $y - x \ge 0$。

同时 $x$ 都是正整数，则 $x-x_0 \ge 1$，其中 $x_0=0$。

```cpp
SDC<int, N> sdc;
int n, m, opt, x, y;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> opt >> x >> y;
		if (opt == 1) sdc.add_eq(x, y);
		else if (opt == 2) sdc.add_ge(y, x, 1);
		else if (opt == 3) sdc.add_ge(x, y, 0);
		else if (opt == 4) sdc.add_ge(x, y, 1);
		else if (opt == 5) sdc.add_ge(y, x, 0);
	}
	for (int i = 1; i <= n; i++) sdc.add_ge(i, 0, 1);
	if (!sdc.solve(n)) return cout << -1, void();
	long long res = 0;
	for (int i = 1; i <= n; i++) res += sdc[i];
	cout << res;
}
```

SLF+LLL 只有 90pts，正解为 tarjan 缩点 + DAG 上 dp。[双倍经验](https://www.luogu.com.cn/problem/P10935)。

## SP116 INTERVAL - Intervals

这题需要建模了。还是前缀和思想，用 $x_i$ 表示区间 $[0,i]$ 最少选几个数，则对于每条约束，有 $d_{b}-d_a \ge c$。而且每个数要么选，要么不选，这说明 $x_i$ 的差分数组中的元素 $\in \{0,1\}$，即约束 $x_i-x_{i-1} \ge 0$ 和 $x_{i-1}-x_i \ge -1$，然后差分约束即可。细节上，由于本题是 0-index 的，要把下标加一处理。

```cpp
int n, l, r, c;
SDC<int, N> sdc;

void _main(int t) {
	cin >> n; int m = -1;
	sdc.clear();
	for (int i = 1; i <= n; i++) {
		cin >> l >> r >> c, m = max(m, r);
		sdc.add_ge(r + 1, l, c);
	}
	for (int i = 1; i <= m + 1; i++) sdc.add_ge(i, i - 1, 0), sdc.add_ge(i - 1, i, -1);
	sdc.solve(m + 1);
	cout << sdc[m + 1];
	if (t) cout << '\n';
}
```

另外本题有[多倍经验](https://www.luogu.com.cn/discuss/984130)。

## P11453 [USACO24DEC] Deforestation S

和上一题一样建模，用 $pre_i$ 表示选 / 不选的前缀和，有 $pre_r - pre_{l-1} \ge t$，并且 $0 \le pre_i - pre_{i-1} \le 1$。注意下标离散化处理。跑完最长路 $n-pre_n$ 即为答案。

```cpp
SDC<int, N> sdc;
int n, k, d[N], x[N], l, r, c;

void _main() {
	sdc.clear(), memset(d, 0, sizeof(d));
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> x[i], d[i] = x[i];
	sort(d + 1, d + n + 1);
	int m = unique(d + 1, d + n + 1) - d - 1;
	for (int i = 1; i <= n; i++) x[i] = lower_bound(d + 1, d + m + 1, x[i]) - d;
	for (int i = 1; i <= k; i++) {
		cin >> l >> r >> c;
		l = lower_bound(d + 1, d + m + 1, l) - d, r = upper_bound(d + 1, d + m + 1, r) - d - 1;
		sdc.add_ge(r, l - 1, c);
	}
	for (int i = 1; i <= n; i++) sdc.add_ge(i, i - 1, 0), sdc.add_ge(i - 1, i, -1);
	sdc.solve(n);
	cout << n - sdc[n] << '\n';
}
```

## P11232 [CSP-S 2024] 超速检测

这题细节多的一批。样例给了提示每辆车有且仅有一段超速区间，那考虑把这段区间处理出来，分类讨论：

- 若 $a=0$：
  - 若 $v>V$，该车一直超速，超速区间 $[d,L]$；
  - 若 $v \le V$，该车不超速。

- 若 $a > 0$：
  - 若 $v>V$，该车一直超速，超速区间 $[d,L]$；
  - 若该车在 $L$ 处速度 $v' \le V$，该车不超速；
  - 否则，超速区间 $[d + \lfloor \dfrac{V^2-v^2}{2a} \rfloor,L]$。

- 若 $a<0$：
  - 若 $v \le V$，该车不超速。
  - 若该车在 $L$ 处速度 $v' > V$，该车一直超速，超速区间 $[d,L]$；
  - 否则，超速区间 $[d,\min(L,d + \dfrac{V^2-v^2}{2a}))$，可以化作 $[d,\min(L,d + \lceil \dfrac{V^2-v^2}{2a}+d \rceil)]$。

将坐标离散化，第一问跑前缀和即可，第二问与上题相同。但是本题卡 spfa，只有 80pts。第二问正解是贪心。

```cpp
SDC<int, N> sdc;
int n, m, l0, v0, p[N], d[N], pre[N];
struct car {
	int d, v, a, l, r;
	int get(int s) {return v * v + 2 * a * s;}
	void calc() {
		// 分类讨论超速区间起止点
		d++;
		if (a == 0) {  // 匀速
			if (v > v0) l = d, r = l0;
			else l = r = -1;
		} else if (a > 0) {   // 匀加速
			if (v > v0) l = d, r = l0;
			else if (get(l0 - d) <= v0 * v0) l = r = -1;
			else l = d + (v0 * v0 - v * v) / (2 * a) + 1, r = l0;
		} else {   // 匀减速
			if (v <= v0) l = r = -1;
			else if (get(l0 - d) > v0 * v0) l = d, r = l0;
			else l = d, r = min<int>(l0, ceil(d + 1.0 * (v0 * v0 - v * v) / (2 * a) - 1));
		}
	}
} a[N];

void _main() {
	read(n, m, l0, v0); l0++;
	for (int i = 1; i <= n; i++) read(a[i].d, a[i].v, a[i].a), a[i].calc();
	for (int i = 1; i <= m; i++) read(p[i]), d[i] = ++p[i];
	sort(d + 1, d + m + 1);
	int tot = unique(d + 1, d + m + 1) - d - 1;
	for (int i = 1; i <= m; i++) p[i] = lower_bound(d + 1, d + tot + 1, p[i]) - d;

	for (int i = 1; i <= m; i++) pre[p[i]]++;
	for (int i = 1; i <= m; i++) pre[i] += pre[i - 1];
	int cnt = 0;
	for (int i = 1; i <= n; i++) {
		if (a[i].l == -1) continue;
		a[i].l = lower_bound(d + 1, d + tot + 1, a[i].l) - d;
		a[i].r = upper_bound(d + 1, d + tot + 1, a[i].r) - d - 1;
		if (pre[a[i].r] - pre[a[i].l - 1]) cnt++, sdc.add_ge(a[i].r, a[i].l - 1, 1);
	}
	for (int i = 1; i <= m; i++) sdc.add_ge(i, i - 1, 0), sdc.add_ge(i - 1, i, -1);
	sdc.solve(m);
	cout << cnt << ' ' << m - sdc[m] << '\n';

	sdc.clear(), memset(a, 0, sizeof(a)), memset(d, 0, sizeof(d)), memset(p, 0, sizeof(p));
}
```

## P12088 [RMI 2019] 还原 / Restore Arrays

套路类似，对 01 串作前缀和，记作 $pre_i$。则对于每条约束：

- 若 $val=0$，第 $k$ 小元素是 $0$，即至少前 $k$ 小都是 $0$，所以 $pre_{r}-pre_{l-1}\le r-l+1-k$。
- 若 $val=1$，第 $k$ 小元素是 $1$，即至多多 $k-1$ 小都是 $0$，所以 $pre_{r}-pre_{l-1}\ge r-l+1-(k-1)$。

别忘了下标加一和 $0 \le pre_{i}-pre_{i-1} \le 1$。本题卡常，需要用 SLF+LLL 优化的版本。

```cpp
SDC<int, N> sdc;
int n, m, l, r, k, v;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> l >> r >> k >> v; l++, r++;
		if (v == 0) sdc.add_le(r, l - 1, r - l + 1 - k);
		else sdc.add_ge(r, l - 1, r - l + 1 - (k - 1));
	}
	for (int i = 1; i <= n; i++) sdc.add_ge(i, i - 1, 0), sdc.add_ge(i - 1, i, -1);
	if (!sdc.solve(n)) return cout << -1, void();
	for (int i = 1; i <= n; i++) cout << (sdc[i] > sdc[i - 1]) << ' ';
}
```

## P10941 Cashier Employment

经典前缀和起手，用 $a_i$ 表示第 $i$ 小时开始工作人数，其前缀和记作 $s_i$。

但是我们发现有些约束带三个变量，比如一个人从 20 点开始工作，那就是

$a_{20}+a_{21}+a_{22}+a_{23}+a_0+a_1+a_2+a_3 \ge R(3)$转化为前缀和

$s_{23}-s_{19}+s_3 \ge R(3)$不过写出几个这类约束容易发现带的第三个变量都是 $s_{23}$，再加上本题数据很小，直接枚举 $s_{23}$ 的值即可。这个值也就是答案了。当然可以二分优化枚举。这实际上是断环为链的思想。

细节上注意下标 +1，以及 $s_i-s_{i-1} \ge 0$。

```cpp
int n, x, r[N], cnt[N];

inline bool check(int x) {
	SDC<int, 100> sdc;
	sdc.add_ge(24, 0, x);
	for (int i = 1; i <= 24; i++) {
		sdc.add_ge(i, i - 1, 0), sdc.add_le(i, i - 1, cnt[i]);
		if (i > 8) sdc.add_ge(i, i - 8, r[i]);
		else sdc.add_le(i + 16, i, x - r[i]);
	}
	return sdc.solve(24) && sdc[24] == x;
}

void _main() {
	for (int i = 1; i <= 24; i++) cin >> r[i];
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> x, cnt[x + 1]++;
	for (int i = 0; i <= n; i++) {
		if (check(i)) return cout << i << '\n', void();
	}
	cout << "No Solution\n";
}
```

## P5590 赛车游戏

令 $d_i$ 表示从 $1$ 到 $i$ 的简单路径长度。则对于边 $(u,v,w)$，有 $d_v-d_u=w$，且 $w \in [1,9]$，故 $1 \le d_v-d_u \le 9$。而且每个 $d_i$ 只有一个值，就保证了路径长度相等。

建约束的时候跑 dfs，把在 $1$ 到 $n$ 路径上的边建进来，不在的边随便赋值。

```cpp
SDC<int, N> sdc;
int n, m, u, v;
int tot = 0, head[N];
struct Edge {
	int next, from, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].from = u, edge[tot].to = v, head[u] = tot;
}

bool vis[N];
bool dfs(int u) {
	if (u == n) return true;
	bool can = false;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (vis[v]) continue;
		vis[v] = true;
		if (dfs(v)) {
			can = true;
			sdc.add_ge(v, u, 1), sdc.add_le(v, u, 9);
		}
		vis[v] = false;
	}
	return can;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		add_edge(u, v);
	}
	if (!dfs(1)) return cout << -1, void();
	if (!sdc.solve(n)) return cout << -1, void();
	cout << n << ' ' << m << '\n';
	for (int i = 1; i <= m; i++) {
		int u = edge[i].from, v = edge[i].to;
		cout << u << ' ' << v << ' ';
		int d = sdc[v] - sdc[u];
		if (1 <= d && d <= 9) cout << d << '\n';
		else cout << 1 << '\n';
	}
}
```

喜提 60pts。时间瓶颈在 dfs，显然有解的图无环（若有环，多走一圈边权就变了），于是在 dfs 中记忆化一下即可 AC。

```cpp
bool vis[N], can[N];
bool dfs(int u) {
	if (u == n) return can[u] = true;
	bool res = false;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (vis[v]) continue;
		vis[v] = true;
		if (can[v] || dfs(v)) {
			res = true;
			sdc.add_ge(v, u, 1), sdc.add_le(v, u, 9);
		}
		vis[v] = false;
	}
	return can[u] = res;
}
```

## P12348 [蓝桥杯 2025 省 A 第二场] 交互

题里给的约束长的就很像标准形式。考虑一下有什么性质。既然 $\min_{l\le x\le r} a_x-\max_{p \le y \le q} a_y \ge ans$，那么对于一个更大的 $a_x$ 和一个更小的 $a_y$，显然 $a_x-a_y \ge ans$。所以一个自然的想法是直接枚举区间中的点一一连边。可以获得 [90pts](https://www.luogu.com.cn/record/219627043) 的高分。

这样的边数有 $O(nk^2)$ 条，其中 $n\le500, k\le100$。我们借鉴一下线段树优化建图中区间往区间连边的思想，建立一个虚点，用 $[l,r]$ 往虚点连边，在从虚点往 $[p,q]$ 连边，边数就被压缩到了 $O(nk)$ 级别。

用不等式解释的话，设虚点为 $h$，则对于约束 $\min_{l\le x\le r} a_x-\max_{p \le y \le q} a_y \ge ans$，则拆成 $a_h-\min_{l\le x\le r} a_x \ge ans$ 和 $\max_{p \le y \le q} a_y-a_h \ge 0$，容易证明这两种约束是等价的。

最后本题即使虚点建边，最坏复杂度也有 $O(nmk)$，只能用 SLF+LLL 优化的版本才能过。

```cpp
SDC<int, N> sdc;
int n, m, l1, r1, l2, r2, x;

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		cin >> l1 >> r1 >> l2 >> r2 >> x;
		for (int j = l1; j <= r1; j++) sdc.add_ge(m + i, j, x);
		for (int j = l2; j <= r2; j++) sdc.add_ge(j, m + i, 0);
	}
	if (!sdc.solve(m + n)) return cout << "No Solution", void();
	int mx = sdc[1], mn = sdc[1];
	for (int i = 1; i <= m + n; i++) mx = max(mx, sdc[i]), mn = min(mn, sdc[i]);
	cout << mx - mn;
}
```

## UVA11671 矩阵中的符号 Sign of Matrix

设 $x_i$ 表示第 $i$ 列的增加次数，$y_i$ 表示第 $j$ 列的增加次数，我们发现每个元素的值为 $x_i+y_i$，考虑把 $y_i$ 取相反数，于是对于每个约束：

- `+`：$x_i-y_i \ge 1$；
- `-`：$x_i-y_i \le -1$；
- `=`：$x_i=y_i$。

令 $x_{i+n}=y_i$，先跑差分约束求出一组 $x_i$ 和 $y_i$ 的解。显然将它们同减一个常数仍是一组解。此时要求最小值，则问题转化为：

给定一组数 $x_i$，求出一个数 $c$ 使得 $\sum |x_i-c|$ 最小。

我们把这 $2n$ 个点放到数轴上并两两配对，如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/t6grrbrd.png)

设所求点为 $P$。当 $P$ 位于 $B$ 左侧时，$P$ 向右运动 $d$ 个单位，到 $B, C, D$ 的距离都会减小，到 $a$ 的距离增加，总和减少 $2d$。$P$ 位于 $C$ 右侧同理。而 $P$ 位于 $B, C$ 之间时，$P$ 向右运动 $d$ 个单位，到 $A, B$ 的距离增加 $d$，而到 $C, D$ 的距离减少 $d$，总和不变且保持最小。由此可得，$P$ 在线段 $BC$ 上（包括端点）时最小。

于是有结论：$c$ 是 $x_i$ 的中位数。当然具体到本题，取 $c=x_n$ 即可。

```cpp
SDC<int, N> sdc;
int n, a[N]; char opt;

void _main(int kase) {
	cin >> n;
	if (n == -1) exit(0);
	cout << "Case " << kase << ": ";
	sdc.clear();
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			cin >> opt;
			if (opt == '+') sdc.add_le(i, j + n, -1);
			else if (opt == '-') sdc.add_ge(i, j + n, 1);
			else if (opt == '0') sdc.add_eq(i, j + n);
		}
	}
	if (!sdc.solve(n << 1)) return cout << "-1\n", void();
	for (int i = 1; i <= (n << 1); i++) a[i] = sdc[i];
	sort(a + 1, a + (n << 1) + 1);
	int res = 0;
	for (int i = 1; i <= (n << 1); i++) res += abs(a[n] - a[i]);
	cout << res << '\n';
}
```

## AT_agc056_c [AGC056C] 01 Balanced

前缀和起手，则 $pre_r-pre_{l-1}=\dfrac{r-l+1}{2}$ 且 $0 \le pre_i-pre_{i-1} \le 1$。但 $n \le 10^6$，直接上 spfa 板子会喜提 TLE。

换个转化，令 $x_i$ 表示 $[1,i]$ 中 $0$ 的个数减去 $1$ 的个数，最小化字典序等价于令 $0$ 尽量多，也就是让 $x_i$ 最小，即 $x$ 字典序最大。

> 如果这里令 $x_i$ 表示 $[1,i]$ 中 $1$ 的个数减去 $0$ 的个数，就变成 $x_i$ 最大，后期最长路不好做。

对于每条约束，有 $x_r=x_{l-1}$。同时 $|x_i-x_{i-1}| = 1$。拆成 $x_i-x_{i-1} \le 1$ 和 $x_{i-1}-x_i \le 1$。此时边权只有 $0$ 和 $1$，双端队列 01-BFS 即可。复杂度 $O(m+n)$。

$x$ 的字典序最大是由差分约束的性质决定的，而观察一下连边有 $(l-1,r,0)$ 和 $(i,i-1,1)$，则对于 $(u,v,w)$ 有 $w=(u-v) \bmod 2$，那就不会出现 $s_i=s_{i-1}$ 的情况了，所以拆分是合理的。

```cpp
int n, m, l, r;
int dis[N];
deque<int> q;
void bfs(int s) {
	memset(dis, 0x3f, sizeof(dis));
	q.emplace_front(s), dis[s] = 0;
	while (!q.empty()) {
		int u = q.front(); q.pop_front();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to, w = edge[j].dis;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				(w == 0) ? q.emplace_front(v) : q.emplace_back(v);
			}
		}
	}
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> l >> r;
		add_edge(l - 1, r, 0), add_edge(r, l - 1, 0);
	}
	for (int i = 1; i <= n; i++) add_edge(i, i - 1, 1), add_edge(i - 1, i, 1);
	bfs(0);
	for (int i = 1; i <= n; i++) cout << (dis[i] < dis[i - 1]);
}
```
