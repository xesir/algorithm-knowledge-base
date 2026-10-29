---
id: prob-luogu-p7109
title: '滴水不漏'
oj: '洛谷'
problemId: 'P7109'
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

暂无（原题：[P7109](https://www.luogu.com.cn/problem/P7109)）。

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
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，其中 $a_i$ 表示第 $i$ 个水杯中水的体积，第 $i$ 个水杯容量为 $i$。你可以给出 $i,j$，交互库将第 $i$ 个水杯中的水倒到第 $j$ 个水杯，并回答是否倒满。操作之间不独立。
>
> 还原原本的序列。
>
> $n \le 10^3$，满分询问次数 $2 \times 10^4$，交互库非自适应。

:::::success[题解]
考虑如下情景：当前需要确定 $x$ 水杯中水的体积，且 $[1,x)$ 的水杯均已清空。可以想到猜数模型，二分体积 $v$，然后倒水 $x \to v$，根据是否倒满来判断，判断以后再撤销操作。

我们依次确定每个水杯。如果能够做到这一点，询问次数就是 $2n \log n$ 且跑不满。

考虑用一个特殊水杯 $t$ 存多余的水。我们每次确定 $i$ 后将水导入，如果倒满就再次二分得到剩余水量，然后令 $t \gets t-1$。同时还要记录一下 $t$ 被倒入多少水，这样减一下就是答案。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 1005;
int n, a[N];
bool ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int u; cin >> u;
    return u;
}

int solve(int x, int lim) {
    if (lim == x) {
        if (ask(x, x)) return x;
        lim--;
    }
    if (lim <= 0) return 0;
    int l = 1, r = lim, res = 0;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (ask(x, mid)) l = mid + 1, res = mid;
        else r = mid - 1;
        ask(mid, x); 
    } return res;
}

void _main() {
    cin >> n;
    int t = n, sum = 0;
    for (int i = 1; i <= n; i++) {
        if (i == t) {
            a[t] = solve(t, t) - sum;
            break;
        }
        int cur = solve(i, i);
        a[i] = cur;
        while (cur > 0 && i < t) {
            if (ask(i, t)) {
                int x = solve(i, cur);
                a[t] = t - (cur - x) - sum;
                t--, sum = 0, cur = x;
            } else {
                sum += cur, cur = 0;
            }
        }
        if (t <= i) break;
    }
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
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
