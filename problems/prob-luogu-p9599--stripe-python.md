---
id: prob-luogu-p9599
title: '[JOI Open 2018] 木琴 / Xylophone'
oj: '洛谷'
problemId: 'P9599'
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

暂无（原题：[P9599](https://www.luogu.com.cn/problem/P9599)）。

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
> 交互库隐藏了一个 $1\sim n$ 的排列 $a_i$。保证 $1$ 所在位置小于 $n$ 所在位置。你可以向交互库询问区间极差。
>
> 还原这个排列。
>
> $n \le 5 \times 10^3$，满分询问次数 $10^4$。

:::::success[题解]

询问 $(i,i+1)$ 可以得到差分数组 $|d_i|=|a_i-a_{i-1}|$。

询问 $(i-1,i,i+1)$ 得到 $k$ 分讨：

- 若 $a_{i-1} <a_i<a_{i+1}$，则 $k=a_{i+1}-a_{i-1}$。    
  注意到 $d_{i+1}+d_i=k$ 且 $d_{i+1} >0 \land d_i >0$。
- 若 $a_{i-1}>a_i>a_{i+1}$，则 $k=a_{i-1}-a_{i+1}$。    
  注意到 $-d_{i+1}-d_i=k$ 且 $d_{i+1} < 0 \land d_i < 0$。
- 若 $a_{i-1}<a_i>a_{i+1}$，则 $d_i > 0 \land d_{i+1}<0$。
  - 若 $a_{i-1}<a_{i+1}$，则 $k=a_i-a_{i-1}=d_i$。
  - 若 $a_{i+1}<a_{i-1}$，则 $k=a_i-a_{i+1}=-d_{i+1}$。
- 若 $a_{i-1}>a_i<a_{i+1}$，则 $d_i< 0 \land d_{i+1}>0$。
  - 若 $a_{i-1}>a_{i+1}$，则 $k=a_{i-1}-a_i=-d_i$。
  - 若 $a_{i+1}>a_{i-1}$，则 $k=a_{i+1}-a_i=d_{i+1}$。

综上所述，当且仅当 $k=|d_i|+|d_{i+1}|$ 时 $d_id_{i+1}>0$。

钦定 $a_1=C \land d_2=\pm |d_2|$ 递推出 $a_1 \sim a_n$，则最小值对应 $1$，进而排列得以还原。在两种情况中取 $\text{pos}(1)<\text{pos}(n)$ 的那种即可。

询问次数 $2n-3$。

:::::

:::::info[代码]
```cpp line-numbers
#define ask query
int d[N], f[N], a[N];
void solve(int N) {
    for (int i = 2; i <= N; i++) d[i] = ask(i-1, i);
    for (int i = 2; i < N; i++) 
        f[i] = (ask(i-1, i+1) == d[i] + d[i+1]);
    for (int i = 2; i < N; i++) {
        if (f[i]) d[i+1] = d[i] > 0 ? d[i+1] : -d[i+1];
        else d[i+1] = d[i] > 0 ? -d[i+1] : d[i+1];
    }
    for (int i = 2; i <= N; i++) a[i] = a[i-1] + d[i];
    int p = min_element(a + 1, a + N + 1) - a;
    for (int i = 1; i <= p; i++) a[i] += 1 - a[p];
    for (int i = p+1; i <= N; i++) a[i] = a[i-1] + d[i];
    int x1 = find(a + 1, a + N + 1, 1) - a;
    int xn = find(a + 1, a + N + 1, N) - a;
    if (x1 > xn)  
        for (int i = 1; i <= N; i++) a[i] = N - a[i] + 1;
    for (int i = 1; i <= N; i++) answer(i, a[i]);
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
