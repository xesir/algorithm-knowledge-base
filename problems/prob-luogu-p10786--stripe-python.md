---
id: prob-luogu-p10786
title: '[NOI2024] 百万富翁'
oj: '洛谷'
problemId: 'P10786'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 基础算法
tags: ['题解']
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
knowledgePoints: []
---

> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10786](https://www.luogu.com.cn/problem/P10786)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以进行 $T$ 次并行询问，并行询问包含至多 $S$ 个单独问题 $(i,j)$，若 $p_i>p_j$ 返回 $i$，否则返回 $j$。
>
> 找出排列中最大值出现的位置。
>
> - 测试点 #1：$n=10^3$，满分要求 $T=1,S=499500$；
> - 测试点 #2：$n=10^6$，满分要求 $T=8,S=1099944$。
>
> 交互库自适应。

:::::success[题解]

首先测试点 #1 就是检查你题目读懂了没有，懂了以后直接把所有 $i<j$ 的 $(i,j)$ 都问一遍即可。一次询问，询问大小为 $\frac{n(n-1)}{2}=499500$。

对于测试点 #2，一个直接的想法是分治，每层二分一下，会形成一个类似线段树的结构，要询问 $20$ 次。注意到题目要求我们把询问减少到 $8$ 次，考虑一个类似 $k$ 叉线段树的策略，每层分 $k$ 块，块内按照 #1 那样两两询问，这样可以得到 $k$ 个胜者进入下一层。

可以用 Turán 定理说明上述策略的最优性。因此恰当的块长一定可以得到最优询问次数。

那么现在这题实际上转化为一个提答题：确定一个长为 $8$ 的序列 $a$ 表示每层的块长。

我自己做的时候直接乱搞出来了。下面叙述正解，可以发现，将 $n$ 个人分 $k$ 块的询问次数为
$$
f(n,k)=(k-n\bmod k)\times \binom{\left\lfloor \frac{n}{k} \right\rfloor}{2}+(n\bmod k)\times \binom{\left\lfloor \frac{n}{k} \right\rfloor+1}{2}
$$

则序列 $a$ 的询问次数为
$$
g(a)=\sum_{i=0}^7 f(a_i,a_{i+1})
$$
对策略进行 DP。设 $dp_{n,k} $ 表示第 $n$ 层，分 $k$ 块的最小代价，枚举下一层分 $k' $ 块可以做到 $O(Tn^2)$，本地需要较长时间。

注意到 $f(n,k)$ 是一个与 $\left\lfloor \frac{n}{k} \right\rfloor$ 有关的式子，所以大量 DP 状态的答案是重复的。考虑数论分块优化 DP，那么复杂度降到 $O(Tn\sqrt{n})$，本机 <1s 即可跑出答案。

:::::

::::info[代码]

这是 DP 代码。

```cpp line-numbers
#define int long long
const int N = 1e6 + 5;
int f(int x) {return x * (x - 1) / 2;}
int g(int x, int y) {return (y - (x % y)) * f(x / y) + x % y * f(x / y + 1);}
int dp[10][N];
int dfs(int n, int k) {
	if (dp[k][n]) return dp[k][n];
	if (k == 1) return f(n);
	vector<int> vec;
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		if (l > 1) vec.emplace_back(l);
		if (r > l) vec.emplace_back(r);
	}
	dp[k][n] = 1e18;
	for (int x : vec) {
		int v = dfs(x, k - 1) + g(n, x);
		if (v < dp[k][n]) dp[k][n] = v;
	}
	return dp[k][n];
}
void out(int n, int k) {
	if (k == 1) return cout << 1, void();
	vector<int> vec;
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		if (l > 1) vec.emplace_back(l);
		if (r > l) vec.emplace_back(r);
	}
	for (int x : vec) {
		if (dp[k][n] == dfs(x, k - 1) + g(n, x)) {
			cout << x << ", ", out(x, k - 1);
			break;
		}
	}
}

void _main() {
	cout << dfs(1000000, 8) << endl;
	out(1000000, 8);
}
```

在运行后的输出如下：

```cpp
1099944
500000, 250000, 125000, 62500, 20833, 3472, 183, 1
```

写到交互程序中即可。

```cpp line-numbers
int work1() {
	vector<int> a, b;
	for (int i = 0; i < 1000; i++) {
		for (int j = i + 1; j < 1000; j++) a.emplace_back(i), b.emplace_back(j);
	}
	auto c = ask(a, b);
	vector<int> cnt(1000, 0);
	for (int i : c) cnt[i]++;
	for (int i = 0; i < 1000; i++) {
		if (cnt[i] >= 999) return i;
	}
	throw -1;
}
const int a[] = {1000000, 500000, 250000, 125000, 62500, 20833, 3472, 183, 1};
int richest(int N, int T, int S) {
	if (N == 1000 && T == 1 && S == 499500) return work1();
	vector<int> q;
	for (int i = 0; i < N; i++) q.emplace_back(i);
	for (int x = 1; x < 9; x++) {
		vector<int> u, v;
		for (int i = 0, l = 0, r; i < a[x]; i++, l = r) {
			r = l + a[x - 1] / a[x];
			if (i < a[x - 1] % a[x]) r++;
			for (int j = l; j < r; j++) {
				for (int k = j + 1; k < r; k++) u.emplace_back(q[j]), v.emplace_back(q[k]);
			}
		}
		auto w = ask(u, v);
		vector<int> cnt(N);
		for (int i = 0; i < (int) w.size(); i++) {
			if (w[i] == u[i]) cnt[v[i]]++;
			else cnt[u[i]]++;
		}
		vector<int> nxt;
		for (int i = 0; i < (int) q.size(); i++) {
			if (!cnt[q[i]]) nxt.emplace_back(q[i]);
		}
		q = nxt;
	}
	return q[0];
}
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
