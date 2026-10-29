---
id: math-derangement
title: '错位排列（错排）'
category: '数学'
subcategory: '组合数学'
tags: ['错排', '错位排列', '递推']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 12. 错位排列

**错排数** $D_i$ 是指将 $1$ 到 $n$ 的自然数排列重新排列为 $P_i$ 后，满足 $\forall i \in [1,n], P_i \ne i$ 的方案数。

例如，$n=3$ 时，错位排列有 $\{2,3,1\}$ 和 $\{3,1,2\}$。

## 12.1 递推公式

计算错排数可以递推。考虑 $D_n$ 时，先把 $n$ 放在 $P_n$，然后有两种情况：

1. 前面 $n-1$ 个数已经是错位排列；
2. 前面 $n-1$ 个数有一个在原位上，其他错位。

对于情况 1，第 $n$ 个数可以与任一数字交换，有 $(n-1)D_{n-1}$ 种方案；

对于情况 2，第 $n$ 个数只能与原位上的交换，有 $(n-1)D_{n-2}$ 种方案；

因此，

$D_n=(n-1)(D_{n-1}+D_{n - 2})$另外地，$D_1=0,D_2=1$。

对 $D_n=(n-1)(D_{n-1}+D_{n - 2})$ 变形：

$$
\begin{aligned}
D_n&=(n-1)(D_{n-1}+D_{n - 2})\\
D_n&=(n-1)D_{n-1}+(n-1)D_{n-2}\\
D_n-nD_{n-1}&=-D_{n-1}+(n-1)D_{n-2}\\
D_n-nD_{n-1}&=(-1)[D_{n-1}-(n-1)D_{n-2}]
\end{aligned}
$$

由此可见 $D_n-nD_{n-1}$ 是首项为 $1$，公比为 $-1$ 的等差数列，由此可得错排的另一个递推式

$D_n=nD_{n-1}+(-1)^n$## *12.2 通项公式

由递推式 2，两边同时除以 $n!$ 有

$\dfrac{D_n}{n!}=\dfrac{D_{n-1}}{(n-1)!}+\dfrac{(-1)^n}{n!}$根据递推式不断代入，累加：

$\dfrac{D_n}{n!}=\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$因此可得错排通项公式

$D_n=n!\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$### 范围估计

根据通项公式可以估计错排的增长速度。由式子

$\dfrac{D_n}{n!}=\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$可以想到 $e^{-1}$ 的泰勒展开。写出 $\dfrac{1}{e}$ 在 $x=-1$ 处的泰勒展开：

$\dfrac{1}{e}=\sum_{k=0}^{\infty} \dfrac{(-1)^k}{k!}$因此：

$\dfrac{1}{e}=\dfrac{D_n}{n!} + \sum_{k=n+1}^{\infty} \dfrac{(-1)^k}{k!}$注意到，当 $n$ 增加时，后面的和式趋近于 $0$，因此可得错排数列的极限：

$\lim_{n \to +\infty} D_n=\dfrac{n!}{e}$即 $D_n=O(n!)$。因此在复杂度中用到错排时，可认为它是阶乘级别的。

## 12.3 例题

### P1595 信封问题

板子题。

```cpp
const int N = 25;
int n;
long long d[N];

void _main() {
	d[2] = 1;
	for (int i = 3; i < N; i++) d[i] = (i - 1) * (d[i - 1] + d[i - 2]);
	cin >> n;
}
```

### P4071 [SDOI2016] 排列计数

稍微思考一下就能发现，可以先选出 $m$ 个数，使得 $a_i=i$，然后再让剩下 $n-m$ 个数都满足 $a_i \ne i$，这就是错排数 $D_{n-m}$。因此答案即为 $C_{n}^{m} \times D_{n-m}$。采用预处理逆元的方法求组合数即可。

