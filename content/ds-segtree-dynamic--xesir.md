---
id: ds-segtree-dynamic
title: '动态开点线段树'
category: 数据结构
subcategory: 线段树
subSubcategory: ''
tags: ["数据结构", "线段树", "动态开点", "大值域", "指针", "区间求和"]
timeComplexity: '单次修改/查询 O(log n)'
spaceComplexity: 'O(m log n)'
level: A
codePath: '数据结构\动态开点线段树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

刚才的线段树已经成功维护了 $n\le 10^5$ 的数组，但如果是 $n$ 更大的情况呢？

在「线段树 1.5」中，可以很明显地看到 $n$ 拉到了 $10^9$，此时单单是开线段树的空间就已经 MLE 了。怎么做呢？这时候就要用到动态开点技巧了。

注意到虽然 $n$ 的数据范围大，但操作数 $m$ 还是 $10^5$，也就是说只有 $10^5$ 个位置有值，其他都是滚木。既然这样，我们只开有意义的区间即可，也就是询问到哪个区间就开哪个区间，这就是动态开点。

实现上用一个 `tot` 记录当前节点数，并对每个节点维护其左右子节点的编号，每次查询时访问其编号即可。这样就不再有 `u<<1` / `u<<1|1` 这种「下标即儿子」的假设，而是显式地存 `lc`、`rc` 两个指针。

本模板的初始序列是 $1,2,3,\dots$（每个位置的初值等于位置编号），所以一个区间 $[l,r]$ 的初始和就是等差数列求和

$$
\sum_{i=l}^{r} i=\frac{r(r+1)}{2}-\frac{l(l-1)}{2}
$$

新开一个节点时，直接按这个式子给它赋初值，不需要真的把区间里的每个数都填一遍。

## 逐行代码解析

### 模块一：带左右儿子编号的结点

```cpp
const int N=5e6+10,INF=1e9+10;
struct aqtw{ 
	int tot=0;
	struct redstone{
		int l=-1,r=-1;
		int lc=-1,rc=-1;
		int wh;
		int addz=0;
	} wcj[N];
	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=wcj[u].lc, rc=wcj[u].rc;//记录左右儿子的指针。由于动态开点，原来 u<<1,u<<1|1 的用法不再生效
        wcj[u].wh = wcj[lc].wh + wcj[rc].wh;
    }
```

`lc`、`rc` 存的是**数组下标**而不是区间端点；`-1` 表示这个儿子还没开。`fixtree` 必须通过 `wcj[u].lc` / `wcj[u].rc` 找儿子，不能再写 `u<<1`。区间上界取 `INF=1e9+10`，节点池开 `5e6+10` 个。

### 模块二：`init` 与 `build`

```cpp
	void init(){//初始化第一个节点
	    tot = 0;
	    wcj[1].l = wcj[1].r = 0;
	    wcj[1].wh = wcj[1].addz = 0;
	    wcj[1].lc = wcj[1].rc = -1;
	}

	int build(int l,int r,int x){//加入节点
		++tot;
		wcj[tot].l = l;
		wcj[tot].r = r;
		wcj[tot].wh=x;
		wcj[tot].addz = 0;
		wcj[tot].lc = wcj[tot].rc = -1;
		return tot;
	}
```

`init` 先把 `tot` 归零、把 $1$ 号位置的哨兵清干净；`build` 每调用一次就占用一个新下标，写入区间端点和初始和，并返回这个下标。主函数里 `lzx.build(1,INF,(INF*(INF+1)/2))` 建出覆盖 $[1,INF]$ 的根节点，初始和就是 $1+2+\cdots+INF$。

### 模块三：`plustree`（缺儿子就现场开）

