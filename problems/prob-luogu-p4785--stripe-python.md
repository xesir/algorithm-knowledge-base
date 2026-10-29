---
id: prob-luogu-p4785
title: '[BalticOI 2016] 交换 (Day2)'
oj: '洛谷'
problemId: 'P4785'
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

暂无（原题：[P4785](https://www.luogu.com.cn/problem/P4785)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一个长为 $n$ 的排列 $a_i$。有 $n-1$ 轮操作，第 $k$ 次操作可以交换 $a_k$ 和 $a_{\lfloor k/2\rfloor}$。你需要最小化最终排列的字典序并输出。
>
> $n \le 2 \times 10^5$，1 秒，250 MB。

:::::success[题解]
思维自然且很有启发性的好题，点赞！

题目中 $i \to \lfloor i/2 \rfloor$ 的交换方式让我们联想到完全二叉树的堆式存储：将 $\lfloor i/2 \rfloor$ 视为 $i$ 的父亲，$i$ 的左右儿子为 $2i,2i+1$。

对原排列建立完全二叉树，根节点为 $1$，则题目转化为最小化层序遍历字典序。

我们按前序遍历的顺序依次考虑每个节点 $i$，则其最终值有三种可能：$x=a_i,y=a_{2i},z=a_{2i+1}$。贪心地，我们先让 $i$ 处的值最小，字典序一定更优。

- 若 $x$ 是最小值，不做交换，左右子树分别递归求解；
- 若 $y$ 是最小值，交换 $x \to y$，然后左右子树递归求解；
- 若 $z$ 是最小值，交换 $x \to z$ 或者依次交换 $x \to y, y \to z$ 都可行。左右子树有 $x,y$ 和 $y,x$ 两种可能。

这里需要说明一下，直接将较小值作为左子树根是错误的，因为较小值可能在左子树中被替换。

我们将一个值沉入一棵子树，其必然经历若干次替换后停止在某个位置。这个位置可以通过模拟上述流程算出。

设 $f(u,x)$ 为值 $x$ 沉入 $u$ 子树后的最终位置。在节点 $i$ 处，假定 $z$ 是最小值，不妨设 $x<y$
，则我们计算出 $f(2i,x)$ 和 $f(2i+1,x)$，然后将 $x$ 沉入较小的一边即可。

对于 $f(u,x)$ 的求解，可以模拟上述递归流程，其会在 $z$ 成为最小值时产生 $3$ 个分支，由递归式 $T(n)=3T(n/2)+O(1)$ 解得复杂度 $O(n^{\log_2 3}) \approx O(n^{1.585})$。加上递归求解，总复杂度为 $O(n^{1.585} \log n)$，可以卡过。

我们注意到 $x$ 一定来源于 $u$ 的祖先节点，这只会有 $O(\log n)$ 个，所以可以对 $(u,x)$ 二元组记忆化。根据记搜实现方式，复杂度为 $O(n \log^2 n) \sim O(n \log n)$。由于哈希表常数太大，使用 map 实现多一只 log 但跑的更快。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 2e5 + 5;
int n, a[N], ans[N];

umap<int, int> mem[N];
int f(int u, int val) {
    int ls = u << 1, rs = u << 1 | 1;
    if (ls > n) return u;
    if (rs > n) return val < a[ls] ? u : f(ls, val);
    if (mem[u].find(val) != mem[u].end()) return mem[u][val];
    int m = min({val, a[ls], a[rs]});
    if (m == val) return mem[u][val] = u;
    if (m == a[ls]) return mem[u][val] = f(ls, val);
    if (val < a[ls]) return mem[u][val] = min(f(ls, val), f(rs, val));
    return mem[u][val] = f(ls, a[ls]) < f(rs, a[ls]) ? f(rs, val) : f(ls, val);
}
void solve(int u, int val) {
    int ls = u << 1, rs = u << 1 | 1;
    if (ls > n) return ans[u] = val, void();
    if (rs > n) {
        int v = a[ls];
        if (v < val) swap(v, val);
        return ans[u] = val, solve(ls, v), void();
    }
    int m = min({val, a[ls], a[rs]});
    if (m == val) {
        ans[u] = val, solve(ls, a[ls]), solve(rs, a[rs]);
    } else if (m == a[ls]) {
        ans[u] = a[ls], solve(ls, val), solve(rs, a[rs]); 
    } else {
        ans[u] = a[rs];
        int x = val, y = a[ls];
        if (x > y) swap(x, y);
        if (f(ls, x) < f(rs, x)) solve(ls, x), solve(rs, y);
        else solve(ls, y), solve(rs, x);
    }
} 

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i];
    a[n + 1] = 1e9, solve(1, a[1]);
    for (int i = 1; i <= n; i++) cout << ans[i] << ' ';
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
