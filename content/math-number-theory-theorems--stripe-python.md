---
id: math-number-theory-theorems
title: '数论常用定理：费马小定理与扩展欧拉定理'
category: '数学'
subcategory: '数论基础'
tags: ['费马小定理', '欧拉定理', '降幂']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 5. 数论常用定理

## 5.1 费马小定理

若 $p$ 为质数，且 $\gcd(a,p)=1$，则 $a^{p-1} \equiv 1 \pmod p$。

变形式：$a^p\equiv a \pmod p$ 和 $a^{p-2}\equiv \dfrac{1}{a} \pmod p$。其中第二个式子表明，当 $p$ 为质数时可以直接用快速幂求逆元。

证明：取一个不为 $p$ 的倍数的数 $a$，构造序列 $A=\{1,2,3, \cdots p-1\}$，则：

$\prod_{i=1}^{p-1} A_i \equiv \prod_{i=1}^{p-1} (A_i\times a) \pmod p$考虑每一个 $A_i$ 都不是 $p$ 的约数易证。则令 $m=(p-1)!$，则

$m \equiv \prod_{i=1}^{p-1} (A_i\times a) \pmod p$又有 $a^{p-1} \times f \equiv f \pmod p$，故

$a^{p-1} \equiv 1 \pmod p$## 5.2 欧拉定理

欧拉定理是费马小定理的扩展形式。若 $\gcd(a,n)=1$，则 $a^{\varphi(n)} \equiv 1 \pmod n$。证明与费马小定理类似，构造一个与 $n$ 互质的序列即可。

### 推论

推论 1：若 $\gcd(a,n)=1$，则 $a^b \equiv a^{b \bmod \varphi(n)} \pmod n$。

推论 2：若 $\gcd(a,n)=1$，则满足 $a^x \equiv 1 \pmod n$ 的最小正整数是 $\varphi(n)$ 的约数。

## *5.3 扩展欧拉定理

扩展欧拉定理在 OI 中常用于对指数取模的情况。