```cpp
	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l && r<=obr){
            wcj[u].wh += k * (r-l+1);
            wcj[u].addz += k;
            return;
        }
        int mid=(l+r)>>1;
        int cns=0;
        if(wcj[u].lc==-1){
        	cns=(mid*(mid+1)/2)-(l*(l-1)/2);
			build(l,mid,cns);
			wcj[u].lc=tot;
		}
		if(wcj[u].rc==-1){
			cns=(r*(r+1)/2)-(mid*(mid+1)/2);
			build(mid+1,r,cns);
			wcj[u].rc=tot;
		}
        banzai(u);
        if(obl<=mid) plustree(wcj[u].lc,l,mid,obl,obr,k);
        if(obr>mid) plustree(wcj[u].rc,mid+1,r,obl,obr,k);
        fixtree(u);	
	}
```

递归到某个节点时，如果它还没有左/右儿子，就按 `[l,mid]`、`[mid+1,r]` 现场开一个，初值用等差数列公式算。**先开儿子，再 `banzai`**，这样下传时儿子一定存在；开完儿子后父节点的 `wh` 与两个儿子的和仍然一致。之后只在有交集的一侧继续递归，回溯时 `fixtree` 修复。

### 模块四：`findxigema`（查询时同样按需开点）

```cpp
	int findxigema(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return 0;
		if(obl<=l && r<=obr) return wcj[u].wh;
		int mid=(l+r)>>1;
		int cns=0;
		if(wcj[u].lc==-1){
		cns=(mid*(mid+1)/2)-(l*(l-1)/2);
			build(l,mid,cns);
			wcj[u].lc=tot;
		}
		if(wcj[u].rc==-1){
			cns=(r*(r+1)/2)-(mid*(mid+1)/2);
			build(mid+1,r,cns);
			wcj[u].rc=tot;
		}
		banzai(u);
		int res=0;
		if(obl<=mid) res += findxigema(wcj[u].lc,l,mid,obl,obr);
		if(obr>mid) res += findxigema(wcj[u].rc,mid+1,r,obl,obr);
		return res;
	}
```

查询也要开点：因为一旦要往某个儿子走，就必须保证这个儿子存在，而且它的初始和要正确。开点逻辑与修改完全一致，所以这里复制了一遍。完全覆盖直接返回 `wh`，否则下传标记后把两侧答案相加。

## 复杂度分析

- 单次修改 / 查询：每次只沿一条到两条路径向下，深度为 $\log(INF)\approx 30$，$O(\log n)$。
- 空间：每个操作最多新开 $O(\log n)$ 个节点，总节点数 $O(m\log n)$，所以节点池开到 $5\times 10^6$ 量级。
- 因为值域固定为 $10^9$，树高不会随 $n$ 增大，实际上是一个「深度 30 左右」的树。

## 适用场景

- 值域很大（如 $10^9$）但操作数不多，按 $4n$ 静态开点会 MLE。
- 需要合并多棵动态开点线段树（线段树合并）时，动态开点是前置条件。
- 可持久化线段树、主席树也依赖同样的「按需开点 + 存儿子编号」思路。
- 初始值不是位置编号时也能用，只是新建节点时的初值要改成对应区间实际的和（例如全 $0$ 就传 $0$）。

## 常见陷阱与注意事项

- 动态开点后不能再写 `u<<1` / `u<<1|1`，必须用 `lc`、`rc` 存的下标。
- 新建节点时一定要把 `lc`、`rc` 置 $-1$，否则会指向上一个复用位置的旧儿子。
- **先建儿子再 `banzai`**，顺序反了会对不存在的节点下传标记。
- 节点池大小按 $m\log V$ 估算，$5\times 10^6$ 是常见量级；开小了会越界。
- 本模板用 `#define int unsigned long long`，而 `INF*(INF+1)/2` 这类表达式依赖无符号运算；改成有符号时要注意溢出。
- 主函数读了 `n` 却没有使用（初始序列固定为 $1,2,\dots$），换题时记得把 `n` 真正用起来。
- 查询里也会开点，所以一次查询之后节点数可能增加，估算空间时要把查询操作也算进去。
