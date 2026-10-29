---
id: ds-dsu-on-tree
title: 'dsu on tree'
category: '数据结构'
subcategory: '其他数据结构'
tags: ["dsu on tree","树上启发式合并","子树","DFS"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 原理

dsu on tree 是一种人类智慧的做法，用来处理一类子树信息的问题。下面来个例题：

> 给你一棵大小为 $n$ 的树，每个节点有颜色 $c_u$。$q$ 次询问，每次询问以 $u$ 为根的子树中的颜色数。
>
> $n,q \le 10^5$。

首先和重链剖分一样，记 $sz_u$ 为子树大小，定义**重儿子**为 $sz_v$ 最大的节点，轻儿子为其他节点。

用一个全局数组记录答案状态。算法分三步进行：

1. 遍历所有轻儿子，**并清空它对全局答案的影响**。
2. 遍历重儿子，**并保留它的影响。**
3. 再次遍历轻儿子，将它的影响合并到全局答案中。

这是一个很暴力的想法。但是可以发现上述过程相当于启发式合并，所以复杂度是 $O(n \log n)$ 的。

## 实现

dsu on tree 的传统实现方法是两次 dfs：

```cpp
void dfs1(int u, int fa) {  // 第一遍 DFS：求重儿子
	sz[u] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs1(v, u), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int fa, bool keep) {    // 第二遍 DFS：dsu on tree
	// keep 表示是否保留 u 的影响
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa && v != son[u]) dfs2(v, u, false);  // 遍历轻儿子
	}
	if (son[u]) dfs2(son[u], u, true);  // 遍历重儿子
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa || v == son[u]) continue;
		// 加入 v 子树的影响
		// 常常要处理 dfs 序后将 v 子树中的节点全部遍历一次
	}
	// 计算 u 子树的答案
	if (!keep) {
		// 清空 u 的影响
		// 常常要处理 dfs 序后将子树中的节点全部删除一次
	}
}
```

有一种好写的方法是利用 set 实现，但复杂度会变成 $O(n \log^2 n)$：

```cpp
set<int> s[N];
void dfs(int u, int fa) {
	bool keep = true;  // 是否保留 u 子树的影响
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		if (s[u].size() < s[v].size()) swap(u, v);  // set 启发式合并
		// 将 v 的影响合并到 u 上并计算 keep
		for (int i : s[v]) s[u].emplace(i);
	}
	// 计算 u 子树的答案
	if (!keep) s[u].clear();  // 清空
}
```

练习：

- [CF600E Lomsat gelral](https://www.luogu.com.cn/problem/CF600E)
- [CF375D Tree and Queries](https://www.luogu.com.cn/problem/CF375D)
- [CF1709E XOR Tree](https://www.luogu.com.cn/problem/CF1709E)（set 式写法）
- [CF570D Tree Requests](https://www.luogu.com.cn/problem/CF570D)
- [CF246E Blood Cousins Return](https://www.luogu.com.cn/problem/CF246E)（set 式写法）
- [CF208E Blood Cousins](https://www.luogu.com.cn/problem/CF208E)
- [P4149 [IOI 2011] Race](https://www.luogu.com.cn/problem/P4149)
- [P4556 [Vani有约会] 雨天的尾巴](https://www.luogu.com.cn/problem/P4556)
- [P1600 [NOIP 2016 提高组] 天天爱跑步](https://www.luogu.com.cn/problem/P1600)（将路径分解为 $u \to \text{LCA}$ 和 $\text{LCA} \to v$ 两段，拆贡献转化为上题）

## 总结

感觉 dsu on tree 适用范围不太广。

dsu on tree 主要应用于离线、静态询问的树上问题。加入和清空贡献时往往和莫队题很像。对于颜色问题，dsu on tree、树上莫队、线段树合并都能解决，相比之下 dsu on tree 有更小的常数。并且 set 式写法非常好写，考场上敲不完线段树合并时属于救命选择。
