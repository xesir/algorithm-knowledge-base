---
id: dp-tree-bag-optimize
title: '树形背包 O(nk) 优化（树上染色 · Xesir 版）'
category: 动态规划
subcategory: 树形DP
subSubcategory: ''
tags: ["动态规划", "树形DP", "树形背包", "树上染色", "边贡献转化"]
timeComplexity: 'O(nk)'
spaceComplexity: 'O(n²)'
level: A
codePath: '动态规划\树形背包优化\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

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
- 扩展：把边贡献换成点贡献、或把「恰好 $k$」换成「至多 $k$」，转移结构基本不变。
