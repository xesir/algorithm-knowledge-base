---
id: graph-dijkstra-heap
title: 'Dijkstra 最短路（堆优化）'
category: 图论
subcategory: 最短路
subSubcategory: 单源最短路
tags: ["图论", "最短路", "Dijkstra", "堆优化", "优先队列", "单源最短路", "贪心"]
timeComplexity: 'O((n+m) log n)'
spaceComplexity: 'O(n+m)'
level: A
codePath: '图论\最短路\Dijkstra（堆优化）\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

Dijkstra 解决的是**非负权图**上的单源最短路。核心思想一句话：**贪心**。

我们维护一个集合 $S$，表示已经确定了最短路的点。每次从 $S$ 外的点里挑一个**距离起点最近**的点，把它塞进 $S$，然后拿它去松弛所有邻边（即更新别的点到起点的距离估计）。重复这个过程，直到所有点都进了 $S$ 就完事。

为什么贪心能成立？因为边权全是非负的，当前离起点最近的那个点，不可能再绕别的路变得更近；否则那条路线上第一个走出 $S$ 的点，距离一定比它还小，矛盾。这就是 Dijkstra 正确性的证明。

实现上用一个优先队列（堆）来维护"当前待选点"，每次取堆顶就是距离最小的那个，于是"取最小"从 $O(n)$ 降到了 $O(\log n)$。

> 注：这里的前提是"没有负权边"，因为 Dijkstra 遇到负权边时贪心就不成立了（尤其遇到负环会直接把程序跑死 ~~这回忆的旋涡快要把我吞没~~）。一般题目都是没有负权边的，所以 Dijkstra 作为复杂度最优的最短路，依然是首选。

## 核心公式 / 状态定义与转移方程

设 $d[u]$ 为源点到 $u$ 的当前最短距离估计，初始：

$$d[S] = 0, \quad d[v] = +\infty \ (v \neq S)$$

对已确定点 $u$ 的每条出边 $(u \to v, w)$，做松弛：

$$d[v] = \min\big(d[v],\ d[u] + w\big)$$

## 逐行代码解析

下面把整份模板按模块拆开讲，各块按顺序拼起来就是完整代码。

### 模块一：头文件与全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
const int INF = 1e9;
const int MaxN = 1e6 + 10;
int n,m;
vector<pair<int,int>> G1[MaxN];
vector<int> d, vis;
```

- `const int INF = 1e9`：用 `1e9` 表示"无穷大"，它比 `INT_MAX` 小，和边权相加不容易溢出。
- `G1` 是邻接表，`G1[a]` 存 `a` 的所有出边，每条边是个 `(终点, 权值)` 的 `pair`。
- `d`、`vis` 声明成 `vector` 而没直接开成数组，是为了后面能 `assign` 动态定大小。

### 模块二：堆结点结构体

```cpp
        struct Point{
            int id,x;
            bool operator<(const Point &aa)const{return x>aa.x;}
        };
```

- `Point` 里 `id` 是点编号、`x` 是当前距离。
- 关键在这句 `return x>aa.x;`：重载 `<` 却写成了 `>`，于是距离**小的**反而"更大"，`priority_queue` 默认大根堆在取堆顶时就取到了**距离最小**的点——这是把小根堆"骗"出来的经典写法。

### 模块三：solve 主过程

```cpp
        void solve(int S) {
            d.assign(1e6, INF);
            vis.assign(1e6, 0);
            d[S] = 0;
            priority_queue<Point> q;
            q.push({S, 0});
            while (!q.empty()) {
                auto it= q.top(); q.pop();
                if (vis[it.id]) continue;
                vis[it.id] = 1;
                for (auto t: G1[it.id]) {
                    if (d[it.id] + t.second < d[t.first]) {
                        d[t.first] = d[it.id] + t.second;
                        if (!vis[t.first]) q.push({t.first, d[t.first]});
                    }
                }
            }
        }
```

- `d.assign(1e6, INF)` 把距离数组开成 $10^6$ 并全部置 `INF`，源点再单独设 `0`。
- `if (vis[it.id]) continue;` 是**惰性删除**：同一个点可能被多次入堆，弹出旧条目时它已经被标记过，直接跳过。
- 内层 `if (d[it.id] + t.second < d[t.first])` 就是松弛条件；成功就更新 `d[t.first]`，并且在 `t.first` 还没确定时把新距离压堆。

### 模块四：main 函数

```cpp
int main() {
    cin >> n >> m;
        for(int i = 1; i <= m; i ++) {
            int a, b; cin >> a >> b;
            int c; cin >> c;
            G1[a].push_back({b, c});
        }
        solve(1);
        if(d[n] == INF) cout << -1 << endl;
        else cout << d[n] << endl;
    return 0;
}    
```

- 先读 $n$ 个点、$m$ 条边，每条边按 `a b c`（先两个端点，再权值）读入；这是有向边，所以只加 `G1[a].push_back({b, c})` 一条。
- 从 1 号点开跑 `solve(1)`，最后输出源点到 $n$ 号点的距离，不可达就输出 `-1`。

## 复杂度分析

用优先队列（堆）优化后：

- 时间复杂度：$O((n+m)\log n)$，其中 $n$ 是点数、$m$ 是边数。每条边最多贡献一次入堆，单次堆操作是 $\log n$ 的。
- 空间复杂度：$O(n+m)$，主要是邻接表，再加上 `d`、`vis` 两个数组。

## 适用场景

边权**全场非负**的图（有向、无向都行）求单源最短路。因为复杂度稳定、基本卡不动，OI 里写最短路首选就是它。

## 常见陷阱与注意事项

1. **负权边**：图里有负权边时贪心失效，最短路不保证正确，负环更是直接出错或死循环；这种情况只能上 Bellman-Ford 或 SPFA（判负环）。
2. **`INF` 相加溢出**：本例用 `1e9` 比较安全；若 `INF` 取 `INT_MAX`，`xA + w` 会溢出成负数。
3. **无向图少建边**：代码只建了 `G1[a]` 这一条有向边，无向图还要补 `G1[b].push_back({a, c})`，否则漏掉反向路。
4. **堆里 `Point` 的比较方向**：`operator<` 里写的是 `x>aa.x`，别手滑改成 `x<aa.x`，否则就变成"取最远点"，全错。
5. **写死的数组上限**：这份模板把长度硬编码成 $10^6$（`MaxN` 与 `assign(1e6, ...)`），点编号超过就不能用了，实战要按题目范围改。

## 对比与扩展

和朴素 Dijkstra（$O(n^2)$）比，堆优化在稀疏图（$m \ll n^2$）里快得多；和 SPFA 比，它不会被构造数据卡到 $O(nm)$，代价是没能力处理负权。想求全源最短路可以看 Floyd，想支持负权可以看 Johnson。
