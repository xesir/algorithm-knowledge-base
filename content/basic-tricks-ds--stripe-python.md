---
id: basic-tricks-ds
title: '数据结构技巧合集（倍增并查集 / 单侧递归线段树 / BIT 倍增）'
category: '基础算法'
subcategory: '优化技巧'
tags: ['数据结构技巧', '倍增并查集', '线段树', 'BIT']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 4. $(★★★)$ 倍增优化并查集

> ***当对两个区间内的点顺次合并时，由于并查集的合并满足结合律，因此可以类似 st 表地倍增优化连边。***

### 例 4-1. [Luogu P3295. 萌萌哒](https://www.luogu.com.cn/problem/P3295)

> 一个长度为 $n$ 的正整数 $S$，有 $m$ 个形如 $S[l_{i_1}:r_{i_1}]=S[l_{i_2}:r_{i_2}]$ 的要求，求满足所有要求的互不相同的 $S$ 有多少个。  
> $1\le l_{i_1},r_{i_1},l_{i_2},r_{i_2}\le n\le 10^5,1\le m\le 10^5,r_{i_1}-l_{i_1}=r_{i_2}-l_{i_2}$。

由于并查集的合并满足结合律，因此考虑将区间 $[l,r]$ 类似 st 表地，拆成 $[l,l+2^k-1],[r-2^k+1,r]$ 两个长度为 $2^k$ 的区间。于是我们可以开 $\log n$ 个并查集，第 $j$ 个就是 $\text{fa}_{i,j}$，表示区间 $[i,i+2^k-1]$ 的父亲区间。

于是我们可以处理完后从上往下传信息（即继续拆分区间合并）即可。最后传到 $\text{fa}_{i,0}$ 时，记有 $c$ 个不同的父亲，由于第一位不能取 $0$，答案即为 $9\times 10^{c-1}$。时间复杂度 $O(n\log n\ \alpha(n))$。

