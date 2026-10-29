---
id: hub-utility-stl
title: 'STL与pbds总述'
category: '实用工具'
subcategory: 'STL与pbds'
subSubcategory: '总述'
tags: ['STL', 'pb_ds', 'bitset', '总述']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: C
noCode: true
hub: true
verified: 2026-10-25
---

## 算法原理

STL 与 pb_ds 子分类收集 C++ 标准库与 GNU 扩展中可以直接调用的容器和位运算工具：

- **STL 容器**：`vector`、`queue`、`stack`、`set/map`、`list` 及常用小技巧。
- **pb_ds**：基于策略的数据结构，如平衡树、优先队列。
- **bitset 优化**：用机器字并行压缩布尔运算。

这些工具的共同点是“用现成实现换开发时间”，但必须清楚它们的复杂度、迭代器失效规则和常数。

## 核心公式 / 状态定义与转移方程

- `vector` 的均摊扩容：容量按倍数增长，单次 `push_back` 均摊 $O(1)$。
- `set/map`：基于红黑树，插入/删除/查找 $O(\log n)$。
- `pb_ds` 平衡树：同样 $O(\log n)$，但支持 `order_of_key` 等排名操作。
- `bitset`：长度为 $n$ 的位运算为 $O(n/64)$，空间为 $O(n/8)$ 字节。

## 逐行代码解析

本篇是子分类总述，不附完整实现。各容器的声明、遍历、删除与 pb_ds/bitset 用法在对应条目中；重点看迭代器失效、`unordered_map` 哈希冲突、`bitset` 长度必须是编译期常量等细节。

## 复杂度分析

- **序列容器**：`vector` 随机访问 $O(1)$，尾部插入均摊 $O(1)$，中间插入 $O(n)$。
- **关联容器**：`set/map` 操作 $O(\log n)$；`unordered_*` 平均 $O(1)$，最坏 $O(n)$。
- **pb_ds**：平衡树操作 $O(\log n)$。
- **bitset**：位运算 $O(n/64)$，空间 $O(n/8)$ 字节。

## 适用场景

- 需要快速实现集合、映射、堆、队列、栈：STL。
- 需要排名、第 k 小、可并堆等 STL 不直接支持的操作：pb_ds。
- 布尔可行性、可达性、集合交并、LCS 等可以位并行的问题：bitset。
- 不适合：对常数极度敏感且 STL 常数过大时，可能需要手写数据结构。

## 常见陷阱与注意事项

- `vector` 扩容导致迭代器/指针失效。
- `set/map` 的 `erase` 在遍历时使用错误迭代器。
- `unordered_map` 被特殊数据卡哈希，最坏退化到 $O(n)$。
- `bitset` 长度必须是编译期常量，不能按运行时 $n$ 动态开。
- `pb_ds` 头文件与命名空间写法因编译器版本而异。
- 忽略 STL 常数，导致渐进复杂度正确但实际超时。

## 对比与扩展

STL 容器是“通用工具箱”，pb_ds 是“补齐 STL 缺失操作的扩展”，bitset 是“用位并行压常数”的优化手段。三者与数据结构大类的关系是：先用 STL/pb_ds 快速实现，再在性能不足时换手写结构或 bitset。
