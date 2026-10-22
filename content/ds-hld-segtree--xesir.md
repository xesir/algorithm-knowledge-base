---
id: ds-hld-segtree
title: '树链剖分线段树（路径与子树操作）'
category: 数据结构
subcategory: 线段树
subSubcategory: ''
tags: ["数据结构", "线段树", "树链剖分", "重链", "路径修改", "子树查询"]
timeComplexity: '路径操作 O(log² n)，子树操作 O(log n)'
spaceComplexity: 'O(n)'
level: A
codePath: '数据结构\树链剖分线段树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

未学习「树链剖分」的请前往图论相关部分学习。在图论部分已经介绍过树链剖分的过程，这里不再赘述，只讨论如何在线段树上维护树上的路径和子树操作。

树链剖分完成后，每个节点 $u$ 都有一个新的编号 `seg[u]`。考虑把节点点权一并映射到对应编号，然后直接按序列方式建树即可：

- 叶子 `l == r` 时，取 `a[rev[l]]`——`rev[l]` 是「序列第 $l$ 位对应原树上的哪个节点」，这样就把点权按剖分顺序摆进了数组。
- 内部节点正常合并左右儿子的信息。

如果原树上的节点权值发生变化，也应当在线段树中的 `seg[u]` 位置进行修改，而不是直接按照节点编号修改。其他线段树相关的函数照常写即可。

现在的问题是，如何把「路径」和「子树」等查询转换到树链剖分后的序列上。这就不得不用到树链剖分的关键性质：

1. 同一条重链上的节点连续。
2. 一棵子树对应连续区间。

由这两个性质可以得到树链剖分后维护信息的方法。

### 路径处理

假设要处理节点 $u$ 到节点 $v$ 的路径。如果 `top[u] != top[v]`，说明它们不在同一条重链上。此时应当让链顶更深的一侧向上跳：先比较 `dep[top[u]]` 与 `dep[top[v]]`，把更深的那个换到 $u$；于是 `top[u]` 所在的重链更靠下，可以处理从 `top[u]` 到 `u` 的整段链，即区间 $[\text{seg}[\text{top}[u]],\text{seg}[u]]$；处理完之后，将 $u$ 跳到这条重链链顶的父亲 `fah[top[u]]`。不断重复上述过程，直到两个节点位于同一条重链，最终剩余路径就是 $[\text{seg}[u],\text{seg}[v]]$。

这样我们就顺利地把一条路径转换为了不多于 $O(\log n)$ 段区间，单次复杂度 $O(\log^2 n)$。

### 子树处理

因为节点 $u$ 的子树对应连续区间 $[\text{seg}[u],\text{seg}[u]+\text{siz}[u]-1]$，所以子树查询可以直接写成一次区间查询。子树修改同理。如果同时需要路径操作和子树操作，树链剖分通常是非常方便的统一方案。

## 逐行代码解析

### 模块一：按剖分序建树

```cpp
	void buildtree(int u,int l,int r){
		xdt[u].l=l;xdt[u].r=r;xdt[u].laz=0;
		if(l==r){
			xdt[u].ma=xdt[u].wh=a[rev[l]];
			return ;
		}
		buildtree(ls,l,mid);
		buildtree(rs,mid+1,r);
		xdt[u].ma=max(xdt[ls].ma,xdt[rs].ma);
		xdt[u].wh=xdt[ls].wh+xdt[rs].wh;
	}
```

`ls`、`rs`、`mid` 是宏：`ls` 展开成 `u<<1`，`rs` 展开成 `(u<<1)|1`，`mid` 展开成 `((l+r)>>1)`。叶子取 `a[rev[l]]`，把「原树节点权值」按剖分顺序映射到序列上；每个节点同时维护区间和 `wh` 与区间最大值 `ma`。

### 模块二：区间加与区间查询

```cpp
	void promaxultra(int u,int l,int r,int obl,int obr,int v){
		if(l>obr||r<obl) return ;
		if(l>=obl&&r<=obr){
			xdt[u].wh+=(r-l+1)*v;
			xdt[u].ma+=v;xdt[u].laz+=v;
			return ;
		}
		pushdown(u,l,r);
		promaxultra(ls,l,mid,obl,obr,v);
		promaxultra(rs,mid+1,r,obl,obr,v);
		fixup(u);
	}
```

完全覆盖时把 `wh` 加上 $v\times len$、`ma` 加 $v$、`laz` 累加 $v$；否则先 `pushdown` 再递归两侧，最后 `fixup` 合并。`pushdown` 会把 `laz` 传给两个儿子，并按左右儿子各自的区间长度更新 `wh`。

