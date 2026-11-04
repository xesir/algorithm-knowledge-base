---
id: ds-stl-associative
title: '关联式容器（set / map / multiset）'
category: 实用工具
subcategory: STL与pbds
tags: ["STL", "map", "set", "multiset", "关联式容器"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

给定若干个数，如何判断某个数有没有出现过、出现了多少次？最直接的做法是开桶数组 `book[x]`，但数值很大、出现负数、元素不是整数时，桶数组就不好用。

**关联式容器**用“键”来组织数据，内部通常是平衡二叉搜索树（红黑树），因此元素自动有序，查找、插入、删除都是 $O(\log n)$。最常用的三个是：

- `std::map`：键值映射，键有序；
- `std::set`：集合，元素有序且去重；
- `std::multiset`：多重集合，元素有序但不去重。

### std::map

- 定义：`map<int, int> M;`，使用上类似数组。
- `M.count(x)`：判断是否存在键 $x$，返回 $0$ 或 $1$。
- `M[x]`：访问键 $x$ 对应的值；如果不存在会自动插入 `{x, 0}`。
- `M[x]++`、`M.count(x)` 的时间复杂度都是 $O(\log n)$，$n$ 是当前元素个数。
- C++11 起可以范围遍历：

```cpp
for (auto i : M) {
    cout << i.first << ' ' << i.second << '\n';
}
```

### std::set

- 定义：`set<int> S;`
- 元素有序且去重。
- `S.count(x)`：判断是否存在；`S.insert(x)`：插入；`S.erase(x)`：删除。
- 上述操作平均 $O(\log n)$。
- 范围遍历：

```cpp
for (auto i : S) {
    cout << i << '\n';
}
```

### std::multiset

- 定义：`multiset<int> S;`
- 与 `set` 的区别是不去重。
- `S.count(x)` 返回 $x$ 的个数；最坏情况下 `count` 会退化到 $O(n)$。
- `S.erase(x)`：
  - 若 $x$ 是**迭代器**，只删除该迭代器指向的一个元素；
  - 若 $x$ 是**元素值**，删除所有等于 $x$ 的元素。
- 其它用法与 `set` 相同。

### 容器内的二分

`set` / `multiset` 支持 `S.lower_bound(x)` 和 `S.upper_bound(x)`，时间复杂度 $O(\log n)$，语义与 STL 的 `lower_bound` / `upper_bound` 一致。

### 容器嵌套

关联式容器可以嵌套，例如 `map<int, set<int>>`、`map<string, vector<int>>`。嵌套时要注意外层键的有序性和内层容器的操作复杂度。

## 核心公式 / 状态定义与转移方程

- `map<Key, Value>`：键值映射，键唯一、有序；`M[key]` 不存在时会插入默认值。
- `set<Key>`：集合，元素唯一、有序；`insert` / `erase` / `count` 都是 $O(\log n)$。
- `multiset<Key>`：多重集合，元素可重复；`erase(value)` 删除全部等于该值的元素，`erase(iterator)` 只删一个。
- `lower_bound(x)`：第一个 $\ge x$ 的位置；`upper_bound(x)`：第一个 $>x$ 的位置。
- 遍历顺序：`map` / `set` / `multiset` 都按键/元素升序；需要自定义顺序时传比较器。

## 逐行代码解析

### map 计数

```cpp
map<int, int> M;
for (int i = 1; i <= n; i++) {
    int x;
    cin >> x;
    M[x]++;
}
cout << M.count(3) << ' ' << M[3] << '\n';
```

- `M[x]++` 会在键不存在时插入 `{x, 0}` 再加一，所以可以直接计数。
- `M.count(3)` 只判断是否存在，不插入；`M[3]` 若不存在会插入，查询时要注意这个副作用。

### set 去重与查找

```cpp
set<int> S;
S.insert(3);
S.insert(3);
S.insert(5);
cout << S.size() << '\n';      // 2
cout << S.count(3) << '\n';    // 1
S.erase(3);
cout << S.count(3) << '\n';    // 0
```

- `set` 自动去重，重复 `insert` 不会增加元素。
- `S.count(x)` 返回 $0/1$；`S.erase(x)` 删除值为 $x$ 的元素。

### multiset 删除一个与删除全部

```cpp
multiset<int> S;
S.insert(2); S.insert(2); S.insert(3);

S.erase(S.find(2));   // 只删一个 2
cout << S.count(2) << '\n';  // 1

S.erase(2);           // 删除所有 2
cout << S.count(2) << '\n';  // 0
```

- `S.find(2)` 返回第一个等于 $2$ 的迭代器；`erase(iterator)` 只删这一个。
- `erase(2)` 传的是值，会删除所有等于 $2$ 的元素。

## 复杂度分析

- `map` / `set` / `multiset` 的插入、删除、查找平均 $O(\log n)$，最坏 $O(\log n)$（红黑树平衡）。
- 范围遍历 $O(n)$。
- `multiset::count(x)` 最坏 $O(n)$，因为要数完所有等于 $x$ 的元素；如果只需要判断存在性，用 `find(x)`。
- 空间 $O(n)$。

## 适用场景

- 需要按值快速查找、插入、删除，且元素有序。
- 需要维护“某个值出现了几次”的映射（`map`）。
- 需要去重并保持有序（`set`）。
- 需要允许重复且保持有序（`multiset`）。
- 需要前驱/后继、区间内第一个大于等于某值的元素（`lower_bound` / `upper_bound`）。
- 预处理可能出现的结果、为特定条件计数、判断条件是否出现过。

## 常见陷阱与注意事项

1. **`M[x]` 会插入**：查询 `map` 时若只想判断存在，用 `M.count(x)` 或 `M.find(x)`，不要用 `M[x]`，否则会悄悄插入 `{x, 0}`。
2. **`multiset.erase(value)` 删除全部**：只想删一个时用 `erase(find(value))`。
3. **`multiset.count` 可能很慢**：最坏 $O(n)$，只判断存在用 `find`。
4. **迭代器失效**：删除元素后，指向被删元素的迭代器失效；遍历中删除要先用 `it = S.erase(it)` 的写法。
5. **自定义比较器**：`set` / `map` 的键必须满足严格弱序；比较器写错会导致元素丢失或行为未定义。
6. **`unordered_map` 不是有序容器**：需要有序/前驱后继时不能用 `unordered_map`；它平均 $O(1)$，但可能被卡哈希。
7. **键的类型**：`map` 的键要可比较；结构体作键需要自定义比较器。
8. **范围遍历时修改容器**：遍历中插入/删除可能使迭代器失效，先收集操作或使用迭代器返回值。

## 对比与扩展

- **`map` vs `unordered_map`**：前者有序、$O(\log n)$、支持前驱后继；后者平均 $O(1)$、无序、可能被哈希冲突卡。
- **`set` vs `multiset`**：前者去重，后者允许重复；需要计数时 `multiset` 更方便，但 `count` 可能慢。
- **`set` vs 排序数组**：静态数据用排序数组 + `lower_bound` 更省空间；需要动态插入删除时用 `set`。
- **容器嵌套**：`map<int, set<int>>` 适合“一个键对应多个有序值”；注意外层键的 `[]` 会插入空容器。
- **讲义练习**：A4096、A4094、A4097、A4093、A4100、G1177、ABC344C、ABC170C、A4095、ABC278C、G1044、CF1426D、ABC233D。题号以原讲义为准，部分为训练平台题号。
