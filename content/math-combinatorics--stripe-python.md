---
id: math-combinatorics
title: '组合数学（排列 / 组合 / 进阶模型）'
category: '数学'
subcategory: '组合数学'
tags: ['排列组合', '组合数', '多重集', 'exLucas']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 9. 排列组合

还有一些较难的内容放到进阶部分了。

## 9.1 排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一列，方案数用 $A_{n}^{m}$ 表示。

我们这样计算：第一个数有 $n$ 种选法，第二个数有 $n-1$ 种选法……第 $m$ 个数有 $n-m+1$ 种选法，由乘法原理得

$A_{n}^{m}=n(n-1)(n-2) \cdots (n-m+1)=\prod_{i=n-m+1}^{n} i=\dfrac{n!}{(n-m)!}$规定 $m>n$ 时 $A_{n}^{m}=0$。

而如果 $m=n$，也就是所有元素都参与排列，此时称为全排列。全排列的计算

$A_{n}^{n}=n!$### 9.1.1 全排列的枚举

在 C++ STL 中提供了 `next_permutation` 函数，可以这样使用：

```cpp
// a为要枚举排列的数组，n为长度
sort(a + 1, a + n + 1);
do {
  ...
} while (next_permutation(a + 1, a + n + 1));
```

时间复杂度为 $O(n!)$。

### 9.1.2 多重集的排列数

就是元素有重，此时需要除去重复的排列。

考虑一组有 $m$ 个的重复元素，其造成重复的个数就是它在排列中的次序交换，也就是 $m!$ 种情况，所以总排列数

$\dfrac{n!}{m_1!m_2!m_3! \cdots}=\dfrac{n!}{\prod m_i!}$其中 $n$ 为总元素个数，$m$ 为各元素出现次数。

### 9.1.3 圆排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一圈，方案数用 $Q_{n}^{m}$ 表示。考虑断环为链，共有 $m$ 个断点，故

$Q_{n}^{m}=\dfrac{A_{n}^{m}}{m}=\dfrac{n!}{m(n-m)!}$特别地，$Q_n^n=\dfrac{A_n^n}{n}=(n-1)!$。

## 9.2 组合

从 $n$ 个**不同**元素中取 $m$ 个元素组成**无序**的一个集合，方案数用 $C_{n}^{m}$ 表示。

考虑先作排列，由于集合无序，需要除去重复的组合，也就是 $m$ 的全排列，逆用乘法原理：

$C_{n}^{m}=\dfrac{A_{n}^{m}}{m!}=\dfrac{n!}{m!(n-m)!}$规定 $m>n$ 时 $C_{n}^{m}=0$。

### 9.2.1 组合的枚举

代码如下：

```cpp
int n, m, cur[N];
void dfs(int x) {
	if (x > m) return ..., void();  // 这里cur就是一个组合，进行处理
	for (int i = cur[x - 1] + 1; i <= n; i++) cur[x] = i, dfs(x + 1);
}

dfs(1);
```

它用于枚举 $1$ 到 $n$ 所有自然数选 $m$ 个的组合。如果套上 `next_permutation`，还能实现排列的枚举。

### 9.2.2 二项式定理

$(a+b)^n=\sum_{i=0}^{n} C_{n}^{i} a^{n-i} b^{i}$这个定理表明，二项式 $(a+b)^n$ 展开项的系数与组合数有直接关系。

我们知道杨辉三角：

