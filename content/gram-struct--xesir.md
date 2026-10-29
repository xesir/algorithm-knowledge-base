---
id: gram-struct
title: '神秘结构体'
category: 实用工具
subcategory: 语法技巧
subSubcategory: 结构体
tags: ["结构体", "struct", "class", "运算符重载", "构造函数", "位域"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

先破一个迷思：C++ 里 `struct` 和 `class` 都是**类**，区别**仅仅**在于成员的默认访问权限——`struct` 默认 `public`，`class` 默认 `private`。别的特性一个不少：成员变量、成员函数、构造函数、析构函数、继承、多态、访问控制，两边都能用。

那 OI 里为什么几乎清一色用 `struct`？因为它默认 `public`，省去满篇写 `public:` 的麻烦。它的核心用途就一个：把**一堆相关的数据打包成一个整体**——一条边、一个点、一个状态，顺手再给它配几个成员函数（尤其是比较运算），让 `sort` 和优先队列直接认识它。

## 逐行代码解析

### 共同点与区别

`struct` 和 `class` 可用的特性完全一样：

- **成员变量**：存储数据。
- **成员函数**：操作数据的函数。
- **构造函数**：初始化对象（可重载）。
- **析构函数**：清理资源（OI 中很少用到）。
- **继承与多态**：支持继承，但 OI 中极少使用。
- **访问控制**：`public`、`protected`、`private` 都支持。

| | `struct` | `class` |
|---|---|---|
| 默认访问权限 | `public` | `private` |
| 默认继承权限 | `public` | `private` |
| 用途习惯 | 纯数据聚合（边、点、状态） | 封装复杂的抽象数据类型 |

- OI 里几乎只用 `struct`，因为聚合数据时默认 `public` 更省事。

### 存边 / 存点（最常用）

```cpp
struct Edge { int to, w, next; };
struct Node { int x, y, dist; };
```

- 最常见的用途：把一条边的三个字段打包，边数组就是 `Edge e[N]`。
- 结构体数组可以像普通数组一样用，也能花括号初始化。

### 构造函数快速初始化

```cpp
struct Point {
    int x, y;
    Point() : x(0), y(0) {}                     // 默认构造函数
    Point(int a, int b) : x(a), y(b) {}         // 带参构造
};
// 使用：
Point p1;          // (0,0)
Point p2(3, 4);    // (3,4)
vector<Point> pts;
pts.push_back({1, 2});        // 直接花括号（聚合初始化）
```

- 冒号后面的 `x(0), y(0)` 是成员初始化列表，比在函数体里赋值更直接。
- `Point()` 带默认值让 `Point p1;` 就能得到 `(0,0)`。

### 成员函数（常用于自定义比较）

```cpp
struct Node {
    int val, id;
    bool is_ok() const { return val > 0; }      // 成员函数
};
```

- 成员函数可以直接访问自己的成员，末尾的 `const` 表示不改动成员，比较函数一般都要加。

### 运算符重载（核心）

```cpp
struct Edge {
    int u, v, w;
    bool operator<(const Edge &other) const {   // 用于 sort 默认升序
        return w < other.w;                     // 按边权排序
    }
};
// 用于优先队列的小根堆（注意重载 > 或者自定义 Compare）
struct Node {
    int dist, id;
    bool operator>(const Node &other) const {   // 用于 priority_queue 小根堆
        return dist > other.dist;
    }
};
priority_queue<Node, vector<Node>, greater<Node>> pq;  // 需要 operator>
```

- `sort` 默认按 `operator<` 升序，所以重载 `<` 就能让 `sort(edges.begin(), edges.end())` 直接生效。
- 优先队列的 `greater<Node>` 调用的是 `operator>`，这才是上面第二个例子里要重载 `>` 的原因。

### 友元函数

```cpp
struct Point {
    int x, y;
    friend bool operator==(const Point &a, const Point &b) { return a.x == b.x && a.y == b.y; }
};
```

- 友元函数能访问结构体的私有成员，重载运算符时用得上；OI 里很少遇到访问控制，所以不常用。

## 复杂度分析

结构体本身不引入算法复杂度，它的开销体现在**内存布局**和**拷贝**上：

- 成员按声明顺序排列，可能因**内存对齐**在成员之间插入填充字节，结构体的实际大小往往大于各成员之和；对大结构体用 `sizeof` 看一眼心里有数。
- 按值传参、按值遍历都会整份拷贝，大结构体要用 `const T&`。
- 运算符重载是普通函数，没有额外运行期代价，`sort` 的复杂度仍由排序算法决定，即 $O(n\log n)$。

## 适用场景

- 打包边、点、状态：图论邻接表、堆里的节点、DP 状态。
- 让自定义类型支持 `sort` / `set` / `map` / 优先队列：重载 `<` 或 `>`、写仿函数。
- 多字段返回（虽然 `pair` / `tuple` 也行，字段多了结构体更清晰）。
- 位域节省内存：状态压缩、二进制序列化。

## 常见陷阱与注意事项

1. **比较函数记得加 `const`**：写 `bool operator<(const Edge&) const`，漏了末尾的 `const` 在 `set` / `map` 里可能编译不过。
2. **运算符重载的语义**：`sort` 认 `<`，优先队列的 `greater` 认 `>`，两者别搞混（详见「我的序列我做主」）。
3. **内存对齐**：结构体大小不等于成员大小之和，敏感场景（`memcpy`、位域混合）要按 `sizeof` 计算。
4. **聚合初始化有前提**：`{}` 直接初始化要求是聚合类型，一旦自己写了构造函数，就不再是聚合，`pts.push_back({1, 2})` 会失效（除非补上对应构造函数）。
5. **结构体数组的初值**：全局/静态数组会自动清零，函数内的局部数组是随机的，别忘记初始化。
6. **位域不能取地址**：位域成员没法用 `&` 取地址，也不能直接读入输出。

## 对比与扩展

| 维度 | `struct` | `class` |
|---|---|---|
| 默认访问权限 | `public` | `private` |
| 默认继承 | `public` | `private` |
| OI 使用频率 | 高 | 低 |

扩展：

- **聚合初始化与 pair**：简单二元组用 `pair`、需要运算符重载的用 `struct`，殊途同归。
- **位域**：`struct Flags { unsigned int a : 1, b : 2, c : 3; };` 各占 1、2、3 位，用于省内存的位打包。
- **POD 类型**（Plain Old Data）：与 C 兼容、可直接 `memcpy` 的结构体，做二进制序列化时有用。
