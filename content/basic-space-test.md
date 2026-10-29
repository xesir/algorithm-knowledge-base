---
id: basic-space-test
title: '空间测试'
category: '实用工具'
subcategory: '调试'
subSubcategory: '时空测试'
tags: ['空间测试', '内存', 'sizeof', '调试']
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-25
---

## 算法原理

空间测试是在本地估算或测量程序占用了多少内存，用来判断会不会 MLE（Memory Limit Exceeded）。它和时间测试是一对：时间测试回答“跑得够不够快”，空间测试回答“占得够不够小”。

竞赛程序的内存通常来自四块：

- **静态/全局区**：全局数组、全局 `vector` 的元信息等，编译后大小基本固定。
- **栈区**：局部变量、递归调用帧；深递归是常见的 MLE 来源。
- **堆区**：`new`、`malloc`、`vector`/`string`/`map` 等容器动态申请的内存。
- **运行时开销**：程序本身、标准库、OJ 的评测进程等，通常有几 MB 到几十 MB。

常用手段分两类：

1. **估算**：按“元素个数 × 单元素大小”逐项相加，适合赛前设计数据范围。
2. **实测**：用 `sizeof`、容器 `capacity()`、`getrusage()` 或读取 `/proc/self/status` 得到实际占用。

估算能提前发现“数组开不下”，实测能发现“容器扩容、递归栈、运行时开销”这些容易漏掉的部分。

## 核心公式 / 状态定义与转移方程

**数组/静态内存**：

$$
\text{bytes} = n \times \texttt{sizeof}(T)
$$

**`vector`**：

$$
\text{bytes} \approx \texttt{capacity}() \times \texttt{sizeof}(T)
$$

注意是 `capacity()` 而不是 `size()`：扩容后容量可能远大于实际元素个数。

**邻接表**：

$$
\text{bytes} \approx n \times \texttt{sizeof(vector)} + 2m \times \texttt{sizeof(edge)}
$$

**递归栈**：

$$
\text{bytes} \approx \text{递归深度} \times \text{每层栈帧大小}
$$

**实测 RSS**：Linux 下 `getrusage(RUSAGE_SELF, &ru)` 的 `ru_maxrss` 表示峰值常驻内存，单位通常是 KB；macOS 上单位是字节，需要按平台区分。

## 逐行代码解析

本篇不附完整程序，只给关键测量片段；完整的时间测试写法见 [时间测试](#basic-timing)。

### 静态类型大小

```cpp
sizeof(int);
sizeof(long long);
sizeof(vector<int>);
```

- `sizeof` 是编译期运算符，返回类型或对象的字节数。
- `sizeof(vector<int>)` 只是一个空 vector 对象的大小，不包含它将来申请的元素内存。
- 对指针使用 `sizeof` 得到的是指针大小，不是它指向的数组大小。

### 容器容量

```cpp
vector<int> v;
v.capacity();
v.size();
```

- `capacity()` 是当前已分配的元素槽位数，`size()` 是实际元素个数。
- 估算 `vector` 内存时用 `capacity() * sizeof(int)`，不要用 `size()`。
- `string`、`deque`、`map` 等容器的实际占用还与实现细节有关，粗略估算时按容量与节点开销相加。

### 进程峰值内存

```cpp
#include <sys/resource.h>
rusage ru;
getrusage(RUSAGE_SELF, &ru);
ru.ru_maxrss;
```

- `ru_maxrss` 是进程运行到当前的峰值常驻内存。
- Linux 下通常以 KB 为单位，macOS 下以字节为单位；跨平台使用时要先确认单位。
- 这是“进程级”数据，包含运行时与标准库开销，不只是你的数组。

### 读取 `/proc/self/status`

```text
VmRSS:  当前常驻内存
VmHWM:  峰值常驻内存
```

- Linux 下可以直接读取 `/proc/self/status`，解析 `VmRSS` 与 `VmHWM`。
- 单位通常是 KB；不同内核版本可能有差异。
- 这种方法只适用于 Linux 本地测试，不能依赖它在 OJ 上运行。

## 复杂度分析

- **估算**：遍历数据结构的定义逐项相加，通常是 $O(1)$ 或 $O(n)$（需要遍历容器容量时）。
- **实测**：`sizeof` 是编译期 $O(1)$；`getrusage` 是系统调用，近似 $O(1)$。
- **空间测试本身**：不改变被测试程序的渐进空间复杂度；它只是观测手段。

## 适用场景

- 赛前按数据范围估算数组、邻接表、DP 表、线段树是否开得下。
- 本地复现 MLE，判断是静态数组、容器扩容还是递归栈导致。
- 对比不同实现的内存占用，例如 `vector` 与手写数组、`map` 与离散化+数组。
- 不适合：OJ 不提供系统调用或 `/proc` 时，只能靠估算；不要依赖实测代码提交。

## 常见陷阱与注意事项

- **只看 `sizeof`**：`sizeof(vector)` 不包含堆上的元素内存。
- **用 `size()` 代替 `capacity()`**：扩容后的容量可能远大于元素个数。
- **忽略递归栈**：深递归可能比全局数组更早触发 MLE。
- **忽略运行时开销**：OJ 的进程本身、标准库和评测环境会占几 MB 到几十 MB。
- **单位混淆**：`ru_maxrss` 在 Linux 是 KB、macOS 是字节；`/proc/self/status` 通常是 KB。
- **虚拟内存不等于常驻内存**：`VSZ` 可能很大，但实际占用看 `RSS`。
- **页对齐与分配器开销**：小块内存分配有额外元数据，估算值通常偏小。
- **32/64 位差异**：指针、`size_t`、结构体对齐都会改变大小。

## 对比与扩展

- **与时间测试**：时间测试用 `clock()` 测 CPU 时间；空间测试用 `sizeof`/`getrusage`/`/proc` 测内存。两者都不改变算法复杂度，只用于验证。
- **与离散化**：离散化把值域从 $O(V)$ 压到 $O(n)$，是最常用的“降空间”手段之一。
- **与 bitset**：bitset 用 $O(n/8)$ 字节表示布尔数组，比 `bool` 数组省 8 倍空间，同时把运算压到 $O(n/64)$。
- **与内存分析工具**：本地可以用 Valgrind、AddressSanitizer 或 IDE 的内存分析器；竞赛中更常用估算与 `getrusage`。

相关条目：[时间测试](#basic-timing)
