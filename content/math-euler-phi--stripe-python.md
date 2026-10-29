---
id: math-euler-phi
title: '欧拉函数'
category: '数学'
subcategory: '数论基础'
tags: ['欧拉函数', '积性函数', '筛法']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 4. 欧拉函数

## 4.1 定义

**欧拉函数** $\varphi(x)$ 指 $[1,n]$ 中与 $n$ 互质的数的个数。

若由算术基本定理可将 $n$ 分解为 $p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$，则

$\varphi(x)=n (1-\dfrac{1}{p_1})  (1-\dfrac{1}{p_2}) (1-\dfrac{1}{p_3}) \cdots (1-\dfrac{1}{p_m}) =n\times \prod_{i=1}^{m} (1-\dfrac{1}{p_i})$由此有一个 $O(\sqrt{n})$ 计算欧拉函数的方法：

```cpp
inline int phi(int n) {
	if (n == 1) return 1;
	int res = n;
	for (int i = 2; i * i <= n; i++) {
		if (n % i == 0) {
			res = res / i * (i - 1);
			while (n % i == 0) n /= i;
		}
	}
	if (n > 1) res = res / n * (n - 1);
	return res;
}
```

## 4.2 性质

1. 若 $p$ 是质数，则 $\varphi(p)=p-1$。
2. 若 $a,b$ 互质，则 $\varphi(ab)=\varphi(a) \times \varphi(b)$。这表明：欧拉函数是积性函数，因而可以用线性筛筛出。
3. $\sum_{d \mid  n} \varphi(d)=n$。一些文章称之为“欧拉反演”，但严格来说并不算反演。
4. 对于 $n>1$，$[1,n]$ 中与 $n$ 互质的数的和为 $\dfrac{1}{2}n\times \varphi(n)$。
5. 若 $n=p^k$，其中 $p$ 是质数，则 $\varphi(n)=p^k-p^{k-1}$。

## 4.3 筛法

使用性质 2 并结合线性筛法，可以在 $O(n)$ 时间内预处理 $[1,n]$ 的欧拉函数值：

```cpp
int len, phi[N], prime[N];
bitset<N> isprime;

inline void eular(int n) {
	phi[1] = 1, isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i <= n; i++) {
		if (isprime[i]) prime[++len] = i, phi[i] = i - 1;
		for (int j = 1; j <= len && i * prime[j] <= n; j++) {
			isprime[i * prime[j]] = false;
			if (i % prime[j] == 0) {
				phi[i * prime[j]] = phi[i] * prime[j];
				break;
			}
			phi[i * prime[j]] = phi[i] * phi[prime[j]];
		}
	}
}
```

## 4.4 例题

### SP4141 ETF - Euler Totient Function

线性筛欧拉函数板子。直接上代码：

```cpp
const int N = 1e6 + 5;
void _main() {
	eular(N - 1);
	int t, x; cin >> t;
	while (t--) cin >> x, cout << phi[x] << '\n';
}
```

### UVA10179 Irreducable Basic Fractions

题意翻译：求 $\dfrac{0}{n},\dfrac{1}{n},\dfrac{2}{n},\cdots \dfrac{n-1}{n}$ 中多少个分数为最简分数。认为 $\dfrac{0}{n}$ 最简。

我们发现最简分数 $\dfrac{x}{n}$ 满足 $\gcd(x,n)=1$，于是所求为 $\varphi(n)$。用分解质因数法求即可，代码不放了。

### P2158 [SDOI2008] 仪仗队

由样例图可以发现能看见的位置关于对角线对称，只需要考虑一个三角形即可。以左下角为原点 $(0,0)$ 建立坐标系，则一个点被阻挡的条件就是到原点连线的斜率相同。设两点 $(x_1,y_1),(x_2,y_2)$，则 $\dfrac{y_1}{x_1}=\dfrac{y_2}{x_2}$。当且仅当这个分数已经为最简形式时它不会被挡住，这就和上题类似了。

所求即为

$2\sum_{i=1}^{n-1} \varphi(i)+1$这是因为 $(2,2)$ 满足条件而我们无法统计进去。注意特判 $n=1$。

