---
id: prob-qoj-5309
title: 'Guess Cycle Length'
oj: 'QOJ'
problemId: 'QOJ5309'
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

暂无（原题：[QOJ5309](https://qoj.ac/problem/5309)）。

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
> 交互库隐藏了一个大小为 $n$ 的环，环上节点的编号是一个 $1 \sim n$ 的排列。你初始位于某个点，每次询问给出一个非负整数 $x$，向后走 $x$ 步并从交互库得知当前节点编号。
>
> 还原环的大小，即找出 $n$。
>
> $n \le 10^9$，满分询问次数 $\le 10^4$，交互库非自适应。

:::::success[题解]
注意到如果从起点走 $x,y$ 步后节点编号相同，则 $n \mid (x-y)$。

考虑 BSGS。设置一个阈值 $B$，先向后跳 $1,2,\cdots,B$ 步，并将步数和节点编号对应插入一个哈希表。再跳 $B,2B,\cdots,B^2$ 步。若 $n \le B$ 则可以直接在第一轮得到答案，否则找到哈希表中第一个出现的数可以计算出答案。

上述做法是确定性的，$B=\sqrt{n}$ 最优，此时询问次数约 $2 \times \sqrt{10^9} \approx 6 \times 10^4$，无法通过。

结论：$k$ 个 $[1,n]$ 内的随机变量，最大值的期望为 $\frac{k}{k+1}n$。

我们随机进行以下流程若干轮：从 $[1,10^9]$ 中随机一个正整数 $x$，并记录走 $x$ 步后的节点标号。由于交互库非自适应，我们找出编号的 $\max$ 记为 $m$，则用 $m$ 来估计 $n$ 的数量级。

这样 $m \to n$ 的距离大大缩小了，考虑在这段距离上 BSGS。跑完 Baby Step 后，可以从起点开始，找到最接近 $m$ 的 $B$ 的倍数 $kB$，然后从 $kB$ 开始重复 Giant Step。

经过简单调参即可通过，注意一些细节。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
const int N = 1e9, B = 2000;
int walk(int x) {
    cout << "walk " << x << endl;
    int a; cin >> a;
    return a;
}
void guess(int x) {
    cout << "guess " << x << endl;
    exit(0);
}

void _main() {
    int m = 0;
    for (int i = 1; i <= 3000; i++) chkmax(m, walk(rand32() % N + 1));
    umap<int, int> mp;
    int x = -1;
    for (int i = 1; i <= B; i++) {
        x = walk(1), chkmax(m, x);
        if (mp.find(x) != mp.end()) guess(i - mp[x]);
        mp[x] = i;
    }
    int d = max(B, m / B * B);
    if (d > B) x = walk(d - B);
    while (true) {
        if (mp.find(x) != mp.end() && d > mp[x]) guess(d - mp[x]);
        x = walk(B), d += B;
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
