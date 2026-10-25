---
id: prob-luogu-p17248
title: 'P17248 审判与救赎'
oj: '洛谷'
problemId: 'P17248'
difficulty: '省选/NOI−'
cfRating: 'NaN'
category: 数据结构
tags: ["主席树", "贪心", "异或", "区间查询"]
timeComplexity: 'O((n+q) log V)'
spaceComplexity: 'O(n log V)'
codePath: '题目专辑\数据结构\审判与救赎\代码--xesir.cpp'
level: A
verified: 2026-10-20
source: 'Xesir'
---

> ~~赛时觉得自己思路太逆天直接否了，没想到真是正解，神秘~~

## 题目描述

给定长度为 $n$ 的非负整数序列 $a$，$q$ 次询问区间 $[l,r]$。

对于区间内的所有数，将它们划分成若干非空组（组内元素不要求连续，不限大小），每组权值为组内所有数的异或和。设各组权值为 $b_1,\dots,b_k$，求最大化 $\prod b_i$，输出对 $998244353$ 取模的结果。

### 输入格式

原文没有单独给出输入格式，下面按所附代码的读入方式整理：

- 第一行两个整数 $n,q$；
- 第二行 $n$ 个整数 $a_1,a_2,\dots,a_n$；
- 接下来 $q$ 行，每行两个整数 $l,r$，表示一次询问。

### 输出格式

输出 $q$ 行，第 $i$ 行一个整数，表示第 $i$ 次询问的答案。

### 数据范围

原文未附数据范围。从代码上界可以推断设计规模：

- `N=5e5+10`，故 $n,q$ 至多约 $5\times 10^5$；
- 值域被写成 $[-\mathrm{INF},\mathrm{INF}]$，其中 `INF=1e9+10`，即按 $a_i$ 在 $10^9$ 量级设计；
- 复杂度 $O((n+q)\log V)$ 也印证了“大 $n$、大值域”的定位。

（以上是从代码反推的，不是原文给出的数据范围。）

## 样例

原文未附样例。

## 解题思路

### 一、题目在问什么

一次询问给一个区间，把区间里的数任意分组（组内不要求连续），每组算异或和，让所有组权值的**乘积**最大。

“任意分组 + 最大化乘积”看起来像要按位贪心求异或最大值，但这题的核心其实是一个不等式问题——真正决定分组方式的不是异或的最值，而是异或与乘法的大小关系。

### 二、两条不等式把问题降维

对任意非负整数 $x,y$：

$$x \oplus y \le x+y$$

这条很好理解：异或是不进位加法，不进位只会让结果变小。

当 $x,y \ge 2$ 时：

$$x+y \le x\times y$$

因为 $xy-x-y=(x-1)(y-1)-1\ge 0$（$x,y\ge 2$ 时 $(x-1)(y-1)\ge 1$）。

把两条连起来：若两个组的权值 $x,y$ 都 $\ge 2$，把它们**合并**成一个组后权值变成 $x\oplus y$，乘积贡献从 $x\times y$ 变成 $x\oplus y$，而

$$x\oplus y \le x+y \le x\times y$$

也就是说，合并只会让答案不变或变小。**结论：最优划分里，任意两个权值 $\ge 2$ 的组都不应该合并。**

于是除了 $0$ 和 $1$ 之外，所有数都应该独立成组——必要时把 $0$ 或 $1$ 并进这些组里。问题只剩下“$0$ 和 $1$ 怎么处理”。

### 三、处理 $0$

任意数异或 $0$ 都等于它本身，所以 $0$ 可以随意并入任何组，不改变该组权值。

因此：

- 如果区间内**全是 $0$**，答案就是 $0$；
- 否则把所有 $0$ 忽略（并进别的组即可，对乘积没有贡献）。

### 四、处理 $1$

一个组里如果混进一个 $1$，只会翻转最低位：偶数 $c$ 变成 $c+1$，奇数变成 $c-1$。

所以“把 $1$ 并进权值为偶数的组”能让该组贡献从 $c$ 变成 $c+1$，相当于乘上 $\frac{c+1}{c}=1+\frac{1}{c}$；并进奇数组成的组只会让贡献变小。

由此得到三条约束：

- 每个 $1$ 至多用来给一个偶数“加 $1$”；
- 每个偶数至多被加一次（加完就变成奇数，不能再加）；
- 收益倍率 $\frac{c+1}{c}$ 关于 $c$ 单调递减，**$c$ 越小收益越大**。

### 五、最终结论

