---
id: basic-greedy
title: '贪心（一般模型与区间问题）'
category: 基础算法
subcategory: 贪心
subSubcategory: ''
tags: ["贪心", "区间问题", "反悔贪心", "交换论证", "排序"]
timeComplexity: 'O(n log n)（主要瓶颈在排序 / 堆）'
spaceComplexity: 'O(n)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

贪心大概是算法世界里**最符合人类直觉**的做法：每一步都挑当前看起来最优的那个，指望这些局部最优拼出全局最优。你去水果店想用 20 块钱买到最多的苹果，多半直接拿单价最便宜的那种，而不会先拿贵的再换——这就是贪心。

它的代码往往极好写，复杂度也接近线性，思维上非常直观。但**贪心并不总是对的**：只有证明了正确性的贪心才可以放心使用，否则就是在赌命。常见的证明套路有两类：

- **交换论证 / 邻项交换**：先假设存在一个最优解，若它和贪心选择不一致，就把两者交换，证明答案不会变差。反复交换，就能把最优解「改造」成贪心解。排队打水、合并果子都用它。
- **贪心选择性质（反证 + 归纳）**：证明「当前这一步最优的选择，一定存在于某个最优解中」，再把已覆盖的部分去掉，对剩下的子问题归纳。

**什么时候该想贪心？** 题目要最优化（最小 / 最大），且决策之间没有难以消除的后效性——即当前怎么选，不会影响后续还能怎么选；即便有影响，也能被排序或交换「抹平」。如果后效性消不掉，通常就得转向反悔贪心或 DP。

## 核心公式 / 状态定义与转移方程

**排队打水**：设排队顺序为 $p_1, p_2, \dots, p_n$，第 $p_j$ 个人的等待时间是前面所有人打水时间之和 $\sum_{k=1}^{j-1} t_{p_k}$，于是总等待时间为

$$
T = \sum_{j=1}^{n} \sum_{k=1}^{j-1} t_{p_k} = \sum_{k=1}^{n} (n - k)\, t_{p_k}
$$

系数 $(n-k)$ 随排名递减，所以**打水快的人要排前面**，按 $t_i$ 升序即得最优。

**货仓选址**：目标 $f(x) = \sum_{i=1}^{n} |x - x_i|$ 是凸函数，「斜率」为（左侧点数）$-$（右侧点数）。它从 $-n$ 单调增到 $n$，斜率由负变正的位置就是**中位数**：$n$ 为奇数取 $x_{(n+1)/2}$，偶数取 $x_{n/2}$ 或 $x_{n/2+1}$ 均可。

## 逐行代码解析

下面把源笔记里的几个经典模型按模块拆开，每块给出对应的代码与要点。

### 合并果子（小根堆维护最小的两堆）

> 有 $n$ 堆果子，每堆 $a_i$ 个。每次合并任意两堆，消耗为两堆之和。求合并成一堆的最小总体力。

每次取当前**最小的两堆**合并，把小根堆顶弹出两个、求和累加、再压回，重复 $n-1$ 次。

```cpp
#include <bits/stdc++.h>
using namespace std;
priority_queue<int,vector<int>,greater<int>> fruit;
int main(){
    int n,ans=0;cin>>n;
    for(int i=1;i<=n;i++){
        int x;cin>>x;fruit.push(x);
    }
    while(fruit.size()>1){
        int a=fruit.top();fruit.pop();
        int b=fruit.top();fruit.pop();
        ans+=a+b;fruit.push(a+b);
    }
    cout<<ans;
}
```

- 本质是**哈夫曼树**：合并过程对应一棵二叉树，总消耗等于所有非叶结点权值和，带权路径长度最小。
- 正确性由交换论证保证：设 $a \le b \le c$，把 $a,b$ 放到最底层互为兄弟、和最小的两堆先合并，总消耗不会变差。
- `while (fruit.size() > 1)` 循环 $n-1$ 轮，每轮两次 `pop`、一次 `push`，复杂度 $O(n \log n)$。

### 排队打水（按耗时升序）

> $n$ 个人同时到达打水，第 $i$ 个人耗时 $t_i$。求一种顺序使所有人总等待时间最小。

按 $t_i$ 从小到大排队即可。下面这段代码把「多台机器分流」的写法也揉进来了：用小根堆维护每个人的累计时间，每次把当前最短的人放到累计时间最小的机器上。

