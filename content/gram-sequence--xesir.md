---
id: gram-sequence
title: '我的序列我做主：自定义比较规则'
category: 语法技巧
subcategory: 运算符与序列
subSubcategory: ''
tags: ["自定义比较", "排序", "优先队列", "运算符重载", "仿函数", "lower_bound"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

C++ 内置的比较规则很单一：`sort` 默认按 `<` 升序，优先队列默认按 `<` 取最大（大根堆）。可现实是——我想按边权排序、想按距离取最小、想在结构体数组里按某个字段二分……内置规则根本不够用。

于是我们自己给「比较」下定义，让排序、优先队列、二分查找按我们的意愿工作。核心就一条：**告诉算法「谁排在谁前面」**。手段有四种：lambda、仿函数（重载 `operator()`）、普通函数指针，以及给类型重载 `operator<` / `operator>`。

## 逐行代码解析

### sort 的自定义比较

`sort` 接受第三个参数——比较器，返回 `true` 表示第一个参数应排在第二个前面。

- **Lambda 表达式**（最灵活）：

```cpp
vector<Edge> edges;
sort(edges.begin(), edges.end(), [](const Edge &a, const Edge &b) {
    return a.w < b.w;      // 按边权升序
});
```

- **函数对象（重载运算符）**：

```cpp
struct Cmp {
    bool operator()(const Edge &a, const Edge &b) const {
        return a.w < b.w;
    }
};
sort(edges.begin(), edges.end(), Cmp());
```

- **函数指针**（最好写）：

```cpp
bool cmp(const Edge &a, const Edge &b) { return a.w < b.w; }
sort(edges.begin(), edges.end(), cmp);
```

- 三种写法效果等价：lambda 最灵活（可就地捕获），仿函数能带自定义状态，函数指针最朴素。
- 注意比较器要满足**严格弱序**：`cmp(a,b)` 与 `cmp(b,a)` 不能同时为真，相等时都得返回 `false`。

### priority_queue 的自定义比较

- **默认是大根堆**（`less`），即 `priority_queue<T>` 等价于 `priority_queue<T, vector<T>, less<T>>`。
- **小根堆**：用 `greater<T>`，要求 `T` 可比较（有 `operator>`）：

```cpp
priority_queue<int, vector<int>, greater<int>> pq;   // 小根堆
```

- **自定义比较类**（和 `sort` 的仿函数类似，但语义相反）：

```cpp
struct Cmp {
    bool operator()(const Node &a, const Node &b) const {
        return a.dist > b.dist;   // 注意：这里 > 表示优先级小（小根堆）！
    }
};
priority_queue<Node, vector<Node>, Cmp> pq;  // 小根堆，按 dist 升序
```

- 这是最反直觉的一处：优先队列比较器的 `operator()` 返回 `true` 表示 `a` 的优先级**低于** `b`（`a` 沉到堆底），所以写 `>` 反而得到小根堆。

### 重载 operator< 用于 sort 和 set/map

```cpp
struct Edge {
    int u, v, w;
    bool operator<(const Edge &other) const {
        if (w != other.w) return w < other.w;
        if (u != other.u) return u < other.u;
        return v < other.v;
    }
};
set<Edge> st;                 // 自动按 operator< 排序
map<Edge, int> mp;            // 同理
```

- 把 `operator<` 写进结构体，`sort`、`set`、`map` 全都自动认识它，一举多得。
- 多关键字比较时按优先级依次比，最后一步保证「相等也不返回 true」，才符合严格弱序。
- 注意重载的是 `operator<`：`set` / `map` 只认 `<`，不认 `>`。

### lower_bound / upper_bound 自定义比较

适用于自定义结构体的数组，按某个字段查找，$O(\log n)$。

```cpp
vector<Edge> edges = ...;  // 假设已按 w 升序排序
Edge target; target.w = 5;
auto it = lower_bound(edges.begin(), edges.end(), target,
                       [](const Edge &a, const Edge &b) { return a.w < b.w; });
// 返回第一个 w >= target.w 的元素
```

- 前提是数组**已按同一规则排好序**，否则二分结果无意义。
- `lower_bound(begin, end, value, cmp)` 的 `cmp` 接受 `(element, value)` 或 `(value, element)`，顺序写反会得到相反结果。

### find

$O(n)$

```cpp
auto it = find(vec.begin(), vec.end(), v);
if (it != vec.end()) cout << *it;
```

- 线性查找，别在大数组里反复用；有序时优先二分。

### 常用函数对象（functional 头文件）

| 函数对象 | 作用 | 示例 |
|---------|------|------|
| `less<T>` | 小于比较（默认升序） | `sort(v.begin(), v.end(), less<int>())` |
| `greater<T>` | 大于比较（降序） | `sort(v.begin(), v.end(), greater<int>())` |
| `equal_to<T>` | 等于 | 用于 `find` 等 |
| `not_equal_to<T>` | 不等于 | 少见 |

- `less` / `greater` 就是标准库写好的仿函数，省得自己动手。

## 复杂度分析

- 比较器本身只决定「怎么比」，不改变算法的复杂度：`sort` 仍是 $O(n\log n)$（$n$ 次比较，每次比较器内部是 $O(1)$），一次 `push` / `pop` 的比较次数仍是 $O(1)$。
- 代价在于**比较函数写得好不好**：比较器里别做重活（别排序、别拷贝大对象），否则常数会爆炸。
- `find` 是 $O(n)$，`lower_bound` 是 $O(\log n)$，这个差距才是选它们时要看的。

## 适用场景

- `sort` 多关键字排序、按自定义字段排。
- `priority_queue` 需要小根堆，或按多个字段动态取最值（如 Dijkstra 按距离）。
- `set` / `map` 装自定义类型：必须提供 `operator<`。
- 结构体数组上按字段二分：`lower_bound` + 自定义比较器。

## 常见陷阱与注意事项

1. **优先队列的比较语义是反的**：`operator()` 返回 `true` 表示「优先级更低」，所以小根堆要写 `>`。这一条是历年血泪重灾区。
2. **比较器必须是严格弱序**：`cmp(a,b)` 和 `cmp(b,a)` 不能同时为真；相等情况要返回 `false`，否则 `sort` 可能越界崩溃。
3. **漏写 `const`**：仿函数的 `operator()` 和成员比较函数都建议加 `const`，否则在某些容器里编译不过。
4. **二分前必须先排序**，且排序规则要与二分比较规则一致，不然结果随机。
5. **`lower_bound` / `upper_bound` 的区别**：`lower_bound` 找第一个 `>=`，`upper_bound` 找第一个 `>`，两者配合能数出等于 `value` 的个数。
6. **`less` / `greater` 要带模板参数**：写成 `greater<int>()`，忘了 `<int>` 编译不过。

## 对比与扩展

| 场景 | 写法 | 认哪个运算符 |
|---|---|---|
| `sort` | 比较器 / `operator<` | `<` |
| `priority_queue` 大根堆 | 默认 `less` | `<` |
| `priority_queue` 小根堆 | `greater` / 自定义仿函数 | `>` |
| `set` / `map` | `operator<` | `<` |
| `lower_bound` | 比较器 | `<` |

扩展：

- `std::bind` 能绑定参数生成函数对象，但 lambda 更直观，OI 里很少用。
- `std::function` 是类型擦除的可调用对象包装，能存 lambda / 函数指针，但有额外开销，别在热路径频繁用。
- 三路比较（C++20）的 `<=>` 能自动生成全部比较运算符，但多数 OJ 还不支持 C++20，暂不引入。
