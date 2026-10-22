---
id: dp-group-bag
title: '分组背包'
category: 动态规划
subcategory: 背包问题
subSubcategory: 分组背包
tags: ["动态规划", "背包问题", "分组背包", "DP"]
timeComplexity: 'O(V × 总物品数)'
spaceComplexity: 'O(V)'
level: A
codePath: '动态规划\背包问题模板\分组背包\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

物品分成若干组，每组内只能选一个（或者不选）。详见云兰阁 P1215(C9)。

**状态转移**：分组背包本质是 01 背包的变种，只不过决策对象从「单个物品」变成了「组内选哪个」。

设 `f[j]` 表示容量 `j` 时的最大价值。遍历每一组，对于组内每个物品都尝试更新 `f`，但要保证**同一组内只选一个**，所以容量的枚举必须放在物品循环外面，即：

```cpp
for (int k = 1; k <= 组数; k++) {          // 遍历每组
    for (int j = V; j >= 0; j--) {         // 容量倒序（类似01背包）
        for (int each : 组k的物品) {
            if (j >= w[each])
                f[j] = max(f[j], f[j - w[each]] + v[each]);
        }
    }
}
```

**为什么容量循环要在外面？** 因为如果容量循环在物品循环里面，会导致同组多个物品被选（相当于从同一个组里选多个）。把容量放在外层，保证了每个状态 `f[j]` 只考虑本组的一个物品来更新，不会出现「选了两个同组物品」的情况。

## 核心公式 / 状态定义与转移方程

$$
f[j] = \max_{i \in \text{组 } k}\big(f[j],\ f[j - w_i] + v_i\big), \quad j \ge w_i
$$

即对第 $k$ 组，用组内每个物品分别试一次更新 `f[j]`，且 `j` 倒序保证本组只放一个。

## 逐行代码解析

### 头文件与全局容器

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
vector<pair<int,int>> a[1010];
vector<int> f(1010);
```

- `a[i]` 是一个 `vector`，装第 $i$ **组**里的所有物品（每个是 `{重量, 价值}`）。
- `#define int long long` 把全局 `int` 换成 `long long`，所以 `main` 要写成 `signed main()`。
- `f` 是一维 DP，`vector` 初始化大小为 1010。

### main 框架与读入建组

```cpp
signed main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        int s;cin>>s;
        for(int j=1;j<=s;j++){
            int c,d;cin>>c>>d;
            a[i].push_back({c,d});
        }
    }
```

- `n` 是组数，`v` 是容量。
- 每组先读组内物品数 `s`，再读 `s` 个 `{重量 c, 价值 d}` 压进 `a[i]`。
- 组编号从 1 开始，`a[0]` 空着不用。

### 三重循环转移与输出

```cpp
    for(int i=1;i<=n;i++){
        for(int j=v;j>=1;j--){
            for(int k=0;k<a[i].size();k++){
                if(j-a[i][k].first>=0)f[j]=max(f[j],f[j-a[i][k].first]+a[i][k].second);
            }
        }
    }
    cout<<f[v];
    return 0;
}
```

- 外层 `i` 遍历组、中层 `j` 遍历容量**倒序**、内层 `k` 遍历组内物品——正是「容量在外、物品在内」的写法。
- `j-a[i][k].first >= 0` 即容量够放下才转移，等价于伪码里的 `j >= w[each]`。
- 答案 `f[v]`。

## 复杂度分析

- **时间复杂度**：$O(V \times \text{总物品数})$。外层每组一次，中层容量 $V$ 次，内层扫该组物品；所有组内物品数加起来就是总物品数。
- **空间复杂度**：$O(V)$ 的 DP 数组，外加 `a` 存所有物品 $O(\text{总物品数})$。

## 适用场景

物品被预先分组、每组至多取一件的背包题，如「每组只能买一样」的方案选择。按组读入、组内互斥枚举即可。

## 常见陷阱与注意事项

1. **容量循环位置**：必须在物品循环**外面**；一旦反过来（先枚举物品再枚举容量），同组会被选多个。
2. **容量倒序**：`j` 从 `v` 递减到 1，保证本组只放一个，和 01 背包同理。
3. **`j=0` 没遍历**：循环写到 `j>=1`，容量为 0 的状态不必更新。
4. **`k` 与 `size()` 的比较**：`k` 是 `int`、`a[i].size()` 是 `unsigned`，会触发符号比较警告，能用但不严谨。
5. **`signed main`**：开了 `#define int long long`，入口必须写 `signed main()`。
6. **数组大小**：`f` 与组数上界 1010，超出要改。

## 对比与扩展

与 01 背包的关系：01 背包每个物品独立决策，分组背包是「组内先选出最优的那一个，再当作一个决策」。可推广为**每组至少选一个 / 恰好选 $t$ 个**的变体，做法是在组内枚举选几个再统一转移。
