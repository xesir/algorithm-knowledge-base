---
id: ds-stl-queue
title: '队列（queue）'
category: 数据结构
subcategory: STL容器
subSubcategory: ''
tags: ["数据结构", "STL", "队列", "双端队列", "优先队列"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

队列，顾名思义，就是排队打饭的那条队——先到的先打饭，后来的老老实实排后面。这就是它的性质：**先进先出**（FIFO，first in first out）。元素只能从**队尾**进、从**队首**出，中间插队？想都别想。

STL 里跟「队」沾边的有三个容器，都写在 `#include<queue>` 里（用了万能头 `bits/stdc++.h` 就可以省略，下文同）：

- `queue<type>`：普通队列，只能队尾进、队首出，底层默认是 `deque`。
- `priority_queue<type>`：优先队列，跟堆差不多，每次拿出来的是当前最值。
- `deque<type>`：双端队列（double-ended queue），两头都能进出，得包含 `#include<deque>`。

它只关心你**什么时候来**，不关心你**是谁**，所以出队顺序和入队顺序一模一样。

## 核心公式 / 状态定义与转移方程

队列的核心约束就是「先入先出」。设元素依次按 $a_1, a_2, \dots, a_n$ 入队，那出队顺序也恒为 $a_1, a_2, \dots, a_n$，第 $i$ 个出队的永远是 $a_i$。把队首记在左、队尾记在右，队列写作 $[a_1, a_2, \dots, a_n]$，一次出队就是：

$$
\text{pop}\big([a_1, a_2, \dots, a_n]\big) = (a_1,\ [a_2, a_3, \dots, a_n])
$$

即弹出队首 $a_1$，剩下的接上。

如果是手写循环队列（用数组 + 取模指针，避免动态扩容），设容量为 $N$、队首下标 $head$、队尾下标 $tail$（$tail$ 指向队尾元素的下一个空位），那么入队出队只挪指针、不搬元素：

$$
head = (head + 1) \bmod N, \qquad tail = (tail + 1) \bmod N
$$

此时队列里的元素个数是 $(tail - head + N) \bmod N$。

## 逐行代码解析

下面按「食用方法」分三块，都是关键片段，不要求拼成一个能 AC 的完整程序。

### 普通队列

```cpp
queue<int> q;

// 元素访问
q.front();  // 返回队首元素（不删除）
q.back();   // 返回队尾元素（不删除）
// 修改
q.push(x);  // 在队尾插入元素 x
q.pop();    // 弹出队首元素（无返回值）
// 容量
q.empty();  // 队列是否为空
q.size();   // 返回队列中元素的数量

queue<int> q1, q2;
q1 = q2;    // 把 q2 的内容赋值给 q1
```

- `front()` / `back()` 只看不删；`pop()` 只删不返回，想取值得先 `front()`。
- `queue` 没有迭代器，别想着 `for` 一遍。

### 双端队列

```cpp
deque<int> q;

// 元素访问
q.front();      // 返回队首元素
q.back();       // 返回队尾元素
// 修改
q.push_back(x); // 在队尾插入元素
q.pop_back();   // 弹出队尾元素
q.push_front(x);// 在队首插入元素
q.pop_front();  // 弹出队首元素
q.insert(it, x);// 在迭代器 it 指向位置前插入 x
q.erase(it);    // 删除迭代器 it 指向的元素
// 容量
q.empty();      // 队列是否为空
q.size();       // 返回队列中元素的数量
```

- 两头进出都是 $O(1)$，还支持 `q[i]` 随机访问，这就是它比 `queue` 强的地方。

### 优先队列

```cpp
priority_queue<int, vector<int>, greater<int> > q;  // 小根堆
q.top();    // 返回堆顶（最小值）
q.pop();    // 弹出堆顶
q.push(x);  // 插入元素 x
q.empty();  // 是否为空

priority_queue<int> Q;  // 大根堆（默认）
Q.top();    // 返回堆顶（最大值）
Q.pop();
Q.push(x);
Q.empty();
```

- 优先队列**只有 `top()`，没有 `front()`**。原主页里大根堆那块写的是 `q.front()`，那是个手滑，编译直接报错，记得改成 `top()`。
- 默认是大根堆，第三个模板参数塞 `greater<int>` 就变（小根堆）。

## 复杂度分析

| 容器 | 访问 | 插入 / 删除 | 说明 |
|---|---|---|---|
| `queue` | `front` / `back` $O(1)$ | `push` / `pop` $O(1)$ | 底层 `deque` |
| `deque` | 两端 $O(1)$，随机访问 $O(1)$ | 两端 $O(1)$，中间 `insert` / `erase` $O(n)$ | 双端进出 |
| `priority_queue` | `top` $O(1)$ | `push` / `pop` $O(\log n)$ | 底层是堆 |

空间都是 $O(n)$，$n$ 是容器里元素个数。一句话：普通队列和双端队列随便用，优先队列每次操作带个 $\log$。

## 适用场景

- **按到达顺序处理**：BFS 的扩展队列、树的层序遍历。
- **两端插入删除**：单调队列（滑动窗口最值）、01BFS（用 `deque`）。
- **动态维护最值**：优先队列上 Dijkstra、Prim、哈夫曼、求第 $k$ 大。
- 排队、缓冲这种「先来先服务」的语义，用 `queue` 最贴切。

## 常见陷阱与注意事项

1. `pop()` 没有返回值：先 `front()` 取值再 `pop()`，否则队首元素直接丢。
2. 取元素前先 `empty()` 判空，对空队列 `front()` / `pop()` 是未定义行为。
3. `queue` 不能遍历、不能随机访问，要遍历请换 `deque` 或手写数组队列。
4. `priority_queue` 只有 `top()`，误写 `front()` 会编译报错（原主页就有这个坑）。
5. 小根堆写法 `priority_queue<int, vector<int>, greater<int> >`：C++11 之前两个 `>` 之间必须留空格写 `> >`，C++11 起可以省略。
6. `queue` 没有 `clear()`，清空得写 `q = queue<int>();` 或循环 `pop()`。

## 对比与扩展

| 容器 | 头文件 | 底层 | 访问方式 | 特点 | 典型应用 |
|---|---|---|---|---|---|
| `queue` | `<queue>` | `deque` | `front` / `back` | 队尾进队首出（FIFO） | BFS、层序遍历 |
| `deque` | `<deque>` | 分块双端数组 | 两端 + 随机访问 | 两端都能进出 | 单调队列、01BFS |
| `priority_queue` | `<queue>` | 二叉堆 | `top` | 每次拿最值 | Dijkstra、top-k |
| `stack` | `<stack>` | `deque` | `top` | 后进先出（LIFO） | DFS、括号匹配 |

扩展方向：单调队列（`ds-monoqueue-1d`）、01BFS、循环队列，还有和堆的对照——优先队列就是二叉堆的封装，想随机删除 / 改元素就得手写堆或上平衡树。
