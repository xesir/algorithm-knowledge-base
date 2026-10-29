---
id: prob-luogu-p9527
title: '[JOIST 2022] 洒水器 / Sprinkler'
oj: '洛谷'
problemId: 'P9527'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 图论
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

暂无（原题：[P9527](https://www.luogu.com.cn/problem/P9527)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一棵 $n$ 个节点的无根树，点有点权 $a_i$。$q$ 次操作：
>
> 1. 给出 $u,k,x$，将距离 $u$ 不超过 $k$ 的点的点权乘 $x$。
> 2. 给出 $u$，查询 $u$ 的点权。
>
> 对给出的模数取模，**不保证模数为质数**。
>
> $n \le 2 \times 10^5$，$q \le 4 \times 10^5$，$ k \le 40$，4 秒，1024 MB。

:::::success[题解]
在树上每个节点维护若干标记：将 $u$ 子树中距离恰为 $i$ 的点乘上 $f_{i,u}$。

修改时对这些标记进行更新：$f_{u,k}, f_{u,k-1}, f_{\operatorname{fa}(u),k-2},f_{\operatorname{fa}(u),k-3},\cdots$，显然只会做 $O(k)$ 次。

标记下传很困难，因此永久化。查询时需要跳父亲来得到标记。也只会跳 $O(k)$ 次。

这个做法可以做到不重不漏。复杂度 $O(n+qk)$。
:::::

:::::info[代码]
```cpp line-numbers
const int N = 2e5 + 5;
int n, _mod, q, fa[N];
vector<int> e[N];
mint a[N], tag[41][N];

void dfs(int u) {
	for (int v : e[u]) {
		if (v == fa[u]) continue;
		fa[v] = u, dfs(v);
	}
}

void _main() {
	cin >> n >> _mod, mint::set_mod(_mod);
	for (int i = 1, u, v; i < n; i++) {
		cin >> u >> v;
		e[u].emplace_back(v), e[v].emplace_back(u);
	}
	for (int i = 1; i <= n; i++) cin >> a[i];
	fa[1] = -1, dfs(1);
	for (int i = 0; i <= 40; i++) fill(tag[i], tag[i] + n + 1, 1);
	cin >> q;
	for (int opt, u, k, x; q--; ) {
		cin >> opt >> u;
		if (opt == 1) {
			cin >> k >> x;
			for (int i = 0; i <= k; i++, u = fa[u]) {
				if (fa[u] == -1) {
					for (int d = 0; d <= k - i; d++) tag[d][u] *= x;
					break;
				}
				tag[k - i][u] *= x;
				if (k - i - 1 >= 0) tag[k - i - 1][u] *= x;
			}
		} else {
			mint res = a[u];
			for (int i = 0; i <= 40 && u != -1; i++, u = fa[u]) res *= tag[i][u];
			cout << res << '\n';
		}
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
