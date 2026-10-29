---
id: math-binomial-inversion
title: '二项式反演'
category: '数学'
subcategory: '组合数学'
tags: ["二项式反演","组合数学","容斥","计数"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
这部分内容摘自 [OI 中的数学基础](https://stripepython.github.io/2025/08/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)中组合数学部分，将并入之后更新的第二版内容。

OI 中的数学基础の[洛谷链接](https://www.luogu.com.cn/article/bhxqoy6g)。

如果某些计数问题的限制是“某些物品恰好若干个”，就可以考虑使用二项式反演。

## 原理

设 $f_n$ 表示恰好使用 $n$ 个不同元素形成特定结构的方案数，$g_n$ 表示从这 $n$ 个不同元素中选出若干个元素形成特定结构的方案数。

已知 $f_n$ 求 $g_n$ 是简单的，枚举选出多少个元素有

$g_n=\sum_{i=0}^{n} C_n^i f_i$反着做却是困难的，这个过程就叫**二项式反演**。有公式：

$f_n=\sum_{i=0}^{n} C_n^i (-1)^{n-i}g_i$二项式反演的作用就是把“恰好”转化为“钦定”。

组合意义上，考虑容斥原理，思考一下每个集合被重复计算几次可以感性理解。下面给出严谨的代数推导。

我们先给出一个引理

$C_n^r C_r^k=C^k_n C^{r-k}_{n-k}$组合意义和代数推导都易证。

把上述式子展开：

$$
\begin{aligned}
f_n&=\sum_{i=0}^{n} C_n^i (-1)^{n-i} [\sum_{j=0}^{i} C_i^j f_j]\\
&=\sum_{i=0}^{n} \sum_{j=0}^{i} C_n^i C_i^j (-1)^{n-i} f_j \\
&= \sum_{j=0}^{n} \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} f_j \\
&= \sum_{j=0}^{n} [f_j \times \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} ]
\end{aligned}
$$

根据引理可得

$$
\begin{aligned}
f_n&=\sum_{j=0}^{n} [f_j \times \sum_{i=j}^{n} C_n^j C_{n-j}^{i-j} (-1)^{n-i} ]\\
&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{i=j}^{n}C_{n-j}^{i-j} (-1)^{n-i} ]\\
\end{aligned}
$$

作换元，令 $k=i-j$，则 $i=k+j$，即有

$$
\begin{aligned}
f_n&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k} ]\\
&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k ]
\end{aligned}
$$

根据二项式定理，当且仅当 $n=j$ 时 $\sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k$ 为 $1$，故：

$f_n=f_n$上述操作均为等价变换，证毕。

下面我们给出二项式反演的全部形式：

$$
\begin{aligned}
&f(n)=\sum_{i=0}^n (-1)^iC_n^i g(i) \Leftrightarrow g(i)=\sum_{i=0}^n (-1)^i C_n^i f(i)\\
&f(n)=\sum_{i=n}^m C_m^ig(i) \Leftrightarrow g(n)=\sum_{i=n}^m (-1)^{m-i} C_m^i f(i)\\
&f(n)=\sum_{i=n}^m C_n^i g(i) \Leftrightarrow g(n)=\sum_{i=n}^m (-1)^{i-n} C_n^i f(i)
\end{aligned}
$$

## 例题

## AT_abc423_f [ABC423F] Loud Cicada

设 $g_x$ 表示钦定 $x$ 种蝉爆发的方案数。状压枚举集合 $S$，则

$g_x=\sum _{\operatorname{popcount}(S) = x} \lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$解释一下，对于集合 $S$ 中的所有元素 $i$，求出 $a_i$ 的最小公倍数，则集合 $S$ 中的所有蝉爆发的充要条件就是年份为最小公倍数的倍数。在 $Y$ 以内共有 $\lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$ 个年份。

然后做二项式反演：

