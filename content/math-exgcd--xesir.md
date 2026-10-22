---
id: math-exgcd
title: '裴蜀定理与扩展欧几里得（EXGCD）'
category: 数学
subcategory: 数论基础
subSubcategory: '同余与模运算'
tags: ["数学", "数论", "裴蜀定理", "扩展欧几里得", "EXGCD", "逆元", "线性同余方程"]
timeComplexity: 'O(log min(a,b))'
spaceComplexity: 'O(log min(a,b))'
level: A
codePath: '数学\数论基础\扩展欧几里得\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

### 裴蜀定理

**定理内容**：对于**不全为零**的整数 $a, b$，**一定存在**整数 $x, y$，使得：

$$
ax + by = \gcd(a, b)
$$

也就是说，$a$ 和 $b$ 的最大公约数，一定能被表示成它们的某个整系数线性组合。

**反过来也成立**：如果某个整数 $d$ 能表示成 $ax + by$ 的形式，那么 $d$ **一定是 $\gcd(a, b)$ 的倍数**。

**证明思路**：用辗转相除法倒推。辗转相除的每一步都能写成“被除数 = 商 × 除数 + 余数”，从最后一步往前代换，就能把 $\gcd(a,b)$ 表示成 $a$ 和 $b$ 的线性组合。

**有什么用？** 最直接的应用：**判断一个方程有没有整数解**。

比如方程 $ax + by = c$ 有整数解，当且仅当 $\gcd(a,b) \mid c$。有了这个结论，你就不用傻傻地枚举 $x, y$ 了，看一眼整除关系就完事。

> 裴蜀定理本身不告诉我们怎么快速找到 $x, y$，求解需要依赖**扩展欧几里得**算法。

### 扩展欧几里得算法（EXGCD）

**它要解决的问题**：给定 $a, b$，求一组整数解 $(x, y)$，使得：

$$
ax + by = \gcd(a, b)
$$

~~裴蜀定理的施工队~~

扩展欧几里得是**在辗转相除的过程中顺手把 $x, y$ 也算出来**。回顾辗转相除法：

$$
\gcd(a, b) = \gcd(b, a \bmod b)
$$

假设我们已经求出了 $b$ 和 $a \bmod b$ 的线性组合：

$$
b \cdot x_2 + (a \bmod b) \cdot y_2 = \gcd(b, a \bmod b)
$$

而 $a \bmod b = a - \lfloor a/b \rfloor \cdot b$，代入上式：

$$
b \cdot x_2 + (a - \lfloor a/b \rfloor \cdot b) \cdot y_2 = \gcd(a, b)
$$

整理一下：

$$
a \cdot y_2 + b \cdot \left( x_2 - \lfloor a/b \rfloor \cdot y_2 \right) = \gcd(a, b)
$$

于是我们就得到了递推关系：

$$
\begin{cases}
x_1 = y_2 \\
y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2
\end{cases}
$$

递归边界：当 $b = 0$ 时，$\gcd(a, 0) = a$，此时 $x = 1, y = 0$。

## 核心公式

| 内容 | 公式 |
|---|---|
| 裴蜀定理 | $ax + by = \gcd(a,b)$ 一定有整数解 |
| 有解判定 | $ax + by = c$ 有整数解 $\iff \gcd(a,b) \mid c$ |
| EXGCD 递推 | $x_1 = y_2,\ y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2$ |
| 递归边界 | $b=0$ 时 $x=1,\ y=0,\ \gcd=a$ |
| 求逆元 | $ax + my = 1$ 的解 $x$ 即 $a^{-1} \pmod{m}$ |
| 同余方程 | $ax \equiv b \pmod{m}$，$x_0 \cdot (b/\gcd)$ 为一组解 |

## 逐行代码解析

### 模块一：递归求解 $ax + by = \gcd(a,b)$

```cpp
// 返回gcd(a,b)，并输出x,y
ll exgcd(ll a, ll b, ll &x, ll &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
```

- `x, y` 是引用传参，递归返回时把当前层的解带回去。
- 边界 `b == 0`：$\gcd(a,0)=a$，此时 $a \cdot 1 + 0 \cdot 0 = a$，所以 `x = 1, y = 0`。
- 返回的 `d` 是最外层调用的 $\gcd(a,b)$，递归过程中一路原样上传。

