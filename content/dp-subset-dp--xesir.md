---
id: dp-subset-dp
title: '子集 DP（子集枚举 · 分组过桥 · 子集最值维护 · Xesir 版）'
category: 动态规划
subcategory: 状态压缩DP
subSubcategory: ''
tags: ["动态规划", "状态压缩", "子集DP", "子集枚举", "高维前缀和"]
timeComplexity: 'O(3^n)（分组）/ O(n·2^n)（子集最值维护）'
spaceComplexity: 'O(2^n)'
level: A
codePath: '动态规划\子集DP\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

子集 DP 是状压 DP 的经典分支，专门处理那些需要**枚举子集**来转移的问题：对于当前状态 `S`，考虑它的所有非空真子集 `T`，再按 `T` 与 `S\T`（即 `S ^ T`）的关系转移。

枚举子集的「骚操作」是这样写的：

```cpp
for(int i=0;i<n;i++){
    for(int sta=(1<<n)-1;sta>=0;sta--){
        if(sta&(1<<i)) //转移
    }
}
```

它把每个 mask 拆成「不含第 $i$ 位」和「含第 $i$ 位」两类版本，等价于把子集的信息逐位向上传递。这个循环的总复杂度是 $O(3^n)$（每个元素有三种归属：不在 `sta` 里 / 在 `sta` 里但不在 `sub` 里 / 在 `sub` 里），$n \le 16$ 完全够用。

本文从源码里收录两个典型方向：

- **分组 DP**：枚举「最后一组」，把大问题 `mask` 拆成子问题 `mask ^ sub`。
- **子集信息合并**：像高维前缀和一样，把「所有子集」的信息逐位向上合并。

## 核心公式 / 状态定义与转移方程

### 分组过桥（以 2026WCA1009 分组过桥 为例）

桥有最大承重 $W$，$n$ 个人各有重量 $w_i$ 与过桥时间 $t_i$。每次只能让一个子集（一组）一起过桥，时间取该组中最慢的 $t_i$，且该组总重量不超过 $W$，求所有人过桥的最少总时间。

- 状态：`dp[mask]` 表示让 `mask` 里所有人过桥所需的最少时间，答案是 `dp[(1<<n)-1]`。
- 预处理：对每个子集 `mask` 预先算出总重量 `totW[mask]` 与最慢时间 `maxT[mask]`，这样可以 $O(1)$ 判断合法性并拿到「一次性过桥代价」。
- 转移：考虑最后一组为 `sub`，之前过桥的人是 `mask ^ sub`：

$$dp[\text{mask}] = \min_{\substack{sub \subseteq \text{mask},\ sub \neq \emptyset \\ totW[sub] \le W}} \Big(dp[\text{mask} \oplus sub] + maxT[sub]\Big)$$

代码里还有一种等价写法：枚举当前状态 `i`，枚举其子集 `j`，转移为 `dp[i] = min(dp[i], dp[i^j] + t[j])`，本质一样。

### 子集最大值维护（以 2026WCA1012 Or Plus Max 为例）

给定 $2^n$ 个数 $a_0, \dots, a_{2^n-1}$。对每个 $k$（$1 \le k < 2^n$），求满足 $(i \mid j) \le k$ 且 $i \ne j$ 的最大 $a_i + a_j$。

- **关键转化**：$(i \mid j) \le k$ 等价于 $i \subseteq k$ 且 $j \subseteq k$。所以对每个 $k$，只要知道「所有 $k$ 的子集下标」对应 $a$ 值中最大的两个（因为 $i \ne j$），相加就是答案。
- **状态维护**：`f[mask]` 是一个二元组 `(max1, max2)`，表示在所有 `sub ⊆ mask` 的下标中 $a_{sub}$ 的最大值与次大值。初始化 `f[i] = (a[i], -INF)`。
- **转移**（类似高维前缀和）：枚举每一位 `bit`，对所有包含该位的 `mask`，用 `mask ^ (1<<bit)` 的信息去更新 `mask`，即 `f[mask] = merge(f[mask], f[mask ^ (1<<bit)]);`，`merge` 负责保留两个最大的数。经过 $n$ 轮后，`f[mask]` 就含所有子集的最大与次大。
- **答案处理**：每个 $k$ 的 `f[k].max1 + f[k].max2` 即为该 $k$ 的最优值；由于答案随 $k$ 单调不减，用一个变量记录当前最大值依次输出即可。