$f_m=\sum_{i=m}^{n} C_m^i (-1)^{i}g_i$复杂度 $O(n2^n)$，杨辉三角 $O(n^2)$ 预处理组合数即可。注意 $\operatorname{lcm}$ 最好开个 `__int128`。

```cpp
#define popcount __builtin_popcount
const int N = 25;
int n, m;
long long y, a[N], g[N], c[N][N];

void _main() {
	cin >> n >> m >> y;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (int s = 0; s < (1 << n); s++) {
		__int128 x = 1;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) x = x / __gcd<__int128>(x, a[i]) * a[i];
			if (x > y) break;  // 注意这句
		} g[popcount(s)] += y / x;
	}
	long long res = 0;
	for (int i = m; i <= n; i++) {
		if ((m - i) & 1) res -= c[i][m] * g[i];
		else res += c[i][m] * g[i];
	} cout << res;
}
```

## P10596 BZOJ2839 集合计数

看到不好求的“恰好”，考虑二项式反演。设 $f_i$ 表示交集大小恰好为 $i$ 的方案数，$g_i$ 表示钦定 $i$ 个元素属于交集的方案数。

那么对于 $g_i$，先从 $n$ 个元素中选出 $i$ 个，方案数 $C_n^i$。剩下 $n-i$ 个元素可选可不选，就是求大小为 $2^{n-i}$ 的集合的非空子集数，答案为 $2^{2^{n-i}}-1$，乘法原理：

$g_i=C_n^i (2^{2^{n-i}}-1)$上二项式反演：

$f_k=\sum_{i=k}^{n}(-1)^{i-k} C_i^k g_i$复杂度 $O(n \log n)$。注意求 $g_i$ 要用欧拉定理。

```cpp
const int N = 1e6 + 5;
mint fac[N], ifac[N], g[N];
mint C(int n, int m) {
	return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];
}
int n, k;
void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 0; i <= n; i++) g[i] = C(n, i) * (mint(2).pow(mod32<1000000006>(2).pow(n - i).val) - 1);
	mint res = 0;
	for (int i = k; i <= n; i++) {
		if ((i - k) & 1) res -= C(i, k) * g[i];
		else res += C(i, k) * g[i];
	} cout << res;
}
```

## P4859 已经没有什么好害怕的了

形式化题意：给出长为 $n$ 的序列 $a,b$，将其两两配对使得 $a_i>b_i$ 的数目减去 $a_i<b_i$ 的数目恰为 $k$，求方案数。

设 $a_i>b_i$ 的数量为 $m$，则 $m-(n-m)=k$，解得 $m=\dfrac{n+k}{2}$。若 $2 \nmid (n+k)$，直接判定无解。此时问题变成 $a_i>b_i$ 的数目**恰好**为 $m$。考虑使用二项式反演化恰好为钦定。设 $g_i$ 为 $a_i>b_i$ 的组数不小于 $i$ 的方案数，根据二项式反演所求为

$\sum_{i=m}^{n} (-1)^{i-m} C_{i}^k g_i$现在的问题就是求 $g_i$，这玩意很 DP，所以设 $dp_{i,j}$ 表示前 $i$ 个数中选出 $j$ 组 $a_i>b_i$ 的方案数。DP 题套路对 $a,b$ 排序，然后可以推出转移方程

$dp_{i,j}=dp_{i-1,j}+(last_i-j+1)dp_{i-1,j-1}$从插入角度考虑 $(a_i,b_i)$ 的贡献，一种情况是不作为新的 $a_i>b_i$，还有一种就是考虑有多少个取代位置。设 $last_i$ 表示 $b$ 序列中第一个小于 $a_i$ 的数的下标，则插入位置就有 $last_i-j+1$ 个，加法原理合并答案。

于是我们 $O(n^2)$ 求出 $dp_{i,j}$。考察 $g_i$ 的定义可得

