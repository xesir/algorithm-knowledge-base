---
id: prob-luogu-p4260
title: '[Code+#3] 博弈论与概率统计'
oj: '洛谷'
problemId: 'P4260'
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

暂无（原题：[P4260](https://www.luogu.com.cn/problem/P4260)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有两个变量 $a,b$，初始 $a=b=0$。进行 $n+m$ 轮操作，一轮操作中：
>
> - 令 $a \gets a+1, b \gets \max(0,b-1)$。概率为 $p$。
> - 令 $a \gets \max(0,a-1), b \gets b+1$。概率为 $1-p$。
>
> 且第一类操作恰好发生 $n$ 次。求 $a$ 的期望。
>
> 进行 $q$ 次询问，每轮询问均给出 $n,m,p$ 并输出答案。
>
> $q,n+m \le 2.5 \times 10^5$，1 秒，125 MB。

::::::success[题解]

容易发现 $p$ 是搞笑的，求出 $\sum a$ 后除以 $\binom{n+m}{n}$ 即为所求。

设第一类操作进行 $x$ 次，第二类操作进行 $y$ 次。忽略与 $0$ 取 $\max$ 的限制，则 $a=x-y$。

设全过程 $a=0$ 时 $-1$ 共进行 $k$ 次，最终 $a=n+k-m$。只要算出 $k$ 对应的方案数即可。

做一个单步容斥，即 $[x=k]=[x \le k]-[x \le k-1]$。根据分析，至多 $k$ 次的充要条件为，任意时刻 $y-x \le k$。

将 $(x,y)$ 拍到二维平面上，问题转化为从 $(0,0)$ 走到 $(n,m)$，不越过 $y=x+k$ 的格路数目。由单线反射容斥，将终点关于 $y=x+k+1$ 做对称可得
$$
\binom{n+m}{n}-\binom{n+m}{m-k-1}
$$
至少转恰好是作差，则 $\text{ans}_k=\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}$。求和即为答案。

- 若 $n \ge m$，那么

  $$
  \begin{aligned}
  \text{ans}&=\sum_{k=0}^m (n+k-m) \left(\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}\right)\\
  &=\sum_{i=0}^m (n-i) \left(\dbinom{n+m}{i}-\dbinom{n+m}{i-1}\right)\\
  &=\sum_{i=0}^m (n-i) \dbinom{n+m}{i}-\sum_{i=0}^{m-1} (n-i-1)\dbinom{n+m}{i}\\
  &=\boxed{\sum_{i=0}^{m-1} \binom{n+m}{i}+(n-m) \binom{n+m}{m}}
  \end{aligned}
  $$

  第二步为换元 $i=m-k$，第三步后面的和式 $i \gets i-1$，第四步为对位相减。

- 若 $n \le m$，同理化简得
  $$
  \begin{aligned}
  \text{ans}&=\sum_{k=m-n}^{m} (n+k-m) \left(\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}\right)\\
  &=\boxed{\sum_{i=0}^{n-1} \binom{n+m}{i}}
  \end{aligned}
  $$

问题转化为 $q$ 次询问组合数下指标前缀和，莫队解决即可，复杂度 $O(n\sqrt{q})$。

:::::info[组合数下指标前缀和]

模板题：[AT_tenka1_2014_final_d 高橋君](https://www.luogu.com.cn/problem/AT_tenka1_2014_final_d)。

> 进行 $q$ 次询问，给定 $n,m$，求
> $$
> f(n,m)=\left(\sum_{i=0}^m \binom{n}{i}\right) \bmod (10^9+7)
> $$
> $q \le 10^5$，$0 \le n,m \le 10^5$，6 秒，256 MB。

考察莫队思想，只要 $n,m$ 移动后 $f(n,m)$ 可以由原本的值 $O(1)$ 递推得到。事实上：

- $f(n,m+1)=f(n,m)+\dbinom{n}{m+1}$。
- $f(n,m-1)=f(n,m)-\dbinom{n}{m}$。
- $f(n+1,m)=2f(n,m)-\dbinom{n}{m}$。
- $f(n-1,m)=\dfrac{f(n,m)+\binom{n-1}{m}}{2}$。

前两条转移显然，后两条由组合数递推式裂项可得。

利用莫队构造，我们可以在 $O(n \sqrt{q})$ 的复杂度内**离线**解决组合数下指标前缀和的问题。

事实上这个问题也存在 $O(q+m \log^2 m)$ 的离线解法，参见 <https://www.luogu.com.cn/article/xypg20ht>。

:::::

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
