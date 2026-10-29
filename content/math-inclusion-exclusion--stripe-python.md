---
id: math-inclusion-exclusion
title: '容斥原理（含 min-max 容斥与斯特林反演）'
category: '数学'
subcategory: '组合数学'
tags: ['容斥原理', 'min-max 容斥', '斯特林反演', '计数']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 8. 容斥原理

容斥原理是加法 & 减法原理的推广。

## 8.1 引入

用一个例题引入：假设班里有 $a$ 个学生喜欢语文，$b$ 个学生喜欢数学，$c$ 个数学喜欢英语，则班里至少喜欢一门学科的有多少个学生？

显然你不能简单地用 $a+b+c$ 计算，因为可以有学生同时喜欢两门甚至三门学科。我们使用集合论语言，设喜欢三门学科的学生集合为 $A,B,C$，则所求为 $|A \cup B \cup C|$。因为 $|A|+|B|+|C|=a+b+c$ 这样会把同时喜欢两个学科的人算重，需要减去 $|A \cap B|+|A \cap C|+ |B \cap C|$。然而这样又会把同时喜欢三个学科的人减去，所以又要加上 $|A \cap B \cap C|$。于是答案为

$|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$这就是三维容斥。

## 8.2 一般形式

更一般地，有

$|\cup_{i=1}^{n} S_i|=\sum_{m=1}^n (-1)^{m-1} \sum_{a_i<a_{i+1}} |\cap _{i=1}^m S_{a_i}|$可以用减法原理结合数学归纳法证明。

用到容斥的地方其实很多，减法原理就是最简单的容斥，高维前缀和也有容斥做法，下文所说的二项式反演、Stirling 反演本质就是有系数的容斥。

需要注意，某些计数 DP 的题也会用到容斥思想，此时我们设计两个 DP 数组 $f_i,g_i$，分别表示总方案数与合法方案数，转移形如 $g_i =\sum_{j} (f_j-h(j))$，其中 $h(j)$ 表示 $j$ 处不合法的方案数。容斥原理的本质就是像这样的多次减法原理。

## *8.3 一般化

对于两个集合函数 $f(S),g(S)$，我们有

$f(S)=\sum_{T \subseteq S} g(T) \Leftrightarrow g(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} f(T)$这个过程又叫做**子集反演**。上面给出的是子集反演的形式一，取补集可以得到子集反演形式二：

$f(S)=\sum_{S \subseteq T} g(T) \Leftrightarrow g(S)=\sum_{S \subseteq T} (-1) ^{|T|-|S|} f(T)$下文第 11 章的二项式反演，就可以看作子集反演在元素都相等时的特例。

## 8.4 例题

### CF1207D Number Of Permutations

考察好序列的性质，发现不太好计数，于是我们用容斥把它拆开，所求变为：总方案数 $-$ 第一维 $a_i$ 有序的方案数 $-$ 第二维 $b_i$ 有序的方案数 $+$ 两维 $a_i,b_i$ 同时有序的方案数。

显然总方案数是 $n!$。对于单维有序的情况，$a_i,b_i$ 同理，这里只讨论 $a_i$。先完成排序后每一块相同的数可以任意交换，于是我们开个桶来计数，由乘法原理可知答案是 $\prod_{i=1}^{n} cnt_i!$。两维同时有序，和上述类似，我们用桶 $p_{i,j}$ 记录数对 $(i,j)$ 的出现次数，所求为 $\prod_{i=1}^{n} p_{a_i,b_i}$。于是我们预处理阶乘即可。

但是要注意两维同时有序可能无解，需要排个序特判一波。

> 以及：CF 有 hack 机制能用 unordered_map 吗？

```cpp
const int N = 3e5 + 5;
using p32 = pair<int, int>;

mint fac[N];
int n, a, b;
p32 h[N];
map<int, int> cnt1, cnt2;
map<p32, int> p;

void _main() {
	cin >> n;
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	for (int i = 1; i <= n; i++) {
		cin >> a >> b, h[i] = make_pair(a, b);
		cnt1[a]++, cnt2[b]++, p[h[i]]++;
	}
	sort(h + 1, h + n + 1);
	mint c0 = fac[n], c1 = 1, c2 = 1, c12 = 1;
	for (int i = 2; i <= n; i++) {
		if (h[i].second < h[i - 1].second) c12 = 0;
	}
	for (const auto& i : cnt1) c1 *= fac[i.second];
	for (const auto& i : cnt2) c2 *= fac[i.second];
	for (const auto& i : p) c12 *= fac[i.second];
	cout << c0 - c1 - c2 + c12;
}
```

