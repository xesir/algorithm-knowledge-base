---
id: math-number-theory-basic
title: '数论基础（整除 / 约数 / gcd / 积性函数 / 取整）'
category: 数学
subcategory: 数论基础
subSubcategory: ''
tags: ["数论", "gcd", "快速幂", "龟速乘", "光速幂", "线性筛", "裴蜀定理", "模逆元"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-11-04
source: 'lker'
---

## 算法原理

![](https://cdn.luogu.com.cn/upload/image_hosting/omgjb4rx.webp)

数论是研究整数的数学。下面的所有变量都是整数。

**例题索引**：[B3634](https://www.luogu.com.cn/problem/B3634)、[P1029](https://www.luogu.com.cn/problem/P1029)、[P1072](https://www.luogu.com.cn/problem/P1072)、[P1226](https://www.luogu.com.cn/problem/P1226)、[U483926](https://www.luogu.com.cn/problem/U483926)、[U185835](https://www.luogu.com.cn/problem/U185835)、[P3383](https://www.luogu.com.cn/problem/P3383)、[P3951](https://www.luogu.com.cn/problem/P3951)、[P4549](https://www.luogu.com.cn/problem/P4549)、[P3811](https://www.luogu.com.cn/problem/P3811)、[P9774](https://www.luogu.com.cn/problem/P9774)。

本笔记按 lker 原文的顺序整理：先建立整除、gcd 与 lcm 的地基，再依次讨论快速幂、龟速乘、光速幂、线性筛、裴蜀定理、模逆元与威尔逊定理，并保留原文中的例题代码。原文中较简短的题解，在这里补上了推导过程；思路与结论保持原样。

### 一、整除、gcd 与 lcm

**引理 1（线性组合整除性）**：若 $d \mid a$ 且 $d \mid b$，则 $d \mid xa+yb$。

证明：设 $a=k_1d$，$b=k_2d$，则 $xa+yb=(xk_1+yk_2)d$，所以 $d \mid (xa+yb)$。证毕。

**引理 2**：$\gcd(a,b)=\gcd(b,a \bmod b)$。

证明：考虑证明 $a,b$ 的公约数集合等于 $b,a\bmod b$ 的公约数集合。设 $a=kb+r$。

- 若 $d\mid a$ 且 $d\mid b$，由引理 1，$d\mid (a-kb)$，即 $d\mid r$，充分性得证；
- 若 $d\mid r$ 且 $d\mid b$，由引理 1，$d\mid (r+kb)$，即 $d\mid a$，必要性得证。

两组数的公约数集合完全相同，所以最大公约数也一致。证毕。

**引理 3**：$a$ 和 $0$ 的最大公约数是 $a$。

证明：$0$ 的约数是所有非零整数，$a$ 的最大约数是自己，所以二者最大公约数为 $a$。

由引理 2 得到欧几里得算法：

$$
\gcd(a,b)=\gcd(b,a\bmod b),
$$

不断迭代直到 $b=0$，此时返回 $a$ 即可。

**复杂度**：$O(\log V)$。

复杂度证明：最坏情况是每次商 $k=1$，此时 $(a,b)$ 变成 $(b,a-b)$，数值下降最慢。设某一步的两个数为 $(A,B)$，下一步是 $(B,A-B)$，再下一步是 $(A-B,2B-A)$；相邻两项之和按斐波那契方式增长。反过来从终止状态 $(g,0)$ 倒推，步数 $t$ 对应的最小数对是斐波那契数列的第 $t$ 项，而斐波那契数按 $\varphi^t/\sqrt5$ 指数增长，所以 $t=O(\log V)$。因此欧几里得算法的时间复杂度为 $O(\log V)$。

**引理 4（算术基本定理）**：对于一个整数 $a$，存在唯一的质因数分解

$$
a=\prod p_i^{\alpha_i}.
$$

**引理 5**：$\max(a,b)+\min(a,b)=a+b$。

**引理 6**：$\operatorname{lcm}(a,b)\cdot \gcd(a,b)=ab$。

证明：

$$
ab=\prod p_i^{\alpha_i+\beta_i},
$$

$$
\gcd(a,b)=\prod p_i^{\min(\alpha_i,\beta_i)},\qquad
\operatorname{lcm}(a,b)=\prod p_i^{\max(\alpha_i,\beta_i)}.
$$

由引理 5，

$$
\operatorname{lcm}(a,b)\cdot \gcd(a,b)
=\prod p_i^{\min(\alpha_i,\beta_i)+\max(\alpha_i,\beta_i)}
=\prod p_i^{\alpha_i+\beta_i}=ab.
$$

于是得到计算 $\operatorname{lcm}$ 的方法：

$$
\operatorname{lcm}(a,b)=\frac{ab}{\gcd(a,b)}.
$$

**例题：B3634**（求两个数的最大公约数和最小公倍数）。按上面的公式计算即可，注意答案可能超过 `int`，需要开 `long long`。代码见「逐行代码解析」。

### 二、P1029 最大公约数和最小公倍数问题

题意：给定 $x_0,y_0$，求满足 $\gcd(P,Q)=x_0$、$\operatorname{lcm}(P,Q)=y_0$ 的有序正整数对 $(P,Q)$ 的数量。

**引理 7**：若 $a\cdot b=x$，则必有 $\min(a,b)\le \sqrt{x}$。

证明：若反设 $a>\sqrt{x}$ 且 $b>\sqrt{x}$，则 $a\cdot b>x$，产生矛盾。证毕。

由引理 6，$PQ=x_0y_0$。因为 $P,Q$ 的地位对称，我们可以只枚举较小的那个，最后再根据 $P=Q$ 与否计算贡献：

- 枚举范围：$P$ 从 $x_0$ 到 $\sqrt{x_0y_0}$，步长为 $x_0$（因为 $P$ 必须是 $x_0$ 的倍数）；
- 令 $Q=\dfrac{x_0y_0}{P}$，先判断 $P\mid x_0y_0$，再判断 $\gcd(P,Q)=x_0$；
- 若 $P=Q$，这一对只算 $1$ 次；若 $P\ne Q$，则 $(P,Q)$ 与 $(Q,P)$ 都合法，贡献为 $2$。

复杂度：枚举次数约为 $\dfrac{\sqrt{x_0y_0}}{x_0}=\sqrt{\dfrac{y_0}{x_0}}$，每次判断 gcd 为 $O(\log V)$，因此总复杂度为 $O\!\left(\sqrt{\dfrac{y_0}{x_0}}\log V\right)$；原文把枚举次数记为 $n$，写作 $O(n\log V)$。代码见「逐行代码解析」。

### 三、P1072 Hankson 的趣味题

题意：给定 $a_0,a_1,b_0,b_1$，求满足

$$
\gcd(x,a_0)=a_1,\qquad \operatorname{lcm}(x,b_0)=b_1
$$

的正整数 $x$ 的个数。

关键观察：由 $\operatorname{lcm}(x,b_0)=b_1$ 可知 $x\mid b_1$，所以合法数字一定是 $b_1$ 的一个因数。于是从 $1$ 枚举到 $\sqrt{b_1}$：

- 若 $i\mid b_1$，则 $i$ 和 $b_1/i$ 都是候选；
- 对每个候选 $x$，检查 $\gcd(x,a_0)=a_1$ 且 $\operatorname{lcm}(x,b_0)=b_1$；
- 若 $i=b_1/i$，只检查一次，避免重复计数。

判断时可以先看 $a_1\mid x$（这是 $\gcd(x,a_0)=a_1$ 的必要条件），再用 `__gcd` 计算两个条件。复杂度为 $O(n\sqrt{V}\log V)$。代码见「逐行代码解析」。

### 四、P1226 快速幂

**引理 8**：

$$
a^b=
\begin{cases}
(a^2)^{\lfloor b/2\rfloor}, & b\bmod 2=0,\\[2pt]
(a^2)^{\lfloor b/2\rfloor}\cdot a, & b\bmod 2=1.
\end{cases}
$$

由引理 8，可以不停把指数除以二向下取整、底数自乘，并用一个变量累乘“指数为奇数时多出来的那个 $a$”。循环维护的不变量是“`ans` 乘上当前的 $a^b$ 等于原式”。当 $b$ 变成 $0$ 时，`ans` 就是答案。

复杂度：指数每次减半，最多减半 $\log b$ 次，所以为 $O(\log b)$。代码见「逐行代码解析」。

### 五、U483926 龟速乘

龟速乘用于在不溢出的情况下完成大数相乘，代价是牺牲部分时间复杂度。~~其实已经被 `__int128` 上位替代~~。

**引理 9**：

$$
ab=
\begin{cases}
2a\lfloor b/2\rfloor, & b\bmod 2=0,\\[2pt]
a+2a\lfloor b/2\rfloor, & b\bmod 2=1.
\end{cases}
$$

用一个变量维护“余 $1$ 时多出来的 $a$”之和，每次迭代 $b=\lfloor b/2\rfloor$、$a=2a$，并对 $p$ 取模。复杂度为 $O(\log b)$，复杂度证明与快速幂相同。代码见「逐行代码解析」。

### 六、U185835 光速幂

光速幂在固定底数 $a$ 和模数 $p$ 的情况下，可以做到 $O(1)$ 查询 $a^b\bmod p$。

核心思想是根号分治和同余类划分。记指数的值域为 $V$，取阈值 $B=\sqrt V$（实际实现中通常略微放大，不影响复杂度平衡，同时防止越界）。预处理：

$$
f_x=a^x=af_{x-1},\qquad g_x=a^{Bx}=g_1g_{x-1},\qquad g_1=f_B,
$$

其中 $x\le B$。查询时把 $b$ 划分为 $b=kB+r$，其中 $k=\lfloor b/B\rfloor$、$r=b\bmod B$，则

$$
a^b=a^{kB+r}=a^{kB}\cdot a^r=g_k\cdot f_r.
$$

于是 $O(B)$ 预处理、$O(1)$ 计算。代码中取 $B\approx 10^5$，注意本题模数是 $998244352$，不是 $998244353$。代码见「逐行代码解析」。

### 七、P3383 线性筛

质数指只有 $1$ 和自己两个因数的正整数，不包括 $1$ 本身；否则会破坏算术基本定理。

线性筛（欧拉筛）让每个合数只被它的最小质因数筛掉一次，从而做到 $O(n)$。做法：

1. 从小到大遍历 $i$；
2. 若 $i$ 没有被标记，则 $i$ 是质数，加入质数表；
3. 用当前已得到的质数 $p_j$ 去筛 $i\cdot p_j$，并令 $i\cdot p_j$ 的最小质因数为 $p_j$；
4. 当 $i\bmod p_j=0$ 时立刻退出内层循环，保证每个合数只被最小质因数筛一次。

为什么每个合数都会被筛到：设合数 $x=i\cdot p$，其中 $p$ 是 $x$ 的最小质因数。因为 $i\ge 2$，所以 $i<x$、$p<x$。如果枚举到 $x$ 之前就中途退出了，说明存在更小的质数 $p'$ 整除 $i$，即 $kp'p=x$ 且 $p'<p$，这与 $p$ 是 $x$ 的最小质因数矛盾。因此枚举到 $i$ 时不会提前退出，$x$ 一定会被筛到。

复杂度：每个合数只被筛一次，时间为 $O(n)$；空间为 $O(n)$。代码见「逐行代码解析」。

### 八、P3951 小凯的疑惑

题意：对于 $\forall x\ge 0,y\ge 0$，$ax+by=N$，满足 $\gcd(a,b)=1$，求使得方程无解的最大 $N$。

**引理 10**：在模 $p$ 高维空间内，若 $k$ 与 $p$ 互质，则以 $k$ 为步长、固定方向向量走 $p-1$ 步，每步的落点都不一样。

证明：设第 $i$ 步的落点为 $X_i$，$i\in[0,p-1]$，方向向量为 $\vec v$，则 $X_i=X_0+i(k\vec v)$。反证：若 $X_i\equiv X_j\pmod p$，移项合并得 $(i-j)k\vec v\equiv 0\pmod p$，即 $p\mid (i-j)k\vec v$。因为 $\gcd(k,p)=1$ 且 $p>|i-j|$，所以这种情况不合法，不会出现落点一致的情况。

**引理 11**：当引理 10 的空间退化为 $1$ 维时，空间中只有 $p$ 个点，而我们走 $p-1$ 步到达 $p$ 个不同的点（考虑起点）。由引理 10，这是单射；定义域和值域集合大小相同，所以走 $p-1$ 步可以覆盖空间中所有的点，即满足双射关系。

**引理 12**：若 $x\mid y$，且 $k\mid x,k\mid y$，则 $\dfrac{x}{k}\mid \dfrac{y}{k}$。

证明：设 $y=\mu x$，则 $\dfrac{y}{k}=\mu\cdot\dfrac{x}{k}$，所以整除关系成立。

**引理 13**：对于整数 $a,b,c,d$，设 $\gcd(a,b)=g$。若 $bc\equiv bd\pmod a$，则消去 $b$ 后一定有 $c\equiv d\pmod{\dfrac{a}{g}}$。

证明：由同余式得 $a\mid b(c-d)$；由引理 12，$\dfrac{a}{g}\mid \dfrac{b}{g}(c-d)$。由于 $\gcd\!\left(\dfrac{a}{g},\dfrac{b}{g}\right)=1$，所以 $\dfrac{a}{g}\mid (c-d)$，即 $c\equiv d\pmod{\dfrac{a}{g}}$。

**引理 14**：对于题目所述方程，一定唯一存在一个 $y_0\in[0,a-1]$，满足 $y_0b\equiv N\pmod a$；$N$ 是合法的充要条件是 $N\ge y_0b$。

证明：由引理 11，满足双射关系，所以 $y_0$ 是唯一的。

- 充分性：若 $N\ge y_0b$，由于 $y_0b\equiv N\pmod a$ 且 $N\ge y_0b$，所以 $N-y_0b\equiv 0\pmod a$，即 $a\mid (N-y_0b)$。于是 $x_0=\dfrac{N-y_0b}{a}\ge 0$，得到一组非负整数解。
- 必要性：若有非负整数解 $N=ax+by$，两边同时对 $a$ 取模，得 $N\equiv yb\pmod a$。代入 $N\equiv y_0b\pmod a$，得 $y_0b\equiv yb\pmod a$。由于 $\gcd(a,b)=1$，由引理 13 得 $y\equiv y_0\pmod a$。又因为 $y_0\le a-1$ 且 $y\ge 0$，合法的最小同余类由 $y_0$ 占据，所以 $y\ge y_0$，从而 $N=ax+by\ge by_0$。证毕。

由引理 14 的逆否命题，$N$ 无非负整数解的充要条件是 $N<y_0b$。又因为 $N\equiv y_0b\pmod a$，所以在以 $y_0b\bmod a$ 为代表的同余类中，最大的无解整数必为 $y_0b-a$。

由引理 11，当 $y_0$ 遍历 $\{0,1,\dots,a-1\}$ 时，$y_0b\bmod a$ 不重不漏地覆盖模 $a$ 的全部 $a$ 个剩余类。每个同余类中最大的不可表示数即为

$$
f(y_0)=y_0b-a.
$$

由于 $b>0$，$f(y_0)$ 随 $y_0$ 增大而严格递增，所以全局最大的无解 $N$ 在 $y_0=a-1$ 时达到：

$$
(a-1)b-a=ab-a-b.
$$

代码只需输出 $ab-a-b$，见「逐行代码解析」。

#### 拓展 Q1：不可表示数的个数

**引理 14.3（对称反转引理）**：对于最大的不可表示数 $M=ab-a-b$，$n$ 和 $M-n$ 中恰好只有一个能被表示。

证明：

- 二者不可能都被表示：假设 $n=ax_1+by_1$，$M-n=ax_2+by_2$，则 $M=(x_1+x_2)a+(y_1+y_2)b$，与 $M$ 不可表示矛盾；
- 二者不可能都不被表示：若 $n$ 不能被表示，由引理 14，$n\le y_0b-a$，于是 $M-n\ge ab-a-b-(y_0b-a)=(a-y_0-1)b$。因为 $y_0\in[0,a-1]$，所以 $a-y_0-1\in[0,a-1]$；由引理 14，超过这个范围就是合法解。

不可表示数只会出现在 $[0,M]$ 中，共有 $ab-a-b+1=(a-1)(b-1)$ 个可能出现的数字。由引理 14.3，区间内的数字两两配对，所以不可表示数的个数为

$$
\frac{(a-1)(b-1)}{2}.
$$

#### 拓展 Q2：不可表示数的和

对于所有 $y_0\in[0,a-1]$，由引理 14，满足

$$
N=y_0b-ka,\qquad N\le y_0b-a,\qquad N>0
$$

的 $N$ 都是不可表示的。对于每个固定的 $y_0$，这些 $N$ 构成一个以 $a$ 为公差的等差数列。

**引理 14.7（连续自然数平方和）**：

$$
\sum_{i=1}^n i^2=\frac{2n^3+3n^2+n}{6}=\frac{n(n+1)(2n+1)}{6}.
$$

证明：离散情况下答案一定可以写作一个多项式。二次项连续求和，答案多项式最高次项是三次项，故设答案为 $An^3+Bn^2+Cn$。手算 $n=1,2,3$：

$$
\begin{cases}
A+B+C=1,\\
8A+4B+2C=5,\\
27A+9B+3C=14.
\end{cases}
$$

解得 $A=\dfrac13$，$B=\dfrac12$，$C=\dfrac16$，即

$$
\frac{n^3}{3}+\frac{n^2}{2}+\frac{n}{6}
=\frac{2n^3+3n^2+n}{6}
=\frac{n(n+1)(2n+1)}{6}.
$$

对于每个固定的 $y_0$，组内首项为 $y_0b-a$，末项为 $r=y_0b\bmod a$，项数为

$$
q=\left\lfloor\frac{y_0b}{a}\right\rfloor=\frac{y_0b-r}{a}.
$$

由等差数列求和公式，

$$
S=\frac{q(y_0b-a+r)}{2}
=\frac12\cdot\frac{y_0b-r}{a}\cdot(y_0b+r-a)
=\frac{1}{2a}\left(b^2y_0^2-r^2-aby_0+ar\right).
$$

对所有 $y_0$ 的贡献求和：

$$
\frac{1}{2a}\left(b^2\sum y_0^2-\sum r^2-ab\sum y_0+a\sum r\right).
$$

由引理 11，$\sum r=\sum y_0$、$\sum r^2=\sum y_0^2$，所以

$$
\frac{1}{2a}\left[(b^2-1)\sum y_0^2-a(b-1)\sum y_0\right].
$$

由引理 14.7 以及等差数列求和公式，并注意 $y_0$ 的取值范围是 $[0,a-1]$：

$$
\frac{1}{2a}\left[(b+1)(b-1)\frac{a(a-1)(2a-1)}{6}-a(b-1)\frac{a(a-1)}{2}\right]
=\frac{(a-1)(b-1)(2ab-a-b-1)}{12}.
$$

### 九、P4549 裴蜀定理

**引理 15（良序原理）**：对于自然数集的任意一个子集，一定有一个最小元素。

裴蜀定理：对于形如 $\sum a_ix_i=n$ 的方程，使其有整数解的最小正整数是所有 $a_i$ 的最大公约数，记为 $d$；所有使其有解的 $n$ 满足 $d\mid n$。

证明：方程解集与自然数集的交集，即正整数解集，一定是自然数集的一个子集。根据良序原理，一定存在一个最小元素 $m$。对于每一个 $a_j$，设 $a_j=qm+r$，则

$$
r=a_j-q\left(\sum a_ix_i\right)
=(1-q)a_j-q\sum_{i\ne j}a_ix_i,
$$

所以 $r$ 也是一个合法解。但 $r$ 是对 $m$ 取模的余数，所以 $r<m$；而 $m$ 是最小正整数解，所以只可能 $r=0$，也就是 $m\mid a_j$。因此 $m$ 是所有元素的公因数，所以 $m\le d$。

另一方面，$m$ 是这些元素的线性组合，由引理 1，$d$ 是它们的最大公因数，所以 $d$ 是它们线性组合的因数，满足 $d\mid m$，即 $d\le m$。于是 $d=m$。证毕。

本题输入可能是负数；负数和其相反数对于一个数的整除关系不变，所以直接取反求 $\gcd$ 即可。代码见「逐行代码解析」。

### 十、P3811 模逆元

定义：一个数 $x$ 在模 $p$ 意义下的逆元记作 $x^{-1}$，满足

$$
x\cdot x^{-1}\equiv 1\pmod p.
$$

逆元的线性递推：设 $p=\left\lfloor\dfrac{p}{i}\right\rfloor i+p\bmod i$，记 $k=\left\lfloor\dfrac{p}{i}\right\rfloor$，$r=p\bmod i$，则 $ki+r\equiv 0\pmod p$。两边同时乘 $i^{-1}r^{-1}$，得到

$$
kr^{-1}+i^{-1}\equiv 0\pmod p,
$$

即

$$
i^{-1}\equiv -kr^{-1}\pmod p.
$$

为了使结果大于 $0$，给负数项加上一个 $p$，得到最终递推式：

$$
i^{-1}=\left(p-\left\lfloor\frac{p}{i}\right\rfloor\right)(p\bmod i)^{-1}\pmod p.
$$

复杂度 $O(n)$。代码见「逐行代码解析」。

### 十一、P9774 新取模运算与威尔逊定理

题意：定义新运算 $x\oplus y$。如果 $x$ 不是 $y$ 的倍数，则得到 $x$ 除以 $y$ 的余数；否则令 $x$ 不断除以 $y$ 直到 $x$ 不再是 $y$ 的倍数，设此时为 $x'$，然后得到 $x'$ 除以 $y$ 的余数。给定质数 $p$，多组询问 $n$，求 $n!\oplus p$。

**引理 16**：若 $a\equiv b\pmod p$，且 $d\mid p$，则 $a\equiv b\pmod d$。

证明：$p\mid (a-b)$，所以 $d\mid (a-b)$，即 $a-b\equiv 0\pmod d$，因此 $a\equiv b\pmod d$。

**引理 17**：若 $p$ 是质数，则 $[0,p-1]$ 范围内所有数字的逆元一定落在 $[0,p-1]$ 范围内，且不重不漏。

证明：逆元是在模 $p$ 意义下定义的，所以一定在 $[0,p-1]$ 范围内。假设一个数字 $x$ 有两个逆元 $a_1,a_2$，则

$$
xa_1\equiv 1\pmod p,\qquad xa_2\equiv 1\pmod p.
$$

两式相减得 $(a_1-a_2)x\equiv 0\pmod p$。因为 $p$ 是质数且 $1\le x\le p-1$，所以 $p\nmid x$，从而 $a_1\equiv a_2\pmod p$，逆元唯一。由于逆元不重，集合大小相等，所以逆元不漏。

**引理 18（威尔逊定理）**：一个大于 $1$ 的整数 $p$ 是质数的充要条件是

$$
(p-1)!\equiv -1\pmod p.
$$

证明：

- 充分性（$p$ 为质数）：在 $1,2,\dots,p-1$ 中，每个数 $x$ 都有唯一的逆元 $x^{-1}\in[1,p-1]$（引理 17）。把 $x$ 与 $x^{-1}$ 配对；若 $x\ne x^{-1}$，这一对的乘积为 $1$。满足 $x=x^{-1}$ 的只有 $x^2\equiv 1\pmod p$ 的解，即 $x\equiv 1$ 或 $x\equiv -1\pmod p$。除了 $1$ 和 $p-1$ 之外，其余数全部两两配对消成 $1$，所以
  $$
  (p-1)!\equiv 1\cdot(p-1)\equiv -1\pmod p.
  $$
- 必要性（$p$ 为合数）：若 $p=4$，$3!=6\equiv 2\not\equiv -1\pmod 4$。若 $p>4$ 且为合数，分两种情况：
  - 若 $p$ 不是完全平方数，设 $p=uv$，其中 $1<u<v<p$，则 $u$ 和 $v$ 都出现在 $(p-1)!$ 的因子中，所以 $p=uv\mid (p-1)!$；
  - 若 $p=r^2$ 且 $r>2$，则 $r$ 和 $2r$ 都小于 $p$ 且出现在 $(p-1)!$ 的因子中，二者贡献至少两个因子 $r$，所以 $r^2=p\mid (p-1)!$。

  因此合数情形下 $(p-1)!\equiv 0\pmod p$，不可能等于 $-1$。

现在回到 $n!\oplus p$。设 $e=v_p(n!)=\sum_{k\ge1}\left\lfloor\dfrac{n}{p^k}\right\rfloor$。按定义，$n!\oplus p$ 就是

$$
\frac{n!}{p^e}\bmod p.
$$

令

$$
F(n)=\prod_{\substack{1\le i\le n\\ p\nmid i}}i,
$$

即 $1\sim n$ 中所有不被 $p$ 整除的数的乘积。把 $n!$ 中的 $p$ 因子逐层剥掉：

$$
\frac{n!}{p^{v_p(n!)}}=F(n)\cdot F\!\left(\left\lfloor\frac np\right\rfloor\right)\cdot F\!\left(\left\lfloor\frac n{p^2}\right\rfloor\right)\cdots
=\prod_{k\ge0}F\!\left(\left\lfloor\frac n{p^k}\right\rfloor\right).
$$

这是因为所有被 $p$ 整除的数都可以写成 $p\cdot j$，提走一个 $p$ 后，剩下的部分正好是 $\left\lfloor n/p\right\rfloor!$，递归处理即可。

接下来计算 $F(n)$。设 $n=qp+r$（$0\le r<p$）。在 $1\sim n$ 中，不被 $p$ 整除的数由 $q$ 个完整的块 $[kp+1,kp+p-1]$ 和一个不完整的块 $[qp+1,qp+r]$ 组成。每个完整块的乘积为 $(p-1)!\equiv -1\pmod p$（威尔逊定理），不完整块的乘积为 $r!$，所以

$$
F(n)\equiv (-1)^q\cdot r!\pmod p.
$$

于是可以 $O(p)$ 预处理 $fact[0..p-1]$（$fact[r]=r!\bmod p$），每次询问按下面的递推逐层计算。令 $m_0=n$，$q_i=\left\lfloor m_i/p\right\rfloor$，$r_i=m_i\bmod p$，$m_{i+1}=q_i$，则

$$
ans=\prod_{i\ge0}(-1)^{q_i}\cdot fact[r_i]\pmod p.
$$

具体地，令 $m=n$，不断执行：

- $q=\left\lfloor m/p\right\rfloor$，$r=m\bmod p$；
- 若 $q$ 为奇数，答案乘 $-1$（即取 $p-ans$）；
- 答案乘 $fact[r]$；
- 令 $m=q$，直到 $m=0$。

伪代码如下：

```text
read T, p
fact[0] = 1
for i = 1 .. p-1:
    fact[i] = fact[i-1] * i mod p

for each query n:
    ans = 1
    m = n
    while m > 0:
        q = m / p
        r = m mod p
        if q is odd:
            ans = (-ans) mod p
        ans = ans * fact[r] mod p
        m = q
    print ans
```

复杂度：预处理 $O(p)$，每次询问 $O(\log_p n)$，总时间 $O(p+T\log_p n)$，空间 $O(p)$。在 $p\le 10^6$、$T\le 10^5$、$n\le 10^{18}$ 的数据范围内可以接受。注意 $p=2$ 时 `fact` 只有两个元素，循环和取模都要正确处理。

---

## 核心公式 / 状态定义与转移方程

- 欧几里得算法：$\gcd(a,b)=\gcd(b,a\bmod b)$，边界 $\gcd(a,0)=a$。
- 最小公倍数：$\operatorname{lcm}(a,b)=\dfrac{ab}{\gcd(a,b)}$。
- 引理 7：若 $ab=x$，则 $\min(a,b)\le\sqrt x$。
- 快速幂：$a^b=(a^2)^{\lfloor b/2\rfloor}\cdot a^{[b\bmod 2]}$。
- 龟速乘：$ab=2a\lfloor b/2\rfloor+a\cdot[b\bmod 2]$。
- 光速幂：$a^b=a^{kB+r}=g_k f_r$，其中 $B$ 为块长，$k=\lfloor b/B\rfloor$，$r=b\bmod B$。
- 欧拉筛：对每个 $i$，用质数 $p_j$ 筛 $i\cdot p_j$；当 $i\bmod p_j=0$ 时退出。
- 裴蜀定理：$\sum a_ix_i=n$ 有整数解 $\iff \gcd(a_1,\dots,a_k)\mid n$；最小正整数解为 $\gcd(a_1,\dots,a_k)$。
- 模逆元递推：$i^{-1}\equiv\left(p-\left\lfloor\dfrac pi\right\rfloor\right)(p\bmod i)^{-1}\pmod p$。
- 威尔逊定理：$p$ 为质数 $\iff (p-1)!\equiv -1\pmod p$。
- P9774：$F(n)\equiv(-1)^{\lfloor n/p\rfloor}(n\bmod p)!\pmod p$，答案为 $\prod_{k\ge0}F(\lfloor n/p^k\rfloor)\bmod p$。
- 小凯的疑惑：最大不可表示数 $ab-a-b$；不可表示数个数 $\dfrac{(a-1)(b-1)}2$；不可表示数之和 $\dfrac{(a-1)(b-1)(2ab-a-b-1)}{12}$。

---

## 逐行代码解析

### gcd / lcm（B3634）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int gcd(int a,int b){
    return b==0?a:gcd(b,a%b);
}
signed main()
{
    int a,b;
    cin>>a>>b;
    int k=gcd(a,b);
    cout<<k<<" "<<a*b/k;
    return 0;
}
```

- `gcd` 用递归实现欧几里得算法，边界是 `b==0` 时返回 `a`。
- `#define int long long` 后，`main` 要写成 `signed main`。
- 输出最大公约数和最小公倍数；`a*b/k` 利用引理 6，注意 `a*b` 可能很大，所以前面开了 `long long`。
- 更稳妥的写法是 `a/gcd(a,b)*b`，可以进一步降低溢出的风险。

### P1029 最大公约数和最小公倍数问题

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long 
signed main()
{
    int x,y;cin>>x>>y;
    int mul=x*y;
    int lim=sqrt(mul);
    int ans=0;
    for(int i=x;i<=lim;i+=x)
    {
        if(mul%i==0)
        {
            int j=mul/i;
            if(__gcd(i,j)==x)
            {
                if(i==j) ans++;
                if(i!=j) ans+=2;
            }
        }
    }
    cout<<ans;
    return 0;
}
```

- `mul=x*y` 是 $PQ$ 的固定值；由引理 7，只需枚举到 `sqrt(mul)`。
- `i+=x` 保证枚举的 $P$ 一定是 $x_0$ 的倍数。
- `mul%i==0` 保证 $Q$ 是整数；`__gcd(i,j)==x` 检查最大公约数条件。
- `i==j` 时只算一对，否则 $(i,j)$ 与 $(j,i)$ 都合法，答案加 $2$。
- `sqrt` 返回浮点数，数据很大时要注意精度；必要时可以用整数二分或 `sqrtl`。

### P1072 Hankson 的趣味题

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int a0,a1,b0,b1;
bool jud(int x)
{
    if(x%a1) return false;
    return (__gcd(x,a0)==a1)&&(x*b0/__gcd(x,b0)==b1);
}
signed main()
{
    int n;cin>>n;
    while(n--)
    {
        cin>>a0>>a1>>b0>>b1;
        int lim=(int)sqrt(b1);
        int ans=0;
        for(int i=1;i<=lim;i++)
        {
            if(b1%i==0)
            {
                if(i==b1/i){
                    if(jud(i))
                        ans++;
                }
                else {
                    if(jud(i)) ans++;
                    if(jud(b1/i)) ans++;
                }                
            }
        }
        cout<<ans<<"\n";
    }
    return 0;
}
```

- 合法 $x$ 一定是 $b_1$ 的因数，所以枚举到 $\sqrt{b_1}$ 即可覆盖所有因数对。
- `jud` 中先用 `x%a1` 排除不可能满足 $\gcd(x,a_0)=a_1$ 的数。
- `x*b0/__gcd(x,b0)` 计算 $\operatorname{lcm}(x,b_0)$；这里先除后乘更稳，但原代码是先乘后除，数据范围内能过。
- `i==b1/i` 时只检查一次，避免完全平方因数被重复计数。
- 多测共用全局变量 `a0,a1,b0,b1`，每轮都会重新读入，不需要额外清空。

### 快速幂（P1226）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int p;
int fpow(int a,int b)
{
    int ans=1;
    while(b)
    {
        if(b%2==1) ans=(ans*a)%p;
        a=(a*a)%p;
        b/=2;
    }
    return ans;
}
signed main()
{
    int a,b;
    cin>>a>>b>>p;
    cout<<a<<"^"<<b<<" mod "<<p<<"="<<fpow(a,b);
    return 0;
}
```

- 循环不变量：`ans * a^b` 始终等于原式（模 `p`）。
- `b%2==1` 时把当前的 `a` 乘进 `ans`；随后 `a` 自乘、`b` 减半。
- `b=0` 时循环结束，`ans` 就是答案；`p=1` 时所有结果模 $1$ 都是 $0$。若题目允许 `p=1` 且 `b=0`，原实现会直接返回 $1$，与 $1\bmod 1=0$ 不一致，需要按题目数据范围确认是否要特判。
- `a` 可能在自乘时超过 `long long`，应保证先取模；原代码在乘完后取模，数据范围内需要确认 `a*a` 不溢出。

### 龟速乘（U483926）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int mul(int a,int b,int p)
{
    int ans=0;
    while(b)
    {
        if(b%2==1) ans=(ans+a)%p;
        a=(a+a)%p;b/=2;
    }
    return ans;
}
signed main()
{
    ios::sync_with_stdio(false);
    cin.tie(0);
    int t;cin>>t;
    while(t--)
    {
        int a,b,p;
        cin>>a>>b>>p;
        cout<<mul(a,b,p)<<'\n';        
    }
    return 0;
}
```

- 与快速幂结构相同，只是把“乘法”换成“加法”：`ans` 累加 `a`，`a` 每次翻倍。
- 每一步都对 `p` 取模，保证 `ans+a` 和 `a+a` 不溢出。
- 复杂度 $O(\log b)$；在支持 `__int128` 的环境里，直接 `a*b%p` 通常更快。
- 多测注意清空是天然的：`ans` 在 `mul` 内部初始化，`a,b,p` 每轮重新读入。

### 光速幂（U185835）

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e5+5;
const int p=998244352;
int pw1[N];
int pw2[N];
signed main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int x,n;
    cin>>x>>n;
    pw1[0]=1;
    int lim=(int)(N-100);
    for(int i=1;i<=lim;i++)
        pw1[i]=(pw1[i-1]*x)%p;
    pw2[0]=1;
    pw2[1]=(pw1[lim-1]*x)%p;
    for(int i=2;i<=lim;i++)
        pw2[i]=(pw2[i-1]*pw2[1])%p;
    while(n--)
    {
        int a;cin>>a;
        int r=a%lim;
        int k=a/lim;
        cout<<(pw2[k]*pw1[r])%p<<" ";
    }
    return 0;
}
```

- `pw1[i]` 存 $x^i$，`pw2[i]` 存 $x^{i\cdot lim}$；`pw2[1]=pw1[lim-1]*x` 正好是 $x^{lim}$。
- 查询指数 `a` 时，`r=a%lim`、`k=a/lim`，答案是 `pw2[k]*pw1[r]%p`。
- 模数是 `998244352`，不是常见的 `998244353`，这是本题最容易看错的地方。
- `lim` 取得略小于 `N`，是为了给 `pw1[lim-1]` 和 `pw2` 留出边界；查询的 `k` 不能超过 `lim`，否则 `pw2[k]` 越界。

### 线性筛（P3383）

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e8+5;
bitset<N> st;
const int M=1e7+5;
int p[M],cnt;
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    for(int i=2;i<N;i++)
    {
        if(!st[i]) {p[++cnt]=i;}
        for(int j=1;j<=cnt;j++)
        {
            if(1LL*i*p[j]>=N) break;
            st[i*p[j]]=1;
            if(i%p[j]==0) break;
        }
    }
    int n,q;cin>>n>>q;
    while(q--)
    {
        int k;cin>>k;
        cout<<p[k]<<"\n";
    }
    return 0;
}
```

- `st[i]` 表示 $i$ 是否被筛掉；`p[1..cnt]` 存质数。
- 外层枚举 $i$，若 `!st[i]` 则 $i$ 是质数。
- 内层用已得到的质数去筛 $i\cdot p_j$；`1LL*i*p[j]` 防止乘法溢出。
- `i%p[j]==0` 时退出，保证每个合数只被最小质因数筛一次。
- 预处理范围写死到 `N`，查询只读 `p[k]`；本题 $n$ 最大 $10^8$，`bitset` 比 `bool` 数组更省空间。

### P3951 小凯的疑惑

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
signed main()
{
    int a,b;
    cin>>a>>b;
    cout<<a*b-a-b;
    return 0;
}
```

- 由引理 14 及后续推导，答案就是 $ab-a-b$。
- `a*b` 可能超过 `int`，所以开 `long long`。
- 题目保证 $\gcd(a,b)=1$；若没有这个条件，公式不成立。

### P4549 裴蜀定理

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
signed main()
{
    int n;cin>>n;
    int x;cin>>x;
    x=abs(x);
    for(int i=2;i<=n;i++)
    {
        int a;cin>>a;
        x=__gcd(x,abs(a));
    }
    cout<<x;
    return 0;
}
```

- 先读入第一个数并取绝对值，作为当前的 gcd。
- 后面每个数取绝对值后与当前 gcd 再取 gcd；最终就是所有数的最大公约数。
- 裴蜀定理保证这个 gcd 就是方程有整数解时的最小正整数。
- `n=0` 的情况题目通常不会给；若给了，这段代码会读不到 `x`，需要额外特判。

### P3811 模逆元

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=3e6+5;
int inv[N];
signed main()
{
    inv[0]=1;
    inv[1]=1;
    cout<<1<<"\n";
    int n,p;cin>>n>>p;
    for(int i=2;i<=n;i++)
    {
        inv[i]=((p-(p/i))*(inv[p%i]))%p;
        cout<<inv[i]<<"\n";
    }
    return 0;
}
```

- `inv[1]=1` 是递推边界；先输出 $1$ 的逆元。
- 递推式 `inv[i]=((p-(p/i))*inv[p%i])%p` 对应上面的公式。
- `p%i` 一定小于 `i`，所以 `inv[p%i]` 已经算过；这就是线性递推成立的原因。
- 需要保证 $p$ 是质数且 $i<p$，否则 `p%i` 可能为 $0$，`inv[0]` 没有意义。

### P9774 新取模运算（伪代码）

```text
read T, p
fact[0] = 1
for i = 1 .. p-1:
    fact[i] = fact[i-1] * i mod p

for each query n:
    ans = 1
    m = n
    while m > 0:
        q = m / p
        r = m mod p
        if q is odd:
            ans = (-ans) mod p
        ans = ans * fact[r] mod p
        m = q
    print ans
```

- `fact[r]` 是 $r! \bmod p$，预处理到 $p-1$ 即可；由威尔逊定理，完整块的乘积是 $-1$。
- 每层剥掉一个 $p$，直到 $m=0$；循环次数是 $O(\log_p n)$。
- 若 `q` 为奇数，完整块有奇数个，乘积为 $-1$，所以答案取负。
- 这是伪代码，具体 C++ 实现由你本人完成；注意 $p\le 10^6$、$n\le 10^{18}$，要开 `long long` 并使用快速输入输出。

---

## 复杂度分析

| 算法 / 题目 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 欧几里得算法 | $O(\log V)$ | $O(1)$（递归栈 $O(\log V)$） |
| B3634 gcd/lcm | $O(\log V)$ | $O(1)$ |
| P1029 | $O\!\left(\sqrt{y_0/x_0}\log V\right)$ | $O(1)$ |
| P1072 | $O(n\sqrt V\log V)$ | $O(1)$ |
| 快速幂 P1226 | $O(\log b)$ | $O(1)$ |
| 龟速乘 U483926 | $O(\log b)$ | $O(1)$ |
| 光速幂 U185835 | $O(B+T)$ | $O(B)$ |
| 线性筛 P3383 | $O(n)$ | $O(n)$ |
| P3951 | $O(1)$ | $O(1)$ |
| 裴蜀定理 P4549 | $O(n\log V)$ | $O(1)$ |
| 模逆元 P3811 | $O(n)$ | $O(n)$ |
| P9774 | $O(p+T\log_p n)$ | $O(p)$ |

其中 $V$ 是数值值域，$B$ 是光速幂的块长，$n$ 在不同题目中分别表示枚举量、元素个数或筛的范围。

---

## 适用场景

- **gcd / lcm**：约分、比例、周期、同余方程、分数运算，以及所有需要“公共因子”的题目。
- **欧几里得算法**：求最大公约数、判断互质、解线性同余方程的基础。
- **快速幂**：模意义下的大指数幂、矩阵快速幂、递推加速。
- **龟速乘**：模数很大且没有 `__int128` 时，防止乘法溢出；现代比赛通常直接用 `__int128`。
- **光速幂**：底数和模数固定、询问次数很多的幂运算，例如固定底数的多次查询。
- **线性筛**：需要 $1\sim n$ 内所有质数，或需要在线性时间内预处理积性函数。
- **裴蜀定理**：判断线性组合能否表示某个数，求最小正整数表示，处理负数和多变量 gcd。
- **模逆元**：模意义下的除法、组合数、解同余方程；线性递推适合求 $1\sim n$ 的全部逆元。
- **威尔逊定理**：质数判定、阶乘模质数的化简，以及 P9774 这类“剥掉质因子后取模”的问题。
- **小凯的疑惑**：两个互质数的线性组合不可表示数问题；拓展公式可用于计数与求和。

---

## 常见陷阱与注意事项

1. **`long long` 溢出**：`a*b` 在 $a,b\le 10^9$ 时就会超过 `int`；lcm 更稳妥的写法是 `a/gcd(a,b)*b`。
2. **`sqrt` 精度**：`sqrt` 返回浮点数，数值很大时可能差 $1$；枚举约数时可以用整数二分或 `sqrtl` 并微调。
3. **负数 gcd**：`__gcd` 对负数可能返回负值；P4549 中统一取 `abs`，最后输出正数。
4. **快速幂的边界**：`b=0` 时答案是 $1\bmod p$；`p=1` 时答案是 $0$；底数为负时先取模归一化。
5. **龟速乘的边界**：`p=1` 时所有结果都是 $0$；`a` 要先对 `p` 取模，避免加法溢出。
6. **光速幂的模数**：本题是 $998244352$，不是 $998244353$；预处理块长和查询上界要匹配，`pw2[k]` 不能越界。
7. **线性筛的退出条件**：必须在 `i%p[j]==0` 时退出，否则同一个合数会被多个质因数重复筛，复杂度退化。
8. **P3951 的前提**：必须 $\gcd(a,b)=1$；答案是 $ab-a-b$，不是 $ab$ 或其他形式。
9. **裴蜀定理的输入**：可能含负数；`n=0` 要特判；多变量时要对所有数取 gcd，而不是只看前两个。
10. **模逆元的前提**：$p$ 必须是质数且 $i<p$；递推中 `p%i` 必须非零，否则 `inv[0]` 无意义。
11. **P9774 的符号**：完整块的乘积是 $-1$，块数为奇数时答案要取负；`n` 很大，必须用 `long long`。
12. **多测清空**：P1029、P1072、龟速乘、光速幂都是多测；局部变量在循环内定义最省心，全局数组要手动清空。
13. **LaTeX 书写**：本笔记公式较多，表格里不要出现裸的 `|`；行内公式的定界符要成对。

---

## 对比与扩展

- **快速幂 vs 龟速乘 vs 光速幂**：快速幂解决“大指数”，龟速乘解决“大乘积溢出”，光速幂解决“固定底数的多次查询”。三者的共同结构都是把指数二进制或分块拆开。
- **欧几里得算法 vs 更相减损术**：更相减损术在数值差距很大时可能退化，欧几里得算法用取模把复杂度压到 $O(\log V)$。
- **线性筛 vs 埃氏筛**：埃氏筛是 $O(n\log\log n)$，写法简单；线性筛是 $O(n)$，适合需要最小质因数或积性函数预处理的场景。
- **裴蜀定理 vs 扩展欧几里得**：裴蜀定理回答“有没有解、最小正整数是多少”，扩展欧几里得给出具体的 $x,y$；两者常配合使用。
- **威尔逊定理 vs 费马小定理**：威尔逊定理给出阶乘与 $-1$ 的关系，适合处理阶乘模质数；费马小定理给出 $a^{p-1}\equiv1$，适合求逆元和快速幂。
- **P3951 的两个拓展**：不可表示数的个数为 $\dfrac{(a-1)(b-1)}2$，和为 $\dfrac{(a-1)(b-1)(2ab-a-b-1)}{12}$；推导都依赖“同余类双射 + 对称配对”。
- **P9774 的可迁移性**：凡是“把阶乘中的所有质因子 $p$ 剥掉再取模”的问题，都可以用“完整块 + 余块 + 威尔逊定理”的套路，复杂度只与 $p$ 和 $\log_p n$ 有关。
