---
id: prob-luogu-p9755
title: '[CSP-S 2023] 种树'
oj: '洛谷'
problemId: 'P9755'
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

暂无（原题：[P9755](https://www.luogu.com.cn/problem/P9755)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵节点树为 $n$ 的有根树，根节点为 $1$。每个节点上有一个任务。每个时刻，你可以标记一个节点，要求这个节点为根或其父亲已被标记。
>
> 对于被标记的节点，在第 $x$ 个时刻任务的完成度将会增加 $\max(1,b_i+x\times c_i)$。目标为所有节点 $i$ 上任务的完成度 $\ge a_i$。初始时任务完成度均为 $0$。
>
> 求完成所有任务的最小时间。
>
> $1 \le n \le 10^5$，$1 \le a_i \le 10^{18}$，$1 \le b_i \le 10^9$，$-10^9 \le c_i \le 10^9$，保证答案 $\le 10^9$，1 秒，512 MB。

:::::success[题解]
考虑特殊性质 A，即 $c_i=0$ 的情形。此时可以求出完成每个任务所需的时间 $t_i = \lceil \frac{a_i}{b_i} \rceil$。考虑如下贪心：将节点按照 $t_i$ 升序排序，依次扫描每个节点，将对应的根链全部标记。

由于答案取决于每个任务的最晚完成时间，因此考虑调整后一定不优，可以说明这个做法的正确性。

上述算法直观的实现是树剖线段树，复杂度 $O( n \log^2 n)$。但是这个过于魔怔了，考虑直接暴力，由于每个点最多被标记一次，跳父亲一共只有 $O(n)$ 次，因此复杂度正确。

接下来考虑特殊性质 B，即链的情形。考虑二分答案 $x$，对于每个点求出 $f(x,l,r)$，表示节点 $x$ 在时间段 $[l,r]$ 完成度的变化量，即可进行 check。下面讲解 $f$ 的计算。

- 若 $c_x \ge 0$，此时增长量单调增，套等差数列求和即得 $f(x,l,r)=(r-l+1) \times b_x+\frac{(r-l+1)(l+r)}{2} c_x$。
- 否则需要分类讨论。列不等式 $b_x+k\times c_x \le 1$ 得 $k_{\min} =\lfloor \frac{1-b_x}{c_x} \rfloor$，表示在时刻 $[k,+\infty)$ 中增长量恒为 $1$。
  - 若 $k < l$，则增长量恒为 $1$，此时 $f(x,l,r)=r-l+1$；
  - 若 $k>r$，则增长量恒为等差数列，与 $c_x\ge 0$ 的式子相同：$f(x,l,r)=(r-l+1)\times b_x+\frac{(r-l+1)(l+r)}{2} c_x$；
  - 若 $k \in [l,r]$，则增长量分为等差数列段和常数段。分段计算知 $f(x,l,r)=(k-l+1) \times b_x+\frac{(k-l+1)(l+k)}{2}c_x+r-k$。

可以做到 $O(1)$ 求解。注意计算 $f$ 的过程需要 int128。

考虑将 A & B 的做法结合起来。我们二分答案 $x$ 转判定，判定时再对每个节点二分一次，通过 $f$ 求出每个节点最晚完成任务的时间 $t_i$。

按照 $t_i$ 升序排序，使用 A 性质的均摊 $O(n)$ 做法即可，复杂度 $O(n \log n \log V)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 1e5 + 5;
int n, fa[N], tag[N];
vector<int> e[N];
void dfs(int u) {
    for (int v : e[u]) if (v != fa[u]) fa[v] = u, dfs(v); 
}
i64 a[N], b[N], c[N], t[N];
i128 f(int x, i128 l, i128 r) {
    if (c[x] >= 0) return (r - l + 1) * b[x] + (r - l + 1) * (l + r) / 2 * c[x];
    i64 k = (1 - b[x]) / c[x];
    if (k < l) return r - l + 1;
    if (k > r) return (r - l + 1) * b[x] + (r - l + 1) * (l + r) / 2 * c[x];
    return (k - l + 1) * b[x] + (k - l + 1) * (l + k) / 2 * c[x] + r - k;
}

bool check(int x) {
    for (int i = 1; i <= n; i++) {
        if (f(i, 1, x) < a[i]) return false;
        int l = 1, r = n;
        while (l <= r) {
            int mid = (l + r) >> 1;
            if (f(i, mid, x) >= a[i]) l = mid + 1, t[i] = mid;
            else r = mid - 1;
        }
    }
    fill(tag + 1, tag + n + 1, 0);
    vector<int> vec(n); iota(vec.begin(), vec.end(), 1);
    sort(vec.begin(), vec.end(), [](int x, int y) -> bool {
        return t[x] < t[y];
    });
    int cur = 0;
    for (int i : vec) {
        if (tag[i]) continue;
        stack<int> st;
        for (int j = i; j != -1 && !tag[j]; j = fa[j]) st.emplace(j);
        while (!st.empty()) {
            int u = st.top(); st.pop();
            if (++cur > t[u]) return false;
            tag[u] = true;
        }
    } return true;
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i] >> b[i] >> c[i];
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    fa[1] = -1, dfs(1); 
    int l = 0, r = 1e9, res = -1;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (check(mid)) res = mid, r = mid - 1;
        else l = mid + 1;
    } cout << res;
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
