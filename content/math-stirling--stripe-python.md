---
id: math-stirling
title: '斯特林数与贝尔数'
category: '数学'
subcategory: '组合数学'
tags: ['斯特林数', '贝尔数', '第二类斯特林数', '多项式']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 14. Stirling 数

## 14.1 第二类 Stirling 数

**第二类 Stirling 数** $S(n,k)$ 表示将 $n$ 个不同元素分为 $k$ 个互不区分的非空**子集**的方案数。

第二类 Stirling 数有递推计算和通项计算两种计算方法。

### 14.1.1 递推公式

考虑到第 $n$ 个元素时，有两种方案：

1. 将第 $n$ 个元素单独放一个新子集，方案数为 $S(n-1,k-1)$；
2. 将第 $n$ 个元素放一个已有子集，方案数为 $k \times S(n-1,k)$。

由加法原理得：

$S(n,k)=S(n-1,k-1)+k \times S(n-1,k)$### *13.1.2 通项公式

$S(n,k)=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$可以发现一个卷积形式

$S(n,k)=\sum_{i+j=k} \dfrac{i^n}{i!} \times \dfrac{(-1)^j}{j!}$因此 $S(n,k)$ 可以看作两个多项式相乘的第 $k$ 项。使用 NTT 等技术，可以在 $O(n \log n)$ 内求出同行第二类 Stirling 数。

#### 证明

发现这个东西长的像二项式反演的式子，故设将 $n$ 个不同元素划分到 $i$ 个不同**可空**集合的方案数为 $g_i$，将 $n$ 个不同元素划分到 $i$ 个不同**非空**集合的方案数为 $g_i$。由乘法原理易得

$g_i=i^n$枚举选出多少个元素 $j$，则

$g_i=\sum_{j=0}^{i} C_i^j f_j$这是二项式反演的标准形式。由二项式反演

$$
\begin{aligned}
f_i&=\sum_{j=0}^{i} (-1)^{i-j} C_i^j g_j\\
&=\sum_{j=0}^{i} (-1)^{i-j} C_i^j j^n\\
&=\sum_{j=0}^{i} \dfrac{i!(-1)^{i-j}j^n}{j!(i-j)!}
\end{aligned}
$$

得到了 $f_i$ 的通项公式。因为 $S(n,i)$ 中的子集互不区分，所以 $f_i$ 在 $S(n,i)$ 的基础上作了全排列，即 $f_i=i! \times S(n,i)$，所以

$S(n,k)=\dfrac{f_k}{k!}=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$## 14.2 第一类 Stirling 数

**第一类 Stirling 数** $s(n,k)$ 表示将 $n$ 个不同元素分为 $k$ 个互不区分的非空**环形排列**的方案数。

第一类 Stirling 数可通过递推计算。考虑到第 $n$ 个元素时，仍有两种方案：

1. 将第 $n$ 个元素单独放一个新环，方案数为 $s(n-1,k-1)$；
2. 将第 $n$ 个元素放一个已有环，方案数为 $(n-1) \times s(n-1,k)$。

由加法原理得：

$s(n,k)=s(n-1,k-1)+(n-1) \times s(n-1,k)$第一类 Stirling 数没有实用的通项公式。

## *14.3 Stirling 反演

有如下两种 **Stirling 反演**：

$$
f_n=\sum_{i=0}^{n} S(n,i) g_i \Leftrightarrow g_n=\sum_{i=0}^n (-1)^{n-i} s(n,i) f_i\\
f_n=\sum_{i=0}^{n} s(n,i) g_i \Leftrightarrow g_n=\sum_{i=0}^n (-1)^{n-i} S(n,i) f_i
$$

这说明了第一类 Stirling 数与第二类 Stirling 数的相互联系。

## 14.4 应用

### *14.4.1 上升幂

定义**上升幂** $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod_{i=0}^{n-1} (x+i)$，有

$x^{\overline n} =\sum_{k} s(n,k) \times x^k$使用递推公式归纳即可。应用 Stirling 反演可得

$x^n=\sum_{k} (-1)^{n-k} S(n,k) \times x^{\overline k }$### *14.4.2 下降幂

定义**下降幂** $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod _{i=0}^{n-1} (x-i)$，有

$x^{n}=\sum_{k} S(n,k) \times x^{\underline k}$同样归纳可得。应用 Stirling 反演可得

$x^{\underline n}=\sum_{k}(-1)^{n-k} s(n,k) x^k$可以发现，$x^{\underline n}=\dfrac{x!}{(x-n)!}=A_{x}^{n}$。

### 14.4.3 常用性质

1. 同行第一类 Stirling 数的和：

$\sum_{k=0}^ n s(k,n)=n!$考虑环形排列的组合意义可证。同行第二类 Stirling 数的和见下文 14.2。

1. 拆幂公式：

$x^{n}=\sum_{k} S(n,k) \times x^{\underline k}=\sum_{k} S(n,k) \times k! \times C_n^k$相当常用的公式，适用于幂求和的题目。这个公式说明了第二类 Stirling 数与组合数的关系。

1. 递推公式 2：

$S(n+1,k+1)=\sum_{i=k}^n C_n^i S(i,k)$考虑组合意义，$n+1$ 个元素分到 $k+1$ 个子集中。枚举第 $n+1$ 个元素和哪些元素在一个子集，剩下的分出 $i$ 个子集。

## 14.5 例题

### P1655 小朋友的球

这是第二类 Stirling 数的板子，但是需要高精度，代码：

