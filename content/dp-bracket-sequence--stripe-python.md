---
id: dp-bracket-sequence
title: '括号序列模型'
category: '动态规划'
subcategory: '区间DP'
tags: ["括号序列","区间DP","计数","栈"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 定义

一般地，定义一个括号序列是仅由 `(` 与 `)` 组成的字符串。合法括号序列的定义为：

1. 空串为一个合法括号序列；
2. 若 `s` 为合法括号序列，则 `(s)` 也是合法括号序列；
3. 若 `s`、`t` 均为合法括号序列，则 `st` 也是合法括号序列。

括号序列其实是一种模型，描述一类二元对应平衡关系。有时还会有 `[]`、`{}`、`<>` 等不同的括号。

## 经典问题

## 合法性判断

栈的经典应用。令 $n=|s|$，维护一个栈，枚举 $i \in [1,n]$：

- 若 $s_i$ 为右括号，且栈顶为对应的左括号，弹出栈顶；
- 否则，将 $s_i$ 入栈。

复杂度为 $O(n)$。代码：

```cpp
bool check(const string& s) {
	stack<char> st;
	int n = s.size();
	for (int i = 0; i < n; i++) {
		if (s[i] == ')' && !st.empty() && st.top() == '(') st.pop();
		else st.emplace(s[i]);
	}
	return st.empty();
}
```

## 合法括号序列计数

设 $H_n$ 为 $n$ 对括号能形成的合法括号序列数。设合法序列的形式为 `(a)b`，其中 `a` 的括号对数为 $m$，则 $b$ 的括号对数为 $n-m-1$，则有

$H_n=\sum_{m=0}^{n-1}H_i H_{n-m-1}$这是 Catalan 数的递推式。计算公式可见 [组合数学复习笔记](https://www.luogu.com.cn/article/fk7v2y6c) 中 Catalan 数相关部分。

## 字典序后继

在这里我们认为左括号的字典序小于右括号。

找到一个最大的 $i$，满足：

- $s_i$ 为左括号；
- $[1,i-1]$ 中左括号的数量严格大于右括号数量

于是将 $s_i$ 变为右括号。设此时 $[1,i]$ 中左括号比右括号多 $k$ 个，贪心地，令最后 $k$ 个为右括号，剩余部分用 `((((()))))` 这样的形式填充。复杂度 $O(n)$。

```cpp
bool next_sequence(string& s) {
	int n = s.size();
	for (int i = n - 1, cnt = 0; i >= 0; i--) {
		if (s[i] == '(') cnt--;
		else cnt++;
		if (s[i] == '(' && cnt > 0) {
			cnt--;
			int x = (n - i - 1 - cnt) / 2, y = n - i - 1 - x;
			string t = s.substr(0, i) + ')' + string(x, '(') + string(y, ')');
			s.swap(t);
			return true;
		}
	}
	return false;
}
```

## 字典序计算

令 $n=|s|$，求比 $s$ 字典序小的括号序列 $t$ 的数目。枚举一个 $i$，表示 $\forall 1\le j <i t_j=s_j$，而 $t_i<s_i$，即 $s_i$ 为右括号而 $t_i$ 为左括号。

设在 $[1,i]$ 中左括号比右括号多 $k$ 个，则 $[i+1,n]$ 中就少 $k$ 个。设 $dp_{i,j}$ 为长度为 $i$ 的括号序列，上述讨论中 $k=j$ 的个数。有：

$dp_{i,j}=dp_{i-1,j-1}+dp_{i-1,j+1}$预处理 $O(n^2)$，查询 $O(n)$。Code：

```cpp
int dp[N][N];
void solve(int n) {
	dp[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		dp[i][0] = dp[i - 1][1];
		for (int j = 1; j <= n; j++) dp[i][j] = dp[i - 1][j - 1] + dp[i - 1][j + 1];
	}
}

long long rnk(const string& s) {
	int n = s.size(), cnt = 0;
	long long res = 1;
	for (int i = 1; i <= n; i++) {
		if (s[i - 1] == ')') res += dp[n - i][cnt + 1], cnt--;
		else cnt++;
	}
	return res;
}
```

## 求字典序为 kkk 的括号序列

上面的 $dp$ 仍然管用。我们从前往后思考，考虑第 $i$ 个位置是否能为 `)`。如果 $s_i$ 是 `)`，则有 $k > dp_{n-i,cnt+1}$，其中 $cnt$ 是当前左括号的数量与右括号数量之差。

若不能填右括号，且填一个左括号不会让后面怎么填都不合法了，也就是 $cnt < \dfrac{1}{2} n$，则填一个左括号。反之，填右括号并令 $k \gets k-dp_{n-i,cnt+1}$。预处理 $O(n^2)$，查询 $O(n)$。

```cpp
string kth(int n, long long k) {
	string s(n, ' ');
	int cnt = 0;
	for (int i = 1; i <= n; i++) {
		if (cnt + 1 <= n / 2 && dp[n - i][cnt + 1] >= k) s[i - 1] = '(', cnt++;
		else {
			s[i - 1] = ')';
			if (cnt + 1 <= n / 2) k -= dp[n - i][cnt + 1];
			cnt--;
		}
	}
	return s;
}
```

## 例题

括号序列的例题是很活的。

## P1944 最长括号匹配

括号匹配基础练手题。我这里介绍一个模板，用一个 01 串的每一位表示该位是否匹配，本题所求即为最长的连续 1 子串的下标。这个 01 串用栈即可方便地求出，复杂度 $O(n)$。

```cpp
const int N = 1e6 + 5;

int n;
char s[N];
bool ok[N];

void solve() {   // 预处理匹配 01 串
	stack<pair<char, int>> st;
	for (int i = 1; i <= n; i++) {
		if (!st.empty() && ((st.top().first == '(' && s[i] == ')') || (st.top().first == '[' && s[i] == ']'))) {
			ok[i] = ok[st.top().second] = true;
			st.pop();
		} else {
			st.emplace(s[i], i);
		}
	}
}

void _main() {
	cin >> (s + 1); n = strlen(s + 1);
	solve();
	int mxlen = 0, l = 0, r = 0;
	for (int i = 1; i <= n; ) {
		while (i <= n && !ok[i]) i++;
		int start = i;
		while (i <= n && ok[i]) i++;
		if (i - start > mxlen) mxlen = i - start, l = start, r = i - 1;
	}
	for (int i = l; i <= r; i++) cout << s[i];
}
```

## P5658 [CSP-S2019] 括号树

树上的括号匹配。考虑一个简单的树形 DP，令 $dp_u$ 为 $[1,u]$ 的合法子串数目。

在全局维护一个栈，和传统方法一样存左括号下标。分类讨论：

- 若 $s_u$ 为 `(`，直接入栈，令 $dp_u \gets 0$；
- 若 $s_u$ 为 `)` 但栈为空，令 $dp_u \gets 0$；
- 若 $s_u$ 为 `)`，设栈顶为 $t$ 并出栈，令 $dp_u \gets dp_{fa_t}+1$。这里的贡献为 $t$ 父亲那里的合法子串加上 $(t,u)$ 这对括号，或者就是单独一对括号。注意这里的出栈操作最后要回溯回来。

复杂度为 $O(n)$。

```cpp
int n, fa[N], st[N];
char s[N];
long long dp[N], ans;

void dfs(int u, long long pre, int top) {
	int t = 0;
	if (s[u] == '(') st[++top] = u;
	else if (top) t = st[top--], dp[u] = dp[fa[t]] + 1, pre += dp[u];
	ans ^= pre * u;
	for (int j = head[u]; j != 0; j = edge[j].next) dfs(edge[j].to, pre, top);
	if (t) st[++top] = t;
}

void _main() {
	cin >> n >> (s + 1);
	for (int i = 2; i <= n; i++) cin >> fa[i], add_edge(fa[i], i);
	dfs(1, 0, 0);
	cout << ans;
}
```

## P8745 [蓝桥杯 2021 省 AB] 括号序列

对于一个不合法的括号序列，如 `)((())(`，如果我们把已经匹配的位置删去，结果为 `)((`，所以使它合法的添加方式是：**在左侧加左括号，在右侧加右括号。**

两种情况显然同理，不妨先看左侧。以样例为例，如果我们将序列按右括号断开，则可以写成

```css
(x(x(x
(x((xx
((xx(x
((x(xx
(((xxx
```

所以“本质不同”的添加结果实际上就是不同的划分方案，这种方案就是在连续的 `)))` 之间的位置加入若干左括号，可以想到 DP。

令 $dp_{i,j}$ 表示第 $i$ 个右括号前加上 $j$ 个左括号的方案数，同时设 $a_i$ 为以 $i$ 结尾的子串中有多少个右括号未匹配，这样 $j \ge a_i$。枚举上一个右括号前加了多少个左括号，有转移：

$dp_{i,j}=\sum_{k=a_{i-1}}^{j} dp_{i-1,k}$直接做是 $O(n^3)$ 的。不过我们发现 $k \in [a_{i-1},j]$，直接对 $dp_{i-1}$ 处理前缀和，复杂度为 $O(n^2)$。

至于右边的情况，将序列翻转并镜像（也就是左右括号互换）后同理可求得。由乘法原理，两种情况相乘取答案。

```cpp
const int N = 5005;
int n, a[N];
char s[N];
modint dp[N][N], pre[N];

modint solve() {
	memset(dp, 0, sizeof(dp)), memset(a, 0, sizeof(a));
	int tot = 0, lcnt = 0, rcnt = 0;
	for (int i = 1; i <= n; i++) {
		if (s[i] == '(') lcnt++;
		else rcnt++;
		if (s[i] == ')') {
			if (lcnt > 0) lcnt--, rcnt--;  // 匹配一对
			a[++tot] = rcnt;
		}
	}
	fill(pre, pre + N, 0);
	for (int j = a[1]; j <= tot; j++) dp[1][j] = 1, pre[j] = pre[j - 1] + dp[1][j];
	for (int i = 2; i <= tot; i++) {
		for (int j = a[i]; j <= tot; j++) {
			if (a[i - 1] == 0) dp[i][j] = pre[j];  // 防越界
			else dp[i][j] = pre[j] - pre[a[i - 1] - 1];
		}
		fill(pre, pre + a[i], 0);
		for (int j = a[i]; j <= tot; j++) pre[j] = pre[j - 1] + dp[i][j];
	}
	return dp[tot][a[tot]];
}

void _main() {
	cin >> (s + 1);
	n = strlen(s + 1);
	modint l = solve();
	reverse(s + 1, s + n + 1);
	for (int i = 1; i <= n; i++) s[i] = (s[i] == '(') ? ')' : '(';
	modint r = solve();
	if (l == 0) cout << r;   // 特判形如(((((的字符串
	else if (r == 0) cout << l;
	else cout << l * r;
}
```

## UVA1626 括号序列 Brackets sequence

括号序列中这种加字符使原序列合法的问题，常用区间 DP。令 $dp_{l,r}$ 表示使子串 $[l,r]$ 合法需添加的最少字符数量。

- 若 $s_l,s_r$ 为一对匹配括号，则 $dp_{l,r} \gets \min(dp_{l,r},dp_{l+1,r-1})$。若 $l+1>r-1$，令 $dp_{l,r} \gets 0$。
- 常规区间 DP 套路，枚举断点 $mid$ 分成两段序列，则 $dp_{l,r} \gets \min(dp_{l,r},dp_{l,mid}+dp_{mid+1,r})$。

题目要求方案，所以我们再整一次递归，按照上述转移的方法去输出。复杂度 $O(n^3)$。

```cpp
const int N = 105;

string h;
int n, dp[N][N];
char s[N];

void dfs(int l, int r) {
	if (l == r) {
		if (s[l] == '(' || s[l] == ')') cout << "()";
		else cout << "[]";
		return;
	}
	if ((s[l] == '(' && s[r] == ')') || (s[l] == '[' && s[r] == ']')) {
		if (l + 1 > r - 1) return cout << s[l] << s[r], void();
		if (dp[l][r] == dp[l + 1][r - 1]) {
			cout << s[l], dfs(l + 1, r - 1), cout << s[r];
			return;
		}
	}
	for (int mid = l; mid < r; mid++) {
		if (dp[l][r] == dp[l][mid] + dp[mid + 1][r]) return dfs(l, mid), dfs(mid + 1, r), void();
	}
}

void _main(int t) {
	getline(cin, h), getline(cin, h); // 这题输入很恶心，有可能是空串
	n = h.size();
	memset(s, 0, sizeof(s));
	for (int i = 0; i < n; i++) s[i + 1] = h[i];
	memset(dp, 0x3f, sizeof(dp));
	for (int i = 1; i <= n; i++) dp[i][i] = 1;
	for (int len = 1; len <= n; len++) {
		for (int l = 1; l + len - 1 <= n; l++) {
			int r = l + len - 1;
			if ((s[l] == '(' && s[r] == ')') || (s[l] == '[' && s[r] == ']')) {
				dp[l][r] = min(dp[l][r], l + 1 <= r - 1 ? dp[l + 1][r - 1] : 0);
			}
			for (int mid = l; mid < r; mid++) dp[l][r] = min(dp[l][r], dp[l][mid] + dp[mid + 1][r]);
		}
	}
	dfs(1, n);
	cout << '\n';
	if (t) cout << '\n';
} signed main() {
	//freopen("test.out", "w", stdout);
	int t = 1; for (scanf("%d", &t), getchar(); t--; ) _main(t);
	return 0;
}
```

## P7914 [CSP-S 2021] 括号序列

括号序列 + $n \le 500$，区间 DP 启动。但是这题还有通配符，记 `<>` 为一个合法括号序列（空串也认为合法），`*+` 表示多个 `*` 连续（可为 0 个），我们考虑五种情况：

1. `*+`；
2. `(<>)`；
3. `<>*+`；
4. `(<>)<>(<>)`；
5. `*+<>`。

然后用 $dp_{opt,l,r}$ 表示方案数。下称 `*` 与 `?` 为通配符，则转移：

- 若 $r-l+1\le k$，且 $dp_{0,l,r-1}=0$，且 $s_r$ 为通配符，则 $dp_{0,l,r}= 1$。

首先区间长度不能超过 $k$，然后借助 $dp_{0,l,r-1}$ 判断 $[l,r-1]$ 内是否都是通配符，这样直接判断一下 $r$ 就行。
- 若 $s_l,s_r$ 可以成为一对匹配括号（即为匹配括号或 `?`），则 $dp_{1,l,r} = dp_{0,l+1,r-1}+dp_{2,l+1,r-1}+dp_{3,l+1,r-1}+dp_{4,l+1,r-1}$。

这个转移我们在上一题是见过的。就是抛掉左右两端的括号看区间里头的方案。
- $dp_{2,l,r}=\sum_{i=l}^{r-1} dp_{3,l,i}\times dp_{0,i+1,r}$。

枚举断点 $i$，2 类序列的前面是 `<>`，也就是一个任意合法的序列，由 3 类序列提供贡献，而后面是一个 0 类序列。
- $dp_{4,l,r}=\sum_{i=l}^{r-1} dp_{0,l,i}\times dp_{3,i+1,r}$。

这个与 2 类序列的转移同理。
- $dp_{3,l,r}=dp_{1,l,r}+\sum_{i=l}^{r-1} (dp_{2,l,i}+dp_{3,l,i}) \times dp_{1,i+1,r}$。

首先 1 类序列是特殊的 3 类序列。然后对于 $[l,i]$，3 类序列左边那个 `(<>)<>` 可以由 2/3 两类序列提供，而右边那个 `(<>)` 则由 1 类序列提供。

这样 dp，复杂度 $O(n^3)$，答案为 $dp_{3,1,n}$。

```cpp
const int N = 505;

int n, k;
char s[N];
modint dp[5][N][N];

void _main() {
	cin >> n >> k >> (s + 1);
	for (int i = 1; i <= n; i++) dp[0][i][i - 1] = 1;  // 后面 dp[x][l + 1][r - 1] 会有区间越界
	for (int len = 1; len <= n; len++) {
		for (int l = 1; l + len - 1 <= n; l++) {
			int r = l + len - 1;
			if (len <= k && dp[0][l][r - 1] == 1 && (s[r] == '*' || s[r] == '?')) dp[0][l][r] = 1;
			if (len < 2) continue;
			if ((s[l] == '(' || s[l] == '?') && (s[r] == ')' || s[r] == '?')) dp[1][l][r] = dp[0][l + 1][r - 1] + dp[2][l + 1][r - 1] + dp[3][l + 1][r - 1] + dp[4][l + 1][r - 1];
			dp[3][l][r] = dp[1][l][r];
			for (int i = l; i < r; i++) {
				dp[2][l][r] += dp[3][l][i] * dp[0][i + 1][r];
				dp[4][l][r] += dp[0][l][i] * dp[3][i + 1][r];
				dp[3][l][r] += (dp[2][l][i] + dp[3][l][i]) * dp[1][i + 1][r];
			}
		}
	}
	cout << dp[3][1][n];
}
```

## P9753 [CSP-S 2023] 消消乐

可消除子串就是一个合法括号序列，本题有 $26$ 种括号。

我们维护一个栈去做括号匹配，若当前字符串 $s_i$ 与栈顶形成一对匹配括号则弹出栈顶否则入栈。动态维护栈内这个字符串的哈希值 $h$。比如说对于 `abbaa` 这个串：

```routeros
i=1 stack: [a]  h=hash(a)
i=2 stack: [ab]  h=hash(ab)
i=3 stack: [a]  h=hash(a)
i=4 stack: []  h=hash()
i=5 stack: [a]  h=hash(a)
```

当 $h$ 又一次出现时，意味着在两个括号之间的序列是合法的，所以带来贡献。我们可以维护一个哈希表 $mp$，用 $mp_{h}$ 表示哈希值为 $h$ 的子串所带来的当前贡献量。在循环结束时，令 $mp_{h} \gets mp_{h}+1$。

当然在上述样例 $i=4$ 时，栈为空串意味着所有东西都匹配走了，所以空串的初始贡献为 $1$，即 $mp_{0} \gets 1$。

哈希模数取 $10^{15}+37$ 并使用平板电视卡常。理论复杂度 $O(n)$。

```cpp
const int N = 2e6 + 5;

const modint base = 13331;
modint b[N];

int n;
char s[N];
stack<char> st;
cc_hash_table<long long, int> mp;

void _main() {
	cin >> n >> (s + 1); mp[0] = 1;
	b[0] = 1;
	for (int i = 1; i < N; i++) b[i] = b[i - 1] * base;
	modint h = 0; long long res = 0;
	for (int i = 1; i <= n; i++) {
		if (!st.empty() && s[i] == st.top()) h -= b[st.size()] * st.top(), st.pop();
		else st.emplace(s[i]), h += b[st.size()] * st.top();
		res += mp[h.val]++;
	}
	cout << res;
}
```

## P10513 括号

有意思的数据结构题。最长合法括号子序列这个东西是一个可合并信息，具体地：

维护三个值 $val,lc,rc$，$val$ 为所求答案，在答案最大化情况下，$lc,rc$ 分别表示失配的左右括号数目。在合并时，令 $p=\min(lc_x,rc_y)$，用 $x$ 中的失配左括号去匹配 $y$ 中的失配右括号，累加答案即可。至此静态版本可用线段树解决。

考虑带修，也就是支持区间取反。这里有两种方法：

1. 类似文艺平衡树，维护两棵树，一棵存正串一棵存反串，修改时打标记交换对应结点；
2. 在一棵树的同一个结点维护正反串，修改时打标记交换。

代码用的方法 2。复杂度 $O((n+q) \log n)$。

```cpp
const int N = 5e5 + 5;

int n, q, opt, l, r;
char s[N];

struct node {
	int val, lc, rc;
	node() : val(0), lc(0), rc(0) {}
	node(int x, int y, int z) : val(x), lc(y), rc(z) {}
};
node operator+ (const node& a, const node& b) {
	return node{
		a.val + b.val + min(a.lc, b.rc),
		a.lc + b.lc - min(a.lc, b.rc),
		a.rc + b.rc - min(a.lc, b.rc)
	};
}

#define ls (rt << 1)
#define rs (rt << 1 | 1)
bool rev[N << 2]; node val[N << 2], rval[N << 2];
void pushup(int rt) {val[rt] = val[ls] + val[rs], rval[rt] = rval[ls] + rval[rs];}
void pushdown(int rt) {
	if (!rev[rt]) return;
	rev[ls] ^= 1, rev[rs] ^= 1, rev[rt] ^= 1;
	swap(val[ls], rval[ls]), swap(val[rs], rval[rs]);
}

void build(int l, int r, int rt) {
	if (l == r) {
		if (s[l] == '(') val[rt].lc = rval[rt].rc = 1;
		else val[rt].rc = rval[rt].lc = 1;
		return;
	}
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}

void reverse(int tl, int tr, int l, int r, int rt) {
	if (tl <= l && r <= tr) return rev[rt] ^= 1, swap(val[rt], rval[rt]), void();
	pushdown(rt);
	int mid = (l + r) >> 1;
	if (tl <= mid) reverse(tl, tr, l, mid, ls);
	if (tr > mid) reverse(tl, tr, mid + 1, r, rs);
	pushup(rt);
}

node query(int tl, int tr, int l, int r, int rt) {
	if (tl <= l && r <= tr) return val[rt];
	pushdown(rt);
	int mid = (l + r) >> 1; node res;
	if (tl <= mid) res = res + query(tl, tr, l, mid, ls);
	if (tr > mid) res = res + query(tl, tr, mid + 1, r, rs);
	return res;
}

void _main() {
	cin >> n >> (s + 1) >> q;
	build(1, n, 1);
	while (q--) {
		cin >> opt >> l >> r;
		if (opt == 1) reverse(l, r, 1, n, 1);
		if (opt == 2) cout << query(l, r, 1, n, 1).val << '\n';
	}
}
```

## P8765 [蓝桥杯 2021 国 AB] 翻转括号序列

再介绍一个括号题的套路。令左括号为 $-1$，右括号为 $1$，设前缀和为 $pre_i$。当 $[l,r]$ 为合法括号序列时：

1. $pre_{l-1}=pre_r$；
2. $\forall i \in [l,r],pre_{l-1} \le pre_i$。

翻译一下：序列的和与最小前缀和均为 $0$。而 $l$ 一定时，最小前缀和关于 $r$ 单调不增，考虑二分。取反操作与上题同理，维护反串。复杂度 $O(q \log^2 n)$。使用线段树上二分可以做到 $O(q \log n)$。

```cpp
const int N = 1e6 + 5;

int n, q, opt, l, r;
char s[N];

struct node {
	int sum, premn, premx;
	node() : sum(0), premn(0), premx(0) {}
	node(int a, int b, int c) : sum(a), premn(b), premx(c) {}
};
node operator+ (const node& a, const node& b) {
	return node{
		a.sum + b.sum,
		min(a.premn, a.sum + b.premn),
		max(a.premx, a.sum + b.premx)
	};
}

#define ls (rt << 1)
#define rs (rt << 1 | 1)
bool rev[N << 2]; node val[N << 2];
void pushup(int rt) {val[rt] = val[ls] + val[rs];}
void reverses(int rt) {  // 取反串
	val[rt].sum = -val[rt].sum, val[rt].premx = -val[rt].premx, val[rt].premn = -val[rt].premn;
	swap(val[rt].premx, val[rt].premn), rev[rt] ^= 1;
}
void pushdown(int rt) {
	if (!rev[rt]) return;
	rev[rt] ^= 1;
	reverses(ls), reverses(rs);
}

void build(int l, int r, int rt) {
	if (l == r) {
		if (s[l] == '(') val[rt].sum = val[rt].premx = val[rt].premn = 1;
		else val[rt].sum = val[rt].premx = val[rt].premn = -1;
		return;
	}
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}

void reverse(int tl, int tr, int l, int r, int rt) {
	if (tl <= l && r <= tr) return reverses(rt), void();
	pushdown(rt);
	int mid = (l + r) >> 1;
	if (tl <= mid) reverse(tl, tr, l, mid, ls);
	if (tr > mid) reverse(tl, tr, mid + 1, r, rs);
	pushup(rt);
}

int query_sum(int tl, int tr, int l, int r, int rt) {
	if (tl <= l && r <= tr) return val[rt].sum;
	pushdown(rt);
	int mid = (l + r) >> 1, res = 0;
	if (tl <= mid) res += query_sum(tl, tr, l, mid, ls);
	if (tr > mid) res += query_sum(tl, tr, mid + 1, r, rs);
	return res;
}
int query_pre(int tl, int tr, int l, int r, int rt, int tot) {
	if (tl <= l && r <= tr) return val[rt].premn + tot;
	pushdown(rt);
	int mid = (l + r) >> 1, res = INT_MAX;
	if (tl <= mid) res = min(res, query_pre(tl, tr, l, mid, ls, tot)), tot += query_sum(tl, tr, l, mid, ls);
	if (tr > mid) res = min(res, query_pre(tl, tr, mid + 1, r, rs, tot));
	return res;
}

int query(int l, int r) {
	int tl = l, tr = r, res = INT_MAX;
	while (tl <= tr) {
		int mid = (tl + tr) >> 1;
		if (query_pre(l, mid, 1, n, 1, 0) >= 0) tl = mid + 1, res = mid;
		else tr = mid - 1;
	}
	if (res == INT_MAX) return 0;
	int x = res;
	while (x >= l) {
		int h = query_sum(l, x, 1, n, 1);
		if (h == 0) return x;
		x -= h;
	}
	return 0;
}

void _main() {
	cin >> n >> q >> (s + 1);
	build(1, n, 1);
	while (q--) {
		cin >> opt >> l;
		if (opt == 1) cin >> r, reverse(l, r, 1, n, 1);
		else cout << query(l, n) << '\n';
	}
}
```
