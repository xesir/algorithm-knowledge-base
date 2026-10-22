---
id: ds-bst
title: '二叉搜索树（BST）'
category: 数据结构
subcategory: 平衡树
subSubcategory: ''
tags: ["数据结构", "二叉搜索树", "BST", "插入删除", "排名", "前驱后继"]
timeComplexity: '单次操作 O(h)，随机数据期望 O(log n)，最坏 O(n)'
spaceComplexity: 'O(n)'
level: A
codePath: '数据结构\二叉搜索树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

### 引入

想象一下，你有一个巨大的有序数组，想要快速查找一个元素，可以二分查找，$O(\log n)$，完美。但如果你想**插入**或**删除**一个元素呢？数组整体平移，$O(n)$，直接裂开。

于是你想到链表，插入删除 $O(1)$，但查找又变成了 $O(n)$。

好，现在问题来了：**有没有一种数据结构，查找、插入、删除都是 $O(\log n)$？**

有的。它的名字叫——**平衡树**。

> ~~**王从天降，愤怒狰狞！**~~

> 数据结构的众神在云端俯视众生。链表说：「我插入快！」数组说：「我查找快！」
> 于是平衡树从天上降下，雷霆万钧：「**只有蒟蒻才会做选择，我全都要。**」

平衡树就是那个「我全都要」的数据结构。它把二叉搜索树的「有序」和「二分」特性发挥到极致，同时通过**旋转**或**重构**来保证树的高度始终是 $O(\log n)$，从而让所有操作都稳定在对数时间。

**你每天都在用它，只是不知道。** C++ 的 `std::set`、`std::map`、`std::multiset`、`std::multimap`，底层实现都是**红黑树**——一种自平衡二叉搜索树。连 Linux 内核的调度器、内存管理，都离不开平衡树的身影。

> 这时候就有大聪明要问了，为什么不用线段树呢？的确线段树也能解决刚才那个问题，但平衡树能维护的比线段树多太多了，诸如动态添加删除、区间翻转等，所以还是非常有必要讲的。~~虽然的确是线段树更常用一点~~

### 定义

二叉搜索树（Binary Search Tree，BST）是一种二叉树，它满足以下性质：

- 空树是二叉搜索树。
- 若左子树不为空，则左子树上**所有**节点的值都**小于**（或小于等于，视情况而定）根节点的值。
- 若右子树不为空，则右子树上**所有**节点的值都**大于**（或大于等于，视情况而定）根节点的值。
- 左右子树本身也都是二叉搜索树。

也就是说，BST 满足**左小右大**。这棵树的**中序遍历**一定是一个**严格递增**（或非降）的序列。

### 基本操作

- **查找**：从根开始，比当前节点小就往左走，比它大就往右走，等于就找到。$O(h)$，$h$ 是树高。
- **插入**：和查找一样，走到空位置就新建节点挂上去。
- **删除**：稍复杂，分三种情况：叶子节点直接删；只有一个孩子就让孩子接替自己；有两个孩子则找右子树的最小值（或左子树的最大值）来替换自己，然后删掉那个替换节点。
- **查找最值**：一直往左走到底就是最小值，一直往右走到底就是最大值。
- **遍历**：中序遍历输出就是有序序列。

## 逐行代码解析

### 模块一：结点结构

```cpp
int tot=0,rot=0;
struct bst{
	int u,cnt;
	int ls,rs;
	int sz;
	bst():u(0),cnt(0),ls(0),rs(0),sz(0){}
	bst(int b,int x):u(b),cnt(x),ls(0),rs(0),sz(1){}
} wcj[N];
```

`u` 是节点自己的编号（为 $0$ 表示空节点），`ls`、`rs` 是左右儿子编号，`sz` 是子树大小。注意这里的 `cnt` **存的是键值本身**，不是出现次数——虽然名字容易误解，但看 `if(v<wcj[b].cnt)` 这种比较就能确认。两个构造函数分别用于空节点和新建节点。

### 模块二：插入与删除

```cpp
int crinsert(int b,int v){
	if(wcj[b].u==0){
		tot++;
		wcj[tot]=bst(tot,v);
		return wcj[tot].u;
	}
	if(v<wcj[b].cnt) wcj[b].ls=crinsert(wcj[b].ls,v);
	else wcj[b].rs=crinsert(wcj[b].rs,v);
	wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
	return wcj[b].u;
}
```

递归到空节点就新建并返回编号；否则按 `v` 与当前键值的大小往左或往右递归，把返回的新子树接回 `ls`/`rs`，回溯时用「左子树大小 + 右子树大小 + 1」更新 `sz`。注意 `v` 等于当前键值时走的是右子树（`else` 分支），所以重复值会挂在右边。

```cpp
int scdelete(int b,int v){
	if(wcj[b].u==0) return 0;
	if(v<wcj[b].cnt){
		wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
		wcj[b].ls=scdelete(wcj[b].ls,v);
	}
	else if(v>wcj[b].cnt){
		wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
		wcj[b].rs=scdelete(wcj[b].rs,v);
	}
	else{
		if(wcj[b].ls==0){
			wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
			return wcj[b].rs;
		}
		else if(wcj[b].rs==0){
			wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
			return wcj[b].ls;
		}	
		else{
			int nw=wcj[b].rs;
			while(wcj[nw].ls!=0) nw=wcj[nw].ls;
			wcj[b].cnt=wcj[nw].cnt;
			wcj[b].rs=scdelete(wcj[b].rs,wcj[nw].cnt);
		}
	}
	wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
	return wcj[b].u;
}
```