![](https://cdn.luogu.com.cn/upload/image_hosting/y4q3udx2.png)

其每一个位置的数字通过左上 + 右上确定，每一行所对应的就是二项式展开的系数。

### 9.2.3 组合数的性质

1. 对称性：

$C_{n}^{m} = C_{n}^{n-m}$代数推导易证，组合意义就是把选出的集合取补集。

1. 递推式：

$C_{n}^{m}=C_{n-1}^{m}+C_{n-1}^{m-1}$代数推导略去，组合意义类似 DP 的思想可以证明。这个式子实际上就是杨辉三角的递推式。

1. 二项式定理的特殊情况 1：

$2^n=\sum_{i=0}^{n} C_n^i$也就是杨辉三角每一行的和。

1. 斐波那契数列：

$fib_{n+1}=\sum_{i=0}^{n} C_{n-i}^i$把杨辉三角每条斜 $30 \degree$ 角的线取出来相加可以发现。

1. 范德蒙恒等式：

$C_{m+n}^{k}=\sum_{i=0}^{k} C_m^i C_n^{k-i}$假设有两堆物品，每堆分别有 $m,n$ 个物品，总共取 $k$ 个，则方案数可分解为：从第一堆取 $i$ 个物品，第二堆取 $k-i$ 个物品，且两种选择独立，故由乘法得到贡献。最后方案即为求和。

1. 二项式定理的特殊情况 2：

$\sum_{i=0}^{n} (-1)^i C_n^i = 0$特殊情况是 $n=0$ 时上式的值为 $1$。

### 9.2.4 计算组合数

#### 定义法

- 优点：写起来简单，不用预处理。
- 缺点：查询复杂度 $O(m)$。

根据定义直接计算，注意先乘后除。

```cpp
inline long long C(int n, int m) {
	if (m > n) return 0;
	long long res = 1;
	for (int i = 1; i <= m; i++) {
		res = res * (n - i + 1) % mod * power(i, mod - 2) % mod;
	}
	return res;
}
```

#### 递推法

- 优点：任意模数，写起来简单，查询 $O(1)$。
- 缺点：预处理时空复杂度均为 $O(n^2)$。

即利用组合数性质 2 预处理杨辉三角。

```cpp
for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
for (int i = 0; i < N; i++) {
  for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
}
```

#### 逆元法

- 优点：预处理可做到 $O(n)$，查询 $O(1)$。
- 缺点：只能在模数为质数时使用。

通过预处理阶乘和阶乘的逆元，直接用定义式计算组合数。

```cpp
inline long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long fac[N], ifac[N];
inline void pre() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i % mod, ifac[i] = power(fac[i], mod - 2);
}

inline long long C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] % mod * ifac[n - m] % mod;
}
```

#### *Lucas 定理法

- 优点：预处理 $O(p)$，查询 $O(\log n)$，适用于模数小而 $n,m$ 很大的情况。
- 缺点：码量稍大，只能处理 $p$ 为质数的情况。

Lucas 定理如下：

$C_n^m \equiv C_{n \bmod p}^{m \bmod p} C_{\lfloor \frac{n}{p}\rfloor}^{\lfloor \frac{m}{p}\rfloor} \pmod p$其中 $p$ 是质数。利用这个式子，先用逆元法预处理所有 $p$ 以内的组合数，查询时递归计算即可。

```cpp
inline long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long fac[N], ifac[N];
inline void pre() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i % mod, ifac[i] = power(fac[i], mod - 2);
}

inline long long C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] % mod * ifac[n - m] % mod;
}
long long lucas(long long n, long long m) {
	if (m == 0) return 1;
	if (n < mod && m < mod) return C(n, m);
	return lucas(n / mod, m / mod) * C(n % mod, m % mod) % mod;
}
```

[P3807 【模板】卢卡斯定理/Lucas 定理](https://www.luogu.com.cn/problem/P3807)。

Lucas 定理可以实现快速求组合数前缀和，可以看进阶部分例题中的 [P4345 [SHOI2015] 超能粒子炮·改](https://www.luogu.com.cn/problem/P4345)。

#### exLucas 法

在 10.2 介绍。

## 9.3 经典模型

这里介绍排列组合题里常用的转化思想，每种模型给出一些例题。

### 9.3.1 捆绑法

Q: 有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须连续，求方案数。

A: 将 $m$ 个元素捆绑在一起，内部排列方案为 $m!$ 种，这 $m$ 个元素的整体视为一个元素，则外部排列方案为 $(n+1)!$ 种，由乘法原理得方案数为 $(n+1)!m!$。

### 9.3.2 插板法

#### 问题一

Q1: 现有 $n$ 个相同元素，分为 $k$ 组，每组至少有一个元素，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的**正**整数解数目）

A1: 不考虑分组，而是考虑间断点，将 $k-1$ 块板子插入到 $n-1$ 个空里，则答案为 $C_{n-1}^{k-1}$。

#### 问题二

Q2: 现有 $n$ 个相同元素，分为 $k$ 组，每组可以为空，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的**非负**整数解数目）

A2: 先借 $k$ 个元素过来放到每组里，由 Q1 可得方案数为 $C_{n+k-1}^{k-1}=C_{n+k-1}^{n}$，再把 $k$ 个元素拿走，方案数不变。

#### 问题三

Q3: 现有 $n$ 个相同元素，分为 $k$ 组，第 $i$ 组的元素数目不小于 $a_i$，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的解数目，其中 $x_i \ge a_i$）

A3: 先借 $\sum a_i$ 个元素过来，令 $x_i'=x_i-a_i$，可知 $\sum x_i'=n-\sum a_i$，由 Q2 得答案为 $C_{n-\sum a_i+k-1}^{n-\sum a_i}$。

#### *问题四

Q4: 现有 $n$ 个相同元素，分为 $k$ 组，每组可以为空，且第 $i$ 组元素不超过 $b_i$ 个，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n,x_i \le b_i$ 的**非负**整数解数目）

A4: 考虑容斥，先抽象出容斥原理的模型：

- $U$：不定方程 $x_1+x_2+\cdots+x_k=n,x_i \le b_i$ 的**非负**整数解；
- 元素：变量 $x_i$；
- 约束：$x_i \le b_i$。

我们对每个 $i$ 计数 $x_i >b_i$，即突破限制的情况数，最后容斥一下。

根据 Q2，$|U|=C_{m+n-1}^{n-1}$。我们需要求 $|\cap_{i=1}^n S_i|$，减法原理变成 $|U|-|\cup_{i=1}^n S_i|$。

考虑 $S_{a_i}$ 的意义即 $x_{a_i} \ge b_{a_i}+1$ 的解数。使用一个 trick，将所有 $x_i$ 减去其下界限制，转化为 Q2，本题解决。

#### 问题五

Q5: 有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须两两不相邻，求方案数。

A5: 先将 $n$ 个元素全排列，再求 $n+1$ 个空隙而插入 $m$ 块板子的方案数为 $A_{n+1}^{m}$，所以方案数为 $n! A_{n+1}^{m}$。

#### 问题六

Q6: 在 $1$ 到 $n$ 的自然数中选择 $k$ 个，选出的数两两不相邻，求方案数。

A6: 考虑 $n-k+1$ 个空隙插入 $k$ 块板，注意这里是组合数 $C_{n-k+1}^k$ 而不是排列。

## 9.4 例题

排列组合的题一般有两种，一种是看着就是数学题去推公式，还有一种就是给了你某些操作，你考察操作的一些性质并结合分类讨论抽象一个组合数学的模型，然后解决问题。

### P1313 [NOIP 2011 提高组] 计算系数

直接套二项式定理：

$(ax+by)^k=\sum_{i=0}^{k} C_k^i (ax)^i(by)^{k-i}=\sum_{i=0}^{k} C_k^i a^ib^{k-i} x_iy_{k-i}$所以答案是 $C_k^m x^n y^m$。代码就不给了。

### AT_abc167_e [ABC167E] Colorful Blocks

考虑枚举恰好有 $i$ 对相邻元素颜色相同的方案数，将相同颜色的元素合并，就剩下 $n-i$ 个元素。

根据计数原理的染色例题，我们知道答案为 $m(m-1)^{n-i-1}$。同时还要乘上 $n-1$ 对元素中选出 $i$ 对的方案数，最终答案为

$\sum_{i=0}^k m(m-1)^{n-i-1} C_{n-1}^i$这个题深挖的话，其实属于二项式反演中“钦定”转“恰好”的部分。

### P1771 方程的解

求出 $x \gets x^x \bmod 1000$ 以后这题就是插板法例题 1，答案为 $C_{x-1}^{k-1}$。定义法算组合数，注意一下先乘后除。难点在于高精度。

```cpp
int k, x;
BigInteger C(int n, int m) {
	if (n < m) return 0;
	BigInteger res = 1;
	for (int i = 1; i <= m; i++) {
		res *= n - i + 1;
		res /= i;
	} return res;
}

void _main() {
	cin >> k >> x;
	x = i_pow(x, x, 1000).to_int64();
	cout << C(x - 1, k - 1);
}
```

### P3223 [HNOI2012] 排队

高中月考题（

考虑减法原理，用女生不相邻的方案数减去女生不相邻而老师相邻的方案数。

求女生不相邻的方案数，用插空法，如果已经排好了 $2$ 个老师和 $n$ 个男生，则会形成 $n+3$ 个空位，在空位上排列 $m$ 个女生即可。由乘法原理，方案数是 $A_{n+2}^{n+2} A_{n+3}^m$。

再考虑求女生不相邻而老师相邻的方案数。用捆绑法，现将老师视为整体，内部方案数为 $A_2^2$；再用插空法，一个老师的整体与 $n$ 个男生形成 $n+1$ 个空位，同理可得方案数为 $A_{n+1}^{n+1}A_{n+2}^{m}$。

综上所述，答案为

$A_{n+2}^{n+2} A_{n+3}^m-A_2^2A_{n+1}^{n+1}A_{n+2}^{m}$注意要用高精度。

```cpp
int n, m;
BigInteger A(int m, int n) {
	BigInteger res = 1;
	for (int i = n - m + 1; i <= n; i++) res *= i;
	return res;
}

void _main() {
	cin >> n >> m;
 	cout << A(n + 2, n + 2) * A(m, n + 3) - A(2, 2) * A(n + 1, n + 1) * A(m, n + 2);
}
```

### AT_abc110_d [ABC110D] Factorization

唯一难的一步就是想到将 $M$ 分解质因数。

记 $M={p_1}^{c_1} {p_2}^{c_2} {p_3}^{c_3} \cdots$，只需要把 $c_i$ 个 $p_i$ 分到 $n$ 组，由插板法例题 2 得答案为 $C_{n+c_i-1}^{n-1}$。乘法原理合并答案。

```cpp
const int N = 2e5 + 5;
int n, m;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n >> m;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 1;
	for (int i = 2; i * i <= m; i++) {
		if (m % i) continue;
		int c = 0;
		while (m % i == 0) m /= i, c++;
		res *= C(n + c - 1, n - 1);
	}
	if (m != 1) res *= n;
	cout << res;
}
```

### P11250 [GESP202409 八级] 手套配对

首先先从 $n$ 对手套中拿出 $k$ 对，方案数 $C_n^k$。又因为要恰好拿走 $k$ 对手套，说明剩下的 $m-2k$ 只手套中不能同时选走一对，从其中取出 $m$ 对左或右手套，由乘法原理得答案为 $2^{m-2k} \times C_{n-k}^{m-2k}$，最后再用乘法原理合并答案。预处理组合数用杨辉三角即可。

```cpp
const int N = 2005;
int n, m, k;
modint c[N][N];

void _main() {
	cin >> n >> m >> k;
	if (m < 2 * k) return cout << 0 << '\n', void();
	cout << c[n][k] * c[n - k][m - 2 * k] * modint(2).pow(m - 2 * k) << '\n';
} signed main() {
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	int t = 1; for (cin >> t; t--; ) _main();
}
```

### P6870 [COCI 2019/2020 #5] Zapina

用 $dp_{i,j}$ 表示前 $i$ 个人分配 $j$ 道题的合法方案数。分类讨论：

1. 让第 $i$ 个人满意，剩下 $j-i$ 道题随便分，由乘法原理得答案为 $(i-1)^{j-i} C_i^j$。
2. 让第 $i$ 个人不满意，枚举给他分几道题加起来即可。

由加法原理合并答案，复杂度 $O(n^3)$，注意一下边界。

```plaintext
const int N = 355;
int n;
mint dp[N][N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n;
	fac[0] = ifac[0] = 1, dp[1][1] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			if (j >= i) dp[i][j] = mint(i - 1).pow(j - i) * C(j, i);
			for (int k = 0; k <= j; k++) {
				if (i != k) dp[i][j] += dp[i - 1][j - k] * C(j, k);
			}
		}
	} cout << dp[n][n];
}
```

### P1350 车的放置

线性做法。设 $f(n,m,k)$ 表示在 $n \times m$ 的网格中放置 $k$ 个车的方案数。枚举在上方棋盘放置多少个车 $i$，根据加法原理答案为

$\sum_{i=0}^k f(a,b,i) \times f(a+c-i,d,k-i)$考虑算出 $f(n,m,k)$。考虑 $f(n,n,n)$ 就是将 $n$ 行全排列，方案数为 $n!$。从 $n\times m$ 的网格中选出一个 $k \times k$ 的子图即可。故

$f(n,m,k)=C_n^k C_m^k k!$问题解决。

```cpp
const int N = 2e3 + 5;
int a, b, c, d, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint f(int n, int m, int k) {return C(n, k) * C(m, k) * fac[k];}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> a >> b >> c >> d >> k;
	mint res = 0;
	for (int i = 0; i <= k; i++) {
		res += f(a, b, i) * f(a + c - i, d, k - i);
	} cout << res;
}
```

### CF1436C Binary Search

考虑二分查找的过程，由于 $n$ 是固定的，则二分查找的路径是唯一的，因此我们可以求出一定小于等于 $x$ 的数的个数，一定大于 $x$ 的数的个数，分别记作 $a,b$。那么在小于等于 $x$ 的 $x-1$ 个数中，就要找 $a-1$ 个数出来排列（因为还有一个数等于 $x$） ，而大于 $x$ 的 $n-x$ 个数中找 $b$ 个来排列，剩下的任意排列，是全排列。

由乘法原理可得答案

$A_{x-1}^{a-1} A_{n-x}^{b} A_{n-a-b}^{n-a-b}$计算排列数也可以用逆元法。

```cpp
const int N = 1005;
int n, x, pos;
mint fac[N], ifac[N];
mint A(int m, int n) {
	if (m > n) return 0;
	return fac[n] * ifac[n - m];
}

void _main() {
	cin >> n >> x >> pos;
	int l = 0, r = n, a = 0, b = 0;
	while (l < r) {
		int mid = (l + r) >> 1;
		if (mid <= pos) l = mid + 1, a++;
		else r = mid, b++;
	} fac[0] = 1, ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cout << A(a - 1, x - 1) * A(b, n - x) * A(n - a - b, n - a - b);
}
```

### P9306 「DTOI-5」进行一个排的重 (Minimum Version)

考虑 $f(a)$ 的计算方法，可以发现就是 $p_i,q_i$ 是否为 $[1,i]$ 的前缀最值。显然，若存在 $i \in [1,n]$ 使得 $p_i=q_i=n$，直接把这个换到前面去，其他的数任意排列都不会产生贡献，因此答案为 $2$ 和 $(n-1)!$。

通过上述讨论，我们发现 $p_i=n$ 和 $q_j=n$ 的位置是关键的。若不存在上述 $i$，手玩一下把 $p_i=n$ 的一项放到前面去，可以构造答案为 $3$。方案如下：第一项贡献为 $2$，而 $q_j$ 必然产生 $1$ 的贡献，如果不产生其他贡献，就必须在 $q_i$ 前放小于它的数。逆用乘法原理，在 $(n-1)!$ 的原方案中除去 $n-q_i$，故答案为 $\dfrac{(n-1)!}{n-q_i}$。把 $q_j$ 放到前面的方案同理，由加法原理合并答案为

$\dfrac{(n-1)!}{n-q_i}+\dfrac{(n-1)!}{n-p_j}$代码分类讨论一下即可。

```cpp
const int N = 5e5 + 5;
int n, p[N], q[N];
mint factorial(int x) {
	mint res = 1;
	for (int i = 2; i <= x; i++) res *= i;
	return res;
}
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) cin >> q[i];
	int i = 1, j = 1;
	for (int x = 1; x <= n; x++) {
		if (p[x] == n) i = x;
		if (q[x] == n) j = x;
	}
	if (i == j) cout << "2 " << factorial(n - 1);
	else cout << "3 " << factorial(n - 1) / (n - q[i]) + factorial(n - 1) / (n - p[j]);
}
```

### CF571A Lengthening Sticks

考虑求合法数目，发现 $a+b>c$ 性质不太好。正难则反，用减法原理，用总数减去不合法的数目。

先求总数。枚举加上的数总和为 $i \in [1,l]$，加到 $3$ 个数上，用插板法，$k$ 个小球之间插 $2$ 块板，方案数为 $C_{i+2}^2$，且 `0, 0, 0` 也属于总数，故总数

$1+\sum_{i=1}^{l}C_{i+2}^2=1+\sum_{i=1}^{k}\dfrac{(i+1)(i+2)}{2}$再考虑不合法的方案。不妨设 $c$ 为最长边，枚举 $i \in [0,l]$ 分配给 $c$，则 $l-i$ 个数分配给 $a,b$，且要求 $a+b \le c$，所以不合法分配为 $u=\min(c+i-a-b, l-i)$，方案数为 $C^{2}_{u+2}=\dfrac{(u+1)(u+2)}{2}$，加法原理合并方案。然后对于 $a,b$ 为最长边同理。

```cpp
#define int long long
int a, b, c, l;
int solve(int a, int b, int c) {
	int res = 0;
	for (int i = 0; i <= l; i++) {
		int u = min(c + i - a - b, l - i);
		if (u >= 0) res += (u + 1) * (u + 2) / 2;
	} return res;
}

void _main() {
	cin >> a >> b >> c >> l;
	int res = 1;
	for (int i = 1; i <= l; i++) res += (i + 1) * (i + 2) / 2;
	res -= solve(a, b, c), res -= solve(a, c, b), res -= solve(b, c, a);
	cout << res;
}
```

### CF1929F Sasha and the Wedding Binary Search Tree

BST 题经典套路中序遍历，问题转化为给 $-1$ 赋值使序列单调不降的方案数。进一步地，对于两个已经确定的点 $i,j$，则对 $(i,j)$ 中的数产生限制 $num \in [a_i,a_j]$，于是我们只需解决这个问题：

- 给出一个长为 $n$ 的序列，值域为 $[l,r]$，求让其单调不降的方案数。

很遗憾的是笔者赛时没有做出来。考虑先把第 $i$ 个数加上 $i$，则单调不降转为严格递增。而递增序列直接选出 $n$ 个不同的数即可，值域为 $[l+1,r+n]$，故答案就是 $C_{r-l+n}^{n}$。或者考虑插板法，$n$ 块板子插入 $r-l+n$ 个空也能得出来。

注意 $c$ 很大，直接逆元法会 RE，但 $\sum n \le 10^6$，所以分子可以暴力，仍然处理一下逆元。

```cpp
const int N = 2e6 + 5;
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	//return fac[n] * ifac[m] * ifac[n - m];
	mint res = 1;
	for (int i = n - m + 1; i <= n; i++) res *= i;
	return res * ifac[m];
} mint solve(int n, int l, int r) {
	if (n <= 0 || l > r) return 1;
	return C(r - l + n, n);
}

int n, c, a[N], ls[N], rs[N], v[N];
void dfs(int rt) {
	if (rt == -1) return;
	dfs(ls[rt]), a[++a[0]] = v[rt], dfs(rs[rt]);
}

void _main() {
	cin >> n >> c;
	for (int i = 1; i <= n; i++) cin >> ls[i] >> rs[i] >> v[i];
	a[0] = 0, dfs(1);
	mint res = 1;
	int l = 0;
	for (int i = 1; i <= n; i++) {
		if (a[i] == -1) continue;
		res *= solve(i - l - 1, l ? a[l] : 1, a[i]);
		l = i;
	}
	res *= solve(n - l, l ? a[l] : 1, c);
	cout << res << '\n';
}
```

### OpenJudge 9275. [USACO2009 Feb] Bullcow

模拟赛秒了。问题等价于：在 $1 \sim n$ 的数中去掉若干个数，使得两两之差 $\ge k$。

和上面那题的 trick 一样，令 $a_i \gets a_i-(i-1)k$，则转为严格递增方案数，插板法知答案为 $C_{n-(i-1)k}^i$。复杂度 $O(n)$。

```cpp
const int N = 1e6 + 5;
int n, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> k;
	mint res = 1;
	for (int i = 1; i <= n; i++) res += C(n - (i - 1) * k, i);
	cout << res;
}
```

### *P5689 [CSP-S2019 江西] 多叉堆

看到题目中的操作形式，想到带权并查集。我们设当前操作是把 $u$ 接到 $v$ 上。那么 $v$ 的位置只能填 $0$。

维护 $a_x$ 表示答案，$s_x$ 表示树的大小。填入 $u$ 子树中的数字就有 $C_{s_v-1}^{s_u}$ 种选择方案，剩下的数字填入 $v$ 子树中。

根据乘法原理，令 $a_v \gets a_ua_v C_{s_v-1}^{s_u}$。注意带权并查集不能启发式合并，复杂度 $O(q \log n)$。

```cpp
const int N = 3e5 + 5;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int n, q, opt, x, y, last;
int fa[N], sz[N];
mint w[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
void unite(int x, int y) {
	x = find(x), y = find(y);
	if (x == y) return;
	fa[x] = y, sz[y] += sz[x], w[y] *= w[x] * C(sz[y] - 1, sz[x]);
}

void _main() {
	cin >> n >> q;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	iota(fa + 1, fa + n + 1, 1), fill(sz + 1, sz + n + 1, 1), fill(w + 1, w + n + 1, 1);
	while (q--) {
		cin >> opt >> x;
		if (opt == 1) {
			cin >> y;
			x = (x + last) % n + 1, y = (y + last) % n + 1;
			unite(x, y);
		} else {
			x = (x + last) % n + 1;
			cout << (last = w[find(x)].val) << '\n';
		}
	}
}
```

### *CF1696E Placing Jinas

显然是从格子 $(0,0)$ 开始操作，一路递推，故设 $(x,y)$ 的末值为 $f_{x,y}$，则

$f_{x,y}=f_{x-1,y}+f_{x,y-1}$对比杨辉三角的计算方法（组合数性质 2）

$C_{n}^{m}=C_{n-1}^{m}+C_{n-1}^{m-1}$发现两者很像，考虑用组合数表示 $f_{x,y}$。对比两者系数可得

$f_{x,y}=C_{x+y}^{x}$因此答案为

$\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} f_{i,j}=\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} C^{i}_{i+j}$预处理逆元后复杂度为 $O(nV)$，无法通过。所以得推波式子：

$$
\begin{aligned}
ans&=\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} f_{i,j}\\
&=\sum_{i=0}^{n} (f_{i,0}+f_{i,1}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,0}+f_{i,1}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,1}+f_{i,2}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,2}+f_{i,3}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} f_{i+1,a_i-1+1}\\
&=\sum_{i=0}^{n} C_{i+a_i}^{i+1}
\end{aligned}
$$