```cpp
const int N = 1e6 + 5;
const long long mod = 1e9 + 7;
long long d[N], fac[N], ifac[N];

long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long t, n, m;

void _main() {
	d[2] = 1;
	for (int i = 3; i < N; i++) d[i] = 1LL * (i - 1) * ((d[i - 1] + d[i - 2]) % mod) % mod;

	fac[0] = 1;
	for (int i = 1; i < N; i++) {
		fac[i] = fac[i - 1] * i % mod;
		ifac[i] = power(fac[i], mod - 2);
	}
	for (cin >> t; t--; ) {
		cin >> n >> m;
		if (m == 0) {cout << d[n] << '\n'; continue;}
		if (n == m) {cout << 1 << '\n'; continue;}
		if (n == m + 1) {cout << 0 << '\n'; continue;}
		cout << (fac[n] * ifac[m] % mod * ifac[n - m] % mod) * (n >= m ? d[n - m] : 1) % mod << '\n';
	}
}
```

同样的思想可以解决 [P8788](https://www.luogu.com.cn/problem/P8788) 的问题 A。

### *P4921 [MtOI2018] 情侣？给我烧了！

定义一个“广义错排数” $f(x)$ 表示 $x$ 对情侣都错开的方案数。方法和上面那题一样，区别在于情侣位置有序，且一对情侣的相对位置有两种选择，由乘法原理得

$a_k=C_n^k \times A_n^k \times 2^k \times f(n-k)$只要预处理出 $f(x)$ 即可。和错排的方法一样分解成子问题。首先我们从这 $2x$ 个人中任意选取一个人，再选一个不能配对的人，乘法原理得 $2x(2x-2)$。分类讨论这两人的配偶：

1. 将他们强制配对：则子问题为 $f(x-2)$。我们有 $x-1$ 个位置，且一对情侣有 $2$ 种可能，答案为 $2(x-1) \times f(x-2)$。
2. 不强制配对：问题变成子问题 $f(x-1)$。

由加法 & 乘法原理得：

$f(x)=2x(2x-2) \times [f(x-1)+2(x-1)\times f(x-2)]$于是我们在 $O(Tn)$ 的复杂度下解决了此问题。你甚至可以用这个做法切掉[加强版](https://www.luogu.com.cn/problem/P4931)。

```cpp
const int N = 1005;
int q, n;
mint fac[N], ifac[N], f[N];
mint A(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[n - m];
}
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	fac[0] = ifac[0] = 1, f[0] = 1, f[1] = 0;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i < N; i++) f[i] = (f[i - 1] + f[i - 2] * 2 * (i - 1)) * 2 * i * (2 * i - 2);
	for (cin >> q; q--; ) {
		cin >> n;
		for (int k = 0; k <= n; k++) cout << C(n, k) * A(n, k) * mint(2).pow(k) * f[n - k] << '\n';
	}
}
```

## 附：计数基础·错位排列（stripe-python）

## 4. 错位排列

定义一个 $1 \sim n$ 的排列 $p_i$ 是错位排列，当且仅当 $\forall 1 \le i \le n, p_i \ne i$。

**错排数** $D_n$ 表示长为 $n$ 的错位排列的数目。

我们可以用排列计数的方法来递推 $D_n$，考虑插入第 $n$ 个数：

- 若 $p_1 \sim p_{n-1}$ 全部满足 $p_i \ne i$，则 $n$ 可以插入任意位置，方案数 $(n-1)D_{n-1}$。
- 若 $p_1 \sim p_{n-1}$ 恰有一个 $i$ 满足 $p_i=i$，则 $n$ 只需与 $p_i$ 调换。而这样的 $i$ 有 $n-1$ 个，方案数 $(n-1)D_{n-2}$。
- 若 $p_1 \sim p_{n-1}$ 有 $\ge 2$ 个 $i$ 满足 $p_i=i$，则 $p_1 \sim p_n$ 不可能成为错位排列，方案数 $0$。

由加法原理合并得到
$$
D_n=(n-1)(D_{n-1}+D_{n-2})
$$
进一步推导可得另一个递推式 $D_n=nD_{n-1}+(-1)^n$。

:::::success[代数推导]
$$
\begin{aligned}
D_n&=(n-1)(D_{n-1}+D_{n-2})\\
\iff& D_n= (n-1)D_{n-1}+(n-1)D_{n-2}\\
\iff& D_n-nD_{n-1} = -D_{n-1} + (n-1)D_{n-2}
\end{aligned}
$$
记 $f_n=D_n-nD_{n-1}$，上式给出 $f_n=-f_{n-1} \implies f_n=(-1)^n$。故
$$
D_n-nD_{n-1}=(-1)^n \iff D_n=nD_{n-1}+(-1)^n
$$
:::::

错排数的通项公式为
$$
D_n=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
$$
下面给出四种推导视角。

:::::success[代数变形]

由 $D_n=nD_{n-1}+(-1)^n$ 可得
$$
\dfrac{D_n}{n!}=\dfrac{D_{n-1}}{(n-1)!}+\dfrac{(-1)^n}{n!}
$$
记 $f_n=\dfrac{D_n}{n!}$，上式给出 $f_n=f_{n-1}+\dfrac{(-1)^n}{n!}$，得
$$
f_n=\sum_{k=0}^n \dfrac{(-1)^k}{k!}
$$
代入 $f_n$ 的定义式后移项即证。

:::::

:::::success[容斥原理]

记第 $i$ 种属性为 $p_i=i$，则 $D_n$ 即不具有任何属性的排列数目。考虑容斥，我们钦定 $k$ 种属性，对钦定至少的组合意义计数：

- 在 $n$ 个位置中钦定 $k$ 个位置，方案数 $\dbinom{n}{k}$。
- 未被钦定的 $n-k$ 个位置全排列，方案数 $(n-k)!$。

容斥系数为 $(-1)^k$。由此可得
$$
\begin{aligned}
D_n&=\sum_{k=0}^n (-1)^k \binom{n}{k} (n-k)!\\
&=\sum_{k=0}^n (-1)^k \dfrac{n!}{k!}\\
&=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

:::::success[二项式反演]

记 $f(k)$ 为恰有 $k$ 个 $i$ 满足 $p_i=i$ 的排列数目，易知
$$
f(k)=\binom{n}{k} D_{n-k}
$$
所有 $f(k)$ 的和即为全排列
$$
\begin{aligned}
n!=\sum_{k=0}^n f(k)=\sum_{k=0}^n \binom{n}{k} D_{n-k}=\sum_{k=0}^n \binom{n}{k} D_k
\end{aligned}
$$
由二项式反演形式一
$$
\begin{aligned}
D_n&=\sum_{k=0}^n (-1)^{n-k} \binom{n}{k}k!\\
&=\sum_{k=0}^n (-1)^{n-k} \dfrac{n!}{(n-k)!}\\
&=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

:::::success[错排 EGF]

记错排数列的 EGF 为 $F$，代入第二个递推式
$$
\begin{aligned}
F(x)&=1+\sum_{n \ge 1} D_n \dfrac{x^n}{n!}\\
&=1+\sum_{n \ge 1} D_{n-1} \dfrac{x^{n-1}}{(n-1)!}+\sum_{n\ge 1} (-1)^n \dfrac{x^n}{n!}\\
F(x)&=1+xF(x)+e^{-x}-1
\end{aligned}
$$
解方程 $F=xF+e^{-x}$ 得 $F(x)=\dfrac{e^{-x}}{1-x}$，即为 EGF 的封闭形式。
$$
\begin{aligned}
F(x)&=\dfrac{e^{-x}}{1-x}\\
&=\left(\sum_{i \ge 0} (-1)^i\dfrac{x^i}{i!} \right)\left(\sum_{j \ge 0} x^j\right)\\
\left[\frac{x^n}{n!}\right] F(x)&= n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

熟知 $e^{-1}$ 的泰勒展开 $e^{-1}=\sum\limits_{k\ge 0} \dfrac{(-1)^k}{k!}$，代入有
$$
\dfrac{D_n}{n!}+\sum_{k \ge n+1} \dfrac{(-1)^k}{k!}=\dfrac{1}{e}
$$
后面的和式在 $n\to +\infty$ 时趋近为 $0$，因此
$$
\lim_{n \to +\infty} \dfrac{D_n}{n!}=\dfrac{1}{e}
$$
更精细的分析表明
$$
D_n=\left\lfloor \dfrac{n!}{e}+\dfrac{1}{2} \right\rfloor
$$
不过实际上这些通项在 OI 中没有什么应用，读者领会思想即可。
