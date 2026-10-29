---
id: math-oi-foundations
title: 'OI 中的数学基础'
category: '数学'
subcategory: '数学基础'
tags: ["数学基础","数论","组合数学","OI数学"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
[$\Huge 更好的阅读体验$](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)

请注意，由于本文 markdown 源码达到了 400K，页面渲染较慢是正常现象，请耐心等待。

> 本文共 33.1w 字符，1.2w 行，200 道例题，完整阅读大概需要 6.5h。

## 0. 前言

为什么要写这篇文章呢？因为教练让我们选一个专题写博客然后交流。

为什么选数学呢？因为线段树分块都被选走了，而数学专题没人选，并且可以把写过的笔记拼起来（

本文章涉及数论 & 组合数学两个部分，还包含一些数学杂项，整体内容比较简单。

## 注意事项及约定

- 若无特殊说明，本文中使用符号 $\oplus$ 表示按位异或，$\&$ 表示按位与，$|$ 表示按位或，$\sim$ 表示按位取反。
- 本文代码中出现的 `modint` 或 `mint` 是笔者编写的自动取模工具，代码可见 [this](https://www.luogu.me/paste/6wwixwot)。
- 本文代码中出现的 `BigInteger` 是笔者编写的高精度整数，代码可见 [this](https://www.luogu.com.cn/article/rz9ubds1)。
- **本文有大量例题。对于较难的例题，用 `*` 标出，没有看懂可以先跳过。**
- [《OI 中的数学基础》例题题单](https://www.luogu.com.cn/training/875199)。题目按在文章中的出现顺序排序，分成了五个部分。
- **本文存在一些较难的章节，用 `*` 标出。初学者可以先跳过。**

## 更新

- 2025-08-06 第一版：通过洛谷审核。
- 2025-10-05 第二版：调整文章结构，优化目录，重构分拆数部分，新增大量例题并修复一些 Bug。

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

## 3. 最大公约数

定义**最大公约数** $\gcd(a,b)$ 为：满足 $k \mid a$ 且 $k \mid b$ 的最大的 $k$。定义 $\gcd(a,0)=0$。

定义最小公倍数 $\operatorname{lcm}(a,b)$ 为：满足 $a \mid k$ 且 $b \mid k$ 的最小的 $k$。

## 3.1 求解 GCD

### 3.1.1 分解质因数法

将两数分解质因数：$a=p_1^{a_1}p_2^{a_2} \cdots, b=a=p_1^{b_1}p_2^{b_2} \cdots$，则 $\gcd(a,b)=p_1^{\min(a_1,b_1)}p_2^{\min(a_2,b_2)} \cdots$，复杂度为 $O(\sqrt{n})$。

这证明：求 gcd 和求最小值有共通之处。

### 3.1.2 辗转相除法

GCD 有如下性质：

$\gcd(a,b)=\gcd(b,a \bmod b)$利用此可递归计算 gcd，出口为 $\gcd(a,0)=a$。复杂度 $O(\log (a+b))$。

```cpp
int gcd(int a, int b) {return b == 0 ? a : gcd(b, a % b);}
```

C++ STL 中有函数 `std::__gcd`，为迭代的辗转相除法实现，复杂度为 $O(\log n)$，可以直接使用。

### 3.1.3 更相减损法

GCD 有如下性质：

$\gcd(a,b)=\gcd(a-b,b)$如果直接递归计算，复杂度为 $O(n)$。Stein 算法对此进行了优化：

若 $2\mid a$ 且 $2\mid b$，则 $\gcd(a,b)=2\gcd(\dfrac{a}{2},\dfrac{b}{2})$。而若只有 $2 \mid  a$，则 $\gcd(a,b)=\gcd(\dfrac{a}{2},b)$。这启示我们可以在过程中除掉约数 $2$，然后再更相减损，复杂度就降到了 $O(\log n)$。Stein 算法常用于大整数的 GCD。

Stein 算法可以借助二进制内置函数优化，称作 Binary GCD，理论复杂度 $O(\log (a+b))$，但在实际表现中可以看作大常数 $O(1)$。这份代码的速度比 `std::__gcd` 更快，可以卡过 [P5435](https://www.luogu.com.cn/problem/P5435)。

```cpp
template <class T> constexpr T gcd(T a, T b) {
	int az = ctz(a), bz = ctz(b), z = min(az, bz);
	for (b >>= bz; a; ) {
		a >>= az; int d = a - b;
		az = ctz(a - b), b = min(a, b), a = abs(d);
	} return b << z;
}
```

## 3.2 exGCD

exGCD 用于求解形如 $ax+by=\gcd(a,b)$ 一类的不定方程。

### 3.2.1 裴蜀定理

对于任意非零整数 $a,b$，$ax+by=c$ 有整数解当且仅当 $c \mid  \gcd(a,b)$。

#### 推论

若 $a_1,a_2,a_3,\cdots,a_n$ 是不全为 $0$ 的整数，则存在整数 $x_1,x_2,x_3,\cdots,x_n$ 使得

$a_1x_1+a_2x_2+a_3x_3+\cdots+a_nx_n=\gcd(a_1,a_2,a_3,\cdots,a_n)$其逆定理也成立。

### 3.2.2 不定方程

由 $\gcd(a,b)=\gcd(b,a\bmod b)$ 得：

$$
\begin{aligned}
ax+by&=bx'+(a\bmod b)y'\\
&=bx'+(a-b\lfloor \dfrac{a}{b} \rfloor)y'\\
&=ay'+b(x'-y'\lfloor \dfrac{a}{b} \rfloor)
\end{aligned}
$$

递归式：$x=y',y=x'-y'\lfloor \dfrac{a}{b} \rfloor$，这样就可以 $O(\log (a+b))$ 求解。

```cpp
void exgcd(int a, int b, int& x, int& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
```

可以证明，通过这种方法得到的 $x,y$ 在值域范围内。所以不用担心溢出的问题。

### 3.2.3 乘法逆元

逆元就是模意义下的倒数：求 $x \equiv \dfrac{1}{a} \pmod m$ 的解。

移项得：$ax \equiv 1 \pmod m$，即为求解不定方程 $ax-bm=1$，用 exGCD 求解即可。

这里可以发现，$x$ 在模 $m$ 意义下有逆元当且仅当 $x,m$ 互质。利用乘法逆元，可以实现模意义下的除法。

### 3.2.4 线性方程组

这里的线性方程组是指求一个最小的 $x$ 满足

$$
\left\{\begin{matrix}
x \equiv a_1 \pmod {m_1} \\
x \equiv a_2 \pmod {m_2} \\
\cdots \\
x \equiv a_n \pmod {m_n}
\end{matrix}\right.
$$

两两考虑。比如我们把前两个方程变成不定方程：$x=m_1p+a_1=m_2q+a_2$。则 $m_1p-m_2q=a_2-a_1$，利用 exGCD 解出一组可行解 $(p,q)$，然后这两个方程组的共同解为 $x \equiv (m_1p+a_1) \pmod {\operatorname{lcm}(m_1,m_2)}$。然后把 $n$ 个方程都这么合并起来即可。这种方法叫 exCRT。

至于为什么不说 CRT，因为我觉得 exCRT 比 CRT 更容易理解，适用范围更广，代码还好写。

## 3.3 常用性质

这里我们不加证明地给出一些 $\gcd$ 的性质。

1. $\gcd(a, b) \times \operatorname{lcm}(a,b)=ab$。
2. $\gcd(a,b) \le |a- b|$。
3. $\gcd(b,a \bmod b)=\gcd(a,b)$。
4. $\gcd(a,b)=\gcd(a-b,b)$。
5. $\gcd(a,b)=\sum_{x \mid a, x\mid b} \varphi(x)$。$\varphi(x)$ 为下文第 4 章要讲的欧拉函数。
6. $\gcd(a,b)=c$，则 $\gcd(\dfrac{a}{c},\dfrac{b}{c})=1$。证明见第一道例题。

## 3.4 例题

前面是 GCD 性质和裴蜀定理应用题，后面是 exGCD & exCRT 例题。

### P1072 [NOIP 2009 提高组] Hankson 的趣味题

注意到性质 6：若 $\gcd(a,b)=c$，且 $a=k_1c,b=k_2c$，则 $\gcd(k_1,k_2)=1$。

证明：考虑反证法，设 $K=\gcd(k_1,k_2) \ne 1$，则存在不为 $1$ 的正整数 $p,q$ 使得 $k_1=pK,k_2=qK$，因而 $a=pKc,b=qKc$，$\gcd(a,b)=Kc \ne c$，故原结论成立。

由题可得：$x=a_1 p$，$b_1=xq$，其中 $p,q$ 为正整数。

由上述结论得：$\gcd(\dfrac{a_0}{a_1},\dfrac{x}{a_1})=1$。又有 $\operatorname{lcm}(x,b_0)=b_1$，故 $\gcd(\dfrac{b_1}{x},\dfrac{b_1}{b_0})=1$。且 $x\mid b_1$，枚举 $x$ 并判断即可，复杂度 $O(\sqrt{b_1} \log V)$。

```cpp
int a0, a1, b0, b1;
void _main() {
	cin >> a0 >> a1 >> b0 >> b1;
	int cnt = 0;
	for (int x = 1; x * x <= b1; x++) {
		if (b1 % x) continue;
		if (x % a1 == 0 && __gcd(x / a1, a0 / a1) == 1 && __gcd(b1 / x, b1 / b0) == 1) cnt++;
		int y = b1 / x;
		if (x == y) continue;
		if (y % a1 == 0 && __gcd(y / a1, a0 / a1) == 1 && __gcd(b1 / y, b1 / b0) == 1) cnt++;
	}
	cout << cnt << '\n';
}
```

### UVA10622 完全P次方数 Perfect P-th Powers

将 $x$ 分解质因数为 ${p_1}^{c_1} {p_2}^{c_2} {p_3}^{c_3} \cdots$。注意到 $(a^xb^y)^z=a^{xz} b^{xz}$。所以 $p=\gcd(c_1,c_2,c_3,\cdots)$。

需要注意 $x$ 不一定是正数。此时 $p$ 不能是偶数，不然 $a^p$ 就是正数了。

```cpp
#define int long long
int x;
void _main() {
	while (cin >> x, x) {
		vector<int> c;
		bool neg = x < 0;
		x = abs(x);
		for (int i = 2; i * i <= x; i++) {
			if (x % i) continue;
			c.emplace_back(0);
			while (x % i == 0) x /= i, c.back()++;
		}
		if (x != 1) c.emplace_back(1);
		int g = 0;
		for (int i : c) g = __gcd(g, i);
		if (neg) g >>= __builtin_ctzll(g);
		cout << g << '\n';
	}
}
```

### CF1499D The Number of Pairs

设 $a=n\times \gcd(a,b),b=m \times \gcd(a,b)$，大力推式子：

$$
\begin{aligned}
c \times \operatorname{lcm(a,b)}-d\times \gcd(a,b)&=x\\
c \times \dfrac{ab}{\gcd(a,b)}-d\times \gcd(a,b)&=x\\
c nm \times \gcd(a,b)-d\times \gcd(a,b)&=x\\
\gcd(a,b)&=\dfrac{x}{cnm-d}
\end{aligned}
$$

说明 $(cnm-d) \mid x$。$O(\sqrt{x})$ 地枚举 $x$ 的因子 $i$。移项有 $cnm=d+i$，即 $c \mid (d+i)$。再将 $\dfrac{d+i}{c}$ 分解质因数，对于每种质因子只有全给 $n$ 和全给 $m$ 两种选择，否则会使得 $(cnm-d) \nmid x$。用线性筛先得到每个数的质因子个数，则贡献为 $2^{cnt}$。复杂度 $O(n+T\sqrt{n})$。

```cpp
const int N = 2e7 + 5;
bitset<N> isprime;
int cnt[N], prime[N];
void init() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i < N; i++) {
		if (isprime[i]) prime[++prime[0]] = i, cnt[i] = 1;
		for (int j = 1; j <= prime[0] && 1LL * i * prime[j] < N; j++) {
			isprime[i * prime[j]] = false;
			if (i % prime[j] == 0) {
				cnt[i * prime[j]] = cnt[i];
				break;
			}
			cnt[i * prime[j]] = cnt[i] + 1;
		}
	}
}

long long c, d, x;
long long f(int x) {
	if ((x + d) % c) return 0;
	return 1LL << cnt[(x + d) / c];
}
void _main() {
	cin >> c >> d >> x;
	long long res = 0;
	for (long long i = 1; i * i <= x; i++) {
		if (x % i) continue;
		res += f(i);
		if (i * i != x) res += f(x / i);
	} cout << res << '\n';
}
```

### CF2148G Farmer John’s Last Wish

不难发现满足 $\gcd_{i=1}^{k} a_i \ne \gcd_{i=1}^{k+1} a_i$ 的最大的 $k$ 等价于满足 $\gcd_{i=1}^{n} a_i \ne \gcd_{i=1}^{k+1} a_i$ 的最大的 $k$。

考虑对前缀 $p$ 的解法，记 $\gcd_{i=1}^{len} p_i = g$，则找到最长的都是 $g$ 的倍数的一段放在前面，这段长度就是答案。动态维护 $f_i$ 表示当前前缀中 $i$ 的倍数数目，答案即为 $\max f_{i \times g}$。

由于每次操作使得 $g$ 变为原本的因子，故 $g$ 的倍数集合只增不删，枚举 $g$ 的倍数 $j \times g$，将 $j \times g$ 加入集合并更新答案。然后遍历 $a_i$ 的因子 $j$，更新 $f_j$，当 $j$ 是 $g$ 的倍数时更新答案。

注意到复杂度为 $O(n^2)$。可以发现 $g$ 降到 $1$ 最多 $O(\log V)$ 次，可以对 $g$ 的变化记忆化一下。复杂度为 $O(n \log V+n\log n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], f[N], vis[N], tag[N];
vector<int> fac[N];

void prework() {
	for (int i = 1; i < N; i++) {
		for (int j = i; j < N; j += i) fac[j].emplace_back(i);
	}
}
void _main() {
	memset(f, 0, sizeof(int) * (n + 1)), memset(vis, 0, sizeof(int) * (n + 1)), memset(tag, 0, sizeof(int) * (n + 1));
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	int g = a[1], cur = 0;
	for (int i = 1; i <= n; i++, g = __gcd(g, a[i])) {
		if (!tag[g]) {
			for (int j = 2; j * g <= n; j++) vis[j * g] = true, cur = max(cur, f[j * g]);
			tag[g] = true;
		}
		for (int j : fac[a[i]]) {
			f[j]++;
			if (vis[j]) cur = max(cur, f[j]);
		} cout << cur << ' ';
	} cout << '\n';
}
```

### P8255 [NOI Online 2022 入门组] 数学游戏

考虑对 $z,x,y$ 质因数分解得：

$\prod {p_i}^{z_i}=\prod {p_i}^{x_i+y_i+\min(x_i,y_i)}$即 $z_i=x_i+y_i+\min(x_i,y_i)$。分类讨论：

1. 若 $y_i \ge x_i$，则 $z_i=x_i+2y_i$，解得 $y_i=\dfrac{z_i-x_i}{2}$。
2. 若 $y_i < x_i$，则 $z_i=2x_i+y_i$，解得 $y_i=z_i-2x_i$。

因此，$y_i=\min(\dfrac{z_i-x_i}{2},z_i-2x_i)$。

想想指数出现 $\min$、除法、减号、乘法的意义：就是取 $\gcd$，开方，除法，乘方。通过配凑系数得到：

$y=\dfrac{x}{z\sqrt{\gcd(x^2,\frac{x}{z})}}$不能整除，不能开方均判为无解。

```cpp
const double eps = 1e-8;
int x, z;

void _main() {
	cin >> x >> z;
	if (z % x) return cout << -1 << '\n', void();
	int128 t = z / x, u = __gcd((int128) x * x, t), us = sqrt(1.0L * u) + 0.5;
	if (u != us * us) return cout << -1 << '\n', void();
	cout << (long long) (t / us) << '\n';
}
```

### P4549 【模板】裴蜀定理

由 $\gcd(a,b,c)=\gcd(a,\gcd(b, c))$ 得

$\sum_{i=1}^{n} a_i x_i = \gcd_{i=1}^{n} |a_i|$而题目中记 $\sum x_i$ 为 $S$，根据裴蜀定理可知 $\gcd_{i=1}^{n} |a_i|$ 是 $S$ 的约数，$S$ 最小时二者相等。也就是求所有数的 $\gcd$。

### CF510D Fox And Jumping

根据裴蜀定理的推论，能跳到所有位置当且仅当我们选出的长度的 $\gcd=1$。于是设 $dp_i$ 表示选择一些长度使得其最大公约数为 $i$ 的最小代价，采用刷表，枚举 $i,j \in [1,n]$ 易得

$dp_{\gcd(l_i, j)} \gets \min(dp_{\gcd(l_i, j)}, c_{i}+v)$对于单个转移，有

$dp_{l_i} \gets \min(dp_{l_i},c_i)$由于下标能到 $10^9$，暴力 dp 是不行的。但是有用的 $dp$ 值不多，于是我们用 `std::map` 维护转移，复杂度比较玄学。

```cpp
const int N = 305;
int n, l[N], c[N];
map<int, int> dp;
void upd(int x, int v) {
	if (!dp.count(x)) dp[x] = v;
	else dp[x] = min(dp[x], v);
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> l[i];
	for (int i = 1; i <= n; i++) cin >> c[i];
	for (int i = 1; i <= n; i++) {
		for (const auto& h : dp) {
			int j = h.first, v = h.second;
			upd(__gcd(l[i], j), c[i] + v);
		} upd(l[i], c[i]);
	}
	cout << (dp.count(1) ? dp[1] : -1);
}
```

### *P2520 [HAOI2011] 向量

不了解向量运算法则请翻到下文 22.1 线性代数部分。

对于 $(-a,-b)$ 这样的向量，可以视为减去 $(a,b)$，其余同理，这样八种就变成了四种。问题转化为求 $c,d,e,f \in \mathbb{N}$ 使得 $c(a,b)+d(a,-b)+e(b,a)+f(b,-a)=(x,y)$，拆开得到

$$
\left\{\begin{matrix}
a(c+d)+b(e+f)=x \\
a(e-f)+b(c-d)=y
\end{matrix}\right.
$$

根据裴蜀定理，上面方程组有整数解的必要条件是 $\gcd(a,b) \mid x$ 且 $\gcd(a,b) \mid y$。

但是这样只能保证 $c+d,e+f,e-f,c-d \in \mathbb{N}$，而 $c,d,e,f$ 会出现 $\dfrac{1}{2}$ 的情况。

所以有解的充要条件是 $\gcd(a,b) \mid x$ 且 $\gcd(a,b) \mid y$ 且 $c+d,c-d$ 奇偶性相同、$e+f,e-f$ 奇偶性相同。

设 $c+d=2k_1+m_1,c-d=2k_2+m_1,e+f=2k_3+m_2,e-f=2k_4+m_2$，且 $m_1,m_2 \in \{0,1\}$，得到

$$
\left\{\begin{matrix}
a(2k_1+m_1)+b(2k_3+m_2)=x \\
a(2k_4+m_2)+b(2k_2+m_1)=y
\end{matrix}\right.
$$

分四种情况讨论。以 $m_1=m_2=0$ 为例，等式两边同除 $2$可得 $\gcd(a,b) \mid \dfrac{x}{2}$，即 $2\gcd(a,b) \mid x$，对于 $y$ 同理。

以 $m_1=0,m_2=1$ 为例，同加 $b$ 再同除 $2$，化简得到 $2 \gcd(a,b) \mid (x+b)$。

剩下两种类似。四种可能或起来即可。

```cpp
long long a, b, x, y;

void _main() {
	cin >> a >> b >> x >> y;
	long long g = __gcd(a, b);
	if (x % g || y % g) return cout << "N\n", void();
	g *= 2;
	if (x % g == 0 && y % g == 0) return cout << "Y\n", void();
	if ((x + b) % g == 0 && (y + a) % g == 0) return cout << "Y\n", void();
	if ((x + a) % g == 0 && (y + b) % g == 0) return cout << "Y\n", void();
	if ((x + a + b) % g == 0 && (y + a + b) % g == 0) return cout << "Y\n", void();
	cout << "N\n";
}
```

### *P3518 [POI 2011] SEJ-Strongbox

设密码集合为 $S$，则 $\forall i,j \in S, (i+j) \bmod n \in S$。考虑对于 $i \in S$，必然有 $\forall k \in \mathbb{N}^+, ki \bmod n \in S$，所以首先考虑 $ki \bmod n$ 能取到哪些数。

首先讨论 $\gcd(i,n)=1$，此时 $ki \bmod n$ 取遍 $0,1,2,3,\cdots,n-1$。因为同余方程 $ki \equiv x \pmod n$ 必然有解。一般地，猜想 $i \in S$ 使得 $ki=x \pmod n$ 有解，即 $\gcd(k,n)=1$，反证法得到 $ki \bmod n$ 取到了所有 $\gcd(i,n)$ 的倍数。

对于 $i \notin S$，$i$ 的所有因子也不是密码。根据这个判定方法，枚举 $d \mid \gcd(m_k,n)$，若合法，则对于 $d \in S$ 的密码数量就是 $\dfrac{n}{d}$。复杂度 $O(k \sqrt {\gcd(m_k,n)})$，可以获得 76pts。

```cpp
#define int long long
const int N = 2.5e5 + 5;
int n, k, a[N];
bool check(int x) {
	for (int i = 1; i < k; i++) {
		if (a[i] % x == 0) return false;
	} return true;
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= k; i++) cin >> a[i];
	int x = __gcd(n, a[k]);
	for (int i = 1; i * i <= x; i++) {
		if (x % i) continue;
		if (check(i)) return cout << n / i, void();
	}
	for (int i = sqrt(x) + 1; i >= 1; i--) {
		if (x % i) continue;
		if (check(x / i)) return cout << n / (x / i), void();
	}
}
```

考虑优化。枚举因子最多只有 $10^7$，思考如何快速 `check`。首先令 $a_i \gets \gcd(a_i,x)$，显然不影响结果。接着对 $x$ 质因数分解。注意到 $2\times 3\times 5\times 7\times 11\times 13\times 17\times 19\times 23\times 29\times 31\times 37\times 41\times 43>10^{14}$，考虑对于每个 $a_i$ 直接按质因子爆搜因数。使用哈希表记忆化搜索，复杂度大概是 $O(k \log V+\sqrt{V}+d(V) \omega(V))$。

```cpp
#define int long long
const int N = 2.5e5 + 5;
int n, k, a[N];
bool check(int x) {
	for (int i = 1; i < k; i++) {
		if (a[i] % x == 0) return false;
	} return true;
}
vector<int> p;
void decompose(int x) {
	for (int i = 2; i * i <= x; i++) {
		if (x % i) continue;
		p.emplace_back(i);
		while (x % i == 0) x /= i;
	}
	if (x != 1) p.emplace_back(x);
}
unordered_set<int> f;
void dfs(int x) {
	if (f.count(x)) return;
	f.emplace(x);
	for (int i : p) {
		if (x % i == 0) dfs(x / i);
	}
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= k; i++) cin >> a[i];
	int x = __gcd(n, a[k]);
	decompose(x);
	for (int i = 1; i < k; i++) dfs(__gcd(a[i], x));
	for (int i = 1; i * i <= x; i++) {
		if (x % i) continue;
		if (!f.count(i)) return cout << n / i, void();
	}
	for (int i = sqrt(x) + 1; i >= 1; i--) {
		if (x % i) continue;
		if (!f.count(x / i)) return cout << n / (x / i), void();
	}
}
```

### P1082 [NOIP 2012 提高组] 同余方程

这东西我们在之前的乘法逆元讲过方法了，就是用 exGCD 解方程 $ax-by=1$。输入保证有解，意味着 $\gcd(a,b)=1$，所以这就是 exGCD 方程的标准形式。细节上，求出 $x$ 以后要处理负数问题。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}

long long a, b;
void _main() {
	cin >> a >> b;
	long long x, y; exgcd(a, b, x, y);
	cout << (x % b + b) % b;
}
```

### P5656 【模板】二元一次不定方程 (exgcd)

首先由裴蜀定理判无解，若 $c$ 不是 $\gcd(a,b)$ 的倍数则直接无解。

设 $\gcd(a,b)=d$。考虑用 exGCD 求解方程 $ax+by=d$，将解记作 $x_0,y_0$。则

$ax_0+by_0=d\\$方程两边同乘 $\dfrac{c}{d}$ 转化为所求：

$a\dfrac{cx_0}{d}+b\dfrac{cy_0}{d}=c\\$故原方程的一组解为 $x_1=\dfrac{cx_0}{d},y_1=\dfrac{cy_0}{d}$。

接下来考虑构造通解形式，设

$a(x_1+m)+b(y_0+n)=c$不难发现 $m,n$ 满足条件 $am+bn=0$。仍然利用裴蜀定理，解得 $m=p \times \dfrac{b}{d}, n=-p \times {a}{d}$，其中 $p$ 是正整数。于是我们得到原方程的通解

$$
\left\{\begin{matrix}
x=x_1+p \times \dfrac{b}{d} \\
y=y_1-p \times \dfrac{a}{d}
\end{matrix}\right.
$$

考虑求解数与最值。找 $x_{\min}$ 即为解关于 $k$ 的不等式

$x_1+km \ge 1$由于式中的值均为整数，故

$k \ge \lceil \dfrac{1-x_1}{m} \rceil$由于 $y$ 随 $x$ 的增大而减小，故 $x_{\min}$ 所对应的 $y$ 就是 $y_{\max}$。接下来我们用 $y_{\max}$ 推 $y_{\min}$。推导一下，可以发现

$y_{\min}=y_{\max} \bmod n$于是 $x_{\max}$ 加上同样多的 $m$ 即可：

$x_{\max}=x_{\min} + \lfloor \dfrac{y_{\max}-1}{n} \times m \rfloor$解数就是 $[y_{\min},y_{\max}]$ 中解的个数，即

$\lfloor \dfrac{y_{\max}-1}{n} +1 \rfloor$至此本题在 $O(\log V)$ 内解决，$V$ 为值域。

在实现中，我们可以将 $a,b,c$ 都除去 $d$，这样可以简化代码。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}

long long a, b, c;

void _main() {
	cin >> a >> b >> c;
	long long d = __gcd(a, b);
	if (c % d) return cout << -1 << '\n', void();
	a /= d, b /= d, c /= d;
	long long x0, y0; exgcd(a, b, x0, y0);
	long long x1 = c * x0, y1 = c * y0;
	int xmin = (x1 > 0 && x1 % b != 0) ? x1 % b : x1 % b + b;
	int ymax = (c - xmin * a) / b;
	int ymin = (y1 > 0 && y1 % a != 0) ? y1 % a : y1 % a + a;
	int xmax = (c - ymin * b) / a;
	if (xmax <= 0) cout << xmin << ' ' << ymin << '\n';
	else cout << (ymax - ymin) / a + 1 << ' ' << xmin << ' ' << ymin << ' ' << xmax << ' ' << ymax << ' ' << '\n';
}
```

### P1516 青蛙的约会

设相遇时两只青蛙跳了 $t$ 次，则

$(n-m)t+kL=x-y$即求解 $t$ 的最小非负整数解。在不定方程 $ax+by=c$ 中，我们把 $n-m$ 视作 $a$，$L$ 视作 $b$，$x-y$ 视作 $c$，则应用上一题的方法来求解。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
long long x, y, m, n, L;

void _main() {
	cin >> x >> y >> m >> n >> L;
	long long a = n - m, b = L, c = x - y;
	if (a < 0) a = -a, c = -c;
	long long d = __gcd(a, b);
	if (c % d) return cout << "Impossible", void();
	a /= d, b /= d, c /= d;
	long long x0, y0; exgcd(a, b, x0, y0);
	long long x1 = c * x0;
	cout << ((x1 > 0 && x1 % b != 0) ? x1 % b : x1 % b + b);
}
```

### P12952 [GCJ Farewell Round #2] Intruder Outsmarting

我们考虑第 $i$ 个转轮，设调整它 $a$ 次，调整第 $w-i+1$ 个转轮 $b$ 次，则有同余方程：

$X_i+Da \equiv X_{w-i+1}+Db \pmod N$其中 $i \le \lfloor \dfrac{W}{2} \rfloor$。显然这个玩意没法 exCRT，于是我们把它变成不定方程：

$$
D(a-b) \equiv X_{w-i+1}-X_i \pmod N\\
D(a-b)-kN=X_{w-i+1}-X_i
$$

等号右边是已知量，将 $a-b$ 和 $k$ 看作未知数，先判无解，然后使用 exGCD 求出 $D(a-b)-kN=\gcd(D,N)$ 的解。我们需要求出 $a+b$ 的最小值。设 $p=a-b$，分类讨论：

- 若 $p \ge 0$，则 $a-b=p$，即 $a+b=2b+p$，当 $b=0$ 且 $p$ 为最小非负整数解时，$a+b$ 取得最小值。
- 若 $p<0$，则 $b-a=-p$，即 $a+b=2a-p$，当 $a=0$ 且 $p$ 为最大非负整数解的相反数时，$a-b$ 取得最小值。

至此，套用模板题的方法，本题解决。

```cpp
const int N = 2005;
#define int long long
void exgcd(int a, int b, int& x, int &y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
int w, n, d, x[N];

void _main(int kase) {
	cout << "Case #" << kase << ": ";
	cin >> w >> n >> d;
	for (int i = 1; i <= w; i++) cin >> x[i];
	int g = __gcd(n, d), n0 = n / g, res = 0;
	for (int i = 1; i <= w / 2; i++) {
		if ((x[i] - x[w - i + 1]) % g) return cout << "IMPOSSIBLE\n", void();
		int a, b; exgcd(d, n, a, b);
		int p = a * ((x[w - i + 1] - x[i]) / g % n0) % n0;
		if (p >= 0) p %= n0, res += min(p, n0 - p);
		else {
			int q = p + n0 * ceil(-1.0 * p / n0);
			res += min(q, n0 - q);
		}
	} cout << res << '\n';
}
```

### P4777 【模板】扩展中国剩余定理（EXCRT）

板子题。给个代码：

```cpp
const int N = 1e5 + 5;

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

int n;
long long a[N], m[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> m[i] >> a[i];
	cout << crt(n, a, m);
}
```

exCRT 很重要的一个用途是对于模数不是质数的情况，我们把模数分解质因数，然后分别计算对这些质因数取模的结果，最后用 exCRT 合并。

### P3868 [TJOI2009] 猜数字

对于 $(x-a_i) \mid  b_i$，可以变形为 $x-a_i \equiv 0 \pmod {b_i}$，然后再移项就是 $x \equiv a_i \pmod {b_i}$。于是解这个同余方程组即可。

细节上注意 $a_i$ 可能为负，需要对 $b_i$ 取模处理，另外这题会爆 `long long`，不过上面板子里已经开了 `__int128` 了。

```cpp
const int N = 15;
int n;
long long a[N], b[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	for (int i = 1; i <= n; i++) a[i] = (a[i] % b[i] + b[i]) % b[i];
	cout << crt(n, a, b);
}
```

### *P4774 [NOI2018] 屠龙勇士

首先把题目翻译过来，发现每条龙所对应的攻击力是确定的，记作 $b_i$。可以用一个 std::multiset 模拟攻击过程，现在问题是求

$$
\left\{\begin{matrix}
b_1x \equiv a_1 \pmod {p_1} \\
b_2x \equiv a_2 \pmod {p_2} \\
\cdots \\
b_nx \equiv a_n \pmod {p_n}
\end{matrix}\right.
$$

的最小正整数解 $x$。

对于 $bx \equiv a \pmod p$，拆开：

$bx-py=a$上 exGCD 求出一组特解 $x_0,y_0$，根据模板题的通解公式有

$x=x_0+k \dfrac{p}{\gcd(b,p)}$同模 $\dfrac{p}{\gcd(b,p)}$ 化为同余式

$x\equiv x_0 \pmod {\dfrac{p}{\gcd(b,p)}}$问题解决。之后使用普通的 exCRT 解出 $x$ 即可。

还有一些特判：

- 上面这种只适用于 $a_i \le p_i$ 的情况。对于 $a_i>p_i$ 的情况，根据数据点分治有 $p_i=1$，那么答案就是 $\max_{i=1}^{n} \lceil \dfrac{a_i}{b_i} \rceil$，需要特判。
- 当所有的 $p_i=a_i$ 时，$x=0$。但是这是错的，应该求出所有刀数取 $\operatorname{lcm}$。

```cpp
const int N = 1e5 + 5;
int n, m;
long long a[N], b[N], p[N], c[N], x, x0[N];
multiset<long long> st;

void _main() {
	st.clear();
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	bool f1 = false, f2 = true;
	for (int i = 1; i <= n; i++) {
		cin >> p[i];
		if (a[i] > p[i]) f1 = true;
		if (a[i] != p[i]) f2 = false;
	}
	for (int i = 1; i <= n; i++) cin >> c[i];
	for (int i = 1; i <= m; i++) cin >> x, st.emplace(x);
	for (int i = 1; i <= n; i++) {
		auto it = st.upper_bound(a[i]);
		if (it != st.begin()) it--;
		b[i] = *it, st.erase(it), st.emplace(c[i]);
		debug(b[i]);
	}
	if (f1) {
		long long res = 0;
		for (int i = 1; i <= n; i++) res = max(res, (a[i] + b[i] - 1) / b[i]);
		return cout << res << '\n', void();
	}
	if (f2) {
		long long res = 1;
		for (int i = 1; i <= n; i++) {
			long long v = p[i] / __gcd(p[i], b[i]);
			res = res / __gcd(res, v) * v;
		} return cout << res << '\n', void();
	}
	for (int i = 1; i <= n; i++) {
		if (b[i] % p[i] == 0) {
			if (p[i] == a[i]) x0[i] = 0, p[i] = 1;
			else return cout << -1 << '\n', void();
			continue;
		}
		long long g = __gcd(b[i], p[i]);
		if (a[i] % g) return cout << -1 << '\n', void();
		long long y0;
		exgcd(b[i], p[i], x0[i], y0);
		p[i] /= g, x0[i] = (x0[i] % p[i] + p[i]) % p[i];
		x0[i] = (int128) x0[i] * (a[i] / g) % p[i];
	}
	cout << crt(n, x0, p) << '\n';
}
```

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

## 7. 计数原理

常用的计数原理有加法原理、乘法原理、抽屉原理、容斥原理等。容斥在第 8 章单独介绍。

## 7.1 加法 & 乘法原理

- **加法原理**：有 $n$ 类方法，$a_i$ 为第 $i$ 类中方法的数目，则总方法数为 $\sum a_i$。
- **乘法原理**：有 $n$ 个步骤，$a_i$ 为第 $i$ 步中方法的数目，则总方法数为 $\prod a_i$。

这两者的区别是：加法分类，乘法分步。

加法原理有一个推论，即减法原理，就是求满足某种约束的方案数可以用总方案数减去不满足约束的方案数。这是最简单的容斥，是“正难则反”的体现。

## 7.2 数列

在加法 & 乘法原理推公式时，常会用到数列求和相关知识，故在此补充。

### 7.2.1 等差数列

等差数列是指满足递推式 $a_i-a_{i-1}=d$ 的数列，其中 $d$ 为常数，称作公差。由递推公式逐级写出：

$$
a_2-a_1=d\\
a_3-a_2=d\\
\cdots\\
a_{i}-a_{i-1}=d
$$

然后两边相加，得

$a_i=a_1+(i-1)d$此为等差数列通项公式。移项可得公差计算方法

$d=\dfrac{a_i-a_1}{i-1}$等差数列求和是 OI 数学题常用方法。下面我们对其作推导。设

$S=a_1+a_2+\cdots+a_n$将其复制一份倒序相加

$$
S=a_n+\cdots+a_2+a_1\\
2S=(a_1+a_n)+(a_2+a_{n-1})+\cdots+(a_n+a_1)=n(a_1+a_n)
$$

因而

$S=\dfrac{a_1+a_n}{2}=na_1+\dfrac{dn(n-1)}{2}$### 7.2.2 等比数列

等差数列是指满足递推式 $\dfrac{a_i}{a_{i-1}}=q$ 的数列，其中 $q$ 为常数，称作公比。类似等差数列的方法可得其递推公式

$a_i=a_1 \times q^{i-1}$仍然来推求和公式。设

$S=a_1+qa_1+q^2a_1 + \cdots + q^na_1$采用错位相减法

$$
qS=qa_1+q^2a_1+q^3a_1+\cdots+q^{n+1}a_1\\
qS-S=q^{n+1}a_1-a_1
$$

因此

$S=\dfrac{(q^{n+1}-1)a_1}{q-1}$#### 分治求和法

如果等比数列在模意义下求和，就需要求 $q-1$ 的逆元，而若 $q-1$ 无逆元，则无法套公式。这里介绍一种使用广义快速幂的分治求和方法，复杂度 $O(\log^2 n)$。

记 $sum(k,n)=1+k+k^2+\cdots+k^{n-1}$。若 $n$ 为偶数，将 $sum(k,n)$ 分为 $1+k+k^2+\cdots+k^{n/2-1}$ 与 $k^{n/2}+\cdots+k^{n-2}+k^{n-1}$ 两部分，则

$$
\begin{aligned}
sum(k,n)&=1+k+k^2+\cdots+k^n \\
&= 1+k+k^2+\cdots+k^{n/2-1}+k^{n/2}+\cdots+k^{n-2}+k^{n-1} \\
&= 1+k+k^2+\cdots+k^{n/2-1} + k^{n/2}(1+k+k^2+\cdots+k^{n/2-1}) \\
&= (k^{n/2}+1) (1+k+k^2+\cdots+k^{n/2-1}) \\
&= (k^{n/2}+1) \times sum(k,n/2)
\end{aligned}
$$

而若 $n$ 为奇数，则 $n-1$ 为偶数，$sum(k,n)=sum(k,n-1) + k^{n-1}$。递归出口 $sum(k,1)=1$。

```cpp
int sum(int k, int n) {
	if (n == 1) return 1;
	if (n & 1) return (sum(k, n - 1) + mpow(k, n - 1)) % p;
	return sum(k, n >> 1) * (mpow(k, n >> 1) + 1) % p;
}
```

自己造的板子：[U588919](https://www.luogu.com.cn/problem/U588919)。

### 7.2.3 幂数列

这里再补充一些幂数列求和的结论。幂数列是形如 $a_i=i^k$ 的数列，$k$ 为正整数。

**结论 1：**

$\sum_{i=1}^{n} i = 1+ 2+3+\cdots+n=\dfrac{n(n+1)}{2}$等差数列求和的最简单情况，相当常用。$\dfrac{n(n+1)}{2}$ 这个东西叫做三角形数。

**结论 2：**

$\sum_{i=1}^{n}i^2 = 1^2+2^2+3^2+\cdots+n^2=\dfrac{n(n+1)(2n+1)}{6}$用数学归纳法证。显然 $n=1$ 时是成立的。考虑 $n=k$ 时等式成立，只需证 $n=k+1$ 时等式也成立，即

$$
1^2+2^2+3^2+\cdots+k^2+(k+1)^2
=\dfrac{k(k+1)(2k+1)}{6}+\dfrac{6(k+1)^2}{6}
=\dfrac{(k+1)(k+3)(2k+3)}{6}
$$

因此结论正确。平方数列求和的这个结果 $\dfrac{n(n+1)(2n+1)}{6}$ 又叫做四角锥数。

**结论 3：**

$\sum_{i=1}^{n} i^3=1^3+2^3+3^3+\cdots+n^3=(1+2+3+\cdots+n)^2=[\dfrac{n(n+1)}{2}]^2$更高次幂的求和一般不常用。一般地，有

$\sum_{i=0}^{n-1} i^m=\dfrac{1}{m+1}\sum_{i=0}^{m} C_{m+1}^k B_k n^{m+1-k}$其中 $B_k$ 是[伯努利数](https://oi-wiki.org/math/combinatorics/bernoulli/)。这是一个讲的很好的[视频](https://www.bilibili.com/video/BV1GZRXYjEGK/)。

下文第 23 章使用 Lagrange 插值法，也可以在 $O(m)$ 的复杂度内计算上式。

### 7.2.4 斐波那契数列

定义 $fib_i=fib_{i-1}+fib_{i-2}$。

特别地，$fib_0=1,fib_1=1$。直接做可以 $O(n)$ 递推。下文第 22 章介绍了使用矩阵快速幂求其第 $n$ 项的 $O(\log n)$ 做法。

熟知地，有通项公式

$fib_n=\dfrac{1}{\sqrt{5}}( (\dfrac{1+\sqrt{5}}{2})^n-(\dfrac{1-\sqrt{5}}{2})^n)$对于斐波那契数列数列，还有几条结论：

1. 前缀和：

$\sum_{i=0}^n fib_n=fib_{n+2}-1\\$1. 平方和：
$\sum_{i=0}^n {fib_n}^2=fib_{n} \times fib_{n+1}$
3. 卡西尼恒等式：

$fib_{n+1}\times fib_{n-1}-{fib_n}^2=(-1)^n$斐波那契数列的增长速度是指数级的。

## 7.3 抽屉原理

抽屉原理，也称为鸽巢原理。定理如下：

将 $n$ 个物品划分为 $k$ 组，则至少有一组含有大于等于 $\lceil \dfrac{n}{k} \rceil$ 个物品。反证法易证。

## 7.4 例题

这部分还会介绍一些计数 DP 的思想。

### P3197 [HNOI2008] 越狱

由减法原理，可以用总数目减去不会越狱的数目。

本题中，$n$ 个人都有 $m$ 种选择，由乘法原理可得总数目为 $m^n$。接着我们考虑合法方案，第一个位置能放 $m$ 个，而第二个位置在第一位没有选的 $m-1$ 个中选一个，由此递推，可得方案数为 $m(m-1)^{n-1}$。所以所求为 $m^n-m(m-1)^{n-1}$。

### [模拟赛] 鲁的石板

> 上面那题的环上版本。有一个大小为 $n$ 的环，$m$ 种颜色，求相邻点不同色的染色方案数对 $10^9+7$ 取模的结果。
>
> $T$ 次询问。$T \le 10^5$，$n \le 10^9$，$m \le 50$。

赛时整了一个抽象的高维容斥 + 等比数列求和 + 分类讨论做法过了，喜提 AK。下面来讲一种优雅的解法。

序列上的版本答案为 $m(m-1)^{n-1}$。记 $f_i$ 为环的大小为 $i$ 时的方案数，则不合法的方案产生于首尾颜色相同的情况。我们可以把首尾直接合并为一个点，此时这个环相邻颜色均不相同，方案数为 $f_{n-1}$。当首尾颜色不同时，方案数就是 $f_n$。由加法原理得

$f_n+f_{n-1}=m(m-1)^{n-1}$移项后可以做到 $O(n)$ 递推求解。作一些代数变形：

$$
\begin{aligned}
f_n+f_{n-1}&=m(m-1)^{n-1}\\
f_n+f_{n-1}&=(m-1)^{n}+(m-1)^{n-1}\\
f_n-(m-1)^n&=(-1)[f_{n-1}-(m-1)^{n-1}]
\end{aligned}
$$

因此 $f_n-(m-1)^n$ 是第二项为 $m-1$，公比为 $-1$ 的等比数列。由等比数列通项公式得

$f_n-(m-1)^n=(-1)^n({m-1})$移项

$f_n=(-1)^n(m-1)+(m-1)^n$只需要 $O(\log n)$ 求解了。注意特判 $n=1$。

### P8557 炼金术（Alchemy）

对于第 $i$ 个金属，一共有 $2^k$ 种情况，使用减法原理减去没有炼出来的 $1$ 种情况，为 $2^k-1$ 种。这是分步的，乘法原理合并答案，答案为 $(2^k-1)^n$。

### P6075 [JSOI2015] 子集选取

神秘结论题。从特殊到一般，讨论 $n=1$。容易证明此时存在一条上升路径将整个三角形分成全 $\varnothing$ 和全 $\{1\}$ 的两部分。因为每一步有向上和向右两种选择，走 $k$ 步答案为 $2^k$。

类似地，对于一个一般的 $n$，根据题目中所给性质可以发现一共有 $n$ 条路径。因此答案为 $(2^k)^n=2^{kn}$。所以就是个快速幂板子。

### *CF1793D Moscow Gorillas

设排列 $a$ 中 $i$ 出现的位置为 $p_i$，排列 $b$ 中 $i$ 出现的位置为 $q_i$。

考虑枚举 $\operatorname{mex}$，设其为 $m$，只要求出有多少 $l,r$ 使得两个排列的子区间 $\operatorname{mex}$ 为 $m$，则合法的 $[l,r]$ 需要满足 $1,2,3,\cdots,m-1$ 中的数恰好出现一次。设 $s=p_m,t=q_m$，不妨令 $s \le t$。

首先特判 $m=1$。此时区间不能跨过 $s,t$，否则 $\operatorname{mex}$ 一定大于 $1$。在 $[1,s),(s,t),(t,n]$ 中可以选择任意端点，方案数为 $\sum \dfrac{h(h-1)}{2}$，其中 $h$ 是区间长度。

用两个指针维护 $l,r$ 当前最小的 $s$ 和最大的 $t$。左端点必须在 $[1,l]$ 中，右端点必须在 $[r,n]$ 中，才能满足 $1,2,3,\cdots,m-1$ 中的数恰好出现一次这条性质。同时根据定义，合法的区间不能包含 $m$。

接下来分类讨论。

1. 当 $s \in [l,r]$ 或 $t \in [l,r]$ 时，合法区间只能包含 $m$，矛盾。
2. 当 $s,t <l$ 时，在 $[1,l]$ 中存在合法区间，贡献为 $(n-r+1)(l-t)$。因为左端点取在 $(t,l]$ 中，右端点取在 $[r,n]$ 中。
3. 当 $s,t \ge r$ 时，同理可得贡献为 $l(s-r)$。
4. 当 $s<l$ 且 $r<t$ 时，左端点取 $(s,l]$ 中，右端点取 $[r,t)$ 中，贡献为 $(l-s)(t-r)$。

根据加法原理合并答案。复杂度 $O(n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], b[N], p[N], q[N];
long long calc(int len) {return 1LL * len * (len - 1) / 2;}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], p[a[i]] = i;
	for (int i = 1; i <= n; i++) cin >> b[i], q[b[i]] = i;
	int s = p[1], t = q[1];
	if (s > t) swap(s, t);
	long long res = 0;
	if (1 <= s - 1) res += calc(s);
	if (t + 1 <= n) res += calc(n - t + 1);
	if (s < t) res += calc(t - s);

	int l = s, r = t;
	for (int m = 2; m <= n; m++) {
		s = p[m], t = q[m];
		if (s > t) swap(s, t);
		if ((l <= s && s <= r) || (l <= t && t <= r)) {
			l = min(l, s), r = max(r, t);
			continue;
		}
		if (s < l && t < l) res += 1LL * (n - r + 1) * (l - t);
		if (s > r && t > r) res += 1LL * l * (s - r);
		if (s < l && r < t) res += 1LL * (l - s) * (t - r);
		l = min(l, s), r = max(r, t);
	} cout << res;
}
```

### P8356 「WHOI-1」数列计数

简单计数 DP。设 $dp_{i,j}$ 表示用了 $i$ 次 $+x$，$j$ 次 $+y$ 的数列方案数。加法原理得到转移

$dp_{i,j}=dp_{i-1,j}+dp_{i,j-1}$只需当 $p \mid (ix+jy)$ 时将 $dp_{i,j} \gets 0$ 即可满足约束。答案就是 $\sum_{i+j=n} dp_{i,j}$。

注意到空间炸了，滚动数组优化即可。复杂度 $O(n^2)$。需要特判 $x=y$。

```cpp
const int N = 1e4 + 5;
int n, p, x, y;
mint dp[2][N];

void _main() {
	cin >> n >> p >> x >> y;
	if (x == y) {
		for (int i = 1; i <= n; i++) {
			if (1LL * i * x % p == 0) return cout << 0 << '\n', void();
		} return cout << 1 << '\n', void();
	}
	dp[0][0] = 1;
	mint res = 0;
	for (int i = 0, st = 0; i <= n; i++, st ^= 1) {
		for (int j = 0; i + j <= n; j++) {
			if (i == 0 && j == 0) continue;
			if ((1LL * i * x + 1LL * j * y) % p) dp[st][j] = (i != 0 ? dp[st ^ 1][j] : 0) + (j != 0 ? dp[st][j - 1] : 0);
 			else dp[st][j] = 0;
			if (i + j == n) res += dp[st][j];
		}
	} cout << res << '\n';
}
```

### OpenJudge 9285 盒子与小球之三

推不出来公式，考虑计数 DP。设 $dp_{i,j}$ 表示前 $i$ 个盒子放 $j$ 个球的方案数，由加法原理

$dp_{i,j}=\sum_{x=0}^k dp_{i-1,j-x}$是一个类似背包的东西，复杂度 $O(nmk)$。

注意到 $dp_{i,j}$ 是 $dp_{i-1}$ 上一段连续的和，可以前缀和优化 DP。更仔细的观察可以发现，这段连续和的长度不变，直接维护一个滑动窗口即可。

```cpp
const int N = 5005;
int n, m, k;
mint dp[N][N];

void _main() {
	cin >> n >> m >> k;
	for (int i = 0; i <= m; i++) dp[i][0] = 1;
	for (int i = 1; i <= m; i++) {
		mint sum = i;
		for (int j = 1; j <= n; j++) {
			dp[i][j] = sum, sum += dp[i - 1][j + 1];
			if (j >= k) sum -= dp[i - 1][j - k];
		}
	} cout << dp[m][n];
}
```

### P6146 [USACO20FEB] Help Yourself G

将所有线段按左端点排序。设 $dp_i$ 表示前 $i$ 条线段的子集复杂度之和。

考虑转移，计数 DP 非常常见的套路是从插入角度考虑第 $i$ 条的贡献。显然不选的贡献为 $dp_{i-1}$，只要考虑加入第 $i$ 条的贡献。

由于我们按左端点排好了序，原复杂度单调不降。加入这条线段，会使得某些子集中所有线段与之不交，从而复杂度增加 $1$。设 $[1,i)$ 中有 $x$ 条线段不与第 $i$ 条相交，选择这 $x$ 条的一个子集会使得复杂度加一。根据加法原理：

$dp_i=dp_{i-1}+(dp_{i-1}+2^x)=2 \times dp_{i-1}+2^{x}$对值域作前缀和，预处理一下每个位置的 $x$ 即可。复杂度可以做到 $O(n)$。

```cpp
const int N = 1e5 + 5;
int n, x[N << 1];
struct node {
	int l, r;
} a[N];
mint dp[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i].l >> a[i].r;
	sort(a + 1, a + n + 1, [](const node& a, const node& b) -> bool {
		return a.l < b.l;
	});
	for (int i = 1; i <= n; i++) x[a[i].r]++;
	for (int i = 1; i <= 2 * n; i++) x[i] += x[i - 1];
	for (int i = 1; i <= n; i++) dp[i] = dp[i - 1] * 2 + mint(2).pow(x[a[i].l - 1]);
	cout << dp[n];
}
```

### *P5664 [CSP-S2019] Emiya 家今天的饭

Emiya 的限制是简单的，最终合法数减去 $1$ 即可。加入 Rin 的限制，在每种方法中只能选一个菜，根据乘法原理可得答案

$\prod_{i=1}^n (1+\sum_{j=1}^m a_{i,j})$加入 Yazid 的限制，考虑减法原理，用上面这个减去不满足 Yazid 限制的方案数。设计一个 DP，令 $dp_{i,x,y}$ 表示考虑前 $i$ 道菜，已经选出了 $x$ 个菜，其中有 $y$ 个菜使用了该食材的不合法方案数。分类讨论转移：

1. 不选当前食材：答案为 $dp_{i-1,x,y}$。
2. 选当前食材：若 $x=y$，则当前已选，从 $dp_{i-1,x-1,y-1}$ 转移；若 $x \ne y$，从 $dp_{i-1,x-1,y}$ 转移。

复杂度 $O(n^3m^2)$，无法通过。

观察到 $c > \lfloor \dfrac{k}{2} \rfloor$ 的限制实际上类似一个**绝对众数**的约束。注意到我们只记录 $x-y$ 也能进行转移。将状态改为 $dp_{i,j}$，其中 $j=x-y$。

同时可以发现，如果枚举不合法的食材，可以直接按不选、$j=x$，$j \ne x$ 分类讨论。最终得到转移方程

$dp_{i,j}=dp_{i-1,j}+dp_{i-1,j-1} \times a_{i,x}+dp_{i-1,j+1} \sum_{k \ne x} a_{i,k}$预处理一下即可，复杂度 $O(n^2m)$。

注意 DP 状态的第二维 $j \in [-n,n]$，需要使用数组漂移的 trick。

```cpp
const int N = 105, M = 2005;
int n, m;
mint a[N][M], sum[N], f[N][N << 1];

mint solve(int x) {
	f[0][n] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = -n; j <= n; j++) {
			f[i][j + n] = 0;
			f[i][j + n] += f[i - 1][j - 1 + n] * a[i][x];
			f[i][j + n] += f[i - 1][j + 1 + n] * (sum[i] - a[i][x]);
			f[i][j + n] += f[i - 1][j + n];
		}
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) res += f[n][i + n];
	return res;
}

void _main() {
	cin >> n >> m;
	mint res = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) cin >> a[i][j], sum[i] += a[i][j];
		res *= sum[i] + 1;
	}
	for (int i = 1; i <= m; i++) res -= solve(i);
	cout << res - 1;
}
```

### AT_abc279_g [ABC279G] At Most 2 Colors

计数 DP。设 $dp_i$ 表示 $i$ 个格子时的答案，分类讨论：

1. 若 $[i-k+1,i)$ 中仅有一种颜色，则 $i$ 填任何颜色均可，答案为 $dp_{\max(1,i-k+1)}\times c$。
2. 若 $[i-k+1,i)$ 中有两种颜色，则 $i$ 只能从这两种颜色中选择。考虑减法原理，用前 $i-1$个格子的总合法方案数减去前 $k-1$ 个只染一种颜色的方案数，得到 $(dp_{i-1}-dp_{\max(1,i-k+1)}) \times 2$。

由加法原理得到递推式

$dp_{i}=dp_{i-1} \times 2+dp_{\max(1,i-k+1)} \times (c-2)$复杂度 $O(n)$。

```cpp
const int N = 1e6 + 5;
int n, k, c;
mint dp[N];

