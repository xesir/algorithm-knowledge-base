---
id: prob-luogu-p13980
title: 'P13980 数列分块入门 5'
oj: '洛谷'
problemId: 'P13980'
difficulty: '提高+/省选−'
cfRating: 'NaN'
category: 数据结构
tags: ["分块", "线段树", "区间开方", "区间求和"]
knowledgePoints: ["ds-block-decomposition", "ds-hld-segtree", "ds-segtree-basic", "ds-segtree-combined"]
timeComplexity: 'O((n+q) log n · log log A)'
spaceComplexity: 'O(n)'
codePath: '题目专辑\数据结构\数列分块入门5\代码--xesir.cpp'
level: A
verified: 2026-10-20
source: 'Xesir'
---

## 题目描述

给出一个长为 $n$ 的数列 $a_1 \ldots a_n$，以及 $n$ 个操作，操作涉及区间开方、区间求和。

### 输入格式

第一行输入一个数字 $n$。

第二行输入 $n$ 个数字，第 $i$ 个数字为 $a_i$，以空格隔开。

接下来输入 $n$ 行询问，每行输入三个数字 $\mathrm{opt}, l, r$，以空格隔开。

若 $\mathrm{opt} = 0$，表示将位于 $[l, r]$ 之间的数字都开方，即对每个 $a_i(l\le i\le r)$ 执行 $a_i \leftarrow \left\lfloor \sqrt{a_i}\right\rfloor$。

若 $\mathrm{opt} = 1$，表示询问位于 $[l, r]$ 的所有数字的和。

### 输出格式

对于每次询问，输出一行一个数字表示答案。

### 数据范围

- 子任务 1（40 分）：$1 \leq n \leq 50000$，$0 \leq a_i,\mathrm{ans} \leq 2^{31}-1$。
- 子任务 2（60 分）：$1 \leq n \leq 300000$，$0 \leq a_i \leq 2^{31}-1$，$0\leq \mathrm{ans}\leq 2^{63}-1$。
- 对于所有测试数据，$1 \leq n \leq 300000$，$0 \leq a_i \leq 2^{31}-1$，$0\leq \mathrm{ans} \leq 2^{63}-1$，$1 \leq l \leq r \leq n$，$\mathrm{opt}\in\{0,1\}$。

## 样例

### 样例 1

**输入：**

```
4
1 2 2 3
0 1 3
1 1 4
0 1 2
1 1 2
```

**输出：**

```
6
2
```

**解释：**

第一次把 $[1,3]$ 开方，数列变成 $1,1,1,3$；查询 $[1,4]$ 得 $6$。第二次把 $[1,2]$ 开方，数列仍是 $1,1,1,3$；查询 $[1,2]$ 得 $2$。

## 解题思路

### 分块解法

非常无脑且简单，正常分块思路即可。由于过于显然，这里不做讲解。

### 线段树解法

这种区间类问题正常思路是考虑线段树维护。难点在于：区间对每个数开根没有一个好的整体维护方法——只知道区间和无法确定开根后的和。

不如转化思路：**直接对每个数暴力开根！**

乍一看这个复杂度必爆无疑，但注意到一个非 $0$ 数开根下取整后，经过有限次数一定会变成 $1$，而 $1$ 开根后不变。

来算算每个数开根多少次会变成 $1$：对于 $n=2^k$，开根一次后变成 $2^{\frac{k}{2}}$，开根 $t$ 次后变为 $2^{\frac{k}{2^t}}$。所以把 $n$ 不断开根直到变成 $1$ 的次数是 $O(\log\log n)$，这个数字非常小，可以忽略不计。

所以我们只需要暴力开根，然后记录「全是 $1$ 的区间」跳过即可。

小细节：题目中权值可能为 $0$，$0$ 开根后不变，所以实际上标记的是 $\le 1$ 的区间。

代码使用线段树解法。

### 为什么「暴力开根」其实不是暴力

关键在于开根会让数值**极快地塌缩**到不动点。

把 $a$ 写成 $2^k$ 的量级，每开一次根，指数就除以 $2$：$k\to k/2\to k/4\to\cdots$。所以要把它压到 $1$，只需要 $\log_2 k$ 次，而 $k\le 31$（$a_i<2^{31}$），也就是**至多 $5$ 次左右**。

换句话说，对每个位置单独开根，总代价是「$n\times O(\log\log A)$」次开根，而不是「每次操作都要扫一遍区间」。$q$ 次操作里绝大多数时候，区间里早就没有还能再开根的数了。

### `q1` 标记在维护什么

线段树的每个结点维护两个量：

- `wh`：区间和，回答询问用；
- `q1`：这个区间是不是**整体都 $\le 1$**。

`q1` 为真的区间，开根操作对它是无效的（$0\to0$，$1\to1$），可以直接跳过。合并时 `q1 = 左.q1 && 右.q1`。