在推式子的过程中，利用 $f_{x,y}=f_{x-1,y}+f_{x,y-1}$ 不断合并相邻两项即可。还有一种方法是化成组合数求和后裂项。

采用预处理逆元求组合数，复杂度可以做到 $O(n)$。注意 $a_i+i$ 可以到 $4\times 10^{5}$，预处理范围要开大。

```cpp
const int N = 4e5 + 5;
int n, a[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n;
	for (int i = 0; i <= n; i++) cin >> a[i];
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 0;
	for (int i = 0; i <= n; i++) res += C(i + a[i], i + 1);
	cout << res;
}
```

### *[模拟赛] 马戏表演

> 对于长为 $n$ 的排列 $a$，设 $a_i$ 表示 $p_i$ 成为了多少个区间最大值。求有多少排列满足 $\forall i \in [1,n],c_i \le m$。对给出的质数 $p$ 取模。
>
> $n \le 10^7$，$n \le m \le C_{n+1}^2$，$10^8 \le p \le 10^9$。

好题。赛时场切之，喜提机房 rk1。

注意到合法的瓶颈是最大值。考虑从最大值的位置入手 DP。

设 $f(n)$ 表示长为 $n$ 的排列的答案。若 $\lceil \dfrac{n}{2}\rceil \times (\lfloor \dfrac{n}{2} \rfloor+1) \le m$，则所有排列都合法，$f(n)=n!$。

对于其他情况，枚举最大值的位置 $i$，手玩一下发现对于长度较小的那一侧一定合法。不妨钦定 $i \le \lfloor \dfrac{n}{2} \rfloor$，则一定合法的就是左侧。根据对称性答案乘 $2$ 即可。根据加法原理得到转移：

$f(n)=2\sum_{i \le \lfloor n/2\rfloor, i(n-i+1) \le m} \dfrac{A_n^i f(n-i)}{n}$解释一下，从 $n$ 个中选择 $i$ 个定为一定合法的部分。除以 $n$ 是因为不能选择最大值。

得到 $O(n^2)$ 的做法。推式子：

$$
\begin{aligned}
f(n)&=2\sum\dfrac{A_n^i f(n-i)}{n}\\
&=\dfrac{2}{n}\sum \dfrac{n!}{(n-i)!} f(n-i)\\
&=\dfrac{2n!}{n}\sum \dfrac{f(n-i)}{(n-i)!} 
\end{aligned}
$$

解一元二次不等式得 $i \in [\dfrac{i+1-\sqrt{\Delta}}{2},\dfrac{i+1+\sqrt{\Delta}}{2}]$，其中 $\Delta=(i+1)^2-4m$。注意到二次函数的对称轴是 $\dfrac{n}{2}$，说明我们直接取 $i \le \lfloor \dfrac{i+1-\sqrt{\Delta}}{2} \rfloor$ 即可。

到这一步，可以发现求和里的东西只与 $n-i$ 有关，前缀和优化即可。

需要求 $n^{-1}$ 和 $(n!)^{-1}$，都能线性做。复杂度 $O(n)$。

```cpp
#define int long long
const int N = 1e7 + 5;
int c, n, m, p;
mod32 f[N], fac[N], ifac[N], inv[N], g[N];
mod32 A(int n, int m) {return fac[n] * ifac[n - m];}

void _main() {
	cin >> c >> n >> m >> p;
	mod32{}.set_mod(p);
	fac[0] = 1;
	for (int i = 1; i <= n + 1; i++) {
		fac[i] = fac[i - 1] * i;
		inv[i] = (i == 1 ? 1 : -inv[p % i] * (p / i));
	}
	ifac[n + 1] = ~fac[n + 1];
	for (int i = n; i >= 1; i--) ifac[i] = ifac[i + 1] * (i + 1);
	for (int i = 0; i <= n; i++) {
		if ((i / 2 + (i & 1)) * (i / 2 + 1) <= m) {
			f[i] = fac[i];
		} else {
			int delta = (i + 1) * (i + 1) - 4 * m;
			int j = 1.0 * (i + 1 - sqrt(delta)) / 2;
			f[i] = (g[i - 1] - g[i - j - 1]) * inv[i] * fac[i] * 2;
		}
		g[i] = g[i - 1] + f[i] * ifac[i];
	} cout << f[n];
}
```

### *P14254 分割（divide）

好题。

不明白赛时在干啥，开场 1h 觉得 T2 不可做直接跳题，大战 2h T3 喜提 4pts，回来看 T2 发现选的点只能是同一层，仅剩 30min 大战排列组合翻盘失败喜提 12pts，赛后 20min 改出 T2。

- 观察 1：$S_i$ 都是一段连续区间，记作 $[l_i,r_i]$。

证明：显然。
- 观察 2：所有选点必定在同一层内部。

证明：反证法，若 $\exists j,d_{b_j}>d_{b_1}$，则 $\cap_{i=2}^{k+1}$ 的左端点 $\ge d_{b_j}>d_{b_1}$，与 $S_1=\cap_{i=2}^{k+1}$ 矛盾。

于是对每一层分开考虑，最后加法原理合并答案。

预处理点 $i$ 的深度 $l_i$ 与子数内最大深度 $r_i$，则选择 $i$ 的深度区间为 $[l_i,r_i]$。

设 $\max S_1=d_{\max}$，则 $\forall i \in [2,n],r_{b_i} \ge d_{\max}$ 且 $\exists i,r_{b_i}=d_{\max}$。这是合法的充要条件。对这个东西进行计数即可。考虑拆贡献，二分出 $r_i=x$ 的点有 $a$ 个，$r_i > x$ 的点有 $b$ 个，减法原理得到

$a(A_{a+b-1}^{k-1}-A_{b}^{k-1})$特别地，$b=k-1$ 时方案都合法，不用减去 $A_{b}^{k-1}$。复杂度 $O(n \log n)$。

由于改题代码是赛后一边玉玉一边写的，这里的代码是第二天重构的。

```cpp
const int N = 1e6 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
mint fac[N], ifac[N];
int n, k, u, l[N], r[N];
mint A(int n, int m) {return n < m ? 0 : fac[n] * ifac[n - m];}

vector<int> level[N];
void dfs(int u) {
	r[u] = l[u];
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		l[v] = l[u] + 1, dfs(v), r[u] = max(r[u], r[v]);
	}
	level[l[u]].emplace_back(r[u]);
}

void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) cin >> u, add_edge(u, i);
	l[1] = 1, dfs(1);
	for (int i = 1; i <= r[1]; i++) sort(level[i].begin(), level[i].end());
	mint res = 0;
	for (int i = 2; i <= n; i++) {
		int len = level[l[i]].size();
		if (k >= len) continue;
		int x = lower_bound(level[l[i]].begin(), level[l[i]].end(), r[i]) - level[l[i]].begin();
		int y = upper_bound(level[l[i]].begin(), level[l[i]].end(), r[i]) - level[l[i]].begin() - 1;
		int a = y - x, b = len - y - 1;
		if (a <= 0 || a + b < k) continue;
		res += A(a + b, k - 1);
		if (b > k - 1) res -= A(b, k - 1);
	} cout << res;
}
```

### *P7961 [NOIP2021] 数列

套路：在 DP 状态中记录进位。

考虑数位 DP 结合计数。设 $dp_{i,j,k,p}$ 表示考虑到 $S$ 的第 $i$ 位，已经确定了 $j$ 个 $a$ 中的元素，前 $i$ 位的 $\operatorname{popcount}$ 为 $k$，向下一位进位为 $p$ 的方案数。

