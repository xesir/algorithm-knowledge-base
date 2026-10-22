---
id: graph-network-flow
title: '网络流（最大流 Dinic 与费用流）'
category: 图论
subcategory: 网络流
subSubcategory: ''
tags: ["图论", "网络流", "最大流", "Dinic", "最小割", "费用流"]
timeComplexity: 'O(n^2 m)'
spaceComplexity: 'O(n + m)'
level: A
codePath: '图论\网络流\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

> 题外话：推荐大家学习网络流看一下[这个视频](https://www.bilibili.com/video/BV1K64y1C7Do/?share_source=copy_web&vd_source=db32312e64ded9c3a314b416e5f8bd86)，讲的肥肠清晰透彻，易于理解。

> 如果说图论是一张错综复杂的交通网，那网络流就是研究**怎么在这张网上最有效率地运输东西**。水管怎么铺，水流量才最大？公路怎么调度，车流量才最大？这些问题都能抽象成网络流模型。它不仅是图论皇冠上的明珠，更是解决分配问题、匹配问题、割问题等无数现实难题的终极武器。

一个**流网络**是一个有向图，每条边 $(u, v)$ 都有一个非负的**容量** $c(u, v)$，表示这条边最多能承载多少"流量"。网络中有两个特殊节点：**源点** $s$（起点）和**汇点** $t$（终点）。

我们可以把流网络想象成一个水管系统：源点是水泵，汇点是蓄水池，边是水管，容量是水管的粗细。**流**就是水在这张网里从源点流向汇点的过程。一个合法的流必须满足三个条件：容量限制、流量守恒、反对称性（详见下一节）。

网络流有三大经典问题：

*   **最大流**：从源点到汇点最多能输送多少流量？
*   **最小割**：至少删掉多少容量的边，才能让源点和汇点不连通？
*   **费用流**：在流量最大的前提下，怎样让总运输费用最小？

这三个问题紧密相连，其中**最大流 = 最小割**，这是网络流中最核心的定理之一。

### 增广路与反悔机制

最大流的一个直观解法是：不断在图中找一条从 $s$ 到 $t$ 的可行路径（**增广路**），然后把这条路径能承载的流量"塞"进去，直到塞不下为止。但直接贪心会出问题——你可能会选错路径，导致最终无法得到最大流。

为了解决这个问题，许多算法应运而生。实现上我们为每条边 $(u, v)$ 都建立一条虚拟的**反向边** $(v, u)$，其容量等于当前在 $(u, v)$ 上已经使用的流量。反向边提供了一种"**反悔**"机制，允许算法撤销之前错误的流量分配，从而找到全局最优解。这里只介绍效率最高、竞赛中最常用的算法——**Dinic 算法**。

### 阻塞流

在深入 Dinic 之前，需要先理解一个概念：**阻塞流 (Blocking Flow)**。

想象一下，在构建好的**分层图**（后面会讲）里，我们不断寻找并塞满增广路，直到再也找不到任何一条从 $s$ 到 $t$ 的路径。这时候我们在分层图里得到的流，就叫阻塞流。

阻塞流有一个重要特性：**最大流一定是阻塞流，但阻塞流不一定是最大流**。阻塞流只是在"当前这一层"的视角下达到了局部最优，但全局上可能还有优化的空间。Dinic 算法的核心，就是**通过反复构建分层图并寻找阻塞流，来一步步逼近全局最大流**。

### Dinic 算法

Dinic 算法通过 BFS 和 DFS 的巧妙配合，高效地寻找最大流。它的时间复杂度是 $O(n^2 m)$，但在实际应用中远达不到这个上界，效率非常高。算法可以概括为以下几个步骤：

1.  **BFS 构建分层图 (Level Graph)**：从源点 $s$ 开始 BFS，计算每个点到 $s$ 的最短距离（按边数），并根据这个距离给所有点分层。然后只保留那些从第 $i$ 层指向第 $i+1$ 层的边。这样，分层图中的任意一条 $s$ 到 $t$ 的路径，都是原图中的一条**最短增广路**。
2.  **DFS 寻找阻塞流**：在分层图上，用 DFS 一次性找出**所有**能从 $s$ 到 $t$ 的增广路，并进行增广。当 DFS 找不到更多路径时，就在当前分层图上找到了一个**阻塞流**。
3.  **更新残量网络并重复**：用找到的阻塞流更新整个网络的流量和残量。然后回到步骤 1，用更新后的残量网络重新 BFS 构建分层图。
4.  **算法终止**：当某次 BFS 无法再从 $s$ 到达 $t$ 时，说明整个网络的 $s$ 到 $t$ 路径已经断绝，此时累积的流量就是最大流。

Dinic 算法之所以快，关键在于它的两个优化：

*   **分层图**：保证了每次增广的都是**最短路径**，而每次构建分层图后，$s$ 到 $t$ 的最短距离**至少增加 1**，所以 BFS 的次数最多为 $n$。
*   **当前弧优化**：在 DFS 寻找阻塞流时，如果一个节点 $u$ 的某条出边 $(u, v)$ 已经被增广到"饱和"（没容量了），或者从 $v$ 点已经找不到更多流量了，那么这条边在当前分层图中就废了。算法会用 `cur[u]` 数组记录下一条**还没试过**的出边，下次 DFS 到 $u$ 时直接从 `cur[u]` 开始，跳过所有已经无用的边，大大节省了时间。

### 费用流

最后简单提一下**费用流**。如果说最大流是"运最多的水"，那费用流就是"**用最少的钱，运最多的水**"。

它的模型和最大流完全一样，只是给每条边额外增加了一个**费用**属性，表示单位流量通过这条边的成本。算法的目标是在保证流量最大的前提下，最小化总费用。最常用的费用流算法是 **SPFA + 增广路**：

1.  用 SPFA 在残量网络上寻找一条从 $s$ 到 $t$ 的、单位费用之和最小的路径（即**最短路**）。
2.  沿着这条最短路进行增广。
3.  重复直到找不到增广路为止。

因为每次都是在当前残量网络上找**费用最短路**，所以最终得到的最大流一定是费用最小的。

## 核心公式 / 状态定义与转移方程

流网络的三个基本约束：

1.  **容量限制**：每条边上的流量不能超过它的容量。

$$0 \le f(u,v) \le c(u,v)$$

2.  **流量守恒**：除了源点和汇点，其他每个点"流进的量"必须等于"流出的量"，水不能在中途凭空消失或产生。

$$\sum_{(v,u) \in E} f(v,u) = \sum_{(u,v) \in E} f(u,v)$$

3.  **反对称性**：这是一个数学上的约定，方便我们处理反向流量。

$$f(u,v) = -f(v,u)$$

增广与反悔的核心是**残量网络**：正向边 $(u,v)$ 还能再增广的量为 $c(u,v)-f(u,v)$；反向边 $(v,u)$ 的容量等于已用流量 $f(u,v)$，用于撤销此前的分配。

**分层图**由 BFS 得到，层号 `wLG[u]` 即 $u$ 到源点按边数计的最短距离：

$$\text{wLG}[s] = 0, \qquad \text{wLG}[v] = \text{wLG}[u] + 1 \quad (\text{沿残量边 } (u,v))$$

DFS 只沿 `wLG[e.to] == wLG[u] + 1` 的边推进，单条增广路能通过的流量等于路径上残量容量的最小值，逐边取 $\min$ 向下传递。

最大流最小割定理：

$$\text{最大流} = \text{最小割}$$

## 逐行代码解析

下面按模块把两份模板拆开讲。各代码块按顺序拼接起来（先是最大流 Dinic，再是费用流），就是 `codePath` 指向的 `.cpp`。

### 模板一 · 模块 1-1：头文件与全局数据结构

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N=210;
const int INF=LLONG_MAX;
int n,m,s,t,mxf=0;
#define fi first
#define se second
typedef pair<int,int> PII;
struct ege{
	int to,w;
	int rev;
};
vector<ege> wYG[N],wRG[N];//原图和残量网络
int wLG[N],cur[N];//记录层数
```

- `N=210` 是顶点上限；`#define int long long` 把 `int` 全部替换成 `long long` 防流量溢出，因此入口要写 `signed main`。
- 边结构体 `ege` 存 `to`（终点）、`w`（残量容量）、`rev`（反向边在 `wRG[to]` 中的下标）。
- `wYG` 存原图、`wRG` 存残量网络（含反向边）；`wLG` 存分层号、`cur` 存当前弧。
- `INF` 取 `LLONG_MAX` 表示"无穷大流量"，初始流量 `mxf=0`。

### 模板一 · 模块 1-2：bfs 构建分层图

```cpp
bool bfs(){
	for(int i=1;i<=n;i++) wLG[i]=-1;
	queue<int> q;
	q.push(s);
	wLG[s]=0;
	while(q.size()){
		int tmp=q.front();q.pop();
		for(auto i:wRG[tmp]){
			if(wLG[i.to]!=-1) continue;
			if(i.w==0) continue;
			q.push(i.to);
			wLG[i.to]=wLG[tmp]+1;
		}
	}
	if(wLG[t]==-1) return false;
	else return true;
}
```

- 先把所有层号置为 $-1$（未访问），从源点 $s$ 开始 BFS，层号 = 父节点层号 $+1$。
- 只沿"残量容量大于 0"的边走（`i.w==0` 跳过），保证是在残量网络上分层。
- 返回 $t$ 是否可达：`wLG[t] == -1` 说明 $s$ 已经无法到达 $t$，增广结束。

### 模板一 · 模块 1-3：dfs 阻塞流增广

```cpp
int dfs(int u,int f){
	if(u==t) return f;
	for(int &i=cur[u];i<(int)wRG[u].size();i++){
		ege &e=wRG[u][i];
		if(e.w>0&&wLG[e.to]==wLG[u]+1){
			int ret=dfs(e.to,min(f,e.w));
			if(ret>0){
				e.w-=ret;
				wRG[e.to][e.rev].w+=ret;
				return ret;
			}
		}
	}
	return 0;
}
```

- 到达汇点直接返回可增广流量 `f`；否则只沿"下一层"的边（`wLG[e.to]==wLG[u]+1`）递归。
- `int &i=cur[u]` 是引用，实现**当前弧优化**：已经饱和或无用的边不会在下一次 DFS 到 $u$ 时重试。
- 增广后正向边 `e.w` 减去流量、反向边 `wRG[e.to][e.rev].w` 加上流量，即"反悔"机制。
- 一次 DFS 只返回一条增广路的流量，主循环反复调用直到返回 $0$。

### 模板一 · 模块 1-4：main 建图与主循环

```cpp
signed main(){
	cin>>n>>m>>s>>t;
	for(int i=1;i<=m;i++){
		int u,v,w;cin>>u>>v>>w;
		wYG[u].push_back({v,w,0});
		wRG[u].push_back({v,w,(int)wRG[v].size()});
		wRG[v].push_back({u,0,(int)wRG[u].size()-1});
	}
	while(bfs()){
		for(int i=1;i<=n;i++) cur[i]=0;
		while(true){
			int pus=dfs(s,INF);
			if(pus==0) break;
			mxf+=pus;
		}
	}
	cout<<mxf<<'\n';
	return 0;
}
```

- 每条原边同时建正向边与反向边：正向边 `rev` 指向反向边的位置，反向边 `rev` 指向正向边的位置（`wRG[u].size()-1`）。
- 每轮 BFS 成功后把当前弧 `cur` 重置为 $0$，再反复 `dfs(s, INF)` 增广，把返回流量累加进 `mxf`。
- 当 `dfs` 返回 $0$（当前分层图已阻塞）就结束本轮，重新 BFS；最终输出最大流 `mxf`。

### 模板二 · 模块 2-1：头文件与全局数据结构（多了费用）

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N=5e3+10;
const int INF=LLONG_MAX;
int n,m,s,t,mxf=0,mic=0;
#define fi first
#define se second
typedef pair<int,int> PII;
struct ege{
	int to,w;
	int rev;
	int cost;
};
vector<ege> wYG[N],wRG[N];//原图和残量网络
int wLG[N],cur[N];//记录层数
bool inq[N],vis[N];
```

- 与 Dinic 相比，`N` 扩大到 `5e3+10`，边结构体多了一个 `cost`（单位费用），并新增 `mic` 记录最小总费用。
- `inq` 用于 SPFA 的入队标记，`vis` 用于增广时的防环标记。

### 模板二 · 模块 2-2：spfa 求费用最短路

```cpp
bool spfa(){
	for(int i=1;i<=n;i++) wLG[i]=INF;
	for(int i=1;i<=n;i++) inq[i]=false;
	queue<int> q;
	q.push(s);
	wLG[s]=0;
	inq[s]=true;
	while(q.size()){
		int tmp=q.front();q.pop();
		for(auto i:wRG[tmp]){
			if(i.w==0) continue;
			if(wLG[i.to]<=wLG[tmp]+i.cost) continue;			
			wLG[i.to]=wLG[tmp]+i.cost;
			if(inq[i.to]==false){
				q.push(i.to);
				inq[i.to]=true;
			}
		}
	}
	return inq[t];
}
```

- 这里 `wLG` 的含义从"层号"变成了"到源点的最小费用"：初始化为 `INF`，源点为 $0$。
- 只沿残量容量大于 0 的边走（`i.w==0` 跳过）；若走到 `i.to` 的费用能更小就松弛并尝试入队（`inq` 标记避免重复入队）。
- 返回 `inq[t]`：$t$ 还在队列里（即被松弛过、可达）就说明找到了费用最短路，可以增广。

### 模板二 · 模块 2-3：dfs 增广并累加费用

```cpp
int dfs(int u,int f){
	if(u==t) return f;
	vis[u]=true;
	int nf=0;
	for(int &i=cur[u];i<(int)wRG[u].size();i++){
		ege &e=wRG[u][i];
		if(e.w>0&&wLG[e.to]==wLG[u]+e.cost&&!vis[e.to]){
			int ret=dfs(e.to,min(f-nf,e.w));
			if(ret>0){
				e.w-=ret;
				wRG[e.to][e.rev].w+=ret;
				mic+=e.cost*ret;
				nf+=ret;
				if(nf==f) break;
			}
		}
	}
	vis[u]=false;
	return nf;
}
```

- DFS 只沿"费用恰好递推一层"的边：`wLG[e.to] == wLG[u] + e.cost`，保证始终走在费用最短路上；`!vis[e.to]` 防止在负权/环上兜圈。
- 增广时除更新反向边外，还要把 `mic += e.cost * ret` 累加进总费用。
- 这里 `nf` 是本次 DFS 已增广的流量，`f-nf` 是剩余可增广量，全部用完（`nf==f`）就提前 `break`；返回本次总共增广的流量。

### 模板二 · 模块 2-4：main 建图与主循环

```cpp
signed main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	cin>>n>>m>>s>>t;
	for(int i=1;i<=m;i++){
		int u,v,w,c;cin>>u>>v>>w>>c;
		wYG[u].push_back({v,w,0,c});
		wRG[u].push_back({v,w,(int)wRG[v].size(),c});
		wRG[v].push_back({u,0,(int)wRG[u].size()-1,-c});
	}
	while(spfa()){
		for(int i=1;i<=n;i++) cur[i]=0;
		while(true){
			int pus=dfs(s,INF);
			if(pus==0) break;
			mxf+=pus;
		}
	}
	cout<<mxf<<" "<<mic<<'\n';
	return 0;
}
```

- 读入每条边时多读一个费用 $c$：正向边费用为 $c$，反向边费用为 $-c$（撤销时把费用也退回来）。
- 主循环结构与 Dinic 一致，只是把 `bfs()` 换成 `spfa()`；每轮 SPFA 成功后重置 `cur`，反复 DFS 增广。
- 最后同时输出最大流 `mxf` 与最小费用 `mic`。

## 复杂度分析

- **最大流 Dinic**：时间复杂度 $O(n^2 m)$（$n$ 为顶点数，$m$ 为边数）。每次 BFS 构建分层图花费 $O(m)$；每轮增广后 $s$ 到 $t$ 的最短距离至少增加 1，因此 BFS 至多进行 $O(n)$ 轮；每一轮在分层图上用当前弧优化求阻塞流的 DFS 为 $O(nm)$。整体为 $O(n^2 m)$，实际运行远达不到这个上界。
- **空间复杂度**：$O(n+m)$。残量网络 `wRG` 为每条原边同时存正向边与反向边，共 $2m$ 条有向边；原图 `wYG` 存 $m$ 条；分层数组 `wLG` 与当前弧数组 `cur` 各 $O(n)$。
- **费用流**：用 SPFA 求费用最短路，复杂度与增广轮数相关，工程上通常慢于最大流；源码给出的顶点上限也更大（`5e3+10`）。

## 适用场景

- **最大流 / 二分图匹配**：二分图最大匹配可转化为最大流（源点连左部、右部连汇点），因此网络流是比匈牙利算法更通用的匹配工具。
- **分配与调度**：资源分配、任务指派、运输调度等问题，凡能抽象成"有容量上限的流动"都可建模为网络流。
- **最小割 / 割问题**：借助「最大流 = 最小割」，把"删边使图不连通的最小代价"转化为最大流求解。
- **费用流**：在运输、指派中每条边有单位费用，要求"在流量最大的前提下费用最小"时使用。
- **建模类问题**：点容量限制（拆点）、分层图、闭合子图等技巧常与网络流结合。

不适合直接用网络流的情况：普通的单源最短路、最小生成树、拓扑排序等有专属算法的问题，用对应算法更高效、更简单。

## 常见陷阱与注意事项

1. **反向边的 `rev` 必须配对**：建边时正向边的 `rev` 指向反向边在 `wRG[to]` 中的下标，反向边的 `rev` 指向正向边在 `wRG[u]` 中的下标。写错会导致增广时改错边、残量网络错乱。
2. **当前弧 `cur` 每轮 BFS / SPFA 后要重置为 0**：`cur` 记录的是"当前分层图里已废的边"，换新图后必须清空，否则会沿用上一轮的断点而漏掉增广路。
3. **DFS 只能沿"前进一层"的边**：最大流要求 `wLG[e.to] == wLG[u] + 1`，费用流要求 `wLG[e.to] == wLG[u] + e.cost`，写法不同别混。
4. **容量为 0 的边要跳过**：`if (i.w == 0) continue;` 若不写，会沿已饱和的边反复递归，造成死循环或错误增广。
5. **`#define int long long` 与 `signed main`**：把 `int` 宏替换成 `long long` 后，`main` 的返回类型也变成 `long long`，必须写成 `signed main()`，否则编译报错。
6. **多组数据要清空**：多次建图时需清空 `wYG` / `wRG`，并把 `mxf`（及费用流的 `mic`）归零，避免上一组数据残留。
7. **费用流不能用 Dijkstra 求最短路**：反向边的费用取负，图中存在负权边，必须用 SPFA；同时用 `vis` 防止在环上无限递归。

## 对比与扩展

- **最大流 vs 最小割**：二者互为对偶，`最大流 = 最小割` 是网络流最核心的定理，很多"删边代价"问题由此转化为最大流。
- **Dinic vs EK / ISAP**：EK 每次 BFS 只找一条增广路，实现简单但较慢；ISAP 是 Dinic 的改进（省去反复 BFS 的开销）；Dinic 是竞赛中最常用、综合效率最高的实现。
- **反向边 = 反悔贪心**：网络流中反向边的设计，本质上是给贪心增广加上了"撤销"能力，与反悔贪心的思想一脉相承。
- **费用流（SPFA + 增广路）**：在最大流基础上给每条边增加**费用**属性，目标是"保证流量最大的前提下最小化总费用"。每轮用 SPFA 在残量网络上找一条费用最短路并沿其增广，重复到找不到增广路为止；因为每次都在当前残量网络上找费用最短路，最终得到的最大流费用最小。