void _main() {
	cin >> n >> k >> c;
	dp[1] = c;
	for (int i = 2; i <= n; i++) dp[i] = dp[i - 1] * 2 + dp[max(1, i - k + 1)] * (c - 2);
	cout << dp[n];
}
```

### *[模拟赛] 日程

> 有一个长度为 $k$ 的 01 序列，有 $n$ 条限制形如 $[l,r]$ 中至少有一个 $0$，$m$ 条限制形如 $[l,r]$ 中至少有一个 $1$，求合法的 01 序列数目对 $10^9+7$ 取模的结果。
>
> $n,m\le 10^5$，$k \le 10^9$。

赛时无人有分的含金量。

考虑 $k \le 10^5$ 怎么做。设 $dp_{0/1,i}$ 表示第 $i$ 个数填 0/1 的方案数，枚举上一个 0/1 的位置 $j$ 判断是否满足性质即可，复杂度 $O(k^2)$。注意到 $j$ 对 $i$ 产生影响的位置是单调的，可以用一个指针维护，复杂度 $O(k)$。

对于 $k \le 10^9$，将 $l,r$ 离散化，则我们现在对连续段做计数 DP。设 $dp_{0/1,i}$ 表示第 $i$ 段全填 0/1 的方案数，仍然可以维护一个 $j$ 来转移。注意第 $i$ 可能 0/1 都有，我们用一个变量 $v$ 来维护。转移用乘法原理和加法原理推一推即可。复杂度 $O(n \log n)$。

```cpp
const int N = 1e5 + 5;
int k, n, m, x[N], y[N];
struct node {
	int l, r;
} a[N], b[N];
discrete_map<int, N << 2> mp;
mint f[2][N];

void _main() {
	cin >> k >> n >> m;
	for (int i = 1; i <= n; i++) {
		cin >> a[i].l >> a[i].r, mp.add(a[i].r);
		if (a[i].l != 1) mp.add(a[i].l - 1);
	}
	for (int i = 1; i <= m; i++) {
		cin >> b[i].l >> b[i].r, mp.add(b[i].r);
		if (b[i].l != 1) mp.add(b[i].l - 1);
	}
	mp.add(1), mp.add(k), mp();
	for (int i = 1; i <= n; i++) x[mp[a[i].r]] = max(x[mp[a[i].r]], mp[a[i].l]);
	for (int i = 1; i <= m; i++) y[mp[b[i].r]] = max(y[mp[b[i].r]], mp[b[i].l]);
	f[0][0] = (x[1] == 0), f[1][0] = (y[1] == 0);
	mint s0 = f[0][0], s1 = f[1][0], v = 0;
	int a = 0, b = 0;
	for (int i = 1; i < mp.width; i++) {
		int len = mp.value(i + 1) - mp.value(i);
		mint p = mint(2).pow(len) - 2;
		if (i >= x[i + 1]) f[0][i] = s1 + v;
		if (i >= y[i + 1]) f[1][i] = s0 + v;
		if (len > 1) v += s0 + s1, v *= p;
		else v = 0;
		s0 += f[0][i], s1 += f[1][i];
		for (; a < x[i + 1]; a++) s0 -= f[0][a];
		for (; b < y[i + 1]; b++) s1 -= f[1][b];
	} cout << v + s0 + s1;
}
```

## 8. 容斥原理

容斥原理是加法 & 减法原理的推广。

## 8.1 引入

用一个例题引入：假设班里有 $a$ 个学生喜欢语文，$b$ 个学生喜欢数学，$c$ 个数学喜欢英语，则班里至少喜欢一门学科的有多少个学生？

显然你不能简单地用 $a+b+c$ 计算，因为可以有学生同时喜欢两门甚至三门学科。我们使用集合论语言，设喜欢三门学科的学生集合为 $A,B,C$，则所求为 $|A \cup B \cup C|$。因为 $|A|+|B|+|C|=a+b+c$ 这样会把同时喜欢两个学科的人算重，需要减去 $|A \cap B|+|A \cap C|+ |B \cap C|$。然而这样又会把同时喜欢三个学科的人减去，所以又要加上 $|A \cap B \cap C|$。于是答案为

$|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$这就是三维容斥。

## 8.2 一般形式

更一般地，有

$|\cup_{i=1}^{n} S_i|=\sum_{m=1}^n (-1)^{m-1} \sum_{a_i<a_{i+1}} |\cap _{i=1}^m S_{a_i}|$可以用减法原理结合数学归纳法证明。

用到容斥的地方其实很多，减法原理就是最简单的容斥，高维前缀和也有容斥做法，下文所说的二项式反演、Stirling 反演本质就是有系数的容斥。

需要注意，某些计数 DP 的题也会用到容斥思想，此时我们设计两个 DP 数组 $f_i,g_i$，分别表示总方案数与合法方案数，转移形如 $g_i =\sum_{j} (f_j-h(j))$，其中 $h(j)$ 表示 $j$ 处不合法的方案数。容斥原理的本质就是像这样的多次减法原理。

## *8.3 一般化

对于两个集合函数 $f(S),g(S)$，我们有

$f(S)=\sum_{T \subseteq S} g(T) \Leftrightarrow g(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} f(T)$这个过程又叫做**子集反演**。上面给出的是子集反演的形式一，取补集可以得到子集反演形式二：

$f(S)=\sum_{S \subseteq T} g(T) \Leftrightarrow g(S)=\sum_{S \subseteq T} (-1) ^{|T|-|S|} f(T)$下文第 11 章的二项式反演，就可以看作子集反演在元素都相等时的特例。

## 8.4 例题

### CF1207D Number Of Permutations

考察好序列的性质，发现不太好计数，于是我们用容斥把它拆开，所求变为：总方案数 $-$ 第一维 $a_i$ 有序的方案数 $-$ 第二维 $b_i$ 有序的方案数 $+$ 两维 $a_i,b_i$ 同时有序的方案数。

显然总方案数是 $n!$。对于单维有序的情况，$a_i,b_i$ 同理，这里只讨论 $a_i$。先完成排序后每一块相同的数可以任意交换，于是我们开个桶来计数，由乘法原理可知答案是 $\prod_{i=1}^{n} cnt_i!$。两维同时有序，和上述类似，我们用桶 $p_{i,j}$ 记录数对 $(i,j)$ 的出现次数，所求为 $\prod_{i=1}^{n} p_{a_i,b_i}$。于是我们预处理阶乘即可。

但是要注意两维同时有序可能无解，需要排个序特判一波。

> 以及：CF 有 hack 机制能用 unordered_map 吗？

```cpp
const int N = 3e5 + 5;
using p32 = pair<int, int>;

mint fac[N];
int n, a, b;
p32 h[N];
map<int, int> cnt1, cnt2;
map<p32, int> p;

void _main() {
	cin >> n;
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	for (int i = 1; i <= n; i++) {
		cin >> a >> b, h[i] = make_pair(a, b);
		cnt1[a]++, cnt2[b]++, p[h[i]]++;
	}
	sort(h + 1, h + n + 1);
	mint c0 = fac[n], c1 = 1, c2 = 1, c12 = 1;
	for (int i = 2; i <= n; i++) {
		if (h[i].second < h[i - 1].second) c12 = 0;
	}
	for (const auto& i : cnt1) c1 *= fac[i.second];
	for (const auto& i : cnt2) c2 *= fac[i.second];
	for (const auto& i : p) c12 *= fac[i.second];
	cout << c0 - c1 - c2 + c12;
}
```

### P1447 [NOI2010] 能量采集

组合数学的原理也可以解决数论问题。在前面的欧拉函数部分，我们知道这样的问题答案是

$\sum_{i=1}^{n} \sum_{j=1}^{m} (2\times\gcd(i, j)-1)=2\sum_{i=1}^{n} \sum_{j=1}^{m} \gcd(i,j)-nm$可以发现 $\gcd(i,j)$ 的值只有 $n$ 种，不妨考虑 $gcd(i,j)=k$ 的数目，设其数目为 $f(k)$。我们可以考虑求以 $k$ 为公约数的数对数目，再减去以 $k$ 的倍数为公约数的数对数目。进一步推导，以 $k$  的倍数为公约数的数对个数等于所有以 $k$ 的倍数为最大公约数的数对个数之和。于是有

$f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor -\sum_{i=2}^{ik \le \min(n,m)} f(ik)$我们发现 $2k > \min(n,m)$ 时 $f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor$，于是倒着算就行了，是调和型枚举，复杂度 $O(n \log n)$。于是 GCD SUM 问题就多了一种容斥做法。

```cpp
const int N = 1e5 + 5;
long long f[N];
int n, m;

void _main() {
	cin >> n >> m;
	for (int k = n; k >= 1; k--) {
		f[k] = 1LL * (n / k) * (m / k);
		for (int i = 2; i * k <= min(n, m); i++) f[k] -= f[i * k];
	}
	long long res = 0;
	for (int i = 1; i <= n; i++) res += f[i] * i;
	cout << res * 2 - 1LL * n * m;
}
```

### AT_abc162_e [ABC162E] Sum of gcd of Tuples (Hard)

笔者数论训练赛の T5。和上面题的套路一样，我们发现，$\gcd a_i=k$ 时当且仅当 $a_1,a_2, \cdots,a_n$ 均为 $k$ 的倍数，且这个倍数是互质的。考虑容斥 + DP，令 $dp_x$ 表示 $[1,x]$ 内选出 $n$ 个互质数的方法数目。考虑用减法原理，总数目减去不互质的方案，枚举公约数 $i$，则根据约数性质可得

$dp_x=x^n-\sum_{i=2}^{x} dp_{\lfloor \frac{x}{i} \rfloor}$赛时写的记搜。可以发现这个东西就是高维容斥。

```cpp
int n, k;
mint dp[N];
mint solve(int x) {
	if (dp[x] != 0) return dp[x];
	if (x == 1) return dp[x] = 1;
	mint res = mint(x).pow(n);
	for (int i = 2; i <= x; i++) {
		res -= solve(x / i);
	} return dp[x] = res;
}

void _main() {
	cin >> n >> k;
	mint res = 0;
	for (int i = 1; i <= k; i++) res += solve(k / i) * i;
	cout << res;
}
```

### AT_abc366_d [ABC366D] Cuboid Sum Query

三维前缀和板子题，容斥原理的另一种应用。我们先来推三维前缀和怎么算。设 $pre_{i,j,k}$ 表示以 $(i,j,k)$ 为右下角的立方体数字之和，则它显然由 $a_{i,j,k}$ 贡献。同时考虑去掉一行 / 一列 / 一柱，加上 $pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}$。这样我们会把同时退掉两维的前缀和算重，于是减去 $pre_{i-1,j-1,k}+pre_{i-1,j,k-1}+pre_{i,j-1,k-1}$。这样又把退掉三维的前缀和减多了，所以加上 $pre_{i-1,j-1,k-1}$。总的转移为

$pre_{i,j,k}=a_{i,j,k}+pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}-pre_{i-1,j-1,k}-pre_{i-1,j,k-1}-pre_{i,j-1,k-1}+pre_{i-1,j-1,k-1}$接着我们考虑单次询问以 $(x_1,y_1,z_1)$ 为左上角，$(x_2,y_2,z_2)$ 为右下角的立方体点权之和。同理可得答案为

$pre_{x_2,y_2,z_2}-pre_{x_1-1,y_2,z_2}-pre_{x_2,y_1-1,z_2}-pre_{x_2,y_2,z_1-1}+pre_{x_1-1,y_1-1,z_2}+pre_{x_1-1,y_2,z_1-1}+pre_{x_2,y_1-1,z_1-1}-pre_{x_1-1,y_1-1,z_1-1}$这两个式子本质是三维容斥原理 $|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$。

于是我们在预处理 $O(n^3)$，查询 $O(1)$ 下解决了该问题。

```cpp
const int N = 105;
int n, q, a[N][N][N], pre[N][N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) cin >> a[i][j][k];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) {
				pre[i][j][k] = a[i][j][k]
				+ pre[i][j][k - 1] + pre[i][j - 1][k] + pre[i - 1][j][k]
				- pre[i][j - 1][k - 1] - pre[i - 1][j][k - 1] - pre[i - 1][j - 1][k]
				+ pre[i - 1][j - 1][k - 1];
			}
		}
	}
	cin >> q;
	while (q--) {
		int x1, x2, y1, y2, z1, z2;
		cin >> x1 >> x2 >> y1 >> y2 >> z1 >> z2;
		cout << (pre[x2][y2][z2]
		- pre[x1 - 1][y2][z2] - pre[x2][y1 - 1][z2] - pre[x2][y2][z1 - 1]
		+ pre[x1 - 1][y1 - 1][z2] + pre[x1 - 1][y2][z1 - 1] + pre[x2][y1 - 1][z1 - 1]
		- pre[x1 - 1][y1 - 1][z1 - 1]) << '\n';
	}
}
```

### P8315 [COCI 2021/2022 #4] Šarenlist

集合容斥板子。

注意到 $m \le 15$，考虑 $O(2^m)$ 枚举一些限制并钦定其不满足。用一个 DFS 搜出路径，然后化边为点，并查集维护一下连通块数目 $c$，贡献就是 $k^c$。容斥系数为 $(-1)^{\operatorname{popcount}(S)}$。复杂度 $O(nm2^m \log n)$。

```cpp
const int N = 65;
int n, m, k, u, v;
pair<int, int> a[N];
int tot = 1, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int fa[N], sz[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
void unite(int x, int y) {fa[find(x)] = find(y);}

vector<int> p[N];
bool dfs(int u, int fa, int to, vector<int>& vec) {
	if (u == to) return true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		vec.emplace_back(j >> 1);
		if (dfs(v, u, to, vec)) return true;
		vec.pop_back();
	} return false;
}

void _main() {
	cin >> n >> m >> k;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	for (int i = 1; i <= m; i++) {
		cin >> a[i], dfs(a[i].first, -1, a[i].second, p[i]);
	}
	mint res = 0;
	for (int s = 0; s < (1 << m); s++) {
		iota(fa + 1, fa + n + 1, 1);
		for (int i = 1; i <= m; i++) {
			if (!(s >> (i - 1) & 1)) continue;
			for (int j = 1; j < (int) p[i].size(); j++) unite(p[i][j - 1], p[i][j]);
		}
		int part = 0;
		for (int i = 1; i < n; i++) part += (i == find(i));
		if (popcount(s) & 1) res -= mint(k).pow(part);
		else res += mint(k).pow(part);
	} cout << res;
}
```

### P1450 [HAOI2008] 硬币购物

先考虑跑一个完全背包，令 $dp_{i,j}$ 表示前 $i$ 种硬币支付 $j$ 元的方案数，有

$dp_{i,j}=dp_{i-1,j}+dp_{i,j-x_i}$滚动数组优化一下，答案为 $dp_n$。这样会算多，于是我们把第 $1,2,3,4$ 种硬币超限的情况分别减掉。又减多了，加回来……可以看到是一个容斥的过程。写出四维容斥原理：

$$
|A\cup B \cup C \cup D|=
|A|+|B|+|C|+|D|
-|A\cap B|-|A\cap C|-|A\cap D|-|B\cap C|-|B \cap D|-|C \cap D|
+|A\cap B\cap C|+|A\cap B\cap D|+|A\cap C\cap D|+|B\cap C \cap D|
-|A\cap B\cap C \cap D|
$$

最后再用一个总的减法原理即可。

```cpp
#define int long long
const int N = 1e5 + 5;
int a, b, c, d, s, c1, c2, c3, c4, q, dp[N];
void work(int x) {
	for (int i = x; i < N; i++) dp[i] += dp[i - x];
}
int f(int x) {return x < 0 ? 0 : dp[x];}

void _main() {
	cin >> c1 >> c2 >> c3 >> c4;
	dp[0] = 1;
	work(c1), work(c2), work(c3), work(c4);
	for (cin >> q; q--; ) {
		cin >> a >> b >> c >> d >> s;
		a = (a + 1) * c1, b = (b + 1) * c2, c = (c + 1) * c3, d = (d + 1) * c4;
		cout << f(s) - f(s - a) - f(s - b) - f(s - c) - f(s - d)
			+ f(s - a - b) + f(s - a - c) + f(s - a - d) + f(s - b - c) + f(s - b - d) + f(s - c - d)
			- f(s - a - b - c) - f(s - a - b - d) - f(s - a - c - d) - f(s - b - c - d)
			+ f(s - a - b - c - d) << '\n';
	}
}
```

### *P6651 「SWTR-5」Chain

一步一步考虑，先想无修改怎么做，我们在拓扑序上做 DP，由加法原理

$f_{i} \gets f_{i}+f_j$进一步地，由于 $n\le 2\times 10^3$，我们可以利用拓扑排序，在 $O(n^2)$ 时间内预处理从 $u$ 到 $v$ 的链数，则

$dp_{k,v} \gets dp_{k,v}+dp_{k,u}$类似 Floyd 那样，对于有向边 $(u,v)$，枚举中继点 $k \in [1,n]$，由加法原理合并。记入度为 $ideg_i$，出度为 $odeg_i$，则总链数

$tot=\sum_{ideg_i=0} \sum_{odeg_j=0} dp_{i,j}$因为一条链的起终点一定满足上述条件。接着我们考虑 $k=1$ 的做法，套路地，记 $f_i$ 为链起点到点 $i$ 的方案数，然后建反图，记 $g_i$ 是反图上的 $f_i$，发现 $g_i$ 等价于原图中点 $i$ 到链终点的方案数。由 $dp_{i,j}$ 的定义易得转移：

$$
f_i = \sum_{ideg_j=0} dp_{j,i}\\
g_i = \sum_{odeg_j=0} dp_{i,j}
$$

那么 $k=1$ 的情况就可以用 $tot-f_ig_i$ 回答。接着我们想 $k=2$，不妨设两点 $u,v$ 中 $u$ 的拓扑序小于 $v$，分类讨论：

- 若 $u,v$ 不在同一条链上，直接用 $tot-f_ug_u-f_vg_v$ 回答；
- 若 $u,v$ 可以在同一条链上，那么 $u$ 到终端的路径包含了 $v$。考虑容斥把重复的加回来，这里的重复是 $f_ug_v dp_{u,v}$，答案为 $tot-f_ug_u-f_vg_v+f_ug_v dp_{u,v}=tot-f_ug_u-g_v(f_v-f_udp_{u,v})$。

接着我们扩展到 $k \le 15$。我们先按拓扑序排序，对于每个点处理要容斥掉的数 $h_i$，则

$h_i=f_i-\sum h_j dp_{j,i}$其中 $j$ 的拓扑序在 $i$ 之前。于是答案为

$tot-\sum h_ig_i$至此，我们在预处理 $O(n^2+m)$，单次查询 $O(k^2)$ 的复杂度下解决了此问题。

```cpp
const int N = 2e3 + 5, M = 2e4 + 5;

int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[M];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, m, u, v, q, len, ideg[N], odeg[N];

int cnt, bfn[N];
mint dp[N][N], f[N], g[N], h[20];
void topo() {
	queue<int> q;
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) q.emplace(i);
		dp[i][i] = 1;
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		bfn[u] = ++cnt;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			for (int k = 1; k <= n; k++) dp[k][v] += dp[k][u];
			if (--ideg[v] == 0) q.emplace(v);
		}
	}
}

