---
id: prob-cf-1375f
title: 'Integer Game'
oj: 'Codeforces'
problemId: 'CF1375F'
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

暂无（原题：[CF1375F](https://www.luogu.com.cn/problem/CF1375F)）。

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
> 现有一个游戏：初始时有三个正整数 $a,b,c$，且 $a,b,c$ 互不相同。
>
> 每一轮中，先手选择一个 $y$，后手需要选择一个正整数将其加上 $y$，并且不能连续两轮选择同一个数。如果 $a,b,c$ 中存在两个数相同，则后手失败。若 $10^3$ 轮后，后手仍然没有失败，则先手失败。
>
> 你需要与交互库博弈，并且可以自由选择先后手，请击败交互库。

:::::success[题解]
考虑一种必胜局面。不妨设 $a<b<c$，并假设上一轮后手操作了 $c$。此时先手给出一个 $y$ 使得 $a+y=b \land b+y=c$，则先手胜。胜利条件即 $a,b,c$ 成等差数列。

于是我们作为先手，尝试构造一个 $y$ 使得局面必然变成等差数列。观察对手的选择：

- 若后手将 $y$ 加到 $a$ 上：新局面为 $b,c,a+y$，列方程 $a+y-c=c-b$ 得 $y=2c-b-a$。
- 若后手将 $y$ 加到 $b$ 上：新局面为 $a,c,b+y$，列方程 $b+y-c=c-a$ 得 $y=2c-b-a$。

于是我们给出 $y=2c-b-a$，如果后手加给 $a,b$ 就形成杀棋。

那么后手只能加 $c$。此时我们再给出一个 $y$，后手就无法行动了，因为规则禁止加 $c$。这样我们在 $O(1)$ 步内即可战胜后手。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
int x[5];
void _main() {
    cin >> x[1] >> x[2] >> x[3];
    cout << "First" << endl;
    while (true) {
        vector<int> y = {x[1], x[2], x[3]};
        sort(y.begin(), y.end());
        int a = y[0], b = y[1], c = y[2], d = 2 * c - b - a;
        if (b - a == c - b) d = b - a;
        cout << d << endl;
        int p; cin >> p;
        if (p == 0) break;
        x[p] += d;
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
