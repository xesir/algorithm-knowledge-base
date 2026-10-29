---
id: prob-luogu-p10243
title: '[THUSC 2021] 种树'
oj: '洛谷'
problemId: 'P10243'
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

暂无（原题：[P10243](https://www.luogu.com.cn/problem/P10243)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一棵 $n$ 个点的无标号树，需要传递一个二进制串。
> - B：已知这个二进制串，需要还原这棵树。
>
> $n \le 70$，满分要求 bit 数 $\le 128$。

:::::success[题解]
括号序和树的形态之间形成了双射，故考虑求出括号序。但是直接做需要 $2n-2$ 个 bit，无法通过。

继续压缩信息，发现括号序的问题是不合法序列也会被算入。我们可以用合法括号序的字典序来记录一个括号序列，求字典序和从字典序还原都是[经典问题](https://oi-wiki.org/topic/bracket/#%E5%AD%97%E5%85%B8%E5%BA%8F%E8%AE%A1%E7%AE%97)。由于 $H_{n-1} \le 2^{128}$ 可以通过。

于是做完了，复杂度 $O(n^2)$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 150;
u128 f[N][N];
bool init;
void work() {
    if (init) return;
    f[0][0] = 1;
    for (int i = 1; i <= 140; i++) {
        f[i][0] = f[i - 1][1];
        for (int j = 1; j <= i; j++) 
            f[i][j] = f[i - 1][j - 1] + f[i - 1][j + 1];
    }
    init = true;
}

u128 encoder(int n, const int* p) {
    vector<vector<int>> e(n + 5);
    for (int i = 2; i <= n; i++) e[p[i]].emplace_back(i);
    string s;
    function<void(int)> dfs = [&](int u) -> void {
        for (int v : e[u]) s += '(', dfs(v), s += ')';
    };
    dfs(1), work();
    u128 rnk = 0;
    for (int i = 0, pre = 0; i < (int)s.size(); i++) {
        int j = (int)s.size() - i - 1;
        if (s[i] == '(') pre++;
        else rnk += f[j][pre + 1], pre--;
    }
    return rnk;
}
void decoder(int n, u128 M, int* p) {
    work();
    u128 rnk = M;
    string s;
    for (int i = 0, pre = 0; i < 2 * (n - 1); i++) {
        int j = 2 * (n - 1) - i - 1;
        u128 v = f[j][pre + 1];
        if (rnk < v) s += '(', pre++;
        else s += ')', pre--, rnk -= v;
    }
    int u = 1, v = 2;
    stack<int> st; st.emplace(1);
    p[1] = 0;
    for (char c : s) {
        if (c == '(') p[v] = u, st.emplace(v), u = v++;
        else st.pop(), u = st.top();
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