vector<int> st, ed;
void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		add_edge(u, v);
		odeg[u]++, ideg[v]++;
	}
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) st.emplace_back(i);
		if (odeg[i] == 0) ed.emplace_back(i);
	} topo();
	mint tot = 0;
	for (int i : st) {
		for (int j : ed) tot += dp[i][j];
	}
	for (int i = 1; i <= n; i++) {
		for (int j : st) f[i] += dp[j][i];
		for (int j : ed) g[i] += dp[i][j];
	}
	for (cin >> q; q--; ) {
		fill(h, h + len, 0);
		cin >> len;
		vector<int> c;
		for (int i = 0; i < len; i++) cin >> u, c.emplace_back(u);
		sort(c.begin(), c.end(), [](int x, int y) -> bool {
			return bfn[x] < bfn[y];
		});
		for (int i = 0; i < len; i++) {
			h[i] = f[c[i]];
			for (int j = 0; j < i; j++) h[i] -= dp[c[j]][c[i]] * h[j];
		}
		mint res = 0;
		for (int i = 0; i < len; i++) res += h[i] * g[c[i]];
		cout << tot - res << '\n';
	}
}
```

### *P5933 [清华集训 2012] 串珠子

绝世好题。前置知识：18.2 子集枚举。下面是本人模拟赛上的思考过程：

注意到 $n \le 16$，一眼状压 DP。如果复杂度是 $O(n2^n)$ 完全可以开到 $20$，所以这题复杂度是 $O(n^22^n)$ 或者 $O(3^n)$。如果考虑 $O(3^n)$，思考子集枚举，分成两个连通块合并答案。发现会算重。

正难则反，记 $g_S$ 表示 $S$ 这个点集的总方案数，显然 $g_S=\prod _{u,v \in S} (a_{u,v}+1)$，可以 $O(n^2 2^n)$ 预处理。考虑计数 DP 配合高维容斥，设 $f_S$ 表示 $S$ 这个点集的答案，用减法原理算出 $f_S$ 即可。枚举 $T \subseteq S$，表示从 $S$ 中钦定一个连通块，其余点任意，则

$f_S =g_S - \sum_{T \subseteq S} f_T \times  g_{S \setminus T}$写完发现减多了，样例得到了宇宙终极答案 $42$。考虑手玩样例，$|S| \le 1$ 的集合显然，直接看 $|S| \ge 2$ 的集合：

- $S=\{1,2\}$，则 $f_S=2,g_S=3$。
- $S=\{1,3\}$，则 $f_S=3,g_S=4$。
- $S=\{2,3\}$，则 $f_S=4,g_S=5$。
- $S=\{1,2,3\}$，列出可能的 $T$ 和 $S \setminus T$：

| $T$ | $S \setminus T$ | $f_T$ | $g_{S \setminus T}$ |
| --- | --- | --- | --- |
| $\{1\}$ | $\{2,3\}$ | $1$ | $5$ |
| $\{2\}$ | $\{1,3\}$ | $1$ | $4$ |
| $\{3\}$ | $\{1,2\}$ | $1$ | $3$ |
| $\{2,3\}$ | $\{1\}$ | $4$ | $2$ |
| $\{1,3\}$ | $\{2\}$ | $3$ | $2$ |
| $\{1,2\}$ | $\{3\}$ | $2$ | $2$ |

而 $g_S=3 \times 4 \times 5=60$，按这种方法减去就是 $42$。

考虑为什么会减多。发现 $(T, S \setminus T)$ 会被重复计算两次。并且贡献不同，没有办法用简单的 $\times \dfrac{1}{2}$ 处理。观察不重的三组，比如 1、3、5 行，可以发现：$2 \in (S \setminus T)$。于是有一个神奇的做法：钦定一个点，强制让它属于 $S$ 集合，就实现了去重。

最终复杂度为 $O(3^n)$。赛时代码：

```cpp
const int N = 17;
mint a[N][N], f[1 << N], g[1 << N];
int n;

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	for (int i = 0; i < (1 << n); i++) {
		g[i] = 1;
		for (int j = 1; j <= n; j++) {
			if (!(i >> (j - 1) & 1)) continue;
			for (int k = j + 1; k <= n; k++) {
				if (i >> (k - 1) & 1) g[i] *= a[j][k] + 1;
			}
		}
	}
	for (int i = 1; i < (1 << n); i++) {
		f[i] = g[i];
		int d = -1;
		for (int j = 0; j < n; j++) {
			if (i >> j & 1) {d = j; break;}
		}
		int s = i ^ (1 << d);
		for (int j = s; j; j = (j - 1) & s) f[i] -= g[j] * f[(s ^ j) | (1 << d)];
	} cout << f[(1 << n) - 1];
}
```

### *P11197 [COTS 2021] 赛狗游戏 Tiket

先转化一下题意，排列 $T$ 不影响答案，因为数对交换一下就满足条件 2。设 $a_i,b_i,c_i$ 为三个排列中 $i$ 出现的位置，问题变成求满足 $a_i<a_j,b_i<b_j,c_i<c_j$ 的三元组 $(i,j,k)$ 数目。

这是三维偏序的模板，使用高级数据结构可做到 $O(n \log^2 n)$。观察到，$a,b,c$ 都是排列。事实上，应用容斥原理可以简单地解决排列上的三维偏序问题。

设 $A=\{(i,j) \mid a_i<a_j\}, B=\{(i,j) \mid b_i<b_j\},C=\{(i,j) \mid c_i<c_j\}$，所求为 $|A \cap B \cap C|$，容斥一下得到

$|A\cap B\cap C|=\dfrac{1}{2}(|A \cap B|+|B \cap C|+|A \cap C|-|A \cup B \cup C|)$对于形如 $|A \cap B|$ 的三部分，做一个二维偏序即可 $O(n \log n)$。考虑 $|A \cup B \cup C|$，若 $(i,j)$ 满足一维偏序，则 $(j,i)$ 满足二维偏序；若其满足二维偏序，则 $(j,i)$ 满足一维偏序；若其满足三维偏序，则 $(j,i)$ 不满足任何偏序。因此，每个 $(i,j)$ 在 $|A \cup B \cup C|$ 中恰好被贡献一次，即 $|A \cup B \cup C|=\dfrac{n(n-1)}{2}$。

于是我们只要做三次二维偏序即可做到 $O(n \log n)$。

```cpp
const int N = 5e5 + 5;
int n, x, a[N], b[N], c[N], d[N], tr[N];
void add(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int ask(int x) {
	int res = 0;
	for (; x >= 1; x -= lowbit(x)) res += tr[x];
	return res;
}
long long solve(int *a, int *b) {
	fill(tr + 1, tr + n + 1, 0);
	long long res = 0;
	for (int i = 1; i <= n; i++) d[b[i]] = a[i];
	for (int i = 1; i <= n; i++) res += ask(d[i]), add(d[i], 1);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> x;
	for (int i = 1; i <= n; i++) cin >> x, a[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, b[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, c[x] = i;
	cout << (solve(a, b) + solve(a, c) + solve(b, c) - 1LL * n * (n - 1) / 2) / 2;
}
```

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

## 11. 二项式反演

## 11.1 原理

设 $f(n)$ 表示恰好使用 $n$ 个不同元素形成特定结构的方案数，$g(n)$ 表示从这 $n$ 个不同元素中选出若干个元素形成特定结构的方案数。

已知 $f(n)$ 求 $g(n)$ 是简单的，枚举选出多少个元素有

$g(n)=\sum_{i=0}^{n} C_n^i f(i)$反着做却是困难的，这个过程就叫**二项式反演**。有公式：

$f(n)=\sum_{i=0}^{n} C_n^i (-1)^{n-i}g(i)$这是二项式反演的形式之一。二项式反演的作用就是把“恰好”转化为“钦定”。

## *11.2 证明

我们先给出一个引理

$C_n^r C_r^k=C^k_n C^{r-k}_{n-k}$组合意义和代数推导都易证。

把上述式子展开：

$$
\begin{aligned}
f(n)&=\sum_{i=0}^{n} C_n^i (-1)^{n-i} [\sum_{j=0}^{i} C_i^j f(j)]\\
&=\sum_{i=0}^{n} \sum_{j=0}^{i} C_n^i C_i^j (-1)^{n-i} f(j) \\
&= \sum_{j=0}^{n} \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} f(j) \\
&= \sum_{j=0}^{n} [f(j) \times \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} ]
\end{aligned}
$$

根据引理可得

$$
\begin{aligned}
f(n)&=\sum_{j=0}^{n} [f(j) \times \sum_{i=j}^{n} C_n^j C_{n-j}^{i-j} (-1)^{n-i} ]\\
&=\sum_{j=0}^{n} [C_n^j f(j) \times \sum_{i=j}^{n}C_{n-j}^{i-j} (-1)^{n-i} ]\\
\end{aligned}
$$

作换元，令 $k=i-j$，则 $i=k+j$，即有

$$
\begin{aligned}
f(n)&=\sum_{j=0}^{n} [C_n^j f(j) \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k} ]\\
&=\sum_{j=0}^{n} [C_n^j f(j) \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k ]
\end{aligned}
$$

由组合数性质 6 可得当且仅当 $n=j$ 时 $\sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k$ 为 $1$，故：

$f(n)=f(n)$上述变换都是等价变换，证毕。

## 11.3 常用形式

下面我们给出二项式反演的全部形式：

形式一：

$f(x)=\sum_{i=0}^x (-1)^iC_x^i g(n) \Leftrightarrow g(x)=\sum_{i=0}^x (-1)^i C_x^i f(i)$这是二项式反演的基本公式。

形式二：

$f(x)=\sum_{i=x}^n C_i^x g(i) \Leftrightarrow g(x)=\sum_{i=x}^n (-1)^{i-x} C_i^x f(i)$这是**钦定意义**下的“至少”转“恰好”。

形式三：

$f(x)=\sum_{i=0}^x C_{n-i}^{n-x} g(i) \Leftrightarrow g(x)=\sum_{i=0}^x (-1)^{x-i} C_{n-i}^{n-x} f(i)$这是**钦定意义**下的“至多”转“恰好”。

形式四：

$f(x)=\sum_{i=0}^x C_{i}^{x} g(i) \Leftrightarrow g(x)=\sum_{i=0}^x (-1)^{x-i} C_{i}^{x} f(i)$这是**选择意义**下的“至多”转“恰好”。

形式五：

$f(x)=\sum_{i=x}^n C_{n-x}^{n-i} g(i) \Leftrightarrow g(x)=\sum_{i=x}^n (-1)^{i-x} C_{n-x}^{n-i} f(i)$这是**选择意义**下的“至少”转“恰好”。

二项式反演的本质是系数特殊的容斥原理。

## 11.4 例题

二项式反演的题目中，最常用的是形式二。同时有些题转成“钦定”以后，还要配合计数 DP 求解。

在二项式反演时，首先要找到“恰好”，然后分清“钦定”和“选择”的区别，使用恰当的反演形式。

### AT_abc423_f [ABC423F] Loud Cicada

设 $g(x)$ 表示**钦定至少** $x$ 种蝉爆发的方案数。状压枚举集合 $S$，则

$g(x)=\sum _{\operatorname{popcount}(S) = x} \lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$解释一下，对于集合 $S$ 中的所有元素 $i$，求出 $a_i$ 的最小公倍数，则集合 $S$ 中的所有蝉爆发的充要条件就是年份为最小公倍数的倍数。在 $Y$ 以内共有 $\lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$ 个年份。

由二项式反演形式二得

$f(m)=\sum_{i=m}^{n} (-1)^{i-m}C_m^i g(i)$复杂度 $O(n2^n)$，杨辉三角 $O(n^2)$ 预处理组合数即可。注意 $\operatorname{lcm}$ 最好开个 `__int128`。

```cpp
#define popcount __builtin_popcount
const int N = 25;
int n, m;
long long y, a[N], g[N], c[N][N];

void _main() {
	cin >> n >> m >> y;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (int s = 0; s < (1 << n); s++) {
		__int128 x = 1;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) x = x / __gcd<__int128>(x, a[i]) * a[i];
			if (x > y) break;  // 注意这句
		} g[popcount(s)] += y / x;
	}
	long long res = 0;
	for (int i = m; i <= n; i++) {
		if ((m - i) & 1) res -= c[i][m] * g[i];
		else res += c[i][m] * g[i];
	} cout << res;
}
```

### P10596 BZOJ2839 集合计数

看到不好求的“恰好”，考虑二项式反演。设 $f(i)$ 表示交集大小恰好为 $i$ 的方案数，$g(i)$ 表示**钦定至少** $i$ 个元素属于交集的方案数。

那么对于 $g(i)$，先从 $n$ 个元素中选出 $i$ 个，方案数 $C_n^i$。剩下 $n-i$ 个元素可选可不选，就是求大小为 $2^{n-i}$ 的集合的非空子集数，答案为 $2^{2^{n-i}}-1$，乘法原理：

$g(i)=C_n^i (2^{2^{n-i}}-1)$由二项式反演形式二得

$f(k)=\sum_{i=k}^{n}(-1)^{i-k} C_i^k g(i)$复杂度 $O(n \log n)$。注意求 $g(i)$ 要用欧拉定理。

```cpp
const int N = 1e6 + 5;
mint fac[N], ifac[N], g[N];
mint C(int n, int m) {
	return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];
}
int n, k;
void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 0; i <= n; i++) g[i] = C(n, i) * (mint(2).pow(mod32<1000000006>(2).pow(n - i).val) - 1);
	mint res = 0;
	for (int i = k; i <= n; i++) {
		if ((i - k) & 1) res -= C(i, k) * g[i];
		else res += C(i, k) * g[i];
	} cout << res;
}
```

### P6521 [CEOI 2010] pin (day2)

首先做一个等价变形，把不同变成相同，令 $m \gets 4-m$ 即可。

将 $i$ 位相同相同视为一个限制，共有 $4$ 种限制，求的是恰好满足 $m$ 个限制的方案数。

套路地，**钦定至少** $x$ 个限制必须满足，设其为 $S$，对于选出的两个串使用字符串哈希，且仅对 $S$ 中的位置哈希，这样就能求出 $x$ 位必须相同的方案数。根据二项式反演形式二求得答案即可。

```cpp
const int N = 5e4 + 5;
int n, m;
long long g[5];
char a[N][5];
const int fac[] = {1, 1, 2, 6, 24};
int C(int n, int m) {return n < m ? 0 : fac[n] / fac[m] / fac[n - m];}

void _main() {
	cin >> n >> m, m = 4 - m;
	for (int i = 1; i <= n; i++) cin >> (a[i] + 1);
	for (int s = 0; s < (1 << 4); s++) {
		umap<uint64_t, int> mp;
		for (int i = 1; i <= n; i++) {
			uint64_t h = 0;
			for (int j = 1; j <= 4; j++) {
				h *= 13331;
				if (s >> (j - 1) & 1) h += a[i][j];
			}
			g[popcount(s)] += mp[h], mp[h]++;
		}
	}
	long long res = 0;
	for (int k = m; k <= 4; k++) {
		if ((k - m) & 1) res -= C(k, m) * g[k];
		else res += C(k, m) * g[k];
 	} cout << res;
}
```

### P6076 [JSOI2015] 染色问题

将“每一”变成“恰好”，用二项式反演的思维来思考。

先处理颜色的限制，不妨计算**选择至多**出现 $x$ 种颜色的方案数。这样每个格子要不然不染色，要不然染 $x$ 种种的一种。

类似地处理掉行列限制后：问题变成：一个 $n\times m$ 的棋盘，至多 $n$ 行被染色，至多 $m$ 行被染色，至多出现 $c$ 种颜色，基础乘法原理得到 $(c+1)^{nm}$。

重复应用三次二项式反演形式四，得到答案为

$\sum_{k=0}^c (-1)^{c-k}C_c^k\sum_{j=0}^m (-1)^{m-j} C_m^j \sum_{i=0}^n (-1)^{n-i} C_n^i (k+1)^{ij}$复杂度 $O(nmc)$，可以通过。

```cpp
const int N = 405;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int n, m, c;
void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> m >> c;
	mint res = 0;
	for (int k = 0; k <= c; k++) {
		mint a1 = 0;
		for (int j = 0; j <= m; j++) {
			mint a2 = 0;
			for (int i = 0; i <= n; i++) {
				if ((n - i) & 1) a2 -= C(n, i) * mint(k + 1).pow(i * j);
				else a2 += C(n, i) * mint(k + 1).pow(i * j);
			}
			if ((m - j) & 1) a1 -= C(m, j) * a2;
			else a1 += C(m, j) * a2;
		}
		if ((c - k) & 1) res -= C(c, k) * a1;
		else res += C(c, k) * a1;
	} cout << res;
}
```

### P5505 [JSOI2011] 分特产

正难则反，记 $f(x)$ 为**钦定至少** $x$ 人没有分到的方案数，由二项式反演形式二得到答案为

$\sum_{i=0}^{n-1} (-1)^i C_n^if(i)$需要求出 $f(x)$。考虑插板法，第 $k$ 个特产没有分到的方案是 $C_{a_k+n-x-1}^{n-x-1}$，根据乘法原理合并：

$f(x)=\prod_{k=1}^m C_{a_k+n-x-1}^{n-x-1}$逆元法预处理组合数即可，复杂度 $O(nm)$。

```cpp
const int N = 2005;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m]; }
int n, m, a[N];
mint f(int x) {
	mint res = 1;
	for (int k = 1; k <= m; k++) res *= C(a[k] + n - x - 1, n - x - 1);
	return res;
}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> a[i];
	mint res = 0;
	for (int i = 0; i < n; i++) {
		if (i & 1) res -= C(n, i) * f(i);
		else res += C(n, i) * f(i);
	} cout << res;
}
```

### CF1228E Another Filling the Grid

我们给出二项式反演形式二的二维形式：

$f(i,j)=\sum_{x=i}^n \sum_{y=j}^n C_x^i C_y^j g(x,y) \Leftrightarrow g(i,j)=\sum_{x=i}^n \sum_{y=j}^n (-1)^{x-i+y-j} C_x^i C_y^j f(x,y)$特判 $k=1$。设 $f(i,j)$ 表示**钦定至少** $i$ 行 $j$ 列不满足要求的方案数，$g(i,j)$ 表示恰好 $i$ 行 $j$ 列不满足要求的方案数。容易发现 $f,g$ 满足上述公式。只需求出 $f(i,j)$。基础乘法原理得到

$f(i,j)=(k-1)^{n^2-(n-i)(n-j)} k^{(n-i)(n-j)}$直接做即可。复杂度 $O(n^2)$。

```cpp
const int N = 255;
int n, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

mint f(int x, int y) {
	return mint(k - 1).pow(n * n - (n - x) * (n - y)) * mint(k).pow((n - x) * (n - y));
}

void _main() {
	cin >> n >> k;
	if (k == 1) return cout << 1, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 0;
	for (int i = 0; i <= n; i++) {
		for (int j = 0; j <= n; j++) {
			if ((i + j) & 1) res -= C(n, i) * C(n, j) * f(i, j);
			else res += C(n, i) * C(n, j) * f(i, j);
		}
	} cout << res;
}
```

### AT_abc172_e [ABC172E] NEQ

其实可以用第 12 章错排的方法解决，放在这里有点大炮打蚊子了。

设 $g(x)$ 表示钦定 $x$ 位相同的方案数，$f(x)$ 为**钦定至少** $x$ 位相同的方案数，根据二项式反演形式二

$g(x)=\sum_{i=x}^n (-1)^{i-x}C_x^i f(i)$答案即为

$g(0)=\sum_{i=0}^n (-1)^n f(i)$此时二项式反演退化为普通容斥原理。容易得到

$f(x)=C_n^x A_m^x (A_{n-x}^{m-x})^2$复杂度 $O(n)$。

```cpp
const int N = 5e5 + 5;
int n, m;
mint fac[N], ifac[N];
mint A(int n, int m) {return n < m ? 0 : fac[n] * ifac[n - m];}
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint f(int x) {
	return C(n, x) * A(m, x) * A(m - x, n - x) * A(m - x, n - x);
}

void _main() {
	cin >> n >> m;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= max(n, m); i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 0;
	for (int i = 0; i <= n; i++) {
		if (i & 1) res -= f(i);
		else res += f(i);
	} cout << res;
}
```

### P10986 [蓝桥杯 2023 国 Python A] 2023

开题 10min 秒了。

设恰好 $m$ 个 $2023$ 出现的方案数为 $f(m)$，钦定至少 $m$ 个 $2023$ 出现的方案数为 $g(m)$，根据二项式反演形式二

$f(m)=\sum_{i=m}^{\lfloor n/4 \rfloor} (-1)^{i-m}C_m^i g(i)$只需求出 $g(i)$。当钦定了 $i$ 个 $2023$ 时，数字串形如 `...2023...2023...`，简单插板法得到

$g(i)=10^{n-4i} C_{n-3i}^i$做完了。复杂度 $O(n)$。

```cpp
const int N = 1e5 + 5;
int n, m;
mint g[N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n >> m;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = m; i <= n / 4; i++) g[i] = C(n - 3 * i, i) * mint(10).pow(n - 4 * i);
	mint res = 0;
	for (int i = m; i <= n / 4; i++) {
		if ((i - m) & 1) res -= C(i, m) * g[i];
		else res += C(i, m) * g[i];
	} cout << res;
}
```

### *P4859 已经没有什么好害怕的了

形式化题意：给出长为 $n$ 的序列 $a,b$，将其两两配对使得 $a_i>b_i$ 的数目减去 $a_i<b_i$ 的数目恰为 $k$，求方案数。

设 $a_i>b_i$ 的数量为 $m$，则 $m-(n-m)=k$，解得 $m=\dfrac{n+k}{2}$。若 $2 \nmid (n+k)$，直接判定无解。此时问题变成 $a_i>b_i$ 的数目恰好为 $m$。使用二项式反演化恰好为钦定。设 $g(i)$ 为**钦定至少** $a_i>b_i$ 的组数不小于 $i$ 的方案数，根据二项式反演形式二，所求即

$\sum_{i=m}^{n} (-1)^{i-m} C_{i}^k g(i)$现在的问题就是求 $g(i)$，这玩意很 DP，所以设 $dp_{i,j}$ 表示前 $i$ 个数中选出 $j$ 组 $a_i>b_i$ 的方案数。DP 题套路对 $a,b$ 排序，然后可以推出转移方程

$dp_{i,j}=dp_{i-1,j}+(last_i-j+1)dp_{i-1,j-1}$可以看看下文的排列计数 DP，从插入角度考虑 $(a_i,b_i)$ 的贡献，一种情况是不作为新的 $a_i>b_i$，还有一种就是考虑有多少个取代位置。设 $last_i$ 表示 $b$ 序列中第一个小于 $a_i$ 的数的下标，则插入位置就有 $last_i-j+1$ 个，加法原理合并答案。

于是我们 $O(n^2)$ 求出 $dp_{i,j}$。考察 $g(i)$ 的定义可得

$g(i)=dp_{n,i}\times  (n-i)!$就是在有序的 DP 基础上考虑剩下 $n-i$ 个全排列。

二项式反演中组合数可以逆元法来求，总复杂度 $O(n^2)$。

```cpp
const int N = 2005;
int n, m, k, a[N], b[N], last[N];
mint fac[N], ifac[N], dp[N][N], g[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n >> k;
	if ((n + k) & 1) return cout << 0, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];

	m = (n + k) / 2;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	sort(a + 1, a + n + 1), sort(b + 1, b + n + 1);
	for (int i = 1; i <= n; i++) last[i] = lower_bound(b + 1, b + n + 1, a[i]) - b - 1;
	dp[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		dp[i][0] = dp[i - 1][0];
		for (int j = 1; j <= i; j++) {
			dp[i][j] = dp[i - 1][j] + dp[i - 1][j - 1] * max(0, last[i] - j + 1);
		}
	}
	for (int i = 0; i <= n; i++) g[i] = dp[n][i] * fac[n - i];
	mint res = 0;
	for (int i = m; i <= n; i++) {
		if ((i - m) & 1) res -= C(i, m) * g[i];
		else res += C(i, m) * g[i];
	} cout << res;
}
```

### P10597 BZOJ4665 小 w 的喜糖

和 P4859 很像。设 $f(x)$ 表示恰好 $x$ 个位置不同的方案数，$g(x)$ 表示**钦定至少** $x$ 个位置的不同方案数，由二项式反演形式二得

$f(x)=\sum_{i=x}^n (-1)^{i-x} C_x^i g(i)$所求为

$f(0)=\sum_{i=0}^n (-1)^i g(i)$我们再一次看到了二项式反演退化为普通容斥原理。考虑求 $g(x)$。

记第 $i$ 种糖果的个数有 $c_i$ 个，先假设同种糖果不同，根据多重集排列数，除掉 $c_i!$ 即可。

设 $dp_{i,j}$ 表示前 $i$ 种糖果中至少 $j$ 个人的糖果与原来相同的方案数，枚举 $k$ 颗被钦定的第 $i$ 种糖果，容易得到

$dp_{i,j}=\sum_{k=0}^{\min(c_i,j)} \dfrac{dp_{i-1,j-k} \times C_{c_i}^k}{(c_i-k)!}$则 $g(x)=dp_{n,x} \times (n-x)!$。复杂度 $O(n^3)$。

```cpp
const int N = 2005;
mint fac[N], ifac[N], dp[N][N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
int n, a[N], c[N];

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], c[a[i]]++;
	dp[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 0; j <= n; j++) {
			for (int k = 0; k <= min(c[i], j); k++) dp[i][j] += dp[i - 1][j - k] * C(c[i], k) * ifac[c[i] - k];
		}
	}
	mint res = 0;
	for (int i = 0; i <= n; i++) {
		if (i & 1) res -= dp[n][i] * fac[n - i];
		else res += dp[n][i] * fac[n - i];
	} cout << res;
}
```

### *P6478 [NOI Online #2 提高组] 游戏

“恰好 $k$ 次非平局”很难处理，不妨转为“钦定 $k$ 次非平局”。设恰好 $k$ 次非平局的方案数为 $g(k)$，**钦定至少** $k$ 次非平局的方案数为 $f(k)$，显然有 $f(n)=\sum_{i=n}^m C_i^n g(i)$，根据二项式反演形式二得

$g(n)=\sum_{i=n}^m (-1)^{i-n} C_i^n f(i)$考虑求 $f(i)$ 即可。考虑树形 DP，设 $dp_{u,i}$ 表示在以 $u$ 为根的子树中钦定 $i$ 个点且必须有胜负的方案数。

考虑对于儿子 $v$ 枚举在 $v$ 中选择 $j$ 个点，有转移：

$dp_{u,i}=\sum_{(u,v)} \sum_{j =0}^i dp_{v,j}dp_{u,i-j}$还可以选择一个点与 $u$ 配对，于是：

$dp_{u,i} \gets dp_{u,i}+dp_{u,i-1}+cnt_{u,x \oplus 1}$其中 $x$ 为点 $u$ 属于哪位玩家，$cnt_{u,0/1}$ 表示以 $u$ 为根的子树中有多少个属于 $0/1$ 玩家。

这是一个树形背包，且应该跑 01 背包。根据树形背包的复杂度证明，复杂度是严格 $O(n^2)$ 的。

这样有 $g(i)=dp_{1,i}\times (m-i)!$。求出来以后套进二项式反演即可。

```cpp
const int N = 5005;
int n, m, u, v, belong[N];
char c;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
mint f[N], g[N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int sz[N], cnt[2][N];
mint dp[N][N];
void dfs(int u, int fa) {
	sz[u] = 1, cnt[belong[u]][u] = 1, dp[u][0] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		vector<mint> f(min(sz[u] + sz[v], m), 0);
		for (int j = 0; j <= min(sz[u], m); j++) {
			for (int k = 0; k <= min(sz[v], m - j); k++) {
				f[j + k] += dp[u][j] * dp[v][k];
			}
		}
		sz[u] += sz[v], cnt[0][u] += cnt[0][v], cnt[1][u] += cnt[1][v];
		copy(f.begin(), f.end(), dp[u]);
	}
	for (int i = cnt[belong[u] ^ 1][u]; i >= 0; i--) {
		dp[u][i + 1] += dp[u][i] * (cnt[belong[u] ^ 1][u] - i);
	}
}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n, m = n / 2;
	for (int i = 1; i <= n; i++) cin >> c, belong[i] = c ^ 48;
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
	}
	dfs(1, -1);
	for (int i = 0; i <= m; i++) g[i] = dp[1][i] * fac[m - i];
	for (int i = 0; i <= m; i++) {
		for (int j = i; j <= m; j++) {
			if ((j - i) & 1) f[i] -= C(j, i) * g[j];
			else f[i] += C(j, i) * g[j];
		}
		cout << f[i] << '\n';
	}
}
```

### *P3270 [JLOI2016] 成绩比较

前置知识：第 24 章 Lagrange 插值求自然数幂和。

设 $f(k)$ 表示恰好 $k$ 个人被碾压的方案数，$g(k)$ 表示**钦定至少** $k$ 个人被碾压的方案数。由二项式反演形式二得

$f(k)=\sum_{i=k}^n (-1)^{i-k} C_i^k g(i)$考虑求 $g(k)$。分步地，从 $n-1$ 个人中钦定 $k$ 个人被碾压。对于每一科 $i$，枚举 D 神的分数 $j$，选出 $r_i-1$ 个人高于 D 神，再乘法原理做一做得到

$g(k)=C_{n-1}^k \prod_{i=1}^m \sum_{j=1}^{U_i} C_{n-k-1}^{r_i-1} j^{n-r_i}(U_j-1)^{n-r_i}$复杂度 $O(nmV \log n)$，无法通过。

考虑消去值域限制。开始大力推柿子：

$$
\begin{aligned}
g(k)&=C_{n-1}^k \prod_{i=1}^m \sum_{j=1}^{U_i} C_{n-k-1}^{r_i-1} j^{n-r_i}(U_j-1)^{n-r_i}\\
&=C_{n-1}^k \prod_{i=1}^m \sum_{j=1}^{U_i} C_{n-k-1}^{r_i-1} j^{n-r_i}\sum_{k=0}^{r_i-1} (-1)^{r_i-k-1}C_{r_i-1}^k {U_i}^k j^{r_i-k-1}\\
&=C_{n-1}^k \prod_{i=1}^m C_{n-k-1}^{r_i-1} \sum_{k=0}^{r_i-1} (-1)^{r_i-k-1} C_{r_i-1}^{k} {U_i}^k \sum_{j=1}^{U_i} j^{n-k-1} 
\end{aligned}
$$

设

$h(i)=\sum_{k=0}^{r_i-1} (-1)^{r_i-k-1} C_{r_i-1}^{k} {U_i}^k \sum_{j=1}^{U_i} j^{n-k-1}$则

$g(k)=C_{n-1}^k \prod_{i=1}^m C_{n-k-1}^{r_i-1} h(i)$只要处理出 $\sum_{j=1}^{U_i} j^{n-k-1}$，$h(i)$ 的预处理是简单的。使用 Lagrange 插值在 $O(n)$ 内求出自然数幂和，然后预处理 $h(i)$，最后套回去即可。总复杂度 $O(n^2m)$。

```cpp
const int N = 105;
int n, m, k, u[N], r[N];
mint h[N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint g(int k) {
	mint res = C(n - 1, k);
	for (int i = 1; i <= m; i++) res *= C(n - k - 1, r[i] - 1) * h[i];
	return res;
}
namespace Lagrange {
	mint a[N], p[N], s[N];
	mint solve(int n, int k) {
		p[0] = 1, s[k + 3] = 1;
		for (int i = 1; i <= k + 2; i++) a[i] = a[i - 1] + mint(i).pow(k), p[i] = p[i - 1] * (n - i);
		for (int i = k + 2; i >= 1; i--) s[i] = s[i + 1] * (n - i);
		if (n <= k + 2) return a[n];
		mint res = 0;
		for (int i = 1; i <= k + 2; i++) {
			mint cur = a[i] * p[i - 1] * s[i + 1] * ifac[i - 1] * ifac[k + 2 - i];
			if ((k + 2 - i) & 1) res -= cur;
			else res += cur;
		} return res;
	}
} using Lagrange::solve;

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> m >> k;
	for (int i = 1; i <= m; i++) cin >> u[i];
	for (int i = 1; i <= m; i++) cin >> r[i];
	for (int i = 1; i <= m; i++) {
		for (int k = 0; k < r[i]; k++) {
			mint cur = C(r[i] - 1, k) * mint(u[i]).pow(k) * solve(u[i], n - k - 1);
			if ((r[i] - k - 1) & 1) h[i] -= cur;
			else h[i] += cur;
		}
	}
	mint res = 0;
	for (int i = k; i <= n; i++) {
		if ((i - k) & 1) res -= C(i, k) * g(i);
		else res += C(i, k) * g(i);
	} cout << res;
}
```

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

## 13. Catalan 数

**Catalan 数**的起源是凸多边形三角剖分问题，即对于一个凸 $n$ 边形，有多少种方式可以用不相交的对角线将其划分为若干个三角形。这里将方案数记作 $H_n$。Catalan 数列为： $1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862\cdots$，参见 [A000108](https://oeis.org/A000108)。

## 13.1 解决问题

**这里写的不太清楚，笔者认为 [OI-Wiki](https://oi-wiki.org/math/combinatorics/catalan/#%E5%BA%94%E7%94%A8) 上写的非常好，推荐学习。**

1. 括号序列计数

Q: 计算 $n$ **对**括号能形成多少种合法括号序列。

A: 方案数为 $H_n$。因为序列的第一个括号必须为 `(`，设之后有一个长度为 $m$ 的子序列，然后为 `)`，再然后是另一个子序列，长度为 $n-m-1$，则方案为 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$，这就是 Catalan 的递推式。

1. 不同构二叉树计数

Q: 计算 $n$ 个节点的不同构二叉树数目。

A: 数目为 $H_n$。设根节点左子树大小为 $m$，则右子树大小为 $n-m-1$，左右子树又是一个子问题，所以方案为 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$，符合递推式。

1. 三角剖分问题

Q: 求对于一个凸 $n+2$ 边形，有多少种方式可以用不相交的对角线将其划分为若干个三角形。

A: 方案数为 $H_n$。固定多边形的一条边并选择一个与它不共线的初始顶点构成一个三角形，这个三角形将原多边形分为两个小多边形，大小分别为 $m$ 和 $n-m-1$，所以方案还是那个 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$。

1. 不越过对角线的网格路径

Q: 在 $n \times n$ 网格中，从 $(0,0)$ 走到 $(n,n)$ 且只能向右或向上移动，求不越过对角线 $y=x$ 的路径数，如图所示。

![](https://cdn.luogu.com.cn/upload/image_hosting/0ztrlo61.png)

A: 路径数为 $H_n$。如果你不考虑限制，就是在总共 $2n$ 步中分出 $n$ 步走上或者右，方案数为 $C_{2n}^{n}$。用减法原理，算不合法的方案，对于任意一条接触了 $y=x$ 的路径，将其**最后**离开这条线的点到 $(0,0)$ 之间作一个对称，则不合法路径的终点变为 $(n-1,n+1)$。可以证明这样变换是一一对应的。选出 $n-1$ 步走右，方案数 $C_{2n}^{n-1}$，因此答案为 $C_{2n}^n-C_{2n}^{n-1}$。这是 Catalan 数的通项公式。

1. 出栈序列计数

Q: 入栈序列为一个 $1$ 到 $n$ 的排列，求合法出栈序列数目。

A: 数目为 $H_n$。设第一个入栈元素在第 $m$ 个出栈，则前面 $m-1$ 个必须在之前出入栈，而之后又 $n-m-1$ 种，递推式又双叒叕是 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$。

由此可见，能用 Catalan 数解决的问题都满足一个递归分解结构：**一个大小为 $n$ 的问题可以分解为两个独立子问题，规模分别为 $m$ 与 $n-m-1$，且两子问题分步**，也就是用乘法原理组合。

## 13.2 计算公式

上面已经给出了一个递推式：

$H_n=\sum_{i=0}^{n-1} H_{i} H_{n-i-1}$但是这玩意是 $O(n^2)$ 的。我们有 $O(n)$ 的递推式：

$H_n=\dfrac{4n-2}{n+1} H_{n-1}$根据问题 4 可知通项公式：

$H_n=\dfrac{C_{2n}^n}{n+1}=C_{2n}^n-C_{2n}^{n-1}$使用递推式可以在 $O(n)$ 复杂度内预处理 $H_i$。而使用通项公式再用 lucas / exLucas 等科技则可以获得更低的复杂度。

## 13.3 例题

### P1044 [NOIP 2003 普及组] 栈

就是问题 5。用递推式 2 计算即可。

```cpp
long long n, h[20];

void _main() {
	cin >> n;
	h[0] = 1;
	for (int i = 1; i <= n; i++) h[i] = h[i - 1] * (4 * i - 2) / (i + 1);
	cout << h[n];
}
```

### P1375 小猫

圆内不相交弦计数。将 $2n$ 个点按顺时针编号，一条弦连接的两点视为左括号和右括号，转化为括号序列计数。所以方案数还是 Catalan 数。代码和上题的区别就是加个取模。

双倍经验：[P1976](https://www.luogu.com.cn/problem/P1976)。

### P10413 [蓝桥杯 2023 国 A] 圆上的连线

这题可以不连线，所以先从 $2023$ 个点选 $n$ 个设为必须连边，这一步方案为 $C_{2023}^n$。

然后这个问题就是上一题，答案为 $H_{n/2}$。由乘法原理可得答案，注意 $n$ 是偶数。

$\sum_{n=0}^{2023} C_{2023}^{n} H_{n/2}, n \in \{x | x=2k,k \in \mathbb{\N} \}$考虑到 $2023$ 不是质数，你应该对组合数和 Catalan 数都用递推来求解。答案是 $104$。

### P1754 球迷购票问题

先审题，当 A 买票后，售票处得到一个 $50$ 元；当 B 买票后，售票处失去一个 $50$ 元，所以 A, B 是一个二元对应关系。建立括号模型，将 A 当作左括号，B 当作右括号，发现合法的排队序列就是括号匹配序列，这是问题 1，还是写 Catalan 数即可。

### P2532 [AHOI2012] 树屋阶梯

把这题放 Catalan 数例题说明了一切。

用 $f_i$ 表示高度为 $i$ 的阶梯的搭建方案数，显然 $f_0=f_1=1$。借用一下第一篇题解的图：

![image.png](https://i.loli.net/2020/02/02/2xksBinHCIXUWrg.png)

枚举每个顶到拐角的矩形，比如这里的第一个矩形，那么右侧方案是 $f_4$。

![image.png](https://i.loli.net/2020/02/02/RJmZdy1kc5qTEbF.png)

再看这个矩形，上侧为 $f_1$，右侧为 $f_3$。

![image.png](https://i.loli.net/2020/02/02/KXQ4GyxiBv1cOwz.png)

类似地，上侧为 $f_2$，右侧为 $f_2$。同理可得另外的情况，因此

$f_n=\sum_{i=0}^{n-1} f_{i} f_{n-i-1}$这满足“一个大小为 $n$ 的问题可以分解为两个独立子问题，规模分别为 $m$ 与 $n-m-1$，且两子问题分步”的条件，所以所求就是 Catalan 数。然后你整个高精度即可，代码不放了。

### *P3978 [TJOI2015] 概率论

不会期望移步下文 18.3。

首先由问题 2 可得不同构二叉树有 $H_n$ 棵。然后设 $f_n$ 表示所有二叉树的叶子节点数目之和。

注意到，$f_n=nH_{n-1}$。

简证：对于一棵 $n$ 个节点的二叉树，若存在 $k$ 个叶子节点，将 $k$ 个叶子依次删去，可构造得 $k$ 棵 $n-1$ 个点的二叉树，并且这些二叉树还有 $n$ 个点可以挂叶子，因此 $f_n =\sum k H_{n-1}=nH_{n-1}$。

然后期望为 $E(X)=\dfrac{f_n}{H_n}$，代入通项公式 $H_n=\dfrac{C_{2n}^n}{n+1}$ 消去可得 $E(X)=\dfrac{n(n+1)}{2(2n-1)}$。于是这道紫题就做完了。

### *P7118 Galgame

根据问题 2，节点数小于 $n$ 的二叉树数目为

$\sum_{i=1}^{n-1} H_i$重点是算节点数相同的二叉树。根据先左再右的比较方式，设左儿子大小为 $s$，左右儿子总大小为 $n$，和问题 2 相同的推导方法可得方案数是

$\sum_{i=0}^{s-1} H_{i} H_{n-i-1}$预处理 Catalan 数，在 dfs 过程中记录乘子，如果走了左链，右子树就不用管了可以任意选，因此由乘法原理将乘子乘上右子树大小，具体细节看代码。

```cpp
const int N = 2e6 + 5;
int n, ls[N], rs[N], sz[N];
mint h[N];

