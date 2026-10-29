---
id: ds-rmq-linear
title: '线性 RMQ'
category: '数据结构'
subcategory: 'ST表'
tags: ["RMQ","线性RMQ","ST表","笛卡尔树"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 前言

RMQ 算法大概是这样的：

| 算法 | 预处理 | 查询 | 空间 | 码量 |
| --- | --- | --- | --- | --- |
| ST 表 | $O(n \log n)$ | $O(1)$ | $O(n \log n)$ | 小 |
| 树状数组 | $O(n)$ | $O(\log^2 n)$ | $O(n)$ | 小 |
| 线段树 | $O(n)$ | $O(\log n)$ | $O(n)$ | 中 |
| 平衡树 | $O(n)$ | $O(\log n)$ | $O(n)$ | 大 |
| 分块 | $O(n)$ | $O(\sqrt{n})$ | $O(n)$ | 大 |
| Sqrt Tree | $O(n \log \log n)$ | $O(1)$ | $O(n)$ | 大 |
| Four Russian | $O(n \log \log n)$ | $O(1)$ | $O(n \log \log n)$ | 大 |
| 线性 RMQ | $O(n)$ | $O(1)$ | $O(n)$ | 中 |

本文介绍的线性 RMQ 科技，具有常数小，预处理严格线性，查询严格常数复杂度等优势。摘自 [OI-Wiki](https://oi-wiki.org/topic/rmq/#%E5%9F%BA%E4%BA%8E%E7%8A%B6%E5%8E%8B%E7%9A%84%E7%BA%BF%E6%80%A7-rmq-%E7%AE%97%E6%B3%95)。

## 原理

把原序列分成 $O(\dfrac{n}{\log n})$ 块，每块长度 $\log n$，跑一次 ST 表，复杂度 $O(\dfrac{n}{\log n} \times \log n) = O(n)$。

记录块中的前后缀最值 $pre$ 和 $suf$。

记查询的 $l,r$ 分别属于 $bl,br$，若 $bl<br$，则答案在 $\max(\max_{i \in (bl,br)} a_i, suf_{bl}, pre_{br})$。

当 $bl=br$ 时，考虑状态压缩。

> 作者注：在大部分题目中，这种情况暴力 $O(\log n)$ 去扫已经足够优秀。

把 $a_{[1,r]}$ 插入单调栈中，则 $\max_{i \in [l,r]} a_i$ 就是单调栈中第一个下标 $\ge l$ 的值。这也是单调栈离线解决 RMQ 问题的基本思想。

状压记录每个数是否在单调栈中，使用速度非常快的 `__builtin_ctz` 函数即可实现 $O(1)$ 查询。

```cpp
template <class T, class Cmp = std::less<T>>
class RMQ {
private:
	Cmp cmp = Cmp();
	std::function<T(const T&, const T&)> func;

	int n, block;
	T a[N], st[__lg(N) + 1][N], pre[N], suf[N];
	int belong[N], pos[N];
	long long f[N];

	inline void build_st() {
		int cur = 0, id = 1;
		pos[0] = -1;
		for (int i = 1; i <= n; i++) {
			st[0][id] = func(st[0][id], a[i]);
			belong[i] = id;
			if (belong[i - 1] != belong[i]) pos[i] = 0;
			else pos[i] = pos[i - 1] + 1;
			if (++cur == block) cur = 0, id++;
		}
		if (n % block == 0) id--;
		for (int i = 1; i <= __lg(id); i++) {
			for (int j = 1; j + (1 << i) - 1 <= id; j++) {
				st[i][j] = func(st[i - 1][j], st[i - 1][j + (1 << (i - 1))]);
			}
		}
	}

	inline void build_subpre() {
		for (int i = 1; i <= n; i++) {
			if (belong[i] != belong[i - 1]) pre[i] = a[i];
			else pre[i] = func(pre[i - 1], a[i]);
		}
		for (int i = n; i >= 1; i--) {
			if (belong[i] != belong[i + 1]) suf[i] = a[i];
			else suf[i] = func(suf[i + 1], a[i]);
		}
	}

	inline void build_block() {
		static int stk[N], top;
		for (int i = 1; i <= n; i++) {
			if (belong[i] != belong[i - 1]) top = 0;
			else f[i] = f[i - 1];
			while (top > 0 && a[stk[top]] <= a[i]) {
				f[i] &= ~(1LL << pos[stk[top--]]);
			}
			stk[++top] = i;
			f[i] |= (1LL << pos[i]);
		}
	}

	void init(const T* _a) {
		func = [&](const T& x, const T& y) -> T {
			return cmp(x, y) ? y : x;
		};
		for (int i = 1; i <= n; i++) a[i] = _a[i];
		block = 63;  // 按需调整
		build_st(), build_subpre(), build_block();
	}

public:
	RMQ() {}
	RMQ(const T* _a, int _n) : n(_n) {init(_a);}

	int query(int l, int r) const {
		int bl = belong[l], br = belong[r];
		if (bl == br) return a[l + __builtin_ctzll(f[r] >> pos[l])];
		if (br - bl == 1) return func(suf[l], pre[r]);
		int k = __lg(br - bl - 1);
		return func(
			func(suf[l], pre[r]),
			func(st[k][bl + 1], st[k][br - (1 << k)])
		);
	}
};
```

个人感觉这种方法码量不大，容易记忆，比笛卡尔树 + LCA + 加减 $1$ RMQ 的 $O(n)$ 预处理 $O(1)$ 常数小且好写，配合 DFS 序求 LCA 可以实现线性处理常数查询，是值得学习的科技。
