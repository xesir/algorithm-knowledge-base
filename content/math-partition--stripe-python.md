---
id: math-partition
title: '分拆数（整数拆分）'
category: '数学'
subcategory: '组合数学'
tags: ['分拆数', '整数拆分', '五边形数定理']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 16. 分拆数

这部分内容参考了本人学长的 [Blog](https://www.luogu.me/article/ed1zhztr)。

- **分拆**：将自然数 $n$ 写为递降正整数和的表示。如 $8=5+2+1$。形式化地，记 $n=r_1+r_2+r_3+\cdots+r_k$，其中 $r_1 \ge r_2 \ge r_3 \ge \cdots r_k \ge 1$，且 $r_1,r_2,r_3,\cdots,r_k$ **无序**。
- **分拆数** $p_n$：自然数 $n$ 的分拆方法数。[A000041](https://oeis.org/A000041)。

仔细思考一下可以发现，$p_n$ 就是背包容量为 $n$，物品体积为 $1,2,3,\cdots,n$ 的完全背包的方案数。因此可以 $O(n^2)$ 地递推求出 $p_n$：

```cpp
p[0] = 1;
for (int i = 1; i <= n; i++) {
    for (int j = i; j <= n; j++) p[j] += p[j - i];
}
```

## 16.1 分拆数变形

如果我们对分拆 $n=r_1+r_2+r_3+\cdots+r_k$ 有一些限制，就会得到分拆数的各种变形。

### 16.1.1 kkk 部分拆数

- **$k$ 部分拆数** $p(n,k)$：将 $n$ 分成恰有 $k$ 个部分的分拆方法数。

用 DP 的思想来推导 $p(n,k)$ 的递推式。

1. 若最后一个数为 $1$，则剩下数的和为 $n-1$，分为 $k-1$ 部，答案为 $p(n-1,k-1)$。
2. 若最后一个数不为 $1$，因为这些数中一定不含有 $1$，于是令 $r'_i =r_i-1$，即 $n-k=(r_1-1)+(r_2-1)+(r_3-1)+\cdots+(r_k-1)$，即为 $n-k$ 分为 $k$ 部，答案为 $p(n-k,k)$。

由加法原理得：

$p(n,k)=p(n-1,k-1)+p(n-k,k)$边界是 $p(0,0)=1$。我们可以在 $O(n^2)$ 时间内计算 $p(n,k)$。显然

$p_n=\sum_{k=1}^{n} p(n,k)$这样我们又多了一种 $O(n^2)$ 算 $p_n$ 的方法。

### 16.1.2 互异分拆数

- **互异分拆**：将自然数 $n$ 写为**严格**递降正整数和的表示。形式化地，记 $n=r_1+r_2+r_3+\cdots+r_k$，其中 $r_1 > r_2 > r_3 > \cdots r_k > 1$，且 $r_1,r_2,r_3,\cdots,r_k$ **无序**。
- **互异分拆数** $pd_n$：自然数 $n$ 的互异分拆方法数。[A000009](https://oeis.org/A000009)。
- **$k$ 部互异分拆数** $pd(n,k)$：将 $n$ 分成恰有 $k$ 个部分的互异分拆方法数。

我们直接给出递推式：

$pd(n,k)=pd(n-k,k-1)+pd(n-k,k)$推导方法类似。有结论：当 $k > \sqrt{2n}$ 时，$pd(n,k)=0$。

证明：贪心地，设 $n=\sum_{i=1}^k i=\dfrac{k(k+1)}{2}$，上式大于 $\dfrac{k^2}{2}$，故 $k < \sqrt{2n}$。

于是可以在 $O(n\sqrt{n})$ 时间内求出 $pd(n,k)$。边界还是 $pd(0,0)=1$。

同理有

$pd_n=\sum_{k=1}^{n} pd(n,k)$所以 $pd_n$ 也可以 $O(n\sqrt{n})$ 算出。本质上，$p_n$ 是完全背包方案数，$pd_n$ 则是 01 背包方案数。

### *16.1.3 最大 kkk 分拆数

- **最大 $k$ 分拆数** $p^{\max}(n,k)$：$n$ 的最大部分为 $k$ 的分拆方法数。
- **最大 $k$ 互异分拆数** $pd^{\max}(n,k)$：$n$ 的最大部分为 $k$ 的互异分拆方法数。

有结论：

$$
p^{\max}(n,k)=p(n,k)\\
pd^{\max}(n,k)=pd(n,k)\\
$$

要证明这个东西且不用到生成函数知识，我们需要引入杨表。在很多介绍分拆数的文章中也称其为 Ferrers 图。

杨表的画法是，将分拆 $n=r_1+r_2+r_3+\cdots+r_k$ 的每个部分用点表示，第 $i$ 行有 $r_i$ 个点。例如 $12=5+4+2+1$ 的杨表如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/j6fuh0ae.png)

将这个杨表顺时针旋转 $90 \degree$，得到的新表称作原表的共轭。如 $12=5+4+2+1$ 的共轭为 $12=4+3+2+2+1$。

![](https://cdn.luogu.com.cn/upload/image_hosting/7leu1zns.png)

记原来的分拆为 $\lambda$，其共轭为 $\lambda^*$。容易发现，$\forall \lambda_1 \ne \lambda_2 ,\lambda_1^* \ne \lambda_2^*$。这说明：共轭是一一对应的。

现在我们证明 $p^{\max}(n,k)=p(n,k)$。

考虑 $p^{\max}(n,k)$ 的一个分拆 $\lambda$ 的杨表，根据定义这个杨表有恰好 $k$ 列。其共轭分拆有 $k$ 行，在 $p(n,k)$ 中恰好被统计一次。因为共轭一一对应，所以 $p^{\max}(n,k)=p(n,k)$。$pd^{\max}(n,k)=pd(n,k)$ 同理。

### *16.1.4 奇分拆数

- **奇分拆数 $po_n$**：$n$ 的各部分分拆均为奇数的方法数。[A000009](https://oeis.org/A000009)。

定理：

$po_n=pd_n$非常神奇的一个式子。证明它需要建立起一一对应关系。

对于一个互异分拆，考虑构造一个奇分拆。重复如下操作直到 $\forall i,2 \nmid r_i$：

对于所有的 $2 \mid r_i$，设 $r_i=2a$，将两个 $a$ 加入到奇分拆中。

比如说对于互异分拆 $14=5+4+3+2$，第一次操作变为 $14=5+3+2+2+1+1$，第二次操作变为 $14=5+3+1+1+1+1+1+1$。

因为一个互异分拆在操作一次之后就不互异了，那么就不存在两个不同的互异分拆映射到相同的奇分拆的情况，证毕。

## 16.2 五边形数定理

![](https://cdn.luogu.com.cn/upload/image_hosting/x5tfyila.png)

- 五边形数 $P_5(n)$：能排成五边形的点数。易得 $P_5(n)=\dfrac{n(3n-1)}{2}$。[A000326](https://oeis.org/A000326)。可以发现 $P_5(n)$ 是 $O(n^2)$ 级别的。
- 广义五边形数：当 $n<0$ 时仍然套用上面的公式。[A001318](https://oeis.org/A001318)。

不加证明地给出定理：

$$
\begin{aligned}
p_n&=\sum_{i>0, n \ge P_5(-i)} (-1)^{i+1} (p_{n-P_5(i)}+p_{n-P_5(-i)})\\
&=p_{n-1}+p_{n-2}-p_{n-5}-p_{n-7}+p_{n-12}+p_{n-15}-\cdots
\end{aligned}
$$

由于 $P_5(n)$ 为 $O(n^2)$ 级别，使得 $n \ge P_5(-i)$ 的 $i$ 只有 $O(\sqrt{n})$ 个。于是可以在 $O(n\sqrt{n})$ 时间内计算分拆数。

## *16.3 范围估计

分拆数 $p_n$ 并不像错排 $D_n$ 那样有明确的估计。目前较好的逼近为

$p_n \sim \dfrac{\exp(\pi \sqrt{\dfrac{2n}{3}})}{4\sqrt{3}n} , n \gets \infty$因此 $O(p_n)$ 在小数据下是一个较优秀的复杂度。例题 [P4128 [SHOI2006] 有色图](https://www.luogu.com.cn/problem/P4128)，但需要用到笔者不会的群论知识，所以没放到例题里。

## 16.4 例题

### SP2007 COUNT - Another Very Easy Problem! WOW!!!

$k$ 部分拆数的板子题。套用递推式即可。

```cpp
int n, k;
mint p[N][N];

void _main() {
	for (int i = 1; i < N; i++) p[i][1] = p[i][i] = 1;
	for (int i = 1; i < N; i++) {
		for (int j = 2; j <= i; j++) p[i][j] = p[i - 1][j - 1] + p[max(i - j, 0)][j];
	}
	while (cin >> n >> k, n || k) cout << p[n][k] << '\n';
}
```

### P6189 [NOI Online #1 入门组] 跑步

分拆数的板子。我们先给出五边形数定理求解的代码：

```cpp
const int N = 1e5 + 5;
long long n, m, a[N << 1], p[N];

void _main() {
	cin >> n >> m;
	p[0] = 1, p[1] = 1, p[2] = 2;
	for (int i = 1; i < N; i++) {
		a[i << 1] = i * (i * 3 - 1) / 2;
		a[i << 1 | 1] = i * (i * 3 + 1) / 2;
	}
	for (int i = 3; i < N; i++) {
		p[i] = 0;
		for (int j = 2; a[j] <= i; j++) {
			if (j & 2) (p[i] += p[i - a[j]]) %= m;
			else p[i] -= p[i - a[j]], p[i] = (p[i] % m + m) % m;
		}
	} cout << p[n];
}
```

求分拆数还有一种有意思的做法是根号分治优化 DP。考虑我们之前给出的两种 $O(n^2)$ 求解方法：

1. 完全背包。设 $dp_{i,j}$ 表示将 $i$ 分拆为若干个不超过 $j$ 的数的方案数，有 $p_n=dp_{n,n}$，转移式为

$dp_{i,j}=dp_{i,j-1}+dp_{i-j,j}$1. 基于 $k$ 部分拆数。即 $p_n=\sum_{k=1}^{n} p(i,k)$，其中

$p(i,k)=p(i-1,k-1)+p(i-k,k)$选择一个阈值 $m$。对于 $\le m$ 的情况使用第一种方法，对于 $>m$ 的情况我们采用第二种方法。具体地，先用 $dp_{i,j}$ 求出 $j \le m$ 的方法数，在递推 $p(i,k)$ 时以 $m$ 为步长递推。复杂度 $O(mn+\dfrac{n^2}{m})$。由基本不等式得 $m=\sqrt{n}$ 最优，复杂度 $O(n\sqrt{n})$。

最后合并答案时，枚举第一个部分的总和 $j$，剩下的总和为 $n-j$，由乘法原理合并。即

$p_n=\sum_{j=0}^{n} (f_{m-1,j} \times \sum_{k=0}^{m} p(n-j,k))$复杂度也控制在 $O(n\sqrt{n})$ 以内。注意代码实现时 $p(i,k)$ 交换了两维优化常数。

```cpp
const int N = 1e5 + 5, M = 405;
int n, m, dp[N], p[M][N];

void _main() {
	cin >> n >> m;
	int b = sqrt(n) + 1;
	dp[0] = 1, p[0][0] = 1;
	for (int i = 1; i < b; i++) {
		for (int j = i; j <= n; j++) (dp[j] += dp[j - i]) %= m;
	}
	for (int i = 1; i < b; i++) {
		for (int j = i; j <= n; j++) {
			p[i][j] = p[i][j - i];
			if (j >= b) (p[i][j] += p[i - 1][j - b]) %= m;
		}
	}
	int res = 0;
	for (int j = 0; j <= n; j++) {
		int cur = 0;
		for (int k = 0; k < b; k++) (cur += p[k][n - j]) %= m;
		(res += 1LL * dp[j] * cur % m) %= m;
	} cout << res;
}
```

实际上，计算分拆数有一个亚线性复杂度的做法，即使用 Hardy-Ramanujan-Rademacher 公式。由于这个东西太过于复杂，这里只给出一个[博客链接](https://travorlzh.github.io/2023/07/16/integer-partitions.html)。

### *AT_abc221_h [ABC221H] Count Multiset

这是一个有限制条件的 $k$ 部分拆数问题。我们考虑容斥掉不合法的方案。

考虑高维容斥，我们只容斥掉恰有 $m+1$ 个 $1$ 的分拆，修改一下 $k$ 部分拆数的递推式：

$p(n,k)=p(n-1,k-1)+p(n-k,k)-p(n-k,k-m-1)$仿照 $p(n-k,k)$ 的计数意义，将所有部分减去 $1$ 以后结尾的所有 $1$ 会被删掉，所以剩余部分为 $k-(m+1)$ 个。复杂度 $O(n^2)$。

```cpp
const int N = 5005;
int n, m;
mint p[N][N];

void _main() {
	cin >> n >> m;
	p[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= i; j++) {
			p[i][j] = p[i - 1][j - 1] + p[i - j][j];
			if (j >= m + 1) p[i][j] -= p[i - j][j - m - 1];
		}
	}
	for (int i = 1; i <= n; i++) cout << p[n][i] << '\n';
}
```

### *P5824 十二重计数法

**注意：本文只给出每小问的答案，并不讲解多项式科技优化 $k$ 部分拆数计算的方法。**

$\text{V}$ 和 $\text{XI}$：盒子相同，每个盒子最多一个球：纯诈骗。若 $n >m$ 答案为 $a_5=a_{11}=0$，否则合法方案没区别，$a_5=a_{11}=1$。复杂度 $O(1)$。

$\text{I}$：球不同，盒子不同：基础乘法原理，答案为 $a_1=m^n$。复杂度 $O(\log n)$。

$\text{II}$ 和 $\text{VIII}$：盒子不同，每个盒子最多一个球：按顺序列出每个球所属盒子的编号。如果球不同编号是有序的，否则无序。所以 $a_2=A_n^m,a_8=C^m_n$。复杂度 $O(n)$。

$\text{VII}$ 和 $\text{IX}$：球相同，盒子不同。对于 $\text{IX}$，盒子非空，见插板法例题 1，答案为 $a_9=C^{m-1}_{n-1}$；对于 $\text{VII}$，盒子可空，插板法例题 2，答案是 $a_7=C^{m-1}_{n+m-1}$。复杂度 $O(n)$。

$\text{VI}$：球不同，盒子相同，盒子非空：第二类 Stirling 数。答案为 $a_6=S(n,m)$。用通项公式做到 $O(n)$。

$\text{III}$：球不同，盒子不同，盒子非空：因为盒子不同，需要全排列一波，答案为 $a_3=m! \times S(n,m)$。同样用通项公式做到 $O(n)$。

$\text{X}$ 和 $\text{XII}$：球相同，盒子相同：$k$ 部分拆数板子，答案是 $a_{10}=p(n,m)$。要求盒子非空，给所有盒子先放一个即可，$a_{12}=p(n-m,m)$。复杂度 $O(n^2)$，可以用多项式科技做到 $O(n \log n)$。

$\text{IV}$：球不同，盒子相同：类似 Bell 数，枚举有 $i$ 个空盒，答案为

$a_4=\sum_{i=0}^{m} S(n,m)$复杂度 $O(n^2)$，同样也可以多项式科技做到 $O(n \log n)$，还可以用单个 Bell 数的做法推式子做到 $O(n)$。
