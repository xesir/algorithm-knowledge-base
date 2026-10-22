---
id: gram-builtin
title: '`__builtin` 全家桶'
category: 语法技巧
subcategory: 内建函数
subSubcategory: ''
tags: ["__builtin", "位运算", "状压DP", "popcount", "clz", "ctz"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

`__builtin` 是 GCC/Clang 提供的一组**编译器内置函数**，它们直接映射到 CPU 指令（或者很短的位运算序列），**常数极小**，常用于位运算加速。因为编译器认识它们，所以不会被当成普通函数调用，从根上就没有函数调用开销。

OI 里最常打交道的几位：`popcount`（数 1）、`clz` / `ctz`（数前导零 / 末尾零）、`ffs`（最低位 1 的位置）、`parity`（1 的个数的奇偶性）。它们几乎都是 $O(1)$，是位运算题和状压 DP 的老朋友。

## 逐行代码解析

### 常用函数一览表

| 函数 | 功能 | 返回类型 | 复杂度 | 适用场景 |
|------|------|---------|--------|---------|
| `__builtin_popcount(x)` | 二进制中 1 的个数（32 位） | `int` | $O(1)$（硬件指令） | 状压 DP、位运算计数 |
| `__builtin_clz(x)` | 前导零个数（32 位，x>0） | `int` | $O(1)$ | 求最高位、快速 log2 |
| `__builtin_ctz(x)` | 末尾零个数（32 位，x>0） | `int` | $O(1)$ | 提取最低位 1、`lowbit` 的变种 |
| `__builtin_ffs(x)` | 最低位 1 的位置（从 1 开始） | `int` | $O(1)$ | 等同于 `ctz(x)+1` |
| `__builtin_parity(x)` | 二进制中 1 的奇偶性 | `int` | $O(1)$ | 校验、哈希 |

- 处理 `long long` 时函数名末尾加 `ll`，如 `__builtin_popcountll(x)`；`clz` / `ctz` 也有 `ll` 版。

### 枚举子集（状压常用）

```cpp
int S = 0b10110;
for (int sub = S; sub; sub = (sub - 1) & S) {
    int cnt = __builtin_popcount(sub);  // 当前子集的元素个数
}
```

- 枚举子集的经典套路：`sub = (sub - 1) & S` 依次枚举 $S$ 的所有非空子集。
- 顺手用 `popcount` 数出当前子集大小，比循环数位快得多。

### 快速求 log2（最高位）

```cpp
int msb = 31 - __builtin_clz(x);        // 对于 32 位整数
int msb64 = 63 - __builtin_clzll(x);    // 对于 64 位
```

- 最高位下标 = 位宽减 1 再减前导零个数，这就是 `clz` 最常见的用法。

### 提取最低位的 1

```cpp
int low = x & -x;                       // 经典 lowbit
int idx = __builtin_ctz(x);             // 最低位 1 的下标（从 0 开始）
```

- `x & -x` 取出最低位的 1 本身，`ctz` 取出它的下标，两者配合树状数组很常见。

### 判断是否为 2 的幂

```cpp
bool is_power_of_two = (x > 0) && (__builtin_popcount(x) == 1);
```

- 2 的幂在二进制里只有一个 1，用 `popcount == 1` 判断即可（别忘了 `x > 0`）。

### 枚举所有 1 位的位置

```cpp
for (int t = x; t; t &= t - 1) {
    int pos = __builtin_ctz(t);         // 当前最低 1 的位号
    // 处理 pos
}
```

- `t &= t - 1` 每次都消掉最低位的 1，循环次数正好是 1 的个数。

## 复杂度分析

这些函数基本都是**单条 CPU 指令**或常数条位运算，复杂度统一 $O(1)$：

- `popcount`：多数平台有专用指令，一条搞定。
- `clz` / `ctz`：同样有硬件指令（`BSR` / `BSF` 之类），常数极小。
- `parity` / `ffs`：由上面的指令组合而来，依然是常数级。

相比手写 while 循环数位，它们把 $O(\text{位数})$ 压成 $O(1)$，在状压题里累积起来差别明显。

## 适用场景

- 状压 DP：`popcount` 数集合大小，`lowbit` + `ctz` 取最低位。
- 位运算题：快速求最高位（`clz`）、最低位（`ctz`）、1 的个数（`popcount`）。
- 枚举子集 / 枚举二进制位：配合 `(sub-1)&S`、`t &= t-1` 两个套路。
- 需要「高效 log2」时，`31 - clz(x)` 比库函数 `log2` 更快更准。
- 判断 2 的幂、奇偶校验、哈希等零碎场景。

## 常见陷阱与注意事项

1. **`clz` / `ctz` 对 $x=0$ 未定义**：调用前必须保证 $x > 0$，否则结果没有意义（甚至可能读出随机值）。
2. **参数类型要匹配**：32 位函数配 `unsigned int`，64 位配 `unsigned long long`，用 `ll` 后缀版，类型混用可能出错。
3. **返回值是 `int`**：`popcount` 返回 `int`，别当成 `bool` 用；`parity` 返回 0/1 表示偶数/奇数个 1。
4. **`ffs` 从 1 开始计数**：`__builtin_ffs(x)` 等价 `__builtin_ctz(x) + 1`，数下标时注意起点。
5. **MSVC 下不存在这些函数**：跨平台需自己实现；OI 大多用 GCC，放心用。
6. **别和 std:: 版本混用**：C++20 的 `<bit>` 提供了 `std::popcount`、`std::countr_zero` 等，OJ 支持度不一，`__builtin` 仍是主流。

## 对比与扩展

| 需求 | `__builtin` 写法 | 手写版本 |
|---|---|---|
| 数 1 的个数 | `__builtin_popcount(x)` | `x &= x - 1` 循环 |
| 最高位下标 | `31 - __builtin_clz(x)` | while 移位 |
| 最低位下标 | `__builtin_ctz(x)` | while 移位 |
| 是否 2 的幂 | `__builtin_popcount(x) == 1` | `x & (x-1)` |

扩展：

- C++20 的 `<bit>`：`std::popcount`、`std::countr_zero`、`std::bit_width` 等，语义更安全，但要注意 OJ 支持度。
- `x & (x-1)` 消最低位 1、`x & -x` 取最低位 1，这两个位运算技巧和 `__builtin` 是黄金搭档。
