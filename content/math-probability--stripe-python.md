---
id: math-probability
title: '概率论与期望'
category: '数学'
subcategory: '组合数学'
tags: ['概率', '期望', '条件概率', '概率分布']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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

## 附：概率论专题笔记（stripe-python）

对于一个随机试验 $E$，我们将其所有可能的基本结果称为**样本点**，记为 $\omega$。所有样本点组成的集合称作**样本空间** $\Omega$。

定义**事件** $A$ 是 $\Omega$ 的子集。当且仅当 $\exists \omega \in A, \omega$ 出现，称为事件 $A$ **发生**。此时有：

- 若 $A=\Omega$，称 $A$ 为**必然事件**。
- 若 $A=\varnothing$，称 $A$ 为**不可能事件**。

事件是一个集合，因此集合的交 & 并 & 补 & 对称差操作都可以推广到事件上。具体地：

- 称 $A \cup B$ 为事件 $A,B$ 的和事件，记作 $A+B$。组合意义为事件 $A$ 发生**或**事件 $B$ 发生。
- 称 $A \cap B$ 为事件 $A,B$ 的积事件，记作 $AB$。组合意义为事件 $A$ 发生且事件 $B$ 发生。
- 称 $A \cap B=\varnothing$ 的事件 $A,B$ 互斥。组合意义为事件 $A,B$ 不可能同时发生。
- 称 $\Omega \setminus A$ 为 $A$ 的对立事件，记作 $\overline A$。组合意义为事件 $A,\overline {A}$ 中必然有且仅有一个发生。

如果满足 $\Omega$ 是有限集，且每个样本点出现的可能性相等，则可以用**古典概型**定义事件 $A$ 发生的概率
$$
P(A)=\dfrac{|A|}{|\Omega|}
$$
概率函数满足如下性质：

- $P(\Omega)=1, P(\varnothing)=0$。
- 若事件 $A,B$ 互斥，则 $P(A+B)=P(A)+P(B)$。称为概率的加法公式。
- 若 $A,B$ 互为独立，则 $P(A)+P(B)=1$。
- 若 $A \subseteq B$，则 $P(A) \le P(B)$。
- 概率的容斥原理：$P(A+B)=P(A)+P(B)-P(AB)$。

定义事件 $A,B$ 相互**独立**，当且仅当
$$
P(AB)=P(A)P(B)
$$
其组合意义为：一个事件是否发生，不会干涉另一个事件的发生。

## 19.1 条件概率

对于两个随机事件 $A,B$，记在事件 $A$ 发生的条件下，事件 $B$ 仍然发生的概率为 $P(B \mid A)$。根据定义
$$
P(B \mid A)=\dfrac{|AB|}{|A|}=\dfrac{P(AB)}{P(B)}
$$
称 $P(B \mid A)$ 为**条件概率**。上式移项有
$$
P(AB)=P(A) P(B \mid A)
$$
称为概率的乘法公式。

设事件 $A_1,A_2,\cdots,A_n$ 两两互斥且和事件为 $\Omega$，并且满足 $\forall 1 \le i \le n, P(A_i)>0$，则有**全概率公式**
$$
P(B)=\sum_{i=1}^n P(A_i) P(B \mid A_i)
$$

## 19.2 随机变量的数字特征

### 19.2.1 概念

对于任意 $\omega \in \Omega$，如果存在唯一的实数 $X(\omega)$ 与之对应，则称 $X$ 为**随机变量**。按照这个定义，随机变量是一个 $\Omega \to \mathbb{R}$ 的函数。

对于随机变量 $X$，其所有可能的取值为 $x_1,x_2,\cdots$，且取值集合有限，或者可以一一列举，则称 $X$ 为**离散型随机变量**。

如无特殊说明，下文讨论的随机变量均为离散型随机变量。对于连续性随机变量，需要使用微积分的知识来定义一些特征。

我们记 $p_i$ 为 $X=x_i$ 的概率，即 $p_i=P(X=x_i)$。将数列 $p_i$ 称为 $X$ 的**分布列**。则 $p_i$ 满足性质 $\sum \limits_{i \ge 1} p_i=1$。用分布列可以描述一个随机变量 $X$。

### 19.2.2 期望

对于随机变量 $X$，称它的均值 / **期望**为
$$
E(X)=\sum_{i=1}^n x_ip_i
$$
需要注意的是，只有上述求和收敛时 $E(X)$ 才存在。在 OI 中，求期望的题目期望一般都是存在的，因此下文不会讨论期望的存在性。

期望满足如下性质：

- **线性性**：对于随机变量 $X$，有 $E(aX+b)=aE(X)+b$。
- 乘法公式：对于**独立**随机变量 $X,Y$，有 $E(XY)=E(X)E(Y)$。注意，$X,Y$ 独立不是等式成立的必要条件。

### 19.2.3 方差

