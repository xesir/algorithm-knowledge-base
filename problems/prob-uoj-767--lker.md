---
id: prob-uoj-767
title: 'UOJ #767 【NOI2022】挑战 NPC Ⅱ'
oj: 'UOJ'
problemId: '767'
difficulty: '其他'
category: 图论
tags: ["树哈希", "树同构", "搜索", "剪枝", "记忆化"]
timeComplexity: 'O(n log n)'
spaceComplexity: 'O(n log n)'
codePath: '题目专辑\图论\挑战NPC2\代码--lker.cpp'
level: A
verified: 2026-10-20
source: 'lker'
---

## 题目描述

原文未附题面，以下题意根据作者思路整理。

给定两棵有根树 $G,H$，满足 $|H|\le |G|\le |H|+k$，其中 $k$ 是小常数。只允许删除 $G$ 中的若干个点，问能否删出一个与 $H$ 同构的子树。

### 输入格式

原文未给出。

### 输出格式

原文未给出。

### 数据范围

原文只给出 $k\le 5$，其余未给出。

## 样例

原文未附样例。原题链接：[UOJ #767 【NOI2022】挑战 NPC Ⅱ](https://uoj.ac/problem/767)。

## 解题思路

注意到 $k$ 不超过 $5$，所以考虑**搜索 + 剪枝 + 记忆化**。

先想暴力搜索怎么做。对于当前尝试匹配的两棵子树 $G'$ 和 $H'$，我们可以把所有同构的子树贪心地放在一起匹配起来，这样就避免了大规模的匹配。又因为 $k\le 5$，对 $G'$ 和 $H'$ 来说不匹配的子树数量一定分别不超过 $5$——至少是一个子树删一个点。

对剩下的若干子树，因为我们只能删除 $G'$ 里的点：

- 如果 $G'$ 里不能匹配的子树数量大于 $H'$ 里不能匹配的子树数量，就删去这些多余的子树；
- 同时枚举两边不能匹配的子树的「通过删除达到匹配」的方案，递归验证。

为了做到这两件事，用 `next_permutation` 求 $G'$ 不能匹配的所有子树的全排列，就得到了所有匹配方案；再把最后超出 $H'$ 不能匹配子树数量的那一段后缀子树全部删去，记下删去子树的代价，然后一一枚举匹配、递归子树。

匹配时如果对每一对子树都枚举「删多少点」，还是暴力的。注意到**前面的子树删得越少，留给后面的限制就越松**，所以对每一对子树从删一个点开始枚举递归，直到这两个子树能得到一个删除代价 $need$ 使得它们同构，把 $need$ 计入总代价，再处理下一对。这样就是一个完整的递归求解过程。

首要难点是如何快速判定同构子树有哪些——自然想到树哈希。把所有子树的哈希值排序，然后用两个指针在两边扫一遍，因为有单调性，可以 $O(n)$ 求出两边无法匹配的子树集合。

然后是复杂度问题：把「以 $u,v$ 为根的子树，在删除 $p$ 个点的限制下能否同构」做成记忆化。数组存不下，把这三个元素做一个集合哈希映射，用 `unordered_map` 存。

最后加剪枝：

- 当两边子树大小差超过 $k$ 时，显然不满足约束，直接 `false`；
- 当 $G'$ 的不匹配子树数量大于 $k$ 时，每个不匹配子树至少要删一个点，所以不可能做到，也直接 `false`。

## 逐行代码解析

下面把搜索函数拆成三段，三段按顺序拼起来就是完整的 `.cpp`。

### 记忆化与入口剪枝

```cpp
bool dfs(int u,int v,int k)
{
    ull key=get_key(u,v,k);
    auto it=memo.find(key);
    if(it!=memo.end())
        return it->second;
    if(sz_f[u]<sz_g[v]) 
        return false;
    if(sz_f[u]-sz_g[v]>k)
        return false;
    int posl=0,posr=0;
    vector<int> fail_u;
    vector<int> fail_v;  
```

- 参数 `k` 是「当前这一层允许再删多少个点」的剩余额度，不是题目里那个全局常数。
- `get_key(u,v,k)` 把三元组压成一个哈希键，配合 `memo` 做记忆化——这一步是整个算法能从指数级降到可接受的关键。
- `sz_f[u]<sz_g[v]` 先排掉「$G$ 这边比 $H$ 还小」的情况：只能删点，不能加点。
- `sz_f[u]-sz_g[v]>k` 就是「大小差超过 $k$ 直接 false」这条剪枝。
- `fail_u`、`fail_v` 分别收集两边还没配上的儿子。

### 双指针扫出无法匹配的子树

```cpp
    while(posl<f[u].size()&&posr<g[v].size())
    {
        if(f[u][posl].val==g[v][posr].val)       
        {
            posl++;
            posr++;
        }else if(f[u][posl].val<g[v][posr].val){
            fail_u.push_back(f[u][posl].id);
            posl++;
        }else {
            fail_v.push_back(g[v][posr].id);
            posr++;            
        }
    }
    while(posl<f[u].size())
    {
        fail_u.push_back(f[u][posl].id);
        posl++;        
    }
    while(posr<g[v].size())
    {
        fail_v.push_back(g[v][posr].id);
        posr++;        
    }
    if(fail_u.size()<fail_v.size())
        return false;
    if(fail_u.size()>k) return false;
    sort(fail_u.begin(),fail_u.end());
```

- 两个儿子列表都按哈希值排好序，所以可以双指针线性归并：相等的一对直接跳过（已经同构），小的那一侧记入「失败集合」。
- 两个 `while` 收尾处理一边扫完的情况。
- `fail_u.size()<fail_v.size()`：$G'$ 这边连子树个数都不够，删点只会更少，直接 `false`。
- `fail_u.size()>k`：每个多余子树至少要删一个点，超过额度就不可能。
- `sort(fail_u...)` 是为了下面 `next_permutation` 能枚举出全排列。

### 枚举匹配方案并递归

```cpp
    do{
        int used=0;
        bool ok=true;
        for(int i=fail_v.size();i<fail_u.size();i++)
            used+=sz_f[fail_u[i]];
        if(k<used) continue;
        for(int i=0;i<fail_v.size();i++)
        {
            int gu=fail_u[i];
            int gv=fail_v[i];
            int need=1;
            while(need<=k-used&&!dfs(gu,gv,need))
                need++;
            if(need>k-used){
                ok=false;
                break;
            }
            used+=need;
        }
        if(ok&&used<=k)
        {
            memo[key]=true;
            return true;
        } 
    }while(next_permutation(fail_u.begin(),fail_u.end()));
    memo[key]=false;
    return false;
}
```

- `for(int i=fail_v.size();i<fail_u.size();i++) used+=sz_f[fail_u[i]]`：多出来的那些子树只能整棵删掉，代价是它们的大小之和。
- `next_permutation` 把 `fail_u` 的每一种排列都试一遍，对应「哪种配对方式」。
- 内层从 `need=1` 开始试，找到最小可行删除数就停——这就是「删得越少留给后面越松」的贪心。
- 全部配对成功就记 `memo[key]=true` 并返回；所有排列都失败则记 `false`。
- 注意 `memo` 只记录「能否成功」，不记录具体方案。

## 复杂度分析

哈希与排序部分是 $O(n\log n)$；搜索主体建立在「$k\le 5$」之上，失败的子树个数不超过 $5$，排列数是常数级的 $5!$，每对子树最多试 $k$ 次删除额度，所以关于 $k$ 的部分是常数级。记忆化保证每个 $(u,v,k)$ 状态只算一次，整体可以通过。

## 常见陷阱与注意事项

- **`used` 初值**：多余子树必须整棵删掉，代价要**先**扣掉，再进入配对循环，否则额度会算多。
- **`need` 从 1 开始而不是 0**：两个不同的子树至少要删一个点才可能同构，从 0 开始会死循环。
- **记忆化键漏了 `k`**：只把 $(u,v)$ 当键会把「删 $1$ 个点可行」和「删 $3$ 个点可行」混为一谈。
- **`fail_u` 没排序就 `next_permutation`**：不排序只能枚举出「从当前排列开始的部分排列」，会漏方案。
- **递归深度**：树可能很深，链状数据要注意爆栈。
- **卡常**：原文提到这份写法能过 QOJ 与洛谷，但 UOJ 上会被卡，需要加快读。

## 对比与扩展

- 与「UOJ #763 树哈希」的关系：那题只判定同构，本题要判定「删点后同构」，所以哈希只是加速匹配的工具，主体是搜索。
- 与「P5043 树同构」的关系：那题是无根树的同构判定，本题是有根树 + 删除操作，约束更强。
- 若 $k$ 变大（比如 $k\le 20$），这套「全排列 + 逐对枚举删点数」就会爆掉，需要换成树上 DP 或更精细的匹配算法。
