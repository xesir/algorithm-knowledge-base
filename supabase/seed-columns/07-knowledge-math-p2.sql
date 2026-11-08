-- ============================================================
-- AKB 专栏种子：知识点 / 数学
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：15 行
-- ============================================================
begin;

drop table if exists _akb_seed_columns;
create temp table _akb_seed_columns (
    author_name text not null,
    column_key text not null,
    column_name text not null,
    content text not null,
    category text,
    tags text[],
    parent_key text,
    difficulty text,
    kind text not null
) on commit drop;

insert into _akb_seed_columns (
    author_name, column_key, column_name, content, category, tags, parent_key, difficulty, kind
) values
('stripe-python', 'col-math-partition--stripe-python', '分拆数（整数拆分） · stripe-python', $AKB326$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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

$a_4=\sum_{i=0}^{m} S(n,m)$复杂度 $O(n^2)$，同样也可以多项式科技做到 $O(n \log n)$，还可以用单个 Bell 数的做法推式子做到 $O(n)$。$AKB326$, '数学', array['分拆数', '整数拆分', '五边形数定理'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-prime-factor-state-compression--stripe-python', '质因子状态压缩 trick · stripe-python', $AKB327$> 本文由 stripe-python 授权合并，保留原文结构与表述。
由于本人在 9.26 模拟赛中的 T2 二十分钟瞪出了做法，然后自己否掉导致写了 2h 喜提 240pts，故对这类题目作一个总结。

## AT_abc195_f [ABC195F] Coprime Present

这题就是本人模拟赛的那个 T2。


一个思路是注意到最大答案在 $2 \times 10^8$ 左右，可以进行 $O(ans)$ 的搜索，但需要 `__int128` 状压和神秘减枝，赛时想了 1.5h 无果。

回归题目发现 $r-l \le 72$ 这个神秘限制。显然 $a,b$ 能同时选当且仅当质因子交集为空。记 $S_a$ 表示 $a$ 的质因子集合。

若 $a, b$ 满足 $S_a \cap S_b=A$，且 $\forall i \in S, i>72$，则 $|a-b|>72$，必然不满足这一限制。所以 $S_a$ 中只有 $\le 72$ 的数是有用的。

通过打表发现，$[2,72]$ 中的质数只有 $20$ 个，故 $S_a$ 可以状态压缩存下。进一步考虑一个状压 DP，用 $f_{S}$ 表示质因子集合为 $S$ 时的选法，考虑加入 $a$ 对 $f_{S}$ 的影响。

记 $T=S_a$，则对于每个 $S$，当且仅当 $S \cup T =\varnothing$ 时 $T$ 才能加入 $S$ 中。刷表法转移：$f_{S \cap T} \gets f_S$。

边界为 $f_{\varnothing}=1$。

复杂度 $O(2^w n)$，其中 $w \le 20$。



赛时 AC 代码。

```cpp
#define int long long
const int N = 21;

int l, r, f[1 << N];
const int p[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41,
	43, 47, 53, 59, 61, 67, 71};  // 20个

void _main() {
	cin >> l >> r;
	f[0] = 1;
	for (int i = l; i <= r; i++) {
		int x = 0;
		for (int j = 0; j < 20; j++) {
			if (i % p[j]) continue;
			x |= 1 << j;
		}
		for (int j = 0; j < (1 << 20); j++) {
			if ((x & j) == 0) f[x | j] += f[j];
		}
	}
	int res = 0;
	for (int i = 0; i < (1 << 20); i++) res += f[i];
	cout << res;
}
```

## P2150 [NOI2015] 寿司晚宴


两个子集中的数字两两互质，等价于子集中的质因数集合交集为空。

我们先从 30pts 开始考虑。因为 $n \le 30$，那么质因数只有 $10$ 个。设 $dp_{i,S,T}$ 表示当前考虑到第 $i$ 个数，质因子集合为 $S,T$ 的方案数。对于 $[2,n]$ 分解质因数，把质因数状压一波。枚举与 $S,T$ 无交集的 $D$，刷表法转移：

$$
dp_{i+1,S \cup D,T} \gets dp_{i,S,T}\\
dp_{i+1,S,T \cup D} \gets dp_{i,S,T}
$$

然后对于 $S \cap D=\varnothing$ 的每个 $S,T$ 统计答案。可以滚动数组优化，时间复杂度为 $O(2^{2w} n)$，其中 $w \le 10$。和上面那题没什么区别。

然后直接考虑正解。因为 $500$ 以内的质数有 $95$ 个，暴力 DP 直接爆炸。但是我们发现 $n$ 以内的数大于 $\sqrt{n}$ 的质因子最多只有一个，也就是大于 $23$ 的质因子最多一个。那么我们以 $23$ 为分界点，考虑在两侧分别 DP。也就是根号分治一波。

具体地，对于 $[2,500]$ 以内的数，我们先找出其最大质因子并按其排序，然后对每一个连续段统计答案。而 $23$ 以内的质数只有 $8$ 个，于是仍然令 $dp_{i,S,T}$ 表示考虑到第 $i$ 个数，质因子集合分别为 $S,T$ 的方案数，但是此时 $|S|,|T| \le 8$。接着考虑最大质因子的贡献，由于它只能被一个子集选走，令 $f_{i,S,T}$ 表示考虑到第 $i$ 个数，其最大质因子只能被第一个子集选走的方案数，$g_{i,S,T}$ 表示其最大质因子只能被第二个子集选走的方案数，仍然刷表转移：

$$
f_{i+1,S \cup D,t} \gets f_{i,S,T}\\
g_{i+1,S,T \cup D} \gets g_{i,S,T}
$$

把 $f,g$ 都合并到 $dp$ 里，需要容斥一下，因为会把不选的情况算两遍：

$dp_{i+1,S,T} = f_{i,S,T}+g_{i,S,T}-dp_{i,S,T}$滚动数组优化空间，注意要像 01 背包那样倒序枚举了。答案即为 $\sum_{S \cap T = \varnothing} dp_{n,S,T}$。

至此，时间复杂度优化到 $O(4^w n)$，其中 $w \le 8$。


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

## P8292 [省选联考 2022] 卡牌


注意到 $s_i \le 30$ 的部分分。样例解释告诉我们可以正难则反。记给出的质数集合为 $P$，枚举一个 $S \subseteq P$，设 $f(S)$ 表示表示选出若干卡牌的集合 $T$，满足 $\forall i \in S, i \nmid \prod T$ 的方案数。

由于 $[2,30]$ 中的质数数目为 $10$，对于 $S$ 只有 $2^{10}$ 种可能，预处理出来即可。

这样是一个容斥的过程，答案为

$\sum_{S \subseteq P} (-1)^{|S|} f(S)$复杂度 $O(2^w n+2^w \sum c)$，其中 $w \le 10$。

考虑优化。注意到 $s_i \le 2000$ 时依旧沿用上题的根号分治，将质因子分成 $\le 43$ 和 $>43$ 两部分。则 $[2,43]$ 中共有 $14$ 个质数，这部分的处理使用上面的容斥即可。$AKB327$, '数学', array['质因子', '状态压缩', '数论', 'trick'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-prime-theory--stripe-python', '质数理论基础（判定 / 筛法 / 算术基本定理） · stripe-python', $AKB328$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 2. 质数

定义一个正整数 $p$ 为**质数**，即它不存在 $1$ 和 $p$ 以外的约数。$1$ 不是质数。

## 2.1 质数分布

定义 $\pi(n)$ 表示 $[1,n]$ 中的质数数目，那么有 $\pi(n)=O(\dfrac{n}{\log n})$。

这个规律在枚举质数的题目中用处很大。它说明了质数每隔 $O(\log n)$ 个数出现一次。

## 2.2 质数的判定

### 2.2.1 枚举法

可以枚举 $[1,\sqrt{n}]$ 中的整数，判定其是否为 $p$ 的约数。因为 $a \mid p$ 时 $\dfrac{p}{a}\mid p$，所以无需枚举到 $n$。复杂度为 $O(\sqrt{n})$。

这里给出一个 $\dfrac{1}{6}$ 常数的实现，筛掉 $2$ 和 $3$ 的倍数：

```cpp
inline bool isprime(int x) {
	if (x <= 1) return false;
	if (x == 2 || x == 3) return true;
	if (x % 6 != 1 && x % 6 != 5) return false;
	for (int i = 5; i * i <= x; i += 6) {
		if (x % i == 0 || x % (i + 2) == 0) return false;
	}
	return true;
}
```

### *2.2.2 Miller-Rabin 法

先引入二次探测定理，即：若 $p$ 为奇质数，则 $x^2 \equiv 1 \pmod p$ 的解为 $x \equiv 1$ 或 $x \equiv p-1$。

> 简证：由 $x^2 \equiv 1 \pmod p$ 得 $(x-1)(x+1) \equiv 0 \pmod p$，即可得出。

接下来使用费马小定理：若 $p$ 为质数且 $\gcd(a,p)=1$，则 $a^{p-1} \equiv 1 \pmod p$。这个结论的讲解可到文章下部。

设 $p-1=u \times 2^t$，随机一个 $a$ 值并求得 $v=a^u \bmod p$，然后执行 $t$ 次 $v \gets v^2 \bmod p$，检查是否满足 $a^{p-1} \equiv 1 \pmod p$。

在 long long 范围内，只需选取 $a \in \{2,325,9375,28178,450775,9780504,1795265022\}$ 即可保证正确性。复杂度 $O(\log n)$。这里给出一个比较科技的写法。

```cpp
inline long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; b >>= 1) {
		if (b & 1) res = (__int128) res * a % p;
		a = (__int128) a * a % p;
	} return res;
}

const long long BASE[] = {2, 325, 9375, 28178, 450775, 9780504, 1795265022};
inline bool miller_rabin(long long n) {
	if (n < 2 || n % 6 % 4 != 1) return (n | 1) == 3;
	long long s = __builtin_ctzll(n - 1), d = n >> s;
	for (long long a : BASE) {
		long long p = power(a, d, n), i = s;
		while (p != 1 && p != n - 1 && a % n && i--) p = (__int128) p * p % n;
		if (p != n - 1 && i != s) return false;
	} return true;
}
```

## 2.3 威尔逊定理

若 $p$ 为质数，则

$(p-1)! \equiv -1 \pmod p$其逆定理也成立。即若 $(p-1)! \equiv -1 \pmod p$，则 $p$ 为质数。

## 2.4 算术基本定理

任何一个合数 $n$ 可以唯一分解成有限个质数的乘积。

存在性：用反证法，假设 $n$ 是最小的不能被分解的合数，则存在 $n=ab$，若 $a,b$ 都可分解，则 $n$ 可以被分解；若 $a,b$ 有不可分解的数，则 $a,b$ 才是最小的数，矛盾。

唯一性：用反证法，假设 $n$ 是最小的存在两种分解的合数，如果 $n$ 存在两种分解 $n={p_1}^{a_1} {p_2}^{a_2} \cdots ={q_1}^{b_1} {q_2}^{b_2} \cdots$，则 $p_1 | {q_1}^{b_1} {q_2}^{b_2} \cdots$，也就是 ${q_1}^{b_1} {q_2}^{b_2} \cdots$ 中有一个 ${q_i}{b_i}$ 可以整除 $p_1$，故 $p_1=q_i$，同除 $p_1$，则 ${p_2}^{a_2} \cdots$ 也是存在两种分解的合数，矛盾。

### 2.4.1 推论

设 $n$ 可以质因数分解为 $n=p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$。

推论 1：正数 $n$ 的正约数个数为

$(c_1+1)(c_2+1)(c_3+1)\cdots(c_m+1)=\prod_{i=1}^{m} (c_i+1)$推论 2：正数 $n$ 的所有正约数和为

$(1+p_1+p_1^2+\cdots+p_1^{c_1})\cdots(1+p_m+p_m^2+\cdots+p_m^{c_m})=\prod_{i=1}^{m} [\sum_{j=0}^{c_i} {p_i}^j]$可以用下文 7.1.2 的等比数列求和优化。

### 2.4.2 分解质因数

#### 试除法

与枚举法判素数同种原理，复杂度 $O(\sqrt{n})$。

```cpp
int p[N], c[N];
int decompose(int n) {
	int m = 0;
	for (int i = 2; i * i <= n; i++) {
		if (n % i) continue;
		p[++m] = i, c[m] = 0;
		while (n % i == 0) n /= i, c[m]++;
	}
	if (n > 1) p[++m] = n, c[m] = 1;
	return m;
}
```

需要注意的是，如果知道 $n$ 的值域，可以先用下面的质数筛打出一个质数表。根据质数分布规律，单次试除的复杂度降为 $O(\dfrac{\sqrt{n}}{\log n})$。

### *2.4.3 除数函数

- 定义**除数函数** $d(n)$ 为 $n$ 的正约数数目。容易发现 $d(n) \le 2\sqrt{n}$。

设 $n$ 可以质因数分解为 $n=p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$，根据推论 1 有

$d(n)=\prod_{i=1}^{m} (c_i+1)$除数函数 $d(n)$ 的级别远小于 $O(\sqrt{n})$。事实上，我们有

$\sum_{n=1}^{x} \dfrac{d(n)}{n}=\dfrac{1}{2} \log^2 x + 2 \gamma \log x+C+\delta$证明参见[这篇知乎讨论](https://www.zhihu.com/question/374042850/answer/3135401865)。其中 $C \approx \dfrac{1}{2}$，$\delta$ 为无穷小。这是一个均值估计。

事实上，还有

$\log d(n) \le \dfrac{\log 2 \log n}{\log \log n}(1+O(\dfrac{\log \log \log n}{\log \log n}))$[参考文献](https://www.zhihu.com/question/451354587/answer/1801059552)。它给出了一个比较好的估计。

- 下文中还会用到一个记号 $\omega(n)$，表示 $n$ 的质因子种类数。

一个粗略估计是 $\omega(n) \le \log n$。事实上，$\omega(n)$ 远小于 $O(\log n)$。因此有一个重要的 trick：基于质因子种类数很小，可以直接对质因子进行搜索或者状态压缩，复杂度约 $O(2^{\omega(n)})$。推荐阅读本人的[一类对质因子进行转态压缩的 trick](https://www.luogu.com.cn/article/f7uu8w9z)。

下面给出一个表格，它给出了 $d(n)$ 和 $\omega(n)$ 在一定范围内的上界：

![](https://cdn.luogu.com.cn/upload/image_hosting/4vaqgdw2.png)

求出 $n$ 的所有因子需要 $O(\sqrt{n})$ 的复杂度，现在我们知道复杂度 $O(\sqrt{n}+d^2(n))$ 是可以通过 $10^{12}$ 的数据的。

除数函数还有一个重要性质：对于 $\gcd(a,b)=1$，有 $d(ab)=d(a)d(b)$。这说明除数函数是一个积性函数。

## 2.5 质数筛

### 2.5.1 埃氏筛

小学课本上学过，我们每遍历到一个质数，就把它的倍数划去，最后剩下的未被划去的就是质数。埃氏筛使用 bitset 优化后速度快于线性筛。

```cpp
bitset<N> isprime;
void solve() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i * i <= N; i++) {  // 一个常数优化：筛到 O(sqrt(N)) 即可
		if (!isprime[i]) continue;
		for (int j = 1LL * i * i; j < N; j += i) isprime[j] = false;
	}
}
```

复杂度为 $O(n \log \log n)$。但是在实际计算中，bitset 优化后，它比 $O(n)$ 的线性筛更优秀。

### 2.5.2 线性筛

线性筛虽然跑不过 bitset 埃氏筛，但是它的思想值得学习。

埃氏筛复杂度到不了线性的原因是它会把一个合数划掉两遍。具体地，在标记 $i \times prime_j$ 时，需要确保 $i$ 的最小质因子不小于 $p$，即 $i\bmod prime_j =0$ 时跳出循环，这样复杂度就降到了 $O(n)$。

```cpp
bitset<N> isprime;
int tot, prime[N];
void solve() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i < N; i++) {
		if (isprime[i]) prime[++tot] = i;
		for (int j = 1; j <= tot; j++) {
			if (i * prime[j] >= N) break;
			isprime[i * prime[j]] = false;
			if (i & prime[j] == 0) break;
		}
	}
}
```

### 2.5.3 区间筛

在一些题目中，我们可能需要求出 $[l,r]$ 中的质数，其中 $l,r \le 10^{14}$ 但 $r-l \le 10^7$。区间筛可在 $O(n \log \log n)$ 的时间复杂度内解决问题，其中 $n=\max(\sqrt{r},r-l)$。

观察到 $[l,r]$ 中的合数的最大质因数不会超过 $\sqrt{r}$，这意味着我们可以用埃氏筛先处理出 $[1,\sqrt{r}]$ 内的质数，再用这些质数去筛掉 $[l,r]$ 中的合数。这也就是埃氏筛那个常数优化的原理。

```cpp
bitset<N> s, p;
void solve(int a, int b) {  // 筛出[a, b)之间的质数，用 p[i - a] 判断i是否为质数
	s.set(), p.set(), s[0] = s[1] = false;
	if (a <= 1) p[1 - a] = false;
	int z = (int) sqrt(b) + 1;
	for (int i = 2; i < z; i++) {
		for (int j = 2; i * j < z; j++) s[i * j] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		for (int j = max(i * i, (a + i - 1) / i * i); j < b; j += i) p[j - a] = false;
	}
}
```

## 2.6 例题

### P1147 连续自然数和

这种题型是一类常见题型，给出 $n$，并对于所求 $a,b$ 有 $ab=n$，则可以枚举 $n$ 的因数求解。

由等差数列求和：

$\dfrac{(l+r)(r-l+1)}{2}=n$枚举 $2n=ij$，则

$$
\left\{\begin{matrix}
r-l+1=i\\
l+r=j \\
\end{matrix}\right.
$$

解得

$$
\left\{\begin{matrix}
l=\dfrac{j-i+1}{2} \\
r=\dfrac{j+i-1}{2}
\end{matrix}\right.
$$

显然，$i,j$ 奇偶性应不同，且 $i$ 倒序枚举。复杂度 $O(\sqrt{n})$。

```cpp
int n;
void _main() {
	cin >> n; n *= 2;
	for (int i = sqrt(n); i >= 2; i--) {
		if (n % i) continue;
		int j = n / i;
		if ((i & 1) + (j & 1) == 1) cout << (j - i + 1) / 2 << ' ' << (j + i - 1) / 2 << '\n';
	}
}
```

### P8795 [蓝桥杯 2022 国 A] 选素数

设所求为 $x_0$，第一次操作后的值为 $x_1$，第二次操作后的值为 $x_2$。有一个重要结论是 $x_i-p_i+1 \le x_{i-1} \le x_i$。因为由题意得 $x_{i-1} \le x_i$，$p_i \mid x_i$ 且 $x_i$ 最小，用反证法，$x_i-p_i+1>x_{i-1}$，那么 $x_i-p_i$ 会成为这个位置的最小解，矛盾。

由此可知，$x_1-p_1+1 \le x_0 \le x_1$，让 $x_0$ 最小化，就要让 $x_1$ 最小，$p_1$ 最大。因为 $p_1 \mid x_1$，所以 $p_1$ 就是 $x_1$ 的最大质因子，此时 $x_0$ 取得最小值 $x_1-p_1+1$。我们再找到 $x_2$ 的最大质因子 $p_2$ 后枚举 $x_1 \in [x_2-p_2+1,x_2]$ 即可。复杂度 $O(n\sqrt{n})$，注意判无解。

```cpp
int decompose(int x) {
	int p = 1, t = x;
	for (int i = 2; i * i <= x; i++) {
		if (t % i) continue;
		while (t % i == 0) t /= i, p = i;
	}
	return max(t, p);
}

void _main() {
	int x2; cin >> x2;

	int p2 = decompose(x2);
	if (p2 == x2) return cout << -1, void();
	int res = INT_MAX;
	for (int x1 = p2 * (x2 / p2 - 1) + 1; x1 <= x2; x1++) {
		int p1 = decompose(x1), x0 = x1 - p1 + 1;
		if (x0 >= 3) res = min(res, x0);
	}
	cout << (res == INT_MAX ? -1 : res);
}
```

双倍经验：[CF923A Primal Sport](https://www.luogu.com.cn/problem/CF923A)。但是我们可爱的 RMJ 已经寄了。

### P1069 [NOIP 2009 普及组] 细胞分裂

形式化题意：给出 $m={m_1}^{m_2}$ 和 $n$ 个正整数 $a_i$，求

$\min_{i \in [1,n]} \min_{m\mid a_i^k} k$显然这题 $m$ 不能给它算出来，对 $m_1$ 分解质因数，则

$m={m_1}^{m_2}=(p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_h^{c_h})^{m_2}=p_1^{c_1m_2} p_2^{c_2m_2} p_3^{c_3m_2} \cdots p_h^{c_hm_2}$这样就得到了 $m$ 的质因数分解。对于每个 $a_i$，当且仅当 $\forall p_j, p_j \mid  a_i$ 时有解，否则 $a_i$ 自乘多少次都不能使 $m$ 成为其约数。

接下来我们求出 $p_j$ 在 $a_i$ 中出现的次数 $cnt$。则对于 $p_j$ 而言，$\min k=\lceil \dfrac{c_j}{cnt} \rceil$。然后用木桶原理，对所有 $\min k$ 取 $\max$，为 $a_i$ 的答案。总复杂度 $O(n \sqrt{V})$，$V$ 是值域。

```cpp
int n, m1, m2, a[N], tot;

int solve(int x) {
	int res = 0;
	for (int i = 1; i <= tot; i++) {
		if (x % p[i]) return INT_MAX;
		int cnt = 0;
		while (x % p[i] == 0) x /= p[i], cnt++;
		res = max(res, c[i] / cnt + (c[i] % cnt != 0));
	}
	return res;
}

void _main() {
	cin >> n >> m1 >> m2;
	for (int i = 1; i <= n; i++) cin >> a[i];
	tot = decompose(m1);
	for (int i = 1; i <= tot; i++) c[i] *= m2;
	int res = INT_MAX;
	for (int i = 1; i <= n; i++) res = min(res, solve(a[i]));
	cout << (res == INT_MAX ? -1 : res);
}
```

### P1865 A % B Problem

由 $m \le 10^6$ 可以筛一下 $m$ 以内的质数，询问用前缀和处理。远古代码太丑了不想放。

### P7960 [NOIP2021] 报数

质数筛的思想延伸。把含有 $7$ 的数先暴力找见，然后把它的倍数筛掉。

```cpp
const int N = 1e7 + 1000;  // 注意这里要开大点
int t, x, nxt[N];
bitset<N> dis;

inline bool check(int x) {
	for (; x != 0; x /= 10) if (x % 10 == 7) return true;
	return false;
}

void _main() {
	int last = 0;
	dis.reset();
	for (int i = 1; i < N; i++) {
		if (dis[i]) continue;
		if (check(i)) {
			for (int j = 1; j * i < N; j++) dis[j * i] = 1;
			continue;
		}
		nxt[last] = i, last = i;
	}
	for (cin >> t; t--; ) {
		cin >> x;
		cout << (dis[x] ? -1 : nxt[x]) << '\n';
	}
}
```

### AT_abc172_d [ABC172D] Sum of Divisors

不会推公式，只会大力筛法。注意到在埃氏筛标记倍数的过程中可以顺便求出 $d(n)$，直接做就好了。

```cpp
const int N = 1e7 + 5;
bitset<N> isprime;
int n, d[N];

void _main() {
	cin >> n;
	isprime.set(), isprime[1] = 0;
	for (int i = 2; i <= n; i++) {
		if (!isprime[i]) continue;
		int mul = 2;
		for (int j = i * 2; j <= n; j += i, mul++) isprime[j] = 0, d[j] += d[mul] + 1;
	}
	long long res = 0;
	d[1] = -1;
	for (int i = 1; i <= n; i++) res += 1LL * i * (d[i] + 2);
	cout << res;
}
```

### AT_abc412_e [ABC412E] LCM Sequence

打个表可以发现，$A_n$ 发生变化当且仅当 $n$ 为质数或质数的幂。

证明：由算术基本定理可设 $n={p_1}^{q_1}{p_2}^{q_2} \cdots {p_m}^{q_m}$。若 $m>1$，只要存在 $^{q_i}$ 的倍数，$n$ 加入就不会改变 $\operatorname{lcm}$。而若 $m=1$，此时 $n={p_1}^{q_1}>n-1$，此时 $n$ 为质数幂。

然后我们用区间筛把质数筛出来，并且在筛法过程中处理质数的幂即可。注意 $A_l$ 贡献是单独的。还有一种方法是用 Miller-Rabin 判质数并且处理质数幂。

```cpp
#define int long long
const int N = 1e7 + 5;
int l, r;
bitset<N> s, p;

void solve(int a, int b) {
	s.set(), p.set();
	int z = (int) sqrt(b) + 1;
	for (int i = 2; i < z; i++) {
		for (int j = 2; i * j < z; j++) s[i * j] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		for (int j = max(i * i, (a + i - 1) / i * i); j < b; j += i) p[j - a] = false;
	}
	for (int i = 2; i * i <= b; i++) {
		if (!s[i]) continue;
		int j = i * i;
		while (j < a) j *= i;
		for (; j < b; j *= i) p[j - a] = true;
	}
}

void _main() {
	cin >> l >> r;
	if (l == r) return cout << 1, void();
	solve(l, r + 1);
	int cnt = 0;
	for (int i = l; i <= r; i++) cnt += p[i - l];
	if (!p[0]) cnt++;
	cout << cnt;
}
```

### [模拟赛] 舔狗的付出

> 给你一个十进制正整数 $x$，在 $x$ 后面添加若干数字使它成为一个质数，可以不添加，求这个质数的最小值。
>
> 多测，$T,x \le 10^6$。

根据质数分布规律，$n$ 以内的质数最大间隔应该是 $O(\log n)$ 级别的。经过测试，在 $n=10^9$ 时最大间隔为 $72$。在本题中，加三位一定能够成为质数。

对于加一位或加两位的数字，我们可以用筛出 $10^8$ 以内的质数枚举解决。但是筛到 $10^9$ 肯定会 T。不妨将加三位的数打表出来：

```cpp
int f(long long x) {
	if (miller_rabin(x)) return -1;
	for (int i = 0; i <= 9; i++) {
		if (miller_rabin(x * 10 + i)) return -1;
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			if (miller_rabin(x * 100 + i * 10 + j)) return -1;
		}
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			for (int k = 0; k <= 9; k++) {
				if (miller_rabin(x * 1000 + i * 100 + j * 10 + k)) return x * 1000 + i * 100 + j * 10 + k;
			}
		}
	} return -1;
}

void _main() {
	int cnt = 0;
	for (int i = 1; i <= 1e6; i++) {
		int x = f(i);
		if (x != -1) cerr << "{" << i << ", " << x << "}, ";
	}
}
```

使用 Miller-Rabin 判质数的复杂度为 $O(nw^3 \log nw)$，其中 $n \le 10^6, w \le 10$，本机可以 4.6s 跑完。如果暴力判质数，要等的时间比较长。可以发现加三位的只有 $393$ 个数字，直接把表写进去就行了。

```cpp
const int N = 1e8 + 100;
unordered_map<int, int> table = {{16718, 16718003}, ...};   // 省略打表内容
bitset<N> isprime;
int x;
void _main() {
	cin >> x;
	if (table.count(x)) return cout << table[x] << '\n', void();
	if (isprime[x]) return cout << x << '\n', void();
	for (int i = 0; i <= 9; i++) {
		if (isprime[x * 10 + i]) return cout << x * 10 + i << '\n', void();
	}
	for (int i = 0; i <= 9; i++) {
		for (int j = 0; j <= 9; j++) {
			if (isprime[x * 100 + i * 10 + j]) return cout << x * 100 + i * 10 + j << '\n', void();
		}
	}
}   // 代码省略了筛质数的部分
```

### P3861 拆分

求出 $n$ 的所有正约数，记为 $x_1,x_2,\cdots,x_{d(n)}$。不妨设 $x$ 单调递增，记录 $p_x$ 表示约数 $x$ 出现的下标。

考虑一个 DP，设 $dp_{i,j}$ 表示将 $x_i$ 分解为若干不超过 $x_j$ 的数的方案数。答案即 $dp_{d(n),d(n)}-1$。考虑转移：

1. $x_i$ 的分解不包含 $x_j$：答案为 $dp_{i,j-1}$。
2. $x_i$ 的分解包含 $x_j$：必要条件是 $x_j \mid x_i$，此时将 $\dfrac{x_i}{x_j}$ 分解为若干小于 $x_j$ 的数的乘积，答案为 $dp_{p_{x_i/x_j}, j-1}$。

二者加起来即为答案。复杂度 $O(\sqrt{n}+d^2(n))$，可以通过。

```cpp
const int N = 6725;  // d(10^12) <= 6720
long long n, x[N];
mint dp[N][N];
gp_hash_table<int, int> p;

void _main() {
	x[0] = 0, p.clear();
	cin >> n;
	for (long long i = 1; i * i <= n; i++) {
		if (n % i) continue;
		x[++x[0]] = i;
		if (i * i != n) x[++x[0]] = n / i;
	}
	sort(x + 1, x + x[0] + 1);
	for (int i = 1; i <= x[0]; i++) p[x[i]] = i;
	for (int i = 1; i <= x[0]; i++) {
		dp[i][1] = (i == 1);
		for (int j = 2; j <= x[0]; j++) {
			dp[i][j] = dp[i][j - 1];
			if (x[i] % x[j]) continue;
			dp[i][j] += dp[p[x[i] / x[j]]][j - 1];
		}
	} cout << dp[x[0]][x[0]] - 1 << '\n';
}
```

### CF1878F Vasilije Loves Number Theory

注意到 $n=d(a)d(n)$，故原问题等价于判断 $d(n) \mid n$。

用一个 std::map 维护当前分解质因数的结果 ${p_1}^{c_1}{p_2}^{c_2}{p_3}^{c_3}\cdots$。那么 $d(n)$ 就是 $\prod (c_i+1)$。因为我们只需判断 $n \bmod d(n)=0$，所以算 $n$ 的时候对 $d(n)$ 取模即可。用一个快速幂来实现。

```cpp
int n, q, opt, x;

long long mpow(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = a * a % p, b >>= 1) {
		if (b & 1) res = res * a % p;
	} return res;
}
void decompose(int x, map<int, int>& mp) {
	for (int i = 2; i * i <= x; i++) {
		while (x % i == 0) mp[i]++, x /= i;
	}
	if (x != 1) mp[x]++;
}

void _main() {
	cin >> n >> q;
	map<int, int> mp;
	decompose(n, mp);
	map<int, int> cur = mp;
	while (q--) {
		cin >> opt;
		if (opt == 1) {
			cin >> x;
			decompose(x, cur);
			long long a = 1, b = 1;
			for (const auto& i : cur) b *= i.second + 1;
			for (const auto& i : cur) a = a * mpow(i.first, i.second, b) % b;
			cout << (a % b ? "NO\n" : "YES\n");
		} else cur = mp;
	} cout << '\n';
}
```

### P1463 [POI 2001 R1 / HAOI2007] 反素数

根据定义不难证明，$[1,n]$ 中最大的反素数就是 $d(x)$ 最大的数中的最小值。

注意到 $2\times 3\times 5 \times 7 \times 11\times 13\times 17 \times 19\times 23 \times 29\times 31=200560490130>2\times 10^9$，所以 $\omega(x) \le 10$。感性理解对于 $d(x)=\prod (c_i+1)$，最大化 $d(x)$ 同时最小化 $x$ 的方法就是使得前面的 $c$ 尽可能大，后面的小一些。可以证明，反素数一定满足 $c_1 \ge c_2 \ge \cdots \ge c_{10}$。

到这里，可以考虑直接爆搜。DFS 枚举指数，满足单调不升且总乘积不超过 $n$，直接记下 $d(x)$，搜索树并不大。

```cpp
#define int long long
int n, ansd, ansn, c[10];
const int p[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};
void dfs(int x, int num, int d) {
	if (d > ansd || (d == ansd && num < ansn)) ansn = num, ansd = d;
	if (x >= 10) return;
	int mul = 1;
	for (int i = 1; i <= (x ? c[x - 1] : 30); i++) {
		mul *= p[x], c[x] = i;
		if (num * mul > n) break;
		dfs(x + 1, num * mul, d * (i + 1));
	}
}
void _main() {
	cin >> n;
	dfs(0, 1, 1);
	cout << ansn;
}
```

### *P7603 [THUPC 2021] 鬼街

注意到 $\omega(10^5) \le 6$，通过预处理质因子分解，修改可以 $O(\omega(V))$ 暴力完成。

考虑查询怎么做。这需要一个叫做**折半警报器**的东西。

根据下文 7.2 的抽屉原理，设某个警报器的阈值为 $y$，监测的集合为 $S$，报警的充要条件为 $\sum_{x \in S} a_x \ge y$，其必要条件是 $\exists x \in S, a_x \ge \lceil \dfrac{y}{k} \rceil$。考虑将一个大警报器拆成几个小的维护某些位置。

对于每个位置 $x$，记录当前发生过的时间阈值和 $tag_x$。用一个 std::set 维护 $x$ 位置所有的警报器。为了消除之前的报警，在插入大警报器时需要差分，小警报器则暴力重构。

因为每次报警，大警报器的阈值至少下降 $\lceil \dfrac{y}{k} \rceil$，所以重构次数约为 $\log_{\frac{k}{k-1}} y$，总体复杂度 $O(n \log n \log V)$。实现上，由于 std::set 常数过大，应该使用类似 Dijkstra 的方法，维护一个堆并且懒删除卡常。一个神秘的地方是用 pbds 会 MLE on #7。

```cpp
const int N = 1e5 + 5;
int n, q, opt, x;
long long y;
vector<int> fac[N];
vector<int> decompose(int x) {
	vector<int> res;
	for (int i = 2; i * i <= x; i++) {
		if (x % i) continue;
		res.emplace_back(i);
		while (x % i == 0) x /= i;
	}
	if (x != 1) res.emplace_back(x);
	return res;
}

struct node {
	long long val; int id, time;
	node(long long a = 0, long long b = 0, long long c = 0) : val(a), id(b), time(c) {}
	bool operator< (const node& a) const {return val > a.val;}
};
priority_queue<node> heap[N];

long long lastans, tim, num, a[N], b[N], last[N], c[N], f[N];
vector<long long> nw, res;
void rebuild(const node& x) {
	int id = x.id;
	if (last[id] == -1) return;
	long long sum = 0;
	for (int i : fac[a[id]]) sum += c[i];
	if (sum >= f[id] + b[id]) return res.emplace_back(id), last[id] = -1, void();  // id报警
	b[id] += f[id] - sum, f[id] = sum, last[id] = ++tim;
	long long cnt = fac[a[id]].size(), d = (b[id] + cnt - 1) / cnt;
	for (int i : fac[a[id]]) heap[i].push(node{c[i] + d, id, tim});
}
void check(int x) {
	while (!heap[x].empty() && heap[x].top().val <= c[x]) {
		node u = heap[x].top(); heap[x].pop();
		if (last[u.id] != u.time) continue; // 懒删除
		rebuild(u);
	}
}
void ask() {
	res.clear(), res.insert(res.end(), nw.begin(), nw.end());
	nw.clear();
	for (int i : fac[x]) c[i] += y;
	for (int i : fac[x]) check(i);
	sort(res.begin(), res.end());
	cout << (lastans = res.size()) << ' ';
	for (int i : res) cout << i << ' ';
	cout << '\n';
}
void add() {
	long long cnt = fac[x].size(), d = (y + cnt - 1) / cnt;
	tim++, num++;
	if (y == 0) return nw.emplace_back(num), void();
	a[num] = x, b[num] = y, last[num] = tim;
	for (int i : fac[x]) f[num] += c[i], heap[i].push(node{c[i] + d, num, tim});
}

void _main() {
	cin >> n >> q;
	for (int i = 2; i <= n; i++) fac[i] = decompose(i);
	while (q--) {
		cin >> opt >> x >> y; y ^= lastans;
		if (opt == 0) ask();
		else add();
	}
}
```$AKB328$, '数学', array['质数', '素数筛', '威尔逊定理', '算术基本定理'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-probability--stripe-python', '概率论与期望 · stripe-python', $AKB329$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 18. 概率论

概率期望在组合数学中是一个有用的工具，很多计数问题用总数乘概率来计算会简单很多。一些很难的计数 DP 变成期望 DP 以后状态转移会比较好推。

## 18.1 概念

- **样本空间**：一个集合 $U$，表示所有可能出现的单个事件。
- **随机事件**：若 $A \subseteq U$，则称 $A$ 是一个随机事件。若 $\exists \omega \in A,\omega$ 发生，则称事件 $A$ 发生。

根据随机事件的定义，我们可以得到必然事件与不可能事件的定义：

- 若随机事件 $A=U$，则 $A$ 为**必然事件**；
- 若随机事件 $A=\varnothing$，则 $A$ 为**不可能事件**。

若随机事件只有有限个，且每个随机事件出现的可能性相同，可以得到概率的古典定义：

- **概率**：记 $P(A)$ 为事件 $A$ 发生的概率，则 $P(A) =\dfrac{|A|}{|U|}$。

### 18.1.1 事件的运算

因为随机事件是一个集合，所以集合的交、并、补同样适用于随机事件。

- **事件的并**：记作 $A \cup B$，也记作 $A +B$，表示事件 $A,B$ 有一个发生。
- **事件的交**：记作 $A \cap B$，也记作 $AB$，表示事件 $A,B$ 同时发生。
- **事件的补**：记作 $U \setminus A$，表示事件 $A$ 不发生。

根据德摩根定律有

$$
U \setminus (A + B)=(U\setminus A) (U \setminus B)\\
U \setminus (AB)= (U \setminus A)+(U \setminus B)
$$

在计算概率时，我们可能会用到这条定理。

### 18.1.2 概率的性质

- 概率的加法原理：若 $A \cap B=\varnothing$，则 $P(A+B)=P(A)+P(B)$。
- 概率的乘法原理：若 $A,B$ 独立，$P(AB)=P(A)\times P(B)$。

根据概率的加法原理有 $P(A)+P(U \setminus A)=1$。请注意概率的加法 & 乘法原理的前提条件。

注意多个事件两两独立不是这些事件独立的充分条件，因此多个事件的乘法原理要慎重使用。

- 概率的单调性：若 $A \subseteq B$，则 $P(A) \le P(B)$。
- 概率的二元容斥：$P(A+B)=P(A)+P(B)-P(AB)$。这里不要求 $A,B$ 独立或者不交。

## 18.2 条件概率

在上文中，我们讨论过独立事件的概率运算原理。若 $A$ 的发生对 $B$ 的发生有影响，就要使用条件概率。

- 条件概率：若已知事件 $B$ 发生，则事件 $A$ 发生的概率为条件概率，记作 $P(A|B)$。

根据概率的乘法原理可得

$P(A|B)=\dfrac{P(AB)}{P(B)}$将这个公式变形可得 $P(AB)=P(B|A) \times P(A)$，得到贝叶斯公式

$P(A|B)=\dfrac{P(B|A)\times P(A)}{P(B)}$这是一个重要的概率原理。条件概率说明了当 $A,B$ 不独立时，概率的乘法原理如何变化。

## *18.3 期望

举一个例子，我们用随机变量 $X$ 表示掷出一枚骰子朝上的点数，则平均点数就是 $X$ 的期望：

$E(X)=1\times \dfrac{1}{6}+2\times \dfrac{1}{6}+3\times \dfrac{1}{6}+4\times \dfrac{1}{6}+5\times \dfrac{1}{6}+6\times \dfrac{1}{6}=3.5$因此，随着掷骰子次数的增大，向上的点数均值应当趋近于 $3.5$。

通过这个例子可以发现，期望就是随机变量输出值的加权平均数，权重为 $P(X=i)$。形式化地，定义 $X$ 的期望为

$E(X) =\sum P(X=i) \times i$根据乘法分配律可得期望的线性性：$E(aX+bY)=aE(X)+bE(Y)$。这是一个很重要的性质，也是期望可以递推计算的理论依据。

## *18.4 概率分布

伯努利试验：一场试验仅有 $1$ 或 $0$ 两种可能，$1$ 表示成功，$0$ 表示失败，设成功的概率为 $p$，可得失败概率为 $1-p$。

1. 两点分布：进行 $1$ 次伯努利试验，成功概率为 $p$，期望值为 $E(X)=p \times 1+(1-p) \times 0=p$。
2. 几何分布：设得到一次成功所需的实验次数为 $X$，则第 $i$ 次才能得到成功的概率为

$P(X=i)=(1-p)^{i-1}p$期望值为 $E(X)=\dfrac{1}{p}$，证明：

$$
\begin{aligned}
E(X)&=\sum_{i=1}^{\infty} P(X=i) \times i\\
&=\sum_{i=1}^{\infty} i(1-p)^{i-1}p\\
&=\dfrac{p}{[1-(1-p)]^2}\\
&=\dfrac{1}{p}
\end{aligned}
$$

1. 二项分布：设进行 $n$ 次伯努利试验成功的次数为 $X$，则

$P(X=i) =C_n^i p^i (1-p)^{n-i}$不加证明地，$E(X)=np$。

1. 超几何分布：现有 $n$ 个产品，其中有 $k$ 个不合格，随机取出 $m$ 个送检，设不合格产品的数量为 $X$，则

$P(X=i)=\dfrac{C_k^i C_{n-k}^{m-i}}{C_n^m}$同样不加证明地，$E(X)=\dfrac{mk}{n}$。

## 18.5 例题

我们先给出概率论的习题，然后讲解利用概率解计数问题的方法。

### P2719 搞笑世界杯

这题有两种做法。我们先来说比较简单的概率 DP，就是设 $dp_{i,j}$ 表示已经售出了 $i$ 张 A 类票，$j$ 张 B 类票的概率。根据概率的加法原理

$dp_{i,j}=\dfrac{dp_{i-1,j}+dp_{i,j-1}}{2}$边界是 $dp_{i,0}=dp_{0,1}=1.0$。复杂度 $O(n^2)$。

```cpp
const int N = 1300;
int n;
double dp[N][N];

inline void _main() {
	cin >> n; n >>= 1;
	for (int i = 2; i <= n; i++) dp[0][i] = dp[i][0] = 1;
 	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) dp[i][j] = (dp[i - 1][j] + dp[i][j - 1]) / 2;
	} cout << fixed << setprecision(4) << dp[n][n];
}
```

第二种做法是数学推导，设事件 $A$ 为最后两张不同，则前 $2n-2$ 张中有 $n-1$ 张 A，$n-1$ 张 B，根据概率的乘法原理得

$P(A)=\dfrac{C_{2n-2}^{n-1}}{2^{2n-2}}$一边循环一边求值即可，复杂度 $O(n)$。

```cpp
int n;
void _main() {
	cin >> n; n >>= 1;
	double res = 1.0;
	for (int i  = 1; i < n; i++) res *= 1.0 * (i + n - 1) / (i * 4);
	cout << fixed << setprecision(4) << 1.0 - res;
}
```

### P1297 [国家集训队] 单选错位

令 $a_{n+1}=a_1$，对于 $a_i$ 和 $a_{i+1}$ 分类讨论：

- 若 $a_i=a_{i+1}$，做对的概率为 $\dfrac{1}{a_i}$。
- 若 $a_i>a_{i+1}$，问题分步，首先有 $\dfrac{a_{i+1}}{a_i}$ 的概率让随机到的答案在 $[1,a_{i+1}]$ 中，然后还有 $\dfrac{1}{a_{i+1}}$ 的概率选中正解。根据概率的乘法原理，二者相乘得 $\dfrac{1}{a_i}$。
- 若 $a_i<a_{i+1}$，同理有 $\dfrac{a_i}{a_{i+1}}$ 的概率使得正确答案在 $[1,a_i]$ 中，然后概率的乘法原理得 $\dfrac{1}{a_{i+1}}$。

根据期望的定义式，求和即可：

$\sum_{i=1}^{n} \dfrac{1}{\max(a_i,a_{i+1})}$```cpp
const int N = 1e7 + 5;
int n, A, B, C, a[N];

void _main() {
	cin >> n >> A >> B >> C >> a[1];
	if (n == 1) return cout << "1.000", void();
	for (int i = 2; i <= n; i++) a[i] = (1LL * a[i - 1] * A + B) % 100000001;
	for (int i = 1; i <= n; i++) a[i] = a[i] % C + 1;
	double res = 0.0;
	a[n + 1] = a[1];
	for (int i = 1; i <= n; i++) res += 1.0 / max(a[i], a[i + 1]);
	cout << fixed << setprecision(3) << res;
}
```

### *[模拟赛] 概率

> 有一个长为 $2n$ 的非负整数序列，每个数字在 $[0,m]$ 中随机均匀分布。求前 $n$ 个数的和 $s_1$ 大于后 $n$ 个数的和 $s_2$ 的概率。对给出的质数 $p$ 取模。
>
> 多测，$T,n,m \le 2000$。

开赛 3.5h 不会 T2，最后 30min 冲出这道 T4 翻盘。

**概率转计数**。总数为 $tot=(m+1)^{2n}$。根据对称性，$s_1 < s_2$ 的方案数等于 $s_1 > s_2$ 的方案数。只需统计 $s_1=s_2$ 的方案数 $ans$，答案即为 $\dfrac{tot-ans}{2tot}$。

我们需要求

$\sum_{k=1}^n x_k=\sum_{k=1}^n y_k$令 $w_k=m-y_k \in [0,m]$，且

$\sum_{k=1}^n=\sum_{k=1}^n (m-w_k)=nm-\sum_{k=1}^n w_k$移项，问题转化为不定方程

$x_1+x_2+\cdots+x_{2n}=nm$的非负整数解数目。要求 $0 \le x_i \le m$。

令 $j=nm-i(m+1)$，根据 9.3.2 的问题四得到答案为

$ans=\sum_{i=0}^{2n} (-1)^i C_{2n}^i C_{2n+j-1}^{j}$复杂度 $O(Tn)$。

```cpp
const int N = 2005, M = 5e6;
int p, q, n, m;
mod32 fac[M + 5], ifac[M + 5];
mod32 C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void ask() {
	mod32 tot = mod32(m + 1).pow(2 * n), res = 0;
	for (int i = 0; i <= 2 * n; i++) {
		int j = n * m - i * (m + 1);
		if (j < 0) break;
		if (i & 1) res -= C(2 * n, i) * C(2 * n + j - 1, j);
		else res += C(2 * n, i) * C(2 * n + j - 1, j);
	} cout << (tot - res) / 2 / tot << '\n';
}

void _main() {
	cin >> p >> q, mod32{}.set_mod(p);
	fac[0] = 1;
	for (int i = 1; i <= M; i++) fac[i] = fac[i - 1] * i;
	ifac[M] = ~fac[M];
	for (int i = M - 1; i >= 0; i--) ifac[i] = ifac[i + 1] * (i + 1);
	while (q--) cin >> n >> m, ask();
}
```

### *P1654 OSU!

用 $dp_{1/2/3,i}$ 表示当连续的 $k$ 个 $1$ 可以贡献 $k^{1/2/3}$ 的分数时的期望。

不难发现，对于 $dp_{1,i}$，这个位置有 $p_i$ 的概率成为 $1$ 从而接上前面，则

$dp_{1,i}=(dp_{1,i-1}+1) \times p_i$考察 $E(X^2)$。因为 $E(X^2) \ne E^2(x)$，经过思考想到通过 $E((X-1)^2)$ 转移。有 $E((X-1)^2)=E(X^2-2X+1)$，根据期望的线性性

$E(X)=E((X-1)^2)+2E(X)+1$写成 DP 方程是

$dp_{2,i}=(dp_{2,i-1}+2 \times dp_{1,i-1}+1) \times p_i$同理我们有 $E((X-1)^3)=E(X^3-3X^2-3X+1)$，写出转移

$dp_{3,i}=dp_{3,i}+(3 \times dp_{2,i-1}+3 \times dp_{1,i}+1) \times p_i$至此本题在 $O(n)$ 复杂度内解决。

```cpp
const int N = 1e5 + 5;
int n;
double p[N], dp1[N], dp2[N], dp3[N];

inline void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) {
		dp1[i] = p[i] * (dp1[i - 1] + 1);
		dp2[i] = p[i] * (dp2[i - 1] + 2 * dp1[i - 1] + 1);
		dp3[i] = dp3[i - 1] + p[i] * (3 * dp2[i - 1] + 3 * dp1[i - 1] + 1);
	} cout << fixed << setprecision(1) << dp3[n];
}
```

### *P4484 [BJWC2018] 最长上升子序列

前置知识：状态压缩，位运算技巧。不会请移步第 18 章。

**期望转计数**。只要求出所有 LIS 长度的和除以 $n!$ 即可。

注意到 $2^{28}$ 不算太大，考虑状压 DP 结合计数。有一个神奇的状压方法：

令 $f_i$ 表示以 $i$ 结尾的 LIS 长度，记 $f_i$ 的前缀最大值为 $g_i$，即 $g_i=\max_{j=1}^i f_i$。

注意到，$g_i$ 单调不降，且差分之后的序列仅由 $0,1$ 组成。可以对这个差分序列状态压缩。

设 $dp_{i,j}$ 表示考虑 $1 \sim i$ 的一个排列，$g$ 的差分在二进制表示下为 $j$ 的 LIS 总长度。

记差分序列为 $d_i$。当在 $i,i+1$ 之间插入一个新数时，根据状态这个数一定是当前最大值，于是 $g_i=1+\max g_j$，故 $d_{i+1}=1$。枚举插入的位置 $p$，需将 $d_p \gets 0$。

转移方程为

$dp_{i,j}=\sum dp_{i-1,j'}$答案用状态为 $j$ 的方案数乘上 LIS 长度即可，也就是 $\operatorname{popcount}(j)$。答案为

$\dfrac{1}{n!} \sum_{j} dp_{n,j} \times \operatorname{popcount}(j)$复杂度为 $O(n^2 2^n)$，需要滚动数组优化。可以通过 $n \le 24$ 的数据。代码从深进上抄的，是刷表法。

```cpp
const int N = 1.4e7 + 5;
int n;
mint dp[2][N];

void _main() {
	cin >> n;
	dp[1][0] = 1;
	for (int i = 1, st = 0; i < n; i++, st ^= 1) {
		fill(dp[st], dp[st] + (1 << i), 0);
		for (int j = 0; j < (1 << (i - 1)); j++) {
			dp[st][j << 1] += dp[st ^ 1][j];
			for (int k = i - 1, pos = -1; k >= 0; k--) {
				int nxt = ((j >> k) << (k + 1)) | (1 << k) | (j & ((1 << k) - 1));
				if (j >> k & 1) pos = k;
				if (pos != -1) nxt ^= (1 << (pos + 1));
				dp[st][nxt] += dp[st ^ 1][j];
			}
		}
	}
	mint res = 0;
	for (int i = 0; i < (1 << (n - 1)); i++) res += dp[n & 1][i] * (popcount(i) + 1);
	for (int i = 1; i <= n; i++) res /= i;
	cout << res;
}
```

注意到这题输入只有一个 $n$，在本机上跑个打表即可，大概 5min 就打完了。

### *P1850 [NOIP 2016 提高组] 换教室

注意到 $v \le 300$，先跑 $O(v^3)$ 的 Floyd 求一下全源最短路。

大力期望 DP。设 $dp_{0/1,i,j}$ 表示考虑到第 $i$ 个教室，已经换了 $j$ 次，这一次换不换的期望代价。容易写出转移式子：

$$
\begin{aligned}
dp_{0,i,j}&=\min(dp_{0,i-1,j}+d_{s_{i-1},s_i},dp_{1,i-1,j}+(1-k_{i-1})d_{s_{i-1},s_i}+k_{i-1}d_{t_{i-1},s_i})\\
dp_{1,i,j}&=\min(dp_{0,i-1,j-1}+(1-k_i)d_{s_{i-1},s_i}+k_i d_{s_{i-1},t_i},dp_{1,i-1,j-1}+(1-k_{i-1})(1-k_i)d_{s_{i-1},s_i}+(1-k_{i-1})k_i d_{s_{i-1},t_i}+k_{i-1}(1-k_i)d_{t_{i-1},s_i}+k_{i-1}k_id_{t_{i-1},t_i})
\end{aligned}
$$

复杂度 $O(v^3+n^2)$。唯一难点在于期望各种性质的熟练运用。

```cpp
const int N = 2005;
int n, m, v, e, x, y, w, s[N], t[N], dis[305][305];
double k[N], dp[2][N][N];
void floyd() {
	for (int k = 1; k <= v; k++) {
		for (int i = 1; i <= v; i++) {
			for (int j = 1; j <= v; j++) dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
		}
	}
}

void _main() {
	cin >> n >> m >> v >> e;
	for (int i = 1; i <= n; i++) cin >> s[i];
	for (int i = 1; i <= n; i++) cin >> t[i];
	for (int i = 1; i <= n; i++) cin >> k[i];
	memset(dis, 0x3f, sizeof(dis));
	for (int i = 1; i <= v; i++) dis[i][i] = 0;
	for (int i = 1; i <= e; i++) {
		cin >> x >> y >> w;
		dis[x][y] = dis[y][x] = min(dis[x][y], w);
	}
	floyd();
	for (int i = 0; i <= n; i++) fill(dp[0][i], dp[0][i] + n + 1, 1e18), fill(dp[1][i], dp[1][i] + n + 1, 1e18);
	dp[0][1][0] = dp[0][1][1] = dp[1][1][1] = 0;
	for (int i = 2; i <= n; i++) {
		for (int j = 0; j <= min(i, m); j++) {
			dp[0][i][j] = min(
				dp[0][i - 1][j] + dis[s[i - 1]][s[i]],
				dp[1][i - 1][j] + dis[s[i - 1]][s[i]] * (1 - k[i - 1]) + dis[t[i - 1]][s[i]] * k[i - 1]
			);
			if (j > 0) dp[1][i][j] = min(
				dp[0][i - 1][j - 1] + dis[s[i - 1]][s[i]] * (1 - k[i]) + dis[s[i - 1]][t[i]] * k[i],
				dp[1][i - 1][j - 1] + dis[s[i - 1]][s[i]] * (1 - k[i - 1]) * (1 - k[i]) + dis[s[i - 1]][t[i]] * (1 - k[i - 1]) * k[i] + dis[t[i - 1]][s[i]] * k[i - 1] * (1 - k[i]) + dis[t[i - 1]][t[i]] * k[i - 1] * k[i]
			);
		}
	}
	double res = 1e18;
	for (int j = 0; j <= min(n, m); j++) res = min({res, dp[0][n][j], dp[1][n][j]});
	cout << fixed << setprecision(2) << res;
}
```

### P11362 [NOIP2024] 遗失的赋值

这个做法来自本人已退役的同学 [zgy_123](https://www.luogu.com.cn/article/hewa7jrt)，在此膜拜 CMO 大神。

不合法的情况有两种：一种是一元限制发生冲突，一种是一元限制与二元限制冲突。对于第一种，开一个 std::map 判无解即可。

考虑用总数 $v^{2(n-1)}$ 乘上合法概率。可以发现 $d_j$ 在判完无解后就没用了。因为已知所有一元限制的位置，对于形如 `...???x?...?y???...` 的一段，设两个相邻一元限制的位置分别为 $l,r$。那么在 $r$ 位置一元限制与二元限制冲突当且仅当：

1. $\forall i \in [l,r)$，第 $i$ 条二元限制为 $(i,x_i)$。
2. 第 $r$ 条二元限制为 $(r,x')$，其中 $x' \ne x_r$。

除此之外，一定可以构造出合法方案。**计数转概率**，第一条的概率为 $p_1=\dfrac{1}{v^{r-l}}$，第二条的概率为 $p_2=\dfrac{v-1}{v}$。显然二者独立，根据概率的乘法原理，在 $r$ 位置冲突的概率为

$\dfrac{v-1}{v^{r-l+1}}$不冲突的概率用 $1$ 减掉即可。把位置排个序扫一遍，复杂度 $O(m \log m)$。

```cpp
const int N = 1e5 + 5;
int n, m, a[N], c, d;
mint v;
unordered_map<int, int> mp;

void _main() {
	mp.clear(), memset(a, 0, sizeof(int) * (m + 1));
	cin >> n >> m >> v;
	bool flag = true;
	for (int i = 1; i <= m; i++) {
		cin >> c >> d;
		if (mp.count(c)) {
			if (mp[c] != d) flag = false;
		} else {
			a[++a[0]] = c, mp[c] = d;
		}
	}
	if (!flag) return cout << 0 << '\n', void();
	sort(a + 1, a + a[0] + 1);
	mint res = v.pow(2 * (n - 1));
	for (int i = 2; i <= a[0]; i++) {
		int l = a[i - 1], r = a[i];
		res *= mint(1) - (v - 1) / v.pow(r - l + 1);
	} cout << res << '\n';
}
```

### *AT_agc030_d [AGC030D] Inversion Sum

**计数转概率**。注意到 $O(n^2)$ 是能过的。如果认为每个操作等概率执行或不执行，可以设 $dp_{i,j}$ 为当前时刻 $a_i > a_j$ 的**概率**。

那么答案就是 $2^m \sum_{i<j} dp_{i,j}$，也就是期望乘总数。现在我们考虑对于一次操作 $x,y$ 对第 $i$ 个位置造成的影响：

- 若 $i \ne x$ 且 $i \ne y$：则 $dp_{x,i} \gets \dfrac{dp_{x,i}+dp_{y,i}}{2}$。因为每次操作以后它有 $\dfrac{1}{2}$ 的概率继承原来的状态，还有 $\dfrac{1}{2}$ 的概率变成 $dp_{y,i}$ 的状态，根据概率的加法原理可得。剩下的 $dp_{y,i},dp_{i,x},dp_{i,y}$ 同理。

注意对于 $dp_{x,y}$ 也有转移为 $dp_{x,y} \gets \dfrac{dp_{x,y}+dp_{y,x}}{2}$，原理类似。复杂度 $O(n^2)$。

```cpp
const int N = 3005;
int n, m, a[N], x[N], y[N];
mint dp[N][N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= m; i++) cin >> x[i] >> y[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			if (a[i] > a[j]) dp[i][j] = 1;
		}
	}
	for (int k = 1; k <= m; k++) {
		for (int i = 1; i <= n; i++) {
			if (i == x[k] || i == y[k]) continue;
			dp[x[k]][i] = dp[y[k]][i] = (dp[x[k]][i] + dp[y[k]][i]) / 2;
			dp[i][x[k]] = dp[i][y[k]] = (dp[i][x[k]] + dp[i][y[k]]) / 2;
		}
		dp[x[k]][y[k]] = dp[y[k]][x[k]] = (dp[x[k]][y[k]] + dp[y[k]][x[k]]) / 2;
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = i + 1; j <= n; j++) res += dp[i][j];
	} cout << res * mint(2).pow(m);
}
```

## 附：概率论专题笔记（stripe-python）

对于一个随机试验 $E$，我们将其所有可能的基本结果称为**样本点**，记为 $\omega$。所有样本点组成的集合称作**样本空间** $\Omega$。

定义**事件** $A$ 是 $\Omega$ 的子集。当且仅当 $\exists \omega \in A, \omega$ 出现，称为事件 $A$ **发生**。此时有：

- 若 $A=\Omega$，称 $A$ 为**必然事件**。
- 若 $A=\varnothing$，称 $A$ 为**不可能事件**。

事件是一个集合，因此集合的交 & 并 & 补 & 对称差操作都可以推广到事件上。具体地：

- 称 $A \cup B$ 为事件 $A,B$ 的和事件，记作 $A+B$。组合意义为事件 $A$ 发生**或**事件 $B$ 发生。
- 称 $A \cap B$ 为事件 $A,B$ 的积事件，记作 $AB$。组合意义为事件 $A$ 发生且事件 $B$ 发生。
- 称 $A \cap B=\varnothing$ 的事件 $A,B$ 互斥。组合意义为事件 $A,B$ 不可能同时发生。
- 称 $\Omega \setminus A$ 为 $A$ 的对立事件，记作 $\overline A$。组合意义为事件 $A,\overline {A}$ 中必然有且仅有一个发生。

如果满足 $\Omega$ 是有限集，且每个样本点出现的可能性相等，则可以用**古典概型**定义事件 $A$ 发生的概率
$$
P(A)=\dfrac{|A|}{|\Omega|}
$$
概率函数满足如下性质：

- $P(\Omega)=1, P(\varnothing)=0$。
- 若事件 $A,B$ 互斥，则 $P(A+B)=P(A)+P(B)$。称为概率的加法公式。
- 若 $A,B$ 互为独立，则 $P(A)+P(B)=1$。
- 若 $A \subseteq B$，则 $P(A) \le P(B)$。
- 概率的容斥原理：$P(A+B)=P(A)+P(B)-P(AB)$。

定义事件 $A,B$ 相互**独立**，当且仅当
$$
P(AB)=P(A)P(B)
$$
其组合意义为：一个事件是否发生，不会干涉另一个事件的发生。

## 19.1 条件概率

对于两个随机事件 $A,B$，记在事件 $A$ 发生的条件下，事件 $B$ 仍然发生的概率为 $P(B \mid A)$。根据定义
$$
P(B \mid A)=\dfrac{|AB|}{|A|}=\dfrac{P(AB)}{P(B)}
$$
称 $P(B \mid A)$ 为**条件概率**。上式移项有
$$
P(AB)=P(A) P(B \mid A)
$$
称为概率的乘法公式。

设事件 $A_1,A_2,\cdots,A_n$ 两两互斥且和事件为 $\Omega$，并且满足 $\forall 1 \le i \le n, P(A_i)>0$，则有**全概率公式**
$$
P(B)=\sum_{i=1}^n P(A_i) P(B \mid A_i)
$$

## 19.2 随机变量的数字特征

### 19.2.1 概念

对于任意 $\omega \in \Omega$，如果存在唯一的实数 $X(\omega)$ 与之对应，则称 $X$ 为**随机变量**。按照这个定义，随机变量是一个 $\Omega \to \mathbb{R}$ 的函数。

对于随机变量 $X$，其所有可能的取值为 $x_1,x_2,\cdots$，且取值集合有限，或者可以一一列举，则称 $X$ 为**离散型随机变量**。

如无特殊说明，下文讨论的随机变量均为离散型随机变量。对于连续性随机变量，需要使用微积分的知识来定义一些特征。

我们记 $p_i$ 为 $X=x_i$ 的概率，即 $p_i=P(X=x_i)$。将数列 $p_i$ 称为 $X$ 的**分布列**。则 $p_i$ 满足性质 $\sum \limits_{i \ge 1} p_i=1$。用分布列可以描述一个随机变量 $X$。

### 19.2.2 期望

对于随机变量 $X$，称它的均值 / **期望**为
$$
E(X)=\sum_{i=1}^n x_ip_i
$$
需要注意的是，只有上述求和收敛时 $E(X)$ 才存在。在 OI 中，求期望的题目期望一般都是存在的，因此下文不会讨论期望的存在性。

期望满足如下性质：

- **线性性**：对于随机变量 $X$，有 $E(aX+b)=aE(X)+b$。
- 乘法公式：对于**独立**随机变量 $X,Y$，有 $E(XY)=E(X)E(Y)$。注意，$X,Y$ 独立不是等式成立的必要条件。

### 19.2.3 方差

期望并不能反映随机变量的波动，因此我们定义了 $X$ 的**方差**为
$$
\begin{aligned}
D(X)&=\sum_{i=1}^n (x_i-E(X))^2 p_i\\
&=\sum_{i=1}^n (x_i^2 p_i-E^2(X))\\
&= E\left((X-E(X))^2\right)\\
&= E(X^2)-E^2(X)
\end{aligned}
$$
上述四个形式都是等价的，请读者注意。方差满足如下性质：

- 对于随机变量 $X$，有 $D(aX+b)=a^2D(X)$。

## 19.3 概率分布

### 19.3.1 两点分布

若随机试验 $E$ 满足 $|\Omega|=2$，则称 $E$ 为**伯努利试验**。记 $\Omega=\{0,1\}$，并用随机变量 $X$ 刻画取出的数字，设 $P(X=1)=p$。

根据概率的性质，必有 $E(X=0)=1-p$。称随机变量 $X$ 服从**两点分布**或 0—1 分布。

对于服从两点分布的随机变量 $X$，显然有：

- $E(X)=p$。
- $D(X)=p(1-p)$。

### 19.3.2 几何分布

在伯努利试验中，若 $X=0$ 称为试验失败，$X=1$ 称为试验成功，仍记单次试验成功的概率为 $p$。

进行若干次独立重复实验，直到实验成功则停止，将实验次数记为 $X$，则称随机变量 $X$ 服从**几何分布**。记作 $X \sim G(p)$。

考虑求 $X$ 的分布列。对于 $X=k$ 的情形，进行分步计数：

- 前 $k-1$ 次实验失败，概率 $(1-p)^{k-1}$。
- 第 $k$ 次实验成功，概率 $p$。

从而 $P(X=k)=(1-p)^{k-1}p$。进一步：

- $E(X)=\dfrac{1}{p}$。
- $D(X)=\dfrac{1-p}{p^2}$。

:::::success[组合证法]

直接对级数求和有
$$
\begin{aligned}
E(X) &= \sum_{k \ge 1} kp_k\\
&= \sum_{k \ge 1} kp (1-p)^{k-1}\\
&= p \sum_{k \ge 1} k(1-p)^{k-1}\\
&= p \dfrac{1}{(1-(1-p))^2}\\
&= \dfrac{1}{p}
\end{aligned}
$$
对于方差，考虑计算 $E(X^2)$ 有
$$
\begin{aligned}
E(X^2) &= \sum_{k \ge 1} k^2p_k\\
&= \sum_{k \ge 1} k^2p (1-p)^{k-1}\\
&= p \sum_{k \ge 1} k^2(1-p)^{k-1}\\
&= p \dfrac{1+1-p}{(1-(1-p))^2}\\
&= \dfrac{2-p}{p^2}
\end{aligned}
$$
从而 $D(X)=E(X^2)-E^2(X)=\dfrac{2-p}{p^2}-\dfrac{1}{p^2}=\dfrac{1-p}{p^2}$。

:::::

### 19.3.3 二项分布

将伯努利试验独立重复 $n$ 次，称为 $n$ 重伯努利试验。在这一随机试验中，记试验成功的次数为 $X$，则称随机变量 $X$ 服从**二项分布**。记作 $X \sim B(n,p)$。

二项分布的另一个组合意义是：箱子中装有若干黑球和白球，独立**放回**地摸出 $n$ 次球，将摸出黑球的次数记为随机变量 $X$。

可以用排列组合配合概率论的方法求 $X$ 的分布列。对于 $X=k$ 的情形，考虑分步计数：

- 钦定 $k$ 次试验成功，方案数 $\dbinom{n}{k}$。
- 对于成功的 $k$ 次试验，概率 $p^k$。
- 对于失败的 $n-k$ 次试验，概率 $(1-p)^{n-k}$。

于是随机变量 $X$ 的分布列 $P(X=k)=\dbinom{n}{k} p^k (1-p)^{n-k}$。进一步：

- $E(X)=np$。
- $D(X)=np(1-p)$。

:::::success[组合证法]

我们有
$$
\begin{aligned}
E(X)&=\sum_{k=0}^n k \times p_k\\
&=\sum_{k=0}^n k \dbinom{n}{k} p^k (1-p)^{n-k}\\
&= \sum_{k=1}^n n \binom{n-1}{k-1} p^k (1-p)^{n-k}\\
&= np \sum_{k=1}^n \binom{n-1}{k-1} p^{k-1}(1-p)^{n-k}\\
&= np  (p+1-p)^{n-1}\\
&=np
\end{aligned}
$$
对于方差，考虑先计算 $E\left(X(X-1)\right)$：
$$
\begin{aligned}
E(X(X-1))&=\sum_{k=0}^n k(k-1) \dbinom{n}{k} p^k (1-p)^{n-k}\\
&=\sum_{k=2}^n n(n-1) \binom{n-2}{k-2} p^k (1-p)^{n-k}\\
&=n(n-1)p^2 \sum_{k=2}^n \binom{n-2}{k-2} p^{k-2} (1-p)^{(n-2)-(k-2)}\\
&= n(n-1)p^2 (p+1-p)^{n-2}\\
&= n(n-1)p^2
\end{aligned}
$$
第二个等号利用了二维吸收恒等式 $k(k-1) \dbinom{n}{k}=n(n-1) \dbinom{n-2}{k-2}$。

由方差线性性 $E(X^2)=E(X(x-1)+X)=n(n-1)p^2+np$。代入方差公式得
$$
\begin{aligned}
D(X)&=E(X^2)-E^2(X)\\
&= n(n-1)p^2+np-n^2p^2\\
&= n^2p-np+np-n^2p^2\\
&= np(1-p)
\end{aligned}
$$
证毕。

:::::

:::::success[PGF 证法]

写出随机变量 $X$ 的 PGF
$$
\begin{aligned}
F(x)&=\sum_{k=0}^n p_k x^k\\
&= \sum_{k=0}^n \dbinom{n}{k} p^k (1-p)^{n-k} x^k\\
&= (px+1-p)^n
\end{aligned}
$$
对 $F$ 求一阶导和二阶导：
$$
\begin{aligned}
F'(x)&= np(px+1-p)^{n-1}\\
F''(x) &= n(n-1)p^2 (px+1-p)^{n-2}
\end{aligned}
$$
根据 EGF 性质即可得到
$$
\begin{aligned}
E(X)&=F'(1)\\
&=np(p+1-p)^{n-1}\\
&=np\\
D(X)&= F''(1)+F'(1)-F'^2(1)\\
&=n(n-1)p^2+np-n^2p^2\\
&=np(1-p)
\end{aligned}
$$
证毕。

:::::

### 19.3.4 超几何分布

箱子中装有 $N$ 个球，其中 $M$ 个是黑球，独立**不放回**地摸出 $n$ 次球，将摸出黑球的次数记为随机变量 $X$，则称 $X$ 服从**超几何分布**。

可以发现，在这种组合意义下，二项分布和超几何分布的区别仅在于放回和不放回的抽取方法。

可以用排列组合的方法求出 $X$ 的分布列：

- 总方案数 $\dbinom{N}{n}$。
- 从 $M$ 个黑球里取出 $k$ 个，再从 $N-M$ 个白球里取出 $n-k$ 个，由乘法原理得到合法方案数 $\dbinom{M}{k} \dbinom{N-M}{n-k}$。

因此，$X$ 的分布列为：
$$
P(X=k)=\dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}}
$$
进一步可得 $E(X)=n\dfrac{M}{N}$。

:::::success[组合证法]

我们有
$$
\begin{aligned}
E(X)&=\sum_{k=0}^n k \times p_k\\
&=\sum_{k=0}^n k \dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}}\\
&=\sum_{k=1}^n \dfrac{M\binom{M-1}{k-1}\binom{N-M}{n-k}}{\binom{N}{n}}\\
&= \dfrac{M}{\binom{N}{n}} \sum_{k=1}^n \binom{M-1}{k-1}\binom{N-M}{n-k}\\
&= \dfrac{M}{\binom{N}{n}} \sum_{i=0}^{n-1} \binom{M-1}{i} \binom{N-M}{n-1-i}\\
&= \dfrac{M}{\binom{N}{n}}  \binom{N-1}{n-1}\\
&= \dfrac{Mn!(N-n)!}{N!}\times \dfrac{(N-1)!}{(n-1)!(N-n)!}\\
&= \dfrac{nM}{N}
\end{aligned}
$$
证毕。倒数第三个等号使用了范德蒙德卷积。

:::::

:::::success[PGF 证法]

写出随机变量 $X$ 的 PGF
$$
\begin{aligned}
F(x)&=\sum_{k=0}^n p_k x^k\\
&= \sum_{k=1}^n \dfrac{\binom{M}{k} \binom{N-M}{n-k}}{\binom{N}{n}} x^k
\end{aligned}
$$
注意到 $F$ 的分子为 $(1+xy)^M (1+y)^{N-M}$ 的展开式中 $y^n$ 项的系数。因此：
$$
\begin{aligned}
\binom{N}{n} F(x) &= [y^n] \left((1+xy)^M (1+y)^{N-M}\right)
\end{aligned}
$$
将等式两边同时关于 $x$ 求偏导：
$$
\begin{aligned}
\binom{N}{n} F'(x) &= [y^n]\dfrac{\partial}{\partial x} \left((1+xy)^M (1+y)^{N-M}\right)\\
\binom{N}{n} F'(x) &= [y^n] \left(My(1+xy)^{M-1}(1+y)^{N-M}\right)
\end{aligned}
$$
所求期望为 $F'(1)$，将 $x=1$ 代入得
$$
\begin{aligned}
\binom{N}{n} F'(1) &= [y^n] \left(My(1+y)^{M-1}(1+y)^{N-M}\right)\\
&= [y^n] My(1+y)^{N-1}\\
&= M\binom{N-1}{n-1}\\
F'(1)&= \dfrac{M\binom{N-1}{n-1}}{\binom{N}{n}}=\dfrac{nM}{N}
\end{aligned}
$$
证毕。

:::::$AKB329$, '数学', array['概率', '期望', '条件概率', '概率分布'], 'col-math-combinatorics', null, 'knowledge'),
('Xesir', 'col-math-quick-pow-basic--xesir', '快速幂（基础，含光速幂） · Xesir', $AKB330$## 算法原理

计算 $a^b$ 如果直接乘，$b$ 很大的时候根本跑不动（$O(b)$ 次乘法，$b=10^{18}$ 的话直接退役）。快速幂的核心思想是：**把指数拆成二进制，边走边平方**。

比如 $a^{13} = a^{8} \times a^{4} \times a^{1}$，因为 $13 = 1101_2$。我们只需要从 $a^1$ 开始，不断平方（$a^2, a^4, a^8, \dots$），遇到二进制位为 1 的就把当前值乘进答案。

所以循环里其实是三件事：看 `y` 的最低位是不是 1（是就乘进 `res`）、把当前的 `x` 平方、把 `y` 右移一位。循环次数就是 `y` 的二进制位数，$O(\log b)$。

### 光速幂

> 有时候我们需要多次求幂次，甚至多到无法接受 $O(n\log n)$ 和 $O(n)$ 的复杂度，这时候怎么办呢？

光速幂适用于**底数 $a$ 和模数 $p$ 固定**、需要多次查询 $a^b \bmod p$ 的场合。

利用分块思想，先预处理出 $a, a^2, \dots, a^{B-1}$ 和 $a^B, a^{2B}, \dots, a^{B^2}$。显然 $B$ 取 $\sqrt p$ 时最优。

对于每个 $b$ 可以唯一分解成 $b = xB + y$（$y < B$），于是 $a^b = a^{xB} \cdot a^{y}$，这样我们就做到了 $O(\sqrt p)$ 预处理和 $O(1)$ 查询。

这个应该是求幂的极限了，比快速幂快了很多倍，不过还是快速幂应用更多。

## 核心公式 / 状态定义与转移方程

指数的二进制拆分：

$$
b = \sum_{i} b_i \cdot 2^i,\quad b_i \in \{0,1\}
$$

幂的拆分（快速幂的根据）：

$$
a^b = \prod_{i:\,b_i = 1} a^{2^i}
$$

底数递推（每次循环平方一次）：

$$
\text{gap}_i = \text{gap}_{i-1}^2 = a^{2^i}
$$

光速幂的分解（$B = \lfloor \sqrt p \rfloor$）：

$$
b = xB + y\ (0 \le y < B), \qquad a^b = a^{xB} \cdot a^{y}
$$

其中 $a^{y}$ 查第一张表，$a^{xB}$ 查第二张表，一次乘法即可出结果。

## 逐行代码解析

### 模块一：常规（递归）写法

```cpp
常规的
int ksm(int x,int y,int p){
    int res=1;
    if(y==0) return 1;
    if(y&1) res=x*ksm(x,y-1,p)%p;
    else res=ksm(x,y/2,p),res=res*res%p;
    return res;
}
```

- 第一行的「常规的」是原文留的段落标题，不是合法 C++ 语句，单独编译这段时要删掉。
- `y == 0` 直接返回 1，是递归的边界。
- `y` 是奇数：先拿掉一个 $x$，剩下 $y-1$ 是偶数，下一层会走平方分支。
- `y` 是偶数：$a^y = (a^{y/2})^2$，递归一半再平方，这就是"指数折半"。
- 递归深度是 $O(\log y)$ 层，写法直观但常数比迭代大。

### 模块二：位运算（迭代）写法

```cpp
位运算的
int ksm(int x,int y,int p){
    int res=1;
    while(y){
        if(y&1)res=res*x%p;
        x=x*x%p;
        y>>=1;
    }
    return res;
}
```

- `res` 是累积答案，初始为乘法单位元 1。
- `if(y&1)`：当前最低位为 1，就把当前的 $a^{2^i}$ 乘进答案。
- `x = x*x % p`：底数平方，从 $a^{2^i}$ 变成 $a^{2^{i+1}}$，为下一位准备。
- `y >>= 1`：右移一位，处理下一个二进制位；`y` 变成 0 时结束。
- 这种写法没有递归栈，是平时最常用的版本。

## 复杂度分析

| 版本 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 快速幂（迭代） | $O(\log b)$ | $O(1)$ |
| 快速幂（递归） | $O(\log b)$ | $O(\log b)$（递归栈） |
| 光速幂（预处理） | $O(\sqrt p)$ | $O(\sqrt p)$ |
| 光速幂（单次查询） | $O(1)$ | $O(1)$ |

快速幂的循环次数等于 $b$ 的二进制位数，每轮最多两次乘法，所以是 $O(\log b)$。光速幂是拿 $O(\sqrt p)$ 的预处理换 $O(1)$ 的查询，查询次数一多就血赚，只查一两次就亏。

## 适用场景

- **模意义下求幂**：几乎每道带"取模"的组合/数论题都会用到。
- **费马小定理求逆元**：$p$ 为质数时 $a^{-1} \equiv a^{p-2} \pmod p$，直接套快速幂。
- **矩阵快速幂**：把标量乘法换成矩阵乘法，就能 $O(k^3\log n)$ 求线性递推的第 $n$ 项。
- **光速幂**：底数和模数固定、查询量巨大（比如 $10^7$ 次）时，把 $O(\log b)$ 压成 $O(1)$。

## 常见陷阱与注意事项

1. **乘法溢出**：原文用的是 `int`，`x*x` 在 $p$ 接近 $10^9$ 时就会爆 `int`。要么开 `long long`，要么像原文那样靠 `#define int long long` 兜着；$p$ 接近 $10^{18}$ 时还得上 `__int128` 或快速乘。
2. **`p = 1` 时递归版错**：任何数模 1 都是 0，但递归版在 `y == 0` 时直接 `return 1`，`ksm(x,0,1)` 会返回 1。迭代版因为 `res` 一开始就 `% p`，反而是对的。
3. **负指数没处理**：两个版本都假设 $y \ge 0$。要支持负指数，得先求逆元再算正指数。
4. **底数为负**：`x` 为负时 `x % p` 在 C++ 里也是负的，先做 `(x % p + p) % p` 归一化。
5. **光速幂的前提**：只适合底数和模数**固定**。换一个底数就得重新预处理，这时还不如直接用快速幂。
6. **光速幂的加法写成乘法**：$a^b = a^{xB} \cdot a^{y}$ 是**相乘**，不是相加。这个笔误在推导时特别容易发生。$AKB330$, '数学', array['数学', '快速幂', '光速幂', '二进制拆分', '模运算'], null, null, 'knowledge'),
('world-needs-sunday', 'col-math-quick-pow-basic', '快速幂（基础与高精度）', $AKB331$## 算法原理

快速幂用于高效计算 $a^b \bmod q$。朴素方法是将 $a$ 连乘 $b$ 次，时间复杂度为 $O(b)$，当 $b$ 达到 $10^{18}$ 量级时完全不可行。快速幂的核心思想是利用指数的二进制拆分：将 $b$ 写成若干 $2$ 的幂之和，则 $a^b$ 可以分解为对应 $a^{2^i}$ 项的乘积，而每个 $a^{2^i}$ 都可以由前一项平方递推得到。

具体地，设 $b$ 的二进制表示为 $b = \sum_{i} b_i \cdot 2^i$（其中 $b_i \in \{0, 1\}$），则 $a^b = \prod_{i: b_i = 1} a^{2^i}$。算法维护一个"当前底数" `gap`，初始为 $a$，每轮循环将其平方得到 $a^2, a^4, a^8, \ldots$，对应二进制位的权值。同时维护"累积答案" `ans`，当 $b$ 的当前最低位为 $1$ 时，将对应的 `gap` 乘入 `ans`。每轮处理后 $b$ 右移一位，直到 $b$ 为 $0$。

整个过程中所有乘法都在模 $q$ 意义下进行，确保中间值始终小于 $q$，避免溢出。由于 $b$ 的二进制位数为 $\lfloor \log_2 b \rfloor + 1$，循环只需执行 $O(\log b)$ 次，每次做至多两次模乘运算，因此总时间复杂度为 $O(\log b)$，空间复杂度为 $O(1)$（迭代实现无需递归栈）。快速幂是数论和组合数学中最基础的工具，广泛应用于模逆元、组合数取模、矩阵快速幂等场景。

## 核心公式

指数的二进制拆分：
$$b = \sum_{i=0}^{\lfloor \log_2 b \rfloor} b_i \cdot 2^i, \quad b_i \in \{0, 1\}$$

快速幂的乘积分解：
$$a^b = \prod_{i:\, b_i = 1} a^{2^i} \pmod{q}$$

底数平方递推：
$$\text{gap}_i = \text{gap}_{i-1}^2 = a^{2^i} \pmod{q}$$

答案累积（当 $b_i = 1$ 时）：
$$\text{ans} \leftarrow \text{ans} \times \text{gap}_i \pmod{q}$$

## 逐行代码解析

### 头文件与命名空间

```cpp
#include<bits/stdc++.h>
using namespace std;
```

- `#include<bits/stdc++.h>`：一次性引入几乎所有标准库头文件，是竞赛环境的常用写法。
- `using namespace std`：省略 `std::` 前缀，让 `cin`、`cout` 等可以直接书写。

### fastpow 函数 — 边界与初始化

```cpp
long long fastpow(long long a,long long b,long long q)
{
	if(b == 0) return 1;  // a^0 = 1 的边界处理
	long long ans = 1;    // 累积答案，初始为乘法单位元
	long long gap = a;    // 当前底数，初始为 a = a^{2^0}
```

- `if(b == 0) return 1`：处理指数为 $0$ 的边界情况。实际上 `while(b)` 在 $b=0$ 时不进入，会直接返回 `ans=1`，此行可省略但保留使语义更清晰。
- `ans = 1`：乘法单位元，作为累积答案的初始值。
- `gap = a`：`gap` 始终维护 $a^{2^i} \bmod q$，其中 $i$ 为当前已处理的二进制位数；初始 $i=0$ 时 `gap = a = a^{2^0}`。

### fastpow 函数 — 主循环

```cpp
	while(b)
	{
		if(b & 1) ans = (ans * gap) % q;   // 当前最低位为 1，乘入对应 a^{2^i}
		gap = (gap * gap) % q;             // 底数平方：a^{2^i} -> a^{2^{i+1}}
		b >>= 1;                           // 右移一位，处理下一位
	}
	return ans;
}
```

- `if(b & 1) ans = (ans * gap) % q`：检查 $b$ 的最低位，为 $1$ 则把该项 $a^{2^i}$ 乘入答案；取模确保 `ans` 始终在 $[0, q)$ 范围内。
- `gap = (gap * gap) % q`：将底数从 $a^{2^i}$ 平方为 $a^{2^{i+1}}$，为下一轮做准备，是快速幂"倍增"思想的核心。
- `b >>= 1`：右移一位，丢弃已处理的最低位，使下一次 `b & 1` 检查的是更高位。
- 参数与返回值均为 `long long`：两个 `long long` 相乘最大约 $q^2 \approx 10^{18}$，仍落在 `long long` 范围（$\approx 9.2 \times 10^{18}$）内，避免溢出。

### main 函数

```cpp
int main() 
{
	long long a,b,q;
	cin >> a >> b >> q;
	cout << a << "^" << b << " mod " << q << "=" << fastpow(a,b,q);
	return 0;
}
```

- `cin >> a >> b >> q`：读入底数 `a`、指数 `b` 与模数 `q`。
- 输出格式为 `a^b mod q=` 后接 `fastpow(a, b, q)` 的结果，便于直接观察计算过程。

## 复杂度分析

循环次数等于 $b$ 的二进制位数，即 $\lfloor \log_2 b \rfloor + 1$。每次循环至多执行两次模乘运算（`ans * gap` 和 `gap * gap`），因此总时间复杂度为 $O(\log b)$。由于采用迭代而非递归实现，无需调用栈，空间复杂度为 $O(1)$。相比之下，朴素连乘需要 $O(b)$ 次乘法，当 $b = 10^{18}$ 时快速幂仅需约 $60$ 次乘法，加速比超过 $10^{16}$。

## 适用场景

模幂运算是数论与组合数学的基石。具体应用包括：费马小定理求模逆元（$a^{-1} \equiv a^{q-2} \pmod{q}$，$q$ 为质数）、组合数取模中的阶乘幂预处理、RSA 等公钥密码学中的模幂运算、以及作为矩阵快速幂的基本运算单元（将标量乘法替换为矩阵乘法即可推广）。

## 常见陷阱与注意事项

1. **中间溢出**：当 $q$ 接近 $10^9$ 时，`ans * gap` 可达 $10^{18}$，仍在 `long long` 范围内。但若 $q$ 接近 $10^{18}$，则两个 $10^{18}$ 级数相乘会溢出，需改用 `__int128` 或快速乘（类似于快速幂的加法分解）。
2. **负数指数**：本代码未处理 $b < 0$ 的情况。若需支持负指数，应先判断 $b$ 的符号，取绝对值计算后用模逆元转换。
3. **底数为负**：当 $a < 0$ 时，`a % q` 在 C++ 中可能为负数，应先做 `(a % q + q) % q` 归一化到 $[0, q)$。
4. **$q = 1$ 的退化**：任何数模 $1$ 均为 $0$，`fastpow(a, b, 1)` 应返回 $0$。代码中 `ans` 初始为 $1$ 但首次乘法后取模即变为 $0$，结果正确但需注意初始值。
5. **递归 vs 迭代**：递归写法逻辑等价但存在栈开销，在 $b$ 极大时（虽然不太可能超过 $64$ 层）无实际问题，但迭代写法常数更小、更安全。
6. **模数 $q = 0$ 会除零**：`a % q`、`ans % q` 在 $q = 0$ 时是未定义行为（除零）。本模板假设 $q \ge 2$（模意义下 $q = 1$ 退化已在第 4 条说明）；若 $q$ 可能为 0，需在入口处特判。

## 对比与扩展

与朴素 $O(b)$ 幂相比，快速幂将复杂度降至对数级，是指数运算的根本优化。与光速幂（预计算 $a^0 \sim a^S$ 和 $a^0, a^S, a^{2S}, \ldots$，通过查表 + 一次乘法实现 $O(1)$ 单次查询）相比，快速幂无需预处理但单次查询为 $O(\log b)$，适合查询次数少的场景。扩展方向包括：矩阵快速幂（将标量乘法替换为矩阵乘法，用于求解线性递推数列的第 $n$ 项）、快速乘（用类似思想实现大数取模乘法防溢出）、以及结合欧拉降幂公式处理超大指数 $b \ge \varphi(q)$ 的情形。

## 附：快速幂（高精度）——麦森数2^P−1

本算法计算 $2^P$ 并保留末 $500$ 位（即麦森数 $2^P - 1$ 的末 $500$ 位），用于解决如洛谷 P1045 麦森数问题。由于 $2^P$ 的位数可达数百位（$P \le 3.1 \times 10^6$ 时约 $10^6$ 位），远超 `long long` 的表示范围，因此必须使用高精度整数运算。算法用 `char` 数组按十进制位存储大整数（低位在前），实现"竖式乘法"函数 `mul`，再套用二进制快速幂框架进行幂运算。

高精度乘法 `mul` 采用经典的竖式算法：两个长度分别为 $n_a$、$n_b$ 的大数相乘，结果的第 $i+j$ 位累加 $A[i] \times B[j]$，最后统一进位。为控制计算量和存储，乘法中通过 `if(i + j < 500)` 截断，只保留末 $500$ 位，相当于在模 $10^{500}$ 意义下运算。由于题目只需末 $500$ 位，这种截断不会丢失所需信息，同时将每次乘法的复杂度从 $O(L^2)$（$L$ 为完整位数）降至 $O(500^2)$。

快速幂框架与基础快速幂完全一致：维护结果 $A$（初始 $1$）和底数 $B$（初始 $2$），逐位检查指数 $P$ 的二进制位，为 $1$ 时 `mul(A, B)` 并更新 $A$，每轮 `mul(B, B)` 更新 $B$，最后 $P$ 右移一位。$2^P$ 的总位数预先用对数公式 $\lfloor P \cdot \log_{10} 2 \rfloor + 1$ 算出并输出。最终 $A[0] -= 1$ 实现 $2^P - 1$（由于 $2^P$ 末位必为偶数非零，减 $1$ 不需借位传播），再逆序输出 $500$ 位。

### 核心公式

$2^P$ 的十进制位数：
$$\text{num} = \lfloor P \cdot \log_{10} 2 \rfloor + 1$$

高精度竖式乘法（截断到末 $L=500$ 位）：
$$\text{ans}[i+j] = \sum_{i+j < L} A[i] \times B[j], \quad \text{ans}[i+1] \mathrel{+}= \left\lfloor \frac{\text{ans}[i]}{10} \right\rfloor, \quad \text{ans}[i] \bmod 10$$

快速幂分解（模 $10^{500}$ 意义下）：
$$2^P = \prod_{i:\, P_i = 1} 2^{2^i} \pmod{10^{500}}$$

麦森数：
$$M_P = 2^P - 1$$

### 逐行代码解析

#### 全局变量与头文件

```cpp
#include<bits/stdc++.h>
using namespace std;
const int n = 510;
char A[n];    // 结果数组，低位在前
char B[n];    // 底数数组，低位在前
int ans[n];   // 乘法临时结果
```

- `const int n = 510`：数组开 $510$ 略大于 $500$，多出的空间用于承接进位时 `ans[i + 1]`（当 `i = 499` 时写入 `ans[500]`），避免越界。
- `char A[n]` / `char B[n]`：用 `char` 存储十进制每位数字（0~9），低位在前，符合竖式乘法从低位到高位的进位方向。
- `int ans[n]`：乘法临时结果用 `int` 而非 `char`，避免累加时超过 `char` 的 $127$ 范围。

#### mul —— 高精度竖式乘法

```cpp
// 高精度乘法：ans = tA * tB，只保留末 500 位
void mul(char tA[], char tB[])
{
	memset(ans, 0, sizeof(ans));
	int na = 500, nb = 500;
	while(!tA[na - 1]) --na;        // 跳过前导零，确定实际有效位数
	while(!tB[nb - 1]) --nb;
	for(int i = 0; i < na; i++)
	{
		for(int j = 0; j < nb; j++)
		{
			if(i + j < 500)          // 截断：只保留末 500 位
				ans[i + j] += tA[i] * tB[j];
		}
	}
	for(int i = 0; i < 500; i++)     // 统一进位
	{
		ans[i + 1] += ans[i] / 10;
		ans[i] %= 10;
	}
}
```

- `while(!tA[na - 1]) --na`：从最高位向低位扫描跳过前导零，确定实际有效位数 `na`、`nb`，减少内层循环次数；当 $B = 2^{2^i}$ 位数远小于 $500$ 时显著加速。
- `if(i + j < 500)`：截断条件。结果的第 $i+j$ 位若 $\ge 500$ 则丢弃，等价于模 $10^{500}$ 运算，高位丢弃不影响末 $500$ 位结果。
- `memset(ans, 0, sizeof(ans))`：每次必须清零，否则累加结果会被上一轮残留数据污染。
- 进位循环上界取 $500$：`ans[i + 1] += ans[i] / 10` 在 `i = 499` 时写入 `ans[500]`，落在 $n = 510$ 的数组内，不会越界。

#### fastpow —— 高精度快速幂

```cpp
// 高精度快速幂：计算 2^q，结果存入 A（末 500 位）
void fastpow(int q)
{
	if(q == 0) { A[0] = 1; return; }
	A[0] = 1;                        // 结果初值 = 1
	B[0] = 2;                        // 底数初值 = 2
	while(q)
	{
		if(q & 1)                     // 当前位为 1，A = A * B
		{
			mul(A, B);
			for(int i = 0; i < 500; i++) A[i] = ans[i];
		}
		mul(B, B);                    // B = B * B
		for(int i = 0; i < 500; i++) B[i] = ans[i];
		q >>= 1;
	}
}
```

- `A[0] = 1`（结果初值）、`B[0] = 2`（底数初值）：与标量快速幂框架完全一致。
- `if(q & 1)`：当前二进制位为 $1$ 时执行 `mul(A, B)` 并把 `ans` 拷回 `A`，实现 `A = A * B`。
- `mul(B, B)`：每轮底数平方并拷回 `B`，`q >>= 1` 右移检查下一位。
- `if(q == 0) { A[0] = 1; return; }`：单独处理 $2^0 = 1$ 的边界，避免进入循环。

#### main —— 位数计算与输出

```cpp
int main()
{
	int q;
	scanf("%d", &q);
	int num = q * log10(2) + 1;      // 计算总位数
	printf("%d\n", num);
	fastpow(q);
	A[0] -= 1;                       // 2^P - 1，末位必非零无需借位
	reverse(A, A + 500);             // 逆序：高位在前
	for(int i = 0; i < 500; i++)
	{
		if(i && i % 50 == 0) putchar('\n');  // 每 50 位换行
		putchar(A[i] + 48);
	}
	return 0;
}
```

- `int num = q * log10(2) + 1`：利用 $\lfloor P \cdot \log_{10} 2 \rfloor + 1$ 计算 $2^P$ 的总位数并先输出。
- `A[0] -= 1`：$2^P$ 末位必为 $2, 4, 8, 6$ 循环、始终非零，减 $1$ 不需借位，直接得到 $2^P - 1$。
- `reverse(A, A + 500)`：乘法低位在前，输出时逆序为高位在前。
- 输出循环每 $50$ 位换行（`i % 50 == 0`），数字转字符用 `A[i] + 48`。

### 复杂度分析

每次高精度乘法 `mul` 的双重循环为 $O(na \cdot nb)$，最坏情况下 $na = nb = 500$，故单次乘法为 $O(500^2) = O(L^2)$（$L = 500$）。快速幂循环次数为 $P$ 的二进制位数 $O(\log P)$，每轮至多两次乘法，因此总时间复杂度为 $O(L^2 \cdot \log P)$。空间上 `A`、`B`、`ans` 各为 $O(L)$，总空间复杂度为 $O(L)$。对于 $P = 3.1 \times 10^6$，$\log P \approx 22$，总乘法约 $44$ 次，每次 $250000$ 次基本运算，总计约 $10^7$ 量级，可在时限内完成。

### 适用场景

超大整数幂运算、麦森数/梅森素数末位问题、位数远超 `long long` 的大数幂问题，以及模运算无法承载（需完整十进制表示）的高精度计算场景。

### 常见陷阱与注意事项

1. **位数公式精度**：`q * log10(2)` 使用浮点运算，当 $P$ 极大时浮点误差可能导致位数差 $1$。更安全的做法是用整数模拟或预留 $\pm 1$ 的容差。
2. **截断位置**：`if(i + j < 500)` 截断在第 $500$ 位。若题目要求保留不同位数，需同步修改截断条件和进位循环上界，否则进位丢失导致结果错误。
3. **`A[0] -= 1` 的前提**：此操作仅在底数为 $2$ 时安全（末位非零）。若推广到其他底数，末位可能为 $0$，减 $1$ 会触发借位传播，需实现完整的高精度减法。
4. **前导零跳过的边界**：`while(!tA[na - 1]) --na` 当所有位为零时 `na` 会减到 $0$ 甚至负数（若数组全零），需确保至少保留 $1$ 位。
5. **数组清零**：`mul` 中 `memset(ans, 0, sizeof(ans))` 每次必须清零，否则累加结果被上一轮残留数据污染。
6. **`char` 类型的乘法溢出**：`tA[i] * tB[j]` 最大为 $9 \times 9 = 81$，累加多次后在进位前可能超过 `char` 范围（$127$）。代码中 `ans` 为 `int` 数组避免了此问题，但需注意 `char` 数组参与乘法时类型提升。

### 对比与扩展

与模意义下的标量快速幂相比，高精度快速幂将标量乘法替换为 $O(L^2)$ 的高精度竖式乘法，适用于需要完整十进制表示的场景。若使用 FFT/NTT 加速大数乘法，可将单次乘法降至 $O(L \log L)$，在 $L$ 很大时（如 $10^5$ 位以上）优势显著。扩展方向包括：支持任意底数的高精度快速幂（需完整减法实现 $a^b - c$）、结合 Miller-Rabin 素性测试判断麦森数是否为梅森素数、以及用高精度快速幂实现大数 RSA 加解密等。$AKB331$, '数学', array['数学', '快速幂', '模幂', '数论', '二进制拆分'], null, null, 'knowledge'),
('stripe-python', 'col-math-sequences--stripe-python', '数列：等差、等比与递推求和 · stripe-python', $AKB332$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 7.2 数列

在加法 & 乘法原理推公式时，常会用到数列求和相关知识，故在此补充。

### 7.2.1 等差数列

等差数列是指满足递推式 $a_i-a_{i-1}=d$ 的数列，其中 $d$ 为常数，称作公差。由递推公式逐级写出：

$$
a_2-a_1=d\\
a_3-a_2=d\\
\cdots\\
a_{i}-a_{i-1}=d
$$

然后两边相加，得

$a_i=a_1+(i-1)d$此为等差数列通项公式。移项可得公差计算方法

$d=\dfrac{a_i-a_1}{i-1}$等差数列求和是 OI 数学题常用方法。下面我们对其作推导。设

$S=a_1+a_2+\cdots+a_n$将其复制一份倒序相加

$$
S=a_n+\cdots+a_2+a_1\\
2S=(a_1+a_n)+(a_2+a_{n-1})+\cdots+(a_n+a_1)=n(a_1+a_n)
$$

因而

$S=\dfrac{a_1+a_n}{2}=na_1+\dfrac{dn(n-1)}{2}$### 7.2.2 等比数列

等差数列是指满足递推式 $\dfrac{a_i}{a_{i-1}}=q$ 的数列，其中 $q$ 为常数，称作公比。类似等差数列的方法可得其递推公式

$a_i=a_1 \times q^{i-1}$仍然来推求和公式。设

$S=a_1+qa_1+q^2a_1 + \cdots + q^na_1$采用错位相减法

$$
qS=qa_1+q^2a_1+q^3a_1+\cdots+q^{n+1}a_1\\
qS-S=q^{n+1}a_1-a_1
$$

因此

$S=\dfrac{(q^{n+1}-1)a_1}{q-1}$#### 分治求和法

如果等比数列在模意义下求和，就需要求 $q-1$ 的逆元，而若 $q-1$ 无逆元，则无法套公式。这里介绍一种使用广义快速幂的分治求和方法，复杂度 $O(\log^2 n)$。

记 $sum(k,n)=1+k+k^2+\cdots+k^{n-1}$。若 $n$ 为偶数，将 $sum(k,n)$ 分为 $1+k+k^2+\cdots+k^{n/2-1}$ 与 $k^{n/2}+\cdots+k^{n-2}+k^{n-1}$ 两部分，则

$$
\begin{aligned}
sum(k,n)&=1+k+k^2+\cdots+k^n \\
&= 1+k+k^2+\cdots+k^{n/2-1}+k^{n/2}+\cdots+k^{n-2}+k^{n-1} \\
&= 1+k+k^2+\cdots+k^{n/2-1} + k^{n/2}(1+k+k^2+\cdots+k^{n/2-1}) \\
&= (k^{n/2}+1) (1+k+k^2+\cdots+k^{n/2-1}) \\
&= (k^{n/2}+1) \times sum(k,n/2)
\end{aligned}
$$

而若 $n$ 为奇数，则 $n-1$ 为偶数，$sum(k,n)=sum(k,n-1) + k^{n-1}$。递归出口 $sum(k,1)=1$。

```cpp
int sum(int k, int n) {
	if (n == 1) return 1;
	if (n & 1) return (sum(k, n - 1) + mpow(k, n - 1)) % p;
	return sum(k, n >> 1) * (mpow(k, n >> 1) + 1) % p;
}
```

自己造的板子：[U588919](https://www.luogu.com.cn/problem/U588919)。

### 7.2.3 幂数列

这里再补充一些幂数列求和的结论。幂数列是形如 $a_i=i^k$ 的数列，$k$ 为正整数。

**结论 1：**

$\sum_{i=1}^{n} i = 1+ 2+3+\cdots+n=\dfrac{n(n+1)}{2}$等差数列求和的最简单情况，相当常用。$\dfrac{n(n+1)}{2}$ 这个东西叫做三角形数。

**结论 2：**

$\sum_{i=1}^{n}i^2 = 1^2+2^2+3^2+\cdots+n^2=\dfrac{n(n+1)(2n+1)}{6}$用数学归纳法证。显然 $n=1$ 时是成立的。考虑 $n=k$ 时等式成立，只需证 $n=k+1$ 时等式也成立，即

$$
1^2+2^2+3^2+\cdots+k^2+(k+1)^2
=\dfrac{k(k+1)(2k+1)}{6}+\dfrac{6(k+1)^2}{6}
=\dfrac{(k+1)(k+3)(2k+3)}{6}
$$

因此结论正确。平方数列求和的这个结果 $\dfrac{n(n+1)(2n+1)}{6}$ 又叫做四角锥数。

**结论 3：**

$\sum_{i=1}^{n} i^3=1^3+2^3+3^3+\cdots+n^3=(1+2+3+\cdots+n)^2=[\dfrac{n(n+1)}{2}]^2$更高次幂的求和一般不常用。一般地，有

$\sum_{i=0}^{n-1} i^m=\dfrac{1}{m+1}\sum_{i=0}^{m} C_{m+1}^k B_k n^{m+1-k}$其中 $B_k$ 是[伯努利数](https://oi-wiki.org/math/combinatorics/bernoulli/)。这是一个讲的很好的[视频](https://www.bilibili.com/video/BV1GZRXYjEGK/)。

下文第 23 章使用 Lagrange 插值法，也可以在 $O(m)$ 的复杂度内计算上式。

### 7.2.4 斐波那契数列

定义 $fib_i=fib_{i-1}+fib_{i-2}$。

特别地，$fib_0=1,fib_1=1$。直接做可以 $O(n)$ 递推。下文第 22 章介绍了使用矩阵快速幂求其第 $n$ 项的 $O(\log n)$ 做法。

熟知地，有通项公式

$fib_n=\dfrac{1}{\sqrt{5}}( (\dfrac{1+\sqrt{5}}{2})^n-(\dfrac{1-\sqrt{5}}{2})^n)$对于斐波那契数列数列，还有几条结论：

1. 前缀和：

$\sum_{i=0}^n fib_n=fib_{n+2}-1\\$1. 平方和：
$\sum_{i=0}^n {fib_n}^2=fib_{n} \times fib_{n+1}$
3. 卡西尼恒等式：

$fib_{n+1}\times fib_{n-1}-{fib_n}^2=(-1)^n$斐波那契数列的增长速度是指数级的。

## 附：数列专题笔记（stripe-python）

## 数列

## 7.1 数学归纳法

考虑证明命题 $P(n)$ 对 $n \ge n_0$ 的一切正整数 $n$ 都成立。给出如下证明方法：

- 证明 $P(n_0)$ 成立。
- 对于 $k \ge n_0$ 的 $k$，证明若 $P(k)$ 成立，则 $P(k+1)$ 成立。$P(k)$ 成立的条件称作**归纳假设**。

这一方法叫做第一数学归纳法，简称为**数学归纳法**。 

下面再给出另一种归纳法，称作第二数学归纳法：

- 证明 $P(n_0)$ 成立。
- 对于 $k \ge n_0$ 的 $k$，证明若 $P(n_0) \sim P(k)$ 全部成立，则 $P(k+1)$ 成立。

请读者体会两种方法的正确性所在。下面给出一些例题，帮助读者理解上述概念。

例题一：求证 $\sum \limits_{i=1}^n i^2=\dfrac{n(n+1)(2n+1)}{6}$。

:::::success[题解]

考虑第一数学归纳法，令命题 $P(n)$ 为 $\sum \limits_{i=1}^n i^2=\dfrac{n(n+1)(2n+1)}{6}$。

当 $n=1$ 时，等式左侧为 $1$，右侧为 $\dfrac{1 \times 2 \times 3}{6}=1$，故 $P(1)$ 成立。

当 $n=k$ 时，假定 $P(k)$ 成立，于是
$$
\begin{aligned}
P(k+1) &\iff \sum_{i=1}^{k+1} i^2=\dfrac{(k+1)(k+2)(2k+3)}{6}\\
&\iff (k+1)^2+\sum_{i=1}^k i^2=\dfrac{(k+1)(k+2)(2k+3)}{6}\\
&\iff 6(k+1)^2 + k(k+1)(2k+1)=(k+1)(k+2)(2k+3)\\
&\iff 2k^2+7k+6=(k+2)(2k+3)
\end{aligned}
$$
显然成立。证毕。

::::::

例题二：记数列 $a_n$ 满足 $a_1=3$，且 $a_{n+1}=3a_n-4n$，求 $a_n$ 的通项公式。

:::::success[题解]

$a_n=2n+1$。证明考虑归纳法：

- $n=1$ 显然成立。

- 当 $n=k$ 时，假定 $a_k=2k+1$ 成立，于是

$$
\begin{aligned}
a_{k+1}&=3a_k-4k\\
&=3(2k+1)-4k\\
&=2(k+1)+1
\end{aligned}
$$

:::::

例题三：求证 $n$ 个点的树必然有 $n-1$ 条边。

:::::success[题解]

考虑第二数学归纳法：

- $n=1$ 时，原命题显然成立。

- $n=k$ 时，可以将原树断开一条边，分解成大小为 $k_1$ 和 $k_2$ 的两棵子树，其中 $1 \le k_1,k_2 \le k$。由归纳假设，原树的边数为 $k_1-1+k_2-1+1=k-1$。 

:::::

## 7.2 等差 / 等比数列

对于数列 $\{a_n\}$，若其满足递推公式 $a_{n+1}-a_n=d$，则称 $\{a_n\}$ 为**等差数列**，$d$ 为公差，$a_1$ 为首项。

记 $S_n=\sum \limits_{i=1}^n a_i$，则等差数列具有如下性质：

- 通项公式：$a_n=a_1+(n-1)d$。
- 前缀和：$S_n=\dfrac{a_1+a_n}{2}n=a_1n+\dfrac{n(n-1)}{2}d$。
- 由以上两个基本公式得到的推论：
  - $a_n=a_m+(n-m)d$。
  - 若 $m+n=p+q$，则 $a_m+a_n=a_p+a_q$。
  - $S_{2n-1}=(2n-1)a_n$。
- 若干个等差数列的线性组合还是等差数列。

这些结论的证明很简单，这里不给出了。

对于数列 $\{a_n\}$，若其满足递推公式 $\dfrac{a_{n+1}}{a_n}=q$，则称 $\{a_n\}$ 为**等比数列**，$q$ 为公比，$a_1$ 为首项。

仍记前缀和为 $S_n$，并且忽略 $q=1$ 的平凡情形。我们有：

- 通项公式：$a_n=a_1 \times q^{n-1}$。
- 前缀和：$S_n=\dfrac{q^n-1}{q-1}a_1$。
- 由以上两个基本公式得到的推论：
  - $a_n=a_m \times q^{n-m}$。
  - 若 $m+n=p+q$，则 $a_m\times a_n=a_p\times a_q$。

下面给出等比数列前缀和的证明：

:::::success[证明]

根据定义，我们有
$$
\begin{aligned}
S_n&=a_1+a_1q+a_1q^{2}+\cdots +a_1 q^{n-1}\\
qS_n&=\phantom{a_1}+a_1q+a_1q^2+\cdots+a_1q^{n-1}+a_1 q^n
\end{aligned}
$$
两式相减得 $(q-1)S_n=(q^n-1)a_1$，即证 $S_n=\dfrac{q^n-1}{q-1} a_1$。

:::::

等比数列的结论被用来解决一些重要的通项问题。

## 7.3 线性常系数齐次递推

### 7.3.1 不动点

问题：给出递推公式 $a_{n+1}=pa_n+q$，其中 $p \ne 0 \land p\ne 1$，求 $a_n$ 的通项公式。

:::::success[题解]

构造**不动点** $x$ 满足 $x=px+q$，解得 $x=\dfrac{q}{1-p}$。

对递推式进行变形：
$$
\begin{aligned}
a_{n+1}&=pa_n+q\\
a_{n+1}-x &= pa_n+q-x\\
a_{n+1}-x &= p(a_n-x)
\end{aligned}
$$
记 $b_n=a_n-x$，上式给出 $b_{n+1}=pb_n$，由等比数列通项公式得 $b_n=b_1 p^{n-1}$。因此 $a_n$ 的通项为
$$
a_n=(a_1-x) p^{n-1}+x
$$
其中 $x=\dfrac{q}{1-p}$。

:::::

### 7.3.2 特征根

问题：给出递推公式 $a_{n+1}=pa_n+qa_{n-1}$，其中 $p,q \ne 0$，求 $a_n$ 的通项公式。

:::::success[题解]

类比一阶线性递推的解法，我们猜想这个数列的本质也是某种等比数列。

构造**特征根** $x$ 满足 $x^{n+1} =px^n+qx^{n-1}$，化简得 $x^2-px-q=0$。将这一方程称为数列的**特征方程**。

由 $\Delta=p^2+4q$ 判定方程根的分布后，将问题分为三类求解：

- 若 $\Delta>0$，可解得方程的两根 $x_1,x_2$。

  由韦达定理 $p=x_1 +x
  _2 \land q=-x_1x_2$，代入递推式得 $a_{n+1}=(x_1+x_2)a_n-x_1x_2 a_{n-1}$，即 $a_{n+1}=x_1a_n+x_2a_n-x_1x_2a_{n-1}$。继续变形：

  - $a_{n+1}-x_1a_n=x_2(a_n-x_1a_{n-1})$。令 $b_n=a_n-x_1 a_{n-1}$，则上式给出 $b_n=x_2b_{n-1}$，得 $b_n=(a_2-x_1a_1)x_2^{n-2} $，记为 $\tt{①}$ 式。
  - $a_{n+1}-x_2a_n=x_1(a_n-x_2a_{n-1})$。令 $c_n=a_n-x_2a_{n-1}$，则上式给出 $c_n=x_1 c_{n-1}$，得 $c_n=(a_2-x_2a_1)x_1^{n-2}$，记为 $\tt{②}$ 式。

  记常数 $C_1=x_2^{-2}(a_2-x_1a_1), C_2=x_1^{-2}(a_2-x_2a_1)$，考虑消去 $a_{n-1}$。

  将 $x_2 \times {\tt{①}}-x_1 \times \tt{②}$ 得 $(x_2-x_1)a_n=C_1 x_2^{n+1}-C_2 x_1^{n+1}$。移项即可解出 $a_n$。

  直接写出通解过于复杂，我们不妨给出 $a_n=Ax_1^n+Bx_2^n$ 的形式，其中 $A,B$ 是一个常数。在实际应用中，根据这个形式可以较为快速地得到 $A,B$。

- 若 $\Delta=0$，方程有两个相等的实数根 $x_0$。

  由韦达定理 $p=2x_0 \land q=-x_0^2$，代入递推式得 $a_{n+1}=2x_0a_n+x_0^2a_{n-1}$。

  移项整理易知 $a_{n+1}-x_0a_n=x_0(a_n-x_0a_{n-1})$，令 $b_n=a_{n+1}-x_0a_n$，上式给出 $b_n=x_0 b_{n-1}$，得 $b_n=(a_2-x_0a_1)x_0^{n-1}$。

  代回定义式后，将等式两边同时除以 $x_0^n$ 得 $\dfrac{a_n}{x_0^n}-\dfrac{a_{n-1}}{x_0^{n-1}}=\dfrac{a_2-x_0a_1}{x_0^2}$。

  记 $c_n=\dfrac{a_n}{x_0^n}$ 且 $B=\dfrac{a_2-x_0a_1}{x_0^2}$，可得 $c_n-c_{n-1}=B$。由等差数列通项公式 $c_n=c_1+(n-1)B$。记 $A=c_1-B$ 得 $c_n=A+Bn$。

  代回 $c_n$ 的定义式，最终我们得到 $a_n=(A+Bn)x_0^n$ 的形式，其中 $A,B$ 是一个常数。

- 若 $\Delta<0$，方程有两个共轭虚根，记其中一解为 $re^{i \theta}$。

  这里的推导比较复杂，我们直接给出结论：$a_n=r^n(A \cos n \theta + B \sin n \theta)$，其中 $A,B$ 是一个常数。

:::::

一般地，对于数列 $a_n$，若其满足
$$
a_n+C_1a_{n-1}+C_2a_{n-2}+\cdots+C_k a_{n-k}=0
$$
且 $C_1 \sim C_k$ 和 $a_1 \sim a_k$ 是常数，则称 $a_n$ 满足 $k$ 阶线性常系数齐次递推。

使用 OGF 的观点，可以考虑构造**特征多项式**
$$
C(x)=x^k+C_1 x^{k-1}+\cdots+C_{k-1}x+C_{k}=x^k+\sum_{i=1}^k C_i x^{k-i}
$$
并且仍分 $C(x)$ 无重根，有重根，有共轭复根的情形讨论。通解超出了 OI 的需要，感兴趣的读者请自行查阅资料。

### 7.3.3 斐波那契数列

斐波那契数列 $F_n$ 由如下递推关系定义
$$
F_n=F_{n-1}+F_{n-2}
$$
边界情况为 $F_0=0, F_1=1, F_2=1$。

斐波那契是特殊的二阶线性常系数齐次递推，因此我们可以用特征根的方法求通项：

:::::success[推导]

构造特征根 $x$ 满足 $x^2-x-1=0$。解得 $x_1=\dfrac{1 + \sqrt{5}}{2},x_2=\dfrac{1 - \sqrt{5}}{2}$。

根据二阶齐次线性递推的结论，可以设通项为 $F_n=Ax_1^n +Bx_2^n$。只需确定常数 $A,B$。

- 当 $n=0$ 时，$F_0=A+B=0$。

- 当 $n=1$ 时，$F_1=Ax_1+Bx_2=1$。

解方程组知 $A=\dfrac{\sqrt{5}}{5}, B=-\dfrac{\sqrt{5}}{5}$。

:::::

得到通项公式为
$$
F_n=\dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1+\sqrt{5}}{2}\right)^n-\left(\dfrac{1-\sqrt{5}}{2}\right)^n\right)
$$
在 OI 中，斐波那契数往往需要在 $\mathbb{Z}_p$ 中计算。如果 $5$ 在模 $p$ 意义下没有二次剩余，我们还需要扩域，即引入 $i$ 并强行令 $i^2 \equiv 5 \pmod p$，然后用形如 $a+bi$ 的数进行求解。复杂度瓶颈在于求 $n$ 次方。

下面给出一些与斐波那契相关的组合恒等式，也可以称之为 $F_n$ 的性质：

- Cassini 恒等式：

$$
F_{n-1}F_{n+1}-F_n^2=(-1)^n
$$

- 加法公式：

$$
F_{m+n}=F_{m+1}F_n+F_mF_{n-1}
$$

- GCD 性质：

$$
F_{\gcd(n,m)}=\gcd(F_n, F_m)
$$

- Zeckendorf 定理：任意自然数 $n$ 可以被唯一表示为若干不相邻斐波那契数的和，即

$$
n=F_{i_1}+F_{i_2}+\cdots+F_{i_k}\\
$$

将斐波那契数作为底数，就得到又一种记数法。Zeckendorf 定理指出，一个自然数具有唯一的**斐波那契编码**。

求编码的过程是朴素贪心。每轮中，我们找到不超过 $n$ 的最大斐波那契数 $F_i$，将 $i$ 加入编码并令 $n \gets n-F_i$。解码直接相加即可。

斐波那契编码的长度为 $O(\log n)$ 级别。在一些构造题中，使用斐波那契编码会比二进制编码更有优势。

## 7.5 多边形数

**三角形数** $P_3(n)$ 的几何意义是下图中第 $n$ 个图形的点数。

![](https://cdn.luogu.com.cn/upload/image_hosting/07va9kww.png)

根据几何直观，容易得到递推式 $P_3(n)=P_3(n-1)+n$。由累加法求和即得通项 $P_3(n)=\dfrac{n(n+1)}{2}$。

自然地，将图形变成正方形，就得到了**四边形数** $P_4(n)$ 的几何意义：

![](https://cdn.luogu.com.cn/upload/image_hosting/g8o28c14.png)

递推式 $P_4(n)=P_4({n-1})+2n-1$，通项式 $P_4(n)=n^2$。因此四边形数又被称为平方数列。

类似地还有**五边形数**：递推式 $P_5(n)=P_5(n-1)+3n-2$，通项式 $P_5(n)=\dfrac{n(3n-1)}{2}$。

将 $P_5$ 的定义域由 $\mathbb{N}^{+}$ 扩展到 $\mathbb{N}$，仍然沿用通项式计算，称这样的 $P_5(n)$ 为**广义五边形数**。在 $n=1,-1,2,-2,3,-3,\cdots$ 时，五边形数数列为 $1,2,5,7,12,15,22,26,\cdots$。

一般地，我们有 $k$ 边形数 $P_k(n)$，其满足：

- 递推式 $P_k(n)=P_k(n-1)+(k-2)(n-1)+1$。
- 通项式 $P_k(n)=\dfrac{(k-2)n^2-(k-4)n}{2}=(k-2)P_3(n-1)+n$。

**费马多边形数定理**指出，每个正整数都可以表示为最多 $k$ 个 $k$ 边形数的和。

一个特殊情形是**拉格朗日四平方和定理**，即每个正整数都可以表示为四个完全平方数的和。

## 7.6 调和级数

调和级数是 OI 中常见的数列。记
$$
H_n=\sum_{i=1}^n \dfrac{1}{i}
$$
数列 $H_n$ 被称作**调和级数**。随着 $n \to +\infty$，$H_n \to +\infty$，即 $H_n$ 发散，这是相当经典的结论。事实上，$H_n$ 的级别为 $O(\log n)$。

使用微积分的方法，可以得到结论：$\sum \limits_{i=1}^n H_i=O(n \log n)$。考虑如下流程的算法：

```cpp line-numbers
for (int i = 1; i <= n; i++)
    for (int j = 1; j <= n; j += i);
```

根据上述结论，该算法的复杂度为 $O(n \log n)$ 级别，称这一技巧为调和型枚举。

对于和式 $\sum \limits_{i=1}^n \frac{1}{i^k}$，可以证明其收敛当且仅当 $k>1$。取 $k=1$ 即为调和级数，取 $k=2$ 则得到著名的 Basel 问题：
$$
\sum_{i \ge 0} \dfrac{1}{i^2}=\dfrac{\pi^2}{6}
$$$AKB332$, '数学', array['数列', '等差数列', '等比数列', '递推'], 'col-math-oi-foundations', null, 'knowledge'),
('Xesir', 'col-math-set-binary--xesir', '集合与二进制 · Xesir', $AKB333$## 算法原理

你有没有想过：**一个整数怎么表示一个集合？**

答案是：用它的二进制位。第 $i$ 位为 1 表示元素 $i$ 在集合中，为 0 表示不在。

比如 $n=5$，二进制是 `101`，就表示集合 $\{0, 2\}$（从第 0 位开始数）。这种表示方法叫**二进制集合**，在状压 DP 中极其常用。

它好用的原因很直接：一个整数只有几十位，却能一次性表达"哪些元素被选了"这种全局状态；而"加一个元素""删一个元素""查一个元素在不在"全部退化成一两条位运算指令，比开一个 `bool` 数组快得多，也省得多。

> ~~我在状压 DP 是不是已经讲过了来着~~

## 核心公式 / 状态定义与转移方程

设 `S` 是一个二进制集合，$i$ 是元素编号：

- 判断元素 $i$ 是否在集合 `S` 中：`(S >> i) & 1`
- 把元素 $i$ 加入集合：`S | (1 << i)`
- 把元素 $i$ 从集合中删除：`S & ~(1 << i)`
- 把元素 $i$ 的状态取反：`S ^ (1 << i)`
- 集合大小（元素个数）：`__builtin_popcount(S)`
- 最低位元素：`__builtin_ctz(S)`，也就是 `lowbit(S)` 对应的下标

**枚举子集**的经典写法是

```
for (int sub = S; sub; sub = (sub - 1) & S)
```

它的正确性来自这一步转移：`(sub - 1) & S` 得到的恰好是"比 `sub` 小的、`S` 的最大子集"。把 `sub` 减 1 会让最低的那个 1 变成 0、它下面的位全变成 1，再与上 `S` 就把不属于 `S` 的位清理掉了。

## 逐行代码解析

### 模块一：集合的三个基本操作

```cpp
bool in   = (S >> i) & 1;      // 元素 i 在不在
int  add  = S | (1 << i);      // 加入 i
int  del  = S & ~(1 << i);     // 删除 i
```

- `(S >> i) & 1`：把第 `i` 位移到最低位，与 1 得到 0/1。也可以写成 `(S >> i) % 2`，但没必要。
- `S | (1 << i)`：第 `i` 位或上 1，其它位不动。重复加入同一个元素不会有副作用。
- `S & ~(1 << i)`：`~(1 << i)` 是"除了第 `i` 位全是 1"的掩码，与一下就把第 `i` 位清了。删除一个本来就不在的元素同样安全。

### 模块二：枚举 `S` 的所有子集

```cpp
for (int sub = S; sub; sub = (sub - 1) & S) {
    // 此时 sub 是 S 的一个非空子集
}
```

- 初始 `sub = S`，第一轮处理的是"全集自己"。
- `(sub - 1) & S` 是递减地取下一个子集，走到 `sub = 0` 时循环结束。
- 循环条件写成 `sub` 而不是 `sub >= 0`，是因为子集按这个顺序枚举到 0 就没了；如果**需要处理空集**，要单独在循环外补一次。
- 注意这里枚举的是"子集"，不是"子序列"——顺序无关，只和选没选有关。

## 复杂度分析

- 枚举一个 $k$ 元集合的所有子集，一共 $2^k$ 个，每个 $O(1)$ 处理，所以是 $O(2^k)$。
- 如果对所有 $2^n$ 个集合都枚举一遍子集，总次数是 $\sum_{S \subseteq U} 2^{|S|} = 3^n$（每个元素有"不在 `S` 里 / 在 `S` 但不在 `sub` 里 / 在 `sub` 里"三种状态），这就是子集 DP 里常见的 $O(3^n)$。
- 空间上，一个集合只用一个整数存，$O(1)$；如果是状压 DP，则是 $O(2^n)$ 的状态数组。

## 适用场景

- **状压 DP**：棋盘覆盖、Hamilton 路径、TSP 这类"选没选过"的问题，状态直接就是一个整数。
- **子集枚举**：在子集 DP（SOS DP）、集合划分、容斥里反复出现。
- **位掩码优化**：把一个 $n \le 20$ 左右的 `bool` 数组压成一个 `int`，减少常数和内存。
- **状态压缩搜索**：BFS/DFS 去重时用整数当 `visited` 标记。

## 常见陷阱与注意事项

1. **下标从 0 还是从 1 开始**：二进制集合天然从第 0 位开始编号，而题目里的元素常常是 $1 \sim n$。要么统一减 1，要么整体左移一位，千万别两边混着用。
2. **最高位溢出**：`1 << i` 在 `i` 达到 31 时溢出 `int`，元素个数超过 30 就别用 `int` 了，换 `long long` 或 `bitset`。
3. **`~` 的类型问题**：`S & ~(1 << i)` 里 `~` 得到的是负数，与上 `int` 是有定义的，但如果 `S` 是 `unsigned` 或 `long long`，掩码要相应写 `~(1u << i)`、`~(1LL << i)`。
4. **枚举子集时漏掉空集**：`for (sub = S; sub; sub = (sub - 1) & S)` 不含 `sub = 0`，需要空集的场合必须单独处理。
5. **`S ^ (1 << i)` 不是"删除"**：异或只在该位本来就是 1 时才等价于删除，元素不存在时它会变成"加入"。删除请老实用 `& ~`。
6. **集合大小别手写循环**：`__builtin_popcount` 是单条指令，比自己 `while` 数位快，而且不容易写错。$AKB333$, '数学', array['数学', '二进制', '集合', '状压', '子集枚举'], 'col-math-oi-foundations', null, 'knowledge'),
('Xesir', 'col-math-sieve--xesir', '筛法：埃氏筛与线性筛 · Xesir', $AKB334$## 算法原理

如果我们想知道**小于等于 $n$ 的所有素数**，一个一个判断显然太低效了。这时候就需要筛法。

### 埃拉托斯特尼筛法（埃氏筛）

这是最经典的筛法，思路简单得离谱：

> **如果 $x$ 是合数，那么 $x$ 的倍数也一定是合数。**

所以我们从小到大遍历每个数，如果它还没被标记成合数，那它就是素数；然后把它的所有倍数都标记成合数。

注意内层循环从 $i^2$ 开始——因为比 $i$ 小的倍数早就被更小的素数筛过了。比如 $i = 5$ 时，$5 \times 2$、$5 \times 3$、$5 \times 4$ 分别被 2、3、2 筛掉了，从 $5 \times 5 = 25$ 开始才有意义。

埃氏筛的时间复杂度是 $O(n \log\log n)$，已经非常优秀了。但它有一个小问题：**每个合数会被标记多次**。比如 12 会被 2、3 各标记一次。

### 线性筛（欧拉筛）

有没有办法让**每个合数只被标记一次**？答案是有——**线性筛**（也叫欧拉筛）。

核心思想：**每个合数只被它的最小质因子筛掉一次**。

当 `i % pri[j] == 0` 时 break，保证了每个合数只被它的最小质因子筛掉。时间复杂度严格 $O(n)$。

线性筛不仅能筛素数，还能顺便算出**欧拉函数**、**莫比乌斯函数**、**约数个数**等一系列数论函数，是竞赛中的万能工具。

事实上，任意具有积性的函数都可以被线性筛求出。原文还给了一个**集成式的线性筛模板（网赛用）**，一些常见积性函数的求法都在里面：`oph` 是欧拉函数、`eph` 是因数和、`d` 是因数个数、`mo` 是莫比乌斯函数，`cnt` 和 `low` 是求约数和用的辅助数组（分别记最小质因子的指数、最小质因子等比数列和 $1+p+\dots+p^k$）。

在一些数论构造题中，也常常需要把式子转换成一些积性函数来求解。所以**掌握线性筛处理积性函数的原理比背板子更重要**。

## 核心公式 / 状态定义与转移方程

**埃氏筛的标记规则**：对每个素数 $i$，把 $i^2, i^2 + i, i^2 + 2i, \dots$ 标为合数。

$$
\text{is\_prime}[j] \leftarrow \text{false}, \qquad j = i^2,\ i^2 + i,\ i^2 + 2i,\ \dots \le n
$$

**线性筛的转移**（$p_j$ 是质数表里的第 $j$ 个质数）：

$$
vis[i \cdot p_j] \leftarrow 1,\quad \text{若 } p_j \mid i \text{ 则立刻 break}
$$

这条 break 的意义是：当 $p_j \mid i$ 时，$p_j$ 已经是 $i$ 的最小质因子，再往后乘更大的质数，最小质因子仍然是 $p_j$，那些数会由 $i$ 的某个倍数在别处筛掉，所以这里停手，保证每个合数只被筛一次。

**模板里几个积性函数的递推**（设 $p = p_j$）：

- 欧拉函数：$p \mid i$ 时 $\varphi(ip) = \varphi(i)\cdot p$；否则 $\varphi(ip) = \varphi(i)\cdot(p-1)$。
- 莫比乌斯函数：$p \mid i$ 时 $\mu(ip) = 0$；否则 $\mu(ip) = -\mu(i)$。
- 约数个数：$p \mid i$ 时 $d(ip) = d(i) / (\text{cnt}(i)+1) \cdot (\text{cnt}(i)+2)$；否则 $d(ip) = 2d(i)$。
- 约数和：靠 `low` 数组把最小质因子那一坨等比数列换掉，$p \mid i$ 时 $\sigma(ip) = \sigma(i)/\text{low}(i)\cdot\text{low}(ip)$，否则 $\sigma(ip) = \sigma(i)\cdot(p+1)$。

## 逐行代码解析

原文的代码文件是"埃氏筛片段 + 线性筛片段 + 完整模板"三段拼起来的，这里先讲前两段（片段里的 `n`、`vis`、`pri`、`cnt` 都假设外面已经定义好）。

### 模块一：埃氏筛

```cpp
vector<char> is_prime(n + 1, true);
is_prime[0] = is_prime[1] = false;
for (int i = 2; i * i <= n; i++) {
    if (is_prime[i]) {
        for (int j = i * i; j <= n; j += i) 
            is_prime[j] = false;
    }
}
```

- 初始化整个数组为 `true`，然后把 `0` 和 `1` 单独标成 `false`（它们不是素数）。
- 外层只到 $\sqrt n$：再大的 $i$ 即使为真，它的平方也超过 $n$，内层不会执行。
- `if (is_prime[i])` 其实是"如果 $i$ 还是素数"：合数早就被更小的质因子标掉了。
- 内层从 `i * i` 起步、步长 `i`，就是上面说的那条优化。
- 用 `vector<char>` 而不是 `vector<bool>`，是不想踩 `vector<bool>` 位压缩带来的慢访问（`vector<bool>` 每个元素只占 1 bit）。

### 模块二：线性筛

```cpp
for (int i = 2; i <= n; i++) {
    if (!vis[i]) pri[cnt++] = i;
    for (int j = 0; j < cnt; j++) {
        if (i * pri[j] > n) break;
        vis[i * pri[j]] = 1;
        if (i % pri[j] == 0) break;  // 关键！保证每个合数只被筛一次
    }
}
```

- `if (!vis[i]) pri[cnt++] = i;`：没被标记过的就是素数，收进质数表。
- 内层枚举质数表里的每个质数，用 `i * pri[j]` 去筛合数。
- 第一个 `break` 是越界保护，别筛出 $n$ 以外。
- 第二个 `break` 是线性筛的灵魂：一旦 $p_j \mid i$，说明 $p_j$ 已经是 $i$ 的最小质因子，再乘更大的质数只会得到"最小质因子不是 $p_j$"的合数，那些数会由别的 $i$ 筛到，这里必须停。

### 模块三：模板里积性函数的写法

```cpp
if(i%p[j]==0){
    oph[i*p[j]]=oph[i]*p[j];
    mo[i*p[j]]=0;
    break;
}
```

- 这是"$p_j$ 已经整除 $i$"的那一支：欧拉函数乘 $p$、莫比乌斯函数直接归零，然后 break。
- 配套的 else 分支（$p_j \nmid i$）就是普通的积性拆分：`oph[i*p[j]]=oph[i]*(p[j]-1)`、`mo[i*p[j]]=-mo[i]`。
- 整个模板的骨架还是上面那两层循环，只是把每个函数的递推塞进了两个分支里。看懂这两支，剩下几个数组照着公式填就行。

## 复杂度分析

| 版本 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 埃氏筛 | $O(n \log\log n)$ | $O(n)$ |
| 线性筛 | $O(n)$ | $O(n)$ |
| 集成模板（顺便求积性函数） | $O(n)$ | $O(n)$ |

埃氏筛的复杂度来自"每个素数 $p$ 贡献约 $n/p$ 次标记"，而素数的倒数和约为 $\ln\ln n$，所以总量是 $O(n\log\log n)$，实测非常接近线性。线性筛每个合数只被标记一次，严格 $O(n)$，但常数比埃氏筛大，小范围（$n \le 10^7$）时两者往往差不多。

## 适用场景

- **多组素数判定**：筛完 $O(1)$ 查表，$10^5$ 次询问也不虚。
- **求 $[1,n]$ 内所有素数**：遍历筛完的数组收集真值即可。
- **质因数分解预处理**：线性筛顺手记下每个数的最小质因子，单次分解降到 $O(\log n)$。
- **积性函数批量求值**：欧拉函数、莫比乌斯函数、约数个数、约数和，全都可以挂在线性筛上 $O(n)$ 求完。
- **莫比乌斯反演 / 数论分块**：几乎都以线性筛预处理为前置。

## 常见陷阱与注意事项

1. **内层从 `2 * i` 开始**：虽然结果也对，但复杂度退化到 $O(n\log n)$，白白丢掉 $\log\log$ 的优化。
2. **`i * i` 溢出**：$n$ 接近 `int` 上限时 `i * i` 会溢出，用 `long long` 或写 `i <= n / i`。
3. **线性筛的第二个 `break` 忘了写**：少了它，一个合数会被多个质数重复标记，复杂度退化，而且积性函数的递推会因为重复赋值而算错。
4. **`vector<bool>` 的坑**：它每个元素只占 1 bit，读写要走位运算，访问比 `vector<char>` 慢，卡常时不划算。
5. **模板里 `isp` 的含义是反的**：模板用 `bitset<N> isp;` 存"是否被筛掉"，`isp[i] == true` 表示**合数**，所以判断素数写的是 `if(!isp[i])`。名字叫 `isp` 却表示"不是素数"，读代码时特别容易被绕进去。
6. **`#define int long long` 的副作用**：模板里 `#define int long long` 之后开了 `signed main()`，所有 `int` 都是 64 位，内存直接翻倍；`N = 1e7 + 5` 的 `bitset` 加六个 `vector<int>` 很容易 MLE。
7. **`0` 和 `1` 不是素数**：埃氏筛片段里显式标掉了，线性筛从 `i = 2` 开始也天然不会碰它们，但自己写的时候别忘了。
8. **空间开小了**：筛到 $n$ 时数组要开到 `n + 1`，`i * pri[j]` 的越界判断要在赋值**之前**做。$AKB334$, '数学', array['数学', '数论', '素数', '筛法', '埃氏筛', '线性筛'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-sieve', '筛法：埃氏筛与线性筛（线性筛求 φ / d / σ）', $AKB335$> 本页合并了原「埃氏筛」「线性筛求欧拉函数」「线性筛求约数个数」「线性筛求约数和」四个条目，统一在筛法框架下讲解；正文以线性筛求 φ 为主线，埃氏筛与 d、σ 的完整实现放在文末附录。

## 一、算法原理

### 1.1 问题背景

当需要查询 $[1, n]$ 内大量数的欧拉函数值（如 $q = 10^6$ 次查询，每个数 $\le 10^7$）时，单次 $O(\sqrt{n})$ 的试除法会超时。

**思路转变**：利用欧拉函数的积性，结合线性筛（欧拉筛）框架，在 $O(n)$ 时间内一次性求出 $[1, n]$ 内所有 $\varphi(i)$，之后每次查询 $O(1)$。

### 1.2 线性筛回顾

线性筛（欧拉筛）是埃氏筛的优化版本，**每个合数只被它的最小质因子筛掉一次**，因此时间复杂度严格 $O(n)$。

核心机制：

- 维护质数表 `prime`，按从小到大顺序存储已发现的质数
- 对每个 $i$ 从 2 到 $n$，若 $i$ 未被标记，则 $i$ 是质数，加入 `prime`
- 对每个质数 $p_j$，标记 $i \times p_j$ 为合数；当 $i \bmod p_j = 0$ 时 `break`——因为 $p_j$ 是 $i$ 的最小质因子，再往后的 $p_k > p_j$ 会导致 $i \times p_k$ 的最小质因子不是 $p_k$，会被重复标记

### 1.3 φ 的两种递推情况

欧拉函数是积性函数：当 $\gcd(a, b) = 1$ 时，$\varphi(ab) = \varphi(a)\varphi(b)$。

在线性筛中，每个合数 $m = i \times p_j$（$p_j$ 是 $m$ 的最小质因子）被标记时，分两种情况计算 $\varphi(m)$：

**情况一：$i \bmod p_j \neq 0$（$p_j$ 不整除 $i$）**

此时 $\gcd(i, p_j) = 1$（因为 $p_j$ 是质数且不整除 $i$），由积性得：

$$\varphi(i \times p_j) = \varphi(i) \times \varphi(p_j) = \varphi(i) \times (p_j - 1)$$

**情况二：$i \bmod p_j = 0$（$p_j$ 整除 $i$）**

此时 $p_j$ 已经是 $i$ 的质因子，所以 $i \times p_j$ 与 $i$ 的**质因子集合完全相同**（只是 $p_j$ 的指数加了 1）。

设 $i = p_j^k \times t$（$\gcd(t, p_j) = 1$），则 $\varphi(i) = \varphi(p_j^k) \times \varphi(t) = p_j^k \cdot \frac{p_j-1}{p_j} \times \varphi(t)$。

而 $\varphi(i \times p_j) = \varphi(p_j^{k+1} \times t) = \varphi(p_j^{k+1}) \times \varphi(t) = p_j^{k+1} \cdot \frac{p_j-1}{p_j} \times \varphi(t) = p_j \times \left(p_j^k \cdot \frac{p_j-1}{p_j} \times \varphi(t)\right) = p_j \times \varphi(i)$。

即：

$$\varphi(i \times p_j) = p_j \times \varphi(i)$$

> **直觉理解**：$i$ 和 $ip$ 的不同质因子集合完全一样，所以 $\varphi(ip) = ip \cdot \prod \frac{q-1}{q} = p \cdot \left(i \cdot \prod \frac{q-1}{q}\right) = p \cdot \varphi(i)$。

### 1.4 边界与初始值

- $\varphi(1) = 1$（1 与自身互质）
- 质数 $p$ 的 $\varphi(p) = p - 1$（质数与 $[1, p-1]$ 全部互质）

这两个值分别在初始化和发现质数时直接赋值，作为递推的起点。

## 二、核心公式/状态定义与转移方程

### 2.1 状态定义

| 数组 | 含义 |
|------|------|
| `phi[i]` | 欧拉函数值 $\varphi(i)$；$\varphi(i) = 0$ 表示 $i$ 尚未被访问（即 $i$ 是质数） |
| `prime` | 已发现的质数表，按升序存储 |

> **关键技巧**：不使用单独的标记数组 `prime_vis`，而是直接利用 `phi` 数组判质数——$\varphi(i) = 0$ 当且仅当 $i$ 尚未被任何更小的数筛到，即 $i$ 是质数。发现质数时立即赋值 $\varphi(p) = p - 1$（$\ge 1$），使后续访问时 `phi[i]` 非零。这种"一数多用"省去了整个 `prime_vis` 数组。

### 2.2 转移方程

对每个 $i$（从 2 到 $n$），对每个质数 $p_j$：

$$
\varphi(i \cdot p_j) =
\begin{cases}
(p_j - 1) \cdot \varphi(i), & i \bmod p_j \neq 0 \quad (\text{互质，直接用积性}) \\
p_j \cdot \varphi(i), & i \bmod p_j = 0 \quad (\text{不互质，质因子集合不变})
\end{cases}
$$

### 2.3 线性时间证明

每个合数仅被它的**最小质因子**筛掉一次：当内层循环遇到 $i \bmod p_j = 0$ 时立即 `break`，保证 $i \times p_k$（$k > j$）不会在此时被标记——因为它们的最小质因子是 $p_j$ 而不是 $p_k$，会在 $i' = i \times p_k / p_j$ 时由 $p_j$ 筛掉。

因此总操作次数恰好等于合数个数，加上质数个数，总共 $n$ 次级别，即 $O(n)$。

### 2.4 附带功能

线性筛一次运行可以同时得到：
- **质数表** `prime`：所有 $\le n$ 的质数
- **质数判定**：$\varphi(i) = i - 1$ 当且仅当 $i$ 为质数，$O(1)$ 查询
- **欧拉函数** `phi[i]`：所有 $\varphi(i)$ 的值
- **最小质因子**（可扩展）：只需多开一个数组记录每个合数被哪个质数筛掉

这种"一次筛法、多个产出"的特性是线性筛最强大的地方。

## 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> prime, phi;
```

全局变量：`prime` 存质数表，`phi` 存欧拉函数值（同时兼作质数标记）。

### 3.1 phi_sieve —— 线性筛求欧拉函数

```cpp
void phi_sieve(int n)
{
    phi.assign(n + 1, 0);
    prime.clear();
    phi[1] = 1;
    for (int i = 2; i <= n; i++)
    {
        if (!phi[i])
        {
            phi[i] = i - 1;
            prime.emplace_back(i);
        }
        for (int j = 0; prime[j] <= n / i; j++)
        {
            if (i % prime[j]) phi[i * prime[j]] = (prime[j] - 1) * phi[i];
            else
            {
                phi[i * prime[j]] = prime[j] * phi[i];
                break;
            }
        }
    }
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `phi.assign(n + 1, 0);` | φ 数组初始化为 0，0 同时表示"未访问" |
| 2 | `prime.clear();` | 清空质数表 |
| 3 | `phi[1] = 1;` | 边界 $\varphi(1) = 1$ |
| 4 | `for (int i = 2; i <= n; i++)` | 外层遍历每个数 |
| 5-8 | `if (!phi[i]) { phi[i] = i - 1; prime.emplace_back(i); }` | $\varphi(i) = 0$ 即未被筛过 → $i$ 是质数，赋值 $\varphi(i) = i-1$ 并加入质数表 |
| 9 | `for (int j = 0; prime[j] <= n / i; j++)` | 内层遍历质数，用 `n/i` 防止 `i*prime[j]` 越界 |
| 10 | `if (i % prime[j]) phi[...] = (p-1) * phi[i];` | 情况一：$p_j$ 不整除 $i$ → 积性，$\varphi(ip) = (p-1) \cdot \varphi(i)$ |
| 11-14 | `else { phi[...] = p * phi[i]; break; }` | 情况二：$p_j$ 整除 $i$ → $\varphi(ip) = p \cdot \varphi(i)$；然后 `break`（保证线性） |

**与旧写法的对比**：旧代码额外维护 `vector<bool> prime_vis` 标记数组，在内层循环中先执行 `prime_vis[i * prime[j]] = false` 再分支。新代码直接用 `!phi[i]` 判断质数——因为 $\varphi(i) = 0$ 当且仅当 $i$ 尚未被任何更小的数筛到（即 $i$ 是质数）。合数的 `phi` 值在内层循环中被直接赋值（非零），无需额外的标记数组。

### 3.2 手动模拟（n = 12）

| $i$ | 操作 | 新增质数 | φ 值更新 |
|-----|------|---------|---------|
| 2 | `phi[2]==0` → 质数 | 2 | $\varphi(2)=1$ |
| 2 | `j=0, prime[0]=2, 2<=6` | — | $\varphi(4) = 2 \times \varphi(2) = 2$（2%2=0, break） |
| 3 | `phi[3]==0` → 质数 | 3 | $\varphi(3)=2$ |
| 3 | `j=0, prime[0]=2, 2<=4` | — | $\varphi(6) = (2-1) \times \varphi(3) = 2$（3%2≠0） |
| 3 | `j=1, prime[1]=3, 3<=4` | — | $\varphi(9) = 3 \times \varphi(3) = 6$（3%3=0, break） |
| 4 | `phi[4]==2≠0` → 非质数 | — | — |
| 4 | `j=0, prime[0]=2, 2<=3` | — | $\varphi(8) = 2 \times \varphi(4) = 4$（4%2=0, break） |
| 5 | `phi[5]==0` → 质数 | 5 | $\varphi(5)=4$ |
| 5 | `j=0, prime[0]=2, 2<=2` | — | $\varphi(10) = (2-1) \times \varphi(5) = 4$（5%2≠0） |
| 5 | `j=1, prime[1]=3, 3<=2` | — | （3 > 12/5=2，内层结束） |
| 6 | `phi[6]==2≠0` → 非质数 | — | — |
| 6 | `j=0, prime[0]=2, 2<=2` | — | $\varphi(12) = 2 \times \varphi(6) = 4$（6%2=0, break） |

**验证**：
- $\varphi(4) = 2$ ✓ {1, 3}
- $\varphi(6) = 2$ ✓ {1, 5}
- $\varphi(9) = 6$ ✓ {1, 2, 4, 5, 7, 8}
- $\varphi(8) = 4$ ✓ {1, 3, 5, 7}
- $\varphi(10) = 4$ ✓ {1, 3, 7, 9}
- $\varphi(12) = 4$ ✓ {1, 5, 7, 11}

全部正确 ✓

### 3.3 main —— 预处理 + 多组查询

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n, q;
    cin >> n >> q;
    phi_sieve(n);
    while (q--)
    {
        int n;
        cin >> n;
        if (phi[n] == n - 1) cout << n << "为质数\n";
        else cout << n << "为合数\n";
        cout << n << "的欧拉函数的值为: " << phi[n];
    }
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `int n, q; cin >> n >> q;` | 读入范围 $n$ 和查询次数 $q$ |
| 3 | `phi_sieve(n);` | 一次预处理，求出所有 $\varphi(1..n)$ |
| 4-7 | `while (q--) { ... }` | 每次查询 $O(1)$，同时判定质数 + 输出 φ 值 |

### 3.4 运行示例

输入：
```
12 3
4
7
12
```

输出：
```
4为合数
4的欧拉函数的值为: 2
7为质数
7的欧拉函数的值为: 6
12为合数
12的欧拉函数的值为: 4
```

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 预处理时间 | $O(n)$ | 每个合数被最小质因子恰好筛一次 |
| 单次查询 | $O(1)$ | 数组下标访问 |
| 空间 | $O(n)$ | `phi` + `prime`（质数约 $n / \ln n$ 个） |

**与单次求值对比**：

| 方法 | 预处理 | 单次查询 | $q=10^6, n=10^7$ 总耗时 |
|------|--------|---------|------------------------|
| 单次试除 | 无 | $O(\sqrt{n})$ | $10^6 \times 3162 \approx 3.2 \times 10^9$（超时） |
| 线性筛 | $O(n)$ | $O(1)$ | $10^7 + 10^6 \approx 1.1 \times 10^7$（瞬间） |

当查询量大时，线性筛批量预处理碾压单次求值。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **大量 φ 值查询** | 预处理后每次 $O(1)$，适合百万级查询 |
| **数论计数** | 很多计数问题需要枚举 φ 值或利用 φ 的求和公式 |
| **同时需要质数表和 φ** | 一次筛法同时得到，效率最高 |
| **莫比乌斯函数/其他积性函数** | 同样的线性筛框架，换递推公式即可 |
| **最小质因子查询** | 略加修改可同时记录每个数的最小质因子 |

## 六、常见陷阱与注意事项

### 6.1 内层循环的终止条件

`prime[j] <= n / i` 而非 `i * prime[j] <= n`。前者用除法避免了乘法溢出，同时保证 `i * prime[j]` 不会越界。若写 `i * prime[j] <= n`，当 $n$ 接近 `int` 上限时可能溢出。

### 6.2 break 的位置

必须在 `i % prime[j] == 0` 时立即 `break`，否则合数会被多个质因子重复标记，复杂度退化为 $O(n \log \log n)$（退化为埃氏筛）。`break` 是保证线性时间的关键。

### 6.3 phi[1] 的初始化

$\varphi(1) = 1$ 必须手动赋值，因为循环从 $i=2$ 开始，1 不会被处理。若遗漏，所有包含因子 1 的积性递推都会出错（不过本题中 1 不参与递推，影响较小，但仍是标准做法）。

### 6.4 质数 φ 值的赋值位置

$\varphi(p) = p - 1$ 在发现质数时赋值，而不是在内层循环中。因为质数 $p$ 只会在外层 `if (prime_vis[i])` 分支中被识别，不会作为合数 $i \times p_j$ 被标记。

### 6.5 数据类型选择

当 $n$ 较大时（如 $n \ge 10^6$），$\varphi(n)$ 可能接近 $n$，`int` 可能不够。建议用 `long long` 存储 `phi` 数组。质数表 `prime` 用 `int` 通常没问题（$10^7$ 以内质数约 66 万个，存下标完全够）。

### 6.6 phi 数组兼作质数标记

本代码不使用单独的 `prime_vis` 标记数组，而是直接用 `!phi[i]`（即 $\varphi(i) = 0$）判断质数。这要求：

- 初始化时 `phi` 全部赋 0，只有 $\varphi(1) = 1$ 手动设置
- 质数在发现时赋值 $\varphi(p) = p - 1 \ge 1$，使后续 `phi[p]` 非零
- 合数在内层循环中被直接赋值（两种情况的结果都 $\ge 1$），也不会保持为 0

**注意**：$\varphi(1) = 1$ 必须在循环前手动赋值，否则 `!phi[1]` 为真会误判 1 为质数。

### 6.7 全局变量 vs 局部变量

代码中 `prime` 和 `phi` 是全局变量。好处是 `phi_sieve` 只需一个参数 $n$；坏处是多组测试数据间可能冲突。竞赛中常用全局变量（方便调试），但应注意在每组测试前调用 `clear()`。

## 七、对比与扩展

### 7.1 埃氏筛 vs 线性筛求 φ

| 维度 | 埃氏筛 + φ | 线性筛求 φ |
|------|-----------|-----------|
| 时间复杂度 | $O(n \log \log n)$ | $O(n)$ |
| 实现难度 | 简单（埃氏筛框架 + 每质数更新 φ） | 中等（需理解两种递推情况 + break 机制） |
| 附带产物 | 质数判定 | 质数表 + 质数判定 + 可扩展最小质因子 |
| 实际速度 | $n \le 10^7$ 时相近 | $n > 10^7$ 时更快 |
| 空间 | 少（只有 phi） | 多一个质数表（约 $n / \ln n$ 个元素） |

### 7.2 埃氏筛求 φ 的写法

埃氏筛也能求 φ，思路是初始化 `phi[i] = i`，然后对每个质数 $p$，遍历 $p$ 的倍数 $j$，执行 `phi[j] = phi[j] / p * (p - 1)`。每个质数只更新一次倍数，因此不同质因子各乘一次 $\frac{p-1}{p}$，结果正确。

```cpp
vector<int> phi(n + 1);
for (int i = 1; i <= n; i++) phi[i] = i;
for (int i = 2; i <= n; i++)
    if (phi[i] == i)  // i 是质数
        for (int j = i; j <= n; j += i)
            phi[j] = phi[j] / i * (i - 1);
```

### 7.3 用线性筛求其他积性函数

线性筛的框架是通用的，只要知道函数在"最小质因子新出现"和"最小质因子重复出现"两种情况下的递推关系，就能在线性时间内求出。常见的：

| 函数 | $i \bmod p \neq 0$ | $i \bmod p = 0$ |
|------|---------------------|------------------|
| 欧拉函数 $\varphi$ | $(p-1) \cdot \varphi(i)$ | $p \cdot \varphi(i)$ |
| 莫比乌斯函数 $\mu$ | $-\mu(i)$ | $0$ |
| 约数个数 $d$ | $2 \cdot d(i)$ | 需额外记录最小质因子的指数 |
| 约数和 $\sigma$ | $(1+p) \cdot \sigma(i)$ | 需额外记录等比数列信息 |
| 最小质因子 | $p$ | $p$（直接赋值） |

### 7.4 线性筛求最小质因子

略加修改，把 `prime_vis` 替换为 `min_prime_factor` 数组，在标记合数时记录最小质因子：

```cpp
vector<int> mpf(n + 1, 0);  // 最小质因子
...
mpf[i * prime[j]] = prime[j];
```

有了最小质因子，可以快速对任意数做质因数分解（每次除以最小质因子）。

### 7.5 一句话总结

线性筛求欧拉函数是"一次筛法、多个产出"的典范：在 $O(n)$ 时间内同时得到质数表、质数判定和所有 φ 值。核心在于利用 φ 的积性，对每个合数 $i \cdot p_j$ 分两种情况递推——$p_j$ 整除 $i$ 时 $\varphi(ip) = p \cdot \varphi(i)$，不整除时 $\varphi(ip) = (p-1) \cdot \varphi(i)$。配合 `break` 保证每个合数只被最小质因子筛一次，实现严格线性复杂度。代码直接用 `!phi[i]` 判质数，省去单独的标记数组。当查询量大时，线性筛远优于单次试除求值。

## 附：埃氏筛（埃拉托斯特尼筛法）

### 埃拉托斯特尼筛法（埃氏筛）

### 一、算法原理

#### 1.1 问题背景

竞赛中经常需要判断大量数字是否为质数（如 $10^5$ 次查询，每个数 $\le 5 \times 10^6$）。逐个试除法每次 $O(\sqrt{n})$，总共 $O(t \sqrt{n})$ 可能超时。

**思路转变**：与其对每个数分别判定，不如一次性筛出 $[1, n]$ 内所有质数，之后每次查询 $O(1)$。

#### 1.2 核心思想

埃拉托斯特尼筛法（Eratosthenes Sieve）：

1. 初始化：将 $[2, n]$ 内所有数标记为"可能是质数"（`true`）
2. 从 $i = 2$ 开始扫描：若 $i$ 仍为 `true`，则 $i$ 是质数，将 $i$ 的所有倍数标记为 `false`（合数）
3. 直到 $i^2 > n$ 时停止——因为比 $i$ 小的质数已经把 $i^2$ 以下的合数筛完了

**为什么从 $i^2$ 开始标记倍数？** 因为 $i \times 2, i \times 3, \ldots, i \times (i-1)$ 这些合数已经被比 $i$ 小的质因子筛掉了。例如 $i = 5$ 时，$5 \times 2 = 10$ 已被 2 筛掉，$5 \times 3 = 15$ 已被 3 筛掉，$5 \times 4 = 20$ 已被 2 筛掉，所以从 $5 \times 5 = 25$ 开始才有意义。

#### 1.3 为什么外层循环到 $\sqrt{n}$ 就停

若 $i > \sqrt{n}$ 且 $i$ 是质数，则 $i^2 > n$，内层循环根本不会执行。但 $i$ 本身不会被任何更小的质数筛掉（因为它是质数），所以它自然保持 `true`，无需再处理。

更准确地说：$\sqrt{n}$ 以内的质数就能筛掉 $[2, n]$ 内所有合数。因为任意合数 $m \le n$ 必有一个质因子 $\le \sqrt{m} \le \sqrt{n}$，该质因子会在外层循环中把 $m$ 筛掉。

#### 1.4 复杂度分析

**时间复杂度**：$O(n \log \log n)$

这个复杂度来自于调和级数：

$$\sum_{\text{p 为质数, p} \le n} \frac{n}{p} = n \sum_{p \le n} \frac{1}{p} \approx n \ln \ln n$$

直觉上，每个质数 $p$ 贡献 $\frac{n}{p}$ 次标记操作，而质数的倒数和增长极慢（$\ln \ln n$），因此总工作量接近线性。

**空间复杂度**：$O(n)$（`vector<bool>` 数组）

**$n = 5 \times 10^6$ 时**：约 $5 \times 10^6 \times \ln \ln(5 \times 10^6) \approx 5 \times 10^6 \times 3.4 \approx 1.7 \times 10^7$ 次操作，瞬间完成。

### 二、核心公式/状态定义与转移方程

#### 2.1 状态定义

用一个布尔数组 `prime_vis[i]` 表示数 $i$ 的状态：

$$
\text{prime\_vis}[i] =
\begin{cases}
\text{true}, & i \text{ 尚未被筛掉（可能是质数）} \\
\text{false}, & i \text{ 已被筛掉（是合数）}
\end{cases}
$$

初始化时全部为 `true`，表示"尚未被筛掉"。0 和 1 不是质数，但本代码未单独处理（调用方需自行判断 $x \ge 2$）。

#### 2.2 筛法转移

对每个 $i$ 从 $2$ 到 $\sqrt{n}$：

- 若 `prime_vis[i]` 为 `true`（$i$ 是质数），则从 $j = i^2$ 开始，每隔 $i$ 标记为 `false`
- 若 `prime_vis[i]` 为 `false`（$i$ 是合数），跳过（其倍数已被更小的质因子筛过）

#### 2.3 vector\<bool\> 的位压缩

`vector<bool>` 是 C++ 的特化版本，每个元素仅占 1 bit。$n = 5 \times 10^6$ 时仅占约 625 KB，远优于 `vector<char>` 的 5 MB。

| 实现 | $n = 5 \times 10^6$ 内存 | 访问速度 |
|-----|------------------------|---------|
| `vector<bool>` | $\approx 625$ KB | 稍慢（位运算） |
| `vector<char>` | $\approx 5$ MB | 快（直接访问） |
| `bitset<N>` | $\approx 625$ KB | 快（编译期固定） |

`vector<bool>` 在内存与灵活性间取得了平衡：大小可运行时指定，且内存极省。

### 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
```

标准头文件与命名空间。

#### 3.1 sieve_vis —— 埃氏筛核心函数

```cpp
vector<bool> sieve_vis(int n)
{
    vector<bool> prime_vis(n + 1, true);
    for (int i = 2; i * i <= n; i++)
    {
        if (!prime_vis[i]) continue;
        for (int j = i * i; j <= n; j += i)
        {
            prime_vis[j] = false;
        }
    }
    return prime_vis;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `vector<bool> sieve_vis(int n)` | 返回布尔数组，`prime_vis[i]` 为 true 表示 $i$ 是质数（或 1） |
| 2 | `vector<bool> prime_vis(n + 1, true);` | 初始化 $[0, n]$ 全为 true。注意 0 和 1 不是质数，调用方需自行判断 |
| 3 | `for (int i = 2; i * i <= n; i++)` | 外层只需到 $\sqrt{n}$，用 `i * i <= n` 避免浮点 `sqrt` |
| 4 | `if (!prime_vis[i]) continue;` | $i$ 已被筛掉（合数），跳过——优化关键：只从质数开始筛 |
| 5 | `for (int j = i * i; j <= n; j += i)` | 从 $i^2$ 开始标记倍数，步长 $i$ |
| 6 | `prime_vis[j] = false;` | 标记为合数 |
| 7 | `return prime_vis;` | 返回筛好的数组 |

**手动模拟**（$n = 30$）：

| 步骤 | 当前质数 $i$ | 标记为 false 的数 | prime_vis 中仍为 true |
|------|-------------|------------------|----------------------|
| 初始 | — | — | 全部 |
| $i=2$ | 2 | 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30 | 2,3,5,7,9,11,13,15,17,19,21,23,25,27,29 |
| $i=3$ | 3 | 9, 12, 15, 18, 21, 24, 27, 30 | 2,3,5,7,11,13,17,19,23,25,29 |
| $i=5$ | 5 | 25, 30 | 2,3,5,7,11,13,17,19,23,29 |
| $i=6$ | — | （6 已被筛，跳过） | 不变 |
| $i=7$ | 7 | （$7^2=49>30$，内层不执行） | 不变 |

$[2, 30]$ 内的质数：2, 3, 5, 7, 11, 13, 17, 19, 23, 29 ✓

#### 3.2 main —— 预处理 + 多组查询

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int t;
    cin >> t;
    vector<bool> vis = move(sieve_vis(5000000));
    while (t--)
    {
        int x;
        cin >> x;
        if (vis[x]) cout << "是质数" << '\n';
        else cout << "是合数" << '\n';
    }
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快速 IO |
| 3-4 | `int t; cin >> t;` | 查询组数 |
| 5 | `vector<bool> vis = move(sieve_vis(5000000));` | 一次性筛到 $5 \times 10^6$，`move` 避免拷贝整个数组 |
| 6-9 | `cin >> x; if (vis[x]) ...` | 每次查询 $O(1)$ |

**关键设计：预处理 + 查询分离**。筛法在最前面一次性完成所有预处理，后续每次查询只需查表。这是"以空间换时间"的经典范例。

> **注意**：代码预先筛到 $5 \times 10^6$，如果查询的 $x$ 超过此范围会越界。实际使用时应根据题目数据范围调整 `sieve_vis` 的参数。

#### 3.3 运行示例

输入：
```
5
2
4
17
100
999983
```

输出：
```
是质数
是合数
是质数
是合数
是质数
```

### 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 预处理时间 | $O(n \log \log n)$ | 接近线性，$n = 5 \times 10^6$ 时约 $1.7 \times 10^7$ 次操作 |
| 单次查询 | $O(1)$ | 数组下标访问 |
| 空间 | $O(n)$ | `vector<bool>` 位压缩，$n = 5 \times 10^6$ 时约 625 KB |

**与试除法对比**：

| 方法 | 预处理 | 单次查询 | $t = 10^5, n = 5 \times 10^6$ 总耗时 |
|------|--------|---------|--------------------------------------|
| 试除法 | 无 | $O(\sqrt{n})$ | $10^5 \times 2236 \approx 2.2 \times 10^8$（偏慢） |
| 埃氏筛 | $O(n \log \log n)$ | $O(1)$ | $1.7 \times 10^7 + 10^5 \approx 1.7 \times 10^7$（瞬间） |

当查询次数 $t$ 较大时，筛法远优于试除法。

### 五、适用场景

| 场景 | 说明 |
|------|------|
| **多组质数判定** | 预处理后每次 $O(1)$ 查询 |
| **求 $[1, n]$ 内所有质数** | 筛完后遍历 `prime_vis` 收集 true 的下标 |
| **质因数分解预处理** | 配合线性筛记录最小质因子 |
| **欧拉函数预处理** | 利用筛法框架计算 $\varphi(i)$ |
| **莫比乌斯函数预处理** | 利用筛法框架计算 $\mu(i)$ |
| **数论分块** | 需要快速判断大数区间内的质数个数 |

### 六、常见陷阱与注意事项

#### 6.1 0 和 1 未处理

代码初始化全为 `true`，0 和 1 也不是质数但会显示"是质数"。若题目可能输入 0 或 1，需特判：

```cpp
if (x < 2) cout << "不是质数" << '\n';
else if (vis[x]) cout << "是质数" << '\n';
else cout << "是合数" << '\n';
```

#### 6.2 数组越界

`sieve_vis(5000000)` 只筛到 $5 \times 10^6$，若查询 $x > 5 \times 10^6$ 会越界。需根据题目最大数据范围调整预处理上界。

#### 6.3 i * i 溢出

当 $n$ 接近 `int` 上限（$\approx 2.1 \times 10^9$）时，`i * i` 可能溢出。应改为 `long long` 或用 `i <= n / i` 代替。

#### 6.4 内层循环起始点

从 `j = i * i` 开始而非 `j = 2 * i`。这是关键优化：$i \times 2$ 到 $i \times (i-1)$ 已被更小的质因子筛过。若从 $2i$ 开始，复杂度退化为 $O(n \ln n)$（仍可过，但非最优）。

#### 6.5 vector\<bool\> 的性能

`vector<bool>` 的位压缩虽然省内存，但读写需要位运算，速度略慢于 `vector<char>` 或 `bitset`。对极端卡常的题目，可考虑 `bitset`（编译期固定大小）或 `vector<char>`。

#### 6.6 与线性筛（欧拉筛）的选择

埃氏筛会重复标记某些合数（如 $12 = 2 \times 6 = 3 \times 4$），而线性筛每个合数只被标记一次。但埃氏筛常数小、实现简单，$n \le 10^7$ 时通常更快或相当。

### 七、对比与扩展

#### 7.1 埃氏筛 vs 线性筛（欧拉筛）

| 维度 | 埃氏筛 | 线性筛（欧拉筛） |
|------|--------|-----------------|
| 时间复杂度 | $O(n \log \log n)$ | $O(n)$ |
| 实现难度 | 极简（3 行核心） | 中等（需维护质数表 + 最小质因子判断） |
| 重复标记 | 有（合数被多个质因子筛） | 无（每个合数只被最小质因子筛一次） |
| 附加功能 | 仅判定质数 | 可同时求 $\varphi(i)$、$\mu(i)$、最小质因子 |
| 实际速度 | $n \le 10^7$ 时通常更快 | $n > 10^7$ 时优势显现 |
| 空间 | `vector<bool>` 位压缩 | `vector<int>` 质数表 + `vector<bool>` |

#### 7.2 区间筛法

当需要求 $[L, R]$（$L$ 很大，$R - L$ 较小）内的质数时，先用埃氏筛筛出 $[1, \sqrt{R}]$ 的质数，再用这些质数筛 $[L, R]$ 的区间。复杂度 $O(\sqrt{R} \log \log \sqrt{R} + (R - L) \log \log R)$。

#### 7.3 利用筛法求积性函数

积性函数（如欧拉函数 $\varphi$、莫比乌斯函数 $\mu$）可通过筛法框架在 $O(n)$ 或 $O(n \log \log n)$ 内预处理。线性筛尤其适合——在标记合数时根据最小质因子递推函数值。

#### 7.4 一句话总结

埃拉托斯特尼筛法用"标记质数倍数"的简单思路，在 $O(n \log \log n)$ 时间内预处理出 $[1, n]$ 内所有质数，查询 $O(1)$。三行核心代码、位压缩省内存、常数极小，是数论中最常用的预处理工具——当需要多次判定质数时，筛法远优于逐个试除。

## 附：线性筛求约数个数 d(n)

### 线性筛求约数个数（欧拉筛批量预处理）

### 一、算法原理

#### 1.1 问题背景

约数个数函数 $d(n)$（也称 $\sigma_0(n)$ 或 $\tau(n)$）表示 $n$ 的正约数个数。当需要查询 $[1, n]$ 内大量数的约数个数（如 $q = 10^6$ 次查询，每个数 $\le 10^7$）时，单次 $O(\sqrt{n})$ 的试除法会超时。

**思路**：利用约数个数的积性，结合线性筛框架，在 $O(n)$ 时间内一次性求出 $[1, n]$ 内所有 $d(i)$，之后每次查询 $O(1)$。

#### 1.2 约数个数公式

设 $n$ 的质因数分解为 $n = p_1^{\alpha_1} \cdot p_2^{\alpha_2} \cdots p_s^{\alpha_s}$，则：

$$d(n) = \prod_{i=1}^{s} (\alpha_i + 1)$$

**直觉理解**：每个质因子 $p_i$ 可以取 $0, 1, 2, \ldots, \alpha_i$ 次方，共 $\alpha_i + 1$ 种选择，各质因子独立组合，所以总数是各 $(\alpha_i + 1)$ 的乘积。

**示例**：

| $n$ | 分解 | $d(n)$ | 约数 |
|-----|------|--------|------|
| 1 | 1 | 1 | {1} |
| 2 | $2^1$ | 2 | {1, 2} |
| 4 | $2^2$ | 3 | {1, 2, 4} |
| 6 | $2^1 \times 3^1$ | $2 \times 2 = 4$ | {1, 2, 3, 6} |
| 12 | $2^2 \times 3^1$ | $3 \times 2 = 6$ | {1, 2, 3, 4, 6, 12} |

#### 1.3 积性与线性筛

约数个数函数 $d(n)$ 是**积性函数**：当 $\gcd(a, b) = 1$ 时，$d(ab) = d(a) \cdot d(b)$。

在线性筛中，每个合数 $m = i \times p_j$（$p_j$ 是 $m$ 的最小质因子）被标记时，分两种情况计算 $d(m)$。关键在于额外维护一个辅助数组 $a[\,]$，记录每个数的最小质因子的指数。

#### 1.4 两种递推情况

**情况一：$i \bmod p_j \neq 0$（$p_j$ 不整除 $i$）**

此时 $\gcd(i, p_j) = 1$（因为 $p_j$ 是质数且不整除 $i$），由积性得：

$$d(i \times p_j) = d(i) \times d(p_j) = d(i) \times 2$$

因为 $p_j$ 是 $i \times p_j$ 的新质因子（指数为 1），所以 $a(i \times p_j) = 1$。

**情况二：$i \bmod p_j = 0$（$p_j$ 整除 $i$）**

此时 $p_j$ 已经是 $i$ 的最小质因子。设 $i$ 中 $p_j$ 的指数为 $k$（即 $a(i) = k$），则 $i \times p_j$ 中 $p_j$ 的指数变为 $k + 1$。

设 $i = p_j^k \times t$（$\gcd(t, p_j) = 1$），则：

$$d(i) = (k + 1) \times d(t)$$

$$d(i \times p_j) = (k + 2) \times d(t) = \frac{(k+2)}{(k+1)} \times d(i) = \frac{a(i \times p_j) + 1}{a(i \times p_j)} \times d(i)$$

其中 $a(i \times p_j) = k + 1 = a(i) + 1$，所以：

$$d(i \times p_j) = d(i) \, / \, a(i \times p_j) \times (a(i \times p_j) + 1)$$

> **为什么先除后乘？** $a(i \times p_j) = k + 1$ 整除 $d(i) = (k+1) \times d(t)$，所以 $d(i) / a(i \times p_j) = d(t)$ 是整数。先除保证整除，再乘避免分数运算。

#### 1.5 边界与初始值

- $d(1) = 1$（1 只有一个约数——自身）
- 质数 $p$ 的 $d(p) = 2$（约数为 1 和 $p$），$a(p) = 1$（最小质因子指数为 1）

### 二、核心公式/状态定义与转移方程

#### 2.1 状态定义

| 数组 | 含义 |
|------|------|
| `vis[i]` | $i$ 是否已被筛过（是否为合数） |
| `prime` | 已发现的质数表，按升序存储 |
| `a[i]` | $i$ 的最小质因子的指数 |
| `d[i]` | 约数个数 $d(i)$ |

#### 2.2 转移方程

对每个 $i$（从 2 到 $n$），对每个质数 $p_j$（$p_j \le n / i$）：

$$
a(i \cdot p_j) =
\begin{cases}
1, & i \bmod p_j \neq 0 \\
a(i) + 1, & i \bmod p_j = 0
\end{cases}
$$

$$
d(i \cdot p_j) =
\begin{cases}
2 \cdot d(i), & i \bmod p_j \neq 0 \quad (\text{新质因子，积性}) \\
d(i) \, / \, a(i \cdot p_j) \times (a(i \cdot p_j) + 1), & i \bmod p_j = 0 \quad (\text{指数}+1)
\end{cases}
$$

#### 2.3 线性时间证明

每个合数仅被它的**最小质因子**筛掉一次：当内层循环遇到 $i \bmod p_j = 0$ 时立即 `break`，保证 $i \times p_k$（$k > j$）不会在此时被标记——因为它们的最小质因子是 $p_j$ 而不是 $p_k$，会在 $i' = i \times p_k / p_j$ 时由 $p_j$ 筛掉。

因此总操作次数恰好等于合数个数加上质数个数，总共 $O(n)$。

#### 2.4 辅助数组 a 的作用

$a[\,]$ 数组记录每个数的最小质因子指数，是情况二递推的关键。在线性筛中，$p_j$ 总是 $i \times p_j$ 的最小质因子（因为质数表按升序遍历），所以：

- 当 $p_j$ 不整除 $i$ 时，$p_j$ 是 $i \times p_j$ 的新质因子，指数为 1
- 当 $p_j$ 整除 $i$ 时，$p_j$ 是 $i$ 的最小质因子，$i \times p_j$ 中 $p_j$ 的指数 = $i$ 中 $p_j$ 的指数 + 1

没有 $a[\,]$ 数组，就无法在情况二中正确递推——因为需要知道"旧指数"才能算"新指数"，进而更新 $d$ 值。

### 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> prime;
vector<int> a, d;
```

全局变量：`prime` 存质数表，`a` 存最小质因子指数，`d` 存约数个数。

#### 3.1 d_sieve —— 线性筛求约数个数

```cpp
void d_sieve(int n)
{
    prime.clear();
    prime.reserve(n / 15 + 16);
    a.assign(n + 1, 0);
    d.assign(n + 1, 0);
    d[1] = 1;
    vector<bool> vis(n + 1, false);
    for (int i = 2; i <= n; i++)
    {
        if (!vis[i])
        {
            prime.emplace_back(i);
            d[i] = 2;
            a[i] = 1;
        }
        for (int j = 0; prime[j] <= n / i; j++)
        {
            int m = prime[j] * i;
            vis[m] = true;
            if (i % prime[j])
            {
                a[m] = 1;
                d[m] = d[i] * 2;
            }
            else
            {
                a[m] = a[i] + 1;
                d[m] = d[i] / a[m] * (a[m] + 1);
                break;
            }
        }
    }
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `prime.clear(); prime.reserve(n / 15 + 16);` | 清空质数表，预留空间（质数密度约 $n / \ln n$） |
| 2-3 | `a.assign(n + 1, 0); d.assign(n + 1, 0);` | 辅助数组和约数个数数组初始化为 0 |
| 4 | `d[1] = 1;` | 边界 $d(1) = 1$ |
| 5 | `vector<bool> vis(n + 1, false);` | 标记数组，初始全 false（未被筛） |
| 6 | `for (int i = 2; i <= n; i++)` | 外层遍历每个数 |
| 7-11 | `if (!vis[i]) { prime.push_back(i); d[i] = 2; a[i] = 1; }` | $i$ 未被筛 → 质数，$d(p) = 2$，$a(p) = 1$ |
| 12 | `for (int j = 0; prime[j] <= n / i; j++)` | 内层遍历质数，`n/i` 防止越界 |
| 13-14 | `int m = prime[j] * i; vis[m] = true;` | 计算 $m = i \times p_j$ 并标记为合数 |
| 15-18 | `if (i % prime[j]) { a[m] = 1; d[m] = d[i] * 2; }` | 情况一：$p_j$ 不整除 $i$ → 新质因子，$d(m) = 2 \cdot d(i)$，$a(m) = 1$ |
| 19-22 | `else { a[m] = a[i]+1; d[m] = d[i]/a[m]*(a[m]+1); break; }` | 情况二：$p_j$ 整除 $i$ → 指数 +1，$d(m) = d(i)/a(m) \cdot (a(m)+1)$；`break` 保证线性 |

#### 3.2 手动模拟（n = 12）

| $i$ | 操作 | 新增质数 | $a$ 值更新 | $d$ 值更新 |
|-----|------|---------|-----------|-----------|
| 2 | `vis[2]=false` → 质数 | 2 | $a(2)=1$ | $d(2)=2$ |
| 2 | `j=0, p=2, 2≤6` | — | $a(4)=a(2)+1=2$ | $d(4)=d(2)/2 \times 3 = 3$（2%2=0, break） |
| 3 | `vis[3]=false` → 质数 | 3 | $a(3)=1$ | $d(3)=2$ |
| 3 | `j=0, p=2, 2≤4` | — | $a(6)=1$ | $d(6)=d(3) \times 2 = 4$（3%2≠0） |
| 3 | `j=1, p=3, 3≤4` | — | $a(9)=a(3)+1=2$ | $d(9)=d(3)/2 \times 3 = 3$（3%3=0, break） |
| 4 | `vis[4]=true` → 非质数 | — | — | — |
| 4 | `j=0, p=2, 2≤3` | — | $a(8)=a(4)+1=3$ | $d(8)=d(4)/3 \times 4 = 4$（4%2=0, break） |
| 5 | `vis[5]=false` → 质数 | 5 | $a(5)=1$ | $d(5)=2$ |
| 5 | `j=0, p=2, 2≤2` | — | $a(10)=1$ | $d(10)=d(5) \times 2 = 4$（5%2≠0） |
| 5 | `j=1, p=3, 3≤2` | — | — | （3 > 12/5=2，内层结束） |
| 6 | `vis[6]=true` → 非质数 | — | — | — |
| 6 | `j=0, p=2, 2≤2` | — | $a(12)=a(6)+1=2$ | $d(12)=d(6)/2 \times 3 = 6$（6%2=0, break） |

**验证**：
- $d(4) = 3$ ✓ {1, 2, 4}
- $d(6) = 4$ ✓ {1, 2, 3, 6}
- $d(8) = 4$ ✓ {1, 2, 4, 8}
- $d(9) = 3$ ✓ {1, 3, 9}
- $d(10) = 4$ ✓ {1, 2, 5, 10}
- $d(12) = 6$ ✓ {1, 2, 3, 4, 6, 12}

全部正确 ✓

#### 3.3 main —— 预处理 + 多组查询

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n, q;
    cin >> n >> q;
    d_sieve(n);
    for (int i = 1; i <= q; i++)
    {
        int x;
        cin >> x;
        cout << d[x] << '\n';
    }
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `int n, q; cin >> n >> q;` | 读入范围 $n$ 和查询次数 $q$ |
| 3 | `d_sieve(n);` | 一次预处理，求出所有 $d(1..n)$ |
| 4-7 | `for (int i = 1; i <= q; i++) { cin >> x; cout << d[x]; }` | 每次查询 $O(1)$ |

#### 3.4 运行示例

输入：
```
12 4
4
6
9
12
```

输出：
```
3
4
3
6
```

### 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 预处理时间 | $O(n)$ | 每个合数被最小质因子恰好筛一次 |
| 单次查询 | $O(1)$ | 数组下标访问 |
| 空间 | $O(n)$ | `vis` + `a` + `d` + `prime`（质数约 $n / \ln n$ 个） |

**与单次试除法对比**：

| 方法 | 预处理 | 单次查询 | $q=10^6, n=10^7$ 总耗时 |
|------|--------|---------|------------------------|
| 单次试除 | 无 | $O(\sqrt{n})$ | $10^6 \times 3162 \approx 3.2 \times 10^9$（超时） |
| 线性筛 | $O(n)$ | $O(1)$ | $10^7 + 10^6 \approx 1.1 \times 10^7$（瞬间） |

### 五、适用场景

| 场景 | 说明 |
|------|------|
| **大量约数个数查询** | 预处理后每次 $O(1)$，适合百万级查询 |
| **约数相关计数** | 如 $\sum_{i=1}^{n} d(i)$、约数和等问题的预处理步骤 |
| **数论函数筛法练习** | $d(n)$ 需要额外维护 $a[\,]$ 数组，是线性筛积性函数的经典进阶案例 |
| **配合其他积性函数** | 线性筛可同时求 $d$、$\varphi$、$\mu$ 等，一次筛法多个产出 |

### 六、常见陷阱与注意事项

#### 6.1 a 数组的含义

`a[i]` 存的是 $i$ 的**最小质因子**的指数，不是任意质因子的指数。在线性筛中，$p_j$ 总是 $i \times p_j$ 的最小质因子（因为质数表按升序遍历），所以 $a[\,]$ 记录的恰好是最小质因子指数。

#### 6.2 先除后乘防溢出

`d[m] = d[i] / a[m] * (a[m] + 1)` 必须先除后乘。因为 $a(m) = a(i) + 1$ 整除 $d(i) = (a(i)+1) \times d(t)$，先除得到整数 $d(t)$，再乘 $(a(m)+1)$ 不溢出。若写成 `d[i] * (a[m]+1) / a[m]`，中间值 `d[i] * (a[m]+1)` 可能溢出。

#### 6.3 vis 数组不能省去

与线性筛求欧拉函数不同，本代码**不能**用 `!d[i]` 代替 `vis[i]` 判质数。因为 $d(1) = 1$ 非零，而质数的 $d(p) = 2$ 也非零，合数的 $d$ 值也非零——$d$ 数组中没有值为 0 的元素可用于标记"未访问"。因此必须额外维护 `vis` 数组。

#### 6.4 d[1] 的初始化

$d(1) = 1$ 必须手动赋值，因为循环从 $i=2$ 开始，1 不会被处理。若遗漏，`d[1]` 保持 0，查询时返回错误结果。

#### 6.5 break 的位置

必须在 `i % prime[j] == 0` 时立即 `break`，否则合数会被多个质因子重复标记，复杂度退化为 $O(n \log \log n)$（退化为埃氏筛）。`break` 是保证线性时间的关键。

#### 6.6 质数 d 值的赋值位置

$d(p) = 2$ 和 $a(p) = 1$ 在发现质数时赋值（外层 `if (!vis[i])` 分支），而不是在内层循环中。因为质数只会在外层被识别，不会作为合数 $i \times p_j$ 被标记。

#### 6.7 数据类型选择

当 $n$ 较大时（如 $n \ge 10^6$），$d(n)$ 的最大值远小于 $n$（高度合成数的 $d$ 值也不超过几千），`int` 完全够用。但 $a[\,]$ 数组值也很小，`int` 足够。

### 七、对比与扩展

#### 7.1 线性筛求 φ vs 求 d

| 维度 | 求 $\varphi$ | 求 $d$ |
|------|-------------|--------|
| 辅助数组 | 无（`phi` 兼作标记） | 需要额外 `a[]` 记录最小质因子指数 |
| 质数标记 | `!phi[i]` 判断质数 | 必须额外维护 `vis[]` |
| 情况一递推 | $(p-1) \cdot \varphi(i)$ | $2 \cdot d(i)$ |
| 情况二递推 | $p \cdot \varphi(i)$ | $d(i) / a(m) \cdot (a(m)+1)$ |
| 递推复杂度 | 直接乘法 | 需要先除后乘（涉及中间量 $d(t)$） |

求 $d$ 比求 $\varphi$ 更复杂的原因：$\varphi$ 在情况二中只需乘 $p$（因为质因子集合不变，$\varphi(ip) = p \cdot \varphi(i)$ 直接成立）；而 $d$ 在情况二中需要修改最小质因子指数对应的因子（从 $(k+1)$ 变为 $(k+2)$），必须知道 $k$ 的值，因此需要额外维护 $a[\,]$ 数组。

#### 7.2 埃氏筛求 d 的写法

埃氏筛也能求 $d$，思路是初始化 `d[i] = 1`，对每个质数 $p$ 遍历其倍数，逐个乘入 $(\alpha+1)$ 因子。但需要额外记录指数，实现不如线性筛优雅。

#### 7.3 用线性筛求其他积性函数

线性筛的框架是通用的，只要知道函数在"最小质因子新出现"和"最小质因子重复出现"两种情况下的递推关系，就能在线性时间内求出。常见的：

| 函数 | $i \bmod p \neq 0$ | $i \bmod p = 0$ | 额外信息 |
|------|---------------------|------------------|---------|
| 欧拉函数 $\varphi$ | $(p-1) \cdot \varphi(i)$ | $p \cdot \varphi(i)$ | 无 |
| 约数个数 $d$ | $2 \cdot d(i)$ | $d(i) / a(m) \cdot (a(m)+1)$ | 最小质因子指数 $a$ |
| 莫比乌斯函数 $\mu$ | $-\mu(i)$ | $0$ | 无 |
| 约数和 $\sigma$ | $\sigma(i) \cdot (1+p)$ | 需额外维护等比数列和 | 最小质因子幂和 |

#### 7.4 约数求和函数 $\sigma(n)$

约数求和 $\sigma(n) = \sum_{d \mid n} d$ 也是积性函数。线性筛求 $\sigma$ 需要额外维护最小质因子的等比数列和 $S$（即 $1 + p + p^2 + \cdots + p^k$），递推更复杂：

- 情况一（$p$ 不整除 $i$）：$\sigma(ip) = \sigma(i) \cdot (1+p)$，$S(ip) = 1+p$
- 情况二（$p$ 整除 $i$）：$S(ip) = S(i) \cdot p + 1$，$\sigma(ip) = \sigma(i) / S(i) \cdot S(ip)$

#### 7.5 一句话总结

线性筛求约数个数是线性筛积性函数的经典进阶案例：在 $O(n)$ 时间内求出 $[1, n]$ 内所有 $d(i)$。核心在于额外维护最小质因子指数数组 $a[\,]$，对每个合数 $i \cdot p_j$ 分两种情况递推——$p_j$ 不整除 $i$ 时 $d(ip) = 2 \cdot d(i)$，整除时 $d(ip) = d(i) / a(m) \cdot (a(m)+1)$。与求 $\varphi$ 不同，求 $d$ 无法用 `d` 数组本身判质数，必须额外维护 `vis` 标记数组。

## 附：线性筛求约数和 σ(n)

### 线性筛求约数和（欧拉筛批量预处理）

### 一、算法原理

#### 1.1 问题背景

约数和函数 $\sigma(n)$（即 $f(n)$）表示 $n$ 的所有正约数之和。当需要查询 $[1, n]$ 内大量数的约数和（如 $q = 10^6$ 次查询，每个数 $\le 10^7$）时，单次 $O(\sqrt{n})$ 的试除法会超时。

**思路**：利用约数和的积性，结合线性筛框架，在 $O(n)$ 时间内一次性求出 $[1, n]$ 内所有 $\sigma(i)$，之后每次查询 $O(1)$。

#### 1.2 约数和公式

设 $n$ 的质因数分解为 $n = p_1^{\alpha_1} \cdot p_2^{\alpha_2} \cdots p_s^{\alpha_s}$，则：

$$\sigma(n) = \prod_{i=1}^{s} \left(1 + p_i + p_i^2 + \cdots + p_i^{\alpha_i}\right)$$

**直觉理解**：每个质因子 $p_i$ 的贡献是一个等比数列和 $1 + p_i + p_i^2 + \cdots + p_i^{\alpha_i}$。各质因子的约数独立组合（由积性），所以总和是各等比数列和的乘积。

**示例**：

| $n$ | 分解 | $\sigma(n)$ | 约数 |
|-----|------|------------|------|
| 1 | 1 | 1 | {1} |
| 2 | $2^1$ | $1+2 = 3$ | {1, 2} |
| 4 | $2^2$ | $1+2+4 = 7$ | {1, 2, 4} |
| 6 | $2^1 \times 3^1$ | $(1+2)(1+3) = 12$ | {1, 2, 3, 6} |
| 12 | $2^2 \times 3^1$ | $(1+2+4)(1+3) = 28$ | {1, 2, 3, 4, 6, 12} |

#### 1.3 积性与线性筛

约数和函数 $\sigma(n)$ 是**积性函数**：当 $\gcd(a, b) = 1$ 时，$\sigma(ab) = \sigma(a) \cdot \sigma(b)$。

在线性筛中，每个合数 $m = i \times p_j$（$p_j$ 是 $m$ 的最小质因子）被标记时，分两种情况计算 $\sigma(m)$。关键在于额外维护一个辅助数组 $g[\,]$，记录每个数的最小质因子对应的等比数列和 $1 + p + p^2 + \cdots + p^k$。

#### 1.4 两种递推情况

**情况一：$i \bmod p_j \neq 0$（$p_j$ 不整除 $i$）**

此时 $\gcd(i, p_j) = 1$（因为 $p_j$ 是质数且不整除 $i$），由积性得：

$$\sigma(i \times p_j) = \sigma(i) \times \sigma(p_j) = \sigma(i) \times (1 + p_j)$$

因为 $p_j$ 是 $i \times p_j$ 的新质因子（指数为 1），对应的等比数列和为 $1 + p_j$，所以 $g(i \times p_j) = 1 + p_j$。

**情况二：$i \bmod p_j = 0$（$p_j$ 整除 $i$）**

此时 $p_j$ 已经是 $i$ 的最小质因子。设 $i$ 中 $p_j$ 的指数为 $k$，则 $i \times p_j$ 中 $p_j$ 的指数变为 $k+1$。

$i$ 的等比数列和为 $g(i) = 1 + p_j + p_j^2 + \cdots + p_j^k$。

$i \times p_j$ 的等比数列和为 $g(i \times p_j) = 1 + p_j + p_j^2 + \cdots + p_j^{k+1} = p_j \times g(i) + 1$。

因为 $\sigma(i) = g(i) \times \sigma(t)$（$t = i / p_j^k$，$p_j \nmid t$），所以：

$$\sigma(i \times p_j) = g(i \times p_j) \times \sigma(t) = \frac{g(i \times p_j)}{g(i)} \times \sigma(i) = \sigma(i) \, / \, g(i) \times g(i \times p_j)$$

> **为什么先除后乘？** $g(i) = 1 + p_j + \cdots + p_j^k$ 整除 $\sigma(i) = g(i) \times \sigma(t)$，所以 $\sigma(i) / g(i) = \sigma(t)$ 是整数。先除保证整除，再乘避免分数运算。

#### 1.5 边界与初始值

- $\sigma(1) = 1$（1 只有一个约数——自身），$g(1) = 1$
- 质数 $p$ 的 $\sigma(p) = 1 + p$，$g(p) = 1 + p$（最小质因子就是自身，指数为 1）

### 二、核心公式/状态定义与转移方程

#### 2.1 状态定义

| 数组 | 含义 |
|------|------|
| `vis[i]` | $i$ 是否已被筛过（是否为合数） |
| `prime` | 已发现的质数表，按升序存储 |
| `g[i]` | $i$ 的最小质因子对应的等比数列和 $1 + p + p^2 + \cdots + p^k$ |
| `f[i]` | 约数和 $\sigma(i)$ |

#### 2.2 转移方程

对每个 $i$（从 2 到 $n$），对每个质数 $p_j$（$p_j \le n / i$），设 $m = i \times p_j$：

$$
g(m) =
\begin{cases}
1 + p_j, & i \bmod p_j \neq 0 \\
p_j \cdot g(i) + 1, & i \bmod p_j = 0
\end{cases}
$$

$$
\sigma(m) =
\begin{cases}
\sigma(i) \cdot (1 + p_j), & i \bmod p_j \neq 0 \quad (\text{新质因子，积性}) \\
\sigma(i) \, / \, g(i) \cdot g(m), & i \bmod p_j = 0 \quad (\text{指数}+1\text{，替换等比和})
\end{cases}
$$

#### 2.3 线性时间证明

每个合数仅被它的**最小质因子**筛掉一次：当内层循环遇到 $i \bmod p_j = 0$ 时立即 `break`，保证 $i \times p_k$（$k > j$）不会在此时被标记——因为它们的最小质因子是 $p_j$ 而不是 $p_k$，会在 $i' = i \times p_k / p_j$ 时由 $p_j$ 筛掉。

因此总操作次数恰好等于合数个数加上质数个数，总共 $O(n)$。

#### 2.4 辅助数组 g 的作用

$g[\,]$ 数组记录每个数的最小质因子对应的等比数列和 $1 + p + p^2 + \cdots + p^k$（$k$ 为该质因子在数中的指数），是情况二递推的关键。

在线性筛中，$p_j$ 总是 $i \times p_j$ 的最小质因子（因为质数表按升序遍历），所以：

- 当 $p_j$ 不整除 $i$ 时，$p_j$ 是新质因子，指数为 1，$g(m) = 1 + p_j$
- 当 $p_j$ 整除 $i$ 时，$p_j$ 是 $i$ 的最小质因子，$i \times p_j$ 中 $p_j$ 的指数 +1，等比数列和从 $g(i)$ 扩展为 $p_j \cdot g(i) + 1$

没有 $g[\,]$ 数组，就无法在情况二中正确递推——因为需要知道"旧等比和"才能算"新等比和"，进而更新 $\sigma$ 值。

#### 2.5 f 和 g 的关系

对于任意 $n$，设其最小质因子为 $p$，指数为 $k$，则 $n = p^k \times t$（$p \nmid t$）：

$$g(n) = 1 + p + p^2 + \cdots + p^k$$

$$\sigma(n) = g(n) \times \sigma(t)$$

当 $n$ 是质数时，$k = 1$，$t = 1$，$g(p) = 1 + p$，$\sigma(p) = (1+p) \times \sigma(1) = 1 + p$，两者相等。

当 $n = 1$ 时，$g(1) = \sigma(1) = 1$，也是一致的。

### 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> prime;
vector<long long> g, f;
```

全局变量：`prime` 存质数表，`g` 存最小质因子等比数列和，`f` 存约数和。注意 `g` 和 `f` 用 `long long`，因为约数和可能很大。

#### 3.1 f_sieve —— 线性筛求约数和

```cpp
void f_sieve(int n)
{
    prime.clear();
    prime.reserve(n / 15 + 16);
    g.assign(n + 1, 0);
    f.assign(n + 1, 0);
    f[1] = g[1] = 1;
    vector<bool> vis(n + 1, false);
    for (int i = 2; i <= n; i++)
    {
        if (!vis[i])
        {
            g[i] = f[i] = i + 1;
            prime.emplace_back(i);
        }
        for (int j = 0; prime[j] <= n / i; j++)
        {
            long long m = prime[j] * i;
            vis[m] = true;
            if (i % prime[j])
            {
                g[m] = 1 + prime[j];
                f[m] = f[i] * g[m];
            }
            else
            {
                g[m] = g[i] * prime[j] + 1;
                f[m] = f[i] / g[i] * g[m];
                break;
            }
        }
    }
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `prime.clear(); prime.reserve(n / 15 + 16);` | 清空质数表，预留空间（质数密度约 $n / \ln n$） |
| 2-3 | `g.assign(n + 1, 0); f.assign(n + 1, 0);` | 辅助数组和约数和数组初始化为 0 |
| 4 | `f[1] = g[1] = 1;` | 边界 $\sigma(1) = g(1) = 1$ |
| 5 | `vector<bool> vis(n + 1, false);` | 标记数组，初始全 false（未被筛） |
| 6 | `for (int i = 2; i <= n; i++)` | 外层遍历每个数 |
| 7-10 | `if (!vis[i]) { g[i] = f[i] = i + 1; prime.emplace_back(i); }` | $i$ 未被筛 → 质数，$g(p) = f(p) = 1 + p$，加入质数表 |
| 11 | `for (int j = 0; prime[j] <= n / i; j++)` | 内层遍历质数，`n/i` 防止越界 |
| 12-13 | `long long m = prime[j] * i; vis[m] = true;` | 计算 $m = i \times p_j$ 并标记为合数（用 `long long` 防溢出） |
| 14-17 | `if (i % prime[j]) { g[m] = 1 + prime[j]; f[m] = f[i] * g[m]; }` | 情况一：$p_j$ 不整除 $i$ → 新质因子，$g(m) = 1+p$，$\sigma(m) = \sigma(i) \cdot (1+p)$ |
| 18-21 | `else { g[m] = g[i]*p+1; f[m] = f[i]/g[i]*g[m]; break; }` | 情况二：$p_j$ 整除 $i$ → 扩展等比和 $g(m) = p \cdot g(i) + 1$，$\sigma(m) = \sigma(i)/g(i) \cdot g(m)$；`break` 保证线性 |

#### 3.2 手动模拟（n = 12）

| $i$ | 操作 | 新增质数 | $g$ 值更新 | $f$ 值更新 |
|-----|------|---------|-----------|-----------|
| 2 | `vis[2]=false` → 质数 | 2 | $g(2)=3$ | $f(2)=3$ |
| 2 | `j=0, p=2, 2≤6` | — | $g(4)=g(2) \times 2+1=7$ | $f(4)=f(2)/g(2) \times 7 = 7$（2%2=0, break） |
| 3 | `vis[3]=false` → 质数 | 3 | $g(3)=4$ | $f(3)=4$ |
| 3 | `j=0, p=2, 2≤4` | — | $g(6)=1+2=3$ | $f(6)=f(3) \times 3 = 12$（3%2≠0） |
| 3 | `j=1, p=3, 3≤4` | — | $g(9)=g(3) \times 3+1=13$ | $f(9)=f(3)/g(3) \times 13 = 13$（3%3=0, break） |
| 4 | `vis[4]=true` → 非质数 | — | — | — |
| 4 | `j=0, p=2, 2≤3` | — | $g(8)=g(4) \times 2+1=15$ | $f(8)=f(4)/g(4) \times 15 = 15$（4%2=0, break） |
| 5 | `vis[5]=false` → 质数 | 5 | $g(5)=6$ | $f(5)=6$ |
| 5 | `j=0, p=2, 2≤2` | — | $g(10)=1+2=3$ | $f(10)=f(5) \times 3 = 18$（5%2≠0） |
| 5 | `j=1, p=3, 3≤2` | — | — | （3 > 12/5=2，内层结束） |
| 6 | `vis[6]=true` → 非质数 | — | — | — |
| 6 | `j=0, p=2, 2≤2` | — | $g(12)=g(6) \times 2+1=7$ | $f(12)=f(6)/g(6) \times 7 = 28$（6%2=0, break） |

**验证**：
- $\sigma(4) = 1+2+4 = 7$ ✓
- $\sigma(6) = 1+2+3+6 = 12$ ✓
- $\sigma(8) = 1+2+4+8 = 15$ ✓
- $\sigma(9) = 1+3+9 = 13$ ✓
- $\sigma(10) = 1+2+5+10 = 18$ ✓
- $\sigma(12) = 1+2+3+4+6+12 = 28$ ✓

全部正确 ✓

#### 3.3 main —— 预处理 + 多组查询

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n, q;
    cin >> n >> q;
    f_sieve(n);
    for (int i = 1; i <= q; i++)
    {
        int x;
        cin >> x;
        cout << f[x] << '\n';
    }
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `int n, q; cin >> n >> q;` | 读入范围 $n$ 和查询次数 $q$ |
| 3 | `f_sieve(n);` | 一次预处理，求出所有 $\sigma(1..n)$ |
| 4-7 | `for (int i = 1; i <= q; i++) { cin >> x; cout << f[x]; }` | 每次查询 $O(1)$ |

#### 3.4 运行示例

输入：
```
12 4
4
6
9
12
```

输出：
```
7
12
13
28
```

### 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 预处理时间 | $O(n)$ | 每个合数被最小质因子恰好筛一次 |
| 单次查询 | $O(1)$ | 数组下标访问 |
| 空间 | $O(n)$ | `vis` + `g` + `f` + `prime`（质数约 $n / \ln n$ 个） |

**与单次试除法对比**：

| 方法 | 预处理 | 单次查询 | $q=10^6, n=10^7$ 总耗时 |
|------|--------|---------|------------------------|
| 单次试除 | 无 | $O(\sqrt{n})$ | $10^6 \times 3162 \approx 3.2 \times 10^9$（超时） |
| 线性筛 | $O(n)$ | $O(1)$ | $10^7 + 10^6 \approx 1.1 \times 10^7$（瞬间） |

### 五、适用场景

| 场景 | 说明 |
|------|------|
| **大约数和查询** | 预处理后每次 $O(1)$，适合百万级查询 |
| **约数相关计数** | 如 $\sum_{i=1}^{n} \sigma(i)$、亲和数判定等问题的预处理步骤 |
| **积性函数筛法进阶** | $\sigma$ 需要额外维护等比数列和 $g$，是线性筛积性函数中最复杂的经典案例 |
| **配合其他积性函数** | 线性筛可同时求 $\sigma$、$d$、$\varphi$、$\mu$ 等，一次筛法多个产出 |

### 六、常见陷阱与注意事项

#### 6.1 g 数组的含义

`g[i]` 存的是 $i$ 的**最小质因子**对应的等比数列和 $1 + p + p^2 + \cdots + p^k$，不是任意质因子的等比和，也不是约数和本身。对于质数 $p$，$g(p) = 1 + p = \sigma(p)$，两者恰好相等，这容易造成误解。但对于质数幂 $p^k$（$k \ge 2$），$g(p^k) = 1 + p + \cdots + p^k \ne \sigma(p^k) = 1 + p + \cdots + p^k$...实际上两者相等，因为 $p^k$ 只有一个质因子。真正的区别体现在有多个质因子时。

#### 6.2 先除后乘防溢出

`f[m] = f[i] / g[i] * g[m]` 必须先除后乘。因为 $g(i) = 1 + p + \cdots + p^k$ 整除 $\sigma(i) = g(i) \times \sigma(t)$，所以 $\sigma(i) / g(i) = \sigma(t)$ 是整数。先除得到整数 $\sigma(t)$，再乘 $g(m)$ 不溢出。若写成 `f[i] * g[m] / g[i]`，中间值 `f[i] * g[m]` 可能溢出 `long long`。

#### 6.3 vis 数组不能省去

与线性筛求欧拉函数不同，本代码**不能**用 `!f[i]` 代替 `vis[i]` 判质数。因为 $f(1) = 1$ 非零，质数的 $f(p) = 1 + p$ 也非零，合数的 $f$ 值也非零——$f$ 数组中没有值为 0 的元素可用于标记"未访问"。因此必须额外维护 `vis` 数组。

#### 6.4 long long 的必要性

约数和 $\sigma(n)$ 可能远大于 $n$。例如 $\sigma(2520) = \sigma(2^3 \times 3^2 \times 5 \times 7) = 15 \times 13 \times 6 \times 8 = 9360$，是 $n$ 的 3.7 倍。当 $n = 10^6$ 时，$\sigma$ 值可能超过 `int` 上限。因此 `g` 和 `f` 数组必须用 `long long`。

#### 6.5 m 的类型

`long long m = prime[j] * i;` 中 `m` 用 `long long` 而非 `int`。虽然 `prime[j] * i <= n` 不会溢出 `int`，但后续 `g[m]` 和 `f[m]` 的下标访问需要正确的下标值，使用 `long long` 更安全。

#### 6.6 break 的位置

必须在 `i % prime[j] == 0` 时立即 `break`，否则合数会被多个质因子重复标记，复杂度退化为 $O(n \log \log n)$。`break` 是保证线性时间的关键。

#### 6.7 质数 f 和 g 值的赋值位置

$g(p) = f(p) = 1 + p$ 在发现质数时赋值（外层 `if (!vis[i])` 分支），而不是在内层循环中。因为质数只会在外层被识别，不会作为合数 $i \times p_j$ 被标记。

### 七、对比与扩展

#### 7.1 三种线性筛积性函数对比

| 维度 | 求 $\varphi$ | 求 $d$ | 求 $\sigma$ |
|------|-------------|--------|------------|
| 辅助数组 | 无 | $a[\,]$（最小质因子指数） | $g[\,]$（最小质因子等比和） |
| 质数标记 | `!phi[i]` 兼作标记 | 必须额外 `vis[]` | 必须额外 `vis[]` |
| 情况一递推 | $(p-1) \cdot \varphi(i)$ | $2 \cdot d(i)$ | $(1+p) \cdot \sigma(i)$ |
| 情况二递推 | $p \cdot \varphi(i)$ | $d(i)/a(m) \cdot (a(m)+1)$ | $\sigma(i)/g(i) \cdot g(m)$ |
| 辅助数组更新 | 无 | $a(m) = a(i)+1$ | $g(m) = g(i) \cdot p + 1$ |
| 数据类型 | `int` 足够 | `int` 足够 | 必须 `long long` |
| 递推复杂度 | 直接乘法 | 先除后乘 | 先除后乘 |

求 $\sigma$ 是三种中最复杂的：需要维护等比数列和 $g$，且结果可能溢出 `int`。但核心思想一致——利用积性，对最小质因子"新出现"和"重复出现"分两种情况递推。

#### 7.2 等比数列和 g 的递推公式

$g$ 的递推 $g(m) = g(i) \times p + 1$ 来自等比数列的扩展：

$$g(i) = 1 + p + p^2 + \cdots + p^k$$

$$g(m) = 1 + p + p^2 + \cdots + p^{k+1} = p \times (1 + p + \cdots + p^k) + 1 = p \times g(i) + 1$$

这个递推避免了直接计算 $p^{k+1}$，只需一次乘法和一次加法。

#### 7.3 用线性筛求其他积性函数

线性筛的框架是通用的，只要知道函数在"最小质因子新出现"和"最小质因子重复出现"两种情况下的递推关系，就能在线性时间内求出。常见的：

| 函数 | $i \bmod p \neq 0$ | $i \bmod p = 0$ | 额外信息 |
|------|---------------------|------------------|---------|
| 欧拉函数 $\varphi$ | $(p-1) \cdot \varphi(i)$ | $p \cdot \varphi(i)$ | 无 |
| 约数个数 $d$ | $2 \cdot d(i)$ | $d(i) / a(m) \cdot (a(m)+1)$ | 最小质因子指数 $a$ |
| 约数和 $\sigma$ | $(1+p) \cdot \sigma(i)$ | $\sigma(i)/g(i) \cdot g(m)$ | 最小质因子等比和 $g$ |
| 莫比乌斯函数 $\mu$ | $-\mu(i)$ | $0$ | 无 |

#### 7.4 三种筛法的统一框架

三个线性筛知识点（求 $\varphi$、求 $d$、求 $\sigma$）共享相同的外层循环和内层 `break` 机制，区别仅在于：

1. **质数时的赋值**：$\varphi(p) = p-1$，$d(p) = 2$，$\sigma(p) = 1+p$
2. **情况一的递推**：分别用 $(p-1)$、$2$、$(1+p)$ 乘
3. **情况二的递推**：$\varphi$ 直接乘 $p$；$d$ 需要辅助数组 $a$；$\sigma$ 需要辅助数组 $g$
4. **辅助数组的更新**：$a(m) = a(i)+1$（指数+1），$g(m) = g(i) \cdot p + 1$（等比和扩展）

理解了这套统一框架，就能举一反三地用线性筛求任意积性函数。

#### 7.5 一句话总结

线性筛求约数和是线性筛积性函数中最复杂的经典案例：在 $O(n)$ 时间内求出 $[1, n]$ 内所有 $\sigma(i)$。核心在于额外维护最小质因子等比数列和数组 $g$，对每个合数 $i \cdot p_j$ 分两种情况递推——$p_j$ 不整除 $i$ 时 $\sigma(ip) = (1+p) \cdot \sigma(i)$，整除时 $g(ip) = p \cdot g(i) + 1$，$\sigma(ip) = \sigma(i)/g(i) \cdot g(ip)$。与求 $d$ 类似，求 $\sigma$ 也无法用 $f$ 数组本身判质数，必须额外维护 `vis` 标记数组，且 $g$ 和 $f$ 必须用 `long long` 防溢出。$AKB335$, '数学', array['数学', '数论', '素数', '筛法', '埃氏筛', '线性筛', '欧拉筛', '积性函数'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-special-angle-method--stripe-python', '特殊角法进阶 · stripe-python', $AKB336$> 本文由 stripe-python 授权合并，保留原文结构与表述。
众所周知，特殊角法是初中几何的降维打击。其在初中的主要体现为 12345 模型。本文对特殊角进一步探究，使之可以适应所有题型。

## 初步探究

这是本文发布前，笔者关于特殊系的一些探究。

| 角度 | 对边 | 临边 | 斜边 |
| --- | --- | --- | --- |
| $\alpha$ | $a$ | $b$ | $c$ |
| $\dfrac{\alpha}{2}$ | $\sqrt{c-b}$ | $\sqrt{c+b}$ | $\sqrt{2c}$ |
| $\dfrac{90\degree-\alpha}{2}$ | $\sqrt{c-a}$ | $\sqrt{c+a}$ | $\sqrt{2c}$ |
| $2\alpha$ | $2ab$ | $2b^2-c^2$ | $c^2$ |
| $45\degree-\alpha$ | $b-a$ | $b+a$ | $\sqrt{2}c$ |

由 $\alpha$ 推导出来的其余角度构成一个特殊角系，例如初中常用的 $37 \degree$ 系与 $23 \degree$ 系如下：

| 角度 | 对边 | 邻边 | 斜边 |
| --- | --- | --- | --- |
| $37 \degree$ | $3$ | $4$ | $5$ |
| $18.5 \degree$ | $1$ | $3$ | $\sqrt{10}$ |
| $26.5 \degree$ | $1$ | $2$ | $\sqrt{5}$ |
| $74 \degree$ | $24$ | $7$ | $25$ |
| $8 \degree$ | $1$ | $7$ | $5\sqrt{2}$ |

| 角度 | 对边 | 邻边 | 斜边 |
| --- | --- | --- | --- |
| $23 \degree$ | $5$ | $12$ | $13$ |
| $11.5 \degree$ | $1$ | $5$ | $\sqrt{26}$ |
| $33.5 \degree$ | $2$ | $3$ | $\sqrt{13}$ |
| $46 \degree$ | $120$ | $119$ | $169$ |
| $22 \degree$ | $7$ | $17$ | $13\sqrt{2}$ |

然而，这种方法有一个致命的缺陷：**不同特殊角系不可混用。** 在市一模中，笔者班级同学就是将 $60 \degree - 37 \degree$ 当作 $23\degree$ 导致错误。

## 进阶探究

本文意在解决这个问题。

我们先改掉角度表示法，用角度近似是为了方便，然而在混用特殊角系时会造成歧义。我们用三元组 $(a,b,c)$ 表示三角比为 $a:b:c$ 的角。

则上文可写作

$$
\dfrac{(3,4,5)}{2}=(1,3,\sqrt{10})\\
\dfrac{(4,3,5)}{2}=(1,2,\sqrt{5})\\
2(3,4,5)=(24,7,25)\\
\dfrac{\pi}{4}-(3,4,5)=(1,7,5\sqrt{2})
$$

接下来是重点。我们用这种表示法来实现不同特殊角混用。

$$
(a_1,b_1,c_1)+(a_2,b_2,c_2)=(a_1b_2+a_2b_1,b_1b_2-a_1a_2,c_1c_2)\\
(a_1,b_1,c_1)-(a_2,b_2,c_2)=(a_1b_2-a_2b_1,b_1b_2+a_1a_2,c_1c_2)\\
$$

最后附上几个做题常见的东西：

（2020中考）

$(4,3,5)-(2,3,\sqrt{13})=(6, 17, 5 \sqrt{13})$（2025靶向二）

$(24,7,25)-(3,2,\sqrt{13})=(27, 86, 25 \sqrt{13})$其他可能用的：

$$
(3,4,5)-(2,3,\sqrt{13})=(1, 18, 5 \sqrt{13})\\
(2,3,\sqrt{13})-(1,3,\sqrt{10})=(3, 11, \sqrt{130})\\
(2,3,\sqrt{13})-(1,2,\sqrt{5})=(1, 8, \sqrt{65})
$$

## 代码实现

python 写了一个简单的包，基于 sympy。如果你要探究其他角度，直接跑代码就可以。

```python
import sympy as sp

class Angle(object):
    def __init__(self, a, b, c):
        self.a, self.b, self.c = a, b, c
        # assert a * a + b * b == c * c

    def __repr__(self):
        return f'Angle(a={self.a}, b={self.b}, c={self.c})'

    def latex(self) -> str:
        return f'({sp.latex(self.a)}, {sp.latex(self.b)}, {sp.latex(self.c)})'

    def coangle(self) -> 'Angle':
        # pi/2-alpha
        a, b, c = self.a, self.b, self.c
        return Angle(b, a, c)

    def double(self) -> 'Angle':
        # 2alpha
        a, b, c = self.a, self.b, self.c
        return Angle(2 * a * b, 2 * b * b - c * c, c * c)

    def half(self) -> 'Angle':
        # alpha/2
        a, b, c = self.a, self.b, self.c
        return Angle(sp.sqrt(c - b), sp.sqrt(c + b), sp.sqrt(2 * c))

    def cohalf(self) -> 'Angle':
        # (pi/2-alpha)/2
        a, b, c = self.a, self.b, self.c
        return Angle(sp.sqrt(c - a), sp.sqrt(c + a), sp.sqrt(2 * c))

    def __add__(self, beta: 'Angle') -> 'Angle':
        # alpha + beta
        a1, b1, c1 = self.a, self.b, self.c
        a2, b2, c2 = beta.a, beta.b, beta.c
        return Angle(a1 * b2 + a2 * b1, b1 * b2 - a1 * a2, c1 * c2)

    def __sub__(self, beta: 'Angle') -> 'Angle':
        # alpha + beta
        a1, b1, c1 = self.a, self.b, self.c
        a2, b2, c2 = beta.a, beta.b, beta.c
        return Angle(a1 * b2 - a2 * b1, b1 * b2 + a1 * a2, c1 * c2)

degree30 = Angle(1, sp.sqrt(3), 2)
degree45 = Angle(1, 1, sp.sqrt(2))
```$AKB336$, '数学', array['特殊角', '几何', '三角', '数学基础'], 'col-math-oi-foundations', null, 'knowledge'),
('Xesir', 'col-math-stars-and-bars--xesir', '隔板法（Stars and Bars） · Xesir', $AKB337$## 算法原理

**定义：** 隔板法用于解决“把 $n$ 个**相同元素**分成 $k$ 组”的计数问题。核心是在元素之间的空隙中放隔板。

### 1. 正整数解

**方程：**

$$
x_1+x_2+\cdots+x_k=n,\qquad x_i\ge 1
$$

**示例：** 将 $n$ 个相同球放入 $k$ 个不同盒子，每盒至少一个。

**推导：** $n$ 个球排成一列，中间有 $n-1$ 个空隙。选 $k-1$ 个空隙放隔板，分成 $k$ 段，每段对应一个盒子的球数。方案数为：

$$
\binom{n-1}{k-1}
$$

### 2. 非负整数解

**方程：**

$$
x_1+x_2+\cdots+x_k=n,\qquad x_i\ge 0
$$

**示例：** 将 $n$ 个相同球放入 $k$ 个不同盒子，允许空盒。

**推导：** 先向每个盒子“借”一个球，共借 $k$ 个，变成 $n+k$ 个球放入 $k$ 个盒子且每盒至少一个。方案数为：

$$
\binom{n+k-1}{k-1}
$$

再各还一个球，正好对应原问题。

### 3. 有下界约束

**方程：**

$$
x_1+x_2+\cdots+x_k=n,\qquad x_i\ge a_i
$$

**示例：** 将 $n$ 个相同球放入 $k$ 个不同盒子，第 $i$ 盒至少 $a_i$ 个。

**推导：** 可以先考虑将每个组预分配 $a_i$ 个。令 $y_i=x_i-a_i\ge 0$，则：

$$
\sum y_i=n-\sum a_i
$$

方案数为：

$$
\binom{n-\sum a_i+k-1}{k-1}
$$

前提是 $n\ge \sum a_i$。

### 4. 有上界约束

**方程：**

$$
x_1+x_2+\cdots+x_n=s,\qquad x_i\le b_i
$$

**示例：** 将 $s$ 个相同球放入 $n$ 个不同盒子，第 $i$ 盒至多 $b_i$ 个。

**推导：** 通常用容斥原理解决。易得总方案数 $\binom{s+n-1}{n-1}$。

定义坏事件 $E_i:\ x_i\ge f_i+1$，要求所有 $E_i$ 都不发生。令 $y_i=x_i-(f_i+1)\ge 0$，那么原方程变成 $y_i+\sum_{j\ne i}x_j=s-(f_i+1)$，则单个坏事件方案数是：

$$
\binom{s-(f_i+1)+n-1}{n-1}
$$

如果有多个坏事件同时发生，就把它们每个都先减去 $f_i+1$，于是方案数是：

$$
\binom{s-\sum_{i\in S}(f_i+1)+n-1}{n-1}
$$

最后套容斥，得到答案：

$$
\sum_{S\subseteq \{1,2,\dots,n\}}
(-1)^{|S|}
\binom{s-\sum_{i\in S}(f_i+1)+n-1}{n-1}
$$

如果组合数上标小于下界，或者出现负数，就说明这种钦定不可能，方案数为 $0$。

## 核心公式

| 模型 | 方程约束 | 方案数 |
|---|---|---|
| 正整数解 | $x_i \ge 1$ | $\dbinom{n-1}{k-1}$ |
| 非负整数解 | $x_i \ge 0$ | $\dbinom{n+k-1}{k-1}$ |
| 下界约束 | $x_i \ge a_i$ | $\dbinom{n-\sum a_i+k-1}{k-1}$ |
| 上界约束 | $x_i \le b_i$ | 容斥求和（见上文） |

## 逐行代码解析

原文这一节只给了模型和公式，没有完整程序，所以这里只写“怎么落地成组合数查询”的骨架。

### 模块一：把模型翻译成组合数

```cpp
// n 个相同球放进 k 个不同盒子，允许空盒
ans = cabz(n + k - 1, k - 1);
```

- 第一步永远是把题目的约束对齐到四种模型之一。
- 非负解直接套 $\binom{n+k-1}{k-1}$；正整数解则套 $\binom{n-1}{k-1}$，本质是把每个变量先减 $1$。
- `cabz` 就是普通的组合数函数，模数、预处理范围按题目要求选。

### 模块二：下界约束的预处理

```cpp
// 每个盒子先预分配 a[i] 个，剩下的再自由分配
for (int i = 1; i <= k; i++) n -= a[i];
ans = cabz(n + k - 1, k - 1);
```

- 下界先“扣掉”，把问题变回非负解模型。
- 扣的过程中如果 `n < 0`，说明总球数不够，直接输出 $0$。
- 这一步不需要枚举，纯减法，复杂度 $O(k)$。

### 模块三：上界约束套容斥

```cpp
// 枚举钦定哪些盒子超过上界，奇数个减、偶数个加
for (int S = 0; S < (1 << n); S++) {
    // 统计 |S| 与 sum(b[i] + 1)
}
```

- 上界约束没有闭式解，标准做法是容斥：钦定某些盒子“至少超限”，把它们的下界抬高到 $b_i+1$。
- 每个子集算一次组合数，符号由 $|S|$ 的奇偶决定。
- 这种方法只适合 $n$ 很小（约 $n \le 20$）的情况；$n$ 大时要换别的模型。

## 复杂度分析

- 隔板法本身只是“把问题变成组合数”，真正的复杂度取决于组合数怎么求。
- 单次套公式：只做几次加减和一次 `cabz` 调用，若组合数用 $O(k)$ 的循环算，就是 $O(k)$。
- 预处理阶乘 + 逆元后：每次查询 $O(1)$，预处理 $O(n)$。
- 上界约束的容斥：枚举 $2^n$ 个子集，每个子集算一次组合数，复杂度 $O(2^n)$ 级别，只适合很小的 $n$。
- 空间开销同样由组合数实现决定：公式法几乎不用额外空间，预处理法则需要 $O(n)$ 的阶乘数组。

## 适用场景

- 相同物品分给不同的人/盒子，问方案数。
- 方程 $x_1+\cdots+x_k=n$ 的整数解计数（带下界、带非负、带上界）。
- 把一段序列切成若干段、每段至少/至多若干个的计数问题。
- 与容斥结合处理“每盒不超过 $b_i$ 个”这类限制。
- 组合数 / 计数 DP 中作为最后一步的合并公式。

## 常见陷阱

1. **元素不同还硬套隔板法**：隔板法只适用于**元素相同、组不同、组内无序**的情况。元素不同要先乘排列数。
2. **组有标号 vs 无标号**：本文所有公式都默认 $k$ 个盒子是**不同**的；如果盒子相同，还要再除以 $k!$ 或改用整数拆分。
3. **正整数解和非负解记反**：正整数是 $\binom{n-1}{k-1}$，非负是 $\binom{n+k-1}{k-1}$，差一个 $k$。
4. **下界扣完为负没判**：$\sum a_i > n$ 时无解，要直接输出 $0$，不能让组合数算出负数上标。
5. **上界约束直接套非负公式**：上界必须容斥，不能简单地把 $b_i$ 代进去。
6. **组合数上标为负**：容斥过程中经常出现 $s-\sum(f_i+1)+n-1<0$，此时组合数应视为 $0$。
7. **忘了取模**：方案数增长很快，组合数计算过程中要步步取模。

---
> 隔板法就一句话：**相同的东西排一排，用隔板切段**。真正难的不是公式，而是判断题目能不能被翻译成“相同物品分组”。$AKB337$, '数学', array['数学', '组合数学', '隔板法', 'Stars and Bars', '组合计数', '容斥'], 'col-math-combinatorics', null, 'knowledge'),
('world-needs-sunday', 'col-math-stars-and-bars', '隔板法（Stars and Bars）', $AKB338$## 隔板法（Stars and Bars）

## 一、问题描述

求将 $n$ 个相同的物品分给 $k$ 个有标号的对象，每个对象可以拿 $0$ 个，有多少种分法？

等价于求非负整数方程的解的个数：

$$x_1 + x_2 + \dots + x_k = n \quad (x_i \ge 0)$$

**答案**：$\dbinom{n + k - 1}{k - 1}$（也等于 $\dbinom{n + k - 1}{n}$）

### 问题的三个关键前提

在使用隔板法之前，必须先明确三个条件：

1. **对象有顺序（有标号）**：第 1 个人拿 3 个和第 2 个人拿 3 个是不同的分法
2. **物品完全相同**：只关心每个人拿几个，不关心具体是哪些物品
3. **允许空组**：每个人可以拿 0 个

如果这三个条件中有任何一个不同，答案公式就会变化（见第七节「常见变体」）。

---

## 二、算法原理：隔板法证明

把 $n$ 个相同的球排成一行，要分成 $k$ 组需要 $k-1$ 个隔板。

例如 $n=3, k=2$：

```
球 球 球 |     →  (3, 0)
球 球 | 球     →  (2, 1)
球 | 球 球     →  (1, 2)
| 球 球 球     →  (0, 3)
```

一共有 $n + k - 1$ 个位置（$n$ 个球 + $k-1$ 个隔板），从中选 $k-1$ 个位置放隔板：

$$\text{方案数} = \binom{n + k - 1}{k - 1}$$

**为什么隔板法能处理「有顺序」**：隔板把球从左到右分成 $k$ 段，第 $i$ 段对应第 $i$ 个人，顺序天然固定。

**为什么能处理「允许 0 个」**：隔板可以相邻、可以放在最前或最后，都对应某个人拿 0 个。

---

## 三、递推推导（DP 视角）

设 $F(n, k)$ 为把 $n$ 分给 $k$ 个有顺序对象的分法数。

### 3.1 按第一个人拿多少分类

第一个人可以拿 $0, 1, 2, \dots, n$ 个。
如果第一个人拿了 $i$ 个，剩下 $n-i$ 个分给 $k-1$ 个人。

$$F(n, k) = \sum_{i=0}^{n} F(n-i, k-1) = \sum_{m=0}^{n} F(m, k-1)$$

### 3.2 边界条件

- $F(0, 0) = 1$：0 个物品分给 0 个人，有一种（空分法）
- $F(n, 0) = 0 \ (n > 0)$：有物品但没人分，不可能
- $F(0, k) = 1 \ (k \ge 0)$：0 个物品分给 $k$ 个人，只有全拿 0 这一种

### 3.3 从小例子找规律

| $k$ | 公式 | 组合数形式 |
|---|---|---|
| $k=1$ | $F(n,1) = 1$ | $\dbinom{n}{0}$ |
| $k=2$ | $F(n,2) = n+1$ | $\dbinom{n+1}{1}$ |
| $k=3$ | $F(n,3) = \frac{(n+1)(n+2)}{2}$ | $\dbinom{n+2}{2}$ |

观察规律：$F(n, k) = \dbinom{n + k - 1}{k - 1}$

### 3.4 递推与公式的一致性（朱世杰恒等式）

由递推 $F(n, k) = \sum\limits_{m=0}^{n} F(m, k-1)$，假设 $F(m, k-1) = \dbinom{m + k - 2}{k - 2}$，则：

$$F(n, k) = \sum_{m=0}^{n} \binom{m + k - 2}{k - 2}$$

利用**朱世杰恒等式**（ hockey-stick identity）：

$$\sum_{m=0}^{n} \binom{m + r}{r} = \binom{n + r + 1}{r + 1}$$

令 $r = k-2$，得：

$$F(n, k) = \binom{n + k - 1}{k - 1}$$

递推与隔板法得到的公式完全一致。

---

## 四、逐行代码解析：代码实现（两种方法）

### 4.1 方法一：组合数公式（推荐）

直接计算 $\dbinom{n + k - 1}{k - 1}$，时间复杂度 $O(k)$。

```cpp
long long comb(int n, int k)
{
    long long res = 1;
    for (int i = 1; i <= k; i++)
        res = res * (n - k + i) / i;
    return res;
}
```

**为什么边乘边除不会出小数**：因为组合数一定是整数，前 $i$ 步乘的乘积一定能被 $i!$ 整除。每一步先乘后除，保证中间结果始终是整数。

### 4.2 方法二：动态规划（递推求和）

严格按照递推式 $F(n, k) = \sum\limits_{m=0}^{n} F(m, k-1)$ 实现，时间复杂度 $O(k \cdot n^2)$，空间复杂度 $O(k \cdot n)$。

```cpp
long long fn(int n, int k)
{
    vector<vector<long long>> dp(k + 1, vector<long long>(n + 1));
    dp[0][0] = 1;              // 边界：F(0,0) = 1
    for (int i = 1; i <= k; i++)          // i 个人
    {
        for (int j = 0; j <= n; j++)      // 总数 j
        {
            for (int z = 0; z <= j; z++)  // 枚举前 i-1 人拿 z 个
            {
                dp[i][j] += dp[i - 1][z];
            }
        }
    }
    return dp[k][n];
}
```

> **注意**：此 DP 是三重循环 $O(k \cdot n^2)$，仅作理解递推用。实际做题应使用前缀和优化到 $O(k \cdot n)$，或直接用组合数公式。

---

## 五、复杂度分析

| 方法 | 时间 | 空间 | 适用场景 |
|---|---|---|---|
| 组合数公式 | $O(k)$ | $O(1)$ | $n, k$ 不大且结果不爆 `long long` |
| DP（暴力版） | $O(k \cdot n^2)$ | $O(k \cdot n)$ | 理解递推关系，不推荐实战 |
| DP（前缀和优化） | $O(k \cdot n)$ | $O(n)$ | 需要取模且 $n, k$ 约 $10^3$ 级别 |

**数据范围提示**：
- 组合数 $\dbinom{60}{30} \approx 1.2 \times 10^{17}$，接近 `long long` 上限（约 $9 \times 10^{18}$）
- 当 $n + k > 60$ 时，结果可能溢出 `long long`，需要高精度或取模

---

## 六、验证示例

### 示例 1：$n=3, k=2$

公式：$\dbinom{3+2-1}{2-1} = \dbinom{4}{1} = 4$

枚举：$(0,3), (1,2), (2,1), (3,0)$ → 4 种 ✓

### 示例 2：$n=3, k=3$

公式：$\dbinom{3+3-1}{3-1} = \dbinom{5}{2} = 10$

枚举：
- $(0,0,3)$ 排列：3 种
- $(0,1,2)$ 排列：6 种
- $(1,1,1)$：1 种

共 $3+6+1=10$ 种 ✓

### 示例 3：$n=0, k$ 任意

公式：$\dbinom{0+k-1}{k-1} = \dbinom{k-1}{k-1} = 1$

所有人都拿 0 个，只有 1 种 ✓

---

## 七、常见变体

| 变体 | 条件 | 公式 | 技巧 |
|---|---|---|---|
| 允许空组（标准） | 有顺序，可拿 0 个 | $\dbinom{n+k-1}{k-1}$ | 基本隔板法 |
| 每人至少 1 个 | 有顺序，每人 $\ge 1$ | $\dbinom{n-1}{k-1}$ | 先每人发 1 个，剩 $n-k$ 个随意分 |
| 每人至少 $a_i$ 个 | 有顺序，第 $i$ 人 $\ge a_i$ | $\dbinom{n - \sum a_i + k - 1}{k - 1}$ | 先每人发 $a_i$ 个，剩余随意分 |
| 无顺序，允许 0 个 | 无顺序，可拿 0 个 | 无简单闭式 | 整数分拆问题，用 DP |
| 物品不同，分给 k 人 | 物品不同，人有顺序 | $k^n$ | 每个物品独立选择去向 |

**「每人至少 1 个」的推导**：先给每个人发 1 个，用掉 $k$ 个，剩下 $n-k$ 个随意分（允许再拿 0 个），代入标准公式：

$$\binom{(n-k) + k - 1}{k - 1} = \binom{n-1}{k-1}$$

要求 $n \ge k$，否则答案为 0。

---

## 八、常见陷阱与注意事项

1. **误以为答案是 $\dbinom{n}{k}$**：$\dbinom{n}{k}$ 是从 $n$ 个里选 $k$ 个，不适合「允许空组且有顺序」的分配问题
2. **混淆「每人至少 1 个」和「允许 0 个」**：
   - 允许 0 个：$\dbinom{n+k-1}{k-1}$
   - 至少 1 个：$\dbinom{n-1}{k-1}$
3. **把物品当成不同的**：物品不同时答案是 $k^n$，相同物品才用隔板法
4. **边界条件写错**：$F(0,0)=1$，但 $F(n,0)=0 \ (n>0)$。如果误以为 $F(n,0)$ 对所有 $n$ 都为 1，会导致后续计算全部偏大
5. **DP 溢出**：组合数增长极快，$n=30, k=30$ 时 $\dbinom{59}{29} \approx 5 \times 10^{16}$，接近 `long long` 上限。题目若要求取模，必须在 DP 中每步取模

---

## 九、DP 的前缀和优化

原暴力 DP 的转移是：

$$dp[i][j] = \sum_{z=0}^{j} dp[i-1][z]$$

这本质上是求前缀和。用前缀和数组 $sum[j] = \sum_{z=0}^{j} dp[i-1][z]$，则 $dp[i][j] = sum[j]$，可将时间从 $O(k \cdot n^2)$ 优化到 $O(k \cdot n)$：

```cpp
long long fn_opt(int n, int k)
{
    vector<long long> dp(n + 1, 0);
    dp[0] = 1;                          // 0 个人时只有 F(0,0)=1
    for (int i = 1; i <= k; i++)
    {
        // 计算前缀和，直接覆盖到 dp（dp[i][j] = 前缀和 dp[i-1][0..j]）
        for (int j = 1; j <= n; j++)
            dp[j] += dp[j - 1];
    }
    return dp[n];
}
```

**另一种等价转移**（经典的完全背包思路）：

$$dp[i][j] = dp[i][j-1] + dp[i-1][j]$$

含义：第 $i$ 个人拿 0 个（$dp[i-1][j]$）+ 第 $i$ 个人至少拿 1 个（先给 1 个，剩 $j-1$ 继续分给 $i$ 人）。

---

## 十、适用场景

1. **不定方程解的计数**：求 $x_1 + x_2 + \dots + x_k = n$ 的非负/正整数解个数
2. **物品分配问题**：$n$ 个相同礼物分给 $k$ 个人的方案数
3. **组合恒等式证明**：利用隔板法的直观解释证明组合恒等式
4. **DP 计数优化**：很多 DP 计数问题最终可以转化为隔板法，从而 $O(1)$ 出答案
5. **生成函数**：隔板法对应生成函数 $\dfrac{1}{(1-x)^k} = \sum_{n \ge 0} \dbinom{n+k-1}{k-1} x^n$

---

## 十一、一句话总结

> $n$ 个相同球分给 $k$ 个有标号盒子、允许空盒的方案数 = $\dbinom{n+k-1}{k-1}$
>
> 核心直觉：把问题转化为「在 $n+k-1$ 个位置中选 $k-1$ 个放隔板」的排列组合问题。$AKB338$, '数学', array['数学', '组合数学', '隔板法', 'Stars and Bars', '组合计数', '动态规划', '递推'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-stirling--stripe-python', '斯特林数与贝尔数 · stripe-python', $AKB339$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 14. Stirling 数

## 14.1 第二类 Stirling 数

**第二类 Stirling 数** $S(n,k)$ 表示将 $n$ 个不同元素分为 $k$ 个互不区分的非空**子集**的方案数。

第二类 Stirling 数有递推计算和通项计算两种计算方法。

### 14.1.1 递推公式

考虑到第 $n$ 个元素时，有两种方案：

1. 将第 $n$ 个元素单独放一个新子集，方案数为 $S(n-1,k-1)$；
2. 将第 $n$ 个元素放一个已有子集，方案数为 $k \times S(n-1,k)$。

由加法原理得：

$S(n,k)=S(n-1,k-1)+k \times S(n-1,k)$### *13.1.2 通项公式

$S(n,k)=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$可以发现一个卷积形式

$S(n,k)=\sum_{i+j=k} \dfrac{i^n}{i!} \times \dfrac{(-1)^j}{j!}$因此 $S(n,k)$ 可以看作两个多项式相乘的第 $k$ 项。使用 NTT 等技术，可以在 $O(n \log n)$ 内求出同行第二类 Stirling 数。

#### 证明

发现这个东西长的像二项式反演的式子，故设将 $n$ 个不同元素划分到 $i$ 个不同**可空**集合的方案数为 $g_i$，将 $n$ 个不同元素划分到 $i$ 个不同**非空**集合的方案数为 $g_i$。由乘法原理易得

$g_i=i^n$枚举选出多少个元素 $j$，则

$g_i=\sum_{j=0}^{i} C_i^j f_j$这是二项式反演的标准形式。由二项式反演

$$
\begin{aligned}
f_i&=\sum_{j=0}^{i} (-1)^{i-j} C_i^j g_j\\
&=\sum_{j=0}^{i} (-1)^{i-j} C_i^j j^n\\
&=\sum_{j=0}^{i} \dfrac{i!(-1)^{i-j}j^n}{j!(i-j)!}
\end{aligned}
$$

得到了 $f_i$ 的通项公式。因为 $S(n,i)$ 中的子集互不区分，所以 $f_i$ 在 $S(n,i)$ 的基础上作了全排列，即 $f_i=i! \times S(n,i)$，所以

$S(n,k)=\dfrac{f_k}{k!}=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$## 14.2 第一类 Stirling 数

**第一类 Stirling 数** $s(n,k)$ 表示将 $n$ 个不同元素分为 $k$ 个互不区分的非空**环形排列**的方案数。

第一类 Stirling 数可通过递推计算。考虑到第 $n$ 个元素时，仍有两种方案：

1. 将第 $n$ 个元素单独放一个新环，方案数为 $s(n-1,k-1)$；
2. 将第 $n$ 个元素放一个已有环，方案数为 $(n-1) \times s(n-1,k)$。

由加法原理得：

$s(n,k)=s(n-1,k-1)+(n-1) \times s(n-1,k)$第一类 Stirling 数没有实用的通项公式。

## *14.3 Stirling 反演

有如下两种 **Stirling 反演**：

$$
f_n=\sum_{i=0}^{n} S(n,i) g_i \Leftrightarrow g_n=\sum_{i=0}^n (-1)^{n-i} s(n,i) f_i\\
f_n=\sum_{i=0}^{n} s(n,i) g_i \Leftrightarrow g_n=\sum_{i=0}^n (-1)^{n-i} S(n,i) f_i
$$

这说明了第一类 Stirling 数与第二类 Stirling 数的相互联系。

## 14.4 应用

### *14.4.1 上升幂

定义**上升幂** $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod_{i=0}^{n-1} (x+i)$，有

$x^{\overline n} =\sum_{k} s(n,k) \times x^k$使用递推公式归纳即可。应用 Stirling 反演可得

$x^n=\sum_{k} (-1)^{n-k} S(n,k) \times x^{\overline k }$### *14.4.2 下降幂

定义**下降幂** $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod _{i=0}^{n-1} (x-i)$，有

$x^{n}=\sum_{k} S(n,k) \times x^{\underline k}$同样归纳可得。应用 Stirling 反演可得

$x^{\underline n}=\sum_{k}(-1)^{n-k} s(n,k) x^k$可以发现，$x^{\underline n}=\dfrac{x!}{(x-n)!}=A_{x}^{n}$。

### 14.4.3 常用性质

1. 同行第一类 Stirling 数的和：

$\sum_{k=0}^ n s(k,n)=n!$考虑环形排列的组合意义可证。同行第二类 Stirling 数的和见下文 14.2。

1. 拆幂公式：

$x^{n}=\sum_{k} S(n,k) \times x^{\underline k}=\sum_{k} S(n,k) \times k! \times C_n^k$相当常用的公式，适用于幂求和的题目。这个公式说明了第二类 Stirling 数与组合数的关系。

1. 递推公式 2：

$S(n+1,k+1)=\sum_{i=k}^n C_n^i S(i,k)$考虑组合意义，$n+1$ 个元素分到 $k+1$ 个子集中。枚举第 $n+1$ 个元素和哪些元素在一个子集，剩下的分出 $i$ 个子集。

## 14.5 例题

### P1655 小朋友的球

这是第二类 Stirling 数的板子，但是需要高精度，代码：

```cpp
const int N = 105;
int n, m;
BigInteger s[N][N];

void _main() {
	s[0][0] = 1;
	for (int i = 1; i < N; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	}
	while (cin >> n >> m) cout << s[n][m] << '\n';
}
```

### B3801 [NICA #1] 乘只因

题里给的条件就是：

$\prod_{i=1}^{k} a_i = \operatorname{lcm}_{i=1}^{k} a_i =n$因为 $\operatorname{lcm}_{i=1}^{k}=\dfrac{\prod_{i=1}^{k} a_i}{\gcd_{i=1}^{k} a_i}$，所以 $\gcd_{i=1}^{k} a_i=1$，而且又说了 $a$ 单调不降，就是说 $a$ 序列两两互质。对 $n$ 分解质因数得 $n=p_1^{a_1} p_2^{a_2} \cdots$，发现若 $a_x \ne 0$，则这些 $p_x$ 只能被分配到同一个 $a_i$ 中。记有 $c$ 个不同质因子，然后你发现这是把 $c$ 个元素划成 $k$ 个子集的方案数，即第二类 Stirling 数。

实现细节上，注意特判掉 $c<k$ 的情况。

```cpp
int n, k;
int decompose(int n) {
	int m = 0;
	for (int i = 2; i * i <= n; i++) {
		if (n % i) continue;
		m++;
		while (n % i == 0) n /= i;
	}
	if (n > 1) m++;
	return m;
}

long long s[15][15];

void _main() {
	cin >> n >> k;
	int m = decompose(n);
	cout << (m < k ? 0 : s[m][k]) << '\n';
} signed main() {
	s[0][0] = 1;
	for (int i = 1; i < 15; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	int t = 1; for (cin >> t; t--; ) _main();
}
```

### *P4609 [FJOI2016] 建筑师

单调栈经典模型。 首先高度为 $n$ 的建筑肯定不会被挡，用它将建筑划分为两段，左边的看不到右边，右边的看不到左边。

推广一下，把 $n$ 的建筑分成 $a+b-1$ 个部分，把一个可以看到的和被它的分到一组去，一共是 $a+b-2$ 组。我们发现，每一组除了最高的建筑都可以任意排列，而且这还是一个环形排列，所以方案数是第一类 Stirling 数 $s(n-1,a+b-2)$。

然后再思考每一组的放置方法，这是一个组合数 $C_{a+b-2}^{a-1}$。由乘法原理合并答案。

```cpp
int q, n, a, b;
const int N = 205;
mint c[N][N], s[50005][N];

void _main() {
	s[0][0] = 1;
	for (int i = 1; i < 50005; i++) {
		for (int j = 1; j < N; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * (i - 1);
	}
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (cin >> q; q--; ) {
		cin >> n >> a >> b;
		cout << s[n - 1][a + b - 2] * c[a + b - 2][a - 1] << '\n';
	}
}
```

### P6162 [Cnoi2020] 四角链

从 DP 出发，令 $dp_{i,j}$ 表示在 $i-1$ 个格子中填入 $j$ 个数的方案数。有两种选择：

1. 第 $i-1$ 个位置不填数，方案数为 $dp_{i-1,j}$。
2. 第 $i-1$ 个位置填数，该位置有 $(i-1)-(j-1)=i-j$ 个选择，方案数为 $(i-j)dp_{i-1,j-1}$。

由加法原理得：

$dp_{i,j}=dp_{i-1,j}+(i-j)dp_{i-1,j-1}$可以 $O(nk)$ 解决了。对比第二类 Stirling 数的递推式：

$S(n,k)=S(n-1,k-1)+k \times S(n-1,k)$将 $j \gets i-j$ 代入递推式

$dp_{i,i-j}=dp_{i-1,i-j-1}+j \times dp_{i-1,i-j}$因此 $dp_{n,k}=S(n,n-k)$。使用通项公式

$S(n,k)=\sum_{i=0}^{k} \dfrac{(-1)^{k-i} i^n}{i!(k-i)!}$配合一下预处理阶乘逆元即可 $O(k \log n)$ 解决。

```cpp
const int N = 1e6 + 5;
int n, k;
mint fac[N], ifac[N];
mint S(int n, int k) {
	mint res = 0;
	for (int i = 0; i <= k; i++) {
		if ((k - i) & 1) res -= mint(i).pow(n) * ifac[i] * ifac[k - i];
		else res += mint(i).pow(n) * ifac[i] * ifac[k - i];
	} return res;
}

void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cout << S(n, n - k);
}
```

### *P10591 BZOJ4671 异或图

好题。前置知识：15 章 Bell 数、22.3 高斯消元。建议先做完 [P10499 开关问题](https://www.luogu.com.cn/problem/P10499)。

看到 $n \le 10$ 一眼状压，然后就做不下去了。设 $f(x)$ 表示钦定 $x$ 个连通块之间两两不连通的方案数，$g(x)$ 表示恰好有 $x$ 个连通块两两不连通的方案数。根据第二类 Stirling 数定义

$f(x)=\sum_{i=x}^n S(i,x) \times g(i)$直接上 Stirling 反演：

$g(x)=\sum_{i=x}^{n} (-1)^{i-x} s(i,x) \times f(i)$所求为

$g(1)=\sum_{i=1}^n (-1)^{i-1} (i-1)! f(i)$只要求出 $f(x)$。因为 $n \le 10$ 可以考虑直接爆搜。注意到 $B_{10}=115975$，考虑搜索哪些点被分到同一个集合。对于每个集合，对于端点所属集合不同的边必须选偶数次。

到这里考虑列方程。设 $x_i$ 表示第 $i$ 个图是否属于子集，那么可以列出若干形如 $\bigoplus_{k \in S} x_k=0$ 的异或方程组。高斯消元以后可以确定一些 $x$ 一定属于 / 不属于该子集，剩下的自由元任选，方案数 $2^c$，加法原理合并即可。总复杂度 $O(n^4B_n)$。

实现上，注意输入格式转换成图。同时 $n \le 10$，不用 bitset 优化，可以直接状压存下。

```cpp
#define int long long
const int N = 105;
int n, m, a[N][20][20], x[N], id[N], f[N], fac[N];
char s[N * N];

int guass(int tot) {
	int cnt = m;
	for (int i = 1, cur = 1; i <= tot && cur <= m; cur++) {
		for (int j = i; j <= tot; j++) {
			if (x[j] >> cur & 1) {swap(x[i], x[j]); break;}
		}
		if (!(x[i] >> cur & 1)) continue;
		for (int j = i + 1; j <= tot; j++) {
			if (x[j] >> cur & 1) x[j] ^= x[i];
		} cnt--, i++;
 	} return cnt;
}
void dfs(int step) {
	if (step > n) {
		int tot = 0;
		for (int i = 1; i <= n; i++) {
			for (int j = i + 1; j <= n; j++) {
				if (id[i] == id[j]) continue;
				x[++tot] = 0;
				for (int k = 1; k <= m; k++) {
					if (a[k][i][j]) x[tot] |= 1LL << k;
				}
			}
		}
		return f[id[0]] += 1LL << guass(tot), void();
	}
	id[step] = ++id[0], dfs(step + 1), id[0]--;
	for (int i = 1; i <= id[0]; i++) id[step] = i, dfs(step + 1);
}

void _main() {
	cin >> m;
	for (int i = 1; i <= m; i++) {
		cin >> (s + 1);
		int len = strlen(s + 1), tot = 0;
		for (int j = 1; ; j++) {
			if (j * (j - 1) / 2 == len) {n = j; break;}
		}
		for (int j = 1; j <= n; j++) {
			for (int k = j + 1; k <= n; k++) a[i][j][k] = s[++tot] ^ 48;
		}
	}
	dfs(1);
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	int res = 0;
	for (int i = 1; i <= n; i++) {
		if (i & 1) res += fac[i - 1] * f[i];
		else res -= fac[i - 1] * f[i];
	} cout << res;
}
```

### *CF932E Team Work

显然答案为 $\sum_{i=1}^{n} C_n^i i^k$。根据常用性质 2 一路推式子：

$$
\begin{aligned}
ans&=\sum_{i=1}^{n} C_n^i i^k\\
&=\sum_{i=0}^{n} C_n^i i^k\\
&=\sum_{i=0}^{n} \dfrac{n!}{i!(n-i)!} \sum_{j=0}^k S(k,j) \times C_i^j\times j!\\
&=\sum_{i=0}^n \dfrac{n!}{i!(n-i)!} \sum_{j=0}^k S(k,j) \times \dfrac{1}{(i-j)}!\\
&=\sum_{i=0}^n \sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-i)!(n-j)!}\\
&=\sum_{j=0}^k \sum_{i=0}^n S(k,j) \times \dfrac{n!}{(n-i)!(n-j)!} \\
&=\sum_{j=0}^k S(k,j) \sum_{i=0}^n \dfrac{(n-j)!}{(n-i)!(i-j)!} \times \dfrac{n!}{(n-j)!}\\
&=\sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-j)!} \sum_{i=0}^n C_{n-j}^{n-i}\\
&=\sum_{j=0}^k S(k,j) \times \dfrac{n!}{(n-j)!} \times 2^{n-j}
\end{aligned}
$$

其中，$\dfrac{n!}{(n-j)!}$ 可以在递推中处理，提前递推好第二类 Stirling 数，预处理 $O(k^2)$，单次查询 $O(k)$。

```cpp
const int N = 5005;
int n, k;
mint s[N][N], fac[N];

void _main() {
	cin >> n >> k;
	if (k == 0) return cout << 1, void();
	s[0][0] = 1;
	for (int i = 1; i <= k; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = s[i - 1][j - 1] + s[i - 1][j] * j;
	}
	mint res = 0, p = 1;
	for (int i = 0; i <= min(n, k); i++) {
		res += s[k][i] * p * mint(2).pow(n - i);
		p *= n - i;
	} cout << res;
}
```

### *P6620 [省选联考 2020 A 卷] 组合数问题

看到组合数和多项式放到一起，考虑转下降幂。因为我们有如下结论：

$C_n^k k^{\underline m}=C_{n-m}^{k-m} n^{\underline m}$代数推导易证。考虑怎么将 $f(x)$ 转化为下降幂多项式 $f(x)=\sum_{i=0}^m b_i x^{\underline i}$。

根据 $x^{n}=\sum S(n,k) \times x^{\underline k}$，有

$$
\begin{aligned}
f(x)&=\sum_{i=0}^m a_i x^{i}\\
&=\sum_{i=0}^m a_i \sum_{j=0}^i S(i,j) x^{\underline j}\\
&=\sum_{i=0}^m x^{\underline j} \sum_{j=i}^m S(j,i) a_j
\end{aligned}
$$

对比一下系数得到 $b_i=\sum_{j=i}^m S(j,i) \times a_j$。将新的 $f(x)$ 代入原式：

$$
\begin{aligned}
ans&=\sum_{k=0}^n f(k) \times x^k \times C_{n}^k\\
&=\sum_{k=0}^n x^k C_{n}^k \sum_{i=0}^m b_i k^{\underline i}\\
&=\sum_{i=0}^m b_i n^{\underline i} \sum_{k=0}^n C_{n-i}^{k-i} x^k\\
&=\sum_{i=0}^m b_i n^{\underline i} \sum_{k=0}^{n-i} C_{n-i}^{k} x^{k+i}\\
&=\sum_{i=0}^m b_i x^i n^{\underline i} \sum_{k=0}^{n-i} C_{n-i}^{k} x^k 1^{n-i-k} \\
&=\sum_{i=0}^m b_i x^i n^{\underline i} (x+1)^{n-i}
\end{aligned}
$$

逆用二项式定理，最终得到一个 $O(m)$ 的式子。我们可以 $O(m^2)$ 递推出第二类 Stirling 数和 $n$ 的下降幂，此题解决。

```cpp
const int N = 1005;
int n, x, p, m, a[N], b[N], s[N][N], low[N];
int madd(int x, int y) {return x += y, x >= p ? x -= p : x;}
int mpow(int a, int b) {
	int res = 1; for (a %= p; b; a = 1LL * a * a % p, b >>= 1) {
		if (b & 1) res = 1LL * res * a % p;
	} return res;
}

void _main() {
	cin >> n >> x >> p >> m;
	for (int i = 0; i <= m; i++) cin >> a[i];
	s[0][0] = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = 1; j <= i; j++) s[i][j] = madd(s[i - 1][j - 1], 1LL * j * s[i - 1][j] % p);
	}  // 第二类 Stirling 数
	for (int i = 0; i <= m; i++) {
		for (int j = i; j <= m; j++) b[i] = madd(b[i], 1LL * a[j] * s[j][i] % p);
	}  // 下降幂系数
	for (int i = 0; i <= m; i++) {
		low[i] = 1;
		for (int j = 0; j < i; j++) low[i] = 1LL * low[i] * (n - j) % p;
	}  // n 的下降幂
	int res = 0;
	for (int i = 0; i <= m; i++) res = madd(res, 1LL * b[i] * mpow(x, i) % p * low[i] % p * mpow(x + 1, n - i) % p);
	cout << res;
}
```

类似套路的题：[P6667](https://www.luogu.com.cn/problem/P6667)，但需要用到笔者不会的多项式科技。

## 15. Bell 数

**Bell 数** $B_n$ 表示大小为 $n$ 的集合的划分方法数，参见 [A000110](https://oeis.org/A000110)。例如，对于集合 $\{1,2,3\}$，有 $5$ 种划分方法：

```dust
{1},{2},{3}
{1,2},{3}
{1,3},{2}
{1},{2,3}
{1,2,3}
```

所以 $B_3=5$。

## 15.1 递推公式

设 $B_n$ 对应集合 $\{a_1,a_2,a_3,\cdots,a_n\}$，$B_{n+1}$ 对应集合 $\{a_1,a_2,a_3,\cdots,a_n,a_{n+1}\}$，只需考虑元素 $a_{n+1}$ 的贡献。

当它和 $k$ 个元素分到一个子集时，还剩下 $n-k$ 个元素，则多出的方案数有 $C_{n}^{n-k} B_{n-k}$，且 $k \in [0,n]$。因此：

$B_{n+1}=\sum_{k=0}^{n} C_n^k B_k$仿照杨辉三角，可以构造一个 Bell 三角形：

- $a_{0,0}=1$；
- $a_{n,0}=a_{n-1,n-1}$；
- $a_{n,m}=a_{n,m-1}+a_{n-1,m-1}$。

此时 $B_n=a_{n,0}$。代码如下：

```cpp
int b[N][N];
void work() {
	b[0][0] = 1;
	for (int i = 1; i < N; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
}
```

可以发现在 $n \le 12$ 较小时 $O(B_n)$ 是可接受的复杂度。例题 [AT_abc390_d [ABC390D] Stone XOR](https://www.luogu.com.cn/problem/AT_abc390_d)。

## 15.2 与第二类 Stirling 数的关系

枚举划分成 $k$ 个非空集合，则每种情况的方案数为第二类 Stirling 数 $S(n,k)$。于是：

$B_n=\sum_{k=0}^n S(n,k)$这表明：Bell 数 $B_n$ 就是第 $n$ 行第二类 Stirling 数的和。因此可以 $O(n \log n)$ 地使用 NTT 计算。

事实上，由这个公式可以得到单次询问 $O(n)$ 求 $B_n$ 的方法。

## *15.3 性质

Bell 数有很多优美的性质。

1. 组合引理：

$B_{n+m} =\sum_{i=0}^{n} [C_n^i \times B_i \times \sum_{j=0}^{m} (j^{n-i} \times S(m,j))]$将 $n+m$ 个元素分成 $n,m$ 两部分。枚举 $m$ 个元素划分为 $j$ 个集合，方案数为 $S(m,j)$。再枚举 $n$ 个元素选 $i$ 个划分出来，方案数为 $C_n^i \times B_i$，则剩下 $n-i$ 个要放到 $j$ 个集合中，方案数 $j^{n-i}$。最后用乘法原理合并答案。

1. Dobinski 公式：

$B_n=\dfrac{1}{e} \sum_{k=0}^{\infty} \dfrac{k^n}{k!}$很神奇的一个级数求和。

1. Touchard 同余：若 $p$ 是质数，则

$B_{n+p} \equiv B_n+B_{n+1} \pmod p$其中结论 2&3 的证明过于复杂，这里不展开说明。如果有兴趣可以看 [这篇 Blog](https://www.cnblogs.com/HeNuclearReactor/p/17552175.html)。

## 15.4 例题

### *CF568B Symmetric and Transitive

做一个图论建模。由对称性可得这是一个无向图，不妨设图中存在 $i$ 个孤立点，则选出孤立点的方案数是 $C_n^i$。然后剩下的分配就是上面讲的集合划分问题，为 $B_{n-i}$。由加法、乘法原理可得所求为

$\sum_{i=1}^{n} C_n^i B_{n-i}$然后组合数用杨辉三角，Bell 数用 Bell 三角预处理即可。

```cpp
const int N = 4005;
int n;
mint b[N][N], c[N][N];

void _main() {
	cin >> n;
	b[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
	for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) res += c[n][i] * b[n - i][0];
	cout << res;
}
```

### *CF908E New Year and Entity Enumeration

好题。先扔掉 $T \subseteq S$ 这条限制。

因为 $M=2^m-1$，即二进制下全是 $1$，可以认为 $a \oplus M= \sim a$，即 $a$ 的无符号取反。

写出两条限制：

1. $\forall a \in S, \sim a \in S$。
2. $\forall a,b \in S, a \& b \in S$。

因为 $a | b=\sim (\sim a \& \sim b)$，根据性质 1&2 有

1. $\forall a,b \in S, a | b \in S$。

因为 $a \oplus b=\sim ((a\& b) | \sim(a | b))$，根据性质 1&2&3 有

1. $\forall a,b \in S, a \oplus b \in S$。

下文设 $d(x,y)$ 表示 $x$ 二进制下的第 $y$ 位。

设

$$
f(x)=\begin{cases}
 \text{AND}_{a \in S, d(a,x)=1 } \text{ } a & \exists a \in S, d(a,x)=1 \\
 0 & \forall a \in S, d(a,x)=0
\end{cases}
$$

先讨论 $S \ne \varnothing$，易得 $0 \in S$。则根据性质 2 可得 $f(x) \in S$。

注意到，$f(x) \ne 0$ 时定有 $d(f(x),x)=1$。设 $d(f(x),y)=1$ 且 $x \ne y$，可以发现 $d(f(y),x)=1$。

证明：反证法，设 $d(f(y),x)=0$，令 $m=f(x) \oplus f(y)$，则 $d(m,x)=1$ 且 $d(m,y)=0$，则 $m \notin S$，与性质 3 矛盾。

设集合 $A(x)=\{y \mid d(f(x),y)=1\}$，则对于 $A(x)$ 中的所有元素 $y$ 有 $A(x)=A(y)$。把所有相等的 $A(x)$ 视作一个集合，则一个神圣的 $S$ 会导致这 $n$ 位被划分为若干非空子集。

这样我们就得到了，一个合法的 $S$ 与将 $m$ 位划分为若干子集的方案一一对应。因此，$S$ 的数目为 Bell 数 $B_m$。

回头看 $T \subseteq S$ 这条限制，就是告诉你哪些 $f(x)$ 不属于一个集合。将所有连通块状压预处理出来，由乘法原理，答案即 $\prod B_{sz}$。时间复杂度 $O(m(m+n))$。

```cpp
const int N = 1005;
long long n, m, a[N];
char s[N];
mint b[N][N];

void _main() {
	cin >> m >> n;
	for (int i = 1; i <= n; i++) {
		cin >> (s + 1);
		for (int j = 1; j <= m; j++) {
			if (s[j] == '1') a[j] |= 1LL << (i - 1);
		}
	}
	map<long long, int> sz;
	for (int i = 1; i <= m; i++) sz[a[i]]++;

	b[0][0] = 1;
	for (int i = 1; i <= m; i++) {
		b[i][0] = b[i - 1][i - 1];
		for (int j = 1; j <= i; j++) b[i][j] = b[i - 1][j - 1] + b[i][j - 1];
	}
	mint res = 1;
	for (const auto& k : sz) res *= b[k.second][0];
	cout << res;
}
```

### P5748 集合划分计数

$O(n)$ 求 Bell 数的板子。观察数据范围，严格 $O(Tn)$ 的算法可以通过本题。推式子：

$$
\begin{aligned}
B_n&=\sum_{i=0}^n S(n,i) \\
&=\sum_{i=0}^{n} \sum_{j=0}^{i} \dfrac{(-1)^{j} (i-j)^n}{j!(i-j)!}\\
&=\sum_{i=0}^{n} \dfrac{(-1)^j}{j!} \sum_{j=0}^{i} \dfrac{(i-j)^n}{(i-j)!}\\
&=\sum_{j=0}^{n} \dfrac{(-1)^j}{j!} \sum_{i=j}^{n} \dfrac{(i-j)^n}{(i-j)!}\\
&=\sum_{j=0}^{n} \dfrac{(-1)^j}{j!} \sum_{i=0}^{n-j} \dfrac{i^n}{i!}
\end{aligned}
$$

内层循环预处理前缀和即可。至此可以做到 $O(Tn \log n)$，瓶颈在快速幂。

注意到 $i^n$ 是积性函数，线性筛预处理 $i^n$ 可以做到 $O(n)$。于是我们得到了单个 Bell 数的 $O(n)$ 求法。

```cpp
const int N = 1e5 + 5;
int n;
mint fac[N], ifac[N], pw[N], pre[N];
bitset<N> isprime;
vector<int> prime;

void prework() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	isprime.set(), isprime[0] = isprime[1] = 0;
	for (int i = 2; i < N; i++) {
		if (!isprime[i]) continue;
		prime.emplace_back(i);
		for (int j = i << 1; j < N; j += i) isprime[j] = 0;
	}
}
void solve() {
	pw[0] = 0, pw[1] = 1;
	for (int i = 2; i <= n; i++) {
		if (isprime[i]) pw[i] = mint(i).pow(n);
		for (int j : prime) {
			if (1LL * i * j > n || j > i) break;
			pw[i * j] = pw[i] * pw[j];
			if (i % j == 0) break;
		}
	}
}

void _main() {
	cin >> n;
	solve();
	for (int i = 1; i <= n; i++) pre[i] = pre[i - 1] + pw[i] * ifac[i];
	mint res = 0;
	for (int j = 0; j <= n; j++) {
		if (j & 1) res -= pre[n - j] * ifac[j];
		else res += pre[n - j] * ifac[j];
	} cout << res << '\n';
}
```

## 附：计数基础·斯特林数与贝尔数（stripe-python）

## 6. 斯特林数

## 6.1 第二类斯特林数

**第二类斯特林数** $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**非空子集的方案数。

我们可以用递推的思想来求解。考虑加入一个新元素的贡献：

- 将新元素单开一个子集，方案数 $\left\{\begin{matrix}
  n-1 \\
  m-1
  \end{matrix}\right\}$。
- 将新元素插入一个现有子集，方案数 $m\left\{\begin{matrix}
  n-1 \\
  m
  \end{matrix}\right\}$。

由加法原理合并得到递推式：
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\left\{\begin{matrix}
n-1 \\
m-1
\end{matrix}\right\}+m\left\{\begin{matrix}
n-1 \\
m
\end{matrix}\right\}
$$
可以做到 $O(n^2)$ 求解。

#### 6.1.1 通项公式

上面的式子复杂度还是太高了，我们考虑直接用组合数学方法求 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。记：

- $g(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**子集的方案数。
- $f(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**非空子集的方案数。

根据球盒模型我们知道 $g(m)=m^n$，又根据消序原理 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\dfrac{f(m)}{m!}$，所以只需配上容斥系数实现 $g \to f$ 的转化。

考虑枚举空集的数目，可以实现 $f \to g$ 的转化：
$$
g(m)=\sum_{i=0}^m \binom{m}{i} f(i)
$$
由二项式反演形式一，容斥系数 $(-1)^{m-i} \dbinom{m}{i}$。也即
$$
\begin{aligned}
f(m)&=\sum_{i=0}^m (-1)^{m-i} \binom{m}{i} g(i)\\
&=\sum_{i=0}^m (-1)^{m-i} \dfrac{m!}{i!(m-i)!} i^n\\
&=\sum_{i=0}^m \dfrac{(-1)^{m-i}i^n m!}{i!(m-i)!}
\end{aligned}
$$
消序后就得到通项公式
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}
= \sum_{i=0}^m \dfrac{(-1)^{m-i} i^n}{i!(m-i)!}
$$
这是一个卷积的形式：记 $f_i=\dfrac{i^n}{i!}$，$g_i=\dfrac{(-1)^i}{i!}$，则有 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=[x^m] FG$。容易在 $O(n \log n)$ 内求解同行第二类斯特林数。

### 6.2 第一类斯特林数

**第一类斯特林数** $\begin{bmatrix}
n \\
m
\end{bmatrix}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**轮换的方案数。轮换可以理解为一个圆排列。

那么仍然可以考虑加入一个新元素的贡献，进行递推求解：

- 将新元素单开一个轮换，方案数 $\begin{bmatrix}
  n-1 \\
  m-1
  \end{bmatrix}$。
- 插入一个现有轮换，方案数 $(n-1)\begin{bmatrix}
  n-1 \\
  m
  \end{bmatrix}$。

加法原理合并就得到递推公式
$$
\begin{bmatrix}
n \\
m
\end{bmatrix}=\begin{bmatrix}
n-1 \\
m-1
\end{bmatrix}+(n-1)\begin{bmatrix}
n-1 \\
m
\end{bmatrix}
$$
在 OI 中，可以认为第一类斯特林数没有通项公式。

根据第一类斯特林数的组合意义，有一个组合恒等式：
$$
\sum_{i=0}^n\begin{bmatrix}
n \\
i
\end{bmatrix}=n!
$$

### 6.3 贝尔数

**贝尔数** $B_n$ 表示将 $n$ 个**有标号**元素不重不漏地划分为若干非空集合的方案数。

根据第二类斯特林数的组合意义，贝尔数就是同行第二类斯特林数的和：
$$
B_n=\sum_{i=0}^m\left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
贝尔数还满足一个递推式：
$$
B_{n+1}=\sum_{i=0}^m \binom{n}{i} B_i
$$
原理是枚举第 $n+1$ 个元素所在集合的大小。上面的两种方法都能做到 $O(n^2)$ 计算贝尔数。

#### 6.3.1 求法

[P5748 集合划分计数](https://www.luogu.com.cn/problem/P5748)：

> $T$ 次询问求 $B_n \bmod 998244353$。
>
> $T =10^3$，$n \le 10^5$，1 秒，125 MB。

我们介绍两种做法。第一种做法可以 $O(n)$ 计算单个 $B_n$，第二种做法可以 $O(n \log n)$ 求出 $B_1 \sim B_n$。

:::::success[单个贝尔数的求法]

代入第二类斯特林数的通项公式：
$$
\begin{aligned}
B_n&=\sum_{k=0}^n \left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \\
&=\sum_{k=0}^{n} \sum_{i=0}^{k} \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n \sum_{k=i}^n \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{k=i}^n \dfrac{(-1)^{k-i}}{(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{j=0}^{n-i} \dfrac{(-1)^j}{j!}\\
\end{aligned}
$$
预处理 $\dfrac{(-1)^j}{j!}$ 的前缀和即可做到 $O(n \log n)$。考虑精细实现：

- 用线性倒推法求解阶乘逆元。
- 用线性筛预处理 $i^n$ 的值。

预处理后复杂度 $O(n)$。

:::::

:::::success[多个贝尔数的求法]

记贝尔数的 EGF 为 $F$，代入递推公式：
$$
\begin{aligned}
F(x)&=\sum_{n \ge 0} B_n \dfrac{x^n}{n!}\\
F'(x)&=\sum_{n \ge 0}B_{n+1} \dfrac{x^n}{n!}\\
&= \sum_{n \ge 0} \dfrac{x^n}{n!} \sum_{k=0}^n \binom{n}{k} B_k\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \binom{n}{k} \dfrac{x^n}{n!}\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \dfrac{x^n}{k!(n-k)!} \\
&= \sum_{k \ge 0} B_k \dfrac{x^k}{k!} \sum _{i \ge 0} \dfrac{x^i}{i!}\\
F'(x)&=F(x) \times e^x
\end{aligned}
$$
由微分方程 $F'=Fe^x$ 得 $\ln F=e^x+C$。代入 $F(0)=1$ 知 $C=-1$，因此我们得到了贝尔数的 EGF
$$
F(x)=\exp (e^x-1)
$$
两次多项式 $\exp$ 即可，复杂度 $O(n \log n)$。

:::::

#### 6.3.2 性质

在第二种方法中，我们求得了贝尔数的 EGF。据此还可以得到 Dobinski 公式
$$
B_n=\dfrac{1}{e} \sum_{k \ge 0} \dfrac{k^n}{k!}
$$
贝尔数对质数 $p$ 有如下同余式
$$
B_{n+p} \equiv B_n+B_{n+1} \pmod p 
$$
 称为 Touchard 同余。另外还有扩展 Touchard 同余
$$
B_{n+p^k}=kB_n+B_{n+1} \pmod p
$$
这两个定理我们不证。

### 6.4 应用

先给出两个定义：

- 上升幂 $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod\limits_{i=0}^{n-1} (x+i)$。
- 下降幂 $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod \limits_{i=0}^{n-1} (x-i)=A_x^n$。

斯特林数可以实现上升幂 / 下降幂 / 普通幂之间的相互转化。

上升幂和普通幂的转化：
$$
x^{\overline n}=\sum_{k=0}^n\begin{bmatrix}
n \\
k
\end{bmatrix}x^k \iff x^n=\sum_{k=0}^n (-1)^{n-k}\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\overline k}
$$
下降幂和普通幂的转化：
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\underline k} \iff x^{\underline n} =\sum_{k=0}^n (-1)^{n-k}\begin{bmatrix}
n \\
k
\end{bmatrix}x^k
$$
同组内的两个等式由斯特林反演得到。

其中普通幂转下降幂的式子又可以写作
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \binom{n}{k} k!
$$
这个公式非常重要，称为**拆幂公式**。见到与普通幂有关的题目时，都可以尝试用下降幂转化。

## 附：斯特林数专题笔记（stripe-python）

## 14.1 第二类斯特林数

**第二类斯特林数** $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**非空子集的方案数。

我们可以用递推的思想来求解。考虑加入一个新元素的贡献：

- 将新元素单开一个子集，方案数 $\left\{\begin{matrix}
  n-1 \\
  m-1
  \end{matrix}\right\}$。
- 将新元素插入一个现有子集，方案数 $m\left\{\begin{matrix}
  n-1 \\
  m
  \end{matrix}\right\}$。

由加法原理合并得到递推式：
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\left\{\begin{matrix}
n-1 \\
m-1
\end{matrix}\right\}+m\left\{\begin{matrix}
n-1 \\
m
\end{matrix}\right\}
$$
可以做到 $O(n^2)$ 求解。

### 14.1.1 通项公式

上面的式子复杂度还是太高了，我们考虑直接用组合数学方法求 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。记：

- $g(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**子集的方案数。
- $f(m)$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**有标号**非空子集的方案数。

根据球盒模型我们知道 $g(m)=m^n$，又根据消序原理 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=\dfrac{f(m)}{m!}$，所以只需配上容斥系数实现 $g \to f$ 的转化。

考虑枚举空集的数目，可以实现 $f \to g$ 的转化：
$$
g(m)=\sum_{i=0}^m \binom{m}{i} f(i)
$$
由二项式反演形式一，容斥系数 $(-1)^{m-i} \dbinom{m}{i}$。也即
$$
\begin{aligned}
f(m)&=\sum_{i=0}^m (-1)^{m-i} \binom{m}{i} g(i)\\
&=\sum_{i=0}^m (-1)^{m-i} \dfrac{m!}{i!(m-i)!} i^n\\
&=\sum_{i=0}^m \dfrac{(-1)^{m-i}i^n m!}{i!(m-i)!}
\end{aligned}
$$
消序后就得到通项公式
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}
= \sum_{i=0}^m \dfrac{(-1)^{m-i} i^n}{i!(m-i)!}
$$
这是一个卷积的形式：记 $f_i=\dfrac{i^n}{i!}$，$g_i=\dfrac{(-1)^i}{i!}$，则有 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}=[x^m] FG$。容易在 $O(n \log n)$ 内求解同行第二类斯特林数。

## 14.2 第一类斯特林数

**第一类斯特林数** $\begin{bmatrix}
n \\
m
\end{bmatrix}$ 表示将 $n$ 个**有标号**元素划分为 $m$ 个**无标号**轮换的方案数。轮换可以理解为一个圆排列。

那么仍然可以考虑加入一个新元素的贡献，进行递推求解：

- 将新元素单开一个轮换，方案数 $\begin{bmatrix}
  n-1 \\
  m-1
  \end{bmatrix}$。
- 插入一个现有轮换，方案数 $(n-1)\begin{bmatrix}
  n-1 \\
  m
  \end{bmatrix}$。

加法原理合并就得到递推公式
$$
\begin{bmatrix}
n \\
m
\end{bmatrix}=\begin{bmatrix}
n-1 \\
m-1
\end{bmatrix}+(n-1)\begin{bmatrix}
n-1 \\
m
\end{bmatrix}
$$
在 OI 中，可以认为第一类斯特林数没有通项公式。

根据第一类斯特林数的组合意义，有一个组合恒等式：
$$
\sum_{i=0}^n\begin{bmatrix}
n \\
i
\end{bmatrix}=n!
$$

## 14.3 贝尔数

**贝尔数** $B_n$ 表示将 $n$ 个**有标号**元素不重不漏地划分为若干非空集合的方案数。

根据第二类斯特林数的组合意义，贝尔数就是同行第二类斯特林数的和：
$$
B_n=\sum_{i=0}^m\left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
贝尔数还满足一个递推式：
$$
B_{n+1}=\sum_{i=0}^m \binom{n}{i} B_i
$$
原理是枚举第 $n+1$ 个元素所在集合的大小。上面的两种方法都能做到 $O(n^2)$ 计算贝尔数。

### 14.3.1 求法

[P5748 集合划分计数](https://www.luogu.com.cn/problem/P5748)：

> $T$ 次询问求 $B_n \bmod 998244353$。
>
> $T =10^3$，$n \le 10^5$，1 秒，125 MB。

我们介绍两种做法。第一种做法可以 $O(n)$ 计算单个 $B_n$，第二种做法可以 $O(n \log n)$ 求出 $B_1 \sim B_n$。

:::::success[单个贝尔数的求法]

代入第二类斯特林数的通项公式：
$$
\begin{aligned}
B_n&=\sum_{k=0}^n \left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \\
&=\sum_{k=0}^{n} \sum_{i=0}^{k} \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n \sum_{k=i}^n \dfrac{(-1)^{k-i}i^n}{i!(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{k=i}^n \dfrac{(-1)^{k-i}}{(k-i)!}\\
&=\sum_{i=0}^n\dfrac{i^n}{i!} \sum_{j=0}^{n-i} \dfrac{(-1)^j}{j!}\\
\end{aligned}
$$
预处理 $\dfrac{(-1)^j}{j!}$ 的前缀和即可做到 $O(n \log n)$。考虑精细实现：

- 用线性倒推法求解阶乘逆元。
- 用线性筛预处理 $i^n$ 的值。

预处理后复杂度 $O(n)$。

:::::

:::::success[多个贝尔数的求法]

记贝尔数的 EGF 为 $F$，代入递推公式：
$$
\begin{aligned}
F(x)&=\sum_{n \ge 0} B_n \dfrac{x^n}{n!}\\
F'(x)&=\sum_{n \ge 0}B_{n+1} \dfrac{x^n}{n!}\\
&= \sum_{n \ge 0} \dfrac{x^n}{n!} \sum_{k=0}^n \binom{n}{k} B_k\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \binom{n}{k} \dfrac{x^n}{n!}\\
&= \sum_{k \ge 0} B_k \sum_{n \ge k} \dfrac{x^n}{k!(n-k)!} \\
&= \sum_{k \ge 0} B_k \dfrac{x^k}{k!} \sum _{i \ge 0} \dfrac{x^i}{i!}\\
F'(x)&=F(x) \times e^x
\end{aligned}
$$
由微分方程 $F'=Fe^x$ 得 $\ln F=e^x+C$。代入 $F(0)=1$ 知 $C=-1$，因此我们得到了贝尔数的 EGF
$$
F(x)=\exp (e^x-1)
$$
两次多项式 $\exp$ 即可，复杂度 $O(n \log n)$。

:::::

### 14.3.2 性质

在第二种方法中，我们求得了贝尔数的 EGF。据此还可以得到 Dobinski 公式
$$
B_n=\dfrac{1}{e} \sum_{k \ge 0} \dfrac{k^n}{k!}
$$
贝尔数对质数 $p$ 有如下同余式
$$
B_{n+p} \equiv B_n+B_{n+1} \pmod p 
$$
 称为 Touchard 同余。另外还有扩展 Touchard 同余
$$
B_{n+p^k}=kB_n+B_{n+1} \pmod p
$$
这两个定理我们不证。

## 14.4 应用

先给出两个定义：

- 上升幂 $x^{\overline{n}}=x(x+1)(x+2)\cdots (x+n-1)=\prod\limits_{i=0}^{n-1} (x+i)$。
- 下降幂 $x^{\underline n}=x(x-1)(x-2)\cdots (x-n+1)=\prod \limits_{i=0}^{n-1} (x-i)=A_x^n$。

斯特林数可以实现上升幂 / 下降幂 / 普通幂之间的相互转化。

上升幂和普通幂的转化：
$$
x^{\overline n}=\sum_{k=0}^n\begin{bmatrix}
n \\
k
\end{bmatrix}x^k \iff x^n=\sum_{k=0}^n (-1)^{n-k}\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\overline k}
$$
下降幂和普通幂的转化：
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} x^{\underline k} \iff x^{\underline n} =\sum_{k=0}^n (-1)^{n-k}\begin{bmatrix}
n \\
k
\end{bmatrix}x^k
$$
同组内的两个等式由斯特林反演得到。

其中普通幂转下降幂的式子又可以写作
$$
x^n=\sum_{k=0}^n\left\{\begin{matrix}
n \\
k
\end{matrix}\right\} \binom{n}{k} k!
$$
这个公式非常重要，称为**拆幂公式**。见到与普通幂有关的题目时，都可以尝试用下降幂转化。$AKB339$, '数学', array['斯特林数', '贝尔数', '第二类斯特林数', '多项式'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-triangle-area-existence--stripe-python', '坐标系中三角形面积的存在性 · stripe-python', $AKB340$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 背景

之前周练考了，把叉乘乘反了，-9pts。

据说不咋考了，不过还是写一下，期末考 rp++ 触底反弹（

## 例题

借用周练题。

如图，$y=-\dfrac{6}{x}$ 上有两点 $A(-2,3),B(6,-1)$，若点 $P$ 在 $y=-\dfrac{6}{x}$ 上，且 $S_{\triangle APB}=8$，求点 $P$ 坐标。

![](https://cdn.luogu.com.cn/upload/image_hosting/9e4tlkqv.png)

先设 $P(x,-\dfrac{6}{x})$，并易得 $y_{AB}=-\dfrac{1}{2}x+2$。

## 方法一：铅垂法

常规方法。我们先找一个点 $P$，过 $P$ 竖割，如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/tvu6olze.png)

则 $S_{\triangle APB}=S_{\triangle ACP}+S_{\triangle BCP}=\dfrac{1}{2}CP \times h_1+\dfrac{1}{2}CP \times h_2=\dfrac{1}{2} CP \times |x_B-x_A|$。

这个方法可以简记为：**三角形面积是水平宽乘铅垂高的一半。**

本题中，$C(x,-\dfrac{1}{2}x+2)$，故 $\dfrac{1}{2} \times  |-\dfrac{1}{2}x+2-(-\dfrac{6}{x})| \times [6-(-2)]=8$。

草稿纸在[这里](https://www.luogu.com.cn/paste/ntdyrl3k)，最后可得答案：

$$
P_1(2\sqrt{3},-\sqrt{3}), P_2(-2\sqrt{3},\sqrt{3})\\
P_3(4+2\sqrt{7},2-\sqrt{7}), P_4(4-2\sqrt{7},2+\sqrt{7})
$$

## 方法二：等积变形

考虑三角形的底是 $AB=4\sqrt{5}$，则顶点 $P$ 对应的高 $h=\dfrac{4\sqrt{5}}{5}$。

由平行线间距离处处相等，作 $l_1,l_2 \mathop{//} AB$，使距离为 $h$ 即可。$l_1,l_2$ 与 $y=-\dfrac{6}{x}$ 交于四点，这四点即为所求。

![](https://cdn.luogu.com.cn/upload/image_hosting/zunx05lv.png)

现在只需要求出 $l_1,l_2$ 的方程联立即可。设 $y=-\dfrac{1}{2}x+b$，由平行线距离公式 $\dfrac{|b_1-b_2|}{\sqrt{k^2+1}}$ 可得：

$\dfrac{|b-2|}{\sqrt{\dfrac{5}{4}}}=\dfrac{4\sqrt{5}}{5}$

这样解得 $b_1=0,b_2=4$，将 $y=-\dfrac{1}{2}x$ 与 $-\dfrac{1}{2}x+4$ 分别与 $y=-\dfrac{6}{x}$ 联立即可求得：

$$
P_1(2\sqrt{3},-\sqrt{3}), P_2(-2\sqrt{3},\sqrt{3})\\
P_3(4+2\sqrt{7},2-\sqrt{7}), P_4(4-2\sqrt{7},2+\sqrt{7})
$$

## 方法三：作高法

直接过 $P$ 作高，有 $S_{\triangle APB}=\dfrac{1}{2} \times AB \times h$。

应用点到直线距离公式 $\dfrac{|kx+b-y|}{\sqrt{k^2+1}}$ 列方程：

$\dfrac{1}{2} \times 4\sqrt{5} \times \dfrac{|-\dfrac{1}{2}x+2-(-\dfrac{6}{x})|}{\sqrt{\dfrac{5}{4}}}=8$这个方程整理后与方法一一致，解得：

$$
P_1(2\sqrt{3},-\sqrt{3}), P_2(-2\sqrt{3},\sqrt{3})\\
P_3(4+2\sqrt{7},2-\sqrt{7}), P_4(4-2\sqrt{7},2+\sqrt{7})
$$

## 方法四：公式法

唯 一 真 神。

应用向量叉乘，对于 $A(x_1,y_1),B(x_2,y_2)$ 和原点围成的三角形，有公式：

$S_{\triangle AOB}=\dfrac{1}{2}|x_1y_2-y_1x_2|$加入一点 $C(x_3,y_3)$，变换坐标系，原点到 $A$ 点，可得公式：

$S_{\triangle ABC}=\dfrac{1}{2}|(x_3-x_1)(y_2-y_1)-(y_3-y_1)(x_2-y_1)|$> 这个公式笔者自己编了口诀：三减一乘二减一，减号两边 xy 换，绝对值再取一半。

在本题中，可列方程：

$\dfrac{1}{2}|-4(x+2)-8(-\dfrac{6}{x}-3)|=8$这个方程整理后与方法一一致，解得：

$$
P_1(2\sqrt{3},-\sqrt{3}), P_2(-2\sqrt{3},\sqrt{3})\\
P_3(4+2\sqrt{7},2-\sqrt{7}), P_4(4-2\sqrt{7},2+\sqrt{7})
$$

## 总结

遇到无法直接算的三角形面积，可以采用铅垂法、等积变形、作高法、公式法解题。一般在坐标系中，三角形面积的存在性问题有多个答案，要注意分类讨论，合理取舍。$AKB340$, '数学', array['三角形面积', '坐标系', '几何', '叉乘'], 'col-math-oi-foundations', null, 'knowledge');

do $$
declare
    v_missing text;
begin
    select string_agg(distinct s.author_name, '、') into v_missing
    from _akb_seed_columns s
    left join public.profiles p on p.nickname = s.author_name
    where p.id is null;

    if v_missing is not null then
        raise exception '缺少作者 profile：%', v_missing;
    end if;
end $$;

insert into public.columns (
    owner_id, column_key, column_name, content, tags, category, parent_key,
    relations, difficulty, kind, status
)
select
    p.id, s.column_key, s.column_name, s.content, s.tags, s.category,
    s.parent_key, '[]'::jsonb, s.difficulty, s.kind, 'published'
from _akb_seed_columns s
join public.profiles p on p.nickname = s.author_name
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    content = excluded.content,
    tags = excluded.tags,
    category = excluded.category,
    parent_key = excluded.parent_key,
    difficulty = excluded.difficulty,
    kind = excluded.kind,
    status = 'published',
    updated_at = now();

drop table if exists _akb_seed_columns;

commit;