$$
a^b \equiv \left\{\begin{matrix}
 a^{b \bmod \varphi(n)} & \gcd(a,n)=1 \\
 a^b & \gcd(a,n) \ne 1,b < \varphi(n) \\
 a^{(b \bmod \varphi(n))+\varphi(n)} & \gcd(a,n) \ne 1, b \ge \varphi(n)
\end{matrix}\right. \pmod n
$$

## 5.4 例题

### P4139 上帝与集合的正确用法

题里给的那个东西实际上是 $2^{2^{2^{2^ \cdots}}} \bmod p$。对指数塔不断递归，用扩展欧拉定理降幂即可。$\varphi(n)$ 提前筛出来。

由于指数塔是无限层，因此肯定有 $b \ge \varphi(n)$，直接认为是第三种情况就行了。

```cpp
long long p;
long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = a * a % p, b >>= 1) {
		if (b & 1) res = res * a % p;
	} return res;
}
long long f(long long p) {return p == 1 ? 0 : power(2, f(phi[p]) + phi[p], p);}

void _main() {   // 这里已经筛过phi[n]了
	cin >> p; cout << f(p) << '\n';
}
```

### P10414 [蓝桥杯 2023 国 A] 2023 次方

和上面那个题没有本质区别。

根据扩展欧拉定理，$a^b \equiv  a^{(b \bmod \varphi(n))+\varphi(n)} \pmod n$，其中 $\gcd(a,n) \ne 1$ 且 $b \le \varphi(n)$。计算可得，$\varphi(2023)=1728$，所以对指数塔上 $>1728$ 的部分用扩展欧拉定理降幂，剩下的部分快速幂即可。得到答案为 $869$。

### *P7334 [JRKSJ R1] 吊打

很好的数据结构和欧拉定理结合的题目。

区间开方可以想到 [GSS4](https://www.luogu.com.cn/problem/SP2713)，势能线段树记录区间最大值，只有 $>1$ 才暴力修改，复杂度是 $O(n \log n \log \log V)$ 的。

考虑区间平方的做法，显然不能直接维护 $a_i$，不然不满足势能线段树的要求。注意到，一个数 $a_i$ 在 $c_i$ 次平方后值为 ${a_i}^{2^{c_i}}$，对 $998244353$ 取模时，指数 $2^{c_i}$ 对 $\varphi(998244353)=998244352$ 取模即可。于是我们考虑维护这个 $c_i$。

这样平方是简单的，区间加一即可。对于开方，我们考虑在线段树的叶子节点维护一个值 $val_i$。当 $c_i \ge 1$ 时，直接将 $c_i \gets c_i-1$，否则令 $val_i \gets \lfloor \sqrt{val_i} \rfloor$。正确性显然。

注意到开方复杂度炸了。考虑将 GSS4 的做法应用到这里，维护区间 $c_i$ 的最小值。只有其 $<1$ 时再进入暴力。配合上区间 $val$ 最大值，可以把暴力次数控制在 $O(\log \log V)$ 以内。因为询问要快速幂，最终复杂度 $O(n \log^2 n)$。

```cpp
const int N = 2e5 + 5;
int n, q, opt, l, r, a[N];
#define ls (rt << 1)
#define rs (rt << 1 | 1)
int val[N << 2], mx[N << 2], cnt[N << 2], cmin[N << 2], tag[N << 2];
void pushup(int rt) {mx[rt] = max(mx[ls], mx[rs]), cmin[rt] = min(cmin[ls], cmin[rs]);}
void pushdown(int rt) {
	if (!tag[rt]) return;
	cnt[ls] += tag[rt], cnt[rs] += tag[rt], cmin[ls] += tag[rt], cmin[rs] += tag[rt];
	tag[ls] += tag[rt], tag[rs] += tag[rt], tag[rt] = 0;
}
void build(int l = 1, int r = n, int rt = 1) {
	cnt[rt] = cmin[rt] = tag[rt] = 0;
	if (l == r) return val[rt] = mx[rt] = a[l], void();
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}
void add(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return cnt[rt]++, cmin[rt]++, tag[rt]++, void();
	int mid = (l + r) >> 1;
	pushdown(rt);
	if (tl <= mid) add(tl, tr, l, mid, ls);
	if (tr > mid) add(tl, tr, mid + 1, r, rs);
	pushup(rt);
}
void sub(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (mx[rt] <= 1) return;
	if (tl <= l && r <= tr && cmin[rt] >= 1) return cnt[rt]--, cmin[rt]--, tag[rt]--, void();
	if (l == r) {
		if (cnt[rt]) cnt[rt]--, cmin[rt]--;
		else mx[rt] = val[rt] = sqrt(val[rt]);
		return;
	}
	int mid = (l + r) >> 1;
	pushdown(rt);
	if (tl <= mid) sub(tl, tr, l, mid, ls);
	if (tr > mid) sub(tl, tr, mid + 1, r, rs);
	pushup(rt);
}
mod998244353 ask(int x, int l = 1, int r = n, int rt = 1) {
	if (l == r) {
		mod998244352 v = mod998244352(2).pow(cnt[rt]);
		return mod998244353(val[rt]).pow(static_cast<int>(v));
	}
	int mid = (l + r) >> 1;
	pushdown(rt);
	return x <= mid ? ask(x, l, mid, ls) : ask(x, mid + 1, r, rs);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	build();
	while (q--) {
		cin >> opt >> l >> r;
		if (opt == 1) sub(l, r);
		else add(l, r);
	}
	mod998244353 res = 0;
	for (int i = 1; i <= n; i++) res += ask(i);
	cout << res;
}
```

### P10496 The Luckiest Number

设答案为 $x$ 个 $8$ 连在一起的整数 $n$，由等比数列求和

$$
\begin{aligned}
n&=8+8\times 10+8\times 10^2 + \cdots + 8 \times 10^x\\
&=\sum_{i=0}^{x} 8 \times 10^i \\
&=\dfrac{8(10^x-1)}{9}
\end{aligned}
$$

设 $d=\gcd(L,8)$，则由题知 $L \mid \dfrac{8(10^x-1)}{9}$，故 $9L \mid 8(10^x-1)$，即

$\dfrac{9L}{d} \mid  (10^x-1)$因此，$10^ x \equiv 1 \pmod {\dfrac{9L}{d}}$。

由欧拉定理的推论 2，我们求出 $\varphi(\dfrac{9L}{d})$ 并枚举其约数检查即可，复杂度 $O(\sqrt{L} \log L)$。

```cpp
long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = (__int128) a * a % p, b >>= 1) {
		if (b & 1) res = (__int128) res * a % p;
	} return res;
}
vector<long long> factors(long long n) {
	vector<long long> res;
	for (long long i = 1; i * i <= n; i++) {
		if (n % i) continue;
		res.emplace_back(i);
		if (n / i != i) res.emplace_back(n / i);
	}
	sort(res.begin(), res.end());
	return res;
}

long long n;

void _main() {
	for (int kase = 1; ; kase++) {
		cin >> n;
		if (n == 0) break;
		cout << "Case " << kase << ": ";
		n = 9 * n / __gcd(n, 8LL);
		if (__gcd(n, 10LL) != 1) {cout << "0\n"; continue;}
		vector<long long> f = factors(phi(n));
		for (long long x : f) {
			if (power(10, x, n) == 1) {cout << x << '\n'; break;}
		}
	}
}
```

### *P2480 [SDOI2010] 古代猪文

我们先形式化题意，就是要求

$g^{\sum_{d \mid n} C_n^d} \bmod 999911659$首先你打个 $O(\sqrt{n})$ 判质数，发现 $999911659$ 是质数，由欧拉定理的推论 1

$g^{\sum_{d \mid n} C_n^d} \equiv g^{\sum_{d \mid n} C_n^d \bmod \varphi(999911659)} \pmod {999911659}$由欧拉函数性质 1，$\varphi(999911659)=999911659-1=999911658$，因此

$g^{\sum_{d \mid n} C_n^d} \equiv g^{\sum_{d \mid n} C_n^d \bmod 999911658} \pmod {999911659}$所以只需求 $\sum_{d \mid n} C_n^d \bmod 999911658$ 然后快速幂即可。如果直接上 exLucas，复杂度会爆炸，考虑怎么做。我们打一个 $O(\sqrt{n})$ 试除法分解质因数可得

$999911658=2\times 3 \times 4679 \times 35617$用 $O(\sqrt{n})$ 枚举 $d \mid n$，然后使用 Lucas 定理计算 $C^{d}_n$ 对 $2,3,4679,35617$ 取模的结果，然后 exCRT 合并答案即可。如果你还不会 Lucas 定理求组合数，请移步下文 9.2.4 学习后再看代码。

特别要注意，欧拉定理成立的条件是 $\gcd(g,999911659)=1$，若不成立要判无解，以及 exCRT 也要判无解。

```cpp
#define int long long
int n, g;

int power(int a, int b, int p) {
	int res = 1; for (a %= p; b; b >>= 1) {
		if (b & 1) res = res * a % p;
		a = a * a % p;
	} return res;
}

namespace Lucas {
	int fac[N], ifac[N];
	inline void init(int p) {
		fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
		for (int i = 2; i <= p; i++) fac[i] = fac[i - 1] * i % p, ifac[i] = power(fac[i], p - 2, p);
	} inline int C(int n, int m, int p) {
		if (n < m) return 0;
		return fac[n] * ifac[m] % p * ifac[n - m] % p;
	} int lucas(int n, int m, int p) {
		if (m == 0) return 1;
		if (n < p && m < p) return C(n, m, p);
		return lucas(n / p, m / p, p) * C(n % p, m % p, p) % p;
	}
}

namespace CRT {
	template <class T> void exgcd(T a, T b, T& x, T& y) {
		if (!b) return x = 1, y = 0, void();
		exgcd(b, a % b, y, x), y -= a / b * x;
	}
	template <class T> T crt(int n, const T* a, const T* m) {
		T x = 0, y = 0, p = m[1], res = a[1];
		for (int i = 2; i <= n; i++) {
			T a0 = p, b0 = m[i], c = (a[i] - res % b0 + b0) % b0, g = __gcd(a0, b0);
			if (c % g) return -1;
			exgcd(a0, b0, x, y);
			x = (__int128) x * c / g % b0, res += x * p, p = p / __gcd(p, b0) * b0, res = (res % p + p) % p;
		}
		return res;
	}
}

const int P[] = {0, 2, 3, 4679, 35617};
int a[5];

void _main() {
	cin >> n >> g;
	if (__gcd(g, 999911659LL) != 1) return cout << 0, void();  // 注意判无解
	for (int i = 1; i <= 4; i++) {
		Lucas::init(P[i]);
		for (int d = 1; d * d <= n; d++) {
			if (n % d) continue;
			a[i] = (a[i] + Lucas::lucas(n, d, P[i])) % P[i];
			if (n / d != d) a[i] = (a[i] + Lucas::lucas(n, n / d, P[i])) % P[i];
		}
	}
	int val = CRT::crt(4, a, P);
	if (val == -1) return cout << 0, void();  // 注意判无解
	cout << power(g, val, 999911659);
}
```

这个题基本把我们讲过的数论知识都用了一遍，是一道很全面很综合的好题。
