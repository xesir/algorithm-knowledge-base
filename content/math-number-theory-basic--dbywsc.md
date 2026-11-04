---
id: math-number-theory-basic
title: '数论基础（素性测试 / 质因数分解 / 筛法 / gcd / 快速幂）'
category: 数学
subcategory: 数论基础
tags: ["数论", "素性测试", "质因数分解", "筛法", "gcd", "lcm", "快速幂"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: B
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

数论研究整数的性质。本笔记覆盖普及组常见的几块：整除与素数、质因数分解、筛法、最大公约数 / 最小公倍数、快速幂。

### 整除与素数

对于整数 $n,m$，如果存在整数 $q$ 使得 $n=q\times m$，就说 $m$ 整除 $n$，记作 $m\mid n$；$m$ 是 $n$ 的因数，$n$ 是 $m$ 的倍数。否则记作 $m\nmid n$。

如果一个数 $n$ 的正因数只有 $1$ 和它自己，且 $n\ne1$，则 $n$ 是**质数**。

### 素性测试

判断一个数是不是质数。暴力做法枚举 $2\sim n-1$，看是否存在 $i\mid n$；时间复杂度 $O(n)$。

一个数 $n$ 最多只有一个质因数大于等于 $\sqrt n$：若存在两个不同的质因数 $p_1,p_2\ge\sqrt n$，则 $p_1p_2>n$，矛盾。因此试除只需要枚举到 $\sqrt n$。判断时也只需要判断是否存在质因数，因为任何合数因数都能继续分解成质因数。

### 质因数分解

沿用试除法：在 $2\sim\sqrt n$ 中枚举 $i$，如果 $i\mid n$，就不断除以 $i$ 直到除不尽，并记录指数；最后若 $n\ne1$，剩下的 $n$ 本身就是一个质因子。时间复杂度 $O(\sqrt n)$。

这样做正确的原因是：循环从 $2$ 开始，若当前 $i\mid n$，$i$ 一定是质数；否则它会被自己的质因子在之前除干净。

### 唯一分解定理

任意整数 $n$ 都可以唯一表示为

$$
n=p_1^{\alpha_1}p_2^{\alpha_2}\cdots p_k^{\alpha_k},
$$

其中 $p_i$ 是质数。这个定理是 gcd、lcm、约数个数、约数和等公式的基础。

### 筛法

质数定理：$1\sim n$ 内的质数数量 $\pi(n)\sim\dfrac{n}{\ln n}$（这里只记结论）。

- **朴素筛**：从 $2$ 开始，把每个数的倍数都筛掉；时间 $O(n\log n)$。
- **埃氏筛**：只用一个数筛它的倍数，且只对质数筛；时间 $O(n\log\log n)$。
- **线性筛（欧拉筛）**：让每个合数只被它的最小质因子筛一次；时间 $O(n)$。

线性筛的核心：对每个 $i$，用已得到的质数 $p_j$ 去筛 $i\cdot p_j$，当 $i\bmod p_j=0$ 时退出。这样每个合数 $x$ 只会被它的最小质因子筛到。

### gcd 与 lcm

最大公因数 $\gcd(a,b)$ 用辗转相除法：

```pseudocode
function gcd(a, b)
    if b == 0
        return a
    return gcd(b, a % b)
```

用到的性质：

- $\gcd(a,b)=\gcd(b,a)$；
- $\gcd(a,0)=a$；
- $\gcd(a,b)=\gcd(b,a\bmod b)$。

第三条的证明：设 $c=a\bmod b$，$a=kb+c$。若 $d\mid a,d\mid b$，则 $d\mid c$；反过来若 $d\mid b,d\mid c$，则 $d\mid a$。两组数的公因子相同，所以最大公因数相同。

时间复杂度 $O(\log\max(a,b))$。若 $\gcd(a,b)=1$，称 $a,b$ 互质；相邻整数总是互质。

内置函数：`__gcd(a,b)` 是 GCC 扩展，`std::gcd(a,b)` 是 C++17 标准；OI 常用环境是 C++14，建议手写。负数可以先取绝对值。

多个数的 gcd 依次求即可：

```pseudocode
g <- 0
for i <- 1 to n
    g <- gcd(g, a[i])
```

更相减损术：$\gcd(a,b)=\gcd(a-b,b)$；多个数时有 $\gcd(a,b,c,\cdots)=\gcd(a,\gcd(b-a,c-a,\cdots))$。

最小公倍数：

$$
\operatorname{lcm}(a,b)=\frac{ab}{\gcd(a,b)}.
$$

证明用唯一分解定理：$ab$ 中每个质因子的指数是 $\alpha_i+\beta_i$，$\gcd$ 取 $\min$，$\operatorname{lcm}$ 取 $\max$，而 $\min+\max=\alpha+\beta$。

多个数的 lcm 也依次求，不能直接用“乘积除以总 gcd”：

$$
\operatorname{lcm}(a,b,c)\ne\frac{abc}{\gcd(a,b,c)}.
$$

例如 $a=2,b=3,c=6$：$\operatorname{lcm}(2,3,6)=6$，而 $\dfrac{2\cdot3\cdot6}{\gcd(2,3,6)}=\dfrac{36}{1}=36$，两者不相等。

### 快速幂

要求 $a^b\bmod P$。把 $b$ 二进制拆分：

$$
b=2^{k_1}+2^{k_2}+\cdots,
$$

$$
a^b=a^{2^{k_1}}\cdot a^{2^{k_2}}\cdots.
$$

一边把 $b$ 右移，一边让 $a$ 自乘，遇到二进制位为 $1$ 就把当前的 $a$ 乘进答案。时间复杂度 $O(\log b)$。

快速幂还能在每一步取模，避免结果溢出：

```pseudocode
function quick_pow(a, b, P)
    res <- 1
    while b > 0
        if b & 1
            res <- res * a % P
        a <- a * a % P
        b <- b >> 1
    return res
```

## 核心公式 / 状态定义与转移方程

- 整除：$m\mid n\iff \exists q,\ n=qm$。
- 试除上界：只需枚举到 $\sqrt n$；若 $i\mid n$ 且 $i\le\sqrt n$，则 $n/i$ 是另一个因数。
- 唯一分解：$n=\prod p_i^{\alpha_i}$。
- 约数个数：$d(n)=\prod(\alpha_i+1)$；约数和：$\sigma(n)=\prod\dfrac{p_i^{\alpha_i+1}-1}{p_i-1}$。
- 埃氏筛：对每个质数 $p$，筛掉 $p^2,p^2+p,\dots$；时间 $O(n\log\log n)$。
- 线性筛：`if (i % p[j] == 0) break;`，每个合数只被最小质因子筛一次。
- 欧几里得：$\gcd(a,b)=\gcd(b,a\bmod b)$，$\gcd(a,0)=a$。
- lcm：$\operatorname{lcm}(a,b)=\dfrac{ab}{\gcd(a,b)}$；多个数依次求。
- 快速幂：$a^b=(a^2)^{\lfloor b/2\rfloor}\cdot a^{b\bmod 2}$。
- 龟速乘：$ab=2a\lfloor b/2\rfloor+a\cdot[b\bmod 2]$，用于模数很大且乘法溢出的情况。

## 逐行代码解析

### 试除法判断质数

```cpp
bool is_prime(long long n) {
    if (n < 2) return false;
    for (long long i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
    }
    return true;
}
```

- `n < 2` 直接排除 $0,1$ 和负数。
- 循环条件 `i * i <= n` 等价于 $i\le\sqrt n$；用 `i <= n / i` 可以避免 `i*i` 溢出。
- 找到一个因子就返回 `false`；循环结束仍未找到则是质数。

### 质因数分解

```cpp
vector<pair<long long, int>> factorize(long long n) {
    vector<pair<long long, int>> res;
    for (long long i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            int cnt = 0;
            while (n % i == 0) {
                n /= i;
                cnt++;
            }
            res.push_back({i, cnt});
        }
    }
    if (n > 1) res.push_back({n, 1});
    return res;
}
```

- 外层枚举到 $\sqrt n$；找到因子后不断除，统计指数。
- 循环结束后若 $n>1$，剩下的 $n$ 是质因子，指数为 $1$。
- 时间复杂度 $O(\sqrt n)$。

### 埃氏筛

```cpp
vector<int> primes;
vector<bool> is_comp(n + 1, false);
for (int i = 2; i <= n; i++) {
    if (!is_comp[i]) {
        primes.push_back(i);
        for (long long j = 1LL * i * i; j <= n; j += i) {
            is_comp[j] = true;
        }
    }
}
```

- 从 $i^2$ 开始筛，因为小于 $i^2$ 的倍数已经被更小的质数筛过。
- `1LL * i * i` 防止 `int` 溢出。
- 时间 $O(n\log\log n)$。

### 线性筛

```cpp
vector<int> primes;
vector<bool> is_comp(n + 1, false);
for (int i = 2; i <= n; i++) {
    if (!is_comp[i]) primes.push_back(i);
    for (int p : primes) {
        if (1LL * i * p > n) break;
        is_comp[i * p] = true;
        if (i % p == 0) break;
    }
}
```

- 每个合数只被它的最小质因子筛一次。
- `i % p == 0` 时退出，保证之后不会用更大的质因子重复筛。
- 时间 $O(n)$。

### GCD 与 LCM

```cpp
long long gcd(long long a, long long b) {
    return b == 0 ? a : gcd(b, a % b);
}

long long lcm(long long a, long long b) {
    return a / gcd(a, b) * b;
}
```

- `lcm` 先除后乘，降低溢出风险。
- 负数先取绝对值；`gcd(0,0)` 按题目约定处理。

### 快速幂

```cpp
long long qpow(long long a, long long b, long long p) {
    long long res = 1 % p;
    a %= p;
    while (b > 0) {
        if (b & 1) res = res * a % p;
        a = a * a % p;
        b >>= 1;
    }
    return res;
}
```

- `res = 1 % p` 处理 $p=1$ 的情况。
- `a %= p` 先归一化，负数底数也能处理。
- 每一步取模，避免溢出。

## 复杂度分析

| 操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 试除法判质数 | $O(\sqrt n)$ | $O(1)$ |
| 质因数分解 | $O(\sqrt n)$ | $O(\log n)$（因子个数） |
| 埃氏筛 | $O(n\log\log n)$ | $O(n)$ |
| 线性筛 | $O(n)$ | $O(n)$ |
| 欧几里得 gcd | $O(\log\min(a,b))$ | $O(1)$（递归栈 $O(\log)$） |
| lcm（已知 gcd） | $O(1)$ | $O(1)$ |
| 快速幂 | $O(\log b)$ | $O(1)$ |

## 适用场景

- 判断单个数是否质数：试除法（$n\le10^{12}$ 左右可用）。
- 分解单个数：试除法；更大的数需要 Pollard-Rho 等高级算法。
- 预处理 $1\sim n$ 的质数：埃氏筛或线性筛；需要最小质因子/积性函数时用线性筛。
- 约分、比例、周期、同余：gcd / lcm。
- 模意义下的大指数幂、矩阵快速幂、递推加速：快速幂。
- 模数很大且乘法溢出：龟速乘（现代环境也可用 `__int128`）。

## 常见陷阱与注意事项

1. **试除上界写成 $i<n$**：会退化成 $O(n)$；应写 $i\le\sqrt n$ 或 `i <= n / i`。
2. **`i*i` 溢出**：`int` 的 `i*i` 在 $i$ 接近 $10^9$ 时会溢出；用 `1LL*i*i` 或 `i <= n/i`。
3. **质因数分解漏掉剩余的 $n$**：循环结束后若 $n>1$，还要把它加入答案。
4. **筛法从 $i$ 开始而不是 $i^2$**：不影响正确性但会重复筛；从 $i^2$ 开始更高效。
5. **线性筛忘记 `break`**：会导致重复筛，复杂度退化。
6. **lcm 先乘后除溢出**：写成 `a / gcd(a,b) * b`。
7. **多个数的 lcm 公式用错**：不能用“乘积除以总 gcd”，要依次求。
8. **`__gcd` 处理负数**：先取绝对值；`std::gcd` 可以处理负数。
9. **快速幂 `p=1`**：`res` 应初始化为 `1 % p`，否则返回 $1$ 而不是 $0$。
10. **底数为负**：先 `a %= p` 归一化；指数为负需要逆元，不是普通快速幂。

## 对比与扩展

- **试除法 vs 筛法**：单个数用试除；多组查询/预处理用筛法。
- **埃氏筛 vs 线性筛**：埃氏筛好写，$O(n\log\log n)$；线性筛 $O(n)$，还能顺便求最小质因子、欧拉函数、约数个数等。
- **gcd vs 更相减损术**：欧几里得用取模，复杂度 $O(\log V)$；更相减损术在数值差距大时可能很慢。
- **快速幂 vs 龟速乘**：快速幂解决“指数大”，龟速乘解决“乘积溢出”，两者可以组合。
- **讲义练习**：P1185、A3042、G1033、A2017、TW1141、G1063、G1043、G1157、P1187、G1094、ABC170D、P1500、ABC172D、A3090、G1127、P1108、TW4031、ABC445E、P1194、P1257、CF2200E、P1504、A2067、CF2216D。题号以原讲义为准，部分为训练平台题号。
