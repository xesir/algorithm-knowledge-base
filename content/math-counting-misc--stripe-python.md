---
id: math-counting-misc
title: '计数杂项：排列计数与图论计数'
category: '数学'
subcategory: '组合数学'
tags: ['排列计数', '图论计数', '计数']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: C
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 17. 计数杂项

## 17.1 排列计数

排列计数问题往往需要设计一个计数 DP。这类题目的 DP 状态一般设 $dp_{i, \cdots}$ 表示当前需要放入第 $i$ 个数的方案数，然后根据需要添加维度。在转移时，往往要从**插入 / 填入**角度分类讨论 $i$ 带来的贡献，并根据乘法或加法原理合并答案。

## 17.2 图论计数

图论计数问题一般是对特定的图结构进行计数。在计数时，最关键的要求是找到目标图的特定结构进行刻画。如果刻画比较困难，可以考虑弱一些的条件然后使用容斥解决。一些题目还要配合子集反演、二项式反演、集合幂级数、多项式科技等。下面是一些图论计数的结论。

## 17.3 例题

前半部分是排列计数，后半部分是图论计数。

### P2401 不等数列

观察数据范围可以发现是一个 $O(nk)$ 的 dp，设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个小于号的方案数。分类讨论：

1. 若放在最左边，会多一个大于号，从 $dp_{i-1,j}$ 转移；
2. 若放在最右边，会多一个小于号，从 $dp_{i-1,j-1}$ 转移；
3. 若插入到小于号之前，因为数字 $i$ 是最大的，所以小于号变为大于号，而前面是一个小于号，因此是多了一个大于号，从 $j \times dp_{i-1,j}$ 转移；
4. 若插入到大于号之前，同理可得转移为 $(i-j-1) \times dp_{i-1,j-1}$。

由加法原理得：

$dp_{i,j}=(j+1) \times  dp_{i-1,j} +(i-j) \times dp_{i-1,j-1}$至此本题在 $O(nk)$ 内解决。边界为 $dp_{i,0}=1$。

```cpp
const int N = 1005;
int n, k;
mint dp[N][N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	for (int i = 2; i <= n; i++) {
		dp[i][0] = 1;
		for (int j = 1; j <= min(i, k); j++) {
			dp[i][j] = dp[i - 1][j] * (j + 1) + dp[i - 1][j - 1] * (i - j);
		}
	} cout << dp[n][k];
}
```

### P6323 [COCI 2006/2007 #4] ZBRKA

还是设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个逆序对的方案数。考虑插入在 $i-1$ 的全排列中插入 $i$ ，枚举增加了多少逆序对 $k$，则有

$dp_{i,j} = \sum_{k=0}^{\min(i-1,j)} dp_{i-1,j-k}$直接做是 $O(nk^2)$ 的。注意到 $dp_{i,j}$ 为同一行 $dp_{i-1}$ 连续区间的和，用前缀和优化即可。考虑求 $j-k$ 的范围，发现 $j-k \in [\max(0, j-i+1), j]$。边界是 $dp_{i,0}=1$。

```cpp
const int N = 1e3 + 5;
int n, k;
mint dp[N][10005], pre[N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	fill(pre + 1, pre + k + 2, 1);
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= k; j++) dp[i][j] = pre[j + 1] - pre[max(0, j - i + 1)];
		pre[0] = 0;
		for (int j = 1; j <= k; j++) pre[j + 1] = pre[j] + dp[i][j];
	}
	cout << dp[n][k];
}
```