## 逐行代码解析

### 分组过桥 · 头文件、宏与读入预处理

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
const int INF=INT_MAX;
//int cnt=0;
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int W,n;cin>>W>>n;
    vector<int> t(1<<n,0),w(1<<n,0),dp(1<<n,INF);
    for(int i=0;i<n;i++){
        int a,b;cin>>a>>b;
        for(int j=0;j<(1<<n);j++){
            if(j&(1<<i)){
                t[j]=max(t[j],a);
                w[j]+=b;
            }
        }
    }
}
```

- `#define int long long` 把整型扩到 64 位，配合 `signed main()` 使用。
- `t[j]`、`w[j]` 即 `maxT`、`totW`，`dp` 初值 `INF=INT_MAX`；三个 `vector` 都开到 `1<<n`。
- 读入每人 `(时间 a, 重量 b)` 后，遍历所有含第 $i$ 位的子集：`t[j]` 取最慢时间、`w[j]` 累加重量。这一步把 $O(n \cdot 2^n)$ 的预处理一次性做完。

### 分组过桥 · 子集枚举转移与快读快写

```cpp
    for(int i;i<(1<<n);i++){
        if(w[i]<=W) dp[i]=t[i];
        for(int j=i;j;j=i&(j-1)){
            if(w[i^j]<=W) dp[i]=min(dp[i],dp[j]+t[i^j]);
        }
    }
    cout<<dp[(1<<n)-1]<<'\n';
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

- `if(w[i]<=W) dp[i]=t[i]`：整个 `i` 作为一组一次过桥的代价。
- `for(int j=i;j;j=i&(j-1))` 是**枚举 `i` 的所有非空子集**的标准写法（`j` 从 `i` 递减，`j = i & (j-1)` 一直取到最小的非空子集，不会到 0）。
- `dp[i]=min(dp[i],dp[j]+t[i^j])`：把 `i` 拆成 `j` 和 `i^j` 两组，其中 `i^j` 是最后过桥的那组，需满足承重 `w[i^j]<=W`。
- `cout<<dp[(1<<n)-1]` 输出全员过桥的最小总时间；底部 `read` / `write` 是模板，本程序未调用。

### Or Plus Max · 头文件与全局

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
const int N=1<<19,INF=INT_MAX;
//int cnt=0;
int a[N];
PII f[N];
inline int read();
inline void write(int x);
PII mxp(PII a,PII b){
    if(a.fi<b.fi) swap(a,b);
    if(a.se<b.fi) a.se=b.fi;
    return a;
}
```

- `N=1<<19` 给足 $n \le 18$ 的空间（$1<<18 = 262144 < 524288$）；`a[i]` 存原数组，`f[i]` 存二元组 `(max1, max2)`。
- `mxp` 是合并函数：先把「首元素较大」的二元组放到 `a`，再用 `b` 的最大值去尝试更新 `a` 的次大值，返回合并后的结果。

### Or Plus Max · main 与答案统计

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n;cin>>n;
    for(int i=0;i<(1<<n);i++){
        cin>>a[i];
        f[i]={a[i],-INF};
    }
    for(int i=0;i<n;i++){
        for(int sta=(1<<n)-1;sta>=0;sta--){
            if(sta&(1<<i)) f[sta]=mxp(f[sta],f[sta^(1<<i)]);
        }
    }
    int ans=0;
    for(int i=1;i<(1<<n);i++){
        ans=max(f[i].fi+f[i].se,ans);
        cout<<ans<<'\n';
    }
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