```cpp
    ll d = exgcd(b, a % b, y, x); // 注意x和y的位置交换
    y -= (a / b) * x;             // 递推更新y
    return d;
}
```

- 注意实参写的是 `y, x` 而不是 `x, y`：这是把下一层的 $x_2$ 直接接到这一层的 $y_1$ 上，省掉一次赋值。
- 交换之后，`y` 里装的是下一层的 $x_2$，`x` 里装的是下一层的 $y_2$。
- `y -= (a / b) * x;` 实现的就是 $y_1 = x_2 - \lfloor a/b \rfloor \cdot y_2$。
- 递归返回后，`x, y` 满足 $ax + by = d$。

### 模块二：用它解线性同余方程

```cpp
// 解线性同余方程 ax ≡ b (mod m)，返回特解（无解返回-1）
ll sl(ll a, ll b, ll m) {
    ll x, y;
    ll d = exgcd(a, m, x, y);
    if (b % d != 0) return -1;
```

- 把 $ax \equiv b \pmod{m}$ 改写成 $ax + my = b$，所以调用 `exgcd(a, m, x, y)`。
- `d = gcd(a, m)`；若 $d \nmid b$，由裴蜀定理，方程无整数解，返回 `-1`。

```cpp
    ll m1 = m / d;
    x = (x * (b / d)) % m1;
    return (x + m1) % m1; // 确保解非负
}
```

- 先乘上 $b/d$，把 $ax+my=d$ 的特解放大成 $ax+my=b$ 的特解。
- 通解是 $x + k \cdot (m/d)$，所以最小正解对 `m1 = m / d` 取模。
- 最后 `(x + m1) % m1` 处理负数，保证返回非负解。

**注**：EXGCD 求出的可行解满足 $|x| \le b$，$|y| \le a$，一般不会爆 `long long`，可以放心用。

## 复杂度分析

- 时间复杂度：与辗转相除相同，递归层数为 $O(\log \min(a,b))$，每层常数次运算。
- 空间复杂度：递归栈深度 $O(\log \min(a,b))$。
- 单次求逆元、单次解线性同余方程都是这个量级，非常适合多次调用。

## 适用场景

- **求逆元**：解 $ax \equiv 1 \pmod{m}$，等价于 $ax + my = 1$。调用 `exgcd(a, m, x, y)`，得到的 $x$ 就是逆元。**不要求模数是质数**，只要 $\gcd(a, m) = 1$ 就行。
- **解线性同余方程**：$ax \equiv b \pmod{m}$ 有解当且仅当 $\gcd(a, m) \mid b$，解就是 $x_0 \cdot (b / \gcd)$。
- **解不定方程**：$ax + by = c$，先求 $ax + by = \gcd$ 的一组特解，再乘上 $c / \gcd$。
- **exCRT 的底层工具**：扩展中国剩余定理每次合并两个同余式，都要用 EXGCD 解一个形如 $M \cdot t \equiv a_k - a \pmod{m_k}$ 的方程。
- **求最小非负解**：通解 $x + k \cdot (m/d)$，对 $m/d$ 取模即可。

## 常见陷阱

1. **忘了判断 $d \nmid b$**：直接乘 $b/d$ 会用到整除，若不整除，算出来的“解”是错的。
2. **取模对象写错**：通解周期是 $m/\gcd(a,m)$，不是 $m$。对 $m$ 取模会漏解。
3. **负数解没处理**：C++ 的 `%` 可能返回负数，最后要 `(x % m1 + m1) % m1`。
4. **递归传参顺序**：`exgcd(b, a % b, y, x)` 的 `y, x` 是故意交换的，改成 `x, y` 就必须补上临时变量交换，否则递推式对不上。
5. **乘法溢出**：$x \cdot (b/d)$ 在 $a, b$ 接近 $10^{18}$ 时会爆 `long long`，需要 `__int128` 或龟速乘。
6. **`a` 或 `b` 为负数**：递归里 `a % b` 的符号随 `a`，边界和取模要额外小心，竞赛里一般先取绝对值再补符号。

---
> 裴蜀定理告诉你“有解”，EXGCD 告诉你“解是什么”。这两件事分清楚，很多数论题的思路就不会乱。
