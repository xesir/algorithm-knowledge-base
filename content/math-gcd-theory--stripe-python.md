---
id: math-gcd-theory
title: '最大公约数与扩展欧几里得'
category: '数学'
subcategory: '数论基础'
tags: ['gcd', 'lcm', 'exgcd', '裴蜀定理']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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