用线性筛筛出欧拉函数即可，复杂度 $O(n)$，代码：

```cpp
int n;
void _main() {
	cin >> n;
	if (n == 1) return cout << 0, 0;
	int res = 1;
	eular(40000);
	for (int i = 1; i < n; i++) res += 2 * phi[i];
	cout << res;
}
```

### P2398 GCD SUM

这题做法很多，读者可以翻到下文 8.3 容斥例题学习容斥做法，这里写的是欧拉函数做法。

可以发现 $\gcd(i,j)$ 的值只有 $n$ 种，不妨考虑 $gcd(i,j)=k$ 的数目。对于一对互质的 $i,j$，有 $\gcd(ik,jk)=k$，所以可以得到结果为 $k$ 的数目为

$2\sum_{i=1}^{\lfloor \frac{n}{k} \rfloor} \varphi(i)-1$和上面那题是一样的，因为 $\gcd(i,j)=\gcd(j,i)$ 有对称性，而 $(1,1)$ 会重复计算，要减一。

然后我们用线性筛处理出 $\varphi(i)$ 的前缀和，$O(n)$ 计算即可。

```cpp
const int N = 1e5 + 5;
int n;
long long pre[N];

void _main() {
	cin >> n;
	eular(n);
	for (int i = 1; i <= n; i++) pre[i] = pre[i - 1] + phi[i];
	long long res = 0;
	for (int i = 1; i <= n; i++) res += 1LL * i * (2 * pre[n / i] - 1);
	cout << res;
}
```

双倍经验：[P1390](https://www.luogu.com.cn/problem/P1390)。这个题没有对称性，把系数 $2$ 去掉即可。

### P2303 [SDOI2012] Longge 的问题

注意到 $\gcd(i,n)$ 是 $n$ 的因数，考虑枚举因数 $x$，再判断有多少 $\gcd(i,n)=x$。与上题相同，$i$ 有 $\varphi(\dfrac{n}{x})$ 个。直接用定义法求欧拉函数即可，复杂度 $O(\sqrt{n} \times d(n))$。

```cpp
#define int long long
int n;
inline int phi(int n) {
	if (n == 1) return 1;
	int res = n;
	for (int i = 2; i * i <= n; i++) {
		if (n % i == 0) {
			res = res / i * (i - 1);
			while (n % i == 0) n /= i;
		}
	}
	if (n > 1) res = res / n * (n - 1);
	return res;
}

inline void _main() {
	cin >> n;
	long long res = 0;
	for (int i = 1; i * i <= n; i++) {
		if (n % i) continue;
		res += i * phi(n / i);
		if (i * i != n) res += n / i * phi(n / (n / i));
	}
	cout << res;
}
```

### *P3768 简单的数学题

一路推式子：

$$
\begin{aligned}
&\sum_{i=1}^n\sum_{j=1}^n ij \gcd(i,j) \\
&=\sum_{i=1}^n \sum_{j=1}^n ij \sum _{d \mid i, d\mid j} \varphi(d) \\
&=\sum_{d=1}^n \varphi(d) \sum_{d \mid i, i \le n} \sum_{d\mid j, j \le n} ij\\
&=\sum_{d=1}^n d^2 \varphi(d) \sum_{i=1}^{\lfloor n/d \rfloor}i \sum_{j=1}^{\lfloor n/d \rfloor}j\\
&=\sum_{d=1}^n d^2 \varphi(d) \left (\sum_{i=1}^{\lfloor n/d \rfloor}i\right)^2 \\
&=\sum_{d=1}^n d^2 \varphi(d) (\dfrac{\lfloor n/d \rfloor \left(\lfloor n/d \rfloor+1 \right)}{2})^2
\end{aligned}
$$

稍微解释一下发生了什么：根据性质 6 将 $\gcd(i,j)$ 写成欧拉函数形式，然后交换求和顺序，接下来发现 $i,j$ 取值相同直接合并求和即可。

做到这里我们可以 $O(n)$ 解决。但是这题正解复杂度是 $O(n^{2/3})$，需要杜教筛科技，这里不作讲解。
