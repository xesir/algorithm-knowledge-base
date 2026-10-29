---
id: prob-cf-1762d
title: 'GCD Queries'
oj: 'Codeforces'
problemId: 'CF1762D'
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

暂无（原题：[CF1762D](https://www.luogu.com.cn/problem/CF1762D)）。

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
> 交互库隐藏了一个 $0 \sim n-1$ 的排列 $a_i$。你可以给出 $i,j$，向交互库询问 $\gcd(i,j)$。
>
> 找到两个位置 $x,y$，使得 $a_x =0\lor a_y=0$ 成立。
>
> 多测，$\sum n \le 2 \times 10^4$，满分询问次数 $2n$，交互库非自适应。

:::::success[题解]
增量法。由 $\gcd(0,x)=x$，我们考虑三个数 $a,b,c$ 并询问 $\gcd(a,b),\gcd(a,c)$：

- 若 $\gcd(a,b)=\gcd(a,c)$，则 $a \ne 0$；
- 若 $\gcd(a,b)<\gcd(b,c)$，则 $b \ne 0$；
- 若 $\gcd(a,b)>\gcd(b,c)$，则 $c \ne 0$。

维护候选集合 $S$，加入一个数使用上述方法排除，直到剩下的 $|S|=2$ 即可。询问次数 $2n-4$。
:::::

:::::info[代码]

```cpp line-numbers
int n;
int ask(int i, int j) {
    cout << "? " << i << ' ' << j << endl;
    int x; cin >> x;
    return x;
}
void answer(int i, int j) {
    cout << "! " << i << ' ' << j << endl;
    int x; cin >> x;
}

void _main() {
    cin >> n;
    deque<int> q = {1, 2};
    for (int i = 3; i <= n; i++) {
        int x = ask(q[0], q[1]), y = ask(q[0], i);
        if (x == y) q.pop_front(), q.emplace_back(i);
        else if (x < y) q.pop_back(), q.emplace_back(i);
    }
    answer(q[0], q[1]);
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