```cpp
	int findinfo(int u,int l,int r,int obl,int obr,bool v){//v=true:查最值
		if(l>obr||r<obl){
			if(v) return LLONG_MIN;
			else return 0;
		}
		if(l>=obl&&r<=obr){
			if(v) return xdt[u].ma;
			else return xdt[u].wh;
		}
		pushdown(u,l,r);
		int res=0;
		if(v) return res=max(findinfo(ls,l,mid,obl,obr,v),findinfo(rs,mid+1,r,obl,obr,v));
		else return res=findinfo(ls,l,mid,obl,obr,v)+findinfo(rs,mid+1,r,obl,obr,v);
		fixup(u);
	}
```

一个函数同时承担「查最值」和「查区间和」：`v=true` 时返回 `ma`，越界返回 `LLONG_MIN`；`v=false` 时返回 `wh`，越界返回 $0$。注意函数末尾的 `fixup(u)` 在 `return` 之后，是执行不到的死代码。

### 模块三：路径操作

```cpp
	int querytree(int x,int y,bool v){
		int ans;
		if(v) ans=LLONG_MIN;
		else ans=0;
		int fx=top[x],fy=top[y];
		while(fx!=fy){
			if (dep[fx]<dep[fy]) swap(x,y),swap(fx,fy);
			if(v) ans=max(ans,findinfo(1,1,seg[0],seg[fx],seg[x],v));
			else ans+=findinfo(1,1,seg[0],seg[fx],seg[x],v);
			x=fah[fx];fx=top[x];
		}
		if(dep[x]<dep[y]) swap(x,y);
		if(v) ans=max(ans,findinfo(1,1,seg[0],seg[y],seg[x],v));
		else ans+=findinfo(1,1,seg[0],seg[y],seg[x],v);
		return ans;
	}
```

只要两个点的链顶不同，就跳更深的那条链，把 `[seg[fx], seg[x]]` 这一段整链交给线段树；跳完后 `x` 变成链顶的父亲。最后两点在同一条链上，再查 `[seg[y], seg[x]]`。整个过程中最多跳 $O(\log n)$ 次，每次线段树 $O(\log n)$，所以单次路径操作 $O(\log^2 n)$。`plustree` 的路径加也是同样的拆链方式，只是把 `findinfo` 换成 `promaxultra`。

### 模块四：子树操作

```cpp
	void plusroot(int x,int v){
		promaxultra(1,1,seg[0],seg[x],seg[x]+siz[x]-1,v);
	}
	int queryroot(int x,bool v){
		return findinfo(1,1,seg[0],seg[x],seg[x]+siz[x]-1,v);
	}
```

子树在剖分序上就是 $[\text{seg}[x],\text{seg}[x]+\text{siz}[x]-1]$，因此子树加、子树查都退化成一次区间操作，单次 $O(\log n)$。注意线段树的下标范围用的是 `seg[0]`：`dfs2` 里 `seg[x]=++seg[0]`，把 `seg[0]` 当计数器用，所以 `seg[0]` 最终等于 $n$。

## 复杂度分析

- 两次 DFS 预处理：$O(n)$。
- 建树：$O(n)$。
- 路径修改 / 路径查询：最多拆成 $O(\log n)$ 段区间，每段线段树操作 $O(\log n)$，总计 $O(\log^2 n)$。
- 子树修改 / 子树查询：一次区间操作，$O(\log n)$。
- 空间：邻接表、剖分数组、四倍线段树，$O(n)$。

## 适用场景

- 树上路径加、路径求和、路径最值，同时还要支持子树加、子树求和。
- 需要把树上问题转成序列问题，并交给线段树维护的通用场景。
- 单点改点权、查路径信息：把修改写成 `seg[x]` 位置的单点修改即可。
- 边权问题可以转成「边权下放到深度较大的端点」再做，但要注意路径查询时 LCA 那一点不能重复算。

## 常见陷阱与注意事项

- 所有树上信息都要通过 `seg[u]` 映射到序列，不能拿原节点编号当下标。
- 路径拆链时先比较 `dep[top[u]]`，不是比较 `dep[u]`；跳的是 `fah[top[u]]`，不是 `fah[u]`。
- 跳完链后 `fx` 要同步更新成新的 `top[x]`，只更新 `x` 会死循环。
- 同一条链上最后一段是 `[seg[y], seg[x]]`（保证 `dep[x] >= dep[y]`），左右端点别写反。
- `seg[0]` 被当作计数器使用，建树范围是 $1\sim\text{seg}[0]$；这是一个容易看漏的写法。
- `findinfo` 末尾的 `fixup(u)` 在 `return` 之后，永远执行不到；查询本身不需要修复，不影响正确性。
- 这份模板里的 `p` 只在主函数查询结果处取模，修改过程没有取模；若题目要求全程取模，需要自己补。
- 这份实现维护的是点权；边权题要额外处理 LCA 位置的归属。
