---
id: ds-fhq-treap
title: 'FHQ-Treap（无旋 Treap）'
category: 数据结构
subcategory: 平衡树
subSubcategory: ''
tags: ["数据结构", "平衡树", "FHQ-Treap", "分裂", "合并", "随机优先级"]
timeComplexity: '所有操作期望 O(log n)'
spaceComplexity: 'O(n)'
level: A
codePath: '数据结构\FHQ-Treap\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

FHQ-Treap 全称是**「非旋转式 Treap 及可持久化」**，由中国 OIer 范浩强发明。它和普通 Treap 一样靠随机优先级维持平衡，但**完全抛弃了旋转操作**，所有功能只通过两个核心操作实现：**Split（分裂）**与 **Merge（合并）**。

代码短、理解容易、支持可持久化，让 FHQ-Treap 成为了竞赛中最受欢迎的平衡树实现之一。

### Treap 的定义与随机优先级

**Treap = Tree + Heap**。一个 Treap 节点同时满足两个性质：

1. **二叉搜索树（BST）性质**：左子树所有键值小于根，右子树所有键值大于根，中序遍历得到有序序列。
2. **堆性质**：每个节点有一个**随机优先级**，父节点的优先级大于（或小于）子节点，形成堆结构。

**随机优先级是 Treap 平衡的秘诀**。每个节点被创建时，程序给它分配一个随机数作为优先级，这个优先级与键值完全无关。由于优先级随机，Treap 的期望树高为 $O(\log n)$。

竞赛中推荐使用 `mt19937` 代替 `rand()`，质量更高：

```cpp
auto seed = chrono::steady_clock::now().time_since_epoch().count();
mt19937_64 rng(seed);
int pri = rng();  // 生成随机优先级
```

和线段树一样，需要 `pushup` 维护子树大小：

```cpp
void pushup(int u) {
    sz[u] = sz[ls[u]] + sz[rs[u]] + cnt[u];
}
```

### Split 与 Merge

#### Split（分裂）

`split(root, val, &x, &y)`：将一棵树按 `val` 分成两棵——`x` 中所有键值 $\le val$，`y` 中所有键值 $>val$。

原理是从根开始递归：

- 若当前节点为空：`x = y = 0`。
- 若当前节点键值 $\le val$：当前节点和**整个左子树**都属于 `x`，右子树可能混合，递归分裂右子树。
- 若当前节点键值 $>val$：当前节点和**整个右子树**都属于 `y`，左子树可能混合，递归分裂左子树。

分裂不改变父子关系，堆性质自然保持。

#### Merge（合并）

`merge(x, y)`：将两棵树合并为一棵。**前提**：`x` 中所有键值都不大于 `y` 中所有键值。

原理：

- 若一棵为空，返回另一棵。
- 否则比较两棵树根的**随机优先级**：`x` 的优先级更高就让 `x` 作新根，递归合并 `x` 的右子树和 `y`；否则 `y` 作新根，递归合并 `x` 和 `y` 的左子树。

`split` 和 `merge` 都只沿一条搜索路径递归，期望复杂度 $O(\log n)$。

### 用 Split/Merge 组合所有操作

有了这两个原子操作，其他操作就像搭积木：

- **插入** `v`：`split(root, v, a, b)`，`root = merge(merge(a, new_node(v)), b)`。
- **删除**一个 `v`：`split(root, v, a, c)`；`split(a, v-1, a, b)`；丢弃 `b` 的根；`root = merge(merge(a, b), c)`。
- **查询排名**：`split(root, x-1, a, b)`，`a` 的大小加 $1$ 就是 `x` 的排名。
- **查询第 k 小**：利用 `sz` 字段在树上二分下降。
- **前驱/后继**：`split(root, x-1, a, b)` 后取 `a` 中最大值，或 `split(root, x, a, b)` 后取 `b` 中最小值。

## 逐行代码解析

本模板额外维护了 `cho`（同一键值的重复次数），所以插入和删除都按「先把等于 $v$ 的一段单独切出来」的方式写。

### 模块一：结点、随机优先级与 `pulp`

```cpp
auto seed=chrono::steady_clock::now().time_since_epoch().count();
mt19937_64 rng(seed);
int rdm[N];
struct bst{
	int u,cnt;
	int ls,rs;
	int sz;
	int cho,prw;
	bst():u(0),cnt(0),ls(0),rs(0),sz(0),cho(0),prw(0){}
	bst(int b,int x):u(b),cnt(x),ls(0),rs(0),sz(1),cho(1),prw(rdm[tot]){}
} wcj[N];
```

`cnt` 是键值，`cho` 是该键值出现的次数，`prw` 是随机优先级。构造函数里 `prw(rdm[tot])` 在 `nwn` 中先 `tot++` 再构造，所以取到的是新下标的随机数。`pulp` 就是 `pushup`：

```cpp
void pulp(int u){
	wcj[u].sz=wcj[wcj[u].ls].sz+wcj[wcj[u].rs].sz+wcj[u].cho;
}
```

子树大小 = 左子树大小 + 右子树大小 + 当前键值的重复次数。