### P1447 [NOI2010] 能量采集

组合数学的原理也可以解决数论问题。在前面的欧拉函数部分，我们知道这样的问题答案是

$\sum_{i=1}^{n} \sum_{j=1}^{m} (2\times\gcd(i, j)-1)=2\sum_{i=1}^{n} \sum_{j=1}^{m} \gcd(i,j)-nm$可以发现 $\gcd(i,j)$ 的值只有 $n$ 种，不妨考虑 $gcd(i,j)=k$ 的数目，设其数目为 $f(k)$。我们可以考虑求以 $k$ 为公约数的数对数目，再减去以 $k$ 的倍数为公约数的数对数目。进一步推导，以 $k$  的倍数为公约数的数对个数等于所有以 $k$ 的倍数为最大公约数的数对个数之和。于是有

$f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor -\sum_{i=2}^{ik \le \min(n,m)} f(ik)$我们发现 $2k > \min(n,m)$ 时 $f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor$，于是倒着算就行了，是调和型枚举，复杂度 $O(n \log n)$。于是 GCD SUM 问题就多了一种容斥做法。

```cpp
const int N = 1e5 + 5;
long long f[N];
int n, m;

void _main() {
	cin >> n >> m;
	for (int k = n; k >= 1; k--) {
		f[k] = 1LL * (n / k) * (m / k);
		for (int i = 2; i * k <= min(n, m); i++) f[k] -= f[i * k];
	}
	long long res = 0;
	for (int i = 1; i <= n; i++) res += f[i] * i;
	cout << res * 2 - 1LL * n * m;
}
```

### AT_abc162_e [ABC162E] Sum of gcd of Tuples (Hard)

笔者数论训练赛の T5。和上面题的套路一样，我们发现，$\gcd a_i=k$ 时当且仅当 $a_1,a_2, \cdots,a_n$ 均为 $k$ 的倍数，且这个倍数是互质的。考虑容斥 + DP，令 $dp_x$ 表示 $[1,x]$ 内选出 $n$ 个互质数的方法数目。考虑用减法原理，总数目减去不互质的方案，枚举公约数 $i$，则根据约数性质可得

$dp_x=x^n-\sum_{i=2}^{x} dp_{\lfloor \frac{x}{i} \rfloor}$赛时写的记搜。可以发现这个东西就是高维容斥。

```cpp
int n, k;
mint dp[N];
mint solve(int x) {
	if (dp[x] != 0) return dp[x];
	if (x == 1) return dp[x] = 1;
	mint res = mint(x).pow(n);
	for (int i = 2; i <= x; i++) {
		res -= solve(x / i);
	} return dp[x] = res;
}

void _main() {
	cin >> n >> k;
	mint res = 0;
	for (int i = 1; i <= k; i++) res += solve(k / i) * i;
	cout << res;
}
```

### AT_abc366_d [ABC366D] Cuboid Sum Query

三维前缀和板子题，容斥原理的另一种应用。我们先来推三维前缀和怎么算。设 $pre_{i,j,k}$ 表示以 $(i,j,k)$ 为右下角的立方体数字之和，则它显然由 $a_{i,j,k}$ 贡献。同时考虑去掉一行 / 一列 / 一柱，加上 $pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}$。这样我们会把同时退掉两维的前缀和算重，于是减去 $pre_{i-1,j-1,k}+pre_{i-1,j,k-1}+pre_{i,j-1,k-1}$。这样又把退掉三维的前缀和减多了，所以加上 $pre_{i-1,j-1,k-1}$。总的转移为

$pre_{i,j,k}=a_{i,j,k}+pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}-pre_{i-1,j-1,k}-pre_{i-1,j,k-1}-pre_{i,j-1,k-1}+pre_{i-1,j-1,k-1}$接着我们考虑单次询问以 $(x_1,y_1,z_1)$ 为左上角，$(x_2,y_2,z_2)$ 为右下角的立方体点权之和。同理可得答案为

