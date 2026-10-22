---
id: basic-bfs
title: 'BFS 广度优先搜索'
category: 基础算法
subcategory: 搜索
subSubcategory: ''
tags: ["搜索", "广度优先搜索", "最短路", "队列", "泛洪填充", "01BFS"]
timeComplexity: 'O(V+E)'
spaceComplexity: 'O(V)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

广度优先搜索（**BFS**）是一种按照"距离由近到远"的顺序遍历状态空间的方法。它通常使用队列维护待扩展状态：

1. 将起点加入队列；
2. 每次取出队首状态；
3. 枚举它能够到达的下一状态；
4. 将尚未访问过的状态加入队尾；
5. 重复直到队列为空或找到目标。

BFS 最重要的性质是：在**所有边权相同的图**中，BFS 第一次到达某个状态时，得到的就是起点到它的最短距离。这里的"边权相同"通常指每走一步代价都是 $1$。因此普通 BFS 特别适合状态转移代价相同的搜索问题，如迷宫最短路、处理连通块、层次遍历等。

## 逐行代码解析

### BFS 基本模板

```cpp
void bfs(int start) {
    queue<int> q;

    q.push(start);
    visited[start] = true;
    dist[start] = 0;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v : graph[u]) {
            if (visited[v]) continue;

            visited[v] = true;
            dist[v] = dist[u] + 1;
            q.push(v);
        }
    }
}
```

- 起点先入队，同时打上标记、距离置 0。
- 每次取队首 `u`，枚举它的所有邻点 `v`；已访问的 `continue` 跳过。
- **在入队时就标记**：`visited[v] = true`、`dist[v] = dist[u] + 1`，再 `q.push(v)`。
- 特别注意：应当在**入队时**标记访问，而不是出队时标记。若等出队才标记，同一个节点会被多个前驱重复加入队列，既浪费时间，也容易造成错误。

### 迷宫问题

**问题模型：** 给定一个网格

- `.` 表示可以通行；
- `#` 表示障碍物；
- 每次可以向上、下、左、右移动一格；
- 求起点到终点是否存在路径，或求最短步数。

把每个网格格子看作图中的一个节点，相邻且可以通行的格子之间连一条边。由于每移动一格的代价都为 $1$，所以可以直接使用 BFS。

```cpp
//最常见的迷宫，变式见A5034
#include <bits/stdc++.h>
using namespace std;
char h[700][700];
int st[150][150];
int n;
int dx[]={0,1,0,-1};int dy[]{1,0,-1,0};
void bfs(int ha,int la,int hb,int lb){
    queue<pair<int,int>> a;
    a.push({ha,la});
    while(a.size()){
        auto t=a.front();a.pop();
        if(t.first==hb&&t.second==lb){
            return;
        }
        for(int i=0;i<4;i++){
            int nx=dx[i]+t.first,ny=dy[i]+t.second;
            if(nx<1||nx>n||ny<1||ny>n){
                continue;
            }
            if(st[nx][ny]==-1&&h[nx][ny]=='.'){
                a.push({nx,ny});st[nx][ny]=st[t.first][t.second]+1;
            }
        }
    }
}
int main()
{
    int tk;cin>>tk;
    while(tk--){
        cin>>n;
            for(int i=1;i<=n;i++){
                for(int j=1;j<=n;j++){
                    cin>>h[i][j];st[i][j]=-1;
                }
            }
            int ha;int la;int hb;int lb;cin>>ha>>la>>hb>>lb;
            st[ha+1][la+1]=1;
            bfs(ha+1,la+1,hb+1,lb+1);
           if(st[hb+1][lb+1]!=-1&&h[ha+1][la+1]!='#')cout<<"YES"<<endl;
           else cout<<"NO"<<endl;
    }
    
return 0;
}
```

- `st` 既当访问标记又当距离：初值 `-1` 表示没到过，`st[nx][ny] = st[当前] + 1` 记录步数。
- `dx` / `dy` 是四方向偏移，越界就 `continue`。
- 到达终点直接 `return`（这里只判可达性，最短距离其实已经记在 `st` 里）。
- 读入的起点坐标在 main 里统一 `+1`（从 0 基转 1 基），扩展时也用同一套坐标。

### 记录最短路径

有时候题面不仅要求最短路径长度，还要求输出路径上的所有点。

设 `pre[x][y]` 表示到达 `(x,y)` 之前所在的位置。可以用一个坐标二元组记录：

```cpp
vector<vector<pair<int, int>>> pre(n, vector<pair<int, int>>(m, {-1, -1}));
```

访问新位置时：

```cpp
pre[nx][ny] = {x, y};
```

BFS 结束后，从终点不断沿 `pre` 回溯到起点，再将路径反转即可。

```cpp
vector<pair<int, int>> path;

if (dist[tx][ty] != -1) {
    int x = tx, y = ty;

    while (!(x == sx && y == sy)) {
        path.push_back({x, y});
        tie(x, y) = pre[x][y];
    }

    path.push_back({sx, sy});
    reverse(path.begin(), path.end());
}
```