```cpp
const int N = 105;
int n, m;
BigInteger s[N][N];

void _main() {
	s[0][0] = 1;
	for (int i = 1; i < N; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	}
	while (cin >> n >> m) cout << s[n][m] << '\n';
}
```

### B3801 [NICA #1] 乘只因

题里给的条件就是：

$\prod_{i=1}^{k} a_i = \operatorname{lcm}_{i=1}^{k} a_i =n$因为 $\operatorname{lcm}_{i=1}^{k}=\dfrac{\prod_{i=1}^{k} a_i}{\gcd_{i=1}^{k} a_i}$，所以 $\gcd_{i=1}^{k} a_i=1$，而且又说了 $a$ 单调不降，就是说 $a$ 序列两两互质。对 $n$ 分解质因数得 $n=p_1^{a_1} p_2^{a_2} \cdots$，发现若 $a_x \ne 0$，则这些 $p_x$ 只能被分配到同一个 $a_i$ 中。记有 $c$ 个不同质因子，然后你发现这是把 $c$ 个元素划成 $k$ 个子集的方案数，即第二类 Stirling 数。

实现细节上，注意特判掉 $c<k$ 的情况。

```cpp
int n, k;
int decompose(int n) {
	int m = 0;
	for (int i = 2; i * i <= n; i++) {
		if (n % i) continue;
		m++;
		while (n % i == 0) n /= i;
	}
	if (n > 1) m++;
	return m;
}

long long s[15][15];

void _main() {
	cin >> n >> k;
	int m = decompose(n);
	cout << (m < k ? 0 : s[m][k]) << '\n';
} signed main() {
	s[0][0] = 1;
	for (int i = 1; i < 15; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	int t = 1; for (cin >> t; t--; ) _main();
}
```

### *P4609 [FJOI2016] 建筑师

单调栈经典模型。 首先高度为 $n$ 的建筑肯定不会被挡，用它将建筑划分为两段，左边的看不到右边，右边的看不到左边。

推广一下，把 $n$ 的建筑分成 $a+b-1$ 个部分，把一个可以看到的和被它的分到一组去，一共是 $a+b-2$ 组。我们发现，每一组除了最高的建筑都可以任意排列，而且这还是一个环形排列，所以方案数是第一类 Stirling 数 $s(n-1,a+b-2)$。

然后再思考每一组的放置方法，这是一个组合数 $C_{a+b-2}^{a-1}$。由乘法原理合并答案。

```cpp
int q, n, a, b;
const int N = 205;
mint c[N][N], s[50005][N];

void _main() {
	s[0][0] = 1;
	for (int i = 1; i < 50005; i++) {
		for (int j = 1; j < N; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * (i - 1);
	}
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (cin >> q; q--; ) {
		cin >> n >> a >> b;
		cout << s[n - 1][a + b - 2] * c[a + b - 2][a - 1] << '\n';
	}
}
```

### P6162 [Cnoi2020] 四角链

从 DP 出发，令 $dp_{i,j}$ 表示在 $i-1$ 个格子中填入 $j$ 个数的方案数。有两种选择：

1. 第 $i-1$ 个位置不填数，方案数为 $dp_{i-1,j}$。
2. 第 $i-1$ 个位置填数，该位置有 $(i-1)-(j-1)=i-j$ 个选择，方案数为 $(i-j)dp_{i-1,j-1}$。

由加法原理得：

$dp_{i,j}=dp_{i-1,j}+(i-j)dp_{i-1,j-1}$可以 $O(nk)$ 解决了。对比第二类 Stirling 数的递推式：

$S(n,k)=S(n-1,k-1)+k \times S(n-1,k)$将 $j \gets i-j$ 代入递推式

$dp_{i,i-j}=dp_{i-1,i-j-1}+j \times dp_{i-1,i-j}$因此 $dp_{n,k}=S(n,n-k)$。使用通项公式

$S(n,k)=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$配合一下预处理阶乘逆元即可 $O(k \log n)$ 解决。

```cpp
const int N = 1e6 + 5;
int n, k;
mint fac[N], ifac[N];
mint S(int n, int k) {
	mint res = 0;
	for (int i = 0; i <= k; i++) {
		if ((k - i) & 1) res -= mint(i).pow(n) * ifac[i] * ifac[k - i];
		else res += mint(i).pow(n) * ifac[i] * ifac[k - i];
	} return res;
}

void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cout << S(n, n - k);
}
```

### *P10591 BZOJ4671 异或图

