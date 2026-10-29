---
id: ds-stl-associative
title: '关联式容器（set / map）'
category: 实用工具
subcategory: STL与pbds
subSubcategory: STL容器
tags: ["数据结构", "STL", "关联式容器", "集合", "映射"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

前面那些「序列式容器」只关心你排队排第几，而**关联式容器**关心的是「你叫什么」——它按**键**来存东西，内部通常用**红黑树**（一种自平衡二叉搜索树）实现，所以元素会**自动排好序**，查找、插入、删除都是 $O(\log n)$。

按「是否需要排序」还分两个阵营：

- **关联式容器**：底层红黑树，元素有序，`set` / `map` / `multiset` / `multimap` 都是这一挂。
- **无序关联式容器**（如 `unordered_set` / `unordered_map`）：底层是**哈希（hash）**，元素不以任何特定顺序排列，平均更快但退化时可能变差。

这里讲最常用的两个：`set`（集合）和 `map`（映射）。

## 核心公式 / 状态定义与转移方程

关联式容器不是动态规划结构，没有转移方程；它的复杂度来自红黑树的高度。含 $n$ 个结点的红黑树高度满足

$$
h = O(\log n)
$$

而查找 / 插入 / 删除都只沿着「根到叶子」的一条链走，代价正比于树高，所以三者都是 $O(\log n)$。至于无序关联式容器，键先经哈希函数映射到桶，理想情况下均摊 $O(1)$，但冲突多了会退化。

## 逐行代码解析

原笔记的「食用方法」照搬如下，分 `set` 和 `map` 两块，再补一条关于 `insert` 返回值的冷知识。都是关键片段，不要求拼成一个能 AC 的完整程序。

### 集合（set）

性质：内部通常通过红黑树实现；元素不重复（想要能重复的就上 **multiset**）；会自动排序插入的数字（不想排序就用**无序关联式容器 unordered_set**）；因为是红黑树，插入查询复杂度都是 $O(\log n)$。

声明、包含 `#include<set>`：`set<type> s;` / `multiset<type> s;` / `unordered_set<type> s;`。

```cpp
set<int> s;//multiset同，unordered_set无二分查询
//插入与删除操作
s.insert(x);		//当容器中没有等价元素的时候，将元素 x 插入到 set 中
s.erase(x);		//删除值为 x 的 所有 元素，返回删除元素的个数
s.erase(pos);		//删除迭代器为 pos 的元素，要求迭代器必须合法
s.erase(first,last);	//删除迭代器在[first,last)范围内的所有元素
s.clear() 		//清空 set
//迭代器 不想写了自己看oi.wiki去罢（
//查找操作
s.count(x);		//返回 set 内键为 x 的元素数量。
s.find(x);		//在 set 内存在键为 x 的元素时会返回该元素的迭代器，否则返回 s.end()
s.lower_bound(x);	//二分搜索，返回指向首个不小于给定键的元素的迭代器。如果不存在这样的元素，返回 s.end()
s.upper_bound(x);	//二分搜索，返回指向首个大于给定键的元素的迭代器。如果不存在这样的元素，返回 s.end()
//容量
s.empty();		//返回容器是否为空。
s.size();		//返回容器内元素个数。
```

- `insert` 若容器里已有等价元素则不插（set 去重的来源）；`erase(x)` 一次删掉**所有**值等于 $x$ 的元素（set 里最多一个）。
- `lower_bound` / `upper_bound` 是二分，能直接在容器上做，`unordered_set` 没有这俩。

### 关于 insert 的返回值（冷知识）

> insert 函数其实是==有返回值==的。返回值类型为 `pair<iterator, bool>`：`iterator` 指向所插入的元素（或者是指向等于所插入值、原本就在容器里的那个元素），`bool` 表示是否插入成功。由于 set 元素唯一，若容器已有等值元素则插入失败返回 false，否则成功返回 true；**map 的 insert 也是同理**。

### 映射（map）

性质：内部通常通过红黑树实现；是键值对容器，键是**唯一**的（`multimap` 允许一个键对应多个元素）；查找插入 $O(\log n)$。

声明、包含 `#include<map>`：`map<key,type>` / `multimap<key,type>` / `unordered_map<key,type>`。

```cpp
//插入与删除操作
//可以直接通过下标访问来进行查询或插入操作。例如 mp["Alan"]=100;
//通过向 map 中插入一个类型为 pair<Key, T> 的值可以达到插入元素的目的，例如 mp.insert(pair<string,int>("Alan",100));
erase(key)		//函数会删除键为 key 的 所有 元素。返回值为删除元素的数量
erase(pos)		//删除迭代器为 pos 的元素，要求迭代器必须合法
erase(first,last)	//删除迭代器在[first,last)范围内的所有元素
clear()			//函数会清空整个容器。

//查询操作
count(x)		//返回容器内键为 x 的元素数量。复杂度为O(log(size)+ans)（关于容器大小对数复杂度，加上匹配个数）。
find(x)			//若容器内存在键为 x 的元素，会返回该元素的迭代器；否则返回 end()。
lower_bound(x)		//返回指向首个不小于给定键的元素的迭代器。
upper_bound(x)		//返回指向首个大于给定键的元素的迭代器。若容器内所有元素均小于或等于给定键，返回 end()。
empty()			//返回容器是否为空。
size()			//返回容器内元素个数。
```

- `mp[key]` 既能查也能插：键不存在时会**默认构造**一个值并插进去，所以别拿 `[]` 随便探一个不存在的键。
- `mp.insert(pair<Key,T>(k, v))` 是显式插入，键已存在则不插（配合上一条冷知识，可用返回值判断是否插成功）。

## 复杂度分析

| 容器 | 查找 / 插入 / 删除 | 底层 | 是否有序 | 元素是否可重复 |
|---|---|---|---|---|
| `set` / `map` | $O(\log n)$ | 红黑树 | 有序 | 键唯一 |
| `multiset` / `multimap` | $O(\log n)$ | 红黑树 | 有序 | 键可重复 |
| `unordered_set` / `unordered_map` | 均摊 $O(1)$，最坏 $O(n)$ | 哈希表 | 无序 | 键唯一 |

空间复杂度为 $O(n)$。`map::count` 因为要数个数，复杂度是 $O(\log n + \text{ans})$（对数查找再加上匹配个数）。

## 适用场景

- **去重 + 有序**：`set` 收集后自动去重并排好序；`multiset` 允许重复。
- **动态维护有序序列**：要频繁插入 / 删除还要能二分查前驱后继，红黑树容器很趁手。
- **建映射 / 计数**：`map<string,int>` 做名字到编号的映射、`unordered_map` 做哈希计数。
- **不想自己写平衡树**时：需要 `lower_bound` / `upper_bound` / 前驱后继，又懒得手写 Treap / Splay，`set` 是现成答案。

## 常见陷阱与注意事项

1. `set` 里不能直接改元素（元素是键，改动会破坏有序性），要改就先 `erase` 再 `insert`。
2. `erase(x)` 删的是**所有**等值元素，删单个要传迭代器 `erase(s.find(x))`，且得先确认迭代器合法。
3. `unordered_set` / `unordered_map` **没有** `lower_bound` / `upper_bound`（无序，二分无意义）。
4. `map` 用 `mp[key]` 查不存在的键会默默插入一个默认值，容易让 `size()` 虚增；只想查就用 `find` / `count`。
5. `set` / `map` 的迭代器遍历天然有序（从小到大），要倒序可用 `rbegin` / `rend`。
6. `insert` 有返回值 `pair<iterator, bool>`，能靠 `bool` 判断是否插入成功（见上文冷知识）。

## 对比与扩展

| 容器 | 头文件 | 底层 | 排序 | 键重复 |
|---|---|---|---|---|
| `set` | `<set>` | 红黑树 | 自动升序 | 否 |
| `multiset` | `<set>` | 红黑树 | 自动升序 | 是 |
| `map` | `<map>` | 红黑树 | 按键升序 | 否 |
| `multimap` | `<map>` | 红黑树 | 按键升序 | 是 |
| `unordered_*` | `<unordered_set>` / `<unordered_map>` | 哈希表 | 无序 | 视具体而定 |

扩展方向：哈希实现的无序关联式容器（更快但无序、可能被卡）、自己手写平衡树以获得「第 $k$ 大 / 排名」等红黑树封装不了的操作，以及 `map` 的 `[]` 与 `insert` 在「查 / 插」语义上的区别。
