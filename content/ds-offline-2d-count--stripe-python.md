---
id: ds-offline-2d-count
title: '离线二维数点'
category: '数据结构'
subcategory: '其他数据结构'
tags: ["离线","二维数点","树状数组","扫描线"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
最近 % 你赛出了好几个这样的问题。

## 算法思想

将询问离线，按一个端点排序，用另一维作扫描线统计答案。统计时，按题目选择权值 / 序列树状数组或线段树，复杂度为 $O(n\log n)$ 级别。

## 例题

## P10814 【模板】离线二维数点

板子题。注意到 $ans_{l,r}=ans_{1,r}-ans_{1,l-1}$，考虑对每个前缀 $[1,x]$ 统计答案。按 $x$ 排序，此时询问有序，类似双指针地顺次加点，则只需要统计当前 $\le num$ 的个数。使用**权值树状数组**。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 2e6 + 5;

int n, m, l, r, x, a[N], ans[N];
int tot;
struct node {
	int x, num, id, typ;
	bool operator< (const node& a) const {return x < a.x;}
} q[N << 1];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {for (; x < N; x += lowbit(x)) tr[x] += c;}
int ask(int x) {int res = 0; for (; x; x -= lowbit(x)) res += tr[x]; return res;}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= m; i++) {
		cin >> l >> r >> x;
		q[++tot] = node{l - 1, x, i, -1};
		q[++tot] = node{r, x, i, 1};
	}
	sort(q + 1, q + tot + 1);
	for (int i = 1, j = 1; i <= tot; i++) {
		for (; j <= q[i].x; j++) add(a[j], 1);
		ans[q[i].id] += q[i].typ * ask(q[i].num);
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P2163 [SHOI2007] 园丁的烦恼

类板子题的二维版本。由二维前缀和，有

$q(x_1,y_1,x_2,y_2)=ans_{x_2,y_2}-ans_{x_1-1,y_2}-ans_{x_2,y_1-1}+ans_{x_1-1,y_1-1}$于是拆成四段，转化为二维数点问题。仍然使用**权值树状数组**。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 5e5 + 5, M = 1e7 + 5;

int n, m, tot, ans[N];
struct pos {
	int x, y;
	bool operator< (const pos& x) const {return y < x.y;}
} a[N];
struct node {
	int r, l, id, typ;
	bool operator< (const node& x) const {return l < x.l;}
} q[N << 2];

int tr[M];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {for (; x < M; x += lowbit(x)) tr[x] += c;}
int ask(int x) {int res = 0; for (; x >= 1; x -= lowbit(x)) res += tr[x]; return res;}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i].x >> a[i].y;
	for (int i = 1; i <= m; i++) {
		int x1, y1, x2, y2;
		cin >> x1 >> y1 >> x2 >> y2;
		//x1++, y1++, x2++, y2++;
		q[++tot] = node{x2, y2, i, 1};
		if (x1 >= 1) q[++tot] = node{x1 - 1, y2, i, -1};
		if (y1 >= 1) q[++tot] = node{x2, y1 - 1, i, -1};
		if (x1 >= 1 && y1 >= 1) q[++tot] = node{x1 - 1, y1 - 1, i, 1};
	}
	sort(a + 1, a + n + 1), sort(q + 1, q + tot + 1);
	for (int i = 0, j = 1, k = 1; i <= n; i++) {
		for (; j <= n && a[j].y == i; j++) add(a[j].x + 1, 1);
		debug(q[k].l);
		for (; k <= tot && q[k].l == i; k++) ans[q[k].id] += q[k].typ * ask(q[k].r + 1);
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P1972 [SDOI2009] HH的项链

这里无法进行前缀和，将询问按右端点排序。扫描时注意到我们只关注最右边的颜色，利用该性质，删掉左边的颜色并加入新颜色即可。于是使用**序列树状数组**。实现的时候开一个 $vis$ 数组记录上一个颜色。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 1e6 + 5;

int n, m, a[N], vis[N], ans[N];
struct node {
	int l, r, id;
} q[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void update(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int query(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res += tr[x];
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	cin >> m;
	for (int i = 1; i <= m; i++) cin >> q[i].l >> q[i].r, q[i].id = i;
	sort(q + 1, q + m + 1, [](const node& x, const node& y) -> bool {
		return x.r < y.r;
	});
	int nxt = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = nxt; j <= q[i].r; j++) {
			if (vis[a[j]]) update(vis[a[j]], -1);
			vis[a[j]] = j, update(j, 1);
		}
		ans[q[i].id] = query(q[i].r) - query(q[i].l - 1);
		nxt = q[i].r + 1;
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P4113 [HEOI2012] 采花

与上一题极其相似，这一次关注的是最右的两个颜色。实现时，开两个数组 $vis_1,vis_2$，关注上两个颜色。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 2e6 + 5;
// 这里省略了快读

int n, c, m, a[N], ans[N];
struct node {
	int l, r, id;
} q[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void update(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int query(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res += tr[x];
	return res;
}

int mp[N], vis1[N], vis2[N];

void _main() {
	read(n), read(c), read(m);
	for (int i = 1; i <= n; i++) read(a[i]);
	for (int i = 1; i <= m; i++) read(q[i].l), read(q[i].r), q[i].id = i;
	sort(q + 1, q + m + 1, [](const node& x, const node& y) -> bool {
		return x.r < y.r;
	});
	int nxt = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = nxt; j <= q[i].r; j++) {
			if (!vis1[a[j]]) vis1[a[j]] = j;
			else {
				if (!vis2[a[j]]) {
					update(vis1[a[j]], 1);
				} else {
					update(vis2[a[j]], 1);
					update(vis1[a[j]], -1);
					vis1[a[j]] = vis2[a[j]];
				}
				vis2[a[j]] = j;
			}
		}
		ans[q[i].id] = query(q[i].r) - query(q[i].l - 1);
		nxt = q[i].r + 1;
	}

	for (int i = 1; i <= m; i++) write(ans[i]), putchar('\n');
	flush();
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P4303 [AHOI2006] 基因匹配

如果元素不重复，LCS 可以转化为 LIS 在 $O(n \log V)$ 时间内使用二维数点求解。见 [P1439 【模板】最长公共子序列](https://www.luogu.com.cn/problem/P1439)。

由于本题每个元素的出现次数严格 $=5$，那么对 $a$ 排序，此时 $b$ 变为 LIS 问题，使用权值树状数组记录前缀 $\max$。贪心一下，发现转移等价时 $j$ 最大最优，倒序枚举 $j$ 即可。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 1e5 + 5;

int n, a[N], b[N];
vector<int> pos[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {
	for (; x < N; x += lowbit(x)) tr[x] = max(tr[x], c);
}
int ask(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res = max(res, tr[x]);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= 5 * n; i++) cin >> a[i], pos[a[i]].emplace_back(i);
	for (int i = 1; i <= 5 * n; i++) cin >> b[i];
	// 变LIS，二维数点权值前缀max
	for (int i = 1; i <= 5 * n; i++) {
		for (int j = 4; j >= 0; j--) {
			int x = pos[b[i]][j];
			add(x, ask(x - 1) + 1);
		}
	}
	cout << ask(5 * n);
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```
