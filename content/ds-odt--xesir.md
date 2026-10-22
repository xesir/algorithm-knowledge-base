---
id: ds-odt
title: '珂朵莉树（ODT）'
category: 数据结构
subcategory: 其他数据结构
subSubcategory: ''
tags: ["数据结构", "珂朵莉树", "ODT", "区间推平", "随机数据", "暴力"]
timeComplexity: '随机数据下每次期望 O(log n)，最坏 O(n)'
spaceComplexity: 'O(n)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

珂朵莉树起源于 Codeforces 896C，因题面背景中的人物珂朵莉而得名。~~名称诡异程度堪比主席树~~

在 OI 圈中，它常被称为「**骗分神器**」。它是基于一些关联式容器（如 `set`）的**暴力区间维护结构**，本质非常质朴，即**将值相同的一整段连续下标合并为一个三元组 $[l,r,v]$**，统一放进 `set` 中维护。

它的关键前提是：**题目中包含「区间赋值 / 区间推平」（assign）操作，且数据具有一定随机性**。

- **为什么快**：每次区间赋值都会把大量零碎的区间删掉，合并为一个大区间，从而使得 `set` 中的区间段数急剧减少。可以证明，在操作随机分布的前提下，`set` 内的平均区间数量仅为 $O(\log n)$ 级别。
- **通用性极强**：由于每个节点是一个具象的区间 $[l,r,v]$，面对求区间第 $k$ 小、区间 $x$ 次方和等线段树极难维护的「诡异操作」，珂朵莉树只需要暴力遍历对应区间段，写起来几乎零思考成本。
- **缺点与不适用性**：如果出题人构造特殊数据（例如完全没有推平操作，或者反复在单点位置交替修改使区间碎裂），区间的数量将退化至 $O(n)$，单次操作退化为 $O(n)$，整体复杂度变为 $O(n^2)$。因此对于没有随机保证或无区间推平的正赛题，直接使用有被卡常或 TLE 的风险。所以一般不要考虑将珂朵莉树作为唯一正解。

## 逐行代码解析

### 模块一：节点定义与初始化

每个节点记录区间的左端点 $l$、右端点 $r$ 以及区间内的公共权值 $v$。为了能在 `set` 中快速按区间左端点查找，重载小于号按 $l$ 排序。

```cpp
struct Node {
    int l, r;
    mutable long long v;

    bool operator<(const Node &other) const {
        return l < other.l;
    }
};

set<Node> odt;
```

权值成员变量通常需要加上 `mutable` 关键字，这样在遍历 `set` 的迭代器为只读（`const`）时，依然可以直接修改节点的值而无需先删除再插入。

初始时，可以把每个元素都单独作为一个区间插入：

```cpp
// 最简单的单点装入初始化
for (int i = 1; i <= n; ++i) {
    odt.insert({i, i, a[i]});
}
```

### 模块二：`split`（区间分裂）

`split(pos)` 的含义是：找到包含位置 $pos$ 的那个区间 $[l,r,v]$，将其切分为两个独立的子区间：

$$
[l,\ pos-1,\ v]\quad\text{与}\quad[pos,\ r,\ v]
$$

并返回以 $pos$ 为左端点的那个区间的迭代器。这是后续一切区间操作的基石。

```cpp
auto split(int pos) {
    if (pos > n) return odt.end();

    // 找到第一个左端点 >= pos 的区间
    auto it = odt.lower_bound({pos, -1, 0});
    if (it != odt.end() && it->l == pos) {
        return it;
    }

    // 真正的目标区间在 it 的前一个
    --it;
    int l = it->l, r = it->r;
    long long v = it->v;

    // 先删除原区间，再插入切分后的两个区间
    odt.erase(it);
    odt.insert({l, pos - 1, v});
    return odt.insert({pos, r, v}).first;
}
```

`lower_bound` 按左端点找到第一个 $\ge pos$ 的区间；如果它的左端点正好等于 `pos`，说明不需要切。否则目标区间在它前面一个，取出后删掉，再插入 `[l, pos-1]` 和 `[pos, r]` 两段，返回后者的迭代器。

### 模块三：`assign`（区间推平）

区间赋值是将 $[l,r]$ 内的所有数全部变成 $x$。

