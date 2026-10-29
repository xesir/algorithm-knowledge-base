---
id: math-prime-theory
title: '质数理论基础（判定 / 筛法 / 算术基本定理）'
category: '数学'
subcategory: '数论基础'
tags: ['质数', '素数筛', '威尔逊定理', '算术基本定理']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 2. 质数

定义一个正整数 $p$ 为**质数**，即它不存在 $1$ 和 $p$ 以外的约数。$1$ 不是质数。

## 2.1 质数分布

定义 $\pi(n)$ 表示 $[1,n]$ 中的质数数目，那么有 $\pi(n)=O(\dfrac{n}{\log n})$。

这个规律在枚举质数的题目中用处很大。它说明了质数每隔 $O(\log n)$ 个数出现一次。

## 2.2 质数的判定

### 2.2.1 枚举法

可以枚举 $[1,\sqrt{n}]$ 中的整数，判定其是否为 $p$ 的约数。因为 $a \mid p$ 时 $\dfrac{p}{a}\mid p$，所以无需枚举到 $n$。复杂度为 $O(\sqrt{n})$。

这里给出一个 $\dfrac{1}{6}$ 常数的实现，筛掉 $2$ 和 $3$ 的倍数：

```cpp
inline bool isprime(int x) {
	if (x <= 1) return false;
	if (x == 2 || x == 3) return true;
	if (x % 6 != 1 && x % 6 != 5) return false;
	for (int i = 5; i * i <= x; i += 6) {
		if (x % i == 0 || x % (i + 2) == 0) return false;
	}
	return true;
}
```

### *2.2.2 Miller-Rabin 法

先引入二次探测定理，即：若 $p$ 为奇质数，则 $x^2 \equiv 1 \pmod p$ 的解为 $x \equiv 1$ 或 $x \equiv p-1$。

> 简证：由 $x^2 \equiv 1 \pmod p$ 得 $(x-1)(x+1) \equiv 0 \pmod p$，即可得出。

接下来使用费马小定理：若 $p$ 为质数且 $\gcd(a,p)=1$，则 $a^{p-1} \equiv 1 \pmod p$。这个结论的讲解可到文章下部。

设 $p-1=u \times 2^t$，随机一个 $a$ 值并求得 $v=a^u \bmod p$，然后执行 $t$ 次 $v \gets v^2 \bmod p$，检查是否满足 $a^{p-1} \equiv 1 \pmod p$。

在 long long 范围内，只需选取 $a \in \{2,325,9375,28178,450775,9780504,1795265022\}$ 即可保证正确性。复杂度 $O(\log n)$。这里给出一个比较科技的写法。

```cpp
inline long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; b >>= 1) {
		if (b & 1) res = (__int128) res * a % p;
		a = (__int128) a * a % p;
	} return res;
}

const long long BASE[] = {2, 325, 9375, 28178, 450775, 9780504, 1795265022};
inline bool miller_rabin(long long n) {
	if (n < 2 || n % 6 % 4 != 1) return (n | 1) == 3;
	long long s = __builtin_ctzll(n - 1), d = n >> s;
	for (long long a : BASE) {
		long long p = power(a, d, n), i = s;
		while (p != 1 && p != n - 1 && a % n && i--) p = (__int128) p * p % n;
		if (p != n - 1 && i != s) return false;
	} return true;
}
```

## 2.3 威尔逊定理

若 $p$ 为质数，则

$(p-1)! \equiv -1 \pmod p$其逆定理也成立。即若 $(p-1)! \equiv -1 \pmod p$，则 $p$ 为质数。

## 2.4 算术基本定理

任何一个合数 $n$ 可以唯一分解成有限个质数的乘积。

存在性：用反证法，假设 $n$ 是最小的不能被分解的合数，则存在 $n=ab$，若 $a,b$ 都可分解，则 $n$ 可以被分解；若 $a,b$ 有不可分解的数，则 $a,b$ 才是最小的数，矛盾。

唯一性：用反证法，假设 $n$ 是最小的存在两种分解的合数，如果 $n$ 存在两种分解 $n={p_1}^{a_1} {p_2}^{a_2} \cdots ={q_1}^{b_1} {q_2}^{b_2} \cdots$，则 $p_1 | {q_1}^{b_1} {q_2}^{b_2} \cdots$，也就是 ${q_1}^{b_1} {q_2}^{b_2} \cdots$ 中有一个 ${q_i}{b_i}$ 可以整除 $p_1$，故 $p_1=q_i$，同除 $p_1$，则 ${p_2}^{a_2} \cdots$ 也是存在两种分解的合数，矛盾。

