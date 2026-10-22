---
id: ds-scapegoat-tree
title: '替罪羊树'
category: 数据结构
subcategory: 平衡树
subSubcategory: ''
tags: ["数据结构", "平衡树", "替罪羊树", "重量平衡", "重构", "平衡因子"]
timeComplexity: '插入/删除/查找均摊 O(log n)'
spaceComplexity: 'O(n)'
level: A
codePath: '数据结构\替罪羊树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

这是最基础的一种平衡树。

### 核心思想

替罪羊树是一种**重量平衡树**。它的思路非常直接：

> **平时不管，失衡了就暴力重构。**

其他平衡树会在每次插入删除后小心翼翼地通过**旋转**来维持平衡，代码复杂且容易写错。替罪羊树则选择了一条截然不同的路：**平时不调整，等树变得「太不平衡」了，直接抓出罪魁祸首的子树，整个推倒重建**。

那棵被选中重构的子树，就是**替罪羊**，这就是它名字的由来。

~~暴力出奇迹~~

### 平衡因子 $\alpha$

替罪羊树引入了一个参数 $\alpha$。对于树上的每个节点 $x$，设：

- $\text{size}(x)$ 表示以 $x$ 为根的子树大小（包含所有节点）。
- $\text{size}(\text{left}(x))$ 和 $\text{size}(\text{right}(x))$ 分别表示左右子树的大小。

如果存在某个节点 $x$，满足：

$$
\max(\text{size}(\text{left}(x)),\ \text{size}(\text{right}(x)))>\alpha\cdot\text{size}(x)
$$

也就是说，**某一棵子树的大小超过了整棵子树大小的 $\alpha$ 倍**，我们就认为这棵树「失衡」了。此时，以 $x$ 为根的子树就是替罪羊，需要被**重构**。

### 重构操作

重构分为两步：

1. **中序遍历**：将替罪羊子树中的所有节点按中序遍历顺序存入一个数组。因为 BST 的中序遍历就是有序序列，所以这个数组是**有序**的。
2. **二分建树**：取数组的**中点**作为新的根，左侧递归建左子树，右侧递归建右子树。这样建出来的树一定是**完全平衡**的。

单次重构的复杂度是 $O(|T|)$，其中 $|T|$ 是替罪羊子树的大小。

### 插入与删除

插入时，先按照普通 BST 的方式插入新节点，然后**从下往上**回溯，检查路径上是否存在失衡节点；如果找到了，就对那个节点进行重构。

替罪羊树的删除有两种常见实现方式：

- **惰性删除**：不真正删除节点，只把该节点的标记清掉。如果被标记删除的节点太多，导致树的有效节点比例失衡，就触发重构。
- **真正删除**：按 BST 的方式删除节点，然后像插入一样检查失衡并重构。

本模板采用的是**真正删除**：把节点从树上摘掉，再沿途检查并重构。

### 复杂度与优缺点

> 替罪羊树的复杂度显然是均摊的，其很大程度取决于 $\alpha$ 的值。证明比较复杂，这里不详细展开，实测表明 $\alpha$ 取 $0.7\sim 0.8$ 最优。

- 插入：均摊 $O(\log n)$。
- 删除：均摊 $O(\log n)$。
- 查找：$O(\log n)$。

虽然单次操作可能因为重构而变慢，但**均摊**下来，所有操作都是 $O(\log n)$。

优点：实现简单，常数小，便于理解。  
缺点：不支持区间操作，无法完全可持久化，可能会被卡。

替罪羊树更多的是帮你理解并入门平衡树，做题时写平衡树一般不会优先用这个。

## 逐行代码解析

### 模块一：结点与平衡判断

```cpp
const double ALPHA=0.75;
int tot=0,rot=0;
struct bst{
    int u,cnt;
    int ls,rs;
    int sz;
    bst():u(0),cnt(0),ls(0),rs(0),sz(0){}
    bst(int b,int x):u(b),cnt(x),ls(0),rs(0),sz(1){}
} wcj[N];
bool isping(int b){           //判断子树是否平衡
    if(b==0) return true;
    int lsz=wcj[wcj[b].ls].sz;
    int rsz=wcj[wcj[b].rs].sz;
    return max(lsz,rsz)<=ALPHA*wcj[b].sz;
}
```

`ALPHA=0.75` 就是平衡因子，落在原文推荐的 $0.7\sim0.8$ 区间内。`isping` 判断「左右子树中较大的那个是否不超过 $\alpha\cdot$ 整棵子树大小」，超过就说明失衡。字段命名和 BST 那份一致：`u` 是自身编号，`cnt` 是键值，`sz` 是子树大小。

### 模块二：中序遍历、二分重建