- 初始化 `f[i] = {a[i], -INF}`：单个下标的「最大值」是自己，「次大值」用 `-INF` 占位（表示还没有第二个数）。
- 双层循环就是高维前缀和写法：枚举每一位 `i`，对所有含该位的 `sta`，用 `sta ^ (1<<i)` 合并进 `sta`。$n$ 轮后每个 `f[sta]` 都统计完 `sta` 的所有子集。
- 输出时 `ans = max(f[i].fi + f[i].se, ans)` 再 `cout<<ans`：因为答案随 $k$ 单调不减，用滚动最大值输出。
- 底部 `read` / `write` 同样未被调用。

## 复杂度分析

**分组过桥**：

- 预处理每个子集的 `t`、`w`：$O(n \cdot 2^n)$。
- 子集枚举转移：每个 mask 枚举其子集，总计 $O(3^n)$。$n \le 16$ 轻松过。
- 空间：三个长度 `1<<n` 的数组，$O(2^n)$。

**Or Plus Max**：

- 高维前缀和式合并：外层 $n$ 位、内层 $2^n$ 个状态，$O(n \cdot 2^n)$。$n \le 18$ 完美。
- 空间：`a[N]` 与 `f[N]` 各 $O(2^n)$（此处按 $2^{19}$ 静态开满）。

## 适用场景

- 需要枚举子集做转移的集合划分问题（划分子集、分组覆盖、安排一批批完成的任务）。
- 子集信息合并 / 高维前缀和类问题（子集最值、子集计数、SOS DP）。
- 数据范围通常在 $n \le 16 \sim 20$。

## 常见陷阱与注意事项

1. **源程序里 `i` 没有初始化**：分组过桥的转移写成 `for(int i;i<(1<<n);i++)`，`i` **未初始化**即参与比较，属未定义行为（编译器可能给出随机初值）。源码如此，**照搬保留**；正确写法应是 `for(int i=0; i<(1<<n); i++)` 或先 `int i=0;`。
2. **枚举子集的起止**：`for(int j=i;j;j=i&(j-1))` 从 `i` 开始、条件为 `j` 非零，枚举的是 `i` 的**所有非空子集**；若需要包含空集，要另外处理。
3. **`INF` 取 `INT_MAX` 的加减**：转移里 `dp[j]+t[i^j]` 在 `dp[j]` 仍为 `INF` 时可能发生大数相加；因 `#define int long long` 把 `dp` 元素变成 64 位，实际不会溢出，但换回 32 位 `int` 就要小心。
4. **`-INF` 作次大值占位**：`f[i]={a[i],-INF}` 中 `-INF` 表示「暂时没有第二个数」；若改用 `INT_MIN`，相加时更容易出现异常值，选 `-INF` 更稳。
5. **答案要滚动取最大**：Or Plus Max 的答案随 $k$ 单调不减，必须输出 `ans`（历史最大），不能直接输出 `f[i].fi+f[i].se`。
6. **下标从 0 计**：`i \mid j \le k` 转成 `i ⊆ k` 时，位与下标一一对应，注意别把 0 号位搞错。
7. **静态开满内存**：`N=1<<19` 的数组按 `long long` 开大约是数 MB，$n$ 再大就要动态按 `1<<n` 开。

## 对比与扩展

- 与 TSP 状压对比：TSP 转移是「在 mask 上加一个还没访问的点」，子集 DP 的转移是「把 mask 拆成两个子集」，后者要枚举子集，故复杂度常为 $O(3^n)$。
- 与普通状压对比：分组过桥是「枚举子集」这一支，Or Plus Max 是「子集信息合并（高维前缀和）」这一支。
- 扩展：SOS DP（Sum over Subsets）就是 Or Plus Max 的一般化，把「两元组」换成计数 / 求和 / 最值即可；子集枚举还常用于容斥与集合幂级数。