$pre_{x_2,y_2,z_2}-pre_{x_1-1,y_2,z_2}-pre_{x_2,y_1-1,z_2}-pre_{x_2,y_2,z_1-1}+pre_{x_1-1,y_1-1,z_2}+pre_{x_1-1,y_2,z_1-1}+pre_{x_2,y_1-1,z_1-1}-pre_{x_1-1,y_1-1,z_1-1}$这两个式子本质是三维容斥原理 $|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$。

于是我们在预处理 $O(n^3)$，查询 $O(1)$ 下解决了该问题。

```cpp
const int N = 105;
int n, q, a[N][N][N], pre[N][N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) cin >> a[i][j][k];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) {
				pre[i][j][k] = a[i][j][k]
				+ pre[i][j][k - 1] + pre[i][j - 1][k] + pre[i - 1][j][k]
				- pre[i][j - 1][k - 1] - pre[i - 1][j][k - 1] - pre[i - 1][j - 1][k]
				+ pre[i - 1][j - 1][k - 1];
			}
		}
	}
	cin >> q;
	while (q--) {
		int x1, x2, y1, y2, z1, z2;
		cin >> x1 >> x2 >> y1 >> y2 >> z1 >> z2;
		cout << (pre[x2][y2][z2]
		- pre[x1 - 1][y2][z2] - pre[x2][y1 - 1][z2] - pre[x2][y2][z1 - 1]
		+ pre[x1 - 1][y1 - 1][z2] + pre[x1 - 1][y2][z1 - 1] + pre[x2][y1 - 1][z1 - 1]
		- pre[x1 - 1][y1 - 1][z1 - 1]) << '\n';
	}
}
```

### P8315 [COCI 2021/2022 #4] Šarenlist

集合容斥板子。

注意到 $m \le 15$，考虑 $O(2^m)$ 枚举一些限制并钦定其不满足。用一个 DFS 搜出路径，然后化边为点，并查集维护一下连通块数目 $c$，贡献就是 $k^c$。容斥系数为 $(-1)^{\operatorname{popcount}(S)}$。复杂度 $O(nm2^m \log n)$。

```cpp
const int N = 65;
int n, m, k, u, v;
pair<int, int> a[N];
int tot = 1, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int fa[N], sz[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
void unite(int x, int y) {fa[find(x)] = find(y);}

vector<int> p[N];
bool dfs(int u, int fa, int to, vector<int>& vec) {
	if (u == to) return true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		vec.emplace_back(j >> 1);
		if (dfs(v, u, to, vec)) return true;
		vec.pop_back();
	} return false;
}

void _main() {
	cin >> n >> m >> k;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	for (int i = 1; i <= m; i++) {
		cin >> a[i], dfs(a[i].first, -1, a[i].second, p[i]);
	}
	mint res = 0;
	for (int s = 0; s < (1 << m); s++) {
		iota(fa + 1, fa + n + 1, 1);
		for (int i = 1; i <= m; i++) {
			if (!(s >> (i - 1) & 1)) continue;
			for (int j = 1; j < (int) p[i].size(); j++) unite(p[i][j - 1], p[i][j]);
		}
		int part = 0;
		for (int i = 1; i < n; i++) part += (i == find(i));
		if (popcount(s) & 1) res -= mint(k).pow(part);
		else res += mint(k).pow(part);
	} cout << res;
}
```

### P1450 [HAOI2008] 硬币购物

先考虑跑一个完全背包，令 $dp_{i,j}$ 表示前 $i$ 种硬币支付 $j$ 元的方案数，有

$dp_{i,j}=dp_{i-1,j}+dp_{i,j-x_i}$滚动数组优化一下，答案为 $dp_n$。这样会算多，于是我们把第 $1,2,3,4$ 种硬币超限的情况分别减掉。又减多了，加回来……可以看到是一个容斥的过程。写出四维容斥原理：

$$
|A\cup B \cup C \cup D|=
|A|+|B|+|C|+|D|
-|A\cap B|-|A\cap C|-|A\cap D|-|B\cap C|-|B \cap D|-|C \cap D|
+|A\cap B\cap C|+|A\cap B\cap D|+|A\cap C\cap D|+|B\cap C \cap D|
-|A\cap B\cap C \cap D|
$$