### 2.4.1 推论

设 $n$ 可以质因数分解为 $n=p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$。

推论 1：正数 $n$ 的正约数个数为

$(c_1+1)(c_2+1)(c_3+1)\cdots(c_m+1)=\prod_{i=1}^{m} (c_i+1)$推论 2：正数 $n$ 的所有正约数和为

$(1+p_1+p_1^2+\cdots+p_1^{c_1})\cdots(1+p_m+p_m^2+\cdots+p_m^{c_m})=\prod_{i=1}^{m} [\sum_{j=0}^{c_i} {p_i}^j]$可以用下文 7.1.2 的等比数列求和优化。

### 2.4.2 分解质因数

#### 试除法

与枚举法判素数同种原理，复杂度 $O(\sqrt{n})$。

```cpp
int p[N], c[N];
int decompose(int n) {
	int m = 0;
	for (int i = 2; i * i <= n; i++) {
		if (n % i) continue;
		p[++m] = i, c[m] = 0;
		while (n % i == 0) n /= i, c[m]++;
	}
	if (n > 1) p[++m] = n, c[m] = 1;
	return m;
}
```

需要注意的是，如果知道 $n$ 的值域，可以先用下面的质数筛打出一个质数表。根据质数分布规律，单次试除的复杂度降为 $O(\dfrac{\sqrt{n}}{\log n})$。

### *2.4.3 除数函数

- 定义**除数函数** $d(n)$ 为 $n$ 的正约数数目。容易发现 $d(n) \le 2\sqrt{n}$。

设 $n$ 可以质因数分解为 $n=p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$，根据推论 1 有

$d(n)=\prod_{i=1}^{m} (c_i+1)$除数函数 $d(n)$ 的级别远小于 $O(\sqrt{n})$。事实上，我们有