$g_i=dp_{n,i}\times  (n-i)!$就是在有序的 dp 基础上考虑剩下 $n-i$ 个全排列。

二项式反演中组合数可以逆元法来求，总复杂度 $O(n^2)$。

```cpp
const int N = 2005;
int n, m, k, a[N], b[N], last[N];
mint fac[N], ifac[N], dp[N][N], g[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n >> k;
	if ((n + k) & 1) return cout << 0, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];

	m = (n + k) / 2;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	sort(a + 1, a + n + 1), sort(b + 1, b + n + 1);
	for (int i = 1; i <= n; i++) last[i] = lower_bound(b + 1, b + n + 1, a[i]) - b - 1;
	dp[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		dp[i][0] = dp[i - 1][0];
		for (int j = 1; j <= i; j++) {
			dp[i][j] = dp[i - 1][j] + dp[i - 1][j - 1] * max(0, last[i] - j + 1);
		}
	}
	for (int i = 0; i <= n; i++) g[i] = dp[n][i] * fac[n - i];
	mint res = 0;
	for (int i = m; i <= n; i++) {
		if ((i - m) & 1) res -= C(i, m) * g[i];
		else res += C(i, m) * g[i];
	} cout << res;
}
```

## P6478 [NOI Online #2 提高组] 游戏

“恰好 $k$ 次非平局”很难处理，不妨转为“钦定 $k$ 次非平局”。设恰好 $k$ 次非平局的方案数为 $g(k)$，钦定 $k$ 次非平局的方案数为 $f(k)$，显然有 $f(n)=\sum_{i=n}^m C_i^n g(i)$，根据二项式反演：

$g(n)=\sum_{i=n}^m (-1)^{i-n} C_i^n f(i)$考虑求 $f(i)$ 即可。考虑树形 DP，设 $dp_{u,i}$ 表示在以 $u$ 为根的子树中钦定 $i$ 个点且必须有胜负的方案数。

考虑对于儿子 $v$ 枚举在 $v$ 中选择 $j$ 个点，有转移：

$dp_{u,i}=\sum_{(u,v)} \sum_{j =0}^i dp_{v,j}dp_{u,i-j}$还可以选择一个点与 $u$ 配对，于是：

$dp_{u,i} \gets dp_{u,i}+dp_{u,i-1}+cnt_{u,x \oplus 1}$其中 $x$ 为点 $u$ 属于哪位玩家，$cnt_{u,0/1}$ 表示以 $u$ 为根的子树中有多少个属于 $0/1$ 玩家。

这是一个树形背包，且应该跑 01 背包。根据树形背包的复杂度证明，复杂度是严格 $O(n^2)$ 的。

这样有 $g(i)=dp_{1,i}\times (m-i)!$。求出来以后套进二项式反演即可。

```cpp
const int N = 5005;
int n, m, u, v, belong[N];
char c;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
mint f[N], g[N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int sz[N], cnt[2][N];
mint dp[N][N];
void dfs(int u, int fa) {
	sz[u] = 1, cnt[belong[u]][u] = 1, dp[u][0] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		vector<mint> f(min(sz[u] + sz[v], m), 0);
		for (int j = 0; j <= min(sz[u], m); j++) {
			for (int k = 0; k <= min(sz[v], m - j); k++) {
				f[j + k] += dp[u][j] * dp[v][k];
			}
		}
		sz[u] += sz[v], cnt[0][u] += cnt[0][v], cnt[1][u] += cnt[1][v];
		copy(f.begin(), f.end(), dp[u]);
	}
	for (int i = cnt[belong[u] ^ 1][u]; i >= 0; i--) {
		dp[u][i + 1] += dp[u][i] * (cnt[belong[u] ^ 1][u] - i);
	}
}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n, m = n / 2;
	for (int i = 1; i <= n; i++) cin >> c, belong[i] = c ^ 48;
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
	}
	dfs(1, -1);
	for (int i = 0; i <= m; i++) g[i] = dp[1][i] * fac[m - i];
	for (int i = 0; i <= m; i++) {
		for (int j = i; j <= m; j++) {
			if ((j - i) & 1) f[i] -= C(j, i) * g[j];
			else f[i] += C(j, i) * g[j];
		}
		cout << f[i] << '\n';
	}
}
```

