---
id: dp-knapsack-overview
title: '背包 DP 综述'
category: '动态规划'
subcategory: '背包问题'
tags: ["背包","01背包","完全背包","多重背包","分组背包"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
之前打 ABC 发现自己背包掌握的不是很熟练，所以写这一篇复习笔记。

## 基本模型

有 $n$ 种物品和一个容量为 $m$ 的背包，每种物品有重量 $w_i$ 与价值 $v_i$ 两种属性，要求选若干个物品，使它们的重量之和 $\le m$ 且 $\sum v$ 最大。

各种背包都是在这个模型下的。

## 01 背包

**每种物品有且仅有一个。**

设 $dp_{i, j}$ 表示前 $i$ 种物品，容量为 $j$ 的背包最大价值。

则

$dp_{i, j}=\max(dp_{i-1,j}, dp_{i-1,j-w_i}+v_i)$这里的两种选择对应选 / 不选第 $i$ 种物品。

可以滚动数组优化。内层循环需要 $j$ 从 $m$ 逆向枚举到 $w_i$，防止 $dp_j$ 被 $dp_{j-w_i}$ 影响。

如此，时间 $O(nm)$，空间 $O(m)$。

## P2871 [USACO07DEC] Charm Bracelet S

板子一个。代码如下：

```cpp
const int N = 13000;
int n, m, w[N], v[N], dp[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	cout << dp[m];
}
```

## P1855 榨取kkksc03

这题与普通背包的区别在于一种物品有两个体积，在 $dp$ 数组中多开一维即可。

```cpp
const int N = 205;
int n, m1, m2, w1[N], w2[N], dp[N][N];

void _main() {
	cin >> n >> m1 >> m2;
	for (int i = 1; i <= n; i++) cin >> w1[i] >> w2[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m1; j >= w1[i]; j--) {
			for (int k = m2; k >= w2[i]; k--) dp[j][k] = max(dp[j][k], dp[j - w1[i]][k - w2[i]] + 1);
		}
	}
	cout << dp[m1][m2];
}
```

## P1802 5 倍经验日

01 背包简单变形。仍然沿用 $dp$ 状态，则

$dp_j=\max(dp_j+lose_i,dp_{j-use_i}+win_i)$注意 $j < use_i$ 时第二个转移无法进行。

```cpp
const int N = 1e3 + 5;
int n, m, v1[N], v2[N], w[N], dp[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v2[i] >> v1[i] >> w[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= 0; j--) dp[j] = max(dp[j] + v2[i], j < w[i] ? 0 : dp[j - w[i]] + v1[i]);
	}
	cout << 5LL * dp[m];
}
```

## [ABC390E] Vitamin Balance

三种 $V_i$ 分开跑 01 背包，暴力枚举两种 $V_i$ 所占的体积，合并答案即可。复杂度 $O(nx+n^2)$。

```cpp
const int N = 5005;

int n, x, opt;
int n1, n2, n3;
struct node {
	int v, w;
} a1[N], a2[N], a3[N];
int dp1[N], dp2[N], dp3[N];

void backpack01(node* a, int n, int* dp) {
	for (int i = 1; i <= n; i++) {
		for (int j = x; j >= a[i].w; j--) dp[j] = max(dp[j], dp[j - a[i].w] + a[i].v);
	}
}

void _main() {
	cin >> n >> x;
	for (int i = 1; i <= n; i++) {
		cin >> opt;
		if (opt == 1) n1++, cin >> a1[n1].v >> a1[n1].w;
		if (opt == 2) n2++, cin >> a2[n2].v >> a2[n2].w;
		if (opt == 3) n3++, cin >> a3[n3].v >> a3[n3].w;
	}
	backpack01(a1, n1, dp1);
	backpack01(a2, n2, dp2);
	backpack01(a3, n3, dp3);
	int res = 0;
	for (int i = 1; i <= x; i++) {
		for (int j = 1; j <= x; j++) {
			int k = x - i - j;
			if (k < 0) continue;
			res = max(res, min(dp1[i], min(dp2[j], dp3[k])));
		}
	}
	cout << res;
}
```

## P2340 [USACO03FALL] Cow Exhibition G

把智商当体积，情商当价值，跑完 01 背包合并答案即可。为了处理负数，进行一个数组漂移的 trick。

```cpp
const int N = 1e5;

int n, w[500], v[500], dp[(N << 2) + 5];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	memset(dp, 0xcf, sizeof(dp));
	dp[N] = 0;
	for (int i = 1; i <= n; i++) {
		if (w[i] >= 0)
			for (int j = (N << 1); j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
		else    // 负数要逆向转移，改成正数以后正序枚举
			for (int j = 0; j <= (N << 1) + w[i]; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	int res = 0;
	for (int i = N; i <= (N << 1); i++) {
		if (dp[i] >= 0) res = max(res, i - N + dp[i]);
	}
	cout << res;
}
```

## P2946 [USACO09MAR] Cow Frisbee Team S

背包经典变式。

模 $m$ 同余类的背包问题，一般设 $dp_{i,j}$ 表示前 $i$ 种物品，总价值模 $m$ 等于 $j$。这里 $dp_{i,j}$ 表示方案数。

那么有转移

$dp_{i,j}=dp_{i-1,j}+dp_{i-1,(j-w_i)\bmod m}$会发现其实和普通 01 背包的区别就是多模了个 $m$。一年前写的代码：

```cpp
const int mod = 1e8;
int n, k, a[N], dp[N][N];

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) dp[i][a[i] % k] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 0; j < k; j++) {
			dp[i][j] = (dp[i][j] + dp[i - 1][j]) % mod;
			dp[i][j] = (dp[i][j] + dp[i - 1][(j - a[i] % k + k) % k]) % mod;
		}
	}
	cout << dp[n][0];
	return 0;
}
```

## P4141 消失之物

直接跑背包计数，复杂度是 $O(n^2m)$ 的。正解用到背包的撤销 trick。

作转移 $dp_j \gets dp_j+dp_{j-w_i}$ 时，我们加入了物品 $i$。那么删去物品 $i$ 就是作 $dp_j \gets dp_j-dp_{j-w_i}$。代码如下。

```cpp
const int N = 2005;
int n, m, w[N], dp1[N], dp2[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> w[i];
	dp1[0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= w[i]; j--) {
			dp1[j] += dp1[j - w[i]];
			dp1[j] %= 10;
		}
	}
	for (int i = 1; i <= n; i++) {
		memcpy(dp2, dp1, sizeof(dp1));
		for (int j = w[i]; j <= m; j++) {
			dp2[j] -= dp2[j - w[i]];
			dp2[j] = (dp2[j] + 10) % 10;
		}
		for (int j = 1; j <= m; j++) cout << dp2[j];
		cout << '\n';
	}
	return 0;
}
```

## HDU 2639 Bone Collector II

01 背包，$k$ 优解问题。

考虑多加一维，令 $dp_{i,j,k}$ 表示前 $i$ 种物品，容量为 $j$ 的背包第 $k$ 大价值。转移时，要求合并 $dp_{i-1,j}$ 与 $dp_{i-1,j-w_i}+v_i$ 两个递减序列，取前 $k$ 大值。这里可以使用某些数据结构或双指针法。这样做时间 $O(nmk)$，空间 $O(mk)$。

## 完全背包

**每种物品有无数个。**

仍然设 $dp_{i, j}$ 表示前 $i$ 种物品，容量为 $j$ 的背包最大价值。

则

$dp_{i, j}=\max(dp_{i-1,j}, dp_{i,j-w_i}+v_i)$这个转移成立的理由是，$dp_{i,j-w_i}$ 已经被 $dp_{i,j-kw_i}$ 所更新过，其中 $k$ 是不小于 $2$ 的整数。因此，我们取 $\max$ 的时候已经考虑了当前物品取 $[1,k]$ 个的情况。

继续滚动数组优化。注意到将 01 背包的内层循环改为正向枚举，即可让 $dp_{j}$ 被 $dp_{j-kw_i}$ 更新。

仍然时间 $O(nm)$，空间 $O(m)$。

## P1616 疯狂的采药

板子 +1，代码如下：

```cpp
const int N = 1e7 + 5;

long long n, m, w[N], v[N], dp[N];

void _main() {
	cin >> m >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	for (int i = 1; i <= n; i++) {
		for (int j = w[i]; j <= m; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	cout << dp[m];
}
```

## P1853 投资的最大效益

比较裸的多测完全背包。注意到 $a$ 是 $1000$ 的倍数，可以优化一下。

```cpp
const int N = 1e6 + 5;
int m, y, n, w[50], v[50], dp[N];

void _main() {
	cin >> m >> y >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i], w[i] /= 1000;
	long long cur = m;
	while (y--) {
		memset(dp, 0, sizeof(dp));
		int m1 = cur / 1000;
		for (int i = 1; i <= n; i++) {
			for (int j = w[i]; j <= m1; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
		}
		cur += dp[m1];
	}
	cout << cur;
}
```

## 多重背包

**每种物品有 $c_i$ 个。**

一个朴素的想法是把第 $i$ 种物品拆分成 $c_i$ 种只有一个的物品，跑 01 背包。复杂度为 $O(m\sum c_i)$，显然喜提 TLE。

经典的优化是二进制分组。对一个数字 $c_i$，把它按二进制拆成 $c_i = \sum 2^d$，那么若干个 $2^d$ 的和可以表示 $[0,c_i]$ 的任意数字，证明使用二进制显然。这样做的复杂度为 $O(m \sum \log c_i)$。

不过这样做近似等于 $O(nm \log V)$，有没有什么更快的方法呢？

有的兄弟，有的。回归朴素思想的转移式：

$dp_{i,j}=\max_{k=0}^{c_i} (dp_{i-1,j-kw_i}+kv_i)$注意到，$dp_{i,j}$ 的有效转移 $dp_{i-1,j-kw_i}$ 满足 $j \equiv j-kw_i \pmod {c_i}$，这启示我们把总容量 $m$ 拆成模 $c_i$ 同余类。此时，$dp_{i,j'}$ 由 $dp_{i,j''}, j'' \in [0,j')$ 转移而来，可以使用单调队列优化。复杂度为 $O(n\sum c_i \sum \dfrac{m}{c_i})=O(nm)$。

## P1776 宝物筛选

板子 +2。给出两种方法的代码：

```cpp
const int N = 1e6 + 5;

int n, m, w[N], v[N], c[N];
int n1, w1[N], v1[N], dp[N];  // 拆完的

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v[i] >> w[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= c[i]; j <<= 1) w1[++n1] = w[i] * j, v1[n1] = v[i] * j, c[i] -= j;
		if (c[i]) w1[++n1] = w[i] * c[i], v1[n1] = v[i] * c[i];
	}
	for (int i = 1; i <= n1; i++) {
		for (int j = m; j >= w1[i]; j--) dp[j] = max(dp[j], dp[j - w1[i]] + v1[i]);
	}
	cout << dp[m];
}
```

```cpp
const int N = 1e6 + 5;

int n, m, w[N], v[N], c[N];
int head, tail, q[N];
int dp[N], dp1[N]; // dp1用于暂存dp的值

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v[i] >> w[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		memcpy(dp1, dp, sizeof(dp));
		for (int j = 0; j < w[i]; j++) {
			head = tail = 0;
			for (int k = j; k <= m; k += w[i]) {
				if (head < tail && q[head] < k - w[i] * c[i]) head++;
				if (head < tail) dp[k] = max(dp1[k], dp1[q[head]] + (k - q[head]) / w[i] * v[i]);
				while (head < tail && dp1[k] >= dp1[q[tail - 1]] + (k - q[tail - 1]) / w[i] * v[i]) tail--;
				q[tail++] = k;
			}
		}
	}
	cout << dp[m];
}
```

## P1782 旅行商的背包

前面是多重背包板子，后面注意到 $m \le 5$，直接枚举体积跑 01 背包，两种背包合并答案即可。

这怎么不算混合背包呢

```cpp
const int N = 1e5 + 5;

#define int long long
int n, m, w[N], v[N], c[N];
int n1, w1[N], v1[N], dp[N];
int nn, A[10], B[10], C[10];

void _main() {
	cin >> n >> nn >> m;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= c[i]; j <<= 1) w1[++n1] = w[i] * j, v1[n1] = v[i] * j, c[i] -= j;
		if (c[i]) w1[++n1] = w[i] * c[i], v1[n1] = v[i] * c[i];
	}
	for (int i = 1; i <= n1; i++) {
		for (int j = m; j >= w1[i]; j--) dp[j] = max(dp[j], dp[j - w1[i]] + v1[i]);
	}

	for (int i = 1; i <= nn; i++) cin >> A[i] >> B[i] >> C[i];
	for (int i = 1; i <= nn; i++) {
		for (int j = m; j >= 1; j--) {
			for (int k = 0; k <= j; k++) dp[j] = max(dp[j], dp[j - k] + A[i] * k * k + B[i] * k + C[i]);
		}
	}
	cout << dp[m];
}
```

## P2347 [NOIP1996 提高组] 砝码称重

这是一道多重背包的可行性问题。事实上，背包可行性问题的判断适用 `bitset` 优化，且代码更为简单。

用 `bitset<N> s` 压位记录状态，第 $i$ 位表示 $i$ 能否取到，那么取 $w_i$ 的值即为 `s << w[i]`，所以转移为 `s |= s << w[i]`。

```cpp
const int N = 1005;
int a[8], w[8] = {1, 2, 3, 5, 10, 20};
bitset<N> s;

void _main() {
	for (int i = 0; i < 6; i++) cin >> a[i];
	s[0] = 1;
	for (int i = 0; i < 6; i++) {
		for (int j = 0; j < a[i]; j++) s |= s << w[i];
	}
	cout << "Total=" << s.count() - 1;
}
```

## 分组背包

**每种物品属于一个组，每组只能选一种。**

思考一下与普通背包的差别，从所有物品中选变成从每组中选，所以对每组跑背包即可。复杂度多乘上一个组数。

## P1757 通天之分组背包

板子 +3。更远古的代码：

```cpp
#include <bits/stdc++.h>
#define N 1005
using namespace std;

namespace BackpackGroup {
	int s, n, w[N], v[N], g[N], cnt[N * N], f[N][N], dp[N];

	int backpack() {
		int y = *max_element(g + 1, g + n + 1);
		for (int i = 1; i <= n; i++) f[g[i]][++cnt[g[i]]] = i;
		for (int k = 1; k <= y; k++) {
			for (int j = s; j >= 0; j--) {
				for (int i = 1; i <= cnt[k]; i++) {
					int idx = f[k][i];
					if (j >= w[idx]) dp[j] = max(dp[j], dp[j - w[idx]] + v[idx]);
				}
			}
		}
		return dp[s];
	}
}
using namespace BackpackGroup;  // 当时的逆天namespace马蜂

signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr);
	cin >> s >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i] >> g[i];
	cout << backpack();
	return 0;
}
```

## P5322 [BJOI2019] 排兵布阵

这题真正难的地方不是背包，而是转化。

把城堡看作物品，兵力看作体积，转换为背包模型。贪心地，对于每个城堡，若兵力 $x>y$ 且能打赢 $x$，那就一定能打赢 $y$。于是将输入的数组转置并排序。这时我们发现这已经被转化为分组背包。

```cpp
const int N = 105;

int s, n, m, a[N][N], dp[20005];

void _main() {
	cin >> s >> n >> m;
	for (int i = 1; i <= s; i++) {
		for (int j = 1; j <= n; j++) cin >> a[j][i];
	}
	for (int i = 1; i <= n; i++) sort(a[i] + 1, a[i] + s + 1);
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= 0; j--) {
			for (int k = 1; k <= s; k++) {
				dp[j] = max(dp[j], j - 2 * a[i][k] - 1 < 0 ? 0 : dp[j - 2 * a[i][k] - 1] + k * i);
			}
		}
	}
	cout << dp[m];
}
```
