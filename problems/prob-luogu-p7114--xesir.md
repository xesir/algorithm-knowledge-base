---
id: prob-luogu-p7114
title: 'P7114 [NOIP2020] 字符串匹配'
oj: '洛谷'
problemId: 'P7114'
difficulty: '提高+/省选−'
cfRating: 'NaN'
category: 字符串
tags: ["字符串哈希", "调和级数", "前缀桶", "奇偶性"]
timeComplexity: 'O(n log n + 26n)'
spaceComplexity: 'O(n)'
codePath: '题目专辑\字符串\字符串匹配\代码--xesir.cpp'
level: A
verified: 2026-10-20
source: 'Xesir'
---

## 题目描述

小 C 学习完了字符串匹配的相关内容，现在他正在做一道习题。

对于一个字符串 $S$，题目要求他找到 $S$ 的所有具有下列形式的拆分方案数：

$S = ABC$，$S = ABABC$，$S = ABAB \ldots ABC$，其中 $A$，$B$，$C$ 均是非空字符串，且 $A$ 中出现奇数次的字符数量不超过 $C$ 中出现奇数次的字符数量。

更具体地，我们可以定义 $AB$ 表示两个字符串 $A$，$B$ 相连接，例如 $A = \texttt{aab}$，$B = \texttt{ab}$，则 $AB = \texttt{aabab}$。

并递归地定义 $A^1=A$，$A^n = A^{n - 1} A$（$n \ge 2$ 且为正整数）。例如 $A = \texttt{abb}$，则 $A^3=\texttt{abbabbabb}$。

则小 C 的习题是求 $S = {(AB)}^iC$ 的方案数，其中 $F(A) \le F(C)$，$F(S)$ 表示字符串 $S$ 中出现奇数次的字符的数量。两种方案不同当且仅当拆分出的 $A$、$B$、$C$ 中有至少一个字符串不同。

### 输入格式

本题有多组数据，输入文件第一行一个正整数 $T$ 表示数据组数。

每组数据仅一行一个字符串 $S$，意义见题目描述。$S$ 仅由英文小写字母构成。

### 输出格式

对于每组数据输出一行一个整数表示答案。

### 数据范围

| 测试点编号 | $\lvert S\rvert \le$ | 特殊性质 |
|:-:|:-:|:-:|
| $1 \sim 4$ | $10$ | 无 |
| $5 \sim 8$ | $100$ | 无 |
| $9 \sim 12$ | $1000$ | 无 |
| $13 \sim 14$ | $2^{15}$ | $S$ 中只包含一种字符 |
| $15 \sim 17$ | $2^{16}$ | $S$ 中只包含两种字符 |
| $18 \sim 21$ | $2^{17}$ | 无 |
| $22 \sim 25$ | $2^{20}$ | 无 |

对于所有测试点，保证 $1 \le T \le 5$，$1 \le |S| \le 2^{20}$。

## 样例

### 样例 1

**输入：**

```
3
nnrnnr
zzzaab
mmlmmlo
```

**输出：**

```
8
9
16
```

### 样例 2

**输入：**

```
5
kkkkkkkkkkkkkkkkkkkk
lllllllllllllrrlllrr
cccccccccccccxcxxxcc
ccccccccccccccaababa
ggggggggggggggbaabab
```

**输出：**

```
156
138
138
147
194
```

**解释：**

样例 1 第一组 `nnrnnr` 的 8 种方案（原文列举）：

1. $A=\texttt{n}$，$B=\texttt{nr}$，$C=\texttt{nnr}$。
2. $A=\texttt{n}$，$B=\texttt{nrn}$，$C=\texttt{nr}$。
3. $A=\texttt{n}$，$B=\texttt{nrnn}$，$C=\texttt{r}$。
4. $A=\texttt{nn}$，$B=\texttt{r}$，$C=\texttt{nnr}$。
5. $A=\texttt{nn}$，$B=\texttt{rn}$，$C=\texttt{nr}$。
6. $A=\texttt{nn}$，$B=\texttt{rnn}$，$C=\texttt{r}$。
7. $A=\texttt{nnr}$，$B=\texttt{n}$，$C=\texttt{nr}$。
8. $A=\texttt{nnr}$，$B=\texttt{nn}$，$C=\texttt{r}$。

样例 3、4 见题目附件，这里不重复。

## 解题思路

### 把结构翻译成「前缀是周期串」

$S={(AB)}^iC$ 意味着：开头 $|AB|\times i$ 个字符由同一个块 $AB$ 重复若干次得到，剩下的部分就是 $C$。又因为 $A$ 是 $AB$ 的前缀，所以：

