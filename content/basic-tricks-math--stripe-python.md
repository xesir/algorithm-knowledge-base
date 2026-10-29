---
id: basic-tricks-math
title: '数学与位运算技巧合集（GCD log / 曼哈顿互化 / 抽屉原理）'
category: '基础算法'
subcategory: '优化技巧'
tags: ['数学技巧', '位运算', '曼哈顿距离', '抽屉原理']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 1. $(★)$ GCD log

>  ***一个数最多做 log 次改变其值的 gcd。***

### 例 1.1 [HDU 5869. Different GCD Subarray Query](https://acm.hdu.edu.cn/showproblem.php?pid=5869)

> 给定长度为 $n$ 的正整数序列 $a$，$q$ 次查询，每次查询给定 $l,r$，求 $a_{l\sim r}$ 的所有子段的互不相同的 gcd 个数。  
> $1\le n,q\le 10^5,1\le a_i\le 10^6$。

由于在固定一个 $l$ 时，对于所有 $r$，互不相同的 $\gcd\limits_{i=l}^r\{a_i\}$ 是 $\log V$ 级别的。于是我们考虑预处理出来这些块，然后把询问离线下来用 BIT 维护处理即可。

时间复杂度 $O(n\log n\log V)$。

### 例 1.2 [QOJ 9426. Relearn through Review](https://qoj.ac/problem/9426)

> 给定长度为 $n$ 的正整数序列，可以最多一次对某个区间 $[l,r]$ 内的数 $a_{l\sim r}$ 都 $+k$，最大化 $\gcd\{a_i\}$。  
> $1\le n\le 3\times 10^5,1\le k,a_i\le 10^{18}$。

暴力枚举是 $O(n^2)$ 的。考虑到前缀 gcd 是单调不升的，可以划分成若干个块。而每一块显然只要钦定对块首进行枚举计算即可。由于块数是 $\log n$ 级别的，故时间复杂度 $O(n\log^2n)$。

