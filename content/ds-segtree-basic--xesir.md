---
id: ds-segtree-basic
title: '朴素线段树（区间加 + 区间求和）'
category: 数据结构
subcategory: 线段树
subSubcategory: ''
tags: ["数据结构", "线段树", "懒标记", "区间修改", "区间求和"]
timeComplexity: '建树 O(n)，单次修改/查询 O(log n)'
spaceComplexity: 'O(4n)'
level: A
codePath: '数据结构\普通线段树\基础模板\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

~~真！史！降！临！~~

线段树是一个竞赛常用数据结构，用于维护区间信息。它可以在 $O(n\log n)$ 时间内完成单点与区间修改，查询区间和与最值等，功能非常丰富 ~~（代价是代码很复杂）~~。

其原理是将每个长度不为 $1$ 的区间划分成左右两个区间递归求解，把整个线段划分为一个树形结构，通过合并左右两区间信息来求得该区间的信息，从而方便地进行大部分的区间操作。

线段树是一棵完全二叉树，每个节点表示一段区间，故节点 $i[l\sim r]$ 的左子节点是 $2i[l,mid]$，右子节点为 $2i+1[mid+1,r]$，其中 $mid=\dfrac{l+r}{2}$。

### 区间查询与修改

首先，每个线段树的节点肯定要维护一些信息，或是区间和，又或是最值等。由于每个节点都是一个区间，我们直接定义一个结构体存储它（当然可以用多个数组，原文的教学版叫 `goc[4*N]`，还带了个「防伪标记(bushi)」）。

在线段树中，每个区间都是大区间划分成两段的，每次只需要往其中一端走即可。查询区间 $(1,3)$ 时，从根节点 $(1,5)$ 开始，$(1,3)$ 完全位于左半部分，直接跳到左儿子；左儿子 $(1,3)$ 完全包含 $(1,3)$，直接返回它储存的值。

然而事情并不总如我们所愿，查询的区间常常跨左右两端。查询区间 $(2,4)$ 时，依然从 $(1,5)$ 开始，可以看出 $(2,4)$ 在左右两端都有询问。怎么处理呢？分开找不就好了！把查询拆到两边，最后把答案合并即可（查询区间和就把两边加起来，查最大值就取 $\max$）。容易看出递归几轮后就会变成单一侧查询，因此复杂度不变。

### 懒标记

懒标记是线段树的灵魂，运用于区间修改。

试想一下，如果没有懒标记，每次修改区间时下面的子区间还没修改，这样得把整个子树修改，每次都要 $O(n\log n)$，全局复杂度退化为 $O(nm\log n)$ ~~(白写了还不如暴力呢)~~。

这时候就要请懒标记出山了！它其实相当于一个「延迟」：当我们修改一段区间的信息时，并不需要立即得知其所有子区间的信息，只需要标记一个「待修改」，等查询到时再下传给子区间即可，维护了线段树 $O(n\log n)$ 的复杂度。

## 逐行代码解析

下面按模板的实际写法拆成四个模块，拼起来就是完整实现。

### 模块一：结点定义

```cpp
struct aqtw{ 
	struct redstone{
		int l=-1,r=-1;
		int wh;
		int addz=0;
	} wcj[800100];
	int a[200100];
```

`redstone` 里 `l`、`r` 是区间端点，`wh` 是区间和，`addz` 是加法懒标记。`l`、`r` 初值为 $-1$，因此代码里用 `wcj[u].l==-1||wcj[u].r==-1` 判断「这个节点还没被建出来」，所有操作一进来先做这个哨兵判断。整个 `aqtw` 结构体最后声明为全局对象 `lzx`，相当于把树和操作函数打包在一起。

### 模块二：`fixtree` 与 `banzai`

