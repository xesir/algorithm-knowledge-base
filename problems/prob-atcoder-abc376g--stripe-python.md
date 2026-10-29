---
id: prob-atcoder-abc376g
title: 'Treasure Hunting'
oj: 'AtCoder'
problemId: 'ABC376G'
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

暂无（原题：[ABC376G](https://www.luogu.com.cn/problem/AT_abc376_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵 $n+1$ 个点的有根树，根节点为 $0$。你从根节点开始游走，只能游走到父亲已经走过的点。每个点有 $\frac{a_i}{\sum a}$ 的概率为关键点，最小化到达关键点步数的期望值并输出，对 $998244353$ 取模。
>
> 多测，$\sum n \le 2 \times 10^5$，2 秒，1024 MB。

:::::success[题解]
树上 exchange argument 模板题。

将所有概率乘上 $\sum a$，答案再除回去。然后把题意翻译成：找到一个拓扑序 $b_i$，最小化 $\sum\limits_{i=1}^n a_ib_i$。

拓扑序是合并连通块的过程，合并的顺序考虑用 exchange argument 确定。记 $c_A$ 为连通块节点数目，$w_A$ 为块中点权和。对于块 $A,B$，将其交换位置的答案变化量为

$$
c_B w_A-c_A w_B
$$

钦定上式 $<0$ 移项得 $c_B w_A<c_A w_B \iff \frac{c_B}{w_B}<\frac{c_A}{w_A}$。这是一个严格全序，符合要求。

可以用并查集 + set 来维护。初始时，将所有节点加入集合，其中 $c_I=1,w_I=a_i$，按照 $\frac{w_A}{c_A}$ 为关键字降序排序。

每次取出最大的 $u$，将 $u$ 合并到父节点块 $v$ 中。这里 $v$ 是这个连通块的代表元，使用并查集找到。合并后 $v$ 的代价改变，删去旧值并插入新值即可。

总复杂度 $O(n \log n)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 2e5 + 5;
int n, p[N], fa[N];
int find(int x) {return x == fa[x] ? x : fa[x] = find(fa[x]);}
i64 a[N], c[N], w[N];

struct node {
    i64 w, c; int id;
    node(i64 x = 0, i64 y = 0, int z = 0) : w(x), c(y), id(z) {}
    bool operator< (const node& a) const {
        if (w * a.c != c * a.w) return w * a.c > c * a.w;
        return id < a.id;
    }
};
set<node> q;

void _main() {
    cin >> n;
    iota(fa, fa + n + 1, 0);
    for (int i = 1; i <= n; i++) cin >> p[i];
    for (int i = 1; i <= n; i++) cin >> a[i];
    mint sum = accumulate(a + 1, a + n + 1, mint(0)), cost = sum;
    copy(a, a + n + 1, w), fill(c, c + n + 1, 1);
    c[0] = 0, w[0] = 0;
    for (int i = 1; i <= n; i++) q.emplace(w[i], c[i], i);
    while (!q.empty()) {
        int u = q.begin()->id; q.erase(q.begin());
        int v = find(p[u]);
        if (v != 0) q.erase(node(w[v], c[v], v));
        cost += c[v] * w[u];
        c[v] += c[u], w[v] += w[u], fa[find(u)] = find(v);
        if (v != 0) q.emplace(w[v], c[v], v); 
    }
    cout << cost / sum << '\n';
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
