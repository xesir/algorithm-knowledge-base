---
id: prob-qoj-17760
title: 'Telepathy'
oj: 'QOJ'
problemId: 'QOJ17760'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 基础算法
tags: ['题解']
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
knowledgePoints: []
---

> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ17760](http://qoj.ac/problem/17760)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和一个大小为 $k$ 的集合 $S$。保证 $S \subseteq \{1,2,\cdots,n\}$ 且 $k < \frac{n}{2}$。
>
>   必须选择一个正整数 $x$ 使得 $x \in [1,n] \land x \notin S$，令 $T = S \cap \{x\}$。
>
> - B：已知 $n,k$ 和大小为 $k+1$ 的集合 $T$。找出 $T \setminus S$，即 A 加的数字。
>
> 多测，$n \le 10^6$，$\sum n \le 3 \times 10^6$。

:::::success[题解]

在最坏情况下，有 $2 \nmid n$ 且 $2k+1=n$，故只需解决这一情况，其余情形可以通过加元素转化到这种情况。

考虑如下转化：对于 $[1,n]$ 中的每个数 $x$，若 $x \in S$ 则令 $a_x=1$，否则令 $a_x=-1$。记 $f(x)=\sum \limits_{i=1}^n a_i$，画出 $x - f(x)$ 的图像：

![](https://cdn.luogu.com.cn/upload/image_hosting/f24zqf6b.png)

容易发现如下性质：

- $f(n)=-1$。
- $f$ 存在唯一的循环位移，使得 $\forall i \in [1,n), f(i) \ge 0$。也即图中将坐标系移动到最低谷点的操作。

这个实际上是 Raney 引理的构造。

忽略 $f(n)$，则 $f(1) \sim f(n-1)$ 相当于一个合法括号序列。考虑用括号序列的结构给 $S$ 构造双射。

考虑 A 的策略。我们可以找到那个多出来的右括号 $-1$，也即寻找 $f(x)$ 在 $[1,n]$ 上第一个达到最小值的位置 $x$，并且将 $x$ 加入 $S$。

考虑 B 的策略。我们去找循环位移的起点，即寻找 $f(x)$ 在 $[1,n]$ 上最后一个达到最小值的位置 $x$。根据唯一性，A 添加的数字就是 $x+1$。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 2e6 + 5;
int n, k, a[N], s[N];

void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k; i++) cin >> s[i];
    int m = 2 * n - 2 * k - 1;
    fill(a + 1, a + m + 1, -1);
    for (int i = 1; i <= k; i++) a[s[i]] = 1;
    for (int i = n + 1; i <= m; i++) a[i] = 1;
    int f = 0, mf = 0, x = 0;
    for (int i = 1; i <= m; i++) {
        f += a[i];
        if (f < mf) mf = f, x = i;
    }
    for (int i = 1; i <= k; i++) cout << s[i] << ' ';
    cout << x << '\n';
}
```

B：

```cpp line-numbers
const int N = 2e6 + 5;
int n, k, a[N], t[N];

void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k + 1; i++) cin >> t[i];
    int m = 2 * n - 2 * k - 1;
    fill(a + 1, a + m + 1, -1);
    for (int i = 1; i <= k + 1; i++) a[t[i]] = 1;
    for (int i = n + 1; i <= m; i++) a[i] = 1;
    int f = 0, mf = 0, x = 0;
    for (int i = 1; i <= m; i++) {
        f += a[i];
        if (f <= mf) mf = f, x = i;
    } cout << x + 1 << '\n';
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
