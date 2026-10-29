---
id: prob-cf-1503b
title: '3-Coloring'
oj: 'Codeforces'
problemId: 'CF1503B'
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

暂无（原题：[CF1503B](https://www.luogu.com.cn/problem/CF1503B)）。

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
> 现有一个 $n \times n$ 的网格和无限多的 $1,2,3$。
>
> 你需要与交互库博弈。每一轮交互库选择一个 $a \in [1,3]$，则你需要给出一个 $b \ne a$，然后选择一个空格子放置一个 $b$。
>
> 如果存在相邻两个格子放有相同数，则交互库胜利。否则 $n^2$ 轮后网格被填满，玩家胜利。你需要扮演玩家并战胜交互库。
>
> $n \le 100$。

::::::success[题解]
集合划分 + 网格图，考虑黑白染色 trick。将点染色以后可以划分为两个集合 $S,T$。

- 若交互库给出 $a=2$，则选择 $S$ 中任意点染 $1$，或者选择 $T$ 中任意点染 $3$。
- 若交互库给出 $a=1$，则选择 $T$ 中任意点染 $3$，如果用光就选择 $S$ 中任意点染 $2$。
- 若交互库给出 $a=3$，则选择 $S$ 中任意点染 $1$，如果用光就选择 $T$ 中任意点染 $2$。

用两个队列存 $S,T$，复杂度 $O(n^2)$。

::::::

::::info[代码]

```cpp line-numbers
int n;
queue<pair<int, int>> s, t;

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            if ((i + j) & 1) s.emplace(i, j);
            else t.emplace(i, j);
        }
    }
    for (int i = 1; i <= n * n; i++) {
        int a; cin >> a;
        if (a == 2) {
            if (s.empty()) {
                auto [x, y] = t.front(); t.pop();
                cout << 3 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = s.front(); s.pop();
                cout << 1 << ' ' << x << ' ' << y << endl;
            }
        } else if (a == 1) {
            if (t.empty()) {
                auto [x, y] = s.front(); s.pop();
                cout << 2 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = t.front(); t.pop();
                cout << 3 << ' ' << x << ' ' << y << endl;
            }
        } else {
            if (s.empty()) {
                auto [x, y] = t.front(); t.pop();
                cout << 2 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = s.front(); s.pop();
                cout << 1 << ' ' << x << ' ' << y << endl;
            }
        }
    }
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
