---
id: math-crt
title: '中国剩余定理（CRT 与 exCRT）'
category: 数学
subcategory: 数论基础
subSubcategory: '同余与模运算'
tags: ["数学", "数论", "中国剩余定理", "CRT", "exCRT", "同余方程组", "扩展欧几里得"]
timeComplexity: 'O(k log m)'
spaceComplexity: 'O(k)'
level: A
codePath: '数学\数论基础\中国剩余定理\源--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

> ~~古人的智慧~~

**问题来源——“物不知数”**：

> 有物不知其数，三三数之剩二，五五数之剩三，七七数之剩二。问物几何？

翻译成现代数学：求 $x$ 满足：

$$
\begin{cases}
x \equiv 2 \pmod{3} \\
x \equiv 3 \pmod{5} \\
x \equiv 2 \pmod{7}
\end{cases}
$$

答案是 $23$。明朝程大位还给编了个口诀：

> 三人同行七十希，五树梅花廿一支，七子团圆正半月，除百零五便得知。

当然这只是个特例，如何对于任意的同余方程组求解呢？

回归正题，CRT 用于求解如下形式的一元线性同余方程组：

$$
\begin{cases}
x \equiv a_1 \pmod{m_1} \\
x \equiv a_2 \pmod{m_2} \\
\vdots \\
x \equiv a_k \pmod{m_k}
\end{cases}
$$

其中 $m_1, m_2, \dots, m_k$ **两两互质**。

### 算法步骤

1. 计算所有模数的乘积：$M = \prod_{i=1}^{k} m_i$。
2. 对于第 $i$ 个方程，计算 $M_i = M / m_i$。
3. 求 $M_i$ 在模 $m_i$ 下的逆元 $t_i$，即 $M_i \cdot t_i \equiv 1 \pmod{m_i}$。
4. 累加：$ans = \sum_{i=1}^{k} a_i \cdot M_i \cdot t_i$。
5. 最终答案：$ans \bmod M$。

**正确性证明**：对于第 $i$ 个方程，$M_i$ 是除了 $m_i$ 以外所有模数的乘积，所以 $M_i \equiv 0 \pmod{m_j}$（$j \ne i$），只有 $M_i$ 这一项对第 $i$ 个方程有贡献。而 $M_i \cdot t_i \equiv 1 \pmod{m_i}$，乘上 $a_i$ 后正好得到 $a_i$。

### 扩展中国剩余定理（exCRT）

如果出题人 ~~故意找茬~~ 不给你模数两两互质呢？exCRT 就能处理这种情况。

exCRT 通过**两两合并**的方式逐步求解。**合并思想**：假设我们已经得到了前 $k-1$ 个方程的一个特解 $x \equiv a \pmod{M}$，其中 $M = \mathrm{lcm}(m_1, \dots, m_{k-1})$。现在要加入新方程 $x \equiv a_k \pmod{m_k}$。我们需要找一个 $t$，使得：

$$
a + t \cdot M \equiv a_k \pmod{m_k}
$$

即：

$$
M \cdot t \equiv a_k - a \pmod{m_k}
$$

这是一个线性同余方程，用 **EXGCD** 判断是否有解（$\gcd(M, m_k) \mid (a_k - a)$），然后解出 $t$，更新：

$$
a' = a + t \cdot M, \quad M' = \mathrm{lcm}(M, m_k)
$$

新的同余式就是 $x \equiv a' \pmod{M'}$。重复合并所有方程，最后得到 $x \equiv a \pmod{M}$，$a$ 就是最小非负解。

> 注：exCRT 在合并过程中可能出现无解，此时整个方程组无解，特判即可。一般题目保证有解。

## 核心公式

| 内容 | 公式 |
|---|---|
| CRT 构造 | $M=\prod m_i,\ M_i=M/m_i,\ ans=\sum a_i M_i t_i \bmod M$ |
| 逆元条件 | $M_i t_i \equiv 1 \pmod{m_i}$，要求 $\gcd(M_i,m_i)=1$（模数两两互质） |
| exCRT 合并 | $a + tM \equiv a_k \pmod{m_k}$ |
| exCRT 更新 | $a' = a + tM,\ M' = \mathrm{lcm}(M, m_k)$ |
| exCRT 有解判定 | $\gcd(M, m_k) \mid (a_k - a)$ |

## 逐行代码解析

### 模块一：CRT 的初始化与模数乘积

```cpp
// 基础CRT：求解同余方程组，a数组为余数，m数组为模数（两两互质），k为方程个数

ll crt(ll a[], ll m[], ll k) {
    ll M = 1, res = 0;
    for (ll i = 1; i <= k; i++) M *= m[i]; // 模数乘积M
```

