---
id: prob-luogu-p12509
title: '通信题'
oj: '洛谷'
problemId: 'P12509'
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

暂无（原题：[P12509](https://www.luogu.com.cn/problem/P12509)）。

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
> 现有两个至多有一个位置不同的 01 串 $S,T$。
>
> - A：已知 $S$，需要传递一个非负整数 $x$，满足 $x < 2^{20}$。
> - B：已知 $T$ 和 $x$，需要输出两个串不同的位置。特别地，若 $S=T$，应输出 0。
>
> $n \le 10^6$。

:::::success[题解]
A 传递的 $x$ 一定要包含 $S$ 的某些信息。简单来说，A 是加密的过程，B 是解密的过程。

我们有很巧妙的构造：记 $f(S)$ 为 $S$ 所有 $1$ 的下标异或和，则 A 直接传递 $x=f(S)$ 即可。

在 B 这里，因为 $n-1$ 位都不会变动，所以两次异或可以直接消去，最后剩下的那个位置就是不同的位置。形式化地说，我们求出 $f(T) \oplus x$ 并输出。

A & B 复杂度 $O(n)$。
:::::

:::::info[代码]

```cpp line-numbers
int f(const string& s) {
    int n = s.size(), res = 0;
    for (int i = 0; i < n; i++) {
        if (s[i] == '1') res ^= i + 1;
    } return res;
}
int Alice(string s) {return f(s);}
int Bob(string t, int x) {return f(t) ^ x;}
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
