---
id: ds-persistent-segtree-template
title: '可持久化线段树学习笔记'
category: '数据结构'
subcategory: '可持久化数据结构'
tags: ["可持久化线段树","主席树","权值线段树"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
感觉将主席树的很多教程都不讲权值线段树，然后本蒟蒻花了半天时间理解主席树维护的线段树和区间线段树有什么区别。

## 权值线段树

普通线段树解决的问题：

1. 对序列上一段区间做修改；
2. 对序列上一段区间查询信息。

而权值线段树把这个序列变成了值域，相当于维护原序列的出现次数。那么权值线段树对值域做维护，自然也就能支持对值域的操作。我造了一个板子题 [SPN D-Struct 02](https://www.luogu.com.cn/problem/U449821)，下面写写这题题解：

对值域建立线段树，每个节点维护总和，对于操作 1 / 2，把沿路节点的和加上或减去 $h$。对于操作 3，在权值线段树上二分，若左节点总和 $\ge k$，则意味着 $k$ 大值在左子树取得，否则在右子树处取得且要将 $k$ 减去左节点总和。对于操作 4，仿照普通线段树把 $[l,r]$ 区间节点的总和加起来即可。使用动态开点复杂度 $O(q \log V)$。code：

```cpp
template <class T, int N>
class WeightedSegmentTree {
private:
	int cnt, root, ch[2][N << 1];
	T val[N << 1];

	int new_node() {
		int cur = ++cnt;
		val[cnt] = 0, ch[0][cnt] = ch[1][cnt] = 0;
		return cur;
	}

	void update(int p, const T& v, int l, int r, int& rt) {
		if (!rt) rt = new_node();
		val[rt] += v;
		if (l == r) return;
		int mid = (l + r) >> 1;
		if (p <= mid) update(p, v, l, mid, ch[0][rt]);
		else update(p, v, mid + 1, r, ch[1][rt]);
	}

	T query(int tl, int tr, int l, int r, int rt) {
		if (tl <= l && r <= tr) return val[rt];
		int mid = (l + r) >> 1;
		T res(0);
		if (tl <= mid) res += query(tl, tr, l, mid, ch[0][rt]);
		if (tr > mid) res += query(tl, tr, mid + 1, r, ch[1][rt]);
		return res;
	}

	int kth(const T& k, int l, int r, int rt) {
		if (l == r) return l;
		int mid = (l + r) >> 1;
		if (val[ch[0][rt]] >= k) return kth(k, l, mid, ch[0][rt]);
		return kth(k - val[ch[0][rt]], mid + 1, r, ch[1][rt]);
	}

public:
	WeightedSegmentTree() : cnt(0), root(0) {}

	void update(int p, const T& v) {update(p, v, 0, N, root);}
	T query(int l, int r) {return query(l, r, 0, N, root);}
	int kth(const T& k) {return kth(k, 0, N, root);}
};
```

## 可持久化的作用

现在让我们扩展一下这个问题：查询区间第 $k$ 小。

区间问题有一个 trick：$[l,r]=[1,r]-[1,l-1]$。于是我们开 $n$ 个权值线段树，第 $i$ 棵维护序列前缀 $[1,i]$，然后在第 $l-1$ 和第 $r$ 棵里递归查找第 $k$ 小……

然而稍微分析一下，空间 $O(nV)$ 已经爆炸，时间也不优。

如何优化？注意到，我们每次只加入一个数，这个操作的性质是很好的。考虑代码

```cpp
void update(int p, const T& v, int l, int r, int& rt) {
  if (!rt) rt = new_node();
  val[rt] += v;
  if (l == r) return;
  int mid = (l + r) >> 1;
  if (p <= mid) update(p, v, l, mid, ch[0][rt]);
  else update(p, v, mid + 1, r, ch[1][rt]);
}
```

根据线段树基础知识，这个过程复杂度是 $O(\log V)$ 意味着被修改的节点也只有 $O(\log V)$ 个。那为什么不在原树上单独引入节点来存储信息呢？比如说我们在 $V=8$ 的权值线段树中插入一个数字 $3$，则修改的节点为 $[1,8],[1,4],[3,4],[3,3]$，把这些节点变成新的就行。

![](https://cdn.luogu.com.cn/upload/image_hosting/fr4zzxjv.png)

这幅图里，绿色节点为原树的节点，红色节点为新建节点。注意到，绿色节点是一棵完整的树。而如果以 `+[1,8]` 为根：

![](https://cdn.luogu.com.cn/upload/image_hosting/w63rybvm.png)

这也是一棵完整的树。因此这个方法是正确的。

现在网上很多教程是先引入可持久化的，本蒟蒻认为应该先引入这种利用重复节点的思想，再发现这个东西可以实现可持久化。这里解释一下，可持久化指的是能够保存历史版本的数据结构，而这种方法的确能够保存历史版本。

事实上，不基于均摊的树形数据结构，比如线段树、FHQ-Treap、AVL、字典树、左偏树都可以用这种方法可持久化。

## 例题

## P3834 【模板】可持久化线段树 2

就是上文提的区间第 $k$ 小问题。这个题要注意几个点：

1. 离散化。
2. 可持久化线段树显然不能用完全二叉树的方法存储，使用动态开点即可。
3. 开大空间，主席树空间是 $O(V+n\log V)$ 的，对于这题保险起见要开 $4 \times 10^6$。当然你可以用指针写。

```cpp
const int N = 2e5 + 5;
// 开N*20为4e6

int n, m, q, a[N], l, r, k, d[N], mp[N];  // 这里m是值域

int cnt, roots[N], sum[N * 20], ls[N * 20], rs[N * 20];
int build(int l, int r) {
	int p = ++cnt;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	return ls[p] = build(l, mid), rs[p] = build(mid + 1, r), p;
}
int copy(int rt) {   // 复制原树节点
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], sum[p] = sum[rt], p;
}
int update(int x, int l, int r, int rt) {
	int p = copy(rt); sum[p]++;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, l, mid, ls[p]);
	else rs[p] = update(x, mid + 1, r, rs[p]);
	return p;
}
int query(int l, int r, int k, int rt1, int rt2) {
	int mid = (l + r) >> 1, num = sum[ls[rt2]] - sum[ls[rt1]];
	if (l == r) return l;
	if (k <= num) return query(l, mid, k, ls[rt1], ls[rt2]);
	else return query(mid + 1, r, k - num, rs[rt1], rs[rt2]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i], d[i] = a[i];
	sort(d + 1, d + n + 1);
	m = unique(d + 1, d + n + 1) - d - 1;
	for (int i = 1; i <= n; i++) {
		int val = lower_bound(d + 1, d + m + 1, a[i]) - d;
		mp[val] = a[i], a[i] = val;
	}
	roots[0] = build(1, m);
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], 1, m, roots[i - 1]);
	while (q--) {
		cin >> l >> r >> k;
		cout << mp[query(1, m, k, roots[l - 1], roots[r])] << '\n';
	}
}
```

## P4137 Rmq Problem / mex

这题可以 bitset 配合莫队水过。不过使用可持久化权值线段树是高贵的在线做法。

首先 $\operatorname{mex} \in [0,n+1]$，这题不用离散化。对于每一个 $a_i$，在权值线段树上维护它最后一次出现的位置，开 $n$ 棵权值线段树，第 $i$ 棵维护序列的 $[1,i]$ 前缀，查询在 $[1,r]$ 中找最小的且最后一次出现位置小于 $l$ 的数，在第 $r$ 棵线段树上二分求解即可。复杂度 $O((n+q) \log n)$。

```cpp
const int N = 2e5 + 5;

int n, q, a[N], l, r;

int cnt, roots[N], last[N * 20], ls[N * 20], rs[N * 20];
int copy(int rt) {
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], last[p] = last[rt], p;
}
int update(int x, int c, int l, int r, int rt) {
	int p = copy(rt);
	if (l == r) return last[p] = c, p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, c, l, mid, ls[p]);
	else rs[p] = update(x, c, mid + 1, r, rs[p]);
	last[p] = min(last[ls[p]], last[rs[p]]);
	return p;
}
int query(int x, int l, int r, int rt) {
	if (l == r) return l;
	int mid = (l + r) >> 1;
	if (last[ls[rt]] < x) return query(x, l, mid, ls[rt]);
	else return query(x, mid + 1, r, rs[rt]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], i, 0, n + 1, roots[i - 1]);
	while (q--) {
		cin >> l >> r;
		cout << query(l, 0, n + 1, roots[r]) << '\n';
	}
}
```

## P4587 [FJOI2016] 神秘数

从暴力开始思考，先对 $[l,r]$ 区间排序，设当前值域为 $[1,V]$，扫一遍区间，若 $a_i>V+1$，此时 $V+1$ 会被跳过而表示不出来，故答案为 $V+1$，否则令 $V \gets a_i+V$ 并继续扫描。

然后我们开 $n$ 棵权值线段树，模拟上述过程，因为 $V$ 每次至少增加一倍，复杂度为 $O(q \log n \log \sum a)$，是正确的。

```cpp
const int N = 2e5 + 5;
int n, q, a[N], l, r;

int cnt, roots[N], sum[N << 5], ls[N << 5], rs[N << 5];
int copy(int rt) {
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], sum[p] = sum[rt], p;
}
int update(int x, int c, int l, int r, int rt) {
	int p = copy(rt); sum[p] += c;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, c, l, mid, ls[p]);
	else rs[p] = update(x, c, mid + 1, r, rs[p]);
	return p;
}
int query(int tl, int tr, int l, int r, int rt1, int rt2) {
	if (tl <= l && r <= tr) return sum[rt1] - sum[rt2];
	int mid = (l + r) >> 1, res = 0;
	if (tl <= mid) res += query(tl, tr, l, mid, ls[rt1], ls[rt2]);
	if (tr > mid) res += query(tl, tr, mid + 1, r, rs[rt1], rs[rt2]);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], a[i], 1, 1e9, roots[i - 1]);
	cin >> q;
	while (q--) {
		cin >> l >> r;
		int res = 1;
		while (true) {
			int val = query(1, res, 1, 1e9, roots[r], roots[l - 1]);
			if (val >= res) res = val + 1;
			else break;
		} cout << res << '\n';
	}
}
```