### 练习 1
- [Luogu P5502. 最大公约数](https://www.luogu.com.cn/problem/P5502)
- [CF1632D. New Year Concert](https://codeforces.com/problemset/problem/1632/D)

---

## 2. $(★☆)$ 奇（偶）数位反转

> ***当要对 01 String 进行相邻同项操作时，可以考虑对奇（偶）数位取反，转化为相邻异项操作。***

### 例 2-1. [Atcoder TKPPC6-2 B. Replace to Order](https://atcoder.jp/contests/tkppc6-2/tasks/tkppc6_2_b)

> 给定长度为 $n$ 的由 `AB` 组成的字符串 $S,T$，对 $S$ 进行任意次操作，每次选择一个子串 `AA`（`BB`），将其翻转为 `BB`（`AA`）。求从 $S$ 变成 $T$ 的最小操作次数，或报告无解。  
> $2\le n\le 2\times 10^5$。

考虑翻转偶数位，这样操作就变成了每次交换相邻的 `AB`（`BA`）。于是贪心地钦定考虑每个 `A` 的相对顺序下位置变化即可。时间复杂度 $O(n)$。

### 例 2-2. [QOJ 9565. Birthday Gift](https://qoj.ac/problem/9565)

> 给定长度为 $n$ 的由 $\tt012$ 构成的字符串，对其进行任意次操作，每次可以将一个 $\tt2$ 改成 $\tt0$ 或 $\tt1$，或者删去一个子串 $\tt00$ 或 $\tt11$。最小化操作后字符串的长度。  
> $1\le n\le 2\times 10^5$。

考虑翻转偶数位，这样第二个操作就变成了删去一个子串 $\tt01$ 或 $\tt10$。那么最后整个串一定是全 $\tt0$ 或全 $\tt1$ 的形式。

设字符串原来 $\tt0,1,2$ 的个数为 $c_0,c_1,c_2$。由于删子串的操作不会改变 $|c_0-c_1|$，因此对 $c_2$ 和 $|c_0-c_1|$ 的大小关系讨论即可。时间复杂度 $O(n)$。

### 练习 2
- [AGC040 C. Neither AB nor BA](https://atcoder.jp/contests/agc040/tasks/agc040_c)
- [AGC004 F. Namori](https://atcoder.jp/contests/agc004/tasks/agc004_f)
- [Luogu P10367. Żarówki](https://www.luogu.com.cn/problem/P10367)
- [Luogu P10068. Line Town](https://www.luogu.com.cn/problem/P10068)
- [QOJ 7509. 01tree](https://qoj.ac/problem/7509)

---

## 12. $(★★)$ 曼哈顿与切比雪夫互化

> ***当坐标系内涉及曼哈顿距离（切比雪夫距离）但是不好做时，可以考虑将坐标系旋转 $\textbf{\textit{45\degree}}$ 转化成切比雪夫距离（曼哈顿距离）。***

### 例 12-1. [Luogu P3964. 松鼠聚会](https://www.luogu.com.cn/problem/P3964)

> 平面上有 $n$ 个点 $(x_i,y_i)$，选择一个点 $(x,y)$，最小化 $\sum\limits_{i=1}^n\max\{|x-x_i|,|y-y_i|\}$。  
> $1\le n\le10^5,0\le |x_i|,|y_i|\le 10^9$。

切比雪夫距离不太好做，考虑转化为曼哈顿距离。

重建坐标系，令 $(x',y')=\left(\dfrac{x+y}2,\dfrac{x-y}2\right)$，则原坐标系的切比雪夫距离，就是新坐标系的曼哈顿距离。

然后就随便做了。

时间复杂度 $O(n\log n)$。

### 例 12-2. [Atcoder Code Festival 2017 QualA D. Four Coloring](https://www.luogu.com.cn/problem/AT_code_festival_2017_quala_d)

> 构造一个 $n\times m$ 的含有 `RYGB` 四种颜色的网格，使得所有曼哈顿距离恰好为 $d$ 的一对网格颜色互不相同。  
> $1\le n,m\le 500,1\le d\le n+m-2$

很容易往黑白染色上想，但是 $d$ 为偶数时似乎没有什么前途。

重建坐标系，令 $(x',y')=(x+y,x-y)$，则原坐标系的曼哈顿距离，就是新坐标系的切比雪夫距离。

然后可以对每 $d\times d$ 划出来，内部填入一种颜色，外部交替形如下：
$$
\def\red{\color{red}\rule{10px}{10px}}
\def\yel{\color{yellow}\rule{10px}{10px}}
\def\grn{\color{limegreen}\rule{10px}{10px}}
\def\blu{\color{skyblue}\rule{10px}{10px}}
\begin{aligned}
\red\yel\red\yel\red\yel\red\yel\\[-6.5pt]
\blu\grn\blu\grn\blu\grn\blu\grn\\[-6.5pt]
\red\yel\red\yel\red\yel\red\yel\\[-6.5pt]
\blu\grn\blu\grn\blu\grn\blu\grn\\[-6.5pt]
\red\yel\red\yel\red\yel\red\yel\\
\end{aligned}
$$
时间复杂度 $O(nm)$。

### 练习 12
- [Luogu P5098. Cave Cows 3 ](https://www.luogu.com.cn/problem/P5098)
- [Luogu P3439. MAG-Warehouse](https://www.luogu.com.cn/problem/P3439)
- [Luogu P2906. Cow Neighborhoods G](https://www.luogu.com.cn/problem/P2906)
- [Luogu P5193. 炸弹](https://www.luogu.com.cn/problem/P5193)
- [Luogu P4648. pairs 动物对数](https://www.luogu.com.cn/problem/P4648)
- [Luogu P7561. 道路の建設案 \(Road Construction\)](https://www.luogu.com.cn/problem/P7561)

---

## 22. $(★★☆)$ 序列值域转 01

> ***存在一个阈值 $\bm x$，要对 $\exbm{≤x}$ 的和 $\exbm{>x}$ 的操作时，可以考虑将 $\exbm{≤x}$ 的变为 $\bm 0$，$\exbm{>x}$ 的变为 $\bm 1$。***

### 例 22-1. [Luogu P2824. 排序](https://www.luogu.com.cn/problem/P2824)

> 给定一个 $1\sim n$ 的排列，$m$ 次操作，每次可以对一个下标区间在 $[l,r]$ 的数进行升序（降序）排序，所有操作结束后查询位置 $q$ 上的数。  
> $1\le n,m\le 10^5,1\le q\le n$。

正常的排序显然是不行的，考虑 $\trick{22}$，若转化成 $01$ 序列的排序，那么我们可以直接统计 $01$ 个数后区间覆盖。

将操作离线下来，考虑二分答案。假设现在二分的答案为 $\text{mid}$，那么我们就把 $\le\text{mid}$ 的设为 $0$，$>\text{mid}$ 的设为 $1$，然后用线段树维护过程，最终位置 $q$ 的数为 $0$ 就是合法的。

时间复杂度 $O(m\log^2n)$。

---

## 32. $(★☆)$ 精度舍弃

> ***在某些情况下，计算时可以舍弃对最终答案没有较大影响的、精度较高的数。***

### 例 32-1. [Luogu P11918. 考试 / Egzamin](https://www.luogu.com.cn/problem/P11918)

> 一共 $n$ 道小题，第 $i$ 小题有 $p_i$ 的概率答对，$1-p_i$ 的概率答错。答对加一分，打错扣一分。每道题可以自由选择是否作答，最大化答对至少 $t$ 道题的概率。精度 $10^{-6}$。  
> $1\le t\le n\le 5\times10^4,0\le p_i\le 1$，$p_i$ 的精度为 $10^{-9}$。

首先有一件显然的事情是我们降序 $p_i$ 后会选择一段前缀。

然后我们有一个朴素的 dp，$f_{i,j}$ 表示前 $i$ 个小题得 $j$ 分的概率。转移方程 $f_{i,j}=f_{i-1,j-1}\cdot p_i+f_{i-1,j+1}
\cdot(1-p_i)$。

直接做是 $O(n^2)$ 的。那我们实际发现，由于一次选择是二项分布的，然后随着 $n$ 的增长，会呈现一个正态分布，那么区间两侧会有相当一部分概率很小的状态，那么由于这里对答案已经没有影响了，我们钦定一个 $\varepsilon$ 直接舍弃 $\le\varepsilon$ 的即可。然后状态数就够了。沉石鱼惊旋说状态数是在 $O(n\sqrt{\ln\varepsilon^{-1}})$ 级别的。

### 例 32-2. [CF618G. Combining Slimes](https://codeforces.com/problemset/problem/618/G)
> 给定一个长度为 $n$ 的网格。现在在网格上做操作。每次从右端向左压入一个数，有 $m$ 的概率为 $1$，$1-m$ 的概率为 $2$。当有两个相邻的 $x$ 时，会向左合并成一个 $x+1$。求直到无法操作时网格所有数之和的期望。精度需要 $10^{-4}$ 的相对误差。
>
> $1\le n\le 10^9$，$10^{-9}\le m\le 1$。

首先根据期望的线性性，答案即为所有格子的期望之和。

设 $a_{i,j}$ 表示对于一个长度为 $i$ 的网格，其最左侧的数为 $j$ 的概率。那么转移需要前两个都出现 $j-1$，即有 $a_{i,j}=a_{i,j-1}\cdot a_{i-1,j-1}$。

设 $p_{i,j}$ 表示对于一个长度为 $i$ 的网格，其最左侧的数为 $j$，且 $j$ 不会被合并的概率。那么左侧第二个数必须不能是 $j$，所以有 $p_{i,j}=a_{i,j}\cdot(1-a_{i-1,j})$。

设 $f_{i,j}$ 表示最终的网格中**最右侧** $i$ 位中最左侧的数为 $j$ 时的期望和。考虑最终网格内数的情况。由于每次都会尽可能合并，因此对于相邻的两个数 $x,y$，一定满足 $x>y\lor x=1$。

于是当 $j\neq 1$ 时，可以直接枚举这 $i$ 位中左边第二个数 $k\ (k<j)$ 求期望，可以得到转移方程：

$$
f_{i,j}=j+\dfrac{\sum\limits_{k=1}^{j-1}f_{i-1,k}\cdot p_{i-1,k}}{\sum\limits_{k=1}^{j-1}p_{i-1,k}}
$$

当 $j=1$ 时就可能有 $k>j$ 了。但这时 $j$ 之后第一个压入的数一定为 $2$。

于是再 dp。设 $b_{i,j}$ 表示对于一个长度为 $i$ 的网格，第一次压入的数为 $2$，且最左侧的数为 $j$ 的概率。由于我们只关心左侧第一个数，所以有 $b_{i,j}=b_{i,j-1}\cdot a_{i-1,j-1}$。

和上面同理，设 $q_{i,j}$ 表示对于一个长度为 $i$ 的网格，第一次压入的数为 $2$，且最左侧的数为 $j$，且它不会被合并的概率。同理有 $q_{i,j}=b_{i,j}\cdot(1-a_{i-1,j})$。

于是这时 $f_{i,j}$ 的转移也是同理的，即为：

$$
f_{i,j}=j+\dfrac{\sum\limits_{k=2}^{m}f_{i-1,k}\cdot q_{i-1,k}}{\sum\limits_{k=2}^{m}q_{i-1,k}}
$$

于是最终的答案即为 $\sum\limits_{i=1}^np_{n,i}\cdot f_{n,i}$。

非常漂亮的 dp！可是时间复杂度全爆了！！！

注意到题目要求的精度并不高，进一步发现：
- 当 $j$ 足够大的时候，dp 值很小，可以忽略不计。
- 当 $i$ 足够大时，$p_{n,i}$ 几乎不变化。

于是考虑钦定一个阈值 $k=50$，对于所有 dp 的第二维，我们只计算到下标 $k$。而最终的答案计算，我们也只需要求出 $\sum\limits_{i=1}^np_{k,i}\cdot f_{n,i}$。

于是我们现在只需要处理出 $f_{n,[1,k]}$ 就好了。矩阵快速幂加速计算即可。

时间复杂度 $O(k^3\log n)$。

---

## 35. $(★★★)$ 抽屉原理转化
> ***当存在类似 $\bm{\le\dfrac 1k\times s}$ 之类约束的方案限制时，可以考虑转化为构造 $\bm{k}$ 种不受该约束的方案，其受约束的权值和恰好为 $\bm{s}$。***

### 例 35-1. [CF2057G. Secret Message](https://codeforces.com/problemset/problem/2057/G)

> 给定一个 $n\times m$ 的由 $\tt\#$ 和 $\tt .$ 构成的矩阵，设所有 $\tt\#$ 连通块的大小和为 $s$，周长和为 $p$。要求构造一种标记不超过 $\dfrac15(s+p)$ 个 $\tt\#$ 格的方案，满足对于所有 $\tt\#$ 格，其要么被标记，要么有一个与其有一条公共边的格子被标记。
>
> $1\le n\times m\le 2\times10^6$。

这个题目限制给的 $\dfrac 15$ 很奇怪。

考虑 $\trick{35}$：如果我们不考虑这个限制的情况下构造出了 $5$ 种合法方案，并且这些方案的 $|S|$ 之和恰为 $s+p$，根据抽屉原理，其中必然存在至少一个方案满足 $|S|\le\dfrac15(s+p)$。

这也太牛了！那我们怎么找到这五个方案呢？

考虑一种十字形的密铺：

$$
\def\sq{\rule{10px}{10px}}
\def\sq{\rule{10px}{10px}}
\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\\[-3px]
\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\\[-3px]
\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\\[-3px]
\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\\[-3px]
\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\\[-3px]
\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\\[-3px]
\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\\[-3px]
\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\\[-3px]
\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\\[-3px]
$$

发现，如果我们选择了所有十字形中心，那么剩余未被影响到的格子就会在边上，我们在另外选择这些点即可。

注意到这些十字形中心的坐标 $(i,j)$ 满足 $(i+2j)\bmod5$ 同余，所以我们按照这种方式五染色，就能得到 $5$ 种合法方案了！

时间复杂度 $O(nm)$。

---

## 39. $(★★)$ 弦交错判相交

> ***可以通过圆所截出的弦是否相交（即在圆上的端点是否交错），来判断圆内是否有直线相交。***

### 例 39-1. [ABC263Ex. Intersection 2](https://atcoder.jp/contests/abc263/tasks/abc263_h)

> 给定 $n$ 条互不平行或重合的直线 $a_ix+b_iy+c_i=0$，$n$ 条直线总共会有 $\dfrac{n(n-1)}2$ 个交点（包含在同一个位置的点，即相同位置算不同的点），求距离原点第 $k$ 近的交点的欧几里得距离。
>
> $2\le n\le 5\times 10^4,1\le k\le \dfrac{n(n-1)}2,0\le|a_i|,|b_i|,|c_i|\le 10^3$。

考虑二分答案 $r$，此时问题就变成了圆 $x^2+y^2=r^2$ 内的交点数量。

运用 $\trick{39}$，就变成了圆内相交弦的对数。

将所有圆上的交点求出来后极角排序并离散化，按照更小的端点升序排序弦，做扫描线，用 BIT 维护区间内更大的端点的个数即为相交弦数量。

时间复杂度 $O(n\log n\log V)$。

### 例 39-2. [CF607E. Cross Sum](https://codeforces.com/problemset/problem/607/E)

> 给定 $n$ 条互不重合的直线 $y=\dfrac{k_i}{1000}x+\dfrac{b_i}{1000}$，两条不平行的直线之间会有一个交点（相同位置的交点多次计数），求距离点 $\left(\dfrac p{1000},\dfrac q{1000}\right)$ 前 $k$ 近的交点的欧几里得距离之和。
>
> $2\le n\le 5\times 10^4 $，$1\le k\le\min\left\{3\times10^7,\dfrac{n(n-1)}{2}\right\}$，$0\le|k_i|,|b_i|,|p|,|q|\le10^6$。

同上一题类似，二分后转化成圆上端点的情况。

由于交点数只要到 $m$，可以使用线段树套 vector 维护。

时间复杂度 $O(n\log n\log V+m)$。

---