填表是困难的。考虑刷表转移。

讨论第 $i$ 位，枚举 $a$ 中存在 $c$ 个 $i$，则贡献为 $c$，加上进位得到 $1$ 的个数为 $p+c$。因为每两个进一位，下一个进位就是 $\lfloor \dfrac{p+c}{2}\rfloor$。同时 $\operatorname{popcount}$ 就应该加上 $(p+c) \bmod 2$。

转移方程：

$dp_{i,j,k,p} \times v_j \times C_{n-j}^{c} \to dp_{i+1,j+c,k+(p+c)\bmod 2, \lfloor (p+c)/2 \rfloor}$答案为

$\sum_{k+\operatorname{popcount(p)} \le K} dp_{m+1,n,k,p}$复杂度 $O(n^4 m)$，用杨辉三角处理组合数跑的飞快。所以这个题最难的是设计 DP 状态。

```cpp
const int N = 105;
int n, m, h, v[N];
mint C[N][N], dp[N][35][35][16];

void _main() {
	for (int i = 0; i < N; i++) C[i][0] = 1, C[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) C[i][j] = C[i - 1][j] + C[i - 1][j - 1];
	}
	cin >> n >> m >> h;
	for (int i = 0; i <= m; i++) cin >> v[i];
	dp[0][0][0][0] = 1;
	for (int i = 0; i <= m; i++) {
		for (int j = 0; j <= n; j++) {
			for (int k = 0; k <= h; k++) {
				for (int p = 0; p <= n / 2; p++) {
					for (int c = 0; c <= n - j; c++)
						dp[i + 1][j + c][k + (c + p) % 2][(c + p) >> 1]
						+= dp[i][j][k][p] * C[n - j][c] * mint(v[i]).pow(c);
				}
			}
		}
	} mint res = 0;
	for (int k = 0; k <= h; k++) {
		for (int p = 0; p <= n / 2; p++) {
			if (k + popcount(p) <= h) res += dp[m + 1][n][k][p];
		}
	} cout << res;
}
```

## 10. 排列组合进阶

由于把这坨东西放到上面会导致目录阅读体验较差，所以把这些较难的内容单独开出来了。

## 10.1 排列进阶

### *10.1.1 康托展开

**康托展开**解决的是求排列字典序的问题。先给出公式：

$1+\sum_{i=1}^{n} rk_i \times (n-i)!$其中 $rk_i$ 表示 $[i,n]$ 中有多少个数小于 $a_i$，即 $a_i$ 的后缀排名。理解一下这个公式，字典序就是比当前排列小的排列数目，贪心地枚举 $i$，使得第 $i$ 位小于 $a_i$，而后置位与字典序无关。那么我们就需要把 $i$ 后面小于 $a_i$ 的数换到前面，且根据全排列的原理有 $(n-i)!$ 种方案。

康托展开的正过程和逆过程都可以用数据结构优化到 $O(n \log n)$。一般地，康托展开常用于对排列的哈希。

### 10.1.2 对换

对于排列 $p$，选择两个不等的数 $i,j$ 并交换 $p_i,p_j$ 的过程称为一次**对换**。若 $|i-j|=1$，则称为相邻对换。

有定理：一个排列进行一次对换，逆序对数的奇偶性改变。

现在有一个经典问题：给定排列 $p_1,p_2$，求对 $p_1$ 最少做多少次对换操作变成 $p_2$。解法是对于 $i \in [1,n]$，将 $p_1$ 向 $p_2$ 连一条无向边，则用 $n$ 减去连通块个数即为答案。复杂度 $O(n)$。感性理解一下正确性：这个图形成若干环，每个含 $x$ 个点的环需要至少 $x-1$ 次对换才能使得环上所有点变成自环。所以这个做法是对的。

一般地，排列对换问题往往使用图论建模思想，用起始位置向目标位置连边。

## *10.2 exLucas 法

- 优点：任意模数，预处理约为 $O(p \log p)$，查询 $O(\log p)$，同样适用于模数小而 $n,m$ 很大的情况。
- 缺点：码量很大。

exLucas 跟 Lucas 没有半毛钱关系。

将模数 $p$ 质因数分解为 $p=p_1^{a_1} p_2^{a_2} \cdots$，然后计算 $C_n^m \bmod p^a$，最后再把答案用 exCRT 合并。

现在的重点是算 $C_n^m \bmod p^a$，由定义式得所求即为 $\dfrac{n!}{m!(n-m)!} \bmod p^a$，只要求出阶乘及逆元即可。先将阶乘中 $p$ 的倍数算掉，即 $\lfloor  \dfrac{n}{p}\rfloor!$，而剩余项存在循环节，可以一起计算，凑不进循环节的单独算。

For example：

$$
\begin{aligned}
20!&=1\times 2\times 3\times 4\times 5\times 6\times 7\times 8\times 9\times 10\times 11\times 12\times 13\times 14\times 15\times 16\times 17\times 18\times 19\times 20\\
&=(1\times 2\times 4\times 5\times 7\times 8\times 10\times 11\times 13\times 14\times 16\times 17\times 19\times 20) \times 6! \times 3^6\\
&=(1\times 2 \times 4 \times 5 \times 7 \times 8)^2\times 19 \times 20 \times 6! \times 3^6
\end{aligned}
$$

至于阶乘逆元，用 exGCD 求得即可。

```cpp
long long power(long long a, long long b, long long p) {
    long long res = 1; for (a %= p; b; b >>= 1) {
        if (b & 1) res = res * a % p;
        a = a * a % p;
    } return res;
}
void exgcd(long long a, long long b, long long& x, long long& y) {
    b == 0 ? (x = 1, y = 0) : (exgcd(b, a % b, y, x), y -= a / b * x);
}
long long inverse(long long x, long long p) {
    long long a, b;
    return exgcd(x, p, a, b), (a % p + p) % p;
}
long long calc(long long n, long long x, long long p) {
    if (n == 0) return 1;
    long long s = 1;
    for (long long i = 1; i <= p; i++) {
        if (i % x) s = s * i % p;
    } s = power(s, n / p, p);
    for (long long i = n / p * p + 1; i <= n; i++) {
        if (i % x) s = i % p * s % p;
    } return s * calc(n / x, x, p) % p;
}
long long multilucas(long long m, long long n, long long x, long long p) {
    int cnt = 0;
    for (long long i = m; i; i /= x) cnt += i / x;
    for (long long i = n; i; i /= x) cnt -= i / x;
    for (long long i = m - n; i; i /= x) cnt -= i / x;
    return power(x, cnt, p) % p * calc(m, x, p) % p * inverse(calc(n, x, p), p) % p
        * inverse(calc(m - n, x, p), p) % p;
}
long long x[20];
int crt(int n, long long* a, long long* m) {
    long long mod = 1, res = 0;
    for (int i = 1; i <= n; i++) mod *= m[i];
    for (int i = 1; i <= n; i++) {
        x[i] = mod / m[i];
        long long x0 = -1, y0 = -1;
        exgcd(x[i], m[i], x0, y0);
        res += a[i] * x[i] * (x0 >= 0 ? x0 : x0 + m[i]);
    } return res % mod;
}
long long exlucas(long long m, long long n, long long p) {
    int len = 0;
    long long p0[20], a0[20];
    for (long long i = 2; i * i <= p; i++) {
        if (p % i) continue;
        p0[++len] = 1;
        while (p % i == 0) p0[len] *= i, p /= i;
        a0[len] = multilucas(m, n, i, p0[len]);
    }
    if (p > 1) p0[++len] = p, a0[len] = multilucas(m, n, p, p);
    return crt(len, a0, p0);
}
```