```cpp
void assign(int l, int r, long long x) {
    auto itr = split(r + 1);
    auto itl = split(l);

    // 删除 [itl, itr) 内的所有旧区间
    odt.erase(itl, itr);

    // 插入合并后的大区间
    odt.insert({l, r, x});
}
```

**非常关键的代码细节**：在调用 `split` 截取边界时，**必须先 `split(r + 1)`，再 `split(l)`**。如果先切 $l$，返回的迭代器可能会在后续切 $r+1$ 时因为所属区间的删除与重构而失效，引发未定义行为（RE）。

### 模块四：其他操作的暴力实现

只要把边界分出来，剩下的操作直接拿迭代器从 `itl` 遍历到 `itr` 暴力统计。

```cpp
void add(int l, int r, long long val) {
    auto itr = split(r + 1);
    auto itl = split(l);

    for (auto it = itl; it != itr; ++it) {
        it->v += val; // 由于使用了 mutable，可以直接修改
    }
}
```

区间第 $k$ 小则把涉及的每个段的信息取出塞进 `vector`，按值排序后累加元素个数：

```cpp
long long query_kth(int l, int r, int k) {
    auto itr = split(r + 1);
    auto itl = split(l);

    vector<pair<long long, int>> elements;
    for (auto it = itl; it != itr; ++it) {
        elements.push_back({it->v, it->r - it->l + 1});
    }

    sort(elements.begin(), elements.end());

    for (auto &[val, cnt] : elements) {
        k -= cnt;
        if (k <= 0) return val;
    }
    return -1;
}
```

区间 $k$ 次方和同理，遍历每一段，把「段长 $\times$ 段值的 $k$ 次方」累加（原文调用了 `qpow` 快速幂，该函数未在本节给出）：

```cpp
long long query_power_sum(int l, int r, long long ex, long long mod) {
    auto itr = split(r + 1);
    auto itl = split(l);

    long long sum = 0;
    for (auto it = itl; it != itr; ++it) {
        long long len = it->r - it->l + 1;
        sum = (sum + len * qpow(it->v % mod, ex, mod)) % mod;
    }
    return sum;
}
```

## 复杂度分析

- 在纯随机数据下，每次操作的期望时间复杂度为 $O(\log\log n)$ 或 $O(\log n)$。
- 每次 `split` 是一次 `set` 的 `lower_bound` 加至多两次插入/删除，单次 $O(\log n)$；暴力遍历的段数取决于当前 `set` 中的区间数量。
- 没有推平操作、或数据被刻意构造使区间碎裂时，区间数量退化至 $O(n)$，单次操作退化为 $O(n)$，整体复杂度变为 $O(n^2)$。
- 空间：`set` 中至多 $O(n)$ 个区间，$O(n)$。

## 适用场景

- 题目里有**区间赋值 / 区间推平**，且数据随机或部分分保证随机。
- 需要维护的操作花里胡哨（区间第 $k$ 小、区间 $k$ 次方和、区间加），线段树标记推不动，但暴力遍历区间段就能算。
- 赛场时间紧张，想先写一个不到 40 行的珂朵莉树骗到大部分甚至全部分数。
- **不适合**：没有推平操作、数据不随机、或者要求严格复杂度的正赛题。

珂朵莉树的核心魅力在于：**将线段树需要耗费巨大心力去推导、打标记的高难度操作，退化为人类最直观的暴力迭代**。

## 常见陷阱与注意事项

- `assign` / `add` 等区间操作必须**先 `split(r + 1)` 再 `split(l)`**，顺序反了迭代器会失效。
- `v` 要加 `mutable`，否则通过迭代器改不了值，只能删了重插。
- `split` 中 `pos > n` 要返回 `end()`；`lower_bound({pos, -1, 0})` 的临时节点只用于比较左端点。
- `erase(itl, itr)` 是左闭右开，右边界必须是 `split(r+1)` 得到的迭代器。
- 初始时如果每个元素单独成段，`set` 大小为 $n$；没有推平操作时它不会自动变小。
- 区间第 $k$ 小要用「段值 + 段长」排序累加，不能把每段只当一个元素。
- 数据不随机时复杂度会退化到 $O(n^2)$，别把它当唯一正解。