void dfs1(int u) {
	if (!u) return;
	dfs1(ls[u]), dfs1(rs[u]), sz[u] = sz[ls[u]] + sz[rs[u]] + 1;
} mint dfs2(int u, mint x) {
	if (!u) return 0;
	mint res = 0;
	for (int i = 0; i < sz[ls[u]]; i++) res += x * h[i] * h[sz[u] - i - 1];
	res += dfs2(ls[u], x * h[sz[rs[u]]]);
	res += dfs2(rs[u], x);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> ls[i] >> rs[i];
	h[0] = 1;
	for (int i = 1; i <= (n << 1); i++) h[i] = h[i - 1] * (4 * i - 2) / (i + 1);
	mint res = 0;
	for (int i = 1; i < n; i++) res += h[i];
	dfs1(1), res += dfs2(1, 1);
	cout << res;
}
```

喜提 [30pts](https://www.luogu.com.cn/record/227987799) 大黑大紫。因为这样做是 $O(n^2)$ 的，会被左偏形态的树卡满。

考虑当左子树大小大于右子树时，用右子树大小代替左子树大小计算。用减法原理，用总方案数减去不小于原树的二叉树。记右子树大小为 $s$，同理可得答案

$H_n-\sum_{i=0}^{s} H_{i}H_{n-i-1}$然后你神奇地发现这变成了启发式合并，复杂度是 $O(n \log n)$ 的。然后你把 `dfs2` 改成这样即可：

```cpp
mint dfs2(int u, mint x) {
	if (!u) return 0;
	mint res = 0;
	if (sz[ls[u]] <= sz[rs[u]]) {
		for (int i = 0; i < sz[ls[u]]; i++) res += x * h[i] * h[sz[u] - i - 1];
	} else {
		res += x * h[sz[u]];
		for (int i = 0; i <= sz[rs[u]]; i++) res -= x * h[i] * h[sz[u] - i - 1];
	}
	res += dfs2(ls[u], x * h[sz[rs[u]]]);
	res += dfs2(rs[u], x);
	return res;
}
```

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

## 16. 分拆数

这部分内容参考了本人学长的 [Blog](https://www.luogu.me/article/ed1zhztr)。

- **分拆**：将自然数 $n$ 写为递降正整数和的表示。如 $8=5+2+1$。形式化地，记 $n=r_1+r_2+r_3+\cdots+r_k$，其中 $r_1 \ge r_2 \ge r_3 \ge \cdots r_k \ge 1$，且 $r_1,r_2,r_3,\cdots,r_k$ **无序**。
- **分拆数** $p_n$：自然数 $n$ 的分拆方法数。[A000041](https://oeis.org/A000041)。

仔细思考一下可以发现，$p_n$ 就是背包容量为 $n$，物品体积为 $1,2,3,\cdots,n$ 的完全背包的方案数。因此可以 $O(n^2)$ 地递推求出 $p_n$：

```cpp
p[0] = 1;
for (int i = 1; i <= n; i++) {
    for (int j = i; j <= n; j++) p[j] += p[j - i];
}
```

## 16.1 分拆数变形

如果我们对分拆 $n=r_1+r_2+r_3+\cdots+r_k$ 有一些限制，就会得到分拆数的各种变形。

### 16.1.1 kkk 部分拆数

- **$k$ 部分拆数** $p(n,k)$：将 $n$ 分成恰有 $k$ 个部分的分拆方法数。

用 DP 的思想来推导 $p(n,k)$ 的递推式。

1. 若最后一个数为 $1$，则剩下数的和为 $n-1$，分为 $k-1$ 部，答案为 $p(n-1,k-1)$。
2. 若最后一个数不为 $1$，因为这些数中一定不含有 $1$，于是令 $r'_i =r_i-1$，即 $n-k=(r_1-1)+(r_2-1)+(r_3-1)+\cdots+(r_k-1)$，即为 $n-k$ 分为 $k$ 部，答案为 $p(n-k,k)$。

由加法原理得：

$p(n,k)=p(n-1,k-1)+p(n-k,k)$边界是 $p(0,0)=1$。我们可以在 $O(n^2)$ 时间内计算 $p(n,k)$。显然

$p_n=\sum_{k=1}^{n} p(n,k)$这样我们又多了一种 $O(n^2)$ 算 $p_n$ 的方法。

### 16.1.2 互异分拆数

- **互异分拆**：将自然数 $n$ 写为**严格**递降正整数和的表示。形式化地，记 $n=r_1+r_2+r_3+\cdots+r_k$，其中 $r_1 > r_2 > r_3 > \cdots r_k > 1$，且 $r_1,r_2,r_3,\cdots,r_k$ **无序**。
- **互异分拆数** $pd_n$：自然数 $n$ 的互异分拆方法数。[A000009](https://oeis.org/A000009)。
- **$k$ 部互异分拆数** $pd(n,k)$：将 $n$ 分成恰有 $k$ 个部分的互异分拆方法数。

我们直接给出递推式：

$pd(n,k)=pd(n-k,k-1)+pd(n-k,k)$推导方法类似。有结论：当 $k > \sqrt{2n}$ 时，$pd(n,k)=0$。

证明：贪心地，设 $n=\sum_{i=1}^k i=\dfrac{k(k+1)}{2}$，上式大于 $\dfrac{k^2}{2}$，故 $k < \sqrt{2n}$。

于是可以在 $O(n\sqrt{n})$ 时间内求出 $pd(n,k)$。边界还是 $pd(0,0)=1$。

同理有

$pd_n=\sum_{k=1}^{n} pd(n,k)$所以 $pd_n$ 也可以 $O(n\sqrt{n})$ 算出。本质上，$p_n$ 是完全背包方案数，$pd_n$ 则是 01 背包方案数。

### *16.1.3 最大 kkk 分拆数

- **最大 $k$ 分拆数** $p^{\max}(n,k)$：$n$ 的最大部分为 $k$ 的分拆方法数。
- **最大 $k$ 互异分拆数** $pd^{\max}(n,k)$：$n$ 的最大部分为 $k$ 的互异分拆方法数。

有结论：

$$
p^{\max}(n,k)=p(n,k)\\
pd^{\max}(n,k)=pd(n,k)\\
$$

要证明这个东西且不用到生成函数知识，我们需要引入杨表。在很多介绍分拆数的文章中也称其为 Ferrers 图。

杨表的画法是，将分拆 $n=r_1+r_2+r_3+\cdots+r_k$ 的每个部分用点表示，第 $i$ 行有 $r_i$ 个点。例如 $12=5+4+2+1$ 的杨表如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/j6fuh0ae.png)

将这个杨表顺时针旋转 $90 \degree$，得到的新表称作原表的共轭。如 $12=5+4+2+1$ 的共轭为 $12=4+3+2+2+1$。

![](https://cdn.luogu.com.cn/upload/image_hosting/7leu1zns.png)

记原来的分拆为 $\lambda$，其共轭为 $\lambda^*$。容易发现，$\forall \lambda_1 \ne \lambda_2 ,\lambda_1^* \ne \lambda_2^*$。这说明：共轭是一一对应的。

现在我们证明 $p^{\max}(n,k)=p(n,k)$。

考虑 $p^{\max}(n,k)$ 的一个分拆 $\lambda$ 的杨表，根据定义这个杨表有恰好 $k$ 列。其共轭分拆有 $k$ 行，在 $p(n,k)$ 中恰好被统计一次。因为共轭一一对应，所以 $p^{\max}(n,k)=p(n,k)$。$pd^{\max}(n,k)=pd(n,k)$ 同理。

### *16.1.4 奇分拆数

- **奇分拆数 $po_n$**：$n$ 的各部分分拆均为奇数的方法数。[A000009](https://oeis.org/A000009)。

定理：

$po_n=pd_n$非常神奇的一个式子。证明它需要建立起一一对应关系。

对于一个互异分拆，考虑构造一个奇分拆。重复如下操作直到 $\forall i,2 \nmid r_i$：

对于所有的 $2 \mid r_i$，设 $r_i=2a$，将两个 $a$ 加入到奇分拆中。

比如说对于互异分拆 $14=5+4+3+2$，第一次操作变为 $14=5+3+2+2+1+1$，第二次操作变为 $14=5+3+1+1+1+1+1+1$。

因为一个互异分拆在操作一次之后就不互异了，那么就不存在两个不同的互异分拆映射到相同的奇分拆的情况，证毕。

## 16.2 五边形数定理

![](https://cdn.luogu.com.cn/upload/image_hosting/x5tfyila.png)

- 五边形数 $P_5(n)$：能排成五边形的点数。易得 $P_5(n)=\dfrac{n(3n-1)}{2}$。[A000326](https://oeis.org/A000326)。可以发现 $P_5(n)$ 是 $O(n^2)$ 级别的。
- 广义五边形数：当 $n<0$ 时仍然套用上面的公式。[A001318](https://oeis.org/A001318)。

不加证明地给出定理：

$$
\begin{aligned}
p_n&=\sum_{i>0, n \ge P_5(-i)} (-1)^{i+1} (p_{n-P_5(i)}+p_{n-P_5(-i)})\\
&=p_{n-1}+p_{n-2}-p_{n-5}-p_{n-7}+p_{n-12}+p_{n-15}-\cdots
\end{aligned}
$$

由于 $P_5(n)$ 为 $O(n^2)$ 级别，使得 $n \ge P_5(-i)$ 的 $i$ 只有 $O(\sqrt{n})$ 个。于是可以在 $O(n\sqrt{n})$ 时间内计算分拆数。

## *16.3 范围估计

分拆数 $p_n$ 并不像错排 $D_n$ 那样有明确的估计。目前较好的逼近为

$p_n \sim \dfrac{\exp(\pi \sqrt{\dfrac{2n}{3}})}{4\sqrt{3}n} , n \gets \infty$因此 $O(p_n)$ 在小数据下是一个较优秀的复杂度。例题 [P4128 [SHOI2006] 有色图](https://www.luogu.com.cn/problem/P4128)，但需要用到笔者不会的群论知识，所以没放到例题里。

## 16.4 例题

### SP2007 COUNT - Another Very Easy Problem! WOW!!!

$k$ 部分拆数的板子题。套用递推式即可。

```cpp
int n, k;
mint p[N][N];

void _main() {
	for (int i = 1; i < N; i++) p[i][1] = p[i][i] = 1;
	for (int i = 1; i < N; i++) {
		for (int j = 2; j <= i; j++) p[i][j] = p[i - 1][j - 1] + p[max(i - j, 0)][j];
	}
	while (cin >> n >> k, n || k) cout << p[n][k] << '\n';
}
```

### P6189 [NOI Online #1 入门组] 跑步

分拆数的板子。我们先给出五边形数定理求解的代码：

```cpp
const int N = 1e5 + 5;
long long n, m, a[N << 1], p[N];

void _main() {
	cin >> n >> m;
	p[0] = 1, p[1] = 1, p[2] = 2;
	for (int i = 1; i < N; i++) {
		a[i << 1] = i * (i * 3 - 1) / 2;
		a[i << 1 | 1] = i * (i * 3 + 1) / 2;
	}
	for (int i = 3; i < N; i++) {
		p[i] = 0;
		for (int j = 2; a[j] <= i; j++) {
			if (j & 2) (p[i] += p[i - a[j]]) %= m;
			else p[i] -= p[i - a[j]], p[i] = (p[i] % m + m) % m;
		}
	} cout << p[n];
}
```

求分拆数还有一种有意思的做法是根号分治优化 DP。考虑我们之前给出的两种 $O(n^2)$ 求解方法：

1. 完全背包。设 $dp_{i,j}$ 表示将 $i$ 分拆为若干个不超过 $j$ 的数的方案数，有 $p_n=dp_{n,n}$，转移式为

$dp_{i,j}=dp_{i,j-1}+dp_{i-j,j}$1. 基于 $k$ 部分拆数。即 $p_n=\sum_{k=1}^{n} p(i,k)$，其中

$p(i,k)=p(i-1,k-1)+p(i-k,k)$选择一个阈值 $m$。对于 $\le m$ 的情况使用第一种方法，对于 $>m$ 的情况我们采用第二种方法。具体地，先用 $dp_{i,j}$ 求出 $j \le m$ 的方法数，在递推 $p(i,k)$ 时以 $m$ 为步长递推。复杂度 $O(mn+\dfrac{n^2}{m})$。由基本不等式得 $m=\sqrt{n}$ 最优，复杂度 $O(n\sqrt{n})$。

最后合并答案时，枚举第一个部分的总和 $j$，剩下的总和为 $n-j$，由乘法原理合并。即

$p_n=\sum_{j=0}^{n} (f_{m-1,j} \times \sum_{k=0}^{m} p(n-j,k))$复杂度也控制在 $O(n\sqrt{n})$ 以内。注意代码实现时 $p(i,k)$ 交换了两维优化常数。

```cpp
const int N = 1e5 + 5, M = 405;
int n, m, dp[N], p[M][N];

void _main() {
	cin >> n >> m;
	int b = sqrt(n) + 1;
	dp[0] = 1, p[0][0] = 1;
	for (int i = 1; i < b; i++) {
		for (int j = i; j <= n; j++) (dp[j] += dp[j - i]) %= m;
	}
	for (int i = 1; i < b; i++) {
		for (int j = i; j <= n; j++) {
			p[i][j] = p[i][j - i];
			if (j >= b) (p[i][j] += p[i - 1][j - b]) %= m;
		}
	}
	int res = 0;
	for (int j = 0; j <= n; j++) {
		int cur = 0;
		for (int k = 0; k < b; k++) (cur += p[k][n - j]) %= m;
		(res += 1LL * dp[j] * cur % m) %= m;
	} cout << res;
}
```

实际上，计算分拆数有一个亚线性复杂度的做法，即使用 Hardy-Ramanujan-Rademacher 公式。由于这个东西太过于复杂，这里只给出一个[博客链接](https://travorlzh.github.io/2023/07/16/integer-partitions.html)。

### *AT_abc221_h [ABC221H] Count Multiset

这是一个有限制条件的 $k$ 部分拆数问题。我们考虑容斥掉不合法的方案。

考虑高维容斥，我们只容斥掉恰有 $m+1$ 个 $1$ 的分拆，修改一下 $k$ 部分拆数的递推式：

$p(n,k)=p(n-1,k-1)+p(n-k,k)-p(n-k,k-m-1)$仿照 $p(n-k,k)$ 的计数意义，将所有部分减去 $1$ 以后结尾的所有 $1$ 会被删掉，所以剩余部分为 $k-(m+1)$ 个。复杂度 $O(n^2)$。

```cpp
const int N = 5005;
int n, m;
mint p[N][N];

void _main() {
	cin >> n >> m;
	p[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= i; j++) {
			p[i][j] = p[i - 1][j - 1] + p[i - j][j];
			if (j >= m + 1) p[i][j] -= p[i - j][j - m - 1];
		}
	}
	for (int i = 1; i <= n; i++) cout << p[n][i] << '\n';
}
```

### *P5824 十二重计数法

**注意：本文只给出每小问的答案，并不讲解多项式科技优化 $k$ 部分拆数计算的方法。**

$\text{V}$ 和 $\text{XI}$：盒子相同，每个盒子最多一个球：纯诈骗。若 $n >m$ 答案为 $a_5=a_{11}=0$，否则合法方案没区别，$a_5=a_{11}=1$。复杂度 $O(1)$。

$\text{I}$：球不同，盒子不同：基础乘法原理，答案为 $a_1=m^n$。复杂度 $O(\log n)$。

$\text{II}$ 和 $\text{VIII}$：盒子不同，每个盒子最多一个球：按顺序列出每个球所属盒子的编号。如果球不同编号是有序的，否则无序。所以 $a_2=A_n^m,a_8=C^m_n$。复杂度 $O(n)$。

$\text{VII}$ 和 $\text{IX}$：球相同，盒子不同。对于 $\text{IX}$，盒子非空，见插板法例题 1，答案为 $a_9=C^{m-1}_{n-1}$；对于 $\text{VII}$，盒子可空，插板法例题 2，答案是 $a_7=C^{m-1}_{n+m-1}$。复杂度 $O(n)$。

$\text{VI}$：球不同，盒子相同，盒子非空：第二类 Stirling 数。答案为 $a_6=S(n,m)$。用通项公式做到 $O(n)$。

$\text{III}$：球不同，盒子不同，盒子非空：因为盒子不同，需要全排列一波，答案为 $a_3=m! \times S(n,m)$。同样用通项公式做到 $O(n)$。

$\text{X}$ 和 $\text{XII}$：球相同，盒子相同：$k$ 部分拆数板子，答案是 $a_{10}=p(n,m)$。要求盒子非空，给所有盒子先放一个即可，$a_{12}=p(n-m,m)$。复杂度 $O(n^2)$，可以用多项式科技做到 $O(n \log n)$。

$\text{IV}$：球不同，盒子相同：类似 Bell 数，枚举有 $i$ 个空盒，答案为

$a_4=\sum_{i=0}^{m} S(n,m)$复杂度 $O(n^2)$，同样也可以多项式科技做到 $O(n \log n)$，还可以用单个 Bell 数的做法推式子做到 $O(n)$。

## 17. 计数杂项

## 17.1 排列计数

排列计数问题往往需要设计一个计数 DP。这类题目的 DP 状态一般设 $dp_{i, \cdots}$ 表示当前需要放入第 $i$ 个数的方案数，然后根据需要添加维度。在转移时，往往要从**插入 / 填入**角度分类讨论 $i$ 带来的贡献，并根据乘法或加法原理合并答案。

## 17.2 图论计数

图论计数问题一般是对特定的图结构进行计数。在计数时，最关键的要求是找到目标图的特定结构进行刻画。如果刻画比较困难，可以考虑弱一些的条件然后使用容斥解决。一些题目还要配合子集反演、二项式反演、集合幂级数、多项式科技等。下面是一些图论计数的结论。

## 17.3 例题

前半部分是排列计数，后半部分是图论计数。

### P2401 不等数列

观察数据范围可以发现是一个 $O(nk)$ 的 dp，设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个小于号的方案数。分类讨论：

1. 若放在最左边，会多一个大于号，从 $dp_{i-1,j}$ 转移；
2. 若放在最右边，会多一个小于号，从 $dp_{i-1,j-1}$ 转移；
3. 若插入到小于号之前，因为数字 $i$ 是最大的，所以小于号变为大于号，而前面是一个小于号，因此是多了一个大于号，从 $j \times dp_{i-1,j}$ 转移；
4. 若插入到大于号之前，同理可得转移为 $(i-j-1) \times dp_{i-1,j-1}$。

由加法原理得：

$dp_{i,j}=(j+1) \times  dp_{i-1,j} +(i-j) \times dp_{i-1,j-1}$至此本题在 $O(nk)$ 内解决。边界为 $dp_{i,0}=1$。

```cpp
const int N = 1005;
int n, k;
mint dp[N][N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	for (int i = 2; i <= n; i++) {
		dp[i][0] = 1;
		for (int j = 1; j <= min(i, k); j++) {
			dp[i][j] = dp[i - 1][j] * (j + 1) + dp[i - 1][j - 1] * (i - j);
		}
	} cout << dp[n][k];
}
```

### P6323 [COCI 2006/2007 #4] ZBRKA

还是设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个逆序对的方案数。考虑插入在 $i-1$ 的全排列中插入 $i$ ，枚举增加了多少逆序对 $k$，则有

$dp_{i,j} = \sum_{k=0}^{\min(i-1,j)} dp_{i-1,j-k}$直接做是 $O(nk^2)$ 的。注意到 $dp_{i,j}$ 为同一行 $dp_{i-1}$ 连续区间的和，用前缀和优化即可。考虑求 $j-k$ 的范围，发现 $j-k \in [\max(0, j-i+1), j]$。边界是 $dp_{i,0}=1$。

```cpp
const int N = 1e3 + 5;
int n, k;
mint dp[N][10005], pre[N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	fill(pre + 1, pre + k + 2, 1);
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= k; j++) dp[i][j] = pre[j + 1] - pre[max(0, j - i + 1)];
		pre[0] = 0;
		for (int j = 1; j <= k; j++) pre[j + 1] = pre[j] + dp[i][j];
	}
	cout << dp[n][k];
}
```

三倍经验：[P1521](https://www.luogu.com.cn/problem/P1521)、[P2513](https://www.luogu.com.cn/problem/P2513)。

### *P7967 [COCI 2021/2022 #2] Magneti

好像这种问题叫做连续段 dp。

DP 题套路先对 $r_i$ 排序简化问题。仍然设 $dp_{i,\cdots}$ 表示当前需要放入第 $i$ 个磁铁的方案数。考虑加维，经过尝试发现空位要是单独一维，连通块也是单独一维。这里的连通块是一个不能再插入磁铁的磁铁连续段。因此，设 $dp_{i,j,k}$ 表示当前需要放入第 $i$ 个磁铁，分成 $j$ 个连通块，占用掉 $k$ 个空位的方案数。

考虑插入 $i$ 并分类讨论：

1. 若第 $i$ 个磁铁单独成为新的块，则从 $dp_{i-1,j-1,k-1}$ 转移；
2. 若第 $i$ 个磁铁放在第 $j$ 个连通块端点，则从 $2j \times dp_{i-1,j,k-r_i}$ 转移。
3. 若第 $i$ 个磁铁将两个连通块合并为一个，则从 $j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$ 转移。

于是状态转移方程为：

$dp_{i,j,k}=dp_{i-1,j-1,k-1}+2j \times dp_{i-1,j,k-r_i}+j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$由此可以求出所有磁铁只形成一个连通块且长度为 $i$ 的方案数 $dp_{n,1,i}$，则根据插板法，将 $l-i$ 个空插到连通块中，答案为

$\sum_{i=1}^{l} dp_{n,1,i} \times C_{l-i+n}^{n}$时空 $O(n^2l)$，使用逆元法求组合数。边界为 $dp_{0,0,0}=1$。

```cpp
const int N = 1e4 + 5;
mint fac[N], ifac[N], dp[55][55][N];

mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

int n, l, r[N];

void _main() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> l;
	for (int i = 1; i <= n; i++) cin >> r[i];
	sort(r + 1, r + n + 1);
	dp[0][0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= l; k++) {
				dp[i][j][k] = dp[i - 1][j - 1][k - 1];
				if (k >= r[i]) dp[i][j][k] += dp[i - 1][j][k - r[i]] * 2 * j;
				if (k >= 2 * r[i] - 1) dp[i][j][k] += dp[i - 1][j + 1][k - 2 * r[i] + 1] * j * (j + 1);
			}
		}
	}
	mint res = 0;
	for (int i = 1; i <= l; i++) res += dp[n][1][i] * C(l - i + n, n);
	cout << res;
}
```

### *AT_code_festival_2017_qualc_f Three Gluttons

思路来自[第一篇题解](https://www.luogu.com.cn/article/8v8z4sbf)。

显然题目中所给的限制没有什么性质，考虑找到一个充要条件对其进行刻画然后计数 DP。

时光倒流，如果 A, B, C 三人最后选择的是 $x_1,y_1,z_1$，只有 $[z_1,x_1,y_1]$ 和 $[z_1,y_1,x_1]$ 符合要求，因为 C 必须先选走 $z_1$，选法为 $1 \times 2 = 2$ 种。

反推一次，如果选择变成了 $x_2,y_2,z_2$，$z_2$ 必须被 C 先选择，则根据乘法原理，$x_2,y_2$ 的选法为 $4 \times 5=20$ 种。

数学归纳法，当反推到第 $i$ 次时的方案数为 $(3i-2)(3i-1)$。因此，对于一个合法排列，对应选择序列的方案数为

$\prod_{i=1}^n (3i-2)(3i-1)$因此，我们只要找到合法排列的数目，乘上这个东西得到答案即可。对于已知的 $a,b,c$ 三个排列，我们这样刻画合法的充要条件：

- $a,b,c$ 内部元素不重，$\forall i$，$a_{i_t},b_{j_t},c_{k_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\} \cup \{c_1 \sim c_{k_t}\}$ 出现且仅出现一次。

因为 $c$ 未知，假如对 C 的选择序列 $x$ 有办法计数，那么只要发现 $c$ 与 $x$ 的映射关系就可以对排列计数。可以得到 $\exists c, c \to x$ 的充要条件是：

- $x$ 元素不重，$a_{i_t},b_{j_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现且仅出现一次，$x_t$ 未在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现。

设当前为第 $t$ 位，不能成为 $x_t$ 的数有：

- $u \in [t+1,n]$ 的 $a_{i_u},b_{j_u},c_{k_u}$。
- $x \in \{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$。

容易发现这两个集合无交集，剩下 $3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$ 个数均能填入其中。

考虑排列计数 DP，设 $dp_{t,i,j}$ 表示 $i_t=i, j_t=j$ 的方案数，从填入角度考虑 $t$ 位置的贡献即可。转移方程形如

$dp_{t,i,j}=\sum_{i'<i,j'<j} dp_{t-1,i',j'} \times (3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|)$直接转移复杂度 $O(n^6)$。

注意到不合法的数目可以预处理出来，设 $x_{i,j}=|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$，对 $x_i$ 作前缀和可以直接查询。复杂度 $O(n^4)$。

注意到每次转移形如一个矩形求和，考虑动态地对 $dp_{i,j}$ 作二维前缀和。复杂度 $O(n^3)$。

```cpp
const int N = 405;
int n, a[N], b[N], x[N][N];
mint dp[N][N][N];
bool vis[N], va[N][N], vb[N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	for (int i = 1; i <= n; i++) {
		vis[a[i]] = true, x[i][0] = i;
		for (int j = 1; j <= n; j++) x[i][j] = x[i][j - 1] + !vis[b[j]];
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= i; j++) va[i][a[j]] = true, vb[i][b[j]] = true;
	}
	for (int i = 0; i <= n; i++) fill(dp[0][i], dp[0][i] + n + 1, 1);
	for (int t = 1; t <= n / 3; t++) {
		for (int i = t; i <= n; i++) {
			for (int j = t; j <= n; j++) {
				if (!va[i][b[j]] && !vb[j][a[i]]) dp[t][i][j] = dp[t - 1][i - 1][j - 1] * (3 * t - x[i][j]);
				dp[t][i][j] += dp[t][i - 1][j] + dp[t][i][j - 1] - dp[t][i - 1][j - 1];
			}
		}
	}
	mint res = dp[n / 3][n][n];
	for (int i = 1; i <= n / 3; i++) res *= (3 * i - 2) * (3 * i - 1);
	cout << res;
}
```

### CF11D A Simple Task

无向图简单环计数。

注意到 $n \le 19$，考虑状压 DP。设 $dp_{S,u}$ 表示当前经过了 $S$ 中的点，$u$ 为当前位置时的路径条数。

直接做会算重。考虑使用[串珠子](https://www.luogu.com.cn/problem/P5933)的 trick，钦定起点为当前走过的点中编号最小的点。体现在二进制中就是 $s=\operatorname{lowbit}(S)$。枚举 $u \to v$ 边，如果 $v$ 比 $S$ 中最小点还小则不合法。否则分类讨论：

- 若 $v \notin S$，直接转移：$dp_{S \cup \{v\},v} \gets dp_{S,u}$。
- 若 $v \in S$ 且 $v=\operatorname{lowbit}(S)$，则构成一个环，答案加上 $dp_{S,u}$。
- 否则，$v$ 对当前状态无贡献。

特别注意，这样计数会算上重边构成的二元环，还会把多元环算两次，最后的答案应该是 $\dfrac{ans-m}{2}$。复杂度 $O(n^22^n)$。

```cpp
const int N = 20;
int n, m, u, v, g[N][N];
long long f[N][1 << N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		g[u][v] = g[v][u] = 1;
	}
	for (int i = 1; i <= n; i++) f[i][1 << (i - 1)] = 1;
	long long res = 0;
	for (int s = 1; s < (1 << n); s++) {
		for (int u = 1; u <= n; u++) {
			if (!(s >> (u - 1) & 1)) continue;
			for (int v = 1; v <= n; v++) {
				if (!g[u][v]) continue;
				if ((s & -s) > (1 << (v - 1))) continue;
				if (s >> (v - 1) & 1) {
					if ((s & -s) == (1 << (v - 1))) res += f[u][s];
				} else {
					f[v][s | (1 << (v - 1))] += f[u][s];
				}
			}
		}
	}
	cout << (res - m) / 2;
}
```

### P1989 无向图三元环计数

传统做法是将点重标号为 $p_1,p_2,p_3,\cdots,p_n$，满足 $d_x <d_y \Leftrightarrow p_x<p_y$，其中 $d$ 为度数。

此时有一个重要的性质：$\forall u \to v$，满足 $p_y >p_x$ 的点至多只有 $\sqrt{2m}$ 条。证明考虑反证，若超过 $\sqrt{2m}$，则出点度数均 $>\sqrt{2m}$，总度数大于 $\sqrt{2m}$，与握手定理矛盾。

重定向，仅保留 $p_x<p_y$ 的 $(u,v)$变成有向边。则可以直接枚举并计数：枚举 $u$，将 $u$ 的出点打上标记，再枚举所有打上标记的点 $v$ 的所有出点 $w$，若 $w$ 也被标记，则发现三元环 $(u,v,w)$。

复杂度 $O(m\sqrt{m})$，并且可以发现三元环的数目上界为 $O(m\sqrt{m})$ 级别。

```cpp
const int N = 1e5 + 5;
int n, m, deg[N], tag[N];
pair<int, int> e[N << 1];
vector<int> g[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> e[i], deg[e[i].first]++, deg[e[i].second]++;
	auto f = [&](int x, int y) -> bool {return deg[x] == deg[y] ? x < y : deg[x] < deg[y];};
	for (int i = 1; i <= m; i++) {
		if (f(e[i].first, e[i].second)) g[e[i].first].emplace_back(e[i].second);
		else g[e[i].second].emplace_back(e[i].first);
	}
	int res = 0;
	for (int u = 1; u <= n; u++){
		for (int v : g[u]) tag[v] = u;
		for (int v : g[u]) {
			for (int w : g[v]) res += tag[w] == u;
		}
	} cout << res;
}
```

### P10982 Connected Graph

考虑高维容斥，设 $g_n$ 为 $n$ 个点有标号图的方案数，$f_n$ 为有标号且连通的方案数。

因为 $n$ 个点的图最多有 $C_{n}^2$ 条边，每条边都可以选与不选，所以

$g_n=2^{C_n^2}$考虑如何刻画连通图的性质。钦定一个节点，枚举其所属连通块的大小 $i$，从剩下 $n-1$ 个点选择 $i-1$ 个组成一个新连通块。于是

$f_n=g_n-\sum_{i=1}^{n-1} C_{n-1}^{i-1} f_i g_{n-i}$复杂度 $O(n^2)$。可以多项式科技优化到 $O(n \log^2 n)$。

```cpp
const int N = 1005;
int n;
mint f[N + 5], g[N + 5], fac[N + 5], ifac[N + 5];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 1; i <= n; i++) g[i] = mint(2).pow(C(i, 2).val);
	f[1] = 1;
	for (int i = 2; i <= n; i++) {
		f[i] = g[i];
		for (int j = 1; j < i; j++) f[i] -= C(i - 1, j - 1) * f[j] * g[i - j];
	} cout << f[n];
}
```

### *P6596 How Many of Them

tourist 的神仙题。前置知识：无向图连通性的有关概念和定理。以下是蓝书做法。

设 $f_{i,j}$ 表示点数为 $i$，割边数为 $j$ 的无向连通图数目。

考虑枚举 $1$ 号点所在的边双连通分量的大小 $k$。从 $i-1$ 个节点中选出 $k$ 个构成边双，方案数是 $f_{k,0} \times C_{i-1}^{k-1}$ 乘上其他部分的贡献。

设 $g_{i,j,k}$ 表示点数为 $i$，割边数为 $j$，有 $k$ 个连通块的无向图数目。则对于 $f_{i,j}$，去掉边双以后剩下 $g_{i-k,j-x,x}$ 的贡献，其中 $x$ 是枚举的量，表示剩下的图中被分成了 $x$ 个连通块。每个连通块与边双形成 $x$ 条割边，所以还需要凑出 $j-x$ 条割边。由于这个边双有 $k$ 个点，每个节点都有 $k$ 种选择，贡献还要乘上 $k^x$。因此

$f_{i,j}=\sum_{k=1}^{i-1} \left( f_{k,0} C_{i-1}^{k-1}\sum_{x=1}^{\min(i-k,j)} g_{i-k,j-x,x}k^x \right)$记 $h_i$ 表示点数为 $i$ 的无向连通图数目。用上一题的转移求出以后，作一个高维容斥得到

$f_{i,0}=h_i-\sum_{j=1}^{i-1} f_{i,j}$考虑 $g_{i,j,k}$ 的转移。为了取重，钦定标号最小点属于一个连通块，然后枚举该连通块的大小 $p$，割边数目 $q$。乘上选法，贡献为 $f_{p,q} C_{i-1}^{p-1}$。再从连通块中找到一个节点连向边双，有 $p$ 种方案。最后讨论图中其他部分，得到 $g_{i-p,j-q,k-1}$。最终得到转移：

$g_{i,j,k}=\sum_{p=1}^i \sum_{q=0}^j f_{p,q} C_{i-1}^{p-1} p g_{i-p,j-q,k-1}$注意到 $n$ 个点的图最多 $n-1$ 条割边，所以 $m$ 实际上与 $n$ 同阶。总复杂度 $O(n^4)$。

由于本题的转移太过复杂，本人试图对 $f,g$ 都记搜转移，但写挂了。于是用了题解里仅记搜 $g$ 的写法。

```cpp
const int N = 55;
int n, m;
mint fac[N], ifac[N], f[N][N], g[N][N][N], h[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint G(int i, int j, int k) {
	if (k > i || (i != 0 && k == 0)) return g[i][j][k] = 0;
	if (g[i][j][k] != -1) return g[i][j][k];
	g[i][j][k] = 0;
	for (int p = 1; p <= i; p++) {
		for (int q = 0; q <= j; q++) {
			g[i][j][k] += f[p][q] * C(i - 1, p - 1) * p * G(i - p, j - q, k - 1);
		}
	} return g[i][j][k];
}

void _main() {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) fill(g[i][j], g[i][j] + N, -1);
	}
	cin >> n >> m;
	m = min(n, m);
	fac[0] = ifac[0] = 1, h[1] = 1, f[0][0] = 1, g[0][0][0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) {
		h[i] = mint(2).pow(C(i, 2).val);
		for (int j = 1; j < i; j++) h[i] -= C(i - 1, j - 1) * h[j] * mint(2).pow(C(i - j, 2).val);
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j < i; j++) {
			for (int k = 1; k < i; k++) {
				mint sum = 0;
				for (int x = 1; x <= min(i - k, j); x++) sum += G(i - k, j - x, x) * mint(k).pow(x);
				f[i][j] += f[k][0] * C(i - 1, k - 1) * sum;
			}
		}
		f[i][0] = h[i];
		for (int j = 1; j < i; j++) f[i][0] -= f[i][j];
	}
	mint res = 0;
	for (int i = 0; i <= m; i++) res += f[n][i];
	cout << res;
}
```

### [模拟赛] 竞赛图

> 给你一个 $n$ 个点的竞赛图，求有多少个点的子集 $S$ 满足 $S$ 的诱导子图是强连通的。答案包括空集。
>
> > 竞赛图是一个有向图，满足任意两个不同的点之间均存在且仅存在一条有向边相连。
> >
> > 一个图在点集 $S$ 的诱导子图的定义为：点集为 $S$，边集为所有两端的点都在 $S$ 中的边的子图。
>
> 多测，$n \le 24$，$T \le 10$。

暴力 Tarjan 可以做到单次 $O(n^22^n)$，和我一样没有前途。

根据竞赛图的性质，将一个强连通分量 $S$ 提出来后，$S$ 的补集与 $S$ 只存在内向边。

直接想状压。考虑类似刷表的做法，用强连通子集 $S$ 去转移其他自己，设出边集合的**交集**为 $E$，对于每个 $T \subseteq E$，$S \cup B$ 中来自 $B$ 的部分一定不强联通，将其标记即可。类似筛法，未被标记的都是强连通子集。

单次复杂度 $O(2^n)$，可以通过。

```cpp
const int N = 24;
int n, a[N], b[1 << N];
bitset<1 << N> vis;

void _main() {
	cin >> n;
	for (int i = 0; i < n; i++) {
		a[i] = 0;
		for (int j = 0, x; j < n; j++) {
			cin >> x;
			if (x) a[i] |= 1 << j;
		}
	}
	vis.reset(), b[0] = (1 << n) - 1;
	int res = 1;
	for (int s = 1; s < (1 << n); s++) {
		b[s] = b[s ^ lowbit(s)] & a[ctz(s)];
		if (vis[s]) continue;
		res++;
		for (int t = b[s]; t; t = (t - 1) & b[s]) vis[s | t] = 1;
	}
	cout << res << '\n';
}
```

### *P3349 [ZJOI2016] 小星星

子集反演例题。

考虑普通状压 DP，设 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号的集合为 $S$ 的方案数。可以得到转移

$dp_{u,i,S}=\prod_{(u,v)} \sum_{(i,j)} \sum_{T \subseteq S} dp_{v,j,T}$复杂度 $O(n^33^n)$，无法通过。注意到我们必须去掉 $T \subseteq S$ 的部分。

复杂度瓶颈在去重。因此，设 $f(S)$ 表示 $n$ 个点的映射恰好使用 $S$ 中所有点的方案数，$g(S)$ 表示 $n$ 个点的映射至多使用 $S$ 中所有点的方案数，显然 $g(S)=\sum_{T \subseteq S} f(T)$，由子集反演形式一

$f(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} g(T)$答案即 $f(U)$。只需对 $g(S)$ 计数即可。

用 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号至多使用 $S$ 中所有点的方案数，允许重复。在这个组合意义下，无需枚举子集就有

$dp_{u,i,S}=\prod_{(u,v), u,v \in S} \sum_{(i,j),i,j \in S} dp_{v,j,S}$于是 $g(S)=\sum_{i \in S} dp_{1,i,S}$。复杂度 $O(n^32^n)$。

细节上，这题答案没有取模，可以对 $2^{64}$ 取模，即 unsigned long long 自然溢出。

```cpp
const int N = 18;