期望并不能反映随机变量的波动，因此我们定义了 $X$ 的**方差**为
$$
\begin{aligned}
D(X)&=\sum_{i=1}^n (x_i-E(X))^2 p_i\\
&=\sum_{i=1}^n (x_i^2 p_i-E^2(X))\\
&= E\left((X-E(X))^2\right)\\
&= E(X^2)-E^2(X)
\end{aligned}
$$
上述四个形式都是等价的，请读者注意。方差满足如下性质：

- 对于随机变量 $X$，有 $D(aX+b)=a^2D(X)$。

## 19.3 概率分布

### 19.3.1 两点分布

若随机试验 $E$ 满足 $|\Omega|=2$，则称 $E$ 为**伯努利试验**。记 $\Omega=\{0,1\}$，并用随机变量 $X$ 刻画取出的数字，设 $P(X=1)=p$。

根据概率的性质，必有 $E(X=0)=1-p$。称随机变量 $X$ 服从**两点分布**或 0—1 分布。

对于服从两点分布的随机变量 $X$，显然有：

- $E(X)=p$。
- $D(X)=p(1-p)$。

### 19.3.2 几何分布

在伯努利试验中，若 $X=0$ 称为试验失败，$X=1$ 称为试验成功，仍记单次试验成功的概率为 $p$。

进行若干次独立重复实验，直到实验成功则停止，将实验次数记为 $X$，则称随机变量 $X$ 服从**几何分布**。记作 $X \sim G(p)$。

考虑求 $X$ 的分布列。对于 $X=k$ 的情形，进行分步计数：

- 前 $k-1$ 次实验失败，概率 $(1-p)^{k-1}$。
- 第 $k$ 次实验成功，概率 $p$。

从而 $P(X=k)=(1-p)^{k-1}p$。进一步：

- $E(X)=\dfrac{1}{p}$。
- $D(X)=\dfrac{1-p}{p^2}$。

:::::success[组合证法]

直接对级数求和有
$$
\begin{aligned}
E(X) &= \sum_{k \ge 1} kp_k\\
&= \sum_{k \ge 1} kp (1-p)^{k-1}\\
&= p \sum_{k \ge 1} k(1-p)^{k-1}\\
&= p \dfrac{1}{(1-(1-p))^2}\\
&= \dfrac{1}{p}
\end{aligned}
$$
对于方差，考虑计算 $E(X^2)$ 有
$$
\begin{aligned}
E(X^2) &= \sum_{k \ge 1} k^2p_k\\
&= \sum_{k \ge 1} k^2p (1-p)^{k-1}\\
&= p \sum_{k \ge 1} k^2(1-p)^{k-1}\\
&= p \dfrac{1+1-p}{(1-(1-p))^2}\\
&= \dfrac{2-p}{p^2}
\end{aligned}
$$
从而 $D(X)=E(X^2)-E^2(X)=\dfrac{2-p}{p^2}-\dfrac{1}{p^2}=\dfrac{1-p}{p^2}$。

:::::

### 19.3.3 二项分布

将伯努利试验独立重复 $n$ 次，称为 $n$ 重伯努利试验。在这一随机试验中，记试验成功的次数为 $X$，则称随机变量 $X$ 服从**二项分布**。记作 $X \sim B(n,p)$。

二项分布的另一个组合意义是：箱子中装有若干黑球和白球，独立**放回**地摸出 $n$ 次球，将摸出黑球的次数记为随机变量 $X$。

可以用排列组合配合概率论的方法求 $X$ 的分布列。对于 $X=k$ 的情形，考虑分步计数：

- 钦定 $k$ 次试验成功，方案数 $\dbinom{n}{k}$。
- 对于成功的 $k$ 次试验，概率 $p^k$。
- 对于失败的 $n-k$ 次试验，概率 $(1-p)^{n-k}$。

于是随机变量 $X$ 的分布列 $P(X=k)=\dbinom{n}{k} p^k (1-p)^{n-k}$。进一步：

- $E(X)=np$。
- $D(X)=np(1-p)$。

:::::success[组合证法]

我们有
$$
\begin{aligned}
E(X)&=\sum_{k=0}^n k \times p_k\\
&=\sum_{k=0}^n k \dbinom{n}{k} p^k (1-p)^{n-k}\\
&= \sum_{k=1}^n n \binom{n-1}{k-1} p^k (1-p)^{n-k}\\
&= np \sum_{k=1}^n \binom{n-1}{k-1} p^{k-1}(1-p)^{n-k}\\
&= np  (p+1-p)^{n-1}\\
&=np
\end{aligned}
$$
对于方差，考虑先计算 $E\left(X(X-1)\right)$：
$$
\begin{aligned}
E(X(X-1))&=\sum_{k=0}^n k(k-1) \dbinom{n}{k} p^k (1-p)^{n-k}\\
&=\sum_{k=2}^n n(n-1) \binom{n-2}{k-2} p^k (1-p)^{n-k}\\
&=n(n-1)p^2 \sum_{k=2}^n \binom{n-2}{k-2} p^{k-2} (1-p)^{(n-2)-(k-2)}\\
&= n(n-1)p^2 (p+1-p)^{n-2}\\
&= n(n-1)p^2
\end{aligned}
$$
第二个等号利用了二维吸收恒等式 $k(k-1) \dbinom{n}{k}=n(n-1) \dbinom{n-2}{k-2}$。

