---
id: basic-bubble-select-sort
title: '基础排序（冒泡 / 快速 / 归并）'
category: 基础算法
subcategory: 排序
tags: ["排序", "冒泡排序", "快速排序", "归并排序", "逆序对", "稳定性"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: B
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

排序算法把一组数据按指定顺序排列。衡量排序算法通常看三点：

- 时间复杂度；
- 空间复杂度；
- **稳定性**：相等的元素在排序后相对顺序是否保持不变。

冒泡、归并是稳定排序；快速排序在随机化划分下通常不稳定。

### 冒泡排序

从第一个元素开始，比较相邻两个元素，如果前面大于后面就交换。每一轮会把当前未排序部分的最大值“冒”到末尾；如果某一轮没有发生交换，说明已经有序，可以提前结束。

### 快速排序

快速排序基于分治：

1. 选一个基准数；
2. 把数组划分成“小于等于基准”“等于基准”“大于基准”三部分；
3. 递归左右两部分。

三路划分可以把与基准相等的元素集中到中间，避免全相同数组退化。随机选择基准可以降低被卡的概率。平均复杂度 $O(n\log n)$，最坏仍是 $O(n^2)$；C++ 的 `std::sort` 使用内省排序，最坏也能做到 $O(n\log n)$。

### 归并排序

归并排序同样基于分治：

1. 把数组从中间分成两半；
2. 递归排序左右两半；
3. 合并两个有序数组。

合并时用双指针，每次取较小者放入临时数组；相等时优先取左边，保证稳定性。时间复杂度 $O(n\log n)$，空间 $O(n)$。

归并排序还可以顺便求**逆序对**：合并左右两半时，若右边当前元素小于左边当前元素，则左边从当前位置到末尾的所有元素都与它构成逆序对，贡献为 `mid - i + 1`。

## 核心公式 / 状态定义与转移方程

- 冒泡排序比较次数：最坏 $\dfrac{n(n-1)}{2}$，时间 $O(n^2)$，空间 $O(1)$，稳定。
- 快速排序：
  - 划分后递归：$T(n)=T(L)+T(R)+O(n)$；
  - 平均 $O(n\log n)$，最坏 $O(n^2)$，空间 $O(\log n)$（递归栈），通常不稳定。
- 归并排序：
  - $T(n)=2T(n/2)+O(n)=O(n\log n)$；
  - 空间 $O(n)$，稳定。
- 逆序对贡献：合并时若 `a[j] < a[i]`，则 `a[i..mid]` 都与 `a[j]` 构成逆序对，贡献 `mid - i + 1`。

## 逐行代码解析

### 冒泡排序（带提前退出）

```pseudocode
Input. An Array A consisting of n elements.
Output. A sorted in nondecreasing order stably.
Method.
need_sort <- True
while need_sort
    need_sort <- False
    for i <- 1 to n - 1
        if A[i] > A[i + 1]
            need_sort <- True
            Swap A[i] and A[i + 1]
```

- 外层 `while` 控制轮数；如果一轮没有交换，`need_sort` 保持假，提前结束。
- 内层只比较相邻元素，严格逆序才交换，因此稳定。
- 最坏（完全逆序）需要 $\dfrac{n(n-1)}{2}$ 次交换。

### 快速排序（三路划分）

```pseudocode
Input. An Array A of n elements.
Output. A sorted in nondecreasing order.
function quick_sort(Arr, len)
    if len <= 1 return
    pivot <- Arr[rand() % len]
    i <- 0, j <- 0, k <- len
    while i < k
        if Arr[i] < pivot
            Swap Arr[i] and Arr[j]
            i <- i + 1
            j <- j + 1
        else if pivot < Arr[i]
            k <- k - 1
            Swap Arr[i] and Arr[k]
        else
            i <- i + 1
    quick_sort(Arr, j)
    quick_sort(Arr + k, len - k)
```

- `[0,j)` 是小于基准的部分，`[j,i)` 是等于基准的部分，`[k,len)` 是大于基准的部分。
- 遇到小于基准就换到前面；遇到大于基准就换到后面；等于基准就跳过。
- 递归只处理小于和大于两部分，等于基准的已经就位。
- 三路划分让全相同数组变成 $O(n)$，但最坏情况仍可能 $O(n^2)$。

### 归并排序

```pseudocode
Input. An Array A of n elements.
Output. A sorted in nondecreasing order stably.
function merge_sort(Arr, l, r)
    if l >= r return
    mid <- (l + r) / 2
    merge_sort(Arr, l, mid)
    merge_sort(Arr, mid + 1, r)
    i <- l, j <- mid + 1, k <- l
    while i <= mid and j <= r
        if Arr[i] <= Arr[j]
            tmp[k] <- Arr[i]
            i <- i + 1
        else
            tmp[k] <- Arr[j]
            j <- j + 1
        k <- k + 1
    while i <= mid
        tmp[k] <- Arr[i]
        i <- i + 1
        k <- k + 1
    while j <= r
        tmp[k] <- Arr[j]
        j <- j + 1
        k <- k + 1
    for p <- l to r
        Arr[p] <- tmp[p]
```

- 先递归左右两半，再把两个有序段合并。
- `Arr[i] <= Arr[j]` 时取左边，保证相等元素的相对顺序不变，因此稳定。
- 合并需要 $O(n)$ 的临时数组。

### 逆序对计数

```pseudocode
function merge_count(Arr, l, r)
    if l >= r return 0
    mid <- (l + r) / 2
    ans <- merge_count(Arr, l, mid) + merge_count(Arr, mid + 1, r)
    i <- l, j <- mid + 1, k <- l
    while i <= mid and j <= r
        if Arr[i] <= Arr[j]
            tmp[k] <- Arr[i]; i <- i + 1
        else
            tmp[k] <- Arr[j]; j <- j + 1
            ans <- ans + (mid - i + 1)
        k <- k + 1
    ...
    return ans
```

- 当右边元素更小时，左边从 `i` 到 `mid` 的所有元素都大于它，都会与它构成逆序对。
- 逆序对计数与归并排序共用同一套合并框架，只多一行贡献计算。

## 复杂度分析

| 算法 | 最坏时间 | 平均时间 | 空间 | 稳定性 |
|---|---|---|---|---|
| 冒泡排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 |
| 快速排序（三路） | $O(n^2)$ | $O(n\log n)$ | $O(\log n)$ | 不稳定 |
| 归并排序 | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 |
| `std::sort`（内省排序） | $O(n\log n)$ | $O(n\log n)$ | $O(\log n)$ | 不稳定 |
| `std::stable_sort` | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 |

## 适用场景

- 冒泡排序：教学、理解交换与稳定性；实际竞赛很少直接使用。
- 快速排序：一般排序、需要原地排序的场合；竞赛中直接用 `std::sort`。
- 归并排序：需要稳定排序、求逆序对、合并两个有序序列。
- `std::sort`：绝大多数竞赛排序场景。
- `std::stable_sort`：需要保持相等元素原顺序时。

## 常见陷阱与注意事项

1. **冒泡排序忘记提前退出**：没有交换时继续扫完，复杂度严格 $O(n^2)$；加上 `need_sort` 可以在近似有序时更快。
2. **快速排序基准选得不好**：固定选第一个元素可能被有序/逆序数据卡到 $O(n^2)$；随机基准或三路划分更稳。
3. **归并排序忘记把临时数组写回**：合并完必须把 `tmp[l..r]` 写回 `Arr[l..r]`。
4. **归并排序的稳定性**：合并时相等元素要优先取左边，否则不稳定。
5. **逆序对贡献的方向**：只有右边元素更小时才统计左边剩余元素；方向写反会多算/少算。
6. **递归深度**：快速排序最坏递归深度 $O(n)$，可能爆栈；随机化/三路划分可缓解。
7. **`std::sort` 不稳定**：需要稳定时用 `std::stable_sort`。
8. **排序对象较大**：比较函数应传引用，避免复制；比较器必须满足严格弱序。

## 对比与扩展

- **冒泡 vs 选择 vs 插入**：三者都是 $O(n^2)$；冒泡和插入稳定，选择不稳定；插入排序在近似有序时表现较好。
- **快速排序 vs 归并排序**：快排原地、平均常数小，但不稳定且最坏 $O(n^2)$；归并稳定、最坏 $O(n\log n)$，但需要 $O(n)$ 额外空间。
- **归并排序 vs 树状数组求逆序对**：归并排序一遍合并即可统计，常数小；树状数组适合带修改或值域较小的场景。
- **`std::sort` vs `std::stable_sort`**：前者更快，后者稳定；需要稳定时不要用 `std::sort` 代替。
- **讲义练习**：A2096、C1014、P1124、P1126、C1105、YL1040E4、G1125。题号以原讲义为准。
