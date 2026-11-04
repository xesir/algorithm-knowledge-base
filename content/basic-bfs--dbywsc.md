---
id: basic-bfs
title: 'BFS 广度优先搜索'
category: 基础算法
subcategory: 搜索
tags: ["BFS", "状态压缩", "迷宫", "队列", "搜索"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

BFS 按“距离由近到远”的顺序遍历状态空间，通常用队列实现：

1. 起点入队；
2. 取队首；
3. 枚举它能到达的下一状态；
4. 未访问的状态入队；
5. 队列为空或找到目标时停止。

BFS 适合边权相同（或边权为 1）的最短路。状态不只是坐标，还可以带方向、剩余次数、持有状态等附加信息。

### 状态设计：CF2041D Drunken Maze

题目在普通迷宫上增加了“不能连续往同一个方向走超过 $k$ 步”的限制。此时状态需要记录：

$$
\{x,\ y,\ last,\ cnt\}
$$

- $x,y$：当前位置；
- $last$：上一步的方向；
- $cnt$：在当前方向上已经连续走了多少步；
- 另外用 `dis` 记录步数。

初始状态为 $\{start_x,start_y,-1,0\}$。转移时枚举四个方向：

- 如果新方向与 `last` 相同，则 `cnt+1`，若超过限制则不能走；
- 如果方向不同，则 `cnt=1`。

`vis` 也要记录这四个属性，否则同一坐标不同方向/连续步数的状态会被错误去重。

### 状态压缩

直接开四维 `vis[x][y][last][cnt]` 在 $n,m$ 较大时容易 MLE。可以把状态编码成一个整数：

$$
id=((x\cdot m+y)\cdot4+last)\cdot4+cnt.
$$

这样 `vis` 只需要一维数组。编码时要保证每一维的进制足够大，避免不同状态撞在一起。

## 核心公式 / 状态定义与转移方程

- 状态：$(x,y,last,cnt)$。
- 转移：
  - 若 $d=last$：$cnt'=cnt+1$，要求 $cnt'\le k$；
  - 否则：$cnt'=1$；
  - 新状态 $(x',y',d,cnt')$，距离 $dis+1$。
- 访问标记：`vis[id]`，`id=((x*m+y)*4+d)*4+cnt`。
- 答案：第一次到达终点时的 `dis`；队列空仍未到达则无解。

## 逐行代码解析

```cpp
struct state {
    int x, y, last, cnt, dis;
};

int bfs(state start, int n, int m, vector<vector<char>>& G, int ex, int ey) {
    vector<int> vis(n * m * 4 * 4 + 1, 0);
    auto compress = [&](int x, int y, int d, int cnt) -> int {
        return (((x - 1) * m + (y - 1)) * 4 + d) * 4 + cnt;
    };

    queue<state> q;
    q.push(start);
    while (!q.empty()) {
        auto u = q.front();
        q.pop();
        if (u.x == ex && u.y == ey) return u.dis;

        for (int d = 0; d < 4; d++) {
            int nx = u.x + dx[d];
            int ny = u.y + dy[d];
            if (nx < 1 || nx > n || ny < 1 || ny > m || G[nx][ny] == '#') continue;

            int cnt = u.cnt;
            if (d == u.last) {
                if (u.cnt == 3) continue;   // 以 k=3 为例
                cnt++;
            } else {
                cnt = 1;
            }

            int id = compress(nx, ny, d, cnt);
            if (!vis[id]) {
                vis[id] = 1;
                q.push({nx, ny, d, cnt, u.dis + 1});
            }
        }
    }
    return -1;
}
```

- `state` 保存坐标、上一步方向、连续步数、距离。
- `vis` 用一维数组，`compress` 把四维状态压成一个整数。
- 坐标从 $1$ 开始，编码时先减 $1$；若直接用 `x*m+y`，`vis` 按 `n*m*4*4` 开会略小，可能越界。
- 同方向时检查连续步数上限；不同方向时重置为 $1$。
- 第一次到达终点就是最短步数；队列空返回 $-1$。
- 代码是原文节选，`dx` / `dy` 方向数组按你的模板补齐。

## 复杂度分析

- 状态数：$O(nm\cdot4\cdot k)$。
- 每个状态枚举四个方向，转移 $O(1)$，总时间 $O(nmk)$。
- 空间：`vis` 为 $O(nmk)$，队列最坏 $O(nmk)$。
- 若 $k$ 很小（如本题 $k\le3$），状态数约为 $O(nm)$。

## 适用场景

- 迷宫最短路、网格 BFS。
- 状态需要带方向、连续步数、剩余次数、持有物品等附加信息。
- 边权相同的最短路。
- 多源 BFS、01 BFS（边权 0/1）等变体。

## 常见陷阱与注意事项

1. **`vis` 只记坐标**：带方向/连续步数的状态必须把这些维度一起记，否则会错误去重。
2. **状态编码进制不够**：`cnt` 的上界、方向数、坐标范围要留够，否则不同状态可能编码相同。
3. **连续步数边界**：是“不能超过 $k$”还是“不能达到 $k$”，要看题目；代码里用 `u.cnt == 3` 是以 $k=3$ 为例。
4. **起点/终点标记**：起点和终点可能不是 `.`，判断障碍时不要把它们误判。
5. **队列元素过多**：状态数大时 BFS 可能 MLE，优先压缩状态或剪枝。
6. **多测清空**：`vis` 和队列在多组数据间要清空。
7. **方向数组**：`dx/dy` 要和题目坐标方向一致，尤其是行列从 0 还是 1 开始。

## 对比与扩展

- **BFS vs DFS**：BFS 求最短路、按层扩展；DFS 强调可达性、适合回溯/枚举。
- **普通 BFS vs 状态 BFS**：普通 BFS 状态是坐标；状态 BFS 把附加信息放进状态，`vis` 也要相应扩展。
- **BFS vs Dijkstra**：边权全 1 用 BFS；边权非负且不同用 Dijkstra；边权只有 0/1 用 0-1 BFS。
- **状态压缩**：四维 `vis` 可以压成一维整数，也可以使用 `map`/`set`，但数组编码通常更快。