### 模块二：`split`

```cpp
void split(int u,int v,int &x,int &y){
	if(!u){
		x=y=0;return ;
	}
	if(wcj[u].cnt<=v){
		x=u;split(wcj[u].rs,v,wcj[u].rs,y);pulp(x);
	}else{
		y=u;split(wcj[u].ls,v,x,wcj[u].ls);pulp(y);
	}
}
```

当前键值 $\le v$ 时，`u` 及整个左子树归 `x`，把 `u` 的右子树继续按 $v$ 切开，切出的左半直接接回 `u` 的右儿子；否则 `u` 及整个右子树归 `y`，把 `u` 的左子树切开，切出的右半接回 `u` 的左儿子。注意 `wcj[u].rs` 是作为引用参数传进去的，所以递归结果会直接写回原位置。

### 模块三：`merge`

```cpp
int merge(int x,int y){
	if(!x||!y) return x|y;
	if(wcj[x].prw<wcj[y].prw){
		wcj[x].rs=merge(wcj[x].rs,y);pulp(x);return x;
	}else{
		wcj[y].ls=merge(x,wcj[y].ls);pulp(y);return y;
	}
}
```

比较随机优先级，小根堆里优先级小的作根。`x` 的优先级更小时，`x` 作根，把 `x` 的右子树与 `y` 合并；否则 `y` 作根，把 `x` 与 `y` 的左子树合并。`x|y` 在其中一个为 $0$ 时直接返回另一个编号。

### 模块四：插入、删除与查询

```cpp
int crinsert(int v){
	int a,b,c;
	split(rot,v,b,c);
	split(b,v-1,a,b);
	if(b==0) return merge(merge(a,nwn(v)),c);
	else wcj[b].cho++;
	pulp(b);
	return merge(merge(a,b),c);;
}
int scdelete(int v){
	int a,b,c;
	split(rot,v,b,c);
	split(b,v-1,a,b);
	if(b==0) return rot;
	else if(wcj[b].cho==1){
		return merge(merge(a,merge(wcj[b].ls,wcj[b].rs)),c);
	} 
	else wcj[b].cho--;
	pulp(b);
	return merge(merge(a,b),c);
}
```

插入：先把 $\le v$ 和 $>v$ 分开，再把 $\le v$ 中 $<v$ 和 $=v$ 分开；若没有等于 $v$ 的节点就新建一个，否则把 `cho` 加一，最后按顺序合回去。删除反过来：若等于 $v$ 的节点重复次数为 $1$，就把它从树上摘掉（合并它的左右儿子）；否则 `cho` 减一。

排名、第 $k$ 小、前驱后继的写法与 BST 那份相同，只是统计时要算上 `cho`：

```cpp
int queryless(int b,int x){
    if(b==0) return 0;
    if(x<=wcj[b].cnt){
        return queryless(wcj[b].ls,x);
    }else{
        return wcj[wcj[b].ls].sz+wcj[b].cho+queryless(wcj[b].rs,x);
    }
}
```

当前键值小于 $x$ 时，左子树、当前键值的全部重复次数都要算进去。`kth` 同理，边界从「左子树大小 + 1」变成「左子树大小 + `cho`」。

## 复杂度分析

- `split`、`merge`：只沿一条搜索路径递归，期望 $O(\log n)$。
- 插入 / 删除：常数次 `split` 和 `merge`，期望 $O(\log n)$。
- 排名 / 第 $k$ 小 / 前驱 / 后继：沿树高走，期望 $O(\log n)$。
- 空间：每个结点固定字段，$O(n)$；被删除的结点不回收。

## 适用场景

- 需要动态插入删除、查排名 / 第 $k$ 小 / 前驱后继，想要代码短、逻辑统一的平衡树。
- 需要**可持久化**平衡树：`split`/`merge` 天然只改路径上的节点，容易扩展。
- 需要按排名分裂、区间翻转（把 `split` 按大小而不是按键值切）等文艺操作。
- 需要维护重复元素时，本模板的 `cho` 字段可以直接计数。

## 常见陷阱与注意事项

- `merge` 的前提是 `x` 中所有键值都不大于 `y` 中所有键值，顺序传反树就不满足 BST 性质。
- `split` 的引用参数顺序要对：`split(u, v, x, y)` 中 `x` 收 $\le v$、`y` 收 $>v$。
- 递归里写 `split(wcj[u].rs, v, wcj[u].rs, y)`，同一个位置既当输入又当输出，这是 FHQ 的惯用写法。
- 本模板用小根堆（`prw` 小的作根），如果改成大根堆，`merge` 的比较方向要跟着改。
- `prw(rdm[tot])` 依赖 `nwn` 先自增 `tot`；自己改代码时别把顺序弄反。
- 删除时 `split(b, v-1, a, b)` 中 `v-1` 的写法要求键值是整数；若键值可能取到最小值，要小心下溢。
- 结点不回收，`N` 要按「插入次数」开够。
- `crinsert` 里 `return` 之后还有 `pulp(b)`，注意哪条分支会提前返回。
