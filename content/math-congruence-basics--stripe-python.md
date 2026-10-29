---
id: math-congruence-basics
title: '同余与模运算（快速幂 / 乘法逆元 / Modint）'
category: '数学'
subcategory: '数论基础'
tags: ['同余', '快速幂', '乘法逆元', 'Modint']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 1. 同余

取模定义：当 $a,p$ 为正数时，有 $a \bmod p=a-b\lfloor \dfrac{a}{b} \rfloor$。

## 1.1 概念 & 性质

若 $a \bmod p =b \bmod p$，则称 $a,b$ 模 $p$ **同余**，记作

$a\equiv b \pmod p$也就是 $a,b$ 在模 $p$ 意义下相等。

推导性质时，我们省略 $\pmod p$。若 $a\equiv b$，同余有如下性质：

- 同加性：$a+c \equiv b+c$
- 同减性：$a-c \equiv b-c$
- 同乘性：$a \times c \equiv b \times c$

还有一个差性质：$a \equiv b \pmod p$ 等价于 $p \mid (a-b)$。它是同减性的推论。

还有一些性质如欧拉定理，扩展欧拉定理等，详见下文数论常用定理部分。

同加 / 减 / 乘性告诉我们，若在模意义下求加 / 减 / 乘法，那么直接把两个运算数先取模再运算最后取模一次，结果是正确的。**但是除法不行。**

请注意：在 C++ 中，对负数 `a` 取模的结果应当写作 `(a % p + p) % p`。

## 1.2 快速幂

快速幂是一个非常常用的数论技巧，可以在 $O(\log b)$ 时间内计算 $a^ b \bmod p$。

因为 $x \times y \equiv (x \bmod p) \times (y \bmod p) \pmod p$，所以一个暴力的做法是直接执行 $b$ 次 $a \gets a \times a \bmod p$，复杂度 $O(b)$。而这个过程可以倍增优化。例如：

$a^{13} \equiv a^{(1101)_2} \equiv a^8 \times a^4 \times a^1 \pmod p$将 $b$ 二进制分解，则位数为 $O(\log b)$，于是我们只要执行 $O(\log b)$ 次乘法。代码如下：

```cpp
template <class T> T mpow(T a, T b, T p) {
    T res = 0; for (a %= p; b; a = a * a % p, b >>= 1) {
        if (b & 1) res = res * a % p;
    } return res;
}
```

事实上，当 $a \times a$ 表示的不再是乘法，而是一个具有**结合律**的运算时，我们仍然可以用快速幂计算 $a^b$。例如加法、矩阵乘法、置换等，笔者把这种东西叫做广义快速幂。

### 1.2.1 快速乘