好题。前置知识：15 章 Bell 数、22.3 高斯消元。建议先做完 [P10499 开关问题](https://www.luogu.com.cn/problem/P10499)。

看到 $n \le 10$ 一眼状压，然后就做不下去了。设 $f(x)$ 表示钦定 $x$ 个连通块之间两两不连通的方案数，$g(x)$ 表示恰好有 $x$ 个连通块两两不连通的方案数。根据第二类 Stirling 数定义

$f(x)=\sum_{i=x}^n S(i,x) \times g(i)$直接上 Stirling 反演：

$g(x)=\sum_{i=x}^{n} (-1)^{i-x} s(i,x) \times f(i)$所求为

$g(1)=\sum_{i=1}^n (-1)^{i-1} (i-1)! f(i)$只要求出 $f(x)$。因为 $n \le 10$ 可以考虑直接爆搜。注意到 $B_{10}=115975$，考虑搜索哪些点被分到同一个集合。对于每个集合，对于端点所属集合不同的边必须选偶数次。

到这里考虑列方程。设 $x_i$ 表示第 $i$ 个图是否属于子集，那么可以列出若干形如 $\bigoplus_{k \in S} x_k=0$ 的异或方程组。高斯消元以后可以确定一些 $x$ 一定属于 / 不属于该子集，剩下的自由元任选，方案数 $2^c$，加法原理合并即可。总复杂度 $O(n^4B_n)$。

实现上，注意输入格式转换成图。同时 $n \le 10$，不用 bitset 优化，可以直接状压存下。

```cpp
#define int long long
const int N = 105;
int n, m, a[N][20][20], x[N], id[N], f[N], fac[N];
char s[N * N];

int guass(int tot) {
	int cnt = m;
	for (int i = 1, cur = 1; i <= tot && cur <= m; cur++) {
		for (int j = i; j <= tot; j++) {
			if (x[j] >> cur & 1) {swap(x[i], x[j]); break;}
		}
		if (!(x[i] >> cur & 1)) continue;
		for (int j = i + 1; j <= tot; j++) {
			if (x[j] >> cur & 1) x[j] ^= x[i];
		} cnt--, i++;
 	} return cnt;
}
void dfs(int step) {
	if (step > n) {
		int tot = 0;
		for (int i = 1; i <= n; i++) {
			for (int j = i + 1; j <= n; j++) {
				if (id[i] == id[j]) continue;
				x[++tot] = 0;
				for (int k = 1; k <= m; k++) {
					if (a[k][i][j]) x[tot] |= 1LL << k;
				}
			}
		}
		return f[id[0]] += 1LL << guass(tot), void();
	}
	id[step] = ++id[0], dfs(step + 1), id[0]--;
	for (int i = 1; i <= id[0]; i++) id[step] = i, dfs(step + 1);
}

void _main() {
	cin >> m;
	for (int i = 1; i <= m; i++) {
		cin >> (s + 1);
		int len = strlen(s + 1), tot = 0;
		for (int j = 1; ; j++) {
			if (j * (j - 1) / 2 == len) {n = j; break;}
		}
		for (int j = 1; j <= n; j++) {
			for (int k = j + 1; k <= n; k++) a[i][j][k] = s[++tot] ^ 48;
		}
	}
	dfs(1);
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	int res = 0;
	for (int i = 1; i <= n; i++) {
		if (i & 1) res += fac[i - 1] * f[i];
		else res -= fac[i - 1] * f[i];
	} cout << res;
}
```

### *CF932E Team Work

显然答案为 $\sum_{i=1}^{n} C_n^i i^k$。根据常用性质 2 一路推式子：

$$
\begin{aligned}
ans&=\sum_{i=1}^{n} C_n^i i^k\\
&=\sum_{i=0}^{n} C_n^i i^k\\
&=\sum_{i=0}^{n} \dfrac{n!}{i!(n-i)!} \sum_{j=0}^k S(k,j) \times C_i^j\times j!\\
&=\sum_{i=0}^n \dfrac{n!}{i!(n-i)!} \sum_{j=0}^k S(k,j) \times \dfrac{1}{(i-j)}!\\
&=\sum_{i=0}^n \sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-i)!(n-j)!}\\
&=\sum_{j=0}^k \sum_{i=0}^n S(k,j) \times \dfrac{n!}{(n-i)!(n-j)!} \\
&=\sum_{j=0}^k S(k,j) \sum_{i=0}^n \dfrac{(n-j)!}{(n-i)!(i-j)!} \times \dfrac{n!}{(n-j)!}\\
&=\sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-j)!} \sum_{i=0}^n C_{n-j}^{n-i}\\
&=\sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-j)!} \times 2^{n-j}
\end{aligned}
$$

其中，$\dfrac{n!}{(n-j)!}$ 可以在递推中处理，提前递推好第二类 Stirling 数，预处理 $O(k^2)$，单次查询 $O(k)$。

```cpp
const int N = 5005;
int n, k;
mint s[N][N], fac[N];

void _main() {
	cin >> n >> k;
	if (k == 0) return cout << 1, void();
	s[0][0] = 1;
	for (int i = 1; i <= k; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	}
	mint res = 0, p = 1;
	for (int i = 0; i <= min(n, k); i++) {
		res += s[k][i] * p * mint(2).pow(n - i);
		p *= n - i;
	} cout << res;
}
```

### *P6620 [省选联考 2020 A 卷] 组合数问题

看到组合数和多项式放到一起，考虑转下降幂。因为我们有如下结论：

$C_n^k k^{\underline m}=C_{n-m}^{k-m} n^{\underline m}$代数推导易证。考虑怎么将 $f(x)$ 转化为下降幂多项式 $f(x)=\sum_{i=0}^m b_i x^{\underline i}$。

根据 $x^{n}=\sum S(n,k) \times x^{\underline k}$，有

$$
\begin{aligned}
f(x)&=\sum_{i=0}^m a_i x^{i}\\
&=\sum_{i=0}^m a_i \sum_{j=0}^i S(i,j) x^{\underline j}\\
&=\sum_{i=0}^m x^{\underline j} \sum_{j=i}^m S(j,i) a_j
\end{aligned}
$$

对比一下系数得到 $b_i=\sum_{j=i}^m S(j,i) \times a_j$。将新的 $f(x)$ 代入原式：

