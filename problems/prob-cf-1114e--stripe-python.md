---
id: prob-cf-1114e
title: 'Arithmetic Progression'
oj: 'Codeforces'
problemId: 'CF1114E'
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

暂无（原题：[CF1114E](https://www.luogu.com.cn/problem/CF1114E)）。

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
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，$a_i$ 在升序排序以后是一个等差数列。你可以向交互库提出如下两种询问：
>
> 1. 给出 $p$，查询 $a_p$。
> 2. 给出 $x$，查询是否 $\exists i, a_i > x$。
>
> 还原等差数列的首项和公差。
>
> $n \le 10^6$，$0 \le a_i \le 10^9$，满分询问次数 $60$，交互库非自适应。

:::::success[题解]
操作二很容易想到猜数模型，所以我们二分最大值，操作次数 $\log V=30$ 次。记最大值为 $m$。

设公差为 $d$，此时我们发现一个性质：$\forall i, d \mid (m-a_i)$。这启示我们可以将剩下 $30$ 次单点询问用于确定 $d$，只需询问 $30$ 个 $a_i$ 取 $\gcd$ 即可。

本题中，我们随机取 $30$ 个 $a_i$，具有极高的正确率。通过一些数论方法可以证明这个东西的错误率在 $10^{-9}$ 左右，完全可以通过。
:::::

:::::info[代码]

```cpp line-numbers
int n;
int ask(int x) {
    cout << "? " << x << endl;
    int u; cin >> u;
    return u;
}
bool query(int x) {
    cout << "> " << x << endl;
    int u; cin >> u;
    return u;
}

void _main() {
    cin >> n;
    int l = 0, r = 1e9, mx = 0;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (query(mid)) l = mid + 1;
        else mx = mid, r = mid - 1;
    }
    int T = 30, d = 0;
    while (T--) {
        int x = ask(rand32() % n + 1);
        d = gcd(d, mx - x);
    }
    cout<< "! " << mx - (n - 1) * d << ' ' << d << endl;
} s
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
