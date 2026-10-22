---
id: ds-segtree-combined
title: '缝合线段树（区间加/乘/赋值 + 区间求和/最值）'
category: 数据结构
subcategory: 线段树
subSubcategory: ''
tags: ["数据结构", "线段树", "区间赋值", "区间乘法", "多标记", "区间最值"]
timeComplexity: '建树 O(n)，单次修改/查询 O(log n)'
spaceComplexity: 'O(4n)'
level: A
codePath: '数据结构\普通线段树\缝合线段树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

~~！？史史？！~~

这份模板把**区间赋值、区间加、区间乘、区间求和、区间求最值**全部塞进了一棵线段树，是前面基础版和乘法版的「超级缝合版」。原文的定位很明确：一般情况在第一个（区间加 + 区间求和）的基础上改就够了，这份是给需要多种操作混用的题准备的。

为了同时支持这些操作，节点需要维护：

- `wh`：区间和；
- `ma`、`mi`：区间最大值、最小值；
- `addz`：加法标记，初值 $0$；
- `mulz`：乘法标记，初值 $1$；
- `gstz`：赋值标记，初值 $-1$，表示「没有赋值」。

三种标记之间存在明确的优先级：**赋值会覆盖之前的一切标记**。因此在 `banzai` 下传时，先看 `gstz`：如果有赋值，直接把两个儿子的 `wh`、`ma`、`mi` 全部设成赋值，并把儿子的 `addz` 清 $0$、`mulz` 清 $1$；处理完赋值后，再按「先乘后加」下推乘法和加法。

这样任意一个节点的值都可以理解为：先被赋值成某个数，再乘、再加。

## 逐行代码解析

### 模块一：结点与 `fixtree`

```cpp
struct aqtw{ 
	struct redstone{
		int l=-1,r=-1;int wh,mi,ma;
		int addz=0,mulz=1;
		int gstz=-1;
	} wcj[4000100];
	int a[1000100];
	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=u<<1,rc=u<<1|1;
        wcj[u].wh=(wcj[lc].wh+wcj[rc].wh)%q;
        wcj[u].ma=max(wcj[lc].ma,wcj[rc].ma)%q;
        wcj[u].mi=min(wcj[lc].mi,wcj[rc].mi)%q;
    }
```

`fixtree` 同时修复和、最大值、最小值。数组开到 `4000100` / `1000100`，对应 $n$ 到 $10^6$ 级别的数据。`gstz=-1` 是「无赋值」的哨兵，因为本题权值非负，用 $-1$ 不会和真实赋值冲突。

### 模块二：`banzai`（三种标记的下传）

```cpp
	void banzai(int p){
		if(wcj[p].gstz!=-1){
			int mid=(wcj[p].l+wcj[p].r)/2;
		wcj[p<<1].wh = wcj[p].gstz*(mid-wcj[p].l+1)%q;
		wcj[p<<1|1].wh = wcj[p].gstz*(wcj[p].r-mid)%q;
		wcj[p<<1].addz=0;wcj[p<<1].mulz=1;wcj[p<<1].ma=wcj[p].gstz;wcj[p<<1].mi=wcj[p].gstz;
		wcj[p<<1|1].addz=0;wcj[p<<1|1].mulz=1;wcj[p<<1|1].ma=wcj[p].gstz;wcj[p<<1|1].mi=wcj[p].gstz;
		}
		wcj[p<<1].wh = ((wcj[p].mulz*wcj[p<<1].wh)%q+(wcj[p].addz*(wcj[p<<1].r-wcj[p<<1].l+1))%q)%q;
		wcj[p<<1|1].wh = ((wcj[p].mulz*wcj[p<<1|1].wh)%q+(wcj[p].addz*(wcj[p<<1|1].r-wcj[p<<1|1].l+1))%q)%q;
		(wcj[p<<1].mulz *= wcj[p].mulz) %= q;
		(wcj[p<<1|1].mulz *= wcj[p].mulz) %= q;
		wcj[p<<1].addz = ((wcj[p<<1].addz*wcj[p].mulz)%q+wcj[p].addz)%q;
		wcj[p<<1|1].addz = ((wcj[p<<1|1].addz*wcj[p].mulz)%q+wcj[p].addz)%q;
		wcj[p].addz = 0, wcj[p].mulz = 1;wcj[p].gstz=-1;
	}
```