设区间内所有非零偶数为 $c_1\le c_2\le\cdots\le c_k$，区间内 $1$ 的个数为 $h$，则最优答案为：

$$\prod_{i=1}^{\min(h,k)}(c_i+1)\times\prod_{i=\min(h,k)+1}^{k}c_i$$

也就是**前 $\min(h,k)$ 小的偶数各加 $1$**，其余偶数不变；如果 $h\ge k$，所有偶数都加 $1$。

**贪心为什么取最小的偶数**：每次操作的收益倍率都大于 $1$，能用就尽量用；而倍率随 $c$ 增大而递减，把有限的 $h$ 次操作全部分给最小的 $h$ 个偶数，等价于“每次选当前收益最大的那个”。用交换论证更严格：若某方案操作了较大的 $c_j$ 却漏掉较小的 $c_i$（$c_i<c_j$），把这次操作从 $c_j$ 换到 $c_i$，总乘积会乘上

$$\frac{c_i+1}{c_i}\cdot\frac{c_j}{c_j+1}>1$$

严格更优，所以最优解一定取最小的一批偶数。

### 六、实现：前缀和 + 主席树

要回答一次询问，需要四类信息：

- 区间内 $0$ 的个数（判断是否全 $0$）；
- 区间内 $1$ 的个数（决定操作次数 $h$）；
- 区间内所有非零数的乘积（基础乘积）；
- 区间内“前 $h$ 小偶数”的 $\frac{c+1}{c}$ 连乘（提升带来的比值）。

前三项用前缀和 $O(1)$ 即可。最后一项是“按值序取前 $h$ 小的偶数”，典型的**主席树（可持久化权值线段树）**场景：以值域为下标，每个前缀版本维护子树内的

- 偶数个数 `cnt`；
- 偶数乘积 `wh` 及其逆元 `iwh`；
- 偶数“加 $1$ 后的乘积”`osp` 及其逆元 `iosp`。

查询时在版本差 $[l-1,r]$ 上做值域二分：左子树偶数够 $k$ 个就只进左子树，不够就把左子树**整体**乘上 `osp * iosp(对侧)`，再进右子树补剩下的个数，$O(\log V)$ 就能取出前 $k$ 小偶数的比值连乘，再乘上基础乘积即得答案。

**为什么维护比值而不是直接维护“加 1 后的答案”**：因为前 $k$ 小的偶数是不确定的，需要二分确定“哪些偶数被加 1”；用比值连乘可以让“取某一段连续值域的偶数”变成一次乘法，配合逆元就能做区间除法。

### 七、细节处理

1. 区间内出现 $998244353$ 时乘积在模意义下为 $0$，答案直接为 $0$，需要特判；
2. 区间全为 $0$ 时答案为 $0$；
3. 逆元用快速幂算，但每次查询都快速幂会超时，所以用哈希表缓存算过的逆元与比值；
4. 主席树用 `vector` 动态分配节点，避免按固定大小开满导致 MLE。

### 八、复杂度

- 建树：每个元素插入一次，每次 $O(\log V)$，共 $O(n\log V)$；
- 单次询问：主席树上值域二分，$O(\log V)$；
- 总复杂度 $O((n+q)\log V)$。

### 九、总结

这个题是一个非常诡异的诈骗题，需要你熟知异或等运算的性质。原题数据强度非常逆天，个人认为实现并通过数据的难度远大于口胡，想训练码力的可以挑战一下。

## 逐行代码解析

### 模块一：头文件、宏与全局数组

```cpp
#include<bits/stdc++.h>
using namespace std;
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define mid ((l+r)>>1)
#define lc goc[u].ls
#define rc goc[u].rs

typedef pair<int,int> PII;
typedef long long ll;
const int N=5e5+10;
const int INF=1e9+10;
const int mod=998244353;

int a[N], h1[N], hf0[N], hmod[N];
```

- `N=5e5+10` 是数组上界；`INF=1e9+10` 作为主席树值域的上下界绝对值；`mod=998244353` 是模数。
- `mid` 是线段树的中点宏，后面 `zxpro` 与 `aliez` 的形参都叫 `l,r`，宏能直接展开；`lc`/`rc` 两个宏实际没有被使用，属模板残留。
- `a` 存原序列；`h1`、`hf0`、`hmod` 分别是“$1$ 的个数”“非零元素个数”“等于模数的元素个数”的前缀和。

### 模块二：快速幂与逆元缓存表

