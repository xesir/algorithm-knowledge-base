---
id: prob-cf-1061f
title: 'Lost Root'
oj: 'Codeforces'
problemId: 'CF1061F'
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

暂无（原题：[CF1061F](https://www.luogu.com.cn/problem/CF1061F)）。

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
> 已知一棵 $n$ 个节点的满 $k$ 叉树，交互库隐藏了所有节点的标号。一次询问给出 $a,b,c$，交互库回答 $b$ 是否在 $a \to c$ 的简单路径上。
>
> 找到根节点的标号。
>
> $n \le 1500$，$2 \le k < n$，满分询问次数 $60n$，交互库非自适应。

:::::success[题解]
注意到满 $k$ 叉树的直径中点一定是根节点。

先考虑怎么找直径。我们发现直接随机两个点有 $\frac{1}{2} \times \frac{1}{4}=\frac{1}{8}$ 的概率找到直径。而且可以通过 $n-2$ 次询问知道路径上的节点，也就知道了路程长度。

实际上直径的路径长可以通过 $n,k$ 算出来。故期望 $8$ 轮就能找到一条直径。

剩下的事情是简单的，考虑枚举路径上的每一个点，计算该点到两个直径端点的距离，如果相等就找到了根。一个优化是，我们只取直径上的点就能找到路径长度。

期望询问次数 $8n+2\log^2 n $，足以通过。
:::::

:::::info[代码]

```cpp line-numbers
const double eps = 1e-6;
bool ask(int a, int b, int c) {
    cout << "? " << a << ' ' << b << ' ' << c << endl;
    string s; cin >> s;
    return s == "Yes";
}
void answer(int x) {cout << "! " << x << endl, exit(0);}

int n, k;
vector<int> path(int u, int v) {
    vector<int> vec = {u, v};
    for (int i = 1; i <= n; i++) {
        if (i == u || i == v) continue;
        if (ask(u, i, v)) vec.emplace_back(i);
    } return vec;
}
int len(int u, int v) {return path(u, v).size();}

void _main() {
    cin >> n >> k;
    int h = log(n * (k - 1) + 1) / log(k) - 1 + eps, u, v;
    while (true) {
        do u = rand32() % n + 1, v = rand32() % n + 1;
        while (u == v);
        if (len(u, v) == 2 * h + 1) break;
    }
    vector<int> vec = path(u, v);
    for (int i : vec) {
        if (i == u || i == v) continue;
        int c1 = 0, c2 = 0;
        for (int j : vec) {
            if (ask(i, j, u)) c1++;
            if (ask(i, j, v)) c2++;
        }
        if (c1 == c2) answer(i);
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