```cpp
#include <bits/stdc++.h>
using namespace std;
priority_queue<int,vector<int>,greater<int>> fruit;
int n,r;
int ans[5010][5010];pair<int,int> t[5010];
int mil(){
    int miw=1e9,b=1;
    for(int i=1;i<=r;i++){
        if(miw>t[i].first){
            miw=t[i].first,b=i;
        }
    }
    return b;
}
int main(){
    long long cnt=0;cin>>n>>r;
    for(int i=1;i<=n;i++){
        int x;cin>>x;fruit.push(x);
    }
    while(fruit.size()){
        int a=fruit.top();fruit.pop();
        int i=mil();
        ans[i][t[i].second+1]=a+ans[i][t[i].second];
        t[i].first=ans[i][t[i].second+1];t[i].second++;
        cnt+=ans[i][t[i].second];
    }
    cout<<cnt;
}
```

- 核心是「短作业优先」：交换相邻的 $i,j$（$t_i > t_j$）后，其他人的等待时间不变，两人贡献从 $2t_i + t_j$ 变为 $2t_j + t_i$，差值 $t_i - t_j > 0$，说明交换后更优。
- 多机模型：升序排序后，每个人分配给当前累计时间最小的机器（源笔记注明「读者自证不难」）。

### 货仓选址（取中位数）

> 数轴上有 $n$ 家商店，位置 $x_1 \le \dots \le x_n$，选货仓位置 $x$ 使 $\sum |x - x_i|$ 最小。

排序后取中位数，再用双指针从两端向中间累加距离差。

```cpp
#include <bits/stdc++.h>
using namespace std;
vector<int> a(100010,40010);
int main() {
    int n,ans=0;
    cin>>n;
    for(int i=1;i<=n;i++){
        int b;cin>>b;//cout<<b;
        a[i]=b;
    }
    sort(a.begin()+1,a.end());
    //for(int i=1;i<=n;i++){
       // cout<<a[i];
   // }
    for(int i=1;i<=n/2;i++){
        ans+=(a[n-i+1]-a[i]);
    }
    cout<<ans<<endl;
    return 0;
}
```

- 第 $i$ 小与第 $n-i+1$ 小配成一对，`ans += a[n-i+1] - a[i]`，累加 $\lfloor n/2 \rfloor$ 对正好等于到中位数的距离和。
- 排序后单次扫描，复杂度 $O(n \log n)$。

### 导弹拦截（LIS 与 Dilworth）

> 一套系统每次拦截高度不能高于上一次；求（1）一套最多拦多少枚，（2）拦下全部最少要几套。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
int a[100010],f[100010];
vector<int> h,s;
signed main()
{
    int n=0,ans=0;
    int t;
    while(cin>>t){
        n++;a[n]=t;f[n]=1;
        h.push_back(t);
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<i;j++){
            if(a[j]>a[i]) f[i]=max(f[i],f[j]+1);
        }
    }
    for(int i=1;i<=n;i++){
        ans=max(ans,f[i]);
    }
    cout<<ans<<endl;
    for(int i=0;i<h.size();i++){
        int k=-1;
        for(int j=0;j<s.size();j++){
            if((k==-1||s[j]<s[k])&&h[i]<=s[j]) k=j;
        }
        if(k==-1) s.push_back(h[i]);
        else s[k]=h[i];
    }
    cout<<s.size();
    return 0;
}
```

- 问题一：最长**不上升**子序列长度，DP 转移 `if(a[j] > a[i]) f[i] = max(f[i], f[j] + 1)`。
- 问题二：用 Dilworth 定理——最少的不上升子序列覆盖数等于最长**严格上升**子序列长度，代码里贪心地用「能接住且最低」的系统去接，`s.size()` 即为答案。
- 源程序用 `#define int long long`，因此 `main` 写成 `signed main`。

### 区间选点 / 最大不相交区间

> 选最少的点，使每个闭区间 $[l_i, r_i]$ 都被覆盖；或选出最多的两两不重叠区间。

两者是同一类贪心（按右端点排序），源笔记给出的是一份「排序后线性扫描」的模板：