[P4720 【模板】扩展卢卡斯定理/exLucas](https://www.luogu.com.cn/problem/P4720)。

## *10.3 多重集的组合数

设 $S=\{n_1 \cdot a_1,n_2\cdots a_2,\cdots,n_k \cdot a_k\}$ 是由 $n_i$ 个 $a_i$ 所组成的多重集。设 $n=\sum n_i$，对于整数 $r$，选出 $S$ 的一个大小为 $r$ 的子集的方案数为

$C_{k+r-1}^{k-1}-\sum_{i=1}^k C^{k-1}_{k+r-n_i-2}+\sum_{1 < i < j \le k} C^{k-1}_{k+r-n_i-n_j-3} - \cdots + (-1)^k C_{k+r-\sum_{i=1}^{k} n_i-(k+1)}^{k-1}$特别地，若 $r \le \min n_i$，则答案为 $C_{k+r-1}^{k-1}$。

### 证明

先讨论 $r \le \min n_i$ 的情况，等价于求 $T = \{x_1 \cdot a_1,x_2\cdots a_2,\cdots,x_k \cdot a_k\} \subseteq S$ 的数目，且满足 $\sum x_i=r$。由插板法例题 2 得到方案数为 $C_{k+r-1}^{k-1}$。

当 $n_i \to +\infty$ 时，相当于 $n_i$ 无限制，答案与上面相同。考虑减法原理，用合法减去不合法。

进一步，设 $S_i$ 表示至少包含 $n_i+1$ 个 $a_i$ 的多重集。从 $S$ 中取出 $n_i+1$ 个 $a_i$，再选 $r-n_i-1$ 个元素即可，同理答案为 $C_{k+r-n_i-2}^{k-1}$。

考虑到这样会算多，再进一步，从 $S$ 中取出 $n_i+1$ 个 $a_i$，$n_j+1$ 个 $a_j$，再任选 $r-n_i-n_j-2$ 个元素得到 $S_i \cap S_j$。类比可得 $\cap S_i$ 的情况。由容斥原理得：

$$
\begin{aligned}
|\cup_{i=1}^{n} S_i|&=\sum_{m=1}^n (-1)^{m-1} \sum_{a_i<a_{i+1}} |\cap _{i=1}^m S_{a_i}|\\
&=\sum_{i=1}^k C^{k-1}_{k+r-n_i-2}-\sum_{1 < i < j \le k} C^{k-1}_{k+r-n_i-n_j-3} +\cdots + (-1)^{k-1} C_{k+r-\sum_{i=1}^{k} n_i-(k+1)}^{k-1}
\end{aligned}
$$

这样就得到了不合法的情况总数。最终用 $C^{k-1}_{k+r-1}$ 减去即得。

## 10.4 例题

依次是康托展开、排列对换、二项式定理和一些比较难的计数题。还有不涉及多项式科技的图论计数题。

### P5367 【模板】康托展开

康托展开板子题，但你要是直接按公式求是 $O(n^2)$ 的。显然枚举 $i$ 不能删，瓶颈在计算 $rk_i$，使用权值树状数组维护即可。

实现时，可以把树状数组上每个位置都加一，然后出现了这个数再减一，这样 $rk_i$ 转化为树状数组前缀求和。复杂度 $O(n \log n)$。

```cpp
const int N = 1e6 + 5;
int n, a[N];

int tr[N];
void add(int x, int c) {for (; x <= n; x += (x & -x)) tr[x] += c;}
int ask(int x) {
	int res = 0;
	for (; x != 0; x -= (x & -x)) res += tr[x];
	return res;
}

mint fac[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, add(i, 1);
	mint res = 1;  // 初值为1
	for (int i = 1; i <= n; i++) res += fac[n - i] * (ask(a[i]) - 1), add(a[i], -1);
	cout << res;
}
```

### *P3014 [USACO11FEB] Cow Line S

这题多了一个给定排名求排列的操作，就是把康托展开的过程反过来。具体可见代码。并且这个逆操作也是可以用权值树状数组 / 权值线段树维护的。

```cpp
int n, q, a[N], ans[N];
long long x, fac[N], w[N];
char opt;

long long tr[N];
void add(int x, long long c) {for (; x <= n; x += (x & -x)) tr[x] += c;}
long long ask(int x) {
	long long res = 0;
	for (; x != 0; x -= (x & -x)) res += tr[x];
	return res;
}
int kth(int k) {
	long long pos = 0, x = 0;
	for (int i = __lg(n); i >= 0; i--) {
		x += (1 << i);
		if (x >= n || pos + tr[x] >= k) x -= (1 << i);
		else pos += tr[x];
	} return x + 1;
}

void _main() {
	cin >> n >> q;
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	while (q--) {
		memset(tr, 0, sizeof(tr));
		cin >> opt;
		if (opt == 'Q') {
			for (int i = 1; i <= n; i++) cin >> a[i], add(i, 1);
			long long res = 1;
			for (int i = 1; i <= n; i++) res += fac[n - i] * (ask(a[i]) - 1), add(a[i], -1);
			cout << res << '\n';
		} else if (opt == 'P') {
			cin >> x; x--;
			for (int i = 1; i <= n; i++) w[n - i + 1] = x % i, x /= i, add(i, 1);
			for (int i = 1; i <= n; i++) ans[i] = kth(w[i] + 1), add(ans[i], -1);
			for (int i = 1; i <= n; i++) cout << ans[i] << ' ';
			cout << '\n';
		}
	}
}
```

数据范围更大的逆康托展开模板：[UVA11525](https://www.luogu.com.cn/problem/UVA11525)。

### *CF1553E Permutation Shift

一个暴力是枚举 $m$ 得到新排列，然后用排列对换的做法求出最小对换次数。

有一个神秘的限制是 $3m \le n$。从这里入手，考虑对于排列 $p$，每次操作至多使得两个 $p_i,p_j$ 归位，则满足 $p_i=i$ 的位置至少有 $n-2m$ 个。

在这个问题中，对于位置 $i$ 有且仅有一个 $k$ 使得 $p_i$ 右移 $k$ 位以后满足 $p_i=i$。我们预处理出每个 $k$ 能使得多少个 $p_i$ 归位，根据抽屉原理，合法的 $k$ 的数目不超过

$\lfloor \dfrac{n}{n-2m} \rfloor$个。在本题中，这个数值不超过 $3$。加上这个剪枝即可通过。

```cpp
const int N = 3e5 + 5;
int n, m, a[N], pos[N], cnt[N], fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}

void _main() {
	memset(cnt, 0, sizeof(int) * (n + 1));
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i], pos[a[i]] = i, cnt[(i - a[i] + n) % n]++;
	vector<int> res;
	for (int k = 0; k < n; k++) {
		if (cnt[k] < n - 2 * m) continue;
		iota(fa + 1, fa + n + 1, 1);
		int c = 0;
		for (int i = 1; i <= n; i++) {
			int x = pos[i], y = (i + k - 1) % n + 1;
			x = find(x), y = find(y);
			if (x != y) fa[x] = y, c++;
		}
		if (c <= m) res.emplace_back(k);
	}
	cout << res.size() << ' ';
	for (int i : res) cout << i << ' ';
	cout << '\n';
}
```

### *AT_arc124_d [ARC124D] Yet Another Sorting Problem

看到排列对换问题，要想到图论建模，也就是把当前位置和目标位置连边。对于本题，我们把 $i$ 和 $p_i$ 之间连一条边。

设前 $n$ 个点为红点，后 $m$ 个点为白点。对 $(x,y)$ 进行一次对换就是交换 $x,y$ 的出点。以第二个样例为例：

![](https://cdn.luogu.com.cn/upload/image_hosting/zue3jk1v.png)

如果交换 $(2, 9)$，那么新图为

![](https://cdn.luogu.com.cn/upload/image_hosting/ver6cgiw.png)

如果交换 $(5,9)$，则新图为

![](https://cdn.luogu.com.cn/upload/image_hosting/1rk6jvyz.png)

我们可以发现两条结论：

1. 如果交换两个不在同一连通块内的点，则等价于在一个环上插入一条链。
2. 如果交换两个在同一连通块内的点，则原环在两个位置断开分裂为两个独立环。

最终的目标是做出 $n$ 个自环。我们可以发现：对于一个大小为 $n$ 的异色环，因为每次操作需要保留一对异色点，总次数为 $n-1$。

对于一个大小为 $n$ 的同色环，需要借助外部力量完成交换，最小次数是 $n+1$。有一种做法是对于两个异色的同色环一起操作，先将两个环合并为一个大的异色环再消除，总次数为二者大小之和。于是我们先做完异色环，然后按大小排序贪心即可。复杂度 $O(n \log n)$。

```cpp
const int N = 2e5 + 5;
int n, m, p[N], fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
vector<int> r[N], a, b;

void _main() {
	cin >> n >> m;
	iota(fa + 1, fa + n + m + 1, 1);
	for (int i = 1; i <= n + m; i++) {
		cin >> p[i];
		fa[find(i)] = find(p[i]);
	}
	for (int i = 1; i <= n + m; i++) r[find(i)].emplace_back(i);
	int res = 0;
	for (int i = 1; i <= n + m; i++) {
		if (find(i) != i) continue;
		if (r[i].size() == 1) continue;  // 自环
		if (r[i].back() <= n) a.emplace_back(r[i].size());  // 红色环
		else if (r[i][0] > n) b.emplace_back(r[i].size());  // 白色环
		else res += r[i].size() - 1;
	}
	sort(a.begin(), a.end(), greater<int>()), sort(b.begin(), b.end(), greater<int>());
	int la = a.size(), lb = b.size();
	for (int i = 0; i < min(la, lb); i++) res += a[i] + b[i];
	for (int i = min(la, lb); i < max(la, lb); i++) res += (i < la ? a[i] : b[i]) + 1;
	cout << res;
}
```

### *P4778 Counting swaps

排列对换问题，先把 $i \to a_i$ 连边，最后的目标状态是 $n$ 个自环。

容易证明将一个大小为 $n$ 的环变成 $n$ 个自环至少需要 $n- 1$ 次对换。对于一个长度为 $n$ 的环，达成最少次数的方法是将它拆成两个大小为 $x,y$ 的环，满足 $x+y=n$。令 $T(x,y)$ 表示分裂环的方案数，不难得到当且仅当 $x=y$ 时 $T(x,y)=x$，否则 $T(x,y)=x+y$.

考虑一个 DP，令 $f_n$ 表示大小为 $n$ 的环以最优步数变成自环的方案数，根据多重集的排列数得

$f_n=\sum_{x+y=n, x \le y} T(x,y) f_x f_y \dfrac{(n-2)!}{(x-1)!(y-1)!}$预处理出 $f_i$ 后，设初始排列由 $k$ 个环构成，第 $i$ 个环的大小为 $c_i$，根据多重集排列数有

$ans=\prod_{i=1}^k f_{c_i} \dfrac{(n-k)!}{\prod_{i=1}^k (c_i-1)!}$复杂度 $O(n^2 \log n)$，可以获得 30pts。

```cpp
const int N = 1e5 + 5;
int n, a[N], fa[N], cnt[N];
mint f[N], fac[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
mint T(int x, int y) {return x == y ? x : x + y;}

void init() {
	fac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i;
	f[1] = 1;
	for (int i = 2; i < 1000; i++) {
		for (int j = 1; j <= i / 2; j++) {
			f[i] += T(j, i - j) * f[j] * f[i - j] * fac[i - 2] / fac[j - 1] / fac[i - j - 1];
		}
	}
}

void _main() {
	cin >> n;
	iota(fa + 1, fa + n + 1, 1), fill(cnt + 1, cnt + n + 1, 0);
	for (int i = 1; i <= n; i++) cin >> a[i], fa[find(i)] = find(a[i]);
	for (int i = 1; i <= n; i++) cnt[find(i)]++;
	mint res = 1;
	int k = 0;
	for (int i = 1; i <= n; i++) {
		if (find(i) != i) continue;
		res *= f[cnt[i]] / fac[cnt[i] - 1], k++;
	}
	cout << res * fac[n - k] << '\n';
}
```

100pts 做法比较神秘。将 $f_n$ 的表打出来输入 OEIS 或者使用注意力，发现 $f_n=n^{n-2}$。于是就变成了 $O(n \log n)$。严格证明比较困难，这里不展开了。

```cpp
for (int i = 2; i < N; i++) f[i] = mint(i).pow(i - 2);   // 预处理 f[i] 改成这个即可
```

### [模拟赛] 宝石展览

> 现有 $n$ 种颜色的宝石，每种颜色有 $a_i$ 颗互不相同的宝石和一个值 $v_i$。
>
> 定义一种展览方案的华丽值为：对于每种颜色 $i$，设方案中有 $c_i$ 颗该颜色的宝石。若 $c_i=0$，则华丽值不变，否则增加 $(v_i)^{c_i}$。
>
> 求所有方案的华丽值对 $10^9+7$ 取模的结果。$n \le 2 \times 10^5,a_i \le 10^9$。

显然第 $i$ 种颜色有 $2^{a_i}$ 种选择。一个想法是求出 $s=\prod 2^{a_i}$ 表示总方案数，然后枚举当前颜色选 $j$ 个，则第 $i$ 种颜色的贡献为

$\dfrac{s}{2^{a_i}} \times \sum_{j=1}^{a_i} C_{a_i}^{j} \times (v_i)^j$复杂度 $O(nV)$，无法通过。观察一下后面那个东西，我们可以逆用二项式定理，即

$\sum_{j=1}^{a_i} C_{a_i}^{j} \times (v_i)^j=(v_i+1)^{a_i}-1$因为 $j$ 从 $1$ 开始，结果要减一。复杂度 $O(n \log V)$。赛时代码写的比较抽象。

```cpp
const int N = 2e5 + 5;
int n, a[N], v[N];
mint f[N], fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> v[i];
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint sum = 1, res = 0;
	for (int i = 1; i <= n; i++) f[i] = mint(2).pow(a[i]), sum *= f[i];
	for (int i = 1; i <= n; i++) {
		mint cur = 0;
		res += (mint(v[i] + 1).pow(a[i]) - 1) * (sum / f[i]);
	} cout << res;
}
```

### *CF1332E Height All the Same

很妙的性质题。我们发现操作 2 可以让任意数变成一个充分大的奇数或偶数，只要原序列中所有数奇偶性相同即可。所以我们只需考虑奇偶性。

从这个角度想，操作 1 可以让相邻两数的奇偶性改变。事实上，对于任意两个位置，我们挑选一条起终点为这两点的路径，比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/cqbhzvgl.png)

这个图里红色为起点，橙色为终点，蓝框为每次进行的操作。则黄色点都被操作两次，奇偶性不变，而起终点的奇偶性发生了改变。所以 1 操作其实是改变任意一对点的奇偶性。

当 $nm$ 为奇数时，此时高度为奇数的数目与高度为偶数的数目中，总有一个是偶数，将这个变成另外一种即可，所以所有的情况都满足限制，答案为 $(r-l+1)^{nm}$。

当 $nm$ 为偶数时，高度为奇数的数目与高度为偶数的数目不能都为奇数，也就是都为偶数。设 $[l,r]$ 中有 $a$ 个奇数，$b$ 个偶数，枚举高度为奇数的数目 $i$，答案为

$\sum_{0 \le i \le nm, 2 \mid i} C_{nm}^i a^i b^{nm-i}$复杂度 $O(nm)$，一眼二项式定理优化。只要处理好 $2 \mid i$ 即可。考虑如下结论

$$
(a+b)^{nm}=\sum_{i=0}^{nm} C_{nm}^i a^i b^{nm-i}\\
(a-b)^{nm}=\sum_{i=0}^{nm} (-1)^{nm-i} C_{nm}^i a^i b^{nm-i}
$$

当 $2 \mid i$ 时，$(-1)^{nm-i}=1$，否则为 $-1$。两式相加并简单整理得

$\sum_{0 \le i \le nm, 2 \mid i} C_{nm}^i a^i b^{nm-i}=\dfrac{(a+b)^{nm}+(a-b)^{nm}}{2}$复杂度 $O(\log nm)$。

```cpp
long long n, m, l, r;
void _main() {
	cin >> n >> m >> l >> r;
	if (n * m % 2) return cout << mint(r - l + 1).pow(n * m), void();
	long long a = r / 2 - (l - 1) / 2, b = r - l + 1 - a;
	cout << (mint(a + b).pow(n * m) + mint(a - b).pow(n * m)) / 2;
}
```

### *P4345 [SHOI2015] 超能粒子炮·改

组合数前缀和科技的板子。题意还是比较清楚的，就是求

$f(n,k)=\sum_{i=0}^{k} C_n^i \bmod 2333$打个试除法判质数可以发现 $2333$ 是质数，于是这个题适用 Lucas 定理，下面设 $p=2333$，那么

$f(n,k)=\sum_{i=0}^{k} C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{i}{p} \rfloor} C_{n \bmod p}^{i \bmod p}$接着我们把后面的 $C_{n \bmod p}^{i \bmod p}$ 按取模意义考虑贡献，且对于 $\lfloor \dfrac{i}{p} \rfloor$ 进行讨论，则

$$
\begin{aligned}
f(n,k)&=C_{\lfloor \frac{n}{p} \rfloor}^0 \sum_{i=0}^{p-1} C_{n \bmod p}^i+C_{\lfloor \frac{n}{p} \rfloor}^1 \sum_{i=0}^{p-1} C_{n \bmod p}^i+\cdots+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p}-1 \rfloor} \sum_{i=0}^{p-1} C_{n \bmod p}^i+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \sum_{i=0}^{k \bmod p} C_{n \bmod p}^i\\
&=(\sum_{i=0}^{p-1} C_{n \bmod p}^i)(C_{\lfloor \frac{n}{p} \rfloor}^0+C_{\lfloor \frac{n}{p} \rfloor}^1 +\cdots+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p}-1 \rfloor} )+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \sum_{i=0}^{k \bmod p} C_{n \bmod p}^i\\
&=f(n \bmod p,p-1) \times f(\lfloor \dfrac{n}{p} \rfloor, \lfloor \dfrac{k}{p}-1 \rfloor)+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \times f(n \bmod p,k \bmod p)
\end{aligned}
$$