最后再用一个总的减法原理即可。

```cpp
#define int long long
const int N = 1e5 + 5;
int a, b, c, d, s, c1, c2, c3, c4, q, dp[N];
void work(int x) {
	for (int i = x; i < N; i++) dp[i] += dp[i - x];
}
int f(int x) {return x < 0 ? 0 : dp[x];}

void _main() {
	cin >> c1 >> c2 >> c3 >> c4;
	dp[0] = 1;
	work(c1), work(c2), work(c3), work(c4);
	for (cin >> q; q--; ) {
		cin >> a >> b >> c >> d >> s;
		a = (a + 1) * c1, b = (b + 1) * c2, c = (c + 1) * c3, d = (d + 1) * c4;
		cout << f(s) - f(s - a) - f(s - b) - f(s - c) - f(s - d)
			+ f(s - a - b) + f(s - a - c) + f(s - a - d) + f(s - b - c) + f(s - b - d) + f(s - c - d)
			- f(s - a - b - c) - f(s - a - b - d) - f(s - a - c - d) - f(s - b - c - d)
			+ f(s - a - b - c - d) << '\n';
	}
}
```

### *P6651 「SWTR-5」Chain

一步一步考虑，先想无修改怎么做，我们在拓扑序上做 DP，由加法原理

$f_{i} \gets f_{i}+f_j$进一步地，由于 $n\le 2\times 10^3$，我们可以利用拓扑排序，在 $O(n^2)$ 时间内预处理从 $u$ 到 $v$ 的链数，则

$dp_{k,v} \gets dp_{k,v}+dp_{k,u}$类似 Floyd 那样，对于有向边 $(u,v)$，枚举中继点 $k \in [1,n]$，由加法原理合并。记入度为 $ideg_i$，出度为 $odeg_i$，则总链数

$tot=\sum_{ideg_i=0} \sum_{odeg_j=0} dp_{i,j}$因为一条链的起终点一定满足上述条件。接着我们考虑 $k=1$ 的做法，套路地，记 $f_i$ 为链起点到点 $i$ 的方案数，然后建反图，记 $g_i$ 是反图上的 $f_i$，发现 $g_i$ 等价于原图中点 $i$ 到链终点的方案数。由 $dp_{i,j}$ 的定义易得转移：

$$
f_i = \sum_{ideg_j=0} dp_{j,i}\\
g_i = \sum_{odeg_j=0} dp_{i,j}
$$

那么 $k=1$ 的情况就可以用 $tot-f_ig_i$ 回答。接着我们想 $k=2$，不妨设两点 $u,v$ 中 $u$ 的拓扑序小于 $v$，分类讨论：

- 若 $u,v$ 不在同一条链上，直接用 $tot-f_ug_u-f_vg_v$ 回答；
- 若 $u,v$ 可以在同一条链上，那么 $u$ 到终端的路径包含了 $v$。考虑容斥把重复的加回来，这里的重复是 $f_ug_v dp_{u,v}$，答案为 $tot-f_ug_u-f_vg_v+f_ug_v dp_{u,v}=tot-f_ug_u-g_v(f_v-f_udp_{u,v})$。

接着我们扩展到 $k \le 15$。我们先按拓扑序排序，对于每个点处理要容斥掉的数 $h_i$，则

$h_i=f_i-\sum h_j dp_{j,i}$其中 $j$ 的拓扑序在 $i$ 之前。于是答案为

$tot-\sum h_ig_i$至此，我们在预处理 $O(n^2+m)$，单次查询 $O(k^2)$ 的复杂度下解决了此问题。

