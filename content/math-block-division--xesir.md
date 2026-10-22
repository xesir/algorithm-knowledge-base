---
id: math-block-division
title: '整除分块'
category: 数学
subcategory: 数论基础
subSubcategory: '数论函数'
tags: ["数学", "数论", "整除分块", "根号复杂度"]
timeComplexity: 'O(√n)'
spaceComplexity: 'O(1)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

> 引入：

给定一个 $n$，求 $\sum_{i=1}^{n} \left\lfloor \frac{n}{i} \right\rfloor$。

你可能会想：这还不简单，直接对于每个 $i$ 求一遍 $\frac{n}{i}$ 下取整的值，再求和不就行了？

你说的对，但是这个算法是 $O(n)$ 的，要怎么处理 $n \le 10^9$ 的数据呢？

整除分块，一个简单但好用的数论思想，用于解决整除类相关的统计问题。

> ~~和分块数据结构并没有什么关系~~

整除有一个重要性质：随着 $i$ 增加，$\lfloor \frac{n}{i} \rfloor$ 单调不增。这使得 $\lfloor \frac{n}{i} \rfloor$ 的每个值在数组中连续。

首先我们有一个很敏锐的观察：虽然 $n$ 很大，但 $\lfloor \frac{n}{i} \rfloor$ 的情况总数并不多。比如 $n = 21$ 时，$\lfloor 21/i \rfloor$ 依次是 $21, 10, 7, 5, 4, 3, 3, 3, 2, 2, 2, \dots$，越往后越稀疏、重复越多。

我们可以证明：$\lfloor \frac{n}{i} \rfloor$ 的情况总数严格不超过 $2\sqrt n$。

- 对于 $i \le \sqrt n$：$i$ 只有 $\sqrt n$ 个，$\lfloor \frac{n}{i} \rfloor$ 至多 $\sqrt n$ 种取值。
- 对于 $i \ge \sqrt n$：$\lfloor \frac{n}{i} \rfloor \le \sqrt n$，也至多 $\sqrt n$ 种取值。

所以我们只需要计算出每个连续块的左边界与右边界，就可以在 $O(\sqrt n)$ 时间内得到答案。

如何计算呢？我们可以很容易得到 $i$ 所在块的右端点是 $\left\lfloor \frac{n}{\lfloor n/i \rfloor} \right\rfloor$，那么每次转移只需要 `r = n / (n / l)` 即可。

## 核心公式 / 状态定义与转移方程

设当前块的左端点为 $l$，则该块内所有 $i$ 的 $\lfloor n/i \rfloor$ 都相同，右端点为

$$
r = \left\lfloor \frac{n}{\left\lfloor n/l \right\rfloor} \right\rfloor
$$

这个式子的意思是：既然这一段的值是 $v = \lfloor n/l \rfloor$，那么所有满足 $\lfloor n/i \rfloor = v$ 的 $i$ 里最大的那个就是 $\lfloor n/v \rfloor$，因为 $i \le n/v$ 时 $n/i \ge v$，而 $i > n/v$ 时 $n/i < v$。

下一块的左端点直接取 $r + 1$，区间贡献计入后继续，直到 $l > n$。

## 逐行代码解析

原文给的是伪代码，这里逐行拆开看：

### 模块一：块循环骨架

```cpp
for(int l=1;l<=n;l=r+1){
    r=min(n,n/(n/l));
    cnt+=s(l,r)*(n/l);
}
```

- `l = 1` 起步，`l = r + 1` 跳到下一块的开头，`l <= n` 时一直做下去。
- `r = min(n, n/(n/l))` 算出当前块的右端点；`min(n, ...)` 是防止最后一块算出超过 $n$ 的值。
- `n / l` 就是这一整块的 $\lfloor n/i \rfloor$ 值，所以可以直接乘以区间贡献。

### 模块二：`s(l, r)` 该写什么

`cnt += s(l,r) * (n/l)` 里的 `s(l, r)` 表示 $[l, r]$ 这一段的"贡献系数"。原题求 $\sum \lfloor n/i \rfloor$ 时，每项系数都是 1，所以 `s(l, r) = r - l + 1`，整块就是 `(r - l + 1) * (n / l)`。

换成别的题时，`s(l, r)` 一般是某个可以 $O(1)$ 求和的式子（比如 $\sum i$、$\sum i^2$、$\sum f(i)$），预处理前缀和即可。

若 `s(l, r)` 可以 $O(1)$ 求出，则整体复杂度为 $O(\sqrt n)$。

## 复杂度分析

块的数量不超过 $2\sqrt n$，每块内部 $O(1)$，所以总时间复杂度 $O(\sqrt n)$，额外空间 $O(1)$（如果 `s(l,r)` 需要前缀和，则是 $O(n)$ 预处理、$O(n)$ 空间）。

和直接枚举的对比很直观：$n = 10^9$ 时，$O(n)$ 是 $10^9$ 次运算，$O(\sqrt n)$ 只有约 $6.3 \times 10^4$ 次。

## 适用场景

- **整除求和**：$\sum_{i=1}^{n} f(\lfloor n/i \rfloor)$ 这一类，把相同取值的段合并。
- **数论函数求和**：配合莫比乌斯反演、欧拉反演，把 $\sum_{i,j}\gcd(i,j)$ 化成 $\sum_d \varphi(d)\lfloor n/d\rfloor^2$ 之后再用整除分块算。
- **杜教筛 / 洲阁筛**：这些高级筛法的递归过程中，$\lfloor n/i \rfloor$ 的取值同样只有 $O(\sqrt n)$ 种，本质上也是整除分块。
- **求 $\sum_{i=1}^{n} \lfloor n/i \rfloor$ 类计数**：比如统计约数个数和。

## 常见陷阱与注意事项

1. **忘了 `min(n, ...)`**：最后一块的 `n/(n/l)` 可能超过 $n$，不加 `min` 会多算。
2. **整数除法方向**：C++ 的 `/` 对正数是向下取整，正好符合这里的需求；但涉及负数时（比如某些推式子）方向就反了。
3. **`l = r + 1` 写成 `l++`**：那就退化成 $O(n)$ 了，白算。
4. **块内取值不是 `n/l`**：块内 $\lfloor n/i \rfloor$ 的值确实等于 `n/l`（左端点的值），但别顺手写成 `n/r`，那是右端点的值，通常是更小的。
5. **`s(l, r)` 不能 $O(1)$ 求时别硬套**：如果贡献需要 $O(\text{len})$ 才能算，整除分块就失去意义了。