由方差线性性 $E(X^2)=E(X(x-1)+X)=n(n-1)p^2+np$。代入方差公式得
$$
\begin{aligned}
D(X)&=E(X^2)-E^2(X)\\
&= n(n-1)p^2+np-n^2p^2\\
&= n^2p-np+np-n^2p^2\\
&= np(1-p)
\end{aligned}
$$
证毕。

:::::

:::::success[PGF 证法]

写出随机变量 $X$ 的 PGF
$$
\begin{aligned}
F(x)&=\sum_{k=0}^n p_k x^k\\
&= \sum_{k=0}^n \dbinom{n}{k} p^k (1-p)^{n-k} x^k\\
&= (px+1-p)^n
\end{aligned}
$$
对 $F$ 求一阶导和二阶导：
$$
\begin{aligned}
F'(x)&= np(px+1-p)^{n-1}\\
F''(x) &= n(n-1)p^2 (px+1-p)^{n-2}
\end{aligned}
$$
根据 EGF 性质即可得到
$$
\begin{aligned}
E(X)&=F'(1)\\
&=np(p+1-p)^{n-1}\\
&=np\\
D(X)&= F''(1)+F'(1)-F'^2(1)\\
&=n(n-1)p^2+np-n^2p^2\\
&=np(1-p)
\end{aligned}
$$
证毕。

:::::

### 19.3.4 超几何分布

箱子中装有 $N$ 个球，其中 $M$ 个是黑球，独立**不放回**地摸出 $n$ 次球，将摸出黑球的次数记为随机变量 $X$，则称 $X$ 服从**超几何分布**。

可以发现，在这种组合意义下，二项分布和超几何分布的区别仅在于放回和不放回的抽取方法。

可以用排列组合的方法求出 $X$ 的分布列：

- 总方案数 $\dbinom{N}{n}$。
- 从 $M$ 个黑球里取出 $k$ 个，再从 $N-M$ 个白球里取出 $n-k$ 个，由乘法原理得到合法方案数 $\dbinom{M}{k} \dbinom{N-M}{n-k}$。

因此，$X$ 的分布列为：
$$
P(X=k)=\dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}}
$$
进一步可得 $E(X)=n\dfrac{M}{N}$。

:::::success[组合证法]

我们有
$$
\begin{aligned}
E(X)&=\sum_{k=0}^n k \times p_k\\
&=\sum_{k=0}^n k \dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}}\\
&=\sum_{k=1}^n \dfrac{M\binom{M-1}{k-1}\binom{N-M}{n-k}}{\binom{N}{n}}\\
&= \dfrac{M}{\binom{N}{n}} \sum_{k=1}^n \binom{M-1}{k-1}\binom{N-M}{n-k}\\
&= \dfrac{M}{\binom{N}{n}} \sum_{i=0}^{n-1} \binom{M-1}{i} \binom{N-M}{n-1-i}\\
&= \dfrac{M}{\binom{N}{n}}  \binom{N-1}{n-1}\\
&= \dfrac{Mn!(N-n)!}{N!}\times \dfrac{(N-1)!}{(n-1)!(N-n)!}\\
&= \dfrac{nM}{N}
\end{aligned}
$$
证毕。倒数第三个等号使用了范德蒙德卷积。

:::::

:::::success[PGF 证法]

写出随机变量 $X$ 的 PGF
$$
\begin{aligned}
F(x)&=\sum_{k=0}^n p_k x^k\\
&= \sum_{k=1}^n \dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}} x^k
\end{aligned}
$$
注意到 $F$ 的分子为 $(1+xy)^M (1+y)^{N-M}$ 的展开式中 $y^n$ 项的系数。因此：
$$
\begin{aligned}
\binom{N}{n} F(x) &= [y^n] \left((1+xy)^M (1+y)^{N-M}\right)
\end{aligned}
$$
将等式两边同时关于 $x$ 求偏导：
$$
\begin{aligned}
\binom{N}{n} F'(x) &= [y^n]\dfrac{\partial}{\partial x} \left((1+xy)^M (1+y)^{N-M}\right)\\
\binom{N}{n} F'(x) &= [y^n] \left(My(1+xy)^{M-1}(1+y)^{N-M}\right)
\end{aligned}
$$
所求期望为 $F'(1)$，将 $x=1$ 代入得
$$
\begin{aligned}
\binom{N}{n} F'(1) &= [y^n] \left(My(1+y)^{M-1}(1+y)^{N-M}\right)\\
&= [y^n] My(1+y)^{N-1}\\
&= M\binom{N-1}{n-1}\\
F'(1)&= \dfrac{M\binom{N-1}{n-1}}{\binom{N}{n}}=\dfrac{nM}{N}
\end{aligned}
$$
证毕。

:::::