对于前面的 $n \bmod p$，根据余数性质可得这个东西小于 $p$，所以我们可以直接 $O(p^2)$ 地递推法求出。对于 $\dfrac{n}{p}$，$n$ 每次至少除掉 $p$，复杂度级别为 $O(\log n)$。最后的 $C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor}$ 可以用 Lucas 定理法求出。预处理 $O(p^2)$，单次查询 $O(\log (n+k))$，但由于这个对数的底数为 $p=2333$，可以直接当作小常数。

```cpp
const int N = 2400, p = 2333;
long long q, n, k;
mint c[N][N], pre[N][N];

mint lucas(long long n, long long m) {
	if (n < m) return 0;
	if (n == m) return 1;
	return c[n % p][m % p] * lucas(n / p, m / p);
}
mint f(long long n, long long k) {
	if (k < 0) return 0;
	if (n == 0 || k == 0) return 1;
	if (n < p && k < p) return pre[n][k];
	return f(n / p, k / p - 1) * pre[n % p][p - 1] + pre[n % p][k % p] * lucas(n / p, k / p);
}

void _main() {
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (int i = 0; i < N; i++) {
		pre[i][0] = 1;
		for (int j = 1; j < N; j++) pre[i][j] = pre[i][j - 1] + c[i][j];
	}
	for (cin >> q; q--; ) cin >> n >> k, cout << f(n, k) << '\n';
}
```

### *AT_arc203_c [ARC203C] Destruction of Walls

注意到 $k <n+m-2$ 时无解，于是有解的情况只有三种。想到分类讨论。

- 当 $k=n+m-2$ 时，经典格路计数问题，答案为 $C_{n+m-2}^{m-1}$。
- 当 $k=n+m-1$ 时，就是右下的格路计数乘上一条新边。容斥一下得到新的位置有 $x=n(m-1)+m(n-1)-(n+m-2)$ 个，乘上 $C_{n+m-2}^{m-1}$ 即可。
- 当 $k=n+m$ 时，一个想法是在格路上新开两条边，容斥并套进组合数的方案数为 $C_{n+m-2}^{m-1} C^{2}_{2nm-2n-2m+2}$，喜提 WA。

因为格路存在环或者返边，如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/6z5qd9tc.png)

这种情况会算重还会算漏。

注意到，这种情况存在一个“折角”，考虑对于这种结构单独计数。最终的合法路径由 $n$ 个下，一个折角，$m-3$ 个右组成。令 $f(x,y)$ 表示将 $x$ 个下，一个折角，$y$ 个右连起来的方案数，使用减法原理，用总数减去折角在两侧的情况，有

$f(x,y)=(y+1) \times C_{x+y+1}^x-2 \times C_{x+y+1}^{x+1}$然后考虑容斥，记 $y=2nm-n-m-k+1$，最后的答案式子是

$\dfrac{y(y+1)}{2}\times C_{n+m-2}^{m-1}-(n+m-3) \times C_{n+m-4}^{n-2}+f(n,m-3)+f(m,n-3)$逆元法处理组合数即可。

```cpp
const int N = 4e5 + 5;
long long n, m, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint f(int x, int y) {
	if (x < 0 || y < 0) return 0;
	return C(x + y + 1, x) * (y + 1) - C(x + y + 1, x + 1) * 2;
}

void _main() {
	cin >> n >> m >> k;
	if (k < n + m - 2) cout << 0 << '\n';
	else if (k == n + m - 2) cout << C(n + m - 2, m - 1) << '\n';
	else if (k == n + m - 1) {
		mint x = n * (m - 1) + m * (n - 1) - (n + m - 2);
		cout << x * C(n + m - 2, m - 1) << '\n';
	} else {
		mint y = 2 * n * m - n - m - k + 1;
		cout << C(n + m - 2, m - 1) * y * (y + 1) / 2
		- C(n + m - 4, n - 2) * (n + m - 3)
		+ f(n, m - 3) + f(m, n - 3) << '\n';
	}
}
```

### *CF1227F2 Wrong Answer on test 233 (Hard Version)

妙妙套路题。考虑单个位置的贡献变化，有 $0$ 变 $1$，$1$ 变 $0$，$0$ 变 $0$，$1$ 变 $1$ 四种情况。由于题目要求 $s'>s$ 的方案数，就只需考虑 $0$ 变 $1$，$1$ 变 $0$ 的情况。而产生变化当且仅当 $h_i$ 与 $h_{i\bmod n+1}$ 不同。若原来的 $a_i=h_i$，移动后就不满足 $a'_{j}=h_{j}$，是 $1$ 变 $0$，而若 $a_i=h_j$，就是 $0$ 变 $1$。通过上述讨论发现：**$0$ 变 $1$ 的方案数等于 $1$ 变 $0$ 的方案数。**

因此，答案其实就是

$\dfrac{k^n-p}{2}$其中 $p$ 表示分数不变的方案数。现在我们只要算出 $p$ 即可。设有 $m$ 个位置使得 $h_i$ 与 $h_{i\bmod n+1}$ 不同，分数不变就是说移动时对了 $i$ 个，错了 $i$ 个，则 $2i \le m$，即 $i \in [0,\lfloor \dfrac{m}{2} \rfloor]$。枚举 $i$，考察 $i$ 产生的贡献，有三部分：

- 对了 $i$ 个，从 $m$ 个位置选出 $i$ 个，方案数 $C^i_m$；
- 错了 $i$ 个，从剩下 $m-i$ 个位置再选 $i$ 个，然后考虑不同选项，一共是错 $m-2i$ 个，且去掉正确的选项与自身，总方案是 $C^{i}_{m-i} (k-2)^{m-2i}$。
- 除这 $m$ 个以外，其他的可以任意选，方案数 $k^{n-m}$。

由乘法原理合并答案

$p=\sum_{i=0}^{\lfloor \frac{m}{2} \rfloor}C^i_mC^{i}_{m-i} (k-2)^{m-2i}k^{n-m}$注意特判 $k=1$。用逆元法求组合数即可。

```cpp
const int N = 2e5 + 5;
int n, k, a[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n >> k;
	if (k == 1) return cout << 0, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	int m = 0;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		if (a[i] != a[i % n + 1]) m++;
	} mint res = 0;
	for (int i = 0; i <= m / 2; i++) res += C(m, i) * C(m - i, i) * mint(k - 2).pow(m - 2 * i) * mint(k).pow(n - m);
	cout << (mint(k).pow(n) - res) / 2;
}
```

### *CF785D Anton and School - 2

考虑枚举子序列的最后一个左括号，可以动态统计其左侧及自身的左括号数目 $a$，右括号数目 $b$，然后枚举再选 $i$ 个括号，则其贡献为

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^iC_{b}^{i+1}$因为括号要匹配，只能枚举到 $\min(a-1,b-1)$，然后考虑组合意义，乘法原理合并两种方案。预处理逆元后复杂度是 $O(n^2)$，无法通过。

