---
id: prob-cf-1438f
title: 'Olha and Igor'
oj: 'Codeforces'
problemId: 'CF1438F'
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

暂无（原题：[CF1438F](https://www.luogu.com.cn/problem/CF1438F)）。

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
> 交互库隐藏了一棵高为 $h$ 的满二叉树，节点有标号且隐藏。一次询问给出 $u,v,w$，询问以 $w$ 为根时 $u,v$ 两点的 LCA 标号。
>
> 还原根节点的标号。
>
> $3 \le h \le 18$，满分询问次数 $\le 2^h+419$，4 秒，250 MB。

:::::success[题解]

考虑随机 $u,v,w$ 并分析每个点作为 LCA 的概率。

对于点 $x$，当且仅当 $u,v,w$ 分居 $x$ 的三棵子树时，$x$ 会被作为回答。粗略估计一下，忽略常数以后的概率是
$$
p_x=\dfrac{(2^{h-d})^2 (2^h-2^{h-d})}{(2^h)^3}
$$
其中 $d$ 是节点 $x$ 的深度，定义域 $d \in [2,h)$。将上式展开
$$
\begin{aligned}
p_x&=\dfrac{(2^{h-d})^2 (2^h-2^{h-d})}{(2^h)^3}\\
&= \dfrac{2^{4h-3d}}{2^{3h}}
\end{aligned}
$$
可以发现 $p_x$ 关于 $d$ 单调减，且下降速度很快。

考虑用 $420$ 次询问随机 $u,v,w$，并取出最大和次大，这两个点有极大概率是根的左右儿子。确定左右儿子以后是简单的，枚举每个点，以一个儿子定根去询问即可。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e5 + 5;
int ask(int u, int v, int w) {
    cout << "? " << u << ' ' << v << ' ' << w << endl;
    int x; cin >> x;
    return x;
}
void answer(int x) {
    cout << "! " << x << endl;
    exit(0);
}
int h, n, cnt[N], p[N];

void _main() {
    cin >> h; n = (1 << h) - 1;
    for (int T = 420; T--; ) {
        int u, v, w;
        do u = rand32() % n + 1, v = rand32() % n + 1, w = rand32() % n + 1;
        while (u == v || u == w || v == w);
        cnt[ask(u, v, w)]++;
    }
    iota(p + 1, p + n + 1, 1);
    sort(p + 1, p + n + 1, [](int u, int v) -> bool {
        return cnt[u] > cnt[v];
    });
    int x = p[1], y = p[2];
    for (int i = 1; i <= n; i++) {
        if (i == x || i == y) continue;
        if (ask(y, i, x) == i) answer(i);
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
