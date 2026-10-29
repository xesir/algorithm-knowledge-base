---
id: math-linear-algebra
title: '线性代数（向量 / 线性变换 / 广义矩阵乘法）'
category: '数学'
subcategory: '线性代数'
tags: ['线性代数', '向量', '线性变换', '矩阵乘法']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 23. 线性代数

注意到我并没有把高斯消元扔到这里面，因为本人觉得高斯消元不用矩阵更好理解。

## 23.1 向量

以平面直角坐标系为例，一个**向量**可以看作由原点指向某点的一条有向线段，用

$$
\begin{bmatrix} a \\ b
 \end{bmatrix}
$$

 来表示。也可以用 $(a,b)$ 来表示一个向量。

这条有向线段的长度叫做向量的模。对于二维向量

$$
x=\begin{bmatrix} a \\ b
 \end{bmatrix}
$$

 有 $|x|=\sqrt{a^2+b^2}$。

向量代表的是如何从原点移动到终点。所以两个向量相加定义为两次移动叠加的效果，相减就是相加的逆运算。可得

$$
\begin{bmatrix} a \\ b
\end{bmatrix} \pm
\begin{bmatrix} c \\ d
\end{bmatrix} =
\begin{bmatrix} a \pm c \\ b \pm d
\end{bmatrix}
$$

向量也可以做数乘运算，相当于缩放操作。有

$$
c \begin{bmatrix} a \\ b
\end{bmatrix}=\begin{bmatrix} c \times a \\ c \times b
\end{bmatrix}
$$

## 23.2 线性变换

对于向量 $x=\begin{bmatrix} a \\ b \end{bmatrix}$，将它变为 $x'=\begin{bmatrix} ax_1+bx_2 \\ ay_1+by_2 \end{bmatrix}$，这个过程就是一个线性变换。不难发现，将平面上每个点对应的向量都作此变换，直线还是直线，原点还是原点。

注意到，一个二维线性变换仅由 $(x_1,x_2,y_1,y_2)$ 四个数字确定。这可以写作 $2 \times 2$ 的**矩阵**：

$$
\begin{bmatrix}
 x_1 & x_2 \\
 y_1 & y_2
\end{bmatrix}
$$

定义矩阵与向量的乘法就是对这个向量应用线性变换：

$$
Ax=\begin{bmatrix}
 x_1 & x_2 \\
 y_1 & y_2
\end{bmatrix} \begin{bmatrix} a \\ b \end{bmatrix}
=\begin{bmatrix} ax_1+bx_2 \\ ay_1+by_2 \end{bmatrix}
$$

同样地，多个线性变换也可以相互叠加。定义矩阵乘法 $AB$ 表示先应用线性变换 $B$，再应用 $A$。二维矩阵乘法如下：

$$
AB=\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix} \begin{bmatrix}
 e & f \\
 g & h
\end{bmatrix} 
=\begin{bmatrix}
 ae+bg & af+bh \\
 ce+ag & cf+dh
\end{bmatrix}
$$

应当注意，$AB \ne BA$，即矩阵乘法没有交换律。可以想到：先缩放后旋转和先旋转后缩放是不一样的。

但是可以发现，$(AB)C=A(BC)$，也就是矩阵乘法有结合律。这是一个重要的性质，通过这个性质，我们可以使用广义快速幂来计算矩阵的幂。

下面给出矩阵乘法的一般公式。对于 $C=AB$，有

$C_{i,j}=\sum_{k=1}^{n} A_{i,k}B_{k,j}$是一个 $O(n^3)$ 的过程。

矩阵的加减法是简单的，就是同位置的数相加减。注意到矩阵加法满足交换律和结合律。

下面给出一个矩阵的板子。

```cpp
template <class T, const int N>
struct matrix {
	T val[N][N];
	matrix() {clear();}
	void clear() {memset(val, 0, sizeof(val));}
	T* operator[] (int x) {return val[x];}
	void reset() {
		clear();
		for (int i = 0; i < N; i++) val[i][i] = 1;
	}
	matrix<T, N>& operator+= (matrix<T, N> B) {
		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) val[i][j] += B[i][j];
		} return *this;
	}
	matrix<T, N>& operator-= (matrix<T, N> B) {
		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) val[i][j] -= B[i][j];
		} return *this;
	}
	matrix<T, N> operator+ (matrix<T, N> B) {return matrix<T, N>(*this) += B;}
	matrix<T, N> operator- (matrix<T, N> B) {return matrix<T, N>(*this) -= B;}
	matrix<T, N> operator* (matrix<T, N> B) {
		auto& A = *this;
		matrix<T, N> C;
		for (int i = 0; i < N; i++) {
			for (int k = 0; k < N; k++) {
				if (A[i][k] == 0) continue;
				for (int j = 0; j < N; j++) C[i][j] += A[i][k] * B[k][j];
			}
		} return C;
	}
	matrix<T, N>& operator*= (matrix<T, N> B) {return *this = *this * B;}
};
template <class T, const int N>
matrix<T, N> mpow(matrix<T, N> a, long long b) {
	matrix<T, N> res; res.reset();
	for (; b; a *= a, b >>= 1) {
		if (b & 1) res *= a;
	} return res;
}
```

