---
id: graph-tarjan-scc
title: 'Tarjan 强连通分量'
category: 图论
subcategory: 连通分量
subSubcategory: 强连通分量
tags: ["图论", "强连通分量", "Tarjan", "DFS", "缩点"]
timeComplexity: 'O(n+m)'
spaceComplexity: 'O(n+m)'
level: A
codePath: '图论\连通分量\Tarjan强连通分量\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

先明确概念。对于有向图 $G$，一个点集 $S$ 是**强连通分量**（SCC），当且仅当 $S$ 中任意两个节点互相可达（默认节点可以到达自身）。当它在保持强连通的前提下**没法再扩大**时，就叫**极大强连通分量**，平时说的 SCC 指的就是它。

极大 SCC 有两把刷子：

- 每个点**只属于一个** SCC，不同极大 SCC **互不相交**。
- 把所有极大 SCC 各缩成一个点之后，得到的图一定是个 **DAG**。

第二条是「缩点」这类题的命根子。举个栗子：点集 $\{1,2,3,4,9\}$ 两两可达，是一个极大 SCC；而 $\{5,6,8\}$、$\{7\}$ 各自也是。

求 SCC 常见两种写法：Kosaraju 和 Tarjan。

- **Kosaraju**：两次 DFS。第一次在原图上跑，记下每个点的**完成时间**；第二次在**反图**上，按完成时间**逆序**再跑，每次能访问到的一坨点恰好就是一个 SCC。思路好懂，但要建反图、跑两遍。
- **Tarjan**：~~Tarjan 还是太强了~~ 只跑**一次 DFS** 就能求出全部 SCC，复杂度线性，实战最快。
  > 你说得对，但是**罗伯特·塔扬（Robert Endre Tarjan）**是 **1986 年图灵奖得主**，Tarjan、并查集、Splay、LCT 等算法的发明者，势能分析法开创者。~~吓哭了~~

Tarjan 的关键在于把 DFS 过程中遇到的有向边分成四类：

1. **树边**：搜索树上的边。
2. **返祖边**：指向祖先节点的边。
3. **横叉边**：从一棵子树指向已访问过的另一棵子树的边。
4. **前向边**：指向子树中节点的边。

前向边基本没用；返祖边和树边必然成环；横叉边和树边**可能**成环。DFS 的性质保证只会有这四种边。

## 核心公式 / 状态定义与转移方程

Tarjan 只维护两个数组：

- `dfn[u]`：点 $u$ **第一次**被 DFS 访问到的时间戳。
- `low[u]`：从 $u$ 出发，经过若干条 DFS 树边、以及**至多一条**返祖边，能够到达的最小 `dfn`。

设 $u$ 的邻点为 $v$，转移分三种情况：

- $v$ **未访问**：$u$ 是 $v$ 在搜索树上的父亲，$v$ 能到的 $u$ 一定能到，所以先递归 $v$，再用 `low[v]` 更新：

$$
low[u] = \min(low[u],\ low[v])
$$

- $v$ **已访问且在栈中**（返祖边 / 横叉边）：用 `dfn[v]` 更新：

$$
low[u] = \min(low[u],\ dfn[v])
$$

- $v$ **已访问且不在栈中**：说明 $v$ 已经属于另一个处理完的 SCC，直接跳过。

回溯时若 `dfn[u] == low[u]`，$u$ 就是当前 SCC 的根，此刻栈中从栈顶到 $u$ 的所有点正好构成这个 SCC，一起弹出来即可。

## 逐行代码解析

下面把整份模板按模块拆开讲，各块按顺序拼起来就是完整代码。

### 头文件与宏定义

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) x&(-x)
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
//const int N=1e5+10;
//int cnt=0;
//int a[N];
inline int read();
inline void write(int x);
```

- `#define int long long` 是把全局的 `int` 偷换成 `long long` 的常用套路，代价是常数变大；开了它，`main` 要写成 `signed main()`。
- 提前声明 `read` / `write`，方便在 `main` 里直接用（编译器要在使用前看到声明）。

### 全局变量