$$
\begin{aligned}
ans&=\sum_{k=0}^n f(k) \times x^k \times C_{n}^k\\
&=\sum_{k=0}^n x^k C_{n}^k \sum_{i=0}^m b_i k^{\underline i}\\
&=\sum_{i=0}^m b_i n^{\underline i} \sum_{k=0}^n C_{n-i}^{k-i} x^k\\
&=\sum_{i=0}^m b_i n^{\underline i} \sum_{k=0}^{n-i} C_{n-i}^{k} x^{k+i}\\
&=\sum_{i=0}^m b_i x^i n^{\underline i} \sum_{k=0}^{n-i} C_{n-i}^{k} x^k 1^{n-i-k} \\
&=\sum_{i=0}^m b_i x^i n^{\underline i} (x+1)^{n-i}
\end{aligned}
$$

逆用二项式定理，最终得到一个 $O(m)$ 的式子。我们可以 $O(m^2)$ 递推出第二类 Stirling 数和 $n$ 的下降幂，此题解决。

```cpp
const int N = 1005;
int n, x, p, m, a[N], b[N], s[N][N], low[N];
int madd(int x, int y) {return x += y, x >= p ? x -= p : x;}
int mpow(int a, int b) {
	int res = 1; for (a %= p; b; a = 1LL * a * a % p, b >>= 1) {
		if (b & 1) res = 1LL * res * a % p;
	} return res;
}

void _main() {
	cin >> n >> x >> p >> m;
	for (int i = 0; i <= m; i++) cin >> a[i];
	s[0][0] = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = madd(s[i - 1][j - 1], 1LL * j * s[i - 1][j] % p);
	}  // 第二类 Stirling 数
	for (int i = 0; i <= m; i++) {
		for (int j = i; j <= m; j++) b[i] = madd(b[i], 1LL * a[j] * s[j][i] % p);
	}  // 下降幂系数
	for (int i = 0; i <= m; i++) {
		low[i] = 1;
		for (int j = 0; j < i; j++) low[i] = 1LL * low[i] * (n - j) % p;
	}  // n 的下降幂
	int res = 0;
	for (int i = 0; i <= m; i++) res = madd(res, 1LL * b[i] * mpow(x, i) % p * low[i] % p * mpow(x + 1, n - i) % p);
	cout << res;
}
```

