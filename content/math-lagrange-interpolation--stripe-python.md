---
id: math-lagrange-interpolation
title: '插值法（Lagrange / Newton）'
category: '数学'
subcategory: '数学基础'
tags: ['插值', 'Lagrange 插值', 'Newton 插值']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 24. 插值法

## 24.1 引入

Q: 找规律：$1,2,3$，填下一项。

A: 填 $114514$。因为 $f(x)=19085x^3-114510x^2+209936x-114510$ 在 $x=1,2,3,4$ 处的取值分别为 $1,2,3,114514$。

如何找到这个多项式就是插值要解决的问题。形式化地，多项式插值的一般形式如下：

给你 $n+1$ 个点 $(x_0,y_0),(x_1,y_1),(x_2,y_2),\cdots,(x_n,y_n)$，求多项式 $f(x)=\sum_{i=0}^n a_i x^i$ 满足

$\forall i=[0,n] \cap \mathbb{N}, f(x_i)=y_i$显然我们有一个列出 $n$ 条方程然后高斯消元的 $O(n^3)$ 做法。而下文介绍的插值法其实是一种构造思想，可以在 $O(n^2)$ 的复杂度内解决问题。甚至使用多项式科技可以做到 $O(n \log^2 n)$。

## 24.2 Lagrange 插值法

- 优点：复杂度 $O(n^2)$，可以优化到 $O(n \log^2 n)$。处理横坐标是连续整数的插值时有 $O(n)$ 复杂度。
- 缺点：求多项式的系数比较麻烦。

Lagrange 插值的核心是构造 $n$ 个基函数 $L_i(x)$，使得每个基函数在对应的数据点取值为 $1$，其他点取值为 $0$，于是

$f(x)=\sum_{i=0}^n y_i L_i(x)$考虑如何构造 $L_i(x)$。不妨设 $L_i(x)=\prod_{j \ne i} (x-x_j)$，代入 $(x_i,y_i)$ 解得

$L_i(x)=\prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}$综上得到 Lagrange 插值公式为

$f(x)=\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}$显然是一个 $O(n^2)$ 的过程。下面给出的板子来自 OI-Wiki，可以通过秦九韶算法求出 $f(x)$ 的各项系数。

```cpp
int n;
mint x[N], y[N], f[N], m[N], px[N];
void lagrange_interp() {
	m[0] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = i; j >= 0; j--) m[j + 1] += m[j], m[j] *= -x[i];
	}
	for (int i = 0; i <= n; i++) {
		px[i] = 1;
		for (int j = 0; j <= n; j++) {
			if (i != j) px[i] *= x[i] - x[j];
		}
	}
	for (int i = 0; i <= n; i++) {
		mint t = y[i] / px[i], k = m[n + 1];
		for (int j = n; j >= 0; j--) f[j] += k * t, k = k * x[i] + m[j];
	}
}
```