[题目链接](https://www.luogu.com.cn/problem/P10446)。如果我们要求 $a b \bmod p$，且 $a,b,p$ 为 64 位整数，直接算会溢出。

可以使用广义快速幂的方法来求，复杂度为 $O(\log \min(a, b))$，会导致复杂度飙升。下面介绍两种复杂度为 $O(1)$ 的快速乘。

#### 使用 128 位整数

直接使用 `__int128` 强制转换：

```cpp
int64_t a, b, p;
void _main() {
	cin >> a >> b >> p;
	cout << (int64_t) ((__int128) a * b % p);
}
```

#### *使用 64 位浮点数

由取模的定义

$ab \bmod p=ab-\lfloor \dfrac{ab}{p} \rfloor \times p$因为 $p$ 是 64 位整数，所以结果可以对 $2^{64}$ 取模，也就是 `unsigned long long` 自然溢出。现在 $ab$ 和 $\lfloor \dfrac{ab}{p} \rfloor \times p$ 都可以直接自然溢出解决。只要求出 $\lfloor \dfrac{ab}{p} \rfloor$ 即可。使用 `long double` 算出 $\dfrac{a}{p}$ 再乘上 $b$ 即可。

误差分析表明，用这种方法计算 $\dfrac{ab}{p}$ 的误差范围为 $(-0.5,0.5)$，加上 $0.5$ 并取整，误差为 $0$ 或 $1$，乘上 $p$ 后误差为 $0$ 或 $-p$，特判即可。

```cpp
int64_t a, b, p;
void _main() {
	cin >> a >> b >> p;
	uint64_t c = (uint64_t) a * b - (uint64_t) (1.0L * a / p * b + 0.5L) * p;
	cout << (c < uint64_t(p) ? c : c + p);
}
```

这种方法比 `__int128` 的常数更小。因为 `__int128` 本质上是两个 64 位整数拼起来的，对 $p$ 取模的时间消耗很大。实际上在不固定模数的情况下还有更快的 Barrett 约减等方法，这里不展开说明。

### *1.2.2 光速幂

若我们要多次询问 $a^b \bmod p$，且 $a,p$ 是常数，则可以在 $O(\sqrt{p})$ 时间内进行预处理并实现 $O(1)$ 查询。

设 $b=ks+t$，其中 $s \ge t$。可以预处理出 $a^s,a^{2s},a^{3s},\cdots,a^{\lceil \frac{p}{s} \rceil \times s}$ 和 $a^1,a^2,a^3,\cdots a^s$。记 $f_i=a^{is}, g_i=a^i$，于是 $a^b=a^{ks+t}=a^{ks} \times a^t=f_k g_t$。当 $s$ 取 $\sqrt{p}$ 时，时间复杂度最小，为 $O(\sqrt{p})$。

使用光速幂的时候多半是为了查询快，那么求出 $k,t$ 如果需要取模常数就很大。此时取 $s=65536$ 可以用位运算避免取模。

```cpp
struct FastPow {
	int p, f[65536], g[65536];
	FastPow(int a, const int mod) : p(mod) {
		f[0] = g[0] = 1;
		for (int i = 1; i < 65536; i++) f[i] = 1LL * f[i - 1] * a % p;
		int x = 1LL * f[65535] * a % p;
		for (int i = 1; i < 65536; i++) g[i] = 1LL * g[i - 1] * x % p;
	}
	int operator() (int b) const {return 1LL * f[b & 65535] * g[b >> 16] % p;}
};
```

## 1.3 乘法逆元

逆元就是模意义下的倒数：$a$ 的逆元定义为 $\dfrac{1}{a} \equiv x \pmod p$ 的解。根据同乘性，得到 $ax \equiv 1 \pmod p$。

不加证明地，给出结论：$a$ 在模 $p$ 意义下有逆元当且仅当 $a,p$ 互质。若 $b$ 有逆元，那么 $\dfrac{a}{b}\bmod p$ 就可以计算了。下面给出一些求逆元的方法。

### 1.3.1 费马小定理法

- 优点：复杂度 $O(\log p)$，编写简单。
- 缺点：仅适用于 $p$ 为质数。

在下文 5.1 部分介绍。这里不加证明地给出结论：若 $p$ 为质数，$a^{-1} \equiv a^{p-2} \pmod p$，可以快速幂求解。

### 1.3.2 exGCD 法

- 优点：复杂度 $O(\log a)$，编写比较简单。只要 $a$ 有逆元就可以求出。
- 缺点：复杂度有时不能带 $\log$，需要处理负数取模。

在下文 3.2.3 部分介绍。

### 1.3.3 线性正推法

- 优点：预处理复杂度 $O(n)$，查询速度快。
- 缺点：仅适用于对 $1,2,3,\cdots,n$ 求逆元的情况，仅适用于 $p$ 为质数。

考虑如何对 $i=1,2,3,\cdots,n$ 求逆元。首先 $1^{-1} \equiv 1 \pmod p$，接着写出取模的定义式：

$p=i \times \lfloor \dfrac{p}{i} \rfloor+p\bmod i$写成同余式：

$i \times \lfloor \dfrac{p}{i} \rfloor+p\bmod i \equiv 0 \pmod p$因为 $p$ 是质数，可以在同余式两边同乘 $i^{-1}(p \bmod i)^{-1}$，得到：

$(p\bmod i)^{-1}\times \lfloor \dfrac{p}{i} \rfloor +i^{-1} \equiv 0 \pmod p$移项：

$i^{-1} \equiv -(p\bmod i)^{-1}\times \lfloor \dfrac{p}{i} \rfloor \pmod p$根据余数性质，$p \bmod i < i$，那么就可以递推计算了。复杂度 $O(n)$。

```cpp
long long inv[N];
void solve() {
	inv[1] = 1;
	for (int i = 2; i <= n; i++) inv[i] = (p - p / i) * inv[p % i] % p;
}
```

根据这个递推式，还有一种做法是先预处理较小数据的逆元，然后根据递推式递归，如下：

```cpp
long long minv(int i) {return i < N ? inv[i] : (p - p / i) * minv(p % i) % p;}
```

这种做法的时间复杂度目前尚不明确，但实际表现良好。在[知乎回答](https://www.zhihu.com/question/59033693/answer/323292359)中，有大佬给出了该方法的上界 $O(n^{1/3 + \varepsilon})$ 和下界 $O\left( {\ln n \over \ln \ln n} \right)$，并且给出了估计 $O(\log p)$。

### 1.3.4 离线倒推法

- 优点：预处理复杂度 $O(n)$，查询速度快。
- 缺点：仅适用于离线情况下。

事实上，如果给出了任意 $n$ 个与 $p$ 互质的数 $a_1,a_2,a_3,\cdots,a_n$，则可以在 $O(n+\log p)$ 内求出它们的逆元。

记 $a_i$ 的前缀积 $s_i=s_{i-1}a_i \bmod p$。可发现 $s_i$ 与 $p$ 互质。于是计算出 ${s_n}^{-1}$ 后，倒推出每个 $s_i$ 的逆元：

${s_{i-1}}^{-1}={a_i}{s_i}^{-1} \bmod p$因此单个 $a_i$ 的逆元有

${a_i}^{-1}=s_{i-1}{s_i}^{-1} \bmod p$可以做到 $O(n+\log p)$。由于需要乘法和两次递推，常数比线性递推略大。这种方法常用于求阶乘的逆元。

## 1.4 Modint

根据上述方法，我们可以编写一个自动取模工具 `mod32`。下文中，它以 `modint` 或 `mint` 的别名出现。

```cpp
template <const int mod>
struct mod32 {
	static_assert((static_cast<long long>(mod)<<1)<=INT_MAX);

	int val;
	explicit operator int() const {return val;}
	static constexpr int norm(int x) {return x<0?x+mod:x;}
	static constexpr int get_mod() {return mod;}
	mod32():val(0){}
	mod32(int m):val(norm(m)){}
	mod32(long long m):val(norm(m%mod)){}
	mod32<mod> operator- () const {return -val;}
	bool operator== (const mod32<mod>& x) const {return val==x.val;}
	bool operator!= (const mod32<mod>& x) const {return val!=x.val;}
	bool operator< (const mod32<mod>& x) const {return val<x.val;}
	bool operator<= (const mod32<mod>& x) const {return val<=x.val;}
	bool operator> (const mod32<mod>& x) const {return val>x.val;}
	bool operator>= (const mod32<mod>& x) const {return val>=x.val;}
	mod32<mod>& operator+= (const mod32<mod>& x)
	{return val=(val+x.val>=mod?val+x.val-mod:val+x.val),*this;}
	mod32<mod>& operator-= (const mod32<mod>& x)
	{return val=(val-x.val<0?val-x.val+mod:val-x.val),*this;}
	mod32<mod>& operator*= (const mod32<mod>& x)
	{return val=(static_cast<unsigned long long>(val)*x.val%mod),*this;}
	mod32<mod> pow(long long b) const
	{mod32<mod> a(*this),res(1);for(;b;a*=a,b>>=1)if(b&1)res*=a;return res;}
//	static void exgcd(long long a,long long b,long long& x,long long& y) {b==0?(x=1,y=0):(exgcd(b,a%b,y,x),y-=a/b*x);}
//	mod32<mod> operator~ () const {long long a,b;return exgcd(val,mod,a,b),a;}
	mod32<mod> operator~ () const {return pow(mod-2);}
	mod32<mod>& operator/= (const mod32<mod>& x) {return *this*=~x;}
	mod32<mod> operator+ (const mod32<mod>& x) const
	{return mod32<mod>(*this)+=x;}
	mod32<mod> operator- (const mod32<mod>& x) const
	{return mod32<mod>(*this)-=x;}
	mod32<mod> operator* (const mod32<mod>& x) const
	{return mod32<mod>(*this)*=x;}
	mod32<mod> operator/ (const mod32<mod>& x) const
	{return mod32<mod>(*this)/=x;}
	friend std::istream& operator>> (std::istream& in, mod32<mod>& x)
	{long long v;return in>>v,x.val=norm(v%mod),in;}
	friend std::ostream& operator<< (std::ostream& out, const mod32<mod>& x)
	{return out<<x.val;}
};
using mod998244353 = mod32<998244353>;
using mod1000000007 = mod32<1000000007>;
```

这份代码用到了快速幂、exGCD 求逆元、费马小定理求逆元等方法，将在文中一一介绍。需要注意的是，在加减时使用 `a+b>=p?a+b-p:a+b` 的写法比 `(a+b)%p` 的写法常数要小的多。

这是一个[不固定模数的 Modint 模板](https://www.luogu.me/paste/wjbw3x3r)。

## 1.5 例题

### [模拟赛] 小学算术

> 求 $\dfrac{a}{b}$ 在 $c$ 进制表示下小数点后的第 $d$ 位。
>
> 多测，$T \le 10^5$，$1 \le a,b,c,d \le 10^9$。

类比十进制下的思考方法，你可以发现所求是 $\lfloor \dfrac{ac^d}{b}\rfloor \bmod c$。

直接做需要高精度。推式子：

$$
\begin{aligned}
\lfloor \dfrac{ac^d}{b}\rfloor \bmod c&=\lfloor \dfrac{ac^d \bmod {bc}}{b}\rfloor \bmod c\\
&=\lfloor \dfrac{(ac^{d-1}\bmod {b}) c}{b}\rfloor \bmod c
\end{aligned}
$$

快速幂解决即可。

### AT_abc146_e [ABC146E] Rem of Sum is Num

很好的同余性质题。先对 $a_i$ 作前缀和，记作 $p_i$，则原条件为

$(p_{r}-p_{l-1})\bmod k = r-l+1$根据余数的性质，等号两边都小于 $k$，因而

$p_{r}-p_{l-1} \equiv r-l+1 \pmod k$因为同余有同加同减性，可以移项，得

$p_r-r\equiv p_{l-1}-(l-1) \pmod k$所以把 $p_i$ 减去 $i$ 对 $k$ 取模，然后用哈希表统计即可。注意删掉超出范围的点，以及负数取模。复杂度 $O(n)$。

```cpp
const int N = 2e5 + 5;
long long n, k, a[N];

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] += a[i - 1];
	long long cnt = 0;
	for (int i = 0; i <= n; i++) a[i] = ((a[i] % k - i) % k + k) % k;
	unordered_map<int, int> mp;
	for (int i = 0; i <= n; i++) {
		if (i >= k) mp[a[i - k]]--;
		cnt += mp[a[i]], mp[a[i]]++;
	} cout << cnt;
}
```

### P1154 奶牛分厩

暴力的做法是枚举 $k$，然后 $O(n)$ 验证，$O(nk)$ 无法通过。

形式化一下题意，题意即为 $\nexists a,b \in S, a \equiv b \pmod p$。根据同余的差性质，等价为 $\nexists i \in \mathbb{N}^+, pi \mid (a-b)$。所以考虑 $O(n^2)$ 求出所有 $s_i-s_j$ 并标记。

仍然暴力枚举 $k$，再枚举 $k$ 的倍数 $ik$，只要判断 $ik$ 是否标记即可。复杂度 $O(n^2 + k \log k)$ 可以通过。

```cpp
const int N = 5e3 + 5, M = 1e6 + 5;
int n, a[N];
bool tag[M << 1];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		for (int j = i + 1; j <= n; j++) tag[abs(a[i] - a[j])] = true;
	}
	for (int i = 1; i < M; i++) {
		if (tag[i]) continue;
		bool flag = true;
		for (int j = i; j < M; j += i) {
			if (tag[j]) {flag = false; break;}
		}
		if (flag) return cout << i, void();
	}
}
```

### AT_abc357_d [ABC357D] 88888888

介绍三种做法。法一：设 $d$ 为 $n$ 的位数，则 $v(n)$ 可以看作一个 $10^d$ 进制数，根据等比数列求和：

$$
\begin{aligned}
v(n)&=\sum_{i=0}^{n-1} n\times (10^d)^i\\
&=n \sum_{i=0}^{n-1} (10^d)^i\\
&=n \times \dfrac{(10^d)^n-1}{10^d-1}
\end{aligned}
$$

求个逆元，写个快速幂即可。复杂度 $O(\log n)$。

```cpp
using ull = unsigned long long;
ull n;
const ull mod = 998244353;
ull power(ull a, ull b) {
	ull res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

void _main() {
	cin >> n;
	ull b = 1;
	while (b <= n) b *= 10;
	cout << n % mod * (power(b, n) - 1) % mod * power(b - 1, mod - 2) % mod;
}
```

法二：如果 $10^d-1$ 没有逆元，一个想法就是广义快速幂。定义 $a \times a$ 表示将 $a$ 和 $a$ 首尾拼接所得的数，求出 $a^n$ 即可。复杂度 $O(\log^2 n)$。

法三：使用广义快速幂进行等比数列求和，移步下文 7.1.2 分治求和法。也可以解决没有逆元的情况，复杂度 $O(\log^ 2n)$。

### AT_abc367_e [ABC367E] Permute K times

首先这个题可以直接倍增，可以看笔者之前的[题解](https://www.luogu.com.cn/article/gyi8yr80)。

将题目中的一次变换定义为两个序列之间的乘法。可以发现，这种乘法没有交换律，但是有结合律，可以广义快速幂求解。复杂度 $O(n \log k)$。事实上，这种乘法就是置换的概念。

```cpp
const int N = 2e5 + 5
int n, a[N], p[N], b[N];
long long k;
void mul(int *a) {
	for (int i = 1; i <= n; i++) b[i] = a[p[i]];
	copy(b + 1, b + n + 1, a + 1);
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (; k; k >>= 1) {
		if (k & 1) mul(a);
		mul(p);
	}
	for (int i = 1; i <= n; i++) cout << a[i] << ' ';
}
```
