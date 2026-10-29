---
id: prob-luogu-p3574
title: '[POI 2014] FAR-FarmCraft'
oj: '洛谷'
problemId: 'P3574'
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

暂无（原题：[P3574](https://www.luogu.com.cn/problem/P3574)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵 $n$ 个点的有根树，根节点为 $1$。你从根节点开始游走，走过一条边的代价为 $1$，必须经过每条边恰好两次。
>
> 每个点有点权 $a_i$，当你游走到该点时，该点上会开始一个时长为 $a_i$ 的任务。最终回到根节点后，开始一个时长为 $a_1$ 的任务。最小化所有点完成任务的时间并输出。
>
> $n \le 5 \times 10^5$，1 秒，125 MB。

:::::success[题解]
考虑树形 DP，记 $f_u$ 为 $u$ 子树内的最大时间，$g_u$ 为将子树内游走完成的总时间。如果可以钦定一个游走儿子的顺序，就有转移：

$$
\begin{aligned}
f_u &\gets \max(f_u,f_v+g_u+1)\\
g_u &\gets  g_v+2
\end{aligned}
$$

关键在于确定 $f$。考虑和上一题一样做 exchange argument。考虑局部 $x,y$ 有：

- 不交换：贡献为 $\max(f_x+g_u+1, f_y+g_u+g_x+3)$；
- 交换：贡献为 $\max(f_y+g_u+1,f_x+g_u+g_y+3)$。

钦定前者更优，于是

$$
f_y+g_u+g_x+3 <f_x+g_u+g_y+3 \iff f_x-g_x>f_y-g_y
$$

这是一个严格偏序，按 $f_u-g_u$ 降序排序，然后做 DP 转移即可。复杂度 $O(n \log n)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 5e5 + 5;
int n, a[N], f[N], g[N];
vector<int> e[N];
void dfs(int u, int fa) {
    if (fa != -1) f[u] = a[u];
    vector<int> vec;
    for (int v : e[u]) {
        if (v == fa) continue;
        dfs(v, u), vec.emplace_back(v);
    }
    sort(vec.begin(), vec.end(), [](int x, int y) -> bool {
		return f[x] - g[x] > f[y] - g[y];
	});
    for (int v : vec) chkmax(f[u], f[v] + g[u] + 1), g[u] += g[v] + 2;
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i];
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    dfs(1, -1);
    cout << max(f[1], a[1] + g[1]);
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