```cpp
inline int ksm(int x,int y,int p){
    int res=1%p;
    x%=p;
    while(y){
        if(y&1) res=(ll)res*x%p;
        x=(ll)x*x%p;
        y>>=1;
    }
    return res;
}

unordered_map<int,int> ic, fc, ifc;
```

- `ksm(x,y,p)` 是迭代版快速幂，用来通过费马小定理求逆元（$x^{mod-2}$）。
- `ic` 缓存逆元 $x^{-1}$，`fc` 缓存 $\frac{x+1}{x}$，`ifc` 缓存 $\frac{x}{x+1}$；把“每次查询都快速幂”降为均摊 $O(1)$。
- 三个哈希表是全局的，所以整份程序的所有逆元只算一次。

### 模块三：主席树节点、逆元查询与构造函数

```cpp
struct siryessir{
    struct note{
        int ls=0, rs=0;
        int wh=1, iwh=1;
        int cnt=0;
        int osp=1, iosp=1;
    };
    vector<note> goc;
    int tot=0;
    int rt[N];

    inline int getinv(int x){
        x %= mod;
        if(x==0) return 0;
        auto it = ic.find(x);
        if(it != ic.end()){
            int res = it->second;
            return res;
        }
        int res = ksm(x, mod-2, mod);
        ic[x] = res;
        return res;
    }

    inline int getf(int x){
        x %= mod;
        auto it = fc.find(x);
        if(it != fc.end()){
            int res = it->second;
            return res;
        }
        int invx = getinv(x);
        int res = (ll)(x+1) * invx % mod;
        fc[x] = res;
        return res;
    }

    inline int getif(int x){
        x %= mod;
        auto it = ifc.find(x);
        if(it != ifc.end()){
            int res = it->second;
            return res;
        }
        int invx1 = getinv((x+1) % mod);
        int res = (ll)x * invx1 % mod;
        ifc[x] = res;
        return res;
    }

    siryessir(){
        goc.clear();
        tot=0;
        goc.push_back({0,0,1,1,0,1,1});
    }
```

- `note` 是主席树节点：`ls/rs` 左右儿子；`wh/iwh` 子树内“偶数乘积”及其逆元；`cnt` 偶数个数；`osp/iosp` 子树内“$\frac{c+1}{c}$ 连乘”及其逆元。
- `goc` 是动态节点池（`vector`），`rt[i]` 是前缀 $[1,i]$ 对应版本的根编号。
- `getinv/getf/getif` 分别带缓存地查 $x^{-1}$、$\frac{x+1}{x}$、$\frac{x}{x+1}$；$x=0$ 时逆元按 $0$ 返回（后面 `k==0` 的分支会提前挡掉 $0$，正常不会走到这里）。
- 构造函数压入一个**全空节点**（编号 0）当作空树：`{0,0,1,1,0,1,1}` 对应 `ls=rs=0`、`wh=iwh=1`、`cnt=0`、`osp=iosp=1`，这样“乘空节点”不会影响乘积。

### 模块四：主席树单点插入 `zxpro`

```cpp
    int zxpro(int u,int l,int r,int k,int v){
        if(k==0) return u;
        goc.push_back(goc[u]);
        u=++tot;

        int kmod = k % mod;
        goc[u].wh = (ll)goc[u].wh * kmod % mod;
        goc[u].iwh = (ll)goc[u].iwh * getinv(kmod) % mod;

        if((k & 1) == 0){
            goc[u].cnt += v;
            int inv_k = getinv(kmod);
            int inv_k1 = getinv((kmod + 1) % mod);
            int f = (ll)(kmod + 1) * inv_k % mod;
            int vf = (ll)kmod * inv_k1 % mod;
            goc[u].osp = (ll)goc[u].osp * f % mod;
            goc[u].iosp = (ll)goc[u].iosp * vf % mod;
        }

        if(l==r) return u;
        if(k <= mid) goc[u].ls = zxpro(goc[u].ls, l, mid, k, v);
        else goc[u].rs = zxpro(goc[u].rs, mid+1, r, k, v);

        int lu = goc[u].ls, ru = goc[u].rs;
        goc[u].wh = (ll)goc[lu].wh * goc[ru].wh % mod;
        goc[u].iwh = (ll)goc[lu].iwh * goc[ru].iwh % mod;
        goc[u].cnt = goc[lu].cnt + goc[ru].cnt;
        goc[u].osp = (ll)goc[lu].osp * goc[ru].osp % mod;
        goc[u].iosp = (ll)goc[lu].iosp * goc[ru].iosp % mod;
        return u;
    }
```