小于往左删、大于往右删；等于时分三种情况：没有左孩子就让右孩子顶替，没有右孩子就让左孩子顶替，两个孩子都有就找右子树最小值 `nw`，把它的键值抄到当前节点，再去右子树里删掉 `nw`。

### 模块三：排名与第 $k$ 小

```cpp
// 返回树中值 < x 的节点个数
int queryless(int b,int x){
    if(b==0) return 0;
    if(x<=wcj[b].cnt){
        return queryless(wcj[b].ls,x);
    }else{
        return wcj[wcj[b].ls].sz+1+queryless(wcj[b].rs,x);
    }
}
// 返回第 k 小的值
int kth(int b,int k){
    if(k<=wcj[wcj[b].ls].sz){
        return kth(wcj[b].ls,k);
    }else if (k==wcj[wcj[b].ls].sz+1){
        return wcj[b].cnt;
    }else{
        return kth(wcj[b].rs,k-wcj[wcj[b].ls].sz-1);
    }
}
```

`queryless` 统计严格小于 $x$ 的节点数：当前键值 $\ge x$ 时只往左找；当前键值 $<x$ 时，左子树全部算上，再加上当前节点，再递归右子树。主函数里 `queryless(rot,x)+1` 就是 $x$ 的排名。

`kth` 用子树大小做二分：左子树够 $k$ 个就往左；正好是左子树大小加一就是当前节点；否则往右，并把 $k$ 减去左子树大小和当前节点。

### 模块四：前驱、后继与主函数

```cpp
int qianququ(int b,int x){
    int ans=LLONG_MIN;
    while(b!=0){
        if(wcj[b].cnt<x){
            ans=wcj[b].cnt;
            b=wcj[b].rs;
        }else{
            b=wcj[b].ls;
        }
    }
    return ans;
}
```

前驱是「小于 $x$ 的最大值」：当前键值 $<x$ 时先记下答案再往右找更大的，否则往左找。后继 `houjiji` 完全对称——当前键值 $>x$ 时记答案再往左，否则往右。

```cpp
    while(n--){
		int opt,x;cin>>opt>>x;
		if(opt==1) rot=crinsert(rot,x);
		else if(opt==2) rot=scdelete(rot,x);
		else if(opt==3) cout<<queryless(rot,x)+1<<'\n';
		else if(opt==4) cout<<kth(rot,x)<<'\n';
		else if(opt==5) cout<<qianququ(rot,x)<<"\n";
		else if(opt==6) cout<<houjiji(rot,x)<<'\n';
	}
```

主函数实现的是 P3369 的六种操作。另有一个 `cxsearch` 按值查找节点编号，但主函数里没有用到。

### 缺陷

BST 的所有操作复杂度都依赖于**树高 $h$**。如果数据是随机的，树高大约是 $O(\log n)$，一切都很好。但如果数据是**有序**的（比如依次插入 $1,2,3,4,\dots,n$），BST 会退化成一个**链**，树高变成 $O(n)$，所有操作退化成 $O(n)$。

这就很尴尬了。我们想要的 $O(\log n)$ 去哪了？根本在于 BST 本身没有自适应机制，无法动态调整树高。于是**解决方案**就是：让树在插入和删除之后**自动调整结构**，始终保持高度在 $O(\log n)$ 左右。这种能自动保持平衡的 BST，就叫**平衡树**。

## 复杂度分析

- 查找、插入、删除、前驱、后继、排名、第 $k$ 小：全部沿一条根到叶的路径走，$O(h)$。
- 随机数据下期望树高 $O(\log n)$，单次期望 $O(\log n)$。
- 有序数据下退化成链，树高 $O(n)$，单次 $O(n)$，$n$ 次操作 $O(n^2)$。
- 空间：每个节点固定几个字段，$O(n)$。

## 适用场景

- 理解平衡树、为后续学习替罪羊树、FHQ-Treap、Splay 打基础。
- 数据随机、对复杂度要求不高的场景，可以直接用裸 BST 水过去。
- 需要动态插入删除 + 查排名 / 第 $k$ 小 / 前驱后继，但不想写复杂平衡树时，可以作为对拍用的暴力。
- **不适合**：数据有序或刻意构造、要求严格 $O(\log n)$ 的正赛题。

## 常见陷阱与注意事项

- 这份代码里 `cnt` 存的是**键值**而不是出现次数，读代码时不要被字段名骗了。
- 重复值会一路往右挂，树里会存在多个键值相同的节点；删除只删一个。
- `queryless` 统计的是**严格小于** $x$ 的个数，排名要再加 $1$。
- `kth` 的边界是 `k == 左子树大小 + 1`，不要把当前节点算进左子树。
- `scdelete` 在两个孩子的分支里先抄键值再递归删右子树的最小值，抄完别忘了更新 `sz`。
- 空节点用 `u == 0` 判断，数组下标从 $1$ 开始，`wcj[0]` 的 `sz` 默认为 $0$。
- 数据有序时树会退化成链，递归深度可能达到 $n$，注意栈溢出风险。
