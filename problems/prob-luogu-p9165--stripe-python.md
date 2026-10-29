---
id: prob-luogu-p9165
title: '「INOH」Round 1 - 意外'
oj: '洛谷'
problemId: 'P9165'
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

暂无（原题：[P9165](https://www.luogu.com.cn/problem/P9165)）。

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
> - A：已知一个长为 $100$ 的数组 $a_i$，需要传递一个数组 $b_i$。
> - B：已知 $b_i$，还原原本的 $a_i$。
>
> 在通信过程中，每个数字有 $50\%$ 的概率被交互库替换为为无效值。
>
> 满分要求 $b_i$ 的长度 $\le 750$。

:::::success[题解]
考虑如下加密方式：构造序列 $a_i$ 的 GF

$$
f(x)=\sum_{i=0}^{99} a_i x^i
$$

传输若干 $f(x)$。当 B 收到 $f(x)$ 后通过 Lagrange 插值即可得到 $f(x)$ 的系数表示，从而还原 $a_i$。

取 $x=0,1,\cdots,149$ 并将每个 $f(x)$ 复制 $5$ 次传输，当 B 收到后，如果某个位置出现超过两次，则认为这是正确值。并且 B 只需要 $100$ 个点值就能插值，故正确率极高。 
:::::

:::::info[代码]

```cpp line-numbers
const int N = 105;

vector<int> Encode(vector<int> vec) {
    vector<int> a(750);
    for (int x = 0; x < 150; x++) {
        mint xp = 1, y = 0;
        for (int i = 0; i < 100; i++, xp *= x) y += vec[i] * xp;
		for (int i = 0; i < 5; i++) a[x + 150 * i] = y.val;
    } 
	return a;
}

mint x[N], y[N], f[N], m[N], px[N];
vector<int> Decode(vector<int> vec) {
	memset(f, 0, sizeof(f)), memset(m, 0, sizeof(m)), memset(px, 0, sizeof(px));
    int n = 0;
    for (int i = 0; i < 150; i++) {
		map<int, int> mp;
		for (int j = 0; j < 5; j++) mp[vec[i + 150 * j]]++;
		for (auto [k, v] : mp) 
			if (v >= 2) {
				x[n] = i, y[n] = k, n++; 
				break;
			}
		if (n >= 100) break;
	}
    m[0] = 1;
    for (int i = 0; i < n; i++) {
        for (int j = i; j >= 0; j--) m[j + 1] += m[j], m[j] *= -x[i];
    }
    for (int i = 0; i < n; i++) {
		px[i] = 1;
		for (int j = 0; j < n; j++) {
			if (i != j) px[i] *= x[i] - x[j];
		}
	}
	for (int i = 0; i < n; i++) {
		mint t = y[i] / px[i], k = m[n];
		for (int j = n - 1; j >= 0; j--) f[j] += k * t, k = k * x[i] + m[j];
	}
    vector<int> res(100);
    for (int i = 0; i < 100; i++) res[i] = f[i].val;
    return res;
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