这里还有一个讲的很好的[视频](https://www.bilibili.com/video/BV1TR4y1j745/)，从 CRT 的角度来推导 Lagrange 插值。

## *24.3 Newton 插值法

- 优点：支持 $O(n)$ 插入新数据点。
- 缺点：复杂度无法优化，不适合处理横坐标是连续整数的插值。

Newton 插值法基于这样一个事实：$f(x)$ 的 $n$ 阶差分会变成一个常数数列。

我们给出的这 $n$ 个数据点本质上其实描述了一个离散的函数。在离散函数上，仿照连续函数的导数定义其微分：

$f'(x)=\dfrac{f(x+1)-f(x)}{1}$可以发现这就是差分。一般地，Newton 插值公式为

$F_n=\sum_{i} C_n^i \Delta^i F_i$实际上把组合数拆成下降幂，你就得到了离散泰勒展开。

下面给出的板子还是从 OI-Wiki 抄的，能够支持 $O(n)$ 插入新数据点，不过常数比 Lagrange 插值略大。

```cpp
template <class T>
class NewtonInterp {
private:
	vector<pair<T, T>> pos;
	vector<vector<T>> dy;
	vector<T> base;
public:
	vector<T> poly;

	void insert(const T& x, const T& y) {
		pos.emplace_back(x, y);
		int n = pos.size();
		if (n == 1) base.emplace_back(1);
		else {
			int m = base.size();
			base.emplace_back(0);
			for (int i = m; i >= 0; i--) base[i] = i >= 1 ? base[i - 1] : 0;
			for (int i = 0; i < m; i++) base[i] -= pos[n - 2].first * base[i + 1];
		}
		dy.emplace_back(pos.size());
		dy[n - 1][n - 1] = y;
		for (int i = n - 2; i >= 0; i--) dy[n - 1][i] = (dy[n - 2][i] - dy[n - 1][i + 1]) / (pos[i].first - pos[n - 1].first);
		poly.emplace_back(0);
		for (int i = 0; i < n; i++) poly[i] += dy[n - 1][0] * base[i];
	}
};
```

需要注意，本质上 Newton 插值和 Lagrange 插值得到的多项式是一样的，只是构造方法不同。

## 24.4 例题

### CF622F The Sum of the k-th Powers

这个题还有一种做法是使用第二类 Stirling 数的拆幂公式，配合多项式科技解决。下面介绍 Lagrange 插值做法。

设 $f(n)=\sum_{i=1}^n i^k$。观察样例可得 $f(n)$ 是关于 $n$ 的 $k+1$ 次多项式。考虑插值确定这个多项式的系数。我们需要取 $k+2$ 个点才能插值，如果暴力做复杂度为 $O(k^2)$，无法通过。

由于点是任取的，考虑横坐标是连续整数的 Lagrange 插值。写出插值公式

$f(n)=\sum_{i=0}^{k+2} y_i \prod_{j \ne i} \dfrac{n-x_j}{x_i-x_j}$横坐标是连续整数时

$f(n)=\sum_{i=0}^{k+2} y_i \prod_{j \ne i} \dfrac{n-j}{i-j}$记 $p_i=\prod_{j=1}^i (n-j),s_i=\prod_{j=i}^{k+2}(n-j)$，即 $n-j$ 的前、后缀积，代入上式得

$f(n)=\sum_{i=0}^{k+2} (-1)^{k-i+2} y_i \times \dfrac{p_{i-1} s_{i+1}}{(i-1)! (k-i+2)!}$ $y_i$ 可以 $O(k)$ 递推出来，至此可以 $O(k \log k)$ 解决。

```cpp
const int N = 1e6 + 5;
int n, k;
mint a[N], p[N], s[N], fac[N];

void _main() {
	cin >> n >> k;
	fac[0] = 1, p[0] = 1, s[k + 3] = 1;
	for (int i = 1; i <= k + 2; i++) {
		fac[i] = fac[i - 1] * i;
		a[i] = a[i - 1] + mint(i).pow(k);
		p[i] = p[i - 1] * (n - i);
	}
	for (int i = k + 2; i >= 1; i--) s[i] = s[i + 1] * (n - i);
	if (n <= k + 2) return cout << a[n], void();
	mint res = 0;
	for (int i = 1; i <= k + 2; i++) {
		if ((k + 2 - i) & 1) res -= a[i] * p[i - 1] * s[i + 1] / fac[i - 1] / fac[k + 2 - i];
		else res += a[i] * p[i - 1] * s[i + 1] / fac[i - 1] / fac[k + 2 - i];
	} cout << res;
}
```

### *P5437 【XR-2】约定

考虑拆贡献，每条边的出现次数均为

$n^{n-2} \times (n-1) \times \dfrac{n(n-1)}{2}=2n^{n-3}$答案即为

$$
\begin{aligned}
ans&=\dfrac{2n^{n-3} \sum_{i=1}^n \sum _{j=i+1}^n (i+j)^k}{n^{n-2}}\\
&=\dfrac{2}{n} \times \left(\sum_{i=1}^n \sum _{j=i+1}^n (i+j)^k \right) \\
&=\dfrac{2}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - \sum_{i=1}^n (2i)^k \right) \\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - 2^k\sum_{i=1}^n i^k \right)
\end{aligned}
$$

后面那个可以 $O(k)$ 解决。考虑转为枚举每个 $i+j$ 的出现次数：

$$
\begin{aligned}
ans&=\dfrac{1}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - 2^k\sum_{i=1}^n i^k \right)\\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n (i-1)i^k+\sum_{i=n+1}^{2n}(2n+1-i)i^k- 2^k\sum_{i=1}^n i^k \right)\\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n i^{k+1}-\sum_{i=1}^n i^k+(2n+1) \sum_{i=n+1}^{2n} i^k-\sum_{i=n+1}^{2n} i^{k+1}- 2^k\sum_{i=1}^n i^k \right)
\end{aligned}
$$

至此我们只需知道 $f(n)=\sum_{i=1}^{n} i^k$ 在 $n,2n$ 处的值。用线性筛筛出 $i^k$ 后使用上题的做法可做到 $O(k)$。

### *P8290 [省选联考 2022] 填树

这题真的没黑吗。

先转化一下题意：就是让一条链权值不为 $0$。

考虑朴素 DP。枚举路径最小值 $x$，则每个点的点权区间为 $[x,x+k]$，跑一个树形 DP。注意到必须钦定一个最小值，不然会使得最小值 $>x$。需要一个高维容斥，对于每个 $[x,x+k]$ 都容斥掉 $[x+1,x+k]$ 的答案。

设 $f_{0/1,u}$ 表示 $u$ 子树内部的方案数，$0/1$ 表示是否要求链以 $u$ 为端点。$g_{0/1,u}$ 表示 $u$ 子树内部的权值和，$0/1$ 同理。

设 $u$ 上的合法区间为 $[l',r']$，可得到 $[l',r']=[x,x+k] \cap [l_u,r_u]$，并记 $s=r'-l'+1$。于是有

$f_{1,u}=s+\sum_{(u,v)} f_{1,v} \times s$对于 $g_{1,u}$ 拆开点 $u$ 的贡献和 $v$ 子树的贡献，同时加法原理合并该点开始的贡献。得到