## 总结

二项式反演的主要作用就是把“恰好”变成“至少 / 至多”，也就是上文所述的“钦定”。

一般二项式反演适用于“恰好”很难做，而“钦定”比较好做的情况。对于“钦定”这一部分，往往要结合计数 DP 的方法求解。


## 附：二项式反演与子集反演（《OI 中的计数基础》· stripe-python）

### 2.1 二项式反演

记全集为 $U$，元素共有 $n$ 种属性，具有第 $i$ 种属性的元素构成集合 $S_i$。现在我们希望计算**恰好**有 $k$ 种属性的元素数目。

我们记
$$
g(k)=\sum \left|\bigcap\limits_{i=1}^k S_{p_i} \right|
$$
组合意义仍然是**钦定至少**。记 $f(k)$ 恰好有 $k$ 种属性的元素数目。那么朴素容斥给出
$$
f(0)=\sum_{i=0}^n (-1)^i g(i)
$$
对于一个元素 $x \in U$，设其具有的属性集合为 $A$，则其被钦定方式 $B$ 算到当且仅当 $B \subseteq A$。因此有
$$
g(k)=\sum_{i=k}^n \binom{i}{n} f(i)
$$
但是我们希望由 $g$ 计算出 $f$。从知 $f$ 求 $g$ 的过程转化到知 $g$ 求 $f$ 的过程叫做反演。而**二项式反演**给出如下结论
$$
g(k)=\sum_{i=k}^n \binom{i}{k} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k}\binom{i}{k} g(i)
$$
根据这个式子，我们就得到了**钦定至少**和**恰好**间的相互转化。$(-1)^{i-k} \dbinom{i}{k}$ 是这一转化的容斥系数。

从线性代数的观点来看，每个 $g$ 都可以写成若干 $f$ 的线性组合，因此反演的本质就是 $\mathbf{G}=A\mathbf{F} \iff \mathbf{F}=A^{-1} \mathbf{G}$。其中 $\mathbf{F},\mathbf{G}$ 为向量，$A$ 为系数矩阵。在二项式反演中，$A$ 恰好是杨辉三角。

我们给出二项式反演的全部形式：

- 形式零：

$$
g(k)=\sum_{i=0}^k (-1)^i\binom{k}{i} f(i) \iff f(k)=\sum_{i=0}^k (-1)^i \binom{k}{i} g(i)
$$

- 形式一：

$$
g(k)=\sum_{i=0}^k \binom{k}{i} f(i) \iff f(k)=\sum_{i=0}^k (-1)^{k-i} \binom{k}{i} g(i)
$$

- 形式二：

$$
g(k)=\sum_{i=k}^n \binom{i}{k} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k}\binom{i}{k} g(i)
$$

形式一是**钦定至多**与**恰好**的转化，形式二是**钦定至少**与**恰好**的转化。

### 2.2 子集反演

对于两个以集合为自变量的函数 $f,g$，**子集反演**给出如下结论：
$$
f(S)=\sum_{T \subseteq S} g(T) \iff g(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} f(T)
$$
同取补集可以得到另一个形式，称为**超集反演**：
$$
f(S)=\sum_{S \subseteq T} g(T) \iff g(S)=\sum_{S \subseteq T} (-1)^{|T|-|S|} f(T)
$$
子集反演实现了**钦定子集  / 超集**与**恰好**的转化，$(-1)^{|S|-|T|}$ 是这一转化的容斥系数。从集合幂级数的角度看，子集反演给出了高维差分的式子。

二项式反演可以看做子集反演的一个特例。
