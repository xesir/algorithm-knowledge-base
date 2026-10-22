---
id: graph-prim
title: 'Prim 最小生成树（堆优化·Dijkstra 型框架）'
category: 图论
subcategory: 最小生成树
subSubcategory: ''
tags: ["图论", "最小生成树", "Prim", "堆优化", "优先队列", "贪心", "MST"]
timeComplexity: 'O((n+m) log n)'
spaceComplexity: 'O(n+m)'
level: A
codePath: '图论\最小生成树\Prim\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

给定一张**带权无向连通图**，选若干条边让所有顶点仍然连通、且所选边权之和最小，选出来的那棵树就叫**最小生成树**（MST）。

Prim 的思路和 Dijkstra 很像：维护一个已选点集合 $S$，每次从 $S$ 外的点中，选一个**离 $S$ 最近的点**加入 $S$，同时把连接它的那条最小边加入生成树。用堆优化后复杂度是 $O((n+m)\log n)$。~~复杂度又带点又带边还是太幽默了~~

正确性同样来自**割定理**：把点分成已选的 $S$ 和未选的部分，横跨这条"割"的边里权值最小的那条，一定属于某棵最小生成树。

## 核心公式 / 状态定义与转移方程

设 `d[v]` 为点 $v$ 到集合 $S$ 的**当前最短连接边权**（注意和 Dijkstra 不同，这里存的是"到 $S$ 的一条边"，不是"到起点的路径长度"）：

$$d[v] = \min\big(d[v],\ w(u, v)\big) \quad (u \in S,\ v \notin S)$$

每步取堆顶得到当前离 $S$ 最近的未选点，把它并入 $S$ 并累加这条边权。

## 逐行代码解析

下面把整份模板按模块拆开讲，各块按顺序拼起来就是完整代码。

### 模块一：头文件与全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
const int INF = 1e9;
const int MaxN = 1e6 + 10;
int n,m,cnt=0,ans=0;
vector<pair<int,int>> G1[MaxN];
vector<int> d, vis;
```

- `cnt` 存答案（已选边权之和），`ans` 存已加入生成树的点数。
- `G1` 是邻接表，`d` 记录每个点到 $S$ 的当前最短连接边权，`vis` 标记点是否已进 $S$。
- `INF = 1e9` 作初始"无穷大"，`MaxN` 是写死的数组上限。

### 模块二：堆结点结构体

```cpp
        struct Point{
            int id,x;
            bool operator<(const Point &aa)const{return x>aa.x;}
        };
```

- 和 Dijkstra 完全一样：`id` 是点编号、`x` 是到 $S$ 的当前边权。
- `return x>aa.x;` 把默认大根堆"骗"成小根堆，堆顶就是当前离 $S$ 最近的候选点。

### 模块三：solve 主过程

```cpp
        void solve(int S) {
            d.assign(1e6,INF);
            vis.assign(1e6,0);
            d[S]=0;
            priority_queue<Point> q;
            q.push({S, 0});
            
            while (!q.empty()) {
                
                auto it= q.top(); q.pop();
                if (vis[it.id]) continue;
                vis[it.id] = 1;
                cnt+=it.x;
                //cout<<cnt<<endl;
                if(ans>=n)break;
                ans++;
                for (auto t: G1[it.id]) {
                    if (t.second < d[t.first]) {
                        d[t.first] = t.second;
                        if (!vis[t.first]){ q.push({t.first, d[t.first]});}
                    }
                }
            }
        }
```

- 起点 `S` 的 `d[S] = 0`，先用 `q.push({S, 0})` 把它放进去（它的边权贡献是 0）。
- `if (vis[it.id]) continue;` 是**惰性删除**：同一个点可能被多次入堆，弹出旧条目时跳过。
- `cnt += it.x;` 把这条连接边权累加进答案，`ans++` 记录又收了一个点；`if(ans>=n)break;` 表示所有点都进树了就收工。
- 扩展时 `if (t.second < d[t.first])` 只在**发现更优边权**时才更新 `d` 并入堆（相当于 Lazy 与 Eager 的折中，减少堆里过期元素的堆积）。
- `//cout<<cnt<<endl;` 是调试残留，保留原样，别提交。

### 模块四：main 函数

```cpp
int main() {
    cin >> n >> m;
    for(int i = 1; i <= m; i ++) {
        int a, b; cin >> a >> b;
        int c; cin >> c;
        G1[a].push_back({b, c});
        G1[b].push_back({a, c});
    }
    solve(1);
    if(ans!=n)cout << "impossible" << endl;
    else cout << cnt << endl;
    return 0;
}    
```

- 读 $n$ 个点、$m$ 条边；因为是**无向图**，每条边都建了双向：`a → b` 和 `b → a`。
- 从 1 号点开跑 `solve(1)`。
- 若 `ans != n` 说明图不连通，输出 `"impossible"`，否则输出最小生成树权值和 `cnt`。

## 复杂度分析

- 时间复杂度：$O((n+m)\log n)$，堆的每次操作是 $\log n$，总操作量是 $O(n+m)$ 级别。
- 空间复杂度：$O(n+m)$，邻接表加上 `d`、`vis` 两个数组。

## 适用场景

最小生成树，尤其是**稠密图**（用邻接矩阵的朴素 Prim 也常有 $O(n^2)$ 版本）。不过在 OI 里一般 Kruskal 更常用——实现更简单、对稀疏图也更友好。

## 常见陷阱与注意事项

1. **无向图要建双向边**：本代码补了 `G1[b].push_back({a, c})`；漏掉就会退化成有向图，结果错误。
2. **判连通**：`ans != n` 时图不连通，没有生成树，本题输出 `"impossible"`。
3. **`d` 的语义别和 Dijkstra 混**：这里是"点到集合 $S$ 的最短边权"，不是"到起点的路径长度"，松弛时用的是 **`t.second`（边权）本身**，而不是 `d[u] + t.second`。
4. **写死的数组上限**：`MaxN` 与 `d.assign(1e6, ...)`、`vis.assign(1e6, ...)` 都硬编码成 $10^6$，点编号超了要改。
5. **惰性删除别忘**：`if (vis[it.id]) continue;` 不能删，否则同一个点会被反复计入 `cnt`。
6. **调试残留**：`//cout<<cnt<<endl;` 记得注释掉/删掉再提交。

## 对比与扩展

Prim 与 Kruskal 都基于割性质，区别在切法：Prim 是"点贪心"，从一个点往外长；Kruskal 是"边贪心"，全局挑最小边。Kruskal 通常更简单、稀疏图更优；Prim 在稠密图上更自然。这份实现直接沿用了 Dijkstra 的堆框架，~~你看代码都是用的 Dijkstra 框架~~，理解时对照 Dijkstra 会快很多。