- `a[]` 存余数、`m[]` 存模数，下标从 $1$ 开始（所以循环写 `1..k`，`a[0]`、`m[0]` 是空的）。
- `M` 是全部模数的乘积，后面所有构造都围绕它展开。
- `res` 用来累加答案，初值为 $0$。

### 模块二：逐项构造答案

```cpp
    for (ll i = 1; i <= k; i++) {
        ll mi = m[i], ai = a[i];
        ll Mi = M / mi; // Mi = M / mi（与mi互质）
        ll inv_Mi = inv(Mi, mi); // Mi在模mi下的逆元
        res = (res + ai * Mi % M * inv_Mi % M) % M; // 累加解
    }
    return res;
}
```

- `Mi = M / mi`：去掉第 $i$ 个模数后的乘积，它天然是其他所有模数的倍数。
- `inv(Mi, mi)` 求 $M_i$ 在模 $m_i$ 下的逆元；CRT 要求模数两两互质，所以这个逆元一定存在。
- `ai * Mi % M * inv_Mi % M` 每乘一次就取一次模，尽量压小中间值。
- 最后 `res % M` 就是最小非负解。

### 模块三：exCRT 的两两合并

```cpp
ll excrt(ll c[],ll m[],ll k){
	ll a=1,b=0,x=0,y=0;
	for(int i=1;i<=k;i++){
		ll g=exgcd(a,c[i],x,y);
		x*=(b-m[i])/g;
		b-=a*x;
		a*=c[i]/g;
		b=(b%a+a)%a;
	}
	return b=(b%a+a)%a;
}
```

- 这里变量含义和上面的推导略有错位：`a` 扮演的是当前合并后的模数 $M$，`b` 扮演的是当前特解 $x$，`c[]` 是余数、`m[]` 是模数。
- `g = exgcd(a, c[i], x, y)` 解的是 $a \cdot x \equiv b - m_i \pmod{c_i}$ 对应的方程，`x` 是齐次解的一部分。
- `x *= (b - m[i]) / g;` 把 $\gcd$ 下的特解放大到目标方程；若 `(b - m[i]) % g != 0`，这里会直接整除丢失信息，等于默认题目保证有解。
- `b -= a * x;` 先把解平移到新同余式上，`a *= c[i] / g;` 把模数扩大为 $\mathrm{lcm}$，最后两行取模保证 `b` 落在 $[0, a)$。

## 复杂度分析

- **CRT**：求 $k$ 个逆元，每个 $O(\log m)$，总时间 $O(k \log m)$；空间 $O(k)$（存数组）。
- **exCRT**：合并 $k-1$ 次，每次一次 EXGCD，时间 $O(k \log m)$，与 CRT 相当，但适用范围更广（不要求模数互质）。
- 原文给出的复杂度口径就是 $O(k \log m)$。

## 适用场景

- **CRT**：模数两两互质的同余方程组；常见于“答案对多个质数取模后合并”“大数取模”类问题。
- **exCRT**：模数不一定互质，甚至模数之间有明显公因子的同余方程组。
- **exCRT 的合并思想**：不只用于解方程，也可以用来合并两个“周期 + 偏移”的限制（如日期、循环节问题）。
- **与 EXGCD 的关系**：exCRT 每次合并都要解一个线性同余方程，底层就是 EXGCD。

## 常见陷阱

1. **CRT 忘了模数必须两两互质**：不互质时 $M_i$ 与 $m_i$ 可能不互质，逆元不存在，`inv` 会返回错误值。
2. **逆元实现要求模数为质数**：本文的 `inv` 若是费马小定理版本，只能处理质数模数；CRT 里的 $m_i$ 是任意两两互质的数，必须用 EXGCD 求逆元。
3. **下标从 0 还是 1 开始**：代码里循环写的是 `i = 1; i <= k`，数组第 $0$ 位没用到，传参时别把数据塞到 `a[0]`。
4. **`M` 溢出**：$M = \prod m_i$ 增长极快，`long long` 最多撑到约 $9 \times 10^{18}$，模数稍大就会爆。
5. **exCRT 无解没判**：`(b - m[i]) / g` 在不能整除时结果没有意义，严格写法应先判 `(b - m[i]) % g != 0`。
6. **exCRT 变量名混淆**：代码里 `a` 是模数、`b` 是解，和公式里的 $a_k$（余数）不是一回事，读的时候要对着上下文。
7. **最后没取最小非负解**：`b` 可能在合并过程中变成负数，必须 `(b % a + a) % a`。

---
> CRT 的构造是“每一项只对自己那个方程负责，对其他方程自动消失”；exCRT 的合并是“把两个限制捏成一个”。抓住这两句话，代码就不容易看晕。
