---
id: prob-yloi2019
title: 'P5521 [] 梅深不见冬'
oj: '来源未考证'
problemId: 'YLOI2019'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 图论
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

暂无（原题：[YLOI2019](https://www.luogu.com.cn/problem/P5521)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵节点数为 $n$ 的有根树，根节点为 $1$，带点有点权 $a_u$。
>
> 你初始持有 $f_u$ 个物品，位于节点 $1$。你可以在树上进行游走，可以选择进入一个未进入的子节点，或者回到父节点。
>
> 你需要在每个节点上放置若干物品。对于非叶节点 $u$，允许在其上放置物品的条件为：每个子节点 $v$ 的物品数都恰好为 $ a_v$。
>
> 你可以在任意时刻回收任意节点上的物品，且不需要走到对应点。
>
> 对于 $u=1,2,\cdots,n$，求出在节点 $u$ 上放置 $a_u$ 个物品所需的 $f_u$ 的最小值。
>
> $n \le 10^5+4$，1 秒，500 MB。

:::::success[题解]
考虑树形 DP，设 $f_u$ 为节点答案。注意到 $u$ 点可回收的物品数恰好为 $a_u$。我们钦定某种顺序，依次游走子树 $v_1,v_2,\cdots,v_k$，那么有转移：

$$
\begin{aligned}
f_u &\gets \sum_{i=1}^{x-1} a_{v_i}+f_{v_x}, x =1,2,\cdots,k\\
f_u &\gets \sum_{i=1}^k a_i+f_u
\end{aligned}
$$

根据木桶原理这里做的是 chkmax。前面这个求和式表示之前回收的物品总数，容易前缀和维护。

现在考虑如何对儿子 $v_i$ 排序，想到用 exchange argument，考虑局部，设两儿子为 $x,y$。

记前面的和式为 $S$，则讨论先 $x$ 后 $y$ 和先 $y$ 后 $x$ 所造成的局部 $\max$：

- 先 $x$ 后 $y$：
  - 处理 $x$ 时的需求量为 $S+f_x$。
  - 处理 $y$ 时，$S \gets S+a_x$，故需求量 $S+a_x+f_y$。
  - 故局部峰值为 $\max(S+f_x,S+a_x+f_y)=S+\max(f_x,a_x+f_y)$。
- 先 $y$ 后 $x$ 同理，得局部峰值 $S+\max(f_y,a_y+f_x)$。

令 $\max(f_x,a_x+f_y)<\max(f_y,a_y+f_x)$。

根据 $a_x,a_y \ge 1$，我们有 $f_x < f_x+a_y \land a_x+f_y>f_y$，故原不等式写为

$$
a_x+f_y<a_y+f_x \iff f_x-a_x > f_y-a_y
$$

得证，按 $f_v-a_x$ 降序排序即可，显然严格全序。

复杂度 $O(n \log n)$。用邻项交换贪心来确定 DP 转移顺序，十分精妙。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 1e5 + 10;
int n, a[N];
vector<int> e[N];
i64 f[N];

void dfs(int u) {
    for (int v : e[u]) dfs(v);
    sort(e[u].begin(), e[u].end(), [](int x, int y) -> bool {
        return f[x] - a[x] > f[y] - a[y]; 
    });
    i64 sum = 0;
    for (int v : e[u]) f[u] = max(f[u], sum + f[v]), sum += a[v];
    f[u] = max(f[u], sum + a[u]);
}

void _main() {
    cin >> n;
    for (int i = 2, x; i <= n; i++) cin >> x, e[x].emplace_back(i);
    for (int i = 1; i <= n; i++) cin >> a[i];
    dfs(1);
    for (int i = 1; i <= n; i++) cout << f[i] << ' '; 
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