```cpp
#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> PII;
vector<PII> s;
void merge(vector<PII> &s) {
    vector<PII> res;
    sort(s.begin(),s.end());
    if(s.empty()){
        s=res;
        return;
    }
    int l=s[0].first,r=s[0].second;
    for(int i=1;i<s.size();i++){
        int a=s[i].first,b=s[i].second;
        if(a<=r){
            l=max(l,a);
            r=min(r,b);
        }else{
            res.push_back({l,r});
            l=a;
            r=b;
        }
    }
    res.push_back({l,r});
    s=res;
}
int main(){
    int n;cin>>n;
    for(int i=1;i<=n; i ++){
        int a,b;cin>>a>>b;
        s.push_back({a,b});
    }
    merge(s);
    cout<<s.size()<<endl;
}
```

- 策略要点：按右端点 $r_i$ 升序，`pos` 记当前最右选点，遇到 `pos < l_i` 就在 $r_i$ 放点并更新 `pos`；「最大不相交区间」判据是 `l_i >` 上一个选中区间的右端点。
- 解释：按右端点排序后第一个被选中的区间「让出的右侧空间最大」，替换成别的区间都不会更优，因此选它不亏。
- 该模板排序后线性扫描一遍，复杂度 $O(n \log n)$。

### 区间分组（小根堆维护各组的末尾右端点）

> 把 $n$ 个闭区间分成尽量少的组，使同组内区间两两不重叠。

```cpp
#include <bits/stdc++.h>
using namespace std;
vector<pair<int,int>> s;
priority_queue<int,vector<int>,greater<int>>h;
int main() {
    int n;cin>>n;
    for(int i=0;i<n;i++){
        int a,b;cin>>a>>b;
        s.push_back({a,b});
    }
    sort(s.begin(),s.end());
    for(int i=0;i<n;i++){
        int l=s[i].first,r=s[i].second;
        if(h.empty()||h.top()>=l){
            h.push(r);
        }else{
            h.pop();
            h.push(r);
        }
    }
    cout<<h.size()<<endl;
    return 0;
}
```

- 按左端点 $l_i$ 升序；小根堆存「每组最后一个区间的右端点」。
- 若堆顶（最小右端点）`>= l`，说明当前区间和**所有**已有组的末尾区间都重叠，必须新建一组；否则接到右端点最小的那组后面。
- 堆大小就是最少组数，复杂度 $O(n \log n)$。

### 区间覆盖（每次挑右端点最远的）

> 用尽量少的区间覆盖目标区间 $[s, t]$，无解则输出无解信息。

```cpp
#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> PII;
vector<PII> s;
void merge(vector<PII> &s) {
    vector<PII> res;
    sort(s.begin(),s.end());
    if(s.empty()){
        s=res;
        return;
    }
    int l=s[0].first,r=s[0].second;
    for(int i=1;i<s.size();i++){
        int a=s[i].first,b=s[i].second;
        if(a<=r){
            l=max(l,a);
            r=min(r,b);
        }else{
            res.push_back({l,r});
            l=a;
            r=b;
        }
    }
    res.push_back({l,r});
    s=res;
}
int main(){
    cout<<1;
}
```

- 策略要点：按左端点升序，从 $s$ 出发，在所有 $l_i \le pos$ 的区间里挑右端点最远的一个，把 $pos$ 更新为它的右端点，直到 $pos \ge t$ 或无区间可选。
- 贪心选择性质：把最优解里右端点较小的区间替换成当前右端点更大的，不会缩小已覆盖范围，也不会限制后续选择。
- 源笔记此处仅给出主函数骨架，完整的双指针扫描按上面的策略补全即可（扫描总复杂度 $O(n \log n)$）。

## 典型例题：反悔贪心

普通贪心「落子无悔」，但很多题存在**后效性 / 资源冲突**（时间限制、容量限制、相邻互斥），前面的选择会堵死后面的更优解。反悔贪心的思路是：先按大方向贪心地选上，若后续发现更优，就通过特定操作把之前的选择「换出来」。它一般用堆维护历史决策，复杂度 $O(n \log n)$。

### 任务调度

> 每个任务有耗时 $t_i$（通常为 1）、截止时间 $d_i$、收益 $p_i$，求截止前完成的最大总收益。

按 $d_i$ 升序，用小根堆存已选任务的收益：能塞下就直接加入；塞不下且 $p_i >$ 堆顶，就弹出收益最小的那个、换入 $p_i$。总任务数不变但收益单调增，且新集合仍满足截止限制。

