---
id: ds-bit-point-range
title: '树状数组（单点修改 + 区间查询）'
category: 数据结构
subcategory: 树状数组
subSubcategory: ''
tags: ["数据结构", "树状数组", "lowbit", "单点修改", "区间查询", "逆序对"]
timeComplexity: '单次修改/查询 O(log n)'
spaceComplexity: 'O(n)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

我们之前学过前缀和，它可以快速求出区间和，十分好用。唉但如果出题人 ~~故意找茬~~ 加了个单点修改呢？

例：给定长度为 $n$ 的序列 $a$，有 $m$ 个操作：

1. 求 $l$ ~ $r$ 区间和
2. 将位置 $x$ 的数加上 $v$

如果依旧用前缀和，每次修改都会对后面 $a[x]$ ~ $a[n]$ 的数产生影响，故复杂度 $O(nm)$，在 $n,m$ 超过 $10^5$ 时原地爆炸。怎么办呢？请树状数组出山！

树状数组 ~~(线段树青春版)~~ 是一种支持单点修改和区间查询的、代码量小的数据结构，复杂度 $O(n\log n)$。

比如要求 $a[1...7]$ 的和：一种做法为 $ans=a_1+a_2+a_3+a_4+a_5+a_6+a_7$ ~~太慢了太慢了~~；如果我们已知 $A=a[1...4],B=a[5...6],C=a[7...7]$，则 $ans=A+B+C$。

树状数组能快速求解信息的原因：我们总能将一段前缀 $[1,n]$ 拆成不多于 $\log n$ 段区间。这就是它的中心思想，即依托二进制划分区间，用极简的数组结构维护区间信息，实现低常数、易编写的高效操作。

$c[n]$ 即为树状数组，不难看出每个 $c[i]$ 都会向左管理一段区间。具体的，$c[i]$ 表示 $a[i-\operatorname{lowbit}(i)+1...i]$ 的和。

注：$\operatorname{lowbit}(x)$ 是指 $x$ 的二进制中最后一个 $1$，如 $\operatorname{lowbit}(5)=1$、$\operatorname{lowbit}(14)=2$，写代码时可以用 $\operatorname{lowbit}(x)=x\&(-x)$ 求得。

不难发现，不同 $c[i]$ 集合之间要么包含要么不交，且 $c[i]$ 的父节点为 $c[i+\operatorname{lowbit}(i)]$，对于任何 $x<y<x+\operatorname{lowbit}(x)$ 有 $c[x]$ 与 $c[y]$ 不交。

## 核心公式 / 结构定义

$$
c[i]=\sum_{j=i-\operatorname{lowbit}(i)+1}^{i} a[j]
$$

$$
\operatorname{lowbit}(x)=x\&(-x)
$$

## 逐行代码解析

### 模块一：查询前缀和

```cpp
int query(int x){
	int res=0;
	for(int i=x;i!=0;i-=lowbit(i)){
		res+=c[i];
	}
	return res;
}
```

`query(x)` 表示 $1$ ~ $x$ 所有数的和，查询 $l$ ~ $r$ 区间和时使用 `query(r)-query(l-1)`。

原理：由上得 $c[i]$ 区间的左端点是 $c[i-\operatorname{lowbit}(i)+1]$，那么 $c[i-\operatorname{lowbit}(i)]$ 即为 $c[i]$ 左边第一个未覆盖的区间，一直往左跳直到 $0$，累加可求值。循环条件写成 `i!=0` 而不是 `i>=0`，否则会访问到 `c[0]`。

### 模块二：单点修改

```cpp
void add(int x,int v){
	for(int i=x;i<=n;i+=lowbit(i)){
		c[i]+=v;
	}
}
```

原理：$c[i]$ 的父节点为 $c[i+\operatorname{lowbit}(i)]$，即对 $c[i]$ 的修改需反映在其父节点上。上界是 `i<=n`，跳出后不再有父节点。

这样我们就成功构建了一个树状数组，代码非常清新 ~~比勾石线段树好太多了~~。

### 模块三：逆序对的主函数部分

```cpp
int n,q=0;cin>>n;
	for(int i=1;i<=n;i++){
		cin>>a[i];
		q+=query(a[i]);
		add(a[i],1);
	}
	cout<<q<<'\n';
```

若 $i<j$ 且 $a[i]>a[j]$，则 $(i,j)$ 是逆序对。我们把每个数看成下标，依次加入时查询前面已经加入的、不大于它的数的个数，累加即为答案。

### 模块四：值域过大时的离散化

若值域很大（如 $a[i]\le 10^9$），此时数组会爆，需要离散化：

```cpp
    vector<int> a,b;
    a.push_back(0);
    for(int i=1;i<=n;i++){
        int t;cin>>t;
        a.push_back(t);
    }
    b=a;
    sort(a.begin()+1,a.end(),cmp);
    a.erase(unique(a.begin()+1,a.end()),a.end());
    for(int i=1;i<=n;i++){
        b[i]=lower_bound(a.begin()+1,a.end(),b[i])-a.begin();
    }
```

原文里 `sort` 用了外部传入的 `cmp`（该函数未给出）；`a[0]` 留作哨兵，离散化后的下标从 $1$ 开始，正好符合树状数组的习惯。

## 复杂度分析

- 单点修改：沿父节点链向上跳，最多 $O(\log n)$ 次。
- 前缀查询：沿未覆盖区间向左跳，最多 $O(\log n)$ 次。
- 区间查询：两次前缀查询相减，$O(\log n)$。
- 建树：逐个 `add` 是 $O(n\log n)$；空间只开一个 $c$ 数组，$O(n)$。
- 逆序对：$n$ 次查询加修改，总计 $O(n\log n)$。

## 适用场景

- 单点修改 + 前缀/区间求和，这是树状数组最标准的形态。
- 求逆序对、统计「前面有多少个数比当前数小/大」这类偏序计数。
- 值域不大，或者可以离散化后压到 $O(n)$ 的值域。
- 需要低常数、短代码的场合；原文也直接说它比线段树清爽得多。

如果需要区间修改、区间查询，单靠一棵树状数组不够，得配合差分或多棵树状数组；区间最值这类不满足「可减性」的信息也不适合直接套。

## 常见陷阱与注意事项

- 下标必须从 $1$ 开始，`c[0]` 永远不参与运算。
- `lowbit(0)=0`，查询循环用 `i!=0` 收尾最稳。
- 修改是 `i+=lowbit(i)`，查询是 `i-=lowbit(i)`，两个方向别写反。
- 区间和是 `query(r)-query(l-1)`，不是 `query(r)-query(l)`。
- 逆序对统计的是「已加入的、小于等于当前值」的个数；若有重复元素，等号的处理决定了重复对算不算逆序对。
- 值域大一定要离散化，否则数组直接越界；离散化时注意去重和 `lower_bound` 的下标基准。
