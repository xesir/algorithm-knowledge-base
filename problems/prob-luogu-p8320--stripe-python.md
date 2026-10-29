---
id: prob-luogu-p8320
title: '『JROI-4』Sunset'
oj: '洛谷'
problemId: 'P8320'
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

暂无（原题：[P8320](https://www.luogu.com.cn/problem/P8320)）。

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
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以向交互库提出如下两种询问：
>
> 1. 给出 $k$，记 $p_i$ 的**当前**前缀 $\max$ 数组为 $m_i$，求 $m$ 前缀 $[1,k]$ 中的颜色数。
> 2. 给出 $k$，令 $p_k \gets 0$。
>
> 还原这个排列。
>
> $n \le 500$，满分询问次数 $\le 5500$，交互库非自适应。

:::::success[题解]
思考题目给出的操作，考虑到二操作不可逆，因此其意义仅仅是确定 $k$ 位置上的数字后，清除其影响。

注意到询问次数接近 $n \log n$，考虑依次用二分确定每一个数字。

接下来考虑前缀 $\max$ 颜色数的性质。我们发现：当前缀 $\max$ 越过最大值后，颜色数始终不会改变。

基于此，考虑猜数模型，二分出当前 $\max$ 的位置，然后将这个位置清零，再继续进行询问。

询问次数为 $n \log n$ 级别。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 505;
int n, a[N];
int ask(int x) {
    cout << "? 1 " << x << endl;
    int u; cin >> u;
    return u;
}
void reset(int x) {cout << "? 2 " << x << endl;}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
}

void _main() {
    cin >> n;
    for (int k = 1, v = n; k <= n; k++, v--){
        int mx = ask(n), l = 1, r = n, p = -1;
        while (l <= r) {
            int mid = (l + r) >> 1;
            if (ask(mid) == mx) r = mid - 1, p = mid;
            else l = mid + 1;
        }
        a[p] = v, reset(p);
    } answer();
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
