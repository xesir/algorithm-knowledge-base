---
id: math-block-division
title: '整除分块（数论分块）'
category: '数学'
subcategory: '数论基础'
tags: ['整除分块', '数论分块', '下取整求和']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 6. 数论分块

数论分块用于快速计算形如

$\sum_{i=1}^{n} f(i) g(\lfloor \dfrac{k}{i} \rfloor)$的式子，其中 $f(i)$ 可处理出前缀和或可以快速计算 $f(x)-f(y)$。如果这是 $O(1)$ 的，则数论分块可在 $O(\sqrt{n})$ 的时间内得出结果。

## 6.1 原理

以函数 $y=\lfloor \dfrac{100}{x} \rfloor$ 为例，图像如下：

![](https://cdn.luogu.com.cn/upload/image_hosting/xsvja4az.png)

我们注意到对于每个固定的 $y$，$x$ 的取值总是一个固定区间。事实上，$\lfloor \dfrac{k}{i} \rfloor$ 不变时，$i \le \lfloor \frac{k}{\lfloor \frac{k}{i} \rfloor} \rfloor$。

设 $m=\lfloor \dfrac{k}{i} \rfloor$，则 $m \le \dfrac{k}{i}$，所以 $\lfloor \dfrac{k}{m} \rfloor \ge \lfloor \frac{k}{\frac{k}{i}} \rfloor=i$。

因此，$i_{\max}=\lfloor \dfrac{k}{m} \rfloor=\lfloor \frac{k}{\lfloor \frac{k}{i} \rfloor} \rfloor$。

## 6.2 板子

```cpp
template <class F_t, class G_t>
long long sqrt_decomposition(long long n, long long k, F_t f, G_t g) {
	long long res = 0;
	for (long long l = 1, r = 0; l <= n; l = r + 1) {
		r = (k / l) ? min(n, (k / (k / l))) : n;
		res += f(r, l - 1) * g(k / l);
	}
	return res;
}
```

这个板子第一个参数传入 $n$，第二个参数传入 $k$，第三个参数传入一个函数计算 $f(x)-f(y)$，第四个参数传入 $g(x)$ 的函数。

## 6.3 例题

### UVA11526 H(n)

【模板】数论分块。

```cpp
int n;
void _main() {
	cin >> n;
	cout << sqrt_decomposition(n, n,
		[](long long x, long long y) {return x - y;}, // f(x) = 1
		[](long long x) {return x;} // g(x) = x
	) << '\n';
}
```

### P2424 约数和

首先考虑求 $f(x)$ 的前缀和 $g(x)$。有一个结论是 $i$ 的约数在 $n$ 以内有 $\lfloor \dfrac{n}{i} \rfloor$ 个，所以

$g(x) = \sum_{i=1}^{n} i \times \lfloor \dfrac{n}{i} \rfloor$然后套板子去求即可。

```cpp
long long g(long long n) {
	if (n <= 1) return n;
	return sqrt_decomposition(n, n,
		[](long long x, long long y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
}

long long l, r;
void _main() {
	cin >> l >> r;
	cout << g(r) - g(l - 1);
}
```

### P2261 [CQOI2007] 余数求和

根据取模的定义，有 $a \bmod b=a-b \times \lfloor \dfrac{a}{b} \rfloor$，然后推一波式子：

$$
\begin{aligned}
G(n, k) &= \sum_{i = 1}^n k \bmod i \\
&= \sum_{i = 1}^n k -i \times \lfloor \dfrac{k}{b} \rfloor \\
&= nk-\sum_{i = 1}^n i \times \lfloor \dfrac{k}{b} \rfloor
\end{aligned}
$$

后面这个东西可以数论分块来做。

```cpp
long long n, k;

void _main() {
	cin >> n >> k;
	cout << n * k - sqrt_decomposition(n, k,
		[](long long x, long long y) {return (x - y) * (x + y + 1) / 2;}, // f(x) = x
		[](long long x) {return x;} // g(x) = x
	);
}
```

### *P2260 [清华集训 2012] 模积和

和上面的题很像。推柿子：

$$
\begin{aligned}
ans &=\sum_{i=1}^{n} \sum_{j=1}^{m} (n \bmod i) \times (m \bmod j), i \neq j  \\

&=\sum_{i=1}^{n} \sum_{j=1}^{m} (n \bmod i) \times (m \bmod j)-\sum_{i=1}^{\min(n,m)} (n \bmod i) \times (m \bmod i)\\

&=\sum_{i=1}^n(n-\lfloor\frac{n}{i}\rfloor\times i)\times\sum_{j=1}^m(m-\lfloor\frac{m}{j}\rfloor\times j)-\sum_{i=1}^{\min(n,m)}(n-\lfloor\frac{n}{i}\rfloor\times i)\times(m-\lfloor\frac{m}{i}\rfloor\times i)\\

&=(n^2-\sum_{i=1}^ni\times\lfloor\frac{n}{i}\rfloor)\times(m^2-\sum_{i=1}^mi\times\lfloor\frac{m}{i}\rfloor)-\sum_{i=1}^{\min(n,m)}(nm-mi\times\lfloor\frac{n}{i}\rfloor-ni\times\lfloor\frac{m}{i}\rfloor+i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor)\\

&=(n^2-\sum_{i=1}^ni\times\lfloor\frac{n}{i}\rfloor)\times(m^2-\sum_{i=1}^mi\times\lfloor\frac{m}{i}\rfloor)-nm\times \min(n,m)+\sum_{i=1}^{\min(n,m)}mi\times\lfloor\frac{n}{i}\rfloor+\sum_{i=1}^{\min(n,m)} ni\times\lfloor\frac{m}{i}\rfloor -\sum_{i=1}^{\min(n,m)}  i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor
\end{aligned}
$$

最后这个 $i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor$ 用数论分块的时候不太一样。首先我们需要保证块内的 $\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor$ 相同，将右端点改为 $\min(\lfloor \frac{n}{\lfloor \frac{n}{i} \rfloor} \rfloor,\lfloor \frac{m}{\lfloor \frac{m}{i} \rfloor} \rfloor)$，这叫做二维数论分块。然后用到结论 $\sum_{i=1}^{n} i^2=\frac{n(n+1)(2n+1)}{6}$。不了解这个结论可以翻到下文 7.2.3 幂数列求和结论 2。

```cpp
long long n, m;
modint pre(modint n) {return n * (n + 1) * (n * 2 + 1) / modint(6);}
modint k1() {  // 这里没法套板子，自己写一个
	modint res = 0;
	for (long long l = 1, r = 0; l <= min(n, m); l = r + 1) {
		r = min(n / (n / l), m / (m / l));
		res += modint(n / l) * modint(m / l) * (pre(r) - pre(l - 1));
	}
	return res;
}

void _main() {
	cin >> n >> m; long long k = min(n, m);
	modint n0 = n, m0 = m;
	modint n1 = n0 * n0 - sqrt_decomposition(n, n,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
	modint m1 = m0 * m0 - sqrt_decomposition(m, m,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
	modint n2 = sqrt_decomposition(k, n,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[&](long long x) {return m0 * x;}
	);
	modint m2 = sqrt_decomposition(k, m,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[&](long long x) {return n0 * x;}
	);
	cout << n1 * m1 - n0 * m0 * k + n2 + m2 - k1();
}
```

### P6583 回首过去

由小学奥数可得，满足题意的 $x,y$ 在约分后，$y$ 的质因子只有 $2$ 和 $5$。也就是形如 $\dfrac{bc}{ac}$ 的分数中，$a$ 仅含有 $2$ 和 $5$ 的质因子，$c$ 不含有 $2$ 或 $5$ 的质因子。

枚举符合要求的 $c$，则 $a \le \lfloor \dfrac{n}{c} \rfloor$，直接用若干个 $2$ 和 $5$ 凑出 $a$，若 $a$ 的个数为 $cnt$，贡献就是 $\lfloor \dfrac{n}{c} \rfloor \times cnt$。可以获得 80pts。

```cpp
long long n;

void _main() {
	cin >> n;
	long long res = 0;
	for (int c = 1; c <= n; c++) {
		long long cnt = 0;
		if (c % 2 == 0 || c % 5 == 0) continue;
		for (int i = 1; i <= n; i <<= 1) {
			for (int j = 1; j <= n; j *= 5) {
				if (1LL * c * i * j > n) break;
				cnt++;
			}
		} res += cnt * (n / c);
	} cout << res;
}
```

看到 $\sum \lfloor \dfrac{n}{c} \rfloor \times cnt$ 这个式子，就是数论分块了。然而 $c$ 选取不连续，要跳过含 $2$ 和 $5$ 质因子的数。我们可以用下文的容斥原理，设 $h(l,r,d)=\lfloor \dfrac{r}{d} \rfloor-\lfloor \dfrac{l-1}{d} \rfloor$ 表示 $[l,r]$ 中有多少个数是 $d$ 的倍数，则区间长度就是 $(r-l+1) -g(l,r,2)-g(l,r,5)+g(l,r,10)$，于是问题解决。

```cpp
#define int long long
int n;
int cnt(int n) {
	int res = 0;
	for (int i = 1; i <= n; i <<= 1) {
		for (int j = 1; j <= n; j *= 5) {
			if (1LL * i * j > n) break;
			res++;
		}
	} return res;
}
int g(int l, int r, int d) {return r / d - (l - 1) / d;}

void _main() {
	cin >> n;
	int res = 0;
	for (int l = 1, r = 0; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		res += cnt(n / l) * (n / l) * (r - l + 1 - g(l, r, 2) - g(l, r, 5) + g(l, r, 10));
	} cout << res;
}
```
