---
id: math-prime-factor-state-compression
title: '质因子状态压缩 trick'
category: '数学'
subcategory: '数论基础'
tags: ["质因子","状态压缩","数论","trick"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
由于本人在 9.26 模拟赛中的 T2 二十分钟瞪出了做法，然后自己否掉导致写了 2h 喜提 240pts，故对这类题目作一个总结。

## AT_abc195_f [ABC195F] Coprime Present

这题就是本人模拟赛的那个 T2。


一个思路是注意到最大答案在 $2 \times 10^8$ 左右，可以进行 $O(ans)$ 的搜索，但需要 `__int128` 状压和神秘减枝，赛时想了 1.5h 无果。

回归题目发现 $r-l \le 72$ 这个神秘限制。显然 $a,b$ 能同时选当且仅当质因子交集为空。记 $S_a$ 表示 $a$ 的质因子集合。

若 $a, b$ 满足 $S_a \cap S_b=A$，且 $\forall i \in S, i>72$，则 $|a-b|>72$，必然不满足这一限制。所以 $S_a$ 中只有 $\le 72$ 的数是有用的。

通过打表发现，$[2,72]$ 中的质数只有 $20$ 个，故 $S_a$ 可以状态压缩存下。进一步考虑一个状压 DP，用 $f_{S}$ 表示质因子集合为 $S$ 时的选法，考虑加入 $a$ 对 $f_{S}$ 的影响。

记 $T=S_a$，则对于每个 $S$，当且仅当 $S \cup T =\varnothing$ 时 $T$ 才能加入 $S$ 中。刷表法转移：$f_{S \cap T} \gets f_S$。

边界为 $f_{\varnothing}=1$。

复杂度 $O(2^w n)$，其中 $w \le 20$。



赛时 AC 代码。

```cpp
#define int long long
const int N = 21;

int l, r, f[1 << N];
const int p[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41,
	43, 47, 53, 59, 61, 67, 71};  // 20个

void _main() {
	cin >> l >> r;
	f[0] = 1;
	for (int i = l; i <= r; i++) {
		int x = 0;
		for (int j = 0; j < 20; j++) {
			if (i % p[j]) continue;
			x |= 1 << j;
		}
		for (int j = 0; j < (1 << 20); j++) {
			if ((x & j) == 0) f[x | j] += f[j];
		}
	}
	int res = 0;
	for (int i = 0; i < (1 << 20); i++) res += f[i];
	cout << res;
}
```

## P2150 [NOI2015] 寿司晚宴


两个子集中的数字两两互质，等价于子集中的质因数集合交集为空。

我们先从 30pts 开始考虑。因为 $n \le 30$，那么质因数只有 $10$ 个。设 $dp_{i,S,T}$ 表示当前考虑到第 $i$ 个数，质因子集合为 $S,T$ 的方案数。对于 $[2,n]$ 分解质因数，把质因数状压一波。枚举与 $S,T$ 无交集的 $D$，刷表法转移：

$$
dp_{i+1,S \cup D,T} \gets dp_{i,S,T}\\
dp_{i+1,S,T \cup D} \gets dp_{i,S,T}
$$

然后对于 $S \cap D=\varnothing$ 的每个 $S,T$ 统计答案。可以滚动数组优化，时间复杂度为 $O(2^{2w} n)$，其中 $w \le 10$。和上面那题没什么区别。

然后直接考虑正解。因为 $500$ 以内的质数有 $95$ 个，暴力 DP 直接爆炸。但是我们发现 $n$ 以内的数大于 $\sqrt{n}$ 的质因子最多只有一个，也就是大于 $23$ 的质因子最多一个。那么我们以 $23$ 为分界点，考虑在两侧分别 DP。也就是根号分治一波。

具体地，对于 $[2,500]$ 以内的数，我们先找出其最大质因子并按其排序，然后对每一个连续段统计答案。而 $23$ 以内的质数只有 $8$ 个，于是仍然令 $dp_{i,S,T}$ 表示考虑到第 $i$ 个数，质因子集合分别为 $S,T$ 的方案数，但是此时 $|S|,|T| \le 8$。接着考虑最大质因子的贡献，由于它只能被一个子集选走，令 $f_{i,S,T}$ 表示考虑到第 $i$ 个数，其最大质因子只能被第一个子集选走的方案数，$g_{i,S,T}$ 表示其最大质因子只能被第二个子集选走的方案数，仍然刷表转移：

$$
f_{i+1,S \cup D,t} \gets f_{i,S,T}\\
g_{i+1,S,T \cup D} \gets g_{i,S,T}
$$

把 $f,g$ 都合并到 $dp$ 里，需要容斥一下，因为会把不选的情况算两遍：

$dp_{i+1,S,T} = f_{i,S,T}+g_{i,S,T}-dp_{i,S,T}$滚动数组优化空间，注意要像 01 背包那样倒序枚举了。答案即为 $\sum_{S \cap T = \varnothing} dp_{n,S,T}$。

至此，时间复杂度优化到 $O(4^w n)$，其中 $w \le 8$。


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

## P8292 [省选联考 2022] 卡牌


注意到 $s_i \le 30$ 的部分分。样例解释告诉我们可以正难则反。记给出的质数集合为 $P$，枚举一个 $S \subseteq P$，设 $f(S)$ 表示表示选出若干卡牌的集合 $T$，满足 $\forall i \in S, i \nmid \prod T$ 的方案数。

由于 $[2,30]$ 中的质数数目为 $10$，对于 $S$ 只有 $2^{10}$ 种可能，预处理出来即可。

这样是一个容斥的过程，答案为

$\sum_{S \subseteq P} (-1)^{|S|} f(S)$复杂度 $O(2^w n+2^w \sum c)$，其中 $w \le 10$。

考虑优化。注意到 $s_i \le 2000$ 时依旧沿用上题的根号分治，将质因子分成 $\le 43$ 和 $>43$ 两部分。则 $[2,43]$ 中共有 $14$ 个质数，这部分的处理使用上面的容斥即可。
