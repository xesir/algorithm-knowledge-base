---
id: prob-luogu-p11647
title: '【MX-X8-T6】「TAOI-3」俄罗斯蓝猫'
oj: '洛谷'
problemId: 'P11647'
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

暂无（原题：[P11647](https://www.luogu.com.cn/problem/P11647)）。

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
> 交互库隐藏了一个长度为 $n$ 的非负整数序列 $a_0 \sim a_{n-1}$，保证 $a_i$ 在 $[0,10^{18}]$ 中随机生成。
>
> 你可以进行 $A$ 次询问，每次询问可以给出不超过 $B$ 个二元组 $(x_i,y_i)$，交互库返回 $a_{x_i}+a_{y_i}$ 构成的集合。
>
> 还原这个序列。
>
> 多测，$T=20$，$5 \le n \le 500$，满分要求 $A \le 2$，$B \le n-1$，$x_i \ne y_i$，每个 $(x_i,y_i)$ 在所有询问中至多出现 $1$ 次。3 秒，496 MB。

:::::success[题解]

由于 $a_i$ 在大值域中随机，不妨认为 $a_i$ 和 $a_i+a_j$ 都不重。

用图论语言刻画，第 $i$ 次询问 $(x,y)$ 相当于建一条 $x \leftrightarrow y$ 的无向边，并将边染上颜色 $i$。如果这个图存在自同构，则必然无法确定答案。

这样就能说明询问单链 / 单环 / 菊花必然不可行，同时表明构造的思路就是破坏对称性。

考虑对着平凡构造调整。做如下两次询问：

- $Q_1$：询问 $(0,1),(0,2),\cdots,(0,n-1)$ 构成一个菊花。
- $Q_2$：询问 $(1,2),(2,3),\cdots,(1,n-1)$ 构成一个环。

这个构造显然会爆。将 $Q_1,Q_2$ 中的 $(0,n-1)$ 和 $(1,2)$ 交换，那么 $Q_1$ 变成菊花带一个三元环，$Q_2$ 变成链上挂一个节点 $0$。下面给出 $n=5$ 时的图：

![](https://cdn.luogu.com.cn/upload/image_hosting/iydvngmx.png)

三元环和环上的点都不能轮换，故该图无自同构。

设两次询问得到的集合为 $S_1,S_2$，我们枚举 $x \in S_1$ 表示 $a_1+a_2=x$，再枚举 $y \in S_2$ 表示 $a_0+a_{n-1}=y$。将 $S_1 \setminus \{x\}$ 和 $S_2 \setminus \{y\}$ 作为下面求解的依据。

记 $s_1=\sum S_1 , s_2 = \sum S_2$，根据定义
$$
\begin{aligned}
s_1&=(n-2)a_0+\sum_{i=1}^{n-2} a_i\\
s_2&=2\left(\sum_{i=1}^{n-1} a_i\right)-(a_1+a_2)\
\end{aligned}
$$
再设 $s=\sum \limits_{i=1}^{n-1} a_i$，代入得 $s_1=(n-2)a_0+s-a_{n-1}$ 和 $s_2=2s-x$。枚举 $x,y$ 后联立 $a_0+a_{n-1}=y$ 得到三个方程，可以解得

$$
a_0=\dfrac{s_1-s+y}{n-1}
$$

这里可以加若干剪枝，即 $a_0$ 非负且 $a_0$ 是整数。

求出 $a_0$ 后再解方程求出 $a_1,a_2$，进而顺着环推一圈，检查最后得到的 $a_{n-1}$ 是否为 $y-a_0$ 即可。

单次 check 是 $O(n^2)$ 的，所以总复杂度似乎是 $O(n^4)$ 的。不过注意到枚举的 $x,y$ 正确率为 $\frac{1}{n}$，那么期望复杂度就是 $O(n^3)$。

::::::

::::::info[代码]

```cpp line-numbers
vector<i64> game(int n) {
    vector<i64> a(n);
    vector<int> x1 = {1}, y1 = {2};
    for (int i = 1; i < n-1; i++) x1.emplace_back(0), y1.emplace_back(i);
    vector<i64> S1 = ask(x1, y1);
    vector<int> x2 = {0, 1}, y2 = {n - 1, n - 1};
    for (int i = 2; i < n-1; i++) x2.emplace_back(i), y2.emplace_back(i+1);
    vector<i64> S2 = ask(x2, y2);
    i128 s1 = accumulate(S1.begin(), S1.end(), i128(0));
    i128 s2 = accumulate(S2.begin(), S2.end(), i128(0));
    auto check = [&](i64 x, i64 y) -> bool {
        set<i64> T1, T2(S2.begin(), S2.end());
        for (i64 v : S1) {
            if (v == x) continue;
            if (v < a[0]) return false;
            T1.emplace(v - a[0]);
        }
        for (i64 a1 : T1) {
            auto chk = [&]() -> bool {
                a[1] = a1, a[2] = x - a[1];
                if (!T1.count(a[2])) return false;
                set<i64> K1 = T1, K2 = T2;
                K1.erase(a[1]), K1.erase(a[2]), K2.erase(y);
                if (!K2.count(a[1] + a[n-1])) return false;
                K2.erase(a[1] + a[n-1]);
                for (int i = 3; i < n - 1; i++) {
                    bool fl = false;
                    for (i64 ai : K1) {
                        if (!K2.count(ai + a[i-1])) continue;
                        K1.erase(ai), K2.erase(ai + a[i-1]);
                        a[i] = ai; fl = true; break;
                    }
                    if (!fl) return false;
                }
                if (K2.count(a[n-2] + a[n-1])) return true;
            };
            if (chk()) return true;
        }
        return false;
    };
    for (i64 x : S1) for (i64 y : S2) {
        if ((s2 - y + x) & 1) continue;
        i128 num = s1 - x + y - (s2 - y + x) / 2;
        if (num < 0 || num % (n - 1)) continue;
        a[0] = num / (n - 1), a[n-1] = y - a[0];
        if (a[n-1] < 0) continue;
        if (check(x, y)) return a;
    } 
    return {};
}
```

::::::

### 【未完成】[CF1292E Rin and The Unknown Flower](https://www.luogu.com.cn/problem/CF1292E)

## 还原树 / 树找点

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