int n, m, u, v, a[N][N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
uint64_t dp[N][N];
void dfs(int u, int fa, int s) {
	for (int i = 1; i <= n; i++) {
		if (s >> (i - 1) & 1) dp[u][i] = 1;
	}
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u, s);
		for (int x = 1; x <= n; x++) {
			if (!(s >> (x - 1) & 1)) continue;
			uint64_t cur = 0;
			for (int y = 1; y <= n; y++) {
				if (!(s >> (y - 1) & 1)) continue;
				if (a[x][y]) cur += dp[v][y];
			}
			dp[u][x] *= cur;
		}
	}
}

void _main() {
	cin >> n >> m;
	if (n == 1) return cout << 1, void();
	for (int i = 1; i <= m; i++) cin >> u >> v, a[u][v] = a[v][u] = 1;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	uint64_t res = 0;
	for (int s = 0; s < (1 << n); s++) {
		dfs(1, -1, s);
		uint64_t cur = 0;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) cur += dp[1][i];
		}
		res += ((n - popcount(s)) & 1) ? -cur : cur;
	} cout << res;
}
```

## 18. 概率论

概率期望在组合数学中是一个有用的工具，很多计数问题用总数乘概率来计算会简单很多。一些很难的计数 DP 变成期望 DP 以后状态转移会比较好推。

## 18.1 概念

- **样本空间**：一个集合 $U$，表示所有可能出现的单个事件。
- **随机事件**：若 $A \subseteq U$，则称 $A$ 是一个随机事件。若 $\exists \omega \in A,\omega$ 发生，则称事件 $A$ 发生。

根据随机事件的定义，我们可以得到必然事件与不可能事件的定义：

- 若随机事件 $A=U$，则 $A$ 为**必然事件**；
- 若随机事件 $A=\varnothing$，则 $A$ 为**不可能事件**。

若随机事件只有有限个，且每个随机事件出现的可能性相同，可以得到概率的古典定义：

- **概率**：记 $P(A)$ 为事件 $A$ 发生的概率，则 $P(A) =\dfrac{|A|}{|U|}$。

### 18.1.1 事件的运算

因为随机事件是一个集合，所以集合的交、并、补同样适用于随机事件。

- **事件的并**：记作 $A \cup B$，也记作 $A +B$，表示事件 $A,B$ 有一个发生。
- **事件的交**：记作 $A \cap B$，也记作 $AB$，表示事件 $A,B$ 同时发生。
- **事件的补**：记作 $U \setminus A$，表示事件 $A$ 不发生。

根据德摩根定律有

$$
U \setminus (A + B)=(U\setminus A) (U \setminus B)\\
U \setminus (AB)= (U \setminus A)+(U \setminus B)
$$

在计算概率时，我们可能会用到这条定理。

### 18.1.2 概率的性质

- 概率的加法原理：若 $A \cap B=\varnothing$，则 $P(A+B)=P(A)+P(B)$。
- 概率的乘法原理：若 $A,B$ 独立，$P(AB)=P(A)\times P(B)$。

根据概率的加法原理有 $P(A)+P(U \setminus A)=1$。请注意概率的加法 & 乘法原理的前提条件。

注意多个事件两两独立不是这些事件独立的充分条件，因此多个事件的乘法原理要慎重使用。

- 概率的单调性：若 $A \subseteq B$，则 $P(A) \le P(B)$。
- 概率的二元容斥：$P(A+B)=P(A)+P(B)-P(AB)$。这里不要求 $A,B$ 独立或者不交。

## 18.2 条件概率

在上文中，我们讨论过独立事件的概率运算原理。若 $A$ 的发生对 $B$ 的发生有影响，就要使用条件概率。

- 条件概率：若已知事件 $B$ 发生，则事件 $A$ 发生的概率为条件概率，记作 $P(A|B)$。

根据概率的乘法原理可得

$P(A|B)=\dfrac{P(AB)}{P(B)}$将这个公式变形可得 $P(AB)=P(B|A) \times P(A)$，得到贝叶斯公式

$P(A|B)=\dfrac{P(B|A)\times P(A)}{P(B)}$这是一个重要的概率原理。条件概率说明了当 $A,B$ 不独立时，概率的乘法原理如何变化。

## *18.3 期望

举一个例子，我们用随机变量 $X$ 表示掷出一枚骰子朝上的点数，则平均点数就是 $X$ 的期望：

$E(X)=1\times \dfrac{1}{6}+2\times \dfrac{1}{6}+3\times \dfrac{1}{6}+4\times \dfrac{1}{6}+5\times \dfrac{1}{6}+6\times \dfrac{1}{6}=3.5$因此，随着掷骰子次数的增大，向上的点数均值应当趋近于 $3.5$。

通过这个例子可以发现，期望就是随机变量输出值的加权平均数，权重为 $P(X=i)$。形式化地，定义 $X$ 的期望为

$E(X) =\sum P(X=i) \times i$根据乘法分配律可得期望的线性性：$E(aX+bY)=aE(X)+bE(Y)$。这是一个很重要的性质，也是期望可以递推计算的理论依据。

## *18.4 概率分布

伯努利试验：一场试验仅有 $1$ 或 $0$ 两种可能，$1$ 表示成功，$0$ 表示失败，设成功的概率为 $p$，可得失败概率为 $1-p$。

1. 两点分布：进行 $1$ 次伯努利试验，成功概率为 $p$，期望值为 $E(X)=p \times 1+(1-p) \times 0=p$。
2. 几何分布：设得到一次成功所需的实验次数为 $X$，则第 $i$ 次才能得到成功的概率为

$P(X=i)=(1-p)^{i-1}p$期望值为 $E(X)=\dfrac{1}{p}$，证明：

$$
\begin{aligned}
E(X)&=\sum_{i=1}^{\infty} P(X=i) \times i\\
&=\sum_{i=1}^{\infty} i(1-p)^{i-1}p\\
&=\dfrac{p}{[1-(1-p)]^2}\\
&=\dfrac{1}{p}
\end{aligned}
$$

1. 二项分布：设进行 $n$ 次伯努利试验成功的次数为 $X$，则

$P(X=i) =C_n^i p^i (1-p)^{n-i}$不加证明地，$E(X)=np$。

1. 超几何分布：现有 $n$ 个产品，其中有 $k$ 个不合格，随机取出 $m$ 个送检，设不合格产品的数量为 $X$，则

$P(X=i)=\dfrac{C_k^i C_{n-k}^{m-i}}{C_n^m}$同样不加证明地，$E(X)=\dfrac{mk}{n}$。

## 18.5 例题

我们先给出概率论的习题，然后讲解利用概率解计数问题的方法。

### P2719 搞笑世界杯

这题有两种做法。我们先来说比较简单的概率 DP，就是设 $dp_{i,j}$ 表示已经售出了 $i$ 张 A 类票，$j$ 张 B 类票的概率。根据概率的加法原理

$dp_{i,j}=\dfrac{dp_{i-1,j}+dp_{i,j-1}}{2}$边界是 $dp_{i,0}=dp_{0,1}=1.0$。复杂度 $O(n^2)$。

```cpp
const int N = 1300;
int n;
double dp[N][N];

inline void _main() {
	cin >> n; n >>= 1;
	for (int i = 2; i <= n; i++) dp[0][i] = dp[i][0] = 1;
 	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) dp[i][j] = (dp[i - 1][j] + dp[i][j - 1]) / 2;
	} cout << fixed << setprecision(4) << dp[n][n];
}
```

第二种做法是数学推导，设事件 $A$ 为最后两张不同，则前 $2n-2$ 张中有 $n-1$ 张 A，$n-1$ 张 B，根据概率的乘法原理得

$P(A)=\dfrac{C_{2n-2}^{n-1}}{2^{2n-2}}$一边循环一边求值即可，复杂度 $O(n)$。

```cpp
int n;
void _main() {
	cin >> n; n >>= 1;
	double res = 1.0;
	for (int i  = 1; i < n; i++) res *= 1.0 * (i + n - 1) / (i * 4);
	cout << fixed << setprecision(4) << 1.0 - res;
}
```

### P1297 [国家集训队] 单选错位

令 $a_{n+1}=a_1$，对于 $a_i$ 和 $a_{i+1}$ 分类讨论：

- 若 $a_i=a_{i+1}$，做对的概率为 $\dfrac{1}{a_i}$。
- 若 $a_i>a_{i+1}$，问题分步，首先有 $\dfrac{a_{i+1}}{a_i}$ 的概率让随机到的答案在 $[1,a_{i+1}]$ 中，然后还有 $\dfrac{1}{a_{i+1}}$ 的概率选中正解。根据概率的乘法原理，二者相乘得 $\dfrac{1}{a_i}$。
- 若 $a_i<a_{i+1}$，同理有 $\dfrac{a_i}{a_{i+1}}$ 的概率使得正确答案在 $[1,a_i]$ 中，然后概率的乘法原理得 $\dfrac{1}{a_{i+1}}$。

根据期望的定义式，求和即可：

$\sum_{i=1}^{n} \dfrac{1}{\max(a_i,a_{i+1})}$```cpp
const int N = 1e7 + 5;
int n, A, B, C, a[N];

void _main() {
	cin >> n >> A >> B >> C >> a[1];
	if (n == 1) return cout << "1.000", void();
	for (int i = 2; i <= n; i++) a[i] = (1LL * a[i - 1] * A + B) % 100000001;
	for (int i = 1; i <= n; i++) a[i] = a[i] % C + 1;
	double res = 0.0;
	a[n + 1] = a[1];
	for (int i = 1; i <= n; i++) res += 1.0 / max(a[i], a[i + 1]);
	cout << fixed << setprecision(3) << res;
}
```

### *[模拟赛] 概率

> 有一个长为 $2n$ 的非负整数序列，每个数字在 $[0,m]$ 中随机均匀分布。求前 $n$ 个数的和 $s_1$ 大于后 $n$ 个数的和 $s_2$ 的概率。对给出的质数 $p$ 取模。
>
> 多测，$T,n,m \le 2000$。

开赛 3.5h 不会 T2，最后 30min 冲出这道 T4 翻盘。

**概率转计数**。总数为 $tot=(m+1)^{2n}$。根据对称性，$s_1 < s_2$ 的方案数等于 $s_1 > s_2$ 的方案数。只需统计 $s_1=s_2$ 的方案数 $ans$，答案即为 $\dfrac{tot-ans}{2tot}$。

我们需要求

$\sum_{k=1}^n x_k=\sum_{k=1}^n y_k$令 $w_k=m-y_k \in [0,m]$，且

$\sum_{k=1}^n=\sum_{k=1}^n (m-w_k)=nm-\sum_{k=1}^n w_k$移项，问题转化为不定方程

$x_1+x_2+\cdots+x_{2n}=nm$的非负整数解数目。要求 $0 \le x_i \le m$。

令 $j=nm-i(m+1)$，根据 9.3.2 的问题四得到答案为

$ans=\sum_{i=0}^{2n} (-1)^i C_{2n}^i C_{2n+j-1}^{j}$复杂度 $O(Tn)$。

```cpp
const int N = 2005, M = 5e6;
int p, q, n, m;
mod32 fac[M + 5], ifac[M + 5];
mod32 C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void ask() {
	mod32 tot = mod32(m + 1).pow(2 * n), res = 0;
	for (int i = 0; i <= 2 * n; i++) {
		int j = n * m - i * (m + 1);
		if (j < 0) break;
		if (i & 1) res -= C(2 * n, i) * C(2 * n + j - 1, j);
		else res += C(2 * n, i) * C(2 * n + j - 1, j);
	} cout << (tot - res) / 2 / tot << '\n';
}

void _main() {
	cin >> p >> q, mod32{}.set_mod(p);
	fac[0] = 1;
	for (int i = 1; i <= M; i++) fac[i] = fac[i - 1] * i;
	ifac[M] = ~fac[M];
	for (int i = M - 1; i >= 0; i--) ifac[i] = ifac[i + 1] * (i + 1);
	while (q--) cin >> n >> m, ask();
}
```

### *P1654 OSU!

用 $dp_{1/2/3,i}$ 表示当连续的 $k$ 个 $1$ 可以贡献 $k^{1/2/3}$ 的分数时的期望。

不难发现，对于 $dp_{1,i}$，这个位置有 $p_i$ 的概率成为 $1$ 从而接上前面，则

$dp_{1,i}=(dp_{1,i-1}+1) \times p_i$考察 $E(X^2)$。因为 $E(X^2) \ne E^2(x)$，经过思考想到通过 $E((X-1)^2)$ 转移。有 $E((X-1)^2)=E(X^2-2X+1)$，根据期望的线性性

$E(X)=E((X-1)^2)+2E(X)+1$写成 DP 方程是

$dp_{2,i}=(dp_{2,i-1}+2 \times dp_{1,i-1}+1) \times p_i$同理我们有 $E((X-1)^3)=E(X^3-3X^2-3X+1)$，写出转移

$dp_{3,i}=dp_{3,i}+(3 \times dp_{2,i-1}+3 \times dp_{1,i}+1) \times p_i$至此本题在 $O(n)$ 复杂度内解决。

```cpp
const int N = 1e5 + 5;
int n;
double p[N], dp1[N], dp2[N], dp3[N];

inline void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) {
		dp1[i] = p[i] * (dp1[i - 1] + 1);
		dp2[i] = p[i] * (dp2[i - 1] + 2 * dp1[i - 1] + 1);
		dp3[i] = dp3[i - 1] + p[i] * (3 * dp2[i - 1] + 3 * dp1[i - 1] + 1);
	} cout << fixed << setprecision(1) << dp3[n];
}
```

### *P4484 [BJWC2018] 最长上升子序列

前置知识：状态压缩，位运算技巧。不会请移步第 18 章。

**期望转计数**。只要求出所有 LIS 长度的和除以 $n!$ 即可。

注意到 $2^{28}$ 不算太大，考虑状压 DP 结合计数。有一个神奇的状压方法：

令 $f_i$ 表示以 $i$ 结尾的 LIS 长度，记 $f_i$ 的前缀最大值为 $g_i$，即 $g_i=\max_{j=1}^i f_i$。

注意到，$g_i$ 单调不降，且差分之后的序列仅由 $0,1$ 组成。可以对这个差分序列状态压缩。

设 $dp_{i,j}$ 表示考虑 $1 \sim i$ 的一个排列，$g$ 的差分在二进制表示下为 $j$ 的 LIS 总长度。

记差分序列为 $d_i$。当在 $i,i+1$ 之间插入一个新数时，根据状态这个数一定是当前最大值，于是 $g_i=1+\max g_j$，故 $d_{i+1}=1$。枚举插入的位置 $p$，需将 $d_p \gets 0$。

转移方程为

$dp_{i,j}=\sum dp_{i-1,j'}$答案用状态为 $j$ 的方案数乘上 LIS 长度即可，也就是 $\operatorname{popcount}(j)$。答案为

$\dfrac{1}{n!} \sum_{j} dp_{n,j} \times \operatorname{popcount}(j)$复杂度为 $O(n^2 2^n)$，需要滚动数组优化。可以通过 $n \le 24$ 的数据。代码从深进上抄的，是刷表法。

```cpp
const int N = 1.4e7 + 5;
int n;
mint dp[2][N];

void _main() {
	cin >> n;
	dp[1][0] = 1;
	for (int i = 1, st = 0; i < n; i++, st ^= 1) {
		fill(dp[st], dp[st] + (1 << i), 0);
		for (int j = 0; j < (1 << (i - 1)); j++) {
			dp[st][j << 1] += dp[st ^ 1][j];
			for (int k = i - 1, pos = -1; k >= 0; k--) {
				int nxt = ((j >> k) << (k + 1)) | (1 << k) | (j & ((1 << k) - 1));
				if (j >> k & 1) pos = k;
				if (pos != -1) nxt ^= (1 << (pos + 1));
				dp[st][nxt] += dp[st ^ 1][j];
			}
		}
	}
	mint res = 0;
	for (int i = 0; i < (1 << (n - 1)); i++) res += dp[n & 1][i] * (popcount(i) + 1);
	for (int i = 1; i <= n; i++) res /= i;
	cout << res;
}
```

注意到这题输入只有一个 $n$，在本机上跑个打表即可，大概 5min 就打完了。

### *P1850 [NOIP 2016 提高组] 换教室

注意到 $v \le 300$，先跑 $O(v^3)$ 的 Floyd 求一下全源最短路。

大力期望 DP。设 $dp_{0/1,i,j}$ 表示考虑到第 $i$ 个教室，已经换了 $j$ 次，这一次换不换的期望代价。容易写出转移式子：

$$
\begin{aligned}
dp_{0,i,j}&=\min(dp_{0,i-1,j}+d_{s_{i-1},s_i},dp_{1,i-1,j}+(1-k_{i-1})d_{s_{i-1},s_i}+k_{i-1}d_{t_{i-1},s_i})\\
dp_{1,i,j}&=\min(dp_{0,i-1,j-1}+(1-k_i)d_{s_{i-1},s_i}+k_i d_{s_{i-1},t_i},dp_{1,i-1,j-1}+(1-k_{i-1})(1-k_i)d_{s_{i-1},s_i}+(1-k_{i-1})k_i d_{s_{i-1},t_i}+k_{i-1}(1-k_i)d_{t_{i-1},s_i}+k_{i-1}k_id_{t_{i-1},t_i})
\end{aligned}
$$

复杂度 $O(v^3+n^2)$。唯一难点在于期望各种性质的熟练运用。

```cpp
const int N = 2005;
int n, m, v, e, x, y, w, s[N], t[N], dis[305][305];
double k[N], dp[2][N][N];
void floyd() {
	for (int k = 1; k <= v; k++) {
		for (int i = 1; i <= v; i++) {
			for (int j = 1; j <= v; j++) dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
		}
	}
}

void _main() {
	cin >> n >> m >> v >> e;
	for (int i = 1; i <= n; i++) cin >> s[i];
	for (int i = 1; i <= n; i++) cin >> t[i];
	for (int i = 1; i <= n; i++) cin >> k[i];
	memset(dis, 0x3f, sizeof(dis));
	for (int i = 1; i <= v; i++) dis[i][i] = 0;
	for (int i = 1; i <= e; i++) {
		cin >> x >> y >> w;
		dis[x][y] = dis[y][x] = min(dis[x][y], w);
	}
	floyd();
	for (int i = 0; i <= n; i++) fill(dp[0][i], dp[0][i] + n + 1, 1e18), fill(dp[1][i], dp[1][i] + n + 1, 1e18);
	dp[0][1][0] = dp[0][1][1] = dp[1][1][1] = 0;
	for (int i = 2; i <= n; i++) {
		for (int j = 0; j <= min(i, m); j++) {
			dp[0][i][j] = min(
				dp[0][i - 1][j] + dis[s[i - 1]][s[i]],
				dp[1][i - 1][j] + dis[s[i - 1]][s[i]] * (1 - k[i - 1]) + dis[t[i - 1]][s[i]] * k[i - 1]
			);
			if (j > 0) dp[1][i][j] = min(
				dp[0][i - 1][j - 1] + dis[s[i - 1]][s[i]] * (1 - k[i]) + dis[s[i - 1]][t[i]] * k[i],
				dp[1][i - 1][j - 1] + dis[s[i - 1]][s[i]] * (1 - k[i - 1]) * (1 - k[i]) + dis[s[i - 1]][t[i]] * (1 - k[i - 1]) * k[i] + dis[t[i - 1]][s[i]] * k[i - 1] * (1 - k[i]) + dis[t[i - 1]][t[i]] * k[i - 1] * k[i]
			);
		}
	}
	double res = 1e18;
	for (int j = 0; j <= min(n, m); j++) res = min({res, dp[0][n][j], dp[1][n][j]});
	cout << fixed << setprecision(2) << res;
}
```

### P11362 [NOIP2024] 遗失的赋值

这个做法来自本人已退役的同学 [zgy_123](https://www.luogu.com.cn/article/hewa7jrt)，在此膜拜 CMO 大神。

不合法的情况有两种：一种是一元限制发生冲突，一种是一元限制与二元限制冲突。对于第一种，开一个 std::map 判无解即可。

考虑用总数 $v^{2(n-1)}$ 乘上合法概率。可以发现 $d_j$ 在判完无解后就没用了。因为已知所有一元限制的位置，对于形如 `...???x?...?y???...` 的一段，设两个相邻一元限制的位置分别为 $l,r$。那么在 $r$ 位置一元限制与二元限制冲突当且仅当：

1. $\forall i \in [l,r)$，第 $i$ 条二元限制为 $(i,x_i)$。
2. 第 $r$ 条二元限制为 $(r,x')$，其中 $x' \ne x_r$。

除此之外，一定可以构造出合法方案。**计数转概率**，第一条的概率为 $p_1=\dfrac{1}{v^{r-l}}$，第二条的概率为 $p_2=\dfrac{v-1}{v}$。显然二者独立，根据概率的乘法原理，在 $r$ 位置冲突的概率为

$\dfrac{v-1}{v^{r-l+1}}$不冲突的概率用 $1$ 减掉即可。把位置排个序扫一遍，复杂度 $O(m \log m)$。

```cpp
const int N = 1e5 + 5;
int n, m, a[N], c, d;
mint v;
unordered_map<int, int> mp;

void _main() {
	mp.clear(), memset(a, 0, sizeof(int) * (m + 1));
	cin >> n >> m >> v;
	bool flag = true;
	for (int i = 1; i <= m; i++) {
		cin >> c >> d;
		if (mp.count(c)) {
			if (mp[c] != d) flag = false;
		} else {
			a[++a[0]] = c, mp[c] = d;
		}
	}
	if (!flag) return cout << 0 << '\n', void();
	sort(a + 1, a + a[0] + 1);
	mint res = v.pow(2 * (n - 1));
	for (int i = 2; i <= a[0]; i++) {
		int l = a[i - 1], r = a[i];
		res *= mint(1) - (v - 1) / v.pow(r - l + 1);
	} cout << res << '\n';
}
```

### *AT_agc030_d [AGC030D] Inversion Sum

**计数转概率**。注意到 $O(n^2)$ 是能过的。如果认为每个操作等概率执行或不执行，可以设 $dp_{i,j}$ 为当前时刻 $a_i > a_j$ 的**概率**。

那么答案就是 $2^m \sum_{i<j} dp_{i,j}$，也就是期望乘总数。现在我们考虑对于一次操作 $x,y$ 对第 $i$ 个位置造成的影响：

- 若 $i \ne x$ 且 $i \ne y$：则 $dp_{x,i} \gets \dfrac{dp_{x,i}+dp_{y,i}}{2}$。因为每次操作以后它有 $\dfrac{1}{2}$ 的概率继承原来的状态，还有 $\dfrac{1}{2}$ 的概率变成 $dp_{y,i}$ 的状态，根据概率的加法原理可得。剩下的 $dp_{y,i},dp_{i,x},dp_{i,y}$ 同理。

注意对于 $dp_{x,y}$ 也有转移为 $dp_{x,y} \gets \dfrac{dp_{x,y}+dp_{y,x}}{2}$，原理类似。复杂度 $O(n^2)$。

```cpp
const int N = 3005;
int n, m, a[N], x[N], y[N];
mint dp[N][N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= m; i++) cin >> x[i] >> y[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			if (a[i] > a[j]) dp[i][j] = 1;
		}
	}
	for (int k = 1; k <= m; k++) {
		for (int i = 1; i <= n; i++) {
			if (i == x[k] || i == y[k]) continue;
			dp[x[k]][i] = dp[y[k]][i] = (dp[x[k]][i] + dp[y[k]][i]) / 2;
			dp[i][x[k]] = dp[i][y[k]] = (dp[i][x[k]] + dp[i][y[k]]) / 2;
		}
		dp[x[k]][y[k]] = dp[y[k]][x[k]] = (dp[x[k]][y[k]] + dp[y[k]][x[k]]) / 2;
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = i + 1; j <= n; j++) res += dp[i][j];
	} cout << res * mint(2).pow(m);
}
```

## 19. 位运算

本来不打算讲的，但是发现 OI 里位运算的题也不少，所以开个新专题。

## 19.1 位运算常用性质

1. 由于异或是不进位加法，不退位减法，故 $x-y \le x \oplus y \le x + y$。
2. 按位考虑 $x,y$ 的异同，有 $x+y=(x\& y) +(x|y)$。
3. 异或是不进位加法，而 $2(x \& y)$ 又能够表示加法进位，因此 $x+y=(x \oplus y)+2(x \& y)$。
4. 对于常数 $x,n$，满足 $x \oplus i \le n$ 的 $i$ 形成的区间有 $O(\log n)$ 个。

## 19.2 位运算基础

让我们来考虑下列问题：

1. 定义 $\operatorname{lowbit}(x)$ 为 $x$ 最低位的 $1$ 及后面的 $0$ 组成的数。如何计算 $\operatorname{lowbit}(x)$ ？

A: 将 $x$ 二进制位全部取反再加一。设原来 $x$ 的二进制表示形如 `(...)10...0000`，全部取反可得 `[...]01...1111`，加一即为 `[...]10...0000`，且 `[...]` 与 `(...)` 内容全部相反，两数或之，得 $10...0000$，即 $\operatorname{lowbit}(x)$。由补码性质可得 `~x + 1 = -x`，因而代码可以这样写：

```cpp
constexpr int lowbit(int x) {return x & -x;}
```

这个函数在树状数组中有大用。还有一种方法是 $x-\operatorname{lowbit}(x)=x\& (x-1)$。

1. 定义 $\operatorname{popcount}(x)$ 为二进制下 $x$ 中 $1$ 的个数，如何计算 $\operatorname{popcount}(x)$？

A: 考虑每次减去它的  $\operatorname{lowbit}$，复杂度 $O(\log n)$。

```cpp
int popcount(int x) {
	int res = 0;
	for (; x; x -= lowbit(x)) res++;
	return res;
}
```

GNU C++ 提供了函数 `__builtin_popcount(x)`，这个函数的速度远快于上面代码，可视为 $O(1)$。另有函数 `__builtin_popcountll(x)` 来计算 `long long` 类型的 $\operatorname{popcount}$。

根据二维容斥有性质：$\operatorname{popcount}(a\&b)=\operatorname{popcount}(a)+\operatorname{popcount}(b)-\operatorname{popcount}(a| b)$。

1. 使用一个 $n$ 位的二进制整数 $s$ 压位表示一个集合，如何降序枚举其子集？

A: 先上代码：

```cpp
for (int i = s; i; i = (i - 1) & s);
```

降序获得下一个子集，其实就是将它的最低位 $1$ 置为 $0$，减去 $1$ 即可，但是这会导致其最低位的 $1$ 后所有的 $0$ 变成了 $1$。通过按位与上 $s$，可以将那些多余的 $1$ 与 $0$ 而抵消。

可以发现其复杂度为 $O(2^{\operatorname{popcount}(n)})$。

1. 考虑枚举 $\{0,1,2, \cdots, n-1 \}$ 的所有子集的所有子集，求复杂度？

A: 根据问题 3，枚举方法显然：

```cpp
for (int i = 0; i < (1 << n); i++) {
	for (int j = i; j; j = (j - 1) & i);
}
```

复杂度为 $O(3^n)$。我们根据组合数学知识来推导一下。考虑枚举每个子集中大小为 $i$ 的子集个数，则总数为

$\sum_{i=0}^{n-1} C_n^i 2^i=\sum_{i=0}^{n-1} C_n^i 2^i 1^{n-i}=(1+2)^n-1=O(3^n)$这里我们逆用了二项式定理。如果直接暴力复杂度为 $O(4^n)$，而这个低复杂度做法是状压 dp 的常用技巧。

1. 求 $\{0,1,2,\cdots,n-1\}$ 的所有子集的所有子集的元素和。即 $\sum_{T \subseteq S} \sum T$。

一个显然的想法是 $O(3^n)$ 地去做。事实上这个问题有 $O(n2^n)$ 的解决方案。

让我们思考一下：不用容斥原理的二维前缀和怎么做？

答案是对每一维分开求前缀和，如下：

```cpp
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) a[i][j] = a[i - 1][j] + a[i][j];
}
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) a[i][j] = a[i][j - 1] + a[i][j];
}
```

在维度很高的时候，这种做法比容斥的复杂度更低。对于子集求和问题，将 $n$ 位视为 $n$ 维跑高维前缀和：

```cpp
for (int i = 0; i < n; i++) {
    for (int s = 0; s < (1 << n); s++) {
        if (s >> i & 1) f[s] += f[s ^ (1 << i)];
    }
}
```

这个技巧叫做 SOS DP。它也是 FWT 等算法的基础。

## 19.3 例题

### P9451 [ZSHOI-R1] 新概念报数

分类讨论。设 $\operatorname{popcount}(a)=p$，则：

1. 若 $p \ge 3$，报告无解；
2. 若 $p \le 1$，直接输出 $a+1$，显然这样 $\operatorname{popcount(a+1)} \le 2$。
3. 若 $p=2$，找到 $a$ 二进制下最右侧的 $01$，然后改为 $10$ 即可。回顾一下问题 1，发现所求就是 $a+\operatorname{lowbit(a)}$。

代码：

```cpp
uint64_t a;

void _main() {
	cin >> a;
	int p = __builtin_popcountll(a);
	if (p >= 3) return cout << "No,Commander\n", void();
	if (p <= 1) cout << a + 1 << '\n';
	else cout << a + (a & -a) << '\n';
}
```

### P3908 数列之异或

普及一下这个结论：

$$
S(n)=\bigoplus_{i=1}^n i=\left\{\begin{matrix}
 n &  n \equiv 0 \pmod 4 \\
 1 &  n \equiv 1 \pmod 4 \\
 n+1 &  n \equiv 2 \pmod 4 \\
 0 &n \equiv 3 \pmod 4 
\end{matrix}\right.
$$

打个表可以发现。下面给出证明：

设 $k \in \mathbb{N^+}$。显然 $n=1,2,3,4$ 时 $S(n)$ 符合规律，用数学归纳法证明：

- 当 $n=4k$ 时，$S(n)=S(4k)=S(4k-1) \oplus 4k= 0 \oplus 4k=4k=n$。
- 当 $n=4k+1$ 时，$S(n)=S(4k+1)=S(4k) \oplus (4k+1)=4k \oplus (4k+1)=1$。
- 当 $n=4k+2$ 时，$S(n)=S(4k+2)=S(4k+1) \oplus (4k+2)=1 \oplus (4k+2)=1+4k+2=4k+3=n+1$。
- 当 $n=4k+3$ 时，$S(n)=S(4k+3)=S(4k+2)\oplus(4k+3)=(4k+3)\oplus(4k+3)=0$。

证毕。

### *[模拟赛] 哈基米哟南北绿豆

原题是 [AT_utpc2011_9](https://atcoder.jp/contests/utpc2011/tasks/utpc2011_9)，NOIP 模拟赛加强了并且放到 T1。鉴定为失心疯 Ad-hoc 题。

> 定义位多项式 $f(x)$ 是关于 $x$ 的中缀表达式，满足如下 BNF 规则：
>
> ```plaintext
> expr ::= "x" | num | ("(" "~" expr ")") | (expr op expr)
> op ::= "+" | "-" | "*" | "&" | "|" | "^"
> ```
>
> 各符号与 C++ 中的定义相同。`num` 为 32 位无符号整数，运算规则与 32 位整数一致，自然溢出。
>
> 给定 $n$ 组 $x_i,y_i$，判定是否存在位多项式 $f(x)$ 使得 $\forall 1 \le i\le n,f(x_i)=y_i$。
>
> 多测，$\sum n \le 3 \times 10^5$。

赛时瞪了 2h 大样例猜了个很离谱的结论过了。虽然我不知道为什么是对的。下面是讲题人做法。

注意到，它给了一堆多余的运算，比如或和异或都能用取反和与表示，减法可以用加法实现等等，但是没给除法和位移。大胆猜测这个东西有一些同余性质。

观察到，若 $x_i \equiv x_j \pmod {2^k}$，必有 $y_i \equiv y_j \pmod {2^k}$。因为位运算的性质是逐位的，满足同余的同加性、同乘性。容易发现这是 $f(x)$ 存在的必要条件。

证明充分性，这实际上是一个构造题。考虑根据 $x_i$ 的奇偶性分类构造再合并。由必要性得，$x_i$ 的奇偶性对应奇偶性相同的 $y_i$。设 $2 \mid x_i$ 时 $2 \mid (y_i-b_0)$，$2 \nmid x_i$ 时 $2 \mid (y_i-b_1)$，给出一个构造：

$f(x)=((x\& 1 ) \oplus 1) \times (2f_0(2x)+b_0)+(x\& 1)(2f_1(2x+1)+b_1)$于是我们证明了这个结论是充要的。现在有一个 $O(n^2)$ 的做法：枚举 $i,j$ 判 $\operatorname{lowbit}$。

从二进制位出发，枚举位 $k$，只需 $x_i,y_i$ 舍去 $k$ 以上的高位时一一对应。精细实现可以做到 $O(n \log V)$。赛时写的排序是 $O(n \log n \log V)$ 的。

```cpp
int n;
uint32_t x[N], y[N];
pair<uint32_t, uint32_t> mp[N];

void _main() {
	read(n);
	for (int i = 1; i <= n; i++) read(x[i], y[i]);
	uint32_t v = sub3();
	for (uint32_t k = 0; k < 32; k++) {
		for (int i = 1; i <= n; i++) mp[i].first = x[i] & ((1ULL << k) - 1), mp[i].second = y[i] & ((1ULL << k) - 1);
		sort(mp + 1, mp + n + 1);
		for (int i = 2; i <= n; i++) {
			if (mp[i].first == mp[i - 1].first && mp[i].second != mp[i - 1].second) return cout << "No\n", void();
		}
	} cout << "Yes\n";
}
```

### AT_abc365_e [ABC365E] Xor Sigma Problem

> **异或有三大思考方向：拆位、01-Trie、线性基。**

显然 $a \oplus b \oplus b =a$，所以考虑记录一个 $pre$ 数组记录前缀异或和。

则

$$
\begin{aligned}
\sum_{i=1}^{i<n} \sum_{j=i+1}^{j\le n} \bigoplus_{k=i}^{k \le j} a_k &=\sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} \bigoplus_{k=i}^{k \le j} a_k - \sum_{i=1}^{i\le n} a_i \\
&= \sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} pre_{i} \oplus pre_{j} - \sum_{i=1}^{i\le n} a_i
\end{aligned}
$$

其中 $\sum_{i=1}^{i\le n} a_i$ 可以 $O(n)$ 计算，重点是计算前面这部分。

考虑把每个数按二进制拆分，逐位记录贡献，统计异或后二进制位为 $1$ 的贡献。

$\sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} pre_{i} \oplus pre_{j}$ 的意思是两两异或，所以可以用乘法原理，枚举二进制位 $d$，再设 $pre$ 中有 $s_0$ 个二进制第 $d$ 位为 $0$ 的，有 $s_1$ 个二进制第 $d$ 位为 $1$ 的，枚举前缀异或 $j$，第 $i$ 位贡献为 $2^i s_{1-pre_j}$。

时间复杂度 $O(n \log w)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], pre[N];

void _main() {
	cin >> n;
	long long tot = 0;
	for (int i = 1; i <= n; i++) cin >> a[i], tot += a[i], pre[i] = pre[i - 1] ^ a[i];
	long long res = 0;
	for (int i = 27; i >= 0; i--) {
		int s[2] = {0, 0};
		for (int j = 1; j <= n; j++) {
			int u = pre[j - 1] >> i & 1, v = pre[j] >> i & 1;
			s[u]++, res += (1LL << i) * s[v ^ 1];
		}
	} cout << res - tot;
}
```

这个题代表了一类位运算问题的套路，就是按位考虑贡献。

### *P11651 [COCI 2024/2025 #4] Xor

还是按位考虑贡献，枚举当前位 $i$，答案的第 $i$ 位为 $1$ 当且仅当有奇数对 $(x,y)$ 满足 $a_x+a_y$ 第 $i$ 位为 $1$。

发现需要排除进位的影响。我们扔掉 $i+1$ 后面的位置，那么 $a_x+a_y \in [2^i,2^{i+1}-1]$ 是可以的，我们考虑进位的意义，就是 $a_x+a_y \in [3 \times 2^i, 2^{i+2}-1]$。可以容斥一下，统计出有多少对 $(x,y)$ 满足 $a_x+a_y \le 2^i$，以及 $2 \times 2^i$ 和 $3 \times 2^i$。精细实现可以做到 $O(n \log V)$。

具体地，考虑将 $a$ 排序后维护双指针 $i,j$，对于 $a_i +a_j \ge x$ 的情况不断缩减右端点并统计答案可以做到 $O(n)$。从高位向低位枚举 $i$，维护两个变长数组分别为舍掉第 $i+1$ 位和没有舍掉的，用类似归并排序的方法合并。这样做就优化掉了一个 log。

```cpp
const int N = 5e5 + 5;
int n, a[N];
long long solve(long long x) {
	long long res = 0;
	for (int i = 1, j = n; i <= n; i++) {
		while (a[i] + a[j] >= x && j >= 1) j--;
		res += n - max(i, j + 1) + 1;
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	sort(a + 1, a + n + 1);
	int res = 0;
	for (int i = 30; i >= 0; i--) {
		vector<int> x, y;
		for (int j = 1; j <= n; j++) {
			if (a[j] >> (i + 1) & 1) x.emplace_back(a[j] ^ (1 << (i + 1)));
			else y.emplace_back(a[j]);
		}
		merge(x.begin(), x.end(), y.begin(), y.end(), a + 1);
		long long v = solve(1LL << i) - solve(2LL * (1 << i)) + solve(3LL * (1 << i));
		if (v & 1) res |= 1 << i;
	} cout << res;
}
```

### *P5300 [GXOI/GZOI2019] 与或和

考虑拆位。以按位与为例，问题转化成：

- 给你一个 01 矩阵，求全为 $1$ 的子矩阵数目。$O(\log V)$ 组数据。

其实我们解决这个即可，因为总的矩阵数目为 $C_{n+1}^2 \times C_{n+1}^2$，减法原理简单算一算就能解决按位或。对于每一个点计算以它为右下角的子矩阵数目。求出二维数组 $b_{i,j}$ 表示上方有多少个连续的 $1$。根据木桶原理，没有贡献的点右边一定有一个更大的数，用单调栈维护即可。复杂度 $O(n^2 \log V)$。