```cpp
	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=u<<1, rc=u<<1|1;
        wcj[u].wh = wcj[lc].wh + wcj[rc].wh;
    }

	void banzai(int p){
		if(wcj[p].l==-1||wcj[p].r==-1) return;
		int lc=p<<1, rc=p<<1|1;
		int lenL = wcj[lc].r - wcj[lc].l + 1;
		int lenR = wcj[rc].r - wcj[rc].l + 1;
		if(wcj[p].addz != 0){
			wcj[lc].wh += wcj[p].addz * lenL;
			wcj[rc].wh += wcj[p].addz * lenR;
			wcj[lc].addz += wcj[p].addz;
			wcj[rc].addz += wcj[p].addz;
			wcj[p].addz = 0;
		}
	}
```

`fixtree` 是 `pushup`：用两个儿子的 `wh` 还原当前节点的 `wh`。`banzai` 是 `pushdown`：把父节点的 `addz` 分别乘上左右儿子的区间长度后加到儿子的 `wh` 上，同时把标记累加到儿子的 `addz`，最后清空自己的 `addz`。注意先改儿子的值、再改儿子的标记，顺序不能反。

### 模块三：建树

```cpp
	void build(int u,int l,int r){
		wcj[u].l=l, wcj[u].r=r;
		wcj[u].addz=0;
		if(l==r) { wcj[u].wh = a[l]; return; }
		int mid=(l+r)>>1;
		build(u<<1,l,mid);
		build(u<<1|1,mid+1,r);
		wcj[u].wh = wcj[u<<1].wh + wcj[u<<1|1].wh;
	}
```

递归到叶子时把 `a[l]` 填进 `wh`，回溯时把两个儿子的和相加。建树只做一次，$O(n)$。

### 模块四：区间修改与区间查询

```cpp
	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l && r<=obr){
            wcj[u].wh += k * (r-l+1);
            wcj[u].addz += k;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) plustree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) plustree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}
```

完全覆盖时直接改 `wh`、打标记走人；否则先下传懒标记，再只递归与询问区间有交集的一侧，最后 `fixtree` 修复当前节点。

```cpp
	int findxigema(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return 0;
		if(obl<=l && r<=obr) return wcj[u].wh;
		banzai(u);
		int res=0;
		int mid=(l+r)>>1;
		if(obl<=mid) res += findxigema(u<<1,l,mid,obl,obr);
		if(obr>mid) res += findxigema(u<<1|1,mid+1,r,obl,obr);
		return res;
	}
```

查询同样先 `banzai` 再递归；完全覆盖直接返回 `wh`，否则把左右两边命中的答案相加。查询不需要 `fixtree`，因为没有修改信息。

## 复杂度分析

- 建树：每个节点访问一次，$O(n)$。
- 区间修改 / 区间查询：每层最多访问常数个节点，树高 $O(\log n)$，单次 $O(\log n)$。
- 空间：四倍数组 `wcj[800100]`、原数组 `a[200100]`，均为 $O(n)$ 级别。

## 适用场景

- 区间加、区间求和：本模板直接对应线段树 1 类问题。
- 单点修改、区间查询：把区间修改的 `l=r=x` 即可。
- 需要维护区间最值、区间乘、区间赋值等可合并信息：在本模板上替换 `fixtree` 与标记逻辑。
- 数据范围到 $10^5$ 级别、要求 $O(\log n)$ 单次操作时，线段树是标准选择。

如果只需要单点修改 + 前缀和，树状数组更短更轻；如果操作无法用标记表示（比如区间第 $k$ 小），就要换别的方法。

## 常见陷阱与注意事项

- `pushdown`（`banzai`）必须在递归子节点之前调用，否则子节点读到的是旧信息。
- 修改后一定要 `fixtree` 回溯修复；查询不需要修，但查询前仍要下传标记。
- 懒标记的影响是「整段」，加标记时要乘区间长度 `r-l+1`，不能只加 `k`。
- 判断完全覆盖用 `obl<=l && r<=obr`，判断相交用 `obl<=mid` / `obr>mid`，不要写成两边都递归。
- 数组要开 $4n$；`800100` 对应 $n\approx 2\times 10^5$。
- `#define int long long` 之后主函数要写 `signed main()`，否则会编译报错。
- 原文教学版的结构体叫 `goc`，实际模板里叫 `wcj`、外层叫 `aqtw`，看代码时别被命名绕晕。
