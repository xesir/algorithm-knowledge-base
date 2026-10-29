---
id: str-hash
title: '字符串哈希学习笔记'
category: '字符串'
subcategory: '字符串哈希'
tags: ["字符串哈希","哈希","多项式哈希"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 字符串哈希

字符串哈希一般用于快速判断两个串是否相同。

常用的方法：对于字符串 $s$，其哈希值为

$(\sum_{i=1}^{n} s_i \times b^{n-i}) \bmod m$只需要 $O(n)$ 计算。

一般 $n$ 达到 $10^6$ 时 $m$ 需要开到 $10^{15}$ 级别。为了减少冲突，一般 $m$ 为质数。但 $998244353,10^9+7$ 就别用了，这里推荐几个：

$10^9+123;10^{15}+37;29\times2^{57}+1$。

用大模数建议开 `__int128`，龟速乘几乎加一个 $\log$。

为了实现子串哈希，处理的时候可以打出所有前缀的哈希计算。

## 子串哈希

$s[l,r]$ 的哈希值为

$$
(\sum_{i=l}^{r} s_i \times b^{r-i}) \bmod m \\
=[\sum_{i=1}^{r} s_i \times b^{r-i}-b^{r-l+1}(\sum_{i=1}^{l-1} s_i \times b^{l-i-1})] \bmod m
$$

可以 $O(1)$ 计算。

或者对于本蒟蒻这样热爱压位高精的来说，用 $b$ 进制大整数理解，记 $h$ 是前缀哈希，就是 $h_r-h_{l-1}b^{r-l+1}$。

## 字符串匹配

直接枚举子串，比较哈希值，复杂度 $O(n)$。

## LCP

预处理一下两个串的哈希值，二分到一点 $i$ 使得 $h_{i}=h'_{i}$ 但 $h_{i+1}\ne h'_{i+1}$，则 LCP 长为 $i$。复杂度 $O(\log n)$。

如果要比较字典序，只需要比较 $a_{i+1}$ 和 $b_{i+1}$ 即可。

## 允许 kkk 次失配的字符串匹配

求 $t$ 在 $s$ 中匹配的位置，匹配定义为长度相同且只有 $k$ 位不同。

枚举 $s$ 的每个可能子串，用 LCP 找第一个失配位置，然后往后跳即可，复杂度 $O(nk \log m)$。

## 最长回文子串

先在每个字符间插入一个字符使偶回文串变成奇回文串。

二分答案，枚举回文中心，判断两侧是否相等即可。复杂度 $O(n \log n)$。

## 后缀排序

先预处理原串的哈希。后缀也是原串的子串，可以 $O(1)$ 获取哈希值，$O(\log n)$ 比较字典序，然后 $O(n \log n)$ 快排即可，总复杂度 $O(n \log^2 n)$。

洛谷的模板题需要卡常，用两个优化：

1. `std::sort` 换成 `std::stable_sort`
2. 取 $m=2^{64}$ 利用 `unsigned long long` 自然溢出

```cpp
namespace SA {
	int n;
	char s[N];

	int sa[N], ht[N];

	const modint base = 131;
	modint p[N], h[N];

	inline modint query(int l, int r) {
		return h[r] - h[l - 1] * p[r - l + 1];
	}

	inline int lcp(int a, int b) {
		int l = 0, r = min(n - a, n - b) + 1, res = 0;
		while (l <= r) {
			int mid = (l + r) >> 1;
			if (query(a, a + mid - 1) == query(b, b + mid - 1)) l = mid + 1, res = mid;
			else r = mid - 1;
		}
		return res;
	}

	inline void sasort() {
		n = strlen(s + 1);
		p[0] = 1;
		for (int i = 1; i <= n; i++) {
			sa[i] = i;
			h[i] = h[i - 1] * base + modint(s[i]), p[i] = p[i - 1] * base;
		}
		stable_sort(sa + 1, sa + n + 1, [](int a, int b) -> bool {
			int len = lcp(a, b);
			return s[a + len] < s[b + len];
		});
	}

	inline void solve_height() {
		for (int i = 2; i <= n; i++) ht[i] = lcp(sa[i], sa[i - 1]);
	}
}
```

顺带一提，这玩意好像可以倍增 + 计数排序做到 $O(n \log n)$。