### 利润问题

> 已知未来 $n$ 天股价 $a_i$，每天可买一股、卖一股或不动，求最大利润。

小根堆存历史买入价。遇到 $a_i >$ 堆顶就累加 $a_i - $ 堆顶，并把 $a_i$ **压两次**（一次当卖出、一次预留反悔），再弹出原堆顶。依据是 $a_j - a_i + a_i - a_k = a_j - a_k$，把多次买卖合并成一次更长的买卖。

### 互斥选择

> 在环形 / 线性序列中选 $k$ 个互不相邻的点，使点权和最大（或最小）。

用双向链表 + 大根堆。取出堆顶 $x$ 累加，删掉左右邻居 $l, r$，把 $x$ 的权值改成 $val_l + val_r - val_x$ 放回堆。之后若再选到该点，总贡献为 $val_x + (val_l + val_r - val_x) = val_l + val_r$，等价于「退选 $x$、改选 $l + r$」。

### 合法括号串

> 每个位置填左括号得 $a$、右括号得 $b$，求权值和最大的合法括号串（保证 $n$ 为偶数）。

先全部填右括号，建大根堆。对 $1 \le i \le n/2$，把前 $2i-1$ 个位置里未入队的 $a_i - b_i$ 入队，然后累加堆顶并弹出。合法括号串要求每个前缀左括号数 $\ge$ 右括号数且两者相等，于是每次改掉「代价最小」的那个位置即可。

> 补充：网络流中反向边的设计正是反悔贪心思想的体现。

## 复杂度分析

| 模型 | 主要操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|---|
| 合并果子 | 小根堆 | $O(n \log n)$ | $O(n)$ |
| 排队打水 | 排序 + 堆 | $O(n \log n)$ | $O(n)$ |
| 货仓选址 | 排序 | $O(n \log n)$ | $O(n)$ |
| 导弹拦截 | DP / 贪心扫描 | $O(n^2)$ 或 $O(n \log n)$ | $O(n)$ |
| 区间选点 / 覆盖 | 排序 + 扫描 | $O(n \log n)$ | $O(n)$ |
| 区间分组 | 排序 + 小根堆 | $O(n \log n)$ | $O(n)$ |
| 反悔贪心 | 堆 + 链表 | $O(n \log n)$ 或 $O(k \log n)$ | $O(n)$ |

一句话：贪心算法本体是线性的，代价几乎都花在**排序**或**堆**上。

## 适用场景

- 目标是最优化，且能证明「当前最优 = 全局最优的一部分」。
- 经典模型：合并果子、排队打水、货仓选址、区间选点 / 覆盖 / 分组、导弹拦截。
- 带时限 / 容量 / 相邻互斥的调度类问题，用反悔贪心（堆 + 链表）改写。
- 贪心常作为高级算法的前置（如 Kruskal、Huffman、Prim），也会在 CSP 里和其他算法配合出现。

## 常见陷阱与注意事项

1. **没证明就乱用**：贪心最容易「看着对、实际上错」，拿不到正确性证明时先想 DP 或对拍。
2. **排序关键字选错**：区间问题排序关键字（左端点还是右端点）决定了策略是否正确，选错位置会直接 WA。
3. **区间边界开闭**：`a <= r` 还是 `a < r` 取决于题目是闭区间还是开区间，务必看清。
4. **反悔堆的维护**：反悔贪心要保证「换进去的元素能覆盖被换出的选择」，写错堆顶弹出 / 压入次数就失去反悔能力。
5. **数据范围**：`ans` 可能超过 `int`，涉及累加时用 `long long`（源程序里 `#define int long long` 就是干这个的）。

## 对比与扩展

| 维度 | 贪心 | DP |
|---|---|---|
| 决策 | 每步直接定，不回头看 | 枚举所有状态转移 |
| 正确性依赖 | 必须证明贪心选择性质 | 只要状态 / 转移正确即可 |
| 复杂度 | 通常 $O(n \log n)$ | 视状态数，常更高 |
| 后效性 | 要求可消除或不存在 | 天然处理 |

扩展方向：**反悔贪心**（把「后悔」做成可撤销的堆操作）、**邻项交换排序**（用偏序 / 交换论证定制比较函数）、以及贪心与数据结构（堆、链表、并查集）的组合。
