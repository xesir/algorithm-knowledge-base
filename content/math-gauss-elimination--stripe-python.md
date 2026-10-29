---
id: math-gauss-elimination
title: '高斯消元'
category: '数学'
subcategory: '线性代数'
tags: ['高斯消元', '线性方程组', '异或方程组']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 22. 高斯消元

## 22.1 步骤

高斯消元是用来解线性方程组或异或方程组的一种算法。下面先以线性方程组

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 -3x-y+2z=-11  \\
 -2x+y+2z=-3 
\end{matrix}\right.
$$

为例说明。

我们通过三种基本操作来消元（这些操作保证方程组的解不会改变）：

1. 交换方程位置：例如，把第一个方程和第二个方程互换。
2. 乘以非零常数：例如，将某个方程两边同时乘以 2 或 -3（但不能乘以 0）。
3. 添加一个方程的倍数：例如，把第一个方程的 2 倍加到第二个方程上。

高斯消元有两个步骤，第一步为前向消元（即简化方程组），第二部为回代求解。

### 前向消元

这一步消元后，方程组变成“三角形”形式，即每个方程比前一个少一个变量。我们从上到下逐个变量处理。

- **第一步：在方程 2 和 3 中消去 $x$**
  - 把方程 1 作为最后留下 $x$ 的那个方程，因为 $x$ 的**系数不为 $0$**。
  - 处理方程 2：计算一个倍数使得 $x$ 的系数为 $0$。倍数 $m=\dfrac{-3}{2}=-1.5$，也就是用方程 2 的 $x$ 系数去除以方程 1 的系数。则方程 2 化为 $(-3x-y+2z)-m(2x+y-z)=0.5y+0.5z=-11-8m=1$。为方便讲解这里化为 $y+z=2$。
  - 处理方程 3：仿照上例，将方程 3 的 $x$ 系数化为 $0$。此时，$m=\dfrac{-2}{2}=-1$，方程 3 化为 $( -2x+y+2z)-m(2x+y-z)=2y+z=-3-8m=5$。
  - 现在方程组已经化为

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 y+z=2  \\
 2y+z=5 
\end{matrix}\right.
$$

- **第二步：在方程 3 中消去 $y$**
  - 此步骤忽略方程 1，因为其存在 $x$ 项。
  - 把方程 2 作为最后留下 $y$ 的那个方程，因为 $y$ 的**系数不为 $0$**。
  - 处理方程 3：仿照上例，将方程 3 的 $y$ 系数化为 $0$。此时，$m=\dfrac{2}{1}=2$，方程 3 化为 $(2y+z)-m(y+z)=-z=5-2m=1$。
  - 现在方程组已经化为

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 y+z=2  \\
 -z=1 
\end{matrix}\right.
$$

至此，方程组已被化为“三角形”形式，最后一个方程可直接求得 $z=-1$。

### 回代求解

从最后一个方程开始，逐个求解变量，并代入前一个方程。

比如这里求得 $z=-1$，代入方程 2 得 $y=3$，再代进方程 1 中解得 $x=2$，所以方程组的解为