特别地，定义如下形式的矩阵是**单位矩阵**：

$I = \begin{bmatrix} 1 & 0 & \cdots & 0 \\ 0 & 1 & \cdots & 0 \\ \vdots & \vdots & \ddots & \vdots \\ 0 & 0 & \cdots & 1 \end{bmatrix}$有 $A\times I=A$。因此，单位矩阵相当于乘法中的单位“1”。

矩阵快速幂板子：[P3390](https://www.luogu.com.cn/problem/P3390)。

其实矩阵乘法能干的事情很多，比如加速数列递推。矩阵可以描述很多具有结合律的运算，方便我们使用线段树等数据结构维护信息。

## *23.3 广义矩阵乘法

一般地，定义矩阵乘法 $C=AB$ 满足

$C_{i,j}=\bigoplus_{k} A_{i,k} \otimes B_{k,j}$这里的 $\oplus, \otimes$ 都是一种二元运算，不是异或。

这叫做**广义矩阵乘法**。这样的矩阵乘法记作 $(\oplus,\otimes)$。我们可以发现，普通的矩阵乘法是一个 $(+,\times)$ 矩阵。

注意我们使用广义矩阵乘法时一般希望维护一个具有结合律的信息。下面我们给出 $(AB)C=A(BC)$ 的判定定理：

- 当且仅当 $\oplus$ 满足交换律，$\otimes$ 满足结合律，$\otimes$ 对 $\oplus$ 满足分配律时，广义矩阵乘法有结合律。

例如矩阵乘法 $(\max,\min)$ 的判定。注意到 $\max$ 对 $\min$ 的分配律：

$\max(\min(a,b),c)=\min(\max(a,c),\max(b,c))$常见的有结合律的广义矩阵乘法有：$(+,\times)$，$(\max,+)$，$(\max,\min)$ 等。下面是一个广义矩阵乘法的板子。

```cpp
template <class T, const int N, class Op1, class Op2, const T o = 0>
struct matrix {
	Op1 op1{}; Op2 op2{};
	T val[N][N];
	T* operator[] (int x) {return val[x];}
	matrix<T, N, Op1, Op2, o> operator* (matrix<T, N, Op1, Op2, o> B) {
		auto& A = *this;
		matrix<T, N, Op1, Op2, o> C;
		for (int i = 0; i < N; i++) {
			fill(C[i], C[i] + N, o);
			for (int k = 0; k < N; k++) {
				for (int j = 0; j < N; j++) C[i][j] = op1(C[i][j], op2(A[i][k], B[k][j]));
			}
		} return C;
	}
	matrix<T, N, Op1, Op2, o>& operator*= (matrix<T, N, Op1, Op2, o> B) {return *this = *this * B;}
};
template <class T>
struct AddOP {
	constexpr T operator() (T a, T b) {return a + b;}
};
template <class T>
struct MinOP {
	constexpr T operator() (T a, T b) {return min(a, b);}
};
template <class T>
struct MaxOP {
	constexpr T operator() (T a, T b) {return max(a, b);}
};
```

在一些题目中，我们会使用数据结构来维护具有结合律的广义矩阵乘法。动态 DP 就使用了这种技巧。

## 23.4 例题

### P10502 Matrix Power Series

矩阵的等比数列求和，考虑使用分治求和法优化。实现一个矩阵快速幂然后分治求和，复杂度为 $O(n^3 \log^2 k)$。

```cpp
using node = matrix<int, 30>;
int n, k, p;
node A;
node sum(node k, int n) {
	if (n == 1) return k;
	node A; A.reset();
	A = (A + mpow(k, n >> 1)) * sum(k, n >> 1);
	if (n & 1) A += mpow(k, n);
	return A;
}
void _main() {
	cin >> n >> k >> p;
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) cin >> A.val[i][j];
	}
	node B = sum(A, k);
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) cout << B.val[i][j] << ' ';
		cout << '\n';
	}
}
```

### P1962 斐波那契数列

矩阵应用之一：优化数列递推。

用矩阵优化 $f_n=f_{n-1}+f_{n-2}$ 这个递推。我们希望找到一个矩阵，将 $\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}$ 变换为 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}$。考虑待定系数，设矩阵

$$
A=\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}
$$

，列方程：

$$
\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}=\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}
$$

根据矩阵乘向量的定义拆开，然后得到：

$$
\left\{\begin{matrix}
f_n=af_{n-1}+bf_{n-2} \\
f_{n-1}=cf_{n-1}+df_{n-2}
\end{matrix}\right.
$$

观察可得，$a=1,b=1,c=1,d=0$ 时符合递推式。故

$$
A=\begin{bmatrix}
 1 & 1 \\
 1 & 0
\end{bmatrix}
$$

。根据数学归纳法可得 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}=A^{i-2} \begin{bmatrix} 1\\ 1\end{bmatrix}$。使用矩阵快速幂优化，复杂度 $O(\log n)$。

