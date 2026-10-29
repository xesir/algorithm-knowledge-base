---
id: prob-luogu-p8494
title: '[IOI 2022] 最罕见的昆虫'
oj: '洛谷'
problemId: 'P8494'
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

暂无（原题：[P8494](https://www.luogu.com.cn/problem/P8494)）。

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
> 交互库隐藏了一个序列 $a_i$，长度为 $n$。交互库会维护一个多重集合 $S$，你可以进行以下三种操作，每种操作至多 $T$ 次：
>
> - 给出 $i$，令 $S \gets S \cup \{a_i\}$。
> - 给出 $i$，令 $S \gets S \setminus \{a_i\}$。
> - 求 $S$ 中众数的出现次数。
>
> 要求 $S$ 中元素的下标两两不同。
>
> 求出原序列中出现最少的元素的出现次数。
>
> $n \le 2 \times 10^3$，满分要求 $T = 3n$。

:::::success[题解]

我们先扫描一遍序列求出颜色数：令 $i=1,2,\cdots,n$ 并加入 $a_i$，若众数次数 $\ge 2$ 则说明有重，将其弹出，否则新增一种颜色。设颜色数为 $c$。

特判 $c=1$ 和 $c=n$ 的平凡情形。一般情况考虑二分答案 $x$ 转判定。

受求颜色数的启发，给出如下流程：顺序扫描序列并加入 $a_i$，若众数次数 $>x$ 则将其弹出。设操作结束后集合大小为 $k$，答案不小于 $x$ 当且仅当 $k\ge cx$。注意 check 前清空集合。

直接做的操作次数为 $n \log n$，可以获得 [47.5pts](https://qoj.ac/submission/2568813)。

考察上述判定过程：

- 若 $k\ge cx$：此次 check 时加入的元素永久保留，不必清空 $S$。
- 若 $k<cx$：此次 check 时排除的元素永久放弃，不必在之后 check 时考虑。

用两个数组记录两类元素，一轮二分规模折半，询问次数 $\sum \limits_{i \ge 0} \dfrac{n}{2^i} \approx 2n$，加上初始求 $c$ 大约是 $3n$。可以获得 [99.95pts](https://qoj.ac/submission/2568915)。

需要卡常。一些常数优化：

- 当 $k \ge cx$ 时结束 check 过程；
- 二分上界设为 $\lfloor \frac{n}{c} \rfloor$；
- 初始轮剩余的元素永久保留；
- 奇数轮将 $\text{mid}$ 加 $1$。

提交后可以通过本题。

:::::

:::::info[代码]

```cpp line-numbers
int min_cardinality(int n) {
    int c = 0;
    vector<int> p, q, in(n), out(n);
    #define add move_inside
    #define del move_outside
    #define ask press_button
    for (int i = 0; i < n; i++) {
        add(i);
        if (ask() > 1) del(i);
        else c++, p.emplace_back(i);
    }
    if (c == 1) return n;

    for (int i : p) in[i] = true;
    auto check = [&](int x) -> bool {
        int cnt = 0; 
        p.clear(), q.clear();
        for (int i = 0; i < n; i++) {
            if (out[i]) continue;
            if (in[i]) {
                if (++cnt >= c * x) return true;
                continue;
            }
            add(i);
            if (ask() > x) del(i), q.emplace_back(i); 
            else cnt++, p.emplace_back(i);
            if (cnt >= c * x) return true;
        }
        return false;
    };
    int l = 1, r = n / c, res = -1;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (check(mid)) {
            res = mid, l = mid + 1;
            for (int i : p) in[i] = true;
        } else {
            r = mid - 1;
            for (int i : p) del(i);
            for (int i : q) out[i] = true;
        }
    } return res;
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