根据组合数性质 1，即对称性有

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^iC_{b}^{i+1}=\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^{a-1-i}C_{b}^{i+1}$然后应用组合数性质 5，即范德蒙恒等式化简

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^{a-1-i}C_{b}^{i+1}=C_{a+b-1}^a$于是逆元法求组合数，复杂度可以做到 $O(n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], b[N];
char s[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> (s + 1); n = strlen(s + 1);
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 1; i <= n; i++) a[i] = a[i - 1] + (s[i] == '(');
	for (int i = n; i >= 1; i--) b[i] = b[i + 1] + (s[i] == ')');
	mint res = 0;
	for (int i = 1; i <= n; i++) {
		if (s[i] == '(') res += C(a[i] + b[i] - 1, a[i]);
	} cout << res;
}
```

### CF451E Devu and Flowers

【模板】多重集的组合数。将一个盒子视作一组重复元素，根据公式计算即可。

实现上，通过二进制枚举集合 $s$，设 $s$ 在二进制下第 $i_1,i_2,\cdots,i_k$ 位为 $1$，则贡献为

$(-1)^x C_{n+m-\sum _{j=1}^k a_{i_j}-(k+1)}^{n-1}$还有一个问题是 $n \le 20$ 但是 $m \le 10^{14}$。需要把逆元法和定义法结合起来算组合数。复杂度 $O(n2^n)$。

```cpp
#define int long long
const int N = 22;
int n, m, a[N];
mint inv[N];
mint C(int n, int m) {
	if (m < 0 || n < 0 || n < m) return 0;
	if (m == 0 || mint(n) == 0) return 1;
	mint res = 1;
	for (int i = 0; i < m; i++) res *= n - i;
	for (int i = 1; i <= m; i++) res *= inv[i];
	return res;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) inv[i] = ~mint(i);
	for (int i = 1; i <= n; i++) cin >> a[i];
	mint res = C(n + m - 1, n - 1);
	for (int s = 1; s < (1 << n); s++) {
		int sum = n + m, k = 0;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) sum -= a[i], k++;
		}
		sum -= k + 1;
		if (k & 1) res -= C(sum, n - 1);
		else res += C(sum, n - 1);
	} cout << res;
}
```

## 附：排列组合专题笔记（stripe-python）

## 10. 排列组合

## 10.1 排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一列，方案数用 $A_{n}^{m}$ 表示。

考虑分步计数：第一个数有 $n$ 种选法，第二个数有 $n-1$ 种选法，这样类推下去，第 $m$ 个数就有 $n-m+1$ 种选法，因此
$$
A_n^m =n(n-1)(n-2) \cdots (n-m+1)=\dfrac{n!}{(n-m)!}
$$
规定 $0 \le m \le n$ 不成立时 $A_n^m=0$。

这一结果也记为 $n^{\underline{m}}$，读作 $n$ 的 $m$ 次**下降幂**。

当 $n=m$ 时，所有元素都参与排列，此时称为**全排列**，方案数 $A_n^n=n!$。

### 10.1.1 圆排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一圈，方案数用 $Q_{n}^{m}$ 表示。

考虑消序，可以断环为链，共有 $m$ 个断点，于是
$$
Q_{n}^{m}=\dfrac{A_{n}^{m}}{m}=\dfrac{n!}{m(n-m)!}
$$
特别地，$Q_n^n=\dfrac{A_n^n}{n}=(n-1)!$。

### 10.1.2 Lehmer 码



### 10.1.3 置换

## 10.2 组合

从 $n$ 个**不同**元素中取 $m$ 个元素组成**无序**的一个集合，方案数用 $\dbinom{n}{m}$ 表示，也记作 $C_n^m$，读作 $n$ 选 $m$。本文统一采用 $\dbinom{n}{m}$ 的记法。

考虑消序，那么只需消去 $m$ 个元素的内部排列，则
$$
\binom{n}{m}=\dfrac{A_n^m}{m!}=\dfrac{n!}{m!(n-m)!}
$$
在本章中，我们规定 $0 \le m \le n$ 不成立时 $\dbinom{n}{m}=0$。

### 10.2.1 二项式定理

**二项式定理**是一个重要的组合恒等式。定理指出：
$$
(a+b)^n=\sum _{i=0}^n \binom{n}{i} a^i b^{n-i}
$$
:::::success[组合意义]
考虑从 $n$ 个相同的因式中，选择 $i$ 个因式取 $a$，剩余 $n-i$ 个因式取 $b$，则 $a^i b^{n-i}$ 项的系数就是 $\dbinom{n}{i}$。
:::::

### 10.2.2 组合恒等式

在证明组合恒等式时，我们可以采用代数推导 / 组合意义的方法来证明。

由于部分等式的代数推导比较复杂，且没有什么启发性，因此略去。读者可以自行搜索相关证明。

- **对称性**：

$$
\binom{n}{m}=\binom{n-m}{m}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\binom{n}{n-m}\\
\iff \dfrac{n!}{m!(n-m)!}&=\dfrac{n!}{(n-m)!m!}
\end{aligned}
$$

显然成立。
:::::

:::::success[组合意义]
考虑对选出的 $m$ 个元素取补集，二者的方案数相同。
:::::

- **吸收恒等式**：

$$
\binom{n}{m}=\dfrac{n}{m} \binom{n-1}{m-1}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\dfrac{n-m+1}{m} \binom{n-1}{m-1}\\
\iff \dfrac{n!}{m!(n-m)!}&=  \dfrac{n(n-1)!}{m(m-1)!(n-m)!}\\
\iff \dfrac{n!}{m!(n-m)!} &= \dfrac{n!}{m!(n-m)!}
\end{aligned}
$$

显然成立。
:::::

根据这个恒等式，可以得到 $f(x)=\dbinom{x}{n}$ 是单峰的，在 $x=\left\lfloor \dfrac{n}{2} \right\rfloor$ 和 $x=\left\lceil \dfrac{n}{2} \right\rceil$时取得最大值。也即组合数具有**凸性**。

常用变形式：$m\dbinom{n}{m}=n\dbinom{n-1}{m-1}$。

- **加法公式**：

$$
\binom{n}{m}=\binom{n-1}{m-1}+\binom{n-1}{m}
$$

:::::success[组合意义]
考虑先确定 $n-1$ 个元素时的情形，并讨论第 $n$ 个元素是否选出。由加法原理合并。
:::::

- **同行求和**：

$$
\sum_{i=0}^n \binom{n}{i}=2^n
$$

:::::success[代数推导]

在二项式定理中令 $a=b=1$ 即证。
:::::

:::::success[组合意义]
考虑对 $n$ 个元素的子集计数，枚举集合大小为 $i$，由加法原理合并得到左侧式子；考虑每个元素是否选择，由乘法原理合并得到右侧式子。
:::::

- **奇偶求和**：

$$
\sum_{i=0}^n (-1)^i \binom{n}{i} = [n=0]
$$

在 $n \ge 1$ 时上式等价于
$$
\sum_{2 \mid i} \binom{n}{i}=\sum_{2 \nmid i} \binom{n}{i}
$$
:::::success[代数推导]

在二项式定理中令 $a=1,b=-1$ 即证。
:::::

:::::success[组合意义]

我们钦定一个特殊元素，通过加入 / 删除这个元素的方法，可以翻转任意一个子集的奇偶性。因此在 $n \ge 1$ 时，奇偶子集可以两两配对，二者数目相等。

:::::

- **上指标前缀和**：

$$
\sum_{i=0}^k \binom{i}{n}=\binom{k+1}{n+1}
$$

:::::success[组合意义]
考虑在 $n+1$ 个元素中取出 $k+1$ 个元素。枚举子集的最大标号 $i$，则剩余 $n$ 个元素必须从 $0 \sim i-1$ 中选取，方案数为 $\binom{i}{n}$，加法原理合并得到总方案数。
:::::

- **范德蒙德卷积**：

$$
\sum_{i=0}^k \binom{n}{i} \binom{m}{k-i}=\binom{n+m}{k}
$$

:::::success[代数推导]

由二项式定理
$$
\begin{aligned}
(x+1)^{n+m}&=(x+1)^n (x+1)^m\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{i=0}^n \binom{n}{i} x^i \sum_{j=0}^m \binom{m}{j} x^j\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{k=0}^{n+m} x^k\sum_{i=0}^n \binom{n}{i} \binom{m}{k-i}
\end{aligned}
$$
对比 $x^k$ 项的系数易证。这里用到了形式幂级数的思想。

:::::

:::::success[组合意义]

有两堆物品，每堆分别有 $n,m$ 个物品，总共取 $k$ 个。方案数显然为 $\dbinom{n+m}{k}$。

枚举从第一堆取 $i$ 个物品，第二堆取 $k-i$ 个物品，两步选择独立，由乘法原理得到贡献，加法原理得到总方案数。

:::::

另一个常用的变形式：
$$
\sum_{i=0}^m \binom{n}{i} \binom{m}{i}=\binom{n+m}{m}
$$

### 10.2.3 计算方法

#### 10.2.3.1 定义法

由定义式 $\dbinom{n}{m}=\dfrac{n^{\underline m}}{m!}$，我们考虑计算 $n(n-1)\cdots(n-m+1)$ 并除以 $1, 2, \cdots, m$。

- 预处理：$O(1)$。
- 单次查询：$O(m)$。
- 模数要求：任意模数 / 不取模。

:::::info[代码]

```cpp line-numbers
mint C(int n, int m) {
	if (m > n) return 0;
	mint res = 1;
	for (int i = 1; i <= m; i++) res = res * (n - i + 1) / i;
	return res;
}
```

:::::

#### 10.2.3.2 递推法

由 $\dbinom{n}{m}=\dbinom{n-1}{m-1}+\dbinom{n-1}{m}$ 可以直接递推。

- 预处理：$O(n^2)$。
- 单次查询：$O(1)$。
- 模数要求：任意模数。

:::::info[代码]

```cpp line-numbers
mint c[N][N];
for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
for (int i = 0; i <= n; i++) {
	for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
}
```

:::::

#### 10.2.3.3 逆元法

由 $\dbinom{n}{m}=\dfrac{n!}{m!(n-m)!}$，我们只需预处理阶乘和阶乘的逆元，即可 $O(1)$ 计算答案。

阶乘逆元可以采用离线倒推法计算。由于需要逆元，因此对模数有要求。

- 预处理：$O(n)$。
- 单次查询：$O(1)$。
- 模数要求：模质数。

:::::info[代码]

```cpp line-numbers
template <class mint, const int N>
struct comb {
    mint fac[N], ifac[N];
    explicit comb(int n) {
        fac[0] = 1;
        for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
        ifac[n] = ~fac[n];
        for (int i = n - 1; i >= 0; i--) ifac[i] = ifac[i + 1] * (i + 1); 
    }
    mint operator() (int n, int m) const {
        if (n < m || m < 0) return 0;
        return fac[n] * ifac[m] * ifac[n - m];
    }
};
```

:::::

#### 10.2.3.4 Lucas 定理

**Lucas 定理**指出，对于质数 $p$，有
$$
\binom{n}{m}\equiv \binom{\lfloor n/p \rfloor}{\lfloor m/p \rfloor} \binom{n \bmod p}{m \bmod p} \pmod p
$$
这个定理我们不证。

我们可以利用 Lucas 定理递归求解组合数。对于 $n,m <p$ 的情形可以用逆元法得到答案。

- 预处理：$O(p)$。
- 单次查询：$O(\log n)$，对数底数为 $p$。
- 模数要求：模质数。

:::::info[代码]

```cpp line-numbers
mint lucas(i64 n, i64 m) {
	if (m == 0) return 1;
	const int p = mint::get_mod();
	if (n < p && m < p) return C(n, m);
	return lucas(n / p, m / p) * C(n % p, m % p);
}
```

:::::

可以发现，上述递归过程与 $n,m$ 的 $p$ 进制表示有很强的关联。因此与 $\dbinom{n}{m} \bmod p$ 相关的问题有时会采用数位 DP 的方法。

Lucas 定理的推论：$\dbinom{n}{m} \equiv 1 \pmod 2 \iff m \subseteq n$。考虑将 $n,m$ 拆成二进制，容易发现 $m $ 在二进制下必为 $n$ 的子集。

## 10.3 多重集的排列数

记多重集 $S=\{n_1 \cdot a_1,n_2 \cdot a_2, \cdots ,n_k \cdot a_k\}$ 表示集合中有 $n_i$ 个 $a_i$。那么 $S$ 的全排列个数为
$$
\dfrac{n!}{n_1!n_2! \cdots n_k!}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
可以用消序的观点理解这个式子。我们定义**多重组合数**为

::::warning[注意]{open}

多重组合数不是多重集的组合数。

::::
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
其中 $n=\sum \limits_{i=1}^k n_i$。多重组合数具有如下组合意义：将 $n$ 个无标号球分到 $k$ 个有标号盒子中，其中第 $i$ 个盒子恰有 $n_i$ 个球的方案数。由此我们可以得到一个恒等式
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\binom{n}{n_1}\binom{n-n_1}{n_2} \cdots \binom{n-n_1-n_2-\cdots-n_{k-1}}{n_k}
$$
代数推导也容易证明，将两边写成定义式约分后即证。

根据其组合意义，我们有**多项式定理**：
$$
(x_1+x_2+\cdots +x_k)^n =\sum_{n_1+n_2+\cdots+n_k=n} \binom{n}{n_1,n_2,\cdots,n_k} x_1^{n_1}x_2 ^{n_2} \cdots x_k^{n_k}
$$
由于 $\dbinom{n}{m}=\dbinom{n}{m,n-m}$，因此二项式定理是多项式定理的一个特殊情形。

## 10.4 经典模型

### 10.4.1 捆绑法

问题：现有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须连续，求方案数。

:::::success[题解]

将 $m$ 个元素捆绑在一起，内部排列方案为 $m!$ 种。这 $m$ 个元素的整体视为一个元素，外部排列方案为 $(n+1)!$ 种，乘法原理合并即可。

:::::

### 10.4.2 插板法 / 不定方程模型

问题一：求方程 $x_1+x_2+\cdots+x_k=n$ 的**正**整数解数目。

:::::success[题解]

考虑组合意义：将 $n$ 个相同元素分为 $k$ 组，每组至少有一个元素的方案数。

考虑用 $k-1$ 块板子插入到 $n$ 个元素之间两两形成的 $n-1$ 个空内部。答案即 $\dbinom{n-1}{k-1}$。

:::::

问题二：求方程 $x_1+x_2+\cdots+x_k=n$ 的**非负**整数解数目。

:::::success[题解]

令 $y_i =x_i+1$，则问题转化为 $y_1+y_2 + \cdots +y_k=n+k$ 的正整数解计数。由问题一，答案为
$$
\dbinom{n+k-1}{k-1}=\dbinom{n+k-1}{n}
$$
:::::

问题三：求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $x_i \ge a_i$。

:::::success[题解]

令 $y_i =x_i-a_i$，则问题转化为 $y_1+y_2 + \cdots +y_k=n-\sum\limits_{i=1}^k a_i$ 的非负整数解计数。由问题二，答案为
$$
\dbinom{n+\sum a_i+k-1}{n-\sum a_i}
$$
:::::

问题四：求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $0 \le x_i \le a_i$。

:::::success[题解]

记属性 $A_i$ 为 $x_i>a_i$，则我们所求的就是不具有任何属性的元素数目。这可以由容斥原理解决。

用钦定至少的意义容斥，枚举一个属性集合 $S$，计数具有 $S$ 中所有属性的元素数目。容斥系数为 $(-1)^{|S|}$。

对于每个 $i \in S$，令上界减去 $a_i+1$，即令 $y_i=x_i-[i \in S](a_i+1)$，问题转化为方程
$$
y_1+y_2+\cdots+y_k=n-\sum_{i \in S} (a_i+1)
$$
的非负整数解计数问题。由问题二得到
$$
\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
因此原问题的答案就是
$$
\sum _{S \subseteq \{1,2,\cdots,k\}} (-1)^{|S|}\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
:::::

问题四的答案又叫做**多重集的组合数**。

### 10.4.3 不降序列模型

问题一：求值域为 $[l,r]$，长为 $n$ 的**严格递增**序列 $a_i$ 的数目。

:::::success[题解]

考虑从 $r-l+1$ 个数中选出 $n$ 个不同数字，将其升序排序得到序列 $a$，故答案为
$$
\binom{r-l+1}{n}
$$
:::::

问题二：求值域为 $[l,r]$，长为 $n$ 的**单调不降**序列 $a_i$ 的数目。

:::::success[题解]

令 $b_i=a_i+i$，问题转化为对值域 $[l+1,r+n]$ 的严格递增序列 $b_i$ 计数，答案为
$$
\binom{r-l+n}{n}
$$
:::::

### 10.4.4 球盒模型

[P5824 十二重计数法](https://www.luogu.com.cn/problem/P5824)。

这部分的重点在于体会有标号和无标号的区别，以及理解盒子至少一个 / 至多一个的处理方法。

这里的答案有些会涉及到下文所讲的斯特林数 & 分拆数。

问题一：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

每个球都有 $m$ 种选择，由乘法原理得到答案 $m^n$。

:::::

问题二：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑每个球所在盒的标号，可以发现这是一个排列问题，答案为 $A_n^m=m^{\underline n}$。

:::::

问题三：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

考虑求出非空子集划分方案后，乘上盒子的全排列方案数。答案即
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\} m!
$$
:::::

问题四：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

枚举非空盒子的数目为 $i$，答案为同行第二类斯特林数之和：
$$
\sum_{i=1}^m \left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
:::::

问题五：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

问题六：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

第二类斯特林数的组合意义，答案为 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。

:::::

问题七：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的非负整数解数目。答案为
$$
\binom{n+m-1}{m-1}=\binom{n+m-1}{n}
$$
:::::

问题八：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑选定 $n$ 个盒子放球，剩余盒子不放，答案即 $\dbinom{n}{m}$。

:::::

问题九：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的正整数解数目。答案为
$$
\binom{n-1}{m-1}
$$
:::::

问题十：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

$k$ 部分拆数的组合意义，答案为 $p(n,m)$。

:::::

问题十一：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

问题十二：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

先给每个盒子放一个球转化为问题十，答案为 $p(n-m,m)$。

:::::

下面我们给出球盒模型的总结表格：

|   球   |  盒子  |  限制   |                             答案                             |
| :----: | :----: | :-----: | :----------------------------------------------------------: |
| 有标号 | 有标号 |   无    |                            $m^n$                             |
| 有标号 | 有标号 | $\le 1$ |                           $A_n^m$                            |
| 有标号 | 有标号 | $\ge 1$ |     $\left\{\begin{matrix}n \\m\end{matrix}\right\} m!$      |
| 有标号 | 无标号 |   无    | $\sum \limits_{i=1}^m \left\{\begin{matrix}n \\i\end{matrix}\right\}$ |
| 有标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 有标号 | 无标号 | $\ge 1$ |       $\left\{\begin{matrix}n \\m\end{matrix}\right\}$       |
| 无标号 | 有标号 |   无    |                     $\dbinom{n+m-1}{n}$                      |
| 无标号 | 有标号 | $\le 1$ |                       $\dbinom{n}{m}$                        |
| 无标号 | 有标号 | $\ge 1$ |                     $\dbinom{n-1}{m-1}$                      |
| 无标号 | 无标号 |   无    |                           $p(n,m)$                           |
| 无标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 无标号 | 无标号 | $\ge 1$ |                          $p(n-m,m)$                          |

## 10.5 组合数下指标前缀和

[AT_tenka1_2014_final_d 高橋君](https://www.luogu.com.cn/problem/AT_tenka1_2014_final_d)：

> 现有 $q$ 个询问，每次询问给出 $n,m$，求
> $$
> f(n,m)=\sum_{i=0}^m \binom{n}{i}
> $$
> 对 $10^9+7$ 取模。
>
> $q \le 10^5$，$0 \le n,m \le 10^5$，6 秒，256 MB。

考虑莫队的思想，将 $n,m$ 作为莫队指针，只要 $n,m$ 移动一位后 $f(n,m)$ 可以由原本的值 $O(1)$ 递推得到，复杂度就是正确的。事实上：

- $f(n,m+1)=f(n,m)+\dbinom{n}{m+1}$。
- $f(n,m-1)=f(n,m)-\dbinom{n}{m}$。
- $f(n+1,m)=2f(n,m)-\dbinom{n}{m}$。
- $f(n-1,m)=\dfrac{f(n,m)+\binom{n-1}{m}}{2}$。

前两条转移显然，后两条由组合数递推式裂项可得。

这样，我们就可以在 $O(n \sqrt{q})$ 的复杂度内**离线**解决组合数下指标前缀和的问题。

事实上这个问题也存在 $O(q+m \log^2 m)$ 的离线解法，参见 <https://www.luogu.com.cn/article/xypg20ht>。

## 10.6 练习

### [P11250 [GESP202409 八级] 手套配对](https://www.luogu.com.cn/problem/P11250)

> 有 $n$ 对手套，每只手套有标号，求从中取出 $m$ 只手套恰好包含 $k$ 对手套的方案数，对 $10^9+7$ 取模。
>
> 多测，$T \le 10^5,n \le 10^3, 1 \le m \le 2n, 1\le k \le n$，1 秒，512 MB。

:::::success[题解]
分两步：

- 钦定 $k$ 对手套，方案数 $\binom{n}{k}$；

- 在剩余 $n-k$ 对手套中找出 $m-2k$ 只不同组的手套，注意左右手套不同，方案数 $\binom{n-k}{m-2k} \times 2^{m-2k}$。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
comb<mint, N> C(N-1);
int n, m, k;

void _main() {
    cin >> n >> m >> k;
    cout << C(n, k) * mint(2).pow(m - 2 * k) * C(n - k, m - 2 * k) << '\n';
}
```

