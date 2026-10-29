---
id: prob-luogu-p5290
title: '[十二省联考 2019] 春节十二响'
oj: '洛谷'
problemId: 'P5290'
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

暂无（原题：[P5290](https://www.luogu.com.cn/problem/P5290)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵以 $1$ 为根的有根树，节点数为 $n$，点带权 $a_i$。你需要将这些节点划分为若干个集合 $S_1,S_2,\cdots,S_k$，满足集合内部不存在祖先—后代关系。最小化 $\sum\limits_{i=1}^k \max\limits_{u \in S_i} a_u$ 并输出。
>
> $n \le 2 \times 10^5$，1 秒，500 MB。

:::::success[题解]

对于点 $u$ 的两个儿子 $x,y$，由于集合不能存在祖先—后代关系，因此 $x$ 的答案需要与 $y$ 合并。

注意到 $\max$ 的四边形不等式 $a<b<c<d \implies \max(a,b)+\max(c,d) < \max(a,c)+\max(b,d)$。根据 exchange argument 的理论，将 $x,y$ 的答案升序排序后依次配对，在局部即为最优。

接下来证明局部最优不会影响祖先答案。将不升序列 $a_i,b_i$ 合并后的 $c_i=\max(a_i,b_i)$ 也是一个不升序列。因此采用其他合并方法得到 $c'_i$ 并降序排序后必然有 $c'_i \ge c_i$。

子树 $u$ 继续向上合并时，提供一个更劣的 $c'_i$ 一定不优。因此上传 $c_i$ 就是全局最优。

直接模拟即可 $O(n^2)$。用启发式合并维护优先队列就有 $O(n \log n)$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 2e5 + 5;
int n, a[N];
vector<int> e[N];
priority_queue<int> q[N];
void join(int u, int v) {
    if (q[u].size() < q[v].size()) swap(q[u], q[v]);
    vector<int> vec;
    while (!q[v].empty()) {
        vec.emplace_back(max(q[u].top(), q[v].top()));
        q[u].pop(), q[v].pop();
    }
    for (int i : vec) q[u].emplace(i);
}
void dfs(int u) {
    for (int v : e[u]) dfs(v), join(u, v);
    q[u].emplace(a[u]);
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i];
    for (int v = 2, u; v <= n; v++) cin >> u, e[u].emplace_back(v);
    dfs(1); i64 res = 0;
    while (!q[1].empty()) res += q[1].top(), q[1].pop();
    cout << res;
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
