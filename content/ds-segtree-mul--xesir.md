---
id: ds-segtree-mul
title: '乘法线段树（区间加 + 区间乘 + 区间求和）'
category: 数据结构
subcategory: 线段树
subSubcategory: ''
tags: ["数据结构", "线段树", "区间乘法", "区间加法", "双标记", "懒标记"]
timeComplexity: '建树 O(n)，单次修改/查询 O(log n)'
spaceComplexity: 'O(4n)'
level: A
codePath: '数据结构\普通线段树\乘法线段树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

这一份是在朴素线段树的基础上，同时维护**区间加**和**区间乘**，并支持取模的版本（对应线段树 2 类问题）。结构仍然是完全二叉树：节点 $i$ 的左儿子 $2i$、右儿子 $2i+1$，每个节点维护区间 $[l,r]$ 的和 `wh`。

区别在于懒标记从一个变成两个：

- `addz`：加法标记，初值 $0$；
- `mulz`：乘法标记，初值 $1$。

任意节点的真实值可以看成「原来的值先乘 `mulz` 再加 `addz` 乘区间长度」，即

$$
\text{wh}=\text{原值}\times\text{mulz}+\text{addz}\times(r-l+1)
$$

两种标记必须按「先乘后加」的顺序复合。考虑一个已有标记 $(\text{mulz},\text{addz})$ 的节点，又收到一次乘法 $k$：

$$
(\text{原值}\times\text{mulz}+\text{addz}\times len)\times k
=\text{原值}\times(\text{mulz}\cdot k)+(\text{addz}\cdot k)\times len
$$

所以乘法会把 `mulz` 和 `addz` 都乘上 $k$。如果收到的是加法 $k$，则只有 `addz` 增加 $k$。这正是 `promaxultree` 里三行都要乘 $k$、而 `plustree` 只动 `addz` 的原因。

## 逐行代码解析

### 模块一：双标记结点

```cpp
int q;

struct aqtw{ 
	struct redstone{
		int l=-1,r=-1;
		int wh;
		int addz=0,mulz=1;
	} wcj[800100];
	int a[200100];
```

`q` 是全局模数，`wh`、`addz` 都要对 `q` 取模；`mulz` 的初值必须是 $1$，否则「没有乘法」会被当成「乘 $0$」。`l`、`r` 仍然用 $-1$ 当「节点不存在」的哨兵。

### 模块二：`banzai`（下传双标记）

```cpp
	void banzai(int p){
		if(wcj[p].l==-1||wcj[p].r==-1) return;
		int lc=p<<1, rc=p<<1|1;
		int lenL = wcj[lc].r - wcj[lc].l + 1;
		int lenR = wcj[rc].r - wcj[rc].l + 1;
		// 下推乘法
		if(wcj[p].mulz != 1){
			wcj[lc].wh = wcj[lc].wh * wcj[p].mulz % q;
			wcj[rc].wh = wcj[rc].wh * wcj[p].mulz % q;
			wcj[lc].mulz = wcj[lc].mulz * wcj[p].mulz % q;
			wcj[rc].mulz = wcj[rc].mulz * wcj[p].mulz % q;
			wcj[lc].addz = wcj[lc].addz * wcj[p].mulz % q;
			wcj[rc].addz = wcj[rc].addz * wcj[p].mulz % q;
		}
		// 下推加法
		if(wcj[p].addz != 0){
			wcj[lc].wh = (wcj[lc].wh + wcj[p].addz * lenL) % q;
			wcj[rc].wh = (wcj[rc].wh + wcj[p].addz * lenR) % q;
			wcj[lc].addz = (wcj[lc].addz + wcj[p].addz) % q;
			wcj[rc].addz = (wcj[rc].addz + wcj[p].addz) % q;
		}
		wcj[p].mulz = 1;
		wcj[p].addz = 0;
	}
```

先下推乘法：儿子的 `wh`、`mulz`、`addz` 全部乘上父节点的 `mulz`——因为父节点的乘法作用在「儿子已有标记」之后，儿子的加法标记也必须跟着乘。再下推加法：只把 `addz * 区间长度` 加到儿子的 `wh` 上，并把 `addz` 累加过去。最后父节点标记复位。

### 模块三：区间加与区间乘

```cpp
	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh = (wcj[u].wh + k * (r-l+1)) % q;
            wcj[u].addz = (wcj[u].addz + k) % q;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) plustree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) plustree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}

	void promaxultree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh = wcj[u].wh * k % q;
            wcj[u].mulz = wcj[u].mulz * k % q;
            wcj[u].addz = wcj[u].addz * k % q;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) promaxultree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) promaxultree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}
```

区间加：`wh` 加上 $k\times len$，`addz` 加 $k$。区间乘：`wh`、`mulz`、`addz` 三者都乘 $k$。两者都在完全覆盖时直接返回，否则先下传、再递归相交的一侧、最后 `fixtree` 修复。

### 模块四：区间查询

```cpp
	int findxigema(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return 0;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].wh % q;
		int res=0;
		int mid=(l+r)>>1;
		if(obl<=mid) res=(res+findxigema(u<<1,l,mid,obl,obr))%q;
		if(obr>mid) res=(res+findxigema(u<<1|1,mid+1,r,obl,obr))%q;
		return res%q;
	}
```

注意这份模板把 `banzai(u)` 放在了「完全覆盖」判断之前：即使当前节点已经整段命中，也先把标记推给儿子再返回。静态四倍数组下这样写不会越界，结果也正确，只是多做了一点无用功；如果照搬到动态开点版本，就要注意儿子是否存在。

## 复杂度分析

- 建树：$O(n)$。
- 区间加 / 区间乘 / 区间求和：单次 $O(\log n)$，与普通线段树同阶，只是每次常数更大。
- 空间：`wcj[800100]`、`a[200100]`，$O(n)$。

## 适用场景

- 同时存在区间加、区间乘、区间求和，并且要求取模。
- 把乘法标记的思路推广到「区间赋值 + 区间加 + 区间乘」的缝合版。
- 只要区间加、不涉及乘法时，用朴素线段树就够了，不必背双标记。

## 常见陷阱与注意事项

- 复合顺序必须是「先乘后加」：乘法要同时改 `mulz` 和 `addz`，加法只改 `addz`。
- `mulz` 初值是 $1$，`addz` 初值是 $0$；复位时也要恢复成 $1$ 和 $0$。
- 下推乘法时，儿子的 `addz` 也要乘父节点的 `mulz`，漏掉这一行会在「先加后乘」的数据上错。
- 每次运算都要取模，尤其是 `k * (r-l+1)` 这种乘积。
- 这份模板在 `#define int long long` 之前就定义了 `read` / `write`，所以这两个函数里的 `int` 还是 32 位；主函数用 `signed main()` 才能和宏展开后的 `long long main` 对上。
- `q` 声明在 `#define int long long` 之后，实际是 `long long`，不要误以为它溢出。
- 输入时把 `a[i]` 和修改的 `k` 都先对 `q` 取模，可以减少中间溢出的风险。