```cpp
const int N = 1005;
int n, a[N][N], b[N][N], top, st[N];
mint calc(int d, int type) {
	for (int i = 1; i <= n; i++) b[1][i] = (a[1][i] >> d & 1) ^ type ^ 1;
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			int x = (a[i][j] >> d & 1) ^ type;
			b[i][j] = x ? 0 : b[i - 1][j] + 1;
		}
	}
	mint res = 0, cur = 0;
	for (int i = 1; i <= n; i++) {
		cur = 0, top = 0;
		for (int j = 1; j <= n; j++) {
			for (; top && b[i][st[top]] >= b[i][j]; top--) cur -= 1LL * b[i][st[top]] * (st[top] - st[top - 1]);
			cur += 1LL * b[i][j] * (j - st[top]), res += cur;
			st[++top] = j;
		}
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	mint x = 0, y = 0, tot = mint(n) * n * (n + 1) * (n + 1) / 4;
	for (int i = 0; i < 31; i++) {
		x += mint(2).pow(i) * calc(i, 1);
		y += mint(2).pow(i) * (tot - calc(i, 0));
	} cout << x << ' ' << y;
}
```

### P5390 [Cnoi2019] 数学作业

考虑拆位，分类讨论：

1. 所有数的第 $i$ 位都为 $0$：答案的第 $i$ 位只能为 $0$。
2. 有至少一个数第 $i$ 位为 $1$：选奇数个元素即可，共有 $2^{n-1}$ 种选法。

观察到，这个分类讨论的过程就是求按位或的过程。因此答案就是按位或和乘上 $2^{n-1}$。

```cpp
int n, a;
void _main() {
	cin >> n;
	int x = 0;
	for (int i = 1; i <= n; i++) cin >> a, x |= a;
	cout << mint(2).pow(n - 1) * x << '\n';
}
```

### P4310 绝世好题

$O(n^2)$ 暴力 dp 显然。就是设 $dp_i$ 表示以 $a_i$ 结尾的子序列的最大长度，则枚举满足 $a_i \& a_j \ne 0$ 的 $j$ 有

$dp_i=\max_{j<i, a_i \& a_j \ne 0} (dp_j+1)$考虑位运算经典套路拆位。观察 $a_i \& a_j \ne 0$ 这个条件，发现只要 $i,j$ 在二进制下有一个相同位的 $1$ 就能转移。那么我们枚举二进制位 $j$，设 $dp_j$ 表示 $j$ 位为 $1$ 时的最大长度。若 $a_i$ 在二进制下的第 $j$ 位不为 $0$，则有转移

$dp_j=\max dp_{j'}+1$这里 $j'$ 是另一个二进制位，由它转移而来即可。一个数 $a_i$ 可以被其二进制位的 $dp$ 转移，再转移到它二进制位的 $dp$ 值上。比较抽象，可以看代码理解。复杂度 $O(n\log V)$。

```cpp
const int N = 1e5 + 5;
int n, a[N], dp[40];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		int mx = 0;
		for (int j = 0; j <= 31; j++) {
			if (a[i] >> j & 1) mx = max(mx, dp[j]);
		}
		for (int j = 0; j <= 31; j++) {
			if (a[i] >> j & 1) dp[j] = max(dp[j], mx + 1);
		}
	}
	cout << *max_element(dp, dp + 32);
}
```

### [模拟赛] 魔法传送门

> 现有一个有向图，对于两个节点 $i,j(i<j)$，两点间边的数量为 $\operatorname{popcount}(a_i \& a_j)$ 条。求从 $1$ 到 $n$ 的简单路径条数。
>
> $n \le 2 \times 10^5$，$1 \le a_i \le 2^{30}$。

有一个显然的 DAG 上 DP，设 $dp_i$ 表示 $i$ 到 $n$ 的路径条数，则

$dp_i =\sum_{j=i+1}^{n} dp_j \times \operatorname{popcount}(a_i \& a_j)$复杂度 $O(n^2)$。考虑这个式子的计数意义，当 $a_i,a_j$ 有一个相同的二进制位时产生 $dp_j$ 的贡献。和上题一样拆位，用 $f_i$ 表示二进制第 $i$ 位的累计贡献，和上题类似地转移即可。复杂度 $O(n \log V)$。

```cpp
const int N = 2e5 + 5;
int n, a[N];
mint dp[N], f[35];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fill(dp + 1, dp + n + 1, 0), fill(f, f + n + 1, 0);
	dp[n] = 1;
	for (int j = 30; j >= 0; j--) {
		if (a[n] >> j & 1) f[j] += dp[n];
	}
	for (int i = n - 1; i >= 1; i--) {
		for (int j = 30; j >= 0; j--) {
			if (a[i] >> j & 1) dp[i] += f[j];
		}
		for (int j = 30; j >= 0; j--) {
			if (a[i] >> j & 1) f[j] += dp[i];
		}
	} cout << dp[1] << '\n';
}
```

### [模拟赛] 小 Z 爱划分

> 给出长度为 $n$ 的序列 $a$，将其划分为若干段，得分为每一段数组元素异或和的积。
>
> 求所有划分方式的得分的平方和。对 $10^9+7$ 取模。
>
> $n \le 2 \times 10^5$，$1 \le a_i \le 10^9$。

套路题。先把 $a_i$ 变成前缀异或。考虑一个 DP，设 $f_i$ 表示前缀 $[1,i]$ 的答案。枚举上一次划分的点 $j$，有

$f_i=\sum_{j=0}^{i-1} f_j (a_i \oplus a_j)^2$复杂度 $O(n^2)$。考虑拆位优化 DP。注意到

$\left( \sum_{i=1}^n a_i\right)^2=\sum_{i=1}^n \sum_{j=1}^n a_ia_j$于是

$f_i=\sum_{x,y} \sum_{j=0}^{i-1} f_j2^{x+y}$要求 $a_i,a_j$ 的 $x,y$ 位不同。设 $g_{0/1,0/1,x,y}$ 表示二进制位对 $(x,y)$ 对 $f$ 的累计贡献。和上面两个题一样辗转转移即可。复杂度 $O(n \log^2 V)$。

```cpp
const int N = 2e5 + 5, M = 31;
int n, a[N];
mint f[N], g[2][2][M][M];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] ^= a[i - 1];
	fill(f, f + n + 1, 0), memset(g, 0, sizeof(g)), f[0] = 1;
	for (int i = 0; i < M; i++) {
		for (int j = 0; j < M; j++) g[0][0][i][j] = 1;
	}
	for (int i = 1; i <= n; i++) {
		for (int x = 0; x < M; x++) {
			for (int y = 0; y < M; y++) f[i] += g[(a[i] >> x & 1) ^ 1][(a[i] >> y & 1) ^ 1][x][y] * (1LL << (x + y));
		}
		for (int x = 0; x < M; x++) {
			for (int y = 0; y < M; y++) g[a[i] >> x & 1][a[i] >> y & 1][x][y] += f[i];
		}
	} cout << f[n] << '\n';
}
```

本人赛时在 `(1LL << (x + y))` 这里用了快速幂，多了 $8$ 倍常数，100->20，警钟长鸣。

### CF2066C Bitwise Slides

异或性质好题。注意到异或有结合律，考虑求出 $a_i$ 的前缀异或 $p_i$，则 $P \oplus Q \oplus R=p_i$。又因为 $P,Q,P$ 中两数相同，根据 $a \oplus a=0$ 转化为 $P,Q,R$ 中至少有一个数为 $p_i$。

考虑计数 DP。令 $dp_{i,j}$ 表示考虑到第 $i$ 位，相同的两数值为 $j$ 的方案数。容易得到 $dp_{i,p_i}=dp_{i-1,p_i}$ 和 $dp_{i,j}=dp_{i-1,j}, j \ne p_i,p_{i-1}$，滚动数组以后值不变。

考虑 $dp_{i,p_{i-1}}$ 如何转移。对于 $dp_{i-1,p_i}$，可以操作等于 $p_i$ 的两个值；对于 $dp_{i-1,p_{i-1}}$，三数相等。由加法原理得：

$dp_{i,p_{i-1}}=3 \times dp_{i-1,p_{i-1}}+2 \times dp_{i-1,p_i}$注意到状态值域很大，但有效状态数只有 $O(n)$ 个。用 std::map 维护转移即可。

```cpp
const int N = 2e5 + 5;
int n, a[N];
map<int, mint> dp;

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] ^= a[i - 1];
	dp.clear(), dp[0] = 1;
	for (int i = 1; i <= n; i++) dp[a[i - 1]] = dp[a[i - 1]] * 3 + dp[a[i]] * 2;
	mint res = 0;
	for (auto it : dp) res += it.second;
	cout << res << '\n';
}
```

### UVA12716 GCD等于XOR GCD XOR

神秘结论题。不妨设 $a\ge b$，则由位运算性质 1 有 $a-b \le a \oplus b$。

设 $\gcd(a,b)=c$，则 $a,b$ 可以写成 $a=a_0c,b=b_0c$ 的形式。那么 $a-b=(a_0-b_0)c$，因为 $a_0 \ge b_0$，所以 $a-b \ge \gcd(a,b)$。

于是我们得到结论：$\gcd(a,b)=a\oplus b=a-b$。根据这个玩意枚举 $a,b$，复杂度是调和级数 $O(n \log n)$ 可以通过。

```cpp
const int N = 3e7 + 5;
int n, res[N];

void _main() {
	for (int b = 1; b <= N / 2; b++) {
		for (int a = b * 2; a < N; a += b) {
			if ((a ^ b) == a - b) res[a]++;
		}
	}
	for (int i = 2; i < N; i++) res[i] += res[i - 1];
	int t; cin >> t;
	for (int i = 1; i <= t; i++) cin >> n, cout << "Case " << i << ": " << res[n] << '\n';
}
```

### P5911 [POI 2004] PRZ

用二进制数 $s$ 表示选择的队员，$dp_s$ 表示当前状态下的最短过桥时间，然后再维护一下每个状态的**总**重量 $a_i$ 和**最大**时间 $b_i$。

转移就是从 $s$ 中分出一个子集 $t$，满足 $a_t \le W$，则 $dp_s \gets \min(dp_s, dp_{s \oplus t}+b_t)$。

使用上面讲过的子集枚举，复杂度为 $O(3^n)$。

```cpp
const int N = 17;
int w0, n, t[N], w[N], a[1 << N], b[1 << N], dp[1 << N];

void _main() {
	cin >> w0 >> n;
	for (int i = 1; i <= n; i++) cin >> t[i] >> w[i];
	for (int s = 0; s < (1 << n); s++) {
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) a[s] += w[i], b[s] = max(b[s], t[i]);
		}
	}
	memset(dp, 0x3f, sizeof(dp));
	dp[0] = 0;
	for (int s = 0; s < (1 << n); s++) {
		for (int t = s; t; t = (t - 1) & s) {
			if (a[t] <= w0) dp[s] = min(dp[s], dp[s ^ t] + b[t]);
		}
	} cout << dp[(1 << n) - 1];
}
```

### CF165E Compatible Numbers

SOS DP 板子题。注意到 $a_i \& a_j=0$ 等价于 $a_i \subseteq (\sim a_j)$，启示我们预处理一个高维前缀和，查询子集是否为空即可。

```cpp
const int N = 1e6 + 5, M = 22;
int n, a[N], f[1 << M];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], f[a[i]] = a[i];
	for (int i = 0; i < M; i++) {
		for (int s = 0; s < (1 << M); s++) {
			if ((s >> i & 1) && f[s ^ (1 << i)]) f[s] = f[s ^ (1 << i)];
		}
	}
	for (int i = 1; i <= n; i++) {
		int x = ((1 << M) - 1) ^ a[i];
		cout << (f[x] ? f[x] : -1) << ' ';
	}
}
```

## 20. 位运算进阶

由于把 01-Trie、bitset 和比较难的例题放到上面会影响阅读体验，于是把这部分拆开了。

## 20.1 01-Trie

字符上的 Trie 属于字符串算法，而二进制上的 Trie 是解决异或问题的有力数据结构。

先介绍 Trie 树，其中文名为字典树，是一棵边带权的叶向树。借用 OI-Wiki 的图：

![trie1](https://oi-wiki.org/string/images/trie1.png)

可以发现，Trie 树通过把相同的字符串前缀压到一起，实现节省复杂度的目的。而如果字符集为 $\{0,1\}$，就叫做 01-Trie，下面我们来介绍 01-Trie 维护异或和时的操作。

01-Trie 的本质是一棵值域为 $2^d$ 的权值线段树。

### 20.1.1 插入 & 删除

由于维护的是异或和，只需知道每一位上 $0/1$ 的奇偶性。故节点需要维护以下三个数组：

- `ch[0/1][x]`：维护节点 $x$ 的左 / 右儿子；
- `w[x]`：维护 $x$ 子树权值的数目。这里可以直接维护奇偶性。
- `xorv[x]`：维护 $x$ 子树的整体异或和。

由此可以写出 01-Trie 的上传操作：

```cpp
inline void pushup(int rt) {
    w[rt] = xorv[rt] = 0;
    if (ch[0][rt]) {
        w[rt] += w[ch[0][rt]];
        xorv[rt] ^= xorv[ch[0][rt]] << 1;
    }
    if (ch[1][rt]) {
        w[rt] += w[ch[1][rt]];
        xorv[rt] ^= (xorv[ch[1][rt]] << 1) | (w[ch[1][rt]] & 1);
    }
}
```

插入删除是平凡的，将数二进制拆分后在遍历路径中更新对应信息即可。

```cpp
inline int newnode() {
    cnt++;
    ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
    return cnt;
}
void insert(int& rt, const T& x, int dep) {
    if (!rt) rt = newnode();
    if (dep > H) return w[rt]++, void();
    insert(ch[x & 1][rt], x >> 1, dep + 1);
    pushup(rt);
}

void remove(int rt, const T& x, int dep) {
    if (dep > H) return w[rt]--, void();
    remove(ch[x & 1][rt], x >> 1, dep + 1);
    pushup(rt);
}
```

### *20.1.2 全局加一

一个神奇操作。考虑二进制下如何加一：

```basic
10101 + 1 = 10110
100000010111111 + 1 = 100000011000000
```

只需要找到最低位的 $0$，将其变为 $1$，然后把后面的所有 $1$ 置 $0$ 即可。放到 Trie 上，直接交换左右儿子并沿交换后 $0$ 的权值边向下递归即可。

```cpp
void add1(int rt) {
    swap(ch[0][rt], ch[1][rt]);
    if (ch[0][rt]) add1(ch[0][rt]);
    pushup(rt);
}
```

### *20.1.3 合并

没错，这神奇玩意还能合并。如果你学过线段树合并或者 FHQ-Treap 的话，这个东西相当好理解。

先判掉 $x,y$ 是空树的情况。直接把 $b$ 的信息放到 $a$ 上，然后递归合并左右儿子即可。

```cpp
int merge(int a, int b) {
    if (!a || !b) return a ? a : b;
    w[a] += w[b], xorv[a] ^= xorv[b];
    ch[0][a] = merge(ch[0][a], ch[0][b]), ch[1][a] = merge(ch[1][a], ch[1][b]);
    return a;
}
```

至此我们实现了一个支持插入 / 删除，全局加一，合并，全局异或和的数据结构。自己造的 [板子题](https://www.luogu.com.cn/problem/U456135)。

## 20.2 bitset

### 20.2.1 用法 & 原理

在 GNU C++ 中，`bitset` 位于 `<bitset>` 头文件中，是一个维护 01 序列的数据结构。其用法如下：

```cpp
bitset<N> bs;  // bitset的长度为定值，初始化时全为0
bs.set();  // 全设为1
bs.reset();   // 全设为0
bs.count();  // 1的数量
bs[x];   // 第x位
bs[x] = 0/1;  // 设置第x位
bs._Find_first();  // 第一个1的位置
bs._Find_next(x);  // [x + 1, N)中第一个1的位置，没有返回N
```

同时，`bitset` 与 `bitset` 直接可以进行按位或、按位与、按位异或运算，还可以对 `bitset` 进行左移右移操作。

在 64 位机器的 bitset 内部实现中，将 $w=64$ 个二进制位压成一组，用一个无符号 64 位整数存储，这本质上是一种分块思想。各种操作都是对这些整数的运算，从而获得了 $\dfrac{1}{w}$ 的常数。一般地，bitset 的复杂度上要乘一个 $\dfrac{1}{w}$。

在目前，可以认为 $O(\dfrac{n^2}{w})$ 在 1s 内可以稳定通过 $n=10^5$ 的数据。

bitset 虽然只能维护一个 01 序列，但其应用非常多。我们在前面见过 bitset 配合埃氏筛的应用。bitset 还用于高维偏序、01 背包、DAG 可达性等问题。同时一个常见的场景是利用 `_Find_next` 向后跳。

### *20.2.2 手写 bitset

下面是一份手写的 bitset 板子。在实际使用中，它和 std::bitset 常数基本一样。

在一些题目中，$w$ 需要取一个更小或者更大的数，此时我们就需要手写 bitset 了。

```cpp
template <const int N>
class BitSet {
private:
	static const int size = (N >> 6) + ((N & 63) != 0);
	uint64_t a[size];
	int find_after(int x) const {
		for (int i = x; i < size; i++) {
			if (a[i]) return __builtin_ctzll(a[i]) ^ (i << 6);
		} return N;
	}
	struct Pos {
		BitSet<N>& bs;
		int pos;
		Pos() : pos(0) {}
		Pos(BitSet<N>& _bs, int _pos) : bs(_bs), pos(0) {}
		int operator= (int x) {return bs.set(pos, x), x;}
		operator int() const {return bs.get(pos);}
	};
public:
	BitSet() {memset(a, 0, sizeof(a));}
	BitSet(const BitSet<N>& x) {memcpy(a, x.a, sizeof(a));}
	int get(int x) const {return a[x >> 6] >> (x & 63) & 1;}
	int operator[] (int x) const {return get(x);}
	Pos operator[] (int x) {return Pos(*this, x);}
	void set(int x, int val = 1) {
		if (x >= N || x < 0) return;
		if (val == 0) a[x >> 6] &= ~(1ULL << (x & 63));
		else a[x >> 6] |= 1ULL << (x & 63);
	}
	void reset(int x) {set(x, 0);}
	void filp(int x) {
		if (x >= N || x < 0) return;
		a[x >> 6] ^= 1ULL << (x & 63);
	}
	void set() {for (int i = 0; i < size; i++) a[i] = -1ULL;}
	void reset() {memset(a, 0, sizeof(a));}
	void flip() {for (int i = 0; i < size; i++) a[i] = ~a[i];}
	int count() const {
		int res = 0;
		for (int i = 0; i < size; i++) res += __builtin_popcountll(a[i]);
		return res;
	}
	BitSet<N> operator~ () const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = ~a[i];
		return res;
	}
	BitSet<N> operator<< (const int& len) const {
		BitSet<N> res;
		uint64_t last = 0;
		for (int i = 0; i + (len >> 6) < size; i++) {
			res.a[i + (len >> 6)] = last | (a[i] << (len & 63));
			if (len & 63) last = a[i] >> (64 - (len & 63));
		} return res;
	}
	BitSet<N> operator>> (const int& len) const {
		BitSet<N> res;
		uint64_t last = 0;
		for (int i = size - 1; i >= (len >> 6); i--) {
			res.a[i - (len >> 6)] = last | (a[i] >> (len & 63));
			if (len & 63) last = a[i] << (64 - (len & 63));
		} return res;
	}
	BitSet<N>& operator&= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] &= x.a[i];
		return *this;
	}
	BitSet<N>& operator|= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] |= x.a[i];
		return *this;
	}
	BitSet<N>& operator^= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] ^= x.a[i];
		return *this;
	}
	BitSet<N>& operator<<= (const int& len) {return *this = *this << len;}
	BitSet<N>& operator>>= (const int& len) {return *this = *this >> len;}
	BitSet<N> operator& (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] & x.a[i];
		return res;
	}
	BitSet<N> operator| (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] | x.a[i];
		return res;
	}
	BitSet<N> operator^ (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] ^ x.a[i];
		return res;
	}
	bool any() const {
		for (int i = 0; i < size; i++) if (!a[i]) return false;
		return true;
	}
	bool none() const {
		for (int i = 0; i < size; i++) if (a[i]) return false;
		return true;
	}
	int first() const {return find_after(0);}
	int next(int x) const {
		uint64_t cur = a[x >> 6] >> (x & 63) >> 1;
		if (cur) return __builtin_ctzll(cur) + x + 1;
		return find_after((x >> 6) + 1);
	}
	int _Find_first() const {return first();}
	int _Find_next(int x) const {return next(x);}
};
```

## 20.3 例题

依次是 01-Trie、bitset 和比较难的位运算题。

### P10471 最大异或对 The XOR Largest Pair

感觉是 01-Trie 最经典的应用。先全部插入到 Trie 上，然后依次枚举每个数，找这个数能够形成的最大异或对。根据异或性质，我们贪心来取，每次尽量选不一样的数位遍历 01-Trie 即可。

```cpp
const int N = 2e6 + 5;
int n, a[N];
int cnt = 1, ch[2][N];

void insert(int x) {
	int cur = 1;
	for (int i = 31; i >= 0; i--) {
		int p = x >> i & 1;
		if (!ch[p][cur]) ch[p][cur] = ++cnt;
		cur = ch[p][cur];
	}
}
int query(int x) {
	int cur = 1, res = 0;
	for (int i = 31; i >= 0; i--) {
		int p = x >> i & 1;
		if (!ch[p ^ 1][cur]) cur = ch[p][cur];
		else cur = ch[p ^ 1][cur], res += (1 << i);
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], insert(a[i]);
	int res = 0;
	for (int i = 1; i <= n; i++) res = max(res, query(a[i]));
	cout << res;
}
```

### P4551 最长异或路径

好像没有头绪。记根节点到 $u$ 点的路径异或和为 $s_u$，推波式子：

$$
\begin{aligned}
e_u \oplus \cdots \oplus e_v &= e_u \oplus \cdots \oplus e_{lca(u,v)} \oplus e_v \oplus \cdots \oplus e_{lca(u,v)} \\
&= e_1 \oplus \cdots \oplus e_{lca(u,v)} \oplus \cdots \oplus e_u  \oplus e_1 \oplus \cdots \oplus e_{lca(u,v)} \oplus \cdots \oplus e_v\\
&=s_u \oplus s_v
\end{aligned}
$$

这里利用了异或性质 $a \oplus a=0$，从根节点到 $lca(u,v)$ 这段路径异或两次就是没有异或。于是这题转化为上题。

### *P6018 [Ynoi2010] Fusion tree

我们发现操作 1 & 3 都是相邻点的操作，不好在树上维护，因此我们统一维护所有点儿子的异或信息，单独处理父亲。然后用 01-Trie 来维护即可，对每个点打个标记维护增加量。单独处理的时候，先删除再插入即可，具体看代码。

```cpp
const int N = 5e5 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

#define ls (ch[0][rt])
#define rs (ch[1][rt])
int cnt, w[N * 21], xorv[N * 21], ch[2][N * 21];
int newnode() {
	cnt++;
	ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
	return cnt;
} void pushup(int rt) {
	w[rt] = xorv[rt] = 0;
	if (ls) w[rt] += w[ls], xorv[rt] ^= xorv[ls] << 1;
	if (rs) w[rt] += w[rs], xorv[rt] ^= (xorv[rs] << 1) | (w[rs] & 1);
} void insert(int& rt, int x, int dep = 0) {
	if (!rt) rt = newnode();
	if (dep > 20) return w[rt]++, void();
	insert(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void remove(int rt, int x, int dep = 0) {
	if (dep > 20) return w[rt]--, void();
	remove(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void add1(int rt) {
	if (!rt) return;
	swap(ls, rs), add1(ls), pushup(rt);
}

int n, q, u, v, a[N], opt, x, y;
int fa[N], rt[N], tag[N];

void dfs(int u, int f) {
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == f) continue;
		fa[v] = u, dfs(v, u);
	}
}

void change(int x, int c) {   // 单独处理节点x的权值
	if (x != 1) remove(rt[fa[x]], a[x] + tag[fa[x]]);
	a[x] += c;
	if (x != 1) insert(rt[fa[x]], a[x] + tag[fa[x]]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
	} dfs(1, -1);
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 2; i <= n; i++) insert(rt[fa[i]], a[i]);
	while (q--) {
		cin >> opt >> x;
		if (opt == 1) {
			tag[x]++, add1(rt[x]);  // 子树全局加1
			if (x != 1) change(fa[x], 1);
		} else if (opt == 2) {
			cin >> y, change(x, -y);
		} else if (opt == 3) {
			if (x != 1) {
				if (fa[x] != 1) cout << (xorv[rt[x]] ^ (a[fa[x]] + tag[fa[fa[x]]])) << '\n';
				else cout << (xorv[rt[x]] ^ a[fa[x]]) << '\n';
			} else {
				cout << xorv[rt[x]] << '\n';
			}
		}
	}
}
```

### *P6623 [省选联考 2020 A 卷] 树

思考 $val(x)$ 的意义，可以发现一个暴力，就是将子树内的点权全部加 $1$ 后再异或起来贡献到父亲，是一个类似树形 dp 的思想。具体地，对于儿子 $v$ 的 $val_v =a_1 \oplus a_2 \oplus \cdots \oplus a_k$，则贡献为 $(a_1+1) \oplus (a_2+1) \oplus \cdots \oplus (a_k+1)$，复杂度 $O(n^2)$。

考虑在每个节点建立一棵 01-Trie，对儿子的 Trie 作合并并全局加一，然后把自己的点权放进去。

考虑复杂度。Trie 的合并操作当且仅当两棵 Trie 存在相同元素时产生 $O(\log n)$ 复杂度。设其出现 $x$ 次，总合并次数 $\sum x = n$，因此复杂度为严格 $O(n \log n)$。

```cpp
const int N = 6e5 + 5;
int tot, head[N];
struct Edge {
	int next, to;
} edge[N];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

int n, a[N], f;

#define ls (ch[0][rt])
#define rs (ch[1][rt])
int cnt, w[N * 20], xorv[N * 20], ch[2][N * 20];
int newnode() {
	cnt++;
	ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
	return cnt;
} void pushup(int rt) {
	w[rt] = xorv[rt] = 0;
	if (ls) w[rt] += w[ls], xorv[rt] ^= xorv[ls] << 1;
	if (rs) w[rt] += w[rs], xorv[rt] ^= (xorv[rs] << 1) | (w[rs] & 1);
} void insert(int& rt, int x, int dep = 0) {
	if (!rt) rt = newnode();
	if (dep > 20) return w[rt]++, void();
	insert(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void add1(int rt) {
	if (!rt) return;
	swap(ls, rs), add1(ls), pushup(rt);
} int merge(int a, int b) {
	if (!a || !b) return a ? a : b;
	w[a] += w[b], xorv[a] ^= xorv[b];
	ch[0][a] = merge(ch[0][a], ch[0][b]), ch[1][a] = merge(ch[1][a], ch[1][b]);
	return a;
}

int rt[N];
long long ans;
void dfs(int u) {
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		dfs(v), rt[u] = merge(rt[u], rt[v]);
	}
	add1(rt[u]), insert(rt[u], a[u]);
	ans += xorv[rt[u]];
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 2; i <= n; i++) cin >> f, add_edge(f, i);
	dfs(1); cout << ans;
}
```

### *P10218 [省选联考 2024] 魔法手杖

两年后再看这个题其实没有那么可怕。特别是 72pts 做法其实并不难。

看到最大化最小值，直接二分答案 $mid$。注意到 $a_i \oplus x \le a_i+x$，因此选择的 $a_i$ 使得 $a_i \oplus x \ge mid$ 一定可以成立，反之 $a_i +x < mid$ 一定不能成立。

考虑对于 $a_i$ 从高位向低位建立一棵 01-Trie，在每个节点上记录最小的 $a_i$ 和总代价，判定答案时遍历整棵树。贪心地，从高位向低位考虑，进行一个类似树上数位 DP 的东西。具体地，记 $sum_{rt}$ 为当前节点的总代价，$mn_{rt}$ 为当前节点上的最小 $a_i$。进行一个 DFS，用三元组 $(cmn,csum,cur)$ 记录当前状态。

- 若 $mid$ 的当前位为 $1$：
  - 若走 $1$ 边，$(cmn,csum)$ 受左子树影响，$cur$ 不变。

  - 若走 $0$ 边，$(cmn,csum)$ 受右子树影响，$cur$ 的当前位改变。

- 若 $mid$ 的当前位为 $0$：
  - 若走 $0$ 边，$(cmn,csum)$ 不变，$cur$ 不变。

  - 若走 $1$ 边，$(cmn,csum)$ 不变，$cur$ 的当前位改变。

当递归到叶子时，判断是否存在可行方案，即 $mid \le cur+cmn+2^d-1$。

需要特判 $\sum b \le m$，总复杂度 $O(nk^2)$，可以获得 72pts。需要比较精细的实现，不然会被卡常变成 32pts。

```cpp
const int N = 1e5 + 5;
constexpr int128 pw(int x) {return int128(1) << x;}
const int128 inf = pw(120) + 5;
int n, m, k, b[N];
int128 a[N];

struct trie {
	int tot, num[2][N * 120];
	int128 sum[N * 120], mn[N * 120];
	trie() : tot(1) {}
	void clear() {
		for (int i = 0; i <= tot; i++) num[0][i] = num[1][i] = 0, sum[i] = 0, mn[i] = inf;
		tot = 1, sum[1] = 0, mn[1] = inf;
	}
	void insert(int128 x, int cost) {
		int rt = 1;
		mn[rt] = min(mn[rt], x), sum[rt] += cost;
		for (int i = k - 1; i >= 0; i--) {
			int c = x >> i & 1;
			if (!num[c][rt]) num[c][rt] = ++tot, mn[tot] = inf, sum[tot] = 0;
			rt = num[c][rt], mn[rt] = min(mn[rt], x), sum[rt] += cost;
		}
	}
#define ls (num[0][rt])
#define rs (num[1][rt])
	bool dfs(int rt, int dep, int128 cmn, int128 csum, int128 mid, int128 cur) {
		if (csum > m) return false;
		if (dep < 0 || !rt) {
			if (dep >= 0) cur += pw(dep + 1) - 1;
			return mid <= cur + cmn;
		}
		if (mid >> dep & 1) {
			return dfs(rs, dep - 1, min(cmn, mn[ls]), csum + sum[ls], mid, cur)
			|| dfs(ls, dep - 1, min(cmn, mn[rs]), csum + sum[rs], mid, cur ^ pw(dep));
		} else {
			return dfs(ls, dep - 1, cmn, csum, mid, cur)
			|| dfs(rs, dep - 1, cmn, csum, mid, cur ^ pw(dep));
		}
	}
} tr;
bool check(int128 x) {return tr.dfs(1, k - 1, inf, 0, x, 0);}

void _main() {
	read(n, m, k), read(a + 1, a + n + 1), read(b + 1, b + n + 1);
	int128 sum = 0;
	for (int i = 1; i <= n; i++) sum += b[i];
	if (sum <= m) return writeln(*min_element(a + 1, a + n + 1) + pw(k) - 1), void();
	tr.clear();
	for (int i = 1; i <= n; i++) tr.insert(a[i], b[i]);
	int128 l = 0, r = pw(k) - 1, res = 0;
	while (l <= r) {
		int128 mid = (l + r) >> 1;
		if (check(mid)) l = mid + 1, res = mid;
		else r = mid - 1;
	} writeln(res);
}
```

这个分在我们 SX 已经足够进队了。下面考虑满分做法。

类比线段树上二分，考虑在 01-Trie 上二分，进行一个贪心从而逐位确定答案。若答案当前位能填 $1$，就必须舍去一棵子树。当无法填 $1$ 时，直接递归两棵子树求解。判断填 $1$ 的可行性和 72pts 做法一样。再记录一个值 $dm$ 表示 $m$ 与当前使用的代价的差，即可实现 $O(nk)$ 求解。实现大概长下面这样：

```cpp
void dfs(int rt, int dep, int128 dm, int128 x, int128 cmn, int128 cur) {
	if (dm < 0) return;
	if (dep < 0) return ans = max(ans, cur), void();
	if (!rt) return ans = max(ans, cmn + (x | (pw(dep) - 1) | pw(dep))), void();
	int128 u = x ^ (pw(dep) - 1);
	bool t1 = sum[ls] <= dm && u + min(cmn, mn[ls]) >= (cur ^ pw(dep)),
	t2 = sum[rs] <= dm && (u ^ pw(dep)) + min(cmn, mn[rs]) >= (cur ^ pw(dep));
	if (t1) dfs(rs, dep - 1, dm - sum[ls], x, min(cmn, mn[ls]), cur ^ pw(dep));
	if (t2) dfs(ls, dep - 1, dm - sum[rs], x | pw(dep), min(cmn, mn[rs]), cur ^ pw(dep));
	if (!t1 && !t2) dfs(ls, dep - 1, dm, x, cmn, cur), dfs(rs, dep - 1, dm, x | pw(dep), cmn, cur);
}

ans = 0, tr.dfs(1, k - 1, m, 0, pw(k), 0);   // 不用二分，改成这样即可
writeln(ans);
```

### AT_abc330_e [ABC330E] Mex and Update

单点修改 + 全局 mex。注意到 $a_i \le 10^9$，但实际值域只能到 $n+1$。

考虑用一个 bitset 维护值域，删数是简单的，加数就用 `_Find_next` 暴力扫即可。复杂度 $O(\dfrac{nq}{w})$。

```cpp
const int N = 2e5 + 5;
int n, q, a[N], x, y, res, cnt[N];
bitset<N> bs;
void add(int x) {
	if (x >= N) return;
	cnt[x]++, bs.set(x, 0);
	if (res == x) res = bs._Find_next(x);
}
void del(int x) {
	if (x >= N) return;
	if (--cnt[x] == 0) bs.set(x, 1), res = min(res, x);
}
void _main() {
	cin >> n >> q;
	bs.set();
	for (int i = 1; i <= n; i++) cin >> a[i], add(a[i]);
	while (q--) {
		cin >> x >> y;
		del(a[x]), add(a[x] = y);
		cout << res << '\n';
	}
}
```

你可以使用这种方法配合普通莫队通过 [P4137 Rmq Problem / mex](https://www.luogu.com.cn/problem/P4137)。

### P1537 弹珠

bitset 优化背包。正常 01 背包的实现大概是这样：

```cpp
dp[0] = 1;
for (int i = 1; i <= n; i++) {
	for (int j = m; j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]]);
}
```

考虑构建一个 bitset，用第 $i$ 位表示第 $i$ 个物品是否能取到。对于新的 $w_i$，若选，则原来能取到 $j$ 的数就能取到 $j+w_i$，代码为 `s <<= w[i]`，不选是一样的，所以或上去即可。

```cpp
bitset<N> s;
s[0] = 1;
for (int i = 1; i <= n; i++) s |= (s << w[i]);
```

回到这题，可以直接暴力把多重背包拆成 01 背包，再上 bitset 优化解决。

```cpp
const int N = 2e5 + 5;
int a[8];
bitset<N> dp;

void main() {
	for (int kase = 1; ; kase++) {
		int tot = 0;
		for (int i = 1; i <= 6; i++) cin >> a[i], tot += a[i] * i;
		if (!tot) return;
		cout << "Collection #" << kase << ":\n";
		if (tot & 1) {cout << "Can't be divided.\n\n"; continue;}
		dp.reset(), dp.set(0, 1);
		for (int i = 1; i <= 6; i++) {
			for (int j = 1; j <= a[i]; j++) {
				dp |= (dp << i);
				if (dp[tot >> 1]) {cout << "Can be divided.\n\n"; goto flag;}
			}
		}
		cout << "Can't be divided.\n\n";
		flag:;
	}
}
```

### *P3810 【模板】三维偏序（陌上花开）

做法来自[这篇题解](https://www.luogu.com.cn/article/gtnbcf0u)。

bitset 的高端应用之一。对于 $k$ 维偏序问题，使用 bitset 解决的复杂度为 $O(\dfrac{n^2k}{w})$，对比其他算法的 $O(n \log^2 n)$ 很优秀了。

开 $n$ 个 bitset，用 $b_{i,j}$ 表示 $j$ 的每一维都不超过 $i$，初始化所有 $b_{i,j}=1$。枚举三维并分别按该维排序，用一个新的 bitset 来记录当前维度 $j$ 是否超过 $i$，不妨令其为 $s$。注意到 $j$ 有单调性容易维护，循环结束后执行 `b[i] &= s` 即可。

注意到开 `bitset<N> b[N]` 在 $n =10^5$ 时需要 1192MB，无法通过。使用分组 bitset 的技巧，时间换空间，将操作每 $B$ 个处理一次，于是只需开 $B$ 个 bitset。会比较卡常。

```cpp
const int N = 1e5 + 5, B = 1e4;
int n, k, a[3][N], p[3][N], ans[N];
bitset<N> b[B], s;  // 119MB

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[0][i] >> a[1][i] >> a[2][i];
	for (int i = 0; i < 3; i++) {
		iota(p[i] + 1, p[i] + n + 1, 1);
		sort(p[i] + 1, p[i] + n + 1, [&](int x, int y) -> bool {
			return a[i][x] < a[i][y];
		});
	}
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, l + B - 1);
		for (int i = l; i <= r; i++) b[i - l].set();
		for (int i = 0; i < 3; i++) {
			s.reset();
			for (int j = 1, k = 1; j <= n; j++) {
				int x = p[i][j];
				while (k <= n && a[i][p[i][k]] <= a[i][x]) s[p[i][k++]] = 1;
				if (l <= x && x <= r) b[x - l] &= s;
			}
		}
		for (int i = l; i <= r; i++) ans[b[i - l].count()]++;
	}
	for (int i = 1; i <= n; i++) cout << ans[i] << '\n';
}
```

### P10480 可达性统计

bitset 的又一个应用：DAG 可达性问题。

考虑在拓扑序上可行性 DP，记 $f_{x,y}$ 表示 $x$ 是否可以到达 $y$。建反图，跑一个拓扑排序，对于边 $(u,v)$ 作转移 $f_{v,i} \to f_{v,i}$。复杂度 $O(nm)$。

注意到如果将 $f_x$ 开成一个 bitset，上述转移就是 `f[v] |= f[u]`。复杂度 $O(\dfrac{nm}{w})$。请注意，**DAG 可达性问题没有更低复杂度的做法**。

```cpp
const int N = 3e4 + 5;
int n, m, deg[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
bitset<N> f[N];
queue<int> q;
void topo() {
	for (int i = 1; i <= n; i++) f[i][i] = 1;
	for (int i = 1; i <= n; i++) {
		if (!deg[i]) q.emplace(i);
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			f[v] |= f[u];
			if (!--deg[v]) q.emplace(v);
		}
	}
}

void _main() {
	cin >> n >> m;
	for (int i = 1, u, v; i <= m; i++) cin >> u >> v, add_edge(v, u), deg[u]++;
	topo();
	for (int i = 1; i <= n; i++) cout << f[i].count() << '\n';
}
```

### *P2150 [NOI2015] 寿司晚宴

两个子集中的数字两两互质，等价于子集中的质因数集合交集为空。

我们先从 30pts 开始考虑。因为 $n \le 30$，那么质因数只有 $10$ 个。设 $dp_{i,s,t}$ 表示当前考虑到第 $i$ 个数，质因子集合的二进制状态分别为 $s,t$ 的方案数。对于 $[2,n]$ 分解质因数，把质因数状压一波。枚举与 $s,t$ 无交集的 $k$，刷表法转移：

$$
\forall k|t =0,dp_{i+1,s|k,t} \gets dp_{i+1,s|k,t}+dp_{i,s,t}\\
\forall k|s =0, dp_{i+1,s,t|k} \gets dp_{i+1,s,t|k}+dp_{i,s,t}
$$

然后对于无交集的 $s,t$ 统计答案。可以滚动数组优化，时间复杂度为 $O(2^{2w} n)$，其中 $w=10$。

然后直接考虑正解。因为 $500$ 以内的质数有 $95$ 个，暴力 DP 直接爆炸。但是我们发现 $n$ 以内的数大于 $\sqrt{n}$ 的质因子最多只有一个，也就是大于 $23$ 的质因子最多一个。那么我们以 $23$ 为分界点，考虑在两侧分别 dp。

具体地，对于 $[2,500]$ 以内的数，我们先找出其最大质因子并按其排序，然后对每一个连续段统计答案。而 $23$ 以内的质数只有 $8$ 个，于是仍然令 $dp_{i,s,t}$ 表示考虑到第 $i$ 个数，质因子集合的二进制状态分别为 $s,t$ 的方案数，但是此时 $s,t \le 2^{8}$。接着考虑最大质因子的贡献，由于它只能被一个子集选走，令 $f_{i,s,t}$ 表示考虑到第 $i$ 个数，其最大质因子只能被第一个子集选走的方案数，$g_{i,s,t}$ 表示其最大质因子只能被第二个子集选走的方案数，仍然刷表转移：

$$
\forall k | t=0, f_{i+1,s|k,t} \gets f_{i+1,s|k,t}+f_{i,s,t}\\
\forall k | s=0, g_{i+1,s,t|k} \gets g_{i+1,s,t|k}+g_{i,s,t}
$$

把 $f,g$ 都合并到 $dp$ 里，需要容斥一下，因为会把不选的情况算两遍：

$dp_{i+1,s,t} \gets f_{i,s,t}+g_{i,s,t}-dp_{i,s,t}$然后我们滚动数组优化空间，注意要像 01 背包那样倒序枚举了。但是还有一个小优化是有用的集合满足 $s | t \ne 0$，那么我们可以枚举 $s$ 和其子集 $t$，这样复杂度优化到 $O(3^w n)$，其中 $w=8$。答案即为

$\sum_{s | t \ne 0} dp_{s,t}$当然这题 $O(4^wn)$ 就够了，代码用的就是无优化的做法。

```cpp
const int N = 505, M = 1 << 8;

int prime[] = {0, 2, 3, 5, 7, 11, 13, 17, 19};
int n, p;
struct node {
	int v, p, s;
	node() : v(0), p(-1), s(0) {}
	void get() {
		int x = v;
		for (int i = 1; i <= 8; i++) {
			if (x % prime[i]) continue;
			s |= 1 << (i - 1);
			while (x % prime[i] == 0) x /= prime[i];
		}
		if (x != 1) p = x;
	}
} a[N];
int dp[N][N], f[N][N], g[N][N];

void _main() {
	cin >> n >> p;
	for (int i = 2; i <= n; i++) a[i].v = i, a[i].get();
	sort(a + 2, a + n + 1, [](const node& x, const node& y) -> bool {
		return x.p < y.p;
	});
	dp[0][0] = 1;
	for (int i = 2; i <= n; i++) {
		if (i == 2 || a[i].p != a[i - 1].p || a[i].p == -1) {  // 新连续段
			memcpy(f, dp, sizeof(f)), memcpy(g, dp, sizeof(g));
		}
#define add(x, y) ((x) += (y), (x) >= p ? (x) -= p : (x))
#define madd(x, y) ((x) + (y) >= p ? (x) + (y) - p : (x) + (y))
#define msub(x, y) ((x) - (y) < 0 ? (x) - (y) + p : (x) - (y))
		for (int s = M - 1; s >= 0; s--) {
			for (int t = M - 1; t >= 0; t--) {
				if (s & t) continue;
				if ((a[i].s & t) == 0) add(f[a[i].s | s][t], f[s][t]);
				if ((a[i].s & s) == 0) add(g[s][a[i].s | t], g[s][t]);
			}
		}
		if (i == n || a[i].p != a[i + 1].p || a[i].p == -1) {  // 下一个点是新连续段
			for (int s = 0; s < M; s++) {
				for (int t = 0; t < M; t++) {
					if (s & t) continue;
					dp[s][t] = msub(madd(f[s][t], g[s][t]), dp[s][t]);
				}
			}
		}
	}
	int res = 0;
	for (int s = 0; s < M; s++) {
		for (int t = 0; t < M; t++) {
			if (s & t) continue;
			add(res, dp[s][t]);
		}
	} cout << res;
}
```

对于这题来说，我们把 $<\sqrt{n}$ 的 $\ge \sqrt{n}$ 分成两类分别处理，最后降低复杂度，这就是根号分治的思想。

### *AT_arc137_d [ARC137D] Prefix XORs

每次一维前缀和可以对应到二维平面上的移动，考虑格路计数拆贡献。对于 $a$ 数组，$k$ 次前缀异或以后的总贡献为

$a_n=\bigoplus_{i=0} (C_{n-i+k-1}^{k-1} \bmod 2) a_{n-i}$考虑 $C_{(n-i)+(k-1)}^{k-1} \bmod 2 =1$ 的必要条件。根据 Lucas 定理，$n-i$ 与 $k-1$ 在二进制表示下所有 $1$ 的位置均不同，即 $(n-i)\&(k-1)=0$。

考虑枚举 $n-i$ 的补集的子集统计答案。复杂度 $O(n+3^{\log m})$，本题放过去了。

```cpp
const int N = 1e6 + 5;
int n, m, a[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int k = 1; k <= m; k++) {
		int res = a[n], s = (k - 1) ^ ((1 << 20) - 1);
		for (int t = s; t; t = (t - 1) & s) {
			if (t < n) res ^= a[n - t];
		} cout << res << ' ';
	}
}
```

### *AT_apc001_f XOR Tree

很神仙的一个题。

化边权为点权，把每个点的点权定义为其所连的边的边权异或和。此时再思考路径异或，发现因为 $a \oplus x \oplus x=a$，除了路径端点异或上一个 $x$，其他点点权不变。至此，题目转化为：

> 给定一个数组，每次将两个数将他们异或上同一个数，求最小操作次数使得数组所有数变为 $0$。

然而这个东西好像还是不可做。于是我们关注数据范围发现 $a_i \le 15$。我们先把权值相同的点两两抵消，那么剩下的是最多 $15$ 个互不相同的数字。

考虑状压 dp，设 $dp_{s}$ 表示以 $s$ 为状态的二进制集合全部消除的最小操作次数。当且仅当 $s$ 内数字异或和为 $0$ 时，$s$ 才能消掉。考虑转移，我们把 $s$ 拆成两个子集 $s_1,s_2$，且 $s_1,s_2$ 异或和均为 $0$，则两个子集直接合并就能减少一次操作。复杂度 $O(n+3^{V})$。于是我们解决了一道黑题。

```cpp
const int N = 1e5 + 5, M = 1 << 15;
int n, u, v, w, a[N], xorv[M + 5], cnt[20], dp[M + 5];

void _main() {
	cin >> n;
	for (int i = 1; i < n; i++) {
		cin >> u >> v >> w; u++, v++;
		a[u] ^= w, a[v] ^= w;
	}
	for (int i = 1; i <= n; i++) cnt[a[i]]++;
	int res = 0, fin = 0;
	for (int i = 1; i <= 15; i++) {
		res += cnt[i] / 2;
		if (cnt[i] & 1) fin |= 1 << (i - 1);  // 消不完
	}

	for (int i = 1; i < M; i++) {
		for (int j = 1; j <= 15; j++) {
			if (i >> (j - 1) & 1) xorv[i] ^= j;
		}
	}
	for (int i = 1; i < M; i++) {
		dp[i] = __builtin_popcount(i) - 1;
		if (xorv[i]) continue;
		for (int j = (i - 1) & i; j; j = (j - 1) & i) {
			if (xorv[j]) continue;
			dp[i] = min(dp[i], dp[j] + dp[i ^ j]);
		}
	}
	cout << res + dp[fin];
}
```

## 21. 分数规划

分数规划一般与其他算法一起出现，比如：

- 与 01 背包结合，称为最优比率背包；
- 与最小生成树结合，称为最优比率生成树；
- 与最短路结合，称为最优密度路径；
- 与 SPFA 判负环结合，称为最优比率环；
- 与网络流结合，称为最优密度子图。

## 21.1 模型

分数规划的基本模型是：有 $n$ 个物品，每种物品有两个权值 $a,b$，选出若干个最大化或最小化 $\dfrac{\sum a} {\sum b}$。

最常见的模型里每种物品只有选与不选两种可能，因而又被称作 01-分数规划。

## 21.2 解法

最值问题且满足单调性，二分启动。以最大值为例，我们二分答案 $mid$，则

由

$\dfrac{\sum a_i} {\sum b_i} > mid$可得

$\sum a_i - mid \times \sum b_i > 0$即

$\sum (a_i-mid \times b_i) > 0$由此得到二分的判定式。在分数规划的问题中，我们需要用其他方法求出 $\sum (a_i-mid \times b_i)$ 的最值并与 $0$ 比较。

## 21.3 例题

最大密度子图板子是 [UVA1389 Hard Life](https://www.luogu.com.cn/problem/UVA1389)，但是要用到笔者不会的网络流知识，这里就不讲了。

### P10505 Dropping Test

分数规划板子。二分不变，可以贪心地去选，按 $a_i-mid \times b_i \ge 0$ 排个序选最大的 $n-k$ 个。分数规划结合贪心。

```cpp
const double eps = 1e-8;
int n, k, a[N], b[N];
double c[N];
bool check(double x) {
	for (int i = 1; i <= n; i++) c[i] = a[i] - b[i] * x;
	sort(c + 1, c + n + 1, greater<double>());
	return accumulate(c + 1, c + n - k + 1, 0.0) >= 0.0;
}

void _main() {
	cin >> n >> k;
	if (n == 0 && k == 0) exit(0);
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	double l = 0.0, r = 1.0;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << round(l * 100.0) << '\n';
}
```

### P4377 [USACO18OPEN] Talent Show G

仔细审题可以发现，这题等价于上面的模型，加入一个 $\sum b_i \ge W$ 的限制。

$\sum b_i \ge W$ 可以想到背包的容量，于是以 $b_i$ 为重量，$a_i-mid \times b_i$ 为体积跑 01 背包即可。如果不会 01 背包推荐我的[背包笔记](https://www.luogu.com.cn/article/6gosht8f)。复杂度 $O(nw \log V)$。分数规划结合 01 背包。

```cpp
const int N = 1e5 + 5;

long long n, w, a[N], b[N];
const double eps = 1e-8;

double dp[N];
inline bool check(double x) {
	for (int i = 1; i <= w; i++) dp[i] = -1e9;
	for (int i = 1; i <= n; i++) {
		for (int j = w; j >= 0; j--) {
			dp[min(w, j + b[i])] = max(dp[min(w, j + b[i])], dp[j] + a[i] - x * b[i]);
		}
	} return dp[w] > 0;
}

void _main() {
	cin >> n >> w;
	for (int i = 1; i <= n; i++) cin >> b[i] >> a[i];
	double l = 0.0, r = 1e9;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << (long long) (1000 * l + eps);
}
```

### U589727 最优比率生成树

还是二分，接下来我们以 $a_i-mid \times b_i$ 为边权跑最小生成树，判断边权和是否大于 $0$ 即可。注意本题是完全图，用 prim 跑最小生成树更优。分数规划结合最小生成树。

```cpp
const int N = 1005;
int tot = 0, head[N];
int val[N][N], cost[N][N];
double w[N][N];

int n, m, u, v, x, y;
const double eps = 1e-4;

bool vis[N];
double dis[N];
inline bool check(double x) {
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) w[i][j] = x * cost[i][j] - val[i][j];
	}
	memset(vis, 0, sizeof(vis)), fill(dis + 1, dis + n + 1, -1e9);
	dis[1] = 0;
	for (int i = 1; i < n; i++) {
		int x = 0;
		for (int j = 1; j <= n; j++) {
			if (!vis[j] && (x == 0 || dis[j] > dis[x])) x = j;
		}
		vis[x] = true;
		for (int j = 1; j <= n; j++) {
			if (!vis[j]) dis[j] = max(dis[j], w[x][j]);
		}
	}
	double res = 0;
	for (int i = 2; i <= n; i++) res += dis[i];
	return res > 0;
}

void _main() {
	cin >> n;
	m = n * (n - 1) / 2;
	double l = 0.0, r = 5e6;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> x >> y;
		val[u][v] = val[v][u] = x;
		cost[u][v] = cost[v][u] = y;
	}
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) r = mid - eps;
		else l = mid + eps;
	} cout << fixed << setprecision(2) << l;
}
```

### P3199 [HNOI2009] 最小圈

人话就是求一个环 $C$ 使得 $\dfrac{\sum_{e \in C} w_e}{|C|}$ 最小。还是二分，这题 $b_i=1$，所以以 $a_i-mid$ 为边权。因为我们只需要判最小环是否小于 $0$，所以用 SPFA 判负环即可。分数规划结合 SPFA 判负环。

```cpp
const int N = 1e4 + 5;
const double eps = 1e-10;

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
int n, m, u, v; double w;

deque<int> q;
double dis[N]; int cnt[N];
bitset<N> vis;

inline bool spfa(int s, double x) {
	for (int i = 1; i <= n; i++) dis[i] = 1e9;
	q.clear(), memset(cnt, 0, sizeof(cnt)), vis.reset();
	q.emplace_back(s), dis[s] = 0, vis[s] = 1, cnt[s] = 1;
	while (!q.empty()) {
		int u = q.front(); q.pop_front(), vis[u] = 0;
		if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (++cnt[v] >= n) return true;
				if (vis[v]) continue;
				vis[v] = 1, q.emplace_back(v);
				if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
			}
		}
	}
	return false;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> u >> v >> w, add_edge(u, v, w);
	double l = -1e7, r = 1e7;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (spfa(1, mid)) r = mid;
		else l = mid;
	} cout << fixed << setprecision(8) << l;
}
```

但是这题即使用 SLF+swap 的 SPFA 也只有 90pts，使用玄学的 DFS-SPFA 可以水过：

> 注意：DFS-SPFA 使用必须慎重，其最差复杂度为指数级。

```cpp
double dis[N];
bool vis[N];

bool dfs(int u, double x) {
	vis[u] = true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to; double w = edge[j].dis - x;
		if (dis[v] > dis[u] + w) {
			dis[v] = dis[u] + w;
			if (vis[v] || dfs(v, x)) return true;
		}
	} return vis[u] = false;
}
inline bool check(double x) {
	fill(dis + 1, dis + n + 1, 0.0), fill(vis + 1, vis + n + 1, false);
	for (int i = 1; i <= n; i++) {
		if (dfs(i, x)) return true;
	} return false;
}
```

### P1730 最小密度路径

还是分数规划的模型，二分起手，这题 $a_i=w,b_i=1$，然后以 $w-mid$ 为边权从 $u$ 到 $v$ 跑 SPFA 最短路即可。这题是最小值，所以就是判最短路小于 $0$。因为这题 $q$ 个询问只有 $O(n^2)$ 个本质不同，打个记忆化即可。分数规划结合最短路。

```cpp
const int N = 1005;
const double eps = 1e-5;
int n, m, u, v, w, q;
double ans[N][N];

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
double dis[N];
bool vis[N];
inline bool spfa(int s, int t, double x) {
	fill(dis + 1, dis + n + 1, 1e9), memset(vis, 0, sizeof(vis));
	queue<int> q;
	q.emplace(s), dis[s] = 0, vis[s] = true;
	while (!q.empty()) {
		int u = q.front(); q.pop();
		vis[u] = false;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to; double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (vis[v]) continue;
				vis[v] = true, q.emplace(v);
			}
		}
	} return dis[t] < 0;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w;
		add_edge(u, v, w);
	} cin >> q;
	while (q--) {
		cin >> u >> v;
		if (ans[u][v] != 0) {
			if (ans[u][v] == -1) cout << "OMG!\n";
			else cout << fixed << setprecision(3) << ans[u][v] << '\n';
			continue;
		}
		double l = 0.0, r = 1e5, res = -1;
		while (r - l > eps) {
			double mid = (l + r) / 2.0;
			if (spfa(u, v, mid)) r = mid, res = r;
			else l = mid;
		}
		if (res == -1) ans[u][v] = -1, cout << "OMG!\n";
		else cout << fixed << setprecision(3) << (ans[u][v] = res) << '\n';
	}
}
```

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

## 23. 线性代数

注意到我并没有把高斯消元扔到这里面，因为本人觉得高斯消元不用矩阵更好理解。

## 23.1 向量

以平面直角坐标系为例，一个**向量**可以看作由原点指向某点的一条有向线段，用

$$
\begin{bmatrix} a \\ b
 \end{bmatrix}
$$

 来表示。也可以用 $(a,b)$ 来表示一个向量。

这条有向线段的长度叫做向量的模。对于二维向量

$$
x=\begin{bmatrix} a \\ b
 \end{bmatrix}
$$

 有 $|x|=\sqrt{a^2+b^2}$。

向量代表的是如何从原点移动到终点。所以两个向量相加定义为两次移动叠加的效果，相减就是相加的逆运算。可得

$$
\begin{bmatrix} a \\ b
\end{bmatrix} \pm
\begin{bmatrix} c \\ d
\end{bmatrix} =
\begin{bmatrix} a \pm c \\ b \pm d
\end{bmatrix}
$$

向量也可以做数乘运算，相当于缩放操作。有

$$
c \begin{bmatrix} a \\ b
\end{bmatrix}=\begin{bmatrix} c \times a \\ c \times b
\end{bmatrix}
$$

## 23.2 线性变换

对于向量 $x=\begin{bmatrix} a \\ b \end{bmatrix}$，将它变为 $x'=\begin{bmatrix} ax_1+bx_2 \\ ay_1+by_2 \end{bmatrix}$，这个过程就是一个线性变换。不难发现，将平面上每个点对应的向量都作此变换，直线还是直线，原点还是原点。

注意到，一个二维线性变换仅由 $(x_1,x_2,y_1,y_2)$ 四个数字确定。这可以写作 $2 \times 2$ 的**矩阵**：

$$
\begin{bmatrix}
 x_1 & x_2 \\
 y_1 & y_2
\end{bmatrix}
$$

定义矩阵与向量的乘法就是对这个向量应用线性变换：

$$
Ax=\begin{bmatrix}
 x_1 & x_2 \\
 y_1 & y_2
\end{bmatrix} \begin{bmatrix} a \\ b \end{bmatrix}
=\begin{bmatrix} ax_1+bx_2 \\ ay_1+by_2 \end{bmatrix}
$$

同样地，多个线性变换也可以相互叠加。定义矩阵乘法 $AB$ 表示先应用线性变换 $B$，再应用 $A$。二维矩阵乘法如下：

$$
AB=\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix} \begin{bmatrix}
 e & f \\
 g & h
\end{bmatrix} 
=\begin{bmatrix}
 ae+bg & af+bh \\
 ce+ag & cf+dh
\end{bmatrix}
$$

应当注意，$AB \ne BA$，即矩阵乘法没有交换律。可以想到：先缩放后旋转和先旋转后缩放是不一样的。

但是可以发现，$(AB)C=A(BC)$，也就是矩阵乘法有结合律。这是一个重要的性质，通过这个性质，我们可以使用广义快速幂来计算矩阵的幂。

下面给出矩阵乘法的一般公式。对于 $C=AB$，有

$C_{i,j}=\sum_{k=1}^{n} A_{i,k}B_{k,j}$是一个 $O(n^3)$ 的过程。

矩阵的加减法是简单的，就是同位置的数相加减。注意到矩阵加法满足交换律和结合律。

下面给出一个矩阵的板子。

```cpp
template <class T, const int N>
struct matrix {
	T val[N][N];
	matrix() {clear();}
	void clear() {memset(val, 0, sizeof(val));}
	T* operator[] (int x) {return val[x];}
	void reset() {
		clear();
		for (int i = 0; i < N; i++) val[i][i] = 1;
	}
	matrix<T, N>& operator+= (matrix<T, N> B) {
		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) val[i][j] += B[i][j];
		} return *this;
	}
	matrix<T, N>& operator-= (matrix<T, N> B) {
		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) val[i][j] -= B[i][j];
		} return *this;
	}
	matrix<T, N> operator+ (matrix<T, N> B) {return matrix<T, N>(*this) += B;}
	matrix<T, N> operator- (matrix<T, N> B) {return matrix<T, N>(*this) -= B;}
	matrix<T, N> operator* (matrix<T, N> B) {
		auto& A = *this;
		matrix<T, N> C;
		for (int i = 0; i < N; i++) {
			for (int k = 0; k < N; k++) {
				if (A[i][k] == 0) continue;
				for (int j = 0; j < N; j++) C[i][j] += A[i][k] * B[k][j];
			}
		} return C;
	}
	matrix<T, N>& operator*= (matrix<T, N> B) {return *this = *this * B;}
};
template <class T, const int N>
matrix<T, N> mpow(matrix<T, N> a, long long b) {
	matrix<T, N> res; res.reset();
	for (; b; a *= a, b >>= 1) {
		if (b & 1) res *= a;
	} return res;
}
```

特别地，定义如下形式的矩阵是**单位矩阵**：

$I = \begin{bmatrix} 1 & 0 & \cdots & 0 \\ 0 & 1 & \cdots & 0 \\ \vdots & \vdots & \ddots & \vdots \\ 0 & 0 & \cdots & 1 \end{bmatrix}$有 $A\times I=A$。因此，单位矩阵相当于乘法中的单位“1”。

矩阵快速幂板子：[P3390](https://www.luogu.com.cn/problem/P3390)。

其实矩阵乘法能干的事情很多，比如加速数列递推。矩阵可以描述很多具有结合律的运算，方便我们使用线段树等数据结构维护信息。

## *23.3 广义矩阵乘法

一般地，定义矩阵乘法 $C=AB$ 满足

$C_{i,j}=\bigoplus_{k} A_{i,k} \otimes B_{k,j}$这里的 $\oplus, \otimes$ 都是一种二元运算，不是异或。

这叫做**广义矩阵乘法**。这样的矩阵乘法记作 $(\oplus,\otimes)$。我们可以发现，普通的矩阵乘法是一个 $(+,\times)$ 矩阵。

注意我们使用广义矩阵乘法时一般希望维护一个具有结合律的信息。下面我们给出 $(AB)C=A(BC)$ 的判定定理：

- 当且仅当 $\oplus$ 满足交换律，$\otimes$ 满足结合律，$\otimes$ 对 $\oplus$ 满足分配律时，广义矩阵乘法有结合律。

例如矩阵乘法 $(\max,\min)$ 的判定。注意到 $\max$ 对 $\min$ 的分配律：

$\max(\min(a,b),c)=\min(\max(a,c),\max(b,c))$常见的有结合律的广义矩阵乘法有：$(+,\times)$，$(\max,+)$，$(\max,\min)$ 等。下面是一个广义矩阵乘法的板子。

```cpp
template <class T, const int N, class Op1, class Op2, const T o = 0>
struct matrix {
	Op1 op1{}; Op2 op2{};
	T val[N][N];
	T* operator[] (int x) {return val[x];}
	matrix<T, N, Op1, Op2, o> operator* (matrix<T, N, Op1, Op2, o> B) {
		auto& A = *this;
		matrix<T, N, Op1, Op2, o> C;
		for (int i = 0; i < N; i++) {
			fill(C[i], C[i] + N, o);
			for (int k = 0; k < N; k++) {
				for (int j = 0; j < N; j++) C[i][j] = op1(C[i][j], op2(A[i][k], B[k][j]));
			}
		} return C;
	}
	matrix<T, N, Op1, Op2, o>& operator*= (matrix<T, N, Op1, Op2, o> B) {return *this = *this * B;}
};
template <class T>
struct AddOP {
	constexpr T operator() (T a, T b) {return a + b;}
};
template <class T>
struct MinOP {
	constexpr T operator() (T a, T b) {return min(a, b);}
};
template <class T>
struct MaxOP {
	constexpr T operator() (T a, T b) {return max(a, b);}
};
```

在一些题目中，我们会使用数据结构来维护具有结合律的广义矩阵乘法。动态 DP 就使用了这种技巧。

## 23.4 例题

### P10502 Matrix Power Series

矩阵的等比数列求和，考虑使用分治求和法优化。实现一个矩阵快速幂然后分治求和，复杂度为 $O(n^3 \log^2 k)$。

```cpp
using node = matrix<int, 30>;
int n, k, p;
node A;
node sum(node k, int n) {
	if (n == 1) return k;
	node A; A.reset();
	A = (A + mpow(k, n >> 1)) * sum(k, n >> 1);
	if (n & 1) A += mpow(k, n);
	return A;
}
void _main() {
	cin >> n >> k >> p;
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) cin >> A.val[i][j];
	}
	node B = sum(A, k);
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) cout << B.val[i][j] << ' ';
		cout << '\n';
	}
}
```

### P1962 斐波那契数列

矩阵应用之一：优化数列递推。

用矩阵优化 $f_n=f_{n-1}+f_{n-2}$ 这个递推。我们希望找到一个矩阵，将 $\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}$ 变换为 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}$。考虑待定系数，设矩阵

$$
A=\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}
$$

，列方程：

$$
\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}=\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}
$$

根据矩阵乘向量的定义拆开，然后得到：

$$
\left\{\begin{matrix}
f_n=af_{n-1}+bf_{n-2} \\
f_{n-1}=cf_{n-1}+df_{n-2}
\end{matrix}\right.
$$

观察可得，$a=1,b=1,c=1,d=0$ 时符合递推式。故

$$
A=\begin{bmatrix}
 1 & 1 \\
 1 & 0
\end{bmatrix}
$$

。根据数学归纳法可得 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}=A^{i-2} \begin{bmatrix} 1\\ 1\end{bmatrix}$。使用矩阵快速幂优化，复杂度 $O(\log n)$。

```cpp
long long n;
void _main() {
	matrix<mint, 2> A;
	A.val[0][0] = A.val[0][1] = A.val[1][0] = 1;
	cin >> n;
	if (n <= 2) return cout << 1, void();
	auto M = mpow(A, n - 2);
	cout << M.val[0][0] + M.val[0][1];
}
```

### P1349 广义斐波那契数列

和上题差不多，设矩阵 $A$ 表示一次变换，列方程：

$$
\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}=\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}
$$