类似套路的题：[P6667](https://www.luogu.com.cn/problem/P6667)，但需要用到笔者不会的多项式科技。

## 15. Bell 数

**Bell 数** $B_n$ 表示大小为 $n$ 的集合的划分方法数，参见 [A000110](https://oeis.org/A000110)。例如，对于集合 $\{1,2,3\}$，有 $5$ 种划分方法：

```dust
{1},{2},{3}
{1,2},{3}
{1,3},{2}
{1},{2,3}
{1,2,3}
```

所以 $B_3=5$。

## 15.1 递推公式

设 $B_n$ 对应集合 $\{a_1,a_2,a_3,\cdots,a_n\}$，$B_{n+1}$ 对应集合 $\{a_1,a_2,a_3,\cdots,a_n,a_{n+1}\}$，只需考虑元素 $a_{n+1}$ 的贡献。

当它和 $k$ 个元素分到一个子集时，还剩下 $n-k$ 个元素，则多出的方案数有 $C_{n}^{n-k} B_{n-k}$，且 $k \in [0,n]$。因此：

$B_{n+1}=\sum_{k=0}^{n} C_n^k B_k$仿照杨辉三角，可以构造一个 Bell 三角形：

- $a_{0,0}=1$；
- $a_{n,0}=a_{n-1,n-1}$；
- $a_{n,m}=a_{n,m-1}+a_{n-1,m-1}$。

此时 $B_n=a_{n,0}$。代码如下：

```cpp
int b[N][N];
void work() {
	b[0][0] = 1;
	for (int i = 1; i < N; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
}
```

可以发现在 $n \le 12$ 较小时 $O(B_n)$ 是可接受的复杂度。例题 [AT_abc390_d [ABC390D] Stone XOR](https://www.luogu.com.cn/problem/AT_abc390_d)。

## 15.2 与第二类 Stirling 数的关系

枚举划分成 $k$ 个非空集合，则每种情况的方案数为第二类 Stirling 数 $S(n,k)$。于是：

$B_n=\sum_{k=0}^n S(n,k)$这表明：Bell 数 $B_n$ 就是第 $n$ 行第二类 Stirling 数的和。因此可以 $O(n \log n)$ 地使用 NTT 计算。

事实上，由这个公式可以得到单次询问 $O(n)$ 求 $B_n$ 的方法。

## *15.3 性质

Bell 数有很多优美的性质。

1. 组合引理：

$B_{n+m} =\sum_{i=0}^{n} [C_n^i \times B_i \times \sum_{j=0}^{m} (j^{n-i} \times S(m,j))]$将 $n+m$ 个元素分成 $n,m$ 两部分。枚举 $m$ 个元素划分为 $j$ 个集合，方案数为 $S(m,j)$。再枚举 $n$ 个元素选 $i$ 个划分出来，方案数为 $C_n^i \times B_i$，则剩下 $n-i$ 个要放到 $j$ 个集合中，方案数 $j^{n-i}$。最后用乘法原理合并答案。

1. Dobinski 公式：

$B_n=\dfrac{1}{e} \sum_{k=0}^{\infty} \dfrac{k^n}{k!}$很神奇的一个级数求和。

1. Touchard 同余：若 $p$ 是质数，则

$B_{n+p} \equiv B_n+B_{n+1} \pmod p$其中结论 2&3 的证明过于复杂，这里不展开说明。如果有兴趣可以看 [这篇 Blog](https://www.cnblogs.com/HeNuclearReactor/p/17552175.html)。

## 15.4 例题

### *CF568B Symmetric and Transitive

做一个图论建模。由对称性可得这是一个无向图，不妨设图中存在 $i$ 个孤立点，则选出孤立点的方案数是 $C_n^i$。然后剩下的分配就是上面讲的集合划分问题，为 $B_{n-i}$。由加法、乘法原理可得所求为

$\sum_{i=1}^{n} C_n^i B_{n-i}$然后组合数用杨辉三角，Bell 数用 Bell 三角预处理即可。

```cpp
const int N = 4005;
int n;
mint b[N][N], c[N][N];

void _main() {
	cin >> n;
	b[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
	for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) res += c[n][i] * b[n - i][0];
	cout << res;
}
```

### *CF908E New Year and Entity Enumeration

好题。先扔掉 $T \subseteq S$ 这条限制。

因为 $M=2^m-1$，即二进制下全是 $1$，可以认为 $a \oplus M= \sim a$，即 $a$ 的无符号取反。

写出两条限制：

1. $\forall a \in S, \sim a \in S$。
2. $\forall a,b \in S, a \& b \in S$。

因为 $a | b=\sim (\sim a \& \sim b)$，根据性质 1&2 有

1. $\forall a,b \in S, a | b \in S$。

因为 $a \oplus b=\sim ((a\& b) | \sim(a | b))$，根据性质 1&2&3 有

1. $\forall a,b \in S, a \oplus b \in S$。

下文设 $d(x,y)$ 表示 $x$ 二进制下的第 $y$ 位。

设

$$
f(x)=\begin{cases}
 \text{AND}_{a \in S, d(a,x)=1 } \text{ } a & \exists a \in S, d(a,x)=1 \\
 0 & \forall a \in S, d(a,x)=0
\end{cases}
$$

先讨论 $S \ne \varnothing$，易得 $0 \in S$。则根据性质 2 可得 $f(x) \in S$。

注意到，$f(x) \ne 0$ 时定有 $d(f(x),x)=1$。设 $d(f(x),y)=1$ 且 $x \ne y$，可以发现 $d(f(y),x)=1$。

证明：反证法，设 $d(f(y),x)=0$，令 $m=f(x) \oplus f(y)$，则 $d(m,x)=1$ 且 $d(m,y)=0$，则 $m \notin S$，与性质 3 矛盾。

设集合 $A(x)=\{y \mid d(f(x),y)=1\}$，则对于 $A(x)$ 中的所有元素 $y$ 有 $A(x)=A(y)$。把所有相等的 $A(x)$ 视作一个集合，则一个神圣的 $S$ 会导致这 $n$ 位被划分为若干非空子集。

这样我们就得到了，一个合法的 $S$ 与将 $m$ 位划分为若干子集的方案一一对应。因此，$S$ 的数目为 Bell 数 $B_m$。

回头看 $T \subseteq S$ 这条限制，就是告诉你哪些 $f(x)$ 不属于一个集合。将所有连通块状压预处理出来，由乘法原理，答案即 $\prod B_{sz}$。时间复杂度 $O(m(m+n))$。

```cpp
const int N = 1005;
long long n, m, a[N];
char s[N];
mint b[N][N];

void _main() {
	cin >> m >> n;
	for (int i = 1; i <= n; i++) {
		cin >> (s + 1);
		for (int j = 1; j <= m; j++) {
			if (s[j] == '1') a[j] |= 1LL << (i - 1);
		}
	}
	map<long long, int> sz;
	for (int i = 1; i <= m; i++) sz[a[i]]++;

	b[0][0] = 1;
	for (int i = 1; i <= m; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
	mint res = 1;
	for (const auto& k : sz) res *= b[k.second][0];
	cout << res;
}
```

### P5748 集合划分计数

$O(n)$ 求 Bell 数的板子。观察数据范围，严格 $O(Tn)$ 的算法可以通过本题。推式子：

$$
\begin{aligned}
B_n&=\sum_{i=0}^n S(n,i) \\
&=\sum_{i=0}^{n} \sum_{j=0}^{i} \dfrac{(-1)^{j} (i-j)^n}{j!(i-j)!}\\
&=\sum_{i=0}^{n} \dfrac{(-1)^j}{j!} \sum_{j=0}^{i} \dfrac{(i-j)^n}{(i-j)!}\\
&=\sum_{j=0}^{n} \dfrac{(-1)^j}{j!} \sum_{i=j}^{n} \dfrac{(i-j)^n}{(i-j)!}\\
&=\sum_{j=0}^{n} \dfrac{(-1)^j}{j!} \sum_{i=0}^{n-j} \dfrac{i^n}{i!}
\end{aligned}
$$

内层循环预处理前缀和即可。至此可以做到 $O(Tn \log n)$，瓶颈在快速幂。

注意到 $i^n$ 是积性函数，线性筛预处理 $i^n$ 可以做到 $O(n)$。于是我们得到了单个 Bell 数的 $O(n)$ 求法。

```cpp
const int N = 1e5 + 5;
int n;
mint fac[N], ifac[N], pw[N], pre[N];
bitset<N> isprime;
vector<int> prime;

void prework() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	isprime.set(), isprime[0] = isprime[1] = 0;
	for (int i = 2; i < N; i++) {
		if (!isprime[i]) continue;
		prime.emplace_back(i);
		for (int j = i << 1; j < N; j += i) isprime[j] = 0;
	}
}
void solve() {
	pw[0] = 0, pw[1] = 1;
	for (int i = 2; i <= n; i++) {
		if (isprime[i]) pw[i] = mint(i).pow(n);
		for (int j : prime) {
			if (1LL * i * j > n || j > i) break;
			pw[i * j] = pw[i] * pw[j];
			if (i % j == 0) break;
		}
	}
}

void _main() {
	cin >> n;
	solve();
	for (int i = 1; i <= n; i++) pre[i] = pre[i - 1] + pw[i] * ifac[i];
	mint res = 0;
	for (int j = 0; j <= n; j++) {
		if (j & 1) res -= pre[n - j] * ifac[j];
		else res += pre[n - j] * ifac[j];
	} cout << res << '\n';
}
```

## 附：计数基础·斯特林数与贝尔数（stripe-python）

## 6. 斯特林数

## 6.1 第二类斯特林数

**第二类斯特林数** $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**非空子集的方案数。

我们可以用递推的思想来求解。考虑加入一个新元素的贡献：

- 将新元素单开一个子集，方案数 $\left\{\begin{matrix}
  n-1 \\
  m-1
  \end{matrix}\right\}$。
- 将新元素插入一个现有子集，方案数 $m\left\{\begin{matrix}
  n-1 \\
  m
  \end{matrix}\right\}$。

由加法原理合并得到递推式：
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\left\{\begin{matrix}
n-1 \\
m-1
\end{matrix}\right\}+m\left\{\begin{matrix}
n-1 \\
m
\end{matrix}\right\}
$$
可以做到 $O(n^2)$ 求解。

#### 6.1.1 通项公式

上面的式子复杂度还是太高了，我们考虑直接用组合数学方法求 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。记：

- $g(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**子集的方案数。
- $f(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**非空子集的方案数。

根据球盒模型我们知道 $g(m)=m^n$，又根据消序原理 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\dfrac{f(m)}{m!}$，所以只需配上容斥系数实现 $g \to f$ 的转化。

考虑枚举空集的数目，可以实现 $f \to g$ 的转化：
$$
g(m)=\sum_{i=0}^m \binom{m}{i} f(i)
$$
由二项式反演形式一，容斥系数 $(-1)^{m-i} \dbinom{m}{i}$。也即
$$
\begin{aligned}
f(m)&=\sum_{i=0}^m (-1)^{m-i} \binom{m}{i} g(i)\\
&=\sum_{i=0}^m (-1)^{m-i} \dfrac{m!}{i!(m-i)!} i^n\\
&=\sum_{i=0}^m \dfrac{(-1)^{m-i}i^n m!}{i!(m-i)!}
\end{aligned}
$$
消序后就得到通项公式
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}
= \sum_{i=0}^m \dfrac{(-1)^{m-i} i^n}{i!(m-i)!}
$$
这是一个卷积的形式：记 $f_i=\dfrac{i^n}{i!}$，$g_i=\dfrac{(-1)^i}{i!}$，则有 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=[x^m] FG$。容易在 $O(n \log n)$ 内求解同行第二类斯特林数。

### 6.2 第一类斯特林数

**第一类斯特林数** $\begin{bmatrix}
n \\
m
\end{bmatrix}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**轮换的方案数。轮换可以理解为一个圆排列。

那么仍然可以考虑加入一个新元素的贡献，进行递推求解：

- 将新元素单开一个轮换，方案数 $\begin{bmatrix}
  n-1 \\
  m-1
  \end{bmatrix}$。
- 插入一个现有轮换，方案数 $(n-1)\begin{bmatrix}
  n-1 \\
  m
  \end{bmatrix}$。

加法原理合并就得到递推公式
$$
\begin{bmatrix}
n \\
m
\end{bmatrix}=\begin{bmatrix}
n-1 \\
m-1
\end{bmatrix}+(n-1)\begin{bmatrix}
n-1 \\
m
\end{bmatrix}
$$
在 OI 中，可以认为第一类斯特林数没有通项公式。

根据第一类斯特林数的组合意义，有一个组合恒等式：
$$
\sum_{i=0}^n\begin{bmatrix}
n \\
i
\end{bmatrix}=n!
$$

### 6.3 贝尔数

**贝尔数** $B_n$ 表示将 $n$ 个**有标号**元素不重不漏地划分为若干非空集合的方案数。

根据第二类斯特林数的组合意义，贝尔数就是同行第二类斯特林数的和：
$$
B_n=\sum_{i=0}^m\left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
贝尔数还满足一个递推式：
$$
B_{n+1}=\sum_{i=0}^m \binom{n}{i} B_i
$$
原理是枚举第 $n+1$ 个元素所在集合的大小。上面的两种方法都能做到 $O(n^2)$ 计算贝尔数。

#### 6.3.1 求法

[P5748 集合划分计数](https://www.luogu.com.cn/problem/P5748)：

> $T$ 次询问求 $B_n \bmod 998244353$。
>
> $T =10^3$，$n \le 10^5$，1 秒，125 MB。

我们介绍两种做法。第一种做法可以 $O(n)$ 计算单个 $B_n$，第二种做法可以 $O(n \log n)$ 求出 $B_1 \sim B_n$。

:::::success[单个贝尔数的求法]

代入第二类斯特林数的通项公式：
$$
\begin{aligned}
B_n&=\sum_{k=0}^n \left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \\
&=\sum_{k=0}^{n} \sum_{i=0}^{k} \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n \sum_{k=i}^n \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{k=i}^n \dfrac{(-1)^{k-i}}{(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{j=0}^{n-i} \dfrac{(-1)^j}{j!}\\
\end{aligned}
$$
预处理 $\dfrac{(-1)^j}{j!}$ 的前缀和即可做到 $O(n \log n)$。考虑精细实现：

- 用线性倒推法求解阶乘逆元。
- 用线性筛预处理 $i^n$ 的值。

预处理后复杂度 $O(n)$。

:::::

:::::success[多个贝尔数的求法]

记贝尔数的 EGF 为 $F$，代入递推公式：
$$
\begin{aligned}
F(x)&=\sum_{n \ge 0} B_n \dfrac{x^n}{n!}\\
F'(x)&=\sum_{n \ge 0}B_{n+1} \dfrac{x^n}{n!}\\
&= \sum_{n \ge 0} \dfrac{x^n}{n!} \sum_{k=0}^n \binom{n}{k} B_k\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \binom{n}{k} \dfrac{x^n}{n!}\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \dfrac{x^n}{k!(n-k)!} \\
&= \sum_{k \ge 0} B_k \dfrac{x^k}{k!} \sum _{i \ge 0} \dfrac{x^i}{i!}\\
F'(x)&=F(x) \times e^x
\end{aligned}
$$
由微分方程 $F'=Fe^x$ 得 $\ln F=e^x+C$。代入 $F(0)=1$ 知 $C=-1$，因此我们得到了贝尔数的 EGF
$$
F(x)=\exp (e^x-1)
$$
两次多项式 $\exp$ 即可，复杂度 $O(n \log n)$。

:::::

#### 6.3.2 性质

在第二种方法中，我们求得了贝尔数的 EGF。据此还可以得到 Dobinski 公式
$$
B_n=\dfrac{1}{e} \sum_{k \ge 0} \dfrac{k^n}{k!}
$$
贝尔数对质数 $p$ 有如下同余式
$$
B_{n+p} \equiv B_n+B_{n+1} \pmod p 
$$
 称为 Touchard 同余。另外还有扩展 Touchard 同余
$$
B_{n+p^k}=kB_n+B_{n+1} \pmod p
$$
这两个定理我们不证。

### 6.4 应用

先给出两个定义：

- 上升幂 $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod\limits_{i=0}^{n-1} (x+i)$。
- 下降幂 $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod \limits_{i=0}^{n-1} (x-i)=A_x^n$。

斯特林数可以实现上升幂 / 下降幂 / 普通幂之间的相互转化。

上升幂和普通幂的转化：
$$
x^{\overline n}=\sum_{k=0}^n\begin{bmatrix}
n \\
k
\end{bmatrix}x^k \iff x^n=\sum_{k=0}^n (-1)^{n-k}\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\overline k}
$$
下降幂和普通幂的转化：
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\underline k} \iff x^{\underline n} =\sum_{k=0}^n (-1)^{n-k}\begin{bmatrix}
n \\
k
\end{bmatrix}x^k
$$
同组内的两个等式由斯特林反演得到。

其中普通幂转下降幂的式子又可以写作
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \binom{n}{k} k!
$$
这个公式非常重要，称为**拆幂公式**。见到与普通幂有关的题目时，都可以尝试用下降幂转化。

## 附：斯特林数专题笔记（stripe-python）

## 14.1 第二类斯特林数

**第二类斯特林数** $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**非空子集的方案数。

我们可以用递推的思想来求解。考虑加入一个新元素的贡献：

- 将新元素单开一个子集，方案数 $\left\{\begin{matrix}
  n-1 \\
  m-1
  \end{matrix}\right\}$。
- 将新元素插入一个现有子集，方案数 $m\left\{\begin{matrix}
  n-1 \\
  m
  \end{matrix}\right\}$。

由加法原理合并得到递推式：
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\left\{\begin{matrix}
n-1 \\
m-1
\end{matrix}\right\}+m\left\{\begin{matrix}
n-1 \\
m
\end{matrix}\right\}
$$
可以做到 $O(n^2)$ 求解。

### 14.1.1 通项公式

上面的式子复杂度还是太高了，我们考虑直接用组合数学方法求 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。记：

- $g(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**子集的方案数。
- $f(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**非空子集的方案数。

根据球盒模型我们知道 $g(m)=m^n$，又根据消序原理 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\dfrac{f(m)}{m!}$，所以只需配上容斥系数实现 $g \to f$ 的转化。

考虑枚举空集的数目，可以实现 $f \to g$ 的转化：
$$
g(m)=\sum_{i=0}^m \binom{m}{i} f(i)
$$
由二项式反演形式一，容斥系数 $(-1)^{m-i} \dbinom{m}{i}$。也即
$$
\begin{aligned}
f(m)&=\sum_{i=0}^m (-1)^{m-i} \binom{m}{i} g(i)\\
&=\sum_{i=0}^m (-1)^{m-i} \dfrac{m!}{i!(m-i)!} i^n\\
&=\sum_{i=0}^m \dfrac{(-1)^{m-i}i^n m!}{i!(m-i)!}
\end{aligned}
$$
消序后就得到通项公式
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}
= \sum_{i=0}^m \dfrac{(-1)^{m-i} i^n}{i!(m-i)!}
$$
这是一个卷积的形式：记 $f_i=\dfrac{i^n}{i!}$，$g_i=\dfrac{(-1)^i}{i!}$，则有 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=[x^m] FG$。容易在 $O(n \log n)$ 内求解同行第二类斯特林数。

## 14.2 第一类斯特林数

**第一类斯特林数** $\begin{bmatrix}
n \\
m
\end{bmatrix}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**轮换的方案数。轮换可以理解为一个圆排列。

那么仍然可以考虑加入一个新元素的贡献，进行递推求解：

- 将新元素单开一个轮换，方案数 $\begin{bmatrix}
  n-1 \\
  m-1
  \end{bmatrix}$。
- 插入一个现有轮换，方案数 $(n-1)\begin{bmatrix}
  n-1 \\
  m
  \end{bmatrix}$。

加法原理合并就得到递推公式
$$
\begin{bmatrix}
n \\
m
\end{bmatrix}=\begin{bmatrix}
n-1 \\
m-1
\end{bmatrix}+(n-1)\begin{bmatrix}
n-1 \\
m
\end{bmatrix}
$$
在 OI 中，可以认为第一类斯特林数没有通项公式。

根据第一类斯特林数的组合意义，有一个组合恒等式：
$$
\sum_{i=0}^n\begin{bmatrix}
n \\
i
\end{bmatrix}=n!
$$

## 14.3 贝尔数

**贝尔数** $B_n$ 表示将 $n$ 个**有标号**元素不重不漏地划分为若干非空集合的方案数。

根据第二类斯特林数的组合意义，贝尔数就是同行第二类斯特林数的和：
$$
B_n=\sum_{i=0}^m\left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
贝尔数还满足一个递推式：
$$
B_{n+1}=\sum_{i=0}^m \binom{n}{i} B_i
$$
原理是枚举第 $n+1$ 个元素所在集合的大小。上面的两种方法都能做到 $O(n^2)$ 计算贝尔数。

### 14.3.1 求法

[P5748 集合划分计数](https://www.luogu.com.cn/problem/P5748)：

> $T$ 次询问求 $B_n \bmod 998244353$。
>
> $T =10^3$，$n \le 10^5$，1 秒，125 MB。

我们介绍两种做法。第一种做法可以 $O(n)$ 计算单个 $B_n$，第二种做法可以 $O(n \log n)$ 求出 $B_1 \sim B_n$。

:::::success[单个贝尔数的求法]

代入第二类斯特林数的通项公式：
$$
\begin{aligned}
B_n&=\sum_{k=0}^n \left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \\
&=\sum_{k=0}^{n} \sum_{i=0}^{k} \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n \sum_{k=i}^n \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{k=i}^n \dfrac{(-1)^{k-i}}{(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{j=0}^{n-i} \dfrac{(-1)^j}{j!}\\
\end{aligned}
$$
预处理 $\dfrac{(-1)^j}{j!}$ 的前缀和即可做到 $O(n \log n)$。考虑精细实现：

- 用线性倒推法求解阶乘逆元。
- 用线性筛预处理 $i^n$ 的值。

预处理后复杂度 $O(n)$。

:::::

:::::success[多个贝尔数的求法]

记贝尔数的 EGF 为 $F$，代入递推公式：
$$
\begin{aligned}
F(x)&=\sum_{n \ge 0} B_n \dfrac{x^n}{n!}\\
F'(x)&=\sum_{n \ge 0}B_{n+1} \dfrac{x^n}{n!}\\
&= \sum_{n \ge 0} \dfrac{x^n}{n!} \sum_{k=0}^n \binom{n}{k} B_k\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \binom{n}{k} \dfrac{x^n}{n!}\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \dfrac{x^n}{k!(n-k)!} \\
&= \sum_{k \ge 0} B_k \dfrac{x^k}{k!} \sum _{i \ge 0} \dfrac{x^i}{i!}\\
F'(x)&=F(x) \times e^x
\end{aligned}
$$
由微分方程 $F'=Fe^x$ 得 $\ln F=e^x+C$。代入 $F(0)=1$ 知 $C=-1$，因此我们得到了贝尔数的 EGF
$$
F(x)=\exp (e^x-1)
$$
两次多项式 $\exp$ 即可，复杂度 $O(n \log n)$。

:::::

### 14.3.2 性质

在第二种方法中，我们求得了贝尔数的 EGF。据此还可以得到 Dobinski 公式
$$
B_n=\dfrac{1}{e} \sum_{k \ge 0} \dfrac{k^n}{k!}
$$
贝尔数对质数 $p$ 有如下同余式
$$
B_{n+p} \equiv B_n+B_{n+1} \pmod p 
$$
 称为 Touchard 同余。另外还有扩展 Touchard 同余
$$
B_{n+p^k}=kB_n+B_{n+1} \pmod p
$$
这两个定理我们不证。

## 14.4 应用

先给出两个定义：

- 上升幂 $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod\limits_{i=0}^{n-1} (x+i)$。
- 下降幂 $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod \limits_{i=0}^{n-1} (x-i)=A_x^n$。

斯特林数可以实现上升幂 / 下降幂 / 普通幂之间的相互转化。

上升幂和普通幂的转化：
$$
x^{\overline n}=\sum_{k=0}^n\begin{bmatrix}
n \\
k
\end{bmatrix}x^k \iff x^n=\sum_{k=0}^n (-1)^{n-k}\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\overline k}
$$
下降幂和普通幂的转化：
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\underline k} \iff x^{\underline n} =\sum_{k=0}^n (-1)^{n-k}\begin{bmatrix}
n \\
k
\end{bmatrix}x^k
$$
同组内的两个等式由斯特林反演得到。

其中普通幂转下降幂的式子又可以写作
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \binom{n}{k} k!
$$
这个公式非常重要，称为**拆幂公式**。见到与普通幂有关的题目时，都可以尝试用下降幂转化。