- $AB$ 一定是 $S$ 的**前缀**，长度记为 $L$；
- $C$ 一定是 $S$ 的**后缀**；
- 中间那段必须是若干个完整的 $AB$ 拼接。

于是可以枚举 $L=|AB|$，再枚举重复次数 $m$（代码里用 $j+1$ 表示），检查 `S[1..L]` 与第 $2,3,\dots,m$ 个块是否完全相同：

$$S[1..L]=S[L+1..2L]=\cdots=S[(m-1)L+1..mL]$$

只要有一处不等，后面的重复次数就都不用看了，直接 `break`。

### 周期性用哈希判

逐块比较是 $O(L)$ 的，整体会退化。用字符串哈希把每段 $O(1)$ 取出来比较即可。

这里对同一段文本用了两组哈希：一组模 $998244353$，一组用 `unsigned long long` 自然溢出（模 $2^{64}$）。两者一起比较，碰撞概率可以忽略。

### 预处理 $F$

$F(P)$ 是「出现奇数次的字符个数」。因为只有 $26$ 种字符，可以用一个 $26$ 位整数当状态：每读入一个字符就异或上对应的位，最后 $1$ 的个数就是 $F$。

于是预处理：

- `pre[i] = F(S[1..i])`，从前往后扫一遍；
- `suf[i] = F(S[i..n])`，从后往前扫一遍。

`__builtin_popcountll` 直接给出二进制里 $1$ 的个数。

### 关键技巧：桶里存「不超过」的计数

剩下要数的就是：对每个合法的 $(L,m)$，统计有多少个 $|A|\in[1,L-1]$ 满足 $F(A)\le F(C)$。

$F$ 的值域只有 $[0,26]$，可以开桶。但桶要能回答「$F(A)\le x$ 的个数」，所以**不存精确值，而是存后缀计数**：

> 每遇到一个前缀 $P$，就把 `thp[k]` 对所有 $k\ge F(P)$ 加一。

这样 `thp[x]` 天然等于「$F(P)\le x$ 的前缀个数」，查询时 `thp[F(C)]` 就是答案，$O(1)$。

### 为什么是 $O(n\log n)$

枚举 $L$ 从 $2$ 到 $n-1$，每个 $L$ 的重复次数最多到 $n/L$，于是总枚举量是

$$\sum_{L=2}^{n-1}\frac{n}{L}=O(n\log n)$$

这正是调和级数的结论。加上每轮 $O(26)$ 的桶更新，总复杂度 $O(n\log n+26n)$。

## 逐行代码解析