写成方程组：

$$
\left\{\begin{matrix}
f_n=af_{n-1}+bf_{n-2} \\
f_{n-1}=cf_{n-1}+df_{n-2}
\end{matrix}\right.
$$

对比递推式 $f_n=p \times f_{n-1}+q\times f_{n-2}$ 可得

$$
A=\begin{bmatrix}
 p & q \\
 1 & 0
\end{bmatrix}
$$

同理 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}=A^{i-2} \begin{bmatrix} 1\\ 1\end{bmatrix}$。代码就不给了。

### P1939 矩阵加速（数列）

考虑一次变换让 $\begin{bmatrix} a_{n-1} \\ a_{n-2} \\a_{n-3} \end{bmatrix}$ 变成 $\begin{bmatrix} a_{n} \\ a_{n-1} \\a_{n-2} \end{bmatrix}$。设矩阵

$$
A=\begin{bmatrix}
a & b & c \\
d & e & f \\
i & j & k 
\end{bmatrix}
$$

写成方程组就有

$$
\left\{\begin{matrix}
a_n=a\times a_{n-1}+b \times a_{n-2}+c\times a_{n-3}\\
a_{n-1}=d\times a_{n-1}+e \times a_{n-2}+f\times a_{n-3}\\
a_{n-2}=i\times a_{n-1}+j \times a_{n-2}+k\times a_{n-3}
\end{matrix}\right.
$$

对比递推式 $a_n=a_{n-1}+a_{n-3}$，得到

$$
A=\begin{bmatrix}
1 & 0 & 1 \\
1 & 0 & 0 \\
0 & 1 & 0 
\end{bmatrix}
$$

答案为 $(A^n)_{2,1}$。

### *P3216 [HNOI2011] 数学作业

不难得出

$C(n)=C(n-1) \times 10^{1+ \lfloor \lg n\rfloor }+n$直接递推做复杂度为 $O(n)$。通过转移方程发现 $C(n)$ 与 $n,n-1$ 有关，所以我们希望有矩阵将 $\begin{bmatrix} C(n-1) \\ n-1 \\n\end{bmatrix}$ 变换为 $\begin{bmatrix} C(n) \\ n+1 \\n\end{bmatrix}$。仍然可以待定系数并对照递推式，得到

$$
\begin{bmatrix} C(n) \\ n+1 \\n\end{bmatrix}=
\begin{bmatrix}
10^{1+\lfloor \lg n \rfloor} & 0 & 1 \\
0 & 0 & 1 \\
0 & -1 & 2
\end{bmatrix}
\begin{bmatrix} C(n-1) \\ n-1 \\n\end{bmatrix}
$$

矩阵快速幂即可，复杂度 $O(\log^2 n)$。这题还有一个 $O(\log^3 n)$ 的广义快速幂 + 分治求和的做法。

```cpp
void _main() {
	cin >> n >> p; n++;
	pw[0] = 1;
	for (int i = 1; i < 30; i++) pw[i] = pw[i - 1] * 10;
	matrix<int, 3> A, V;  // V为向量，A为矩阵
	V.val[2][0] = 1, A.val[0][2] = 1, A.val[1][2] = 1, A.val[2][1] = -1, A.val[2][2] = 2;
	for (int i = 1; i < 30; i++) {
		A.val[0][0] = pw[i] % p;
		if (n < pw[i]) {
			V *= mpow(A, n - pw[i - 1]);
			return cout << (V.val[0][0] % p + p) % p, void();
		}
		V *= mpow(A, pw[i] - pw[i - 1]);
	}
}
```

### *P3990 [SHOI2013] 超级跳马

矩阵应用之二：矩阵优化 DP。

考虑计数 DP，令 $dp_{i,j}$ 表示跳到 $(i,j)$ 的方案数。显然有转移

$dp_{i,j}=\sum_{k \bmod 2=1} (dp_{i-1,j-k}+dp_{i,j-k}+dp_{i+1,j-k})$这是 $O(nm^2)$ 的。考虑对奇偶行维护前缀和来优化，设 $f_{i,j}=\sum_{k \bmod 2=1} dp_{i,j-k}$，有 $f_{i,j}=f_{i,j-2}+dp_{i,j}$，则转移方程改写为

$dp_{i,j}=f_{i-1,j-1}+f_{i,j-1}+f_{i+1,j-1}$代入 $f$ 的转移方程得

$f_{i,j}=f_{i-1,j-1}+f_{i,j-1}+f_{i+1,j-1}+f_{i,j-2}$优化到 $O(nm)$。注意到这是一个线性递推的式子，考虑矩阵快速幂优化 DP。

我们希望找到一个矩阵 $A$，使得向量 $(f_{1,j},f_{2,j},\cdots,f_{n,j},f_{1,j-1},f_{2,j-1},\cdots,f_{n,j-1})$ 在乘上 $A$ 后变为 $(f_{1,j+1},f_{2,j+1},\cdots,f_{n,j+1},f_{1,j},f_{2,j},\cdots,f_{n,j})$。这是容易的，根据转移方程的系数构造即可。最后的答案为 $dp_{n,m}=f_{n,m}-f_{n,m-2}$。复杂度 $O(n^3 \log m)$。

这个题告诉我们：DP 状态一维很小，一维很大时，就要考虑矩阵快速幂优化 DP 了。

```cpp
int n, m;
matrix<mint, 100> A;
mint f(int n, int m) {
	if (m <= 0) return 0;
	matrix<mint, 100> B;
	B.val[0][0] = 1;
	auto C = B * mpow(A, m - 1);
	return C.val[0][n - 1];
}

void _main() {
	cin >> n >> m;
	for (int i = 0; i < n; i++) {
		A.val[i][i] = 1, A.val[i + n][i] = 1, A.val[i][i + n] = 1;
		if (i != 0) A.val[i - 1][i] = 1;
		if (i != n - 1) A.val[i + 1][i] = 1;
	}
	cout << f(n, m) - f(n, m - 2);
}
```

### P9893 [ICPC 2018 Qingdao R] Soldier Game

考虑 DP。有两种 DP 都能得到 $O(n^2)$ 做法，但只有下面这种是有前途的：枚举最小值 $c$，设 $dp_i$ 表示考虑到 $i$ 的最小 $\max$。容易得到转移：

$dp_i=\min(\max(dp_{i-1},a_i),\max(dp_{i-2},a_{i-1}+a_i))$要求 $a_i \ge c$ 和 $a_{i-1}+a_i \ge c$。注意到 $c$ 只有 $2n$ 种，可以 $O(n^2)$ 解决。

这本身是一个线性 DP，而且这个转移可以想到 $(\min,\max)$ 广义矩阵乘法。可以用一棵线段树来维护矩阵的积。具体地：

$$
\begin{bmatrix}dp_i\\ dp_{i-1}\end{bmatrix}\begin{bmatrix}
a_i & a_i+a_{i-1} & \\
-\infty & \infty 
\end{bmatrix}=\begin{bmatrix}dp_{i-1}\\ dp_{i-2}\end{bmatrix}
$$

这里的乘法是 $(\min,\max)$ 乘法。待定系数一下即可得到。然后我们实现一个单点修改全局查询的线段树即可，复杂度 $O(n \log n)$ 带八倍常数。

```cpp
const int N = 1e6 + 5;
const long long inf = 1e18;
long long n, a[N];
using node = matrix<long long, 2, MaxOP<long long>, MinOP<long long>, -inf>;
struct segtree {
#define ls (rt << 1)
#define rs (rt << 1 | 1)
	node I, B, sum[N << 2];
	segtree() {
		I[0][0] = inf, I[0][1] = -inf, I[1][0] = -inf, I[1][1] = inf;
		B[0][0] = -inf, B[0][1] = inf, B[1][0] = -inf, B[1][1] = -inf;
	}
	void pushup(int rt) {sum[rt] = sum[ls] * sum[rs];}
	void build(int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt] = B, void();
		int mid = (l + r) >> 1;
		build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
	}
	void update(int x, long long c, int typ, int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt][typ][0] = c, void();
		int mid = (l + r) >> 1;
		if (x <= mid) update(x, c, typ, l, mid, ls);
		else update(x, c, typ, mid + 1, r, rs);
		pushup(rt);
	}
} sgt;

vector<tuple<int, int, int>> vec;
void _main() {
	//debug(sizeof(f) / 1048576.0);
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	vec.clear();
	for (int i = 1; i <= n; i++) {
		vec.emplace_back(a[i], i, 0);
		if (i > 1) vec.emplace_back(a[i - 1] + a[i], i, 1);
	}
	sort(vec.begin(), vec.end());
	sgt.build();
	long long res = inf;
	for (const auto& info : vec) {
		long long v = get<0>(info), x = get<1>(info), typ = get<2>(info);
		sgt.update(x, v, typ);
		node A; A[0][0] = A[0][1] = inf, A[1][0] = A[1][1] = -inf, A *= sgt.sum[1];
		//mdebug(v, A[0][0]);
		res = min(res, v - A[0][0]);
	} cout << res << '\n';
}
```

### *P6772 [NOI2020] 美食家

看到这种很复杂的约束，考虑拆点 / 拆边。注意到 $w_i \in [1,5]$，直接将边权拆开，花费 $w_i$ 天转化为经过 $w_i$ 个点。

考虑图上 DP，设 $dp_{i,u}$ 表示经过 $i$ 个点，当前位于点 $u$ 的最大愉悦值。不考虑美食节可得转移

$dp_{i+1,v}=\max_{(u,v)} (dp_{i,u}+c_v)$对于美食节，初始化时将 $dp_{t_i,x_i}$ 加上 $y_i$ 即可。进行 $T$ 轮转移，复杂度 $O(Tnw)$。

考虑 $(\max,+)$ 广义矩阵乘法。对于边 $(u,v)$，转移矩阵 $A$ 满足 $A_{u,v}=c_v$，再设初始值为向量 $a$，则 $k$ 轮转移就是 $A^k a$。其中 $a_1=c_1$。

直接矩阵快速幂不可行，可以预处理 $A^{2^k}$，多次转移直接倍增处理。复杂度 $O(n^3w^3k \log T)$，无法通过。

注意到倍增可以 $O(n^3w^3 \log T)$ 完成，瓶颈在转移，使用 $O(n^2w^2)$ 的矩阵乘向量即可。总复杂度 $O(n^3w^3 \log T+n^2w^2k\log T)$。

不会写代码，抄的深进。

```cpp
const int N = 255;
long long A[31][N][N], dp[2][N];
int n, m, t, k, u, v, w, val[N];
int f(int x, int y) {return x * n + y - 1;}
struct node {
	int t, x, y;
} a[N];

void _main() {
	cin >> n >> m >> t >> k;
	for (int i = 1; i <= n; i++) cin >> val[i];
	memset(A, 0xcf, sizeof(A));
	for (int i = 0; i < 4; i++) {
		for (int j = 1; j <= n; j++) A[0][f(i, j)][f(i + 1, j)] = 0;
	}
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w;
		A[0][f(4, v)][f(5 - w, u)] = val[v];
	}
	for (int s = 0; s < 30; s++) {
		for (int i = 0; i < n * 5; i++) {
			for (int k = 0; k < n * 5; k++) {
				for (int j = 0; j < n * 5; j++) {
					A[s + 1][i][k] = max(A[s + 1][i][k], A[s][i][j] + A[s][j][k]);
				}
			}
		}
	}
	memset(dp, 0xcf, sizeof(dp));
	int st = 0;
	dp[0][f(4, 1)] = val[1];
	auto trans = [&](int s) -> void {
		for (int d = 0; d < 30; d++) {
			if (!(s >> d & 1)) continue;
			st ^= 1;
			memset(dp[st], 0xcf, sizeof(dp[st]));
			for (int i = 0; i < 5 * n; i++) {
				for (int j = 0; j < 5 * n; j++) {
					dp[st][i] = max(dp[st][i], dp[st ^ 1][j] + A[d][i][j]);
				}
			}
		}
	};
	for (int i = 1; i <= k; i++) cin >> a[i].t >> a[i].x >> a[i].y;
	sort(a + 1, a + k + 1, [](const node& a, const node& b) -> bool {
		return a.t < b.t;
	});
	for (int i = 1; i <= k; i++) {
		trans(a[i].t - a[i - 1].t);
		dp[st][f(4, a[i].x)] += a[i].y;
	}
	trans(t - a[k].t);
	cout << (dp[st][f(4, 1)] < 0 ? -1 : dp[st][f(4, 1)]);
}
```

### P7453 [THUSC 2017] 大魔法师

矩阵应用之三：维护结合律信息，与数据结构结合。

题目所给的是一堆区间操作和全局查询，自然想到线段树。但是这题的修改太过复杂，普通的线段树懒标记难以维护。考虑在线段树上每个节点维护一个向量，修改用矩阵表示，这样懒标记用矩阵记录就好了。

我们需要一个四维向量 $\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}$ 来表示信息。这里有一个常数 $1$ 的原因是，修改 4&5 涉及对常数 $v$ 的操作。如果你只设计三维，会发现怎么也推不出来。

