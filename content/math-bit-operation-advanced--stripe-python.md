---
id: math-bit-operation-advanced
title: '位运算进阶：01-Trie 与 bitset'
category: '数学'
subcategory: '数学基础'
tags: ['01-Trie', 'bitset', '位运算']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 20. 位运算进阶

由于把 01-Trie、bitset 和比较难的例题放到上面会影响阅读体验，于是把这部分拆开了。

## 20.1 01-Trie

字符上的 Trie 属于字符串算法，而二进制上的 Trie 是解决异或问题的有力数据结构。

先介绍 Trie 树，其中文名为字典树，是一棵边带权的叶向树。借用 OI-Wiki 的图：

![trie1](https://oi-wiki.org/string/images/trie1.png)

可以发现，Trie 树通过把相同的字符串前缀压到一起，实现节省复杂度的目的。而如果字符集为 $\{0,1\}$，就叫做 01-Trie，下面我们来介绍 01-Trie 维护异或和时的操作。

01-Trie 的本质是一棵值域为 $2^d$ 的权值线段树。

### 20.1.1 插入 & 删除

由于维护的是异或和，只需知道每一位上 $0/1$ 的奇偶性。故节点需要维护以下三个数组：

- `ch[0/1][x]`：维护节点 $x$ 的左 / 右儿子；
- `w[x]`：维护 $x$ 子树权值的数目。这里可以直接维护奇偶性。
- `xorv[x]`：维护 $x$ 子树的整体异或和。

由此可以写出 01-Trie 的上传操作：

```cpp
inline void pushup(int rt) {
    w[rt] = xorv[rt] = 0;
    if (ch[0][rt]) {
        w[rt] += w[ch[0][rt]];
        xorv[rt] ^= xorv[ch[0][rt]] << 1;
    }
    if (ch[1][rt]) {
        w[rt] += w[ch[1][rt]];
        xorv[rt] ^= (xorv[ch[1][rt]] << 1) | (w[ch[1][rt]] & 1);
    }
}
```

插入删除是平凡的，将数二进制拆分后在遍历路径中更新对应信息即可。

```cpp
inline int newnode() {
    cnt++;
    ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
    return cnt;
}
void insert(int& rt, const T& x, int dep) {
    if (!rt) rt = newnode();
    if (dep > H) return w[rt]++, void();
    insert(ch[x & 1][rt], x >> 1, dep + 1);
    pushup(rt);
}

void remove(int rt, const T& x, int dep) {
    if (dep > H) return w[rt]--, void();
    remove(ch[x & 1][rt], x >> 1, dep + 1);
    pushup(rt);
}
```

### *20.1.2 全局加一

一个神奇操作。考虑二进制下如何加一：

```basic
10101 + 1 = 10110
100000010111111 + 1 = 100000011000000
```

只需要找到最低位的 $0$，将其变为 $1$，然后把后面的所有 $1$ 置 $0$ 即可。放到 Trie 上，直接交换左右儿子并沿交换后 $0$ 的权值边向下递归即可。

```cpp
void add1(int rt) {
    swap(ch[0][rt], ch[1][rt]);
    if (ch[0][rt]) add1(ch[0][rt]);
    pushup(rt);
}
```

### *20.1.3 合并

没错，这神奇玩意还能合并。如果你学过线段树合并或者 FHQ-Treap 的话，这个东西相当好理解。

先判掉 $x,y$ 是空树的情况。直接把 $b$ 的信息放到 $a$ 上，然后递归合并左右儿子即可。

```cpp
int merge(int a, int b) {
    if (!a || !b) return a ? a : b;
    w[a] += w[b], xorv[a] ^= xorv[b];
    ch[0][a] = merge(ch[0][a], ch[0][b]), ch[1][a] = merge(ch[1][a], ch[1][b]);
    return a;
}
```

至此我们实现了一个支持插入 / 删除，全局加一，合并，全局异或和的数据结构。自己造的 [板子题](https://www.luogu.com.cn/problem/U456135)。

## 20.2 bitset

### 20.2.1 用法 & 原理

在 GNU C++ 中，`bitset` 位于 `<bitset>` 头文件中，是一个维护 01 序列的数据结构。其用法如下：

```cpp
bitset<N> bs;  // bitset的长度为定值，初始化时全为0
bs.set();  // 全设为1
bs.reset();   // 全设为0
bs.count();  // 1的数量
bs[x];   // 第x位
bs[x] = 0/1;  // 设置第x位
bs._Find_first();  // 第一个1的位置
bs._Find_next(x);  // [x + 1, N)中第一个1的位置，没有返回N
```

同时，`bitset` 与 `bitset` 直接可以进行按位或、按位与、按位异或运算，还可以对 `bitset` 进行左移右移操作。

在 64 位机器的 bitset 内部实现中，将 $w=64$ 个二进制位压成一组，用一个无符号 64 位整数存储，这本质上是一种分块思想。各种操作都是对这些整数的运算，从而获得了 $\dfrac{1}{w}$ 的常数。一般地，bitset 的复杂度上要乘一个 $\dfrac{1}{w}$。

在目前，可以认为 $O(\dfrac{n^2}{w})$ 在 1s 内可以稳定通过 $n=10^5$ 的数据。

bitset 虽然只能维护一个 01 序列，但其应用非常多。我们在前面见过 bitset 配合埃氏筛的应用。bitset 还用于高维偏序、01 背包、DAG 可达性等问题。同时一个常见的场景是利用 `_Find_next` 向后跳。

### *20.2.2 手写 bitset

下面是一份手写的 bitset 板子。在实际使用中，它和 std::bitset 常数基本一样。

在一些题目中，$w$ 需要取一个更小或者更大的数，此时我们就需要手写 bitset 了。

```cpp
template <const int N>
class BitSet {
private:
	static const int size = (N >> 6) + ((N & 63) != 0);
	uint64_t a[size];
	int find_after(int x) const {
		for (int i = x; i < size; i++) {
			if (a[i]) return __builtin_ctzll(a[i]) ^ (i << 6);
		} return N;
	}
	struct Pos {
		BitSet<N>& bs;
		int pos;
		Pos() : pos(0) {}
		Pos(BitSet<N>& _bs, int _pos) : bs(_bs), pos(0) {}
		int operator= (int x) {return bs.set(pos, x), x;}
		operator int() const {return bs.get(pos);}
	};
public:
	BitSet() {memset(a, 0, sizeof(a));}
	BitSet(const BitSet<N>& x) {memcpy(a, x.a, sizeof(a));}
	int get(int x) const {return a[x >> 6] >> (x & 63) & 1;}
	int operator[] (int x) const {return get(x);}
	Pos operator[] (int x) {return Pos(*this, x);}
	void set(int x, int val = 1) {
		if (x >= N || x < 0) return;
		if (val == 0) a[x >> 6] &= ~(1ULL << (x & 63));
		else a[x >> 6] |= 1ULL << (x & 63);
	}
	void reset(int x) {set(x, 0);}
	void filp(int x) {
		if (x >= N || x < 0) return;
		a[x >> 6] ^= 1ULL << (x & 63);
	}
	void set() {for (int i = 0; i < size; i++) a[i] = -1ULL;}
	void reset() {memset(a, 0, sizeof(a));}
	void flip() {for (int i = 0; i < size; i++) a[i] = ~a[i];}
	int count() const {
		int res = 0;
		for (int i = 0; i < size; i++) res += __builtin_popcountll(a[i]);
		return res;
	}
	BitSet<N> operator~ () const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = ~a[i];
		return res;
	}
	BitSet<N> operator<< (const int& len) const {
		BitSet<N> res;
		uint64_t last = 0;
		for (int i = 0; i + (len >> 6) < size; i++) {
			res.a[i + (len >> 6)] = last | (a[i] << (len & 63));
			if (len & 63) last = a[i] >> (64 - (len & 63));
		} return res;
	}
	BitSet<N> operator>> (const int& len) const {
		BitSet<N> res;
		uint64_t last = 0;
		for (int i = size - 1; i >= (len >> 6); i--) {
			res.a[i - (len >> 6)] = last | (a[i] >> (len & 63));
			if (len & 63) last = a[i] << (64 - (len & 63));
		} return res;
	}
	BitSet<N>& operator&= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] &= x.a[i];
		return *this;
	}
	BitSet<N>& operator|= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] |= x.a[i];
		return *this;
	}
	BitSet<N>& operator^= (const BitSet<N>& x) {
		for (int i = 0; i < size; i++) a[i] ^= x.a[i];
		return *this;
	}
	BitSet<N>& operator<<= (const int& len) {return *this = *this << len;}
	BitSet<N>& operator>>= (const int& len) {return *this = *this >> len;}
	BitSet<N> operator& (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] & x.a[i];
		return res;
	}
	BitSet<N> operator| (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] | x.a[i];
		return res;
	}
	BitSet<N> operator^ (const BitSet<N>& x) const {
		BitSet<N> res;
		for (int i = 0; i < size; i++) res.a[i] = a[i] ^ x.a[i];
		return res;
	}
	bool any() const {
		for (int i = 0; i < size; i++) if (!a[i]) return false;
		return true;
	}
	bool none() const {
		for (int i = 0; i < size; i++) if (a[i]) return false;
		return true;
	}
	int first() const {return find_after(0);}
	int next(int x) const {
		uint64_t cur = a[x >> 6] >> (x & 63) >> 1;
		if (cur) return __builtin_ctzll(cur) + x + 1;
		return find_after((x >> 6) + 1);
	}
	int _Find_first() const {return first();}
	int _Find_next(int x) const {return next(x);}
};
```

## 20.3 例题

依次是 01-Trie、bitset 和比较难的位运算题。

### P10471 最大异或对 The XOR Largest Pair

感觉是 01-Trie 最经典的应用。先全部插入到 Trie 上，然后依次枚举每个数，找这个数能够形成的最大异或对。根据异或性质，我们贪心来取，每次尽量选不一样的数位遍历 01-Trie 即可。

```cpp
const int N = 2e6 + 5;
int n, a[N];
int cnt = 1, ch[2][N];

void insert(int x) {
	int cur = 1;
	for (int i = 31; i >= 0; i--) {
		int p = x >> i & 1;
		if (!ch[p][cur]) ch[p][cur] = ++cnt;
		cur = ch[p][cur];
	}
}
int query(int x) {
	int cur = 1, res = 0;
	for (int i = 31; i >= 0; i--) {
		int p = x >> i & 1;
		if (!ch[p ^ 1][cur]) cur = ch[p][cur];
		else cur = ch[p ^ 1][cur], res += (1 << i);
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], insert(a[i]);
	int res = 0;
	for (int i = 1; i <= n; i++) res = max(res, query(a[i]));
	cout << res;
}
```

### P4551 最长异或路径

好像没有头绪。记根节点到 $u$ 点的路径异或和为 $s_u$，推波式子：

$$
\begin{aligned}
e_u \oplus \cdots \oplus e_v &= e_u \oplus \cdots \oplus e_{lca(u,v)} \oplus e_v \oplus \cdots \oplus e_{lca(u,v)} \\
&= e_1 \oplus \cdots \oplus e_{lca(u,v)} \oplus \cdots \oplus e_u  \oplus e_1 \oplus \cdots \oplus e_{lca(u,v)} \oplus \cdots \oplus e_v\\
&=s_u \oplus s_v
\end{aligned}
$$

这里利用了异或性质 $a \oplus a=0$，从根节点到 $lca(u,v)$ 这段路径异或两次就是没有异或。于是这题转化为上题。

### *P6018 [Ynoi2010] Fusion tree

我们发现操作 1 & 3 都是相邻点的操作，不好在树上维护，因此我们统一维护所有点儿子的异或信息，单独处理父亲。然后用 01-Trie 来维护即可，对每个点打个标记维护增加量。单独处理的时候，先删除再插入即可，具体看代码。

```cpp
const int N = 5e5 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

#define ls (ch[0][rt])
#define rs (ch[1][rt])
int cnt, w[N * 21], xorv[N * 21], ch[2][N * 21];
int newnode() {
	cnt++;
	ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
	return cnt;
} void pushup(int rt) {
	w[rt] = xorv[rt] = 0;
	if (ls) w[rt] += w[ls], xorv[rt] ^= xorv[ls] << 1;
	if (rs) w[rt] += w[rs], xorv[rt] ^= (xorv[rs] << 1) | (w[rs] & 1);
} void insert(int& rt, int x, int dep = 0) {
	if (!rt) rt = newnode();
	if (dep > 20) return w[rt]++, void();
	insert(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void remove(int rt, int x, int dep = 0) {
	if (dep > 20) return w[rt]--, void();
	remove(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void add1(int rt) {
	if (!rt) return;
	swap(ls, rs), add1(ls), pushup(rt);
}

int n, q, u, v, a[N], opt, x, y;
int fa[N], rt[N], tag[N];

void dfs(int u, int f) {
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == f) continue;
		fa[v] = u, dfs(v, u);
	}
}

void change(int x, int c) {   // 单独处理节点x的权值
	if (x != 1) remove(rt[fa[x]], a[x] + tag[fa[x]]);
	a[x] += c;
	if (x != 1) insert(rt[fa[x]], a[x] + tag[fa[x]]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
	} dfs(1, -1);
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 2; i <= n; i++) insert(rt[fa[i]], a[i]);
	while (q--) {
		cin >> opt >> x;
		if (opt == 1) {
			tag[x]++, add1(rt[x]);  // 子树全局加1
			if (x != 1) change(fa[x], 1);
		} else if (opt == 2) {
			cin >> y, change(x, -y);
		} else if (opt == 3) {
			if (x != 1) {
				if (fa[x] != 1) cout << (xorv[rt[x]] ^ (a[fa[x]] + tag[fa[fa[x]]])) << '\n';
				else cout << (xorv[rt[x]] ^ a[fa[x]]) << '\n';
			} else {
				cout << xorv[rt[x]] << '\n';
			}
		}
	}
}
```

### *P6623 [省选联考 2020 A 卷] 树

思考 $val(x)$ 的意义，可以发现一个暴力，就是将子树内的点权全部加 $1$ 后再异或起来贡献到父亲，是一个类似树形 dp 的思想。具体地，对于儿子 $v$ 的 $val_v =a_1 \oplus a_2 \oplus \cdots \oplus a_k$，则贡献为 $(a_1+1) \oplus (a_2+1) \oplus \cdots \oplus (a_k+1)$，复杂度 $O(n^2)$。

考虑在每个节点建立一棵 01-Trie，对儿子的 Trie 作合并并全局加一，然后把自己的点权放进去。

考虑复杂度。Trie 的合并操作当且仅当两棵 Trie 存在相同元素时产生 $O(\log n)$ 复杂度。设其出现 $x$ 次，总合并次数 $\sum x = n$，因此复杂度为严格 $O(n \log n)$。

```cpp
const int N = 6e5 + 5;
int tot, head[N];
struct Edge {
	int next, to;
} edge[N];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

int n, a[N], f;

#define ls (ch[0][rt])
#define rs (ch[1][rt])
int cnt, w[N * 20], xorv[N * 20], ch[2][N * 20];
int newnode() {
	cnt++;
	ch[1][cnt] = ch[0][cnt] = w[cnt] = xorv[cnt] = 0;
	return cnt;
} void pushup(int rt) {
	w[rt] = xorv[rt] = 0;
	if (ls) w[rt] += w[ls], xorv[rt] ^= xorv[ls] << 1;
	if (rs) w[rt] += w[rs], xorv[rt] ^= (xorv[rs] << 1) | (w[rs] & 1);
} void insert(int& rt, int x, int dep = 0) {
	if (!rt) rt = newnode();
	if (dep > 20) return w[rt]++, void();
	insert(ch[x & 1][rt], x >> 1, dep + 1), pushup(rt);
} void add1(int rt) {
	if (!rt) return;
	swap(ls, rs), add1(ls), pushup(rt);
} int merge(int a, int b) {
	if (!a || !b) return a ? a : b;
	w[a] += w[b], xorv[a] ^= xorv[b];
	ch[0][a] = merge(ch[0][a], ch[0][b]), ch[1][a] = merge(ch[1][a], ch[1][b]);
	return a;
}

int rt[N];
long long ans;
void dfs(int u) {
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		dfs(v), rt[u] = merge(rt[u], rt[v]);
	}
	add1(rt[u]), insert(rt[u], a[u]);
	ans += xorv[rt[u]];
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 2; i <= n; i++) cin >> f, add_edge(f, i);
	dfs(1); cout << ans;
}
```

### *P10218 [省选联考 2024] 魔法手杖

两年后再看这个题其实没有那么可怕。特别是 72pts 做法其实并不难。

看到最大化最小值，直接二分答案 $mid$。注意到 $a_i \oplus x \le a_i+x$，因此选择的 $a_i$ 使得 $a_i \oplus x \ge mid$ 一定可以成立，反之 $a_i +x < mid$ 一定不能成立。

考虑对于 $a_i$ 从高位向低位建立一棵 01-Trie，在每个节点上记录最小的 $a_i$ 和总代价，判定答案时遍历整棵树。贪心地，从高位向低位考虑，进行一个类似树上数位 DP 的东西。具体地，记 $sum_{rt}$ 为当前节点的总代价，$mn_{rt}$ 为当前节点上的最小 $a_i$。进行一个 DFS，用三元组 $(cmn,csum,cur)$ 记录当前状态。

- 若 $mid$ 的当前位为 $1$：
  - 若走 $1$ 边，$(cmn,csum)$ 受左子树影响，$cur$ 不变。

  - 若走 $0$ 边，$(cmn,csum)$ 受右子树影响，$cur$ 的当前位改变。

- 若 $mid$ 的当前位为 $0$：
  - 若走 $0$ 边，$(cmn,csum)$ 不变，$cur$ 不变。

  - 若走 $1$ 边，$(cmn,csum)$ 不变，$cur$ 的当前位改变。

当递归到叶子时，判断是否存在可行方案，即 $mid \le cur+cmn+2^d-1$。

需要特判 $\sum b \le m$，总复杂度 $O(nk^2)$，可以获得 72pts。需要比较精细的实现，不然会被卡常变成 32pts。

```cpp
const int N = 1e5 + 5;
constexpr int128 pw(int x) {return int128(1) << x;}
const int128 inf = pw(120) + 5;
int n, m, k, b[N];
int128 a[N];

struct trie {
	int tot, num[2][N * 120];
	int128 sum[N * 120], mn[N * 120];
	trie() : tot(1) {}
	void clear() {
		for (int i = 0; i <= tot; i++) num[0][i] = num[1][i] = 0, sum[i] = 0, mn[i] = inf;
		tot = 1, sum[1] = 0, mn[1] = inf;
	}
	void insert(int128 x, int cost) {
		int rt = 1;
		mn[rt] = min(mn[rt], x), sum[rt] += cost;
		for (int i = k - 1; i >= 0; i--) {
			int c = x >> i & 1;
			if (!num[c][rt]) num[c][rt] = ++tot, mn[tot] = inf, sum[tot] = 0;
			rt = num[c][rt], mn[rt] = min(mn[rt], x), sum[rt] += cost;
		}
	}
#define ls (num[0][rt])
#define rs (num[1][rt])
	bool dfs(int rt, int dep, int128 cmn, int128 csum, int128 mid, int128 cur) {
		if (csum > m) return false;
		if (dep < 0 || !rt) {
			if (dep >= 0) cur += pw(dep + 1) - 1;
			return mid <= cur + cmn;
		}
		if (mid >> dep & 1) {
			return dfs(rs, dep - 1, min(cmn, mn[ls]), csum + sum[ls], mid, cur)
			|| dfs(ls, dep - 1, min(cmn, mn[rs]), csum + sum[rs], mid, cur ^ pw(dep));
		} else {
			return dfs(ls, dep - 1, cmn, csum, mid, cur)
			|| dfs(rs, dep - 1, cmn, csum, mid, cur ^ pw(dep));
		}
	}
} tr;
bool check(int128 x) {return tr.dfs(1, k - 1, inf, 0, x, 0);}

void _main() {
	read(n, m, k), read(a + 1, a + n + 1), read(b + 1, b + n + 1);
	int128 sum = 0;
	for (int i = 1; i <= n; i++) sum += b[i];
	if (sum <= m) return writeln(*min_element(a + 1, a + n + 1) + pw(k) - 1), void();
	tr.clear();
	for (int i = 1; i <= n; i++) tr.insert(a[i], b[i]);
	int128 l = 0, r = pw(k) - 1, res = 0;
	while (l <= r) {
		int128 mid = (l + r) >> 1;
		if (check(mid)) l = mid + 1, res = mid;
		else r = mid - 1;
	} writeln(res);
}
```

这个分在我们 SX 已经足够进队了。下面考虑满分做法。

类比线段树上二分，考虑在 01-Trie 上二分，进行一个贪心从而逐位确定答案。若答案当前位能填 $1$，就必须舍去一棵子树。当无法填 $1$ 时，直接递归两棵子树求解。判断填 $1$ 的可行性和 72pts 做法一样。再记录一个值 $dm$ 表示 $m$ 与当前使用的代价的差，即可实现 $O(nk)$ 求解。实现大概长下面这样：

```cpp
void dfs(int rt, int dep, int128 dm, int128 x, int128 cmn, int128 cur) {
	if (dm < 0) return;
	if (dep < 0) return ans = max(ans, cur), void();
	if (!rt) return ans = max(ans, cmn + (x | (pw(dep) - 1) | pw(dep))), void();
	int128 u = x ^ (pw(dep) - 1);
	bool t1 = sum[ls] <= dm && u + min(cmn, mn[ls]) >= (cur ^ pw(dep)),
	t2 = sum[rs] <= dm && (u ^ pw(dep)) + min(cmn, mn[rs]) >= (cur ^ pw(dep));
	if (t1) dfs(rs, dep - 1, dm - sum[ls], x, min(cmn, mn[ls]), cur ^ pw(dep));
	if (t2) dfs(ls, dep - 1, dm - sum[rs], x | pw(dep), min(cmn, mn[rs]), cur ^ pw(dep));
	if (!t1 && !t2) dfs(ls, dep - 1, dm, x, cmn, cur), dfs(rs, dep - 1, dm, x | pw(dep), cmn, cur);
}

ans = 0, tr.dfs(1, k - 1, m, 0, pw(k), 0);   // 不用二分，改成这样即可
writeln(ans);
```

### AT_abc330_e [ABC330E] Mex and Update

单点修改 + 全局 mex。注意到 $a_i \le 10^9$，但实际值域只能到 $n+1$。

考虑用一个 bitset 维护值域，删数是简单的，加数就用 `_Find_next` 暴力扫即可。复杂度 $O(\dfrac{nq}{w})$。

```cpp
const int N = 2e5 + 5;
int n, q, a[N], x, y, res, cnt[N];
bitset<N> bs;
void add(int x) {
	if (x >= N) return;
	cnt[x]++, bs.set(x, 0);
	if (res == x) res = bs._Find_next(x);
}
void del(int x) {
	if (x >= N) return;
	if (--cnt[x] == 0) bs.set(x, 1), res = min(res, x);
}
void _main() {
	cin >> n >> q;
	bs.set();
	for (int i = 1; i <= n; i++) cin >> a[i], add(a[i]);
	while (q--) {
		cin >> x >> y;
		del(a[x]), add(a[x] = y);
		cout << res << '\n';
	}
}
```

你可以使用这种方法配合普通莫队通过 [P4137 Rmq Problem / mex](https://www.luogu.com.cn/problem/P4137)。

### P1537 弹珠

bitset 优化背包。正常 01 背包的实现大概是这样：

```cpp
dp[0] = 1;
for (int i = 1; i <= n; i++) {
	for (int j = m; j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]]);
}
```

考虑构建一个 bitset，用第 $i$ 位表示第 $i$ 个物品是否能取到。对于新的 $w_i$，若选，则原来能取到 $j$ 的数就能取到 $j+w_i$，代码为 `s <<= w[i]`，不选是一样的，所以或上去即可。

```cpp
bitset<N> s;
s[0] = 1;
for (int i = 1; i <= n; i++) s |= (s << w[i]);
```

回到这题，可以直接暴力把多重背包拆成 01 背包，再上 bitset 优化解决。

```cpp
const int N = 2e5 + 5;
int a[8];
bitset<N> dp;

void main() {
	for (int kase = 1; ; kase++) {
		int tot = 0;
		for (int i = 1; i <= 6; i++) cin >> a[i], tot += a[i] * i;
		if (!tot) return;
		cout << "Collection #" << kase << ":\n";
		if (tot & 1) {cout << "Can't be divided.\n\n"; continue;}
		dp.reset(), dp.set(0, 1);
		for (int i = 1; i <= 6; i++) {
			for (int j = 1; j <= a[i]; j++) {
				dp |= (dp << i);
				if (dp[tot >> 1]) {cout << "Can be divided.\n\n"; goto flag;}
			}
		}
		cout << "Can't be divided.\n\n";
		flag:;
	}
}
```

### *P3810 【模板】三维偏序（陌上花开）

做法来自[这篇题解](https://www.luogu.com.cn/article/gtnbcf0u)。

bitset 的高端应用之一。对于 $k$ 维偏序问题，使用 bitset 解决的复杂度为 $O(\dfrac{n^2k}{w})$，对比其他算法的 $O(n \log^2 n)$ 很优秀了。

开 $n$ 个 bitset，用 $b_{i,j}$ 表示 $j$ 的每一维都不超过 $i$，初始化所有 $b_{i,j}=1$。枚举三维并分别按该维排序，用一个新的 bitset 来记录当前维度 $j$ 是否超过 $i$，不妨令其为 $s$。注意到 $j$ 有单调性容易维护，循环结束后执行 `b[i] &= s` 即可。

注意到开 `bitset<N> b[N]` 在 $n =10^5$ 时需要 1192MB，无法通过。使用分组 bitset 的技巧，时间换空间，将操作每 $B$ 个处理一次，于是只需开 $B$ 个 bitset。会比较卡常。

```cpp
const int N = 1e5 + 5, B = 1e4;
int n, k, a[3][N], p[3][N], ans[N];
bitset<N> b[B], s;  // 119MB

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[0][i] >> a[1][i] >> a[2][i];
	for (int i = 0; i < 3; i++) {
		iota(p[i] + 1, p[i] + n + 1, 1);
		sort(p[i] + 1, p[i] + n + 1, [&](int x, int y) -> bool {
			return a[i][x] < a[i][y];
		});
	}
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, l + B - 1);
		for (int i = l; i <= r; i++) b[i - l].set();
		for (int i = 0; i < 3; i++) {
			s.reset();
			for (int j = 1, k = 1; j <= n; j++) {
				int x = p[i][j];
				while (k <= n && a[i][p[i][k]] <= a[i][x]) s[p[i][k++]] = 1;
				if (l <= x && x <= r) b[x - l] &= s;
			}
		}
		for (int i = l; i <= r; i++) ans[b[i - l].count()]++;
	}
	for (int i = 1; i <= n; i++) cout << ans[i] << '\n';
}
```

### P10480 可达性统计

bitset 的又一个应用：DAG 可达性问题。

考虑在拓扑序上可行性 DP，记 $f_{x,y}$ 表示 $x$ 是否可以到达 $y$。建反图，跑一个拓扑排序，对于边 $(u,v)$ 作转移 $f_{v,i} \to f_{v,i}$。复杂度 $O(nm)$。

注意到如果将 $f_x$ 开成一个 bitset，上述转移就是 `f[v] |= f[u]`。复杂度 $O(\dfrac{nm}{w})$。请注意，**DAG 可达性问题没有更低复杂度的做法**。

```cpp
const int N = 3e4 + 5;
int n, m, deg[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
bitset<N> f[N];
queue<int> q;
void topo() {
	for (int i = 1; i <= n; i++) f[i][i] = 1;
	for (int i = 1; i <= n; i++) {
		if (!deg[i]) q.emplace(i);
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			f[v] |= f[u];
			if (!--deg[v]) q.emplace(v);
		}
	}
}

void _main() {
	cin >> n >> m;
	for (int i = 1, u, v; i <= m; i++) cin >> u >> v, add_edge(v, u), deg[u]++;
	topo();
	for (int i = 1; i <= n; i++) cout << f[i].count() << '\n';
}
```

### *P2150 [NOI2015] 寿司晚宴

两个子集中的数字两两互质，等价于子集中的质因数集合交集为空。

我们先从 30pts 开始考虑。因为 $n \le 30$，那么质因数只有 $10$ 个。设 $dp_{i,s,t}$ 表示当前考虑到第 $i$ 个数，质因子集合的二进制状态分别为 $s,t$ 的方案数。对于 $[2,n]$ 分解质因数，把质因数状压一波。枚举与 $s,t$ 无交集的 $k$，刷表法转移：

$$
\forall k|t =0,dp_{i+1,s|k,t} \gets dp_{i+1,s|k,t}+dp_{i,s,t}\\
\forall k|s =0, dp_{i+1,s,t|k} \gets dp_{i+1,s,t|k}+dp_{i,s,t}
$$

然后对于无交集的 $s,t$ 统计答案。可以滚动数组优化，时间复杂度为 $O(2^{2w} n)$，其中 $w=10$。

然后直接考虑正解。因为 $500$ 以内的质数有 $95$ 个，暴力 DP 直接爆炸。但是我们发现 $n$ 以内的数大于 $\sqrt{n}$ 的质因子最多只有一个，也就是大于 $23$ 的质因子最多一个。那么我们以 $23$ 为分界点，考虑在两侧分别 dp。

具体地，对于 $[2,500]$ 以内的数，我们先找出其最大质因子并按其排序，然后对每一个连续段统计答案。而 $23$ 以内的质数只有 $8$ 个，于是仍然令 $dp_{i,s,t}$ 表示考虑到第 $i$ 个数，质因子集合的二进制状态分别为 $s,t$ 的方案数，但是此时 $s,t \le 2^{8}$。接着考虑最大质因子的贡献，由于它只能被一个子集选走，令 $f_{i,s,t}$ 表示考虑到第 $i$ 个数，其最大质因子只能被第一个子集选走的方案数，$g_{i,s,t}$ 表示其最大质因子只能被第二个子集选走的方案数，仍然刷表转移：

$$
\forall k | t=0, f_{i+1,s|k,t} \gets f_{i+1,s|k,t}+f_{i,s,t}\\
\forall k | s=0, g_{i+1,s,t|k} \gets g_{i+1,s,t|k}+g_{i,s,t}
$$

把 $f,g$ 都合并到 $dp$ 里，需要容斥一下，因为会把不选的情况算两遍：

$dp_{i+1,s,t} \gets f_{i,s,t}+g_{i,s,t}-dp_{i,s,t}$然后我们滚动数组优化空间，注意要像 01 背包那样倒序枚举了。但是还有一个小优化是有用的集合满足 $s | t \ne 0$，那么我们可以枚举 $s$ 和其子集 $t$，这样复杂度优化到 $O(3^w n)$，其中 $w=8$。答案即为

$\sum_{s | t \ne 0} dp_{s,t}$当然这题 $O(4^wn)$ 就够了，代码用的就是无优化的做法。

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

对于这题来说，我们把 $<\sqrt{n}$ 的 $\ge \sqrt{n}$ 分成两类分别处理，最后降低复杂度，这就是根号分治的思想。

### *AT_arc137_d [ARC137D] Prefix XORs

每次一维前缀和可以对应到二维平面上的移动，考虑格路计数拆贡献。对于 $a$ 数组，$k$ 次前缀异或以后的总贡献为

$a_n=\bigoplus_{i=0} (C_{n-i+k-1}^{k-1} \bmod 2) a_{n-i}$考虑 $C_{(n-i)+(k-1)}^{k-1} \bmod 2 =1$ 的必要条件。根据 Lucas 定理，$n-i$ 与 $k-1$ 在二进制表示下所有 $1$ 的位置均不同，即 $(n-i)\&(k-1)=0$。

考虑枚举 $n-i$ 的补集的子集统计答案。复杂度 $O(n+3^{\log m})$，本题放过去了。

```cpp
const int N = 1e6 + 5;
int n, m, a[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int k = 1; k <= m; k++) {
		int res = a[n], s = (k - 1) ^ ((1 << 20) - 1);
		for (int t = s; t; t = (t - 1) & s) {
			if (t < n) res ^= a[n - t];
		} cout << res << ' ';
	}
}
```

### *AT_apc001_f XOR Tree

很神仙的一个题。

化边权为点权，把每个点的点权定义为其所连的边的边权异或和。此时再思考路径异或，发现因为 $a \oplus x \oplus x=a$，除了路径端点异或上一个 $x$，其他点点权不变。至此，题目转化为：

> 给定一个数组，每次将两个数将他们异或上同一个数，求最小操作次数使得数组所有数变为 $0$。

然而这个东西好像还是不可做。于是我们关注数据范围发现 $a_i \le 15$。我们先把权值相同的点两两抵消，那么剩下的是最多 $15$ 个互不相同的数字。

考虑状压 dp，设 $dp_{s}$ 表示以 $s$ 为状态的二进制集合全部消除的最小操作次数。当且仅当 $s$ 内数字异或和为 $0$ 时，$s$ 才能消掉。考虑转移，我们把 $s$ 拆成两个子集 $s_1,s_2$，且 $s_1,s_2$ 异或和均为 $0$，则两个子集直接合并就能减少一次操作。复杂度 $O(n+3^{V})$。于是我们解决了一道黑题。

```cpp
const int N = 1e5 + 5, M = 1 << 15;
int n, u, v, w, a[N], xorv[M + 5], cnt[20], dp[M + 5];

void _main() {
	cin >> n;
	for (int i = 1; i < n; i++) {
		cin >> u >> v >> w; u++, v++;
		a[u] ^= w, a[v] ^= w;
	}
	for (int i = 1; i <= n; i++) cnt[a[i]]++;
	int res = 0, fin = 0;
	for (int i = 1; i <= 15; i++) {
		res += cnt[i] / 2;
		if (cnt[i] & 1) fin |= 1 << (i - 1);  // 消不完
	}

	for (int i = 1; i < M; i++) {
		for (int j = 1; j <= 15; j++) {
			if (i >> (j - 1) & 1) xorv[i] ^= j;
		}
	}
	for (int i = 1; i < M; i++) {
		dp[i] = __builtin_popcount(i) - 1;
		if (xorv[i]) continue;
		for (int j = (i - 1) & i; j; j = (j - 1) & i) {
			if (xorv[j]) continue;
			dp[i] = min(dp[i], dp[j] + dp[i ^ j]);
		}
	}
	cout << res + dp[fin];
}
```
