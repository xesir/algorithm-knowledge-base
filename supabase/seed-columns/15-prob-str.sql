-- ============================================================
-- AKB 专栏种子：题目 / 字符串
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：2 行
-- ============================================================
begin;

drop table if exists _akb_seed_columns;
create temp table _akb_seed_columns (
    author_name text not null,
    column_key text not null,
    column_name text not null,
    content text not null,
    category text,
    tags text[],
    parent_key text,
    difficulty text,
    kind text not null
) on commit drop;

insert into _akb_seed_columns (
    author_name, column_key, column_name, content, category, tags, parent_key, difficulty, kind
) values
('Xesir', 'col-prob-luogu-p7114--xesir', 'P7114 [NOIP2020] 字符串匹配 · Xesir', $AKB605$## 题目描述

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
- 桶技巧（把「$\le x$ 的计数」做成增量后缀加）在统计类题目里很常见，和「值域树状数组」是同一个思路的轻量版。$AKB605$, '字符串', array['字符串哈希', '调和级数', '前缀桶', '奇偶性'], null, '提高+/省选−', 'problem'),
('world-needs-sunday', 'col-prob-p7915-palindrome', '[CSP-S 2021] 回文（P7915）— 双栈分段贪心迭代', $AKB606$## 题目描述

给定正整数 $n$ 和整数序列 $a_1, a_2, \ldots, a_{2n}$，在这 $2n$ 个数中，$1, 2, \ldots, n$ 分别各出现恰好 2 次。现在进行 $2n$ 次操作，目标是创建一个长度同样为 $2n$ 的序列 $b_1, b_2, \ldots, b_{2n}$，初始时 $b$ 为空序列，每次可以进行以下两种操作之一：

1. 将序列 $a$ 的**开头**元素加到 $b$ 的末尾，并从 $a$ 中移除（操作 `L`）
2. 将序列 $a$ 的**末尾**元素加到 $b$ 的末尾，并从 $a$ 中移除（操作 `R`）

目的是让 $b$ 成为一个**回文数列**，即满足对所有 $1 \le i \le n$，有 $b_i = b_{2n+1-i}$。判断是否能达成，如果能则输出**字典序最小**的操作方案。

### 输入格式

每个测试点包含多组测试数据。

- 第一行：整数 $T$，表示测试数据组数
- 对于每组数据：
  - 第一行：正整数 $n$
  - 第二行：$2n$ 个空格隔开的整数 $a_1, a_2, \ldots, a_{2n}$

### 输出格式

对每组测试数据输出一行：
- 若无法生成回文数列，输出 `-1`
- 否则输出一个长度为 $2n$ 的、由 `L` 或 `R` 构成的字符串（字典序最小）

### 数据范围

- $1 \le T \le 100$
- $1 \le n, \sum n \le 5 \times 10^5$
- 序列中 $1, 2, \ldots, n$ 各出现恰好 2 次

## 样例

**输入**：
```
2
5
4 1 2 4 5 3 1 2 3 5
3
1 2 3 1 2 3
```

**输出**：
```
LRRLLRRRRL
-1
```

**样例解释**：第一组数据中，生成的 $b = [4, 5, 3, 1, 2, 2, 1, 3, 5, 4]$，是回文数列。

## 解题思路

### 第一步：回文对称性分析

回文串的核心性质是**对称配对**：第 1 个和第 $2n$ 个元素相同，第 2 个和第 $2n-1$ 个相同，依此类推。这意味着每确定前半部分的一个操作，就能同步确定后半部分对应的操作。

```
结果串 b:  b1  b2  b3 ... bn  bn+1 ... b2n-1  b2n
            ↕   ↕   ↕           ↕     ↕      ↕
           配对1 配对2 配对3     配对3  配对2  配对1

每步同时确定首尾两个位置的操作
```

### 第二步：首步选择与区间划分

第一步只有两种选择：取左端（`L`）或取右端（`R`）。由于要求字典序最小，优先尝试 `L` 分支，失败再尝试 `R` 分支。

以首步取 `L`（取 $a[1]$）为例：

1. $a[1]$ 必须与序列中另一个相同值 $a[k]$ 配对，构成回文的首尾
2. $a[1]$ 成为 $b$ 的第 1 个元素，$a[k]$ 成为 $b$ 的第 $2n$ 个元素
3. 配对位置 $k$ 将剩余序列划分为两段：
   - **$c$ 段**：$[2, k-1]$（$a[1]$ 和 $a[k]$ 之间的部分，从左到右管理）
   - **$d$ 段**：$[k+1, 2n]$（$a[k]$ 右侧的部分，从右到左管理）

```
原序列:  a1  a2  a3 ... a(k-1)  ak  a(k+1) ... a(2n)
         ↑    ←——— c 段 ———→  ↑    ←——— d 段 ———→
        首步取走            配对取走

c 段: ctop → ... ← cback     (正向管理)
d 段: dback → ... ← dtop     (反向管理，dtop 从 2n 向左)
```

### 第三步：贪心匹配迭代

此后每步在前端（$c$ 段左端 `ctop` 或 $d$ 段左端 `dtop`）和后端（$c$ 段右端 `cback` 或 $d$ 段右端 `dback`）中寻找相等的元素对。共有四种匹配条件：

| 前端取自 | 后端取自 | 前端操作 | 后端操作 | 条件 |
|---|---|---|---|---|
| $c$ 段左端 | $c$ 段右端 | `L` | `L` | $a[\text{ctop}] = a[\text{cback}]$ 且 $\text{ctop} \ne \text{cback}$ |
| $c$ 段左端 | $d$ 段右端 | `L` | `R` | $a[\text{ctop}] = a[\text{dback}]$ 且 $d$ 段非空 |
| $d$ 段左端 | $c$ 段右端 | `R` | `L` | $a[\text{dtop}] = a[\text{cback}]$ 且 $c$ 段非空 |
| $d$ 段左端 | $d$ 段右端 | `R` | `R` | $a[\text{dtop}] = a[\text{dback}]$ 且 $\text{dtop} \ne \text{dback}$ |

**贪心策略**：每步优先尝试前端取 $c$ 段（操作 `L`），因为 `L` 字典序小于 `R`。若 $c$ 段前端无法与任何后端匹配，才尝试 $d$ 段前端（操作 `R`）。若两者均无法匹配，则该分支失败。

### 第四步：对称性压缩

利用回文对称性，每确定前端第 `idx` 步的操作，同步确定后端第 $2n - \text{idx} + 1$ 步的操作。这样把 $2n$ 步的操作压缩为 $n$ 步迭代，每步同时填入两个位置。

### 第五步：两分支覆盖

- **`fn_L` 分支**：首步取 $a[1]$（左端），搜索 $a[1]$ 的配对位置 $k$，划分 $c = [2, k-1]$，$d = [k+1, 2n]$
- **`fn_R` 分支**：首步取 $a[2n]$（右端），搜索 $a[2n]$ 的配对位置 $k$，划分 $c = [1, k-1]$，$d = [k+1, 2n-1]$

由于 `L` 字典序小于 `R`，优先尝试 `fn_L`。若失败则尝试 `fn_R`。若均失败则无解，输出 $-1$。

## 逐行代码解析

### 全局变量与初始化

```cpp
vector<int> a;
vector<char> s;
int n;

void init()
{
    a.clear(); s.clear();
    a.resize(2 * n + 5);
    s.resize(2 * n + 5);
}
```

- `a`：输入序列，1-based 下标
- `s`：操作方案字符串，`s[i]` 表示第 $i$ 步的操作（`L` 或 `R`）
- `init()`：多组数据时清空并重新分配，多预留 5 个位置防越界

### fn_L 分支（首步取左端）

```cpp
bool fn_L()
{
    int k = 2;
    s[1] = 'L', s[2 * n] = 'L';          // 首尾操作均为 L
    while (a[1] != a[k]) ++k;            // 找 a[1] 的配对位置 k
    int ctop = 2, cback = k - 1;         // c 段：[2, k-1]
    int dtop = 2 * n, dback = k + 1;     // d 段：[k+1, 2n]（反向）
    int idx = 2;                          // 当前填充位置（从第 2 步开始）
```

- `s[1] = 'L'`：首步取左端
- `s[2n] = 'L'`：末步取走配对元素 $a[k]$，由于 $a[k]$ 在 $a[1]$ 右侧，末步也是从左端取（此时 $a[k]$ 已成为剩余序列的左端），因此操作为 `L`
- `while (a[1] != a[k]) ++k`：线性搜索 $a[1]$ 的配对位置（题目保证存在）
- `dtop = 2n`：$d$ 段从右端开始，向左收缩

```cpp
    while (ctop <= cback || dtop >= dback)
    {
        // 条件1：c 段前端匹配 c 段后端 或 c 段前端匹配 d 段后端
        if ((ctop <= cback) && ((a[ctop] == a[cback] && ctop != cback)
            || (a[ctop] == a[dback] && dtop >= dback)))
        {
            s[idx] = 'L';                 // 前端取 c 段左端
            if (a[ctop] == a[cback] && ctop != cback) {
                s[2 * n - idx + 1] = 'L';  // 后端取 c 段右端
                --cback;
            } else {
                s[2 * n - idx + 1] = 'R';  // 后端取 d 段右端
                ++dback;
            }
            ++ctop;
        }
```

- 条件 1 处理前端取 $c$ 段（操作 `L`）的情况
- `ctop <= cback`：确保 $c$ 段非空
- 子条件 A：`a[ctop] == a[cback]` 且 `ctop != cback`——$c$ 段内部首尾配对，后端也取 $c$ 段（`L`）
- 子条件 B：`a[ctop] == a[dback]` 且 `dtop >= dback`——$c$ 段前端与 $d$ 段后端配对，后端取 $d$ 段（`R`）
- `ctop != cback`：防止 $c$ 段只剩一个元素时自匹配

```cpp
        // 条件2：d 段前端匹配 c 段后端 或 d 段前端匹配 d 段后端
        else if ((dtop >= dback) && ((a[dtop] == a[cback] && ctop <= cback)
            || (a[dtop] == a[dback] && dtop != dback)))
        {
            s[idx] = 'R';                 // 前端取 d 段左端
            if (a[dtop] == a[cback] && ctop <= cback) {
                s[2 * n - idx + 1] = 'L';  // 后端取 c 段右端
                --cback;
            } else {
                s[2 * n - idx + 1] = 'R';  // 后端取 d 段右端
                ++dback;
            }
            --dtop;
        }
        else return false;                // 无匹配，分支失败
        ++idx;
    }
    return true;
}
```

- 条件 2 处理前端取 $d$ 段（操作 `R`）的情况，结构与条件 1 对称
- 若两个条件都不满足，说明当前状态下无法继续配对，该分支失败

### fn_R 分支（首步取右端）

```cpp
bool fn_R()
{
    int k = 1;
    s[1] = 'R', s[2 * n] = 'L';          // 首步 R，末步 L
    while (a[2 * n] != a[k]) ++k;        // 找 a[2n] 的配对位置 k
    int ctop = 1, cback = k - 1;         // c 段：[1, k-1]
    int dtop = 2 * n - 1, dback = k + 1; // d 段：[k+1, 2n-1]（反向）
    int idx = 2;
    // 主循环与 fn_L 完全相同
    ...
}
```

- `s[1] = 'R'`：首步取右端 $a[2n]$
- `s[2n] = 'L'`：末步取走配对元素 $a[k]$，此时 $a[k]$ 已成为剩余序列的左端，操作为 `L`
- 搜索方向变为从左找 $a[2n]$ 的配对位置
- $d$ 段右边界变为 $2n-1$（因为 $a[2n]$ 已被取走）
- 主循环逻辑与 `fn_L` 完全相同

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int T;
    cin >> T;
    while (T--)
    {
        cin >> n;
        init();
        for (int i = 1; i <= 2 * n; i++) cin >> a[i];
        if (fn_L()) {                    // 先尝试 L 分支（字典序更小）
            for (int i = 1; i <= 2 * n; i++) cout << s[i];
            cout << '\n';
        }
        else if (fn_R()) {               // L 失败则尝试 R 分支
            for (int i = 1; i <= 2 * n; i++) cout << s[i];
            cout << '\n';
        }
        else cout << -1 << '\n';         // 两分支均失败，无解
    }
    return 0;
}
```

- 优先尝试 `fn_L`（字典序更优），失败则尝试 `fn_R`
- `fn_R` 会从头覆盖 `s` 数组，因此不需要额外重置
- 两个分支均失败则输出 $-1$

## 复杂度分析

### 时间复杂度

| 操作 | 复杂度 | 说明 |
|---|---|---|
| 配对位置搜索 | $O(n)$ | 线性扫描找 $a[1]$ 或 $a[2n]$ 的配对位置 |
| 贪心匹配主循环 | $O(n)$ | 每步推进 `ctop` 或 `dtop`（以及 `cback`/`dback`），总共 $n$ 步 |
| 两分支各执行一次 | $O(n)$ | 两个分支各 $O(n)$，常数倍 |
| **总计** | $O(n)$ | 线性时间 |

### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 序列数组 `a` | $O(n)$ | 长度 $2n+5$ |
| 操作数组 `s` | $O(n)$ | 长度 $2n+5$ |
| **总计** | $O(n)$ | 线性空间 |

## 常见陷阱与注意事项

1. **`ctop != cback` 的遗漏**
   - 当 $c$ 段只剩一个元素时（`ctop == cback`），该元素不能同时作为前端和后端匹配自身
   - 条件中 `ctop != cback` 防止此情况，遗漏会导致回文串中某位被重复使用

2. **$d$ 段的方向**
   - $d$ 段从右向左管理（`dtop` 从 $2n$ 递减，`dback` 从 $k+1$ 递增）
   - 与 $c$ 段方向相反，混淆方向会导致取错元素

3. **两分支的独立性**
   - `fn_L` 失败后需完全重置状态再执行 `fn_R`
   - `fn_R` 会从头覆盖 `s` 数组，因此不会残留 `fn_L` 的数据

4. **配对位置不存在**
   - 题目保证每个数恰好出现两次，`while (a[1] != a[k]) ++k` 必然终止
   - 若输入不满足此条件，可能越界

5. **多组数据的初始化**
   - 每组测试数据必须调用 `init()` 清空 `a` 和 `s`，否则上一组残留数据污染当前结果

6. **字典序最小的保证**
   - 优先尝试 `fn_L`（首步 `L` 字典序小于 `R`）保证全局字典序最小
   - 在 `fn_L` 内部，每步优先尝试前端取 $c$ 段（`L`），进一步保证局部字典序最小
   - 这两层贪心保证了最终方案是所有合法方案中字典序最小的

## 对比与扩展

| 方法 | 时间 | 空间 | 特点 |
|---|---|---|---|
| **双栈分段贪心（本算法）** | $O(n)$ | $O(n)$ | 利用对称性压缩为 2 分支，贪心匹配 |
| 暴力搜索 | $O(2^{2n})$ | $O(n)$ | 枚举所有操作序列，超时 |
| 双向 BFS | $O(n \cdot 4^n)$ | $O(n)$ | 搜索所有合法操作，仍指数级 |
| 记忆化 DFS | $O(n^2)$ | $O(n^2)$ | 记忆化区间状态，可行但较慢 |

### 扩展

- **推广到元素出现次数不恰好为两次**：需更复杂的配对策略，可能需要预处理所有配对关系
- **推广到取数后放入多个栈**：双段贪心思想可扩展到多段区间配对
- **对称构造问题**：双段贪心思想适用于其他需要对称配对的构造问题，如括号匹配、镜像序列等$AKB606$, '字符串', array['贪心', '回文构造', '双栈', '模拟', 'CSP-S', '构造'], null, '普及+/提高−', 'problem');

do $$
declare
    v_missing text;
begin
    select string_agg(distinct s.author_name, '、') into v_missing
    from _akb_seed_columns s
    left join public.profiles p on p.nickname = s.author_name
    where p.id is null;

    if v_missing is not null then
        raise exception '缺少作者 profile：%', v_missing;
    end if;
end $$;

insert into public.columns (
    owner_id, column_key, column_name, content, tags, category, parent_key,
    relations, difficulty, kind, status
)
select
    p.id, s.column_key, s.column_name, s.content, s.tags, s.category,
    s.parent_key, '[]'::jsonb, s.difficulty, s.kind, 'published'
from _akb_seed_columns s
join public.profiles p on p.nickname = s.author_name
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    content = excluded.content,
    tags = excluded.tags,
    category = excluded.category,
    parent_key = excluded.parent_key,
    difficulty = excluded.difficulty,
    kind = excluded.kind,
    status = 'published',
    updated_at = now();

drop table if exists _akb_seed_columns;

commit;