```cpp
const int N = 2e3 + 5, M = 2e4 + 5;

int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[M];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, m, u, v, q, len, ideg[N], odeg[N];

int cnt, bfn[N];
mint dp[N][N], f[N], g[N], h[20];
void topo() {
	queue<int> q;
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) q.emplace(i);
		dp[i][i] = 1;
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		bfn[u] = ++cnt;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			for (int k = 1; k <= n; k++) dp[k][v] += dp[k][u];
			if (--ideg[v] == 0) q.emplace(v);
		}
	}
}

vector<int> st, ed;
void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		add_edge(u, v);
		odeg[u]++, ideg[v]++;
	}
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) st.emplace_back(i);
		if (odeg[i] == 0) ed.emplace_back(i);
	} topo();
	mint tot = 0;
	for (int i : st) {
		for (int j : ed) tot += dp[i][j];
	}
	for (int i = 1; i <= n; i++) {
		for (int j : st) f[i] += dp[j][i];
		for (int j : ed) g[i] += dp[i][j];
	}
	for (cin >> q; q--; ) {
		fill(h, h + len, 0);
		cin >> len;
		vector<int> c;
		for (int i = 0; i < len; i++) cin >> u, c.emplace_back(u);
		sort(c.begin(), c.end(), [](int x, int y) -> bool {
			return bfn[x] < bfn[y];
		});
		for (int i = 0; i < len; i++) {
			h[i] = f[c[i]];
			for (int j = 0; j < i; j++) h[i] -= dp[c[j]][c[i]] * h[j];
		}
		mint res = 0;
		for (int i = 0; i < len; i++) res += h[i] * g[c[i]];
		cout << tot - res << '\n';
	}
}
```

### *P5933 [清华集训 2012] 串珠子

绝世好题。前置知识：18.2 子集枚举。下面是本人模拟赛上的思考过程：

注意到 $n \le 16$，一眼状压 DP。如果复杂度是 $O(n2^n)$ 完全可以开到 $20$，所以这题复杂度是 $O(n^22^n)$ 或者 $O(3^n)$。如果考虑 $O(3^n)$，思考子集枚举，分成两个连通块合并答案。发现会算重。

正难则反，记 $g_S$ 表示 $S$ 这个点集的总方案数，显然 $g_S=\prod _{u,v \in S} (a_{u,v}+1)$，可以 $O(n^2 2^n)$ 预处理。考虑计数 DP 配合高维容斥，设 $f_S$ 表示 $S$ 这个点集的答案，用减法原理算出 $f_S$ 即可。枚举 $T \subseteq S$，表示从 $S$ 中钦定一个连通块，其余点任意，则

$f_S =g_S - \sum_{T \subseteq S} f_T \times  g_{S \setminus T}$写完发现减多了，样例得到了宇宙终极答案 $42$。考虑手玩样例，$|S| \le 1$ 的集合显然，直接看 $|S| \ge 2$ 的集合：

- $S=\{1,2\}$，则 $f_S=2,g_S=3$。
- $S=\{1,3\}$，则 $f_S=3,g_S=4$。
- $S=\{2,3\}$，则 $f_S=4,g_S=5$。
- $S=\{1,2,3\}$，列出可能的 $T$ 和 $S \setminus T$：

| $T$ | $S \setminus T$ | $f_T$ | $g_{S \setminus T}$ |
| --- | --- | --- | --- |
| $\{1\}$ | $\{2,3\}$ | $1$ | $5$ |
| $\{2\}$ | $\{1,3\}$ | $1$ | $4$ |
| $\{3\}$ | $\{1,2\}$ | $1$ | $3$ |
| $\{2,3\}$ | $\{1\}$ | $4$ | $2$ |
| $\{1,3\}$ | $\{2\}$ | $3$ | $2$ |
| $\{1,2\}$ | $\{3\}$ | $2$ | $2$ |

而 $g_S=3 \times 4 \times 5=60$，按这种方法减去就是 $42$。

考虑为什么会减多。发现 $(T, S \setminus T)$ 会被重复计算两次。并且贡献不同，没有办法用简单的 $\times \dfrac{1}{2}$ 处理。观察不重的三组，比如 1、3、5 行，可以发现：$2 \in (S \setminus T)$。于是有一个神奇的做法：钦定一个点，强制让它属于 $S$ 集合，就实现了去重。

最终复杂度为 $O(3^n)$。赛时代码：

```cpp
const int N = 17;
mint a[N][N], f[1 << N], g[1 << N];
int n;

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	for (int i = 0; i < (1 << n); i++) {
		g[i] = 1;
		for (int j = 1; j <= n; j++) {
			if (!(i >> (j - 1) & 1)) continue;
			for (int k = j + 1; k <= n; k++) {
				if (i >> (k - 1) & 1) g[i] *= a[j][k] + 1;
			}
		}
	}
	for (int i = 1; i < (1 << n); i++) {
		f[i] = g[i];
		int d = -1;
		for (int j = 0; j < n; j++) {
			if (i >> j & 1) {d = j; break;}
		}
		int s = i ^ (1 << d);
		for (int j = s; j; j = (j - 1) & s) f[i] -= g[j] * f[(s ^ j) | (1 << d)];
	} cout << f[(1 << n) - 1];
}
```

