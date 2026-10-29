---
id: prob-luogu-p10384
title: '「HOI R1」杂交选种'
oj: '洛谷'
problemId: 'P10384'
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

暂无（原题：[P10384](https://www.luogu.com.cn/problem/P10384)）。

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
> 现有 $n$ 个个体，每个个体的基因型为 $\tt{AA}, \tt{Aa}, \tt{aa}$ 之一。每次操作可以向交互库询问一个个体的性状，或者令交互库将两个个体杂交，不能自交。杂交次数不能超过 $T$。
>
> 还原原本的基因序列。
>
> $n \le 2 \times 10^4$，满分要求 $T=4.5 \times 10^5$，交互库非自适应。

:::::success[题解]
考虑 Subtask 3 的做法，先一遍扫描扫出 $\tt{aa}$，然后用这个 $\tt{aa}$ 与其他含有 $\tt{A}$ 的个体杂交 $22$ 次，若杂交结果出现 $\tt{aa}$ 则确定为 $\tt{Aa}$，否则认定为 $\tt{AA}$，错误率极低。可以获得 [25 分](https://www.luogu.com.cn/record/269213539)。

这启示我们设法造出一个 $\tt{aa}$。如果允许自交，一个简单的做法就是扫一遍序列，然后将所有元素多次自交，这样 $\tt{Aa}$ 就有 $1/4$ 的概率造出 $\tt{aa}$。

本题不允许自交，那么我们有一种替代方法是让 $\tt{Aa}$ 与其后代杂交。具体地，我们随机一个个体先与当前个体杂交，则我们有 $\tt{AA} \times \tt{Aa} \to \tt{Aa}$，然后用 $\tt{Aa}$ 与 $\tt{Aa}$ 杂交即可。

由于上述策略错误率较高，我们用一个 vector 记录下其所有后代，并且随机一个后代进行杂交。

进行一些调参，将后代杂交重复 $12$ 次，得到 $\tt{aa}$ 以后的杂交上界根据当前杂交次数决定。这样可以通过本题，进行 $10$ 次提交测试中有 $4$ 次可以 AC。
:::::

:::::info[代码]

```cpp line-numbers
vector<string> guess(int n) {
    int cur = n;
    auto mix = [&](int u, int v) -> int {return cross(u, v), ++cur;};
    vector<string> res(n, "AA");
    vector<int> a(n + 5);
    for (int i = 1; i <= n; i++) a[i] = (query(i) == 'a');
    auto work = [&](int p, int lim) -> void {
        for (int i = 1; i <= n; i++) {
            if (a[i] == 1) {
                res[i - 1] = "aa";
            } else {
                int T = lim;
                while (T--) {
                    int x = mix(p, i);
                    if (query(x) == 'A') continue;
                    res[i - 1] = "Aa";
                    break;
                }
            }
        }
    };
    int p = find(a.begin(), a.end(), 1) - a.begin(); 
    if (p != (int)a.size()) return work(p, 22), res;
    for (int i = 1; i <= n; i++) {
        int x = rand32() % n + 1, T = 12;
        while (x == i) x = rand32() % n + 1;
        vector<int> son = {x};
        while (T--) {
            int idx = rand32() % son.size();
            int now = mix(son[idx], i);
            if (query(now) == 'a') return work(now, (4.5e5 - cur + n) / n), res;
            son.emplace_back(now), son.emplace_back(now);
        }
    }
    return res;
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
