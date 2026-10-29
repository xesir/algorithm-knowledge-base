---
id: basic-greedy-block-building
title: '积木大赛类贪心'
category: '基础算法'
subcategory: '贪心'
tags: ["积木大赛","贪心","差分","区间"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 序列版本

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P1969 [NOIP 2013 提高组] 积木大赛](https://www.luogu.com.cn/problem/P1969)、[P5019 [NOIP 2018 提高组] 铺设道路](https://www.luogu.com.cn/problem/P5019)、[P3078 [USACO13MAR] Poker Hands S](https://www.luogu.com.cn/problem/P3078)。

发现操作瓶颈在最大数。因为比它小的数都到 $0$ 时，最大数不会变成 $0$，需要进行额外操作。

对于位置 $i$，若 $a_i > a_{i-1}$，那么必然要支付 $a_i-a_{i-1}$ 的代价。注意到这个代价与相对位置无关，可以直接统计一遍。注意这样子消不掉 $a_1$，最后要加回来。答案的式子

$a_1+\sum_{i=2}^{n} \max(a_i-a_{i-1},0)$```cpp
const int N = 1e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	int res = a[1];
	for (int i = 2; i <= n; i++) res += max(0, a[i] - a[i - 1]);
	cout << res;
}
```

### 变式

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$，或者将下标为奇数 / 偶数的元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P6631 [ZJOI2020] 序列](https://www.luogu.com.cn/problem/P6631)。

## 环上版本

> 给你长度为 $n$ 的首尾相接的环 $a$。一次操作将一个环上的子区间所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 2 \times 10^5, a_i \ge 0$。

原题链接：[AT_arc136_c [ARC136C] Circular Addition](https://www.luogu.com.cn/problem/AT_arc136_c)。

根据上面那题的启发，猜想答案是

$\sum_{i=1}^{n} \max(a_i-a_{(i + 1) \bmod n +1},0)$不难发现这是错的。但是可以往差分上想。由于这是个环，一次操作实际上使得差分数组一个点减一，一个点加一。则答案的下界为

$p=\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}|$显然这不是答案。记 $q= \max a$，一次操作最多只会使得 $q \gets q -1$。当 $q>p$ 时，答案下界为 $q$。

猜想答案为 $\max(p,q)$。下面给出贪心方案。

设一个全为 $\max a$ 的极长连续段为最大区间。

1. 当 $p<q$ 时，注意到 $0 \notin a$，则一次操作将整个环减少一，此时 $q \gets q -1$，$p$ 不变。重复操作至 $p=q$。

:::success[为什么 $0 \notin a$]

考虑反证法。显然 $p \ge \max a - \min a$，当 $0 \in a$ 时取等号，此时 $p \ge q$，矛盾。

:::

1. 当 $p>q$ 时，一次操作选取一个最大区间减一，则 $p \gets p-1$，$q$ 最多减一。重复操作至 $p=q$。

现在只需给出 $p=q$ 时的操作方案。

- 当最大区间的数目为 $1$ 时，一次操作将其减一，$p \gets p-1, q \gets q-1$；
- 当最大区间的数目不为 $1$ 时，可以推出 $0 \notin a$。找到一个最短的包含所有 $\max a$ 的区间，重复操作直到 $p=q=0$。

综上所述，答案为

$\max(\max_{i=1}^{n} a_i,\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}| )$```cpp
const int N = 2e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	long long p = 0;
	for (int i = 1; i <= n; i++) p += abs(a[i] - a[(i + 1) % n + 1]);
	cout << max<long long>(*max_element(a + 1, a + n + 1), p / 2);
}
```

## 树上版本

> 给你节点数为 $n$ 的无根树，点 $i$ 的权值为 $a_i$。一次操作将一条树链上的所有点权减 $1$。
>
> 求点权全变成 $0$ 的最少操作数。
>
> $n \le 3 \times 10^6, a_i \ge 0$。

原题链接：[P7246 手势密码](https://www.luogu.com.cn/problem/P7246)。

记 $(u,v)$ 表示对从 $u$ 到 $v$ 的树链进行一次操作。对于下图

![](https://cdn.luogu.com.cn/upload/image_hosting/r03khxgv.png)

可以发现，$(x,y), (r,r)$ 和 $(x,r),(y,r)$ 的作用效果是相同的。但是后者的路径可以向上延伸两次，前者只能延伸一次，所以子树决策 $(x,r),(y,r)$ 一定不劣。

所以在决策等效时，子树向根提供的路径数越多越好。

第二点，考虑路径什么时候“拐弯”。比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/z1hqy87m.png)

如果按照子树决策的思路，$(x,x),(y,y),(z,z)$ 三条路径各自都可以向 $r$ 延伸。在 $r$ 处，可以考虑将两条延伸至此的路径拼接，即变为 $(x,y),(z,z)$，则 $(x,x),(y,y)$ 的代价合并。

这样就可以 DFS 了。记当前节点为 $u$，设

$$
s=\sum_{v \in \operatorname{son}(u)} f(v)\\
m=\max_{v \in \operatorname{son}(u)} f(v)
$$

则不满足最优决策时，$u$ 子树内的代价下界为 $\max(\lfloor \dfrac{s}{2} \rfloor,s-m)$。设其为 $l_0$。

为了保证向上延伸的路径尽量多，考虑瓶颈。$a_u$ 显然是一个瓶颈，因为不能减成负数。子树和 $s-a_u$ 也是瓶颈。所以代价下界 $l=\max(0,\min(l_0,a_u,s-a_u))$。向上延伸的路径数就是 $a_u-l$。

别忘了更新答案。对于节点 $u$，不难发现贡献为 $a_u-s$。因为要满足 $l$ 的限制，贡献具体是 $\max(a_u-s+l,0)-l$。

```cpp
int opt, n, seed, a[N], u[N], v[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
long long ans;
long long dfs(int u, int fa) {
	long long s = 0, m = 0;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		long long x = dfs(v, u);
		s += x, m = max(m, x);
	}
	long long l = max(0LL, min({1LL * a[u], s - a[u], s / 2, s - m}));
	ans += max(0LL, a[u] - s + l) - l;
	return a[u] - l;
}

void _main() {
	cin >> opt;
	if (opt == 1) {
		cin >> n;
		for (int i = 1; i <= n; i++) cin >> a[i];
		for (int i = 1; i < n; i++) cin >> u[0] >> v[0], add_edge(u[0], v[0]), add_edge(v[0], u[0]);
	} else {
		cin >> seed >> n;
		Generate::n = n, Generate::seed = seed, Generate::RS(a, u, v);
		for (int i = 1; i < n; i++) add_edge(u[i], v[i]), add_edge(v[i], u[i]);
	}
	dfs(1, -1);
	cout << ans;
}
```

## 基环树版本

> 给你节点数为 $n$ 的基环树，点 $i$ 的权值为 $a_i$。一次操作将一条简单路径上的所有点权减 $1$。
>
> 求点权全变成 $0$ 的最少操作数。
>
> $n \le 3 \times 10^6, a_i \ge 0$。

不会。