```cpp
void findnode(int b,vector<int>& son){//中序遍历收集节点编号
    if(b==0) return;
    findnode(wcj[b].ls,son);
    son.push_back(b);
    findnode(wcj[b].rs,son);
}
int build(vector<int>& son,int l,int r){//重建平衡树
    if(l>r) return 0;
    int mid=(l+r)>>1;
    int nwr=son[mid];
    wcj[nwr].ls=build(son,l,mid-1);
    wcj[nwr].rs=build(son,mid+1,r);
    wcj[nwr].sz=wcj[wcj[nwr].ls].sz+wcj[wcj[nwr].rs].sz+1;
    return nwr;
}
void rebuild(int &b){              //重构子树
    vector<int>son;
    findnode(b,son);
    for(int id:son){
        wcj[id].ls=wcj[id].rs=0;
    }
    b=build(son,0,son.size()-1);
}
```

`findnode` 中序遍历把节点编号按有序顺序塞进 `son`；`build` 每次取区间中点作根，递归建左右半边，回溯时重算 `sz`；`rebuild` 先把这些节点的左右儿子清空（防止旧指针形成环），再用 `build` 重建整棵子树。参数 `int &b` 是引用，所以 `b` 会被直接改成新的根。

### 模块三：插入

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
    if(!isping(b)) rebuild(b);
    return wcj[b].u;
}
```

先按 BST 规则递归插入，回溯时更新 `sz`，然后**每次回溯都检查当前节点是否失衡**，失衡就立刻以它为替罪羊重构。因为是从下往上，第一个被发现的失衡节点就是最靠下的罪魁祸首。

### 模块四：删除

```cpp
int scdelete(int b,int v){
    if(wcj[b].u==0) return 0;
    if(v<wcj[b].cnt){
        wcj[b].ls=scdelete(wcj[b].ls,v);
        wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
        if(!isping(b)) rebuild(b);
    }
    else if(v>wcj[b].cnt){
        wcj[b].rs=scdelete(wcj[b].rs,v);
        wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
        if(!isping(b)) rebuild(b);
    }
    else{
        if(wcj[b].ls==0){
            return wcj[b].rs;
        }
        else if(wcj[b].rs==0){
            return wcj[b].ls;
        }
        else{
            int nw=wcj[b].rs;
            while(wcj[nw].ls!=0) nw=wcj[nw].ls;
            wcj[b].cnt=wcj[nw].cnt;
            wcj[b].rs=scdelete(wcj[b].rs,wcj[nw].cnt);
            wcj[b].sz=wcj[wcj[b].ls].sz+wcj[wcj[b].rs].sz+1;
            if(!isping(b)) rebuild(b);
        }
    }
    return wcj[b].u;
}
```

和 BST 的删除同构：小于往左、大于往右，相等时按「无左孩子 / 无右孩子 / 两个孩子」三种情况处理。两个孩子时用右子树最小值替换，再去右子树删掉它。每层回溯后同样检查并重构。被摘掉的节点不会回收，`tot` 只增不减。

## 复杂度分析

- 插入：正常 BST 路径 $O(\log n)$，加上均摊的重构代价，均摊 $O(\log n)$。
- 删除：同理，均摊 $O(\log n)$。
- 查找、排名、第 $k$ 小、前驱后继：沿树高走，$O(\log n)$。
- 单次重构 $O(|T|)$，但被重构的子树大小会按 $\alpha$ 的比例增长，均摊到每次插入删除是 $O(\log n)$。
- 空间：所有节点存在数组里，删除不回收，最坏可能是操作次数级别，$O(n+q)$。

## 适用场景

- 想入门平衡树，理解「重构」这一思路。
- 需要动态插入删除 + 查排名 / 第 $k$ 小 / 前驱后继，但对常数和被卡的风险要求不高。
- 作为对拍时的暴力平衡树实现，代码短、好写。
- **不适合**：需要区间操作（如区间翻转）、需要可持久化、或者出题人专门卡替罪羊的题目。

## 常见陷阱与注意事项

- `ALPHA` 别取得太接近 $1$（退化成链）或太小（重构过于频繁），$0.7\sim0.8$ 是经验值。
- `rebuild` 必须先清空 `ls`/`rs`，否则旧指针会让 `build` 建出的树带上环。
- `rebuild(int &b)` 用引用传参，调用时直接写 `rebuild(b)` 就能改掉父节点指向的子树根。
- 插入/删除回溯时每个节点都要检查平衡，漏掉某一层可能让失衡一直积累。
- 删除采用「抄右子树最小值」的方式，若树中允许重复键值，要注意重复元素的处理。
- `isping` 里 `wcj[b].sz` 已经包含当前节点，比较的是左右子树大小与整棵子树的比例。
- 本模板不回收被删除的节点，`N` 要按「操作总数」开够。
- 代码里的 `cnt` 是键值不是计数，和某些教材的写法不同。