$$
\left\{\begin{matrix}
 x=2  \\
 y=3  \\
 z=-1 
\end{matrix}\right.
$$

还可以考虑无解 / 无穷多解的情况。无解时，一条方程形如 $0x=c$，其中 $c$ 是不为 $0$ 的常数。而无穷多解则是 $0x=0$ 的形式。

## 22.2 模板

在实现时，通常需要保证选择的主元系数的绝对值尽量大，这样可以减小精度误差。

```plaintext
template <int N>
class GuassSolution {
private:
	int n, m;
	double a[N][N];
public:
	explicit GuassSolution(int _n) : n(_n), m(0) {}
	template <class T> void add(const T& it, double val) {
		for (int i = 0; i < n; i++) a[m][i] = it[i];
		a[m][n] = val, m++;
	}

	template <class T> int solve(T it, double eps = 1e-9) {  // 无解-1，唯一解0，无穷解1
		int ln = 0;
		for (int k = 0; k < n; k++) {  // 消去x_k
			int mx = ln;
			for (int i = ln + 1; i < m; i++) {
				if (abs(a[i][k]) > abs(a[mx][k])) mx = i;
			}  // 找x_k系数不为0的方程
			if (abs(a[mx][k]) < eps) continue;
			for (int j = 0; j <= n; j++) swap(a[ln][j], a[mx][j]);
			for (int i = 0; i < m; i++) {  // 在方程中消去x_k
				if (i == ln) continue;
				double x = a[i][k] / a[ln][k];  // 变系数
				for (int j = k; j <= n; j++) a[i][j] -= a[ln][j] * x;  // 加减消元
			} ln++;
		}
		if (ln < n) {  // 意味着有一条方程的左边为 0
			for (; ln < n; ln++) {
				if (abs(a[ln][n]) > eps) return -1;
			}
			return 1;
		}
		for (int i = 0; i < n; i++) it[i] = a[i][n] / a[i][i];  // 回代求解
		return 0;
	}
};
```

显然可以看出复杂度为 $O(n^2m)$，其中 $n$ 为未知数的个数，$m$ 为方程的条数。

## 22.3 异或方程组

上述过程可以给出线性方程组的数值解法，而若方程形如

$$
\left\{\begin{matrix}
a_{1,1} x_1 \oplus a_{1,2} x_2 \oplus \cdots \oplus a_{1,n} x_n = v_1 \\
a_{2,1} x_1 \oplus a_{2,2} x_2 \oplus \cdots \oplus a_{2,n} x_n = v_2 \\
\cdots \\
a_{m,1} x_1 \oplus a_{m,2} x_2 \oplus \cdots \oplus a_{m,n} x_n = v_m
\end{matrix}\right.
$$

其中 $a_{i,i}, v_i \in \{0,1\}$，则仍然可以使用类似方法解决。具体地，因为异或有结合律、交换律，并且我们还不用乘除来改变系数，直接异或消元就行了。然而异或方程组会出现“自由元”，比如方程组

$$
\left\{\begin{matrix}
x_1 \oplus x_2 = 1 \\
x_2 \oplus x_3 = 1 \\
x_1 \oplus x_3 = 0
\end{matrix}\right.
$$

与线性方程组不同，即使 $n$ 元有 $n$ 个方程也会多解。上述异或方程组逻辑上为：$x_1=x_3$ 且 $x_1 \ne x_2$。于是 $x_3$ 取 $0,1$ 都是可以的。对于这种自由元，我们只能全解完后 dfs 暴力求解。

可以用 bitset 优化，时间复杂度变为 $O(\dfrac{n^2m}{w})$。

## 22.4 例题

### P2455 [SDOI2006] 线性方程组

高斯消元板子。

```cpp
int n, a[N];
double x[N];

void _main() {
	cin >> n;
	GuassSolution<N> sol(n);
	for (int i = 1; i <= n; i++) {
		for (int i = 0; i <= n; i++) cin >> a[i];
		sol.add(a, a[n]);
	}
	int opt = sol.solve(x + 1);
	if (opt == -1) cout << -1;
	else if (opt == 1) cout << 0;
	else {
		for (int i = 1; i <= n; i++) {
			cout << 'x' << i << '=';
			if (abs(x[i]) > 1e-5) cout << fixed << setprecision(2) << x[i] << '\n';
			else cout << 0 << '\n';  // 这里不这样处理的话会出现 -0.00 的输出
		}
	}
}
```

### P4035 [JSOI2008] 球形空间产生器

好像这题沦落为退火板子了（

根据题意列方程，设球心为 $(x_1,x_2,x_3,\cdots,x_n)$，则

$\forall 1 \le i \le n+1, \sum_{j=1}^{n} (a_{i,j}-x_j)^2=r^2$定睛一看是二次方程。这里用到一个 trick，相邻两个方程作差，此时化为 $n$ 元一次方程组，满足

$\forall 1 \le i \le n, \sum_{j=1}^{n} [{a_{i,j}}^2-{a_{i+1,j}}^2-2x_j(a_{i,j}-a_{i+1,j})]=0$化成标准形式

$\forall 1 \le i \le n, \sum_{j=1}^{n} 2x_j(a_{i,j}-a_{i+1,j})=\sum_{j=1}^{n}({a_{i,j}}^2-{a_{i+1,j}}^2)$于是就可以高斯消元解方程组了。

```cpp
const int N = 100;
int n;
double a[N][N], b[N], x[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n + 1; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	GuassSolution<N> sol(n);
	for (int i = 1; i <= n; i++) {
		double v = 0;
		for (int j = 1; j <= n; j++) {
			b[j - 1] = 2.0 * (a[i][j] - a[i + 1][j]);
			v += a[i][j] * a[i][j] - a[i + 1][j] * a[i + 1][j];
		} sol.add(b, v);
	} sol.solve(x);
	for (int i = 0; i < n; i++) cout << fixed << setprecision(3) << x[i] << ' ';
}
```

### *P2011 计算电压

请物竞生来应该能秒掉罢。

考虑用物理知识列方程，由基尔霍夫定律可得流入电流等于流出电流，且根据电压本质是电势差可得

$\sum_{(j, i)} \dfrac{U_j-U_i}{R_{j,i}}=\sum_{(i,k)} \dfrac{U_i-U_k}{R_{i,k}}$用到了欧姆定律 $I=\dfrac{U}{R}$。意义是 $i$ 节点的入边贡献的电流等于出边的总电流，取并集

$\sum_{(i,j)} \dfrac{U_j-U_i}{R_{i,j}}=0$这个式子最大的好处是化边权为点权且无需判断电流方向。

然后我们枚举点 $i$，若它直接连向电源，电压就是给出的值，否则枚举出边列方程，这样是一个 $n$ 元一次方程组，且主元系数均不为 $0$，故一定有解。可以发现复杂度为 $O(n^3+m)$。

```cpp
const int N = 2e5 + 5;

int tot = 0, head[N];
struct Edge {
	int next, to; double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}

int n, m, k, q, u, v, num;
double val, h[N], U0[N], U[N];

void _main() {
	cin >> n >> m >> k >> q;
	GuassSolution<205> sol(n);
	for (int i = 1; i <= k; i++) cin >> u >> U0[u];
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> val;
		add_edge(u, v, val), add_edge(v, u, val);
	}
	for (int u = 1; u <= n; u++) {
		fill(h + 1, h + n + 1, 0);
		if (U0[u] > 0) {
			h[u] = 1, sol.add(h + 1, U0[u]);
		} else {
			for (int j = head[u]; j != 0; j = edge[j].next) {
				int v = edge[j].to; double w = edge[j].dis;
				h[v] += 1.0 / w, h[u] -= 1.0 / w;
			} sol.add(h + 1, 0);
		}
	}
	sol.solve(U + 1);
	while (q--) cin >> u >> v, cout << fixed << setprecision(2) << U[u] - U[v] << '\n';
}
```

### *P2973 [USACO10HOL] Driving Out the Piggies G

概率 DP 经常会有后效性，此时使用高斯消元解决即可。

考虑 DP 结合概率，设 $dp_i$ 表示表示炸弹经过 $i$ 号节点的**期望**次数。那么唯一的转移方法就是从相邻节点继承而来。根据概率的乘法原理，乘上一个不爆炸的概率和一个出边数目的概率。即

$dp_u=\sum_{(v,u)} (1-\dfrac{p}{q}) \dfrac{1}{deg_v} dp_v$注意 $1$ 号节点初始有炸弹，因此 $dp_1 \gets dp_1+1$。

由于这不是树，没有换根 DP 这种东西，而且转移有后效性，可以移项后用高斯消元解方程组。复杂度 $O(n^3)$。

```cpp
const int N = 305, M = 5e4 + 5;
int n, m, p, q, u, v, deg[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[M << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
double a[N], dp[N];

void _main() {
	cin >> n >> m >> p >> q;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v, deg[u]++, deg[v]++;
		add_edge(u, v), add_edge(v, u);
	}
	GuassSolution<N> sol(n);
	for (int u = 1; u <= n; u++) {
		fill(a + 1, a + n + 1, 0.0);
		a[u] = 1.0;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			a[v] = -(1.0 - 1.0 * p / q) / deg[v];
		}
		sol.add(a + 1, u == 1);
	}
	sol.solve(dp + 1);
	for (int i = 1; i <= n; i++) cout << fixed << setprecision(12) << 1.0 * p / q * dp[i] << '\n';
}
```

### P2447 [SDOI2010] 外星千足虫

题意翻译：给出方程组

$$
\left\{\begin{matrix}
a_{1,1} x_1 + a_{1,2} x_2 + \cdots + a_{1,n} x_n \equiv v_1 \pmod 2 \\
a_{2,1} x_1 + a_{2,2} x_2 + \cdots + a_{2,n} x_n \equiv v_2 \pmod 2 \\
\cdots \\
a_{m,1} x_1 + a_{m,2} x_2 + \cdots + a_{m,n} x_n \equiv v_m \pmod 2
\end{matrix}\right.
$$

求方程组的解，并且求最少的方程条数使得方程组有唯一解。

思考一下模 $2$ 意义下的加法，发现这就是异或，于是第一问套用高斯消元即可。考虑第二问，显然至少要 $n$ 个方程才能解出 $n$ 元异或方程组，于是我们先解完 $n$ 个方程，若存在自由元就再加入新方程，直到有唯一解或者方程用完为止。使用 bitset 优化即可通过。

```cpp
const int N = 2005;
int n, m; char c;
bitset<N> a[N];
int v[N], id[N];

int guass() {
	int cnt = 0;
	for (int k = 1; k <= n; k++) {
		int mx = m + 1;
		for (int i = k; i <= m; i++) {
			if (a[i][k] && id[mx] > id[i]) mx = i;
		}
		if (mx == m + 1) return -1;
		cnt = max(cnt, id[mx]);
		swap(a[k], a[mx]), swap(v[k], v[mx]), swap(id[k], id[mx]);
		for (int i = 1; i <= m; i++) {
			if (i != k && a[i][k]) a[i] ^= a[k], v[i] ^= v[k];
		}
	} return cnt;
}

void _main() {
	cin >> n >> m;
	iota(id + 1, id + m + 2, 1);
	for (int i = 1; i <= m; i++) {
		for (int j = 1; j <= n; j++) cin >> c, a[i][j] = c ^ 48;
		cin >> c, v[i] = c ^ 48;
	}
	int h = guass();
	if (h == -1) return cout << "Cannot Determine", void();
	cout << h << '\n';
	for (int i = 1; i <= n; i++) cout << (v[i] ? "?y7M#\n" : "Earth\n");
}
```

### P10499 开关问题

用 $0/1$ 表示第 $i$ 个灯的初始状态 $x_i$，那么若干组关系可以列出一个以 $x_i$ 为主元的异或方程，即与 $i$ 相关联的灯的状态的异或和等于 $i$ 的初始状态。

高斯消元求其自由元个数 $c$，根据乘法原理答案为 $2^c$。无解当且仅当出现了形如 $0=1$ 的方程。可以 bitset 优化。

```cpp
const int N = 35;
int n, x, y, st[N], ed[N];
bitset<N> a[N];

int guass() {
	int cnt = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = i; j <= n; j++) {
			if (a[j][i]) {swap(a[i], a[j]), swap(ed[i], ed[j]); break;}
		}
		for (int j = 1; j <= n; j++) {
			if (i != j && a[j][i]) a[j] ^= a[i], ed[j] ^= ed[i];
		}
	}
	for (int i = 1; i <= n; i++) {
		if (a[i].count()) continue;
		if (ed[i]) return -1;
		cnt++;
	} return cnt;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> st[i];
	for (int i = 1; i <= n; i++) cin >> ed[i], ed[i] ^= st[i];
	for (int i = 1; i <= n; i++) a[i].reset();
	while (cin >> x >> y, x && y) a[y][x] = 1;
	for (int i = 1; i <= n; i++) a[i][i] = 1;
	int x = guass();
	if (x == -1) cout << "Oh,it's impossible~!!\n";
	else cout << (1LL << x) << '\n';
}
```