真正的开根只发生在叶子上：内部结点收到覆盖标记后，一路把 `lag` 下推，直到叶子才 `sqrtl`，然后回溯更新 `wh` 与 `q1`。这样每个数最多被真正开根 $O(\log\log A)$ 次，之后就一直被 `q1` 挡住。

### 与分块写法的关系

分块做法的思路完全相同，只是把「整块都 $\le1$ 就跳过」代替了线段树的 `q1`：

| | 分块 | 线段树 |
|---|---|---|
| 跳过条件 | 整块的 `q1` | 结点的 `q1` |
| 散块处理 | 直接暴力 | 递归到叶子 |
| 单次复杂度 | $O(\sqrt n)$ | $O(\log n)$ |

两者的总复杂度同阶（都是靠「每个数只会被开根很少几次」），线段树常数略小。

### 手算样例

初始 $a=(1,2,2,3)$。

1. `0 1 3`：对 $[1,3]$ 开根，$\lfloor\sqrt1\rfloor=1,\lfloor\sqrt2\rfloor=1,\lfloor\sqrt2\rfloor=1$，数列变成 $(1,1,1,3)$；
2. `1 1 4`：$1+1+1+3=6$；
3. `0 1 2`：对前两个开根，$1,1$ 都不变，数列仍是 $(1,1,1,3)$；
4. `1 1 2`：$1+1=2$。

输出 $6$ 和 $2$，与样例一致。注意第 3 步里 $[1,2]$ 这段的 `q1` 已经是真，整段会被直接跳过。

## 逐行代码解析

### 头文件、宏与结点结构

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
#define mid ((l+r)/2)
#define ls (u<<1)
#define rs ((u<<1)|1)
const int N=3e5+10;
int n;
int a[N];
struct redstone{
	int u,l,r;
	int wh;
	bool lag,q1;
} wcj[4*N];
```

- `#define int long long`：区间和会超过 `int`（答案上限 $2^{63}-1$），必须开 `long long`。
- `mid / ls / rs` 三个宏把线段树的下标运算写短，`mid` 依赖函数里的 `l, r` 变量名。
- 结构体里 `u,l,r` 是结点编号与管辖区间，`wh` 是区间和，`lag` 表示「这个区间有待下传的开方操作」，`q1` 表示「整个区间都已经 $\le 1$」。
- 数组开 `4*N`，对应 $3\times10^5$ 的规模。

### 建树

```cpp
void build(int u,int l,int r){
	wcj[u].u=u;wcj[u].l=l;wcj[u].r=r;
	wcj[u].lag=false;
	if(l==r){
		wcj[u].wh=a[l];wcj[u].q1=(bool)(a[l]<=1);
		//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
		return ;
	}
	build(ls,l,mid);build(rs,mid+1,r);
	wcj[u].wh=wcj[ls].wh+wcj[rs].wh;
	wcj[u].q1=wcj[ls].q1&&wcj[rs].q1;
	//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
}
```

- 递归到叶子时直接写入 `a[l]`，并用 `a[l]<=1` 初始化 `q1`。
- 回溯时 `wh` 相加、`q1` 取与：只有两个儿子都 $\le1$，父亲才整段 $\le1$。
- 中间的 `//cout<<...` 是原文留下的调试输出，注释掉不影响运行。

### pushup 与 pushdown

```cpp
void pushup(int u){
	if(wcj[u].l==wcj[u].r){
		wcj[u].q1=(bool)(wcj[u].wh<=1);
		//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
		return ;
	}
	wcj[u].wh=wcj[ls].wh+wcj[rs].wh;
	wcj[u].q1=wcj[ls].q1&&wcj[rs].q1;
}
void pushdown(int u){
	if(!wcj[u].lag) return ;
	if(wcj[u].q1){
	    wcj[u].lag=false;
	    return;
	}
	if(wcj[u].l==wcj[u].r){
		wcj[u].wh=sqrtl(wcj[u].wh);
		//cout<<u<<" "<<wcj[u].wh<<'\n';
		wcj[u].q1=(bool)(wcj[u].wh<=1);
		wcj[u].lag=false;
		return ;
	}
	if(wcj[ls].lag) pushdown(ls);
	if(wcj[rs].lag) pushdown(rs);
	if(wcj[u].lag){
		wcj[ls].lag=true;wcj[rs].lag=true;wcj[u].lag=false;
		pushdown(ls);pushdown(rs);
		pushup(u);
	}
}
```