### *P11197 [COTS 2021] 赛狗游戏 Tiket

先转化一下题意，排列 $T$ 不影响答案，因为数对交换一下就满足条件 2。设 $a_i,b_i,c_i$ 为三个排列中 $i$ 出现的位置，问题变成求满足 $a_i<a_j,b_i<b_j,c_i<c_j$ 的三元组 $(i,j,k)$ 数目。

这是三维偏序的模板，使用高级数据结构可做到 $O(n \log^2 n)$。观察到，$a,b,c$ 都是排列。事实上，应用容斥原理可以简单地解决排列上的三维偏序问题。

设 $A=\{(i,j) \mid a_i<a_j\}, B=\{(i,j) \mid b_i<b_j\},C=\{(i,j) \mid c_i<c_j\}$，所求为 $|A \cap B \cap C|$，容斥一下得到

$|A\cap B\cap C|=\dfrac{1}{2}(|A \cap B|+|B \cap C|+|A \cap C|-|A \cup B \cup C|)$对于形如 $|A \cap B|$ 的三部分，做一个二维偏序即可 $O(n \log n)$。考虑 $|A \cup B \cup C|$，若 $(i,j)$ 满足一维偏序，则 $(j,i)$ 满足二维偏序；若其满足二维偏序，则 $(j,i)$ 满足一维偏序；若其满足三维偏序，则 $(j,i)$ 不满足任何偏序。因此，每个 $(i,j)$ 在 $|A \cup B \cup C|$ 中恰好被贡献一次，即 $|A \cup B \cup C|=\dfrac{n(n-1)}{2}$。

于是我们只要做三次二维偏序即可做到 $O(n \log n)$。

```cpp
const int N = 5e5 + 5;
int n, x, a[N], b[N], c[N], d[N], tr[N];
void add(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int ask(int x) {
	int res = 0;
	for (; x >= 1; x -= lowbit(x)) res += tr[x];
	return res;
}
long long solve(int *a, int *b) {
	fill(tr + 1, tr + n + 1, 0);
	long long res = 0;
	for (int i = 1; i <= n; i++) d[b[i]] = a[i];
	for (int i = 1; i <= n; i++) res += ask(d[i]), add(d[i], 1);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> x;
	for (int i = 1; i <= n; i++) cin >> x, a[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, b[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, c[x] = i;
	cout << (solve(a, b) + solve(a, c) + solve(b, c) - 1LL * n * (n - 1) / 2) / 2;
}
```

## 附：计数基础·容斥与反演（stripe-python）

## 2. 容斥原理

OI 中的**容斥原理**是一类计数方法的统称。下面先介绍一个最朴素的容斥：

考虑有限集 $A,B,C$，我们要计数 $A \cup B \cup C$ 的元素数目，那么有
$$
|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B \cap C|+|A \cap B \cap C|
$$
将上述结论推广，记全集为 $U$，元素共有 $n$ 种属性，具有第 $i$ 种属性的元素构成集合 $S_i$，则不具有任何属性的元素数目为
$$
\left|U\right|-\left| \bigcup_{i=1}^n S_i \right|=\sum_{k=0}^n (-1)^k \sum \left|\bigcap_{i=1}^k S_{p_i} \right|
$$
上式中，$(-1)^k$ 称为**容斥系数**。第二个 $\sum$ 的要求为：选出 $k$ 个不同的下标，记为 $p_1 \sim p_k$。

第二个求和的组合意义引出了**钦定**的概念。我们钦定 $k$ 种属性 $p_1 \sim p_k$，并计算具有这些属性的元素数目。请注意，这里计数的元素一定具有 $p_1 \sim p_k$ 这些属性，但并不是只有这些属性。因此，更准确的组合意义应该是**钦定至少**。

:::::info[说明]{open}

**钦定至少**的组合意义隐含着两步：先枚举 $p_1 \sim p_k$，再计数具有这些属性的元素数目。每种钦定方式的元素数目需要求和。