赋值分支把两个儿子的和、最大值、最小值直接改成 `gstz`，并清空儿子的乘加标记——因为「赋值」之后，之前的所有变换都作废。随后统一按乘法、加法下推：儿子的 `wh` 先乘父的 `mulz` 再加父的 `addz * 长度`；儿子的 `mulz` 乘上父的 `mulz`；儿子的 `addz` 先乘父的 `mulz` 再加父的 `addz`。最后父节点三种标记全部复位。

### 模块三：赋值、加、乘

```cpp
	void setnewv(int u,int l,int r,int obl,int obr,int k){
			if(wcj[u].l==-1||wcj[u].r==-1) return;
			if(obl<=l&&r<=obr){
	            wcj[u].wh=k*(r-l+1);wcj[u].wh%=q;
	            wcj[u].ma=k;wcj[u].ma%=q;
	            wcj[u].mi=k;wcj[u].mi%=q;
	            wcj[u].addz=0;wcj[u].addz%=q;
	            wcj[u].mulz=1;
	            wcj[u].gstz=k;
	            return;
	        }
	        banzai(u);
	        int mid=(l+r)>>1;
	        if(obl<=mid) setnewv(u<<1,l,mid,obl,obr,k);
	        if(obr>mid) setnewv(u<<1|1,mid+1,r,obl,obr,k);
	        fixtree(u);	
		}
```

区间赋值在完全覆盖时把 `wh` 设为 $k\times len$，最值设为 $k$，清掉乘加标记，只留下 `gstz=k`。这是「赋值优先级最高」的直接体现。

```cpp
	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh+=k*(r-l+1);wcj[u].wh%=q;
            wcj[u].ma+=k;wcj[u].ma%=q;
            wcj[u].mi+=k;wcj[u].mi%=q;
            wcj[u].addz+=k;wcj[u].addz%=q;
            return;
        }
        ...
	}
```

加法对和、最大值、最小值同时加 $k$，并累加 `addz`。乘法（`promaxultree`）则把和、最大值、最小值、`mulz`、`addz` 全部乘 $k$。两者都是完全覆盖即返回，否则下传、递归相交侧、`fixtree` 修复。

### 模块四：三种查询

```cpp
	int findmax(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return LLONG_MIN;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].ma;
		int res=LLONG_MIN;
		int mad=(l+r)>>1;
		if(obl<=mad) res=max(res,findmax(u<<1,l,mad,obl,obr));
		if(obr>mad) res=max(res,findmax(u<<1|1,mad+1,r,obl,obr));
		return res;
	}
```

`findmax` 用 `LLONG_MIN` 当中性元，递归取两侧最大值。`findmin` 对称地用 `LLONG_MAX`。`findxigema` 的中性元是 $0$，把两侧答案相加后对 `q` 取模。三个查询都先 `banzai`，保证读到的是最新值。

## 复杂度分析

- 建树：$O(n)$。
- 区间赋值 / 加法 / 乘法 / 求和 / 求最值：完全覆盖时 $O(1)$ 打标记，否则每层最多访问常数个节点，单次 $O(\log n)$。
- 空间：`wcj[4000100]`、`a[1000100]`，$O(n)$。

## 适用场景

- 一道题里同时出现区间赋值、区间加、区间乘，还要查区间和或最值。
- 需要把多种标记揉在一棵树上，且能接受较长的代码和较大的常数。
- 原文也提到，这份板子是某些模版题的标准实现（~~其实这个板子就是 [FEOI]羽化锻造模版 的std~~）。

如果只有区间加和区间求和，用基础模板就够；只有加和乘，用乘法模板即可，没必要上这份缝合版。

## 常见陷阱与注意事项

- 赋值标记优先级最高：打赋值时必须清空 `addz` 和 `mulz`，否则旧标记会在下传时「复活」。
- `gstz` 用 $-1$ 当哨兵，前提是权值非负；若数据允许负数，这个哨兵就会和真实赋值混淆。
- 下推顺序是先赋值、再乘法、再加法，顺序错了结果会错。
- 乘法要同时更新 `wh`、`ma`、`mi`、`mulz`、`addz`，漏掉任何一个都会在多操作数据上出错。
- 这里对 `ma`、`mi` 也做了 `%q`。取模会破坏大小关系，严格来说「区间最大值取模」并不是一个良定义的运算；这份代码是按题目要求这样写的，换成别的最值题时要谨慎。
- `#define int long long` 后主函数必须写 `signed main()`。
- 代码使用了 `#pragma GCC optimize` 系列和自定义 `IO` 命名空间，本地调试时如果编译器不支持这些 pragma，可以按需处理。