$g_{1,u}=\dfrac{s(s+1)}{2}+s(l'-1)+\sum_{(u,v)} g_{1,v} \times  s+f_{1,u} \times [\dfrac{s(s+1)}{2}+s(l'-1)]$考虑 $f_{0,u}$，可以讲链拆成三段，即左段、当前节点、右段，然后乘法原理合并答案：

$f_{0,u}=s+\sum_{(u,v)} (1+\sum_p f_{1,p}) \times f_{1,v}\times s$对于 $g_{0,u}$，拆贡献得到三部分：$v$ 子树向上的贡献，$u$ 的贡献，$v$ 的历史贡献。加法原理合并答案：

$g_{0,u}=\dfrac{s(s+1)}{2}+s(l'-1)+\sum_{(u,v)} (1+\sum_{p} f_{1,p})[s \times g_{1,v}+(\dfrac{s(s+1)}{2}+s(l'-1)) f_{1,v}]+\sum_{p} g_{1,p} \times f_{1,v}\times s$分别做完这四个转移，复杂度 $O(nV^2)$。注意到 $\sum_p$ 的部分可以前缀和优化，复杂度 $O(nV)$。历尽千辛万苦获得了 20pts。

考虑链的情况，此时 $l',r'$ 为定值，总方案数为

$\prod_{i=1}^n (r'-l'+1)$权值和为

$\sum_{i=1} [\dfrac{w(w+1)}{2}+w(l'-1)] \times \prod_{j\ne i} (r'-l'+1)$设 $x$ 是链内一点。注意到，$l',r'$ 为关于 $x$ 的一次多项式，$\dfrac{w(w+1)}{2}$ 为关于 $x$ 的二次多项式。总方案数、权值和是关于 $x$ 的 $n,n+1$ 次多项式。树可以拆成若干条链得到这个结论。

在每一个分段内，答案都是关于 $x$ 的多项式，答案的总和就是前缀和的末元素。考虑找到 $O(n)$ 个点暴力 DP 再前缀和，直接得到了答案前缀和的若干点值，代入 Lagrange 插值公式，我们惊喜地发现这个方法绕开了值域限制。

总复杂度 $O(n^3)$，需要离散化等，细节较多。代码中的 `discrete_map` 是一个离散化的工具，[源码](https://www.luogu.me/paste/husimzif)。

```cpp
const int N = 205;
int n, k, l[N], r[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
discrete_map<int, N << 2> mp;

mint f[2][N], g[2][N];
void dfs(int u, int fa, int ql, int qr) {
	int l0 = max(ql, l[u]), r0 = min(qr, r[u]);
	if (l0 > r0) l0 = 1, r0 = 0;
	int s = r0 - l0 + 1;
	mint h = 1LL * r0 * (r0 + 1) / 2 - 1LL * l0 * (l0 - 1) / 2;
	f[0][u] = f[1][u] = s, g[0][u] = g[1][u] = h;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u, ql, qr);
		f[0][u] += f[1][u] * f[1][v];
		g[0][u] += g[1][v] * f[1][u] + f[1][v] * g[1][u];
		f[1][u] += f[1][v] * s;
		g[1][u] += g[1][v] * s + f[1][v] * h;
	}
}
void solve(mint w, int ql, int qr, mint& ans1, mint& ans2) {
	dfs(1, -1, ql, qr);
	for (int i = 1; i <= n; i++) ans1 += w * f[0][i], ans2 += w * g[0][i];
}

mint a[N << 2], b[N << 2], c[N << 2];
mint lagrange(int n, mint x0, mint *x, mint *y) {
	mint res = 0;
	for (int i = 0; i < n; i++) {
		mint a = 1, b = 1;
		for (int j = 0; j < n; j++) {
			if (i != j) a *= x0 - x[j], b *= x[i] - x[j];
		} res += a / b * y[i];
	} return res;
}

void _main() {
	cin >> n >> k;
	int v = 0;
	for (int i = 1; i <= n; i++) {
		cin >> l[i] >> r[i], v = max(v, r[i] + 1);
		mp.add(l[i]), mp.add(r[i]), mp.add(max(0, l[i] - k)), mp.add(max(0, r[i] - k));
	}
	mp.add(v), mp();
	for (int i = 1, u, v; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	mint res1 = 0, res2 = 0;
	for (int i = 1; i < mp.width; i++) {
		int ql = mp.value(i), qr = ql + k, j = 0;
		for (; j <= n + 1; j++, qr++) {
			if (mp.value(i) + j == mp.value(i + 1)) break;
			solve(1, ql, qr, res1, res2), solve(-1, ++ql, qr, res1, res2);
			a[j] = mp.value(i) + j, b[j] = res1, c[j] = res2;
		}
		if (mp.value(i) + j < mp.value(i + 1)) {
			res1 = lagrange(j, mp.value(i + 1) - 1, a, b);
			res2 = lagrange(j, mp.value(i + 1) - 1, a, c);
		}
	} cout << res1 << '\n' << res2;
}
```
