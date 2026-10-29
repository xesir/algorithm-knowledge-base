---
id: math-bit-operation
title: '位运算'
category: '数学'
subcategory: '数学基础'
tags: ['位运算', '按位与', '按位异或', 'lowbit']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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
