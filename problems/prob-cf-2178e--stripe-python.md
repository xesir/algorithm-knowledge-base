---
id: prob-cf-2178e
title: 'Flatten or Concatenate'
oj: 'Codeforces'
problemId: 'CF2178E'
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

暂无（原题：[CF2178E](https://www.luogu.com.cn/problem/CF2178E)）。

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
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，$a_i$ 由以下方式生成：
>
> - 初始时有两个序列 $a=b=[2^k]$。
> - 每轮中，可以选择 $a$ 或 $b$ 序列中的最大值 $x$，将 $x$ 替换为两个 $x/2$，需要保证 $x$ 为偶数。
> - 或者选择将 $a,b$ 拼接起来，并将 $a,b$ 都替换为拼接后结果。
>
> 你可以向交互库询问一个区间的和。
>
> 求出 $a_i$ 中的最大值。
>
> 多测，$\sum n \le 10^5$，满分询问次数 $300$。

:::::success[题解]
首先我们发现拼接操作是诈骗，取一个足够大的 $k$ 可以做到和拼接同样的效果。

因此只考虑替换。可以发现，这个操作不会改变序列的和。

假设当前序列的总和为 $s$。则我们只需找到一个 $i$ 使得前 $i$ 个数的和为 $s/2$，就可以将数组分成两部分，然后分治求解。$i$ 可以通过二分找到。询问次数大概是 $n \log^2 n$ 的，无法通过。

一个关键的观察是：最大值一定出现在长度更短的一侧。因为操作强制选最大值，所以最大值只会不变或除二，单调不降。因此选择较短的一侧递归即可，次数 $\log^2 n$。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
int ask(int l, int r) {
    cout << "? " << l << ' ' << r << endl;
    int u; cin >> u;
    return u;
}
int n;

int solve(int l, int r, int sum) {
    if (l == r) return sum;
    int lo = l, hi = r, p = -1;
    while (lo <= hi) {
        int mid = (lo + hi) >> 1, val = ask(l, mid);
        if (val == sum / 2) {p = mid; break;}
        if (val < sum / 2) lo = mid + 1;
        else hi = mid - 1; 
    }
    if (p - l + 1 <= r - p) return solve(l, p, sum >> 1);
    return solve(p + 1, r, sum >> 1);
}

void _main() {
    cin >> n;
    int x = solve(1, n, ask(1, n));
    cout << "! " << x << endl;
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
