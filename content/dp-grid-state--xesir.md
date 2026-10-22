---
id: dp-grid-state
title: '棋盘状压 DP（炮兵阵地 + 互不侵犯 · Xesir 版）'
category: 动态规划
subcategory: 状态压缩DP
subSubcategory: ''
tags: ["动态规划", "状态压缩", "棋盘状压DP", "炮兵阵地", "互不侵犯"]
timeComplexity: 'O(N·S³)（炮兵阵地）/ O(N·2^N·2^N·K)（互不侵犯）'
spaceComplexity: 'O(2^M·2^M)（炮兵阵地）/ O(N·2^N·K)（互不侵犯）'
level: A
codePath: '动态规划\棋盘状压DP\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

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
- 扩展：用滚动数组降空间；把合法状态编号压缩到 $S$ 维减少无效枚举；更复杂的棋盘覆盖（连通性约束）可引入轮廓线 DP（插头 DP）逐格推进。