- `pre[x][y]` 记录的是到达 `(x,y)` 的**前驱位置**。
- 扩展新位置时写 `pre[nx][ny] = {x, y}`。
- 回溯是从终点往回走，`path` 里是逆序的，最后 `reverse` 一把得到从起点到终点的正序路径。

### 泛洪填充

> 令 `1` 表示细胞，`0` 表示空地，上下左右相邻的细胞属于同一个区域，求区域数。

等价于给定一个网格，统计其中有多少个连通区域。解法是扫描整个网格：当前位置已访问就跳过；属于某个新连通块就把答案加一，从该位置开始 BFS，把整块全部标记。这类过程称为**泛洪填充**（Flood Fill）。BFS 只是实现泛洪的一种方式，也可以使用 DFS。

```cpp
//变式见P1362(C12),P1363(C12),P1364(C12)
#include <bits/stdc++.h>
using namespace std;
int cnt=0; 
int dx[]={-1,0,1,0};
int dy[]={0,-1,0,1};
char h[700][700]; 
int n,m;
void bfs(int x,int y) {
    queue<pair<int,int>> q; 
    q.push({x,y});          
    h[x][y]='0';        
    while (!q.empty()) {
        auto t=q.front(); 
        q.pop();                 
        for (int i=0;i<4;i++) {
            int nx=t.first+dx[i];
            int ny=t.second+dy[i];
            if(nx<1||nx>n||ny<1||ny>m||h[nx][ny]=='0')continue;
                q.push({nx,ny});      
                h[nx][ny]='0';    
        }
    }
}

int main() {
    cin>>n>>m;
    for (int i=1;i<=n;i++) {
        for(int j=1;j<=m;j++){
            cin>>h[i][j];
        }
    }
    for (int i=1;i<=n;i++) {
        for (int j=1;j<=m;j++) {
            if (h[i][j]!='0') {
                cnt++;
                bfs(i,j); 
            }
        }
    }
    cout<<cnt<<endl;
    return 0;
}
```

- 泛洪用 `h[x][y]='0'` **直接涂色**标记（起点和扩展点都涂成 `'0'`），省掉一个 visited 数组；BFS 里 `h[nx][ny]=='0'` 就跳过。
- main 双层循环扫过所有格子，`h[i][j]!='0'` 说明是没被涂过的新块，`cnt++` 并从这里 `bfs` 涂整块。
- 注意 main 的判断条件与 BFS 里的涂色要一致。

如果要统计当前连通块大小，可以在 BFS 中维护计数：

```cpp
int size = 0;

while (!q.empty()) {
    auto [x, y] = q.front();
    q.pop();
    ++size;

    // 扩展相邻位置
}
```

- 在出队（每个节点恰好被处理一次）时 `++size`，循环结束时 `size` 就是这一块的大小。

### 多源 BFS

> 给定一个 $01$ 矩阵，求每个位置到最近的 `1` 的曼哈顿距离。

