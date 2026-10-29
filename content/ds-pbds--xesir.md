---
id: ds-pbds
title: 'pb_ds（基于策略的数据结构）'
category: 实用工具
subcategory: STL与pbds
subSubcategory: pb_ds
tags: ["pb_ds", "平衡树", "配对堆", "可并堆", "GCC扩展"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

**pb_ds**，即「基于策略的数据结构」（policy-based data structures），是 GCC 自带的扩展库。它封装了**平衡树、堆、字典树、哈希表**四种数据结构，功能极其强大。~~STL 你不要给我打电话了我怕 pb_ds 误会~~

2021 年 9 月 1 日，根据《关于 NOI 系列活动中编程语言使用限制的补充说明》，允许使用以下划线开头的库函数或宏（但具有明确禁止操作的库函数和宏除外）。这让在 NOI 系列活动中使用 pb_ds 库的合规性有了文件上的依据。所以在 NOI 系列竞赛中**完全允许**使用 pb_ds，可以正常运行，不用担心误入小黑屋。

> 但有一点需要注意：pb_ds 只在使用 libstdc++ 为标准库的编译器下可以使用，在 NOI 系列竞赛中使用的 Dev 等编译器上往往**无法通过本地编译**，这使得用 pb_ds 实现的代码难以在本地调试，使用需慎重。~~当然你要是打网赛用这个那就啥事没有~~

**下面是食用方法。**

## 逐行代码解析

### 配置

pb_ds 库主要包含在这两个头文件中：

```text
ext/pb_ds/assoc_container.hpp
ext/pb_ds/tree_policy.hpp
```

一般情况下我们直接使用 `#include <bits/extc++.h>`，它包含了 `STL` 库、`pb_ds` 库以及 `<bits/stdc++.h>` 里的所有内容，可以直接无脑使用。~~健忘症福音~~

pb_ds 的通用命名空间是 `__gnu_pbds`，所以使用时**可以无脑用下面这个配置：**

```cpp
#include <bits/extc++.h>
using namespace __gnu_pbds;
```

唯一需要注意的是，这个命名空间会与 `std` 里的 `priority_queue` 冲突，所以**不要同时开** `using namespace __gnu_pbds;` 与 `using namespace std;`。

### 配对堆

STL 默认的 `std::priority_queue` 是个「死标准堆」：元素一旦 `push` 进去就再也没法修改，也不能快速删除任意元素，更不能 $O(1)$ 合并两个堆。pb_ds 的 `priority_queue` 直接补上了这几个缺口，功能更丰富，常数还很小。

一般堆的定义语法：

```cpp
__gnu_pbds::priority_queue<T, Compare, Tag, Allocator>
```

- `T`：储存的元素类型（支持自定义）。
- `Compare`：提供严格弱序的比较类型。
- `Tag`：`__gnu_pbds` 提供五种不同的堆，默认是 `pairing_heap_tag`，即**配对堆**。除配对堆外的四种堆要么容易 T 飞、要么是 MLE 狂欢节，所以我们默认 pb_ds 的堆只有配对堆，其他都是滚木。
- `Allocator`：空间配置器，一般用不到。

配对堆的成员函数：

| 名称 | 作用 | 返回类型 / 值 | 复杂度 |
|---|---|---|---|
| `push()` | 向堆中压入一个元素 | 迭代器（该元素位置） | $O(1)$ |
| `pop()` | 弹出堆顶元素 | `void` | 最坏 $O(n)$，均摊 $O(\log n)$ |
| `top()` | 返回堆顶元素 | 堆中元素类型 | $O(1)$ |
| `size()` | 返回元素个数 | `size_type` | $O(1)$ |
| `empty()` | 返回是否为空 | `bool` | $O(1)$ |
| `modify(iterator, key)` | 把迭代器位置的键改为传入的 `key` 并重排 | `void` | 最坏 $O(n)$，均摊 $O(\log n)$ |
| `erase(iterator)` | 删除迭代器位置的键值 | `void` | 最坏 $O(n)$，均摊 $O(\log n)$ |
| `join(other)` | 把 `other` 合并到当前堆并把 `other` 清空 | `void` | $O(1)$ |

~~居然还是可并堆，再也不用手写左偏树了 doge~~

### 平衡树

pb_ds 的 `tree` 是竞赛里性价比最高的「免写平衡树」，代码比手写平衡树少了巨多。

一般平衡树的定义语法：

```cpp
tree<Key, Mapped, Cmp_Fn = std::less<Key>, Tag, Node_Update, Allocator>
```

- `Key`：储存的元素类型（自动去重）。
- `Mapped`：映射值类型，类似 set 填 `null_type`，类似 map 填值类型 `V`。
- `Cmp_Fn`：键的比较函子，定义元素的排序规则，如 `less<Key>` 或 `greater<Key>`。
- `Tag`：底层数据结构实现，即平衡树类型，一般选红黑树 `rb_tree_tag`。
- `Node_Update`：节点更新策略，用 `tree_order_statistics_node_update` 可以启用排名功能，默认不启用。
- `Allocator`：空间配置器，用默认值即可。

最常用的是：

```cpp
tree<PII, null_type, less<PII>, rb_tree_tag, tree_order_statistics_node_update> a;
```

平衡树的成员函数：

| 函数 | 作用 | 返回值 | 时间复杂度 |
|---|---|---|---|
| `size()` | 返回当前树中元素个数 | `size_type` | $O(1)$ |
| `empty()` | 判断树是否为空 | `bool` | $O(1)$ |
| `max_size()` | 返回理论最大容量（极少使用） | `size_type` | $O(1)$ |
| `clear()` | 清空树中所有元素 | `void` | $O(1)$ |
| `insert(value)` | 插入元素（或键值对） | `pair<iterator, bool>` | $O(\log n)$ |
| `insert(first, last)` | 插入迭代器区间内的所有元素 | `void` | $O(\log n)$ |
| `erase(iterator)` | 删除迭代器指向的元素 | `void` | $O(\log n)$ |
| `erase(first, last)` | 删除迭代器区间 $[first, last)$ 内的元素 | `void` | $O(\log n)$ |
| `erase(key)` | 删除所有等于 key 的元素 | `size_type`（删除个数，set 中为 0 或 1） | $O(\log n)$ |
| `find(key)` | 查找键为 key 的元素 | 迭代器（找不到返回 `end()`） | $O(\log n)$ |
| `lower_bound(key)` | 返回第一个 $\ge$ key 的元素的迭代器 | 迭代器 | $O(\log n)$ |
| `upper_bound(key)` | 返回第一个 $>$ key 的元素的迭代器 | 迭代器 | $O(\log n)$ |
| `equal_range(key)` | 返回 `pair<lower_bound(key), upper_bound(key)>` | `pair<iterator, iterator>` | $O(\log n)$ |
| `order_of_key(key)` | 返回树中严格小于 key 的元素个数 | `size_type`（相当于排名减 1） | $O(\log n)$ |
| `find_by_order(index)` | 返回排名为 `index`（从 0 开始）的元素的迭代器 | 迭代器（若 `index` $\ge$ size 返回 `end()`） | $O(\log n)$ |
| `join(other)` | 把 `other` 的所有元素合并到当前树，合并后 `other` 被清空，需保证两棵树值域无交集 | `void` | 理论 $O(\log n)$，实测常数较大 |
| `split(key, other)` | 把当前树中所有 $>$ key 的元素移到 `other`，$\le$ key 的留在当前树，要求 `other` 调用前为空 | `void` | 理论 $O(\log^2 n)$，实测可能退化为 $O(n)$ |

pb_ds 本质是个「竞赛速通外挂」：在绝大多数数据结构题里，能把几十甚至上百行的手写代码直接压到十几行，非常适合 OI 选手掌握。

## 复杂度分析

pb_ds 把复杂度都封装在库里，各操作的具体量级**视所选容器与实现**，要点如下：

- **配对堆**：`push` / `top` / `size` / `empty` / `join` 为 $O(1)$；`pop` / `modify` / `erase` 均摊 $O(\log n)$（单个操作最坏可达 $O(n)$）。
- **平衡树（红黑树）**：绝大多数操作（插入、删除、查找、排名相关）都是 $O(\log n)$；`join` 理论 $O(\log n)$、`split` 理论 $O(\log^2 n)$，但实测常数偏大甚至可能退化。
- **空间复杂度**：与元素个数成正比，$O(n)$。

## 适用场景

- **需要「可并堆」**：多路归并、可合并的优先队列场景，配对堆 $O(1)$ `join` 比手写左偏树省事。
- **需要修改 / 删除堆内元素**：普通 `priority_queue` 做不到，配对堆的 `modify` / `erase` 可以。
- **需要平衡树功能又懒得手写**：需要 `order_of_key`（查排名）、`find_by_order`（按排名取值）时，直接用 pb_ds 的 `tree`。
- **哈希表 / 字典树**：pb_ds 还封装了哈希表（`gp_hash_table`）与字典树，卡 `unordered_map` 被 hack 时可作为替代。

## 常见陷阱与注意事项

1. **命名空间冲突**：`using namespace __gnu_pbds;` 与 `using namespace std;` 同开会让 `priority_queue` 歧义，二选一或显式加前缀。
2. **本地编译不过**：pb_ds 依赖 libstdc++，Dev 等竞赛常用编译器常常无法本地编译，导致难以本地调试，赛前先确认评测机能用。
3. **`join` / `split` 有前提**：`join` 要求两棵树值域无交集，`split` 要求目标树调用前为空，违反前提行为未定义。
4. **迭代器会失效**：`pop` / `erase` 之后，原来指向被删元素的迭代器不能再用。
5. **`modify` 要传对迭代器**：它是按迭代器定位的，找不到正确迭代器就改不了；改完键值后库内部会重排。
6. **平衡树自动去重**：`tree` 的 `Key` 自动去重，类似 set，别指望它能存重复键（要多重集得把键设成 `pair<Key, int>` 之类）。
7. **`insert(first, last)` 的复杂度标注**：文档里常写作 $O(\log n)$，实际按区间长度叠加，理解为「每个元素 $O(\log n)$」更稳。

## 对比与扩展

| 需求 | 手写方案 | STL 方案 | pb_ds 方案 |
|---|---|---|---|
| 可并堆 | 左偏树 / 斜堆 | 无 | `priority_queue`（`pairing_heap_tag`） |
| 改 / 删堆内元素 | 手写堆 | 无（需惰性删除） | `priority_queue::modify` / `erase` |
| 查排名 / 按排名取值 | 手写平衡树 | 无 | `tree` + `tree_order_statistics_node_update` |
| 哈希表 | 手写散列表 | `unordered_map` | `gp_hash_table` |

扩展方向：pb_ds 的 `tree` 配合 `order_of_key` / `find_by_order` 可以轻松实现「动态第 $k$ 小」「区间排名」；`gp_hash_table` 在需要抗 hack 时比 `unordered_map` 更稳。想深入可对照站内的平衡树、堆、哈希表相关知识点。
