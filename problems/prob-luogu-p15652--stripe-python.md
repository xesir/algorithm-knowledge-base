---
id: prob-luogu-p15652
title: '[省选联考 2026] 排列游戏'
oj: '洛谷'
problemId: 'P15652'
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

暂无（原题：[P15652](https://www.luogu.com.cn/problem/P15652)）。

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
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以向交互库询问一个区间的 $\operatorname{mex}$。
>
> 还原这个排列。只要你给出的排列和正确排列每个区间的 $\operatorname{mex}$ 相等即认为答案正确。
>
> $n \le 3 \times 10^4$，满分询问次数 $n$。

:::::success[题解]

在排列中，区间 $\operatorname{mex}$ 等于补集 $\min$。形式化地
$$
\operatorname{mex} \limits_{i=l}^r p_i=\min\left\{\min_{i=1}^{l-1} p_i, \min _{i=r+1}^n p_i\right\}
$$
我们发现只有前后缀 $\min$ 是有用的，知道这 $2n$ 个信息后其他询问可以直接拼出来，所以先做 $2n$ 次询问。

询问完成后，在前后缀 $\min$ 产生突变的位置，我们可以确定答案。而两个已确定数中间只需要比它大即可，可以任意填入。

考虑缩减操作次数。我们发现问到 $0$ 以后前后缀 $\min$ 一定是 $0$，可以省略询问。猜数模型，二分求出 $0$，次数 $n+\log n$。

进一步，可以先问前缀 $\min$ 直到出现 $0$，此时我们就确定了 $0$ 的位置，从后面再开始问，次数压缩到 $n$。

:::::

::::info[代码]

```cpp line-numbers
vector<int> perm(int n) {
    vector<int> pre(n), suf(n), res(n, -1);
    int pos0 = n - 1;
    for (int i = 0; i < n - 1; i++) {
        pre[i] = query(i + 1, n - 1);
        if (pre[i] == 0) {pos0 = i; break;}
    }
    for (int i = n - 1; i > pos0; i--) suf[i] = query(0, i - 1);
    for (int i = 0; i < n - 1; i++) {
        if (i == 0 || pre[i] != pre[i - 1]) res[i] = pre[i];
    }
    for (int i = n - 1; i >= 1; i--) {
        if (i == n - 1 || suf[i + 1] != suf[i]) res[i] = suf[i];
    }
    set<int> q;
    vector<int> vis(n);
    for (int i = 0; i < n; i++) if (res[i] != -1) vis[res[i]] = 1;
    for (int i = 0; i < n; i++) if (!vis[i]) q.emplace(i);
    for (int l = -1, r = 0; r < n; r++) {
        if (res[r] == -1) continue;
        if (l == -1) {l = r; continue;}
        int low = max(res[l], res[r]);
        for (int i = l + 1; i < r; i++) {
            assert(!q.empty());
            auto it = q.upper_bound(low);
            assert(it != q.end());
            res[i] = *it;
            q.erase(it);
        }
        l = r;
    }
    return res;
}
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