```cpp
const int MAXN = 10005;
vector<int> G1[MAXN];  // 邻接表存储有向图
int dfn[MAXN], low[MAXN], scc[MAXN];  // scc[u]表示u所属的SCC编号
stack<int> st;
int idx = 0, tot = 0;  // 时间戳、SCC数量
bool vis[MAXN];  // 标记是否在栈中
```

- `scc[u]` 记录点 $u$ 属于第几个 SCC，是后面缩点的基础。
- `vis[u]` 记录 $u$ **是否还在栈里**，这是判断「已访问且在栈中」的依据。

### tarjan 函数

```cpp
void tarjan(int u) {
    dfn[u] = low[u] = ++idx;
    st.push(u);
    vis[u] = true;
    for (int v : G1[u]) {
        if (!dfn[v]) {  // v未访问
            tarjan(v);
            low[u] = min(low[u], low[v]);
        } else if (vis[v]) {  // v已访问且在栈中（回边）
            low[u] = min(low[u], dfn[v]);
        }
    }
    // 找到SCC的根
    if (dfn[u] == low[u]) {
        tot++;
        int v;
        do {
            v = st.top();
            st.pop();
            vis[v] = false;
            scc[v] = tot;
        } while (v != u);
    }
}
```

- 进入时先打时间戳、入栈、置 `vis = true`。
- 注意第二支用的是 `dfn[v]` 而不是 `low[v]`：已访问且在栈中的点，只能通过它**本身的**时间戳来更新，写错了会连成一片。
- 弹出时用 `do…while`，保证根 $u$ 自己也被弹出。

### main 函数

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
	//int n;cin>>n;
    return 0;
}
```

- 这里只留了框架：真正的建图、调用 `tarjan(1..n)`、统计答案都空着，按题目填即可。
- 关同步 + 解除 `cin` / `cout` 绑定，配合快读快写一起用。

### 快读快写

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

- `read` 用 `x = (x<<1) + (x<<3) + (ch^48)`，等价于 `x = x*10 + (ch-'0')`，位运算更快。
- `write` 是递归版，先把高位输出完再输出末位，天然就是正序。

## 复杂度分析

每个点、每条边都只被处理常数次：入栈出栈各一次，遍历邻接表总计 $O(m)$，所以

- 时间复杂度：$O(n + m)$，严格线性，没有 $\log$。
- 空间复杂度：$O(n + m)$，即邻接表加上三个数组。

## 适用场景

- **缩点**：把 SCC 缩成点后原图变 DAG，接着就能在上面跑拓扑 / DP（如最长路、方案计数）。
- **判环 / 找环**：一个 SCC 大小大于 1 就说明有环。
- **2-SAT、传递闭包**等有向图结构问题的前置步骤。
- 需要「有向图强连通结构」时优先用 Tarjan；如果只是无向图割点 / 桥，那是另一套 Tarjan 变体。

## 常见陷阱与注意事项

1. **`low` 更新用错数组**：已访问且在栈中的点要用 `dfn[v]`，未访问的点递归后用 `low[v]`，这两个别搞混。
2. **忘记判 `vis[v]`**：如果只用 `dfn[v]` 判「访问过」，会把已经出栈、属于别的 SCC 的点也算进来，结果全错。
3. **链状图爆栈**：递归 Tarjan 在一条长链上可能爆栈，必要时开大栈或改写迭代版。
4. **多组数据要清空**：`dfn` / `low` / `scc` / 邻接表在每组数据前都要重置。
5. **图的编号从 0 开始**：`dfn[u]` 未访问判断依赖初值为 0，若点编号含 0 要特殊处理。

## 对比与扩展

| 维度 | Tarjan | Kosaraju |
|---|---|---|
| DFS 次数 | 1 次（原图） | 2 次（原图 + 反图） |
| 是否需要反图 | 不需要 | 需要 |
| 时间复杂度 | $O(n+m)$ | $O(n+m)$ |
| 代码量 / 常数 | 小 / 小 | 稍大 / 稍大 |

扩展方向：

- **缩点建新图**：把 `scc[u]` 当作新点编号，遍历原边去重后得到 DAG（对应 `graph-scc-condensation`、`graph-scc-dag-dp`）。
- **无向图 Tarjan**：同一套 `dfn` / `low` 思想还能求割点、桥、边双 / 点双连通分量，注意无向图要处理「走过的反向边」。