### 练习 4
- [Luogu P12736. 圣诞灯链 Christmas chain](https://www.luogu.com.cn/problem/P12736)

---

## 11. $(★★★)$ 单侧递归线段树

> ***线段树区间合并信息不能直接做而需要满足一定关系时，可以考虑递归合并。***

### 例 11-1. [Luogu P4198. 楼房重建](https://www.luogu.com.cn/problem/P4198)

> 在平面的横坐标为 $i\in[1,n]$ 的地方，有线段 $(i,0)-(i,H_i)$，初始 $H_i=0$。$m$ 次修改，每次修改一个 $H_i$，并查询从 $(0,0)$ 最多能看到多少线段。  
> $1\le n,m\le10^5,1\le H_i\le 10^9$。

单侧递归线段树模板。

考虑用线段树维护答案，但是上传信息不好处理。

下面令 $\text{maxl}_S$ 表示区间 $S$ 中最多可看到的楼房数量，$\text{maxs}_S$ 表示区间 $S$ 中的最大斜率。

首先对于区间 $[l,r]$，其左区间的信息一定是会在这个区间里（由题意可得）。

考虑递归处理右区间的情况，并传入该区间的值所必须要大于的最小值 $x$。

- 若 $l=r$，则返回 $[a_r>x]$；
- 将区间划分成 $L,R$ 两段：
  - 若 $\text{maxs}_L\le x$，那么 $L$ 不会对答案有贡献，递归处理 $R$；
  - 若 $\text{maxs}_L>x$，那么递归处理 $L$，并加上 $R$ 的贡献。

若中途遇到一些不会对答案产生贡献的情况就不用考虑，直接跳出即可。

时间复杂度 $O(n\log^2n)$。

---

## 13. $(★★★)$ 直方图转笛卡尔树

> ***在一个直方图上操作时，可以考虑将其横向划分成若干个极大的矩形，建立笛卡尔树。***

### 例 13-1. [Luogu P6453. PERIODNI](https://www.luogu.com.cn/problem/P6453)

> 给定一个宽 $n$ 高分别为 $a_i$ 的格点直方图，要求在格子内放入恰好 $k$ 颗棋子，要求任意两颗棋子如果共行（列），棋子之间应当有超过 $1$ 个极长连续段。求放置方案数，对 $10^9+7$ 取模。  
> $1\le n,k\le 500,1\le a_i\le 10^6$。

考虑一个直方图：
$$
\rule{10px}{10px}\rule{10px}{40px}\rule{10px}{30px}\rule{10px}{50px}\rule{10px}{10px}\rule{10px}{30px}\rule{10px}{20px}
$$
对其进行横向划分：

$$
\def\red{\color{red}}
\def\org{\color{orange}}
\def\ord{\color{orangered}}
\def\yel{\color{gold}}
\def\grn{\color{limegreen}}
\def\skb{\color{skyblue}}
\def\blu{\color{blue}}
\def\pur{\color{purple}}
\def\pnk{\color{pink}}
\def\wht{\color{white}}
\def\r#1#2{\rule{#1px}{#2px}}
\begin{array}{c}
\quad\red\r{10}{10}\quad\ord\r{10}{20}\quad\quad\quad\\[-3.5pt]
\quad\org\r{30}{10}\quad\yel\r{10}{10}\quad\\[-3.5pt]
\quad\org\r{30}{10}\quad\grn\r{20}{10}\\[-3.5pt]
\skb\r{70}{10}
\end{array}
$$
从下往上，根据它们的相连关系，可以建出笛卡尔树。

然后考虑 dp。设 $f_{x,i}$ 表示以 $x$ 为根的子树放了 $i$ 颗棋子的方案数，$g_{x,i}$ 表示以 $x$ 为根的子树但不包含 $x$，放了 $j$ 颗棋子的方案数。记 $\text{lson}_x,\text{rson}_x$ 分别表示 $x$ 的左右儿子，$h_x,w_x$ 分别为节点 $x$ 对应的矩形的高、宽，则有：
$$
g_{x,i}=\sum\limits_{j=0}^if_{\text{lson}_i,j}\cdot f_{\text{rson}_i,i-j}\\
f_{x,i}=\sum\limits_{j=0}^i\binom{h_x}{i-j}\cdot\binom{w_x-j}{i-j}\cdot(i-j)!\cdot g_{x,j}
$$
时间复杂度 $O(nk^2+n^2)$。

### 练习 13
- [AGC041 F. Histogram Rooks](https://atcoder.jp/contests/agc041/tasks/agc041_f)

---

## 15. $(★★☆)$ BIT 倍增

> ***当要做二分套 BIT 时，有的时候由于有很多重复计算的部分，因此可以利用其转成一个 BIT 上倍增的过程。***

### 例 15-1. [Luogu P6619. 冰火战士](https://www.luogu.com.cn/problem/P6619)
> 有两个二元组集合 $A,B$，会进行共 $q$ 次插入和删除二元组 $(x,y)$ 的操作，每次操作完都要钦定一个 $k$，令 $f(k)=\sum\limits_{\substack{(x,y)\in A\\x\le k}}y,g(k)=\sum\limits_{\substack{(x,y)\in B\\x\ge k}}y,w(k)=\min\left(f(k),g(k)\right)$，输出 $2w_{\max}(k)$ 和 $\max\{k\mid w(k)=w_{\max}(k)\}$。  
> $1\le q\le 2\times10^6,1\le x,\sum y\le 2\times 10^9$。

首先一个简单的观察是 $w(k)$ 是一个单峰函数，但是有不变的段，不能三分。

不难想到可以先二分出一个 $k_0$ 满足 $f(k_0)<g(k_0),f(k_0+1)\ge g(k_0+1)$，再找到 $k_1=\max\{k\mid g(k)=g(k_1+1)\}$。这样答案必然是 $k_0,k_1$ 中的一个。

这个过程直接二分套 BIT 是 $O(q\log^2q)$ 的，考虑优化。

注意到我们在计算前后缀和时有很多重复使用的段。由于 BIT 的节点 $x$ 存的是 $[x-\text{lowbit}(x)+1,x]$ 的信息，所以按二进制位从高到低枚举，这样倍增就和原来的二分等价了。中间求前缀和的过程我们就直接记一个当前的和，然后累加即可。

时间复杂度 $O(q\log q)$。

---

## 26. $(★★☆)$ 分块 ST 表

> ***当因为空间、时间等问题 st 表无法直接处理时，可以考虑分块后再上 st 表处理。***

### 例 26-1. [Luogu P3793. 由乃救爷爷](https://www.luogu.com.cn/problem/P3793)

> 给定长度为 $n$ 的正整数序列 $a$，$m$ 次询问，每次询问给定区间 $[l,r]$，求 $\max\limits_{i=l}^r\{a_i\}$。  
> $1\le n,m\le 2\times 10^7,0\le a_i< 2^{31},5\sec,500\text{ MB}$，数据随机。

虽然是四毛子板子，但是可以考虑一个更为简洁的东西，也是官方做法。

普通的 st 表在这里的瓶颈在于空间 $O(n\log n)$ 开不下。

考虑按块长 $B$ 分块，这样一个询问就可以拆成后缀最大值、块间最大值、前缀最大值三个子问题。我们预处理块间 st 表和块内的前后缀最大值即可。

空间复杂度 $O\left(\dfrac nB\log\dfrac nB\right)$，时间复杂度 $O\left(\dfrac nB\log\dfrac nB+q\right)$，取 $B=\log n$ 时为 $O(n)$。

当然，询问会有区间在同一块内的情况。这种情况期望下是 $O\left(\dfrac{B^2}n\right)$ 的。结合上述内容 $B$ 可以取 $[\log n,\sqrt n]$，对应的期望时间复杂度为 $O(n)$ 到 $O(m)$ 左右。

### 例 26-2. [Luogu P11750. 谢谢您。](https://www.luogu.com.cn/problem/P11750)

> 给定一个长度为 $n$ 的正整数序列 $a$，和 $m$ 个区间 $[l_i,r_i]$。$q$ 次询问 $x,y,k$，求 $\max\limits_{i=x}^y\left\{\sum\limits_{j=l_i}^{r_i}[a_j=k]\right\}$。
>
> $1\le n,m,q\le 2\times10^5$，$1\le a_i,k\le n$，$1\le l_i\le r_i\le n$，$1\le x\le y\le m$，$1\sec,64\text{ MB}$。

下面令 $m$ 个给定的区间为「关键区间」，$q$ 个询问的区间为「询问区间」。

看到出现次数，考虑根号分治。设 $c_k=\sum\limits_{i=1}^n[a_i=k]$。

- $c_k>\sqrt n$，此时最多只有 $\sqrt n$ 个 $k$ 满足这样的要求。

  对于这种情况，将每个询问 $(l,r,k)$ 挂在 $k$ 上，枚举所有符合要求的 $k$，直接前缀和处理每个关键区间内 $k$ 的出现次数，然后 $O(m)$ 分块预处理每个块内的最大值，这样每次询问可以做到 $O(\sqrt m)$。总时间复杂度为 $O((n+m)\sqrt n+q\sqrt m)$。

- $c_k\le\sqrt n$，这种情况比较难处理。

  考虑将每个询问 $(l,r,k)$ 挂在 $k$ 出现的所有位置上。然后从 $1$ 到 $n$ 扫描线，设当前扫到 $i$。

  考虑维护一个激活关键区间的序列 $b$，初始全 $0$。若一个关键区间满足 $i\in[l_j,r_j]$，则将这个区间激活，在 $b$ 上体现为执行 $b_j\gets r_j$。然后处理每个挂在 $i$ 上的询问区间 $[l,r]$，查询 $r_{\max}=\max\limits_{j=l}^r\{b_j\}$。若 $r_{\max}\ge i$，那么代表着该询问的答案至少可以更新为 $[i,r_{\max}]$ 中 $k$ 的出现次数。

  然后得到的这个 $r_{\max}$ 再在 $k$ 出现的所有位置构成的序列上二分一下就可以的得到当前询问得到的 $k$ 的出现次数，就可以更新答案。可以发现我们这样更新答案一定是可以取到最终答案的。

  对于每种 $k$ 来说，其每个位置都要询问。如果用线段树维护 $b$，那么可以做到的时间复杂度为 $O(m\log m+q\sqrt n(\log m+\log\sqrt n))$，这不太能要。

  $b_j\gets r_j$ 可以看作 $b_j\gets\max(b_j,r_j)$，所以考虑维护 st 表进行更新。但直接暴力更新肯定没道理。
  将 $b$ 分块，维护块内以及块间的 st 表。那么对于块内，如果需要修改维护 $[p,p+2^d)$ 的最大值的位置，则必然满足 $p\le j<p+2^d$，即 $j-2^d<p\le j$。也就是一种 $d$ 的贡献至多为 $2^d$，所以总贡献为 $O(\sum 2^d)=O(2^{\log\sqrt m})=O(\sqrt m)$。块间是同理的。这样就是修改 $O(\sqrt m)$，查询 $O(1)$。

  那么这样时间复杂度就变成 $O(m\sqrt m+q\sqrt n\log\sqrt n)$。

剩余的工夫就是大力卡常了。

---

## 38. $(★)$ Trie 交换子树

> ***可以通过 Trie 上交换子树来实现序列值域上的一些操作。***

### 例 38-1. [AGC044C. Strange Dance](https://www.luogu.com.cn/problem/AT_agc044_c)

> 编号为 $0\sim 3^n$ 的人围成一圈。现在有一个操作序列 $S$，有两种操作：
>
> - $S_i=\tt S$：表示对于第 $x$ 个人，他会走到第 $y$ 个位置，其中 $y$ 是 $x$ 三进制下每个数位 $\tt 12$ 翻转后得到的数。
> - $S_i=\tt R$：表示对于第 $x$ 个人，他会走到第 $(x+1)\mod 3^n$ 个位置。
>
> 问最后每个人所在的位置。
>
> $1\le n\le 12,1\le |S|\le 2\times 10^5$。

考虑把问题放到 trie 上处理，这里我们**从低到高**建树。

发现其实 $\tt S$ 对应着将每个节点的 $1,2$ 两个儿子交换，我们可以打懒标记处理。

而 $\tt R$ 操作，我们考虑从最低位向高位处理。发现对于同一个节点的三个儿子，我们容易想到轮换儿子，而变成 $0$ 的子树还需要处理进位，这一点我们递归下去即可。

时间复杂度 $O(3^n+n|S|)$。

### 例 38-2. [CF1515H. Phoenix and Bits](https://codeforces.com/problemset/problem/1515/H)

> 给定大小为 $n$ 的集合，$q$ 次操作或查询：
>
> - $\texttt{1}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位与 $z$。
> - $\texttt{2}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位或 $z$。
> - $\texttt{3}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位异或 $z$。
> - $\texttt{4}\ x\ y$：查询 $[x,y]$ 内有多少个不同的数。
>
> $1\le n\le 2\times10^5,1\le q\le 10^5$。

考虑使用动态开点权值线段树，但本质和 01 trie 类似。

对区间操作时，我们利用线段树分裂截出来这段，最后再合并回去。

xor 我们可以利用同上一个例题一样，直接交换左右子树即可。

对于 and，我们可以用 xor 和 or 代替。具体地，令 $S=2^{20}-1$，有 $x\text{\ and\ }y=((x\text{ xor }S)\text{ or }(y\text{ xor }S))\text{ xor }S$。

接下来只要考虑 or 即可。

我们相当于要对两个子树进行合并（只有一个子树是显然的），那么之间线段树合并即可。

时间复杂度 $O(n\log^2V)$，实际还有一点细节。

---