- `pushup` 叶子处重新算 `q1`，内部结点用两儿子合并。
- `pushdown` 是这套写法的核心：真正执行开方的是叶子，所以一路把 `lag` 往下推，直到叶子才 `sqrtl`。
- `if(wcj[u].q1) { lag=false; return; }`：整段已经 $\le1$，开方不再改变，直接把标记清掉——这就是复杂度能对的原因。
- `sqrtl` 返回 `long double`，赋回 `long long` 会截断取整，正好符合「下取整」的要求。

### 区间开方与区间查询

```cpp
void forget(int u,int obl,int obr){
	//cout<<u<<endl;
	if(wcj[u].r<obl||wcj[u].l>obr) return ;
	//cout<<u<<endl;
	if(wcj[u].l>=obl&&wcj[u].r<=obr){
		wcj[u].lag=true;pushdown(u);pushup(u);
		//cout<<u<<endl;
		return ;
	}
	//cout<<u<<endl;
	pushdown(u);pushup(u);
	//cout<<u<<endl;
	int l=wcj[u].l,r=wcj[u].r;
	if(obl<=mid) forget(ls,obl,obr);
	if(obr>mid) forget(rs,obl,obr);
	pushdown(u);pushup(u);
	return ;
}
int zhuiyi(int u,int obl,int obr){
	if(wcj[u].r<obl||wcj[u].l>obr) return 0;
	if(wcj[u].l>=obl&&wcj[u].r<=obr){
		pushdown(u);pushup(u);
		//cout<<u<<"%"<<wcj[u].wh<<'\n';
		return wcj[u].wh;
	}
	pushdown(u);pushup(u);
	int res=0;
	int l=wcj[u].l,r=wcj[u].r;
	if(obl<=mid) res+=zhuiyi(ls,obl,obr);
	if(obr>mid) res+=zhuiyi(rs,obl,obr);
	pushdown(u);pushup(u);
	return res;
}
```

- `forget` 是区间开方：完全覆盖时打上 `lag` 再立刻 `pushdown`，把开方一路送到叶子；不完整覆盖时先下放、再分别递归、最后重新合并。
- `zhuiyi` 是区间求和：完全覆盖直接返回 `wh`，否则递归两半累加。
- 两个函数都在进入和退出时调用 `pushdown/pushup`，保证「树上每个结点的 `wh` 和 `q1` 都是最新的」。
- 函数名 `forget`、`zhuiyi` 是原作者的习惯叫法，不影响功能。

### 主函数

```cpp
signed main(){
	ios::sync_with_stdio(0);
	cin.tie(0);cout.tie(0);
	cin>>n;
	for(int i=1;i<=n;i++) cin>>a[i];
	build(1,1,n);
	for(int i=1;i<=n;i++){
		int op,l,r;cin>>op>>l>>r;
		if(op) cout<<zhuiyi(1,l,r)<<'\n';
		else forget(1,l,r);
	}
	return 0;
}
```

- 题目保证「$n$ 个数、$n$ 个操作」，所以循环次数直接用 `n`。
- `op` 为 $1$ 时查询、为 $0$ 时开方。
- `signed main` 配合前面的 `#define int long long`。

## 复杂度分析

单次开方最坏要走 $O(\log n)$ 层，但每个数从 $a_i$ 变成 $1$ 只需要 $O(\log\log a_i)$ 次开方，之后就被 `q1` 整段跳过。所以总时间约 $O\big((n+q)\log n\cdot\log\log A\big)$，其中 $A$ 是值域上界；空间是线段树数组 $O(n)$。

## 常见陷阱与注意事项

- **`q1` 要判 $\le 1$ 而不是 $=1$**：题目允许 $a_i=0$，$0$ 开方仍是 $0$，只判 `==1` 会让含 $0$ 的区间永远下传，复杂度退化。
- **叶子才做 `sqrtl`**：在内部结点直接对 `wh` 开方是错的，$\lfloor\sqrt{a+b}\rfloor\ne\lfloor\sqrt a\rfloor+\lfloor\sqrt b\rfloor$。
- **`sqrtl` 的返回类型**：`sqrtl` 返回 `long double`，赋给 `long long` 会截断，正好是下取整；换成 `double` 在 $2^{63}$ 量级会有精度风险。
- **`#define int long long` 的开销**：数组 `wcj[4*N]` 每个结点都变大，$3\times10^5$ 时要留意内存。
- **调试输出残留**：源码里大量 `//cout` 已被注释，若取消注释会 TLE。
- **递归深度**：线段树深度 $O(\log n)$，不会爆栈。

## 对比与扩展

- 与「分块解法」的关系：分块同样利用「开方很快退化到 $1$」这一点，对整块打标记、对散块暴力，复杂度同阶但常数不同。
- 与「区间取模」「区间除法」一类题的关系：都是「操作会让值快速退化到不动点」，于是可以暴力 + 跳过。
- 如果题目改成「区间加 + 区间开方」，就不能只靠 `q1` 跳过了，因为加法会把值重新变大。