- `zxpro` 是可持久化单点插入：先复制旧节点、开新节点，再沿值域 $[l,r]$ 递归到叶子。
- `if(k==0) return u;` 意味着 $0$ **不插入**：$0$ 对乘积没有贡献，也可以避开 $\frac{0+1}{0}$ 这种除零。
- 路径上每个节点都乘上 $k$ 并维护其逆元；只有 $k$ 为偶数时才累加 `cnt`，同时把 $\frac{k+1}{k}$ 与 $\frac{k}{k+1}$ 分别乘进 `osp/iosp`。
- 回溯时用左右儿子重新合并五个量，只有被修改的那条链会新建节点，所以每次插入只增加 $O(\log V)$ 个节点。

### 模块五：查询前 $k$ 小偶数的比值连乘 `aliez`

```cpp
    int aliez(int p1,int p2,int l,int r,int k){
        if(k <= 0) return 1;
        int cntz = goc[p2].cnt - goc[p1].cnt;
        if(k > cntz) k = cntz;
        if(k == 0) return 1;
        if(l == r){
            return ksm(getf(l), k, mod);
        }
        int lu1 = goc[p1].ls, ru1 = goc[p1].rs;
        int lu2 = goc[p2].ls, ru2 = goc[p2].rs;
        int now = goc[lu2].cnt - goc[lu1].cnt;
        if(k <= now){
            return aliez(lu1, lu2, l, mid, k);
        } else {
            int cntl = (ll)goc[lu2].osp * goc[lu1].iosp % mod;
            int cntr = aliez(ru1, ru2, mid+1, r, k - now);
            return (ll)cntl * cntr % mod;
        }
    }
} hjt;
```

- `p1` 是 $l-1$ 版本、`p2` 是 $r$ 版本，用版本差得到区间信息；函数求的是“前 $k$ 小偶数的 $\frac{c+1}{c}$ 连乘”。
- 进入时先把 $k$ 压到不超过区间偶数总数；到叶子（值为 $l$）时该位置有 $k$ 个相同偶数，返回 $(\frac{l+1}{l})^k$。
- 值域二分：左子树偶数个数 `now` 够 $k$ 个，就只进左子树；否则左子树**全部**被选中，直接用 `goc[lu2].osp * goc[lu1].iosp` 拿到左子树整体的比值连乘，再进右子树补剩下的 $k-now$ 个。
- 结尾的 `} hjt;` 顺手声明了全局主席树对象 `hjt`。

### 模块六：快读快写