另一种组合意义叫做**选择至少**，相当于直接求属性个数 $\ge k$ 的元素数目。

钦定和选择的组合意义是完全不同的，请读者注意区分。

:::::

容易发现，一个元素会被不同的钦定至少算到多次。形式化地，对于一个元素 $x \in U$，设其具有的属性集合为 $A$，则其被钦定方式 $B$ 算到当且仅当 $B \subseteq A$。因此：

- $x$ 会被计算 $2^{|A|}$ 次。
- 有关 $x$ 的容斥系数之和为 $\sum\limits_{B \subseteq A} (-1)^{|B|} =[A = \varnothing]$。

:::::success[代数推导]

考虑枚举 $|B|=k$，于是
$$
\begin{aligned}
\sum_{B \subseteq A} (-1)^{|B|}&=\sum_{k=0}^{|A|} (-1)^k \binom{|A|}{k}\\
&=(-1+1)^{|A|}\\
&=0
\end{aligned}
$$
当 $A =\varnothing$ 时上式的值为 $1$。

:::::

由于系数为 $[A =\varnothing]$，没有任何属性的元素被计算 $1$ 次，具有属性的元素被计算 $0$ 次。因此，钦定至少的容斥方法可以正确算出答案。

需要注意的是，朴素地计算这个容斥式的复杂度为 $O(n2^n)$。在很多题目中，我们可以以更低的复杂度计算 $\sum \left|\bigcap\limits_{i=1}^k S_{p_i} \right|$ 。

从这个式子中，我们可以得到容斥原理的核心思想：用一种容斥方法，将每个元素计算多次，并配以恰当的容斥系数，使得容斥系数之和恰好就是我们希望的系数。

### 2.3 min-max 容斥

**min-max 容斥**又称为最值反演。对于长度为 $n$ 的序列 $a_i$，记 $S=\{1,2,\cdots,n\}$，那么
$$
\max_{i \in S} a_i=\sum_ {T \subseteq S} (-1)^{|T|-1} \min_{i \in T} a_j\\
\min_{i \in S} a_i=\sum_ {T \subseteq S} (-1)^{|T|-1} \max_{i \in T} a_j\\
$$
min-max 容斥实现了 $\min$ 和 $\max$ 的转化，$(-1)^{|T|-1}$ 是这一转化的容斥系数。

记第 $k$ 小为 $k \text{th}\min$，则扩展 min-max 容斥指出
$$
k\text{th}\max_{i \in S} = \sum_{T \subseteq S} (-1)^{|T|-k} \binom{|T|-1}{k-1} \min_{i \in S} a_i\\
k\text{th}\min_{i \in S} = \sum_{T \subseteq S} (-1)^{|T|-k} \binom{|T|-1}{k-1} \max_{i \in S} a_i\\
$$
 类似于朴素容斥推广到二项式反演，min-max 容斥推广到扩展 min-max 容斥也是同理。$(-1)^{|T|-k} \dbinom{|T|-1}{k-1}$ 是扩展 min-max 容斥的容斥系数。

值得注意的是，由于期望线性性的存在，对等式两边同时套一个期望，min-max 容斥仍然成立。因此这个式子常用于计算最值的期望。

另一个应用是，考虑对质因数分解后的指数做 min-max 容斥，那么有 gcd-lcm 推广：
$$
\underset{i\in S}{\operatorname{lcm}} a_i=\prod _{T \subseteq S} \left(\gcd_{i \in T} a_i \right)^{(-1)^{|T|-1}}
$$

### 2.4 斯特林反演

类比二项式反演的 $g(k)=\sum\limits_{i=k}^n \dbinom{i}{n} f(i)$，如果系数由组合数变成了斯特林数，而我们仍然希望配上容斥系数实现 $g \to f$ 的转化，则需要利用**斯特林反演**的结论：
$$
g(k)=\sum_{i=k}^n \left\{\begin{matrix}
n \\
i
\end{matrix}\right\} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k} \begin{bmatrix}
n \\
i
\end{bmatrix} g(i)\\
g(k)=\sum_{i=k}^n \begin{bmatrix}
n \\
i
\end{bmatrix} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k} \left\{\begin{matrix}
n \\
i
\end{matrix}\right\} g(i)
$$
这两个式子揭示了两类斯特林数的内在联系。
