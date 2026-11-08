-- ============================================================
-- AKB 专栏种子：知识点 / 数学
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：62 行
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
('world-needs-sunday', 'col-hub-math-number-theory', '数论总述', $AKB264$## 算法原理

数论在竞赛里主要处理三类问题：**判定与分解**（这个数是不是素数、怎么分解质因数）、**同余方程**（求解模意义下的方程与逆元）、**批量求和与计数**（在 $1\sim n$ 上做整除相关的统计）。

本页是「数学」大类下的二级总述，把数论相关知识点按工具分五组：

- **同余与模运算**：快速幂、乘法逆元、Modint 封装、费马小定理与扩展欧拉定理（降幂）。
- **素数**：素性判定、埃氏筛与线性筛、算术基本定理、威尔逊定理、Miller-Rabin、Pollard-Rho。
- **公约数**：gcd / lcm、裴蜀定理、扩展欧几里得、解线性同余方程。
- **数论函数**：欧拉函数及其线性筛、约数个数与约数和。
- **整除与转化**：整除分块（数论分块）、同余最短路（把同余条件转成图上最短路）。

所有结论都要先确认**适用范围**：逆元存在要求 $\gcd(a,m)=1$；费马小定理要求 $m$ 为素数；扩展欧拉定理用于指数极大时降幂，且 $b\ge\varphi(m)$ 才成立。

## 核心公式 / 状态定义与转移方程

- 快速幂：$a^b \bmod p$ 按二进制拆分，$a^{2^k}$ 逐层平方。
- 逆元：$a^{-1}\equiv a^{p-2}\pmod p$（$p$ 素数），或解 $ax+my=1$。
- 线性筛：每个合数只被其最小质因子筛掉一次。
- 欧拉函数：$\varphi(n)=n\prod_{p\mid n}(1-\frac{1}{p})$。
- 整除分块：$\sum_{i=1}^{n} f(i)\lfloor n/i\rfloor$ 中 $\lfloor n/i\rfloor$ 只有 $O(\sqrt n)$ 种取值，右端点 $r=\lfloor n/\lfloor n/l\rfloor\rfloor$。

## 逐行代码解析

本页是总述页，不附实现；快速幂、筛法、exgcd、欧拉函数、整除分块等模板在各子条目中给出，并配套逐行注释与边界处理。

## 复杂度分析

- 快速幂：$O(\log b)$。
- 埃氏筛 $O(n\log\log n)$；线性筛 $O(n)$。
- 试除分解 $O(\sqrt n)$；Pollard-Rho 期望约 $O(n^{1/4})$ 次乘法。
- 扩展欧几里得 $O(\log n)$。
- 整除分块 $O(\sqrt n)$。

## 适用场景

- 需要在大指数、模意义下做乘除与幂运算。
- 需要判定素数、分解大整数、求离散对数。
- 需要解同余方程 / 线性同余方程组。
- 需要统计与整除、约数、欧拉函数相关的量。
- 不适合：数据范围小、直接枚举即可的题目，硬套数论工具反而增加常数与出错面。

## 常见陷阱与注意事项

- 负数取模没有调整到非负。
- 乘法溢出：中间量需要 `long long` 甚至 `__int128`。
- 模数与底数不互质时直接套费马小定理求逆元。
- 筛法数组开小；把 $1$ 当成素数。
- 多组数据没有清空与模数相关的全局数组。
- 扩展欧拉定理降幂时漏判 $b<\varphi(m)$ 的情况。

## 对比与扩展

数论与组合计数、矩阵加速、图论都有交叉：组合数取模需要阶乘逆元，线性递推用矩阵快速幂，同余条件可以建成最短路模型（同余最短路）。学习顺序建议：gcd 与快速幂 → 筛法与分解 → 逆元与同余方程 → 欧拉函数与数论定理 → 整除分块、同余最短路等应用。$AKB264$, '数学', array['数论', '总述', '学习路线'], null, null, 'knowledge'),
('world-needs-sunday', 'col-hub-math', '数学总述', $AKB265$## 算法原理

竞赛数学主要解决两类问题：**数论计算**与**组合计数**。它们的共同点是把一个看似需要枚举的过程，转化为可递推、可快速幂、可筛法的公式。

本大类覆盖的内容可以按工具分组：

- **数论基础**：整除、gcd/lcm、扩展欧几里得、欧拉函数、素数筛、分解质因数、同余与模运算、乘法逆元、中国剩余定理、BSGS、Miller-Rabin、Pollard-Rho。
- **计数与组合**：组合数、隔板法、容斥、二项式定理、整数分拆。
- **线性代数与矩阵**：矩阵乘法、矩阵快速幂、线性递推、高斯消元。
- **其他基础**：快速幂、高精度幂、分数运算、复数、集合与位运算、笛卡尔平面、群论。

数学题的难点通常不在代码，而在**把题目条件翻译成方程或计数模型**。

## 核心公式 / 状态定义与转移方程

常用的分析入口：

1. **确定运算所在的代数结构**：整数、模意义下的剩余系、矩阵、多项式。
2. **把条件写成同余式或方程**：例如“能被 $a$ 整除且余 $b$”写成 $x\equiv b\pmod a$。
3. **选择求解工具**：线性同余用 exgcd，模数为合数用 CRT 或 exCRT，离散对数用 BSGS，大数分解用 Pollard-Rho。
4. **计数题先定“对象”与“等价类”**：再决定用组合数、隔板法还是容斥。

所有公式都要注意适用范围：逆元要求模数与底数互质，费马小定理要求模数为素数，CRT 要求模数两两互质（否则需要扩展版本）。

## 逐行代码解析

本篇是大类总述，不附具体实现。各子分类的模板代码、逐行注释与边界处理在对应知识点页中；快速幂、筛法、exgcd、矩阵快速幂等条目都给出了可直接复用的骨架。

## 复杂度分析

常见量级：

- 快速幂：$O(\log n)$。
- 埃氏筛：$O(n\log\log n)$；线性筛：$O(n)$。
- 试除法分解：$O(\sqrt n)$；Pollard-Rho 期望约为 $O(n^{1/4})$ 次乘法。
- 扩展欧几里得：$O(\log n)$。
- 矩阵快速幂：$O(k^3\log n)$，其中 $k$ 为矩阵阶数。
- 高斯消元：$O(n^3)$。
- 组合数预处理：$O(n)$ 阶乘与逆元，单次查询 $O(1)$。

具体量级以各子条目的代码为准。

## 适用场景

- 需要取模后做加减乘除、求逆元、解同余方程。
- 需要统计方案数、路径数、合法序列数。
- 需要处理超大指数、线性递推、矩阵加速。
- 需要判断素数、分解大整数、求离散对数。
- 不适合：题目本质是模拟或搜索，硬套数学公式反而增加出错面。

## 常见陷阱与注意事项

- 模运算中负数取模未调整到非负。
- 乘法溢出不使用 `long long` 或 `__int128`。
- 逆元在模数与底数不互质时直接套费马小定理。
- 筛法数组开小，或把 1 当成素数。
- 矩阵乘法顺序写反；快速幂的单位矩阵没有初始化。
- 组合数预处理的上界小于实际询问的 $n$。
- 多测题忘记清空与模数相关的全局数组。

## 对比与扩展

数学与动态规划、图论、字符串都有交叉：计数 DP 用组合数，矩阵快速幂加速线性递推，字符串哈希依赖模运算，图论中的方案计数常与矩阵乘法结合。学习顺序建议先打牢 gcd、快速幂、筛法与模运算，再进入逆元、CRT、组合计数与矩阵，最后处理 BSGS、Miller-Rabin、Pollard-Rho 等大数工具。$AKB265$, '数学', array['数学', '总述', '学习路线'], null, null, 'knowledge'),
('Fohen', 'col-math-01-fractional--fenfeng', '0/1 分数规划 · Fohen', $AKB266$## 算法原理

0/1 分数规划解决一类**比值最优化**问题：有 $n$ 个元素，第 $i$ 个元素带两个正整数属性 $a_i$ 与 $b_i$，要在满足一定约束的前提下选出一个子集 $S$，使比值

$$
\frac{\sum_{i \in S} a_i}{\sum_{i \in S} b_i}
$$

达到最大（求最小可对称处理）。以「恰好选 $k$ 个」为例，设 $s_i \in \{0,1\}$ 表示第 $i$ 个元素是否被选，目标即

$$
\max \frac{\sum_{i=1}^{n} a_i s_i}{\sum_{i=1}^{n} b_i s_i},\quad s_i \in \{0,1\},\ \sum_{i=1}^{n} s_i = k
$$

暴力枚举子集是 $O(2^n)$，完全不可接受。核心思想是**二分答案**：先猜一个值 $x$，判断「是否存在方案使比值 $\ge x$」。因为 $b_i > 0$、分母恒正，可安全移项：

$$
\frac{\sum a_i s_i}{\sum b_i s_i} \ge x \iff \sum s_i\,(a_i - x b_i) \ge 0
$$

令 $c_i = a_i - x b_i$，判定就退化成「是否存在方案使 $\sum_{i \in S} c_i \ge 0$」。这个判定通常远比原问题简单：例如「恰好选 $k$ 个」时，只要取 $c_i$ 最大的 $k$ 个求和即可。

答案具有**单调性**：若在 $x$ 处存在可行方案，则对所有更小的 $x$ 也一定可行。于是可以二分 $x$：可行则上调下界，不可行则下调上界，逐步逼近最优值。

## 核心公式

0/1 分数规划的关键，是把「分数形式的目标」通过二分转成「线性形式的判定」。设答案为 $x$，判定式：

$$
\sum_{i=1}^{n} s_i\,(a_i - x b_i) \ge 0
$$

即令

$$
c_i = a_i - x b_i
$$

后判断 $\sum_{i \in S} c_i$ 是否可能非负。移项的依据是 $b_i > 0$ 且 $\sum b_i s_i > 0$，乘到右边不改变不等号方向。整个算法就是「二分 $x$ + 按约束对 $c_i$ 做内层判定」。

## 逐行代码解析

二分答案的整体框架如下（伪代码，`check(x)` 按具体约束实现）：

```cpp
// 二分答案：check(x) 判断是否存在方案使比值 >= x
double l = 0, r = max(a[i] / b[i]);   // 答案区间，r 取单个比值的最大值
for (int it = 0; it < 60; it++) {     // 固定迭代次数，精度更稳
    double mid = (l + r) / 2;
    if (check(mid)) l = mid;          // 可行，答案可以更大
    else            r = mid;          // 不可行，答案需要更小
}

bool check(double x) {
    for (int i = 1; i <= n; i++)
        c[i] = a[i] - x * b[i];       // 计算 c_i = a_i - x*b_i
    // 按约束判断 sum(c_i) 是否能 >= 0：
    //   恰好选 k 个 → 排序取前 k 大求和
    //   无限制任选 → 累加所有正的 c_i
    //   重量受限   → 以 c_i 为价值跑 0/1 背包
}
```

要点：

- `r` 的初值可取 $\max \frac{a_i}{b_i}$，因为最优比值不会超过单个元素的比值最大值。
- 二分用「固定迭代次数」（如 60 次）比 `while (r - l > eps)` 更容易控制精度，也能避免浮点死循环。
- `check(x)` 只回答「存在 / 不存在」，不是「所有方案是否都满足」，二者不要混淆。

## 复杂度分析

- **时间复杂度**：视具体实现。外层二分为 $O(\log V)$ 次（$V$ 为二分区间长度与所需精度的比值），再乘以内层判定的开销。常见内层判定：恰好选 $k$ 个为 $O(n \log n)$，重量受限背包为 $O(nW)$，生成树为 $O(m \log m)$，判环为 $O(nm)$。
- **空间复杂度**：视具体实现。通常 $O(n)$ 用于存储 $a_i, b_i, c_i$，再加上内层判定所需结构（如背包的 $O(W)$、存图的 $O(n+m)$）。

## 适用场景

- 求**最大 / 最小比值**的优化问题，例如性价比、单位时间收益、最优比率生成树、最优比率环等。
- 原目标带分数、难以直接优化，但「给定 $x$ 判断可行性」容易实现时，用二分转判定。
- 与 0/1 背包、生成树、最短路、网络流等经典算法结合，构成「外层二分 + 内层判定」的统一模板。

## 常见陷阱与注意事项

1. **分母必须恒正**：$b_i > 0$ 才能保证移项时不等号方向不变；若分母可能为负或为 0，需单独讨论，不能直接乘过去。
2. **精度控制**：二分迭代次数不足或 `eps` 设得过大，会导致答案精度不够；浮点运算用 `double` / `long double` 并固定迭代次数更稳妥。
3. **判定语义**：`check(x)` 判断的是「是否存在方案使比值 $\ge x$」，不要写成「所有方案都 $\ge x$」。
4. **贪心不通用**：「取前 $k$ 大」只适用于「恰好选 $k$ 个」且无附加限制；一旦有重量、连通性等约束，就要换成背包、生成树、网络流等对应判定。
5. **$c_i$ 符号**：$x$ 较大时 $c_i = a_i - x b_i$ 可能全为负，内层判定会稳定返回「不可行」，这是二分向回收敛的正常现象。

## 对比与扩展

不同约束下，内层判定方法随之变化：

| 题目约束 | 内层判定方法 | 复杂度 |
|---|---|---|
| 无限制，任选 | 把所有正的 $c_i$ 相加，判断是否 $\ge 0$ | $O(n)$ |
| 恰好选 $k$ 个 | 对 $c_i$ 排序，取最大的 $k$ 个求和 | $O(n \log n)$ |
| 总重量 $\le W$（背包） | 以 $c_i$ 为价值、$w_i$ 为重量跑 0/1 背包 | $O(nW)$ |
| 选出的边构成生成树 | 以 $c_i$ 为边权求最大生成树 | $O(m \log m)$ |
| 选出的边构成环 | 以 $c_i$ 为边权判定正环 / 负环 | $O(nm)$ |
| 选出的点构成闭合子图 | 转化为最小割跑网络流 | 视问题而定 |

扩展方面：分数规划也可用 **Dinkelbach 迭代法**求解，它在每轮固定当前比值、直接解一次线性目标的最优解来更新答案，通常比二分收敛更快；二分答案与 Dinkelbach 都建立在「比值目标可线性化」这一共同基础上。$AKB266$, '数学', array['数学', '数论', '分数规划', '二分答案'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-01-fractional--stripe-python', '0/1 分数规划 · stripe-python', $AKB267$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 21. 分数规划

分数规划一般与其他算法一起出现，比如：

- 与 01 背包结合，称为最优比率背包；
- 与最小生成树结合，称为最优比率生成树；
- 与最短路结合，称为最优密度路径；
- 与 SPFA 判负环结合，称为最优比率环；
- 与网络流结合，称为最优密度子图。

## 21.1 模型

分数规划的基本模型是：有 $n$ 个物品，每种物品有两个权值 $a,b$，选出若干个最大化或最小化 $\dfrac{\sum a} {\sum b}$。

最常见的模型里每种物品只有选与不选两种可能，因而又被称作 01-分数规划。

## 21.2 解法

最值问题且满足单调性，二分启动。以最大值为例，我们二分答案 $mid$，则

由

$\dfrac{\sum a_i} {\sum b_i} > mid$可得

$\sum a_i - mid \times \sum b_i > 0$即

$\sum (a_i-mid \times b_i) > 0$由此得到二分的判定式。在分数规划的问题中，我们需要用其他方法求出 $\sum (a_i-mid \times b_i)$ 的最值并与 $0$ 比较。

## 21.3 例题

最大密度子图板子是 [UVA1389 Hard Life](https://www.luogu.com.cn/problem/UVA1389)，但是要用到笔者不会的网络流知识，这里就不讲了。

### P10505 Dropping Test

分数规划板子。二分不变，可以贪心地去选，按 $a_i-mid \times b_i \ge 0$ 排个序选最大的 $n-k$ 个。分数规划结合贪心。

```cpp
const double eps = 1e-8;
int n, k, a[N], b[N];
double c[N];
bool check(double x) {
	for (int i = 1; i <= n; i++) c[i] = a[i] - b[i] * x;
	sort(c + 1, c + n + 1, greater<double>());
	return accumulate(c + 1, c + n - k + 1, 0.0) >= 0.0;
}

void _main() {
	cin >> n >> k;
	if (n == 0 && k == 0) exit(0);
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	double l = 0.0, r = 1.0;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << round(l * 100.0) << '\n';
}
```

### P4377 [USACO18OPEN] Talent Show G

仔细审题可以发现，这题等价于上面的模型，加入一个 $\sum b_i \ge W$ 的限制。

$\sum b_i \ge W$ 可以想到背包的容量，于是以 $b_i$ 为重量，$a_i-mid \times b_i$ 为体积跑 01 背包即可。如果不会 01 背包推荐我的[背包笔记](https://www.luogu.com.cn/article/6gosht8f)。复杂度 $O(nw \log V)$。分数规划结合 01 背包。

```cpp
const int N = 1e5 + 5;

long long n, w, a[N], b[N];
const double eps = 1e-8;

double dp[N];
inline bool check(double x) {
	for (int i = 1; i <= w; i++) dp[i] = -1e9;
	for (int i = 1; i <= n; i++) {
		for (int j = w; j >= 0; j--) {
			dp[min(w, j + b[i])] = max(dp[min(w, j + b[i])], dp[j] + a[i] - x * b[i]);
		}
	} return dp[w] > 0;
}

void _main() {
	cin >> n >> w;
	for (int i = 1; i <= n; i++) cin >> b[i] >> a[i];
	double l = 0.0, r = 1e9;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) l = mid;
		else r = mid;
	} cout << (long long) (1000 * l + eps);
}
```

### U589727 最优比率生成树

还是二分，接下来我们以 $a_i-mid \times b_i$ 为边权跑最小生成树，判断边权和是否大于 $0$ 即可。注意本题是完全图，用 prim 跑最小生成树更优。分数规划结合最小生成树。

```cpp
const int N = 1005;
int tot = 0, head[N];
int val[N][N], cost[N][N];
double w[N][N];

int n, m, u, v, x, y;
const double eps = 1e-4;

bool vis[N];
double dis[N];
inline bool check(double x) {
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) w[i][j] = x * cost[i][j] - val[i][j];
	}
	memset(vis, 0, sizeof(vis)), fill(dis + 1, dis + n + 1, -1e9);
	dis[1] = 0;
	for (int i = 1; i < n; i++) {
		int x = 0;
		for (int j = 1; j <= n; j++) {
			if (!vis[j] && (x == 0 || dis[j] > dis[x])) x = j;
		}
		vis[x] = true;
		for (int j = 1; j <= n; j++) {
			if (!vis[j]) dis[j] = max(dis[j], w[x][j]);
		}
	}
	double res = 0;
	for (int i = 2; i <= n; i++) res += dis[i];
	return res > 0;
}

void _main() {
	cin >> n;
	m = n * (n - 1) / 2;
	double l = 0.0, r = 5e6;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> x >> y;
		val[u][v] = val[v][u] = x;
		cost[u][v] = cost[v][u] = y;
	}
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (check(mid)) r = mid - eps;
		else l = mid + eps;
	} cout << fixed << setprecision(2) << l;
}
```

### P3199 [HNOI2009] 最小圈

人话就是求一个环 $C$ 使得 $\dfrac{\sum_{e \in C} w_e}{|C|}$ 最小。还是二分，这题 $b_i=1$，所以以 $a_i-mid$ 为边权。因为我们只需要判最小环是否小于 $0$，所以用 SPFA 判负环即可。分数规划结合 SPFA 判负环。

```cpp
const int N = 1e4 + 5;
const double eps = 1e-10;

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
int n, m, u, v; double w;

deque<int> q;
double dis[N]; int cnt[N];
bitset<N> vis;

inline bool spfa(int s, double x) {
	for (int i = 1; i <= n; i++) dis[i] = 1e9;
	q.clear(), memset(cnt, 0, sizeof(cnt)), vis.reset();
	q.emplace_back(s), dis[s] = 0, vis[s] = 1, cnt[s] = 1;
	while (!q.empty()) {
		int u = q.front(); q.pop_front(), vis[u] = 0;
		if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (++cnt[v] >= n) return true;
				if (vis[v]) continue;
				vis[v] = 1, q.emplace_back(v);
				if (!q.empty() && dis[q.front()] > dis[q.back()]) swap(q.front(), q.back());
			}
		}
	}
	return false;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> u >> v >> w, add_edge(u, v, w);
	double l = -1e7, r = 1e7;
	while (r - l > eps) {
		double mid = (l + r) / 2;
		if (spfa(1, mid)) r = mid;
		else l = mid;
	} cout << fixed << setprecision(8) << l;
}
```

但是这题即使用 SLF+swap 的 SPFA 也只有 90pts，使用玄学的 DFS-SPFA 可以水过：

> 注意：DFS-SPFA 使用必须慎重，其最差复杂度为指数级。

```cpp
double dis[N];
bool vis[N];

bool dfs(int u, double x) {
	vis[u] = true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to; double w = edge[j].dis - x;
		if (dis[v] > dis[u] + w) {
			dis[v] = dis[u] + w;
			if (vis[v] || dfs(v, x)) return true;
		}
	} return vis[u] = false;
}
inline bool check(double x) {
	fill(dis + 1, dis + n + 1, 0.0), fill(vis + 1, vis + n + 1, false);
	for (int i = 1; i <= n; i++) {
		if (dfs(i, x)) return true;
	} return false;
}
```

### P1730 最小密度路径

还是分数规划的模型，二分起手，这题 $a_i=w,b_i=1$，然后以 $w-mid$ 为边权从 $u$ 到 $v$ 跑 SPFA 最短路即可。这题是最小值，所以就是判最短路小于 $0$。因为这题 $q$ 个询问只有 $O(n^2)$ 个本质不同，打个记忆化即可。分数规划结合最短路。

```cpp
const int N = 1005;
const double eps = 1e-5;
int n, m, u, v, w, q;
double ans[N][N];

int tot = 0, head[N];
struct Edge {
	int next, to;
	double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}
double dis[N];
bool vis[N];
inline bool spfa(int s, int t, double x) {
	fill(dis + 1, dis + n + 1, 1e9), memset(vis, 0, sizeof(vis));
	queue<int> q;
	q.emplace(s), dis[s] = 0, vis[s] = true;
	while (!q.empty()) {
		int u = q.front(); q.pop();
		vis[u] = false;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to; double w = edge[j].dis - x;
			if (dis[v] > dis[u] + w) {
				dis[v] = dis[u] + w;
				if (vis[v]) continue;
				vis[v] = true, q.emplace(v);
			}
		}
	} return dis[t] < 0;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w;
		add_edge(u, v, w);
	} cin >> q;
	while (q--) {
		cin >> u >> v;
		if (ans[u][v] != 0) {
			if (ans[u][v] == -1) cout << "OMG!\n";
			else cout << fixed << setprecision(3) << ans[u][v] << '\n';
			continue;
		}
		double l = 0.0, r = 1e5, res = -1;
		while (r - l > eps) {
			double mid = (l + r) / 2.0;
			if (spfa(u, v, mid)) r = mid, res = r;
			else l = mid;
		}
		if (res == -1) ans[u][v] = -1, cout << "OMG!\n";
		else cout << fixed << setprecision(3) << (ans[u][v] = res) << '\n';
	}
}
```$AKB267$, '数学', array['分数规划', '二分答案', '最优比率'], 'col-math-oi-foundations', null, 'knowledge'),
('Xesir', 'col-math-01-fractional--xesir', '0/1 分数规划 · Xesir', $AKB268$## 算法原理

### 问题模型

给定两个长度为 $n$ 的正整数列 $a_1, a_2, \dots, a_n$ 与 $b_1, b_2, \dots, b_n$ 和正整数 $k$，求

$$
\max \frac{\sum_{i=1}^{n} a_i s_i}{\sum_{i=1}^{n} b_i s_i}, \qquad s_i \in \{0,1\},\ \sum_{i=1}^{n} s_i = k
$$

说白了就是：$n$ 个物品，每个物品有两个属性 $a_i$、$b_i$，要选出 $k$ 个，让"选出的 $a$ 之和"除以"选出的 $b$ 之和"最大。

### 解法

暴力枚举子集复杂度是 $O(2^n)$ 的，完全无法接受。

我们可以考虑二分，先猜测一个值 $x$，判断是否存在方案使

$$
\frac{\sum_{i=1}^{n} a_i s_i}{\sum_{i=1}^{n} b_i s_i} \ge x
$$

移项得 $\sum_{i=1}^{n} s_i(a_i - xb_i) \ge 0$。

这一步能移项，是因为 $b_i$ 都是正数、分母恒正。

显然我们每次选 $a_i - xb_i$ 前 $k$ 大的即可。

显然答案具有单调性：若能满足约束则增大 $x$，否则减小 $x$。

这个套路的精髓在于：**把一个比值最优化问题，变成一个"选数求和"的可行性问题**。后者往往极好判定，前者则完全没法直接贪心。

## 核心公式 / 状态定义与转移方程

**二分的判定式**（$c_i(x) = a_i - x b_i$）：

$$
\exists S,\ |S| = k:\ \sum_{i \in S} c_i(x) \ge 0 \quad \Longleftrightarrow\quad \max_{|S|=k}\sum_{i \in S} c_i(x) \ge 0
$$

也就是说，只需要求"前 $k$ 大的 $c_i$ 之和"，看它是不是非负。

**单调性**：$c_i(x)$ 关于 $x$ 单调递减（因为 $b_i > 0$），所以"存在可行方案"这个性质随 $x$ 增大而变假，可以二分。二分的上下界一般取

$$
L = 0, \qquad R = \max_i \frac{a_i}{b_i}
$$

（最优值一定落在单个物品的比值之间。）

## 逐行代码解析

原文没有给完整程序，只给了判定思路。下面只写二分的骨架，`check` 的内部按题目约束来填（见后面的变体表）。

### 模块一：二分框架

```cpp
double l = 0, r = 1e9;              // 答案的上下界，r 取一个必然可行的上界
while (r - l > 1e-6) {               // 精度够了就停
    double x = (l + r) / 2;
    if (check(x)) l = x;            // 存在方案，说明答案 >= x
    else r = x;                     // 不存在方案，答案 < x
}
```

- `l`、`r` 是答案的可行区间，初始时保证"最优值在 $[l, r]$ 内"。
- `while (r - l > 1e-6)` 是精度控制：比固定循环次数更直观，但循环次数不固定；卡时间的话可以改成固定跑 $60 \sim 100$ 次。
- `check(mid)` 为真就上调下界，为假就下调上界，这就是"二分答案"的标准写法。
- 输出时通常打印 `l`（可行侧），因为 `r` 是第一个不可行的值。

### 模块二：`check(x)` 里做什么

- 先算出所有 $c_i = a_i - x b_i$。
- 再按题目约束挑出最优的一组 $s_i$，看 $\sum s_i c_i$ 是否 $\ge 0$。
- 这一步是**内层判定**，它的复杂度决定了整个算法的复杂度；不同的约束对应不同的判定方式，见下表。

## 变体与内层判定

视约束条件不同，可延伸出以下几种情况：

| 题目约束 | 内层判定方法 | 复杂度 |
| :--- | :--- | :--- |
| 无限制，任选 | 把所有正的 $c_i$ 加起来，看是否 $\ge 0$ | $O(n)$ |
| 恰好选 $k$ 个 | 把 $c_i$ 排序，取最大的 $k$ 个求和 | $O(n \log n)$ |
| 总重量 $\le W$（背包） | 以 $c_i$ 为价值、$w_i$ 为重量跑 01 背包 | $O(nW)$ |
| 选出的边构成生成树 | 以 $c_i$ 为边权跑最大生成树 | $O(m \log m)$ |
| 选出的边构成环 | 以 $c_i$ 为边权判正环/负环 | $O(nm)$ |
| 选出的点构成闭合子图 | 转化为最小割跑网络流 | 视情况而定 |

这张表基本就是 0/1 分数规划的"全家桶"：最优比率生成树、最优比率环、最大密度子图，全都是同一套二分 + 判定。

## 复杂度分析

整体复杂度 = 二分次数 × 单次判定复杂度。

- 二分次数：按精度 $1e-6$ 算，大约是 $\log_2(\text{值域} / 10^{-6})$ 次；写固定次数的话就是几十次。
- 单次判定：见上表，从 $O(n)$ 到 $O(nm)$ 不等。

所以这类题的复杂度没有统一答案，取决于内层判定用的是什么算法。空间同理。

## 适用场景

- **最优比率问题**：最大化 $\frac{\sum a_i}{\sum b_i}$，如"单位价值最大的方案"。
- **最优比率生成树**：每条边有花费和收益，求收益/花费最大的生成树（内层跑最大生成树）。
- **最优比率环**：求一个环使比值最大（内层用 SPFA/Bellman-Ford 判正环）。
- **最大密度子图**：选一个点集使其内部边数/点数最大（内层是最小割）。
- **分数形式的答案**：题目要求输出"最大平均值""最大单位成本效益"时优先考虑这个套路。

## 常见陷阱与注意事项

1. **分母可能为 0**：题目的 $b_i$ 必须全为正数，否则移项那一步不成立，而且比值本身也没定义。
2. **精度不够**：`r - l > 1e-6` 对答案量级较大时可能不够，一般按题目要求的输出位数再多留两位；也可以直接固定迭代 60 次。
3. **上下界取错**：`r` 要取一个"一定可行"的上界，比如 $\max a_i / b_i$；取小了会把正确答案切掉。
4. **`check` 里的比较用 `>= 0` 还是 `> 0`**：二分的是"是否存在"，用 `>= 0` 更稳，尤其是浮点误差累积时。
5. **浮点排序**：`c_i` 是 `double`，排序没问题，但求和时误差会累积，`n` 很大时可以先用 `long double`。
6. **内层判定写错方向**：求**最大**比值时"可行"对应 $\sum c_i \ge 0$；如果题目求的是最小值，判定符号和二分方向都要反过来。$AKB268$, '数学', array['数学', '分数规划', '二分答案', '01分数规划'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-binomial-inversion--stripe-python', '二项式反演 · stripe-python', $AKB269$> 本文由 stripe-python 授权合并，保留原文结构与表述。
这部分内容摘自 [OI 中的数学基础](https://stripepython.github.io/2025/08/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)中组合数学部分，将并入之后更新的第二版内容。

OI 中的数学基础の[洛谷链接](https://www.luogu.com.cn/article/bhxqoy6g)。

如果某些计数问题的限制是“某些物品恰好若干个”，就可以考虑使用二项式反演。

## 原理

设 $f_n$ 表示恰好使用 $n$ 个不同元素形成特定结构的方案数，$g_n$ 表示从这 $n$ 个不同元素中选出若干个元素形成特定结构的方案数。

已知 $f_n$ 求 $g_n$ 是简单的，枚举选出多少个元素有

$g_n=\sum_{i=0}^{n} C_n^i f_i$反着做却是困难的，这个过程就叫**二项式反演**。有公式：

$f_n=\sum_{i=0}^{n} C_n^i (-1)^{n-i}g_i$二项式反演的作用就是把“恰好”转化为“钦定”。

组合意义上，考虑容斥原理，思考一下每个集合被重复计算几次可以感性理解。下面给出严谨的代数推导。

我们先给出一个引理

$C_n^r C_r^k=C^k_n C^{r-k}_{n-k}$组合意义和代数推导都易证。

把上述式子展开：

$$
\begin{aligned}
f_n&=\sum_{i=0}^{n} C_n^i (-1)^{n-i} [\sum_{j=0}^{i} C_i^j f_j]\\
&=\sum_{i=0}^{n} \sum_{j=0}^{i} C_n^i C_i^j (-1)^{n-i} f_j \\
&= \sum_{j=0}^{n} \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} f_j \\
&= \sum_{j=0}^{n} [f_j \times \sum_{i=j}^{n} C_n^i C_i^j (-1)^{n-i} ]
\end{aligned}
$$

根据引理可得

$$
\begin{aligned}
f_n&=\sum_{j=0}^{n} [f_j \times \sum_{i=j}^{n} C_n^j C_{n-j}^{i-j} (-1)^{n-i} ]\\
&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{i=j}^{n}C_{n-j}^{i-j} (-1)^{n-i} ]\\
\end{aligned}
$$

作换元，令 $k=i-j$，则 $i=k+j$，即有

$$
\begin{aligned}
f_n&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k} ]\\
&=\sum_{j=0}^{n} [C_n^j f_j \times \sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k ]
\end{aligned}
$$

根据二项式定理，当且仅当 $n=j$ 时 $\sum_{k=0}^{n-j}C_{n-j}^{k} (-1)^{n-j-k}1^k$ 为 $1$，故：

$f_n=f_n$上述操作均为等价变换，证毕。

下面我们给出二项式反演的全部形式：

$$
\begin{aligned}
&f(n)=\sum_{i=0}^n (-1)^iC_n^i g(i) \Leftrightarrow g(i)=\sum_{i=0}^n (-1)^i C_n^i f(i)\\
&f(n)=\sum_{i=n}^m C_m^ig(i) \Leftrightarrow g(n)=\sum_{i=n}^m (-1)^{m-i} C_m^i f(i)\\
&f(n)=\sum_{i=n}^m C_n^i g(i) \Leftrightarrow g(n)=\sum_{i=n}^m (-1)^{i-n} C_n^i f(i)
\end{aligned}
$$

## 例题

## AT_abc423_f [ABC423F] Loud Cicada

设 $g_x$ 表示钦定 $x$ 种蝉爆发的方案数。状压枚举集合 $S$，则

$g_x=\sum _{\operatorname{popcount}(S) = x} \lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$解释一下，对于集合 $S$ 中的所有元素 $i$，求出 $a_i$ 的最小公倍数，则集合 $S$ 中的所有蝉爆发的充要条件就是年份为最小公倍数的倍数。在 $Y$ 以内共有 $\lfloor \dfrac{Y}{\operatorname{lcm}_{i \in S} a_i} \rfloor$ 个年份。

然后做二项式反演：

$f_m=\sum_{i=m}^{n} C_m^i (-1)^{i}g_i$复杂度 $O(n2^n)$，杨辉三角 $O(n^2)$ 预处理组合数即可。注意 $\operatorname{lcm}$ 最好开个 `__int128`。

```cpp
#define popcount __builtin_popcount
const int N = 25;
int n, m;
long long y, a[N], g[N], c[N][N];

void _main() {
	cin >> n >> m >> y;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (int s = 0; s < (1 << n); s++) {
		__int128 x = 1;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) x = x / __gcd<__int128>(x, a[i]) * a[i];
			if (x > y) break;  // 注意这句
		} g[popcount(s)] += y / x;
	}
	long long res = 0;
	for (int i = m; i <= n; i++) {
		if ((m - i) & 1) res -= c[i][m] * g[i];
		else res += c[i][m] * g[i];
	} cout << res;
}
```

## P10596 BZOJ2839 集合计数

看到不好求的“恰好”，考虑二项式反演。设 $f_i$ 表示交集大小恰好为 $i$ 的方案数，$g_i$ 表示钦定 $i$ 个元素属于交集的方案数。

那么对于 $g_i$，先从 $n$ 个元素中选出 $i$ 个，方案数 $C_n^i$。剩下 $n-i$ 个元素可选可不选，就是求大小为 $2^{n-i}$ 的集合的非空子集数，答案为 $2^{2^{n-i}}-1$，乘法原理：

$g_i=C_n^i (2^{2^{n-i}}-1)$上二项式反演：

$f_k=\sum_{i=k}^{n}(-1)^{i-k} C_i^k g_i$复杂度 $O(n \log n)$。注意求 $g_i$ 要用欧拉定理。

```cpp
const int N = 1e6 + 5;
mint fac[N], ifac[N], g[N];
mint C(int n, int m) {
	return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];
}
int n, k;
void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 0; i <= n; i++) g[i] = C(n, i) * (mint(2).pow(mod32<1000000006>(2).pow(n - i).val) - 1);
	mint res = 0;
	for (int i = k; i <= n; i++) {
		if ((i - k) & 1) res -= C(i, k) * g[i];
		else res += C(i, k) * g[i];
	} cout << res;
}
```

## P4859 已经没有什么好害怕的了

形式化题意：给出长为 $n$ 的序列 $a,b$，将其两两配对使得 $a_i>b_i$ 的数目减去 $a_i<b_i$ 的数目恰为 $k$，求方案数。

设 $a_i>b_i$ 的数量为 $m$，则 $m-(n-m)=k$，解得 $m=\dfrac{n+k}{2}$。若 $2 \nmid (n+k)$，直接判定无解。此时问题变成 $a_i>b_i$ 的数目**恰好**为 $m$。考虑使用二项式反演化恰好为钦定。设 $g_i$ 为 $a_i>b_i$ 的组数不小于 $i$ 的方案数，根据二项式反演所求为

$\sum_{i=m}^{n} (-1)^{i-m} C_{i}^k g_i$现在的问题就是求 $g_i$，这玩意很 DP，所以设 $dp_{i,j}$ 表示前 $i$ 个数中选出 $j$ 组 $a_i>b_i$ 的方案数。DP 题套路对 $a,b$ 排序，然后可以推出转移方程

$dp_{i,j}=dp_{i-1,j}+(last_i-j+1)dp_{i-1,j-1}$从插入角度考虑 $(a_i,b_i)$ 的贡献，一种情况是不作为新的 $a_i>b_i$，还有一种就是考虑有多少个取代位置。设 $last_i$ 表示 $b$ 序列中第一个小于 $a_i$ 的数的下标，则插入位置就有 $last_i-j+1$ 个，加法原理合并答案。

于是我们 $O(n^2)$ 求出 $dp_{i,j}$。考察 $g_i$ 的定义可得

$g_i=dp_{n,i}\times  (n-i)!$就是在有序的 dp 基础上考虑剩下 $n-i$ 个全排列。

二项式反演中组合数可以逆元法来求，总复杂度 $O(n^2)$。

```cpp
const int N = 2005;
int n, m, k, a[N], b[N], last[N];
mint fac[N], ifac[N], dp[N][N], g[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n >> k;
	if ((n + k) & 1) return cout << 0, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];

	m = (n + k) / 2;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	sort(a + 1, a + n + 1), sort(b + 1, b + n + 1);
	for (int i = 1; i <= n; i++) last[i] = lower_bound(b + 1, b + n + 1, a[i]) - b - 1;
	dp[0][0] = 1;
	for (int i = 1; i <= n; i++) {
		dp[i][0] = dp[i - 1][0];
		for (int j = 1; j <= i; j++) {
			dp[i][j] = dp[i - 1][j] + dp[i - 1][j - 1] * max(0, last[i] - j + 1);
		}
	}
	for (int i = 0; i <= n; i++) g[i] = dp[n][i] * fac[n - i];
	mint res = 0;
	for (int i = m; i <= n; i++) {
		if ((i - m) & 1) res -= C(i, m) * g[i];
		else res += C(i, m) * g[i];
	} cout << res;
}
```

## P6478 [NOI Online #2 提高组] 游戏

“恰好 $k$ 次非平局”很难处理，不妨转为“钦定 $k$ 次非平局”。设恰好 $k$ 次非平局的方案数为 $g(k)$，钦定 $k$ 次非平局的方案数为 $f(k)$，显然有 $f(n)=\sum_{i=n}^m C_i^n g(i)$，根据二项式反演：

$g(n)=\sum_{i=n}^m (-1)^{i-n} C_i^n f(i)$考虑求 $f(i)$ 即可。考虑树形 DP，设 $dp_{u,i}$ 表示在以 $u$ 为根的子树中钦定 $i$ 个点且必须有胜负的方案数。

考虑对于儿子 $v$ 枚举在 $v$ 中选择 $j$ 个点，有转移：

$dp_{u,i}=\sum_{(u,v)} \sum_{j =0}^i dp_{v,j}dp_{u,i-j}$还可以选择一个点与 $u$ 配对，于是：

$dp_{u,i} \gets dp_{u,i}+dp_{u,i-1}+cnt_{u,x \oplus 1}$其中 $x$ 为点 $u$ 属于哪位玩家，$cnt_{u,0/1}$ 表示以 $u$ 为根的子树中有多少个属于 $0/1$ 玩家。

这是一个树形背包，且应该跑 01 背包。根据树形背包的复杂度证明，复杂度是严格 $O(n^2)$ 的。

这样有 $g(i)=dp_{1,i}\times (m-i)!$。求出来以后套进二项式反演即可。

```cpp
const int N = 5005;
int n, m, u, v, belong[N];
char c;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
mint f[N], g[N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int sz[N], cnt[2][N];
mint dp[N][N];
void dfs(int u, int fa) {
	sz[u] = 1, cnt[belong[u]][u] = 1, dp[u][0] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		vector<mint> f(min(sz[u] + sz[v], m), 0);
		for (int j = 0; j <= min(sz[u], m); j++) {
			for (int k = 0; k <= min(sz[v], m - j); k++) {
				f[j + k] += dp[u][j] * dp[v][k];
			}
		}
		sz[u] += sz[v], cnt[0][u] += cnt[0][v], cnt[1][u] += cnt[1][v];
		copy(f.begin(), f.end(), dp[u]);
	}
	for (int i = cnt[belong[u] ^ 1][u]; i >= 0; i--) {
		dp[u][i + 1] += dp[u][i] * (cnt[belong[u] ^ 1][u] - i);
	}
}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n, m = n / 2;
	for (int i = 1; i <= n; i++) cin >> c, belong[i] = c ^ 48;
	for (int i = 1; i < n; i++) {
		cin >> u >> v;
		add_edge(u, v), add_edge(v, u);
	}
	dfs(1, -1);
	for (int i = 0; i <= m; i++) g[i] = dp[1][i] * fac[m - i];
	for (int i = 0; i <= m; i++) {
		for (int j = i; j <= m; j++) {
			if ((j - i) & 1) f[i] -= C(j, i) * g[j];
			else f[i] += C(j, i) * g[j];
		}
		cout << f[i] << '\n';
	}
}
```

## 总结

二项式反演的主要作用就是把“恰好”变成“至少 / 至多”，也就是上文所述的“钦定”。

一般二项式反演适用于“恰好”很难做，而“钦定”比较好做的情况。对于“钦定”这一部分，往往要结合计数 DP 的方法求解。


## 附：二项式反演与子集反演（《OI 中的计数基础》· stripe-python）

### 2.1 二项式反演

记全集为 $U$，元素共有 $n$ 种属性，具有第 $i$ 种属性的元素构成集合 $S_i$。现在我们希望计算**恰好**有 $k$ 种属性的元素数目。

我们记
$$
g(k)=\sum \left|\bigcap\limits_{i=1}^k S_{p_i} \right|
$$
组合意义仍然是**钦定至少**。记 $f(k)$ 恰好有 $k$ 种属性的元素数目。那么朴素容斥给出
$$
f(0)=\sum_{i=0}^n (-1)^i g(i)
$$
对于一个元素 $x \in U$，设其具有的属性集合为 $A$，则其被钦定方式 $B$ 算到当且仅当 $B \subseteq A$。因此有
$$
g(k)=\sum_{i=k}^n \binom{i}{n} f(i)
$$
但是我们希望由 $g$ 计算出 $f$。从知 $f$ 求 $g$ 的过程转化到知 $g$ 求 $f$ 的过程叫做反演。而**二项式反演**给出如下结论
$$
g(k)=\sum_{i=k}^n \binom{i}{k} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k}\binom{i}{k} g(i)
$$
根据这个式子，我们就得到了**钦定至少**和**恰好**间的相互转化。$(-1)^{i-k} \dbinom{i}{k}$ 是这一转化的容斥系数。

从线性代数的观点来看，每个 $g$ 都可以写成若干 $f$ 的线性组合，因此反演的本质就是 $\mathbf{G}=A\mathbf{F} \iff \mathbf{F}=A^{-1} \mathbf{G}$。其中 $\mathbf{F},\mathbf{G}$ 为向量，$A$ 为系数矩阵。在二项式反演中，$A$ 恰好是杨辉三角。

我们给出二项式反演的全部形式：

- 形式零：

$$
g(k)=\sum_{i=0}^k (-1)^i\binom{k}{i} f(i) \iff f(k)=\sum_{i=0}^k (-1)^i \binom{k}{i} g(i)
$$

- 形式一：

$$
g(k)=\sum_{i=0}^k \binom{k}{i} f(i) \iff f(k)=\sum_{i=0}^k (-1)^{k-i} \binom{k}{i} g(i)
$$

- 形式二：

$$
g(k)=\sum_{i=k}^n \binom{i}{k} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k}\binom{i}{k} g(i)
$$

形式一是**钦定至多**与**恰好**的转化，形式二是**钦定至少**与**恰好**的转化。

### 2.2 子集反演

对于两个以集合为自变量的函数 $f,g$，**子集反演**给出如下结论：
$$
f(S)=\sum_{T \subseteq S} g(T) \iff g(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} f(T)
$$
同取补集可以得到另一个形式，称为**超集反演**：
$$
f(S)=\sum_{S \subseteq T} g(T) \iff g(S)=\sum_{S \subseteq T} (-1)^{|T|-|S|} f(T)
$$
子集反演实现了**钦定子集  / 超集**与**恰好**的转化，$(-1)^{|S|-|T|}$ 是这一转化的容斥系数。从集合幂级数的角度看，子集反演给出了高维差分的式子。

二项式反演可以看做子集反演的一个特例。$AKB269$, '数学', array['二项式反演', '组合数学', '容斥', '计数'], 'col-math-combinatorics', null, 'knowledge'),
('lker', 'col-math-bit-operation--lker', '位运算 · lker', $AKB270$## 算法原理

![](https://cdn.luogu.com.cn/upload/image_hosting/933ab2v0.webp)

本笔记按 lker 原文的顺序整理 6 道与位运算、异或相关的题：P5514、P5651、P8445、P13552、P11008、CF1956D。原文没有附 C++ 代码，下面的「逐行代码解析」用操作步骤与伪代码拆解核心过程；完整实现由你本人完成。

**题目索引**：[P5514 永夜的报应](https://www.luogu.com.cn/problem/P5514)、[P5651 基础最短路练习题](https://www.luogu.com.cn/problem/P5651)、[P8445 射命丸文的取材之旅](https://www.luogu.com.cn/problem/P8445)、[P13552 鱼类考古学](https://www.luogu.com.cn/problem/P13552)、[P11008 『STA - R7』异或生成序列](https://www.luogu.com.cn/problem/P11008)、[CF1956D Nene and the Mex Operator](https://codeforces.com/problemset/problem/1956/D)。

### 一、P5514 永夜的报应

题意：把 $n$ 个非负整数分成若干组，每组的权值是组内所有数的异或和，要求最小化所有组权值之和。

经典恒等式：

$$
a+b=(a\oplus b)+2(a\ \&\ b).
$$

因为 $a\ \&\ b\ge 0$，所以

$$
a+b\ge a\oplus b.
$$

设两个组的异或和分别为 $x,y$。把它们合并成一组，新权值为 $x\oplus y$，由上式有 $x+y\ge x\oplus y$，所以**合并两个组不会让答案变大**。反复合并，直到只剩一组，答案就是所有数的异或和。

原文的反证也等价：假设存在一种最优方案是先异或若干集合再求和。把这些集合的权值再异或起来，由异或的结合律，它等于一开始就把所有元素异或在一起；而由 $a+b\ge a\oplus b$，这个值不超过原来各组权值之和，与“最优且分组数大于 1”矛盾。因此全部异或起来就是最优。

> 原文写的是“$a\ \&\ b$ 显然大于 $0$”，严格说应为**非负**；$a\ \&\ b=0$ 时取等号。

伪代码见「逐行代码解析」。复杂度 $O(n)$，空间 $O(1)$。

### 二、P5651 基础最短路练习题

题意：给定 $n$ 个点、$m$ 条边的无向连通图，边有边权；一条简单路径的权值为路径上所有边权的异或和。保证图中不存在异或和不为 $0$ 的简单环。$Q$ 次询问 $x$ 到 $y$ 的简单路径权值。

关键性质：任意两条 $x\to y$ 的路径，它们的对称差可以分解成若干个环；题目保证每个环的异或和为 $0$，所以这两条路径的异或和相等。也就是说，**两点之间的路径异或和是唯一的**，“最短路”在这里只是题面说法，并不需要真的做最短路。

做法：任取一棵生成树（DFS 或 BFS 即可），记 `dis[u]` 为根到 $u$ 的树路径异或和。对询问 $(x,y)$，树上的 $x\to y$ 路径异或和为

$$
dis[x]\oplus dis[y],
$$

而它等于任意一条 $x\to y$ 路径的异或和，所以直接输出即可。一次 DFS 预处理，$O(1)$ 回答每个询问。

伪代码见「逐行代码解析」。复杂度 $O(n+m+Q)$，空间 $O(n+m)$。

### 三、P8445 射命丸文的取材之旅

题意：给定两个长度为 $n$ 的序列 $a,b$。对每个位置 $i$，选择 $c_i\in\{a_i,b_i\}$。最大化

$$
\max_{1\le l\le r\le n}\left(r-l+1-\operatorname{mex}\{c_l,\dots,c_r\}\right).
$$

直接限制 $\operatorname{mex}=x$ 很麻烦：既要保证 $x$ 不出现，又要保证 $0\sim x-1$ 全部出现。这里换一个角度：**只强制 $x$ 不出现**。

为什么可以这样：

- 若区间里 $x$ 不出现，则实际的 $\operatorname{mex}\le x$，所以
  $$
  len-\operatorname{mex}\ge len-x.
  $$
  实际 $\operatorname{mex}$ 更小只会让答案更优；而真正的最优区间在 $x=\operatorname{mex}$ 时也会被统计到。
- 于是答案等于
  $$
  \max_{x}\left(\text{最长的不出现 }x\text{ 的区间长度}-x\right).
  $$
  这样关于“较小数必须全部出现”的限制就自然消失了。

固定 $x$ 时，哪些位置无法避开 $x$？只有当 $a_i=b_i=x$ 时，$c_i$ 被迫等于 $x$；如果 $a_i\ne x$ 或 $b_i\ne x$，我们总可以选另一个值来避开 $x$。因此：

- 这些被迫位置就是断点；
- 避开 $x$ 的最长区间，就是断点切割出的最长连续段。

实现时，用桶把所有 $a_i=b_i=x$ 的下标存进 `pos[x]`。每个下标只会作为一个值的断点出现，所以总断点数不超过 $n$。对每个 $x$ 扫描它的断点，计算最大空隙 `maxgap`，用 `maxgap - x` 更新答案即可。

伪代码见「逐行代码解析」。复杂度 $O(n+\max a_i)$（本题 $\max a_i\le n$，即 $O(n)$），空间 $O(n)$。

### 四、P13552 鱼类考古学

题意：有 $n$ 个非负整数。每次可以选两个数，用按位与或加法合并成一个数；在 $n-1$ 次操作中，按位与操作恰好使用 $n-k$ 次，加法操作恰好使用 $k-1$ 次。最大化最后剩下的数。

**第一步：把按位与全部移到加法之前。**

题面中 $\otimes$ 表示按位与。关键不等式：

$$
(a\ \&\ b)+c\ge c\ge (a+b)\ \&\ c.
$$

也就是说，先与再加，不会比先加再与差。把操作树中“加法在里、与在外”的结构不断交换，最终一定可以化成一个等价或更优的形式：

- 先把元素分成 $k$ 个集合，每个集合内部做按位与（共 $n-k$ 次）；
- 再把得到的 $k$ 个值相加（共 $k-1$ 次）。

于是问题变成：**把 $n$ 个数分成 $k$ 组，每组权值为组内按位与，最大化权值之和。**

**第二步：从高位到低位贪心。**

维护当前还需要分配的集合数 $cur$（初始为 $k$）。从最高位向最低位递归。设当前元素中该位为 $1$ 的个数为 $cnt$，当前元素总数为 $total$。

- **$cnt<cur$**：不可能让 $cur$ 个集合都保留这一位。优先把每个该位为 $1$ 的元素单独设成一个集合：单独成组时它的值就是它本身，低位也不会被其他元素与掉。把这些元素的值直接加入答案并移除，令 $cur\leftarrow cur-cnt$，对剩下的该位为 $0$ 的元素继续递归。
- **$cnt\ge cur$**：至少能凑出 $cur$ 个含该位 $1$ 的元素。再分两种：
  - 若 $cnt=total$（当前所有元素该位都是 $1$），则 $cur$ 个集合都可以保留这一位，答案加上 $cur\cdot 2^b$；把所有元素减去 $2^b$，$cur$ 不变，继续递归。
  - 否则（存在该位为 $0$ 的元素）：至少有一个集合要吸收这些 $0$，因此最多只有 $cur-1$ 个集合能保留这一位。为了让损失最小，把所有该位为 $0$ 的元素与在一起，作为一个新的候选元素；答案加上 $(cur-1)\cdot 2^b$；把 $1$ 元素减去 $2^b$，与这个新元素一起递归，$cur$ 不变。

> 原文在这里写的是“最多保留 $cur-1$ 个”。这成立的前提是**存在该位为 $0$ 的元素**；如果当前所有元素该位都为 $1$，则 $cur$ 个集合都能保留这一位，应加 $cur\cdot 2^b$。上面的分类把这两种情况分开，避免 $k=n$ 或全 $1$ 时少算。

伪代码见「逐行代码解析」。每个测试用例约 $O(30n)$，空间 $O(n)$。样例输出为 $3,12,1$。

### 五、P11008 『STA - R7』异或生成序列

题意：给定一个 $1\sim n$ 的排列 $p$ 的异或生成序列 $b_i=p_i\oplus p_{i+1}$（$1\le i<n$），要求还原任意一个合法的排列 $p$。

令 $s_0=0$，$s_i=\bigoplus_{j=1}^i b_j$。则

$$
s_i=p_1\oplus p_{i+1},
$$

$$
p_{i+1}=p_1\oplus s_i,
$$

$$
s_i\oplus s_j=p_{i+1}\oplus p_{j+1}.
$$

所以只要确定 $p_1$，整个排列就确定了。问题变成：找一个 $p_1$，使得 $\{p_1\oplus s_i\mid 0\le i<n\}$ 恰好是 $1\sim n$。

**配对观察**：在 $1\sim n$ 中，天然成对的是

$$
(2k,\ 2k+1),
$$

因为 $2k\oplus(2k+1)=1$。注意：$u\oplus v=1$ 的充要条件是 $\left\lfloor u/2\right\rfloor=\left\lfloor v/2\right\rfloor$（两个数只有最低位不同）。

当所有数同时异或同一个 $p_1$ 时，最低位可能翻转，但**高位不变**，所以仍然有

$$
\left\lfloor\frac{u\oplus p_1}{2}\right\rfloor
=
\left\lfloor\frac{v\oplus p_1}{2}\right\rfloor.
$$

因此，原排列中的配对关系可以转移到前缀异或序列 $s_i$ 上：按 $\left\lfloor s_i/2\right\rfloor$ 分组，原本成对的 $p$ 值对应的 $s$ 值仍然落在同一组。

在 $1\sim n$ 中：

- $1$ 本应与 $0$ 配对，但排列中没有 $0$，所以 $1$ 落单；
- 若 $n$ 为偶数，$n$ 本应与 $n+1$ 配对，但排列中没有 $n+1$，所以 $n$ 也落单；
- 其余元素两两成对。

所以，把每个 $s_i$ 按 $\left\lfloor s_i/2\right\rfloor$ 放入桶后，**桶大小为 $1$ 的桶最多只有两个**，分别对应原排列中的 $1$ 以及偶数时的 $n$。其中必然有一个桶对应原排列中的 $1$。

实现：统计每个 $\left\lfloor s_i/2\right\rfloor$ 的出现次数；对出现次数为 $1$ 的桶，取出对应的 $s_i$，假设它对应原排列中的 $1$，则

$$
p_1=s_i\oplus 1.
$$

用这个 $p_1$ 生成整个排列，花 $O(n)$ 校验是否落在 $1\sim n$ 且不重复。候选最多两个，总复杂度 $O(n)$。

伪代码见「逐行代码解析」。注意本题 $\sum n\le 2\times 10^6$，要使用快速输入输出。

### 六、CF1956D Nene and the Mex Operator

~~0d000721~~

题意：给定长度 $n\le 18$ 的数组。每次操作选择区间 $[l,r]$，令 $x=\operatorname{mex}(a_l,\dots,a_r)$，然后把该区间所有元素改为 $x$。最多操作 $5\times 10^5$ 次，最大化最终数组和，并输出操作方案。

先看一个长度为 $x$ 的区间：

- 区间只有 $x$ 个元素，所以 $\operatorname{mex}\le x$；
- 一次操作后区间所有元素都变成同一个值，最大只能是 $x$，区间和最大为 $x^2$；
- 要真正得到 $x^2$，操作前区间必须恰好包含 $0,1,\dots,x-1$（即这 $x$ 个数的一个排列）。

因此，问题可以看成：把数组划分成若干区间，每个区间要么保持原样，要么构造成 $0\sim len-1$ 的排列后一次操作变成 $len$，得到 $len^2$ 的收益；不同区间之间可以再用区间 DP 组合。

**构造 $0,1,\dots,x-1$ 的方法**（递归）：

- 长度为 $1$：若当前数不为 $0$，对它单独操作一次，`mex({a})=0`，把它变成 $0$；若已经是 $0$，不动。
- 长度大于 $1$：先递归把前缀 $[l,r-1]$ 变成 $0,1,\dots,x-2$。此时区间 $[l,r]$ 中有 $0\sim x-2$ 和第 $x$ 个数：
  - 若第 $x$ 个数已经是 $x-1$，前缀构造完就已经是 $0\sim x-1$；
  - 否则，对 $[l,r]$ 操作一次，`mex` 恰好是 $x-1$，整个区间变成 $x-1$；再递归把前缀 $[l,r-1]$ 重新构造成 $0\sim x-2$，于是第 $x$ 个数保持 $x-1$。

得到 $0\sim x-1$ 后，再对整个区间操作一次，`mex=x`，区间变成 $x$，收益 $x^2$。

原文给出的长度 $2$、长度 $3$ 例子就是上面的过程：

$$
x_1,x_2\to 0,x_2\to 1,1\to 0,1,
$$

$$
x_1,x_2,x_3\to 0,1,x_3\to 2,2,2\to 0,1,2.
$$

（最后再对整个区间操作一次，长度 $2$ 变成 $2,2$，长度 $3$ 变成 $3,3,3$。）

**区间 DP**：设 $f(l,r)$ 表示区间 $[l,r]$ 能获得的最大收益。初始有三种选择：

1. 不操作，收益为区间和；
2. 构造成排列后整体操作，收益为 $len^2$；
3. 在某个 $k$ 处拆成 $[l,k]$ 和 $[k+1,r]$，收益为两者之和。

即

$$
f(l,r)=\max\left(\sum_{i=l}^r a_i,\ len^2,\ \max_{l\le k<r}\big(f(l,k)+f(k+1,r)\big)\right).
$$

记录每个区间选择了哪种方案；最后从 $[1,n]$ 递归输出操作。构造一个长度 $len$ 的区间需要不超过 $2^{len}$ 次操作；DP 选出的区间互不相交，所以总操作数不超过 $2^n\le 2^{18}=262144$，在 $5\times 10^5$ 以内。

伪代码见「逐行代码解析」。复杂度 $O(n^3+2^n)$，空间 $O(n^2)$。

---

## 核心公式 / 状态定义与转移方程

- 异或与加法的关系：$a+b=(a\oplus b)+2(a\ \&\ b)\ge a\oplus b$。
- 合并两组：若两组异或和为 $x,y$，则合并后为 $x\oplus y\le x+y$。
- 路径异或唯一：若所有环的异或和为 $0$，则任意两条 $x\to y$ 路径异或和相等；`ans=dis[x]^dis[y]`。
- MEX 区间转化：若强制 $x$ 不出现，则实际 $\operatorname{mex}\le x$，有 $len-\operatorname{mex}\ge len-x$。
- P8445 断点：只有 $a_i=b_i=x$ 的位置被迫取 $x$；最长可行区间 = 断点间的最大空隙。
- P13552 与加法：$(a\ \&\ b)+c\ge c\ge(a+b)\ \&\ c$；最优形式是“先分组求与，再求和”。
- P13552 高位贪心：$cnt<cur$ 时把 $1$ 元素单独成组；$cnt\ge cur$ 时，有 $0$ 元素则保留 $cur-1$ 个，全 $1$ 则保留 $cur$ 个。
- P11008 前缀异或：$s_0=0$，$s_i=\bigoplus_{j=1}^i b_j$，$p_{i+1}=p_1\oplus s_i$，$s_i\oplus s_j=p_{i+1}\oplus p_{j+1}$。
- P11008 配对：$u\oplus v=1\iff\left\lfloor u/2\right\rfloor=\left\lfloor v/2\right\rfloor$；原排列中只有 $1$（以及偶数时的 $n$）落单。
- CF1956D 区间收益：$f(l,r)=\max\left(\sum a_i,\ len^2,\ \max f(l,k)+f(k+1,r)\right)$。
- CF1956D 构造：先递归构造前缀 $0\sim x-2$，必要时整体操作成 $x-1$，再重建前缀；最后整体操作成 $x$。

---

## 逐行代码解析

> 原文没有附 C++ 代码。下面用伪代码拆解每道题的核心过程；完整实现（含快速输入输出、边界处理）由你本人完成。

### P5514：全部异或

```text
ans = 0
for x in a:
    ans = ans xor x
print ans
```

- 每读入一个数就异或进 `ans`，最后 `ans` 就是所有数的异或和。
- 不需要真的分组；合并论证保证全部异或是最小值。
- 注意 `ans` 的初始值为 $0$；异或的单位元是 $0$。

### P5651：生成树 + 前缀异或

```text
read n, m, Q
build adjacency list

dis[1] = 0
dfs(u, fa):
    for (v, w) in adj[u]:
        if v == fa: continue
        dis[v] = dis[u] xor w
        dfs(v, u)

dfs(1, 0)
for each query (x, y):
    print dis[x] xor dis[y]
```

- 生成树只需要保留每个点第一次被访问时的那条边；`fa` 防止走回父亲。
- `dis[u]` 是根到 $u$ 的树路径异或和；由路径异或唯一性，`dis[x]^dis[y]` 就是任意 $x\to y$ 路径的异或和。
- 不需要堆优化 Dijkstra；边权是异或，不是加法。

### P8445：断点最大空隙

```text
read n, a[1..n], b[1..n]

for i = 1..n:
    if a[i] == b[i]:
        pos[a[i]].push(i)

ans = 0
for x = 0..n:
    prev = 0
    maxgap = 0
    for p in pos[x]:
        maxgap = max(maxgap, p - prev - 1)
        prev = p
    maxgap = max(maxgap, n - prev)
    ans = max(ans, maxgap - x)

print ans
```

- 只有 `a[i]==b[i]` 的位置才无法避开该值；其余位置可以选另一个值。
- `prev` 从 $0$ 开始、最后用 $n-prev$ 收尾，等价于在数组两端加了两个虚拟断点。
- 若某个 $x$ 没有断点，`maxgap=n`，候选为 $n-x$。
- 答案至少为 $0$，所以 `ans` 初始化为 $0$。

### P13552：高位递归

```text
solve(list, k, bit):
    if bit < 0 or k == 0:
        return 0

    ones = [x in list if (x >> bit) & 1]
    zeros = [x in list if not ((x >> bit) & 1)]

    if ones is empty:
        return solve(list, k, bit - 1)

    if len(ones) < k:
        // 每个 1 元素单独成组，低位完全保留
        return sum(ones) + solve(zeros, k - len(ones), bit - 1)

    if len(zeros) == 0:
        // 所有元素都有这一位，k 个组都能保留
        return k * (1 << bit) + solve([x - (1 << bit) for x in ones], k, bit - 1)

    // 有 0 元素：至多 k-1 个组保留这一位；所有 0 元素与成一个新元素
    z = AND(zeros)
    return (k - 1) * (1 << bit)
           + solve([x - (1 << bit) for x in ones] + [z], k, bit - 1)
```

- 入口：`solve(a, k, 29)`（因为 $a_i<2^{30}$）。
- `ones` 是该位为 $1$ 的元素，`zeros` 是该位为 $0$ 的元素。
- `len(ones) < k` 时，把每个 $1$ 元素单独成组，直接加上它们的完整值；这些组不再参与后续递归。
- `len(zeros) == 0` 时，所有组都能保留这一位，加 $k\cdot 2^b$ 后把该位清零，继续优化低位。
- 否则，把 $0$ 元素与成一个新元素，牺牲一个组来吸收它们，加 $(k-1)\cdot 2^b$，继续递归。
- 递归深度最多 $30$；每层都要扫描当前元素，整体约 $O(30n)$。

### P11008：按 $\lfloor s_i/2\rfloor$ 分桶

```text
read T
for each test:
    read n
    read b[1..n-1]

    s[0] = 0
    for i = 1..n-1:
        s[i] = s[i-1] xor b[i]

    // 统计 floor(s[i]/2) 的出现次数，并记录对应的 s[i]
    cnt = map from floor(s[i]/2) to count
    val = map from floor(s[i]/2) to one s[i]

    for each bucket with count == 1:
        candidate = val[bucket] xor 1      # 假设该 s[i] 对应原排列中的 1
        generate p[1..n]:
            p[1] = candidate
            for i = 1..n-1:
                p[i+1] = candidate xor s[i]
        if p is a permutation of 1..n:
            print p
            break
```

- 前缀异或 `s` 有 $n$ 个值（$s_0\sim s_{n-1}$），正好对应排列的 $n$ 个值。
- 桶大小为 $1$ 的桶最多两个；依次假设它对应原排列中的 $1$，反推 `p1 = s[i]^1`。
- 生成并校验是 $O(n)$；最多尝试两个候选，总复杂度 $O(n)$。
- 值域较大时用哈希表或排序分组，不要直接开 $2^{30}$ 的数组。

### CF1956D：构造排列 + 区间 DP

```text
// 把区间 [l, r] 变成 0, 1, ..., len-1
build_permutation(l, r):
    if l == r:
        if a[l] != 0:
            operate(l, l)        // 非零单点变成 0
        return

    build_permutation(l, r-1)    // 前缀变成 0..len-2
    len = r - l + 1
    if a[r] != len - 1:
        operate(l, r)            // 整个区间变成 len-1
        build_permutation(l, r-1)  // 重建前缀 0..len-2

// 让 [l, r] 全部变成 len，收益 len^2
build_uniform(l, r):
    build_permutation(l, r)
    operate(l, r)                // mex = len

// 区间 DP
for len = 1..n:
    for l = 1..n-len+1:
        r = l + len - 1
        f[l][r] = sum(a[l..r])   // 不操作
        if len*len > f[l][r]:
            f[l][r] = len*len
            choice[l][r] = "uniform"
        for k = l..r-1:
            if f[l][k] + f[k+1][r] > f[l][r]:
                f[l][r] = f[l][k] + f[k+1][r]
                choice[l][r] = k

print f[1][n]
reconstruct(1, n):
    if choice == "uniform":
        build_uniform(1, n)
    elif choice is a split k:
        reconstruct(l, k)
        reconstruct(k+1, r)
    else:
        do nothing
```

- `build_permutation` 的递归次数满足 $T(len)=2T(len-1)+1$，约为 $2^{len}$；DP 选出的区间互不相交，总操作数不超过 $2^n$。
- `choice` 记录当前区间是“整体构造”还是“在 $k$ 处拆分”；若整体构造，就执行 `build_uniform` 并输出操作。
- `f[l][r]` 的初始值是区间原和与 $len^2$ 的较大者；拆分转移允许把数组切成若干独立区间。
- 注意 $n\le 18$，$len^2$ 最大 $324$，不会溢出；`sum` 用 `long long` 更稳。

---

## 复杂度分析

| 题目 / 算法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| P5514 | $O(n)$ | $O(1)$ |
| P5651 | $O(n+m+Q)$ | $O(n+m)$ |
| P8445 | $O(n+\max a_i)$（$\max a_i\le n$ 时 $O(n)$） | $O(n)$ |
| P13552 | $O(30n)$ 每组数据 | $O(n)$ |
| P11008 | $O(n)$ 每组数据 | $O(n)$ |
| CF1956D | $O(n^3+2^n)$ | $O(n^2)$ |

其中 P13552 的 $30$ 来自值域 $a_i<2^{30}$；CF1956D 的 $2^n$ 同时是构造操作数的上界，$n\le18$ 时不超过 $262144$，满足 $5\times10^5$ 的限制。

---

## 适用场景

- **P5514 型**：把“分组异或和最小/最大”转成“合并两组是否变优”，利用 $x+y\ge x\oplus y$。
- **P5651 型**：图上路径异或和、环异或和为 $0$、异或前缀；不要被“最短路”误导。
- **P8445 型**：区间长度减 MEX、可以选择每个位置的值；用“只禁止 $x$”替代“精确限制 MEX”。
- **P13552 型**：按位与分组、与和加法混合、高位贪心；注意全 $1$ 与存在 $0$ 的边界。
- **P11008 型**：由异或差分序列还原排列、前缀异或、按 $\lfloor x/2\rfloor$ 配对。
- **CF1956D 型**：区间 MEX 操作、构造排列、区间 DP + 操作方案输出。

---

## 常见陷阱与注意事项

1. **P5514 的 `a&b` 可以为 $0$**：恒等式仍成立，等号在 $a&b=0$ 时取得；不要说“必然大于 $0$”。
2. **P5651 不要真的跑最短路**：题目保证所有环异或为 $0$，任意路径异或和相同；生成树 + 前缀异或即可。边权是异或，不是加法。
3. **P8445 只禁止 $x$**：不要额外要求 $0\sim x-1$ 全部出现；那会把问题变复杂，而且会漏掉最优解。
4. **P8445 的断点条件**：只有 $a_i=b_i=x$ 才是被迫的；只要有一个不等于 $x$，就可以避开。
5. **P13552 的全 $1$ 边界**：$cnt\ge cur$ 时，只有存在 $0$ 元素才保留 $cur-1$ 个；全 $1$ 时应保留 $cur$ 个。$k=n$ 时答案为所有数之和。
6. **P13552 的 $k=1$**：此时只能把所有数按位与，答案就是全部元素的 AND；递归会自然落到这个结果。
7. **P11008 的候选桶**：桶大小为 $1$ 的桶最多两个；要逐个尝试并校验，不能直接认定第一个就是 $1$。
8. **P11008 的输入规模**：$\sum n\le2\times10^6$，必须用快速输入输出；`s_i` 的值域较大，不要开过大的桶数组。
9. **CF1956D 的操作数**：构造一个长度 $len$ 的区间约 $2^{len}$ 次操作；$n=18$ 时约 $2^{18}$，在限制内。不要在每个区间上重复构造。
10. **CF1956D 的 $n=1$**：若 $a_1=0$，操作一次变成 $1$，收益 $1$；若 $a_1\ne0$，直接保留原值更大（$a_1$ vs $1$），DP 会取较大者。
11. **位运算优先级**：`&` 的优先级低于 `==`，写 `(x >> b) & 1` 时括号要加清楚；不要写 `x & 1 == 1`。
12. **多测与清空**：P13552、P11008 都是多测；容器在每组数据内定义，避免残留。

---

## 对比与扩展

- **P5514 与普通分组**：普通分组求和使用“合并两组会相加”，这里用“合并两组异或会变小”；核心都是证明合并操作不劣。
- **P5651 与最短路**：普通最短路是边权相加，这里边权是异或；因为环异或为 $0$，路径异或退化成“树上前缀异或”。
- **P8445 与标准 MEX 题**：标准做法常常枚举 MEX 并维护 $0\sim x-1$ 的出现；这里反过来“只禁止 $x$”，用“实际 MEX 只会更小”把存在性条件消掉。
- **P13552 与按位贪心**：和“按位确定答案”的套路一致，但多了一个“集合数量”维度；高位优先，低位递归。
- **P11008 与排列还原**：利用 $u\oplus v=1$ 的配对关系，把排列的配对搬到前缀异或序列上；这是“异或差分 + 配对”的典型用法。
- **CF1956D 与区间 DP**：先证明单区间最优是 $len^2$，再用区间 DP 决定“整体构造还是拆分”；构造部分用递归把任意区间变成 $0\sim len-1$。$AKB270$, '数学', array['位运算', '异或', '贪心', 'MEX', '构造', '生成树', '前缀异或'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-bit-operation--stripe-python', '位运算 · stripe-python', $AKB271$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 19. 位运算

本来不打算讲的，但是发现 OI 里位运算的题也不少，所以开个新专题。

## 19.1 位运算常用性质

1. 由于异或是不进位加法，不退位减法，故 $x-y \le x \oplus y \le x + y$。
2. 按位考虑 $x,y$ 的异同，有 $x+y=(x\& y) +(x|y)$。
3. 异或是不进位加法，而 $2(x \& y)$ 又能够表示加法进位，因此 $x+y=(x \oplus y)+2(x \& y)$。
4. 对于常数 $x,n$，满足 $x \oplus i \le n$ 的 $i$ 形成的区间有 $O(\log n)$ 个。

## 19.2 位运算基础

让我们来考虑下列问题：

1. 定义 $\operatorname{lowbit}(x)$ 为 $x$ 最低位的 $1$ 及后面的 $0$ 组成的数。如何计算 $\operatorname{lowbit}(x)$ ？

A: 将 $x$ 二进制位全部取反再加一。设原来 $x$ 的二进制表示形如 `(...)10...0000`，全部取反可得 `[...]01...1111`，加一即为 `[...]10...0000`，且 `[...]` 与 `(...)` 内容全部相反，两数或之，得 $10...0000$，即 $\operatorname{lowbit}(x)$。由补码性质可得 `~x + 1 = -x`，因而代码可以这样写：

```cpp
constexpr int lowbit(int x) {return x & -x;}
```

这个函数在树状数组中有大用。还有一种方法是 $x-\operatorname{lowbit}(x)=x\& (x-1)$。

1. 定义 $\operatorname{popcount}(x)$ 为二进制下 $x$ 中 $1$ 的个数，如何计算 $\operatorname{popcount}(x)$？

A: 考虑每次减去它的  $\operatorname{lowbit}$，复杂度 $O(\log n)$。

```cpp
int popcount(int x) {
	int res = 0;
	for (; x; x -= lowbit(x)) res++;
	return res;
}
```

GNU C++ 提供了函数 `__builtin_popcount(x)`，这个函数的速度远快于上面代码，可视为 $O(1)$。另有函数 `__builtin_popcountll(x)` 来计算 `long long` 类型的 $\operatorname{popcount}$。

根据二维容斥有性质：$\operatorname{popcount}(a\&b)=\operatorname{popcount}(a)+\operatorname{popcount}(b)-\operatorname{popcount}(a| b)$。

1. 使用一个 $n$ 位的二进制整数 $s$ 压位表示一个集合，如何降序枚举其子集？

A: 先上代码：

```cpp
for (int i = s; i; i = (i - 1) & s);
```

降序获得下一个子集，其实就是将它的最低位 $1$ 置为 $0$，减去 $1$ 即可，但是这会导致其最低位的 $1$ 后所有的 $0$ 变成了 $1$。通过按位与上 $s$，可以将那些多余的 $1$ 与 $0$ 而抵消。

可以发现其复杂度为 $O(2^{\operatorname{popcount}(n)})$。

1. 考虑枚举 $\{0,1,2, \cdots, n-1 \}$ 的所有子集的所有子集，求复杂度？

A: 根据问题 3，枚举方法显然：

```cpp
for (int i = 0; i < (1 << n); i++) {
	for (int j = i; j; j = (j - 1) & i);
}
```

复杂度为 $O(3^n)$。我们根据组合数学知识来推导一下。考虑枚举每个子集中大小为 $i$ 的子集个数，则总数为

$\sum_{i=0}^{n-1} C_n^i 2^i=\sum_{i=0}^{n-1} C_n^i 2^i 1^{n-i}=(1+2)^n-1=O(3^n)$这里我们逆用了二项式定理。如果直接暴力复杂度为 $O(4^n)$，而这个低复杂度做法是状压 dp 的常用技巧。

1. 求 $\{0,1,2,\cdots,n-1\}$ 的所有子集的所有子集的元素和。即 $\sum_{T \subseteq S} \sum T$。

一个显然的想法是 $O(3^n)$ 地去做。事实上这个问题有 $O(n2^n)$ 的解决方案。

让我们思考一下：不用容斥原理的二维前缀和怎么做？

答案是对每一维分开求前缀和，如下：

```cpp
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) a[i][j] = a[i - 1][j] + a[i][j];
}
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) a[i][j] = a[i][j - 1] + a[i][j];
}
```

在维度很高的时候，这种做法比容斥的复杂度更低。对于子集求和问题，将 $n$ 位视为 $n$ 维跑高维前缀和：

```cpp
for (int i = 0; i < n; i++) {
    for (int s = 0; s < (1 << n); s++) {
        if (s >> i & 1) f[s] += f[s ^ (1 << i)];
    }
}
```

这个技巧叫做 SOS DP。它也是 FWT 等算法的基础。

## 19.3 例题

### P9451 [ZSHOI-R1] 新概念报数

分类讨论。设 $\operatorname{popcount}(a)=p$，则：

1. 若 $p \ge 3$，报告无解；
2. 若 $p \le 1$，直接输出 $a+1$，显然这样 $\operatorname{popcount(a+1)} \le 2$。
3. 若 $p=2$，找到 $a$ 二进制下最右侧的 $01$，然后改为 $10$ 即可。回顾一下问题 1，发现所求就是 $a+\operatorname{lowbit(a)}$。

代码：

```cpp
uint64_t a;

void _main() {
	cin >> a;
	int p = __builtin_popcountll(a);
	if (p >= 3) return cout << "No,Commander\n", void();
	if (p <= 1) cout << a + 1 << '\n';
	else cout << a + (a & -a) << '\n';
}
```

### P3908 数列之异或

普及一下这个结论：

$$
S(n)=\bigoplus_{i=1}^n i=\left\{\begin{matrix}
 n &  n \equiv 0 \pmod 4 \\
 1 &  n \equiv 1 \pmod 4 \\
 n+1 &  n \equiv 2 \pmod 4 \\
 0 &n \equiv 3 \pmod 4 
\end{matrix}\right.
$$

打个表可以发现。下面给出证明：

设 $k \in \mathbb{N^+}$。显然 $n=1,2,3,4$ 时 $S(n)$ 符合规律，用数学归纳法证明：

- 当 $n=4k$ 时，$S(n)=S(4k)=S(4k-1) \oplus 4k= 0 \oplus 4k=4k=n$。
- 当 $n=4k+1$ 时，$S(n)=S(4k+1)=S(4k) \oplus (4k+1)=4k \oplus (4k+1)=1$。
- 当 $n=4k+2$ 时，$S(n)=S(4k+2)=S(4k+1) \oplus (4k+2)=1 \oplus (4k+2)=1+4k+2=4k+3=n+1$。
- 当 $n=4k+3$ 时，$S(n)=S(4k+3)=S(4k+2)\oplus(4k+3)=(4k+3)\oplus(4k+3)=0$。

证毕。

### *[模拟赛] 哈基米哟南北绿豆

原题是 [AT_utpc2011_9](https://atcoder.jp/contests/utpc2011/tasks/utpc2011_9)，NOIP 模拟赛加强了并且放到 T1。鉴定为失心疯 Ad-hoc 题。

> 定义位多项式 $f(x)$ 是关于 $x$ 的中缀表达式，满足如下 BNF 规则：
>
> ```plaintext
> expr ::= "x" | num | ("(" "~" expr ")") | (expr op expr)
> op ::= "+" | "-" | "*" | "&" | "|" | "^"
> ```
>
> 各符号与 C++ 中的定义相同。`num` 为 32 位无符号整数，运算规则与 32 位整数一致，自然溢出。
>
> 给定 $n$ 组 $x_i,y_i$，判定是否存在位多项式 $f(x)$ 使得 $\forall 1 \le i\le n,f(x_i)=y_i$。
>
> 多测，$\sum n \le 3 \times 10^5$。

赛时瞪了 2h 大样例猜了个很离谱的结论过了。虽然我不知道为什么是对的。下面是讲题人做法。

注意到，它给了一堆多余的运算，比如或和异或都能用取反和与表示，减法可以用加法实现等等，但是没给除法和位移。大胆猜测这个东西有一些同余性质。

观察到，若 $x_i \equiv x_j \pmod {2^k}$，必有 $y_i \equiv y_j \pmod {2^k}$。因为位运算的性质是逐位的，满足同余的同加性、同乘性。容易发现这是 $f(x)$ 存在的必要条件。

证明充分性，这实际上是一个构造题。考虑根据 $x_i$ 的奇偶性分类构造再合并。由必要性得，$x_i$ 的奇偶性对应奇偶性相同的 $y_i$。设 $2 \mid x_i$ 时 $2 \mid (y_i-b_0)$，$2 \nmid x_i$ 时 $2 \mid (y_i-b_1)$，给出一个构造：

$f(x)=((x\& 1 ) \oplus 1) \times (2f_0(2x)+b_0)+(x\& 1)(2f_1(2x+1)+b_1)$于是我们证明了这个结论是充要的。现在有一个 $O(n^2)$ 的做法：枚举 $i,j$ 判 $\operatorname{lowbit}$。

从二进制位出发，枚举位 $k$，只需 $x_i,y_i$ 舍去 $k$ 以上的高位时一一对应。精细实现可以做到 $O(n \log V)$。赛时写的排序是 $O(n \log n \log V)$ 的。

```cpp
int n;
uint32_t x[N], y[N];
pair<uint32_t, uint32_t> mp[N];

void _main() {
	read(n);
	for (int i = 1; i <= n; i++) read(x[i], y[i]);
	uint32_t v = sub3();
	for (uint32_t k = 0; k < 32; k++) {
		for (int i = 1; i <= n; i++) mp[i].first = x[i] & ((1ULL << k) - 1), mp[i].second = y[i] & ((1ULL << k) - 1);
		sort(mp + 1, mp + n + 1);
		for (int i = 2; i <= n; i++) {
			if (mp[i].first == mp[i - 1].first && mp[i].second != mp[i - 1].second) return cout << "No\n", void();
		}
	} cout << "Yes\n";
}
```

### AT_abc365_e [ABC365E] Xor Sigma Problem

> **异或有三大思考方向：拆位、01-Trie、线性基。**

显然 $a \oplus b \oplus b =a$，所以考虑记录一个 $pre$ 数组记录前缀异或和。

则

$$
\begin{aligned}
\sum_{i=1}^{i<n} \sum_{j=i+1}^{j\le n} \bigoplus_{k=i}^{k \le j} a_k &=\sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} \bigoplus_{k=i}^{k \le j} a_k - \sum_{i=1}^{i\le n} a_i \\
&= \sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} pre_{i} \oplus pre_{j} - \sum_{i=1}^{i\le n} a_i
\end{aligned}
$$

其中 $\sum_{i=1}^{i\le n} a_i$ 可以 $O(n)$ 计算，重点是计算前面这部分。

考虑把每个数按二进制拆分，逐位记录贡献，统计异或后二进制位为 $1$ 的贡献。

$\sum_{i=1}^{i\le n} \sum_{j=i}^{j\le n} pre_{i} \oplus pre_{j}$ 的意思是两两异或，所以可以用乘法原理，枚举二进制位 $d$，再设 $pre$ 中有 $s_0$ 个二进制第 $d$ 位为 $0$ 的，有 $s_1$ 个二进制第 $d$ 位为 $1$ 的，枚举前缀异或 $j$，第 $i$ 位贡献为 $2^i s_{1-pre_j}$。

时间复杂度 $O(n \log w)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], pre[N];

void _main() {
	cin >> n;
	long long tot = 0;
	for (int i = 1; i <= n; i++) cin >> a[i], tot += a[i], pre[i] = pre[i - 1] ^ a[i];
	long long res = 0;
	for (int i = 27; i >= 0; i--) {
		int s[2] = {0, 0};
		for (int j = 1; j <= n; j++) {
			int u = pre[j - 1] >> i & 1, v = pre[j] >> i & 1;
			s[u]++, res += (1LL << i) * s[v ^ 1];
		}
	} cout << res - tot;
}
```

这个题代表了一类位运算问题的套路，就是按位考虑贡献。

### *P11651 [COCI 2024/2025 #4] Xor

还是按位考虑贡献，枚举当前位 $i$，答案的第 $i$ 位为 $1$ 当且仅当有奇数对 $(x,y)$ 满足 $a_x+a_y$ 第 $i$ 位为 $1$。

发现需要排除进位的影响。我们扔掉 $i+1$ 后面的位置，那么 $a_x+a_y \in [2^i,2^{i+1}-1]$ 是可以的，我们考虑进位的意义，就是 $a_x+a_y \in [3 \times 2^i, 2^{i+2}-1]$。可以容斥一下，统计出有多少对 $(x,y)$ 满足 $a_x+a_y \le 2^i$，以及 $2 \times 2^i$ 和 $3 \times 2^i$。精细实现可以做到 $O(n \log V)$。

具体地，考虑将 $a$ 排序后维护双指针 $i,j$，对于 $a_i +a_j \ge x$ 的情况不断缩减右端点并统计答案可以做到 $O(n)$。从高位向低位枚举 $i$，维护两个变长数组分别为舍掉第 $i+1$ 位和没有舍掉的，用类似归并排序的方法合并。这样做就优化掉了一个 log。

```cpp
const int N = 5e5 + 5;
int n, a[N];
long long solve(long long x) {
	long long res = 0;
	for (int i = 1, j = n; i <= n; i++) {
		while (a[i] + a[j] >= x && j >= 1) j--;
		res += n - max(i, j + 1) + 1;
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	sort(a + 1, a + n + 1);
	int res = 0;
	for (int i = 30; i >= 0; i--) {
		vector<int> x, y;
		for (int j = 1; j <= n; j++) {
			if (a[j] >> (i + 1) & 1) x.emplace_back(a[j] ^ (1 << (i + 1)));
			else y.emplace_back(a[j]);
		}
		merge(x.begin(), x.end(), y.begin(), y.end(), a + 1);
		long long v = solve(1LL << i) - solve(2LL * (1 << i)) + solve(3LL * (1 << i));
		if (v & 1) res |= 1 << i;
	} cout << res;
}
```

### *P5300 [GXOI/GZOI2019] 与或和

考虑拆位。以按位与为例，问题转化成：

- 给你一个 01 矩阵，求全为 $1$ 的子矩阵数目。$O(\log V)$ 组数据。

其实我们解决这个即可，因为总的矩阵数目为 $C_{n+1}^2 \times C_{n+1}^2$，减法原理简单算一算就能解决按位或。对于每一个点计算以它为右下角的子矩阵数目。求出二维数组 $b_{i,j}$ 表示上方有多少个连续的 $1$。根据木桶原理，没有贡献的点右边一定有一个更大的数，用单调栈维护即可。复杂度 $O(n^2 \log V)$。

```cpp
const int N = 1005;
int n, a[N][N], b[N][N], top, st[N];
mint calc(int d, int type) {
	for (int i = 1; i <= n; i++) b[1][i] = (a[1][i] >> d & 1) ^ type ^ 1;
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			int x = (a[i][j] >> d & 1) ^ type;
			b[i][j] = x ? 0 : b[i - 1][j] + 1;
		}
	}
	mint res = 0, cur = 0;
	for (int i = 1; i <= n; i++) {
		cur = 0, top = 0;
		for (int j = 1; j <= n; j++) {
			for (; top && b[i][st[top]] >= b[i][j]; top--) cur -= 1LL * b[i][st[top]] * (st[top] - st[top - 1]);
			cur += 1LL * b[i][j] * (j - st[top]), res += cur;
			st[++top] = j;
		}
	} return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	mint x = 0, y = 0, tot = mint(n) * n * (n + 1) * (n + 1) / 4;
	for (int i = 0; i < 31; i++) {
		x += mint(2).pow(i) * calc(i, 1);
		y += mint(2).pow(i) * (tot - calc(i, 0));
	} cout << x << ' ' << y;
}
```

### P5390 [Cnoi2019] 数学作业

考虑拆位，分类讨论：

1. 所有数的第 $i$ 位都为 $0$：答案的第 $i$ 位只能为 $0$。
2. 有至少一个数第 $i$ 位为 $1$：选奇数个元素即可，共有 $2^{n-1}$ 种选法。

观察到，这个分类讨论的过程就是求按位或的过程。因此答案就是按位或和乘上 $2^{n-1}$。

```cpp
int n, a;
void _main() {
	cin >> n;
	int x = 0;
	for (int i = 1; i <= n; i++) cin >> a, x |= a;
	cout << mint(2).pow(n - 1) * x << '\n';
}
```

### P4310 绝世好题

$O(n^2)$ 暴力 dp 显然。就是设 $dp_i$ 表示以 $a_i$ 结尾的子序列的最大长度，则枚举满足 $a_i \& a_j \ne 0$ 的 $j$ 有

$dp_i=\max_{j<i, a_i \& a_j \ne 0} (dp_j+1)$考虑位运算经典套路拆位。观察 $a_i \& a_j \ne 0$ 这个条件，发现只要 $i,j$ 在二进制下有一个相同位的 $1$ 就能转移。那么我们枚举二进制位 $j$，设 $dp_j$ 表示 $j$ 位为 $1$ 时的最大长度。若 $a_i$ 在二进制下的第 $j$ 位不为 $0$，则有转移

$dp_j=\max dp_{j'}+1$这里 $j'$ 是另一个二进制位，由它转移而来即可。一个数 $a_i$ 可以被其二进制位的 $dp$ 转移，再转移到它二进制位的 $dp$ 值上。比较抽象，可以看代码理解。复杂度 $O(n\log V)$。

```cpp
const int N = 1e5 + 5;
int n, a[N], dp[40];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		int mx = 0;
		for (int j = 0; j <= 31; j++) {
			if (a[i] >> j & 1) mx = max(mx, dp[j]);
		}
		for (int j = 0; j <= 31; j++) {
			if (a[i] >> j & 1) dp[j] = max(dp[j], mx + 1);
		}
	}
	cout << *max_element(dp, dp + 32);
}
```

### [模拟赛] 魔法传送门

> 现有一个有向图，对于两个节点 $i,j(i<j)$，两点间边的数量为 $\operatorname{popcount}(a_i \& a_j)$ 条。求从 $1$ 到 $n$ 的简单路径条数。
>
> $n \le 2 \times 10^5$，$1 \le a_i \le 2^{30}$。

有一个显然的 DAG 上 DP，设 $dp_i$ 表示 $i$ 到 $n$ 的路径条数，则

$dp_i =\sum_{j=i+1}^{n} dp_j \times \operatorname{popcount}(a_i \& a_j)$复杂度 $O(n^2)$。考虑这个式子的计数意义，当 $a_i,a_j$ 有一个相同的二进制位时产生 $dp_j$ 的贡献。和上题一样拆位，用 $f_i$ 表示二进制第 $i$ 位的累计贡献，和上题类似地转移即可。复杂度 $O(n \log V)$。

```cpp
const int N = 2e5 + 5;
int n, a[N];
mint dp[N], f[35];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fill(dp + 1, dp + n + 1, 0), fill(f, f + n + 1, 0);
	dp[n] = 1;
	for (int j = 30; j >= 0; j--) {
		if (a[n] >> j & 1) f[j] += dp[n];
	}
	for (int i = n - 1; i >= 1; i--) {
		for (int j = 30; j >= 0; j--) {
			if (a[i] >> j & 1) dp[i] += f[j];
		}
		for (int j = 30; j >= 0; j--) {
			if (a[i] >> j & 1) f[j] += dp[i];
		}
	} cout << dp[1] << '\n';
}
```

### [模拟赛] 小 Z 爱划分

> 给出长度为 $n$ 的序列 $a$，将其划分为若干段，得分为每一段数组元素异或和的积。
>
> 求所有划分方式的得分的平方和。对 $10^9+7$ 取模。
>
> $n \le 2 \times 10^5$，$1 \le a_i \le 10^9$。

套路题。先把 $a_i$ 变成前缀异或。考虑一个 DP，设 $f_i$ 表示前缀 $[1,i]$ 的答案。枚举上一次划分的点 $j$，有

$f_i=\sum_{j=0}^{i-1} f_j (a_i \oplus a_j)^2$复杂度 $O(n^2)$。考虑拆位优化 DP。注意到

$\left( \sum_{i=1}^n a_i\right)^2=\sum_{i=1}^n \sum_{j=1}^n a_ia_j$于是

$f_i=\sum_{x,y} \sum_{j=0}^{i-1} f_j2^{x+y}$要求 $a_i,a_j$ 的 $x,y$ 位不同。设 $g_{0/1,0/1,x,y}$ 表示二进制位对 $(x,y)$ 对 $f$ 的累计贡献。和上面两个题一样辗转转移即可。复杂度 $O(n \log^2 V)$。

```cpp
const int N = 2e5 + 5, M = 31;
int n, a[N];
mint f[N], g[2][2][M][M];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] ^= a[i - 1];
	fill(f, f + n + 1, 0), memset(g, 0, sizeof(g)), f[0] = 1;
	for (int i = 0; i < M; i++) {
		for (int j = 0; j < M; j++) g[0][0][i][j] = 1;
	}
	for (int i = 1; i <= n; i++) {
		for (int x = 0; x < M; x++) {
			for (int y = 0; y < M; y++) f[i] += g[(a[i] >> x & 1) ^ 1][(a[i] >> y & 1) ^ 1][x][y] * (1LL << (x + y));
		}
		for (int x = 0; x < M; x++) {
			for (int y = 0; y < M; y++) g[a[i] >> x & 1][a[i] >> y & 1][x][y] += f[i];
		}
	} cout << f[n] << '\n';
}
```

本人赛时在 `(1LL << (x + y))` 这里用了快速幂，多了 $8$ 倍常数，100->20，警钟长鸣。

### CF2066C Bitwise Slides

异或性质好题。注意到异或有结合律，考虑求出 $a_i$ 的前缀异或 $p_i$，则 $P \oplus Q \oplus R=p_i$。又因为 $P,Q,P$ 中两数相同，根据 $a \oplus a=0$ 转化为 $P,Q,R$ 中至少有一个数为 $p_i$。

考虑计数 DP。令 $dp_{i,j}$ 表示考虑到第 $i$ 位，相同的两数值为 $j$ 的方案数。容易得到 $dp_{i,p_i}=dp_{i-1,p_i}$ 和 $dp_{i,j}=dp_{i-1,j}, j \ne p_i,p_{i-1}$，滚动数组以后值不变。

考虑 $dp_{i,p_{i-1}}$ 如何转移。对于 $dp_{i-1,p_i}$，可以操作等于 $p_i$ 的两个值；对于 $dp_{i-1,p_{i-1}}$，三数相等。由加法原理得：

$dp_{i,p_{i-1}}=3 \times dp_{i-1,p_{i-1}}+2 \times dp_{i-1,p_i}$注意到状态值域很大，但有效状态数只有 $O(n)$ 个。用 std::map 维护转移即可。

```cpp
const int N = 2e5 + 5;
int n, a[N];
map<int, mint> dp;

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] ^= a[i - 1];
	dp.clear(), dp[0] = 1;
	for (int i = 1; i <= n; i++) dp[a[i - 1]] = dp[a[i - 1]] * 3 + dp[a[i]] * 2;
	mint res = 0;
	for (auto it : dp) res += it.second;
	cout << res << '\n';
}
```

### UVA12716 GCD等于XOR GCD XOR

神秘结论题。不妨设 $a\ge b$，则由位运算性质 1 有 $a-b \le a \oplus b$。

设 $\gcd(a,b)=c$，则 $a,b$ 可以写成 $a=a_0c,b=b_0c$ 的形式。那么 $a-b=(a_0-b_0)c$，因为 $a_0 \ge b_0$，所以 $a-b \ge \gcd(a,b)$。

于是我们得到结论：$\gcd(a,b)=a\oplus b=a-b$。根据这个玩意枚举 $a,b$，复杂度是调和级数 $O(n \log n)$ 可以通过。

```cpp
const int N = 3e7 + 5;
int n, res[N];

void _main() {
	for (int b = 1; b <= N / 2; b++) {
		for (int a = b * 2; a < N; a += b) {
			if ((a ^ b) == a - b) res[a]++;
		}
	}
	for (int i = 2; i < N; i++) res[i] += res[i - 1];
	int t; cin >> t;
	for (int i = 1; i <= t; i++) cin >> n, cout << "Case " << i << ": " << res[n] << '\n';
}
```

### P5911 [POI 2004] PRZ

用二进制数 $s$ 表示选择的队员，$dp_s$ 表示当前状态下的最短过桥时间，然后再维护一下每个状态的**总**重量 $a_i$ 和**最大**时间 $b_i$。

转移就是从 $s$ 中分出一个子集 $t$，满足 $a_t \le W$，则 $dp_s \gets \min(dp_s, dp_{s \oplus t}+b_t)$。

使用上面讲过的子集枚举，复杂度为 $O(3^n)$。

```cpp
const int N = 17;
int w0, n, t[N], w[N], a[1 << N], b[1 << N], dp[1 << N];

void _main() {
	cin >> w0 >> n;
	for (int i = 1; i <= n; i++) cin >> t[i] >> w[i];
	for (int s = 0; s < (1 << n); s++) {
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) a[s] += w[i], b[s] = max(b[s], t[i]);
		}
	}
	memset(dp, 0x3f, sizeof(dp));
	dp[0] = 0;
	for (int s = 0; s < (1 << n); s++) {
		for (int t = s; t; t = (t - 1) & s) {
			if (a[t] <= w0) dp[s] = min(dp[s], dp[s ^ t] + b[t]);
		}
	} cout << dp[(1 << n) - 1];
}
```

### CF165E Compatible Numbers

SOS DP 板子题。注意到 $a_i \& a_j=0$ 等价于 $a_i \subseteq (\sim a_j)$，启示我们预处理一个高维前缀和，查询子集是否为空即可。

```cpp
const int N = 1e6 + 5, M = 22;
int n, a[N], f[1 << M];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], f[a[i]] = a[i];
	for (int i = 0; i < M; i++) {
		for (int s = 0; s < (1 << M); s++) {
			if ((s >> i & 1) && f[s ^ (1 << i)]) f[s] = f[s ^ (1 << i)];
		}
	}
	for (int i = 1; i <= n; i++) {
		int x = ((1 << M) - 1) ^ a[i];
		cout << (f[x] ? f[x] : -1) << ' ';
	}
}
```$AKB271$, '数学', array['位运算', '按位与', '按位异或', 'lowbit'], 'col-math-oi-foundations', null, 'knowledge'),
('Xesir', 'col-math-bit-operation--xesir', '位操作 · Xesir', $AKB272$## 算法原理

计算机里的整数是用二进制存储的，所以直接对二进制位进行操作，往往比做乘除法快得多。

常用的位运算符有：

- `&`（按位与）：两个位都是 1 结果才是 1。
- `|`（按位或）：只要有一个是 1 结果就是 1。
- `^`（按位异或）：两个位不同结果为 1，相同为 0。
- `~`（按位取反）：0 变 1，1 变 0。
- `<<`（左移）：整体向左移动，右边补 0，相当于乘以 2。
- `>>`（右移）：整体向右移动，相当于除以 2（向下取整）。

位操作在状压 DP、树状数组、快速幂、哈希等场景中无处不在。比如判断一个数是不是 2 的幂：`(x & (x - 1)) == 0`；获取二进制最低位的 1：`lowbit(x) = x & -x`。

> OI 必备技能，位运算比大多数运算（如四则运算）都快多了，要养成优先用位运算的习惯。

## 核心公式 / 状态定义与转移方程

位运算里真正需要背的"公式"其实没几个，常用的就下面这几条：

- 取最低位的 1（以及它后面的 0）：`lowbit(x) = x & -x`。
- 抹掉最低位的 1：`x & (x - 1)`。反复做这个操作，可以数出 `x` 有多少个 1。
- 判断 2 的幂：`x > 0` 且 `(x & (x - 1)) == 0`。
- 把第 `i` 位置 1：`x | (1 << i)`；置 0：`x & ~(1 << i)`；取反：`x ^ (1 << i)`；查询：`(x >> i) & 1`。
- 乘除 2 的幂：`x << k` 等于 `x * 2^k`，`x >> k` 等于 `x / 2^k`（向下取整）。

其中 `lowbit` 是树状数组能跑起来的根本原因：`x & -x` 恰好就是"`x` 这个节点管的那一段长度"。

## 逐行代码解析

### 模块一：lowbit

```cpp
int lowbit(int x){
    return x & -x;      // -x 是补码下的取反加一，与上去只剩最低位的 1
}
```

- `-x` 在补码里等于 `~x + 1`，它会把 `x` 最低位的 1 保留、更低的位置 0，所以 `x & -x` 正好抠出最低位的 1。
- 例：`x = 12 = 1100`，`-x` 的低 4 位是 `0100`，与一下得 `0100`，也就是 4。

### 模块二：判断 2 的幂

```cpp
bool ispow2(int x){
    return x > 0 && (x & (x - 1)) == 0;
}
```

- 2 的幂的二进制一定是"一个 1 后面跟一串 0"，减 1 之后变成"一串 0 后面跟一串 1"，两者与起来必然为 0。
- `x > 0` 这个条件不能省：`x = 0` 时 `0 & -1` 也是 0，会被误判成 2 的幂。
- 注意括号：`&` 的优先级比 `==` 低，不写括号就变成 `x & ((x - 1) == 0)`，意思完全变了。

## 复杂度分析

单个位运算指令是 $O(1)$ 的，所以这些技巧本身都是常数时间、常数空间。

不过在复杂度分析里，真正需要留意的是"位运算把常数压掉了多少"：`x * 2` 和 `x << 1` 在编译器优化后往往一样快，但 `% 2` 和 `& 1`、`/ 2` 和 `>> 1` 在取模/除法较慢的场合差别就明显了。另外，`__builtin_popcount`、`__builtin_ctz` 这类内建函数一般会被编译成单条指令，比自己写循环数位快得多。

## 适用场景

- **状压 DP**：用整数的二进制位表示集合的选中状态，转移全靠位运算。
- **树状数组**：`lowbit` 决定了 `i += i & -i` 的跳跃方式。
- **快速幂**：指数按二进制位拆，靠 `y & 1` 和 `y >>= 1` 逐位处理（见「快速幂」那条）。
- **哈希**：哈希表容量取 2 的幂时，可以用 `hash & (size - 1)` 代替取模。
- **倍增 / 二进制拆分**：任何"按 2 的幂预处理、按二进制位拼答案"的算法都离不开它。

## 常见陷阱与注意事项

1. **优先级**：`&`、`|`、`^` 的优先级比 `==`、`!=` 还低，`x & 1 == 0` 会被解析成 `x & (1 == 0)`。凡是位运算和比较混用，一律加括号。
2. **右移负数**：`>>` 对负数是算术右移（高位补符号位），效果是**向下取整**；而 C++ 的 `/` 是**向零取整**。所以 `-7 >> 1` 是 `-4`，`-7 / 2` 是 `-3`，两者不一样。
3. **左移溢出**：`1 << 31` 在 `int` 上已经溢出（32 位有符号数最高位是符号位），要写成 `1LL << 31`。同理 `1 << i` 的 `i` 到 31 就该警惕。
4. **`~` 不是逻辑取反**：`~x` 等于 `-x - 1`，`~0` 是 `-1` 而不是 `false`。逻辑取反请用 `!`。
5. **`x & (x - 1)` 判 2 的幂时 `x` 必须为正**：`x = 0` 会被误判，`x` 为负时也没有意义。
6. **无符号与有符号混用**：`size_t` 这类无符号类型和 `int` 运算时会被提升成无符号，`-1` 会变成极大的正数，循环条件直接失控。$AKB272$, '数学', array['数学', '位运算', '二进制', 'lowbit', '状压'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-bit-operation-advanced--stripe-python', '位运算进阶：01-Trie 与 bitset · stripe-python', $AKB273$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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
```$AKB273$, '数学', array['01-Trie', 'bitset', '位运算'], 'col-math-oi-foundations', null, 'knowledge'),
('Fohen', 'col-math-block-division--fenfeng', '整除分块（数论分块） · Fohen', $AKB274$## 算法原理

整除分块（也叫数论分块）用于解决一类**整除求和**问题：给定 $n$，求

$$
\sum_{i=1}^{n} \left\lfloor \frac{n}{i} \right\rfloor
$$

朴素的直接枚举是 $O(n)$，当 $n \le 10^9$ 时就不可接受了。整除分块的核心观察是：**$\lfloor n/i \rfloor$ 的取值个数远小于 $n$**。

- 随着 $i$ 增大，$\lfloor n/i \rfloor$ 单调不增，且每个取值在 $i$ 上**连续成段**（例如 $n=21$ 时 $\lfloor 21/i \rfloor$ 依次是 $21,10,7,5,5,4,3,3,3,2,2,\dots,1$，越往后越稀疏）。
- 可以证明 $\lfloor n/i \rfloor$ 的不同取值个数 $\le 2\sqrt n$：当 $i \le \sqrt n$ 时最多 $\sqrt n$ 种；当 $i > \sqrt n$ 时 $\lfloor n/i \rfloor < \sqrt n$，也最多 $\sqrt n$ 种。

于是我们把 $i$ 按「$\lfloor n/i \rfloor$ 相同」分成若干块，每块只算一次，复杂度降到 $O(\sqrt n)$。

## 核心公式

对每个块，已知左端点 $l$，其右端点是

$$
r = \left\lfloor \frac{n}{\lfloor n/l \rfloor} \right\rfloor
$$

即 `r = n / (n / l)`（注意这里的除法都是下取整，且 $r$ 要再和 $n$ 取 $\min$ 防止越界）。

## 逐行代码解析

伪代码如下：

```cpp
for (int l = 1; l <= n; l = r + 1) {
    r = min(n, n / (n / l));      // 当前块右端点
    cnt += s(l, r) * (n / l);     // s(l,r) 是该块的"贡献"，n/l 是整块共同的 ⌊n/i⌋ 值
}
```

- `l = r + 1`：跳到下一块的左端点。
- `r = n / (n / l)`：由「$l$ 所在块右端点」公式直接得出。
- `s(l, r)`：表示区间 $[l, r]$ 上的额外贡献（如区间长度、区间和、某函数值之和）；若它能 $O(1)$ 求出，则整体就是 $O(\sqrt n)$。

## 复杂度分析

- **时间复杂度**：块数 $O(\sqrt n)$，每块 $O(1)$，总计 $O(\sqrt n)$。
- **空间复杂度**：$O(1)$。

## 适用场景

- 求 $\sum_{i=1}^n \lfloor n/i \rfloor$ 这类整除求和。
- 统计 $[1,n]$ 中约数个数、约数和等需要按 $\lfloor n/i \rfloor$ 分段的计数问题。
- 是莫比乌斯反演、杜教筛等更复杂数论推导的基础工具。

## 常见陷阱与注意事项

1. **右端点要取 $\min(n, \cdot)$**：`n / (n / l)` 在 $l$ 较小时可能超过 $n$，必须 `min(n, ...)`。
2. **死循环**：忘记 `l = r + 1` 会在同一块原地打转。
3. **整除顺序**：`n / (n / l)` 里两次除法都要下取整，写成 `n / n / l` 就错了。
4. **溢出**：$n$ 很大（接近 `int` 上限）时，块内累加用 `long long` 防溢出。
5. **边界**：$l$ 从 $1$ 开始；$n=0$ 需特判（此时无意义）。

## 对比与扩展

| 方法 | 复杂度 | 适用 |
|---|---|---|
| 直接枚举 | $O(n)$ | $n$ 很小 |
| 整除分块 | $O(\sqrt n)$ | $n \le 10^9 \sim 10^{18}$ 的整除求和 |
| 杜教筛 | $O(n^{2/3})$ | 前缀和型的数论函数求和 |
| 莫比乌斯反演 | 视推导 | 带卷积/容斥的计数，常与整除分块结合 |$AKB274$, '数学', array['数学', '数论', '整除分块', '根号复杂度'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-block-division--stripe-python', '整除分块（数论分块） · stripe-python', $AKB275$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 6. 数论分块

数论分块用于快速计算形如

$\sum_{i=1}^{n} f(i) g(\lfloor \dfrac{k}{i} \rfloor)$的式子，其中 $f(i)$ 可处理出前缀和或可以快速计算 $f(x)-f(y)$。如果这是 $O(1)$ 的，则数论分块可在 $O(\sqrt{n})$ 的时间内得出结果。

## 6.1 原理

以函数 $y=\lfloor \dfrac{100}{x} \rfloor$ 为例，图像如下：

![](https://cdn.luogu.com.cn/upload/image_hosting/xsvja4az.png)

我们注意到对于每个固定的 $y$，$x$ 的取值总是一个固定区间。事实上，$\lfloor \dfrac{k}{i} \rfloor$ 不变时，$i \le \lfloor \frac{k}{\lfloor \frac{k}{i} \rfloor} \rfloor$。

设 $m=\lfloor \dfrac{k}{i} \rfloor$，则 $m \le \dfrac{k}{i}$，所以 $\lfloor \dfrac{k}{m} \rfloor \ge \lfloor \frac{k}{\frac{k}{i}} \rfloor=i$。

因此，$i_{\max}=\lfloor \dfrac{k}{m} \rfloor=\lfloor \frac{k}{\lfloor \frac{k}{i} \rfloor} \rfloor$。

## 6.2 板子

```cpp
template <class F_t, class G_t>
long long sqrt_decomposition(long long n, long long k, F_t f, G_t g) {
	long long res = 0;
	for (long long l = 1, r = 0; l <= n; l = r + 1) {
		r = (k / l) ? min(n, (k / (k / l))) : n;
		res += f(r, l - 1) * g(k / l);
	}
	return res;
}
```

这个板子第一个参数传入 $n$，第二个参数传入 $k$，第三个参数传入一个函数计算 $f(x)-f(y)$，第四个参数传入 $g(x)$ 的函数。

## 6.3 例题

### UVA11526 H(n)

【模板】数论分块。

```cpp
int n;
void _main() {
	cin >> n;
	cout << sqrt_decomposition(n, n,
		[](long long x, long long y) {return x - y;}, // f(x) = 1
		[](long long x) {return x;} // g(x) = x
	) << '\n';
}
```

### P2424 约数和

首先考虑求 $f(x)$ 的前缀和 $g(x)$。有一个结论是 $i$ 的约数在 $n$ 以内有 $\lfloor \dfrac{n}{i} \rfloor$ 个，所以

$g(x) = \sum_{i=1}^{n} i \times \lfloor \dfrac{n}{i} \rfloor$然后套板子去求即可。

```cpp
long long g(long long n) {
	if (n <= 1) return n;
	return sqrt_decomposition(n, n,
		[](long long x, long long y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
}

long long l, r;
void _main() {
	cin >> l >> r;
	cout << g(r) - g(l - 1);
}
```

### P2261 [CQOI2007] 余数求和

根据取模的定义，有 $a \bmod b=a-b \times \lfloor \dfrac{a}{b} \rfloor$，然后推一波式子：

$$
\begin{aligned}
G(n, k) &= \sum_{i = 1}^n k \bmod i \\
&= \sum_{i = 1}^n k -i \times \lfloor \dfrac{k}{b} \rfloor \\
&= nk-\sum_{i = 1}^n i \times \lfloor \dfrac{k}{b} \rfloor
\end{aligned}
$$

后面这个东西可以数论分块来做。

```cpp
long long n, k;

void _main() {
	cin >> n >> k;
	cout << n * k - sqrt_decomposition(n, k,
		[](long long x, long long y) {return (x - y) * (x + y + 1) / 2;}, // f(x) = x
		[](long long x) {return x;} // g(x) = x
	);
}
```

### *P2260 [清华集训 2012] 模积和

和上面的题很像。推柿子：

$$
\begin{aligned}
ans &=\sum_{i=1}^{n} \sum_{j=1}^{m} (n \bmod i) \times (m \bmod j), i \neq j  \\

&=\sum_{i=1}^{n} \sum_{j=1}^{m} (n \bmod i) \times (m \bmod j)-\sum_{i=1}^{\min(n,m)} (n \bmod i) \times (m \bmod i)\\

&=\sum_{i=1}^n(n-\lfloor\frac{n}{i}\rfloor\times i)\times\sum_{j=1}^m(m-\lfloor\frac{m}{j}\rfloor\times j)-\sum_{i=1}^{\min(n,m)}(n-\lfloor\frac{n}{i}\rfloor\times i)\times(m-\lfloor\frac{m}{i}\rfloor\times i)\\

&=(n^2-\sum_{i=1}^ni\times\lfloor\frac{n}{i}\rfloor)\times(m^2-\sum_{i=1}^mi\times\lfloor\frac{m}{i}\rfloor)-\sum_{i=1}^{\min(n,m)}(nm-mi\times\lfloor\frac{n}{i}\rfloor-ni\times\lfloor\frac{m}{i}\rfloor+i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor)\\

&=(n^2-\sum_{i=1}^ni\times\lfloor\frac{n}{i}\rfloor)\times(m^2-\sum_{i=1}^mi\times\lfloor\frac{m}{i}\rfloor)-nm\times \min(n,m)+\sum_{i=1}^{\min(n,m)}mi\times\lfloor\frac{n}{i}\rfloor+\sum_{i=1}^{\min(n,m)} ni\times\lfloor\frac{m}{i}\rfloor -\sum_{i=1}^{\min(n,m)}  i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor
\end{aligned}
$$

最后这个 $i^2\times\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor$ 用数论分块的时候不太一样。首先我们需要保证块内的 $\lfloor\frac{n}{i}\rfloor\times\lfloor\frac{m}{i}\rfloor$ 相同，将右端点改为 $\min(\lfloor \frac{n}{\lfloor \frac{n}{i} \rfloor} \rfloor,\lfloor \frac{m}{\lfloor \frac{m}{i} \rfloor} \rfloor)$，这叫做二维数论分块。然后用到结论 $\sum_{i=1}^{n} i^2=\frac{n(n+1)(2n+1)}{6}$。不了解这个结论可以翻到下文 7.2.3 幂数列求和结论 2。

```cpp
long long n, m;
modint pre(modint n) {return n * (n + 1) * (n * 2 + 1) / modint(6);}
modint k1() {  // 这里没法套板子，自己写一个
	modint res = 0;
	for (long long l = 1, r = 0; l <= min(n, m); l = r + 1) {
		r = min(n / (n / l), m / (m / l));
		res += modint(n / l) * modint(m / l) * (pre(r) - pre(l - 1));
	}
	return res;
}

void _main() {
	cin >> n >> m; long long k = min(n, m);
	modint n0 = n, m0 = m;
	modint n1 = n0 * n0 - sqrt_decomposition(n, n,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
	modint m1 = m0 * m0 - sqrt_decomposition(m, m,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[](long long x) {return x;}
	);
	modint n2 = sqrt_decomposition(k, n,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[&](long long x) {return m0 * x;}
	);
	modint m2 = sqrt_decomposition(k, m,
		[](modint x, modint y) {return (x - y) * (x + y + 1) / 2;},
		[&](long long x) {return n0 * x;}
	);
	cout << n1 * m1 - n0 * m0 * k + n2 + m2 - k1();
}
```

### P6583 回首过去

由小学奥数可得，满足题意的 $x,y$ 在约分后，$y$ 的质因子只有 $2$ 和 $5$。也就是形如 $\dfrac{bc}{ac}$ 的分数中，$a$ 仅含有 $2$ 和 $5$ 的质因子，$c$ 不含有 $2$ 或 $5$ 的质因子。

枚举符合要求的 $c$，则 $a \le \lfloor \dfrac{n}{c} \rfloor$，直接用若干个 $2$ 和 $5$ 凑出 $a$，若 $a$ 的个数为 $cnt$，贡献就是 $\lfloor \dfrac{n}{c} \rfloor \times cnt$。可以获得 80pts。

```cpp
long long n;

void _main() {
	cin >> n;
	long long res = 0;
	for (int c = 1; c <= n; c++) {
		long long cnt = 0;
		if (c % 2 == 0 || c % 5 == 0) continue;
		for (int i = 1; i <= n; i <<= 1) {
			for (int j = 1; j <= n; j *= 5) {
				if (1LL * c * i * j > n) break;
				cnt++;
			}
		} res += cnt * (n / c);
	} cout << res;
}
```

看到 $\sum \lfloor \dfrac{n}{c} \rfloor \times cnt$ 这个式子，就是数论分块了。然而 $c$ 选取不连续，要跳过含 $2$ 和 $5$ 质因子的数。我们可以用下文的容斥原理，设 $h(l,r,d)=\lfloor \dfrac{r}{d} \rfloor-\lfloor \dfrac{l-1}{d} \rfloor$ 表示 $[l,r]$ 中有多少个数是 $d$ 的倍数，则区间长度就是 $(r-l+1) -g(l,r,2)-g(l,r,5)+g(l,r,10)$，于是问题解决。

```cpp
#define int long long
int n;
int cnt(int n) {
	int res = 0;
	for (int i = 1; i <= n; i <<= 1) {
		for (int j = 1; j <= n; j *= 5) {
			if (1LL * i * j > n) break;
			res++;
		}
	} return res;
}
int g(int l, int r, int d) {return r / d - (l - 1) / d;}

void _main() {
	cin >> n;
	int res = 0;
	for (int l = 1, r = 0; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		res += cnt(n / l) * (n / l) * (r - l + 1 - g(l, r, 2) - g(l, r, 5) + g(l, r, 10));
	} cout << res;
}
```$AKB275$, '数学', array['整除分块', '数论分块', '下取整求和'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-block-division--xesir', '整除分块 · Xesir', $AKB276$## 算法原理

> 引入：

给定一个 $n$，求 $\sum_{i=1}^{n} \left\lfloor \frac{n}{i} \right\rfloor$。

你可能会想：这还不简单，直接对于每个 $i$ 求一遍 $\frac{n}{i}$ 下取整的值，再求和不就行了？

你说的对，但是这个算法是 $O(n)$ 的，要怎么处理 $n \le 10^9$ 的数据呢？

整除分块，一个简单但好用的数论思想，用于解决整除类相关的统计问题。

> ~~和分块数据结构并没有什么关系~~

整除有一个重要性质：随着 $i$ 增加，$\lfloor \frac{n}{i} \rfloor$ 单调不增。这使得 $\lfloor \frac{n}{i} \rfloor$ 的每个值在数组中连续。

首先我们有一个很敏锐的观察：虽然 $n$ 很大，但 $\lfloor \frac{n}{i} \rfloor$ 的情况总数并不多。比如 $n = 21$ 时，$\lfloor 21/i \rfloor$ 依次是 $21, 10, 7, 5, 4, 3, 3, 3, 2, 2, 2, \dots$，越往后越稀疏、重复越多。

我们可以证明：$\lfloor \frac{n}{i} \rfloor$ 的情况总数严格不超过 $2\sqrt n$。

- 对于 $i \le \sqrt n$：$i$ 只有 $\sqrt n$ 个，$\lfloor \frac{n}{i} \rfloor$ 至多 $\sqrt n$ 种取值。
- 对于 $i \ge \sqrt n$：$\lfloor \frac{n}{i} \rfloor \le \sqrt n$，也至多 $\sqrt n$ 种取值。

所以我们只需要计算出每个连续块的左边界与右边界，就可以在 $O(\sqrt n)$ 时间内得到答案。

如何计算呢？我们可以很容易得到 $i$ 所在块的右端点是 $\left\lfloor \frac{n}{\lfloor n/i \rfloor} \right\rfloor$，那么每次转移只需要 `r = n / (n / l)` 即可。

## 核心公式 / 状态定义与转移方程

设当前块的左端点为 $l$，则该块内所有 $i$ 的 $\lfloor n/i \rfloor$ 都相同，右端点为

$$
r = \left\lfloor \frac{n}{\left\lfloor n/l \right\rfloor} \right\rfloor
$$

这个式子的意思是：既然这一段的值是 $v = \lfloor n/l \rfloor$，那么所有满足 $\lfloor n/i \rfloor = v$ 的 $i$ 里最大的那个就是 $\lfloor n/v \rfloor$，因为 $i \le n/v$ 时 $n/i \ge v$，而 $i > n/v$ 时 $n/i < v$。

下一块的左端点直接取 $r + 1$，区间贡献计入后继续，直到 $l > n$。

## 逐行代码解析

原文给的是伪代码，这里逐行拆开看：

### 模块一：块循环骨架

```cpp
for(int l=1;l<=n;l=r+1){
    r=min(n,n/(n/l));
    cnt+=s(l,r)*(n/l);
}
```

- `l = 1` 起步，`l = r + 1` 跳到下一块的开头，`l <= n` 时一直做下去。
- `r = min(n, n/(n/l))` 算出当前块的右端点；`min(n, ...)` 是防止最后一块算出超过 $n$ 的值。
- `n / l` 就是这一整块的 $\lfloor n/i \rfloor$ 值，所以可以直接乘以区间贡献。

### 模块二：`s(l, r)` 该写什么

`cnt += s(l,r) * (n/l)` 里的 `s(l, r)` 表示 $[l, r]$ 这一段的"贡献系数"。原题求 $\sum \lfloor n/i \rfloor$ 时，每项系数都是 1，所以 `s(l, r) = r - l + 1`，整块就是 `(r - l + 1) * (n / l)`。

换成别的题时，`s(l, r)` 一般是某个可以 $O(1)$ 求和的式子（比如 $\sum i$、$\sum i^2$、$\sum f(i)$），预处理前缀和即可。

若 `s(l, r)` 可以 $O(1)$ 求出，则整体复杂度为 $O(\sqrt n)$。

## 复杂度分析

块的数量不超过 $2\sqrt n$，每块内部 $O(1)$，所以总时间复杂度 $O(\sqrt n)$，额外空间 $O(1)$（如果 `s(l,r)` 需要前缀和，则是 $O(n)$ 预处理、$O(n)$ 空间）。

和直接枚举的对比很直观：$n = 10^9$ 时，$O(n)$ 是 $10^9$ 次运算，$O(\sqrt n)$ 只有约 $6.3 \times 10^4$ 次。

## 适用场景

- **整除求和**：$\sum_{i=1}^{n} f(\lfloor n/i \rfloor)$ 这一类，把相同取值的段合并。
- **数论函数求和**：配合莫比乌斯反演、欧拉反演，把 $\sum_{i,j}\gcd(i,j)$ 化成 $\sum_d \varphi(d)\lfloor n/d\rfloor^2$ 之后再用整除分块算。
- **杜教筛 / 洲阁筛**：这些高级筛法的递归过程中，$\lfloor n/i \rfloor$ 的取值同样只有 $O(\sqrt n)$ 种，本质上也是整除分块。
- **求 $\sum_{i=1}^{n} \lfloor n/i \rfloor$ 类计数**：比如统计约数个数和。

## 常见陷阱与注意事项

1. **忘了 `min(n, ...)`**：最后一块的 `n/(n/l)` 可能超过 $n$，不加 `min` 会多算。
2. **整数除法方向**：C++ 的 `/` 对正数是向下取整，正好符合这里的需求；但涉及负数时（比如某些推式子）方向就反了。
3. **`l = r + 1` 写成 `l++`**：那就退化成 $O(n)$ 了，白算。
4. **块内取值不是 `n/l`**：块内 $\lfloor n/i \rfloor$ 的值确实等于 `n/l`（左端点的值），但别顺手写成 `n/r`，那是右端点的值，通常是更小的。
5. **`s(l, r)` 不能 $O(1)$ 求时别硬套**：如果贡献需要 $O(\text{len})$ 才能算，整除分块就失去意义了。$AKB276$, '数学', array['数学', '数论', '整除分块', '根号复杂度'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-block-division', '整除分块（数论分块）', $AKB277$## 算法原理

**一句话结论**：数论分块（整除分块）的核心思想只有一句——**按某个整除结果分段，段内批量处理，段与段之间用除法跳转**。它把 $\sum_{i=1}^{n}\left\lfloor\dfrac{n}{i}\right\rfloor$ 这类从 $O(n)$ 的逐项求和降到 $O(\sqrt{n})$。

**解决的问题**：计算

$$S(n)=\sum_{i=1}^{n}\left\lfloor\frac{n}{i}\right\rfloor$$

**关键观察：单调 + 大量重复值**。$\lfloor n/i\rfloor$ 随 $i$ 增大单调不增，并且大量相邻 $i$ 取同一个值。例如 $n=10$ 时十个取值是 $10,5,3,2,2,1,1,1,1,1$，只有 5 个不同的段：$[1,1]$、$[2,2]$、$[3,3]$、$[4,5]$、$[6,10]$。只要能把每段一次算掉，总工作量就从 10 降到 5；$n$ 很大时这个差距是 $O(n)$ 与 $O(\sqrt n)$ 的差距。

**核心推导：段右端点怎么求**。设当前段的左端点为 $L$，段内值为 $v=\lfloor n/L\rfloor$，右端点为 $R$。段内值恒为 $v$ 即 $v\le n/R<v+1$，乘 $R$ 得 $vR\le n<(v+1)R$，整理为 $n/(v+1)<R\le n/v$。取 $R$ 的最大整数值：

$$R=\left\lfloor\frac{n}{v}\right\rfloor$$

下一个不同值的段从 $R+1$ 开始。整个循环就是：`v = n / l` → `r = n / v` → 段内乘长度 → `l = r + 1`。

**为什么这样做是对的**：段内值恒定由上式保证（不漏）；$l$ 每轮跳到 $r+1$ 且 $r\ge l$ 严格递增，最终越过 $n$ 退出（不重、有限步）。所以每个 $i$ 恰被统计一次，结果与逐项求和完全一致。

**为什么段数只有 $O(\sqrt n)$**：当 $i\le\sqrt n$ 时这样的 $i$ 至多 $\sqrt n$ 个；当 $i>\sqrt n$ 时 $\lfloor n/i\rfloor<\sqrt n$，取值至多 $\sqrt n$ 种。两种情况段数都不超过 $O(\sqrt n)$。

## 核心公式 / 状态定义与转移方程

**连续型（fn1）——段内值是常数**：

- 段内值：$v=\left\lfloor\dfrac{n}{l}\right\rfloor$
- 段右端：$r=\left\lfloor\dfrac{n}{v}\right\rfloor$
- 段内贡献：$v\cdot(r-l+1)$，即「值 × 长度」

$$S(n)=\sum_{\text{每段}} v\cdot len$$

**余数型（fn2）——段内是 $i$ 的一次函数**。利用恒等式 $n\bmod i=n-i\lfloor n/i\rfloor$：

$$T(n)=\sum_{i=1}^{n}(n\bmod i)=\sum_{i=1}^{n}n-\sum_{i=1}^{n}i\left\lfloor\frac{n}{i}\right\rfloor=n^2-\sum_{i=1}^{n}i\left\lfloor\frac{n}{i}\right\rfloor$$

分块方式与 fn1 相同，但段内 $n\bmod i=n-iv$ 随 $i$ 线性变化，必须用等差数列求和：设 $len=r-l+1$、$sum_i=\dfrac{(l+r)\cdot len}{2}$，段内贡献为

$$n\cdot len-v\cdot sum_i$$

**倍数型（fn3）——沿 $k$ 的幂分层**。把 $1\sim n$ 中的数按「根 $a$ 不被 $k$ 整除」分链：根 $a$ 的链是 $a,\ ak,\ ak^2,\dots\le n$，链长 $L(a)=\max\{t:ak^t\le n\}+1$。设 $U_t=\left\lfloor n/k^t\right\rfloor$，由整除恒等式 $\lfloor\lfloor n/a\rfloor/b\rfloor=\lfloor n/(ab)\rfloor$ 得递推：

$$U_{t+1}=\left\lfloor\frac{U_t}{k}\right\rfloor$$

链长恰为 $t+1$ 的根满足 $U_{t+1}<a\le U_t$（连续候选区间），再从中扣掉 $k$ 的倍数：区间内 $k$ 的倍数个数 = $\lfloor U_t/k\rfloor-\lfloor U_{t+1}/k\rfloor=U_{t+1}-U_{t+2}$。于是链长为 $t+1$ 的根个数是**二阶差分**：

$$cnt_{t+1}=(U_t-U_{t+1})-(U_{t+1}-U_{t+2})=U_t-2U_{t+1}+U_{t+2}$$

代码变量替换 $U=U_t,\ D=U_{t+1},\ D/k=U_{t+2}$，得 `cnt = U - 2*D + D/k`；下一层 `U = D`、`++len`。层数只有 $O(\log_k n)$。

**手算示例 1（连续型，$n=10$）**：

| l | v | r | 段 | 贡献 |
|---|---|---|---|---|
| 1 | 10 | 1 | [1,1] | 10 |
| 2 | 5 | 2 | [2,2] | 5 |
| 3 | 3 | 3 | [3,3] | 3 |
| 4 | 2 | 5 | [4,5] | 2×2=4 |
| 6 | 1 | 10 | [6,10] | 1×5=5 |

合计 $10+5+3+4+5=27$，与逐项求和的 $10+5+3+2+2+1+1+1+1+1=27$ 一致。经本代码实测输出 27。

**手算示例 2（余数型，$n=10$）**：

| l | v | r | len | sum_i | 段内贡献 |
|---|---|---|---|---|---|
| 1 | 10 | 1 | 1 | 1 | 10−10=0 |
| 2 | 5 | 2 | 1 | 2 | 10−10=0 |
| 3 | 3 | 3 | 1 | 3 | 10−9=1 |
| 4 | 2 | 5 | 2 | 9 | 20−18=2 |
| 6 | 1 | 10 | 5 | 40 | 50−40=10 |

合计 13，与 $10\%1+\dots+10\%10=13$ 一致。经本代码实测输出 13。

**手算示例 3（倍数型，$n=10,k=2$）**：根（不被 2 整除的数）为 $1,3,5,7,9$，链分别为 `1,2,4,8`（长4）、`3,6`（长2）、`5,10`（长2）、`7`（长1）、`9`（长1）。代码逐层输出 `len cnt`：层 1 的 $cnt=10-10+2=2$、层 2 的 $5-4+1=2$、层 3 的 $2-2+0=0$、层 4 的 $1-0+0=1$，即链长 1 有 2 个、链长 2 有 2 个、链长 4 有 1 个，与手数一致；所有 cnt 之和 $5=n-\lfloor n/k\rfloor$（sanity check）。

## 逐行代码解析

代码拆成 4 个模块，按顺序拼接即完整程序。

### 模块 1 头文件与连续型 fn1

```cpp
#include<bits/stdc++.h>
using namespace std;
//求取sum(i = 1 ~ n) floor(n / i);   (连续型分块)
long long fn1(long long n)
{
	/*
	可以发现在求取的过程中有很多重复的数字。并且具有单调性
	假设一个相同值的区间是[L,R];则floor(n / L) == floor(n / R)
	设 k = floor(n / L)。则:  k <= n / R < k + 1 
	所以  k * R <= n < (k + 1) * R
	n / (k + 1) <  R <= n / k ,  R = floor(n / k)
	第一个起点L = 1,下一个不同值的区间为R + 1
	*/
	long long ans = 0;
	for(long long l = 1,r;l <= n;l = r + 1)
	{
		long long k = n / l;
		r = n / k;
		ans += k * (r - l + 1);
	}
	return ans;
}


```

- 注释块完整给出了推导链：段内值恒为 $k=\lfloor n/L\rfloor$，由 $kR\le n<(k+1)R$ 推出 $R=\lfloor n/k\rfloor$，下一段从 $R+1$ 开始。
- `for(long long l = 1, r; l <= n; l = r + 1)`：`l` 从 1 出发、每轮跳到段右端加一，保证全区间 $[1,n]$ 不重不漏。
- `k = n / l`（段内值）、`r = n / k`（段右端）：一次除法确定整段范围，这是 O(√n) 的关键。
- `ans += k * (r - l + 1)`：段内值 × 段长度，一次处理整段。

### 模块 2 余数型 fn2

```cpp
//求取sum(i = 1 ~ n) n % i;    (余数型分块)
long long fn2(long long n)
{
	/*
	sum(i = 1 ~ n) n % i 可以看成  sum(i = 1 ~ n) n - floor(n / i) * i;
	这一部分：sum(i = l ~ r) floor(n / i) * i 的求和可以写成 len * (l + r) / 2 * k;
	后面过程与前面差不多 
	*/
	long long ans = 0;
	for(long long l = 1,r;l <= n;l = r + 1)
	{
		long long k = n / l;
		r = n / k;
		long long len = r - l + 1;
		ans += len * n - len * (l + r) / 2 * k;  
	} 
	return ans;
}


```

- 把 $n\bmod i$ 拆成 $n-i\lfloor n/i\rfloor$：前半段每块贡献 $len\cdot n$，后半段是「等差数列和 × 段内值」。
- `len * (l + r) / 2 * k`：即 $sum_i \cdot k$，其中 $len(l+r)/2$ 是段内 $i$ 之和（连续整数和）。
- 注意此处不能写成 `(n % l) * len`——段内 $n\bmod i$ 随 $i$ 线性变化、不是常数，那样会少算（见陷阱）。
- 本写法的溢出边界：$len\cdot(l+r)$ 先乘，$n\ge10^{12}$ 时可能溢出；更稳的写法是「先除 2 再乘」（$len$ 与 $l+r$ 中恰有一个偶数），属于实现细节，本库不代改代码。

### 模块 3 倍数型 fn3

```cpp
//倍增型分块 不具体题目了，就把每个长度的个数打印一下吧。 
void fn3(long long n,long long k)
{
	/*
	不知道怎么写，给ai了 
	把 1..n 中的数按“根 a 不被 k 整除”分链：
		根 a 的链为 a, a*k, a*k^2, ...
		链长 L(a) = 满足 a*k^t <= n 的最大 t + 1

	设 U_t = floor(n / k^t)，则:  U_0 = n,  U_{t+1} = floor(U_t / k)
	（因为 floor(floor(n/A)/B) = floor(n/(A*B))，取 A=k^t, B=k 即得）

	链长恰好为 t+1 的根 a 满足:
		a*k^t <= n < a*k^{t+1}
	两边除以 k^t:
		a <= n/k^t 且 a > n/k^{t+1}
	对整数 a:
		U_{t+1} < a <= U_t
	所以候选根是连续区间 (U_{t+1}, U_t]

	但根必须 k ? a，要从该区间里排除 k 的倍数:
	区间长度 = U_t - U_{t+1}
	其中 k 的倍数个数 = floor(U_t/k) - floor(U_{t+1}/k)
					= U_{t+1} - U_{t+2}
	（因为 floor(U_t/k) = U_{t+1}，floor(U_{t+1}/k) = U_{t+2}）

	所以链长为 t+1 的根个数:
		cnt = (U_t - U_{t+1}) - (U_{t+1} - U_{t+2})
			= U_t - 2*U_{t+1} + U_{t+2}

	代码变量替换:  U = U_t,  D = U_{t+1},  D/k = U_{t+2}
		cnt = U - 2*D + D/k
	下一层:  U = D,  len++（链长递增）
	层数只有 O(log_k n)，非常快
	注意: k = 1 时 U 不降，会死循环，必须特判
	*/
	
	if (k == 1) 
	{
        cout << "k=1 无意义（所有数都能被1整除，根不存在）\n";
        return;
    }
	
	long long U = n;
	int len = 1;
	while(U > 0)
	{
		long long D = U / k;
		long long cnt = U - 2 * D + D / k;
		
		cout << len << ' ' << cnt << '\n'; 
		
		U = D;
		++len;
	}
}

```

- `if (k == 1)` 必须特判：$k=1$ 时 $D=U/1=U$ 恒不变，循环永不前进（死循环）；语义上所有数都能被 1 整除，「根」不存在。
- `D = U / k` 即 $U_{t+1}=\lfloor U_t/k\rfloor$：由嵌套整除恒等式保证精确，无需考虑余数。
- `cnt = U - 2 * D + D / k` 即二阶差分：整段长度 $U-D$ 减去「其中 $k$ 的倍数个数」$D-D/k$。
- `U = D; ++len`：进入下一层（链长加一），层数只有 $O(\log_k n)$。
- 打印每层「链长 个数」，可加 sanity check：所有 cnt 之和应等于 $n-\lfloor n/k\rfloor$。

### 模块 4 主函数

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	long long n,k;
	cin >> n >> k;
	cout << fn1(n) << '\n';
	cout << fn2(n) << '\n';
	fn3(n,k); 
	return 0;
}
```

- 读入 $n,k$ 后依次输出 fn1、fn2 结果与 fn3 的逐层统计，方便三种模板一起验证。
- `ios::sync_with_stdio(false)` 关闭同步，大输入下显著提速。

## 复杂度分析

- **连续型 / 余数型**：段数 $O(\sqrt n)$（$i\le\sqrt n$ 与 $i>\sqrt n$ 两段论证），每段 $O(1)$，总时间 $O(\sqrt n)$；只用常数个变量，空间 $O(1)$。
- **倍数型**：层数 $O(\log_k n)$（$n=10^{18},k=2$ 也才 60 层），时间 $O(\log_k n)$，空间 $O(1)$。
- **数值量级（溢出红线）**：

| 量 | 量级 | `long long` 安全区 | 需 `__int128` / 取模 |
|---|---|---|---|
| $S(n)=\sum\lfloor n/i\rfloor$ | $\approx n\ln n$ | $n\le10^{12}$（约 $2.8\times10^{13}$） | $n\ge10^{17}$ 接近上限（约 $4\times10^{18}$），$n\ge10^{18}$ 溢出 |
| $T(n)=\sum(n\bmod i)$ | $\approx n^2/2$ | $n\le10^9$（约 $5\times10^{17}$） | $n\ge10^{10}$ |
| fn2 中间量 $len\cdot(l+r)$ | 先乘后除的峰值 | $n\le10^9$（约 $2\times10^{18}$） | $n\ge10^{12}$（先乘必溢出，改先除后乘） |

- 题目要求取模时，直接每段取模即可，无需 `__int128`。
- fn2 的 $len\cdot(l+r)$ 求值顺序是 `((len*(l+r))/2)*v`，大 $n$ 时先乘溢出，见陷阱 5。

## 适用场景

- **$\sum f(\lfloor n/i\rfloor)$ 型**：出现「对整除结果的函数求和」就用连续型，段内贡献换成 $f(v)\cdot len$。
- **$\sum (n\bmod i)$、$\sum i\lfloor n/i\rfloor$ 型**：余数型，段内按等差数列处理。
- **$k$ 的倍数 / 链 / 幂次分层**：「选 $x$ 不能选 $kx$」、按 $k$ 的幂分层计数的题用倍数型；这是「根 + 链」结构的通用模板。
- **双键与反演前置**：$\sum\lfloor n/i\rfloor\lfloor m/i\rfloor$ 右端点取 `min(n/(n/l), m/(m/l))`，是莫比乌斯反演、杜教筛的常见前置。
- **不要用 / 慎用**：$n$ 很小逐项求和更简单；多次不同 $n$ 的询问注意每种 $n$ 单独分块；需要上取整时先转成 $\lceil n/i\rceil=\lfloor(n-1)/i\rfloor+1$ 再套下取整模板。

## 常见陷阱与注意事项

1. **右端点写成 `n/(v+1)`**：正确是 `r = n/v`；`n/(v+1)` 会取到更小的右端，漏掉段尾元素。
2. **忘记 `l = r + 1`**：死循环。每轮必须更新左端点。
3. **`int` 不够用**：`l, r, v, ans` 全部 `long long`；$n\ge10^{18}$ 时答案还要 `__int128`。
4. **余数型段内误当常数（段内 $n\bmod i$ 是 $i$ 的一次函数）**：不能写成

```text
ans += (n % l) * (r - l + 1);   // 错误：段内 n%i 不是常数，用 n%l 乘长度会严重少算
```

也不能写成

```text
ans += len * n - i * v;         // 错误：i 未定义，段内 i 是变量
```

正确做法是段内等差数列求和：$sum_i=(l+r)\cdot len/2$，`ans += len * n - v * sum_i`。

5. **`len*(l+r)/2*v` 先乘溢出**：求值顺序是 `((len*(l+r))/2)*v`，先算 $len\times(l+r)$。$n\le10^9$ 时乘积约 $2\times10^{18}$ 勉强安全，$n\ge10^{12}$ 时约 $2\times10^{24}$ 必溢出。安全写法「先除后乘」（连续整数和里 $len$ 与 $l+r$ 恰有一个偶数）：

```text
if (len & 1) sum_i = len * ((l + r) / 2);  // len 为奇 → l+r 为偶，先除 l+r
else         sum_i = (len / 2) * (l + r);  // len 为偶 → len/2 是整数，先除 len
```
6. **取模除法**：模意义下除以 2 要用 `inv2 = (MOD + 1) / 2`（奇质数模），不能直接 `/2`。
7. **倍数型 `k == 1` 没特判**：$U$ 恒不变、死循环；语义上也没有根，应直接返回特值。
8. **倍数型用浮点**：`D/k` 若转成 `double` 大数会掉精度，必须整数除法；幂次计数用快速幂而不是 `pow`。
9. **倍数型方案数用加法**：求「方案数」时每层 $cnt$ 个根的贡献是乘上 $f(len)^{cnt}$（初值 1），不是加法；只求和时才用加法。
10. **变式里漏了整体量级**：$T(n)\approx n^2/2$ 增长极快，大 $n$ 必须取模或 `__int128`。

**复习检查清单**（写完一段分块代码逐项对照）：

- [ ] `r = n/v`（**不是** `n/(v+1)`）
- [ ] `l = r + 1` 更新，循环条件 `l <= n` 覆盖完整
- [ ] 段内是常数 → 乘长度；段内是线性 → 等差数列求和
- [ ] `sum_i = (l+r)*len/2` 先除后乘防溢出
- [ ] `int` 全改 `long long`
- [ ] 倍数型：`k == 1` 特判
- [ ] 倍数型：求方案数用乘法、初值 1；求总和用加法
- [ ] 幂次用快速幂，不用 `pow`
- [ ] 大 $n$ 时答案用 `__int128` 或取模
- [ ] 倍数型 sanity check：所有 `cnt` 之和等于 $n-\lfloor n/k\rfloor$

## 对比与扩展

**三种分块对比**：

| 维度 | 连续型 fn1 | 余数型 fn2 | 倍数型 fn3 |
|---|---|---|---|
| 分块键 | ⌊n/i⌋ | ⌊n/i⌋ | ⌊n/k^t⌋ |
| 段形状 | [l,r] | [l,r] | (U_{t+1}, U_t] |
| 段内性质 | 值恒定 | i 的一次函数 | 层恒定，需筛 k 倍数 |
| 段推进 | r = n/v，l = r+1 | 同左 | U = U/k |
| 段内处理 | v·len | n·len − v·sum_i | U−2D+D/k（二阶差分） |
| 复杂度 | O(√n) | O(√n) | O(log_k n) |

**一句话对比**：连续型段内是常数、乘长度；余数型段内是一次函数、等差数列；倍数型段内还有筛选、整段减掉排除项即二阶差分。

**识别信号三问**：出现 $\sum f(\lfloor n/i\rfloor)$ → 连续型；出现 $n\bmod i$ 或 $\sum i\lfloor n/i\rfloor$ → 余数型；出现 $k$ 的倍数、链、幂、$k\nmid a$ → 倍数型。

**扩展方向**：

**连续型变式（在基础模板上改一行）**：

- **带函数 $f$**：$\sum_{i=1}^{n}f\!\left(\lfloor n/i\rfloor\right)$ —— 把 `v * (r-l+1)` 换成 `f(v) * (r-l+1)`。
- **双键分块（两个 $n$ 同时）**：$\sum_{i=1}^{\min(n,m)}\lfloor n/i\rfloor\lfloor m/i\rfloor$，右端点取两者最小值：

```text
r = min(n / (n / l), m / (m / l));
```

这是莫比乌斯反演的常见前置。

- **带上界 $[1,R]$（而不是 $[1,n]$）**：

```text
for (long long l = 1, r; l <= R; l = r + 1) {
    long long v = n / l;
    r = min(n / v, R);   // 防止越过 R
    ...
}
```

**余数型变式**：

- 求 $\sum i\lfloor n/i\rfloor$（fn2 的中间量）：只剩 `ans += v * sum_i`，不需要 `n * len` 那一半。
- 带下界 $[L,R]$：`l` 从 L 出发，再加 `r = min(n / v, R)` 防越界。
- **对质数 $p$ 取模**（模意义下不能直接除 2）：

```text
long long inv2 = (MOD + 1) / 2;
long long len = (r - l + 1) % MOD;
long long sum_i = ((l + r) % MOD) * len % MOD * inv2 % MOD;
ans = (ans + n % MOD * len % MOD - v % MOD * sum_i % MOD + MOD) % MOD;
```

**倍数型变式**：

- **求和型**（链数 × 链长总和）：`ans = (ans + cnt * len) % MOD`，初值 0；与方案数型 `ans = ans * fastpow(f[len], cnt, MOD) % MOD`（初值 1）成对记忆。
- **一层一级差分**（约束不带 $k\nmid a$、允许任意起点）：`cnt = U - D`。口诀：约束里只有一个条件 → 一阶；还嵌一个排除条件 → 二阶。
- **更一般的「$k$ 的幂分层」**：任何形如 $\lfloor n/k^t\rfloor$ 的分层都能套这个模板，不限于「根 + 链」场景。
- **$k=1$ 的语义**：任何数都能被 1 整除，「根」不存在，直接返回特值（方案数题中答案为空集的 1）。

**更高阶的组合**：

- **上取整分块**：$\lceil n/i\rceil=\lfloor(n-1)/i\rfloor+1$，转成下取整后套连续型模板。
- **二次分块**：外层枚举 $\lfloor n/i\rfloor$，内层再分块算 $\sum i$、$\sum i^2$ 等，常见于高次求和。
- **莫比乌斯反演 + 分块**：预处理 $\mu$ 的前缀和 $M(i)=\sum_{j\le i}\mu(j)$，段内贡献 $(M(r)-M(l-1))\cdot\lfloor n/l\rfloor\cdot\lfloor m/l\rfloor$。
- **杜教筛 + 分块**：当 $\sum f(i)$ 无法直接预处理时，用杜教筛求前缀和，外层继续分块，复杂度 $O(n^{2/3})$。$AKB277$, '数学', array['数学', '整除分块', '数论分块', '根号复杂度', '余数求和'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-bsgs--xesir', 'BSGS 大步小步算法 · Xesir', $AKB278$## 算法原理

大步小步算法（Baby-Step Giant-Step，BSGS）用于解决高次同余方程问题，典型的分块思想运用，复杂度 $O(\sqrt p)$。

**问题：** 给定整数 $a,b,p$ 且 $a \perp p$，求使 $a^x \equiv b \pmod p$ 的最小非负整数 $x$。

**思路：** 暴力枚举是绝对不可行的，我们考虑压缩搜索空间。

由扩展欧拉定理 $a^x \equiv a^{x \mod \varphi(p)} \pmod p$ 可以得到 $a^x$ 在模 $p$ 意义下的最小循环节为 $\varphi(p)$。而 $\varphi(p)$ 的最大值是 $p-1$，故我们只需要在 $[0,p]$ 中判断即可。

显然暴力判断 $[0,p]$ 的复杂度是 $O(p)$ 也不够优，对于 $p \le 10^9$ 数据我们需要更优的解法。这时候我们要用到分块思想。令 $m=\lfloor \sqrt p \rfloor$，设 $x=im-j$，其中 $1 \le i \le m,0 \le j \le m-1$。

则有 $a^{im-j} \equiv b \pmod p$，即 $(a^m)^i \equiv ba^j \pmod p$。于是转换为最小化 $i$ 下最大化 $j$。

- 先枚举 $j$（Baby Step），将 $\{ba^j, j\}$ 作为键值对存入哈希表中，重复时取更大的。
- 后枚举 $i$（Giant Step），查找哈希表中键为 $a^{mi}$ 的元素，第一次找到即为最小值。

枚举 $j$ 和 $i$ 的复杂度都是 $O(\sqrt p)$，故总体复杂度也是 $O(\sqrt p)$，可以接受。

## 核心公式

| 内容 | 公式 |
|---|---|
| 原方程 | $a^x \equiv b \pmod p$ |
| 循环节 | 最小循环节为 $\varphi(p)$，答案只需在 $[0,p]$ 内找 |
| 设块长 | $m = \lceil \sqrt p \rceil$，$x = im - j$ |
| 变形 | $(a^m)^i \equiv b a^j \pmod p$ |
| 枚举范围 | $1 \le i \le m$，$0 \le j \le m-1$ |

## 逐行代码解析

### 模块一：预处理与边界

```cpp
int bsgs(int a,int b,int p){
    h.clear();
    if(__gcd(a,p)!=1) return -1;
	a%=p,b%=p;
	if(b==1) return 0;
```

- `h.clear()`：哈希表是全局或外部维护的，每次调用前必须清空，否则上一组的 $\{ba^j, j\}$ 会污染答案。
- `__gcd(a,p) != 1` 直接返回 `-1`：BSGS 要求 $a \perp p$，不互质时逆元/循环节性质都不成立。
- `a %= p, b %= p` 先把底数和目标压回模范围内。
- `b == 1` 时 $x = 0$ 就是最小非负解，直接返回，省掉后面的枚举。

### 模块二：Baby Step，把 $ba^j$ 存表

```cpp
	int m=ceil(sqrt(p)),t=b,k=ksm(a,m,p);
	h[b]=0;
	for(int j=1;j<m;j++){
		t=t*a%p;h[t]=j;
	}
```

- `m = ceil(sqrt(p))` 是块长，`k = a^m mod p` 后面 Giant Step 要用。
- `h[b] = 0` 对应 $j=0$：$ba^0 = b$。
- 循环从 $j=1$ 到 $m-1$，每次 `t = t * a % p` 递推得到 $b a^j$，把下标 `j` 存进哈希表。
- 题目要求“最小化 $i$ 下最大化 $j$”，所以同一个键后写入的更大 $j$ 会覆盖先前的值（代码里是直接赋值）。

### 模块三：Giant Step，查表得答案

```cpp
	t=1;
	for(int i=1;i<=m;i++){
		t=t*k%p;
		if(h.count(t)) return i*m-h[t];
	}
	return -1;
}
```

- `t` 从 $1$ 开始，每轮乘一次 $a^m$，第 $i$ 轮就是 $(a^m)^i$。
- 一旦哈希表里存在这个键，说明 $(a^m)^i \equiv b a^j$，返回 $x = im - j$。
- 从 $i=1$ 开始从小到大枚举，第一次命中就是最小的 $i$；同一 $i$ 下存的是最大的 $j$，对应最小的 $x$。
- 全部枚举完还没命中，说明在 $[0,p]$ 内无解，返回 `-1`。

## 复杂度分析

- 时间复杂度：Baby Step 枚举 $O(\sqrt p)$ 次，Giant Step 枚举 $O(\sqrt p)$ 次，哈希表单次期望 $O(1)$，总计 $O(\sqrt p)$。
- 空间复杂度：哈希表最多存 $O(\sqrt p)$ 个键值对。
- 原文口径就是 $O(\sqrt p)$，适用于 $p \le 10^9$ 的数据。

## 适用场景

- 求解 $a^x \equiv b \pmod p$ 的最小非负整数解（离散对数）。
- 模数 $p$ 是质数、且 $a$ 与 $p$ 互质时最标准；不互质时这套写法直接返回 `-1`，需要 exBSGS 另做处理。
- 需要枚举“指数型”状态、但指数范围达到 $10^9$ 级别的计数/判定问题。
- 与哈希表结合，是“空间换时间”的典型分块模型。

## 常见陷阱

1. **忘记清空哈希表**：多组数据时上一组的残留会让答案直接错掉。
2. **没有判断 $\gcd(a,p)=1$**：不互质时方程可能仍有解，但本实现会误报无解。
3. **`b == 1` 的特判漏掉**：$x=0$ 是合法解，漏判会在某些数据上返回 `-1` 或错误值。
4. **块长取整方式**：`ceil(sqrt(p))` 与 `floor(sqrt(p))` 都能过，但枚举范围要与块长配套，混用容易漏掉边界。
5. **哈希表覆盖顺序**：要求同一键保留更大的 $j$，如果先存大 $j$ 再被小 $j$ 覆盖，答案就不是最小的 $x$。
6. **返回值可能超过 $p$**：$im-j$ 的理论范围要自己核对，必要时对 $\varphi(p)$ 取最小表示。
7. **`int` 溢出**：`t * a`、`t * k` 在 $p$ 接近 $10^9$ 时会爆 `int`，应转 `long long`。

---
> BSGS 的本质就是“把 $x$ 拆成 $im-j$，一半存表、一半查表”。想清楚为什么这么拆能把 $O(p)$ 压到 $O(\sqrt p)$，比背代码有用得多。$AKB278$, '数学', array['数学', '数论', 'BSGS', '离散对数', '高次同余方程', '分块', '哈希表'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-cartesian-plane--xesir', '平面直角坐标系 · Xesir', $AKB279$## 算法原理

这个大家应该很熟悉了：两条互相垂直的数轴（$x$ 轴和 $y$ 轴）交于原点，平面上任意一点都可以用 $(x, y)$ 唯一表示。

在 OI 中，坐标系主要出现在：

- **计算几何**：点、线、多边形、距离、面积等。
- **曼哈顿距离**：$|x_1 - x_2| + |y_1 - y_2|$。
- **欧几里得距离**：$\sqrt{(x_1 - x_2)^2 + (y_1 - y_2)^2}$。
- **向量的叉积与点积**：判断方向、计算面积。

虽然计算几何在 OI 中算是一个独立的板块，但坐标系本身是基础中的基础。很多看起来跟几何无关的题（比如把 $(i, j)$ 当成点的 DP、把状态画成网格的搜索），本质上也都是在坐标系上做文章。

> ~~什么？你没学过坐标系？不会吧不会吧~~

## 核心公式 / 状态定义与转移方程

**两种距离**：

$$
d_{\text{曼哈顿}} = |x_1 - x_2| + |y_1 - y_2|
$$

$$
d_{\text{欧氏}} = \sqrt{(x_1 - x_2)^2 + (y_1 - y_2)^2}
$$

**点积**（判断夹角、投影）：

$$
\vec a \cdot \vec b = x_1 x_2 + y_1 y_2 = |\vec a|\,|\vec b|\cos\theta
$$

**叉积**（判断左右、求面积）：

$$
\vec a \times \vec b = x_1 y_2 - x_2 y_1
$$

叉积的符号直接给出方向关系：大于 0 说明 $\vec b$ 在 $\vec a$ 的逆时针一侧，小于 0 在顺时针一侧，等于 0 说明共线。三点 $A, B, C$ 构成的三角形面积则是

$$
S = \frac{|\overrightarrow{AB} \times \overrightarrow{AC}|}{2}
$$

## 逐行代码解析

### 模块一：两点距离

```cpp
double dis(int x1,int y1,int x2,int y2){
    return hypot(x1 - x2, y1 - y2);   // 欧几里得距离，等价于 sqrt(dx*dx + dy*dy)
}
int manhattan(int x1,int y1,int x2,int y2){
    return abs(x1 - x2) + abs(y1 - y2);  // 曼哈顿距离
}
```

- `hypot` 会先做溢出保护再开方，比手写 `sqrt(dx*dx + dy*dy)` 稳，代价是慢一点。
- 曼哈顿距离全程是整数运算，没有精度问题，能用它的时候尽量用。
- 端点顺序无所谓，`dx`、`dy` 取绝对值或平方后符号都消失了。

### 模块二：叉积判方向

```cpp
long long cross(int x1,int y1,int x2,int y2){
    return 1LL * x1 * y2 - 1LL * y1 * x2;
}
// cross(B.x - A.x, B.y - A.y, C.x - A.x, C.y - A.y) > 0  →  C 在 AB 左侧
```

- 两个坐标相乘可能到 $10^{18}$，所以要 `1LL *` 提升成 `long long`，不要用 `int` 硬算。
- 只用符号时也可以只取符号而不算具体值，但一般直接算更省事。
- 判断"共线"必须写 `== 0`，浮点坐标不能这么干（得用 eps）。

## 复杂度分析

单次距离/点积/叉积都是常数次加减乘，$O(1)$ 时间、$O(1)$ 空间。

需要留意的是**整体**复杂度：$n$ 个点两两求距离是 $O(n^2)$，这才是这类题真正的瓶颈。坐标系本身不带来任何额外开销，它只是一个描述工具。

## 适用场景

- **计算几何**：凸包、旋转卡壳、半平面交，全部建立在叉积之上。
- **网格图上的 DP / 搜索**：把格子坐标当点，转移就是向量加法。
- **曼哈顿距离最优化**：$\max |x_i - x_j| + |y_i - y_j|$ 这类问题可以拆绝对值转成 $4$ 种线性式，或用旋转 $45^\circ$ 转成切比雪夫距离。
- **判断点与直线/多边形的位置关系**：叉积符号一发入魂。
- **向量旋转**：用复数或旋转矩阵，本质还是坐标变换。

## 常见陷阱与注意事项

1. **整数叉积溢出**：坐标到 $10^9$ 时，$x_1y_2$ 就已经是 $10^{18}$，必须 `long long`（甚至 `__int128`）。
2. **浮点比较不要用 `==`**：`double` 算出来的距离、叉积几乎不可能"恰好相等"，判等一律 `fabs(a - b) < eps`。
3. **曼哈顿距离不是欧氏距离**：圆在曼哈顿距离下是菱形，在欧氏距离下才是圆。题目说"距离"时先确认是哪种。
4. **开方丢精度**：比较距离大小时优先比**平方**，既避免开方误差又快。
5. **`abs` 用错重载**：`abs` 对 `int` 返回 `int`，对浮点要 `fabs`（或 `std::abs` 的浮点重载）。对 `long long` 用 `abs` 时注意别被隐式转成 `int`。
6. **坐标系原点与下标**：题目里的 $(i, j)$ 常常从 1 开始，代码里从 0 开始，算距离时要统一。$AKB279$, '数学', array['数学', '坐标系', '计算几何', '向量', '距离'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-catalan--stripe-python', 'Catalan 数 · stripe-python', $AKB280$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 13. Catalan 数

**Catalan 数**的起源是凸多边形三角剖分问题，即对于一个凸 $n$ 边形，有多少种方式可以用不相交的对角线将其划分为若干个三角形。这里将方案数记作 $H_n$。Catalan 数列为： $1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862\cdots$，参见 [A000108](https://oeis.org/A000108)。

## 13.1 解决问题

**这里写的不太清楚，笔者认为 [OI-Wiki](https://oi-wiki.org/math/combinatorics/catalan/#%E5%BA%94%E7%94%A8) 上写的非常好，推荐学习。**

1. 括号序列计数

Q: 计算 $n$ **对**括号能形成多少种合法括号序列。

A: 方案数为 $H_n$。因为序列的第一个括号必须为 `(`，设之后有一个长度为 $m$ 的子序列，然后为 `)`，再然后是另一个子序列，长度为 $n-m-1$，则方案为 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$，这就是 Catalan 的递推式。

1. 不同构二叉树计数

Q: 计算 $n$ 个节点的不同构二叉树数目。

A: 数目为 $H_n$。设根节点左子树大小为 $m$，则右子树大小为 $n-m-1$，左右子树又是一个子问题，所以方案为 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$，符合递推式。

1. 三角剖分问题

Q: 求对于一个凸 $n+2$ 边形，有多少种方式可以用不相交的对角线将其划分为若干个三角形。

A: 方案数为 $H_n$。固定多边形的一条边并选择一个与它不共线的初始顶点构成一个三角形，这个三角形将原多边形分为两个小多边形，大小分别为 $m$ 和 $n-m-1$，所以方案还是那个 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$。

1. 不越过对角线的网格路径

Q: 在 $n \times n$ 网格中，从 $(0,0)$ 走到 $(n,n)$ 且只能向右或向上移动，求不越过对角线 $y=x$ 的路径数，如图所示。

![](https://cdn.luogu.com.cn/upload/image_hosting/0ztrlo61.png)

A: 路径数为 $H_n$。如果你不考虑限制，就是在总共 $2n$ 步中分出 $n$ 步走上或者右，方案数为 $C_{2n}^{n}$。用减法原理，算不合法的方案，对于任意一条接触了 $y=x$ 的路径，将其**最后**离开这条线的点到 $(0,0)$ 之间作一个对称，则不合法路径的终点变为 $(n-1,n+1)$。可以证明这样变换是一一对应的。选出 $n-1$ 步走右，方案数 $C_{2n}^{n-1}$，因此答案为 $C_{2n}^n-C_{2n}^{n-1}$。这是 Catalan 数的通项公式。

1. 出栈序列计数

Q: 入栈序列为一个 $1$ 到 $n$ 的排列，求合法出栈序列数目。

A: 数目为 $H_n$。设第一个入栈元素在第 $m$ 个出栈，则前面 $m-1$ 个必须在之前出入栈，而之后又 $n-m-1$ 种，递推式又双叒叕是 $H_n=\sum_{m=0}^{n-1} H_i H_{n-m-1}$。

由此可见，能用 Catalan 数解决的问题都满足一个递归分解结构：**一个大小为 $n$ 的问题可以分解为两个独立子问题，规模分别为 $m$ 与 $n-m-1$，且两子问题分步**，也就是用乘法原理组合。

## 13.2 计算公式

上面已经给出了一个递推式：

$H_n=\sum_{i=0}^{n-1} H_{i} H_{n-i-1}$但是这玩意是 $O(n^2)$ 的。我们有 $O(n)$ 的递推式：

$H_n=\dfrac{4n-2}{n+1} H_{n-1}$根据问题 4 可知通项公式：

$H_n=\dfrac{C_{2n}^n}{n+1}=C_{2n}^n-C_{2n}^{n-1}$使用递推式可以在 $O(n)$ 复杂度内预处理 $H_i$。而使用通项公式再用 lucas / exLucas 等科技则可以获得更低的复杂度。

## 13.3 例题

### P1044 [NOIP 2003 普及组] 栈

就是问题 5。用递推式 2 计算即可。

```cpp
long long n, h[20];

void _main() {
	cin >> n;
	h[0] = 1;
	for (int i = 1; i <= n; i++) h[i] = h[i - 1] * (4 * i - 2) / (i + 1);
	cout << h[n];
}
```

### P1375 小猫

圆内不相交弦计数。将 $2n$ 个点按顺时针编号，一条弦连接的两点视为左括号和右括号，转化为括号序列计数。所以方案数还是 Catalan 数。代码和上题的区别就是加个取模。

双倍经验：[P1976](https://www.luogu.com.cn/problem/P1976)。

### P10413 [蓝桥杯 2023 国 A] 圆上的连线

这题可以不连线，所以先从 $2023$ 个点选 $n$ 个设为必须连边，这一步方案为 $C_{2023}^n$。

然后这个问题就是上一题，答案为 $H_{n/2}$。由乘法原理可得答案，注意 $n$ 是偶数。

$\sum_{n=0}^{2023} C_{2023}^{n} H_{n/2}, n \in \{x | x=2k,k \in \mathbb{\N} \}$考虑到 $2023$ 不是质数，你应该对组合数和 Catalan 数都用递推来求解。答案是 $104$。

### P1754 球迷购票问题

先审题，当 A 买票后，售票处得到一个 $50$ 元；当 B 买票后，售票处失去一个 $50$ 元，所以 A, B 是一个二元对应关系。建立括号模型，将 A 当作左括号，B 当作右括号，发现合法的排队序列就是括号匹配序列，这是问题 1，还是写 Catalan 数即可。

### P2532 [AHOI2012] 树屋阶梯

把这题放 Catalan 数例题说明了一切。

用 $f_i$ 表示高度为 $i$ 的阶梯的搭建方案数，显然 $f_0=f_1=1$。借用一下第一篇题解的图：

![image.png](https://i.loli.net/2020/02/02/2xksBinHCIXUWrg.png)

枚举每个顶到拐角的矩形，比如这里的第一个矩形，那么右侧方案是 $f_4$。

![image.png](https://i.loli.net/2020/02/02/RJmZdy1kc5qTEbF.png)

再看这个矩形，上侧为 $f_1$，右侧为 $f_3$。

![image.png](https://i.loli.net/2020/02/02/KXQ4GyxiBv1cOwz.png)

类似地，上侧为 $f_2$，右侧为 $f_2$。同理可得另外的情况，因此

$f_n=\sum_{i=0}^{n-1} f_{i} f_{n-i-1}$这满足“一个大小为 $n$ 的问题可以分解为两个独立子问题，规模分别为 $m$ 与 $n-m-1$，且两子问题分步”的条件，所以所求就是 Catalan 数。然后你整个高精度即可，代码不放了。

### *P3978 [TJOI2015] 概率论

不会期望移步下文 18.3。

首先由问题 2 可得不同构二叉树有 $H_n$ 棵。然后设 $f_n$ 表示所有二叉树的叶子节点数目之和。

注意到，$f_n=nH_{n-1}$。

简证：对于一棵 $n$ 个节点的二叉树，若存在 $k$ 个叶子节点，将 $k$ 个叶子依次删去，可构造得 $k$ 棵 $n-1$ 个点的二叉树，并且这些二叉树还有 $n$ 个点可以挂叶子，因此 $f_n =\sum k H_{n-1}=nH_{n-1}$。

然后期望为 $E(X)=\dfrac{f_n}{H_n}$，代入通项公式 $H_n=\dfrac{C_{2n}^n}{n+1}$ 消去可得 $E(X)=\dfrac{n(n+1)}{2(2n-1)}$。于是这道紫题就做完了。

### *P7118 Galgame

根据问题 2，节点数小于 $n$ 的二叉树数目为

$\sum_{i=1}^{n-1} H_i$重点是算节点数相同的二叉树。根据先左再右的比较方式，设左儿子大小为 $s$，左右儿子总大小为 $n$，和问题 2 相同的推导方法可得方案数是

$\sum_{i=0}^{s-1} H_{i} H_{n-i-1}$预处理 Catalan 数，在 dfs 过程中记录乘子，如果走了左链，右子树就不用管了可以任意选，因此由乘法原理将乘子乘上右子树大小，具体细节看代码。

```cpp
const int N = 2e6 + 5;
int n, ls[N], rs[N], sz[N];
mint h[N];

void dfs1(int u) {
	if (!u) return;
	dfs1(ls[u]), dfs1(rs[u]), sz[u] = sz[ls[u]] + sz[rs[u]] + 1;
} mint dfs2(int u, mint x) {
	if (!u) return 0;
	mint res = 0;
	for (int i = 0; i < sz[ls[u]]; i++) res += x * h[i] * h[sz[u] - i - 1];
	res += dfs2(ls[u], x * h[sz[rs[u]]]);
	res += dfs2(rs[u], x);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> ls[i] >> rs[i];
	h[0] = 1;
	for (int i = 1; i <= (n << 1); i++) h[i] = h[i - 1] * (4 * i - 2) / (i + 1);
	mint res = 0;
	for (int i = 1; i < n; i++) res += h[i];
	dfs1(1), res += dfs2(1, 1);
	cout << res;
}
```

喜提 [30pts](https://www.luogu.com.cn/record/227987799) 大黑大紫。因为这样做是 $O(n^2)$ 的，会被左偏形态的树卡满。

考虑当左子树大小大于右子树时，用右子树大小代替左子树大小计算。用减法原理，用总方案数减去不小于原树的二叉树。记右子树大小为 $s$，同理可得答案

$H_n-\sum_{i=0}^{s} H_{i}H_{n-i-1}$然后你神奇地发现这变成了启发式合并，复杂度是 $O(n \log n)$ 的。然后你把 `dfs2` 改成这样即可：

```cpp
mint dfs2(int u, mint x) {
	if (!u) return 0;
	mint res = 0;
	if (sz[ls[u]] <= sz[rs[u]]) {
		for (int i = 0; i < sz[ls[u]]; i++) res += x * h[i] * h[sz[u] - i - 1];
	} else {
		res += x * h[sz[u]];
		for (int i = 0; i <= sz[rs[u]]; i++) res -= x * h[i] * h[sz[u] - i - 1];
	}
	res += dfs2(ls[u], x * h[sz[rs[u]]]);
	res += dfs2(rs[u], x);
	return res;
}
```

## 附：计数基础·卡特兰数（stripe-python）

## 5. 卡特兰数

**卡特兰数** $C_n$ 由下面的递推关系定义：
$$
C_n=\sum_{i=0}^{n-1} C_iC_{n-1-i}
$$
观察递推式的组合意义：枚举分界点 $i$ 后，问题可以转化到规模为 $i$ 和 $n-1-i$ 个两个子问题，且两个子问题独立。

### 5.1 应用

下面，我们来介绍一些 Catalan 数的应用场景。

#### 5.1.1 括号序列计数

**问题一** 计数 $n$ **对**括号能形成多少个合法括号串。

::::::success[题解]

分析：考虑一个合法括号串形如 $\tt{(}A\tt{)}B$，其中 $A,B$ 为合法括号串。枚举 $|A|=i$，则 $|B|=n-1-i$。

而构造 $A,B$ 恰为规模为 $i$ 和 $n-1-i$ 的子问题，符合 Catalan 数定义式的组合意义。答案为 $C_n$。

::::::

**问题二** 现有 $k$ 种不同的括号，计数 $n$ **对**括号能形成多少个合法括号串。

::::::success[题解]

考虑先构造一个合法括号串，再确定 $n$ 对括号分别为哪种。乘法原理得答案 $C_n k^n$。

::::::

另外，出栈序列计数 / 圆内不交弦计数都能转化为括号序计数，本节不作介绍。

#### 5.1.2 无标号二叉树计数

**问题** 计算 $n$ 个节点的无标号二叉树数目。

::::::success[解法一]

对于根节点，枚举其左子树大小 $i$，则右子树的大小为 $n-1-i$，构造左右子树的方案数独立。这对应了 Catalan 数的组合意义，答案为 $C_n$。

::::::

::::::success[解法二]

无标号二叉树的形态和其括号序形成了双射，问题转化为合法括号序计数，答案为 $C_n$。

::::::

#### 5.1.3 格路计数

**问题** 你初始位于 $(0,0)$，需要走到 $(n,n)$，每一步只能向右或向上走，且不能越过 $y=x$，求方案数。

::::::success[解法一]

考虑减法原理。总路径数为 $\dbinom{2n}{n}$，只需计算不合法路径数。

刻画不合法路径的形态。分析知，一条不合法路径必然碰到了 $y=x+1$。找出路径与 $y=x+1$ 第一次相交的位置，并将之后的路径沿 $y=x+1$ 作对称。

![](https://cdn.luogu.com.cn/upload/image_hosting/fecer0hv.png)

上图为 OI-Wiki 中的原理图，侵删。

在反射操作后，一条不合法路径的终点变为 $(n-1,n+1)$，且不合法路径与这样的格路建立了双射，数目为 $\dbinom{2n}{n+1}$。因此答案为
$$
\binom{2n}{n}-\binom{2n}{n+1}
$$
::::::

::::::success[解法二]

将向右视为左括号，向上视为右括号，则一条合法格路和一个合法括号序列建立了双射，答案为 $C_n$。

::::::

#### 5.1.4 三角剖分计数

**问题** 求凸 $n+2$ 边形三角剖分的方案数。

:::::success[题解]

钦定一条边 $(1,n+2)$ 作为基边，记这条边所在的三角形的第三个顶点标号为 $k$，原问题被拆分为以下部分：

- 三角形 $1 \to n+2 \to k \to 1$。
- 顶点 $1 \sim k$ 形成的 $k$ 边形。
- 顶点 $k \sim n+2$ 形成的 $n+3-k$ 边形。

两个子问题独立，可以单独计数。偏移两个下标即对应了 Catalan 数定义式的组合意义，故答案为 $C_n$。

:::::

### 5.2 计算公式

在上文中，我们已经给出了一些 Catalan 数的计算公式。下面再总结和补充一些：

- 定义式：$C_n=\sum \limits_{i=0}^n C_i C_{n-1-i}$。
- 递推式：$C_n=\dfrac{4n-2}{n+1} C_{n-1}$。
- 通项 1：$C_n=\dfrac{1}{n+1} \dbinom{2n}{n}=\dfrac{(2n)!}{n!(n+1)!}$。
- 通项 2：$C_n=\dbinom{2n}{n}-\dbinom{2n}{n+1}$。

通项 2 由 13.1.3 的解法一给出。下面通过代数推导，证明后三个式子等价。

:::::success[代数推导]

对通项 2 进行变形
$$
\begin{aligned}
C_n&=\dbinom{2n}{n}-\dbinom{2n}{n+1}\\
&=\dfrac{(2n)!}{(n!)^2}-\dfrac{(2n)!}{(n-1)!(n+1)!}\\
&= \dfrac{(2n)!}{(n!)^2} \left(1-\dfrac{n!}{(n-1)!(n+1)}\right)\\
&= \dfrac{(2n)!}{(n!)^2}\left(1-\dfrac{n}{n+1}\right)\\
&= \dfrac{(2n)!}{(n!)^2} \times \dfrac{1}{n+1}\\
&= \dfrac{(2n)!}{n!(n+1)!}
\end{aligned}
$$
所有变形都是等价变形，故通项 1 与通项 2 等价。

将通项 1 代入递推式
$$
\begin{aligned}
C_n&=\dfrac{4n-2}{n+1} C_{n-1}\\
\iff \dfrac{(2n)!}{n!(n+1)!} &= \dfrac{4n-2}{n+1} \times \dfrac{(2n-2)!}{(n-1)!n!}\\
\iff \dfrac{2n(2n-1)(2n-2)!}{(n-1)!(n+1)!n} &=  \dfrac{2(2n-1)(2n-2)!}{(n-1)!n!(n+1)}\\
\iff \dfrac{2(2n-1)(2n-2)!}{(n-1)!(n+1)!} &= \dfrac{2(2n-1)(2n-2)!}{(n-1)! (n+1)!}
\end{aligned}
$$
显然成立。因此通项 1 可以得到递推式，证毕。

:::::

下面，我们用定义式来推导 Catalan 数的 OGF，即由纯代数推导证明通项 1 是定义式的解。

:::::success[代数推导]

记 Catalan 数的 OGF 为 $F$，则
$$
\begin{aligned}
F(x)&=\sum_{n \ge 0} C_nx^n\\
&= 1+\sum_{n \ge 1} x^n \sum_{i=0}^{n-1} C_iC_{n-1-i}\\
&= 1+\sum_{n \ge 1} x \sum_{i=0}^{n-1} C_i x^i C_{n-1-i} x^{n-1-i}\\
&= 1+x\sum_{i \ge 0} C_i x^i \sum_{j \ge 0} C^j x^j\\
&= 1+xF^2(x)
\end{aligned}
$$
因此 $F=1+xF^2$，解得 $F=\dfrac{1 \pm \sqrt{1-4x}}{2x}$。

由 $F(0)=1$ 作取舍后得到 $F$ 的封闭形式
$$
F(x)=\dfrac{1-\sqrt{1-4x}}{2x}
$$
由广义二项式定理展开得
$$
\begin{aligned}
(1-4x)^{1/2} &= \sum_{n \ge 0} \binom{1/2}{n} (-4x)^n\\
&= \sum_{n \ge 0} (-1)^n 4^n\dfrac{(1/2)^{\underline n}}{n!} x^n\\
&= \sum_{n \ge 0} \dfrac{(-1)^n 4^n}{n!} x^n\prod_{k=0}^{n-1} \left(\dfrac{1}{2}-k\right) \\
&= \sum_{n \ge 0} \dfrac{(-1)^n 4^n}{n!} x^n\times \dfrac{(-1)^{n-1}}{2^n}(2n-3)!!\\
&= \sum_{n \ge 0} \dfrac{(-1)^{2n-1} 2^n (2n-3)!!}{n!}x^n\\
&= 1-\sum_{n \ge 1}\dfrac{2^n(2n-3)!!}{n!}x^n \\
&=1 - \sum_{n \ge 1} \dfrac{2^n (2n-3)!! (2n-2)!!}{n!(2n-2)!!}x^n\\
&= 1 -\sum_{n \ge 1} \dfrac{2(2n-2)!}{n!(n-1)!}x^n\\
&= 1-\sum_{n\ge 1} \dfrac{2}{n} \binom{2n-2}{n-1}x^n\\
F(x)&= \dfrac{1}{2x} \sum_{n\ge 1} \dfrac{2}{n} \binom{2n-2}{n-1}x^n\\
&=\sum_{n\ge 1} \dfrac{1}{n} \binom{2n-2}{n-1}x^{n-1}\\
&= \sum_{n \ge 0} \dfrac{1}{n+1} \binom{2n}{n} x^n\\
C_n= [x^n]F&=\dfrac{1}{n+1} \binom{2n}{n}
\end{aligned}
$$
证毕。

:::::

### 5.3 格路计数模型

在 OI 中，特定括号序列计数、前缀和序列计数等问题都可以转化为格路计数问题。在练习中，我们会看到具体的转化方法。

**反射容斥**是解决**格路计数**问题的核心方法。由于笔者不会反射容斥代数化，本节只讲述组合意义的解法。

另外格路计数还有一些技巧，比如旋转坐标系，为区域赋权等方法。这部分请读者结合练习题来学习。

问题一：你初始位于 $(0,0)$，需要走到 $(n,m)$，每一步只能向右或向上走，求方案数。

:::::success[题解]

一共需要走 $n+m$ 步，选出 $n$ 步向右即可，方案数 $\dbinom{n+m}{n}$。

:::::

问题二：你初始位于 $(0,0)$，需要走到 $(n,m)$，每一步只能向右或向上走，且不能越过 $y=x+b$，求方案数。

:::::success[题解]

使用 13.1.3 的手法，考虑减法原理。总方案数 $\dbinom{n+m}{n}$，故只需求出不合法路径数目。

 一条不合法路径必然碰到了 $y=x+b+1$。我们找到这条路径与 $y=x+b+1$ 的第一个交点，并将之后的路径关于 $y=x+b+1$ 对称。此时不合法路径的终点变为 $(m-n+1,n+b+1)$。

可以证明，不合法路径与终点为 $(m-n+1,n+b+1)$ 的无限制格路存在双射关系。因此原问题的答案为
$$
\binom{n+m}{n}-\binom{n+m}{m-b-1}
$$
:::::

问题三：你初始位于 $(0,0)$，需要走到 $(n,m)$，每一步只能向右或向上走，且不能越过 $y=x+b_1$ 和 $y=x+b_2$，保证 $b_1<b_2$，求方案数。

::::::success[题解]

咕咕咕。

::::::$AKB280$, '数学', array['Catalan', '卡特兰数', '格路计数'], 'col-math-combinatorics', null, 'knowledge'),
('Fohen', 'col-math-combinatorics--fenfeng', '组合数学 · Fohen', $AKB281$## 算法原理

组合数学是研究「计数」的学科：在给定规则下，计算满足条件的安排方式共有多少种。它不是简单地从 $1$ 数到 $n$，而是借助公式与递推，把「数数」变成可计算的结构。

组合数学的两条「公理」是：

**加法原理（分类用加法）**：做一件事有 $n$ 类方法，第 $i$ 类方法有 $a_i$ 种做法，且各类方法互不重叠，则总方法数为

$$
a_1 + a_2 + \cdots + a_n
$$

**乘法原理（分步用乘法）**：做一件事需要 $n$ 个步骤，第 $i$ 个步骤有 $a_i$ 种做法，则总方法数为

$$
a_1 \times a_2 \times \cdots \times a_n
$$

几乎所有计数问题都可以拆解成这两个原理的组合。例如「3 件上衣 × 2 条裤子」是乘法原理的直接应用；而「从 10 人里选 3 人组队（不计顺序）」对应组合、「选 3 人分别担任不同职务（计顺序）」对应排列，两者只差一个「顺序是否计入」。

在这两条公理之上，衍生出排列、组合、二项式定理、容斥原理、隔板法、斯特林数、卡特兰数等一系列模型，是 OI 中计数类问题的基石。

## 核心公式

### 排列

从 $n$ 个不同元素中选出 $k$ 个**按顺序**排成一列：

$$
A_n^k = \frac{n!}{(n-k)!}
$$

第一个位置有 $n$ 种选法，第二个有 $n-1$ 种，……第 $k$ 个有 $n-k+1$ 种。特别地，$k=n$ 时 $A_n^n = n!$，即全排列数。

### 组合

从 $n$ 个不同元素中选出 $k$ 个**不考虑顺序**：

$$
C_n^k = \binom{n}{k} = \frac{n!}{k!(n-k)!}
$$

排列数再除以 $k!$，因为选出的 $k$ 个元素有 $k!$ 种顺序，在组合中都算同一种。

- 对称性：$\dbinom{n}{k} = \dbinom{n}{n-k}$
- 边界：$\dbinom{n}{0} = \dbinom{n}{n} = 1$，$\dbinom{n}{1} = n$

### 二项式定理

$$
(a+b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k} b^k
$$

- 取 $a=b=1$：$\sum_{k=0}^{n}\binom{n}{k} = 2^n$，即 $n$ 个元素的所有子集数量，状压 DP 中天天用。
- 取 $a=1,\ b=-1$：$\sum_{k=0}^{n}(-1)^k\binom{n}{k} = 0$，即交错和性质，在容斥原理中频繁出现。

### 常见组合恒等式

1. **转换式**：$\dbinom{n}{k} = \dbinom{n}{n-k}$（当 $k$ 接近 $n$ 时转为较小值）
2. **帕斯卡恒等式（递推）**：$\dbinom{n}{k} = \dbinom{n-1}{k-1} + \dbinom{n-1}{k}$（杨辉三角，也是组合数 DP 的基础）
3. **吸收恒等式**：$k\dbinom{n}{k} = n\dbinom{n-1}{k-1}$
4. **范德蒙德卷积**：$\sum_{k=0}^{r}\dbinom{n}{k}\dbinom{m}{r-k} = \dbinom{n+m}{r}$
5. **上指标求和**：$\sum_{k=0}^{n}\dbinom{k}{m} = \dbinom{n+1}{m+1}$

### Lucas 定理

当 $n,m$ 极大且模数 $p$ 为质数时：

$$
\binom{n}{m} \equiv \binom{n \bmod p}{m \bmod p} \cdot \binom{\lfloor n/p \rfloor}{\lfloor m/p \rfloor} \pmod p
$$

相当于把 $n,m$ 写成 $p$ 进制，逐位求组合数再相乘。

### 圆排列

$n$ 个元素选出 $m$ 个围成一圈的排列数记作 $Q(n,m)$：

$$
Q(n,n) = \frac{A_n^n}{n} = (n-1)!,\qquad Q(n,m) = \binom{n}{m} \cdot Q(m,m)
$$

普通排列有 $n$ 种循环移位，圆排列把这些移位视为同一种，故除以 $n$。

### 错排数

$D_n$ 表示 $n$ 个元素都不落在自己原位置的排列数，递推式为

$$
D_n = (n-1)(D_{n-1} + D_{n-2}),\qquad D_1 = 0,\ D_2 = 1
$$

### 容斥原理

全集 $U$ 中有「坏事件」$E_1, E_2, \dots, E_m$，则一个坏事件都不发生的方案数为

$$
\left|\overline{E_1}\cap \overline{E_2}\cap \cdots \cap \overline{E_m}\right|
= \sum_{S\subseteq\{1,2,\dots,m\}} (-1)^{|S|}\left|\bigcap_{i\in S} E_i\right|
$$

其中 $S=\varnothing$ 时，$\left|\bigcap_{i\in S}E_i\right|$ 理解为 $|U|$。其本质是「恰好落在 $k$ 个坏事件里」的方案被算了 $\sum_{j=0}^{k}(-1)^j\binom{k}{j}=(1-1)^k$ 次，只有 $k=0$ 时为 $1$。

### 隔板法

把 $n$ 个**相同**元素分成 $k$ 个**不同**组：

- 每组至少 $1$ 个（正整数解 $x_i \ge 1$）：$\dbinom{n-1}{k-1}$
- 允许空组（非负整数解 $x_i \ge 0$）：$\dbinom{n+k-1}{k-1}$
- 第 $i$ 组至少 $a_i$ 个：$\dbinom{n-\sum a_i + k - 1}{k-1}$（要求 $n \ge \sum a_i$）

### 斯特林数

- **第一类斯特林数（轮换数）**：$n$ 个不同元素分成 $k$ 个非空圆排列，记作 $\begin{bmatrix}n\\k\end{bmatrix}$，递推 $\begin{bmatrix}n\\k\end{bmatrix} = \begin{bmatrix}n-1\\k-1\end{bmatrix} + (n-1)\begin{bmatrix}n-1\\k\end{bmatrix}$
- **第二类斯特林数（子集数）**：$n$ 个不同元素分成 $k$ 个非空子集，记作 $\begin{Bmatrix}n\\k\end{Bmatrix}$，递推 $\begin{Bmatrix}n\\k\end{Bmatrix} = \begin{Bmatrix}n-1\\k-1\end{Bmatrix} + k\begin{Bmatrix}n-1\\k\end{Bmatrix}$，初值 $\begin{Bmatrix}0\\0\end{Bmatrix}=1$

### 卡特兰数

$$
H_n = \binom{2n}{n} - \binom{2n}{n-1} = \frac{1}{n+1}\binom{2n}{n},\qquad H_n = \frac{4n-2}{n+1}H_{n-1},\ H_0 = 1
$$

## 逐行代码解析

本节给出组合数在 OI 中的几种计算思路（伪代码，体现思想步骤）。

### 思路一：杨辉三角递推（$n$ 较小时）

依据帕斯卡恒等式 $\binom{n}{k} = \binom{n-1}{k-1} + \binom{n-1}{k}$：

```cpp
// C[i][j] 表示组合数 C(i, j)，模 mod
C[0][0] = 1;
for (int i = 1; i <= n; i++) {
    C[i][0] = C[i][i] = 1;                 // 边界
    for (int j = 1; j < i; j++)
        C[i][j] = (C[i-1][j-1] + C[i-1][j]) % mod;
}
```

- 适合 $n$ 较小（约 $n \le 2000$）且需要多次查询的场景。
- 可顺带求出所有 $C(i,j)$，是组合数 DP 的基础。

### 思路二：预处理阶乘 + 逆元（$n$ 较大、模数为大质数）

```cpp
// fact[i] = i!，inv_fact[i] = (i!)^{-1}
// 由费马小定理：inv_fact[n] = pow(fact[n], mod-2) % mod
// 再倒推：inv_fact[i-1] = inv_fact[i] * i % mod
// 查询：C(n,k) = fact[n] * inv_fact[k] % mod * inv_fact[n-k] % mod
```

- 预处理 $O(n)$，之后每次查询 $O(1)$。
- 关键点：组合数中的除法必须换成「乘逆元」，不能直接 `/`。

### 思路三：Lucas 定理（$n$ 极大、$p$ 为质数）

```cpp
// 把 n,m 写成 p 进制，逐位求组合数再相乘
// 递归：lucas(n, m) = C(n % p, m % p) * lucas(n / p, m / p) % p
// 边界：m == 0 时返回 1
```

- 当某一位出现 $m_i > n_i$ 时，该组合数为 $0$。
- 常用于 $n$ 达到 $10^{18}$ 级别的取模组合数。

## 复杂度分析

| 场景 | 方法 | 时间复杂度 | 空间复杂度 |
|---|---|---|---|
| $n$ 较小（约 $n \le 2000$） | 杨辉三角递推 | $O(n^2)$ | $O(n^2)$ |
| $n$ 较大、模数为大质数 | 预处理阶乘 + 逆元 | $O(n)$ 预处理，$O(1)$ 查询 | $O(n)$ |
| $n$ 极大、模数 $p$ 为质数 | Lucas 定理 | $O(p)$ 预处理，$O(\log_p n)$ 查询 | $O(p)$ |
| $n$ 极大（$10^{18}$ 级别） | Lucas 定理 + 数位 DP | 视具体实现 | 视具体实现 |

## 适用场景

- **计数 DP**：很多 DP 题的最终答案就是一个组合数。
- **概率与期望**：概率本质上是「有利情况数 / 总情况数」。
- **容斥原理**：处理「至少 / 至多 / 都不出现」这类条件。
- **生成函数**：把组合问题转化为多项式运算，配合 NTT 使用。
- **二项式定理**：展开 $(a+b)^n$，用于数学变形与算法正确性证明。
- **具体模型**：合法括号串、栈的出栈序列、二叉树形态数、凸多边形三角剖分（卡特兰数）；相同元素分组（隔板法）；每个元素都不在原位置的排列（错排数）。

## 常见陷阱与注意事项

1. **排列与组合混淆**：两者唯一区别是「顺序是否计入」；排列 $A_n^k$ 再除以 $k!$ 才是组合 $\binom{n}{k}$。
2. **隔板法前提**：只适用于「元素相同、组不同、组内无序」；有上界约束时需转用容斥原理。
3. **容斥符号**：由奇偶性决定加减，容易漏掉 $(-1)^{|S|}$ 或把首尾符号写反。
4. **组合数溢出**：$\binom{n}{k}$ 增长极快，需取模；取模下的除法要先求逆元，不能直接 `/`。
5. **Lucas 前提**：模数 $p$ 必须是质数；$p$ 进制表示中某位 $m_i > n_i$ 时该项为 $0$。
6. **边界初值**：$\binom{n}{0}=1$、错排 $D_1=0$、卡特兰数 $H_0=1$、第二类斯特林数 $\begin{Bmatrix}0\\0\end{Bmatrix}=1$ 要写对，否则递推全线出错。

## 对比与扩展

| 概念 | 计数对象 | 关键公式 |
|---|---|---|
| 排列 | 有序选 $k$ 个 | $A_n^k = \dfrac{n!}{(n-k)!}$ |
| 组合 | 无序选 $k$ 个 | $\dbinom{n}{k} = \dfrac{n!}{k!(n-k)!}$ |
| 圆排列 | 选 $m$ 个围成一圈 | $Q(n,n) = (n-1)!$ |
| 错排数 | 无人在原位 | $D_n = (n-1)(D_{n-1}+D_{n-2})$ |
| 隔板法 | 相同元素分 $k$ 组 | $\dbinom{n+k-1}{k-1}$ |
| 第二类斯特林数 | $n$ 元素分 $k$ 个非空子集 | $\begin{Bmatrix}n\\k\end{Bmatrix}$ |
| 卡特兰数 | 两类操作且一类不越界 | $\dfrac{1}{n+1}\dbinom{2n}{n}$ |

扩展方向：组合数可推广到多项式系数（多重集排列）；容斥可推广到 Min-Max 容斥；生成函数把计数映射为幂级数；Lucas 可扩展到 exLucas（模任意数）；卡特兰数与斯特林数在树结构计数中频繁出现，是更复杂计数模型的基础。

### 扩展技巧速记

- **Lucas 定理模 2 的位运算判定**：当 $p=2$ 时，$\dbinom{n}{k}\equiv 1 \pmod 2$ 当且仅当 $k$ 是 $n$ 的二进制子集，即 $(n \mathbin{\&} k)=k$：

```
C(n, k) 为奇数  <=>  (n & k) == k
```

（等价于 $n \mathbin{|} k = n$：$k$ 的每个为 $1$ 的二进制位在 $n$ 中也都为 $1$，判定为 $O(1)$。）

- **卡特兰数的反射法**：$H_n$ 计数从 $(0,0)$ 到 $(n,n)$、每步向右或向上、且始终满足 $x \ge y$ 的格点路径数。总路径数为 $\dbinom{2n}{n}$；越界路径（首次碰到直线 $y=x+1$）关于该直线作反射后，与从 $(0,0)$ 到 $(n-1,n+1)$ 的路径一一对应，共 $\dbinom{2n}{n-1}$ 条。故 $H_n = \dbinom{2n}{n} - \dbinom{2n}{n-1} = \dfrac{1}{n+1}\dbinom{2n}{n}$。

- **有上界隔板法的容斥公式**：把 $n$ 个相同元素分到 $m$ 个不同组，要求 $0 \le x_i \le a_i$，方案数为

$$
\sum_{k=0}^{m} (-1)^k \sum_{|S|=k} \binom{n - \sum_{i\in S}(a_i+1) + m - 1}{m-1}
$$

其中 $n - \sum_{i\in S}(a_i+1) < 0$ 时该项为 $0$。本质是对每个违反上限的组「预扣 $a_i+1$」后，再用无上界公式。

- **每类至少出现一次的容斥模型**：把 $n$ 个不同物品分到 $m$ 类且每类非空（满射），方案数为

$$
\sum_{k=0}^{m} (-1)^k \binom{m}{k} (m-k)^n = m!\begin{Bmatrix}n\\m\end{Bmatrix}
$$

即对「恰有 $k$ 类空着」做容斥，与第二类斯特林数等价。$AKB281$, '数学', array['组合数学', '排列组合', '组合计数', '容斥原理', '卡特兰数'], null, null, 'knowledge'),
('stripe-python', 'col-math-combinatorics--stripe-python', '组合数学（排列 / 组合 / 进阶模型） · stripe-python', $AKB282$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 9. 排列组合

还有一些较难的内容放到进阶部分了。

## 9.1 排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一列，方案数用 $A_{n}^{m}$ 表示。

我们这样计算：第一个数有 $n$ 种选法，第二个数有 $n-1$ 种选法……第 $m$ 个数有 $n-m+1$ 种选法，由乘法原理得

$A_{n}^{m}=n(n-1)(n-2) \cdots (n-m+1)=\prod_{i=n-m+1}^{n} i=\dfrac{n!}{(n-m)!}$规定 $m>n$ 时 $A_{n}^{m}=0$。

而如果 $m=n$，也就是所有元素都参与排列，此时称为全排列。全排列的计算

$A_{n}^{n}=n!$### 9.1.1 全排列的枚举

在 C++ STL 中提供了 `next_permutation` 函数，可以这样使用：

```cpp
// a为要枚举排列的数组，n为长度
sort(a + 1, a + n + 1);
do {
  ...
} while (next_permutation(a + 1, a + n + 1));
```

时间复杂度为 $O(n!)$。

### 9.1.2 多重集的排列数

就是元素有重，此时需要除去重复的排列。

考虑一组有 $m$ 个的重复元素，其造成重复的个数就是它在排列中的次序交换，也就是 $m!$ 种情况，所以总排列数

$\dfrac{n!}{m_1!m_2!m_3! \cdots}=\dfrac{n!}{\prod m_i!}$其中 $n$ 为总元素个数，$m$ 为各元素出现次数。

### 9.1.3 圆排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一圈，方案数用 $Q_{n}^{m}$ 表示。考虑断环为链，共有 $m$ 个断点，故

$Q_{n}^{m}=\dfrac{A_{n}^{m}}{m}=\dfrac{n!}{m(n-m)!}$特别地，$Q_n^n=\dfrac{A_n^n}{n}=(n-1)!$。

## 9.2 组合

从 $n$ 个**不同**元素中取 $m$ 个元素组成**无序**的一个集合，方案数用 $C_{n}^{m}$ 表示。

考虑先作排列，由于集合无序，需要除去重复的组合，也就是 $m$ 的全排列，逆用乘法原理：

$C_{n}^{m}=\dfrac{A_{n}^{m}}{m!}=\dfrac{n!}{m!(n-m)!}$规定 $m>n$ 时 $C_{n}^{m}=0$。

### 9.2.1 组合的枚举

代码如下：

```cpp
int n, m, cur[N];
void dfs(int x) {
	if (x > m) return ..., void();  // 这里cur就是一个组合，进行处理
	for (int i = cur[x - 1] + 1; i <= n; i++) cur[x] = i, dfs(x + 1);
}

dfs(1);
```

它用于枚举 $1$ 到 $n$ 所有自然数选 $m$ 个的组合。如果套上 `next_permutation`，还能实现排列的枚举。

### 9.2.2 二项式定理

$(a+b)^n=\sum_{i=0}^{n} C_{n}^{i} a^{n-i} b^{i}$这个定理表明，二项式 $(a+b)^n$ 展开项的系数与组合数有直接关系。

我们知道杨辉三角：

![](https://cdn.luogu.com.cn/upload/image_hosting/y4q3udx2.png)

其每一个位置的数字通过左上 + 右上确定，每一行所对应的就是二项式展开的系数。

### 9.2.3 组合数的性质

1. 对称性：

$C_{n}^{m} = C_{n}^{n-m}$代数推导易证，组合意义就是把选出的集合取补集。

1. 递推式：

$C_{n}^{m}=C_{n-1}^{m}+C_{n-1}^{m-1}$代数推导略去，组合意义类似 DP 的思想可以证明。这个式子实际上就是杨辉三角的递推式。

1. 二项式定理的特殊情况 1：

$2^n=\sum_{i=0}^{n} C_n^i$也就是杨辉三角每一行的和。

1. 斐波那契数列：

$fib_{n+1}=\sum_{i=0}^{n} C_{n-i}^i$把杨辉三角每条斜 $30 \degree$ 角的线取出来相加可以发现。

1. 范德蒙恒等式：

$C_{m+n}^{k}=\sum_{i=0}^{k} C_m^i C_n^{k-i}$假设有两堆物品，每堆分别有 $m,n$ 个物品，总共取 $k$ 个，则方案数可分解为：从第一堆取 $i$ 个物品，第二堆取 $k-i$ 个物品，且两种选择独立，故由乘法得到贡献。最后方案即为求和。

1. 二项式定理的特殊情况 2：

$\sum_{i=0}^{n} (-1)^i C_n^i = 0$特殊情况是 $n=0$ 时上式的值为 $1$。

### 9.2.4 计算组合数

#### 定义法

- 优点：写起来简单，不用预处理。
- 缺点：查询复杂度 $O(m)$。

根据定义直接计算，注意先乘后除。

```cpp
inline long long C(int n, int m) {
	if (m > n) return 0;
	long long res = 1;
	for (int i = 1; i <= m; i++) {
		res = res * (n - i + 1) % mod * power(i, mod - 2) % mod;
	}
	return res;
}
```

#### 递推法

- 优点：任意模数，写起来简单，查询 $O(1)$。
- 缺点：预处理时空复杂度均为 $O(n^2)$。

即利用组合数性质 2 预处理杨辉三角。

```cpp
for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
for (int i = 0; i < N; i++) {
  for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
}
```

#### 逆元法

- 优点：预处理可做到 $O(n)$，查询 $O(1)$。
- 缺点：只能在模数为质数时使用。

通过预处理阶乘和阶乘的逆元，直接用定义式计算组合数。

```cpp
inline long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long fac[N], ifac[N];
inline void pre() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i % mod, ifac[i] = power(fac[i], mod - 2);
}

inline long long C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] % mod * ifac[n - m] % mod;
}
```

#### *Lucas 定理法

- 优点：预处理 $O(p)$，查询 $O(\log n)$，适用于模数小而 $n,m$ 很大的情况。
- 缺点：码量稍大，只能处理 $p$ 为质数的情况。

Lucas 定理如下：

$C_n^m \equiv C_{n \bmod p}^{m \bmod p} C_{\lfloor \frac{n}{p}\rfloor}^{\lfloor \frac{m}{p}\rfloor} \pmod p$其中 $p$ 是质数。利用这个式子，先用逆元法预处理所有 $p$ 以内的组合数，查询时递归计算即可。

```cpp
inline long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long fac[N], ifac[N];
inline void pre() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i % mod, ifac[i] = power(fac[i], mod - 2);
}

inline long long C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] % mod * ifac[n - m] % mod;
}
long long lucas(long long n, long long m) {
	if (m == 0) return 1;
	if (n < mod && m < mod) return C(n, m);
	return lucas(n / mod, m / mod) * C(n % mod, m % mod) % mod;
}
```

[P3807 【模板】卢卡斯定理/Lucas 定理](https://www.luogu.com.cn/problem/P3807)。

Lucas 定理可以实现快速求组合数前缀和，可以看进阶部分例题中的 [P4345 [SHOI2015] 超能粒子炮·改](https://www.luogu.com.cn/problem/P4345)。

#### exLucas 法

在 10.2 介绍。

## 9.3 经典模型

这里介绍排列组合题里常用的转化思想，每种模型给出一些例题。

### 9.3.1 捆绑法

Q: 有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须连续，求方案数。

A: 将 $m$ 个元素捆绑在一起，内部排列方案为 $m!$ 种，这 $m$ 个元素的整体视为一个元素，则外部排列方案为 $(n+1)!$ 种，由乘法原理得方案数为 $(n+1)!m!$。

### 9.3.2 插板法

#### 问题一

Q1: 现有 $n$ 个相同元素，分为 $k$ 组，每组至少有一个元素，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的**正**整数解数目）

A1: 不考虑分组，而是考虑间断点，将 $k-1$ 块板子插入到 $n-1$ 个空里，则答案为 $C_{n-1}^{k-1}$。

#### 问题二

Q2: 现有 $n$ 个相同元素，分为 $k$ 组，每组可以为空，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的**非负**整数解数目）

A2: 先借 $k$ 个元素过来放到每组里，由 Q1 可得方案数为 $C_{n+k-1}^{k-1}=C_{n+k-1}^{n}$，再把 $k$ 个元素拿走，方案数不变。

#### 问题三

Q3: 现有 $n$ 个相同元素，分为 $k$ 组，第 $i$ 组的元素数目不小于 $a_i$，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n$ 的解数目，其中 $x_i \ge a_i$）

A3: 先借 $\sum a_i$ 个元素过来，令 $x_i'=x_i-a_i$，可知 $\sum x_i'=n-\sum a_i$，由 Q2 得答案为 $C_{n-\sum a_i+k-1}^{n-\sum a_i}$。

#### *问题四

Q4: 现有 $n$ 个相同元素，分为 $k$ 组，每组可以为空，且第 $i$ 组元素不超过 $b_i$ 个，求方案数。

（可以抽象为：求方程 $x_1+x_2+\cdots+x_k=n,x_i \le b_i$ 的**非负**整数解数目）

A4: 考虑容斥，先抽象出容斥原理的模型：

- $U$：不定方程 $x_1+x_2+\cdots+x_k=n,x_i \le b_i$ 的**非负**整数解；
- 元素：变量 $x_i$；
- 约束：$x_i \le b_i$。

我们对每个 $i$ 计数 $x_i >b_i$，即突破限制的情况数，最后容斥一下。

根据 Q2，$|U|=C_{m+n-1}^{n-1}$。我们需要求 $|\cap_{i=1}^n S_i|$，减法原理变成 $|U|-|\cup_{i=1}^n S_i|$。

考虑 $S_{a_i}$ 的意义即 $x_{a_i} \ge b_{a_i}+1$ 的解数。使用一个 trick，将所有 $x_i$ 减去其下界限制，转化为 Q2，本题解决。

#### 问题五

Q5: 有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须两两不相邻，求方案数。

A5: 先将 $n$ 个元素全排列，再求 $n+1$ 个空隙而插入 $m$ 块板子的方案数为 $A_{n+1}^{m}$，所以方案数为 $n! A_{n+1}^{m}$。

#### 问题六

Q6: 在 $1$ 到 $n$ 的自然数中选择 $k$ 个，选出的数两两不相邻，求方案数。

A6: 考虑 $n-k+1$ 个空隙插入 $k$ 块板，注意这里是组合数 $C_{n-k+1}^k$ 而不是排列。

## 9.4 例题

排列组合的题一般有两种，一种是看着就是数学题去推公式，还有一种就是给了你某些操作，你考察操作的一些性质并结合分类讨论抽象一个组合数学的模型，然后解决问题。

### P1313 [NOIP 2011 提高组] 计算系数

直接套二项式定理：

$(ax+by)^k=\sum_{i=0}^{k} C_k^i (ax)^i(by)^{k-i}=\sum_{i=0}^{k} C_k^i a^ib^{k-i} x_iy_{k-i}$所以答案是 $C_k^m x^n y^m$。代码就不给了。

### AT_abc167_e [ABC167E] Colorful Blocks

考虑枚举恰好有 $i$ 对相邻元素颜色相同的方案数，将相同颜色的元素合并，就剩下 $n-i$ 个元素。

根据计数原理的染色例题，我们知道答案为 $m(m-1)^{n-i-1}$。同时还要乘上 $n-1$ 对元素中选出 $i$ 对的方案数，最终答案为

$\sum_{i=0}^k m(m-1)^{n-i-1} C_{n-1}^i$这个题深挖的话，其实属于二项式反演中“钦定”转“恰好”的部分。

### P1771 方程的解

求出 $x \gets x^x \bmod 1000$ 以后这题就是插板法例题 1，答案为 $C_{x-1}^{k-1}$。定义法算组合数，注意一下先乘后除。难点在于高精度。

```cpp
int k, x;
BigInteger C(int n, int m) {
	if (n < m) return 0;
	BigInteger res = 1;
	for (int i = 1; i <= m; i++) {
		res *= n - i + 1;
		res /= i;
	} return res;
}

void _main() {
	cin >> k >> x;
	x = i_pow(x, x, 1000).to_int64();
	cout << C(x - 1, k - 1);
}
```

### P3223 [HNOI2012] 排队

高中月考题（

考虑减法原理，用女生不相邻的方案数减去女生不相邻而老师相邻的方案数。

求女生不相邻的方案数，用插空法，如果已经排好了 $2$ 个老师和 $n$ 个男生，则会形成 $n+3$ 个空位，在空位上排列 $m$ 个女生即可。由乘法原理，方案数是 $A_{n+2}^{n+2} A_{n+3}^m$。

再考虑求女生不相邻而老师相邻的方案数。用捆绑法，现将老师视为整体，内部方案数为 $A_2^2$；再用插空法，一个老师的整体与 $n$ 个男生形成 $n+1$ 个空位，同理可得方案数为 $A_{n+1}^{n+1}A_{n+2}^{m}$。

综上所述，答案为

$A_{n+2}^{n+2} A_{n+3}^m-A_2^2A_{n+1}^{n+1}A_{n+2}^{m}$注意要用高精度。

```cpp
int n, m;
BigInteger A(int m, int n) {
	BigInteger res = 1;
	for (int i = n - m + 1; i <= n; i++) res *= i;
	return res;
}

void _main() {
	cin >> n >> m;
 	cout << A(n + 2, n + 2) * A(m, n + 3) - A(2, 2) * A(n + 1, n + 1) * A(m, n + 2);
}
```

### AT_abc110_d [ABC110D] Factorization

唯一难的一步就是想到将 $M$ 分解质因数。

记 $M={p_1}^{c_1} {p_2}^{c_2} {p_3}^{c_3} \cdots$，只需要把 $c_i$ 个 $p_i$ 分到 $n$ 组，由插板法例题 2 得答案为 $C_{n+c_i-1}^{n-1}$。乘法原理合并答案。

```cpp
const int N = 2e5 + 5;
int n, m;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n >> m;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 1;
	for (int i = 2; i * i <= m; i++) {
		if (m % i) continue;
		int c = 0;
		while (m % i == 0) m /= i, c++;
		res *= C(n + c - 1, n - 1);
	}
	if (m != 1) res *= n;
	cout << res;
}
```

### P11250 [GESP202409 八级] 手套配对

首先先从 $n$ 对手套中拿出 $k$ 对，方案数 $C_n^k$。又因为要恰好拿走 $k$ 对手套，说明剩下的 $m-2k$ 只手套中不能同时选走一对，从其中取出 $m$ 对左或右手套，由乘法原理得答案为 $2^{m-2k} \times C_{n-k}^{m-2k}$，最后再用乘法原理合并答案。预处理组合数用杨辉三角即可。

```cpp
const int N = 2005;
int n, m, k;
modint c[N][N];

void _main() {
	cin >> n >> m >> k;
	if (m < 2 * k) return cout << 0 << '\n', void();
	cout << c[n][k] * c[n - k][m - 2 * k] * modint(2).pow(m - 2 * k) << '\n';
} signed main() {
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	int t = 1; for (cin >> t; t--; ) _main();
}
```

### P6870 [COCI 2019/2020 #5] Zapina

用 $dp_{i,j}$ 表示前 $i$ 个人分配 $j$ 道题的合法方案数。分类讨论：

1. 让第 $i$ 个人满意，剩下 $j-i$ 道题随便分，由乘法原理得答案为 $(i-1)^{j-i} C_i^j$。
2. 让第 $i$ 个人不满意，枚举给他分几道题加起来即可。

由加法原理合并答案，复杂度 $O(n^3)$，注意一下边界。

```plaintext
const int N = 355;
int n;
mint dp[N][N], fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n;
	fac[0] = ifac[0] = 1, dp[1][1] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			if (j >= i) dp[i][j] = mint(i - 1).pow(j - i) * C(j, i);
			for (int k = 0; k <= j; k++) {
				if (i != k) dp[i][j] += dp[i - 1][j - k] * C(j, k);
			}
		}
	} cout << dp[n][n];
}
```

### P1350 车的放置

线性做法。设 $f(n,m,k)$ 表示在 $n \times m$ 的网格中放置 $k$ 个车的方案数。枚举在上方棋盘放置多少个车 $i$，根据加法原理答案为

$\sum_{i=0}^k f(a,b,i) \times f(a+c-i,d,k-i)$考虑算出 $f(n,m,k)$。考虑 $f(n,n,n)$ 就是将 $n$ 行全排列，方案数为 $n!$。从 $n\times m$ 的网格中选出一个 $k \times k$ 的子图即可。故

$f(n,m,k)=C_n^k C_m^k k!$问题解决。

```cpp
const int N = 2e3 + 5;
int a, b, c, d, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint f(int n, int m, int k) {return C(n, k) * C(m, k) * fac[k];}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> a >> b >> c >> d >> k;
	mint res = 0;
	for (int i = 0; i <= k; i++) {
		res += f(a, b, i) * f(a + c - i, d, k - i);
	} cout << res;
}
```

### CF1436C Binary Search

考虑二分查找的过程，由于 $n$ 是固定的，则二分查找的路径是唯一的，因此我们可以求出一定小于等于 $x$ 的数的个数，一定大于 $x$ 的数的个数，分别记作 $a,b$。那么在小于等于 $x$ 的 $x-1$ 个数中，就要找 $a-1$ 个数出来排列（因为还有一个数等于 $x$） ，而大于 $x$ 的 $n-x$ 个数中找 $b$ 个来排列，剩下的任意排列，是全排列。

由乘法原理可得答案

$A_{x-1}^{a-1} A_{n-x}^{b} A_{n-a-b}^{n-a-b}$计算排列数也可以用逆元法。

```cpp
const int N = 1005;
int n, x, pos;
mint fac[N], ifac[N];
mint A(int m, int n) {
	if (m > n) return 0;
	return fac[n] * ifac[n - m];
}

void _main() {
	cin >> n >> x >> pos;
	int l = 0, r = n, a = 0, b = 0;
	while (l < r) {
		int mid = (l + r) >> 1;
		if (mid <= pos) l = mid + 1, a++;
		else r = mid, b++;
	} fac[0] = 1, ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cout << A(a - 1, x - 1) * A(b, n - x) * A(n - a - b, n - a - b);
}
```

### P9306 「DTOI-5」进行一个排的重 (Minimum Version)

考虑 $f(a)$ 的计算方法，可以发现就是 $p_i,q_i$ 是否为 $[1,i]$ 的前缀最值。显然，若存在 $i \in [1,n]$ 使得 $p_i=q_i=n$，直接把这个换到前面去，其他的数任意排列都不会产生贡献，因此答案为 $2$ 和 $(n-1)!$。

通过上述讨论，我们发现 $p_i=n$ 和 $q_j=n$ 的位置是关键的。若不存在上述 $i$，手玩一下把 $p_i=n$ 的一项放到前面去，可以构造答案为 $3$。方案如下：第一项贡献为 $2$，而 $q_j$ 必然产生 $1$ 的贡献，如果不产生其他贡献，就必须在 $q_i$ 前放小于它的数。逆用乘法原理，在 $(n-1)!$ 的原方案中除去 $n-q_i$，故答案为 $\dfrac{(n-1)!}{n-q_i}$。把 $q_j$ 放到前面的方案同理，由加法原理合并答案为

$\dfrac{(n-1)!}{n-q_i}+\dfrac{(n-1)!}{n-p_j}$代码分类讨论一下即可。

```cpp
const int N = 5e5 + 5;
int n, p[N], q[N];
mint factorial(int x) {
	mint res = 1;
	for (int i = 2; i <= x; i++) res *= i;
	return res;
}
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) cin >> q[i];
	int i = 1, j = 1;
	for (int x = 1; x <= n; x++) {
		if (p[x] == n) i = x;
		if (q[x] == n) j = x;
	}
	if (i == j) cout << "2 " << factorial(n - 1);
	else cout << "3 " << factorial(n - 1) / (n - q[i]) + factorial(n - 1) / (n - p[j]);
}
```

### CF571A Lengthening Sticks

考虑求合法数目，发现 $a+b>c$ 性质不太好。正难则反，用减法原理，用总数减去不合法的数目。

先求总数。枚举加上的数总和为 $i \in [1,l]$，加到 $3$ 个数上，用插板法，$k$ 个小球之间插 $2$ 块板，方案数为 $C_{i+2}^2$，且 `0, 0, 0` 也属于总数，故总数

$1+\sum_{i=1}^{l}C_{i+2}^2=1+\sum_{i=1}^{k}\dfrac{(i+1)(i+2)}{2}$再考虑不合法的方案。不妨设 $c$ 为最长边，枚举 $i \in [0,l]$ 分配给 $c$，则 $l-i$ 个数分配给 $a,b$，且要求 $a+b \le c$，所以不合法分配为 $u=\min(c+i-a-b, l-i)$，方案数为 $C^{2}_{u+2}=\dfrac{(u+1)(u+2)}{2}$，加法原理合并方案。然后对于 $a,b$ 为最长边同理。

```cpp
#define int long long
int a, b, c, l;
int solve(int a, int b, int c) {
	int res = 0;
	for (int i = 0; i <= l; i++) {
		int u = min(c + i - a - b, l - i);
		if (u >= 0) res += (u + 1) * (u + 2) / 2;
	} return res;
}

void _main() {
	cin >> a >> b >> c >> l;
	int res = 1;
	for (int i = 1; i <= l; i++) res += (i + 1) * (i + 2) / 2;
	res -= solve(a, b, c), res -= solve(a, c, b), res -= solve(b, c, a);
	cout << res;
}
```

### CF1929F Sasha and the Wedding Binary Search Tree

BST 题经典套路中序遍历，问题转化为给 $-1$ 赋值使序列单调不降的方案数。进一步地，对于两个已经确定的点 $i,j$，则对 $(i,j)$ 中的数产生限制 $num \in [a_i,a_j]$，于是我们只需解决这个问题：

- 给出一个长为 $n$ 的序列，值域为 $[l,r]$，求让其单调不降的方案数。

很遗憾的是笔者赛时没有做出来。考虑先把第 $i$ 个数加上 $i$，则单调不降转为严格递增。而递增序列直接选出 $n$ 个不同的数即可，值域为 $[l+1,r+n]$，故答案就是 $C_{r-l+n}^{n}$。或者考虑插板法，$n$ 块板子插入 $r-l+n$ 个空也能得出来。

注意 $c$ 很大，直接逆元法会 RE，但 $\sum n \le 10^6$，所以分子可以暴力，仍然处理一下逆元。

```cpp
const int N = 2e6 + 5;
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	//return fac[n] * ifac[m] * ifac[n - m];
	mint res = 1;
	for (int i = n - m + 1; i <= n; i++) res *= i;
	return res * ifac[m];
} mint solve(int n, int l, int r) {
	if (n <= 0 || l > r) return 1;
	return C(r - l + n, n);
}

int n, c, a[N], ls[N], rs[N], v[N];
void dfs(int rt) {
	if (rt == -1) return;
	dfs(ls[rt]), a[++a[0]] = v[rt], dfs(rs[rt]);
}

void _main() {
	cin >> n >> c;
	for (int i = 1; i <= n; i++) cin >> ls[i] >> rs[i] >> v[i];
	a[0] = 0, dfs(1);
	mint res = 1;
	int l = 0;
	for (int i = 1; i <= n; i++) {
		if (a[i] == -1) continue;
		res *= solve(i - l - 1, l ? a[l] : 1, a[i]);
		l = i;
	}
	res *= solve(n - l, l ? a[l] : 1, c);
	cout << res << '\n';
}
```

### OpenJudge 9275. [USACO2009 Feb] Bullcow

模拟赛秒了。问题等价于：在 $1 \sim n$ 的数中去掉若干个数，使得两两之差 $\ge k$。

和上面那题的 trick 一样，令 $a_i \gets a_i-(i-1)k$，则转为严格递增方案数，插板法知答案为 $C_{n-(i-1)k}^i$。复杂度 $O(n)$。

```cpp
const int N = 1e6 + 5;
int n, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> k;
	mint res = 1;
	for (int i = 1; i <= n; i++) res += C(n - (i - 1) * k, i);
	cout << res;
}
```

### *P5689 [CSP-S2019 江西] 多叉堆

看到题目中的操作形式，想到带权并查集。我们设当前操作是把 $u$ 接到 $v$ 上。那么 $v$ 的位置只能填 $0$。

维护 $a_x$ 表示答案，$s_x$ 表示树的大小。填入 $u$ 子树中的数字就有 $C_{s_v-1}^{s_u}$ 种选择方案，剩下的数字填入 $v$ 子树中。

根据乘法原理，令 $a_v \gets a_ua_v C_{s_v-1}^{s_u}$。注意带权并查集不能启发式合并，复杂度 $O(q \log n)$。

```cpp
const int N = 3e5 + 5;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

int n, q, opt, x, y, last;
int fa[N], sz[N];
mint w[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
void unite(int x, int y) {
	x = find(x), y = find(y);
	if (x == y) return;
	fa[x] = y, sz[y] += sz[x], w[y] *= w[x] * C(sz[y] - 1, sz[x]);
}

void _main() {
	cin >> n >> q;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	iota(fa + 1, fa + n + 1, 1), fill(sz + 1, sz + n + 1, 1), fill(w + 1, w + n + 1, 1);
	while (q--) {
		cin >> opt >> x;
		if (opt == 1) {
			cin >> y;
			x = (x + last) % n + 1, y = (y + last) % n + 1;
			unite(x, y);
		} else {
			x = (x + last) % n + 1;
			cout << (last = w[find(x)].val) << '\n';
		}
	}
}
```

### *CF1696E Placing Jinas

显然是从格子 $(0,0)$ 开始操作，一路递推，故设 $(x,y)$ 的末值为 $f_{x,y}$，则

$f_{x,y}=f_{x-1,y}+f_{x,y-1}$对比杨辉三角的计算方法（组合数性质 2）

$C_{n}^{m}=C_{n-1}^{m}+C_{n-1}^{m-1}$发现两者很像，考虑用组合数表示 $f_{x,y}$。对比两者系数可得

$f_{x,y}=C_{x+y}^{x}$因此答案为

$\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} f_{i,j}=\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} C^{i}_{i+j}$预处理逆元后复杂度为 $O(nV)$，无法通过。所以得推波式子：

$$
\begin{aligned}
ans&=\sum_{i=0}^{n} \sum_{j=0}^{a_i-1} f_{i,j}\\
&=\sum_{i=0}^{n} (f_{i,0}+f_{i,1}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,0}+f_{i,1}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,1}+f_{i,2}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} (f_{i+1,2}+f_{i,3}+\cdots+f_{i,a_i-1})\\
&=\sum_{i=0}^{n} f_{i+1,a_i-1+1}\\
&=\sum_{i=0}^{n} C_{i+a_i}^{i+1}
\end{aligned}
$$

在推式子的过程中，利用 $f_{x,y}=f_{x-1,y}+f_{x,y-1}$ 不断合并相邻两项即可。还有一种方法是化成组合数求和后裂项。

采用预处理逆元求组合数，复杂度可以做到 $O(n)$。注意 $a_i+i$ 可以到 $4\times 10^{5}$，预处理范围要开大。

```cpp
const int N = 4e5 + 5;
int n, a[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n;
	for (int i = 0; i <= n; i++) cin >> a[i];
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint res = 0;
	for (int i = 0; i <= n; i++) res += C(i + a[i], i + 1);
	cout << res;
}
```

### *[模拟赛] 马戏表演

> 对于长为 $n$ 的排列 $a$，设 $a_i$ 表示 $p_i$ 成为了多少个区间最大值。求有多少排列满足 $\forall i \in [1,n],c_i \le m$。对给出的质数 $p$ 取模。
>
> $n \le 10^7$，$n \le m \le C_{n+1}^2$，$10^8 \le p \le 10^9$。

好题。赛时场切之，喜提机房 rk1。

注意到合法的瓶颈是最大值。考虑从最大值的位置入手 DP。

设 $f(n)$ 表示长为 $n$ 的排列的答案。若 $\lceil \dfrac{n}{2}\rceil \times (\lfloor \dfrac{n}{2} \rfloor+1) \le m$，则所有排列都合法，$f(n)=n!$。

对于其他情况，枚举最大值的位置 $i$，手玩一下发现对于长度较小的那一侧一定合法。不妨钦定 $i \le \lfloor \dfrac{n}{2} \rfloor$，则一定合法的就是左侧。根据对称性答案乘 $2$ 即可。根据加法原理得到转移：

$f(n)=2\sum_{i \le \lfloor n/2\rfloor, i(n-i+1) \le m} \dfrac{A_n^i f(n-i)}{n}$解释一下，从 $n$ 个中选择 $i$ 个定为一定合法的部分。除以 $n$ 是因为不能选择最大值。

得到 $O(n^2)$ 的做法。推式子：

$$
\begin{aligned}
f(n)&=2\sum\dfrac{A_n^i f(n-i)}{n}\\
&=\dfrac{2}{n}\sum \dfrac{n!}{(n-i)!} f(n-i)\\
&=\dfrac{2n!}{n}\sum \dfrac{f(n-i)}{(n-i)!} 
\end{aligned}
$$

解一元二次不等式得 $i \in [\dfrac{i+1-\sqrt{\Delta}}{2},\dfrac{i+1+\sqrt{\Delta}}{2}]$，其中 $\Delta=(i+1)^2-4m$。注意到二次函数的对称轴是 $\dfrac{n}{2}$，说明我们直接取 $i \le \lfloor \dfrac{i+1-\sqrt{\Delta}}{2} \rfloor$ 即可。

到这一步，可以发现求和里的东西只与 $n-i$ 有关，前缀和优化即可。

需要求 $n^{-1}$ 和 $(n!)^{-1}$，都能线性做。复杂度 $O(n)$。

```cpp
#define int long long
const int N = 1e7 + 5;
int c, n, m, p;
mod32 f[N], fac[N], ifac[N], inv[N], g[N];
mod32 A(int n, int m) {return fac[n] * ifac[n - m];}

void _main() {
	cin >> c >> n >> m >> p;
	mod32{}.set_mod(p);
	fac[0] = 1;
	for (int i = 1; i <= n + 1; i++) {
		fac[i] = fac[i - 1] * i;
		inv[i] = (i == 1 ? 1 : -inv[p % i] * (p / i));
	}
	ifac[n + 1] = ~fac[n + 1];
	for (int i = n; i >= 1; i--) ifac[i] = ifac[i + 1] * (i + 1);
	for (int i = 0; i <= n; i++) {
		if ((i / 2 + (i & 1)) * (i / 2 + 1) <= m) {
			f[i] = fac[i];
		} else {
			int delta = (i + 1) * (i + 1) - 4 * m;
			int j = 1.0 * (i + 1 - sqrt(delta)) / 2;
			f[i] = (g[i - 1] - g[i - j - 1]) * inv[i] * fac[i] * 2;
		}
		g[i] = g[i - 1] + f[i] * ifac[i];
	} cout << f[n];
}
```

### *P14254 分割（divide）

好题。

不明白赛时在干啥，开场 1h 觉得 T2 不可做直接跳题，大战 2h T3 喜提 4pts，回来看 T2 发现选的点只能是同一层，仅剩 30min 大战排列组合翻盘失败喜提 12pts，赛后 20min 改出 T2。

- 观察 1：$S_i$ 都是一段连续区间，记作 $[l_i,r_i]$。

证明：显然。
- 观察 2：所有选点必定在同一层内部。

证明：反证法，若 $\exists j,d_{b_j}>d_{b_1}$，则 $\cap_{i=2}^{k+1}$ 的左端点 $\ge d_{b_j}>d_{b_1}$，与 $S_1=\cap_{i=2}^{k+1}$ 矛盾。

于是对每一层分开考虑，最后加法原理合并答案。

预处理点 $i$ 的深度 $l_i$ 与子数内最大深度 $r_i$，则选择 $i$ 的深度区间为 $[l_i,r_i]$。

设 $\max S_1=d_{\max}$，则 $\forall i \in [2,n],r_{b_i} \ge d_{\max}$ 且 $\exists i,r_{b_i}=d_{\max}$。这是合法的充要条件。对这个东西进行计数即可。考虑拆贡献，二分出 $r_i=x$ 的点有 $a$ 个，$r_i > x$ 的点有 $b$ 个，减法原理得到

$a(A_{a+b-1}^{k-1}-A_{b}^{k-1})$特别地，$b=k-1$ 时方案都合法，不用减去 $A_{b}^{k-1}$。复杂度 $O(n \log n)$。

由于改题代码是赛后一边玉玉一边写的，这里的代码是第二天重构的。

```cpp
const int N = 1e6 + 5;
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
mint fac[N], ifac[N];
int n, k, u, l[N], r[N];
mint A(int n, int m) {return n < m ? 0 : fac[n] * ifac[n - m];}

vector<int> level[N];
void dfs(int u) {
	r[u] = l[u];
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		l[v] = l[u] + 1, dfs(v), r[u] = max(r[u], r[v]);
	}
	level[l[u]].emplace_back(r[u]);
}

void _main() {
	cin >> n >> k;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) cin >> u, add_edge(u, i);
	l[1] = 1, dfs(1);
	for (int i = 1; i <= r[1]; i++) sort(level[i].begin(), level[i].end());
	mint res = 0;
	for (int i = 2; i <= n; i++) {
		int len = level[l[i]].size();
		if (k >= len) continue;
		int x = lower_bound(level[l[i]].begin(), level[l[i]].end(), r[i]) - level[l[i]].begin();
		int y = upper_bound(level[l[i]].begin(), level[l[i]].end(), r[i]) - level[l[i]].begin() - 1;
		int a = y - x, b = len - y - 1;
		if (a <= 0 || a + b < k) continue;
		res += A(a + b, k - 1);
		if (b > k - 1) res -= A(b, k - 1);
	} cout << res;
}
```

### *P7961 [NOIP2021] 数列

套路：在 DP 状态中记录进位。

考虑数位 DP 结合计数。设 $dp_{i,j,k,p}$ 表示考虑到 $S$ 的第 $i$ 位，已经确定了 $j$ 个 $a$ 中的元素，前 $i$ 位的 $\operatorname{popcount}$ 为 $k$，向下一位进位为 $p$ 的方案数。

填表是困难的。考虑刷表转移。

讨论第 $i$ 位，枚举 $a$ 中存在 $c$ 个 $i$，则贡献为 $c$，加上进位得到 $1$ 的个数为 $p+c$。因为每两个进一位，下一个进位就是 $\lfloor \dfrac{p+c}{2}\rfloor$。同时 $\operatorname{popcount}$ 就应该加上 $(p+c) \bmod 2$。

转移方程：

$dp_{i,j,k,p} \times v_j \times C_{n-j}^{c} \to dp_{i+1,j+c,k+(p+c)\bmod 2, \lfloor (p+c)/2 \rfloor}$答案为

$\sum_{k+\operatorname{popcount(p)} \le K} dp_{m+1,n,k,p}$复杂度 $O(n^4 m)$，用杨辉三角处理组合数跑的飞快。所以这个题最难的是设计 DP 状态。

```cpp
const int N = 105;
int n, m, h, v[N];
mint C[N][N], dp[N][35][35][16];

void _main() {
	for (int i = 0; i < N; i++) C[i][0] = 1, C[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) C[i][j] = C[i - 1][j] + C[i - 1][j - 1];
	}
	cin >> n >> m >> h;
	for (int i = 0; i <= m; i++) cin >> v[i];
	dp[0][0][0][0] = 1;
	for (int i = 0; i <= m; i++) {
		for (int j = 0; j <= n; j++) {
			for (int k = 0; k <= h; k++) {
				for (int p = 0; p <= n / 2; p++) {
					for (int c = 0; c <= n - j; c++)
						dp[i + 1][j + c][k + (c + p) % 2][(c + p) >> 1]
						+= dp[i][j][k][p] * C[n - j][c] * mint(v[i]).pow(c);
				}
			}
		}
	} mint res = 0;
	for (int k = 0; k <= h; k++) {
		for (int p = 0; p <= n / 2; p++) {
			if (k + popcount(p) <= h) res += dp[m + 1][n][k][p];
		}
	} cout << res;
}
```

## 10. 排列组合进阶

由于把这坨东西放到上面会导致目录阅读体验较差，所以把这些较难的内容单独开出来了。

## 10.1 排列进阶

### *10.1.1 康托展开

**康托展开**解决的是求排列字典序的问题。先给出公式：

$1+\sum_{i=1}^{n} rk_i \times (n-i)!$其中 $rk_i$ 表示 $[i,n]$ 中有多少个数小于 $a_i$，即 $a_i$ 的后缀排名。理解一下这个公式，字典序就是比当前排列小的排列数目，贪心地枚举 $i$，使得第 $i$ 位小于 $a_i$，而后置位与字典序无关。那么我们就需要把 $i$ 后面小于 $a_i$ 的数换到前面，且根据全排列的原理有 $(n-i)!$ 种方案。

康托展开的正过程和逆过程都可以用数据结构优化到 $O(n \log n)$。一般地，康托展开常用于对排列的哈希。

### 10.1.2 对换

对于排列 $p$，选择两个不等的数 $i,j$ 并交换 $p_i,p_j$ 的过程称为一次**对换**。若 $|i-j|=1$，则称为相邻对换。

有定理：一个排列进行一次对换，逆序对数的奇偶性改变。

现在有一个经典问题：给定排列 $p_1,p_2$，求对 $p_1$ 最少做多少次对换操作变成 $p_2$。解法是对于 $i \in [1,n]$，将 $p_1$ 向 $p_2$ 连一条无向边，则用 $n$ 减去连通块个数即为答案。复杂度 $O(n)$。感性理解一下正确性：这个图形成若干环，每个含 $x$ 个点的环需要至少 $x-1$ 次对换才能使得环上所有点变成自环。所以这个做法是对的。

一般地，排列对换问题往往使用图论建模思想，用起始位置向目标位置连边。

## *10.2 exLucas 法

- 优点：任意模数，预处理约为 $O(p \log p)$，查询 $O(\log p)$，同样适用于模数小而 $n,m$ 很大的情况。
- 缺点：码量很大。

exLucas 跟 Lucas 没有半毛钱关系。

将模数 $p$ 质因数分解为 $p=p_1^{a_1} p_2^{a_2} \cdots$，然后计算 $C_n^m \bmod p^a$，最后再把答案用 exCRT 合并。

现在的重点是算 $C_n^m \bmod p^a$，由定义式得所求即为 $\dfrac{n!}{m!(n-m)!} \bmod p^a$，只要求出阶乘及逆元即可。先将阶乘中 $p$ 的倍数算掉，即 $\lfloor  \dfrac{n}{p}\rfloor!$，而剩余项存在循环节，可以一起计算，凑不进循环节的单独算。

For example：

$$
\begin{aligned}
20!&=1\times 2\times 3\times 4\times 5\times 6\times 7\times 8\times 9\times 10\times 11\times 12\times 13\times 14\times 15\times 16\times 17\times 18\times 19\times 20\\
&=(1\times 2\times 4\times 5\times 7\times 8\times 10\times 11\times 13\times 14\times 16\times 17\times 19\times 20) \times 6! \times 3^6\\
&=(1\times 2 \times 4 \times 5 \times 7 \times 8)^2\times 19 \times 20 \times 6! \times 3^6
\end{aligned}
$$

至于阶乘逆元，用 exGCD 求得即可。

```cpp
long long power(long long a, long long b, long long p) {
    long long res = 1; for (a %= p; b; b >>= 1) {
        if (b & 1) res = res * a % p;
        a = a * a % p;
    } return res;
}
void exgcd(long long a, long long b, long long& x, long long& y) {
    b == 0 ? (x = 1, y = 0) : (exgcd(b, a % b, y, x), y -= a / b * x);
}
long long inverse(long long x, long long p) {
    long long a, b;
    return exgcd(x, p, a, b), (a % p + p) % p;
}
long long calc(long long n, long long x, long long p) {
    if (n == 0) return 1;
    long long s = 1;
    for (long long i = 1; i <= p; i++) {
        if (i % x) s = s * i % p;
    } s = power(s, n / p, p);
    for (long long i = n / p * p + 1; i <= n; i++) {
        if (i % x) s = i % p * s % p;
    } return s * calc(n / x, x, p) % p;
}
long long multilucas(long long m, long long n, long long x, long long p) {
    int cnt = 0;
    for (long long i = m; i; i /= x) cnt += i / x;
    for (long long i = n; i; i /= x) cnt -= i / x;
    for (long long i = m - n; i; i /= x) cnt -= i / x;
    return power(x, cnt, p) % p * calc(m, x, p) % p * inverse(calc(n, x, p), p) % p
        * inverse(calc(m - n, x, p), p) % p;
}
long long x[20];
int crt(int n, long long* a, long long* m) {
    long long mod = 1, res = 0;
    for (int i = 1; i <= n; i++) mod *= m[i];
    for (int i = 1; i <= n; i++) {
        x[i] = mod / m[i];
        long long x0 = -1, y0 = -1;
        exgcd(x[i], m[i], x0, y0);
        res += a[i] * x[i] * (x0 >= 0 ? x0 : x0 + m[i]);
    } return res % mod;
}
long long exlucas(long long m, long long n, long long p) {
    int len = 0;
    long long p0[20], a0[20];
    for (long long i = 2; i * i <= p; i++) {
        if (p % i) continue;
        p0[++len] = 1;
        while (p % i == 0) p0[len] *= i, p /= i;
        a0[len] = multilucas(m, n, i, p0[len]);
    }
    if (p > 1) p0[++len] = p, a0[len] = multilucas(m, n, p, p);
    return crt(len, a0, p0);
}
```

[P4720 【模板】扩展卢卡斯定理/exLucas](https://www.luogu.com.cn/problem/P4720)。

## *10.3 多重集的组合数

设 $S=\{n_1 \cdot a_1,n_2\cdots a_2,\cdots,n_k \cdot a_k\}$ 是由 $n_i$ 个 $a_i$ 所组成的多重集。设 $n=\sum n_i$，对于整数 $r$，选出 $S$ 的一个大小为 $r$ 的子集的方案数为

$C_{k+r-1}^{k-1}-\sum_{i=1}^k C^{k-1}_{k+r-n_i-2}+\sum_{1 < i < j \le k} C^{k-1}_{k+r-n_i-n_j-3} - \cdots + (-1)^k C_{k+r-\sum_{i=1}^{k} n_i-(k+1)}^{k-1}$特别地，若 $r \le \min n_i$，则答案为 $C_{k+r-1}^{k-1}$。

### 证明

先讨论 $r \le \min n_i$ 的情况，等价于求 $T = \{x_1 \cdot a_1,x_2\cdots a_2,\cdots,x_k \cdot a_k\} \subseteq S$ 的数目，且满足 $\sum x_i=r$。由插板法例题 2 得到方案数为 $C_{k+r-1}^{k-1}$。

当 $n_i \to +\infty$ 时，相当于 $n_i$ 无限制，答案与上面相同。考虑减法原理，用合法减去不合法。

进一步，设 $S_i$ 表示至少包含 $n_i+1$ 个 $a_i$ 的多重集。从 $S$ 中取出 $n_i+1$ 个 $a_i$，再选 $r-n_i-1$ 个元素即可，同理答案为 $C_{k+r-n_i-2}^{k-1}$。

考虑到这样会算多，再进一步，从 $S$ 中取出 $n_i+1$ 个 $a_i$，$n_j+1$ 个 $a_j$，再任选 $r-n_i-n_j-2$ 个元素得到 $S_i \cap S_j$。类比可得 $\cap S_i$ 的情况。由容斥原理得：

$$
\begin{aligned}
|\cup_{i=1}^{n} S_i|&=\sum_{m=1}^n (-1)^{m-1} \sum_{a_i<a_{i+1}} |\cap _{i=1}^m S_{a_i}|\\
&=\sum_{i=1}^k C^{k-1}_{k+r-n_i-2}-\sum_{1 < i < j \le k} C^{k-1}_{k+r-n_i-n_j-3} +\cdots + (-1)^{k-1} C_{k+r-\sum_{i=1}^{k} n_i-(k+1)}^{k-1}
\end{aligned}
$$

这样就得到了不合法的情况总数。最终用 $C^{k-1}_{k+r-1}$ 减去即得。

## 10.4 例题

依次是康托展开、排列对换、二项式定理和一些比较难的计数题。还有不涉及多项式科技的图论计数题。

### P5367 【模板】康托展开

康托展开板子题，但你要是直接按公式求是 $O(n^2)$ 的。显然枚举 $i$ 不能删，瓶颈在计算 $rk_i$，使用权值树状数组维护即可。

实现时，可以把树状数组上每个位置都加一，然后出现了这个数再减一，这样 $rk_i$ 转化为树状数组前缀求和。复杂度 $O(n \log n)$。

```cpp
const int N = 1e6 + 5;
int n, a[N];

int tr[N];
void add(int x, int c) {for (; x <= n; x += (x & -x)) tr[x] += c;}
int ask(int x) {
	int res = 0;
	for (; x != 0; x -= (x & -x)) res += tr[x];
	return res;
}

mint fac[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, add(i, 1);
	mint res = 1;  // 初值为1
	for (int i = 1; i <= n; i++) res += fac[n - i] * (ask(a[i]) - 1), add(a[i], -1);
	cout << res;
}
```

### *P3014 [USACO11FEB] Cow Line S

这题多了一个给定排名求排列的操作，就是把康托展开的过程反过来。具体可见代码。并且这个逆操作也是可以用权值树状数组 / 权值线段树维护的。

```cpp
int n, q, a[N], ans[N];
long long x, fac[N], w[N];
char opt;

long long tr[N];
void add(int x, long long c) {for (; x <= n; x += (x & -x)) tr[x] += c;}
long long ask(int x) {
	long long res = 0;
	for (; x != 0; x -= (x & -x)) res += tr[x];
	return res;
}
int kth(int k) {
	long long pos = 0, x = 0;
	for (int i = __lg(n); i >= 0; i--) {
		x += (1 << i);
		if (x >= n || pos + tr[x] >= k) x -= (1 << i);
		else pos += tr[x];
	} return x + 1;
}

void _main() {
	cin >> n >> q;
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	while (q--) {
		memset(tr, 0, sizeof(tr));
		cin >> opt;
		if (opt == 'Q') {
			for (int i = 1; i <= n; i++) cin >> a[i], add(i, 1);
			long long res = 1;
			for (int i = 1; i <= n; i++) res += fac[n - i] * (ask(a[i]) - 1), add(a[i], -1);
			cout << res << '\n';
		} else if (opt == 'P') {
			cin >> x; x--;
			for (int i = 1; i <= n; i++) w[n - i + 1] = x % i, x /= i, add(i, 1);
			for (int i = 1; i <= n; i++) ans[i] = kth(w[i] + 1), add(ans[i], -1);
			for (int i = 1; i <= n; i++) cout << ans[i] << ' ';
			cout << '\n';
		}
	}
}
```

数据范围更大的逆康托展开模板：[UVA11525](https://www.luogu.com.cn/problem/UVA11525)。

### *CF1553E Permutation Shift

一个暴力是枚举 $m$ 得到新排列，然后用排列对换的做法求出最小对换次数。

有一个神秘的限制是 $3m \le n$。从这里入手，考虑对于排列 $p$，每次操作至多使得两个 $p_i,p_j$ 归位，则满足 $p_i=i$ 的位置至少有 $n-2m$ 个。

在这个问题中，对于位置 $i$ 有且仅有一个 $k$ 使得 $p_i$ 右移 $k$ 位以后满足 $p_i=i$。我们预处理出每个 $k$ 能使得多少个 $p_i$ 归位，根据抽屉原理，合法的 $k$ 的数目不超过

$\lfloor \dfrac{n}{n-2m} \rfloor$个。在本题中，这个数值不超过 $3$。加上这个剪枝即可通过。

```cpp
const int N = 3e5 + 5;
int n, m, a[N], pos[N], cnt[N], fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}

void _main() {
	memset(cnt, 0, sizeof(int) * (n + 1));
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i], pos[a[i]] = i, cnt[(i - a[i] + n) % n]++;
	vector<int> res;
	for (int k = 0; k < n; k++) {
		if (cnt[k] < n - 2 * m) continue;
		iota(fa + 1, fa + n + 1, 1);
		int c = 0;
		for (int i = 1; i <= n; i++) {
			int x = pos[i], y = (i + k - 1) % n + 1;
			x = find(x), y = find(y);
			if (x != y) fa[x] = y, c++;
		}
		if (c <= m) res.emplace_back(k);
	}
	cout << res.size() << ' ';
	for (int i : res) cout << i << ' ';
	cout << '\n';
}
```

### *AT_arc124_d [ARC124D] Yet Another Sorting Problem

看到排列对换问题，要想到图论建模，也就是把当前位置和目标位置连边。对于本题，我们把 $i$ 和 $p_i$ 之间连一条边。

设前 $n$ 个点为红点，后 $m$ 个点为白点。对 $(x,y)$ 进行一次对换就是交换 $x,y$ 的出点。以第二个样例为例：

![](https://cdn.luogu.com.cn/upload/image_hosting/zue3jk1v.png)

如果交换 $(2, 9)$，那么新图为

![](https://cdn.luogu.com.cn/upload/image_hosting/ver6cgiw.png)

如果交换 $(5,9)$，则新图为

![](https://cdn.luogu.com.cn/upload/image_hosting/1rk6jvyz.png)

我们可以发现两条结论：

1. 如果交换两个不在同一连通块内的点，则等价于在一个环上插入一条链。
2. 如果交换两个在同一连通块内的点，则原环在两个位置断开分裂为两个独立环。

最终的目标是做出 $n$ 个自环。我们可以发现：对于一个大小为 $n$ 的异色环，因为每次操作需要保留一对异色点，总次数为 $n-1$。

对于一个大小为 $n$ 的同色环，需要借助外部力量完成交换，最小次数是 $n+1$。有一种做法是对于两个异色的同色环一起操作，先将两个环合并为一个大的异色环再消除，总次数为二者大小之和。于是我们先做完异色环，然后按大小排序贪心即可。复杂度 $O(n \log n)$。

```cpp
const int N = 2e5 + 5;
int n, m, p[N], fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
vector<int> r[N], a, b;

void _main() {
	cin >> n >> m;
	iota(fa + 1, fa + n + m + 1, 1);
	for (int i = 1; i <= n + m; i++) {
		cin >> p[i];
		fa[find(i)] = find(p[i]);
	}
	for (int i = 1; i <= n + m; i++) r[find(i)].emplace_back(i);
	int res = 0;
	for (int i = 1; i <= n + m; i++) {
		if (find(i) != i) continue;
		if (r[i].size() == 1) continue;  // 自环
		if (r[i].back() <= n) a.emplace_back(r[i].size());  // 红色环
		else if (r[i][0] > n) b.emplace_back(r[i].size());  // 白色环
		else res += r[i].size() - 1;
	}
	sort(a.begin(), a.end(), greater<int>()), sort(b.begin(), b.end(), greater<int>());
	int la = a.size(), lb = b.size();
	for (int i = 0; i < min(la, lb); i++) res += a[i] + b[i];
	for (int i = min(la, lb); i < max(la, lb); i++) res += (i < la ? a[i] : b[i]) + 1;
	cout << res;
}
```

### *P4778 Counting swaps

排列对换问题，先把 $i \to a_i$ 连边，最后的目标状态是 $n$ 个自环。

容易证明将一个大小为 $n$ 的环变成 $n$ 个自环至少需要 $n- 1$ 次对换。对于一个长度为 $n$ 的环，达成最少次数的方法是将它拆成两个大小为 $x,y$ 的环，满足 $x+y=n$。令 $T(x,y)$ 表示分裂环的方案数，不难得到当且仅当 $x=y$ 时 $T(x,y)=x$，否则 $T(x,y)=x+y$.

考虑一个 DP，令 $f_n$ 表示大小为 $n$ 的环以最优步数变成自环的方案数，根据多重集的排列数得

$f_n=\sum_{x+y=n, x \le y} T(x,y) f_x f_y \dfrac{(n-2)!}{(x-1)!(y-1)!}$预处理出 $f_i$ 后，设初始排列由 $k$ 个环构成，第 $i$ 个环的大小为 $c_i$，根据多重集排列数有

$ans=\prod_{i=1}^k f_{c_i} \dfrac{(n-k)!}{\prod_{i=1}^k (c_i-1)!}$复杂度 $O(n^2 \log n)$，可以获得 30pts。

```cpp
const int N = 1e5 + 5;
int n, a[N], fa[N], cnt[N];
mint f[N], fac[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
mint T(int x, int y) {return x == y ? x : x + y;}

void init() {
	fac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i;
	f[1] = 1;
	for (int i = 2; i < 1000; i++) {
		for (int j = 1; j <= i / 2; j++) {
			f[i] += T(j, i - j) * f[j] * f[i - j] * fac[i - 2] / fac[j - 1] / fac[i - j - 1];
		}
	}
}

void _main() {
	cin >> n;
	iota(fa + 1, fa + n + 1, 1), fill(cnt + 1, cnt + n + 1, 0);
	for (int i = 1; i <= n; i++) cin >> a[i], fa[find(i)] = find(a[i]);
	for (int i = 1; i <= n; i++) cnt[find(i)]++;
	mint res = 1;
	int k = 0;
	for (int i = 1; i <= n; i++) {
		if (find(i) != i) continue;
		res *= f[cnt[i]] / fac[cnt[i] - 1], k++;
	}
	cout << res * fac[n - k] << '\n';
}
```

100pts 做法比较神秘。将 $f_n$ 的表打出来输入 OEIS 或者使用注意力，发现 $f_n=n^{n-2}$。于是就变成了 $O(n \log n)$。严格证明比较困难，这里不展开了。

```cpp
for (int i = 2; i < N; i++) f[i] = mint(i).pow(i - 2);   // 预处理 f[i] 改成这个即可
```

### [模拟赛] 宝石展览

> 现有 $n$ 种颜色的宝石，每种颜色有 $a_i$ 颗互不相同的宝石和一个值 $v_i$。
>
> 定义一种展览方案的华丽值为：对于每种颜色 $i$，设方案中有 $c_i$ 颗该颜色的宝石。若 $c_i=0$，则华丽值不变，否则增加 $(v_i)^{c_i}$。
>
> 求所有方案的华丽值对 $10^9+7$ 取模的结果。$n \le 2 \times 10^5,a_i \le 10^9$。

显然第 $i$ 种颜色有 $2^{a_i}$ 种选择。一个想法是求出 $s=\prod 2^{a_i}$ 表示总方案数，然后枚举当前颜色选 $j$ 个，则第 $i$ 种颜色的贡献为

$\dfrac{s}{2^{a_i}} \times \sum_{j=1}^{a_i} C_{a_i}^{j} \times (v_i)^j$复杂度 $O(nV)$，无法通过。观察一下后面那个东西，我们可以逆用二项式定理，即

$\sum_{j=1}^{a_i} C_{a_i}^{j} \times (v_i)^j=(v_i+1)^{a_i}-1$因为 $j$ 从 $1$ 开始，结果要减一。复杂度 $O(n \log V)$。赛时代码写的比较抽象。

```cpp
const int N = 2e5 + 5;
int n, a[N], v[N];
mint f[N], fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> v[i];
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	mint sum = 1, res = 0;
	for (int i = 1; i <= n; i++) f[i] = mint(2).pow(a[i]), sum *= f[i];
	for (int i = 1; i <= n; i++) {
		mint cur = 0;
		res += (mint(v[i] + 1).pow(a[i]) - 1) * (sum / f[i]);
	} cout << res;
}
```

### *CF1332E Height All the Same

很妙的性质题。我们发现操作 2 可以让任意数变成一个充分大的奇数或偶数，只要原序列中所有数奇偶性相同即可。所以我们只需考虑奇偶性。

从这个角度想，操作 1 可以让相邻两数的奇偶性改变。事实上，对于任意两个位置，我们挑选一条起终点为这两点的路径，比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/cqbhzvgl.png)

这个图里红色为起点，橙色为终点，蓝框为每次进行的操作。则黄色点都被操作两次，奇偶性不变，而起终点的奇偶性发生了改变。所以 1 操作其实是改变任意一对点的奇偶性。

当 $nm$ 为奇数时，此时高度为奇数的数目与高度为偶数的数目中，总有一个是偶数，将这个变成另外一种即可，所以所有的情况都满足限制，答案为 $(r-l+1)^{nm}$。

当 $nm$ 为偶数时，高度为奇数的数目与高度为偶数的数目不能都为奇数，也就是都为偶数。设 $[l,r]$ 中有 $a$ 个奇数，$b$ 个偶数，枚举高度为奇数的数目 $i$，答案为

$\sum_{0 \le i \le nm, 2 \mid i} C_{nm}^i a^i b^{nm-i}$复杂度 $O(nm)$，一眼二项式定理优化。只要处理好 $2 \mid i$ 即可。考虑如下结论

$$
(a+b)^{nm}=\sum_{i=0}^{nm} C_{nm}^i a^i b^{nm-i}\\
(a-b)^{nm}=\sum_{i=0}^{nm} (-1)^{nm-i} C_{nm}^i a^i b^{nm-i}
$$

当 $2 \mid i$ 时，$(-1)^{nm-i}=1$，否则为 $-1$。两式相加并简单整理得

$\sum_{0 \le i \le nm, 2 \mid i} C_{nm}^i a^i b^{nm-i}=\dfrac{(a+b)^{nm}+(a-b)^{nm}}{2}$复杂度 $O(\log nm)$。

```cpp
long long n, m, l, r;
void _main() {
	cin >> n >> m >> l >> r;
	if (n * m % 2) return cout << mint(r - l + 1).pow(n * m), void();
	long long a = r / 2 - (l - 1) / 2, b = r - l + 1 - a;
	cout << (mint(a + b).pow(n * m) + mint(a - b).pow(n * m)) / 2;
}
```

### *P4345 [SHOI2015] 超能粒子炮·改

组合数前缀和科技的板子。题意还是比较清楚的，就是求

$f(n,k)=\sum_{i=0}^{k} C_n^i \bmod 2333$打个试除法判质数可以发现 $2333$ 是质数，于是这个题适用 Lucas 定理，下面设 $p=2333$，那么

$f(n,k)=\sum_{i=0}^{k} C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{i}{p} \rfloor} C_{n \bmod p}^{i \bmod p}$接着我们把后面的 $C_{n \bmod p}^{i \bmod p}$ 按取模意义考虑贡献，且对于 $\lfloor \dfrac{i}{p} \rfloor$ 进行讨论，则

$$
\begin{aligned}
f(n,k)&=C_{\lfloor \frac{n}{p} \rfloor}^0 \sum_{i=0}^{p-1} C_{n \bmod p}^i+C_{\lfloor \frac{n}{p} \rfloor}^1 \sum_{i=0}^{p-1} C_{n \bmod p}^i+\cdots+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p}-1 \rfloor} \sum_{i=0}^{p-1} C_{n \bmod p}^i+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \sum_{i=0}^{k \bmod p} C_{n \bmod p}^i\\
&=(\sum_{i=0}^{p-1} C_{n \bmod p}^i)(C_{\lfloor \frac{n}{p} \rfloor}^0+C_{\lfloor \frac{n}{p} \rfloor}^1 +\cdots+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p}-1 \rfloor} )+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \sum_{i=0}^{k \bmod p} C_{n \bmod p}^i\\
&=f(n \bmod p,p-1) \times f(\lfloor \dfrac{n}{p} \rfloor, \lfloor \dfrac{k}{p}-1 \rfloor)+C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor} \times f(n \bmod p,k \bmod p)
\end{aligned}
$$

对于前面的 $n \bmod p$，根据余数性质可得这个东西小于 $p$，所以我们可以直接 $O(p^2)$ 地递推法求出。对于 $\dfrac{n}{p}$，$n$ 每次至少除掉 $p$，复杂度级别为 $O(\log n)$。最后的 $C_{\lfloor \frac{n}{p} \rfloor}^{\lfloor \frac{k}{p} \rfloor}$ 可以用 Lucas 定理法求出。预处理 $O(p^2)$，单次查询 $O(\log (n+k))$，但由于这个对数的底数为 $p=2333$，可以直接当作小常数。

```cpp
const int N = 2400, p = 2333;
long long q, n, k;
mint c[N][N], pre[N][N];

mint lucas(long long n, long long m) {
	if (n < m) return 0;
	if (n == m) return 1;
	return c[n % p][m % p] * lucas(n / p, m / p);
}
mint f(long long n, long long k) {
	if (k < 0) return 0;
	if (n == 0 || k == 0) return 1;
	if (n < p && k < p) return pre[n][k];
	return f(n / p, k / p - 1) * pre[n % p][p - 1] + pre[n % p][k % p] * lucas(n / p, k / p);
}

void _main() {
	for (int i = 0; i < N; i++) c[i][0] = 1, c[i][i] = 1;
	for (int i = 0; i < N; i++) {
		for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
	}
	for (int i = 0; i < N; i++) {
		pre[i][0] = 1;
		for (int j = 1; j < N; j++) pre[i][j] = pre[i][j - 1] + c[i][j];
	}
	for (cin >> q; q--; ) cin >> n >> k, cout << f(n, k) << '\n';
}
```

### *AT_arc203_c [ARC203C] Destruction of Walls

注意到 $k <n+m-2$ 时无解，于是有解的情况只有三种。想到分类讨论。

- 当 $k=n+m-2$ 时，经典格路计数问题，答案为 $C_{n+m-2}^{m-1}$。
- 当 $k=n+m-1$ 时，就是右下的格路计数乘上一条新边。容斥一下得到新的位置有 $x=n(m-1)+m(n-1)-(n+m-2)$ 个，乘上 $C_{n+m-2}^{m-1}$ 即可。
- 当 $k=n+m$ 时，一个想法是在格路上新开两条边，容斥并套进组合数的方案数为 $C_{n+m-2}^{m-1} C^{2}_{2nm-2n-2m+2}$，喜提 WA。

因为格路存在环或者返边，如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/6z5qd9tc.png)

这种情况会算重还会算漏。

注意到，这种情况存在一个“折角”，考虑对于这种结构单独计数。最终的合法路径由 $n$ 个下，一个折角，$m-3$ 个右组成。令 $f(x,y)$ 表示将 $x$ 个下，一个折角，$y$ 个右连起来的方案数，使用减法原理，用总数减去折角在两侧的情况，有

$f(x,y)=(y+1) \times C_{x+y+1}^x-2 \times C_{x+y+1}^{x+1}$然后考虑容斥，记 $y=2nm-n-m-k+1$，最后的答案式子是

$\dfrac{y(y+1)}{2}\times C_{n+m-2}^{m-1}-(n+m-3) \times C_{n+m-4}^{n-2}+f(n,m-3)+f(m,n-3)$逆元法处理组合数即可。

```cpp
const int N = 4e5 + 5;
long long n, m, k;
mint fac[N], ifac[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint f(int x, int y) {
	if (x < 0 || y < 0) return 0;
	return C(x + y + 1, x) * (y + 1) - C(x + y + 1, x + 1) * 2;
}

void _main() {
	cin >> n >> m >> k;
	if (k < n + m - 2) cout << 0 << '\n';
	else if (k == n + m - 2) cout << C(n + m - 2, m - 1) << '\n';
	else if (k == n + m - 1) {
		mint x = n * (m - 1) + m * (n - 1) - (n + m - 2);
		cout << x * C(n + m - 2, m - 1) << '\n';
	} else {
		mint y = 2 * n * m - n - m - k + 1;
		cout << C(n + m - 2, m - 1) * y * (y + 1) / 2
		- C(n + m - 4, n - 2) * (n + m - 3)
		+ f(n, m - 3) + f(m, n - 3) << '\n';
	}
}
```

### *CF1227F2 Wrong Answer on test 233 (Hard Version)

妙妙套路题。考虑单个位置的贡献变化，有 $0$ 变 $1$，$1$ 变 $0$，$0$ 变 $0$，$1$ 变 $1$ 四种情况。由于题目要求 $s'>s$ 的方案数，就只需考虑 $0$ 变 $1$，$1$ 变 $0$ 的情况。而产生变化当且仅当 $h_i$ 与 $h_{i\bmod n+1}$ 不同。若原来的 $a_i=h_i$，移动后就不满足 $a'_{j}=h_{j}$，是 $1$ 变 $0$，而若 $a_i=h_j$，就是 $0$ 变 $1$。通过上述讨论发现：**$0$ 变 $1$ 的方案数等于 $1$ 变 $0$ 的方案数。**

因此，答案其实就是

$\dfrac{k^n-p}{2}$其中 $p$ 表示分数不变的方案数。现在我们只要算出 $p$ 即可。设有 $m$ 个位置使得 $h_i$ 与 $h_{i\bmod n+1}$ 不同，分数不变就是说移动时对了 $i$ 个，错了 $i$ 个，则 $2i \le m$，即 $i \in [0,\lfloor \dfrac{m}{2} \rfloor]$。枚举 $i$，考察 $i$ 产生的贡献，有三部分：

- 对了 $i$ 个，从 $m$ 个位置选出 $i$ 个，方案数 $C^i_m$；
- 错了 $i$ 个，从剩下 $m-i$ 个位置再选 $i$ 个，然后考虑不同选项，一共是错 $m-2i$ 个，且去掉正确的选项与自身，总方案是 $C^{i}_{m-i} (k-2)^{m-2i}$。
- 除这 $m$ 个以外，其他的可以任意选，方案数 $k^{n-m}$。

由乘法原理合并答案

$p=\sum_{i=0}^{\lfloor \frac{m}{2} \rfloor}C^i_mC^{i}_{m-i} (k-2)^{m-2i}k^{n-m}$注意特判 $k=1$。用逆元法求组合数即可。

```cpp
const int N = 2e5 + 5;
int n, k, a[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> n >> k;
	if (k == 1) return cout << 0, void();
	fac[0] = ifac[0] = 1;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	int m = 0;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		if (a[i] != a[i % n + 1]) m++;
	} mint res = 0;
	for (int i = 0; i <= m / 2; i++) res += C(m, i) * C(m - i, i) * mint(k - 2).pow(m - 2 * i) * mint(k).pow(n - m);
	cout << (mint(k).pow(n) - res) / 2;
}
```

### *CF785D Anton and School - 2

考虑枚举子序列的最后一个左括号，可以动态统计其左侧及自身的左括号数目 $a$，右括号数目 $b$，然后枚举再选 $i$ 个括号，则其贡献为

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^iC_{b}^{i+1}$因为括号要匹配，只能枚举到 $\min(a-1,b-1)$，然后考虑组合意义，乘法原理合并两种方案。预处理逆元后复杂度是 $O(n^2)$，无法通过。

根据组合数性质 1，即对称性有

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^iC_{b}^{i+1}=\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^{a-1-i}C_{b}^{i+1}$然后应用组合数性质 5，即范德蒙恒等式化简

$\sum_{i=0}^{\min(a-1,b-1)} C_{a-1}^{a-1-i}C_{b}^{i+1}=C_{a+b-1}^a$于是逆元法求组合数，复杂度可以做到 $O(n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], b[N];
char s[N];
mint fac[N], ifac[N];
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	cin >> (s + 1); n = strlen(s + 1);
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 1; i <= n; i++) a[i] = a[i - 1] + (s[i] == '(');
	for (int i = n; i >= 1; i--) b[i] = b[i + 1] + (s[i] == ')');
	mint res = 0;
	for (int i = 1; i <= n; i++) {
		if (s[i] == '(') res += C(a[i] + b[i] - 1, a[i]);
	} cout << res;
}
```

### CF451E Devu and Flowers

【模板】多重集的组合数。将一个盒子视作一组重复元素，根据公式计算即可。

实现上，通过二进制枚举集合 $s$，设 $s$ 在二进制下第 $i_1,i_2,\cdots,i_k$ 位为 $1$，则贡献为

$(-1)^x C_{n+m-\sum _{j=1}^k a_{i_j}-(k+1)}^{n-1}$还有一个问题是 $n \le 20$ 但是 $m \le 10^{14}$。需要把逆元法和定义法结合起来算组合数。复杂度 $O(n2^n)$。

```cpp
#define int long long
const int N = 22;
int n, m, a[N];
mint inv[N];
mint C(int n, int m) {
	if (m < 0 || n < 0 || n < m) return 0;
	if (m == 0 || mint(n) == 0) return 1;
	mint res = 1;
	for (int i = 0; i < m; i++) res *= n - i;
	for (int i = 1; i <= m; i++) res *= inv[i];
	return res;
}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) inv[i] = ~mint(i);
	for (int i = 1; i <= n; i++) cin >> a[i];
	mint res = C(n + m - 1, n - 1);
	for (int s = 1; s < (1 << n); s++) {
		int sum = n + m, k = 0;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) sum -= a[i], k++;
		}
		sum -= k + 1;
		if (k & 1) res -= C(sum, n - 1);
		else res += C(sum, n - 1);
	} cout << res;
}
```

## 附：排列组合专题笔记（stripe-python）

## 10. 排列组合

## 10.1 排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一列，方案数用 $A_{n}^{m}$ 表示。

考虑分步计数：第一个数有 $n$ 种选法，第二个数有 $n-1$ 种选法，这样类推下去，第 $m$ 个数就有 $n-m+1$ 种选法，因此
$$
A_n^m =n(n-1)(n-2) \cdots (n-m+1)=\dfrac{n!}{(n-m)!}
$$
规定 $0 \le m \le n$ 不成立时 $A_n^m=0$。

这一结果也记为 $n^{\underline{m}}$，读作 $n$ 的 $m$ 次**下降幂**。

当 $n=m$ 时，所有元素都参与排列，此时称为**全排列**，方案数 $A_n^n=n!$。

### 10.1.1 圆排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一圈，方案数用 $Q_{n}^{m}$ 表示。

考虑消序，可以断环为链，共有 $m$ 个断点，于是
$$
Q_{n}^{m}=\dfrac{A_{n}^{m}}{m}=\dfrac{n!}{m(n-m)!}
$$
特别地，$Q_n^n=\dfrac{A_n^n}{n}=(n-1)!$。

### 10.1.2 Lehmer 码



### 10.1.3 置换

## 10.2 组合

从 $n$ 个**不同**元素中取 $m$ 个元素组成**无序**的一个集合，方案数用 $\dbinom{n}{m}$ 表示，也记作 $C_n^m$，读作 $n$ 选 $m$。本文统一采用 $\dbinom{n}{m}$ 的记法。

考虑消序，那么只需消去 $m$ 个元素的内部排列，则
$$
\binom{n}{m}=\dfrac{A_n^m}{m!}=\dfrac{n!}{m!(n-m)!}
$$
在本章中，我们规定 $0 \le m \le n$ 不成立时 $\dbinom{n}{m}=0$。

### 10.2.1 二项式定理

**二项式定理**是一个重要的组合恒等式。定理指出：
$$
(a+b)^n=\sum _{i=0}^n \binom{n}{i} a^i b^{n-i}
$$
:::::success[组合意义]
考虑从 $n$ 个相同的因式中，选择 $i$ 个因式取 $a$，剩余 $n-i$ 个因式取 $b$，则 $a^i b^{n-i}$ 项的系数就是 $\dbinom{n}{i}$。
:::::

### 10.2.2 组合恒等式

在证明组合恒等式时，我们可以采用代数推导 / 组合意义的方法来证明。

由于部分等式的代数推导比较复杂，且没有什么启发性，因此略去。读者可以自行搜索相关证明。

- **对称性**：

$$
\binom{n}{m}=\binom{n-m}{m}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\binom{n}{n-m}\\
\iff \dfrac{n!}{m!(n-m)!}&=\dfrac{n!}{(n-m)!m!}
\end{aligned}
$$

显然成立。
:::::

:::::success[组合意义]
考虑对选出的 $m$ 个元素取补集，二者的方案数相同。
:::::

- **吸收恒等式**：

$$
\binom{n}{m}=\dfrac{n}{m} \binom{n-1}{m-1}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\dfrac{n-m+1}{m} \binom{n-1}{m-1}\\
\iff \dfrac{n!}{m!(n-m)!}&=  \dfrac{n(n-1)!}{m(m-1)!(n-m)!}\\
\iff \dfrac{n!}{m!(n-m)!} &= \dfrac{n!}{m!(n-m)!}
\end{aligned}
$$

显然成立。
:::::

根据这个恒等式，可以得到 $f(x)=\dbinom{x}{n}$ 是单峰的，在 $x=\left\lfloor \dfrac{n}{2} \right\rfloor$ 和 $x=\left\lceil \dfrac{n}{2} \right\rceil$时取得最大值。也即组合数具有**凸性**。

常用变形式：$m\dbinom{n}{m}=n\dbinom{n-1}{m-1}$。

- **加法公式**：

$$
\binom{n}{m}=\binom{n-1}{m-1}+\binom{n-1}{m}
$$

:::::success[组合意义]
考虑先确定 $n-1$ 个元素时的情形，并讨论第 $n$ 个元素是否选出。由加法原理合并。
:::::

- **同行求和**：

$$
\sum_{i=0}^n \binom{n}{i}=2^n
$$

:::::success[代数推导]

在二项式定理中令 $a=b=1$ 即证。
:::::

:::::success[组合意义]
考虑对 $n$ 个元素的子集计数，枚举集合大小为 $i$，由加法原理合并得到左侧式子；考虑每个元素是否选择，由乘法原理合并得到右侧式子。
:::::

- **奇偶求和**：

$$
\sum_{i=0}^n (-1)^i \binom{n}{i} = [n=0]
$$

在 $n \ge 1$ 时上式等价于
$$
\sum_{2 \mid i} \binom{n}{i}=\sum_{2 \nmid i} \binom{n}{i}
$$
:::::success[代数推导]

在二项式定理中令 $a=1,b=-1$ 即证。
:::::

:::::success[组合意义]

我们钦定一个特殊元素，通过加入 / 删除这个元素的方法，可以翻转任意一个子集的奇偶性。因此在 $n \ge 1$ 时，奇偶子集可以两两配对，二者数目相等。

:::::

- **上指标前缀和**：

$$
\sum_{i=0}^k \binom{i}{n}=\binom{k+1}{n+1}
$$

:::::success[组合意义]
考虑在 $n+1$ 个元素中取出 $k+1$ 个元素。枚举子集的最大标号 $i$，则剩余 $n$ 个元素必须从 $0 \sim i-1$ 中选取，方案数为 $\binom{i}{n}$，加法原理合并得到总方案数。
:::::

- **范德蒙德卷积**：

$$
\sum_{i=0}^k \binom{n}{i} \binom{m}{k-i}=\binom{n+m}{k}
$$

:::::success[代数推导]

由二项式定理
$$
\begin{aligned}
(x+1)^{n+m}&=(x+1)^n (x+1)^m\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{i=0}^n \binom{n}{i} x^i \sum_{j=0}^m \binom{m}{j} x^j\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{k=0}^{n+m} x^k\sum_{i=0}^n \binom{n}{i} \binom{m}{k-i}
\end{aligned}
$$
对比 $x^k$ 项的系数易证。这里用到了形式幂级数的思想。

:::::

:::::success[组合意义]

有两堆物品，每堆分别有 $n,m$ 个物品，总共取 $k$ 个。方案数显然为 $\dbinom{n+m}{k}$。

枚举从第一堆取 $i$ 个物品，第二堆取 $k-i$ 个物品，两步选择独立，由乘法原理得到贡献，加法原理得到总方案数。

:::::

另一个常用的变形式：
$$
\sum_{i=0}^m \binom{n}{i} \binom{m}{i}=\binom{n+m}{m}
$$

### 10.2.3 计算方法

#### 10.2.3.1 定义法

由定义式 $\dbinom{n}{m}=\dfrac{n^{\underline m}}{m!}$，我们考虑计算 $n(n-1)\cdots(n-m+1)$ 并除以 $1, 2, \cdots, m$。

- 预处理：$O(1)$。
- 单次查询：$O(m)$。
- 模数要求：任意模数 / 不取模。

:::::info[代码]

```cpp line-numbers
mint C(int n, int m) {
	if (m > n) return 0;
	mint res = 1;
	for (int i = 1; i <= m; i++) res = res * (n - i + 1) / i;
	return res;
}
```

:::::

#### 10.2.3.2 递推法

由 $\dbinom{n}{m}=\dbinom{n-1}{m-1}+\dbinom{n-1}{m}$ 可以直接递推。

- 预处理：$O(n^2)$。
- 单次查询：$O(1)$。
- 模数要求：任意模数。

:::::info[代码]

```cpp line-numbers
mint c[N][N];
for (int i = 0; i <= n; i++) c[i][0] = 1, c[i][i] = 1;
for (int i = 0; i <= n; i++) {
	for (int j = 1; j < i; j++) c[i][j] = c[i - 1][j] + c[i - 1][j - 1];
}
```

:::::

#### 10.2.3.3 逆元法

由 $\dbinom{n}{m}=\dfrac{n!}{m!(n-m)!}$，我们只需预处理阶乘和阶乘的逆元，即可 $O(1)$ 计算答案。

阶乘逆元可以采用离线倒推法计算。由于需要逆元，因此对模数有要求。

- 预处理：$O(n)$。
- 单次查询：$O(1)$。
- 模数要求：模质数。

:::::info[代码]

```cpp line-numbers
template <class mint, const int N>
struct comb {
    mint fac[N], ifac[N];
    explicit comb(int n) {
        fac[0] = 1;
        for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
        ifac[n] = ~fac[n];
        for (int i = n - 1; i >= 0; i--) ifac[i] = ifac[i + 1] * (i + 1); 
    }
    mint operator() (int n, int m) const {
        if (n < m || m < 0) return 0;
        return fac[n] * ifac[m] * ifac[n - m];
    }
};
```

:::::

#### 10.2.3.4 Lucas 定理

**Lucas 定理**指出，对于质数 $p$，有
$$
\binom{n}{m}\equiv \binom{\lfloor n/p \rfloor}{\lfloor m/p \rfloor} \binom{n \bmod p}{m \bmod p} \pmod p
$$
这个定理我们不证。

我们可以利用 Lucas 定理递归求解组合数。对于 $n,m <p$ 的情形可以用逆元法得到答案。

- 预处理：$O(p)$。
- 单次查询：$O(\log n)$，对数底数为 $p$。
- 模数要求：模质数。

:::::info[代码]

```cpp line-numbers
mint lucas(i64 n, i64 m) {
	if (m == 0) return 1;
	const int p = mint::get_mod();
	if (n < p && m < p) return C(n, m);
	return lucas(n / p, m / p) * C(n % p, m % p);
}
```

:::::

可以发现，上述递归过程与 $n,m$ 的 $p$ 进制表示有很强的关联。因此与 $\dbinom{n}{m} \bmod p$ 相关的问题有时会采用数位 DP 的方法。

Lucas 定理的推论：$\dbinom{n}{m} \equiv 1 \pmod 2 \iff m \subseteq n$。考虑将 $n,m$ 拆成二进制，容易发现 $m $ 在二进制下必为 $n$ 的子集。

## 10.3 多重集的排列数

记多重集 $S=\{n_1 \cdot a_1,n_2 \cdot a_2, \cdots ,n_k \cdot a_k\}$ 表示集合中有 $n_i$ 个 $a_i$。那么 $S$ 的全排列个数为
$$
\dfrac{n!}{n_1!n_2! \cdots n_k!}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
可以用消序的观点理解这个式子。我们定义**多重组合数**为

::::warning[注意]{open}

多重组合数不是多重集的组合数。

::::
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
其中 $n=\sum \limits_{i=1}^k n_i$。多重组合数具有如下组合意义：将 $n$ 个无标号球分到 $k$ 个有标号盒子中，其中第 $i$ 个盒子恰有 $n_i$ 个球的方案数。由此我们可以得到一个恒等式
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\binom{n}{n_1}\binom{n-n_1}{n_2} \cdots \binom{n-n_1-n_2-\cdots-n_{k-1}}{n_k}
$$
代数推导也容易证明，将两边写成定义式约分后即证。

根据其组合意义，我们有**多项式定理**：
$$
(x_1+x_2+\cdots +x_k)^n =\sum_{n_1+n_2+\cdots+n_k=n} \binom{n}{n_1,n_2,\cdots,n_k} x_1^{n_1}x_2 ^{n_2} \cdots x_k^{n_k}
$$
由于 $\dbinom{n}{m}=\dbinom{n}{m,n-m}$，因此二项式定理是多项式定理的一个特殊情形。

## 10.4 经典模型

### 10.4.1 捆绑法

问题：现有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须连续，求方案数。

:::::success[题解]

将 $m$ 个元素捆绑在一起，内部排列方案为 $m!$ 种。这 $m$ 个元素的整体视为一个元素，外部排列方案为 $(n+1)!$ 种，乘法原理合并即可。

:::::

### 10.4.2 插板法 / 不定方程模型

问题一：求方程 $x_1+x_2+\cdots+x_k=n$ 的**正**整数解数目。

:::::success[题解]

考虑组合意义：将 $n$ 个相同元素分为 $k$ 组，每组至少有一个元素的方案数。

考虑用 $k-1$ 块板子插入到 $n$ 个元素之间两两形成的 $n-1$ 个空内部。答案即 $\dbinom{n-1}{k-1}$。

:::::

问题二：求方程 $x_1+x_2+\cdots+x_k=n$ 的**非负**整数解数目。

:::::success[题解]

令 $y_i =x_i+1$，则问题转化为 $y_1+y_2 + \cdots +y_k=n+k$ 的正整数解计数。由问题一，答案为
$$
\dbinom{n+k-1}{k-1}=\dbinom{n+k-1}{n}
$$
:::::

问题三：求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $x_i \ge a_i$。

:::::success[题解]

令 $y_i =x_i-a_i$，则问题转化为 $y_1+y_2 + \cdots +y_k=n-\sum\limits_{i=1}^k a_i$ 的非负整数解计数。由问题二，答案为
$$
\dbinom{n+\sum a_i+k-1}{n-\sum a_i}
$$
:::::

问题四：求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $0 \le x_i \le a_i$。

:::::success[题解]

记属性 $A_i$ 为 $x_i>a_i$，则我们所求的就是不具有任何属性的元素数目。这可以由容斥原理解决。

用钦定至少的意义容斥，枚举一个属性集合 $S$，计数具有 $S$ 中所有属性的元素数目。容斥系数为 $(-1)^{|S|}$。

对于每个 $i \in S$，令上界减去 $a_i+1$，即令 $y_i=x_i-[i \in S](a_i+1)$，问题转化为方程
$$
y_1+y_2+\cdots+y_k=n-\sum_{i \in S} (a_i+1)
$$
的非负整数解计数问题。由问题二得到
$$
\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
因此原问题的答案就是
$$
\sum _{S \subseteq \{1,2,\cdots,k\}} (-1)^{|S|}\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
:::::

问题四的答案又叫做**多重集的组合数**。

### 10.4.3 不降序列模型

问题一：求值域为 $[l,r]$，长为 $n$ 的**严格递增**序列 $a_i$ 的数目。

:::::success[题解]

考虑从 $r-l+1$ 个数中选出 $n$ 个不同数字，将其升序排序得到序列 $a$，故答案为
$$
\binom{r-l+1}{n}
$$
:::::

问题二：求值域为 $[l,r]$，长为 $n$ 的**单调不降**序列 $a_i$ 的数目。

:::::success[题解]

令 $b_i=a_i+i$，问题转化为对值域 $[l+1,r+n]$ 的严格递增序列 $b_i$ 计数，答案为
$$
\binom{r-l+n}{n}
$$
:::::

### 10.4.4 球盒模型

[P5824 十二重计数法](https://www.luogu.com.cn/problem/P5824)。

这部分的重点在于体会有标号和无标号的区别，以及理解盒子至少一个 / 至多一个的处理方法。

这里的答案有些会涉及到下文所讲的斯特林数 & 分拆数。

问题一：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

每个球都有 $m$ 种选择，由乘法原理得到答案 $m^n$。

:::::

问题二：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑每个球所在盒的标号，可以发现这是一个排列问题，答案为 $A_n^m=m^{\underline n}$。

:::::

问题三：将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

考虑求出非空子集划分方案后，乘上盒子的全排列方案数。答案即
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\} m!
$$
:::::

问题四：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

枚举非空盒子的数目为 $i$，答案为同行第二类斯特林数之和：
$$
\sum_{i=1}^m \left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
:::::

问题五：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

问题六：将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

第二类斯特林数的组合意义，答案为 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。

:::::

问题七：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的非负整数解数目。答案为
$$
\binom{n+m-1}{m-1}=\binom{n+m-1}{n}
$$
:::::

问题八：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑选定 $n$ 个盒子放球，剩余盒子不放，答案即 $\dbinom{n}{m}$。

:::::

问题九：将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的正整数解数目。答案为
$$
\binom{n-1}{m-1}
$$
:::::

问题十：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

$k$ 部分拆数的组合意义，答案为 $p(n,m)$。

:::::

问题十一：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

问题十二：将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

先给每个盒子放一个球转化为问题十，答案为 $p(n-m,m)$。

:::::

下面我们给出球盒模型的总结表格：

|   球   |  盒子  |  限制   |                             答案                             |
| :----: | :----: | :-----: | :----------------------------------------------------------: |
| 有标号 | 有标号 |   无    |                            $m^n$                             |
| 有标号 | 有标号 | $\le 1$ |                           $A_n^m$                            |
| 有标号 | 有标号 | $\ge 1$ |     $\left\{\begin{matrix}n \\m\end{matrix}\right\} m!$      |
| 有标号 | 无标号 |   无    | $\sum \limits_{i=1}^m \left\{\begin{matrix}n \\i\end{matrix}\right\}$ |
| 有标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 有标号 | 无标号 | $\ge 1$ |       $\left\{\begin{matrix}n \\m\end{matrix}\right\}$       |
| 无标号 | 有标号 |   无    |                     $\dbinom{n+m-1}{n}$                      |
| 无标号 | 有标号 | $\le 1$ |                       $\dbinom{n}{m}$                        |
| 无标号 | 有标号 | $\ge 1$ |                     $\dbinom{n-1}{m-1}$                      |
| 无标号 | 无标号 |   无    |                           $p(n,m)$                           |
| 无标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 无标号 | 无标号 | $\ge 1$ |                          $p(n-m,m)$                          |

## 10.5 组合数下指标前缀和

[AT_tenka1_2014_final_d 高橋君](https://www.luogu.com.cn/problem/AT_tenka1_2014_final_d)：

> 现有 $q$ 个询问，每次询问给出 $n,m$，求
> $$
> f(n,m)=\sum_{i=0}^m \binom{n}{i}
> $$
> 对 $10^9+7$ 取模。
>
> $q \le 10^5$，$0 \le n,m \le 10^5$，6 秒，256 MB。

考虑莫队的思想，将 $n,m$ 作为莫队指针，只要 $n,m$ 移动一位后 $f(n,m)$ 可以由原本的值 $O(1)$ 递推得到，复杂度就是正确的。事实上：

- $f(n,m+1)=f(n,m)+\dbinom{n}{m+1}$。
- $f(n,m-1)=f(n,m)-\dbinom{n}{m}$。
- $f(n+1,m)=2f(n,m)-\dbinom{n}{m}$。
- $f(n-1,m)=\dfrac{f(n,m)+\binom{n-1}{m}}{2}$。

前两条转移显然，后两条由组合数递推式裂项可得。

这样，我们就可以在 $O(n \sqrt{q})$ 的复杂度内**离线**解决组合数下指标前缀和的问题。

事实上这个问题也存在 $O(q+m \log^2 m)$ 的离线解法，参见 <https://www.luogu.com.cn/article/xypg20ht>。

## 10.6 练习

### [P11250 [GESP202409 八级] 手套配对](https://www.luogu.com.cn/problem/P11250)

> 有 $n$ 对手套，每只手套有标号，求从中取出 $m$ 只手套恰好包含 $k$ 对手套的方案数，对 $10^9+7$ 取模。
>
> 多测，$T \le 10^5,n \le 10^3, 1 \le m \le 2n, 1\le k \le n$，1 秒，512 MB。

:::::success[题解]
分两步：

- 钦定 $k$ 对手套，方案数 $\binom{n}{k}$；

- 在剩余 $n-k$ 对手套中找出 $m-2k$ 只不同组的手套，注意左右手套不同，方案数 $\binom{n-k}{m-2k} \times 2^{m-2k}$。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
comb<mint, N> C(N-1);
int n, m, k;

void _main() {
    cin >> n >> m >> k;
    cout << C(n, k) * mint(2).pow(m - 2 * k) * C(n - k, m - 2 * k) << '\n';
}
```

:::::

:::::success[另解]
二元 GF 刻画之，用 $x$ 的幂表示取出的手套总数，$y$ 的幂表示配对成功的手套对数。

一对手套的 GF 为 $1+2x+x^2y$。则答案为 $[x^m y^k] \left(1+2x+x^2y\right)^n$。于是

$$
\begin{aligned}
 \left(1+2x+x^2y\right)^n&=\sum_{i=0}^n \binom{n}{i} (1+2x)^{n-i} (x^2y)^i\\

[y^k] \left(1+2x+x^2y\right)^n &=\binom{n}{k} (1+2x)^{n-k} x^{2k}\\

[y^k] \left(1+2x+x^2y\right)^n &=\binom{n}{k} x^{2k} \sum_{j=0}^{n-k} \binom{n-k}{j} 2^j x^j\\

[x^{m-2k}] (1+2x)^{n-k}&=\binom{n-k}{m-2k} 2^{m-2k}\\

[x^m y^k] \left(1+2x+x^2y\right)^n &= \binom{n}{k} \binom{n-k}{m-2k} 2^{m-2k}
\end{aligned}
$$
:::::

### [P3330 [ZJOI2011] 看电影](https://www.luogu.com.cn/problem/P3330)

> 有 $n$ 人前来看电影，共有 $k$ 个座位。每人依次入场，从 $1 \sim k$ 中随机选择一个正整数 $p$。若 $p$ 无人则坐在 $p$，否则令 $p \gets p+1$ 并继续上述操作。若 $p>n$ 则无法落座。
>
> 求所有人都有座位的概率。需要高精度。
>
> 多测，$T \le 50$，$n,k \le 200$，1 秒，125 MB。

:::::success[题解]
特判 $k<n$ 的情况。

概率转计数，总方案显然有 $k^n$ 种，考虑计算合法方案数。

在 $k$ 后方新增一个陷阱座位，然后将 $k+1$ 个座位拉成环，这样所有人一定有座位，根据圆排列的知识可以得到方案数为 $(k+1)^{n-1}$。

此时合法当且仅当陷阱上没有人。由于环是旋转对称的，直接从 $k+1-n$ 个空座位中选出一个陷阱即可。于是得到答案式子

$$
\dfrac{(k+1)^{n-1} (k+1-n)}{k^n}
$$
:::::

:::::info[代码]

```python line-numbers
from math import gcd
T = int(input())
for _ in range(T):
    n, k = map(int, input().split())
    if k < n:
        print('0 1')
        continue
    a = ((k + 1) ** (n - 1)) * (k + 1 - n)
    b = k ** n
    print(a // gcd(a, b), b // gcd(a, b))
```

:::::


## 附：排列组合与经典模型（《OI 中的计数基础》· stripe-python）

## 3. 排列组合

### 3.1 排列

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一列，方案数用 $A_{n}^{m}$ 表示。

考虑分步计数：第一个数有 $n$ 种选法，第二个数有 $n-1$ 种选法，这样类推下去，第 $m$ 个数就有 $n-m+1$ 种选法，因此
$$
A_n^m =n(n-1)(n-2) \cdots (n-m+1)=\dfrac{n!}{(n-m)!}
$$
规定 $0 \le m \le n$ 不成立时 $A_n^m=0$。

这一结果也记为 $n^{\underline{m}}$，读作 $n$ 的 $m$ 次**下降幂**。

当 $n=m$ 时，所有元素都参与排列，此时称为**全排列**，方案数 $A_n^n=n!$。

-----

从 $n$ 个**不同**元素中取 $m$ 个元素排成**有序**的一圈，方案数用 $Q_{n}^{m}$ 表示。

考虑消序，可以断环为链，共有 $m$ 个断点，于是
$$
Q_{n}^{m}=\dfrac{A_{n}^{m}}{m}=\dfrac{n!}{m(n-m)!}
$$
特别地，$Q_n^n=\dfrac{A_n^n}{n}=(n-1)!$。

### 3.2 组合

从 $n$ 个**不同**元素中取 $m$ 个元素组成**无序**的一个集合，方案数用 $\dbinom{n}{m}$ 表示，也记作 $C_n^m$，读作 $n$ 选 $m$。本文统一采用 $\dbinom{n}{m}$ 的记法。

考虑消序，那么只需消去 $m$ 个元素的内部排列，则
$$
\binom{n}{m}=\dfrac{A_n^m}{m!}=\dfrac{n!}{m!(n-m)!}
$$
在本章中，我们规定 $0 \le m \le n$ 不成立时 $\dbinom{n}{m}=0$。

### 3.3 二项式定理

**二项式定理**是一个重要的组合恒等式。定理指出：
$$
(a+b)^n=\sum _{i=0}^n \binom{n}{i} a^i b^{n-i}
$$
:::::success[组合意义]
考虑从 $n$ 个相同的因式中，选择 $i$ 个因式取 $a$，剩余 $n-i$ 个因式取 $b$，则 $a^i b^{n-i}$ 项的系数就是 $\dbinom{n}{i}$。
:::::

### 3.4 组合恒等式

- **对称性**：

$$
\binom{n}{m}=\binom{n-m}{m}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\binom{n}{n-m}\\
\iff \dfrac{n!}{m!(n-m)!}&=\dfrac{n!}{(n-m)!m!}
\end{aligned}
$$

显然成立。
:::::

:::::success[组合意义]
考虑对选出的 $m$ 个元素取补集，二者的方案数相同。
:::::

- **吸收恒等式**：

$$
\binom{n}{m}=\dfrac{n}{m} \binom{n-1}{m-1}
$$

:::::success[代数推导]
$$
\begin{aligned}
\binom{n}{m}&=\dfrac{n-m+1}{m} \binom{n-1}{m-1}\\
\iff \dfrac{n!}{m!(n-m)!}&=  \dfrac{n(n-1)!}{m(m-1)!(n-m)!}\\
\iff \dfrac{n!}{m!(n-m)!} &= \dfrac{n!}{m!(n-m)!}
\end{aligned}
$$

显然成立。
:::::

根据这个恒等式，可以得到 $f(x)=\dbinom{x}{n}$ 是单峰的，在 $x=\left\lfloor \dfrac{n}{2} \right\rfloor$ 和 $x=\left\lceil \dfrac{n}{2} \right\rceil$时取得最大值。也即组合数具有**凸性**。

常用变形式：$m\dbinom{n}{m}=n\dbinom{n-1}{m-1}$。

- **加法公式**：

$$
\binom{n}{m}=\binom{n-1}{m-1}+\binom{n-1}{m}
$$

:::::success[组合意义]
考虑先确定 $n-1$ 个元素时的情形，并讨论第 $n$ 个元素是否选出。由加法原理合并。
:::::

- **同行求和**：

$$
\sum_{i=0}^n \binom{n}{i}=2^n
$$

:::::success[代数推导]

在二项式定理中令 $a=b=1$ 即证。
:::::

:::::success[组合意义]
考虑对 $n$ 个元素的子集计数，枚举集合大小为 $i$，由加法原理合并得到左侧式子；考虑每个元素是否选择，由乘法原理合并得到右侧式子。
:::::

- **奇偶求和**：

$$
\sum_{i=0}^n (-1)^i \binom{n}{i} = [n=0]
$$

在 $n \ge 1$ 时上式等价于
$$
\sum_{2 \mid i} \binom{n}{i}=\sum_{2 \nmid i} \binom{n}{i}
$$
:::::success[代数推导]

在二项式定理中令 $a=1,b=-1$ 即证。
:::::

:::::success[组合意义]

我们钦定一个特殊元素，通过加入 / 删除这个元素的方法，可以翻转任意一个子集的奇偶性。因此在 $n \ge 1$ 时，奇偶子集可以两两配对，二者数目相等。

:::::

- **上指标前缀和**：

$$
\sum_{i=0}^k \binom{i}{n}=\binom{k+1}{n+1}
$$

:::::success[组合意义]
考虑在 $n+1$ 个元素中取出 $k+1$ 个元素。枚举子集的最大标号 $i$，则剩余 $n$ 个元素必须从 $0 \sim i-1$ 中选取，方案数为 $\binom{i}{n}$，加法原理合并得到总方案数。
:::::

- **范德蒙德卷积**：

$$
\sum_{i=0}^k \binom{n}{i} \binom{m}{k-i}=\binom{n+m}{k}
$$

:::::success[代数推导]

由二项式定理
$$
\begin{aligned}
(x+1)^{n+m}&=(x+1)^n (x+1)^m\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{i=0}^n \binom{n}{i} x^i \sum_{j=0}^m \binom{m}{j} x^j\\
\sum_{k=0}^{n+m} \binom{n+m}{k}x^k&=\sum_{k=0}^{n+m} x^k\sum_{i=0}^n \binom{n}{i} \binom{m}{k-i}
\end{aligned}
$$
对比 $x^k$ 项的系数易证。这里用到了形式幂级数的思想。

:::::

:::::success[组合意义]

有两堆物品，每堆分别有 $n,m$ 个物品，总共取 $k$ 个。方案数显然为 $\dbinom{n+m}{k}$。

枚举从第一堆取 $i$ 个物品，第二堆取 $k-i$ 个物品，两步选择独立，由乘法原理得到贡献，加法原理得到总方案数。

:::::

另一个常用的变形式：
$$
\sum_{i=0}^m \binom{n}{i} \binom{m}{i}=\binom{n+m}{m}
$$

### 3.5 多重集的排列数

记多重集 $S=\{n_1 \cdot a_1,n_2 \cdot a_2, \cdots ,n_k \cdot a_k\}$ 表示集合中有 $n_i$ 个 $a_i$。那么 $S$ 的全排列个数为
$$
\dfrac{n!}{n_1!n_2! \cdots n_k!}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
可以用消序的观点理解这个式子。我们定义**多重组合数**为

::::warning[注意]{open}

多重组合数不是多重集的组合数。

::::
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\dfrac{n!}{\prod \limits_{i=1}^k n_i!}
$$
其中 $n=\sum \limits_{i=1}^k n_i$。多重组合数具有如下组合意义：将 $n$ 个无标号球分到 $k$ 个有标号盒子中，其中第 $i$ 个盒子恰有 $n_i$ 个球的方案数。由此我们可以得到一个恒等式
$$
\binom{n}{n_1,n_2,\cdots,n_k}=\binom{n}{n_1}\binom{n-n_1}{n_2} \cdots \binom{n-n_1-n_2-\cdots-n_{k-1}}{n_k}
$$
代数推导也容易证明，将两边写成定义式约分后即证。

根据其组合意义，我们有**多项式定理**：
$$
(x_1+x_2+\cdots +x_k)^n =\sum_{n_1+n_2+\cdots+n_k=n} \binom{n}{n_1,n_2,\cdots,n_k} x_1^{n_1}x_2 ^{n_2} \cdots x_k^{n_k}
$$
由于 $\dbinom{n}{m}=\dbinom{n}{m,n-m}$，因此二项式定理是多项式定理的一个特殊情形。

### 3.6 经典模型

#### 3.6.1 捆绑法

**问题** 现有 $n+m$ 个不同元素要进行排列，其中 $m$ 个元素必须连续，求方案数。

:::::success[题解]

将 $m$ 个元素捆绑在一起，内部排列方案为 $m!$ 种。这 $m$ 个元素的整体视为一个元素，外部排列方案为 $(n+1)!$ 种，乘法原理合并即可。

:::::

#### 3.6.2 插板法 / 不定方程模型

**问题一** 求方程 $x_1+x_2+\cdots+x_k=n$ 的**正**整数解数目。

:::::success[题解]

考虑组合意义：将 $n$ 个相同元素分为 $k$ 组，每组至少有一个元素的方案数。

考虑用 $k-1$ 块板子插入到 $n$ 个元素之间两两形成的 $n-1$ 个空内部。答案即 $\dbinom{n-1}{k-1}$。

:::::

**问题二** 求方程 $x_1+x_2+\cdots+x_k=n$ 的**非负**整数解数目。

:::::success[题解]

令 $y_i =x_i+1$，则问题转化为 $y_1+y_2 + \cdots +y_k=n+k$ 的正整数解计数。由问题一，答案为
$$
\dbinom{n+k-1}{k-1}=\dbinom{n+k-1}{n}
$$
:::::

**问题三** 求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $x_i \ge a_i$。

:::::success[题解]

令 $y_i =x_i-a_i$，则问题转化为 $y_1+y_2 + \cdots +y_k=n-\sum\limits_{i=1}^k a_i$ 的非负整数解计数。由问题二，答案为
$$
\dbinom{n+\sum a_i+k-1}{n-\sum a_i}
$$
:::::

**问题四** 求方程 $x_1+x_2+\cdots+x_k=n$ 的整数解数目，要求 $0 \le x_i \le a_i$。

:::::success[题解]

记属性 $A_i$ 为 $x_i>a_i$，则我们所求的就是不具有任何属性的元素数目。这可以由容斥原理解决。

用钦定至少的意义容斥，枚举一个属性集合 $S$，计数具有 $S$ 中所有属性的元素数目。容斥系数为 $(-1)^{|S|}$。

对于每个 $i \in S$，令上界减去 $a_i+1$，即令 $y_i=x_i-[i \in S](a_i+1)$，问题转化为方程
$$
y_1+y_2+\cdots+y_k=n-\sum_{i \in S} (a_i+1)
$$
的非负整数解计数问题。由问题二得到
$$
\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
因此原问题的答案就是
$$
\sum _{S \subseteq \{1,2,\cdots,k\}} (-1)^{|S|}\binom{n-\sum\limits_{i \in S} (a_i+1)+k-1}{k-1}
$$
:::::

问题四的答案又叫做**多重集的组合数**。

#### 3.6.3 不降序列模型

**问题一** 求值域为 $[l,r]$，长为 $n$ 的**严格递增**序列 $a_i$ 的数目。

:::::success[题解]

考虑从 $r-l+1$ 个数中选出 $n$ 个不同数字，将其升序排序得到序列 $a$，故答案为
$$
\binom{r-l+1}{n}
$$
:::::

**问题二** 求值域为 $[l,r]$，长为 $n$ 的**单调不降**序列 $a_i$ 的数目。

:::::success[题解]

令 $b_i=a_i+i$，问题转化为对值域 $[l+1,r+n]$ 的严格递增序列 $b_i$ 计数，答案为
$$
\binom{r-l+n}{n}
$$
:::::

#### 3.6.4 球盒模型

[P5824 十二重计数法](https://www.luogu.com.cn/problem/P5824)。

这部分的重点在于体会有标号和无标号的区别，以及理解盒子至少一个 / 至多一个的处理方法。

这里的答案有些会涉及到下文所讲的斯特林数 & 分拆数。

**问题一** 将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

每个球都有 $m$ 种选择，由乘法原理得到答案 $m^n$。

:::::

**问题二** 将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑每个球所在盒的标号，可以发现这是一个排列问题，答案为 $A_n^m=m^{\underline n}$。

:::::

**问题三** 将 $n$ 个有标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

考虑求出非空子集划分方案后，乘上盒子的全排列方案数。答案即
$$
\left\{\begin{matrix}
n \\
m
\end{matrix}\right\} m!
$$
:::::

**问题四** 将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

枚举非空盒子的数目为 $i$，答案为同行第二类斯特林数之和：
$$
\sum_{i=1}^m \left\{\begin{matrix}
n \\
i
\end{matrix}\right\}
$$
:::::

**问题五** 将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

**问题六** 将 $n$ 个有标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

第二类斯特林数的组合意义，答案为 $\left\{\begin{matrix}
n \\
m
\end{matrix}\right\}$。

:::::

**问题七** 将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的非负整数解数目。答案为
$$
\binom{n+m-1}{m-1}=\binom{n+m-1}{n}
$$
:::::

**问题八** 将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

考虑选定 $n$ 个盒子放球，剩余盒子不放，答案即 $\dbinom{n}{m}$。

:::::

**问题九** 将 $n$ 个无标号球放入 $m$ 个有标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

设第 $i$ 个盒子放了 $x_i$ 个球，即求不定方程 $x_1+x_2+\cdots + x_m=n$ 的正整数解数目。答案为
$$
\binom{n-1}{m-1}
$$
:::::

**问题十** 将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，求方案数。

:::::success[题解]

$k$ 部分拆数的组合意义，答案为 $p(n,m)$。

:::::

**问题十一** 将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至多一个球，求方案数。

:::::success[题解]

任意可行方案都无法区分，因此答案就是 $[n \le m]$。

:::::

**问题十二** 将 $n$ 个无标号球放入 $m$ 个无标号的盒子中，每个盒子至少一个球，求方案数。

:::::success[题解]

先给每个盒子放一个球转化为问题十，答案为 $p(n-m,m)$。

:::::

下面我们给出球盒模型的总结表格：

|   球   |  盒子  |  限制   |                             答案                             |
| :----: | :----: | :-----: | :----------------------------------------------------------: |
| 有标号 | 有标号 |   无    |                            $m^n$                             |
| 有标号 | 有标号 | $\le 1$ |                           $A_n^m$                            |
| 有标号 | 有标号 | $\ge 1$ |     $\left\{\begin{matrix}n \\m\end{matrix}\right\} m!$      |
| 有标号 | 无标号 |   无    | $\sum \limits_{i=1}^m \left\{\begin{matrix}n \\i\end{matrix}\right\}$ |
| 有标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 有标号 | 无标号 | $\ge 1$ |       $\left\{\begin{matrix}n \\m\end{matrix}\right\}$       |
| 无标号 | 有标号 |   无    |                     $\dbinom{n+m-1}{n}$                      |
| 无标号 | 有标号 | $\le 1$ |                       $\dbinom{n}{m}$                        |
| 无标号 | 有标号 | $\ge 1$ |                     $\dbinom{n-1}{m-1}$                      |
| 无标号 | 无标号 |   无    |                           $p(n,m)$                           |
| 无标号 | 无标号 | $\le 1$ |                         $[n \le m]$                          |
| 无标号 | 无标号 | $\ge 1$ |                          $p(n-m,m)$                          |

### 3.7 组合数下指标前缀和

[AT_tenka1_2014_final_d 高橋君](https://www.luogu.com.cn/problem/AT_tenka1_2014_final_d)：

> 现有 $q$ 个询问，每次询问给出 $n,m$，求
> $$
> f(n,m)=\sum_{i=0}^m \binom{n}{i}
> $$
> 对 $10^9+7$ 取模。
>
> $q \le 10^5$，$0 \le n,m \le 10^5$，6 秒，256 MB。

考虑莫队的思想，将 $n,m$ 作为莫队指针，只要 $n,m$ 移动一位后 $f(n,m)$ 可以由原本的值 $O(1)$ 递推得到，复杂度就是正确的。事实上：

- $f(n,m+1)=f(n,m)+\dbinom{n}{m+1}$。
- $f(n,m-1)=f(n,m)-\dbinom{n}{m}$。
- $f(n+1,m)=2f(n,m)-\dbinom{n}{m}$。
- $f(n-1,m)=\dfrac{f(n,m)+\binom{n-1}{m}}{2}$。

前两条转移显然，后两条由组合数递推式裂项可得。

这样，我们就可以在 $O(n \sqrt{q})$ 的复杂度内**离线**解决组合数下指标前缀和的问题。

事实上这个问题也存在 $O(q+m \log^2 m)$ 的离线解法，参见 <https://www.luogu.com.cn/article/xypg20ht>。$AKB282$, '数学', array['排列组合', '组合数', '多重集', 'exLucas'], null, null, 'knowledge'),
('Xesir', 'col-math-combinatorics--xesir', '组合数学 · Xesir', $AKB283$## 算法原理

> ***引入***

先来一道经典的选择题——

**你有 3 件不同的上衣和 2 条不同的裤子，请问一共有多少种不同的穿法？**

这个问题的答案很简单：$3 \times 2 = 6$ 种。

那换个问题：**从 10 个人里选 3 个人组成一个小组，有多少种选法？**

这时候就不能简单相乘了，因为选出的 3 个人之间**没有顺序**，$\{A,B,C\}$ 和 $\{C,B,A\}$ 是同一种选法。

再换一个：**从 10 个人里选 3 个人，分别担任组长、副组长和记录员，有多少种安排？**

这下顺序又重要了，A 当组长、B 当副组长和 B 当组长、A 当副组长是两种不同的安排。

这三个问题，分别对应了组合数学里最核心的三个概念：**乘法原理**、**组合**、**排列**。它们看起来很简单，但稍微变形一下，比如“有重复元素的排列”“带限制的组合”“容斥原理”，就能衍生出无数让人头秃的题目。

组合数学，说白了就是**研究“数数”的学问**。但这里的“数数”不是 $1,2,3,\dots$，而是**在给定规则下，计算有多少种不同的安排方式**。

在 OI 中，组合数学的应用无处不在：

- **计数 DP**：很多 DP 题的最终答案就是一个组合数。
- **概率与期望**：计算概率本质上就是“有利情况数 / 总情况数”。
- **容斥原理**：处理“至少”“至多”“都不”这类条件时的利器。
- **生成函数**：把组合问题变成多项式运算，配合 NTT 食用更佳。
- **二项式定理**：展开 $(a+b)^n$，在数学变形和算法证明中频繁出现。

组合数学内容无论在笔试题还是编程题中都很常见，从普及组一直考到 NOI，可以说是无数 OIer 心中的梦魇。~~显然牢 GOC 也正在被组合数学肘击~~

由于组合数学的变体实在太多，在题目中的应用更是群魔乱舞，这里**只会讲一些通用基础模型**，具体问题到时候再具体分析。

### 加法原理与乘法原理

这是组合数学的两条“公理”，所有复杂的计数问题都可以拆解成它们的组合。

**加法原理**：做一件事有 $n$ 类方法，第 $i$ 类方法有 $a_i$ 种做法，且各类方法之间**互不重叠**，那么总方法数为：

$$
a_1 + a_2 + \cdots + a_n
$$

简单说：**分类用加法**。

**乘法原理**：做一件事需要 $n$ 个步骤，第 $i$ 个步骤有 $a_i$ 种做法，那么总方法数为：

$$
a_1 \times a_2 \times \cdots \times a_n
$$

简单说：**分步用乘法**。

这两个原理看似是废话，但几乎所有计数问题都是从它们出发的。比如开头那个“3 件上衣 × 2 条裤子”就是乘法原理的直接应用。

### 排列

**排列**研究的是：从 $n$ 个不同元素中，选出 $k$ 个**按顺序排成一列**，有多少种排法。公式：

$$
A_n^k = \frac{n!}{(n-k)!}
$$

读作“$n$ 排 $k$”，或者“从 $n$ 个里取 $k$ 个的排列数”。

为什么是这个公式？第一个位置有 $n$ 种选法，第二个位置有 $n-1$ 种，……第 $k$ 个位置有 $n-k+1$ 种，乘起来就是：

$$
n \times (n-1) \times \cdots \times (n-k+1) = \frac{n!}{(n-k)!}
$$

**特殊情况**：$k=n$ 时，$A_n^n = n!$，也就是 $n$ 个元素的全排列数。

基础概念里还有一种更口语的说法：排列就是**把一堆东西按某种顺序排成一列**，一般 $1\sim n$ 的排列是要求将 $1\sim n$ 的数字随机打乱后按顺序排放，即每个数取 $1\sim n$ 的值且不重复。$n$ 个不同元素的全排列数量是 $n!$。

在 OI 中，排列经常出现在：

- **全排列枚举**：用 `next_permutation` 或 DFS 生成所有排列。
- **排列的逆序对**：归并排序或树状数组计算。
- **排列与置换**：把排列看成一种映射，可以研究它的循环分解。

> 很多题目都有这个哦，不只是数学相关的题呢

### 组合

**组合**研究的是：从 $n$ 个不同元素中，选出 $k$ 个**不考虑顺序**，有多少种选法。公式：

$$
C_n^k = \binom{n}{k} = \frac{n!}{k!(n-k)!}
$$

读作“$n$ 选 $k$”。

为什么是排列数再除以 $k!$？因为选出来的 $k$ 个元素，在排列中是有顺序的（$k!$ 种顺序），但组合中这些顺序算同一种，所以要除以 $k!$。

**组合数的对称性**：

$$
\binom{n}{k} = \binom{n}{n-k}
$$

意思是“选 $k$ 个留下”等价于“选 $n-k$ 个扔掉”，非常直观。

**边界情况**：

$$
\binom{n}{0} = \binom{n}{n} = 1, \quad \binom{n}{1} = n
$$

### 二项式定理

组合数最经典的应用就是二项式定理：

$$
(a+b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k} b^k
$$

这个公式的**组合意义**是：$(a+b)^n$ 展开后，每一项 $a^{n-k}b^k$ 的系数，就是从 $n$ 个括号里选 $k$ 个取 $b$、剩下的取 $a$ 的方案数。

特别地，当 $a=b=1$ 时：

$$
\sum_{k=0}^{n} \binom{n}{k} = 2^n
$$

也就是说，$n$ 个元素的**所有子集数量**是 $2^n$——这个结论在状压 DP 中天天用。

当 $a=1, b=-1$ 时：

$$
\sum_{k=0}^{n} (-1)^k \binom{n}{k} = 0
$$

这就是交错和的性质，在容斥原理中会频繁出现。

### 常见组合恒等式

这几个恒等式在 OI 中经常用到，建议记住：

**1. 转换式**

$$
\binom{n}{k} = \binom{n}{n-k}
$$

依据定义可得。当 $k$ 接近 $n$ 时可以转化为较小值。

**2. 帕斯卡恒等式（递推公式）**

$$
\binom{n}{k} = \binom{n-1}{k-1} + \binom{n-1}{k}
$$

这就是杨辉三角的递推公式，也是组合数 DP 的基础。

**3. 吸收恒等式**

$$
k\binom{n}{k} = n\binom{n-1}{k-1}
$$

**4. 范德蒙德卷积**

$$
\sum_{k=0}^{r} \binom{n}{k}\binom{m}{r-k} = \binom{n+m}{r}
$$

**5. 上指标求和**

$$
\sum_{k=0}^{n} \binom{k}{m} = \binom{n+1}{m+1}
$$

### Lucas 定理

用于处理 $n,m$ 极大的情况。一般这种情况需要取模，且模数 $p$ 为质数。公式：

$$
\binom{n}{m} \bmod p = \binom{n \bmod p}{m \bmod p} \cdot \binom{\lfloor n/p \rfloor}{\lfloor m/p \rfloor} \bmod p
$$

相当于把 $n, m$ 写成 $p$ 进制，逐位求组合数相乘。当 $p$ 较小而 $n$ 巨大时非常实用。

原文还留了一段注释版的递归写法：

```cpp
//int lucas(int n,int k){
	//if(k==0) return 1;
	//return cabz(n%mod,k%mod)*lucas(n/mod,k/mod)%mod;
//}
//计算>mod的组合数
//推导：若mod=2，则当n&k=k时C(n,k)=1，否则为0
```

- `k == 0` 是递归边界：$\binom{n}{0}=1$。
- 每次拆出 $n \bmod p$、$m \bmod p$ 这一位，用普通组合数 `cabz` 算，再把商递归下去。
- 模数为 $2$ 时可以进一步简化成位运算：`(n & k) == k` 时答案为 $1$，否则为 $0$。

### 组合数在 OI 中的计算方法

| 场景 | 方法 | 复杂度 |
|------|------|--------|
| $n$ 很小（如 $n \le 2000$） | 杨辉三角递推 | $O(n^2)$ |
| $n$ 很大，模数为大质数 | 预处理阶乘 + 费马小定理求逆元 | $O(n)$ 预处理，$O(1)$ 查询 |
| $n$ 很大，模数为任意数 | Lucas 定理 | $O(\log_p n \cdot p)$ |
| $n$ 极大（$10^{18}$ 级别） | Lucas 定理 + 数位 DP | 视情况 |

除了阶乘预处理，原文还给了两版实现：一版是杨辉三角记忆化递归（`Untitled2--xesir.cpp`），一版是阶乘 + 逆元预处理（`Untitled1--xesir.cpp`）。后者还顺手把错排、卡特兰、排列数都写在了同一个文件里，属于“组合数全家桶”。

### 圆排列

**定义：** $n$ 个元素选出 $m$ 个围成一圈的排列情况数称为圆排列数，记作 $Q(n,m)$。

**求法：** 先考虑 $Q(n,n)$。显然一个排列可以有 $n$ 种循环移位，而圆排列不能。两者只有这一个区别，故 $Q(n,n)=\frac{1}{n} \times A(n,n)=(n-1)!$。

容易得出 $Q(n,m)=C(n,m) \times Q(m,m)$。

### 错排数

**定义：** 错位排列是每个元素都不在其有序位置的排列。具体地，若 $P$ 是 $1\sim n$ 的一个排列，且对于任意 $i$ 满足 $P_i \ne i$，则称 $P$ 是 $n$ 的一个错位排列。定义 $D_n$ 为 $n$ 的错位排列总数。

**求法：** 元素 $1$ 肯定不能放在 $1$ 上。考虑元素 $1$ 替换了位置 $k$：

- 若 $k$ 在位置 $1$：此时剩余的所有 $n-2$ 个元素构成一个错排问题，故此时方案数为 $D_{n-2}$。
- 若 $k$ 不在位置 $1$：此时除 $1$ 外的 $n-1$ 个数和除 $k$ 外的 $n-1$ 个位置构成一个错排问题，故此时方案数为 $D_{n-1}$。

$k$ 可取除 $1$ 外的任意 $n-1$ 个值，故有：

$$
D_n=(n-1)(D_{n-2}+D_{n-1})
$$

边界条件：$D_1=0, D_2=1$。

### 容斥原理

**容斥原理**常用于组合计数问题的统计中，应用非常广泛。一般形式：

$$
\left|\overline{E_1}\cap \overline{E_2}\cap \cdots \cap \overline{E_m}\right|
=
\sum_{S\subseteq \{1,2,\dots,m\}} (-1)^{|S|}\left|\bigcap_{i\in S} E_i\right|
$$

**推导：** 先从最简单的情况想。

假设有一个全集 $U$，里面有一些我们不想要的“坏事件” $E_1,E_2,\dots,E_m$。我们想数的是：一个坏事件都不发生的方案数。

如果只有一个坏事件 $E_1$，那很好办：

$$
|U|-|E_1|
$$

也就是总数减去发生 $E_1$ 的方案。

如果有两个坏事件 $E_1,E_2$，先减掉发生 $E_1$ 的，再减掉发生 $E_2$ 的：

$$
|U|-|E_1|-|E_2|
$$

但是，同时发生 $E_1$ 和 $E_2$ 的方案被减了两次，所以要加回来一次：

$$
|U|-|E_1|-|E_2|+|E_1\cap E_2|
$$

如果有三个坏事件，继续往下想。先减单个，再加两两同时发生的，但三个同时发生的又被多加了一次，所以要再减掉：

$$
|U|-|E_1|-|E_2|-|E_3|
+|E_1\cap E_2|+|E_1\cap E_3|+|E_2\cap E_3|
-|E_1\cap E_2\cap E_3|
$$

这样一步步推下去，我们发现对于一个方案，如果它恰好落在 $k$ 个坏事件里，那么它在右边被计算的次数是：

$$
1-\binom{k}{1}+\binom{k}{2}-\cdots+(-1)^k\binom{k}{k}
=(1-1)^k
$$

即与事件数奇偶性相同的要被减掉，不同的由于被多减一次需要加回来，符号是交替的。其中 $S=\varnothing$ 时，$\left|\bigcap_{i\in \varnothing} E_i\right|$ 就理解为 $|U|$。

**例子：每种颜色都出现。** 把 $n$ 个位置染成 $m$ 种颜色，要求每种颜色至少出现一次。

总染法是 $m^n$。令 $E_i$ 表示第 $i$ 种颜色完全没有出现。钦定 $k$ 种颜色都不出现，那么每个位置只能在剩下的 $m-k$ 种颜色里选，方案数是 $(m-k)^n$。选出这 $k$ 种颜色有 $\binom{m}{k}$ 种。根据容斥：

$$
\sum_{k=0}^{m}(-1)^k\binom{m}{k}(m-k)^n
$$

这就是“每类都要出现”的基础容斥模型。

### 隔板法

隔板法用于解决“把 $n$ 个**相同元素**分成 $k$ 组”的计数问题，核心是在元素之间的空隙中放隔板。它和组合数学关系很近，但因为变体（正整数解、非负整数解、下界、上界）比较多，单独拆成了一篇，见「隔板法（Stars and Bars）」。

### 斯特林轮换数

**定义：** 将 $n$ 个不同元素分成 $k$ 个非空圆排列的方案数为第一类斯特林数，记作 $S(n,k)$ 或 $\begin{bmatrix}n\\k\end{bmatrix}$。

**求法：** 考虑给第 $n$ 个人分配。

- 若给 $n$ 新开一组，则前 $n-1$ 个人应该安排到 $k-1$ 个组中，方案数 $S(n-1,k-1)$。
- 若将 $n$ 安排到此前的组中，则前 $n-1$ 个人应该安排到 $k$ 个组中。此时 $n$ 有 $n-1$ 种排法，即排到前面任意一人左边，可证明不重不漏。方案数 $(n-1)S(n-1,k)$。

综上，递推公式为：

$$
S(n,k)=S(n-1,k-1)+(n-1)S(n-1,k)
$$

边界：

$$
\begin{bmatrix}0\\0\end{bmatrix}=1,\qquad
\begin{bmatrix}n\\0\end{bmatrix}=0\ (n>0),\qquad
\begin{bmatrix}0\\k\end{bmatrix}=0\ (k>0)
$$

可以验证，按这种递推方式推出的斯特林数满足 $S(n,1)=Q(n,n)$，符合定义。

### 斯特林子集数

**定义：** 将 $n$ 个不同元素分成 $k$ 个非空子集的方案数为第二类斯特林数，记作 $S(n,k)$ 或 $\begin{Bmatrix} n \\ k \end{Bmatrix}$。

**求法：** 和第一类斯特林数推导几乎相同：

- 若给 $n$ 新开一组，则前 $n-1$ 个人应该安排到 $k-1$ 个组中，方案数 $S(n-1,k-1)$。
- 若将 $n$ 安排到此前的组中，则前 $n-1$ 个人应该安排到 $k$ 个组中。方案数 $k S(n-1,k)$。

综上，递推公式为：

$$
S(n,k)=S(n-1,k-1)+k S(n-1,k)
$$

初始 $S(0,0)=1$。

### 卡特兰数

Catalan 数是 OI 中应用非常广的一类组合数。

**定义：** 我们先考虑一个问题：从格点 $(0,0)$ 走到 $(n,n)$，只能向右或向上走，不能越过主对角线，问方案数有多少？

![](https://cdn.luogu.com.cn/upload/image_hosting/k2mhccat.png)

这个问题的答案就是卡特兰数，记作 $H_n$。它表示有两种操作，并且一种操作无论何时不能超过第二种的方案数。

**求法：** 很容易想到合法数 $=$ 总数 $-$ 非法数。总数很好求就是 $C(2n,n)$，所以接下来要求非法路径数。

我们考虑创建一条副对角线，其上的点为 $(a,a+1)$：

![](https://cdn.luogu.com.cn/upload/image_hosting/blxs2hx8.png)

所有非法路径都与副对角线至少一个交点，所以我们可以将路径按副对角线对称。显然每一条非法路径唯一对应一条从 $(0,0)$ 到 $(n-1,n+1)$ 的路径，所以非法路径数为 $C(2n,n-1)$。于是我们得到：

$$
H_n=C(2n,n)-C(2n,n-1)
$$

注意到 Catalan 数其实有三个公式：

1. $H_n=C(2n,n)-C(2n,n-1)$
2. $H_n=\frac{1}{n+1} C(2n,n)$
3. $H_n=\frac{4n-2}{n+1} H_{n-1}$，其中 $H_0=1$。

~~注意力惊人~~

**应用：** 一般当问题中有两种操作，并且一种操作无论何时不能超过第二种的方案数，或要求两种操作不能有交集，这样的问题可以用 Catalan 数解决。例如：

1. 求 $n$ 对括号的合法括号串个数。合法括号串中每个右括号必然配对一个左括号，对于每个右括号，如果前面的左括号数 $<$ 右括号数，那就一定不合法。这其实和刚才的路径数是一个模型，所以其答案为 Catalan 数。
2. 一个栈的进栈序列为 $1\sim n$，求出栈序列数。显然任何时刻出栈数不能超过入栈数，所以答案也是 Catalan 数。
3. $n$ 个节点的二叉树形态数（分左右子树）。虽然看上去和 Catalan 数没有任何关联，但它满足 Catalan 数的递推式。考虑我们选好了第 $n$ 点要分配到的根节点，若左子树有 $i$ 个，那右子树就有 $n-i-1$ 个。所以总的方案数 $T_n=\sum_{i=0}^{n-1}T_i T_{n-1-i}$，满足递推式，所以也是 Catalan 数。
4. 在圆周上均匀或任意排列 $2n$ 个点，两两连接成 $n$ 条弦，并要求任意两条弦不相交。~~逐渐离谱~~ 设圆上的点按顺序编号为 $1,2,\ldots,2n$。固定点 $1$，假设点 $1$ 与点 $2i+2$ 相连，那么这条弦把其余点分成两部分，弦的一侧有 $2i$ 个点，另一侧有 $2(n-i-1)$ 个点。由于所有弦都不能相交，这两部分之间不会互相影响。因此对于这种配对方式，方案数为 $T_i T_{n-1-i}$。这样就和刚才的二叉树一样了，也是 Catalan 数。
5. 通过连接顶点将凸 $n+2$ 边形分成 $n$ 个三角形的方案数。非常显然，读者自证不难。~~？~~

## 核心公式

| 内容 | 公式 |
|---|---|
| 排列数 | $A_n^k = \dfrac{n!}{(n-k)!}$ |
| 组合数 | $\dbinom{n}{k} = \dfrac{n!}{k!(n-k)!}$ |
| 帕斯卡递推 | $\dbinom{n}{k} = \dbinom{n-1}{k-1} + \dbinom{n-1}{k}$ |
| 范德蒙德卷积 | $\sum_{k=0}^{r}\dbinom{n}{k}\dbinom{m}{r-k}=\dbinom{n+m}{r}$ |
| Lucas | $\dbinom{n}{m} \equiv \dbinom{n \bmod p}{m \bmod p}\dbinom{\lfloor n/p\rfloor}{\lfloor m/p\rfloor} \pmod p$ |
| 圆排列 | $Q(n,n)=(n-1)!,\quad Q(n,m)=C(n,m)Q(m,m)$ |
| 错排 | $D_n=(n-1)(D_{n-1}+D_{n-2})$ |
| 第一类斯特林数 | $S(n,k)=S(n-1,k-1)+(n-1)S(n-1,k)$ |
| 第二类斯特林数 | $S(n,k)=S(n-1,k-1)+kS(n-1,k)$ |
| 卡特兰数 | $H_n=\dfrac{1}{n+1}\dbinom{2n}{n}$ |

## 逐行代码解析

下面拆的是阶乘 + 逆元版本（`Untitled1--xesir.cpp`）里的几个核心函数。

### 模块一：快速幂

```cpp
int ksm(int x, int y, int p) {
    int res = 1 % p;
    x %= p;

    while (y > 0) {
        if (y & 1) {
            res = res * x % p;
        }
        x = x * x % p;
        y >>= 1;
    }
    return res;
}
```

- `res = 1 % p` 而不是直接 `1`，是为了兼容 $p=1$ 的退化情况。
- `x %= p` 先把底数压进模范围。
- 指数按二进制拆分：`y & 1` 取出当前最低位，是 $1$ 就乘进答案；每轮 `x` 自平方、`y` 右移。
- 整个循环 $O(\log y)$，后面求阶乘逆元全靠它。

### 模块二：阶乘与阶乘逆元预处理

```cpp
void jiecycl(int n) {
    n = min(n, N - 1);
    jcr[0] = 1;
    for (int i = 1; i <= n; i++) {
        jcr[i] = jcr[i - 1] * i % mod;
    }
    // 费马小定理：a^(mod-2) ≡ a^(-1) (mod mod)
    nyj[n] = ksm(jcr[n], mod - 2, mod);
    for (int i = n; i >= 1; i--) {
        nyj[i - 1] = nyj[i] * i % mod;
    }
}
```

- `n = min(n, N - 1)` 防止越界，`N` 是数组开的大小。
- 正向跑一遍得到 `jcr[i] = i!`。
- 用费马小定理求**最大的那个**阶乘逆元：`nyj[n] = (n!)^(mod-2)`。
- 反向递推：$(i!)^{-1} \cdot i = ((i-1)!)^{-1}$，所以 `nyj[i-1] = nyj[i] * i % mod`。这样只用一次快速幂就把所有阶乘逆元推出来了。
- 前提是 `mod` 为质数且 $n!$ 不被 `mod` 整除；本题 `N` 远小于 `mod`，满足条件。

### 模块三：组合数查询

```cpp
int cabz(int n, int k) {
    if (n < 0 || k < 0 || k > n || n >= N) {
        return 0;
    }

    return jcr[n] * nyj[k] % mod * nyj[n - k] % mod;
}
```

- 四个边界：$n<0$、$k<0$、$k>n$、$n$ 超出预处理范围，全部返回 $0$。
- 主体就是 $\dfrac{n!}{k!(n-k)!}$ 的模意义版本，用逆元代替除法。
- 每次乘完都取模，避免 `long long` 溢出（这里 `#define int long long`）。

### 模块四：错排与卡特兰

```cpp
D[n] = (n - 1) * (dcp(n - 1) + dcp(n - 2)) % mod;
```

- 直接翻译 $D_n=(n-1)(D_{n-1}+D_{n-2})$，记忆化数组 `D` 初值为 $0$，配合 $D_0=1,D_1=0,D_2=1$ 的边界。
- 注意 `D[1] = 0` 无法用“非零即已算”判断，所以函数开头单独写了 `n == 1` 的返回。

```cpp
for (int i = 2; i <= n; i++) {
    for (int j = 0; j < i; j++) {
        dp[i] = (dp[i] + dp[j] * dp[i - 1 - j]) % mod;
    }
}
```

- 这是卡特兰的递推式 $H_i=\sum_{j=0}^{i-1}H_jH_{i-1-j}$。
- 双重循环 $O(n^2)$，`dp` 预先开了 $200001$ 的大小。
- `H_0 = H_1 = 1`，循环从 $i=2$ 开始。

## 复杂度分析

- **杨辉三角递推**：预处理 $O(n^2)$，查询 $O(1)$，空间 $O(n^2)$；适合 $n \le 2000$。
- **阶乘 + 逆元预处理**：预处理 $O(n + \log mod)$（一次快速幂），查询 $O(1)$，空间 $O(n)$；要求模数为质数且 $n < mod$。
- **Lucas**：每次递归 $O(\log_p n)$ 层，每层算一次小组合数，总量级 $O(\log_p n \cdot p)$ 或 $O(p + \log_p n)$（视小组合数的预处理方式）。
- **圆排列**：套组合数，复杂度取决于组合数的求法。
- **错排**：记忆化递推 $O(n)$，空间 $O(n)$。
- **容斥**：一般枚举子集是 $O(2^m)$；若按“钦定 $k$ 个”合并同类项，可降到 $O(m)$ 或 $O(m \log n)$。
- **斯特林数**：递推 $O(nk)$，空间可以滚到 $O(k)$。
- **卡特兰**：本文代码是 $O(n^2)$ 递推；用通项 $\frac{1}{n+1}\binom{2n}{n}$ 可以做到 $O(n)$ 预处理 + $O(1)$ 查询。

## 适用场景

- **排列 / 组合**：有顺序用 $A_n^k$，无顺序用 $\binom{n}{k}$；判断标准只有一句“交换两个元素算不算不同方案”。
- **二项式定理**：展开、求和、证明恒等式；$\sum \binom{n}{k}=2^n$ 是状压 DP 的计数基础。
- **Lucas**：$n,m$ 巨大（$10^{18}$）而模数 $p$ 较小且为质数。
- **阶乘预处理**：$n$ 在 $10^6 \sim 10^7$、模数为大质数、需要大量查询组合数。
- **圆排列**：围成一圈、旋转视为同一种方案。
- **错排**：每个元素都不能回到自己的位置，如“装错信封”。
- **容斥**：出现“至少 / 至多 / 都不 / 恰好”等字眼，且直接正面计数困难。
- **隔板法**：相同物品分给不同组，详见单独条目。
- **斯特林数**：把 $n$ 个不同元素分成 $k$ 个非空组；第一类组内成环，第二类组内无序。
- **卡特兰数**：两种操作互相约束、括号匹配、栈的出栈序列、二叉树形态、不相交弦。

## 常见陷阱

1. **排列和组合搞混**：只要“交换顺序算不同”，就是排列；否则是组合。
2. **组合数边界没判**：$k<0$、$k>n$、$n<0$ 都应返回 $0$，漏判会数组越界或算出垃圾值。
3. **逆元前提被忽略**：阶乘预处理版本要求模数是质数，且 $n < mod$；否则阶乘出现 $0$，逆元直接失效。
4. **Lucas 的模数必须是质数**：合数模数不能直接套 Lucas，需要扩展 Lucas。
5. **容斥符号写反**：奇数个事件取负、偶数个（含 $0$ 个）取正，$|S|$ 的奇偶决定符号。
6. **隔板法的前提**：元素必须相同、组必须不同、组内无序；元素不同要先乘上排列数。
7. **错排边界**：$D_1=0$ 不是 $1$，$D_0=1$ 是为了递推方便，手算时别被绕进去。
8. **卡特兰数溢出**：$H_n$ 增长极快，不取模时 `long long` 很快就会爆。
9. **斯特林数两类混淆**：第一类组内是圆排列（乘 $n-1$），第二类组内是集合（乘 $k$），系数别写反。
10. **`#define int long long` 的副作用**：`main` 要写 `signed main`，`int` 数组内存翻倍，$10^7$ 级别要小心 MLE。

---
> 组合数学的题，九成死在“模型没认出来”。公式可以查，模型只能靠积累：先问“有没有顺序”，再问“能不能重复”，最后问“有没有限制”，三步下来基本就能对上号。$AKB283$, '数学', array['数学', '组合数学', '排列组合', '二项式定理', 'Lucas', '容斥原理', '卡特兰数', '斯特林数'], null, null, 'knowledge'),
('Xesir', 'col-math-complex--xesir', '复数 · Xesir', $AKB284$## 算法原理

复数可以看作**二元数**，形式为 $a + bi$，其中 $a, b$ 是实数，$i$ 是虚数单位，满足 $i^2 = -1$。

$a$ 叫实部，$b$ 叫虚部。两个复数相等当且仅当实部、虚部分别相等——这一点很重要，因为它意味着"一个复数 = 两个实数捆在一起"，这就是它能被塞进 FFT 里的原因。

在数学上，复数域是最完备的数域（任何多项式方程在复数域里都有解）；在 OI 中，它也常被用于 FFT 等神秘多项式算法中。

> ~~此事在人教版高中数学 A 版必修二中亦有记载~~

## 核心公式 / 状态定义与转移方程

复数 $a+bi$ 与 $c+di$ 的四则运算：

**加法 / 减法**（实部虚部分别加减）：

$$
(a+bi) \pm (c+di) = (a \pm c) + (b \pm d)i
$$

**乘法**（像多项式一样展开，再用 $i^2 = -1$ 合并）：

$$
(a+bi)(c+di) = (ac - bd) + (ad + bc)i
$$

**除法**（上下同乘分母的共轭）：

$$
\frac{a+bi}{c+di} = \frac{(a+bi)(c-di)}{c^2+d^2} = \frac{ac+bd}{c^2+d^2} + \frac{bc-ad}{c^2+d^2}\,i
$$

> 需保证分母 $c^2+d^2$ 不为零。

**模**（到原点的距离）：

$$
|a+bi| = \sqrt{a^2 + b^2}
$$

**共轭**（虚部取反）：

$$
\overline{a+bi} = a - bi
$$

顺带一提，复数乘法的几何意义就是"模相乘、幅角相加"，所以乘一个单位复数 $(\cos\theta + i\sin\theta)$ 就等于把向量旋转 $\theta$。

## 逐行代码解析

### 模块一：定义与乘法

```cpp
struct Complex { double a, b; };          // a + bi

Complex mul(Complex x, Complex y){
    return {x.a * y.a - x.b * y.b,        // 实部：ac - bd
            x.a * y.b + x.b * y.a};       // 虚部：ad + bc
}
```

- 用两个 `double` 分别存实部和虚部，是最朴素的实现。
- 乘法四个乘、两个加减，注意实部是**减**：`ac - bd`，写成加号就全错了。
- 这就是 FFT 里那个"蝶形运算"的基本单元，只是那边通常会展开手写以省常数。

### 模块二：除法与模

```cpp
Complex divide(Complex x, Complex y){
    double t = y.a * y.a + y.b * y.b;     // 分母的模长平方 c² + d²
    return {(x.a * y.a + x.b * y.b) / t,  // 实部
            (x.b * y.a - x.a * y.b) / t}; // 虚部
}
double mo(Complex x){
    return sqrt(x.a * x.a + x.b * x.b);   // 模 |a + bi|
}
```

- 除法先算分母 $c^2+d^2$，再分别算实部、虚部，避免中间反复求值。
- 虚部是 `bc - ad`，注意下标顺序：`x.b * y.a - x.a * y.b`。
- 模长用 `hypot(x.a, x.b)` 更稳（防溢出），这里为了看清公式才写成 `sqrt`。

## 复杂度分析

单次加减乘除都是常数次实数运算，$O(1)$ 时间、$O(1)$ 空间。

真正需要复杂度的地方是**用它来做算法**：FFT 做长度为 $n$ 的多项式乘法是 $O(n \log n)$，其中每次蝶形运算都是一次复数乘法加两次复数加减，复数本身并不增加渐进复杂度，只影响常数。

## 适用场景

- **FFT / NTT**：多项式乘法、大整数乘法、卷积。FFT 用的就是单位复根 $\omega = \cos\frac{2\pi}{n} + i\sin\frac{2\pi}{n}$。
- **平面向量旋转**：乘一个单位复数即可旋转，比旋转矩阵少算几个三角函数。
- **解方程**：一元二次方程判别式小于 0 时，根落在复数域。
- **几何变换**：缩放 + 旋转 + 平移可以用复数一次表达。

## 常见陷阱与注意事项

1. **除法分母为零**：$c^2 + d^2 = 0$ 当且仅当 $c = d = 0$，此时除数是 0，必须先判掉。
2. **乘法符号写反**：实部是 $ac - bd$，虚部是 $ad + bc$。四个字母的顺序记混就整道题崩。
3. **浮点误差**：FFT 里复数的实部虚部都是 `double`，长度一大误差会累积。需要精确值时用 NTT（模意义下的整数运算）替代。
4. **`std::complex` 更省事**：C++ 标准库自带 `complex<double>`，运算符都重载好了，自己写结构体主要是为了卡常数或做模意义版本。
5. **共轭忘了取**：除法必须乘**分母的共轭**，不是分子的。
6. **`i` 不是变量**：代码里没有内建的虚数单位，别写 `i` 当变量名又当虚数用。$AKB284$, '数学', array['数学', '复数', 'FFT', '虚数单位'], 'col-math-oi-foundations', null, 'knowledge'),
('stripe-python', 'col-math-congruence-basics--stripe-python', '同余与模运算（快速幂 / 乘法逆元 / Modint） · stripe-python', $AKB285$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 1. 同余

取模定义：当 $a,p$ 为正数时，有 $a \bmod p=a-b\lfloor \dfrac{a}{b} \rfloor$。

## 1.1 概念 & 性质

若 $a \bmod p =b \bmod p$，则称 $a,b$ 模 $p$ **同余**，记作

$a\equiv b \pmod p$也就是 $a,b$ 在模 $p$ 意义下相等。

推导性质时，我们省略 $\pmod p$。若 $a\equiv b$，同余有如下性质：

- 同加性：$a+c \equiv b+c$
- 同减性：$a-c \equiv b-c$
- 同乘性：$a \times c \equiv b \times c$

还有一个差性质：$a \equiv b \pmod p$ 等价于 $p \mid (a-b)$。它是同减性的推论。

还有一些性质如欧拉定理，扩展欧拉定理等，详见下文数论常用定理部分。

同加 / 减 / 乘性告诉我们，若在模意义下求加 / 减 / 乘法，那么直接把两个运算数先取模再运算最后取模一次，结果是正确的。**但是除法不行。**

请注意：在 C++ 中，对负数 `a` 取模的结果应当写作 `(a % p + p) % p`。

## 1.2 快速幂

快速幂是一个非常常用的数论技巧，可以在 $O(\log b)$ 时间内计算 $a^ b \bmod p$。

因为 $x \times y \equiv (x \bmod p) \times (y \bmod p) \pmod p$，所以一个暴力的做法是直接执行 $b$ 次 $a \gets a \times a \bmod p$，复杂度 $O(b)$。而这个过程可以倍增优化。例如：

$a^{13} \equiv a^{(1101)_2} \equiv a^8 \times a^4 \times a^1 \pmod p$将 $b$ 二进制分解，则位数为 $O(\log b)$，于是我们只要执行 $O(\log b)$ 次乘法。代码如下：

```cpp
template <class T> T mpow(T a, T b, T p) {
    T res = 0; for (a %= p; b; a = a * a % p, b >>= 1) {
        if (b & 1) res = res * a % p;
    } return res;
}
```

事实上，当 $a \times a$ 表示的不再是乘法，而是一个具有**结合律**的运算时，我们仍然可以用快速幂计算 $a^b$。例如加法、矩阵乘法、置换等，笔者把这种东西叫做广义快速幂。

### 1.2.1 快速乘

[题目链接](https://www.luogu.com.cn/problem/P10446)。如果我们要求 $a b \bmod p$，且 $a,b,p$ 为 64 位整数，直接算会溢出。

可以使用广义快速幂的方法来求，复杂度为 $O(\log \min(a, b))$，会导致复杂度飙升。下面介绍两种复杂度为 $O(1)$ 的快速乘。

#### 使用 128 位整数

直接使用 `__int128` 强制转换：

```cpp
int64_t a, b, p;
void _main() {
	cin >> a >> b >> p;
	cout << (int64_t) ((__int128) a * b % p);
}
```

#### *使用 64 位浮点数

由取模的定义

$ab \bmod p=ab-\lfloor \dfrac{ab}{p} \rfloor \times p$因为 $p$ 是 64 位整数，所以结果可以对 $2^{64}$ 取模，也就是 `unsigned long long` 自然溢出。现在 $ab$ 和 $\lfloor \dfrac{ab}{p} \rfloor \times p$ 都可以直接自然溢出解决。只要求出 $\lfloor \dfrac{ab}{p} \rfloor$ 即可。使用 `long double` 算出 $\dfrac{a}{p}$ 再乘上 $b$ 即可。

误差分析表明，用这种方法计算 $\dfrac{ab}{p}$ 的误差范围为 $(-0.5,0.5)$，加上 $0.5$ 并取整，误差为 $0$ 或 $1$，乘上 $p$ 后误差为 $0$ 或 $-p$，特判即可。

```cpp
int64_t a, b, p;
void _main() {
	cin >> a >> b >> p;
	uint64_t c = (uint64_t) a * b - (uint64_t) (1.0L * a / p * b + 0.5L) * p;
	cout << (c < uint64_t(p) ? c : c + p);
}
```

这种方法比 `__int128` 的常数更小。因为 `__int128` 本质上是两个 64 位整数拼起来的，对 $p$ 取模的时间消耗很大。实际上在不固定模数的情况下还有更快的 Barrett 约减等方法，这里不展开说明。

### *1.2.2 光速幂

若我们要多次询问 $a^b \bmod p$，且 $a,p$ 是常数，则可以在 $O(\sqrt{p})$ 时间内进行预处理并实现 $O(1)$ 查询。

设 $b=ks+t$，其中 $s \ge t$。可以预处理出 $a^s,a^{2s},a^{3s},\cdots,a^{\lceil \frac{p}{s} \rceil \times s}$ 和 $a^1,a^2,a^3,\cdots a^s$。记 $f_i=a^{is}, g_i=a^i$，于是 $a^b=a^{ks+t}=a^{ks} \times a^t=f_k g_t$。当 $s$ 取 $\sqrt{p}$ 时，时间复杂度最小，为 $O(\sqrt{p})$。

使用光速幂的时候多半是为了查询快，那么求出 $k,t$ 如果需要取模常数就很大。此时取 $s=65536$ 可以用位运算避免取模。

```cpp
struct FastPow {
	int p, f[65536], g[65536];
	FastPow(int a, const int mod) : p(mod) {
		f[0] = g[0] = 1;
		for (int i = 1; i < 65536; i++) f[i] = 1LL * f[i - 1] * a % p;
		int x = 1LL * f[65535] * a % p;
		for (int i = 1; i < 65536; i++) g[i] = 1LL * g[i - 1] * x % p;
	}
	int operator() (int b) const {return 1LL * f[b & 65535] * g[b >> 16] % p;}
};
```

## 1.3 乘法逆元

逆元就是模意义下的倒数：$a$ 的逆元定义为 $\dfrac{1}{a} \equiv x \pmod p$ 的解。根据同乘性，得到 $ax \equiv 1 \pmod p$。

不加证明地，给出结论：$a$ 在模 $p$ 意义下有逆元当且仅当 $a,p$ 互质。若 $b$ 有逆元，那么 $\dfrac{a}{b}\bmod p$ 就可以计算了。下面给出一些求逆元的方法。

### 1.3.1 费马小定理法

- 优点：复杂度 $O(\log p)$，编写简单。
- 缺点：仅适用于 $p$ 为质数。

在下文 5.1 部分介绍。这里不加证明地给出结论：若 $p$ 为质数，$a^{-1} \equiv a^{p-2} \pmod p$，可以快速幂求解。

### 1.3.2 exGCD 法

- 优点：复杂度 $O(\log a)$，编写比较简单。只要 $a$ 有逆元就可以求出。
- 缺点：复杂度有时不能带 $\log$，需要处理负数取模。

在下文 3.2.3 部分介绍。

### 1.3.3 线性正推法

- 优点：预处理复杂度 $O(n)$，查询速度快。
- 缺点：仅适用于对 $1,2,3,\cdots,n$ 求逆元的情况，仅适用于 $p$ 为质数。

考虑如何对 $i=1,2,3,\cdots,n$ 求逆元。首先 $1^{-1} \equiv 1 \pmod p$，接着写出取模的定义式：

$p=i \times \lfloor \dfrac{p}{i} \rfloor+p\bmod i$写成同余式：

$i \times \lfloor \dfrac{p}{i} \rfloor+p\bmod i \equiv 0 \pmod p$因为 $p$ 是质数，可以在同余式两边同乘 $i^{-1}(p \bmod i)^{-1}$，得到：

$(p\bmod i)^{-1}\times \lfloor \dfrac{p}{i} \rfloor +i^{-1} \equiv 0 \pmod p$移项：

$i^{-1} \equiv -(p\bmod i)^{-1}\times \lfloor \dfrac{p}{i} \rfloor \pmod p$根据余数性质，$p \bmod i < i$，那么就可以递推计算了。复杂度 $O(n)$。

```cpp
long long inv[N];
void solve() {
	inv[1] = 1;
	for (int i = 2; i <= n; i++) inv[i] = (p - p / i) * inv[p % i] % p;
}
```

根据这个递推式，还有一种做法是先预处理较小数据的逆元，然后根据递推式递归，如下：

```cpp
long long minv(int i) {return i < N ? inv[i] : (p - p / i) * minv(p % i) % p;}
```

这种做法的时间复杂度目前尚不明确，但实际表现良好。在[知乎回答](https://www.zhihu.com/question/59033693/answer/323292359)中，有大佬给出了该方法的上界 $O(n^{1/3 + \varepsilon})$ 和下界 $O\left( {\ln n \over \ln \ln n} \right)$，并且给出了估计 $O(\log p)$。

### 1.3.4 离线倒推法

- 优点：预处理复杂度 $O(n)$，查询速度快。
- 缺点：仅适用于离线情况下。

事实上，如果给出了任意 $n$ 个与 $p$ 互质的数 $a_1,a_2,a_3,\cdots,a_n$，则可以在 $O(n+\log p)$ 内求出它们的逆元。

记 $a_i$ 的前缀积 $s_i=s_{i-1}a_i \bmod p$。可发现 $s_i$ 与 $p$ 互质。于是计算出 ${s_n}^{-1}$ 后，倒推出每个 $s_i$ 的逆元：

${s_{i-1}}^{-1}={a_i}{s_i}^{-1} \bmod p$因此单个 $a_i$ 的逆元有

${a_i}^{-1}=s_{i-1}{s_i}^{-1} \bmod p$可以做到 $O(n+\log p)$。由于需要乘法和两次递推，常数比线性递推略大。这种方法常用于求阶乘的逆元。

## 1.4 Modint

根据上述方法，我们可以编写一个自动取模工具 `mod32`。下文中，它以 `modint` 或 `mint` 的别名出现。

```cpp
template <const int mod>
struct mod32 {
	static_assert((static_cast<long long>(mod)<<1)<=INT_MAX);

	int val;
	explicit operator int() const {return val;}
	static constexpr int norm(int x) {return x<0?x+mod:x;}
	static constexpr int get_mod() {return mod;}
	mod32():val(0){}
	mod32(int m):val(norm(m)){}
	mod32(long long m):val(norm(m%mod)){}
	mod32<mod> operator- () const {return -val;}
	bool operator== (const mod32<mod>& x) const {return val==x.val;}
	bool operator!= (const mod32<mod>& x) const {return val!=x.val;}
	bool operator< (const mod32<mod>& x) const {return val<x.val;}
	bool operator<= (const mod32<mod>& x) const {return val<=x.val;}
	bool operator> (const mod32<mod>& x) const {return val>x.val;}
	bool operator>= (const mod32<mod>& x) const {return val>=x.val;}
	mod32<mod>& operator+= (const mod32<mod>& x)
	{return val=(val+x.val>=mod?val+x.val-mod:val+x.val),*this;}
	mod32<mod>& operator-= (const mod32<mod>& x)
	{return val=(val-x.val<0?val-x.val+mod:val-x.val),*this;}
	mod32<mod>& operator*= (const mod32<mod>& x)
	{return val=(static_cast<unsigned long long>(val)*x.val%mod),*this;}
	mod32<mod> pow(long long b) const
	{mod32<mod> a(*this),res(1);for(;b;a*=a,b>>=1)if(b&1)res*=a;return res;}
//	static void exgcd(long long a,long long b,long long& x,long long& y) {b==0?(x=1,y=0):(exgcd(b,a%b,y,x),y-=a/b*x);}
//	mod32<mod> operator~ () const {long long a,b;return exgcd(val,mod,a,b),a;}
	mod32<mod> operator~ () const {return pow(mod-2);}
	mod32<mod>& operator/= (const mod32<mod>& x) {return *this*=~x;}
	mod32<mod> operator+ (const mod32<mod>& x) const
	{return mod32<mod>(*this)+=x;}
	mod32<mod> operator- (const mod32<mod>& x) const
	{return mod32<mod>(*this)-=x;}
	mod32<mod> operator* (const mod32<mod>& x) const
	{return mod32<mod>(*this)*=x;}
	mod32<mod> operator/ (const mod32<mod>& x) const
	{return mod32<mod>(*this)/=x;}
	friend std::istream& operator>> (std::istream& in, mod32<mod>& x)
	{long long v;return in>>v,x.val=norm(v%mod),in;}
	friend std::ostream& operator<< (std::ostream& out, const mod32<mod>& x)
	{return out<<x.val;}
};
using mod998244353 = mod32<998244353>;
using mod1000000007 = mod32<1000000007>;
```

这份代码用到了快速幂、exGCD 求逆元、费马小定理求逆元等方法，将在文中一一介绍。需要注意的是，在加减时使用 `a+b>=p?a+b-p:a+b` 的写法比 `(a+b)%p` 的写法常数要小的多。

这是一个[不固定模数的 Modint 模板](https://www.luogu.me/paste/wjbw3x3r)。

## 1.5 例题

### [模拟赛] 小学算术

> 求 $\dfrac{a}{b}$ 在 $c$ 进制表示下小数点后的第 $d$ 位。
>
> 多测，$T \le 10^5$，$1 \le a,b,c,d \le 10^9$。

类比十进制下的思考方法，你可以发现所求是 $\lfloor \dfrac{ac^d}{b}\rfloor \bmod c$。

直接做需要高精度。推式子：

$$
\begin{aligned}
\lfloor \dfrac{ac^d}{b}\rfloor \bmod c&=\lfloor \dfrac{ac^d \bmod {bc}}{b}\rfloor \bmod c\\
&=\lfloor \dfrac{(ac^{d-1}\bmod {b}) c}{b}\rfloor \bmod c
\end{aligned}
$$

快速幂解决即可。

### AT_abc146_e [ABC146E] Rem of Sum is Num

很好的同余性质题。先对 $a_i$ 作前缀和，记作 $p_i$，则原条件为

$(p_{r}-p_{l-1})\bmod k = r-l+1$根据余数的性质，等号两边都小于 $k$，因而

$p_{r}-p_{l-1} \equiv r-l+1 \pmod k$因为同余有同加同减性，可以移项，得

$p_r-r\equiv p_{l-1}-(l-1) \pmod k$所以把 $p_i$ 减去 $i$ 对 $k$ 取模，然后用哈希表统计即可。注意删掉超出范围的点，以及负数取模。复杂度 $O(n)$。

```cpp
const int N = 2e5 + 5;
long long n, k, a[N];

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[i], a[i] += a[i - 1];
	long long cnt = 0;
	for (int i = 0; i <= n; i++) a[i] = ((a[i] % k - i) % k + k) % k;
	unordered_map<int, int> mp;
	for (int i = 0; i <= n; i++) {
		if (i >= k) mp[a[i - k]]--;
		cnt += mp[a[i]], mp[a[i]]++;
	} cout << cnt;
}
```

### P1154 奶牛分厩

暴力的做法是枚举 $k$，然后 $O(n)$ 验证，$O(nk)$ 无法通过。

形式化一下题意，题意即为 $\nexists a,b \in S, a \equiv b \pmod p$。根据同余的差性质，等价为 $\nexists i \in \mathbb{N}^+, pi \mid (a-b)$。所以考虑 $O(n^2)$ 求出所有 $s_i-s_j$ 并标记。

仍然暴力枚举 $k$，再枚举 $k$ 的倍数 $ik$，只要判断 $ik$ 是否标记即可。复杂度 $O(n^2 + k \log k)$ 可以通过。

```cpp
const int N = 5e3 + 5, M = 1e6 + 5;
int n, a[N];
bool tag[M << 1];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) {
		for (int j = i + 1; j <= n; j++) tag[abs(a[i] - a[j])] = true;
	}
	for (int i = 1; i < M; i++) {
		if (tag[i]) continue;
		bool flag = true;
		for (int j = i; j < M; j += i) {
			if (tag[j]) {flag = false; break;}
		}
		if (flag) return cout << i, void();
	}
}
```

### AT_abc357_d [ABC357D] 88888888

介绍三种做法。法一：设 $d$ 为 $n$ 的位数，则 $v(n)$ 可以看作一个 $10^d$ 进制数，根据等比数列求和：

$$
\begin{aligned}
v(n)&=\sum_{i=0}^{n-1} n\times (10^d)^i\\
&=n \sum_{i=0}^{n-1} (10^d)^i\\
&=n \times \dfrac{(10^d)^n-1}{10^d-1}
\end{aligned}
$$

求个逆元，写个快速幂即可。复杂度 $O(\log n)$。

```cpp
using ull = unsigned long long;
ull n;
const ull mod = 998244353;
ull power(ull a, ull b) {
	ull res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

void _main() {
	cin >> n;
	ull b = 1;
	while (b <= n) b *= 10;
	cout << n % mod * (power(b, n) - 1) % mod * power(b - 1, mod - 2) % mod;
}
```

法二：如果 $10^d-1$ 没有逆元，一个想法就是广义快速幂。定义 $a \times a$ 表示将 $a$ 和 $a$ 首尾拼接所得的数，求出 $a^n$ 即可。复杂度 $O(\log^2 n)$。

法三：使用广义快速幂进行等比数列求和，移步下文 7.1.2 分治求和法。也可以解决没有逆元的情况，复杂度 $O(\log^ 2n)$。

### AT_abc367_e [ABC367E] Permute K times

首先这个题可以直接倍增，可以看笔者之前的[题解](https://www.luogu.com.cn/article/gyi8yr80)。

将题目中的一次变换定义为两个序列之间的乘法。可以发现，这种乘法没有交换律，但是有结合律，可以广义快速幂求解。复杂度 $O(n \log k)$。事实上，这种乘法就是置换的概念。

```cpp
const int N = 2e5 + 5
int n, a[N], p[N], b[N];
long long k;
void mul(int *a) {
	for (int i = 1; i <= n; i++) b[i] = a[p[i]];
	copy(b + 1, b + n + 1, a + 1);
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> p[i];
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (; k; k >>= 1) {
		if (k & 1) mul(a);
		mul(p);
	}
	for (int i = 1; i <= n; i++) cout << a[i] << ' ';
}
```$AKB285$, '数学', array['同余', '快速幂', '乘法逆元', 'Modint'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-counting-misc--stripe-python', '计数杂项：排列计数与图论计数 · stripe-python', $AKB286$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 17. 计数杂项

## 17.1 排列计数

排列计数问题往往需要设计一个计数 DP。这类题目的 DP 状态一般设 $dp_{i, \cdots}$ 表示当前需要放入第 $i$ 个数的方案数，然后根据需要添加维度。在转移时，往往要从**插入 / 填入**角度分类讨论 $i$ 带来的贡献，并根据乘法或加法原理合并答案。

## 17.2 图论计数

图论计数问题一般是对特定的图结构进行计数。在计数时，最关键的要求是找到目标图的特定结构进行刻画。如果刻画比较困难，可以考虑弱一些的条件然后使用容斥解决。一些题目还要配合子集反演、二项式反演、集合幂级数、多项式科技等。下面是一些图论计数的结论。

## 17.3 例题

前半部分是排列计数，后半部分是图论计数。

### P2401 不等数列

观察数据范围可以发现是一个 $O(nk)$ 的 dp，设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个小于号的方案数。分类讨论：

1. 若放在最左边，会多一个大于号，从 $dp_{i-1,j}$ 转移；
2. 若放在最右边，会多一个小于号，从 $dp_{i-1,j-1}$ 转移；
3. 若插入到小于号之前，因为数字 $i$ 是最大的，所以小于号变为大于号，而前面是一个小于号，因此是多了一个大于号，从 $j \times dp_{i-1,j}$ 转移；
4. 若插入到大于号之前，同理可得转移为 $(i-j-1) \times dp_{i-1,j-1}$。

由加法原理得：

$dp_{i,j}=(j+1) \times  dp_{i-1,j} +(i-j) \times dp_{i-1,j-1}$至此本题在 $O(nk)$ 内解决。边界为 $dp_{i,0}=1$。

```cpp
const int N = 1005;
int n, k;
mint dp[N][N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	for (int i = 2; i <= n; i++) {
		dp[i][0] = 1;
		for (int j = 1; j <= min(i, k); j++) {
			dp[i][j] = dp[i - 1][j] * (j + 1) + dp[i - 1][j - 1] * (i - j);
		}
	} cout << dp[n][k];
}
```

### P6323 [COCI 2006/2007 #4] ZBRKA

还是设 $dp_{i,j}$ 表示当前需要放入数字 $i$，有 $j$ 个逆序对的方案数。考虑插入在 $i-1$ 的全排列中插入 $i$ ，枚举增加了多少逆序对 $k$，则有

$dp_{i,j} = \sum_{k=0}^{\min(i-1,j)} dp_{i-1,j-k}$直接做是 $O(nk^2)$ 的。注意到 $dp_{i,j}$ 为同一行 $dp_{i-1}$ 连续区间的和，用前缀和优化即可。考虑求 $j-k$ 的范围，发现 $j-k \in [\max(0, j-i+1), j]$。边界是 $dp_{i,0}=1$。

```cpp
const int N = 1e3 + 5;
int n, k;
mint dp[N][10005], pre[N];

void _main() {
	cin >> n >> k;
	dp[1][0] = 1;
	fill(pre + 1, pre + k + 2, 1);
	for (int i = 2; i <= n; i++) {
		for (int j = 1; j <= k; j++) dp[i][j] = pre[j + 1] - pre[max(0, j - i + 1)];
		pre[0] = 0;
		for (int j = 1; j <= k; j++) pre[j + 1] = pre[j] + dp[i][j];
	}
	cout << dp[n][k];
}
```

三倍经验：[P1521](https://www.luogu.com.cn/problem/P1521)、[P2513](https://www.luogu.com.cn/problem/P2513)。

### *P7967 [COCI 2021/2022 #2] Magneti

好像这种问题叫做连续段 dp。

DP 题套路先对 $r_i$ 排序简化问题。仍然设 $dp_{i,\cdots}$ 表示当前需要放入第 $i$ 个磁铁的方案数。考虑加维，经过尝试发现空位要是单独一维，连通块也是单独一维。这里的连通块是一个不能再插入磁铁的磁铁连续段。因此，设 $dp_{i,j,k}$ 表示当前需要放入第 $i$ 个磁铁，分成 $j$ 个连通块，占用掉 $k$ 个空位的方案数。

考虑插入 $i$ 并分类讨论：

1. 若第 $i$ 个磁铁单独成为新的块，则从 $dp_{i-1,j-1,k-1}$ 转移；
2. 若第 $i$ 个磁铁放在第 $j$ 个连通块端点，则从 $2j \times dp_{i-1,j,k-r_i}$ 转移。
3. 若第 $i$ 个磁铁将两个连通块合并为一个，则从 $j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$ 转移。

于是状态转移方程为：

$dp_{i,j,k}=dp_{i-1,j-1,k-1}+2j \times dp_{i-1,j,k-r_i}+j(j+1) \times dp_{i-1,j+1, k-2r_i+1}$由此可以求出所有磁铁只形成一个连通块且长度为 $i$ 的方案数 $dp_{n,1,i}$，则根据插板法，将 $l-i$ 个空插到连通块中，答案为

$\sum_{i=1}^{l} dp_{n,1,i} \times C_{l-i+n}^{n}$时空 $O(n^2l)$，使用逆元法求组合数。边界为 $dp_{0,0,0}=1$。

```cpp
const int N = 1e4 + 5;
mint fac[N], ifac[N], dp[55][55][N];

mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

int n, l, r[N];

void _main() {
	fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
	for (int i = 2; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	cin >> n >> l;
	for (int i = 1; i <= n; i++) cin >> r[i];
	sort(r + 1, r + n + 1);
	dp[0][0][0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= l; k++) {
				dp[i][j][k] = dp[i - 1][j - 1][k - 1];
				if (k >= r[i]) dp[i][j][k] += dp[i - 1][j][k - r[i]] * 2 * j;
				if (k >= 2 * r[i] - 1) dp[i][j][k] += dp[i - 1][j + 1][k - 2 * r[i] + 1] * j * (j + 1);
			}
		}
	}
	mint res = 0;
	for (int i = 1; i <= l; i++) res += dp[n][1][i] * C(l - i + n, n);
	cout << res;
}
```

### *AT_code_festival_2017_qualc_f Three Gluttons

思路来自[第一篇题解](https://www.luogu.com.cn/article/8v8z4sbf)。

显然题目中所给的限制没有什么性质，考虑找到一个充要条件对其进行刻画然后计数 DP。

时光倒流，如果 A, B, C 三人最后选择的是 $x_1,y_1,z_1$，只有 $[z_1,x_1,y_1]$ 和 $[z_1,y_1,x_1]$ 符合要求，因为 C 必须先选走 $z_1$，选法为 $1 \times 2 = 2$ 种。

反推一次，如果选择变成了 $x_2,y_2,z_2$，$z_2$ 必须被 C 先选择，则根据乘法原理，$x_2,y_2$ 的选法为 $4 \times 5=20$ 种。

数学归纳法，当反推到第 $i$ 次时的方案数为 $(3i-2)(3i-1)$。因此，对于一个合法排列，对应选择序列的方案数为

$\prod_{i=1}^n (3i-2)(3i-1)$因此，我们只要找到合法排列的数目，乘上这个东西得到答案即可。对于已知的 $a,b,c$ 三个排列，我们这样刻画合法的充要条件：

- $a,b,c$ 内部元素不重，$\forall i$，$a_{i_t},b_{j_t},c_{k_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\} \cup \{c_1 \sim c_{k_t}\}$ 出现且仅出现一次。

因为 $c$ 未知，假如对 C 的选择序列 $x$ 有办法计数，那么只要发现 $c$ 与 $x$ 的映射关系就可以对排列计数。可以得到 $\exists c, c \to x$ 的充要条件是：

- $x$ 元素不重，$a_{i_t},b_{j_t}$ 均只在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现且仅出现一次，$x_t$ 未在 $\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$ 出现。

设当前为第 $t$ 位，不能成为 $x_t$ 的数有：

- $u \in [t+1,n]$ 的 $a_{i_u},b_{j_u},c_{k_u}$。
- $x \in \{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}$。

容易发现这两个集合无交集，剩下 $3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$ 个数均能填入其中。

考虑排列计数 DP，设 $dp_{t,i,j}$ 表示 $i_t=i, j_t=j$ 的方案数，从填入角度考虑 $t$ 位置的贡献即可。转移方程形如

$dp_{t,i,j}=\sum_{i'<i,j'<j} dp_{t-1,i',j'} \times (3t-|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|)$直接转移复杂度 $O(n^6)$。

注意到不合法的数目可以预处理出来，设 $x_{i,j}=|\{a_1 \sim a_{i_t}\} \cup \{b_1 \sim b_{j_t}\}|$，对 $x_i$ 作前缀和可以直接查询。复杂度 $O(n^4)$。

注意到每次转移形如一个矩形求和，考虑动态地对 $dp_{i,j}$ 作二维前缀和。复杂度 $O(n^3)$。

```cpp
const int N = 405;
int n, a[N], b[N], x[N][N];
mint dp[N][N][N];
bool vis[N], va[N][N], vb[N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	for (int i = 1; i <= n; i++) {
		vis[a[i]] = true, x[i][0] = i;
		for (int j = 1; j <= n; j++) x[i][j] = x[i][j - 1] + !vis[b[j]];
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= i; j++) va[i][a[j]] = true, vb[i][b[j]] = true;
	}
	for (int i = 0; i <= n; i++) fill(dp[0][i], dp[0][i] + n + 1, 1);
	for (int t = 1; t <= n / 3; t++) {
		for (int i = t; i <= n; i++) {
			for (int j = t; j <= n; j++) {
				if (!va[i][b[j]] && !vb[j][a[i]]) dp[t][i][j] = dp[t - 1][i - 1][j - 1] * (3 * t - x[i][j]);
				dp[t][i][j] += dp[t][i - 1][j] + dp[t][i][j - 1] - dp[t][i - 1][j - 1];
			}
		}
	}
	mint res = dp[n / 3][n][n];
	for (int i = 1; i <= n / 3; i++) res *= (3 * i - 2) * (3 * i - 1);
	cout << res;
}
```

### CF11D A Simple Task

无向图简单环计数。

注意到 $n \le 19$，考虑状压 DP。设 $dp_{S,u}$ 表示当前经过了 $S$ 中的点，$u$ 为当前位置时的路径条数。

直接做会算重。考虑使用[串珠子](https://www.luogu.com.cn/problem/P5933)的 trick，钦定起点为当前走过的点中编号最小的点。体现在二进制中就是 $s=\operatorname{lowbit}(S)$。枚举 $u \to v$ 边，如果 $v$ 比 $S$ 中最小点还小则不合法。否则分类讨论：

- 若 $v \notin S$，直接转移：$dp_{S \cup \{v\},v} \gets dp_{S,u}$。
- 若 $v \in S$ 且 $v=\operatorname{lowbit}(S)$，则构成一个环，答案加上 $dp_{S,u}$。
- 否则，$v$ 对当前状态无贡献。

特别注意，这样计数会算上重边构成的二元环，还会把多元环算两次，最后的答案应该是 $\dfrac{ans-m}{2}$。复杂度 $O(n^22^n)$。

```cpp
const int N = 20;
int n, m, u, v, g[N][N];
long long f[N][1 << N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		g[u][v] = g[v][u] = 1;
	}
	for (int i = 1; i <= n; i++) f[i][1 << (i - 1)] = 1;
	long long res = 0;
	for (int s = 1; s < (1 << n); s++) {
		for (int u = 1; u <= n; u++) {
			if (!(s >> (u - 1) & 1)) continue;
			for (int v = 1; v <= n; v++) {
				if (!g[u][v]) continue;
				if ((s & -s) > (1 << (v - 1))) continue;
				if (s >> (v - 1) & 1) {
					if ((s & -s) == (1 << (v - 1))) res += f[u][s];
				} else {
					f[v][s | (1 << (v - 1))] += f[u][s];
				}
			}
		}
	}
	cout << (res - m) / 2;
}
```

### P1989 无向图三元环计数

传统做法是将点重标号为 $p_1,p_2,p_3,\cdots,p_n$，满足 $d_x <d_y \Leftrightarrow p_x<p_y$，其中 $d$ 为度数。

此时有一个重要的性质：$\forall u \to v$，满足 $p_y >p_x$ 的点至多只有 $\sqrt{2m}$ 条。证明考虑反证，若超过 $\sqrt{2m}$，则出点度数均 $>\sqrt{2m}$，总度数大于 $\sqrt{2m}$，与握手定理矛盾。

重定向，仅保留 $p_x<p_y$ 的 $(u,v)$变成有向边。则可以直接枚举并计数：枚举 $u$，将 $u$ 的出点打上标记，再枚举所有打上标记的点 $v$ 的所有出点 $w$，若 $w$ 也被标记，则发现三元环 $(u,v,w)$。

复杂度 $O(m\sqrt{m})$，并且可以发现三元环的数目上界为 $O(m\sqrt{m})$ 级别。

```cpp
const int N = 1e5 + 5;
int n, m, deg[N], tag[N];
pair<int, int> e[N << 1];
vector<int> g[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) cin >> e[i], deg[e[i].first]++, deg[e[i].second]++;
	auto f = [&](int x, int y) -> bool {return deg[x] == deg[y] ? x < y : deg[x] < deg[y];};
	for (int i = 1; i <= m; i++) {
		if (f(e[i].first, e[i].second)) g[e[i].first].emplace_back(e[i].second);
		else g[e[i].second].emplace_back(e[i].first);
	}
	int res = 0;
	for (int u = 1; u <= n; u++){
		for (int v : g[u]) tag[v] = u;
		for (int v : g[u]) {
			for (int w : g[v]) res += tag[w] == u;
		}
	} cout << res;
}
```

### P10982 Connected Graph

考虑高维容斥，设 $g_n$ 为 $n$ 个点有标号图的方案数，$f_n$ 为有标号且连通的方案数。

因为 $n$ 个点的图最多有 $C_{n}^2$ 条边，每条边都可以选与不选，所以

$g_n=2^{C_n^2}$考虑如何刻画连通图的性质。钦定一个节点，枚举其所属连通块的大小 $i$，从剩下 $n-1$ 个点选择 $i-1$ 个组成一个新连通块。于是

$f_n=g_n-\sum_{i=1}^{n-1} C_{n-1}^{i-1} f_i g_{n-i}$复杂度 $O(n^2)$。可以多项式科技优化到 $O(n \log^2 n)$。

```cpp
const int N = 1005;
int n;
mint f[N + 5], g[N + 5], fac[N + 5], ifac[N + 5];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}

void _main() {
	cin >> n;
	fac[0] = ifac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 1; i <= n; i++) g[i] = mint(2).pow(C(i, 2).val);
	f[1] = 1;
	for (int i = 2; i <= n; i++) {
		f[i] = g[i];
		for (int j = 1; j < i; j++) f[i] -= C(i - 1, j - 1) * f[j] * g[i - j];
	} cout << f[n];
}
```

### *P6596 How Many of Them

tourist 的神仙题。前置知识：无向图连通性的有关概念和定理。以下是蓝书做法。

设 $f_{i,j}$ 表示点数为 $i$，割边数为 $j$ 的无向连通图数目。

考虑枚举 $1$ 号点所在的边双连通分量的大小 $k$。从 $i-1$ 个节点中选出 $k$ 个构成边双，方案数是 $f_{k,0} \times C_{i-1}^{k-1}$ 乘上其他部分的贡献。

设 $g_{i,j,k}$ 表示点数为 $i$，割边数为 $j$，有 $k$ 个连通块的无向图数目。则对于 $f_{i,j}$，去掉边双以后剩下 $g_{i-k,j-x,x}$ 的贡献，其中 $x$ 是枚举的量，表示剩下的图中被分成了 $x$ 个连通块。每个连通块与边双形成 $x$ 条割边，所以还需要凑出 $j-x$ 条割边。由于这个边双有 $k$ 个点，每个节点都有 $k$ 种选择，贡献还要乘上 $k^x$。因此

$f_{i,j}=\sum_{k=1}^{i-1} \left( f_{k,0} C_{i-1}^{k-1}\sum_{x=1}^{\min(i-k,j)} g_{i-k,j-x,x}k^x \right)$记 $h_i$ 表示点数为 $i$ 的无向连通图数目。用上一题的转移求出以后，作一个高维容斥得到

$f_{i,0}=h_i-\sum_{j=1}^{i-1} f_{i,j}$考虑 $g_{i,j,k}$ 的转移。为了取重，钦定标号最小点属于一个连通块，然后枚举该连通块的大小 $p$，割边数目 $q$。乘上选法，贡献为 $f_{p,q} C_{i-1}^{p-1}$。再从连通块中找到一个节点连向边双，有 $p$ 种方案。最后讨论图中其他部分，得到 $g_{i-p,j-q,k-1}$。最终得到转移：

$g_{i,j,k}=\sum_{p=1}^i \sum_{q=0}^j f_{p,q} C_{i-1}^{p-1} p g_{i-p,j-q,k-1}$注意到 $n$ 个点的图最多 $n-1$ 条割边，所以 $m$ 实际上与 $n$ 同阶。总复杂度 $O(n^4)$。

由于本题的转移太过复杂，本人试图对 $f,g$ 都记搜转移，但写挂了。于是用了题解里仅记搜 $g$ 的写法。

```cpp
const int N = 55;
int n, m;
mint fac[N], ifac[N], f[N][N], g[N][N][N], h[N];
mint C(int n, int m) {return n < m ? 0 : fac[n] * ifac[m] * ifac[n - m];}
mint G(int i, int j, int k) {
	if (k > i || (i != 0 && k == 0)) return g[i][j][k] = 0;
	if (g[i][j][k] != -1) return g[i][j][k];
	g[i][j][k] = 0;
	for (int p = 1; p <= i; p++) {
		for (int q = 0; q <= j; q++) {
			g[i][j][k] += f[p][q] * C(i - 1, p - 1) * p * G(i - p, j - q, k - 1);
		}
	} return g[i][j][k];
}

void _main() {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) fill(g[i][j], g[i][j] + N, -1);
	}
	cin >> n >> m;
	m = min(n, m);
	fac[0] = ifac[0] = 1, h[1] = 1, f[0][0] = 1, g[0][0][0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i <= n; i++) {
		h[i] = mint(2).pow(C(i, 2).val);
		for (int j = 1; j < i; j++) h[i] -= C(i - 1, j - 1) * h[j] * mint(2).pow(C(i - j, 2).val);
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j < i; j++) {
			for (int k = 1; k < i; k++) {
				mint sum = 0;
				for (int x = 1; x <= min(i - k, j); x++) sum += G(i - k, j - x, x) * mint(k).pow(x);
				f[i][j] += f[k][0] * C(i - 1, k - 1) * sum;
			}
		}
		f[i][0] = h[i];
		for (int j = 1; j < i; j++) f[i][0] -= f[i][j];
	}
	mint res = 0;
	for (int i = 0; i <= m; i++) res += f[n][i];
	cout << res;
}
```

### [模拟赛] 竞赛图

> 给你一个 $n$ 个点的竞赛图，求有多少个点的子集 $S$ 满足 $S$ 的诱导子图是强连通的。答案包括空集。
>
> > 竞赛图是一个有向图，满足任意两个不同的点之间均存在且仅存在一条有向边相连。
> >
> > 一个图在点集 $S$ 的诱导子图的定义为：点集为 $S$，边集为所有两端的点都在 $S$ 中的边的子图。
>
> 多测，$n \le 24$，$T \le 10$。

暴力 Tarjan 可以做到单次 $O(n^22^n)$，和我一样没有前途。

根据竞赛图的性质，将一个强连通分量 $S$ 提出来后，$S$ 的补集与 $S$ 只存在内向边。

直接想状压。考虑类似刷表的做法，用强连通子集 $S$ 去转移其他自己，设出边集合的**交集**为 $E$，对于每个 $T \subseteq E$，$S \cup B$ 中来自 $B$ 的部分一定不强联通，将其标记即可。类似筛法，未被标记的都是强连通子集。

单次复杂度 $O(2^n)$，可以通过。

```cpp
const int N = 24;
int n, a[N], b[1 << N];
bitset<1 << N> vis;

void _main() {
	cin >> n;
	for (int i = 0; i < n; i++) {
		a[i] = 0;
		for (int j = 0, x; j < n; j++) {
			cin >> x;
			if (x) a[i] |= 1 << j;
		}
	}
	vis.reset(), b[0] = (1 << n) - 1;
	int res = 1;
	for (int s = 1; s < (1 << n); s++) {
		b[s] = b[s ^ lowbit(s)] & a[ctz(s)];
		if (vis[s]) continue;
		res++;
		for (int t = b[s]; t; t = (t - 1) & b[s]) vis[s | t] = 1;
	}
	cout << res << '\n';
}
```

### *P3349 [ZJOI2016] 小星星

子集反演例题。

考虑普通状压 DP，设 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号的集合为 $S$ 的方案数。可以得到转移

$dp_{u,i,S}=\prod_{(u,v)} \sum_{(i,j)} \sum_{T \subseteq S} dp_{v,j,T}$复杂度 $O(n^33^n)$，无法通过。注意到我们必须去掉 $T \subseteq S$ 的部分。

复杂度瓶颈在去重。因此，设 $f(S)$ 表示 $n$ 个点的映射恰好使用 $S$ 中所有点的方案数，$g(S)$ 表示 $n$ 个点的映射至多使用 $S$ 中所有点的方案数，显然 $g(S)=\sum_{T \subseteq S} f(T)$，由子集反演形式一

$f(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} g(T)$答案即 $f(U)$。只需对 $g(S)$ 计数即可。

用 $dp_{u,i,S}$ 表示将 $u$ 节点映射到 $i$ 节点，$u$ 子树内部使用的节点编号至多使用 $S$ 中所有点的方案数，允许重复。在这个组合意义下，无需枚举子集就有

$dp_{u,i,S}=\prod_{(u,v), u,v \in S} \sum_{(i,j),i,j \in S} dp_{v,j,S}$于是 $g(S)=\sum_{i \in S} dp_{1,i,S}$。复杂度 $O(n^32^n)$。

细节上，这题答案没有取模，可以对 $2^{64}$ 取模，即 unsigned long long 自然溢出。

```cpp
const int N = 18;

int n, m, u, v, a[N][N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
uint64_t dp[N][N];
void dfs(int u, int fa, int s) {
	for (int i = 1; i <= n; i++) {
		if (s >> (i - 1) & 1) dp[u][i] = 1;
	}
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u, s);
		for (int x = 1; x <= n; x++) {
			if (!(s >> (x - 1) & 1)) continue;
			uint64_t cur = 0;
			for (int y = 1; y <= n; y++) {
				if (!(s >> (y - 1) & 1)) continue;
				if (a[x][y]) cur += dp[v][y];
			}
			dp[u][x] *= cur;
		}
	}
}

void _main() {
	cin >> n >> m;
	if (n == 1) return cout << 1, void();
	for (int i = 1; i <= m; i++) cin >> u >> v, a[u][v] = a[v][u] = 1;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	uint64_t res = 0;
	for (int s = 0; s < (1 << n); s++) {
		dfs(1, -1, s);
		uint64_t cur = 0;
		for (int i = 1; i <= n; i++) {
			if (s >> (i - 1) & 1) cur += dp[1][i];
		}
		res += ((n - popcount(s)) & 1) ? -cur : cur;
	} cout << res;
}
```$AKB286$, '数学', array['排列计数', '图论计数', '计数'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-counting-principles--stripe-python', '计数原理：加法与乘法原理 / 抽屉原理 · stripe-python', $AKB287$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 7. 计数原理

常用的计数原理有加法原理、乘法原理、抽屉原理、容斥原理等。容斥在第 8 章单独介绍。

## 7.1 加法 & 乘法原理

- **加法原理**：有 $n$ 类方法，$a_i$ 为第 $i$ 类中方法的数目，则总方法数为 $\sum a_i$。
- **乘法原理**：有 $n$ 个步骤，$a_i$ 为第 $i$ 步中方法的数目，则总方法数为 $\prod a_i$。

这两者的区别是：加法分类，乘法分步。

加法原理有一个推论，即减法原理，就是求满足某种约束的方案数可以用总方案数减去不满足约束的方案数。这是最简单的容斥，是“正难则反”的体现。

## 7.3 抽屉原理

抽屉原理，也称为鸽巢原理。定理如下：

将 $n$ 个物品划分为 $k$ 组，则至少有一组含有大于等于 $\lceil \dfrac{n}{k} \rceil$ 个物品。反证法易证。

## 7.4 例题

这部分还会介绍一些计数 DP 的思想。

### P3197 [HNOI2008] 越狱

由减法原理，可以用总数目减去不会越狱的数目。

本题中，$n$ 个人都有 $m$ 种选择，由乘法原理可得总数目为 $m^n$。接着我们考虑合法方案，第一个位置能放 $m$ 个，而第二个位置在第一位没有选的 $m-1$ 个中选一个，由此递推，可得方案数为 $m(m-1)^{n-1}$。所以所求为 $m^n-m(m-1)^{n-1}$。

### [模拟赛] 鲁的石板

> 上面那题的环上版本。有一个大小为 $n$ 的环，$m$ 种颜色，求相邻点不同色的染色方案数对 $10^9+7$ 取模的结果。
>
> $T$ 次询问。$T \le 10^5$，$n \le 10^9$，$m \le 50$。

赛时整了一个抽象的高维容斥 + 等比数列求和 + 分类讨论做法过了，喜提 AK。下面来讲一种优雅的解法。

序列上的版本答案为 $m(m-1)^{n-1}$。记 $f_i$ 为环的大小为 $i$ 时的方案数，则不合法的方案产生于首尾颜色相同的情况。我们可以把首尾直接合并为一个点，此时这个环相邻颜色均不相同，方案数为 $f_{n-1}$。当首尾颜色不同时，方案数就是 $f_n$。由加法原理得

$f_n+f_{n-1}=m(m-1)^{n-1}$移项后可以做到 $O(n)$ 递推求解。作一些代数变形：

$$
\begin{aligned}
f_n+f_{n-1}&=m(m-1)^{n-1}\\
f_n+f_{n-1}&=(m-1)^{n}+(m-1)^{n-1}\\
f_n-(m-1)^n&=(-1)[f_{n-1}-(m-1)^{n-1}]
\end{aligned}
$$

因此 $f_n-(m-1)^n$ 是第二项为 $m-1$，公比为 $-1$ 的等比数列。由等比数列通项公式得

$f_n-(m-1)^n=(-1)^n({m-1})$移项

$f_n=(-1)^n(m-1)+(m-1)^n$只需要 $O(\log n)$ 求解了。注意特判 $n=1$。

### P8557 炼金术（Alchemy）

对于第 $i$ 个金属，一共有 $2^k$ 种情况，使用减法原理减去没有炼出来的 $1$ 种情况，为 $2^k-1$ 种。这是分步的，乘法原理合并答案，答案为 $(2^k-1)^n$。

### P6075 [JSOI2015] 子集选取

神秘结论题。从特殊到一般，讨论 $n=1$。容易证明此时存在一条上升路径将整个三角形分成全 $\varnothing$ 和全 $\{1\}$ 的两部分。因为每一步有向上和向右两种选择，走 $k$ 步答案为 $2^k$。

类似地，对于一个一般的 $n$，根据题目中所给性质可以发现一共有 $n$ 条路径。因此答案为 $(2^k)^n=2^{kn}$。所以就是个快速幂板子。

### *CF1793D Moscow Gorillas

设排列 $a$ 中 $i$ 出现的位置为 $p_i$，排列 $b$ 中 $i$ 出现的位置为 $q_i$。

考虑枚举 $\operatorname{mex}$，设其为 $m$，只要求出有多少 $l,r$ 使得两个排列的子区间 $\operatorname{mex}$ 为 $m$，则合法的 $[l,r]$ 需要满足 $1,2,3,\cdots,m-1$ 中的数恰好出现一次。设 $s=p_m,t=q_m$，不妨令 $s \le t$。

首先特判 $m=1$。此时区间不能跨过 $s,t$，否则 $\operatorname{mex}$ 一定大于 $1$。在 $[1,s),(s,t),(t,n]$ 中可以选择任意端点，方案数为 $\sum \dfrac{h(h-1)}{2}$，其中 $h$ 是区间长度。

用两个指针维护 $l,r$ 当前最小的 $s$ 和最大的 $t$。左端点必须在 $[1,l]$ 中，右端点必须在 $[r,n]$ 中，才能满足 $1,2,3,\cdots,m-1$ 中的数恰好出现一次这条性质。同时根据定义，合法的区间不能包含 $m$。

接下来分类讨论。

1. 当 $s \in [l,r]$ 或 $t \in [l,r]$ 时，合法区间只能包含 $m$，矛盾。
2. 当 $s,t <l$ 时，在 $[1,l]$ 中存在合法区间，贡献为 $(n-r+1)(l-t)$。因为左端点取在 $(t,l]$ 中，右端点取在 $[r,n]$ 中。
3. 当 $s,t \ge r$ 时，同理可得贡献为 $l(s-r)$。
4. 当 $s<l$ 且 $r<t$ 时，左端点取 $(s,l]$ 中，右端点取 $[r,t)$ 中，贡献为 $(l-s)(t-r)$。

根据加法原理合并答案。复杂度 $O(n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], b[N], p[N], q[N];
long long calc(int len) {return 1LL * len * (len - 1) / 2;}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i], p[a[i]] = i;
	for (int i = 1; i <= n; i++) cin >> b[i], q[b[i]] = i;
	int s = p[1], t = q[1];
	if (s > t) swap(s, t);
	long long res = 0;
	if (1 <= s - 1) res += calc(s);
	if (t + 1 <= n) res += calc(n - t + 1);
	if (s < t) res += calc(t - s);

	int l = s, r = t;
	for (int m = 2; m <= n; m++) {
		s = p[m], t = q[m];
		if (s > t) swap(s, t);
		if ((l <= s && s <= r) || (l <= t && t <= r)) {
			l = min(l, s), r = max(r, t);
			continue;
		}
		if (s < l && t < l) res += 1LL * (n - r + 1) * (l - t);
		if (s > r && t > r) res += 1LL * l * (s - r);
		if (s < l && r < t) res += 1LL * (l - s) * (t - r);
		l = min(l, s), r = max(r, t);
	} cout << res;
}
```

### P8356 「WHOI-1」数列计数

简单计数 DP。设 $dp_{i,j}$ 表示用了 $i$ 次 $+x$，$j$ 次 $+y$ 的数列方案数。加法原理得到转移

$dp_{i,j}=dp_{i-1,j}+dp_{i,j-1}$只需当 $p \mid (ix+jy)$ 时将 $dp_{i,j} \gets 0$ 即可满足约束。答案就是 $\sum_{i+j=n} dp_{i,j}$。

注意到空间炸了，滚动数组优化即可。复杂度 $O(n^2)$。需要特判 $x=y$。

```cpp
const int N = 1e4 + 5;
int n, p, x, y;
mint dp[2][N];

void _main() {
	cin >> n >> p >> x >> y;
	if (x == y) {
		for (int i = 1; i <= n; i++) {
			if (1LL * i * x % p == 0) return cout << 0 << '\n', void();
		} return cout << 1 << '\n', void();
	}
	dp[0][0] = 1;
	mint res = 0;
	for (int i = 0, st = 0; i <= n; i++, st ^= 1) {
		for (int j = 0; i + j <= n; j++) {
			if (i == 0 && j == 0) continue;
			if ((1LL * i * x + 1LL * j * y) % p) dp[st][j] = (i != 0 ? dp[st ^ 1][j] : 0) + (j != 0 ? dp[st][j - 1] : 0);
 			else dp[st][j] = 0;
			if (i + j == n) res += dp[st][j];
		}
	} cout << res << '\n';
}
```

### OpenJudge 9285 盒子与小球之三

推不出来公式，考虑计数 DP。设 $dp_{i,j}$ 表示前 $i$ 个盒子放 $j$ 个球的方案数，由加法原理

$dp_{i,j}=\sum_{x=0}^k dp_{i-1,j-x}$是一个类似背包的东西，复杂度 $O(nmk)$。

注意到 $dp_{i,j}$ 是 $dp_{i-1}$ 上一段连续的和，可以前缀和优化 DP。更仔细的观察可以发现，这段连续和的长度不变，直接维护一个滑动窗口即可。

```cpp
const int N = 5005;
int n, m, k;
mint dp[N][N];

void _main() {
	cin >> n >> m >> k;
	for (int i = 0; i <= m; i++) dp[i][0] = 1;
	for (int i = 1; i <= m; i++) {
		mint sum = i;
		for (int j = 1; j <= n; j++) {
			dp[i][j] = sum, sum += dp[i - 1][j + 1];
			if (j >= k) sum -= dp[i - 1][j - k];
		}
	} cout << dp[m][n];
}
```

### P6146 [USACO20FEB] Help Yourself G

将所有线段按左端点排序。设 $dp_i$ 表示前 $i$ 条线段的子集复杂度之和。

考虑转移，计数 DP 非常常见的套路是从插入角度考虑第 $i$ 条的贡献。显然不选的贡献为 $dp_{i-1}$，只要考虑加入第 $i$ 条的贡献。

由于我们按左端点排好了序，原复杂度单调不降。加入这条线段，会使得某些子集中所有线段与之不交，从而复杂度增加 $1$。设 $[1,i)$ 中有 $x$ 条线段不与第 $i$ 条相交，选择这 $x$ 条的一个子集会使得复杂度加一。根据加法原理：

$dp_i=dp_{i-1}+(dp_{i-1}+2^x)=2 \times dp_{i-1}+2^{x}$对值域作前缀和，预处理一下每个位置的 $x$ 即可。复杂度可以做到 $O(n)$。

```cpp
const int N = 1e5 + 5;
int n, x[N << 1];
struct node {
	int l, r;
} a[N];
mint dp[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i].l >> a[i].r;
	sort(a + 1, a + n + 1, [](const node& a, const node& b) -> bool {
		return a.l < b.l;
	});
	for (int i = 1; i <= n; i++) x[a[i].r]++;
	for (int i = 1; i <= 2 * n; i++) x[i] += x[i - 1];
	for (int i = 1; i <= n; i++) dp[i] = dp[i - 1] * 2 + mint(2).pow(x[a[i].l - 1]);
	cout << dp[n];
}
```

### *P5664 [CSP-S2019] Emiya 家今天的饭

Emiya 的限制是简单的，最终合法数减去 $1$ 即可。加入 Rin 的限制，在每种方法中只能选一个菜，根据乘法原理可得答案

$\prod_{i=1}^n (1+\sum_{j=1}^m a_{i,j})$加入 Yazid 的限制，考虑减法原理，用上面这个减去不满足 Yazid 限制的方案数。设计一个 DP，令 $dp_{i,x,y}$ 表示考虑前 $i$ 道菜，已经选出了 $x$ 个菜，其中有 $y$ 个菜使用了该食材的不合法方案数。分类讨论转移：

1. 不选当前食材：答案为 $dp_{i-1,x,y}$。
2. 选当前食材：若 $x=y$，则当前已选，从 $dp_{i-1,x-1,y-1}$ 转移；若 $x \ne y$，从 $dp_{i-1,x-1,y}$ 转移。

复杂度 $O(n^3m^2)$，无法通过。

观察到 $c > \lfloor \dfrac{k}{2} \rfloor$ 的限制实际上类似一个**绝对众数**的约束。注意到我们只记录 $x-y$ 也能进行转移。将状态改为 $dp_{i,j}$，其中 $j=x-y$。

同时可以发现，如果枚举不合法的食材，可以直接按不选、$j=x$，$j \ne x$ 分类讨论。最终得到转移方程

$dp_{i,j}=dp_{i-1,j}+dp_{i-1,j-1} \times a_{i,x}+dp_{i-1,j+1} \sum_{k \ne x} a_{i,k}$预处理一下即可，复杂度 $O(n^2m)$。

注意 DP 状态的第二维 $j \in [-n,n]$，需要使用数组漂移的 trick。

```cpp
const int N = 105, M = 2005;
int n, m;
mint a[N][M], sum[N], f[N][N << 1];

mint solve(int x) {
	f[0][n] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = -n; j <= n; j++) {
			f[i][j + n] = 0;
			f[i][j + n] += f[i - 1][j - 1 + n] * a[i][x];
			f[i][j + n] += f[i - 1][j + 1 + n] * (sum[i] - a[i][x]);
			f[i][j + n] += f[i - 1][j + n];
		}
	}
	mint res = 0;
	for (int i = 1; i <= n; i++) res += f[n][i + n];
	return res;
}

void _main() {
	cin >> n >> m;
	mint res = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) cin >> a[i][j], sum[i] += a[i][j];
		res *= sum[i] + 1;
	}
	for (int i = 1; i <= m; i++) res -= solve(i);
	cout << res - 1;
}
```

### AT_abc279_g [ABC279G] At Most 2 Colors

计数 DP。设 $dp_i$ 表示 $i$ 个格子时的答案，分类讨论：

1. 若 $[i-k+1,i)$ 中仅有一种颜色，则 $i$ 填任何颜色均可，答案为 $dp_{\max(1,i-k+1)}\times c$。
2. 若 $[i-k+1,i)$ 中有两种颜色，则 $i$ 只能从这两种颜色中选择。考虑减法原理，用前 $i-1$个格子的总合法方案数减去前 $k-1$ 个只染一种颜色的方案数，得到 $(dp_{i-1}-dp_{\max(1,i-k+1)}) \times 2$。

由加法原理得到递推式

$dp_{i}=dp_{i-1} \times 2+dp_{\max(1,i-k+1)} \times (c-2)$复杂度 $O(n)$。

```cpp
const int N = 1e6 + 5;
int n, k, c;
mint dp[N];

void _main() {
	cin >> n >> k >> c;
	dp[1] = c;
	for (int i = 2; i <= n; i++) dp[i] = dp[i - 1] * 2 + dp[max(1, i - k + 1)] * (c - 2);
	cout << dp[n];
}
```

### *[模拟赛] 日程

> 有一个长度为 $k$ 的 01 序列，有 $n$ 条限制形如 $[l,r]$ 中至少有一个 $0$，$m$ 条限制形如 $[l,r]$ 中至少有一个 $1$，求合法的 01 序列数目对 $10^9+7$ 取模的结果。
>
> $n,m\le 10^5$，$k \le 10^9$。

赛时无人有分的含金量。

考虑 $k \le 10^5$ 怎么做。设 $dp_{0/1,i}$ 表示第 $i$ 个数填 0/1 的方案数，枚举上一个 0/1 的位置 $j$ 判断是否满足性质即可，复杂度 $O(k^2)$。注意到 $j$ 对 $i$ 产生影响的位置是单调的，可以用一个指针维护，复杂度 $O(k)$。

对于 $k \le 10^9$，将 $l,r$ 离散化，则我们现在对连续段做计数 DP。设 $dp_{0/1,i}$ 表示第 $i$ 段全填 0/1 的方案数，仍然可以维护一个 $j$ 来转移。注意第 $i$ 可能 0/1 都有，我们用一个变量 $v$ 来维护。转移用乘法原理和加法原理推一推即可。复杂度 $O(n \log n)$。

```cpp
const int N = 1e5 + 5;
int k, n, m, x[N], y[N];
struct node {
	int l, r;
} a[N], b[N];
discrete_map<int, N << 2> mp;
mint f[2][N];

void _main() {
	cin >> k >> n >> m;
	for (int i = 1; i <= n; i++) {
		cin >> a[i].l >> a[i].r, mp.add(a[i].r);
		if (a[i].l != 1) mp.add(a[i].l - 1);
	}
	for (int i = 1; i <= m; i++) {
		cin >> b[i].l >> b[i].r, mp.add(b[i].r);
		if (b[i].l != 1) mp.add(b[i].l - 1);
	}
	mp.add(1), mp.add(k), mp();
	for (int i = 1; i <= n; i++) x[mp[a[i].r]] = max(x[mp[a[i].r]], mp[a[i].l]);
	for (int i = 1; i <= m; i++) y[mp[b[i].r]] = max(y[mp[b[i].r]], mp[b[i].l]);
	f[0][0] = (x[1] == 0), f[1][0] = (y[1] == 0);
	mint s0 = f[0][0], s1 = f[1][0], v = 0;
	int a = 0, b = 0;
	for (int i = 1; i < mp.width; i++) {
		int len = mp.value(i + 1) - mp.value(i);
		mint p = mint(2).pow(len) - 2;
		if (i >= x[i + 1]) f[0][i] = s1 + v;
		if (i >= y[i + 1]) f[1][i] = s0 + v;
		if (len > 1) v += s0 + s1, v *= p;
		else v = 0;
		s0 += f[0][i], s1 += f[1][i];
		for (; a < x[i + 1]; a++) s0 -= f[0][a];
		for (; b < y[i + 1]; b++) s1 -= f[1][b];
	} cout << v + s0 + s1;
}
```


## 附：计数原理、鸽巢原理与染色模型（《OI 中的计数基础》· stripe-python）

## 1. 计数原理

### 1.1 加法 & 乘法原理

**加法原理**：若完成一个任务有 $n$ **类**方法，第 $i$ 类的方案数为 $a_i$，则完成这个任务的总方案数为 $a_1+a_2+\cdots +a_n=\sum \limits_{i=1}^n a_i$ 种方法。

**乘法原理**：若完成一个任务有 $n$ **步**，第 $i$ 步的方案数为 $a_i$，则完成这个任务的总方案数为 $a_1\times a_2\times \cdots \times a_n=\prod \limits_{i=1}^n a_i$ 种方法。

如果读者是计数原理的初学者，那么请在阅读下文时，时刻注意分类 / 分步的区别。

加法原理的推论：设总方案数为 $n$，不合法的方案数为 $m$，则合法的方案数为 $n-m$。

这一结论称为**减法原理** / 单步容斥 / 整体排除。减法原理是一种十分常见的计数方法，如果对合法元素的计数比较困难，我们可以转而计算总方案数 & 不合法方案数。这体现了正难则反的思想。

乘法原理的推论：设有序对象的数目为 $n$，若存在一种方法，使得每个无序对象都恰好对应 $m$ 个有序对象，则无序对象的方案数为 $\dfrac{n}{m}$。

这个结论称为**消序原理**。消序常用于有序计数和无序计数的转换。请注意其使用前提：必须能够将每个无序对象恰好对应 $m$ 个有序对象。

### 1.2 鸽巢原理

将 $n$ 个元素不重不漏地划分为 $k$ 组，则必然存在一个分组，其中元素的数目不小于 $\left \lceil \dfrac{n}{k} \right \rceil$。

### 1.3 染色模型

这里讲解染色方案的计数问题，希望读者能够加深对计数原理的理解。

问题一：将长为 $n$ 的有标号**链**染色，共有 $m$ 种颜色，且要求相邻两点颜色不同，求染色的方案数。

:::::success[题解]

考虑分步计数：

- 第一个位置：有 $m$ 种选择。
- 第二个位置：不能选择与第一个相同的颜色，有 $m-1$ 种选择。
- ……
- 第 $n$ 个位置：不能选择与第 $n-1$ 个相同的颜色，有 $m-1$ 种选择。

因此，对于第 $1$ 个位置，方案数为 $m$。而对于第 $2 \sim n$ 个位置，方案数为 $m-1$，由乘法原理合并
$$
m(m-1)^{n-1}
$$
:::::

问题二：将长为 $n$ 的有标号**环**染色，共有 $m$ 种颜色，且要求相邻两点颜色不同，求染色的方案数。

:::::success[题解]

直接计数较为困难，考虑变换视角，用递推的方法求出答案。

记 $f_n$ 为问题答案，考虑减法原理：

- 总方案数：我们先忽略首尾同色的情形，答案为 $m(m-1)^{n-1}$。
- 不合法方案数：因为首尾同色，可以合并为单点，则答案为 $f_{n-1}$。

于是得到递推式为
$$
f_n=m(m-1)^{n-1}-f_{n-1}
$$
进行一些代数变形
$$
\begin{aligned}
f_n+f_{n-1}&=m(m-1)^{n-1}\\
f_n+f_{n-1}&=(m-1)^n+(m-1)^{n-1}\\
f_n-(m-1)^n &= -f_{n-1}+(m-1)^{n-1}
\end{aligned}
$$
记 $g_n=f_n-(m-1)^n$，则上式给出 $g_n=-g_{n-1}$。因此
$$
\begin{aligned}
g_n&=(-1)^n (m-1)\\
f_n-(m-1)^n &= (-1)^n (m-1)\\
f_n&=(-1)^n (m-1)+(m-1)^n
\end{aligned}
$$
至此问题解决。

:::::$AKB287$, '数学', array['计数原理', '加法原理', '乘法原理', '抽屉原理'], 'col-math-combinatorics', null, 'knowledge'),
('Xesir', 'col-math-crt--xesir', '中国剩余定理（CRT 与 exCRT） · Xesir', $AKB288$## 算法原理

> ~~古人的智慧~~

**问题来源——“物不知数”**：

> 有物不知其数，三三数之剩二，五五数之剩三，七七数之剩二。问物几何？

翻译成现代数学：求 $x$ 满足：

$$
\begin{cases}
x \equiv 2 \pmod{3} \\
x \equiv 3 \pmod{5} \\
x \equiv 2 \pmod{7}
\end{cases}
$$

答案是 $23$。明朝程大位还给编了个口诀：

> 三人同行七十希，五树梅花廿一支，七子团圆正半月，除百零五便得知。

当然这只是个特例，如何对于任意的同余方程组求解呢？

回归正题，CRT 用于求解如下形式的一元线性同余方程组：

$$
\begin{cases}
x \equiv a_1 \pmod{m_1} \\
x \equiv a_2 \pmod{m_2} \\
\vdots \\
x \equiv a_k \pmod{m_k}
\end{cases}
$$

其中 $m_1, m_2, \dots, m_k$ **两两互质**。

### 算法步骤

1. 计算所有模数的乘积：$M = \prod_{i=1}^{k} m_i$。
2. 对于第 $i$ 个方程，计算 $M_i = M / m_i$。
3. 求 $M_i$ 在模 $m_i$ 下的逆元 $t_i$，即 $M_i \cdot t_i \equiv 1 \pmod{m_i}$。
4. 累加：$ans = \sum_{i=1}^{k} a_i \cdot M_i \cdot t_i$。
5. 最终答案：$ans \bmod M$。

**正确性证明**：对于第 $i$ 个方程，$M_i$ 是除了 $m_i$ 以外所有模数的乘积，所以 $M_i \equiv 0 \pmod{m_j}$（$j \ne i$），只有 $M_i$ 这一项对第 $i$ 个方程有贡献。而 $M_i \cdot t_i \equiv 1 \pmod{m_i}$，乘上 $a_i$ 后正好得到 $a_i$。

### 扩展中国剩余定理（exCRT）

如果出题人 ~~故意找茬~~ 不给你模数两两互质呢？exCRT 就能处理这种情况。

exCRT 通过**两两合并**的方式逐步求解。**合并思想**：假设我们已经得到了前 $k-1$ 个方程的一个特解 $x \equiv a \pmod{M}$，其中 $M = \mathrm{lcm}(m_1, \dots, m_{k-1})$。现在要加入新方程 $x \equiv a_k \pmod{m_k}$。我们需要找一个 $t$，使得：

$$
a + t \cdot M \equiv a_k \pmod{m_k}
$$

即：

$$
M \cdot t \equiv a_k - a \pmod{m_k}
$$

这是一个线性同余方程，用 **EXGCD** 判断是否有解（$\gcd(M, m_k) \mid (a_k - a)$），然后解出 $t$，更新：

$$
a' = a + t \cdot M, \quad M' = \mathrm{lcm}(M, m_k)
$$

新的同余式就是 $x \equiv a' \pmod{M'}$。重复合并所有方程，最后得到 $x \equiv a \pmod{M}$，$a$ 就是最小非负解。

> 注：exCRT 在合并过程中可能出现无解，此时整个方程组无解，特判即可。一般题目保证有解。

## 核心公式

| 内容 | 公式 |
|---|---|
| CRT 构造 | $M=\prod m_i,\ M_i=M/m_i,\ ans=\sum a_i M_i t_i \bmod M$ |
| 逆元条件 | $M_i t_i \equiv 1 \pmod{m_i}$，要求 $\gcd(M_i,m_i)=1$（模数两两互质） |
| exCRT 合并 | $a + tM \equiv a_k \pmod{m_k}$ |
| exCRT 更新 | $a' = a + tM,\ M' = \mathrm{lcm}(M, m_k)$ |
| exCRT 有解判定 | $\gcd(M, m_k) \mid (a_k - a)$ |

## 逐行代码解析

### 模块一：CRT 的初始化与模数乘积

```cpp
// 基础CRT：求解同余方程组，a数组为余数，m数组为模数（两两互质），k为方程个数

ll crt(ll a[], ll m[], ll k) {
    ll M = 1, res = 0;
    for (ll i = 1; i <= k; i++) M *= m[i]; // 模数乘积M
```

- `a[]` 存余数、`m[]` 存模数，下标从 $1$ 开始（所以循环写 `1..k`，`a[0]`、`m[0]` 是空的）。
- `M` 是全部模数的乘积，后面所有构造都围绕它展开。
- `res` 用来累加答案，初值为 $0$。

### 模块二：逐项构造答案

```cpp
    for (ll i = 1; i <= k; i++) {
        ll mi = m[i], ai = a[i];
        ll Mi = M / mi; // Mi = M / mi（与mi互质）
        ll inv_Mi = inv(Mi, mi); // Mi在模mi下的逆元
        res = (res + ai * Mi % M * inv_Mi % M) % M; // 累加解
    }
    return res;
}
```

- `Mi = M / mi`：去掉第 $i$ 个模数后的乘积，它天然是其他所有模数的倍数。
- `inv(Mi, mi)` 求 $M_i$ 在模 $m_i$ 下的逆元；CRT 要求模数两两互质，所以这个逆元一定存在。
- `ai * Mi % M * inv_Mi % M` 每乘一次就取一次模，尽量压小中间值。
- 最后 `res % M` 就是最小非负解。

### 模块三：exCRT 的两两合并

```cpp
ll excrt(ll c[],ll m[],ll k){
	ll a=1,b=0,x=0,y=0;
	for(int i=1;i<=k;i++){
		ll g=exgcd(a,c[i],x,y);
		x*=(b-m[i])/g;
		b-=a*x;
		a*=c[i]/g;
		b=(b%a+a)%a;
	}
	return b=(b%a+a)%a;
}
```

- 这里变量含义和上面的推导略有错位：`a` 扮演的是当前合并后的模数 $M$，`b` 扮演的是当前特解 $x$，`c[]` 是余数、`m[]` 是模数。
- `g = exgcd(a, c[i], x, y)` 解的是 $a \cdot x \equiv b - m_i \pmod{c_i}$ 对应的方程，`x` 是齐次解的一部分。
- `x *= (b - m[i]) / g;` 把 $\gcd$ 下的特解放大到目标方程；若 `(b - m[i]) % g != 0`，这里会直接整除丢失信息，等于默认题目保证有解。
- `b -= a * x;` 先把解平移到新同余式上，`a *= c[i] / g;` 把模数扩大为 $\mathrm{lcm}$，最后两行取模保证 `b` 落在 $[0, a)$。

## 复杂度分析

- **CRT**：求 $k$ 个逆元，每个 $O(\log m)$，总时间 $O(k \log m)$；空间 $O(k)$（存数组）。
- **exCRT**：合并 $k-1$ 次，每次一次 EXGCD，时间 $O(k \log m)$，与 CRT 相当，但适用范围更广（不要求模数互质）。
- 原文给出的复杂度口径就是 $O(k \log m)$。

## 适用场景

- **CRT**：模数两两互质的同余方程组；常见于“答案对多个质数取模后合并”“大数取模”类问题。
- **exCRT**：模数不一定互质，甚至模数之间有明显公因子的同余方程组。
- **exCRT 的合并思想**：不只用于解方程，也可以用来合并两个“周期 + 偏移”的限制（如日期、循环节问题）。
- **与 EXGCD 的关系**：exCRT 每次合并都要解一个线性同余方程，底层就是 EXGCD。

## 常见陷阱

1. **CRT 忘了模数必须两两互质**：不互质时 $M_i$ 与 $m_i$ 可能不互质，逆元不存在，`inv` 会返回错误值。
2. **逆元实现要求模数为质数**：本文的 `inv` 若是费马小定理版本，只能处理质数模数；CRT 里的 $m_i$ 是任意两两互质的数，必须用 EXGCD 求逆元。
3. **下标从 0 还是 1 开始**：代码里循环写的是 `i = 1; i <= k`，数组第 $0$ 位没用到，传参时别把数据塞到 `a[0]`。
4. **`M` 溢出**：$M = \prod m_i$ 增长极快，`long long` 最多撑到约 $9 \times 10^{18}$，模数稍大就会爆。
5. **exCRT 无解没判**：`(b - m[i]) / g` 在不能整除时结果没有意义，严格写法应先判 `(b - m[i]) % g != 0`。
6. **exCRT 变量名混淆**：代码里 `a` 是模数、`b` 是解，和公式里的 $a_k$（余数）不是一回事，读的时候要对着上下文。
7. **最后没取最小非负解**：`b` 可能在合并过程中变成负数，必须 `(b % a + a) % a`。

---
> CRT 的构造是“每一项只对自己那个方程负责，对其他方程自动消失”；exCRT 的合并是“把两个限制捏成一个”。抓住这两句话，代码就不容易看晕。$AKB288$, '数学', array['数学', '数论', '中国剩余定理', 'CRT', 'exCRT', '同余方程组', '扩展欧几里得'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-crt', '中国剩余定理（CRT）', $AKB289$## 中国剩余定理（CRT）

> ⚠️ **代码质量警告：本实现大数容易溢出**
>
> 本代码使用 `long long` 存储模数乘积 $M = \prod r_i$，在计算过程中 `Mi * ti`、`x * Mi` 等中间乘法可能在取模前就已经溢出。
>
> **支持的数值范围**：
> - 当模数都是 int 范围内的小质数时（如 $r_i \le 10^9$），最多只能支持约 **2~3 个**模数，再多 $M$ 就会超过 `long long` 上限（约 $9 \times 10^{18}$）
> - 若模数都很小（如 $r_i \le 100$），最多支持约 **15 个**模数
> - 中间乘法 `ans * gap`、`gap * gap` 在模数接近 $10^9$ 时也可能溢出
>
> **改进建议**：使用 `__int128` 或龟速乘（快速乘）避免中间溢出；或使用扩展欧几里得法的 EXCRT 版本（不要求模数互质且更安全）。

## 一、算法原理

### 1.1 问题描述

给定 $n$ 个同余方程，模数两两互质：

$$
\begin{cases}
x \equiv a_1 \pmod{r_1} \\
x \equiv a_2 \pmod{r_2} \\
\quad \vdots \\
x \equiv a_n \pmod{r_n}
\end{cases}
$$

其中 $\gcd(r_i, r_j) = 1$（$i \ne j$），求 $x$ 在模 $M = \prod_{i=1}^{n} r_i$ 意义下的唯一解。

### 1.2 核心构造

令 $M = \prod_{i=1}^{n} r_i$，$M_i = \dfrac{M}{r_i}$（即去掉第 $i$ 个模数后的乘积）。

由于所有模数两两互质，$M_i$ 与 $r_i$ 互质，因此 $M_i$ 在模 $r_i$ 意义下存在逆元，记为 $t_i = M_i^{-1} \pmod{r_i}$。

则方程组的解为：

$$
x \equiv \sum_{i=1}^{n} a_i \cdot M_i \cdot t_i \pmod{M}
$$

### 1.3 正确性证明

对第 $k$ 个方程验证：

- 当 $i \ne k$ 时，$M_i$ 包含因子 $r_k$，所以 $M_i \equiv 0 \pmod{r_k}$，因此 $a_i \cdot M_i \cdot t_i \equiv 0 \pmod{r_k}$
- 当 $i = k$ 时，$M_k \cdot t_k \equiv M_k \cdot M_k^{-1} \equiv 1 \pmod{r_k}$，因此 $a_k \cdot M_k \cdot t_k \equiv a_k \pmod{r_k}$

所以总和满足 $x \equiv a_k \pmod{r_k}$，对所有 $k$ 成立。

### 1.4 逆元的求法

本代码使用**费马小定理**求逆元：因为 $r_i$ 是质数，所以 $t_i = M_i^{r_i - 2} \bmod r_i$。

也可以用扩展欧几里得算法求逆元，效率相同且不要求 $r_i$ 为质数（只要求互质）。

## 二、核心公式与状态定义

### 2.1 CRT 核心公式

$$
\boxed{x \equiv \sum_{i=1}^{n} a_i \cdot \frac{M}{r_i} \cdot \left(\frac{M}{r_i}\right)^{-1}_{r_i} \pmod{M}, \quad M = \prod_{i=1}^{n} r_i}
$$

### 2.2 变量定义

| 变量 | 含义 |
|------|------|
| $n$ | 同余方程的个数 |
| $r_i$ | 第 $i$ 个模数（两两互质，且为质数） |
| $a_i$ | 第 $i$ 个余数 |
| $M$ | 所有模数的乘积 $\prod r_i$ |
| $M_i$ | $M / r_i$（去掉第 $i$ 个模数后的乘积） |
| $t_i$ | $M_i$ 在模 $r_i$ 下的逆元 |
| `ans` | 累加的结果，最终即 $x \bmod M$ |

### 2.3 求解流程

```
输入: n 个同余方程 (r_i, a_i)
输出: x mod M

1. 计算 M = r_1 * r_2 * ... * r_n
2. ans = 0
3. 对每个 i = 1..n:
   - Mi = M / r_i
   - ti = Mi^{-1} mod r_i    （费马小定理 / 扩展欧几里得）
   - ans = (ans + a_i * Mi * ti) mod M
4. 返回 ans
```

## 三、逐行代码解析

### 3.1 全局变量与 init

```cpp
vector<long long> a, r;
void init(int n)
{
    a.assign(n + 1, 0);
    r.assign(n + 1, 0);
}
```

`a[i]` 存余数，`r[i]` 存模数。数组下标从 1 开始，方便按方程编号访问。

### 3.2 _gcd —— 欧几里得算法

```cpp
long long _gcd(long long a, long long b)
{
    return b ? _gcd(b, a % b) : a;
}
```

递归实现的 GCD，本代码中实际未被 CRT 函数调用（因为假设模数两两互质且为质数），保留作通用工具函数。

### 3.3 fastpow —— 快速幂

```cpp
long long fastpow(long long a, long long b, long long q)
{
    long long ans = 1;
    long long gap = a % q;
    while (b)
    {
        if (b & 1) ans = (ans * gap) % q;
        gap = (gap * gap) % q;
        b >>= 1;
    }
    return ans;
}
```

计算 $a^b \bmod q$，用于费马小定理求逆元。注意首行 `gap = a % q` 确保底数先取模。

### 3.4 CRT —— 中国剩余定理主函数

```cpp
long long CRT(int n, long long M)
{
    long long ans = 0;
    for (int i = 1; i <= n; i++)
    {
        long long x = a[i] % M;
        long long Mi = M / r[i];
        long long ti = fastpow(Mi, r[i] - 2, r[i]);
        x = (x * (Mi % M)) % M;
        x = (x * ti) % M;
        ans = (ans + x) % M;
    }
    return (ans % M + M) % M;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `long long ans = 0;` | 累加器初始化 |
| 2 | `long long x = a[i] % M;` | 取余数的模 M 形式 |
| 3 | `long long Mi = M / r[i];` | $M_i = M / r_i$ |
| 4 | `long long ti = fastpow(Mi, r[i] - 2, r[i]);` | 费马小定理求 $t_i = M_i^{-1} \bmod r_i$ |
| 5 | `x = (x * (Mi % M)) % M;` | $x \leftarrow a_i \cdot M_i \pmod{M}$ |
| 6 | `x = (x * ti) % M;` | $x \leftarrow a_i \cdot M_i \cdot t_i \pmod{M}$ |
| 7 | `ans = (ans + x) % M;` | 累加到答案 |
| 8 | `return (ans % M + M) % M;` | 确保结果非负 |

### 3.5 main —— 输入输出

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    long long M = 1;
    cin >> n;
    init(n);
    for (int i = 1; i <= n; i++)
    {
        cin >> r[i] >> a[i];
        M *= r[i];
    }
    cout << CRT(n, M);
    return 0;
}
```

读取 $n$ 个方程，逐次累乘计算 $M$，调用 CRT 求解并输出。

### 3.6 运行示例

输入：
```
3
3 2
5 3
7 2
```

即求解：
$$
\begin{cases}
x \equiv 2 \pmod{3} \\
x \equiv 3 \pmod{5} \\
x \equiv 2 \pmod{7}
\end{cases}
$$

输出：
```
23
```

验证：$23 \bmod 3 = 2$，$23 \bmod 5 = 3$，$23 \bmod 7 = 2$ ✓

$M = 3 \times 5 \times 7 = 105$，通解为 $x \equiv 23 \pmod{105}$。

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(n \log r_{\max})$ | 每个方程需要一次快速幂求逆元 $O(\log r_i)$，共 $n$ 个方程 |
| 空间 | $O(n)$ | 存储 $a_i$ 和 $r_i$ |

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **同余方程组求解** | 模数两两互质的同余方程组 |
| **组合数取模** | 模数为合数但可分解为互质因子的乘积时，分别求解后用 CRT 合并 |
| **NTT 合并** | 用多个 NTT 友好模数计算后，用 CRT 合并出真实结果 |
| **数论构造题** | 需要构造满足多个同余约束的数 |

## 六、常见陷阱与注意事项

### 6.1 大数溢出（最严重问题）

本代码的最大问题是溢出。`long long` 的上限约为 $9.2 \times 10^{18}$，当模数乘积 $M$ 或中间乘法超过这个值时，结果完全错误。

**典型溢出点**：
- `M *= r[i]` —— 累乘 $M$ 时溢出
- `ans * gap` 和 `gap * gap` —— 快速幂内部乘法溢出
- `x * (Mi % M)` —— CRT 中的乘法溢出

**解决方案**：
1. 使用 `__int128` 做中间乘法（部分编译器支持）
2. 使用龟速乘（快速乘）模拟乘法，避免溢出
3. 使用 Python 等自带高精度的语言

### 6.2 模数必须两两互质

CRT 的前提条件是模数两两互质。如果模数不互质，应当使用扩展中国剩余定理（EXCRT），通过合并方程逐步求解。

### 6.3 费马小定理要求模数为质数

本代码用 `fastpow(Mi, r[i] - 2, r[i])` 求逆元，要求 $r_i$ 是质数。如果 $r_i$ 只是与 $M_i$ 互质但不是质数，应改用扩展欧几里得求逆元。

### 6.4 结果可能为负

虽然代码末尾做了 `(ans % M + M) % M` 确保非负，但如果中间步骤处理不当（如 $a_i$ 为负数），仍可能出问题。建议输入前先将 $a_i$ 调整到 $[0, r_i)$ 范围内。

### 6.5 M 可能等于 0

如果模数太多导致 $M$ 溢出变为 0，后续 `M / r[i]` 会触发除零错误。使用前务必确认数据范围。

## 七、对比与扩展

### 7.1 三种 CRT 实现对比

| 维度 | 费马小定理版（本代码） | 扩展欧几里得版 | EXCRT（扩展 CRT） |
|------|---------------------|-------------|-----------------|
| 模数要求 | 两两互质且为质数 | 两两互质 | 无需互质 |
| 求逆方式 | 快速幂 | 扩展欧几里得 | 合并方程时用 exgcd |
| 时间复杂度 | $O(n \log r)$ | $O(n \log r)$ | $O(n \log r)$ |
| 代码复杂度 | 简单 | 中等 | 稍复杂 |
| 适用场景 | 模数为质数的竞赛题 | 模数互质但不一定是质数 | 模数不互质的一般情况 |

### 7.2 龟速乘（快速乘）防溢出

```cpp
long long mul(long long a, long long b, long long mod)
{
    long long ans = 0;
    while (b)
    {
        if (b & 1) ans = (ans + a) % mod;
        a = (a + a) % mod;
        b >>= 1;
    }
    return ans;
}
```

用加法模拟乘法，复杂度 $O(\log b)$，避免中间溢出。配合 CRT 使用可处理更大的模数。

### 7.3 EXCRT（扩展中国剩余定理）

当模数不互质时，使用 EXCRT 逐次合并方程：

```cpp
long long excrt(int n, long long r[], long long a[])
{
    long long M = r[1], ans = a[1];
    for (int i = 2; i <= n; i++)
    {
        long long c = ((a[i] - ans) % r[i] + r[i]) % r[i];
        long long x, y;
        long long d = ex_gcd(M, r[i], x, y);
        if (c % d != 0) return -1; // 无解
        long long t = r[i] / d;
        x = mul(x, c / d, t);
        ans += x * M;
        M = M / d * r[i];
        ans = (ans % M + M) % M;
    }
    return ans;
}
```

每次合并两个同余方程，通过扩展欧几里得求解新的模数和余数。

### 7.4 一句话总结

中国剩余定理求解两两互质模数的同余方程组，核心是构造 $M = \prod r_i$ 和 $M_i = M/r_i$，利用逆元 $M_i^{-1}$ 使得第 $i$ 项仅在模 $r_i$ 下贡献 $a_i$，其余模下为 0。本实现基于费马小定理求逆元，**代码简洁但大数容易溢出**，仅适合模数较少、数值较小的场景。生产级实现应配合龟速乘或 `__int128` 使用。$AKB289$, '数学', array['数学', '数论', '中国剩余定理', 'CRT', '模逆元', '费马小定理', '同余方程组'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-derangement--stripe-python', '错位排列（错排） · stripe-python', $AKB290$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 12. 错位排列

**错排数** $D_i$ 是指将 $1$ 到 $n$ 的自然数排列重新排列为 $P_i$ 后，满足 $\forall i \in [1,n], P_i \ne i$ 的方案数。

例如，$n=3$ 时，错位排列有 $\{2,3,1\}$ 和 $\{3,1,2\}$。

## 12.1 递推公式

计算错排数可以递推。考虑 $D_n$ 时，先把 $n$ 放在 $P_n$，然后有两种情况：

1. 前面 $n-1$ 个数已经是错位排列；
2. 前面 $n-1$ 个数有一个在原位上，其他错位。

对于情况 1，第 $n$ 个数可以与任一数字交换，有 $(n-1)D_{n-1}$ 种方案；

对于情况 2，第 $n$ 个数只能与原位上的交换，有 $(n-1)D_{n-2}$ 种方案；

因此，

$D_n=(n-1)(D_{n-1}+D_{n - 2})$另外地，$D_1=0,D_2=1$。

对 $D_n=(n-1)(D_{n-1}+D_{n - 2})$ 变形：

$$
\begin{aligned}
D_n&=(n-1)(D_{n-1}+D_{n - 2})\\
D_n&=(n-1)D_{n-1}+(n-1)D_{n-2}\\
D_n-nD_{n-1}&=-D_{n-1}+(n-1)D_{n-2}\\
D_n-nD_{n-1}&=(-1)[D_{n-1}-(n-1)D_{n-2}]
\end{aligned}
$$

由此可见 $D_n-nD_{n-1}$ 是首项为 $1$，公比为 $-1$ 的等差数列，由此可得错排的另一个递推式

$D_n=nD_{n-1}+(-1)^n$## *12.2 通项公式

由递推式 2，两边同时除以 $n!$ 有

$\dfrac{D_n}{n!}=\dfrac{D_{n-1}}{(n-1)!}+\dfrac{(-1)^n}{n!}$根据递推式不断代入，累加：

$\dfrac{D_n}{n!}=\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$因此可得错排通项公式

$D_n=n!\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$### 范围估计

根据通项公式可以估计错排的增长速度。由式子

$\dfrac{D_n}{n!}=\sum_{k=0}^{n} \dfrac{(-1)^k}{k!}$可以想到 $e^{-1}$ 的泰勒展开。写出 $\dfrac{1}{e}$ 在 $x=-1$ 处的泰勒展开：

$\dfrac{1}{e}=\sum_{k=0}^{\infty} \dfrac{(-1)^k}{k!}$因此：

$\dfrac{1}{e}=\dfrac{D_n}{n!} + \sum_{k=n+1}^{\infty} \dfrac{(-1)^k}{k!}$注意到，当 $n$ 增加时，后面的和式趋近于 $0$，因此可得错排数列的极限：

$\lim_{n \to +\infty} D_n=\dfrac{n!}{e}$即 $D_n=O(n!)$。因此在复杂度中用到错排时，可认为它是阶乘级别的。

## 12.3 例题

### P1595 信封问题

板子题。

```cpp
const int N = 25;
int n;
long long d[N];

void _main() {
	d[2] = 1;
	for (int i = 3; i < N; i++) d[i] = (i - 1) * (d[i - 1] + d[i - 2]);
	cin >> n;
}
```

### P4071 [SDOI2016] 排列计数

稍微思考一下就能发现，可以先选出 $m$ 个数，使得 $a_i=i$，然后再让剩下 $n-m$ 个数都满足 $a_i \ne i$，这就是错排数 $D_{n-m}$。因此答案即为 $C_{n}^{m} \times D_{n-m}$。采用预处理逆元的方法求组合数即可。

```cpp
const int N = 1e6 + 5;
const long long mod = 1e9 + 7;
long long d[N], fac[N], ifac[N];

long long power(long long a, long long b) {
	long long res = 1;
	for (a %= mod; b; b >>= 1) {
		if (b & 1) res = res * a % mod;
		a = a * a % mod;
	}
	return res;
}

long long t, n, m;

void _main() {
	d[2] = 1;
	for (int i = 3; i < N; i++) d[i] = 1LL * (i - 1) * ((d[i - 1] + d[i - 2]) % mod) % mod;

	fac[0] = 1;
	for (int i = 1; i < N; i++) {
		fac[i] = fac[i - 1] * i % mod;
		ifac[i] = power(fac[i], mod - 2);
	}
	for (cin >> t; t--; ) {
		cin >> n >> m;
		if (m == 0) {cout << d[n] << '\n'; continue;}
		if (n == m) {cout << 1 << '\n'; continue;}
		if (n == m + 1) {cout << 0 << '\n'; continue;}
		cout << (fac[n] * ifac[m] % mod * ifac[n - m] % mod) * (n >= m ? d[n - m] : 1) % mod << '\n';
	}
}
```

同样的思想可以解决 [P8788](https://www.luogu.com.cn/problem/P8788) 的问题 A。

### *P4921 [MtOI2018] 情侣？给我烧了！

定义一个“广义错排数” $f(x)$ 表示 $x$ 对情侣都错开的方案数。方法和上面那题一样，区别在于情侣位置有序，且一对情侣的相对位置有两种选择，由乘法原理得

$a_k=C_n^k \times A_n^k \times 2^k \times f(n-k)$只要预处理出 $f(x)$ 即可。和错排的方法一样分解成子问题。首先我们从这 $2x$ 个人中任意选取一个人，再选一个不能配对的人，乘法原理得 $2x(2x-2)$。分类讨论这两人的配偶：

1. 将他们强制配对：则子问题为 $f(x-2)$。我们有 $x-1$ 个位置，且一对情侣有 $2$ 种可能，答案为 $2(x-1) \times f(x-2)$。
2. 不强制配对：问题变成子问题 $f(x-1)$。

由加法 & 乘法原理得：

$f(x)=2x(2x-2) \times [f(x-1)+2(x-1)\times f(x-2)]$于是我们在 $O(Tn)$ 的复杂度下解决了此问题。你甚至可以用这个做法切掉[加强版](https://www.luogu.com.cn/problem/P4931)。

```cpp
const int N = 1005;
int q, n;
mint fac[N], ifac[N], f[N];
mint A(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[n - m];
}
mint C(int n, int m) {
	if (n < m) return 0;
	return fac[n] * ifac[m] * ifac[n - m];
}

void _main() {
	fac[0] = ifac[0] = 1, f[0] = 1, f[1] = 0;
	for (int i = 1; i < N; i++) fac[i] = fac[i - 1] * i, ifac[i] = ~fac[i];
	for (int i = 2; i < N; i++) f[i] = (f[i - 1] + f[i - 2] * 2 * (i - 1)) * 2 * i * (2 * i - 2);
	for (cin >> q; q--; ) {
		cin >> n;
		for (int k = 0; k <= n; k++) cout << C(n, k) * A(n, k) * mint(2).pow(k) * f[n - k] << '\n';
	}
}
```

## 附：计数基础·错位排列（stripe-python）

## 4. 错位排列

定义一个 $1 \sim n$ 的排列 $p_i$ 是错位排列，当且仅当 $\forall 1 \le i \le n, p_i \ne i$。

**错排数** $D_n$ 表示长为 $n$ 的错位排列的数目。

我们可以用排列计数的方法来递推 $D_n$，考虑插入第 $n$ 个数：

- 若 $p_1 \sim p_{n-1}$ 全部满足 $p_i \ne i$，则 $n$ 可以插入任意位置，方案数 $(n-1)D_{n-1}$。
- 若 $p_1 \sim p_{n-1}$ 恰有一个 $i$ 满足 $p_i=i$，则 $n$ 只需与 $p_i$ 调换。而这样的 $i$ 有 $n-1$ 个，方案数 $(n-1)D_{n-2}$。
- 若 $p_1 \sim p_{n-1}$ 有 $\ge 2$ 个 $i$ 满足 $p_i=i$，则 $p_1 \sim p_n$ 不可能成为错位排列，方案数 $0$。

由加法原理合并得到
$$
D_n=(n-1)(D_{n-1}+D_{n-2})
$$
进一步推导可得另一个递推式 $D_n=nD_{n-1}+(-1)^n$。

:::::success[代数推导]
$$
\begin{aligned}
D_n&=(n-1)(D_{n-1}+D_{n-2})\\
\iff& D_n= (n-1)D_{n-1}+(n-1)D_{n-2}\\
\iff& D_n-nD_{n-1} = -D_{n-1} + (n-1)D_{n-2}
\end{aligned}
$$
记 $f_n=D_n-nD_{n-1}$，上式给出 $f_n=-f_{n-1} \implies f_n=(-1)^n$。故
$$
D_n-nD_{n-1}=(-1)^n \iff D_n=nD_{n-1}+(-1)^n
$$
:::::

错排数的通项公式为
$$
D_n=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
$$
下面给出四种推导视角。

:::::success[代数变形]

由 $D_n=nD_{n-1}+(-1)^n$ 可得
$$
\dfrac{D_n}{n!}=\dfrac{D_{n-1}}{(n-1)!}+\dfrac{(-1)^n}{n!}
$$
记 $f_n=\dfrac{D_n}{n!}$，上式给出 $f_n=f_{n-1}+\dfrac{(-1)^n}{n!}$，得
$$
f_n=\sum_{k=0}^n \dfrac{(-1)^k}{k!}
$$
代入 $f_n$ 的定义式后移项即证。

:::::

:::::success[容斥原理]

记第 $i$ 种属性为 $p_i=i$，则 $D_n$ 即不具有任何属性的排列数目。考虑容斥，我们钦定 $k$ 种属性，对钦定至少的组合意义计数：

- 在 $n$ 个位置中钦定 $k$ 个位置，方案数 $\dbinom{n}{k}$。
- 未被钦定的 $n-k$ 个位置全排列，方案数 $(n-k)!$。

容斥系数为 $(-1)^k$。由此可得
$$
\begin{aligned}
D_n&=\sum_{k=0}^n (-1)^k \binom{n}{k} (n-k)!\\
&=\sum_{k=0}^n (-1)^k \dfrac{n!}{k!}\\
&=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

:::::success[二项式反演]

记 $f(k)$ 为恰有 $k$ 个 $i$ 满足 $p_i=i$ 的排列数目，易知
$$
f(k)=\binom{n}{k} D_{n-k}
$$
所有 $f(k)$ 的和即为全排列
$$
\begin{aligned}
n!=\sum_{k=0}^n f(k)=\sum_{k=0}^n \binom{n}{k} D_{n-k}=\sum_{k=0}^n \binom{n}{k} D_k
\end{aligned}
$$
由二项式反演形式一
$$
\begin{aligned}
D_n&=\sum_{k=0}^n (-1)^{n-k} \binom{n}{k}k!\\
&=\sum_{k=0}^n (-1)^{n-k} \dfrac{n!}{(n-k)!}\\
&=n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

:::::success[错排 EGF]

记错排数列的 EGF 为 $F$，代入第二个递推式
$$
\begin{aligned}
F(x)&=1+\sum_{n \ge 1} D_n \dfrac{x^n}{n!}\\
&=1+\sum_{n \ge 1} D_{n-1} \dfrac{x^{n-1}}{(n-1)!}+\sum_{n\ge 1} (-1)^n \dfrac{x^n}{n!}\\
F(x)&=1+xF(x)+e^{-x}-1
\end{aligned}
$$
解方程 $F=xF+e^{-x}$ 得 $F(x)=\dfrac{e^{-x}}{1-x}$，即为 EGF 的封闭形式。
$$
\begin{aligned}
F(x)&=\dfrac{e^{-x}}{1-x}\\
&=\left(\sum_{i \ge 0} (-1)^i\dfrac{x^i}{i!} \right)\left(\sum_{j \ge 0} x^j\right)\\
\left[\frac{x^n}{n!}\right] F(x)&= n!\sum_{k=0}^n \dfrac{(-1)^k}{k!}
\end{aligned}
$$
:::::

熟知 $e^{-1}$ 的泰勒展开 $e^{-1}=\sum\limits_{k\ge 0} \dfrac{(-1)^k}{k!}$，代入有
$$
\dfrac{D_n}{n!}+\sum_{k \ge n+1} \dfrac{(-1)^k}{k!}=\dfrac{1}{e}
$$
后面的和式在 $n\to +\infty$ 时趋近为 $0$，因此
$$
\lim_{n \to +\infty} \dfrac{D_n}{n!}=\dfrac{1}{e}
$$
更精细的分析表明
$$
D_n=\left\lfloor \dfrac{n!}{e}+\dfrac{1}{2} \right\rfloor
$$
不过实际上这些通项在 OI 中没有什么应用，读者领会思想即可。$AKB290$, '数学', array['错排', '错位排列', '递推'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-euler-phi--stripe-python', '欧拉函数 · stripe-python', $AKB291$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 4. 欧拉函数

## 4.1 定义

**欧拉函数** $\varphi(x)$ 指 $[1,n]$ 中与 $n$ 互质的数的个数。

若由算术基本定理可将 $n$ 分解为 $p_1^{c_1} p_2^{c_2} p_3^{c_3} \cdots p_m^{c_m}$，则

$\varphi(x)=n (1-\dfrac{1}{p_1})  (1-\dfrac{1}{p_2}) (1-\dfrac{1}{p_3}) \cdots (1-\dfrac{1}{p_m}) =n\times \prod_{i=1}^{m} (1-\dfrac{1}{p_i})$由此有一个 $O(\sqrt{n})$ 计算欧拉函数的方法：

```cpp
inline int phi(int n) {
	if (n == 1) return 1;
	int res = n;
	for (int i = 2; i * i <= n; i++) {
		if (n % i == 0) {
			res = res / i * (i - 1);
			while (n % i == 0) n /= i;
		}
	}
	if (n > 1) res = res / n * (n - 1);
	return res;
}
```

## 4.2 性质

1. 若 $p$ 是质数，则 $\varphi(p)=p-1$。
2. 若 $a,b$ 互质，则 $\varphi(ab)=\varphi(a) \times \varphi(b)$。这表明：欧拉函数是积性函数，因而可以用线性筛筛出。
3. $\sum_{d \mid  n} \varphi(d)=n$。一些文章称之为“欧拉反演”，但严格来说并不算反演。
4. 对于 $n>1$，$[1,n]$ 中与 $n$ 互质的数的和为 $\dfrac{1}{2}n\times \varphi(n)$。
5. 若 $n=p^k$，其中 $p$ 是质数，则 $\varphi(n)=p^k-p^{k-1}$。

## 4.3 筛法

使用性质 2 并结合线性筛法，可以在 $O(n)$ 时间内预处理 $[1,n]$ 的欧拉函数值：

```cpp
int len, phi[N], prime[N];
bitset<N> isprime;

inline void eular(int n) {
	phi[1] = 1, isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i <= n; i++) {
		if (isprime[i]) prime[++len] = i, phi[i] = i - 1;
		for (int j = 1; j <= len && i * prime[j] <= n; j++) {
			isprime[i * prime[j]] = false;
			if (i % prime[j] == 0) {
				phi[i * prime[j]] = phi[i] * prime[j];
				break;
			}
			phi[i * prime[j]] = phi[i] * phi[prime[j]];
		}
	}
}
```

## 4.4 例题

### SP4141 ETF - Euler Totient Function

线性筛欧拉函数板子。直接上代码：

```cpp
const int N = 1e6 + 5;
void _main() {
	eular(N - 1);
	int t, x; cin >> t;
	while (t--) cin >> x, cout << phi[x] << '\n';
}
```

### UVA10179 Irreducable Basic Fractions

题意翻译：求 $\dfrac{0}{n},\dfrac{1}{n},\dfrac{2}{n},\cdots \dfrac{n-1}{n}$ 中多少个分数为最简分数。认为 $\dfrac{0}{n}$ 最简。

我们发现最简分数 $\dfrac{x}{n}$ 满足 $\gcd(x,n)=1$，于是所求为 $\varphi(n)$。用分解质因数法求即可，代码不放了。

### P2158 [SDOI2008] 仪仗队

由样例图可以发现能看见的位置关于对角线对称，只需要考虑一个三角形即可。以左下角为原点 $(0,0)$ 建立坐标系，则一个点被阻挡的条件就是到原点连线的斜率相同。设两点 $(x_1,y_1),(x_2,y_2)$，则 $\dfrac{y_1}{x_1}=\dfrac{y_2}{x_2}$。当且仅当这个分数已经为最简形式时它不会被挡住，这就和上题类似了。

所求即为

$2\sum_{i=1}^{n-1} \varphi(i)+1$这是因为 $(2,2)$ 满足条件而我们无法统计进去。注意特判 $n=1$。

用线性筛筛出欧拉函数即可，复杂度 $O(n)$，代码：

```cpp
int n;
void _main() {
	cin >> n;
	if (n == 1) return cout << 0, 0;
	int res = 1;
	eular(40000);
	for (int i = 1; i < n; i++) res += 2 * phi[i];
	cout << res;
}
```

### P2398 GCD SUM

这题做法很多，读者可以翻到下文 8.3 容斥例题学习容斥做法，这里写的是欧拉函数做法。

可以发现 $\gcd(i,j)$ 的值只有 $n$ 种，不妨考虑 $gcd(i,j)=k$ 的数目。对于一对互质的 $i,j$，有 $\gcd(ik,jk)=k$，所以可以得到结果为 $k$ 的数目为

$2\sum_{i=1}^{\lfloor \frac{n}{k} \rfloor} \varphi(i)-1$和上面那题是一样的，因为 $\gcd(i,j)=\gcd(j,i)$ 有对称性，而 $(1,1)$ 会重复计算，要减一。

然后我们用线性筛处理出 $\varphi(i)$ 的前缀和，$O(n)$ 计算即可。

```cpp
const int N = 1e5 + 5;
int n;
long long pre[N];

void _main() {
	cin >> n;
	eular(n);
	for (int i = 1; i <= n; i++) pre[i] = pre[i - 1] + phi[i];
	long long res = 0;
	for (int i = 1; i <= n; i++) res += 1LL * i * (2 * pre[n / i] - 1);
	cout << res;
}
```

双倍经验：[P1390](https://www.luogu.com.cn/problem/P1390)。这个题没有对称性，把系数 $2$ 去掉即可。

### P2303 [SDOI2012] Longge 的问题

注意到 $\gcd(i,n)$ 是 $n$ 的因数，考虑枚举因数 $x$，再判断有多少 $\gcd(i,n)=x$。与上题相同，$i$ 有 $\varphi(\dfrac{n}{x})$ 个。直接用定义法求欧拉函数即可，复杂度 $O(\sqrt{n} \times d(n))$。

```cpp
#define int long long
int n;
inline int phi(int n) {
	if (n == 1) return 1;
	int res = n;
	for (int i = 2; i * i <= n; i++) {
		if (n % i == 0) {
			res = res / i * (i - 1);
			while (n % i == 0) n /= i;
		}
	}
	if (n > 1) res = res / n * (n - 1);
	return res;
}

inline void _main() {
	cin >> n;
	long long res = 0;
	for (int i = 1; i * i <= n; i++) {
		if (n % i) continue;
		res += i * phi(n / i);
		if (i * i != n) res += n / i * phi(n / (n / i));
	}
	cout << res;
}
```

### *P3768 简单的数学题

一路推式子：

$$
\begin{aligned}
&\sum_{i=1}^n\sum_{j=1}^n ij \gcd(i,j) \\
&=\sum_{i=1}^n \sum_{j=1}^n ij \sum _{d \mid i, d\mid j} \varphi(d) \\
&=\sum_{d=1}^n \varphi(d) \sum_{d \mid i, i \le n} \sum_{d\mid j, j \le n} ij\\
&=\sum_{d=1}^n d^2 \varphi(d) \sum_{i=1}^{\lfloor n/d \rfloor}i \sum_{j=1}^{\lfloor n/d \rfloor}j\\
&=\sum_{d=1}^n d^2 \varphi(d) \left (\sum_{i=1}^{\lfloor n/d \rfloor}i\right)^2 \\
&=\sum_{d=1}^n d^2 \varphi(d) (\dfrac{\lfloor n/d \rfloor \left(\lfloor n/d \rfloor+1 \right)}{2})^2
\end{aligned}
$$

稍微解释一下发生了什么：根据性质 6 将 $\gcd(i,j)$ 写成欧拉函数形式，然后交换求和顺序，接下来发现 $i,j$ 取值相同直接合并求和即可。

做到这里我们可以 $O(n)$ 解决。但是这题正解复杂度是 $O(n^{2/3})$，需要杜教筛科技，这里不作讲解。$AKB291$, '数学', array['欧拉函数', '积性函数', '筛法'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-euler-phi--xesir', '欧拉函数（单个数与线性筛） · Xesir', $AKB292$## 算法原理

**欧拉函数** $\varphi(n)$ 的定义是：**小于等于 $n$ 的正整数中，与 $n$ 互质的数的个数**。

比如 $\varphi(6)$：1 到 6 里和 6 互质的是 1 和 5，所以 $\varphi(6) = 2$。

### 性质

1. **当 $n$ 是质数时，$\varphi(n) = n - 1$**。因为质数和所有比它小的数都互质。
2. **欧拉函数是积性函数**。这意味着：如果 $\gcd(a, b) = 1$，那么 $\varphi(ab) = \varphi(a) \times \varphi(b)$。
3. **计算公式**：由质因数分解可以直接得到下面的乘积式。
4. **求和式**：$\sum_{d \mid n} \varphi(d) = n$，这条是欧拉反演的出发点。

第 3 条怎么理解？可以看做 $[1,n]$ 内的每个数含有质因数 $p_i$ 的"概率"为 $\frac{1}{p_i}$，而互质的数显然满足没有任意公共质因数，其出现的频率就是 $\prod_{i=1}^{k}\left(1 - \frac{1}{p_i}\right)$。

### 两种求法

- **单个数的欧拉函数**：直接质因数分解，边分解边算，$O(\sqrt n)$。
- **多个数的欧拉函数**：用**线性筛**（欧拉筛）一次性全算出来。因为欧拉函数是积性函数，线性筛可以在筛素数的同时，顺便把每个数的 $\varphi$ 值算出来，$O(n)$。

## 核心公式 / 状态定义与转移方程

**计算公式**：若 $n$ 的质因数分解为 $n = p_1^{a_1} p_2^{a_2} \cdots p_k^{a_k}$，则

$$
\varphi(n) = n \times \prod_{i=1}^{k} \left(1 - \frac{1}{p_i}\right)
$$

注意这个式子里只出现了**不同的质因子**，跟每个质因子的指数没关系。所以分解时只要找到一个质因子，就乘一次 $(1 - 1/p)$，然后把它的幂全部除掉即可。

**代码里的转移**（先除后乘，避免分数）：

$$
\text{ans} \leftarrow \frac{\text{ans}}{p} \times (p-1)
$$

**线性筛的递推**（$p$ 为当前质数）：

- $p \mid i$：$\varphi(ip) = \varphi(i) \cdot p$（$ip$ 与 $i$ 的质因子集合相同，只是 $p$ 的指数加一）。
- $p \nmid i$：$\varphi(ip) = \varphi(i) \cdot (p-1)$（积性，$\gcd(i,p)=1$）。

**欧拉反演**：由 $\sum_{d \mid n}\varphi(d) = n$ 出发，可以做出很多变换。原文举的例子是

$$
\sum_{i=1}^{n}\sum_{j=1}^{n}\gcd(i,j) = \sum_{i=1}^{n}\sum_{j=1}^{n}\sum_{d \mid \gcd(i,j)}\varphi(d) = \sum_{d=1}^{n}\varphi(d)\left\lfloor\frac{n}{d}\right\rfloor^{2}
$$

中间那步是把 $\gcd(i,j)$ 换成 $\sum_{d \mid \gcd(i,j)}\varphi(d)$ 并把 $d$ 提到外面；而 $[d \mid \gcd(i,j)]$ 等价于 $[d \mid i]$ 且 $[d \mid j]$，两者独立，各自的计数都是 $\lfloor n/d \rfloor$，乘起来就是平方。原来 $O(n^2)$ 的式子就这样变成了 $O(n)$。

欧拉反演只是一种思想，用于解决具体问题时需要开动脑筋，没有模板可套。

## 逐行代码解析

### 模块一：单个数求 $\varphi$

```cpp
int euler_phi(int n) {
    int ans = n;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            ans = ans / i * (i - 1);  // 公式：n × (1 - 1/i)
            while (n % i == 0) n /= i;
        }
    }
    if (n > 1) ans = ans / n * (n - 1);
    return ans;
}
```

- `ans` 初始为 $n$，正好对应公式前面的那个 $n$。
- `i * i <= n` 里比较的是**当前**的 `n`：小质因子被除干净后上界会缩小，循环提前结束。
- `ans = ans / i * (i - 1)`：乘入 $\frac{i-1}{i}$。必须先除后乘，因为 $i \mid \text{ans}$ 恒成立，而先乘可能溢出。
- `while (n % i == 0) n /= i;`：把 $i$ 的幂全部除掉。这保证同一个质因子只被乘一次——公式里只出现不同的质因子。
- 循环结束后若 `n > 1`，说明剩下的是个大于 $\sqrt{\text{原}n}$ 的质因子，补乘一次。

### 模块二：线性筛批量求 $\varphi$

```cpp
for(int j=0;j<=tot&&i*c[j]<=n;j++){
    p[i*c[j]]=true;
    if(i%c[j]==0){
        oph[i*c[j]]=oph[i]*c[j];
        break;
    }else oph[i*c[j]]=oph[i]*(c[j]-1);
}
```

- `c` 是质数表，`tot` 是它的末位下标（所以循环写 `j <= tot`）。
- `p[i*c[j]]=true`：把合数标记掉（注意这个数组里 `true` 表示合数）。
- `if(i%c[j]==0)`：$c_j$ 已经整除 $i$，即 $c_j$ 是 $i$ 的最小质因子，此时 $\varphi(ic_j) = \varphi(i)\cdot c_j$，然后 **break**。
- `else`：互质，走积性，$\varphi(ic_j) = \varphi(i)\cdot(c_j - 1)$。
- `break` 的位置和线性筛筛素数时完全一致，保证每个合数只被最小质因子筛一次。

## 复杂度分析

| 方法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 单个数试除法 | $O(\sqrt n)$ | $O(1)$ |
| 线性筛批量 | $O(n)$ | $O(n)$ |

单个数求值就是一次质因数分解，$n = 10^{12}$ 时约 $10^6$ 次试除，能过；$10^{18}$ 就不行了。批量求 $1 \sim n$ 的所有 $\varphi$ 值必须用线性筛，$O(n)$ 搞定。

## 适用场景

- **求模逆元**：$\gcd(a,n)=1$ 时 $a^{-1} \equiv a^{\varphi(n)-1} \pmod n$（欧拉定理）。
- **降幂**：计算 $a^b \bmod n$ 时把指数对 $\varphi(n)$ 取模（扩展欧拉定理还能处理不互质的情况）。
- **数论计数**：$\sum_{d \mid n}\varphi(d) = n$ 是很多计数题的变形起点。
- **欧拉反演**：把 $\gcd$ 求和类问题化成 $\varphi$ 的求和，是莫比乌斯反演的"兄弟"。
- **既约分数统计**：分母为 $n$ 的既约真分数个数就是 $\varphi(n)$。

## 常见陷阱与注意事项

1. **先除后乘**：`ans / i * (i - 1)` 不能写成 `ans * (i - 1) / i`，否则 `ans * (i-1)` 可能溢出 `int`。
2. **`while (n % i == 0) n /= i;` 不能省**：少了它，同一个质因子会被乘多次，把公式算重。
3. **收尾漏写**：`if (n > 1)` 那一步处理的是大质因子，漏掉的话质数输入会算成 $n$ 而不是 $n-1$。
4. **`int` 溢出**：`ans` 和 `i * i` 在 $n$ 接近 $2^{31}$ 时都会溢出，参数和返回类型建议用 `long long`。
5. **线性筛模板里的 `N` 是摆设**：代码里声明了 `const int mod = 998244353, N = 1e8;`，但实际用的是 `n + 10` 动态分配。真正筛到 $10^8$ 时 `vector<int> oph` 要 400MB，注意内存。
6. **`oph[1] = 1` 的位置**：模板在 `zhi(n)` **之后**才把 `oph[1]` 置 1，因为循环从 `i = 2` 开始、`1` 不会被动到。自己改代码时别把这条覆盖掉。
7. **欧拉函数不是完全积性**：$\varphi(ab) = \varphi(a)\varphi(b)$ 只在 $\gcd(a,b)=1$ 时成立，例如 $\varphi(2)\varphi(2)=1 \neq \varphi(4)=2$。
8. **$\varphi(1) = 1$**：1 与自身互质，边界别写错。$AKB292$, '数学', array['数学', '数论', '欧拉函数', '积性函数', '线性筛', '欧拉反演'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-euler-phi', '欧拉函数（单次求值）', $AKB293$## 欧拉函数（单次求值）

## 一、算法原理

### 1.1 定义

欧拉函数 $\varphi(n)$ 表示 $[1, n]$ 中与 $n$ 互质（$\gcd(k, n) = 1$）的正整数个数。

**示例**：

| $n$ | 与 $n$ 互质的数 | $\varphi(n)$ |
|-----|----------------|-------------|
| 1 | {1} | 1 |
| 2 | {1} | 1 |
| 3 | {1, 2} | 2 |
| 4 | {1, 3} | 2 |
| 5 | {1, 2, 3, 4} | 4 |
| 6 | {1, 5} | 2 |
| 12 | {1, 5, 7, 11} | 4 |

### 1.2 三条基本性质

**性质 1**：若 $p$ 为质数，则 $\varphi(p) = p - 1$

质数 $p$ 与 $[1, p-1]$ 中的每个数都互质，共 $p - 1$ 个。

**性质 2**：若 $p$ 为质数，$k$ 为正整数，则 $\varphi(p^k) = (p-1) \cdot p^{k-1}$

在 $[1, p^k]$ 中，与 $p^k$ 不互质的数恰好是 $p$ 的倍数：$p, 2p, 3p, \ldots, p^{k-1} \cdot p$，共 $p^{k-1}$ 个。因此 $\varphi(p^k) = p^k - p^{k-1} = (p-1) \cdot p^{k-1}$。

**性质 3（积性）**：若 $\gcd(m, n) = 1$，则 $\varphi(m \cdot n) = \varphi(m) \cdot \varphi(n)$

这是欧拉函数最重要的性质——当两数互质时，欧拉函数可拆分为乘积。利用积性 + 质因数分解，就能把任意 $n$ 的 $\varphi(n)$ 归约到质数幂的情况。

### 1.3 计算公式推导

设 $n$ 的质因数分解为 $n = p_1^{\alpha_1} \cdot p_2^{\alpha_2} \cdots p_s^{\alpha_s}$，则：

$$\varphi(n) = \varphi(p_1^{\alpha_1}) \cdot \varphi(p_2^{\alpha_2}) \cdots \varphi(p_s^{\alpha_s})$$

（积性，因为不同质数的幂两两互质）

$$= \prod_{i=1}^{s} (p_i - 1) \cdot p_i^{\alpha_i - 1}$$

（性质 2）

$$= \prod_{i=1}^{s} p_i^{\alpha_i} \cdot \frac{p_i - 1}{p_i}$$

（提取 $p_i^{\alpha_i}$，把 $(p_i-1) \cdot p_i^{\alpha_i - 1}$ 写成 $p_i^{\alpha_i} \cdot \frac{p_i-1}{p_i}$）

$$= n \cdot \prod_{i=1}^{s} \frac{p_i - 1}{p_i}$$

（$\prod p_i^{\alpha_i} = n$ 合并）

$$= n \cdot \prod_{i=1}^{s} \left(1 - \frac{1}{p_i}\right)$$

**关键结论**：欧拉函数仅由 $n$ 和它的**不同质因子**决定，与各质因子的幂次 $\alpha_i$ 无关。

**验证**：$\varphi(12) = \varphi(2^2 \times 3) = 12 \times \frac{1}{2} \times \frac{2}{3} = 12 \times \frac{1}{3} = 4$ ✓

互质的数：{1, 5, 7, 11}，恰好 4 个 ✓

### 1.4 朴素法 vs 公式法

| 方法 | 思路 | 复杂度 |
|------|------|--------|
| 朴素枚举 | 遍历 $k = 1 \ldots n$，逐个检查 $\gcd(k, n) = 1$ | $O(n \log n)$ |
| 公式法 | 质因数分解 + 乘积公式 | $O(\sqrt{n})$ |

当 $n = 10^{12}$ 时，朴素法完全不可行，公式法只需约 $10^6$ 次操作。

## 二、核心公式/状态定义与转移方程

### 2.1 核心公式

$$\boxed{\varphi(n) = n \cdot \prod_{p \mid n} \left(1 - \frac{1}{p}\right) = n \cdot \prod_{p \mid n} \frac{p - 1}{p}}$$

其中 $p$ 遍历 $n$ 的所有**不同质因子**。

### 2.2 算法转移

对 $n$ 做质因数分解，每找到一个质因子 $p$，就执行：

$$\text{res} \leftarrow \text{res} / p \times (p - 1)$$

等价于 $\text{res} \leftarrow \text{res} \times \frac{p-1}{p}$。

**为什么先除后乘？** $\text{res}$ 初始为 $n$，而 $p \mid n$，所以 $\text{res} / p$ 必为整数。先除保证整除，再乘避免分数运算。若写成 `res * (p-1) / p`，中间值更大，可能溢出。

### 2.3 质数判定副产物

由性质 1，$\varphi(p) = p - 1$。反过来，若 $\varphi(n) = n - 1$，则 $n$ 是质数——因为只有质数才与 $[1, n-1]$ 中所有数都互质。本代码利用这一性质附带判定了质数。

> **注意**：这只是判质数的一种方式，效率（$O(\sqrt{n})$）与试除法相同，不如筛法预处理后 $O(1)$ 查询。

### 2.4 重要性质速查

| 性质 | 公式 | 条件 |
|------|------|------|
| 质数 | $\varphi(p) = p - 1$ | $p$ 为质数 |
| 质数幂 | $\varphi(p^k) = p^k - p^{k-1}$ | $p$ 为质数，$k \ge 1$ |
| 积性 | $\varphi(mn) = \varphi(m)\varphi(n)$ | $\gcd(m, n) = 1$ |
| 完全积性？ | ❌ 不成立 | $\gcd(m,n) > 1$ 时不保证 |
| 欧拉定理 | $a^{\varphi(n)} \equiv 1 \pmod{n}$ | $\gcd(a, n) = 1$ |
| 费马小定理 | $a^{p-1} \equiv 1 \pmod{p}$ | $p$ 为质数，$\gcd(a,p)=1$（欧拉定理的特例） |
| 求和公式 | $\sum_{d \mid n} \varphi(d) = n$ | 任意正整数 $n$ |

## 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
```

标准头文件与命名空间。

### 3.1 phi —— 欧拉函数单次求值

```cpp
int phi(int n)
{
    int res = n;
    for (int i = 2; i * i <= n; i++)
    {
        if (n % i == 0) res = res / i * (i - 1);
        while (n % i == 0) n /= i;
    }
    if(n > 1) res = res / n * (n - 1);
    return res;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `int phi(int n)` | 输入 $n$，返回 $\varphi(n)$ |
| 2 | `int res = n;` | 初始化 $\text{res} = n$，后续逐个质因子乘入 $\frac{p-1}{p}$ |
| 3 | `for (int i = 2; i * i <= n; i++)` | 试除法找质因子，外层到 $\sqrt{n}$，用 `i*i` 避免浮点 |
| 4 | `if (n % i == 0) res = res / i * (i - 1);` | $i$ 是质因子 → 乘入 $\frac{i-1}{i}$（先除后乘防溢出） |
| 5 | `while (n % i == 0) n /= i;` | 把 $n$ 中所有 $i$ 的因子除干净，保证下次找到的是**不同**质因子 |
| 6 | `if(n > 1) res = res / n * (n - 1);` | 循环结束后若 $n > 1$，说明残留了一个大于 $\sqrt{\text{原}n}$ 的质因子，补乘 |
| 7 | `return res;` | 返回最终结果 |

**执行示例**（$n = 12$）：

| 步骤 | $i$ | $n$（当前） | `i*i <= n`? | 动作 | res |
|------|-----|------------|------------|------|-----|
| 初始 | — | 12 | — | res = 12 | 12 |
| $i=2$ | 2 | 12 | 4 ≤ 12 ✓ | res = 12/2*1 = 6; n = 12→6→3 | 6 |
| $i=3$ | 3 | 3 | 9 ≤ 3 ✗ | 循环退出 | 6 |
| 收尾 | — | 3 | — | n>1 → res = 6/3*2 = 4 | 4 |

$\varphi(12) = 4$ ✓ 互质的数：{1, 5, 7, 11}

### 3.2 main —— 求值 + 质数判定

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n,q;
    //注意: n >= 2
    cin >> n;
    q = phi(n);
    if (q == n - 1) cout << n << "为质数\n";
    else cout << n << "为合数\n";
    cout << n << "的欧拉函数的值为: " << q;
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快速 IO |
| 3-4 | `int n, q; cin >> n;` | 读入 $n$（注释提醒 $n \ge 2$） |
| 5 | `q = phi(n);` | 计算欧拉函数 |
| 6-7 | `if (q == n - 1) ...` | 利用 $\varphi(n) = n-1 \iff n$ 为质数的性质判定质数 |
| 8 | `cout << ... << q;` | 输出欧拉函数值 |

### 3.3 运行示例

输入：
```
12
```

输出：
```
12为合数
12的欧拉函数的值为: 4
```

输入：
```
7
```

输出：
```
7为质数
7的欧拉函数的值为: 6
```

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(\sqrt{n})$ | 试除法质因数分解，外层循环到 $\sqrt{n}$ |
| 空间 | $O(1)$ | 仅用几个变量 |

**与朴素枚举法对比**：

| 方法 | 复杂度 | $n = 10^{12}$ |
|------|--------|--------------|
| 朴素枚举 | $O(n \log n)$ | $\approx 10^{13}$，不可行 |
| 公式法 | $O(\sqrt{n})$ | $\approx 10^6$，瞬间完成 |

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **模逆元** | 由欧拉定理 $a^{\varphi(n)-1} \equiv a^{-1} \pmod{n}$（$\gcd(a,n)=1$ 时），需先求 $\varphi(n)$ |
| **RSA 加密** | 公钥密码系统的核心运算，需计算 $\varphi(n)$ 来生成密钥 |
| **质数判定** | $\varphi(n) = n - 1$ 当且仅当 $n$ 为质数 |
| **简化幂运算** | 计算 $a^k \bmod n$ 时，若 $\gcd(a,n)=1$，可把 $k$ 对 $\varphi(n)$ 取模来缩小指数 |
| **数论计数** | 欧拉函数在各种数论计数问题中作为中间量出现 |
| **分数化简** | 利用 $\sum_{d \mid n} \varphi(d) = n$ 统计分母为 $n$ 的约数的既约分数个数 |

## 六、常见陷阱与注意事项

### 6.1 n = 1 的边界

$\varphi(1) = 1$（1 与自身互质）。但本代码注释标注 $n \ge 2$，若输入 $n = 1$：循环不执行，`n > 1` 为 false，返回 `res = 1`。结果正确，但质数判定 `q == n - 1` → `1 == 0` → 判为合数，语义上 1 既不是质数也不是合数，需特判。

### 6.2 先除后乘防溢出

`res = res / i * (i - 1)` 必须先除后乘。因为 $i$ 是 $n$ 的质因子，而 `res` 初始为 $n$ 并在每步乘入 $\frac{p-1}{p}$，始终保持整除性。若写成 `res * (i-1) / i`，中间值 `res * (i-1)` 可能溢出 `int`。

### 6.3 循环中 n 被修改

`while (n % i == 0) n /= i;` 修改了 $n$ 的值，因此外层 `i * i <= n` 比较的是**当前剩余的 $n$**，不是原始 $n$。这是一个容易忽略的细节——当 $n$ 被除掉小质因子后，$\sqrt{n}$ 变小，循环可能提前结束，残留的大质因子由末尾的 `if (n > 1)` 处理。

### 6.4 int 溢出

当 $n$ 接近 `int` 上限（$\approx 2.1 \times 10^9$）时，`res`、`i * i` 可能溢出。建议参数和返回值用 `long long`：

```cpp
long long phi(long long n)
{
    long long res = n;
    for (long long i = 2; i * i <= n; i++)
    { ... }
    ...
}
```

### 6.5 欧拉函数不是完全积性的

$\varphi(mn) = \varphi(m)\varphi(n)$ **仅当** $\gcd(m, n) = 1$。若 $\gcd(m, n) > 1$，此式不成立。例如 $\varphi(2) \cdot \varphi(2) = 1 \neq \varphi(4) = 2$。

### 6.6 多次查询的效率

单次求值 $O(\sqrt{n})$ 适合少量查询。若需查询 $[1, n]$ 内所有 $\varphi$ 值，应改用线性筛批量预处理，复杂度 $O(n)$。

## 七、对比与扩展

### 7.1 单次求值 vs 筛法批量求值

| 维度 | 单次求值（本代码） | 线性筛批量预处理 |
|------|-------------------|-----------------|
| 单次复杂度 | $O(\sqrt{n})$ | $O(1)$（预处理后） |
| 预处理 | 无 | $O(n)$ |
| 适用场景 | 少量查询、$n$ 极大 | 大量查询、$n \le 10^7$ |
| 空间 | $O(1)$ | $O(n)$ |
| 额外功能 | 可附带判质数 | 可同时求 $\varphi$、$\mu$、最小质因子 |

### 7.2 欧拉定理与费马小定理

**欧拉定理**：若 $\gcd(a, n) = 1$，则 $a^{\varphi(n)} \equiv 1 \pmod{n}$。

**费马小定理**（欧拉定理的特例）：若 $p$ 为质数，$\gcd(a, p) = 1$，则 $a^{p-1} \equiv 1 \pmod{p}$（因为 $\varphi(p) = p - 1$）。

**应用**：求模逆元 $a^{-1} \equiv a^{\varphi(n)-1} \pmod{n}$；计算大幂 $a^k \bmod n$ 时把 $k$ 对 $\varphi(n)$ 取模。

### 7.3 线性筛求欧拉函数

利用积性和质因数分解，线性筛可在 $O(n)$ 内求出 $[1, n]$ 内所有 $\varphi$ 值：

- $\varphi(1) = 1$
- 若 $p$ 为质数：$\varphi(p) = p - 1$
- 若 $i \bmod p \neq 0$（$p$ 不整除 $i$，即 $\gcd(i, p) = 1$）：$\varphi(i \cdot p) = \varphi(i) \cdot \varphi(p) = \varphi(i) \cdot (p - 1)$
- 若 $i \bmod p = 0$（$p$ 整除 $i$，即 $p$ 已是 $i$ 的质因子）：$\varphi(i \cdot p) = \varphi(i) \cdot p$（因为 $ip$ 与 $i$ 的质因子集合相同，$\varphi(ip) = ip \cdot \prod \frac{q-1}{q} = p \cdot \left(i \cdot \prod \frac{q-1}{q}\right) = p \cdot \varphi(i)$）

### 7.4 欧拉函数求和公式

$$\sum_{d \mid n} \varphi(d) = n$$

**直觉理解**：考虑分数 $\frac{1}{n}, \frac{2}{n}, \ldots, \frac{n}{n}$，化简后分母为 $d$（$d \mid n$）的既约分数恰好有 $\varphi(d)$ 个，总数 $n$ 个。

### 7.5 一句话总结

欧拉函数 $\varphi(n)$ 统计 $[1, n]$ 中与 $n$ 互质的数的个数，核心公式 $\varphi(n) = n \cdot \prod_{p \mid n} \frac{p-1}{p}$ 仅由不同质因子决定、与幂次无关。单次求值用试除法质因数分解在 $O(\sqrt{n})$ 完成，先除后乘防溢出；批量求值用线性筛在 $O(n)$ 内完成全部预处理。欧拉定理 $a^{\varphi(n)} \equiv 1 \pmod{n}$ 是模逆元和大幂运算的理论基础。$AKB293$, '数学', array['数学', '数论', '欧拉函数', '积性函数', '质因数分解'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-eulerian-number--stripe-python', '欧拉数（排列上升数计数） · stripe-python', $AKB294$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的计数基础》第 7 节。

## 7. 欧拉数

对于一个 $1 \sim n$ 的排列 $p_i$，我们称 $p_i<p_{i+1}$ 这样的结构为一个上升。**欧拉数** $\left<\begin{matrix}
n \\
k
\end{matrix}\right>$ 定义为恰有 $k$ 个上升的 $1 \sim n$ 的排列数目。将排列 $p_i$ 的上升数记为 $\text{asc}(p)$。

欧拉数是一类特殊的排列计数问题。因此我们可以用排列计数 DP 的观点来求解。欧拉数问题是非常经典的插入 DP 应用。

另外，直接将下降容斥成无限制也是可以做的，下面分别介绍这些做法。

:::::success[插入 DP 观点]

考虑**按值域插入**的 DP 视角。选择插入 DP 的原因是，上升是一个局部性质，插入数字便于刻画上升的变化，也不会对其他信息产生影响。

- 记 $\left<\begin{matrix}
  n \\
  k
  \end{matrix}\right>$ 为 $\text{asc}(p)=k$ 的排列 $p_1 \sim p_n$ 的数目。

- 转移视角为：考虑在长为 $n-1$ 的排列中插入当前最大值 $n$。此时有 $n$ 个空位可以插入。

  - 将 $n$ 插入到开头，形成 $n>a_1$，不增加上升数，方案数 $1$。
  - 将 $n$ 插入到一个原有的上升 $a_i<a_{i+1}$ 中间，形成 $a_i<n>a_{i+1}$，不增加上升数，方案数 $k$。
  - 将 $n$ 插入到结尾，形成 $a_{n-1}<n$，增加 $1$ 个上升，方案数 $1$。
  - 将 $n$ 插入到一个原有的下降 $a_i>a_{i+1}$ 中间，形成 $a_i<n>a_{i+1}$，增加 $1$ 个上升，方案数 $n-1-k$。

  综上所述，转移方程 
  $$
  \left<\begin{matrix}
  n \\
  k
  \end{matrix}\right>=(k+1)\left<\begin{matrix}
  n-1 \\
  k
  \end{matrix}\right>+(n-k)\left<\begin{matrix}
  n-1 \\
  k-1
  \end{matrix}\right>
  $$

复杂度 $O(n^2)$。

:::::

:::::success[容斥观点]

设 $f(k)=\left<\begin{matrix}
n \\
k
\end{matrix}\right>$， $f$ 的组合意义是恰好。

考虑将**恰好**容斥为**钦定至少**。定义 $g(k)$ 为钦定 $k$ 个上升的 $1\sim n$ 的排列数目，$g \to f$ 的容斥系数为 $(-1)^{i-k} \dbinom{i}{k}$。

考察 $g(k)$ 的组合意义。当我们钦定 $k$ 个特定位置时，整个排列实际上被分成 $n-k$ 段。

在一段内，所有位置的符号都是 `<`，也即段内严格递增。而在段与段之间，符号都是 `?`，也即无限制。更进一步，如果我们确定了一段内填入的数字，这些数必须自动排序，所以段内方案数为 $1$，或者说段内数字不带序。

根据上面的分析，$g(k)$ 的组合意义是：将 $n$ 个有标号球划分为 $n-k$ 个非空有标号段。根据球盒模型，我们得到
$$
g(k)=(n-k)! \left\{\begin{matrix}n\\n-k\end{matrix}\right\}
$$
配上容斥系数代入 $f$ 得
$$
\left<\begin{matrix}
n \\
k
\end{matrix}\right>=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k} (n-i)!\left\{\begin{matrix}n\\n-i\end{matrix}\right\}
$$
这就是欧拉数的通项公式。

为了获得更低的复杂度，可以代入第二类斯特林数的通项公式化简。请读者注意，这个过程隐含了第二次容斥。
$$
\begin{aligned}
\left<\begin{matrix}
n \\
k
\end{matrix}\right>&=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k} (n-i)!\left\{\begin{matrix}n\\n-i\end{matrix}\right\}\\
&=\sum_{i=k}^n (-1)^{i-k} \binom{i}{k}\sum_{j=0}^{n-i} (-1)^{n-i-j} \binom{n-i}{j} j^n\\
&= \sum_{i=k}^n \sum_{j=0}^{n-i} (-1)^{n-k-j} \binom{i}{k} \binom{n-i}{j} j^n\\
&= \sum_{j=0}^{n-k} (-1)^{n-k-j} j^n \sum_{i=k}^{n-j} \binom{i}{k} \binom{n-i}{j}\\
&= \sum_{j=0}^{n-k} (-1)^{n-k-j} j^n \binom{n+1}{k+j+1}
\end{aligned}
$$
倒数第一步使用了范德蒙德卷积。令 $i=n-k-j$ 可以得到一个更好看的式子：
$$
\left<\begin{matrix}
n \\
k
\end{matrix}\right>=\sum_{i=0}^{n-k} (-1)^i \binom{n+1}{i} (n-k-i)^n
$$
这是一个 $O(n \log n)$ 的式子。

:::::$AKB294$, '数学', array['欧拉数', '排列计数', '插入 DP', '容斥'], 'col-math-combinatorics', null, 'knowledge'),
('Xesir', 'col-math-exgcd--xesir', '裴蜀定理与扩展欧几里得（EXGCD） · Xesir', $AKB295$## 算法原理

### 裴蜀定理

**定理内容**：对于**不全为零**的整数 $a, b$，**一定存在**整数 $x, y$，使得：

$$
ax + by = \gcd(a, b)
$$

也就是说，$a$ 和 $b$ 的最大公约数，一定能被表示成它们的某个整系数线性组合。

**反过来也成立**：如果某个整数 $d$ 能表示成 $ax + by$ 的形式，那么 $d$ **一定是 $\gcd(a, b)$ 的倍数**。

**证明思路**：用辗转相除法倒推。辗转相除的每一步都能写成“被除数 = 商 × 除数 + 余数”，从最后一步往前代换，就能把 $\gcd(a,b)$ 表示成 $a$ 和 $b$ 的线性组合。

**有什么用？** 最直接的应用：**判断一个方程有没有整数解**。

比如方程 $ax + by = c$ 有整数解，当且仅当 $\gcd(a,b) \mid c$。有了这个结论，你就不用傻傻地枚举 $x, y$ 了，看一眼整除关系就完事。

> 裴蜀定理本身不告诉我们怎么快速找到 $x, y$，求解需要依赖**扩展欧几里得**算法。

### 扩展欧几里得算法（EXGCD）

**它要解决的问题**：给定 $a, b$，求一组整数解 $(x, y)$，使得：

$$
ax + by = \gcd(a, b)
$$

~~裴蜀定理的施工队~~

扩展欧几里得是**在辗转相除的过程中顺手把 $x, y$ 也算出来**。回顾辗转相除法：

$$
\gcd(a, b) = \gcd(b, a \bmod b)
$$

假设我们已经求出了 $b$ 和 $a \bmod b$ 的线性组合：

$$
b \cdot x_2 + (a \bmod b) \cdot y_2 = \gcd(b, a \bmod b)
$$

而 $a \bmod b = a - \lfloor a/b \rfloor \cdot b$，代入上式：

$$
b \cdot x_2 + (a - \lfloor a/b \rfloor \cdot b) \cdot y_2 = \gcd(a, b)
$$

整理一下：

$$
a \cdot y_2 + b \cdot \left( x_2 - \lfloor a/b \rfloor \cdot y_2 \right) = \gcd(a, b)
$$

于是我们就得到了递推关系：

$$
\begin{cases}
x_1 = y_2 \\
y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2
\end{cases}
$$

递归边界：当 $b = 0$ 时，$\gcd(a, 0) = a$，此时 $x = 1, y = 0$。

## 核心公式

| 内容 | 公式 |
|---|---|
| 裴蜀定理 | $ax + by = \gcd(a,b)$ 一定有整数解 |
| 有解判定 | $ax + by = c$ 有整数解 $\iff \gcd(a,b) \mid c$ |
| EXGCD 递推 | $x_1 = y_2,\ y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2$ |
| 递归边界 | $b=0$ 时 $x=1,\ y=0,\ \gcd=a$ |
| 求逆元 | $ax + my = 1$ 的解 $x$ 即 $a^{-1} \pmod{m}$ |
| 同余方程 | $ax \equiv b \pmod{m}$，$x_0 \cdot (b/\gcd)$ 为一组解 |

## 逐行代码解析

### 模块一：递归求解 $ax + by = \gcd(a,b)$

```cpp
// 返回gcd(a,b)，并输出x,y
ll exgcd(ll a, ll b, ll &x, ll &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
```

- `x, y` 是引用传参，递归返回时把当前层的解带回去。
- 边界 `b == 0`：$\gcd(a,0)=a$，此时 $a \cdot 1 + 0 \cdot 0 = a$，所以 `x = 1, y = 0`。
- 返回的 `d` 是最外层调用的 $\gcd(a,b)$，递归过程中一路原样上传。

```cpp
    ll d = exgcd(b, a % b, y, x); // 注意x和y的位置交换
    y -= (a / b) * x;             // 递推更新y
    return d;
}
```

- 注意实参写的是 `y, x` 而不是 `x, y`：这是把下一层的 $x_2$ 直接接到这一层的 $y_1$ 上，省掉一次赋值。
- 交换之后，`y` 里装的是下一层的 $x_2$，`x` 里装的是下一层的 $y_2$。
- `y -= (a / b) * x;` 实现的就是 $y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2$。
- 递归返回后，`x, y` 满足 $ax + by = d$。

### 模块二：用它解线性同余方程

```cpp
// 解线性同余方程 ax ≡ b (mod m)，返回特解（无解返回-1）
ll sl(ll a, ll b, ll m) {
    ll x, y;
    ll d = exgcd(a, m, x, y);
    if (b % d != 0) return -1;
```

- 把 $ax \equiv b \pmod{m}$ 改写成 $ax + my = b$，所以调用 `exgcd(a, m, x, y)`。
- `d = gcd(a, m)`；若 $d \nmid b$，由裴蜀定理，方程无整数解，返回 `-1`。

```cpp
    ll m1 = m / d;
    x = (x * (b / d)) % m1;
    return (x + m1) % m1; // 确保解非负
}
```

- 先乘上 $b/d$，把 $ax+my=d$ 的特解放大成 $ax+my=b$ 的特解。
- 通解是 $x + k \cdot (m/d)$，所以最小正解对 `m1 = m / d` 取模。
- 最后 `(x + m1) % m1` 处理负数，保证返回非负解。

**注**：EXGCD 求出的可行解满足 $|x| \le b$，$|y| \le a$，一般不会爆 `long long`，可以放心用。

## 复杂度分析

- 时间复杂度：与辗转相除相同，递归层数为 $O(\log \min(a,b))$，每层常数次运算。
- 空间复杂度：递归栈深度 $O(\log \min(a,b))$。
- 单次求逆元、单次解线性同余方程都是这个量级，非常适合多次调用。

## 适用场景

- **求逆元**：解 $ax \equiv 1 \pmod{m}$，等价于 $ax + my = 1$。调用 `exgcd(a, m, x, y)`，得到的 $x$ 就是逆元。**不要求模数是质数**，只要 $\gcd(a, m) = 1$ 就行。
- **解线性同余方程**：$ax \equiv b \pmod{m}$ 有解当且仅当 $\gcd(a, m) \mid b$，解就是 $x_0 \cdot (b / \gcd)$。
- **解不定方程**：$ax + by = c$，先求 $ax + by = \gcd$ 的一组特解，再乘上 $c / \gcd$。
- **exCRT 的底层工具**：扩展中国剩余定理每次合并两个同余式，都要用 EXGCD 解一个形如 $M \cdot t \equiv a_k - a \pmod{m_k}$ 的方程。
- **求最小非负解**：通解 $x + k \cdot (m/d)$，对 $m/d$ 取模即可。

## 常见陷阱

1. **忘了判断 $d \nmid b$**：直接乘 $b/d$ 会用到整除，若不整除，算出来的“解”是错的。
2. **取模对象写错**：通解周期是 $m/\gcd(a,m)$，不是 $m$。对 $m$ 取模会漏解。
3. **负数解没处理**：C++ 的 `%` 可能返回负数，最后要 `(x % m1 + m1) % m1`。
4. **递归传参顺序**：`exgcd(b, a % b, y, x)` 的 `y, x` 是故意交换的，改成 `x, y` 就必须补上临时变量交换，否则递推式对不上。
5. **乘法溢出**：$x \cdot (b/d)$ 在 $a, b$ 接近 $10^{18}$ 时会爆 `long long`，需要 `__int128` 或龟速乘。
6. **`a` 或 `b` 为负数**：递归里 `a % b` 的符号随 `a`，边界和取模要额外小心，竞赛里一般先取绝对值再补符号。

---
> 裴蜀定理告诉你“有解”，EXGCD 告诉你“解是什么”。这两件事分清楚，很多数论题的思路就不会乱。$AKB295$, '数学', array['数学', '数论', '裴蜀定理', '扩展欧几里得', 'EXGCD', '逆元', '线性同余方程'], 'col-hub-math-number-theory', null, 'knowledge'),
('Fohen', 'col-math-factorization--fenfeng', 'Pollard-Rho 质因数分解 · Fohen', $AKB296$## 算法原理

Pollard-Rho 用于**大整数的质因数分解**。当 $n$ 大到 $10^{18}$ 级别，试除法需要枚举到 $\sqrt{n} \approx 10^9$，直接超时。Pollard-Rho 把「逐个试因子」换成「**随机猜因子**」，借助**生日悖论**大幅降低尝试次数。

**生日悖论**：一个房间要多少人，才能让「至少两个人同一天生日」的概率超过 50%？直觉是 183 人（365 的一半），但答案是 **23 人**。原因在于比较对象不是「某个人和你是否同天」，而是「任意两个人之间」：$k$ 个人两两配对的组合数是 $\binom{k}{2} \approx \frac{k^2}{2}$，随 $k$ 平方增长，碰撞来得远比直觉早。

把生日悖论搬到因数分解上：设 $n$ 有一个（未知的）质因子 $p$，必有 $p \le \sqrt{n}$。若随机生成 $k$ 个数并对 $p$ 取模，当 $k \approx \sqrt{p}$ 时，几乎必然有两个数同余，即 $x_i \equiv x_j \pmod{p}$。此时 $p \mid (x_i - x_j)$，于是 $\gcd(\lvert x_i - x_j \rvert, n)$ 是 $p$ 的倍数，极大概率就是 $n$ 的一个**非平凡因子**（既不是 $1$ 也不是 $n$）。

关键点在于 $p \le \sqrt{n}$，所以 $\sqrt{p} \le n^{1/4}$：只需约 $n^{1/4}$ 次随机「碰撞」就能挖出一个因子，比试除法的 $\sqrt{n}$ 快得多。找到因子后递归分解，直到全部拆成质数。

具体怎么生成随机数？Pollard-Rho 用一个**伪随机递推** $x_{i+1} \equiv (x_i^2 + c) \pmod{n}$。因为状态只有 $n$ 种，序列必然进入循环；「尾巴 + 环」整体形似希腊字母 $\rho$，算法因此得名。对 $p$ 取模后状态只有 $p$ 种，环更短（约 $\sqrt{p}$），所以在模 $p$ 意义下先碰撞、在模 $n$ 意义下尚未碰撞——正是这种「差」暴露了因子。

## 核心公式 / 状态定义与转移方程

**伪随机递推**：

$$
x_{i+1} \equiv (x_i^2 + c) \pmod{n}, \qquad c \not\equiv 0,\ -2 \pmod{n}
$$

**生日悖论（碰撞概率）**：$k$ 个数中至少有一对模 $p$ 同余的概率约为

$$
P \approx 1 - e^{-k^2 / (2p)}
$$

当 $k \approx \sqrt{p}$ 时 $P$ 超过 $50\%$。

**碰撞给出因子**：若 $x_i \equiv x_j \pmod{p}$ 且 $x_i \not\equiv x_j \pmod{n}$，则

$$
d = \gcd(\lvert x_i - x_j \rvert, n), \qquad 1 < d < n
$$

**复杂度依据**：$p \le \sqrt{n} \implies \sqrt{p} \le n^{1/4}$，因此期望尝试次数为 $O(n^{1/4})$。

## 逐行代码解析

Pollard-Rho 的完整实现还需配合 Miller-Rabin 素性测试与防溢出模乘，下面用伪代码分模块讲解核心流程。

### 模块一：伪随机递推与 ρ 形结构

```cpp
// 伪随机递推：x_{i+1} ≡ (x_i^2 + c) (mod n)
long long f(long long x, long long c, long long n) {
    return ((__int128)x * x + c) % n;   // __int128 防止 x*x 溢出
}
```

- 递推是「伪随机」的：给定 $n$ 与 $c$ 后序列完全确定，但取值在 $[0, n)$ 上乱跳。
- 状态只有 $n$ 种，序列必然进入循环；「尾巴 + 环」构成 $\rho$ 形，是算法名字的由来。
- 平方项让相邻值快速散开；改变 $c$ 可换一条新序列，供失败时重试。

### 模块二：Floyd 判环（龟兔赛跑）

```cpp
// 快慢指针在「模 p 的环」上必然相遇，差值暴露因子
x = f(x, c, n);              // 慢指针（乌龟）走一步
y = f(f(y, c, n), c, n);     // 快指针（兔子）走两步
d = gcd(abs(x - y), n);      // 相遇时 |x - y| 是 p 的倍数
```

- 无需存下整条序列：只维护两个指针 $x$（慢）与 $y$（快）。
- 当序列在模 $p$ 上成环时，快慢指针必然在同一环内追上，即 $x \equiv y \pmod{p}$。
- 此时 $p \mid (x - y)$，$\gcd(\lvert x - y \rvert, n)$ 就是候选因子 $d$。

### 模块三：单次 Pollard-Rho 找非平凡因子

```cpp
long long pollard_rho(long long n) {
    if (n % 2 == 0) return 2;             // 偶数特判，直接拆出 2
    long long c = rand() % (n - 1) + 1;   // 随机常数 c（避开 0 与 -2）
    long long x = rand() % n, y = x, d = 1;
    while (d == 1) {                      // 未碰撞则继续推进
        x = f(x, c, n);
        y = f(f(y, c, n), c, n);
        d = gcd(abs(x - y), n);
    }
    return d == n ? pollard_rho(n) : d;   // d==n 撞在模 n 上，换 c 重试
}
```

- $d = 1$ 说明还没碰撞，继续推进序列。
- $d = n$ 说明 $x \equiv y \pmod{n}$，这次运气不好，换随机 $c$ 重新跑。
- $1 < d < n$ 时，$d$ 就是一个非平凡因子。

### 模块四：Miller-Rabin 判质数 + 递归分解

```cpp
void factorize(long long n, vector<long long>& fac) {
    if (n == 1) return;
    if (is_prime(n)) { fac.push_back(n); return; }   // Miller-Rabin 判定质数
    long long d = pollard_rho(n);                    // 拆出非平凡因子
    factorize(d, fac);                               // 递归分解 d
    factorize(n / d, fac);                           // 递归分解另一半
}
```

- `is_prime` 用 Miller-Rabin 随机化素性测试，误判概率可忽略（详见「对比与扩展」）。
- 找到因子 $d$ 后对 $d$ 与 $n/d$ 分别递归，直到全部拆成质数。
- 分工：Pollard-Rho 负责「拆」，Miller-Rabin 负责「判定是否还要拆」。

## 复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(n^{1/4})$（期望） | 每个因子期望 $O(n^{1/4})$ 次迭代找到；每次迭代一次模乘与一次 gcd |
| 空间 | $O(1)$ | Floyd 判环只需两个指针，不存整条序列 |

**与试除法对比**：试除法 $O(\sqrt{n})$，Pollard-Rho $O(n^{1/4})$。当 $n = 10^{18}$ 时，$\sqrt{n} \approx 10^9$ 已经扛不住，而 $n^{1/4} \approx 3 \times 10^4$ 瞬间完成。

## 适用场景

- 大整数质因数分解：$n$ 到 $10^{18}$ 甚至更大（配合 Miller-Rabin），试除法顶不住时。
- 只需单个非平凡因子（不要求全部质因子）时，可只调用一次 `pollard_rho`。
- 数论题里对 $n$ 做唯一分解、求 $\varphi(n)$、求约数个数/约数和等，当 $\sqrt{n}$ 过不了时。

## 常见陷阱与注意事项

1. **模乘溢出**：$x \cdot x$ 在 $n$ 接近 $2^{63}$ 时会溢出，必须用 `__int128` 或龟速乘做模乘。
2. **$d = n$ 的失败**：撞在模 $n$ 上得到的 $\gcd = n$ 不是有效因子，必须换 $c$ 重试（递归重跑）。
3. **$c$ 的取值**：$c = 0$ 或 $c = -2$ 时序列会退化（很快循环），应避开。
4. **初值固定**：随机化初始 $x$ 与 $c$，否则对某些 $n$ 可能反复失败。
5. **必须配合素性测试**：Pollard-Rho 只能拆合数，需 Miller-Rabin 先判质数，否则会无限递归。
6. **偶数特判**：偶数 $n$ 直接返回 $2$，否则平方递推在偶数上表现差。

## 对比与扩展

| 方法 | 复杂度 | 适用 |
|------|--------|------|
| 试除法 | $O(\sqrt{n})$ | $n \le 10^{12}$ 左右 |
| Pollard-Rho | $O(n^{1/4})$（期望） | $n$ 到 $10^{18}$ 甚至更大 |
| 埃氏筛 / 线性筛 | $O(n\log\log n)$ / $O(n)$ | 批量筛出 $[1,n]$ 的质因子，$n \le 10^7$ |

扩展：

- **Miller-Rabin**：随机化素性测试，与 Pollard-Rho 组成完整的「大整数分解」工具链。
- **Brent 判环**：Floyd 判环的改进版，减少 gcd 调用次数，常数更小。
- **平方根攻击思想**：Pollard-Rho 是「用碰撞把 $O(n)$ 降到 $O(\sqrt{n})$」的典型例子，同源的还有 BSGS（大步小步）、Meet-in-the-Middle 等，核心都是生日悖论。$AKB296$, '数学', array['数学', '数论', '质因数分解', '随机化算法', '生日悖论'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-factorization--xesir', '质因数分解（试除法与 Pollard-Rho） · Xesir', $AKB297$## 算法原理

根据**算术基本定理**，任何一个大于 1 的整数都能唯一地分解成若干个素数的乘积。比如 $12 = 2^2 \times 3$，$114514 = 2 \times 31 \times 1847$。

问题来了：**给一个数，怎么快速把它拆开？**

### 朴素算法：试除法

最直接的想法：从 2 开始，一个一个试除。如果 $i$ 能整除 $n$，那 $i$ 就是一个质因子，然后把 $n$ 里的 $i$ 全部除掉，继续试。

**为什么只试到 $\sqrt n$？** 因为因数成对出现，如果 $n$ 有大于 $\sqrt n$ 的因子，那它一定对应一个小于 $\sqrt n$ 的因子。

试除法的复杂度是 $O(\sqrt n)$。$n$ 在 $10^{12}$ 以内还能跑，但到了 $10^{18}$ 就扛不住了。这时候就需要更骚的操作。

## 核心公式 / 状态定义与转移方程

**算术基本定理**：

$$
n = p_1^{a_1} p_2^{a_2} \cdots p_k^{a_k}, \qquad p_1 < p_2 < \cdots < p_k
$$

**试除法的循环不变量**：每轮开始前，当前剩下的 $n$ 已经不含任何小于 $i$ 的质因子。所以

$$
\text{若 } i \mid n,\ \text{则 } i \text{ 必为质数}
$$

这个结论很关键：我们根本不需要判断 $i$ 是不是质数，因为比 $i$ 小的因子早就被除干净了，能整除当前 $n$ 的 $i$ 一定是质数。

**循环边界**：只要 $i^2 \le n$ 就继续。循环结束时若还有 $n > 1$，剩下的这个 $n$ 一定是个质数（否则它会有不超过 $\sqrt n$ 的因子，早被除掉了）。

## 逐行代码解析

### 模块一：主循环找质因子

```cpp
vector<int> breakdown(int n) {
    vector<int> res;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            while (n % i == 0) n /= i;
            res.push_back(i);
        }
    }
```

- `res` 存分解出来的质因子。
- `i * i <= n` 里的 `n` 是**当前**的 `n`，不是原始的 `n`。每除掉一个因子，上界都会跟着变小，循环会提前结束。
- `if (n % i == 0)`：找到一个质因子（依据上面那条不变量，能整除的一定是质数）。
- `while (n % i == 0) n /= i;`：把 $i$ 的幂次全部除干净。这一步既是"去重"，也保证了后面不会再把同一个质因子算第二次。

### 模块二：收尾

```cpp
    if (n > 1) res.push_back(n);
    return res;
}
```

- 循环结束后如果 `n > 1`，说明剩下的是一个大于 $\sqrt{\text{原}n}$ 的质因子，要单独补进去。
- 这一步不能省：比如 $n = 14$，循环在 $i = 2$ 时把 2 除走，剩下的 7 不会再被任何 $i$ 扫到。
- 返回的是**不同的**质因子（每个只出现一次），因为 `while` 把重复的幂次都除掉了。如果需要带指数的分解式，得另外记次数。

## 复杂度分析

| 方法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 试除法 | $O(\sqrt n)$ | $O(1)$（不计返回的 vector） |
| 先线性筛再分解（$n$ 不大时） | $O(\sqrt n)$ 预处理 + $O(\log n)$ 单次 | $O(\sqrt n)$ |
| Pollard-Rho | 期望 $O(n^{1/4})$ 找到一个非平凡因子 | 视实现而定 |

试除法最坏情况是 $n$ 为质数，要试到 $\sqrt n$；平均情况因为会不断除掉小因子，实际循环次数远小于 $\sqrt n$。

## 适用场景

- **单个数分解**：$n \le 10^{12}$ 时直接试除，够用且好写。
- **欧拉函数、约数个数、约数和**：都建立在质因数分解之上。
- **判断一个数是不是完全平方 / 完全立方**：分解后看指数即可。
- **多组数据**：先线性筛出 $\sqrt{\max n}$ 以内的质数，再用质数表去试除，能省掉大量无用枚举。

## 常见陷阱与注意事项

1. **收尾的 `if (n > 1)` 漏写**：这是最常见的错误，$n = 2p$（$p$ 是大质数）这类数据会直接少一个因子。
2. **`i * i <= n` 的溢出**：`i`、`n` 是 `int` 且 $n$ 接近 $2^{31}$ 时 `i * i` 会溢出成负数，循环提前结束。用 `long long` 或写 `i <= n / i`。
3. **返回的是去重后的质因子**：如果你的题目要的是"$12 = 2^2 \times 3$"这种带指数的形式，这个函数给不了，得自己在 `while` 里数次数。
4. **忘了 `n` 会被改**：函数参数是按值传递的，所以外面传进来的数不会被改；但如果自己写的时候用了引用，调用完之后原来的 `n` 就变成 1 了。
5. **$n = 1$ 或 $n = 0$**：$1$ 没有质因子，函数返回空 vector；$0$ 和负数不在算术基本定理的范围内，要特判。

## 对比与扩展：Pollard-Rho

当 $n$ 大到 $10^{18}$ 级别，试除法直接暴毙。Pollard-Rho 算法应运而生。

它的核心思想非常粗暴，就是**随机猜因子**。

> 不考虑年份，一个房间要多少人，才能让**至少两个人同一天生日**的概率超过 50%？
> 直觉告诉你可能是 183 人（365 的一半）。但答案是——**23 人**。
> 为什么会这样？因为比较的对象不是"某个人和你同一天"，而是"任意两个人之间"。人数一多，两两配对的组合数暴涨，撞车的概率就上去了。

把这个思路搬到因数分解上：与其一个一个试因子，不如随机生成一堆数，看它们之间有没有"碰撞"——即两个数的差的绝对值正好是 $n$ 的因子。

Pollard-Rho 利用这个思想，可以在期望 $O(n^{1/4})$ 的时间内找到一个非平凡因子（既不是 1 也不是 $n$ 本身的因子）。找到之后递归分解，直到全部拆成质数。

> ~~别问我具体怎么操作，我也不会，等我学完再说 soon~~

一句话总结：试除法是"暴力枚举因子"，Pollard-Rho 是"随机撞因子"。前者 $O(\sqrt n)$，后者期望 $O(n^{1/4})$；$n = 10^{18}$ 时前者要试 $10^9$ 次，后者只到 $10^4$ 量级，差了四个数量级。$AKB297$, '数学', array['数学', '数论', '质因数分解', '算术基本定理', 'Pollard-Rho'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-gauss-elimination--stripe-python', '高斯消元 · stripe-python', $AKB298$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 22. 高斯消元

## 22.1 步骤

高斯消元是用来解线性方程组或异或方程组的一种算法。下面先以线性方程组

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 -3x-y+2z=-11  \\
 -2x+y+2z=-3 
\end{matrix}\right.
$$

为例说明。

我们通过三种基本操作来消元（这些操作保证方程组的解不会改变）：

1. 交换方程位置：例如，把第一个方程和第二个方程互换。
2. 乘以非零常数：例如，将某个方程两边同时乘以 2 或 -3（但不能乘以 0）。
3. 添加一个方程的倍数：例如，把第一个方程的 2 倍加到第二个方程上。

高斯消元有两个步骤，第一步为前向消元（即简化方程组），第二部为回代求解。

### 前向消元

这一步消元后，方程组变成“三角形”形式，即每个方程比前一个少一个变量。我们从上到下逐个变量处理。

- **第一步：在方程 2 和 3 中消去 $x$**
  - 把方程 1 作为最后留下 $x$ 的那个方程，因为 $x$ 的**系数不为 $0$**。
  - 处理方程 2：计算一个倍数使得 $x$ 的系数为 $0$。倍数 $m=\dfrac{-3}{2}=-1.5$，也就是用方程 2 的 $x$ 系数去除以方程 1 的系数。则方程 2 化为 $(-3x-y+2z)-m(2x+y-z)=0.5y+0.5z=-11-8m=1$。为方便讲解这里化为 $y+z=2$。
  - 处理方程 3：仿照上例，将方程 3 的 $x$ 系数化为 $0$。此时，$m=\dfrac{-2}{2}=-1$，方程 3 化为 $( -2x+y+2z)-m(2x+y-z)=2y+z=-3-8m=5$。
  - 现在方程组已经化为

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 y+z=2  \\
 2y+z=5 
\end{matrix}\right.
$$

- **第二步：在方程 3 中消去 $y$**
  - 此步骤忽略方程 1，因为其存在 $x$ 项。
  - 把方程 2 作为最后留下 $y$ 的那个方程，因为 $y$ 的**系数不为 $0$**。
  - 处理方程 3：仿照上例，将方程 3 的 $y$ 系数化为 $0$。此时，$m=\dfrac{2}{1}=2$，方程 3 化为 $(2y+z)-m(y+z)=-z=5-2m=1$。
  - 现在方程组已经化为

$$
\left\{\begin{matrix}
 2x+y-z=8  \\
 y+z=2  \\
 -z=1 
\end{matrix}\right.
$$

至此，方程组已被化为“三角形”形式，最后一个方程可直接求得 $z=-1$。

### 回代求解

从最后一个方程开始，逐个求解变量，并代入前一个方程。

比如这里求得 $z=-1$，代入方程 2 得 $y=3$，再代进方程 1 中解得 $x=2$，所以方程组的解为

$$
\left\{\begin{matrix}
 x=2  \\
 y=3  \\
 z=-1 
\end{matrix}\right.
$$

还可以考虑无解 / 无穷多解的情况。无解时，一条方程形如 $0x=c$，其中 $c$ 是不为 $0$ 的常数。而无穷多解则是 $0x=0$ 的形式。

## 22.2 模板

在实现时，通常需要保证选择的主元系数的绝对值尽量大，这样可以减小精度误差。

```plaintext
template <int N>
class GuassSolution {
private:
	int n, m;
	double a[N][N];
public:
	explicit GuassSolution(int _n) : n(_n), m(0) {}
	template <class T> void add(const T& it, double val) {
		for (int i = 0; i < n; i++) a[m][i] = it[i];
		a[m][n] = val, m++;
	}

	template <class T> int solve(T it, double eps = 1e-9) {  // 无解-1，唯一解0，无穷解1
		int ln = 0;
		for (int k = 0; k < n; k++) {  // 消去x_k
			int mx = ln;
			for (int i = ln + 1; i < m; i++) {
				if (abs(a[i][k]) > abs(a[mx][k])) mx = i;
			}  // 找x_k系数不为0的方程
			if (abs(a[mx][k]) < eps) continue;
			for (int j = 0; j <= n; j++) swap(a[ln][j], a[mx][j]);
			for (int i = 0; i < m; i++) {  // 在方程中消去x_k
				if (i == ln) continue;
				double x = a[i][k] / a[ln][k];  // 变系数
				for (int j = k; j <= n; j++) a[i][j] -= a[ln][j] * x;  // 加减消元
			} ln++;
		}
		if (ln < n) {  // 意味着有一条方程的左边为 0
			for (; ln < n; ln++) {
				if (abs(a[ln][n]) > eps) return -1;
			}
			return 1;
		}
		for (int i = 0; i < n; i++) it[i] = a[i][n] / a[i][i];  // 回代求解
		return 0;
	}
};
```

显然可以看出复杂度为 $O(n^2m)$，其中 $n$ 为未知数的个数，$m$ 为方程的条数。

## 22.3 异或方程组

上述过程可以给出线性方程组的数值解法，而若方程形如

$$
\left\{\begin{matrix}
a_{1,1} x_1 \oplus a_{1,2} x_2 \oplus \cdots \oplus a_{1,n} x_n = v_1 \\
a_{2,1} x_1 \oplus a_{2,2} x_2 \oplus \cdots \oplus a_{2,n} x_n = v_2 \\
\cdots \\
a_{m,1} x_1 \oplus a_{m,2} x_2 \oplus \cdots \oplus a_{m,n} x_n = v_m
\end{matrix}\right.
$$

其中 $a_{i,i}, v_i \in \{0,1\}$，则仍然可以使用类似方法解决。具体地，因为异或有结合律、交换律，并且我们还不用乘除来改变系数，直接异或消元就行了。然而异或方程组会出现“自由元”，比如方程组

$$
\left\{\begin{matrix}
x_1 \oplus x_2 = 1 \\
x_2 \oplus x_3 = 1 \\
x_1 \oplus x_3 = 0
\end{matrix}\right.
$$

与线性方程组不同，即使 $n$ 元有 $n$ 个方程也会多解。上述异或方程组逻辑上为：$x_1=x_3$ 且 $x_1 \ne x_2$。于是 $x_3$ 取 $0,1$ 都是可以的。对于这种自由元，我们只能全解完后 dfs 暴力求解。

可以用 bitset 优化，时间复杂度变为 $O(\dfrac{n^2m}{w})$。

## 22.4 例题

### P2455 [SDOI2006] 线性方程组

高斯消元板子。

```cpp
int n, a[N];
double x[N];

void _main() {
	cin >> n;
	GuassSolution<N> sol(n);
	for (int i = 1; i <= n; i++) {
		for (int i = 0; i <= n; i++) cin >> a[i];
		sol.add(a, a[n]);
	}
	int opt = sol.solve(x + 1);
	if (opt == -1) cout << -1;
	else if (opt == 1) cout << 0;
	else {
		for (int i = 1; i <= n; i++) {
			cout << 'x' << i << '=';
			if (abs(x[i]) > 1e-5) cout << fixed << setprecision(2) << x[i] << '\n';
			else cout << 0 << '\n';  // 这里不这样处理的话会出现 -0.00 的输出
		}
	}
}
```

### P4035 [JSOI2008] 球形空间产生器

好像这题沦落为退火板子了（

根据题意列方程，设球心为 $(x_1,x_2,x_3,\cdots,x_n)$，则

$\forall 1 \le i \le n+1, \sum_{j=1}^{n} (a_{i,j}-x_j)^2=r^2$定睛一看是二次方程。这里用到一个 trick，相邻两个方程作差，此时化为 $n$ 元一次方程组，满足

$\forall 1 \le i \le n, \sum_{j=1}^{n} [{a_{i,j}}^2-{a_{i+1,j}}^2-2x_j(a_{i,j}-a_{i+1,j})]=0$化成标准形式

$\forall 1 \le i \le n, \sum_{j=1}^{n} 2x_j(a_{i,j}-a_{i+1,j})=\sum_{j=1}^{n}({a_{i,j}}^2-{a_{i+1,j}}^2)$于是就可以高斯消元解方程组了。

```cpp
const int N = 100;
int n;
double a[N][N], b[N], x[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n + 1; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	GuassSolution<N> sol(n);
	for (int i = 1; i <= n; i++) {
		double v = 0;
		for (int j = 1; j <= n; j++) {
			b[j - 1] = 2.0 * (a[i][j] - a[i + 1][j]);
			v += a[i][j] * a[i][j] - a[i + 1][j] * a[i + 1][j];
		} sol.add(b, v);
	} sol.solve(x);
	for (int i = 0; i < n; i++) cout << fixed << setprecision(3) << x[i] << ' ';
}
```

### *P2011 计算电压

请物竞生来应该能秒掉罢。

考虑用物理知识列方程，由基尔霍夫定律可得流入电流等于流出电流，且根据电压本质是电势差可得

$\sum_{(j, i)} \dfrac{U_j-U_i}{R_{j,i}}=\sum_{(i,k)} \dfrac{U_i-U_k}{R_{i,k}}$用到了欧姆定律 $I=\dfrac{U}{R}$。意义是 $i$ 节点的入边贡献的电流等于出边的总电流，取并集

$\sum_{(i,j)} \dfrac{U_j-U_i}{R_{i,j}}=0$这个式子最大的好处是化边权为点权且无需判断电流方向。

然后我们枚举点 $i$，若它直接连向电源，电压就是给出的值，否则枚举出边列方程，这样是一个 $n$ 元一次方程组，且主元系数均不为 $0$，故一定有解。可以发现复杂度为 $O(n^3+m)$。

```cpp
const int N = 2e5 + 5;

int tot = 0, head[N];
struct Edge {
	int next, to; double dis;
} edge[N << 1];
inline void add_edge(int u, int v, double w) {
	edge[++tot].next = head[u], edge[tot].to = v, edge[tot].dis = w, head[u] = tot;
}

int n, m, k, q, u, v, num;
double val, h[N], U0[N], U[N];

void _main() {
	cin >> n >> m >> k >> q;
	GuassSolution<205> sol(n);
	for (int i = 1; i <= k; i++) cin >> u >> U0[u];
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> val;
		add_edge(u, v, val), add_edge(v, u, val);
	}
	for (int u = 1; u <= n; u++) {
		fill(h + 1, h + n + 1, 0);
		if (U0[u] > 0) {
			h[u] = 1, sol.add(h + 1, U0[u]);
		} else {
			for (int j = head[u]; j != 0; j = edge[j].next) {
				int v = edge[j].to; double w = edge[j].dis;
				h[v] += 1.0 / w, h[u] -= 1.0 / w;
			} sol.add(h + 1, 0);
		}
	}
	sol.solve(U + 1);
	while (q--) cin >> u >> v, cout << fixed << setprecision(2) << U[u] - U[v] << '\n';
}
```

### *P2973 [USACO10HOL] Driving Out the Piggies G

概率 DP 经常会有后效性，此时使用高斯消元解决即可。

考虑 DP 结合概率，设 $dp_i$ 表示表示炸弹经过 $i$ 号节点的**期望**次数。那么唯一的转移方法就是从相邻节点继承而来。根据概率的乘法原理，乘上一个不爆炸的概率和一个出边数目的概率。即

$dp_u=\sum_{(v,u)} (1-\dfrac{p}{q}) \dfrac{1}{deg_v} dp_v$注意 $1$ 号节点初始有炸弹，因此 $dp_1 \gets dp_1+1$。

由于这不是树，没有换根 DP 这种东西，而且转移有后效性，可以移项后用高斯消元解方程组。复杂度 $O(n^3)$。

```cpp
const int N = 305, M = 5e4 + 5;
int n, m, p, q, u, v, deg[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[M << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
double a[N], dp[N];

void _main() {
	cin >> n >> m >> p >> q;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v, deg[u]++, deg[v]++;
		add_edge(u, v), add_edge(v, u);
	}
	GuassSolution<N> sol(n);
	for (int u = 1; u <= n; u++) {
		fill(a + 1, a + n + 1, 0.0);
		a[u] = 1.0;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			a[v] = -(1.0 - 1.0 * p / q) / deg[v];
		}
		sol.add(a + 1, u == 1);
	}
	sol.solve(dp + 1);
	for (int i = 1; i <= n; i++) cout << fixed << setprecision(12) << 1.0 * p / q * dp[i] << '\n';
}
```

### P2447 [SDOI2010] 外星千足虫

题意翻译：给出方程组

$$
\left\{\begin{matrix}
a_{1,1} x_1 + a_{1,2} x_2 + \cdots + a_{1,n} x_n \equiv v_1 \pmod 2 \\
a_{2,1} x_1 + a_{2,2} x_2 + \cdots + a_{2,n} x_n \equiv v_2 \pmod 2 \\
\cdots \\
a_{m,1} x_1 + a_{m,2} x_2 + \cdots + a_{m,n} x_n \equiv v_m \pmod 2
\end{matrix}\right.
$$

求方程组的解，并且求最少的方程条数使得方程组有唯一解。

思考一下模 $2$ 意义下的加法，发现这就是异或，于是第一问套用高斯消元即可。考虑第二问，显然至少要 $n$ 个方程才能解出 $n$ 元异或方程组，于是我们先解完 $n$ 个方程，若存在自由元就再加入新方程，直到有唯一解或者方程用完为止。使用 bitset 优化即可通过。

```cpp
const int N = 2005;
int n, m; char c;
bitset<N> a[N];
int v[N], id[N];

int guass() {
	int cnt = 0;
	for (int k = 1; k <= n; k++) {
		int mx = m + 1;
		for (int i = k; i <= m; i++) {
			if (a[i][k] && id[mx] > id[i]) mx = i;
		}
		if (mx == m + 1) return -1;
		cnt = max(cnt, id[mx]);
		swap(a[k], a[mx]), swap(v[k], v[mx]), swap(id[k], id[mx]);
		for (int i = 1; i <= m; i++) {
			if (i != k && a[i][k]) a[i] ^= a[k], v[i] ^= v[k];
		}
	} return cnt;
}

void _main() {
	cin >> n >> m;
	iota(id + 1, id + m + 2, 1);
	for (int i = 1; i <= m; i++) {
		for (int j = 1; j <= n; j++) cin >> c, a[i][j] = c ^ 48;
		cin >> c, v[i] = c ^ 48;
	}
	int h = guass();
	if (h == -1) return cout << "Cannot Determine", void();
	cout << h << '\n';
	for (int i = 1; i <= n; i++) cout << (v[i] ? "?y7M#\n" : "Earth\n");
}
```

### P10499 开关问题

用 $0/1$ 表示第 $i$ 个灯的初始状态 $x_i$，那么若干组关系可以列出一个以 $x_i$ 为主元的异或方程，即与 $i$ 相关联的灯的状态的异或和等于 $i$ 的初始状态。

高斯消元求其自由元个数 $c$，根据乘法原理答案为 $2^c$。无解当且仅当出现了形如 $0=1$ 的方程。可以 bitset 优化。

```cpp
const int N = 35;
int n, x, y, st[N], ed[N];
bitset<N> a[N];

int guass() {
	int cnt = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = i; j <= n; j++) {
			if (a[j][i]) {swap(a[i], a[j]), swap(ed[i], ed[j]); break;}
		}
		for (int j = 1; j <= n; j++) {
			if (i != j && a[j][i]) a[j] ^= a[i], ed[j] ^= ed[i];
		}
	}
	for (int i = 1; i <= n; i++) {
		if (a[i].count()) continue;
		if (ed[i]) return -1;
		cnt++;
	} return cnt;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> st[i];
	for (int i = 1; i <= n; i++) cin >> ed[i], ed[i] ^= st[i];
	for (int i = 1; i <= n; i++) a[i].reset();
	while (cin >> x >> y, x && y) a[y][x] = 1;
	for (int i = 1; i <= n; i++) a[i][i] = 1;
	int x = guass();
	if (x == -1) cout << "Oh,it's impossible~!!\n";
	else cout << (1LL << x) << '\n';
}
```$AKB298$, '数学', array['高斯消元', '线性方程组', '异或方程组'], null, null, 'knowledge'),
('Xesir', 'col-math-gauss-elimination--xesir', '高斯消元 · Xesir', $AKB299$## 算法原理

推荐大家去听**[这个课程](https://www.bilibili.com/video/BV1uLo6Y5Eku/?share_source=copy_web&vd_source=db32312e64ded9c3a314b416e5f8bd86)**，讲得很仔细易懂，而且不需要必须有矩阵基础。

> 高斯消元听上去很高级，实际上只需要初中数学水平就能理解。~~不少人都独自「发明」过高斯消元算法~~

还记得线性代数引入部分提到的解线性方程组吗？方程数量少的时候，人脑处理完全无压力，初中就学过代入消元、加减消元。那如果 $n$ 拉到 $50$ 甚至更多呢？我们需要一个**机械可复制**的过程，好搬到代码里。

给你一个线性方程组：

$$
\begin{cases}
2x + y - z = 8 \\
-3x - y + 2z = -11 \\
-2x + y + 2z = -3
\end{cases}
$$

写成增广矩阵就是：

$$
\left[\begin{array}{ccc|c}
2 & 1 & -1 & 8 \\
-3 & -1 & 2 & -11 \\
-2 & 1 & 2 & -3
\end{array}\right]
$$

最后一列是等号右边的常数。

可以发现，对以下三种操作，方程组的解**不变**：

1. 交换两个方程的位置；
2. 给一个方程的每一项乘上一个非 $0$ 系数；
3. 将一个方程加上另一个方程的若干倍。

高斯消元的目标就是：**通过这三种「合法操作」，把这个矩阵变成一个「答案直接写在脸上」的形状**——上三角矩阵。

怎么「消」？核心思路是**逐列处理**。从左到右看每一列，做两件事：

1. **选主元**：在还没处理的行里，找一个这一列系数**不是零**的行，把它交换到当前行；
2. 用这一行把**下面所有行**的这一列系数消成 $0$。

拿上面那个矩阵举例，第一列的主元选 $2$（第一行第一列）。用第一行去消第二、三行的第一列：

- 第二行：$-3x$ 要变成 $0$，就把第一行乘 $\frac{3}{2}$ 加到第二行上去；
- 第三行：$-2x$ 要变成 $0$，就把第一行直接加到第三行上去。

消完变成：

$$
\left[\begin{array}{ccc|c}
2 & 1 & -1 & 8 \\
0 & 0.5 & 0.5 & 1 \\
0 & 2 & 1 & 5
\end{array}\right]
$$

然后看第二列，在第二、三行里选主元，继续消……最后会变成**上三角**：

$$
\left[\begin{array}{ccc|c}
2 & 1 & -1 & 8 \\
0 & 0.5 & 0.5 & 1 \\
0 & 0 & -1 & 1
\end{array}\right]
$$

到这一步，从最后一行往上**回代**就行了：第三行是 $-z=1\Rightarrow z=-1$，代入第二行得 $y=3$，再代入第一行得 $x=2$。也就是 $(x,y,z)=(2,3,-1)$，代回原方程三式都成立。

实现上，由于浮点数存在精度问题，判断是否为 $0$ 一般不用 `x==0`，而是定义一个极小量 `EPS`（原文说通常取 $10^{-15}$），判断时用 `fabs(x) < EPS`。

**本条目代码的实际做法**：它其实不是「消成上三角 + 回代」，而是一路做到 **Gauss-Jordan**——对每个主元行，把**其余所有行**（不只是下面）该列的系数都消成 $0$；最后再统一把每行除以自己的主元，直接得到每个未知数。原文代码分了两遍循环：第一遍消元，第二遍归一化并收集答案。

## 核心公式 / 状态定义与转移方程

**增广矩阵**：把系数矩阵 $A$ 与常数项 $b$ 拼成 $n\times(n+1)$ 的矩阵

$$
[A\mid b]=\left[\begin{array}{cccc|c}
a_{11} & a_{12} & \cdots & a_{1n} & b_1 \\
a_{21} & a_{22} & \cdots & a_{2n} & b_2 \\
\vdots & \vdots & \ddots & \vdots & \vdots \\
a_{n1} & a_{n2} & \cdots & a_{nn} & b_n
\end{array}\right]
$$

**三种初等行变换**（解集不变）：

- 交换第 $i$、$j$ 行；
- 第 $i$ 行整体乘 $k$（$k\ne 0$）；
- 第 $j$ 行乘 $k$ 加到第 $i$ 行。

**消元公式**（代码里 `xyk(a, b, k)` 干的事，`a` 是主元行、`b` 是被消行、$k$ 是当前列）：

$$
b_i \leftarrow b_i-\frac{b_k}{a_k}\,a_i,\qquad i=k-1,\,k,\,\dots,\,n+1
$$

消元的目标是让 $b_k$ 变成 $0$。

**归一化 / 回代**：

$$
x_i=\frac{b_i}{a_{ii}}
$$

**主元判定**：$\lvert a_{ii}\rvert<\varepsilon$ 视为 $0$（代码取 $\varepsilon=10^{-8}$），需要换行；整列都找不到非零主元时方程组无唯一解。

## 逐行代码解析

完整程序 66 行，下面按「头文件与全局 → 消元工具函数 → 第一遍消元 → 第二遍归一化 + 主函数」拆成四块。代码按原文原样贴出，只在行尾补了讲解用的 `//` 注释。

### 模块一：头文件、常量与全局数组

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define lowbit(x) x&(-x)                 // 本程序没用到，模板残留
//#define int long long                // 被注释掉的宏，说明作者考虑过开 long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const double EPS=1e-8;                   // 判零阈值：原文正文说 1e-15，代码实际取 1e-8
int n;                                   // 未知数个数
vector<vector<double>> fc(110,vector<double>(110));   // 增广矩阵，1-based，最大 109 阶
```

- 全程用 `double`，所以只能做实数消元，不能直接解整数/模意义下的方程组。
- `fc` 是全局的 $110\times 110$ 静态开好的表，第 $0$ 行/列不用；`n` 超过 $109$ 会越界。
- `#define int long long` 被注释掉了，这里的 `int` 就是 32 位整型；本程序里 `int` 只用来当下标和循环变量，问题不大。

### 模块二：单步消元 `xyk`

```cpp
void xyk(vector<double> &a,vector<double> &b,int k){
	double xi=b[k]/a[k];                 // 消去系数：被消行第 k 列 / 主元行第 k 列
	for(int i=k-1;i<=n+1;i++){
		b[i]-=xi*a[i];                   // b -= xi * a，把 b 的第 k 列打成 0
	}
}
```

- 参数按引用传，直接原地改被消行 `b`。
- `xi` 就是「要加多少倍的主元行」；`b[k] -= xi*a[k]` 之后第 $k$ 列恰好为 $0$（浮点意义下接近 $0$）。
- 循环从 `k-1` 开始而不是 `k`，会把第 $k-1$ 列也顺手减一遍；正常情况下前面几列已经是 $0$，减了等于没减，但浮点残差下这属于「多动了一格」。
- 循环上界是 `n+1`，正好覆盖增广矩阵的最后一列常数项。

### 模块三：第一遍 —— 选主元 + 全行消元

```cpp
vector<double> gsolve(){
	vector<double> ys;
	for(int i=1;i<=n;i++){
		int u=i,v=fabsl(fc[u][i]);       // v 是 int，却接 fabsl 的返回值（会被截断）
		while(v<EPS){                    // 当前主元太小 → 往下找
			u++;
			if(u>n){
				cout<<"No Solution";return ys;   // 整列都是 0：无唯一解
			}
			v=fabsl(fc[u][i]);
		}
		cout<<endl;                      // 调试残留：每处理一列就打一个空行
		if(u!=i) swap(fc[u],fc[i]);      // 把主元行换到第 i 行
		for(int j=1;j<=n;j++){
			if(j==i) continue;           // 跳过主元行自己
			xyk(fc[i],fc[j],i);          // 用第 i 行消掉其余各行的第 i 列
		}
	}
```

- `for(int i=1;i<=n;i++)` 是逐列处理：第 $i$ 列的主元放在第 $i$ 行。
- **`v` 声明成 `int` 是个大坑**：`fabsl` 返回 `long double`，赋值给 `int` 会直接截断，$\lvert a\rvert<1$ 的非零主元会变成 `0`，随后被当成「主元为零」继续往下找，找完一整列就报 `No Solution`。照原文保留，见「常见陷阱」。
- `swap(fc[u],fc[i])` 换的是整行（`vector<double>` 交换），所以常数项会跟着一起走。
- 消元范围是 `j=1..n` 且 `j!=i`，也就是**上下全消**，这正是 Gauss-Jordan 而不是普通上三角消元。
- `cout<<endl;` 每次循环输出一个空行，属于调试残留，放在 OJ 上会多出 $n$ 行空行。

### 模块四：第二遍归一化 + `main`

```cpp
	vector<double> ans;
	for(int i=1;i<=n;i++){
		int u=i,v=fabsl(fc[u][i]);       // 又找了一遍主元（此时对角线应已非零）
		while(v<EPS){
			u++;
			if(u>n){
				cout<<"No Solution";return ys;
			}
			v=fabsl(fc[u][i]);
		}
		swap(fc[u],fc[i]);
		fc[i][n+1]/=fc[i][i];            // 常数项除以主元，直接得到 x_i
		if(fabsl(fc[u][i])<EPS) fc[i][n+1]=0;   // 可疑：u 此时指向被换下去的行
		ans.push_back(fc[i][n+1]);
	}
	return ans;
}
int main(){
//  freopen(".in","r",stdin);
//  freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
	cin>>n;
	for(int i=1;i<=n;i++){
		for(int j=1;j<=n+1;j++){
			cin>>fc[i][j];               // 读入 n 行、每行 n+1 个数：增广矩阵
		}
	}
	vector<double> ans=gsolve();
	for(int i=0;i<(int)ans.size();i++) printf("%.2lf\n",ans[i]);   // 保留两位小数逐行输出
    return 0;
}
```

- 第二遍理论上只需要「第 $i$ 行除以 $a_{ii}$」，因为第一遍已经把除对角线外的系数都消成 $0$；代码却又搜了一次主元，逻辑上是冗余的。
- `if(fabsl(fc[u][i])<EPS) fc[i][n+1]=0;` 在 `swap` **之后**执行：此时 `fc[u]` 是刚被换下来的旧行，`fc[u][i]` 就是「原来那个不合格的主元」，几乎必然小于 `EPS`，于是只要发生过换行，这一行的答案就被强行清零。
- 返回的 `ans` 只在求解成功时才有 $n$ 个元素；无解时提前 `return ys`（空 vector），`main` 里循环 $0$ 次，什么都不输出——这一点和前面已经打印的 `No Solution` 配合，不算矛盾，但格式上容易踩坑。
- 输出用 `printf("%.2lf\n", ...)`，而 IO 又混用了 `cout`；在 `ios::sync_with_stdio(false)` 之后仍然可以混用 `printf`/`cout`，只是缓冲顺序不保证，这里恰好没有交错输出的场景。

## 复杂度分析

| 维度 | 复杂度 | 怎么数出来的 |
|---|---|---|
| 时间 | $O(n^3)$ | 外层 $n$ 列，每列对 $n-1$ 行做一次消元，每次消元扫 $n+1$ 个元素 |
| 空间 | $O(n^2)$ | 存 $n\times(n+1)$ 的增广矩阵；代码里直接开成 $110\times 110$ 的定长表，是 $O(1)$ 常数开销 |

选主元的 `while` 最多扫描 $n$ 行，摊到每一列是 $O(n)$，被消元的 $O(n^2)$ 吸收，不改变总复杂度。第二遍循环也是 $O(n^2)$，同样被吸收。

## 适用场景

- **实数系数的一次方程组**：$n$ 元 $n$ 个方程，求唯一解，直接套这个模板。
- **把「方程组」翻译成矩阵的题**：物理/化学配平、电路、几何约束等建模题，列完方程就交给消元。
- **求逆矩阵**：把 $[A\mid I]$ 消成 $[I\mid A^{-1}]$，行变换逻辑完全一致。
- **算行列式**：消成上三角后把主对角线乘起来（注意换行会变号）。
- **不适合**：方程数不等于未知数、需要判断「无解 / 无穷多解」并分别输出时，这个模板只打印 `No Solution`，区分不了两种情形；模意义下的方程组也不能直接用 `double`，得改成模运算 + 逆元。

## 常见陷阱与注意事项

> 以下问题都是**原文代码原样保留**的结果，这里只指出，不修改代码。

1. **`int v = fabsl(...)` 截断（最致命）**。`fabsl` 返回 `long double`，赋给 `int` 后小数部分直接丢掉：主元是 $0.5$ 时 `v=0`，被判成「零主元」；一路找下去找不到就输出 `No Solution`。所以这个模板对「主元绝对值小于 $1$」的方程组基本不可用。
2. **`fabsl` 与 `fabs` 混用**。矩阵元素是 `double`，`fabsl` 要的是 `long double`，会隐式提升再截断回来，能编译，但语义上应该用 `fabs`。
3. **换行后答案被清零**。第二遍的 `if(fabsl(fc[u][i])<EPS) fc[i][n+1]=0;` 在 `swap` 之后判断的是「被换下去的旧行」，只要换过行就恒为真，答案直接变 $0$。这一行看起来是想「防止除以接近 0 的主元」，但位置放错了。
4. **`xyk` 从 `k-1` 开始减**。正常 Gauss-Jordan 里第 $i$ 行前 $i-1$ 列都为 $0$，多减一格通常无害；但存在浮点残差时会污染上一列，属于不必要的风险。
5. **EPS 前后不一致**。正文说通常取 $10^{-15}$，代码里是 $1e-8$。$10^{-8}$ 对 `double` 偏大，接近病态的方程组容易被误判。
6. **`cout<<endl;` 调试残留**。每列输出一个空行，提交前应删；这里保留是为了和原文一致。
7. **无解与无穷多解没有区分**。两种情形都打印 `No Solution` 并返回空 vector。
8. **数组只有 110 阶**。`n>109` 直接越界，且没有任何提示。
9. **没有对 $n=0$ 做保护**。读入 $n=0$ 时两遍循环都不执行，输出为空。
10. **混用 `cout` 与 `printf`**。虽然能跑，但格式（`endl` 与 `\n`）和缓冲策略不一致，规范化写法是统一其中一种。$AKB299$, '数学', array['数学', '线性代数', '高斯消元', '方程组', '矩阵'], null, null, 'knowledge'),
('stripe-python', 'col-math-gcd-lcm--stripe-python', '最大公约数与扩展欧几里得 · stripe-python', $AKB300$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 3. 最大公约数

定义**最大公约数** $\gcd(a,b)$ 为：满足 $k \mid a$ 且 $k \mid b$ 的最大的 $k$。定义 $\gcd(a,0)=0$。

定义最小公倍数 $\operatorname{lcm}(a,b)$ 为：满足 $a \mid k$ 且 $b \mid k$ 的最小的 $k$。

## 3.1 求解 GCD

### 3.1.1 分解质因数法

将两数分解质因数：$a=p_1^{a_1}p_2^{a_2} \cdots, b=a=p_1^{b_1}p_2^{b_2} \cdots$，则 $\gcd(a,b)=p_1^{\min(a_1,b_1)}p_2^{\min(a_2,b_2)} \cdots$，复杂度为 $O(\sqrt{n})$。

这证明：求 gcd 和求最小值有共通之处。

### 3.1.2 辗转相除法

GCD 有如下性质：

$\gcd(a,b)=\gcd(b,a \bmod b)$利用此可递归计算 gcd，出口为 $\gcd(a,0)=a$。复杂度 $O(\log (a+b))$。

```cpp
int gcd(int a, int b) {return b == 0 ? a : gcd(b, a % b);}
```

C++ STL 中有函数 `std::__gcd`，为迭代的辗转相除法实现，复杂度为 $O(\log n)$，可以直接使用。

### 3.1.3 更相减损法

GCD 有如下性质：

$\gcd(a,b)=\gcd(a-b,b)$如果直接递归计算，复杂度为 $O(n)$。Stein 算法对此进行了优化：

若 $2\mid a$ 且 $2\mid b$，则 $\gcd(a,b)=2\gcd(\dfrac{a}{2},\dfrac{b}{2})$。而若只有 $2 \mid  a$，则 $\gcd(a,b)=\gcd(\dfrac{a}{2},b)$。这启示我们可以在过程中除掉约数 $2$，然后再更相减损，复杂度就降到了 $O(\log n)$。Stein 算法常用于大整数的 GCD。

Stein 算法可以借助二进制内置函数优化，称作 Binary GCD，理论复杂度 $O(\log (a+b))$，但在实际表现中可以看作大常数 $O(1)$。这份代码的速度比 `std::__gcd` 更快，可以卡过 [P5435](https://www.luogu.com.cn/problem/P5435)。

```cpp
template <class T> constexpr T gcd(T a, T b) {
	int az = ctz(a), bz = ctz(b), z = min(az, bz);
	for (b >>= bz; a; ) {
		a >>= az; int d = a - b;
		az = ctz(a - b), b = min(a, b), a = abs(d);
	} return b << z;
}
```

## 3.2 exGCD

exGCD 用于求解形如 $ax+by=\gcd(a,b)$ 一类的不定方程。

### 3.2.1 裴蜀定理

对于任意非零整数 $a,b$，$ax+by=c$ 有整数解当且仅当 $c \mid  \gcd(a,b)$。

#### 推论

若 $a_1,a_2,a_3,\cdots,a_n$ 是不全为 $0$ 的整数，则存在整数 $x_1,x_2,x_3,\cdots,x_n$ 使得

$a_1x_1+a_2x_2+a_3x_3+\cdots+a_nx_n=\gcd(a_1,a_2,a_3,\cdots,a_n)$其逆定理也成立。

### 3.2.2 不定方程

由 $\gcd(a,b)=\gcd(b,a\bmod b)$ 得：

$$
\begin{aligned}
ax+by&=bx'+(a\bmod b)y'\\
&=bx'+(a-b\lfloor \dfrac{a}{b} \rfloor)y'\\
&=ay'+b(x'-y'\lfloor \dfrac{a}{b} \rfloor)
\end{aligned}
$$

递归式：$x=y',y=x'-y'\lfloor \dfrac{a}{b} \rfloor$，这样就可以 $O(\log (a+b))$ 求解。

```cpp
void exgcd(int a, int b, int& x, int& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
```

可以证明，通过这种方法得到的 $x,y$ 在值域范围内。所以不用担心溢出的问题。

### 3.2.3 乘法逆元

逆元就是模意义下的倒数：求 $x \equiv \dfrac{1}{a} \pmod m$ 的解。

移项得：$ax \equiv 1 \pmod m$，即为求解不定方程 $ax-bm=1$，用 exGCD 求解即可。

这里可以发现，$x$ 在模 $m$ 意义下有逆元当且仅当 $x,m$ 互质。利用乘法逆元，可以实现模意义下的除法。

### 3.2.4 线性方程组

这里的线性方程组是指求一个最小的 $x$ 满足

$$
\left\{\begin{matrix}
x \equiv a_1 \pmod {m_1} \\
x \equiv a_2 \pmod {m_2} \\
\cdots \\
x \equiv a_n \pmod {m_n}
\end{matrix}\right.
$$

两两考虑。比如我们把前两个方程变成不定方程：$x=m_1p+a_1=m_2q+a_2$。则 $m_1p-m_2q=a_2-a_1$，利用 exGCD 解出一组可行解 $(p,q)$，然后这两个方程组的共同解为 $x \equiv (m_1p+a_1) \pmod {\operatorname{lcm}(m_1,m_2)}$。然后把 $n$ 个方程都这么合并起来即可。这种方法叫 exCRT。

至于为什么不说 CRT，因为我觉得 exCRT 比 CRT 更容易理解，适用范围更广，代码还好写。

## 3.3 常用性质

这里我们不加证明地给出一些 $\gcd$ 的性质。

1. $\gcd(a, b) \times \operatorname{lcm}(a,b)=ab$。
2. $\gcd(a,b) \le |a- b|$。
3. $\gcd(b,a \bmod b)=\gcd(a,b)$。
4. $\gcd(a,b)=\gcd(a-b,b)$。
5. $\gcd(a,b)=\sum_{x \mid a, x\mid b} \varphi(x)$。$\varphi(x)$ 为下文第 4 章要讲的欧拉函数。
6. $\gcd(a,b)=c$，则 $\gcd(\dfrac{a}{c},\dfrac{b}{c})=1$。证明见第一道例题。

## 3.4 例题

前面是 GCD 性质和裴蜀定理应用题，后面是 exGCD & exCRT 例题。

### P1072 [NOIP 2009 提高组] Hankson 的趣味题

注意到性质 6：若 $\gcd(a,b)=c$，且 $a=k_1c,b=k_2c$，则 $\gcd(k_1,k_2)=1$。

证明：考虑反证法，设 $K=\gcd(k_1,k_2) \ne 1$，则存在不为 $1$ 的正整数 $p,q$ 使得 $k_1=pK,k_2=qK$，因而 $a=pKc,b=qKc$，$\gcd(a,b)=Kc \ne c$，故原结论成立。

由题可得：$x=a_1 p$，$b_1=xq$，其中 $p,q$ 为正整数。

由上述结论得：$\gcd(\dfrac{a_0}{a_1},\dfrac{x}{a_1})=1$。又有 $\operatorname{lcm}(x,b_0)=b_1$，故 $\gcd(\dfrac{b_1}{x},\dfrac{b_1}{b_0})=1$。且 $x\mid b_1$，枚举 $x$ 并判断即可，复杂度 $O(\sqrt{b_1} \log V)$。

```cpp
int a0, a1, b0, b1;
void _main() {
	cin >> a0 >> a1 >> b0 >> b1;
	int cnt = 0;
	for (int x = 1; x * x <= b1; x++) {
		if (b1 % x) continue;
		if (x % a1 == 0 && __gcd(x / a1, a0 / a1) == 1 && __gcd(b1 / x, b1 / b0) == 1) cnt++;
		int y = b1 / x;
		if (x == y) continue;
		if (y % a1 == 0 && __gcd(y / a1, a0 / a1) == 1 && __gcd(b1 / y, b1 / b0) == 1) cnt++;
	}
	cout << cnt << '\n';
}
```

### UVA10622 完全P次方数 Perfect P-th Powers

将 $x$ 分解质因数为 ${p_1}^{c_1} {p_2}^{c_2} {p_3}^{c_3} \cdots$。注意到 $(a^xb^y)^z=a^{xz} b^{xz}$。所以 $p=\gcd(c_1,c_2,c_3,\cdots)$。

需要注意 $x$ 不一定是正数。此时 $p$ 不能是偶数，不然 $a^p$ 就是正数了。

```cpp
#define int long long
int x;
void _main() {
	while (cin >> x, x) {
		vector<int> c;
		bool neg = x < 0;
		x = abs(x);
		for (int i = 2; i * i <= x; i++) {
			if (x % i) continue;
			c.emplace_back(0);
			while (x % i == 0) x /= i, c.back()++;
		}
		if (x != 1) c.emplace_back(1);
		int g = 0;
		for (int i : c) g = __gcd(g, i);
		if (neg) g >>= __builtin_ctzll(g);
		cout << g << '\n';
	}
}
```

### CF1499D The Number of Pairs

设 $a=n\times \gcd(a,b),b=m \times \gcd(a,b)$，大力推式子：

$$
\begin{aligned}
c \times \operatorname{lcm(a,b)}-d\times \gcd(a,b)&=x\\
c \times \dfrac{ab}{\gcd(a,b)}-d\times \gcd(a,b)&=x\\
c nm \times \gcd(a,b)-d\times \gcd(a,b)&=x\\
\gcd(a,b)&=\dfrac{x}{cnm-d}
\end{aligned}
$$

说明 $(cnm-d) \mid x$。$O(\sqrt{x})$ 地枚举 $x$ 的因子 $i$。移项有 $cnm=d+i$，即 $c \mid (d+i)$。再将 $\dfrac{d+i}{c}$ 分解质因数，对于每种质因子只有全给 $n$ 和全给 $m$ 两种选择，否则会使得 $(cnm-d) \nmid x$。用线性筛先得到每个数的质因子个数，则贡献为 $2^{cnt}$。复杂度 $O(n+T\sqrt{n})$。

```cpp
const int N = 2e7 + 5;
bitset<N> isprime;
int cnt[N], prime[N];
void init() {
	isprime.set(), isprime[0] = isprime[1] = false;
	for (int i = 2; i < N; i++) {
		if (isprime[i]) prime[++prime[0]] = i, cnt[i] = 1;
		for (int j = 1; j <= prime[0] && 1LL * i * prime[j] < N; j++) {
			isprime[i * prime[j]] = false;
			if (i % prime[j] == 0) {
				cnt[i * prime[j]] = cnt[i];
				break;
			}
			cnt[i * prime[j]] = cnt[i] + 1;
		}
	}
}

long long c, d, x;
long long f(int x) {
	if ((x + d) % c) return 0;
	return 1LL << cnt[(x + d) / c];
}
void _main() {
	cin >> c >> d >> x;
	long long res = 0;
	for (long long i = 1; i * i <= x; i++) {
		if (x % i) continue;
		res += f(i);
		if (i * i != x) res += f(x / i);
	} cout << res << '\n';
}
```

### CF2148G Farmer John’s Last Wish

不难发现满足 $\gcd_{i=1}^{k} a_i \ne \gcd_{i=1}^{k+1} a_i$ 的最大的 $k$ 等价于满足 $\gcd_{i=1}^{n} a_i \ne \gcd_{i=1}^{k+1} a_i$ 的最大的 $k$。

考虑对前缀 $p$ 的解法，记 $\gcd_{i=1}^{len} p_i = g$，则找到最长的都是 $g$ 的倍数的一段放在前面，这段长度就是答案。动态维护 $f_i$ 表示当前前缀中 $i$ 的倍数数目，答案即为 $\max f_{i \times g}$。

由于每次操作使得 $g$ 变为原本的因子，故 $g$ 的倍数集合只增不删，枚举 $g$ 的倍数 $j \times g$，将 $j \times g$ 加入集合并更新答案。然后遍历 $a_i$ 的因子 $j$，更新 $f_j$，当 $j$ 是 $g$ 的倍数时更新答案。

注意到复杂度为 $O(n^2)$。可以发现 $g$ 降到 $1$ 最多 $O(\log V)$ 次，可以对 $g$ 的变化记忆化一下。复杂度为 $O(n \log V+n\log n)$。

```cpp
const int N = 2e5 + 5;
int n, a[N], f[N], vis[N], tag[N];
vector<int> fac[N];

void prework() {
	for (int i = 1; i < N; i++) {
		for (int j = i; j < N; j += i) fac[j].emplace_back(i);
	}
}
void _main() {
	memset(f, 0, sizeof(int) * (n + 1)), memset(vis, 0, sizeof(int) * (n + 1)), memset(tag, 0, sizeof(int) * (n + 1));
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	int g = a[1], cur = 0;
	for (int i = 1; i <= n; i++, g = __gcd(g, a[i])) {
		if (!tag[g]) {
			for (int j = 2; j * g <= n; j++) vis[j * g] = true, cur = max(cur, f[j * g]);
			tag[g] = true;
		}
		for (int j : fac[a[i]]) {
			f[j]++;
			if (vis[j]) cur = max(cur, f[j]);
		} cout << cur << ' ';
	} cout << '\n';
}
```

### P8255 [NOI Online 2022 入门组] 数学游戏

考虑对 $z,x,y$ 质因数分解得：

$\prod {p_i}^{z_i}=\prod {p_i}^{x_i+y_i+\min(x_i,y_i)}$即 $z_i=x_i+y_i+\min(x_i,y_i)$。分类讨论：

1. 若 $y_i \ge x_i$，则 $z_i=x_i+2y_i$，解得 $y_i=\dfrac{z_i-x_i}{2}$。
2. 若 $y_i < x_i$，则 $z_i=2x_i+y_i$，解得 $y_i=z_i-2x_i$。

因此，$y_i=\min(\dfrac{z_i-x_i}{2},z_i-2x_i)$。

想想指数出现 $\min$、除法、减号、乘法的意义：就是取 $\gcd$，开方，除法，乘方。通过配凑系数得到：

$y=\dfrac{x}{z\sqrt{\gcd(x^2,\frac{x}{z})}}$不能整除，不能开方均判为无解。

```cpp
const double eps = 1e-8;
int x, z;

void _main() {
	cin >> x >> z;
	if (z % x) return cout << -1 << '\n', void();
	int128 t = z / x, u = __gcd((int128) x * x, t), us = sqrt(1.0L * u) + 0.5;
	if (u != us * us) return cout << -1 << '\n', void();
	cout << (long long) (t / us) << '\n';
}
```

### P4549 【模板】裴蜀定理

由 $\gcd(a,b,c)=\gcd(a,\gcd(b, c))$ 得

$\sum_{i=1}^{n} a_i x_i = \gcd_{i=1}^{n} |a_i|$而题目中记 $\sum x_i$ 为 $S$，根据裴蜀定理可知 $\gcd_{i=1}^{n} |a_i|$ 是 $S$ 的约数，$S$ 最小时二者相等。也就是求所有数的 $\gcd$。

### CF510D Fox And Jumping

根据裴蜀定理的推论，能跳到所有位置当且仅当我们选出的长度的 $\gcd=1$。于是设 $dp_i$ 表示选择一些长度使得其最大公约数为 $i$ 的最小代价，采用刷表，枚举 $i,j \in [1,n]$ 易得

$dp_{\gcd(l_i, j)} \gets \min(dp_{\gcd(l_i, j)}, c_{i}+v)$对于单个转移，有

$dp_{l_i} \gets \min(dp_{l_i},c_i)$由于下标能到 $10^9$，暴力 dp 是不行的。但是有用的 $dp$ 值不多，于是我们用 `std::map` 维护转移，复杂度比较玄学。

```cpp
const int N = 305;
int n, l[N], c[N];
map<int, int> dp;
void upd(int x, int v) {
	if (!dp.count(x)) dp[x] = v;
	else dp[x] = min(dp[x], v);
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> l[i];
	for (int i = 1; i <= n; i++) cin >> c[i];
	for (int i = 1; i <= n; i++) {
		for (const auto& h : dp) {
			int j = h.first, v = h.second;
			upd(__gcd(l[i], j), c[i] + v);
		} upd(l[i], c[i]);
	}
	cout << (dp.count(1) ? dp[1] : -1);
}
```

### *P2520 [HAOI2011] 向量

不了解向量运算法则请翻到下文 22.1 线性代数部分。

对于 $(-a,-b)$ 这样的向量，可以视为减去 $(a,b)$，其余同理，这样八种就变成了四种。问题转化为求 $c,d,e,f \in \mathbb{N}$ 使得 $c(a,b)+d(a,-b)+e(b,a)+f(b,-a)=(x,y)$，拆开得到

$$
\left\{\begin{matrix}
a(c+d)+b(e+f)=x \\
a(e-f)+b(c-d)=y
\end{matrix}\right.
$$

根据裴蜀定理，上面方程组有整数解的必要条件是 $\gcd(a,b) \mid x$ 且 $\gcd(a,b) \mid y$。

但是这样只能保证 $c+d,e+f,e-f,c-d \in \mathbb{N}$，而 $c,d,e,f$ 会出现 $\dfrac{1}{2}$ 的情况。

所以有解的充要条件是 $\gcd(a,b) \mid x$ 且 $\gcd(a,b) \mid y$ 且 $c+d,c-d$ 奇偶性相同、$e+f,e-f$ 奇偶性相同。

设 $c+d=2k_1+m_1,c-d=2k_2+m_1,e+f=2k_3+m_2,e-f=2k_4+m_2$，且 $m_1,m_2 \in \{0,1\}$，得到

$$
\left\{\begin{matrix}
a(2k_1+m_1)+b(2k_3+m_2)=x \\
a(2k_4+m_2)+b(2k_2+m_1)=y
\end{matrix}\right.
$$

分四种情况讨论。以 $m_1=m_2=0$ 为例，等式两边同除 $2$可得 $\gcd(a,b) \mid \dfrac{x}{2}$，即 $2\gcd(a,b) \mid x$，对于 $y$ 同理。

以 $m_1=0,m_2=1$ 为例，同加 $b$ 再同除 $2$，化简得到 $2 \gcd(a,b) \mid (x+b)$。

剩下两种类似。四种可能或起来即可。

```cpp
long long a, b, x, y;

void _main() {
	cin >> a >> b >> x >> y;
	long long g = __gcd(a, b);
	if (x % g || y % g) return cout << "N\n", void();
	g *= 2;
	if (x % g == 0 && y % g == 0) return cout << "Y\n", void();
	if ((x + b) % g == 0 && (y + a) % g == 0) return cout << "Y\n", void();
	if ((x + a) % g == 0 && (y + b) % g == 0) return cout << "Y\n", void();
	if ((x + a + b) % g == 0 && (y + a + b) % g == 0) return cout << "Y\n", void();
	cout << "N\n";
}
```

### *P3518 [POI 2011] SEJ-Strongbox

设密码集合为 $S$，则 $\forall i,j \in S, (i+j) \bmod n \in S$。考虑对于 $i \in S$，必然有 $\forall k \in \mathbb{N}^+, ki \bmod n \in S$，所以首先考虑 $ki \bmod n$ 能取到哪些数。

首先讨论 $\gcd(i,n)=1$，此时 $ki \bmod n$ 取遍 $0,1,2,3,\cdots,n-1$。因为同余方程 $ki \equiv x \pmod n$ 必然有解。一般地，猜想 $i \in S$ 使得 $ki=x \pmod n$ 有解，即 $\gcd(k,n)=1$，反证法得到 $ki \bmod n$ 取到了所有 $\gcd(i,n)$ 的倍数。

对于 $i \notin S$，$i$ 的所有因子也不是密码。根据这个判定方法，枚举 $d \mid \gcd(m_k,n)$，若合法，则对于 $d \in S$ 的密码数量就是 $\dfrac{n}{d}$。复杂度 $O(k \sqrt {\gcd(m_k,n)})$，可以获得 76pts。

```cpp
#define int long long
const int N = 2.5e5 + 5;
int n, k, a[N];
bool check(int x) {
	for (int i = 1; i < k; i++) {
		if (a[i] % x == 0) return false;
	} return true;
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= k; i++) cin >> a[i];
	int x = __gcd(n, a[k]);
	for (int i = 1; i * i <= x; i++) {
		if (x % i) continue;
		if (check(i)) return cout << n / i, void();
	}
	for (int i = sqrt(x) + 1; i >= 1; i--) {
		if (x % i) continue;
		if (check(x / i)) return cout << n / (x / i), void();
	}
}
```

考虑优化。枚举因子最多只有 $10^7$，思考如何快速 `check`。首先令 $a_i \gets \gcd(a_i,x)$，显然不影响结果。接着对 $x$ 质因数分解。注意到 $2\times 3\times 5\times 7\times 11\times 13\times 17\times 19\times 23\times 29\times 31\times 37\times 41\times 43>10^{14}$，考虑对于每个 $a_i$ 直接按质因子爆搜因数。使用哈希表记忆化搜索，复杂度大概是 $O(k \log V+\sqrt{V}+d(V) \omega(V))$。

```cpp
#define int long long
const int N = 2.5e5 + 5;
int n, k, a[N];
bool check(int x) {
	for (int i = 1; i < k; i++) {
		if (a[i] % x == 0) return false;
	} return true;
}
vector<int> p;
void decompose(int x) {
	for (int i = 2; i * i <= x; i++) {
		if (x % i) continue;
		p.emplace_back(i);
		while (x % i == 0) x /= i;
	}
	if (x != 1) p.emplace_back(x);
}
unordered_set<int> f;
void dfs(int x) {
	if (f.count(x)) return;
	f.emplace(x);
	for (int i : p) {
		if (x % i == 0) dfs(x / i);
	}
}

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= k; i++) cin >> a[i];
	int x = __gcd(n, a[k]);
	decompose(x);
	for (int i = 1; i < k; i++) dfs(__gcd(a[i], x));
	for (int i = 1; i * i <= x; i++) {
		if (x % i) continue;
		if (!f.count(i)) return cout << n / i, void();
	}
	for (int i = sqrt(x) + 1; i >= 1; i--) {
		if (x % i) continue;
		if (!f.count(x / i)) return cout << n / (x / i), void();
	}
}
```

### P1082 [NOIP 2012 提高组] 同余方程

这东西我们在之前的乘法逆元讲过方法了，就是用 exGCD 解方程 $ax-by=1$。输入保证有解，意味着 $\gcd(a,b)=1$，所以这就是 exGCD 方程的标准形式。细节上，求出 $x$ 以后要处理负数问题。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}

long long a, b;
void _main() {
	cin >> a >> b;
	long long x, y; exgcd(a, b, x, y);
	cout << (x % b + b) % b;
}
```

### P5656 【模板】二元一次不定方程 (exgcd)

首先由裴蜀定理判无解，若 $c$ 不是 $\gcd(a,b)$ 的倍数则直接无解。

设 $\gcd(a,b)=d$。考虑用 exGCD 求解方程 $ax+by=d$，将解记作 $x_0,y_0$。则

$ax_0+by_0=d\\$方程两边同乘 $\dfrac{c}{d}$ 转化为所求：

$a\dfrac{cx_0}{d}+b\dfrac{cy_0}{d}=c\\$故原方程的一组解为 $x_1=\dfrac{cx_0}{d},y_1=\dfrac{cy_0}{d}$。

接下来考虑构造通解形式，设

$a(x_1+m)+b(y_0+n)=c$不难发现 $m,n$ 满足条件 $am+bn=0$。仍然利用裴蜀定理，解得 $m=p \times \dfrac{b}{d}, n=-p \times {a}{d}$，其中 $p$ 是正整数。于是我们得到原方程的通解

$$
\left\{\begin{matrix}
x=x_1+p \times \dfrac{b}{d} \\
y=y_1-p \times \dfrac{a}{d}
\end{matrix}\right.
$$

考虑求解数与最值。找 $x_{\min}$ 即为解关于 $k$ 的不等式

$x_1+km \ge 1$由于式中的值均为整数，故

$k \ge \lceil \dfrac{1-x_1}{m} \rceil$由于 $y$ 随 $x$ 的增大而减小，故 $x_{\min}$ 所对应的 $y$ 就是 $y_{\max}$。接下来我们用 $y_{\max}$ 推 $y_{\min}$。推导一下，可以发现

$y_{\min}=y_{\max} \bmod n$于是 $x_{\max}$ 加上同样多的 $m$ 即可：

$x_{\max}=x_{\min} + \lfloor \dfrac{y_{\max}-1}{n} \times m \rfloor$解数就是 $[y_{\min},y_{\max}]$ 中解的个数，即

$\lfloor \dfrac{y_{\max}-1}{n} +1 \rfloor$至此本题在 $O(\log V)$ 内解决，$V$ 为值域。

在实现中，我们可以将 $a,b,c$ 都除去 $d$，这样可以简化代码。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}

long long a, b, c;

void _main() {
	cin >> a >> b >> c;
	long long d = __gcd(a, b);
	if (c % d) return cout << -1 << '\n', void();
	a /= d, b /= d, c /= d;
	long long x0, y0; exgcd(a, b, x0, y0);
	long long x1 = c * x0, y1 = c * y0;
	int xmin = (x1 > 0 && x1 % b != 0) ? x1 % b : x1 % b + b;
	int ymax = (c - xmin * a) / b;
	int ymin = (y1 > 0 && y1 % a != 0) ? y1 % a : y1 % a + a;
	int xmax = (c - ymin * b) / a;
	if (xmax <= 0) cout << xmin << ' ' << ymin << '\n';
	else cout << (ymax - ymin) / a + 1 << ' ' << xmin << ' ' << ymin << ' ' << xmax << ' ' << ymax << ' ' << '\n';
}
```

### P1516 青蛙的约会

设相遇时两只青蛙跳了 $t$ 次，则

$(n-m)t+kL=x-y$即求解 $t$ 的最小非负整数解。在不定方程 $ax+by=c$ 中，我们把 $n-m$ 视作 $a$，$L$ 视作 $b$，$x-y$ 视作 $c$，则应用上一题的方法来求解。

```cpp
template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
long long x, y, m, n, L;

void _main() {
	cin >> x >> y >> m >> n >> L;
	long long a = n - m, b = L, c = x - y;
	if (a < 0) a = -a, c = -c;
	long long d = __gcd(a, b);
	if (c % d) return cout << "Impossible", void();
	a /= d, b /= d, c /= d;
	long long x0, y0; exgcd(a, b, x0, y0);
	long long x1 = c * x0;
	cout << ((x1 > 0 && x1 % b != 0) ? x1 % b : x1 % b + b);
}
```

### P12952 [GCJ Farewell Round #2] Intruder Outsmarting

我们考虑第 $i$ 个转轮，设调整它 $a$ 次，调整第 $w-i+1$ 个转轮 $b$ 次，则有同余方程：

$X_i+Da \equiv X_{w-i+1}+Db \pmod N$其中 $i \le \lfloor \dfrac{W}{2} \rfloor$。显然这个玩意没法 exCRT，于是我们把它变成不定方程：

$$
D(a-b) \equiv X_{w-i+1}-X_i \pmod N\\
D(a-b)-kN=X_{w-i+1}-X_i
$$

等号右边是已知量，将 $a-b$ 和 $k$ 看作未知数，先判无解，然后使用 exGCD 求出 $D(a-b)-kN=\gcd(D,N)$ 的解。我们需要求出 $a+b$ 的最小值。设 $p=a-b$，分类讨论：

- 若 $p \ge 0$，则 $a-b=p$，即 $a+b=2b+p$，当 $b=0$ 且 $p$ 为最小非负整数解时，$a+b$ 取得最小值。
- 若 $p<0$，则 $b-a=-p$，即 $a+b=2a-p$，当 $a=0$ 且 $p$ 为最大非负整数解的相反数时，$a-b$ 取得最小值。

至此，套用模板题的方法，本题解决。

```cpp
const int N = 2005;
#define int long long
void exgcd(int a, int b, int& x, int &y) {
	if (b == 0) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
int w, n, d, x[N];

void _main(int kase) {
	cout << "Case #" << kase << ": ";
	cin >> w >> n >> d;
	for (int i = 1; i <= w; i++) cin >> x[i];
	int g = __gcd(n, d), n0 = n / g, res = 0;
	for (int i = 1; i <= w / 2; i++) {
		if ((x[i] - x[w - i + 1]) % g) return cout << "IMPOSSIBLE\n", void();
		int a, b; exgcd(d, n, a, b);
		int p = a * ((x[w - i + 1] - x[i]) / g % n0) % n0;
		if (p >= 0) p %= n0, res += min(p, n0 - p);
		else {
			int q = p + n0 * ceil(-1.0 * p / n0);
			res += min(q, n0 - q);
		}
	} cout << res << '\n';
}
```

### P4777 【模板】扩展中国剩余定理（EXCRT）

板子题。给个代码：

```cpp
const int N = 1e5 + 5;

template <class T> void exgcd(T a, T b, T& x, T& y) {
	if (!b) return x = 1, y = 0, void();
	exgcd(b, a % b, y, x), y -= a / b * x;
}
template <class T> T crt(int n, const T* a, const T* m) {
	T x = 0, y = 0, p = m[1], res = a[1];
	for (int i = 2; i <= n; i++) {
		T a0 = p, b0 = m[i], c = (a[i] - res % b0 + b0) % b0, g = __gcd(a0, b0);
		if (c % g) return -1;
		exgcd(a0, b0, x, y);
		x = (__int128) x * c / g % b0, res += x * p, p = p / __gcd(p, b0) * b0, res = (res % p + p) % p;
	}
	return res;
}

int n;
long long a[N], m[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> m[i] >> a[i];
	cout << crt(n, a, m);
}
```

exCRT 很重要的一个用途是对于模数不是质数的情况，我们把模数分解质因数，然后分别计算对这些质因数取模的结果，最后用 exCRT 合并。

### P3868 [TJOI2009] 猜数字

对于 $(x-a_i) \mid  b_i$，可以变形为 $x-a_i \equiv 0 \pmod {b_i}$，然后再移项就是 $x \equiv a_i \pmod {b_i}$。于是解这个同余方程组即可。

细节上注意 $a_i$ 可能为负，需要对 $b_i$ 取模处理，另外这题会爆 `long long`，不过上面板子里已经开了 `__int128` 了。

```cpp
const int N = 15;
int n;
long long a[N], b[N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) cin >> b[i];
	for (int i = 1; i <= n; i++) a[i] = (a[i] % b[i] + b[i]) % b[i];
	cout << crt(n, a, b);
}
```

### *P4774 [NOI2018] 屠龙勇士

首先把题目翻译过来，发现每条龙所对应的攻击力是确定的，记作 $b_i$。可以用一个 std::multiset 模拟攻击过程，现在问题是求

$$
\left\{\begin{matrix}
b_1x \equiv a_1 \pmod {p_1} \\
b_2x \equiv a_2 \pmod {p_2} \\
\cdots \\
b_nx \equiv a_n \pmod {p_n}
\end{matrix}\right.
$$

的最小正整数解 $x$。

对于 $bx \equiv a \pmod p$，拆开：

$bx-py=a$上 exGCD 求出一组特解 $x_0,y_0$，根据模板题的通解公式有

$x=x_0+k \dfrac{p}{\gcd(b,p)}$同模 $\dfrac{p}{\gcd(b,p)}$ 化为同余式

$x\equiv x_0 \pmod {\dfrac{p}{\gcd(b,p)}}$问题解决。之后使用普通的 exCRT 解出 $x$ 即可。

还有一些特判：

- 上面这种只适用于 $a_i \le p_i$ 的情况。对于 $a_i>p_i$ 的情况，根据数据点分治有 $p_i=1$，那么答案就是 $\max_{i=1}^{n} \lceil \dfrac{a_i}{b_i} \rceil$，需要特判。
- 当所有的 $p_i=a_i$ 时，$x=0$。但是这是错的，应该求出所有刀数取 $\operatorname{lcm}$。

```cpp
const int N = 1e5 + 5;
int n, m;
long long a[N], b[N], p[N], c[N], x, x0[N];
multiset<long long> st;

void _main() {
	st.clear();
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	bool f1 = false, f2 = true;
	for (int i = 1; i <= n; i++) {
		cin >> p[i];
		if (a[i] > p[i]) f1 = true;
		if (a[i] != p[i]) f2 = false;
	}
	for (int i = 1; i <= n; i++) cin >> c[i];
	for (int i = 1; i <= m; i++) cin >> x, st.emplace(x);
	for (int i = 1; i <= n; i++) {
		auto it = st.upper_bound(a[i]);
		if (it != st.begin()) it--;
		b[i] = *it, st.erase(it), st.emplace(c[i]);
		debug(b[i]);
	}
	if (f1) {
		long long res = 0;
		for (int i = 1; i <= n; i++) res = max(res, (a[i] + b[i] - 1) / b[i]);
		return cout << res << '\n', void();
	}
	if (f2) {
		long long res = 1;
		for (int i = 1; i <= n; i++) {
			long long v = p[i] / __gcd(p[i], b[i]);
			res = res / __gcd(res, v) * v;
		} return cout << res << '\n', void();
	}
	for (int i = 1; i <= n; i++) {
		if (b[i] % p[i] == 0) {
			if (p[i] == a[i]) x0[i] = 0, p[i] = 1;
			else return cout << -1 << '\n', void();
			continue;
		}
		long long g = __gcd(b[i], p[i]);
		if (a[i] % g) return cout << -1 << '\n', void();
		long long y0;
		exgcd(b[i], p[i], x0[i], y0);
		p[i] /= g, x0[i] = (x0[i] % p[i] + p[i]) % p[i];
		x0[i] = (int128) x0[i] * (a[i] / g) % p[i];
	}
	cout << crt(n, x0, p) << '\n';
}
```$AKB300$, '数学', array['gcd', 'lcm', 'exgcd', '裴蜀定理'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-gcd-lcm', 'GCD 与 LCM（欧几里得算法）', $AKB301$## GCD 与 LCM（欧几里得算法）

## 一、算法原理

### 1.1 最大公约数 GCD

**定义**：对于两个正整数 $a, b$，它们的最大公约数（Greatest Common Divisor, GCD）是能同时整除 $a$ 和 $b$ 的最大正整数，记作 $\gcd(a, b)$。

例：$\gcd(12, 18) = 6$，$\gcd(7, 13) = 1$（两数互质）。

### 1.2 欧几里得算法（辗转相除法）

**核心等式**：

$$\gcd(a, b) = \gcd(b, a \bmod b)$$

**为什么成立？** 设 $d = \gcd(a, b)$，即 $d \mid a$ 且 $d \mid b$。令 $a = q \cdot b + r$（其中 $0 \le r < b$，$r = a \bmod b$），则：

- $d \mid a$ 且 $d \mid b$ → $d \mid (a - q \cdot b) = r$ → $d$ 也是 $b$ 和 $r$ 的公约数
- 反过来，若 $d' \mid b$ 且 $d' \mid r$，则 $d' \mid (q \cdot b + r) = a$ → $d'$ 也是 $a$ 和 $b$ 的公约数

因此 $\{a, b\}$ 的公约数集合与 $\{b, a \bmod b\}$ 的公约数集合完全相同，最大元自然也相同 ✓

**终止条件**：当 $b = 0$ 时，$\gcd(a, 0) = a$（任何数与 0 的最大公约数是它本身）。

### 1.3 最小公倍数 LCM

**定义**：对于两个正整数 $a, b$，它们的最小公倍数（Least Common Multiple, LCM）是能同时被 $a$ 和 $b$ 整除的最小正整数，记作 $\text{lcm}(a, b)$。

例：$\text{lcm}(12, 18) = 36$，$\text{lcm}(7, 13) = 91$。

**核心公式**：

$$\gcd(a, b) \times \text{lcm}(a, b) = a \times b$$

变形得：

$$\text{lcm}(a, b) = \frac{a \times b}{\gcd(a, b)}$$

**为什么成立？** 从质因数分解角度看：设 $a = \prod p_i^{e_i}$，$b = \prod p_i^{f_i}$，则

- $\gcd(a, b) = \prod p_i^{\min(e_i, f_i)}$
- $\text{lcm}(a, b) = \prod p_i^{\max(e_i, f_i)}$

显然 $\min(e_i, f_i) + \max(e_i, f_i) = e_i + f_i$，对应指数相加即乘积等式成立 ✓

### 1.4 防溢出技巧：先除后乘

直接写 `a * b / gcd(a, b)` 有溢出风险：当 $a, b$ 都是 $10^9$ 时，$a \times b$ 可达 $10^{18}$，`int` 存不下。即使 `long long`，若 $a, b$ 更大也会溢出。

正确写法：

$$\text{lcm}(a, b) = \frac{a}{\gcd(a, b)} \times b$$

先除后乘，中间值更小，溢出概率大幅降低。本代码即采用此写法。

## 二、核心公式/状态定义与转移方程

### 2.1 欧几里得算法递归式

$$
\gcd(a, b) =
\begin{cases}
a, & b = 0 \\
\gcd(b, a \bmod b), & b \neq 0
\end{cases}
$$

### 2.2 复杂度分析

欧几里得算法的时间复杂度为 $O(\log \min(a, b))$。

**证明思路**（拉梅定理，Lamé's Theorem）：欧几里得算法的步数不超过较小数的十进制位数的 5 倍。

直觉上，$a \bmod b$ 至少比 $a$ 小一半（当 $b \le a/2$ 时显然；当 $b > a/2$ 时，$a \bmod b = a - b < a/2$），因此每次递归规模至少减半，步数为对数级。

### 2.3 性质速查

| 性质 | 公式 |
|------|------|
| 交换律 | $\gcd(a, b) = \gcd(b, a)$ |
| 结合律 | $\gcd(\gcd(a, b), c) = \gcd(a, \gcd(b, c))$ |
| 分配律 | $\gcd(k \cdot a, k \cdot b) = k \cdot \gcd(a, b)$ |
| 互质条件 | $\gcd(a, b) = 1 \iff a, b$ 互质 |
| 贝祖定理 | 存在整数 $x, y$ 使得 $a \cdot x + b \cdot y = \gcd(a, b)$ |
| GCD-LCM 关系 | $\gcd(a, b) \times \text{lcm}(a, b) = a \times b$ |
| LCM 分配律 | $\text{lcm}(k \cdot a, k \cdot b) = k \cdot \text{lcm}(a, b)$ |

## 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
```

标准头文件与命名空间。

### 3.1 _gcd —— 欧几里得算法递归实现

```cpp
long long _gcd(long long a, long long b)
{
    return b ? _gcd(b, a % b) : a;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `long long _gcd(long long a, long long b)` | 参数用 `long long`，支持大数；函数名前加下划线避免与 `std::gcd`（C++17）冲突 |
| 2 | `return b ? _gcd(b, a % b) : a;` | 三元运算符一行实现：若 $b \neq 0$，递归调用 `_gcd(b, a % b)`；若 $b = 0$，返回 $a$（终止条件） |

**执行示例**：$\gcd(48, 18)$

$$
\begin{align*}
\gcd(48, 18) &= \gcd(18, 48 \bmod 18) = \gcd(18, 12) \\
&= \gcd(12, 18 \bmod 12) = \gcd(12, 6) \\
&= \gcd(6, 12 \bmod 6) = \gcd(6, 0) \\
&= 6 \quad ✓
\end{align*}
$$

递归 3 层即得出结果。

### 3.2 _lcm —— 最小公倍数

```cpp
long long _lcm(long long a, long long b)
{
    return a / _gcd(a, b) * b;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `a / _gcd(a, b) * b` | **先除后乘**防溢出：$a / \gcd$ 必为整数（$\gcd$ 整除 $a$），再乘 $b$ 结果与 $a \times b / \gcd$ 相同但中间值更小 |

> **注意**：`a / gcd * b` 与 `b / gcd * a` 结果相同，但从溢出角度看，先用较大的数去除更安全。

### 3.3 main —— 多组测试

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int t;
    cin >> t;
    while (t--)
    {
        long long a, b;
        cin >> a >> b;
        cout << _gcd(a, b) << ' ' << _lcm(a, b) << '\n';
    }
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快速 IO，多组数据时加速输入输出 |
| 3-4 | `int t; cin >> t;` | 读入测试用例组数 |
| 5-8 | `while (t--) { cin >> a >> b; cout << ... << '\n'; }` | 每组读入两个数，输出 GCD 和 LCM，用 `'\n'` 代替 `endl` 避免刷新缓冲区 |

### 3.4 运行示例

输入：
```
3
12 18
7 13
100 25
```

输出：
```
6 36
1 91
25 100
```

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间（GCD） | $O(\log \min(a, b))$ | 欧几里得算法，递归深度为对数级 |
| 时间（LCM） | $O(\log \min(a, b))$ | 多一次除法和乘法，常数级额外开销 |
| 空间 | $O(\log \min(a, b))$ | 递归栈深度；迭代版为 $O(1)$ |

对于 $a, b \le 10^{18}$，递归深度约 60 层，几乎瞬间完成。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **约分 / 化简分数** | 分子分母同除以 GCD，得到最简分数 |
| **求最小公倍数** | 周期问题、调度问题中求重复周期 |
| **扩展欧几里得** | 求模逆元、解贝祖方程（GCD 是基础） |
| **数论计数** | 利用 GCD/LCM 性质统计满足条件的数对 |
| **判断互质** | $\gcd(a, b) = 1$ 即互质，数论中常见条件 |
| **多个数的 GCD/LCM** | 结合律保证可依次迭代计算：$\gcd(a, b, c) = \gcd(\gcd(a, b), c)$ |

## 六、常见陷阱与注意事项

### 6.1 a < b 时算法仍正确

$\gcd(18, 48)$ → $\gcd(48, 18 \bmod 48) = \gcd(48, 18)$，自动交换。**不需要**在调用前保证 $a \ge b$。

### 6.2 参数为 0 的情况

- $\gcd(a, 0) = a$（算法本身已处理，是终止条件）
- $\gcd(0, 0)$ 无定义，数学上不存在，代码会返回 0
- $\text{lcm}(a, 0) = 0$（任何数都是 0 的倍数），但代码中 `a / gcd(a,0) * 0 = a / a * 0 = 0`，结果正确

### 6.3 负数的 GCD

数学上 GCD 始终为正。若输入可能为负，需取绝对值：`_gcd(abs(a), abs(b))`。本代码假设输入为正整数。

### 6.4 溢出问题

- `a * b / gcd` 写法可能溢出，必须先除后乘：`a / gcd * b`
- 即使先除后乘，若 $a, b$ 都接近 `long long` 上限（$9 \times 10^{18}$），LCM 仍可能溢出；此时需用 `__int128` 或高精度

### 6.5 递归深度

对 $10^{18}$ 以内的数，递归深度约 60 层，不会栈溢出。但若有严格要求，可改写为迭代版：

```cpp
long long _gcd(long long a, long long b)
{
    while (b) { a %= b; swap(a, b); }
    return a;
}
```

### 6.6 C++17 内置 gcd

C++17 在 `<numeric>` 中提供了 `std::gcd` 和 `std::lcm`，但竞赛环境不一定支持，手写版本更稳妥。

### 6.7 多个数的 GCD/LCM

利用结合律迭代即可：

```cpp
long long gcd_n(vector<long long>& v)
{
    long long res = v[0];
    for (int i = 1; i < v.size(); i++)
        res = _gcd(res, v[i]);
    return res;
}
```

## 七、对比与扩展

### 7.1 递归版 vs 迭代版

| 维度 | 递归版 | 迭代版 |
|------|--------|--------|
| 代码长度 | 一行，极其简洁 | 三行循环 |
| 空间 | $O(\log n)$ 栈空间 | $O(1)$ |
| 可读性 | 接近数学定义，直观 | 稍低 |
| 栈溢出风险 | 极低（约 60 层） | 无 |
| 性能 | 函数调用开销略大 | 更快 |

### 7.2 更慢的方法：质因数分解法

先分别分解 $a, b$ 的质因数，再取指数的 min/max。复杂度为 $O(\sqrt{a} + \sqrt{b})$，远劣于欧几里得算法的 $O(\log \min(a,b))$，仅在需要质因数信息时使用。

### 7.3 扩展欧几里得算法

欧几里得算法的扩展版本，不仅求 $\gcd(a, b)$，还求贝祖系数 $x, y$ 使得 $a \cdot x + b \cdot y = \gcd(a, b)$。是求模逆元、解线性同余方程的基础。

### 7.4 二进制 GCD（Stein 算法）

用移位和减法代替取模，在某些硬件上更快，且特别适合大整数（高精度）实现。核心利用：

- $\gcd(2a, 2b) = 2 \cdot \gcd(a, b)$
- $\gcd(2a, b) = \gcd(a, b)$（$b$ 为奇数）
- $\gcd(a, b) = \gcd(|a-b|, \min(a, b))$（$a, b$ 均为奇数）

### 7.5 一句话总结

GCD 是数论的基石算法，欧几里得算法用一行递归实现了 $O(\log n)$ 的极致效率；LCM 通过 `先除后乘` 的公式从 GCD 衍生而来，两者共同构成了数论计数、模运算、扩展欧几里得等高级算法的基础。掌握 GCD 的性质与实现，是学习数论的第一步。$AKB301$, '数学', array['数学', '数论', '最大公约数', '最小公倍数', '欧几里得算法', '递归'], 'col-hub-math-number-theory', null, 'knowledge'),
('Fohen', 'col-math-group-theory--fenfeng', '群论 · Fohen', $AKB302$## 算法原理

群论（抽象代数）研究在集合上定义的代数结构及其运算性质。这一思想最早由伽罗瓦提出，最初用于解决一元高次方程的根式求解问题，此后不断拓展，如今已渗透到数论、代数几何、密码学与程序设计等多个领域。

在信息学竞赛中，群论的直接应用较少，唯一强相关的 Pólya 定理也极少出现；但群论的概念是许多数学内容的基础，缺少群论基础将难以理解矩阵、模运算、线性空间等内容。本节只介绍与竞赛相关的抽象代数基本概念，以「帮助理解概念」为目标，部分表述偏形象化而非严格化。

核心思想是**按约束从宽松到严格对代数对象分类**。一个抽象代数对象由「集合 + 一个（或两个）二元运算 + 若干公理」构成，每增加一条公理，结构就更丰富、可用性质也更多。

- 只含一个二元运算 $*$ 的对象，按约束递增：**原群 → 半群 → 幺半群 → 群 → 阿贝尔群**。
- 含两个二元运算 $\oplus,\otimes$ 的对象，按约束递增：**半环 → 环 → 交换环 → 整环 → 除环 → 域 → 有序域 → 代数闭域**。

## 核心公式 / 状态定义与转移方程

### 单运算结构

| 对象 | 新增公理 | 形式化条件 |
|---|---|---|
| 原群 | 封闭性 | $\forall a,b\in A,\ a*b\in A$ |
| 半群 | 结合律 | $(a*b)*c=a*(b*c)$ |
| 幺半群 | 单位元 | $\exists\, i\in A,\ \forall a\in A,\ a*i=a$ |
| 群 | 逆元 | $\forall a\in A,\ a*a^{-1}=i$ |
| 阿贝尔群 | 交换律 | $a*b=b*a$ |

### 双运算结构

设两种运算为 $\oplus$（加法）与 $\otimes$（乘法）。

- **半环**：$\oplus$ 构成交换幺半群，$\otimes$ 构成幺半群，且 $\otimes$ 对 $\oplus$ 满足分配律 $a\otimes(b\oplus c)=(a\otimes b)\oplus(a\otimes c)$。
- **环**：$\oplus$ 构成阿贝尔群，$\otimes$ 构成半群，且 $\otimes$ 对 $\oplus$ 满足分配律。
- **交换环**：在环的基础上，$\otimes$ 满足交换律。
- **整环**：在交换环的基础上无零因子，即 $\forall a,b\ne 0,\ ab\ne 0$。
- **除环**：在环的基础上，除加法单位元 $0$ 外每个元素有乘法逆元。
- **域**：交换环 + 无零因子 + 除加法单位元 $0$ 外每个元素有乘法逆元 + 两种运算的单位元不相等。
- **有序域**：在域的基础上可定义全序 $\le$，满足不等式的一切性质。
- **代数闭域**：在域的基础上，每个非常数多项式都有根。

## 逐行代码解析

本知识点为纯概念，下面用伪代码表示「判定一个代数对象类型」的思想步骤（仅为示意，非可运行代码）：

```cpp
// 单运算结构：逐层检查公理（从宽松到严格）

bool isMagma(A, op) {              // 原群：封闭性
    for (a in A) for (b in A)
        if (!A.contains(op(a, b))) return false;
    return true;
}

bool isSemigroup(A, op) {          // 半群：原群 + 结合律
    if (!isMagma(A, op)) return false;
    for (a in A) for (b in A) for (c in A)
        if (op(op(a, b), c) != op(a, op(b, c))) return false;
    return true;
}

bool isMonoid(A, op, i) {          // 幺半群：半群 + 单位元
    if (!isSemigroup(A, op)) return false;
    for (a in A) if (op(a, i) != a) return false;
    return true;
}

bool isGroup(A, op, i, inv) {      // 群：幺半群 + 逆元
    if (!isMonoid(A, op, i)) return false;
    for (a in A) if (op(a, inv(a)) != i) return false;
    return true;
}

bool isAbelianGroup(A, op, i, inv) { // 阿贝尔群：群 + 交换律
    if (!isGroup(A, op, i, inv)) return false;
    for (a in A) for (b in A)
        if (op(a, b) != op(b, a)) return false;
    return true;
}
```

要点：

- 每一层都在上一层基础上只多检查一条公理，层级严格递进。
- 封闭性检查需要枚举所有二元组，结合律需要枚举所有三元组，逆元需要预先知道每个元素的逆元。
- 双运算结构（环、域等）同理：先验证 $\oplus$ 与 $\otimes$ 各自的性质，再验证 $\otimes$ 对 $\oplus$ 的分配律与零因子等附加条件。

## 复杂度分析

群论本身是纯概念，**无统一的时间/空间复杂度**，具体取决于所应用的数据结构与算法：

- 有限集上直接检验「封闭性 / 结合律」：时间复杂度 $O(n^2)$ / $O(n^3)$（$n$ 为集合大小），空间复杂度 $O(1)$。
- 利用结合律维护区间信息（ST 表、倍增）：预处理 $O(n\log n)$，单次查询 $O(1)$。
- 利用逆元做前缀和与差分：$O(n)$ 预处理，$O(1)$ 单次查询。
- 利用逆元做快速幂：$O(\log k)$。

因此本知识点的 frontmatter 复杂度记为「视具体实现」。

## 适用场景

| 结构性质 | 典型 OI 应用 |
|---|---|
| 封闭性（原群） | 分块维护的操作只需满足封闭性 |
| 结合律（半群） | 树状数组、ST 表、LCA、倍增等基于二分/倍增的数据结构 |
| 单位元（幺半群） | 线段树懒标记、矩阵变换、字符串自动机 |
| 逆元（群） | 快速幂、前缀和与差分、FFT/NTT 等可撤销操作 |
| 交换律（阿贝尔群） | 线性基 |
| 半环 | 最短路（Floyd、矩阵乘法最短路） |
| 环 / 域 | 模运算：模质数域 $\mathbb{F}_p$、模合数剩余类环 $\mathbb{Z}_m$ |

## 常见陷阱与注意事项

1. **交换律比结合律难满足**：矩阵乘法满足结合律却不满足交换律（一般 $AB\ne BA$），不要想当然地认为运算可交换。
2. **零因子的存在**：模合数 $m$ 的剩余类中，两个非零因数 $a,b$（满足 $ab=m$）相乘为 $0$，即 $ab\equiv 0\pmod m$，故模合数剩余类不是整环，也不是域。
3. **群要排除无逆元的元素**：例如实数乘法中 $0$ 无乘法逆元，故 $(\mathbb{R},\times)$ 不是群；去掉 $0$ 后 $(\mathbb{R}\setminus\{0\},\times)$ 才是群。
4. **域要求两种单位元不相等**：加法单位元 $0$ 与乘法单位元 $1$ 必须不同，这是域的额外约束。
5. **有序域与偏序**：$\mathbb{Q}$、$\mathbb{R}$ 是有序域；$\mathbb{C}$ 不是有序域，其上只能定义偏序。
6. **层级递进别混淆**：半群 / 幺半群 / 群 / 阿贝尔群 逐层递进，判定时应从最宽松到最严格逐条核对公理。

## 对比与扩展

### 单运算结构对比

| 对象 | 新增公理 | 示例 |
|---|---|---|
| 原群 | 封闭性 | 任意定义了二元运算的集合 |
| 半群 | + 结合律 | 求最值、$\gcd$、矩阵乘法、字符串拼接 |
| 幺半群 | + 单位元 | $(\mathbb{Z},+,0)$ |
| 群 | + 逆元 | $(\mathbb{Z},+)$、$(\mathbb{R}\setminus\{0\},\times)$ |
| 阿贝尔群 | + 交换律 | $(\mathbb{Z},+)$、异或运算（线性基） |

### 双运算结构对比

| 对象 | 新增条件 | 示例 |
|---|---|---|
| 半环 | $\oplus$ 交换幺半群 + $\otimes$ 幺半群 + 分配律 | $(\min,+)$ 最短路 |
| 环 | $\oplus$ 阿贝尔群 + $\otimes$ 半群 + 分配律 | 模 $m$ 剩余类 $\mathbb{Z}_m$ |
| 交换环 | $\otimes$ 交换律 | 模合数剩余类 |
| 整环 | 无零因子 | $\mathbb{Z}$ |
| 除环 | 除零外有逆元 | 四元数 $\mathbb{H}$ |
| 域 | 交换环 + 无零因子 + 除零外有逆元 + 单位元不等 | $\mathbb{Q}$、$\mathbb{R}$、$\mathbb{C}$、$\mathbb{F}_p$ |
| 有序域 | 可定义全序 | $\mathbb{Q}$、$\mathbb{R}$ |
| 代数闭域 | 每个非常数多项式有根 | $\mathbb{C}$ |

### 扩展

- **Pólya 定理**：群论在组合计数中的经典应用，借助置换群统计在对称作用下「本质不同」的染色方案数。
- **有限域 $\mathbb{F}_p$**：模质数 $p$ 的剩余类构成域，是竞赛中模运算、求逆元、多项式运算的理论基础。
- **模合数剩余类环**：模合数时不构成域（存在零因子），因此不能直接做除法，需借助 CRT 或扩欧等技巧。$AKB302$, '数学', array['数学', '抽象代数', '群', '环', '域'], null, null, 'knowledge'),
('Xesir', 'col-math-group-theory--xesir', '群论 · 抽象代数对象分类 · Xesir', $AKB303$## 算法原理

~~四万万人齐下跪，天涯处处是神犇~~

群论，即抽象代数，被普遍认为是数学及其诸多应用中最基本~~也最抽象~~的内容。其最初由伽罗瓦提出，当时用于解决一元高次方程求解问题，后来不断延伸，概念已经渗透到各行各业。

OI 中群论的直接应用很少，唯一强相关的 Pólya 定理也很少出现。然而群论的概念是很多数学内容的基础，没有群论基础很难理解这些知识 ~~比如线代~~。所以本栏主要介绍群论相关的基本概念，并且属于选读内容：如果后面（也可能是前面）的内容里看到陌生的群论词汇，回来查这里就行。本栏以帮助理解概念为准，所以很多解释会**形象化而非严谨化**。

这一节的核心其实就一句话：**按约束从宽松到严格，给「集合 + 运算」排一条队**。

- 只有一个二元运算 $*$ 的：原群 → 半群 → 幺半群 → 群 → 阿贝尔群。
- 有两个二元运算 $\oplus,\otimes$ 的：半环 → 环 → 交换环 → 整环 → 除环 → 域 → 有序域 → 代数闭域。

每往上加一条公理，能用的性质就多一条，能套的数据结构/算法也就多一类。所以记这条链的正确方式不是背名字，而是记「**每层比上一层多了什么**」。

### 单运算：从「啥也不是」到「能交换」

- **原群**：一个集合 $A$ 上定义了二元运算 $*$，且对任意 $a,b\in A$ 有 $a*b\in A$。~~就是这样，没有任何要求了~~ 可以看成一个函数 `T op(T a,T b)`，取其所有返回值构成的集合。分块只要能维护满足原群条件的操作就行 ~~可以视为啥都能维护~~。
- **半群**：在原群基础上要求 $*$ 满足结合律 $(a*b)*c=a*(b*c)$。结合律是对一个运算最宽松的条件，求最值、$\gcd$、矩阵乘法、字符串拼接都满足。树状数组、LCA、ST 表这些基于二分/倍增的数据结构，维护的操作必须满足结合律。
- **幺半群**：在半群基础上要求存在单位元 $i$，使得 $\forall a\in A,\ a*i=a$（加法单位元就是 $0$）。线段树的懒标记、矩阵变换、字符串自动机，都需要操作有单位元。
- **群**：在幺半群基础上要求除单位元外每个元素都有逆元 $a^{-1}$，$\forall a\in A,\ a*a^{-1}=i$。例如除 $0$ 外任意实数的乘法逆元是倒数 $\frac{1}{a}$。快速幂、前缀和与差分、FFT/NTT 都要求操作有逆元，也就是满足**可撤销性**。
- **阿贝尔群**：在群基础上要求交换律 $a*b=b*a$。~~虽然看上去很反直觉，但交换律确实比结合律难满足得多，矩阵乘法就是经典的满足结合律不满足交换律~~ 线性基要求操作构成阿贝尔群。

### 双运算：环、域那一串

两个运算一般记作 $\oplus$（加法）和 $\otimes$（乘法），分配律是把两者缝在一起的那根线：

$$a\otimes(b\oplus c)=(a\otimes b)\oplus(a\otimes c)$$

- **半环**：$\oplus$ 构成交换幺半群，$\otimes$ 构成幺半群，且 $\otimes$ 对 $\oplus$ 有分配律。~~你猜为什么叫抽象数学~~ 若 $\oplus=\min,\ \otimes=+$，$\min$ 满足交换律且 $a+\min(b,c)=\min(a+b,a+c)$，于是两者构成半环——最短路算法要求的正是这个结构。
- **环**：$\oplus$ 构成阿贝尔群，$\otimes$ 构成半群，再加分配律。模 $m$ 的剩余类 $\mathbb{Z}_m$ 就是环，所以在模运算里到处能见到它。
- **交换环**：在环基础上要求 $\otimes$ 满足交换律。一般模合数的剩余类是交换环。
- **整环**：在交换环基础上要求没有零因子，即任意 $a,b\ne 0$ 有 $ab\ne 0$。听着显然，其实不是：模合数 $m$ 的剩余系里一定存在两个 $m$ 的因数 $a,b$ 使 $ab=m$，即 $ab\equiv 0\pmod m$，这就是零因子。整数集 $\mathbb{Z}$ 是整环。
- **除环**：在环基础上要求除加法单位元 $0$ 外每个元素都有逆元。四元数 $\mathbb{H}$ 是除环。
- **域**：几乎是性质最完备的抽象代数对象。交换环 + 无零因子 + 非零元都有逆元 + 两种运算的单位元不相等。有理数集 $\mathbb{Q}$、实数集 $\mathbb{R}$、复数集 $\mathbb{C}$、模质数 $p$ 的剩余系 $\mathbb{F}_p$ 都是域，其中 $\mathbb{F}_p$ 是有限域。域内可以做我们熟悉的任意四则运算，是常规数学的基石。
- **有序域**：在域基础上要求可以定义全序 $\le$，且满足不等式的所有性质。于是元素能排成 $\cdots\le a_{k+1}\le a_{k+2}\le\cdots$，每个元素都有确定位置。$\mathbb{Q}$、$\mathbb{R}$ 是有序域，$\mathbb{C}$ 不是，$\mathbb{C}$ 上只能定义偏序。
- **代数闭域**：在域基础上要求每个非常数多项式都有根，即没有真代数扩域。常见的域里只有 $\mathbb{C}$ 是代数闭域；$\mathbb{R}$ 不是，因为 $x^2+1=0$ 在实数范围内无解。

## 核心公式 / 状态定义与转移方程

这里的「公式」就是两条公理链。

### 单运算结构（约束由松到紧）

| 对象 | 比上一层多要求 | 形式化写法 |
|---|---|---|
| 原群 | 封闭性 | $\forall a,b\in A,\ a*b\in A$ |
| 半群 | 结合律 | $(a*b)*c=a*(b*c)$ |
| 幺半群 | 单位元 | $\exists i\in A,\ \forall a\in A,\ a*i=a$ |
| 群 | 逆元 | $\forall a\in A,\ a*a^{-1}=i$ |
| 阿贝尔群 | 交换律 | $a*b=b*a$ |

### 双运算结构

| 对象 | 结构要求 | 典型例子（原文给的） |
|---|---|---|
| 半环 | $\oplus$ 交换幺半群 + $\otimes$ 幺半群 + 分配律 | $(\min,+)$，最短路 |
| 环 | $\oplus$ 阿贝尔群 + $\otimes$ 半群 + 分配律 | 模 $m$ 剩余类 $\mathbb{Z}_m$ |
| 交换环 | 环 + $\otimes$ 交换律 | 模合数剩余类（原文举例写的是八元数） |
| 整环 | 交换环 + 无零因子 | $\mathbb{Z}$ |
| 除环 | 环 + 非零元有逆元 | 四元数 $\mathbb{H}$ |
| 域 | 交换环 + 无零因子 + 非零元有逆元 + 两单位元不等 | $\mathbb{Q},\mathbb{R},\mathbb{C},\mathbb{F}_p$ |
| 有序域 | 域 + 可定义全序 $\le$ | $\mathbb{Q},\mathbb{R}$ |
| 代数闭域 | 域 + 每个非常数多项式有根 | $\mathbb{C}$ |

> 原文在「交换环」处举例写的是八元数，这里照原样保留；不过八元数连结合律都不满足，拿它当交换环的例子其实不太合适，见「常见陷阱」。

## 逐行代码解析

这一节是纯概念，原文没有配套程序。下面只是把几条公理「翻译成代码」，方便把定义和数据结构对上号（都是示意片段，不是完整程序）。

### 模块一：结合律 —— 一个能合并的 `op`

```cpp
int op(int a, int b) { return max(a, b); }   // 求最大值：满足结合律
// max(max(a,b),c) == max(a,max(b,c))，所以区间信息可以任意分组先合并
```

- 分块、树状数组、ST 表、倍增，全都只要求「合并信息」这个操作满足结合律，不要求别的。
- 只要 `op` 满足结合律，区间就能拆成若干段分别算再合并——这就是倍增类数据结构的全部理论基础。

### 模块二：单位元 —— 空区间的返回值

```cpp
int query(int u, int l, int r, int ql, int qr) {
    if (qr < l || r < ql) return 0;          // 单位元：与 max 运算后不改变结果
    if (ql <= l && r <= qr) return tree[u];
    int mid = (l + r) >> 1;
    return op(query(u << 1, l, mid, ql, qr),
              query(u << 1 | 1, mid + 1, r, ql, qr));
}
```

- 越界分支返回的 `0` 就是幺半群里的那个单位元 $i$：$\max(x,0)=x$（值域非负时）。
- 换成区间乘/矩阵乘，这个返回值就得换成 $1$/单位矩阵——**单位元写错，整个结构就崩**，这是这类数据结构最常见的手滑点。

### 模块三：逆元 —— 前缀和、差分能「撤销」

```cpp
int s[N];                                     // 加法群 (Z,+)：逆元是 -a
int rangeSum(int l, int r) { return s[r] - s[l - 1]; }   // 减掉前缀 = 撤销前面的贡献
```

- 前缀和能做区间查询、差分能撤销修改、快速幂能算逆元，本质都是「这个运算有逆元」。
- 如果运算是 $\max$，就**没有**逆元（$\max(a,x)=b$ 解不出唯一 $a$），所以最值前缀和不能相减。

### 模块四：半环 —— 两个运算加分配律

```cpp
int addOp(int a, int b) { return min(a, b); }   // ⊕：交换幺半群
int mulOp(int a, int b) { return a + b; }       // ⊗：幺半群，单位元 0
// 分配律：a + min(b, c) == min(a + b, a + c)
```

- $(\min,+)$ 是「最短路半环」：$\oplus$ 取最优、$\otimes$ 做累加，于是松弛、Floyd、广义矩阵乘法都能统一写成一套式子。
- 半环没有逆元，所以不能用「撤销」的思路优化，只能老老实实合并。

## 复杂度分析

群论本身是概念，没有统一复杂度，具体取决于你拿它去描述什么算法：

| 场景 | 时间 | 空间 |
|---|---|---|
| 在有限集合上暴力验证封闭性 / 结合律 | $O(n^2)$ / $O(n^3)$（$n$ 为集合大小） | $O(1)$ |
| 用结合律维护区间信息（ST 表、倍增） | 预处理 $O(n\log n)$，查询 $O(1)$ | $O(n\log n)$ |
| 用逆元做前缀和 / 差分 | 预处理 $O(n)$，单次 $O(1)$ | $O(n)$ |
| 用逆元做快速幂 | $O(\log k)$ | $O(1)$ |
| 用半环做最短路 | $O(n^3)$（Floyd）/ $O(m\log n)$（堆优化 Dijkstra） | $O(n^2)$ / $O(n+m)$ |

所以 frontmatter 里时间与空间都记「视具体实现」——这不是偷懒，而是这一条本来就不对应某个具体算法。

## 适用场景

| 结构性质 | 在 OI 里对应的东西 |
|---|---|
| 封闭性（原群） | 分块维护的操作只需封闭 |
| 结合律（半群） | 树状数组、LCA、ST 表、倍增 |
| 单位元（幺半群） | 线段树懒标记、矩阵变换、字符串自动机 |
| 逆元（群） | 快速幂、前缀和与差分、FFT/NTT 等可撤销操作 |
| 交换律（阿贝尔群） | 线性基 |
| 半环 | 最短路、广义矩阵乘法 |
| 环 / 域 | 模运算：$\mathbb{Z}_m$ 是环，$\mathbb{F}_p$ 是域 |

**什么时候该翻这一篇**：写数据结构时想确认「这个操作能不能上线段树 / ST 表」，或者想确认「这个模数下能不能直接做除法」。这两种问题，答案都在这条公理链上。

## 常见陷阱与注意事项

1. **交换律比结合律难满足**。矩阵乘法满足结合律但不满足交换律，$AB\ne BA$（很多时候维度都不匹配）。不要想当然地把「可交换」当成默认性质。
2. **零因子的存在**。模合数 $m$ 的剩余类里，$m$ 的两个真因数相乘为 $0$（$ab\equiv 0\pmod m$），所以它不是整环、更不是域，不能直接做除法，得用扩欧 / CRT 绕。
3. **群里要踢掉没有逆元的元素**。$(\mathbb{R},\times)$ 不是群，因为 $0$ 没有乘法逆元；$(\mathbb{R}\setminus\{0\},\times)$ 才是群。原文在「群」处写「除单位 $0$ 外」，指的就是这件事。
4. **域要求两种单位元不相等**。加法单位元 $0$ 与乘法单位元 $1$ 必须不同，这条常被当成废话，但它确实是公理之一。
5. **有序域 vs 偏序**。$\mathbb{Q},\mathbb{R}$ 是有序域；$\mathbb{C}$ 上不存在与四则运算相容的全序，只能定义偏序。复数「不能比大小」就是这个原因。
6. **八元数那个例子存疑**。原文把八元数放在「交换环」下举例，但八元数连结合律都不满足（它甚至连四元数都不是交换的），严格说只能算「非结合代数」。这里保留原样只是尊重原文，不要把它当结论背。
7. **别把「链」记反**。公理是从宽松到严格的**包含**关系：每个群都是幺半群，每个幺半群都是半群，反过来不成立。判断某个对象属于哪一层，从最宽松的条件往上逐条对。
8. **概念不能直接当模板用**。知道「矩阵乘法是半群」并不会让你写出矩阵快速幂；这一篇的价值在于遇到「能不能撤销 / 能不能合并」时，能立刻判掉整条路。

## 对比与扩展

- **Pólya 定理**：群论在组合计数里最经典的应用，用置换群统计在对称作用下「本质不同」的染色方案。原文也提到它是 OI 里唯一强相关的应用。
- **有限域 $\mathbb{F}_p$**：模质数剩余系构成域，是模运算、求逆元、多项式运算的理论地基；模合数就只剩环，很多操作会失效。
- **线性空间**：把「向量 + 加法 + 数乘」也按公理组织起来，就是线性代数里那套理论，见[线性代数](?id=math-linear-algebra)。$AKB303$, '数学', array['数学', '群论', '抽象代数', '群', '环', '域'], null, null, 'knowledge'),
('stripe-python', 'col-math-inclusion-exclusion--stripe-python', '容斥原理（含 min-max 容斥与斯特林反演） · stripe-python', $AKB304$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 8. 容斥原理

容斥原理是加法 & 减法原理的推广。

## 8.1 引入

用一个例题引入：假设班里有 $a$ 个学生喜欢语文，$b$ 个学生喜欢数学，$c$ 个数学喜欢英语，则班里至少喜欢一门学科的有多少个学生？

显然你不能简单地用 $a+b+c$ 计算，因为可以有学生同时喜欢两门甚至三门学科。我们使用集合论语言，设喜欢三门学科的学生集合为 $A,B,C$，则所求为 $|A \cup B \cup C|$。因为 $|A|+|B|+|C|=a+b+c$ 这样会把同时喜欢两个学科的人算重，需要减去 $|A \cap B|+|A \cap C|+ |B \cap C|$。然而这样又会把同时喜欢三个学科的人减去，所以又要加上 $|A \cap B \cap C|$。于是答案为

$|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$这就是三维容斥。

## 8.2 一般形式

更一般地，有

$|\cup_{i=1}^{n} S_i|=\sum_{m=1}^n (-1)^{m-1} \sum_{a_i<a_{i+1}} |\cap _{i=1}^m S_{a_i}|$可以用减法原理结合数学归纳法证明。

用到容斥的地方其实很多，减法原理就是最简单的容斥，高维前缀和也有容斥做法，下文所说的二项式反演、Stirling 反演本质就是有系数的容斥。

需要注意，某些计数 DP 的题也会用到容斥思想，此时我们设计两个 DP 数组 $f_i,g_i$，分别表示总方案数与合法方案数，转移形如 $g_i =\sum_{j} (f_j-h(j))$，其中 $h(j)$ 表示 $j$ 处不合法的方案数。容斥原理的本质就是像这样的多次减法原理。

## *8.3 一般化

对于两个集合函数 $f(S),g(S)$，我们有

$f(S)=\sum_{T \subseteq S} g(T) \Leftrightarrow g(S)=\sum_{T \subseteq S} (-1)^{|S|-|T|} f(T)$这个过程又叫做**子集反演**。上面给出的是子集反演的形式一，取补集可以得到子集反演形式二：

$f(S)=\sum_{S \subseteq T} g(T) \Leftrightarrow g(S)=\sum_{S \subseteq T} (-1) ^{|T|-|S|} f(T)$下文第 11 章的二项式反演，就可以看作子集反演在元素都相等时的特例。

## 8.4 例题

### CF1207D Number Of Permutations

考察好序列的性质，发现不太好计数，于是我们用容斥把它拆开，所求变为：总方案数 $-$ 第一维 $a_i$ 有序的方案数 $-$ 第二维 $b_i$ 有序的方案数 $+$ 两维 $a_i,b_i$ 同时有序的方案数。

显然总方案数是 $n!$。对于单维有序的情况，$a_i,b_i$ 同理，这里只讨论 $a_i$。先完成排序后每一块相同的数可以任意交换，于是我们开个桶来计数，由乘法原理可知答案是 $\prod_{i=1}^{n} cnt_i!$。两维同时有序，和上述类似，我们用桶 $p_{i,j}$ 记录数对 $(i,j)$ 的出现次数，所求为 $\prod_{i=1}^{n} p_{a_i,b_i}$。于是我们预处理阶乘即可。

但是要注意两维同时有序可能无解，需要排个序特判一波。

> 以及：CF 有 hack 机制能用 unordered_map 吗？

```cpp
const int N = 3e5 + 5;
using p32 = pair<int, int>;

mint fac[N];
int n, a, b;
p32 h[N];
map<int, int> cnt1, cnt2;
map<p32, int> p;

void _main() {
	cin >> n;
	fac[0] = 1;
	for (int i = 1; i <= n; i++) fac[i] = fac[i - 1] * i;
	for (int i = 1; i <= n; i++) {
		cin >> a >> b, h[i] = make_pair(a, b);
		cnt1[a]++, cnt2[b]++, p[h[i]]++;
	}
	sort(h + 1, h + n + 1);
	mint c0 = fac[n], c1 = 1, c2 = 1, c12 = 1;
	for (int i = 2; i <= n; i++) {
		if (h[i].second < h[i - 1].second) c12 = 0;
	}
	for (const auto& i : cnt1) c1 *= fac[i.second];
	for (const auto& i : cnt2) c2 *= fac[i.second];
	for (const auto& i : p) c12 *= fac[i.second];
	cout << c0 - c1 - c2 + c12;
}
```

### P1447 [NOI2010] 能量采集

组合数学的原理也可以解决数论问题。在前面的欧拉函数部分，我们知道这样的问题答案是

$\sum_{i=1}^{n} \sum_{j=1}^{m} (2\times\gcd(i, j)-1)=2\sum_{i=1}^{n} \sum_{j=1}^{m} \gcd(i,j)-nm$可以发现 $\gcd(i,j)$ 的值只有 $n$ 种，不妨考虑 $gcd(i,j)=k$ 的数目，设其数目为 $f(k)$。我们可以考虑求以 $k$ 为公约数的数对数目，再减去以 $k$ 的倍数为公约数的数对数目。进一步推导，以 $k$  的倍数为公约数的数对个数等于所有以 $k$ 的倍数为最大公约数的数对个数之和。于是有

$f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor -\sum_{i=2}^{ik \le \min(n,m)} f(ik)$我们发现 $2k > \min(n,m)$ 时 $f(k)=\lfloor \dfrac{n}{k} \rfloor \times\lfloor \dfrac{m}{k} \rfloor$，于是倒着算就行了，是调和型枚举，复杂度 $O(n \log n)$。于是 GCD SUM 问题就多了一种容斥做法。

```cpp
const int N = 1e5 + 5;
long long f[N];
int n, m;

void _main() {
	cin >> n >> m;
	for (int k = n; k >= 1; k--) {
		f[k] = 1LL * (n / k) * (m / k);
		for (int i = 2; i * k <= min(n, m); i++) f[k] -= f[i * k];
	}
	long long res = 0;
	for (int i = 1; i <= n; i++) res += f[i] * i;
	cout << res * 2 - 1LL * n * m;
}
```

### AT_abc162_e [ABC162E] Sum of gcd of Tuples (Hard)

笔者数论训练赛の T5。和上面题的套路一样，我们发现，$\gcd a_i=k$ 时当且仅当 $a_1,a_2, \cdots,a_n$ 均为 $k$ 的倍数，且这个倍数是互质的。考虑容斥 + DP，令 $dp_x$ 表示 $[1,x]$ 内选出 $n$ 个互质数的方法数目。考虑用减法原理，总数目减去不互质的方案，枚举公约数 $i$，则根据约数性质可得

$dp_x=x^n-\sum_{i=2}^{x} dp_{\lfloor \frac{x}{i} \rfloor}$赛时写的记搜。可以发现这个东西就是高维容斥。

```cpp
int n, k;
mint dp[N];
mint solve(int x) {
	if (dp[x] != 0) return dp[x];
	if (x == 1) return dp[x] = 1;
	mint res = mint(x).pow(n);
	for (int i = 2; i <= x; i++) {
		res -= solve(x / i);
	} return dp[x] = res;
}

void _main() {
	cin >> n >> k;
	mint res = 0;
	for (int i = 1; i <= k; i++) res += solve(k / i) * i;
	cout << res;
}
```

### AT_abc366_d [ABC366D] Cuboid Sum Query

三维前缀和板子题，容斥原理的另一种应用。我们先来推三维前缀和怎么算。设 $pre_{i,j,k}$ 表示以 $(i,j,k)$ 为右下角的立方体数字之和，则它显然由 $a_{i,j,k}$ 贡献。同时考虑去掉一行 / 一列 / 一柱，加上 $pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}$。这样我们会把同时退掉两维的前缀和算重，于是减去 $pre_{i-1,j-1,k}+pre_{i-1,j,k-1}+pre_{i,j-1,k-1}$。这样又把退掉三维的前缀和减多了，所以加上 $pre_{i-1,j-1,k-1}$。总的转移为

$pre_{i,j,k}=a_{i,j,k}+pre_{i-1,j,k}+pre_{i,j-1,k}+pre_{i,j,k-1}-pre_{i-1,j-1,k}-pre_{i-1,j,k-1}-pre_{i,j-1,k-1}+pre_{i-1,j-1,k-1}$接着我们考虑单次询问以 $(x_1,y_1,z_1)$ 为左上角，$(x_2,y_2,z_2)$ 为右下角的立方体点权之和。同理可得答案为

$pre_{x_2,y_2,z_2}-pre_{x_1-1,y_2,z_2}-pre_{x_2,y_1-1,z_2}-pre_{x_2,y_2,z_1-1}+pre_{x_1-1,y_1-1,z_2}+pre_{x_1-1,y_2,z_1-1}+pre_{x_2,y_1-1,z_1-1}-pre_{x_1-1,y_1-1,z_1-1}$这两个式子本质是三维容斥原理 $|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B\cap C|+|A \cup B \cup C|$。

于是我们在预处理 $O(n^3)$，查询 $O(1)$ 下解决了该问题。

```cpp
const int N = 105;
int n, q, a[N][N][N], pre[N][N][N];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) cin >> a[i][j][k];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			for (int k = 1; k <= n; k++) {
				pre[i][j][k] = a[i][j][k]
				+ pre[i][j][k - 1] + pre[i][j - 1][k] + pre[i - 1][j][k]
				- pre[i][j - 1][k - 1] - pre[i - 1][j][k - 1] - pre[i - 1][j - 1][k]
				+ pre[i - 1][j - 1][k - 1];
			}
		}
	}
	cin >> q;
	while (q--) {
		int x1, x2, y1, y2, z1, z2;
		cin >> x1 >> x2 >> y1 >> y2 >> z1 >> z2;
		cout << (pre[x2][y2][z2]
		- pre[x1 - 1][y2][z2] - pre[x2][y1 - 1][z2] - pre[x2][y2][z1 - 1]
		+ pre[x1 - 1][y1 - 1][z2] + pre[x1 - 1][y2][z1 - 1] + pre[x2][y1 - 1][z1 - 1]
		- pre[x1 - 1][y1 - 1][z1 - 1]) << '\n';
	}
}
```

### P8315 [COCI 2021/2022 #4] Šarenlist

集合容斥板子。

注意到 $m \le 15$，考虑 $O(2^m)$ 枚举一些限制并钦定其不满足。用一个 DFS 搜出路径，然后化边为点，并查集维护一下连通块数目 $c$，贡献就是 $k^c$。容斥系数为 $(-1)^{\operatorname{popcount}(S)}$。复杂度 $O(nm2^m \log n)$。

```cpp
const int N = 65;
int n, m, k, u, v;
pair<int, int> a[N];
int tot = 1, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int fa[N], sz[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
void unite(int x, int y) {fa[find(x)] = find(y);}

vector<int> p[N];
bool dfs(int u, int fa, int to, vector<int>& vec) {
	if (u == to) return true;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		vec.emplace_back(j >> 1);
		if (dfs(v, u, to, vec)) return true;
		vec.pop_back();
	} return false;
}

void _main() {
	cin >> n >> m >> k;
	for (int i = 1; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	for (int i = 1; i <= m; i++) {
		cin >> a[i], dfs(a[i].first, -1, a[i].second, p[i]);
	}
	mint res = 0;
	for (int s = 0; s < (1 << m); s++) {
		iota(fa + 1, fa + n + 1, 1);
		for (int i = 1; i <= m; i++) {
			if (!(s >> (i - 1) & 1)) continue;
			for (int j = 1; j < (int) p[i].size(); j++) unite(p[i][j - 1], p[i][j]);
		}
		int part = 0;
		for (int i = 1; i < n; i++) part += (i == find(i));
		if (popcount(s) & 1) res -= mint(k).pow(part);
		else res += mint(k).pow(part);
	} cout << res;
}
```

### P1450 [HAOI2008] 硬币购物

先考虑跑一个完全背包，令 $dp_{i,j}$ 表示前 $i$ 种硬币支付 $j$ 元的方案数，有

$dp_{i,j}=dp_{i-1,j}+dp_{i,j-x_i}$滚动数组优化一下，答案为 $dp_n$。这样会算多，于是我们把第 $1,2,3,4$ 种硬币超限的情况分别减掉。又减多了，加回来……可以看到是一个容斥的过程。写出四维容斥原理：

$$
|A\cup B \cup C \cup D|=
|A|+|B|+|C|+|D|
-|A\cap B|-|A\cap C|-|A\cap D|-|B\cap C|-|B \cap D|-|C \cap D|
+|A\cap B\cap C|+|A\cap B\cap D|+|A\cap C\cap D|+|B\cap C \cap D|
-|A\cap B\cap C \cap D|
$$

最后再用一个总的减法原理即可。

```cpp
#define int long long
const int N = 1e5 + 5;
int a, b, c, d, s, c1, c2, c3, c4, q, dp[N];
void work(int x) {
	for (int i = x; i < N; i++) dp[i] += dp[i - x];
}
int f(int x) {return x < 0 ? 0 : dp[x];}

void _main() {
	cin >> c1 >> c2 >> c3 >> c4;
	dp[0] = 1;
	work(c1), work(c2), work(c3), work(c4);
	for (cin >> q; q--; ) {
		cin >> a >> b >> c >> d >> s;
		a = (a + 1) * c1, b = (b + 1) * c2, c = (c + 1) * c3, d = (d + 1) * c4;
		cout << f(s) - f(s - a) - f(s - b) - f(s - c) - f(s - d)
			+ f(s - a - b) + f(s - a - c) + f(s - a - d) + f(s - b - c) + f(s - b - d) + f(s - c - d)
			- f(s - a - b - c) - f(s - a - b - d) - f(s - a - c - d) - f(s - b - c - d)
			+ f(s - a - b - c - d) << '\n';
	}
}
```

### *P6651 「SWTR-5」Chain

一步一步考虑，先想无修改怎么做，我们在拓扑序上做 DP，由加法原理

$f_{i} \gets f_{i}+f_j$进一步地，由于 $n\le 2\times 10^3$，我们可以利用拓扑排序，在 $O(n^2)$ 时间内预处理从 $u$ 到 $v$ 的链数，则

$dp_{k,v} \gets dp_{k,v}+dp_{k,u}$类似 Floyd 那样，对于有向边 $(u,v)$，枚举中继点 $k \in [1,n]$，由加法原理合并。记入度为 $ideg_i$，出度为 $odeg_i$，则总链数

$tot=\sum_{ideg_i=0} \sum_{odeg_j=0} dp_{i,j}$因为一条链的起终点一定满足上述条件。接着我们考虑 $k=1$ 的做法，套路地，记 $f_i$ 为链起点到点 $i$ 的方案数，然后建反图，记 $g_i$ 是反图上的 $f_i$，发现 $g_i$ 等价于原图中点 $i$ 到链终点的方案数。由 $dp_{i,j}$ 的定义易得转移：

$$
f_i = \sum_{ideg_j=0} dp_{j,i}\\
g_i = \sum_{odeg_j=0} dp_{i,j}
$$

那么 $k=1$ 的情况就可以用 $tot-f_ig_i$ 回答。接着我们想 $k=2$，不妨设两点 $u,v$ 中 $u$ 的拓扑序小于 $v$，分类讨论：

- 若 $u,v$ 不在同一条链上，直接用 $tot-f_ug_u-f_vg_v$ 回答；
- 若 $u,v$ 可以在同一条链上，那么 $u$ 到终端的路径包含了 $v$。考虑容斥把重复的加回来，这里的重复是 $f_ug_v dp_{u,v}$，答案为 $tot-f_ug_u-f_vg_v+f_ug_v dp_{u,v}=tot-f_ug_u-g_v(f_v-f_udp_{u,v})$。

接着我们扩展到 $k \le 15$。我们先按拓扑序排序，对于每个点处理要容斥掉的数 $h_i$，则

$h_i=f_i-\sum h_j dp_{j,i}$其中 $j$ 的拓扑序在 $i$ 之前。于是答案为

$tot-\sum h_ig_i$至此，我们在预处理 $O(n^2+m)$，单次查询 $O(k^2)$ 的复杂度下解决了此问题。

```cpp
const int N = 2e3 + 5, M = 2e4 + 5;

int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[M];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
int n, m, u, v, q, len, ideg[N], odeg[N];

int cnt, bfn[N];
mint dp[N][N], f[N], g[N], h[20];
void topo() {
	queue<int> q;
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) q.emplace(i);
		dp[i][i] = 1;
	}
	while (!q.empty()) {
		int u = q.front(); q.pop();
		bfn[u] = ++cnt;
		for (int j = head[u]; j != 0; j = edge[j].next) {
			int v = edge[j].to;
			for (int k = 1; k <= n; k++) dp[k][v] += dp[k][u];
			if (--ideg[v] == 0) q.emplace(v);
		}
	}
}

vector<int> st, ed;
void _main() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		cin >> u >> v;
		add_edge(u, v);
		odeg[u]++, ideg[v]++;
	}
	for (int i = 1; i <= n; i++) {
		if (ideg[i] == 0) st.emplace_back(i);
		if (odeg[i] == 0) ed.emplace_back(i);
	} topo();
	mint tot = 0;
	for (int i : st) {
		for (int j : ed) tot += dp[i][j];
	}
	for (int i = 1; i <= n; i++) {
		for (int j : st) f[i] += dp[j][i];
		for (int j : ed) g[i] += dp[i][j];
	}
	for (cin >> q; q--; ) {
		fill(h, h + len, 0);
		cin >> len;
		vector<int> c;
		for (int i = 0; i < len; i++) cin >> u, c.emplace_back(u);
		sort(c.begin(), c.end(), [](int x, int y) -> bool {
			return bfn[x] < bfn[y];
		});
		for (int i = 0; i < len; i++) {
			h[i] = f[c[i]];
			for (int j = 0; j < i; j++) h[i] -= dp[c[j]][c[i]] * h[j];
		}
		mint res = 0;
		for (int i = 0; i < len; i++) res += h[i] * g[c[i]];
		cout << tot - res << '\n';
	}
}
```

### *P5933 [清华集训 2012] 串珠子

绝世好题。前置知识：18.2 子集枚举。下面是本人模拟赛上的思考过程：

注意到 $n \le 16$，一眼状压 DP。如果复杂度是 $O(n2^n)$ 完全可以开到 $20$，所以这题复杂度是 $O(n^22^n)$ 或者 $O(3^n)$。如果考虑 $O(3^n)$，思考子集枚举，分成两个连通块合并答案。发现会算重。

正难则反，记 $g_S$ 表示 $S$ 这个点集的总方案数，显然 $g_S=\prod _{u,v \in S} (a_{u,v}+1)$，可以 $O(n^2 2^n)$ 预处理。考虑计数 DP 配合高维容斥，设 $f_S$ 表示 $S$ 这个点集的答案，用减法原理算出 $f_S$ 即可。枚举 $T \subseteq S$，表示从 $S$ 中钦定一个连通块，其余点任意，则

$f_S =g_S - \sum_{T \subseteq S} f_T \times  g_{S \setminus T}$写完发现减多了，样例得到了宇宙终极答案 $42$。考虑手玩样例，$|S| \le 1$ 的集合显然，直接看 $|S| \ge 2$ 的集合：

- $S=\{1,2\}$，则 $f_S=2,g_S=3$。
- $S=\{1,3\}$，则 $f_S=3,g_S=4$。
- $S=\{2,3\}$，则 $f_S=4,g_S=5$。
- $S=\{1,2,3\}$，列出可能的 $T$ 和 $S \setminus T$：

| $T$ | $S \setminus T$ | $f_T$ | $g_{S \setminus T}$ |
| --- | --- | --- | --- |
| $\{1\}$ | $\{2,3\}$ | $1$ | $5$ |
| $\{2\}$ | $\{1,3\}$ | $1$ | $4$ |
| $\{3\}$ | $\{1,2\}$ | $1$ | $3$ |
| $\{2,3\}$ | $\{1\}$ | $4$ | $2$ |
| $\{1,3\}$ | $\{2\}$ | $3$ | $2$ |
| $\{1,2\}$ | $\{3\}$ | $2$ | $2$ |

而 $g_S=3 \times 4 \times 5=60$，按这种方法减去就是 $42$。

考虑为什么会减多。发现 $(T, S \setminus T)$ 会被重复计算两次。并且贡献不同，没有办法用简单的 $\times \dfrac{1}{2}$ 处理。观察不重的三组，比如 1、3、5 行，可以发现：$2 \in (S \setminus T)$。于是有一个神奇的做法：钦定一个点，强制让它属于 $S$ 集合，就实现了去重。

最终复杂度为 $O(3^n)$。赛时代码：

```cpp
const int N = 17;
mint a[N][N], f[1 << N], g[1 << N];
int n;

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) cin >> a[i][j];
	}
	for (int i = 0; i < (1 << n); i++) {
		g[i] = 1;
		for (int j = 1; j <= n; j++) {
			if (!(i >> (j - 1) & 1)) continue;
			for (int k = j + 1; k <= n; k++) {
				if (i >> (k - 1) & 1) g[i] *= a[j][k] + 1;
			}
		}
	}
	for (int i = 1; i < (1 << n); i++) {
		f[i] = g[i];
		int d = -1;
		for (int j = 0; j < n; j++) {
			if (i >> j & 1) {d = j; break;}
		}
		int s = i ^ (1 << d);
		for (int j = s; j; j = (j - 1) & s) f[i] -= g[j] * f[(s ^ j) | (1 << d)];
	} cout << f[(1 << n) - 1];
}
```

### *P11197 [COTS 2021] 赛狗游戏 Tiket

先转化一下题意，排列 $T$ 不影响答案，因为数对交换一下就满足条件 2。设 $a_i,b_i,c_i$ 为三个排列中 $i$ 出现的位置，问题变成求满足 $a_i<a_j,b_i<b_j,c_i<c_j$ 的三元组 $(i,j,k)$ 数目。

这是三维偏序的模板，使用高级数据结构可做到 $O(n \log^2 n)$。观察到，$a,b,c$ 都是排列。事实上，应用容斥原理可以简单地解决排列上的三维偏序问题。

设 $A=\{(i,j) \mid a_i<a_j\}, B=\{(i,j) \mid b_i<b_j\},C=\{(i,j) \mid c_i<c_j\}$，所求为 $|A \cap B \cap C|$，容斥一下得到

$|A\cap B\cap C|=\dfrac{1}{2}(|A \cap B|+|B \cap C|+|A \cap C|-|A \cup B \cup C|)$对于形如 $|A \cap B|$ 的三部分，做一个二维偏序即可 $O(n \log n)$。考虑 $|A \cup B \cup C|$，若 $(i,j)$ 满足一维偏序，则 $(j,i)$ 满足二维偏序；若其满足二维偏序，则 $(j,i)$ 满足一维偏序；若其满足三维偏序，则 $(j,i)$ 不满足任何偏序。因此，每个 $(i,j)$ 在 $|A \cup B \cup C|$ 中恰好被贡献一次，即 $|A \cup B \cup C|=\dfrac{n(n-1)}{2}$。

于是我们只要做三次二维偏序即可做到 $O(n \log n)$。

```cpp
const int N = 5e5 + 5;
int n, x, a[N], b[N], c[N], d[N], tr[N];
void add(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int ask(int x) {
	int res = 0;
	for (; x >= 1; x -= lowbit(x)) res += tr[x];
	return res;
}
long long solve(int *a, int *b) {
	fill(tr + 1, tr + n + 1, 0);
	long long res = 0;
	for (int i = 1; i <= n; i++) d[b[i]] = a[i];
	for (int i = 1; i <= n; i++) res += ask(d[i]), add(d[i], 1);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> x;
	for (int i = 1; i <= n; i++) cin >> x, a[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, b[x] = i;
	for (int i = 1; i <= n; i++) cin >> x, c[x] = i;
	cout << (solve(a, b) + solve(a, c) + solve(b, c) - 1LL * n * (n - 1) / 2) / 2;
}
```

## 附：计数基础·容斥与反演（stripe-python）

## 2. 容斥原理

OI 中的**容斥原理**是一类计数方法的统称。下面先介绍一个最朴素的容斥：

考虑有限集 $A,B,C$，我们要计数 $A \cup B \cup C$ 的元素数目，那么有
$$
|A \cup B \cup C|=|A|+|B|+|C|-|A \cap B|-|A \cap C|-|B \cap C|+|A \cap B \cap C|
$$
将上述结论推广，记全集为 $U$，元素共有 $n$ 种属性，具有第 $i$ 种属性的元素构成集合 $S_i$，则不具有任何属性的元素数目为
$$
\left|U\right|-\left| \bigcup_{i=1}^n S_i \right|=\sum_{k=0}^n (-1)^k \sum \left|\bigcap_{i=1}^k S_{p_i} \right|
$$
上式中，$(-1)^k$ 称为**容斥系数**。第二个 $\sum$ 的要求为：选出 $k$ 个不同的下标，记为 $p_1 \sim p_k$。

第二个求和的组合意义引出了**钦定**的概念。我们钦定 $k$ 种属性 $p_1 \sim p_k$，并计算具有这些属性的元素数目。请注意，这里计数的元素一定具有 $p_1 \sim p_k$ 这些属性，但并不是只有这些属性。因此，更准确的组合意义应该是**钦定至少**。

:::::info[说明]{open}

**钦定至少**的组合意义隐含着两步：先枚举 $p_1 \sim p_k$，再计数具有这些属性的元素数目。每种钦定方式的元素数目需要求和。

另一种组合意义叫做**选择至少**，相当于直接求属性个数 $\ge k$ 的元素数目。

钦定和选择的组合意义是完全不同的，请读者注意区分。

:::::

容易发现，一个元素会被不同的钦定至少算到多次。形式化地，对于一个元素 $x \in U$，设其具有的属性集合为 $A$，则其被钦定方式 $B$ 算到当且仅当 $B \subseteq A$。因此：

- $x$ 会被计算 $2^{|A|}$ 次。
- 有关 $x$ 的容斥系数之和为 $\sum\limits_{B \subseteq A} (-1)^{|B|} =[A = \varnothing]$。

:::::success[代数推导]

考虑枚举 $|B|=k$，于是
$$
\begin{aligned}
\sum_{B \subseteq A} (-1)^{|B|}&=\sum_{k=0}^{|A|} (-1)^k \binom{|A|}{k}\\
&=(-1+1)^{|A|}\\
&=0
\end{aligned}
$$
当 $A =\varnothing$ 时上式的值为 $1$。

:::::

由于系数为 $[A =\varnothing]$，没有任何属性的元素被计算 $1$ 次，具有属性的元素被计算 $0$ 次。因此，钦定至少的容斥方法可以正确算出答案。

需要注意的是，朴素地计算这个容斥式的复杂度为 $O(n2^n)$。在很多题目中，我们可以以更低的复杂度计算 $\sum \left|\bigcap\limits_{i=1}^k S_{p_i} \right|$ 。

从这个式子中，我们可以得到容斥原理的核心思想：用一种容斥方法，将每个元素计算多次，并配以恰当的容斥系数，使得容斥系数之和恰好就是我们希望的系数。

### 2.3 min-max 容斥

**min-max 容斥**又称为最值反演。对于长度为 $n$ 的序列 $a_i$，记 $S=\{1,2,\cdots,n\}$，那么
$$
\max_{i \in S} a_i=\sum_ {T \subseteq S} (-1)^{|T|-1} \min_{i \in T} a_j\\
\min_{i \in S} a_i=\sum_ {T \subseteq S} (-1)^{|T|-1} \max_{i \in T} a_j\\
$$
min-max 容斥实现了 $\min$ 和 $\max$ 的转化，$(-1)^{|T|-1}$ 是这一转化的容斥系数。

记第 $k$ 小为 $k \text{th}\min$，则扩展 min-max 容斥指出
$$
k\text{th}\max_{i \in S} = \sum_{T \subseteq S} (-1)^{|T|-k} \binom{|T|-1}{k-1} \min_{i \in S} a_i\\
k\text{th}\min_{i \in S} = \sum_{T \subseteq S} (-1)^{|T|-k} \binom{|T|-1}{k-1} \max_{i \in S} a_i\\
$$
 类似于朴素容斥推广到二项式反演，min-max 容斥推广到扩展 min-max 容斥也是同理。$(-1)^{|T|-k} \dbinom{|T|-1}{k-1}$ 是扩展 min-max 容斥的容斥系数。

值得注意的是，由于期望线性性的存在，对等式两边同时套一个期望，min-max 容斥仍然成立。因此这个式子常用于计算最值的期望。

另一个应用是，考虑对质因数分解后的指数做 min-max 容斥，那么有 gcd-lcm 推广：
$$
\underset{i\in S}{\operatorname{lcm}} a_i=\prod _{T \subseteq S} \left(\gcd_{i \in T} a_i \right)^{(-1)^{|T|-1}}
$$

### 2.4 斯特林反演

类比二项式反演的 $g(k)=\sum\limits_{i=k}^n \dbinom{i}{n} f(i)$，如果系数由组合数变成了斯特林数，而我们仍然希望配上容斥系数实现 $g \to f$ 的转化，则需要利用**斯特林反演**的结论：
$$
g(k)=\sum_{i=k}^n \left\{\begin{matrix}
n \\
i
\end{matrix}\right\} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k} \begin{bmatrix}
n \\
i
\end{bmatrix} g(i)\\
g(k)=\sum_{i=k}^n \begin{bmatrix}
n \\
i
\end{bmatrix} f(i) \iff f(k)=\sum_{i=k}^n (-1)^{i-k} \left\{\begin{matrix}
n \\
i
\end{matrix}\right\} g(i)
$$
这两个式子揭示了两类斯特林数的内在联系。$AKB304$, '数学', array['容斥原理', 'min-max 容斥', '斯特林反演', '计数'], 'col-math-combinatorics', null, 'knowledge'),
('stripe-python', 'col-math-lagrange-interpolation--stripe-python', '插值法（Lagrange / Newton） · stripe-python', $AKB305$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 24. 插值法

## 24.1 引入

Q: 找规律：$1,2,3$，填下一项。

A: 填 $114514$。因为 $f(x)=19085x^3-114510x^2+209936x-114510$ 在 $x=1,2,3,4$ 处的取值分别为 $1,2,3,114514$。

如何找到这个多项式就是插值要解决的问题。形式化地，多项式插值的一般形式如下：

给你 $n+1$ 个点 $(x_0,y_0),(x_1,y_1),(x_2,y_2),\cdots,(x_n,y_n)$，求多项式 $f(x)=\sum_{i=0}^n a_i x^i$ 满足

$\forall i=[0,n] \cap \mathbb{N}, f(x_i)=y_i$显然我们有一个列出 $n$ 条方程然后高斯消元的 $O(n^3)$ 做法。而下文介绍的插值法其实是一种构造思想，可以在 $O(n^2)$ 的复杂度内解决问题。甚至使用多项式科技可以做到 $O(n \log^2 n)$。

## 24.2 Lagrange 插值法

- 优点：复杂度 $O(n^2)$，可以优化到 $O(n \log^2 n)$。处理横坐标是连续整数的插值时有 $O(n)$ 复杂度。
- 缺点：求多项式的系数比较麻烦。

Lagrange 插值的核心是构造 $n$ 个基函数 $L_i(x)$，使得每个基函数在对应的数据点取值为 $1$，其他点取值为 $0$，于是

$f(x)=\sum_{i=0}^n y_i L_i(x)$考虑如何构造 $L_i(x)$。不妨设 $L_i(x)=\prod_{j \ne i} (x-x_j)$，代入 $(x_i,y_i)$ 解得

$L_i(x)=\prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}$综上得到 Lagrange 插值公式为

$f(x)=\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}$显然是一个 $O(n^2)$ 的过程。下面给出的板子来自 OI-Wiki，可以通过秦九韶算法求出 $f(x)$ 的各项系数。

```cpp
int n;
mint x[N], y[N], f[N], m[N], px[N];
void lagrange_interp() {
	m[0] = 1;
	for (int i = 0; i <= n; i++) {
		for (int j = i; j >= 0; j--) m[j + 1] += m[j], m[j] *= -x[i];
	}
	for (int i = 0; i <= n; i++) {
		px[i] = 1;
		for (int j = 0; j <= n; j++) {
			if (i != j) px[i] *= x[i] - x[j];
		}
	}
	for (int i = 0; i <= n; i++) {
		mint t = y[i] / px[i], k = m[n + 1];
		for (int j = n; j >= 0; j--) f[j] += k * t, k = k * x[i] + m[j];
	}
}
```

这里还有一个讲的很好的[视频](https://www.bilibili.com/video/BV1TR4y1j745/)，从 CRT 的角度来推导 Lagrange 插值。

## *24.3 Newton 插值法

- 优点：支持 $O(n)$ 插入新数据点。
- 缺点：复杂度无法优化，不适合处理横坐标是连续整数的插值。

Newton 插值法基于这样一个事实：$f(x)$ 的 $n$ 阶差分会变成一个常数数列。

我们给出的这 $n$ 个数据点本质上其实描述了一个离散的函数。在离散函数上，仿照连续函数的导数定义其微分：

$f'(x)=\dfrac{f(x+1)-f(x)}{1}$可以发现这就是差分。一般地，Newton 插值公式为

$F_n=\sum_{i} C_n^i \Delta^i F_i$实际上把组合数拆成下降幂，你就得到了离散泰勒展开。

下面给出的板子还是从 OI-Wiki 抄的，能够支持 $O(n)$ 插入新数据点，不过常数比 Lagrange 插值略大。

```cpp
template <class T>
class NewtonInterp {
private:
	vector<pair<T, T>> pos;
	vector<vector<T>> dy;
	vector<T> base;
public:
	vector<T> poly;

	void insert(const T& x, const T& y) {
		pos.emplace_back(x, y);
		int n = pos.size();
		if (n == 1) base.emplace_back(1);
		else {
			int m = base.size();
			base.emplace_back(0);
			for (int i = m; i >= 0; i--) base[i] = i >= 1 ? base[i - 1] : 0;
			for (int i = 0; i < m; i++) base[i] -= pos[n - 2].first * base[i + 1];
		}
		dy.emplace_back(pos.size());
		dy[n - 1][n - 1] = y;
		for (int i = n - 2; i >= 0; i--) dy[n - 1][i] = (dy[n - 2][i] - dy[n - 1][i + 1]) / (pos[i].first - pos[n - 1].first);
		poly.emplace_back(0);
		for (int i = 0; i < n; i++) poly[i] += dy[n - 1][0] * base[i];
	}
};
```

需要注意，本质上 Newton 插值和 Lagrange 插值得到的多项式是一样的，只是构造方法不同。

## 24.4 例题

### CF622F The Sum of the k-th Powers

这个题还有一种做法是使用第二类 Stirling 数的拆幂公式，配合多项式科技解决。下面介绍 Lagrange 插值做法。

设 $f(n)=\sum_{i=1}^n i^k$。观察样例可得 $f(n)$ 是关于 $n$ 的 $k+1$ 次多项式。考虑插值确定这个多项式的系数。我们需要取 $k+2$ 个点才能插值，如果暴力做复杂度为 $O(k^2)$，无法通过。

由于点是任取的，考虑横坐标是连续整数的 Lagrange 插值。写出插值公式

$f(n)=\sum_{i=0}^{k+2} y_i \prod_{j \ne i} \dfrac{n-x_j}{x_i-x_j}$横坐标是连续整数时

$f(n)=\sum_{i=0}^{k+2} y_i \prod_{j \ne i} \dfrac{n-j}{i-j}$记 $p_i=\prod_{j=1}^i (n-j),s_i=\prod_{j=i}^{k+2}(n-j)$，即 $n-j$ 的前、后缀积，代入上式得

$f(n)=\sum_{i=0}^{k+2} (-1)^{k-i+2} y_i \times \dfrac{p_{i-1} s_{i+1}}{(i-1)! (k-i+2)!}$ $y_i$ 可以 $O(k)$ 递推出来，至此可以 $O(k \log k)$ 解决。

```cpp
const int N = 1e6 + 5;
int n, k;
mint a[N], p[N], s[N], fac[N];

void _main() {
	cin >> n >> k;
	fac[0] = 1, p[0] = 1, s[k + 3] = 1;
	for (int i = 1; i <= k + 2; i++) {
		fac[i] = fac[i - 1] * i;
		a[i] = a[i - 1] + mint(i).pow(k);
		p[i] = p[i - 1] * (n - i);
	}
	for (int i = k + 2; i >= 1; i--) s[i] = s[i + 1] * (n - i);
	if (n <= k + 2) return cout << a[n], void();
	mint res = 0;
	for (int i = 1; i <= k + 2; i++) {
		if ((k + 2 - i) & 1) res -= a[i] * p[i - 1] * s[i + 1] / fac[i - 1] / fac[k + 2 - i];
		else res += a[i] * p[i - 1] * s[i + 1] / fac[i - 1] / fac[k + 2 - i];
	} cout << res;
}
```

### *P5437 【XR-2】约定

考虑拆贡献，每条边的出现次数均为

$n^{n-2} \times (n-1) \times \dfrac{n(n-1)}{2}=2n^{n-3}$答案即为

$$
\begin{aligned}
ans&=\dfrac{2n^{n-3} \sum_{i=1}^n \sum _{j=i+1}^n (i+j)^k}{n^{n-2}}\\
&=\dfrac{2}{n} \times \left(\sum_{i=1}^n \sum _{j=i+1}^n (i+j)^k \right) \\
&=\dfrac{2}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - \sum_{i=1}^n (2i)^k \right) \\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - 2^k\sum_{i=1}^n i^k \right)
\end{aligned}
$$

后面那个可以 $O(k)$ 解决。考虑转为枚举每个 $i+j$ 的出现次数：

$$
\begin{aligned}
ans&=\dfrac{1}{n} \times \left(\sum_{i=1}^n \sum _{j=1}^n (i+j)^k - 2^k\sum_{i=1}^n i^k \right)\\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n (i-1)i^k+\sum_{i=n+1}^{2n}(2n+1-i)i^k- 2^k\sum_{i=1}^n i^k \right)\\
&=\dfrac{1}{n} \times \left(\sum_{i=1}^n i^{k+1}-\sum_{i=1}^n i^k+(2n+1) \sum_{i=n+1}^{2n} i^k-\sum_{i=n+1}^{2n} i^{k+1}- 2^k\sum_{i=1}^n i^k \right)
\end{aligned}
$$

至此我们只需知道 $f(n)=\sum_{i=1}^{n} i^k$ 在 $n,2n$ 处的值。用线性筛筛出 $i^k$ 后使用上题的做法可做到 $O(k)$。

### *P8290 [省选联考 2022] 填树

这题真的没黑吗。

先转化一下题意：就是让一条链权值不为 $0$。

考虑朴素 DP。枚举路径最小值 $x$，则每个点的点权区间为 $[x,x+k]$，跑一个树形 DP。注意到必须钦定一个最小值，不然会使得最小值 $>x$。需要一个高维容斥，对于每个 $[x,x+k]$ 都容斥掉 $[x+1,x+k]$ 的答案。

设 $f_{0/1,u}$ 表示 $u$ 子树内部的方案数，$0/1$ 表示是否要求链以 $u$ 为端点。$g_{0/1,u}$ 表示 $u$ 子树内部的权值和，$0/1$ 同理。

设 $u$ 上的合法区间为 $[l',r']$，可得到 $[l',r']=[x,x+k] \cap [l_u,r_u]$，并记 $s=r'-l'+1$。于是有

$f_{1,u}=s+\sum_{(u,v)} f_{1,v} \times s$对于 $g_{1,u}$ 拆开点 $u$ 的贡献和 $v$ 子树的贡献，同时加法原理合并该点开始的贡献。得到

$g_{1,u}=\dfrac{s(s+1)}{2}+s(l'-1)+\sum_{(u,v)} g_{1,v} \times  s+f_{1,u} \times [\dfrac{s(s+1)}{2}+s(l'-1)]$考虑 $f_{0,u}$，可以讲链拆成三段，即左段、当前节点、右段，然后乘法原理合并答案：

$f_{0,u}=s+\sum_{(u,v)} (1+\sum_p f_{1,p}) \times f_{1,v}\times s$对于 $g_{0,u}$，拆贡献得到三部分：$v$ 子树向上的贡献，$u$ 的贡献，$v$ 的历史贡献。加法原理合并答案：

$g_{0,u}=\dfrac{s(s+1)}{2}+s(l'-1)+\sum_{(u,v)} (1+\sum_{p} f_{1,p})[s \times g_{1,v}+(\dfrac{s(s+1)}{2}+s(l'-1)) f_{1,v}]+\sum_{p} g_{1,p} \times f_{1,v}\times s$分别做完这四个转移，复杂度 $O(nV^2)$。注意到 $\sum_p$ 的部分可以前缀和优化，复杂度 $O(nV)$。历尽千辛万苦获得了 20pts。

考虑链的情况，此时 $l',r'$ 为定值，总方案数为

$\prod_{i=1}^n (r'-l'+1)$权值和为

$\sum_{i=1} [\dfrac{w(w+1)}{2}+w(l'-1)] \times \prod_{j\ne i} (r'-l'+1)$设 $x$ 是链内一点。注意到，$l',r'$ 为关于 $x$ 的一次多项式，$\dfrac{w(w+1)}{2}$ 为关于 $x$ 的二次多项式。总方案数、权值和是关于 $x$ 的 $n,n+1$ 次多项式。树可以拆成若干条链得到这个结论。

在每一个分段内，答案都是关于 $x$ 的多项式，答案的总和就是前缀和的末元素。考虑找到 $O(n)$ 个点暴力 DP 再前缀和，直接得到了答案前缀和的若干点值，代入 Lagrange 插值公式，我们惊喜地发现这个方法绕开了值域限制。

总复杂度 $O(n^3)$，需要离散化等，细节较多。代码中的 `discrete_map` 是一个离散化的工具，[源码](https://www.luogu.me/paste/husimzif)。

```cpp
const int N = 205;
int n, k, l[N], r[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
discrete_map<int, N << 2> mp;

mint f[2][N], g[2][N];
void dfs(int u, int fa, int ql, int qr) {
	int l0 = max(ql, l[u]), r0 = min(qr, r[u]);
	if (l0 > r0) l0 = 1, r0 = 0;
	int s = r0 - l0 + 1;
	mint h = 1LL * r0 * (r0 + 1) / 2 - 1LL * l0 * (l0 - 1) / 2;
	f[0][u] = f[1][u] = s, g[0][u] = g[1][u] = h;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u, ql, qr);
		f[0][u] += f[1][u] * f[1][v];
		g[0][u] += g[1][v] * f[1][u] + f[1][v] * g[1][u];
		f[1][u] += f[1][v] * s;
		g[1][u] += g[1][v] * s + f[1][v] * h;
	}
}
void solve(mint w, int ql, int qr, mint& ans1, mint& ans2) {
	dfs(1, -1, ql, qr);
	for (int i = 1; i <= n; i++) ans1 += w * f[0][i], ans2 += w * g[0][i];
}

mint a[N << 2], b[N << 2], c[N << 2];
mint lagrange(int n, mint x0, mint *x, mint *y) {
	mint res = 0;
	for (int i = 0; i < n; i++) {
		mint a = 1, b = 1;
		for (int j = 0; j < n; j++) {
			if (i != j) a *= x0 - x[j], b *= x[i] - x[j];
		} res += a / b * y[i];
	} return res;
}

void _main() {
	cin >> n >> k;
	int v = 0;
	for (int i = 1; i <= n; i++) {
		cin >> l[i] >> r[i], v = max(v, r[i] + 1);
		mp.add(l[i]), mp.add(r[i]), mp.add(max(0, l[i] - k)), mp.add(max(0, r[i] - k));
	}
	mp.add(v), mp();
	for (int i = 1, u, v; i < n; i++) cin >> u >> v, add_edge(u, v), add_edge(v, u);
	mint res1 = 0, res2 = 0;
	for (int i = 1; i < mp.width; i++) {
		int ql = mp.value(i), qr = ql + k, j = 0;
		for (; j <= n + 1; j++, qr++) {
			if (mp.value(i) + j == mp.value(i + 1)) break;
			solve(1, ql, qr, res1, res2), solve(-1, ++ql, qr, res1, res2);
			a[j] = mp.value(i) + j, b[j] = res1, c[j] = res2;
		}
		if (mp.value(i) + j < mp.value(i + 1)) {
			res1 = lagrange(j, mp.value(i + 1) - 1, a, b);
			res2 = lagrange(j, mp.value(i + 1) - 1, a, c);
		}
	} cout << res1 << '\n' << res2;
}
```$AKB305$, '数学', array['插值', 'Lagrange 插值', 'Newton 插值'], 'col-math-oi-foundations', null, 'knowledge'),
('world-needs-sunday', 'col-math-lcm-pair-count', 'LCM数对计数问题', $AKB306$## 算法原理

本算法求解满足 $\text{lcm}(a, b) = n$ 的有序对 $(a, b)$ 的个数。关键观察是：LCM 由各质因子的最大指数决定，因此可以将问题分解到每个质因子维度上独立处理，再利用乘法原理将各维度的方案数相乘。

设 $n$ 的质因数分解为 $n = \prod_{i} p_i^{e_i}$。对于每个质因子 $p_i$，设 $a$ 中 $p_i$ 的指数为 $\alpha_i$，$b$ 中 $p_i$ 的指数为 $\beta_i$，则 $\text{lcm}(a, b)$ 中 $p_i$ 的指数为 $\max(\alpha_i, \beta_i)$。要求 $\max(\alpha_i, \beta_i) = e_i$，即 $\alpha_i$ 和 $\beta_i$ 中至少有一个等于 $e_i$，且两者都不超过 $e_i$。

满足 $\max(\alpha, \beta) = e$ 且 $0 \le \alpha, \beta \le e$ 的有序对 $(\alpha, \beta)$ 共有 $2e + 1$ 种：当 $\alpha = e$ 时 $\beta$ 可取 $0, 1, \ldots, e$ 共 $e+1$ 种；当 $\beta = e$ 且 $\alpha \ne e$ 时 $\alpha$ 可取 $0, 1, \ldots, e-1$ 共 $e$ 种。两者合计 $2e + 1$。由于各质因子维度独立，总方案数为各维度方案数之积 $\prod_{i} (2e_i + 1)$。

算法实现分两步：先用 `init` 对 $n$ 做质因数分解（试除法，$O(\sqrt{n})$），将每个质因子及其指数存入 `AM` 向量；再用 DFS 在质因子维度上枚举每个质因子的指数分配方案。对于每个质因子 $p^e$，DFS 分两段枚举：第一段固定 $a$ 的指数为 $e$，$b$ 的指数取 $0 \sim e$（共 $e+1$ 种）；第二段固定 $b$ 的指数为 $e$，$a$ 的指数取 $0 \sim e-1$（共 $e$ 种，排除 $a = e$ 避免与第一段重复计数）。两段合计恰好 $2e + 1$ 种，与公式吻合。

## 核心公式

$n$ 的质因数分解：
$$n = \prod_{i=1}^{m} p_i^{e_i}$$

LCM 的质因子条件：
$$\max(\alpha_i, \beta_i) = e_i, \quad 0 \le \alpha_i, \beta_i \le e_i$$

单个质因子的合法方案数：
$$|\{(\alpha, \beta) : \max(\alpha, \beta) = e\}| = (e + 1) + e = 2e + 1$$

有序对总数（乘法原理）：
$$\text{ans} = \prod_{i=1}^{m} (2e_i + 1)$$

## 逐行代码解析

### 全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<pair<long long,long long>> AM;   // 存储 (质因子, 指数) 对
long long ans;                          // 全局答案计数
```

- `AM` 存放 `(质因子, 指数)` 对，由 `init` 填充后供 `dfs` 按维度枚举。
- `ans` 为全局计数，`init` 里清零，`dfs` 到达叶子节点时累加。

### init（质因数分解）

```cpp
// 质因数分解：将 n 分解为 AM = {(p1,e1), (p2,e2), ...}
void init(long long n)
{
	ans = 0;
	AM.clear();
	for(long long i = 2; i * i <= n; i++)     // 试除法
	{
		long long cnt = 0;
		while(n % i == 0) { ++cnt; n /= i; }
		if(cnt) AM.emplace_back(i, cnt);
	}
	if(n > 1) AM.emplace_back(n, 1);          // 剩余的大于 1 的因子
}
```

- 试除法遍历 $i$ 从 $2$ 到 $\sqrt{n}$，对每个能整除 $n$ 的 $i$ 统计指数并除掉。
- 循环上界用 `i * i <= n`，等价于 $i \le \sqrt{n}$；若循环结束后 $n > 1$，说明剩余部分是一个大于 $\sqrt{n}$ 的质因子（指数为 $1$），单独加入。
- `ans = 0` 与 `AM.clear()` 保证每组测试数据独立，避免上一组的残留。

### dfs（递归枚举指数分配）

```cpp
// DFS 枚举每个质因子的指数分配
void dfs(long long idx, long long a, long long b)
{
	if(idx == AM.size())                      // 所有质因子已分配完毕
	{
		cout << a << " " << b << '\n';        // 输出合法对
		++ans;
		return;
	}
	// 预处理 p^0, p^1, ..., p^e
	vector<long long> tmp(AM[idx].second + 1);
	tmp[0] = 1;
	for(long long i = 1; i <= AM[idx].second; i++)
		tmp[i] = tmp[i - 1] * AM[idx].first;

	// 第一段：a 的指数固定为 e，b 的指数取 0~e（共 e+1 种）
	for(long long i = 0; i <= AM[idx].second; i++)
		dfs(idx + 1, a * tmp[AM[idx].second], b * tmp[i]);

	// 第二段：b 的指数固定为 e，a 的指数取 0~e-1（共 e 种，排除 a=e 避免重复）
	for(long long i = 0; i < AM[idx].second; i++)
		dfs(idx + 1, a * tmp[i], b * tmp[AM[idx].second]);
}
```

- 递归出口 `idx == AM.size()` 表示所有质因子已分配完毕，此时 `a`、`b` 为完整的合法有序对，输出并 `++ans`。
- `tmp[i] = tmp[i-1] * AM[idx].first`：预计算 $p^0, p^1, \ldots, p^e$，避免在 DFS 中重复计算幂值。
- 第一段 `for(i=0; i<=e; i++)`：固定 $a$ 的指数为 $e$，$b$ 的指数取 $0 \sim e$，覆盖所有 $\alpha = e$ 的情形。
- 第二段 `for(i=0; i<e; i++)`：固定 $b$ 的指数为 $e$，$a$ 的指数取 $0 \sim e-1$，上界为 $e-1$ 排除了 $\alpha = e$（已在第一段计数），避免 $(e, e)$ 重复。
- `a` 和 `b` 在递归过程中累积各质因子的贡献，到达叶子节点时即为完整的 $(a, b)$ 值。

### main（读入与输出）

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int t;
	cin >> t;
	for(int i = 1; i <= t; i++)
	{
		long long n;
		cin >> n;
		init(n);
		dfs(0, 1, 1);
		cout << "Case " << i << ": " << ans << '\n';
	}
	return 0;
}
```

- `ios::sync_with_stdio(false)` 取消 C/C++ 流同步，`cin.tie(nullptr)` 解绑输入输出，加速大量 `cout` 输出。
- 每组数据先读入 `n`，调用 `init(n)` 分解，再 `dfs(0, 1, 1)` 从 $a = b = 1$ 开始枚举。
- 输出格式为 `Case i: ans`，`i` 从 `1` 到 `t`。

## 复杂度分析

质因数分解 `init` 使用试除法，时间复杂度为 $O(\sqrt{n})$。DFS 枚举的总方案数为 $\prod_{i} (2e_i + 1)$，每个质因子贡献 $2e_i + 1$ 种选择。由于 $\prod (2e_i + 1) \le \prod (2e_i + 1) \le d(n)^2$（$d(n)$ 为约数个数），且 $d(n) = O(n^\epsilon)$（对任意 $\epsilon > 0$），实际方案数通常远小于 $n$。空间上 `AM` 存储质因子对，个数为 $O(\log n / \log \log n)$（质因子数的上界），DFS 递归深度等于质因子个数，总空间复杂度为 $O(\text{质因子数})$。

## 适用场景

数论计数问题、约数与 LCM/GCD 组合计数、需要枚举所有满足特定 LCM 或 GCD 条件的数对的场景。这类问题在竞赛数论中较为常见，核心是将多元条件分解到各质因子维度独立处理。

## 常见陷阱与注意事项

1. **重复计数**：$(e, e)$ 即 $\alpha = \beta = e$ 同时满足"$\alpha = e$"和"$\beta = e$"两个条件。若两段枚举的上界都设为 $e$，则该情况被计数两次。第二段上界设为 $e - 1$ 是避免重复的关键。
2. **有序对 vs 无序对**：本代码求解有序对 $(a, b)$，即 $(a, b)$ 与 $(b, a)$ 视为不同。若题目要求无序对，需对 $a \ne b$ 的情况除以 $2$，再加回 $a = b$ 的 $1$ 种。
3. **$n = 1$ 的退化**：当 $n = 1$ 时质因数分解为空，`AM.size() = 0`，DFS 直接到达叶子节点输出 $(1, 1)$，答案为 $1$（因为 $\text{lcm}(1,1) = 1$）。
4. **溢出**：`a` 和 `b` 在 DFS 中累积乘积可能超过 `long long` 范围。若题目保证 $a, b \le n$ 则不会溢出（因为 $a, b$ 均为 $n$ 的约数），但若 $n$ 接近 `long long` 上界仍需注意。
5. **大数质因数分解**：试除法为 $O(\sqrt{n})$，当 $n$ 达到 $10^{14}$ 以上时需考虑 Pollard-Rho 等更快的分解算法。
6. **输出量过大**：代码在 DFS 叶子节点输出每个合法对 $(a, b)$，当方案数极大时输出会成为瓶颈，实际使用中可去掉输出仅计数。

## 对比与扩展

与直接枚举所有约数对再验证 LCM 的 $O(d(n)^2)$ 做法相比，本算法利用质因子维度的独立性将复杂度降至 $O(\prod(2e_i+1))$，通常远小于 $d(n)^2$。类似思路可推广到 GCD 计数（$\min(\alpha, \beta) = e_i$ 的方案数为 $(2e_i + 1)$ 但分配方式不同）、以及同时约束 LCM 和 GCD 的计数问题。扩展方向包括：利用莫比乌斯反演处理 $\sum \text{lcm}$ 类求和问题、结合容斥原理处理多约束计数、以及推广到多元组 $(a_1, a_2, \ldots, a_k)$ 的 LCM 计数。$AKB306$, '数学', array['数学', '数论', 'LCM', '计数', '质因数分解', 'DFS'], null, null, 'knowledge'),
('Fohen', 'col-math-linear-algebra--fenfeng', '线性代数 · Fohen', $AKB307$## 算法原理

线性代数研究的是**多个未知数、多个方程（多种量）如何被系统化、批量处理**。它的动机很朴素：当未知数和方程只有两三个时，代入消元、画图找交点这类手工方法完全够用；一旦规模扩大到几十上百个未知数、几十上百个方程，手工方法当场失效，就需要一套**机械、可重复、能写进程序**的统一工具，这就是线性代数。

线性代数的两个核心对象是**向量**和**矩阵**：

- **向量**：具有**大小**和**方向**两个独立属性的代数对象，可以看成「一组有序数」的打包。
- **矩阵**：由 $m \times n$ 个数排成的矩形数表。本质上它是「把一堆数整整齐齐地码在一起，然后批量处理」——如果说数组是「一堆数的打包」，矩阵就是「一堆数组的打包」。

以二元一次方程组为例：

$$
\begin{cases}
x + 2y = 10 \\
2x + y = 8
\end{cases}
$$

把系数「打包」成矩阵、未知数打包成向量后，方程组统一写成：

$$
\begin{pmatrix} 1 & 2 \\ 2 & 1 \end{pmatrix}
\begin{pmatrix} x \\ y \end{pmatrix}
=
\begin{pmatrix} 10 \\ 8 \end{pmatrix}
$$

左边是系数矩阵，中间是未知数向量，右边是常数向量。一旦写成矩阵形式，解方程就统一成「对矩阵做若干次合法行变换」，于是可以机械地消元、回代——这正是高斯消元的思想来源。

在 OI 中线性代数是一把实打实的工具，集中体现在：

- **矩阵快速幂**：把线性递推写成矩阵乘法，用快速幂在 $O(\log n)$ 次「矩阵乘法」内求出第 $n$ 项，递推式再长也不怕。
- **高斯消元**：解 $n$ 元一次方程组，或求异或方程组的解。
- **线性基**：求一堆数能异或出的最大值、第 $k$ 大，是线性代数中「线性空间」在异或运算上的具体体现。
- **行列式与矩阵树定理**：数生成树的个数，转化为求一个行列式。

一句话总结：**线性代数就是「把一堆数打包，然后批量变换」的学问。**

## 核心公式 / 状态定义与转移方程

线性代数没有单一的状态转移方程（那是动态规划的特征），它的「核心公式」是一套**向量与矩阵的定义与运算规则**。

### 向量

向量是同时具有**大小**和**方向**的代数对象，数学中一般研究**自由向量**——只由大小和方向决定，与起点位置无关。用**有向线段** $\overrightarrow{AB}$ 表示时，$A$ 为起点、$B$ 为终点。

基本概念：

- **模**：有向线段 $\overrightarrow{AB}$ 的长度，记作 $|\overrightarrow{AB}|$ 或 $|\vec{a}|$，是一个非负实数，刻画向量的大小。
- **零向量**：模为 $0$ 的向量，记作 $\vec{0}$，方向未定义（或视为任意）。
- **单位向量**：模为 $1$ 的向量，记作 $\vec{e}$；任意非零向量 $\vec{a}$ 的**归一化**结果 $\frac{\vec{a}}{|\vec{a}|}$ 是与 $\vec{a}$ 同方向的单位向量。
- **平行向量（共线向量）**：方向相同或相反的两个非零向量，记作 $\vec{a} \parallel \vec{b}$；自由向量可平移，故平行向量总能平移到同一直线上。
- **相等向量 / 相反向量**：模相等且方向相同则相等（记 $\vec{a} = \vec{b}$）；模相等且方向相反则互为相反向量，$-\vec{a}$ 满足 $\vec{a} + (-\vec{a}) = \vec{0}$。
- **夹角**：两非零向量 $\vec{a}, \vec{b}$ 的夹角 $\theta$ 规定在 $[0, \pi]$ 内；$\theta = 0$ 同向、$\theta = \pi$ 反向、$\theta = \frac{\pi}{2}$ 垂直（记 $\vec{a} \perp \vec{b}$）。
- **不能比较大小**：向量带方向，只有模可以比较，向量本身只讨论相等性，不存在序关系。

线性运算：

- **加法**：三角形法则——首尾相接的 $\vec{a} = \overrightarrow{AB}$、$\vec{b} = \overrightarrow{BC}$ 之和为 $\vec{a} + \vec{b} = \overrightarrow{AC}$；等价地有平行四边形法则。加法满足交换律与结合律：

$$
\vec{a} + \vec{b} = \vec{b} + \vec{a}, \qquad (\vec{a} + \vec{b}) + \vec{c} = \vec{a} + (\vec{b} + \vec{c})
$$

- **减法**：$\vec{a} - \vec{b} = \vec{a} + (-\vec{b})$；几何上，共起点的 $\vec{a}, \vec{b}$ 相减，结果是由 $\vec{b}$ 终点指向 $\vec{a}$ 终点的有向线段，且 $\overrightarrow{AB} = \overrightarrow{OB} - \overrightarrow{OA}$。
- **数乘**：实数 $\lambda$ 与向量 $\vec{a}$ 的数乘满足 $|\lambda \vec{a}| = |\lambda| \, |\vec{a}|$；当 $\lambda > 0$ 时同向、$\lambda < 0$ 时反向、$\lambda = 0$ 时为零向量。满足结合律与分配律：

$$
\lambda(\mu \vec{a}) = (\lambda\mu)\vec{a}, \qquad (\lambda + \mu)\vec{a} = \lambda\vec{a} + \mu\vec{a}, \qquad \lambda(\vec{a} + \vec{b}) = \lambda\vec{a} + \lambda\vec{b}
$$

### 矩阵

**定义**：矩阵是由 $m \times n$ 个数排成的 $m$ 行 $n$ 列矩形数表，记为

$$
A = \begin{bmatrix}
a_{11} & a_{12} & \cdots & a_{1n} \\
a_{21} & a_{22} & \cdots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \cdots & a_{mn}
\end{bmatrix}
$$

其中 $a_{ij}$ 是第 $i$ 行第 $j$ 列的元素。向量是矩阵的特殊情形：列向量是 $n \times 1$ 矩阵，行向量是 $1 \times n$ 矩阵。

基本概念：

- **同型矩阵**：行数、列数分别对应相同的两个矩阵。
- **方阵**：行数等于列数的矩阵，$n$ 阶方阵即 $n \times n$ 矩阵；OI 中的很多定义与应用都基于方阵。
- **主对角线**：方阵从左上到右下的对角线，由满足 $i = j$ 的元素 $a_{11}, a_{22}, \dots, a_{nn}$ 构成。
- **对称矩阵**：满足 $a_{ij} = a_{ji}$ 的方阵，元素关于主对角线对称。
- **对角矩阵**：主对角线外元素全为 $0$ 的方阵，记作 $\mathrm{diag}\{\lambda_1, \lambda_2, \dots, \lambda_n\}$。
- **单位矩阵**：主对角线元素全为 $1$ 的对角矩阵，记作 $I$ 或 $I_n$。
- **三角矩阵**：主对角线左下方全为 $0$ 的是上三角矩阵，右上方全为 $0$ 的是下三角矩阵。

基本运算：

- **转置**：行列互换，第 $i$ 行变第 $i$ 列，记作 $A^T$。例：

$$
\begin{bmatrix} 1 & 2 & 3 \\ 4 & 5 & 6 \end{bmatrix}^T
=
\begin{bmatrix} 1 & 4 \\ 2 & 5 \\ 3 & 6 \end{bmatrix}
$$

- **加法**：同型矩阵对应元素相加。
- **乘法**：设 $C = A \times B$，则 $c_{ij} = \sum_k a_{ik} b_{kj}$；要求 $A$ 的列数等于 $B$ 的行数，即 $A_{m \times n} \cdot B_{n \times p} = C_{m \times p}$。矩阵乘法**满足结合律、不满足交换律**。
- **行列式**：仅对方阵定义，记作 $\det(A)$ 或 $|A|$；二阶行列式为 $ad - bc$：

$$
\begin{vmatrix} a & b \\ c & d \end{vmatrix} = ad - bc
$$

- **逆矩阵**：方阵 $A$ 可逆时满足 $A A^{-1} = A^{-1} A = I$；二阶方阵的逆为

$$
A^{-1} = \frac{1}{ad-bc}\begin{bmatrix} d & -b \\ -c & a \end{bmatrix}
$$

可见方阵可逆当且仅当其行列式 $ad - bc \neq 0$。

### 初等变换

初等变换包含三种操作，每种操作都对应一个「对单位矩阵 $I$ 做一次该变换」得到的**初等矩阵**：

1. **倍乘矩阵** $D_i(k)$：把单位矩阵第 $i$ 个对角元换成 $k$（$k \neq 0$），行变换效果是「第 $i$ 行乘以 $k$」，常用于归一化或提取公因子。
2. **对换矩阵** $P_{ij}$：交换单位矩阵第 $i$、$j$ 两行，行变换效果是「交换第 $i$、$j$ 两行」，用于消元时选取主元。
3. **倍加矩阵** $T_{ij}(k)$：把单位矩阵第 $j$ 行的 $k$ 倍加到第 $i$ 行，行变换效果是「第 $j$ 行乘以 $k$ 加到第 $i$ 行」，是消元法的核心操作。

对矩阵 $A$ **左乘**初等矩阵等价于做一次**初等行变换**，**右乘**等价于做一次**初等列变换**。三种初等矩阵均可逆，且逆矩阵仍是同类型初等矩阵：

| 初等矩阵 | 逆矩阵 |
| :--- | :--- |
| $D_i(k)$ | $D_i(1/k)$ |
| $P_{ij}$ | $P_{ij}$ |
| $T_{ij}(k)$ | $T_{ij}(-k)$ |

它们的行列式分别为 $|D_i(k)| = k$、$|P_{ij}| = -1$、$|T_{ij}(k)| = 1$，这一性质在「用初等变换计算行列式」时非常有用。

初等变换的典型应用：

1. **求解线性方程组（消元法）**：把系数矩阵与常数项拼成增广矩阵，用初等行变换化为行最简形，直接读出解（见「逐行代码解析」的高斯消元）。
2. **求逆矩阵（Gauss–Jordan 法）**：把 $A$ 与 $I$ 并排成 $[A \mid I]$，只用初等行变换把左边 $A$ 化为 $I$，右边就自动变成 $A^{-1}$。
3. **化标准形**：通过初等变换把任意矩阵化为「左上角单位矩阵 $I_r$、其余为 $0$」的标准形，可用于判断矩阵的秩。

### 矩阵快速幂与线性递推

矩阵乘法满足结合律，因此可以把普通快速幂的「底数换成矩阵、乘法换成矩阵乘法」，得到**矩阵快速幂**，把求幂的 $O(n)$ 次乘法降为 $O(\log n)$ 次。注意：只有方阵才有「幂」的说法，所以矩阵快速幂只对方阵使用。

最经典的用途是**加速线性递推**。对 $k$ 阶线性递推

$$
f_n = c_1 f_{n-1} + c_2 f_{n-2} + \cdots + c_k f_{n-k}
$$

定义状态向量（列向量）

$$
X_n = \begin{bmatrix} f_{n-1} \\ f_{n-2} \\ \vdots \\ f_{n-k} \end{bmatrix}
$$

则存在转移矩阵

$$
M = \begin{bmatrix}
c_1 & c_2 & \cdots & c_{k-1} & c_k \\
1 & 0 & \cdots & 0 & 0 \\
0 & 1 & \cdots & 0 & 0 \\
\vdots & \vdots & \ddots & \vdots & \vdots \\
0 & 0 & \cdots & 1 & 0
\end{bmatrix}
$$

使得 $X_n = M \cdot X_{n-1}$，从而 $X_n = M^{\,n-k} \cdot X_k$，只需用矩阵快速幂求 $M^{\,n-k}$，复杂度 $O(k^3 \log n)$。

以斐波那契数列 $f_n = f_{n-1} + f_{n-2}$（初值 $f_1 = f_2 = 1$）为例，取 $X_n = \begin{bmatrix} f_n \\ f_{n-1} \end{bmatrix}$，则

$$
X_n = \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix} \cdot X_{n-1}
\implies
\begin{bmatrix} f_n \\ f_{n-1} \end{bmatrix}
=
\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}^{n-2}
\begin{bmatrix} f_2 \\ f_1 \end{bmatrix}
$$

> 上述转移矩阵都是按「左乘」情况构造的；矩阵乘法不满足交换律，使用中一定不能弄混左右顺序。

## 逐行代码解析

本知识点是概念型内容（无独立实现），以下给出三个核心操作的**伪代码 / 思想步骤**。

### 矩阵乘法

```cpp
// 矩阵乘法：A(m×p) × B(p×n) → C(m×n)
for (int i = 0; i < m; i++) {
    for (int k = 0; k < p; k++) {
        if (A[i][k] == 0) continue;          // 稀疏优化：跳过 0，减少无效累加
        for (int j = 0; j < n; j++) {
            C[i][j] += A[i][k] * B[k][j];    // C[i][j] = Σ_k A[i][k]·B[k][j]
        }
    }
}
```

- 循环次序 `i-k-j`：把「对 $k$ 求和」放在中间层，是为了在 $A[i][k] = 0$ 时直接跳过，对稀疏矩阵更友好；朴素写法 `i-j-k` 亦可。
- 边界：$A$ 的列数必须等于 $B$ 的行数，结果矩阵尺寸为 $m \times n$。

### 矩阵快速幂

```cpp
// 矩阵快速幂：求 A^n（A 为方阵）
Mat res = 单位矩阵 I;                 // res 初始为单位矩阵
while (n > 0) {
    if (n & 1) res = res * A;         // 指数二进制最低位为 1，则乘入答案
    A = A * A;                        // 底数自乘
    n >>= 1;                          // 指数右移一位
}
return res;
```

- `res` 初始化为**单位矩阵**：任何矩阵与相应大小的单位矩阵相乘仍是自身，这是「乘法的幺元」。
- 只有**方阵**才能做幂运算，因此这里要求 $A$ 为方阵。

### 高斯消元（解线性方程组）

```cpp
// 高斯消元（伪代码）：把增广矩阵化为上三角，再回代
for (int i = 1; i <= n; i++) {                 // 逐列处理
    在第 i..n 行中找第 i 列系数非 0 的行作为主元;
    if (找不到) return "无唯一解";
    把该行交换到第 i 行;                        // 选主元
    for (int j = i + 1; j <= n; j++)            // 用第 i 行消掉下方各行第 i 列
        第 j 行 -= (第 j 行第 i 列 / 第 i 行第 i 列) * 第 i 行;
}
// 此时矩阵为上三角，从最后一行向上回代
for (int i = n; i >= 1; i--)
    由第 i 行解出 x[i]（代入已求出的 x[i+1..n]）;
```

- **选主元**：若当前列主元为 $0$，需要与下方非 $0$ 的行交换；找不到非 $0$ 主元说明无唯一解（可能无解或无穷多解）。
- **回代**：上三角矩阵的最后一行只有一个未知数，先解出，再逐层代入上一行。

## 复杂度分析

线性代数没有统一复杂度，取决于具体操作：

| 操作 / 算法 | 时间复杂度 | 说明 |
| :--- | :--- | :--- |
| 矩阵加法、转置 | $O(nm)$ | 逐元素处理 |
| 矩阵乘法 | $O(mnp)$ | $A_{m \times n} \cdot B_{n \times p}$，三重循环 |
| 矩阵快速幂（加速 $k$ 阶递推） | $O(k^3 \log n)$ | $\log n$ 次矩阵乘法，每次 $O(k^3)$ |
| 高斯消元（$n$ 元方程组） | $O(n^3)$ | $n$ 列消元，每列 $O(n^2)$ |
| 求行列式（消元法） | $O(n^3)$ | 与高斯消元同阶 |

空间复杂度也视具体实现而定：矩阵乘法需存 $A, B, C$，共 $O(mn + np + mp)$；矩阵快速幂需 $O(k^2)$ 存转移矩阵与结果矩阵；高斯消元需 $O(n^2)$ 存增广矩阵。

## 适用场景

- **线性递推加速**：斐波那契、$k$ 阶常系数线性递推，$n$ 可达 $10^{18}$ 规模时用矩阵快速幂求第 $n$ 项。
- **解线性方程组 / 异或方程组**：$n$ 元一次方程组、开关灯问题（异或方程组）用高斯消元。
- **矩阵运算类问题**：图上路径计数（邻接矩阵的 $k$ 次幂对应长度为 $k$ 的路径数）、矩阵树定理数生成树。
- **线性基**：求一堆数能异或出的最大值、第 $k$ 大、判断能否异或出某个值。
- **不适合**：递推式含非线性项（如 $f_n = f_{n-1}^2$）；或矩阵维度过大，使 $O(k^3 \log n)$ 也过不去时，需要结合特征多项式（Cayley–Hamilton）等更高级手段降维。

## 常见陷阱与注意事项

1. **矩阵乘法不满足交换律**：$AB \neq BA$，顺序不能乱；用转移矩阵加速递推时左乘、右乘的构造方式不同，一旦混用就会全错。
2. **乘法要求维度匹配**：$A$ 的列数必须等于 $B$ 的行数，否则无定义；转置后要重新核对行、列数。
3. **只有方阵才有幂与行列式**：矩阵快速幂、行列式、逆矩阵（可逆前提）都只对方阵成立。
4. **主元为 $0$ 必须换行**：高斯消元中当前列主元为 $0$ 时，要与下方非 $0$ 行交换；找不到非 $0$ 主元说明无唯一解，不能直接除。
5. **浮点精度判 $0$**：高斯消元判断「是否为 $0$」不要写 `x == 0`，而要用极小量 `EPS`（如 $10^{-8}$）配合 `fabs(x) < EPS`，避免浮点误差导致误判。
6. **逆矩阵要求行列式非零**：二阶逆矩阵公式的分母 $ad - bc$ 为 $0$ 时矩阵不可逆。
7. **数乘与零向量**：$\lambda = 0$ 时 $\lambda \vec{a} = \vec{0}$；向量不能比较大小，只能用模比较。
8. **单位矩阵作幺元**：矩阵快速幂的 `res` 必须初始化为单位矩阵，不能初始化为全 $0$ 或全 $1$。

## 对比与扩展

| 方法 | 解决的问题 | 复杂度 |
| :--- | :--- | :--- |
| 代入 / 加减消元（手工） | 方程数很少的方程组 | 难以量化 |
| 高斯消元 | $n$ 元一次方程组、异或方程组 | $O(n^3)$ |
| 矩阵快速幂 | $k$ 阶线性递推求第 $n$ 项 | $O(k^3 \log n)$ |
| 普通递推 | 同上，逐项推到第 $n$ 项 | $O(k n)$ |
| 特征多项式（Cayley–Hamilton） | 高维矩阵快速幂降维 | 约 $O(k^2 \log n)$ |

延伸方向：

- **线性基**：把「异或」看作向量加法，在 $0/1$ 向量空间里求极大线性无关组，是线性代数「线性空间」思想的直接应用，能求异或最大值、第 $k$ 大。
- **矩阵树定理**：无向图生成树个数等于其拉普拉斯矩阵任意余子式的行列式，把「数生成树」转化为「求行列式」。
- **线性映射与线性空间**：向量空间、基、维数、线性变换等概念构成线性代数的理论骨架，也是理解线性基、矩阵秩等概念的进阶入口。
- **非齐次项与多维递推**：矩阵快速幂还能推广到带常数项的非齐次递推与多维递推，遇到相关问题时再展开。$AKB307$, '数学', array['数学', '线性代数', '矩阵', '高斯消元', '矩阵快速幂'], null, null, 'knowledge'),
('stripe-python', 'col-math-linear-algebra--stripe-python', '线性代数（向量 / 线性变换 / 广义矩阵乘法） · stripe-python', $AKB308$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

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
```$AKB308$, '数学', array['线性代数', '向量', '线性变换', '矩阵乘法'], null, null, 'knowledge'),
('Xesir', 'col-math-linear-algebra--xesir', '线性代数 · 引入与向量 · Xesir', $AKB309$## 算法原理

~~RedStone 为本栏目编辑做出极小贡献，GOC 感谢您的趋势与拖更~~

> ***引入***
> 先来道开胃小菜——

假设你在玩一个游戏，有两种道具，它们的合成公式如下：

- 1 个铁矿石 + 2 个木材 → 3 个工具
- 2 个铁矿石 + 1 个木材 → 4 个武器

**给你 10 个铁矿石和 8 个木材，最多能合成多少个工具和武器？**

你可能会设 $x$ 个工具、$y$ 个武器，然后列方程组：

$$
\begin{cases}
x + 2y \le 10 \\
2x + y \le 8
\end{cases}
$$

然后画个图、找个交点，算出来 $(x, y) = (2, 4)$，总共 6 件。

看起来挺简单的是吧？那如果道具种类变成 10 种、原料变成 20 种呢？你的「画图法」当场退役 ~~AFO~~。这时候就需要一个能**系统化处理多个未知数、多个方程**的工具。

**线性代数**，就是干这个的。

---

上面那个方程组，我们可以把系数「打包」成一个**矩形数表**：

$$
\begin{cases}
x + 2y = 10 \\
2x + y = 8
\end{cases}
\quad \longrightarrow \quad
\begin{pmatrix}
1 & 2 \\
2 & 1
\end{pmatrix}
\begin{pmatrix}
x \\ y
\end{pmatrix}
=
\begin{pmatrix}
10 \\ 8
\end{pmatrix}
$$

左边那个 $2\times 2$ 的方阵就是**矩阵**，右边那个 $(x,y)$ 就是**向量**。

你会发现，**矩阵本质上就是把一堆数整整齐齐地码在一起，然后批量处理**。就像数组是「一堆数的打包」，矩阵就是「一堆数组的打包」。

---

别以为线性代数只是数学课上的抽象概念，它在 OI 里可是实打实的**杀器**：

- **矩阵快速幂**：斐波那契数列 $F_n = F_{n-1} + F_{n-2}$ 能写成矩阵形式，然后用快速幂 $O(\log n)$ 求出第 $n$ 项。递推式再长都不怕。
- **高斯消元**：解 $n$ 元一次方程组，或者求异或方程组的解。
- **线性基**：求一堆数能异或出的最大值、第 $k$ 大，是线性代数的**线性空间**在异或运算上的具体体现。
- **行列式与矩阵树定理**：数生成树的个数，直接算个行列式完事。

所以**线性代数就是「把一堆数打包，然后批量变换」的学问。**

听起来是不是比「行列式」「特征向量」这些词亲切多了？~~那就对了，因为我也不懂那些高深的（逃）~~

这一篇是总纲 + 向量部分；矩阵、矩阵快速幂、初等变换见[矩阵与矩阵快速幂](?id=math-matrix-multiplication)，解方程见[高斯消元](?id=math-gauss-elimination)。

## 核心公式 / 状态定义与转移方程

### 向量是什么

向量是具有**大小**和**方向**两个独立属性的代数对象。数学中一般研究**自由向量**，即仅由大小和方向决定、与起点位置无关，记作 $\vec{a}$ 或 $\boldsymbol{a}$。

**有向线段**是向量的几何实现：一条有向线段由**起点、方向、长度**三要素确定，给定起点后终点随之唯一确定。向量常用 $\overrightarrow{AB}$ 表示，此时起点为 $A$、终点为 $B$。

- **模**：有向线段 $\overrightarrow{AB}$ 的长度，记作 $\lvert\overrightarrow{AB}\rvert$ 或 $\lvert\vec{a}\rvert$，是非负实数，刻划向量的大小。
- **零向量**：模为 $0$ 的向量，记作 $\vec{0}$。方向未定义（或视为任意），坐标意义下各分量均为 $0$。
- **单位向量**：模为 $1$ 的向量，记作 $\vec{e}$。任意非零向量 $\vec{a}$ 的 $\frac{\vec{a}}{\lvert\vec{a}\rvert}$ 是与它同方向的单位向量，称为**归一化**。
- **平行向量**：两个非零向量方向相同或相反，记作 $\vec{a}\parallel\vec{b}$。自由向量可任意平移，故任意一组平行向量都能平移到同一条直线上，所以又叫**共线向量**。
- **相等向量**：模相等且方向相同，记作 $\vec{a}=\vec{b}$；自由向量意义下视为同一向量。
- **相反向量**：模相等且方向相反，$\vec{a}$ 的相反向量记作 $-\vec{a}$，满足 $\vec{a}+(-\vec{a})=\vec{0}$。
- **夹角**：任取点 $O$，作 $\overrightarrow{OA}=\vec{a}$、$\overrightarrow{OB}=\vec{b}$，则 $\angle AOB$ 称为 $\vec{a}$ 与 $\vec{b}$ 的夹角，记作 $\langle\vec{a},\vec{b}\rangle$，取值范围 $[0,\pi]$。

**关于比较**：向量带方向，模可以比较，但向量本身不能比较大小。两个向量之间只讨论相等性，不存在序关系。

### 向量的线性运算

**加法**（三角形法则）：首尾相接的 $\vec{a}=\overrightarrow{AB}$、$\vec{b}=\overrightarrow{BC}$，其和定义为 $\vec{a}+\vec{b}=\overrightarrow{AC}$。

等价定义（平行四边形法则）：以共起点的两个向量为邻边作平行四边形，从公共起点出发的对角线即为它们的和。

运算律：

$$
\vec{a}+\vec{b}=\vec{b}+\vec{a},\qquad (\vec{a}+\vec{b})+\vec{c}=\vec{a}+(\vec{b}+\vec{c})
$$

**减法**：$\vec{a}-\vec{b}=\vec{a}+(-\vec{b})$。几何上，对共起点的 $\vec{a},\vec{b}$，$\vec{a}-\vec{b}$ 是由 $\vec{b}$ 的终点指向 $\vec{a}$ 的终点的有向线段。由定义得 $\overrightarrow{AB}=\overrightarrow{OB}-\overrightarrow{OA}$。

**数乘**：设 $\lambda$ 为实数，$\lambda\vec{a}$ 满足

$$
\lvert\lambda\vec{a}\rvert=\lvert\lambda\rvert\,\lvert\vec{a}\rvert
$$

且 $\lambda>0$ 时与 $\vec{a}$ 同向、$\lambda<0$ 时反向、$\lambda=0$ 时为零向量。运算律：

$$
\lambda(\mu\vec{a})=(\lambda\mu)\vec{a},\qquad (\lambda+\mu)\vec{a}=\lambda\vec{a}+\mu\vec{a},\qquad \lambda(\vec{a}+\vec{b})=\lambda\vec{a}+\lambda\vec{b}
$$

> **原文此处留白**：小标题「内积」「外积」下面没有内容 ~~理论存在，画饼开始~~。本页不做补充，等原文补完再同步。

## 逐行代码解析

原文这一节没有配套程序（向量部分全是概念），下面只是把向量的定义和线性运算写成代码的示意片段，用来对照公式，不是完整程序。

### 模块一：向量本体 + 加法 / 减法 / 数乘

```cpp
struct Vec { double x, y; };                                       // 平面向量：大小由 (x,y) 决定
Vec operator+(const Vec& a, const Vec& b) { return {a.x + b.x, a.y + b.y}; }  // 三角形法则的坐标版
Vec operator-(const Vec& a, const Vec& b) { return {a.x - b.x, a.y - b.y}; }  // 共起点相减，指向被减向量终点
Vec operator*(double k, const Vec& a)     { return {k * a.x, k * a.y}; }      // 数乘：方向由 k 的符号决定
```

- 自由向量的「与起点无关」直接体现在结构体里只有两个分量，没有起点字段。
- 加法的坐标写法就是把两个方向上的贡献分别相加，正好对应三角形法则。
- 数乘只缩放长度，$k<0$ 时方向翻转 $180^\circ$。

### 模块二：模与归一化

```cpp
double norm(const Vec& a) { return sqrt(a.x * a.x + a.y * a.y); }        // 模 |a|
Vec unit(const Vec& a) {                                                 // 归一化：同方向的单位向量
    double L = norm(a);
    return {a.x / L, a.y / L};                                           // 零向量会除 0，调用前自己判
}
```

- 模是勾股定理的直接翻译，非负实数，所以「向量能比大小」这个错觉只对模成立。
- 归一化要求 $\vec{a}\ne\vec{0}$；零向量的方向未定义，除零会得到 `nan`。

### 模块三：一次线性变换的写法（通向矩阵）

```cpp
// 方阵左乘列向量：y = A x，这就是「线性变换」在坐标下的全部内容
for (int i = 0; i < n; i++) {
    y[i] = 0;
    for (int j = 0; j < n; j++) y[i] += A[i][j] * x[j];   // 第 i 个输出 = A 第 i 行与 x 的点积
}
```

- 每一行系数对旧坐标做一次**线性组合**，所以矩阵天然就是「批量线性变换」的载体。
- 这也解释了为什么矩阵乘法不交换：先做变换 $A$ 再做 $B$，和先 $B$ 后 $A$ 通常不是一回事。

## 复杂度分析

本页是总纲与概念，没有具体算法，复杂度只能按操作拆开说：

| 操作 | 时间 | 空间 |
|---|---|---|
| 向量加 / 减 / 数乘（$n$ 维） | $O(n)$ | $O(n)$ |
| 求模 / 归一化（$n$ 维） | $O(n)$ | $O(1)$ |
| 方阵乘向量 | $O(n^2)$ | $O(n)$ |
| 矩阵快速幂加速 $k$ 阶递推 | $O(k^3\log n)$ | $O(k^2)$ |
| 高斯消元解 $n$ 元方程组 | $O(n^3)$ | $O(n^2)$ |

frontmatter 记「视具体实现」，因为这一条本身是概念总纲，具体数字取决于你接下来用哪种运算。

## 适用场景

- **计算几何**：点、线、多边形、距离、面积，全部用向量表示；叉积判方向、点积判夹角。
- **线性递推加速**：把转移写成矩阵，用矩阵快速幂把 $O(n)$ 压到 $O(k^3\log n)$。
- **解线性方程组 / 异或方程组**：高斯消元的主场。
- **线性基**：异或空间里的极大线性无关组，求异或最大值、第 $k$ 大。
- **行列式与矩阵树定理**：数生成树个数。
- **不适合**：方程组里有非线性项（乘积、指数、$\max/\min$）时，矩阵这套语言直接失效，得换方法。

## 常见陷阱与注意事项

1. **向量不能比大小**。只有模可以比较，$\vec{a}<\vec{b}$ 是没有定义的写法。
2. **自由向量可平移**。相等只看大小与方向，所以「两个向量同起点」只是画图方便，不是定义的一部分。
3. **数乘的符号**。$\lambda=0$ 得到零向量，方向未定义；后续若对这个向量做归一化就会除零。
4. **矩阵乘法不交换**。$AB\ne BA$，加速递推时左乘/右乘的构造方式完全不同，混用就全错。
5. **不等式与等式要分清**。引入部分的「开胃小菜」写的是 $\le$（线性规划），正片改成了 $=$（线性方程组）。两种问题的解法不一样：前者看可行域顶点，后者才用高斯消元。
6. **线性变换这一节原文是空的**。不要以为「没写就是没有内容」，下面单列一节说明现状。
7. **别跳过向量直接学矩阵**。矩阵的每一行本质就是与向量做点积，向量运算不熟，矩阵乘法只能靠背。

## 线性变换（原文留白）

原文在这里只留了三个标题，正文一句话都没写：

- **线性空间**：原文只有标题。
- **线性基**：原文只有标题。
- **线性映射**：原文只有标题。

> ~~理论存在，画饼开始~~

为了不让这一节彻底空着，这里只补一句最基础的定义（属补白，不是原文内容）：若映射 $T$ 满足

$$
T(\vec{a}+\vec{b})=T(\vec{a})+T(\vec{b}),\qquad T(\lambda\vec{a})=\lambda T(\vec{a})
$$

则称 $T$ 为**线性变换**（线性映射）。坐标下一旦选定基，线性变换就能写成一个矩阵，左乘该矩阵即完成变换——这就是上一页矩阵乘法与线性递推能挂上钩的原因。更详细的线性空间、线性基、线性映射内容，等原文补充后再回来同步。$AKB309$, '数学', array['数学', '线性代数', '向量', '矩阵', '线性变换'], null, null, 'knowledge'),
('world-needs-sunday', 'col-math-matrix-linear-recurrence', '矩阵加速线性递推', $AKB310$## 矩阵加速线性递推

## 一、算法原理

### 1.1 问题背景

竞赛中有大量这样的题目：数列 $f(n)$ 由前面的项线性组合而来，如 $f(n) = 2f(n-1) + 3f(n-2) + 5n + 7$，求 $f(10^{18})$。

| 方法 | 复杂度 | $n = 10^{18}$ 可行性 |
|------|--------|---------------------|
| 朴素递推 | $O(n)$ | 完全不可行（每秒约 $10^8 \sim 10^9$ 次运算） |
| 通项公式 | $O(1)$ | 仅少数递推有封闭形式，推导困难且易错 |
| **矩阵快速幂** | $O(k^3 \log n)$ | $k$ 为状态维数（通常个位数），$10^{18}$ 只需约 60 轮 ✓ |

### 1.2 核心直觉

递推本质上是一个**固定的函数反复作用**：$v(1) \to v(2) \to v(3) \to \cdots$。如果这个函数恰好是"左乘矩阵 $M$"，那么走 $n$ 步就是连乘 $n$ 个 $M$，而**结合律**允许把它们按任意分组方式先乘好——快速幂正是最高效的分组方式。

### 1.3 三步转化

$$\text{递推关系} \xrightarrow{\text{状态向量}+\text{转移矩阵}} \text{矩阵乘法} \xrightarrow{\text{结合律}} M^n \xrightarrow{\text{快速幂}} O(k^3 \log n)$$

1. **状态向量**：把"一个时刻的全部信息"打包成列向量 $F(m)$
2. **转移矩阵**：把"推一步"写成 $F(m) = M \cdot F(m-1)$
3. **矩阵幂**：$F(n) = M^{n-m_0} \cdot F(m_0)$，用快速幂计算 $M^{n-m_0}$

### 1.4 线性性——能用矩阵加速的充要判据

矩阵乘向量的本质是**线性组合**。能用矩阵加速的充要条件：

> 每个新分量都能写成旧分量的**常数系数加权和**。

- 系数是常数 ✅
- 出现"两个未知量相乘"（如 $n \cdot f(n-1)$）就 ❌

**红线清单**（无法塞进标准矩阵加速的结构）：

| 结构 | 例子 | 为什么不行 |
|------|------|-----------|
| 未知量的乘积 | $f(n) = n \cdot f(n-1)$（阶乘型） | 两个未知分量相乘，不是线性组合 |
| max / min 转移 | $f(i) = \max(f(i-1),\ f(i-2)+a_i)$ | max 不是线性运算 |
| 未知量作除数/指数 | $f(n) = f(n-1) / f(n-2)$ | 非线性 |
| 非固定系数 | $f(i) = c_i \cdot f(i-1)$，$c_i$ 各不相同 | 转移矩阵每步都在变，无法统一成一个 $M$ 求幂 |

> **例外**：max/min 可通过 $(\max, +)$ 半环扩展矩阵乘法定义来解决（见第七节）。

### 1.5 预备知识速查

| 概念 | 要点 |
|------|------|
| 矩阵乘法 | $(a \times b)$ 矩阵 × $(b \times c)$ 矩阵 = $(a \times c)$ 矩阵；$C[i][j] = \sum_t A[i][t] \cdot B[t][j]$ |
| 结合律 | $(AB)C = A(BC)$ ✅ —— 矩阵快速幂合法性的基石 |
| 不满足交换律 | $AB \neq BA$ ❌ —— 决定了"转移顺序"不能随便换 |
| 单位矩阵 $I$ | 主对角线为 1，其余为 0；$I \cdot M = M \cdot I = M$，充当快速幂中 `res = 1` 的角色 |
| 快速幂 | 指数二进制分解，$O(\log n)$ 次"平方 + 按位累乘" |
| 模运算 | 加减乘对模数同态：$(a \cdot b + c) \bmod \text{mod}$；除法需逆元 |

## 二、核心公式/状态定义与转移方程

### 2.1 状态向量设计原则

> **转移时需要什么，状态里就放什么。**

递推往往不止依赖一个量。比如 $f(n) = f(n-1) + f(n-2)$，要知道 $f(n)$ 就得同时掌握 $f(n-1)$ 和 $f(n-2)$。于是定义列向量：

$$F(m) = \begin{bmatrix} f(m) \\ f(m-1) \end{bmatrix}$$

它编码了"时刻 $m$ 的全部所需信息"。

### 2.2 转移矩阵——一步递推 = 乘一次矩阵

如果能把递推写成

$$F(m) = M \cdot F(m-1)$$

——即新状态的每个分量都是旧状态分量的加权和（系数为常数）——那么递推就完全被矩阵 $M$ 刻画了。

### 2.3 迭代展开——n 步 = 矩阵幂

$$F(n) = M \cdot F(n-1) = M^2 \cdot F(n-2) = \cdots = M^{n-m_0} \cdot F(m_0)$$

其中 $m_0$ 是初始时刻。于是"推 $10^{18}$ 步"变成"算 $M^{10^{18}}$"，快速幂登场。

### 2.4 第一个完整例子：斐波那契

递推：$f(n) = f(n-1) + f(n-2)$，初值 $f(1) = f(2) = 1$。

**第一步：定状态。** 需要最近两项：

$$F(m) = \begin{bmatrix} f(m) \\ f(m-1) \end{bmatrix}$$

**第二步：解转移矩阵。** 求 $2 \times 2$ 矩阵 $M = \begin{bmatrix} a & b \\ c & d \end{bmatrix}$ 使得 $M \cdot F(m-1) = F(m)$：

- 第一行算新分量 $f(m)$：$a \cdot f(m-1) + b \cdot f(m-2) = f(m-1) + f(m-2)$ → $a=1,\ b=1$
- 第二行算新分量 $f(m-1)$：直接抄旧的第一分量 → $c=1,\ d=0$

$$M = \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}$$

**第三步：定幂次。** $F(1) = [f(1),\ f(0)]^T = [1,\ 0]^T$，每乘一次 $M$ 前进一格，故

$$F(n) = M^{n-1} \cdot F(1)$$

$n = 1$ 时 $M^0 = I$，得 $F(1)$ 本身 ✓（天然的边界自检）。

**第四步：手算验证。** $M^2 = \begin{bmatrix} 2 & 1 \\ 1 & 1 \end{bmatrix}$，$M^4 = (M^2)^2 = \begin{bmatrix} 5 & 3 \\ 3 & 2 \end{bmatrix}$，$M^8 = (M^4)^2 = \begin{bmatrix} 34 & 21 \\ 21 & 13 \end{bmatrix}$

求 $f(10)$：$n-1 = 9 = 1001_2 = 8 + 1$，故 $M^9 = M^8 \cdot M = \begin{bmatrix} 55 & 34 \\ 34 & 21 \end{bmatrix}$

$f(10) = 55$ ✓（斐波那契：1, 1, 2, 3, 5, 8, 13, 21, 34, 55）

整个过程只做了 4 次矩阵乘法。若 $n = 10^{18}$，也就约 60 轮。

### 2.5 通用模板：k 阶线性递推的"友矩阵"

**一般形式**：

$$f(n) = c_1 f(n-1) + c_2 f(n-2) + \cdots + c_k f(n-k)$$

**状态**（$k$ 维，窗口内所有项）：

$$F(m) = \begin{bmatrix} f(m) \\ f(m-1) \\ \vdots \\ f(m-k+1) \end{bmatrix}$$

**转移矩阵**（$k \times k$）：

$$M = \begin{bmatrix} c_1 & c_2 & \cdots & c_{k-1} & c_k \\ 1 & 0 & \cdots & 0 & 0 \\ 0 & 1 & \cdots & 0 & 0 \\ \vdots & & \ddots & & \vdots \\ 0 & 0 & \cdots & 1 & 0 \end{bmatrix}$$

**记忆图像——传送带 / 移位寄存器**：

把状态想成一条传送带上的 $k$ 个格子：

- **第一行**负责"计算新来的值"：按系数 $c_1 \ldots c_k$ 加权混合旧窗口
- **下面的行**负责"整体右移一格"：第 $i$ 行在第 $i-1$ 列放 1，意思是"新窗口第 $i$ 格 = 旧窗口第 $i-1$ 格"，即每个值都向前挪一位、最老的掉出去

**幂次对齐**：

初值通常给 $f(1)$ 到 $f(k)$，即初始向量取在时刻 $m_0 = k$：

$$F(n) = M^{n-k} \cdot F(k), \qquad F(k) = \begin{bmatrix} f(k) \\ f(k-1) \\ \vdots \\ f(1) \end{bmatrix}, \qquad \text{答案} = F(n) \text{ 的第 1 个分量}$$

指数是 $n - k$：从时刻 $k$ 走到时刻 $n$ 恰好 $n - k$ 步。**这是全流程最容易差一的地方**，见第六节自检方法。

### 2.6 构造技巧大全

真实题目很少直接给你纯净的 $k$ 阶递推，总带着常数项、$n$ 的多项式、前缀和……下面的技巧逐一破解。总原则始终不变：

> **"转移需要什么，状态里就放什么；每个新分量必须是旧分量的线性组合。"**

#### 技巧 1：常数项 → 增加 "1" 这一维

例：$f(n) = 2f(n-1) + 3$。

常数 3 不是任何旧分量的倍数。给状态添一个恒为 1 的维度，让常数也变成"系数 × 状态分量"：

$$F(m) = \begin{bmatrix} f(m) \\ 1 \end{bmatrix}, \qquad M = \begin{bmatrix} 2 & 3 \\ 0 & 1 \end{bmatrix}$$

第二行 $[0,\ 1]$ 表示"1"由旧的"1"转移而来——"1"是台永动机，永远产出 1，于是常数项就可以永远搭顺风车。

**数值验证**（$f(1)=1 \to f(2)=5,\ f(3)=13,\ f(4)=29$）：

$F(1) = [1,\ 1]^T \to M \cdot F(1) = [2+3,\ 1]^T = [5,\ 1]^T$ ✓ → $[2 \cdot 5+3,\ 1]^T = [13,\ 1]^T$ ✓ → $[2 \cdot 13+3,\ 1]^T = [29,\ 1]^T$ ✓

#### 技巧 2：n、n²、n³ → 二项式展开链（最常用也最易错）

例：$f(n) = f(n-1) + n^2$。

难点：递推里出现的是**新时刻的 $n^2$**，而矩阵转移时手里只有**旧时刻的分量**。必须用二项式把"新的"翻译回"旧的"：

$$n = (n-1) + 1$$

$$n^2 = (n-1)^2 + 2(n-1) + 1$$

$$n^3 = (n-1)^3 + 3(n-1)^2 + 3(n-1) + 1$$

（系数正是杨辉三角那一行！$n^2$ 需要 $[1,\ 2,\ 1]$，$n^3$ 需要 $[1,\ 3,\ 3,\ 1]$。）

于是想维护 $n^2$，就必须连带维护 $n$ 和 1——一条完整的链：

$$F(m) = \begin{bmatrix} f(m) \\ m^2 \\ m \\ 1 \end{bmatrix}, \qquad M = \begin{bmatrix} 1 & 1 & 2 & 1 \\ 0 & 1 & 2 & 1 \\ 0 & 0 & 1 & 1 \\ 0 & 0 & 0 & 1 \end{bmatrix}$$

逐行验证（对旧向量 $[f(n-1),\ (n-1)^2,\ (n-1),\ 1]^T$）：

| 行 | 表达式 | 展开结果 | 应等于 |
|----|--------|---------|--------|
| 1 | $f(n-1) + (n-1)^2 + 2(n-1) + 1$ | $f(n-1) + n^2$ | $f(n)$ ✓ |
| 2 | $(n-1)^2 + 2(n-1) + 1$ | $n^2$ | $m^2$ 分量 ✓ |
| 3 | $(n-1) + 1$ | $n$ | $m$ 分量 ✓ |
| 4 | $1$ | $1$ | 常数分量 ✓ |

**数值验证**（$f(0)=0 \to f(1)=1,\ f(2)=5,\ f(3)=14,\ f(4)=30$）：

$F(0)=[0,0,0,1]^T$，乘一次得 $[0+0+0+1,\ 1,\ 1,\ 1]^T = [1,1,1,1]^T$ → $f(1)=1$ ✓

再乘得 $[1+1+2+1,\ 4,\ 2,\ 1]^T = [5,4,2,1]^T$ → $f(2)=5$ ✓

再乘得 $[5+4+4+1,\ 9,\ 3,\ 1]^T = [14,9,3,1]^T$ → $f(3)=14$ ✓

**两个要点**：
1. 递推中出现新时刻的 $n^k$，就"退一格"用二项式写成旧时刻的线性组合
2. 维护 $n^k$ 必须连带 $n^{k-1} \ldots n$、1 全链条，一个不能少

#### 技巧 3：前缀和 / 统计量 → 直接塞进状态

例：斐波那契前缀和 $S(n) = \sum_{i=1}^{n} f(i)$，求 $S(10^{18})$。

把 $S$ 也当成一个"需要转移的量"，直接放进状态：

$$F(m) = \begin{bmatrix} S(m) \\ f(m) \\ f(m-1) \end{bmatrix}, \qquad M = \begin{bmatrix} 1 & 1 & 1 \\ 0 & 1 & 1 \\ 0 & 1 & 0 \end{bmatrix}$$

逐行验证（对旧向量 $[S(n-1),\ f(n-1),\ f(n-2)]^T$）：

- 第 1 行：$S(n-1) + f(n-1) + f(n-2) = S(n-1) + f(n) = S(n)$ ✓（注意 $f(n)$ 要先展开成 $f(n-1)+f(n-2)$ 才是旧分量的线性组合——这正是新手填错第 1 行 $[1,1,0]$ 的原因）
- 第 2 行：$f(n-1) + f(n-2) = f(n)$ ✓
- 第 3 行：$f(n-1)$ ✓

**数值验证**（$S_2=2,\ S_3=4,\ S_4=7$）：$F(2)=[2,1,1]^T$ → 乘 $M$ 得 $[2+1+1,\ 2,\ 1]^T = [4,2,1]^T = F(3)$ ✓ → 再乘得 $[4+2+1,\ 3,\ 2]^T = [7,3,2]^T = F(4)$ ✓

答案取第 1 分量——答案在哪个分量，取决于你把谁放在状态的第一位，两者要配套。

#### 技巧 4：多个互相递推的量 → 全部打包

若题目同时给两个量互相迭代，如 $a(n) = 2a(n-1) + b(n-1)$，$b(n) = a(n-1) + 3b(n-1)$，就把 $a$、$b$ 都放进状态：

$$F(m) = \begin{bmatrix} a(m) \\ b(m) \end{bmatrix}, \qquad M = \begin{bmatrix} 2 & 1 \\ 1 & 3 \end{bmatrix}$$

矩阵天然就是描述"一组量同时线性演化"的语言。

#### 技巧 5：等比项 aⁿ → 自身可线性转移

$a^n = a \cdot a^{n-1}$，所以 $a^n$ 自己就是一个合法的线性分量（系数是常数 $a$），需要时放进状态即可。

> **注意**：它只能加、不能乘别的分量——$f(n) = f(n-1) \cdot a^n$ 里出现了两个未知量相乘，就踩了红线。

#### 技巧 6：图上游走 —— 最直观的"矩阵 = 转移"模型

设邻接矩阵 $A$（有边为 1），一个经典结论：

$$(A^k)[i][j] = \text{从 } i \text{ 到 } j \text{ 恰好走 } k \text{ 步的方案数}$$

原因：$A$ 的幂每乘一次，恰好"多走一步"（$(A^{k+1})[i][j] = \sum_t (A^k)[i][t] \cdot A[t][j]$，枚举倒数第二步 $t$）。这是"一次转移 = 一次矩阵乘法"最朴素的具象化。

#### 综合大例：f(n) = 2f(n-1) + 3f(n-2) + 5n + 7

把所有技巧一次用全。状态：递推阶数 2 → 要 $f(n-1)$、$f(n-2)$；线性项 $n$；常数 → 补 1：

$$F(m) = \begin{bmatrix} f(m) \\ f(m-1) \\ m \\ 1 \end{bmatrix}$$

逐行构造（关键是把含 $n$ 的项退回 $n-1$：$5n + 7 = 5(n-1) + 12$）：

| 新分量 | 用旧分量表达 | 行系数 $[f(n-1),\ f(n-2),\ n-1,\ 1]$ |
|--------|-------------|---------------------------------------|
| $f(n)$ | $2f(n-1) + 3f(n-2) + 5(n-1) + 12$ | $[2,\ 3,\ 5,\ 12]$ |
| $f(n-1)$ | 直接抄 | $[1,\ 0,\ 0,\ 0]$ |
| $n$ | $(n-1) + 1$ | $[0,\ 0,\ 1,\ 1]$ |
| $1$ | 恒等 | $[0,\ 0,\ 0,\ 1]$ |

$$M = \begin{bmatrix} 2 & 3 & 5 & 12 \\ 1 & 0 & 0 & 0 \\ 0 & 0 & 1 & 1 \\ 0 & 0 & 0 & 1 \end{bmatrix}$$

**数值验证**（$f(1)=1,\ f(2)=2$）：$f(3) = 2 \cdot 2 + 3 \cdot 1 + 15 + 7 = 29$。用矩阵：$F(2) = [2,1,2,1]^T$，第一行点积 $= 4+3+10+12 = 29$ ✓

$F(3) = [29,2,3,1]^T$，$f(4) = 2 \cdot 29 + 3 \cdot 2 + 20 + 7 = 91$，第一行点积 $= 58+6+15+12 = 91$ ✓

### 2.7 下标对齐 —— 最容易 WA 的地方

矩阵本身背模板就能写对，真正翻车的是"乘几次"。三个自检动作务必养成习惯：

**1. 口诀："指数 = 步数"**

从初始向量 $F(m_0)$ 到答案向量 $F(n)$，转移恰好进行 $n - m_0$ 次，所以指数就是 $n - m_0$。写下状态定义的那一刻，就把 $m_0$ 和 $F(m_0)$ 具体列出（含每个分量的值），别凭感觉。

**2. 边界自检：$n = m_0$ 时必须返回初值**

代入最小合法的 $n$：此时 $M^0 = I$，输出应恰好等于已知的初始值。若不等，说明初始向量摆错或答案取错了分量。

**3. 单步自检：$n = m_0 + 1$ 时手推对照**

$M \cdot F(m_0)$ 应等于你手工推一步的结果；再暴力跑前 $10^4$ 项与矩阵版逐项对拍。矩阵元素错、幂次错、初值错，这三类 bug 会被这一步全部揪出。

### 2.8 行向量还是列向量？（约定问题）

同一个转移有左右两种写法，选定一种坚持到底：

| 约定 | 转移式 | 矩阵形态 | $n$ 步后 |
|------|--------|---------|---------|
| 列向量（本文） | $F(m) = M \cdot F(m-1)$ | 第一行是"计算新值的系数" | $F(n) = M^{n-m_0} \cdot F(m_0)$ |
| 行向量 | $v(m) = v(m-1) \cdot M$ | 第一列是对应系数（= 列向量版的转置） | $v(n) = v(m_0) \cdot M^{n-m_0}$ |

**连锁后果**（在"分段转移"中致命）：列向量下先经转移 $A$ 再经转移 $B$，合成矩阵是

$$v'' = B(Av) = (BA)v \implies \text{合成为 } B \cdot A \text{ ——顺序反着写！}$$

调试时先确认自己用哪种约定，再检查矩阵元素含义，否则会出现"元素全填转置位置"的隐形错误。

### 2.9 半环视角：把矩阵乘法换成别的运算

矩阵快速幂能用的根本原因不是"数可以相加相乘"，而是 $(\oplus, \otimes)$ 满足**半环**性质：$\oplus$ 可交换、可结合、有单位元（零元），$\otimes$ 可结合、有单位元，且对 $\oplus$ 满足分配律。只要换掉一对运算，同一套幂运算就能解决另一类问题：

| 半环类型 | 加法 $\oplus$ | 乘法 $\otimes$ | 核心含义与应用 |
| :--- | :--- | :--- | :--- |
| **布尔半环** | OR（逻辑或） | AND（逻辑与） | 可达性、布尔矩阵乘法 |
| **(max, ×) 半环** | max（取最大） | ×（普通乘法） | 最大权重路径、概率最大化 |
| **(max, min) 半环** | max（取最大） | min（取最小） | 瓶颈路径问题（最大化最小边权） |
| **max-Łukasiewicz 半环** | max | $\max(0, a+b-1)$ | 模糊逻辑推理，可等价转换为热带线性代数 |
| **分配格 / 路代数** | 并（join） | 交（meet） | 一般化的格上矩阵运算，涵盖布尔代数、模糊代数等 |

实践上的用法：把 `c[i][j] = sum(a[i][k] * b[k][j])` 换成 `c[i][j] = max(a[i][k] + b[k][j])` 就得到最长路版本的矩阵幂（对应边权加法）；换成 `c[i][j] |= a[i][k] & b[k][j]` 就得到可达性版本。只要新运算满足半环公理，快速幂的 $O(n^3\log k)$ 结构完全不变。

## 三、逐行代码解析

本程序是一个**通用的矩阵加速框架**：读入初始状态向量、转移矩阵和转移次数，自动完成 $M^k \cdot F_0$ 的计算。与矩阵乘法、矩阵快速幂两个知识点共享基础设施函数（`read_mat`、`write_mat`、`mul_mat`、`fastpow_mat`），核心新增在 `main` 函数的调度逻辑。

### 3.1 共享基础设施（read_mat / write_mat / mul_mat / fastpow_mat）

这四个函数与矩阵快速幂知识点完全一致，此处仅说明关键设计：

```cpp
const long long mod = 1e9 + 7;
```

- 全局模数 $10^9 + 7$（质数），每步取模控制溢出

```cpp
void read_mat(vector<vector<long long>>& mat, int n, int m)
{
    mat.assign(n + 1, vector<long long>(m + 1, 0));
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++)
            cin >> mat[i][j];
}
```

- `n`、`m` 由调用方传入（分离维度管理与数据读入），1-based 下标与数学公式直接对应

```cpp
vector<vector<long long>> mul_mat(const vector<vector<long long>>& A, const vector<vector<long long>>& B, const long long mod)
{
    if (A[1].size() != B.size()) return vector<vector<long long>>();
    int n = A.size(), m = B[1].size();
    vector<vector<long long>> ans(n, vector<long long>(m, 0));
    for (int i = 1; i < n; i++)
        for (int k = 1; k < A[1].size(); k++)
        {
            if (!A[i][k]) continue;
            for (int j = 1; j < m; j++)
                ans[i][j] = (ans[i][j] + A[i][k] * B[k][j]) % mod;
        }
    return ans;
}
```

- `const&` 避免值拷贝，`i-k-j` 循环顺序缓存友好，稀疏跳过 `if (!A[i][k]) continue` 对含大量 0 的转移矩阵效果显著
- 判维失败返回空矩阵作为失败信号

```cpp
vector<vector<long long>> fastpow_mat(const vector<vector<long long>>& A, long long k, const long long mod)
{
    if (A.size() != A[1].size()) return vector<vector<long long>>();
    vector<vector<long long>> ans(A.size(), vector<long long>(A[1].size(), 0));
    for (int i = 1; i < A.size(); i++) ans[i][i]  = 1;
    vector<vector<long long>> tmp(A);
    if (k == 0) return ans;
    while (k)
    {
        if (k & 1) ans = move(mul_mat(tmp, ans, mod));
        tmp = move(mul_mat(tmp, tmp, mod));
        k >>= 1;
    }
    return ans;
}
```

- 单位矩阵 $I$ 为乘法单位元，`tmp` 不断自乘平方，`move` 避免深拷贝
- `k` 用 `long long` 读入，支持 $k$ 达 $10^{18}$

> 以上函数的完整逐行解析见 [矩阵快速幂](?id=math-matrix-quick-pow) 知识点。

### 3.2 main —— 核心调度：读入 → 求幂 → 乘状态

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    cout << "请输入初始状态的元素个数: \n";
    cin >> n;
    cout << "请输入初始状态: \n";
    vector<vector<long long>> A;
    read_mat(A, n, 1);
    cout << "请输入转移矩阵: \n";
    vector<vector<long long>> shift_mat;
    read_mat(shift_mat, n, n);
    cout << "请输入转移次数: \n";
    long long k;
    cin >> k;
    cout << "结果为: \n";
    write_mat(mul_mat(fastpow_mat(shift_mat, k, mod), A, mod));
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快速 IO |
| 3-5 | `cin >> n;` | 状态维数 $k$（注意这里的 `n` 是状态维度，不是递推步数） |
| 6-7 | `read_mat(A, n, 1);` | 读入初始状态向量 $F(m_0)$，形状 $n \times 1$（列向量） |
| 8-9 | `read_mat(shift_mat, n, n);` | 读入转移矩阵 $M$，形状 $n \times n$（方阵） |
| 10-11 | `cin >> k;` | 转移次数 $k$，用 `long long` 读入，支持 $10^{18}$ |
| 12 | `write_mat(mul_mat(fastpow_mat(shift_mat, k, mod), A, mod));` | 核心：计算 $M^k \cdot F_0$ 并输出 |

**最后一行是整个程序的灵魂**，拆解为三步：

$$\underbrace{\text{fastpow\_mat}(M,\ k)}_{\text{Step 1: } M^k} \quad \xrightarrow{\text{}} \quad \underbrace{\text{mul\_mat}(M^k,\ F_0)}_{\text{Step 2: } M^k \cdot F_0} \quad \xrightarrow{\text{}} \quad \underbrace{\text{write\_mat}(\cdots)}_{\text{Step 3: 输出}}$$

1. `fastpow_mat(shift_mat, k, mod)` ——计算转移矩阵的 $k$ 次幂 $M^k$，$O(n^3 \log k)$
2. `mul_mat(..., A, mod)` ——用 $M^k$ 左乘初始状态向量 $F_0$，得到最终状态 $F(m_0 + k)$
3. `write_mat(...)` ——输出结果矩阵（$n \times 1$ 的列向量，即各状态分量的最终值）

### 3.3 运行示例：斐波那契第 10 项

状态 $F(m) = [f(m),\ f(m-1)]^T$，转移矩阵 $M = \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}$，初始 $F(1) = [1,\ 0]^T$，求 $f(10)$。

输入：
```
2
1 0
1 1
1 0
9
```

- 初始状态个数 = 2
- 初始状态：1 0（即 $f(1)=1,\ f(0)=0$）
- 转移矩阵：$\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}$
- 转移次数 = 9（$10 - 1 = 9$ 步，从 $m_0 = 1$ 到 $n = 10$）

输出：
```
55 34
34 21
```

$F(10) = M^9 \cdot F(1) = [55,\ 34]^T$，第 1 分量 $f(10) = 55$ ✓

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(k^3 \log n)$ | $O(\log n)$ 轮快速幂，每轮最多 2 次矩阵乘法，每次 $O(k^3)$；最后再乘一次状态向量 $O(k^2)$ |
| 空间 | $O(k^2)$ | `ans`、`tmp` 及临时结果矩阵 |

其中 $k$ 是状态维数，$n$ 是转移步数。

**规模感受**：

| $k$ | $\log n$ ($n=10^{18}$) | 总运算量 | 耗时 |
|-----|----------------------|---------|------|
| 2 | 60 | $\approx 1.4 \times 10^4$ | 瞬间 |
| 4 | 60 | $\approx 1.1 \times 10^5$ | 瞬间 |
| 10 | 60 | $\approx 7.2 \times 10^6$ | 毫秒级 |
| 100 | 60 | $\approx 7.2 \times 10^8$ | 接近 1 秒贴边 |

对比朴素递推 $O(n)$，$n = 10^{18}$ 时快了约 17 个数量级——这正是"快速幂 + 矩阵"组合的价值。

> $k$ 较大时需考虑 `i-k-j` 循环序、攒批取模等常数优化（本程序已内置）。

## 五、适用场景

| 场景 | 说明 | 典型例子 |
|------|------|---------|
| **线性递推加速** | 线性常系数递推数列的第 $n$ 项（$n$ 达 $10^{18}$） | 斐波那契、$f(n) = c_1 f(n-1) + \cdots + c_k f(n-k)$ |
| **带常数项/多项式项的递推** | 用构造技巧扩展状态维度 | $f(n) = 2f(n-1) + 3f(n-2) + 5n + 7$ |
| **前缀和统计量** | 把前缀和塞进状态向量 | $S(n) = \sum_{i=1}^{n} f(i)$，$n$ 达 $10^{18}$ |
| **多变量联动递推** | 多个量互相线性迭代 | $a(n) = 2a(n-1) + b(n-1)$ |
| **图论路径计数** | 邻接矩阵的 $k$ 次幂 = 恰好 $k$ 步的路径数 | "走恰好 $k$ 步从 $i$ 到 $j$ 有多少条路" |
| **状态压缩 DP 优化** | 状态转移写成矩阵形式 | 某些线性 DP 的转移矩阵固定时 |
| **模意义下的矩阵逆** | $A^{-1} = A^{\text{mod}-2}$（当 $A$ 可逆且 mod 为质数） | 需要矩阵逆的场景 |

## 六、常见陷阱与注意事项

### 6.1 幂次差一（最高频 WA 原因）

**症状**：答案与期望差一个递推步。

**根因**：$n - k$、$n - k + 1$、$n - k - 1$ 之间反复横跳。

**自检**：代入 $n = m_0$，此时 $M^0 = I$ 应返回初值；若不等，说明幂次错。

### 6.2 矩阵填成转置

**症状**：数值验证时每一行都对，但实际运行全错。

**根因**：列向量约定下，"新分量 $i$ 的系数"应填在第 $i$ **行**；行向量约定则填列。先定约定再动笔。

### 6.3 初始向量顺序摆反

**症状**：小规模验证全对，大规模答案错乱。

**根因**：$F(k) = [f(k),\ f(k-1),\ \ldots,\ f(1)]^T$，与状态定义严格一致，倒过来全盘皆错。

### 6.4 忘记维护 n² 的配套链

**症状**：$n^2$ 分量的转移矩阵行无法填出合法系数。

**根因**：要维护 $n^2$ 必须连带 $n$ 和 1；只放 $n^2$ 一维，转移矩阵无处取系数。

### 6.5 含 n 的项没退回 n-1

**症状**：数值验证第一轮就错。

**根因**：递推里是 $5n$，矩阵行里要写 $5(n-1) + 5$ 的展开系数（即 $[5, 5]$ 对应 $n-1$ 和 1 两维）。这是因为转移矩阵乘的是**旧时刻**的状态。

### 6.6 前缀和行没有展开

**症状**：前缀和分量转移行填错（常见填成 $[1,1,0]$）。

**根因**：$S(n) = S(n-1) + f(n)$，而 $f(n)$ 要再展开成 $f(n-1) + f(n-2)$ 才能填系数（正确行为 $[1,1,1]$）。

### 6.7 漏取模 / 读入不取模

**症状**：溢出导致结果错误。

**根因**：溢出安全分析的前提是参与首轮乘法的元素 $< \text{mod}$ 量级。若题面元素可能达到 $10^{18}$，需在 `read_mat` 中就地归约：`mat[i][j] = ((mat[i][j] % mod) + mod) % mod;`。

### 6.8 k 必须非负

**症状**：$k < 0$ 时主循环不终止。

**根因**：`k >>= 1` 对负数是算术右移（`-1 >> 1` 恒为 `-1`）。若需支持负指数（矩阵逆），须另行按费马小定理转化为 $A^{k \bmod (\text{mod}-1)}$ 等方式处理。

### 6.9 硬套模板处理非线性

**症状**：对含未知量乘积或 max/min 的递推强行套矩阵加速，结果完全错误。

**根因**：模板只对线性递推有效。遇到非线性结构，要么转化问题消除非线性项，要么换算法。

## 七、对比与扩展

### 7.1 与朴素递推 / 通项公式对比

| 维度 | 朴素递推 | 通项公式 | 矩阵加速 |
|------|---------|---------|---------|
| 复杂度 | $O(n)$ | $O(1)$ | $O(k^3 \log n)$ |
| $n = 10^{18}$ | 不可行 | 仅少数递推可用 | 可行 ✓ |
| 通用性 | 通用 | 极低（需封闭形式） | 高（只要线性即可） |
| 实现难度 | 低 | 高（推导易错） | 中（模板化） |
| 常数项/前缀和 | 天然支持 | 需重新推导 | 构造技巧扩展状态 |
| 易错点 | 无 | 推导错误 | 幂次差一、矩阵转置 |

### 7.2 进阶技巧

#### 分段转移：不同阶段不同规则

题目若说"前 $n_1$ 天规则 A、之后规则 B"：

$$F(n) = M_B^{n-n_1} \cdot M_A^{n_1} \cdot F(0)$$

两段幂各自快速幂算出后按顺序相乘（注意列向量下合成顺序是 $B \cdot A$，反着写）。

#### 转移矩阵预处理 + 多次询问

同一底矩阵要回答多组"走 $t$ 步"的询问时，预处理 $M^{2^0},\ M^{2^1},\ \ldots,\ M^{2^{59}}$，每次询问 $O(k^2 \log t)$ 拼装答案。

#### 矩阵等比数列求和

要算 $S = I + M + M^2 + \cdots + M^{n-1}$（"n 步内所有状态的累计统计"类问题）：

$$S(2t) = S(t) \cdot (I + M^t), \qquad S(2t+1) = S(2t) + M^{2t}$$

递归分治，$O(k^3 \log n)$ 完成。经典应用：$M$ 是图邻接矩阵时，$S$ 给出"长度不超过 $n-1$ 的路径总数"。

#### (max, +) 半环矩阵幂

把矩阵乘法定义换成 $C[i][j] = \max_t (A[i][t] + B[t][j])$，依然满足结合律，可求"恰好 $k$ 步的最长路/最优 DP 值"。只需重写 `mul_mat` 的内层运算，`fastpow_mat` 框架完全复用。

#### 状态维度瘦身

维度 $k$ 直接决定耗时（$k^3 \log n$），能省一维是一维：

- 递推里用不到的量不进状态
- 能由已有分量推出来的量不进状态（如同时放 $f(n)$、$f(n-1)$、$f(n-1)+f(n-2)$ 就冗余了）
- 转移只往前看 $s$ 步，窗口就开 $s$ 维，不多开

### 7.3 完整做题流程（五步法）

拿到一道矩阵加速题，按此流程走：

1. **写递推**：明确 $f(n)$ 的表达式与足够多的初值
2. **设计状态向量**：把"推一步需要的所有量"列出来（递推窗口 + $n$ 的多项式链 + 常数 1 + 前缀和 + 其他联动量），并明确 $m_0$ 与 $F(m_0)$ 的每个分量值
3. **逐行填转移矩阵**：每个新分量用二项式/展开式翻译成旧分量的线性组合，每一行当场口算验证一遍
4. **对齐幂次**：指数 $= n - m_0$，答案取对应分量
5. **对拍**：暴力 $O(n)$ 版跑前若干项，与矩阵版逐项比对（含 $n = m_0$、$m_0 + 1$ 两个边界点）

### 7.4 一句话总结

把递推的"一步"抽象成列向量乘固定矩阵——状态向量装下"推一步所需的全部信息"（递推窗口、二项式链维护的 $n^k$、永动机般的常数 1、前缀和……），转移矩阵的第一行负责"算新值"、下面的错位 1 负责"移位"；线性性保证矩阵存在，结合律保证 $n$ 步连乘可折叠成 $M^{n-m_0}$，快速幂把 $10^{18}$ 步压缩成约 60 轮 $O(k^3)$ 的矩阵乘法——设计时恪守"新分量必须是旧分量的线性组合"，提交前用"$n = m_0$ 返回初值 + 单步手推 + 暴力对拍"三连自检，矩阵加速便是处理超大步数线性递推的通用钥匙。$AKB310$, '数学', array['数学', '矩阵', '快速幂', '线性递推', '状态转移', '构造技巧'], 'col-math-matrix-multiplication', null, 'knowledge'),
('Xesir', 'col-math-matrix-multiplication--xesir', '矩阵与矩阵快速幂 · Xesir', $AKB311$## 算法原理

矩阵（Matrix）是一个由 $m\times n$ 个数排成的 $m$ 行 $n$ 列的矩形数表：

$$
A = \begin{bmatrix}
a_{11} & a_{12} & \cdots & a_{1n} \\
a_{21} & a_{22} & \cdots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \cdots & a_{mn}
\end{bmatrix}
$$

其中 $a_{ij}$ 表示第 $i$ 行第 $j$ 列的元素，矩阵常用大写字母 $A,B,C$ 表示。向量是特殊的矩阵：列向量是 $n\times 1$ 矩阵，行向量是 $1\times n$ 矩阵。

### 基本概念

- **同型矩阵**：行数与列数分别对应相同。
- **方阵**：行数等于列数，$n$ 阶方阵即 $n\times n$ 矩阵。OI 里很多定义与运用都基于方阵。
- **主对角线**：方阵中从左上到右下、满足 $i=j$ 的元素 $a_{11},a_{22},\dots,a_{nn}$。
- **对称矩阵**：满足 $a_{ij}=a_{ji}$，元素关于主对角线对称。
- **对角矩阵**：主对角线之外全为 $0$，记作 $\mathrm{diag}\{\lambda_1,\lambda_2,\dots,\lambda_n\}$。
- **单位矩阵**：主对角线全为 $1$ 的对角矩阵，记作 $I$ 或 $I_n$。
- **三角矩阵**：主对角线左下方全为 $0$ 的称为上三角矩阵；右上方全为 $0$ 的称为下三角矩阵。

### 四则运算与两个「特殊运算」

- **转置**：行与列互换，第 $i$ 行变第 $i$ 列。
- **加法**：同型矩阵对应元素相加。
- **乘法**：$C=A\times B$ 时 $c_{ij}=\sum_k a_{ik}b_{kj}$，要求 $A$ 的列数等于 $B$ 的行数；满足**结合律**，不满足**交换律**。
- **行列式**：只对方阵定义，记作 $\det(A)$ 或 $\lvert A\rvert$；二阶情形就是 $ad-bc$。
- **逆矩阵**：方阵可逆时满足 $A\cdot A^{-1}=A^{-1}\cdot A=I$。

### 矩阵快速幂

普通快速幂能优化求幂，是因为乘法满足结合律；矩阵乘法同样满足结合律，所以把底数从**整数**换成**矩阵**、乘法换成**矩阵乘法**，其余完全一致——这就是矩阵快速幂。

有两个细节必须记住：

1. 快速幂里的初值 `1` 要换成**单位矩阵** $I$（任何矩阵乘相应大小的单位矩阵还是自身）。
2. 只有方阵才有「幂」这一说法，所以矩阵快速幂实际上只能对方阵使用。

**最经典的应用是加速线性递推。** 对 $k$ 阶线性递推

$$
f_n=c_1f_{n-1}+c_2f_{n-2}+\cdots+c_kf_{n-k}
$$

把「一步递推」写成矩阵乘法，$n$ 步就是矩阵的 $n-k$ 次幂，$O(k^3\log n)$ 就能算到 $10^{18}$ 级别。细节见下面的核心公式一节。

### 初等变换

初等变换是线性代数里最基础也最强大的工具之一，共三种操作，每种都对应一个**初等矩阵**（对单位矩阵 $I$ 做一次该变换得到的矩阵）：

1. **倍乘矩阵** $D_i(k)$：把单位矩阵第 $i$ 个对角元换成 $k$（$k\ne 0$），行变换效果是「第 $i$ 行乘 $k$」，常用于归一化或提取公因子。
2. **对换矩阵** $P_{ij}$：把单位矩阵第 $i$ 行与第 $j$ 行互换，行变换效果是「交换两行」，消元时用来选主元（避开 $0$ 主元）。
3. **倍加矩阵** $T_{ij}(k)$：把单位矩阵第 $j$ 行的 $k$ 倍加到第 $i$ 行，行变换效果是「第 $j$ 行乘 $k$ 加到第 $i$ 行」——**消元法的核心操作**，Gaussian 消元的主力。

对矩阵 $A$ **左乘**一个初等矩阵，等价于对 $A$ 做一次**初等行变换**；**右乘**则等价于一次**初等列变换**。三种初等矩阵均可逆，且逆矩阵仍是同类型初等矩阵：

| 初等矩阵 | 逆矩阵 |
| :--- | :--- |
| $D_i(k)$ | $D_i(1/k)$ |
| $P_{ij}$ | $P_{ij}$（对换的逆是自己） |
| $T_{ij}(k)$ | $T_{ij}(-k)$ |

它们的行列式分别为 $\lvert D_i(k)\rvert=k$、$\lvert P_{ij}\rvert=-1$、$\lvert T_{ij}(k)\rvert=1$，这个性质在**用初等变换算行列式**时非常好用。

初等变换的三个经典用途：

1. **解线性方程组（消元法）**：系数矩阵与常数项拼成增广矩阵，用初等行变换化成行最简形，直接读出解（见[高斯消元](?id=math-gauss-elimination)）。
2. **求逆矩阵（Gauss-Jordan 法）**：把 $A$ 与 $I$ 并排摆成 $[A\mid I]$，只用初等行变换把左边化成 $I$，右边就自动变成 $A^{-1}$。
3. **化标准形**：把任意矩阵化成「左上角是单位矩阵 $I_r$、其余为 $0$」的形式，可用于判断矩阵的秩。

## 核心公式 / 状态定义与转移方程

### 基本运算

$$
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6
\end{bmatrix}^{T}
=
\begin{bmatrix}
1 & 4 \\
2 & 5 \\
3 & 6
\end{bmatrix}
$$

$$
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6
\end{bmatrix}
\begin{bmatrix}
7 & 8 \\
9 & 10 \\
11 & 12
\end{bmatrix}
=
\begin{bmatrix}
58 & 64 \\
139 & 154
\end{bmatrix}
$$

> 乘法结果矩阵的尺寸由前者的行数和后者的列数决定：$A_{m\times n}\cdot B_{n\times p}=C_{m\times p}$。

### 行列式与逆矩阵

$$
\begin{vmatrix}
a & b \\
c & d
\end{vmatrix}
= ad-bc
\qquad\Longrightarrow\qquad
\begin{vmatrix}
1 & 2 \\
3 & 4
\end{vmatrix}
=1\cdot 4-2\cdot 3=-2
$$

$$
A=\begin{bmatrix} a & b \\ c & d \end{bmatrix},
\qquad
A^{-1}=\frac{1}{ad-bc}\begin{bmatrix} d & -b \\ -c & a \end{bmatrix}
$$

例如

$$
\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}^{-1}
=\frac{1}{-2}\begin{bmatrix} 4 & -2 \\ -3 & 1 \end{bmatrix}
=\begin{bmatrix} -2 & 1 \\ 1.5 & -0.5 \end{bmatrix}
$$

代回去乘一遍确实得到 $I$，说明 $ad-bc\ne 0$ 是可逆的充要条件。

### 线性递推的状态与转移矩阵

$$
f_n=c_1f_{n-1}+c_2f_{n-2}+\cdots+c_kf_{n-k}
$$

定义状态向量（窗口内所有项，共 $k$ 维）：

$$
X_n=\begin{bmatrix} f_{n-1} \\ f_{n-2} \\ \vdots \\ f_{n-k} \end{bmatrix}
$$

则存在转移矩阵 $M$ 使 $X_n=M\cdot X_{n-1}$：

$$
M=\begin{bmatrix}
c_1 & c_2 & \cdots & c_{k-1} & c_k \\
1 & 0 & \cdots & 0 & 0 \\
0 & 1 & \cdots & 0 & 0 \\
\vdots & \vdots & \ddots & \vdots & \vdots \\
0 & 0 & \cdots & 1 & 0
\end{bmatrix}
$$

于是

$$
X_n=M^{\,n-k}\cdot X_k
$$

只需用矩阵快速幂求 $M^{\,n-k}$，复杂度 $O(k^3\log n)$，显然优于一般递推。

以斐波那契为例，$f_n=f_{n-1}+f_{n-2}$、$f_1=f_2=1$，取 $X_n=[f_n,\ f_{n-1}]^T$：

$$
X_n=\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}\cdot X_{n-1}
\qquad\Longrightarrow\qquad
\begin{bmatrix} f_n \\ f_{n-1} \end{bmatrix}
=
\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}^{n-2}
\begin{bmatrix} f_2 \\ f_1 \end{bmatrix}
$$

> 上面构造的转移矩阵都是为**左乘**情况构造的；矩阵乘法**没有交换律**，所以一定不要弄混顺序。

## 逐行代码解析

原文这一节给的是**片段**（依赖 `v2`、`vi` 两个 typedef，原文没有给出定义，也没有 `main`），并不是可直接编译的完整程序，所以本条目按 `noCode` 处理，代码按原文顺序原样贴出并拆成四块讲解。

### 模块一：矩阵加法 `mtxp`

```cpp
v2 mtxp(v2 a,v2 b){//矩阵加法
	int n=a.size(),m=a[0].size();
	for(int i=1;i<n;i++){
		for(int j=1;j<m;j++){
			a[i][j]+=b[i][j];
		}
	}
	return a;
}
```

- `n` 取行数、`m` 取列数（`a[0].size()`），对应「同型矩阵对应元素相加」。
- **循环从 `i=1`、`j=1` 开始**，也就是第 $0$ 行、第 $0$ 列被跳过。这是 1-based 书写习惯的残留，和下面 `muljz` 的 0-based 遍历不一致，实际使用时要留意（见「常见陷阱」）。
- 参数按值传递，函数内改的是副本，所以必须 `return a`；这也意味着每次调用都要整表拷贝一次。

### 模块二：矩阵乘法 `muljz`

```cpp
v2 muljz(v2 a,v2 b){//矩阵乘法
	int m=a.size(),p=a[0].size(),n=b[0].size();
	v2 c(m,vi(n,0));
	for(int i=0;i<m;i++){
		for(int k=0;k<p;k++){
		    if(a[i][k]==0) continue;
		    for(int j=0;j<n;j++){
		        c[i][j]=(c[i][j]+a[i][k]*b[k][j]);
		    }
		}
	}
	return c;
}
```

- 三个变量要按「角色」理解，别按字母猜：`m` 是 $A$ 的行数、`p` 是公共维（$A$ 的列 = $B$ 的行）、`n` 是 $B$ 的列数。结果 `c` 是 $m\times n$。
- 循环序是 `i-k-j`：把公共维 $k$ 放中间，`a[i][k]==0` 时整段 `j` 循环直接跳过，对稀疏矩阵（比如转移矩阵）很划算。
- `c[i][j]=(c[i][j]+a[i][k]*b[k][j]);` **没有取模**，乘加都直接在原类型上做，元素大时会溢出。
- 原文没有对 `a[0].size()==b.size()` 做判维检查，维度不匹配会直接越界。

### 模块三：矩阵快速幂 `ksmjz`

```cpp
v2 ksmjz(v2 a,int n){//矩阵快速幂
	int len=a.size();
	v2 res(len,vi(len,0));
	for(int i=0;i<len;i++){
		res[i][i]=1;
	}
	while(n){
		if(n&1) res=muljz(res,a);
		a=muljz(a,a);
		n>>=1;
	}
	return res;
}
```

- `res` 初始化成 $I$：只把主对角线置 $1$，其余保持 $0$——这就是快速幂里 `res=1` 的矩阵版。
- `while(n)` 里「按位累乘 + 底数平方 + 右移」，和整数快速幂逐字对应。
- 指数是 `int n`，上限约 $2\times 10^9$；真要做到 $10^{18}$ 得改成 `long long`。
- 只有 `a` 是方阵时 `muljz(a,a)` 才合法；原文没有检查，非方阵会静默越界或算错。

### 模块四：构造转移矩阵 `fdpjz`

```cpp
v2 fdpjz(vi a){//优化递推矩阵
	int n=a.size();v2 b;
	b.pb(a);
	for(int i=1;i<n;i++){
		vi c;
		for(int j=0;j<n;j++){
			if(i-1==j) c.pb(1);
			else c.pb(0);
		}
		b.pb(c);
	}
	return b;
}
```

- 传入的 `a` 就是递推系数 $[c_1,c_2,\dots,c_k]$，第一行原样搬进转移矩阵。
- 之后每一行只有第 `i-1` 列是 $1$，其余为 $0$，正好实现「窗口整体下移一格」。
- `pb` 是 `push_back`；这里全程 0-based，和 `muljz` 一致。构造出来的就是核心公式里的友矩阵。

## 复杂度分析

| 操作 | 时间 | 空间 |
|---|---|---|
| 矩阵加法（$n\times m$） | $O(nm)$ | $O(nm)$（按值传参还要多一份拷贝） |
| 矩阵乘法（$m\times p$ 乘 $p\times n$） | $O(mpn)$，方阵即 $O(n^3)$ | $O(mn)$ |
| 矩阵快速幂（$n$ 阶方阵，指数 $k$） | $O(n^3\log k)$ | $O(n^2)$ |
| 矩阵加速 $k$ 阶线性递推 | $O(k^3\log n)$ | $O(k^2)$ |
| 一次初等变换 | $O(n)$（只动一行/一列） | $O(1)$ |
| Gauss-Jordan 求逆（$n$ 阶） | $O(n^3)$ | $O(n^2)$ |

其中矩阵快速幂与线性递推的复杂度是原文明确给出的字面值（$O(k^3\log n)$）；加法、乘法与初等变换的复杂度按循环层数与操作规模推出。

## 适用场景

- **矩阵乘法模板题**：给定两个矩阵求积，直接三重循环。
- **线性递推加速**：斐波那契、常系数线性递推的第 $n$ 项（$n$ 达 $10^{18}$）。
- **图上游走计数**：邻接矩阵的 $k$ 次幂给出「恰好走 $k$ 步」的路径数。
- **固定转移的 DP 加速**：转移矩阵不随阶段变化时，可以把多轮转移折叠成一次矩阵幂。
- **解方程组 / 求逆**：初等变换 + Gauss-Jordan，配合[高斯消元](?id=math-gauss-elimination)。
- **不适合**：递推里有未知量相乘、$\max/\min$ 转移、系数每步变化的结构（除非改用 $(\max,+)$ 这类半环，见[群论·抽象代数对象分类](?id=math-group-theory)），矩阵加速那套线性组合的前提已经崩了。

## 常见陷阱与注意事项

1. **`mtxp` 的下标基准和别处不一致**。加法从 `1` 开始遍历，跳过了第 $0$ 行与第 $0$ 列；`muljz`、`ksmjz`、`fdpjz` 都是 `0` 开始。混用时第 $0$ 行/列的加法结果不会被更新，且 `1×n` 或 `n×1` 的矩阵会直接算成空操作。照原文原样保留，使用时自己盯住这一点。
2. **`muljz` 全程不取模**。元素稍大就会溢出；而且溢出后符号/数值都不可预测。要取模得自己加 `% mod`。
3. **`muljz` 没有判维**。`a[0].size()` 与 `b.size()` 不相等时，`b[k][j]` 直接越界。矩阵乘法要求 $A$ 的列数等于 $B$ 的行数。
4. **`ksmjz` 的指数是 `int`**。$k>2^{31}-1$ 就爆，做 $10^{18}$ 的递推必须换 `long long`。
5. **只有方阵能求幂**。`ksmjz` 没有做方阵检查，非方阵会在 `muljz(a,a)` 里出错。
6. **`res` 必须初始化为单位矩阵**。初始化成全 $0$ 或全 $1$，幂次结果全错。
7. **转移矩阵是按左乘构造的**。$X_n=M\cdot X_{n-1}$，所以 $X_n=M^{n-k}X_k$；如果改成行向量约定，矩阵要转置，幂次写法也得跟着改。
8. **幂次差一**。$X_k$ 是初始时刻，走到 $X_n$ 恰好 $n-k$ 步；写成 $n-k+1$ 或 $n-k-1$ 都会整体错一位，代 $n=k$ 自检最快。
9. **`.size()` 是 `size_t`**。和 `int` 混比会有符号警告，严谨写法是 `(int)a.size()`。
10. **初等变换左乘行、右乘列**。`[A\mid I]` 求逆时只能做行变换；不小心把列变换混进去，右边就不再是 $A^{-1}$。
11. **行列式只对方阵有定义**。别对 $m\ne n$ 的矩阵算 $\det$。$AKB311$, '数学', array['数学', '矩阵', '矩阵乘法', '矩阵快速幂', '线性递推'], null, null, 'knowledge'),
('world-needs-sunday', 'col-math-matrix-multiplication', '矩阵乘法', $AKB312$## 矩阵乘法

## 一、算法原理与问题定义

读入两个矩阵 $A$ 和 $B$，计算它们的乘积 $C = A \times B$；如果维度不满足相乘条件，则输出错误提示。

**矩阵乘法的两条铁律**：

1. **可乘条件**：$A$ 是 $n \times k$ 矩阵、$B$ 是 $k \times m$ 矩阵时才能相乘，即 $A$ 的列数必须等于 $B$ 的行数，否则乘法无定义。
2. **结果形状**：乘积 $C$ 是 $n \times m$ 矩阵，其中：

$$C[i][j] = \sum_{t=1}^{k} A[i][t] \times B[t][j]$$

用文字说：$C$ 的第 $i$ 行第 $j$ 列 = $A$ 的第 $i$ 行 与 $B$ 的第 $j$ 列对应元素乘积之和（行乘列，点积）。

整个程序是典型的"输入 → 处理 → 输出"三段式结构：一个函数负责读入，一个函数负责判维 + 三重循环计算，一个函数负责输出。

## 二、数据结构设计

### 1. 为什么用 vector<vector<long long>>

- 二维 vector 天然对应"矩阵 = 行的序列"，每行是一个一维 vector，行列数可任意指定，无需预设最大规模。
- **long long 的必要性**：矩阵乘法中元素要先乘再加。两个 $10^5$ 量级的数相乘已达 $10^{10}$，超出 int（上限约 $2.1 \times 10^9$）的表示范围。用 long long（上限约 $9.2 \times 10^{18}$）是防止溢出的标准做法。

### 2. 为什么采用 1-based 下标

```cpp
mat.assign(n + 1, vector<long long>(m + 1, 0));
// 读入循环: i = 1..n, j = 1..m
```

- 数学公式中矩阵下标习惯从 1 开始，代码下标与公式下标直接一一对应，写三重循环时无需做"第 i 行其实是下标 i-1"的心算换算，降低出错概率。
- 代价是第 0 行、第 0 列的空间闲置，开销可忽略。
- 这个约定会统一约束后面所有函数的循环边界——全程序保持同一套下标语义是正确性的基础。

## 三、逐行代码解析

> 按源文件 `源.cpp` 的实际顺序拆成 5 个模块：头文件 → `read_mat`（读入）→ `write_mat`（输出）→ `mul_mat`（边界/判维 + 三重循环）→ `main`（串联）。各模块代码块按顺序拼接即与 `.cpp` 完全一致，行尾 `//` 注释仅用于讲解。

### 1. 头文件与命名空间

```cpp
#include<bits/stdc++.h>
using namespace std;
```

- 万能头 `bits/stdc++.h` 一次包含标准库常用头，竞赛环境常见写法。
- `using namespace std;` 省去 `std::` 前缀；这是代码里的既定写法，讲解以 `.cpp` 为准。

### 2. read_mat —— 读入矩阵

```cpp
void read_mat(vector<vector<long long>>& mat,int n,int m)
{
    mat.assign(n + 1, vector<long long>(m + 1, 0)); // 分配 (n+1)×(m+1) 并全部清零
    for (int i = 1; i <= n; i++)                    // 1-based：i 从 1 到 n
    {
        for (int j = 1; j <= m; j++)                // 行优先：内层扫列
        {
            cin >> mat[i][j];
        }
    }
}
```

- **按引用传参 `&`**：读入要修改外部矩阵，必须传引用，否则函数内的赋值随函数结束而丢失。
- **`assign` 一石二鸟**：既分配 `(n+1)×(m+1)` 空间，又把所有元素初始化为 0，后续累加所需的"清零"在此一并完成。
- **行优先读入**：外层扫行、内层扫列，与"每行 m 个数"的输入格式一致；n/m 由调用方读入后传入，读入函数只负责填数据，职责单一。

### 3. write_mat —— 输出矩阵

```cpp
void write_mat(const vector<vector<long long>>& mat)
{
    if (mat.size() <= 1 || mat[1].size() <= 1)    // 边界：空/退化矩阵时提前返回
    {
        cout << "NO null" << '\n';                // 打印错误提示
        return;
    }
    for (int i = 1; i < mat.size(); i++)          // 行上界 = 行数+1，配 mat[i][j] 的行下标
    {
        for (int j = 1; j < mat[1].size(); j++)   // 列上界 = 列数+1，配 mat[i][j] 的列下标
        {
            cout << mat[i][j] << ' ';
        }
        cout << '\n';
    }
}
```

- **先处理失败分支**：`mul_mat` 边界/判维失败时返回空矩阵，这里用 `mat.size() <= 1 || mat[1].size() <= 1` 双重拦截——`mat.size() <= 1` 挡空矩阵（size 为 0），`mat[1].size() <= 1` 挡没有数据列的退化矩阵，命中即打印 `NO null` 并提前返回；提示语的具体措辞以题目要求为准。
- **行列上界配对纪律**：行下标 `i` 配 `mat.size()`、列下标 `j` 配 `mat[1].size()`，与 `mat[i][j]` 中两个下标的位置严格对应，任意形状（方阵、1×N、N×1）都能正确遍历、不会越界。
- **输出格式细节**：每行末尾会多打一个空格，多数判题器可容忍；严格题可改为"元素间空格分隔、行末不留空格"。

### 4. mul_mat —— 判维与三重循环（核心）

```cpp
vector<vector<long long>> mul_mat(const vector<vector<long long>>& A, const vector<vector<long long>>& B)
{
    if (A.size() <= 1 || B.size() <= 1) return {};   // 边界：空/退化矩阵直接返回空
    if (A[1].size() != B.size()) return {};          // 判维：列A+1 != 行B+1 时返回空矩阵
    int n = A.size(), m = B[1].size();    // n=行A+1, m=列B+1（1-based 各带一个 +1）
    vector<vector<long long>> ans(n, vector<long long>(m, 0));
    for (int i = 1; i < n; i++)           // i：结果行 = A 的行
    {
        for (int k = 1; k < A[1].size(); k++) // k：公共维度（A 的列 = B 的行）
        {
            for (int j = 1; j < m; j++)   // j：结果列 = B 的列
            {
                ans[i][j] += A[i][k] * B[k][j]; // 行乘列点积，累加到 ans[i][j]
            }
        }
    }
    return ans;
}
```

- **先做边界守卫**：`A.size() <= 1 || B.size() <= 1` 在访问 `A[1]`、`B[1]` 之前先拦下空矩阵（size 为 0）或退化矩阵（只有第 0 行/列），避免后续 `A[1].size()` 越界，也让 0×0 这类边界输入被安全处理。
- **判维是"列A = 行B"的等价写法**：1-based 存储使 `A[1].size() = 列A+1`、`B.size() = 行B+1`，两边的 "+1" 抵消，`A[1].size() == B.size()` 与数学条件完全等价；前提是全程统一 1-based 语义。
- **失败返回空矩阵**：乘法函数不负责打印错误（计算与 IO 分离），用 `return {}` 返回空 vector，调用方（或 `write_mat`）用 `mat.size() <= 1` 区分成功/失败；正常矩阵至少 1 行 1 列，不会与"空"混淆。
- **`i-k-j` 循环顺序缓存友好**：内层 `j` 连续访问 `B[k][j]` 与 `ans[i][j]`，内存连续、命中率高；相比 `i-j-k` 少切换 B 的行，减少 cache miss。
- **`const&` 保护**：`const&` 接收两个乘数，既避免值拷贝开销，又在编译期防止函数体内误改 A、B。

### 5. main —— 串联三段式

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    vector<vector<long long>> A, B, ans;
    int n, m;
    cin >> n >> m;
    read_mat(A, n, m);
    cin >> n >> m;
    read_mat(B, n, m);
    ans = mul_mat(A, B);
    write_mat(ans);
    return 0;
}
```

- **流程清晰**：读 A 的维度 → 读 A → 读 B 的维度 → 读 B → 乘 → 打；main 只负责维度管理与调度，读入/计算/输出各自封装，职责分离。
- **成败分支内聚**：成功输出矩阵 / 失败输出提示分别封装在 `mul_mat`（边界/判维）与 `write_mat`（空矩阵）内部，main 不需要写 if。

## 四、手动示例

设：

$$A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix},\quad B = \begin{bmatrix} 5 & 6 \\ 7 & 8 \end{bmatrix}$$

计算 $C = A \times B$：

| C[i][j] | 计算过程 | 结果 |
|---------|---------|------|
| C[1][1] | 1×5 + 2×7 = 5 + 14 | 19 |
| C[1][2] | 1×6 + 2×8 = 6 + 16 | 22 |
| C[2][1] | 3×5 + 4×7 = 15 + 28 | 43 |
| C[2][2] | 3×6 + 4×8 = 18 + 32 | 50 |

$$C = \begin{bmatrix} 19 & 22 \\ 43 & 50 \end{bmatrix}$$

## 五、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(n \times m \times k)$ | 三重循环，行A × 列B × 公共维度k；方阵情形即经典的 $O(n^3)$ |
| 空间 | $O(n \times m)$ | 三个矩阵，总计 $O(nm)$ |

这是朴素矩阵乘法的标准复杂度；更大规模需借助分块或 Strassen 类算法，常规题目无此需求。

## 适用场景

- **矩阵乘法模板题**：给定两个矩阵求乘积，直接三重循环即可
- **作为矩阵快速幂 / 线性递推加速的基座**：矩阵乘法是 $A^k$ 的 $O(n^3 \log k)$ 计算与斐波那契类 $O(\log n)$ 递推的基础（见「七、扩展与延伸」）
- **不适用**：$n$ 很大的稠密矩阵相乘时，朴素 $O(n^3)$ 会超时，需要分块、Strassen 类算法，或利用矩阵的稀疏性

## 六、常见陷阱

1. **行列上界的配对**：任何遍历中，行下标必须配 `mat.size()`、列下标必须配 `mat[1].size()`，与 `mat[i][j]` 中两个下标的位置严格对应。测试时必含长方形用例（如 1×3、3×1），因为方阵的对称性无法暴露行列配对错误。
2. **下标语义的全局一致性**：判维条件 `A[1].size() == B.size()` 成立的前提是全程统一 1-based 存储（各带一个 "+1"，比较时抵消）。若某处改用 0-based 或漏写/多写 "+1"，判维即失效。
3. **内层乘积下标顺序**：`A[i][k] * B[k][j]`，i 对应 A 的行、k 是公共维、j 对应 B 的列，书写时按公式逐位核对。
4. **传引用**：读入函数必须以 `&` 接收矩阵参数，否则修改不生效；只读参数建议加 `const`。
5. **数据类型**：乘加运算默认使用 long long，防止溢出；若元素接近 $10^9$ 且公共维度很大，需估算累加上界确认不超 $9.2 \times 10^{18}$。
6. **行末空格**：视判题器严格程度决定是否消除；严格题采用"首元素外均前置空格"的写法。
7. **边界输入**：新代码已在 `mul_mat` 入口用 `A.size() <= 1 || B.size() <= 1` 挡掉空矩阵/退化矩阵，`write_mat` 又用 `mat.size() <= 1 || mat[1].size() <= 1` 兜底，因此 0×0 这类边界输入不会触发 `A[1]` 越界；若要保持这一安全，不要删掉这两处守卫。

## 七、扩展与延伸

- **矩阵快速幂**：利用矩阵乘法的结合律，通过快速幂的思想计算 $A^k$，常用于线性递推加速（如斐波那契第 n 项的 $O(\log n)$ 求解）。
- **矩阵乘法的结合律**：$(A \times B) \times C = A \times (B \times C)$，但**不满足交换律**：$A \times B \neq B \times A$（维度都不一定匹配）。
- **单位矩阵**：主对角线为 1、其余为 0 的方阵，满足 $A \times I = I \times A = A$，是矩阵快速幂的初始值。
- **Strassen 算法**：利用分治策略将矩阵乘法降到约 $O(n^{2.807})$，竞赛中几乎不用，了解即可。$AKB312$, '数学', array['数学', '矩阵', '矩阵乘法', '线性代数'], null, null, 'knowledge'),
('world-needs-sunday', 'col-math-matrix-quick-pow', '矩阵快速幂', $AKB313$## 矩阵快速幂

## 一、算法原理与问题定义

读入一个方阵 $A$ 和一个指数 $k$，计算 $A^k \pmod{10^9+7}$，输出结果；若 $A$ 不是方阵（无法自乘），输出错误提示。

**核心矛盾**：$k$ 可能非常大（典型题目中 $k$ 可达 $10^{18}$ 量级）。朴素的"乘 $k$ 次"即使每次乘法只要 $O(n^3)$，总复杂度也是 $O(n^3 \cdot k)$，对 $k = 10^{18}$ 完全不可行。

**突破口**是经典的快速幂思想：

$$A^{13} = A^{8} \times A^{4} \times A^{1} \quad (13 = 1101_2)$$

把指数写成二进制，只需 $O(\log k)$ 次"平方 + 按位累乘"就能得到结果。而"乘法"这个概念从普通的数推广到矩阵后，整套思想原样适用——因为矩阵乘法满足**结合律**（$(AB)C = A(BC)$），这正是快速幂正确性的代数基础；同时矩阵乘法没有交换律，但快速幂恰好不需要交换律，只需自乘与自乘结果相乘，顺序天然合法。

**最大应用场景**——加速线性递推：如斐波那契数列 $F(n) = F(n-1) + F(n-2)$ 可写成矩阵幂形式 $[F(n), F(n-1)] = [F(1), F(0)] \times M^{n-1}$，于是 $O(n)$ 的递推被压缩为 $O(n^3 \log n)$ 的矩阵幂——当 $n$ 高达 $10^{18}$ 时，这是唯一可行的路径。

## 二、数据结构设计

与矩阵乘法程序一脉相承的三项决定：

### 1. vector<vector<long long>> + 模数 mod

矩阵幂的每一步都在做"乘加"，数值增长极快，`long long` 配合每步取模是标准组合；全局模数 `mod = 1e9 + 7` 是质数，作为题目常用模数写死在常量中。

### 2. 沿用 1-based 下标

`read_mat` 与矩阵乘法完全一致：`assign(n+1, vector(m+1, 0))`，n/m 由调用方传入，下标从 1 开始，与数学公式直接对应。全程序（读入、判维、三重循环、单位矩阵初始化）统一这套语义。

### 3. 空矩阵继续作为失败信号

- `fastpow_mat` 发现 $A$ 不是方阵时返回空矩阵
- `mul_mat` 判维失败时返回空矩阵
- `write_mat` 检查 `.empty()` 统一处理输出 `NO mull`

失败信号层层向上传递，计算与 IO 保持分离。

## 三、逐行代码解析 1/3：mul_mat —— 带模矩阵乘法

相比普通矩阵乘法，本版做了三处增强：`const&` 参数、`i-k-j` 缓存友好循环顺序、稀疏跳过优化。

```cpp
vector<vector<long long>> mul_mat(const vector<vector<long long>>& A, const vector<vector<long long>>& B, const long long mod)
{
    if (A[1].size() != B.size()) return vector<vector<long long>>();
    int n = A.size(), m = B[1].size();
    vector<vector<long long>> ans(n, vector<long long>(m, 0));
    for (int i = 1; i < n; i++)
    {
        for (int k = 1; k < A[1].size(); k++)
        {
            if (!A[i][k]) continue;          // 稀疏跳过：A[i][k]为0时整行B[k]无需计算
            for (int j = 1; j < m; j++)
            {
                ans[i][j] = (ans[i][j] + A[i][k] * B[k][j]) % mod;
            }
        }
    }
    return ans;
}
```

### 三处增强

| 增强点 | 说明 |
|--------|------|
| `const&` 参数 | 避免值拷贝开销，编译期防止误改 A、B |
| `i-k-j` 循环顺序 | 内层 `j` 连续访问 `B[k][j]` 和 `ans[i][j]`，两者在内存中均连续，缓存命中率高 |
| 稀疏跳过 `if (!A[i][k]) continue;` | 当 `A[i][k]` 为 0 时，`A[i][k] * B[k][j]` 必为 0，跳过整行 `j` 循环。对稀疏矩阵（如转移矩阵中大量 0 元素）效果显著 |

### 取模的时机与溢出安全分析

为什么写成 `(ans + A*B) % mod`，而不是 `A[i][k] % mod * B[k][j] % mod` 逐项取模？关键在于估算表达式的上界：

- 若矩阵元素均 $< \text{mod} \approx 1.0 \times 10^9$，则乘积 $A[i][k] \times B[k][j] < (10^9+7)^2 \approx 1.0 \times 10^{18}$
- 再加上一个 $< \text{mod}$ 的旧值 `ans[i][j]`，总和 $< 1.0 \times 10^{18} + 10^9$
- `long long` 上限约 $9.2 \times 10^{18}$，留有约 9 倍安全余量 ✓

这个分析的隐含前提是"参与运算的元素始终 $< \text{mod}$"。程序通过"每次乘法结果都 `% mod`"来维持这个前提：`ans`、`tmp` 中所有元素永远落在 $[0, \text{mod})$ 区间内，后续每轮运算的上界与首轮相同，全程不会溢出。

> **重要前提**：读入的原始元素也必须 $< \text{mod}$ 量级，因为首轮乘法用的是未取模的原始值。

### 判维条件

`A[1].size() != B.size()` 即 列A+1 == 行B+1，两边 1-based 偏差互相抵消，与数学条件"列 A = 行 B"等价——矩阵自乘天然是方阵间的运算，这里为通用性保留了完整判维。

## 四、逐行代码解析 2/3：fastpow_mat —— 核心算法

### 1. 合法性检查 + 单位元准备

```cpp
if (A.size() != A[1].size()) return vector<vector<long long>>();
vector<vector<long long>> ans(A.size(), vector<long long>(A[1].size(), 0));
for (int i = 1; i < A.size(); i++) ans[i][i] = 1;   // 单位矩阵 I
vector<vector<long long>> tmp(A);                    // tmp = A
```

两个初始化各有深意：

| 变量 | 初始值 | 作用 |
|------|--------|------|
| `ans` | 单位矩阵 $I$ | 矩阵乘法中的乘法单位元（$I \times M = M \times I = M$）。数论快速幂里 `res = 1`，这里就是它的矩阵版本 |
| `tmp` | $A$ 的副本 | "底数"的替身，循环中不断自乘平方（$A \to A^2 \to A^4 \to A^8 \cdots$），不修改原始 $A$ |

**为什么 A 必须是方阵？** $A^k$ 意味着 $A$ 自己乘自己 $k$ 次，只有 $n \times n$ 方阵相乘后形状才不变；非方阵连 $A \times A$ 都无法定义，直接以空矩阵报告失败。

### 2. k = 0 特判

```cpp
if (k == 0) return ans;   // A^0 = I
```

数学规定 $A^0 = I$（单位矩阵），恰好此时 `ans` 还没被循环动过、就是 $I$，直接返回即可。这个特判也可以省略——$k = 0$ 时 `while` 循环体一次都不执行，返回的本来就是 $I$——但显式写出更清晰。

### 3. 二进制分解主循环

```cpp
while (k)
{
    if (k & 1) ans = move(mul_mat(tmp, ans, mod));   // 当前二进制位是 1 → 累乘
    tmp = move(mul_mat(tmp, tmp, mod));              // 底数平方: A^(2^t) → A^(2^(t+1))
    k >>= 1;                                          // 处理下一位
}
```

**不变量**（循环任意时刻都成立的性质）：进入第 $t$ 轮循环前，`tmp` $= A^{2^t}$，`ans` $=$ $A$ 的二进制分解中已处理各位对应的幂之积。

以 $k = 13 = 1101_2$ 为例：

| 轮次 | k 的二进制 | k&1 | 动作 | ans | tmp（本轮结束后） |
|------|-----------|-----|------|-----|------------------|
| 初始 | 1101 | — | — | $I$ | $A^1$ |
| 1 | 1101 | 1 | ans ×= $A^1$；tmp 平方 | $A^1$ | $A^2$ |
| 2 | 110 | 0 | tmp 平方 | $A^1$ | $A^4$ |
| 3 | 11 | 1 | ans ×= $A^4$；tmp 平方 | $A^5$ | $A^8$ |
| 4 | 1 | 1 | ans ×= $A^8$ | $A^{13}$ ✓ | （不再使用） |

循环结束时 `ans` $= A^{k \text{ 的二进制各位展开之积之和}} = A^k$。整个过程矩阵乘法执行 $O(\log k)$ 次，$k = 10^{18}$ 时约 60 轮。

**三个实现细节**：

- `k & 1` 与 `k >>= 1`：位运算取最低位、右移一位，等价于"不断除 2 取余"，是快速幂的惯用写法
- **`move` 语义**：`ans = move(mul_mat(...))` 将返回值的资源（底层指针）直接"窃取"到 `ans`，避免深拷贝。矩阵乘法每次返回新矩阵，值拷贝会复制整个 $n^2$ 数据；`move` 把这次拷贝省掉，在 $n = 100$ 时每轮省 2 次 $10^4$ 元素拷贝，累积效果可观
- 末轮的最后一次平方是冗余的：$k$ 的最高位处理完后，`tmp` 的平方结果不会再被用到。可优化为 `k >>= 1; if (k) tmp = move(mul_mat(tmp, tmp, mod));`，省去一次 $O(n^3)$ 乘法。对单次求解影响甚微，属性能优化而非正确性问题

## 五、逐行代码解析 3/3：write_mat 与 main

`write_mat` 未做任何改动：先处理空矩阵分支，再按"行下标 i 配 `mat.size()`、列下标 j 配 `mat[1].size()`"的纪律遍历输出。

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    vector<vector<long long>> A, ans;
    int n;
    long long k;
    cin >> n >> k;
    read_mat(A, n, n);
    ans = move(fastpow_mat(A, k, mod));
    write_mat(ans);
    return 0;
}
```

`main` 负责维度管理和调度——读入 $n$ 和 $k$ 后，以 `read_mat(A, n, n)` 读入方阵（行列同为 $n$），`move` 将 `fastpow_mat` 的返回值无拷贝移入 `ans`。`read_mat` 只管填数据，职责分离清晰。

> **注意**：$k$ 上限可达 $10^{18}$，必须用 `long long` 读入和传参，`int` 会溢出。

## 六、手动模拟示例

设 $A = \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}$，$k = 5$。

这是斐波那契递推矩阵，$A^k$ 的左上角元素 $= F_{k+1}$。

$5 = 101_2$，分解为 $A^4 \times A^1$。

| 轮次 | k 二进制 | k&1 | 动作 | ans | tmp |
|------|---------|-----|------|-----|-----|
| 初始 | 101 | — | — | $I$ | $A^1$ |
| 1 | 101 | 1 | ans ×= $A^1$；tmp 平方 | $A^1$ | $A^2$ |
| 2 | 10 | 0 | tmp 平方 | $A^1$ | $A^4$ |
| 3 | 1 | 1 | ans ×= $A^4$ | $A^5$ ✓ | — |

计算过程：

$$A^2 = \begin{bmatrix} 2 & 1 \\ 1 & 1 \end{bmatrix},\quad A^4 = \begin{bmatrix} 5 & 3 \\ 3 & 2 \end{bmatrix}$$

$$A^5 = A^4 \times A^1 = \begin{bmatrix} 5 & 3 \\ 3 & 2 \end{bmatrix} \times \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix} = \begin{bmatrix} 8 & 5 \\ 5 & 3 \end{bmatrix}$$

验证：$F_6 = 8$, $F_5 = 5$ ✓

## 七、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(n^3 \log k)$ | $O(\log k)$ 轮循环，每轮最多 2 次矩阵乘法，每次 $O(n^3)$ |
| 空间 | $O(n^2)$ | `ans`、`tmp` 及临时结果矩阵 |

以 $n = 100$、$k = 10^{18}$ 为例：约 60 轮 × 2 次 × $10^6$ 次乘加 $\approx 1.2 \times 10^8$ 次运算，在现代评测机 1~2 秒内可完成。

对比朴素连乘 $O(n^3 \cdot k)$，$k = 10^{18}$ 时快了约 17 个数量级——这正是"快速幂 + 矩阵"组合的价值。

## 八、常见陷阱

1. **读入元素需 < mod 量级**：溢出安全分析的前提是参与首轮乘法的元素 $< \text{mod}$。若题面元素可能达到 $10^{18}$，需在 `read_mat` 中就地归约：`mat[i][j] = ((mat[i][j] % mod) + mod) % mod;`（先 `%` 再 `+mod` 再 `%`，可同时兼容负数）。
2. **k 必须非负**：`k >>= 1` 对负数是算术右移（`-1 >> 1` 恒为 `-1`），$k < 0$ 时主循环不终止。若需支持负指数（矩阵逆），须另行按费马小定理转化为 $A^{k \bmod (\text{mod}-1)}$ 等方式处理。
3. **指数用 long long 读入**：$k$ 上限 $10^{18}$，`int` 存不下，会直接溢出。
4. **单位矩阵初始化**：只置主对角线 `ans[i][i] = 1`，其余保持 0；写错成整行/整列置 1 会让所有结果翻倍错乱。
5. **n, m ≥ 1 前提**：函数内直接访问 `A[1]`，$0 \times 0$ 输入会越界；常规题目保证非空矩阵，无需处理。
6. **signed/unsigned 比较**：`int i` 与 `A.size()`（`size_t`）比较有编译警告，建议 `(int)A.size()`。
7. **末轮冗余平方**：最高位处理完后 `tmp` 的平方不再使用，可加 `if (k)` 判断省去一次 $O(n^3)$ 乘法。
8. **行末空格**：每行末尾多一个空格，宽松判题器可过，严格题需改为"首元素外均前置空格"的写法。

## 九、适用场景

- **线性递推加速**：斐波那契数列、线性常系数递推数列的第 $n$ 项（$n$ 达 $10^{18}$），构造转移矩阵后用矩阵快速幂求解
- **图论中的路径计数**：邻接矩阵的 $k$ 次幂表示恰好走 $k$ 步从 $i$ 到 $j$ 的路径数
- **状态压缩 DP 优化**：某些状态转移可写成矩阵形式，用矩阵快速幂加速
- **模意义下的矩阵逆**：$A^{-1} = A^{\text{mod}-2}$（当 $A$ 可逆且 mod 为质数时）

## 十、与数的快速幂对比

| 维度 | 数的快速幂 | 矩阵快速幂 |
|------|-----------|-----------|
| 计算对象 | 整数 $a^k$ | 方阵 $A^k$ |
| 单位元 | 1（标量） | $I$（单位矩阵） |
| 乘法 | 整数乘法 $O(1)$ | 矩阵乘法 $O(n^3)$ |
| 总复杂度 | $O(\log k)$ | $O(n^3 \log k)$ |
| 取模 | 每步 `% mod` | 每步 `% mod`（内层循环） |
| 正确性基础 | 乘法结合律 | 矩阵乘法结合律 |
| 典型应用 | 模逆元、费马小定理 | 线性递推加速、路径计数 |$AKB313$, '数学', array['数学', '矩阵', '快速幂', '线性递推', '矩阵乘法'], 'col-math-matrix-multiplication', null, 'knowledge'),
('Fohen', 'col-math-miller-rabin--fenfeng', 'Miller–Rabin 素性测试 · Fohen', $AKB314$## 算法原理

Miller–Rabin 素性测试解决的是"判断一个很大的整数 $n$ 是否为质数"的问题。试除法要从 $2$ 试到 $\sqrt{n}$，复杂度 $O(\sqrt{n})$，当 $n$ 达到 $10^{18}$ 级别时约需 $10^9$ 次运算，已经非常吃力；对更大的数（如密码学中几百上千位的大整数）更是完全不可行。因此需要一种**不枚举因子**的高效素性测试。

**出发点：费马小定理**。若 $p$ 是质数且 $\gcd(a,p)=1$，则

$$
a^{p-1} \equiv 1 \pmod{p}
$$

等价形式（对任意整数 $a$）是 $a^p \equiv a \pmod{p}$。

费马小定理给出的是质数的**必要条件**：如果 $n$ 是质数，那么对任意与 $n$ 互质的 $a$，$a^{n-1} \equiv 1 \pmod{n}$ 一定成立。由此容易想到一个判定方向：随机选底数 $a$，若 $a^{n-1} \not\equiv 1 \pmod{n}$，则 $n$ **一定是合数**（这一步永远正确）；若 $a^{n-1} \equiv 1 \pmod{n}$，则暂时认为 $n$ "可能是质数"。

但这条路走不通——**费马小定理的逆命题是假的**：存在合数 $n$（称为**卡迈克尔数**，Carmichael number），使所有与 $n$ 互质的 $a$ 都满足 $a^{n-1} \equiv 1 \pmod{n}$，于是"费马测试"会被这类合数彻底骗过。仅靠费马小定理无法区分质数与卡迈克尔数。

**Miller–Rabin 的关键加强：利用质数下平方根的唯一性**。设 $p$ 是奇质数，则模 $p$ 意义下方程

$$
x^2 \equiv 1 \pmod{p}
$$

只有两个解 $x \equiv 1$ 与 $x \equiv -1 \pmod{p}$。原因是 $p \mid (x^2-1)=(x-1)(x+1)$，而 $p$ 是质数，故 $p \mid (x-1)$ 或 $p \mid (x+1)$。也就是说，在质数模下，$1$ 的平方根**只能是 $\pm 1$**，不可能出现"某个既不是 $1$ 也不是 $-1$ 的数，平方之后却变成 $1$"。

这个性质给了我们一个更强的"戳穿合数"的手段。把 $n-1$（$n$ 为奇质数时是偶数）写成

$$
n-1 = d \cdot 2^r, \quad d\ \text{为奇数},\ r \ge 1
$$

并考察序列

$$
a^d,\ a^{2d},\ a^{4d},\ \dots,\ a^{2^r d} = a^{n-1} \pmod{n}
$$

如果 $n$ 是质数，由费马小定理 $a^{n-1} \equiv 1$，那么从后往前"不断开平方"，这个序列要么第一项就是 $1$，要么在某一步得到 $-1$、之后一路平方到 $1$。反过来，若序列既不满足"首项为 $1$"，也不满足"中途出现过 $-1$"，则 $n$ 必然是合数。

于是 Miller–Rabin 对单个底数 $a$ 做：先算 $x = a^d \bmod n$，再反复平方最多 $r$ 次，随时检查是否出现"非 $\pm 1$ 的数平方后变成 $1$"、或"一路平方到 $a^{n-1}$ 都没出现 $1$ / $-1$"这类异常；一旦出现就能断言 $n$ 是合数，否则认为 $n$ 通过这一轮检测。

**它是概率性算法，但错误是单边的**：若 $n$ 是质数，Miller–Rabin 对任何底数都**一定**判定为"质数"（永远不会把质数误判为合数）；若 $n$ 是合数，它可能以很小的概率误判为"质数"。对奇数合数，单个底数误判通过的概率不超过 $\dfrac{1}{4}$，于是取 $k$ 个独立底数后误判率不超过

$$
\left(\frac{1}{4}\right)^k
$$

只要 $k$ 稍大，错误率即可降到可以忽略。更进一步，对 $n < 2^{64}$ 范围内的整数，取固定的一组小底数（如 $\{2,3,5,7,11,13,17,19,23,29,31,37\}$）就能得到**确定性**的正确结果。正因为又准又快，Miller–Rabin 成为竞赛中判断大素数的事实标准。

## 核心公式 / 状态定义与转移方程

Miller–Rabin 不是动态规划，没有"状态定义与转移方程"，其核心是一组数论公式与判定条件。

### 费马小定理（出发点）

$$
a^{p-1} \equiv 1 \pmod{p} \qquad (p\ \text{为质数},\ \gcd(a,p)=1)
$$

### 质数下平方根的唯一性（关键加强）

$$
x^2 \equiv 1 \pmod{p} \implies x \equiv \pm 1 \pmod{p} \qquad (p\ \text{为奇质数})
$$

推导：$x^2 - 1 = (x-1)(x+1) \equiv 0 \pmod{p}$，因 $p$ 是质数，必有 $p \mid (x-1)$ 或 $p \mid (x+1)$。

### $n-1$ 的 2 分解

$$
n-1 = d \cdot 2^r, \qquad d\ \text{为奇数},\ r \ge 1
$$

### 检测序列

$$
a^d,\ a^{2d},\ a^{4d},\ \dots,\ a^{2^r d} = a^{n-1} \pmod{n}
$$

### 判定条件

对底数 $a$（$\gcd(a,n)=1$），若 $n$ 是奇质数，则必有

$$
a^d \equiv 1 \pmod{n} \quad \text{或} \quad \exists\, i \in \{0,1,\dots,r-1\},\ a^{2^i d} \equiv -1 \pmod{n}
$$

否则 $n$ 必为合数。

### 错误率

$$
P(\text{合数通过单轮检测}) \le \frac{1}{4}, \qquad P(\text{合数通过 } k \text{ 轮}) \le \left(\frac{1}{4}\right)^k
$$

## 逐行代码解析

资料中没有给出可运行的完整代码，以下按模块给出伪代码，说明 Miller–Rabin 的实现骨架。三个模块依次为：模意义快速幂、单底数检测、多底数确定化判定。

### 模块一：模意义快速幂（powmod）

```text
// 计算 a^b mod m，是 Miller–Rabin 每个底数检测的底层运算
function powmod(a, b, m):
    result = 1
    a = a mod m
    while b > 0:
        if b 为奇数:
            result = mulmod(result, a, m)   // 用 mulmod / __int128 防 result*a 溢出
        a = mulmod(a, a, m)
        b = b >> 1                          // 指数右移，对应二进制拆分
    return result
```

- 快速幂把指数按二进制拆分，复杂度为 $O(\log b)$ 次模乘；每轮 Miller–Rabin 调用一次 `powmod(a, d, n)`，其中 $d \le n-1$。
- 模乘 `result * a` 在 $n$ 接近 $64$ 位上限时中间结果可能溢出，需用 `__int128` 或"快速乘（mulmod）"承载（见「常见陷阱与注意事项」）。
- `b 为奇数` 用位运算 `b & 1` 判断，`b >> 1` 即整数除以 $2$。

### 模块二：单底数 Miller–Rabin 检测

```text
// 对底数 a 检测 n：返回 false 说明 n 一定是合数，返回 true 说明 n 可能为质数
function millerRabin(n, a):
    if n 能被 a 整除:
        return (n == a)               // 只有 n 恰好等于底数 a 本身时才"可能是质数"
    把 n - 1 写成 d * 2^r，其中 d 为奇数   // n 为奇质数时 n-1 是偶数，r >= 1
    x = powmod(a, d, n)               // 序列首项 a^d
    if x == 1 或 x == n - 1:
        return true                   // 首项即 1 或 -1，本轮通过
    for i = 1 .. r - 1:               // 反复平方，最多 r-1 次
        x = x * x mod n
        if x == n - 1:
            return true               // 中途平方得到 -1，本轮通过
        if x == 1:
            return false              // 非 ±1 的数平方后变成 1，n 必为合数
    return false                      // 直到 a^(n-1) 都没出现 1 或 -1，n 必为合数
```

- 核心不变量：质数模下 $x^2 \equiv 1$ 只有 $x \equiv \pm 1$，因此"非 $\pm 1$ 的数平方后变成 $1$"在质数下不可能发生，一旦发生即可断言合数。
- `d * 2^r` 分解：把 $n-1$ 的因子 $2$ 全部提出来，得到奇数 $d$ 与次数 $r$；例如 $n=73$ 时 $n-1=72=9\times 2^3$，即 $d=9,\ r=3$。
- 首项 $a^d \equiv 1$ 或中途出现 $n-1$（即 $-1$）都算通过；既无 $1$ 也无 $-1$ 而一路平方到 $a^{n-1}$，等价于不满足费马小定理，必为合数。

### 模块三：多底数确定化判定（isPrime）

```text
// 对 64 位范围内整数做确定性判定：取固定底数集，全部通过才判为质数
function isPrime(n):
    if n < 2:
        return false                  // 1 既不是质数也不是合数
    if n 是 {2,3,5,7,11,13,17,19,23,29,31,37} 之一:
        return true
    if n 为偶数:
        return false                  // 大于 2 的偶数必为合数
    for a in {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}:
        if millerRabin(n, a) == false:
            return false              // 任一底数戳穿 → 合数
    return true                       // 全部通过 → 质数
```

- 概率算法"确定化"：对 $n < 2^{64}$，用上述 $12$ 个小底数做固定检测即可得到严格正确的结果，无需真随机；这是竞赛中常用的确定性结论。
- 误判率来自"单底数下合数通过检测的概率不超过 $\dfrac{1}{4}$"，$k$ 个独立底数后不超过 $\left(\dfrac{1}{4}\right)^k$，可忽略不计。
- 前置特判先处理 $n < 2$、偶数、以及 $n$ 本身就是小质数的情况，既避免进入慢速的模幂循环，也避免对偶数做 $n-1$ 的 2 分解出错。

## 复杂度分析

| 维度 | 复杂度 | 说明 |
|---|---|---|
| 单轮检测（一个底数） | $O(\log^3 n)$ | 一次模幂做 $O(\log n)$ 次模乘，每次模乘 $O(\log^2 n)$ |
| $k$ 轮检测 | $O(k \log^3 n)$ | $k$ 为底数个数 |
| 空间 | $O(1)$ | 只维护若干变量（迭代快速幂无递归栈） |

补充说明：资料给出的"最优复杂度 $O(k \log^2 n \log\log n \log\log\log n)$"对应的是采用渐进更快的大整数乘法（如 FFT / Schönhage–Strassen，单次乘法 $O(\log n \log\log n \log\log\log n)$）时的理论界；常规竞赛实现使用 $O(\log^2 n)$ 的朴素乘法，故为 $O(k \log^3 n)$，二者并不矛盾。

与试除法对比：对 $n = 10^{18}$，试除约需 $\sqrt{10^{18}} = 10^9$ 次除法，而 Miller–Rabin（$k=12$）只需约 $12 \times (\log_2 10^{18})^3 \approx 12 \times 60^3 \approx 2.6 \times 10^6$ 次模乘量级，快了几个数量级。

## 适用场景

- **判断单个数或少量大整数是否为质数**，尤其是 $n$ 达 $10^{18}$ 甚至更大时（此时试除法不可行）。
- **密码学 / 哈希**：选取大质数模数、生成 RSA 等密钥时快速验证候选质数。
- **与筛法配合**：先用小筛法筛出小质数作底数或预处理，再用 Miller–Rabin 判定候选大数；或先 Miller–Rabin 快速筛，再用确定性方法复核。
- **不适用**：需要一次性筛出 $[1,n]$ 内所有素数（应改用埃氏筛 / 线性筛）；$n$ 很小（试除法更简单、常数更小）；要求绝对严格证明的场合（应改用 AKS 等确定性测试）。

## 常见陷阱与注意事项

1. **模乘溢出**：$n$ 达 $64$ 位时 `x * x % n` 的中间结果可能超出 `long long`，必须用 `__int128` 或"快速乘（mulmod）"承载，否则结果错误甚至误判。
2. **只用费马小定理不够**：若只检验 $a^{n-1} \equiv 1 \pmod{n}$，会被卡迈克尔数骗过；必须加上平方检测（核心加强）才能戳穿这类合数。
3. **底数不足**：只测 $a=2$ 等少量底数会漏判某些强伪素数；应使用固定底数集或随机多底数。
4. **小数特判**：$n<2$、$n=2$、偶数、以及 $n$ 恰好等于某个小底数本身的情况必须先特判，否则对偶数做 $n-1=d\cdot 2^r$ 分解或模幂会出错。
5. **单边错误性质**：Miller–Rabin 永不把质数判为合数，只会把合数误判为质数；理解这一点才能正确使用它（可先快速筛、再用确定性方法确认）。
6. **底数独立性**：$k$ 个底数需"独立"才使错误率不超过 $\left(\frac{1}{4}\right)^k$；实践中对 $2^{64}$ 内整数直接用固定底数集即可，无需真随机。

## 对比与扩展

**Miller–Rabin vs 试除法 vs 筛法**

| 方法 | 单次判定 | 预处理 | 适用 |
|---|---|---|---|
| 试除法 | $O(\sqrt{n})$ | 无 | $n$ 较小 |
| 埃氏筛 / 线性筛 | $O(1)$ 查询 | $O(n \log\log n)$ / $O(n)$ | 批量筛 $[1,n]$ |
| Miller–Rabin | $O(k \log^3 n)$ | 无 | 单个大数 |

- **费马测试 vs Miller–Rabin**：费马测试只查 $a^{n-1} \equiv 1$，会被卡迈克尔数骗过；Miller–Rabin 增加平方检测，能戳穿所有卡迈克尔数，故也称"强伪素数测试"。
- **确定性 vs 概率性测试**：确定性测试（试除法、AKS、Lucas–Lehmer、椭圆曲线素性证明）绝对准确但通常更慢；Miller–Rabin 是概率性测试（可用固定底数集确定化），是竞赛中判断大素数的事实标准。
- **扩展方向**：与 Pollard's Rho 等分解算法配合，先判定质数再分解合数；BPSW 测试是另一种实用的强伪素数测试；对超范围整数可进一步结合确定性质数证明。

一句话总结：Miller–Rabin 从费马小定理出发，用"质数模下 $1$ 的平方根只能是 $\pm 1$"这一更强性质戳穿卡迈克尔数，以 $O(k \log^3 n)$ 的代价、可忽略的错误率快速判断大整数是否为质数，是竞赛与密码学中判断大素数的事实标准。$AKB314$, '数学', array['数论', '素数', '素性测试', '费马小定理', '概率算法'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-miller-rabin--xesir', '素性测试（试除法与 Miller-Rabin） · Xesir', $AKB315$## 算法原理

先来做个小游戏——

**请你快速判断：73 是质数吗？**

你可能在脑子里飞快地试了试：2 不行，3 不行（7+3=10，不是 3 的倍数），5 不行，7 不行（7×10=70，余 3）……算到 $\sqrt{73} \approx 8.5$，发现都除不尽，于是得出结论：**73 是质数**。

好，那再问你：**114513 是质数吗？**

这时候你可能就不太想一个一个试了。那如果数字是 $10^{18}$ 级别的呢？如果给你 $10^5$ 个这样的数字要你判断呢？暴力试除法当场退役。

**素数**（也叫**质数**），就是只能被 1 和它本身整除的正整数。比如 2、3、5、7、11、13 都是素数，而 4、6、8、9 是合数。1 既不是素数也不是合数。

素数看起来定义很简单，但它在数论中的地位非同小可。所有大于 1 的整数都可以唯一地分解成若干个素数的乘积，这就是**算术基本定理**。换句话说，素数是构建所有整数的"基本粒子"。

### 试除法

最朴素的想法当然是**试除法**：从 2 试到 $\sqrt{n}$，看有没有能整除 $n$ 的。这里有一个明显的剪枝：如果 $n$ 有大于 $\sqrt{n}$ 的因子，那它一定对应一个小于 $\sqrt{n}$ 的因子，早就被发现了，因此不用特殊判断。

复杂度 $O(\sqrt n)$，一般情况下需要判断单一素数时，试除法已经够用。然而对于 $n$ 很大的情况（比如 $10^{18}$）试除法就显得太慢了，这时需要更高效的算法。

### 两类素性测试

一般的素性测试有两种：

- **确定性测试**：绝对确定一个数是否为素数。常见例子包括试除法、Lucas–Lehmer 测试和椭圆曲线素性证明。
- **概率性测试**：通常比确定性测试快很多，但有极小的概率错误地将合数识别为质数（但不会将质数识别为合数）。

竞赛中最常用的是 **Miller–Rabin 素性测试**，这是一种超快的素性测试，最优复杂度 $O(k \log^2 n \log\log n \log\log\log n)$，基于费马小定理的扩展。虽然是一种**概率性**算法，但通过多次检测可以把错误率降到可以忽略的程度。在实际竞赛中，Miller–Rabin 是判断大素数的事实标准。

> 这个比较复杂，原文暂且没讲（看大家意愿），所以下面只给出试除法的实现。

## 核心公式 / 状态定义与转移方程

**试除法能剪枝到 $\sqrt n$ 的依据**（因数成对出现）：

$$
n\ \text{是合数} \implies \exists\, d,\ 2 \le d \le \sqrt n,\ d \mid n
$$

也就是说，只要 $[2, \sqrt n]$ 里没有 $n$ 的因子，$n$ 就一定是素数。

**两种测试的区别**：确定性测试永远给对答案；概率性测试可能把合数误判为素数，但不会反过来。这个"单边错误"很重要——它保证了概率性测试**绝不会冤枉一个素数**。

## 逐行代码解析

### 模块一：试除法主体

```cpp
bool isPrime(long long n){
    if (n < 2) return false;              // 0 和 1 都不是素数
    for (long long i = 2; i * i <= n; i++)  // 只试到 sqrt(n)
        if (n % i == 0) return false;      // 找到一个因子就判合数
    return true;                           // 一个都没有，是素数
}
```

- `n < 2` 必须先判：`0`、`1` 都不是素数，负数更没有意义。
- 循环条件写 `i * i <= n` 而不是 `i <= sqrt(n)`，省掉浮点开方，也不会因为精度把边界算错。
- 一旦 `n % i == 0` 立刻返回，平均情况下远早于 $\sqrt n$ 就退出了；最坏情况（$n$ 是素数）才跑满整个循环。
- 这里用 `long long` 而不是 `int`，是为了让 `i * i` 在 $n$ 较大时不溢出。

### 模块二：可以补的两个小剪枝

```cpp
if (n % 2 == 0) return n == 2;              // 偶数：只有 2 是素数
for (long long i = 3; i * i <= n; i += 2)   // 只试奇数
    if (n % i == 0) return false;
```

- 先排掉所有偶数，之后步长取 2，循环次数直接减半。
- `return n == 2` 这个写法很省事：`n == 2` 返回 `true`，其它偶数返回 `false`。
- 再往上还可以只试 $6k \pm 1$ 形式的数（排掉 3 的倍数），不过常数优化到头也就那样，瓶颈还是在 $O(\sqrt n)$ 本身。

## 复杂度分析

| 方法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 试除法（单个 $n$） | $O(\sqrt n)$ | $O(1)$ |
| 试除法 + 只试奇数 | $O(\sqrt n)$（常数减半） | $O(1)$ |
| 埃氏筛 / 线性筛（批量到 $n$） | $O(n \log\log n)$ / $O(n)$ | $O(n)$ |
| Miller–Rabin（$k$ 个底数） | 最优 $O(k \log^2 n \log\log n \log\log\log n)$ | $O(1)$ |

试除法判断单个数的复杂度是 $O(\sqrt n)$：$n = 10^{18}$ 时要试 $10^9$ 次，基本没戏；而 Miller–Rabin 只需要几十次模幂。

## 适用场景

- **判断单个 / 少量数是不是素数**：$n$ 在 $10^{12}$ 以内，试除法完全够用。
- **批量判断**：要判断很多个数时，改用埃氏筛或线性筛预处理，单次查询 $O(1)$。
- **大整数素性测试**：$n$ 到 $10^{18}$ 甚至更大，用 Miller–Rabin。
- **哈希冲突规避**：用大质数当模数可以减少冲突概率。
- **密码学**：RSA 等加密算法的基础就是大质数的分解难度。

## 常见陷阱与注意事项

1. **`i * i` 溢出**：`i` 是 `int` 且 $n$ 接近 $2^{31}$ 时，`i * i` 会变成负数，循环直接失控。用 `long long`，或者写 `i <= n / i`。
2. **忘了判 `n < 2`**：`0` 和 `1` 会被判成素数，这是最经典的 WA 点。
3. **只试到 $n/2$**：虽然也对，但白白多跑了一倍的量级，没有利用"因数成对"的性质。
4. **Miller–Rabin 是概率性的**：单底数下合数有不超过约 $\frac{1}{4}$ 的概率蒙混过关，所以要取多个底数；而且要记住它只会"把合数误判成素数"，不会反过来。
5. **试除法处理 $10^{18}$ 会 T**：别指望它在 $10^{18}$ 上跑得过，这时候该换 Miller–Rabin 或 Pollard-Rho。
6. **`sqrt` 的精度**：`i <= sqrt(n)` 在 $n$ 是完全平方数附近可能差一，所以用 `i * i <= n` 更稳。$AKB315$, '数学', array['数学', '数论', '素数', '素性测试', 'Miller-Rabin'], 'col-hub-math-number-theory', null, 'knowledge'),
('Fohen', 'col-math-modular-arithmetic--fenfeng', '模运算相关算法 · Fohen', $AKB316$## 算法原理

模运算（modular arithmetic）即**取余**运算。给定整数 $a$ 与正整数 $n$，存在唯一的余数 $r$ 与整数 $q$，使得

$$a = q \cdot n + r, \quad 0 \le r < n$$

记 $a \bmod n = r$，称 $r$ 为 $a$ 除以 $n$ 的**最小非负余数**。C++ 中写作 `a % n`，但 C++ 的 `%` 结果符号与被除数一致（向零取整），而数学上通常只关心非负余数，二者在负数上并不一致。

一个直观的例子：今天是星期三，问 $5$ 天后是星期几。因为 $3 + 5 = 8$，$8 \bmod 7 = 1$，所以是星期一。若问 $1145$ 天后，只需算 $1145 \bmod 7$ 即可，无需反复减 $7$。

模运算之所以重要，是因为竞赛题经常要求结果对某个大数（如 $10^9 + 7$）取模。在模意义下，**加、减、乘**都可以"先取模、再运算、最后再取模"，唯独**除法**不能直接把分子分母分别取模后相除，而必须借助**模逆元**。

围绕模运算，延伸出一整套数论算法，本文按依赖顺序展开：

1. **同余与基本运算**：同余的定义、性质，以及模意义下加减乘的恒等变形。
2. **模逆元**：模意义下做除法的核心工具。
3. **裴蜀定理与扩展欧几里得（EXGCD）**：解线性同余方程与不定方程，并求逆元。
4. **费马小定理与欧拉定理**：快速求逆元与"降幂"。
5. **中国剩余定理（CRT）**：解一元线性同余方程组。
6. **BSGS 与原根**：解高次同余方程，以及 NTT 等进阶应用的基础。

## 核心公式

### 2.1 同余与基本运算

若 $a \bmod n = b \bmod n$，称 $a$ 与 $b$ 模 $n$ **同余**，记作

$$a \equiv b \pmod{n}$$

等价于 $n \mid (a - b)$。同余关系满足自反性、对称性、传递性，并在加减乘与幂运算下**保持**：

$$a \equiv b,\ c \equiv d \pmod{m} \implies a+c \equiv b+d,\ a-c \equiv b-d,\ ac \equiv bd,\ a^k \equiv b^k \pmod{m}$$

模意义下加减乘的恒等式：

$$(a + b) \bmod m = \big((a \bmod m) + (b \bmod m)\big) \bmod m$$

$$(a - b) \bmod m = \big((a \bmod m) - (b \bmod m) + m\big) \bmod m$$

$$(a \times b) \bmod m = \big((a \bmod m) \times (b \bmod m)\big) \bmod m$$

减法式中先加 $m$ 是为了把负数"抬"回非负范围。

### 2.2 模逆元

若存在整数 $x$ 使 $a \cdot x \equiv 1 \pmod{m}$，称 $x$ 为 $a$ 模 $m$ 的**逆元**，记作 $a^{-1} \pmod{m}$。逆元存在的充要条件是 $\gcd(a, m) = 1$。有了逆元即可做除法：

$$a / b \equiv a \cdot b^{-1} \pmod{m}$$

常用求法：

- **费马小定理**（$m$ 为质数）：$a^{-1} \equiv a^{m-2} \pmod{m}$。
- **扩展欧几里得**（不要求 $m$ 为质数）：解 $ax + my = 1$ 得 $x$。
- **线性递推**（$m$ 为质数，批量求 $1 \sim n$ 的逆元）：$inv[i] = m - (m / i) \cdot inv[m \bmod i] \bmod m$。

### 2.3 裴蜀定理

对不全为零的整数 $a, b$，一定存在整数 $x, y$ 使

$$ax + by = \gcd(a, b)$$

反过来，方程 $ax + by = c$ 有整数解**当且仅当** $\gcd(a, b) \mid c$。这一结论是判断不定方程与线性同余方程是否有解的直接依据。

### 2.4 扩展欧几里得的递推

由 $\gcd(a, b) = \gcd(b, a \bmod b)$ 且 $a \bmod b = a - \lfloor a/b \rfloor \cdot b$，代入整理得：

$$x_1 = y_2, \quad y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2$$

边界为 $b = 0$ 时 $\gcd(a, 0) = a$，此时 $x = 1, y = 0$。

### 2.5 费马小定理与欧拉定理

费马小定理：设 $p$ 为质数且 $\gcd(a, p) = 1$，则

$$a^{p-1} \equiv 1 \pmod{p}$$

等价形式（不要求互质，对所有整数成立）：

$$a^p \equiv a \pmod{p}$$

欧拉定理（费马小定理的推广）：设 $\gcd(a, m) = 1$，则

$$a^{\varphi(m)} \equiv 1 \pmod{m}$$

用于"降幂"：当 $\gcd(a, m) = 1$ 时 $a^b \equiv a^{b \bmod \varphi(m)} \pmod{m}$。若不互质，可用**扩展欧拉定理**（当 $b \ge \varphi(m)$）：

$$a^b \equiv a^{\,b \bmod \varphi(m) + \varphi(m)} \pmod{m}$$

### 2.6 中国剩余定理（CRT）

求解方程组 $x \equiv a_i \pmod{m_i}$（$m_i$ 两两互质）。令 $M = \prod m_i$，$M_i = M / m_i$，$t_i \equiv M_i^{-1} \pmod{m_i}$，则

$$x \equiv \sum_{i=1}^{k} a_i \, M_i \, t_i \pmod{M}$$

### 2.7 BSGS 与原根

BSGS 求 $a^x \equiv b \pmod{p}$（$a \perp p$）的最小非负解：令 $m = \lfloor\sqrt{p}\rfloor$，$x = im - j$，转化为

$$(a^m)^i \equiv b \cdot a^j \pmod{p}$$

分"小步"枚举 $j$ 建表、"大步"枚举 $i$ 查表。原根：若 $g$ 模 $n$ 的阶恰为 $\varphi(n)$，则称 $g$ 为 $n$ 的原根。

## 逐行代码解析

本节给出各算法的**伪代码 / 思想步骤**，与任何具体 `.cpp` 实现无关。

### 3.1 模意义下的加减乘

```cpp
add(a, b, m) = ((a % m) + (b % m)) % m          // 加法：先取模再相加取模
sub(a, b, m) = ((a % m) - (b % m) + m) % m      // 减法：加 m 保证结果非负
mul(a, b, m) = (1LL * (a % m) * (b % m)) % m    // 乘法：中间转 long long 防溢出
```

### 3.2 快速幂（求 $a^b \bmod m$）

```cpp
fastpow(a, b, m):
    ans = 1, base = a % m
    while b > 0:
        if b & 1: ans = ans * base % m   // 当前二进制位为 1 就乘入
        base = base * base % m           // 底数平方倍增
        b >>= 1                          // 处理下一个二进制位
    return ans
```

### 3.3 扩展欧几里得（EXGCD）

```cpp
exgcd(a, b):
    若 b == 0: return (a, 1, 0)          // 边界：gcd(a,0)=a，解 x=1,y=0
    (d, x2, y2) = exgcd(b, a % b)        // 递归求解子问题
    x1 = y2
    y1 = x2 - (a / b) * y2               // 递推更新
    return (d, x1, y1)
```

返回 $d = \gcd(a, b)$，且满足 $a x_1 + b y_1 = d$。

### 3.4 费马小定理求逆元（$m$ 为质数）

```cpp
inv(a, m) = fastpow(a, m - 2, m)   // a^{-1} ≡ a^{m-2} (mod m)
```

### 3.5 中国剩余定理（CRT）

```cpp
crt(a[1..k], m[1..k]):              // m[i] 两两互质
    M = m[1] * m[2] * ... * m[k]    // 模数乘积
    res = 0
    for i = 1..k:
        Mi = M / m[i]               // 除 m[i] 外其余模数的乘积
        ti = inv(Mi, m[i])          // Mi 在模 m[i] 下的逆元
        res = (res + a[i] * Mi % M * ti % M) % M
    return res
```

### 3.6 BSGS

```cpp
bsgs(a, b, p):                       // 求 a^x ≡ b (mod p) 的最小非负解，a ⊥ p
    m = ceil(sqrt(p))
    for j = 0 .. m-1:                // Baby step：小步建表
        记录 (b * a^j mod p, j)，重复时取更大的 j
    for i = 1 .. m:                  // Giant step：大步查表
        t = (a^m)^i mod p
        若 t 在表中，return i * m - 表值
    return -1                        // 无解
```

### 3.7 原根判断（$p$ 为质数）

```cpp
is_primitive_root(a, p):
    若 fastpow(a, p-1, p) != 1: return false          // 不满足费马小定理
    对 p-1 的每个质因子 q:
        若 fastpow(a, (p-1)/q, p) == 1: return false  // 阶更小，非原根
    return true
```

## 复杂度分析

本知识点涵盖多个独立算法，整体无统一复杂度；各算法单独如下：

| 算法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 模加减乘 | $O(1)$ | $O(1)$ |
| 快速幂 / 费马小定理求逆元 | $O(\log m)$ | $O(1)$ |
| 扩展欧几里得 | $O(\log\min(a, b))$ | $O(\log\min(a, b))$（递归栈） |
| 线性递推求 $1 \sim n$ 逆元 | $O(n)$ | $O(n)$ |
| 中国剩余定理 CRT | $O(k \log M)$ | $O(1)$（不含输入数组） |
| 扩展 CRT（exCRT） | $O(k \log m)$ | $O(1)$ |
| BSGS | $O(\sqrt{p})$ | $O(\sqrt{p})$（哈希表） |
| 原根判断 | $O(\sqrt{p} \log p)$ | $O(1)$ |

## 适用场景

- **模意义四则运算**：竞赛中答案对 $10^9+7$ 等大数取模时，加减乘直接按恒等式变形，除法转为乘逆元。
- **组合数 / 分数取模**：$C(n, k) = n!/(k!(n-k)!)$ 取模时，预处理阶乘及其逆元，实现 $O(1)$ 查询。
- **解线性同余方程 / 不定方程**：$ax \equiv b \pmod{m}$ 或 $ax + by = c$ 用 EXGCD 判断有解并求特解（依据裴蜀定理）。
- **解同余方程组**：模数两两互质用 CRT，不互质用 exCRT。
- **解高次同余方程**：$a^x \equiv b \pmod{p}$（$a \perp p$）用 BSGS，是离散对数问题的基础解法。
- **NTT 与原根**：快速数论变换需要模数的原根，离散对数相关问题也依赖"阶"与"原根"的概念。

## 常见陷阱与注意事项

1. **负数取模**：C++ 中 `-3 % 5 == -3`，而数学期望得到 $2$。规范写法是 `(x % m + m) % m` 保证非负。
2. **除法不能直接取模**：$\dfrac{a}{b} \bmod m$ 不能写成 $\dfrac{a \bmod m}{b \bmod m}$，必须乘逆元 $a \cdot b^{-1} \bmod m$，且要求 $\gcd(b, m) = 1$。
3. **费马小定理求逆元要求模数为质数**：模数为合数时 $a^{m-2}$ 未必等于 $a^{-1}$，应改用欧拉定理或 EXGCD（都要求 $\gcd(a, m) = 1$）。
4. **防溢出**：两个接近 $m$ 的数相乘可能超过 `int` 上限，中间结果需用 `long long`。
5. **CRT 要求模数两两互质**：不满足时用 exCRT 通过两两合并处理，合并中可能出现无解（$\gcd$ 不整除差时），需特判。
6. **BSGS 要求 $a \perp p$**：不互质时算法失效，需用扩展 BSGS（先约去 $\gcd$ 再求解）。
7. **原根存在条件**：正整数 $n$ 有原根当且仅当 $n$ 为 $1, 2, 4$、$p^e$ 或 $2p^e$（$p$ 为奇质数，$e$ 为正整数），并非所有模数都有原根。
8. **降幂的前提**：$\gcd(a, m) = 1$ 时才有 $a^b \equiv a^{b \bmod \varphi(m)} \pmod{m}$；不互质时改用扩展欧拉定理，并注意其成立条件 $b \ge \varphi(m)$。

## 对比与扩展

### 7.1 三种求逆元方法对比

| 方法 | 条件 | 时间复杂度 | 适用 |
|---|---|---|---|
| 费马小定理 + 快速幂 | $m$ 为质数 | $O(\log m)$ | 竞赛最常见（模数多为质数） |
| 欧拉定理 + 快速幂 | $\gcd(a,m)=1$ | $O(\sqrt{m} + \log m)$ | 合数模，需先求 $\varphi(m)$ |
| 扩展欧几里得 | $\gcd(a,m)=1$ | $O(\log m)$ | 合数模，或需同时求 GCD |

### 7.2 费马小定理与欧拉定理的关系

费马小定理是欧拉定理的**特例**：当 $m$ 为质数 $p$ 时 $\varphi(p) = p - 1$，欧拉定理 $a^{\varphi(p)} \equiv 1 \pmod{p}$ 即退化为 $a^{p-1} \equiv 1 \pmod{p}$。两者证明思路相同——对剩余系整体乘以 $a$，比较乘积后约去与模数互质的部分。

### 7.3 欧拉定理与扩展欧拉定理

欧拉定理只适用于 $\gcd(a, m) = 1$；扩展欧拉定理去掉了互质要求，代价是需要判断 $b$ 与 $\varphi(m)$ 的大小关系。在处理指数极长（如 $10^{100000}$）的降幂问题时，扩展欧拉定理是通用工具。

### 7.4 CRT 与 exCRT

| 维度 | CRT | exCRT |
|---|---|---|
| 前提 | 模数两两互质 | 无互质要求 |
| 方法 | 直接套公式（逆元 + 累加） | 两两合并，用 EXGCD 解线性同余 |
| 复杂度 | $O(k \log M)$ | $O(k \log m)$ |
| 无解 | 不存在（互质必有解） | 可能无解（合并时 $\gcd$ 不整除） |

### 7.5 BSGS 与原根的进一步扩展

- **扩展 BSGS**：当 $\gcd(a, p) \neq 1$ 时，先对两边约去公因子，转化为互质情形再套 BSGS。
- **原根与 NTT**：快速数论变换要求模数 $p$ 存在原根（常见如 $998244353$，原根为 $3$），利用原根的幂次可构造单位根替代复数域上的 FFT。
- **离散对数**：BSGS 是离散对数问题的分块解法，与"原根 / 阶"的概念一起，构成了有限域上对数运算的基础。

### 7.6 实现细节：解界、同余方程、BSGS 与原根求法

几个容易被忽略、却能避免爆 `long long` 或死循环的实现细节：

- **EXGCD 解界**：方程 $ax + by = \gcd(a, b)$ 由 EXGCD 直接返回的特解满足 $|x| \le b$、$|y| \le a$（对正数 $a, b$），量级不超过输入规模，中途一般不爆 `long long`；但解线性同余方程时若再乘上 $c/\gcd(a,b)$，量级会被放大，需注意。
- **线性同余方程 $ax \equiv b \pmod{m}$ 的模数缩放**：若 $g = \gcd(a, m) > 1$ 且 $g \mid b$，方程等价于 $(a/g)\,x \equiv (b/g) \pmod{m/g}$，共 $g$ 组模 $m$ 的解。不要拿原始模数 $m$ 直接套特解，否则会漏解或错解。
- **BSGS 归一化与特判**：先 `a %= p`（当 $a \equiv 0 \pmod{p}$ 时仅 $b \equiv 0$ 有解 $x = 1$，$b \not\equiv 0$ 无解）；且 $b \equiv 1 \pmod{p}$ 时最小解就是 $0$，应直接返回，避免由 `i*m - j` 反推出 $0$ 之外的伪解。
- **原根的求法**：先枚举求**最小原根** $g$，再由它生成全部原根——当 $g$ 为原根时，$g^k$ 是原根当且仅当 $\gcd(k, \varphi(p)) = 1$，故原根总数为 $\varphi(\varphi(p))$（$p$ 为质数时即 $\varphi(p-1)$）。

```
// 求最小原根 + 全部原根（p 为质数）
g = 使 is_primitive_root(g, p) 成立的最小正整数      // 用 3.7 的判断
for k = 1 .. p-1:
    若 gcd(k, p-1) == 1: 收集 g^k mod p 为一个原根   // 共 φ(p-1) 个
```

一句话总结：模运算是 OI 数论的公共语言——加减乘可自由变形，除法借逆元实现；逆元、EXGCD、费马 / 欧拉定理、CRT、BSGS 与原根分别解决了模意义下"做除法、解方程、解方程组、求对数"等核心问题。$AKB316$, '数学', array['数学', '数论', '模运算', '同余', '逆元'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-modular-arithmetic--xesir', '模运算相关算法及应用 · Xesir', $AKB317$## 算法原理

不要觉得模运算离我们很远——

比如：如果今天是**星期三**，问 **$5$** 天后是**星期几**？

**~~星期八~~** 显然不是。~~我们小学二年级就知道~~ 我们通常会这么算——$3+5-7=1$，所以是**星期一**。

但如果今天是**星期三**，问 **$1145$** 天后是**星期几**？~~细节1145~~

显然 $3+1145-7-7-7-7-7-7\dots$ 极其麻烦~~勾都不用~~。那聪明的小盆友就要说了：“用 $(3+1145)/7$ 得到的余数不就是答案了吗？”（当然此处如果能整除（即余数为 $0$）是星期日）

十分正确！这正是 ==**模运算**== ！但是如何用数学语言表示呢？

### 模运算概念及性质

模运算即**取余**，是我们小学二年级就学过的~~简单~~运算，就是取整数 $\frac{a}{b}$ 的余数。具体的，若 $r$ 满足 $0\le r<n$ 且存在整数 $q$ 使得 $q\times n+r=a$，则 $a \bmod n=r$，在 C++ 中可写作 `%`。

看起来很简单的概念，但它延伸出了大量定理与算法，最后成为 OI 数学以至数论中**不可或缺的一部分**。

#### 1. 同余

如果 $a \bmod n=b \bmod n$，则称 $a$ 与 $b$ 模 $n$ 同余，记作 $a \equiv b \pmod{m}$，等价于 $n\mid(a-b)$（这里 $a\mid b$ 表示 $a$ 能整除 $b$，或者说 $b$ 能被 $a$ 整除）。

同余有一些 **~~奇妙~~性质**：

- 自反性：$a \equiv a \pmod{m}$
- 对称性：若 $a \equiv b \pmod{m}$，则 $b \equiv a \pmod{m}$
- 传递性：若 $a \equiv b \pmod{m}$ 且 $c \equiv b \pmod{m}$，则 $a \equiv c\pmod{m}$
- 运算保持性：若 $a \equiv b \pmod{m}$，$c \equiv d \pmod{m}$，则：

$$
a+c \equiv b+d \pmod{m}
$$

$$
a-c \equiv b-d \pmod{m}
$$

$$
a \cdot c \equiv b\cdot d \pmod{m}
$$

$$
a^k \equiv b^k \pmod{m}
$$

这些性质说明：**同余关系在加减乘和幂运算下都能“保持”**，这让我们可以在模意义下放心地做各种代数变形。

#### 2. 模运算的基本运算

在 C++ 中，`%` 只对整数有效，而且结果的正负与被除数一致（C++ 的取余是向零取整）。但在数学上，我们通常只关心 **最小非负余数**，即 $0 \le r < m$。

**加、减、乘**都很直接：

$$
(a + b) \bmod m = ((a \bmod m) + (b \bmod m)) \bmod m
$$

$$
(a - b) \bmod m = ((a \bmod m) - (b \bmod m) + m) \bmod m
$$

$$
(a \times b) \bmod m = ((a \bmod m) \times (b \bmod m)) \bmod m
$$

注意减法的处理：为了避免负数，通常先加一个 $m$ 再取模。

**除法**就没那么简单了——不能直接 $\frac{a}{b} \bmod m = \frac{a \bmod m}{b \bmod m}$，因为模意义下“除以一个数”需要用**逆元**来实现。

#### 3. 模逆元

在模 $m$ 意义下，如果存在整数 $x$ 使得 $a \times x \equiv 1 \pmod{m}$，则称 $x$ 是 $a$ 在模 $m$ 下的**逆元**，记作 $a^{-1} \pmod{m}$。有了逆元，就可以做除法了：$a / b \equiv a \times b^{-1} \pmod{m}$。

**逆元存在的条件**：$\gcd(a, m) = 1$（即 $a$ 与 $m$ 互质）。

**求逆元的常用方法**：

- **费马小定理**（当 $m$ 是质数时）：$a^{m-1} \equiv 1 \pmod{m}$，所以 $a^{-1} \equiv a^{m-2} \pmod{m}$，用快速幂算即可。
- **扩展欧几里得算法**（适用于 $m$ 不一定是质数）：解线性同余方程 $a \times x + m \times y = 1$，得到的 $x$ 就是逆元。
- **线性递推**（求 $1 \sim n$ 的逆元，$m$ 是质数）：$inv[i] = m - (m/i) \times inv[m \% i] \bmod m$，复杂度 $O(n)$，效率极高。

逆元在组合数取模、分数取模等问题中无处不在，是模运算的进阶核心。

#### 4. 几个常用的模运算小技巧

- **防溢出**：乘法时先转 `long long` 再取模。
- **负数取模**：在 C++ 中 `-3 % 5 = -3`，而数学上希望得到 $2$。所以一般写成 `(x % m + m) % m` 来保证非负。
- **同余幂的性质**：$a^k \bmod m$ 在 $k$ 很大时可以用快速幂，而且指数也可以先对 $\varphi(m)$ 取模（欧拉定理），前提是 $\gcd(a, m)=1$。

### 费马小定理与欧拉定理

> 神秘快速幂插件

**费马小定理定理内容**：设 $p$ 是质数，且 $\gcd(a, p) = 1$，则：

$$
a^{p-1} \equiv 1 \pmod{p}
$$

还有一个等价形式，**不要求 $a$ 与 $p$ 互质**，对所有整数 $a$ 都成立：

$$
a^p \equiv a \pmod{p}
$$

**证明**：构造序列 $A = \{1, 2, 3, \dots, p-1\}$，把它们都乘以 $a$ 再对 $p$ 取模，得到的还是 $1$ 到 $p-1$ 的一个排列。于是：

$$
1 \cdot 2 \cdots (p-1) \equiv (a \cdot 1)(a \cdot 2) \cdots (a \cdot (p-1)) \pmod{p}
$$

右边提取 $a^{p-1}$，两边约掉 $(p-1)!$（因为 $p$ 是质数，$(p-1)!$ 与 $p$ 互质），得到 $a^{p-1} \equiv 1 \pmod{p}$。

**最经典的应用：求逆元**。当模数 $p$ 是质数时，由费马小定理：

$$
a^{p-1} \equiv 1 \pmod{p} \quad \Longrightarrow \quad a \cdot a^{p-2} \equiv 1 \pmod{p}
$$

所以 $a$ 的逆元就是 $a^{p-2} \bmod p$。相比 EXGCD，费马小定理求逆元**代码更短**，但**限制更强**——模数必须是质数。

费马小定理还有个升级版：**欧拉定理**。设 $m$ 是任意正整数，$a$ 是与 $m$ **互质**的整数，即 $\gcd(a, m) = 1$，则：

$$
a^{\varphi(m)} \equiv 1 \pmod{m}
$$

其中 $\varphi(m)$ 就是欧拉函数。

特殊情况：如果 $m$ 是质数 $p$，那么 $\varphi(p) = p-1$，欧拉定理就退化为：

$$
a^{p-1} \equiv 1 \pmod{p}
$$

这不就是费马小定理吗？所以费马小定理是欧拉定理的**子集**。

**证明**：取模 $m$ 的**简化剩余系**（即所有与 $m$ 互质的剩余类），记作 $R = \{r_1, r_2, \dots, r_{\varphi(m)}\}$。把这堆数都乘以 $a$，再对 $m$ 取模，因为 $\gcd(a, m)=1$，所以得到的新集合仍然是同一个简化剩余系（只是顺序变了）。于是它们的乘积相等：

$$
r_1 r_2 \cdots r_{\varphi(m)} \equiv (a r_1)(a r_2) \cdots (a r_{\varphi(m)}) \pmod{m}
$$

右边提取 $a^{\varphi(m)}$，两边约掉 $\prod r_i$，就得到 $a^{\varphi(m)} \equiv 1 \pmod{m}$。证明过程和费马小定理几乎一模一样。

> 不想看跳了也行，又不考你证明

**作用一：求逆元（当模数不是质数时）**。如果 $\gcd(a, m) = 1$，由欧拉定理：

$$
a^{\varphi(m)} \equiv 1 \pmod{m} \quad \Longrightarrow \quad a \cdot a^{\varphi(m)-1} \equiv 1 \pmod{m}
$$

所以 $a$ 在模 $m$ 下的逆元就是 $a^{\varphi(m)-1} \bmod m$。

不过说实话，**实际做题时很少用这个公式求逆元**，因为需要先算 $\varphi(m)$，而 $\varphi(m)$ 的计算复杂度通常是 $O(\sqrt{m})$，对于单次还行，多次就不划算了。~~而且一般模都是质数。~~

**作用二：降幂（指数取模）**。这是欧拉定理最经典的应用之一。当底数 $a$ 与模数 $m$ 互质时，计算 $a^b \bmod m$，如果指数 $b$ 超级大（比如 $10^{100000}$），我们可以直接把指数对 $\varphi(m)$ 取模：

$$
a^b \equiv a^{b \bmod \varphi(m)} \pmod{m}
$$

因为 $b = q \cdot \varphi(m) + r$，$a^b = (a^{\varphi(m)})^q \cdot a^r \equiv 1^q \cdot a^r \pmod{m}$。

#### 扩展欧拉定理

如果 $\gcd(a, m) \ne 1$，上面的降幂公式不能直接用。但有个更强的版本（欧拉定理的“完全体”）：对于任意整数 $a$，当 $b \ge \varphi(m)$ 时：

$$
a^b \equiv a^{b \bmod \varphi(m) + \varphi(m)} \pmod{m}
$$

只需要判断大小关系即可，肥肠好用。~~证明我也看不懂，就不放了~~

### 原根

#### 定义

在模 $n$ 意义下，如果存在一个整数 $g$，使得 $g^1, g^2, \dots, g^{\varphi(n)}$ 模 $n$ 后恰好遍历所有与 $n$ 互质的数（即构成一个缩系），则称 $g$ 为 $n$ 的原根。

更形式化地说：$g$ 是 $n$ 的原根，当且仅当 $g$ 模 $n$ 的**阶**为 $\varphi(n)$。其中“阶”定义为使得 $g^k \equiv 1 \pmod{n}$ 成立的**最小正整数** $k$。

**例子**：$n = 7$，$\varphi(7) = 6$，取 $g = 3$：

$$
3^1 \equiv 3,\quad 3^2 \equiv 2,\quad 3^3 \equiv 6,\quad 3^4 \equiv 4,\quad 3^5 \equiv 5,\quad 3^6 \equiv 1 \pmod{7}
$$

最小回到 $1$ 的指数是 $6$，恰好等于 $\varphi(7)$，所以 $3$ 是模 $7$ 的原根。

可以看出，原根是一个“发生器”：从 $g^1$ 开始乘，直到乘了 $\varphi(n)$ 次才第一次回到 $1$，在此之前产生的所有余数**绝不重复**。

> 在 OI 中，我们通常只在 $n$ 为质数 $p$ 的情况下讨论原根。此时 $\varphi(p) = p-1$，所以 $g^0, g^1, \dots, g^{p-2}$ 模 $p$ 后恰好得到 $1$ 到 $p-1$ 的所有非零整数。

可以证明，一个正整数 $n$ 存在原根当且仅当其为 $1,2,4$ 或 $p^e$ 或 $2p^e$，其中 $p$ 为奇质数，$e$ 为正整数。在此不做过多解释，感兴趣可以自行查阅。

#### 性质

**性质一**：若 $k$ 是满足 $a^k \equiv 1 \pmod{n}$ 的最小正整数，且 $\gcd(a,n)=1$，则 $k \mid \varphi(n)$。这是判断原根的核心依据，即**最小周期一定整除 $\varphi(n)$**。

**性质二**：设 $g$ 是模质数 $p$ 的一个原根，则模 $p$ 的**所有原根**恰好是：

$$
g^k \bmod p \quad (1 \le k < p-1,\ \gcd(k, p-1) = 1)
$$

也就是说 $g$ 的幂次中，指数与 $p-1$ 互质的那些都是原根。

#### 判断

给定质数 $p$ 和整数 $a$，判断 $a$ 是否为 $p$ 的原根。

**第一步**：检查 $a^{p-1} \equiv 1 \pmod{p}$。如果不成立，直接判定不是原根。

**第二步**：枚举 $p-1$ 的所有质因子。对于每个质因子 $q$，检查：

$$
a^{(p-1)/q} \not\equiv 1 \pmod{p}
$$

如果对所有质因子 $q$ 都成立，则 $a$ 是原根。单次判断复杂度 $O(\sqrt{p} \log p)$（分解质因子 + 快速幂）。

#### 求所有原根

1. 求出 $p$ 的**最小原根** $g$：从 $2$ 开始枚举，对每个数用上述方法判断，第一个通过的就是最小原根。
2. 利用性质二，枚举 $k \in [1, p-2]$，若 $\gcd(k, p-1) = 1$，则 $g^k \bmod p$ 也是一个原根。
3. 排序后即为所有原根。

原根个数为 $\varphi(\varphi(p)) = \varphi(p-1)$。

## 核心公式

| 内容 | 公式 |
|---|---|
| 同余定义 | $a \equiv b \pmod{m} \iff m \mid (a-b)$ |
| 减法取模 | $((a \bmod m) - (b \bmod m) + m) \bmod m$ |
| 费马小定理 | $a^{p-1} \equiv 1 \pmod{p}$（$p$ 为质数，$\gcd(a,p)=1$） |
| 费马求逆元 | $a^{-1} \equiv a^{p-2} \pmod{p}$ |
| 欧拉定理 | $a^{\varphi(m)} \equiv 1 \pmod{m}$（$\gcd(a,m)=1$） |
| 欧拉降幂 | $a^b \equiv a^{b \bmod \varphi(m)} \pmod{m}$（$\gcd(a,m)=1$） |
| 扩展欧拉定理 | $a^b \equiv a^{b \bmod \varphi(m) + \varphi(m)} \pmod{m}$（$b \ge \varphi(m)$） |
| 原根判定 | 对所有 $q \mid (p-1)$ 且 $q$ 为质数，$a^{(p-1)/q} \not\equiv 1 \pmod{p}$ |

## 逐行代码解析

原文这一节只给了极短的调用片段，没有完整程序，所以这里贴的是“怎么用”的骨架。

### 费马小定理求逆元

```cpp
// 快速幂，一行带走
int inv = ksm(a, p - 2, p);
```

- `ksm` 是快速幂函数，返回 $a^b \bmod p$。
- 传入指数 `p - 2`，得到的就是 $a^{p-2} \bmod p$，也就是 $a$ 在模质数 $p$ 下的逆元。
- 调用前要保证 $p$ 是质数，且 `a % p != 0`；否则 `ksm` 会算出 $0$，而不是“无逆元”的信号。

### 线性递推求逆元

```cpp
// 求 1~n 的逆元，m 为质数
inv[i] = m - (m / i) * inv[m % i] % m;
```

- 按 $i$ 从小到大递推，`inv[1] = 1` 是边界。
- `m / i` 和 `m % i` 都是整数除法/取余，`m % i < i` 保证右边的逆元已经算过。
- 结果天然落在 $[1, m-1]$，不用再 `(x % m + m) % m`。

### 原根判定的核心循环

```cpp
for (int q : prime_factors_of(p - 1))
    if (ksm(a, (p - 1) / q, p) == 1) return false;
return true;
```

- 先分解 $p-1$ 的质因子（注意是**质**因子，不是所有因子）。
- 只要有一个 $q$ 让 $a^{(p-1)/q} \equiv 1$，说明 $a$ 的阶小于 $p-1$，不是原根。
- 全部通过才是原根；外层再从 $2$ 开始枚举，第一个通过的就是最小原根。

## 复杂度分析

这一节是概念 + 工具集合，复杂度要分工具看：

- 单次快速幂：$O(\log p)$。
- 费马小定理求单个逆元：$O(\log p)$。
- 线性递推求 $1 \sim n$ 的逆元：$O(n)$ 时间、$O(n)$ 空间。
- 计算单个 $\varphi(m)$：$O(\sqrt{m})$。
- 原根单次判断：$O(\sqrt{p} \log p)$（分解质因子 + 若干次快速幂）。
- 求最小原根：从 $2$ 开始枚举，最坏需要枚举若干个数，每次 $O(\sqrt{p}\log p)$；求出最小原根后再枚举 $k$ 生成全部原根，需要 $O(p \log p)$ 级别。

## 适用场景

- 题目要求答案对 $10^9+7$、$998244353$ 之类的质数取模，出现除法 → 费马小定理求逆元。
- 模数不是质数，但保证 $\gcd(a,m)=1$ → 扩展欧几里得求逆元；也可以用欧拉定理，但一般不划算。
- 指数大到读入都只能用字符串（如 $10^{100000}$）→ 欧拉降幂 / 扩展欧拉定理。
- 需要把模 $p$ 的非零剩余表示成某个数的幂（NTT 找原根、离散对数）→ 原根。
- 判断一个数是不是原根、求最小原根、求所有原根 → 阶 + 质因子判定。

## 常见陷阱

1. **C++ 的 `%` 不是数学取模**：`-3 % 5 == -3`，要写成 `(x % m + m) % m` 才是最小非负余数。
2. **除法不能直接取模**：$(a/b) \bmod m \ne (a \bmod m)/(b \bmod m)$，必须乘逆元。
3. **逆元存在的条件被忽略**：$\gcd(a,m) \ne 1$ 时逆元不存在，费马小定理和 EXGCD 都不能硬套。
4. **费马小定理要求模数是质数**：模数合数时 $a^{m-2}$ 不是逆元，这是最常见的 WA 来源之一。
5. **降幂公式用错版本**：$\gcd(a,m)=1$ 才能用 $a^b \equiv a^{b \bmod \varphi(m)}$；不互质时必须用扩展欧拉定理，并且要判断 $b \ge \varphi(m)$。
6. **原根判定枚举了所有因子**：只需要枚举 $p-1$ 的**质**因子；枚举合因子会误判。
7. **乘法溢出**：两个 $10^9$ 级别的数相乘会爆 `int`，先转 `long long` 再取模。

---
原根在 OI 中主要用于 NTT（快速数论变换）中寻找模数的原根，以及一些离散对数相关问题。理解“阶”和“周期”的概念，就能把握原根的本质。$AKB317$, '数学', array['数学', '数论', '模运算', '同余', '费马小定理', '欧拉定理', '原根', '逆元'], 'col-hub-math-number-theory', null, 'knowledge'),
('world-needs-sunday', 'col-math-modular-inverse', '模逆元（费马小定理 + 扩展欧几里得）', $AKB318$## 模逆元（费马小定理 + 扩展欧几里得）

## 一、算法原理

### 1.1 定义

在模 $q$ 意义下，$a$ 的**模逆元**（modular inverse）$a^{-1}$ 满足：

$$a \cdot a^{-1} \equiv 1 \pmod{q}$$

逆元存在的**充要条件**是 $\gcd(a, q) = 1$，即 $a$ 与 $q$ 互质。

**直觉理解**：在实数域中，$a$ 的倒数是 $1/a$，满足 $a \times (1/a) = 1$。模逆元就是模意义下的"倒数"——把除法转化为乘法。$a / b \bmod q$ 等价于 $a \times b^{-1} \bmod q$。

### 1.2 费马小定理

**费马小定理**：若 $p$ 为质数且 $\gcd(a, p) = 1$，则

$$a^{p-1} \equiv 1 \pmod{p}$$

两边同乘 $a^{-1}$：

$$a^{p-2} \equiv a^{-1} \pmod{p}$$

因此，当模数 $q$ 为**质数**时，$a^{-1} \equiv a^{q-2} \pmod{q}$，用快速幂在 $O(\log q)$ 内求出。

### 1.3 欧拉定理（一般情况）

当模数 $q$ **不一定为质数**时，用欧拉定理：

$$a^{\varphi(q)} \equiv 1 \pmod{q} \quad (\gcd(a, q) = 1)$$

因此 $a^{-1} \equiv a^{\varphi(q)-1} \pmod{q}$。

当 $q$ 为质数时 $\varphi(q) = q - 1$，退化为费马小定理。所以费马小定理是欧拉定理的特例。

### 1.4 扩展欧几里得法

逆元也可以通过求解方程 $ax + qy = 1$（$\gcd(a,q)=1$ 保证有解）来获得。用扩展欧几里得算法求出 $x$，则 $a^{-1} \equiv x \pmod{q}$。这种方法不要求 $q$ 为质数，只要求 $\gcd(a,q) = 1$。

### 1.5 三种方法对比

| 方法 | 条件 | 复杂度 | 代码难度 |
|------|------|--------|---------|
| 费马小定理 + 快速幂 | $q$ 为质数 | $O(\log q)$ | 简单 |
| 欧拉定理 + 快速幂 | $\gcd(a,q)=1$ | $O(\sqrt{q} + \log q)$（需先求 $\varphi(q)$） | 中等 |
| 扩展欧几里得 | $\gcd(a,q)=1$ | $O(\log q)$ | 中等 |

本代码实现的是**费马小定理 + 快速幂**法。

## 二、核心公式/状态定义与转移方程

### 2.1 核心公式

$$\boxed{a^{-1} \equiv a^{q-2} \pmod{q} \quad (q \text{ 为质数}, \gcd(a,q)=1)}$$

### 2.2 快速幂递推

将指数 $q - 2$ 按二进制分解，利用平方倍增：

$$a^b = \left(a^{b/2}\right)^2 \times (a \text{ if } b \text{ odd})$$

| 迭代 | 操作 | 含义 |
|------|------|------|
| `ans = 1` | 初始化 | 累积器 |
| `gap = a` | 初始化 | 当前平方基 |
| `if (b & 1) ans = ans * gap % q` | 奇数位 | 乘入当前基 |
| `gap = gap * gap % q` | 平方 | 基倍增 |
| `b >>= 1` | 右移 | 处理下一位 |

### 2.3 逆元函数的状态转移

```
inv(a, q):
  若 gcd(a, q) == 1 → 返回 fastpow(a, q-2, q)   // 费马小定理
  否则 → 返回 -1                                    // 逆元不存在
```

### 2.4 GCD 递推（欧几里得算法）

$$\gcd(a, b) = \gcd(b, a \bmod b), \quad \gcd(a, 0) = a$$

### 2.5 重要性质速查

| 性质 | 公式 | 条件 |
|------|------|------|
| 逆元定义 | $a \cdot a^{-1} \equiv 1 \pmod{q}$ | $\gcd(a,q)=1$ |
| 费马小定理 | $a^{q-2} \equiv a^{-1} \pmod{q}$ | $q$ 为质数 |
| 欧拉定理 | $a^{\varphi(q)-1} \equiv a^{-1} \pmod{q}$ | $\gcd(a,q)=1$ |
| 乘法转除法 | $a/b \equiv a \cdot b^{-1} \pmod{q}$ | $\gcd(b,q)=1$ |
| 逆元的逆元 | $(a^{-1})^{-1} \equiv a \pmod{q}$ | $\gcd(a,q)=1$ |
| 逆元可乘 | $(ab)^{-1} \equiv a^{-1} \cdot b^{-1} \pmod{q}$ | $\gcd(a,q)=\gcd(b,q)=1$ |
| 线性递推 | $i^{-1} \equiv -(q/i) \cdot (q \bmod i)^{-1} \pmod{q}$ | $q$ 为质数，$i < q$ |

## 三、逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
```

标准头文件与命名空间。

### 3.1 _gcd —— 欧几里得算法

```cpp
long long _gcd(long long a, long long b)
{
    return b ? _gcd(b, a % b) : a;
}
```

递归实现的欧几里得算法。`b` 为 0 时返回 `a`（递归终点），否则递归调用 `_gcd(b, a % b)`。函数名加下划线前缀避免与标准库 `gcd` 冲突。

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `long long _gcd(long long a, long long b)` | 输入 $a, b$，返回 $\gcd(a, b)$ |
| 2 | `return b ? _gcd(b, a % b) : a;` | 三目运算：$b \ne 0$ 时递归，$b = 0$ 时返回 $a$ |

### 3.2 fastpow —— 快速幂

```cpp
long long fastpow(long long a, long long b, long long q)
{
    if (b == 0) return 1;
    long long ans = 1;
    long long gap = a;
    while (b)
    {
        if (b & 1) ans = (ans * gap) % q;
        gap = (gap * gap) % q;
        b >>= 1;
    }
    return ans;
}
```

计算 $a^b \bmod q$。

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `if (b == 0) return 1;` | 特判 $b = 0$：$a^0 = 1$ |
| 2-3 | `long long ans = 1; long long gap = a;` | `ans` 为累积器，`gap` 为当前平方基 |
| 4 | `while (b)` | 遍历 $b$ 的每一位二进制位 |
| 5 | `if (b & 1) ans = (ans * gap) % q;` | 当前位为 1 → 乘入 `gap` |
| 6 | `gap = (gap * gap) % q;` | 平方倍增 |
| 7 | `b >>= 1;` | 右移处理下一位 |

### 3.3 inv —— 模逆元（费马小定理）

```cpp
long long inv(long long a, long long q)
{
    if (_gcd(a, q) == 1) return fastpow(a, q - 2, q);
    return -1;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `long long inv(long long a, long long q)` | 输入 $a$ 和质数 $q$，返回 $a^{-1} \bmod q$ |
| 2 | `if (_gcd(a, q) == 1) return fastpow(a, q - 2, q);` | $\gcd(a,q)=1$ → 费马小定理：$a^{-1} \equiv a^{q-2}$ |
| 3 | `return -1;` | 不互质 → 逆元不存在，返回 $-1$ |

### 3.4 main —— 求逆元

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    //q要为质数
    long long a, q;
    cin >> a >> q;
    cout << inv(a, q);
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-2 | `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快速 IO |
| 3 | `//q要为质数` | 注释提醒：费马小定理要求 $q$ 为质数 |
| 4-5 | `long long a, q; cin >> a >> q;` | 读入 $a$ 和模数 $q$ |
| 6 | `cout << inv(a, q);` | 输出 $a^{-1} \bmod q$（或 $-1$ 表示不存在） |

### 3.5 运行示例

输入：
```
3 7
```

输出：
```
5
```

因为 $3 \times 5 = 15 \equiv 1 \pmod{7}$，所以 $3^{-1} \equiv 5 \pmod{7}$。

验证：$3^{7-2} = 3^5 = 243 = 34 \times 7 + 5 \equiv 5 \pmod{7}$ ✓

输入：
```
2 4
```

输出：
```
-1
```

因为 $\gcd(2, 4) = 2 \ne 1$，逆元不存在。

## 四、复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 时间 | $O(\log q)$ | 快速幂 $O(\log q)$ + GCD $O(\log q)$ |
| 空间 | $O(1)$ | 仅用几个变量（递归 GCD 的栈深度为 $O(\log q)$） |

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **模意义除法** | $a/b \bmod q$ 转化为 $a \times b^{-1} \bmod q$ |
| **组合数取模** | $C(n,k) = n! / (k!(n-k)!)$ 取模需要求阶乘的逆元 |
| **模方程求解** | 求解 $ax \equiv b \pmod{q}$ 转化为 $x \equiv b \cdot a^{-1} \pmod{q}$ |
| **RSA 加密** | 生成密钥时需要模逆元 |
| **分数取模** | 将分数 $a/b$ 在模 $q$ 下表示为整数 $a \cdot b^{-1} \bmod q$ |

## 六、常见陷阱与注意事项

### 6.1 q 必须为质数

费马小定理要求模数 $q$ 为质数。若 $q$ 为合数，$a^{q-2} \bmod q$ **不一定**等于 $a^{-1}$。例如 $q = 4$，$a = 3$：$3^{4-2} = 9 \equiv 1 \pmod{4}$，但 $3^{-1} \equiv 3 \pmod{4}$（$3 \times 3 = 9 \equiv 1 \pmod{4}$），两者恰好相等是巧合。另一个反例：$q = 6$，$a = 5$，$5^{6-2} = 5^4 = 625 \equiv 1 \pmod{6}$，而 $5^{-1} \equiv 5 \pmod{6}$，不相等。

### 6.2 gcd 检查的必要性

即使 $q$ 为质数，仍需检查 $\gcd(a, q) = 1$。当 $a$ 是 $q$ 的倍数时（$q$ 为质数即 $a$ 是 $q$ 的倍数），逆元不存在。代码返回 $-1$ 表示这种情况。若不做检查直接计算，结果为 0 而非 $-1$，可能导致下游逻辑错误。

### 6.3 long long 的必要性

中间计算 `ans * gap` 和 `gap * gap` 可能超过 `int` 上限。当 $q$ 接近 $10^9$ 时，两个 $< q$ 的数相乘结果可达 $10^{18}$，必须用 `long long`。

### 6.4 负数取模

C++ 中负数取模结果为负数。若 $a$ 可能为负，需先 `a = ((a % q) + q) % q` 转为正数再求逆元。

### 6.5 逆元不改变"整除性"

$a \cdot b^{-1} \bmod q$ 的结果只有在 $b \mid a$ 时才等于 $a/b$ 的整数部分取模。当 $b \nmid a$ 时，结果是"模 $q$ 意义下的商"，而非真实除法的结果。

### 6.6 函数名冲突

标准库 `<algorithm>` 在 C++17 中提供了 `std::gcd`，本代码用 `_gcd` 避免命名冲突。若使用 `using namespace std` 且不加分隔符直接定义 `gcd`，可能产生歧义。

## 七、对比与扩展

### 7.1 三种求逆元方法对比

| 维度 | 费马小定理（本代码） | 欧拉定理 | 扩展欧几里得 |
|------|---------------------|---------|-------------|
| 模数要求 | $q$ 为质数 | $\gcd(a,q)=1$ | $\gcd(a,q)=1$ |
| 核心公式 | $a^{q-2}$ | $a^{\varphi(q)-1}$ | 解 $ax+qy=1$ |
| 复杂度 | $O(\log q)$ | $O(\sqrt{q} + \log q)$ | $O(\log q)$ |
| 需要快速幂 | 是 | 是 | 否 |
| 需要求 $\varphi$ | 否 | 是 | 否 |
| 适用场景 | 模数为质数（竞赛常见） | 模数为合数 | 模数为合数或需同时求 GCD |

### 7.2 线性递推求逆元

当需要 $[1, n]$ 内所有数的逆元（$n \le q$，$q$ 为质数）时，可线性递推：

$$i^{-1} \equiv -(q/i) \cdot (q \bmod i)^{-1} \pmod{q}$$

推导：设 $q = ki + r$（$k = q/i$，$r = q \bmod i$），则 $ki + r \equiv 0 \pmod{q}$，两边乘 $i^{-1} r^{-1}$ 得 $k \cdot r^{-1} + i^{-1} \equiv 0$，所以 $i^{-1} \equiv -k \cdot r^{-1} = -(q/i) \cdot (q \bmod i)^{-1}$。

```cpp
inv[1] = 1;
for (int i = 2; i <= n; i++)
    inv[i] = (q - q / i) * inv[q % i] % q;
```

复杂度 $O(n)$，适合批量预处理。

### 7.3 逆元与组合数

组合数 $C(n, k) = \frac{n!}{k!(n-k)!}$ 取模时，需要预处理阶乘及其逆元：

$$C(n, k) \bmod q = n! \cdot (k!)^{-1} \cdot ((n-k)!)^{-1} \bmod q$$

预处理 `fact[i] = i!` 和 `invfact[i] = (i!)^{-1}`，即可 $O(1)$ 查询组合数。

### 7.4 扩展欧几里得求逆元

```cpp
long long ex_gcd(long long a, long long b, long long &x, long long &y)
{
    if (!b) { x = 1; y = 0; return a; }
    long long d = ex_gcd(b, a % b, y, x);
    y -= a / b * x;
    return d;
}

long long inv(long long a, long long q)
{
    long long x, y;
    ex_gcd(a, q, x, y);
    return (x % q + q) % q;
}
```

不要求 $q$ 为质数，只要求 $\gcd(a, q) = 1$。

### 7.5 一句话总结

模逆元是模意义下的"倒数"，将除法转化为乘法。当模数 $q$ 为质数时，由费马小定理 $a^{-1} \equiv a^{q-2} \pmod{q}$，用快速幂 $O(\log q)$ 求解；当 $q$ 为合数时，由欧拉定理 $a^{-1} \equiv a^{\varphi(q)-1} \pmod{q}$ 或扩展欧几里得求解。逆元是组合数取模、模方程求解等问题的核心工具。$AKB318$, '数学', array['数学', '数论', '模逆元', '费马小定理', '欧拉定理', '快速幂', '扩展欧几里得'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-nested-radical--stripe-python', '嵌套根式化简 · stripe-python', $AKB319$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## Example 0

求 $\sqrt{a \pm \sqrt{b}}$ 的值和判别式。

注意到，要把这个根号开出来，可以把根号里面化为完全平方式。于是作**换元，令**

$a=m^2+n^2, \sqrt{b}=2mn$则

$\text{原式} = \sqrt{m^2+n^2 \pm 2mn}=\sqrt{(m \pm n)^2}=m \pm n$由 $\sqrt{b}=2mn$ 得 $4m^2n^2=b$

再次换元，令 $x=m^2,y=n^2$，则有如下方程组：

$$
\left\{\begin{matrix} x+y=a
 \\4xy=b

\end{matrix}\right.
$$

消元，整理得

$-x^2+ax-\dfrac{1}{4}b=0$由一元二次方程的判别式得

$\Delta=a^2-4 \times (-1) \times (-\dfrac{1}{4}b)=a^2-b$由一元二次方程的求根公式得

$$
x_1=\dfrac{-a+\sqrt{\Delta}}{-2}=\dfrac{a-\sqrt{\Delta}}{2},
x_2=\dfrac{-a-\sqrt{\Delta}}{-2}=\dfrac{a+\sqrt{\Delta}}{2}
$$

所以原方程组有两组解为

$$
\left\{\begin{matrix} x_1=\dfrac{a-\sqrt{\Delta}}{2}, x_2=\dfrac{a+\sqrt{\Delta}}{2}
 \\y_1=\dfrac{a+\sqrt{\Delta}}{2}, y_2=\dfrac{a-\sqrt{\Delta}}{2}

\end{matrix}\right.
$$

注意到，$x$ 取 $x_1$ 或 $x_2$ 不影响最终结果，不妨令

$$
x=\dfrac{a+\sqrt{\Delta}}{2},
y=\dfrac{a-\sqrt{\Delta}}{2}
$$

则

$m=\sqrt{x}=\sqrt{\dfrac{a+\sqrt{\Delta}}{2}}, n=\sqrt{y}=\sqrt{\dfrac{a-\sqrt{\Delta}}{2}}$回代可得

$\text{原式} = \sqrt{\dfrac{a+\sqrt{\Delta}}{2}} \pm \sqrt{\dfrac{a-\sqrt{\Delta}}{2}}, \Delta=a^2-b$### 结论

$\sqrt{a \pm \sqrt{b}}=\sqrt{\dfrac{a+\sqrt{\Delta}}{2}} \pm \sqrt{\dfrac{a-\sqrt{\Delta}}{2}}, \Delta=a^2-b$当且仅当 $\Delta \ge 0$ 且为完全平方数时可开根。

特别地，如果 $b$ 为完全平方数，判别式无效。

## Example 1

这是卷子上的题。求 $\sqrt{5+2\sqrt{6}}$ 和 $\sqrt{7-2\sqrt{10}}$ 的值。

解：

因为 $\sqrt{5+2\sqrt{6}}=\sqrt{5+\sqrt{24}}$

所以 $\Delta=5^2-24=1$

所以 $\sqrt{5+2\sqrt{6}}=\sqrt{\dfrac{5+1}{2}}+\sqrt{\dfrac{5-1}{2}}=\sqrt{3}+\sqrt{2}$

因为 $\sqrt{7-2\sqrt{10}}=\sqrt{7+\sqrt{40}}$

所以 $\Delta=7^2-40=9$

所以 $\sqrt{7-2\sqrt{10}}=\sqrt{\dfrac{7+3}{2}}-\sqrt{\dfrac{7-3}{2}}=\sqrt{5}-\sqrt{2}$

看上去秒杀。但是我们在考试中偶尔也会遇到这类特别奇葩的题目：

## Example 2

这是那张卷子上的压轴题。求 $\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}$ 的值。

第一反应是开 $\sqrt{10+2\sqrt{5}}$，然而开不开。

只能考虑换元。

### 方法 1：代数换元

令

$p=\sqrt{4-\sqrt{10+2\sqrt{5}}}, q=\sqrt{4+\sqrt{10+2\sqrt{5}}}$注意到 $p^2+q^2$ 可以消掉 $\sqrt{10+2\sqrt{5}}$，$pq$ 则可以在根号下应用平方差公式。

则

$p^2+q^2=4-\sqrt{10+2\sqrt{5}}+4+\sqrt{10+2\sqrt{5}}=8$同时

$pq=\sqrt{(4-\sqrt{10+2\sqrt{5}})(4+\sqrt{10+2\sqrt{5}})}$ $=\sqrt{4^2-(\sqrt{10+2\sqrt{5}})^2}$ $=\sqrt{16-10-2\sqrt{5}}$ $=\sqrt{6-2\sqrt{5}}$对 $\sqrt{6-2\sqrt{5}}$ 应用上面的公式，得 $pq=\sqrt{5}-1$。

所以

$(p+q)^2=p^2+q^2+2pq=8+2(\sqrt{5}-1)=6+2\sqrt{5}$又因为 $\text{原式} \ge 0$，所以

$\text{原式}=p+q=\sqrt{6+2\sqrt{5}}$对 $\sqrt{6+2\sqrt{5}}$ 应用上面的公式，得 $\text{原式}=\sqrt{5}+1$。

### 方法 2：逆用公式

作一个不一样的换元。

令

$\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}=\sqrt{a+\sqrt{b}}$则

$\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}=\sqrt{\dfrac{a+\sqrt{a^2-b}}{2}}+ \sqrt{\dfrac{a-\sqrt{a^2-b}}{2}}$考虑在等式两边构造同构：

$\sqrt{\dfrac{8+2\sqrt{10+2\sqrt{5}}}{2}}+\sqrt{\dfrac{8-2\sqrt{10+2\sqrt{5}}}{2}}=\sqrt{\dfrac{a+\sqrt{a^2-b}}{2}}+ \sqrt{\dfrac{a-\sqrt{a^2-b}}{2}}$得到 $a=8, \sqrt{a^2-b}=2\sqrt{10+2\sqrt{5}}$

解得 $b=24-8\sqrt{5}$

则 $\text{原式}=\sqrt{8+\sqrt{24-8\sqrt{5}}}$

对 $\sqrt{24-8\sqrt{5}}$ 应用公式得 $\sqrt{24-8\sqrt{5}}=2\sqrt{5}-2$。

则 $\text{原式}=\sqrt{6+2\sqrt{5}}$

对 $\sqrt{6+2\sqrt{5}}$ 应用公式，得 $\text{原式}=\sqrt{5}+1$。

## Example 3

来一道逆用公式的模板题。求 $\dfrac{\sqrt{2}}{2}(\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}})$ 的值。

显然我们可以对 $\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}}$ 进行代数换元法。但是逆用公式更为快捷。

$\text{原式} = \dfrac{1}{\sqrt{2}}(\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}}) = \sqrt{\dfrac{4+\sqrt{7}}{2}}+\sqrt{\dfrac{4-\sqrt{7}}{2}}$不难看出 $\sqrt{\dfrac{4+\sqrt{7}}{2}}+\sqrt{\dfrac{4-\sqrt{7}}{2}}$ 是公式的标准形式。

令 $\text{原式}  = \sqrt{a+\sqrt{b}}$，则 $a=4, \sqrt{a^2-b} = \sqrt{7}$，解得 $b=9$。

所以 $\text{原式} = \sqrt{4+\sqrt{9}} = \sqrt{7}$$AKB319$, '数学', array['嵌套根式', '根号', '代数', '数学基础'], 'col-math-oi-foundations', null, 'knowledge'),
('dbywsc', 'col-math-number-theory-basic--dbywsc', '数论基础（素性测试 / 质因数分解 / 筛法 / gcd / 快速幂） · dbywsc', $AKB320$## 算法原理

数论研究整数的性质。本笔记覆盖普及组常见的几块：整除与素数、质因数分解、筛法、最大公约数 / 最小公倍数、快速幂。

### 整除与素数

对于整数 $n,m$，如果存在整数 $q$ 使得 $n=q\times m$，就说 $m$ 整除 $n$，记作 $m\mid n$；$m$ 是 $n$ 的因数，$n$ 是 $m$ 的倍数。否则记作 $m\nmid n$。

如果一个数 $n$ 的正因数只有 $1$ 和它自己，且 $n\ne1$，则 $n$ 是**质数**。

### 素性测试

判断一个数是不是质数。暴力做法枚举 $2\sim n-1$，看是否存在 $i\mid n$；时间复杂度 $O(n)$。

一个数 $n$ 最多只有一个质因数大于等于 $\sqrt n$：若存在两个不同的质因数 $p_1,p_2\ge\sqrt n$，则 $p_1p_2>n$，矛盾。因此试除只需要枚举到 $\sqrt n$。判断时也只需要判断是否存在质因数，因为任何合数因数都能继续分解成质因数。

### 质因数分解

沿用试除法：在 $2\sim\sqrt n$ 中枚举 $i$，如果 $i\mid n$，就不断除以 $i$ 直到除不尽，并记录指数；最后若 $n\ne1$，剩下的 $n$ 本身就是一个质因子。时间复杂度 $O(\sqrt n)$。

这样做正确的原因是：循环从 $2$ 开始，若当前 $i\mid n$，$i$ 一定是质数；否则它会被自己的质因子在之前除干净。

### 唯一分解定理

任意整数 $n$ 都可以唯一表示为

$$
n=p_1^{\alpha_1}p_2^{\alpha_2}\cdots p_k^{\alpha_k},
$$

其中 $p_i$ 是质数。这个定理是 gcd、lcm、约数个数、约数和等公式的基础。

### 筛法

质数定理：$1\sim n$ 内的质数数量 $\pi(n)\sim\dfrac{n}{\ln n}$（这里只记结论）。

- **朴素筛**：从 $2$ 开始，把每个数的倍数都筛掉；时间 $O(n\log n)$。
- **埃氏筛**：只用一个数筛它的倍数，且只对质数筛；时间 $O(n\log\log n)$。
- **线性筛（欧拉筛）**：让每个合数只被它的最小质因子筛一次；时间 $O(n)$。

线性筛的核心：对每个 $i$，用已得到的质数 $p_j$ 去筛 $i\cdot p_j$，当 $i\bmod p_j=0$ 时退出。这样每个合数 $x$ 只会被它的最小质因子筛到。

### gcd 与 lcm

最大公因数 $\gcd(a,b)$ 用辗转相除法：

```pseudocode
function gcd(a, b)
    if b == 0
        return a
    return gcd(b, a % b)
```

用到的性质：

- $\gcd(a,b)=\gcd(b,a)$；
- $\gcd(a,0)=a$；
- $\gcd(a,b)=\gcd(b,a\bmod b)$。

第三条的证明：设 $c=a\bmod b$，$a=kb+c$。若 $d\mid a,d\mid b$，则 $d\mid c$；反过来若 $d\mid b,d\mid c$，则 $d\mid a$。两组数的公因子相同，所以最大公因数相同。

时间复杂度 $O(\log\max(a,b))$。若 $\gcd(a,b)=1$，称 $a,b$ 互质；相邻整数总是互质。

内置函数：`__gcd(a,b)` 是 GCC 扩展，`std::gcd(a,b)` 是 C++17 标准；OI 常用环境是 C++14，建议手写。负数可以先取绝对值。

多个数的 gcd 依次求即可：

```pseudocode
g <- 0
for i <- 1 to n
    g <- gcd(g, a[i])
```

更相减损术：$\gcd(a,b)=\gcd(a-b,b)$；多个数时有 $\gcd(a,b,c,\cdots)=\gcd(a,\gcd(b-a,c-a,\cdots))$。

最小公倍数：

$$
\operatorname{lcm}(a,b)=\frac{ab}{\gcd(a,b)}.
$$

证明用唯一分解定理：$ab$ 中每个质因子的指数是 $\alpha_i+\beta_i$，$\gcd$ 取 $\min$，$\operatorname{lcm}$ 取 $\max$，而 $\min+\max=\alpha+\beta$。

多个数的 lcm 也依次求，不能直接用“乘积除以总 gcd”：

$$
\operatorname{lcm}(a,b,c)\ne\frac{abc}{\gcd(a,b,c)}.
$$

例如 $a=2,b=3,c=6$：$\operatorname{lcm}(2,3,6)=6$，而 $\dfrac{2\cdot3\cdot6}{\gcd(2,3,6)}=\dfrac{36}{1}=36$，两者不相等。

### 快速幂

要求 $a^b\bmod P$。把 $b$ 二进制拆分：

$$
b=2^{k_1}+2^{k_2}+\cdots,
$$

$$
a^b=a^{2^{k_1}}\cdot a^{2^{k_2}}\cdots.
$$

一边把 $b$ 右移，一边让 $a$ 自乘，遇到二进制位为 $1$ 就把当前的 $a$ 乘进答案。时间复杂度 $O(\log b)$。

快速幂还能在每一步取模，避免结果溢出：

```pseudocode
function quick_pow(a, b, P)
    res <- 1
    while b > 0
        if b & 1
            res <- res * a % P
        a <- a * a % P
        b <- b >> 1
    return res
```

## 核心公式 / 状态定义与转移方程

- 整除：$m\mid n\iff \exists q,\ n=qm$。
- 试除上界：只需枚举到 $\sqrt n$；若 $i\mid n$ 且 $i\le\sqrt n$，则 $n/i$ 是另一个因数。
- 唯一分解：$n=\prod p_i^{\alpha_i}$。
- 约数个数：$d(n)=\prod(\alpha_i+1)$；约数和：$\sigma(n)=\prod\dfrac{p_i^{\alpha_i+1}-1}{p_i-1}$。
- 埃氏筛：对每个质数 $p$，筛掉 $p^2,p^2+p,\dots$；时间 $O(n\log\log n)$。
- 线性筛：`if (i % p[j] == 0) break;`，每个合数只被最小质因子筛一次。
- 欧几里得：$\gcd(a,b)=\gcd(b,a\bmod b)$，$\gcd(a,0)=a$。
- lcm：$\operatorname{lcm}(a,b)=\dfrac{ab}{\gcd(a,b)}$；多个数依次求。
- 快速幂：$a^b=(a^2)^{\lfloor b/2\rfloor}\cdot a^{b\bmod 2}$。
- 龟速乘：$ab=2a\lfloor b/2\rfloor+a\cdot[b\bmod 2]$，用于模数很大且乘法溢出的情况。

## 逐行代码解析

### 试除法判断质数

```cpp
bool is_prime(long long n) {
    if (n < 2) return false;
    for (long long i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
    }
    return true;
}
```

- `n < 2` 直接排除 $0,1$ 和负数。
- 循环条件 `i * i <= n` 等价于 $i\le\sqrt n$；用 `i <= n / i` 可以避免 `i*i` 溢出。
- 找到一个因子就返回 `false`；循环结束仍未找到则是质数。

### 质因数分解

```cpp
vector<pair<long long, int>> factorize(long long n) {
    vector<pair<long long, int>> res;
    for (long long i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            int cnt = 0;
            while (n % i == 0) {
                n /= i;
                cnt++;
            }
            res.push_back({i, cnt});
        }
    }
    if (n > 1) res.push_back({n, 1});
    return res;
}
```

- 外层枚举到 $\sqrt n$；找到因子后不断除，统计指数。
- 循环结束后若 $n>1$，剩下的 $n$ 是质因子，指数为 $1$。
- 时间复杂度 $O(\sqrt n)$。

### 埃氏筛

```cpp
vector<int> primes;
vector<bool> is_comp(n + 1, false);
for (int i = 2; i <= n; i++) {
    if (!is_comp[i]) {
        primes.push_back(i);
        for (long long j = 1LL * i * i; j <= n; j += i) {
            is_comp[j] = true;
        }
    }
}
```

- 从 $i^2$ 开始筛，因为小于 $i^2$ 的倍数已经被更小的质数筛过。
- `1LL * i * i` 防止 `int` 溢出。
- 时间 $O(n\log\log n)$。

### 线性筛

```cpp
vector<int> primes;
vector<bool> is_comp(n + 1, false);
for (int i = 2; i <= n; i++) {
    if (!is_comp[i]) primes.push_back(i);
    for (int p : primes) {
        if (1LL * i * p > n) break;
        is_comp[i * p] = true;
        if (i % p == 0) break;
    }
}
```

- 每个合数只被它的最小质因子筛一次。
- `i % p == 0` 时退出，保证之后不会用更大的质因子重复筛。
- 时间 $O(n)$。

### GCD 与 LCM

```cpp
long long gcd(long long a, long long b) {
    return b == 0 ? a : gcd(b, a % b);
}

long long lcm(long long a, long long b) {
    return a / gcd(a, b) * b;
}
```

- `lcm` 先除后乘，降低溢出风险。
- 负数先取绝对值；`gcd(0,0)` 按题目约定处理。

### 快速幂

```cpp
long long qpow(long long a, long long b, long long p) {
    long long res = 1 % p;
    a %= p;
    while (b > 0) {
        if (b & 1) res = res * a % p;
        a = a * a % p;
        b >>= 1;
    }
    return res;
}
```

- `res = 1 % p` 处理 $p=1$ 的情况。
- `a %= p` 先归一化，负数底数也能处理。
- 每一步取模，避免溢出。

## 复杂度分析

| 操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 试除法判质数 | $O(\sqrt n)$ | $O(1)$ |
| 质因数分解 | $O(\sqrt n)$ | $O(\log n)$（因子个数） |
| 埃氏筛 | $O(n\log\log n)$ | $O(n)$ |
| 线性筛 | $O(n)$ | $O(n)$ |
| 欧几里得 gcd | $O(\log\min(a,b))$ | $O(1)$（递归栈 $O(\log)$） |
| lcm（已知 gcd） | $O(1)$ | $O(1)$ |
| 快速幂 | $O(\log b)$ | $O(1)$ |

## 适用场景

- 判断单个数是否质数：试除法（$n\le10^{12}$ 左右可用）。
- 分解单个数：试除法；更大的数需要 Pollard-Rho 等高级算法。
- 预处理 $1\sim n$ 的质数：埃氏筛或线性筛；需要最小质因子/积性函数时用线性筛。
- 约分、比例、周期、同余：gcd / lcm。
- 模意义下的大指数幂、矩阵快速幂、递推加速：快速幂。
- 模数很大且乘法溢出：龟速乘（现代环境也可用 `__int128`）。

## 常见陷阱与注意事项

1. **试除上界写成 $i<n$**：会退化成 $O(n)$；应写 $i\le\sqrt n$ 或 `i <= n / i`。
2. **`i*i` 溢出**：`int` 的 `i*i` 在 $i$ 接近 $10^9$ 时会溢出；用 `1LL*i*i` 或 `i <= n/i`。
3. **质因数分解漏掉剩余的 $n$**：循环结束后若 $n>1$，还要把它加入答案。
4. **筛法从 $i$ 开始而不是 $i^2$**：不影响正确性但会重复筛；从 $i^2$ 开始更高效。
5. **线性筛忘记 `break`**：会导致重复筛，复杂度退化。
6. **lcm 先乘后除溢出**：写成 `a / gcd(a,b) * b`。
7. **多个数的 lcm 公式用错**：不能用“乘积除以总 gcd”，要依次求。
8. **`__gcd` 处理负数**：先取绝对值；`std::gcd` 可以处理负数。
9. **快速幂 `p=1`**：`res` 应初始化为 `1 % p`，否则返回 $1$ 而不是 $0$。
10. **底数为负**：先 `a %= p` 归一化；指数为负需要逆元，不是普通快速幂。

## 对比与扩展

- **试除法 vs 筛法**：单个数用试除；多组查询/预处理用筛法。
- **埃氏筛 vs 线性筛**：埃氏筛好写，$O(n\log\log n)$；线性筛 $O(n)$，还能顺便求最小质因子、欧拉函数、约数个数等。
- **gcd vs 更相减损术**：欧几里得用取模，复杂度 $O(\log V)$；更相减损术在数值差距大时可能很慢。
- **快速幂 vs 龟速乘**：快速幂解决“指数大”，龟速乘解决“乘积溢出”，两者可以组合。
- **讲义练习**：P1185、A3042、G1033、A2017、TW1141、G1063、G1043、G1157、P1187、G1094、ABC170D、P1500、ABC172D、A3090、G1127、P1108、TW4031、ABC445E、P1194、P1257、CF2200E、P1504、A2067、CF2216D。题号以原讲义为准，部分为训练平台题号。$AKB320$, '数学', array['数论', '素性测试', '质因数分解', '筛法', 'gcd', 'lcm', '快速幂'], 'col-hub-math-number-theory', null, 'knowledge'),
('Fohen', 'col-math-number-theory-basic--fenfeng', '数论基础 · Fohen', $AKB321$## 算法原理

数论研究整数的性质。在进入质因数分解、筛法、模运算、同余等具体算法之前，先要理清一批最基础的概念——整除、约数、带余数除法、最大公约数与最小公倍数、加性 / 积性函数、取整函数。它们像地基一样支撑起后面所有数论内容。

**整除**是其中最核心的概念。对两个整数 $a$、$b$（$a \neq 0$），若存在整数 $q$ 使 $b = aq$，则称 $a$ 整除 $b$，记作 $a \mid b$；否则记作 $a \nmid b$。直观地说，判断 $b$ 能否被 $a$ 整除，就是看 $b$ 是否是 $a$ 的整数倍。例如 $3 \mid 6$（$6 = 3 \times 2$），而 $4 \nmid 6$。

由整除可以直接引出**约数**（若 $a \mid b$，则 $a$ 是 $b$ 的约数）、**带余数除法**（对任意 $a \neq 0$，$b$ 都可唯一写成 $b = qa + r$，$0 \le r < |a|$），以及后续的**最大公约数 / 最小公倍数**。而"取余"正是模运算的雏形，是数论中最重要的运算之一。

在此基础上，**加性函数**与**积性函数**提供了"化整为零"的视角：只要知道函数在素数幂处的取值，就能由加性 / 积性把任意整数的取值拼出来，这一性质是线性筛预处理各类数论函数值的关键。**取整函数**（下取整 $\lfloor \cdot \rfloor$、上取整 $\lceil \cdot \rceil$）则在整除分块、素数计数等问题中大量出现，几乎是必备工具。

## 核心公式 / 状态定义与转移方程

### 整除与约数

**定义**：$a \mid b \iff \exists q \in \mathbb{Z},\ b = aq$（其中 $a \neq 0$）。

整除的常用性质：

| 性质 | 公式 | 含义 |
|---|---|---|
| 传递性 | $a \mid b$ 且 $b \mid c \Rightarrow a \mid c$ | 整除关系可传递 |
| 线性组合 | $a \mid b$ 且 $a \mid c \Rightarrow a \mid (xb + yc)$ | 对任意整数 $x,y$ 成立 |
| 互相整除 | $a \mid b$ 且 $b \mid a \Rightarrow b = \pm a$ | 只差一个符号 |
| 余数等价 | $b = qa + c$ 时，$a \mid b \iff a \mid c$ | 判断整除只看余数 |

最后一条特别有用：判断 $a$ 能否整除一个数，只需看它除以 $a$ 的余数是否为 $0$。

**约数成对出现**：当 $b \neq 0$ 时，若 $d$ 遍历 $b$ 的所有约数，则 $\dfrac{b}{d}$ 也遍历 $b$ 的所有约数，即 $d$ 与 $\dfrac{b}{d}$ 总是一对。

### 带余数除法

$$
b = qa + r, \quad 0 \le r < |a|
$$

其中 $q$ 为商、$r$ 为余数；上式中的 $r$ 称为**最小非负余数**，未特别说明时"余数"均指它。

### 最大公约数与最小公倍数

**定义**：$\gcd(a,b)$ 是 $a,b$ 公有约数中最大者，$\operatorname{lcm}(a,b)$ 是 $a,b$ 公有倍数中最小的正数。

常用性质：

- $\gcd(a,b) = \gcd(b,a)$（交换律）。
- 若 $a \neq 0$，则 $\gcd(a,0) = |a|$。
- $\gcd(bq+r, b) = \gcd(r, b)$——辗转相除法的理论依据。
- $\gcd(a_1,a_2,\dots,a_n) = \gcd(\gcd(a_1,a_2),a_3,\dots,a_n)$（可逐个求）。

gcd 与 lcm 的关系：

$$
\gcd(a,b) \cdot \operatorname{lcm}(a,b) = |a \cdot b|
$$

因此 lcm 可统一转换为 gcd 求解：

$$
\operatorname{lcm}(a,b) = \frac{a}{\gcd(a,b)} \cdot b
$$

### 加性函数与积性函数

**加性函数**：$f(1)=0$，且对任意互质的正整数 $x,y$ 有 $f(xy)=f(x)+f(y)$；若"互质"条件可去掉则为**完全加性函数**。

**积性函数**：$f(1)=1$，且对任意互质的正整数 $x,y$ 有 $f(xy)=f(x)f(y)$；若"互质"条件可去掉则为**完全积性函数**。

常用实例：

| 函数 | 含义 | 类别 |
|---|---|---|
| $\nu_p(n)$ | 质因数分解中质数 $p$ 的指数 | 完全加性 |
| $\Omega(n)$ | 所有质因子总数（带重数） | 完全加性 |
| $\omega(n)$ | 相异质因子个数，$\omega(n)=\sum_{p \mid n}1$ | 加性（非完全加性） |
| $\varphi(n)$ | $1$ 到 $n$ 中与 $n$ 互质的数的个数 | 积性 |
| $\sigma_k(n)$ | 所有正因数的 $k$ 次幂之和 | 积性 |
| $\mu(n)$ | 莫比乌斯函数 | 积性 |
| $\mathrm{id}(n)=n$、$\mathbf{1}(n)=1$ | 恒等函数、常函数 | 完全积性 |

积性性质的价值在于：只需知道函数在素数幂处的取值，就能拼出所有整数的值，因而可用线性筛在 $O(n)$ 内预处理出 $1 \sim n$ 的取值。

### 取整函数

$$
\lfloor x \rfloor = \max\{k \in \mathbb{Z} : k \le x\}, \qquad \lceil x \rceil = \min\{k \in \mathbb{Z} : k \ge x\}
$$

基本性质：

- $x - 1 < \lfloor x \rfloor \le x \le \lceil x \rceil < x + 1$。
- $x \in \mathbb{Z} \iff x = \lfloor x \rfloor = \lceil x \rceil$。
- $\lceil x \rceil - \lfloor x \rfloor = \begin{cases} 0, & x \in \mathbb{Z} \\ 1, & x \notin \mathbb{Z} \end{cases}$

注意负数：$\lfloor -2.3 \rfloor = -3$，$\lceil -2.3 \rceil = -2$。

## 逐行代码解析

本知识点是一组定义与性质，无统一实现，下面给出其中"唯一可直接写成算法的部分"——最大公约数 / 最小公倍数——的伪代码，其余概念直接套用公式即可。

**辗转相除法（欧几里得算法）**求 $\gcd$：

```cpp
int gcd(int a, int b) {
    while (b != 0) {
        int t = b;
        b = a % b;   // 由 gcd(bq+r, b) = gcd(r, b)，把 (a,b) 换成 (b, a%b)
        a = t;
    }
    return a;       // b == 0 时，gcd(a, 0) = a
}
```

- 核心依据是 $\gcd(bq+r, b) = \gcd(r, b)$：令 $r = a \bmod b$，则 $\gcd(a,b)=\gcd(b,r)$，每轮让"较小数"变成余数，规模快速减小。
- 当 $b = 0$ 时返回 $a$，对应性质 $\gcd(a,0)=|a|$（$a>0$ 时即 $a$）。
- 无需预先保证 $a \ge b$：若 $a < b$，第一轮 `a % b == a`，循环自动交换两数。

**最小公倍数**直接由 gcd 转换：

```cpp
int lcm(int a, int b) {
    return a / gcd(a, b) * b;   // 先除后乘，防止 a*b 溢出
}
```

- 依据 $\gcd(a,b)\cdot\operatorname{lcm}(a,b)=|ab|$，故 $\operatorname{lcm}=a/\gcd\cdot b$。
- 必须**先除后乘**：直接 `a * b / gcd` 在 $a,b$ 较大时中间结果 $ab$ 可能溢出。

**二进制 gcd（Stein 算法）**的思想步骤（常数更小，常用于卡常题）：

```text
1. 若 a、b 均为偶数：gcd(a,b) = 2 * gcd(a/2, b/2)
2. 若 a 为偶数、b 为奇数：gcd(a,b) = gcd(a/2, b)
3. 若 a 为奇数、b 为偶数：gcd(a,b) = gcd(a, b/2)
4. 若 a、b 均为奇数：gcd(a,b) = gcd(|a-b|, min(a,b))
```

以上操作都可转化为位运算（判断奇偶、右移除 $2$），故常数很小。

## 复杂度分析

本知识点为概念集合，**无统一复杂度，须视具体实现而定**。其中涉及算法的部分可给出参考复杂度：

| 操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 辗转相除法求 $\gcd$ | $O(\log \min(a,b))$ | $O(1)$（迭代）/ $O(\log \min(a,b))$（递归栈） |
| 二进制 gcd | $O(\log \min(a,b))$ | $O(1)$ |
| 由 gcd 求 $\operatorname{lcm}$ | $O(\log \min(a,b))$ | $O(1)$ |
| 其余概念（整除、约数、取整等） | 视具体实现 | 视具体实现 |

## 适用场景

- **质因数分解、筛法、模运算、同余方程**的前置基础：理解整除与带余数除法是理解"余数"与"模"的前提。
- **求最大公约数 / 最小公倍数**：约分、周期问题、调度问题中反复出现，直接套用欧几里得算法。
- **枚举约数**：利用"约数成对出现"只需枚举到 $\sqrt{b}$，可用于求因子个数、因子和。
- **数论函数预处理**：积性 / 加性函数可用线性筛 $O(n)$ 预处理，是莫比乌斯反演等工具的地基。
- **整除分块、素数计数**：取整函数 $\lfloor \cdot \rfloor$ 是这些算法中反复出现的符号与工具。

## 常见陷阱与注意事项

1. **整除记号要求 $a \neq 0$**：$a \mid b$ 的定义中除数不能为 $0$；做题时要留意 $0$ 是否作为除数出现。
2. **0 的约数**：部分教材认为 $0$ 的约数有无穷多个（任何非零整数都能整除 $0$），因此讨论约数时通常默认不考虑 $0$；做题时留意题目是否特判了 $0$。
3. **余数范围与负数取模**：数学余数满足 $0 \le r < |a|$；但 C/C++ 的 `%` 对负数向 $0$ 取整，可能得到负余数，与数学定义不一致，需按题目约定处理。
4. **lcm 溢出**：必须**先除后乘**（`a / gcd * b`），直接 `a * b / gcd` 可能中途溢出；极端情况下 lcm 本身也可能超过整数范围，需 `long long` 或高精度。
5. **约数枚举上限**：约数成对出现，只需枚举 $d \le \sqrt{b}$；注意完全平方数时 $\sqrt{b}$ 这一对只算一次。
6. **积性 / 加性的"互质"条件**：只有互质时才能拆分；完全积性 / 完全加性才无需互质。$\omega(n)$ 是加性但**非完全加性**（如 $\omega(p^2)=1 \neq 2\omega(p)$）。
7. **取整函数对负数**：下取整"向下"、上取整"向上"，与正数不同，例如 $\lfloor -2.3 \rfloor = -3$、$\lceil -2.3 \rceil = -2$，不要想当然当作"去掉小数点"。

## 对比与扩展

**加性函数 vs 积性函数**

| 维度 | 加性函数 | 积性函数 |
|---|---|---|
| 基准值 | $f(1)=0$ | $f(1)=1$ |
| 互质时的拆分 | $f(xy)=f(x)+f(y)$ | $f(xy)=f(x)f(y)$ |
| 去掉互质条件后 | 完全加性函数 | 完全积性函数 |
| 典型例子 | $\nu_p$、$\Omega$、$\omega$ | $\varphi$、$\sigma_k$、$\mu$、$\mathrm{id}$、$\mathbf{1}$ |

**辗转相除法 vs 二进制 gcd**

| 维度 | 辗转相除法 | 二进制 gcd |
|---|---|---|
| 核心操作 | 取模 | 位运算 + 减法 |
| 复杂度 | $O(\log \min(a,b))$ | $O(\log \min(a,b))$ |
| 常数 | 较大（取模较慢） | 更小，适合极度卡常 |
| 适用 | 一般情况直接 `std::__gcd` | 高精度、大整数或卡常题 |

**扩展方向**：

- 由 gcd 可引出**扩展欧几里得算法**，用于求模逆元、解线性同余方程。
- 由积性函数可引出**线性筛预处理**、**莫比乌斯反演**。
- 由带余数除法与取整函数可引出**整除分块**、**素数计数**、**同余与模运算**。

一句话总结：数论基础是一组看似简单、却贯穿始终的定义与性质——整除与约数、带余数除法、gcd / lcm、加性 / 积性函数、取整函数；它们共同构成了质因数分解、筛法、模运算、莫比乌斯反演等所有后续数论内容的基石。$AKB321$, '数学', array['数论', '整除', '约数', '最大公约数', '积性函数'], 'col-hub-math-number-theory', null, 'knowledge'),
('lker', 'col-math-number-theory-basic--lker', '数论基础（整除 / 约数 / gcd / 积性函数 / 取整） · lker', $AKB322$## 算法原理

![](https://cdn.luogu.com.cn/upload/image_hosting/omgjb4rx.webp)

数论是研究整数的数学。下面的所有变量都是整数。

**例题索引**：[B3634](https://www.luogu.com.cn/problem/B3634)、[P1029](https://www.luogu.com.cn/problem/P1029)、[P1072](https://www.luogu.com.cn/problem/P1072)、[P1226](https://www.luogu.com.cn/problem/P1226)、[U483926](https://www.luogu.com.cn/problem/U483926)、[U185835](https://www.luogu.com.cn/problem/U185835)、[P3383](https://www.luogu.com.cn/problem/P3383)、[P3951](https://www.luogu.com.cn/problem/P3951)、[P4549](https://www.luogu.com.cn/problem/P4549)、[P3811](https://www.luogu.com.cn/problem/P3811)、[P9774](https://www.luogu.com.cn/problem/P9774)。

本笔记按 lker 原文的顺序整理：先建立整除、gcd 与 lcm 的地基，再依次讨论快速幂、龟速乘、光速幂、线性筛、裴蜀定理、模逆元与威尔逊定理，并保留原文中的例题代码。原文中较简短的题解，在这里补上了推导过程；思路与结论保持原样。

### 一、整除、gcd 与 lcm

**引理 1（线性组合整除性）**：若 $d \mid a$ 且 $d \mid b$，则 $d \mid xa+yb$。

证明：设 $a=k_1d$，$b=k_2d$，则 $xa+yb=(xk_1+yk_2)d$，所以 $d \mid (xa+yb)$。证毕。

**引理 2**：$\gcd(a,b)=\gcd(b,a \bmod b)$。

证明：考虑证明 $a,b$ 的公约数集合等于 $b,a\bmod b$ 的公约数集合。设 $a=kb+r$。

- 若 $d\mid a$ 且 $d\mid b$，由引理 1，$d\mid (a-kb)$，即 $d\mid r$，充分性得证；
- 若 $d\mid r$ 且 $d\mid b$，由引理 1，$d\mid (r+kb)$，即 $d\mid a$，必要性得证。

两组数的公约数集合完全相同，所以最大公约数也一致。证毕。

**引理 3**：$a$ 和 $0$ 的最大公约数是 $a$。

证明：$0$ 的约数是所有非零整数，$a$ 的最大约数是自己，所以二者最大公约数为 $a$。

由引理 2 得到欧几里得算法：

$$
\gcd(a,b)=\gcd(b,a\bmod b),
$$

不断迭代直到 $b=0$，此时返回 $a$ 即可。

**复杂度**：$O(\log V)$。

复杂度证明：最坏情况是每次商 $k=1$，此时 $(a,b)$ 变成 $(b,a-b)$，数值下降最慢。设某一步的两个数为 $(A,B)$，下一步是 $(B,A-B)$，再下一步是 $(A-B,2B-A)$；相邻两项之和按斐波那契方式增长。反过来从终止状态 $(g,0)$ 倒推，步数 $t$ 对应的最小数对是斐波那契数列的第 $t$ 项，而斐波那契数按 $\varphi^t/\sqrt5$ 指数增长，所以 $t=O(\log V)$。因此欧几里得算法的时间复杂度为 $O(\log V)$。

**引理 4（算术基本定理）**：对于一个整数 $a$，存在唯一的质因数分解

$$
a=\prod p_i^{\alpha_i}.
$$

**引理 5**：$\max(a,b)+\min(a,b)=a+b$。

**引理 6**：$\operatorname{lcm}(a,b)\cdot \gcd(a,b)=ab$。

证明：

$$
ab=\prod p_i^{\alpha_i+\beta_i},
$$

$$
\gcd(a,b)=\prod p_i^{\min(\alpha_i,\beta_i)},\qquad
\operatorname{lcm}(a,b)=\prod p_i^{\max(\alpha_i,\beta_i)}.
$$

由引理 5，

$$
\operatorname{lcm}(a,b)\cdot \gcd(a,b)
=\prod p_i^{\min(\alpha_i,\beta_i)+\max(\alpha_i,\beta_i)}
=\prod p_i^{\alpha_i+\beta_i}=ab.
$$

于是得到计算 $\operatorname{lcm}$ 的方法：

$$
\operatorname{lcm}(a,b)=\frac{ab}{\gcd(a,b)}.
$$

**例题：B3634**（求两个数的最大公约数和最小公倍数）。按上面的公式计算即可，注意答案可能超过 `int`，需要开 `long long`。代码见「逐行代码解析」。

### 二、P1029 最大公约数和最小公倍数问题

题意：给定 $x_0,y_0$，求满足 $\gcd(P,Q)=x_0$、$\operatorname{lcm}(P,Q)=y_0$ 的有序正整数对 $(P,Q)$ 的数量。

**引理 7**：若 $a\cdot b=x$，则必有 $\min(a,b)\le \sqrt{x}$。

证明：若反设 $a>\sqrt{x}$ 且 $b>\sqrt{x}$，则 $a\cdot b>x$，产生矛盾。证毕。

由引理 6，$PQ=x_0y_0$。因为 $P,Q$ 的地位对称，我们可以只枚举较小的那个，最后再根据 $P=Q$ 与否计算贡献：

- 枚举范围：$P$ 从 $x_0$ 到 $\sqrt{x_0y_0}$，步长为 $x_0$（因为 $P$ 必须是 $x_0$ 的倍数）；
- 令 $Q=\dfrac{x_0y_0}{P}$，先判断 $P\mid x_0y_0$，再判断 $\gcd(P,Q)=x_0$；
- 若 $P=Q$，这一对只算 $1$ 次；若 $P\ne Q$，则 $(P,Q)$ 与 $(Q,P)$ 都合法，贡献为 $2$。

复杂度：枚举次数约为 $\dfrac{\sqrt{x_0y_0}}{x_0}=\sqrt{\dfrac{y_0}{x_0}}$，每次判断 gcd 为 $O(\log V)$，因此总复杂度为 $O\!\left(\sqrt{\dfrac{y_0}{x_0}}\log V\right)$；原文把枚举次数记为 $n$，写作 $O(n\log V)$。代码见「逐行代码解析」。

### 三、P1072 Hankson 的趣味题

题意：给定 $a_0,a_1,b_0,b_1$，求满足

$$
\gcd(x,a_0)=a_1,\qquad \operatorname{lcm}(x,b_0)=b_1
$$

的正整数 $x$ 的个数。

关键观察：由 $\operatorname{lcm}(x,b_0)=b_1$ 可知 $x\mid b_1$，所以合法数字一定是 $b_1$ 的一个因数。于是从 $1$ 枚举到 $\sqrt{b_1}$：

- 若 $i\mid b_1$，则 $i$ 和 $b_1/i$ 都是候选；
- 对每个候选 $x$，检查 $\gcd(x,a_0)=a_1$ 且 $\operatorname{lcm}(x,b_0)=b_1$；
- 若 $i=b_1/i$，只检查一次，避免重复计数。

判断时可以先看 $a_1\mid x$（这是 $\gcd(x,a_0)=a_1$ 的必要条件），再用 `__gcd` 计算两个条件。复杂度为 $O(n\sqrt{V}\log V)$。代码见「逐行代码解析」。

### 四、P1226 快速幂

**引理 8**：

$$
a^b=
\begin{cases}
(a^2)^{\lfloor b/2\rfloor}, & b\bmod 2=0,\\[2pt]
(a^2)^{\lfloor b/2\rfloor}\cdot a, & b\bmod 2=1.
\end{cases}
$$

由引理 8，可以不停把指数除以二向下取整、底数自乘，并用一个变量累乘“指数为奇数时多出来的那个 $a$”。循环维护的不变量是“`ans` 乘上当前的 $a^b$ 等于原式”。当 $b$ 变成 $0$ 时，`ans` 就是答案。

复杂度：指数每次减半，最多减半 $\log b$ 次，所以为 $O(\log b)$。代码见「逐行代码解析」。

### 五、U483926 龟速乘

龟速乘用于在不溢出的情况下完成大数相乘，代价是牺牲部分时间复杂度。~~其实已经被 `__int128` 上位替代~~。

**引理 9**：

$$
ab=
\begin{cases}
2a\lfloor b/2\rfloor, & b\bmod 2=0,\\[2pt]
a+2a\lfloor b/2\rfloor, & b\bmod 2=1.
\end{cases}
$$

用一个变量维护“余 $1$ 时多出来的 $a$”之和，每次迭代 $b=\lfloor b/2\rfloor$、$a=2a$，并对 $p$ 取模。复杂度为 $O(\log b)$，复杂度证明与快速幂相同。代码见「逐行代码解析」。

### 六、U185835 光速幂

光速幂在固定底数 $a$ 和模数 $p$ 的情况下，可以做到 $O(1)$ 查询 $a^b\bmod p$。

核心思想是根号分治和同余类划分。记指数的值域为 $V$，取阈值 $B=\sqrt V$（实际实现中通常略微放大，不影响复杂度平衡，同时防止越界）。预处理：

$$
f_x=a^x=af_{x-1},\qquad g_x=a^{Bx}=g_1g_{x-1},\qquad g_1=f_B,
$$

其中 $x\le B$。查询时把 $b$ 划分为 $b=kB+r$，其中 $k=\lfloor b/B\rfloor$、$r=b\bmod B$，则

$$
a^b=a^{kB+r}=a^{kB}\cdot a^r=g_k\cdot f_r.
$$

于是 $O(B)$ 预处理、$O(1)$ 计算。代码中取 $B\approx 10^5$，注意本题模数是 $998244352$，不是 $998244353$。代码见「逐行代码解析」。

### 七、P3383 线性筛

质数指只有 $1$ 和自己两个因数的正整数，不包括 $1$ 本身；否则会破坏算术基本定理。

线性筛（欧拉筛）让每个合数只被它的最小质因数筛掉一次，从而做到 $O(n)$。做法：

1. 从小到大遍历 $i$；
2. 若 $i$ 没有被标记，则 $i$ 是质数，加入质数表；
3. 用当前已得到的质数 $p_j$ 去筛 $i\cdot p_j$，并令 $i\cdot p_j$ 的最小质因数为 $p_j$；
4. 当 $i\bmod p_j=0$ 时立刻退出内层循环，保证每个合数只被最小质因数筛一次。

为什么每个合数都会被筛到：设合数 $x=i\cdot p$，其中 $p$ 是 $x$ 的最小质因数。因为 $i\ge 2$，所以 $i<x$、$p<x$。如果枚举到 $x$ 之前就中途退出了，说明存在更小的质数 $p'$ 整除 $i$，即 $kp'p=x$ 且 $p'<p$，这与 $p$ 是 $x$ 的最小质因数矛盾。因此枚举到 $i$ 时不会提前退出，$x$ 一定会被筛到。

复杂度：每个合数只被筛一次，时间为 $O(n)$；空间为 $O(n)$。代码见「逐行代码解析」。

### 八、P3951 小凯的疑惑

题意：对于 $\forall x\ge 0,y\ge 0$，$ax+by=N$，满足 $\gcd(a,b)=1$，求使得方程无解的最大 $N$。

**引理 10**：在模 $p$ 高维空间内，若 $k$ 与 $p$ 互质，则以 $k$ 为步长、固定方向向量走 $p-1$ 步，每步的落点都不一样。

证明：设第 $i$ 步的落点为 $X_i$，$i\in[0,p-1]$，方向向量为 $\vec v$，则 $X_i=X_0+i(k\vec v)$。反证：若 $X_i\equiv X_j\pmod p$，移项合并得 $(i-j)k\vec v\equiv 0\pmod p$，即 $p\mid (i-j)k\vec v$。因为 $\gcd(k,p)=1$ 且 $p>|i-j|$，所以这种情况不合法，不会出现落点一致的情况。

**引理 11**：当引理 10 的空间退化为 $1$ 维时，空间中只有 $p$ 个点，而我们走 $p-1$ 步到达 $p$ 个不同的点（考虑起点）。由引理 10，这是单射；定义域和值域集合大小相同，所以走 $p-1$ 步可以覆盖空间中所有的点，即满足双射关系。

**引理 12**：若 $x\mid y$，且 $k\mid x,k\mid y$，则 $\dfrac{x}{k}\mid \dfrac{y}{k}$。

证明：设 $y=\mu x$，则 $\dfrac{y}{k}=\mu\cdot\dfrac{x}{k}$，所以整除关系成立。

**引理 13**：对于整数 $a,b,c,d$，设 $\gcd(a,b)=g$。若 $bc\equiv bd\pmod a$，则消去 $b$ 后一定有 $c\equiv d\pmod{\dfrac{a}{g}}$。

证明：由同余式得 $a\mid b(c-d)$；由引理 12，$\dfrac{a}{g}\mid \dfrac{b}{g}(c-d)$。由于 $\gcd\!\left(\dfrac{a}{g},\dfrac{b}{g}\right)=1$，所以 $\dfrac{a}{g}\mid (c-d)$，即 $c\equiv d\pmod{\dfrac{a}{g}}$。

**引理 14**：对于题目所述方程，一定唯一存在一个 $y_0\in[0,a-1]$，满足 $y_0b\equiv N\pmod a$；$N$ 是合法的充要条件是 $N\ge y_0b$。

证明：由引理 11，满足双射关系，所以 $y_0$ 是唯一的。

- 充分性：若 $N\ge y_0b$，由于 $y_0b\equiv N\pmod a$ 且 $N\ge y_0b$，所以 $N-y_0b\equiv 0\pmod a$，即 $a\mid (N-y_0b)$。于是 $x_0=\dfrac{N-y_0b}{a}\ge 0$，得到一组非负整数解。
- 必要性：若有非负整数解 $N=ax+by$，两边同时对 $a$ 取模，得 $N\equiv yb\pmod a$。代入 $N\equiv y_0b\pmod a$，得 $y_0b\equiv yb\pmod a$。由于 $\gcd(a,b)=1$，由引理 13 得 $y\equiv y_0\pmod a$。又因为 $y_0\le a-1$ 且 $y\ge 0$，合法的最小同余类由 $y_0$ 占据，所以 $y\ge y_0$，从而 $N=ax+by\ge by_0$。证毕。

由引理 14 的逆否命题，$N$ 无非负整数解的充要条件是 $N<y_0b$。又因为 $N\equiv y_0b\pmod a$，所以在以 $y_0b\bmod a$ 为代表的同余类中，最大的无解整数必为 $y_0b-a$。

由引理 11，当 $y_0$ 遍历 $\{0,1,\dots,a-1\}$ 时，$y_0b\bmod a$ 不重不漏地覆盖模 $a$ 的全部 $a$ 个剩余类。每个同余类中最大的不可表示数即为

$$
f(y_0)=y_0b-a.
$$

由于 $b>0$，$f(y_0)$ 随 $y_0$ 增大而严格递增，所以全局最大的无解 $N$ 在 $y_0=a-1$ 时达到：

$$
(a-1)b-a=ab-a-b.
$$

代码只需输出 $ab-a-b$，见「逐行代码解析」。

#### 拓展 Q1：不可表示数的个数

**引理 14.3（对称反转引理）**：对于最大的不可表示数 $M=ab-a-b$，$n$ 和 $M-n$ 中恰好只有一个能被表示。

证明：

- 二者不可能都被表示：假设 $n=ax_1+by_1$，$M-n=ax_2+by_2$，则 $M=(x_1+x_2)a+(y_1+y_2)b$，与 $M$ 不可表示矛盾；
- 二者不可能都不被表示：若 $n$ 不能被表示，由引理 14，$n\le y_0b-a$，于是 $M-n\ge ab-a-b-(y_0b-a)=(a-y_0-1)b$。因为 $y_0\in[0,a-1]$，所以 $a-y_0-1\in[0,a-1]$；由引理 14，超过这个范围就是合法解。

不可表示数只会出现在 $[0,M]$ 中，共有 $ab-a-b+1=(a-1)(b-1)$ 个可能出现的数字。由引理 14.3，区间内的数字两两配对，所以不可表示数的个数为

$$
\frac{(a-1)(b-1)}{2}.
$$

#### 拓展 Q2：不可表示数的和

对于所有 $y_0\in[0,a-1]$，由引理 14，满足

$$
N=y_0b-ka,\qquad N\le y_0b-a,\qquad N>0
$$

的 $N$ 都是不可表示的。对于每个固定的 $y_0$，这些 $N$ 构成一个以 $a$ 为公差的等差数列。

**引理 14.7（连续自然数平方和）**：

$$
\sum_{i=1}^n i^2=\frac{2n^3+3n^2+n}{6}=\frac{n(n+1)(2n+1)}{6}.
$$

证明：离散情况下答案一定可以写作一个多项式。二次项连续求和，答案多项式最高次项是三次项，故设答案为 $An^3+Bn^2+Cn$。手算 $n=1,2,3$：

$$
\begin{cases}
A+B+C=1,\\
8A+4B+2C=5,\\
27A+9B+3C=14.
\end{cases}
$$

解得 $A=\dfrac13$，$B=\dfrac12$，$C=\dfrac16$，即

$$
\frac{n^3}{3}+\frac{n^2}{2}+\frac{n}{6}
=\frac{2n^3+3n^2+n}{6}
=\frac{n(n+1)(2n+1)}{6}.
$$

对于每个固定的 $y_0$，组内首项为 $y_0b-a$，末项为 $r=y_0b\bmod a$，项数为

$$
q=\left\lfloor\frac{y_0b}{a}\right\rfloor=\frac{y_0b-r}{a}.
$$

由等差数列求和公式，

$$
S=\frac{q(y_0b-a+r)}{2}
=\frac12\cdot\frac{y_0b-r}{a}\cdot(y_0b+r-a)
=\frac{1}{2a}\left(b^2y_0^2-r^2-aby_0+ar\right).
$$

对所有 $y_0$ 的贡献求和：

$$
\frac{1}{2a}\left(b^2\sum y_0^2-\sum r^2-ab\sum y_0+a\sum r\right).
$$

由引理 11，$\sum r=\sum y_0$、$\sum r^2=\sum y_0^2$，所以

$$
\frac{1}{2a}\left[(b^2-1)\sum y_0^2-a(b-1)\sum y_0\right].
$$

由引理 14.7 以及等差数列求和公式，并注意 $y_0$ 的取值范围是 $[0,a-1]$：

$$
\frac{1}{2a}\left[(b+1)(b-1)\frac{a(a-1)(2a-1)}{6}-a(b-1)\frac{a(a-1)}{2}\right]
=\frac{(a-1)(b-1)(2ab-a-b-1)}{12}.
$$

### 九、P4549 裴蜀定理

**引理 15（良序原理）**：对于自然数集的任意一个子集，一定有一个最小元素。

裴蜀定理：对于形如 $\sum a_ix_i=n$ 的方程，使其有整数解的最小正整数是所有 $a_i$ 的最大公约数，记为 $d$；所有使其有解的 $n$ 满足 $d\mid n$。

证明：方程解集与自然数集的交集，即正整数解集，一定是自然数集的一个子集。根据良序原理，一定存在一个最小元素 $m$。对于每一个 $a_j$，设 $a_j=qm+r$，则

$$
r=a_j-q\left(\sum a_ix_i\right)
=(1-q)a_j-q\sum_{i\ne j}a_ix_i,
$$

所以 $r$ 也是一个合法解。但 $r$ 是对 $m$ 取模的余数，所以 $r<m$；而 $m$ 是最小正整数解，所以只可能 $r=0$，也就是 $m\mid a_j$。因此 $m$ 是所有元素的公因数，所以 $m\le d$。

另一方面，$m$ 是这些元素的线性组合，由引理 1，$d$ 是它们的最大公因数，所以 $d$ 是它们线性组合的因数，满足 $d\mid m$，即 $d\le m$。于是 $d=m$。证毕。

本题输入可能是负数；负数和其相反数对于一个数的整除关系不变，所以直接取反求 $\gcd$ 即可。代码见「逐行代码解析」。

### 十、P3811 模逆元

定义：一个数 $x$ 在模 $p$ 意义下的逆元记作 $x^{-1}$，满足

$$
x\cdot x^{-1}\equiv 1\pmod p.
$$

逆元的线性递推：设 $p=\left\lfloor\dfrac{p}{i}\right\rfloor i+p\bmod i$，记 $k=\left\lfloor\dfrac{p}{i}\right\rfloor$，$r=p\bmod i$，则 $ki+r\equiv 0\pmod p$。两边同时乘 $i^{-1}r^{-1}$，得到

$$
kr^{-1}+i^{-1}\equiv 0\pmod p,
$$

即

$$
i^{-1}\equiv -kr^{-1}\pmod p.
$$

为了使结果大于 $0$，给负数项加上一个 $p$，得到最终递推式：

$$
i^{-1}=\left(p-\left\lfloor\frac{p}{i}\right\rfloor\right)(p\bmod i)^{-1}\pmod p.
$$

复杂度 $O(n)$。代码见「逐行代码解析」。

### 十一、P9774 新取模运算与威尔逊定理

题意：定义新运算 $x\oplus y$。如果 $x$ 不是 $y$ 的倍数，则得到 $x$ 除以 $y$ 的余数；否则令 $x$ 不断除以 $y$ 直到 $x$ 不再是 $y$ 的倍数，设此时为 $x'$，然后得到 $x'$ 除以 $y$ 的余数。给定质数 $p$，多组询问 $n$，求 $n!\oplus p$。

**引理 16**：若 $a\equiv b\pmod p$，且 $d\mid p$，则 $a\equiv b\pmod d$。

证明：$p\mid (a-b)$，所以 $d\mid (a-b)$，即 $a-b\equiv 0\pmod d$，因此 $a\equiv b\pmod d$。

**引理 17**：若 $p$ 是质数，则 $[0,p-1]$ 范围内所有数字的逆元一定落在 $[0,p-1]$ 范围内，且不重不漏。

证明：逆元是在模 $p$ 意义下定义的，所以一定在 $[0,p-1]$ 范围内。假设一个数字 $x$ 有两个逆元 $a_1,a_2$，则

$$
xa_1\equiv 1\pmod p,\qquad xa_2\equiv 1\pmod p.
$$

两式相减得 $(a_1-a_2)x\equiv 0\pmod p$。因为 $p$ 是质数且 $1\le x\le p-1$，所以 $p\nmid x$，从而 $a_1\equiv a_2\pmod p$，逆元唯一。由于逆元不重，集合大小相等，所以逆元不漏。

**引理 18（威尔逊定理）**：一个大于 $1$ 的整数 $p$ 是质数的充要条件是

$$
(p-1)!\equiv -1\pmod p.
$$

证明：

- 充分性（$p$ 为质数）：在 $1,2,\dots,p-1$ 中，每个数 $x$ 都有唯一的逆元 $x^{-1}\in[1,p-1]$（引理 17）。把 $x$ 与 $x^{-1}$ 配对；若 $x\ne x^{-1}$，这一对的乘积为 $1$。满足 $x=x^{-1}$ 的只有 $x^2\equiv 1\pmod p$ 的解，即 $x\equiv 1$ 或 $x\equiv -1\pmod p$。除了 $1$ 和 $p-1$ 之外，其余数全部两两配对消成 $1$，所以
  $$
  (p-1)!\equiv 1\cdot(p-1)\equiv -1\pmod p.
  $$
- 必要性（$p$ 为合数）：若 $p=4$，$3!=6\equiv 2\not\equiv -1\pmod 4$。若 $p>4$ 且为合数，分两种情况：
  - 若 $p$ 不是完全平方数，设 $p=uv$，其中 $1<u<v<p$，则 $u$ 和 $v$ 都出现在 $(p-1)!$ 的因子中，所以 $p=uv\mid (p-1)!$；
  - 若 $p=r^2$ 且 $r>2$，则 $r$ 和 $2r$ 都小于 $p$ 且出现在 $(p-1)!$ 的因子中，二者贡献至少两个因子 $r$，所以 $r^2=p\mid (p-1)!$。

  因此合数情形下 $(p-1)!\equiv 0\pmod p$，不可能等于 $-1$。

现在回到 $n!\oplus p$。设 $e=v_p(n!)=\sum_{k\ge1}\left\lfloor\dfrac{n}{p^k}\right\rfloor$。按定义，$n!\oplus p$ 就是

$$
\frac{n!}{p^e}\bmod p.
$$

令

$$
F(n)=\prod_{\substack{1\le i\le n\\ p\nmid i}}i,
$$

即 $1\sim n$ 中所有不被 $p$ 整除的数的乘积。把 $n!$ 中的 $p$ 因子逐层剥掉：

$$
\frac{n!}{p^{v_p(n!)}}=F(n)\cdot F\!\left(\left\lfloor\frac np\right\rfloor\right)\cdot F\!\left(\left\lfloor\frac n{p^2}\right\rfloor\right)\cdots
=\prod_{k\ge0}F\!\left(\left\lfloor\frac n{p^k}\right\rfloor\right).
$$

这是因为所有被 $p$ 整除的数都可以写成 $p\cdot j$，提走一个 $p$ 后，剩下的部分正好是 $\left\lfloor n/p\right\rfloor!$，递归处理即可。

接下来计算 $F(n)$。设 $n=qp+r$（$0\le r<p$）。在 $1\sim n$ 中，不被 $p$ 整除的数由 $q$ 个完整的块 $[kp+1,kp+p-1]$ 和一个不完整的块 $[qp+1,qp+r]$ 组成。每个完整块的乘积为 $(p-1)!\equiv -1\pmod p$（威尔逊定理），不完整块的乘积为 $r!$，所以

$$
F(n)\equiv (-1)^q\cdot r!\pmod p.
$$

于是可以 $O(p)$ 预处理 $fact[0..p-1]$（$fact[r]=r!\bmod p$），每次询问按下面的递推逐层计算。令 $m_0=n$，$q_i=\left\lfloor m_i/p\right\rfloor$，$r_i=m_i\bmod p$，$m_{i+1}=q_i$，则

$$
ans=\prod_{i\ge0}(-1)^{q_i}\cdot fact[r_i]\pmod p.
$$

具体地，令 $m=n$，不断执行：

- $q=\left\lfloor m/p\right\rfloor$，$r=m\bmod p$；
- 若 $q$ 为奇数，答案乘 $-1$（即取 $p-ans$）；
- 答案乘 $fact[r]$；
- 令 $m=q$，直到 $m=0$。

伪代码如下：

```text
read T, p
fact[0] = 1
for i = 1 .. p-1:
    fact[i] = fact[i-1] * i mod p

for each query n:
    ans = 1
    m = n
    while m > 0:
        q = m / p
        r = m mod p
        if q is odd:
            ans = (-ans) mod p
        ans = ans * fact[r] mod p
        m = q
    print ans
```

复杂度：预处理 $O(p)$，每次询问 $O(\log_p n)$，总时间 $O(p+T\log_p n)$，空间 $O(p)$。在 $p\le 10^6$、$T\le 10^5$、$n\le 10^{18}$ 的数据范围内可以接受。注意 $p=2$ 时 `fact` 只有两个元素，循环和取模都要正确处理。

---

## 核心公式 / 状态定义与转移方程

- 欧几里得算法：$\gcd(a,b)=\gcd(b,a\bmod b)$，边界 $\gcd(a,0)=a$。
- 最小公倍数：$\operatorname{lcm}(a,b)=\dfrac{ab}{\gcd(a,b)}$。
- 引理 7：若 $ab=x$，则 $\min(a,b)\le\sqrt x$。
- 快速幂：$a^b=(a^2)^{\lfloor b/2\rfloor}\cdot a^{[b\bmod 2]}$。
- 龟速乘：$ab=2a\lfloor b/2\rfloor+a\cdot[b\bmod 2]$。
- 光速幂：$a^b=a^{kB+r}=g_k f_r$，其中 $B$ 为块长，$k=\lfloor b/B\rfloor$，$r=b\bmod B$。
- 欧拉筛：对每个 $i$，用质数 $p_j$ 筛 $i\cdot p_j$；当 $i\bmod p_j=0$ 时退出。
- 裴蜀定理：$\sum a_ix_i=n$ 有整数解 $\iff \gcd(a_1,\dots,a_k)\mid n$；最小正整数解为 $\gcd(a_1,\dots,a_k)$。
- 模逆元递推：$i^{-1}\equiv\left(p-\left\lfloor\dfrac pi\right\rfloor\right)(p\bmod i)^{-1}\pmod p$。
- 威尔逊定理：$p$ 为质数 $\iff (p-1)!\equiv -1\pmod p$。
- P9774：$F(n)\equiv(-1)^{\lfloor n/p\rfloor}(n\bmod p)!\pmod p$，答案为 $\prod_{k\ge0}F(\lfloor n/p^k\rfloor)\bmod p$。
- 小凯的疑惑：最大不可表示数 $ab-a-b$；不可表示数个数 $\dfrac{(a-1)(b-1)}2$；不可表示数之和 $\dfrac{(a-1)(b-1)(2ab-a-b-1)}{12}$。

---

## 逐行代码解析

### gcd / lcm（B3634）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int gcd(int a,int b){
    return b==0?a:gcd(b,a%b);
}
signed main()
{
    int a,b;
    cin>>a>>b;
    int k=gcd(a,b);
    cout<<k<<" "<<a*b/k;
    return 0;
}
```

- `gcd` 用递归实现欧几里得算法，边界是 `b==0` 时返回 `a`。
- `#define int long long` 后，`main` 要写成 `signed main`。
- 输出最大公约数和最小公倍数；`a*b/k` 利用引理 6，注意 `a*b` 可能很大，所以前面开了 `long long`。
- 更稳妥的写法是 `a/gcd(a,b)*b`，可以进一步降低溢出的风险。

### P1029 最大公约数和最小公倍数问题

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long 
signed main()
{
    int x,y;cin>>x>>y;
    int mul=x*y;
    int lim=sqrt(mul);
    int ans=0;
    for(int i=x;i<=lim;i+=x)
    {
        if(mul%i==0)
        {
            int j=mul/i;
            if(__gcd(i,j)==x)
            {
                if(i==j) ans++;
                if(i!=j) ans+=2;
            }
        }
    }
    cout<<ans;
    return 0;
}
```

- `mul=x*y` 是 $PQ$ 的固定值；由引理 7，只需枚举到 `sqrt(mul)`。
- `i+=x` 保证枚举的 $P$ 一定是 $x_0$ 的倍数。
- `mul%i==0` 保证 $Q$ 是整数；`__gcd(i,j)==x` 检查最大公约数条件。
- `i==j` 时只算一对，否则 $(i,j)$ 与 $(j,i)$ 都合法，答案加 $2$。
- `sqrt` 返回浮点数，数据很大时要注意精度；必要时可以用整数二分或 `sqrtl`。

### P1072 Hankson 的趣味题

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int a0,a1,b0,b1;
bool jud(int x)
{
    if(x%a1) return false;
    return (__gcd(x,a0)==a1)&&(x*b0/__gcd(x,b0)==b1);
}
signed main()
{
    int n;cin>>n;
    while(n--)
    {
        cin>>a0>>a1>>b0>>b1;
        int lim=(int)sqrt(b1);
        int ans=0;
        for(int i=1;i<=lim;i++)
        {
            if(b1%i==0)
            {
                if(i==b1/i){
                    if(jud(i))
                        ans++;
                }
                else {
                    if(jud(i)) ans++;
                    if(jud(b1/i)) ans++;
                }                
            }
        }
        cout<<ans<<"\n";
    }
    return 0;
}
```

- 合法 $x$ 一定是 $b_1$ 的因数，所以枚举到 $\sqrt{b_1}$ 即可覆盖所有因数对。
- `jud` 中先用 `x%a1` 排除不可能满足 $\gcd(x,a_0)=a_1$ 的数。
- `x*b0/__gcd(x,b0)` 计算 $\operatorname{lcm}(x,b_0)$；这里先除后乘更稳，但原代码是先乘后除，数据范围内能过。
- `i==b1/i` 时只检查一次，避免完全平方因数被重复计数。
- 多测共用全局变量 `a0,a1,b0,b1`，每轮都会重新读入，不需要额外清空。

### 快速幂（P1226）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int p;
int fpow(int a,int b)
{
    int ans=1;
    while(b)
    {
        if(b%2==1) ans=(ans*a)%p;
        a=(a*a)%p;
        b/=2;
    }
    return ans;
}
signed main()
{
    int a,b;
    cin>>a>>b>>p;
    cout<<a<<"^"<<b<<" mod "<<p<<"="<<fpow(a,b);
    return 0;
}
```

- 循环不变量：`ans * a^b` 始终等于原式（模 `p`）。
- `b%2==1` 时把当前的 `a` 乘进 `ans`；随后 `a` 自乘、`b` 减半。
- `b=0` 时循环结束，`ans` 就是答案；`p=1` 时所有结果模 $1$ 都是 $0$。若题目允许 `p=1` 且 `b=0`，原实现会直接返回 $1$，与 $1\bmod 1=0$ 不一致，需要按题目数据范围确认是否要特判。
- `a` 可能在自乘时超过 `long long`，应保证先取模；原代码在乘完后取模，数据范围内需要确认 `a*a` 不溢出。

### 龟速乘（U483926）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int mul(int a,int b,int p)
{
    int ans=0;
    while(b)
    {
        if(b%2==1) ans=(ans+a)%p;
        a=(a+a)%p;b/=2;
    }
    return ans;
}
signed main()
{
    ios::sync_with_stdio(false);
    cin.tie(0);
    int t;cin>>t;
    while(t--)
    {
        int a,b,p;
        cin>>a>>b>>p;
        cout<<mul(a,b,p)<<'\n';        
    }
    return 0;
}
```

- 与快速幂结构相同，只是把“乘法”换成“加法”：`ans` 累加 `a`，`a` 每次翻倍。
- 每一步都对 `p` 取模，保证 `ans+a` 和 `a+a` 不溢出。
- 复杂度 $O(\log b)$；在支持 `__int128` 的环境里，直接 `a*b%p` 通常更快。
- 多测注意清空是天然的：`ans` 在 `mul` 内部初始化，`a,b,p` 每轮重新读入。

### 光速幂（U185835）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e5+5;
const int p=998244352;
int pw1[N];
int pw2[N];
signed main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int x,n;
    cin>>x>>n;
    pw1[0]=1;
    int lim=(int)(N-100);
    for(int i=1;i<=lim;i++)
        pw1[i]=(pw1[i-1]*x)%p;
    pw2[0]=1;
    pw2[1]=(pw1[lim-1]*x)%p;
    for(int i=2;i<=lim;i++)
        pw2[i]=(pw2[i-1]*pw2[1])%p;
    while(n--)
    {
        int a;cin>>a;
        int r=a%lim;
        int k=a/lim;
        cout<<(pw2[k]*pw1[r])%p<<" ";
    }
    return 0;
}
```

- `pw1[i]` 存 $x^i$，`pw2[i]` 存 $x^{i\cdot lim}$；`pw2[1]=pw1[lim-1]*x` 正好是 $x^{lim}$。
- 查询指数 `a` 时，`r=a%lim`、`k=a/lim`，答案是 `pw2[k]*pw1[r]%p`。
- 模数是 `998244352`，不是常见的 `998244353`，这是本题最容易看错的地方。
- `lim` 取得略小于 `N`，是为了给 `pw1[lim-1]` 和 `pw2` 留出边界；查询的 `k` 不能超过 `lim`，否则 `pw2[k]` 越界。

### 线性筛（P3383）

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e8+5;
bitset<N> st;
const int M=1e7+5;
int p[M],cnt;
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    for(int i=2;i<N;i++)
    {
        if(!st[i]) {p[++cnt]=i;}
        for(int j=1;j<=cnt;j++)
        {
            if(1LL*i*p[j]>=N) break;
            st[i*p[j]]=1;
            if(i%p[j]==0) break;
        }
    }
    int n,q;cin>>n>>q;
    while(q--)
    {
        int k;cin>>k;
        cout<<p[k]<<"\n";
    }
    return 0;
}
```

- `st[i]` 表示 $i$ 是否被筛掉；`p[1..cnt]` 存质数。
- 外层枚举 $i$，若 `!st[i]` 则 $i$ 是质数。
- 内层用已得到的质数去筛 $i\cdot p_j$；`1LL*i*p[j]` 防止乘法溢出。
- `i%p[j]==0` 时退出，保证每个合数只被最小质因数筛一次。
- 预处理范围写死到 `N`，查询只读 `p[k]`；本题 $n$ 最大 $10^8$，`bitset` 比 `bool` 数组更省空间。

### P3951 小凯的疑惑

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
signed main()
{
    int a,b;
    cin>>a>>b;
    cout<<a*b-a-b;
    return 0;
}
```

- 由引理 14 及后续推导，答案就是 $ab-a-b$。
- `a*b` 可能超过 `int`，所以开 `long long`。
- 题目保证 $\gcd(a,b)=1$；若没有这个条件，公式不成立。

### P4549 裴蜀定理

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
signed main()
{
    int n;cin>>n;
    int x;cin>>x;
    x=abs(x);
    for(int i=2;i<=n;i++)
    {
        int a;cin>>a;
        x=__gcd(x,abs(a));
    }
    cout<<x;
    return 0;
}
```

- 先读入第一个数并取绝对值，作为当前的 gcd。
- 后面每个数取绝对值后与当前 gcd 再取 gcd；最终就是所有数的最大公约数。
- 裴蜀定理保证这个 gcd 就是方程有整数解时的最小正整数。
- `n=0` 的情况题目通常不会给；若给了，这段代码会读不到 `x`，需要额外特判。

### P3811 模逆元

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=3e6+5;
int inv[N];
signed main()
{
    inv[0]=1;
    inv[1]=1;
    cout<<1<<"\n";
    int n,p;cin>>n>>p;
    for(int i=2;i<=n;i++)
    {
        inv[i]=((p-(p/i))*(inv[p%i]))%p;
        cout<<inv[i]<<"\n";
    }
    return 0;
}
```

- `inv[1]=1` 是递推边界；先输出 $1$ 的逆元。
- 递推式 `inv[i]=((p-(p/i))*inv[p%i])%p` 对应上面的公式。
- `p%i` 一定小于 `i`，所以 `inv[p%i]` 已经算过；这就是线性递推成立的原因。
- 需要保证 $p$ 是质数且 $i<p$，否则 `p%i` 可能为 $0$，`inv[0]` 没有意义。

### P9774 新取模运算（伪代码）

```text
read T, p
fact[0] = 1
for i = 1 .. p-1:
    fact[i] = fact[i-1] * i mod p

for each query n:
    ans = 1
    m = n
    while m > 0:
        q = m / p
        r = m mod p
        if q is odd:
            ans = (-ans) mod p
        ans = ans * fact[r] mod p
        m = q
    print ans
```

- `fact[r]` 是 $r! \bmod p$，预处理到 $p-1$ 即可；由威尔逊定理，完整块的乘积是 $-1$。
- 每层剥掉一个 $p$，直到 $m=0$；循环次数是 $O(\log_p n)$。
- 若 `q` 为奇数，完整块有奇数个，乘积为 $-1$，所以答案取负。
- 这是伪代码，具体 C++ 实现由你本人完成；注意 $p\le 10^6$、$n\le 10^{18}$，要开 `long long` 并使用快速输入输出。

---

## 复杂度分析

| 算法 / 题目 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 欧几里得算法 | $O(\log V)$ | $O(1)$（递归栈 $O(\log V)$） |
| B3634 gcd/lcm | $O(\log V)$ | $O(1)$ |
| P1029 | $O\!\left(\sqrt{y_0/x_0}\log V\right)$ | $O(1)$ |
| P1072 | $O(n\sqrt V\log V)$ | $O(1)$ |
| 快速幂 P1226 | $O(\log b)$ | $O(1)$ |
| 龟速乘 U483926 | $O(\log b)$ | $O(1)$ |
| 光速幂 U185835 | $O(B+T)$ | $O(B)$ |
| 线性筛 P3383 | $O(n)$ | $O(n)$ |
| P3951 | $O(1)$ | $O(1)$ |
| 裴蜀定理 P4549 | $O(n\log V)$ | $O(1)$ |
| 模逆元 P3811 | $O(n)$ | $O(n)$ |
| P9774 | $O(p+T\log_p n)$ | $O(p)$ |

其中 $V$ 是数值值域，$B$ 是光速幂的块长，$n$ 在不同题目中分别表示枚举量、元素个数或筛的范围。

---

## 适用场景

- **gcd / lcm**：约分、比例、周期、同余方程、分数运算，以及所有需要“公共因子”的题目。
- **欧几里得算法**：求最大公约数、判断互质、解线性同余方程的基础。
- **快速幂**：模意义下的大指数幂、矩阵快速幂、递推加速。
- **龟速乘**：模数很大且没有 `__int128` 时，防止乘法溢出；现代比赛通常直接用 `__int128`。
- **光速幂**：底数和模数固定、询问次数很多的幂运算，例如固定底数的多次查询。
- **线性筛**：需要 $1\sim n$ 内所有质数，或需要在线性时间内预处理积性函数。
- **裴蜀定理**：判断线性组合能否表示某个数，求最小正整数表示，处理负数和多变量 gcd。
- **模逆元**：模意义下的除法、组合数、解同余方程；线性递推适合求 $1\sim n$ 的全部逆元。
- **威尔逊定理**：质数判定、阶乘模质数的化简，以及 P9774 这类“剥掉质因子后取模”的问题。
- **小凯的疑惑**：两个互质数的线性组合不可表示数问题；拓展公式可用于计数与求和。

---

## 常见陷阱与注意事项

1. **`long long` 溢出**：`a*b` 在 $a,b\le 10^9$ 时就会超过 `int`；lcm 更稳妥的写法是 `a/gcd(a,b)*b`。
2. **`sqrt` 精度**：`sqrt` 返回浮点数，数值很大时可能差 $1$；枚举约数时可以用整数二分或 `sqrtl` 并微调。
3. **负数 gcd**：`__gcd` 对负数可能返回负值；P4549 中统一取 `abs`，最后输出正数。
4. **快速幂的边界**：`b=0` 时答案是 $1\bmod p$；`p=1` 时答案是 $0$；底数为负时先取模归一化。
5. **龟速乘的边界**：`p=1` 时所有结果都是 $0$；`a` 要先对 `p` 取模，避免加法溢出。
6. **光速幂的模数**：本题是 $998244352$，不是 $998244353$；预处理块长和查询上界要匹配，`pw2[k]` 不能越界。
7. **线性筛的退出条件**：必须在 `i%p[j]==0` 时退出，否则同一个合数会被多个质因数重复筛，复杂度退化。
8. **P3951 的前提**：必须 $\gcd(a,b)=1$；答案是 $ab-a-b$，不是 $ab$ 或其他形式。
9. **裴蜀定理的输入**：可能含负数；`n=0` 要特判；多变量时要对所有数取 gcd，而不是只看前两个。
10. **模逆元的前提**：$p$ 必须是质数且 $i<p$；递推中 `p%i` 必须非零，否则 `inv[0]` 无意义。
11. **P9774 的符号**：完整块的乘积是 $-1$，块数为奇数时答案要取负；`n` 很大，必须用 `long long`。
12. **多测清空**：P1029、P1072、龟速乘、光速幂都是多测；局部变量在循环内定义最省心，全局数组要手动清空。
13. **LaTeX 书写**：本笔记公式较多，表格里不要出现裸的 `|`；行内公式的定界符要成对。

---

## 对比与扩展

- **快速幂 vs 龟速乘 vs 光速幂**：快速幂解决“大指数”，龟速乘解决“大乘积溢出”，光速幂解决“固定底数的多次查询”。三者的共同结构都是把指数二进制或分块拆开。
- **欧几里得算法 vs 更相减损术**：更相减损术在数值差距很大时可能退化，欧几里得算法用取模把复杂度压到 $O(\log V)$。
- **线性筛 vs 埃氏筛**：埃氏筛是 $O(n\log\log n)$，写法简单；线性筛是 $O(n)$，适合需要最小质因数或积性函数预处理的场景。
- **裴蜀定理 vs 扩展欧几里得**：裴蜀定理回答“有没有解、最小正整数是多少”，扩展欧几里得给出具体的 $x,y$；两者常配合使用。
- **威尔逊定理 vs 费马小定理**：威尔逊定理给出阶乘与 $-1$ 的关系，适合处理阶乘模质数；费马小定理给出 $a^{p-1}\equiv1$，适合求逆元和快速幂。
- **P3951 的两个拓展**：不可表示数的个数为 $\dfrac{(a-1)(b-1)}2$，和为 $\dfrac{(a-1)(b-1)(2ab-a-b-1)}{12}$；推导都依赖“同余类双射 + 对称配对”。
- **P9774 的可迁移性**：凡是“把阶乘中的所有质因子 $p$ 剥掉再取模”的问题，都可以用“完整块 + 余块 + 威尔逊定理”的套路，复杂度只与 $p$ 和 $\log_p n$ 有关。$AKB322$, '数学', array['数论', 'gcd', '快速幂', '龟速乘', '光速幂', '线性筛', '裴蜀定理', '模逆元'], 'col-hub-math-number-theory', null, 'knowledge'),
('Xesir', 'col-math-number-theory-basic--xesir', '数论基础（整除 / 约数 / gcd / 积性函数 / 取整） · Xesir', $AKB323$## 算法原理

在开始之前，我们先花两分钟把一些最基础的概念理清楚，它们会像地基一样支撑起后面所有数论知识。

### 整除

**整除**是整个数论里最核心的概念之一。它的定义很简单：对于两个整数 $a$、$b$（其中 $a \neq 0$），如果存在一个整数 $q$，使得 $b = aq$，我们就说 **$a$ 整除 $b$**，记作 $a \mid b$。反过来，如果不存在这样的 $q$，就记作 $a \nmid b$。

用人话说就是：**$b$ 能不能被 $a$ 整除，看 $b$ 是不是 $a$ 的整数倍。** 比如 $3 \mid 6$（因为 $6 = 3 \times 2$），但 $4 \nmid 6$（因为找不到整数 $q$ 使 $6 = 4q$）。

整除有几个很常用的性质：

- 如果 $a \mid b$ 且 $b \mid c$，那么 $a \mid c$（传递性）。
- 如果 $a \mid b$ 且 $a \mid c$，那么对于任意整数 $x, y$，都有 $a \mid (xb + yc)$（线性组合）。
- 如果 $a \mid b$ 且 $b \mid a$，那么 $b = \pm a$（互相整除只差一个符号）。
- 如果 $a \neq 0$，$b = qa + c$，那么 $a \mid b \iff a \mid c$（余数不影响整除性）。

最后这条特别有用——它告诉我们，判断 $a$ 能不能整除一个数，只需要看它除以 $a$ 的**余数**是不是 0 就行了。

### 约数

如果 $a \mid b$，我们就说 $a$ 是 $b$ 的**约数**（也叫因数）。比如 $6$ 的约数有 $1, 2, 3, 6$。

关于约数有个小性质：当 $b \neq 0$ 时，如果 $d$ 遍历 $b$ 的所有约数，那么 $\frac{b}{d}$ 也会遍历 $b$ 的所有约数。换句话说，**约数是成对出现的**——$d$ 和 $b/d$ 总是一对。比如 $12$ 的约数对是 $(1,12), (2,6), (3,4)$。这就是枚举约数只需要枚举到 $\sqrt b$ 的原因。

### 带余数除法

这是我们小学就学过的"除法有余数"的正式说法：对于整数 $a, b$（$a \neq 0$），存在唯一的整数 $q$ 和 $r$，使得 $b = qa + r$，$0 \le r < |a|$，其中 $q$ 叫**商**，$r$ 叫**余数**。

注意余数的范围是 $0$ 到 $|a|-1$，这个叫**最小非负余数**——如果没有特别说明，我们说的"余数"指的就是它。取余运算又被叫做模运算，是后面很重要的内容。

### 最大公约数与最小公倍数

**最大公约数**（gcd）是两个或多个整数共有的约数中最大的那个，记作 $(a, b)$ 或 $\gcd(a, b)$，比如 $\gcd(12, 18) = 6$。**最小公倍数**（lcm）是两个或多个整数共有的倍数中最小的那个正数，记作 $[a, b]$ 或 $\operatorname{lcm}(a, b)$。

求解上，朴素的 gcd 是辗转相除法，原理可自行了解。`std` 库中的 `__gcd()` 函数就是采用该方法实现，故一般情况下直接使用无需手写。lcm 则因为下面那条乘积关系，全部转成 gcd 来求。

### 加性函数与积性函数

数论里有一类函数叫**加性函数**：$f(1) = 0$，且对于任意互质的正整数 $x, y$，都有 $f(xy) = f(x) + f(y)$。如果连"互质"这个条件都不需要，就叫**完全加性函数**。

另一类核心函数叫**积性函数**：$f(1) = 1$，且对于任意互质的正整数 $x, y$，都有 $f(xy) = f(x)f(y)$。如果连"互质"这个条件都不需要，就叫**完全积性函数**。

这些函数在数论里无处不在，在很多问题中积性性质往往是化繁为简的关键：只需知道它在素数幂处的取值，就能由乘法性拼出所有整数的值。由于这一特性，它们也全都能被线性筛 $O(n)$ 地预处理出在 $1 \sim n$ 中的值。

### 取整函数

- **下取整**（floor）：$\lfloor x \rfloor$ 是不超过 $x$ 的最大整数。
- **上取整**（ceil）：$\lceil x \rceil$ 是不小于 $x$ 的最小整数。

这就是数论最基础的一批概念。它们单独看都很简单，但组合起来就能解决非常复杂的问题，后面我们会一个一个展开。

> **关于 0 的约数**：部分教材认为 0 的约数有无穷多个（任何非零整数都能整除 0），因此在讨论约数时通常默认不考虑 0。做题时也请留意题目是否特判了 0 的情况。

## 核心公式 / 状态定义与转移方程

**带余数除法**（余数取最小非负值）：

$$
b = qa + r, \qquad 0 \le r < |a|
$$

**余数的两条直观性质**：任一整数被正整数 $a$ 除后，余数一定是 $0$ 到 $a-1$ 中的一个；任意连续的 $a$ 个整数被 $a$ 除后，恰好各取到上述 $a$ 个余数各一次，特别地**一定有且仅有一个数能被 $a$ 整除**。

**gcd 的常用性质**：

- $(a, b) = (b, a)$（交换律）。
- 若 $a \neq 0$，则 $(a, 0) = |a|$。
- $(bq + r, b) = (r, b)$——这就是**辗转相除法**的理论依据。
- $(a_1, a_2, \dots, a_n) = ((a_1, a_2), a_3, \dots, a_n)$（可以逐个求）。

**gcd 与 lcm 的关系**：

$$
(a, b) \cdot [a, b] = |a \cdot b|
$$

也就是"两数之积等于它们的最大公约数乘以最小公倍数"，所以实现上 lcm 都是直接转换为 gcd 进行求解。

**常见数论函数一览**：

- $\nu_p(n)$：$n$ 的质因数分解中质数 $p$ 的指数（完全加性）。
- $\Omega(n)$：$n$ 的所有质因子总数，带重数（完全加性）。
- $\omega(n)$：$n$ 的相异质因子个数，等于 $\sum_{p \mid n} 1$（加性，但**不是**完全加性）。
- $\varphi(n)$：$1$ 到 $n$ 中与 $n$ 互质的数的个数（积性）。
- $\sigma_k(n)$：$n$ 的所有正因数的 $k$ 次幂之和（积性）；$\sigma_0(n) = d(n)$ 是因数个数，$\sigma_1(n) = \sigma(n)$ 是因数和。
- $\mu(n)$：莫比乌斯函数，$n$ 有平方质因子时为 $0$，否则为 $(-1)^{\omega(n)}$（积性）。
- $\mathrm{id}(n) = n$（恒等函数）与 $\mathbf{1}(n) = 1$（常函数）：完全积性。

**取整函数的基本性质**：

$$
x - 1 < \lfloor x \rfloor \le x \le \lceil x \rceil < x + 1
$$

$x \in \mathbb{Z} \iff x = \lfloor x \rfloor = \lceil x \rceil$；并且

$$
\lceil x \rceil - \lfloor x \rfloor = \begin{cases} 0, & x \in \mathbb{Z} \\ 1, & x \notin \mathbb{Z} \end{cases}
$$

简单说：$\lfloor 3.7 \rfloor = 3$，$\lceil 3.7 \rceil = 4$；$\lfloor -2.3 \rfloor = -3$，$\lceil -2.3 \rceil = -2$。

## 逐行代码解析

原文给的是三段可以直接抄的 gcd / lcm 实现，这里按"辗转相除 → 二进制 gcd → lcm"的顺序拆开讲。注意原文省略了 `typedef long long ll;`，也没写头文件。

### 模块一：辗转相除法

```cpp
ll gcd(ll a, ll b) {
    while (b != 0) {
        ll temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
```

- 依据就是 $(bq + r, b) = (r, b)$：令 $r = a \bmod b$，则 $\gcd(a, b) = \gcd(b, r)$。
- 用 `temp` 暂存 `b`，是因为 `b` 先被 `a % b` 覆盖了，`a` 还要拿原来的 `b`。
- 循环到 `b == 0` 时返回 `a`，对应 $(a, 0) = |a|$。
- 不需要预先保证 $a \ge b$：若 $a < b$，第一轮 `a % b == a`，相当于自动交换了两数。

### 模块二：二进制 gcd

```cpp
int gcd(int a, int b) {
    if (!a || !b) return a | b;
    int aa = __builtin_ctz(a), bb = __builtin_ctz(b), k = min(aa, bb);
    b >>= bb;
    while (a) {
        a >>= aa;
        int tmp = b - a;
        aa = __builtin_ctz(tmp);
        b = min(a, b);
        a = abs(tmp);
    }
    return b << k;
}
```

算法流程就是四条规则：都是偶数则提一个 2 出来；一奇一偶则把偶数除掉 2；都是奇数则用减法的 gcd。所有操作都能用位运算实现，所以常数很小，一般在极度卡常题中使用。

- `if (!a || !b) return a | b;`：有一个是 0 时，`a | b` 恰好是那个非零数，省掉一次分支。
- `__builtin_ctz(x)` 数的是二进制末尾 0 的个数，等价于"最多能右移几次还是整数"，正好是 $2$ 的指数部分。
- `k = min(aa, bb)` 是公共的 2 的幂次，最后统一 `b << k` 补回去。
- 循环里 `b` 始终被保持成奇数，`a` 每轮先右移成奇数，两个奇数相减得到偶数，恰好把公共的 2 的因子消掉，再用 `min` 和 `abs` 让下一轮的两个数非负且有序。

### 模块三：lcm

```cpp
ll lcm(ll a, ll b) {
    return a / gcd(a, b) * b;
}
```

- 依据 $(a,b)\cdot[a,b] = |ab|$，所以 $[a,b] = a/\gcd(a,b) \cdot b$。
- 必须**先除后乘**：直接 `a * b / gcd` 在 $a,b$ 都是 $10^9$ 级别时中间结果就爆 `long long` 了。
- 这里调用的 `gcd` 是模块一那个 `ll` 版本（模块二是 `int` 版本，不匹配）。

## 复杂度分析

| 操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 辗转相除法求 gcd | $O(\log \min(a,b))$ | $O(1)$（迭代） |
| 二进制 gcd | $O(\log \min(a,b))$ | $O(1)$ |
| 由 gcd 求 lcm | $O(\log \min(a,b))$ | $O(1)$ |
| 枚举 $b$ 的约数 | $O(\sqrt b)$ | $O(1)$（不存结果时） |
| 线性筛预处理积性函数 | $O(n)$ | $O(n)$ |

本条目整体是"一组概念 + 几个小工具"，没有统一的复杂度，其余概念须视具体实现而定。

## 适用场景

- **约分、周期问题、调度问题**：直接套 gcd / lcm，注意先除后乘。
- **枚举约数**：利用"约数成对出现"只枚举到 $\sqrt b$，求因数个数、因数和。
- **质因数分解、筛法、模运算**：整除与带余数除法是它们的前置概念。
- **数论函数预处理**：积性 / 加性函数可用线性筛 $O(n)$ 批量求值，是莫比乌斯反演等工具的地基。
- **整除分块、素数计数**：$\lfloor \cdot \rfloor$ 在这些算法里反复出现，是必备符号。
- **拓展欧几里得 / 模逆元**：都从 $(bq+r, b) = (r, b)$ 这条性质长出来。

## 常见陷阱与注意事项

1. **`__builtin_ctz(0)` 是未定义行为**：模块二的二进制 gcd 里，若某一轮 `a == b`，则 `tmp = 0`，紧接着 `__builtin_ctz(tmp)` 就踩到 UB（GCC 上通常返回一个无意义的值甚至崩溃）。这一段是照原文原样搬过来的，真要用请自己补 `if (!tmp) break;`。
2. **lcm 溢出**：必须先除后乘（`a / gcd * b`），直接 `a * b / gcd` 会中途溢出；极端情况下 lcm 本身也可能超过 `long long`。
3. **整除记号要求 $a \neq 0$**：$a \mid b$ 的定义里除数不能为 0。
4. **0 的约数**：讨论约数时通常默认不考虑 0，做题时留意题目是否特判。
5. **C++ 的 `%` 与数学余数不一致**：数学余数满足 $0 \le r < |a|$，而 C++ 的 `%` 对负数向 0 取整，会得到负余数，需要 `(a % b + b) % b` 修正。
6. **约数枚举的边界**：完全平方数时 $\sqrt b$ 那一对只能算一次，别忘了判 `d * d == b`。
7. **积性 / 加性的"互质"条件**：只有互质时才能拆。$\omega(n)$ 是加性但非完全加性，例如 $\omega(p^2) = 1 \neq 2\omega(p)$。
8. **取整函数对负数**：下取整"向下"、上取整"向上"，$\lfloor -2.3 \rfloor = -3$，别当成"去掉小数点"。$AKB323$, '数学', array['数学', '数论', '整除', '约数', '最大公约数', '积性函数', '取整函数'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-number-theory-theorems--stripe-python', '数论常用定理：费马小定理与扩展欧拉定理 · stripe-python', $AKB324$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《OI 中的数学基础》（[博客版](https://stripepython.github.io/2025/10/05/OI%20%E4%B8%AD%E7%9A%84%E6%95%B0%E5%AD%A6%E5%9F%BA%E7%A1%80/)），本页按主题拆分。

## 5. 数论常用定理

## 5.1 费马小定理

若 $p$ 为质数，且 $\gcd(a,p)=1$，则 $a^{p-1} \equiv 1 \pmod p$。

变形式：$a^p\equiv a \pmod p$ 和 $a^{p-2}\equiv \dfrac{1}{a} \pmod p$。其中第二个式子表明，当 $p$ 为质数时可以直接用快速幂求逆元。

证明：取一个不为 $p$ 的倍数的数 $a$，构造序列 $A=\{1,2,3, \cdots p-1\}$，则：

$\prod_{i=1}^{p-1} A_i \equiv \prod_{i=1}^{p-1} (A_i\times a) \pmod p$考虑每一个 $A_i$ 都不是 $p$ 的约数易证。则令 $m=(p-1)!$，则

$m \equiv \prod_{i=1}^{p-1} (A_i\times a) \pmod p$又有 $a^{p-1} \times f \equiv f \pmod p$，故

$a^{p-1} \equiv 1 \pmod p$## 5.2 欧拉定理

欧拉定理是费马小定理的扩展形式。若 $\gcd(a,n)=1$，则 $a^{\varphi(n)} \equiv 1 \pmod n$。证明与费马小定理类似，构造一个与 $n$ 互质的序列即可。

### 推论

推论 1：若 $\gcd(a,n)=1$，则 $a^b \equiv a^{b \bmod \varphi(n)} \pmod n$。

推论 2：若 $\gcd(a,n)=1$，则满足 $a^x \equiv 1 \pmod n$ 的最小正整数是 $\varphi(n)$ 的约数。

## *5.3 扩展欧拉定理

扩展欧拉定理在 OI 中常用于对指数取模的情况。

$$
a^b \equiv \left\{\begin{matrix}
 a^{b \bmod \varphi(n)} & \gcd(a,n)=1 \\
 a^b & \gcd(a,n) \ne 1,b < \varphi(n) \\
 a^{(b \bmod \varphi(n))+\varphi(n)} & \gcd(a,n) \ne 1, b \ge \varphi(n)
\end{matrix}\right. \pmod n
$$

## 5.4 例题

### P4139 上帝与集合的正确用法

题里给的那个东西实际上是 $2^{2^{2^{2^ \cdots}}} \bmod p$。对指数塔不断递归，用扩展欧拉定理降幂即可。$\varphi(n)$ 提前筛出来。

由于指数塔是无限层，因此肯定有 $b \ge \varphi(n)$，直接认为是第三种情况就行了。

```cpp
long long p;
long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = a * a % p, b >>= 1) {
		if (b & 1) res = res * a % p;
	} return res;
}
long long f(long long p) {return p == 1 ? 0 : power(2, f(phi[p]) + phi[p], p);}

void _main() {   // 这里已经筛过phi[n]了
	cin >> p; cout << f(p) << '\n';
}
```

### P10414 [蓝桥杯 2023 国 A] 2023 次方

和上面那个题没有本质区别。

根据扩展欧拉定理，$a^b \equiv  a^{(b \bmod \varphi(n))+\varphi(n)} \pmod n$，其中 $\gcd(a,n) \ne 1$ 且 $b \le \varphi(n)$。计算可得，$\varphi(2023)=1728$，所以对指数塔上 $>1728$ 的部分用扩展欧拉定理降幂，剩下的部分快速幂即可。得到答案为 $869$。

### *P7334 [JRKSJ R1] 吊打

很好的数据结构和欧拉定理结合的题目。

区间开方可以想到 [GSS4](https://www.luogu.com.cn/problem/SP2713)，势能线段树记录区间最大值，只有 $>1$ 才暴力修改，复杂度是 $O(n \log n \log \log V)$ 的。

考虑区间平方的做法，显然不能直接维护 $a_i$，不然不满足势能线段树的要求。注意到，一个数 $a_i$ 在 $c_i$ 次平方后值为 ${a_i}^{2^{c_i}}$，对 $998244353$ 取模时，指数 $2^{c_i}$ 对 $\varphi(998244353)=998244352$ 取模即可。于是我们考虑维护这个 $c_i$。

这样平方是简单的，区间加一即可。对于开方，我们考虑在线段树的叶子节点维护一个值 $val_i$。当 $c_i \ge 1$ 时，直接将 $c_i \gets c_i-1$，否则令 $val_i \gets \lfloor \sqrt{val_i} \rfloor$。正确性显然。

注意到开方复杂度炸了。考虑将 GSS4 的做法应用到这里，维护区间 $c_i$ 的最小值。只有其 $<1$ 时再进入暴力。配合上区间 $val$ 最大值，可以把暴力次数控制在 $O(\log \log V)$ 以内。因为询问要快速幂，最终复杂度 $O(n \log^2 n)$。

```cpp
const int N = 2e5 + 5;
int n, q, opt, l, r, a[N];
#define ls (rt << 1)
#define rs (rt << 1 | 1)
int val[N << 2], mx[N << 2], cnt[N << 2], cmin[N << 2], tag[N << 2];
void pushup(int rt) {mx[rt] = max(mx[ls], mx[rs]), cmin[rt] = min(cmin[ls], cmin[rs]);}
void pushdown(int rt) {
	if (!tag[rt]) return;
	cnt[ls] += tag[rt], cnt[rs] += tag[rt], cmin[ls] += tag[rt], cmin[rs] += tag[rt];
	tag[ls] += tag[rt], tag[rs] += tag[rt], tag[rt] = 0;
}
void build(int l = 1, int r = n, int rt = 1) {
	cnt[rt] = cmin[rt] = tag[rt] = 0;
	if (l == r) return val[rt] = mx[rt] = a[l], void();
	int mid = (l + r) >> 1;
	build(l, mid, ls), build(mid + 1, r, rs), pushup(rt);
}
void add(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (tl <= l && r <= tr) return cnt[rt]++, cmin[rt]++, tag[rt]++, void();
	int mid = (l + r) >> 1;
	pushdown(rt);
	if (tl <= mid) add(tl, tr, l, mid, ls);
	if (tr > mid) add(tl, tr, mid + 1, r, rs);
	pushup(rt);
}
void sub(int tl, int tr, int l = 1, int r = n, int rt = 1) {
	if (mx[rt] <= 1) return;
	if (tl <= l && r <= tr && cmin[rt] >= 1) return cnt[rt]--, cmin[rt]--, tag[rt]--, void();
	if (l == r) {
		if (cnt[rt]) cnt[rt]--, cmin[rt]--;
		else mx[rt] = val[rt] = sqrt(val[rt]);
		return;
	}
	int mid = (l + r) >> 1;
	pushdown(rt);
	if (tl <= mid) sub(tl, tr, l, mid, ls);
	if (tr > mid) sub(tl, tr, mid + 1, r, rs);
	pushup(rt);
}
mod998244353 ask(int x, int l = 1, int r = n, int rt = 1) {
	if (l == r) {
		mod998244352 v = mod998244352(2).pow(cnt[rt]);
		return mod998244353(val[rt]).pow(static_cast<int>(v));
	}
	int mid = (l + r) >> 1;
	pushdown(rt);
	return x <= mid ? ask(x, l, mid, ls) : ask(x, mid + 1, r, rs);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	build();
	while (q--) {
		cin >> opt >> l >> r;
		if (opt == 1) sub(l, r);
		else add(l, r);
	}
	mod998244353 res = 0;
	for (int i = 1; i <= n; i++) res += ask(i);
	cout << res;
}
```

### P10496 The Luckiest Number

设答案为 $x$ 个 $8$ 连在一起的整数 $n$，由等比数列求和

$$
\begin{aligned}
n&=8+8\times 10+8\times 10^2 + \cdots + 8 \times 10^x\\
&=\sum_{i=0}^{x} 8 \times 10^i \\
&=\dfrac{8(10^x-1)}{9}
\end{aligned}
$$

设 $d=\gcd(L,8)$，则由题知 $L \mid \dfrac{8(10^x-1)}{9}$，故 $9L \mid 8(10^x-1)$，即

$\dfrac{9L}{d} \mid  (10^x-1)$因此，$10^ x \equiv 1 \pmod {\dfrac{9L}{d}}$。

由欧拉定理的推论 2，我们求出 $\varphi(\dfrac{9L}{d})$ 并枚举其约数检查即可，复杂度 $O(\sqrt{L} \log L)$。

```cpp
long long power(long long a, long long b, long long p) {
	long long res = 1; for (a %= p; b; a = (__int128) a * a % p, b >>= 1) {
		if (b & 1) res = (__int128) res * a % p;
	} return res;
}
vector<long long> factors(long long n) {
	vector<long long> res;
	for (long long i = 1; i * i <= n; i++) {
		if (n % i) continue;
		res.emplace_back(i);
		if (n / i != i) res.emplace_back(n / i);
	}
	sort(res.begin(), res.end());
	return res;
}

long long n;

void _main() {
	for (int kase = 1; ; kase++) {
		cin >> n;
		if (n == 0) break;
		cout << "Case " << kase << ": ";
		n = 9 * n / __gcd(n, 8LL);
		if (__gcd(n, 10LL) != 1) {cout << "0\n"; continue;}
		vector<long long> f = factors(phi(n));
		for (long long x : f) {
			if (power(10, x, n) == 1) {cout << x << '\n'; break;}
		}
	}
}
```

### *P2480 [SDOI2010] 古代猪文

我们先形式化题意，就是要求

$g^{\sum_{d \mid n} C_n^d} \bmod 999911659$首先你打个 $O(\sqrt{n})$ 判质数，发现 $999911659$ 是质数，由欧拉定理的推论 1

$g^{\sum_{d \mid n} C_n^d} \equiv g^{\sum_{d \mid n} C_n^d \bmod \varphi(999911659)} \pmod {999911659}$由欧拉函数性质 1，$\varphi(999911659)=999911659-1=999911658$，因此

$g^{\sum_{d \mid n} C_n^d} \equiv g^{\sum_{d \mid n} C_n^d \bmod 999911658} \pmod {999911659}$所以只需求 $\sum_{d \mid n} C_n^d \bmod 999911658$ 然后快速幂即可。如果直接上 exLucas，复杂度会爆炸，考虑怎么做。我们打一个 $O(\sqrt{n})$ 试除法分解质因数可得

$999911658=2\times 3 \times 4679 \times 35617$用 $O(\sqrt{n})$ 枚举 $d \mid n$，然后使用 Lucas 定理计算 $C^{d}_n$ 对 $2,3,4679,35617$ 取模的结果，然后 exCRT 合并答案即可。如果你还不会 Lucas 定理求组合数，请移步下文 9.2.4 学习后再看代码。

特别要注意，欧拉定理成立的条件是 $\gcd(g,999911659)=1$，若不成立要判无解，以及 exCRT 也要判无解。

```cpp
#define int long long
int n, g;

int power(int a, int b, int p) {
	int res = 1; for (a %= p; b; b >>= 1) {
		if (b & 1) res = res * a % p;
		a = a * a % p;
	} return res;
}

namespace Lucas {
	int fac[N], ifac[N];
	inline void init(int p) {
		fac[0] = fac[1] = ifac[0] = ifac[1] = 1;
		for (int i = 2; i <= p; i++) fac[i] = fac[i - 1] * i % p, ifac[i] = power(fac[i], p - 2, p);
	} inline int C(int n, int m, int p) {
		if (n < m) return 0;
		return fac[n] * ifac[m] % p * ifac[n - m] % p;
	} int lucas(int n, int m, int p) {
		if (m == 0) return 1;
		if (n < p && m < p) return C(n, m, p);
		return lucas(n / p, m / p, p) * C(n % p, m % p, p) % p;
	}
}

namespace CRT {
	template <class T> void exgcd(T a, T b, T& x, T& y) {
		if (!b) return x = 1, y = 0, void();
		exgcd(b, a % b, y, x), y -= a / b * x;
	}
	template <class T> T crt(int n, const T* a, const T* m) {
		T x = 0, y = 0, p = m[1], res = a[1];
		for (int i = 2; i <= n; i++) {
			T a0 = p, b0 = m[i], c = (a[i] - res % b0 + b0) % b0, g = __gcd(a0, b0);
			if (c % g) return -1;
			exgcd(a0, b0, x, y);
			x = (__int128) x * c / g % b0, res += x * p, p = p / __gcd(p, b0) * b0, res = (res % p + p) % p;
		}
		return res;
	}
}

const int P[] = {0, 2, 3, 4679, 35617};
int a[5];

void _main() {
	cin >> n >> g;
	if (__gcd(g, 999911659LL) != 1) return cout << 0, void();  // 注意判无解
	for (int i = 1; i <= 4; i++) {
		Lucas::init(P[i]);
		for (int d = 1; d * d <= n; d++) {
			if (n % d) continue;
			a[i] = (a[i] + Lucas::lucas(n, d, P[i])) % P[i];
			if (n / d != d) a[i] = (a[i] + Lucas::lucas(n, n / d, P[i])) % P[i];
		}
	}
	int val = CRT::crt(4, a, P);
	if (val == -1) return cout << 0, void();  // 注意判无解
	cout << power(g, val, 999911659);
}
```

这个题基本把我们讲过的数论知识都用了一遍，是一道很全面很综合的好题。$AKB324$, '数学', array['费马小定理', '欧拉定理', '降幂'], 'col-hub-math-number-theory', null, 'knowledge'),
('stripe-python', 'col-math-oi-foundations--stripe-python', 'OI 中的数学基础 · stripe-python', $AKB325$> 原文由 stripe-python 授权合并。原文章 markdown 超过 400K，单页加载与渲染都很慢，因此按主题拆分为下列条目，正文（含全部例题）已随各条目迁出，本页只保留索引与原文参考资料。

## 拆分索引

**数论与数论计数**

- `math-congruence-basics` 同余与模运算（快速幂 / 乘法逆元 / Modint）
- `math-prime-theory` 质数理论基础（判定 / 筛法 / 算术基本定理）
- `math-gcd-theory` 最大公约数与扩展欧几里得
- `math-euler-phi` 欧拉函数
- `math-number-theory-theorems` 数论常用定理：费马小定理与扩展欧拉定理
- `math-block-division` 整除分块（数论分块）
- `math-01-fractional` 0/1 分数规划

**组合数学**

- `math-counting-principles` 计数原理：加法与乘法原理 / 抽屉原理
- `math-inclusion-exclusion` 容斥原理（含 min-max 容斥与斯特林反演）
- `math-combinatorics` 组合数学（排列 / 组合 / 进阶模型）
- `math-derangement` 错位排列（错排）
- `math-catalan` Catalan 数
- `math-stirling` 斯特林数与贝尔数
- `math-partition` 分拆数（整数拆分）
- `math-counting-misc` 计数杂项：排列计数与图论计数
- `math-probability` 概率论与期望

**数学杂项与线性代数**

- `math-sequences` 数列：等差、等比与递推求和
- `math-bit-operation` 位运算
- `math-bit-operation-advanced` 位运算进阶：01-Trie 与 bitset
- `math-gauss-elimination` 高斯消元
- `math-linear-algebra` 线性代数（向量 / 线性变换 / 广义矩阵乘法）
- `math-lagrange-interpolation` 插值法（Lagrange / Newton）

**跨学科**

- `graph-congruence-shortest-path` 同余最短路

## 原文说明

## 0. 前言

为什么要写这篇文章呢？因为教练让我们选一个专题写博客然后交流。

为什么选数学呢？因为线段树分块都被选走了，而数学专题没人选，并且可以把写过的笔记拼起来（

本文章涉及数论 & 组合数学两个部分，还包含一些数学杂项，整体内容比较简单。

## 注意事项及约定

- 若无特殊说明，本文中使用符号 $\oplus$ 表示按位异或，$\&$ 表示按位与，$|$ 表示按位或，$\sim$ 表示按位取反。
- 本文代码中出现的 `modint` 或 `mint` 是笔者编写的自动取模工具，代码可见 [this](https://www.luogu.me/paste/6wwixwot)。
- 本文代码中出现的 `BigInteger` 是笔者编写的高精度整数，代码可见 [this](https://www.luogu.com.cn/article/rz9ubds1)。
- **本文有大量例题。对于较难的例题，用 `*` 标出，没有看懂可以先跳过。**
- [《OI 中的数学基础》例题题单](https://www.luogu.com.cn/training/875199)。题目按在文章中的出现顺序排序，分成了五个部分。
- **本文存在一些较难的章节，用 `*` 标出。初学者可以先跳过。**

## 更新（world-needs-sunday 维护的更新记录）

- 2025-08-06 第一版：通过洛谷审核。
- 2025-10-05 第二版：调整文章结构，优化目录，重构分拆数部分，新增大量例题并修复一些 Bug。

## 参考资料

**第 1 章**

- 1.2.1 [模意义下的整数乘法](https://oi-wiki.org/math/binary-exponentiation/#%E6%A8%A1%E6%84%8F%E4%B9%89%E4%B8%8B%E7%9A%84%E6%95%B4%E6%95%B0%E4%B9%98%E6%B3%95)——OI Wiki。
- 1.2.2 [快速幂，光速幂及O(1)逆元](https://zhuanlan.zhihu.com/p/646773254)——秋钧。
- 1.2.2 [同一底数与同一模数的预处理快速幂](https://oi-wiki.org/math/binary-exponentiation/#%E5%90%8C%E4%B8%80%E5%BA%95%E6%95%B0%E4%B8%8E%E5%90%8C%E4%B8%80%E6%A8%A1%E6%95%B0%E7%9A%84%E9%A2%84%E5%A4%84%E7%90%86%E5%BF%AB%E9%80%9F%E5%B9%82)——OI Wiki。
- 1.3.3 [题解 P3811 【模板】乘法逆元](https://www.luogu.com.cn/article/olb3kk4e)——Rising_Date。

**第 2 章**

- 2.2.2 [Miller–Rabin 素性测试](https://oi-wiki.org/math/number-theory/prime/#millerrabin-%E7%B4%A0%E6%80%A7%E6%B5%8B%E8%AF%95)——OI Wiki。
- 2.4.3 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 3 章**

- 3.1.3 [Stein 算法的优化](https://oi-wiki.org/math/number-theory/gcd/#stein-%E7%AE%97%E6%B3%95%E7%9A%84%E4%BC%98%E5%8C%96)——OI Wiki。
- 3.1.3 [P5435](https://www.luogu.com.cn/article/t7bd37d3)——Maysoul。
- 3.4 《信息学奥林匹克竞赛实战笔记》。

**第 4 章**

- 4.2 《信息学奥林匹克竞赛实战笔记》。

**第 5 章**

- 5.1 [费马小定理](https://oi-wiki.org/math/number-theory/fermat/#%E8%B4%B9%E9%A9%AC%E5%B0%8F%E5%AE%9A%E7%90%86)——OI Wiki。

**第 6 章**

- 6.1 [数论分块](https://oi-wiki.org/math/number-theory/sqrt-decomposition/)——OI Wiki。
- 6.1 [数论分块](https://zhuanlan.zhihu.com/p/643870541)——Standard。

**第 7 章**

- 7.2.2 [等差数列](https://baike.baidu.com/item/%E7%AD%89%E5%B7%AE%E6%95%B0%E5%88%97/1129192)——百度百科。
- 7.2.3 [等比数列求和公式](https://baike.baidu.com/item/%E7%AD%89%E6%AF%94%E6%95%B0%E5%88%97%E6%B1%82%E5%92%8C%E5%85%AC%E5%BC%8F/7527367)——百度百科。
- 7.2.3 [分治(等比数列求和) - 约数之和 - AcWing 97](https://blog.csdn.net/njuptACMcxk/article/details/108019553)——njuptACMcxk。
- 7.2.4 [信奥常见数列详解](https://www.luogu.com.cn/article/oudldvmw)——Nostopathy。
- 7.3 [抽屉原理](https://oi-wiki.org/math/combinatorics/drawer-principle/)——OI Wiki。

**第 8 章**

- 8.1 [容斥原理](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/)——OI Wiki。
- 8.3 [容斥原理一般化](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E5%AE%B9%E6%96%A5%E5%8E%9F%E7%90%86%E4%B8%80%E8%88%AC%E5%8C%96)——OI Wiki。

**第 9 章**

- 9.1.3 [圆排列](https://oi-wiki.org/math/combinatorics/combination/#%E5%9C%86%E6%8E%92%E5%88%97)——OI Wiki。
- 9.2.2 [二项式定理](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%AE%9A%E7%90%86)——OI Wiki。
- 9.2.3 [组合数性质 | 二项式推论](https://oi-wiki.org/math/combinatorics/combination/#%E7%BB%84%E5%90%88%E6%95%B0%E6%80%A7%E8%B4%A8--%E4%BA%8C%E9%A1%B9%E5%BC%8F%E6%8E%A8%E8%AE%BA)——OI Wiki。
- 9.3.2 [插板法](https://oi-wiki.org/math/combinatorics/combination/#%E6%8F%92%E6%9D%BF%E6%B3%95)——OI Wiki。
- 9.3.2 [不定方程非负整数解计数](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E4%B8%8D%E5%AE%9A%E6%96%B9%E7%A8%8B%E9%9D%9E%E8%B4%9F%E6%95%B4%E6%95%B0%E8%A7%A3%E8%AE%A1%E6%95%B0)——OI Wiki。

**第 10 章**

- 10.1.1 [排名](https://oi-wiki.org/math/permutation/#%E6%8E%92%E5%90%8D)——OI Wiki。
- 10.1.2 [题解：CF1553E Permutation Shift](https://www.luogu.com.cn/article/lexsfrlf)——hh弟中弟。
- 10.2 [exLucas 算法](https://oi-wiki.org/math/number-theory/lucas/#exlucas-%E7%AE%97%E6%B3%95)——OI Wiki。
- 10.3 《算法竞赛进阶指南》——李煜东。

**第 11 章**

- 11.2 [二项式反演](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%8F%8D%E6%BC%94)——OI Wiki。
- 11.3 [容斥原理 & 二项式反演](https://www.cnblogs.com/2huk/p/18169274)——2huk。
- 11.3 [二项式反演学习笔记](https://www.cnblogs.com/XuYueming/p/18397758)——XuYueming。

**第 12 章**

- 12.2 [错位排列](https://www.luogu.com.cn/article/8k18otus)——xzyg。

**第 13 章**

- 13.1 DeepSeek。
- 13.1 [简单格路计数相关](https://www.cnblogs.com/Sktn0089/p/19183743)——Sktn0089。
- 13.2 [常见形式](https://oi-wiki.org/math/combinatorics/catalan/#%E5%B8%B8%E8%A7%81%E5%BD%A2%E5%BC%8F)——OI Wiki。

**第 14 章**

- 14.1 & 14.2 [斯特林数](https://oi-wiki.org/math/combinatorics/stirling/)——OI Wiki。
- 14.3 [二项式反演与斯特林反演](https://www.cnblogs.com/UKE-Automation/p/19688555)——UKE_Automation。
- 14.4.3 [斯特林数入门](https://zhuanlan.zhihu.com/p/160779987)——Hongzy。

**第 15 章**

- 15.1 & 15.2 [贝尔数](https://oi-wiki.org/math/combinatorics/bell/)——OI Wiki。
- 15.3 [贝尔数](https://www.cnblogs.com/HeNuclearReactor/p/18552275.html)——NuclearReactor。

**第 16 章**

- 16.1 & 16.2 [分拆数](https://www.luogu.me/article/ed1zhztr)——LYH_cpp。
- 16.3 [组合数学（2）分拆数](https://zhuanlan.zhihu.com/p/530925152)——卷心汪汪队。

**第 18 章**

- 18.1 & 18.2 & 18.3 & 18.4 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 19 章**

- 19.2 [遍历所有掩码的子掩码](https://oi-wiki.org/math/binary-set/#%E9%81%8D%E5%8E%86%E6%89%80%E6%9C%89%E6%8E%A9%E7%A0%81%E7%9A%84%E5%AD%90%E6%8E%A9%E7%A0%81)——OI Wiki。
- 19.2 [高维前缀和 (SOSDP) ](https://www.cnblogs.com/jiangchen4133/p/18741715.html)——Aurora-JC。

**第 20 章**

- 20.1 [字典树 (Trie) ](https://oi-wiki.org/string/trie/#%E7%BB%B4%E6%8A%A4%E5%BC%82%E6%88%96%E5%92%8C)——OI Wiki。

**第 21 章**

- 21.2 [分数规划](https://oi-wiki.org/misc/frac-programming/)——OI Wiki。

**第 22 章**

- 22.1 DeepSeek。
- 22.3 [高斯消元法解异或方程组](https://oi-wiki.org/math/numerical/gauss/#%E9%AB%98%E6%96%AF%E6%B6%88%E5%85%83%E6%B3%95%E8%A7%A3%E5%BC%82%E6%88%96%E6%96%B9%E7%A8%8B%E7%BB%84)——OI Wiki。

**第 23 章**

- 23.1 & 23.2《深入浅出程序设计竞赛（进阶篇）》——洛谷。
- 23.3 [关于广义矩阵乘法常见误区的一点纠正](https://www.cnblogs.com/qkhm/p/20055514/ddp)——qkhm。

**第 24 章**

- 24.1 DeepSeek。
- 24.2 & 24.3 [插值](https://oi-wiki.org/math/numerical/interp/)——OI Wiki。
- 24.3 [离散泰勒公式，牛顿插值法，以及那些奇怪的数列](https://www.bilibili.com/video/BV1GvoaYbExs/)——科技3D视界。

**第 25 章**

- 25.2 [浅谈同余最短路](https://www.luogu.com.cn/article/boecnq71)——Exp10re。$AKB325$, '数学', array['数学基础', '数论', '组合数学', '索引'], null, null, 'knowledge');

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
