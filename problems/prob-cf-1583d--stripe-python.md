---
id: prob-cf-1583d
title: 'Omkar and the Meaning of Life'
oj: 'Codeforces'
problemId: 'CF1583D'
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

暂无（原题：[CF1583D](https://www.luogu.com.cn/problem/CF1583D)）。

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
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以给出数组 $a_1,a_2,\cdots,a_n$，满足 $a_i \in [1,n]$。交互库得到数组 $b_i=a_i+p_i$，然后找到最小的 $k$ 满足 $b_k$ 在 $b$ 中出现一次，并将 $k$ 返回你的程序，若不存在返回 $0$。
>
> 还原这个排列。
>
> $n \le 100$，满分询问次数 $2n$。

:::::success[题解：$2n-2$ 次询问]
由于次数是 $2n$，我们考虑先用 $n$ 次询问确定一个位置，然后再递推确定剩余位置。

假设我们要确定位置 $i$，则令 $a_i \gets n$，交互库即得到 $b_i=p_i+n$。我们枚举 $v \in [1,n)$，并令 $a_j \gets v, j \ne i$，那么交互库得到 $b_j=p_i+v$。

- 若 $p_i \ne n$，那么如果我们猜中了 $p_i=v$，排列必然有一个位置满足 $p_j=n$，所以在枚举到这个 $v$ 时就得到答案。
- 若 $p_i=n$，则将所有 $v$ 问完都没有答案。

因为交互库返回的是 $k_{\min}$，我们应该先确定 $p_n$，否则后面的情况无法确定。

我们考虑确定 $v$ 的位置，那么只需令 $a$ 形如 $[n+1-v,n+1-v,\cdots,n+1-v,n+1-p_i]$，询问结果就是 $v$ 的下标，读者自证不难。

稍微卡一下无效询问，询问次数不超过 $2n-2$。

:::::

::::info[代码]

```cpp line-numbers
const int N = 105;
int n, a[N], p[N];
int ask() {
    cout << "? ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
    int x; return cin >> x, x;
}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << p[i] << ' ';
    cout << endl, exit(0);
}

void _main() {
    cin >> n, p[n] = n;
    for (int v = 1; v < n; v++) {
        fill(a + 1, a + n, v), a[n] = n;
        int x = ask();
        if (x != 0) {p[n] = v; break;}
    }
    for (int v = 1; v <= n; v++) {
        if (p[n] == v) continue;
        fill(a + 1, a + n, n + 1 - v), a[n] = n + 1 - p[n];
        int x = ask(); p[x] = v;
    }
    answer();
} 
```

::::

::::::success[题解：$n$ 次询问]
我们考虑在第一阶段直接求出 $\ge p_n$ 的所有数。这里我们换一个更好的构造方式：令 $a=[1,1,\cdots,1+v]$。

- 对于 $i<n$，有 $b_i=p_i+1$。
- 对于 $i=n$，有 $b_n=p_n+v+1$。

如果交互库返回的 $k \ne 0$，可得 $p_k+1=p_n+v+1$，得 $p_k=p_n+v$。反之我们有 $p_n=n-v+1$。

完成第一阶段后，我们求出 $<p_n$ 的所有元素。仍然枚举 $v$ 并确定其位置，令 $a=[1+v,1+v,\cdots,1+v,1]$ 即可，得到一个 $k$。同理得 $p_k=p_n-v$。

询问次数严格 $n$ 次。
::::::

::::info[代码]

```cpp line-numbers
const int N = 105;
int n, a[N], p[N];
int ask() {
    cout << "? ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
    int x; return cin >> x, x;
}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << p[i] << ' ';
    cout << endl, exit(0);
}

void _main() {
    cin >> n, p[n] = 1;
    for (int v = 1; v < n; v++) {
        fill(a + 1, a + n, 1), a[n] = 1 + v;
        int k = ask();
        if (k == 0) {
            p[n] = n - v + 1;
            break;
        } 
        p[k] = v;
    }
    for (int i = 1; i < n; i++) {
        if (p[i] > 0) p[i] += p[n];
    } 
    for (int v = 1; v < p[n]; v++) {
        fill(a + 1, a + n, 1 + v), a[n] = 1;
        int k = ask(); p[k] = p[n] - v;
    }
    answer();
} 
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