### 头文件与哈希函数

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
#define ull unsigned long long
#define PUU pair<ull,ull> 
#define fi first
#define se second
const int N=2e6+10,mod1=998244353,mod2=1e9+7;
int thp[27];
PUU hs[N],pb[N];
int pre[N],suf[N];
inline PUU gths(int l,int r){
    PUU res;
    res.fi=(hs[r].fi%mod1+mod1-hs[l-1].fi*pb[r-l+1].fi%mod1)%mod1;
    res.se=(hs[r].se-hs[l-1].se*pb[r-l+1].se);
    return res;
}
```

- `PUU` 是「双哈希值」的 pair，第一维模 $998244353$，第二维自然溢出。
- `hs[i]` 是前缀哈希，`pb[i]` 是 $26^i$ 的两种取模结果。
- `gths(l,r)` 取子串哈希：`h[r] - h[l-1] * 26^{r-l+1}`。
- 第一维要 `+mod1` 再取模，防止减法出现负数；第二维本来就靠溢出自动取模，不需要额外处理。
- `thp[27]` 就是那个桶，下标是 $F$ 的值（$0\sim26$）。

### 预处理幂、读入与前缀哈希

```cpp
signed main(){
    ios::sync_with_stdio(0);
    cin.tie(0);cout.tie(0);
    int t;cin>>t;
    pb[0].fi=1,pb[0].se=1;
    for(int i=1;i<1.5e6;i++) 
        pb[i].fi=pb[i-1].fi*26%mod1,pb[i].se=pb[i-1].se*26;
    while(t--){
        string s;cin>>s;s='0'+s;
        int n=s.size()-1;ull ans=0;
        for(int i=0;i<=26;i++) thp[i]=0;
        for(int i=1;i<=n;i++) 
            hs[i].fi=(hs[i-1].fi*26%mod1+(s[i]-'a')%mod1)%mod1,            hs[i].se=(hs[i-1].se*26+(s[i]-'a'));
```

- 幂表只预计算到 $1.5\times10^6$：$|S|\le2^{20}\approx1.05\times10^6$，够用。
- `s='0'+s` 把下标挪到 $1$ 基，`hs[0]` 天然为空串。
- 哈希的底数取 $26$（字符集大小），映射值是 `s[i]-'a'`。
- `thp` 每组重置，避免跨组污染。
- `hs` 不需要清空——因为每次都是从 `hs[0]=0` 开始重新递推，用到的位置都会被覆盖。

### $F$ 的前后缀预处理

```cpp
        for(int i=1,j=0;i<=n;i++){
            j^=(1<<(s[i]-'a'));
            pre[i]=__builtin_popcountll(j);
        }
        for(int i=n,j=0;i>0;i--){
            j^=(1<<(s[i]-'a'));
            suf[i]=__builtin_popcountll(j);
        }
```

- `j` 是 $26$ 位的奇偶掩码：某个字符出现奇数次，对应位就是 $1$。
- 每读一个字符异或一次，正好把「出现次数奇偶」翻转。
- `pre[i]` 是 $F(S[1..i])$，`suf[i]` 是 $F(S[i..n])$。
- 两趟都从空掩码出发，互不影响。

### 主循环：桶 + 枚举

```cpp
        for(int i=2;i<n;i++){
            //bool kk=true;
            for(int k=pre[i-1];k<=26;k++) thp[k]++;
            for(int j=0;(j+1)*i<n;j++){
                if(hs[i]==gths(1+i*j,i*(j+1))){
                    ans+=thp[suf[i*(j+1)+1]];
                }else break;
            }
        }
        cout<<ans<<'\n';
    }
    return 0;
}
```

- 外层 `i` 就是 $L=|AB|$，范围 $[2,n-1]$：$|AB|\ge2$（$A,B$ 都非空），且要留出至少 $1$ 个字符给 $C$。
- `thp[k]++ (k>=pre[i-1])` 把「长度为 $i-1$ 的前缀」加入桶。因为 $i$ 递增，长度 $1\sim i-1$ 的前缀在前几轮都已加入，正好就是所有合法的 $|A|$。
- 内层 `j` 从 $0$ 开始：`gths(1+i*j, i*(j+1))` 是第 $j$ 个块（$0$ 基），与 `hs[i]`（第 $0$ 个块）比较。
- `j=0` 时是「自己和自己比」，永远相等，所以每次至少会进入一次循环体。
- 一旦某块不相等就 `break`：后面的重复次数都建立在「前面全相等」的基础上。
- `(j+1)*i<n` 保证 $C$ 非空，长度是 $n-(j+1)i$，`suf[i*(j+1)+1]` 正是 $F(C)$。
- `ans+=thp[F(C)]` 一次加的是「所有满足 $F(A)\le F(C)$ 的 $A$ 的个数」，$O(1)$ 完成。

## 复杂度分析

幂表预处理 $O(1.5\times10^6)$，每组字符串：哈希 $O(n)$、前后缀 $F$ 各 $O(n)$、桶更新 $O(26n)$、枚举块 $O(n\log n)$。总时间 $O(n\log n+26n)$，空间是四个长度 $2\times10^6$ 的数组，$O(n)$。

## 常见陷阱与注意事项

- **桶存的是「$\le$」不是「$=$」**：`for(k=pre[i-1];k<=26;k++)++` 这种写法容易写反，写成 `thp[pre[i-1]]++` 就只能查精确值了。
- **$|A|$ 的范围是 $1\sim L-1$**：$B$ 必须非空，所以 $A$ 不能等于 $AB$ 整段；桶刚好只加到 $i-1$ 为止。
- **$C$ 必须非空**：循环条件用 `(j+1)*i<n` 而不是 `<=`。
- **失配立刻 `break`**：周期性一旦破坏，更大的重复次数都不可能成立。
- **取模减法要加 `mod`**：`hs[r]-hs[l-1]*pow` 可能为负。
- **第二组哈希依赖溢出**：`res.se` 全程在 `unsigned long long` 里运算，不能中途转成 `int`。
- **幂表上界**：$|S|$ 最大 $2^{20}$，预计算到 $1.5\times10^6$ 才够；开小了会读到未初始化的 `pb`。

## 对比与扩展

- 与「P14154 索道」的关系：那道题用单调队列把 $O(nk)$ 的 DP 压成 $O(n)$，本题用调和级数把「枚举所有块」压成 $O(n\log n)$，都是把重复计算的部分一次性摊掉。
- 若不允许哈希碰撞，可以把周期性判定换成 KMP 的失配数组，复杂度仍是线性级别。
- 桶技巧（把「$\le x$ 的计数」做成增量后缀加）在统计类题目里很常见，和「值域树状数组」是同一个思路的轻量版。
