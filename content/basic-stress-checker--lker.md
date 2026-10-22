---
id: basic-stress-checker
title: '对拍（SPJ 与构造题 checker）'
category: 基础算法
subcategory: 对拍
subSubcategory: ''
tags: ["对拍", "SPJ", "checker", "构造题", "合法性检验"]
timeComplexity: '视 checker 内部检验方式'
spaceComplexity: '视 checker 内部实现'
level: A
codePath: '基础算法\对拍\构造题Checker\checker--lker.cpp'
verified: 2026-10-20
source: 'lker'
---

## 算法原理

有 SPJ 的题目在对拍时不能使用 `system` 语句直接比较，而需要手动编写一个 checker。对于只要求输出满足某些约束的情况，我们不再需要 `bf.cpp` 文件，只需要对输出进行一次合法性检查即可。

对于构造类型的题目，检验分两层：

- **合法性检验**：判断输出是否满足题目对输出方案的约束；
- **最优性检验**：判断得到的方案是否为最优解。最优性可以通过深搜完成，也可以通过理论分析得到答案的上界。

~~不过题目是不是一般会给你一个写好的 checker 来着。~~

以 [P8468 文文的构造游戏](https://www.luogu.com.cn/problem/P8468) 为例。核心思路是：如果程序判断存在方案，就按照题意检查一遍它给出的构造；如果程序判断不存在方案（输出 `-1`），就用深搜枚举，确认是不是真的不存在。

需要注意的是，深搜可能会超时，所以 `data.cpp` 不要生成过大的数据。

### 检验流程

1. 跑 `data` 生成数据，跑 `mine` 得到输出；
2. 先把 `data.out` 读回来，记下每个询问的 $(s,m)$；
3. 再把 `mine.out` 读回来，逐组核对；
4. 输出 `-1` 的组用 `ex(s,m)` 深搜验证确实无解；输出方案 `a` 的组用 `ck(s,m,n,a)` 验证「个数在范围内、每个数不超过 $s$、和为 $s$、异或和为 $0$」。

## 逐行代码解析

### 深搜判定：到底存不存在合法方案

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
bool dfs(int s,int d,int n,int sm,int xr)
{
    if(d==n)return sm==s&&xr==0;
    for(int x=1;x<=s;x++)
        if(dfs(s,d+1,n,sm+x,xr^x))
            return true;
    return false;
}
bool ex(int s,int m)
{
    for(int n=1;n<=m;n++)
        if(dfs(s,0,n,0,0))
            return true;
    return false;
}
```

- `dfs(s,d,n,sm,xr)` 表示「已经选了 $d$ 个数、当前和为 `sm`、异或和为 `xr`，还要再选到 $n$ 个」，返回是否能补完。
- 递归出口 `d==n` 时同时检查**和等于 $s$** 与**异或和为 $0$**，这正是题目要求的两个条件。
- `for(int x=1;x<=s;x++)` 枚举下一个数的取值：每个数必须在 $[1,s]$ 内，否则不合法。
- `ex(s,m)` 枚举可能的个数 $n\in[1,m]$，任意一个能构造出来就说明存在方案。

### 合法性检验：检查程序给出的构造

```cpp
bool ck(int s,int m,int n,vector<int>&a)
{
    if(n<1||n>m)return false;
    int sm=0,xr=0;
    for(int x:a){
        if(x<1||x>s)return false;
        sm+=x;
        xr^=x;
    }
    return sm==s&&xr==0;
}
```

- 先卡个数 $n\in[1,m]$，再逐个卡每个数 $x\in[1,s]$，越界直接判错。
- 边累加边异或，最后统一比较，等价于前面深搜的两个终止条件。
- 注意这里只验**合法性**，不验最优性——本题是构造题，只要方案合法即可。

### 主循环：读回两份文件并逐组核对

```cpp
signed main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./mine");
        freopen("data.out","r",stdin);
        int T;cin>>T;
        vector<pair<int,int>> qs(T);
        for(int i=0;i<T;i++)cin>>qs[i].first>>qs[i].second;
        cin.clear();
        freopen("mine.out","r",stdin);
        bool ok=true;
        for(int i=0;i<T;i++){
            int s=qs[i].first,m=qs[i].second;
            int n;cin>>n;cin.clear();
            if(n==-1){
                if(ex(s,m)){ok=false;break;}
            }else{
                vector<int>a(n);
                for(int j=0;j<n;j++)cin>>a[j],cin.clear();
                if(!ck(s,m,n,a)){ok=false;break;}
            }
        }
        if(!ok){cout<<"WA/RE/MLE on test "<<++ti<<"\n";break;}
        cout<<"AC on test "<<++ti<<"\n";
        if(ti==10)break;
    }
    return 0;
}
```

- 这里**只需要 `data` 和 `mine`**：SPJ 题的正确性由 checker 自己判定，不需要 `bf.cpp`。
- 先读 `data.out` 存下所有询问，再读 `mine.out` 对照——顺序不能反，读完一边要 `cin.clear()` 才能切到另一边。
- 输出 `-1` 时调 `ex(s,m)`：如果深搜发现其实存在方案，说明程序答错了；否则这组算过。
- 输出方案时调 `ck`：任何一个数越界、和不对、异或和不为 0 都判错。
- `signed main` 配合前面的 `#define int long long`，避免深搜里的和溢出。
- 出错即 `break`，保住当轮的 `data.out` 与 `mine.out` 供复现。

## 复杂度分析

checker 本身的开销取决于检验方式：`ck` 是 $O(n)$；`ex` 的深搜最坏要枚举 $s^n$ 种方案，是指数级的，所以 `data.cpp` 必须把 $s$ 和 $m$ 压小，否则还没等 checker 判完就先超时了。

## 适用场景

- 输出任意合法方案的构造题、多解题。
- 带 SPJ 的题目（题目给 checker 时直接用，不给时自己写一份）。
- 需要验证「输出格式本身是否合规」的场景，例如个数、取值范围、是否重复。

## 常见陷阱

- **深搜爆炸**：`ex` 是指数级，数据造大了必然 TLE，表现为「控制器一直不结束」。要把 `data.cpp` 的规模限制在深搜能跑完的量级。
- **只验合法、忘了验最优**：如果题目要求最优解，`ck` 里必须再比较一次答案大小，或者用理论上界判断；否则「输出一个合法但很差的方案」也会被判 AC。
- **`cin.clear()` 漏写**：切换 `freopen` 后读入失败，后面的判定全建立在垃圾值上。
- **`-1` 的语义没对齐**：要确认题目规定的「无解输出」到底是 `-1` 还是 `No solution`，写错会把正确答案判成 WA。
- **多测题忘记清空**：`ok`、临时 `vector` 每轮都要重新初始化，不能跨组复用。

## 对比与扩展

- 与「浮点误差对拍」的区别：那边比数值接近程度，这边比方案是否合法。
- 如果题目附带官方 checker，优先用官方的；自己重写容易漏掉题面里的隐藏约束。
- 构造题还可以反过来用：写一个随机构造程序，让 checker 帮你筛掉不合法的生成策略。
