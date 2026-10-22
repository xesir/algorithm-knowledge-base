---
id: dp-opt-sos
title: 'SOS DP（子集和 / 高维前缀和）'
category: 动态规划
subcategory: DP优化
subSubcategory: ''
tags: ["动态规划", "DP优化", "SOS DP", "子集和", "高维前缀和", "状压"]
timeComplexity: '朴素 O(3^n) / 迭代 O(n·2^n)'
spaceComplexity: 'O(2^n)'
level: A
codePath: '动态规划\DP优化\SOS子集和\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

SOS DP（Sum Over Subsets DP）本质上是**高维前缀和在二进制位上的应用**。它的作用是在 $O(n \cdot 2^n)$ 的时间内求出每个集合的所有子集（或超集）的贡献和。

高维前缀和的核心思想是：**在每个维度上独立做一次一维前缀和**。当维度是二进制位（取值只有 0 和 1）时，高维前缀和就变成了 SOS DP。

## 核心公式 / 状态定义与转移方程

给定长度为 $2^n$ 的数组 $f[mask]$，定义：

$$
F[mask] = \sum_{sub \subseteq mask} f[sub]
$$

即对每个 mask，求它所有子集的和。把每一位看作一个维度，$F$ 就是 $n$ 维数组的前缀和。

- **朴素做法**：枚举每个 mask，再枚举它的所有子集。
- **迭代做法**：按位逐维累加。

## 逐行代码解析

### 朴素子集枚举

```cpp
for (int mask = 0; mask < (1 << n); mask++)
    for (int sub = mask; ; sub = (sub - 1) & mask) {
        F[mask] += f[sub];
        if (sub == 0) break;
    }
```

- 外层枚举 `mask`，内层用 `sub = (sub - 1) & mask` 枚举 `mask` 的所有子集（从 `mask` 本身一路往下减）。
- 到 `sub == 0` 时手工 `break` 收尾。
- 总复杂度 $O(3^n)$：每个元素有三种状态（不在 mask 中、在 mask 中不在 sub 中、在 sub 中）。

### 迭代做法

```cpp
for (int i = 0; i < n; i++)          // 枚举每一位
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))         // 如果这一位是 1
            f[mask] += f[mask ^ (1 << i)];
```

- 外层枚举每一位 $i$（共 $n$ 个维度），内层扫所有 mask。
- 只对第 $i$ 位为 1 的 mask 累加：它的子集里把第 $i$ 位取 0 的那个 `mask ^ (1 << i)` 已经先算好了，直接加进来。
- 复杂度 $O(n \cdot 2^n)$，远优于 $O(3^n)$。

![](https://r2.xsimple-r2.com/gpt-image/497651/116e62d5-5d8c-41b2-81aa-c3e8c5a3bce8.png)

### 子集和模板（求所有子集的和）

```cpp
for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))
            f[mask] += f[mask ^ (1 << i)];
```

### 超集和模板（求所有超集的和）

```cpp
for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (!(mask & (1 << i)))
            f[mask] += f[mask | (1 << i)];
```

- 只需把判断条件反过来（`!(mask & (1 << i))`），累加方向也随之反转（从 `mask | (1 << i)` 加过来）。

## 复杂度分析

- 朴素子集枚举：$O(3^n)$。
- 迭代 SOS DP：$O(n \cdot 2^n)$。把「枚举每个 mask 的全部子集」拆成「按维度逐个累加」，一维只花 $O(2^n)$，共 $n$ 维。
- 空间复杂度：$O(2^n)$，在原数组 `f` 上原地累加，不需要额外数组。

## 适用场景

- **子集计数**：统计每个 mask 有多少个子集满足某种性质。
- **子集最值**：维护每个 mask 的所有子集中的最大值、次大值（如 Or Plus Max）。
- **超集统计**：统计每个 mask 的所有超集的信息。
- **状压 DP 预处理**：在状压 DP 中快速合并子集信息，避免枚举子集。
- **子集卷积**：SOS DP 是子集卷积的前置步骤。

## 常见陷阱与注意事项

1. **子集 / 超集的判断条件别写反**：子集和是 `mask & (1 << i)`（该位为 1 才累加），超集和是 `!(mask & (1 << i))`（该位为 0 才累加）。
2. **累加来源的下标要对应**：子集和从 `mask ^ (1 << i)`（清掉这一位）来，超集和从 `mask | (1 << i)`（补上这一位）来，别混。
3. **`n` 是位数不是元素个数**：数组长度是 $2^n$，循环上界写 `1 << n`，别漏了括号。
4. **原地累加**：`f[mask]` 直接在原数组上覆盖，保证依赖的 `f[mask ^ ...]` 是上一层（已处理完前面维度）的值，别把顺序改乱。