现在分别考虑修改即可。前三种修改是类似的，使用待定系数法得到

$$
\begin{bmatrix}
1 & 1 & 0 & 0\\
0 & 1 & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i+B_i\\ B_i\\ C_i\\ 1\end{bmatrix}
$$

后面两种就不给了。

第四种和第五种在单位矩阵的基础上微调即可：

$$
\begin{bmatrix}
1 & 0 & 0 & v\\
0 & 1 & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i+v\\ B_i\\ C_i\\ 1\end{bmatrix}
$$

$$
\begin{bmatrix}
1 & 0 & 0 & 0\\
0 & v & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i\\ vB_i\\ C_i\\ 1\end{bmatrix}
$$

单点覆盖仍然微调单位矩阵，通过对角线上的 $0$ 先归零再加回去：

$$
\begin{bmatrix}
1 & 0 & 0 & 0\\
0 & 1 & 0 & 0\\
0 & 0 & 0 & v\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i\\ B_i\\ v\\ 1\end{bmatrix}
$$

至此我们可以在 $O(n \log n)$ 的时间内解决这个问题。但是矩阵的常数有 $4^3=64$ 倍，需要比较精细的实现。

```cpp
const int N = 2.5e5 + 5;
using node = matrix<mint, 4>;

int n, q, opt, l, r, v;
node A[10], a[N];

#define ls (rt << 1)
#define rs (rt << 1 | 1)
node sum[N << 2], tag[N << 2];
void pushup(int rt) {sum[rt] = sum[ls] + sum[rs];}
void pushdown(int rt) {
	sum[ls] *= tag[rt], sum[rs] *= tag[rt];
	tag[ls] *= tag[rt], tag[rs] *= tag[rt];
	tag[rt].reset();
}
void build(int l = 1, int r = n, int rt = 1) {
	tag[rt].reset();
	if (l == r) return sum[rt] = a[l], void();
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}
void change(int tl, int tr, const node& c, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return sum[rt] *= c, tag[rt] *= c, void();
	pushdown(rt);
	int mid = (l + r) >> 1;
	if (tl <= mid) change(tl, tr, c, l, mid, ls);
	if (tr > mid) change(tl, tr, c, mid + 1, r, rs);
	pushup(rt);
}
node query(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return sum[rt];
	int mid = (l + r) >> 1; node res;
	pushdown(rt);
	if (tl <= mid) res += query(tl, tr, l, mid, ls);
	if (tr > mid) res += query(tl, tr, mid + 1, r, rs);
	return res;
}

void _main() {
	read(n);
	for (int i = 1; i <= n; i++) {
		read(a[i].val[0][0].val, a[i].val[0][1].val, a[i].val[0][2].val);
		a[i].val[0][3] = 1;
	}
	build();
	for_each(A, A + 10, [](node& x) {x.reset();});
	A[1].val[1][0] = A[2].val[2][1] = A[3].val[0][2] = 1, A[6].val[2][2] = 0;
	for (read(q); q--; ) {
		read(opt, l, r);
		if (opt <= 3) {
			change(l, r, A[opt]);
		} else if (opt <= 6) {
			read(v);
			A[4].val[3][0] = A[5].val[1][1] = A[6].val[3][2] = v;
			change(l, r, A[opt]);
		} else {
			node res = query(l, r);
			writesp(res.val[0][0].val), writesp(res.val[0][1].val), writeln(res.val[0][2].val);
		}
	} flush();
}
```

### *P4719 【模板】动态 DP

矩阵应用之四：维护带修改的 DP，即动态 DP。

前置知识：重链剖分。

其实并不板。考虑不带修的做法，经典 DP。设 $f_{0/1,u}$ 表示选 / 不选 $u$ 点的最大独立集。则

$$
f_{0,u}=\sum_{(v,u)} \max(f_{0,v},f_{1,v})\\
f_{1,u}=a_u+\sum_{(v,u)} f_{0,v}
$$

答案为 $\max(f_{0,1},f_{1,1})$。

观察转移方程，每次更改点权只需修改一条树链。但如果随意找，每次更新的复杂度会达到 $O(n)$。

对树作一次重链剖分。这样每个点到根的路径上只会经过 $O(\log n)$ 条重链。为了适应重儿子的性质，定义 $g_{0/1,u}$ 表示 $u$ 点的所有轻儿子无限制 / 不能取且取自己的最大独立集。于是

$$
f_{0,u}=g_{0,u}+\max(f_{0,son_u},f_{1,son_u})\\
f_{1,u}=g_{1,u}+f_{0,son_u}
$$

其中 $son_u$ 代表轻儿子。这样我们就去掉了求和。

变形：

$$
f_{0,u}=\max(f_{0,son_u}+g_{0,u},f_{1,son_u}+g_{0,u})\\
f_{1,u}=\max(g_{1,u}+f_{0,son_u},-\infty)
$$

定义 $(\max,+)$ 的广义矩阵乘法。待定系数一下得到

$$
\begin{bmatrix}
g_{0,u} & g_{0,u} & \\
g_{1,u} & -\infty & \\
\end{bmatrix}\begin{bmatrix}f_{0,v}\\ f_{1,v}\end{bmatrix}=\begin{bmatrix}dp_{0,u}\\ dp_{1,u}\end{bmatrix}
$$

此时的矩阵应该写在左边。因为重剖过程是先链头后链尾。于是我们在 DFS 序上建一棵线段树，问题解决。复杂度 $O(n \log^2 n)$，$4$ 倍常数。

```cpp
const int N = 1e5 + 5, inf = 1e9;
using node = matrix<int, 2, MaxOP<int>, AddOP<int>, -inf>;
int n, q, a[N], u, v;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int num, sz[N], fa[N], son[N], top[N], dfn[N], ed[N], id[N], f[2][N], g[2][N];
void dfs1(int u) {
	sz[u] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		fa[v] = u, dfs1(v), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int t) {
	top[u] = t, dfn[u] = ++num, id[num] = u;
	if (!son[u]) return ed[t] = num, void();
	dfs2(son[u], t);
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa[u] && v != son[u]) dfs2(v, v);
	}
}
void dfs3(int u) {
	f[1][u] = g[1][u] = a[u];
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		dfs3(v);
		f[0][u] += max(f[0][v], f[1][v]), f[1][u] += f[0][v];
		if (v != son[u]) g[0][u] += max(f[0][v], f[1][v]), g[1][u] += f[0][v];
 	}
}

node B[N];
struct segtree {
#define ls (rt << 1)
#define rs (rt << 1 | 1)
	node sum[N << 2];
	void pushup(int rt) {sum[rt] = sum[ls] * sum[rs];}
	void build(int l = 1, int r = n, int rt = 1) {
		if (l == r) {
			sum[rt][0][0] = sum[rt][0][1] = g[0][id[l]];
			sum[rt][1][0] = g[1][id[l]], sum[rt][1][1] = -inf;
			B[l] = sum[rt];
			return;
		}
		int mid = (l + r) >> 1;
		build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
	}
	void change(int x, int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt] = B[l], void();
		int mid = (l + r) >> 1;
		if (x <= mid) change(x, l, mid, ls);
		else change(x, mid + 1, r, rs);
		pushup(rt);
	}
	node query(int tl, int tr, int l = 1, int r = n, int rt = 1) {
		if (tl <= l && r <= tr) return sum[rt];
		int mid = (l + r) >> 1;
		if (tr <= mid) return query(tl, tr, l, mid, ls);
		if (tl > mid) return query(tl, tr, mid + 1, r, rs);
		return query(tl, tr, l, mid, ls) * query(tl, tr, mid + 1, r, rs);
	}
} sgt;

node ask(int x) {return sgt.query(dfn[x], ed[top[x]]);}
void change(int u, int c) {
	B[dfn[u]][1][0] += c - a[u], a[u] = c;
	for (; u; u = fa[top[u]]) {
		node last = ask(top[u]);
		sgt.change(dfn[u]);
		node cur = ask(top[u]);
		int p = dfn[fa[top[u]]];
		B[p][0][0] += max(cur[0][0], cur[1][0]) - max(last[0][0], last[1][0]);
		B[p][0][1] += max(cur[0][0], cur[1][0]) - max(last[0][0], last[1][0]);
		B[p][1][0] += cur[0][0] - last[0][0];
	}
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	dfs1(1), dfs2(1, 1), dfs3(1), sgt.build();
	while (q--) {
		cin >> u >> v;
		change(u, v);
		node res = ask(1);
		cout << max(res[0][0], res[1][0]) << '\n';
	}
}
```

### *P5024 [NOIP 2018 提高组] 保卫王国

注意到，最小覆盖集 = 全集 - 最大独立集。

于是和模板题的区别在于不是修改点权，而是强制两个点是否属于最大独立集，同时操作独立。

把点权改成正 / 负无穷即可实现强制属于独立集。于是套用模板题的做法就行了。

### *P8820 [CSP-S 2022] 数据传输

困难的。从部分分开始思考。

- $k=1$ 是简单的，答案就是路径上的点权之和。求个 LCA 即可 $O(n \log n)$。
- $k=2$ 时，手玩可以发现跳到儿子再跳回来一定不优。于是最优方案只经过路径上的点。

将这条链拿出来 DP。设 $dp_{i}$ 表示跳到第 $i$ 个点的最小代价，则 $dp_{i}=\min(dp_{i-1},dp_{i-2})+a_i$。复杂度 $O(qn \log n)$。

考虑树上动态 DP。定义 $(\min,+)$ 广义矩阵乘法：

$\forall C=AB,C_{i,j}=\min_{k} (A_{i,k}+B_{k,j})$待定系数容易得到

$$
\begin{bmatrix}
a_i & a_i & \infty \\
0 & \infty & \infty \\
\infty & \infty & 0
\end{bmatrix}\begin{bmatrix}dp_{i-1}\\ dp_{i-2}\\0\end{bmatrix}=\begin{bmatrix}dp_{i}\\ dp_{i-1}\\0\end{bmatrix}
$$

这里为了与 $k=3$ 统一，用的是三维矩阵。实际上两维就够了。

- $k=3$ 时，最优方案可能由一个一个儿子跳到另一个儿子。注意到，最优方案上只有一条路径和一些儿子。

仍然将链拿出来，形成一个毛毛虫结构。将 LCA 的父亲也视为儿子。

设 $dp_{0/1/2,i}$ 表示跳到离点 $i$ 距离为 $0/1/2$ 的最小代价。记 $s_i$ 表示 $i$ 的最小代价儿子。可得转移

$$
\begin{aligned}
dp_{0,i}&=\min(dp_{0,i-1}+dp_{1,i-1},dp_{2,i-1})+a_i\\
dp_{1,i}&=\min(dp_{0,i}+s_i,dp_{0,i-1}+s_i,dp_{1, i-1}+s_i,dp_{0,i-1})\\
dp_{2,i}&=dp_{1,i-1}
\end{aligned}
$$

考虑动态 DP。我们需要把 $dp_{1,i}$ 的转移变成下标只有 $i-1$ 的式子。代入 $dp_{0,i}$ 的转移方程得到

$dp_{1,i}=\min(dp_{0,i-1},dp_{1,i-1}+s_i,dp_{2,i-1}+a_i+s_i)$耐心地推出转移矩阵：

$$
\begin{bmatrix}
a_i & a_i & a_i \\
0 & s_i & a_i+s_i \\
\infty & 0 & \infty
\end{bmatrix}\begin{bmatrix}dp_{0,i-1}\\ dp_{1,i-1}\\dp_{2,i-1}\end{bmatrix}=\begin{bmatrix}dp_{0,i}\\ dp_{1,i}\\dp_{2,i}\end{bmatrix}
$$

用树上倍增维护一条链的正序积和倒序积，可以做到 $O(nk^3 \log n)$，细节很多。

> 为什么不用树剖维护？
>
> 树剖直接维护只能做正序积，无法维护倒序积，需要重推一遍转移矩阵。但是树上倍增的过程中直接交换递推顺序是对的。

```cpp
const int N = 2e5 + 5;
const long long inf = 1e15;
using node = matrix<long long, 3, MinOP<long long>, AddOP<long long>, inf>;

int n, q, k, u, v;
long long a[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

int dep[N], sz[N], fa[N], son[N], top[N];
long long s[N], dis[N];
void dfs1(int u) {
	sz[u] = 1, dis[u] = dis[fa[u]] + a[u], dep[u] = dep[fa[u]] + 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		fa[v] = u, dfs1(v), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int t) {
	top[u] = t;
	if (son[u]) dfs2(son[u], t);
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa[u] && v != son[u]) dfs2(v, v);
	}
}
int lca(int u, int v) {
	while (top[u] != top[v]) {
		if (dep[top[u]] < dep[top[v]]) swap(u, v);
		u = fa[top[u]];
	} return dep[u] < dep[v] ? u : v;
}
int pa[20][N];
node I, B[N], mul[20][N], rmul[20][N];
void dfs3(int u) {
	pa[0][u] = fa[u], mul[0][u] = rmul[0][u] = B[u];
	for (int i = 1; i < 20; i++) {
		pa[i][u] = pa[i - 1][pa[i - 1][u]];
		mul[i][u] = mul[i - 1][u] * mul[i - 1][pa[i - 1][u]];
		rmul[i][u] = rmul[i - 1][pa[i - 1][u]] * rmul[i - 1][u];
	}
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		dfs3(v);
	}
}
node ask(int u, int v) {
	node x = I, y = I;
	if (dep[u] < dep[v]) y = B[v], v = fa[v];
	for (int i = 19; i >= 0; i--) {
		if (dep[pa[i][u]] >= dep[v]) x = rmul[i][u] * x, u = pa[i][u];
	}
	if (u == v) return y * B[u] * x;
	for (int i = 19; i >= 0; i--) {
		if (pa[i][u] == pa[i][v]) continue;
		x = rmul[i][u] * x, y = y * mul[i][v];
		u = pa[i][u], v = pa[i][v];
	} return y * B[v] * B[fa[v]] * B[u] * x;
}

void _main() {
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			if (i != j) I[i][j] = inf;
		}
	}
	cin >> n >> q >> k;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fill(s + 1, s + n + 1, inf);
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
		s[u] = min(s[u], a[v]), s[v] = min(s[v], a[u]);
	}
	dfs1(1), dfs2(1, -1);
	if (k == 1) {
		while (q--) {
			cin >> u >> v;
			int f = lca(u, v);
			cout << dis[u] + dis[v] - 2 * dis[f] + a[f] << '\n';
		} return;
	}
	B[0] = I;
	for (int i = 1; i <= n; i++) {
		node& A = B[i];
		if (k == 2) {
			A[0][0] = A[0][1] = a[i];
			A[1][0] = A[2][2] = 0;
			A[0][2] = A[1][1] = A[1][2] = A[2][0] = A[2][1] = inf;
		} else {
			A[0][0] = A[0][1] = A[0][2] = a[i];
			A[1][0] = A[2][1] = 0;
			A[1][1] = s[i], A[1][2] = a[i] + s[i];
			A[2][0] = A[2][2] = inf;
		}
	}
	dfs3(1);
	while (q--) {
		cin >> u >> v;
		if (u == v) {cout << a[u] << '\n'; continue;}
	 	if (dep[u] < dep[v]) swap(u, v);
		node x = ask(fa[u], v), y = I;
		if (k == 2) y[0][0] = a[u];
		else y[0][0] = a[u], y[0][1] = a[u] + s[u];
		x *= y, cout << x[0][0] << '\n';
	}
}
```

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

## 25. 同余最短路

同余最短路是一个使用图论方法解决数论问题的 trick。

## 25.1 适用范围

当题目中存在类似 $f(i+x)=f(i)+x$ 的转移关系时，可以考虑利用同余的性质建立图论模型，在上面跑最短路求解。

常见的同余最短路的模型有：

1. 给出 $n$ 个数 $a_i$，求有多少个 $b \in [0,T]$ 且满足 $\sum_{i=1}^n a_ix_i=b$ 有非负整数解。
2. 体积模 $m$ 意义下的完全背包问题。

由于这个说法过于抽象，因此下面给出一些例题，请读者结合例题学习。另外，这里不讲转圈 trick。

## 25.2 例题

### P3403 跳楼机

就是求 $k \in [0,h)$ 时有多少个 $k$ 满足不定方程 $ax+by+cz=k$。

观察到，若 $k$ 合法，则 $k+ap < h$ 也合法。证明：$k+ap=a(x+p)+by+cz$。

注意到 $k \equiv k+ap \pmod a$，则对于合法的 $k$，满足 $k \equiv k' \pmod a$ 的所有 $k' < h$ 合法，数目为 $\lfloor \dfrac{h-k}{a} \rfloor+1$。

设 $d_i$ 表示模 $a$ 余 $i$ 的 $k$ 中的最小值，只要求出 $d_0 \sim d_{a-1}$。到这里用数论方法就做不下去了。

考虑一个数 $k$，且 $r=k \bmod a$。

- $k \gets k+a$，$r$ 不变。
- $k \gets k+b$，$r \gets (r+b) \bmod a$。
- $k \gets k+c$，$r \gets (r+c) \bmod a$。

显然第一条转移对于 $d_i$ 无影响。考虑剩下两条转移，可以写成这个形式：

$$
d_r \to d_{(r+b) \bmod a}\\
d_r \to d_{(r+c) \bmod a}\\
$$

将 $d$ 作为单源最短路的距离数组，将 $d_i$ 视为一个点，进行图论建模：

- $d_0=0$。
- $d_{1},d_{2},\cdots,d_{a-1}=+\infty$。
- $x \to (x+b) \bmod a$，边权为 $b$。
- $x \gets (x+c) \bmod c$，边权为 $c$。

由 $0$ 开始跑最短路，即可得到所有的 $d$。

到这里我们可以解释同余最短路名字的来源：一个点代表一个同余类，通过同余关系建边求得某种最小值，进而计算答案。

需要注意，由于同余最短路中是根据同余关系建边，无法使得 SPFA 达到最坏复杂度 $O(nm)$，因此可以在同余最短路中使用 SPFA 求最短路。下面给出一个省略 SPFA 板子的代码。

```cpp
#define int long long
const int N = 1e5 + 5;
int h, s[3], a, b, c;

void _main() {
	cin >> h >> s[0] >> s[1] >> s[2];
	sort(s, s + 3), a = s[0], b = s[1], c = s[2], h--;
	for (int i = 0; i < a; i++) {
		add_edge(i, (i + c) % a, c);
		add_edge(i, (i + b) % a, b);
	}
	SPFA::spfa(0);
	int res = 0;
	for (int i = 0; i < a; i++) {
		if (h >= SPFA::dis[i]) res += (h - SPFA::dis[i]) / a + 1;
	}
	cout << res;
}
```

### P2371 [国家集训队] 墨墨的等式

注意到这是上一题的 $n$ 元版本，并且对于 $b$ 有约束 $b \in [l,r]$。利用 $[l,r]=[1,r]-[1,l-1]$ 就能去掉这个限制。

先对 $a$ 排序，以 $a_1$ 为模数建立同余关系：

- $x \to (x+a_i) \bmod a_1$。其中 $i \in [2,n], x \in [0,a)$，边权为 $a_i$。

跑 SPFA 即可。注意特判 $a_i=0$，并且开大空间。

这里需要注意一个点：模数应该选的尽量小。在同余最短路的题目中，边数常常为 $O(nM)$ 级别，其中 $M$ 是模数。这里我们就取 $M=\min a_i$ 最好。

```cpp
#define int long long
const int N = 6e6 + 5;

int m, n, l, r, x, a[N];
long long query(long long x) {
	long long res = 0;
	for (int i = 0; i < a[1]; i++) {
		if (x >= SPFA::dis[i]) res += (x - SPFA::dis[i]) / a[1] + 1;
	} return res;
}

void _main() {
	cin >> m >> l >> r;
	for (int i = 1; i <= m; i++) {
		cin >> x;
		if (x != 0) a[++n] = x;
	}
	sort(a + 1, a + n + 1);
	for (int x = 0; x < a[1]; x++) {
		for (int i = 2; i <= n; i++) add_edge(x, (x + a[i]) % a[1], a[i]);
	}
	SPFA::spfa(0);
	cout << query(r) - query(l - 1);
}
```

### [模拟赛] 星际保安

> 给你一个由四个节点组成的环，求从节点 $2$ 出发，回到节点 $2$ 的不小于 $k$ 的最短路。
>
> $k \le 10^{18}$，环的边权 $\le 3 \times 10^4$。

赛时整了一个假的裴蜀定理解七元不定方程做法水过去了，喜提全场唯一 AK。赛后被 hack 了。

设从 $2$ 到 $2$ 的最短路为 $d$，$2$ 号节点连接的两条边的较小边权为 $w=\min(d_{1,2},d_{2,3})$，则可以进行 $x$ 次往返使得 $d+2wx \ge k$。其他往返方案也类似，这样就是一个不定方程问题。

以 $2w$ 为模数尝试同余最短路。设 $f_{x,i}$ 表示最短路模 $2w$ 的余数为 $x$，到达 $i$ 点的最短路，可以在 Dijkstra 中直接处理。此时点数为 $8w$，复杂度为 $O(w \log w)$，可以通过。最后的答案就是 $f_{x,2}$ 取合法最小值即可。

赛后改题代码。

```cpp
#define int long long
const int N = 60005;
int m, k, d[10], dis[5][N];

int tot = 0, head[N];
struct Edge {
	int next, to, dis;
} edge[N << 1];
inline void add_edge(int u, int v, int w) {
	edge[++tot].next = head[u];
	edge[tot].to = v, edge[tot].dis = w;
	head[u] = tot;
}

struct node {
	int to, dis;
	node(int x = 0, int y = 0) : to(x), dis(y) {}
	bool operator< (const node& other) const {return dis > other.dis;}
};
priority_queue<node> q;
inline void dijkstra() {
	memset(dis, 0x3f, sizeof(dis));
	dis[2][0] = 0, q.emplace(2, 0);
	while (!q.empty()) {
		int u = q.top().to, d = q.top().dis; q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to, w = edge[j].dis, c = dis[u][d % m] + w;
			if (dis[v][c % m] > c) dis[v][c % m] = c, q.emplace(v, c);
		}
	}
}

void _main() {
	cin >> k >> d[1] >> d[2] >> d[3] >> d[4];
	add_edge(1, 2, d[1]), add_edge(2, 1, d[1]);
	add_edge(2, 3, d[2]), add_edge(3, 2, d[2]);
	add_edge(3, 4, d[3]), add_edge(4, 3, d[3]);
	add_edge(4, 1, d[4]), add_edge(1, 4, d[4]);
	m = min(d[1], d[2]) * 2;
	memset(dis, 0x3f, sizeof(dis));
	dijkstra();
	int res = LLONG_MAX;
	for (int i = 0; i < m; i++) {
		if (dis[2][i] >= k) res = min(res, dis[2][i]);
		else {
			int x = k - dis[2][i], t = x / m * m + m * (x % m != 0);
			res = min(res, t + dis[2][i]);
		}
	} cout << res;
}
```

### P2662 [WC2002] 牛场围栏

还是不定方程问题。

设可以使用的木料长度的集合为 $S$，则 $S=\{l_i-j \mid i \in [1,n], j\in [0,\min(l_i,m)] \}$，记 $\min S=p$。

观察到，$p=1$ 时不存在最大值。设 $d_i$ 表示满足 $k \equiv i \pmod p$ 的最小的 $k$。

建图：对于 $u \in [a_i-m,a_i], v \in [0,p)$，建一条 $v \to (v+u) \pmod p$ 且边权为 $u$ 的边即可。用同余最短路求出 $d_i$，答案为 $\max(d_i-m)$。如果图不连通必然无解。

实现时，并不需要求出 $S$，只要对 $a$ 排序并取 $p=\max(1,a_1-m)$ 即可。

```cpp
#define int long long
const int N = 1e6 + 5;
int n, m, p, a[N];
void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	sort(a + 1, a + n + 1);
	int p = max<int>(1, a[1] - m);
	if (p == 1) return cout << -1, void();
	for (int i = 1; i <= n; i++) {
		for (int j = max(a[i - 1] + 1, a[i] - m); j <= a[i]; j++) {
			if (j == p) continue;
			for (int k = 0; k < p; k++) add_edge(k, (k + j) % p, j);
		}
	} SPFA::spfa(0);
	int res = 0;
	for (int i = 0; i < p; i++) {
		if (SPFA::dis[i] >= 0x3f3f3f3f3f3f3f3f) return cout << -1, void();
		res = max(res, SPFA::dis[i] - p);
	} cout << res;
}
```

### AT_arc084_b [ABC077D] Small Multiple

这题做法比较多，同余最短路是经典解法。

注意到，任何一个正整数都可以由 $1$ 开始，按顺序执行若干次 $\times 10, +1$ 的操作得到，且 $+1$ 的次数就是数位和。

建立图论模型：

- $k \to 10k \bmod n$，边权为 $0$。
- $k \to (k+1) \bmod n$，边权为 $1$。

从 $1$ 走到 $0$ 的最短路即为答案。注意到连续走 $10$ 条 $+1$ 其实是不合法的，但是这个题里答案一定不优。使用 01-BFS 可得到 $O(n)$ 复杂度。

### *P9140 [THUPC 2023 初赛] 背包

同余最短路的第二类例题。

由于 $V$ 很大，$v_i$ 很小，大部分背包体积都消耗在了性价比最高的物品上。将物品按性价比排序，我们只要求出余量即可。

一个贪心的想法是，先用 $\lfloor \dfrac{V}{v_1} \rfloor$ 个 $k_1$ 填满大部分，剩下的 $V \bmod v_1$ 的体积再找其他物品填充。但事实上我们可以舍弃一些 $1$ 号物品使得代价更小。

通过这个讨论，实际上问题已经转化为体积模 $v_1$ 意义下的完全背包。记 $d_i$ 表示模 $v_1$ 余 $i$ 的最优解，建立图论模型：

- $i \to (i+v_j) \bmod v_1$，边权为 $c_j-c_1\lfloor \dfrac{i+v_j}{v_1} \rfloor$。

用 SPFA 跑出**最长路**即可，答案即为 $\lfloor \dfrac{V}{v_1} \rfloor c_1 +d_{V \bmod v_1}$。

```cpp
#define int long long
const int N = 5e6 + 5;
int n, q, x;
struct node {
	int v, c;
} a[N];

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i].v >> a[i].c;
	sort(a + 1, a + n + 1, [](const node& a, const node& b) -> bool {
		return a.c * b.v > b.c * a.v;
	});
	int m = a[1].v;
	for (int i = 0; i <= m; i++) {
		for (int j = 1; j <= n; j++) add_edge(i, (i + a[j].v) % m, a[j].c - (i + a[j].v) / m * a[1].c);
	} SPFA::spfa(0);
	while (q--) {
		cin >> x;
		if (SPFA::dis[x % m] < -1e17) {cout << -1 << '\n'; continue;}
		cout << x / m * a[1].c + SPFA::dis[x % m] << '\n';
	}
}
```

## 参考资料

**第 1 章**

- 1.2.1 [模意义下的整数乘法](https://oi-wiki.org/math/binary-exponentiation/#%E6%A8%A1%E6%84%8F%E4%B9%89%E4%B8%8B%E7%9A%84%E6%95%B4%E6%95%B0%E4%B9%98%E6%B3%95)——OI Wiki。
- 1.2.2 [快速幂，光速幂及O(1)逆元](https://zhuanlan.zhihu.com/p/646773254)——秋钧。
- 1.2.2 [同一底数与同一模数的预处理快速幂](https://oi-wiki.org/math/binary-exponentiation/#%E5%90%8C%E4%B8%80%E5%BA%95%E6%95%B0%E4%B8%8E%E5%90%8C%E4%B8%80%E6%A8%A1%E6%95%B0%E7%9A%84%E9%A2%84%E5%A4%84%E7%90%86%E5%BF%AB%E9%80%9F%E5%B9%82)——OI Wiki。
- 1.3.3 [题解 P3811 【模板】乘法逆元](https://www.luogu.com.cn/article/olb3kk4e)——Rising_Date。

**第 2 章**

- 2.2.2 [Miller–Rabin 素性测试](https://oi-wiki.org/math/number-theory/prime/#millerrabin-%E7%B4%A0%E6%80%A7%E6%B5%8B%E8%AF%95)——OI Wiki。
- 2.4.3 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 3 章**

- 3.1.3 [Stein 算法的优化](https://oi-wiki.org/math/number-theory/gcd/#stein-%E7%AE%97%E6%B3%95%E7%9A%84%E4%BC%98%E5%8C%96)——OI Wiki。
- 3.1.3 [P5435](https://www.luogu.com.cn/article/t7bd37d3)——Maysoul。
- 3.4 《信息学奥林匹克竞赛实战笔记》。

**第 4 章**

- 4.2 《信息学奥林匹克竞赛实战笔记》。

**第 5 章**

- 5.1 [费马小定理](https://oi-wiki.org/math/number-theory/fermat/#%E8%B4%B9%E9%A9%AC%E5%B0%8F%E5%AE%9A%E7%90%86)——OI Wiki。

**第 6 章**

- 6.1 [数论分块](https://oi-wiki.org/math/number-theory/sqrt-decomposition/)——OI Wiki。
- 6.1 [数论分块](https://zhuanlan.zhihu.com/p/643870541)——Standard。

**第 7 章**

- 7.2.2 [等差数列](https://baike.baidu.com/item/%E7%AD%89%E5%B7%AE%E6%95%B0%E5%88%97/1129192)——百度百科。
- 7.2.3 [等比数列求和公式](https://baike.baidu.com/item/%E7%AD%89%E6%AF%94%E6%95%B0%E5%88%97%E6%B1%82%E5%92%8C%E5%85%AC%E5%BC%8F/7527367)——百度百科。
- 7.2.3 [分治(等比数列求和) - 约数之和 - AcWing 97](https://blog.csdn.net/njuptACMcxk/article/details/108019553)——njuptACMcxk。
- 7.2.4 [信奥常见数列详解](https://www.luogu.com.cn/article/oudldvmw)——Nostopathy。
- 7.3 [抽屉原理](https://oi-wiki.org/math/combinatorics/drawer-principle/)——OI Wiki。

**第 8 章**

- 8.1 [容斥原理](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/)——OI Wiki。
- 8.3 [容斥原理一般化](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E5%AE%B9%E6%96%A5%E5%8E%9F%E7%90%86%E4%B8%80%E8%88%AC%E5%8C%96)——OI Wiki。

**第 9 章**

- 9.1.3 [圆排列](https://oi-wiki.org/math/combinatorics/combination/#%E5%9C%86%E6%8E%92%E5%88%97)——OI Wiki。
- 9.2.2 [二项式定理](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%AE%9A%E7%90%86)——OI Wiki。
- 9.2.3 [组合数性质 | 二项式推论](https://oi-wiki.org/math/combinatorics/combination/#%E7%BB%84%E5%90%88%E6%95%B0%E6%80%A7%E8%B4%A8--%E4%BA%8C%E9%A1%B9%E5%BC%8F%E6%8E%A8%E8%AE%BA)——OI Wiki。
- 9.3.2 [插板法](https://oi-wiki.org/math/combinatorics/combination/#%E6%8F%92%E6%9D%BF%E6%B3%95)——OI Wiki。
- 9.3.2 [不定方程非负整数解计数](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E4%B8%8D%E5%AE%9A%E6%96%B9%E7%A8%8B%E9%9D%9E%E8%B4%9F%E6%95%B4%E6%95%B0%E8%A7%A3%E8%AE%A1%E6%95%B0)——OI Wiki。

**第 10 章**

- 10.1.1 [排名](https://oi-wiki.org/math/permutation/#%E6%8E%92%E5%90%8D)——OI Wiki。
- 10.1.2 [题解：CF1553E Permutation Shift](https://www.luogu.com.cn/article/lexsfrlf)——hh弟中弟。
- 10.2 [exLucas 算法](https://oi-wiki.org/math/number-theory/lucas/#exlucas-%E7%AE%97%E6%B3%95)——OI Wiki。
- 10.3 《算法竞赛进阶指南》——李煜东。

**第 11 章**

- 11.2 [二项式反演](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%8F%8D%E6%BC%94)——OI Wiki。
- 11.3 [容斥原理 & 二项式反演](https://www.cnblogs.com/2huk/p/18169274)——2huk。
- 11.3 [二项式反演学习笔记](https://www.cnblogs.com/XuYueming/p/18397758)——XuYueming。

**第 12 章**

- 12.2 [错位排列](https://www.luogu.com.cn/article/8k18otus)——xzyg。

**第 13 章**

- 13.1 DeepSeek。
- 13.1 [简单格路计数相关](https://www.cnblogs.com/Sktn0089/p/19183743)——Sktn0089。
- 13.2 [常见形式](https://oi-wiki.org/math/combinatorics/catalan/#%E5%B8%B8%E8%A7%81%E5%BD%A2%E5%BC%8F)——OI Wiki。

**第 14 章**

- 14.1 & 14.2 [斯特林数](https://oi-wiki.org/math/combinatorics/stirling/)——OI Wiki。
- 14.3 [二项式反演与斯特林反演](https://www.cnblogs.com/UKE-Automation/p/19688555)——UKE_Automation。
- 14.4.3 [斯特林数入门](https://zhuanlan.zhihu.com/p/160779987)——Hongzy。

**第 15 章**

- 15.1 & 15.2 [贝尔数](https://oi-wiki.org/math/combinatorics/bell/)——OI Wiki。
- 15.3 [贝尔数](https://www.cnblogs.com/HeNuclearReactor/p/18552275.html)——NuclearReactor。

**第 16 章**

- 16.1 & 16.2 [分拆数](https://www.luogu.me/article/ed1zhztr)——LYH_cpp。
- 16.3 [组合数学（2）分拆数](https://zhuanlan.zhihu.com/p/530925152)——卷心汪汪队。

**第 18 章**

- 18.1 & 18.2 & 18.3 & 18.4 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 19 章**

- 19.2 [遍历所有掩码的子掩码](https://oi-wiki.org/math/binary-set/#%E9%81%8D%E5%8E%86%E6%89%80%E6%9C%89%E6%8E%A9%E7%A0%81%E7%9A%84%E5%AD%90%E6%8E%A9%E7%A0%81)——OI Wiki。
- 19.2 [高维前缀和 (SOSDP) ](https://www.cnblogs.com/jiangchen4133/p/18741715.html)——Aurora-JC。

**第 20 章**

- 20.1 [字典树 (Trie) ](https://oi-wiki.org/string/trie/#%E7%BB%B4%E6%8A%A4%E5%BC%82%E6%88%96%E5%92%8C)——OI Wiki。

**第 21 章**

- 21.2 [分数规划](https://oi-wiki.org/misc/frac-programming/)——OI Wiki。

**第 22 章**

- 22.1 DeepSeek。
- 22.3 [高斯消元法解异或方程组](https://oi-wiki.org/math/numerical/gauss/#%E9%AB%98%E6%96%AF%E6%B6%88%E5%85%83%E6%B3%95%E8%A7%A3%E5%BC%82%E6%88%96%E6%96%B9%E7%A8%8B%E7%BB%84)——OI Wiki。

**第 23 章**

- 23.1 & 23.2《深入浅出程序设计竞赛（进阶篇）》——洛谷。
- 23.3 [关于广义矩阵乘法常见误区的一点纠正](https://www.cnblogs.com/qkhm/p/20055514/ddp)——qkhm。

**第 24 章**

- 24.1 DeepSeek。
- 24.2 & 24.3 [插值](https://oi-wiki.org/math/numerical/interp/)——OI Wiki。
- 24.3 [离散泰勒公式，牛顿插值法，以及那些奇怪的数列](https://www.bilibili.com/video/BV1GvoaYbExs/)——科技3D视界。

**第 25 章**

- 25.2 [浅谈同余最短路](https://www.luogu.com.cn/article/boecnq71)——Exp10re。