如果对每个 `0` 分别做一次 BFS，最坏复杂度为 $O((nm)^2)$，通常无法接受。这时可以用**多源 BFS**：将所有 `1` 同时作为起点，一起放入同一个队列，同时向外扩展，其余同正常 BFS 即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
int n,m;
int h[1010][1010],st[1010][1010];
int dx[]={1,0,-1,0},dy[]={0,1,0,-1};
queue<pair<int,int>> q;
void bfs(){
    while(q.size()){
        auto t=q.front();q.pop();
        for(int i=0;i<4;i++){
            int nx=t.first+dx[i],ny=t.second+dy[i];
            if(nx<1||nx>n||ny<1||ny>m) continue;
            if(h[nx][ny]==1||st[nx][ny]!=0) continue;
            st[nx][ny]=st[t.first][t.second]+1;
            q.push({nx,ny});
        }
    }
}
int main(){
    ios::sync_with_stdio(0);
        cin.tie(0);
        cout.tie(0);
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        string a;cin>>a;
        for(int j=0;j<a.size();j++){
            h[i][j+1]=a[j]-48;
            
        }
        
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            if(h[i][j]==1)q.push({i,j});
        }
    }
    bfs();
    for(int i=1;i<=n;i++){
            for(int j=1;j<=m;j++){
                cout<<st[i][j]<<" ";
            }
            cout<<endl;
        }
}
```

- `q` 是全局队列；main 里把所有 `h[i][j]==1` 的点**一次性全部入队**，这就是"多源"。
- BFS 里 `st` 初值为 0，遇到 `h==1`（源）或 `st!=0`（已访问）就 `continue`，`st[nx][ny]=st[t]+1`。
- 于是每个非源点只会被"最近的源"先访问到，`st` 即为它到最近 `1` 的曼哈顿距离。

### 01BFS

普通 BFS 要求每条边的代价相同。如果边的权值可能是 `0` 或 `1`，就不能简单地认为"走一步距离加一"。一些经典模型如：经过普通道路代价为 $1$；改变方向、破坏墙壁或使用传送门代价为 $0$。这时候就要用到 **01BFS**，它专门处理边权为 `0` 和 `1` 的图论 / 迷宫问题。

普通 BFS 使用队列 `queue`，只支持在末尾添加元素，实在是太拉了。01BFS 就不一样了，它的底层是**双端队列** `deque`，可以在首尾添加与删除元素，显然能实现的功能要比 BFS 强。

逻辑非常简单：`0` 边扩展没有代价，直接把它添加到**队首**立即扩展；反之 `1` 边扩展有代价，按正常 BFS 逻辑加到**队尾**。这样就在保持 BFS"第一次到时即最短距离"性质的同时处理了 `0/1` 边权，复杂度还是 $O(n)$（$n$ 为状态空间数），非常优秀。

代码也不难写，这里先只给特殊处理部分：

```cpp
if (dist[u] + w < dist[v]) {
    dist[v] = dist[u] + w;

    if (w == 0) {
        q.push_front(v);
    } else {
        q.push_back(v);
    }
}
```

- **注：** 01BFS 应在发现更短距离时进行松弛，一般不能仅使用 `visited` 判断是否处理过。
- 补充：对于存在边权为 `2` 的图也可以用 01BFS 解决，方法是将 `2` 边权拆点变成两条边权 `1` 维护。拆点的逻辑一般比较复杂，在一些复杂度限制低的题目中还不如 Dijkstra。01BFS 还是只留给 `0-1` 图比较好。

## 复杂度分析

- **图 $G=(V,E)$**：每个状态最多入队一次，每条边最多被枚举一次，时间复杂度 $O(V+E)$；队列与 `visited` / `dist` 数组共占用 $O(V)$ 空间。
- **$n \times m$ 网格**：状态数 $V=nm$，每格最多 4 条出边，等价于 $O(nm)$ 时间、$O(nm)$ 空间。
- **多源 BFS / 01BFS**：本质上仍是每个状态、每条边处理常数次，复杂度保持线性；01BFS 换成双端队列不改变渐进复杂度。

## 适用场景

- 无权图或网格图上的最短路径（每步代价为 $1$）。
- 连通块统计与泛洪填充（Flood Fill）。
- 树的层次遍历、计算每个节点的深度。
- 多源 BFS：求每个点到若干源点中最近一个的距离（如 $01$ 矩阵中每个位置到最近 `1` 的曼哈顿距离）。
- 01BFS：边权仅为 `0` 或 `1` 的最短路问题。
- 状态可枚举、单步代价为 $1$ 的隐式图搜索。

## 常见陷阱与注意事项

1. **入队时标记，而非出队时**：出队才标记会让同一节点被多个前驱重复入队，浪费时空且易产生错误结果。
2. **只有边权相同才保证最短**：普通 BFS 要求每步代价相同；一旦边权不等，就不能再用"第一次到达即最短"，应改用 Dijkstra 或 SPFA。
3. **多源 BFS 要同时入队**：必须把所有源点以 `dist = 0` 一起入队再统一扩展；若对每个源点单独跑一遍 BFS，复杂度会退化。
4. **01BFS 按松弛而非仅访问判断**：应写成"发现更短距离就更新"，不能只用一个 `visited` 布尔值判断是否处理过；`0` 边入队首、`1` 边入队尾。
5. **网格注意越界与障碍**：方向数组要成对、正确，扩展前先判断边界和障碍。
6. **记录路径需前驱数组**：用 `pre` 记录"从哪来"，结束后从终点回溯到起点再反转。
7. **起点坐标的 0 基 / 1 基换算**：迷宫模板里读入后统一 `+1`，接线时别漏，否则会错位。

## 对比与扩展

| 算法 | 适用 | 时间复杂度 | 特点 |
|---|---|---|---|
| 单向 BFS | 无权图 / 网格最短路 | $O(V+E)$ | 按层扩展，第一次到达即最短 |
| DFS | 连通性、排列枚举、回溯 | $O(V+E)$ | 一条路走到底，不保证最短路 |
| Dijkstra | 非负权图最短路 | $O((V+E)\log V)$ | 优先队列贪心松弛 |
| 双向 BFS | 无权图且起终点已知 | $O(V+E)$ | 两端同时扩展，常数更优 |
| 01BFS | 边权仅为 $0/1$ | $O(V+E)$ | 双端队列：$0$ 边队首、$1$ 边队尾 |
| 多源 BFS | 多个源点的最短路 | $O(V+E)$ | 所有源点同时入队 |

扩展方向：

- **双向 BFS**：起点与终点同时向外扩展，两个搜索前沿相遇即得到答案。
- **01BFS 到边权 $2$**：可将边权 $2$ 拆成两条边权 $1$ 的边来维护，但拆点逻辑较复杂，在复杂度限制宽松的题目中往往不如 Dijkstra。
- **A\* 搜索**：在 BFS 基础上引入启发函数（如曼哈顿距离），优先扩展更接近目标的状态，适合大规模网格。
- **层次遍历的延伸**：BFS 按层访问的性质，也是 Dinic 分层图构建、AC 自动机按 fail 指针按层构建等算法的底层工具。

一句话总结：BFS 的核心是"用队列按距离由近到远逐层扩展"，边权相同时第一次到达即最短；配合多源与 01BFS 两种变形，能覆盖一大类无权 / 小边权最短路问题。
