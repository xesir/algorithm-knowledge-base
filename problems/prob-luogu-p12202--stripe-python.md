---
id: prob-luogu-p12202
title: '[COI 2022] 回文子串 / Madioničar'
oj: '洛谷'
problemId: 'P12202'
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

暂无（原题：[P12202](https://www.luogu.com.cn/problem/P12202)）。

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
> 交互库隐藏了一个字符串 $S$，长为 $n$。你可以向交互库询问一个子串是否回文。
>
> 找出最长回文子串长度。
>
> $n \le 10^5$，满分询问次数 $2n$，交互库非自适应。

:::::success[题解]

$n \log n$ 显然，枚举回文中心然后二分长度即可。

Manacher 似乎可以做到 $4n$，但并没有什么启示。

我们考虑优化 $n \log n$ 的暴力：考虑最优性剪枝，记当前答案为 $x$，每次只询问比 $x$ 大的长度，这可以直接暴力扩展。由于 $x$ 最多移动 $n$ 次，询问次数就是严格 $n$ 次。奇偶分别问一次，次数 $2n$。 

:::::

::::info[代码]

```cpp line-numbers
bool ask(int l, int r) {
	cout << "? " << l << ' ' << r << endl;
	int x; cin >> x;
	return x;
}
void answer(int n) {
	cout << "! " << n << endl;
	exit(0);
}

int n;
void _main() {
	cin >> n;
	int x = 0, y = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = x + 1; 1 <= i - j && i + j <= n; j++) {
			if (!ask(i - j, i + j)) break;
			x++;
		}
		for (int j = y + 1; 1 <= i - j && i + j + 1 <= n; j++) {
			if (!ask(i - j, i + j + 1)) break;
			y++;
		}
	}
	if (y == 0) answer(2 * x + 1);
	else answer(max(2 * x + 1, 2 * y + 2));
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
