---
id: graph-kruskal
title: 'Kruskal 最小生成树（并查集 + 贪心）'
category: 图论
subcategory: 最小生成树
subSubcategory: ''
tags: ["图论", "最小生成树", "Kruskal", "并查集", "贪心", "MST", "边贪心"]
timeComplexity: 'O(m log m)'
spaceComplexity: 'O(n+m)'
level: A
codePath: '图论\最小生成树\Kruskal\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

给定一张**带权无向连通图**，选若干条边让所有顶点仍然连通、且所选边权之和最小，选出来的那棵树就叫**最小生成树**（MST）。换成大白话：你要修路把 $n$ 个村子连起来，每条路有造价，怎么修最省钱？答案就是最小生成树。

Kruskal 的核心思想是**边贪心**：

> 把所有边按权值从小到大排序，依次考虑每条边；如果这条边连接的两个点目前还不连通（即加入它不会成环），就把它加入生成树，否则跳过。

为什么贪心是对的？因为按权值从小到大选边，每次选的是当前能连通两个不同连通块的最小边，最终得到的树一定是最小生成树（这是**割性质**的直接应用）。

**具体步骤**：

1. 将 $m$ 条边按权值升序排序。
2. 初始化并查集，每个点自成一个集合。
3. 从小到大遍历边 $(u, v, w)$：
   - 如果 $u$ 和 $v$ 不在同一集合，则合并它们，把边加入答案，计数加 1。
   - 如果已经在同一集合，说明加入这条边会成环，跳过。
4. 当加入的边数达到 $n-1$ 时，生成树构建完成。

## 核心公式 / 状态定义与转移方程

并查集（`gen` 即 find，带路径压缩）：

$$\text{root}(x) = \begin{cases} x, & h[x] = x \\ \text{root}(h[x]), & h[x] \neq x \end{cases}$$

选边判据——两端点不同集合才合并：

$$u \not\equiv v \;\Rightarrow\; \text{选中边 } (u, v, w),\ \text{ans} \mathrel{+}= w$$

## 逐行代码解析

下面把整份模板按模块拆开讲，各块按顺序拼起来就是完整代码。

### 模块一：头文件与并查集

```cpp
#include <bits/stdc++.h>
using namespace std;
int h[100010];
int gen(int x){
    if(h[x]!=x){
        h[x]=gen(h[x]);
    }
    return h[x];
}
```

- `h[x]` 是并查集的父指针，`h[x] == x` 表示它是自己集合的根。
- `gen(x)` 是 find 的递归写法：顺着父指针一路往上找，顺手把路径上的点直接接到根上，也就是**路径压缩**。
- `h` 数组开死成 `100010`，点数超了要改。

### 模块二：边的结构体与优先队列

```cpp
struct side{
    int s,e,l;
    bool operator<(const side &aa)const{
        return l>aa.l;
        }
};
priority_queue<side> f;
```

- `side` 存一条边：`s`、`e` 两个端点，`l` 是权值。
- `return l > aa.l;` 又是那个熟悉的套路：重载 `<` 写成 `>`，于是 `priority_queue` 默认大根堆在取堆顶时拿到的是权值**最小**的边（等价于把所有边按权值排好序）。
- 所以这里用优先队列代替了"排序 + 顺序遍历"。

### 模块三：读边并初始化并查集

```cpp
int main()
{
    int n,m,cnt=0,ans=0;cin>>n>>m;
    for(int i=1;i<=m;i++){
        side s;cin>>s.s>>s.e>>s.l;f.push(s);
    }
    for(int i=1;i<=n;i++){
        h[i]=i;
    }
```

- `cnt` 存答案（已选边权之和），`ans` 存已选边数。
- 读 $m$ 条边，每条按 `s e l` 顺序读入并压进优先队列。
- 初始化并查集：让每个点 `h[i] = i`，各自成一个集合。

### 模块四：贪心选边与输出

```cpp
    while(f.size()){
        auto t=f.top();f.pop();
        if(h[gen(t.s)]==h[gen(t.e)]) continue;
        else {h[gen(t.s)]=gen(t.e);cnt+=t.l;ans++;}
    }
    if(ans==n-1)cout<<cnt;
    else cout<<"impossible";
return 0;
}
```

- 每次取出权值最小的边 `t`：如果两个端点已经同集合，说明成环，`continue` 跳过。
- 否则把两个集合合并（`h[gen(t.s)] = gen(t.e)`），把权值累加进 `cnt`，已选边数 `ans` 加 1。
- 最后若 `ans == n-1`，说明选够了 $n-1$ 条边、生成树构建成功，输出 `cnt`；否则图不连通，输出 `"impossible"`。

## 复杂度分析

- 时间复杂度：优先队列的选边相当于排序 $O(m \log m)$，并查集操作近似 $O(1)$，总 $O(m \log m)$。
- 空间复杂度：$O(n+m)$，并查集数组加上优先队列里的 $m$ 条边。

## 适用场景

最小生成树、判断图的连通性、以及一切"用最小代价把若干点连起来"的问题。Kruskal 实现简单、对**稀疏图**特别友好，是 OI 里最常用的 MST 写法。

## 常见陷阱与注意事项

1. **图不连通**：Kruskal 结束后如果边数不足 $n-1$，说明不存在最小生成树（只适用于连通图），本题输出 `"impossible"`。
2. **优先队列的方向**：`operator<` 里写成 `l > aa.l` 才是"取最小边"，若写反就变成最大生成树。
3. **并查集要路径压缩**：`gen` 里那句 `h[x]=gen(h[x])` 不能省，否则可能退化。
4. **合并时用根节点**：合并写成 `h[gen(t.s)] = gen(t.e)`（把 `s` 的根挂到 `e` 的根上），不能直接对 `t.s` 赋值。
5. **大小写/重边**：重边会被正常处理（都进优先队列，先小后大）；自环因两端同集合会被直接跳过。
6. **数组上限 `100010`**：写死的，点数超了要改。

## 对比与扩展

和 Prim（点贪心、堆优化 $O((n+m)\log n)$）比，Kruskal 是边贪心、代码更短、稀疏图更舒服；Prim 则更适合稠密图，不过日常 OI 里 Kruskal 出场率明显更高。两者都基于割性质，只是切入角度不同。
