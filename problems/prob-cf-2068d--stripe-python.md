---
id: prob-cf-2068d
title: 'Morse Code'
oj: 'Codeforces'
problemId: 'CF2068D'
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

暂无（原题：[CF2068D](https://www.luogu.com.cn/problem/CF2068D)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n$ 个实数 $f_i$。你需要为每个 $i$ 分配一个字符串 $s_i$，使得不存在 $i \ne j$ 满足 $s_i$ 是 $s_j$ 的前缀。字符集为 $\{\tt{.},\tt{-}\}$。其中 $\tt{.}$ 的代价为 $1$，$\tt{-}$ 的代价为 $2$，字符串的代价为其中字符代价之和。
>
> 设 $s_i$ 的代价为 $c_i$，最小化 $\sum\limits_{i=1}^n f_ic_i$，构造方案并输出。
>
> $n \le 200$，$0<f_i<1 \land \sum\limits_{i=1}^n f_i=1$，2 秒，1000 MB。

:::::success[题解]
你说的对，但 $O(n^4)$ 过了。

下面称 $\tt{.}$ 为 $\tt{0}$，$\tt{-}$ 为 $\tt{1}$，则需要构造若干 01 串。考虑建立 01-Trie，向左儿子走的代价为 $1$，向右儿子走的代价为 $2$。记节点 $u$ 到根节点的距离为 $d_u$，问题转化为在 01-Trie 上选择若干无祖先—后代关系的点，最小化 $\sum f_u d_u$。

我们肯定不能显式建立 01-Trie。因此考虑直接搜索，逐层构建 01-Trie。接下来有一个观察：$f_i$ 越大的节点，其在 trie 上的深度越浅。证明考虑排序不等式。

因此，按 $f_i$ 降序排序，每次在当前层分配 $i$ 个节点时直接选择最大的 $i$ 个点即可。

用四元组 $(\text{k},\text{cur},\text{nxt},\text{dep})$ 作为搜索状态，表示当前还有 $\text{k}$ 个位置没有分配，当前层可以操作 $\text{cur}$ 个点，下一层可以操作 $\text{nxt}$ 个点，当前深度为 $\text{dep}$。

状态数是 $O(n^4)$ 的。事实上，我们可以使用贡献提前计算的 trick：当 trie 向下推进一层时，所有尚未分配的字符，最终的编码长度都至少增加了 $1$。对 $f$ 做一个后缀和，然后可以直接计算这一部分的代价，没有必要记录 $\text{dep}$ 了。

对于三元组 $(\text{k},\text{cur},\text{nxt})$，我们枚举当前层有 $i$ 个节点继续向下进行转移。如果搜索有环，则绕环一定不优，可以剪枝。并且将答案记忆化，到达已经搜索过的点直接返回。

这里状态数为 $O(n^3)$，转移带 $O(n)$，总体复杂度 $O(n^4)$。构造方案时，对于每个三元组 $(\text{k},\text{cur},\text{nxt})$ 记录最优决策点 $i$，然后推回去即可。

:::::

:::::info[代码]
```cpp line-numbers
const int N = 255;
const double inf = 1e18;
using node = pair<double, int>;

int n; node a[N];
double suf[N];
string ans[N];

int vis[N][N][N], opt[N][N][N];
double mem[N][N][N];
double dfs(int k, int cur, int nxt) {
    if (k == n) return 0;
    if (cur == 0 && nxt == 0) return inf;
    if (vis[k][cur][nxt] == 1) return inf;
    if (vis[k][cur][nxt] == 2) return mem[k][cur][nxt];
    vis[k][cur][nxt] = 1;
    double res = inf; int p = -1;
    for (int i = 0; i <= min(n - k, cur); i++) {
        int nk = k + cur - i;
        double cost = suf[nk + 1] + dfs(nk, min(nxt + i, n - nk), min(i, n - nk));
        if (cost < res) res = cost, p = i;
    }
    vis[k][cur][nxt] = 2;
    return opt[k][cur][nxt] = p, mem[k][cur][nxt] = res;
}
void work() {
    vector<string> cur = {""}, nxt;
    for (int k = 0; k < n; ) {
        int i = opt[k][min<int>(cur.size(), n - k)][min<int>(nxt.size(), n - k)];
        vector<string> nnxt;
        for (int j = 0; j < i; j++) {
            nxt.emplace_back(cur[j] + '.');
            nnxt.emplace_back(cur[j] + '-');
        }
        int cnt = min<int>(cur.size(), n - k) - i;
        for (int j = 0; j < cnt; j++) {
            ans[a[k + j + 1].second] = cur[i + j];
        }
        k += cnt, cur.swap(nxt), nxt.swap(nnxt);
    }
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i].first, a[i].second = i;
    sort(a + 1, a + n + 1, greater<node>());
    for (int i = n; i >= 1; i--) suf[i] = suf[i + 1] + a[i].first;
    dfs(0, 1, 0), work();
    for (int i = 1; i <= n; i++) cout << ans[i] << '\n';
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
