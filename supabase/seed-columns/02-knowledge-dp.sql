-- ============================================================
-- AKB 专栏种子：知识点 / 动态规划
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：67 行
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
('world-needs-sunday', 'col-dp-01bag-2d', '二维费用01背包', $AKB54$## 算法原理

二维费用01背包是标准01背包的自然推广：每个物品在放入背包时同时消耗两种资源（例如体积和重量、时间和金钱），背包对两种资源分别有上限 $V$ 和 $M$。目标是在不超过两种资源上限的前提下，使物品总价值最大。

状态定义 $dp[i][j]$ 表示在第一种资源消耗不超过 $i$、第二种资源消耗不超过 $j$ 时能获得的最大价值。与标准01背包不同，这里有两个维度的约束，因此状态是一个二维表格。对每个物品，需要同时从 $i$ 和 $j$ 两个方向做逆序遍历，以确保每个物品只被选取一次。

状态转移的逻辑与标准01背包完全类似：若选第 $k$ 个物品，则两种资源分别消耗 $v$ 和 $m$，剩余资源为 $i - v$ 和 $j - m$，价值为 $dp[i-v][j-m] + w$；若不选，则价值为 $dp[i][j]$。两者取较大值。由于使用一维滚动数组（空间优化），必须对 $i$ 和 $j$ 均逆序遍历。

由于 `dp` 数组被初始化为 $0$，空选取（一个物品都不选）始终是可行解，因此 $dp[i][j]$ 天然具有"不超过"语义：它表示的是"资源不超过 $i$ 和 $j$"时的最大价值，而非"恰好等于 $i$ 和 $j$"。这也是求最大值时用 $0$（而非 $-\infty$）初始化的原因。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{第一种资源不超过 } i \text{、第二种资源不超过 } j \text{ 时的最大价值}$$

状态转移方程（对物品 $k$，消耗 $v$ 和 $m$，价值 $w$）：

$$dp[i][j] = \max\big(dp[i][j],\; dp[i-v][j-m] + w\big), \quad i \geq v,\; j \geq m$$

最终答案：

$$\text{ans} = dp[V][M]$$

## 逐行代码解析

### 全局准备（头文件 + main + 读入 + dp 数组）

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int N, V, M;
	cin >> N >> V >> M;
	vector<vector<long long>> dp(V + 1, vector<long long>(M + 1, 0));
```

- **`N` / `V` / `M`**：依次读入物品数、第一种资源上限、第二种资源上限。
- **`dp` 表**：大小为 $(V+1) \times (M+1)$，下标范围 $0..V$、$0..M$；用 `long long` 防价值溢出，初始化为 $0$（求最大值时 $0$ 即合法下界）。
- **`ios::sync_with_stdio(false)` + `cin.tie(nullptr)`**：关闭 C 风格 IO 同步并解绑 cin/cout，加快大量读写。

### 物品循环与读入每个物品

```cpp
	for (int k = 0; k < N; k++)
	{
		int v, m, w;
		cin >> v >> m >> w;
```

- **物品循环 `k`**：从 $0$ 到 $N-1$，逐个处理每个物品。
- **`v` / `m` / `w`**：当前物品分别消耗的第一种资源量、第二种资源量，以及它的价值。

### 双重逆序遍历 + 核心转移

```cpp
		for (int i = V; i >= v; i--)
		{
			for (int j = M; j >= m; j--)
			{
				dp[i][j] = max(dp[i - v][j - m] + w, dp[i][j]);
			}
		}
	}
```

- **双重逆序**：$i$ 从 $V$ 到 $v$、$j$ 从 $M$ 到 $m$ 均逆序遍历，保证每个物品只被选取一次（任一维度正序都会重复选）。
- **边界范围**：`i >= v`、`j >= m` 保证 `i - v >= 0`、`j - m >= 0`，访问 `dp[i-v][j-m]` 不会越界。
- **核心转移**：`dp[i-v][j-m] + w`（选第 $k$ 件）与当前 `dp[i][j]`（不选）取较大值。

### 输出答案

```cpp
	cout << dp[V][M];
}
```

- **输出**：`dp[V][M]` 即两种资源上限分别为 $V$、$M$ 时的最大价值，也就是最终答案。

## 复杂度分析

- **时间复杂度**：$O(N \times V \times M)$。外层物品循环 $N$ 次，内层两重循环共 $V \times M$ 次，每次转移为 $O(1)$。
- **空间复杂度**：$O(V \times M)$。使用二维滚动数组，不需要记录每个物品的历史状态。若使用三维数组则为 $O(N \times V \times M)$，但实际中滚动数组已足够。

## 适用场景

适用于物品同时消耗两种资源且各有上限的背包问题，例如：体积和重量双限制、时间和金钱双限制、CPU 和内存双限制等场景。当资源维度增加到三个或更多时可类推推广。

## 常见陷阱与注意事项

- **双重逆序遍历**：$i$ 和 $j$ 两个维度都必须逆序遍历，任何一个维度正序都会导致同一物品被重复选取。
- **`long long` 防溢出**：价值和资源乘积可能很大，务必使用 `long long` 类型存储 `dp` 值。
- **下标越界**：逆序遍历从 $V$ 到 $v$、$M$ 到 $m$，确保 $i - v \geq 0$ 和 $j - m \geq 0$。
- **初始化值**：求最大价值时初始化为 $0$；若要求"恰好装满"两种资源，则初始化为 $-\infty$。

## 对比与扩展

与标准01背包相比，仅增加了资源维度，核心转移逻辑不变。可推广到三维甚至更高维度的费用背包，但空间和时间的增长是指数级的。若物品可重复选取则改为完全背包的二维费用版本（两个维度均正序遍历）。也可结合分组、多重等变种。$AKB54$, '动态规划', array['动态规划', '背包问题', '二维费用', '01背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-01bag-record', '01背包（带记录/路径还原）', $AKB55$## 算法原理

标准01背包只输出最大价值，而带记录的01背包需要还原具体选择了哪些物品。核心思想是采用逆序DP：转移方程从 $i = N$ 递减到 $i = 1$，即先计算后端物品、再计算前端物品，这样路径还原时可以从前到后正序遍历，逻辑更直观。

状态定义 $dp[i][j]$ 表示从第 $i$ 到第 $N$ 个物品中选取、容量为 $j$ 时能获得的最大价值。与标准01背包不同，这里 $dp[i][j]$ 依赖的是 $dp[i+1][\cdot]$（后一行）而非 $dp[i-1][\cdot]$（前一行）。转移时若选第 $i$ 个物品则价值为 $dp[i+1][j - w_i] + v_i$，若不选则为 $dp[i+1][j]$。

路径还原的过程从 $i = 1$、$j = V$ 出发，正序遍历每个物品。对物品 $i$，判断当前状态 $dp[i][j]$ 是否等于 $dp[i+1][j - w_i] + v_i$（即是否由"选了第 $i$ 个物品"转移而来）。若相等，则第 $i$ 个物品被选中，输出 $i$ 并将容量减去 $w_i$；若不等，则第 $i$ 个物品未被选中，容量不变。逐步推进直到遍历完所有物品。

逆序DP的优势在于路径还原时方向与物品编号一致（从 $1$ 到 $N$），输出即为物品编号的升序。若使用标准正序DP，路径还原需从 $dp[N][V]$ 反向回溯到 $dp[0][0]$，输出顺序为降序，不够直观。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{从第 } i \text{ 到第 } N \text{ 个物品中选取、容量为 } j \text{ 时的最大价值}$$

状态转移方程：

$$dp[i][j] = \max\big(dp[i+1][j],\; dp[i+1][j-w_i] + v_i\big), \quad j \geq w_i$$

当 $j < w_i$ 时：

$$dp[i][j] = dp[i+1][j]$$

路径还原条件（第 $i$ 个物品被选中）：

$$dp[i][j] = dp[i+1][j-w_i] + v_i$$

最终答案：

$$\text{ans} = dp[1][V]$$

## 逐行代码解析

### 头文件与读入

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	int N,V;
	cin >> N >> V;
	vector<pair<int,int>> A(N + 2);
	for(int i = 1;i <= N;i++) cin >> A[i].first >> A[i].second;
```

- `N` 是物品数、`V` 是背包容量，从标准输入读入。
- `A` 数组：`A[i].first` 存第 $i$ 个物品的重量，`A[i].second` 存价值。
- `A` 开成 $N+2$ 大小，为下标 $N+1$ 留出空间，防止后面访问 `A[i+1]` 越界。

### dp 表初始化

```cpp
	vector<vector<int>> dp(N + 2,vector<int>(V + 2,0));
```

- `dp[i][j]` 表示从第 $i$ 到第 $N$ 个物品中选取、容量为 $j$ 时的最大价值。
- 表开成 $(N+2) \times (V+2)$，比 $N$、$V$ 各多 2，防止 `i+1`、`j+1` 越界。
- 全表初始化为 $0$，因此 `dp[N+1][j]` 全为 $0$，即"没有物品可选"时的边界。

### 逆序 DP 转移

```cpp
	for(int i = N;i >= 1;i--)
	{
		for(int j = V;j >= 1;j--)
		{
			dp[i][j] = dp[i+1][j];
			if (j >= A[i].first) dp[i][j] = max(dp[i + 1][j - A[i].first] + A[i].second , dp[i + 1][j]);
		}
	}
```

- `i` 从 $N$ 递减到 $1$：先算后端物品、再算前端物品，依赖的是后一行 `dp[i+1]`。
- 每一轮先默认不选：`dp[i][j] = dp[i+1][j]`，继承后一行同容量的值。
- `if (j >= A[i].first)` 是"容量放得下第 $i$ 个物品"的边界，避免 `j - A[i].first` 变负越界。
- 放得下时取"选"与"不选"的较大值：`dp[i+1][j - A[i].first] + A[i].second` 对应选，`dp[i+1][j]` 对应不选。

### 路径还原

```cpp
	int j = V;
	for(int i = 1;i <= N;i++)
	{
		if(j >= A[i].first && dp[i][j] == dp[i + 1][j - A[i].first] + A[i].second)
		{
			cout << i << ' ';
			j -= A[i].first;
		}
	}
	return 0;
}
```

- 从 `i = 1`、`j = V` 出发正序遍历，方向与物品编号一致，输出即升序。
- 关键判断：`dp[i][j] == dp[i+1][j - A[i].first] + A[i].second` 成立说明第 $i$ 个物品被选中。
- 前面的 `j >= A[i].first` 用短路求值防止容量不足时下标越界。
- 选中后输出 `i` 并把容量 `j -= A[i].first`，保证后续判断基于剩余容量。

## 复杂度分析

- **时间复杂度**：$O(N \times V)$。DP阶段两重循环共 $N \times V$ 次状态转移，路径还原阶段线性遍历 $N$ 次，总体为 $O(N \times V)$。
- **空间复杂度**：$O(N \times V)$。需保留完整的二维 `dp` 表用于路径还原，无法用一维滚动数组优化（因为回溯时需要所有历史状态）。

## 适用场景

适用于不仅需要最大价值、还需要输出具体选择了哪些物品的01背包问题。常见于需要给出具体方案的题目，如资源分配方案、选课方案等。

## 常见陷阱与注意事项

- **必须保留二维表**：路径还原需要访问 $dp[i+1][j-w_i]$，因此不能使用一维滚动数组优化空间，必须保留完整的二维 `dp` 表。
- **逆序DP的方向**：$i$ 从 $N$ 到 $1$ 递减，依赖 $dp[i+1]$ 而非 $dp[i-1]$，与标准01背包方向相反。
- **数组大小多开**：`A` 和 `dp` 均多开 $2$ 个元素（$N+2$、$V+2$），防止 $i+1$ 越界。
- **路径还原判断的歧义**：当选与不选的价值相等时，代码优先判断为"选中"——这在输出方案时可能导致多种正确方案中输出其中一种。若题目有字典序要求，需调整判断顺序。
- **`j` 的更新**：还原路径时 `j` 必须在选中物品后减去 $A[i].first$，保证后续判断基于剩余容量。

## 对比与扩展

与标准01背包相比，核心转移逻辑相同，区别在于DP方向（逆序）和额外的路径还原阶段。正序DP也可实现路径还原，但需从 $dp[N][V]$ 反向回溯。此技术可推广到任意需要还原决策路径的DP问题（如LCS输出、最短路路径还原等），核心思想均为"根据转移方程反推决策"。$AKB55$, '动态规划', array['动态规划', '背包问题', '01背包', '路径还原', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Fohen', 'col-dp-01bag-standard--fenfeng', '01背包（标准） · Fohen', $AKB56$## 算法原理

01背包是动态规划中最经典、最基础的模型之一：给定 $n$ 个物品和一个容量为 $V$ 的背包，第 $i$ 个物品的重量为 $w_i$、价值为 $v_i$，每件物品**最多选一次**（要么选、要么不选），目标是选出若干物品，使总重量不超过 $V$ 且总价值最大。

很多人会第一时间想到贪心：按「性价比」（价值与重量之比）从高到低依次选取。但贪心并不正确——它可能为了选高性价比的物品而挤占容量，反而错过全局最优，因此 01背包必须用动态规划求解。

DP 的核心是把「选不选第 $i$ 个物品」当成一次决策：设 $f[i][j]$ 表示「只考虑前 $i$ 个物品、背包容量为 $j$ 时能获得的最大价值」，每个物品只有选与不选两种决策。这样就把原问题拆成子问题逐层递推，最终答案在 $f[n][V]$。

## 核心公式 / 状态定义与转移方程

状态定义：

$$f[i][j] = \text{考虑前 } i \text{ 个物品、容量为 } j \text{ 时的最大价值}$$

每个物品只有两种决策：

- **不选第 $i$ 个物品**：价值等于 $f[i-1][j]$。
- **选第 $i$ 个物品**（要求 $j \geq w_i$）：先用前 $i-1$ 个物品填满容量 $j - w_i$，价值为 $f[i-1][j-w_i] + v_i$。

转移方程：

$$f[i][j] = \max\big(f[i-1][j],\; f[i-1][j-w_i] + v_i\big), \quad j \geq w_i$$

当 $j < w_i$ 时放不下，只能不选：

$$f[i][j] = f[i-1][j], \quad j < w_i$$

边界条件：$f[0][j] = 0$（没有物品时价值为 $0$），$f[i][0] = 0$（容量为 $0$ 装不下任何物品）。

### 空间优化（滚动数组）

观察转移方程，第 $i$ 层只依赖第 $i-1$ 层，因此可以去掉第一维，只用一个一维数组 $f[j]$。但这时**容量必须倒序枚举**（从大到小）：

```cpp
for (int i = 1; i <= n; i++)
    for (int j = V; j >= w[i]; j--)
        f[j] = max(f[j], f[j - w[i]] + v[i]);
```

**为什么必须倒序？** 因为 $f[j - w_i]$ 必须是「上一层」的状态。倒序枚举能保证计算 $f[j]$ 时，$f[j - w_i]$ 还没被当前物品更新过；若正序枚举，$f[j - w_i]$ 可能已经选了当前物品，就会造成同一物品被重复选取。

## 逐行代码解析

下面给出二维写法（与 .cpp 文件一致），它最直观，便于理解状态转移。

```cpp
#include <bits/stdc++.h>
using namespace std;
pair<int,int> a[1010];
int f[1010][1010],w[1010];
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        cin>>a[i].first>>a[i].second;
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<=v;j++){
            if(a[i].first>j) f[i][j]=f[i-1][j];
            else f[i][j]=max(f[i-1][j],f[i-1][j-a[i].first]+a[i].second);
        }
    }
    cout<<f[n][v];
    return 0;
}
```

- `#include <bits/stdc++.h>` 是万能头文件，一次包含几乎所有标准库。
- `pair<int,int> a[1010]` 用 `pair` 存储每个物品：`first` 是重量、`second` 是价值。
- `f[1010][1010]` 是二维 DP 表，`f[i][j]` 表示前 $i$ 个物品、容量 $j$ 的最大价值；`w[1010]` 在本写法里未使用（重量直接存进了 `a[i].first`）。
- `ios::sync_with_stdio(0)`、`cin.tie(0)`、`cout.tie(0)` 关闭同步流，加速输入输出。
- 读入 $n$、$v$ 后，循环读入每个物品的重量与价值。
- 核心转移：外层枚举物品 $i$（$1 \dots n$），内层枚举容量 $j$（$1 \dots v$）；若 `a[i].first > j`（放不下）则继承 `f[i-1][j]`，否则在「不选」与「选」中取较大值。
- 最后输出 `f[n][v]`，即前 $n$ 个物品、容量 $v$ 下的最大价值。

## 复杂度分析

- **时间复杂度**：$O(n \times V)$。外层 $n$ 个物品、内层 $V$ 个容量，共 $n \times V$ 个状态，每个状态 $O(1)$ 转移。
- **空间复杂度**：二维写法为 $O(n \times V)$；用滚动数组优化后可降到 $O(V)$。

## 适用场景

适用于「每件物品最多选一次」的选择问题，是背包问题的入门与基石。实际题目中背包 DP 常被包装成各种变体（完全背包、多重背包、分组背包、二维费用背包等），但它们都能在 01背包的基础上演化而来，因此掌握 01背包是学习其余背包模型的必修课。

## 常见陷阱与注意事项

1. **倒序枚举**：一维滚动数组下容量必须倒序；正序会复用本层已更新的状态，导致同一物品被选多次。
2. **初始化**：求最大价值一般把 $f$ 初始化为 $0$；若要求「恰好装满」，则 $f[0]=0$、其余置为 $-\infty$（求最小代价则置为足够大的数）。
3. **边界**：下标从 $1$ 开始，$f[0][j]$ 表示「没有物品」的初始状态；转移前先判断 $j$ 是否装得下当前物品。
4. **数组大小**：二维表大小为 $(n+1) \times (V+1)$，多出的一行一列用于边界条件，避免越界。
5. **状态来源**：选第 $i$ 个物品时用 $f[i-1][j-w_i]$，不能写成 $f[i][j-w_i]$（那样就变成完全背包了）。

## 对比与扩展

| 背包类型 | 与 01背包的区别 | 关键写法 |
|---|---|---|
| 完全背包 | 每件物品可选任意次 | 一维时容量正序枚举 |
| 多重背包 | 每件物品有数量上限 | 二进制拆分后跑 01背包 |
| 分组背包 | 每组最多选一件 | 容量循环放在组内物品循环外层 |

01背包的核心转移 $f[i][j] = \max(f[i-1][j], f[i-1][j-w_i]+v_i)$ 是所有背包模型的共同骨架：完全背包只是把第二项的行号从 $i-1$ 改成 $i$（允许本层重复转移）；多重背包通过二进制拆分（或单调队列优化）转成 01背包；分组背包则把「决策一个物品」换成「决策一组里的一个物品」。掌握 01背包的状态定义与倒序枚举，后续变体都能快速上手。$AKB56$, '动态规划', array['动态规划', '背包问题', '01背包', 'DP', '滚动数组'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-01bag-standard--xesir', '01背包（标准） · Xesir', $AKB57$## 算法原理

背包问题是动态规划里最经典的题型之一，基本所有 OIer 都跟它打过照面。它的核心思路很简单：**给你一个容量有限的背包，一堆物品，每个物品有重量和价值，问怎么装价值最大**。当然出题人不会给你裸板子，实际题目中背包 DP 会变成各种变体并藏起来阴你；不过万变不离其宗，背包毫无疑问是 DP 最入门的题型，也是 DP 的必修课。

**01背包**：每个物品**最多选一次**，要么选要么不选。（详见云兰阁 P1211(C9)）

非常经典的题型，很多人第一时间会想到贪心，优先性价比（$w/v$）最大，但实际上行不通哒！只需要一个 $v$ 大但性价比稍高的物品就能轻松占住你的背包，让你无法达到最优解的真实（。

接下来就要考虑 **DP** 了。设 `f[i][j]` 表示考虑前 `i` 个物品、背包容量为 `j` 时能获得的最大价值，显然每个物品只有选或不选两种决策。

转移方程：

$$
f[i][j] = \max(f[i-1][j],\ f[i-1][j - w[i]] + v[i]) \quad (j \ge w[i])
$$

### 空间优化（滚动数组）

==这是一个非常常用的技巧，在之后的 DP 中也会经常见到==

观察发现第 `i` 层只依赖第 `i-1` 层，所以可以去掉第一维，只用一个一维数组 `f[j]`。但要注意，**容量必须倒序枚举**（从大到小），否则当前物品会被重复选取（因为正序会用到本层更新过的状态，相当于可以选多次）。代码里常见的写法：

```cpp
for (int i = 1; i <= n; i++)
    for (int j = V; j >= w[i]; j--)
        f[j] = max(f[j], f[j - w[i]] + v[i]);
```

**为什么倒序？** 因为 `f[j - w[i]]` 必须是上一层的状态，倒序能保证它还没被当前物品更新过。如果正序，`f[j - w[i]]` 可能已经选了当前物品，就会出现重复选择的情况。

## 逐行代码解析

下面按模块拆开源里的这份模板；它用的是**二维写法**，和上面看到的滚动数组是同一套转移的两种实现。

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
pair<int,int> a[1010];
int f[1010][1010],w[1010];
```

- `a[i].first` 存第 $i$ 个物品的重量，`a[i].second` 存价值，用 `pair` 省得开两个数组。
- `f[i][j]` 就是二维 DP 表；`w[1010]` 声明了却**从没用到**（源里就是这么留下的），别被它迷惑。
- 数组只开到 `1010`，暗示 $n, v \le 1000$ 量级。

### main 框架与读入

```cpp
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        cin>>a[i].first>>a[i].second;
    }
```

- 三行关同步 / 解绑，加速 `cin / cout`。
- `n` 是物品数，`v` 是背包容量，都从下标 1 开始存，`f[0][*]` 天然是「没有物品」的边界。

### 核心转移与输出

```cpp
    for(int i=1;i<=n;i++){
        for(int j=1;j<=v;j++){
            if(a[i].first>j) f[i][j]=f[i-1][j];
            else f[i][j]=max(f[i-1][j],f[i-1][j-a[i].first]+a[i].second);
        }
    }
    cout<<f[n][v];
    return 0;
}
```

- `a[i].first > j`：物品比容量还重，放不下，只能继承上一行 `f[i-1][j]`。
- 否则取 `max(不选 = f[i-1][j], 选 = f[i-1][j-w_i]+v_i)`，注意第二项用的是 `f[i-1]`（上一行），这正是「每件最多选一次」的保证。
- 答案就是右下角 `f[n][v]`。

## 复杂度分析

- **时间复杂度**：$O(n \times V)$，两层循环填满二维表，每次转移 $O(1)$。
- **空间复杂度**：$O(n \times V)$（这份是二维写法）。由于 `f[i][j]` 只依赖第 `i-1` 行，可以压成一维滚动数组做到 $O(V)$——但压缩后容量必须**倒序枚举**。

## 适用场景

每件物品最多选一次的背包问题，是所有背包变种（多重、完全、分组、混合）的基础模板。物品数与容量在 $10^3$ 级别时可直接套用。

## 常见陷阱与注意事项

1. **正文与代码不是同一种写法**：上面讲滚动数组要「倒序」，而这份模板走的是二维表、`j` 正序，两种写法别抄混；一旦压成一维却忘了倒序，同一个物品会被选多次。
2. **数组开小**：`a` 只到 `1010`，$n$ 或 $v$ 超过 1000 直接越界，看清数据范围。
3. **`w` 数组是摆设**：源里声明未用，照搬不影响正确性，但别以为它参与了转移。
4. **初始化语义**：求最大价值全 0 初始化即可；若题目要求「恰好装满」，要把 `f[0][0]` 设为 0、其余设为 $-\infty$。
5. **溢出**：当 $n \cdot V$ 或价值和较大时，考虑改 `long long`。

## 对比与扩展

与完全背包的唯一区别：转移第二项的行号。01背包用 `f[i-1][j-w_i]`（上一行），完全背包用 `f[i][j-w_i]`（同一行）。压成一维后对应「01 倒序、完全正序」。可继续扩展到二维费用背包、分组背包、树形依赖背包等。$AKB57$, '动态规划', array['动态规划', '背包问题', '01背包', '滚动数组', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-01bag-standard', '01背包（标准）', $AKB58$## 算法原理

01背包是所有背包问题的基石。给定 $n$ 个物品和一个容量为 $m$ 的背包，第 $i$ 个物品的重量为 $w_i$，价值为 $v_i$，每件物品最多选取一次（选或不选），目标是在不超容量的前提下使总价值最大。

核心思路是定义二维状态 $dp[i][j]$ 表示"从前 $i$ 个物品中选取，放入容量为 $j$ 的背包时能获得的最大价值"。这个状态定义将问题分解为子问题：只考虑前 $i$ 个物品、只使用 $j$ 的容量时，最优解是多少。通过逐步增加物品数量 $i$ 和容量 $j$，最终答案为 $dp[n][m]$。

状态转移的关键在于"选或不选第 $i$ 个物品"。若不选第 $i$ 个物品，则价值等于前 $i-1$ 个物品在容量 $j$ 下的最优值，即 $dp[i-1][j]$；若选第 $i$ 个物品，则需要预留出 $w_i$ 的容量，剩余容量 $j - w_i$ 用前 $i-1$ 个物品去填充，价值为 $dp[i-1][j-w_i] + v_i$。两者取较大值即为 $dp[i][j]$。当 $j < w_i$ 时，物品放不下，只能不选。

DP表的填充顺序为外层循环遍历物品 $i$（从 $1$ 到 $n$），内层循环遍历容量 $j$（从 $0$ 到 $m$）。由于 $dp[i][j]$ 只依赖第 $i-1$ 行的值，因此正序或逆序遍历 $j$ 均可（二维数组情形下不影响正确性）。整个表格从左到右、从上到下逐步填充，最终在右下角 $dp[n][m]$ 得到答案。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{从前 } i \text{ 个物品中选取、容量不超过 } j \text{ 时的最大价值}$$

状态转移方程：

$$dp[i][j] = \max\big(dp[i-1][j],\; dp[i-1][j-w_i] + v_i\big), \quad j \geq w_i$$

当 $j < w_i$ 时：

$$dp[i][j] = dp[i-1][j]$$

边界条件：$dp[0][j] = 0$（前 $0$ 个物品价值为 $0$），$dp[i][0] = 0$（容量为 $0$ 无法放入任何物品）。

最终答案：

$$\text{ans} = dp[n][m]$$

## 逐行代码解析

### 头文件与 main 入口

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
```

- `#include<bits/stdc++.h>` 是万能头文件，一次包含几乎所有标准库（含 `iostream`、`vector`），省去逐个 `#include`。
- `using namespace std;` 让 `cin`、`cout`、`vector`、`max` 等免写 `std::` 前缀。
- `main()` 是程序入口，`{` 之后是函数体。

### 读入数据

```cpp
	int n,m; // n: 物品数, m: 背包容量
	cin >> n >> m;
	vector<int> W(n + 1); // W[i]: 第 i 个物品的重量
	vector<int> C(n + 1); // C[i]: 第 i 个物品的价值
	for(int i = 1;i <= n;i++) cin >> W[i] >> C[i]; // 依次读入每个物品的重量与价值
```

- `n` 是物品个数，`m` 是背包容量。
- `W`、`C` 数组都开到 `n+1`，下标从 1 开始存储，`W[i]`、`C[i]` 分别对应第 i 个物品的重量与价值。
- 下标从 1 开始，是为了让 `dp[0][j]` 自然表示"没有物品"的初始状态。
- 读入循环 `i` 从 1 到 n（闭区间，含 i=n），保证每个物品都读入。

### 初始化 dp 表

```cpp
	vector<vector<int>> dp(n + 1,vector<int>(m + 1,0)); // 全 0 初始化
```

- `dp` 表大小为 $(n+1) \times (m+1)$，全部初始化为 0。
- 第 0 行和第 0 列自动为 0，正好对应边界条件 $dp[0][j]=0$ 与 $dp[i][0]=0$。

### 核心 DP 转移

```cpp
	for(int i = 1;i <= n;i++) // 外层: 逐个物品
	{
		for(int j = 0;j <= m;j++) // 内层: 遍历容量 0..m
		{
			if(j >= W[i]) dp[i][j] =max(dp[i - 1][j - W[i]] + C[i] , dp[i - 1][j]); // 可选: 取 max(选, 不选)
			else dp[i][j] = dp[i - 1][j]; // 放不下: 只能不选
		}
	}
```

- 外层循环 `i` 从 1 到 n，内层循环 `j` 从 0 到 m，逐行逐列填充 `dp` 表。
- 当 `j >= W[i]` 时执行核心转移：`dp[i-1][j-W[i]] + C[i]`（选第 i 个物品）与 `dp[i-1][j]`（不选）取最大值。
- 当 `j < W[i]` 时物品放不下，直接继承上一行 `dp[i-1][j]`。
- 二维数组下 `j` 正序或逆序均不影响正确性（`dp[i][j]` 只依赖第 `i-1` 行）；若压缩成一维则必须逆序。

### 输出答案

```cpp
	cout << dp[n][m]; // 答案 = dp[n][m]
	return 0;
}
```

- `dp[n][m]` 即前 n 个物品、容量 m 下的最大价值，是最终答案。
- `return 0;` 正常结束程序。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$。外层循环 $n$ 次，内层循环 $m+1$ 次，共 $n \times (m+1)$ 次状态转移，每次转移为 $O(1)$ 操作。
- **空间复杂度**：$O(n \times m)$。使用二维数组存储所有状态。由于 $dp[i][j]$ 仅依赖 $dp[i-1][\cdot]$，可将空间优化为 $O(m)$ 的一维滚动数组（需对 $j$ 逆序遍历）。

## 适用场景

适用于每件物品最多选一次的背包问题，是所有背包变种（完全背包、多重背包、分组背包等）的基础模板。当物品数和容量均在 $10^3$ 级别时可直接使用。

## 常见陷阱与注意事项

- **数组大小**：`dp` 数组需开到 $(n+1) \times (m+1)$，多出的第 $0$ 行第 $0$ 列用于边界条件，否则数组越界。
- **初始化值**：求最大价值时 `dp` 初始化为 $0$；若要求"恰好装满"则需将 `dp[0]` 设为 $0$、其余设为 $-\infty$。
- **下标从 1 开始**：代码中 `W` 和 `C` 从下标 $1$ 开始存储，`dp` 表的第 $0$ 行表示"无物品"的初始状态，避免索引越界。
- **二维 vs 一维**：二维写法中 $j$ 正序逆序均可，但若改为一维滚动数组，$j$ 必须逆序遍历，否则同一物品可能被重复选取。
- **整数溢出**：当价值和容量较大时，应考虑使用 `long long` 防止溢出。

## 对比与扩展

与完全背包的核心区别在于转移方程中第二项的行号：01背包用 $dp[i-1][j-w_i]$（前 $i-1$ 行），完全背包用 $dp[i][j-w_i]$（同一行，允许重复选取）。01背包可扩展为二维费用背包、分组背包、计数背包等变种，也可在树形结构上推广为树形依赖背包。

**混合背包**：当 01、完全、多重三类物品出现在同一题中时，可统一用一个数量参数 $s$ 分发：$s=-1$ 表示 01 背包、$s=0$ 表示完全背包、$s>0$ 表示多重背包（数量为 $s$）。只需一个转移入口，按 $s$ 选择对应写法即可，不必为每种类型单独写代码。

```text
对每个物品读入 (w, v, s)：
  s == -1  → 01背包（一维时容量逆序）
  s ==  0  → 完全背包（一维时容量正序）
  s >   0  → 拆成多个物品后按01背包处理（二进制拆分）
```

**最小化背包**：当目标从"价值最大"换成"代价最小"（如最少硬币数、恰好装满的最小消耗）时，初始化规则要反过来：$dp[0]=0$，其余状态初始化为一个足够大的数（记作 $INF$），转移由 $\max$ 改为 $\min$；最终若 $dp[m]$ 仍为 $INF$，说明该容量无法恰好达到。$AKB58$, '动态规划', array['动态规划', '背包问题', '01背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-bitmask-hamilton--xesir', '状压 DP · 旅行商问题（TSP 简化版 · Xesir 版） · Xesir', $AKB59$## 算法原理

状压 DP（状态压缩动态规划）是用**二进制位**表示「子集」的技巧：当问题的一个状态可以写成一个有限集合的子集时，就把每位表示「该元素是否被选中」，整个子集压成一个整数。这样状态数从「指数个集合」变成「可枚举的整数」，配合位运算就能高效转移。

**适用条件**：数据范围很小，通常 $n \le 20$（因为 $2^n$ 还在可接受范围内）；且转移依赖集合之间的包含 / 交集 / 并集关系。

**常用位运算**：

- 判断第 $i$ 位是否为 1：`(mask >> i) & 1`
- 把第 $i$ 位设为 1：`mask | (1 << i)`
- 把第 $i$ 位取反：`mask ^ (1 << i)`
- 枚举子集：`for (int sub = mask; sub; sub = (sub-1) & mask)`
- 统计 1 的个数：`__builtin_popcount(mask)`（GCC 内置）

**例题（旅行商问题 TSP 简化版，详见洛谷 P1171）**：给定 $n$ 个点，从点 0 出发，经过每个点恰好一次，最后回到点 0，求最短路径长度。$n \le 20$。

这就是最经典的 TSP 状压 DP。用状态 `f[mask][i]` 描述「已经访问的集合」与「当前所在点」，逐个把未访问的点接上来即可。

## 核心公式 / 状态定义与转移方程

状态定义：

$$f[\text{mask}][i] = \text{已访问点集为 mask、当前停在点 } i \text{ 时的最短距离}$$

初始状态：只访问了点 0，停在点 0，距离为 0。

$$f[1][0] = 0$$

转移：从当前状态 $(\text{mask}, i)$ 走向一个**尚未访问**的点 $j$（即 `(mask >> j) & 1 == 0`）：

$$f[\text{mask} \mid (1 \ll j)][j] = \min\big(f[\text{mask} \mid (1 \ll j)][j],\; f[\text{mask}][i] + d[i][j]\big)$$

最终答案：遍历所有终点 $i$，补上回到起点的边，取最小。

$$\text{ans} = \min_i \big(f[\,(1 \ll n) - 1\,][i] + d[i][0]\big)$$

## 逐行代码解析

源笔记此处标注为 `code：（细节防伪标记）`——中间那段装饰性注释确实是作者的「防伪标记」，**原样照搬**。

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
int f[1<<21][21];
int d[21][21];
```

- `f[1<<21][21]` 是 DP 表，第一维是 $2^n$ 的 mask，第二维是当前点；$n \le 20$ 时 `1<<21` 留了一点余量。
- `d[21][21]` 是点对之间的距离矩阵。

### main：读入与初始化

```cpp
int main(){
    int n,mi=1e9;cin>>n;
	memset(f,0x3f,sizeof f);
    for(int i=0;i<n;i++){
		for(int j=0;j<n;j++){
			cin>>d[i][j];
           // cout<<d[i][j]<<" ";
		}
       // cout<<endl;
	}
	//fghyhhtry6hfgbnncbnjkolojbxsdfgh寒食风。嗯。
/*	 /\
    //\\
   ///\\\
   sszzzss
	//996?wixin
    你活到头了
*/
    
    int M=(1<<n)-1;
    f[1][0]=0;
}
```

- `memset(f,0x3f,sizeof f)` 把 `int` 数组按字节填成 `0x3f`，得到近似无穷大 `0x3f3f3f3f`，用来表示「不可达」。
- 读入 $n \times n$ 的距离矩阵 `d[i][j]`；两行 `// cout...` 是调试输出，提交时应删掉。
- `int M=(1<<n)-1;` 是全 1 状态（所有点都访问过）；`f[1][0]=0` 是唯一的初始可达状态。

### 状态转移

```cpp
    for(int s=0;s<=M;s++){
		for(int i=0;i<n;i++){
			if(f[s][i]<0x3f3f3f3f){
				for(int j=0;j<n;j++){
					if(((s>>j)&1)==0){
                        //cout<<"f[M][i],mi);\n";
						int ns=s|(1<<j);
						f[ns][j]=min(f[ns][j],f[s][i]+d[i][j]);
					}//TDO
				}
			}//TODO
		}//TODO
	}
    //\\、、operator>>=(7)；
```

- 外层按 `s` 从小到大枚举 mask；由于 `s | (1<<j)` 一定比 `s` 大，用普通升序即可保证前一状态算过。
- `if(f[s][i]<0x3f3f3f3f)` 只对可达状态转移；内层枚举未访问点 `j`（`((s>>j)&1)==0`），把 `j` 加入集合，用 `f[s][i]+d[i][j]` 松弛 `f[ns][j]`。
- 行尾那几处待办注释（源码里写作 `//TDO` 与 `//` 加待办字样）是备忘残留，照搬保留。

### 统计答案

```cpp
    for(int i=0;i<n;i++){
       // cout<<f[M][i]<<endl;
		mi=min(f[M][i]+d[i][0],mi);
	}
	cout<<mi;
}
```

- 枚举终点 $i$，把「走完全程的 `f[M][i]`」再加上「从 $i$ 回到起点 0 的 `d[i][0]`」，取最小值 `mi` 输出。

## 复杂度分析

- **时间复杂度**：$O(n^2 \cdot 2^n)$。外层 $2^n$ 个 mask，每个 mask 枚举当前点 $i$（$n$ 种）与下一个点 $j$（$n$ 种）。
- **空间复杂度**：$O(n \cdot 2^n)$。DP 表 `f` 是 $2^n \times n$；本题由于用 `int f[1<<21][21]` 静态开满，约占 176 MB。

> $n \le 20$ 时 $2^{20} \approx 10^6$，$n^2 \cdot 2^n \approx 4 \times 10^8$，C++ 里比较吃紧，实际可剪枝（只枚举含当前点的状态）。

## 适用场景

- 集合决策问题：每个元素「选 / 不选」。
- 排列与路径问题：TSP、Hamilton 路径、排列计数。
- 图上与连通性 / 匹配相关的、$n$ 很小的问题。
- 共同前提：$n$ 不大（通常 $n \le 20 \sim 25$）。

## 常见陷阱与注意事项

1. **下标的基准**：起点按 0 号点处理，所以初始状态是 `f[1][0] = 0`，而不是 `f[0][0]`。
2. **无穷大选取**：用 `0x3f3f3f3f`（约 $10^9$）而非 `INT_MAX`，避免松弛时加法溢出；判可达用 `f[s][i] < 0x3f3f3f3f`。
3. **枚举顺序**：`s` 升序即可，因为加入一个点只会让 mask 变大；不需要额外排序。
4. **必须判未访问**：`((s>>j)&1)==0` 少了它就会重复经过同一个点。
5. **空间开销**：静态 `int f[1<<21][21]` 较大，注意题目内存限制，必要时改成按 `popcount` 分层或滚动的写法。
6. **`main` 返回类型**：本程序没有 `#define int long long`，`main` 保持普通 `int main()` 即可。
7. **调试残留**：源码多处注释掉的 `cout`（含那段装饰性注释）都应清理，避免误提交。

## 对比与扩展

- 与棋盘状压对比：这里压缩的是「已访问的点集」，棋盘状压压缩的是「单行的摆放」。
- 与「子集 DP」对比：TSP 的转移是「在 mask 上再加一个点」，子集 DP 的转移是「枚举 mask 的子集」，两者都建立在位运算之上。
- 扩展：若图不是完全图，先用 Floyd 预处理两点间最短路，再做状压 DP；也可以改用「枚举末点逐层扩展」的分层写法来省空间。$AKB59$, '动态规划', array['动态规划', '状态压缩', '状压DP', 'TSP', '旅行商', '最短路'], 'col-dp-bitmask-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-bitmask-hamilton', '状态压缩DP（Hamilton路径最短路）', $AKB60$## 算法原理

状态压缩动态规划（Bitmask DP）是利用**二进制位**来表示状态集合的 DP 技巧。当问题涉及"选/不选"的集合决策，且 $n$ 较小（通常 $n \le 20$）时，用一个整数的每一位表示对应元素是否被选中，可以将集合状态压缩为一个整数。

**Hamilton 路径最短路问题**：给定 $n$ 个点的带权有向图，求从点 $0$ 出发、到点 $n-1$ 结束、**不重不漏经过每个点恰好一次**的最短路径长度。这是旅行商问题（TSP）的简化版本（固定起点和终点）。

### 状态定义

$$f[\text{mask}][j] = \text{已访问集合为 mask，当前停在点 } j \text{ 时的最短路径长度}$$

其中 $\text{mask}$ 是一个 $n$ 位二进制数，第 $i$ 位为 $1$ 表示点 $i$ 已被访问。

### 状态转移

要到达状态 $(\text{mask}, j)$，上一步一定是从某个点 $k$ 走到 $j$，且 $k$ 在"去掉 $j$ 后的集合"中：

$$f[\text{mask}][j] = \min_{k \in \text{mask} \setminus \{j\}} \Big(f[\text{mask} \oplus (1 \ll j)][k] + \text{edges}[k][j]\Big)$$

即：枚举所有可能的前驱点 $k$，从 $k$ 走到 $j$，取最小值。

### 初始状态

$$f[1 \ll 0][0] = 0$$

只经过点 $0$，当前在点 $0$，路径长度为 $0$。

### 最终答案

$$f[(1 \ll n) - 1][n - 1]$$

经过所有点（全 $1$ 状态），停在终点 $n-1$。

## 逐行代码解析

### 定义与初始化

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	//Hamilton路径的定义是从0到n - 1不重不漏地经过每个点一次。
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n, m;
	cin >> n >> m;
	//f[i][j]:当前状态为i,正在j点上
	vector<vector<long long>> f((1 << n), vector<long long>(n,INT_MAX));
	vector<vector<int>> edges(n, vector<int>(n,INT_MAX));
```

- `n`、`m` 分别是有向图的点数和边数；关闭同步流是为了让 $n \le 20$ 时的读入不成为瓶颈。
- `f[mask][j]` 表示「已访问点集为 `mask`、当前停留在点 $j$」的最短路径长度。初值 `INT_MAX` 用于表示该状态尚不可达。
- `edges[u][v]` 是邻接矩阵；同样初始化为 `INT_MAX`，这样后面的松弛不会误用不存在的边。

### 读入边与起点状态

```cpp
	for (int i = 1; i <= m; i++)
	{
		int u, v, k;
		cin >> u >> v >> k;
		edges[u][v] = min(edges[u][v], k);
	}

	f[1][0] = 0;
```

- 逐条读入有向边 $(u, v, k)$，`min` 保证**重边取最小权**。
- `f[1][0] = 0`：`mask = 1` 表示「只访问了点 0」，当前正停在点 0，路径长度为 0。这是唯一的初始可达状态。

### 状态转移

```cpp
	for (int i = 1; i < (1 << n); i++)
	{
		for (int j = 0; j < n; j++)
		{
			//如果点j被经过了，则退出这一轮
			if (!((i >> j) & 1)) continue;
			for (int k = 0; k < n; k++)
			{
				//判断上一个状态的k是否被经过，如果是则松弛边
				if (((i ^ (1 << j)) >> k & 1))f[i][j] = min(f[i][j], f[i ^ (1 << j)][k] + edges[k][j]);
			}
		}
	}
```

- 外层 `i` 按 `mask` **从小到大**枚举；由于 $i \oplus 2^j < i$ 恒成立，`i ^ (1 << j)` 一定已经算过，不需要额外排序。
- 第二层要求 $j$ 在 `i` 中（`(i >> j) & 1`），否则跳过。
- 内层枚举「上一个点」$k$，要求 $k$ 属于 `i ^ (1 << j)`（去掉 $j$ 之后的状态），用 `f[i ^ (1 << j)][k] + edges[k][j]` 松弛 `f[i][j]`。

### 输出答案

```cpp
	if (f[(1 << n) - 1][n - 1] != INT_MAX) cout << f[(1 << n) - 1][n - 1];
	else cout << -1;
}
```

- 终态是「所有点都访问过」即 `(1 << n) - 1`，终点固定为 $n - 1$。
- 若该状态仍为 `INT_MAX`，说明不存在 Hamilton 路径，输出 `-1`。

## 复杂度分析

- **时间复杂度**：$O(n^2 \cdot 2^n)$
  - 外层枚举 $\text{mask}$：$2^n$ 种
  - 中层枚举当前点 $j$：$n$ 种
  - 内层枚举前驱点 $k$：$n$ 种
  - 总共有 $n \cdot 2^n$ 个状态，每个状态转移 $O(n)$

- **空间复杂度**：$O(n \cdot 2^n)$
  - DP 数组大小为 $n \times 2^n$

> $n \le 20$ 时，$2^{20} \approx 10^6$，$n^2 \cdot 2^n \approx 4 \times 10^8$，在 C++ 中勉强可过。实际中可以剪枝：只枚举含当前点的状态。

## 适用场景

状态压缩 DP 适用于以下问题：
1. **集合决策问题**：每个元素有"选/不选"两种状态
2. **排列/路径问题**：如 TSP、Hamilton 路径、排列计数
3. **图上状态问题**：如二分图匹配、连通性
4. **$n$ 较小**：通常 $n \le 20 \sim 25$

## 实现细节

### 位运算技巧

| 操作 | 代码 | 说明 |
|---|---|---|
| 判断点 $j$ 是否在 mask 中 | `(mask >> j) & 1` | 右移 j 位后取最低位 |
| 将点 $j$ 加入 mask | `mask \| (1 << j)` | 按位或 |
| 将点 $j$ 从 mask 中移除 | `mask ^ (1 << j)` | 按位异或（前提是 j 在 mask 中） |
| 全 1 状态（所有点都经过） | `(1 << n) - 1` | n 个 1 |

### 重边处理

输入可能有重边（同一对 $(u, v)$ 出现多条边），邻接矩阵需取最小值：

```cpp
edges[u][v] = min(edges[u][v], k);
```

### 数据类型

路径长度可能很大（$n$ 条边，每条边权最大 $10^9$），需用 `long long` 存储 DP 值，避免溢出。初始值设为 `INT_MAX` 表示不可达。

## 常见陷阱与注意事项

1. **n 的范围**：状压 DP 只适用于 $n \le 20$ 的情况，$n=20$ 时 $2^{20} \approx 10^6$ 已经比较吃内存
2. **初始状态设置**：起点是点 0，所以 `f[1][0] = 0`（而不是 `f[0][0] = 0`）
3. **无解情况**：如果最终状态仍是 `INT_MAX`，说明不存在 Hamilton 路径，输出 -1
4. **无向图 vs 有向图**：如果是无向图，`edges[u][v]` 和 `edges[v][u]` 都要赋值
5. **空间优化**：可以用滚动数组或按 popcount 分层枚举 mask 来优化空间，但通常不需要

## 相关知识点

- **位运算基础**：状态压缩的核心工具
- **动态规划基础**：状态定义与转移的一般方法
- **Floyd 全源最短路**：如果图不是完全图，通常先用 Floyd 预处理出任意两点最短路，再做状压 DP$AKB60$, '动态规划', array['动态规划', '状态压缩', '状压DP', 'Hamilton路径', '最短路', 'TSP'], 'col-dp-bitmask-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-bitmask-overview', '状态压缩 DP 总览（Hamilton / 棋盘 / 子集枚举）', $AKB61$## 算法原理

本页是「状态压缩 DP」的二级栏目索引：把集合或棋盘一行压成二进制整数作为状态，用位运算完成转移。

**学习顺序**：Hamilton 路径 → 棋盘状压（炮兵阵地/互不侵犯）→ 子集 DP（枚举子集）。

## 核心公式 / 状态定义与转移方程

**按题型选子栏目**：

| 题型 | 子条目 |
|---|---|
| 经过集合的最短路径 | 状态压缩DP（Hamilton路径最短路） |
| 棋盘行状态 + 相邻限制 | 棋盘状压 DP（炮兵阵地 + 互不侵犯） |
| 枚举子集做合并/分组 | 子集 DP（子集枚举 · 分组过桥 · 子集最值维护） |

常见转移：$f[S][i]=\min_{j\in S,j\ne i}\{f[S\setminus\{i\}][j]+w(j,i)\}$；子集枚举用 `for (T = S; T; T = (T-1) & S)`。

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出状态设计、位运算细节与逐行解析。

## 复杂度分析

- Hamilton：$O(2^n n^2)$。
- 棋盘状压：$O(n\cdot 2^m\cdot 2^m)$ 或按合法状态数优化。
- 子集 DP：枚举所有子集为 $O(3^n)$，按题意可进一步优化。

## 适用场景

- $n\le 20$ 左右的集合型问题。
- 棋盘/网格上只与相邻行有关的状态。
- 需要枚举子集做分组、覆盖、最值合并。

## 常见陷阱与注意事项

- 先确认 $n$ 的范围，$2^n$ 不能过大。
- 位运算优先级低，判断要加括号。
- 棋盘题先预处理合法行状态，减少枚举量。
- 子集枚举的循环边界 `T = (T-1) & S`，不要写成 `T-1`。
- 记忆化与递推的初值要统一。

## 对比与扩展

- 状压 DP vs 普通 DP：状态是集合而非单个下标。
- 子集 DP vs SOS DP：前者枚举子集，后者做高维前缀和。
- 可扩展到轮廓线 DP、插头 DP。$AKB61$, '动态规划', array['状压DP', '状态压缩', 'Hamilton', '子集DP', '总览'], null, null, 'knowledge'),
('stripe-python', 'col-dp-bracket-sequence--stripe-python', '括号序列模型 · stripe-python', $AKB62$> 本文由 stripe-python 授权合并，保留原文结构与表述。
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
```$AKB62$, '动态规划', array['括号序列', '区间DP', '计数', '栈'], 'col-dp-interval-overview', null, 'knowledge'),
('Fohen', 'col-dp-complete-bag--fenfeng', '完全背包 · Fohen', $AKB63$## 算法原理

完全背包是背包问题的一种基本变体：与 01 背包相比，每种物品不再限制"最多选一次"，而是可以**选取任意多次**（即无限件），其余设定（容量限制、求最大价值）与 01 背包完全相同。

理解完全背包的关键，在于它与 01 背包在**容量遍历顺序**上的唯一区别。回顾 01 背包的空间优化：用一维滚动数组 `f[j]` 表示容量为 `j` 时能获得的最大价值，容量必须**倒序**枚举。倒序的意义在于保证计算 `f[j]` 时用到的 `f[j - w[i]]` 仍是"上一件物品处理完"的旧状态，从而每个物品只被选取一次，不会从当前层状态转移而重复选到同一件物品。

而完全背包恰好需要"允许重复选取"，也就是允许从当前层（本件物品处理过程中）的状态继续转移。因此只需要把容量从倒序枚举改为**正序**枚举：正序时，`f[j - w[i]]` 可能已经在本次循环里被更新过（已经包含第 `i` 种物品），于是同一件物品可以被反复放入。

一句话概括：01 背包倒序、完全背包正序，二者的核心差异就在于"是否允许从当前层状态转移"。

## 核心公式 / 状态定义与转移方程

状态定义（一维滚动数组，容量记作 $m$）：

$$f[j] = \text{容量为 } j \text{ 时能获得的最大价值}$$

转移方程（第 $i$ 种物品，容量 $j$ 正序枚举）：

$$f[j] = \max\big(f[j],\; f[j - w_i] + v_i\big), \quad j \ge w_i$$

其中 $w_i$、$v_i$ 分别是第 $i$ 种物品的重量与价值；当 $j < w_i$ 时物品放不下，`f[j]` 保持不变。

写成二维形式，状态为"从前 $i$ 种物品中选取、容量为 $j$ 时的最大价值"：

$$dp[i][j] = \max\big(dp[i-1][j],\; dp[i][j - w_i] + v_i\big)$$

注意第二项用的是 $dp[i][j - w_i]$（同一行、当前物品）而非 $dp[i-1][j - w_i]$（前一行），这正是"允许重复选取"的体现。

最终答案：

$$\text{ans} = f[m]$$

## 逐行代码解析

```cpp
#include <bits/stdc++.h>
using namespace std;
pair<int,int> a[1010];
int f[1010];
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        cin>>a[i].first>>a[i].second;
    }
    for(int i=1;i<=n;i++){
        for(int j=a[i].first;j<=v;j++){
             f[j]=max(f[j],f[j-a[i].first]+a[i].second);
        }
    }
    cout<<f[v];
    return 0;
}
```

- 头文件与全局数组：`bits/stdc++.h` 是万能头；`a[1010]` 用 `pair<int,int>` 存储每种物品的「重量, 价值」；`f[1010]` 是一维滚动数组，`f[j]` 表示容量为 `j` 时的最大价值，初始全部为 `0`。
- `ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);` 关闭 C 与 C++ 流同步并解除输入输出绑定，加速读写。
- `cin>>n>>v` 读入物品种类数 `n` 与背包容量 `v`（即容量 $m$）。
- 第一个 `for` 循环读入每种物品：`a[i].first` 是重量，`a[i].second` 是价值。
- 核心双层循环：外层 `i` 逐种考虑物品；内层 `j` 从 `a[i].first`（该物品的重量）开始**正序**枚举到 `v`，这是与 01 背包唯一的不同。
- 转移 `f[j]=max(f[j], f[j-a[i].first]+a[i].second)`：不选则保持 `f[j]`，选则用「容量减掉当前物品重量后的状态」加上「当前物品价值」。由于 `j` 正序，`f[j-a[i].first]` 可能已在本次循环被更新，从而允许同一物品重复选取。
- 内层循环从 `a[i].first` 起，等价于自动跳过 `j < a[i].first` 放不下的情况。
- 最后输出 `f[v]`，即容量为 `v` 时的最大价值。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$。外层 $n$ 次、内层最多 $m$ 次，每次转移 $O(1)$。
- **空间复杂度**：$O(m)$。只使用一维滚动数组 `f`（长度 $m+1$），相较二维写法 $O(n \times m)$ 完成空间优化。

## 适用场景

适用于"每种物品可取无限件"的背包问题，例如硬币找零（求凑出某面额的最少硬币数或方案数）、无限件物品的采购、整数划分（完全背包求方案数）等。当题目明确"每种物品有无限件"或物品数量没有上限时使用。

## 常见陷阱与注意事项

- **遍历方向**：完全背包必须**正序**枚举容量，01 背包**倒序**，二者正好相反，是最容易混淆的一点；一旦写反，完全背包会退化成 01 背包（每件只选一次）。
- **转移来源**：完全背包允许从当前层状态转移，用的是"本件物品处理中"的 `f[j-w_i]`；这是与 01 背包（只能用上一层状态）的本质区别。
- **初始化**：求最大价值一般初始化为 `0`；求最小代价则初始化为一个大数（INF），注意区分。
- **边界**：根据题目是"恰好装满"还是"至多装满"来决定初始化方式，转移时只从有效状态转移。
- **整数溢出**：价值与容量较大时改用 `long long`。
- **滚动数组**：一维数组是常规写法，但务必记住遍历顺序——01 背包倒序、完全背包正序、分组背包容量循环在外层。

## 对比与扩展

- **与 01 背包**：唯一核心区别是遍历方向与转移来源——01 背包倒序、用上一层状态；完全背包正序、用当前层状态，从而允许重复选取。
- **与多重背包**：多重背包每种物品有数量上限 $s_i$，可通过二进制拆分（拆成若干 2 的幂次再加余数）转化为 01 背包，也可用单调队列优化。
- **扩展方向**：完全背包求方案数（硬币找零、整数划分）、二维费用完全背包等。$AKB63$, '动态规划', array['动态规划', '背包问题', '完全背包', '滚动数组'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-complete-bag--xesir', '完全背包 · Xesir', $AKB64$## 算法原理

完全背包：每个物品可以选**任意多次**（无限件），详见云兰阁 P1212(C9)。

看上去很简单，实际一点都不难。

上面 01 背包的优化里我们讲到，倒序枚举的原因是确保不会从本层转移、从而重复选到同一件物品。但完全背包**恰巧需要重复选择**，也就是允许从本层状态转移，所以我们只需要把倒序枚举改成**正序**即可。

状态转移：

$$
f[j] = \max\big(f[j],\ f[j - w_i] + v_i\big), \quad j \ge w_i
$$

## 逐行代码解析

### 头文件与数组

```cpp
#include <bits/stdc++.h>
using namespace std;
pair<int,int> a[1010];
int f[1010];
```

- 与 01 背包模板同款：`a[i].first` 是重量、`a[i].second` 是价值。
- `f` 直接是**一维**数组，容量从 0 扫到 `v`，不需要第二维。

### main 框架与读入

```cpp
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        cin>>a[i].first>>a[i].second;
    }
```

- 读入 $n$ 件物品的重量与价值，下标从 1 开始。

### 正序转移与输出

```cpp
    for(int i=1;i<=n;i++){
        for(int j=a[i].first;j<=v;j++){
             f[j]=max(f[j],f[j-a[i].first]+a[i].second);
        }
    }
    cout<<f[v];
    return 0;
}
```

- 关键就一处：`j` 从 `a[i].first` **递增**到 `v`。计算 `f[j]` 时 `f[j-w_i]` 可能已经被本层更新过（里面已经含了物品 $i$），于是允许无限重复选取。
- 若把这一行改成倒序，就退化成 01 背包了。
- 答案 `f[v]`。

## 复杂度分析

- **时间复杂度**：$O(n \times V)$，两层循环，每格 $O(1)$。
- **空间复杂度**：$O(V)$，一维数组直接复用。

## 适用场景

每种物品可以无限取的背包题，例如硬币找零（最少硬币数）、完全背包求方案数、不限购买数量的采购问题。题目里出现「无限件」「每种物品有无数个」就用它。

## 常见陷阱与注意事项

1. **正 / 倒序搞反**：完全背包必须**正序**，倒序会变成每件只选一次。
2. **`j` 的起点**：从 `a[i].first` 开始即可，比它小的容量放不下该物品。
3. **同数组复用**：`f` 被原地覆盖更新，别在遍历途中拿它当「上一轮」用。
4. **重量为 0 的物品**：此时 `f[j-w_i] = f[j]` 会自引用，结果不可预期，应保证输入重量 $\ge 1$。
5. **求方案数**：若变成计数版，初始化要改成 `f[0]=1`、其余为 0。
6. **溢出**：价值 / 容量较大时用 `long long`。

## 对比与扩展

与 01 背包的唯一核心差异：转移第二项是 `f[j-w_i]`（本层）还是 `f[i-1][j-w_i]`（上一层），压成一维后对应「完全正序 / 01 倒序」。完全背包可扩展为计数背包（整数划分、方案数）、多重背包（加数量上限后二进制拆分或单调队列优化）等。$AKB64$, '动态规划', array['动态规划', '背包问题', '完全背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-complete-bag', '完全背包', $AKB65$## 算法原理

完全背包是01背包的近亲：每种物品有无限件可供选取，其余设定（容量限制、求最大价值）与01背包完全相同。关键区别在于转移方程中"选了物品 $i$ 后"的依赖行号。

状态定义 $dp[i][j]$ 表示从前 $i$ 种物品中选取、容量为 $j$ 时能获得的最大价值。转移时若选第 $i$ 种物品，则剩余容量 $j - w_i$ 仍可从前 $i$ 种物品中继续选取（允许重复），因此价值为 $dp[i][j - w_i] + v_i$——注意这里用的是 $dp[i]$ 而非 $dp[i-1]$，这正是允许重复选取的本质。

为什么正序遍历容量 $j$ 能允许重复选取？因为正序遍历时，计算 $dp[i][j]$ 时 $dp[i][j - w_i]$ 可能在本次循环中已经被更新过（即已经包含了第 $i$ 种物品），从而允许同一物品被多次选取。而逆序遍历时，$dp[i][j - w_i]$ 尚未被本次循环更新，仍为第 $i-1$ 行的旧值，因此每个物品只选一次——这正是01背包的做法。

这个区别是01背包与完全背包的唯一核心差异：01背包的转移用 $dp[i-1][j-w_i]$（前一行），完全背包用 $dp[i][j-w_i]$（同一行）。对应的容量遍历方向为：01背包逆序，完全背包正序。理解这一点就掌握了两种背包的精髓。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{从前 } i \text{ 种物品中选取、容量为 } j \text{ 时的最大价值}$$

状态转移方程：

$$dp[i][j] = \max\big(dp[i-1][j],\; dp[i][j-w_i] + v_i\big), \quad j \geq w_i$$

当 $j < w_i$ 时：

$$dp[i][j] = dp[i-1][j]$$

最终答案：

$$\text{ans} = dp[n][m]$$

## 逐行代码解析

### 头文件与 main 框架

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	int n,m;
	cin >> n >> m;
```

- `n` 是物品种类数，`m` 是背包容量，二者是问题的输入。
- 万能头 `bits/stdc++.h` 与 `using namespace std;` 是竞赛常用写法，一次性引入 `vector`、`pair`、`cin/cout` 等所需组件。

### 读入物品数组

```cpp
	vector<pair<int,int>> A(n + 1);
	for(int i = 1;i <= n;i++) cin >> A[i].first >> A[i].second; // 读入每种物品的重量与价值
```

- `A[i].first` 存第 $i$ 种物品的重量，`A[i].second` 存价值。
- 数组开到 `n + 1`，下标从 $1$ 开始，`A[0]` 闲置不用，便于与 `dp[i]` 的 $i$ 对齐。

### dp 表初始化

```cpp
	vector<vector<int>> dp(n + 1,vector<int> (m + 1,0)); // dp[i][j] 表示前 i 种、容量 j 的最大价值
```

- `dp` 表大小为 $(n+1) \times (m+1)$，全部初始化为 $0$。
- `dp[0][*]` 与 `dp[*][0]` 都是 $0$，分别对应「没有物品」和「容量为 0」的边界，天然无需额外处理。

### 核心转移（双重循环）

```cpp
	for(int i = 1;i <= n;i++)
	{
		for(int j = 1;j <= m;j++)
		{
			if(j >= A[i].first) dp[i][j] = max(dp[i - 1][j],dp[i][j - A[i].first] + A[i].second); // 放得下：选 or 不选取最大值
			else dp[i][j] = dp[i - 1][j]; // 放不下：继承上一行
		}
	}
```

- 外层循环 `i` 从 $1$ 到 $n$，逐种物品考虑；内层循环 `j` 从 $1$ 到 $m$，**正序**遍历容量。
- 正序是关键：计算 `dp[i][j]` 时 `dp[i][j - A[i].first]` 可能已在本次循环被更新（已含第 $i$ 种物品），从而允许同一物品重复选取；若改成逆序就退化为 01 背包。
- 选第 $i$ 种物品用 `dp[i][j - A[i].first] + A[i].second`，注意第二项是 `dp[i]` 不是 `dp[i-1]`；不选则是 `dp[i-1][j]`。
- 当 `j < A[i].first` 时物品放不下，直接继承上一行 `dp[i-1][j]`。

### 输出结果

```cpp
	cout << dp[n][m]; // 前 n 种、容量 m 的最大价值
	return 0;
} 
```

- `dp[n][m]` 即为前 $n$ 种物品、容量 $m$ 下的最大价值。
- 输出后 `return 0;` 正常结束程序。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$。外层 $n$ 次，内层 $m$ 次，每次转移 $O(1)$。
- **空间复杂度**：$O(n \times m)$。二维写法。由于 $dp[i][j]$ 依赖 $dp[i-1][j]$ 和 $dp[i][j-w_i]$（同一行更小列），可用一维滚动数组优化为 $O(m)$，此时 $j$ 正序遍历即可。

## 适用场景

适用于每种物品可无限选取的背包问题，如硬币找零（求最少硬币数）、完全背包求方案数、无限物品采购等。当题目中物品数量没有上限或明确说明"每种物品有无限件"时使用。

## 常见陷阱与注意事项

- **容量正序遍历**：这是与01背包最核心的区别。完全背包必须正序遍历 $j$，否则变成01背包（每个物品只选一次）。
- **转移方程的行号**：第二项是 $dp[i][j-w_i]$（同一行），不是 $dp[i-1][j-w_i]$（前一行）。混淆会导致算法错误。
- **一维优化时的方向**：一维滚动数组时 $j$ 正序遍历，与01背包的逆序恰恰相反，容易混淆。
- **初始化**：求最大价值初始化为 $0$；若求"恰好装满"的方案数，初始化需特殊处理（`dp[0] = 1`，其余为 $0$）。
- **整数溢出**：当价值和容量较大时使用 `long long`。
- **物品重量为 0**：当某件物品重量 $w_i = 0$ 时，转移方程里 $dp[i][j-w_i]$ 会退化为 $dp[i][j]$（同一状态自引用）导致错误；应约定输入合法（重量 $\ge 1$），或在读入时对重量为 0 的物品特判跳过。

## 对比与扩展

与01背包的唯一核心区别：转移方程第二项用 $dp[i][j-w_i]$（同一行），对应容量正序遍历。完全背包可推广为多重背包（每种物品有数量上限 $c_i$，可通过二进制拆分或单调队列优化转化为01/完全背包）。也可扩展为计数版完全背包（求方案数）和二维费用完全背包等。

### 扩展技巧：整数划分（完全背包求方案数）

把正整数 $n$ 拆成若干个正整数之和，且**顺序无关**（例如 $1+2$ 与 $2+1$ 视为同一种）的拆分数，可用「完全背包求方案数」解决：把 $1,2,\dots,n$ 当作无限件物品，容量为 $n$，求方案数。设 $f[j]$ 表示和为 $j$ 的方案数，初始化 $f[0]=1$（空方案），转移为 $f[j] \mathrel{+}= f[j-i]$。外层枚举数字 $i$、内层正序枚举 $j$：正序允许 $i$ 被重复使用（对应"可取无限个"），而外层固定数字顺序保证 $1+2$ 与 $2+1$ 只会按一种顺序被统计一次，从而满足"组合顺序无关"。

```
f[0] = 1
for i = 1 .. n:            # 外层枚举数字 i
    for j = i .. n:        # 内层正序 j，保证组合顺序无关、只统计一次
        f[j] += f[j - i]
```

答案是 $f[n]$。$AKB65$, '动态规划', array['动态规划', '背包问题', '完全背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-count-01bag', '计数01背包（最大值方案计数）', $AKB66$## 算法原理

计数01背包在标准01背包求最大价值的基础上，同时统计达到该最大价值的不同方案数。维护两个一维数组：`nmax[j]` 记录容量 $j$ 下能达到的最大价值，`cnt[j]` 记录达到该最大价值的方案数。两者同步更新，共同维护。

转移时对每个物品 $i$（重量 $v$，价值 $m$），容量 $j$ 逆序遍历（保证01特性）。当 $j \geq v$ 时，比较"选了物品 $i$ 后的价值"（`nmax[j-v] + m`）与"当前最大价值"（`nmax[j]`），分三种情况处理：

1. **选后更优**（`nmax[j-v] + m > nmax[j]`）：最大价值被更新，之前的方案数全部作废，方案数重置为 `cnt[j-v]`（即选了物品 $i$ 后，方案数等于容量 $j-v$ 时的方案数）。
2. **选后相等**（`nmax[j-v] + m == nmax[j]`）：最大价值不变，但多了一条达到该价值的途径，方案数累加 `cnt[j-v]` 并取模。
3. **选后更差**（`nmax[j-v] + m < nmax[j]`）：不影响，`nmax[j]` 和 `cnt[j]` 均不变。

方案数通常需要对一个大质数取模（如 $10^9 + 7$），以防止数值溢出。`cnt` 数组初始化为 $1$（因为"什么都不选"也是一种有效方案），`nmax` 初始化为 $0$。

## 状态定义与转移方程

状态定义：

$$\text{nmax}[j] = \text{容量为 } j \text{ 时的最大价值}$$

$$\text{cnt}[j] = \text{达到 nmax}[j] \text{ 的方案数}$$

情况一（选后更优）：

$$\text{if } \text{nmax}[j-v] + m > \text{nmax}[j]: \quad \text{nmax}[j] = \text{nmax}[j-v] + m, \quad \text{cnt}[j] = \text{cnt}[j-v]$$

情况二（选后相等）：

$$\text{if } \text{nmax}[j-v] + m = \text{nmax}[j]: \quad \text{cnt}[j] = \big(\text{cnt}[j] + \text{cnt}[j-v]\big) \bmod k$$

最终答案：

$$\text{ans} = \text{cnt}[V]$$

其中模数 $k = 10^9 + 7$。

## 逐行代码解析

以下按模块拆分，各模块代码块按顺序拼接起来即为完整的 `.cpp` 文件。

### 模块一：头文件与全局常量

```cpp
#include<bits/stdc++.h>
using namespace std;
const long long k = 1e9 + 7; // 方案数取模用的质数模数
```

- **模数 `k`**：$10^9 + 7$，用于方案数取模，防止方案数过大溢出。
- 常量 `k` 用 `long long` 声明，与 `cnt` 数组类型一致，避免取模时类型不匹配。

### 模块二：main 入口与读入

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int N,V;
	cin >> N >> V;
```

- `N` 是物品数量，`V` 是背包容量。
- `ios::sync_with_stdio(false)` 关闭 C 标准流同步、`cin.tie(nullptr)` 解绑输入输出，加速读写。

### 模块三：DP 数组初始化

```cpp
	vector<long long> cnt(V + 1,1);  // 每个容量下"什么都不选"都是 1 种方案
	vector<long long> nmax(V + 1,0); // 每个容量下初始最大价值为 0
```

- **`cnt` 数组**：初始化为 $1$，因为"什么都不选"（价值 $0$）也是合法方案；若初始化为 $0$ 则所有方案数都会是 $0$。大小为 $V+1$。
- **`nmax` 数组**：初始化为 $0$，记录各容量下的最大价值。大小为 $V+1$。
- 下标范围是 $0 \sim V$，所以数组开到 $V+1$，最终答案就是 `cnt[V]`。

### 模块四：物品循环与容量逆序转移

```cpp
	for(int i = 1;i <= N;i++)
	{
		int v,m;
		cin >> v >> m;
		for(int j = V;j >= 1;j--)
		{
			if(j >= v) 
			{
				if(nmax[j - v] + m > nmax[j])
				{
					nmax[j] = nmax[j - v] + m;
					cnt[j] = cnt[j - v];
				}
				else if(nmax[j - v] + m == nmax[j]) cnt[j] = (cnt[j] + cnt[j - v]) % k;
			}
		}
	}
```

- **物品循环 `i`**：从 $1$ 到 $N$，每次读入当前物品的重量 `v` 与价值 `m`，逐个处理。
- **容量循环 `j`**：从 $V$ 逆序遍历到 $1$，保证 01 背包特性（每个物品只选一次）；若正序则会变成完全背包计数。
- **边界 `j >= v`**：只有容量装得下才转移，同时防止 `j - v` 下标越界（当 `v > V` 时直接跳过，该物品不参与）。
- **三情况分支**：`>` 时更新最大价值并把方案数"替换"为 `cnt[j-v]`；`==` 时方案数累加 `cnt[j-v]` 并取模；`<` 时保持不变。

### 模块五：输出答案

```cpp
	cout << cnt[V];
	return 0; 
}
```

- **输出**：`cnt[V]` 即容量 $V$ 下达到最大价值的方案数，也是最终答案。
- `return 0;` 结束 `main`，与开头的 `{` 配对闭合整个函数。

## 复杂度分析

- **时间复杂度**：$O(N \times V)$。物品循环 $N$ 次，容量循环 $V$ 次，每次转移为 $O(1)$ 的比较和更新。
- **空间复杂度**：$O(V)$。使用两个一维数组 `nmax` 和 `cnt`，无需二维表。

## 适用场景

适用于既要求最大价值、又要求统计达到该最大价值的方案数的问题。常见于计数类背包题目，模数通常为 $10^9 + 7$。当题目问"有多少种选法能获得最大价值"时使用。

## 常见陷阱与注意事项

- **`cnt` 初始化为 1**：因为"什么都不选"也是一种方案（价值为 $0$），如果初始化为 $0$ 则所有方案数都会是 $0$。
- **`nmax` 初始化为 0**：对应最大价值初始为 $0$。若要求"恰好装满"则初始化需调整。
- **容量逆序遍历**：必须逆序，否则同一物品会被重复选取（变成完全背包计数）。
- **取模时机**：累加方案数时立即取模（`% k`），避免中间结果溢出。
- **情况一与情况二的区分**：更新最大价值时方案数是"替换"（`cnt[j] = cnt[j-v]`），而非"累加"。只有相等时才是累加。
- **`long long` 类型**：方案数可能很大，`cnt` 和 `nmax` 均使用 `long long` 防止溢出。

## 对比与扩展

与标准01背包相比，额外维护了方案数数组 `cnt`，转移时增加"更优/相等/更差"三种情况的分支判断。此思路可推广到完全背包计数（正序遍历）、LIS计数、最大子段和计数等任何"求最值同时统计方案数"的DP问题。若需输出具体方案，可结合路径还原技术。$AKB66$, '动态规划', array['动态规划', '背包问题', '计数', '01背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-digit-count', '数位统计（数字计数）— 按位统计数码出现次数', $AKB67$## 算法原理

### 问题描述

给定两个正整数 $a, b$，求在区间 $[a, b]$ 中的所有整数中，每个数码 $0 \sim 9$ 各出现了多少次。

- 数据范围：$1 \le a \le b \le 10^{12}$
- 前导零不计入统计。例如 $5$ 不写成 $05$，十位的 $0$ 不算。

### 核心思想：前缀和转化

区间 $[a, b]$ 的答案等于 $[1, b]$ 减去 $[1, a-1]$：

$$
\text{ans}[a,b] = \text{solve}(b) - \text{solve}(a-1)
$$

其中 $\text{solve}(n)$ 表示统计 $1 \sim n$ 中每个数码出现的次数。

这样就把区间问题转化为了求前缀的问题，只需要实现一个函数 `solve(num)`。

### 核心思想：按位独立统计

暴力枚举每个数再拆位统计的时间复杂度是 $O(n \log n)$，当 $n = 10^{12}$ 时完全不可行。

换个角度：**每个数位可以独立统计，最后把所有位的贡献相加。**

观察 $1 \sim 99$ 中数字 $1$ 出现的次数：
- 个位是 $1$：$1, 11, 21, \dots, 91$，共 $10$ 次
- 十位是 $1$：$10 \sim 19$，共 $10$ 次
- 总计 $20$ 次

个位和十位的统计是独立的，可以分开计算再相加。

---

## 核心公式与变量定义

设当前统计第 $k$ 位，权重 $i = 10^k$（个位 $i=1$，十位 $i=10$，百位 $i=100$...）。

将数字 $N$ 按当前位拆分为三部分：

$$
N = \text{num\_h} \times 10i + \text{current} \times i + \text{lower}
$$

| 变量 | 含义 | 计算方式 |
|------|------|----------|
| `num_h` | 高位部分（当前位左边的数字） | `num / i / 10` |
| `current` | 当前位数字 | `(num / i) % 10` |
| `lower` | 低位部分（当前位右边的数字） | `num % i` |
| `num_d` | 当前位及低位组成的数 | `num % (i * 10) = current * i + lower` |

例如 $N = 345$，统计十位（$i = 10$）：
- `num_h = 345 / 10 / 10 = 3`
- `current = (345 / 10) % 10 = 4`
- `lower = 345 % 10 = 5`
- `num_d = 345 % 100 = 45`

---

## 非零数码 d = 1~9 的统计公式

当前位要统计数码 $d$ 出现的次数，分两种情况：

### 情况一：高位 < num_h

高位可以取 $0 \sim \text{num\_h}-1$，共 `num_h` 种。  
每种情况下，当前位固定为 $d$，低位可以任意取 $0 \sim i-1$，共 $i$ 种。

贡献：

$$
\text{num\_h} \times i
$$

### 情况二：高位 = num_h

看当前位数字 `current` 与 $d$ 的关系：

- **若 current > d**：当前位可以取到 $d$，低位任意，额外贡献 $i$
- **若 current == d**：当前位取 $d$，低位只能取 $0 \sim \text{lower}$，额外贡献 $\text{lower} + 1$
- **若 current < d**：当前位取不到 $d$，额外贡献 $0$

### 代码中的等价写法

代码中令 `q = num_d - i * d = (current - d) * i + lower`：

| q 的范围 | 对应关系 | 贡献 |
|----------|----------|------|
| `q >= i` | current > d | 加 $i$ |
| `0 <= q < i` | current == d | 加 `q + 1`（即 lower + 1） |
| `q < 0` | current < d | 加 $0$ |

为什么 `q + 1` 等于 `lower + 1`？当 `current == d` 时，`q = 0 * i + lower = lower`，所以 `q + 1 = lower + 1`。

---

## 数码 0 的特殊处理

数码 $0$ 不能作为前导零出现，需要特殊处理。

### 为什么需要特殊处理？

如果用和非零数码一样的公式统计 $0$，会把前导零也算进去。比如统计十位的 $0$ 时，一位数 $5$ 会被当作 `05`，十位的 $0$ 也被统计了，但实际上前导零不算。

### 基础贡献

高位不能从 $0$ 开始（否则就是前导零），高位只能从 $1$ 到 `num_h - 1`，共 `num_h - 1` 种。

贡献：

$$
(\text{num\_h} - 1) \times i
$$

若 `num_h == 0`，说明当前位就是最高位且为 $0$，属于前导零，直接跳过这一位。

### 额外贡献

仅当 `num_h > 0` 时才考虑高位等于 `num_h` 的情况：

- **若 current > 0**：当前位可以取到 $0$，低位任意，额外贡献 $i$
- **若 current == 0**：当前位取 $0$，低位只能取 $0 \sim \text{lower}$，额外贡献 $\text{lower} + 1$

代码中因为 $d=0$，所以 `q = num_d - i * 0 = num_d`，判断逻辑和非零数码一致。

---

## 完整算法流程

```
函数 solve(num):
    初始化 ans[0..9] = 0
    对于每一位 i = 1, 10, 100, ... (i <= num):
        num_h = num / i / 10      // 高位
        num_d = num % (i * 10)    // 当前位及低位

        对于数码 d = 0 到 9:
            如果 d == 0:
                p = num_h - 1     // 高位从 1 开始
                如果 p < 0: 跳过   // 最高位是 0，属于前导零
                q = num_d
                ans[0] += p * i   // 基础贡献
                如果 q >= i: ans[0] += i
                否则如果 q >= 0: ans[0] += q + 1
            否则:
                p = num_h
                q = num_d - i * d
                ans[d] += p * i   // 基础贡献
                如果 q >= i: ans[d] += i
                否则如果 q >= 0: ans[d] += q + 1
    返回 ans
```

---

## 样例验证

### 样例输入

```
1 99
```

### 手动计算（统计 1~99）

个位统计（$i = 1$）：
- `num_h = 99 / 1 / 10 = 9`
- `num_d = 99 % 10 = 9`
- 数码 $d \neq 0$：`p = num_h = 9`，基础贡献 $\text{num\_h} \times i = 9 \times 1 = 9$；`q = num_d - i × d = 9 - d`。
  - 当 $d \le 8$ 时 $q \ge 1 = i$，进入 `q >= i` 分支，额外加 $i = 1$；
  - 当 $d = 9$ 时 $q = 0$，进入 `0 <= q < i` 分支，额外加 `q + 1 = 1`。
  两种情况额外贡献都恰好为 1，因此个位贡献恒为 $9 + 1 = 10$（$d = 1 \sim 9$ 均成立）。

交叉验证：直接数 1~99 中数字 1 出现的次数。
- 个位是 1：1, 11, 21, ..., 91 → 10 次
- 十位是 1：10~19 → 10 次
- 总共 20 次

数码 0 出现的次数：
- 个位是 0：10, 20, ..., 90 → 9 次
- 十位是 0：0 次（前导零不算）
- 总共 9 次

### 样例输出

```
9 20 20 20 20 20 20 20 20 20
```

与题目样例一致。

---

## 逐行代码解析

### fn 函数（统计 1~num 中各数码出现次数）

```cpp
vector<long long> fn(long long num)
{
    vector<long long> ans(10,0);      // ans[0]~ans[9] 存储各数码出现次数

    for(long long i = 1;i <= num;i *= 10)   // 枚举每一位：个位、十位、百位...
    {
        long long num_h = num / i / 10;     // 高位部分
        long long num_d = num % (i * 10);   // 当前位及低位

        for(int d = 0;d <= 9;d++)           // 统计每个数码 0~9
        {
            if(d == 0)                       // 数码 0 特殊处理
            {
                long long p = num_h - 1;     // 高位从 1 开始（不能全是前导零）
                if(p < 0) continue;          // 最高位是 0，跳过
                long long q = num_d - i * d; // 因为 d=0，q = num_d
                ans[d] += p * i;             // 基础贡献
                if(q >= i) ans[d] += i;      // current > 0，加 i
                else if(q >= 0) ans[d] += q + 1; // current == 0，加 lower+1
            }
            else                              // 非零数码
            {
                long long p = num_h;
                long long q = num_d - i * d;
                ans[d] += p * i;             // 基础贡献
                if(q >= i) ans[d] += i;      // current > d，加 i
                else if(q >= 0) ans[d] += q + 1; // current == d，加 lower+1
            }
        }
    }
    return ans;
}
```

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);

    long long l,r;
    cin >> l >> r;

    vector<long long> t1 = fn(r);     // [1, r] 的统计
    vector<long long> t2 = fn(l - 1); // [1, l-1] 的统计

    // 前缀和相减得到 [l, r] 的答案
    for(int i = 0;i <= 9;i++) cout << t1[i] - t2[i] << ' ';
    return 0;
}
```

### 关键变量对照表

| 变量 | 类型 | 含义 |
|------|------|------|
| `i` | long long | 当前位的权重（1, 10, 100, ...） |
| `num_h` | long long | 高位部分（当前位左边的数字） |
| `num_d` | long long | 当前位及低位组成的数 = current * i + lower |
| `p` | long long | 高位的合法取值数量 |
| `q` | long long | 用于判断当前位与 d 的大小关系，current==d 时 q = lower |
| `ans[d]` | long long | 数码 d 出现的总次数 |

---

## 复杂度分析

### 时间复杂度

外层循环枚举每一位，最多约 $13$ 次（$10^{12}$ 有 13 位）。  
内层循环枚举数码 $0 \sim 9$，共 $10$ 次。

总操作数约 $130$ 次，时间复杂度：

$$
O(10 \cdot \log_{10} N) = O(\log N)
$$

### 空间复杂度

只用到了大小为 10 的数组，空间复杂度 $O(1)$。

---

## 适用场景

1. **数码计数问题**：统计区间内某数码出现的次数
2. **数位 DP 入门**：按位统计是数位 DP 的基础思想
3. **数字规律题**：涉及数位规律的数学问题
4. **前缀和转化**：区间 $[a,b]$ 转化为前缀差的经典应用

---

## 常见陷阱与注意事项

### 1. 额外贡献要 +1

当当前位恰好等于要统计的数码 $d$ 时，低位可以取 $0 \sim \text{lower}$，共 `lower + 1` 种，不是 `lower` 种。

代码中必须写成 `ans[d] += q + 1`，而不是 `ans[d] += q`。这是最容易漏掉的地方。

### 2. 数码 0 的前导零问题

统计 $0$ 时，高位不能从 $0$ 开始，基础贡献用 `num_h - 1` 而不是 `num_h`。  
如果 `num_h == 0`，说明当前位就是最高位且为 $0$，属于前导零，必须 `continue` 跳过。

### 3. 数据类型要用 long long

答案可能很大：$10^{12}$ 有 12 位，每位上每个数码最多出现约 $10^{11}$ 次，总和约 $10^{12} \times 12$，必须用 `long long`。

### 4. l - 1 可能为 0

当 $l = 1$ 时，`l - 1 = 0`，`fn(0)` 应该返回全 0 数组。  
代码中循环条件是 `i <= num`，当 `num = 0` 时循环不执行，返回全 0，正确。

### 5. i *= 10 可能溢出

当 `num` 接近 `long long` 上限时，`i *= 10` 可能溢出。对于 $10^{12}$ 来说，`i` 最大到 $10^{12}$，远小于 long long 上限（$9 \times 10^{18}$），没问题。如果题目范围更大，需要额外判断溢出。

### 6. num_d 的计算

`num_d = num % (i * 10)`，注意是 `i * 10` 而不是 `i`。`num_d` 包含当前位和低位，长度是两位（以当前位为个位来看）。

### 7. 非零数码的高位从 0 开始是合法的

非零数码统计时，高位取 0 是正常的，因为即使高位全是 0，只要当前位是 $d \neq 0$，这个数就不是前导零。只有当数码本身是 0 时，才需要担心前导零问题。

### 8. q < 0 时不加

当 `current < d` 时，`q = num_d - i * d < 0`，此时没有额外贡献，什么也不加。不要误写成加 0 以外的东西。

---

## 扩展：从数位统计到数位 DP

本题是**按位统计法**，用数学公式直接计算每一位的贡献。更一般的数位问题（带约束条件、状态更复杂）需要用**数位 DP**：

| 方法 | 适用场景 | 特点 |
|------|----------|------|
| 按位统计（本题） | 简单的数码计数、数字和等 | 公式推导，代码短，速度快 |
| 数位 DP | 带约束的计数问题（如不含4、各位和为k等） | 记忆化搜索，状态灵活，通用性强 |

数位 DP 的核心思想也是"按位处理"，但用 DP 状态记录更复杂的约束条件（如是否紧贴上界、是否有前导零、各位数字和等）。本题可以看作数位 DP 的最简版本。$AKB67$, '动态规划', array['数位DP', '数位统计', '数学', '按位处理', '前导零', '洛谷'], null, null, 'knowledge'),
('Fohen', 'col-dp-digit-memo--fenfeng', '数位 DP（记忆化搜索框架） · Fohen', $AKB68$## 算法原理

数位 DP 是一类专门处理「与数字的每一位有关」的计数 / 最值问题的算法。它不枚举区间里的每一个数，而是从最高位开始一位一位地「填数字」，配合记忆化搜索，把「数位上的限制」翻译成状态与转移。套路非常固定：只要理解了「按位枚举 + 记忆化搜索」这个框架，再复杂的限制也不过是往状态里多加几个维度。

**区间转前缀**。这类问题通常问「$[L, R]$ 中有多少个数满足某个性质」。直接统计区间很麻烦，于是定义 `solve(x)` 表示 $[0, x]$（或 $[1, x]$，视题目而定）中满足条件的个数，答案可以写成一个前缀差：

$$
\text{ans} = \text{solve}(R) - \text{solve}(L - 1)
$$

于是任务被规约成：给定一个上界 `x`，统计从 $0$ 到 `x` 的所有整数中有多少个符合条件。这一步把「区间」转化为「前缀」，是数位 DP 的第一个关键动作。

**为什么用记忆化搜索而不是循环 DP**。数位 DP 的状态里通常有「是否贴着上界」这一维，它与具体上界强相关，循环 DP 需要精细处理从高位到低位的贴界与进位；而记忆化搜索直接用递归参数表达这些约束，写起来更直观，且天然按位推进。这也是本知识点以「记忆化搜索框架」命名的原因。

## 核心公式 / 状态定义与转移方程

### 状态定义

从最高位开始逐位填数，递归过程中维护几类通用状态：

- `pos`：当前处理到第几位（从高位向低位推进）。
- `tight`（本实现写为 `is_limited`）：是否已经「贴住上界」。若为真，当前位最大只能填上界的对应位；否则可填 $0 \sim 9$。
- `started`（本实现写为 `qdz`，含义是「是否仍处于前导零」）：是否已经开始填非零数字。前导零不参与某些限制，比如相邻数字差的判断。
- 附加状态视题目而定：上一个数字、连续相同长度、是否出现过某个数码、当前已填数字的模数余数等。

### 转移方程

设当前位上限为 $\text{upper}$：当 `tight` 为真时 $\text{upper} = \text{digits}[pos]$，否则 $\text{upper} = 9$。枚举数字 $d \in [0, \text{upper}]$，有：

$$
\text{dfs}(pos, \cdots) = \sum_{d = 0}^{\text{upper}} \text{dfs}\bigl(pos - 1, \cdots\bigr)
$$

其中状态的更新为：新贴界 = `is_limited && (d == digits[pos])`，新前导零 = `qdz && (d == 0)`，其余附加状态按题目约束更新。递归基为「所有位都填完时返回 $1$」，表示当前这条填数路径是一个合法方案。

### 通用框架（伪代码）

```cpp
int digits[...];     // 上界 N 的各位数字
long long dp[...];   // 记忆化数组，维度按状态而定

long long dfs(int pos, /* 附加状态… */, bool is_limited, bool is_leading_zero) {
    if (pos == 0) return 1;                            // 递归基：所有位填完
    if (!is_limited && !is_leading_zero && dp[pos][...] != -1)
        return dp[pos][...];                           // 记忆化查表
    long long ans = 0;
    int upper_bound = is_limited ? digits[pos] : 9;    // 当前位上限
    for (int d = 0; d <= upper_bound; ++d) {
        // …检查 d 是否合法（附加状态）…
        ans += dfs(pos - 1, /* 新附加状态… */, is_limited && (d == digits[pos]),
                   is_leading_zero && (d == 0));
    }
    if (!is_limited && !is_leading_zero)
        dp[pos][...] = ans;                            // 记录状态
    return ans;
}

long long solve(long long n) {
    if (n < 0) return 0;
    if (n == 0) return 1;                              // 0 是否算数按题意处理
    int len = 0;
    while (n > 0) { digits[++len] = n % 10; n /= 10; }
    memset(dp, -1, sizeof(dp));
    return dfs(len, /* 附加状态初值… */, true, true);
}

long long result = solve(R) - solve(L - 1);            // 区间转前缀
```

### 本题（windy 数）的状态与转移

下方代码以「windy 数」为例：不含前导零、且相邻两个数字之差至少为 $2$ 的正整数称为 windy 数，统计区间 $[a, b]$ 内 windy 数的个数（$a, b \le 10^{18}$）。状态设计：

- `w`：当前位（从 $1$ 到 `dqw`，`dqw` 为上界位数）。
- `is_limited`：是否贴住上界。
- `qianyiwei`：上一位填的数字（$0 \sim 9$），用于判断相邻差。
- `qdz`：是否仍处于前导零（$1$ 表示尚未开始）。

转移时枚举数字 $i \in [0, \text{upper}]$，其中 $\text{upper}$ 由贴界情况决定；若「已开始且 $\lvert \text{qianyiwei} - i \rvert < 2$」则剪枝，若 `is_limited` 且 $i > N[w]$ 则越界剪枝。

## 逐行代码解析

### 模块一：全局定义与 DP 数组

```cpp
#include <bits/stdc++.h>   // 万能头文件
using namespace std;
#define int long long   // 全局 long long，避免计数溢出
string l,r;   // 区间端点（字符串，便于逐位拆分）
int dp[30][2][30][2],N[30];   // 记忆化数组 / 上界各位数字
int dqw;   // 上界位数
```

- `dp[30][2][30][2]` 的四个下标依次是 `pos / is_limited / qianyiwei / qdz`；`30` 足够容纳 `long long` 范围内最多 $19$ 位的数。
- `N[i]` 存上界第 $i$ 位的数字（下标从 $1$ 开始），配合 `is_limited` 限制当前位能填的上限。
- `#define int long long` 把 `int` 全局替换为 `long long`，主函数因此写成 `signed main()`，避免答案溢出。

### 模块二：dfs 函数（记忆化搜索主体）

```cpp
int dfs(int w,int is_limited,int qianyiwei,int qdz){
    if(dp[w][is_limited][qianyiwei][qdz]!=-1) return dp[w][is_limited][qianyiwei][qdz];   // 已算过：查表直接返回
    if(w==dqw+1) return 1;   // 递归基：所有位都填完
    dp[w][is_limited][qianyiwei][qdz]=0;   // 清零后累加子状态
    for(int i=0;i<10;i++){   // 枚举当前位 0~9
        if(abs(qianyiwei-i)<2&&qdz!=1) continue;   // 相邻差不足 2 且已开始 → 非法
        if(is_limited&&i>N[w]) continue;   // 贴界却填大 → 非法
        dp[w][is_limited][qianyiwei][qdz]+=dfs(w+1,is_limited&&(i==N[w]),i,qdz&&(i==0));   // 转移：更新贴界与前导零
    }
    return dp[w][is_limited][qianyiwei][qdz];
}
```

- 递归基是 `w == dqw + 1`：此时所有位都已填完，返回 $1$ 表示这是一条合法路径。
- 记忆化查表放在最前面：`dp` 初始化为 $-1$，一旦 `!= -1` 说明该状态已算过，直接复用，避免重复计算。
- `is_limited && (i == N[w])` 更新贴界：只有原本贴界且本位置恰好等于上界对应位，下一层才继续贴界。
- `qdz && (i == 0)` 更新前导零：只有原本全是 $0$ 且本位置仍填 $0$，才继续处于前导零。

### 模块三：solve 函数（数位拆分）

```cpp
int solve(string x){
	memset(dp,-1,sizeof dp);   // 每次 solve 重置记忆化
	 for(int i=0;i<x.size();i++){   // 逐字符拆分上界
	           N[i+1]=x[i]-48;   // 字符转数字（ASCII 48 即 0）
	       }
	 dqw=x.size();   // 记录位数
	 return dfs(1,1,0,1);   // 从第 1 位开始，贴界且处在前导零
}
```

- 入口参数是字符串 `x`，用 `x[i] - 48` 把字符转成数字存进 `N`，避免了 `long long` 拆位时反复取模的麻烦。
- `dfs(1, 1, 0, 1)` 的四个初值：从第 $1$ 位开始、贴住上界、上一位为 $0$、仍处在前导零。
- 每次 `solve` 前必须 `memset(dp, -1, ...)`，因为不同的上界对应不同的 `dp` 表，不能跨上界复用。

### 模块四：主函数（区间转前缀）

```cpp
signed main(){
	int a,b;cin>>a>>b;a--;   // 读区间，a 减一
	l=to_string(a),r=to_string(b);   // 端点转字符串
	cout<<solve(r)-solve(l);   // 前缀差即答案
}
```

- `a--` 对应公式 $\text{solve}(b) - \text{solve}(a - 1)$，把区间 $[a, b]$ 转成两个前缀之差。
- `to_string` 把端点转成字符串，交给 `solve` 逐位拆分。
- 主函数写成 `signed main()`，因为 `#define int long long` 会改写 `int main` 中的 `int`。

## 复杂度分析

数位 DP 的复杂度只与「位数」和「状态数」有关，与数字本身的大小无关。

设上界有 $L$ 位（`long long` 范围内 $L \le 19$），除 `pos / tight / started` 之外的附加状态总数为 $S$。记忆化搜索保证每个状态最多被计算一次，而每个状态要枚举 $0 \sim 9$ 共 $10$ 个数做转移，因此单次 `solve`：

- **时间复杂度**：$O(L \cdot S \cdot 10)$。`tight`、`started` 各两种取值带来的常数因子并入大 O。
- **空间复杂度**：$O(L \cdot S)$，即记忆化数组 `dp` 的大小。

以本实现（windy 数）为例：$L \le 19$，附加状态只有「上一位数字」$S = 10$，状态总数约 $19 \times 2 \times 10 \times 2 = 760$，每个状态枚举 $10$ 个数，单次 `solve` 只有几千次操作。这也是数位 DP 能轻松应付 $10^{18}$ 量级区间的原因。

## 适用场景

1. **区间计数**：统计 $[L, R]$ 内满足「数位性质」的数的个数（不含某数码、相邻数字差、各位和等）。
2. **超大上界**：$L, R$ 可达 $10^{18}$ 甚至大整数（逐位存储），暴力枚举不可行而数位 DP 仍很快。
3. **带数位约束的最值 / 构造**：在满足数位限制的前提下求最大值、第 $k$ 小等。
4. **前导零敏感问题**：需要区分「真实数字」与「前导零」的题目（如 windy 数、统计数码出现次数）。

不适合的场景：与数位无关的计数，或状态必须与「完整数字」强绑定的问题——此时「区间转前缀」与按位状态拆分发挥不了作用。

## 常见陷阱与注意事项

1. **前导零**：前导零不算真实数字。若把它当成普通数字参与相邻差、出现次数等限制会多算；维护 `started` 状态，直到第一次填非零数字才真正「开始」。
2. **0 是否算数**：`solve(-1)` 应为 $0$，而 `solve(0)` 返回 $1$ 还是 $0$ 取决于题意是否承认 $0$ 满足条件，需单独确认。
3. **记忆化的时机**：严格说只在 `!tight && !started` 时缓存结果。把「贴界」状态也放进 `dp` 维度（如本例）正确性不受影响，但会把状态与具体上界绑定，复用率下降。
4. **状态维度爆炸**：不要随意加维度。若某个信息只在递归基里用到，可考虑用数学方法（数位和、余数）代替，避免状态数激增。
5. **贴界上限**：贴界时当前位上限是上界对应位 `N[w]`，否则是 $9$；把上限恒设成 $9$ 会漏掉贴界剪枝，导致结果偏大。

## 对比与扩展

| 方法 | 思路 | 适用 | 特点 |
|---|---|---|---|
| 按位统计法 | 用公式直接算每一位的贡献 | 数码计数、各位和等简单问题 | 代码短、$O(\log N)$，但约束一复杂就难写 |
| 数位 DP（记忆化搜索） | 逐位填数 + 状态转移 | 任意数位约束的计数 / 最值 | 通用性强、状态灵活 |

按位统计法可以看作数位 DP 的最简形态：两者都「按位处理」，而记忆化搜索框架把「紧贴上界、前导零、附加约束」统一成状态，能推广到任意数位限制。

**变体与扩展方向**：

- **固定位数**：如「11 位手机号码」问题，首位不能是 $0$，可直接限定第一位枚举 $1 \sim 9$，省去 `started` 状态。
- **连续相同段**：增加 `same`（当前连续长度）、`has4 / has8`（是否出现过某数码）等状态，用于「至少三个相邻相同且不能同时出现 4 和 8」这类约束。
- **子串禁止 / 自动机**：若限制「不能出现某子串」，可把已填后缀压成 AC 自动机节点作为状态。
- **记忆化搜索 ↔ 迭代 DP**：两者可互转，记忆化搜索更直观，迭代 DP 常数更小。$AKB68$, '动态规划', array['数位DP', '记忆化搜索', '按位枚举', '区间转前缀', '前导零'], null, null, 'knowledge'),
('Xesir', 'col-dp-digit-memo--xesir', '数位 DP — 按位填数与记忆化搜索 · Xesir', $AKB69$## 算法原理

数位 DP 是一类专门处理**与数字的每一位有关**的计数 / 最值问题的算法。它的套路极其固定，一旦你理解了「按位枚举 + 记忆化搜索」的框架，再花里胡哨的限制也不过是往状态里加几个维度的事。

### 核心思想：区间转前缀

数位 DP 通常解决「$[L, R]$ 中有多少个数满足某个性质」这样的问题。我们不会直接统计区间，而是定义函数 `solve(x)` 表示 $[0, x]$ 中满足条件的个数，然后答案就是：

$$
\text{ans} = \text{solve}(R) - \text{solve}(L-1)
$$

所以任务就变成：给定一个上界 `x`，统计从 `0` 到 `x` 的所有整数中有多少个符合条件。

### 通用框架：记忆化搜索按位填数

我们从最高位（通常是十进制最高位）开始，一位一位地填数字。搜索过程中需要维护几个**通用的状态**：

- `pos`：当前处理到第几位（从高位往低位，或从低往高，常见从高位）。
- `tight`（或 `limit`）：布尔值，表示此前填的数字是否已经**贴住了上界**。如果 `tight=true`，则当前位最大只能填上界的对应位；否则可以填 `0~9`。
- `started`（或 `leadZero`）：布尔值，表示是否已经开始填写**非前导零**的数字。因为数字可以有不同长度，前导零不参与某些限制（如相邻数字差的限制、数字出现次数的统计等）。
- 其他状态视题目而定。

**关键点**：

- **记忆化的条件**：只有当 `!tight && !started` 时才缓存结果。
- **前导零的处理**：如果 `started=false` 且继续填 0，通常不更新「上一个数字」等状态，否则会错误地把前导零当成普通数字。直到第一次填非零数字，才真正「开始」一个数。

### 常见附加状态

除了 `pos, tight, started`，每道题还会加入一些特定的限制信息：

- **上一个数字**：用于处理相邻数字差、连续相同等。
- **连续相同长度**：如要求至少出现三个相邻相同数字。
- **数字出现情况**：如是否出现过 4 或 8，某些数字的个数。
- **模数余数**：如果要求数字能被某个数整除，维护当前已填数字构成的数模某个数的余数。
- **自动机状态**：如果限制了不能出现某个子串（如「13」），可以将已填的后缀压成 AC 自动机节点。

**原则**：状态维度要尽量少，但必须保证未来决策所需的信息完整。如果少了某个信息，不同历史会导致不同的合法后继，那就必须加进来。

## 核心公式 / 状态定义与转移方程

**状态定义**：一个状态由「当前位 `pos`」加上若干限制维度组成，通用部分为 `(pos, tight, started)`（或等价的 `is_limited` / `is_leading_zero`），再加题目特有的维度。

**转移**：在当前位置枚举可填数字 `i`（`0 ~ upper_bound`）：

$$
\text{upper\_bound} = \begin{cases} \text{digits}[pos], & \text{tight} = \text{true} \\ 9, & \text{tight} = \text{false} \end{cases}
$$

$$
\text{ans} = \sum_{i=0}^{\text{upper\_bound}} \text{dfs}(pos-1,\ \ldots,\ \text{new\_tight},\ \text{new\_started})
$$

其中 `new_tight = tight && (i == digits[pos])`，`new_started = started || (i != 0)`。

**记忆化条件**：仅当 `!tight && !started` 时把 `ans` 存入 `dp`，因为带上界的路径只走一次、复用率低。

## 逐行代码解析

下面把整章涉及的代码按顺序拆开讲。

### 模块一：通用框架模板

```cpp
int digits; // 存储 N 的各位数字
long long dp[...]; // 记忆化数组，维度根据状态而定
// dfs 函数
long long dfs(int pos, ..., bool is_limited, bool is_leading_zero) {
	// 1. 递归基：所有位都填完了
	if (pos == 0) return 1; // 或其他基本情况
	// 2. 记忆化：在特定条件下查表
	if (!is_limited && !is_leading_zero && dp[pos][...] != -1) {
		return dp[pos][...];
	}
	long long ans = 0;
	int upper_bound = is_limited ? digits[pos] : 9; // 确定当前位的上限
	// 3. 循环遍历当前位可以填的数字
	for (int i = 0; i <= upper_bound; ++i) {
		// ... 检查 i 是否合法 ...
		ans += dfs(pos - 1, ..., new_is_limited, 		new_is_leading_zero);
	}
	// 4. 记录状态
	if (!is_limited && !is_leading_zero) {
		dp[pos][...] = ans;
	}
	return ans;
}
long long solve(long long n) {
	if (n < 0) return 0;
	if (n == 0) return 1; // 0 是一个满足条件的数（如果题目允许）
	// 1. 将 n 转换为数位数组
	int len = 0;
	while (n > 0) {
		digits[++len] = n % 10;
		n /= 10;
	}
	// 2. 初始化 DP 数组
	memset(dp, -1, sizeof(dp));
	// 3. 从最高位开始 DFS
	// 注意：digits 数组是反的，所以从 len 开始
	return dfs(len, ..., true, true);
}
// 主程序入口
long long result = solve(R) - solve(L - 1);
```

- 递归基 `pos == 0` 时返回 1，表示这条路径填出了「一个合法数字」。
- 记忆化前先查表，`!is_limited && !is_leading_zero` 才查 / 存，避免把与上界绑定的状态缓存下来。
- `digits` 通过 `n % 10` 从低位到高位填，所以 `digits[1]` 是最低位，`solve` 里要从 `len`（最高位）开始 DFS。
- 这就是「模板」：真正的题目只需替换成自己的状态维度和合法性检查。

### 模块二：例题一 windy 数

> **题意**：不含前导零且相邻两个数字之差至少为 2 的正整数称为 windy 数，统计区间 $[a,b]$ 内的 windy 数个数。$a,b \le 10^{18}$。

**状态设计**：

- `pos`：当前处理到第几位（从高位到低位）。
- `tight`：是否贴住上界。
- `last`：上一位填的数字（0~9），用于判断相邻差。
- `started`：是否已经开始（前导零判断）。

**转移**：在当前位置尝试填数字 `d`（`0~lim`）。

- 如果 `started=false` 且 `d=0`，则仍未开始，`last` 保持为某个不影响判断的值（例如 0，但要小心别和真实数字 0 混淆，可在转移时特判）。
- 如果 `started=true` 或 `d!=0`，则检查 `abs(d - last) >= 2`（若是第一个非零数字，无需检查，因为前面没有数字）。
- 更新 `nstarted = started || (d != 0)`，`nlast = d`（仅当 `nstarted` 为真才更新）。

**递归基**：填完所有位后返回 1（只要每一步都合法，就算一个）。**记忆化**：对 `pos, last, started` 缓存。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[30][2][30][2],N[30];
int dqw;
int dfs(int w,int is_limited,int qianyiwei,int qdz){
    if(dp[w][is_limited][qianyiwei][qdz]!=-1) return dp[w][is_limited][qianyiwei][qdz];
    if(w==dqw+1) return 1;
    dp[w][is_limited][qianyiwei][qdz]=0;
    for(int i=0;i<10;i++){
        if(abs(qianyiwei-i)<2&&qdz!=1) continue;
        if(is_limited&&i>N[w]) continue;
        dp[w][is_limited][qianyiwei][qdz]+=dfs(w+1,is_limited&&(i==N[w]),i,qdz&&(i==0));
    }
    return dp[w][is_limited][qianyiwei][qdz];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	 for(int i=0;i<x.size();i++){
	           N[i+1]=x[i]-48;
	       }
	 dqw=x.size();
	 return dfs(1,1,0,1);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
	cout<<solve(r)-solve(l);
}
```

- `qianyiwei` 就是 `last`（上一位数字），`qdz` 是 `started` 的反向标记：`qdz=1` 表示「还在前导零阶段」，`qdz=0` 表示已经开始了。
- `abs(qianyiwei-i)<2 && qdz!=1`：只有已经开始（`qdz!=1`）时才检查相邻差至少 2；前导零阶段不检查。
- `qdz&&(i==0)`：只要一直填 0，`qdz` 就一直为 1（仍未开始）。
- `solve` 里把字符串从高位到低位拷进 `N`（`N[i+1] = x[i]-48`），`dqw = x.size()` 是位数，从 `dfs(1,1,0,1)` 开始。
- 主函数把 `a` 减一，用 `solve(b) - solve(a-1)` 得到区间计数。

### 模块三：例题二 手机号码

> **题意**：统计 11 位手机号码中，**至少出现 3 个相邻相同数字**，且**不能同时出现 4 和 8** 的号码个数。号码无前导零，区间 $[L,R]$ 均为 11 位数。

**状态设计**：

- `pos`：当前位。
- `tight`：是否贴住上界。
- `last`：上一位数字（用于判断连续）。
- `started`：由于固定 11 位，第一位不能是 0，所以 `started` 可省（但代码中仍保留，用于通用）。
- `same`：当前连续相同数字的长度（最多到 3，再大也截断为 3，因为超过 3 仍满足「至少 3」）。
- `has4`、`has8`：是否出现过 4 / 8。

**转移**：枚举数字 `d`，先检查 `tight` 边界。

- 更新 `nsame`：如果 `d == last`，则 `nsame = min(3, same+1)`，否则 `nsame = 1`（通常把第一个数字的 `same` 设为 1）。
- 更新 `has4` 和 `has8`。
- 如果 `has4 && has8` 同时为 true，则该分支直接跳过（不合法）。
- 递归到下一位。

**递归基**：最后一位填完，检查 `same >= 3`（4、8 同时出现已在转移中过滤），满足返回 1，否则 0。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[20][2][20][2][4][4],N[20];
int dqw;
int dfs(int w,int tit,int hyw,int qdz,int mp3,int k84){
    if(dp[w][tit][hyw][qdz][mp3][k84]!=-1) return dp[w][tit][hyw][qdz][mp3][k84];
    if(w==dqw+1){
		if(mp3>=3) return 1;
		else return 0;
	}
    dp[w][tit][hyw][qdz][mp3][k84]=0;
    for(int i=0;i<10;i++){
        if(tit&&i>N[w]) continue;
        int nk84=k84,nmp3=mp3;
        if(i==8) nk84=k84|2;
        if(i==4) nk84=k84|1;
        if(mp3<3){
			if(i==hyw&&!qdz) nmp3=mp3+1;
			else nmp3=1;
		}
        if(nk84==3) continue;
        dp[w][tit][hyw][qdz][mp3][k84]+=dfs(w+1,tit&&(i==N[w]),i,qdz&&(i==0),nmp3,nk84);
    }
    return dp[w][tit][hyw][qdz][mp3][k84];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	for(int i=0;i<(int)x.size();i++){
	    N[i+1]=x[i]-'0';
	}
	dqw=x.size();
	return dfs(1,1,0,1,1,0);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
    int cnt=solve(r)-solve(l);
	cout<<cnt;
}
```

- `k84` 用两个二进制位记录出现过哪些数：`8` 置 `|2`、`4` 置 `|1`，所以 `nk84 == 3` 就代表**同时出现过 4 和 8**，直接 `continue` 剪掉。
- `mp3` 是连续相同的长度，且用 `if(mp3<3)` 截断，最大只记到 3（再大也不用区分）。
- `i==hyw && !qdz`：只有不是前导零（`!qdz`）时才可能与前一位相同、累加连续长度。
- 递归基判断 `mp3>=3`，即出现过至少 3 个相邻相同数字，满足则计 1。

## 复杂度分析

状态数为 `位数 × 2 × 2 × 其他状态数`，每一位枚举 10 个数字，所以单次 `solve` 的复杂度大约是：

$$
O(\text{len} \times \text{状态数} \times 10)
$$

其中 `len` 是上界的位数，通常 $\le 19$（`long long` 范围）。因此数位 DP **非常快，与上界大小无关，只与位数和状态数有关**。

- 时间复杂度：$O(\text{len} \times \text{状态数} \times 10)$。
- 空间复杂度：$O(\text{len} \times \text{状态数})$（记忆化数组）。

## 适用场景

- 统计区间 $[L, R]$ 内满足「**数位层面**限制」的数的个数（相邻差、数位和、是否含某些数字等）。
- 数位上的最值问题（在限制下最大化 / 最小化某个数位相关量）。
- 上界极大（如 $10^{18}$ 甚至大整数）时，暴力枚举不可行、但位数很小，正是数位 DP 的用武之地。

## 常见陷阱与注意事项

1. **前导零**：前导零不算入数字，但长度固定时（如 11 位手机号）前导零就是非法首位，所以可以直接限制第一位从 1~9 枚举，省去 `started`。
2. **0 是否算数**：如果统计区间包含 0，需要单独处理，因为 `solve(0)` 应返回 1（或 0，取决于定义）。通常 `solve(-1)=0`，`solve(0)=1`（若 0 满足条件）。
3. **记忆化的时机**：只在 `!tight` 和 `!started` 时记忆化，否则状态与具体上界绑定，复用率低。
4. **状态维度爆炸**：不要随意加维度，先想清楚是否真的需要。如果某个信息只在递归基中用到，可以用数学计算代替（如数位和）。
5. **源里 windy 代码的写法（照搬未改）**：`dp` 维度里带了 `is_limited` 这一维，也就是说贴界 / 不贴界两种情形分开记忆化，并没有走「只在 `!tight` 时缓存」的教科书优化。因为贴界的路径本身只有一条、状态数很少，这样写依然正确且够快，这里按**原样搬运**，不改成标准写法。
6. **windy 的 0 计数**：递归基对所有合法路径都返回 1，等价于把数字 0 也算作 windy 数；但答案用 `solve(b) - solve(a-1)` 相减时这个多算的 1 会被抵消，所以不影响结果。
7. **区间转前缀的边界**：主函数统一用 `a--` 后 `solve(R) - solve(L-1)`，注意 `L` 为 0 / 1 时的边界。

**最后**：数位 DP 是竞赛中性价比极高的知识点——代码模板固定，思维难度主要在**把题目限制翻译成状态和转移**。只要你能画出状态转移图，剩下的就是套模板。建议先把这两个例题的代码看懂，然后自己动手写一遍，再找几道变式（如「不含 4 且不含 62」「数字和能被 9 整除」等）练手。记住：**数位 DP 的复杂度只与位数和状态数有关，与数字大小无关**，所以遇到 $10^{18}$ 甚至 $10^{100}$（大整数）时，它都是你的好伙伴。$AKB69$, '动态规划', array['数位DP', '记忆化搜索', '按位枚举', '区间转前缀', '前导零', 'windy数', '手机号码'], null, null, 'knowledge'),
('Fohen', 'col-dp-expectation--fenfeng', '期望 DP · Fohen', $AKB70$## 算法原理

期望 DP 是动态规划中与**概率与期望**紧密结合的一类，目标通常是求某个随机过程下的期望值。由于随机过程的每一步都带有不确定性，期望 DP 的状态定义与转移方式和普通确定性 DP 不同，理解它需要先掌握数学期望的基本定义与两条关键性质。

### 数学期望的定义

对于离散型随机变量 $\xi$，其数学期望定义为：

$$
E(\xi) = \sum_{x \in S} P(\xi = x) \times x
$$

也就是把每个可能取值乘上它出现的概率再全部累加，本质上是按概率加权的平均值。

### 两条关键性质

期望 DP 几乎处处依赖下面两条性质。

**线性性**：

$$
E(X + Y) = E(X) + E(Y), \qquad E(kX) = kE(X)
$$

这条性质**不要求 $X$ 与 $Y$ 相互独立**，适用范围极广。很多期望题的正解就是利用线性性，把「总期望」拆成「每一部分的期望」分别计算再求和。

**独立性**：若 $X$ 与 $Y$ 独立，则

$$
E(XY) = E(X) \times E(Y)
$$

需要强调的是，独立性是这条公式成立的前提；例如 $E(X^2) \neq E(X)^2$，因为 $X$ 与自身显然不独立。

## 核心公式 / 状态定义与转移方程

### 状态定义

期望 DP 最常见的状态是「从当前状态到达目标状态所需步数（或得分）的期望」，记作 $dp[i]$，其中 $i$ 表示当前状态。

### 逆推方向

很多期望 DP 题都是**倒着推**的，即从目标状态向起始状态递推，与普通 DP「从起始推向答案」的方向相反。

原因在于：若正推，$dp[i]$ 会依赖还没算出来的 $dp[i+1]$；若逆推，先令目标状态的 $dp$ 值为 $0$，则 $dp[i]$ 只依赖已经算好的后续状态，递推天然成立。

### 后效性与线性方程组

普通 DP 要求满足无后效性，即状态之间不能形成环状依赖。但期望 DP 中环无处不在：例如在无向图上的随机游走，还可能停留在原地。此时不能直接递推，需要**高斯消元**。

以随机游走为例，把同一层（同一行、同一阶段）的所有状态写成线性方程组：

$$
dp[i][j] - \frac{1}{4} dp[i][j-1] - \frac{1}{4} dp[i][j+1] = 1 + \frac{1}{4} dp[i+1][j]
$$

右边是下一层的已知量，左边是同一层的未知量。对每一行建立方程组，用高斯消元解出这一行的所有 $dp$ 值，再向上一层递推。

### 典型模型举例

**连击得分模型（P1365）**：给定由 `o`、`x`、`?` 组成的字符串，`o` 是连击、`x` 断连击、`?` 各有 $50\%$ 概率变成 `o` 或 `x`；连击长度为 $L$ 时贡献 $L^2$ 分。设 $len_i$ 为第 $i$ 步结束时的连击长度期望，$f_i$ 为前 $i$ 步的期望得分，长度从 $len$ 增至 $len+1$ 时的得分增量为 $(len+1)^2 - len^2 = 2len + 1$。

**游走模型（P3232）**：无向图上从点 $1$ 出发，随机等概率选择一条边游走，到达点 $n$ 停止。设 $f_i$ 为点 $i$ 的期望经过次数，$deg_j$ 为点 $j$ 的度数，对 $i \neq n$：

$$
f_i = [i = 1] + \sum_{(i,j) \in E,\, j \neq n} \frac{f_j}{deg_j}
$$

其中 $[i = 1]$ 表示仅当 $i$ 是起点时额外加 $1$（起点多贡献一次）；终点 $n$ 到达后停止，不参与计算。这是 $n-1$ 个未知数的线性方程组，用高斯消元求解。求出 $f$ 后，边 $(u,v)$ 的期望经过次数为：

$$
g_{u,v} = [u \neq n]\frac{f_u}{deg_u} + [v \neq n]\frac{f_v}{deg_v}
$$

## 逐行代码解析

本节给出期望 DP 的几类典型处理流程的伪代码，便于理解思想，不要求与任何可运行程序一致。

### 逆推型：从目标状态出发

```
令目标状态的 dp = 0
从目标状态向前枚举状态 i（倒序）:
    枚举状态 i 的所有可能转移:
        dp[i] += 概率 * (代价 + dp[后继状态])
```

以「从状态 $i$ 到达目标所需步数的期望」为例，逆推保证了 $dp[后继状态]$ 已经被算出。

### 带随机分支型：对每个分支取平均

以 P1365 的连击得分期望为例，三种字符的转移如下：

```cpp
// 'o'（连击）:
//   f[i] = f[i-1] + 2 * len[i-1] + 1;      len[i] = len[i-1] + 1
// 'x'（断连击）:
//   f[i] = f[i-1];                          len[i] = 0
// '?'（各有 50% 概率）:
//   f[i] = f[i-1] + (2 * len[i-1] + 1) / 2.0;
//   len[i] = (len[i-1] + 1) / 2.0;
```

`?` 分支的本质是对 `o` 与 `x` 两种结果取平均，正确性由期望的线性性保证。注意 $len$ 也要取平均后的值，不能只按某一边计算。

### 后效型：高斯消元

```
把同一层（或同一行）的所有未知 dp 写成线性方程组:
    左端 = 本层未知量（含自转移系数）
    右端 = 已知层贡献 + 常数项
对每一层做高斯消元，解出该层所有 dp
再向上一层递推
```

## 复杂度分析

期望 DP 没有统一的复杂度，取决于转移结构：

| 类型 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 无后效的逆推/正推型 | 状态数 $\times$ 单状态转移数，线性一维通常 $O(n)$ | $O(n)$ |
| 带随机分支型（如 osu!） | $O(n)$ | $O(n)$ 或 $O(1)$ |
| 带环的后效型（高斯消元） | 每层 $O(m^3)$，共 $n$ 层为 $O(n m^3)$ | 系数矩阵 $O(m^2)$ |

由于具体开销随题目模型差异较大，本知识点在 frontmatter 中以「视具体实现」标注。

## 适用场景

- 求随机过程到达某状态的**期望步数**（如随机游走、期望移动次数）。
- 求随机过程的**期望得分 / 期望收益**（如连击得分、期望消耗）。
- 状态转移带环、存在后效性的随机问题，配合高斯消元求解。
- 与概率 DP、状压 DP 结合的综合题（例如状态集合较小、需要同时考虑概率与期望的场景）。

## 常见陷阱与注意事项

1. **正推还是逆推要判断清楚**：若状态依赖「未来」状态，正推会依赖未算出的值，应改为逆推。
2. **线性性不要求独立**：把总期望拆成部分期望再求和是合法的，这是很多题的关键。
3. **独立性与平方期望**：$E(XY) = E(X)E(Y)$ 只在独立时成立，因此 $E(X^2) \neq E(X)^2$。
4. **后效性不能直接 DP**：状态之间有环时，普通递推会出错或死循环，应改为高斯消元解线性方程组。
5. **平均要作用于所有相关量**：处理概率分支时，不只答案取平均，中间量（如连击长度）也要取平均后的值。
6. **高斯消元的层划分**：把「本层未知量」与「已知层贡献」分到等号两侧，才能正确建方程。

## 对比与扩展

| 对象 | 特点 |
|---|---|
| 普通线性 DP | 状态确定性转移，无后效，正向或逆向都可递推 |
| 期望 DP | 状态带概率，常需逆推；有环时配合高斯消元 |
| 概率 DP | 求「概率」而非「期望」，思想相近、常与期望 DP 一起出现 |

扩展方向：

- 期望的线性性可推广到更复杂的目标：把总期望拆成多个可独立计算的部分再求和。
- 随机游走类问题可结合图的度数、高斯消元等技巧。
- 与状压 DP 结合时，先压缩状态，再按期望的逆推方式转移。$AKB70$, '动态规划', array['动态规划', '期望DP', '概率', '高斯消元', '随机游走'], null, null, 'knowledge'),
('Xesir', 'col-dp-expectation--xesir', '期望 DP · Xesir', $AKB71$## 算法原理

> 期望天堂没有期望

期望 DP，顾名思义就是关于期望的 DP。~~？~~

这一类 DP 通常与概率高度挂钩，因此受到概率一些性质的影响，通常也并不是很直观，有一定思维难度。故将此板块从线性 DP 独立出来单独讲解。~~被肘哭力~~

### 期望定义

离散型随机变量 $\xi$ 的数学期望定义为：

$$
E(\xi) = \sum_{x \in S} P(\xi = x) \times x
$$

也就是**每个可能值乘以它出现的概率，再全部加起来**，可以视作加权平均值。

期望有两个重要性质。

**线性性**：期望的和等于和的期望。

$$
E(X + Y) = E(X) + E(Y) \qquad E(kX) = kE(X)
$$

这条性质**不要求 $X$ 和 $Y$ 独立**，适用范围极广。很多期望题的正解就是利用线性性，把「总期望」拆成「每一部分的期望」分别计算，再求和。期望 DP 这个东西能够成立，也是由于这条性质。~~不然你拿啥递推~~

**独立性**：如果 $X$ 和 $Y$ 独立，则 $E(XY) = E(X) \times E(Y)$。

~~因为有独立性这个前提，所以 $E(X^2) \neq E(X) \times E(X)$ 哦~~

期望 DP 几乎处处用到这两个性质。

### 逆推

你会发现很多期望 DP 题都是**倒着推**的，即从目标答案状态推向起始状态，和其他 DP 从起始推向答案完全相反，这是理解期望 DP 逻辑的一大难点。

一般期望 DP 中设 $dp[i]$ 表示「从状态 $i$ 到达目标状态所需步数的期望」。如果你正推，$dp[i]$ 依赖于 $dp[i+1]$，但 $dp[i+1]$ 还没算出来。如果你逆推，先算 $dp[目标] = 0$，然后 $dp[i]$ 只依赖于已经算好的 $dp[i+1]$，天然成立。

### 后效性

~~！？QQ？！~~

我们知道，一般 DP 是不允许有环状依赖的，即需满足无后效性。但是期望 DP 不一样。比如随机游走中，一般是无向图，环无处不在，甚至还要计算停在原地的期望，这显然具有后效性。

是不是意味着 DP 不能做了呢？当然不是！

**处理方法：高斯消元。**

观察到一般两边转移的系数是不同的，我们可以把位置状态都当做未知数考虑。所以把同一层（同一行、同一阶段）的所有状态写成线性方程组（以游走为例）：

$$
dp[i][j] - \frac{1}{4}dp[i][j-1] - \frac{1}{4}dp[i][j+1] = 1 + \frac{1}{4}dp[i+1][j]
$$

右边是下一层的已知量，左边是同一层的未知量。对每一行建一个方程组，用高斯消元解出这一行的所有 $dp$ 值，然后往上递推即可。

## 核心公式 / 状态定义与转移方程

**状态定义**：期望 DP 最常见的状态是「从当前状态到达目标状态所需步数（或得分）的期望」，记作 $dp[i]$。

**逆推方向**：对于无后效的模型，令目标状态 $dp = 0$，从后往前递推，保证 $dp[i]$ 只依赖已经算好的后继状态。

**后效性模型**：当状态之间存在环，把同一层（同一行、同一阶段）的所有未知 $dp$ 写成线性方程组，用高斯消元解出后，再向上一层递推。

典型模型：

**连击得分模型（P1365）**：设第 $i$ 步的连击长度为 $len_i$、期望得分为 $f_i$，则连击（`o`）时分数增量为 $2 len_{i-1} + 1$；`?` 的情况对两种结果取平均即可，正确性由期望的线性性保证。

**游走模型（P3232）**：无向图上从 1 出发随机等概率选一条边游走，走到 $n$ 停止。设 $f_i$ 表示点 $i$ 的期望经过次数，对 $i \neq n$：

$$
f_i = [i = 1] + \sum_{(i,j) \in E,\, j \neq n} \frac{f_j}{deg_j}
$$

含义是：从 $j$ 出发，以 $1/deg_j$ 的概率走到 $i$。$[i=1]$ 是因为起点额外贡献一次。到 $f$ 求出后，边 $(u,v)$ 的期望经过次数为：

$$
g_{u,v} = [u \neq n]\frac{f_u}{deg_u} + [v \neq n]\frac{f_v}{deg_v}
$$

## 逐行代码解析

本节给出期望 DP 几类典型处理流程的伪代码，便于理解思想，不要求与某个可运行程序一致。

### 逆推型：从目标状态出发

```cpp
令目标状态的 dp = 0
从目标状态向前枚举状态 i（倒序）:
    枚举状态 i 的所有可能转移:
        dp[i] += 概率 * (代价 + dp[后继状态])
```

以「从状态 $i$ 到达目标所需步数的期望」为例，逆推保证了 `dp[后继状态]` 已经被算出。

### 带随机分支型：对每个分支取平均

以 P1365 的连击得分期望为例，设第 $i$ 步有 $len_i$ 次连击，$f_i$ 表示期望得分，则三种字符的转移如下：

```cpp
// 'o'（连击）:
//   f[i] = f[i-1] + 2 * len[i-1] + 1;      len[i] = len[i-1] + 1
// 'x'（断连击）:
//   f[i] = f[i-1];                          len[i] = 0
// '?'（各有 50% 概率）:
//   f[i] = f[i-1] + (2 * len[i-1] + 1) / 2.0;
//   len[i] = (len[i-1] + 1) / 2.0;
```

`?` 分支的本质是对 `o` 与 `x` 两种结果取平均，正确性由期望的线性性保证。注意过程中的 $len$ 也要取平均后的值，不能只看一边。

### 后效型：高斯消元

```cpp
把同一层（或同一行）的所有未知 dp 写成线性方程组:
    左端 = 本层未知量（含自转移系数）
    右端 = 已知层贡献 + 常数项
对每一层做高斯消元，解出该层所有 dp
再向上一层递推
```

## 复杂度分析

期望 DP 没有统一的复杂度，取决于转移结构：

| 类型 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 无后效的逆推 / 正推型 | 状态数 $\times$ 单状态转移数，线性一维通常 $O(n)$ | $O(n)$ |
| 带随机分支型（如 osu!） | $O(n)$ | $O(n)$ 或 $O(1)$ |
| 带环的后效型（高斯消元） | 每层 $O(m^3)$，共 $n$ 层为 $O(n m^3)$ | 系数矩阵 $O(m^2)$ |

由于具体开销随题目模型差异较大，本知识点在 frontmatter 中以「视具体实现」标注。

## 适用场景

- 求随机过程到达某状态的**期望步数**（如随机游走、期望移动次数）。
- 求随机过程的**期望得分 / 期望收益**（如连击得分、期望消耗）。
- 状态转移带环、存在后效性的随机问题，配合高斯消元求解。
- 与概率 DP、状压 DP 结合的综合题。

## 常见陷阱与注意事项

1. **正推还是逆推要判断清楚**：若状态依赖「未来」状态，正推会依赖未算出的值，应改为逆推。
2. **线性性不要求独立**：把总期望拆成部分期望再求和是合法的，这是很多题的关键。
3. **独立性与平方期望**：$E(XY) = E(X)E(Y)$ 只在独立时成立，因此 $E(X^2) \neq E(X)^2$。
4. **后效性不能直接 DP**：状态之间有环时，普通递推会出错或死循环，应改为高斯消元解线性方程组。
5. **平均要作用于所有相关量**：处理概率分支时，不只答案取平均，中间量（如连击长度 $len$）也要取平均后的值。
6. **高斯消元的层划分**：把「本层未知量」与「已知层贡献」分到等号两侧，才能正确建方程。

## 题目

**P1365 WJMZBMR 打 osu! / Easy**

> 给定一个由 `o`、`x`、`?` 组成的字符串，`o` 是连击，`x` 断连击，`?` 各有 50% 概率变成 `o` 或 `x`。连击长度为 $L$ 时贡献 $L^2$ 分，求总期望得分。

这个题是期望 DP 最简单的一类模型。我们很容易想到，设第 $i$ 步有 $len_i$ 次连击，$f_i$ 表示期望得分。则连击（`o`）情况下分数贡献 $2 len_{i-1}+1$，否则不贡献 $f_i$ 且将 $len_i$ 设为 $0$。那 50% 的情况怎么处理呢？很简单，两种取平均即可，正确性由期望的线性性决定。需要注意的是，过程中 $len$ 也是取平均情况，不能只看一边。

**P2473 奖励关**

~~gun 去看有趣の小题目~~

**P3232 游走**

> 无向图上从 1 出发随机等概率选择任意一边游走，走到 $n$ 停止。每条边有权重（编号），给边重新编号使总得分期望最小。

~~请输入文本~~

首先我们可以贪心地为期望经过次数更多的边分配更小的边权，所以只需要求出所有边经过期望并排序即可。设 $f_i$ 表示点 $i$ 的期望经过次数，对于 $i \neq n$，有 $f_i = [i = 1] + \sum_{(i,j) \in E,\, j \neq n} \frac{f_j}{deg_j}$：从 $j$ 出发，以 $1/deg_j$ 的概率走到 $i$，$[i=1]$ 是因为起点额外贡献一次。注意点 $n$ 是终点，到达后停止，所以 $f_n$ 不参与计算。

这是 $n-1$ 个未知数的线性方程组，**高斯消元求解**。得到 $f$ 后，边 $(u,v)$ 的期望经过次数为 $g_{u,v} = [u \neq n]\frac{f_u}{deg_u} + [v \neq n]\frac{f_v}{deg_v}$，排序 $g$，期望次数最大的边给最小号，累加即可。$AKB71$, '动态规划', array['动态规划', '期望DP', '概率', '高斯消元', '随机游走'], null, null, 'knowledge'),
('Xesir', 'col-dp-formula-method--xesir', 'DP 公式化打法 · 通用解题流程 · Xesir', $AKB72$## 算法原理

上面已经讲了很多知识点和例题，但考场上 DP 考的很活，让你完全摸不着头脑，原地吓哭 ~~这才是世界上最绝望的WA法~~。

因此真正重要的是**拿到一道 DP 题之后，脑子该怎么转**。你会遇到各种长得不一样的题，但背后的套路其实就那几招。这里把几位神犇老师的精华和考场经验揉在一起，给你一份「DP 解题通用流程图」，保证比赛 $RP++$ ~~套公式做题就是快~~。

### 第一步：这题该不该用 DP？

不是所有题都要 DP。先问自己三个问题：

1. **问题能不能被拆成若干阶段？**
   阶段可以是序列下标、树的深度、背包容量、时间、位数……总之要有一个明确的「处理到第几步」的维度。
2. **最优解的子结构是否成立？**
   即全局最优解中，子问题的解也一定是最优的。如果不成立，那可能是贪心或搜索的事。
3. **状态之间有没有环？**
   如果依赖关系无环，就能按拓扑序算；如果有环且无法通过方程转换，一般不能 DP。

如果以上都满足，那 DP 大概率可行。如果感觉可以暴力枚举所有情况，但爆搜会 T，那 DP 往往是正解。

## 核心公式 / 状态定义与转移方程

### 第二步：设计状态

**状态的本质**：把完整的历史压缩成「足以决定未来」的信息。换句话说，我们只关心那些**以后还会用到**的过去细节，其他都扔掉。

设计状态时，反复问自己：

- 未来做决策时，需要知道哪些已处理的信息？
- 如果我不知道某个信息，两个不同的历史会不会导致不同的合法后继？
- 如果需要，就把它加进状态；如果不需要，就别加。

常见的信息类型：

- **位置**：`i` 表示处理到第 i 个元素（线性 DP）。
- **容量**：`j` 表示背包剩余或已用容量（背包 DP）。
- **区间端点**：`[l, r]` 表示正在处理的连续区间（区间 DP）。
- **末尾值**：LIS 中保留结尾数字，因为后续能否接上只取决于它。
- **集合**：用二进制 mask 表示哪些元素已被选（状压 DP）。
- **深度 / 层数**：记忆化搜索中的搜索深度。
- **与边界的交互**：树形 DP 中，子树向父节点提供什么（大小、最值、路径状态等）。

**状态维度的取舍**：维数越多，复杂度越高。先保证正确，再考虑优化，能少一维就少一维。

### 第三步：转移方程

状态定义好了，转移怎么来？最稳的方法是**从最后一次决策倒推**。

想象你已经得到了状态 `dp[S]`，问自己：**这个状态对应的最优方案，它的最后一步可能是什么？**

将所有可能的最后一步分成互不重叠的几类，每一类都对应一个前驱状态，然后：

```cpp
dp[当前] = best_{所有前驱，( dp[前驱] + 本次新增代价 )}
```

这个公式里：

- `best` 可以是 `max`、`min`、`sum`（计数）、`or`（可行性）等。
- `新增代价` 是从前驱到当前的额外花费，有时为 0。

**关键点**：

- 分类一定要**不重不漏**，否则会漏解或重复计数。
- 每个合法方案必然有唯一的最后一步，所以一定被枚举到。
- 每个转移也一定拼出一个合法方案，所以不会多算。

如果你发现某类方案无法用状态表示，那可能是状态定义少了一个维度，回头补充。

## 逐行代码解析

本篇是方法论总结，没有对应的 `.cpp`。下面把「七步流程」当成一组按序执行的步骤来解析，每一步都可以理解成伪代码里的一行。

### 第四步：初始化 —— 给状态一个「起点」

初值决定了 DP 从哪些「空」状态开始。

- **求最值**：通常把不可达状态设为 `+∞`（最小值）或 `-∞`（最大值），只把真正的起点赋为 0 或对应值。
- **求方案数**：起点 `dp[0] = 1`，其余为 0。
- **求可行性**：起点 `true`，其余 `false`。

特别要注意边界问题（如背包 DP 中「恰好」与「至多」的区别）。数位 DP 中，前导零的处理也属于初始化的一种变体，要单独考虑数字 0 是否合法。

### 第五步：确定计算顺序 —— 按拓扑序来

状态之间的依赖关系构成一张有向无环图（DAG）。我们要按拓扑序计算，保证依赖的前驱已经算完。

常见的顺序：

- **序列 DP**：按位置从左到右（或从右到左）。
- **区间 DP**：按区间长度从小到大（长区间依赖短区间）。
- **树形 DP**：DFS 后序遍历（儿子先算完再算父亲）。
- **状压 DP**：按 mask 从小到大（子集的 mask 数值更小），或者按 popcount 从小到大。
- **数位 DP**：用记忆化搜索自动处理依赖（递归天然形成 DAG）。

如果依赖关系存在环，那就不是普通 DP 了，可能是最短路或高斯消元。

### 第六步：检查正确性

写完转移后，心里模拟一个简单数据，看状态是否会更新、边界是否处理、最终答案是否取对。最好自己手跑一遍 DP 来检查问题。

### 第七步：优化

「暴力 DP」往往是 $O(n^2)$ 或 $O(n^3)$，但数据范围可能让你必须优化。优化的前提是**转移方程已经正确**，否则优化只会放大错误。

优化的常见方向：

1. **空间优化**：滚动数组（只保留最近几层）。
2. **时间优化**：
   - 前缀和 / 后缀和优化（转移是一段求和）。
   - 单调队列优化（窗口最值）。
   - 斜率优化（决策贡献写成直线）。
   - 决策单调性分治 / 四边形不等式。
   - 数据结构优化（线段树、树状数组维护候选值）。
3. **状态压缩**：把某些维度压成二进制（状压 DP）。
4. **维度转置**：交换两维，让较小的一维进入复杂度指数（如背包价值与重量互换）。
5. **Meet-in-the-Middle**：折半枚举，组合状态。

**考场经验**：先写一个能过的暴力 DP（至少能过小样例），再根据数据范围判断需要哪种优化。如果时间紧，甚至可以交暴力拿部分分。

### 实战 Checklist

1. **看数据范围** → 推测维度与复杂度。
2. **定义阶段** → 处理到哪个位置 / 哪个状态。
3. **提炼关键信息** → 未来决策需要什么。
4. **写出状态表示** → 包括含义与下标。
5. **最后一步分类** → 写出转移方程。
6. **初始化与答案位置** → 确保起点正确。
7. **验证样例** → 手算或模拟。
8. **考虑优化** → 空间 / 时间。

## 复杂度分析

### xD-yD 模型 —— 帮你快速估计复杂度

这个模型来自 $yyyyxh$ 老师的课件 ~~吓哭了清华神犇~~，非常实用：

- **x 维数组**：表示状态数组的维度数。
- **y 维转移**：表示枚举转移的循环层数（不包括预处理）。

这样 DP 的空间复杂度为 $O(n^x)$，时间复杂度为 $O(n^{x+y})$。

例如：

- **1D-0D**：递推式 `f[i] = f[i-1] + ...`，只有一维状态，转移 $O(1)$。如斐波那契、前缀和。
- **1D-1D**：一维状态，转移需要枚举一个前驱，$O(n)$ 转移，总 $O(n^2)$。如 LIS 的 $O(n^2)$ 解法。
- **2D-0D**：二维状态，转移 $O(1)$，如 LCS 的 $O(nm)$（每个状态常数转移）。
- **2D-1D**：二维状态，转移需枚举一维，$O(n^3)$。典型的就是区间 DP，如石子合并。
- **3D-1D** 等：多维状态，转移枚举一层。

**用途**：

- 看到一道题，先尝试把它套进某个 xD-yD 的框架，能帮你快速确定状态数和复杂度。
- 如果 xD-yD 的朴素复杂度已经接近题目限制（如 n=500 时 $O(n^3)$ 可能过不了），你就知道需要优化（如四边形不等式）或重新设计状态。

**注意**：这不是死板分类，只是思考工具。有些复杂 DP 状态维度不固定（如树形背包），或状态是集合（状压），但思路一致。

## 适用场景

### 各类 DP 的典型状态设计思路（不展开，仅点一下）

- **线性 DP**：按序列位置推进，保留末尾信息（如 LIS 的结尾值、编辑距离的当前匹配位置）。
- **背包 DP**：容量维度，决策选与不选。
- **区间 DP**：`[l, r]` 区间，最后合并或处理端点。
- **树形 DP**：子树汇总，向父节点传递接口信息（大小、选点数、路径状态）。
- **状压 DP**：用 mask 表示集合，枚举子集或元素。
- **数位 DP**：高位到低位，`tight` 和 `started` 控制边界。
- **计数 DP**：注意去重，常用插入顺序或容斥。

## 常见陷阱与注意事项

第六步检查时最容易踩的坑：

- 漏了不选的情况（如 01 背包忘记继承 `dp[j]`）。
- 转移时使用了当前层已更新的值，导致重复选取（完全背包正序，01 倒序）。
- 数组越界或初始化遗漏。
- 答案位置不对（如 LIS 答案是 `max f[i]`，不是 `f[n]`）。

此外，设计状态时「能少一维就少一维」，但**该加的维度必须加**：如果某个历史信息会影响未来的合法后继，漏掉它就会出错，哪怕复杂度更好也没用。

## 最后的碎碎念

DP 是 OI 里最灵活的工具，没有之一。它不像数据结构有固定模板，更像是一种思维方式。

当你遇到一道新题时，不要急着去套「这是 XX 背包还是 XX 区间」，先回到最本质的问题：

**我需要维护哪些信息，才能满足决策需要？**

想清楚这个，状态就出来了；然后根据最后一步分类，转移就出来了；再检查一下无后效性，初始化，答案位置——这就拿到了 DP 解。优化是锦上添花，正确才是雪中送炭。

现在，把这套流程刻进脑子里，下次见到 DP 题，先走一遍 Checklist，你会发现那些花里胡哨的题目，其实内核都是这几个步骤。$AKB72$, '动态规划', array['动态规划', '方法论', '解题流程', '状态设计', '转移方程', 'xD-yD'], null, null, 'knowledge'),
('Xesir', 'col-dp-grid-number-pick--xesir', '方格取数 · Xesir', $AKB73$## 算法原理

有一个 $n \times n$ 的方格，某些格子有数字（正整数），从左上角走到右下角，每次只能向右或向下走，求路径上数字之和的最大值。（有些版本会走两次，但这里是基础版。）

**状态设计**：最经典的是用二维 `f[i][j]` 表示从 `(1,1)` 走到 `(i,j)` 的最大和。转移：

$$f[i][j] = val[i][j] + \max(f[i-1][j],\ f[i][j-1])$$

最终答案就是 `f[n][n]`。

**进阶**：如果题目要求走两次（如 NOIP 2000 方格取数）或其他变体，需要更多维度的 DP 及优化；基础版就是上面这个。

> **注**：下面这份代码被作者**人为下毒**了，直接提交会 WA，请根据理解独自编写 ~~别想抄袭~~。

## 核心公式 / 状态定义与转移方程

状态定义：

$$f[i][j] = \text{从 } (1,1) \text{ 走到 } (i,j) \text{ 的最大数字和}$$

正确转移（供理解，代码里并没有写对）：

$$f[i][j] = a[i][j] + \max(f[i-1][j],\ f[i][j-1])$$

边界 `f[1][1] = a[1][1]`，最终答案 $f[n][n]$。

## 逐行代码解析

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
int dp[1010][1010],a[1010][1010];
```

- `a` 存格子权值，`dp` 本意是存「走到每个格子的最大和」。

### 读入 n 与坐标点

```cpp
int main() {
   //int t;cin>>t;
   //while(t--){
           int n;cin>>n;
           int x,y,c;
           while(cin>>x>>y>>c&&x&&y&&c){
               a[x][y]=c;
           }
```

- 读入方格边长 `n`。
- 之后循环读 `x y c`，把权值 `c` 填到 `a[x][y]`，读到 `0 0 0` 时停（`x&&y&&c` 为假）。
- `//int t;cin>>t;` 与 `//while(t--){` 是多组数据版本的残留注释，此处已被注释掉。

### DP 主循环（下毒点，别照抄）

```cpp
        for(int i=1;i<=n;i++){
            for(int j=1;j<=n;j++){
                 dp[i][j][k][u]=max(dp[i-1][j]，dp[i][j-1]);
                 dp[i][j]+=a[i][j];              
            }
        }
```

- 循环枚举每个格子 `(i,j)`，本意是让 `dp[i][j]` 从上方、左方取大再加当前格子。
- 但 `dp[i][j][k][u]` 把二维数组 `dp` 当四维来写，`k`、`u` 又根本没定义；逗号还是全角 `，`。
- 紧接着的 `dp[i][j]+=a[i][j]` 里，`dp[i][j]` 并没有拿到转移结果，于是整张表退化，答案全错。

### 输出与返回

```cpp
        cout<<dp[n][n];
   //}
    return 0;
}
```

- 输出右下角 `dp[n][n]`，`//}` 同样是多组数据写法的残留注释。

## 复杂度分析

- **时间复杂度**：$O(n^2)$，双重循环遍历每个格子。
- **空间复杂度**：$O(n^2)$，`a` 与 `dp` 两张表。若采用滚动数组，可压到 $O(n)$。

## 适用场景

「只能向右或向下」的方格类路径最值问题。基础版是二维路径 DP 的入门（与数字三角形同源）；若要「走两次」，需升到三维/四维状态并处理交点去重。

## 常见陷阱与注意事项

1. **此代码为演示用、不可直接提交**：作者明确写了「被我人为下毒了」。请勿直接复制到 OJ ~~别想抄袭~~。
2. **下毒点一：数组维度写错**：`dp[i][j][k][u]` 在二维数组上写了四维下标，`k`、`u` 未声明，编译器直接报错。
3. **下毒点二：全角逗号**：`max(dp[i-1][j]，dp[i][j-1])` 里的 `，` 是全角字符，不是合法的 C++ 逗号，同样编不过。
4. **下毒点三：结果没回填**：即使把上面两处勉强改到能编译，这一行也没有把 `max(...)` 的结果写回 `dp[i][j]`；随后的 `dp[i][j]+=a[i][j]` 在一个空值上加，`dp` 会退化成「单格权值」，求出来不是最大路径和 → WA。理解正确的转移方程后请自己重写实现。
5. **读入终止条件**：`while(...&&x&&y&&c)` 依赖坐标与权值都非零来结束输入；若权值允许为 0，这个写法会提前退出。

## 对比与扩展

与数字三角形同属「只能往右下走」的路径 DP，区别在于正方形的转移来自「上一个格子（上/左）」，而三角形来自「下一行（下/右下）」。

进阶的方格取数（NOIP 2000）要走两次，状态需同时记录两条路径的位置（可用 $x_1 + y_1 = x_2 + y_2$ 这条不变量把维度降一维），并在两路径走到同一格时只加一次权值。$AKB73$, '动态规划', array['动态规划', '线性DP', '方格取数', '路径DP', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('Fohen', 'col-dp-grid-state--fenfeng', '棋盘状压 DP · Fohen', $AKB74$## 算法原理

棋盘状压 DP 是「行状压 DP」的一种：把棋盘每一行的摆放情况压成一个二进制数，一位代表一个格子（1 表示放、0 表示不放），再沿行做动态规划。它适用于「行内状态可以用二进制表示、行与行之间只通过相邻的若干行相互约束」的棋盘类问题。

以炮兵阵地（洛谷 P2704）为例：在 $N \times M$ 的网格上布置炮兵，每门炮兵的攻击范围是上下左右各两格，任意两门炮兵不能互相攻击，且只能放在平原（P）上，求最多能放多少门。

这个问题的关键在于「攻击距离更远」：像「互不侵犯」这类题只需相邻两行不冲突，而炮兵的射程跨两格，因此第 $i$ 行是否合法不仅取决于第 $i-1$ 行，还取决于第 $i-2$ 行。于是状态必须同时记录「当前行」与「上一行」两行，形成三维状态 $dp[i][cur][pre]$。

由于 $M \le 10$，每行至多用一个 10 位二进制数表示；再预处理出每行「内部合法（不存在相距小于 3 的两门炮）」且「不与山地冲突」的状态集合，转移时只枚举这些合法状态，就能把指数级的状态枚举压缩到很小的范围。

## 核心公式 / 状态定义与转移方程

记 $V(i)$ 为第 $i$ 行的合法状态集合：行内不存在相距小于 3 的两个 1，且不与山地冲突。

### 状态定义

$$dp[i][cur][pre]$$

表示前 $i$ 行中、第 $i$ 行状态为 $cur$、第 $i-1$ 行状态为 $pre$ 时能放的最多炮兵数。

### 行内合法状态

每一行内部不能存在相距小于 3 的两门炮（任意两个 1 之间至少隔两个 0），等价于：

```text
(state & (state << 1)) == 0   且   (state & (state << 2)) == 0
```

### 山地约束

状态必须落在平原上，不能压到山地（H 格）：

```text
state & mountain[i] == 0
```

### 转移方程

枚举第 $i-2$ 行的合法状态 $prepre$，若三行两两互不冲突，则用「上一行的值 + 当前行新增炮兵数」更新：

$$dp[i][cur][pre] = \max_{prepre \in V(i-2)} \Big( dp[i-1][pre][prepre] + \mathrm{popcount}(cur) \Big)$$

其中枚举的 $prepre$ 还需满足 `cur & pre == 0`、`cur & prepre == 0`、`pre & prepre == 0`，$\mathrm{popcount}(cur)$ 是状态 $cur$ 中 1 的个数，即本行新增的炮兵数。

### 最终答案

$$\mathrm{answer} = \max_{cur \in V(n),\, pre \in V(n-1)} dp[n][cur][pre]$$

## 逐行代码解析

### 头文件与全局数组

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
//const int N=1e5+10;
//int cnt=0;
//int a[N];
int mp[110];
int dp[3][1<<11][1<<11];
int ndp[110][1<<11];
vector<int> pas[110];
inline int read();
inline void write(int x);
int popcount(int x){
    return __builtin_popcount(x);
}
```

- 万能头加快读快写模板的宏；`#define int long long` 把整型统一成 64 位，配合 `signed main()` 使用，避免答案溢出。
- `mp[i]` 记录第 $i$ 行的山地掩码（H 格对应位为 1）；`pas[i]` 存第 $i$ 行的全部合法状态。
- `dp[3][1<<11][1<<11]` 是滚动数组，3 层轮流表示第 $i$、$i-1$、$i-2$ 三行；`popcount` 用 GCC 内置的 `__builtin_popcount` 统计 1 的个数。
- `ndp`、`read`、`write` 是模板残留，本算法并未使用它们。

### 读入地图并预处理合法状态

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    
    int n,m;cin>>n>>m;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            char c;cin>>c;
            if(c=='H') mp[i]|=(1<<(m-j));
        }
    }
    for(int i=1;i<=n;i++){
        for(int j=0;j<(1<<m);j++){
                //cout<<dp[i][j]<<' ';
                //if(i!=1) dp[i][j]=LLONG_MIN;
            if((((j<<2)&j)>0)||(((j<<1)&j)>0)||(((j>>2)&j)>0)||(((j>>1)&j)>0)) continue;
            if(j&mp[i]) continue;
            pas[i].push_back(j);
        }
           //cout<<endl;
    }
    pas[0].push_back(0);
```

- 读入 $n$、$m$ 后，把每行的 H 格压进 `mp[i]`：第 $j$ 列对应第 `m-j` 位，位序与后续状态定义保持一致。
- 枚举 $0 \sim 2^m-1$ 的所有状态，`(j<<1)&j`、`(j<<2)&j` 非 0 说明存在相距小于 3 的两个 1，直接跳过（`>>` 方向是等价的冗余判断）。
- 再用 `j & mp[i]` 排除压到山地的状态，剩下的就是本行的合法状态，存入 `pas[i]`。
- `pas[0].push_back(0)` 让「第 0 行为空」成为合法状态，作为第 1 行的上一行、以及 `n=1` 时枚举 `pas[n-1]` 的兜底。

### 初始化 dp 数组与第一行

```cpp
    for(int i=0;i<=2;i++){
        for(int j=0;j<(1<<m);j++){
            for(int u=0;u<(1<<m);u++){
                dp[i][j][u]=LLONG_MIN;
            }
        }
    }
    for(int j:pas[1]){
        dp[1][j][0]=popcount(j);
    }
```

- 先把 3 层滚动数组整体置为 `LLONG_MIN`，表示「不可达」。
- 第 1 行没有上一行，只需与「空上一行」（状态 0）相容，因此 `dp[1][j][0] = popcount(j)`。

### 三行约束的状态转移

```cpp
    for(int i=2;i<=n;i++){
        for(int j:pas[i]){
            for(int u:pas[i-1]){
                if(u&j) continue;
                for(int o:pas[max(i-2,0ll)]){
                    if(o&u) continue;
                    if(o&j) continue;
                    
                    dp[i%3][j][u]=max(dp[i%3][j][u],dp[(i-1)%3][u][o]+popcount(j));
                }
                
            }
        }
    }
```

- 第 $i$ 行从第 $i-1$、$i-2$ 行转移：`j` 是当前行、`u` 是上一行、`o` 是上上行，三层都从各自行的合法状态集里取。
- `u&j`、`o&u`、`o&j` 三处 `continue` 保证三行两两不冲突。
- `max(i-2,0ll)` 处理 $i=2$ 时上上行为第 0 行（只有空状态 0）。
- 用 `dp[i%3][j][u] = max(..., dp[(i-1)%3][u][o] + popcount(j))` 完成滚动更新，把上一行的最优值加上当前行的炮兵数。

### 统计答案并输出

```cpp
    
    int cnt=0;
    for(int j:pas[n]){
        for(int k:pas[n-1]){
            cnt=max(cnt,dp[n%3][j][k]);
        }
    }
       cout<<cnt<<endl;
    
    
    return 0;
}
```

- 最后枚举末两行的全部组合（`pas[n]` 与 `pas[n-1]`），取最大值。
- `dp[n%3][j][k]` 就是前 $n$ 行、末两行为 $(j,k)$ 时的最优值。
- 输出 `cnt` 即为最多能放的炮兵数。

### 快读快写辅助函数

```cpp
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `read` 用 `getchar` 逐字符读入并累加，`write` 递归输出，是竞赛常用的快读快写模板。
- 本程序通过 `cin/cout`（已关闭同步）完成输入输出，这两个函数未参与本次算法流程。

## 复杂度分析

- **时间复杂度**：$O(N \cdot S^3)$
  - 预处理每行枚举 $2^M$ 个状态：$O(N \cdot 2^M)$
  - 转移共 $N$ 行，每行三重循环分别枚举 `pas[i]`、`pas[i-1]`、`pas[i-2]`，每层至多 $S$ 个合法状态：$O(N \cdot S^3)$
  - $S$ 是「行内不存在相距小于 3 的两个 1」的状态数，$M=10$ 时 $S=60$；$N \le 100$ 时约为 $100 \times 60^3 \approx 2.2 \times 10^7$，非常快

- **空间复杂度**：$O(S^2)$
  - 滚动数组只保留 3 层，每层存 `(cur, pre)` 两维：$O(3 \cdot S^2)=O(S^2)$
  - 实现里 `dp` 直接按 $2^M \times 2^M$ 开满、元素是 `long long`，$M=10$ 时约 $96$ MB；若把合法状态编号压缩，可降到真正的 $O(S^2)$ 内存

## 适用场景

1. **棋盘/网格上的「放置」类问题**：每格只有放/不放两种状态，单行可以用一个二进制数表示。
2. **行与行之间只依赖相邻的常数行**：炮兵的攻击跨两格，故状态要记当前行与上一行两维；依赖越多，状态维数越高。
3. **列数很小、行数可以很大**：$M \le 10$ 使 $2^M$ 可枚举，而 $N$ 只出现在外层循环里，不影响状态维度。
4. **典型题目**：炮兵阵地（P2704）、互不侵犯（P1896）、玉米田（Corn Fields）、骑士等。

## 常见陷阱与注意事项

1. **行内合法性要同时检查距离 1 和距离 2**：必须同时判 `(state & (state<<1))` 与 `(state & (state<<2))`，漏掉 `<<2` 会多算相邻隔一格的错误状态。
2. **位序全程保持一致**：读图用 `1 << (m-j)` 表示第 $j$ 列，则状态里「第几位对应第几列」必须沿用同一方向，否则山地约束会错位。
3. **山地过滤不能省**：`j & mp[i]` 这层判断少了会允许炮兵放到 H 格上。
4. **边界行**：$n=1$ 或 $n=2$ 时上一行/上上行可能越界，代码里 `pas[0].push_back(0)` 与 `max(i-2,0ll)` 正是为兜底准备的。
5. **滚动数组只开 3 层**：只需相邻三行，读 `(i-1)%3`、写 `i%3`，三层的读写方向不要搞反。
6. **内存**：`1<<11` 的两维配合 `long long` 约 $96$ MB，注意题目内存限制；空间紧张时可用「合法状态编号压缩」把两维从 $2^M \times 2^M$ 降到 $S \times S$。

## 对比与扩展

- **与「互不侵犯」对比**：互不侵犯（P1896）只约束相邻两行，状态是二维的 $dp[i][state][k]$；炮兵阵地攻击距离两格，需同时看两行，状态升到三维。
- **与「集合状压 DP」对比**：TSP / Hamilton 路径压缩的是「已访问的点集」，这里压缩的是「单行棋盘状态」，属于「行状压」这一支。
- **扩展**：可用滚动数组降空间；把合法状态编号压缩到 $S$ 维，减少无效枚举；更复杂的棋盘覆盖（连通性约束）可引入轮廓线 DP（插头 DP）逐格推进。$AKB74$, '动态规划', array['状态压缩', '状压DP', '炮兵阵地', '位运算', '滚动数组'], 'col-dp-bitmask-overview', null, 'knowledge'),
('Xesir', 'col-dp-grid-state--xesir', '棋盘状压 DP（炮兵阵地 + 互不侵犯 · Xesir 版） · Xesir', $AKB75$## 算法原理

棋盘状压 DP 是「行状压 DP」的一种：把每一行的摆放情况压成一个二进制数（1 表示放、0 表示不放），再一行一行地做 DP。它适用于「行内状态可用二进制表示、行与行之间只通过相邻若干行相互约束」的棋盘问题。

本文覆盖两个经典例题，源码里依次给出：

**例题一 · 炮兵阵地（详见洛谷 P2704）**：在 $N \times M$ 的网格上布置炮兵，每门炮的攻击范围是上下左右各两格，任意两门不能互相攻击，只能在平原（P）上放，求最多放多少门。$M \le 10$，所以每行的状态用一个二进制数表示即可。

与「互不侵犯」不同，炮兵的攻击距离更远：第 $i$ 行是否合法不仅取决于第 $i-1$ 行，还取决于第 $i-2$ 行。于是状态要同时记住「当前行」与「上一行」，升成三维 `dp[i][cur][pre]`。预处理出每行「行内相距都 $\ge 3$ 且不压到山地」的合法状态集合，转移时只枚举这些状态，就能把指数级枚举压得很小。

**例题二 · 互不侵犯（详见洛谷 P1896）**：在 $N \times N$ 的棋盘上放 $K$ 个国王，任意两个国王不能相邻（周围 8 格都不行），求方案数。$N \le 9$，每行仍用一个二进制数表示。这里只需「相邻两行」不冲突，状态是二维的 `dp[i][state][k]`。

## 核心公式 / 状态定义与转移方程

### 炮兵阵地

记 $V(i)$ 为第 $i$ 行的合法状态集合：行内任意两个 1 相距至少 3，且不与山地冲突。行内合法等价于同时满足 `(state & (state << 1)) == 0` 与 `(state & (state << 2)) == 0`；山地约束是 `state & mountain[i] == 0`。

状态：`dp[i][cur][pre]` 表示前 $i$ 行中、第 $i$ 行状态为 `cur`、第 $i-1$ 行状态为 `pre` 时能放的最多炮兵数。

转移：枚举第 $i-2$ 行的状态 `prepre`，若三行两两不冲突，则

$$dp[i][cur][pre] = \max_{prepre \in V(i-2)} \Big(dp[i-1][pre][prepre] + \mathrm{popcount}(cur)\Big)$$

答案：遍历末两行，取 $\max dp[N][cur][pre]$。

### 互不侵犯

状态：`dp[i][state][k]` 表示前 $i$ 行、第 $i$ 行状态为 `state`、总共放了 $k$ 个国王的方案数。

转移：枚举上一行状态 `pre`，检查冲突后累加

$$dp[i][state][k] = \sum_{pre} dp[i-1][pre][k - \mathrm{popcount}(state)]$$

冲突判据：行内 `(state & (state << 1)) == 0`；相邻两行 `(state1 & state2) == 0`，以及与 `state2 << 1`、`state2 >> 1` 都无交。

## 逐行代码解析

### 炮兵阵地 · 头文件、宏与全局数组

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
//const int N=1e5+10;
//int cnt=0;
//int a[N];
int mp[110];
int dp[3][1<<11][1<<11];
int ndp[110][1<<11];
vector<int> pas[110];
inline int read();
inline void write(int x);
int popcount(int x){
    return __builtin_popcount(x);
}
```

- `#define int long long` 统一 64 位整数，配合 `signed main()` 使用，避免答案溢出。
- `mp[i]` 是第 $i$ 行的山地掩码；`pas[i]` 存第 $i$ 行的所有合法状态；`dp[3][1<<11][1<<11]` 是滚动数组，3 层轮流表示第 $i$、$i-1$、$i-2$ 行。
- `popcount` 用 GCC 内置的 `__builtin_popcount` 统计 1 的个数；`ndp`、`read`、`write` 是模板残留，本算法并未使用它们。

### 炮兵阵地 · 读图与预处理合法状态

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    
    int n,m;cin>>n>>m;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            char c;cin>>c;
            if(c=='H') mp[i]|=(1<<(m-j));
        }
    }
    for(int i=1;i<=n;i++){
        for(int j=0;j<(1<<m);j++){
                //cout<<dp[i][j]<<' ';
                //if(i!=1) dp[i][j]=LLONG_MIN;
            if((((j<<2)&j)>0)||(((j<<1)&j)>0)||(((j>>2)&j)>0)||(((j>>1)&j)>0)) continue;
            if(j&mp[i]) continue;
            pas[i].push_back(j);
        }
           //cout<<endl;
    }
    pas[0].push_back(0);
}
```

- 把每行的 H 格压进 `mp[i]`：第 $j$ 列对应第 `m-j` 位，位序要全程保持一致。
- 枚举 $0 \sim 2^m-1$ 的所有状态，`(j<<1)&j`、`(j<<2)&j` 非 0 说明存在相距小于 3 的两个 1，跳过（`>>` 方向是等价的冗余检查）。
- 再用 `j & mp[i]` 排除压到山地的状态，剩下的存入 `pas[i]`。
- `pas[0].push_back(0)` 让「第 0 行为空」成为合法状态，作为第 1 行的上一行、以及边界情况的兜底。

### 炮兵阵地 · 滚动转移、统计答案与快读快写

```cpp
    for(int i=0;i<=2;i++){
        for(int j=0;j<(1<<m);j++){
            for(int u=0;u<(1<<m);u++){
                dp[i][j][u]=LLONG_MIN;
            }
        }
    }
    for(int j:pas[1]){
        dp[1][j][0]=popcount(j);
    }
    for(int i=2;i<=n;i++){
        for(int j:pas[i]){
            for(int u:pas[i-1]){
                if(u&j) continue;
                for(int o:pas[max(i-2,0ll)]){
                    if(o&u) continue;
                    if(o&j) continue;
                    
                    dp[i%3][j][u]=max(dp[i%3][j][u],dp[(i-1)%3][u][o]+popcount(j));
                }
                
            }
        }
    }
    
    int cnt=0;
    for(int j:pas[n]){
        for(int k:pas[n-1]){
            cnt=max(cnt,dp[n%3][j][k]);
        }
    }
       cout<<cnt<<endl;
    
    
    return 0;
}
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- 先把 3 层滚动数组置为 `LLONG_MIN`（不可达）；第 1 行没有上一行，只与「空上一行」（状态 0）相容，所以 `dp[1][j][0]=popcount(j)`。
- 第 $i$ 行从第 $i-1$、$i-2$ 行转移：`j` 是当前行、`u` 是上一行、`o` 是上上行，三层都从各自行的合法状态集里取。
- `u&j`、`o&u`、`o&j` 三处 `continue` 保证三行两两不冲突；`max(i-2,0ll)` 处理 $i=2$ 时上上行为第 0 行。
- 用 `dp[i%3][j][u] = max(..., dp[(i-1)%3][u][o] + popcount(j))` 完成滚动更新，把上一行的最优值加上本行新增的炮兵数。
- 最后枚举末两行的组合取最大值，`cout<<cnt` 输出。
- 底部的 `read` / `write` 是模板，本程序未调用（实际走 `cin/cout`）。

### 互不侵犯 · 头文件与全局

```cpp
#include <bits/stdc++.h>
using namespace std;
#define fi first
#define se second
typedef long long ll;
typedef pair<ll,ll> PII;
ll n,k;
ll dp[10][1<<10][100];
ll count_ones(ll n) {
    return __builtin_popcount(n);
}
```

- `dp[10][1<<10][100]` 对应「行数 $\le 9$、状态 $2^9$、国王数 $\le 100$」，用 `long long` 存方案数（方案数可能很大）。
- `count_ones` 用 `__builtin_popcount` 统计一行里国王的个数。
- 注意这份代码**没有** `#define int long long`，却仍写了 `signed main()`——`signed` 与 `int` 等价，能正常编译。

### 互不侵犯 · main 转移与统计

```cpp
signed main(){
    ll cnt=0;
    cin>>n>>k;
    dp[0][0][0]=1;
    for(ll i=1;i<=n;i++){
        for(ll s=0;s<(1<<n);s++){
            for(ll a=0;a<(1<<n);a++){
                for(ll j=0;j<=k;j++){
                    ll u=count_ones(a),v=count_ones(s);
                    if(s&a) continue;
                    if(a&(a<<1)) continue;
                    if(s&(a<<1)) continue;
                    if(s&(s<<1)) continue;
                    if(a&(s<<1)) continue;
                    if(j+u>k||j<v) continue;
                    dp[i][a][j+u]+=dp[i-1][s][j];
                }
            }
        }
    }
    for(ll s=0;s<(1<<n);s++){
        if(count_ones(s)<=k) cnt+=dp[n][s][k];
    }
    cout<<cnt;
}
```

- `dp[0][0][0]=1`：第 0 行、状态 0、放了 0 个国王，这一种方案数作为边界。
- 四重循环：行 $i$、当前行状态 `a`、上一行状态 `s`、已放国王数 $j$。
- 五个 `continue` 覆盖全部冲突：`s&a`（同列撞车）、`a&(a<<1)`（当前行内相邻）、`s&(a<<1)`（左上 / 右下对角）、`s&(s<<1)`（上一行内相邻，属冗余检查）、`a&(s<<1)`（另一种对角）。
- `if(j+u>k||j<v) continue;` 保证总数不超 $k$；其中 `j<v` 恒不成立（前 $i-1$ 行已包含第 $i-1$ 行的 `v` 个国王，故必有 `j >= v`），属多余判断。
- 累加 `dp[i][a][j+u]+=dp[i-1][s][j]`；最后把末行所有状态、总数恰好为 $k$ 的方案数求和输出。

## 复杂度分析

**炮兵阵地**：

- 预处理每行枚举 $2^M$ 个状态，成本 $O(N \cdot 2^M)$。
- 转移共 $N$ 行，每行三重循环分别枚举 `pas[i]`、`pas[i-1]`、`pas[i-2]`，每层至多 $S$ 个合法状态：$O(N \cdot S^3)$。$M=10$ 时 $S \approx 60$，$N \le 100$ 时约 $2 \times 10^7$，很快。
- 空间：滚动数组 3 层，每层 `cur × pre` 两维，实现里直接按 $2^M \times 2^M$ 开满，`long long` 下约 96 MB；把合法状态编号压缩后可降到 $O(S^2)$。

**互不侵犯**：

- 时间：$O(N \cdot 2^N \cdot 2^N \cdot K)$，实测可过（大量状态非法，预处理转移表能更快）。
- 空间：$O(N \cdot 2^N \cdot K)$。

## 适用场景

1. **棋盘 / 网格上的「放置」类问题**：每格只有放 / 不放两种状态，单行用一个二进制数表示。
2. **行与行只依赖相邻的常数行**：相邻两行约束 → 二维状态；像炮兵这样跨两行约束 → 三维状态。
3. **列数很小、行数可以很大**：$M \le 10$ 使 $2^M$ 可枚举，$N$ 只出现在外层循环里。
4. **典型题目**：炮兵阵地（P2704）、互不侵犯（P1896）、玉米田、骑士等。

## 常见陷阱与注意事项

1. **行内合法性要同时检查距离 1 和距离 2**：炮兵必须同时判 `(state & (state<<1))` 与 `(state & (state<<2))`，漏掉 `<<2` 会多算隔一格也能互相攻击的错误状态。
2. **位序全程一致**：读图用 `1 << (m-j)` 表示第 $j$ 列，状态里「第几位对应第几列」必须沿用同一方向，否则山地约束会错位。
3. **山地过滤不能省**：少了 `j & mp[i]` 这层判断，就会允许炮兵放到 H 格上。
4. **边界行要兜底**：$n=1$ 或 $n=2$ 时上一行 / 上上行可能越界，`pas[0].push_back(0)` 与 `max(i-2,0ll)` 正是为此准备。
5. **滚动数组只开 3 层**：读 `(i-1)%3`、写 `i%3`，三层读写方向不要搞反。
6. **内存**：`1<<11` 的两维配合 `long long` 约 96 MB，注意内存限制；紧张时可用「合法状态编号压缩」。
7. **互不侵犯的冲突判据有一处冗余**：`s&(s<<1)` 与上一行内部的相邻检查重复，可去掉；`j<v` 也恒不成立。
8. **`signed main` 的两种来源**：炮兵阵地是因为 `#define int long long` 才需要 `signed main`；互不侵犯没有该宏，写 `signed main` 只是习惯，二者都合法。
9. **`#define int long long` 开启后**所有 `int` 变成 64 位，`max(i-2,0ll)` 里的 `0ll` 就是为配合它写的。

## 对比与扩展

- 炮兵阵地 vs 互不侵犯：前者跨两行约束 → 三位状态 + 滚动数组；后者只约束相邻两行 → 二维状态 + 计数维度 $K$。
- 与集合状压（TSP、子集 DP）对比：这里压缩的是「单行棋盘」，属于「行状压」这一支。
- 扩展：用滚动数组降空间；把合法状态编号压缩到 $S$ 维减少无效枚举；更复杂的棋盘覆盖（连通性约束）可引入轮廓线 DP（插头 DP）逐格推进。$AKB75$, '动态规划', array['动态规划', '状态压缩', '棋盘状压DP', '炮兵阵地', '互不侵犯'], 'col-dp-bitmask-overview', null, 'knowledge'),
('Xesir', 'col-dp-group-bag--xesir', '分组背包 · Xesir', $AKB76$## 算法原理

物品分成若干组，每组内只能选一个（或者不选）。详见云兰阁 P1215(C9)。

**状态转移**：分组背包本质是 01 背包的变种，只不过决策对象从「单个物品」变成了「组内选哪个」。

设 `f[j]` 表示容量 `j` 时的最大价值。遍历每一组，对于组内每个物品都尝试更新 `f`，但要保证**同一组内只选一个**，所以容量的枚举必须放在物品循环外面，即：

```cpp
for (int k = 1; k <= 组数; k++) {          // 遍历每组
    for (int j = V; j >= 0; j--) {         // 容量倒序（类似01背包）
        for (int each : 组k的物品) {
            if (j >= w[each])
                f[j] = max(f[j], f[j - w[each]] + v[each]);
        }
    }
}
```

**为什么容量循环要在外面？** 因为如果容量循环在物品循环里面，会导致同组多个物品被选（相当于从同一个组里选多个）。把容量放在外层，保证了每个状态 `f[j]` 只考虑本组的一个物品来更新，不会出现「选了两个同组物品」的情况。

## 核心公式 / 状态定义与转移方程

$$
f[j] = \max_{i \in \text{组 } k}\big(f[j],\ f[j - w_i] + v_i\big), \quad j \ge w_i
$$

即对第 $k$ 组，用组内每个物品分别试一次更新 `f[j]`，且 `j` 倒序保证本组只放一个。

## 逐行代码解析

### 头文件与全局容器

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
vector<pair<int,int>> a[1010];
vector<int> f(1010);
```

- `a[i]` 是一个 `vector`，装第 $i$ **组**里的所有物品（每个是 `{重量, 价值}`）。
- `#define int long long` 把全局 `int` 换成 `long long`，所以 `main` 要写成 `signed main()`。
- `f` 是一维 DP，`vector` 初始化大小为 1010。

### main 框架与读入建组

```cpp
signed main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        int s;cin>>s;
        for(int j=1;j<=s;j++){
            int c,d;cin>>c>>d;
            a[i].push_back({c,d});
        }
    }
```

- `n` 是组数，`v` 是容量。
- 每组先读组内物品数 `s`，再读 `s` 个 `{重量 c, 价值 d}` 压进 `a[i]`。
- 组编号从 1 开始，`a[0]` 空着不用。

### 三重循环转移与输出

```cpp
    for(int i=1;i<=n;i++){
        for(int j=v;j>=1;j--){
            for(int k=0;k<a[i].size();k++){
                if(j-a[i][k].first>=0)f[j]=max(f[j],f[j-a[i][k].first]+a[i][k].second);
            }
        }
    }
    cout<<f[v];
    return 0;
}
```

- 外层 `i` 遍历组、中层 `j` 遍历容量**倒序**、内层 `k` 遍历组内物品——正是「容量在外、物品在内」的写法。
- `j-a[i][k].first >= 0` 即容量够放下才转移，等价于伪码里的 `j >= w[each]`。
- 答案 `f[v]`。

## 复杂度分析

- **时间复杂度**：$O(V \times \text{总物品数})$。外层每组一次，中层容量 $V$ 次，内层扫该组物品；所有组内物品数加起来就是总物品数。
- **空间复杂度**：$O(V)$ 的 DP 数组，外加 `a` 存所有物品 $O(\text{总物品数})$。

## 适用场景

物品被预先分组、每组至多取一件的背包题，如「每组只能买一样」的方案选择。按组读入、组内互斥枚举即可。

## 常见陷阱与注意事项

1. **容量循环位置**：必须在物品循环**外面**；一旦反过来（先枚举物品再枚举容量），同组会被选多个。
2. **容量倒序**：`j` 从 `v` 递减到 1，保证本组只放一个，和 01 背包同理。
3. **`j=0` 没遍历**：循环写到 `j>=1`，容量为 0 的状态不必更新。
4. **`k` 与 `size()` 的比较**：`k` 是 `int`、`a[i].size()` 是 `unsigned`，会触发符号比较警告，能用但不严谨。
5. **`signed main`**：开了 `#define int long long`，入口必须写 `signed main()`。
6. **数组大小**：`f` 与组数上界 1010，超出要改。

## 对比与扩展

与 01 背包的关系：01 背包每个物品独立决策，分组背包是「组内先选出最优的那一个，再当作一个决策」。可推广为**每组至少选一个 / 恰好选 $t$ 个**的变体，做法是在组内枚举选几个再统一转移。$AKB76$, '动态规划', array['动态规划', '背包问题', '分组背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-group-bag', '分组背包', $AKB77$## 算法原理

分组背包是01背包的变体：将物品分为若干组，每组中最多选择一件物品（可以不选）。这与01背包的区别在于"组"的约束——同一组内的物品互斥，而不同组之间独立。

状态定义 $dp[j]$ 表示容量为 $j$ 时的最大价值（使用一维滚动数组）。对每一组，在当前容量允许的范围内枚举组内每件物品 $k$（重量 $w_k$，价值 $v_k$）进行转移。转移方程为 $dp[j] = \max(dp[j], dp[j - w_k] + v_k)$。

关键在于遍历顺序的三重循环结构：外层遍历组号 $i$，中层对容量 $j$ 逆序遍历，内层对组内物品正向枚举。容量逆序遍历是保证"每组最多选一件"的核心——当处理组 $i$ 时，容量从大到小遍历，使得组内任意一件物品 $k$ 的转移依赖的 $dp[j - w_k]$ 尚未被同组其他物品更新过，从而保证同一组内不会同时选中两件物品。组内物品的正向枚举则不影响正确性，因为每件物品的转移都基于"未选本组任何物品"的状态。

这种结构确保：处理完一组后，$dp[j]$ 已经考虑了"在本组中选一件或不选"的所有可能性，然后进入下一组继续处理。

## 状态定义与转移方程

状态定义：

$$dp[j] = \text{容量为 } j \text{ 时的最大价值}$$

状态转移方程（对组 $i$ 内的物品 $k$）：

$$dp[j] = \max\big(dp[j],\; dp[j - w_k] + v_k\big), \quad j \geq w_k$$

遍历顺序约束：

$$\text{外层：组 } i \;\to\; \text{中层：容量 } j \text{ 逆序} \;\to\; \text{内层：组内物品 } k$$

最终答案：

$$\text{ans} = dp[m]$$

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<pair<int,int>> A[101];
```

- `A` 数组：以组号为下标的 `pair` 向量数组，`A[c]` 存第 $c$ 组的所有物品，每个 `pair` 的 `first` 为重量、`second` 为价值，固定大小 $101$。
- 物品的重量和价值用 `int` 存即可，最终结果（`dp`）用 `long long` 防溢出。

### main 初始化与读入

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int m,n,sz = 0;
	cin >> m >> n;
	vector<long long> dp(m + 1,0);
	for(int i = 0;i < n;i++)
	{
		int a,b,c;
		cin >> a >> b >> c;
		A[c].emplace_back(a,b);
		sz = max(sz,c);
	}
```

- `m` 为背包容量、`n` 为物品总数；`dp` 是一维滚动数组，大小 $m+1$，初始化为 $0$，用 `long long` 防溢出。
- 输入格式：每组数据三个值 $a$（重量）、$b$（价值）、$c$（组号），物品按组号归类存入 `A[c]`。
- `sz` 记录最大组号，用于确定外层循环范围。

### 核心 DP 三重循环

```cpp
	for(int i = 1;i <= sz;i++)
	{
		for(int j = m;j > 0;j--)
		{
			for(int z = 0;z < A[i].size();z++)
			{
				if(j >= A[i][z].first) dp[j] = max(dp[j - A[i][z].first] + A[i][z].second, dp[j]);
			}
		}
	}
```

- 外层遍历组号 $i$（$1$ 到 $sz$），中层容量 $j$ 逆序（$m$ 到 $1$），内层遍历组内每件物品 $z$。
- 容量逆序保证同一组内任意物品的转移都基于「未选本组任何物品」的旧状态，从而每组最多选一件。
- 转移只在 $j \geq$ 物品重量（`A[i][z].first`）时执行，避免下标越界；否则不更新 `dp[j]`。

### 输出结果

```cpp
	cout << dp[m]; 
	return 0;	
} 
```

- `dp[m]` 即为容量 $m$ 下的最大价值，处理完全部组后直接输出。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$，其中 $n$ 为总物品数（所有组物品之和），$m$ 为背包容量。更精确地是 $O\big(\sum_{i} |G_i| \times m\big)$，即所有组的物品数之和乘以容量。
- **空间复杂度**：$O(m)$。一维滚动数组。额外空间 $O(n)$ 用于存储物品分组。

## 适用场景

适用于物品被分组、每组最多选一件的背包问题，例如：菜单分类每类选一道菜、课程按学期分组每学期选一门、装备按部位分组每部位选一件等。当题目明确给出"分组"或"互斥选择"的约束时使用。

## 常见陷阱与注意事项

- **三重循环的顺序**：必须为"组 $\to$ 容量逆序 $\to$ 组内物品"。若将容量和物品的循环交换（先遍历物品再遍历容量），会变成对组内所有物品做01背包，导致同组内可能选多件。
- **容量逆序的原因**：保证同一组内任意物品的转移都基于"未选本组任何物品"的旧状态。若正序则可能先选了物品A再选物品B，违反每组最多一件的约束。
- **组内物品的枚举顺序**：正向枚举即可，不影响正确性，因为每件物品的转移都读同一个 $dp[j-w_k]$（本组未更新前的值）。
- **`A` 数组大小**：固定为 $101$，若组号可能超过 $100$ 需要调整大小或使用 `map`。
- **`long long` 防溢出**：价值和可能较大，使用 `long long` 存储 `dp` 值。
- **组号下界**：外层循环固定从 $1$ 开始，若输入组号从 $0$ 开始，`A[0]` 中的物品会被静默丢弃；应约定组号从 $1$ 开始，或读入时统一对组号加 $1$ 偏移。

## 对比与扩展

与01背包相比，分组背包的核心区别在于三重循环结构和"每组最多选一件"的约束。若每组内物品可重复选取则变为"分组完全背包"（容量改正序遍历）。分组背包可进一步推广为"每组最多选 $k$ 件"的泛化版本。在树形DP中，将每个节点的子节点视为一个"组"即可将分组背包用于树形依赖背包问题。$AKB77$, '动态规划', array['动态规划', '背包问题', '分组背包', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-integer-partition--xesir', '整数划分 · Xesir', $AKB78$## 算法原理

给定一个正整数 `n`，求将 `n` 拆分成若干个正整数之和的方案数（顺序无关，即 `1+2` 和 `2+1` 算同一种），答案对 `1e9+7` 取模。

**状态设计**：这是一个完全背包的变种，但这里按线性 DP 处理。设 `f[j]` 表示凑出数字 `j` 的方案数，初始化 `f[0] = 1`。

然后枚举每个整数 `i`（从 1 到 n），对于每个 `j`（从 `i` 到 n），执行 `f[j] += f[j-i]`。

这其实等价于完全背包求方案数，因为每个数字都可以无限使用。由于要求**顺序无关**，所以外层循环是数字 `i`、内层是容量 `j`（正序），这样能保证每个组合只被统计一次。

## 核心公式 / 状态定义与转移方程

状态定义：

$$f[j] = \text{用若干正整数（无序）凑出 } j \text{ 的方案数}$$

转移（外层物品 `i`、内层容量 `j` 正序）：

$$f[j] \mathrel{+}= f[j-i], \quad j \ge i$$

边界条件 $f[0] = 1$，最终答案 $f[n] \bmod (10^9+7)$。

## 逐行代码解析

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
int f[1010];
const int mod=1e9+7;
```

- `f[j]` 是「凑出 j 的方案数」的一维 DP 数组。
- `mod = 1e9+7` 用于取模。

### main、初始化与读入

```cpp
int main(){
    f[0]=1;
    int n;cin>>n;
```

- `f[0]=1`：凑出 0 的方案数是 1（一个都不选），这是整个计数 DP 的起点。
- 读入 `n`。

### 核心双重循环

```cpp
    for(int i=1;i<=n;i++){
        for(int j=i;j<=n;j++){
            f[j]+=f[j-i];f[j]%=mod;
        }
    }
```

- 外层枚举「当前允许使用的数字」`i`，从 1 到 n。
- 内层 `j` 从 `i` 到 `n` **正序**：`f[j] += f[j-i]` 表示「在凑出 j-i 的方案后面再添一个 i」。
- 外层是物品、内层正序，这正是完全背包的标准写法，保证每个数字可用无限次、且组合不重复计数。
- 每加一次立刻 `%= mod`，防止数值膨胀。

### 输出

```cpp
    cout<<f[n]%mod;
}
```

- 输出 `f[n]` 对 `mod` 取模的结果，即划分数。

## 复杂度分析

- **时间复杂度**：$O(n^2)$，两重循环合计约 $n^2/2$ 次加法。
- **空间复杂度**：$O(n)$，只用一个一维数组 `f`。

## 适用场景

- 整数划分（无序拆分为正整数之和）的方案计数。
- 「每个物品可用无限次、求凑出某容量的方案数」的完全背包问题，都可以套这个一维正序写法。
- 与之对照：如果要求**顺序有关**（`1+2` 与 `2+1` 算不同），那就不再是整数划分，而是另一类计数问题（需要换掉外层内层的顺序或改用别的 DP）。

## 常见陷阱与注意事项

1. **外层物品、内层容量是正序**：这是「完全背包、组合不重复」的关键；若把两层顺序写反，就变成统计「有序拆分」，答案会大很多。
2. **`f[0]=1` 不能漏**：这是计数 DP 的起点，漏了后面全是 0。
3. **取模位置**：`f[j]+=f[j-i]; f[j]%=mod;` 每次都取模。因为两者都小于 `mod`，相加不超过 $2 \times 10^9$，仍在 `int` 范围内，不会溢出。
4. **数据范围**：`f` 只开到 1010，$n$ 超过 1000 要加大数组。
5. **答案含义**：这里统计的是「无序拆分」，与「把 n 分成若干个正整数之和」的划分数一致。

## 对比与扩展

| 问题 | 外层 / 内层 | 是否重复计数 |
|---|---|---|
| 整数划分（本项目标） | 物品在外、容量在内正序 | 组合不重复 |
| 有序拆分 | 容量在外、物品在内 | 会重复（统计的是排列） |

扩展方向：限制「拆成恰好 k 部分」「每个数不超过 m」「每个数出现次数有上限」等变体，分别对应加维、加限制或改成多重背包。$AKB78$, '动态规划', array['动态规划', '线性DP', '整数划分', '完全背包', '计数DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-interval-overview', '区间 DP 总览（石子合并 / 括号序列 / 涂色与合成）', $AKB79$## 算法原理

本页是「区间 DP」的二级栏目索引：状态定义为区间 $[l,r]$，按区间长度从小到大枚举，转移时枚举分界点 $k$ 合并左右子区间。

**学习顺序**：环形石子合并 → 括号序列模型 → 涂色问题 → 合成问题。

## 核心公式 / 状态定义与转移方程

**按题型选子栏目**：

| 题型 | 子条目 |
|---|---|
| 合并相邻两堆的代价 | 区间DP — 环形石子合并 |
| 括号/回文类匹配 | 括号序列模型 |
| 区间染色 | 区间DP — 涂色问题 |
| 两段合成一段 | 区间DP — 合成问题 |

通用转移：$f[l][r]=\min_{l\le k<r}\{f[l][k]+f[k+1][r]+w(l,k,r)\}$。

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出转移方程、边界与逐行解析。

## 复杂度分析

- 标准区间 DP：$O(n^3)$，空间 $O(n^2)$。
- 环形石子合并：断环成链后长度翻倍，复杂度同 $O(n^3)$。
- 部分题型可用四边形不等式优化到 $O(n^2)$，以子页说明为准。

## 适用场景

- 相邻合并、消去、染色、括号匹配。
- 需要枚举分界点的序列最优划分。
- 环形问题（复制一倍断环）。

## 常见陷阱与注意事项

- 枚举顺序必须是「先长度、后左端点」，否则用到未计算状态。
- 环形问题复制数组后答案区间长度为 $n$，不是 $2n$。
- 初始化：单点区间要有合法初值。
- 合成/涂色题的 $w$ 依赖分界点，不能漏项。
- $O(n^3)$ 在 $n\approx 500$ 时就可能超时，先看数据范围。

## 对比与扩展

- 区间 DP vs 线性 DP：前者按区间长度推进，后者按下标推进。
- 与分治的区别：区间 DP 会枚举所有分界点并保存子区间答案。
- 可扩展到环形 DP、树上区间合并。$AKB79$, '动态规划', array['区间DP', '石子合并', '括号序列', '总览', '学习路线'], null, null, 'knowledge'),
('Xesir', 'col-dp-interval-paint--xesir', '区间DP — 涂色问题 · Xesir', $AKB80$## 算法原理

区间涂色也是一道经典的区间 DP 模型：**用最少的刷子次数，把一个空串涂成目标串**。

> 给定一个目标字符串，每次可以把一段连续区间涂成同一个字符，求最少涂色次数。详见洛谷 P4170

**状态**：`f[l][r]` 表示将区间 `[l, r]` 涂成目标串所需的最少次数。
**初始化**：`f[i][i] = 1`（单个格子涂一次）。

**转移**：

- 如果 `s[l] == s[r]`，那么涂 `[l, r]` 时可以先涂 `[l, r-1]` 或 `[l+1, r]`，因为两端的颜色可以一次带过，所以

$$
f[l][r] = \min(f[l][r-1],\ f[l+1][r])
$$

- 否则枚举分割点 `k`：

$$
f[l][r] = \min_{k=l}^{r-1} (f[l][k] + f[k+1][r])
$$

注意初始化 `f[i][i] = 1`，其余 `INF`。

## 核心公式 / 状态定义与转移方程

| 情况 | 转移式 |
|---|---|
| `s[l] == s[r]` | $f[l][r] = \min(f[l][r-1],\ f[l+1][r])$ |
| `s[l] != s[r]` | $f[l][r] = \min_{k=l}^{r-1}(f[l][k] + f[k+1][r])$ |

直觉：两端颜色相同，说明涂左端那一次可以顺手把右端也涂了，于是省一次；不同色就只能把区间切成两段各涂各的。

## 逐行代码解析

### 模块一：读入与下标对齐

```cpp
    string a;cin>>a;//cout<<a;
    a=" "+a;
    int n=a.size()-1;
    //cout<<n;
```

- 读入目标串后，在开头补一个空格，让字符串变成 **1-indexed**：`a[1]` 对应第一个字符，数组下标与 DP 的 `l / r` 完全对齐。
- `n = a.size() - 1` 就是原串长度。

### 模块二：单点初始化与长度递推

```cpp
    for(int i=1;i<=n;i++){
		f[i][i]=1;
	}
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
```

- `f[i][i] = 1`：长度为 1 的区间涂一次即可。
- 外层枚举长度 `d`，内层枚举左端点，右端点 `r = l + d - 1`，越界跳过。

### 模块三：两种转移

```cpp
            if(a[l]==a[r]) f[l][r]=min(f[l][r-1],f[l+1][r]);
            
            for(int k=l;k<r;k++){
				f[l][r]=min(f[l][r],f[l][k]+f[k+1][r]);
            }
```

- 两端相同：用「去掉一端」的子区间转移，靠 `min` 取较优的一侧。
- 之后无条件再枚举分割点 `k`，把区间切成两段分别涂，取更小的方案。
- 最后输出 `f[1][n]`。

## 复杂度分析

- 时间复杂度：状态数 $O(n^2)$，每个状态枚举分割点 $O(n)$，共 $O(n^3)$。
- 空间复杂度：二维 `f` 数组 $O(n^2)$。

## 适用场景

- 区间**涂色 / 染色**类问题：一次操作可以覆盖连续一段，求最少操作次数。
- 更一般的「区间覆盖成统一值」的场景，只要最后一步能拆成子区间，就可以套这个框架。

## 常见陷阱与注意事项

1. **下标对齐**：读入后补一个空格，保证 `s[l]`、`s[r]` 与 DP 下标一致，否则会整体错位。
2. **相等分支容易漏**：`s[l] == s[r]` 时一定要先做 `min(f[l][r-1], f[l+1][r])`，否则答案会偏大。
3. **初始化**：`f[i][i] = 1`，其余要置 `INF`（求最小），否则 `min` 取不到有意义的值。
4. **遍历顺序**：同样按长度递增，短区间先算好。
5. **源里的可疑写法（照搬未改）**：代码中全局 `vector<char> a(310)` 被主函数里局部声明的 `string a` **同名遮蔽**，实际起作用的是局部 `string a`，全局那个 `vector<char>` 是多余的；后续 `a=" "+a;`、`a[l]`、`a[r]` 用的都是 `string`。这属于源代码的冗余，不影响运行结果，本知识点按**原样搬运**，不做修改。$AKB80$, '动态规划', array['区间DP', '动态规划', '涂色', '洛谷P4170', '枚举分割点'], 'col-dp-interval-overview', null, 'knowledge'),
('Fohen', 'col-dp-interval-stone-merge--fenfeng', '区间DP — 环形石子合并（区间DP入门经典） · Fohen', $AKB81$## 算法原理

区间 DP 是一类基础但应用广泛的动态规划。它的核心思想是：**先求出小区间的最优解，再把两个小区间合并成大区间**。

判断一个问题能不能用区间 DP，看它是否满足：答案可以看成「一个区间的最优解由它内部两个子区间的最优解拼出来」。满足这个特征，基本就能套区间 DP。它的套路非常固定：

- **状态**：`f[l][r]` 表示只考虑区间 `[l, r]` 的最优答案。
- **转移**：枚举分割点 `k`，把区间切成 `[l, k]` 和 `[k+1, r]`，再合并这两个子区间的最优解。
- **计算顺序**：按区间长度从小到大（`len = 2 → n`）递推，因为长区间依赖短区间。

定义状态时要先想清楚「这个区间代表什么操作」——是「涂成一个颜色」、「合并成一堆石子」还是「合成一个数字」。转移时把**最后一步**（或最后一次合并）作为分割点，就能保证不重不漏。

### 石子合并问题

有 $n$ 堆石子**排成一行**，每次只能合并**相邻**的两堆，合并代价为这两堆重量之和，求把所有石子合并成一堆的**最小总代价**。

## 核心公式 / 状态定义与转移方程

### 状态定义

`f[l][r]` 表示把区间 `[l, r]` 内所有石子合并成一堆的最小代价。

### 初始化

`f[i][i] = 0`（单堆石子不用合并，代价为 0）。

### 转移方程

枚举「最后一次合并」的分界点 `k`：先把 `[l, k]` 合并成一堆，再把 `[k+1, r]` 合并成一堆，最后把这两堆合并。最后一步的代价是两堆重量之和，用前缀和 `sum[r] - sum[l-1]` 快速求出：

$$
f[l][r] = \min_{k=l}^{r-1} \Big( f[l][k] + f[k+1][r] + \text{sum}[r] - \text{sum}[l-1] \Big)
$$

### 破环为链（环形石子合并）

如果石子**首尾相接**摆成一个环，直接套用线性区间 DP 会漏掉跨过首尾的合并。经典解法是**破环为链**：把原数组复制成两倍长度，变成一条长度为 $2n$ 的链，然后在这条链上枚举所有长度为 $n$ 的区间，分别做一次区间 DP，最后取最值。

此时同时求**最大**和**最小**两个代价，分别用 `f1`（最大）和 `f2`（最小）两张表。核心片段如下：

```cpp
for(int i=1;i<=2*n;i++){
    if(i<=n) cin>>a[i];
    else a[i]=a[i-n];
    f1[i][i]=0;f2[i][i]=0;
    p[i]=p[i-1]+a[i];
}
for(int d=2;d<=2*n;d++){
    for(int l=1;l<=2*n;l++){
        int r=l+d-1;
        if(r>2*n) continue;
        for(int k=l;k<r;k++){
            f1[l][r]=max(f1[l][r],f1[l][k]+f1[k+1][r]+p[r]-p[l-1]);
            f2[l][r]=min(f2[l][r],f2[l][k]+f2[k+1][r]+p[r]-p[l-1]);
        }
    }
}
int ans1=0,ans2=INF;
for(int i=1;i<=n;i++){
    ans1=max(f1[i][i+n-1],ans1);
    ans2=min(f2[i][i+n-1],ans2);
}
```

> 上面是「补充片段」，省略了头文件、`main` 函数以及 `f2` 初始化为 `INF` 等完整代码；完整可运行代码（线性版）见下方「逐行代码解析」。

## 逐行代码解析

以下为线性版（排成一行、只求最小代价）的完整代码，按模块拆解。

### 模块一：全局定义

```cpp
#include <bits/stdc++.h>
using namespace std;
const int INF=1e9;
vector<vector<int>> f(310,vector<int>(310,INF));
vector<int> a(310),p(310);
```

- `f` 是 DP 表，初始化为 `INF`（极大值），表示「尚未合并」。
- `a` 存每堆石子的重量，`p` 是前缀和数组。
- 数组大小 `310` 足够容纳 $n \le 300$ 的数据。

### 模块二：输入与初始化

```cpp
int main(){
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i][i]=0;
        p[i]=p[i-1]+a[i];
    }
```

- 读入的同时把单堆区间 `f[i][i]` 置为 `0`，并累加前缀和 `p[i] = p[i-1] + a[i]`。

### 模块三：区间 DP 转移

```cpp
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
            for(int k=l;k<r;k++){
                f[l][r]=min(f[l][r],f[l][k]+f[k+1][r]+p[r]-p[l-1]);
            }
        }
    }
```

- 最外层按区间长度 `d` 从小到大枚举，保证长区间依赖的短区间已经算好。
- 中层枚举左端点 `l`，右端点 `r = l + d - 1`；`r > n` 时越界，跳过。
- 内层枚举分割点 `k`，把 `[l, r]` 切成 `[l, k]` 与 `[k+1, r]`。
- `p[r] - p[l-1]` 是区间 `[l, r]` 的总重量，即最后一次合并的代价。

### 模块四：输出答案

```cpp
    cout<<f[1][n];
}
```

- 线性问题里整个区间就是 `[1, n]`，答案直接输出 `f[1][n]`。

## 复杂度分析

- **状态数**：$O(n^2)$（区间左右端点）。
- **单状态转移**：枚举分割点 $O(n)$。
- **总时间复杂度**：$O(n^3)$，对于 $n \le 300$ 的数据够用；若转移满足四边形不等式等特殊性质，可优化到 $O(n^2)$。
- **空间复杂度**：$O(n^2)$（DP 表）；环形版数组翻倍到 $2n$，DP 表为 $O((2n)^2)$，仍是 $O(n^2)$ 量级。

## 适用场景

1. **区间合并类**：石子合并、能量项链等——大区间的最优解由两个子区间合并而来。
2. **区间最优决策**：涂色、加分二叉树等——答案定义在区间上，且与内部子区间相关。
3. **环形区间问题**：通过「破环为链」转化为线性区间 DP。

## 常见陷阱与注意事项

1. **先算短区间**：计算顺序必须按区间长度从小到大，长区间依赖短区间。
2. **分割点不能取到右端点**：分割点 $k$ 的范围是 $l \le k < r$，切出的右区间 `[k+1, r]` 不能为空。
3. **前缀和下标**：区间和写作 `p[r] - p[l-1]`，注意是 `l-1` 而不是 `l`。
4. **环形数组开两倍**：破环为链后，数组、前缀和、DP 表都要按 $2n$ 的长度开，否则越界。
5. **环形答案取最值**：环形版的答案不是 `f[1][n]`，而是枚举所有长度为 $n$ 的区间取最值。
6. **最小值初始化**：求最小代价的 `f`（或环形版的 `f2`）要初始化为极大值（如 `INF`），再交给 `min` 更新，否则取不出最小值。
7. **线性与环形别写混**：线性版只求最小代价（单张 `f` 表），环形版同时求最大（`f1`）和最小（`f2`）两张表，注意命名对应关系。

## 对比与扩展

| 版本 | 状态 | 答案提取 | 说明 |
|---|---|---|---|
| 线性石子合并 | `f[l][r]` 最小代价 | `f[1][n]` | 排成一行，只求最小 |
| 环形石子合并 | `f1`（最大）/ `f2`（最小） | 枚举 `f[·][i+n-1]` 取最值 | 破环为链，数组翻倍到 $2n$ |

区间 DP 的核心就是**枚举分割点、合并子区间**。遇到区间题，先看「最后一步」是什么——是切分、合并，还是端点取舍——想清楚后套上 `f[l][r]` 框架，按长度递增计算即可。

同一套区间 DP 框架还能推广到其它问题：

- **涂色问题**（洛谷 P4170）：当区间两端颜色相同 `s[l] == s[r]` 时，可以直接由去掉一端的区间转移 `f[l][r] = min(f[l][r-1], f[l+1][r])`，省去分割点枚举。
- **合成问题**（洛谷 P3146）：相邻两个相同数字 $x$ 合成 $x+1$，需要「能否完全合成」与「能得到的最大数字」两张表，分别存储、语义不同。$AKB81$, '动态规划', array['区间DP', '动态规划', '石子合并', '破环为链', '前缀和', '枚举分割点'], 'col-dp-interval-overview', null, 'knowledge'),
('Xesir', 'col-dp-interval-stone-merge--xesir', '区间DP — 石子合并（含破环为链） · Xesir', $AKB82$## 算法原理

石子合并是区间 DP 的入门经典：**先求出小区间的最优解，再把两个小区间拼成大区间**。

> 有 n 堆石子排成一行，每次合并相邻两堆，代价为两堆重量之和，求合并成一堆的最小总代价。详见云兰阁 P1222(C9)

**状态**：`f[l][r]` 表示合并区间 `[l, r]` 内所有石子成一堆的最小代价。
**初始化**：`f[i][i] = 0`（单堆不用合并）。
**转移**：枚举**最后一步**合并的分界点 `k`，即先把 `[l, k]` 合并成一堆，再把 `[k+1, r]` 合并成一堆，最后合并这两堆。代价为两堆重量之和，用前缀和 `sum[r] - sum[l-1]` 快速得到。

把最后一步作为分割点，保证每个状态被不重不漏地枚举到；按区间长度从小到大递推，长区间依赖的短区间一定已经算好。

## 核心公式 / 状态定义与转移方程

$$
f[l][r] = \min_{k=l}^{r-1} (f[l][k] + f[k+1][r] + sum[r] - sum[l-1])
$$

其中 `sum` 为前缀和，$f[l][r]$ 只依赖长度更短的子区间。

**代码**就是经典的 $O(n^3)$ 写法，数据小直接跑。

补充：如果问题中的区间是**首尾相接的环**（比如石子摆成一个环），直接套用区间 DP 会漏掉跨过首尾的合并。

经典解法是**破环为链**，即把原数组复制成两倍长度，变成一条长度为 $2n$ 的链，然后在这个链上枚举所有长度为 $n$ 的区间，分别做一次区间 DP，最后取最值。

## 逐行代码解析

下面的代码按模块拆开讲，拼起来就是完整实现。

### 模块一：读入与前缀和初始化

```cpp
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i][i]=0;
        p[i]=p[i-1]+a[i];
    }
```

- `f[i][i] = 0`：长度为 1 的区间不用合并，代价为 0。
- `p[i] = p[i-1] + a[i]`：边读入边做前缀和，之后任意区间的和都能 $O(1)$ 取出。
- 全局 `f` 初值设为 `INF`，这样 `min` 才能正确被第一次转移覆盖。

### 模块二：区间 DP 三重循环

```cpp
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
            for(int k=l;k<r;k++){
                f[l][r]=min(f[l][r],f[l][k]+f[k+1][r]+p[r]-p[l-1]);
            }
        }
    }
    cout<<f[1][n];
```

- 最外层枚举**区间长度** `d`，保证算 `[l, r]` 时它的所有子区间都已算好。
- 中间枚举左端点 `l`，右端点 `r = l + d - 1`，越界直接跳过。
- 内层枚举分割点 `k`，转移式即前面那条公式；`p[r] - p[l-1]` 就是本次合并的代价。
- 答案输出 `f[1][n]`。

### 模块三：破环为链

```cpp
for(int i=1;i<=2*n;i++){
    if(i<=n) cin>>a[i];
    else a[i]=a[i-n];
    f1[i][i]=0;f2[i][i]=0;
    p[i]=p[i-1]+a[i];
}
for(int d=2;d<=2*n;d++){
    for(int l=1;l<=2*n;l++){
        int r=l+d-1;
        if(r>2*n) continue;
        for(int k=l;k<r;k++){
            f1[l][r]=max(f1[l][r],f1[l][k]+f1[k+1][r]+p[r]-p[l-1]);
            f2[l][r]=min(f2[l][r],f2[l][k]+f2[k+1][r]+p[r]-p[l-1]);
        }
    }
}
int ans1=0,ans2=INF;
for(int i=1;i<=n;i++){
    ans1=max(f1[i][i+n-1],ans1);
    ans2=min(f2[i][i+n-1],ans2);
}
```

- 数组开到 `2n`，后半段由 `a[i] = a[i-n]` 复制得到，环就被「拉直」成链。
- `f1` 求最大、`f2` 求最小，同一套循环里一起转移（环形石子合并常同时问最大 / 最小代价）。
- 最后枚举所有长度为 `n` 的窗口 `[i, i+n-1]`，取最值即可。
- 注意上面的环形代码是接着主程序写的片段，`f1`、`f2` 需要自行按二维数组定义好，`n`、`a`、`p` 沿用前面的定义。

## 复杂度分析

- 基础（线性）版本：状态数 $O(n^2)$，每个状态枚举分割点 $O(n)$，故时间复杂度 $O(n^3)$，空间复杂度 $O(n^2)$。
- 环形版本：链长变为 $2n$，复杂度为 $O((2n)^3)$ 量级，仍是 $O(n^3)$；空间同样 $O((2n)^2) = O(n^2)$ 量级。
- 若转移满足四边形不等式，可用四边形不等式优化把 $O(n^3)$ 降到 $O(n^2)$，但基础版 $n$ 小的时候够用了。

## 适用场景

- 一排 / 一圈元素的**合并类**问题：石子合并、能量项链等。
- 答案能写成「大区间由两个子区间拼出来」的最优化问题，最后一步可作为分割点。
- 环形版本：需要跨越首尾合并的场景，用「破环为链 + 枚举长度 $n$ 的窗口」处理。

## 常见陷阱与注意事项

1. **分割点取值范围**：`k` 取 $l \sim r-1$，不能取到 `r`（否则 `[r+1, r]` 是空区间）。
2. **转移方向**：必须按长度 `d` 递增枚举，先算短区间，否则用到的是没算过的 `f`。
3. **初值**：`f[i][i]` 要正确初始化（本题为 0），其余初值用 `INF`（求最小）或 0（求最大），弄反会出错。
4. **环形漏解**：环形问题直接套线性 DP 会漏掉跨过首尾的合并，务必先破环为链。
5. **数组开倍**：破环为链时数组要开到 `2n`，枚举上界也都要同步改成 `2n`。$AKB82$, '动态规划', array['区间DP', '动态规划', '石子合并', '破环为链', '前缀和', '枚举分割点'], 'col-dp-interval-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-interval-stone-merge', '区间DP — 环形石子合并（区间DP入门经典）', $AKB83$## 算法原理

### 什么是区间 DP

区间 DP 是动态规划的一个重要分支，核心特征是：

- 在一个**区间** $[l, r]$ 上定义状态；
- 大区间的答案由若干个**小区间**合并而来；
- 计算顺序：**先算短区间，再算长区间**。

典型应用场景：
- 石子合并（最小/最大代价）
- 能量项链
- 括号匹配 / 最长回文子序列
- 加分二叉树
- 多边形三角剖分

### 石子合并问题

$n$ 堆石子围成一圈，第 $i$ 堆有 $a_i$ 个石子。每次只能合并**相邻**的两堆，合并的代价为这两堆石子的数量之和。求将所有石子合并成一堆的**最小代价**和**最大代价**。

### 核心思想

合并 $[l, r]$ 这一段的最后一步，一定是把左边某段和右边某段合并到一起：

```
左边 [l, k-1]    右边 [k, r]
      \              /
       \            /
        \          /
         合并成一堆
    代价 = 左边代价 + 右边代价 + 区间总和
```

枚举分割点 $k$，取最优值。这就是区间 DP 的标准转移结构。

---

## 状态定义与转移方程

### 状态定义

| 状态 | 含义 |
|------|------|
| `mindp[len][l]` | 把从 $l$ 开始、长度为 `len` 的区间（即 $[l, l+len-1]$）合并成一堆的**最小**代价 |
| `maxdp[len][l]` | 把从 $l$ 开始、长度为 `len` 的区间合并成一堆的**最大**代价 |

> 注：也常用 `dp[l][r]` 的写法，含义相同。`[len][l]` 写法更强调"按长度递推"的顺序。

### 转移方程

枚举分割点 $k$（右区间的起点）：

$$
\text{mindp}[len][l] = \min_{k=l+1}^{l+len-1} \Big( \text{mindp}[k-l][l] + \text{mindp}[len-k+l][k] + \text{sum}(l, l+len-1) \Big)
$$

$$
\text{maxdp}[len][l] = \max_{k=l+1}^{l+len-1} \Big( \text{maxdp}[k-l][l] + \text{maxdp}[len-k+l][k] + \text{sum}(l, l+len-1) \Big)
$$

其中：

- `mindp[k-l][l]`：左半段 $[l, k-1]$ 的代价，长度为 $k-l$
- `mindp[len-k+l][k]`：右半段 $[k, l+len-1]$ 的代价，长度为 $len - (k-l)$
- `sum(l, r)`：区间 $[l, r]$ 的石子总数，即本次合并的代价

### 理解"最后一步"

不管前面怎么合并，最后一步一定是把左右两大堆合并。这一步的代价是固定的（等于区间总和），所以总代价 = 左边最优 + 右边最优 + 本次合并代价。

这就是区间 DP 的"**最优子结构**"：大区间的最优解由小区间的最优解组合而来。

---

## 环形处理：断环成链

### 问题

石子是围成一圈的，首尾相邻。如果直接按线性区间 $[1, n]$ 做，会漏掉"从第 $n$ 堆和第 1 堆之间断开"的方案。

### 技巧：复制一遍数组

把数组复制一份接在后面，长度变成 $2n$：

$$
A[1], A[2], \dots, A[n], A[1], A[2], \dots, A[n]
$$

这样，原环上任意一种断开方式，都对应线性数组中一段长度为 $n$ 的连续区间：

```
原环：  1 - 2 - 3 - 4 - (回到1)
复制后：1 2 3 4 1 2 3 4

从 1 断开 → 区间 [1, 4]
从 2 断开 → 区间 [2, 5]
从 3 断开 → 区间 [3, 6]
从 4 断开 → 区间 [4, 7]
```

### 答案提取

做完 DP 后，枚举所有长度为 $n$ 的区间，取最值：

$$
\text{minans} = \min_{i=1}^{n} \text{mindp}[n][i]
$$

$$
\text{maxans} = \max_{i=1}^{n} \text{maxdp}[n][i]
$$

---

## 前缀和优化

每次合并的代价是区间总和，如果每次都遍历求和会是 $O(n)$，总复杂度变成 $O(n^4)$。

用**前缀和**预处理，可以 $O(1)$ 求区间和：

$$
\text{nsum}[i] = \sum_{j=1}^{i} A[j]
$$

$$
\text{sum}(l, r) = \text{nsum}[r] - \text{nsum}[l-1]
$$

---

## 完整算法流程

### 第一步：初始化

```
1. 读入 n 和每堆石子数 a[1..n]
2. 复制数组：a[n+1..2n] = a[1..n]
3. 计算前缀和 nsum[1..2n]
4. 初始化 DP：
   - mindp[1][i] = 0  （只有一堆，不需要合并）
   - maxdp[1][i] = 0
   - mindp[len][l] = INF  （最小值初始化为无穷大）
   - maxdp[len][l] = 0    （最大值初始化为 0）
```

### 第二步：区间 DP 转移

```
按区间长度从小到大枚举 len = 2 .. n:
    枚举左端点 l:
        枚举分割点 k（右区间起点）:
            cost = nsum[l+len-1] - nsum[l-1]   // 本次合并代价
            mindp[len][l] = min(mindp[len][l],
                                mindp[k-l][l] + mindp[len-k+l][k] + cost)
            maxdp[len][l] = max(maxdp[len][l],
                                maxdp[k-l][l] + maxdp[len-k+l][k] + cost)
```

### 第三步：提取答案

```
minans = INF, maxans = 0
枚举 i = 1 .. n:
    minans = min(minans, mindp[n][i])
    maxans = max(maxans, maxdp[n][i])
输出 minans, maxans
```

---

## 逐行代码解析

### 变量定义

```cpp
const int INF = 0x3f3f3f3f;   // 无穷大，约 1e9
vector<int> A;                 // 石子数量数组（2n 长度）
vector<vector<int>> mindp;     // 最小代价 DP 表
vector<vector<int>> maxdp;     // 最大代价 DP 表
vector<int> nsum;              // 前缀和数组
```

### 初始化

```cpp
int n;
cin >> n;
A.resize(2 * n + 1, 0);       // 开 2n，用于断环成链
nsum.resize(2 * n + 1, 0);
mindp.resize(n + 1, vector<int>(2 * n + 1, INF));   // 最小值初始化为 INF
maxdp.resize(n + 1, vector<int>(2 * n + 1, 0));     // 最大值初始化为 0

for (int i = 1; i <= n; i++)
{
    cin >> A[i];
    A[i + n] = A[i];          // 复制一遍，断环成链
}

for (int i = 1; i <= 2 * n; i++)
{
    nsum[i] = nsum[i - 1] + A[i];   // 前缀和
    mindp[1][i] = 0;                // 长度为 1，代价为 0
}
```

### DP 转移

```cpp
for (int len = 2; len <= n; len++)           // 枚举区间长度
{
    for (int l = 1; l <= 2 * n - len + 1; l++)  // 枚举左端点
    {
        for (int k = l + 1; k < l + len; k++)   // 枚举分割点
        {
            int cost = nsum[l + len - 1] - nsum[l - 1];  // 区间和 = 本次合并代价
            // 左区间：[l, k-1]，长度 k-l
            // 右区间：[k, l+len-1]，长度 len - (k-l)
            mindp[len][l] = min(mindp[len][l],
                mindp[k - l][l] + mindp[len - k + l][k] + cost);
            maxdp[len][l] = max(maxdp[len][l],
                maxdp[k - l][l] + maxdp[len - k + l][k] + cost);
        }
    }
}
```

### 提取答案

```cpp
int minarr = INF;
int maxarr = 0;
for (int i = 1; i <= n; i++)
{
    minarr = min(minarr, mindp[n][i]);   // 枚举所有可能的断开点
    maxarr = max(maxarr, maxdp[n][i]);
}
cout << minarr << endl << maxarr;
```

### 关键变量对照表

| 变量 | 含义 |
|------|------|
| `len` | 当前处理的区间长度 |
| `l` | 区间左端点 |
| `k` | 分割点，右区间的起点 |
| `k - l` | 左区间长度 |
| `len - k + l` | 右区间长度 |
| `nsum[l + len - 1] - nsum[l - 1]` | 区间和 = 本次合并代价 |

---

## 复杂度分析

### 时间复杂度

三层循环：
- 外层枚举长度：$O(n)$
- 中层枚举左端点：$O(n)$
- 内层枚举分割点：$O(n)$

总时间复杂度：

$$
O(n^3)
$$

对于 $n \le 100$ 完全没问题，$n \le 300$ 也能过。如果 $n$ 更大（如 1000+），需要用四边形不等式优化到 $O(n^2)$。

### 空间复杂度

DP 表是 $(n+1) \times (2n+1)$，空间复杂度：

$$
O(n^2)
$$

---

## 适用场景

1. **区间合并类问题**：石子合并、能量项链
2. **区间最优决策**：加分二叉树、多边形三角剖分
3. **回文/括号类**：最长回文子序列、括号匹配
4. **环形问题**：通过"断环成链"技巧转化为线性区间 DP

---

## 常见陷阱与注意事项

### 1. 长度从 2 开始枚举

长度为 1 的区间不需要合并，代价为 0，是初始条件。DP 从 `len = 2` 开始。

### 2. 分割点不能等于右端点

分割点 $k$ 的范围是 $l+1 \le k < l+len$，不能取到 $l+len$（否则右区间为空，没有意义）。

### 3. 环形数组要开 2n

数组 `A`、前缀和 `nsum`、DP 表都要考虑 $2n$ 的长度。只开 $n$ 会越界。

### 4. 答案不是 mindp[n][1]

环形问题要枚举所有长度为 $n$ 的区间取最值，不能直接用 `mindp[n][1]`。这是最容易犯的错误。

### 5. 最小值要初始化为 INF

`mindp` 必须初始化为一个足够大的值（如 `0x3f3f3f3f`），然后再用 `min` 更新。如果初始化为 0，永远取不出最小值。

### 6. 最大值的初始化要小心

如果石子重量**全为正**，`maxdp` 初始化为 0 没问题（因为每次合并都是加正数）。

但如果石子可能为**负数**，`maxdp` 必须初始化为 `-INF`，否则会被 0 卡住，取不到正确的负数值。

### 7. 数据类型

当 $n = 100$、每堆 $100$ 时，总代价约 $100 \times 100 \times 100 = 10^6$，`int` 够。但当 $n$ 更大或石子更大时，要考虑 `long long`。

### 8. 下标从 1 开始

前缀和和区间 DP 用 1-based 下标最方便，`nsum[0] = 0`，区间 $[l, r]$ 的和直接是 `nsum[r] - nsum[l-1]`。

### 9. 转移时两边都要用同一种 DP

求最小值就两边都用 `mindp`，求最大值就两边都用 `maxdp`。不要写混了（比如最小值里不小心用了 maxdp）。

### 10. 区间 DP 的两种扩展技巧

**端点相等优化（涂色 P4170）**：当区间两端相等 $s[l]=s[r]$ 时，涂 $[l,r]$ 可以复用某次涂色，直接由去掉一端的区间转移，省去分割点枚举：

```
若 s[l] == s[r]:
    f[l][r] = min(f[l][r-1], f[l+1][r])
```

单格区间初始化为 $1$（涂一格至少一次）。这里没有"分割点 + 代价"的结构，而是靠"两端相等就合并处理"降维，比通用 $O(n^3)$ 模板更简洁。

**双状态设计（合成 P3146）**：一个状态表不够用时拆成两个：`dp[l][r]` 存"能否合成"（bool），`f[l][r]` 存"合成出的最大数字"。能否合成只决定区间能否整体合并，最大数字则参与后续合并取最优，二者语义不同、各司其职。

---

## 区间 DP 的通用模板

### 线性版

```cpp
for (int len = 2; len <= n; len++) {
    for (int l = 1; l + len - 1 <= n; l++) {
        int r = l + len - 1;
        dp[l][r] = INF;
        for (int k = l; k < r; k++) {
            dp[l][r] = min(dp[l][r],
                dp[l][k] + dp[k + 1][r] + cost(l, r));
        }
    }
}
```

### 环形版

```cpp
// 断环成链：a[i+n] = a[i]
for (int len = 2; len <= n; len++) {
    for (int l = 1; l + len - 1 <= 2 * n; l++) {
        int r = l + len - 1;
        for (int k = l; k < r; k++) {
            dp[l][r] = min(dp[l][r],
                dp[l][k] + dp[k + 1][r] + cost(l, r));
        }
    }
}
// 答案：枚举 i=1..n 的 dp[i][i+n-1] 取最值
```

---

## 记忆口诀

> **定状态，按长度；**
> **找分割，加代价；**
> **环复制，取最值；**
> **先小区间，再大区间。**$AKB83$, '动态规划', array['区间DP', '动态规划', '石子合并', '环形DP', '断环成链', '前缀和'], 'col-dp-interval-overview', null, 'knowledge'),
('Xesir', 'col-dp-interval-synthesis--xesir', '区间DP — 合成问题 · Xesir', $AKB84$## 算法原理

> 给定一行数字，每次可以选择两个相邻且相同的数字 x，将它们合并成一个数字 x+1。问最终能得到的最大数字是多少。详见洛谷 P3146

这题看起来像石子合并的变种，但合并条件是「**相等且相邻**」，而且不是求代价，而是求**能合成的最大值**。

**状态设计**：需要两个数组：

- `dp[l][r]` 表示区间 `[l, r]` **能否被完全合成一个数字**，如果能，合成出来的数字是多少（否则为 0）。
- `f[l][r]` 表示区间 `[l, r]` 内**能得到的最大数字**（不一定完全合成一个）。

**转移**：

- 枚举分割点 `k`，如果 `dp[l][k]` 和 `dp[k+1][r]` 都非零且相等，那么 `dp[l][r] = dp[l][k] + 1`（因为两个 `x` 合成 `x+1`）。
- 同时，`f[l][r]` 要取所有子区间 `f[l][k]`、`f[k+1][r]` 以及 `dp[l][r]` 的最大值（因为不一定要完全合成，可以留一部分不合并）。

**初始化**：`dp[i][i] = f[i][i] = a[i]`（单个数字就是它自己）。
**最终答案**：`f[1][n]`。

代码里用 `dp` 存合成结果，用 `f` 存最大值，注意如果 `dp[l][k] == dp[k+1][r]` 才能合成，否则不能。

## 核心公式 / 状态定义与转移方程

$$
dp[l][r] =
\begin{cases}
dp[l][k] + 1, & dp[l][k] \neq 0 \ \text{且}\ dp[l][k] = dp[k+1][r] \\
0, & \text{否则}
\end{cases}
$$

$$
f[l][r] = \max\Big( \max_{l \le k < r} f[l][k],\ \max_{l \le k < r} f[k+1][r],\ dp[l][r] \Big)
$$

其中 `dp[l][r]` 非零时代表整个区间能被合成出的那个数字，`f[l][r]` 则允许区间内部留一部分不合并。

## 逐行代码解析

### 模块一：初始化

```cpp
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i][i]=a[i];dp[i][i]=a[i];}
```

- 单个数字区间 `[i, i]` 能「完全合成」成它自己，所以 `dp[i][i] = f[i][i] = a[i]`。
- 注意 `dp[i][i]` 非零是有意义的：它表示这个区间可以作为左右合并的一块。

### 模块二：合并转移

```cpp
            for(int k=l;k<r;k++){
                f[l][r]=max({f[l][k],f[k+1][r],f[l][r]});
                if(dp[l][k]!=0&&dp[l][k]==dp[k+1][r]){
                    if(dp[l][k]+1>dp[l][r]) dp[l][r]=dp[l][k]+1;
                }
            }
```

- `f[l][r] = max({f[l][k], f[k+1][r], f[l][r]})`：继承两个子区间的最大值（不完全合并的情况）。
- 当左右两块都能完全合成、且合成值相等时，它们才能拼成 `dp[l][k] + 1`，更新到 `dp[l][r]`。
- 用 `if(...>dp[l][r])` 而不是直接赋值，是为了保留多个分割点里更大的合成值。

### 模块三：把合成结果并入最大值并输出

```cpp
            if (dp[l][r]!=0) {
                f[l][r]=max(f[l][r],dp[l][r]);
            }
        }
    }
    cout<<f[1][n];
```

- `dp[l][r]` 非零时（整个区间能被合成一个数），它也是区间内能得到的数字之一，并入 `f[l][r]`。
- 最终答案是 `f[1][n]`——整个序列能得到的最大数字。

## 复杂度分析

- 时间复杂度：状态数 $O(n^2)$，每个状态枚举分割点 $O(n)$，共 $O(n^3)$。
- 空间复杂度：两张二维数组 `dp`、`f`，共 $O(n^2)$。

## 适用场景

- 序列上「**相邻相等则合并 / 消除**」类问题，且目标是最大 / 最少等最值。
- 需要同时区分「整个区间能否合成一个整体」和「区间内部分能取到的最大收益」的场景，这正是 `dp` 与 `f` 分工的典型用法。

## 常见陷阱与注意事项

1. **两个数组别混用**：`dp` 只管「整个区间合成为一个数」的结果（0 表示合不成），`f` 管「区间内最大数字」，二者含义不同。
2. **判断条件**：必须 `dp[l][k] != 0 && dp[l][k] == dp[k+1][r]` 两个条件同时成立才能合并（非零 + 相等）。
3. **`f` 的合并时机**：`f` 要在每个 `k` 上继承子区间的最大值，最后再把 `dp[l][r]` 并进来，两者顺序不要漏。
4. **初值语义**：`dp[i][i] = a[i]`，用 0 表示「合不成」是本题的约定，注意与真实数字 0 无关（输入均为正数）。
5. **遍历顺序**：仍按长度 `d` 从小到大递推。$AKB84$, '动态规划', array['区间DP', '动态规划', '合成', '洛谷P3146', '枚举分割点'], 'col-dp-interval-overview', null, 'knowledge'),
('stripe-python', 'col-dp-knapsack-overview--stripe-python', '背包 DP 综述 · stripe-python', $AKB85$> 本文由 stripe-python 授权合并，保留原文结构与表述。
之前打 ABC 发现自己背包掌握的不是很熟练，所以写这一篇复习笔记。

## 基本模型

有 $n$ 种物品和一个容量为 $m$ 的背包，每种物品有重量 $w_i$ 与价值 $v_i$ 两种属性，要求选若干个物品，使它们的重量之和 $\le m$ 且 $\sum v$ 最大。

各种背包都是在这个模型下的。

## 01 背包

**每种物品有且仅有一个。**

设 $dp_{i, j}$ 表示前 $i$ 种物品，容量为 $j$ 的背包最大价值。

则

$dp_{i, j}=\max(dp_{i-1,j}, dp_{i-1,j-w_i}+v_i)$这里的两种选择对应选 / 不选第 $i$ 种物品。

可以滚动数组优化。内层循环需要 $j$ 从 $m$ 逆向枚举到 $w_i$，防止 $dp_j$ 被 $dp_{j-w_i}$ 影响。

如此，时间 $O(nm)$，空间 $O(m)$。

## P2871 [USACO07DEC] Charm Bracelet S

板子一个。代码如下：

```cpp
const int N = 13000;
int n, m, w[N], v[N], dp[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	cout << dp[m];
}
```

## P1855 榨取kkksc03

这题与普通背包的区别在于一种物品有两个体积，在 $dp$ 数组中多开一维即可。

```cpp
const int N = 205;
int n, m1, m2, w1[N], w2[N], dp[N][N];

void _main() {
	cin >> n >> m1 >> m2;
	for (int i = 1; i <= n; i++) cin >> w1[i] >> w2[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m1; j >= w1[i]; j--) {
			for (int k = m2; k >= w2[i]; k--) dp[j][k] = max(dp[j][k], dp[j - w1[i]][k - w2[i]] + 1);
		}
	}
	cout << dp[m1][m2];
}
```

## P1802 5 倍经验日

01 背包简单变形。仍然沿用 $dp$ 状态，则

$dp_j=\max(dp_j+lose_i,dp_{j-use_i}+win_i)$注意 $j < use_i$ 时第二个转移无法进行。

```cpp
const int N = 1e3 + 5;
int n, m, v1[N], v2[N], w[N], dp[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v2[i] >> v1[i] >> w[i];
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= 0; j--) dp[j] = max(dp[j] + v2[i], j < w[i] ? 0 : dp[j - w[i]] + v1[i]);
	}
	cout << 5LL * dp[m];
}
```

## [ABC390E] Vitamin Balance

三种 $V_i$ 分开跑 01 背包，暴力枚举两种 $V_i$ 所占的体积，合并答案即可。复杂度 $O(nx+n^2)$。

```cpp
const int N = 5005;

int n, x, opt;
int n1, n2, n3;
struct node {
	int v, w;
} a1[N], a2[N], a3[N];
int dp1[N], dp2[N], dp3[N];

void backpack01(node* a, int n, int* dp) {
	for (int i = 1; i <= n; i++) {
		for (int j = x; j >= a[i].w; j--) dp[j] = max(dp[j], dp[j - a[i].w] + a[i].v);
	}
}

void _main() {
	cin >> n >> x;
	for (int i = 1; i <= n; i++) {
		cin >> opt;
		if (opt == 1) n1++, cin >> a1[n1].v >> a1[n1].w;
		if (opt == 2) n2++, cin >> a2[n2].v >> a2[n2].w;
		if (opt == 3) n3++, cin >> a3[n3].v >> a3[n3].w;
	}
	backpack01(a1, n1, dp1);
	backpack01(a2, n2, dp2);
	backpack01(a3, n3, dp3);
	int res = 0;
	for (int i = 1; i <= x; i++) {
		for (int j = 1; j <= x; j++) {
			int k = x - i - j;
			if (k < 0) continue;
			res = max(res, min(dp1[i], min(dp2[j], dp3[k])));
		}
	}
	cout << res;
}
```

## P2340 [USACO03FALL] Cow Exhibition G

把智商当体积，情商当价值，跑完 01 背包合并答案即可。为了处理负数，进行一个数组漂移的 trick。

```cpp
const int N = 1e5;

int n, w[500], v[500], dp[(N << 2) + 5];

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	memset(dp, 0xcf, sizeof(dp));
	dp[N] = 0;
	for (int i = 1; i <= n; i++) {
		if (w[i] >= 0)
			for (int j = (N << 1); j >= w[i]; j--) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
		else    // 负数要逆向转移，改成正数以后正序枚举
			for (int j = 0; j <= (N << 1) + w[i]; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	int res = 0;
	for (int i = N; i <= (N << 1); i++) {
		if (dp[i] >= 0) res = max(res, i - N + dp[i]);
	}
	cout << res;
}
```

## P2946 [USACO09MAR] Cow Frisbee Team S

背包经典变式。

模 $m$ 同余类的背包问题，一般设 $dp_{i,j}$ 表示前 $i$ 种物品，总价值模 $m$ 等于 $j$。这里 $dp_{i,j}$ 表示方案数。

那么有转移

$dp_{i,j}=dp_{i-1,j}+dp_{i-1,(j-w_i)\bmod m}$会发现其实和普通 01 背包的区别就是多模了个 $m$。一年前写的代码：

```cpp
const int mod = 1e8;
int n, k, a[N], dp[N][N];

void _main() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) dp[i][a[i] % k] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = 0; j < k; j++) {
			dp[i][j] = (dp[i][j] + dp[i - 1][j]) % mod;
			dp[i][j] = (dp[i][j] + dp[i - 1][(j - a[i] % k + k) % k]) % mod;
		}
	}
	cout << dp[n][0];
	return 0;
}
```

## P4141 消失之物

直接跑背包计数，复杂度是 $O(n^2m)$ 的。正解用到背包的撤销 trick。

作转移 $dp_j \gets dp_j+dp_{j-w_i}$ 时，我们加入了物品 $i$。那么删去物品 $i$ 就是作 $dp_j \gets dp_j-dp_{j-w_i}$。代码如下。

```cpp
const int N = 2005;
int n, m, w[N], dp1[N], dp2[N];

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> w[i];
	dp1[0] = 1;
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= w[i]; j--) {
			dp1[j] += dp1[j - w[i]];
			dp1[j] %= 10;
		}
	}
	for (int i = 1; i <= n; i++) {
		memcpy(dp2, dp1, sizeof(dp1));
		for (int j = w[i]; j <= m; j++) {
			dp2[j] -= dp2[j - w[i]];
			dp2[j] = (dp2[j] + 10) % 10;
		}
		for (int j = 1; j <= m; j++) cout << dp2[j];
		cout << '\n';
	}
	return 0;
}
```

## HDU 2639 Bone Collector II

01 背包，$k$ 优解问题。

考虑多加一维，令 $dp_{i,j,k}$ 表示前 $i$ 种物品，容量为 $j$ 的背包第 $k$ 大价值。转移时，要求合并 $dp_{i-1,j}$ 与 $dp_{i-1,j-w_i}+v_i$ 两个递减序列，取前 $k$ 大值。这里可以使用某些数据结构或双指针法。这样做时间 $O(nmk)$，空间 $O(mk)$。

## 完全背包

**每种物品有无数个。**

仍然设 $dp_{i, j}$ 表示前 $i$ 种物品，容量为 $j$ 的背包最大价值。

则

$dp_{i, j}=\max(dp_{i-1,j}, dp_{i,j-w_i}+v_i)$这个转移成立的理由是，$dp_{i,j-w_i}$ 已经被 $dp_{i,j-kw_i}$ 所更新过，其中 $k$ 是不小于 $2$ 的整数。因此，我们取 $\max$ 的时候已经考虑了当前物品取 $[1,k]$ 个的情况。

继续滚动数组优化。注意到将 01 背包的内层循环改为正向枚举，即可让 $dp_{j}$ 被 $dp_{j-kw_i}$ 更新。

仍然时间 $O(nm)$，空间 $O(m)$。

## P1616 疯狂的采药

板子 +1，代码如下：

```cpp
const int N = 1e7 + 5;

long long n, m, w[N], v[N], dp[N];

void _main() {
	cin >> m >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i];
	for (int i = 1; i <= n; i++) {
		for (int j = w[i]; j <= m; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
	}
	cout << dp[m];
}
```

## P1853 投资的最大效益

比较裸的多测完全背包。注意到 $a$ 是 $1000$ 的倍数，可以优化一下。

```cpp
const int N = 1e6 + 5;
int m, y, n, w[50], v[50], dp[N];

void _main() {
	cin >> m >> y >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i], w[i] /= 1000;
	long long cur = m;
	while (y--) {
		memset(dp, 0, sizeof(dp));
		int m1 = cur / 1000;
		for (int i = 1; i <= n; i++) {
			for (int j = w[i]; j <= m1; j++) dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
		}
		cur += dp[m1];
	}
	cout << cur;
}
```

## 多重背包

**每种物品有 $c_i$ 个。**

一个朴素的想法是把第 $i$ 种物品拆分成 $c_i$ 种只有一个的物品，跑 01 背包。复杂度为 $O(m\sum c_i)$，显然喜提 TLE。

经典的优化是二进制分组。对一个数字 $c_i$，把它按二进制拆成 $c_i = \sum 2^d$，那么若干个 $2^d$ 的和可以表示 $[0,c_i]$ 的任意数字，证明使用二进制显然。这样做的复杂度为 $O(m \sum \log c_i)$。

不过这样做近似等于 $O(nm \log V)$，有没有什么更快的方法呢？

有的兄弟，有的。回归朴素思想的转移式：

$dp_{i,j}=\max_{k=0}^{c_i} (dp_{i-1,j-kw_i}+kv_i)$注意到，$dp_{i,j}$ 的有效转移 $dp_{i-1,j-kw_i}$ 满足 $j \equiv j-kw_i \pmod {c_i}$，这启示我们把总容量 $m$ 拆成模 $c_i$ 同余类。此时，$dp_{i,j'}$ 由 $dp_{i,j''}, j'' \in [0,j')$ 转移而来，可以使用单调队列优化。复杂度为 $O(n\sum c_i \sum \dfrac{m}{c_i})=O(nm)$。

## P1776 宝物筛选

板子 +2。给出两种方法的代码：

```cpp
const int N = 1e6 + 5;

int n, m, w[N], v[N], c[N];
int n1, w1[N], v1[N], dp[N];  // 拆完的

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v[i] >> w[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= c[i]; j <<= 1) w1[++n1] = w[i] * j, v1[n1] = v[i] * j, c[i] -= j;
		if (c[i]) w1[++n1] = w[i] * c[i], v1[n1] = v[i] * c[i];
	}
	for (int i = 1; i <= n1; i++) {
		for (int j = m; j >= w1[i]; j--) dp[j] = max(dp[j], dp[j - w1[i]] + v1[i]);
	}
	cout << dp[m];
}
```

```cpp
const int N = 1e6 + 5;

int n, m, w[N], v[N], c[N];
int head, tail, q[N];
int dp[N], dp1[N]; // dp1用于暂存dp的值

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> v[i] >> w[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		memcpy(dp1, dp, sizeof(dp));
		for (int j = 0; j < w[i]; j++) {
			head = tail = 0;
			for (int k = j; k <= m; k += w[i]) {
				if (head < tail && q[head] < k - w[i] * c[i]) head++;
				if (head < tail) dp[k] = max(dp1[k], dp1[q[head]] + (k - q[head]) / w[i] * v[i]);
				while (head < tail && dp1[k] >= dp1[q[tail - 1]] + (k - q[tail - 1]) / w[i] * v[i]) tail--;
				q[tail++] = k;
			}
		}
	}
	cout << dp[m];
}
```

## P1782 旅行商的背包

前面是多重背包板子，后面注意到 $m \le 5$，直接枚举体积跑 01 背包，两种背包合并答案即可。

这怎么不算混合背包呢

```cpp
const int N = 1e5 + 5;

#define int long long
int n, m, w[N], v[N], c[N];
int n1, w1[N], v1[N], dp[N];
int nn, A[10], B[10], C[10];

void _main() {
	cin >> n >> nn >> m;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i] >> c[i];
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= c[i]; j <<= 1) w1[++n1] = w[i] * j, v1[n1] = v[i] * j, c[i] -= j;
		if (c[i]) w1[++n1] = w[i] * c[i], v1[n1] = v[i] * c[i];
	}
	for (int i = 1; i <= n1; i++) {
		for (int j = m; j >= w1[i]; j--) dp[j] = max(dp[j], dp[j - w1[i]] + v1[i]);
	}

	for (int i = 1; i <= nn; i++) cin >> A[i] >> B[i] >> C[i];
	for (int i = 1; i <= nn; i++) {
		for (int j = m; j >= 1; j--) {
			for (int k = 0; k <= j; k++) dp[j] = max(dp[j], dp[j - k] + A[i] * k * k + B[i] * k + C[i]);
		}
	}
	cout << dp[m];
}
```

## P2347 [NOIP1996 提高组] 砝码称重

这是一道多重背包的可行性问题。事实上，背包可行性问题的判断适用 `bitset` 优化，且代码更为简单。

用 `bitset<N> s` 压位记录状态，第 $i$ 位表示 $i$ 能否取到，那么取 $w_i$ 的值即为 `s << w[i]`，所以转移为 `s |= s << w[i]`。

```cpp
const int N = 1005;
int a[8], w[8] = {1, 2, 3, 5, 10, 20};
bitset<N> s;

void _main() {
	for (int i = 0; i < 6; i++) cin >> a[i];
	s[0] = 1;
	for (int i = 0; i < 6; i++) {
		for (int j = 0; j < a[i]; j++) s |= s << w[i];
	}
	cout << "Total=" << s.count() - 1;
}
```

## 分组背包

**每种物品属于一个组，每组只能选一种。**

思考一下与普通背包的差别，从所有物品中选变成从每组中选，所以对每组跑背包即可。复杂度多乘上一个组数。

## P1757 通天之分组背包

板子 +3。更远古的代码：

```cpp
#include <bits/stdc++.h>
#define N 1005
using namespace std;

namespace BackpackGroup {
	int s, n, w[N], v[N], g[N], cnt[N * N], f[N][N], dp[N];

	int backpack() {
		int y = *max_element(g + 1, g + n + 1);
		for (int i = 1; i <= n; i++) f[g[i]][++cnt[g[i]]] = i;
		for (int k = 1; k <= y; k++) {
			for (int j = s; j >= 0; j--) {
				for (int i = 1; i <= cnt[k]; i++) {
					int idx = f[k][i];
					if (j >= w[idx]) dp[j] = max(dp[j], dp[j - w[idx]] + v[idx]);
				}
			}
		}
		return dp[s];
	}
}
using namespace BackpackGroup;  // 当时的逆天namespace马蜂

signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr);
	cin >> s >> n;
	for (int i = 1; i <= n; i++) cin >> w[i] >> v[i] >> g[i];
	cout << backpack();
	return 0;
}
```

## P5322 [BJOI2019] 排兵布阵

这题真正难的地方不是背包，而是转化。

把城堡看作物品，兵力看作体积，转换为背包模型。贪心地，对于每个城堡，若兵力 $x>y$ 且能打赢 $x$，那就一定能打赢 $y$。于是将输入的数组转置并排序。这时我们发现这已经被转化为分组背包。

```cpp
const int N = 105;

int s, n, m, a[N][N], dp[20005];

void _main() {
	cin >> s >> n >> m;
	for (int i = 1; i <= s; i++) {
		for (int j = 1; j <= n; j++) cin >> a[j][i];
	}
	for (int i = 1; i <= n; i++) sort(a[i] + 1, a[i] + s + 1);
	for (int i = 1; i <= n; i++) {
		for (int j = m; j >= 0; j--) {
			for (int k = 1; k <= s; k++) {
				dp[j] = max(dp[j], j - 2 * a[i][k] - 1 < 0 ? 0 : dp[j - 2 * a[i][k] - 1] + k * i);
			}
		}
	}
	cout << dp[m];
}
```$AKB85$, '动态规划', array['背包', '01背包', '完全背包', '多重背包', '分组背包'], null, null, 'knowledge'),
('world-needs-sunday', 'col-dp-knapsack-topk', '01 背包前 k 大解', $AKB86$## 算法原理

**问题模型**：$m$ 个物品，第 $i$ 个重量 $v_i$、价值 $w_i$（本代码命名：`v`=重量、`w`=价值），背包容量 $n$。求所有可行方案中价值**前 $k$ 大**的价值总和，返回所有前 $k$ 大价值之和。

**朴素 01 背包为什么不够**：`dp[j]` 只存容量 $j$ 的最大价值，转移 `dp[j]=max(dp[j], dp[j-w]+v)` 把另一路候选直接丢掉——丢掉之后就再也恢复不出次优解。核心改动：**把「一个数」扩展成「前 $k$ 个有序数」**：$dp[j][0..k-1]$ 按价值从大到小存前 $k$ 个，未满的位置用 $-\infty$（LLONG_MIN）占位，不变式是**有效值占据前缀 $[0,t)$、之后全 $-\infty$**。

**转移：两路归并**。考虑物品 $i$、容量 $j$，可行解按「是否包含 $i$」分成两类（穷尽且不重叠）：路线 A（不选）= 旧 `dp[j]` 的前 $k$ 大，自身有序；路线 B（选）= 旧 `dp[j-v_i]` 前 $k$ 大整体加 $w_i$。每路内部有序（B 路全体加同一个常数不改变顺序，$x\ge y\Rightarrow x+w_i\ge y+w_i$），所以整体前 $k$ 大必在「两路各前 $k$ 大」的并集里——**每路取超过 $k$ 个没有意义**（第 $k+1$ 个前面至少有 $k$ 个不小于它、进不了整体前 $k$）。双指针各指向两路队首，每轮取较大者，$k$ 次（或双方耗尽）即得新前 $k$ 大。

**正确性（归纳）**：假设考虑前 $i-1$ 件时每个容量都保存正确的前 $k$ 大；不选 $i$ 的解对应 $\{i-1, j\}$ 的前 $k$ 大（路线 A）；选 $i$ 的解去掉 $i$ 后重量 $\le j-v_i$，对应 $dp[j-v_i]$ 的前 $k$ 大整体加 $w_i$（路线 B）。两路并集覆盖全部候选，归并取前 $k$ 不遗漏。

**本代码是「恰好装满」语义**：只有 `dp[0][0]=0`，其余全部 $-\infty$——只有恰好装满容量 $j$ 的方案会进入 $dp[j]$。这也是为什么 `dp[0][0]=0` 后容量 0 只有价值 0 这一个解。若要「不超过容量」语义，需改为每个 $dp[j][0]=0$ 打底（见陷阱 6）。

**下标安全的直觉**：归并不变量 $l+r=idx$（初始 0=0；每轮取一个就 `idx++` 且恰好一个指针 `++`），循环条件 `idx<k` 在 C++ `&&` 短路下先判为真才去访问 `dp[...][l]` 与 `dp[j][r]`，此时 $l\le idx<k$、$r\le idx<k$——所以不需要额外写 `l<k && r<k` 的冗余防御。

**写回不残留旧值**：设旧有效前缀长 $t$、B 路有效长 $s$，归并得到 $idx=\min(k,\ t+s)\ge t$（路线 A 把旧前缀全部带进候选）；写回 $[0,idx)$ 已覆盖旧前缀，`[idx,k)` 因为 $idx\ge t$ 本来就是 $-\infty$，不变式保持。

## 核心公式 / 状态定义与转移方程

**状态定义**：

$$dp[j][r]=\text{容量为 }j\text{ 时全部可行方案价值第 }r{+}1\text{ 大（}r=0..k{-}1\text{）};\quad \text{未满用 }-\infty\text{ 占位}$$

**初始化**（恰好装满语义）：$dp[0][0]=0$，其余 $dp[j][r]=-\infty$。

**转移**（对每个物品 $i$、容量 $j$ 倒序）：

$$dp[j] = \text{merge\_topk}\big(\underbrace{dp[j]}_{\text{路线A}},\ \underbrace{dp[j-v_i]\ \text{整体加}\ w_i}_{\text{路线B}}\big)$$

其中 `merge_topk(A, B)` 即双指针归并：`l` 指向 B 路、`r` 指向 A 路，

$$tmp[idx] = \max\big(dp[j-v_i][l]+w_i,\ dp[j][r]\big),\qquad l+r=idx$$

**答案**：

$$\text{sum}=\sum_{r=0}^{k-1}\big[\ dp[n][r]\ne-\infty\ \big]\,dp[n][r]$$

**手算走读**（$k=2$，容量 $n=5$，物品 $(2,4),(3,5),(5,9)$，本代码实测输出 18）：
- 初始：$dp[0]=[0,-\infty]$，其余全 $-\infty$。
- 物品 1 $(2,4)$：$dp[2]$ 归并 = A 全 $-\infty$、B=$dp[0]+4=[4]$ → $dp[2]=[4,-\infty]$。
- 物品 2 $(3,5)$：$dp[5]$ 归并 = A 全 $-\infty$、B=$dp[2]+5=[9]$ → $dp[5]=[9,-\infty]$。
- 物品 3 $(5,9)$：$dp[5]$ 归并 = A=$[9]$、B=$dp[0]+9=[9]$ → 合并得 $[9,9]$。
- $\text{sum}=9+9=18$：两种方案（$\{2,3\}$ 与 $\{5\}$）价值同为 9，本代码**不去重**，前 2 大就是两个 9。

## 逐行代码解析

代码拆成 3 个模块，按顺序拼接即完整程序。

### 模块 1 全局数组与初始化

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> v, w;
vector<vector<long long>> dp;
vector<long long> tmp;
void init(int n, int m, int k)
{
	v.assign(m + 1, 0);
	w.assign(m + 1, 0);
	dp.assign(n + 1, vector<long long>(k , LLONG_MIN));
	tmp.assign(k , 0);
	dp[0][0] = 0;
}

```

- 命名约定（与常见模板相反，本代码全篇如此）：`v` 是重量、`w` 是价值，读入 `v[i], w[i]`、转移 `dp[j - v[i]] + w[i]`，看代码时别按直觉当反了。
- `dp` 开成 `(n+1) × k`：一行就是容量 $j$ 的前 $k$ 大有序序列，全填 `LLONG_MIN` 占位；`tmp` 是归并用的临时行。
- `dp[0][0] = 0`：容量 0 恰好装满、价值 0，是全部推导的种子；其余容量留 $-\infty$ 即「恰好装满」语义。

### 模块 2 读入与双层循环归并

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n, m, k;
	cin >> k >> n >> m;
	init(n, m, k);

	for (int i = 1; i <= m; i++) cin >> v[i] >> w[i];

	for (int i = 1; i <= m; i++)
	{
		for (int j = n; j >= v[i]; j--)
		{
			int l = 0, r = 0, idx = 0;
			while (idx < k && dp[j - v[i]][l] != LLONG_MIN && dp[j][r] != LLONG_MIN)
			{
				if (dp[j - v[i]][l] + w[i] >= dp[j][r])
				{
					tmp[idx] = dp[j - v[i]][l] + w[i];
					++idx, ++l;
				}
				else
				{
					tmp[idx] = dp[j][r];
					++idx, ++r;
				}
			}

			while (idx < k && dp[j - v[i]][l] != LLONG_MIN)
			{
				tmp[idx] = dp[j - v[i]][l] + w[i];
				++idx, ++l;
			}

			while (idx < k && dp[j][r] != LLONG_MIN)
			{
				tmp[idx] = dp[j][r];
				++idx, ++r;
			}

			for (int z = 0; z < idx; z++) dp[j][z] = tmp[z];
		}
	}

	
```

- 读入顺序是 `k n m`，再 $m$ 行 `v w`（重量 价值）。
- 外层物品、内层容量**倒序**：与普通 01 背包同理，保证每件物品只用最新一轮之前的状态、至多选一次。
- 主循环条件三段 `&&` 短路：`idx < k` 先判断，再查两路的队首是否都不是 $-\infty$——队首是 $-\infty$ 即该路耗尽（有序序列前缀有效保证后面也是 $-\infty$），无须再比。
- 每轮取较大者写入 `tmp[idx]`，对应指针与 `idx` 同进：`l+r=idx` 不变式自动保证 `l,r` 永不错过 `k`、也永不超过两路有效长度（越界只可能是 $-\infty$，被条件挡掉了）。
- 两个"剩余"循环处理某一路先耗尽的情形，直接把另一路剩余值搬进 `tmp`。
- 写回只覆盖 `[0, idx)`：$idx\ge$ 旧有效前缀长 $t$，旧前缀被新前缀覆盖、其余位置本来就是 $-\infty$，无残留。

### 模块 3 求和输出

```cpp
long long sum = 0;
	for (int i = 0; i < k; i++)
	{
		if (dp[n][i] != LLONG_MIN) sum += dp[n][i];
	}
	cout << sum;

	return 0;

}
```

- 只累加 $dp[n][r]\ne LLONG_MIN$ 的项：不足 $k$ 个方案时，占位的 $-\infty$ 不计入。
- 输出答案后直接结束。

## 复杂度分析

- 状态数：`dp` 为 $(C+1)$ 行、每行 $k$ 个值，共 $O(Ck)$ 个状态（$C$ 是代码中的容量 `n`）。
- 每个物品对每个容量做一次 $O(k)$ 归并 + $O(k)$ 写回；物品数记为 $M$（代码中的 `m`），总时间 $O(MCk)$。
- 空间：`dp` 为 $(C+1)\times k$，即 $O(Ck)$；`tmp` 只是 $O(k)$ 的临时行——容量维度倒序使容量可以原地滚动，代码已经直接复用 `dp[j]`。

## 适用场景

**本模板解决**：「求前 $k$ 优解的价值和/第 $k$ 优价值」这类需要保留多个候选的背包问题——凡转移存在 `max` 丢解的地方（背包、最长路径、若干 DP），把标量状态换成有序前 $k$ 序列 + 双指针归并就是同一套路。

**适用边界**：$k$ 通常不会太大（$O(nVk)$ 随 $k$ 线性上涨）；恰好装满 vs 不超过容量要先确认题意再定初始化；需要去重的题目要在归并时跳过与上一位相等的值（此时结果可能不满 $k$ 个）。

**不适用**：$k$ 巨大（如 $k>10^5$）时复杂度失控，应转「kth 最优解」专用技巧（A* / 可持久化堆等），而非 $O(nVk)$ 暴扩状态。

## 常见陷阱与注意事项

1. **`v`/`w` 命名与直觉相反**：本代码 `v`=重量、`w`=价值；读题/复用模板时先对齐命名，否则转移式 `dp[j-v[i]]+w[i]` 会悄悄变成"价值当重量减"。
2. **恰好装满语义**：只有 `dp[0][0]=0` 其余 $-\infty$ 意味着只统计恰好装满的方案；许多题目要求「不超过容量」的最大值，此时应给每个 $dp[j][0]$ 打 0 底（初始化不同，转移不变）。
3. **$-\infty$ 必须占位**：不占位会把"无效容量"当 0 参与归并，凭空造出解。
4. **$\text{LLONG\_MIN}+w_i$ 溢出**：主循环的三段条件里先把 `dp[j - v[i]][l] != LLONG_MIN` 短路掉才做加法，顺序不能倒过来。
5. **双指针条件写反/写漏**：丢掉 `&&` 里任一路判空，`l`/`r` 会滑进 $-\infty$ 区取到垃圾值参与比较。
6. **手动加 `l<k`、`r<k` 防御**：不是错误，但冗余——`l+r=idx` 不变式下 `idx<k` 已保证下标安全；加多了反而掩盖"不变式被破坏"的真正 bug。
7. **写回整行而不是 `[0,idx)`**：会把 `tmp` 后半未初始化的旧值写进 $dp[j]$，破坏前缀有效不变式；临时数组在多轮循环中复用，残留值不可信。
8. **重复价值不去重**：两种不同方案价值相同时本代码各算一解（测试 `(2,4),(3,5),(5,9)` 输出 18 即两个 9）；题目要求去重时归并处要加「与上一个写入值相等则跳」的判断，且最后可能不足 $k$ 个。
9. **k=0 的初始化问题**：`dp` 的行长为 0，`dp[0][0]=0` 会越界；若题目允许 $k=0$，应在 `init` 之前特判输出 0，或保证 $k\ge1$。$k$ 大于总可行解数时未满部分由 $-\infty$ 挡住，不会错加。
10. **容量倒序写成正序**：会退化成完全背包（每件选无限次），前 $k$ 大序列反而把错误解也算进去。

## 对比与扩展

**与普通 01 背包**：标量 `dp[j]` 是 `k=1` 的特例；本模板的唯一增量是"状态有序化 + 双指针归并"，1 行递推换成两路各 $k$ 个候选的归并，其余（倒序、初始化、答案取法）完全同构。

**与完全/多重背包**：只要把容量循环改成正序（完全）或用二进制分组（多重），"前 $k$ 大归并"这套状态扩展原样可用——它不依赖 01 的选法限制。

**去重版（预提案 1，经确认写入）**：在每次写入 `tmp[idx]` 前判断「当前取值 == 上一次写入的值」则跳过（取另一路继续比较），最后不足 $k$ 个用 $-\infty$ 补齐；完整写清后归并复杂度不变，只是 idx 推进与指针推进不再是同一语句。

**k 的防御说明（预提案 2，经确认写入）**：$k\le0$ 时不能直接跑这套初始化——`dp` 的行长为 0，`dp[0][0]=0` 会越界；应先特判输出 0。$k$ 大于全部可行解总数时，`dp[n]` 未满部分为 $-\infty$，求和处 `!= LLONG_MIN` 过滤，答案即所有解的价值的和。$AKB86$, '动态规划', array['01背包', '前k大', '双指针归并', '动态规划', '有序序列'], 'col-dp-knapsack-overview', null, 'knowledge'),
('dbywsc', 'col-dp-linear-basic--dbywsc', '线性 DP 基础（数字三角形 / 最大子段和 / LIS） · dbywsc', $AKB87$## 算法原理

线性 DP 的状态沿序列下标（或值域）线性推进，通常定义成“以 $i$ 结尾”“前 $i$ 个”或“凑出 $i$”的形式。它是区间、树形、状压等复杂 DP 的基础。

### 数字三角形

给定一个数字三角形，从顶到底走，每次可以走到正下方或右下方，求路径最大和。

如果从上往下定义状态，最后一行有 $n$ 个终点，答案要在多个终点里取最大，处理麻烦。反过来从下往上走：设 $f_{i,j}$ 表示从 $(i,j)$ 到底部的最大路径和，则

$$
f_{i,j}=a_{i,j}+\max(f_{i+1,j},f_{i+1,j+1}).
$$

边界是最底下一行 $f_{n,i}=a_{n,i}$，答案是 $f_{1,1}$。时间复杂度 $O(n^2)$。

### 蜜蜂路线

从 $m$ 爬到 $n$ 的路线数。设 $f_i$ 为从 $m$ 到 $i$ 的方案数，则 $f_m=1$，转移为

$$
f_i=f_{i-1}+f_{i-2}.
$$

边界要处理 $f_{m-1}=0$，表示不可达。答案 $f_n$。本质是斐波那契递推。

### 斐波那契字符串

字符串由前两项拼接而成。设第 $i$ 项中 $0$ 的个数为 $c0_i$、$1$ 的个数为 $c1_i$、逆序对数为 $inv_i$，则

$$
c0_i=c0_{i-1}+c0_{i-2},\qquad
c1_i=c1_{i-1}+c1_{i-2},
$$

$$
inv_i=inv_{i-1}+inv_{i-2}+c1_{i-2}\cdot c0_{i-1}.
$$

最后一项是前两项拼接，新增逆序对来自“前一项的 $1$”与“后一项的 $0$”的配对。每一步取模。

### 最大子段和

设 $f_i$ 为以 $a_i$ 结尾的最大子段和。当前元素要么接在前一段后面，要么自己单独成段：

$$
f_i=\max(f_{i-1}+a_i,\ a_i).
$$

答案是 $\max_i f_i$，不是 $f_n$。时间复杂度 $O(n)$。

### 最长连续子序列（值域 DP）

若要求“数值连续”的最长子序列，设 $f_x$ 为以值 $x$ 结尾的最长连续子序列长度，则

$$
f_x=f_{x-1}+1.
$$

对每个 $a_i$ 更新 $f_{a_i}$，答案取所有 $f$ 的最大值。值域大时用 `std::map`。注意不能提前把所有出现的值初始化为 $1$，否则会把不连续的数错误接起来。

### 最大双子段和

要求两个不重叠子段的最大和。枚举分界点 $i$，左边取 $[1,i-1]$ 的最大子段和 $pre_{i-1}$，右边取 $[i+1,n]$ 的最大子段和 $suf_{i+1}$，答案

$$
\max_i (pre_{i-1}+suf_{i+1}).
$$

$pre_i$ 和 $suf_i$ 都可以用最大子段和的 DP 预处理，时间 $O(n)$。

### 最长上升子序列（LIS）

设 $f_i$ 为以 $a_i$ 结尾的最长上升子序列长度：

$$
f_i=1+\max_{j<i,\ a_j<a_i} f_j.
$$

答案是 $\max_i f_i$。时间复杂度 $O(n^2)$。

### LIS 的 $O(n\log n)$ 做法

维护一个数组 $f$，表示当前各长度的上升子序列末尾的最小值。遍历原数组，对每个 $x$：

- 若 $x$ 比 $f$ 中所有数都大，接在末尾，LIS 长度加一；
- 否则找到 $f$ 中第一个 $\ge x$ 的位置，把它替换成 $x$。

这样 $f$ 始终有序，可以用 `lower_bound`。替换不会影响答案长度，只是让末尾更小，给后面留更多空间。时间复杂度 $O(n\log n)$。

### 合唱队形

枚举中间最高的人 $i$，左右分别是“从 $1$ 到 $i$ 的最长上升子序列”和“从 $n$ 到 $i$ 的最长上升子序列”，总长度为两者之和减一。对每个 $i$ 取最大。

### 友好城市

把每个友好城市看成点对 $(a_i,b_i)$，按 $a_i$ 升序排序。要选最多不交叉的点对，等价于在 $b_i$ 上求 LIS。$n$ 较大时用 $O(n\log n)$ 的 LIS。

### 导弹拦截与 Dilworth 定理

第一问求最长不升子序列，可以仿照 LIS，用二分维护；注意严格下降时用 `upper_bound` 加 `greater<int>()`。

第二问求“最少用多少个不升子序列覆盖整个序列”，答案等于最长上升子序列长度，这是 **Dilworth 定理** 的一个特例。

### BFS/DP 混合：过河

设 $f_i$ 为到达 $i$ 号点的最短游泳距离，初始为极大值，$f_0=0$。若当前点是鳄鱼则不能走；否则可以从 $i-m\sim i-1$ 中跳过来（若中间有左岸或木板），也可以从 $i-1$ 游过来（若 $i-1$ 是水）。最后判断 $f_{n+1}\le k$。

### 质因数分解式 DP

设 $f_i$ 为凑出 $i$ 的最小数量，初始极大值；对原本存在的数 $f_{a_i}=1$。转移有两种：

- 枚举 $i$ 的因子 $d$：$f_i=\min(f_i,f_d+f_{i/d})$；
- 用筛法枚举倍数：$f_{i\cdot j}=\min(f_{i\cdot j},f_i+f_j)$。

前者 $O(n\sqrt n)$，后者 $O(n\log n)$。

### 多维 DP

有些问题只设一维不够，需要二维或更高维状态。典型如：

- 方格取数：两个路径同时走，状态是两维坐标；
- 最长公共子序列：$f_{i,j}$ 表示 $a$ 前 $i$ 个和 $b$ 前 $j$ 个的 LCS；
- 区间/网格上的最优决策：状态带左右端点或行列。

多维 DP 的关键仍是状态定义、边界、转移顺序和无后效性。

## 核心公式 / 状态定义与转移方程

- 数字三角形：$f_{i,j}=a_{i,j}+\max(f_{i+1,j},f_{i+1,j+1})$。
- 蜜蜂路线：$f_i=f_{i-1}+f_{i-2}$，$f_m=1,f_{m-1}=0$。
- 最大子段和：$f_i=\max(f_{i-1}+a_i,a_i)$，答案 $\max f_i$。
- 最大双子段和：$\max_i(pre_{i-1}+suf_{i+1})$。
- LIS：$f_i=1+\max_{j<i,a_j<a_i}f_j$；优化版用 `lower_bound` 维护末尾最小值。
- Dilworth：最少不升子序列覆盖数 = 最长上升子序列长度。
- LCS：$f_{i,j}=\begin{cases}f_{i-1,j-1}+1,&a_i=b_j\\ \max(f_{i-1,j},f_{i,j-1}),&a_i\ne b_j\end{cases}$。
- 记忆化与递推：两者本质相同，线性 DP 通常用递推。

## 逐行代码解析

### 数字三角形

```cpp
for (int j = 1; j <= n; j++) f[n][j] = a[n][j];
for (int i = n - 1; i >= 1; i--)
    for (int j = 1; j <= i; j++)
        f[i][j] = a[i][j] + max(f[i + 1][j], f[i + 1][j + 1]);
cout << f[1][1];
```

- 从最底层开始，边界直接赋原值。
- 从下往上递推，每个格子只依赖下一行。
- 答案是 `f[1][1]`。

### 最大子段和

```cpp
long long f = 0, ans = -INF;
for (int i = 1; i <= n; i++) {
    f = max(f + a[i], a[i]);
    ans = max(ans, f);
}
```

- `f` 是以当前元素结尾的最大子段和。
- `ans` 记录全局最大，不能只输出 `f`。
- 初始 `ans` 要足够小，处理全负数的情况。

### LIS 的 $O(n\log n)$

```cpp
vector<int> f;
for (int i = 1; i <= n; i++) {
    auto it = lower_bound(f.begin(), f.end(), a[i]);
    if (it == f.end()) f.push_back(a[i]);
    else *it = a[i];
}
cout << f.size();
```

- `f` 中第 $k$ 个元素表示长度为 $k+1$ 的上升子序列末尾的最小值。
- `lower_bound` 找第一个 $\ge a_i$ 的位置并替换；严格上升用 `lower_bound`，不下降用 `upper_bound`。
- `f.size()` 就是 LIS 长度。

### 最大双子段和

```cpp
pre[0] = suf[n + 1] = -INF;
for (int i = 1; i <= n; i++) {
    cur = max(cur + a[i], a[i]);
    pre[i] = max(pre[i - 1], cur);
}
cur = 0;
for (int i = n; i >= 1; i--) {
    cur = max(cur + a[i], a[i]);
    suf[i] = max(suf[i + 1], cur);
}
long long ans = -INF;
for (int i = 1; i <= n; i++) ans = max(ans, pre[i - 1] + suf[i + 1]);
```

- `pre[i]` 是前 $i$ 个中的最大子段和，`suf[i]` 是后 $i$ 个中的最大子段和。
- 枚举分界点 $i$，左右各取一个不重叠子段。
- 注意分界点两侧至少各有一个元素。

### LCS

```cpp
for (int i = 1; i <= n; i++)
    for (int j = 1; j <= m; j++) {
        if (a[i] == b[j]) f[i][j] = f[i - 1][j - 1] + 1;
        else f[i][j] = max(f[i - 1][j], f[i][j - 1]);
    }
```

- `f[i][j]` 表示 $a$ 前 $i$ 个与 $b$ 前 $j$ 个的 LCS 长度。
- 相等时接上；不等时从上方或左方转移。
- 时间 $O(nm)$，空间可以用滚动数组压到 $O(m)$。

## 复杂度分析

| 模型 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 数字三角形 | $O(n^2)$ | $O(n^2)$（可压到 $O(n)$） |
| 最大子段和 | $O(n)$ | $O(1)$ |
| 最大双子段和 | $O(n)$ | $O(n)$ |
| LIS（朴素） | $O(n^2)$ | $O(n)$ |
| LIS（二分） | $O(n\log n)$ | $O(n)$ |
| LCS | $O(nm)$ | $O(nm)$（可压到 $O(m)$） |
| 过河/值域 DP | $O(n\cdot m)$ 或 $O(n\log n)$ | $O(n)$ |

## 适用场景

- 状态沿下标线性推进、转移只依赖前一个/前几个状态：数字三角形、最大子段和、斐波那契类。
- 需要保留“以某个位置/值结尾”的信息：LIS、连续子序列。
- 需要前后缀合并：最大双子段和、合唱队形。
- 两个序列匹配：LCS。
- 值域较大但状态只与值有关：用 `map` 做值域 DP。
- 多维状态：方格取数、区间/网格决策。

## 常见陷阱与注意事项

1. **最大子段和答案取成 $f_n$**：`f_n` 只是以最后一个元素结尾的最大和，答案是全局最大值。
2. **LIS 的二分边界**：严格上升用 `lower_bound`，不下降用 `upper_bound`；写反会得到错误长度。
3. **LIS 的 `f` 数组不是具体方案**：它只维护每个长度的最小末尾，不能直接还原 LIS。
4. **最大双子段和的边界**：分界点两侧都要有元素；`pre[0]` / `suf[n+1]` 要设成 $-\infty$。
5. **LCS 的空间**：二维数组可能 MLE，可以滚动一维，但要注意更新顺序。
6. **值域 DP 提前初始化**：不能把所有出现的值都设成 $1$，否则会把不连续的值错误接起来。
7. **多维 DP 的转移顺序**：要保证依赖的状态已经算过；必要时倒序/按长度枚举。
8. **多测清空**：DP 数组、前缀/后缀数组在多组数据间要清空。

## 对比与扩展

- **线性 DP vs 记忆化搜索**：线性 DP 通常自底向上递推，常数小；记忆化自顶向下，适合状态顺序不明显的问题。
- **LIS 的两种做法**：$O(n^2)$ 好写、能还原方案；$O(n\log n)$ 只求长度，不能直接还原（除非额外记录）。
- **LCS vs LIS**：LCS 是二维匹配；若一个序列是排列，可以转成 LIS。
- **Dilworth 定理**：最少链覆盖 = 最长反链，导弹拦截是典型应用。
- **讲义中的多维 DP 题目**：CF2195C、LG1447 线段、CF2193F、C1030 花生采摘、LG1459 方格取数、LG1454 快速求和、P1219 最长公共子序列（弱化版）、LG1456 两个排列的最长公共子序列。题号以原讲义为准，具体题面请按题名检索。$AKB87$, '动态规划', array['线性DP', '数字三角形', '最大子段和', 'LIS', 'Dilworth', '动态规划'], 'col-dp-linear-overview', null, 'knowledge'),
('Xesir', 'col-dp-linear-edit-distance--xesir', '字符串编辑距离 · Xesir', $AKB88$## 算法原理

给定两个字符串，允许三种操作：插入一个字符、删除一个字符、替换一个字符。求将第一个串变成第二个串所需的最少操作次数（即 Levenshtein 距离）。

**状态设计**：设 `f[i][j]` 表示把 `a[1..i]` 变成 `b[1..j]` 的最少操作次数。

初始化：

- `f[i][0] = i`（删掉 a 的所有字符变成空串，需 i 次删除）；
- `f[0][j] = j`（从空串插入 j 个字符得到 b）。

转移分几种情况：

1. 如果 `a[i] == b[j]`，则 `f[i][j] = f[i-1][j-1]`（不用操作）；
2. 替换：`f[i-1][j-1] + 1`；
3. 删除（a 删一个）：`f[i-1][j] + 1`；
4. 插入（b 删一个，等价于在 a 中插入）：`f[i][j-1] + 1`。

取最小值即可。

**注意**：代码里的初始化写法是 `f[i][0]=i`、`f[0][j]=j`，然后转移时先把 `f[i][j]` 设成一个较大的数（这里是 `1e9`），再逐步取 min。

## 核心公式 / 状态定义与转移方程

$$f[i][j] = \begin{cases} f[i-1][j-1], & a[i] = b[j] \\ 1 + \min\big(f[i-1][j-1],\ f[i-1][j],\ f[i][j-1]\big), & a[i] \neq b[j] \end{cases}$$

边界条件 $f[i][0] = i$、$f[0][j] = j$，最终答案 $f[n][m]$。

## 逐行代码解析

### 头文件与 DP 表声明

```cpp
#include <bits/stdc++.h>
using namespace std;
vector<vector<int>> f(1010,vector<int>(1010,1e9));
```

- `f` 用 `vector<vector<int>>` 开成 $1010 \times 1010$，每个值先填 `1e9`（当作「无穷大」），这样转移里可以直接对 `f[i][j]` 取 min。
- 用 `1e9` 而不是 `INT_MAX`，是为了避免后续 `+1` 之后整型溢出。

### main、读入与 1 基化

```cpp
signed main()
{
    int n,m;string a,b;
    cin>>n>>a>>m>>b;
    a=" "+a;b=" "+b;
```

- 读入顺序是 `n`、`a`、`m`、`b`。
- `a=" "+a;` 在前面补一个空格，把字符串**整体挪成 1 基**，这样后面就能直接用 `a[i]`、`b[j]`，不必写 `a[i-1]`，与 `f` 的 1 基对齐。
- 入口写成 `signed main`：本文件虽没写 `#define int long long`，但 `signed main` 与 `int main` 等价，保留无害。

### 边界初始化

```cpp
    for(int i=0;i<=n;i++){
        f[i][0]=i;
    }
    for(int i=0;i<=m;i++){
        f[0][i]=i;
    }
```

- `f[i][0]=i`：把 a 的前 i 个字符全删光，代价 i。
- `f[0][i]=i`：从空串插入 i 个字符得到 b 的前 i 个字符，代价 i。
- 这两个边界不可省，否则空串相关的转换会算错。

### 核心转移与输出

```cpp
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            if(a[i]==b[j]) f[i][j]=min(f[i][j],f[i-1][j-1]);
            else f[i][j]=min(f[i][j],f[i-1][j-1]+1);
            f[i][j]=min(f[i][j],f[i-1][j]+1);
            f[i][j]=min(f[i][j],f[i][j-1]+1);
        }
    }
    cout<<f[n][m];
    return 0;
}
```

- 匹配时用对角线 `f[i-1][j-1]`（不操作）；不匹配时用 `f[i-1][j-1]+1`（替换）。
- 再分别用 `f[i-1][j]+1`（删除 a 的一个字符）与 `f[i][j-1]+1`（在 a 中插入一个字符）更新。
- 每一步都在初始的 `1e9` 基础上逐步取 min，最终 `f[n][m]` 就是最少操作数。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$，两重循环，每次 $O(1)$。
- **空间复杂度**：$O(n \times m)$，二维 `f` 表（$1010^2$ 约 4MB）。可压成两行滚动数组降到 $O(m)$。

## 适用场景

拼写检查（自动纠错）、DNA/RNA 序列比对、自然语言处理里的相似度度量、模糊字符串匹配等。凡是要「量化两个串差多少」的地方，编辑距离都是最基础的工具。

## 常见陷阱与注意事项

1. **边界初始化遗漏**：`f[i][0]=i`、`f[0][j]=j` 必须写，否则空串转换会出错。
2. **下标对齐**：本代码用 `a=" "+a` 把字符串挪成 1 基，才敢直接写 `a[i]`、`b[j]`；忘了这一步，下标就要整体减一。
3. **三种操作对应哪个邻居**：替换取对角线 `f[i-1][j-1]`，删除取上方 `f[i-1][j]`，插入取左方 `f[i][j-1]`，方向最容易混。
4. **多组数据要重置**：`f` 是一次性构造的全局对象，多组数据时要重新填回 `1e9`，否则会残留上一组的结果。
5. **初始化开销**：`vector<vector<int>>` 把 $10^6$ 个元素都填成 `1e9`，有一定常数开销。

## 对比与扩展

编辑距离与 LCS 状态结构相似，但转移逻辑相反：LCS 匹配时对角加一、不匹配取邻居最大值；编辑距离匹配时直接继承对角、不匹配取邻居最小值加一。

扩展方向：带权编辑距离（插入/删除/替换代价不同）、Damerau-Levenshtein 距离（增加「交换相邻字符」操作），以及用滚动数组把空间压到 $O(\min(n, m))$。$AKB88$, '动态规划', array['动态规划', '线性DP', '编辑距离', 'Levenshtein', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-edit-distance', '字符串编辑距离', $AKB89$## 算法原理

编辑距离（Levenshtein距离）衡量将字符串 $a$ 转换为字符串 $b$ 所需的最少单字符操作次数，允许的操作包括：插入一个字符、删除一个字符、修改一个字符。它是衡量字符串相似度的重要指标。

状态定义 $dp[i][j]$ 表示将 $a$ 的前 $i$ 个字符（$a[0..i-1]$）转换为 $b$ 的前 $j$ 个字符（$b[0..j-1]$）所需的最少操作次数。考虑最后一步操作：若 $a[i-1] = b[j-1]$（当前字符相同），则无需对最后字符做任何操作，$dp[i][j] = dp[i-1][j-1]$（直接继承上一对角线的值）。

若 $a[i-1] \neq b[j-1]$（当前字符不同），则取三种操作的最小值加 $1$：修改操作（将 $a[i-1]$ 改为 $b[j-1]$，代价 $dp[i-1][j-1] + 1$）、插入操作（在 $a$ 的末尾插入 $b[j-1]$，代价 $dp[i][j-1] + 1$）、删除操作（删除 $a[i-1]$，代价 $dp[i-1][j] + 1$）。

边界条件的含义：$dp[i][0] = i$ 表示将 $a$ 的前 $i$ 个字符全部删除变为空串需 $i$ 次操作；$dp[0][j] = j$ 表示从空串插入 $j$ 个字符得到 $b$ 的前 $j$ 个字符需 $j$ 次操作。DP表按 $i$ 从 $1$ 到 $|a|$、$j$ 从 $1$ 到 $|b|$ 的顺序填充，每个状态依赖左上、左、上三个邻居。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{将 } a[0..i-1] \text{ 转换为 } b[0..j-1] \text{ 的最少操作次数}$$

当 $a[i-1] = b[j-1]$ 时：

$$dp[i][j] = dp[i-1][j-1]$$

当 $a[i-1] \neq b[j-1]$ 时：

$$dp[i][j] = \min\big(dp[i-1][j-1],\; dp[i][j-1],\; dp[i-1][j]\big) + 1$$

边界条件：

$$dp[i][0] = i, \quad dp[0][j] = j$$

最终答案：

$$\text{ans} = dp[|a|][|b|]$$

## 逐行代码解析

### 模块一：头文件与读入

```cpp
#include<bits/stdc++.h>
using namespace std;
//字符串编辑距离就是从一个字符串修改到另一个字符串时，编辑单个字符（比如修改、插入、删除）所需要的最少次数
int main()
{
	string a,b;
	cin >> a >> b;
```

- `#include<bits/stdc++.h>` 与 `using namespace std;` 是竞赛常用写法，一次性引入全部标准库。
- `string a, b;` 声明两个字符串，字符下标从 `0` 开始。
- `cin >> a >> b` 按空白分隔读入两个原串，原串中不含空格。

### 模块二：DP 表与边界初始化

```cpp
	vector<vector<int>> dp(a.size() + 1,vector<int>(b.size() + 1 , 0));
	//边界初始化 
	for(int i = 1;i <= a.size();i++) dp[i][0] = i;//将a[0] ~ a[i]转化为空所要的次数 
	for(int j = 1;j <= b.size();j++) dp[0][j] = j;//将b[0] ~ b[j]转化为空所要的次数 
```

- `dp` 表大小为 $(|a|+1)\times(|b|+1)$，多出的第 $0$ 行/列表示空串，初值全为 $0$。
- `dp[i][0] = i`：把 $a$ 的前 $i$ 个字符全部删除变成空串需要 $i$ 次删除。
- `dp[0][j] = j`：从空串插入 $j$ 个字符得到 $b$ 的前 $j$ 个字符需要 $j$ 次插入。
- 边界初始化不可省略，否则空串相关的转换会得到错误结果。

### 模块三：状态转移（核心 DP）

```cpp
	for(int i = 1;i <= a.size();i++)
	{
		for(int j = 1;j <= b.size();j++)
		{
			if(a[i - 1] == b[j - 1]) dp[i][j] = dp[i - 1][j - 1];
			else
			{
				dp[i][j] = min({
					dp[i - 1][j - 1],/*修改操作，将A[i]与B[j]的位置改成一样*/
					dp[i][j - 1],/*插入操作，将A[i]后面加一个*/
					dp[i- 1][j],/*删除操作,将A[i]删除*/ 
				}) + 1;
			}
		}
	}
```

- 外层循环 `i` 遍历 $a$ 的每个字符（$1$ 到 $|a|$），内层循环 `j` 遍历 $b$ 的每个字符（$1$ 到 $|b|$）。
- 字符匹配：`a[i-1] == b[j-1]` 时直接继承对角线 `dp[i-1][j-1]`，无需操作。
- 字符不匹配：用 `min({...})` 取三种操作的最小值再加 $1$；`dp[i-1][j-1]` 是修改、`dp[i][j-1]` 是插入、`dp[i-1][j]` 是删除。
- 下标 `a[i-1]`、`b[j-1]` 对应 `dp[i][j]`，因为 `dp` 的第 $0$ 行/列代表空串，第 $i$ 行对应 $a$ 的前 $i$ 个字符。

### 模块四：输出结果与 main 结尾

```cpp
	cout << dp[a.size()][b.size()];
	return 0;
}
```

- `dp[a.size()][b.size()]` 即把整个 $a$ 转换为 $b$ 的最少操作次数，作为最终答案输出。
- `min({...})` 初始化列表需要 C++11 支持，也可用嵌套 `min(min(a,b),c)` 替代。
- 输出未加换行，若需多组输出建议补 `'\n'`。

## 复杂度分析

- **时间复杂度**：$O(|a| \times |b|)$。两重循环共 $|a| \times |b|$ 次状态转移，每次为 $O(1)$ 的比较和取最小值。
- **空间复杂度**：$O(|a| \times |b|)$。二维 `dp` 表。由于 $dp[i][j]$ 仅依赖第 $i-1$ 行和第 $i$ 行，可优化为 $O(|b|)$ 的滚动数组（需保留两行）。

## 适用场景

适用于拼写检查（自动纠错）、DNA序列比对、自然语言处理中的相似度计算、模糊字符串匹配等场景。当需要量化两个字符串之间的差异程度时，编辑距离是最基础的工具。

## 常见陷阱与注意事项

- **边界初始化**：`dp[i][0] = i` 和 `dp[0][j] = j` 不可省略，否则空串相关的转换会得到错误结果。
- **字符索引**：`a[i-1]` 和 `b[j-1]` 对应 $dp[i][j]$，因为 `dp` 的第 $0$ 行/列代表空串，第 $i$ 行对应 $a$ 的前 $i$ 个字符。
- **三种操作的区分**：修改对应对角线 $dp[i-1][j-1]$，插入对应左方 $dp[i][j-1]$，删除对应上方 $dp[i-1][j]$。容易混淆哪个方向对应哪种操作。
- **`min({...})` 语法**：C++ 的初始化列表 `min({a, b, c})` 需要 C++11 支持，也可用嵌套 `min(min(a,b),c)` 替代。
- **空间优化**：滚动数组优化时需注意更新顺序，避免覆盖还未使用的上一行值。

## 对比与扩展

编辑距离与LCS（最长公共子序列）在状态结构上相似，但转移逻辑不同：LCS在字符匹配时加 $1$、不匹配时取邻居最大值；编辑距离在字符匹配时继承对角线、不匹配时取邻居最小值加 $1$。编辑距离可扩展为带权编辑距离（不同操作有不同代价）、Damerau-Levenshtein距离（增加交换相邻字符的操作）等变种。空间优化可用滚动数组将空间降到 $O(\min(|a|, |b|))$。$AKB89$, '动态规划', array['动态规划', '线性DP', '编辑距离', 'Levenshtein', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('Fohen', 'col-dp-linear-lcs-length--fenfeng', '最长公共子序列长度（普通） · Fohen', $AKB90$## 算法原理

最长公共子序列（Longest Common Subsequence，LCS）问题是：给定两个字符串，求它们的最长公共子序列的长度。子序列不要求在原串中连续出现，但要求各字符保持与原串一致的相对顺序。例如字符串 `abcde` 与 `ace` 的最长公共子序列是 `ace`，长度为 $3$。

LCS 用动态规划求解的核心在于：把「第一个串的前 $i$ 个字符与第二个串的前 $j$ 个字符」作为状态，用「当前两个字符是否相等」划分情况，逐格递推得到答案。这也是 LCS 与最长公共子串最本质的区别——LCS 允许子序列在中途跳过不匹配的字符后继续，而最长公共子串要求连续。

设 `f[i][j]` 表示第一个串的前 $i$ 个字符与第二个串的前 $j$ 个字符的最长公共子序列长度。处理到字符 `a[i-1]` 与 `b[j-1]` 时（字符下标从 $0$ 开始，与 `f` 的 $1$ 基下标错位 $1$）：

- 若 `a[i-1] == b[j-1]`，这个字符可以直接接到之前的最长公共子序列后面，于是 `f[i][j] = f[i-1][j-1] + 1`。
- 若二者不等，当前字符无法同时匹配，就「跳过」其中一个：取「跳过 $a$ 的当前字符」与「跳过 $b$ 的当前字符」两种方案的较大值，即 `f[i][j] = max(f[i-1][j], f[i][j-1])`。

最终答案就是 `f[n][m]`（$n$、$m$ 分别为两个串的长度）。

## 核心公式 / 状态定义与转移方程

### 状态定义

$$
f[i][j] = \text{串 } a \text{ 的前 } i \text{ 个字符与串 } b \text{ 的前 } j \text{ 个字符的最长公共子序列长度}
$$

其中 $1 \le i \le n$，$1 \le j \le m$，$n = |a|$、$m = |b|$。

### 转移方程

$$
f[i][j] =
\begin{cases}
f[i-1][j-1] + 1, & a[i-1] = b[j-1] \\[2pt]
\max\bigl(f[i-1][j],\; f[i][j-1]\bigr), & a[i-1] \ne b[j-1]
\end{cases}
$$

### 边界条件

$$
f[0][j] = 0, \quad f[i][0] = 0
$$

第 $0$ 行与第 $0$ 列对应「空串与任意串的 LCS 长度」，恒为 $0$。全局数组默认清零，天然满足，无需显式初始化。

### 最终答案

$$
\text{ans} = f[n][m]
$$

## 逐行代码解析

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
int f[1010][1010];
signed main()
{
    int n,m;cin>>n>>m;
    string a,b;cin>>a>>b;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            f[i][j]=max(f[i-1][j],f[i][j-1]);
            if(a[i-1]==b[j-1]) f[i][j]=f[i-1][j-1]+1;
        }
    }
    cout<<f[n][m];
    return 0;
}
```

### 头文件与全局变量

- `#include <bits/stdc++.h>`：万能头文件，一次涵盖 `string`、`iostream`、`algorithm`（`max`）等所需头文件。
- `#define int long long`：把 `int` 统一替换为 `long long`，避免答案或中间值溢出；由于 `main` 的返回值类型必须是 `int`，宏替换后要写成 `signed main()`。
- `int f[1010][1010]`：DP 表。它是全局数组，开在静态区并自动清零，因此第 $0$ 行/第 $0$ 列的边界条件无需显式赋值。

### 读入

- `cin >> n >> m` 先读入两个串的长度，再 `cin >> a >> b` 读入两个串。注意：本实现要求输入先给出两个长度，与「直接读两个串」的写法不同。
- 字符串下标从 $0$ 开始，与 `f` 的 $1$ 基下标错位 $1$。

### DP 双重循环

- 外层 `i` 枚举第一个串的前缀长度（$1$ 到 $n$），内层 `j` 枚举第二个串的前缀长度（$1$ 到 $m$）。
- 先执行 `f[i][j] = max(f[i-1][j], f[i][j-1])`：无论当前字符是否相等，先取「跳过左边字符」（`f[i][j-1]`）与「跳过上边字符」（`f[i-1][j]`）的较大值。
- 再判断 `if(a[i-1]==b[j-1]) f[i][j]=f[i-1][j-1]+1`：若当前字符相等，则用「对角线 + 1」覆盖刚才的较大值。因为 `f[i-1][j-1]+1` 一定不小于 `max(f[i-1][j], f[i][j-1])`，这一步等价于标准的「相等取对角线 + 1，不等取较大值」。
- 字符下标用 `a[i-1]`、`b[j-1]` 与 `f[i][j]` 对齐：`f` 的第 $0$ 行/列代表空串，所以字符下标整体前移 $1$。

### 输出

- `cout << f[n][m]` 输出右下角 `f[n][m]`，即两个完整串的 LCS 长度。

## 复杂度分析

- **时间复杂度**：$O(nm)$。双重循环共 $n \times m$ 个状态，每个状态做 $O(1)$ 次转移。
- **空间复杂度**：$O(nm)$。二维数组 `f[1010][1010]`。由于 `f[i][j]` 只依赖第 $i-1$ 行，可优化为两行滚动数组，空间降到 $O(m)$；但二维写法更简单直观。

## 适用场景

- 求两个序列（字符串、数组等）的最长公共子序列长度，是文本比较、版本差异（diff）、生物信息学（DNA/RNA 序列比对）等领域的经典基础算法。
- 需要衡量两个序列「相似度」的场景，LCS 长度是最常用的度量之一。
- 当其中一条序列是 $1 \sim n$ 的排列时，可转化为 LIS 求解（见「对比与扩展」）。

## 常见陷阱与注意事项

- **下标错位**：字符用 `a[i-1]`、`b[j-1]`，对应 `f[i][j]`，因为 `f` 的第 $0$ 行/列表示空串。
- **边界初始化**：第 $0$ 行与第 $0$ 列必须为 $0$。全局数组自动清零；若改用局部数组或 `vector`，需显式清零，否则边界会是垃圾值。
- **与最长公共子串的区别**：LCS 在字符不等时取 `max`（允许中断），最长公共子串在字符不等时归 $0$（要求连续），两者切勿混淆。
- **空间优化注意方向**：滚动数组优化会覆盖对角线旧值 `f[i-1][j-1]`，需用临时变量保存，否则转移会用到被覆盖的值。
- **空串处理**：$n=0$ 或 $m=0$ 时答案为 $0$，代码自动成立（`f[0][j]`、`f[i][0]` 均为 $0$）。

## 对比与扩展

- **LCS vs 最长公共子串**：核心区别在「不匹配时的处理」——LCS 取 `max`，最长公共子串归 $0$。
- **LCS → LIS 转化**：当其中一条序列是 $1 \sim n$ 的排列时（每个数恰好出现一次），可以把 LCS 转化为 LIS，将复杂度从 $O(n^2)$ 降到 $O(n\log n)$。做法：先记录排列 $A$ 中每个数的位置 `pos[value] = index`，再把序列 $B$ 的每个元素映射成它在 $A$ 中的位置，得到新序列 $C$；此时 $A$ 与 $B$ 的 LCS 长度恰好等于 $C$ 的 LIS 长度。原因是排列中元素顺序唯一，公共子序列等价于「按下标单调递增」取出的子序列。映射思路：

```cpp
vector<int> pos(n+1);
for (int i = 0; i < n; i++) pos[A[i]] = i;
vector<int> C;
for (int x : B) C.push_back(pos[x]);
// 然后对 C 跑 LIS 贪心 + 二分
```

- **其他扩展**：输出具体 LCS（增加方向数组回溯）、求 LCS 方案数、带权 LCS（不同字符匹配有不同权值）等。$AKB90$, '动态规划', array['动态规划', '线性DP', '最长公共子序列', 'LCS', '最长上升子序列', 'LIS'], 'col-dp-linear-overview', null, 'knowledge'),
('Xesir', 'col-dp-linear-lcs-length--xesir', '最长公共子序列长度（普通） · Xesir', $AKB91$## 算法原理

给定两个字符串，求它们的最长公共子序列的长度（子序列不要求连续，但顺序必须一致）。

**状态设计**：设 `f[i][j]` 表示第一个串的前 `i` 个字符和第二个串的前 `j` 个字符的最长公共子序列长度。

转移分两种情况：

- 如果 `a[i] == b[j]`，则 `f[i][j] = f[i-1][j-1] + 1`；
- 否则 `f[i][j] = max(f[i-1][j], f[i][j-1])`。

原因是：当前字符相等时，可以直接接到之前的最长公共子序列后面；不相等时，就跳过其中一个字符，取两种「舍弃」里的最大值。

## 核心公式 / 状态定义与转移方程

$$f[i][j] = \begin{cases} f[i-1][j-1] + 1, & a[i] = b[j] \\ \max\big(f[i-1][j],\ f[i][j-1]\big), & a[i] \neq b[j] \end{cases}$$

边界条件 $f[0][j] = f[i][0] = 0$，最终答案 $f[n][m]$。

## 逐行代码解析

### 头文件、宏与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
int f[1010][1010];
```

- `#define int long long` 把全局 `int` 偷换成 `long long`，所以下面入口写成了 `signed main`。
- `f` 是 $1010 \times 1010$ 的二维表，够 $n, m \le 1000$ 的规模。

### main 与读入

```cpp
signed main()
{
    int n,m;cin>>n>>m;
    string a,b;cin>>a>>b;
```

- 先读两个长度 `n`、`m`，再读两个字符串 `a`、`b`。
- 这里 `a`、`b` 是**0 基**下标（`a[0]` 才是第一个字符），而 `f` 用 1 基，所以下面访问字符时要写 `a[i-1]`、`b[j-1]`。

### 核心 DP 双重循环

```cpp
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            f[i][j]=max(f[i-1][j],f[i][j-1]);
            if(a[i-1]==b[j-1]) f[i][j]=f[i-1][j-1]+1;
        }
    }
```

- 先无条件取「上方 `f[i-1][j]`」与「左方 `f[i][j-1]`」的较大值，对应「跳过 a 的一个字符」或「跳过 b 的一个字符」。
- 再判断当前两个字符 `a[i-1]`、`b[j-1]` 是否相等；相等就用对角线 `f[i-1][j-1]+1` **覆盖**（这与刚才的 max 并不冲突，匹配时对角线加一一定不劣）。
- 第 0 行、第 0 列初值为 0，天然表示「空串的 LCS 长度为 0」，不必额外初始化。

### 输出

```cpp
    cout<<f[n][m];
    return 0;
}
```

- `f[n][m]` 即两个完整串的 LCS 长度，直接输出。

## 复杂度分析

- **时间复杂度**：$O(n \times m)$。两重循环分别 $n$、$m$ 次，每次 $O(1)$。
- **空间复杂度**：$O(n \times m)$，二维 `f` 表。由于 $f[i][j]$ 只依赖第 $i-1$ 行与第 $i$ 行，可优化为两行滚动数组 $O(m)$（需暂存对角线旧值）。

## 适用场景

求两个序列最长公共子序列**长度**的常规题。它是文本 diff、生物序列比对、版本控制等场景的基础算法。当 $n, m$ 都在 $10^3$ 级别时，二维 DP 完全够用。

## 常见陷阱与注意事项

1. **下标错位**：`f` 是 1 基（第 0 行/列代表空串），字符串是 0 基，所以字符要写 `a[i-1]`、`b[j-1]`；写成 `a[i]` 会越界且含义全错。
2. **与最长公共子串的区别**：LCS 不匹配时取邻居 `max`（允许中断）；子串不匹配时要归 0（要求连续）。两者混用是最经典的错误。
3. **先 max 再覆盖的顺序**：本代码先 `max(上, 左)` 再用匹配情形覆盖，等于取了「上、左、对角线加一」三者的最大；理解清楚顺序就不会慌。
4. **输入方式**：本代码先读长度再读串；若题目不给长度（只给两个串），要换成 `cin >> a >> b` 并用 `a.size()` 作边界。
5. **数据范围**：`#define int long long` 会放大内存与常数，$1010^2$ 的 `long long` 表约 8MB，注意别在小内存限制下爆掉。

## 对比与扩展

**神秘技巧：LCS → LIS**。当两个序列中**有一个是 1 到 n 的排列**（所有数字恰好出现一次）时，LCS 可以转化为 LIS，从而把 $O(n^2)$ 降到 $O(n \log n)$。

做法：先把排列 A 中每个数字的位置记下来 `pos[value] = index_in_A`；再把序列 B 里的每个元素映射成它在 A 中的位置，得到新数组 C（因为 A 是排列，B 中元素都在 A 里出现过）。那么 A 和 B 的 LCS 长度就等于 **C 的 LIS 长度**。

为什么成立？A 中元素的顺序就是位置顺序，B 中元素映射到位置后，如果这些位置递增，就说明它们在 A 中的顺序与在 B 中的顺序一致，正好构成公共子序列；求最长的递增位置序列就是 LIS。

```cpp
vector<int> pos(n+1);
for (int i = 0; i < n; i++) pos[A[i]] = i;
vector<int> C;
for (int x : B) C.push_back(pos[x]);
// 然后对 C 跑 LIS 贪心+二分
```

其余扩展：输出具体子序列（加方向数组回溯）、求 LCS 方案数、带权 LCS；串很长（$10^5$ 级）时二维 DP 不可行，需要 Bitset 优化等手段。$AKB91$, '动态规划', array['动态规划', '线性DP', '最长公共子序列', 'LCS', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-lcs-length', '最长公共子序列长度（普通）', $AKB92$## 算法原理

最长公共子序列（LCS）问题求两个字符串 $a$ 和 $b$ 的最长公共子序列的长度。子序列不要求连续，但要求保持原序列中的相对顺序。LCS是文本比较、版本控制、生物序列分析等领域的基础算法。

状态定义 $dp[i][j]$ 表示字符串 $a$ 的前 $i$ 个字符与字符串 $b$ 的前 $j$ 个字符的最长公共子序列长度。考虑当前字符 $a[i-1]$ 和 $b[j-1]$ 的关系：若两者相同，则这个字符可以延长已有的公共子序列，即 $dp[i][j] = dp[i-1][j-1] + 1$——上一对角线的最长公共子序列加上当前匹配字符。

若 $a[i-1] \neq b[j-1]$（当前字符不同），则当前字符无法同时匹配，取两种"舍弃"策略的较大值：舍弃 $a$ 的最后一个字符（$dp[i-1][j]$）或舍弃 $b$ 的最后一个字符（$dp[i][j-1]$）。即 $dp[i][j] = \max(dp[i-1][j], dp[i][j-1])$。

这是LCS与最长公共子串的本质区别：LCS在字符不匹配时取邻居最大值（允许子序列中断后继续），而最长公共子串在字符不匹配时归零（要求连续）。DP表从左上角 $dp[0][0]$ 填充到右下角 $dp[|a|][|b|]$，第 $0$ 行和第 $0$ 列自动为 $0$（空串与任何串的LCS长度为 $0$）。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{字符串 } a[0..i-1] \text{ 与 } b[0..j-1] \text{ 的LCS长度}$$

当 $a[i-1] = b[j-1]$ 时：

$$dp[i][j] = dp[i-1][j-1] + 1$$

当 $a[i-1] \neq b[j-1]$ 时：

$$dp[i][j] = \max\big(dp[i-1][j],\; dp[i][j-1]\big)$$

边界条件：

$$dp[0][j] = 0, \quad dp[i][0] = 0$$

最终答案：

$$\text{ans} = dp[|a|][|b|]$$

## 逐行代码解析

### 头文件与 main 入口

```cpp
#include<bits/stdc++.h> // 万能头文件
using namespace std;
int main() // 程序入口
{
```

- 万能头文件 `bits/stdc++.h` 一次涵盖所需的 `string`、`vector`、`iostream`、`algorithm` 等，无需逐个包含。
- `using namespace std;` 省去 `std::` 前缀，OI 竞赛代码常见写法。

### 读入

```cpp
	string a,b;   // 两个待比较字符串
	cin >> a >> b; // 按顺序读入 a、b
```

- `a`、`b` 为两个待求最长公共子序列的字符串。
- `cin >> a >> b` 以空白分隔读入两个字符串，默认假设字符串不含空格。

### dp 表初始化

```cpp
	vector<vector<int>> dp(a.size() + 1,vector<int>(b.size() + 1,0)); // 大小 (|a|+1)×(|b|+1)，全 0
```

- `dp` 表大小为 $(|a|+1) \times (|b|+1)$，第 $0$ 行和第 $0$ 列自然为 $0$，对应空串的边界条件。
- 多出的第 $0$ 行/列表示"前 $0$ 个字符"（空串），从而避免单独处理边界。

### 核心 DP 双重循环

```cpp
	for(int i = 1;i <= a.size();i++) // 外层遍历 a 的每个字符
	{
		for(int j = 1;j <= b.size();j++) // 内层遍历 b 的每个字符
		{
			if(a[i - 1] == b[j - 1]) dp[i][j] = dp[i - 1][j - 1] + 1; // 字符相同：上一对角线 + 1
			else dp[i][j] = max(dp[i - 1][j] , dp[i][j - 1]); // 字符不同：取上方/左方较大值
		}
	}
```

- 外层循环 `i` 遍历 $a$ 的每个字符（$1$ 到 $|a|$）；内层循环 `j` 遍历 $b$ 的每个字符（$1$ 到 $|b|$）。
- 字符匹配时，若 `a[i-1] == b[j-1]`，在上一对角线 `dp[i-1][j-1]` 的基础上加 $1$，延长公共子序列。
- 字符不匹配时，取上方 `dp[i-1][j]`（舍弃 $a$ 的最后一个字符）和左方 `dp[i][j-1]`（舍弃 $b$ 的最后一个字符）的较大值。
- 下标 `a[i-1]`、`b[j-1]` 对应 `dp[i][j]`：因为 `dp` 的第 $0$ 行/列代表空串，字符下标整体错位 $1$。

### 输出与返回

```cpp
	cout << dp[a.size()][b.size()]; // 右下角即答案
	return 0;
}
```

- `dp[a.size()][b.size()]` 即 $dp[|a|][|b|]$，为 $a$ 和 $b$ 的 LCS 长度。
- `return 0;` 表示程序正常结束。

## 复杂度分析

- **时间复杂度**：$O(|a| \times |b|)$。两重循环共 $|a| \times |b|$ 次状态转移，每次为 $O(1)$。
- **空间复杂度**：$O(|a| \times |b|)$。二维 `dp` 表。由于 $dp[i][j]$ 仅依赖第 $i-1$ 行和第 $i$ 行，可优化为 $O(|b|)$ 的滚动数组。

## 适用场景

适用于求两个序列的最长公共子序列长度的问题，是文本比较（如diff工具）、生物序列分析（DNA/RNA比对）、版本控制系统等的基础算法。当需要判断两个序列的相似度时，LCS是最经典的度量之一。

## 常见陷阱与注意事项

- **与最长公共子串的区别**：LCS不匹配时取邻居 `max`（允许中断），子串不匹配时归 $0$（要求连续）。这是两者最本质的区别，混淆会导致算法错误。
- **字符索引**：`a[i-1]` 和 `b[j-1]` 对应 `dp[i][j]`，因为 `dp` 的第 $0$ 行/列代表空串。
- **初始化**：第 $0$ 行和第 $0$ 列必须为 $0$（空串的LCS长度为 $0$），`vector` 初始化时自动满足。
- **空间优化方向**：滚动数组优化时，由于 $dp[i][j]$ 依赖 $dp[i-1][j-1]$（上一行左方），需用临时变量保存对角线旧值，避免被覆盖。
- **字符串长度为0**：当 $a$ 或 $b$ 为空串时，答案为 $0$，代码自动处理（`dp[0][j]` 和 `dp[i][0]` 均为 $0$）。

## 对比与扩展

与最长公共子串的核心区别在于不匹配时的处理：LCS取邻居最大值，子串归零。LCS可扩展为输出具体子序列（增加方向数组回溯）、求LCS的方案数、带权LCS（不同字符匹配有不同权值）等。在字符串很长时（$10^5$ 级别），$O(n^2)$ 的DP不可接受，需使用Bitset优化将复杂度降到 $O(n^2 / 64)$ 或使用其他高级技术。

**LCS→LIS 转化**：当其中一个序列是 $1\sim n$ 的排列时（每个数恰出现一次），可以借助位置映射把 LCS 转成 LIS 求解。先对排列建立映射 $pos[x]$（数 $x$ 在排列中的下标）；再把另一个序列的每个元素替换成 $pos[\,y\,]$（排列中不存在的元素直接丢弃），得到新序列。此时原两序列的 LCS 长度恰好等于这个新序列的 LIS 长度——因为排列中元素顺序唯一，公共子序列就等价于"按下标单调递增"取出来的子序列。伪代码：

```
pos[x] = x 在排列 p 中的下标    // p 是 1..n 的排列
b' = [pos[y] for y in b if y 在 p 中]   // 丢弃 p 中不存在的元素
答案 = LIS(b')                  // 用贪心 + 二分的 O(n log n) LIS
```

这样当 $|a|=|b|=n$ 且 $a$ 是排列时，复杂度从 $O(n^2)$ 降到 $O(n\log n)$。$AKB92$, '动态规划', array['动态规划', '线性DP', '最长公共子序列', 'LCS', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-lcs-output', '最长公共子序列（带输出）', $AKB93$## 算法原理

在标准LCS求长度的基础上，带输出的LCS需要还原具体的最长公共子序列字符串。核心思想是额外维护一个方向数组 $A[i][j]$，记录每个状态 $dp[i][j]$ 是从哪个方向转移来的，然后从右下角 $dp[|a|][|b|]$ 回溯到左上角 $dp[0][0]$，沿途收集匹配字符。

方向数组定义三种方向：方向 $0$ 表示从对角线转移来（即 $a[i-1] = b[j-1]$，字符匹配），偏移为 $(-1, -1)$；方向 $1$ 表示从上方转移来（即 $dp[i-1][j] > dp[i][j-1]$，舍弃 $a$ 的字符），偏移为 $(-1, 0)$；方向 $2$ 表示从左方转移来（即 $dp[i][j-1] \geq dp[i-1][j]$，舍弃 $b$ 的字符），偏移为 $(0, -1)$。

回溯过程从 $x = |a|$、$y = |b|$ 出发，根据 $A[x][y]$ 的方向移动。当方向为 $0$（对角线）时，说明 $a[x-1] = b[y-1]$ 是一个匹配字符，将其记录到结果数组中，然后移动到 $(x-1, y-1)$。当方向为 $1$ 或 $2$ 时，不记录字符，仅按方向移动。回溯直到 $x = 0$ 或 $y = 0$（到达边界）。

由于回溯是从后向前收集字符，结果数组需要逆序填充（从LCS末尾向前），最终正向输出即为LCS字符串。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{字符串 } a[0..i-1] \text{ 与 } b[0..j-1] \text{ 的LCS长度}$$

$$A[i][j] = \text{转移方向：} 0 \text{（对角线）、} 1 \text{（上方）、} 2 \text{（左方）}$$

当 $a[i-1] = b[j-1]$ 时：

$$dp[i][j] = dp[i-1][j-1] + 1, \quad A[i][j] = 0$$

当 $dp[i-1][j] > dp[i][j-1]$ 时：

$$dp[i][j] = dp[i-1][j], \quad A[i][j] = 1$$

否则：

$$dp[i][j] = dp[i][j-1], \quad A[i][j] = 2$$

方向偏移数组：

$$n_x = \{-1, -1, 0\}, \quad n_y = \{-1, 0, -1\}$$

## 逐行代码解析

### 全局变量（方向偏移数组）

```cpp
#include<bits/stdc++.h>
using namespace std;
int n_x[3] = { -1 , -1 , 0};
int n_y[3] = { -1 , 0 , -1};
```

- `#include<bits/stdc++.h>` 是万能头文件，`using namespace std` 免去每个标准类型都写 `std::`，是竞赛常见写法。
- `n_x`、`n_y` 是三个方向的行/列偏移：方向 $0$ 对角线 $(-1,-1)$、方向 $1$ 上方 $(-1,0)$、方向 $2$ 左方 $(0,-1)$，下标必须与方向编号严格对应。
- 回溯时用 `x += n_x[方向]`、`y += n_y[方向]` 统一完成坐标移动，避免为三种方向各写一套 `if`。

### 读入与 DP 表初始化

```cpp
int main()
{
	string a,b;
	cin >> a >> b;
	vector<vector<int>> dp(a.size() + 1,vector<int>(b.size() + 1,0));
	vector<vector<int>> A(a.size() + 1,vector<int>(b.size() + 1 , 0)); 
```

- 用 `string` 读入两个字符串 `a`、`b`。
- `dp` 与方向数组 `A` 都开成 $(|a|+1)\times(|b|+1)$，多出的一行一列充当 0 号边界，`dp[0][*]`、`dp[*][0]` 默认为 0，省去边界特判。
- `dp` 记录 LCS 长度，`A` 记录每个状态的转移方向，两者同大小，便于回溯时按 `A` 移动。

### DP 填充（核心转移）

```cpp
	for(int i = 1;i <= a.size();i++)
	{
		for(int j = 1;j <= b.size();j++)
		{
			if(a[i - 1] == b[j - 1]) 
			{
				dp[i][j] = dp[i - 1][j - 1] + 1;
				A[i][j] = 0;
			}
			else if(dp[i - 1][j] > dp[i][j - 1])
			{
				dp[i][j] = dp[i - 1][j];
				A[i][j] = 1;
			}
			else
			{
				dp[i][j] = dp[i][j - 1];
				A[i][j] = 2;
			}
		}
	}
```

- 循环变量从 $1$ 枚举到 `a.size()`/`b.size()`，因此字符用 `a[i-1]`、`b[j-1]` 下标访问。
- 字符匹配时走对角线转移 $+1$，方向记为 $0$；不匹配时上方更大选方向 $1$（舍弃 `a` 的字符），否则选方向 $2$（舍弃 `b` 的字符）。
- 上方与左方相等时进入 `else` 选方向 $2$ 只是约定，选方向 $1$ 同样正确，二者长度一致但可能得到不同的字符串。

### 回溯还原 LCS 字符串

```cpp
	vector<char> str(dp[a.size()][b.size()]);
	int idx = dp[a.size()][b.size()] - 1;
	int x = a.size();
	int y = b.size();
	while(x != 0 && y != 0)
	{
		int tmp = A[x][y];
		if(tmp  == 0)
		{
			str[idx--] = a[x - 1];
			x += n_x[tmp];
			y += n_y[tmp];
		}
		else
		{
			x += n_x[tmp];
			y += n_y[tmp];
		}
	}
```

- `str` 大小等于 LCS 长度，`idx` 从 `长度-1` 开始逆序填充，保证最终 `str` 正序就是 LCS 字符串。
- 从右下角 $(|a|, |b|)$ 出发，读 `A[x][y]` 决定方向；`while(x != 0 && y != 0)` 保证任一坐标到 0 就停止，索引始终合法。
- 方向 $0$ 时 `a[x-1]` 是匹配字符，先写入 `str[idx--]` 再按偏移移动；方向 $1$/$2$ 只移动不记录。

### 输出结果

```cpp
	cout << "最长子序列的长度为 ： ";
	for(char i : str) cout << i;
	cout << '\n';
	
	cout <<"长度为 :  "<< dp[a.size()][b.size()];
	return 0;
}
```

- 第一行遍历 `str` 逐个字符输出，即 LCS 字符串本身。
- 第二行输出 `dp[a.size()][b.size()]`，即 LCS 长度。
- `return 0;` 正常结束 `main` 函数。

## 复杂度分析

- **时间复杂度**：$O(|a| \times |b|)$。DP填充阶段 $|a| \times |b|$ 次，回溯阶段最多走 $|a| + |b|$ 步，总体为 $O(|a| \times |b|)$。
- **空间复杂度**：$O(|a| \times |b|)$。需保留完整的 `dp` 表和方向数组 `A`，无法用滚动数组优化。

## 适用场景

适用于需要输出LCS具体内容（而非仅长度）的问题，如diff工具对比两个文件的差异行、版本控制系统对比代码变更、生物信息学中输出匹配的DNA片段等。

## 常见陷阱与注意事项

- **必须保留二维表**：回溯需要访问方向数组 `A` 的所有历史状态，不能用滚动数组优化空间。
- **方向选择的歧义**：当 $dp[i-1][j] = dp[i][j-1]$（上方等于左方）时，代码选择方向 $2$（左方），但选方向 $1$ 也是正确的——不同选择可能得到不同的LCS字符串，但长度相同。若题目要求字典序最小的LCS，需特殊处理。
- **结果数组的填充方向**：回溯从后向前收集字符，`idx` 从 `LCS长度 - 1` 递减填充，最终 `str` 正序即为LCS字符串。
- **回溯终止条件**：`while(x != 0 && y != 0)`，当任一索引为 $0$ 时停止（到达边界）。
- **方向偏移的正确性**：`n_x` 和 `n_y` 数组的值必须与方向编号严格对应，否则回溯路径会错误。

## 对比与扩展

与标准LCS相比，增加了方向数组 `A` 和回溯阶段，核心DP转移逻辑不变。回溯路径还原的思想与01背包路径还原、最短路路径还原等技术一脉相承——都是"根据转移方程记录决策方向，然后从终点反推到起点"。若需求所有LCS方案，需在方向相同时同时回溯两个方向（递归或栈实现），复杂度可能指数增长。$AKB93$, '动态规划', array['动态规划', '线性DP', '最长公共子序列', 'LCS', '路径还原', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-lcs-substring', '最长公共子串', $AKB94$## 算法原理

最长公共子串问题求两个字符串 $A$ 和 $B$ 中最长的连续公共部分。与最长公共子序列（LCS）的关键区别在于：子串要求在两个字符串中连续出现，而子序列不要求连续。这个区别导致状态转移方程有本质不同。

状态定义 $dp[i][j]$ 表示以 $A[i-1]$ 和 $B[j-1]$ 结尾的最长公共子串的长度。考虑当前字符 $A[i-1]$ 和 $B[j-1]$：若两者相同，则公共子串可以在上一对字符的基础上延长 $1$，即 $dp[i][j] = dp[i-1][j-1] + 1$。若两者不同，则以 $A[i-1]$ 和 $B[j-1]$ 结尾的公共子串长度为 $0$（因为子串必须连续，一旦中断就必须从头开始）。

这是与LCS最本质的区别：LCS在字符不匹配时取邻居最大值 $dp[i][j] = \max(dp[i-1][j], dp[i][j-1])$（允许子序列中断后继续），而最长公共子串在字符不匹配时直接归零 $dp[i][j] = 0$（要求连续，中断则重新开始）。

由于最长公共子串可能以任意一对字符结尾，答案不一定出现在 $dp[|A|][|B|]$，而是整个 `dp` 表中的最大值。因此需要额外维护一个全局变量 `ans` 记录遍历过程中的最大值。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{以 } A[i-1] \text{ 和 } B[j-1] \text{ 结尾的最长公共子串长度}$$

当 $A[i-1] = B[j-1]$ 时：

$$dp[i][j] = dp[i-1][j-1] + 1$$

当 $A[i-1] \neq B[j-1]$ 时：

$$dp[i][j] = 0$$

最终答案：

$$\text{ans} = \max_{1 \leq i \leq |A|,\; 1 \leq j \leq |B|} dp[i][j]$$

## 逐行代码解析

### 头文件与 main 框架

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
```

- `bits/stdc++.h` 是 GCC 的万能头，竞赛中常用，一次包含几乎所有标准库；`using namespace std;` 省去 `std::` 前缀。
- `main` 返回 `int`，最后用 `return 0` 表示正常结束。

### 读入与 dp 表初始化

```cpp
	string A,B;
	cin >> A >> B;
	vector<vector<int>> dp(A.size() + 1 ,vector<int>(B.size() + 1, 0 ));
	int ans = 0;
```

- `cin >> A >> B` 读入两个以空白分隔的字符串。
- **`dp` 表**：大小为 $(|A|+1) \times (|B|+1)$，全部初始化为 $0$。第 $0$ 行和第 $0$ 列代表空串，空串与任何串的公共子串长度为 $0$。
- **`ans` 变量**：全局最大值，初始化为 $0$，每次字符匹配时更新。

### 双层循环与状态转移（核心）

```cpp
	for(int i = 1;i <= A.size();i++)
	{
		for(int j = 1;j <= B.size();j++)
		{
			if(A[i - 1] == B[j - 1])
			{
				dp[i][j] = dp[i - 1][j - 1] + 1;
				ans = max(ans,dp[i][j]);
			}
			else dp[i][j] = 0;
		}
	}
```

- **外层循环 `i`** 遍历 $A$ 的每个字符（$1$ 到 $|A|$），**内层循环 `j`** 遍历 $B$ 的每个字符（$1$ 到 $|B|$）；每个 `dp[i][j]` 对应字符对 `A[i-1]` 与 `B[j-1]`。
- 循环从 $1$ 开始：`i=0` 或 `j=0` 表示空串，已在初始化时置 $0$，无需参与转移。
- **字符匹配**：若 `A[i-1] == B[j-1]`，在上一对角线 `dp[i-1][j-1]` 基础上延长 $1$，并更新全局最大值 `ans`。
- **字符不匹配**：直接令 `dp[i][j] = 0`，因为子串必须连续，一旦中断则重新开始。

### 输出与返回

```cpp
	cout << ans;
	return 0;
}
```

- 答案不一定出现在 `dp[|A|][|B|]`（右下角），最长公共子串可能以任意一对字符结尾，所以输出遍历中维护的全局最大值 `ans`。
- `return 0` 表示程序正常结束。

## 复杂度分析

- **时间复杂度**：$O(|A| \times |B|)$。两重循环共 $|A| \times |B|$ 次状态转移，每次为 $O(1)$。
- **空间复杂度**：$O(|A| \times |B|)$。二维 `dp` 表。由于 $dp[i][j]$ 仅依赖 $dp[i-1][j-1]$（上一行左方），可优化为 $O(|B|)$ 的滚动数组（需用临时变量保存对角线旧值）。

## 适用场景

适用于求两个字符串的最长连续公共部分的问题，如文本查重（检测抄袭段落）、生物信息学中的序列匹配（寻找保守序列片段）、代码相似度检测等。当题目明确要求"连续"时使用本算法，若不要求连续则用LCS。

## 常见陷阱与注意事项

- **与LCS的混淆**：最长公共子串不匹配时归 $0$（连续），LCS不匹配时取邻居最大值（不连续）。混用会导致算法错误——用LCS的转移求子串会得到错误的大值，用子串的转移求LCS会得到错误的小值。
- **全局最大值而非 `dp[|A|][|B|]`**：答案不一定在右下角，因为最长公共子串可能以任意一对字符结尾。必须遍历整个 `dp` 表取最大值（代码中用 `ans` 实时更新）。
- **字符索引**：`A[i-1]` 和 `B[j-1]` 对应 `dp[i][j]`，因为第 $0$ 行/列代表空串。
- **空间优化**：滚动数组优化时，由于 $dp[i][j]$ 依赖 $dp[i-1][j-1]$（上一行左方），需用临时变量保存对角线旧值，否则会被覆盖。
- **空串处理**：当 $A$ 或 $B$ 为空串时，答案为 $0$，代码自动处理。

## 对比与扩展

与LCS（最长公共子序列）的核心区别在于：子串不匹配时归 $0$（要求连续），LCS不匹配时取邻居最大值（允许中断）。最长公共子串也可用后缀自动机（SAM）或后缀数组在 $O(|A| + |B|)$ 的线性时间内求解，适合超长字符串。若需输出具体子串内容，可在DP过程中记录最大值对应的 $(i, j)$ 位置，然后向前截取 `ans` 个字符即可。可扩展为多个字符串的最长公共子串、带通配符的公共子串等变种。$AKB94$, '动态规划', array['动态规划', '线性DP', '最长公共子串', '字符串', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('Xesir', 'col-dp-linear-lis-binary--xesir', '最长上升子序列（二分） · Xesir', $AKB95$## 算法原理

最长上升子序列（LIS）：给定一个序列，求最长的**严格递增**子序列的长度（不要求连续）。

**暴力 DP**：设 `f[i]` 表示以第 `i` 个元素结尾的最长上升子序列长度。初始化 `f[i] = 1`（单独一个元素也算长度 1）。转移：对每个 `i` 枚举所有 `j < i`，如果 `a[j] < a[i]`，则 `f[i] = max(f[i], f[j] + 1)`。最终答案是所有 `f[i]` 的最大值。

$O(n^2)$ 还是太暴力了，有没有更优的做法呢？有的兄弟有的。

**贪心 + 二分优化**：我们不再记录「以 `i` 结尾的最长长度」，而是维护一个数组 `d`，其中 `d[len]` 表示**长度为 len 的上升子序列的末尾元素的最小可能值**。

这个数组有一个重要性质：**`d` 是严格递增的**（长度越长，末尾值不可能更小，否则就能接在更短的后面）。

处理每个数 `x` 时：

- 在 `d` 中找到**第一个大于等于 x 的位置**（用 `lower_bound`）。
- 找到了，就用 `x` 替换那个位置（末尾越小越优）。
- 没找到（即 `x` 大于 `d` 中所有数），就追加到末尾，说明可以形成更长的上升子序列。

最终 `d` 的长度就是 LIS 的长度，复杂度 $O(n \log n)$。

**为什么贪心是对的？** 我们始终让每个长度的末尾尽可能小，这样未来更容易接上更大的数。举个例子：序列 `[2, 3, 1]`，处理 `2` 时 `d=[2]`，处理 `3` 时 `d=[2,3]`，处理 `1` 时替换掉 `2` 变成 `d=[1,3]`。虽然 `1` 单独看没增加长度，但它让长度为 1 的末尾变小了，后面再来个 `2` 就能形成 `[1,2]` 长度为 2，而原来的 `[2,3]` 末尾是 3，接不了 `2`。所以贪心保证了未来最优。

### 朴素 O(n²) 写法（对照）

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
int a[100010],f[100010];
signed main()
{
    int n,ans=0;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i]=1;
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<i;j++){
            if(a[j]<a[i]) f[i]=max(f[i],f[j]+1);
        }
    }
   for(int i=1;i<=n;i++){
       ans=max(ans,f[i]);
   }
    cout<<ans;
    return 0;
}
```

- 双重循环枚举「上一个接谁」，$O(n^2)$，$n$ 到 $10^5$ 就过不去了。
- 用 `#define int long long` 偷换全局 `int`，所以入口写成 `signed main`。

## 核心公式 / 状态定义与转移方程

状态定义：

$$d[k] = \text{所有长度为 } k \text{ 的上升子序列中，末尾元素的最小值}$$

对每个 $x = a[i]$：

- 若 `x` 比 `d` 的末尾还大（即 `pos > len`）：$d[\,len+1\,] = x$（追加，长度 +1）。
- 否则：$d[\,lower\_bound(x)\,] = x$（替换，长度不变）。

其中 `pos = lower_bound(d + 1, d + len + 1, x) - d` 返回第一个 $\ge x$ 的下标。最终：

$$\text{ans} = len$$

## 逐行代码解析

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 100010;
int a[N], d[N];
```

- `a` 存原序列，`d` 是核心辅助数组，`d[len]` 表示长度为 `len` 的上升子序列的最小末尾。
- 下标从 1 用起，`d` 的有效区间是 `d[1..len]`。

### 读入与哨兵

```cpp
int main() {
    int n; cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i];
    
    int len = 0;
    d[0] = -1e9; // 哨兵，防止边界
```

- 先读长度 `n`，再读入 `a[1..n]`。
- `len` 记录当前 `d` 的有效长度，初始为 0。
- 作者在 `d[0]` 放了一个极小值当**哨兵**，意图是避免边界判断（后面若改成从 `d` 起点二分时能兜底）。

### 主循环：二分 + 追加/替换

```cpp
    for (int i = 1; i <= n; i++) {
        int pos = lower_bound(d + 1, d + len + 1, a[i]) - d; // 第一个 >= a[i] 的位置
        if (pos > len) { // 没找到，追加
            d[++len] = a[i];
        } else { // 替换
            d[pos] = a[i];
        }
    }
```

- `lower_bound(d + 1, d + len + 1, a[i])` 在 `d[1..len]` 中二分，找**第一个 $\ge a[i]$** 的位置，减掉 `d` 的地址得到下标 `pos`。
- 若 `pos > len`（范围内没有 $\ge a[i]$ 的元素），说明 `a[i]` 可以延长最长链，`d[++len] = a[i]` 追加。
- 否则用 `a[i]` 覆盖 `d[pos]`：长度不变，但让该长度的末尾更小，为后续延长铺路。

### 输出

```cpp
    cout << len << endl;
    return 0;
}
```

- 结束时 `len` 就是 LIS 长度，直接输出。

## 复杂度分析

- **时间复杂度**：$O(n \log n)$。每个元素要么 $O(1)$ 追加，要么 $O(\log n)$ 二分定位后替换，共处理 $n$ 个元素。
- **空间复杂度**：$O(n)$。`a`、`d` 各占 $O(n)$，`d` 的大小不会超过 $n$。

## 适用场景

- 数据规模较大（$n > 10^4$）的 LIS 长度问题，是 LIS 的最优做法。
- 配合「LCS → LIS 转化」，可把「一个序列是排列」的 LCS 从 $O(n^2)$ 降到 $O(n \log n)$（见 `dp-linear-lcs-length`）。
- $n$ 较小时（$< 10^3$），朴素 $O(n^2)$ 也够用，写起来更直白。

## 常见陷阱与注意事项

1. **严格递增 vs 非降**：求**严格上升**用 `lower_bound`（找第一个 $\ge x$）；若允许相等（非降），要改成 `upper_bound`（找第一个比 `x` 大的位置）。
2. **`d` 不是真正的 LIS**：替换操作会打乱原始顺序，`d` 里的序列不能当作答案输出；我们只取它的**长度**。
3. **哨兵 `d[0]` 的边界含义**：本代码二分区间是 `d[1..len]`，`d[0]` 那个极小值主要是防越界的写法；理解成「兜底哨兵」即可，别指望它参与比较。
4. **`-1e9` 赋给 `int`**：字面量是浮点，赋给 `int d[0]` 会截断成整数，数值上没问题，但心里要清楚。
5. **多组数据要清空**：`len` 要归零、`d` 要重置，否则第二组会带着上一组的状态。

## 对比与扩展

| 做法 | 状态 | 时间复杂度 | 空间 |
|---|---|---|---|
| 朴素 DP | 以 $i$ 结尾的 LIS 长度 | $O(n^2)$ | $O(n)$ |
| 贪心 + 二分（本代码） | 长度 $k$ 的最小末尾 | $O(n \log n)$ | $O(n)$ |

扩展方向：需要**输出具体 LIS** 时，二分的同时额外记一个前驱数组回溯；可推广到二维 LIS（俄罗斯套娃）、带权 LIS（最大权值上升子序列）等变种。$AKB95$, '动态规划', array['动态规划', '线性DP', '最长上升子序列', 'LIS', '二分查找'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-lis-binary', '最长上升子序列（二分）', $AKB96$## 算法原理

最长上升子序列（LIS）问题求数组 $A$ 中最长的严格递增子序列的长度。朴素DP的时间复杂度为 $O(n^2)$，二分优化将其降到 $O(n \log n)$，是LIS的最优解法。

核心思想是维护一个数组 $B$，其中 $B[k]$ 表示长度为 $k$ 的上升子序列的最小末尾元素。这个定义是关键：对于每个长度 $k$，我们只关心所有长度为 $k$ 的上升子序列中末尾最小的那个，因为末尾越小越有利于后续元素延长子序列。

对每个新元素 $A[i]$，分两种情况处理：若 $B$ 为空，或 $A[i]$ 大于 $B$ 的末尾元素（即 $A[i] > B[\text{back}]$），说明 $A[i]$ 可以延长当前最长的上升子序列，直接将 $A[i]$ 追加到 $B$ 末尾。若 $A[i]$ 不大于 $B$ 的末尾元素，则在 $B$ 中用二分查找找到第一个大于等于 $A[i]$ 的位置，将其替换为 $A[i]$——这不会增加子序列长度，但会使该长度的末尾更小，为后续延长创造更有利条件。

替换操作的正确性在于：用更小的 $A[i]$ 替换 $B$ 中某位置的值，不会影响之前已经形成的更长子序列（因为只替换了第一个 $\geq A[i]$ 的位置，且 $A[i]$ 比该位置的旧值更小）。最终 $B$ 的长度即为LIS长度。

需要注意的是，$B$ 数组本身不一定构成真实的LIS（因为替换操作打乱了原始顺序），但其大小正确反映了LIS的长度。

## 状态定义与转移方程

状态定义：

$$B[k] = \text{所有长度为 } k \text{ 的上升子序列中，末尾元素的最小值}$$

转移规则：

$$\text{若 } B \text{ 为空或 } A[i] > B[\text{back}]: \quad B.\text{emplace\_back}(A[i])$$

$$\text{否则}: \quad B\big[\text{lower\_bound}(A[i])\big] = A[i]$$

其中 `lower_bound` 返回 $B$ 中第一个 $\geq A[i]$ 的位置索引。

最终答案：

$$\text{ans} = |B|$$

（$B$ 无哨兵，长度即答案）

## 逐行代码解析

### 全局变量

```cpp
#include<bits/stdc++.h>  // 万能头，包含所有标准库
using namespace std;     // 标准命名空间，省去 std:: 前缀
int n;                   // 序列长度
vector<int> A, B;        // 原序列 A 与辅助数组 B
```

- `A`：存储输入序列，下标从 $1$ 开始，大小 $n+1$（$0$ 号位闲置）。
- `B`：核心辅助数组，`B[k]` 表示长度为 $k$ 的上升子序列的最小末尾；新代码不设哨兵，`B` 初始为空。

### init 函数（初始化）

```cpp
void init(int n)
{
	A.assign(n + 1, 0);         // A 扩为 n+1 并清零，下标 1..n 使用
	if (!B.empty()) B.clear();  // 清空 B，支持多次调用不残留
	B.reserve(n + 1);           // 预留容量，避免反复扩容
}
```

- `init(n)` 集中完成初始化：`A.assign(n + 1, 0)` 把 `A` 扩到 $n+1$ 并清零；`B.clear()` 清空 `B`；`B.reserve(n + 1)` 预留容量。
- 新代码不再放入哨兵 $0$，`B` 初始为空，是否可追加由主循环里的 `B.empty()` 判断。

### find 函数（二分查找）

```cpp
int find(int x)
{
	int l = 0, r = B.size() - 1;  // 二分区间为闭区间 [0, B.size()-1]
	while (l < r)
	{
		int mid = (l + r) / 2;    // 中间位置，向下取整
		if (x <= B[mid]) r = mid; // 第一个 >= x 的位置在左半，收缩右边界
		else l = mid + 1;         // 否则在右半，左边界右移
	}
	return l;                     // 返回第一个 >= x 的位置下标
}
```

- `find(x)` 手写二分，返回 $B$ 中第一个 $\geq x$ 的位置下标，供主循环替换用。
- 使用 $l < r$ 的二分模板，区间是闭区间 $[0, B.size()-1]$，最终返回 $l$。
- 收缩条件 `x <= B[mid]`（等价 `B[mid] >= x`）是修复后的正确方向；旧代码写反成 `x >= B[mid]` 会定位到错误位置。

### main·读入与初始化

```cpp
int main()
{
	cin >> n;                     // 读入序列长度 n
	init(n);                      // 初始化 A、B
	for (int i = 1; i <= n; i++) cin >> A[i];  // 读入 A[1..n]
```

- 读入 `n` 后调用 `init(n)` 完成 `A`、`B` 的初始化。
- 读入循环 `i = 1..n`，边界与 `A` 的 1 基下标保持一致。

### main·主循环与输出

```cpp
	for (int i = 1; i <= n; i++)
	{
		if (B.empty() || A[i] > B.back()) B.emplace_back(A[i]);  // B 空或可延长，追加到末尾
		else B[find(A[i])] = A[i];                 // 否则二分定位后替换
	}
	cout << B.size();              // LIS 长度 = B 大小（无哨兵）
	return 0;
}
```

- 主循环对每个 $A[i]$：若 `B.empty()`（首元素）或 $A[i] > B.back()$ 则追加（延长子序列），否则调用 `find` 找到替换位置并替换。
- 替换不会增加长度，但让对应长度的末尾更小，更有利于后续延长。
- 输出 `B.size()`：`B` 无哨兵，长度即 LIS 长度。
- 边界：$n=0$ 时循环不执行，`B` 为空，直接输出 $0$。

## 复杂度分析

- **时间复杂度**：$O(n \log n)$。对每个元素 $A[i]$，要么 $O(1)$ 追加到 $B$ 末尾，要么 $O(\log n)$ 的二分查找替换位置。共 $n$ 个元素，总时间 $O(n \log n)$。
- **空间复杂度**：$O(n)$。`A` 和 `B` 数组各 $O(n)$。`B` 数组的大小不会超过 $n$（每个元素最多追加一次）。

## 适用场景

适用于求LIS长度且数据量较大（$n > 10^4$）的场景，是LIS的最优算法。广泛用于序列分析、调度问题、嵌套结构检测等。当 $n$ 较小（$< 10^3$）时朴素 $O(n^2)$ DP也可接受。

## 常见陷阱与注意事项

- **无哨兵设计**：新代码不在 `B` 中放哨兵，`B` 初始为空，主循环用 `B.empty()` 判断是否可以追加。这避免了旧代码"哨兵 $0$ 假设元素全为正数"的限制，支持任意整数（含 $0$、负数）。
- **`find` 函数的正确性**：本代码的 `find` 使用 `x <= B[mid]`（即 `B[mid] >= x`）作为收缩条件，二分找到第一个 $\geq x$ 的位置并替换，对应**严格递增**子序列。旧代码写反成 `x >= B[mid]` 是 bug，会导致定位错误。若求**非递减**（允许相等）子序列，应改为 `x < B[mid]`（查找第一个 $> x$ 的位置）。
- **`B` 不构成真实LIS**：`B` 数组中的值经过替换操作后可能不满足原始顺序，不能直接作为LIS输出。其大小正确反映LIS长度。
- **严格递增 vs 非递减**：若求最长非递减子序列（允许相等），`find` 的条件需调整为查找第一个 $> x$ 的位置（即 `x < B[mid]`）。
- **`B` 数组的大小**：最终直接输出 `B.size()` 即LIS长度（新代码无哨兵，不需要 `-1`）。

## 对比与扩展

与朴素 $O(n^2)$ DP相比，二分优化利用了 $B$ 数组"长度对应最小末尾"的单调性，将内层线性查找变为二分查找。若需输出具体LIS序列，需在二分优化的同时额外维护一个前驱数组（记录每个元素在LIS中的前驱），最后回溯输出。可扩展为二维LIS（如俄罗斯套娃问题）、带权LIS（求最大权值上升子序列）等变种。$AKB96$, '动态规划', array['动态规划', '线性DP', '最长上升子序列', 'LIS', '二分查找', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-lis-bit-count', '最长上升子序列（树状数组优化·带计数）', $AKB97$## 算法原理

本算法在 $O(n \log n)$ 时间内同时求解最长上升子序列（LIS）的**长度**和**方案数**。朴素 $O(n^2)$ DP 中，状态 $dp[i]$ 表示以 $A[i]$ 结尾的 LIS 长度，转移为 $dp[i] = \max_{j < i, A[j] < A[i]} dp[j] + 1$。若同时计数，还需维护 $cnt[i]$ 表示以 $A[i]$ 结尾的 LIS 方案数。朴素做法对每个 $i$ 线性扫描所有 $j < i$，内层为 $O(n)$。

树状数组优化的核心观察：转移方程 $dp[i] = \max_{A[j] < A[i]} dp[j] + 1$ 中的约束条件是 $A[j] < A[i]$（值域约束），而非 $j < i$（下标约束）。下标约束 $j < i$ 由遍历顺序自然保证（从左到右处理），因此转移只需查询"所有已处理元素中，值小于 $A[i]$ 的那些元素的最大 $dp$ 值及对应方案数"。这恰好是一个**前缀最大值查询**，可以用树状数组在 $O(\log n)$ 内完成。

但由于 $A[i]$ 的值域可能很大或含负数，不能直接以值为下标建 BIT。算法首先对 $A$ 做离散化（排序 + 去重 + 二分映射），将值压缩到 $[1, m]$ 范围（$m$ 为不同值的个数）。然后以压缩后的值为 BIT 下标，每个 BIT 节点存储一个 $(len, cnt)$ 二元组：$len$ 为该值域前缀内的最大 LIS 长度，$cnt$ 为达到该长度的方案数。

BIT 的合并规则是本算法的精髓：查询前缀 $[1, v-1]$ 时，遍历覆盖该前缀的所有 BIT 节点，取 $len$ 最大者，若多个节点的 $len$ 相同则将它们的 $cnt$ 相加。更新时，将新元素的 $(len, cnt)$ 插入 BIT，沿途每个节点用相同的合并规则与已有值比较更新。这把朴素 DP 的 $O(n)$ 内层转移压缩为 $O(\log n)$ 的 BIT 查询 + 更新。

## 状态定义与转移方程

朴素 DP 状态定义：

$$dp[i] = \text{以 } A[i] \text{ 结尾的 LIS 长度}$$

$$cnt[i] = \text{以 } A[i] \text{ 结尾的 LIS 方案数}$$

朴素转移方程：

$$dp[i] = \max_{\substack{j < i \\ A[j] < A[i]}} \big(dp[j] + 1\big)$$

$$cnt[i] = \sum_{\substack{j < i,\; A[j] < A[i] \\ dp[j] + 1 = dp[i]}} cnt[j]$$

树状数组优化后的转移（离散化后 $rank(i)$ 为 $A[i]$ 的排名）：

$$dp[i] = \text{BIT.query}\big(rank(i) - 1\big).len + 1$$

$$cnt[i] = \begin{cases} \text{BIT.query}\big(rank(i) - 1\big).cnt & \text{if 有前驱（query.len > 0）} \\ 1 & \text{if 无前驱（query.len = 0）} \end{cases}$$

BIT 节点合并规则（查询/更新时对 $(len_1, cnt_1)$ 与 $(len_2, cnt_2)$ 取并）：

$$\text{merge}\big((len_1, cnt_1),\; (len_2, cnt_2)\big) = \begin{cases} (len_1, cnt_1) & \text{if } len_1 > len_2 \\ (len_2, cnt_2) & \text{if } len_2 > len_1 \\ (len_1, cnt_1 + cnt_2) & \text{if } len_1 = len_2 \end{cases}$$

最终答案：

$$\text{ans\_len} = \text{BIT.query}(m).len, \quad \text{ans\_cnt} = \text{BIT.query}(m).cnt \pmod{10^9 + 7}$$

## 数据结构图示

```
离散化示例：
  原始 A = [3, 1, 4, 1, 5, 9, 2, 6]
  排序去重 tmp = [1, 2, 3, 4, 5, 6, 9]
  rank: A[1]=3→3, A[2]=1→1, A[3]=4→4, A[4]=1→1,
        A[5]=5→5, A[6]=9→7, A[7]=2→2, A[8]=6→6

BIT 结构（以 rank 为下标，存储 (len, cnt)）：

         BIT[1]  BIT[2]  BIT[3]  BIT[4]  BIT[5]  BIT[6]  BIT[7]
          (1,1)   (2,1)   (1,1)   (3,1)   (4,1)   (5,1)   (6,1)

  lowbit 覆盖关系（BIT 标准结构）：
  BIT[1] 覆盖 [1]       BIT[2] 覆盖 [1,2]
  BIT[3] 覆盖 [3]       BIT[4] 覆盖 [1,2,3,4]
  BIT[5] 覆盖 [5]       BIT[6] 覆盖 [5,6]
  BIT[7] 覆盖 [7]

  query(6) = merge(BIT[6], BIT[4])
            = merge((5,1), (3,1)) = (5,1)   ← len=5 取较大者
  query(3) = merge(BIT[3], BIT[2])
            = merge((1,1), (2,1)) = (2,1)   ← len=2 取较大者
```

## 核心操作详解

### lowbit(x)

- **作用**：返回 $x$ 的最低位 $1$ 对应的值，即 $x \mathbin{\&} (-x)$。
- **关键细节**：BIT 的基石操作。$-x$ 在补码表示下等价于 $\sim x + 1$，因此 $x \mathbin{\&} (-x)$ 提取 $x$ 二进制表示中最低位的 $1$。例如 $\text{lowbit}(6) = 6 \mathbin{\&} (-6) = 2$（$6 = 110_2$，最低位 $1$ 在第 $2$ 位）。

### treearr 结构体

- **字段**：`len[i]` 存储 BIT 节点 $i$ 维护的最大 LIS 长度，`cnt[i]` 存储对应方案数，`ans_len` 和 `ans_cnt` 为查询暂存。
- **设计思路**：将树状数组从"维护前缀和"推广为"维护前缀最大值 + 计数"。每个 BIT 节点不再存一个标量，而是存一个 $(len, cnt)$ 二元组。

### add(idx, num, t_cnt)

- **作用**：将 $(num, t\_cnt)$ 合并到 BIT 节点 $idx$ 上（单节点更新）。
- **合并规则**：
  - 若 $num > len[idx]$：新长度更优，直接替换 $len[idx] = num$，$cnt[idx] = t\_cnt$（旧方案被更优方案淘汰）。
  - 若 $num = len[idx]$：长度相同，方案数累加 $cnt[idx] \mathrel{+}= t\_cnt \pmod{mod}$。
  - 若 $num < len[idx]$：新方案更短，不做任何操作（保持已有更优值）。
- **关键细节**：这里的合并规则是"取最大长度，等长则计数相加"，与普通 BIT 的"求和"完全不同。这要求 BIT 的每个节点维护的不是单一标量，而是 $(max, count)$ 对。

### insert(idx, num, t_cnt)

- **作用**：将 $(num, t\_cnt)$ 插入 BIT 位置 $idx$，并沿 lowbit 链向上传播。
- **算法步骤**：`while (idx <= sz) { add(idx, num, t_cnt); idx += lowbit(idx); }`。
- **关键细节**：与标准 BIT 单点更新完全一致，只是 `add` 内部逻辑变为 $(len, cnt)$ 合并而非简单加法。

### get(idx)

- **作用**：查询前缀 $[1, idx]$ 上的最大 LIS 长度及方案数，结果存入 `ans_len` 和 `ans_cnt`。
- **算法步骤**：`ans_len = 0, ans_cnt = 0; while (idx) { merge BIT[idx] into (ans_len, ans_cnt); idx -= lowbit(idx); }`。
- **合并细节**：遍历覆盖 $[1, idx]$ 的所有 BIT 节点，对每个节点的 $(len, cnt)$ 与当前 $(ans\_len, ans\_cnt)$ 执行同样的合并规则——取较大 $len$，等长则 $cnt$ 相加。
- **关键细节**：查询的是值域前缀 $[1, idx]$ 上的最优值，对应"所有值 $\le idx$ 的元素中最大的 LIS 长度及方案数"。为求严格递增（值 $< A[i]$），调用时传入 $rank(i) - 1$。

### 离散化

- **作用**：将原始值域压缩到 $[1, m]$（$m$ 为不同值个数），使 BIT 能以下标直接索引。
- **步骤**：`sort` → `unique` → `lower_bound` 逐个映射。
- **关键细节**：离散化保证了值的大小关系不变（仅压缩值域），因此"值 $< A[i]$"的约束在离散化后等价于"排名 $< rank(i)$"。

## 逐行代码解析

代码按逻辑阶段拆为 6 个模块：头文件与全局、BIT 结构与构造、BIT 更新（add/insert）、BIT 查询（get）、读入与离散化、主循环与输出。各模块的代码块按顺序拼接起来就是完整的 `.cpp`。

### 模块 1：头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
const int mod = 1e9 + 7;                    // 方案数取模的模数
inline int lowbit(int x) { return x & -x; }  // 返回 x 最低位 1 对应的值
```

- 要点 1：`mod` 是方案数取模用的模数；`lowbit(x)` 返回 $x$ 二进制最低位 $1$ 对应的值，是 BIT 所有跳转的基础。
- 要点 2：`x & -x` 依赖补码（$-x = \sim x + 1$），例如 `lowbit(6) = 2`。符号写错（如 `x & ~x`）会让 `insert`/`get` 的循环跳不动或越界。

### 模块 2：treearr 结构体与构造函数

```cpp
struct treearr
{
	vector<int> len;              // len[i]: BIT 节点 i 的最大 LIS 长度
	vector<int> cnt;              // cnt[i]: BIT 节点 i 的方案数
	int sz,ans_len,ans_cnt;       // sz: 值域大小; ans_*: 查询暂存
	treearr(int n)
	{
		len.assign(n + 1, 0);     // 下标从 1 开始，故开 n+1
		cnt.assign(n + 1, 0);
		sz = n;
		ans_len = 0, ans_cnt = 0;
	}
```

- 要点 1：`len`、`cnt` 两个数组配合，让每个 BIT 节点维护一个 $(max\_len, count)$ 二元组，把树状数组从"前缀和"推广为"前缀最大值 + 计数"。
- 要点 2：数组开到 `n + 1` 是因为 BIT 下标从 $1$ 开始、下标 $0$ 不使用；`sz` 记录值域大小，是 `insert` 里 `idx <= sz` 的边界依据。

### 模块 3：add 与 insert（BIT 更新）

```cpp
	void add(int idx,int num,int t_cnt)          // 单节点合并
	{
		if (num > len[idx]) len[idx] = num,cnt[idx] = t_cnt;           // 更优 → 替换
		else if (num == len[idx]) cnt[idx] = (cnt[idx] + t_cnt) % mod; // 等长 → 累加
	}
	void insert(int idx,int num,int t_cnt)       // 沿 lowbit 链向上传播
	{
		while (idx <= sz)                         // 上界：不能越过值域大小 sz
		{
			add(idx, num, t_cnt);
			idx += lowbit(idx);
		}
	}
```

- 要点 1：`add` 三种分支——`num > len` 替换（更优方案淘汰旧方案）、`num == len` 累加取模、`num < len` 忽略；这是"前缀最大值 BIT"的核心合并逻辑。
- 要点 2：`insert` 与标准 BIT 单点更新完全一致，沿 `idx += lowbit(idx)` 向上传播；循环条件是 `idx <= sz`，误写成 `< sz` 会漏更新最后一个节点。
- 要点 3：累加处 `(cnt[idx] + t_cnt) % mod` 的两个加数都小于 `mod`，和不超过 $2 \times 10^9 + 12$，仍在 `int` 范围内，不会溢出。

### 模块 4：get（BIT 前缀查询）

```cpp
	void get(int idx)                             // 查询前缀 [1, idx]
	{
		ans_len = 0, ans_cnt = 0;                  // 每次查询前清零暂存
		while (idx)                                // idx 归 0 即遍历完 [1, idx] 全部节点
		{
			if (len[idx] > ans_len)
			{
				ans_len = len[idx];
				ans_cnt = cnt[idx];
			}
			else if (len[idx] == ans_len) ans_cnt = (ans_cnt + cnt[idx]) % mod; // 等长 → 累加
			idx -= lowbit(idx);
		}
	}
```

- 要点 1：查询沿 `idx -= lowbit(idx)` 向下合并，覆盖值域前缀 $[1, idx]$ 的所有 BIT 节点；取最大 `len`，等长则 `cnt` 相加。
- 要点 2：循环条件写成 `while (idx)` 而非 `while (idx >= 0)`——下标减到 $0$ 表示前缀遍历完毕，再继续会越界访问 `len[0]`/`cnt[0]`。
- 要点 3：`get` 查的是 $\le idx$ 的前缀，对应"值 $\le$ 排名 idx 的元素"；为求严格递增，调用方传入 `A[i] - 1`（值 $<$ A[i]）。

### 模块 5：main 读入与离散化

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int T;
	cin >> T;
	while (T--)
	{
		int n,sz;                        // n: 序列长度
		cin >> n;
		vector<int> A(n + 1);            // 原始序列（之后就地改为排名）
		vector<int> tmp(n + 1);          // 离散化辅助数组
		for (int i = 1; i <= n; i++)
		{
			cin >> A[i];
			tmp[i] = A[i];
		}
		sort(tmp.begin() + 1, tmp.end());                          // 排序
		tmp.erase(unique(tmp.begin() + 1, tmp.end()), tmp.end());  // 去重
		treearr arr(tmp.size());         // BIT 大小 = 去重后 tmp.size()
```

- 要点 1：`sort` 从 `begin() + 1` 开始，因为 `tmp[0]` 是未使用的占位；`sort` + `unique` + `erase` 得到去重后的有序值域。
- 要点 2：读入下标从 $1$ 到 $n$，与离散化排名 $[1, m]$ 的 1-based 约定一致，避免后面 `get(A[i] - 1)` 退化成 `get(-1)` 越界。
- 要点 3：`treearr arr(tmp.size())` 用去重后的 `tmp.size()` 作为 BIT 大小（含未用的 `tmp[0]`，实际为 $m+1$），比所需多一个节点但不影响正确性。

### 模块 6：主循环转移与输出

```cpp
		for (int i = 1; i <= n; i++)
		{
			A[i] = lower_bound(tmp.begin() + 1, tmp.end(), A[i]) - tmp.begin(); // 值 → 排名 [1, m]
			arr.get(A[i] - 1);              // 查所有值 < A[i] 的前驱
			int new_len = arr.ans_len + 1;  // 在前驱最优长度上 +1
			int new_cnt = arr.ans_len ? arr.ans_cnt : 1;  // 无前驱时方案数为 1
			arr.insert(A[i], new_len, new_cnt);           // 插入当前元素信息
		}
		arr.get(tmp.size());                // 查询整个值域的全局最优
		cout << arr.ans_len << ' ' << arr.ans_cnt << '\n';
	}
	return 0;
}
```

- 要点 1：`lower_bound` 返回 `tmp` 中第一个等于 $A[i]$ 的位置，减去 `begin()` 得到排名 $[1, m]$（因 `tmp` 从下标 $1$ 开始）。
- 要点 2：`arr.get(A[i] - 1)` 查询排名 $<$ `rank(A[i])` 的前缀，对应值严格小于 $A[i]$；用 $A[i]-1$ 而非 $A[i]$ 保证严格递增（相同值不参与转移）。
- 要点 3：`new_cnt = arr.ans_len ? arr.ans_cnt : 1`——以 `ans_len` 是否大于 $0$ 判断有无前驱：`ans_len == 0` 表示无前驱（当前元素最小），LIS 长度为 $1$、方案数为 $1$（自身单独构成）；否则继承前驱方案数。用 `ans_len` 而非 `ans_cnt` 判断，避免方案数取模后恰好为 $0$ 时被误判为无前驱。
- 要点 4：`arr.insert(A[i], new_len, new_cnt)` 把当前元素信息写入 BIT，后续元素查询时能看到它；最终 `arr.get(tmp.size())` 取整个值域的全局最大长度与方案数。

## 复杂度分析

- **时间复杂度**：离散化（排序 $O(n \log n)$ + 去重 $O(n)$ + 逐个二分映射 $O(n \log n)$）；主循环 $n$ 个元素，每个做一次 `get`（$O(\log m)$）和一次 `insert`（$O(\log m)$），合计 $O(n \log m)$。由于 $m \le n$，总时间复杂度为 $O(n \log n)$。
- **空间复杂度**：`A` 和 `tmp` 各 $O(n)$，BIT 的 `len` 和 `cnt` 各 $O(m) \le O(n)$，总空间复杂度为 $O(n)$。

与朴素 $O(n^2)$ DP 相比，BIT 优化将内层转移从线性扫描降为对数查询。与二分优化的 LIS（$O(n \log n)$ 求长度但不求方案数）相比，BIT 优化在相同时间复杂度下额外支持方案数计数。

## 适用场景

需要同时求解 LIS 长度和方案数的场景（如统计最长上升子序列的个数）、值域较大或含负数需要离散化的场景、需要 $O(n \log n)$ 在线处理（元素逐个到达、实时查询）的场景。常见于竞赛中的 LIS 计数变种问题。

## 常见陷阱与注意事项

1. **严格递增 vs 非递减**：代码中 `get(A[i] - 1)` 查询 $rank - 1$ 保证严格递增（相同值不参与转移）。若需最长非递减子序列，应改为 `get(A[i])`（允许相同值参与转移）。
2. **方案数的模运算**：`cnt` 的累加在 `add` 和 `get` 中都取模。判断"是否有前驱"必须用 `ans_len`（代码中为 `new_cnt = arr.ans_len ? arr.ans_cnt : 1`），而不能用 `ans_cnt`——因为 `ans_cnt` 可能因取模后恰好为 $0$（实际方案数为 $mod$ 的倍数）而被误判为"无前驱"；`ans_len` 只可能为 $0$（无前驱）或正数（有前驱），不受取模影响。
3. **离散化的下标起点**：`tmp` 从下标 $1$ 开始（`tmp.begin() + 1`），`lower_bound` 返回值范围为 $[1, m]$。若误从下标 $0$ 开始，`A[i]` 可能映射到 $0$，导致 `get(A[i] - 1)` 查询 `get(-1)` 越界。
4. **BIT 大小**：BIT 大小应为离散化后的不同值个数 $m$，而非原始序列长度 $n$。当有重复值时 $m < n$，BIT 更省空间。
5. **多组数据的初始化**：每组测试数据新建 `treearr` 对象，自动初始化 `len` 和 `cnt` 为 $0$。若改为全局数组复用，需手动清零。
6. **`ans_len` 与 `ans_cnt` 的初值**：`get` 函数中 `ans_len = 0, ans_cnt = 0`，当查询结果为空（`idx = 0` 或所有节点 `len = 0`）时返回 $(0, 0)$。主循环中通过 `arr.ans_len ? arr.ans_cnt : 1` 处理此情况（以 `ans_len` 判断是否有前驱）。

## 对比与扩展

与朴素 $O(n^2)$ DP 相比，BIT 优化利用了"值域约束可转化为前缀查询"的性质，将内层转移从 $O(n)$ 降为 $O(\log n)$。与二分优化 LIS 相比，二分法仅求长度（$O(n \log n)$），无法直接计数；BIT 优化在相同复杂度下支持计数，但需要离散化预处理和更大的常数因子。

扩展方向包括：线段树替代 BIT（线段树支持区间查询，更灵活但常数更大）、带权 LIS（每个元素有权值，求最大权值上升子序列，需将 BIT 的合并规则改为权值相关）、二维 LIS（如俄罗斯套娃问题，需多维离散化）、以及将 BIT 优化思路推广到其他"值域约束型 DP"（如最长递增子序列的变种、LCS 转化为 LIS 问题等）。若需还原具体 LIS 路径而不仅计数，需额外维护前驱指针并回溯。$AKB97$, '动态规划', array['动态规划', '线性DP', '最长上升子序列', 'LIS', '树状数组', 'BIT', '离散化', '计数'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-maxsub', '长度不超过m的最大子段和', $AKB98$## 算法原理

求长度不超过 $m$ 的最大连续子段和。朴素做法枚举所有长度不超过 $m$ 的子段，复杂度 $O(n \times m)$。利用前缀和与单调队列可将复杂度降到 $O(n)$。

首先计算前缀和数组 $\text{sum}[i] = \sum_{k=1}^{i} A[k]$。任意子段 $A[l..r]$ 的和可表示为 $\text{sum}[r] - \text{sum}[l-1]$。问题转化为：对每个右端点 $i$，在窗口 $[i-m, i-1]$ 内找到最小的前缀和 $\text{sum}[j]$，使得 $\text{sum}[i] - \text{sum}[j]$ 最大。

这本质上是滑动窗口最小值问题：对每个 $i$，需要在长度为 $m$ 的窗口 $[i-m, i-1]$ 中维护前缀和的最小值。用单调递增队列维护——队首始终是窗口内前缀和最小的位置，队尾弹出所有大于等于当前前缀和的元素以保持单调性。

具体地，单调队列存储 $(\text{sum}[j], j)$。对每个 $i$：首先检查队首是否过期（$i - \text{que.front().second} \geq m$ 表示队首已滑出窗口），若过期则弹出。然后将 $\text{sum}[i-1]$ 入队——入队前弹出队尾所有前缀和值 $\geq \text{sum}[i-1]$ 的元素（因为它们不可能成为后续窗口的最小值）。最后，当前最大子段和为 $\text{sum}[i] - \text{que.front().first}$，更新全局最大值 $\text{ans}$。

每个元素最多入队出队各一次，均摊 $O(1)$，总体 $O(n)$。

## 状态定义与转移方程

前缀和定义：

$$\text{sum}[i] = \sum_{k=1}^{i} A[k]$$

子段和表示：

$$\text{sum}(A[l..r]) = \text{sum}[r] - \text{sum}[l-1]$$

对每个右端点 $i$，求窗口内最小前缀和：

$$\text{ans} = \max_{1 \leq i \leq n} \big(\text{sum}[i] - \min\{\text{sum}[j] : i - m \leq j \leq i - 1\}\big)$$

单调队列维护（$q$ 为单调递增队列）：

$$\text{若 } i - q.\text{front().second} \geq m: \quad q.\text{pop\_front()}$$

$$\text{while } q.\text{back().first} \geq \text{sum}[i-1]: \quad q.\text{pop\_back()}$$

## 逐行代码解析

### 全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
int n, m;
vector<long long> sum;
long long ans = -0x3f3f3f3f3f3f3f3f;
```

- **`sum` 数组**：前缀和数组，大小 $n+1$，`sum[0] = 0`。`sum[i]` 表示 $A[1] + A[2] + \ldots + A[i]$。
- **`ans` 变量**：全局最大子段和，初始化为极小值 $-0x3f3f3f3f3f3f3f3f$（`long long` 的负无穷），因为元素可能全为负。
- **`n, m`**：序列长度与子段长度上限，声明为全局变量便于 `main` 内直接使用。

### main 与读入

```cpp
int main()
{
	/*P1714*/
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	cin >> n >> m;
	sum.resize(n + 1,0);
	for(int i = 1;i <= n;i++) // 边读入边累加前缀和
	{
		long long x;
		cin >> x;
		sum[i] = sum[i - 1] + x;
	}
```

- **`ios::sync_with_stdio(false)` 与 `cin.tie(nullptr)`**：关闭 C 风格同步、解除输入输出绑定，加速大数据量读入。
- **`sum.resize(n + 1, 0)`**：分配 $n+1$ 个 `long long` 并清零，`sum[0] = 0` 作为空段的前缀和。
- **循环 `for(int i = 1; i <= n; i++)`**：从 $1$ 到 $n$（含）逐个数读入，用 `sum[i] = sum[i-1] + x` 累加出前缀和。

### 单调队列核心循环

```cpp
	deque<pair<long long ,int>> que;
	for(int i = 1;i <= n;i++)
	{
		if(!que.empty())
		{
			if(i - que.front().second >= m) que.pop_front(); // 队首滑出窗口则弹出
		}
		
		while(!que.empty() && que.back().first >= sum[i - 1]) que.pop_back(); // 弹出不小于 sum[i-1] 的队尾，保持单调递增
		que.emplace_back(sum[i - 1],i); // 入队左端点前缀和 sum[i-1]
		
		ans = max(sum[i] - que.front().first , ans); // 队首即窗口内最小前缀和
	}
```

- **`que` 单调队列**：`deque<pair<long long, int>>`，存储 $(前缀和值, 下标)$，维护单调递增。
- **队首出队**：`i - que.front().second >= m` 时弹出队首——表示队首位置距当前右端点已超过 $m$，滑出窗口（条件是 $\geq$ 而非 $>$）。
- **队尾维护 + 入队**：`while` 弹出所有前缀和值 $\geq \text{sum}[i-1]$ 的队尾元素（它们更大，不可能成为后续窗口的最小值），再入队 $(\text{sum}[i-1], i)$。注意入队的是 $\text{sum}[i-1]$（左端点的前缀和），而非 $\text{sum}[i]$。
- **更新答案**：`sum[i] - que.front().first` 是当前右端点 $i$ 的最大子段和，更新全局 `ans`。

### 输出

```cpp
	cout << ans;
	return 0;
}
```

- **`cout << ans`**：`ans` 即为长度不超过 $m$ 的最大子段和。
- **`return 0`**：程序正常结束。

## 复杂度分析

- **时间复杂度**：$O(n)$。前缀和计算 $O(n)$，单调队列处理每个元素最多入队出队各一次，均摊 $O(1)$，总计 $O(n)$。
- **空间复杂度**：$O(n)$。前缀和数组 $O(n)$，单调队列最坏 $O(n)$。

## 适用场景

适用于有长度上限的最大子段和问题（对应洛谷P1714），也可推广到最大子段积、带限制的最短/最长子段等变种。当子段长度无限制时，退化为经典的最大子段和（Kadane算法），$O(n)$ 无需单调队列。

## 常见陷阱与注意事项

- **`ans` 初始化为负无穷**：因为元素可能全为负，初始化为 $0$ 会得到错误答案。使用 $-0x3f3f3f3f3f3f3f3f$ 作为 `long long` 的负无穷。
- **入队的是 `sum[i-1]` 而非 `sum[i]`**：对右端点 $i$，子段和为 $\text{sum}[i] - \text{sum}[j]$（$j \in [i-m, i-1]$），因此队列中维护的是 $\text{sum}[i-1]$ 及之前的前缀和。
- **队首出队的条件**：`i - que.front().second >= m`（注意是 $\geq$ 不是 $>$），因为窗口范围为 $[i-m, i-1]$，长度为 $m$。
- **`long long` 类型**：前缀和可能很大，使用 `long long` 防止溢出。
- **窗口大小 $m$**：当 $m \geq n$ 时退化为无长度限制的最大子段和，算法仍然正确。

## 对比与扩展

与无限制的最大子段和（Kadane算法，$O(n)$ 无需单调队列）相比，本算法增加了长度约束，需用单调队列维护窗口内最小前缀和。单调队列是DP优化的重要工具，同样适用于多重背包的单调队列优化、固定窗口大小的最值查询等场景。可推广为最小子段和、最大子段积、带权子段和等变种。$AKB98$, '动态规划', array['动态规划', '线性DP', '单调队列', '前缀和', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-overview', '线性 DP 总览（LIS / LCS / 经典模型）', $AKB99$## 算法原理

本页是「线性 DP」的二级栏目索引：状态沿序列下标线性推进，按「以 i 结尾 / 前 i 个」定义状态，是区间、树形、状压等复杂 DP 的基础。

**学习顺序**：数字三角形 → 最大子段和 → LIS → LCS → 编辑距离 → 方格取数 / 整数划分。

## 核心公式 / 状态定义与转移方程

**按模型选子栏目**：

| 模型 | 子条目 |
|---|---|
| 路径/网格上的线性推进 | 数字三角形、方格取数 |
| 子段问题 | 长度不超过 m 的最大子段和 |
| 单序列子序列 | 最长上升子序列（二分）、（树状数组优化·带计数） |
| 双序列匹配 | 最长公共子序列（长度 / 带输出）、最长公共子串 |
| 字符串改造成本 | 字符串编辑距离 |
| 计数型线性 DP | 整数划分 |

## 逐行代码解析

本页只做导航，不重复贴代码；各子页都给出状态定义、转移与逐行解析，页面自动渲染对应 `.cpp`。

## 复杂度分析

- LIS 二分：$O(n\log n)$；LIS 树状数组带计数：$O(n\log n)$。
- LCS：$O(nm)$ 时间，滚动数组可降空间。
- 编辑距离：$O(nm)$。
- 数字三角形 / 最大子段和：$O(n^2)$ 或 $O(n)$。
- 整数划分：按具体模型为 $O(n^2)$ 或 $O(n\sqrt n)$。

## 适用场景

- 序列上的最优子结构问题（选/不选、匹配、分段）。
- 作为区间 DP、树形 DP 的子过程。
- 需要输出方案时用记录前驱的写法。

## 常见陷阱与注意事项

- LIS 的「严格上升」与「非降」在二分边界上不同。
- LCS 输出方案要额外记录转移来源，不能只回看数值。
- 最大子段和的「长度不超过 m」需要单调队列优化。
- 滚动数组要确认依赖方向，避免覆盖未使用状态。
- 计数型 DP 注意取模与初始状态。

## 对比与扩展

- 线性 DP vs 区间 DP：前者按下标推进，后者按区间长度推进。
- LIS 的 $O(n\log n)$ 写法本质是维护「长度为 k 的最小结尾」。
- 可扩展到带修 LIS、二维偏序等。$AKB99$, '动态规划', array['线性DP', 'LIS', 'LCS', '总览', '学习路线'], null, null, 'knowledge'),
('Fohen', 'col-dp-linear-triangle--fenfeng', '数字三角形 · Fohen', $AKB100$## 算法原理

数字三角形是最经典的路径型动态规划入门模型之一。给定一个 $n$ 层的数字三角形（第 $i$ 层有 $i$ 个数字），从顶部出发，每次只能向下或向右下走到相邻位置，求从顶部走到最底层路径上数字之和的最大值。

线性 DP 的核心特征是「状态按顺序递推」：状态往往与序列的位置、顺序有关，转移方向明确、没有环。数字三角形中，状态按照「行」的顺序逐层递推，正是线性 DP 的典型代表。

本题有两种等价的递推方向：**自上而下**（从顶部逐行往下推）与**自底向上**（从最底层往上推）。自上而下的状态定义是「从顶部走到 $(i,j)$ 的最大和」，最后需要遍历最后一行取最大值；自底向上的写法把状态定义为「从 $(i,j)$ 出发走到最底层能获得的最大和」，从最后一行开始原地累加，天然避免了边界判断，最终答案直接就是顶部 $f[1][1]$。本页代码采用自底向上的写法。

## 核心公式 / 状态定义与转移方程

### 状态定义

设 $f[i][j]$ 表示从顶部走到第 $i$ 行第 $j$ 列（自上而下视角），或从 $(i,j)$ 出发走到最底层（自底向上视角）所能获得的最大路径和。

### 自上而下的转移

$$
f[i][j] = val[i][j] + \max\big(f[i-1][j],\, f[i-1][j-1]\big)
$$

即当前格子的值，加上左上方 $f[i-1][j-1]$ 与正上方 $f[i-1][j]$ 两个来源中的较大者。

### 自底向上的转移（本页代码采用）

$$
f[i][j] := f[i][j] + \max\big(f[i+1][j],\, f[i+1][j+1]\big)
$$

即从最后一行开始，把每个格子的值累加上它正下方 $f[i+1][j]$ 与右下方 $f[i+1][j+1]$ 两个格子中的较大者。逐层往上，最终答案就是：

$$
\text{ans} = f[1][1]
$$

## 逐行代码解析

### 头文件与全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
int f[1010][1010];
```

- `f` 是全局二维数组，既用来读入三角形，又原地用作 DP 表，节省空间。
- 全局数组默认初始化为 $0$；对于自底向上写法，读入时已覆盖所有有效位置，无需额外清零。

### 读入三角形

```cpp
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=i;j++){
            cin>>f[i][j];
        }
    }
```

- 关闭同步流并解除绑定，加快输入输出。
- 第 $i$ 行只有 $i$ 个数字，因此内层循环上界是 `i` 而不是 `n`。

### 自底向上 DP

```cpp
    for(int i=n-1;i>=1;i--){
        for(int j=1;j<=i;j++){
            f[i][j]+=max(f[i+1][j],f[i+1][j+1]);
        }
    }
```

- 从倒数第二行（$i=n-1$）开始，逐行向上枚举。
- 每个格子从下一层正下方与右下方的两个格子中取较大值累加到自身，得到「从该点出发走到最底层的最大和」。
- 自底向上时，每个格子下方必然存在合法的下一层格子，因此无需任何边界判断。

### 输出答案

```cpp
    cout<<f[1][1];
    return 0;
}
```

- 推完之后，顶部 $f[1][1]$ 即为全局最优路径和，直接输出即可。

## 复杂度分析

- **时间复杂度**：$O(n^2)$。状态数为 $\frac{n(n+1)}{2}$，每个状态只需 $O(1)$ 转移。
- **空间复杂度**：$O(n^2)$。`f` 数组为 $n \times n$。由于自底向上每行只依赖下一行，理论上可用一维滚动数组优化到 $O(n)$（本页代码未做此优化）。

## 适用场景

- 数字三角形等「金字塔形」路径最值问题，是路径型线性 DP 的基础模板。
- 可作为学习「状态按行递推」与「顺推 / 逆推两种方向」的入门例题。
- 可推广为最小路径和、带障碍的路径计数、多方向移动的路径 DP 等变体。

## 常见陷阱与注意事项

- **内层循环上界是 `i`**：第 $i$ 行只有 $i$ 个数字，写成 `j<=n` 会读到未初始化的位置。
- **自底向上可免去边界判断**：正推写法需要处理第 $0$ 行、左上方 / 正上方越界等情况；自底向上从下一层取 `max`，两个来源始终合法，实现更简洁。
- **原地累加要求 `f` 先存原始值**：`f[i][j] += max(...)` 是在读入的原值上累加，读入完成后才能开始 DP，顺序不能颠倒。
- **数组大小**：模板中的 `1010` 需按题目 $n$ 的上限调整，避免越界。
- **正负权值**：自底向上写法对负数同样成立（每个格子始终取下一层两个合法格子的较大者）；若改用自上而下写法且数字可能为负，则需把无效边界初始化为 $-\infty$ 而非 $0$。

## 对比与扩展

- **自上而下 vs 自底向上**：两种方向都能求出答案。自上而下最后要在最后一行取最大值；自底向上答案直接是 $f[1][1]$，且省去边界处理。
- **最小路径和**：把 `max` 改为 `min` 即可求路径和的最小值。
- **带障碍的路径**：障碍格置为 $-\infty$（求最大）或 $+\infty$（求最小），转移时跳过。
- **多方向 / 更一般的矩阵路径**：把三角形推广为矩阵，转移来源变为上方与左方等，本质相同。
- **滚动数组优化**：自底向上每行只依赖下一行，可把二维数组压成一维，空间降到 $O(n)$。$AKB100$, '动态规划', array['动态规划', '线性DP', '数字三角形', '路径DP'], 'col-dp-linear-overview', null, 'knowledge'),
('Xesir', 'col-dp-linear-triangle--xesir', '数字三角形 · Xesir', $AKB101$## 算法原理

数字三角形：给定一个数字三角形，从顶部出发，每次只能向下或右下走，求路径上数字之和的最大值。

**正向（自顶向下）的状态设计**：设 `f[i][j]` 表示从顶部走到第 `i` 行第 `j` 列时能获得的最大和，转移非常简单：

$$f[i][j] = val[i][j] + \max(f[i-1][j],\ f[i-1][j-1])$$

但代码里用的是**自底向上**的写法，从最后一行开始往上推。这样做有两个好处：不用单独处理边界（顶部的「上方」并不存在），而且最终答案就是 `f[1][1]`，省掉了「最后一行取最大值」这一步。

自底向上的转移：

$$f[i][j] \mathrel{+}= \max(f[i+1][j],\ f[i+1][j+1])$$

即当前点累加上它下面两个方向（正下方、右下方）中较大的那个。

## 核心公式 / 状态定义与转移方程

- 自顶向下：$f[i][j] = val[i][j] + \max(f[i-1][j],\ f[i-1][j-1])$，边界 $f[1][1] = val[1][1]$，答案 $\max_{j} f[n][j]$。
- 自底向上（本代码采用）：$f[i][j] \mathrel{+}= \max(f[i+1][j],\ f[i+1][j+1])$，$i$ 从 $n-1$ 递减到 $1$，答案 $f[1][1]$。
- 第 $i$ 行只有 $i$ 个数，所以内层 `j` 的上界是 `i`（不是 `n`）。

## 逐行代码解析

### 头文件与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
int f[1010][1010];
```

- `f` 直接当二维数组用，边长上限 1010，够 $n \le 1000$ 的规模。
- 这里**没有**多开行列：因为自底向上从下往上推，转移只会用到「下一行」的 `j` 与 `j+1`，读的都是已就位的格子，不存在越界。

### main 开头与读入三角形

```cpp
int main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=i;j++){
            cin>>f[i][j];
        }
    }
```

- 关同步 + 解绑，读入更快。
- 读入时第 $i$ 行只读 $i$ 个数，恰好把三角形铺进 `f` 的「左下三角」。

### 自底向上的核心转移

```cpp
    for(int i=n-1;i>=1;i--){
        for(int j=1;j<=i;j++){
            f[i][j]+=max(f[i+1][j],f[i+1][j+1]);
        }
    }
```

- 外层 `i` 从 $n-1$ 递减到 $1$：最后一行的值已经就位，从倒数第二行往上推。
- `f[i][j] += ...` 是**原地累加**，把「从 $(i,j)$ 出发到底层的最大和」直接压回 `f[i][j]`，不再需要另开一张表。
- `max(f[i+1][j], f[i+1][j+1])` 分别对应走正下方与走右下方。

### 输出答案

```cpp
    cout<<f[1][1];
    return 0;
}
```

- 推完后 `f[1][1]` 就是「从顶点到底层的最大路径和」，直接输出，无需再遍历最后一行取最大值。

## 复杂度分析

- **时间复杂度**：$O(n^2)$。转移次数为 $\sum_{i=1}^{n-1} i = \dfrac{n(n-1)}{2}$，每次 $O(1)$；读入同样是 $O(n^2)$，总量级仍为 $O(n^2)$。
- **空间复杂度**：$O(n^2)$，用来存整个三角形。DP 是原地累加，除输入数组外不再额外开表；若还想压空间，可只保留相邻两行滚成 $O(n)$（对本题规模意义不大）。

## 适用场景

数字三角形、矩阵里只能向下/向右走的路径最值问题，是路径 DP 的入门模板。可推广到：最小路径和（`max` 换 `min`）、带障碍的路径计数、多方向移动的路径 DP，以及「走两次」的方格取数进阶版（需要升维）。

## 常见陷阱与注意事项

1. **内层上界是 `i` 不是 `n`**：第 $i$ 行只有 $i$ 个数字，写成 `j<=n` 会读到未初始化的格子。
2. **自底向上时下标方向别写反**：`f[i+1][j]` 与 `f[i+1][j+1]` 是「下一行」的两列，写反就走成了另一条路径。
3. **答案位置要对上写法**：本写法答案是 `f[1][1]`；如果改成自顶向下，答案才需要遍历最后一行取最大值。
4. **数字可能为负**：本题按非负数讲解，`f` 全局默认 0 没问题；一旦数字可负，基准行必须来自真实输入，不能靠初值兜底。
5. **数据范围**：`f` 开到 1010 只够边长 1000，$n$ 更大要相应加大数组。

## 对比与扩展

| 写法 | 状态含义 | 边界处理 | 答案 |
|---|---|---|---|
| 自顶向下 | 从 $(1,1)$ 走到 $(i,j)$ | 需处理 $j-1$ 与 $j>i-1$ 越界 | 最后一行取最大值 |
| 自底向上（本代码） | 从 $(i,j)$ 走到最底层 | 天然无越界 | `f[1][1]` |

扩展方向：换成求最小值、加上「不能经过障碍格」的限制，以及把转移维度从二维提升到「走两次」的方格取数（见 `dp-grid-number-pick`）。$AKB101$, '动态规划', array['动态规划', '线性DP', '数字三角形', '路径DP', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-linear-triangle', '数字三角形', $AKB102$## 算法原理

数字三角形是最经典的路径DP入门题。给定一个 $n$ 层的数字三角形（第 $i$ 层有 $i$ 个数字），从顶部出发走到最底层，每次只能走到正下方或右下方的相邻位置，求路径上数字之和的最大值。

状态定义 $dp[i][j]$ 表示从顶部走到第 $i$ 行第 $j$ 列时的最大路径和。从顶部 $(1, 1)$ 出发，到达 $(i, j)$ 的路径只能从上方两个位置之一转移而来：左上方 $(i-1, j-1)$ 或正上方 $(i-1, j)$。取两者较大值加上当前位置的数字 $A[i][j]$，即为 $dp[i][j]$。

转移方程 $dp[i][j] = \max(dp[i-1][j-1], dp[i-1][j]) + A[i][j]$ 体现了"每次只能向下走一步"的约束。边界条件为 $dp[1][1] = A[1][1]$（顶部只有一个数），第 $0$ 行和越界位置为 $0$（代码中通过多开两行两列处理边界）。

DP表从上到下、从左到右逐行填充。由于每行的状态只依赖上一行，可使用滚动数组优化空间到 $O(n)$。最终答案在最后一行取最大值：$\text{ans} = \max_{j} dp[n][j]$，因为终点可以是最后一行的任意一列。

## 状态定义与转移方程

状态定义：

$$dp[i][j] = \text{从顶部 } (1,1) \text{ 走到 } (i,j) \text{ 的最大路径和}$$

状态转移方程：

$$dp[i][j] = \max\big(dp[i-1][j-1],\; dp[i-1][j]\big) + A[i][j]$$

边界条件：

$$dp[1][1] = A[1][1]$$

最终答案：

$$\text{ans} = \max_{1 \leq j \leq n} dp[n][j]$$

## 逐行代码解析

代码按功能拆成 4 个模块：头文件与全局变量、随机数据生成、DP 模板、求答案与输出。

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
#include<random>
using namespace std;
int n,m; // n 为三角形层数；m 声明后未使用
vector<vector<int>> A; // 存三角形，后面多开两行两列防越界
```

- 要点 1：`n` 存层数，`A` 是全局二维数组，后面用 `resize` 开成 $(n+2)\times(n+2)$。
- 要点 2：多开两行两列，使转移时的 `A[i-1][j-1]`、`A[i-1][j]` 碰到第 $0$ 行/第 $0$ 列也不会越界。

### 随机数据生成（题目生成）

```cpp
int main()
{
	//题目生成 
	random_device rd; // 真随机种子源
	mt19937 gen(rd()); // 梅森旋转随机数引擎
	uniform_int_distribution<int> dis1(1,10); // 层数 n ∈ [1,10]
	uniform_int_distribution<int> dis2(1,10000); // 每个格子数字 ∈ [1,10000]
	n = dis1(gen); // 随机生成层数
	A.resize(n + 2,vector<int>(n + 2,0)); // 开 (n+2)×(n+2) 并清零
	for(int i = 1;i <= n;i++) // 逐行
	{
		for(int j = 1;j <= i;j++) // 第 i 行有 i 个数字
		{
			A[i][j] = dis2(gen); // 随机填数
			cout << A[i][j] << '\t'; // 打印三角形，制表符分隔
		}
		cout << endl; // 每行结束换行
	}
```

- 要点 1：`dis1` 生成层数 $n$（$1\sim10$），`dis2` 生成每个格子的数字（$1\sim10000$）。
- 要点 2：内层循环上界是 `i` 而不是 `n`，因为第 $i$ 行只有 $i$ 个数字。
- 要点 3：`A.resize(n + 2, vector<int>(n + 2, 0))` 先开空间再赋值，两个维度都多开 2，避免 `j-1` 越界。

### DP 模板（核心转移）

```cpp
	//模板
	vector<vector<int>> dp(n + 2,vector<int>(n + 2 , 0)); // dp 表初始化为 0
	for(int i = 1;i <= n;i++) // 从上到下逐行
	{
		for(int j = 1;j <= i;j++) // 第 i 行只有 i 列有效
		{
			dp[i][j] = max(dp[i - 1][j - 1] , dp[i - 1][j]) + A[i][j]; // 左上方/正上方取大 + 当前值
		}
	}
```

- 要点 1：`dp[i][j]` 表示从顶部走到 $(i,j)$ 的最大路径和，初值全 $0$，第 $0$ 行和越界位置自动为 $0$。
- 要点 2：核心转移 `max(dp[i-1][j-1], dp[i-1][j]) + A[i][j]`，从左上方和正上方取较大者再加当前数字。
- 要点 3：`dp` 同样开 $(n+2)\times(n+2)$，使 $j>i-1$ 时 `dp[i-1][j]` 落到 $0$，自动处理"正上方越界"。

### 求答案与输出

```cpp
	int ans = 0; // 答案初值 0（本题数据全正，安全）
	for(int i = 1;i <= n;i++) ans = max(ans,dp[n][i]); // 最后一行取最大值
	cout << ans; // 输出答案
	return 0;
}
```

- 要点 1：终点是最后一行的任意列，所以要遍历 `dp[n][1..n]` 取最大，而不是 `dp[n][n]`。
- 要点 2：`ans` 初值取 $0$ 只在数字全正时正确；若数字可为负，应初始化为 $-\infty$ 或 `dp[n][1]`。

## 复杂度分析

- **时间复杂度**：$O(n^2)$。双重循环共 $\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$ 次状态转移，每次 $O(1)$。最后遍历最后一行 $O(n)$，总体 $O(n^2)$。
- **空间复杂度**：$O(n^2)$。二维 `dp` 表和 `A` 数组各 $O(n^2)$。由于每行只依赖上一行，可用滚动数组优化为 $O(n)$。

## 适用场景

适用于数字三角形、矩阵从上到下的路径DP问题。是路径类DP的基础模板，可推广为最小路径和、带障碍的路径计数、多方向移动的路径DP等。

## 常见陷阱与注意事项

- **多开两行两列**：`A` 和 `dp` 均开 $(n+2) \times (n+2)$，避免 $j-1$ 越界时的额外判断。若不多开，需在转移前判断 $j-1 \geq 1$ 和 $j \leq i-1$。
- **第 $0$ 行的值**：`dp[0][j]` 为 $0$（初始化值），这意味着越界位置自动按 $0$ 处理。若数字可能为负，需将 `dp` 初始化为 $-\infty$。
- **答案在最后一行取最大值**：终点可以是最后一行的任意位置，不是 `dp[n][n]` 而是遍历 `dp[n][1..n]` 取最大。
- **内层循环的范围**：第 $i$ 行只有 $i$ 个有效数字，`j` 从 $1$ 到 $i$，不是 $1$ 到 $n$。
- **正上方可能越界**：当 $j > i-1$ 时，`dp[i-1][j]` 对应越界位置（值为 $0$），由于多开列自动处理。

## 对比与扩展

与从左上到右下的矩阵路径DP（如最小路径和）类似，区别在于三角形的结构（第 $i$ 行有 $i$ 个元素）。可扩展为求最小路径和（`max` 改 `min`）、带障碍的路径（障碍位置 `dp` 值为 $-\infty$）、允许向左走的变种等。空间优化可用一维滚动数组（逆序遍历 $j$ 避免覆盖）。

- **自底向上的写法**：也可以反过来从最后一行向上倒推，把状态定义为 $dp[i][j]$ 表示「从 $(i,j)$ 出发走到最底层的最大路径和」。转移时原地累加，$dp[i][j]$ 加上正下方 $dp[i+1][j]$ 与右下方 $dp[i+1][j+1]$ 中的较大值，最后答案直接就是 $dp[1][1]$，免去了最后一行取最大值这一步边界处理。倒推写法如下：

```
for i = n-1 到 1:
    for j = 1 到 i:
        dp[i][j] += max(dp[i+1][j], dp[i+1][j+1])
ans = dp[1][1]
```$AKB102$, '动态规划', array['动态规划', '线性DP', '路径DP', 'DP'], 'col-dp-linear-overview', null, 'knowledge'),
('dbywsc', 'col-dp-memo-search--dbywsc', '记忆化搜索 · dbywsc', $AKB103$## 算法原理

记忆化搜索是“带记录表的 DFS”：用 DFS 枚举状态，但把已经算过的状态存起来，下次需要时直接返回，避免重复计算。

### 从斐波那契说起

递归求斐波那契：

$$
f_i=f_{i-1}+f_{i-2},\qquad f_1=f_2=1.
$$

直接递归会把同一个 $f_i$ 计算很多次，递归树上的节点大量重复，时间复杂度近似 $O(2^n)$。如果把第一次算出的 $f_i$ 存进数组 `dp[i]`，之后直接返回，每个状态只算一次，时间降到 $O(n)$，代价是 $O(n)$ 的空间。

这就是“用空间换时间”，也是记忆化搜索的核心。重复出现的子问题叫做**重叠子问题**。

### 思考步骤

记忆化搜索依赖 DFS，所以思考方式和 DFS 一致：

1. 状态怎么表示？
2. 初始状态 / 边界是什么？
3. 当前状态能转移到哪些状态？
4. 转移时是否要取最优 / 计数？
5. 哪些状态已经算过，怎么存？

### 状态存储

- 状态范围小且连续：用数组 `dp[...]`；
- 状态范围大或带负数：用 `std::map` / `std::unordered_map`，代价是多一个 $\log$；
- 多维状态：用多维数组或把状态编码成一个整数。

### 与动态规划的关系

记忆化搜索是动态规划的一种实现方式：它同样需要状态定义、边界、转移，只是用递归自顶向下计算。数位 DP、状压 DP、树上 DP 等用记忆化写往往更直观。

## 核心公式 / 状态定义与转移方程

- 斐波那契：$f_i=f_{i-1}+f_{i-2}$，$f_1=f_2=1$。
- 记忆化框架：

```text
solve(state):
    if state is boundary: return boundary_value
    if dp[state] has been calculated: return dp[state]
    res = combine(solve(next_state1), solve(next_state2), ...)
    dp[state] = res
    return res
```

- 时间复杂度：状态数 × 每个状态的转移代价（每个状态只算一次）。
- 空间复杂度：状态数 × 每个状态存储的值 + 递归栈深度。

## 逐行代码解析

### 斐波那契的记忆化

```cpp
long long dp[N];
bool vis[N];

long long f(int i) {
    if (i == 1 || i == 2) return 1;
    if (vis[i]) return dp[i];
    vis[i] = true;
    return dp[i] = f(i - 1) + f(i - 2);
}
```

- 边界 `i == 1 || i == 2` 直接返回 $1$。
- `vis[i]` 标记是否算过；算过就直接返回 `dp[i]`。
- 每个 $i$ 只算一次，时间 $O(n)$，空间 $O(n)$。

### 空调温度（最优化记忆化）

```text
solve(t):
    if t == target: return 0
    if t > target: return t - target        // 只能减，直接算
    if vis[t]: return dp[t]
    vis[t] = true
    dp[t] = min(solve(t + 1), solve(t - 2), solve(t * 2)) + 1
    return dp[t]
```

- 状态是当前温度 $t$，目标是 `target`。
- 当 $t>target$ 时，继续搜索没有意义，可以直接算出需要减的次数。
- 每个温度只算一次；温度范围有限，因此总复杂度与温度值域成正比。
- 若状态跨度大或含负数，可以用 `std::map` 存，时间多一个 $\log$。

### 滑雪（网格记忆化）

```text
solve(x, y):
    if dp[x][y] != -1: return dp[x][y]
    dp[x][y] = 1
    for each neighbor (nx, ny):
        if a[nx][ny] < a[x][y]:
            dp[x][y] = max(dp[x][y], solve(nx, ny) + 1)
    return dp[x][y]
```

- 状态是格子 $(x,y)$，值是“从该格子出发的最长下降路径”。
- 只能走到比当前格子低的位置，所以状态图无环，记忆化不会死循环。
- 每个格子只算一次，时间 $O(nm)$。

## 复杂度分析

- 时间复杂度 = 状态数 × 每个状态的转移代价。记忆化保证每个状态只计算一次。
- 空间复杂度 = 状态数 × 存储单元 + 递归栈深度。
- 用 `map` 存状态时，每次查询/插入多一个 $O(\log S)$，$S$ 为状态数。

## 适用场景

- 状态图是 DAG（无环），且存在大量重叠子问题。
- 递推顺序不明显，或状态不方便按维度顺序遍历。
- 数位 DP、状压 DP、树上 DP、博弈 DP 等。
- 状态范围大、需要离散化或哈希存储时，用 `map` 记忆化。

## 常见陷阱与注意事项

1. **忘记标记已访问**：只存 `dp` 不判 `vis`，仍会重复计算；可以用 `dp = -1` 表示未算。
2. **状态有环**：如果状态之间可以互相到达，记忆化会死循环；需要改递推或先证明无环。
3. **边界写错**：边界必须在递归入口先判断，否则可能访问非法状态。
4. **状态编码冲突**：多维状态压成一个整数时，进制要足够大，避免不同状态编码相同。
5. **`map` 的常数**：状态量大时 `map` 可能很慢，能用数组就用数组。
6. **递归深度**：状态链很长时可能爆栈，可以改递推或手动开栈。
7. **多测清空**：`dp` / `vis` 在多组数据间要清空，避免残留。

## 对比与扩展

- **记忆化搜索 vs 递推 DP**：两者本质相同；记忆化自顶向下、写起来接近 DFS，递推自底向上、常数更小。状态转移顺序不明显时记忆化更方便。
- **记忆化 vs 剪枝**：剪枝是“不搜明显不优的分支”，记忆化是“不重复搜已经算过的状态”；两者可以同时使用。
- **记忆化 vs 打表**：打表是预处理所有答案，记忆化是遇到才算；状态空间大但访问少时记忆化更省。
- **练习**：TW2014 斐波那契、P1507 空调温度 2、A5005 滑雪、LG1149 Function、ABC340C。$AKB103$, '动态规划', array['动态规划', '记忆化搜索', 'DFS', '重叠子问题', '剪枝'], 'col-hub-dp', null, 'knowledge'),
('Xesir', 'col-dp-mixed-bag--xesir', '混合背包 · Xesir', $AKB104$## 算法原理

> 详见云兰阁 DF1637。

把每种物品**分别处理**即可：是 01 就按 01 跑，是完全就正序跑，是多重就二进制拆分后按 01 跑。

插播一些背包 DP 实现细节：

- **初始化**：求最大价值一般初始化为 0，求最小代价初始化为 INF（或大数），注意区分。
- **边界**：根据题目信息（如是否要求装满）初始化，转移时只从有效状态转移。
- **滚动数组**：一维数组是常规操作，但要注意遍历顺序，01 倒序，完全正序，分组容量在外。

## 核心公式 / 状态定义与转移方程

用一个数量参数 `s` 区分三类物品：

| `s` 的取值 | 物品类型 | 处理方式 |
|---|---|---|
| `s = -1` | 01 背包 | 拆成 $1$ 件，按 01 逆序 |
| `s = 0` | 完全背包 | 直接正序 |
| `s > 0` | 多重背包 | 二进制拆分后按 01 逆序 |

转移只有一条：

$$
f[j] = \max\big(f[j],\ f[j - w] + v\big)
$$

区别只在容量 `j` 的**枚举方向**。

## 逐行代码解析

### 结构体与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;
struct Good{
    int v,w,type;
};
const int N = 2010;
int n, m, dp[N];
vector<Good> a;
```

- `Good` 多了一个 `type` 字段：`-1` 表示按 01 处理，`0` 表示按完全处理。
- `dp[N]` 是一维滚动数组，`a` 存展开后的所有物品。

### 读入与按类型拆分

```cpp
int main(){
    cin >> n >> m;
    for (int i = 1; i <= n; i++) {
        int v, w, s; cin >> v >> w >> s;
        if(s==-1) s=1;
        if(s>0){
             for (int k = 1; k <= s; k *= 2)
                    {
                        s -= k;
                        a.push_back({v * k, w * k,-1});
                    }
                    if (s > 0)
                        a.push_back({v * s, w * s,-1});
        }else{
            a.push_back({v,w,0});
        }

    }
```

- `if(s==-1) s=1;`：把 01 物品当成「数量为 1 的多重物品」，这样它也能走二进制拆分，最终 `type` 仍是 `-1`。
- `s > 0` 分支：二进制拆分，压入的每个物品都带 `type = -1`（按 01 处理）。
- `else` 分支：`s = 0`（完全背包），整件压入、`type = 0`。

### 按 type 分流转移与输出

```cpp
    for (auto i : a){
        if(i.type==-1){
            for (int j = m; j >= i.v; --j){
                dp[j] = max(dp[j], dp[j - i.v] + i.w);
            }
        }else{
            for(int j=i.v;j<=m;j++){
                dp[j]=max(dp[j],dp[j-i.v]+i.w);
            }
        }
    }
    cout << dp[m] << endl;
    return 0;
}
```

- `type == -1`：容量 `j` **倒序**，01 背包写法。
- 否则（`type == 0`）：容量 `j` **正序**，完全背包写法。
- 一条分支一个方向，正是「按类型分别处理」的落地。答案 `dp[m]`。

## 复杂度分析

- **时间复杂度**：$O(m \times \sum \log s[i])$，取决于各类物品拆出来多少件；完全背包部分每件只扫一趟 $O(m)$。
- **空间复杂度**：$O(m + \sum \log s[i])$，一维 DP 表加展开后的物品数。

## 适用场景

一份输入里同时混有 01、完全、多重三类物品的背包题。用统一的 `s` 参数 + `type` 标记即可一个框架全搞定。

## 常见陷阱与注意事项

1. **只看 `-1` 这一个负值**：代码里 `if(s==-1)` 只特判 $-1$；若出现别的负数（如 $-2$），会掉进 `else` 分支被**当成完全背包**，这是模板的隐含前提，读题时要确认负数只有 $-1$。
2. **方向别反**：`type == -1` 走逆序、`type == 0` 走正序，反了就变成另一类背包。
3. **拆分的 `s` 是形参**：`s -= k` 改的是这个物品副本，不影响下一件物品。
4. **数组大小**：`N=2010` 是容量维度，容量超了要改；拆出来的物品用 `vector` 无压力。
5. **初始化语义**：全 0 对应「不要求装满」，要求装满需 `dp[0]=0`、其余 $-\infty$。
6. **溢出**：改 `dp` 为 `long long` 并留意类型。

## 对比与扩展

| 类型 | 数量参数 | 容量方向 | 关键操作 |
|---|---|---|---|
| 01 | `s = -1` | 倒序 | 直接当 1 件 |
| 完全 | `s = 0` | 正序 | 直接正序 |
| 多重 | `s > 0` | 倒序 | 二进制拆分 |

扩展方向：把二进制拆分换成单调队列优化以处理极大的 $s$；或结合分组、二维费用等约束做成更通用的「万能背包」框架。$AKB104$, '动态规划', array['动态规划', '背包问题', '混合背包', '二进制优化', '多重背包', '完全背包'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-multi-bag-binary--xesir', '多重背包（二进制优化） · Xesir', $AKB105$## 算法原理

多重背包：每个物品有**有限个**数量 `s[i]`，可以选 0 到 `s[i]` 个（详见云兰阁 P1214(C9)）。

最朴素的做法：把每个物品拆成 `s[i]` 个独立的 01 物品，然后跑 01 背包。但这样复杂度是 $O(V \cdot \sum s[i])$，物品总数可能很大（比如 `n=100, s[i]=1000`），直接炸裂。

### 二进制优化

把 `s[i]` 拆成若干个 2 的幂次，再加一个余数，使得这些数能组合出 $0 \sim s[i]$ 的任意数量。每个新物品的重量 = 原重量 × 系数，价值 = 原价值 × 系数。例如 `s=13`，拆成 `1, 2, 4, 6`（$1+2+4=7$，再补个 6，凑够 13）。

这样转换出的物品数量只有 $O(\log n)$ 级别，对这些新物品做 01 背包，就把多重背包完美转化了。这种优化其实用到了**状态压缩**的思想。

## 核心公式 / 状态定义与转移方程

拆分形式：设 $s = 2^{k} - 1 + r$，其中 $r \in [0, 2^{k} - 1]$，则

$$
s = \underbrace{1 + 2 + 4 + \dots + 2^{k-1}}_{\text{2 的幂次}} + r
$$

这 $k+1$ 个数能组合出 $0 \sim s$ 的**任意**整数。拆出来的每个物品按 01 处理：

$$
f[j] = \max\big(f[j],\ f[j - w] + v\big)
$$

## 逐行代码解析

分三块看：先定义拆分后的物品，再读入并拆分，最后统一跑 01 背包。

### 结构体与全局数组

```cpp
#include <bits/stdc++.h>
using namespace std;

struct Good
{
    int v,w;
};
const int N = 2010;
int n, m, dp[N];
vector<Good> a;
```

- `Good` 描述「拆分后的一件物品」的重量与价值。
- `dp[N]` 是一维滚动数组（容量维度），`N=2010` 对应容量上界。
- `a` 用 `vector` 动态存放拆分出的**所有**物品，数量不固定所以不能用定长数组。

### 读入与二进制拆分

```cpp
int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; ++i)
    {
        int v, w, s; cin >> v >> w >> s;
        for (int k = 1; k <= s; k *= 2)
        {
            s -= k;
            a.push_back({v * k, w * k});
        }
        if (s > 0)
            a.push_back({v * s, w * s});
    }
```

- `k` 依次取 `1, 2, 4, 8, …`；每轮先 `s -= k`，再把「$k$ 个原物品打包」压进去：重量 `v*k`、价值 `w*k`。
- 循环结束时 `s` 就是剩下来的余数，`s > 0` 时再补一个 `{v*s, w*s}`。
- 这样 $s$ 件物品被压缩成 $O(\log s)$ 件 01 物品。

### 01 背包转移与输出

```cpp
    for (auto i : a)
        for (int j = m; j >= i.v; --j)
            dp[j] = max(dp[j], dp[j - i.v] + i.w);
    cout << dp[m] << endl;
    return 0;
}
```

- 遍历拆出的每件物品 `i`，容量 `j` **倒序**枚举——就是标准 01 背包。
- 注意这里 `i` 是 `Good` 类型，`i.v` 是它占的容量、`i.w` 是它的价值。
- 答案 `dp[m]` 即容量 `m` 下的最大价值。

## 复杂度分析

- **时间复杂度**：$O(V \times \sum \log s[i])$。每个物品被拆成 $O(\log s[i])$ 件，每件跑一遍容量循环。
- **空间复杂度**：$O(m + \sum \log s[i])$，即一维 DP 表加上拆分出的物品数量。

## 适用场景

每种物品有明确数量上限的多重背包题。`s[i]` 较大、朴素展开会超时时首选二进制优化；当 `s[i]` 特别大（比如到 $10^5$）再考虑单调队列优化。

## 常见陷阱与注意事项

1. **读入顺序对不上**：本段开头的行内小片段写的是 `cin >> w >> v >> s`（重量在前），而完整代码是 `cin >> v >> w >> s`——源里两处名字对调了，照抄时别混。
2. **拆分后物品数**：约 $\sum (\lfloor \log_2 s \rfloor + 1)$，用 `vector` 装最稳。
3. **容量倒序**：拆分后必须按 01 背包处理，`j` 倒序，否则就变成完全背包了。
4. **初始化**：全 0 对应「不要求装满」；要求装满则 `dp[0]=0`、其余 $-\infty$。
5. **数组大小**：`N=2010` 是容量维度，容量超过 2010 要改大。
6. **溢出**：价值累加可能超 `int`，兜不住就换 `long long`。

## 对比与扩展

| 做法 | 时间复杂度 | 说明 |
|---|---|---|
| 朴素展开 | $O(V \cdot \sum s[i])$ | 直接拆成 $s[i]$ 个 01 物品 |
| 二进制优化 | $O(V \cdot \sum \log s[i])$ | 本模板 |
| 单调队列优化 | $O(V \cdot n)$ | 代码稍复杂，$s$ 特别大时用 |

源笔记补充：多重背包还有**单调队列优化**，可以做到 $O(V \cdot n)$，但代码稍复杂，适用于 $s$ 特别大的情况；不过二进制优化已经够应付大多数题目了。$AKB105$, '动态规划', array['动态规划', '背包问题', '多重背包', '二进制优化', '状态压缩'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-multi-bag-binary', '多重背包（二进制优化）', $AKB106$## 算法原理

多重背包中第 $i$ 种物品有数量上限 $m_i$ 件，每件重量为 $w_i$、价值为 $u_i$。朴素做法是将每种物品展开为 $m_i$ 个独立物品按01背包处理，时间复杂度为 $O(W \times \sum m_i)$，当 $m_i$ 很大时不可接受。二进制优化将复杂度降到 $O\big(W \times \sum \log m_i\big)$。

核心思想基于二进制拆分原理：任何正整数 $m$ 可以表示为若干 $2$ 的幂次之和加上一个余数。具体地，令 $k = 1, 2, 4, 8, \ldots$，依次从 $m$ 中减去 $k$，将 $(u \times k, w \times k)$ 作为一个"打包物品"存入列表，直到 $m$ 不足以凑出下一个 $2$ 的幂，此时将剩余的 $m$ 作为一个打包物品。例如 $m = 13$ 拆分为 $1 + 2 + 4 + 6$，共 $4$ 个打包物品。

拆分后，这 $\lfloor \log_2 m \rfloor + 1$ 个打包物品的组合可以凑出 $0$ 到 $m$ 之间的任意整数件原物品。这是因为 $1, 2, 4, \ldots, 2^t$ 的子集和可以表示 $0$ 到 $2^{t+1} - 1$ 的所有整数，再加上余数项即可覆盖 $0$ 到 $m$。因此，对打包物品按01背包处理，等价于原问题。

拆分后物品数为 $\sum_{i=1}^{n} \big(\lfloor \log_2 m_i \rfloor + 1\big)$，远小于 $\sum m_i$。对拆分后的所有打包物品执行标准01背包（容量逆序遍历），即可在 $O\big(W \times \sum \log m_i\big)$ 的复杂度内求解。

## 状态定义与转移方程

二进制拆分（对第 $i$ 种物品，价值 $u$，重量 $w$，数量 $m$）：

$$k = 1, 2, 4, \ldots, 2^t, \quad \text{打包物品 } (u \times k, \; w \times k), \quad m \leftarrow m - k$$

当 $m$ 有剩余时：

$$\text{打包物品 } (u \times m_{\text{剩余}}, \; w \times m_{\text{剩余}})$$

拆分后01背包转移：

$$dp[j] = \max\big(dp[j],\; dp[j - w_k] + v_k\big), \quad j \geq w_k$$

最终答案：

$$\text{ans} = dp[W]$$

## 逐行代码解析

下面按逻辑阶段把整段代码拆成 5 个模块：头文件与全局变量 → main 与读入 → 读入并二进制拆分 → 01背包转移 → 输出。

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
int N , W;
vector<long long> dp;
vector<pair<long long , long long>> A;
/*洛谷P1776*/
```

- `N`、`W` 分别为物品种类数与背包容量，声明为全局变量，方便在 `main` 与各循环中直接使用。
- `dp` 是一维滚动数组，大小为 $W+1$、初始化为 $0$，使用 `long long` 防溢出；`dp[j]` 表示容量 $j$ 下能达到的最大价值。
- `A` 存储拆分后的打包物品，每个 `pair` 的 `first` 为打包价值（$u \times k$），`second` 为打包重量（$w \times k$）。

### main 与读入

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	cin >> N >> W;
	dp.resize(W + 1, 0);
```

- `ios::sync_with_stdio(false)` 关闭 C++ 与 C 标准输入输出的同步，`cin.tie(nullptr)` 解除 `cin`/`cout` 绑定，用于加快 IO。
- 读入物品种类数 `N` 与背包容量 `W` 后，把 `dp` 扩容到 $W+1$ 并全部置 $0$，保证下标 `dp[W]` 合法。

### 读入物品并二进制拆分

```cpp
	for (int i = 1; i <= N; i++)
	{
		long long u, w, m;
		cin >> u >> w >> m;
		for (int k = 1; k <= m; k <<= 1)
		{
			A.emplace_back(u * k , w * k);
			m -= k;
		}
		if (m) A.emplace_back(u * m, w * m);
	}
```

- 每次读入一种物品的价值 `u`、重量 `w`、数量 `m`；三者用 `long long`，因为乘以 $k$ 后数值可能很大。
- 内层 `k` 从 $1$ 开始每次左移一位（`k <<= 1`，即翻倍），把打包物品 $(u \times k,\ w \times k)$ 存入 `A`，并从 `m` 中减去 `k`；循环条件 `k <= m` 保证每次打包不超过剩余数量。
- 余数处理：拆分循环结束后若 `m` 仍大于 $0$，把剩余 `m` 件作为一个打包物品存入 `A`（如 $m = 13$ 拆成 $1 + 2 + 4 + 6$）。

### 01背包转移

```cpp
	for (int i = 0; i < A.size(); i++)
	{
		for (int j = W; j >= 1; j--)
		{
			if (j >= A[i].second) dp[j] = max(dp[j], dp[j - A[i].second] + A[i].first);
		}
	}
```

- 对 `A` 里所有打包物品做标准01背包：外层遍历每个打包物品，内层容量 `j` 从 $W$ 逆序到 $1$，保证每个打包物品最多被选一次。
- `if (j >= A[i].second)` 判断当前容量装得下该物品（$j \ge$ 打包重量），装得下才转移，避免下标越界。
- `A[i].first` 是打包价值、`A[i].second` 是打包重量，对应转移方程 $dp[j] = \max(dp[j],\ dp[j - w_k] + v_k)$。

### 输出

```cpp
	cout << dp[W];
	return 0;
}
```

- `dp[W]` 即容量 $W$ 下背包的最大价值，作为最终答案输出。
- `return 0;` 正常结束程序。

## 复杂度分析

- **时间复杂度**：$O\big(W \times \sum_{i=1}^{N} \log m_i\big)$。拆分后打包物品总数为 $\sum_{i=1}^{N} \big(\lfloor \log_2 m_i \rfloor + 1\big) = O\big(\sum \log m_i\big)$，对每个打包物品遍历容量 $W$，故总时间为 $O\big(W \times \sum \log m_i\big)$。
- **空间复杂度**：$O\big(W + \sum \log m_i\big)$。`dp` 数组 $O(W)$，打包物品列表 $O\big(\sum \log m_i\big)$。

## 适用场景

适用于每种物品有数量上限的多重背包问题（对应洛谷P1776），当 $m_i$ 较大（$10^4$ 级别）且 $W$ 也在 $10^4$ 级别时使用。当 $m_i$ 和 $W$ 均达到 $10^5$ 级别时需进一步用单调队列优化。

## 常见陷阱与注意事项

- **`k <<= 1` 的含义**：`k` 每次翻倍（$1 \to 2 \to 4 \to 8 \to \ldots$），这是二进制拆分的核心。注意 `k <<= 1` 等价于 `k *= 2`。
- **拆分循环的终止条件**：`k <= m` 确保每次打包不超过剩余数量。若写成 `k <= m` 的判断有误，可能导致打包数量超过实际。
- **余数项不可遗漏**：拆分后若 $m$ 仍有剩余（如 $m = 13$，拆出 $1+2+4=7$，剩余 $6$），必须将剩余作为最后一个打包物品，否则无法凑出所有 $0$ 到 $m$ 的数量。
- **`long long` 防溢出**：价值和重量乘以 $k$ 后可能很大，务必使用 `long long`。
- **容量逆序遍历**：打包物品按01背包处理，容量必须逆序，否则同一打包物品会被重复选取。

## 对比与扩展

与朴素多重背包（$O(W \times \sum m_i)$）相比，二进制优化通过拆分将物品数从 $\sum m_i$ 降到 $\sum \log m_i$，大幅降低复杂度。与单调队列优化（$O(N \times W)$）相比，二进制优化实现简单但复杂度略高。当 $W$ 和 $m_i$ 都很大（$10^5$ 级别）时，单调队列优化是更优选择。二进制拆分的思想也可用于其他需要"将大数量拆分为对数级别"的场景。$AKB106$, '动态规划', array['动态规划', '背包问题', '多重背包', '二进制优化', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-multi-bag-monotone', '多重背包（单调队列优化）', $AKB107$## 算法原理

单调队列优化是多重背包的最高效优化，将复杂度降到 $O(n \times W)$，适用于 $n$ 和 $W$ 均达到 $10^5$ 级别的场景。核心思想是将转移方程转化为滑动窗口最值问题，用单调队列在 $O(1)$ 均摊时间内完成每次转移。

对于第 $i$ 种物品（价值 $v$，重量 $w$，数量 $m$），转移方程为 $dp[j] = \max_{0 \leq k \leq \min(m, \lfloor j/w \rfloor)} \big(dp[j - k \times w] + k \times v\big)$。观察发现，$j$ 的转移只依赖于 $j' = j - k \times w$（即与 $j$ 模 $w$ 同余的位置），因此将所有容量按 $\bmod \; w$ 分为 $w$ 组，每组内的转移是独立的。

在同余数类 $r$（$r = 0, 1, \ldots, w-1$）中，容量序列为 $r, r+w, r+2w, \ldots$。对位置 $j = r + t \times w$，转移为 $dp[j] = \max_{0 \leq k \leq m} \big(dp[r + (t-k) \times w] + k \times v\big)$。这等价于在滑动窗口 $[t-m, t]$ 内求 $dp[r + s \times w] - s \times v$ 的最大值再加上 $t \times v$——这是经典的滑动窗口最大值问题，用单调递减队列维护即可。

单调队列存储 $(位置 j, dp[j]值)$。队首出队条件为窗口距离超过 $m$ 件物品（即 $(j - \text{que.front().first}) / w > m$）。队尾维护时弹出所有不如当前优的元素（即 $dp[j] \geq \text{que.back().second} + (j - \text{que.back().first}) / w \times v$）。更新 $dp[j]$ 为队首值加上偏移量。

## 状态定义与转移方程

原始转移方程：

$$dp[j] = \max_{0 \leq k \leq \min(m,\; \lfloor j/w \rfloor)} \big(dp[j - k \times w] + k \times v\big)$$

同余类分组后，对 $j = r + t \times w$：

$$dp[j] = \max_{0 \leq k \leq m} \big(dp[r + (t-k) \times w] + k \times v\big)$$

单调队列更新（$q$ 为单调递减队列，存储位置对）：

$$dp[j] = \text{q.front().second} + \frac{j - \text{q.front().first}}{w} \times v$$

最终答案：

$$\text{ans} = dp[W]$$

## 逐行代码解析

以下按逻辑模块拆解完整代码；各模块的代码块按顺序拼接，即为 `Untitled1.cpp` 的完整实现。

### 头文件与命名空间

```cpp
#include<bits/stdc++.h>
using namespace std;
```

- `#include<bits/stdc++.h>` 是竞赛常用的万能头文件，一次性引入标准库常用组件（含 `vector`、`deque`、`pair`）。
- `using namespace std` 省去 `std::` 前缀，让 `vector`、`deque`、`pair` 等写法更简洁。

### 主函数与读入、初始化

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	long long n,W;
	cin >> n >> W;
	vector<long long> dp(W + 1,0);
	deque<pair<long long,long long>> que;
```

- `dp` 数组：一维滚动数组，大小 `W+1`，初始化为 `0`，统一用 `long long` 防价值溢出。
- `que` 单调队列：`deque<pair<long long,long long>>`，存储 `(位置 j, dp[j] 值)`，维护单调递减。
- `ios::sync_with_stdio(false)` 与 `cin.tie(nullptr);cout.tie(nullptr);` 关闭同步、解除输入输出绑定，加速大量读写。

### 物品循环与读入

```cpp
	while(n--)
	{
		long long v,w,m;
		cin >> v >> w >> m;
```

- 外层 `while(n--)` 逐个处理每种物品，`v` 为价值、`w` 为重量、`m` 为数量上限。
- 每种物品在上一种物品的 `dp` 基础上继续转移，因此循环结束时 `dp` 就是「考虑全部物品」的最优解。

### 同余类分组 + 单调队列转移

```cpp
		for(long long i = 0;i < w;i++)
		{
			que.clear(); 
			for(long long j = i;j <= W;j += w)
			{
				if(!que.empty() && (j - que.front().first) / w > m) que.pop_front(); 
				while(!que.empty() && dp[j] >= que.back().second + (j - que.back().first) / w * v) que.pop_back();
				que.emplace_back(j,dp[j]);
				dp[j] = que.front().second + (j - que.front().first) / w * v;
			}
		}
	}
```

- 同余类遍历：外层 `i` 从 `0` 到 `w-1` 枚举所有余数类，内层 `j` 以步长 `w` 遍历同余数容量（`j = i, i+w, i+2w, …`）；每类处理前 `que.clear()` 保证队列从空开始。
- 队首出队：`(j - que.front().first) / w > m` 表示队首位置与当前容量相差超过 `m` 件物品，已滑出窗口，弹出队首；因两者同余，整除是精确的。
- 队尾维护：`dp[j] >= que.back().second + (j - que.back().first) / w * v` 表示当前值（加上偏移量后）已不劣于队尾，弹出队尾以保持单调递减。
- 入队与更新：先把当前原始 `dp[j]` 用 `que.emplace_back(j,dp[j])` 入队，再用队首值加偏移量更新 `dp[j]`；入队必须先于更新，否则会用上已更新值。

### 输出答案

```cpp
	cout << dp[W];
	return 0;
} 
```

- `dp[W]` 即容量 `W` 下的最大价值，直接输出作为答案。
- `return 0;` 正常结束程序。

## 复杂度分析

- **时间复杂度**：$O(n \times W)$。每种物品遍历所有容量一次（$w$ 个同余类覆盖全部 $W+1$ 个位置），每个元素最多入队出队各一次，均摊 $O(1)$。总计 $n$ 种物品，总时间 $O(n \times W)$。
- **空间复杂度**：$O(W)$。`dp` 数组 $O(W)$，单调队列最坏 $O(W)$，但通常远小于 $W$。

## 适用场景

适用于数据范围极大的多重背包问题（$n$ 和 $W$ 均达到 $10^4$ 至 $10^5$ 级别），当二进制优化的 $O\big(W \times \sum \log m_i\big)$ 仍然不够快时使用。是多重背包的最优解法。

## 常见陷阱与注意事项

- **同余类分组**：必须按 $\bmod \; w$ 分组，每组独立处理。若不分组合并处理，转移会依赖错误的位置。
- **队列出队的判断条件**：用 $(j - \text{que.front().first}) / w > m$ 而非 $j - \text{que.front().first} > m \times w$，两者等价但前者更直接。
- **队尾维护的偏移量**：比较时必须加上 $(j - \text{que.back().first}) / w \times v$ 的偏移量，因为不同位置的 $dp$ 值加上不同件数的价值后才能公平比较。
- **入队时机**：先将原始 $dp[j]$ 入队，再用队首更新 $dp[j]$。顺序不能颠倒，否则会用到已更新的值。
- **`long long` 类型**：价值和偏移量乘积可能很大，务必使用 `long long`。
- **队列清空**：处理每种物品的每个同余类前需 `que.clear()`，确保队列从空开始。
- **重量为 $0$ 的物品**：当 $w = 0$ 时同余类循环 `for(i = 0; i < w; i++)` 一次都不执行，该物品会被整体跳过、价值漏算；一般约定输入合法（$w \ge 1$），否则应单独处理 $w=0$ 的情况。

## 对比与扩展

与二进制优化（$O\big(W \times \sum \log m_i\big)$）相比，单调队列优化进一步将复杂度降到 $O(n \times W)$，是多重背包的理论最优。但实现更复杂，需要理解同余分组和滑动窗口的思想。单调队列优化是DP优化的重要工具，同样适用于"长度不超过 $m$ 的最大子段和"等滑动窗口最值问题。理解本算法后可推广到其他需要"在窗口内取最值"的DP转移。$AKB107$, '动态规划', array['动态规划', '背包问题', '多重背包', '单调队列', 'DP'], 'col-dp-knapsack-overview', null, 'knowledge'),
('Xesir', 'col-dp-opt-monotone-queue--xesir', 'DP 优化（单调队列 / SOS） · Xesir', $AKB108$## 算法原理

顾名思义就是使用单调队列优化的 DP。这种 DP 的转移式一般长这样：

$$
dp[i]=a[i]+\max_{j \in [l,r]} (dp[j]+b[j])
$$

很显然直接模拟这个过程是 $O(n^2)$ 的石山。由于一般题目 $l,r$ 直接与 $i$ 有关，所以本质是**滑动窗口**问题，我们可以考虑用**单调队列**维护窗口内 $dp[j]+b[j]$ 的最值。

## 核心公式 / 状态定义与转移方程

设状态 $dp[i]$ 表示处理到第 $i$ 个位置时的最优值，转移形如：

$$
dp[i] = a[i] + \max_{j \in [l,r]} (dp[j] + b[j])
$$

其中窗口 $[l,r]$ 通常随 $i$ 滑动，即 $l,r$ 都是 $i$ 的函数。把要取最值的部分 $dp[j]+b[j]$ 丢进单调队列里维护，队首就是窗口内的最优决策 $j$。

## 逐行代码解析

下面把代码骨架按模块拆开讲，各块按顺序拼起来就是完整的一份骨架。

### 队列定义

```cpp
int q[N], head = 1, tail = 0;
```

- `q[N]` 是单调队列本体，存的是**下标**而不是数值，取用时再回去查 `f[q[...]]`。
- `head = 1, tail = 0` 是空队列的标准写法，配合 `head <= tail` 判空。

### 入队并维护单调性

```cpp
for (int i = 1; i <= n; i++) {
    int add = i - L;
    if (add >= 0 && f[add] > NEG) {
    while (head <= tail && f[q[tail]] <= f[add]) tail--;
        q[++tail] = add;
    }
```

- 能作为 $i$ 决策的新位置是 `add = i - L`，只有它**合法**（下标非负且不是不可达的 `NEG`）时才考虑入队。
- 入队前从队尾把 `f` 值**不大于** `f[add]` 的元素弹掉，保证队列里 `f` 值从队首到队尾**单调递减**，队首永远是最优决策。

### 弹出过期元素

```cpp
    while (head <= tail && q[head] < i - R) head++;
```

- 窗口右端是 $i-R$，队首下标一旦 `< i - R` 就滑出了可用范围，从队首弹出。

### 取值转移

```cpp
    if (head <= tail) f[i] = a[i] + f[q[head]];
    else f[i] = NEG;
}
```

- 队列非空时，队首就是窗口内的最优决策，直接 `f[i] = a[i] + f[q[head]]`。
- 队列为空说明窗口内没有任何合法前驱，当前状态不可达，置为 `NEG`。

## 复杂度分析

每个下标最多入队一次、出队一次，单调队列的总操作是线性的：

- 时间复杂度：$O(n)$，把原本 $O(n^2)$ 的「枚举窗口内所有决策」压成了均摊 $O(1)$ 的取队首。
- 空间复杂度：$O(n)$，即 `f` 数组加上单调队列 `q`。

## 适用场景

- 转移式中出现「对一段滑动窗口取最值」的 DP，且 $l,r$ 随 $i$ 单调移动。
- 典型如：限制跳跃长度的最值 DP、多重背包的单调队列优化、带窗口长度约束的线性 DP。

## 常见陷阱与注意事项

1. **队列存下标而不是数值**：入队、判过期、取值都依赖下标，存数值就没法判窗口过期。
2. **判空再取队首**：取 `f[q[head]]` 前一定要 `head <= tail`，否则空队列会读到越界的垃圾值。
3. **不可达状态别入队**：`f[add] > NEG` 这层判断不能少，否则 `NEG` 会污染最值。
4. **维护的比较方向要和单调性一致**：取最大值时队尾弹 `<=`，取最小值时弹 `>=`，写反了队首就不是最优。
5. **窗口边界 `L / R` 的含义**：确认 `i-L`、`i-R` 是可用决策区间的端点，别把 `l,r` 和 `L,R` 搞混。

## 附：SOS DP（子集和 / 高维前缀和）

SOS DP（Sum Over Subsets DP）本质上是**高维前缀和在二进制位上的应用**。它的作用是在 $O(n \cdot 2^n)$ 的时间内求出每个集合的所有子集（或超集）的贡献和。

高维前缀和的核心思想是：**在每个维度上独立做一次一维前缀和**。当维度是二进制位（取值只有 0 和 1）时，高维前缀和就变成了 SOS DP。

### 核心公式 / 状态定义与转移方程

给定长度为 $2^n$ 的数组 $f[mask]$，定义：

$$
F[mask] = \sum_{sub \subseteq mask} f[sub]
$$

即对每个 mask，求它所有子集的和。把每一位看作一个维度，$F$ 就是 $n$ 维数组的前缀和。

- **朴素做法**：枚举每个 mask，再枚举它的所有子集。
- **迭代做法**：按位逐维累加。

### 逐行代码解析

#### 朴素子集枚举

```cpp
for (int mask = 0; mask < (1 << n); mask++)
    for (int sub = mask; ; sub = (sub - 1) & mask) {
        F[mask] += f[sub];
        if (sub == 0) break;
    }
```

- 外层枚举 `mask`，内层用 `sub = (sub - 1) & mask` 枚举 `mask` 的所有子集（从 `mask` 本身一路往下减）。
- 到 `sub == 0` 时手工 `break` 收尾。
- 总复杂度 $O(3^n)$：每个元素有三种状态（不在 mask 中、在 mask 中不在 sub 中、在 sub 中）。

#### 迭代做法

```cpp
for (int i = 0; i < n; i++)          // 枚举每一位
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))         // 如果这一位是 1
            f[mask] += f[mask ^ (1 << i)];
```

- 外层枚举每一位 $i$（共 $n$ 个维度），内层扫所有 mask。
- 只对第 $i$ 位为 1 的 mask 累加：它的子集里把第 $i$ 位取 0 的那个 `mask ^ (1 << i)` 已经先算好了，直接加进来。
- 复杂度 $O(n \cdot 2^n)$，远优于 $O(3^n)$。

![](https://r2.xsimple-r2.com/gpt-image/497651/116e62d5-5d8c-41b2-81aa-c3e8c5a3bce8.png)

#### 子集和模板（求所有子集的和）

```cpp
for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))
            f[mask] += f[mask ^ (1 << i)];
```

#### 超集和模板（求所有超集的和）

```cpp
for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (!(mask & (1 << i)))
            f[mask] += f[mask | (1 << i)];
```

- 只需把判断条件反过来（`!(mask & (1 << i))`），累加方向也随之反转（从 `mask | (1 << i)` 加过来）。

### 复杂度分析

- 朴素子集枚举：$O(3^n)$。
- 迭代 SOS DP：$O(n \cdot 2^n)$。把「枚举每个 mask 的全部子集」拆成「按维度逐个累加」，一维只花 $O(2^n)$，共 $n$ 维。
- 空间复杂度：$O(2^n)$，在原数组 `f` 上原地累加，不需要额外数组。

### 适用场景

- **子集计数**：统计每个 mask 有多少个子集满足某种性质。
- **子集最值**：维护每个 mask 的所有子集中的最大值、次大值（如 Or Plus Max）。
- **超集统计**：统计每个 mask 的所有超集的信息。
- **状压 DP 预处理**：在状压 DP 中快速合并子集信息，避免枚举子集。
- **子集卷积**：SOS DP 是子集卷积的前置步骤。

### 常见陷阱与注意事项

1. **子集 / 超集的判断条件别写反**：子集和是 `mask & (1 << i)`（该位为 1 才累加），超集和是 `!(mask & (1 << i))`（该位为 0 才累加）。
2. **累加来源的下标要对应**：子集和从 `mask ^ (1 << i)`（清掉这一位）来，超集和从 `mask | (1 << i)`（补上这一位）来，别混。
3. **`n` 是位数不是元素个数**：数组长度是 $2^n$，循环上界写 `1 << n`，别漏了括号。
4. **原地累加**：`f[mask]` 直接在原数组上覆盖，保证依赖的 `f[mask ^ ...]` 是上一层（已处理完前面维度）的值，别把顺序改乱。$AKB108$, '动态规划', array['动态规划', 'DP优化', '单调队列', '滑动窗口'], null, null, 'knowledge'),
('Fohen', 'col-dp-rerooting--fenfeng', '换根 DP · Fohen', $AKB109$## 算法原理

换根 DP（Rerooting DP），又称「二次扫描与换根法」，是树形 DP 的一种常用技巧，用来解决「**要求分别以每个节点为根各算一次答案**」这类问题。

如果对每个节点都重新做一遍完整的树形 DP，总复杂度会达到 $O(n^2)$ 甚至更高。换根 DP 的核心思想是：先任选一个节点（通常取 $1$）作为根做一次 DP，再利用「根在相邻节点之间切换时，答案如何变化」这一关系，用 $O(1)$ 的时间从父节点的答案推出儿子节点的答案，从而在两次 DFS 内求出所有节点为根时的答案。

具体分两步：

1. **第一次 DFS（自底向上）**：任选 $1$ 为根，做一次普通树形 DP，同时维护子树统计量（如子树大小 `sz[u]`、子树内距离和 `dp[u]`），并得到「以 $1$ 为根」的答案。
2. **第二次 DFS（自顶向下换根）**：已知 `f[u]`（以 $u$ 为根时的全局答案），当根从 $u$ 换到它的儿子 $v$ 时，只需根据 `sz[v]` 等统计量调整答案，即可得到 `f[v]`。

本页以「STA-Station」为例：给定一棵 $n$ 个节点的树，求一个节点作为根时，所有节点的深度之和最大。即对每个点 $u$ 求 $\sum_{v} \text{dist}(u,v)$，取最大值。

## 核心公式 / 状态定义与转移方程

### 状态定义

| 符号 | 含义 |
|------|------|
| `sz[u]` | 在第一次 DFS 的树中，以 $u$ 为根的子树大小 |
| `dp[u]` | 以 $u$ 为根的子树内，所有节点到 $u$ 的距离之和 |
| `f[u]` | 以 $u$ 为整棵树的根时，所有节点到 $u$ 的距离之和（即最终答案） |

### 第一次 DFS（自底向上）

$$
dp[u] = \sum_{v \in \text{children}(u)} \big(dp[v] + sz[v]\big)
$$

其中 $sz[u] = 1 + \sum_{v \in \text{children}(u)} sz[v]$。

理解：把根从 $u$ 挪到它的儿子 $v$ 时，$v$ 子树内每个节点到 $u$ 的距离都比到 $v$ 多 $1$，所以 $v$ 这棵子树对 $u$ 的总贡献是 $dp[v] + sz[v]$。

### 第二次 DFS（自顶向下换根）

$$
f[v] = f[u] - sz[v] + (n - sz[v]) = f[u] + n - 2 \cdot sz[v]
$$

边界条件：$f[1] = dp[1]$（第一次 DFS 已求出以 $1$ 为根的答案）。

理解：根从 $u$ 换到儿子 $v$ 时，$v$ 子树内的 $sz[v]$ 个节点到根的距离各减少 $1$；其余 $n - sz[v]$ 个节点到根的距离各增加 $1$。一减一加，就得到上面的递推式。

### 答案

$$
\text{ans} = \max_{1 \le i \le n} f[i]
$$

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
vector<int> G1[1000010];                // 邻接表存树
int n,ans=0,jd=1;                       // n=节点数，ans=最大深度和，jd=最优根编号
int sz[1000010],f[1000010],dp[1000010]; // 子树大小 / 全局答案 / 子树内距离和
```

- 用邻接表 `G1` 存储无根树，之后通过「传父节点」的方式避免重复访问。
- `#define int long long` 把 `int` 全局替换为 `long long`，防止距离和溢出；因此 `main` 要用 `signed main()` 声明。
- `sz`、`dp`、`f` 三个数组分别对应状态定义中的三个量。

### 第一次 DFS：自底向上求 sz 与 dp

```cpp
void dfs1(int st,int pa){
	sz[st]=1,dp[st]=0;                 // 初始化：先把自己计入子树
	for(auto i:G1[st]){
		if(i==pa) continue;             // 跳过父节点，避免走回头路
		dfs1(i,st);                     // 先递归处理子树
		sz[st]+=sz[i];                  // 累加子树大小
		dp[st]+=dp[i]+sz[i];            // 累加距离和：dp[i] + sz[i]
	}
}
```

- 递归顺序是「先子树后根」：处理完儿子 $i$ 之后，`sz[i]` 与 `dp[i]` 才可用。
- `dp[st] += dp[i] + sz[i]` 正是公式 $dp[u] = \sum (dp[v] + sz[v])$ 的实现。
- `if(i==pa) continue;` 利用父节点标记，代替了 `vis` 数组，避免在树上回头。

### 第二次 DFS：自顶向下换根求 f

```cpp
void dfs2(int st,int pa){
	sz[st]=1,dp[st]=0;                 // 冗余初始化，不影响本函数求 f
	for(auto i:G1[st]){
		if(i==pa) continue;
		f[i]=f[st]+n-2*sz[i];           // 换根递推：f[v] = f[u] + n - 2·sz[v]
		dfs2(i,st);                     // 继续向下换根
	}
}
```

- 核心是 `f[i] = f[st] + n - 2*sz[i]`，对应公式 $f[v] = f[u] + n - 2 \cdot sz[v]$。
- 这里用到的 `sz[i]` 是第一次 DFS 中算好的子树大小，因此在第二次 DFS 之前必须先完成第一次 DFS。
- 函数体开头的 `sz[st]=1,dp[st]=0` 是从第一次 DFS 复制来的冗余语句，对本函数求 `f` 没有影响。

### 主函数：建图、两次 DFS 与取答案

```cpp
signed main(){
    cin>>n;
    for(int i=1;i<n;i++){
		int u,v;cin>>u>>v;
		G1[u].push_back(v);
		G1[v].push_back(u);
	}
	dfs1(1,-1);
	dfs2(1,-1);
	for(int i=1;i<=n;i++){
		if(ans<f[i]){ans=max(ans,f[i]);jd=i;}
	}
	cout<<jd;
    return 0;
}
```

- 读入 $n-1$ 条无向边，双向加边构造邻接表。
- 以 $1$ 为根做两次 DFS；第二次 DFS 的起点是 `dfs2(1,-1)`，因此需要 `f[1]` 已正确初始化。
- 最后遍历所有节点取 `f[i]` 的最大值，记录对应的根编号 `jd` 并输出。

## 复杂度分析

### 时间复杂度

两次 DFS 各访问每个节点和每条边一次，加上建图与最后扫描：

$$
O(n)
$$

换根 DP 的关键收益就是把「对每个根各做一次 DP」的 $O(n^2)$ 降为 $O(n)$。

### 空间复杂度

邻接表 $O(n)$，三个数组 `sz`、`dp`、`f` 各 $O(n)$：

$$
O(n)
$$

## 适用场景

- **树的「全根」统计**：求每个节点为根时的某个全局量，如深度之和、到所有节点的距离之和、树的重心等。
- **与子树大小挂钩的转移**：答案随根移动时，变化量可用子树大小等统计量 $O(1)$ 表示。
- **树的重心 / 深度和最大 / 到各点距离和** 等经典问题。

## 常见陷阱与注意事项

### 1. 第二次 DFS 前必须先完成第一次 DFS

`f` 的递推依赖第一次 DFS 算好的 `sz`，两次 DFS 的顺序不能颠倒。

### 2. 根节点的 f 要先赋值

换根递推的起点是根节点，必须先令 $f[\text{root}] = dp[\text{root}]$（本页中即 $f[1] = dp[1]$）。如果 `f[root]` 保持初值 $0$ 就向下递推，所有非根节点的答案都会算错。

### 3. 用父节点标记代替 vis 数组

树上 DFS 通过 `if(i == pa) continue;` 跳过父节点即可，不需要额外的 `vis` 数组，但根节点的父节点要传一个不存在的编号（如 $-1$）。

### 4. 距离和可能超出 int 范围

当 $n$ 较大时，$\sum \text{dist}(u,v)$ 可能达到 $O(n^2)$ 量级，要用 `long long`（本页用 `#define int long long` 处理）。

### 5. 换根时只变一条边的两端

换根只发生在相邻的 $u$ 和 $v$ 之间，其余节点到根的距离变化是一致的（要么都 $+1$、要么都 $-1$），因此才能 $O(1)$ 递推。

## 对比与扩展

### 与普通树形 DP 的对比

| | 普通树形 DP | 换根 DP |
|---|---|---|
| 答案数量 | 只求某一个根 | 求所有节点为根 |
| DFS 次数 | 一次 | 两次（一次自底向上、一次自顶向下） |
| 复杂度 | $O(n)$ | $O(n)$（而非 $O(n^2)$） |

### 扩展：更一般的换根

当换根时的变化量不能仅靠 `sz` 表示时，可以维护更丰富的统计量（如子树内最值、直径端点、前缀/后缀合并等）。核心不变：**先固定一个根算一次，再沿树边把答案从父节点「搬运」到子节点**。

换根 DP 与「树上前后缀合并」「二次扫描」本质相通，都是把「对每个位置重新算一遍」压缩成「算一次 + 沿边传递」。$AKB109$, '动态规划', array['换根DP', '树形DP', '二次扫描', '深度之和', '动态规划'], 'col-dp-tree-overview', null, 'knowledge'),
('Xesir', 'col-dp-rerooting--xesir', '换根 DP（STA-Station · Xesir 版） · Xesir', $AKB110$## 算法原理

换根 DP（二次扫描与换根法）用来解决「**要求分别以每个节点为根各算一次答案**」这类问题。若对每个根都重跑一遍树形 DP，复杂度会退化到 $O(n^2)$；换根法的核心是：先任选一个点（通常取 1）为根做一次自底向上的 DP，再利用「根从父节点切到相邻儿子时答案如何变化」的关系，$O(1)$ 地把答案推给儿子，两次 DFS 就能求出所有点为根时的值。

例题「STA-Station」：求一个节点作为根时，所有节点深度之和最大。对每个点 $u$ 求 $\sum_v dist(u,v)$，找最大的那个 $u$。

**第一次 DFS（自底向上）**，以 1 为根：

- `sz[u]`：子树大小。
- `dp[u]`：以 $u$ 为根的子树内，所有节点到 $u$ 的距离之和。

$$dp[u] = \sum_{v \in children(u)} \big(dp[v] + sz[v]\big)$$

**第二次 DFS（自顶向下，换根）**：设 `f[u]` 为以 $u$ 为根时所有节点到 $u$ 的距离之和，基准 `f[1] = dp[1]`。当根从 $u$ 换到它的儿子 $v$ 时，$v$ 子树内的 `sz[v]` 个点到根的距离都减少 1，其余 $n - sz[v]$ 个点都增加 1，于是

$$f[v] = f[u] - sz[v] + (n - sz[v]) = f[u] + n - 2 \cdot sz[v]$$

**答案**：取 `f[i]` 最大的节点编号。

## 核心公式 / 状态定义与转移方程

| 名称 | 含义 |
|---|---|
| `sz[u]` | 以 $u$ 为根的子树大小 |
| `dp[u]` | 子树内各点到 $u$ 的距离之和（不含 $u$ 到父节点的边） |
| `f[u]` | 以 $u$ 为根时全树各点到 $u$ 的距离之和 |

第一次 DFS 转移：$dp[u] = \sum_{v} (dp[v] + sz[v])$。

第二次 DFS 换根：$f[v] = f[u] + n - 2\,sz[v]$。

答案：$\arg\max_i f[i]$。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
vector<int> G1[1000010];
int n,ans=0,jd=1;
int sz[1000010],f[1000010],dp[1000010];
```

- `#define int long long` 统一 64 位整型，`main` 需写成 `signed main`。
- `G1` 是邻接表；`sz`、`f`、`dp` 三个数组分别对应上面的三种量；`jd` 记录答案节点编号，初值 1。

### dfs1：求子树大小与子树深度和

```cpp
void dfs1(int st,int pa){
	sz[st]=1,dp[st]=0;
	for(auto i:G1[st]){
		if(i==pa) continue;
		dfs1(i,st);
		sz[st]+=sz[i];
		dp[st]+=dp[i]+sz[i];
	}
}
```

- `sz[st]=1,dp[st]=0` 是初始化。每合并一个儿子：`sz[st]+=sz[i]`，子树深度和 `dp[st]+=dp[i]+sz[i]`——儿子子树内的每个点都要多走一条边，所以加上 `sz[i]`。
- `if(i==pa) continue;` 跳过父节点。

### dfs2：自顶向下换根

```cpp
void dfs2(int st,int pa){
	sz[st]=1,dp[st]=0;
	for(auto i:G1[st]){
		if(i==pa) continue;
		f[i]=f[st]+n-2*sz[i];
		dfs2(i,st);
	}
}
```

- 核心只有一行：`f[i]=f[st]+n-2*sz[i];`，就是换根公式。注意它用到的是 `sz[i]`——此时 `sz[i]` 还保存着 dfs1 算出的正确子树大小。
- 开头那句 `sz[st]=1,dp[st]=0;` 看起来像初始化，其实会**把 dfs1 算好的 `sz[st]` 覆盖成 1**。它能工作的原因是：`sz[i]` 只在被父亲用到的那一次需要正确，而父节点 `st` 早在 `dfs2(st)` 进入前就已经用过了 `sz[st]`，覆盖发生在使用之后，所以不影响结果（能过，但很依赖调用顺序）。
- `dp[st]=0` 在这轮里完全没用到。

### main：建树、求最大深度和的根

```cpp
signed main(){
    cin>>n;
    for(int i=1;i<n;i++){
		int u,v;cin>>u>>v;
		G1[u].push_back(v);
		G1[v].push_back(u);
	}
	dfs1(1,-1);
	dfs2(1,-1);
	for(int i=1;i<=n;i++){
		if(ans<f[i]){ans=max(ans,f[i]);jd=i;}
	}
	cout<<jd;
    return 0;
}
```

- 读 $n$ 个点和 $n-1$ 条无向边，双向建边。
- `dfs1(1,-1)` 求 `sz` 与 `dp`；`dfs2(1,-1)` 从根 1 出发推 `f`。
- 最后线性扫描找 `f[i]` 最大的编号 `jd` 并输出。

## 复杂度分析

- **时间复杂度**：$O(n)$。两次 DFS 各自把每条边、每个点处理常数次。
- **空间复杂度**：$O(n)$。邻接表加三个数组均为 $O(n)$。

## 适用场景

- 要求分别以每个节点为根计算答案，且根的移动能 $O(1)$ 递推的问题。
- 子树大小、深度和、点权和、重心 / 带权距离和等「全树统计」类问题。
- 典型题：STA-Station（本题）、树上到所有点距离之和的最值。

## 常见陷阱与注意事项

1. **`f[1]` 没有被显式赋值**：公式说基准是 `f[1] = dp[1]`，但代码里从没写过这一句，`f[1]` 依赖全局数组的零初始化（等于 0）。于是所有 `f[i]` 相比真值都**平移了一个常数 `dp[1]`**；因为最终只要 `f` 的**最大值的下标**，平移常量不改变 $\arg\max$，答案仍然正确。若不改用在别处（比如直接输出 `f` 值），这个坑就会暴露。
2. **`dfs2` 里的 `sz[st]=1` 会覆盖 dfs1 的结果**：它之所以无害，是因为 `sz[st]` 在被覆盖前已经被父节点用过；一旦调整遍历顺序就可能出错，读代码时要留意。
3. **`#define int long long` 的连带影响**：`main` 必须写 `signed main()`。
4. **递归爆栈**：$n$ 可达 $10^6$，链状树深度可能很大，递归版有爆栈风险，必要时开大栈或改迭代。
5. **双向边必须判父**：`if(i==pa) continue;` 两个 DFS 都不能漏。
6. **`ans` 初值与负值**：`ans=0` 且 `f` 可能为负（因平移），判据是 `ans<f[i]`；本题因真值非负，最大 `f` 一定不小于 0，所以能正常更新。

## 对比与扩展

- 与普通树形 DP 相比，换根 DP 多了「自顶向下推一遍」的第二遍 DFS，把「单根答案」升级成「所有根答案」。
- 与树上背包、最小支配集相比：那些是「合并子树」，换根 DP 是「把整棵树的信息从根往儿子传」。
- 扩展：把「距离之和」换成「点权之和、最远点距离」等，换根递推式相应改写即可。$AKB110$, '动态规划', array['动态规划', '树形DP', '换根DP', '二次扫描', '深度之和'], 'col-dp-tree-overview', null, 'knowledge'),
('Xesir', 'col-dp-subset-dp--xesir', '子集 DP（子集枚举 · 分组过桥 · 子集最值维护 · Xesir 版） · Xesir', $AKB111$## 算法原理

子集 DP 是状压 DP 的经典分支，专门处理那些需要**枚举子集**来转移的问题：对于当前状态 `S`，考虑它的所有非空真子集 `T`，再按 `T` 与 `S\T`（即 `S ^ T`）的关系转移。

枚举子集的「骚操作」是这样写的：

```cpp
for(int i=0;i<n;i++){
    for(int sta=(1<<n)-1;sta>=0;sta--){
        if(sta&(1<<i)) //转移
    }
}
```

它把每个 mask 拆成「不含第 $i$ 位」和「含第 $i$ 位」两类版本，等价于把子集的信息逐位向上传递。这个循环的总复杂度是 $O(3^n)$（每个元素有三种归属：不在 `sta` 里 / 在 `sta` 里但不在 `sub` 里 / 在 `sub` 里），$n \le 16$ 完全够用。

本文从源码里收录两个典型方向：

- **分组 DP**：枚举「最后一组」，把大问题 `mask` 拆成子问题 `mask ^ sub`。
- **子集信息合并**：像高维前缀和一样，把「所有子集」的信息逐位向上合并。

## 核心公式 / 状态定义与转移方程

### 分组过桥（以 2026WCA1009 分组过桥 为例）

桥有最大承重 $W$，$n$ 个人各有重量 $w_i$ 与过桥时间 $t_i$。每次只能让一个子集（一组）一起过桥，时间取该组中最慢的 $t_i$，且该组总重量不超过 $W$，求所有人过桥的最少总时间。

- 状态：`dp[mask]` 表示让 `mask` 里所有人过桥所需的最少时间，答案是 `dp[(1<<n)-1]`。
- 预处理：对每个子集 `mask` 预先算出总重量 `totW[mask]` 与最慢时间 `maxT[mask]`，这样可以 $O(1)$ 判断合法性并拿到「一次性过桥代价」。
- 转移：考虑最后一组为 `sub`，之前过桥的人是 `mask ^ sub`：

$$dp[\text{mask}] = \min_{\substack{sub \subseteq \text{mask},\ sub \neq \emptyset \\ totW[sub] \le W}} \Big(dp[\text{mask} \oplus sub] + maxT[sub]\Big)$$

代码里还有一种等价写法：枚举当前状态 `i`，枚举其子集 `j`，转移为 `dp[i] = min(dp[i], dp[i^j] + t[j])`，本质一样。

### 子集最大值维护（以 2026WCA1012 Or Plus Max 为例）

给定 $2^n$ 个数 $a_0, \dots, a_{2^n-1}$。对每个 $k$（$1 \le k < 2^n$），求满足 $(i \mid j) \le k$ 且 $i \ne j$ 的最大 $a_i + a_j$。

- **关键转化**：$(i \mid j) \le k$ 等价于 $i \subseteq k$ 且 $j \subseteq k$。所以对每个 $k$，只要知道「所有 $k$ 的子集下标」对应 $a$ 值中最大的两个（因为 $i \ne j$），相加就是答案。
- **状态维护**：`f[mask]` 是一个二元组 `(max1, max2)`，表示在所有 `sub ⊆ mask` 的下标中 $a_{sub}$ 的最大值与次大值。初始化 `f[i] = (a[i], -INF)`。
- **转移**（类似高维前缀和）：枚举每一位 `bit`，对所有包含该位的 `mask`，用 `mask ^ (1<<bit)` 的信息去更新 `mask`，即 `f[mask] = merge(f[mask], f[mask ^ (1<<bit)]);`，`merge` 负责保留两个最大的数。经过 $n$ 轮后，`f[mask]` 就含所有子集的最大与次大。
- **答案处理**：每个 $k$ 的 `f[k].max1 + f[k].max2` 即为该 $k$ 的最优值；由于答案随 $k$ 单调不减，用一个变量记录当前最大值依次输出即可。

## 逐行代码解析

### 分组过桥 · 头文件、宏与读入预处理

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int INF=INT_MAX;
//int cnt=0;
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int W,n;cin>>W>>n;
    vector<int> t(1<<n,0),w(1<<n,0),dp(1<<n,INF);
    for(int i=0;i<n;i++){
        int a,b;cin>>a>>b;
        for(int j=0;j<(1<<n);j++){
            if(j&(1<<i)){
                t[j]=max(t[j],a);
                w[j]+=b;
            }
        }
    }
}
```

- `#define int long long` 把整型扩到 64 位，配合 `signed main()` 使用。
- `t[j]`、`w[j]` 即 `maxT`、`totW`，`dp` 初值 `INF=INT_MAX`；三个 `vector` 都开到 `1<<n`。
- 读入每人 `(时间 a, 重量 b)` 后，遍历所有含第 $i$ 位的子集：`t[j]` 取最慢时间、`w[j]` 累加重量。这一步把 $O(n \cdot 2^n)$ 的预处理一次性做完。

### 分组过桥 · 子集枚举转移与快读快写

```cpp
    for(int i;i<(1<<n);i++){
        if(w[i]<=W) dp[i]=t[i];
        for(int j=i;j;j=i&(j-1)){
            if(w[i^j]<=W) dp[i]=min(dp[i],dp[j]+t[i^j]);
        }
    }
    cout<<dp[(1<<n)-1]<<'\n';
    return 0;
}
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `if(w[i]<=W) dp[i]=t[i]`：整个 `i` 作为一组一次过桥的代价。
- `for(int j=i;j;j=i&(j-1))` 是**枚举 `i` 的所有非空子集**的标准写法（`j` 从 `i` 递减，`j = i & (j-1)` 一直取到最小的非空子集，不会到 0）。
- `dp[i]=min(dp[i],dp[j]+t[i^j])`：把 `i` 拆成 `j` 和 `i^j` 两组，其中 `i^j` 是最后过桥的那组，需满足承重 `w[i^j]<=W`。
- `cout<<dp[(1<<n)-1]` 输出全员过桥的最小总时间；底部 `read` / `write` 是模板，本程序未调用。

### Or Plus Max · 头文件与全局

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=1<<19,INF=INT_MAX;
//int cnt=0;
int a[N];
PII f[N];
inline int read();
inline void write(int x);
PII mxp(PII a,PII b){
    if(a.fi<b.fi) swap(a,b);
    if(a.se<b.fi) a.se=b.fi;
    return a;
}
```

- `N=1<<19` 给足 $n \le 18$ 的空间（$1<<18 = 262144 < 524288$）；`a[i]` 存原数组，`f[i]` 存二元组 `(max1, max2)`。
- `mxp` 是合并函数：先把「首元素较大」的二元组放到 `a`，再用 `b` 的最大值去尝试更新 `a` 的次大值，返回合并后的结果。

### Or Plus Max · main 与答案统计

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n;cin>>n;
    for(int i=0;i<(1<<n);i++){
        cin>>a[i];
        f[i]={a[i],-INF};
    }
    for(int i=0;i<n;i++){
        for(int sta=(1<<n)-1;sta>=0;sta--){
            if(sta&(1<<i)) f[sta]=mxp(f[sta],f[sta^(1<<i)]);
        }
    }
    int ans=0;
    for(int i=1;i<(1<<n);i++){
        ans=max(f[i].fi+f[i].se,ans);
        cout<<ans<<'\n';
    }
    return 0;
}
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- 初始化 `f[i] = {a[i], -INF}`：单个下标的「最大值」是自己，「次大值」用 `-INF` 占位（表示还没有第二个数）。
- 双层循环就是高维前缀和写法：枚举每一位 `i`，对所有含该位的 `sta`，用 `sta ^ (1<<i)` 合并进 `sta`。$n$ 轮后每个 `f[sta]` 都统计完 `sta` 的所有子集。
- 输出时 `ans = max(f[i].fi + f[i].se, ans)` 再 `cout<<ans`：因为答案随 $k$ 单调不减，用滚动最大值输出。
- 底部 `read` / `write` 同样未被调用。

## 复杂度分析

**分组过桥**：

- 预处理每个子集的 `t`、`w`：$O(n \cdot 2^n)$。
- 子集枚举转移：每个 mask 枚举其子集，总计 $O(3^n)$。$n \le 16$ 轻松过。
- 空间：三个长度 `1<<n` 的数组，$O(2^n)$。

**Or Plus Max**：

- 高维前缀和式合并：外层 $n$ 位、内层 $2^n$ 个状态，$O(n \cdot 2^n)$。$n \le 18$ 完美。
- 空间：`a[N]` 与 `f[N]` 各 $O(2^n)$（此处按 $2^{19}$ 静态开满）。

## 适用场景

- 需要枚举子集做转移的集合划分问题（划分子集、分组覆盖、安排一批批完成的任务）。
- 子集信息合并 / 高维前缀和类问题（子集最值、子集计数、SOS DP）。
- 数据范围通常在 $n \le 16 \sim 20$。

## 常见陷阱与注意事项

1. **源程序里 `i` 没有初始化**：分组过桥的转移写成 `for(int i;i<(1<<n);i++)`，`i` **未初始化**即参与比较，属未定义行为（编译器可能给出随机初值）。源码如此，**照搬保留**；正确写法应是 `for(int i=0; i<(1<<n); i++)` 或先 `int i=0;`。
2. **枚举子集的起止**：`for(int j=i;j;j=i&(j-1))` 从 `i` 开始、条件为 `j` 非零，枚举的是 `i` 的**所有非空子集**；若需要包含空集，要另外处理。
3. **`INF` 取 `INT_MAX` 的加减**：转移里 `dp[j]+t[i^j]` 在 `dp[j]` 仍为 `INF` 时可能发生大数相加；因 `#define int long long` 把 `dp` 元素变成 64 位，实际不会溢出，但换回 32 位 `int` 就要小心。
4. **`-INF` 作次大值占位**：`f[i]={a[i],-INF}` 中 `-INF` 表示「暂时没有第二个数」；若改用 `INT_MIN`，相加时更容易出现异常值，选 `-INF` 更稳。
5. **答案要滚动取最大**：Or Plus Max 的答案随 $k$ 单调不减，必须输出 `ans`（历史最大），不能直接输出 `f[i].fi+f[i].se`。
6. **下标从 0 计**：`i \mid j \le k` 转成 `i ⊆ k` 时，位与下标一一对应，注意别把 0 号位搞错。
7. **静态开满内存**：`N=1<<19` 的数组按 `long long` 开大约是数 MB，$n$ 再大就要动态按 `1<<n` 开。

## 对比与扩展

- 与 TSP 状压对比：TSP 转移是「在 mask 上加一个还没访问的点」，子集 DP 的转移是「把 mask 拆成两个子集」，后者要枚举子集，故复杂度常为 $O(3^n)$。
- 与普通状压对比：分组过桥是「枚举子集」这一支，Or Plus Max 是「子集信息合并（高维前缀和）」这一支。
- 扩展：SOS DP（Sum over Subsets）就是 Or Plus Max 的一般化，把「两元组」换成计数 / 求和 / 最值即可；子集枚举还常用于容斥与集合幂级数。$AKB111$, '动态规划', array['动态规划', '状态压缩', '子集DP', '子集枚举', '高维前缀和'], 'col-dp-bitmask-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-tree-01bag', '树状01背包', $AKB112$## 算法原理

树状01背包是01背包与树形DP的结合。树上有 $N$ 个节点，每个节点有重量和价值，选中一个节点必须同时选中其父节点（保证连通性——即选了子节点就必须选父节点，形成"依赖"关系）。目标是在容量 $V$ 的限制下使选中节点的总价值最大。

算法通过 DFS 后序遍历处理。对每个节点 `idx`，先初始化其 `dp` 值：若容量 $j \geq$ 当前节点的重量，则 $dp[\text{idx}][j] = v_{\text{idx}}$（即只选当前节点本身），否则为 $0$。这一步体现了依赖关系——选了子节点的前提是当前节点已被选中。

然后将每个子树"合并"到当前节点。对子节点 `child`，先递归处理子节点（得到 $dp[\text{child}][\cdot]$），然后将子节点的 `dp` 值合并到当前节点。合并过程是一个树上分组背包：将总容量 $j$ 分配给当前节点自身和各子树，枚举分配给子树 `child` 的容量 $k$，转移为 $dp[\text{idx}][j] = \max(dp[\text{idx}][j-k] + dp[\text{child}][k], dp[\text{idx}][j])$。

容量 $j$ 逆序遍历（保证不重复计算），$k$ 从 $1$ 到 $j - w_{\text{idx}}$（预留当前节点的重量）。DFS 从根节点开始，最终答案为 $dp[\text{root}][V]$。

## 状态定义与转移方程

状态定义：

$$dp[\text{idx}][j] = \text{在以 idx 为根的子树中选取、总重量不超过 } j \text{ 时的最大价值}$$

初始化（体现依赖关系）：

$$dp[\text{idx}][j] = v_{\text{idx}}, \quad j \geq w_{\text{idx}}$$

合并子树（对子节点 `child`）：

$$dp[\text{idx}][j] = \max\big(dp[\text{idx}][j-k] + dp[\text{child}][k],\; dp[\text{idx}][j]\big)$$

最终答案：

$$\text{ans} = dp[\text{root}][V]$$

## 逐行代码解析

按功能把代码拆成 5 个模块，逐个模块讲解。

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
/*U436983*/
int N , V , root;
vector<pair<int,int>> A;
vector<vector<int>> son;
vector<vector<int>> dp;
```

- **`A` 数组**：`A[i].first` 存节点 $i$ 的重量，`A[i].second` 存价值。
- **`son` 数组**：邻接表，`son[p]` 存节点 $p$ 的所有子节点。
- **`dp` 表**：二维数组 $(N+1)\times(V+1)$，`dp[idx][j]` 表示以 `idx` 为根的子树中重量不超过 $j$ 时的最大价值。

### dfs：初始化当前节点

```cpp
void dfs(int idx)
{
	for(int i = A[idx].first;i <= V;i++) dp[idx][i] = A[idx].second; // 容量够就填当前节点自身价值，体现依赖关系
```

- 先假设"只选当前节点自己"：只要容量 $i \ge w_{\text{idx}}$（即 `A[idx].first`），就把 `dp[idx][i]` 设为价值 `A[idx].second`；容量不够的部分保持 $0$。
- 这一步体现依赖关系——子节点能累加价值的前提是父节点已被选中，所以先把父节点自身的价值铺满。

### dfs：合并子树（树上分组背包）

```cpp
	for(int i : son[idx])
	{
		dfs(i);
		for(int j = V ; j > A[idx].first ; j--) // 逆序枚举容量，防止同一子树被重复合并
		{
			for(int k = 1;j - k >= A[idx].first;k++) // 分给子树 i 的容量 k，预留父节点重量
			{
				dp[idx][j] = max(dp[idx][j - k] + dp[i][k] , dp[idx][j]);
			}
		}
	}
}
```

- 对每个子节点 `i` 先递归 `dfs(i)`，拿到子树的 `dp[i][]`，再把它合并进当前节点。
- 外层 `j` 从 $V$ **逆序**到 `A[idx].first + 1`：逆序是为了防止同一子树被重复合并；下界预留当前节点的重量。
- 内层 `k` 从 $1$ 到 `j - A[idx].first`：把容量 $k$ 分给子树 `i`，剩下 `j-k` 留给当前节点和已合并的子树。
- 转移 `dp[idx][j] = max(dp[idx][j-k] + dp[i][k], dp[idx][j])`，即"把子树按容量 $k$ 并进来"与"不并"取更大值。

### main：读入与建树

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);

	cin >> N >> V;
	dp.resize(N + 1,vector<int>(V + 1,0));
	A.resize(N + 1);
	son.resize(N + 1,vector<int>());
	for(int i = 1;i <= N;i++)
	{
		int p;
		cin >> A[i].first >> A[i].second >> p;
		if(p == -1) root = i;
		else son[p].emplace_back(i);
	}
```

- 前两行关闭 C/C++ 输入输出同步、解绑 `cin/cout`，加快读入速度。
- `dp / A / son` 都开成 $(N+1)$ 大小，下标从 $1$ 到 $N$，与"父节点标记 $-1$"区分开，避免下标 $0$ 冲突。
- 逐点读入重量、价值、父节点 `p`：`p == -1` 表示无父节点，即为根；否则把自己挂到 `son[p]` 的子节点列表里。

### main：求解与输出

```cpp
	dfs(root);
	cout << dp[root][V];
	return 0;
}
```

- 从根节点 `root` 开始 DFS，后序遍历整棵树完成所有合并。
- `dp[root][V]` 即以根为起点的最大价值，直接输出。

## 复杂度分析

- **时间复杂度**：最坏 $O(N \times V^2)$。每个节点合并子树时，三重循环（子节点 $\times$ 容量 $j$ $\times$ 分配 $k$）的最坏复杂度为 $O(V^2)$。优化后（利用子树大小的前缀和技巧）可降到 $O(N \times V)$，但本实现未优化。
- **空间复杂度**：$O(N \times V)$。每个节点维护一个长度 $V+1$ 的 `dp` 数组，共 $N$ 个节点。

## 适用场景

适用于树形依赖背包问题——选子节点必须先选父节点（对应U436983），也适用于有依赖关系的资源分配问题。当物品之间存在树形依赖关系（选A必须先选B）时使用。常见于游戏中的技能树解锁、课程先修关系等场景。

## 常见陷阱与注意事项

- **初始化体现依赖关系**：`dp[idx][j] = A[idx].second` 仅在 $j \geq w_{\text{idx}}$ 时设置，这意味着子节点的价值只能在父节点已选的基础上累加——这是依赖背包的核心。
- **容量逆序遍历**：合并子树时 `j` 逆序遍历，防止同一子树被重复合并。
- **`k` 的范围**：从 $1$ 到 $j - w_{\text{idx}}$，因为必须预留当前节点的重量。若 `k` 从 $0$ 开始会出错（$k=0$ 表示不给子树容量，但子节点仍需父节点已选）。
- **根节点的识别**：`p == -1` 标记根节点，题目保证只有一个根。
- **DFS的递归深度**：树可能为链状，递归深度达 $N$，需注意栈溢出（可改用迭代或手动栈）。
- **复杂度优化**：本实现为 $O(N \times V^2)$，可通过"左子树大小 + 右子树大小"的前缀和技巧优化到 $O(N \times V)$，但实现更复杂。
- **根节点缺失的兜底**：`root` 默认初始值为 $0$，若输入中没有任何 `p == -1`（根缺失），会误对 `dfs(0)` 调用。应读入后检查 `root` 是否为 $0$ 并视为非法输入，或约定输入保证有且仅有一个根。

## 对比与扩展

与标准01背包相比，树状01背包增加了依赖关系约束，通过DFS后序遍历和树上分组背包合并实现。与分组背包的联系在于：每个节点的子节点集合可以视为一个"组"，合并过程即为分组背包。可推广为泛化依赖背包（依赖关系为DAG而非树）、树上多重背包等变种。复杂度优化可利用DFS序将树形DP转化为序列上的背包问题，达到 $O(N \times V)$。$AKB112$, '动态规划', array['动态规划', '树形DP', '背包问题', '依赖背包', 'DFS', 'DP'], 'col-dp-tree-overview', null, 'knowledge'),
('Fohen', 'col-dp-tree-bag-optimize--fenfeng', '树形背包 O(nk) 优化 · Fohen', $AKB113$## 算法原理

树形背包把「树上的最优决策」和「背包问题」结合起来：以节点为单位，在 DFS 自底向上的过程中，把每个儿子的子树当作一个「物品组」，用分组背包的方式合并进父亲的状态里。朴素做法对「父亲容量」和「儿子贡献」各枚举一层，看似 $O(nk^2)$；但只要把每一维的枚举上界都限制在子树大小（或 $k$）以内，均摊后就是 $O(nk)$，这正是「树形背包 $O(nk)$ 优化」名字的由来。

以例题「树上染色」为例：给定一棵 $n$ 个点的带权树，要把其中恰好 $k$ 个点染成黑色、其余 $n-k$ 个点染成白色，最大化「所有黑点两两距离之和 + 所有白点两两距离之和」。直接枚举点对再求距离既不方便转移、也难与树的结构结合，于是把「点对距离」拆成「每条边的贡献」：

> 一条边 $(u,v)$ 对答案的贡献，等于「经过这条边的同色点对数量 × 这条边的边权」。而「经过这条边的同色点对数量」只由边两侧各自的颜色分布决定，也就是只依赖「子树里取了多少个黑点」。

这样，总答案就被写成所有边贡献之和，每条边的贡献只依赖子树内的黑点数，恰好可以用树形背包逐层合并求出。

## 核心公式 / 状态定义与转移方程

设树以 $1$ 为根，$sz_v$ 表示 $v$ 的子树大小，$k$ 表示要染的黑点数。

**状态定义**：$dp[u][j]$ 表示在 $u$ 的子树内选 $j$ 个黑点时，子树内部所有边的贡献之和（不含 $u$ 到父节点的那条边）。

**边贡献**：对于边 $(u,v)$（$v$ 是 $u$ 的儿子，边权为 $w$），若 $v$ 的子树内取了 $t$ 个黑点，则经过这条边的同色点对数为：

$$
t(k-t) + (sz_v - t)\big((n-k) - (sz_v - t)\big)
$$

第一项是「跨过这条边的黑点对」：$v$ 侧 $t$ 个黑点、另一侧 $k-t$ 个黑点，两两配对共 $t(k-t)$ 对；第二项是「跨过这条边的白点对」：$v$ 侧有 $sz_v-t$ 个白点、另一侧有 $(n-k)-(sz_v-t)$ 个白点。于是这条边的贡献为：

$$
w \cdot \left[\, t(k-t) + (sz_v - t)\big((n-k) - (sz_v - t)\big) \,\right]
$$

**转移方程**（把儿子 $v$ 合并进 $u$，枚举从 $v$ 子树取 $t$ 个黑点）：

$$
dp[u][m] = \max_{0 \le t \le \min(m,\,sz_v)} \Big( dp[u][m-t] + dp[v][t] + w \cdot \left[ t(k-t) + (sz_v-t)\big((n-k)-(sz_v-t)\big) \right] \Big)
$$

**初始化**：$dp[u][0] = dp[u][1] = 0$（$u$ 自身可白或黑，此时子树内还没有边，贡献为 $0$），其余状态初始化为 $-1$ 表示「不可达」（代码里用 `memset` 统一完成）。

**答案**：$dp[1][k]$。另外 $k$ 与 $n-k$ 黑白对称，可以先用 `if(n-k<k) k=n-k;` 把第二维压缩到不超过 $\lceil n/2 \rceil$。

## 逐行代码解析

### 头文件、宏与全局变量

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=2e3+10;
int cnt=0,n,k;
vector<PII> G1[N];
int siz[N],dp[N][N];
```

- `#define int long long` 把 `int` 全局替换成 `long long`，配合后文的 `signed main()`；边权与点对数的乘积可达 $10^{12}$ 量级，必须用 64 位整数避免溢出。
- `G1[x]` 是邻接表，元素 `PII` 的 `fi` 存邻居编号、`se` 存边权，`fi`/`se` 分别是 `first`/`second` 的宏缩写。
- `dp[N][N]` 是二维背包表，`dp[u][j]` 表示 $u$ 子树选 $j$ 个黑点时的贡献；`siz[N]` 存子树大小。
- `N=2e3+10` 对应数据范围 $n \le 2000$；`cnt` 是模板残留变量、未使用。

### dfs1 预处理子树大小

```cpp
void dfs1(int x,int fa){
	siz[x]=1;
	for(auto i:G1[x]){
		if(i.fi==fa) continue;
		dfs1(i.fi,x);
		siz[x]+=siz[i.fi];
	}
}
```

- 第一遍 DFS 只做一件事：自底向上统计每个点的子树大小 `siz[x]`。
- `siz[x]=1` 先把 $x$ 自己算进去，再跳过父节点、把每个儿子的 `siz` 累加进来。
- `siz` 在第二遍 DFS 中用于给背包维度设上界（`min(k, siz[x])`、`min(m, siz[v])`），是复杂度降到 $O(nk)$ 的关键。

### dfs2 树形背包主转移

```cpp
void dfs2(int x,int fa){
	dp[x][0]=dp[x][1]=0;
	for(auto j:G1[x]){
		if(j.fi==fa) continue;
        dfs2(j.fi,x);
		for(int m=min(k,siz[x]);m>=0;m--){
			if(dp[x][m]!=-1) dp[x][m]+=dp[j.fi][0]+siz[j.fi]*(n-k-siz[j.fi])*j.se;
			for(int v=min(m,siz[j.fi]);v>0;v--){
				if(dp[x][m-v]==-1) continue;
				int tot=v*(k-v)+(siz[j.fi]-v)*(n-k-siz[j.fi]+v);
				dp[x][m]=max(dp[x][m],dp[x][m-v]+dp[j.fi][v]+tot*j.se);
			}
		}
	}
}
```

- `dp[x][0]=dp[x][1]=0`：$x$ 自身可白（$0$ 个黑点）或黑（$1$ 个黑点），此时子树内还没有边，贡献为 $0$。
- 先递归 `dfs2(j.fi,x)` 算出儿子的完整状态，再用背包把它合并进 $x$；外层 `m` 逆序枚举，保证同一个儿子只被合并一次（0/1 背包性质）。
- `tot = v*(k-v)+(siz[j.fi]-v)*(n-k-siz[j.fi]+v)` 是「儿子子树取 $v$ 个黑点」时边 $(x,j)$ 的贡献：前一项是跨边黑点对、后一项是跨边白点对。
- 内层 `v` 从 $1$ 开始，$v=0$（儿子全白）的贡献由前一行 `dp[x][m]+=dp[j.fi][0]+siz[j.fi]*(n-k-siz[j.fi])*j.se` 单独补齐。

### 主函数

```cpp
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    memset(dp,-1,sizeof dp);
	cin>>n>>k;
    if(n-k<k) k=n-k;
	for(int i=1;i<n;i++){
		int u,v,w;cin>>u>>v>>w;
		G1[u].push_back({v,w});
		G1[v].push_back({u,w});
	}
	dfs1(1,0);
	dfs2(1,0);
	cout<<dp[1][k];
    return 0;
}
```

- `memset(dp,-1,sizeof dp)` 把整张 `dp` 表初始化为 $-1$（不可达），之后只有从 `dp[x][0]=dp[x][1]=0` 递推得到的状态才会被更新。
- `if(n-k<k) k=n-k;` 利用黑白对称性，取黑、白两色中数量较少的一方作为 `k`，显著缩小 DP 第二维。
- 读入 $n-1$ 条无向边并建双向邻接表，以 $1$ 为根先 `dfs1` 求子树大小、再 `dfs2` 做背包，答案即 `dp[1][k]`。
- 前两行 `read`/`write` 是模板自带的快读快写声明；本程序实际用 `cin/cout`，未调用它们。

### 快读快写辅助函数

```cpp
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `read()` 用 `getchar()` 逐字符读入整数，跳过前导空白并处理负号；`x=(x<<1)+(x<<3)+(ch^48)` 等价于 `x=x*10+(ch-'0')`。
- `write()` 递归按位输出：负数先输出 `-`，`x>9` 时先输出高位，最后 `putchar(x%10+'0')` 输出个位。
- 这两个函数是模板自带的快速 I/O 工具，本程序未调用，保留不影响正确性。

## 复杂度分析

- **时间复杂度 $O(nk)$**：合并儿子时，外层 `m` 的上界是 $\min(k, siz[x])$、内层 `v` 的上界是 $\min(m, siz[v])$，两层看似 $O(nk^2)$；但每一维都被子树大小截断，均摊后总复杂度为 $O(nk)$，可平稳通过 $n,k \le 2000$ 的数据（对应代码中的 $N=2\times10^3+10$）。
- **空间复杂度 $O(n^2)$**：代码用固定的二维表 `dp[N][N]` 存状态，即 $O(n^2)$。实际上有意义的状态只有 $\sum_u \min(k, siz[u]) = O(nk)$ 个；若按每个节点动态开 $\min(k,siz[u])+1$ 长度的数组，空间可进一步降到 $O(nk)$。

## 适用场景

- 树上「按数量分配 / 选点」的最优决策问题，状态为「子树内选了多少个」，如树上染色、树上资源分配。
- 带容量约束的树上背包：把每个儿子当作一个物品组，用分组背包合并进父亲。
- 需要把「全局距离 / 全局贡献」拆成「每条边的贡献」再逐层 DP 的树形计数与最优化题。
- 数据规模在 $n,k \le 10^3 \sim 10^4$ 量级、背包容量与 $n$ 同阶的树形背包题。

## 常见陷阱与注意事项

- **边贡献要在合并儿子时算**：边 $(u,v)$ 的贡献依赖 $v$ 子树内的黑点数 $t$，必须在合并 $v$ 的当下连同 `dp[v][t]` 一起加进转移，不能等整棵树合并完再统一处理。
- **dp 初始化为 -1 表示不可达**：`dp[x][0]=dp[x][1]=0` 是唯一合法起点，其余状态用 `memset(dp,-1,...)` 标记，转移前用 `if(dp[...]!=-1)` 判断，避免从不可达状态出发得到错误答案。
- **外层 m 必须逆序**：这是 0/1 背包合并，同一个儿子只能取一次；若正序枚举，`dp[x][m-v]` 会被本次已更新的值污染，导致同一儿子被重复使用。
- **黑白对称压缩维度**：$k$ 与 $n-k$ 对称，先 `if(n-k<k) k=n-k;` 把第二维缩到不超过 $n/2$，是本题通过大数据的关键。
- **用 64 位整数**：边贡献是「点对数量 × 边权」，量级可达 $O(n^2 \cdot w)$，`#define int long long` 必不可少。
- **$O(nk)$ 依赖维度截断**：若合并时把 `m`、`v` 都无脑枚举到 $k$ 而不做 `min(k, siz)` 截断，复杂度会退化成 $O(nk^2)$。

## 对比与扩展

- **对比「树状01背包」**（选子必选父的依赖背包）：本算法的状态是「子树内取了多少个黑点」，只关心数量、没有父子依赖，转移是「分组背包 + 边贡献」；依赖背包则把「选父才可选子」的约束写进状态与转移。
- **对比朴素树上背包 $O(nk^2)$**：朴素版把每维都枚举到 $k$，总复杂度 $O(nk^2)$；本算法用 $\min(k, siz)$ 截断每维，均摊降到 $O(nk)$。
- **扩展**：把「全局点对距离之和」拆成「每条边贡献」的技巧，可推广到树上两两距离求和、带权路径计数等需要按边统计的问题；分组背包的合并方式还能推广到虚树上的多组询问背包、树上依赖背包等变种。$AKB113$, '动态规划', array['树形背包', '树上染色', '树形DP', '背包DP', '边贡献转化'], 'col-dp-tree-overview', null, 'knowledge'),
('Xesir', 'col-dp-tree-bag-optimize--xesir', '树形背包 O(nk) 优化（树上染色 · Xesir 版） · Xesir', $AKB114$## 算法原理

树形背包把「树上的最优决策」和「背包问题」结合起来：以节点为单位，在 DFS 自底向上的过程中，把每个儿子的子树当作一个「物品组」合并进父亲的状态。朴素写法对「父亲容量」和「儿子贡献」各枚举一层，看着像 $O(nk^2)$；但只要把枚举上界限制在子树大小以内，把每一对「点」只在它们 LCA 处合并一次，均摊下来就是 $O(nk)$——这正是「树形背包 $O(nk)$ 优化」名字的由来。

例题「树上染色」：给一棵 $n$ 个点的带权树，把其中恰好 $k$ 个点染黑、其余 $n-k$ 个点染白，最大化「所有黑点两两距离之和 + 所有白点两两距离之和」。

直接枚举点对求距离既不好转移、也难与树结构结合，于是把「点对距离」拆成「**每条边的贡献**」：一条边被某一对同色点经过，就计入一次它的边权。这样只需在合并儿子时统计每条边的贡献，就能套树形背包。

## 核心公式 / 状态定义与转移方程

对一条边 `(u, v)`（$v$ 是 $u$ 的儿子，子树大小为 $sz_v$），若 $v$ 的子树里有 $t$ 个黑点，则这条边上「同色点对」的贡献次数为

$$t(k-t) + (sz_v - t)\big((n-k) - (sz_v - t)\big)$$

前一项是黑黑点对数，后一项是白白点对数，再乘边权 $w$ 就是这条边的总贡献。

**状态定义**：`dp[u][j]` 表示在 $u$ 的子树内选 $j$ 个黑点时，子树内部所有边的贡献和（不含 $u$ 到父节点那条边）。

**合并儿子**：儿子 $v$ 的子树取 $t$ 个黑点时，

$$dp[u][m] = \max_{t \le m}\Big(dp[u][m-t] + dp[v][t] + \big[t(k-t) + (sz_v - t)((n-k)-(sz_v-t))\big]\cdot w\Big)$$

**初始化**：`dp[u][0] = dp[u][1] = 0`（源笔记指出这里稍微偷懒：更严格的写法是只初始化 `dp[u][0]=0`，根的染色在合并过程中再确定）。其余位置置为 `-1` 表示「不可达」。

**黑白对称**：把黑点换成白点、$k$ 换成 $n-k$ 答案不变，所以代码里执行 `if(n-k<k) k=n-k;` 把 $k$ 压小以降低 DP 维度。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=2e3+10;
int cnt=0,n,k;
vector<PII> G1[N];
int siz[N],dp[N][N];
```

- `#define int long long` 把整型统一成 64 位，代价是常数变大；开了它 `main` 必须写成 `signed main`。
- `G1[x]` 是带权邻接表，`pair` 的 `first` 是邻点、`second` 是边权；`siz[x]` 是子树大小，`dp[x][j]` 是状态。
- `cnt` 声明后未使用，属模板残留。

### dfs1：求子树大小

```cpp
void dfs1(int x,int fa){
	siz[x]=1;
	for(auto i:G1[x]){
		if(i.fi==fa) continue;
		dfs1(i.fi,x);
		siz[x]+=siz[i.fi];
	}
}
```

- 标准树形 DP 第一遍：`siz[x]=1` 起步，递归每个儿子后把它们的 `siz` 累加回来。
- `if(i.fi==fa) continue;` 跳过父节点（因为是无向树）。

### dfs2：背包合并与边贡献

```cpp
void dfs2(int x,int fa){
	dp[x][0]=dp[x][1]=0;
	for(auto j:G1[x]){
		if(j.fi==fa) continue;
        dfs2(j.fi,x);
		for(int m=min(k,siz[x]);m>=0;m--){
			if(dp[x][m]!=-1) dp[x][m]+=dp[j.fi][0]+siz[j.fi]*(n-k-siz[j.fi])*j.se;
			for(int v=min(m,siz[j.fi]);v>0;v--){
				if(dp[x][m-v]==-1) continue;
				int tot=v*(k-v)+(siz[j.fi]-v)*(n-k-siz[j.fi]+v);
				dp[x][m]=max(dp[x][m],dp[x][m-v]+dp[j.fi][v]+tot*j.se);
			}
		}		
	}
}
```

- `dp[x][0]=dp[x][1]=0`：只初始化「取 0 个 / 1 个黑点」两种基本情况，其余位置保持全局的 `-1`。
- 递归处理儿子 `dfs2(j.fi, x)` 后开始合并：`m` 从 `min(k, siz[x])` **倒序**枚举（背包倒序，避免同一儿子被重复取）。
- `if(dp[x][m]!=-1) dp[x][m]+=...`：这是「儿子取 $t=0$ 个黑点」的分支，给 `dp[x][m]` 加上这条边在 `t=0` 时的贡献 `siz[j.fi]*(n-k-siz[j.fi])*j.se`（即上公式里 $t=0$ 的取值）。
- 内层 `v` 从 `min(m, siz[j.fi])` **倒序**枚举儿子子树取几个黑点，`tot` 就是该边贡献次数，用 `max` 更新 `dp[x][m]`。
- 两处 `-1` 判断保证只在「已算出的状态」上转移。

### main 与快读快写

```cpp
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    memset(dp,-1,sizeof dp);
	cin>>n>>k;
    if(n-k<k) k=n-k;
	for(int i=1;i<n;i++){
		int u,v,w;cin>>u>>v>>w;
		G1[u].push_back({v,w});
		G1[v].push_back({u,w});
	}
	dfs1(1,0);
	dfs2(1,0);
	cout<<dp[1][k];
    return 0;
}
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `memset(dp,-1,sizeof dp)` 把不可达状态统一置为 `-1`（注意 `-1` 在补码里是全 1 字节，用 `memset` 写字节是安全的）。
- 读入 $n,k$ 后先做黑白对称压缩 `if(n-k<k) k=n-k;`，再读 $n-1$ 条带权无向边。
- `dfs1(1,0)` 求子树大小，`dfs2(1,0)` 跑背包，答案是 `dp[1][k]`。
- 底部的 `read` / `write` 是快读快写模板，本程序并未调用（真正输入输出走 `cin/cout`）。

## 复杂度分析

- **时间复杂度**：$O(nk)$。每个节点对只在其 LCA 处被合并一次，枚举上界被 `siz[x]`、`siz[j.fi]` 与 `k` 同时限制，均摊即为 $O(nk)$，而不是表面上看到的 $O(nk^2)$。
- **空间复杂度**：$O(n^2)$。`dp[N][N]` 开满 $2000 \times 2000$，元素是 `long long`，约 32 MB。

## 适用场景

- 树上染色 / 树上选点最大收益（本题）：把「点对贡献」拆成「边贡献」再套背包。
- 一切「在子树上选恰好 $j$ 个点 / 用恰好 $j$ 的容量，合并时考虑子树与外界交互」的树形背包问题。
- 需要 $O(nk)$ 而非 $O(nk^2)$ 的场合：关键是限制枚举上界为子树大小。

## 常见陷阱与注意事项

1. **复杂度别算成 $O(nk^2)$**：上界被 `siz` 限制后均摊是 $O(nk)$，这才是能过数据范围的原因。
2. **初始化偷懒**：`dp[x][0]=dp[x][1]=0` 相当于默认「根可以直接是黑或白」；更严谨的写法是只置 `dp[x][0]=0`，根的颜色在合并时确定。理解这个差异比照抄更重要。
3. **`-1` 作为不可达标记**：转移前必须判 `-1`，否则会把未定义状态也算进去。
4. **循环必须倒序**：`m`、`v` 都从大到小枚举，这是背包「每个儿子只取一次」的保证；正序会让同一子树被重复使用。
5. **黑白对称压缩**：`if(n-k<k) k=n-k;` 把维度压小，画面上少一层循环；别漏掉，否则 $k$ 大时可能 TLE。
6. **`#define int long long` 的连带影响**：`main` 要写 `signed main`，且遍历 `for(auto i:G1[x])` 时下标等运算统一是 64 位。
7. **`read` / `write` 未使用**：底部保留的是模板，别以为读入走了快读。

## 对比与扩展

- 与普通树形背包（`dp[u][j]` 只统计子树内部）相比，本题多了「边贡献」这一层，把跨越子树的点对也算了进来。
- 与「没有上司的舞会」相比，本题从两态扩成了「取 $j$ 个」的容量维度，是分组背包的树上版本。
- 扩展：把边贡献换成点贡献、或把「恰好 $k$」换成「至多 $k$」，转移结构基本不变。$AKB114$, '动态规划', array['动态规划', '树形DP', '树形背包', '树上染色', '边贡献转化'], 'col-dp-tree-overview', null, 'knowledge'),
('Fohen', 'col-dp-tree-color-edge--fenfeng', '树上染色（边贡献分解） · Fohen', $AKB115$## 算法原理

「树上染色」是树形背包与“边贡献分解”相结合的经典问题：给定一棵 $n$ 个节点、边带权的树，要求给恰好 $k$ 个点染成黑色、其余 $n-k$ 个点染成白色，最大化所有黑点两两距离之和与所有白点两两距离之和的总和。

直接枚举同色点对来统计距离，复杂度高且难以在树上高效维护。核心洞察在于：树上任意一条路径都会被它经过的每条边**恰好**切分一次，因此“所有同色点对的距离之和”可以按边拆成贡献——每条边对答案的贡献等于“经过这条边的同色点对数量 $\times$ 边权”。

把某条连接父节点 $u$ 与子节点 $v$ 的边 $(u,v)$ 砍掉后，整棵树被分成两个连通块：$v$ 所在的子树（大小 $sz_v$）与其余部分（大小 $n-sz_v$）。若在 $v$ 子树内选了 $t$ 个黑点，那么：

- 子树内的黑点与子树外的黑点组成的黑点对都要经过这条边，共 $t(k-t)$ 对；
- 子树内的白点与子树外的白点组成的白点对都要经过这条边，共 $(sz_v-t)\big((n-k)-(sz_v-t)\big)$ 对。

两者相加再乘边权 $w$，就是这条边对答案的贡献。于是“最大化点对距离”被转化为“在树上分配黑点数量、使所有边贡献之和最大”，这正是树形背包能处理的形式——每个节点要决定“自己子树内选几个黑点”，各子树的分配方案通过背包合并到父节点。

## 核心公式 / 状态定义与转移方程

状态定义：

$$dp[u][j] = \text{在 } u \text{ 的子树内选 } j \text{ 个黑点时，子树内部所有边的贡献和（不含 } u \text{ 到父节点的边）}$$

其中 $j$ 的取值范围为 $0 \le j \le \min(k, sz_u)$。

初始化（尚未合并任何儿子，$u$ 自身可黑可白，子树内还没有内部边）：

$$dp[u][0] = dp[u][1] = 0$$

边贡献（合并儿子 $v$，从 $v$ 子树取 $t$ 个黑点）：

$$\text{contrib} = \big[\, t(k-t) + (sz_v - t)\big((n-k)-(sz_v-t)\big) \big] \cdot w$$

其中 $w$ 是边 $(u,v)$ 的边权。

转移方程（把儿子 $v$ 背包合并进 $u$）：

$$dp[u][m] = \max_{0 \le t \le m}\Big( dp[u][m-t] + dp[v][t] + \text{contrib} \Big)$$

最终答案（以节点 $1$ 为根）：

$$\text{ans} = dp[1][k]$$

黑白对称优化：黑、白两色完全对称，把 $k$ 换成 $n-k$ 答案不变，因此代码里先做 $k = \min(k, n-k)$，以缩小 DP 的第二维。

## 逐行代码解析

### 头文件、宏与全局变量

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=2e3+10;
int cnt=0,n,k;
vector<PII> G1[N];
int siz[N],dp[N][N];
```

- `#define int long long` 把 `int` 全局替换为 `long long`，因此 `main` 必须写成 `signed main()`，否则 `int main()` 会被宏替换成 `long long main()` 而编译失败。
- `PII` 即 `pair<long long,long long>`，邻接表 `G1[x]` 的每个元素是 `{相邻节点, 边权}`，用 `i.fi` 取节点、`i.se` 取边权。
- `dp[N][N]` 是树形背包的核心表，`dp[u][j]` 表示子树 $u$ 内选 $j$ 个黑点的最大贡献；`N = 2\times 10^3 + 10`。

### dfs1：预处理子树大小

```cpp
void dfs1(int x,int fa){
	siz[x]=1;
	for(auto i:G1[x]){
		if(i.fi==fa) continue;
		dfs1(i.fi,x);
		siz[x]+=siz[i.fi];
	}
}
```

- 一次自底向上的 DFS，把每个节点的子树大小 `siz[x]` 全部求出来。
- `if(i.fi==fa) continue;` 跳过父节点，避免在无向树上往回走形成环。
- 子树大小会在 `dfs2` 中用于限制背包容量、计算边贡献，所以先单独跑一遍。

### dfs2：树形背包核心

```cpp
void dfs2(int x,int fa){
	dp[x][0]=dp[x][1]=0;
	for(auto j:G1[x]){
		if(j.fi==fa) continue;
        dfs2(j.fi,x);
		for(int m=min(k,siz[x]);m>=0;m--){
			if(dp[x][m]!=-1) dp[x][m]+=dp[j.fi][0]+siz[j.fi]*(n-k-siz[j.fi])*j.se;
			for(int v=min(m,siz[j.fi]);v>0;v--){
				if(dp[x][m-v]==-1) continue;
				int tot=v*(k-v)+(siz[j.fi]-v)*(n-k-siz[j.fi]+v);
				dp[x][m]=max(dp[x][m],dp[x][m-v]+dp[j.fi][v]+tot*j.se);
			}
		}		
	}
}
```

- `dp[x][0]=dp[x][1]=0` 初始化：$x$ 自身可白（$0$ 个黑点）或黑（$1$ 个黑点），此时还没有内部边，贡献为 $0$；其余状态被 `memset` 填成 $-1$ 表示“当前不可达”。
- `if(dp[x][m]!=-1) dp[x][m]+=...` 处理 $t=0$ 的分支：儿子 $v$ 全白，边贡献为 $sz_v(n-k-sz_v)\cdot w$，累加到旧值上。
- 内层 `v` 枚举分给儿子子树的黑点数 $t$，`tot = t(k-t) + (sz_v-t)(n-k-sz_v+t)` 正是这条边被同色点对经过的次数，乘 `j.se` 得边贡献。
- 容量 $m$ 从大到小枚举，保证 `dp[x][m-v]`（$m-v<m$）仍是“合并本儿子之前”的旧值，从而每个儿子只被合并一次、不会重复计数。

### 快读快写声明与 main

```cpp
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    memset(dp,-1,sizeof dp);
	cin>>n>>k;
    if(n-k<k) k=n-k;
	for(int i=1;i<n;i++){
		int u,v,w;cin>>u>>v>>w;
		G1[u].push_back({v,w});
		G1[v].push_back({u,w});
	}
	dfs1(1,0);
	dfs2(1,0);
	cout<<dp[1][k];
    return 0;
}
```

- `memset(dp,-1,sizeof dp)` 把整张 `dp` 表填成 $-1$ 作为“不可达”哨兵，再由 `dp[x][0]=dp[x][1]=0` 显式打开可达状态。
- `if(n-k<k) k=n-k;` 利用黑白对称把 $k$ 换成较小值，减小 DP 第二维的规模。
- 读边用 `G1[u].push_back({v,w})` 双向加边；根固定为节点 $1$，答案即 `dp[1][k]`。

### 快读快写实现

```cpp
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `read()` 用 `getchar` 逐字符读整数：跳过前导非数字、处理负号，`x=(x<<1)+(x<<3)+(ch^48)` 等价于 `x = x*10 + (ch-'0')`。
- `write(x)` 递归从高位到低位输出，负数先打负号再取相反数。
- 这两个函数在本程序里其实未被 `main` 调用（`main` 用的是 `cin/cout`），保留它们是作者常用的快读快写模板。

## 复杂度分析

- **时间复杂度**：$O(nk)$。每个节点合并儿子时枚举容量 $m$ 与分配给儿子的黑点数 $t$，表面看是 $O(nk^2)$；但受子树大小 `siz` 限制，每对节点只会在其最近公共祖先（LCA）处被合并一次，均摊下来为 $O(nk)$。
- **空间复杂度**：$O(nk)$。`dp[u][j]` 共有 $n$ 个节点 $\times$ $(k+1)$ 个可选黑点数；代码为方便静态声明成 `dp[N][N]`（$N=2\times 10^3+10$），第二维实际只用到 $0 \dots k$。配合 $k=\min(k,n-k)$ 的对称优化，$k \le n/2$。

## 适用场景

适用于“树上点染色 + 点对距离/边贡献求和”类问题：给树上的点分组（如黑白染色），要求最大化或最小化某一类点对的总距离、总贡献。典型特征是——目标函数能按“边两侧各组点数”拆成每条边的独立贡献，从而把点对层面的统计转化为树形背包。凡是能拆成“边两侧某类点对数 $\times$ 边权”的问题，都可套用这一框架。

## 常见陷阱与注意事项

- **哨兵 $-1$ 与可达性**：`dp` 表用 $-1$ 表示“该黑点数当前不可达”，合并前必须先 `memset(dp,-1,sizeof dp)`，再用 `dp[x][0]=dp[x][1]=0` 打开初始状态。若用 $0$ 当初始值，会把“不可达”与“贡献为 $0$”混淆，导致错误转移。
- **黑白对称优化**：`if(n-k<k) k=n-k;` 依赖黑白两色答案对称；若题目对两种颜色赋了不同权值（不对称），则不能这样交换。
- **容量逆序遍历**：合并儿子时 $m$ 必须从大到小枚举，否则 `dp[x][m-v]` 读到的是“已合并当前儿子”的新值，会把同一个儿子重复计入。
- **`#define int long long`**：一旦开启，`main` 必须写成 `signed main()`；`memset` 填 $-1$ 依赖二进制补码，对 `long long` 数组同样成立。
- **递归深度**：树可能退化成链，`dfs1`/`dfs2` 递归深度可达 $n$，数据较大时需注意栈溢出。
- **边界与下标**：循环上限取 `min(k,siz[x])`、`min(m,siz[j.fi])`，避免访问超出子树实际大小的无效状态。

## 对比与扩展

- **与普通树形背包的关系**：本质是树上分组背包的变体——每个儿子是一个“组”，从该组选 $t$ 个黑点是一种“物品”，只是“物品价值”额外叠加了这条边的贡献项。
- **与「没有上司的舞会」（树形最大独立集）的区别**：后者只有选/不选两种状态、转移 $O(1)$；本问题要枚举黑点数做背包合并，状态是“选了几个”，复杂度更高。
- **扩展**：若边权或点权改为有向/非对称，只需改边贡献公式中的同色点对数计算；若限制的是“同色连通块”而非点对距离，则转化为另一类树上计数问题。$AKB115$, '动态规划', array['动态规划', '树形DP', '树上背包', '边贡献分解', '黑白染色'], 'col-dp-tree-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-tree-dance', '树形DP · 最大权独立集', $AKB116$## 算法原理

最大权独立集是树形 DP 的入门模型：给定一棵树，每个点有一个权值，要求选出一个点集，使集合内任意两个点都不相邻，并最大化选中点的权值和。

之所以能在树上高效求解，是因为树没有环：一旦确定了根，某个点选或不选只影响它的子节点，不会绕回祖先。于是可以在每个节点上只保留“选 / 不选”两种状态，用后序遍历自底向上合并。

设：

- `dp[u][0]`：不选 $u$ 时，以 $u$ 为根的子树内能得到的最大权值和。
- `dp[u][1]`：选 $u$ 时，以 $u$ 为根的子树内能得到的最大权值和。

状态的含义只包含“当前节点选不选”，因为父节点是否被选会在父节点处处理；子节点之间的选择互不影响，可以分别取最优。

## 核心公式 / 状态定义与转移方程

对每个节点 $u$，枚举其子节点 $v$：

**选 $u$**：所有子节点都不能选，所以

$$
dp[u][1] = w_u + \sum_{v \in \text{children}(u)} dp[v][0]
$$

**不选 $u$**：每个子节点可以选，也可以不选，取较优值：

$$
dp[u][0] = \sum_{v \in \text{children}(u)} \max\big(dp[v][0], dp[v][1]\big)
$$

**边界**：叶子节点没有儿子，`dp[leaf][0] = 0`，`dp[leaf][1] = w_leaf`。

**答案**：根节点可选可不选，答案为

$$
\max\big(dp[\text{root}][0], dp[\text{root}][1]\big)
$$

**计算顺序**：先递归处理所有子节点，再计算当前节点；也就是后序遍历。若先算父节点再算子节点，转移会用到未计算的状态。

## 逐行代码解析

本篇是纯知识条目，不附完整实现；模板题 [P1352 没有上司的舞会](#prob-luogu-p1352) 给出了完整代码与逐行注释。

实现时只需要抓住四步：

1. **建树**：读入 $n-1$ 条父子关系，把孩子挂到父亲下面，并标记每个点是否有父亲。
2. **找根**：唯一没有父亲的点就是根；也可以从任意点出发、把无向边按 DFS 方向定向。
3. **后序 DFS**：先递归所有儿子，得到 `dp[v][0/1]`，再按上面的两条转移累加到 `dp[u][0/1]`。
4. **输出**：`max(dp[root][0], dp[root][1])`。

如果题目保证 $1$ 号点是根，第 2 步可以省略；如果不保证，必须显式找根，不能默认从 $1$ 开始。

## 复杂度分析

- **时间复杂度**：$O(n)$。每个节点只被 DFS 访问一次，每个节点的转移只遍历它的儿子，所有儿子边合计 $O(n)$。
- **空间复杂度**：$O(n)$。`dp` 表 $O(n)$，邻接表 $O(n)$，递归栈最坏 $O(n)$。

树形 DP 的复杂度通常是“状态数 × 单次合并代价”。本题状态数是 $2n$，每个儿子只做 $O(1)$ 合并，所以是 $O(n)$。

## 适用场景

- 树上相邻点不能同时选的带权选择问题（最大权独立集）。
- 公司聚会、派对邀请、课程选择等“上下级不能同时参加”的模型。
- 树上最小点覆盖、最大匹配等与独立集互补的问题，可以通过类似的两态/三态 DP 求解。
- 不适合：图不是树且存在环；一般图的最大独立集是 NP-hard，不能直接套 $O(n)$ 的树形 DP。

## 常见陷阱与注意事项

- **根不唯一或未找根**：输入不保证 $1$ 是根时，必须通过父亲标记或入度找根；否则会漏掉整棵树的一部分。
- **权值可能为负**：如果题目允许负权，`dp[u][1]` 要以 $w_u$ 为基础，不能把初值全部设成 $0$ 后盲目取最大；必要时用负无穷初始化。
- **递归深度**：链状树深度可达 $n$，递归可能栈溢出；大规模数据要改成显式栈或加编译栈空间。
- **多测未清空**：邻接表、`dp`、父亲标记都要清空。
- **答案只取 `dp[root][1]`**：根节点可以不选，必须取两种状态的较大值。
- **把“相邻”理解成“子树内任意两点”**：约束只作用于直接相连的点，隔代的点可以同时选。

## 对比与扩展

- **与树形背包的区别**：最大权独立集只有“选/不选”两态，合并时不需要枚举容量；树形背包要在每个儿子处枚举分配多少容量，复杂度更高。
- **与最小点覆盖的关系**：在树上，最小点覆盖与最大独立集互补；求出一个即可推出另一个的大小。
- **与最大匹配的关系**：树是二分图，最大独立集 = 总点数 − 最大匹配；树形 DP 和匈牙利算法都能求解，但树形 DP 更直接。
- **与一般图**：一般图最大独立集是 NP-hard，不能依赖树的无环性；需要状压、分支限界或近似算法。

模板题：[P1352 没有上司的舞会](#prob-luogu-p1352)$AKB116$, '动态规划', array['树形DP', '最大独立集', '状态设计', '后序遍历'], 'col-dp-tree-overview', null, 'knowledge'),
('Fohen', 'col-dp-tree-min-dominating--fenfeng', '树的最小支配集（三态 DP） · Fohen', $AKB117$## 算法原理

在一棵 $n$ 个节点的无根树上放置最少的「信号塔」，使得每个节点要么自己放塔，要么至少与一个放了塔的节点相邻。这等价于求树的最小支配集（minimum dominating set）：选一个最小的点集 $D$，使每个点要么属于 $D$，要么与 $D$ 中的某个点相邻。

与最大独立集的「选 / 不选」两态不同，最小支配集里一个节点「是否被覆盖」有三种来源——**自己放塔**、**被某个儿子放塔覆盖**、**等父节点放塔覆盖**。于是状态按这三种来源拆成三态，这也是「三态 DP」名称的由来。

整体仍是树形 DP 的「先子树后根」套路：先递归求出每个子树在三种状态下的最优代价，再自底向上把这些子树的最优值合并到父节点。最终根节点没有父节点，不能「等父节点覆盖」，所以答案只在根的前两个状态里取。

## 核心公式 / 状态定义与转移方程

### 状态定义

| 状态 | 含义 |
|------|------|
| `dp[u][0]` | 在 $u$ 上放塔，$u$ 被自己覆盖时，$u$ 子树内的最少塔数 |
| `dp[u][1]` | $u$ 不放塔、被至少一个儿子覆盖时，$u$ 子树内的最少塔数 |
| `dp[u][2]` | $u$ 不放塔、也不被任何儿子覆盖（等待父节点覆盖）时，$u$ 子树内的最少塔数 |

### 转移方程

设 $v$ 遍历 $u$ 的所有儿子。

- **放塔**：$u$ 自己放塔后，每个儿子可以处于任意状态，取三者最小：

$$
dp[u][0] = 1 + \sum_{v} \min\big(dp[v][0],\ dp[v][1],\ dp[v][2]\big)
$$

- **等待父节点覆盖**：儿子不能依赖父节点（否则无人覆盖该儿子），只能自己放塔或被它的儿子覆盖：

$$
dp[u][2] = \sum_{v} \min\big(dp[v][0],\ dp[v][1]\big)
$$

- **被儿子覆盖**：先让每个儿子取 $\min\big(dp[v][0], dp[v][1]\big)$；若其中已有儿子选状态 0（放塔），则 $u$ 已被覆盖，无需额外代价；否则必须强制把某个儿子从状态 1 升级成状态 0，付出最小差价：

$$
dp[u][1] = \sum_{v} \min\big(dp[v][0],\ dp[v][1]\big) + \Delta
$$

$$
\Delta = \begin{cases}
0, & \text{若存在儿子 } v \text{ 满足 } dp[v][0] \le dp[v][1] \\
\min_{v}\big(dp[v][0] - dp[v][1]\big), & \text{否则}
\end{cases}
$$

### 答案

根节点没有父节点，不能处于「等待父节点覆盖」的状态 2，故答案为：

$$
\text{ans} = \min\big(dp[root][0],\ dp[root][1]\big)
$$

## 逐行代码解析

### 头文件与全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
int n;
vector<int> bo[10010];
int f[10010][3],v[10010];
```

- `bo` 是邻接表，存无向树；`f[x][0..2]` 对应三态 DP 数组。
- `n` 为节点数；`v` 声明后未使用，是从「找根」模板里残留的数组，不影响结果。
- 数组开 `10010`，可容纳 $n \le 10^4$ 量级的规模。

### DFS 三态转移

```cpp
void dp(int x, int fa){
    f[x][0]=1;f[x][1]=0;f[x][2]=0;
    bool buxiao=true;
	int yanglaojin = 10000000;
    for(int i=0;i<bo[x].size();i++){
        int y=bo[x][i];
        if (y == fa) continue;
        //cout<<y<<" "<<x<<endl;
        dp(y, x);//TODO
        f[x][0]+=min({f[y][0],f[y][1],f[y][2]});
        f[x][2]+=min(f[y][0],f[y][1]);
        if(f[y][0]<=f[y][1]) buxiao=false;
        f[x][1]+=min(f[y][0],f[y][1]);
        yanglaojin=min(yanglaojin,f[y][0]-f[y][1]);
    }
    if(buxiao) f[x][1]+=yanglaojin;
}
```

- 先初始化 `f[x][0]=1`（自己放塔占 1 个）、`f[x][1]=f[x][2]=0`；`buxiao` 标记「还没有儿子选状态 0」，`yanglaojin` 记录最小的 `f[y][0]-f[y][1]`，即把某个儿子从状态 1 升级成状态 0 的最小额外代价。
- 递归顺序是「先子树后根」：先 `dp(y, x)` 算出儿子，再回来合并；`if (y == fa) continue;` 用父节点标记代替 `vis` 数组，避免在树上走回头路。
- `if (f[y][0] <= f[y][1]) buxiao = false;`：只要有一个儿子「放塔」不劣于「被它自己的儿子覆盖」，$u$ 就已经被儿子覆盖，无需额外补偿。
- 循环结束后若 `buxiao` 仍为真，说明没有任何儿子放塔，此时强制把一个儿子升级为状态 0，代价取最小的 `yanglaojin`，对应公式中的 $\Delta$ 项。

### 主函数

```cpp
int main(){
	cin>>n;

	for(int i=1;i<n;i++){
		int s;cin>>s;
		
		int b;cin>>b;
		bo[s].push_back(b);
		bo[b].push_back(s);
	}

    dp(1, -1);
    cout<<min(f[1][0],f[1][1])<<endl;

    return 0;
}
```

- 读入 $n-1$ 条边并双向加边，构建无向树的邻接表。
- 以 $1$ 为根做一次 DFS；根没有父节点，父标记传 `-1`。
- 答案是 `min(f[1][0], f[1][1])`：根不能靠父节点覆盖，只能取「自己放塔」或「被儿子覆盖」中更优的那个。

## 复杂度分析

### 时间复杂度

DFS 访问每个节点恰好一次；每个节点内部遍历它的邻接边。整棵树的度之和为 $2(n-1)$，所有「遍历儿子」的循环加起来共 $O(n)$ 次：

$$
O(n)
$$

### 空间复杂度

邻接表存 $2(n-1)$ 条有向边，为 $O(n)$；三态 DP 数组 `f[10010][3]` 也是 $O(n)$：

$$
O(n)
$$

## 适用场景

- **树上最小支配集 / 基站覆盖类问题**：如 Cell Phone Network（USACO），选最少点使每个点被自身或邻点覆盖。
- **节点覆盖来源多样的树形覆盖问题**：当「被覆盖」取决于自己、儿子、父亲三方时，用三态区分，可自然推广到带权等变体。
- **与最大独立集、最小点覆盖并列的树形 DP 经典模型**：三者的状态设计互相映照，适合放在一起对照练习。

## 常见陷阱与注意事项

1. **三态不可混淆**：状态 2 表示「等父节点覆盖」，其儿子不能再处于状态 2（否则无人覆盖该儿子），因此 $dp[u][2]$ 只能从儿子的状态 0 与状态 1 转移。
2. **`dp[u][1]` 必须满足「至少一个儿子放塔」**：不能简单地把所有儿子的 $\min(dp[v][0], dp[v][1])$ 相加就收工，否则会出现「人人等别人覆盖」的空覆盖；要检查是否有儿子选状态 0，没有就补一个最小升级代价。
3. **判断用 $\le$ 而非 $<$**：当 $dp[v][0] = dp[v][1]$ 时，儿子「放塔」与「被它的儿子覆盖」代价相同，此时「$u$ 被儿子覆盖」无需额外代价，所以代码用 `if (f[y][0] <= f[y][1])`。
4. **叶子节点靠大常数初值兜底**：叶子没有儿子，`buxiao` 恒为真，`f[leaf][1]` 会加上初始值 `10000000`（等效无穷大），表示叶子不可能「被儿子覆盖」，这是靠初值而非显式特判实现的。
5. **根节点答案不含状态 2**：根没有父节点，「等父节点覆盖」无效，答案只能取 $\min(dp[root][0], dp[root][1])$。
6. **无向树用父节点标记防回头**：DFS 传 `fa`，循环里 `if (y == fa) continue;`，避免回到父节点造成死循环；根节点传 `-1`。

## 对比与扩展

### 与最大独立集、最小点覆盖的对比

| | 目标 | 状态设计 | 转移约束 |
|---|---|---|---|
| 最大独立集 | 选最多点，两两不相邻 | 两态（选 / 不选） | 相邻不能同时选 |
| 最小点覆盖 | 选最少点，覆盖每条边 | 两态（选 / 不选） | 每条边至少一端被选 |
| 最小支配集 | 选最少点，覆盖每个点 | 三态（自己放 / 被儿子覆盖 / 等父覆盖） | 每个点至少被覆盖一次 |

支配集比前两者多一态，根因在于「被覆盖」的来源有自己、儿子、父亲三种，而独立集和点覆盖只需关心节点自身与相邻边的局部关系。

### 扩展

- **贪心解法**：无向树上的最小支配集也可用「从叶子自底向上贪心选点」做到 $O(n)$，但三态 DP 更通用、更好写对，且容易推广到带权、带其他约束的变体。
- **输出方案**：若需要输出具体选了哪些点，可在 DP 时记录每个状态是从哪个儿子的哪个状态转移而来，最后自顶向下回溯。
- **带权最小支配集**：把「放塔」的代价从常数 $1$ 换成点权 $w[u]$，其余转移结构不变，即可求带权版本。$AKB117$, '动态规划', array['树形DP', '最小支配集', '三态DP', '动态规划', '覆盖问题'], 'col-dp-tree-overview', null, 'knowledge'),
('Xesir', 'col-dp-tree-min-dominating--xesir', '树的最小支配集（三态 DP · Cell Phone Network · Xesir 版） · Xesir', $AKB118$## 算法原理

例题「Cell Phone Network」要求：**选最少的点，使得每个点要么被选，要么与某个被选的点相邻**。这正是树的**最小支配集**问题。

和最大独立集「选 / 不选」两态不同，最小支配集里一个节点「是否已被覆盖」有**三种来源**：自己放塔被自己覆盖、被某个儿子放塔覆盖、暂时没被覆盖只在等父节点来覆盖。于是状态按这三种来源拆成三态，这也是「三态 DP」这个名字的由来：

- `dp[u][0]`：在 $u$ 放塔，$u$ 被自己覆盖。
- `dp[u][1]`：$u$ 不放塔，且被子节点覆盖（至少有一个儿子放塔）。
- `dp[u][2]`：$u$ 不放塔，且不被任何子节点覆盖（只等父节点来覆盖）。

先自底向上把儿子的三态都算出来，再在父亲处按三种情况分别合并。

## 核心公式 / 状态定义与转移方程

设 $u$ 的儿子集合为 $children(u)$。

放塔（$u$ 自己覆盖）：每个儿子可取任意状态，取三者最小值。

$$dp[u][0] = 1 + \sum_{v \in children(u)} \min(dp[v][0], dp[v][1], dp[v][2])$$

等父覆盖（$u$ 暂时没被覆盖）：儿子不能指望父节点，只能自己解决（放塔或被自己的儿子覆盖）。

$$dp[u][2] = \sum_{v \in children(u)} \min(dp[v][0], dp[v][1])$$

被儿子覆盖（$u$ 不放塔，但至少一个儿子放塔）：先假设所有儿子都取 $\min(dp[v][0], dp[v][1])$，若没有任何儿子真的选了 `dp[v][0]`，就强制把某个儿子从 `dp[v][1]` 换成 `dp[v][0]`，取代价最小的那个。

$$dp[u][1] = \sum_{v \in children(u)} \min(dp[v][0], dp[v][1]) + \begin{cases} 0 & \text{若存在儿子选了 } dp[v][0] \\ \min_v \big(dp[v][0] - dp[v][1]\big) & \text{否则} \end{cases}$$

**答案**：根没有父节点，不能靠父覆盖，所以取 $\min(dp[root][0], dp[root][1])$。

## 逐行代码解析

源笔记自带吐槽：`code:(沉浸式欣赏GOC诡异码风与变量名)`，变量名 `buxiao`（不孝）、`yanglaojin`（养老金）确实很抽象，但下面全部**原样照搬**。

### 全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
int n;
vector<int> bo[10010];
int f[10010][3],v[10010];
```

- `bo[x]` 是邻接表；`f[x][0..2]` 是三态 `dp`；`n` 存点数。
- `v[10010]` 声明了但在本程序中**并未使用**，属源码残留，照搬保留。

### dp 函数：三态转移

```cpp
void dp(int x, int fa){
    f[x][0]=1;f[x][1]=0;f[x][2]=0;
    bool buxiao=true;
	int yanglaojin = 10000000;
    for(int i=0;i<bo[x].size();i++){
        int y=bo[x][i];
        if (y == fa) continue;
        //cout<<y<<" "<<x<<endl;
        dp(y, x);//TODO
        f[x][0]+=min({f[y][0],f[y][1],f[y][2]});
        f[x][2]+=min(f[y][0],f[y][1]);
        if(f[y][0]<=f[y][1]) buxiao=false;
        f[x][1]+=min(f[y][0],f[y][1]);
        yanglaojin=min(yanglaojin,f[y][0]-f[y][1]);
    }
    if(buxiao) f[x][1]+=yanglaojin;
}
```

- 初始化：`f[x][0]=1`（自己放塔算 1 个），`f[x][1]=f[x][2]=0`。
- `buxiao=true` 表示「暂时还没有儿子选 `dp[v][0]`」；`yanglaojin` 记录「把某个儿子从 `dp[v][1]` 换成 `dp[v][0]` 的最小额外代价」，用固定值 `10000000` 当无穷大。
- 遍历儿子（`if (y == fa) continue;` 跳过父节点，因为是无向树）：先 `dp(y, x)` 递归。
- 三态累加：状态 0 取三者 `min({...})`；状态 2 取 `min(f[y][0], f[y][1])`；状态 1 也先按 `min(f[y][0], f[y][1])` 累加。
- `if(f[y][0] <= f[y][1]) buxiao=false;`：只要有儿子「自然」会选状态 0，$u$ 就被儿子覆盖了，不需要强制。
- `yanglaojin = min(yanglaojin, f[y][0]-f[y][1])` 记录最小补差价；循环结束后若 `buxiao` 仍为真（没有任何儿子选了 0），就把这笔差价补进 `f[x][1]`。

### main：建无向树、从 1 号点 DP

```cpp
int main(){
	cin>>n;

	for(int i=1;i<n;i++){
		int s;cin>>s;
		
		int b;cin>>b;
		bo[s].push_back(b);
		bo[b].push_back(s);
	}

    dp(1, -1);
    cout<<min(f[1][0],f[1][1])<<endl;

    return 0;
}
```

- 读入 $n-1$ 条无向边，`bo[s].push_back(b)` 与 `bo[b].push_back(s)` **双向**建边，因此 `dp` 里必须靠 `fa` 判父。
- `dp(1, -1)`：任取 1 号点为根，`-1` 表示它没有父节点。
- 输出 `min(f[1][0], f[1][1])`：根不能靠父覆盖，答案只在「自己放塔」和「被儿子覆盖」两态里取最小。

## 复杂度分析

- **时间复杂度**：$O(n)$。每个节点只被访问一次，每轮合并儿子是 $O(1)$（`min({...})` 也是常数次比较）。
- **空间复杂度**：$O(n)$。邻接表加上 `f`、`v` 数组，均为 $O(n)$。

## 适用场景

- 树上最小支配集：以最少的点覆盖整棵树（每个点被自己或邻点覆盖）。
- 「放置设施 / 通讯塔」类覆盖问题：一个设施能覆盖自身与相邻点，求最少设施数。
- 一切「节点有『自己解决 / 靠儿子 / 靠父亲』三种归属」的树形 DP 问题。

## 常见陷阱与注意事项

1. **`yanglaojin` 用的是固定值而非真正的无穷大**：源程序写 `int yanglaojin = 10000000;`，只要答案规模不超过这个量级就没问题，$n$ 很大时不够用。
2. **强制补差价的判据用 `<=`**：`if(f[y][0] <= f[y][1]) buxiao=false;` 用的是小于等于。它保证 `buxiao` 为真时所有儿子都满足 `f[y][0] > f[y][1]`，于是 `f[y][0]-f[y][1] > 0`，补差价一定是正的，逻辑自洽。
3. **状态 2 与状态 1 的初始化区别**：`f[x][2]` 不额外加 1，因为它是「等父覆盖」这种尚未覆盖的状态；很多人会把它误加 1。
4. **无向树必须判父**：`dp` 第二参 `fa` 就是为此存在，漏掉会死循环。
5. **`v` 数组是废变量**：声明但没用，不要以为它参与建树。
6. **递归爆栈**：链状树深度可达 $n$，$n$ 大时要留意栈空间。

## 对比与扩展

- 与最大独立集对比：最大独立集是「选 / 不选」两态，本题因为「覆盖来源」有三种而升到三态。
- 与棋盘状压、集合状压对比：这里压缩的是「树上节点的覆盖状态」，属于树形 DP 一支。
- 树上最小支配集还有更简洁的二态写法，但三态写法思路最直白，理解后再化简不迟。$AKB118$, '动态规划', array['动态规划', '树形DP', '最小支配集', '三态DP', '覆盖问题'], 'col-dp-tree-overview', null, 'knowledge'),
('world-needs-sunday', 'col-dp-tree-overview', '树形 DP 总览（独立集 / 背包 / 换根 / 支配集）', $AKB119$## 算法原理

本页是「树形 DP」的二级栏目索引：在树上按子树合并信息，状态通常带「选不选当前点」「当前点属于哪一类」，转移通过 DFS 后序合并儿子。

**学习顺序**：最大权独立集 → 树状 01 背包 → 树形背包 O(nk) 优化 → 换根 DP → 最小支配集。

## 核心公式 / 状态定义与转移方程

**按题型选子栏目**：

| 题型 | 子条目 |
|---|---|
| 选/不选相邻点 | 树形DP · 最大权独立集 |
| 子树内做背包 | 树状01背包、树形背包 O(nk) 优化 |
| 边贡献分解 | 树上染色（边贡献分解） |
| 全树每个点作为根求值 | 换根 DP（STA-Station） |
| 点覆盖/支配关系 | 树的最小支配集（三态 DP） |

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出状态定义、转移顺序与逐行解析。

## 复杂度分析

- 树形背包朴素合并 $O(nk^2)$，按子树大小限制上界可做到 $O(nk)$。
- 换根 DP 两次 DFS，$O(n)$。
- 独立集 / 支配集：$O(n)$。
- 边贡献分解：$O(n)$。

## 适用场景

- 树上选择问题（独立集、覆盖集、支配集）。
- 子树资源分配（树形背包）。
- 需要以每个点为根统计（换根）。
- 边/点贡献可拆分统计的计数题。

## 常见陷阱与注意事项

- 树形背包的循环上界要按「已合并子树大小」限制，否则退化为 $O(nk^2)$。
- 换根时先算子树答案，再用父亲信息回推，注意减去重复贡献。
- 多状态 DP 要写清每种状态的合法转移。
- 递归深度大时注意栈溢出，可改迭代或开栈。
- 无边权/点权的初始化要统一。

## 对比与扩展

- 树形 DP vs 树上贪心：能用贪心证明时优先贪心。
- 树形背包 vs 一般背包：多了子树依赖关系。
- 可扩展到基环树 DP（先断环再合并）。$AKB119$, '动态规划', array['树形DP', '换根DP', '树形背包', '总览', '学习路线'], null, null, 'knowledge'),
('world-needs-sunday', 'col-hub-dp', '动态规划总述', $AKB120$## 算法原理

动态规划把原问题拆成**互相重叠的子问题**，先求子问题的最优值，再由子问题推出原问题。能使用动态规划的问题通常同时具备三个特征：

- **最优子结构**：原问题的最优解由子问题的最优解组合而成。
- **无后效性**：一旦状态确定，后续决策不再依赖到达该状态的具体路径。
- **重叠子问题**：不同决策路径会反复遇到同一个子问题，因此值得记忆化。

本大类按建模对象分为：线性 DP、背包问题、区间 DP、树形 DP、数位 DP、状态压缩 DP、期望 DP、DP 优化与 DP 方法论。子分类之间不是严格的先后依赖，真正的依赖关系由具体题目的状态设计决定。

## 核心公式 / 状态定义与转移方程

动态规划的统一流程是：

1. **定义状态**：用最少的维度描述“当前局面”，且该描述足以决定后续所有决策。
2. **写边界**：初始化空集、长度为 0、根节点等最基本局面。
3. **写转移**：枚举当前状态的最后一步决策，把它归约到更小的状态。
4. **确定顺序**：保证转移时依赖的状态已经算好；区间 DP 按长度递增，背包按容量方向，树形 DP 按后序。
5. **压缩空间**：当某一维只依赖上一层时，用滚动数组或原地更新。

状态定义是全部工作的核心。判断状态是否合格的直接标准是：**两个到达同一状态的方案，对后续决策必须完全等价**。如果后续还需要知道“是怎么来的”，说明状态缺维度。

## 逐行代码解析

本篇是大类总述，不附具体实现。线性 DP、背包、区间 DP、树形 DP 等子分类各自的模板代码、逐行注释与边界处理在对应知识点页中；本篇只负责给出统一的状态设计框架。

## 复杂度分析

动态规划的复杂度通常写成：

- 时间复杂度 = 状态数 × 单个状态的转移代价。
- 空间复杂度 = 状态数（滚动数组后为其中一层的大小）。

例如背包的状态数是物品数 × 容量，单次转移 $O(1)$，总复杂度 $O(nm)$；区间 DP 的状态数是 $O(n^2)$，每次枚举分割点 $O(n)$，总复杂度 $O(n^3)$。具体量级以各子条目的代码为准。

## 适用场景

- 计数：方案数、路径数、合法序列数。
- 最值：最大价值、最小代价、最长/最短序列。
- 可行性：能否凑出某个和、能否到达某个状态。
- 方案构造：在 DP 值之外记录前驱或选择。

不适合动态规划的情形：子问题彼此独立（分治更合适）、局部最优可证明推出全局最优（贪心更合适）、状态无法压缩且搜索空间可接受（搜索 + 剪枝可能更简单）。

## 常见陷阱与注意事项

- 状态定义漏维度，导致后续决策信息不足。
- 转移顺序写反：01 背包必须倒序枚举容量，完全背包必须正序。
- 边界初始化错误：求最大值时负无穷、求最小值时正无穷，计数时初值为 0 或 1 要分清。
- 多测题忘记清空 DP 数组或清空范围不对。
- 空间压缩后仍按二维下标的含义写代码，出现覆盖。
- 把“恰好”与“至多”混用，初始化与答案取值都会错。

## 对比与扩展

动态规划与贪心的分界线是“是否需要保留多个候选状态”；与分治的分界线是“子问题是否重叠”；与搜索的分界线是“状态能否被有限维描述”。掌握状态设计后，可以继续学习单调队列、斜率、决策单调性、SOS 等优化手段。$AKB120$, '动态规划', array['动态规划', '总述', '学习路线'], null, null, 'knowledge');

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
