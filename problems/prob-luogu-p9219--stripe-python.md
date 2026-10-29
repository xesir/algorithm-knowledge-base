---
id: prob-luogu-p9219
title: '「TAOI-1」Antipathy World'
oj: '洛谷'
problemId: 'P9219'
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

暂无（原题：[P9219](https://www.luogu.com.cn/problem/P9219)）。

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
> 交互库隐藏了一个序列 $a_i$，长度为 $n$。你可以给出 $i,j$，向交互库查询 $|a_i-a_j|$。
>
> 找出 $x$ 使得 $\forall i \ne x, a_x \ge 2a_i$。
>
> 多测，$T \le 25$，$n \le 5 \times 10^4$，满分询问次数 $\lfloor n/2\rfloor+2$。

:::::success[题解]
注意到询问次数与 $n/2$ 有关，考虑分组询问。对于 $i=1,3,\cdots$，我们询问 $i,i+1$，得到 $\lfloor n/2\rfloor$ 个答案。

这样一来，我们一定会得到一个最大差。设其位置为 $p$，则 $x$ 就在这一组或者没有问到的数里面。分类讨论一下：

- 若 $n$ 为偶数：则 $x \in \{p,p+1\}$，再任找一个 $y$，比较 $|a_p-a_y|$ 和 $|a_{p+1}-a_y|$ 即可。
- 若 $n$ 为奇数：则 $x \in \{p,p+1,n\}$，我们询问 $|a_p-a_n|$ 和 $|a_{p+1}-a_n|$，然后根据三个数的大小关系容易得到 $x$。

容易发现操作次数恰好为 $\lfloor n/2\rfloor+2$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 5e4 + 5;
int n, k, a[N];
int ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int u; cin >> u;
    return u;
}

void _main() {
    cin >> n >> k;
    fill(a + 1, a + n + 1, 0);
    for (int i = 1; i < n; i += 2) a[i] = ask(i, i + 1);
    int p = max_element(a + 1, a + n + 1) - a;
    if (n & 1) {
        int x = ask(p, n), y = ask(p + 1, n);
        if (x > a[p] && y > a[p]) cout << "! " << n << endl;
        else if (x > y) cout << "! " << p << endl;
        else cout << "! " << p + 1 << endl;
    } else {
        int x = 1;
        if (p == 1) x = 3;
        if (ask(p, x) > ask(p + 1, x)) cout << "! " << p << endl;
        else cout << "! " << p + 1 << endl;
    }
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