$\sum_{n=1}^{x} \dfrac{d(n)}{n}=\dfrac{1}{2} \log^2 x + 2 \gamma \log x+C+\delta$证明参见[这篇知乎讨论](https://www.zhihu.com/question/374042850/answer/3135401865)。其中 $C \approx \dfrac{1}{2}$，$\delta$ 为无穷小。这是一个均值估计。

事实上，还有

$\log d(n) \le \dfrac{\log 2 \log n}{\log \log n}(1+O(\dfrac{\log \log \log n}{\log \log n}))$[参考文献](https://www.zhihu.com/question/451354587/answer/1801059552)。它给出了一个比较好的估计。

- 下文中还会用到一个记号 $\omega(n)$，表示 $n$ 的质因子种类数。

一个粗略估计是 $\omega(n) \le \log n$。事实上，$\omega(n)$ 远小于 $O(\log n)$。因此有一个重要的 trick：基于质因子种类数很小，可以直接对质因子进行搜索或者状态压缩，复杂度约 $O(2^{\omega(n)})$。推荐阅读本人的[一类对质因子进行转态压缩的 trick](https://www.luogu.com.cn/article/f7uu8w9z)。

下面给出一个表格，它给出了 $d(n)$ 和 $\omega(n)$ 在一定范围内的上界：

![](https://cdn.luogu.com.cn/upload/image_hosting/4vaqgdw2.png)

求出 $n$ 的所有因子需要 $O(\sqrt{n})$ 的复杂度，现在我们知道复杂度 $O(\sqrt{n}+d^2(n))$ 是可以通过 $10^{12}$ 的数据的。

除数函数还有一个重要性质：对于 $\gcd(a,b)=1$，有 $d(ab)=d(a)d(b)$。这说明除数函数是一个积性函数。

## 2.5 质数筛

### 2.5.1 埃氏筛

小学课本上学过，我们每遍历到一个质数，就把它的倍数划去，最后剩下的未被划去的就是质数。埃氏筛使用 bitset 优化后速度快于线性筛。

```cpp
bitset<N> isprime;
void solve() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i * i <= N; i++) {  // 一个常数优化：筛到 O(sqrt(N)) 即可
		if (!isprime[i]) continue;
		for (int j = 1LL * i * i; j < N; j += i) isprime[j] = false;
	}
}
```

复杂度为 $O(n \log \log n)$。但是在实际计算中，bitset 优化后，它比 $O(n)$ 的线性筛更优秀。

### 2.5.2 线性筛

线性筛虽然跑不过 bitset 埃氏筛，但是它的思想值得学习。

埃氏筛复杂度到不了线性的原因是它会把一个合数划掉两遍。具体地，在标记 $i \times prime_j$ 时，需要确保 $i$ 的最小质因子不小于 $p$，即 $i\bmod prime_j =0$ 时跳出循环，这样复杂度就降到了 $O(n)$。

```cpp
bitset<N> isprime;
int tot, prime[N];
void solve() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i < N; i++) {
		if (isprime[i]) prime[++tot] = i;
		for (int j = 1; j <= tot; j++) {
			if (i * prime[j] >= N) break;
			isprime[i * prime[j]] = false;
			if (i & prime[j] == 0) break;
		}
	}
}
```

### 2.5.3 区间筛

在一些题目中，我们可能需要求出 $[l,r]$ 中的质数，其中 $l,r \le 10^{14}$ 但 $r-l \le 10^7$。区间筛可在 $O(n \log \log n)$ 的时间复杂度内解决问题，其中 $n=\max(\sqrt{r},r-l)$。

观察到 $[l,r]$ 中的合数的最大质因数不会超过 $\sqrt{r}$，这意味着我们可以用埃氏筛先处理出 $[1,\sqrt{r}]$ 内的质数，再用这些质数去筛掉 $[l,r]$ 中的合数。这也就是埃氏筛那个常数优化的原理。

```cpp
bitset<N> s, p;
void solve(int a, int b) {  // 筛出[a, b)之间的质数，用 p[i - a] 判断i是否为质数
	s.set(), p.set(), s[0] = s[1] = false;
	if (a <= 1) p[1 - a] = false;
	int z = (int) sqrt(b) + 1;
	for (int i = 2; i < z; i++) {
		for (int j = 2; i * j < z; j++) s[i * j] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		for (int j = max(i * i, (a + i - 1) / i * i); j < b; j += i) p[j - a] = false;
	}
}
```

## 2.6 例题

### P1147 连续自然数和

这种题型是一类常见题型，给出 $n$，并对于所求 $a,b$ 有 $ab=n$，则可以枚举 $n$ 的因数求解。

由等差数列求和：

$\dfrac{(l+r)(r-l+1)}{2}=n$枚举 $2n=ij$，则

$$
\left\{\begin{matrix}
r-l+1=i\\
l+r=j \\
\end{matrix}\right.
$$

解得

$$
\left\{\begin{matrix}
l=\dfrac{j-i+1}{2} \\
r=\dfrac{j+i-1}{2}
\end{matrix}\right.
$$

显然，$i,j$ 奇偶性应不同，且 $i$ 倒序枚举。复杂度 $O(\sqrt{n})$。

```cpp
int n;
void _main() {
	cin >> n; n *= 2;
	for (int i = sqrt(n); i >= 2; i--) {
		if (n % i) continue;
		int j = n / i;
		if ((i & 1) + (j & 1) == 1) cout << (j - i + 1) / 2 << ' ' << (j + i - 1) / 2 << '\n';
	}
}
```

### P8795 [蓝桥杯 2022 国 A] 选素数

设所求为 $x_0$，第一次操作后的值为 $x_1$，第二次操作后的值为 $x_2$。有一个重要结论是 $x_i-p_i+1 \le x_{i-1} \le x_i$。因为由题意得 $x_{i-1} \le x_i$，$p_i \mid x_i$ 且 $x_i$ 最小，用反证法，$x_i-p_i+1>x_{i-1}$，那么 $x_i-p_i$ 会成为这个位置的最小解，矛盾。

由此可知，$x_1-p_1+1 \le x_0 \le x_1$，让 $x_0$ 最小化，就要让 $x_1$ 最小，$p_1$ 最大。因为 $p_1 \mid x_1$，所以 $p_1$ 就是 $x_1$ 的最大质因子，此时 $x_0$ 取得最小值 $x_1-p_1+1$。我们再找到 $x_2$ 的最大质因子 $p_2$ 后枚举 $x_1 \in [x_2-p_2+1,x_2]$ 即可。复杂度 $O(n\sqrt{n})$，注意判无解。

```cpp
int decompose(int x) {
	int p = 1, t = x;
	for (int i = 2; i * i <= x; i++) {
		if (t % i) continue;
		while (t % i == 0) t /= i, p = i;
	}
	return max(t, p);
}

void _main() {
	int x2; cin >> x2;

	int p2 = decompose(x2);
	if (p2 == x2) return cout << -1, void();
	int res = INT_MAX;
	for (int x1 = p2 * (x2 / p2 - 1) + 1; x1 <= x2; x1++) {
		int p1 = decompose(x1), x0 = x1 - p1 + 1;
		if (x0 >= 3) res = min(res, x0);
	}
	cout << (res == INT_MAX ? -1 : res);
}
```

双倍经验：[CF923A Primal Sport](https://www.luogu.com.cn/problem/CF923A)。但是我们可爱的 RMJ 已经寄了。

### P1069 [NOIP 2009 普及组] 细胞分裂

形式化题意：给出 $m={m_1}^{m_2}$ 和 $n$ 个正整数 $a_i$，求

$\min_{i \in [1,n]} \min_{m\mid a_i^k} k$显然这题 $m$ 不能给它算出来，对 $m_1$ 分解质因数，则

$m={m_1}^{m_2}=(p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_h^{c_h})^{m_2}=p_1^{c_1m_2} p_2^{c_2m_2} p_3^{c_3m_2} \cdots p_h^{c_hm_2}$这样就得到了 $m$ 的质因数分解。对于每个 $a_i$，当且仅当 $\forall p_j, p_j \mid  a_i$ 时有解，否则 $a_i$ 自乘多少次都不能使 $m$ 成为其约数。

接下来我们求出 $p_j$ 在 $a_i$ 中出现的次数 $cnt$。则对于 $p_j$ 而言，$\min k=\lceil \dfrac{c_j}{cnt} \rceil$。然后用木桶原理，对所有 $\min k$ 取 $\max$，为 $a_i$ 的答案。总复杂度 $O(n \sqrt{V})$，$V$ 是值域。

```cpp
int n, m1, m2, a[N], tot;

int solve(int x) {
	int res = 0;
	for (int i = 1; i <= tot; i++) {
		if (x % p[i]) return INT_MAX;
		int cnt = 0;
		while (x % p[i] == 0) x /= p[i], cnt++;
		res = max(res, c[i] / cnt + (c[i] % cnt != 0));
	}
	return res;
}

void _main() {
	cin >> n >> m1 >> m2;
	for (int i = 1; i <= n; i++) cin >> a[i];
	tot = decompose(m1);
	for (int i = 1; i <= tot; i++) c[i] *= m2;
	int res = INT_MAX;
	for (int i = 1; i <= n; i++) res = min(res, solve(a[i]));
	cout << (res == INT_MAX ? -1 : res);
}
```

### P1865 A % B Problem

由 $m \le 10^6$ 可以筛一下 $m$ 以内的质数，询问用前缀和处理。远古代码太丑了不想放。

### P7960 [NOIP2021] 报数

质数筛的思想延伸。把含有 $7$ 的数先暴力找见，然后把它的倍数筛掉。

```cpp
const int N = 1e7 + 1000;  // 注意这里要开大点
int t, x, nxt[N];
bitset<N> dis;

inline bool check(int x) {
	for (; x != 0; x /= 10) if (x % 10 == 7) return true;
	return false;
}

void _main() {
	int last = 0;
	dis.reset();
	for (int i = 1; i < N; i++) {
		if (dis[i]) continue;
		if (check(i)) {
			for (int j = 1; j * i < N; j++) dis[j * i] = 1;
			continue;
		}
		nxt[last] = i, last = i;
	}
	for (cin >> t; t--; ) {
		cin >> x;
		cout << (dis[x] ? -1 : nxt[x]) << '\n';
	}
}
```

### AT_abc172_d [ABC172D] Sum of Divisors

不会推公式，只会大力筛法。注意到在埃氏筛标记倍数的过程中可以顺便求出 $d(n)$，直接做就好了。

```cpp
const int N = 1e7 + 5;
bitset<N> isprime;
int n, d[N];

void _main() {
	cin >> n;
	isprime.set(), isprime[1] = 0;
	for (int i = 2; i <= n; i++) {
		if (!isprime[i]) continue;
		int mul = 2;
		for (int j = i * 2; j <= n; j += i, mul++) isprime[j] = 0, d[j] += d[mul] + 1;
	}
	long long res = 0;
	d[1] = -1;
	for (int i = 1; i <= n; i++) res += 1LL * i * (d[i] + 2);
	cout << res;
}
```

### AT_abc412_e [ABC412E] LCM Sequence

打个表可以发现，$A_n$ 发生变化当且仅当 $n$ 为质数或质数的幂。

证明：由算术基本定理可设 $n={p_1}^{q_1}{p_2}^{q_2} \cdots {p_m}^{q_m}$。若 $m>1$，只要存在 $^{q_i}$ 的倍数，$n$ 加入就不会改变 $\operatorname{lcm}$。而若 $m=1$，此时 $n={p_1}^{q_1}>n-1$，此时 $n$ 为质数幂。

然后我们用区间筛把质数筛出来，并且在筛法过程中处理质数的幂即可。注意 $A_l$ 贡献是单独的。还有一种方法是用 Miller-Rabin 判质数并且处理质数幂。

```cpp
#define int long long
const int N = 1e7 + 5;
int l, r;
bitset<N> s, p;

void solve(int a, int b) {
	s.set(), p.set();
	int z = (int) sqrt(b) + 1;
	for (int i = 2; i < z; i++) {
		for (int j = 2; i * j < z; j++) s[i * j] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		for (int j = max(i * i, (a + i - 1) / i * i); j < b; j += i) p[j - a] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		int j = i * i;
		while (j < a) j *= i;
		for (; j < b; j *= i) p[j - a] = true;
	}
}

void _main() {
	cin >> l >> r;
	if (l == r) return cout << 1, void();
	solve(l, r + 1);
	int cnt = 0;
	for (int i = l; i <= r; i++) cnt += p[i - l];
	if (!p[0]) cnt++;
	cout << cnt;
}
```

### [模拟赛] 舔狗的付出

> 给你一个十进制正整数 $x$，在 $x$ 后面添加若干数字使它成为一个质数，可以不添加，求这个质数的最小值。
>
> 多测，$T,x \le 10^6$。

根据质数分布规律，$n$ 以内的质数最大间隔应该是 $O(\log n)$ 级别的。经过测试，在 $n=10^9$ 时最大间隔为 $72$。在本题中，加三位一定能够成为质数。

对于加一位或加两位的数字，我们可以用筛出 $10^8$ 以内的质数枚举解决。但是筛到 $10^9$ 肯定会 T。不妨将加三位的数打表出来：

```cpp
int f(long long x) {
	if (miller_rabin(x)) return -1;
	for (int i = 0; i <= 9; i++) {
		if (miller_rabin(x * 10 + i)) return -1;
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			if (miller_rabin(x * 100 + i * 10 + j)) return -1;
		}
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			for (int k = 0; k <= 9; k++) {
				if (miller_rabin(x * 1000 + i * 100 + j * 10 + k)) return x * 1000 + i * 100 + j * 10 + k;
			}
		}
	} return -1;
}

void _main() {
	int cnt = 0;
	for (int i = 1; i <= 1e6; i++) {
		int x = f(i);
		if (x != -1) cerr << "{" << i << ", " << x << "}, ";
	}
}
```

使用 Miller-Rabin 判质数的复杂度为 $O(nw^3 \log nw)$，其中 $n \le 10^6, w \le 10$，本机可以 4.6s 跑完。如果暴力判质数，要等的时间比较长。可以发现加三位的只有 $393$ 个数字，直接把表写进去就行了。

```cpp
const int N = 1e8 + 100;
unordered_map<int, int> table = {{16718, 16718003}, ...};   // 省略打表内容
bitset<N> isprime;
int x;
void _main() {
	cin >> x;
	if (table.count(x)) return cout << table[x] << '\n', void();
	if (isprime[x]) return cout << x << '\n', void();
	for (int i = 0; i <= 9; i++) {
		if (isprime[x * 10 + i]) return cout << x * 10 + i << '\n', void();
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			if (isprime[x * 100 + i * 10 + j]) return cout << x * 100 + i * 10 + j << '\n', void();
		}
	}
}   // 代码省略了筛质数的部分
```

### P3861 拆分

求出 $n$ 的所有正约数，记为 $x_1,x_2,\cdots,x_{d(n)}$。不妨设 $x$ 单调递增，记录 $p_x$ 表示约数 $x$ 出现的下标。

考虑一个 DP，设 $dp_{i,j}$ 表示将 $x_i$ 分解为若干不超过 $x_j$ 的数的方案数。答案即 $dp_{d(n),d(n)}-1$。考虑转移：

1. $x_i$ 的分解不包含 $x_j$：答案为 $dp_{i,j-1}$。
2. $x_i$ 的分解包含 $x_j$：必要条件是 $x_j \mid x_i$，此时将 $\dfrac{x_i}{x_j}$ 分解为若干小于 $x_j$ 的数的乘积，答案为 $dp_{p_{x_i/x_j}, j-1}$。

二者加起来即为答案。复杂度 $O(\sqrt{n}+d^2(n))$，可以通过。

```cpp
const int N = 6725;  // d(10^12) <= 6720
long long n, x[N];
mint dp[N][N];
gp_hash_table<int, int> p;

void _main() {
	x[0] = 0, p.clear();
	cin >> n;
	for (long long i = 1; i * i <= n; i++) {
		if (n % i) continue;
		x[++x[0]] = i;
		if (i * i != n) x[++x[0]] = n / i;
	}
	sort(x + 1, x + x[0] + 1);
	for (int i = 1; i <= x[0]; i++) p[x[i]] = i;
	for (int i = 1; i <= x[0]; i++) {
		dp[i][1] = (i == 1);
		for (int j = 2; j <= x[0]; j++) {
			dp[i][j] = dp[i][j - 1];
			if (x[i] % x[j]) continue;
			dp[i][j] += dp[p[x[i] / x[j]]][j - 1];
		}
	} cout << dp[x[0]][x[0]] - 1 << '\n';
}
```

### CF1878F Vasilije Loves Number Theory

注意到 $n=d(a)d(n)$，故原问题等价于判断 $d(n) \mid n$。

用一个 std::map 维护当前分解质因数的结果 ${p_1}^{c_1}{p_2}^{c_2}{p_3}^{c_3}\cdots$。那么 $d(n)$ 就是 $\prod (c_i+1)$。因为我们只需判断 $n \bmod d(n)=0$，所以算 $n$ 的时候对 $d(n)$ 取模即可。用一个快速幂来实现。

```cpp
int n, q, opt, x;

long long mpow(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = a * a % p, b >>= 1) {
		if (b & 1) res = res * a % p;
	} return res;
}
void decompose(int x, map<int, int>& mp) {
	for (int i = 2; i * i <= x; i++) {
		while (x % i == 0) mp[i]++, x /= i;
	}
	if (x != 1) mp[x]++;
}

void _main() {
	cin >> n >> q;
	map<int, int> mp;
	decompose(n, mp);
	map<int, int> cur = mp;
	while (q--) {
		cin >> opt;
		if (opt == 1) {
			cin >> x;
			decompose(x, cur);
			long long a = 1, b = 1;
			for (const auto& i : cur) b *= i.second + 1;
			for (const auto& i : cur) a = a * mpow(i.first, i.second, b) % b;
			cout << (a % b ? "NO\n" : "YES\n");
		} else cur = mp;
	} cout << '\n';
}
```

### P1463 [POI 2001 R1 / HAOI2007] 反素数

根据定义不难证明，$[1,n]$ 中最大的反素数就是 $d(x)$ 最大的数中的最小值。

注意到 $2\times 3\times 5 \times 7 \times 11\times 13\times 17 \times 19\times 23 \times 29\times 31=200560490130>2\times 10^9$，所以 $\omega(x) \le 10$。感性理解对于 $d(x)=\prod (c_i+1)$，最大化 $d(x)$ 同时最小化 $x$ 的方法就是使得前面的 $c$ 尽可能大，后面的小一些。可以证明，反素数一定满足 $c_1 \ge c_2 \ge \cdots \ge c_{10}$。

到这里，可以考虑直接爆搜。DFS 枚举指数，满足单调不升且总乘积不超过 $n$，直接记下 $d(x)$，搜索树并不大。

```cpp
#define int long long
int n, ansd, ansn, c[10];
const int p[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};
void dfs(int x, int num, int d) {
	if (d > ansd || (d == ansd && num < ansn)) ansn = num, ansd = d;
	if (x >= 10) return;
	int mul = 1;
	for (int i = 1; i <= (x ? c[x - 1] : 30); i++) {
		mul *= p[x], c[x] = i;
		if (num * mul > n) break;
		dfs(x + 1, num * mul, d * (i + 1));
	}
}
void _main() {
	cin >> n;
	dfs(0, 1, 1);
	cout << ansn;
}
```

### *P7603 [THUPC 2021] 鬼街

注意到 $\omega(10^5) \le 6$，通过预处理质因子分解，修改可以 $O(\omega(V))$ 暴力完成。

考虑查询怎么做。这需要一个叫做**折半警报器**的东西。

根据下文 7.2 的抽屉原理，设某个警报器的阈值为 $y$，监测的集合为 $S$，报警的充要条件为 $\sum_{x \in S} a_x \ge y$，其必要条件是 $\exists x \in S, a_x \ge \lceil \dfrac{y}{k} \rceil$。考虑将一个大警报器拆成几个小的维护某些位置。

对于每个位置 $x$，记录当前发生过的时间阈值和 $tag_x$。用一个 std::set 维护 $x$ 位置所有的警报器。为了消除之前的报警，在插入大警报器时需要差分，小警报器则暴力重构。

因为每次报警，大警报器的阈值至少下降 $\lceil \dfrac{y}{k} \rceil$，所以重构次数约为 $\log_{\frac{k}{k-1}} y$，总体复杂度 $O(n \log n \log V)$。实现上，由于 std::set 常数过大，应该使用类似 Dijkstra 的方法，维护一个堆并且懒删除卡常。一个神秘的地方是用 pbds 会 MLE on #7。

```cpp
const int N = 1e5 + 5;
int n, q, opt, x;
long long y;
vector<int> fac[N];
vector<int> decompose(int x) {
	vector<int> res;
	for (int i = 2; i * i <= x; i++) {
		if (x % i) continue;
		res.emplace_back(i);
		while (x % i == 0) x /= i;
	}
	if (x != 1) res.emplace_back(x);
	return res;
}

struct node {
	long long val; int id, time;
	node(long long a = 0, long long b = 0, long long c = 0) : val(a), id(b), time(c) {}
	bool operator< (const node& a) const {return val > a.val;}
};
priority_queue<node> heap[N];

long long lastans, tim, num, a[N], b[N], last[N], c[N], f[N];
vector<long long> nw, res;
void rebuild(const node& x) {
	int id = x.id;
	if (last[id] == -1) return;
	long long sum = 0;
	for (int i : fac[a[id]]) sum += c[i];
	if (sum >= f[id] + b[id]) return res.emplace_back(id), last[id] = -1, void();  // id报警
	b[id] += f[id] - sum, f[id] = sum, last[id] = ++tim;
	long long cnt = fac[a[id]].size(), d = (b[id] + cnt - 1) / cnt;
	for (int i : fac[a[id]]) heap[i].push(node{c[i] + d, id, tim});
}
void check(int x) {
	while (!heap[x].empty() && heap[x].top().val <= c[x]) {
		node u = heap[x].top(); heap[x].pop();
		if (last[u.id] != u.time) continue; // 懒删除
		rebuild(u);
	}
}
void ask() {
	res.clear(), res.insert(res.end(), nw.begin(), nw.end());
	nw.clear();
	for (int i : fac[x]) c[i] += y;
	for (int i : fac[x]) check(i);
	sort(res.begin(), res.end());
	cout << (lastans = res.size()) << ' ';
	for (int i : res) cout << i << ' ';
	cout << '\n';
}
void add() {
	long long cnt = fac[x].size(), d = (y + cnt - 1) / cnt;
	tim++, num++;
	if (y == 0) return nw.emplace_back(num), void();
	a[num] = x, b[num] = y, last[num] = tim;
	for (int i : fac[x]) f[num] += c[i], heap[i].push(node{c[i] + d, num, tim});
}

void _main() {
	cin >> n >> q;
	for (int i = 2; i <= n; i++) fac[i] = decompose(i);
	while (q--) {
		cin >> opt >> x >> y; y ^= lastans;
		if (opt == 0) ask();
		else add();
	}
}
```
