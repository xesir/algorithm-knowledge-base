---
id: prob-luogu-p16958
title: '[SCCPC 2026] 括号序列'
oj: '洛谷'
problemId: 'P16958'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 数学
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

暂无（原题：[P16958](https://www.luogu.com.cn/problem/P16958)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定合法括号串 $S$，求有多少合法括号串 $T$ 满足 $|T| \le |S|$ 且 $T$ 的字典序不大于 $S$。
>
> 多测，$\sum |S| \le 10^6$，2 秒，1024 MB。

:::::success[题解]

我们将括号串转化成格路。将左括号视作 $x \gets x+1$，右括号视作 $y \gets y+1$，则长为 $2n$ 的合法括号串双射到 $(0,0) \to (n,n)$ 的不跨越 $y=x$ 的格路。

特判 $T$ 是 $S$ 前缀的情形后，枚举并钦定 LCP。具体地，我们枚举 $S$ 的第 $i$ 位，在格路上钦定这样一个结构：

![](https://cdn.luogu.com.cn/upload/image_hosting/8q4ivnal.png)

在 LCP 之后 $T$ 不受字典序限制，枚举 $|T|=m$，则 $T$ 对应 $(x+1,y) \to (m,m)$ 的格路。由单线反射容斥，将终点关于 $y=x+1$ 作对称可得
$$
\binom{m-(x+1)+m-y}{m-y}-\binom{m-1-(x-1)+m+1-y}{m+1-y}
$$
转而枚举 $m-y=k$，整理得到 $(x,y)$ 处的贡献为
$$
\boxed{\sum_{k=0}^{n-y} \left(\binom{2k+y-x-1}{k}-\binom{2k+y-x-1}{k+1}\right)}
$$
我们记
$$
f(a,b)=\sum_{k=0}^b \binom{2k+a}{k}
$$
则 $(x,y)$ 处的贡献可以写作 $f(y-x-1,n-y)-f(y-x-3,n-y+1)$。

瓶颈在于 $f$ 的计算，暴力可以得到 $O(n^2)$ 做法。注意到 $f$ 的形式是一堆组合数加和，类比组合数下指标前缀和的莫队做法，我们考虑 $a,b$ 移动对 $f$ 的影响。$b$ 的移动是简单的：
$$
\begin{aligned}
f(a,b+1)&=f(a,b)+\binom{2(b+1)+2}{b+1}\\
f(a,b-1)&=f(a,b)-\binom{2b+a}{b}
\end{aligned}
$$
我们需要观察 $a \gets a\pm 1$ 的影响。可以对 $a \in [-8,-1], b\in [0,8]$ 进行打表：

```plain
0       0       0       0       0       0       0       0       1
0       0       0       0       0       0       0       1       10
0       0       0       0       0       0       1       9       54
0       0       0       0       0       1       8       44      209
0       0       0       0       1       7       35      155     650
0       0       0       1       6       27      111     441     1728
0       0       1       5       20      76      286     1078    4081
0       1       4       14      49      175     637     2353    8788
```

注意到以下等式成立：$441+637=1078$，$1278+2353=4081$，对其他位置验证也满足规律，猜测有
$$
f(a,b)=f(a-1,b)+f(a+1,b-1)
$$
而 $f(a+1,b-1) \to f(a+1,b)$ 是容易的。从而
$$
\boxed{\begin{aligned}
f(a,b)&=f(a-1,b)+f(a+1,b)-\binom{2b+a+1}{b}\\
f(a-1,b)&= f(a+1,b)-f(a,b)+\binom{2b+a+1}{b}
\end{aligned}}
$$
维护 $f(a,b)$ 和 $f(a+1,b)$ 后可以递推 $f(a-1,b)$，从而 $a \gets a-1$ 解决。对 $a \gets a+1$ 可以逆用上式同理求得。

注意到 $S$ 的枚举过程中，只有 $x \gets x+1$ 和 $y \gets y+1$ 两种操作，对应的移动是 $b \gets b- 1$ 和 $a \gets a\pm 1$，且指针移动总次数 $O(n)$。故直接维护两个 $f$ 值的复杂度就是线性。

复杂度 $O(n)$。[代码](https://qoj.ac/submission/2887256)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