:::::

:::::success[另解]
二元 GF 刻画之，用 $x$ 的幂表示取出的手套总数，$y$ 的幂表示配对成功的手套对数。

一对手套的 GF 为 $1+2x+x^2y$。则答案为 $[x^m y^k] \left(1+2x+x^2y\right)^n$。于是

$$
\begin{aligned}
 \left(1+2x+x^2y\right)^n&=\sum_{i=0}^n \binom{n}{i} (1+2x)^{n-i} (x^2y)^i\\

[y^k] \left(1+2x+x^2y\right)^n &=\binom{n}{k} (1+2x)^{n-k} x^{2k}\\

[y^k] \left(1+2x+x^2y\right)^n &=\binom{n}{k} x^{2k} \sum_{j=0}^{n-k} \binom{n-k}{j} 2^j x^j\\

[x^{m-2k}] (1+2x)^{n-k}&=\binom{n-k}{m-2k} 2^{m-2k}\\

[x^m y^k] \left(1+2x+x^2y\right)^n &= \binom{n}{k} \binom{n-k}{m-2k} 2^{m-2k}
\end{aligned}
$$
:::::

### [P3330 [ZJOI2011] 看电影](https://www.luogu.com.cn/problem/P3330)

> 有 $n$ 人前来看电影，共有 $k$ 个座位。每人依次入场，从 $1 \sim k$ 中随机选择一个正整数 $p$。若 $p$ 无人则坐在 $p$，否则令 $p \gets p+1$ 并继续上述操作。若 $p>n$ 则无法落座。
>
> 求所有人都有座位的概率。需要高精度。
>
> 多测，$T \le 50$，$n,k \le 200$，1 秒，125 MB。

:::::success[题解]
特判 $k<n$ 的情况。

概率转计数，总方案显然有 $k^n$ 种，考虑计算合法方案数。

在 $k$ 后方新增一个陷阱座位，然后将 $k+1$ 个座位拉成环，这样所有人一定有座位，根据圆排列的知识可以得到方案数为 $(k+1)^{n-1}$。

此时合法当且仅当陷阱上没有人。由于环是旋转对称的，直接从 $k+1-n$ 个空座位中选出一个陷阱即可。于是得到答案式子

$$
\dfrac{(k+1)^{n-1} (k+1-n)}{k^n}
$$
:::::

:::::info[代码]

```python line-numbers
from math import gcd
T = int(input())
for _ in range(T):
    n, k = map(int, input().split())
    if k < n:
        print('0 1')
        continue
    a = ((k + 1) ** (n - 1)) * (k + 1 - n)
    b = k ** n
    print(a // gcd(a, b), b // gcd(a, b))
```

:::::
