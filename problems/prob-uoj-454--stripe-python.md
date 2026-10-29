---
id: prob-uoj-454
title: '【UER #8】打雪仗'
oj: 'UOJ'
problemId: 'UOJ454'
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

暂无（原题：[UOJ454](https://uoj.ac/problem/454)）。

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
> - A：已知一个长为 $2n$ 的 01 串 $S$。
> - B：有 $n$ 个下标 $p_1,p_2,\cdots,p_n$。输出这 $n$ 个下标上的字符。
>
> 两个程序之间可以通信，每轮通信只能传输一个 bit。
>
> $n \le 1000$，满分通信次数 $\le 1335$。

:::::success[题解]
核心是平衡规划思想。

注意到 $m \approx \frac{4}{3}{n}$，这启示我们考虑三等分。将字符串切成三段以后，B 可以知道哪一段包含的 $p_i$ 最多，然后将这个信息传输给 A。A 直接将整段传输过去，次数为 $\frac{2n}{3}$。

剩下 $\frac{4n}{3}$ 个位置中，我们注意到 A 发送的字符数上界为 $n-\frac{n}{3}=\frac{2n}{3}$，于是直接让 B 将位置信息压成一个 01 串传给 A，A 再把信息传送回去即可。

A 的通信次数为 $\frac{4n}{3}$，B 的通信次数为 $\frac{4n}{3}+2$，均可通过。
:::::

:::::info[代码]
A：

```cpp line-numbers
const int N = 2005;
int n, m, k, L[4], R[4];
char s[N];
ifstream fin;

void _main() {
    fin.open("alice.in"), fin >> n >> m >> (s + 1), fin.close();
	L[1] = 1, R[1] = 2 * n / 3, L[2] = R[1] + 1, R[2] = 4 * n / 3, L[3] = R[2] + 1, R[3] = 2 * n;
	char c1, c2; cin >> c1 >> c2;
	if (c1 == '0' && c2 == '1') k = 1;
	else if (c1 == '1' && c2 == '0') k = 2;
	else k = 3;
	for (int i = L[k]; i <= R[k]; i++) cout << s[i];
	cout << flush;
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		char c; cin >> c;
		if (c == '1') cout << s[i];
	}
	cout << flush;
}
```

B：

```cpp line-numbers
const int N = 2005;
int n, m, p[N], L[4], R[4], cnt[4];
bool need[N];
char s[N];
ifstream fin;
ofstream fout;

void _main() {
    fin.open("bob.in"), fout.open("bob.out");
	fin >> n >> m;
	for (int i = 1; i <= n; i++) fin >> p[i], need[p[i]] = 1;
	fin.close();
	L[1] = 1, R[1] = 2 * n / 3, L[2] = R[1] + 1, R[2] = 4 * n / 3, L[3] = R[2] + 1, R[3] = 2 * n;
	for (int k = 1; k <= 3; k++) {
		for (int i = L[k]; i <= R[k]; i++) cnt[k] += need[i];
	}
	int k = max_element(cnt + 1, cnt + 4) - cnt;
	if (k == 1) cout << "01" << flush;
	else if (k == 2) cout << "10" << flush;
	else cout << "11" << flush;
	for (int i = L[k]; i <= R[k]; i++) {
		char c; cin >> c;
		if (need[i]) s[i] = c;
	}
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		cout << need[i];
	} cout << flush;
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		if (need[i]) {
			char c; cin >> c;
			s[i] = c;
		}
	} 
	for (int i = 1; i <= n; i++) fout << s[p[i]];
	fout << flush, fout.close();
}
```

:::::

### 【未完成】[QOJ16236 Two-Way Communication](https://qoj.ac/problem/16236)

### 【未完成】[CF1406E Deleting Numbers](https://www.luogu.com.cn/problem/CF1406E)

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