```cpp
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

- 手写 `getchar/putchar` 快读快写，应对 $5\times 10^5$ 级别的输入输出。
- `write` 是递归输出每一位，负数先输出负号。

### 模块七：main——建版本与回答询问

```cpp
int main(){
    int n, m;
    n = read(); m = read();
    for(int i=1;i<=n;i++){
        a[i] = read();
        h1[i] = h1[i-1] + (a[i] == 1);
        hf0[i] = hf0[i-1] + (a[i] != 0);
        hmod[i] = hmod[i-1] + (a[i] == mod);
        if(a[i] == mod){
            hjt.rt[i] = hjt.rt[i-1];
        } else {
            hjt.rt[i] = hjt.zxpro(hjt.rt[i-1], -INF, INF, a[i], 1);
        }
    }
    while(m--){
        int l, r;
        l = read(); r = read();
        if(hf0[r] - hf0[l-1] == 0){
            write(0); putchar('\n');
            continue;
        }
        if(hmod[r] - hmod[l-1] > 0){
            write(0); putchar('\n');
            continue;
        }
        int res = (ll)hjt.goc[hjt.rt[r]].wh * hjt.goc[hjt.rt[l-1]].iwh % mod;
        int cnt1 = h1[r] - h1[l-1];
        int cntj = hjt.goc[hjt.rt[r]].cnt - hjt.goc[hjt.rt[l-1]].cnt;
        int k = min(cnt1, cntj);
        if(k == 0){
            write(res); putchar('\n');
            continue;
        }
        int ans = hjt.aliez(hjt.rt[l-1], hjt.rt[r], -INF, INF, k);
        write((ll)res * ans % mod); putchar('\n');
    }
    return 0;
}
```

- 建版本：边读入边维护三个前缀和；若 `a[i]==mod`，该版本直接复用上一版本（这个值在模意义下是 $0$，需要特判），否则在上一版本上插入。
- `res` 是区间所有非零数的乘积，用 `wh[r] * iwh[l-1]` 得到——主席树维护的是“偶数”的乘积，但 `wh` 实际对**所有插入的非零值**都乘了，所以它就是完整的基础乘积。
- `k = min(1 的个数, 偶数个数)` 就是最多能做多少次“偶数加 $1$”。
- 三个提前退出分支：全 $0$ 输出 $0$；含模数输出 $0$；`k==0` 直接输出基础乘积。否则把比值连乘乘回 `res`。

## 复杂度分析

- **时间**：建树 $n$ 次插入，每次 $O(\log V)$；每次询问在主席树上值域二分，$O(\log V)$（叶子上还要一次快速幂 $O(\log mod)$，有缓存后均摊很低）。总计 $O((n+q)\log V)$，$V$ 约为 $2\times 10^9$。
- **空间**：每次插入新建 $O(\log V)$ 个节点，共 $O(n\log V)$ 个；每个节点 7 个 `int`（28 字节），$n=5\times 10^5$、$\log V\approx 31$ 时节点数约 $1.5\times 10^7$，占用在 400 MB 量级，内存限制紧的时候要留意。`vector` 动态分配避免了按固定上界开满，但常数仍然是这套做法的主要压力。

## 常见陷阱与注意事项

1. **$0$ 不能当偶数去“加 $1$”**：套用 $\frac{c+1}{c}$ 会直接除零。代码在 `zxpro` 里对 `k==0` 提前返回，$0$ 不进树；而 $0$ 本身可以免费并入任何组，不需要单独处理。

2. **区间含 $998244353$ 要特判为 $0$**：这个值在模意义下就是 $0$，且它是大于等于 $2$ 的奇数，最优划分下会独立成组，乘积含因子 $998244353\equiv 0$，无法被“加 $1$”抵消。代码用 `hmod` 前缀和检测后直接输出 $0$。

3. **`hmod` 统计的是“等于 `mod`”而不是“模 `mod` 为 $0$”**：只有当 $a_i$ 的值域小于 $2\times 998244353$ 时两者才等价。若值域更大，必须改成 `a[i] % mod == 0`，否则会漏判。

4. **逆元必须缓存**：每次查询都快速幂会超时，`ic/fc/ifc` 三个哈希表把重复的逆元与比值查询降为均摊 $O(1)$。

5. **`wh` 与 `osp` 别混淆**：`wh` 是“所有非零数”的乘积（含奇数），`osp` 是“偶数的 $\frac{c+1}{c}$ 连乘”（只含偶数）；答案 = 基础乘积 × 前 $k$ 小偶数的比值乘积。

6. **只有偶数能被 $1$ 提升**：奇数异或 $1$ 会减 $1$，所以每个偶数最多提升一次，操作次数上限是 $\min(h,k)$。

7. **分支顺序不能乱**：先判全 $0$、再判含模数、最后判 `k==0`，否则会在“全零但无模数”等边界上错误地进入 `aliez` 或算出非零结果。

8. **值域上界 `INF=1e9+10` 可能不够**：如果 $a_i$ 取到 $2^{30}-1\approx 1.07\times 10^9$，就会超过 `INF`，被塞进最右侧叶子（值为 `INF`）里，导致“前 $k$ 小偶数”的顺序和比值都不对。若数据卡这一点，需要把 `INF` 调大。

9. **`aliez` 的叶子返回含义**：到叶子时同一数值有 $k$ 个，用快速幂一次算出比值 $k$ 次方，不要写成单个比值。

10. **递归深度**：`zxpro` 与 `aliez` 的递归深度是 $O(\log V)$，正常不会爆栈；`write` 的递归深度只有十进制位数，也没有风险。

## 对比与扩展

- **异或的不等式刻画**：$x\oplus y\le x+y\le x\times y$（$x,y\ge 2$）是本题的核心，它把“怎么分组”直接化约为“只需处理 $0$ 和 $1$”。这与“异或最大值 / 最小异或对”那种按位 Trie 贪心是两条完全不同的路子。

- **主席树求“前 $k$ 小的某个聚合量”**：经典主席树求区间第 $k$ 小，本题把聚合量从“个数”换成“乘积、比值乘积”，靠每个节点维护 `cnt/wh/osp` 三组信息、查询时值域二分，是同一模板的变体。

- **交换论证贪心**：“收益 $\frac{c+1}{c}$ 单调递减，所以取最小的一批”是收益独立、可交换的典型贪心，证明手法与“排序后按收益降序取”的题相通。

- **诈骗题性质**：题面用“异或”作包装，真正考的是两条不等式加一个数据结构；对异或运算的性质不熟时，很容易误入“按位贪心求异或最大值”的歧途。