```cpp
long long n;
void _main() {
	matrix<mint, 2> A;
	A.val[0][0] = A.val[0][1] = A.val[1][0] = 1;
	cin >> n;
	if (n <= 2) return cout << 1, void();
	auto M = mpow(A, n - 2);
	cout << M.val[0][0] + M.val[0][1];
}
```

### P1349 广义斐波那契数列

和上题差不多，设矩阵 $A$ 表示一次变换，列方程：

$$
\begin{bmatrix} f_{i-1} \\ f_{i-2}\end{bmatrix}\begin{bmatrix}
 a & b \\
 c & d
\end{bmatrix}=\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}
$$

写成方程组：

$$
\left\{\begin{matrix}
f_n=af_{n-1}+bf_{n-2} \\
f_{n-1}=cf_{n-1}+df_{n-2}
\end{matrix}\right.
$$

对比递推式 $f_n=p \times f_{n-1}+q\times f_{n-2}$ 可得

$$
A=\begin{bmatrix}
 p & q \\
 1 & 0
\end{bmatrix}
$$

同理 $\begin{bmatrix} f_{i} \\ f_{i-1}\end{bmatrix}=A^{i-2} \begin{bmatrix} 1\\ 1\end{bmatrix}$。代码就不给了。

### P1939 矩阵加速（数列）

考虑一次变换让 $\begin{bmatrix} a_{n-1} \\ a_{n-2} \\a_{n-3} \end{bmatrix}$ 变成 $\begin{bmatrix} a_{n} \\ a_{n-1} \\a_{n-2} \end{bmatrix}$。设矩阵

$$
A=\begin{bmatrix}
a & b & c \\
d & e & f \\
i & j & k 
\end{bmatrix}
$$

写成方程组就有

$$
\left\{\begin{matrix}
a_n=a\times a_{n-1}+b \times a_{n-2}+c\times a_{n-3}\\
a_{n-1}=d\times a_{n-1}+e \times a_{n-2}+f\times a_{n-3}\\
a_{n-2}=i\times a_{n-1}+j \times a_{n-2}+k\times a_{n-3}
\end{matrix}\right.
$$

对比递推式 $a_n=a_{n-1}+a_{n-3}$，得到

$$
A=\begin{bmatrix}
1 & 0 & 1 \\
1 & 0 & 0 \\
0 & 1 & 0 
\end{bmatrix}
$$

答案为 $(A^n)_{2,1}$。

### *P3216 [HNOI2011] 数学作业

不难得出

$C(n)=C(n-1) \times 10^{1+ \lfloor \lg n\rfloor }+n$直接递推做复杂度为 $O(n)$。通过转移方程发现 $C(n)$ 与 $n,n-1$ 有关，所以我们希望有矩阵将 $\begin{bmatrix} C(n-1) \\ n-1 \\n\end{bmatrix}$ 变换为 $\begin{bmatrix} C(n) \\ n+1 \\n\end{bmatrix}$。仍然可以待定系数并对照递推式，得到

$$
\begin{bmatrix} C(n) \\ n+1 \\n\end{bmatrix}=
\begin{bmatrix}
10^{1+\lfloor \lg n \rfloor} & 0 & 1 \\
0 & 0 & 1 \\
0 & -1 & 2
\end{bmatrix}
\begin{bmatrix} C(n-1) \\ n-1 \\n\end{bmatrix}
$$

矩阵快速幂即可，复杂度 $O(\log^2 n)$。这题还有一个 $O(\log^3 n)$ 的广义快速幂 + 分治求和的做法。

```cpp
void _main() {
	cin >> n >> p; n++;
	pw[0] = 1;
	for (int i = 1; i < 30; i++) pw[i] = pw[i - 1] * 10;
	matrix<int, 3> A, V;  // V为向量，A为矩阵
	V.val[2][0] = 1, A.val[0][2] = 1, A.val[1][2] = 1, A.val[2][1] = -1, A.val[2][2] = 2;
	for (int i = 1; i < 30; i++) {
		A.val[0][0] = pw[i] % p;
		if (n < pw[i]) {
			V *= mpow(A, n - pw[i - 1]);
			return cout << (V.val[0][0] % p + p) % p, void();
		}
		V *= mpow(A, pw[i] - pw[i - 1]);
	}
}
```

### *P3990 [SHOI2013] 超级跳马

矩阵应用之二：矩阵优化 DP。

考虑计数 DP，令 $dp_{i,j}$ 表示跳到 $(i,j)$ 的方案数。显然有转移

$dp_{i,j}=\sum_{k \bmod 2=1} (dp_{i-1,j-k}+dp_{i,j-k}+dp_{i+1,j-k})$这是 $O(nm^2)$ 的。考虑对奇偶行维护前缀和来优化，设 $f_{i,j}=\sum_{k \bmod 2=1} dp_{i,j-k}$，有 $f_{i,j}=f_{i,j-2}+dp_{i,j}$，则转移方程改写为

$dp_{i,j}=f_{i-1,j-1}+f_{i,j-1}+f_{i+1,j-1}$代入 $f$ 的转移方程得

$f_{i,j}=f_{i-1,j-1}+f_{i,j-1}+f_{i+1,j-1}+f_{i,j-2}$优化到 $O(nm)$。注意到这是一个线性递推的式子，考虑矩阵快速幂优化 DP。

我们希望找到一个矩阵 $A$，使得向量 $(f_{1,j},f_{2,j},\cdots,f_{n,j},f_{1,j-1},f_{2,j-1},\cdots,f_{n,j-1})$ 在乘上 $A$ 后变为 $(f_{1,j+1},f_{2,j+1},\cdots,f_{n,j+1},f_{1,j},f_{2,j},\cdots,f_{n,j})$。这是容易的，根据转移方程的系数构造即可。最后的答案为 $dp_{n,m}=f_{n,m}-f_{n,m-2}$。复杂度 $O(n^3 \log m)$。

这个题告诉我们：DP 状态一维很小，一维很大时，就要考虑矩阵快速幂优化 DP 了。

```cpp
int n, m;
matrix<mint, 100> A;
mint f(int n, int m) {
	if (m <= 0) return 0;
	matrix<mint, 100> B;
	B.val[0][0] = 1;
	auto C = B * mpow(A, m - 1);
	return C.val[0][n - 1];
}

void _main() {
	cin >> n >> m;
	for (int i = 0; i < n; i++) {
		A.val[i][i] = 1, A.val[i + n][i] = 1, A.val[i][i + n] = 1;
		if (i != 0) A.val[i - 1][i] = 1;
		if (i != n - 1) A.val[i + 1][i] = 1;
	}
	cout << f(n, m) - f(n, m - 2);
}
```

### P9893 [ICPC 2018 Qingdao R] Soldier Game

考虑 DP。有两种 DP 都能得到 $O(n^2)$ 做法，但只有下面这种是有前途的：枚举最小值 $c$，设 $dp_i$ 表示考虑到 $i$ 的最小 $\max$。容易得到转移：

$dp_i=\min(\max(dp_{i-1},a_i),\max(dp_{i-2},a_{i-1}+a_i))$要求 $a_i \ge c$ 和 $a_{i-1}+a_i \ge c$。注意到 $c$ 只有 $2n$ 种，可以 $O(n^2)$ 解决。

这本身是一个线性 DP，而且这个转移可以想到 $(\min,\max)$ 广义矩阵乘法。可以用一棵线段树来维护矩阵的积。具体地：

$$
\begin{bmatrix}dp_i\\ dp_{i-1}\end{bmatrix}\begin{bmatrix}
a_i & a_i+a_{i-1} & \\
-\infty & \infty 
\end{bmatrix}=\begin{bmatrix}dp_{i-1}\\ dp_{i-2}\end{bmatrix}
$$

这里的乘法是 $(\min,\max)$ 乘法。待定系数一下即可得到。然后我们实现一个单点修改全局查询的线段树即可，复杂度 $O(n \log n)$ 带八倍常数。

```cpp
const int N = 1e6 + 5;
const long long inf = 1e18;
long long n, a[N];
using node = matrix<long long, 2, MaxOP<long long>, MinOP<long long>, -inf>;
struct segtree {
#define ls (rt << 1)
#define rs (rt << 1 | 1)
	node I, B, sum[N << 2];
	segtree() {
		I[0][0] = inf, I[0][1] = -inf, I[1][0] = -inf, I[1][1] = inf;
		B[0][0] = -inf, B[0][1] = inf, B[1][0] = -inf, B[1][1] = -inf;
	}
	void pushup(int rt) {sum[rt] = sum[ls] * sum[rs];}
	void build(int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt] = B, void();
		int mid = (l + r) >> 1;
		build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
	}
	void update(int x, long long c, int typ, int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt][typ][0] = c, void();
		int mid = (l + r) >> 1;
		if (x <= mid) update(x, c, typ, l, mid, ls);
		else update(x, c, typ, mid + 1, r, rs);
		pushup(rt);
	}
} sgt;

vector<tuple<int, int, int>> vec;
void _main() {
	//debug(sizeof(f) / 1048576.0);
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	vec.clear();
	for (int i = 1; i <= n; i++) {
		vec.emplace_back(a[i], i, 0);
		if (i > 1) vec.emplace_back(a[i - 1] + a[i], i, 1);
	}
	sort(vec.begin(), vec.end());
	sgt.build();
	long long res = inf;
	for (const auto& info : vec) {
		long long v = get<0>(info), x = get<1>(info), typ = get<2>(info);
		sgt.update(x, v, typ);
		node A; A[0][0] = A[0][1] = inf, A[1][0] = A[1][1] = -inf, A *= sgt.sum[1];
		//mdebug(v, A[0][0]);
		res = min(res, v - A[0][0]);
	} cout << res << '\n';
}
```

### *P6772 [NOI2020] 美食家

看到这种很复杂的约束，考虑拆点 / 拆边。注意到 $w_i \in [1,5]$，直接将边权拆开，花费 $w_i$ 天转化为经过 $w_i$ 个点。

考虑图上 DP，设 $dp_{i,u}$ 表示经过 $i$ 个点，当前位于点 $u$ 的最大愉悦值。不考虑美食节可得转移

$dp_{i+1,v}=\max_{(u,v)} (dp_{i,u}+c_v)$对于美食节，初始化时将 $dp_{t_i,x_i}$ 加上 $y_i$ 即可。进行 $T$ 轮转移，复杂度 $O(Tnw)$。

考虑 $(\max,+)$ 广义矩阵乘法。对于边 $(u,v)$，转移矩阵 $A$ 满足 $A_{u,v}=c_v$，再设初始值为向量 $a$，则 $k$ 轮转移就是 $A^k a$。其中 $a_1=c_1$。

直接矩阵快速幂不可行，可以预处理 $A^{2^k}$，多次转移直接倍增处理。复杂度 $O(n^3w^3k \log T)$，无法通过。

注意到倍增可以 $O(n^3w^3 \log T)$ 完成，瓶颈在转移，使用 $O(n^2w^2)$ 的矩阵乘向量即可。总复杂度 $O(n^3w^3 \log T+n^2w^2k\log T)$。

不会写代码，抄的深进。

```cpp
const int N = 255;
long long A[31][N][N], dp[2][N];
int n, m, t, k, u, v, w, val[N];
int f(int x, int y) {return x * n + y - 1;}
struct node {
	int t, x, y;
} a[N];

void _main() {
	cin >> n >> m >> t >> k;
	for (int i = 1; i <= n; i++) cin >> val[i];
	memset(A, 0xcf, sizeof(A));
	for (int i = 0; i < 4; i++) {
		for (int j = 1; j <= n; j++) A[0][f(i, j)][f(i + 1, j)] = 0;
	}
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w;
		A[0][f(4, v)][f(5 - w, u)] = val[v];
	}
	for (int s = 0; s < 30; s++) {
		for (int i = 0; i < n * 5; i++) {
			for (int k = 0; k < n * 5; k++) {
				for (int j = 0; j < n * 5; j++) {
					A[s + 1][i][k] = max(A[s + 1][i][k], A[s][i][j] + A[s][j][k]);
				}
			}
		}
	}
	memset(dp, 0xcf, sizeof(dp));
	int st = 0;
	dp[0][f(4, 1)] = val[1];
	auto trans = [&](int s) -> void {
		for (int d = 0; d < 30; d++) {
			if (!(s >> d & 1)) continue;
			st ^= 1;
			memset(dp[st], 0xcf, sizeof(dp[st]));
			for (int i = 0; i < 5 * n; i++) {
				for (int j = 0; j < 5 * n; j++) {
					dp[st][i] = max(dp[st][i], dp[st ^ 1][j] + A[d][i][j]);
				}
			}
		}
	};
	for (int i = 1; i <= k; i++) cin >> a[i].t >> a[i].x >> a[i].y;
	sort(a + 1, a + k + 1, [](const node& a, const node& b) -> bool {
		return a.t < b.t;
	});
	for (int i = 1; i <= k; i++) {
		trans(a[i].t - a[i - 1].t);
		dp[st][f(4, a[i].x)] += a[i].y;
	}
	trans(t - a[k].t);
	cout << (dp[st][f(4, 1)] < 0 ? -1 : dp[st][f(4, 1)]);
}
```

### P7453 [THUSC 2017] 大魔法师

矩阵应用之三：维护结合律信息，与数据结构结合。

题目所给的是一堆区间操作和全局查询，自然想到线段树。但是这题的修改太过复杂，普通的线段树懒标记难以维护。考虑在线段树上每个节点维护一个向量，修改用矩阵表示，这样懒标记用矩阵记录就好了。

我们需要一个四维向量 $\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}$ 来表示信息。这里有一个常数 $1$ 的原因是，修改 4&5 涉及对常数 $v$ 的操作。如果你只设计三维，会发现怎么也推不出来。

现在分别考虑修改即可。前三种修改是类似的，使用待定系数法得到

$$
\begin{bmatrix}
1 & 1 & 0 & 0\\
0 & 1 & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i+B_i\\ B_i\\ C_i\\ 1\end{bmatrix}
$$

后面两种就不给了。

第四种和第五种在单位矩阵的基础上微调即可：

$$
\begin{bmatrix}
1 & 0 & 0 & v\\
0 & 1 & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i+v\\ B_i\\ C_i\\ 1\end{bmatrix}
$$

$$
\begin{bmatrix}
1 & 0 & 0 & 0\\
0 & v & 0 & 0\\
0 & 0 & 1 & 0\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i\\ vB_i\\ C_i\\ 1\end{bmatrix}
$$

单点覆盖仍然微调单位矩阵，通过对角线上的 $0$ 先归零再加回去：

$$
\begin{bmatrix}
1 & 0 & 0 & 0\\
0 & 1 & 0 & 0\\
0 & 0 & 0 & v\\
0 & 0 & 0 & 1
\end{bmatrix}\begin{bmatrix}A_i\\ B_i\\ C_i\\ 1\end{bmatrix}=\begin{bmatrix}A_i\\ B_i\\ v\\ 1\end{bmatrix}
$$

至此我们可以在 $O(n \log n)$ 的时间内解决这个问题。但是矩阵的常数有 $4^3=64$ 倍，需要比较精细的实现。

```cpp
const int N = 2.5e5 + 5;
using node = matrix<mint, 4>;

int n, q, opt, l, r, v;
node A[10], a[N];

#define ls (rt << 1)
#define rs (rt << 1 | 1)
node sum[N << 2], tag[N << 2];
void pushup(int rt) {sum[rt] = sum[ls] + sum[rs];}
void pushdown(int rt) {
	sum[ls] *= tag[rt], sum[rs] *= tag[rt];
	tag[ls] *= tag[rt], tag[rs] *= tag[rt];
	tag[rt].reset();
}
void build(int l = 1, int r = n, int rt = 1) {
	tag[rt].reset();
	if (l == r) return sum[rt] = a[l], void();
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}
void change(int tl, int tr, const node& c, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return sum[rt] *= c, tag[rt] *= c, void();
	pushdown(rt);
	int mid = (l + r) >> 1;
	if (tl <= mid) change(tl, tr, c, l, mid, ls);
	if (tr > mid) change(tl, tr, c, mid + 1, r, rs);
	pushup(rt);
}
node query(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return sum[rt];
	int mid = (l + r) >> 1; node res;
	pushdown(rt);
	if (tl <= mid) res += query(tl, tr, l, mid, ls);
	if (tr > mid) res += query(tl, tr, mid + 1, r, rs);
	return res;
}

void _main() {
	read(n);
	for (int i = 1; i <= n; i++) {
		read(a[i].val[0][0].val, a[i].val[0][1].val, a[i].val[0][2].val);
		a[i].val[0][3] = 1;
	}
	build();
	for_each(A, A + 10, [](node& x) {x.reset();});
	A[1].val[1][0] = A[2].val[2][1] = A[3].val[0][2] = 1, A[6].val[2][2] = 0;
	for (read(q); q--; ) {
		read(opt, l, r);
		if (opt <= 3) {
			change(l, r, A[opt]);
		} else if (opt <= 6) {
			read(v);
			A[4].val[3][0] = A[5].val[1][1] = A[6].val[3][2] = v;
			change(l, r, A[opt]);
		} else {
			node res = query(l, r);
			writesp(res.val[0][0].val), writesp(res.val[0][1].val), writeln(res.val[0][2].val);
		}
	} flush();
}
```

### *P4719 【模板】动态 DP

矩阵应用之四：维护带修改的 DP，即动态 DP。

前置知识：重链剖分。

其实并不板。考虑不带修的做法，经典 DP。设 $f_{0/1,u}$ 表示选 / 不选 $u$ 点的最大独立集。则

$$
f_{0,u}=\sum_{(v,u)} \max(f_{0,v},f_{1,v})\\
f_{1,u}=a_u+\sum_{(v,u)} f_{0,v}
$$

答案为 $\max(f_{0,1},f_{1,1})$。

观察转移方程，每次更改点权只需修改一条树链。但如果随意找，每次更新的复杂度会达到 $O(n)$。

对树作一次重链剖分。这样每个点到根的路径上只会经过 $O(\log n)$ 条重链。为了适应重儿子的性质，定义 $g_{0/1,u}$ 表示 $u$ 点的所有轻儿子无限制 / 不能取且取自己的最大独立集。于是

$$
f_{0,u}=g_{0,u}+\max(f_{0,son_u},f_{1,son_u})\\
f_{1,u}=g_{1,u}+f_{0,son_u}
$$

其中 $son_u$ 代表轻儿子。这样我们就去掉了求和。

变形：

$$
f_{0,u}=\max(f_{0,son_u}+g_{0,u},f_{1,son_u}+g_{0,u})\\
f_{1,u}=\max(g_{1,u}+f_{0,son_u},-\infty)
$$

定义 $(\max,+)$ 的广义矩阵乘法。待定系数一下得到

$$
\begin{bmatrix}
g_{0,u} & g_{0,u} & \\
g_{1,u} & -\infty & \\
\end{bmatrix}\begin{bmatrix}f_{0,v}\\ f_{1,v}\end{bmatrix}=\begin{bmatrix}dp_{0,u}\\ dp_{1,u}\end{bmatrix}
$$

此时的矩阵应该写在左边。因为重剖过程是先链头后链尾。于是我们在 DFS 序上建一棵线段树，问题解决。复杂度 $O(n \log^2 n)$，$4$ 倍常数。

```cpp
const int N = 1e5 + 5, inf = 1e9;
using node = matrix<int, 2, MaxOP<int>, AddOP<int>, -inf>;
int n, q, a[N], u, v;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int num, sz[N], fa[N], son[N], top[N], dfn[N], ed[N], id[N], f[2][N], g[2][N];
void dfs1(int u) {
	sz[u] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		fa[v] = u, dfs1(v), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int t) {
	top[u] = t, dfn[u] = ++num, id[num] = u;
	if (!son[u]) return ed[t] = num, void();
	dfs2(son[u], t);
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa[u] && v != son[u]) dfs2(v, v);
	}
}
void dfs3(int u) {
	f[1][u] = g[1][u] = a[u];
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		dfs3(v);
		f[0][u] += max(f[0][v], f[1][v]), f[1][u] += f[0][v];
		if (v != son[u]) g[0][u] += max(f[0][v], f[1][v]), g[1][u] += f[0][v];
 	}
}

node B[N];
struct segtree {
#define ls (rt << 1)
#define rs (rt << 1 | 1)
	node sum[N << 2];
	void pushup(int rt) {sum[rt] = sum[ls] * sum[rs];}
	void build(int l = 1, int r = n, int rt = 1) {
		if (l == r) {
			sum[rt][0][0] = sum[rt][0][1] = g[0][id[l]];
			sum[rt][1][0] = g[1][id[l]], sum[rt][1][1] = -inf;
			B[l] = sum[rt];
			return;
		}
		int mid = (l + r) >> 1;
		build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
	}
	void change(int x, int l = 1, int r = n, int rt = 1) {
		if (l == r) return sum[rt] = B[l], void();
		int mid = (l + r) >> 1;
		if (x <= mid) change(x, l, mid, ls);
		else change(x, mid + 1, r, rs);
		pushup(rt);
	}
	node query(int tl, int tr, int l = 1, int r = n, int rt = 1) {
		if (tl <= l && r <= tr) return sum[rt];
		int mid = (l + r) >> 1;
		if (tr <= mid) return query(tl, tr, l, mid, ls);
		if (tl > mid) return query(tl, tr, mid + 1, r, rs);
		return query(tl, tr, l, mid, ls) * query(tl, tr, mid + 1, r, rs);
	}
} sgt;

node ask(int x) {return sgt.query(dfn[x], ed[top[x]]);}
void change(int u, int c) {
	B[dfn[u]][1][0] += c - a[u], a[u] = c;
	for (; u; u = fa[top[u]]) {
		node last = ask(top[u]);
		sgt.change(dfn[u]);
		node cur = ask(top[u]);
		int p = dfn[fa[top[u]]];
		B[p][0][0] += max(cur[0][0], cur[1][0]) - max(last[0][0], last[1][0]);
		B[p][0][1] += max(cur[0][0], cur[1][0]) - max(last[0][0], last[1][0]);
		B[p][1][0] += cur[0][0] - last[0][0];
	}
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	dfs1(1), dfs2(1, 1), dfs3(1), sgt.build();
	while (q--) {
		cin >> u >> v;
		change(u, v);
		node res = ask(1);
		cout << max(res[0][0], res[1][0]) << '\n';
	}
}
```

### *P5024 [NOIP 2018 提高组] 保卫王国

注意到，最小覆盖集 = 全集 - 最大独立集。

于是和模板题的区别在于不是修改点权，而是强制两个点是否属于最大独立集，同时操作独立。

把点权改成正 / 负无穷即可实现强制属于独立集。于是套用模板题的做法就行了。

### *P8820 [CSP-S 2022] 数据传输

困难的。从部分分开始思考。

- $k=1$ 是简单的，答案就是路径上的点权之和。求个 LCA 即可 $O(n \log n)$。
- $k=2$ 时，手玩可以发现跳到儿子再跳回来一定不优。于是最优方案只经过路径上的点。

将这条链拿出来 DP。设 $dp_{i}$ 表示跳到第 $i$ 个点的最小代价，则 $dp_{i}=\min(dp_{i-1},dp_{i-2})+a_i$。复杂度 $O(qn \log n)$。

考虑树上动态 DP。定义 $(\min,+)$ 广义矩阵乘法：

$\forall C=AB,C_{i,j}=\min_{k} (A_{i,k}+B_{k,j})$待定系数容易得到

$$
\begin{bmatrix}
a_i & a_i & \infty \\
0 & \infty & \infty \\
\infty & \infty & 0
\end{bmatrix}\begin{bmatrix}dp_{i-1}\\ dp_{i-2}\\0\end{bmatrix}=\begin{bmatrix}dp_{i}\\ dp_{i-1}\\0\end{bmatrix}
$$

这里为了与 $k=3$ 统一，用的是三维矩阵。实际上两维就够了。

- $k=3$ 时，最优方案可能由一个一个儿子跳到另一个儿子。注意到，最优方案上只有一条路径和一些儿子。

仍然将链拿出来，形成一个毛毛虫结构。将 LCA 的父亲也视为儿子。

设 $dp_{0/1/2,i}$ 表示跳到离点 $i$ 距离为 $0/1/2$ 的最小代价。记 $s_i$ 表示 $i$ 的最小代价儿子。可得转移

$$
\begin{aligned}
dp_{0,i}&=\min(dp_{0,i-1}+dp_{1,i-1},dp_{2,i-1})+a_i\\
dp_{1,i}&=\min(dp_{0,i}+s_i,dp_{0,i-1}+s_i,dp_{1, i-1}+s_i,dp_{0,i-1})\\
dp_{2,i}&=dp_{1,i-1}
\end{aligned}
$$

考虑动态 DP。我们需要把 $dp_{1,i}$ 的转移变成下标只有 $i-1$ 的式子。代入 $dp_{0,i}$ 的转移方程得到

$dp_{1,i}=\min(dp_{0,i-1},dp_{1,i-1}+s_i,dp_{2,i-1}+a_i+s_i)$耐心地推出转移矩阵：

$$
\begin{bmatrix}
a_i & a_i & a_i \\
0 & s_i & a_i+s_i \\
\infty & 0 & \infty
\end{bmatrix}\begin{bmatrix}dp_{0,i-1}\\ dp_{1,i-1}\\dp_{2,i-1}\end{bmatrix}=\begin{bmatrix}dp_{0,i}\\ dp_{1,i}\\dp_{2,i}\end{bmatrix}
$$

用树上倍增维护一条链的正序积和倒序积，可以做到 $O(nk^3 \log n)$，细节很多。

> 为什么不用树剖维护？
>
> 树剖直接维护只能做正序积，无法维护倒序积，需要重推一遍转移矩阵。但是树上倍增的过程中直接交换递推顺序是对的。

```cpp
const int N = 2e5 + 5;
const long long inf = 1e15;
using node = matrix<long long, 3, MinOP<long long>, AddOP<long long>, inf>;

int n, q, k, u, v;
long long a[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}

int dep[N], sz[N], fa[N], son[N], top[N];
long long s[N], dis[N];
void dfs1(int u) {
	sz[u] = 1, dis[u] = dis[fa[u]] + a[u], dep[u] = dep[fa[u]] + 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		fa[v] = u, dfs1(v), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int t) {
	top[u] = t;
	if (son[u]) dfs2(son[u], t);
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa[u] && v != son[u]) dfs2(v, v);
	}
}
int lca(int u, int v) {
	while (top[u] != top[v]) {
		if (dep[top[u]] < dep[top[v]]) swap(u, v);
		u = fa[top[u]];
	} return dep[u] < dep[v] ? u : v;
}
int pa[20][N];
node I, B[N], mul[20][N], rmul[20][N];
void dfs3(int u) {
	pa[0][u] = fa[u], mul[0][u] = rmul[0][u] = B[u];
	for (int i = 1; i < 20; i++) {
		pa[i][u] = pa[i - 1][pa[i - 1][u]];
		mul[i][u] = mul[i - 1][u] * mul[i - 1][pa[i - 1][u]];
		rmul[i][u] = rmul[i - 1][pa[i - 1][u]] * rmul[i - 1][u];
	}
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa[u]) continue;
		dfs3(v);
	}
}
node ask(int u, int v) {
	node x = I, y = I;
	if (dep[u] < dep[v]) y = B[v], v = fa[v];
	for (int i = 19; i >= 0; i--) {
		if (dep[pa[i][u]] >= dep[v]) x = rmul[i][u] * x, u = pa[i][u];
	}
	if (u == v) return y * B[u] * x;
	for (int i = 19; i >= 0; i--) {
		if (pa[i][u] == pa[i][v]) continue;
		x = rmul[i][u] * x, y = y * mul[i][v];
		u = pa[i][u], v = pa[i][v];
	} return y * B[v] * B[fa[v]] * B[u] * x;
}

void _main() {
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			if (i != j) I[i][j] = inf;
		}
	}
	cin >> n >> q >> k;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fill(s + 1, s + n + 1, inf);
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
		s[u] = min(s[u], a[v]), s[v] = min(s[v], a[u]);
	}
	dfs1(1), dfs2(1, -1);
	if (k == 1) {
		while (q--) {
			cin >> u >> v;
			int f = lca(u, v);
			cout << dis[u] + dis[v] - 2 * dis[f] + a[f] << '\n';
		} return;
	}
	B[0] = I;
	for (int i = 1; i <= n; i++) {
		node& A = B[i];
		if (k == 2) {
			A[0][0] = A[0][1] = a[i];
			A[1][0] = A[2][2] = 0;
			A[0][2] = A[1][1] = A[1][2] = A[2][0] = A[2][1] = inf;
		} else {
			A[0][0] = A[0][1] = A[0][2] = a[i];
			A[1][0] = A[2][1] = 0;
			A[1][1] = s[i], A[1][2] = a[i] + s[i];
			A[2][0] = A[2][2] = inf;
		}
	}
	dfs3(1);
	while (q--) {
		cin >> u >> v;
		if (u == v) {cout << a[u] << '\n'; continue;}
	 	if (dep[u] < dep[v]) swap(u, v);
		node x = ask(fa[u], v), y = I;
		if (k == 2) y[0][0] = a[u];
		else y[0][0] = a[u], y[0][1] = a[u] + s[u];
		x *= y, cout << x[0][0] << '\n';
	}
}
```
