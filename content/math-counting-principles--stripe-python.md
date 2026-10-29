---
id: math-counting-principles
title: '计数原理：加法与乘法原理 / 抽屉原理'
category: '数学'
subcategory: '组合数学'
tags: ['计数原理', '加法原理', '乘法原理', '抽屉原理']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 7. 计数原理

常用的计数原理有加法原理、乘法原理、抽屉原理、容斥原理等。容斥在第 8 章单独介绍。

## 7.1 加法 & 乘法原理

- **加法原理**：有 $n$ 类方法，$a_i$ 为第 $i$ 类中方法的数目，则总方法数为 $\sum a_i$。
- **乘法原理**：有 $n$ 个步骤，$a_i$ 为第 $i$ 步中方法的数目，则总方法数为 $\prod a_i$。

这两者的区别是：加法分类，乘法分步。

加法原理有一个推论，即减法原理，就是求满足某种约束的方案数可以用总方案数减去不满足约束的方案数。这是最简单的容斥，是“正难则反”的体现。

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