三倍经验：[P1521](https://www.luogu.com.cn/problem/P1521)、[P2513](https://www.luogu.com.cn/problem/P2513)。

### *P7967 [COCI 2021/2022 #2] Magneti

好像这种问题叫做连续段 dp。

DP 题套路先对 $r_i$ 排序简化问题。仍然设 $dp_{i,\cdots}$ 表示当前需要放入第 $i$ 个磁铁的方案数。考虑加维，经过尝试发现空位要是单独一维，连通块也是单独一维。这里的连通块是一个不能再插入磁铁的磁铁连续段。因此，设 $dp_{i,j,k}$ 表示当前需要放入第 $i$ 个磁铁，分成 $j$ 个连通块，占用掉 $k$ 个空位的方案数。

考虑插入 $i$ 并分类讨论：

1. 若第 $i$ 个磁铁单独成为新的块，则从 $dp_{i-1,j-1,k-1}$ 转移；
2. 若第 $i$ 个磁铁放在第 $j$ 个连通块端点，则从 $2j \times dp_{i-1,j,k-r_i}$ 转移。
3. 若第 $i$ 个磁铁将两个连通块合并为一个，则从 $j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$ 转移。

于是状态转移方程为：

$dp_{i,j,k}=dp_{i-1,j-1,k-1}+2j \times dp_{i-1,j,k-r_i}+j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$由此可以求出所有磁铁只形成一个连通块且长度为 $i$ 的方案数 $dp_{n,1,i}$，则根据插板法，将 $l-i$ 个空插到连通块中，答案为

$\sum_{i=1}^{l} dp_{n,1,i} \times C_{l-i+n}^{n}$时空 $O(n^2l)$，使用逆元法求组合数。边界为 $dp_{0,0,0}=1$。

```cpp
const int N = 1e4 + 5;
mint fac[N], ifac[N], dp[55][55][N];

mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

int n, l, r[N];

void _main() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> l;
	for (int i = 1; i <= n; i++) cin >> r[i];
	sort(r + 1, r + n + 1);
	dp[0][0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= l; k++) {
				dp[i][j][k] = dp[i - 1][j - 1][k - 1];
				if (k >= r[i]) dp[i][j][k] += dp[i - 1][j][k - r[i]] * 2 * j;
				if (k >= 2 * r[i] - 1) dp[i][j][k] += dp[i - 1][j + 1][k - 2 * r[i] + 1] * j * (j + 1);
			}
		}
	}
	mint res = 0;
	for (int i = 1; i <= l; i++) res += dp[n][1][i] * C(l - i + n, n);
	cout << res;
}
```

### *AT_code_festival_2017_qualc_f Three Gluttons

思路来自[第一篇题解](https://www.luogu.com.cn/article/8v8z4sbf)。

显然题目中所给的限制没有什么性质，考虑找到一个充要条件对其进行刻画然后计数 DP。

时光倒流，如果 A, B, C 三人最后选择的是 $x_1,y_1,z_1$，只有 $[z_1,x_1,y_1]$ 和 $[z_1,y_1,x_1]$ 符合要求，因为 C 必须先选走 $z_1$，选法为 $1 \times 2 = 2$ 种。

反推一次，如果选择变成了 $x_2,y_2,z_2$，$z_2$ 必须被 C 先选择，则根据乘法原理，$x_2,y_2$ 的选法为 $4 \times 5=20$ 种。

数学归纳法，当反推到第 $i$ 次时的方案数为 $(3i-2)(3i-1)$。因此，对于一个合法排列，对应选择序列的方案数为

$\prod_{i=1}^n (3i-2)(3i-1)$因此，我们只要找到合法排列的数目，乘上这个东西得到答案即可。对于已知的 $a,b,c$ 三个排列，我们这样刻画合法的充要条件：

- $a,b,c$ 内部元素不重，$\forall i$，$a_{i_t},b_{j_t},c_{k_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\} \cup \{c_1 \sim c_{k_t}\}$ 出现且仅出现一次。

因为 $c$ 未知，假如对 C 的选择序列 $x$ 有办法计数，那么只要发现 $c$ 与 $x$ 的映射关系就可以对排列计数。可以得到 $\exists c, c \to x$ 的充要条件是：

- $x$ 元素不重，$a_{i_t},b_{j_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现且仅出现一次，$x_t$ 未在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现。

设当前为第 $t$ 位，不能成为 $x_t$ 的数有：

- $u \in [t+1,n]$ 的 $a_{i_u},b_{j_u},c_{k_u}$。
- $x \in \{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$。

容易发现这两个集合无交集，剩下 $3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$ 个数均能填入其中。

考虑排列计数 DP，设 $dp_{t,i,j}$ 表示 $i_t=i, j_t=j$ 的方案数，从填入角度考虑 $t$ 位置的贡献即可。转移方程形如

$dp_{t,i,j}=\sum_{i'<i,j'<j} dp_{t-1,i',j'} \times (3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|)$直接转移复杂度 $O(n^6)$。

注意到不合法的数目可以预处理出来，设 $x_{i,j}=|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$，对 $x_i$ 作前缀和可以直接查询。复杂度 $O(n^4)$。

注意到每次转移形如一个矩形求和，考虑动态地对 $dp_{i,j}$ 作二维前缀和。复杂度 $O(n^3)$。

```cpp
const int N = 405;
int n, a[N], b[N], x[N][N];
mint dp[N][N][N];
bool vis[N], va[N][N], vb[N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	for (int i = 1; i <= n; i++) {
		vis[a[i]] = true, x[i][0] = i;
		for (int j = 1; j <= n; j++) x[i][j] = x[i][j - 1] + !vis[b[j]];
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= i; j++) va[i][a[j]] = true, vb[i][b[j]] = true;
	}
	for (int i = 0; i <= n; i++) fill(dp[0][i], dp[0][i] + n + 1, 1);
	for (int t = 1; t <= n / 3; t++) {
		for (int i = t; i <= n; i++) {
			for (int j = t; j <= n; j++) {
				if (!va[i][b[j]] && !vb[j][a[i]]) dp[t][i][j] = dp[t - 1][i - 1][j - 1] * (3 * t - x[i][j]);
				dp[t][i][j] += dp[t][i - 1][j] + dp[t][i][j - 1] - dp[t][i - 1][j - 1];
			}
		}
	}
	mint res = dp[n / 3][n][n];
	for (int i = 1; i <= n / 3; i++) res *= (3 * i - 2) * (3 * i - 1);
	cout << res;
}
```

### CF11D A Simple Task

无向图简单环计数。

注意到 $n \le 19$，考虑状压 DP。设 $dp_{S,u}$ 表示当前经过了 $S$ 中的点，$u$ 为当前位置时的路径条数。

直接做会算重。考虑使用[串珠子](https://www.luogu.com.cn/problem/P5933)的 trick，钦定起点为当前走过的点中编号最小的点。体现在二进制中就是 $s=\operatorname{lowbit}(S)$。枚举 $u \to v$ 边，如果 $v$ 比 $S$ 中最小点还小则不合法。否则分类讨论：

- 若 $v \notin S$，直接转移：$dp_{S \cup \{v\},v} \gets dp_{S,u}$。
- 若 $v \in S$ 且 $v=\operatorname{lowbit}(S)$，则构成一个环，答案加上 $dp_{S,u}$。
- 否则，$v$ 对当前状态无贡献。

特别注意，这样计数会算上重边构成的二元环，还会把多元环算两次，最后的答案应该是 $\dfrac{ans-m}{2}$。复杂度 $O(n^22^n)$。

```cpp
const int N = 20;
int n, m, u, v, g[N][N];
long long f[N][1 << N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		g[u][v] = g[v][u] = 1;
	}
	for (int i = 1; i <= n; i++) f[i][1 << (i - 1)] = 1;
	long long res = 0;
	for (int s = 1; s < (1 << n); s++) {
		for (int u = 1; u <= n; u++) {
			if (!(s >> (u - 1) & 1)) continue;
			for (int v = 1; v <= n; v++) {
				if (!g[u][v]) continue;
				if ((s & -s) > (1 << (v - 1))) continue;
				if (s >> (v - 1) & 1) {
					if ((s & -s) == (1 << (v - 1))) res += f[u][s];
				} else {
					f[v][s | (1 << (v - 1))] += f[u][s];
				}
			}
		}
	}
	cout << (res - m) / 2;
}
```

### P1989 无向图三元环计数

传统做法是将点重标号为 $p_1,p_2,p_3,\cdots,p_n$，满足 $d_x <d_y \Leftrightarrow p_x<p_y$，其中 $d$ 为度数。

此时有一个重要的性质：$\forall u \to v$，满足 $p_y >p_x$ 的点至多只有 $\sqrt{2m}$ 条。证明考虑反证，若超过 $\sqrt{2m}$，则出点度数均 $>\sqrt{2m}$，总度数大于 $\sqrt{2m}$，与握手定理矛盾。

重定向，仅保留 $p_x<p_y$ 的 $(u,v)$变成有向边。则可以直接枚举并计数：枚举 $u$，将 $u$ 的出点打上标记，再枚举所有打上标记的点 $v$ 的所有出点 $w$，若 $w$ 也被标记，则发现三元环 $(u,v,w)$。

复杂度 $O(m\sqrt{m})$，并且可以发现三元环的数目上界为 $O(m\sqrt{m})$ 级别。

```cpp
const int N = 1e5 + 5;
int n, m, deg[N], tag[N];
pair<int, int> e[N << 1];
vector<int> g[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> e[i], deg[e[i].first]++, deg[e[i].second]++;
	auto f = [&](int x, int y) -> bool {return deg[x] == deg[y] ? x < y : deg[x] < deg[y];};
	for (int i = 1; i <= m; i++) {
		if (f(e[i].first, e[i].second)) g[e[i].first].emplace_back(e[i].second);
		else g[e[i].second].emplace_back(e[i].first);
	}
	int res = 0;
	for (int u = 1; u <= n; u++){
		for (int v : g[u]) tag[v] = u;
		for (int v : g[u]) {
			for (int w : g[v]) res += tag[w] == u;
		}
	} cout << res;
}
```

### P10982 Connected Graph

考虑高维容斥，设 $g_n$ 为 $n$ 个点有标号图的方案数，$f_n$ 为有标号且连通的方案数。

因为 $n$ 个点的图最多有 $C_{n}^2$ 条边，每条边都可以选与不选，所以

$g_n=2^{C_n^2}$考虑如何刻画连通图的性质。钦定一个节点，枚举其所属连通块的大小 $i$，从剩下 $n-1$ 个点选择 $i-1$ 个组成一个新连通块。于是

$f_n=g_n-\sum_{i=1}^{n-1} C_{n-1}^{i-1} f_i g_{n-i}$复杂度 $O(n^2)$。可以多项式科技优化到 $O(n \log^2 n)$。

```cpp
const int N = 1005;
int n;
mint f[N + 5], g[N + 5], fac[N + 5], ifac[N + 5];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 1; i <= n; i++) g[i] = mint(2).pow(C(i, 2).val);
	f[1] = 1;
	for (int i = 2; i <= n; i++) {
		f[i] = g[i];
		for (int j = 1; j < i; j++) f[i] -= C(i - 1, j - 1) * f[j] * g[i - j];
	} cout << f[n];
}
```

### *P6596 How Many of Them

tourist 的神仙题。前置知识：无向图连通性的有关概念和定理。以下是蓝书做法。

设 $f_{i,j}$ 表示点数为 $i$，割边数为 $j$ 的无向连通图数目。

考虑枚举 $1$ 号点所在的边双连通分量的大小 $k$。从 $i-1$ 个节点中选出 $k$ 个构成边双，方案数是 $f_{k,0} \times C_{i-1}^{k-1}$ 乘上其他部分的贡献。

设 $g_{i,j,k}$ 表示点数为 $i$，割边数为 $j$，有 $k$ 个连通块的无向图数目。则对于 $f_{i,j}$，去掉边双以后剩下 $g_{i-k,j-x,x}$ 的贡献，其中 $x$ 是枚举的量，表示剩下的图中被分成了 $x$ 个连通块。每个连通块与边双形成 $x$ 条割边，所以还需要凑出 $j-x$ 条割边。由于这个边双有 $k$ 个点，每个节点都有 $k$ 种选择，贡献还要乘上 $k^x$。因此

$f_{i,j}=\sum_{k=1}^{i-1} \left( f_{k,0} C_{i-1}^{k-1}\sum_{x=1}^{\min(i-k,j)} g_{i-k,j-x,x}k^x \right)$记 $h_i$ 表示点数为 $i$ 的无向连通图数目。用上一题的转移求出以后，作一个高维容斥得到

$f_{i,0}=h_i-\sum_{j=1}^{i-1} f_{i,j}$考虑 $g_{i,j,k}$ 的转移。为了取重，钦定标号最小点属于一个连通块，然后枚举该连通块的大小 $p$，割边数目 $q$。乘上选法，贡献为 $f_{p,q} C_{i-1}^{p-1}$。再从连通块中找到一个节点连向边双，有 $p$ 种方案。最后讨论图中其他部分，得到 $g_{i-p,j-q,k-1}$。最终得到转移：

$g_{i,j,k}=\sum_{p=1}^i \sum_{q=0}^j f_{p,q} C_{i-1}^{p-1} p g_{i-p,j-q,k-1}$注意到 $n$ 个点的图最多 $n-1$ 条割边，所以 $m$ 实际上与 $n$ 同阶。总复杂度 $O(n^4)$。

由于本题的转移太过复杂，本人试图对 $f,g$ 都记搜转移，但写挂了。于是用了题解里仅记搜 $g$ 的写法。

```cpp
const int N = 55;
int n, m;
mint fac[N], ifac[N], f[N][N], g[N][N][N], h[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint G(int i, int j, int k) {
	if (k > i || (i != 0 && k == 0)) return g[i][j][k] = 0;
	if (g[i][j][k] != -1) return g[i][j][k];
	g[i][j][k] = 0;
	for (int p = 1; p <= i; p++) {
		for (int q = 0; q <= j; q++) {
			g[i][j][k] += f[p][q] * C(i - 1, p - 1) * p * G(i - p, j - q, k - 1);
		}
	} return g[i][j][k];
}

void _main() {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) fill(g[i][j], g[i][j] + N, -1);
	}
	cin >> n >> m;
	m = min(n, m);
	fac[0] = ifac[0] = 1, h[1] = 1, f[0][0] = 1, g[0][0][0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) {
		h[i] = mint(2).pow(C(i, 2).val);
		for (int j = 1; j < i; j++) h[i] -= C(i - 1, j - 1) * h[j] * mint(2).pow(C(i - j, 2).val);
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j < i; j++) {
			for (int k = 1; k < i; k++) {
				mint sum = 0;
				for (int x = 1; x <= min(i - k, j); x++) sum += G(i - k, j - x, x) * mint(k).pow(x);
				f[i][j] += f[k][0] * C(i - 1, k - 1) * sum;
			}
		}
		f[i][0] = h[i];
		for (int j = 1; j < i; j++) f[i][0] -= f[i][j];
	}
	mint res = 0;
	for (int i = 0; i <= m; i++) res += f[n][i];
	cout << res;
}
```

### [模拟赛] 竞赛图

> 给你一个 $n$ 个点的竞赛图，求有多少个点的子集 $S$ 满足 $S$ 的诱导子图是强连通的。答案包括空集。
>
> > 竞赛图是一个有向图，满足任意两个不同的点之间均存在且仅存在一条有向边相连。
> >
> > 一个图在点集 $S$ 的诱导子图的定义为：点集为 $S$，边集为所有两端的点都在 $S$ 中的边的子图。
>
> 多测，$n \le 24$，$T \le 10$。

暴力 Tarjan 可以做到单次 $O(n^22^n)$，和我一样没有前途。

根据竞赛图的性质，将一个强连通分量 $S$ 提出来后，$S$ 的补集与 $S$ 只存在内向边。

直接想状压。考虑类似刷表的做法，用强连通子集 $S$ 去转移其他自己，设出边集合的**交集**为 $E$，对于每个 $T \subseteq E$，$S \cup B$ 中来自 $B$ 的部分一定不强联通，将其标记即可。类似筛法，未被标记的都是强连通子集。

单次复杂度 $O(2^n)$，可以通过。

```cpp
const int N = 24;
int n, a[N], b[1 << N];
bitset<1 << N> vis;

void _main() {
	cin >> n;
	for (int i = 0; i < n; i++) {
		a[i] = 0;
		for (int j = 0, x; j < n; j++) {
			cin >> x;
			if (x) a[i] |= 1 << j;
		}
	}
	vis.reset(), b[0] = (1 << n) - 1;
	int res = 1;
	for (int s = 1; s < (1 << n); s++) {
		b[s] = b[s ^ lowbit(s)] & a[ctz(s)];
		if (vis[s]) continue;
		res++;
		for (int t = b[s]; t; t = (t - 1) & b[s]) vis[s | t] = 1;
	}
	cout << res << '\n';
}
```

### *P3349 [ZJOI2016] 小星星

子集反演例题。

考虑普通状压 DP，设 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号的集合为 $S$ 的方案数。可以得到转移

$dp_{u,i,S}=\prod_{(u,v)} \sum_{(i,j)} \sum_{T \subseteq S} dp_{v,j,T}$复杂度 $O(n^33^n)$，无法通过。注意到我们必须去掉 $T \subseteq S$ 的部分。

复杂度瓶颈在去重。因此，设 $f(S)$ 表示 $n$ 个点的映射恰好使用 $S$ 中所有点的方案数，$g(S)$ 表示 $n$ 个点的映射至多使用 $S$ 中所有点的方案数，显然 $g(S)=\sum_{T \subseteq S} f(T)$，由子集反演形式一

$f(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} g(T)$答案即 $f(U)$。只需对 $g(S)$ 计数即可。

用 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号至多使用 $S$ 中所有点的方案数，允许重复。在这个组合意义下，无需枚举子集就有

$dp_{u,i,S}=\prod_{(u,v), u,v \in S} \sum_{(i,j),i,j \in S} dp_{v,j,S}$于是 $g(S)=\sum_{i \in S} dp_{1,i,S}$。复杂度 $O(n^32^n)$。

细节上，这题答案没有取模，可以对 $2^{64}$ 取模，即 unsigned long long 自然溢出。

```cpp
const int N = 18;

int n, m, u, v, a[N][N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
uint64_t dp[N][N];
void dfs(int u, int fa, int s) {
	for (int i = 1; i <= n; i++) {
		if (s >> (i - 1) & 1) dp[u][i] = 1;
	}
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u, s);
		for (int x = 1; x <= n; x++) {
			if (!(s >> (x - 1) & 1)) continue;
			uint64_t cur = 0;
			for (int y = 1; y <= n; y++) {
				if (!(s >> (y - 1) & 1)) continue;
				if (a[x][y]) cur += dp[v][y];
			}
			dp[u][x] *= cur;
		}
	}
}

void _main() {
	cin >> n >> m;
	if (n == 1) return cout << 1, void();
	for (int i = 1; i <= m; i++) cin >> u >> v, a[u][v] = a[v][u] = 1;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	uint64_t res = 0;
	for (int s = 0; s < (1 << n); s++) {
		dfs(1, -1, s);
		uint64_t cur = 0;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) cur += dp[1][i];
		}
		res += ((n - popcount(s)) & 1) ? -cur : cur;
	} cout << res;
}
```
