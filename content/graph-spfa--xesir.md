---
id: graph-spfa
title: 'SPFA 最短路与判负环（队列优化 Bellman-Ford）'
category: 图论
subcategory: 最短路
subSubcategory: 单源最短路
tags: ["图论", "最短路", "SPFA", "Bellman-Ford", "负权边", "判负环", "队列优化"]
timeComplexity: '最坏 O(nm)，实际通常很快'
spaceComplexity: 'O(n+m)'
level: A
codePath: '图论\最短路\Bellman-Ford 批量松弛优化（类SPFA变体）\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

最朴素的带负权最短路是 Bellman-Ford：暴力松弛 $n-1$ 轮，每轮把所有边都试一遍，复杂度 $O(nm)$。

SPFA 优化的点很直白：**只有本轮被更新过的点，才有可能去更新别人**。所以拿个队列把这些点维护起来，每次取队首，松弛它的出边；如果某个点被更新且它不在队列里，就把它入队。这样大量不必要的松弛就被省掉了。

**判断负环**：如果某个点入队/被更新的次数超过 $n$，说明存在负环——也就是可以无限绕圈让总权值无限变小，此时最短路根本不存在。

本代码就是一个**带判负环**的版本：它把所有点初始入队（相当于加了一个"超级源点"，这样能检测到任意位置可达的负环），并用 `cnt[v] = cnt[u] + 1` 记录松弛链长度，一旦 `cnt[v] >= n` 就返回"有负环"。

## 核心公式 / 状态定义与转移方程

松弛依然是那套：

$$dis[v] = \min\big(dis[v],\ dis[u] + w\big)$$

负环判定（`cnt[v]` 表示到 `v` 的最短路边数上界）：

$$\text{cnt}[v] \geq n \;\Rightarrow\; \text{存在负环}$$

## 逐行代码解析

下面把整份模板按模块拆开讲，各块按顺序拼起来就是完整代码。

### 模块一：头文件与全局变量

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N = 2010;
vector<pair<int,int>> e[N];
int dis[N], cnt[N], vis[N];
queue<int> q;
```

- `#define int long long` 把全局的 `int` 偷换成 `long long`，代价是常数变大；开了它，`main` 必须写成 `signed main()`。
- `e` 是邻接表，存 `(终点, 权值)`；`cnt` 记录当前松弛链长度（判负环用），`vis` 记录点是否**在队列里**。
- `N = 2010` 是点数上限，直接开死。

### 模块二：spfa 函数

```cpp
bool spfa(int n) {
    for(int i=1;i<=n;i++){
        dis[i] = 0, vis[i] = 1;
          q.push(i);
    }
    while (!q.empty()) {
        int u = q.front();
        q.pop(), vis[u] = 0;
        for (auto ed : e[u]) {
              int v = ed.first, w = ed.second;
              if (dis[v] > dis[u] + w) {
                dis[v] = dis[u] + w;
                cnt[v] = cnt[u] + 1;  
                if (cnt[v]>=n) return false;
                if (!vis[v]) q.push(v), vis[v] = 1;
            }
        }
    }
    return true;
}
```

- 开头把所有点的 `dis` 清成 `0` 并入队——这是"超级源点"式写法，配合判负环能扫描到任意位置的可达负环。
- 出队时 `vis[u] = 0`，表示它已经不在队列里了，之后可以再次入队。
- `if (dis[v] > dis[u] + w)` 是松弛条件；成功后 `cnt[v] = cnt[u] + 1`，`cnt[v] >= n` 直接 `return false`（有负环）。
- 返回 `true` 表示跑完没有负环。

### 模块三：main 函数

```cpp
signed main(){
    int n,m;cin >> n >> m;
    memset(dis,0x3f,sizeof dis);
    for(int i = 1; i <= m; i ++) {
        int a, b; cin >> a >> b;
        int c; cin >> c;
        e[a].push_back({b, c});
    }

    if(spfa(n)) cout<<"No";
    else cout<<"Yes";    
    return 0;
}
```

- `memset(dis,0x3f,sizeof dis)` 把 `dis` 置成 `0x3f3f3f3f`；不过在这份"只判负环"的版本里其实用不上，因为 `spfa` 开头又会把所有 `dis[i]` 清成 0。
- 读 $m$ 条有向边，只加 `e[a].push_back({b, c})` 一条。
- 调用 `spfa(n)`，返回真就输出 `"No"`、否则 `"Yes"`（注意这里的输出是这套题的约定，和"有没有负环"的语义相反，用的时候按题目要求改）。

## 复杂度分析

- 时间复杂度：理论上 $O(nm)$，但实际通常很快。注意在构造数据下会被卡到 $O(nm)$，容易 TLE。
- 空间复杂度：$O(n+m)$，邻接表加上 `dis`、`cnt`、`vis` 几个数组。

## 适用场景

- **有负权边**的最短路（正权也能跑，但没优势）。
- **判断负环**：这是 SPFA 至今仍然"必须存在"的核心场景，很多图论算法的前置步骤都靠它。
- 后续一些图论算法会直接拿 SPFA 当基础组件。

> 警告：因为出题人喜欢卡 SPFA，OI 里它已经逐渐失宠，很多老司机说"SPFA 已死"。所以写最短路首选**一定是 Dijkstra**，~~不然莫名其妙 T 了也不能怪别人辣~~。当然这不代表它啥时候都不能用，判负环这种特殊场景还是得靠它。

## 常见陷阱与注意事项

1. **被构造数据卡爆**：复杂度最坏 $O(nm)$，别在正权最短路题里无脑用它。
2. **判负环的 `cnt` 写法**：`cnt[v] = cnt[u] + 1` 表示路径边数，`cnt[v] >= n` 才说明有负环；写成"入队次数"也行，但两者别混着写。
3. **`#define int long long` 的连带影响**：开了它入口必须是 `signed main()`，否则编译报错。
4. **数组上限 `N = 2010`**：写死的，点数超了要改。
5. **多组数据要清空**：`dis`、`cnt`、`vis`、队列和邻接表每组都要重置。

## 对比与扩展

和 Dijkstra 比，SPFA 能处理负权、能判负环，但复杂度不稳定；和 Floyd 比，SPFA 求单源最短路、能跑大规模稀疏图，Floyd 求全源、只能跑小图。想彻底避开 SPFA 的不稳定性又需要负权，可以考虑 Johnson 重赋权后跑 Dijkstra。
