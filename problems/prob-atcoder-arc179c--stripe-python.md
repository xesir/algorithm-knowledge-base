---
id: prob-atcoder-arc179c
title: 'Beware of Overflow'
oj: 'AtCoder'
problemId: 'ARC179C'
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

暂无（原题：[ARC179C](https://www.luogu.com.cn/problem/AT_arc179_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个正整数 $k$ 和长为 $n$ 的序列 $a_i$。保证 $|a_i| \le k, \left|\sum \limits_{i=1}^n a_i\right| \le k$。你可以进行如下两种操作：
>
> - 选择 $i,j$，删去 $a_i,a_j$ 并加入 $a_i+a_j$，要求 $|a_i+a_j| \le k$；
> - 选择 $i,j$，查询 $a_i<a_j$ 是否成立。
>
> 构造一组操作，使得最终序列中仅剩 $1$ 个数。
>
> $n \le 10^3$，满分操作次数 $2.5 \times 10^4$，交互库非自适应。

:::::success[题解]
容易发现在不知道任何信息的情况下做操作一是找死。

注意到操作次数为 $n \log n$ 级别，考虑利用操作二将序列排序。

接下来，考虑每轮选择最小值和最大值相加，可以讨论正负证明合法。重复 $n-1$ 轮即可。

此时需要修正序列的有序性，考虑二分找插入位置，然后暴力模拟，复杂度可以接受。操作次数为 $2 n \log n$，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
bool ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int a; cin >> a;
    return a;
}
int add(int x, int y) {
    cout << "+ " << x << ' ' << y << ' ' << endl;
    int a; cin >> a;
    return a;
} 
int n;

void _main() {
    cin >> n;
    deque<int> a(n);
    iota(a.begin(), a.end(), 1);
    stable_sort(a.begin(), a.end(), ask);
    for (int i = 1; i < n; i++) {
        int x = a.front(), y = a.back(), z = add(x, y);
        a.pop_front(), a.pop_back();
        a.insert(lower_bound(a.begin(), a.end(), z, ask), z);
    }
    cout << "!" << endl;
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
