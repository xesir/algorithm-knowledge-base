---
id: prob-luogu-p5047
title: 'P5047 Yuno loves sqrt technology II'
oj: '洛谷'
problemId: 'P5047'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 数据结构
tags: ["莫队","二次离线","分块","逆序对"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: A
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
knowledgePoints: ["ds-mo-team","ds-block-decomposition"]
---

> 本题题解由 stripe-python 授权合并，保留原文结构与表述。
做题记录。二次离线莫队科技。

> 给你一个长为 $n$ 的序列 $a$，$q$ 次询问，每次查询一个区间的逆序对数。
>
> $n, q\le 10^5$。

下文复杂度分析认为 $n,q$ 同阶。先离散化。

考虑普通莫队怎么做。我们开一个权值树状数组，每次指针移动时在值域上查询有多少个数比它小。复杂度 $O(n\sqrt{n} \log n)$，无法通过。

以右指针移动为例，对于 $[l,r] \to [l,r+1]$，记 $x=a_{r+1}$，贡献即为 $x$ 在 $[l,r]$ 中产生的逆序对。设 $f(l,r,x)$ 表示这个贡献。

关键性质：$f(l,r,x)=f(1,r,x)-f(1,l-1,x)$。这种简单的差分思想在很多题里都会用到。

对于 $f(1,r,x)$，只需在莫队扫描过程中更新权值树状数组。对于 $f(1,l-1,x)$，我们首先将这样的询问放进一个 std::vector 中离线下来。

现在问题转为：单点添加，查询排名。考虑数据结构性质平衡，莫队 $O(n\sqrt{n})$ 次移动，数组长度为 $O(n)$，使用值域分块可以做到 $O(\sqrt{n})$ 插入，$O(1)$ 查询，与莫队结构适配。

这样我们在 $O(n\sqrt{n})$ 内求得每次答案的变化量，问题解决。细节比较多，需要卡常。

完整代码：

```cpp
const int N = 2e5 + 5;
int n, q, a[N], d[N], x[N], y[N];
long long ans[N];
struct query {
	int l, r, id;
	long long ans;
} qry[N];   // 一次离线
vector<tuple<int, int, int, int, int>> vec[N];   // 二次离线
// 五元组 (l, r, id, 加减, 左右)
struct block {
	static constexpr int B = 256;
	int L[N], R[N], belong[N], a[N], b[N];
	void init() {
		for (int i = 1; i <= B; i++) L[i] = N / B * (i - 1) + 1, R[i] = N / B * i;
		R[B] = N;
		for (int i = 1; i <= B; i++) fill(belong + L[i], belong + R[i] + 1, i);
	}
	void clear() {memset(a, 0, sizeof(a)), memset(b, 0, sizeof(b));}
	void add(int x) {  // 加数
		for (int i = belong[x]; i <= B; i++) a[i]++;
		for (int i = x; i <= R[belong[x]]; i++) b[i]++;
	}
	int ask(int x) {return x <= 0 ? 0 : a[belong[x] - 1] + b[x];}  // 排名
} b;

void _main() {
	read(n, q), read(a + 1, a + n + 1);
	copy(a + 1, a + n + 1, d + 1), sort(d + 1, d + n + 1);
	int tot = unique(d + 1, d + n + 1) - d - 1;
	for (int i = 1; i <= n; i++) a[i] = lower_bound(d + 1, d + tot + 1, a[i]) - d;
	b.init(), b.clear();
	for (int i = 1; i <= n; i++) x[i] = b.ask(a[i] - 1), y[i] = b.ask(n) - b.ask(a[i]), b.add(a[i]);
	for (int i = 1; i <= n; i++) mdebug(x[i], y[i]);

	for (int i = 1; i <= q; i++) read(qry[i].l, qry[i].r), qry[i].id = i;
	int unit = n / sqrt(q);
	sort(qry + 1, qry + q + 1, [&](const query& x, const query& y) -> bool {
		if (x.l / unit != y.l / unit) return x.l < y.l;
		if ((x.l / unit) & 1) return x.r < y.r;
		return x.r > y.r;
	});
	for (int i = 1, l = 1, r = 0; i <= q; i++) {
		int ql = qry[i].l, qr = qry[i].r;
		long long &cur = qry[i].ans;
		if (l > ql) vec[r].emplace_back(ql, l - 1, i, 1, -1);
		while (l > ql) cur -= x[--l];
		if (r < qr) vec[l - 1].emplace_back(r + 1, qr, i, -1, 1);
		while (r < qr) cur += y[++r];
		if (l < ql) vec[r].emplace_back(l, ql - 1, i, -1, -1);
		while (l < ql) cur += x[l++];
		if (r > qr) vec[l - 1].emplace_back(qr + 1, r, i, 1, 1);
		while (r > qr) cur -= y[r--];
	}  // 一次离线：普通莫队，处理二次离线所需信息

	b.clear();
	for (int i = 1; i <= n; i++) {
		b.add(a[i]);
		for (const auto& info : vec[i]) {
			int l = get<0>(info), r = get<1>(info), id = get<2>(info), sgn = get<3>(info), lr = get<4>(info);
			for (int j = l; j <= r; j++) {
				if (lr == -1) qry[id].ans += sgn * b.ask(a[j] - 1);
				else qry[id].ans += sgn * (i - b.ask(a[j]));
			}
		}
	}  // 二次离线：处理剩下的贡献信息

	for (int i = 1; i <= q; i++) qry[i].ans += qry[i - 1].ans;
	for (int i = 1; i <= q; i++) ans[qry[i].id] = qry[i].ans;
	for (int i = 1; i <= q; i++) writeln(ans[i]);
	FastIO::flush();
}
```
