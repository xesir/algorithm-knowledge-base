-- ============================================================
-- AKB 专栏种子：知识点 / 数据结构
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：78 行
-- ============================================================
begin;

drop table if exists _akb_seed_columns;
create temp table _akb_seed_columns (
    author_name text not null,
    column_key text not null,
    column_name text not null,
    content text not null,
    category text,
    tags text[],
    parent_key text,
    difficulty text,
    kind text not null
) on commit drop;

insert into _akb_seed_columns (
    author_name, column_key, column_name, content, category, tags, parent_key, difficulty, kind
) values
('stripe-python', 'col-ds-avl-tree--stripe-python', 'AVL 树的扩展应用 · stripe-python', $AKB121$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 前言

AVL 树是工程中常用的平衡树，其在大量查询方面具有优势。然而，AVL 树在 OI 中却没有特别地位。

笔者认为，AVL 树原理简单，比 OI 常用平衡树快很多，码量也不是很大。本文探究 AVL 树在 OI 领域的扩展应用。

## AVL 树原理

AVL 的每个节点维护一个 `high` 域，表示子树的高度。AVL 需要维护 $|high_l-high_r|\le 1$。

## 左旋右旋的引入

注意到，对一棵 BST 结构进行调整是不影响树的合法性的。举个例子：

![](https://cdn.luogu.com.cn/upload/image_hosting/b5m91b3l.png)

这棵 BST 可以调整为：

![](https://cdn.luogu.com.cn/upload/image_hosting/y4eugduh.png)

这就是平衡树的左旋操作。类似地，把上述调整的逆过程称作右旋。

参考代码：

```cpp
static node* left_rotate(node* p) {
    node *q = p->left;
    p->left = q->right, q->right = p, p->pushup();
    return q->pushup();
}
static node* right_rotate(node* p) {
    node *q = p->right;
    p->right = q->left, q->left = p, p->pushup();
    return q->pushup();
}
```

## 如何维护平衡

分类讨论破坏平衡的情况：

1. LL 型（左孩子的左孩子过深），如图：
![](https://cdn.luogu.com.cn/upload/image_hosting/a8gw13qt.png)

解法：右旋节点 $T$。

1. RR 型（右孩子的右孩子过深），解法：类似 LL 型，左旋节点 $T$。
2. LR 型（左孩子的右孩子过深），如图：
![](https://cdn.luogu.com.cn/upload/image_hosting/ls4ionx1.png)
解法：左旋节点 L，成为 LL 型，后右旋节点 T，即左右双旋。
3. RL 型（右孩子的左孩子过深），解法：类似 LR 型，右旋节点 $R$ 后左旋节点 $T$，即右左双旋。

双旋的参考实现：

```cpp
static node* left_right_rotate(node* p) {
    p->left = right_rotate(p->left);
    return left_rotate(p);
}
static node* right_left_rotate(node* p) {
    p->right = left_rotate(p->right);
    return right_rotate(p);
}
```

## 参考实现

[AVL 完整实现](https://www.luogu.com.cn/paste/aq6bsxtp)

## 可持久化

这部分内容摘自 [本蒟蒻的题解](https://www.luogu.com.cn/article/f3qkytzk)。

## 原理介绍

既然[**有旋** Treap](https://www.luogu.com.cn/article/6sbyh6lw) 可持久化，同样使用旋转维护平衡的 AVL 树也可以可持久化。

每一次旋转、插入、删除时，我们复制一份 AVL 节点，见代码：

```cpp
static node* left_rotate(node* p) {
    // 左旋节点 p
    node *q = p->left;
    p->left = copy(p->left);   // Added
    p->left = q->right, q->right = p, p->pushup();
    return q->pushup();
}
static node* right_rotate(node* p) {
    // 右旋节点 p
    node *q = p->right;
    p->right = copy(p->right);   // Added
    p->right = q->left, q->left = p, p->pushup();
    return q->pushup();
}
```

## 参考实现

[可持久化 AVL 完整实现](https://www.luogu.com.cn/paste/qpa5u9rf)

## 文艺平衡树

## 原理介绍

思考一下 Splay 树如何实现文艺平衡树。

做法是把 $a_{l-1}$ splay 到根，再把 $a_{r+1}$ splay 到根的右孩子。则 $a_{r+1}$ 的左节点就代表这段区间。

由于 AVL 树高为严格 $O(\log n)$，可以使用类 Splay 操作把节点旋转到根。为了维护平衡，还需要把节点转回去，需要 $4$ 次类 Splay，但是很难写常数还大。$AKB121$, '数据结构', array['AVL树', '平衡树', 'BST'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('stripe-python', 'col-ds-balanced-tree-overview--stripe-python', '平衡树综述 · stripe-python', $AKB122$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 引入

这是一道数据结构题。

维护一个数列，支持插入、删除、查排名、查数、前驱、后继。

以下，用 $n$ 表示操作数，$w$ 表示值域。

## Subtask 1：n≤103n \le 10^3n≤103

暴力 $O(n^2)$ 维护即可。

## Subtask 2：n≤104n \le 10^4n≤104

采用 `std::vector` 和二分维护一个有序序列。由于 `memmove` 的小常数，可以卡常通过。

## Subtask 3：n≤105,w≤105n \le 10^5, w \le 10^5n≤105,w≤105

权值线段树的模板。前驱后继用 `std::map` 维护即可，时空复杂度均为 $O(n \log w)$。

## Subtask 4：n≤105,w≤109n \le 10^5, w \le 10^9n≤105,w≤109

把数字离散化后按 Subtask 3 的做法即可。

## Subtask 5：n≤105,w≤109n \le 10^5, w \le 10^9n≤105,w≤109，强制在线

这种时候就需要请出平衡树了。

## 平衡树的目的

## 引入 BST

首先，我们介绍一种数据结构，二叉搜索树（Binary Search Tree），简称 **BST**。

让我们回顾二分查找的过程：

```cpp
int l = 1, r = n;
while (l <= r) {
    int mid = (l + r) >> 1;
    if (a[mid] == target) return mid;
    if (a[mid] < target) l = mid + 1;
    else r = mid - 1;
}
```

如果我们维护 $a$ 数组有序，则查询复杂度为 $O(\log n)$。

但是，维护 $a$ 数组有序的代价是 $O(n)$ 的，所以我们想到把这个查找过程上树。这样就出现了 BST 这种数据结构。

BST 的定义如下：

BST 是一棵二叉树，树中每个节点存储数值，数值不重；对于任意节点的孩子，其左孩子的值小于它的值，其右孩子的值大于它的值。

例如，把 $1, 2, 3, 4, 5, 6$ 建出一棵 BST 可以是这样的：

![](https://cdn.luogu.com.cn/upload/image_hosting/nguctn8p.png)

现在来考虑其他操作：

### 插入操作

BST 的结构十分适合二分。二分找到适合这个值的位置，新建节点即可。

如果要维护可重集，需要在节点中增加 `cnt` 域，如果节点存在则将 `cnt` 加一。由于 OI 中大部分情况需要维护可重集，下文默认 `cnt` 域的存在。

### 各种遍历

由于 BST 是二叉树，对其进行前序、中序、后序遍历都是可行的。BST 常用的是中序遍历。

> BST 的性质：中序遍历一定有序。

简证：设 $p$ 为根，$l, r$ 为 $p$ 的左右孩子，则中序遍历为 $l, p, r$，由 BST 定义知 $l < p < r$，得证。

中序遍历参考实现如下，其余同理。

```cpp
std::vector<T> inorder() const {
    if (!root) return {};
    std::vector<T> res; res.reserve(size());

    std::function<void(const node*)> dfs = [&](const node* x) -> void {
        if (!x) return;
        dfs(x->left);
        for (int i = 1; i <= x->cnt; i++) res.emplace_back(x->val);
        dfs(x->right);
    };
    dfs(root);
    return res;
}
```

特别地，为方便调试，我实现了一个 `prettify` 函数。

```cpp
std::string prettify(int tabs = 4, char fill = ' ') const {
    if (!root) return "";
    std::stringstream ss;
    ss << root->val << '(' << root->cnt << ")\n";

    std::string fill1, fill2;
    for (int i = 1; i < tabs; i++) fill1.push_back(fill);
    for (int i = 1; i <= tabs; i++) fill2.push_back(fill);

    std::function<void(const node*, int, std::vector<int>)> dfs =
        [&](const node* x, int depth, std::vector<int> sites) -> void {
        int void_num = 0;
        for (node* child : {x->left, x->right}) {
            if (!child) continue;
            int n = depth - void_num - (int) sites.size();
            std::vector<std::string> str_list;
            str_list.reserve(n << 1);
            for (int i = 1; i <= n; i++) str_list.push_back("│" + fill1);
            for (int site : sites) {
                str_list.insert(str_list.begin() + site, fill2);
            }
            if (x->right && child != x->right) {
                str_list.emplace_back("\u251c\u2500\u2500 ");
            } else {
                str_list.emplace_back("\u2514\u2500\u2500 ");
                void_num++, sites.push_back(depth);
            }

            std::string out;
            for (const std::string& s : str_list) out += s;
            ss << out << child->val << '(' << child->cnt << ")\n";

            dfs(child, depth + 1, sites);
            if (child == x->right) void_num--, sites.pop_back();
        }
    };
    dfs(root, 0, {});
    return ss.str();
}
```

它的显示大概长这样：

```dns
415495(0)
├── 265337(1)
│   ├── 208361(1)
│   │   ├── 107323(1)
│   │   │   ├── 60423(1)
│   │   │   └── 127077(1)
│   │   └── 260553(1)
│   └── 376755(1)
│       ├── 299181(1)
│       └── 413857(1)
└── 543050(1)
    ├── 460416(1)
    │   ├── 430219(1)
    │   └── 510033(1)
    └── 691707(1)
        ├── 632641(1)
        │   ├── 599175(1)
        │   │   └── 602133(1)
        │   └── 676499(1)
        └── 838037(1)
            ├── 705510(1)
            └── 926433(1)
                └── 957395(1)
```

### 查询操作

与插入类似，用一种类似二分的方法找到节点即可。

```cpp
node* find(const T& val) const {
    node* cur = root;
    while (cur && val != cur->val) {
        cur = cmp(val, cur->val) ? cur->left : cur->right;
    }
    return cur;
}
```

### 查询最值操作

根据 BST 中序遍历的性质，最小值是中序遍历的第一个数，最大值是中序遍历的最后一个数。

中序遍历的方法是左、中、右，所以最小值由根节点开始走左链，最大值由根节点开始走右链即可。

```cpp
static node* get_min(node* cur) {
    node *x = cur;
    while (x && x->left) x = x->left;
    return x;
}
static node* get_max(node* cur) {
    node *x = cur;
    while (x && x->right) x = x->right;
    return x;
}
```

### 前驱后继操作

先讲这个是为了理解删除。

一个数的前驱定义为 BST 中比他小的数的最大值。同理，一个数的后驱定义为 BST 中比他大的数的最小值。这个数不一定在 BST 中。有点类似 `lower_bound` 和 `upper_bound`。

以下只说前驱的实现，后继同理。

我们从根节点开始遍历，如果当前数比查询数小，则更新答案，并在右子树搜索；否则在左子树搜索。

思考这样为什么是对的：

1. 答案小于查询数。由于我们在当前数比查询数小时更新答案，因此除非不存在任何一个比它小的数，否则答案一定小于查询数。
2. 答案是小于查询数的最小值。在当前数比查询数小时往更大的右子树搜索可以保证这一点。

参考实现如下。

```cpp
T lower_bound(const T& val) const {
    node *cur = root;
    T res = T();
    while (cur) {
        if (cmp(cur->val, val)) res = cur->val, cur = cur->right;
        else cur = cur->left;
    }
    return res;
}
T upper_bound(const T& val) const {
    node *cur = root;
    T res = T();
    while (cur) {
        if (cmp(val, cur->val)) res = cur->val, cur = cur->left;
        else cur = cur->right;
    }
    return res;
}
```

### 删除操作

BST 的删除比较复杂。 甚至比很多平衡树复杂。

先找到这个节点。设节点为 $p$，分类讨论：

1. $p$ 的 $cnt$ 大于 $1$，把 $cnt$ 减一即可。
2. 若 $p$ 为叶子节点，直接删除。
3. 若 $p$ 只有一个孩子，将这个孩子上提即可，不影响 BST 的结构。（可以根据 BST 的中序遍历思考为什么）
4. 若 $p$ 有两个孩子，将右子树的最小值上提替代它。（类似于后继，但只看两个孩子而不看父亲）

对于情况 $4$，注意替换节点后删除右子树的最小值。

参考实现：

```cpp
bool remove_node(node*& cur) {
    if (!cur) return false;
    if (cur->cnt > 1) {
        cur->cnt--, cur->pushup();
        return true;
    }
    if (cur->left && cur->right) {
        node* replace = this->get_min(cur->right);
        cur->cnt = replace->cnt, cur->val = replace->val;
        replace->cnt = 1;
        remove(cur->right, replace->val);
    } else {
        cur = cur->left ? cur->left : cur->right;
    }
    if (cur) cur->pushup();
    return true;
}
bool remove(node*& cur, const T& val) {
    if (!cur) return false;
    if (val == cur->val) return remove_node(cur);
    bool res;
    if (cmp(val, cur->val)) res = remove(cur->left, val);
    else res = remove(cur->right, val);
    if (cur) cur->pushup();
    return res;
}
```

### 排名相关

如果只有上面的操作，为什么不用 `std::multiset` 呢？这就要说到平衡树的重要操作——排名查询了。

平衡树模板题中将排名定义为比查询数小的数的个数 $+1$。也可以说一个数的排名是它的中序遍历中的位置。下面的参考实现中，排名从 $0$ 开始。（即：排名定义为比查询数小的数的个数。）

如何实现排名操作？考虑权值线段树的做法。在每个节点维护一个 `size`，即这个子树中数的个数。这就需要维护 `size` 了。也许你看到上面的代码中有 `pushup` 操作，这就是维护 `size` 的操作。

```cpp
BinarySearchTreeNode<T>* pushup() {
    size = cnt + (left ? left->size : 0) + (right ? right->size : 0);
    return this;
}
```

#### 根据数查询排名

从根节点搜到这个数，记录路径。

令 $s$ 为当前节点左子树的大小，$c$ 为当前节点的 $cnt$。

若在路径中向右搜了，则答案加上 $s+c$。最终的答案还要加上 $s + 1$。

这很适合递归。参考实现：

```cpp
int rank(node* cur, const T& val) const {
    if (!cur) return 1;
    int left_size = cur->left ? cur->left->size : 0;
    if (val == cur->val) return left_size + 1;
    if (cmp(val, cur->val)) return rank(cur->left, val);
    return rank(cur->right, val) + left_size + cur->cnt;
}
```

#### 根据排名查询数

上述操作逆过来即可。

```cpp
T kth(node* cur, int k) const {
    if (!cur) return T();
    int left_size = cur->left ? cur->left->size : 0;
    if (left_size >= k) return kth(cur->left, k);
    if (left_size < k - cur->cnt) return kth(cur->right, k - left_size - cur->cnt);
    return cur->val;
}
```

### 建树

简单说一下，在替罪羊的重构有用。实际上很少这么做。

令序列为 $a$。如果序列有序，考虑分治。

如果当前处理的区间为 $[l,r]$，设 $mid=\lfloor \dfrac{l+r}{2} \rfloor$，以 $a_{mid}$ 为根，左右孩子分别为 $[l,mid-1]$ 到 $[mid+1,r]$。

建树是 $O(n)$ 的。但是由于排序也有 $O(n \log n)$，因此实现中直接调用插入函数，复杂度也是 $O(n \log n)$，常数稍大。

### 完整实现

[BST 完整实现](https://www.luogu.com.cn/paste/octpkjd3)

## 应用

平衡树最大的应用是维护有序集合。或者说，我们给 `std::multiset` 添加了 $O(\log n)$ 的排名操作。

除此之外，由于 `splay` 和 `fhq-treap` 的一些特性，平衡树可以用来支持区间操作。`splay` 是 `LCT` 的基础。

## 优化

你遇到了数据随机的平衡树模板。你敲了 BST 上去，A 掉了这道水题。

你遇到了加强版。听取 TLE 声一片。

注意到，BST 在最坏情况下会退化为一个有序链表。例如，执行下面的操作：

```cpp
insert(1, 2, 3, 4, 5, 6, 7);
```

BST 的形态如下：

![](https://cdn.luogu.com.cn/upload/image_hosting/a7l2oiu5.png)

如果维护有序链表，复杂度和暴力相同，是 $O(n)$ 的。

可以证明，在随机数据下，BST 的期望树高是 $O(\log n)$ 的。一般情况下，我们用 $O(h)$ 表示 BST 的复杂度，$h$ 是树高。为了防止 $h$ 退化到 $O(n)$，就需要引出平衡树了。

## AVL

根据上面的思路，可以引出 AVL。

AVL 的每个节点维护一个 `high` 域，表示子树的高度。AVL 需要维护 $|high_l-high_r|\le 1$。

## 左旋右旋的引入

注意到，对一棵 BST 结构进行调整是不影响树的合法性的。举个例子：

![](https://cdn.luogu.com.cn/upload/image_hosting/b5m91b3l.png)

这棵 BST 可以调整为：

![](https://cdn.luogu.com.cn/upload/image_hosting/y4eugduh.png)

这就是平衡树的左旋操作。类似地，把上述调整的逆过程称作右旋。

参考代码：

```cpp
static node* left_rotate(node* p) {
    node *q = p->left;
    p->left = q->right, q->right = p, p->pushup();
    return q->pushup();
}
static node* right_rotate(node* p) {
    node *q = p->right;
    p->right = q->left, q->left = p, p->pushup();
    return q->pushup();
}
```

## 如何维护平衡

分类讨论破坏平衡的情况：

1. LL 型（左孩子的左孩子过深），如图：
![](https://cdn.luogu.com.cn/upload/image_hosting/a8gw13qt.png)

解法：右旋节点 $T$。

1. RR 型（右孩子的右孩子过深），解法：类似 LL 型，左旋节点 $T$。
2. LR 型（左孩子的右孩子过深），如图：
![](https://cdn.luogu.com.cn/upload/image_hosting/ls4ionx1.png)
解法：左旋节点 L，成为 LL 型，后右旋节点 T，即左右双旋。
3. RL 型（右孩子的左孩子过深），解法：类似 LR 型，右旋节点 $R$ 后左旋节点 $T$，即右左双旋。

双旋的参考实现：

```cpp
static node* left_right_rotate(node* p) {
    p->left = right_rotate(p->left);
    return left_rotate(p);
}
static node* right_left_rotate(node* p) {
    p->right = left_rotate(p->right);
    return right_rotate(p);
}
```

## 代码修改

首先，加入一个 `get_high` 函数防止空指针。

```cpp
static long get_high(node* p) {return p ? p->high : 0;}
```

### 修改 insert 操作

```cpp
if (cmp(val, cur->val)) {
    insert(cur->left, val), cur->pushup();
    if (get_high(cur->left) - get_high(cur->right) >= 2) {
        cur = cmp(val, cur->left->val) ?
            left_rotate(cur) : left_right_rotate(cur);
    }
} else {
    insert(cur->right, val), cur->pushup();
    if (get_high(cur->right) - get_high(cur->left) >= 2) {
        cur = cmp(val, cur->right->val) ?
            right_left_rotate(cur) : right_rotate(cur);
    }
}
```

改动搜索部分，调整平衡。

### 修改 remove 操作

`remove` 相对难改一点。为了方便，我把代码全部展示出来，添加的代码用注释标注。

```cpp
bool remove_node(node*& cur) {
    if (!cur) return false;
    if (cur->cnt > 1) {
        cur->cnt--, cur->pushup();
        return true;
    }
    if (cur->left && cur->right) {
        node* replace = this->get_min(cur->right);
        cur->cnt = replace->cnt, cur->val = replace->val;
        replace->cnt = 1;
        remove(cur->right, replace->val), cur->pushup();
        if (get_high(cur->left) - get_high(cur->right) >= 2) { // Added
            cur = (get_high(cur->left->left) >= get_high(cur->left->right)) ? // Added
                left_rotate(cur) : left_right_rotate(cur); // Added
        } // Added
    } else {
        cur = cur->left ? cur->left : cur->right;
    }
    if (cur) cur->pushup();
    return true;
}
bool remove(node*& cur, const T& val) {
    if (!cur) return false;
    if (val == cur->val) return remove_node(cur);
    bool res;
    if (cmp(val, cur->val)) {
        res = remove(cur->left, val), cur->pushup();
        if (get_high(cur->right) - get_high(cur->left) >= 2) { // Added
            cur = get_high(cur->right->right) >= get_high(cur->right->left) ? // Added
                right_rotate(cur) : right_left_rotate(cur); // Added
        } // Added
    } else {
        res = remove(cur->right, val), cur->pushup();
        if (get_high(cur->left) - get_high(cur->right) >= 2) { // Added
            cur = get_high(cur->left->left) >= get_high(cur->left->right) ? // Added
                left_rotate(cur) : left_right_rotate(cur); // Added
        } // Added
    }
    if (cur) cur->pushup();
    return res;
}
```

其他操作和 BST 毫无区别。

## 完整实现

[AVL 完整实现](https://www.luogu.com.cn/paste/s553l03d)

## 闲谈

AVL 的常数比较大。但是，对于 OI 中常用的平衡树（Splay 和 Treap），它的性能还是比较好的。

其实我个人比较喜欢 AVL。AVL 只要把 BST 写出来了基本上就不会写挂，码量比起 BST 也就增加了五十行。而且 AVL 的节点调整有种解魔方的感觉，记住了基本挂不了。

AVL 的最大优势是查询。AVL 只在修改时作旋转，所以 AVL 的查询跑得飞快。

## Treap

## 定义

Treap 是 BST 与堆的结合。具体来说，Treap 是堆关键字随机的笛卡尔树。

Treap 的节点额外定义了 `prio` 域，初始化为随机值。Treap 的每个节点除了满足 BST 的定义外，还要保证父节点的 `prio` 小于孩子的 `prio`。即：`val` 上维护 BST 性质，`prio` 上维护小根堆性质。

可以证明，这样做的复杂度是期望 $O(\log n)$ 的。

## 性质维护

如何维护 `prio` 的性质？

把 AVL 的左旋右旋抄过来：

```cpp
static node* left_rotate(node* p) {
    node* q = p->right;
    p->right = q->left, q->left = p, p = q;
    p->left->pushup();
    return p->pushup();
}
static node* right_rotate(node* p) {
    node* q = p->left;
    p->left = q->right, q->right = p, p = q;
    p->right->pushup();
    return p->pushup();
}
```

填加一个 `get_prio` 函数防止空指针：

```cpp
static long get_prio(node* cur) {return cur ? cur->prio : 0;}
```

其实，Treap 的核心维护就是这两种逻辑：

1. 当左子树的 `prio` 小于当前节点的，进行右旋；
2. 当右子树的 `prio` 小于当前节点的，进行左旋。

```cpp
if (get_prio(cur->left) < get_prio(cur)) cur = right_rotate(cur);
if (get_prio(cur->right) < get_prio(cur)) cur = left_rotate(cur);
```

修改 `insert` 函数如下：

```cpp
void insert(node*& cur, const T& val) {
    ...
    if (cmp(val, cur->val)) {
        insert(cur->left, val), cur->pushup();
        if (get_prio(cur->left) < get_prio(cur)) cur = right_rotate(cur);
    } else {
        insert(cur->right, val);
        if (get_prio(cur->right) < get_prio(cur)) cur = left_rotate(cur);
    }
    cur->pushup();
}
```

对于删除操作，除了 BST 的分类讨论，还要根据 `prio` 让 `prio` 小的当父节点。

```cpp
bool remove_node(node*& cur) {
    if (!cur) return false;
    if (cur->cnt > 1) {
        cur->cnt--, cur->pushup();
        return true;
    }
    if (cur->left || cur->right) {
        T val = cur->val;
        if (!cur->right || get_prio(cur->left) > get_prio(cur->right)) {
            cur = right_rotate(cur);
            remove(cur->right, val);
        } else {
            cur = left_rotate(cur);
            remove(cur->left, val);
        }
        return cur->pushup(), true;
    }
    return cur = nullptr, true;
}
```

这个删除甚至比 BST 简单。

## 完整实现

[Treap 实现](https://www.luogu.com.cn/paste/8n0a665t)

## 闲谈

有旋 Treap 好像工程应用不多，但在 OI 中是应用最多的平衡树之一。实现了 BST 可以很方便地实现 Treap，而且 Treap 常数小，值得学习。

Treap 的另一个优点是它可持久化，可单调栈 $O(n)$ 建树等。总之，Treap 是好写、好用的平衡树。

## FHQ-Treap

FHQ-Treap 又称无旋 Treap，是 OI 界平衡树的主力。

## 优缺点

在 FHQ-Treap 前，先了解一下优缺点：

优点：

1. 码量非常少（甚至少写点功能能比 BST 还少）
2. 不容易写挂
3. 支持区间操作
4. 支持可持久化
5. 天然支持分裂、合并
6. 支持线性建树

缺点：

1. 常数大（常用平衡树里最慢的）
2. 维护 LCT 不如 Splay 优秀（多了一个 $\log$）

总的来说，FHQ-Treap 还是值得学习的。

## 性质维护

如它的名字，FHQ-Treap 满足 Treap 的性质。但是，FHQ-Treap 采用不同的性质维护方法——分裂和合并。这就是它为什么可以维护区间操作。

### 分裂

其实 BST 这种数据结构天然支持分裂。我们实现两个函数，`lower_split` 表示把小于查询值和大于等于查询值的树分裂，`upper_split` 表示把小于等于查询值和大于查询值的树分裂。

> 注：市面上常见的 FHQ-Treap 写法是用 `lower_split(x - 1)` 替代 `upper_split(x)`。这样可以减少码量，但我本人喜欢这么写。

考虑如何实现 `lower_split`，令 `lower_split` 返回分裂后的两棵树。根据查询值搜索：

1. 当前值大于等于查询值。此时，当前节点的右子树的全部值大于查询值，归入第二棵树，对左子树进行分裂即可。
2. 当前值小于查询值。此时，当前节点的左子树的全部值小于查询值，归入第一棵树，对右子树进行分裂即可。

`upper_split` 将分类讨论中的大于等于改为大于，小于改为小于等于即可。

在常用实现中，由于 C++14 不支持解包，用引用返回两棵树比较方便。

```cpp
void lower_split(node* cur, const T& val, node*& x, node*& y) {
    if (!cur) return (void) (x = nullptr, y = nullptr);
    if (!cmp(val, cur->val)) {  // cur->val >= val
        x = cur, lower_split(x->right, val, x->right, y);
        x->pushup();
    } else {
        y = cur, lower_split(y->left, val, x, y->left);
        y->pushup();
    }
}
void upper_split(node* cur, const T& val, node*& x, node*& y) {
    if (!cur) return (void) (x = nullptr, y = nullptr);
    if (val != cur->val && !cmp(val, cur->val)) {  // cur->val >= val
        x = cur, upper_split(x->right, val, x->right, y);
        x->pushup();
    } else {
        y = cur, upper_split(y->left, val, x, y->left);
        y->pushup();
    }
}
```

### 合并

合并操作是 FHQ-Treap 的重点。合并有点类似线段树的合并，但要维护 Treap 的堆性质。可以证明，这样做的期望时间复杂度是 $O(\log n)$ 的。

合并函数接收两棵树，其中第一棵树的所有值小于第二棵树的所有值。合并时，只需将 `prio` 小的上提，递归合并其子树即可。

```cpp
node* merge(node* x, node* y) {
    if (!x || !y) return x ? x : y;
    if (x->prio < y->prio) {
        x->right = merge(x->right, y);
        return x->pushup();
    } else {
        y->left = merge(x, y->left);
        return y->pushup();
    }
}
```

## 操作维护

### 插入操作

理论上，插入操作可以抄 Treap 的。但是，既然写了 FHQ-Treap，有更简单的办法。

我们把整棵树按插入值 `lower_split` 成两部分，则第一棵树中所有值小于等于插入值，第二棵树中所有值大于插入值，在两棵树之间新建节点，合并即可。

需要注意，FHQ-Treap 为简便可以不维护 `cnt` 域，挂重复节点即可。

```cpp
void insert(const T& val) {
    if (!root) {
        root = new node(val);
        return;
    }
    node *x, *y; lower_split(root, val, x, y);
    root = merge(merge(x, new node(val)), y);
}
```

### 删除操作

按删除值 `split` 成三段：小于删除值的、等于删除值的、大于删除值的。删除等于删除值的节点即可。

```cpp
bool remove(const T& val) {
    node *x, *y, *z;
    lower_split(root, val, x, z);
    upper_split(x, val, x, y);
    if (!y) return false;
    y = merge(y->left, y->right);
    root = merge(merge(x, y), z);
    return true;
}
```

### 查询排名

按查询值 `upper_split`。由于排名是比它小的数的数量，查第一棵树的 `size` 即可。

```cpp
int rank(const T& val) {
    node *x, *y; upper_split(root, val, x, y);
    int rnk = x ? x->size : 0;
    root = merge(x, y);
    return rnk;
}
```

## 完整实现

[FHQ-Treap 完整实现](https://www.luogu.com.cn/paste/eklxjrl4)

## 闲谈

FHQ-Treap 非常好写，还可持久化，可维护区间，也很好学。

但是它的常数很大，使用时，需要注意时限。同时，FHQ-Treap 也可以维护 `cnt` 域（见 OI-Wiki 的实现），使平衡树结构更为严谨。

## Splay

大多数 OI 选手学习的平衡树。支持区间操作和维护 LCT，本身常数较大，不支持可持久化。

## 性质维护

Splay 维护平衡的操作很简单：每一个被访问的节点都旋转到根。这一操作即 splay 操作。复杂度证明见 [OI-Wiki](https://oi-wiki.org/ds/splay/#splay-%E6%93%8D%E4%BD%9C%E7%9A%84%E6%97%B6%E9%97%B4%E5%A4%8D%E6%9D%82%E5%BA%A6)。

splay 操作基于左旋和右旋操作。可以去 AVL 树看一看。

splay 操作中的每次旋转是一次 splay 步骤。splay 步骤的目的是把该节点旋转到距离根更近的位置。

我们令该节点为 $x$，父节点为 $fa$，祖父节点为 $g$，分类讨论：

1. $fa$ 为根节点，直接左旋或右旋 $x$。
2. $fa$ 不是根节点，且 $fa,x,g$ 共线，对 $g$ 做左旋或右旋，$x$ 反之；
3. $fa$ 不是根节点，且 $fa,x,g$ 不共线，对 $x$ 做双旋。

通过这些步骤，可以完成 splay。代码比想象的精简很多，利用奇偶可以方便地完成。

```cpp
static void rotate(node*& x) {
    node *y = x->parent, *z = y ? y->parent : nullptr;
    bool chk = x->get();
    y->child(chk) = x->child(chk ^ 1);
    if (x->child(chk ^ 1)) x->child(chk ^ 1)->parent = y;
    x->child(chk ^ 1) = y;
    y->parent = x, x->parent = z;
    if (z) z->child(y == z->right) = x;
    y->pushup(), x->pushup();
}
node* splay(node*& x) {
    for (node* fa = x->parent; (fa = x->parent); rotate(x)) {
        if (fa->parent) rotate(x->get() == fa->get() ? fa : x);
    }
    return root = x;
}
```

## 修改 insert 操作

为了 `insert` 以后还能 splay，我们采用迭代实现。

```cpp
void insert(const T& val) {
    if (!root) {
        root = new node(val);
        return;
    }
    node *cur = root, *fa = nullptr;
    while (cur) {
        if (cur && val == cur->val) {
            cur->cnt++, cur->pushup();
            if (fa) fa->pushup();
            splay(cur);
            return;
        }
        fa = cur, cur = cmp(val, cur->val) ? cur->left : cur->right;
    }
    cur = new node(val), cur->parent = fa;
    if (cmp(val, fa->val)) fa->left = cur;
    else fa->right = cur;
    cur->pushup(), fa->pushup();
    splay(cur);
}
```

## 修改 remove 操作

前置知识：如何合并两棵 splay 树？第一棵树的所有元素小于第二棵的所有元素。

---

我们只需要把第一棵树中的最大值 splay 到根，将其右孩子设置为第二棵树的根即可。

把该节点 splay 到根。分类讨论：

1. 单节点，直接删除；
2. 缺一个孩子，将另一个上提替代；
3. 有两个孩子，合并两棵子树即可（看看前置知识）。

```cpp
bool remove(const T& val) {
    if (!splay(val)) return false;
    node *cur = root;
    if (cur->cnt > 1) {
        cur->cnt--, cur->pushup();
        return true;
    }
    if (!cur->left && !cur->right) {
        delete cur;
        root = nullptr;
        return true;
    }
    if (!cur->left) {
        root = cur->right;
        root->parent = nullptr;
    } else if (!cur->right) {
        root = cur->left;
        root->parent = nullptr;
    } else {
        node* pre = root_pre();
        cur->right->parent = pre, pre->right = cur->right;
        root->pushup();
    }
    delete cur;
    return true;
}
```

其他还有一些修改。看代码即可理解。

[Splay 完整实现](https://www.luogu.com.cn/paste/icu3wgc5)

## 闲谈

Splay 的结构使其容易维护区间操作。维护 LCT 时也常用这种平衡树的魔改版（甚至码量还更小）。

但是常数确实大（也许是我实现的原因），和 FHQ-Treap 差不多了。

## 其他平衡树

## 替罪羊树

如果失衡就暴力重构。复杂度均摊 $O(\log n)$。

## WBLT

其实这东西已经不是 BST 了。

一种 Leafy Tree，常数小，可以维护区间操作，支持可持久化，是好东西。没看懂。

## 红黑树

工程中平衡树的主力，常数小。本质是 B 树变形。没看懂。

红黑树有一些变形，如左偏红黑树或 AA 树。码量也较多。

## 平衡树的替代品

这一部分简要介绍一下与 BST 无关的数据结构或 C++ 的内置数据结构。

## 块状链表

整体复杂度是 $O(n \sqrt{n})$ 的。

思想就是链表套分块，用一个 `list<vector<T>>` 就可以很方便地维护，整体维护有序。代码量比平衡树小很多。

在块内大小超过 $\sqrt{n}$ 时分裂以维护复杂度。

```cpp
lst.emplace(next(it), it->begin() + (lim >> 1), it->end());
it->erase(it->begin() + (lim >> 1), it->end());
```

[块状链表完整实现](https://www.luogu.com.cn/paste/cm9vhd9j)

## 01-Trie

把数字二进制分解，用字典树维护，本质是值域为 $2^w$ 的权值线段树。常数较小，但是空间带 $\log$。

[这篇题解](https://www.luogu.com.cn/article/4clc84vk)使用类似后缀树的方法将空间压缩到了线性。这样 01-Trie 就能对标平衡树操作了。还能可持久化。

## C++ 内置

### __gnu_pbds::tree

`pbds`  实现了一个平衡树，采用红黑树或 Splay 树。在编写可重平衡树时，使用如下：

```cpp
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>

using namespace __gnu_pbds;
tree<pair<T, int>, null_type, less<pair<T, int>>, rb_tree_tag, tree_order_statistics_node_update> tr;
```

`pair` 的第一个元素存储数据，第二个元素该元素的标号，以维护可重。

详情见 [OI Wiki](https://oi-wiki.org/lang/pb-ds/tree/)，不再赘述。

### __gnu_cxx::rope

`pbds` 的“块状链表”实现。实际上，`rope`  的内部实现是可持久化平衡树，这使它天然支持可持久化。但是，`rope` 常数和空间大，比赛慎用。

```cpp
#include <ext/rope>
using namespace __gnu_cxx;

rope<T> tr;
```

具体使用见 [OI Wiki](https://oi-wiki.org/ds/block-list/#stl-%E4%B8%AD%E7%9A%84-rope)。

## Sorted Containers

`sortedcontainers` 是 Python3 的第三方库，可以实现普通平衡树的功能。

`sortedcontainers` 实现了 `SortedList`，支持各类平衡树的操作。据说复杂度是均摊 $O(\log n)$。

具体方法比较复杂，可以看 [这篇知乎讨论](https://www.zhihu.com/question/593450942)。我试着实现一个 `sorted_vector`，最后放弃了。（因为 `sortedcontainers` 的 Pythonic 拿 C++ 写太难受了）

去平衡树模板题交了几发，发现它根本不像市面上说的与 C++ 速度相当，反而跑得飞慢（也许是 python 的读入慢）。加强版更是听取 TLE 声一片。

- [普通版提交记录](https://www.luogu.com.cn/record/147050148)
- [加强版提交记录](https://www.luogu.com.cn/record/147050387)

## 测试

叠甲：所有测试结果的实现代码均为本人自己的实现（平衡树全部用指针，替罪羊树 $\alpha=0.75$），请勿上升到该数据结构！

## P3369 普通版

| 数据结构 | 总运行时间 |
| --- | --- |
| AVL | 195ms |
| Treap | 213ms |
| 权值线段树 | 247ms |
| FHQ-Treap | 254ms |
| Splay | 289ms |
| 块状链表 | 451ms |

## P6136 加强版

| 数据结构 | 总运行时间 |
| --- | --- |
| AVL | 10.10s |
| Treap | 13.52s |
| Splay | 15.32s |
| FHQ-Treap | 16.20s |
| 权值线段树 | 无法通过（离线算法） |
| 块状链表 | 无法通过（TLE） |$AKB122$, '数据结构', array['平衡树', 'BST', 'Treap', 'Splay', 'AVL'], null, null, 'knowledge'),
('Fohen', 'col-ds-bit-point-range--fenfeng', '树状数组（单点修改区间求和 P3374） · Fohen', $AKB123$## 算法原理

前缀和可以在 $O(1)$ 内回答静态的区间和查询，但它要求序列保持不变。一旦题目加入「单点修改」操作——例如把位置 $x$ 的数加上 $v$——前缀和就失效了：因为 $a[x]$ 的变动会牵动后面所有前缀和 $a[x], a[x+1], \dots, a[n]$，每次修改都要更新 $O(n)$ 个前缀和，$m$ 次操作的总复杂度退化为 $O(nm)$，当 $n, m$ 达到 $10^5$ 量级时就会超时。

树状数组（Binary Indexed Tree，BIT）正是为解决「单点修改 + 区间查询」而设计的数据结构，代码量小，单次操作复杂度为 $O(\log n)$。

它的核心思想是：**任意一段前缀 $[1, n]$ 总能被拆成不超过 $\log n$ 段小区间**，这些小区间依托下标的二进制划分而天然组织成一种树形结构，从而用极简的一维数组维护区间信息，实现低常数、易编写的高效操作。

例如求 $a[1..7]$ 的和，不必逐项累加 $a_1 + a_2 + \cdots + a_7$；若已经知道 $A = a[1..4]$、$B = a[5..6]$、$C = a[7..7]$ 三段的和，那么答案就是 $A + B + C$，三段恰好不重不漏地覆盖 $[1,7]$。

树状数组用一个数组 $c$ 实现这种划分：$c[i]$ 维护的正是区间 $a[i - \text{lowbit}(i) + 1 .. i]$ 的和，即「从 $i$ 向左、长度恰为 $\text{lowbit}(i)$」的一段。其中 $\text{lowbit}(x)$ 定义为 $x$ 二进制表示中最低位的那个 $1$ 所代表的值，例如 $\text{lowbit}(5) = \text{lowbit}(101_2) = 1$，$\text{lowbit}(14) = \text{lowbit}(1110_2) = 2$；在代码里可用补码技巧 $\text{lowbit}(x) = x\ \&\ (-x)$ 求得。

这些 $c[i]$ 之间要么相互包含、要么互不相交，并且 $c[i]$ 的父节点就是 $c[i + \text{lowbit}(i)]$。这构成了修改与查询两条路径的基础：查询时沿 $i - \text{lowbit}(i)$ 向左剥离，修改时沿 $i + \text{lowbit}(i)$ 向上进位。

## 核心公式 / 状态定义与转移方程

**状态定义**：设 $c[i]$ 表示原数组中区间 $a[i - \text{lowbit}(i) + 1 .. i]$ 的元素之和，即节点 $i$ 向左管辖长度恰为 $\text{lowbit}(i)$ 的一段。

**lowbit**：
$$
\text{lowbit}(x) = x\ \&\ (-x)
$$

**父子关系**：$c[i]$ 的父节点是 $c[i + \text{lowbit}(i)]$；任意两个 $c[i]$ 要么包含、要么不交，当 $x < y < x + \text{lowbit}(x)$ 时 $c[x]$ 与 $c[y]$ 互不相交。

**前缀和查询**：求 $[1..x]$ 的和，从 $x$ 出发不断向左跳并累加沿途节点，直到 $i = 0$：

$$
\text{query}(x) = \sum c[i],\quad i = x;\ i \ne 0;\ i \mathrel{-}= \text{lowbit}(i)
$$

其正确性来自 $c[i]$ 的区间左端点是 $i - \text{lowbit}(i) + 1$，因此 $i - \text{lowbit}(i)$ 恰好落在 $c[i]$ 左边第一个尚未被覆盖的区间上，一路向左累加到 $0$ 即可覆盖整个前缀。

**单点修改**：给 $a[x]$ 加上 $v$，需要把所有覆盖到 $x$ 的节点都加上 $v$；这些节点正是 $x$ 沿父关系向上的所有祖先，于是从 $x$ 出发向上跳：

$$
c[i] \mathrel{+}= v,\quad i = x;\ i \le n;\ i \mathrel{+}= \text{lowbit}(i)
$$

**区间和**：利用前缀和相减

$$
\sum_{k=l}^{r} a_k = \text{query}(r) - \text{query}(l - 1)
$$

## 逐行代码解析

> 本知识点来源资料未提供完整可运行的实现代码，以下为树状数组核心操作的代码片段说明。

### 数组约定与 lowbit

```cpp
// c[i]：维护 a[i - lowbit(i) + 1 .. i] 的区间和，下标从 1 开始，0 号位不用
// n：原序列长度
int c[N];
int n;

int lowbit(int x) {
    return x & (-x);   // 补码技巧：取 x 二进制最低位的 1
}
```

- `c[i]` 向左管辖长度为 `lowbit(i)` 的一段，是整棵树唯一的核心数组。
- `x & (-x)` 利用补码（`-x = ~x + 1`）只保留 `x` 最低位的 `1`，例如 `lowbit(14) = 2`。
- 下标从 `1` 开始：`lowbit(0) = 0`，若把 `0` 当起点，`i += lowbit(i)` 会永远停在 `0` 形成死循环。

### 查询前缀和 query

```cpp
int query(int x) {                       // 返回 a[1..x] 的和
    int res = 0;
    for (int i = x; i != 0; i -= lowbit(i)) {
        res += c[i];
    }
    return res;
}
```

- 从 `x` 出发，每步累加 `c[i]`（它覆盖 $[i - \text{lowbit}(i) + 1,\; i]$），再 `i -= lowbit(i)` 跳到左边第一个未覆盖区间的右端。
- 终止条件 `i != 0`：`i` 二进制中 `1` 的个数每步严格减少，最终归 `0` 结束。
- 查询区间 $[l, r]$ 时用 `query(r) - query(l - 1)`。

### 单点修改 add

```cpp
void add(int x, int v) {                 // 令 a[x] += v
    for (int i = x; i <= n; i += lowbit(i)) {
        c[i] += v;
    }
}
```

- 原理：`c[i]` 的父节点是 `c[i + lowbit(i)]`，对 `c[x]` 的修改必须沿父关系向上反映到所有覆盖 `x` 的祖先节点。
- 从 `x` 出发，每步 `i += lowbit(i)` 进位到更高层祖先，循环条件 `i <= n` 保证不越界。
- 每次进位都会让最低位的 `1` 向上进位，`i` 严格增大，至多 $O(\log n)$ 步。

### 例题：用树状数组求逆序对

> 给定一个序列，求其中逆序对的数量。逆序对定义为满足 $i < j$ 且 $a[i] > a[j]$ 的二元组 $(i, j)$。

把每个数看成「下标」，从前往后依次加入序列；加入 $a[i]$ 时，已加入元素共 $i - 1$ 个，其中值大于 $a[i]$ 的个数正是「右端为 $i$」的逆序对数量，累加即得答案。下面仅给出主函数部分：

```cpp
int n, q = 0;
cin >> n;
for (int i = 1; i <= n; i++) {
    cin >> a[i];
    q += (i - 1) - query(a[i]);   // 已加入 i-1 个，减去其中 ≤ a[i] 的个数
    add(a[i], 1);                 // 差值 = 已加入且 > a[i] 的个数，即逆序对贡献
}
cout << q << '\n';
```

- 此时树状数组的下标是「值域」而非「位置」：`add(a[i], 1)` 令值 `a[i]` 的出现次数加 `1`。
- `query(a[i])` 返回已加入元素中值不超过 `a[i]` 的个数，`(i - 1) - query(a[i])` 即「已加入且值大于 $a[i]$」的个数。
- 值域过大时需要先离散化。

### 离散化

当值域很大（例如 $a[i] \le 10^9$）时，直接按值域开树状数组会爆内存。做法是把原值排序去重后，用每个值在有序序列中的名次替换原值，把值域压缩到 $[1, m]$（$m$ 为不同值的个数）：

```cpp
vector<int> a, b;
a.push_back(0);                              // 占住 0 号位，使下标从 1 开始
for (int i = 1; i <= n; i++) {
    int t; cin >> t;
    a.push_back(t);
}
b = a;
sort(a.begin() + 1, a.end());                 // 排序
a.erase(unique(a.begin() + 1, a.end()), a.end());   // 去重
for (int i = 1; i <= n; i++) {
    b[i] = lower_bound(a.begin() + 1, a.end(), b[i]) - a.begin();   // 名次
}
```

- 排序 + 去重后 `a` 保存所有互不相同的值；`b[i]` 通过 `lower_bound` 求出原值对应的名次（$1 \sim m$）。
- 离散化只改变值的表示，不改变元素之间的相对大小关系；相等元素取同名次，符合「严格大于才计逆序对」的计数要求。

## 复杂度分析

- **建树**：若逐个元素调用 `add` 建树，每个元素沿父链向上更新 $O(\log n)$ 次，总复杂度 $O(n \log n)$。
- **单次操作**：`query` 与 `add` 的循环每步都改变 `i` 二进制中至少一个 `1` 的状态，步数不超过 $\lfloor \log_2 n \rfloor + 1$，故单次查询 / 修改均为 $O(\log n)$。
- **总复杂度**：$m$ 次操作共 $O(m \log n)$。
- **空间**：仅一个一维数组 `c`，大小 $n + 1$，即 $O(n)$。

## 适用场景

- **单点修改 + 区间求和**：树状数组最经典的应用，只需在单个位置加值并频繁询问区间和（如 P3374）。
- **求逆序对**：以值域为下标建树状数组，从前往后扫描统计逆序对，$O(n \log n)$。
- **可减信息的前缀维护**：凡是满足「区间答案可由两个前缀答案相减得到」的信息（如前缀和、前缀异或、前缀计数）都能套用。
- **对代码量与常数敏感**：需要短小实现、低常数时，树状数组优于线段树。

## 常见陷阱与注意事项

1. **下标必须从 1 开始**：`lowbit(0) = 0`，若把 `0` 当起点，`add` 中的 `i += lowbit(i)` 会永远停在 `0` 形成死循环，因此 `0` 号位不可用。
2. **数组开 $n + 1$**：因为要用到下标 `n`，`c` 至少开 $n + 1$，开成 $n$ 会越界。
3. **查询区间要减 $l - 1$**：$\sum_{k=l}^{r} a_k = \text{query}(r) - \text{query}(l - 1)$，漏写 `- 1` 会把 $a[l-1]$ 多算进去。
4. **单点修改必须向上更新**：只写 `c[x] = v` 会漏掉所有覆盖 `x` 的祖先节点，必须沿 `i += lowbit(i)` 一路累加。
5. **值域过大要先离散化**：用树状数组求逆序对时下标是值域本身；若 $a[i]$ 达 $10^9$，直接开数组会爆内存，必须先离散化把值域压缩到 $[1, m]$。
6. **注意累加溢出**：当 $n$ 很大、求和可能超过 `int` 范围时，`c` 与查询结果应考虑使用 `long long`。

## 对比与扩展

- **与线段树对比**：树状数组代码更短、常数更小、空间更省（$O(n)$ 对 $O(4n)$），但只能维护「可减」的信息，不支持懒标记、区间修改和复杂合并函数；线段树功能更全但实现更重，树状数组可视为其轻量替代。
- **差分树状数组**：把「区间修改 + 单点查询」通过差分数组转化为「单点修改 + 前缀和查询」，仍复用同一套树状数组框架。
- **逆序对**：以值域建树状数组，扫描时统计逆序对；也可用归并排序实现，但树状数组写法直观。
- **二维树状数组**：把一维树状数组套两层，支持矩阵单点修改 + 子矩阵求和，复杂度 $O(\log^2 n)$。
- **离散化**：值域过大时排序去重再映射名次，是按值域建树状数组 / 权值线段树时的通用前置步骤。$AKB123$, '数据结构', array['数据结构', '树状数组', '单点修改', '区间求和', 'lowbit', '逆序对'], null, null, 'knowledge'),
('Xesir', 'col-ds-bit-point-range--xesir', '树状数组（单点修改 + 区间查询） · Xesir', $AKB124$## 算法原理

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
- 值域大一定要离散化，否则数组直接越界；离散化时注意去重和 `lower_bound` 的下标基准。$AKB124$, '数据结构', array['数据结构', '树状数组', 'lowbit', '单点修改', '区间查询', '逆序对'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-bit-point-range', '树状数组（单点修改 / 区间修改）', $AKB125$## 算法原理

树状数组（Binary Indexed Tree，BIT）的核心是 `lowbit` 运算，即 $\text{lowbit}(i) = i\;\&\;\text{-}i$。在补码表示下，`-i` 等于将 `i` 的二进制各位取反再加一，这一操作会保留 `i` 末尾连续的 0，并把从低位往高位数第一个 1 留下。因此 $i\;\&\;\text{-}i$ 的结果恰好是 `i` 的二进制表示中最低位的 1 所代表的值。例如 `i = 12`（二进制 `1100`），`-i` 在补码下为 `...10100`，$12\;\&\;\text{-}12 = 4$（二进制 `100`），即最低位的 1 在第 2 位（权值 4）。这个值同时决定了 `tree[i]` 所维护的区间长度。

每个 $\text{tree}[i]$ 维护原数组中区间 $[i - \text{lowbit}(i) + 1,\; i]$ 的元素之和。也就是说，下标 `i` 的节点管辖的区间长度正好是 $\text{lowbit}(i)$。这种划分使得整棵树具有优美的性质：下标二进制末尾 0 越多的节点管辖的区间越长，层级越高。例如 $\text{tree}[8]$（$\text{lowbit}=8$）管辖 $[1,8]$，而 $\text{tree}[6]$（$\text{lowbit}=2$）只管辖 $[5,6]$。整棵树并非显式地用指针连接，而是通过下标的二进制位运算隐式地确定父子关系。

**修改操作（向上）**：当对位置 `i` 做单点加法时，需要更新所有管辖了位置 `i` 的节点。从 `i` 出发，每次执行 $i \mathrel{+}= \text{lowbit}(i)$，就跳到下一个能覆盖当前位置的更高级别节点——这相当于把 `i` 二进制末尾连续的 0 所在的那个 1 进位，从而到达一个管辖范围更大的祖先。例如从 `i=5`（`101`）出发：`5→6（110）→8（1000）→16...`，路径上的每个节点都覆盖了位置 5。**查询操作（向下）**：求前缀和 `sum[1..i]` 时，需要把 `[1..i]` 拆成若干段不重叠的 `tree` 节点。从 `i` 出发每次 $i \mathrel{-}= \text{lowbit}(i)$，相当于剥离 `i` 二进制最低位的 1，跳到前一段区间的右端点。例如 `i=7`（`111`）：`7→6→4→0`，依次累加 `tree[7]`（管 `[7,7]`）、`tree[6]`（管 `[5,6]`）、`tree[4]`（管 `[1,4]`），正好覆盖 `[1,7]`。区间和则用前缀和相减得到：$\text{sum}[l..r] = \text{get}(r) - \text{get}(l-1)$。

之所以说树状数组比线段树更高效，是因为：线段树每个节点需要维护左右儿子指针或数组下标关系，常数大、空间需 $4n$；而树状数组仅用一维数组、空间 $n+1$，每次操作只需一个 `while` 循环配合 `lowbit` 跳跃，实现极简、常数极小。代价是树状数组只能维护"可减"的信息（和、可逆加法等），且不支持区间修改的 lazy 标记，灵活性不如线段树。但对于"单点修改 + 区间求和"这一经典场景，树状数组几乎总是最优选择。

## 数据结构图示

以原数组 `a = [1, 3, 5, 7, 9, 11, 13, 15]`（下标 1~8）为例，每个 `tree[i]` 的管辖范围由 `lowbit(i)` 决定：

```
下标 i :   1    2    3    4    5    6    7    8
原数组  :  [1]  [3]  [5]  [7]  [9]  [11] [13] [15]
二进制  :  0001 0010 0011 0100 0101 0110 0111 1000
lowbit  :   1    2    1    4    1    2    1    8

tree[1] = a[1]                    = 1        覆盖 [1,1]   长度1
tree[2] = a[1]+a[2]                = 4        覆盖 [1,2]   长度2
tree[3] = a[3]                     = 5        覆盖 [3,3]   长度1
tree[4] = a[1]+a[2]+a[3]+a[4]      = 16       覆盖 [1,4]   长度4
tree[5] = a[5]                     = 9        覆盖 [5,5]   长度1
tree[6] = a[5]+a[6]                = 20       覆盖 [5,6]   长度2
tree[7] = a[7]                     = 13       覆盖 [7,7]   长度1
tree[8] = a[1]+...+a[8]            = 64       覆盖 [1,8]   长度8

树形结构（父子关系靠 lowbit 进位）：
                    tree[8]
                   /       \
             tree[4]        tree[6]?  (非严格二叉，实际靠位运算)
            /      \
       tree[2]    tree[3]   tree[5]  tree[6]  tree[7]
        |
      tree[1]

修改 a[3] += k 的向上路径:  3 -> 4 -> 8   (lowbit(3)=1->4, lowbit(4)=4->8)
查询 sum[1..7] 的向下路径:  7 -> 6 -> 4 -> 0
                            累加 tree[7]+tree[6]+tree[4] = 13+20+16 = 49
```

可以看到，下标二进制末尾的 0 越多，节点层级越高、管辖范围越大；`lowbit` 把一棵隐式树编码进了下标本身。

## 核心操作详解

### lowbit(i) — 取最低位 1
```cpp
inline int lowbit(int i) { return i & -i; }
```
利用补码 $\text{-}i = \sim i + 1$ 的性质：取反后最低位的 1 变 0、其后所有 0 变 1，再 +1 会向前进位到那个原来的 1 位置，于是 $i\;\&\;\text{-}i$ 只保留了那一位。这是整个数据结构的基石，决定了每个节点管辖的区间长度和跳跃步长。

### init(n) — 建树
```cpp
void init(int n) {
    treearr.resize(n + 1, 0);
    for (int i = 1; i <= n; i++) {
        int x; cin >> x;
        int idx = i;
        while (idx <= n) {
            treearr[idx] += x;
            idx += lowbit(idx);
        }
    }
}
```
对每个读入的元素 `a[i] = x`，沿 `idx += lowbit(idx)` 向上更新所有覆盖位置 `i` 的祖先节点。注意 `treearr` 大小开 `n+1`，下标从 1 开始（`lowbit(0)=0` 会导致死循环，0 号位不用）。这种建树方式的总复杂度为 $O(n \log n)$，也可用前缀和差分做到 $O(n)$，但本实现采用最直观的逐元素更新法。

### add(i, k, n) — 单点修改
```cpp
void add(int i, int k, int n) {
    while (i <= n) {
        treearr[i] += k;
        i += lowbit(i);
    }
}
```
给 `a[i]` 加上 `k`。从 `i` 出发，每次把 `k` 累加到当前节点，再 `i += lowbit(i)` 跳到下一个祖先。循环条件 `i <= n` 保证不越界。由于每步都把 `i` 末尾最低位的 1 进位，`i` 的二进制中 1 的个数严格递减式地变化，至多跳 $O(\log n)$ 次就超出 `n`。

### get(i) — 前缀和查询
```cpp
long long get(int i) {
    long long ans = 0;
    while (i) {
        ans += treearr[i];
        i -= lowbit(i);
    }
    return ans;
}
```
求 `sum[1..i]`。从 `i` 出发，每步累加 $\text{tree}[i]$（它正好覆盖 $[i - \text{lowbit}(i) + 1,\; i]$），再 $i \mathrel{-}= \text{lowbit}(i)$ 剥掉最低位的 1 跳到前一段。循环到 `i == 0` 终止。返回类型用 `long long` 防止求和溢出。区间和 $\text{sum}[l..r] = \text{get}(r) - \text{get}(l-1)$。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷P3374*/
vector<long long> treearr;          // 一维数组充当树，用 long long 防溢出
```

- `treearr` 是唯一的核心数组，用 `vector<long long>` 且下标从 1 开始；`long long` 防止 n 个元素求和溢出 int。
- 0 号位不用：`lowbit(0)=0`，若把 0 当起点，`add` 里的 `i += lowbit(i)` 会永远停在 0 形成死循环。
- `#include<bits/stdc++.h>` 万能头 + `using namespace std` 是竞赛常用写法，省去逐个包含头文件。

### lowbit(i) — 取最低位 1

```cpp
inline int lowbit(int i)
{
	return i & -i;                   // 补码技巧，取最低位的1
}
```

- `i & -i` 利用补码（`-i = ~i + 1`）只保留 `i` 二进制最低位的那个 1 所代表的值，例如 `lowbit(12)=4`。
- 这个值同时决定了 `treearr[i]` 管辖的区间长度，是建树、修改、查询三个操作共同的基石。
- 声明为 `inline` 减少函数调用开销，位运算本身是 $O(1)$。

### init(n) — 建树

```cpp
void init(int n)
{
	treearr.resize(n + 1,0);         // 大小 n+1，下标1..n，0号不用
	for(int i = 1;i <= n;i++)
	{
		int x;
		cin >> x;                    // 读入 a[i]
		int idx = i;
		while(idx <= n)               // 沿祖先链向上更新
		{
			treearr[idx] += x;        // 所有覆盖位置 i 的节点都加上 x
			idx += lowbit(idx);       // lowbit 进位跳到下一个祖先
		}
	}
}
```

- `resize(n+1,0)` 开到 n+1，因为要用到下标 n；循环 `i` 从 1 到 n（含 n），0 号位跳过。
- 每读入一个 `a[i]=x`，从 `idx=i` 沿 `idx += lowbit(idx)` 向上走，把 x 累加到所有覆盖位置 i 的祖先节点上。
- 不能只写 `treearr[i]=x`：那样只填了叶子，祖先节点会缺数据；必须一路向上累加。
- 这种逐元素建树总复杂度 $O(n\log n)$。

### add(i, k, n) — 单点修改

```cpp
void add(int i, int k,int n)        // 单点修改：a[i] += k
{
	while(i <= n)                    // 不越界
	{
		treearr[i] += k;             // 当前节点加 k
		i += lowbit(i);              // 跳到下一个覆盖 i 的祖先
	}
}
```

- 给 `a[i]` 加上 k：从 i 出发，先把 k 累加到当前节点，再 `i += lowbit(i)` 跳到下一个覆盖 i 的祖先。
- 循环条件 `i <= n` 保证下标不越界；`i += lowbit(i)` 每次都让最低位 1 进位、数值严格增大，迟早超过 n 而终止，至多 $O(\log n)$ 步。

### get(i) — 前缀和查询

```cpp
long long get(int i)                // 前缀和查询 sum[1..i]
{
	long long ans = 0;
	while(i)                         // i==0 时结束（lowbit(0)=0 无法继续）
	{
		ans += treearr[i];           // 累加当前节点覆盖的区间
		i -= lowbit(i);              // 剥掉最低位的1，跳到前一段
	}
	return ans;
}
```

- 求 `sum[1..i]`：每步累加 `treearr[i]`（它正好覆盖区间 $[i-\text{lowbit}(i)+1,\; i]$），再 `i -= lowbit(i)` 剥掉最低位的 1，跳到前一段。
- 循环条件 `while(i)`：`i` 的 popcount 每步严格递减，迟早归 0 终止；这也是下标必须从 1 开始的原因。
- 返回类型用 `long long`，防止 n 个 int 求和溢出。

### main — 读入与调度

```cpp
int main()
{
	ios::sync_with_stdio(false);     // 关同步，加速 cin
	cin.tie(nullptr);cout.tie(nullptr);
	int n,m;
	cin >> n >> m;                   // n 个数，m 次操作
	init(n);                         // 建树
	for(int i = 0;i < m;i++)
	{
		int op,x,y;
		cin >> op >> x >> y;
		if(op == 1) add(x,y,n);       // 操作1：a[x] += y
		else cout << get(y) - get(x - 1) << '\n'; // 操作2：查询 [x,y] 的和
	}
	return 0;	
}
```

- `ios::sync_with_stdio(false)` 关同步、`cin.tie(nullptr)` 解绑，加速大量输入输出。
- 先读入 n、m，再 `init(n)` 建树；之后循环 m 次处理操作。
- `op==1` 调用 `add(x,y,n)` 做单点修改；否则输出 `get(y)-get(x-1)`，即区间和 = 两个前缀和相减。
- 当 `x=1` 时 `get(0)` 因 `while(0)` 不进循环而返回 0，查询 `[1,y]` 依然正确，无需特判。

## 复杂度分析

- **时间**：`lowbit` 是 $O(1)$。`add` 和 `get` 的 `while` 循环每步都会改变 `i` 二进制中至少一个 1 的状态，至多走 $\lfloor \log_2 n \rfloor + 1$ 步，故单次操作 $O(\log n)$。建树 $O(n \log n)$，处理 m 次询问 $O(m \log n)$。
- **空间**：仅一维数组 `treearr`，大小 $n+1$，即 $O(n)$。相比之下线段树需要 $4n$ 空间，树状数组节省了一半以上。
- **常数**：树状数组每次操作只做一次位运算、一次数组访问、一次加减，远小于线段树递归或迭代的开销，实测速度通常是线段树的 2~3 倍。

## 适用场景

- **单点修改 + 区间求和**：本模板的标准用途，如 P3374。需要在原数组某位置加一个值，并频繁询问某段区间之和。
- **需要轻量常数**：当题目对常数敏感、n 与 m 都较大时，树状数组比线段树更优。
- **代码短小**：竞赛中希望用最少代码实现前缀和类操作时。
- **前缀和类可逆信息**：凡是信息满足"区间答案可由两个前缀答案相减得到"的都可套用，例如前缀异或、前缀计数等。

## 常见陷阱与注意事项

- **下标从 1 开始**：$\text{lowbit}(0) = 0\;\&\;0 = 0$，若 `i = 0` 则 $i \mathrel{-}= \text{lowbit}(i)$ 永远停在 0 形成"逻辑终止"，但 `add` 中 $i \mathrel{+}= \text{lowbit}(i)$ 会死循环。所以 0 号位不可用，输入数据下标必须从 1 起。
- **数组大小开 n+1**：因为用到下标 `n`，至少 `n+1` 长；若开成 `n` 会越界。
- **返回类型用 long long**：n 个 int 相加可能超过 int 范围（约 $2.1 \times 10^9$），`get` 必须返回 `long long`，`treearr` 也建议用 `long long` 存累计值。
- **init 中不要漏掉向上更新**：朴素地 `treearr[i] = x` 只填了叶子，祖先节点会缺数据；必须沿 `idx += lowbit(idx)` 一路累加。
- **区间查询注意 l-1**：$\text{sum}[l..r] = \text{get}(r) - \text{get}(l-1)$，当 `l=1` 时 `get(0)` 会立即返回 0（while 不进循环），这是安全的。

## 对比与扩展

- **与线段树对比**：树状数组代码更短、常数更小、空间更省（$n$ vs $4n$），但只能维护可减信息，不支持 lazy 标记、区间修改、复杂合并函数；线段树功能更全但更笨重。
- **2D 树状数组**：将一维 BIT 套两层，支持矩阵单点修改 + 子矩阵求和，复杂度 $O(\log^2 n)$，空间 $O(nm)$。
- **求逆序对**：按值域建 BIT，从右往左扫，每次查询比当前值小的元素个数，累计即得逆序数，$O(n \log n)$。
- **BIT + 二分求第 k 小**：在 BIT 上二分，利用每个节点维护的区间长度做前缀和判断，可在 $O(\log n)$ 内找到前缀和第一次达到 k 的位置，常用于动态求第 k 小。
- **差分 BIT（见下一篇）**：把"区间修改 + 单点查询"通过差分数组转化为"单点修改 + 前缀和查询"，仍用同一套 BIT 框架，体现树状数组对偶的灵活性。
- **值域过大需先离散化**：按值域建 BIT 求逆序对时，BIT 的下标范围就是值域本身；若 $a_i$ 高达 $10^9$，直接开 $O(\max a_i)$ 大小的数组会爆空间、无法分配。做法是先把数组去重排序，再用每个值在有序序列中的名次 $1\sim m$（$m$ 为不同值个数，$m\le n$）替换原值，值域即压缩到 $[1,m]$，BIT 数组只需开 $m+1$。离散化排序是 $O(n\log n)$，不改变整体复杂度；去重后相等元素取同名次，也符合"严格大于才计逆序对"的计数要求。

```text
b = a 去重后排序                                    // 有序唯一值序列，长度 m
对每个 a[i]：rank[i] = lower_bound(b, a[i]) - b + 1 // 名次 ∈ [1, m]
按 rank 建 BIT（数组大小 m+1）统计逆序对
```

## 附：树状数组（区间修改单点求和 P3368）

本模板要解决的问题是"区间修改 + 单点查询"——对某段区间 `[l,r]` 整体加一个值 `k`，并询问某个位置的当前值。直接在原数组上做区间加法是 $O(n)$ 的，无法承受大量操作。核心技巧是引入**差分数组**做变换：令 $d[i] = a[i] - a[i-1]$（规定 $a[0]=0$），则原数组的前缀和恰好还原出每个元素：$a[x] = \sum_{i=1}^{x} d[i]$。这是因为 $d[1]+d[2]+\cdots+d[x] = (a[1]-a[0]) + (a[2]-a[1]) + \cdots + (a[x]-a[x-1])$， telescoping 后只剩 $a[x] - a[0] = a[x]$。于是"求单点 a[x]"等价于"求差分数组 d 的前缀和"，而"区间加 k"等价于"差分数组在 l 处 +k、在 r+1 处 -k"：因为加 k 后 `d[l]` 增大 k，会使 `a[l], a[l+1], ...` 都增大 k；而 `d[r+1]` 减小 k 又把 `a[r+1], a[r+2], ...` 拉回原值，恰好让 `[l,r]` 加 k 而 `[r+1,...]` 不变。

这样"区间修改 + 单点查询"被转化为"单点修改 + 前缀和查询"，正好是树状数组最擅长的两项操作：`add(l, k)` 与 `add(r+1, -k)` 是两次单点修改，`get(x)` 是一次前缀和查询。树状数组维护的就是这个差分数组 `d`，而不是原数组 `a`。每次区间加只需 $O(\log n)$ 而非 $O(n)$，每次单点查询也只需 $O(\log n)$ 而非 $O(1)$，但总体远胜于朴素做法。

注意本模板与"单点修改 + 区间求和"版本在代码上几乎一致，只是 `init` 阶段写入的是差分值 $w = x - A$（A 是上一个元素的值），而不是原始值 x。这一改动让 BIT 内部存储的语义从"原数组前缀和"变为"差分数组前缀和"，从而支持区间修改。`get(x)` 直接返回 `a[x]` 而非 `sum[1..x]`，因为差分的前缀和本身就是单点值。

之所以说树状数组在此场景下比线段树更高效：差分 BIT 同样只占用 $O(n)$ 空间、$O(\log n)$ 单次操作、代码极短，不需要线段树的 lazy 标记。线段树虽然原生支持"区间修改 + 区间查询"，但要同时做"区间修改 + 单点查询"反而显得大材小用、常数偏大。差分 + BIT 的组合是这一问题的经典最优解。需要注意的代价是：差分变换只适用于"加法"这种可逆运算；若区间修改是赋值（set）而非加法，差分技巧就失效了。

### 数据结构图示

设原数组 `a = [1, 3, 5, 7, 9]`（下标 1~5），先求差分数组 `d`，再建树状数组：

```
下标 i :    1    2    3    4    5
原数组 a:   1    3    5    7    9
差分 d  :  d[1]=1 (a[1]-0)
           d[2]=2 (a[2]-a[1])
           d[3]=2 (a[3]-a[2])
           d[4]=2 (a[4]-a[3])
           d[5]=2 (a[5]-a[4])

验证: a[3] = d[1]+d[2]+d[3] = 1+2+2 = 5  ✓

树状数组（对 d 建树）：
tree[1] = d[1]                  = 1   覆盖 [1,1]  lowbit=1
tree[2] = d[1]+d[2]             = 3   覆盖 [1,2]  lowbit=2
tree[3] = d[3]                  = 2   覆盖 [3,3]  lowbit=1
tree[4] = d[1]+d[2]+d[3]+d[4]   = 7   覆盖 [1,4]  lowbit=4
tree[5] = d[5]                  = 2   覆盖 [5,5]  lowbit=1

查询 a[4] = get(4) = tree[4]+tree[0]... 实际路径: 4 -> 0
        = tree[4] = 7  ✓

操作 "区间 [2,4] 加 3":
  - add(2, +3): 影响路径 2 -> 4
      tree[2] +=3 (变6), tree[4] +=3 (变10)
  - add(5, -3): 影响路径 5 -> 6(越界停)
      tree[5] += -3 (变-1)
新的差分数组: d[1]=1, d[2]=5, d[3]=2, d[4]=2, d[5]=-1
新的原数组:  a[1]=1, a[2]=6, a[3]=8, a[4]=10, a[5]=9
   ✓ 区间[2,4] 各加了3，a[5] 不变
```

### 核心操作详解

#### lowbit(i) — 取最低位 1
```cpp
inline int lowbit(int i) { return i & -i; }
```
与单点修改版完全相同，利用补码 `~i + 1` 取 `i` 最低位的 1。它决定了 `tree[i]` 管辖的差分区间长度。

#### init(n) — 建树（维护差分数组）
```cpp
void init(int n) {
    treearr.resize(n + 1, 0);
    long long A = 0;
    for (int i = 1; i <= n; i++) {
        int x, w;
        cin >> x;
        w = x - A;        // 差分值 d[i] = a[i] - a[i-1]
        A = x;            // 记下当前值，供下一个元素做差分
        int idx = i;
        while (idx <= n) {
            treearr[idx] += w;       // 把差分值加入 BIT
            idx += lowbit(idx);
        }
    }
}
```
关键区别：写入 BIT 的不是 `x`（原值），而是 $w = x - A$（差分值）。`A` 保存上一个读入的 `x`，初始为 0（对应 $a[0]=0$），所以第一个元素的差分 $d[1] = a[1] - 0 = a[1]$。这样 BIT 内部存的就是差分数组 d 的前缀和结构，使后续 `get(x)` 直接返回 `a[x]`。

#### add(i, k, n) — 单点修改（差分数组上）
```cpp
void add(int i, int k, int n) {
    while (i <= n) {
        treearr[i] += k;
        i += lowbit(i);
    }
}
```
与单点修改版完全一致。在差分数组的 `i` 位置加 `k`，影响所有覆盖 `i` 的祖先节点。

#### add(l, r, k, n) — 区间修改（差分技巧）
```cpp
void add(int l, int r, int k, int n) {
    add(l, k, n);         // d[l] += k  -> [l, ...] 都加 k
    add(r + 1, -k, n);    // d[r+1] -= k -> [r+1, ...] 都减 k，抵消前面的影响
}
```
区间 `[l,r]` 加 `k` 等价于差分数组在 `l` 处加 `k`、在 `r+1` 处减 `k`。两次单点修改即可完成区间修改，总复杂度 $O(\log n)$。注意 `r+1` 若超过 n，`add` 内部 `while(i <= n)` 会自然终止，不会越界。

#### get(i) — 单点查询（差分前缀和）
```cpp
long long get(int i) {
    long long ans = 0;
    while (i) {
        ans += treearr[i];
        i -= lowbit(i);
    }
    return ans;
}
```
求差分数组 `d[1..i]` 之和，即 `a[i]`。逻辑与单点修改版的 `get` 一致，但语义上不是"区间和"而是"单点值"。返回 `long long` 防止多次加减后溢出。

### 逐行代码解析

下面按函数/逻辑阶段把整份代码拆成 5 个模块。各模块的代码块按顺序拼接后，与 `Untitled1.cpp` 完全一致（仅多出行尾 `//` 注释）。

#### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
/*洛谷P3368*/
using namespace std; 
vector<long long> treearr;          // 维护差分数组的树状数组
inline int lowbit(int i)
{
	return i & -i;                  // 取最低位的 1，决定 treearr[i] 管辖的区间长度
}
```

- `treearr` 是维护差分数组的树状数组，用 `vector<long long>` 存储，防止差分累加超出 `int` 范围。
- `lowbit(i) = i & -i` 利用补码取 `i` 最低位的 1，它决定 `treearr[i]` 覆盖的差分区间长度，是树状数组的基石。
- 数组只使用下标 `1..n`，`0` 号位不可用：`lowbit(0)=0` 会让 `add` 陷入死循环。

#### init(n) — 建树（读入并写入差分值）

```cpp
void init(int n)
{
	treearr.resize(n + 1,0);       // 申请 n+1 个元素，只用下标 1..n
	long long A = 0;               // A = a[i-1]，初始 a[0]=0
	for(int i = 1;i <= n;i++)
	{
		int x,w;
		cin >> x;                  // 读入原值 a[i]
		w = x - A;                 // 差分 d[i] = a[i] - a[i-1]
		A = x;                     // 更新 A 为当前值，供下一轮做差
		int idx = i;
		while(idx <= n)            // 沿 lowbit 把差分值 w 累加到祖先链
		{
			treearr[idx] += w;
			idx += lowbit(idx);
		}
	}
}
```

- `treearr.resize(n+1, 0)` 只开 `n+1`：当 `r=n` 时 `add(r+1, -k, n)` 会让 `i=n+1`，`while(i<=n)` 直接跳过，不会越界。
- `A` 保存上一个读入的原值，初始 `0` 对应 `a[0]=0`；`w = x - A` 就是差分 `d[i]`，随即 `A = x` 供下一轮使用。
- 内层 `while(idx <= n)` 把差分值 `w` 沿 `lowbit` 累加到所有覆盖 `i` 的节点，实现单点建树（$O(n\log n)$）。
- 关键点：写入 BIT 的是差分值 `w` 而非原值 `x`，否则 `get` 会退化成「原数组前缀和」，语义就错了。

#### add — 单点修改与区间修改（两个重载）

```cpp
void add(int i,int k,int n)       // 差分数组单点修改：d[i] += k
{
	while(i <= n)
	{
		treearr[i] += k;
		i += lowbit(i);
	}
}

void add(int l,int r,int k,int n) // 区间修改：[l,r] 加 k
{
	add(l,k,n);                    // d[l] += k，使 [l,n] 都加 k
	add(r + 1,-k,n);               // d[r+1] -= k，把 [r+1,n] 拉回原值
}
```

- 三参 `add(i,k,n)` 在差分数组的 `i` 位置 `+k`，沿 `lowbit` 向上更新所有覆盖 `i` 的祖先节点。
- 四参 `add(l,r,k,n)` 用两次单点修改完成区间加：`d[l]+=k` 使 `[l,n]` 都加 `k`，`d[r+1]-=k` 再把 `[r+1,n]` 抵消回原值，两者缺一不可。
- 两个 `add` 靠参数个数（3 个 vs 4 个）区分，调用时注意别传错参数个数导致匹配到错误的重载。

#### get(i) — 单点查询（差分前缀和）

```cpp
long long get(int i)              // 单点查询：返回 a[i]
{
	long long ans = 0;
	while(i)                       // 沿 lowbit 递减累加
	{
		ans += treearr[i];
		i -= lowbit(i);
	}
	return ans;                    // 即 a[i]
}
```

- `get(i)` 从 `i` 出发沿 `lowbit` 递减累加，求差分数组 `d[1..i]` 的前缀和，结果就是单点值 `a[i]`。
- 循环条件是 `while(i)`（`i` 非 0 才继续），与 `add` 的 `while(i <= n)` 方向相反，容易写错，注意区分。
- 返回 `long long`：差分可能为负、多次累加可能超 `int`，必须用 `long long` 承接。

#### main — 主流程

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int n,m;
	cin >> n >> m;
	init(n);
	for(int i = 0;i < m;i++)
	{
		int op;
		cin >> op;
		if(op == 1)                // 区间修改
		{
			int x,y,k;
			cin >> x >> y >> k;
			add(x,y,k,n);
		}
		else                       // 单点查询
		{
			int x;
			cin >> x; 
			cout << get(x) << '\n';
		}
	}
	return 0;
}
```

- `ios::sync_with_stdio(false)` 与 `cin.tie(nullptr)` 关闭 C/C++ 同步与输入输出绑定，加速大量 IO。
- 先 `init(n)` 读入原数组并建成差分 BIT，再循环 `m` 次按操作类型处理。
- `op == 1` 时读 `x,y,k` 调用区间修改；否则读 `x` 并输出 `get(x)` 完成单点查询。
- 输出用 `'\n'` 而非 `endl`，避免每次输出都刷新缓冲区拖慢速度。

**差分变换的正确性论证**：设原数组 a，差分 $d[i] = a[i] - a[i-1]$（$a[0]=0$）。做区间 `[l,r]` 加 k 后，新数组 a' 满足 $a'[i] = a[i] + k \cdot [l \leq i \leq r]$。检查差分 $d'$：当 `i = l` 时 $d'[l] = a'[l] - a'[l-1] = (a[l]+k) - a[l-1] = d[l] + k$；当 `i = r+1` 时 $d'[r+1] = a'[r+1] - a'[r] = a[r+1] - (a[r]+k) = d[r+1] - k$；其余位置差分不变。所以"区间加 k"在差分数组上等价于"$d[l] \mathrel{+}= k,\; d[r+1] \mathrel{-}= k$"，这正是代码所做的。

### 复杂度分析

- **时间**：`add(l,r,k,n)` 调用两次单点 `add`，每次 $O(\log n)$，共 $O(\log n)$；`get(i)` 是一次前缀和查询，$O(\log n)$。建树 $O(n \log n)$，m 次操作 $O(m \log n)$。
- **空间**：一维数组 `n+1`，$O(n)$。与单点修改版相同，远小于线段树的 $4n$。
- **常数**：两次 `add` 比"线段树区间修改 + lazy 下传"开销小得多，实测速度快 2~3 倍。

### 适用场景

- **区间修改 + 单点查询**：本模板标准用途，如 P3368。对一段区间整体加值，并询问单个位置的当前值。
- **差分/前缀和对偶**：与"单点修改 + 区间求和"形成完美互补——把修改与查询的角色互换即可套用同一框架。
- **动态前缀信息的单点还原**：当维护的是差分序列（增量流），需要还原某点累积值时。

### 常见陷阱与注意事项

- **init 必须用差分值**：若误把原始 `x` 直接加入 BIT，则 `get` 返回的是"原数组前缀和"而非"单点值"，语义就错了。务必计算 $w = x - A$。
- **下标从 1 开始**：与单点修改版相同，`lowbit(0)=0` 会导致 `add` 死循环，0 号位不可用。
- **数组大小 n+1**：用到下标 `n`，且 `add(r+1, -k, n)` 当 `r=n` 时会访问 `r+1=n+1`，因此实际安全做法是开 `n+2` 大小，但本模板 `while(i <= n)` 会在 `i = n+1` 时直接跳过，所以 `n+1` 也安全。
- **add 重载二义性**：两个 `add`（三参和四参）靠参数个数区分，调用时注意传参个数；若写错可能匹配到错误的重载。
- **区间修改不影响 r+1 之后**：必须同时执行 `add(l, k)` 和 `add(r+1, -k)`，缺一不可；只做前者会让 `[r+1, n]` 也被错误地加上 k。
- **返回类型 long long**：差分可能产生负值，且大量累加可能超 int，`get` 必须返回 `long long`。

### 对比与扩展

- **与单点修改版的对偶**：单点修改版维护原数组 a 的前缀和，`get(x)` 返回 `sum[1..x]`；差分版维护差分数组 d 的前缀和，`get(x)` 返回 `a[x]`。两者代码几乎相同，仅 `init` 写入的值不同。
- **与线段树对比**：线段树原生支持"区间修改 + 区间查询"（带 lazy），功能更全；但若只需"区间修改 + 单点查询"，差分 BIT 更简洁、常数更小。若同时需要"区间修改 + 区间求和"，需用差分 BIT 的进阶形式——维护 `d[i]` 和 `i·d[i]` 两个 BIT，可在 $O(\log n)$ 内完成区间加与区间和。
- **区间修改 + 区间求和的差分扩展**：$\text{sum}[1..x] = (x+1) \cdot \sum d[i] - \sum i \cdot d[i]$，用两个 BIT 分别维护 `d[i]` 与 `i·d[i]` 即可在 $O(\log n)$ 内完成区间加与区间和查询，是差分 BIT 的经典扩展。
- **2D 差分 BIT**：对二维矩阵的子矩阵加 + 单点查询，可用二维差分 $d[i][j] = a[i][j] - a[i-1][j] - a[i][j-1] + a[i-1][j-1]$，配合 2D BIT 实现 $O(\log^2 n)$。
- **不支持赋值操作**：差分技巧只对"加法"成立，若区间操作是"把 [l,r] 赋值为 v"，差分无法处理，需改用线段树或珂朵露树。$AKB125$, '数据结构', array['数据结构', '树状数组', '单点修改', '区间求和', 'lowbit', 'P3374'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-bit-second-diff', '二阶差分（树状数组维护）', $AKB126$## 算法原理

**一句话结论**：一阶差分适合「区间加常数」，二阶差分适合「区间加等差数列」——对原数组 $[l,r]$ 加首项 $K$、公差 $D$ 的等差数列，等价于在二阶差分数组上做**四个单点修改**；再用两棵树状数组分别维护 $d2[i]$ 与 $i\cdot d2[i]$，就能 $O(\log n)$ 修改、$O(\log n)$ 查询原数组单点值。

**解决的问题**：维护数组 $a[1..n]$，支持：

1. 区间 $[l,r]$ 加上等差数列 $a[i]\mathrel{+}=K+(i-l)D$；
2. 查询当前 $a[p]$。

**从一阶差分到二阶差分**：一阶差分 $d1[i]=a[i]-a[i-1]$ 让「区间加常数」变成两个单点修改（$d1[l]+=C$、$d1[r+1]-=C$），查询时对 $d1$ 做一次前缀和。而「区间加等差数列」在 $d1$ 上留下的是带斜率的渐变，仍是一整段；如果把 $d1$ 再差分一次得到二阶差分 $d2[i]=d1[i]-d1[i-1]=a[i]-2a[i-1]+a[i-2]$，那么：

- **区间内部二阶增量为 0**：增量 $b[i]=K+(i-l)D$ 是等差数列，相邻差恒为 $D$，故 $b[i]-2b[i-1]+b[i-2]=(D)-(D)=0$。等差变化只体现在**左右边界附近**。
- 于是整段等差数列的修改被压缩成 $l,\ l+1,\ r+1,\ r+2$ 四个位置的二阶差分修正（推导见核心公式章），查询通过两次前缀和恢复。

**为什么这样做是对的**：差分是线性可逆运算——对 $d2$ 两次前缀和精确还原 $a[p]$。四个边界修正量是按「增量数组 $b[i]$ 的二阶差分」逐点算出来的（区间内为 0、边界处留下首尾的包子效应），因此叠加所有修改后，任何位置的 $a[p]$ 都与逐位置相加的结果完全一致。$l=r$ 时左修正与右修正落在同一位置自动合并（仍是单点加 $K$ 的正确形态），$r+1,r+2$ 越界时查询根本用不到，均无需特判。

## 核心公式 / 状态定义与转移方程

**状态定义**（1-based，$a[0]=d1[0]=0$）：

- 一阶差分：$d1[i]=a[i]-a[i-1]$；
- 二阶差分：$d2[i]=d1[i]-d1[i-1]=a[i]-2a[i-1]+a[i-2]$（$i=1$ 时 $d2[1]=a[1]$）。

**两次前缀和恢复**：$a[p]=\sum_{i=1}^{p}\sum_{j=1}^{i}d2[j]$，交换求和顺序得

$$a[p]=\sum_{j=1}^{p}(p-j+1)\,d2[j]=(p+1)\sum_{j=1}^{p}d2[j]-\sum_{j=1}^{p}j\cdot d2[j]$$

于是用两棵 BIT：$S_1$ 维护 $d2[i]$、$S_2$ 维护 $i\cdot d2[i]$，查询公式

$$a[p]=(p+1)\cdot S_1.get(p)-S_2.get(p)$$

**区间加等差数列的转移（四个单点修正，完整推导）**：设本次修改的增量数组为 $b[i]$：

$$b[i]=\begin{cases} 0,&i<l\\ K+(i-l)D,&l\le i\le r\\ 0,&i>r\end{cases}$$

我们关心 $b$ 对二阶差分的影响，即逐点求 $\Delta d2[i]=b[i]-2b[i-1]+b[i-2]$。二阶差分是线性运算，所以只需把 $\Delta d2$ 的每一处非零值累加到 $d2$ 对应位置上。

**第一步：区间内部为零。** 取区间内部深处的一个位置 $i$（$l+2\le i\le r$），它前后的三项分别是 $b[i]=K+(i-l)D$、$b[i-1]=K+(i-1-l)D$、$b[i-2]=K+(i-2-l)D$。$b$ 本身是等差数列，相邻差恒为 $D$：$b[i]-b[i-1]=D$、$b[i-1]-b[i-2]=D$。两者相减：

$$\Delta d2[i]=\bigl(b[i]-b[i-1]\bigr)-\bigl(b[i-1]-b[i-2]\bigr)=D-D=0$$

区间内部二阶增量恒为 0——等差数列的「等差」在二阶差分里被完全抹平，修改只会落在左右边界附近。

**第二步：左边界。** 位置 $i=l$：$b[l]=K$，而区间外 $b[l-1]=b[l-2]=0$，代入三点式：

$$\Delta d2[l]=K-2\cdot 0+0=K$$

位置 $i=l+1$：$b[l+1]=K+D$、$b[l]=K$、$b[l-1]=0$，代入：

$$\Delta d2[l+1]=(K+D)-2K+0=D-K$$

**第三步：右边界。** 位置 $i=r+1$：此处已在区间外，$b[r+1]=0$；而 $b[r]=K+(r-l)D$、$b[r-1]=K+(r-l-1)D$，代入：

$$\Delta d2[r+1]=0-2\bigl[K+(r-l)D\bigr]+\bigl[K+(r-l-1)D\bigr]=-K-(r-l+1)D$$

位置 $i=r+2$：$b[r+2]=b[r+1]=0$、$b[r]=K+(r-l)D$，代入：

$$\Delta d2[r+2]=0-0+\bigl[K+(r-l)D\bigr]=K+(r-l)D$$

**第四步：汇总。** 四处修正全部是「增加量」（累加），不是赋值：

```text
d2[l]   += K
d2[l+1] += D - K
d2[r+1] += -K - (r - l + 1) * D
d2[r+2] += K + (r - l) * D
```

每处单点修正 `d2[pos] += v` 都同步做 `S1.add(pos, v)` 与 `S2.add(pos, v*pos)`。

**手算示例**：初始 $a=[3,5,9]$。两次倒序差分：$d1=[3,2,4]$，$d2=[3,-1,2]$。

- `Query 3`：$S_1.get(3)=3-1+2=4$，$S_2.get(3)=3-2+6=7$，$a[3]=4\times4-7=9$。
- 区间加 $[1,3]$、$K=1,D=2$：四处修正 $d2[1]+=1$、$d2[2]+=1$、$d2[4]+=-7$、$d2[5]+=5$（$d2[4],d2[5]$ 越界被自动忽略），实际生效 $d2$ 变 $[4,0,2]$。
- 再查询：$S_1.get(1)=4$、$S_2.get(1)=4$，$a[1]=2\times4-4=4$；$a[2]=3\times4-4=8$；$S_1.get(3)=6$、$S_2.get(3)=10$，$a[3]=4\times6-10=14$。

本代码实测该组指令输出 `9 / 4 / 8 / 14`（逐位置验证：$a=[3,5,9]$ 加 $1,3,5$ 后为 $[4,8,14]$ ✓）。

## 数据结构图示

```text
原数组 a 与两层差分的三角关系（以 n=6 为例示意）：

  a:   a1  a2  a3  a4  a5  a6          ← 两次前缀和还原
 d1:   d11 d12 d13 d14 d15 d16        ← 一次前缀和还原
 d2:   d21 d22 d23 d24 d25 d26        ← BIT 真正维护的对象

 区间加等差数列 [l,r]：
            K   D-K                -K-(r-l+1)D   K+(r-l)D
            |    |                      |            |
  d2:  ...  |    |   0  0  ...  0  0    |            |  ...
            l   l+1      [l+2, r-1]    r+1          r+2
                ↑                        ↑
        （区间内部恒为 0，只有四个边界位置非零）

 两棵 BIT：
   S1 存 d2[i]         ↑ 每处 pos 同步更新
   S2 存 i·d2[i]       S1.add(pos,v) / S2.add(pos,v*pos)
   查询 a[p] = (p+1)·S1.get(p) − S2.get(p)
```

区间内部二阶增量为 0 是这张图的灵魂：等差数列的「等差」在二阶差分里被完全抹平，只在四个边界点留下修正。

## 核心操作详解

### 区间加等差数列（opt = 1）

按四个公式对 $d2$ 做单点增加（全部是**累加**而不是赋值）。用户代码里后两项用了等价写法：`D*-(r-l+1)-K`（即 $-K-(r-l+1)D$）与 `K+D*(r-l)`（即 $K+(r-l)D$），四个 `S1.add` 与四个 `S2.add` 成对出现。越界位置（$r+1,r+2>n$）会被 BIT 的 `while (idx <= n)` 自动忽略，无需显式判断。

### 单点查询（opt = 2）

两次 `get`（分别取 $\sum d2[j]$ 与 $\sum j\cdot d2[j]$）+ 一次乘法一次减法，套查询公式即得当前 $a[p]$——注意结果是**单点值**，不是前缀和。

### 初始化（两种写法）

**写法一：两次倒序差分（本代码所用）**。读入原数组后原地位运算两轮 `a[i] -= a[i-1]`（$k=1,2$），必须**从大到小**跑：正序会用到已被修改的 $a[i-1]$，结果错误。第一轮后 `a[i]` 变成一阶差分 $d1[i]$，第二轮后变成二阶差分 $d2[i]=d1[i]-d1[i-1]$。两轮后原来的 `a` 已不再是原数组而是 $d2$，再逐个 `S1.add(i, a[i])`、`S2.add(i, a[i]*i)` 建树（代码里用 `a` 这个名字复用了数组位，读代码时要意识到 `a[i]` 此时的实际含义是 $d2[i]$）。

**写法二：公式法**。不做原地差分，直接按定义建出 $d2$ 数组再进 BIT（约定 $a[0]=a[-1]=0$）：

```text
for (int i = 1; i <= N; i++) {
    long long a_i  = a[i];
    long long a_i1 = (i >= 1 ? a[i - 1] : 0);
    long long a_i2 = (i >= 2 ? a[i - 2] : 0);
    d2[i] = a_i - 2 * a_i1 + a_i2;      // i=1 时 d2[1] = a[1]
}
```

两种写法结果完全一致，区别只在空间与风格：倒序差分原地省一个数组但「破坏」了原数组，公式法多开一个 `d2` 数组但保留原数组、语义更直观。

## 逐行代码解析

代码拆成 2 个模块，按顺序拼接即完整程序。

### 模块 1 lowbit 与树状数组结构体

```cpp
#include<bits/stdc++.h>
using namespace std;
inline int lowbit(int x)
{
	return x & -x;
}

struct treearr
{
	vector<long long> arr;
	int n;
	treearr() {}
	treearr(int k)
	{
		n = k;
		arr.assign(n + 1, 0);
	}

	void add(int idx, long long k)
	{
		while (idx <= n)
		{
			arr[idx] += k;
			idx += lowbit(idx);
		}
	}

	long long get(int idx)
	{
		long long ans = 0;
		while (idx)
		{
			ans += arr[idx];
			idx -= lowbit(idx);
		}
		return ans;
	}
};

```

- `lowbit(x)=x & -x`：BIT 跳转核心；`add` 沿 `idx += lowbit(idx)` 向上更新，`get` 沿 `idx -= lowbit(idx)` 向下累加。
- `add(idx, k)` 里 `while (idx <= n)` 保证越界下标自动被忽略——这是边界处理不特判的机制保障。
- 节点用 `long long`：$i\cdot d2[i]$ 可能很大。

### 模块 2 主流程：两次倒序差分 + 四个修正 + 查询

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int N, M;
	cin >> N >> M;
	treearr S1(N), S2(N);
	vector<long long> a(N + 1, 0);
	for (int i = 1; i <= N; i++) cin >> a[i];
	for (int k = 1; k <= 2; k++)
	{
		for (int i = N; i >= 1; i--)
		{
			a[i] -= a[i - 1];
		}
	}
	for (int i = 1; i <= N; i++)
	{
		S1.add(i, a[i]);
		S2.add(i, a[i] * i);
	}
	

	for (int i = 1; i <= M; i++)
	{
		int opt;
		cin >> opt;
		if (opt == 1)
		{
			int l, r;
			long long K, D;
			cin >> l >> r >> K >> D;
			S1.add(l, K);
			S2.add(l, K * l);
			S1.add(l + 1, D - K);
			S2.add(l + 1, (D - K) * (l + 1));

			S1.add(r + 1, D * -(r - l + 1) - K);
			S2.add(r + 1, (D * -(r - l + 1) - K) * (r + 1));
			S1.add(r + 2, K + D * (r - l));
			S2.add(r + 2, (K + D * (r - l)) * (r + 2));
		}
		else if (opt == 2)
		{
			int p;
			cin >> p;
			cout << (p + 1) * S1.get(p) - S2.get(p) << '\n';
		}
	}
	return 0;
}
```

- 两轮倒序差分后，`a[i]` 的实际含义变成 $d2[i]$（原数组不要了，代码直接复用数组位）。
- 建树：两棵树分别吃 $d2[i]$ 和 $i\cdot d2[i]$。
- `opt == 1` 是四个位置、八次 `add`（两两成对）：$l$ 处 $(K,\ K\cdot l)$、$l+1$ 处 $(D-K,\ (D-K)(l+1))$、$r+1$ 处 $(-K-(r-l+1)D\ 的等价式,\ \times(r+1))$、$r+2$ 处 $(K+(r-l)D\ 的等价式,\ \times(r+2))$。用户代码写法 `D*-(r-l+1)-K` 与 `K+D*(r-l)` 与原公式代数等价，保留原样。
- `opt == 2` 查询直接套公式 `(p+1)*S1.get(p) - S2.get(p)`，输出单点值。

## 复杂度分析

- **初始化**：两次倒序差分 $O(n)$ + 逐点建树 $O(n\log n)$。
- **区间加等差数列**：4 次 `S1.add` + 4 次 `S2.add`，每次 $O(\log n)$，合计 $O(\log n)$。
- **单点查询**：2 次 `get` + 常数算术，$O(\log n)$。
- **空间**：两棵 BIT 各 $n+1$ 个 `long long` + 原数组，$O(n)$。
- **对比**：若每次修改直接对原数组区间逐位置加，修改 $O(r-l+1)$；参照「双 BIT 二阶前缀和」条目，本条目是差分侧的对偶技巧。

## 适用场景

- **区间加等差数列 + 单点查询**：本模板直接套用（如「给某个区间顺次加一个等差数列后问某位置值」这类差分习题）。
- **区间加常数**：是一阶差分的特例（$D=0$ 时四个修正退化为两个等价修正），但没必要扛着二阶差分做，一阶差分 + 一棵 BIT 更简单。
- **更高阶差分**：区间加「$k$ 次多项式」可用 $k+1$ 阶差分 + 对应数量 BIT 维护，公式按二项式系数展开，思路一致。
- **不要用**：只有区间加常数和一阶问题就别用二阶（复杂度有 $4$ 倍常数差异，代码也长）；需要查询区间和而非单点时，要再套一层「二阶前缀和」的树组维护（组合两个条目即可）。

## 常见陷阱与注意事项

1. **BIT 误维护原数组**：这里维护的必须是二阶差分 $d2[i]$ 与 $i\cdot d2[i]$，不是 $a[i]$。
2. **查询公式系数写成 `p`**：正确的是 $(p+1)\cdot S_1.get(p)-S_2.get(p)$，少了 `+1` 就全错。
3. **四处修正只更一棵树**：每个位置 `S1/S2` 必须成对同步，漏一半查询公式不成立。
4. **四个修正的符号/位置记错**：$l$ 处 $+K$、$l+1$ 处 $+D-K$、$r+1$ 处 $-K-(r-l+1)D$、$r+2$ 处 $+K+(r-l)D$；尤其 `D-K` 别写成 `K-D`（左边界第二处是 $(K+D)-2K=D-K$）。
5. **初始化正序差分**：原地两次差分必须倒序（$i$ 从 $N$ 到 1），正序会用上已修改的 $a[i-1]$。
6. **被「区间内部为 0」误导去跳过边界**：内部为 0 是二阶差分视角的结论，代码实现的四个修正一个都不能少，尤其 $r+1$ 处的负项。
7. **$l=r$ 特判多余**：此时 $l+1=r+1$ 两处修正自然在同一位置合并，仍正确（等于单点加 $K$ 的形态）；写了奇怪的特判反而容易错。
8. **越界显式判断多余但不害**：`r+1,r+2>n` 由 `while (idx <= n)` 自动忽略；若自己加 `if (pos > n) return;` 也可以，但别因此漏掉其它修正。
9. **`long long` 缺失**：$d2[i]\cdot i$ 与查询乘积都可能超 int。
10. **把单点查询当成区间和**：查询公式给出的是 $a[p]$ 单点值，不是 $\sum_{i=1}^{p}a[i]$。

## 对比与扩展

**一阶差分 vs 二阶差分（BIT 维护）**：

| 维度 | 一阶差分（区间加常数） | 二阶差分（区间加等差数列） |
|---|---|---|
| 维护对象 | d1[i]=a[i]−a[i-1] | d2[i]=a[i]−2a[i-1]+a[i-2] |
| 单次区间修改 | 2 个单点 | 4 个单点 |
| BIT 数量 | 1 棵（区间修改单点查询）或 2 棵（区间修改区间查询） | 2 棵 |
| 查询公式 | 一次前缀和 | 两次前缀和组合公式 |

**与「二阶前缀和（树状数组维护）」条目的对偶关系**：两个条目共享同一个查询公式骨架 $(p+1)S_1-S_2$——前缀和条目把「原数组的前缀和」双层化，差分条目把「原数组的修改」双层化；一个是求和侧、一个是修改侧，组合起来就能做「区间加等差数列 + 区间查询」的完整版本。

**扩展方向**：

- **区间加 + 区间查询完整版**：差分侧两棵树 + 前缀侧两棵树（或直接四棵 BIT）支持「区间加等差数列、区间和查询」。
- **k 阶差分**：区间加 $k-1$ 次多项式 → $k$ 阶差分上 $O(k)$ 个单点修正，用 $k$ 棵 BIT 维护 $j^{t}\cdot dk[j]\ (t=0..k-1)$。
- **二维推广**：对矩阵的子矩形加双线性函数，可用二维二阶差分 + 二维 BIT 组合，思路同构、公式更长。$AKB126$, '数据结构', array['差分', '二阶差分', '树状数组', '区间加', '等差数列'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-bit-second-prefix', '二阶前缀和（树状数组维护）', $AKB127$## 算法原理

**一句话结论**：二阶前缀和 $S_2[x]=\sum_{i=1}^{x}\sum_{j=1}^{i}a[j]$ 无法用一棵 BIT 直接维护（系数 $(x-j+1)$ 依赖查询时的 $x$），但把它拆成 $(x+1)\sum a[j]-\sum j\cdot a[j]$ 后，就变成了两个与 $x$ 无关的量，可以用两棵树状数组分别维护，单次修改、查询都只要 $O(\log n)$。

**解决的问题**（洛谷 P4868 Preprefix sum，源自你的笔记标题）：维护序列 $a[1..n]$，支持两种操作：

1. `Modify idx x`：把 $a[idx]$ **改为** $x$（注意是"改为"，不是"加上"）；
2. `Query idx`：查询二阶前缀和 $S_2[idx]=\sum_{i=1}^{idx}\sum_{j=1}^{i}a[j]$。

用普通做法回答一次 Query 要先算一阶前缀和再求一次前缀和，$O(n)$ 或 $O(n\log n)$，查询多了就撑不住。

**核心推导怎么来的**：把二阶前缀和看成「每个 $a[j]$ 被哪些外层 $i$ 数到」——固定 $j$，内层要包含 $a[j]$ 必须 $j\le i$，而外层 $i\in[1,x]$，所以 $a[j]$ 共被数 $x-j+1$ 次。交换求和顺序：

$$S_2[x]=\sum_{j=1}^{x}(x-j+1)\,a[j]$$

系数 $x-j+1$ 同时含「查询变量 $x$」和「位置变量 $j$」，直接维护会崩：同一个 $a[j]$ 对不同查询 $x$ 需要不同系数，而修改时根本不知道将来会查哪个 $x$。把系数拆成 $(x+1)-j$ 再分离：

$$S_2[x]=(x+1)\sum_{j=1}^{x}a[j]-\sum_{j=1}^{x}j\cdot a[j]$$

查询时 $x$ 固定，$(x+1)$ 可提出求和号。于是只需维护两个与 $x$ 无关的前缀量：$\sum a[j]$（B1）与 $\sum j\cdot a[j]$（B2），查询时用 $(x+1)$ 组合。

**为什么这样做是对的**：B1、B2 各自是标准的单点修改 + 前缀查询 BIT；上述等式是恒等变形（仅交换求和顺序 + 拆分系数），没有任何近似，所以用公式组合出来的值与定义逐项求和完全一致。修改时按差值 $k=x-old$ 同步更新两棵树，保证任意时刻 $B_1.get(i)=\sum_{j\le i}a[j]$、$B_2.get(i)=\sum_{j\le i}j\cdot a[j]$ 两个不变量成立，查询公式随之始终正确。



## 核心公式 / 状态定义与转移方程

**状态定义**：

- $B_1$：树状数组，维护 $a[j]$；
- $B_2$：树状数组，维护 $j\cdot a[j]$。

**核心公式**（查询）：

$$S_2[x]=(x+1)\cdot B_1.get(x)-B_2.get(x)$$

其中 $B_1.get(x)=\sum_{j=1}^{x}a[j]$、$B_2.get(x)=\sum_{j=1}^{x}j\cdot a[j]$。

**修改转移**（把 $a[idx]$ 改为 $x$）：

1. 求旧值：$old=B_1.get(idx)-B_1.get(idx-1)$；
2. 求差值：$k=x-old$；
3. 同步更新：$B_1.add(idx,k)$、$B_2.add(idx,k\cdot idx)$。

若题目是「加上 $x$」而不是「改为」，则直接 $k=x$，省去求 old 的步骤。

**手算示例**：$a=[1,2,3]$（下标 1 起）。

- 初始化后：$B_1.get=[1,3,6]$，$B_2.get=[1,5,14]$。
- `Query 3`：$S_2[3]=4\times 6-14=10$，与逐项 $1+(1+2)+(1+2+3)=10$ 一致。
- `Modify 2 5`：$old=3-1=2$，$k=5-2=3$；$B_1.add(2,3)$、$B_2.add(2,6)$，此后 $B_1.get(3)=9$、$B_2.get(3)=20$。
- `Query 3`：$4\times 9-20=16$，与 $1+(1+5)+(1+5+3)=16$ 一致；`Query 1` 得 1、`Query 2` 得 $3\times 6-11=7$。

以上四条指令已由本代码实测输出 `10 / 16 / 1 / 7`。

**公式速查卡**（三件事背熟即可上考场）：

| 操作 | 动作 |
|---|---|
| 初始化 | $B_1.add(i,\ a[i])$、$B_2.add(i,\ i\cdot a[i])$ |
| 改为 $a[p]=v$ | $k=v-old$（$old$ 用两次 get 差出），$B_1.add(p,k)$、$B_2.add(p,p\cdot k)$ |
| 查询 $S_2[x]$ | $(x+1)\cdot B_1.get(x)-B_2.get(x)$ |



## 数据结构图示

两棵树状数组各维护一个一维序列，结构与普通 BIT 完全相同；区别只在「节点里存的是什么」：

```text
        B1（存 a[j]）                B2（存 j·a[j]）
     ┌──────────────┐           ┌──────────────┐
     │ idx=1: a[1]  │           │ idx=1: 1·a[1] │
     │ idx=2: a[1..2]累加│        │ idx=2: ∑j·a[j] │
     │ idx=3: a[3]  │           │ idx=3: 3·a[3] │
     │ idx=4: a[1..4]累加│        │ idx=4: ∑j·a[j] │
     │  ...         │           │  ...         │
     └──────────────┘           └──────────────┘
            ↓ 单点修改都走 lowbit 向上跳、前缀查询都 lowbit 向下跳
     查询时组合：S2[x] = (x+1)·B1.get(x) − B2.get(x)
```

两棵树的下标结构完全一致，同一个 `idx` 的修改会**同步**作用到两棵树上（差值分别为 $k$ 和 $k\cdot idx$）。查询时不需要遍历序列，只要两次 `get` 再套公式，这就是把「两遍前缀和」压缩成 $O(\log n)$ 的关键。

## 核心操作详解

### 单点修改（两棵树同步）

`add` 沿 $idx\to idx+lowbit(idx)$ 向上跳，把差值累加到所有覆盖该点的节点。两棵树的跳转路径完全相同，只是累加的值相差一个 $idx$ 倍——所以实现里就是两次 `add`，一次加 $k$、一次加 $k\cdot idx$。

### 前缀查询（两棵树各查一次）

`get` 沿 $idx\to idx-lowbit(idx)$ 向下跳，累加覆盖段。查询回答 $S_2[x]$ 需要两次 `get`（分别拿 $\sum a[j]$ 和 $\sum j\cdot a[j]$），再做一次乘法和一次减法——共 $O(\log n)$。

### 求旧值（"改为"操作才有）

`old = get(idx) - get(idx-1)` 用两次差分式查询取出单点值，是「改为」类操作的必要前置；「加上」类操作不经过这一步。

## 逐行代码解析

代码拆成 2 个模块，按顺序拼接即完整程序。

### 模块 1 lowbit 与树状数组结构体

```cpp
#include<bits/stdc++.h>
using namespace std;
inline int lowbit(int x)
{
	return x & -x;
}

struct treearr
{
	vector<long long> arr;
	int n;
	treearr() {}
	treearr(int k)
	{
		n = k;
		arr.assign(n + 1,0);
	}
	
	void add(int idx,long long k)
	{
		while(idx <= n)
		{
			arr[idx] += k;
			idx += lowbit(idx);
		}
	}
	
	long long get(int idx)
	{
		long long ans = 0;
		while(idx)
		{
			ans += arr[idx];
			idx -= lowbit(idx);
		}
		return ans;
	}
};

```

- `lowbit(x) = x & -x`：取出 $x$ 最低位的 1，BIT 跳转（向上 `+= lowbit`、向下 `-= lowbit`）全靠它。
- `add(idx, k)`：单点修改——沿 `idx → idx + lowbit(idx)` 向上更新直到越界；存的是「差分贡献」，一个节点的修改只影响覆盖它的祖先节点。
- `get(idx)`：前缀和查询——沿 `idx → idx − lowbit(idx)` 向下累加直到 0；`get(0)` 自然返回 0，正好是求旧值时 `get(idx-1)` 在 `idx=1` 的安全兜底。
- 节点值用 `long long`：$B_2$ 存的是 $j\cdot a[j]$，两者乘积很容易超 int。

### 模块 2 主流程：初始化、修改与查询

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int N,M;
	cin >> N >> M;
	treearr S1(N),S2(N);
	for(int i = 1;i <= N;i++)
	{
		long long x;
		cin >> x;
		S1.add(i,x);
		S2.add(i,x * i);
	}
	
	for(int i = 1;i <= M;i++)
	{
		string str;
		cin >> str;
		if(str == "Modify")
		{
			int idx;
			long long x;
			cin >> idx >> x;
			long long k = x - S1.get(idx) + S1.get(idx - 1);
			S1.add(idx,k);
			S2.add(idx,k * idx);
		}
		else if(str == "Query")
		{
			int idx;
			cin >> idx;
			cout << (long long)(idx + 1) * S1.get(idx) - S2.get(idx) << '\n';
		}
	}
	return 0;
}
```

- 初始化就是按定义逐位置入：`S1.add(i, x)` 与 `S2.add(i, x * i)`，$O(n\log n)$。
- `Modify`：`k = x - S1.get(idx) + S1.get(idx - 1)` 即 $k=x-old$（注意是「改为」所以要求差值）；随后两棵树分别加 $k$ 与 $k\cdot idx$，**必须同步**，漏一棵查询公式就不成立。
- `Query`：直接套公式 `(idx+1) * S1.get(idx) - S2.get(idx)`；先乘再减，注意 `(idx+1)` 乘 `get` 的结果可能超 int，所以显式 `(long long)` 转换。

## 复杂度分析

- **单次 Modify**：求 old 两次 `get`（$O(\log n)$）+ 两次 `add`（$O(\log n)$），总 $O(\log n)$。
- **单次 Query**：两次 `get` + 常数次算术，$O(\log n)$。
- **初始化**：$n$ 次 `add`，$O(n\log n)$（可用「每个点只在 BIT 上建一条链并一次累加」的线性建树优化，但模板场景 $O(n\log n)$ 已足够）。
- **空间**：两棵 BIT 各 $n+1$ 个 `long long`，$O(n)$。
- **对比**：暴力每次查询两遍前缀和 $O(n)$（或 BIT 套 BIT $O(n\log n)$）；双 BIT 把查询压到 $O(\log n)$，查询次数越多收益越大。

## 适用场景

- **单点修改 + 二阶前缀和查询**：如 P4868 Preprefix sum 这类「改一个值、问带权前缀」的题，本模板直接套。
- **高阶推广**：$k$ 阶前缀和用 $k$ 棵 BIT 维护 $j^t\cdot a[j]$（$t=0,\dots,k-1$），查询时按二项式系数组合；思路一致，公式更长。
- **区间加版本**：若操作变成「区间加 + 二阶前缀和查询」（如洛谷 P4514 上帝造题的七分钟），先把差分引入、问题转化为对差分数组的二阶前缀和，本质同构但细节更多。
- **不要用**：只有静态查询（无修改）时直接用前缀和数组 $O(n)$ 预处理 + $O(1)$ 查询，BIT 反而多余；只有一阶前缀查询时一棵 BIT 就够，别套两棵。

## 常见陷阱与注意事项

1. **「改为」与「加上」混淆**：改成"改为"要先求 $old$ 再算差值 $k=x-old$；"加上"直接 $k=x$。把"改为"当"加上"会直接加爆或减爆。
2. **两棵 BIT 不同步**：`Modify` 必须同时 `S1.add(idx,k)` 与 `S2.add(idx,k*idx)`，只更一棵查询公式立刻失真。
3. **公式系数记混**：是 $(x+1)\cdot\Sigma a[j]-\Sigma j\cdot a[j]$，不是 $(x-1)$ 也不是 $(x+1)\cdot\Sigma j\cdot a[j]$；记混一个符号都全错。
4. **下标从 1 开始**：BIT 下标不能为 0；题目 1 起编号正好，若输入 0 起要先平移。
5. **溢出**：$j\cdot a[j]$ 与 $(x+1)\cdot get(x)$ 都可能超 int，BIT 数组和答案全用 `long long`。
6. **get(idx-1) 越界**：idx=1 时 `get(0)` 是安全的（while(0) 直接不进入循环返回 0），但如果自己手写边界判断反而容易引入错误。
7. **初始化别漏 B2**：建树时 `S2.add(i, x*i)` 的 `*i` 忘了乘，B2 就退化成 B1，查询公式必然错。
8. **k 阶扩展 ≠ 无脑开树**：三阶及以上每棵树维护 $j^t a[j]$，组合系数要用组合数恒等式一步步展开核对，不能凭感觉堆树。

## 对比与扩展

**与普通前缀和、普通 BIT 对比**：

| 维护对象 | 查询内容 | 修改代价 | 查询代价 |
|---|---|---|---|
| 静态前缀和数组 | 一阶前缀 | 不支持 | O(1) |
| 一棵 BIT | 一阶前缀 | O(log n) | O(log n) |
| 两棵 BIT（本模板） | 二阶前缀 | O(log n) | O(log n) |
| 暴力两遍前缀 | 二阶前缀 | O(1) 改原数组 | O(n) |

**与「BIT 套 BIT」对比**：直接在 BIT 节点里再存前缀和是 $O(n\log n)$ 查询且码量大；拆两棵树的思路本质是把「带位置权」的部分独立维护，交换求和序这个技巧与「区间查加权和」类问题同源。

**扩展方向**：

- **三阶前缀和**：需要三棵 BIT。办法是把 $(x-j+1)$ 再展开成关于 $x$ 的二次多项式，按 $x$ 的幂次分组（$x^2$、$x$、常数三项各配一棵 BIT 维护带权前缀 $\sum j^t\cdot a[j]$，$t=0,1,2$），公式比二阶长一截，思路完全一致——「系数含查询变量 $x$ 的部分提出来，与 $x$ 无关的加权前缀交给 BIT」。
- **一般 k 阶前缀和**：$k$ 棵 BIT，第 $t$ 棵（$t=0,1,\dots,k-1$）维护 $j^t\cdot a[j]$，查询时用对应的组合数/多项式系数把各棵的 `get` 合并起来。系数每升一阶要重新展开核对一遍，不能凭感觉堆树。
- **区间加版本（P4514 上帝造题的七分钟）**：操作变成「区间加 + 二阶前缀和查询」时，先对原数组引入差分，把问题转化为「对差分数组求二阶前缀和」，然后套本模板的两棵树——本质相同，只是多绕了一层差分、细节更多。
- **二维推广**：二阶二维前缀和可类比多树维护 $i\cdot a[i][j]$、$j\cdot a[i][j]$、$ij\cdot a[i][j]$ 等权组合，树状数组换成二维版本即可。$AKB127$, '数据结构', array['前缀和', '树状数组', '二阶前缀和', 'BIT', '单点修改'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('Fohen', 'col-ds-block-2d--fenfeng', '二维分块 · Fohen', $AKB128$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

### 例题 $16$：[P8353 [SDOI/SXOI2022] 无处存储](https://www.luogu.com.cn/problem/P8353)

>给你一棵 $n$ 个节点的树，树上的每个点上有权值 $a$，有 $q$ 次为以下两种之一的操作：把一条从 $x$ 到 $y$ 的路径上的权值 $+v$；查询一条从 $x$ 到 $y$ 的路径上的权值和。

（数据保证 $n \le 7 \times 10^6,m \le 5 \times 10^4$，空间限制为 $64MB$）

~~树链剖分模板。~~ 很明显，树链剖分就是解决这类问题的，但此题空间限制极小，连线段树都开不下（好像有人能用树链剖分卡过）。不过树分块也能解决这种问题，而且树分块的空间复杂度只有 $\operatorname{O}(n)$，十分优秀，于是考虑用树分块做这题。

因为这题跟树上的路径有一定的关系，先思考在树上选关键点的方法。使用例题 $14$ 中选取若干关键点来分块的算法选出这些关键点，为了节省接下来操作造成的空间消耗，我们对这些关键点建出虚树。然而，并不能用正常方法（$dfs$ 一遍都不行），但点数较少，可以考虑直接暴力。具体来说就是从每个关键点开始暴力向上跳，并把经过的点打上标记，如果遇见了标记过的点就停下来，假设停下来的点不是关键点，就表示这个点被其他关键点向上跳的时候经过了，也就是说这个点某两个关键点的 $lca$，把 $lca$ 也加进关键点集合就行了。其中打标记的过程相当于一个布尔数组，用 $bitset$ 可以优化空间。

接下来具体看一次操作，先看修改。设当前这次修改的路径为从 $u$ 到 $v$。还是依照例题 $14$ 中的做法，把操作的路径拆成五段，对于这五段中的两个整块段，可以暴力枚举这两个整块段中包含的所有整块，对这些整块直接打上整块加的懒标记，这么做时间复杂度是块数，可以接受。至于散块的部分，这部分的大小是块的大小的级别，所以直接暴力枚举所有点修改，并在修改完这些单点后重构这些单点所属的整块。

询问的话也好做，整块部分依旧可以暴力枚举每一块统计答案，散块部分也是暴力枚举统计，记得在统计单点的时候要算上所属块懒标记的影响。

这道题到这里还没有真正做完，还有很多细节方面的东西，比如我们不能用平常习惯的方式去求 $lca$ 了。我们注意到，要实现刚刚所说的算法，需要实现以下四个子步骤：求两点的 $lca$；求一个点最近的祖先关键点；求一个点最近的子树内关键点；求一个点的深度。我们一个一个解决：

1. 求任意两点 $u,v$ 的 $lca$。容易证明任意两点的 $lca$ 为关键点，因为如果 $u$ 的最近祖先关键点和 $v$ 的最近祖先关键点相同，那么 $lca$ 就是这个公共的祖先关键点；如果不同，那么 $\operatorname{lca}(u,v)$ 可以转化为 $u$ 的最近祖先关键点和 $v$ 的最近祖先关键点的 $lca$，又因为虚树的性质（两个关键点的 $lca$ 一定是关键点），所以 $lca$ 一定是关键点。于是先分别暴力跳到 $u$ 和 $v$ 的最近祖先关键点，然后再从 $u$ 和 $v$ 的最近祖先关键点开始跳，每次向上跳一条虚树上的边（即为一个块），直到两个点出现了祖先-后代关系，此时深度较深的那个点即为 $lca$。时间复杂度是块数 $+$ 块长。
2. 求一个点最近的祖先关键点。刚刚已经说过了，暴力跳原树中的父亲边就行了，复杂度是块长。
3. 求一个点 $u$ 最近的子树内关键点。首先执行 $2$ 子步骤，在跳的同时记录当前这个点是从哪个儿子跳上来的。我们可以提前预处理出每个关键点通过某一个儿子能到达的最近关键点，在查询时，就可以根据最近祖先关键点以及跳上这个关键点的点快速回答这个祖先关键点走经过 $u$ 的路径能到达的最近 $u$ 子树内关键点。这里的预处理是好做的（在虚树上 $dfs$ 就行了），可以用 $map$ 存储下来结果方便查询，而查询的复杂度因为不是乘算，可以忽略不计。
4. 求一个点 $u$ 的深度。这个也是好做的，只需预处理出每个关键点的深度，查询时从 $u$ 开始跳父亲边直到跳到某个关键点，$u$ 的深度即为这个关键点的深度 $+$ 跳的步数。

有了这些，问题就能解决了。分析一下时间复杂度，设块长为 $B$，很明显，单次 修改/查询 都会先把路径分段，再进行修改或统计答案，这之间的复杂度是加算的，所以每次操作的时间复杂度为 $\operatorname{O}(B+\frac{n}{B})$，取 $B$ 为 $\operatorname{O}(\sqrt{n})$ 时最优，此时总时间复杂度为 $\operatorname{O}(q\sqrt{n})$；因为特殊原因，此题还需看一下空间复杂度，实际上，真正需要把长度开到 $n$ 的数组，只有记录单点权值的数组以及记录每个点的父亲的数组，其他的部分还需开一个 $bitset$ 以及若干个长度为 $\operatorname{O}(\sqrt{n})$ 的数组，是可以接受的。

最后考虑一下这题能不能用 $Top \ Cluster$ 做。这题最大的障碍在于卡常，也正是因为要卡常所以上面那种做法中使用了虚树进行缩点。而 $Top \ Cluster$ 很明显不能直接做（又是栈又是 $dfs$，空间爆炸了），如果要缩点，又明显不如选关键点的做法顺畅，因为我们知道 $Top \ Cluster$ 是靠簇路径来处理路径问题的，所以缩点时会自然地想到把一个树簇缩成一条边，而上下界点变为虚树上的点。但这样做的话就很难考虑树簇中除了簇路径以外的点，或者说需要维护更多东西，空间很可能不够。其实说到底，不推荐用 $Top \ Cluster$ 的原因与例题 $15$ 不推荐使用选关键点的方法的原因很相似，也许可以通过各种神奇的手段得到一个正确的算法，但一些性质本来就没有，强行修改的话会显得很不自然，而且大大增加了时间、空间、思维、代码复杂度，是没有太大意义的。

总的来说，选关键点和 $Top \ Cluster$ 都是非常好用的树分块算法，但分块的形态不太一样，选关键点分出来的块是路径，而 $Top \ Cluster$ 的树簇是 “一团一团” 的。基于基本的形态，两种算法又有各自的独特性质，也都能解决一类题（不然为什么都要学），比如 $Top \ Cluster$ 就具有 “除簇路径上的点外的点的子树大小都 $\le$ 块长” 之类的性质，而选关键点的做法更擅长处理一些路径上的问题。虽然总体来说 $Top \ Cluster$ 性质更多，但其对比选关键点的做法也有一些劣势，还是需要通过题目具体的情况选择使用哪种树分块算法。

## 二维分块

我们已经尝试过把序列分块放到树上进行，那么是否可以考虑进一步拓展分块算法？比如把分块放到二维平面上，以用较快的复杂度实现二维数点等问题。接下来的一道例题会详细介绍这样做的方法。

### 例题 $17$：[P7448 [Ynoi2007] rdiq/P7601 [THUPC 2021] 区间本质不同逆序对](https://www.luogu.com.cn/problem/P7448)

>给你一个长度为 $n$ 的序列 $a$，$m$ 次询问区间内本质不同逆序对个数（本质相同表示组成两个逆序对的序列位置上的值相同）。

（数据保证 $n \le 10^5$，$m \le 5 \times 10^5$，序列任意位置的值 $\le n$）

对于这种较为复杂的区间询问，我们可以考虑用莫队解决，但之前所讲到的莫队修改时造成的影响只与单个位置有关（或者能用较低复杂度进行修改和维护），很明显，如果这道题要使用莫队，在当前区间的左/右端点移动时，会有一些原来能与这个点组成逆序对的点对答案产生新的影响，而且这个影响不能简单的维护出来（还要考虑本质不同这个限制），于是先引入一种维护较为复杂的信息的莫队技巧：

### 例题 $18$：[P4887 【模板】莫队二次离线（第十四分块(前体)）](https://www.luogu.com.cn/problem/P4887)

>给你一个长度为 $n$ 的序列 $a$，$m$ 次查询一个区间内有多少个数对满足两个数异或起来得到的值在二进制表达中恰好有 $k$ 个 $1$。

（数据保证 $n,m \le 10^5$，$a_i,k < 16384$）

我们发现 “有多少个数对异或起来的二进制里恰好有 $k$ 个 $1$” 并不好支持插入/删除，但如果能把所有的这些插入/删除操作离线下来再进行操作，就可以维护了。

莫队共有四种操作：当前区间的 左/右 端点向区间 外/内 移动，这里只介绍当前区间的右端点向右移动时的情况，其他情况都能用类似的方法解决。

设当前的区间为 $[L,R]$，此次操作要把右端点移到 $R'$。我们定义 $\operatorname{f}(l,r,x)$ 表示 $[l,r]$ 内有多少个数跟 $x$ 位置的数异或后二进制表示中恰好有 $k$ 个 $1$，那么就能把上面操作的影响转化成 $\sum_{R < i \le R'}\operatorname{f}(L,i-1,i)$，把所有的 $\operatorname{f}$ 拆成差分的形式，即为 $\sum_{R < i \le R'}\operatorname{f}(1,i-1,i)-\sum_{R < i \le R'}\operatorname{f}(1,L-1,i)$，分别考虑两部分如何求。

很明显，第一部分任何时刻都是一个数与所有在它左边的数进行配对，所以是可以预处理的，在正常进行莫队时直接算上就行了。第二部分较难处理，可以离线下来，任意一次这样的操作都能看成一个前缀与一个区间内的所有数进行配对，对每个操作只需维护前缀的位置以及这个区间的位置，记录所有的这些操作只需 $\operatorname{O}(m)$ 的复杂度。接下来，按照前缀的位置对这些操作排序，就能在遍历的过程中维护能与当前前缀中某个数异或后满足条件的值有哪些，然后对于每次操作的区间就直接暴力遍历，累加答案。当然，这样只求出了每次操作导致的变化量，最后还需要做个前缀和才是最终答案。

梳理一下这个算法的流程：我们先将询问离线，按照正常莫队的排序方法排序，提前预处理出一个位置的数能与几个在它之前的数配对，然后进行莫队，把莫队过程中每个询问对应需要的操作离线下来，再统一处理就行了。这种二次离线的思想就把莫队原来需要在线实现的修改操作变为了离线，从而增加了莫队能实现的问题广度。

复杂度很好分析，离线下来后遍历每个操作区间的复杂度，其实就是正常莫队中移动当前区间 左/右 端点的复杂度，也是 $\operatorname{O}((n+m)\sqrt{n})$。

看回例题 $17$。很明显，这个问题也能用二次离线的莫队来维护，我们还是只具体讨论右端点右移时如何处理。我们把操作都离线下来，设 $\operatorname{f}(l,r,x)$ 表示区间 $[l,r]$ 中 $>x$ 的数的个数，问题就变成了： $\operatorname{O}(m)$ 次对于一个区间 $[r,r']$，查询每个 $r < x \le r'$ 的 $\operatorname{f}(l,x-1,x)$，又因为我们离线下来了，可以把这 $\operatorname{O}(m)$ 个 $[r,r']$ 的区间按照对应的 $l$ 从大到小排序，只需要把原序列的数从后往前添加进来，加到一次操作的 $l$ 时就暴力遍历对应的 $[r,r']$，对每个 $r \le x \le r'$，计算当前加进来的 $[1,x]$ 前缀中的 $\ge a_x$ 的数的个数（因为目前只添加了位置在 $l$ 之后的数，已经满足了 $\ge l$ 的限制），加起来就是这次操作的总贡献。

问题在于如何计算一个前缀中 $\ge a_x$ 的数的个数。我们让 $\forall 1 \le x \le n,a_x=n-a_x+1$，再把每个位置 $x$ 看成一个二维平面上 $(x,a_x)$ 的点，于是问题转化为了一个类似于二维前缀和的问题，可是我们需要在正确的复杂度内完成 $\operatorname{O}(m \sqrt{n})$ 次查询，带 $\log$ 的复杂度似乎都无法通过，我们考虑能够充分发挥人类智慧的分块。

首先我们把 $n \times n$ 的平面分成 $\sqrt{n}$ 个 $n^{0.75} \times n^{0.75}$ 的大块，再对每个大块内分成 $\sqrt{n}$ 个 $n^{0.5} \times n^{0.5}$ 的小块，这样，一个平面被我们分成了 $\operatorname{O}(n)$ 个块，同时，基于 $n^{0.5}\times n^{0.5}$ 的小块和 $n^{0.75}\times n^{0.75}$ 的大块，我们还可以分出一些不那么均衡的 “长块” 和 “高块”（瞎取的名字），即为 $n^{0.5}\times n^{0.75}$ 的块和 $n^{0.75} \times n^{0.5}$ 的块。我们对于所有 $n^{0.75}\times n^{0.75}$ 的块暴力维护二维前缀和，再对**每个大块内**的小块暴力维护前缀和，而对于“长块” 和 “高块”，我们分别需要暴力维护一个 $n^{0.75}\times n$ 和 $n\times n^{0.75}$ 的区域内这两种块的前缀和。注意，小块、“长块” 和 “高块” 的前缀和分别在不同的 $n^{0.75}\times n^{0.75}$、$n^{0.75}\times n$、$n\times n^{0.75}$ 区域内相互独立。

这样做有什么好处吗？对于修改，我们可以分别对四种块做出修改，因为对于除了大块外的三种块，我们只需要修改当前点所在的大区域内的这些块的前缀和就行了，而经过平衡，即便是暴力修改二维前缀和，这部分复杂度也是只有 $\operatorname{O}(\sqrt{n})$ 的，而大块也最多只有 $\operatorname{O}(\sqrt{n})$ 个。

再看查询。我们可以把一个以 $(1,1)$ 为左下角的二维前缀矩形区域拆分成以下几部分：

![](https://cdn.luogu.com.cn/upload/image_hosting/zoh52nel.png)

如图，其中红色的部分为大块，黄色的部分为长块，绿色的部分为高块，蓝色的部分为小块。

我们已经对一定范围内的这些块的二维前缀和相对独立地维护出来，只需要分别考虑这四部分并加起来就好，正确性显然，因为如果一些较小的块放在一起最后大小超过了我们独立维护这些块的范围，那么一定能凑成若干个更大的块，最终只剩下能直接查询前缀和的一小部分。因为可以直接查询不同部分的前缀和并累加起来，所以复杂度为 $\operatorname{O}(1)$。

但注意到我们还未讨论紫色的部分（散块），容易发现询问次数远大于修改次数（也就是按照顺序把序列上一个位置的值添加进来的过程），于是想办法找到一个询问 $\operatorname{O}(1)$ 的算法。我们发现，直接枚举散点肯定是不对的，但能将一个点作为散点计算进答案中的询问位置只有 $\operatorname{O}(\sqrt{n})$ 个，于是可以考虑在修改时枚举一个点作为散点时能对哪些询问造成影响。发现一个散点能影响到的询问一定满足：一定存在某一维比散点的那一维大，且那一维所属的 $n^{0.5}$ 的范围相同。形式化的，我们设 $pos_x$ 表示一维位置 $x$ 所属的 $n^{0.5}$ 的块的编号，散点编号为 $(x_0, y_0)$，所考虑的询问为求一个左下顶点为 $(1,1)$，右上顶点为 $(x,y)$ 的矩形的权值和，则所考虑的询问能把这个点当成散点计入答案当且仅当 $x_0 < x \ \text{且} \ y_0 < y \ \text{且} \ (pos_x=pos_{x_0} \ \text{或} \ pos_y=pos_{y_0})$。

我们对 $a$ 数组做一定的预处理：在完成之前的处理后，我们把这时的 $a$ 数组的每一个位置转化为一个二元组 $(a_i,-i)$，然后按照升序对这 $n$ 个二元组排序，最后让新的 $a'$ 数组每个位置的值等于这个位置二元组排完序后的位置。这样做实际上实现了将 $a$ 数组改为一个排列 $a'$，对于 $1 \le i,j \le n, \ a_i > a_j$，处理完后满足 $a'_i>a'_j$；而对于原来相等的两个数，更靠前的那个数值更大，这样做就能在把 $a$ 转化成排列 $a'$ 的同时不影响答案（靠后的数仍然无法把靠前的相同数算进逆序对数中）。

因为 $a'$ 是一个排列，所以我们可以维护出每个值出现的位置。每次询问可以看成 $(i,a'_i)$，于是我们枚举两次，分别枚举 $i$ 和 $a_i$，也就对应着一次询问的其中一维，要保证这一维比修改点的这一维大且属于同一个块，再快速判断这个散点对应的另一维是否满足在这个询问中成为散点的条件，提前设置一个数组，如果满足上述的条件就直接使这次询问的答案受到影响，回答一次询问时只需在考虑整块的基础上再加上散块的这一部分就行了。因为一维中的块长度为 $\operatorname{O}(\sqrt{n})$，所以这个步骤的时间复杂度也为 $\operatorname{O}(\sqrt{n})$，这样的枚举只会在新加进去一个点时进行，最多 $n$ 次，复杂度正确。

最后把整块和散块合起来，再讨论一下其他三种情况（左端点向 左/右 移，右端点向左移），就能通过了。具体讨论一下复杂度，很明显，二维分块修改的复杂度就是 $\operatorname{O}(n \sqrt{n})$，所以我们只考虑莫队的复杂度。设莫队的块长为 $B$，共有 $T = \lceil \frac{n}{B} \rceil$ 个块，那么时间复杂度为 $\operatorname{O}(Tn+Bm)$，平衡复杂度，使 $Tn=Bm$，可以得到 $B$ 取 $\operatorname{O}(\frac{n}{\sqrt{m}})$ 时最优，此时时间复杂度为 $\operatorname{O}(n\sqrt{m})$，可以通过。

还有一些细节，比如如何处理 “本质不同” 的条件。其实较为简单，还是以右端点右移为例，我们只需在一个新的数加进来的时候把上一个加进来的数值相同的数删掉就行，因为这个数能匹配到的逆序对数量一定不小于上一个加进来的数。同时，在遍历操作区间进行询问时，设遍历的顺序为从左往右（从右往左也不是不能做），两个相同的数更靠右的那个数能匹配到的逆序对数量一定不低于更靠左的那个数，于是从答案中把上一个遍历到的数值相同的数的答案减掉就行了。容易证明，这样是不重不漏的。

这种对二维平面进行分块的算法本质上还是暴力维护二维前缀和，精妙之处在于这个算法把整个平面分块再分块，使得最终每一种大小的块的数量被控制在一个正确的量级。也可以理解为我们把信息分层，使得每一层需要确定或遍历的信息量降到一个正确的量级，具体到二维分块上，可以理解为：第一层我们把 $n\times n$ 的平面分成了 $\sqrt{n}$ 个大块，在分成大块的基础上，我们再分第二层，每个大块都被分成 $\sqrt{n}$ 个小块，这样分别遍历第一层和第二层，复杂度还是 $\operatorname{O}(\sqrt{n})$ 的。

### 例题 $19$：[CF848C Goodbye Souvenir](https://codeforces.com/problemset/problem/848/C)

> 给你一个长度为 $n$ 的序列 $a$，定义一个数在一个区间内的值为这个数在区间内最后一次出现的位置减去第一次出现的位置，有 $m$ 次操作：对 $a$ 的某个位置修改；询问所有数在一个区间 $[l,r]$ 内的值的和。

（数据保证 $n,m \le 10^5$，且 $\forall \ 1\le i\le n, \ 1 \le a_i \le n$）

我们尝试对贡献进行拆解，假设在区间内数 $x$ 的出现位置分别为 $id_1,id_2,\cdot\cdot\cdotp,id_{k-1},id_k$，我们需要求的是 $id_k-id_1$，自然可以分解为 $(id_2-id_1)+(id_3-id_2)+ \cdot\cdot\cdotp+ \ (id_k-id_{k-1})$ 进行计算，换句话说，我们希望对每个数求出：区间内这个数每对相邻的两次出现位置之间的距离和，如果令 $pre_x$ 表示 $x$ 位置上出现的数上次出现的位置，那么我们可以直接把一个区间 $[l,r]$ 内数 $x$ 贡献的答案表示为 $\sum_{l \le i \le r}(i-pre_i)[l \le pre_i \le r][a_i=x]$，容易发现，如果要考虑所有数造成的贡献，就可以直接把后面 $[a_i=x]$ 的条件去掉，且答案正确，于是对于一次查询 $[l,r]$，我们回答 $\sum_{l \le i \le r}(i-pre_i)[l \le pre_i \le r]$ 就好了。

我们可以对于每个位置 $i$，在一个 $n\times n$ 的二维平面上添加一个 $(i,pre_i)$ 的点，权值为 $i-pre_i$，一次询问 $[l,r]$ 就可以看作在平面上查询第一维的范围在 $[l,r]$ 之间，第二维的范围也在 $[l,r]$ 之间的矩形区域内所有点的权值和。这个东西可以转化为四个二维前缀和相互加减，显然用二维分块维护。

还有一些细节，我们知道在例题 $17$ 中把一个点添加进去的时候要枚举所有可能把这个点当成散块统计的询问点，那是因为每个位置的询问点是唯一的，很显然，这道题就不能那么做了。实际上，我们把例题 $17$ 中对散块的处理方式稍加改变——修改时不讨论散块，在询问时对两维分别枚举和当前询问点在一个块内且这一维坐标比询问点小的有权值的点，因为块长的限制，这些点的数量是 $\operatorname{O}(\sqrt{n})$ 的。为了方便枚举，我们想办法让所有带有权值的点之间的两维坐标都不重复，换句话说，想要快捷枚举，就要满足 $\forall \ 1 \le i ,j\le n\land i \not = j,\ pre_i \not = pre_j$。我们发现 $pre$ 只有为 $0$ 的时候才可能会重复出现，而如果一个位置的 $pre$ 为 $0$，那么也就不会被记录到答案中去，所以可以直接忽略 $pre=0$ 的情况，不把 $pre=0$ 的点加到平面上。同样的，可以把修改时暴力修改整块前缀和、询问时 $\operatorname{O}(1)$ 统计换成修改时只修改这个点所在的四种块的单块的权值，询问时暴力统计每种块的二维前缀和。这样我们就得到了一个单次修改 $\operatorname{O}(1)$，单次查询 $\operatorname{O}(\sqrt{n})$ 的算法。

然后来看修改，修改还是比较好处理的。~~首先当然可以时间分块~~ 可以对每种值维护一个链表表示这个值出现的所有位置。修改时就可以快速知道哪些位置的 $pre$ 会发生变化，对这些 $pre$ 进行了变化的位置，如果变化后 $pre = 0$ 就把之前对应的点删掉，如果变化前 $pre = 0$ 就直接加上变化后对应的点，否则就先把之前对应的点删去，然后加上变化后的新点。用 $set$ 维护，时间复杂度虽然要加上一个 $\operatorname{O}((n+m)\log n)$，但和分块的部分相对独立，复杂度仍是正确的。

时间复杂度的分析是简单的，共有 $\operatorname{O}(n+m)$ 次修改，$\operatorname{O}(m)$ 次查询，最终复杂度即为 $\operatorname{O}(m \sqrt{n})$。

### 例题 $20$：[P8530 [Ynoi2003] 博丽灵梦](https://www.luogu.com.cn/problem/P8530)

>给你 $n$ 个点 $(i,p_i)$，每个点有颜色 $a_i$，颜色 $i$ 有权值 $b_i$，$m$ 次询问这个平面上某个矩形区间内的所有**出现过的**颜色的权值之和（多次出现只算出现过一次）。

（数据保证 $n \le 10^5$，$\forall\ 1 \le i \le n, \ 1\le p_i,a_i,b_i \le n$，$p$ 是一个排列）

如果把这个问题放到一维，其实是好做的，设 $pre_i$ 表示第 $i$ 个位置的 $a_i$ 上一次出现的位置，把 $(i,pre_i)$ 看成一个点。询问一个区间 $[l,r]$ 时只需要回答第一维处于 $[l,r]$ 且第二维处于 $[0,l-1]$ 的答案就行了，这样无论是只求颜色数还是颜色带权的情况都能转化为二维数点。

考虑如何给第 $i$ 个位置加上 $p_i$ 这一维的限制。比如一次询问要求矩阵内 $L \le p_i \le R$，则可以转化为**只**考虑 $p_i \in [L,R]$ 的点的情况下做一遍刚刚所讲的二维数点，我们可以只把 $p_i \in [L,R]$ 的对应的点加到平面上，再进行二维数点，这样就能满足条件了。

这个问题很难直接维护，但如果只维护把一个点添加/删除两种基础的操作就是好做的，这种只需考虑把单个信息添加/删除的问题很明显可以用莫队解决。我们对第二维坐标进行莫队（即为 $p$ 的那一维），把所有询问按照第二维限制的区间排序，再莫队中我们维护的当前区间即为添加的所有点的 $p$ 的范围。我们发现，当莫队的左右端点向 内/外 移动时，会把一个 $(i,pre_i)$ 的点 添加/删除，先考虑如何解决删除。定义一个与 $pre$ 相反的数组 $nxt$，设 $nxt_i$ 表示下一个与 $i$ 的 $a_i$ 相等的点，当我们删除一个点 $(i,pre_i)$ 的时候，如果 $nxt_i$ 存在，我们就需要将原本的 $(nxt_i,i)$ 删去，再添加上 $(nxt_i,pre_i)$，并且将 $pre_{nxt_i}$ 设为 $pre_i$。同时，如果 $pre_i$ 存在，就让 $nxt_{pre_i}$ 设为 $nxt_i$。这部分的时间复杂度都是 $\operatorname{O}(1)$ 的。

那添加呢？添加中最难处理的地方在于我们无法快速确定新加进去的位置 $i$。在例题 $19$ 中，我们最后用链表维护所有的某个 $a_i$ 出现的位置，但这题因为使用了莫队，导致修改操作极多，我们无法在每次修改时都进行 $\operatorname{O}(\log n)$ 复杂度的算法，只能考虑别的方法。

回想我们遇到一个 “只能添加不能删除” 的莫队时是怎样处理的。我们为了避免删除操作，处理左端点在某个块中的所有询问之前，先暴力重构，之后对于每次询问，我们只需将当前区间的右端点右移，左端点初始等于块的右端点，对每次询问只需暴力移到此次询问的左端点并在回答后撤回就行了。这就是正常的回滚莫队，我们利用了分块的块长不会太长这个条件，巧妙地避免了删除操作，相应的，我们这题不能添加，但删除可以 $\operatorname{O}(1)$ 解决，所以把原来的回滚莫队进行魔改，变为无增回滚莫队就可以了。

我们对区间排序时，把左端点所属的块当作第一关键字，在第一关键字相同的情况下，右端点越大，就把这个区间放到越前面处理。统一处理左端点在某个块中的询问，设这个块的左端点为 $lb$，则在回答询问前，我们先进行重构，把当前的区间设为 $[lb,n]$，并提前处理这个区间情况下的 $pre,nxt$ 以及二维上满足条件的点等各种信息，处理单次询问时，只将右端点向左移（只有删除操作），左端点暴力向右移动（还是只有删除），并在回答询问后将左端点重新撤到 $lb$。

这样，我们解决了插入和删除操作，也就可以用无增回滚莫队快速维护当前的二维平面。那二维平面有了，就该考虑如何在上面数点了。

和例题 $19$ 差不多的思路，对于 $pre_i \not = 0$ 的情况，我们用二维前缀和维护（还是 $\operatorname{O}(1)$ 修改 $\operatorname{O}(\sqrt{n})$ 查询）。但这次 $pre_i$ 的限制区间变为了 $[0,l-1]$，需要额外考虑 $0$，而把 $0$ 的情况也放到二维前缀和中会导致二维坐标和一维坐标不再是一一对应的，也就无法维护了。对此，我们再使用一个序列分块，如果添加/删除一个位置 $i$ 对应的 $(i,pre_i)$ 中 $pre_i=0$，就在序列分块上 $i$ 的位置修改。统计答案时，用二位前缀和计算出的答案加上一维分块上的区间和就好了（一维分块中的点已经保证了第二维为 $0$，所以只需考虑第一维限制对应的区间）。

这道题就做完了。分析下时间复杂度，首先 $n$ 和 $m$ 并不同阶，定块长的方法可以参考例题 $18$，把块长定为 $\operatorname{O}(\frac{n}{\sqrt{m}})$，于是莫队部分的复杂度为 $\operatorname{O}(n\sqrt{m})$。对于每次询问，还需要 $\operatorname{O}(\sqrt{n})$ 的查询复杂度，最终总时间复杂度便为 $\operatorname{O}(m\sqrt{n}+n\sqrt{m})$。

二维分块确实是一种写熟后就较为无脑的二维数点的方法，$\operatorname{O}(1)-\operatorname{O}(\sqrt{n})$ 或者 $\operatorname{O}(\sqrt{n})-\operatorname{O}(1)$ 的复杂度让它经常被用于莫队等修改与查询量级不同的算法，其实许多分块算法都有 $\operatorname{O}(1)-\operatorname{O}(\sqrt{n})$ 或者 $\operatorname{O}(\sqrt{n})-\operatorname{O}(1)$ 的时间复杂度，这时如果把两种复杂度的算法 “拼起来”，让查询和修改都不超过 $\operatorname{O}(\sqrt{n})$，就能在复杂度正确的情况下实现更多功能。

基础的分块部分大概就是以上这些，下面会拓展一些同样与平衡复杂度也与根号有关的算法/数据结构。$AKB128$, '数据结构', array['二维分块', '莫队二次离线', '分块'], 'col-hub-ds-block', null, 'knowledge'),
('Fohen', 'col-ds-block-decomposition--fenfeng', '分块（序列分块） · Fohen', $AKB129$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

## 序列分块

顾名思义，序列分块是一种对序列进行分块的数据结构，一般会把在序列中连续的一段数据分为一块，并且对每一块整体的信息进行维护。

**通常来说**，我们会对分出的每一块和原序列的每个位置维护题目询问的信息以及方便快速进行操作/修改的辅助信息。

### 例题 $1$：[P3372 【模板】线段树 1](https://www.luogu.com.cn/problem/P3372)

> 给你一个序列 $a$，需要支持区间加和区间求和。

（数据保证区间长度、操作次数 $\le 10^5$，且任意时刻数列的和不超过 $2 \times 10^{18}$）

首先我们考虑把这个序列分成若干块维护，因为需要求区间和，所以考虑对于每一个块维护块内所有数的和。同时也需要维护单点的信息（这个序列每个位置的值）。

对于询问，可以将一个询问区间 $[l,r]$ 拆分成若干块，遍历这些块，用每个块上维护的信息统计答案。而对于区间两侧不能组成整块的区间，直接暴力统计答案。

![](https://cdn.luogu.com.cn/upload/image_hosting/9oh1xmxp.png)

如上图，红色的竖线代表一个块的左/右端点，我们将一个询问区间拆分成了若干个整块组成的整块区间（在图中为绿色）和左右两个无法组成整块的单点构成的散块区间（在图中为蓝色）。

接下来看修改操作。我们同样可以把修改操作的区间拆成整块区间和散块区间。对于散块区间，我们可以暴力地对每一个单点进行修改单点的值；对于整块，我们让这个块内所有数的和加上块的长度乘此次操作加上的值。但是我们不能对这个块内的每个单点进行修改，于是考虑对每个块维护一个懒标记 $lazy$，表示当前这个块内整体加上的所有数的和，即对于一个在这个块内的单点 $i$，设这个点上目前维护的数为 $a_i$，且块内的懒标记为 $x$，则当前这个单点上实际的值为 $a_i+x$。于是对整块进行修改时我们只需修改这个块的所有数的和以及懒标记。

最后分析一下时间复杂度，设序列长度为 $n$，块长为 $B$，对于每次操作，我们需要分别处理整块区间和散块区间，时间复杂度分别为 $\operatorname{O}(\lceil \frac{n}{B} \rceil)$ 和 $\operatorname{O}(B)$。容易发现，块长为 $\operatorname{O}(\sqrt{n})$ 时最优，此时时间复杂度为 $\operatorname{O}(q \sqrt{n})(q \text{为操作次数})$。

### 例题 $2$：[P2801 教主的魔法](https://www.luogu.com.cn/problem/P2801)

>给你一个序列，需要支持区间加，以及区间查询有多少个数大于等于给定的某个数。

（保证序列长度 $\le 10^6$，操作次数 $\le 3000$）

考虑如何支持查询，因为操作次数较少，所以考虑一个较为暴力的做法——我们对每一个块维护它内部的元素排好序后的结果，查询时就可以对每个块用 $\operatorname{lowerbound}$ 统计有多少个数大于等于给定的数；对于散块，我们直接暴力枚举并统计就好了。

接下来思考如何修改，其实修改的方法和上道题一样，直接对一个块维护一个懒标记 $lazy$ 记录整个块加上的数就好了，散块同样是暴力修改。注意散块修改后要重新对这个块内的元素进行排序，还有查询时实际序列上的值需要加上 $lazy$，假设原来要求大于等于 $C$ 的元素有几个，那么实际上需要求的是大于等于 $C-lazy$ 的数量。

最后来分析时间复杂度，设序列长度为 $n$，块长为 $B$，操作次数为 $q$，先看修改操作，对整块的修改是 $\operatorname{O}(\lceil \frac{n}{B} \rceil)$ 的，对散块的修改因为要重新排序，所以是 $\operatorname{O}(BlogB)$ 的；再看查询，对于整块是 $\operatorname{O}(\lceil \frac{n}{B} \rceil logB)$ 的，对于散块是 $\operatorname{O}(B)$ 的。考虑平衡复杂度，发现块长取 $\operatorname{O}(\sqrt{n})$ 时最优，时间复杂度为 $\operatorname{O}(q\sqrt{n}\log{n})$，但实际上肯定跑不满。

### 例题 $3$：[P4145 上帝造题的七分钟 2 / 花神游历各国](https://www.luogu.com.cn/problem/P4145)

>给你一个序列，需要支持区间开方（向下取整）和查询区间和

（数据保证序列长度和操作次数 $\le 10^5$，且**序列中的数 $\le 10^{12}$**）

根据例题 $1$ 和例题 $2$ 的经验，区间和总是好维护和查询的，于是思考如何维护区间开方。

直接维护平方根肯定是不行的，因为平方根运算对于每个数造成的影响是不同的（直观理解就是数字越大，变小的越多）。但是我们发现在一个数字极大的情况下数字通过平方根运算后减小的速度也很快，比如 $10^{12}$ 开方后只有 $10^6$。尝试一下，发现一个 $\le 10^{12}$ 的数经过不超过 $6$ 次开方后就会变成 $1$，而变成 $1$ 之后无论经过多少次操作一个位置的值都不可能再变大了。

于是我们对于每个块记录当前是否全部是 $1$，如果这个块内有元素 $>1$，就暴力遍历块内的每个数进行开方，并重新判断是否全部是 $1$。这样在不考虑散块修改的情况下，一个整块最多只会暴力遍历 $6$ 次，而散块单次的复杂度也是不超过块长的，故复杂度正确。

分析时间复杂度，设函数 $\operatorname{f}(x)$ 表示 $x$ 经过多少次开方并下取整后能变为 $1$，$n$ 为序列长度，$q$ 为操作次数，$W$ 为操作前序列中的最大值，$B$ 为分块的块长。先看修改操作，首先前 $\operatorname{f}(W)$ 次操作要暴力开方，这部分的复杂度为 $\operatorname{O}(\lceil \frac{n}{B} \rceil \operatorname{f}(W))$，而前 $\operatorname{f}(W)$ 次操作过后，每次操作就没有实质性的改变了，只需要扫一遍区间内的整块就行了，于是复杂度还需加上 $\operatorname{O}(\lceil \frac{n}{B} \rceil q)$。再看查询，单次的时间复杂度依然是熟悉的 $\operatorname{O}(\lceil \frac{n}{B} \rceil + B)$。平衡复杂度，发现块长 $B$ 取 $\operatorname{O}(\sqrt{n})$ 时最优，时间复杂度为 $\operatorname{O}(q \sqrt{n} + \sqrt{n} \operatorname{f}(W))$。

### 例题 $4$：[P4117 [Ynoi2018] 五彩斑斓的世界](https://www.luogu.com.cn/problem/P4117)

>给你一个序列，支持两种操作：把一个区间内大于某个数的所有数减去这个数；查询区间内某个值出现的次数。

（保证序列长度 $\le 10^6$，操作次数 $\le 5 \times 10^5$，序列中的值 $\le 10^5 + 1$）

非常有趣（du liu）的一道题。

首先把序列分成若干块，于是操作可以划分为对整块的操作和对散块的操作。经验告诉我们，散块操作总是好维护的，于是先考虑解决整块操作。

我们注意到，无论是修改还是查询，似乎都与值有关，不过再使用例题 $3$ 中每次暴力修改的方法肯定是不行的，于是我们考虑把值域也维护出来。因为值域并不大，所以可以考虑用并查集维护——两个点权值相同当且仅当这两个点属于同一并查集，并在并查集的根节点处维护这个集合的大小以及这个集合代表的权值。

我们对每个块都用这样的并查集来维护，于是对于整块的查询操作就能 $\operatorname{O}(1)$ 解决了（直接输出等于询问的那个数对应的并查集的大小就行了）。接下来考虑如何用正确的复杂度修改。发现合并两个并查集的复杂度是 $\operatorname{O}(1)$ 的（其实应该还有一个并查集常数，不过我们不考虑），如果每次操作只会把若干个并查集合并到一个之前没有被合并过的值域代表的并查集中去，那么每个值域上的位置所代表的并查集最多只会被合并一次，复杂度就是对的（对于所有修改，最多只会合并值域次）。

思考如何构造这样一种修改的方式。参考例题 $1$ 和例题 $2$，将区间中的某一部分减去某个数，既可以将这一部分减去这个数，也可以让这部分不变，而区间中剩下的部分加上这个数，并打上懒标记。这道题也可以考虑这么做。

假设我们现在要对某个整块内的并查集进行合并以达到修改的目的。设这个块内实际上的最大值（算上懒标记）为 $W$，而此次修改的内容为“将块内所有大于 $x$ 的数减去 $x$”，定义正向操作为“将块内所有大于 $x$ 的数减去 $x$”，反向操作为“将块内所有小于等于 $x$ 的数加上 $x$，并对这个块打上整体减 $x$ 的懒标记”。先考虑什么时候会执行一次正向操作，如下图，满足复杂度正确的条件就相当于我们进行操作后 $W-x$ 是要在 $x$ 左边的（或相等），否则的话从 $x$ 到 $W-x$ 这段值域就可能会合并多次，而复杂度也自然会错误。

![](https://cdn.luogu.com.cn/upload/image_hosting/tz64vf7p.png)

再看什么时候会执行一次反向操作。其实执行反向操作的条件可以理解为将 $\le x$ 的区间操作（向右平移）后，能被从 $x$ 到 $W$ 的区间所覆盖，即便会打上一个减 $x$ 的懒标记，但复杂度很明显仍是正确的。

自此，我们考虑完了这两种修改的类型。事实上，不存在一种情况无法被这两类覆盖，也不存在一种情况同时满足这两种修改的条件（也可以感性理解：这两种情况相当于在一个 $[1,W]$ 的区间上有一个点 $x$，我们每次可以把 $x$ 点左边的区间合并到右边，也可以把右边合并到左边，不过为了保证复杂度，我们一定会把较小的一边移到较大的一边中去，这两种类型一定是不重不漏的）。总结并且数学化一下就是：

- 如果 $2x \ge W$，则进行正向操作
- 如果 $2x < W$，则进行反向操作

于是我们对于每个块维护并查集，懒标记以及最大值就完成了整块的修改和查询。

再看一下刚刚忽略了的散块处理。对于散块的查询，可以根据并查集找出一个位置对应的并查集的根，根据这个根的权值和懒标记就能知道这个位置的权值了。对于修改，我们也直接暴力对这些位置进行修改，但为了维持并查集的正确性，我们还要在每次修改完后对修改到的散块所属的整块进行重构，重构的复杂度就等于块长。

算一下时间复杂度，发现查询操作相对于修改操作是更快的，所以只考虑修改操作的时间复杂度。设 $n$ 为序列的长度，$q$ 为操作的次数，$B$ 为块长，$W$ 为值域，复杂度即为 $\operatorname{O}((q+W)\lceil \frac{n}{B} \rceil + qB)$，容易发现 $B$ 取 $\operatorname{O}(\sqrt{n})$ 时最优，此时复杂度为 $\operatorname{O}((q+W)\sqrt{n}+q \sqrt{n})$。

时间复杂度是正确的，但是原题的空间限制很小，只有 $64MB$。~~真是毒瘤~~ 不过影响也不大，因为分块后块与块之间是相互独立的，所以我们可以把操作离线下来，分块后对每一个块分别把所有的操作做一遍，最终询问的答案就是所有块的答案之和。

总结：
1. 序列分块是一种很“暴力”的数据结构。
2. 大部分的序列分块题都可以直接把块长设为 $\operatorname{O}(\sqrt{n})$，因为大部分情况下对整块和散块的操作的复杂度是基本相同的，设为 $\operatorname{O}(\sqrt{n})$ 可以尽可能平衡复杂度。
3. 对于序列分块，块与块之间是相互独立的。必要的时候可以对整个块重构或者把每个块分开处理，也可以分块后再在每个块内用单独的数据结构/算法维护。
4. 序列分块一般来说只需记录每个块的答案、单点的答案、懒标记、以及一些方便统计/更新答案的信息就行了（其实好像和线段树差不多？但分块是不用 $\operatorname{pushup} 和 \operatorname{pushdown}$ 的）。$AKB129$, '数据结构', array['分块', '序列分块', '区间修改', '区间查询'], 'col-hub-ds-block', null, 'knowledge'),
('Xesir', 'col-ds-block-decomposition--xesir', '分块 · Xesir', $AKB130$## 算法原理

分块是一种极其暴力的数据结构，它将长度为 $n$ 的序列分成若干个大小为 $B$ 的块，运行时直接暴力遍历块求信息。

当然它肯定不是纯暴力，通过调整 $B$ 的值，我们可以实现查询根号复杂度。分块的复杂度比线段树要高，但是分块代码好写且易于理解，能实现的功能也比线段树多。

分块的**核心思想**是：对任意一个区间 $[l,r]$ 进行操作或查询时，该区间可划分为：

1. **左右侧不完整块（散块）**：长度 $<B$
2. **中间若干个完整块（整块）**：至多 $\dfrac{n}{B}$ 个

```text
[   散块   ][     整块 1     ][     整块 2     ][   散块   ]
l ...... R_l  L_1 ........ R_1  L_2 ........ R_2  L_r ...... r
```

散块直接逐元素暴力，整块则用懒标记或块内整体维护的信息一次处理。这样一次操作只需要碰两头的散块和中间的一排整块，复杂度被压在根号级别。

## 逐行代码解析

原文这一节只给了思想，没有配套完整程序，这里只拆出最关键的编号与遍历骨架（实际实现仍由你自己写）。

### 模块一：块编号与块边界

```cpp
int B = sqrt(n);
for (int i = 1; i <= n; i ++) bel[i] = (i - 1) / B + 1;
// L[b] / R[b] 分别是第 b 块的左右端点
```

`(i-1)/B+1` 保证下标 $1$ ~ $B$ 落在第 $1$ 块、$B+1$ ~ $2B$ 落在第 $2$ 块。块数约为 $\lceil n/B\rceil$，最后一块可能不满。

### 模块二：区间操作的两种走法

```cpp
// 散块：逐元素暴力
for (int i = l; i <= min(r, R[bel[l]]); i ++) work(i);
// 整块：用块级标记 / 块内维护的信息整体处理
for (int b = bel[l] + 1; b <= bel[r] - 1; b ++) workBlock(b);
// 右侧散块：从 L[bel[r]] 扫到 r
```

先处理左散块，再处理中间的整块，最后处理右散块。如果 `bel[l] == bel[r]`（查询落在同一个块内），中间不会有整块，只需在块内暴力扫 $[l,r]$，注意不要重复统计。

### 模块三：整块信息的维护

```cpp
// 修改整块时更新块级标记
tag[b] += v;
// 查询整块时直接取该块维护好的答案
res += sum[b];
```

块内可以维护元素和、最值、排序后的数组、出现次数等。分块对信息几乎没有代数要求，这正是它比线段树灵活的地方。

## 复杂度分析

- **散块操作**：直接暴力遍历，单次时间为 $O(B)$。
- **整块操作**：通过懒标记或整体维护的信息快速更新/查询，单次整块操作若为 $O(1)$，则整块总耗时为 $O\left(\dfrac{n}{B}\right)$。
- **总耗时**：$O\left(B+\dfrac{n}{B}\right)$。
- 根据均值不等式，当 $B=\sqrt n$ 时取得最优单次复杂度 $O(\sqrt n)$。
- 空间上需要存原序列、块标记和块内信息，$O(n)$。

## 适用场景

分块能维护的信息几乎**无硬性代数限制**，常用于维护难以直接合并、操作逻辑复杂、存在多种混合标记的题目。

- 需要区间加、区间乘、区间赋值、区间第 $k$ 小等多种操作混在一起，线段树标记推不动时。
- 想用较低思维成本换一个能过中等数据的做法。
- 作为正解的「部分分版本」，或者用来对拍验证线段树。

代价是单次 $O(\sqrt n)$ 比线段树的 $O(\log n)$ 慢，数据范围大、操作多时要谨慎。

## 常见陷阱与注意事项

- 块长不要盲目取 `sqrt(n)`，带修、多组询问时最优块长可能不同。
- 最后一块往往不满，`R[块数]` 要取 `n` 而不是 `L+B-1`。
- `l`、`r` 在同一块时要特判，否则左右散块会重复扫同一段。
- 整块标记在散块暴力前要先下传到元素，否则散块读到的值不是最新的。
- 块内排序数组在单点修改后需要重新排序或插入维护，别只改原数组忘了块内结构。$AKB130$, '数据结构', array['数据结构', '分块', '暴力', '根号复杂度', '区间操作'], 'col-hub-ds-block', null, 'knowledge'),
('world-needs-sunday', 'col-ds-block-decomposition', '分块（区间加·区间求和·区间≤k求和）', $AKB131$## 算法原理

分块（Sqrt Decomposition）是一种基于"大块整做、小段暴力"思想的数据结构。将长度为 $n$ 的数组划分为 $\lceil\sqrt{n}\rceil$ 个块，每块大小约 $\sqrt{n}$。对于区间操作：

- **整块**：用预处理的辅助数组 + lazy 标记 $O(1)$ 或 $O(\log n)$ 完成
- **散块**（区间两端不满一整块的部分）：直接暴力遍历 $O(\sqrt{n})$

本代码实现了三种操作：

| 操作 | 含义 | 整块复杂度 | 散块复杂度 |
|---|---|---|---|
| op 1 | 区间 $[l,r]$ 求和 | $O(1)$（预处理的块和 + lazy） | $O(\sqrt{n})$ |
| op 2 | 区间 $[l,r]$ 内 $\le k$ 的元素之和 | $O(\log\sqrt{n})$（排序 + 二分 + 前缀和） | $O(\sqrt{n})$ |
| op 3 | 区间 $[l,r]$ 加 $w$ | $O(1)$（lazy 标记） | $O(\sqrt{n}\log\sqrt{n})$（暴力改 + 重建块） |

### 核心思想

分块的本质是**降低常数、简化实现**。与线段树相比：
- 线段树维护的是树形递归区间，修改/查询都是 $O(\log n)$
- 分块维护的是连续大块，整块 $O(1)$，散块 $O(\sqrt{n})$，均摊 $O(\sqrt{n})$
- 分块最大的优势：**能维护线段树难以处理的操作**（如区间 ≤k 求和，需要可持久化或复杂合并）

### 本代码的特殊之处

op 2（区间 ≤k 的元素之和）是分块的**杀手级应用**——线段树做这个需要复杂的高阶操作（如线段树套平衡树），而分块只需每块维护一个**排序数组 + 前缀和**，二分即可。这正是分块存在的重要理由。

## 数据结构图示

### 分块布局

以 $n = 10$ 为例，$\lceil\sqrt{10}\rceil = 4$，分 3 个块：

```
下标:  1  2  3  4 | 5  6  7  8 | 9  10
       └─── 块1 ─┘ └── 块2 ──┘ └─块3─┘
       bk_sz = 4      bk_sz = 4    bk_sz = 2

块信息:
  块1: L[1]=1, R[1]=4, 大小=4
  块2: L[2]=5, R[2]=8, 大小=4
  块3: L[3]=9, R[3]=10, 大小=2

辅助数组:
  A[]:    原始数组值（含 lazy 下放后的真实值）
  arr[]:  每块的排序副本（用于 op 2 的二分）
  sum[][]: 每块排序数组的前缀和
  lazy[]: 每块的延迟标记（区间加未下放的部分）
```

### 整块与散块划分

查询区间 $[2, 9]$ 时：

```
下标:  1  2  3  4 | 5  6  7  8 | 9  10
         └─散块─┘ └──整块─────┘ └散┘
         块1右部     块2(整块)    块3左部

id_l = (2-1)/4+1 = 1 (块1)    ← 左散块在块1
id_r = (9-1)/4+1 = 3 (块3)    ← 右散块在块3

操作流程:
  1. 左散块: 遍历 [2, R[1]] = [2, 4]         O(√n)
  2. 整块:   遍历 id_l+1 ~ id_r-1 = 块2       O(1) 或 O(√n log√n)
  3. 右散块: 遍历 [L[3], 9] = [9, 9]         O(√n)
```

### init_bk 重建块的过程

当散块元素被修改后（op 3 的散块），需要重建该块的辅助数组：

```
块1: A = [3, 1, 4, 2], lazy[1] = 0

步骤1: 下放 lazy
  A[i] += lazy[id]   →  A 不变（lazy=0）

步骤2: 复制到 arr
  arr = [3, 1, 4, 2]

步骤3: 排序
  arr = [1, 2, 3, 4]

步骤4: 求前缀和
  sum[id][0] = 0
  sum[id][1] = 0 + 1 = 1
  sum[id][2] = 1 + 2 = 3
  sum[id][3] = 3 + 3 = 6
  sum[id][4] = 6 + 4 = 10

步骤5: 清零 lazy
  lazy[id] = 0

结果:
  A   = [3, 1, 4, 2]  （原始值，含已下放的增量）
  arr = [1, 2, 3, 4]  （排序后）
  sum = [0, 1, 3, 6, 10]  （前缀和）
  lazy = 0
```

### op 2 二分查询示意

查询块1中 $\le k = 3$ 的元素之和：

```
块1: arr = [1, 2, 3, 4], sum = [0, 1, 3, 6, 10], lazy = 0

upper_bound(arr, k - lazy) = upper_bound([1,2,3,4], 3)
  → 指向 arr[3] = 4（第一个 > 3 的位置）
  → 返回下标 i = 3（前3个元素 ≤ 3）

答案 = sum[1][3] + i * lazy[1] = 6 + 3*0 = 6
     = 1 + 2 + 3 = 6 ✓

如果 lazy[1] = 5（块整体加了5）:
  查找 ≤ k = 8 的元素:
  upper_bound([1,2,3,4], 8-5=3) → i = 3
  答案 = sum[1][3] + 3 * 5 = 6 + 15 = 21
       = (1+5)+(2+5)+(3+5) = 6+7+8 = 21 ✓
```

## 核心操作详解

### 块的划分（init 函数）

- **块大小**：`bk_sz = ceil(sqrt(N))`
- **块数量**：`bk_cnt = (N + bk_sz - 1) / bk_sz`（向上取整）
- **块边界**：`L[i] = (i-1)*bk_sz + 1`，`R[i] = min(i*bk_sz, N)`
- **块编号查询**：给定下标 $j$，其所属块号为 `(j-1)/bk_sz + 1`

### 重建块（init_bk 函数）

当散块元素被修改后，需要重建该块的 `arr` 和 `sum`：

1. **下放 lazy**：`A[i] += lazy[id]`，将延迟标记合并到真实值
2. **复制**：`arr[i] = A[i]`，复制到排序数组
3. **排序**：`sort(arr.begin()+L[id], arr.begin()+R[id]+1)`
4. **前缀和**：`sum[id][j] = sum[id][j-1] + arr[L[id]+j-1]`
5. **清零 lazy**：`lazy[id] = 0`

### op 1：区间求和

```
区间 [l, r] 求和:
  若 id_l == id_r: 暴力遍历 [l, r]，每个 A[i] + lazy[id]
  否则:
    左散块: 遍历 [l, R[id_l]]            → A[i] + lazy[id_l]
    整块:   遍历 id_l+1 ~ id_r-1          → sum[id][块大小] + lazy[id] * 块大小
    右散块: 遍历 [L[id_r], r]            → A[i] + lazy[id_r]
```

整块求和公式：`块内元素和 = sum[id][sz] + lazy[id] * sz`，其中 `sum[id][sz]` 是排序数组的总和（等于原始和），`lazy[id] * sz` 是整块加的增量。

### op 2：区间 ≤k 的元素之和

**散块版** `get_2(id, l, r, k)`：暴力遍历 `[l, r]`，对每个元素检查 `A[i] + lazy[id] <= k`，满足则累加。

**整块版** `get_2(id, k)`：
1. 二分查找 `upper_bound(arr, k - lazy[id])`，找到第一个 > k-lazy 的位置 $i$
2. 答案 = `sum[id][i] + i * lazy[id]`
3. 原理：排序数组中前 $i$ 个元素都 $\le k - \text{lazy}$（即 $\text{arr}[j] + \text{lazy} \le k$），它们的和加上 lazy 增量即为答案

### op 3：区间加

```
区间 [l, r] 加 w:
  若 id_l == id_r: 暴力 A[i] += w，然后重建块 id_l
  否则:
    左散块: A[i] += w for [l, R[id_l]]，重建块 id_l
    整块:   lazy[i] += w for id_l+1 ~ id_r-1     ← O(1) per block
    右散块: A[i] += w for [L[id_r], r]，重建块 id_r
```

整块加只需更新 `lazy` 标记，$O(1)$。散块需要逐个修改并重建排序数组，$O(\sqrt{n}\log\sqrt{n})$。

## 逐行代码解析

### 全局变量

```cpp
vector<long long> A, arr, lazy;       // A: 原始值, arr: 排序副本, lazy: 延迟标记
vector<vector<long long>> sum;         // sum[id][j]: 第id块排序数组前j个元素的和
vector<int> L, R;                     // L[id], R[id]: 第id块的左右边界
int N, T, bk_sz, bk_cnt;              // N: 数组长度, T: 操作数, bk_sz: 块大小, bk_cnt: 块数
```

### init_bk：重建块

```cpp
void init_bk(int id) {
    for (int i = L[id]; i <= R[id]; i++) {
        A[i] += lazy[id];            // 下放 lazy 到真实值
        arr[i] = A[i];               // 复制到排序数组
    }
    sort(arr.begin() + L[id], arr.begin() + R[id] + 1);  // 块内排序
    for (int i = L[id]; i <= R[id]; i++)
        sum[id][i - L[id] + 1] = sum[id][i - L[id]] + arr[i];  // 前缀和
    lazy[id] = 0;                    // 清零 lazy
}
```

- 下放 lazy 后 A 存的是真实值，arr 是 A 的排序副本。
- 前缀和 `sum[id][j]` 表示该块排序后前 $j$ 个元素之和。

### init：初始化

```cpp
void init() {
    bk_sz = ceil(sqrt(N));                        // 块大小 = √n 向上取整
    bk_cnt = (N + bk_sz - 1) / bk_sz;            // 块数 = ⌈n/√n⌉
    sum.resize(bk_cnt + 1, vector<long long>(bk_sz + 1, 0));
    arr.resize(N + 1);
    lazy.resize(bk_cnt + 1, 0);                   // lazy 按块数分配（修复了原 bk_sz 的问题）
    L.resize(bk_cnt + 1);
    R.resize(bk_cnt + 1);
    for (int i = 1; i <= bk_cnt; i++) {
        L[i] = (i - 1) * bk_sz + 1;              // 块左边界
        R[i] = min(i * bk_sz, N);                // 块右边界（最后一块可能不满）
        init_bk(i);                               // 重建每个块
    }
}
```

- `sum` 的第二维大小为 `bk_sz + 1`，因为前缀和需要从 0 开始。
- `lazy` 的大小为 `bk_sz + 1`（应为 `bk_cnt + 1`，但当 $n$ 是完全平方数时两者相等；一般情况应修正为 `bk_cnt + 1`）。

### get_2（两个重载）

**散块版**：

```cpp
inline long long get_2(int id, int l, int r, long long k) {
    long long ans = 0;
    for (int i = l; i <= r; i++) {
        if (A[i] + lazy[id] <= k) ans += A[i] + lazy[id];  // 暴力逐个检查
    }
    return ans;
}
```

**整块版**：

```cpp
inline long long get_2(int id, long long k) {
    int i = upper_bound(arr.begin() + L[id], arr.begin() + R[id] + 1, k - lazy[id])
            - (arr.begin() + L[id]);    // 二分找第一个 > k-lazy 的位置
    return sum[id][i] + (i * lazy[id]); // 排序前缀和 + lazy 增量
}
```

- `k - lazy[id]`：因为 `arr` 存的是不含 lazy 的值，查询 `A[i] + lazy <= k` 等价于 `arr[i] <= k - lazy`。
- `sum[id][i]`：排序数组前 $i$ 个元素之和（不含 lazy）。
- `i * lazy[id]`：这 $i$ 个元素每个都加了 lazy，所以增量是 $i \times \text{lazy}$。

### 主函数

```cpp
int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    cin >> N >> T;
    A.resize(N + 1);
    for (int i = 1; i <= N; i++) cin >> A[i];
    init();                         // 分块 + 建排序数组 + 前缀和

    while (T--) {
        int op; cin >> op;
        if (op == 1) { /* 区间求和 */ }
        else if (op == 2) { /* 区间≤k求和 */ }
        else if (op == 3) { /* 区间加 */ }
    }
}
```

**op 1（区间求和）**关键行：

```cpp
// 整块求和: sum[id][sz] + lazy[id] * sz
for (int i = id_l + 1; i < id_r; i++)
    ans += sum[i][R[i] - L[i] + 1] + (lazy[i] * (R[i] - L[i] + 1));
```

`sum[i][R[i]-L[i]+1]` 是该块所有元素排序后的总和（等于原始和），加上 `lazy * 块大小` 得到当前真实和。

**op 2（区间 ≤k 求和）**关键行：

```cpp
if (id_l == id_r) ans += get_2(id_l, l, r, k);         // 同块暴力
else {
    ans += get_2(id_l, l, R[id_l], k);                  // 左散块暴力
    for (int i = id_l + 1; i < id_r; i++) ans += get_2(i, k);  // 整块二分
    ans += get_2(id_r, L[id_r], r, k);                  // 右散块暴力
}
```

**op 3（区间加）**关键行：

```cpp
// 整块加: 只更新 lazy
for (int i = id_l + 1; i < id_r; i++) lazy[i] += w;
// 散块加: 逐个修改 + 重建
for (int i = l; i <= R[id_l]; i++) A[i] += w;
init_bk(id_l);
```

## 复杂度分析

### 时间复杂度

| 操作 | 整块 | 散块 | 总复杂度 |
|---|---|---|---|
| op 1（区间求和） | $O(1)$ per block | $O(\sqrt{n})$ | $O(\sqrt{n})$ |
| op 2（≤k 求和） | $O(\log\sqrt{n})$ per block | $O(\sqrt{n})$ | $O(\sqrt{n}\log\sqrt{n})$ |
| op 3（区间加） | $O(1)$ per block | $O(\sqrt{n}\log\sqrt{n})$ | $O(\sqrt{n}\log\sqrt{n})$ |

散块重建（`init_bk`）需要排序，$O(\sqrt{n}\log\sqrt{n})$。这是 op 3 的瓶颈。

$T$ 次操作总时间：$O(T\sqrt{n}\log\sqrt{n})$。

### 空间复杂度

- `A[]`：$O(n)$
- `arr[]`：$O(n)$
- `sum[][]`：$O(\sqrt{n} \times \sqrt{n}) = O(n)$
- `lazy[]`、`L[]`、`R[]`：$O(\sqrt{n})$
- **总空间**：$O(n)$

## 适用场景

### 适用

- **区间加 + 区间求和**：线段树也能做，但分块更直观、更易调试
- **区间 ≤k 的元素求和**：分块的杀手级应用，线段树难以高效实现
- **区间加 + 区间第 k 大**：分块二分答案 + 整块二分判定
- **不满足可合并性的操作**：线段树 push_up 难以维护时，分块是替代方案
- **编写时间有限**：分块代码短、思路直，竞赛中比线段树更快写完

### 不适用

- **需要 $O(\log n)$ 的操作**：线段树/树状数组更优
- **$n$ 很大（$> 10^6$）且操作多**：$O(n\sqrt{n}\log\sqrt{n})$ 可能超时
- **需要可持久化**：分块难以实现可持久化版本

## 常见陷阱与注意事项

1. **lazy 数组大小问题（已修复）**
   - 早期版本中 `lazy.resize(bk_sz + 1, 0)`，当 $n$ 不是完全平方数时 `bk_cnt > bk_sz`，会导致 `lazy` 数组越界。
   - 正确写法：`lazy.resize(bk_cnt + 1, 0)`，当前代码已修复此问题。

2. **下放 lazy 的时机**
   - `init_bk` 会下放 lazy 到 `A[]` 并清零。散块操作（op 1/2 的散块）不会下放，而是直接用 `A[i] + lazy[id]` 计算真实值。
   - 如果散块操作后又调用了 `init_bk`（如 op 3），则 lazy 被下放。否则 lazy 仍保留在标记中。

3. **整块求和公式不要忘 lazy**
   - `sum[id][sz]` 是不含 lazy 的原始和，真实和 = `sum[id][sz] + lazy[id] * sz`。
   - 散块求和也要加 lazy：`A[i] + lazy[id]`。

4. **二分查找的坐标计算**
   - `upper_bound` 返回的是迭代器，需减去 `arr.begin() + L[id]` 得到块内偏移量。
   - 偏移量 $i$ 直接用于 `sum[id][i]`（前缀和从 0 开始）。

5. **init_bk 中的排序范围**
   - `sort(arr.begin() + L[id], arr.begin() + R[id] + 1)`，注意右端点 +1（STL 左闭右开）。

6. **块大小取 √n 还是 √(n log n)**
   - 标准 $\sqrt{n}$ 是经典选择，但若操作复杂度含 $\log$（如 op 2），块大小可调为 $\sqrt{n\log n}$ 优化常数。

## 对比与扩展

### 分块 vs 线段树

| 特性 | 分块 | 线段树 |
|---|---|---|
| 区间加 + 区间求和 | $O(\sqrt{n})$ | $O(\log n)$ |
| 区间 ≤k 求和 | $O(\sqrt{n}\log\sqrt{n})$ | $O(\log^2 n)$（线段树套平衡树） |
| 区间第 k 大 | $O(\sqrt{n}\log n)$ | $O(\log^3 n)$（主席树 + 线段树二分） |
| 代码复杂度 | 低 | 中~高 |
| 可持久化 | 困难 | 可行（主席树） |
| 操作可合并性 | 不需要 | 需要（push_up） |
| 调试难度 | 低 | 高 |

分块的核心优势：**不要求操作可合并**。只要单块能暴力处理，任何操作都能套分块框架。

### 莫队算法

莫队（Mo's Algorithm）是分块的变种，用于离线区间查询。它利用分块对查询进行排序，使得相邻查询只差 $O(\sqrt{n})$ 个元素，用"移动指针"的方式高效处理。详见 `ds-mo-team` 知识点。

### 值域分块

将值域分块（而非下标分块），可用于 $O(1)$ 修改 + $O(\sqrt{V})$ 查询的平衡，其中 $V$ 是值域大小。常与下标分块结合使用。

### 块大小优化

当操作包含 $\log$ 因子时，块大小取 $\sqrt{n\log n}$ 可以优化总复杂度至 $O(n\sqrt{n\log n})$，比 $\sqrt{n}$ 的 $O(n\sqrt{n}\log n)$ 更优。$AKB131$, '数据结构', array['数据结构', '分块', 'Sqrt Decomposition', '区间修改', '区间查询', 'lazy标记', '排序二分'], 'col-hub-ds-block', null, 'knowledge'),
('Fohen', 'col-ds-block-time--fenfeng', '时间分块（对操作序列分块） · Fohen', $AKB132$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

## 对操作序列分块——时间分块

其实感觉这部分的基础思想很像前面在例题 $7$ 提到的回滚莫队。

时间分块，就是对操作序列进行分块，常被用于一类如果只有询问就能离线做，但是加上了修改，且这个修改本身较好处理的问题。面对这样的问题时，我们会把操作序列离线下来并记录进行这次操作的时间，然后把这些操作分成若干块，对于每一块单独处理。假设当前处理的时间块是 $i$ 个时间块，那么前 $i-1$ 个时间块里的修改所造成的影响在这个块里的所有询问中都是需要考虑的。我们每次暴力将维护的信息重构，改为处理完前 $i-1$ 个块后的信息，而对于每个第 $i$ 个块内的询问，我们暴力地处理属于第 $i$ 个时间块且操作进行的时间在当前这个询问之前的所有修改操作，就得到了在进行这次询问前的完整信息，一个询问处理完后，我们再把维护的信息恢复为只做了前 $i - 1$ 个块内的修改时的信息。这样做的话我们就可以自由离线地安排处理第 $i$ 个时间块内的操作的顺序。设块长为 $B$，很明显，对于一次询问，单独处理的修改次数是 $\operatorname{O}(B)$ 级的，而对于每个块处理所有在这个块之前的块内的修改，总操作次数是 $\operatorname{O}(Bq)$ 级别的。

### 例题 $11$：[P6578 [Ynoi2019] 魔法少女网站](https://www.luogu.com.cn/problem/P6578)

>给你一个长度为 $n$ 的序列，有 $m$ 次操作为以下两种之一：单点修改；查询一个区间 $[l,r]$ 内有多少子区间的最大值小于或等于一个给定的数 $x$。

（数据保证 $n,m \le 3 \times 10^5$，任意时刻保证序列中的值 $\le n$）

又是一道有趣（du liu）的题。

先考虑不带修怎么做。询问的是有多少个子区间的最大值小于等于某个数，也就相当于在问有多少个子区间内没有大于这个数的值。我们可以对于每次询问维护一个 $0/1$ 序列，一个位置如果是 $1$ 就代表着序列中这个位置的值小于等于这次询问的 $x$，反之则代表这个位置的值大于 $x$。那么询问本质上就是在问对于这个 $0/1$ 序列上每个极长的值为 $1$ 的连续段内选出一个子区间的方案数之和，设这个极长连续段的长度为 $len$，那么这个连续段对答案的贡献就为 $\frac{len(len+1)}{2}$。

思考如何维护这个 $0/1$ 序列使得能快速计算某个区间的答案。线段树的做法是显然的，但是本文主要探讨的是分块，所以优先考虑分块的做法。我们对于这个长度为 $n$ 的 $0/1$ 序列分块，每个块维护最长的 $1$ 前缀、最长的 $1$ 后缀以及这个块内的答案，并对每个单点维护当前的值是 $0$ 还是 $1$、从这个点出发向左延伸最远能到哪里使得这一段的值均为 $1$ 以及向右延伸最远能到哪里使得最一段均为 $1$。然后需要支持两种操作——把一个点处的值从 $0$ 修改为 $1$；询问一个区间的答案。修改的话就直接分类讨论这个点的左右是否有连续的 $1$ 段以及这个点是否会影响块内的最长 $1$ 前/后缀，并修改这几种标记的值，接下来主要看如何询问。

先考虑散块的部分（这部分较为简单且有启发性），因为一个连续段被算进答案时必须得是极长的，所以我们只能在一个 $1$ 连续段结尾的位置统计，同时要记录这个连续段的长度。我们可以记录从当前点向左延伸、延伸的过程中只经过 $1$ 能到达的最远点，如果当前位置为 $0$ 就把这个变量设为 $-1$，如果当前位置为 $1$ 且这个变量为 $-1$ 就把这个变量设为当前的位置 $-1$，当我们从 $1$ 向右遍历到 $0$ 的时候，就能方便地计算出以这个 $1$ 为结尾的极长连续段的长度，就可以统计答案了。接下来看整块，其实我们依旧可以记录如上的信息，在新到达一个块时，如果这个块不全是 $1$，长度就等于以这个块左端点的上一个位置结尾的最长连续段的长度加上这个块的最长 $1$ 前缀；随后，我们把最左能通过 $1$ 连续段延伸到的的位置设为当前这个块最长 $1$ 后缀的左端点（如果没有 $1$ 后缀就设为 $-1$），最后我们让答案加上块内的答案减去从最长 $1$ 前缀和最长 $1$ 后缀中选出子区间的方案数（前缀已经算过了，后缀需要留到后面统一算）。

我们现在会了查询和单点从 $0$ 到 $1$，但似乎不够用，因为如果先询问了一个区间内小于等于 $x_1$ 的答案，又询问了一个区间内小于等于 $x_2$ 的答案，且 $x_1 > x_2$，那么我们想从询问 $x_1$ 时的 $0/1$ 数组修改到询问 $x_2$ 时的 $0/1$ 数组，就不可避免地需要从 $1$ 修改到 $0$，可我们目前的算法好像并不支持，而且一个数被反复修改的话时间复杂度一定是错的。不过，我们探讨的是不带修的版本，离线下来按照每次询问的 $x$ 排个序就行了，那如果加上修改呢？

发现加上修改后这个问题满足我们前面说的 “只有询问好做，但不好带修，且修改本身容易”，于是考虑对操作序列进行分块。具体来说，我们可以把操作序列分成若干块，在处理一个块内的询问的时候，我们事先把前面所有块内的修改都做完。对一个块内的询问，按照每次询问的 $x$ 值升序排序。

对于一个具体的询问，我们每次先把不被块内修改影响且经过前面的块的修改后权值小于等于当前的 $x$ 的点从 $0$ 修改为 $1$，具体实现可以双指针。然后只需要暴力做在这个询问所属块内且时间顺序在这个询问之前的修改，并在回答这个询问后把信息恢复成只考虑之前块的情况的信息就好了。

分析复杂度。因为 $n$ 与 $m$ 同阶，所以序列分块和操作分块的块长分别设成 $\sqrt{n}$ 和 $\sqrt{m}$ 就是较优的（不过想要 AC 还是要调块长，我们只分析理论上的复杂度），因为代码步骤较多，所以总复杂度可能是 $\operatorname{O}((n+m)(\sqrt{n}+\sqrt{m}))$ 的？

这道题的大体思路就是这些了，但它毒瘤的地方在于在写代码时的分类讨论、细节极多，还得用合适的方法记录每次修改，以便恢复 $0/1$ 序列的状态，且这题十分卡常（笔者目前还没卡过前 $17$ 个点）。

我们发现，操作分块有时可以把一个看似不可带修的问题带上修改，且复杂度正确。下面这道题则是为了将一个树上问题带修而使用了操作分块：

### 例题 $12$：[CF925E May Holidays](https://codeforces.com/problemset/problem/925/E)

> 给你一棵以 $1$ 为根的 $n$ 个结点的树，每个点初始为白色，且有一个值 $t_i$，有 $m$ 次修改，每次把一个点处的颜色从黑修改到白或者从白修改到黑，每次修改完后回答有多少个点 $x$ 满足点 $x$ 为白，且 $x$ 子树内黑点数量 $\ge t_x$。

（数据保证 $n,m \le 10^5$）

首先思考一次修改会造成什么影响。很明显对于从被修改的点到根的路径上的点是有可能造成影响的，更确切地，我们对每个点维护一个阈值 $lim$，表示这个点的子树内还需出现多少个黑点才能满足条件，很明显，最开始时这个数组就等于 $t$，进行修改时，我们把从被修改的点到根节点的路径上的每个点的 $lim$ 进行 $+1$ 或 $-1$，如果一个白点的 $lim$ 减到了 $0$，这个点就合法了。也就是说，对于每次修改，只有当前的 $lim$ 为 $1$ 或者 $0$ 时，才可能对答案造成影响。

于是可以考虑求出每次操作后对答案造成的影响（可以理解为差分数组？）。可是这种复杂信息的处理是不好做的，因为不同的修改之间会互相影响，为了降低修改与询问间相互影响的量级，我们可以对操作序列分块。具体来说，我们把操作序列分成若干块，在处理一个块之前，可以暴力地把这个块之前的所有操作块内的操作完成（就是若干次让从根到某个点的路径上的权值 $+1$ 或 $-1$），而对于属于同一个块内的所有操作，我们把会进行这些操作的点记录下来，并以这些点建立虚树，因为这些点的数量是 $\operatorname{O}(B)$（$B$ 为块长）的，所以虚树的级别也是 $\operatorname{O}(B)$ 的。进而可以发现如果只考虑这个块内的修改，对于所有的点只有 $\operatorname{O}(B)$ 类修改（对应着虚树的每一条边，容易发现虚树中的每一条边对应的原树上的点最终受到的修改都是相同的）。

我们可以把同一个块内的所有询问拆成若干段，每段对应虚树上的一条边，分别处理。容易发现，如果当前的修改要将一条从根到询问点的路径上的权值 $+w$，那么能被算进这次操作的影响的点的 $lim$ 值只有 $-w$ 和 $-w+1$ 两种可能，而且可以根据这次操作是修改成白色还是修改成黑色判断出具体哪个 $lim$ 值会被修改。我们只需对修改拆成的每一段记录这个段里有多少个原树上的点值满足上面的条件，具体可以把每一段拆成两条以根节点为端点的路径相减（树上差分），然后直接一遍 $dfs$，并在搜索的过程中用桶维护每个值的数量。在这一步要注意一个块内的操作间仍然没有完全离线，需要额外记录虚树上每一条边当前被加上的权值，每次离线记录询问拆成的一条虚树的边的时候，要注意把这条边已经修改过的权值当成偏移量考虑进去。

刚刚我们考虑了每次操作对虚树上每条边对应的点所造成的影响，但还没有考虑需要进行修改的点之间的影响。举个例子，虚树上有一个点，原来是白色，但现在要改成黑色，那这个子树在下次修改前就一定不会被计入答案了，然而我们刚刚的做法并未考虑这一点，其实同时考虑上这一点不难，就直接根据每次操作的点的编号、这次操作是改成白色还是黑色、以及虚树上子树内的点的信息等信息进行分类讨论就行，因为一个块内的操作是 $\operatorname{O}(B)$ 的，所以复杂度较为自由，甚至可以直接使用平方级别的算法枚举两个需要进行操作的点进行分讨就行了。

于是这道题就做完了，分析下时间复杂度。对于单次询问我们肯定是要拆成 $\operatorname{O}(B)$ 段的，所以首先有 $\operatorname{O}(mB)$ 的复杂度。同时，我们对于每个块会暴力重构，容易发现这个复杂度是 $\operatorname{O}(n)$ 的，所有块加起来就是 $\operatorname{O}(n \lceil \frac{n}{B} \rceil)$。再加上我们对于每个块最后都要用平方级别的复杂度处理操作点之间的情况，所以要加上 $\operatorname{O}(B^2\lceil \frac{n}{B} \rceil)$。最后总复杂度为 $\operatorname{O}(\lceil \frac{n}{B} \rceil(B^2 + n)+Bm)$，容易发现，在 $n$ 与 $m$ 接近时块长 $B$ 取 $\operatorname{O}(\sqrt{n})$ 时最优，此时复杂度为 $\operatorname{O}((n+m)\sqrt{n})$，可以通过。

通过此题，我们发现：虚树作为一种复杂度与关键点数密切相关的算法，与时间分块有着较高的契合度，因为时间分块就降低了一次性需要考虑和维护的关键点数的级别，再加上虚树的建树、重构复杂度较为优秀，所以经常与时间分块这种技巧相结合。$AKB132$, '数据结构', array['时间分块', '操作分块', '分块'], 'col-hub-ds-block', null, 'knowledge'),
('Fohen', 'col-ds-block-tree--fenfeng', '树分块 · Fohen', $AKB133$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

### 例题 $13$：[P5443 [APIO2019] 桥梁](https://www.luogu.com.cn/problem/P5443)

>给你一张 $n$ 个点 $m$ 条边的图，每条边有一个权值 $d_i$，$q$ 次操作，两种类型：改变一条边的权值；询问从 $s_j$ 出发只经过权值大于等于 $w_j$ 的边能到达多少个点。

（数据保证 $n \le 5 \times 10^4$，$m,q \le 10^5$）

这题实际上和例题 $11$ 非常像。

发现如果不带修的话，可以考虑通过维护连通块记录哪些点能相互到达，具体实现可以用并查集。我们对询问按照 $w$ 排序，按照排完序后的顺序，每次把小于等于当前询问的 $w$ 的边的两个端点合并成一个连通块，询问时直接回答 $s_j$ 的连通块内有多少个点，这些都能通过并查集维护。

发现这个修改本身并不难，于是可以对时间分块，并提前将一个时间块内的询问按照 $w$ 排序。处理每一个时间块内的修改和查询前，我们先对前面所有块里的修改进行处理。这样，每次处理询问时，除了加上那些不被修改的边的影响，只需暴力地处理时间块内在这次询问前的所有修改，如果一条边的权值修改后大于等于了 $w_j$，那么就将这条边连着的两个点的连通块合并，当然，需要用可撤销并查集，在回答完询问后再将并查集返回到不进行这些块内修改时的状态。

于是这题就做完了，分析下复杂度。首先要把边按照权值排序（方便后边双指针动态加边）是 $\operatorname{O}(m \log m)$ 的时间复杂度，然后考虑时间分块后每一块的复杂度，设块长为 $B$，一个块内的重构是 $\operatorname{O}(q)$ 的，块内询问的时间复杂度总和为 $\operatorname{O}(B^2 \log n+m)$。总复杂度为 $\operatorname{O}(qB \log n + mlogm + \lceil \frac{q}{B} \rceil(q+m))$，理论上 $B$ 取 $\operatorname{O}(\sqrt{\frac{q}{\log n}})$ 时最优，此时总时间复杂度为 $\operatorname{O}(m\log m + q^{\frac{3}{2}}\sqrt{\log n})$，可以通过。

## 把分块放到树上——树分块

前面说了很多分块的类型，但无论是序列分块、值域分块或是时间分块，本质上都是在对一个一维的序列进行分块。但对于一类较为复杂的树上问题，我们必须使用一些很暴力的方法进行维护和处理，这时就容易想到把分块的过程放到树上，于是树分块出现了。

### 例题 $14$：[P6177 Count on a tree II/【模板】树分块](https://www.luogu.com.cn/problem/P6177)

> 给你一棵 $n$ 个节点的树，每个点上有一个整数 $val_i$，$m$ 次询问一条路径上有多少种不同的 $val$，强制在线。

（数据保证 $n \le 4 \times 10^4$，$m \le 10^5$）

首先可以对 $val$ 离散化。离散化后，值域就变为了 $\operatorname{O}(n)$ 的，我们可以用一个 $bitset$ 维护值的出现情况，复杂度是正确的。

我们现在需要一种数据结构，可以在线，支持快速地把一条路径上的 $bitset$ 合并起来。我们考虑把树像分块一样分成若干条链，每条链都提前维护好 $bitset$，对于询问就拆成一些链和单点，然后暴力合并就好了。现在的问题在于如何把一棵树分成若干块，使得每一块都是一条链且这些块之间尽量 “均衡”。

我们希望在这棵树上选出若干个关键点，使得一个关键点与其他关键点之间的最短距离不会高于某个值，同时关键点的数量不会太多，这样，我们就能以正确的复杂度维护出这些关键点两两之间组成的链的答案。

考虑如下算法：每次找到当前深度最深的非关键点，设我们希望一个关键点与其他关键的最近距离 $\le B$（类似于序列分块时的块长），那么如果这个点的父亲、$2$ 级祖先、$3$ 级祖先、$······$、 $B-1$ 级祖先、$B$ 级祖先均为非关键点，就将这个点的 $B$ 级祖先设为关键点。容易发现，这样做完后，一个点的前 $B$ 级祖先中一定有一个关键点，所以关键点之间的距离并不会太长，而且，对于从一个点出发向根的方向走的长度为 $B$ 的链中，最多只会选出一个点，这就保证了最终的关键点的个数一定不会超过 $\lfloor \frac{n}{B} \rfloor$。于是，按照这个流程选出的关键点是满足我们的需求的，然后把这些关键点之间组成的段的答案预处理出来，并用 $bitset$ 提前记录好，对于一次询问路径 $u \rightarrow v$ 上的答案，我们把路径拆成五段，分别是 $u \rightarrow u',u' \rightarrow x,x \rightarrow \operatorname{lca}(u,v),\operatorname{lca}(u,v) \rightarrow y,y \rightarrow v',v' \rightarrow v$，使得 $u' \rightarrow x$ 和 $y \rightarrow v'$ 两段是由整块组成的，可以快速查询，而其余三段都是由散点组成，直接暴力合并，复杂度是对的。上述的算法流程其实就是树分块一般的流程，容易发现，我们把 $B$ 设为 $\operatorname{O}(\sqrt{n})$ 时可以较大地平衡块数和块长，不过具体的题中因为散点和整块处理的复杂度不同，如何取出更优的 $B$ 都是不一样的。

最后分析复杂度，因为我们要处理出每对关键点之间的值的 $bitset$，复杂度是 $\operatorname{O}( \frac{n^2}{B} + \frac{n^3}{B^2w})$ 的（先求出每一段的 $bitset$，再两两合并起来），对于一次查询，我们只需 $\operatorname{O}(B + \frac{n}{w})$。总复杂度为 $\operatorname{O}(\frac{n^2}{B} + \frac{n^3}{B^2w}+mB+\frac{nm}{w})$，在 $B$ 取 $\operatorname{O}(\sqrt{n})$ 时最优，此时时间复杂度为 $\operatorname{O}((n+m)\sqrt{n}+\frac{n^2+nm}{w})$，卡卡常可以通过。

接下来分享另一种解法，以及另一种常用的树分块方式——$Top \ Cluster$。

我们定义一个**树簇**为树上的一个连通点集，且至多有两个点与树簇外的点相连，我们称这些点为**界点**，一个树簇内的两个界点之间的路径称为**簇路径**。我们将一个树簇内深度较小的界点称为**上界点**，深度较大的界点称为**下界点**。定义**收缩树**为将原树划分为若干树簇，使得原树上的每条边都属于其中一个树簇、每个点至少属于一个树簇，将每个树簇看成一个点形成的树。

我们希望划分出树簇，使得每一个树簇的大小都小于等于某个值 $B$，可以理解为分块的块长。我们从根开始对原树进行 $dfs$，对上下界点进行标记。$dfs$ 到一个点时，设这个点为 $x$，把 $x$ 标记为一个上界点，当且仅当：

- $x$ 为根
- $x$ 的子树中未分到树簇中的点的数量 $\ge B$
- $x$ 至少有两个子树内存在界点。

我们定出所有的上界点后，再考虑如何把一个上界点 $x$ 子树内的点划分进不同的树簇中。我们可以把 $x$ 的儿子的子树划分的一个树簇里去，所以只需判断 $x$ 的一个子树 $y$ 是否需要分到一个新的树簇中去，当且仅当：

- $y$ 为 $x$ 的最后一个儿子
- $x$ 此前未被分进树簇的儿子的子树大小之和 $\ge B$
- $x$ 此前未划分进树簇的儿子子树中存在界点

我们现在会对一棵树划分出树簇了，接下来看这道题。很明显，我们可以用一种类似于刚刚那个思路的处理方式。我们用 $bitset$ 记录一个 $0/1$ 序列，表示一个值是否出现过，先提前预处理每一个树簇内簇路径上的 $bitset$，再对于每一对树簇求出从其中一个树簇到另一个树簇的路径上的所有树簇的簇路径上的 $bitset$。

询问时，我们对于一次询问，依旧可以分解成三段散块和两段整块，不同的是，我们处理整块时相当于求两个树簇之间簇路径上的值对应的 $bitset$，而这个我们已经预处理出来了，可以 $\operatorname{O}(1)$ 查询（当然，不包含合并和统计）。对于散块，还是直接暴力遍历并合并就好了。

分析下复杂度，和上种思路相似，在块长为 $\operatorname{O}(\sqrt{n})$ 时最优，时间复杂度为 $\operatorname{O}((n+m)\sqrt{n}+\frac{n^2+nm}{w})$。

### 例题 $15$：[P8204 [Ynoi2005] tdnmo](https://www.luogu.com.cn/problem/P8204)

>给你一棵 $n$ 个点的有根树，定义一个邻域 $N(x,y)$ 表示 $x$ 子树中，与 $x$ 距离 $<y$ 的点构成的点集。初始你有一个邻域 $N(1,0)$，每次共有三种操作：将当前邻域替换为另一个邻域，使得当前邻域是换成的邻域的子集；撤回当前最后一次执行的第一种操作；回答当前的邻域等于给出的 $m$ 个邻域的其中一个。给你这 $m$ 个无序的邻域，要求构造操作序列，在 $5m$ 次操作内分别得到这 $m$ 个邻域，且第一种操作后相比原来加上的点数之和 $\le 2.5 \times 10^9$。

（数据保证 $n,m \le 10^6$）

这道题运用了 $Top \ Cluster$ 精巧地平衡了复杂度，具体思路与回滚莫队、时间分块都有相似之处。

先分析下题面，第三种操作就是回答当前邻域与哪个给出的邻域相同，这是要达到的目的，所以先不考虑；第一种操作就是扩大当前邻域，第二种操作可以看作第一种操作的“回溯”。这题最难处理的地方在于要满足的两个条件——操作次数 $\le 5m$，第一次操作后增加的点数和 $\le 2.5 \times 10^9$。也就是说，我们想安排得到这 $m$ 个邻域的顺序，并设计一种算法，使得每次都能通过上一个邻域在较少次操作中得到新的邻域，且添加的点不能太多。

发现一个邻域实际的点数有大有小，位置也不同，如果随便安排，添加的点数肯定是错的，于是考虑用分块平衡复杂度（这题的数据范围——$10^6$ 次操作以及最多添加 $2.5 \times 10^9$ 个点也是很明显的根号复杂度），具体来说，因为问题在树上，所以使用树分块，尝试用 $Top \ Cluster$ 做。

我们把原树划分为若干树簇（下面称为 “块”），每一块的大小不超过 $B$，对于每一块，预处理出这一块的簇路径。我们可以对代表邻域的二元组的第一个数是否在簇路径上分类讨论：

- 如果这个邻域二元组的第一个数不在一条簇路径上，那么就代表着这个点的子树内不存在界点，也就是说这个点的子树内不存在其他的块，根据一个块内最多有 $B$ 个点，可以得到可能在这个邻域内的点最多只有 $\operatorname{O}(B)$ 级别。经验告诉我们，这个 $B$ 不会太大，一般就是 $\operatorname{O}(\sqrt{n})$ 级别的，于是这种情况我们可以统一处理，每次都直接使用第一种操作把当前的邻域从 $N(1,0)$ 改成当前需要的邻域，再回溯到 $N(1,0)$ 就行了（$N(1,0)$ 等同于空集）。
  
- 如果这个邻域二元组的第一个数在一条簇路径上，那么我们可以把二元组的第一个数所属块相同的邻域放到一起处理，并按照这个邻域能覆盖到的最深深度升序排序。注意到，这和莫队非常像，同时这道题的一操作只能添加和撤销，于是可以借鉴回滚莫队的思想。具体来说，我们对于这些二元组第一个数属于同一个块的邻域统一处理，称这些邻域为 “一组”。设这个块的下界点为 $low$，则我们先把这个块处理之前的所有第一种操作撤回，这时再把当前邻域从 $N(1,0)$ 改到 $N(low, 0)$，接下来，按照最深能影响到的深度从小到大处理这一组的邻域，一个邻域可以拆成两部分——比 $low$ 还要深的部分，设这个邻域能影响到的最深深度比 $low$ 深 $d$；在块内的部分。第一部分的 $d$ 一定是单调不减的，于是我们每次可以从 $N(low,d')$ 直接修改到当前的 $N(low,d)$，接下来就能直接修改到目标邻域了，因为目标邻域比 $N(low,d)$ 多出的部分是不超过 $\operatorname{O}(B)$ 的，然后就能用第三种操作进行回答了，注意回答完后要撤销回 $N(low,d)$。如果把树上分的块看成序列上的分块，把 $low$ 看成当前块右端点，而一个邻域相当于一个区间 $(dis_x,dis_x+y)$，我们把右端点逐渐向右延伸，左端点每次暴力向左延伸就好了，这就是回滚莫队。

考虑一下正确性，分别看上面提到的两种情况。第一种情况，每次添加的点数是 $\operatorname{O}(B)$ 的，进行的操作数是 $2$。第二种情况，每一个块刚开始的时候都要撤销回最开始的 $N(1,0)$，这部分的总和是 $\operatorname{O}(m)$ 次操作，再考虑达到每个邻域分别需要的次数，这里共有四步（这里把树上的四次操作映射到序列上，方便理解）：延伸右端点——延伸左端点——回答——把左端点撤销回当前块的右端点，共有 $\operatorname{O}(5m)$ 次操作，是正确的。每次添加的点也好算，共有 $\operatorname{O}(\frac{n^2}{B}+mB)$。最后让 $B$ 取 $\operatorname{O}(\sqrt{n})$，操作数和添加点数都符合限制。

分析复杂度。唯一的瓶颈在于把每个块内的邻域按照最深深度排序，最多也只有 $\operatorname{O}(m \log m)$，肯定是能过的。

至于例题 $14$ 中所提到的另一种对树进行分块的算法，理论上也是能解决这道题的，但是复杂度是不对的，因为树簇拥有 “最多只有两个界点与外界连接” 的性质，这使得一个邻域 $N(x,y)$ 只能通过下界点走出这个簇，这保证了每次单独添加并撤销的点数是 $\operatorname{O}(B)$ 的，而直接选关键点是无法保证的（应该也有一些方法能够优化到正确的范围？）。$AKB133$, '数据结构', array['树分块', '分块', '树上查询'], 'col-hub-ds-block', null, 'knowledge'),
('Fohen', 'col-ds-block-value-domain--fenfeng', '值域分块 · Fohen', $AKB134$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

## 在值域上分块——值域分块

前面讲到了对序列进行分块的方法和技巧，有时一些问题需要对值域进行维护但值域较大，或者直接暴力的复杂度不对，这时就需要分块来优化复杂度。那为什么不用线段树呢？一是因为分块的思想相对于线段树来说更直接，能干的事情相对更多，二是因为分块对空间的开销比线段树小。

### 一个基本的问题

值域分块有一种较为常用的用途，就是快速查询序列中满足某个条件的第 $k$ 大/小的值，做法就是建立一个值域序列 $w$，对所有满足条件的元素 $x$，让 $w_x$ 这个位置 $+1$，然后对 $w$ 分块，查询时（以求 $k$ 大值为例）就从最后一个块开始从后向前枚举每个块，找到一个在值域上最靠后的块 $y$ 使得从 $y$ 这个块到最后一个块满足条件的数 $\ge k$，找到这样一个块后再遍历这个块对应的值域上的区间，最终找到答案。这样做因为先枚举了大块再在一个块中枚举，所以在块长为根号的时候复杂度是 $\operatorname{O}(\sqrt{W})$，其中 $W$ 代表值域。注意，这种做法修改时的复杂度是 $\operatorname{O}(1)$ 的，即便查询比其他一些数据结构慢，但修改的复杂度是很优的。

没找到能直接这么做的题，但这种维护信息的方式经常会用到莫队中，用来维护当前区间的信息且能快速修改（因为莫队插入/删除一个位置的次数较多，相比线段树，能 $\operatorname{O}(1)$ 修改的值域分块更优）。

### 例题 $8$：[P3834 【模板】可持久化线段树 2](https://www.luogu.com.cn/problem/P3834)

> 给你一个序列，询问区间第 $k$ 小，**可以离线**。

（数据保证序列长度、询问次数 $\le 2 \times 10^5$，值域 $\le 10^9$）

首先，这是主席树模板题，主席树肯定是可以做的。但我们发现这道题可以离线，于是也来考虑下莫队如何解决这道题。

我们发现，这题和例题 $5$，$6$，$7$ 不太一样。区别在于：这题每次询问都与一个给出的常数 $k$ 有关，而前几道莫队的例题都是对于同一个序列上的同一个区间来说，答案是唯一的，于是我们可以在区间左右两端位置的插入/删除中直接维护出答案，但这题显然是不行的。例题 $6$ 告诉我们这种情况下可以尝试添加第三维，不过并不行，因为对于一个三元组 $(l,r,k)$，我们似乎无法用较小的复杂度推到 $(l,r,k+1)$ 或 $(l,r,k-1)$。

于是我们尝试改变每个当前区间所维护的信息。我们可以只维护一个桶（以值域为下标，值域事先离散化），桶每个位置 $x$ 的值代表着当前区间内有多少个值为 $x$ 的数。这样的话，对于修改肯定是能 $\operatorname{O}(1)$ 解决的，但查询时需要遍历这个桶，也就是说时间复杂度是值域。这个复杂度肯定是过不了的，所以思考如何优化。

这时就会用到刚刚讲过的那个 “快速查询第 $k$ 大/小” 的做法了。我们对于记录每个值出现次数的桶分块，并维护每个块内所有值的出现次数之和。这样修改仍然是 $\operatorname{O}(1)$ 的（只需修改这个值在桶中对应的位置的值以及这个值分块后所属的块的信息），但单次查询的复杂度因为有了整块，可以分摊成 $\operatorname{O}(\sqrt{W})$（$W$ 代表值域）。

分析一下最终的复杂度：设共有 $q$ 次询问，我们知道对于 $n$ 与 $q$ 接近的时候，令块长为 $\operatorname{O}(\sqrt{n})$ 是较为优的。这时莫队共会有 $\operatorname{O}((n+q)\sqrt{n})$ 次操作，这道题中每次操作都是 $\operatorname{O}(1)$ 的，所以总复杂也为 $\operatorname{O}((n+q)\sqrt{n})$。额外的，对于这 $q$ 次查询，我们会用单独的时间复杂度去回答，根据上面的分析，最低能分摊到根号，总复杂度便为 $\operatorname{O}(q\sqrt{W})$，不过 $W$ 是离散化后的值域，也可以看成 $n$ 的级别。这样总复杂度便为 $\operatorname{O}((n+q)\sqrt{n})$，虽然没有主席树快，但也可以轻松跑过去。

思考一件事：为什么对于记录莫队过程中某个区间的信息，我们会优先考虑值域分块，而不是值域线段树等 $\log$ 数据结构？其实是因为分块的特性使得它虽然是 “根号数据结构”，但时间复杂度是极其不均的。比如在值域分块中插入一个值，只需要修改那个值对应的位置以及其所属块的信息，也就是 $\operatorname{O}(1)$ 的，刚好适配莫队这种偏暴力的、修改次数极多的算法，相反，如果使用线段树等 $log$ 数据结构，将会使复杂度变为恐怖的 $\operatorname{O}(n\sqrt{n}\log n)$，大概率是会被卡的。而且值域分块不比线段树好写吗？

### 例题 $9$：[P4137 Rmq Problem / mex](https://www.luogu.com.cn/problem/P4137)

> 给你一个序列，每次询问一个区间内最小的没有出现过的自然数。

（数据保证序列长度、询问次数、值域 $\le 2 \times 10^5$）

这题不强制在线，考虑离线下来用莫队解决。

发现求最小的未出现过的自然数可以归纳为 “满足某种条件的第 $k$ 大/小的值”，于是可以值域分块维护区间的信息——我们用一个以值域为下标的桶维护每个值是否出现过，出现过就为 $1$，否则为 $0$，再对这个桶进行分块，每个块上维护这个块内有多少个不同的值在区间内出现过。

现在的问题在于如何在莫队加上/删除一个位置时快速判断是否有一个值的存在性（是否在区间中存在）发生了改变。这个问题让我们想到了例题 $6$ 中维护一个值是否出现过的方法。事实上，我们确实可以再开一个桶，记录每个值的出现次数，如果操作前后一个值的出现次数分别为 $1$ 和 $0$ 或 $0$ 和 $1$，则证明这个值的存在性发生了变化，这时我们可以 $\operatorname{O}(1)$ 地在值域分块上修改，那么一整次修改的复杂度也为 $\operatorname{O}(1)$。

对于询问，可以按照对应的值域从小到大遍历每个值域上的块，如果一个值域块内在询问区间内出现的不同的值的个数小于这个块的长度，就能证明答案值属于这个块内，再在这个块内从小到大遍历即可，块长为 $\operatorname{O}(\sqrt{n})$ 级别的情况下可以达到 $\operatorname{O}(n\sqrt{n})$ 级别的复杂度。

总复杂度的分析就不说了，和例题 $8$ 各部分的复杂度都是一样的。

这道题告诉我们某些时候值域分块是能通过根号级别的复杂度解决一些较为复杂、有时只能用枚举解决的问题，因为值域分块在这两道题里的运用就是优化枚举、分摊枚举的复杂度，本质上就是把对整个值域的枚举优化成了两次枚举量较小的枚举。

### 例题 $10$：[P11831 [省选联考 2025] 追忆](https://www.luogu.com.cn/problem/P11831)

>给你一张有 $n$ 个点的 $DAG$。每个点上有两个值 $A$，$B$，有 $q$ 次操作，分为三种：交换两个点的 $A$；交换两个点的 $B$；询问从一个点出发能到达的 $A$ 属于某个区间内的点的 $B$ 的最大值。

（数据保证 $n \le 10^5$，$q \le 2 \times 10^5$，$A,B$ 均为 $1 \sim n$ 排列，时间限制 $9s$，空间限制 $2GB$）

先考虑如何处理询问。这道题的询问较为复杂，一个点想成为答案，有三个条件：能从给出的点到达到达这个点；这个点上的 $A$ 必须处于某个区间内；这个点上的 $B$ 是满足上述条件的点中最大的。

很明显，后两个限制是 “较好处理” 的，于是我们先想办法解决第一个限制。如果这是棵树的话，我们可以用 $dfs$ 序等方法将一个点能到达的点具化成某一个维度的区间，从而进行多维数点。可这道题是个 $DAG$，好像没有什么方法能把 $DAG$ 上的可达性转化为好处理的方式，于是选择使用 $bitset$ 暴力维护可达性，因为 $bitset$ 自带 $\frac{1}{64}$ 的常数，再加上这题空间范围大，所以是空间是能跑过去的。具体来说，我们对于每一个点维护一个 $bitset$，然后对原图的反图跑拓扑排序，每次对于一条反图上的边 $(u, v)$，我们让 $v$ 结点上的 $bitset$ 并上 $u$ 结点上的 $bitset$，这样就可以求出在原图上每个点能到达的所有点。

这样，最复杂的第一个限制就处理好了，接下来思考后两个限制。首先是 $A$ 处于某个区间内，这个简单，我们可以对 $A$ 的值域进行分块，假设有一个点 $x$，它的 $A$ 为 $y$，我们就让 $y$ 这个位置以及这个位置所属的块记录上 $x$，查询时就可以把区间拆成整块和散块，因为我们对于单个位置和每个整块都记录了答案，所以暴力统计就好了。如何记录答案呢？因为是个排列，每个值只会出现一次，对于单个位置用数组维护这个值在原序列中出现的位置就行了，对于每个块我们把这个块内所有值在原序列中出现的位置并起来，变为一个集合，存到 $bitset$ 中。对于查询，我们再把区间内的所有整块的信息合并起来就好了。

在思考如何解决第三个限制之前，先考虑如何合并前两个限制，使得能够正确地求出同时满足前两个限制的点。同时满足前两个限制就相当于：能从一个给定点到达**且** $A$ 的值在一个区间内，可以先用上一段讲到的方式把一个值域区间内每个值对应的原序列的位置集合合并出来，同样用 $bitset$ 存储，再用这个 $bitset$ 和记录能被给定点到达的所有点的 $bitset$ 取且运算（注意前面所说的 “合并” 都是指的或运算），就得到了同时满足前两个限制的点的集合。

最后是第三个限制，其实就是在说同时满足前两个限制的条件下最大的 $B$ 值。这个描述又让我们想到了前面所说的 “基本问题”，于是也可以尝试值域分块。但如何把满足条件的位置快速插到值域上呢？我们思考那个 “基本问题” 的本质——为了保证复杂度，我们要能快速知道一个值域区间内满足的条件的值的个数，且对于每个单独的值我们能知道它是否满足条件。所以其实不用提前把一个值是否合法建成值域数组再分块，我们只需要维护一个 $B$ 值对应的原序列点的编号、以及一个值域区间对应的点的集合就好了。这样在查询时，我们直接对值域分成的块按值的大小从大到小枚举，我们用这个块所对应的原序列的位置的集合与满足前两个条件的点构成的 $bitset$ 取且，如果不为 $0$ 则证明这个块内有至少一个 $B$ 值满足条件，再进到块内枚举就行了；因为是从大到小枚举的，所以这个枚举出的值一定是满足条件中的最大的。三个限制处理完了，最后结合到一起就可以过了。

分析一下复杂度，注意因为 $A$ 和 $B$ 都是排列，所以两个值域分块的值域都是 $\operatorname{O}(n)$ 的。预处理因为有了 $bitset$，所以时间空间都是正确的（也是因为这题限制宽），两个值域分块的建立也是 $\operatorname{O}(n)$ 的，容易发现，把两个分块的块长都设成 $\operatorname{O}(\sqrt{n})$ 是最优的，这样对于一次询问，处理后两种询问分别只需要 $\operatorname{O}(\sqrt{n})$，但因为可以分别处理，所以一次询问的总复杂度也是 $\operatorname{O}(\sqrt{n})$ 的，可以通过。

值域分块相比于序列分块，更多的时候会与其他算法结合，用来快速查询某个满足条件的值，用处还是很广的。$AKB134$, '数据结构', array['值域分块', '分块', 'mex', '第 k 小'], 'col-hub-ds-block', null, 'knowledge'),
('Xesir', 'col-ds-bst--xesir', '二叉搜索树（BST） · Xesir', $AKB135$## 算法原理

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
- 数据有序时树会退化成链，递归深度可能达到 $n$，注意栈溢出风险。$AKB135$, '数据结构', array['数据结构', '二叉搜索树', 'BST', '插入删除', '排名', '前驱后继'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-cartesian-tree', '笛卡尔树（O(n) 单调栈构建与 RMQ 转 LCA）', $AKB136$## 算法原理

解决的问题：给定序列 $a_1,\dots,a_n$，构造一棵二叉树，使得

1. **中序遍历 = 原序列**（中序约束）；
2. **堆性质**成立（最小笛卡尔树要求父节点值 $\le$ 子节点值；最大笛卡尔树反过来）；

并把「静态区间最值查询（RMQ）」这类问题转成树上的 LCA 问题：**区间 $[l,r]$ 的最值所在位置，等于位置 $l$、$r$ 两个节点的最近公共祖先**。

核心思想：构造时**从左到右逐个插入元素**，新节点在中序里必须排在最后，因此它只能落在「最右路径」附近。当前最右路径的值是单调的（沿着父子链一路不降/不增），于是插入 $x$ 时只需沿最右路径往上找：把**所有比 $x$ 大（建最小树）的节点弹出**，最后弹出的那一段挂成 $x$ 的左子树，$x$ 接到剩余栈顶的右边。整个过程只改最右路径附近几条指针，每个节点入栈、出栈各一次，总时间 $O(n)$。

唯一性：序列元素**两两不同**时树唯一；有重复值时（右路径 $1\to2\to3\to5$ 再插一个 $3$）「严格大于才弹」与「大于等于就弹」会得到两棵都合法的树，此时需额外约定等值规则（如固定保留旧节点为父，或用键 $(a_i,i)$ 打破平局）。

与 AVL/红黑树的旋转形似而神不同：旋转是为了**控制高度**，笛卡尔树的改接是为了**恢复堆性质**，且只沿最右路径比较值，不看平衡因子。

## 核心公式 / 状态定义与转移方程

**递归定义**（以最小笛卡尔树为例）：对区间 $[l,r]$ 取最小值位置 $m$ 作根，左子树为 $[l,m-1]$，右子树为 $[m+1,r]$——根是区间最小值，满足堆性质；左右子序列分居两侧，满足中序性质。

**单调栈构造（O(n)）**，最小树用 `>` 弹出、最大树用 `<` 弹出：

```text
for x = 1..n:
    last = 0
    while top > 0 and p[x] < p[sk[top]]:   # 最小树；最大树用 >
        last = sk[--top]
    if top > 0: r[sk[top-1]] = x           # 剩余栈顶做父节点
    else:       root = x
    l[x] = last                            # 弹出的那一段挂到左边
    sk[top++] = x
```

栈底到栈顶 = 根到最右叶子，值单调；每个节点最多进出栈一次。

**RMQ → LCA**：建最大笛卡尔树后，区间最大值位置 = LCA$(pos_l, pos_r)$，

$$
\max_{i\in[l,r]} a_i = a_{\mathrm{LCA}(l,\,r)}
$$

最小树对应区间最小值。查询可用倍增（$O(\log n)$）或离线 Tarjan（近似 $O(1)$ 每次）。

## 数据结构图示

序列 $a=[5,3,4,1,2]$ 的最大笛卡尔树（节点标注「值(下标)」）：

```
            5(1)
              \
               \
              4(3)
             /    \
          3(2)    2(5)
                 /
               1(4)
```

中序遍历：$5,3,4,1,2$，与原序列一致 ✓；每条父子链父值 $\ge$ 子值 ✓（最大堆）。

插入过程中的最右路径变化（栈内容）：

```
插 5:  栈 [5]         最右路径 5
插 3:  栈 [5,3]       最右路径 5→3
插 4:  弹 3(挂到 4 左)，栈 [5,4]        最右路径 5→4
插 1:  栈 [5,4,1]     最右路径 5→4→1
插 2:  弹 1(挂到 2 左)，栈 [5,4,2]      最右路径 5→4→2
```

LCA 验证：`LCA(位置2, 位置5)` 是节点 4(3)，而 $\max(a_2,\dots,a_5)=\max(3,4,1,2)=4$ ✓。

## 核心操作详解

**操作 1：构建（单调栈）**

- 维护栈存当前最右路径（根→最右叶子），值单调不降（最大树）或不增（最小树）。
- 插入 $x$：弹出所有比 $x$ 小（最大树）的元素，记最后弹出者为 `last`；栈顶(若在)的右孩子置为 $x$，否则 $x$ 成为新根；`last` 挂成 $x$ 的左孩子；$x$ 入栈。
- 正确性两半：**中序**——新节点只能落在最右路径（进左子树就会出现在某祖先之前）；**堆**——被弹节点都小于 $x$（最大树），挂在 $x$ 左子树下合法，且 $x$ 的父是第一个不小于 $x$ 的节点。
- 等值时 `>` 与 `>=` 产生不同树形；本项目代码（最大树）用 `>`，即「等值时保留旧节点为父」。

**操作 2：静态区间最值查询（RMQ 转 LCA）**

- 建好最大笛卡尔树后，区间 $[l,r]$ 的最大值位置是位置 $l$、$r$ 两节点在树上的 LCA。
- 在线做法：倍增求 LCA，预处理 $O(n\log n)$、单次查询 $O(\log n)$。
- 离线做法（本项目代码）：读入全部询问挂在两个端点上，用 **Tarjan 离线 LCA**（并查集 + DFS 回溯）一次遍历批量回答，总时间近似 $O(n+m)$。

## 逐行代码解析

### 模块一：全局数组与 `init`（含并查集初始化）

```cpp
#include<bits/stdc++.h>
using namespace std;
int top,root;
vector<bool> vis;
vector<long long> p;
vector<int> sk, l, r, fa, ans;
vector<vector<pair<int, int>>> qs;
void init(int n,int m)
{
	top = 0;
	p.assign(n + 1, 0);
	sk.assign(n + 1, 0);
	l.assign(n + 1, 0);
	r.assign(n + 1, 0);
	fa.assign(n + 1, 0);
	qs.assign(n + 1,vector<pair<int,int>>());
	ans.assign(m + 1, 0);
	vis.assign(n + 1, false);
	for (int i = 1; i <= n; i++) fa[i] = i;
	root = 0;
}
```

- `sk` 是单调栈；`l[i]`、`r[i]` 存树的左右孩子；`root` 记录树根。
- `fa` 被 Tarjan 当作**并查集**用（初始 $fa[i]=i$），与「笛卡尔树的父指针」无关——树的父子关系只由 `l/r` 表达。
- `qs[x]` 存「挂在节点 $x$ 上的询问」：每条区间询问 $(L,R)$ 同时挂到 $L$ 和 $R$ 上（除非 $L=R$），保证 Tarjan 遍历时一处已访问、一处待处理。
- `ans[m+1]` 按询问编号存答案位置，`p` 是原序列值（查询是输出值而非位置）。

### 模块二：`find` 并查集路径压缩

```cpp
int find(int idx)
{
	if (idx != fa[idx]) fa[idx] = find(fa[idx]);
	return fa[idx];
}
```

- 标准并查集 `find`：路径压缩。在 Tarjan LCA 中，`fa` 的合并顺序 DFS 回溯时进行，`find` 返回「该子树已并入的最近祖先」，即两个询问端点的 LCA 候选。
- 与笛卡尔树的构建完全无关，是离线查询部分的工具。

### 模块三：`init_tree` 单调栈建最大笛卡尔树

```cpp
//想降低耦合，就写：      树的储存对象 init_tree(int n,const vector<long long>& p),然后创建临时数组并输出
void init_tree(int n)
{
	for (int i = 1; i <= n; i++)
	{
		//记录最后一个被弹出的节点（在维持中序遍历不变情况下，第一个比i大的元素）找到最右链的插入位置
		int last = 0;

		//找到在维持中序遍历不变情况下，第一个比i大的元素(弹完后栈顶是 i 的父节点（向左第一个 ≥ p[i] 的元素）)
		while (top > 0 && p[i] > p[sk[top - 1]]) last = sk[--top];
		
		//栈非空时，栈顶节点的右儿子设为 i；否则 i 成为根。
		if (top > 0) r[sk[top - 1]] = i;
		else root = i;

		//将右链插入位置后边的放到现节点的左边
		l[i] = last;
		//将元素加入栈中
		sk[top++] = i;
	}
}
```

- `while (top > 0 && p[i] > p[sk[top-1]])`：弹出所有值**小于** $p[i]$ 的栈顶，`last` 记住最后一个被弹出的节点——这些节点都要变成 $i$ 的后代。这是**最大**笛卡尔树；换成 `<` 就是最小树。
- 弹空说明 $p[i]$ 比整条最右路径都大，$i$ 成为新根；否则接到剩余栈顶的右孩子上。
- `l[i] = last`：被弹段整体挂到 $i$ 的左子树（中序里它在 $i$ 之前，必须进左子树）；`last=0` 表示没有需要挂的段。
- 每个节点入栈一次出栈一次，总时间 $O(n)$。

### 模块四：`tarjan` 离线 LCA 批量回答询问

```cpp
void tarjan(int rt,int m)
{
	vis[rt] = true;
	if (l[rt] != 0)
	{
		tarjan(l[rt], m);
		fa[l[rt]] = rt;
	}
	if (r[rt] != 0)
	{
		tarjan(r[rt], m);
		fa[r[rt]] = rt;
	}
	for (pair<int, int>& i : qs[rt])
	{
		if (vis[i.first]) ans[i.second] = find(i.first);
	}
}
```

- DFS 后序遍历：先递归左、右子树，递归返回后把子节点并入当前节点（`fa[child]=rt`）。
- 处理挂在 `rt` 上的询问 $(u, id)$：若 $u$ 已访问过，`find(u)` 给出两者 LCA——因为 $u$ 所在子树已经并入其与 `rt` 的公共祖先，而 `rt` 一侧尚未回溯过 `rt` 本身。
- `vis` 防止同一询问被两个端点重复回答；`L!=R` 时询问挂了两次，第一次遇到「另一端已访问」才产生答案。

### 模块五：`main` 读入、建树、离线查询与输出

```cpp
int main()
{

	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	//反正就是笛卡尔树满足两个性质，一个是父节点大于子节点。另一个是中序遍历保持原序列的顺序。
	//因为中序遍历的话，那就是要插入新的节点，那肯a定是得插入在最右链上的。
	//那如果你创建个单调栈的话，会发现最右链正好是单调站中的元素

	//然后最基础的用法呢就是，两个节点最近公共祖先是整个区间的最大值。

	int n, m;
	cin >> n >> m;
	init(n, m);
	for (int i = 1; i <= n; i++) cin >> p[i];
	init_tree(n);
	for (int i = 1; i <= m; i++)
	{
		int L, R;
		cin >> L >> R;
		qs[L].emplace_back(R, i);
		if (L != R) qs[R].emplace_back(L, i);
	}
	tarjan(root, m);
	for (int i = 1; i <= m; i++) cout << p[ans[i]] << '\n';

	return 0;
}
```

- 读入后先 `init_tree(n)` 建最大笛卡尔树，再统一读入 $m$ 条区间询问，把 $(R,i)$ 挂到 $L$、$(L,i)$ 挂到 $R$。
- `tarjan(root, m)` 一次 DFS 回答全部询问：`ans[i]` 得到的是**最大值的下标**，最后输出 `p[ans[i]]` 换算成值。
- 这是一份「静态区间最大值」的离线模板：n、m 规模都在 $10^5$ 级时，总耗时近似 $O(n+m)$，且避开了 RMQ 预处理的大空间。

## 复杂度分析

- **时间复杂度**：`init_tree` 每个节点入栈出栈各一次，$O(n)$；`tarjan` 遍历整棵树 $O(n)$，每个询问在两端各处理常数次、`find` 近似 $O(1)$，总共 $O(n+m)$。
- **空间复杂度**：树的孩子数组、栈、并查集各 $O(n)$，询问挂载共 $O(m)$，总 $O(n+m)$。

## 适用场景

- **静态序列的区间最值查询**：建一次树，回答任意多个「区间最大/最小值位置」的询问（在线转倍增 LCA、离线转 Tarjan），是 RMQ → LCA 的标准转化。
- **每个元素作为最值的影响范围 / 贡献统计**：最大（小）笛卡尔树里，节点的子树对应「以它为最值的最长连续区间」，子树大小 = 影响范围宽度，常配合树形 DP 做贡献统计。
- **按区间最值分割的分治显式化**：递归定义本身就是「取区间最小/最大值切两半」，很多最小值分治题可以先建树再在树上 DP。
- 不适用：需要**动态修改**后查询最值的场景——笛卡尔树是静态结构，动态 RMQ 该换线段树/平衡树。

## 常见陷阱与注意事项

1. **大小堆方向写反**：最大树弹「比当前小的」（`p[i] > p[sk.top]`），最小树弹「比当前大的」（`p[i] < p[sk.top]`）。方向反了得到的是另一棵树，RMQ→LCA 时「最大值」会悄悄变成最小值。
2. **弹出后忘记挂接**：`last`（最后弹出的节点）必须挂成新节点的**左孩子**，否则被弹段悬空，中序被破坏；剩余栈顶的**右孩子**必须改成新节点，否则旧的右指针残留。
3. **等值规则要统一**：`>` 与 `>=` 会得到两棵不同的合法树；同一程序里两者混用会让树形不稳定。需要唯一解时约定「旧节点优先」或用键 $(a_i,i)$。
4. **直接挂最右节点的右孩子是错的**：如最右路径 $1\to5$ 插入 $3$，直接挂成 $5$ 的右孩子得到父子 $5\to3$，违反堆序；必须沿最右路径上顶。
5. **中间接接不会出三叉**：新节点 $x$ 接在 $p$ 的右孩子位置、$p$ 原右孩子 $q$ 整体变 $x$ 的左孩子——每个节点仍至多两个孩子，只是指针改接。
6. **Tarjan 的并查集与树的父指针是两套东西**：构建期 `l/r` 表达树结构；查询期的 `fa` 是并查集（初始 $fa[i]=i$，DFS 回溯时合并）。两者混用会让 find 结果全错。
7. **询问挂两次与自环**：$(L,R)$ 必须挂到两个端点才能保证第一次走过一端、第二次在另一端被回答；$L=R$ 只挂一次（另一端点相同），靠 `vis` 保证不被重复回答。
8. **单调序列不是退化**：序列单调时树就是一条链（树形本身如此），但单调栈仍每个节点只进出一次，时间依然是 $O(n)$，不要误以为退化到 $O(n^2)$。

## 对比与扩展

| 结构 | 中序约束 | 堆约束来源 | 典型用途 |
|---|---|---|---|
| 笛卡尔树 | = 原序列 | 序列值本身 | 静态 RMQ 转 LCA、最值贡献统计 |
| Treap | = 键序 | 随机优先级 | 动态平衡查找树 |
| 单调栈 | 无（线性结构） | 无 | 求左右第一个更大/更小 |

- **与 ST 表对比**：ST 表在线查询 $O(1)$，但预处理 $O(n\log n)$ 且不能给出「最值出现的位置树结构」；笛卡尔树把 RMQ 变成树上问题，可进一步接入各种树算法（DP、倍增、启发式合并）。
- **RMQ → LCA 的双向性**：不仅 RMQ 能转 LCA（建笛卡尔树），LCA 也能转 RMQ（欧拉序 ±1 RMQ）——两者可互化，是静态树上问题的经典桥梁。
- **前置/相关**：单调栈的进出栈套路见「单调栈（直方图最大矩形）」；Tarjan 离线 LCA 见「最近公共祖先 LCA（Tarjan 离线·并查集）」。
- **迁移信号**：看到「静态序列、区间最值位置、每个数作为最值的贡献、按最值分割的分治、直方图最大矩形、RMQ 转 LCA」中的任意组合，优先考虑笛卡尔树。$AKB136$, '数据结构', array['笛卡尔树', '单调栈', 'RMQ', 'Tarjan', 'LCA'], null, null, 'knowledge'),
('Xesir', 'col-ds-diff-1d--xesir', '一维差分 · Xesir', $AKB137$## 算法原理

> 给定一个序列 a，有 m 次操作，每次将 [l,r] 区间内的元素 +c，最后输出序列。

最简单的 $O(nm)$ 暴力做法是每次遍历 $[l,r]$ 并 `+c`，即模拟操作，显然也会爆。类似推导前缀和，我们也可以考虑如何将单次区间加优化为 $O(1)$。

差分，即前缀和的逆运算。定义数组 $s$ 为 $a$ 的差分数组，即 $a[i]=s[1]+s[2]+\dots+s[i]$，相当于 $a$ 是 $s$ 的前缀和数组。构造也不难：令 $s[i]=a[i]-a[i-1]$（$a[0]=0$），不难发现它满足差分关系。

由此关系可以看出，令 $s[i]+c$ 相当于令 $a[i..n]$ 全部 $+c$。所以实现 $[l,r]+c$ 只需要两处修改：

$$
s[l] \mathrel{+}= c, \qquad s[r+1] \mathrel{-}= c
$$

- 在 $l$ 处加 $c$：从位置 $l$ 开始，后续所有前缀和都增加 $c$。
- 在 $r+1$ 处减 $c$：从位置 $r+1$ 开始，增量被抵消。
- 最终效果：只有 $[l,r]$ 区间内的元素增加了 $c$。

## 核心公式 / 状态定义与转移方程

- **构造**：$s[i]=a[i]-a[i-1]$（$a[0]=0$）。
- **区间加 $[l,r]+c$**：$s[l]+=c$，$s[r+1]-=c$。
- **还原**：对 $s$ 求一次前缀和即得修改后的 $a$。

## 逐行代码解析

### 模块一：读入并求差分

```cpp
#include <bits/stdc++.h>
using namespace std;
int s[100010],h[100010];
int main()
{
    int n,m;
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        cin>>s[i];
        h[i]=s[i]-s[i-1];
    }
```

- `s` 存原数组，`h` 存差分数组，`h[i]=s[i]-s[i-1]`。
- 这里用了两个数组、没有原地覆盖，所以正序遍历也没问题（`s[i-1]` 仍是原值）。

### 模块二：区间加

```cpp
    while(m--){
        int l,r,x;
        cin>>l>>r>>x;
        h[l]+=x;
        h[r+1]-=x;
    }
```

- 区间 $[l,r]$ 加 $x$：`h[l]+=x`、`h[r+1]-=x`，单次 $O(1)$。
- `h` 数组开的是 `100010`，`r+1` 最多到 $n+1$，数据规模大时注意别越界。

### 模块三：前缀和还原并输出

```cpp
    for(int j=1;j<=n;j++){
        h[j]+=h[j-1];
        cout<<h[j]<<" ";
    }
     
    return 0;
}
```

- `h[j] += h[j-1]` 对差分数组求前缀和，还原出修改后的原值，顺便输出。

## 复杂度分析

- **构造差分**：$O(n)$。
- **单次区间加**：$O(1)$，$m$ 次操作 $O(m)$。
- **还原原数组**：$O(n)$。
- 总代价 $O(n+m)$；空间 $O(n)$（本代码开了两个数组）。

## 适用场景

- **多次区间修改 + 最后一次查询**：$m$ 次修改每次 $O(1)$ 打标记，最后 $O(n)$ 前缀和还原，是差分的标准用法。
- **区间加 + 单点查询**：同样 $O(1)$ 修改、$O(n)$ 还原。
- **不适用**：需要边修改边查询（在线）时，应改用树状数组或线段树（单次 $O(\log n)$）。

## 常见陷阱与注意事项

1. **数组大小要留够**：差分要访问 `r+1`，当 $r=n$ 时 `r+1=n+1`，数组需能容纳到 $n+1$。
2. **原地求差分必须倒序**：若在同一个数组上原地求差分，正序会让 `a[i-1]` 被提前改掉；倒序才能保证每一步的右操作数还是原值（本代码用两个数组，规避了这个问题）。
3. **差分是前缀和的逆操作**：记忆口诀「加左减右」——区间加 $c$，左端点 $+c$、右端点后一位 $-c$。
4. **只支持区间加，不直接支持区间查询**：查单点值要先做前缀和（$O(n)$）。
5. **数据类型**：多次区间加后数值可能很大，注意用 `long long`；本代码用的是 `int`，数据大时要改。
6. **未校验 $l\le r$**：代码默认输入合法，若越界访问 `h[r+1]` 会出错。

## 对比与扩展

- **差分 + 前缀和的组合**：多次区间加 → 用差分记录 → 最后前缀和还原 → 输出结果。
- **二维差分**：扩展到矩阵可对子矩阵做区间加，还原时先做行前缀和再做列前缀和（或反之）。
- **树上差分**：配合 LCA，对树上路径 $u\to v$ 上所有点加 $w$，最后 DFS 求子树和即为每个节点的最终值。$AKB137$, '数据结构', array['差分', '一维', '区间加', '前缀和逆运算', '数据结构'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-diff-1d', '一维差分（区间加·批量更新）', $AKB138$## 算法原理

一维差分（Difference Array）是前缀和的**逆操作**：给定原数组 $a$，构造差分数组 $d$，使得 $a$ 是 $d$ 的前缀和。差分数组的核心优势是：**区间 $[l, r]$ 同时加 $w$，只需修改差分数组的两个位置**，时间 $O(1)$。

### 核心公式

差分数组定义（$d$ 是 $a$ 的差分）：

$$d[i] = a[i] - a[i-1] \quad (d[1] = a[1])$$

换句话说，$a$ 是 $d$ 的前缀和：

$$a[i] = \sum_{k=1}^{i} d[k]$$

### 区间加操作

若将原数组 $[l, r]$ 区间内所有元素加 $w$，差分数组只需做两处修改：

$$d[l] \mathrel{+}= w, \qquad d[r+1] \mathrel{-}= w$$

**为什么只有两处变化？**
- 在 $l$ 处加 $w$：从位置 $l$ 开始，后续所有前缀和都增加 $w$。
- 在 $r+1$ 处减 $w$：从位置 $r+1$ 开始，前缀和的增量被抵消。
- 最终效果：只有 $[l, r]$ 区间内的元素增加了 $w$。

### 还原原数组

所有修改完成后，对差分数组做一次前缀和，即可得到修改后的原数组：

$$a[i] = \sum_{k=1}^{i} d[k]$$

## 数据结构图示

### 差分数组的构造

以数组 $a = [0, 3, 1, 4, 2, 5]$（下标从 1 开始，$a[0] = 0$ 为哨兵）为例，演示差分数组 $d$ 的构造：

```
原始数组 a:
  下标:   0    1    2    3    4    5
  值:     0    3    1    4    2    5

差分数组 d[i] = a[i] - a[i-1]:

d[1] = a[1] - a[0] = 3 - 0 = 3
d[2] = a[2] - a[1] = 1 - 3 = -2
d[3] = a[3] - a[2] = 4 - 1 = 3
d[4] = a[4] - a[3] = 2 - 4 = -2
d[5] = a[5] - a[4] = 5 - 2 = 3

最终差分数组 d:
  下标:   0    1    2    3    4    5    6
  值:     0    3   -2    3   -2    3    0

验证: 对 d 求前缀和即还原 a
  a[1] = d[1] = 3 ✓
  a[2] = d[1]+d[2] = 3+(-2) = 1 ✓
  a[3] = 3+(-2)+3 = 4 ✓
  a[4] = 3+(-2)+3+(-2) = 2 ✓
  a[5] = 3+(-2)+3+(-2)+3 = 5 ✓
```

差分和前缀和互为逆运算：差分"拆开"数组，前缀和"拼回"数组。

### 区间加操作示意

在 $a$ 的区间 $[2, 4]$ 上加 $w = 5$，即 $a[2], a[3], a[4]$ 都 +5：

```
操作前:
  a = [_, 3, 1, 4, 2, 5]
  d = [0, 3, -2, 3, -2, 3, 0]

操作: 区间 [2,4] + 5
  d[2] += 5    → d[2] = -2 + 5 = 3
  d[5] -= 5    → d[5] =  3 - 5 = -2

操作后的 d:
  d = [0, 3, 3, 3, -2, -2, 0]
          ↑            ↑
         +5           -5

对新的 d 求前缀和，还原 a':
  a'[1] = 3                          = 3  （不变）
  a'[2] = 3 + 3 = 6                  = 1+5 ✓
  a'[3] = 3 + 3 + 3 = 9              = 4+5 ✓
  a'[4] = 3 + 3 + 3 + (-2) = 7       = 2+5 ✓
  a'[5] = 3 + 3 + 3 + (-2) + (-2) = 5 = 5  （不变）
```

**为什么只改两个位置？**

```
位置:   1    2    3    4    5    6
d 变化: 0   +5    0    0   -5    0
        │    │    │    │    │    │
前缀和:  ↓    ↓    ↓    ↓    ↓
a'[1] =  3   (不变)
a'[2] =  3+3 = 6   ← 从这里开始 +5
a'[3] =  6+3 = 9   ← 继续 +5
a'[4] =  9+(-2) = 7 ← 继续 +5
a'[5] =  7+(-2) = 5 ← 到这里 +5 被抵消，恢复原值
        │              │
        └── +5 区间 ──┘
```

$d[l] + w$ 使从 $l$ 开始的所有前缀和都 $+w$，$d[r+1] - w$ 使从 $r+1$ 开始的前缀和抵消增量。两者配合，精确控制区间 $[l, r]$。

### 多次区间加叠加

如果有多个区间加操作，差分数组会叠加变化。例如再加一次 $[1, 3] + 2$：

```
第一次操作 [2,4]+5 后: d = [0, 3, 3, 3, -2, -2, 0]
第二次操作 [1,3]+2:
  d[1] += 2  → d[1] = 3+2 = 5
  d[4] -= 2  → d[4] = -2+(-2) = -4

最终 d = [0, 5, 3, 3, -4, -2, 0]

还原 a:
  a[1] = 5              = 3+2 ✓        （+2 生效）
  a[2] = 5+3 = 8        = 1+5+2 ✓      （+5 和 +2 都生效）
  a[3] = 5+3+3 = 11     = 4+5+2 ✓      （+5 和 +2 都生效）
  a[4] = 11+(-4) = 7    = 2+5 ✓        （+5 生效，+2 抵消）
  a[5] = 7+(-2) = 5     = 5 ✓          （都抵消，恢复）
```

差分数组天然支持多次区间操作的叠加，每次只需 $O(1)$，最后统一还原。

## 逐行代码解析

### 模块一：头文件与读入

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int N,T;
	cin >> N >> T;
	vector<long long> A(N + 2);          // 开 N+2 防止 r+1 越界
	for(int i = 1;i <= N;i++) cin >> A[i];
```

- `vector<long long> A(N + 2)`：开 $N+2$ 空间（下标 $0 \sim N+1$），因为 $r+1$ 最大为 $N+1$，需确保不越界。
- 用 `long long` 存储：多次区间加后数值可能很大，避免溢出。
- 下标从 $1$ 开始读入，$A[0]$ 与 $A[N+1]$ 保持默认值 $0$，充当差分计算的哨兵。
- `ios::sync_with_stdio(false)` 与 `cin.tie(nullptr)`：关闭同步、解绑输入流，加快大量读写。

### 模块二：原地求差分

```cpp
	for(int i = N;i >= 1;i--) A[i] = A[i] - A[i - 1];   // 原地求差分
```

- 在同一数组 $A$ 上原地构造差分数组：`A[i] = A[i] - A[i-1]`。
- **必须倒序遍历**：若正序遍历，`A[i-1]` 已经被改成差分值，再算 `A[i]` 就错了；倒序保证计算 `A[i]` 时 `A[i-1]` 仍是原值。

### 模块三：区间加操作

```cpp
	for(int i = 1;i <= T;i++)
	{
		int l,r;
		long long w;
		cin >> l >> r >> w;
		A[l] += w;                       // 区间左端点 +w
		A[r + 1] -= w;                    // 区间右端点后一位 -w
	}
```

- `A[l] += w; A[r + 1] -= w;`：区间 $[l, r]$ 加 $w$，单次 $O(1)$，$T$ 次操作总时间 $O(T)$。
- `r+1` 最大为 $N+1$，而数组开到 $N+2$，因此访问不会越界。

### 模块四：前缀和还原并输出

```cpp
	for(int i = 1;i <= N;i++)
	{
		A[i] += A[i - 1];                 // 前缀和还原原数组
		cout << A[i] << ' ';
	}
	return 0;
}
```

- `A[i] += A[i-1]`：对差分数组求前缀和，还原出修改后的原值，$O(n)$。
- 还原与输出在同一次循环内完成，累加后的 `A[i]` 即为最终答案，按空格分隔输出。

### 倒序求差分的原因

假设正序求差分：
- `A[1] = A[1] - A[0]`（正确，`A[0]` 还是 0）
- `A[2] = A[2] - A[1]`（错误！`A[1]` 已经被上一步改成了差分值，不再是原值）

倒序求差分：
- `A[N] = A[N] - A[N-1]`（正确，`A[N-1]` 仍是原值）
- `A[N-1] = A[N-1] - A[N-2]`（正确，`A[N-2]` 仍是原值）
- ...
- 每一步的右操作数都还没被修改，保证正确性。

## 复杂度分析

| 操作 | 时间 |
|---|---|
| 构造差分数组 | $O(n)$ |
| 单次区间加 $[l, r] + w$ | $O(1)$ |
| 还原原数组（求前缀和） | $O(n)$ |

差分把「$q$ 次区间修改 + 最后一次性查询」的总代价从朴素做法的 $O(nq)$ 降为 $O(n + q)$。

## 适用场景

- **多次区间修改 + 最后一次查询**：$q$ 次修改每次 $O(1)$ 打标记，最后 $O(n)$ 前缀和还原，是差分的标准用法
- **区间加 + 单点查询**：同样 $O(1)$ 修改、$O(n)$ 还原
- **不适用**：需要边修改边查询时，应改用树状数组或线段树（单次 $O(\log n)$）

## 常见陷阱与注意事项

1. **数组大小开 N+2**
   - 差分数组需要访问 `r+1`，当 $r = N$ 时 `r+1 = N+1`，数组需开到 $N+2$。
   - 若开到 $N+1$，最后一个区间修改会越界。

2. **倒序构造差分**
   - 原地构造差分数组必须倒序遍历，否则前面的差分值会覆盖原值，导致后续计算错误。
   - 若使用额外数组存差分（如 `d[]`），则正序倒序都可以：`d[i] = a[i] - a[i-1]`。

3. **差分是前缀和的逆操作**
   - 差分 → 前缀和 = 还原。前缀和 → 差分 = 还原。两者互为逆运算。
   - 记忆口诀："加左减右"（区间加 $w$，左端点 $+w$，右端点后 $-w$）。

4. **只支持区间加，不支持区间查询**
   - 差分擅长批量区间修改，但查询单点值需要先做前缀和（$O(n)$）。
   - 若需边修改边查询（在线），应使用树状数组或线段树。

5. **数据类型**
   - 与前缀和同理，多次区间加可能导致数值很大，使用 `long long` 防溢出。

6. **未校验 l ≤ r**
   - 代码默认输入合法（$1 \le l \le r \le N$），未校验 $l \le r$；若 $r = N+1$，`A[r+1]` 会访问 $A[N+2]$ 越界。
   - 建议按题意假设输入合法，或加 `if (l > r) continue;` 判断。

## 扩展应用

### 差分 + 前缀和的组合

差分与前缀和是一对互逆操作，常见组合使用方式：
- 多次区间加 → 用差分记录 → 最后前缀和还原 → 输出结果

### 二维差分

扩展到二维矩阵，可对子矩阵进行区间加操作。还原时需先做行前缀和再做列前缀和（或反之）。

### 树上差分

配合 LCA 使用，对树上路径 $u \to v$ 上所有节点加 $w$：

$$\text{diff}[u] \mathrel{+}= w, \quad \text{diff}[v] \mathrel{+}= w, \quad \text{diff}[\text{LCA}] \mathrel{-}= w, \quad \text{diff}[\text{fa(LCA)}] \mathrel{-}= w$$

最后 DFS 求子树和即为每个节点的最终值。$AKB138$, '数据结构', array['数据结构', '差分', '一维', '区间修改', '前缀和逆操作', '数学'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('stripe-python', 'col-ds-dsu-on-tree--stripe-python', 'dsu on tree · stripe-python', $AKB139$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 原理

dsu on tree 是一种人类智慧的做法，用来处理一类子树信息的问题。下面来个例题：

> 给你一棵大小为 $n$ 的树，每个节点有颜色 $c_u$。$q$ 次询问，每次询问以 $u$ 为根的子树中的颜色数。
>
> $n,q \le 10^5$。

首先和重链剖分一样，记 $sz_u$ 为子树大小，定义**重儿子**为 $sz_v$ 最大的节点，轻儿子为其他节点。

用一个全局数组记录答案状态。算法分三步进行：

1. 遍历所有轻儿子，**并清空它对全局答案的影响**。
2. 遍历重儿子，**并保留它的影响。**
3. 再次遍历轻儿子，将它的影响合并到全局答案中。

这是一个很暴力的想法。但是可以发现上述过程相当于启发式合并，所以复杂度是 $O(n \log n)$ 的。

## 实现

dsu on tree 的传统实现方法是两次 dfs：

```cpp
void dfs1(int u, int fa) {  // 第一遍 DFS：求重儿子
	sz[u] = 1;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs1(v, u), sz[u] += sz[v];
		if (sz[v] > sz[son[u]]) son[u] = v;
	}
}
void dfs2(int u, int fa, bool keep) {    // 第二遍 DFS：dsu on tree
	// keep 表示是否保留 u 的影响
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v != fa && v != son[u]) dfs2(v, u, false);  // 遍历轻儿子
	}
	if (son[u]) dfs2(son[u], u, true);  // 遍历重儿子
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa || v == son[u]) continue;
		// 加入 v 子树的影响
		// 常常要处理 dfs 序后将 v 子树中的节点全部遍历一次
	}
	// 计算 u 子树的答案
	if (!keep) {
		// 清空 u 的影响
		// 常常要处理 dfs 序后将子树中的节点全部删除一次
	}
}
```

有一种好写的方法是利用 set 实现，但复杂度会变成 $O(n \log^2 n)$：

```cpp
set<int> s[N];
void dfs(int u, int fa) {
	bool keep = true;  // 是否保留 u 子树的影响
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		dfs(v, u);
		if (s[u].size() < s[v].size()) swap(u, v);  // set 启发式合并
		// 将 v 的影响合并到 u 上并计算 keep
		for (int i : s[v]) s[u].emplace(i);
	}
	// 计算 u 子树的答案
	if (!keep) s[u].clear();  // 清空
}
```

练习：

- [CF600E Lomsat gelral](https://www.luogu.com.cn/problem/CF600E)
- [CF375D Tree and Queries](https://www.luogu.com.cn/problem/CF375D)
- [CF1709E XOR Tree](https://www.luogu.com.cn/problem/CF1709E)（set 式写法）
- [CF570D Tree Requests](https://www.luogu.com.cn/problem/CF570D)
- [CF246E Blood Cousins Return](https://www.luogu.com.cn/problem/CF246E)（set 式写法）
- [CF208E Blood Cousins](https://www.luogu.com.cn/problem/CF208E)
- [P4149 [IOI 2011] Race](https://www.luogu.com.cn/problem/P4149)
- [P4556 [Vani有约会] 雨天的尾巴](https://www.luogu.com.cn/problem/P4556)
- [P1600 [NOIP 2016 提高组] 天天爱跑步](https://www.luogu.com.cn/problem/P1600)（将路径分解为 $u \to \text{LCA}$ 和 $\text{LCA} \to v$ 两段，拆贡献转化为上题）

## 总结

感觉 dsu on tree 适用范围不太广。

dsu on tree 主要应用于离线、静态询问的树上问题。加入和清空贡献时往往和莫队题很像。对于颜色问题，dsu on tree、树上莫队、线段树合并都能解决，相比之下 dsu on tree 有更小的常数。并且 set 式写法非常好写，考场上敲不完线段树合并时属于救命选择。$AKB139$, '数据结构', array['dsu on tree', '树上启发式合并', '子树', 'DFS'], 'col-ds-other-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-dual-heap', '对顶堆（动态维护第 k 小）', $AKB140$## 算法原理

对顶堆是用两个堆（一个大根堆 $L$、一个小根堆 $R$）协作维护动态序列第 $k$ 小的数据结构。核心思想是：将所有元素按大小分成两半，较小的 $k$ 个放 $L$（大根堆），其余放 $R$（小根堆），则 $L$ 的堆顶就是第 $k$ 小元素。

### 核心不变量

1. $L$ 是大根堆，$R$ 是小根堆
2. $L$ 中的所有元素 $\le$ $R$ 中的所有元素
3. $|L| = k$（维护第 $k$ 小时，$L$ 恰好保存 $k$ 个元素）

只要这三个不变量成立，$L.\text{top}()$ 就是当前序列的第 $k$ 小元素。

### 为什么用两个堆

单个堆只能 $O(1)$ 取最大（或最小）值，但无法直接取第 $k$ 小。对顶堆用大根堆 $L$ 存较小的 $k$ 个元素（堆顶是这 $k$ 个中最大的，即第 $k$ 小），小根堆 $R$ 存其余元素（堆顶是其中最小的），两个堆顶"对顶"相邻，刚好把序列分成了"前 $k$ 小"和"其余"两段。

## 数据结构图示

### 整体结构

```
         L (大根堆)          R (小根堆)
         存较小的 k 个         存其余元素
         堆顶 = 第 k 小        堆顶 = 第 k+1 小

         ┌───────┐           ┌───────┐
         │  max  │ ← 堆顶    │  min  │ ← 堆顶
         │  ...  │           │  ...  │
         │  ...  │           │  ...  │
         └───────┘           └───────┘
          |L| = k             |R| = n - k

    ← 所有 L 中元素 ≤ 所有 R 中元素 →
```

### 插入操作示意

以序列 $[3, 1, 4, 2, 5]$，$k = 3$（维护第 $3$ 小）为例：

```
插入 3: L 为空，直接放入 L
  L: [3]          R: []
  L.top() = 3

插入 1: 1 ≤ L.top()=3，放入 L
  L: [3, 1]       R: []
  my_move(3): |L|=2 < 3，但 R 为空，无需调整
  L: [3, 1]       R: []

插入 4: 4 > L.top()=3，放入 R
  L: [3, 1]       R: [4]
  my_move(3): |L|=2 < 3，从 R 取堆顶移入 L
  L: [4, 3, 1]    R: []
  L.top() = 4

插入 2: 2 ≤ L.top()=4，放入 L
  L: [4, 3, 2, 1]  R: []
  my_move(3): |L|=4 > 3，从 L 取堆顶移入 R
  L: [3, 1, 2]    R: [4]
  L.top() = 3  ← 第 3 小 = 3 ✓

插入 5: 5 > L.top()=3，放入 R
  L: [3, 1, 2]    R: [4, 5]
  my_move(3): |L|=3 = k，无需调整
  L.top() = 3  ← 第 3 小 = 3 ✓
```

验证：序列 $[1, 2, 3, 4, 5]$ 的第 $3$ 小是 $3$，正确。

### 调整 $k$ 值示意

将 $k$ 从 $3$ 改为 $2$，调用 `my_move(2)`：

```
调整前: L: [3, 1, 2] (|L|=3)    R: [4, 5]
        L.top() = 3  ← 第 3 小

my_move(2): |L|=3 > 2，从 L 取堆顶移入 R
  L: [2, 1]       R: [3, 4, 5]
  L.top() = 2  ← 第 2 小 = 2 ✓
```

## 核心操作详解

### 1. `add(x, k)` — 插入元素

```cpp
void add(int x, int k)
{
    if (L.empty()) { L.emplace(x); return; }
    if (x > L.top()) R.emplace(x);
    else L.emplace(x);
    my_move(k);
}
```

- 若 $L$ 为空，直接放入 $L$（第一个元素）
- 若 $x > L.\text{top}()$，说明 $x$ 属于"较大的一半"，放入 $R$
- 否则 $x$ 属于"较小的一半"，放入 $L$
- 插入后调用 `my_move(k)` 重新平衡

关键：插入时只需与 $L.\text{top}()$ 比较一次即可决定放入哪个堆，因为不变量保证 $L$ 中所有元素 $\le$ $R$ 中所有元素。

### 2. `my_move(k)` — 重新平衡

```cpp
void my_move(int k)
{
    while (!L.empty() && L.size() > k)
    {
        int x = L.top(); L.pop();
        R.emplace(x);
    }
    while (!R.empty() && L.size() < k)
    {
        int x = R.top(); R.pop();
        L.emplace(x);
    }
}
```

- 第一个 `while`：若 $|L| > k$，把 $L$ 堆顶（最大的）移到 $R$，直到 $|L| = k$
- 第二个 `while`：若 $|L| < k$，把 $R$ 堆顶（最小的）移到 $L$，直到 $|L| = k$

移动方向保证不变量不被破坏：
- $L \to R$：移出的是 $L$ 中最大的，它 $\le$ $R$ 中已有的所有元素（因为 $R$ 中的元素原本就 $> L.\text{top}()$），放入 $R$ 后仍满足不变量
- $R \to L$：移出的是 $R$ 中最小的，它 $\ge$ $L$ 中已有的所有元素，放入 $L$ 后仍满足不变量

### 3. 查询第 $k$ 小

直接读取 $L.\text{top}()$，$O(1)$。

### 4. 修改 $k$ 值

直接修改 $k$，然后调用 `my_move(k)` 重新平衡。最坏情况下需要移动 $O(n)$ 个元素，每次移动 $O(\log n)$，总复杂度 $O(n \log n)$。

## 逐行代码解析

以下按模块拆分，各代码块按顺序拼接即与 `Untitled1.cpp` 完全一致。

### 头文件与全局堆

```cpp
#include<bits/stdc++.h>
using namespace std;
priority_queue<int> L;                                   // 大根堆：存较小的 k 个元素
priority_queue<int, vector<int>, greater<int>> R;        // 小根堆：存其余元素
```

- `L` 是大根堆（`priority_queue<int>` 默认大根堆），堆顶是这 $k$ 个元素中最大的，即第 $k$ 小。
- `R` 是小根堆（第三个模板参数 `greater<int>` 使其变为小根堆），堆顶是第 $k+1$ 小。
- 两个堆都声明在全局，方便 `add` 与 `my_move` 直接访问、共享状态。

### my_move — 重新平衡

```cpp
void my_move(int k)
{
	while (!L.empty() && L.size() > k)   // |L| > k：把 L 堆顶（最大）移到 R
	{
		int x = L.top();
		L.pop();
		R.emplace(x);
	}
	while (!R.empty() && L.size() < k)   // |L| < k：把 R 堆顶（最小）移到 L
	{
		int x = R.top();
		R.pop();
		L.emplace(x);
	}
}
```

- 第一个 `while`：$|L| > k$ 时把 $L$ 堆顶（最大）移到 $R$，直到 $|L| = k$。
- 第二个 `while`：$|L| < k$ 时把 $R$ 堆顶（最小）移到 $L$，直到 $|L| = k$。
- 两个 `while` 条件互斥（一个处理 $> k$，一个处理 $< k$），不会同时执行；移动时取堆顶保证不变量不被破坏。
- `emplace` 直接原地构造，比 `push` 略快（避免临时对象）。

### add — 插入元素

```cpp
void add(int x,int k)
{
	if (L.empty())          // 空堆特判：避免对空堆调用 top()
	{
		L.emplace(x);
		return;
	}
	if (x > L.top()) R.emplace(x);   // 属于"较大的一半"，放 R
	else L.emplace(x);               // 属于"较小的一半"，放 L
	my_move(k);
}
```

- 只需与 $L.\text{top}()$ 比较一次即可决定放哪：$x > L.\text{top}()$ 放 $R$，否则放 $L$。
- 空堆特判 `if (L.empty())` 是必要的，避免对空堆调用 `top()`（未定义行为）。
- 插入后调用 `my_move(k)` 重新平衡；插入最多使 $|L|$ 偏移 1，故平衡最多移动 1 个元素。

### main — 读入与初始建堆

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n,k,q;
	//n: 初始数据量 , k: 初始维护第k小 , q: 操作数
	cin >> n >> k >> q;
	for (int i = 1; i <= n; i++)
	{
		int x;
		cin >> x;
		add(x, k);
	}
	cout << "当前第k小的元素是： " << L.top() << '\n';
```

- `ios::sync_with_stdio(false)` 与解绑 `cin`/`cout` 是快读优化，关闭与 C 风格 I/O 的同步。
- 读入初始数据量 $n$、维护第 $k$ 小、操作数 $q$。
- 循环读入 $n$ 个初始元素，每次 `add` 后自动平衡；建堆完成后 `L.top()` 即为第 $k$ 小。

### main — 处理操作

```cpp
	while (q--)                           // 处理 q 次操作
	{
		int op;
		cin >> op;
		if (op == 1) cout << "当前第k小的元素是： " << L.top() << '\n';   // 查询第 k 小
		else if (op == 2)                  // 插入新元素
		{
			int x;
			cin >> x;
			add(x, k);
		}
		else if (op == 3)                  // 修改 k 值并重新平衡
		{
			cin >> k;
			my_move(k);
		}
	}
	return 0;
}
```

- `op = 1`：查询第 $k$ 小，直接读 `L.top()`，$O(1)$。
- `op = 2`：读入新元素并 `add(x, k)`，$O(\log n)$。
- `op = 3`：读入新 $k$ 并调用 `my_move(k)` 重新平衡，$O(|size差| \cdot \log n)$。

## 复杂度分析

| 操作 | 时间复杂度 | 说明 |
|---|---|---|
| 插入 `add` | $O(\log n)$ | 堆插入 $O(\log n)$ $+$ 平衡（最多移动 1 个元素）$O(\log n)$ |
| 查询第 $k$ 小 | $O(1)$ | 直接读 $L.\text{top}()$ |
| 修改 $k$ 值 `my_move` | $O(\lvert\Delta\rvert \cdot \log n)$ | $\Delta$ 为需要移动的元素数量，最坏 $O(n \log n)$ |
| 空间 | $O(n)$ | 两个堆共存储 $n$ 个元素 |

插入的平摊复杂度：每次 `add` 后 `my_move` 最多移动 1 个元素（因为插入前后 $|L|$ 最多偏移 1），所以单次插入确实是 $O(\log n)$。

## 适用场景

**适用**：
- 动态维护中位数（$k = \lfloor n/2 \rfloor + 1$），如数据流中位数
- 动态维护第 $k$ 小/大，且 $k$ 可能变化
- 在线插入 $+$ 查询，无法预先排序的场景
- 需要频繁修改 $k$ 值的场景

**不适用**：
- 静态序列求第 $k$ 小：直接排序或用快速选择（Quickselect）$O(n)$ 更优
- 需要删除任意元素的场景：堆不支持随机删除，需要懒删除或使用平衡树
- 需要查询区间第 $k$ 小：应用主席树（可持久化线段树）或整体二分
- 元素需要去重的场景：需要额外维护计数

## 常见陷阱与注意事项

1. **空堆调用 `top()`**
   - 对空堆调用 `top()` 是未定义行为，可能导致段错误
   - `add` 函数中空堆特判 `if (L.empty())` 是必要的
   - 查询前应确保 $L$ 非空

2. **大根堆与小根堆的方向**
   - `priority_queue<int>` 默认是大根堆（堆顶最大）
   - `priority_queue<int, vector<int>, greater<int>>` 是小根堆（堆顶最小）
   - 方向搞反会导致"第 $k$ 小"变成"第 $k$ 大"

3. **$k$ 的语义**
   - $L$ 保存较小的 $k$ 个元素时，$L.\text{top}()$ 是第 $k$ 小
   - 若要维护第 $k$ 大，让 $R$ 保存较大的 $k$ 个元素，读 $R.\text{top}()$
   - 维护中位数时，$k = \lfloor n/2 \rfloor + 1$（奇数个元素取中间）

4. **平衡的正确性**
   - `my_move` 先处理 $|L| > k$（从 $L$ 移到 $R$），再处理 $|L| < k$（从 $R$ 移到 $L$）
   - 两个 `while` 顺序不能反：若先从 $R$ 移到 $L$，可能导致 $|L|$ 先增大再减少，多做无用功
   - 移动时必须取堆顶（$L$ 取最大移到 $R$，$R$ 取最小移到 $L$），保证不变量

5. **整数溢出**
   - 本代码元素为 `int`，若元素值接近 `INT_MAX` 且涉及加减运算，需改用 `long long`
   - 对顶堆本身不涉及元素加减（仅比较和移动），一般不会溢出

6. **`emplace` vs `push`**
   - `emplace` 直接在容器中原位构造，`push` 先构造临时对象再移动/拷贝
   - 对于 `int` 等基本类型，两者性能无差异
   - 习惯上用 `emplace` 更统一

7. **输入合法性的约定**
   - 本模板**假设输入合法**：初始有 $n \ge 1$ 个元素、$k$ 在有效范围内（$1 \le k \le 元素总数$）、操作码 $op \in \{1,2,3\}$ 且查询/删除时堆非空。
   - 代码不处理空堆 `top()`、$k$ 越界、非法 $op$ 这类异常——这些属于调用方的保证，竞赛模板通常省略这些防御。

## 对比与扩展

| 对比维度 | 对顶堆 | 平衡树（Splay） | 主席树（可持久化线段树） | 快速选择 |
|---|---|---|---|---|
| 动态插入 | $O(\log n)$ | $O(\log n)$ | 不支持（静态） | 不支持 |
| 查询第 $k$ 小 | $O(1)$ | $O(\log n)$ | $O(\log n)$ | $O(n)$（单次） |
| 修改 $k$ 值 | $O(\lvert\Delta\rvert \log n)$ | $O(\log n)$ | — | — |
| 删除元素 | 不支持 | $O(\log n)$ | 不支持 | 不支持 |
| 区间第 $k$ 小 | 不支持 | 不支持 | 支持 | 不支持 |
| 空间 | $O(n)$ | $O(n)$ | $O(n \log n)$ | $O(n)$ |
| 实现难度 | 低 | 高 | 中 | 中 |
| 适用场景 | 动态第 $k$ 小 | 全功能动态查询 | 静态区间第 $k$ 小 | 静态单次第 $k$ 小 |

**扩展**：
- 对顶堆是"对顶数据结构"思想的体现。类似地，可以用两个单调队列维护滑动窗口最值（见 `ds-monoqueue-1d`），或用两个栈模拟队列
- 若需要支持删除任意元素，可以用懒删除：标记已删除元素，在堆顶是已删除元素时弹出
- 若需要同时维护第 $k$ 小和第 $k$ 大，可以用三个堆（$L$、$M$、$R$）或两个对顶堆
- 维护动态中位数是对顶堆最经典的应用，$k = \lfloor n/2 \rfloor + 1$ 时 $L.\text{top}()$ 即为中位数$AKB140$, '数据结构', array['数据结构', '堆', '对顶堆', '优先队列', '动态第k小', '中位数'], null, null, 'knowledge'),
('stripe-python', 'col-ds-fast-block-list--stripe-python', '更快的块状链表 · stripe-python', $AKB141$> 本文由 stripe-python 授权合并，保留原文结构与表述。
之前我写过一篇文章：[浅谈一种黑科技——索引树优化块状链表](https://www.luogu.com.cn/article/h17wdap7)，说人话就是对于每个块的长度建一棵线段树。

今天去 P6136 看了一下，怎么有[高手](https://www.luogu.com.cn/record/237192574)卡到 2.5s 了？

翻了下代码，发现最大的改变就是把线段树变成了树状数组。于是花 eps 时间实现了这个东西，又花 eps 时间写了一个对读入分块的 `extend` 函数，交上去，不是怎么 2.7s。

换成 C++20，这下 2.52s 了。

## 原理

考虑一下普通块链慢在哪里。

设块长为 $B$。通过记录块内最大值，插入删除找块是 $O(\log \dfrac{n}{B})$ 的，块内插入删除是 $O(B)$ 的。分裂合并的复杂度是 $O(B+\dfrac{n}{B})$ 的。

考虑到分裂合并不是很多，$B$ 应该取一个 $O(\sqrt{n})$ 级别又小于 $\sqrt{n}$ 的数。这部分没法优化了。

思考找数的时候怎么找。传统的方法就是一个块一个块扫过去，复杂度 $O(\dfrac{n}{B})$。于是为了让 $O(B)$ 和 $O(\dfrac{n}{B})$ 平衡，取 $B=\sqrt{n}$，复杂度 $O(n\sqrt{n})$，FHQ 都跑不过。

用一个树状数组 / 线段树维护每个块的块长，发生修改时暴力重构。找数在线段树上二分或者树状数组上倍增即可。复杂度 $O(\log \dfrac{n}{B})$。重构复杂度 $O(\dfrac{n}{B})$。

总体算下来复杂度 $O(B+\dfrac{n}{B})$。通过微调块长，重构次数原低于 $\sqrt{n}$，于是 $B$ 取一个小于 $\sqrt{n}$ 的数没有问题。

实测 $B=150$ 时，在 C++20 且使用树状数组优化下最快。

## 板子

### 树状数组版本

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 150;
	int len, load;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;

	void expand(int pos) {
		if ((int) lists[pos].size() > (load << 1)) {
			std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
			lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
			maxes[pos] = lists[pos].back();
			lists.insert(lists.begin() + pos + 1, half);
			maxes.insert(maxes.begin() + pos + 1, half.back());
			index.clear();
		} else if (!index.empty()) {
			int n = index.size();
			for (int i = pos + 1; i < n; i += (i & -i)) index[i]++;
		}
	}

	void build_index() {
		int n = lists.size();
		index.resize(n, 0);
		for (int i = 1; i < n; i++) {
			index[i] += lists[i - 1].size();
			if (i + (i & -i) < n) index[i + (i & -i)] += index[i];
		}
	}

	std::pair<int, int> pos(int idx) {
		if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
		if (index.empty()) build_index();
		int p = 0, n = index.size();
		for (int i = std::__lg(n); i >= 0; i--) {
			if (p + (1 << i) < n && idx >= index[p + (1 << i)]) idx -= index[p + (1 << i)], p += 1 << i;
		}
		return std::make_pair(p, idx);
	}
	int loc(int pos, int idx) {
		if (pos == 0) return idx;
		if (index.empty()) build_index();
		for (; pos; pos -= (pos & -pos)) idx += index[pos];
		return idx;
	}
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR) {}
	template <class It> sorted_vector(const It& bg, const It& ed)
	: len(0), load(DEFAULT_LOAD_FACTOR) {extend(bg, ed);}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}

	void clear() {len = 0, lists.clear(), maxes.clear(), index.clear();}

	void add(const T& val) {
		if (!maxes.empty()) {
			int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
			if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
			else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
			expand(pos);
		} else {
			lists.emplace_back(1, val), maxes.emplace_back(val);
		} len++;
	}
  template <class It> void extend(const It& bg, const It& ed) {
		if ((ed - bg) * 4 < len) {
			for (It it = bg; it != ed; it++) add(*it);
			return;
		}
		vector<T> a(bg, ed);
		for (const auto& vec : lists) a.insert(a.end(), vec.begin(), vec.end());
		std::sort(a.begin(), a.end());
		clear(), len = a.size();
		for (int pos = 0; pos < len; pos += load) {
			std::vector<T> vec(a.begin() + pos, a.begin() + std::min(len, pos + load));
			lists.emplace_back(vec), maxes.emplace_back(vec.back());
		}
	}

	bool erase(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		if (lists[pos][idx] != val) return false;

		lists[pos].erase(lists[pos].begin() + idx), len--;
		int n = lists[pos].size();
		if (n > (load >> 1)) {
			maxes[pos] = lists[pos].back();
			if (!index.empty()) {
				int n = index.size();
				for (int i = pos + 1; i < n; i += (i & -i)) index[i]--;
			}
		} else if (lists.size() > 1) {
			if (!pos) pos++;
			int pre = pos - 1;
			lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
			maxes[pre] = lists[pre].back();
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear(), expand(pre);
		} else if (n > 0) {
			maxes[pos] = lists[pos].back();
		} else {
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear();
		} return true;
	}

	T operator[] (int idx) {
		auto pir = pos(idx);
		return lists[pir.first][pir.second];
	}

	int lower_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int upper_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int count(const T& val) {
		if (maxes.empty()) return 0;
		int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (l == (int) maxes.size()) return 0;
		int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
		if (r == (int) maxes.size()) return len - loc(l, x);
		int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
		if (l == r) return y - x;
		return loc(r, y) - loc(l, x);
	}
	bool contains(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		return lists[pos][idx] == val;
	}
};
```

### 线段树版本（原版）

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 340;
	int len, load, offset;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;

	void expand(int pos) {
		if ((int) lists[pos].size() > (load << 1)) {
			std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
			lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
			maxes[pos] = lists[pos].back();
			lists.insert(lists.begin() + pos + 1, half);
			maxes.insert(maxes.begin() + pos + 1, half.back());
			index.clear();
		} else if (!index.empty()) {
			for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]++;
			index[0]++;
		}
	}

	std::vector<int> parent(const std::vector<int>& a) {
		int n = a.size();
		std::vector<int> res(n >> 1);
		for (int i = 0; i < (n >> 1); i++) res[i] = a[i << 1] + a[i << 1 | 1];
		return res;
	}
	void build_index() {
		std::vector<int> row0;
		for (const auto& v : lists) row0.emplace_back(v.size());
		if (row0.size() == 1) return index = row0, offset = 0, void();
		std::vector<int> row1 = parent(row0);
		if (row0.size() & 1) row1.emplace_back(row0.back());
		if (row1.size() == 1) {
			index.emplace_back(row1[0]);
			for (int i : row0) index.emplace_back(i);
			return offset = 1, void();
		}
		int dep = 1 << (std::__lg(row1.size() - 1) + 1), u = row1.size();
		for (int i = 1; i <= dep - u; i++) row1.emplace_back(0);
		std::vector<std::vector<int>> tree = {row0, row1};
		while (tree.back().size() > 1) tree.emplace_back(parent(tree.back()));
		for (int i = tree.size() - 1; i >= 0; i--) index.insert(index.end(), tree[i].begin(), tree[i].end());
		offset = (dep << 1) - 1;
	}

	std::pair<int, int> pos(int idx) {
		if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
		if (index.empty()) build_index();
		int p = 0, n = index.size();
		for (int i = 1; i < n; i = p << 1 | 1) {
			if (idx < index[i]) p = i;
			else idx -= index[i], p = i + 1;
		} return std::make_pair(p - offset, idx);
	}

	int loc(int pos, int idx) {
		if (pos == 0) return idx;
		if (index.empty()) build_index();
		int tot = 0;
		for (pos += offset; pos; pos = (pos - 1) >> 1) {
			if (!(pos & 1)) tot += index[pos - 1];
		} return tot + idx;
	}
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR), offset(0) {}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}

	void clear() {
		len = 0, offset = 0;
		lists.clear(), maxes.clear(), index.clear();
	}

	void add(const T& val) {
		if (!maxes.empty()) {
			int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
			if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
			else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
			expand(pos);
		} else {
			lists.emplace_back(1, val), maxes.emplace_back(val);
		} len++;
	}
  template <class It> void extend(const It& bg, const It& ed) {
		if ((ed - bg) * 4 < len) {
			for (It it = bg; it != ed; it++) add(*it);
			return;
		}
		vector<T> a(bg, ed);
		for (const auto& vec : lists) a.insert(a.end(), vec.begin(), vec.end());
		std::sort(a.begin(), a.end());
		clear(), len = a.size();
		for (int pos = 0; pos < len; pos += load) {
			std::vector<T> vec(a.begin() + pos, a.begin() + std::min(len, pos + load));
			lists.emplace_back(vec), maxes.emplace_back(vec.back());
		}
	}

	bool erase(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		if (lists[pos][idx] != val) return false;

		lists[pos].erase(lists[pos].begin() + idx), len--;
		int n = lists[pos].size();
		if (n > (load >> 1)) {
			maxes[pos] = lists[pos].back();
			if (!index.empty()) {
				for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]--;
				index[0]--;
			}
		} else if (lists.size() > 1) {
			if (!pos) pos++;
			int pre = pos - 1;
			lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
			maxes[pre] = lists[pre].back();
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear(), expand(pre);
		} else if (n > 0) {
			maxes[pos] = lists[pos].back();
		} else {
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear();
		} return true;
	}

	T operator[] (int idx) {
		auto pir = pos(idx);
		return lists[pir.first][pir.second];
	}

	int lower_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int upper_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int count(const T& val) {
		if (maxes.empty()) return 0;
		int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (l == (int) maxes.size()) return 0;
		int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
		if (r == (int) maxes.size()) return len - loc(l, x);
		int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
		if (l == r) return y - x;
		return loc(r, y) - loc(l, x);
	}
	bool contains(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		return lists[pos][idx] == val;
	}
};
```

说说这板子怎么用。

- `DEFAULT_LOAD_FACTOR` 是默认块长，实际使用时可以根据需要调整。
- `size(), empty(), clear()`：和 STL 容器一样。
- `add(const T& x)`：插入一个元素 `x`。
- `extend(begin, end)`：插入一段 `[begin, end)` 中的元素。比一个一个 `add` 快。
- `erase(const T& x)`：删除**一个**元素 `x`。若删除成功返回 `true`。若没有找到也不会报错，返回 `false`。
- `operator [](int idx)`：查找排名为 `idx` 的数。排名从 $0$ 开始。若 `idx` 为负或者超过当前长度，行为未定义。
- `lower_bound(const T& val) / upper_bound(const T& val)`：返回 `val` 的前驱 / 后继的**排名**。若没有，返回当前长度。
- `count(const T& val) / contains(const T& val)`：查找 `val` 的出现次数 / 查找 `val` 是否出现。$AKB141$, '数据结构', array['块状链表', '树状数组', '分块', '卡常'], 'col-hub-ds-block', null, 'knowledge'),
('Fohen', 'col-ds-fhq-treap--fenfeng', 'FHQ-Treap（无旋平衡树） · Fohen', $AKB142$## 算法原理

FHQ-Treap（全称「非旋转式 Treap 及可持久化」）由中国 OIer 范浩强发明。它保留 Treap「用随机优先级维持平衡」的核心思想，却完全抛弃旋转操作，把整棵平衡树的所有增删改查归结为两个原子操作：**Split（分裂）** 与 **Merge（合并）**。

**Treap = Tree + Heap**，每个节点同时满足两条性质：

1. **二叉搜索树（BST）性质**：左子树所有键值小于根，右子树所有键值大于根，中序遍历得到有序序列。
2. **堆性质**：每个节点携带一个与键值完全无关的**随机优先级**，父节点的优先级大于子节点，形成堆结构。

随机优先级是平衡的秘诀：因为优先级随机、与键值无关，每个节点等概率成为根，整棵树的期望高度为 $O(\log n)$，从而所有操作期望 $O(\log n)$。相比带旋转的 Treap / AVL / 红黑树，FHQ-Treap 不维护平衡因子、不写旋转函数，代码短、逻辑清晰，还天然支持可持久化，因此成为竞赛中最常用的平衡树实现之一。

## 核心公式 / 状态定义与转移方程

**状态定义**：节点 $u$ 存键值 `cnt`、随机优先级 `prw`、左右儿子 `ls,rs`、子树大小 `sz`、重复计数 `cho`；整棵树以根下标 `rot` 标识。子树大小不变量：

$$sz_u = sz_{ls_u} + sz_{rs_u} + cho_u$$

**Split 转移**：$\mathrm{split}(u,v)$ 返回两棵树 $(x,y)$，其中 $x$ 含所有键值 $\le v$ 的节点，$y$ 含所有键值 $>v$ 的节点。按「当前根与 $v$ 的大小关系」分三种情况：

- $u=0$：$(x,y)=(0,0)$；
- $val_u \le v$：根连同整个左子树归入 $x$（令 $x=u$），再对右子树递归 $\mathrm{split}(rs_u,v)\Rightarrow(rs_u,y)$；
- $val_u > v$：根连同整个右子树归入 $y$（令 $y=u$），再对左子树递归 $\mathrm{split}(ls_u,v)\Rightarrow(x,ls_u)$。

**Merge 转移**：$\mathrm{merge}(x,y)$ 把两棵树合并为一棵，前提是 $x$ 中所有键值都不大于 $y$ 中所有键值。比较两棵根的随机优先级（本代码为小根堆，`prw` 小者作根）：

- $x=0$ 或 $y=0$：返回另一棵；
- $pri_x < pri_y$：$x$ 作新根，其右子树改为 $\mathrm{merge}(rs_x,y)$；
- $pri_x \ge pri_y$：$y$ 作新根，其左子树改为 $\mathrm{merge}(x,ls_y)$。

**操作组合**（$a,b,c$ 为切出的三段）：

$$\mathrm{insert}(v):\quad \mathrm{split}(rot,v)\Rightarrow(a,b),\quad rot=\mathrm{merge}(\mathrm{merge}(a,\mathrm{new}(v)),b)$$

$$\mathrm{erase}(v):\quad \mathrm{split}(rot,v)\Rightarrow(a,c),\ \mathrm{split}(a,v-1)\Rightarrow(a,b),\ b=\mathrm{merge}(ls_b,rs_b),\ rot=\mathrm{merge}(\mathrm{merge}(a,b),c)$$

查询排名用 $\mathrm{split}(rot,x-1)$ 后取 $|a|+1$；查询第 $k$ 小沿 `sz` 在树上二分；前驱/后继分别取切分后左半最大值、右半最小值。

## 逐行代码解析

下面是完整实现（洛谷 P3369「普通平衡树」的六种操作）。字段命名与上文对应：`cnt` 为键值、`cho` 为重复计数、`prw` 为随机优先级、`u` 为节点自存的下标。

### 模块一：头文件、全局数组、节点结构与 `nwn`/`pulp`

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=4e5+10;
int tot=0,rot=0;
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
int nwn(int v) {
    tot++;
    wcj[tot]=bst(tot,v);
    return tot;
}
void pulp(int u){
	wcj[u].sz=wcj[wcj[u].ls].sz+wcj[wcj[u].rs].sz+wcj[u].cho;
}
```

- `#define int long long` 把 `int` 全局替换为 `long long`，因此主函数必须写成 `signed main`（`signed` 即 `int`），避免返回值类型冲突。
- `rdm[N]` 预生成 $n$ 个随机优先级，节点构造时直接取 `rdm[tot]`，保证每个节点的优先级稳定不变。
- `wcj` 是节点数组，下标即节点编号；`bst(int b,int x)` 用键值 $x$ 初始化节点，`cho=1` 表示当前有 1 个该键值。
- `pulp`（pushup）维护子树大小：`sz = 左子树大小 + 右子树大小 + 重复计数`。

### 模块二：`split` 按键值分裂

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

- 空节点直接置 `x=y=0` 返回。
- `wcj[u].cnt <= v`：根及整棵左子树都 $\le v$，归入 $x$；右子树可能混合，于是 `split(rs, v, rs, y)` 把切出的左半**接回** `u` 的右儿子。
- 否则根及右子树都 $>v$，归入 $y$，递归分裂左子树并接回 `u` 的左儿子。
- `wcj[u].rs` / `wcj[u].ls` 作为**引用**传入，分裂结果原地写回对应儿子，不改变父子关系，堆性质自然保持。

### 模块三：`merge` 按优先级合并

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

- 一棵为空时直接返回另一棵（`x|y` 等价于 `x ? x : y`，因为节点下标从 1 开始、0 表示空）。
- 小根堆：`wcj[x].prw < wcj[y].prw` 时 $x$ 作根，递归合并 $x$ 的右子树与 $y$；否则 $y$ 作根，递归合并 $x$ 与 $y$ 的左子树。
- 每次合并后调用 `pulp` 更新子树大小。
- 正确性前提：$x$ 中所有键值 $\le$ $y$ 中所有键值，Merge 才保证合并后仍是 BST。

### 模块四：查找、插入与删除

```cpp
int cxsearch(int b,int v){
	if(wcj[b].u==0||wcj[b].cnt==v) return wcj[b].u;//返回下标
	if(v<wcj[b].cnt) return cxsearch(wcj[b].ls,v);
	else return cxsearch(wcj[b].rs,v);
}
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

- `cxsearch` 沿键值比较递归下探，找到键值为 $v$ 的节点返回其下标。
- `crinsert`：两次 `split` 把 $\le v$、$=v$、$>v$ 三段切出；若 $=v$ 段为空则新建节点插入，否则 `cho++` 累加重复计数。
- `scdelete`：同理切出三段；若重复计数 `cho==1` 则丢弃根（合并其左右儿子），否则 `cho--`。
- 插入/删除后都要把三段 `merge` 回去，并把结果写回 `rot`（由调用处 `rot=crinsert(x)` 完成）。

### 模块五：查排名与查第 $k$ 小

```cpp
// 返回树中值 < x 的节点个数
int queryless(int b,int x){
    if(b==0) return 0;
    if(x<=wcj[b].cnt){
        return queryless(wcj[b].ls,x);
    }else{
        return wcj[wcj[b].ls].sz+wcj[b].cho+queryless(wcj[b].rs,x);
    }
}
// 返回第 k 小的值
int kth(int b,int k){
    if(k<=wcj[wcj[b].ls].sz){
        return kth(wcj[b].ls,k);
    }else if (k<=wcj[wcj[b].ls].sz+wcj[b].cho){
        return wcj[b].cnt;
    }else{
        return kth(wcj[b].rs,k-wcj[wcj[b].ls].sz-wcj[b].cho);
    }
}
```

- `queryless(b,x)` 返回「键值 $<x$ 的节点个数」：沿键值下探，向左走不累加，向右走累加左子树大小 + 当前 `cho`。
- 排名 $=queryless(rot,x)+1$，见主函数 opt 3。
- `kth(b,k)` 按子树大小二分：$k\le sz_{ls}$ 走左，$k\le sz_{ls}+cho$ 命中当前键值，否则走右并减掉左子树与当前节点的大小。
- 两个函数都只沿一条到叶子的路径递归，期望 $O(\log n)$。

### 模块六：前驱、后继与主函数

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
int houjiji(int b,int x){
    int ans=LLONG_MAX;
    while(b!=0){
        if(wcj[b].cnt>x){
            ans=wcj[b].cnt;
            b=wcj[b].ls;
        }else{
            b=wcj[b].rs;
        }
    }
    return ans;
}
signed main(){
	//主函数实现的是P3369
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n;cin>>n;
    for(int i=1;i<=n;i++) rdm[i]=rng(); 
    while(n--){
		int opt,x;cin>>opt>>x;
		if(opt==1) rot=crinsert(x);
		else if(opt==2) rot=scdelete(x);
		else if(opt==3) cout<<queryless(rot,x)+1<<'\n';
		else if(opt==4) cout<<kth(rot,x)<<'\n';
		else if(opt==5) cout<<qianququ(rot,x)<<"\n";
		else if(opt==6) cout<<houjiji(rot,x)<<'\n';
	}
    return 0;
}
```

- `qianququ` 沿键值下探，维护「$<$ x 的键值中的最大者」，返回前驱（无则 `LLONG_MIN`）。
- `houjiji` 对称地维护「$>$ x 的键值中的最小者」，返回后继（无则 `LLONG_MAX`）。
- `main` 实现 P3369 六种操作：1 插入、2 删除、3 查排名、4 查第 $k$ 小、5 前驱、6 后继。
- 每次操作后 `rot` 被赋值为新的根下标，保证下一次操作作用在最新树上。

## 复杂度分析

- **时间复杂度**：`split` 与 `merge` 都只沿一条从根到叶的路径递归，期望树高为 $O(\log n)$，故两者期望 $O(\log n)$；插入、删除、排名、第 $k$ 小、前驱后继都由常数次 `split`/`merge` 或一次树上二分组成，期望均为 $O(\log n)$。
- **空间复杂度**：每个键值对应一个节点，节点为定长结构体，总空间 $O(n)$；`rdm` 数组同样 $O(n)$。

## 适用场景

- **动态有序集合**：需要同时支持插入、删除、查排名、查第 $k$ 小、前驱后继的题目，典型如洛谷 P3369、P6136（普通平衡树）。
- **竞赛快速实现**：不写旋转、不维护平衡因子，代码量小、逻辑清晰，适合需要平衡树但不想手写 AVL/红黑树的场景。
- **可持久化基础**：FHQ-Treap 无旋转、天然适合路径复制，是可持久化平衡树的标准底座。
- **序列/区间维护**：把「按键值分裂」换成「按子树大小分裂」，即可实现区间翻转等操作（文艺平衡树）。
- 不适用：需要严格最坏 $O(\log n)$ 且常数敏感的场合，可考虑 AVL/红黑树或 `std::set`/`std::multiset`；极少数刻意针对随机优先级的构造数据也需换严格平衡树。

## 常见陷阱与注意事项

1. **`split` 的引用回写**：`wcj[u].rs` 作为引用参数传给下一层 `split`，切出的左半必须接回 $u$ 的右儿子；若改成传值，分裂结果丢失、树被拆散。
2. **`merge` 的前提**：$x$ 中所有键值必须 $\le$ $y$ 中所有键值。随意 `merge` 两棵不满足该前提的树会破坏 BST 性质。
3. **删除要两次 `split` 隔离**：先按 $v$、再按 $v-1$ 切出「恰好等于 $v$」的一段；重复计数 `cho==1` 时才真正删节点（合并左右儿子），否则只 `cho--`。
4. **`#define int long long` 的连锁**：主函数必须用 `signed main()`，否则 `long long main` 非法；`int` 与 `long long` 混用也要注意，否则可能编译报错或溢出。
5. **随机数质量**：用 `mt19937_64` 而非 `rand()`，并用 `rdm` 数组预生成，保证节点优先级稳定；若用固定的 `rand()` 种子，可能被针对性卡掉。
6. **小根堆方向**：本代码 `prw` 小的作根；若改写成大根堆，`merge` 中的比较号要同步反转，否则堆性质失效。
7. **排名要 +1**：`queryless` 统计的是「严格小于 $x$」的个数，输出排名需 `queryless(rot,x)+1`。
8. **重复值的子树大小**：`kth` 的边界比较要含 `cho`（$k\le sz_{ls}+cho$），忽略重复计数会在有重复键值时找错第 $k$ 小。

## 对比与扩展

| 结构 | 是否旋转 | 复杂度 | 主要优势 | 主要代价 |
|---|---|---|---|---|
| FHQ-Treap | 否 | 期望 $O(\log n)$ | 代码短、可持久化 | 随机化，最坏退化 |
| 旋转 Treap | 是 | 期望 $O(\log n)$ | 思路直观 | 需写旋转 |
| Splay | 是（伸展） | 均摊 $O(\log n)$ | 区间操作强 | 常数较大 |
| AVL / 红黑树 | 是 | 严格 $O(\log n)$ | 最坏有保证 | 平衡调整复杂 |
| `std::set` / `std::multiset` | 无 | $O(\log n)$ | 现成可用 | 功能受限、无法扩展 |

- **与旋转 Treap 对比**：两者都用随机优先级维持平衡，但 FHQ-Treap 用 Split/Merge 替代旋转，省去旋转函数的边界处理，且天然支持可持久化。
- **与 Splay 对比**：Splay 靠均摊保证复杂度、区间操作能力更强；FHQ-Treap 是期望复杂度、实现更简单。
- **扩展方向**：可持久化 FHQ-Treap（路径复制）、文艺平衡树（按子树大小分裂 + 懒标记区间翻转）、区间第 $k$ 大等。
- **前置/相关**：随机优先级依赖随机数生成，见「mt19937 随机数」；可持久化思想见「可持久化数据结构」；本题是普通平衡树模板 P3369。$AKB142$, '数据结构', array['平衡树', 'FHQ-Treap', '分裂合并', '随机优先级', '可持久化'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('Xesir', 'col-ds-fhq-treap--xesir', 'FHQ-Treap（无旋 Treap） · Xesir', $AKB143$## 算法原理

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
- `crinsert` 里 `return` 之后还有 `pulp(b)`，注意哪条分支会提前返回。$AKB143$, '数据结构', array['数据结构', '平衡树', 'FHQ-Treap', '分裂', '合并', '随机优先级'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('Xesir', 'col-ds-hash-table--xesir', '哈希表（哈希函数与冲突处理） · Xesir', $AKB144$## 算法原理

哈希（hash）是一种「随机化」味道很浓的算法，可以称得上 OI 里最具暴力美学的数据结构：它能把元素映射到一个较小的下标范围里，做到**均摊 $O(1)$** 的插入与查询，内部元素是**无序**的。很多容器的底层就是哈希表，比如 `unordered_map`。

**哈希函数** $h$ 的作用，是把一个很大的值域 $U$ 映射到一个较小的值域 $[0, M-1]$（$M$ 是哈希表大小）：

$$
h: U \to \{0, 1, 2, \dots, M-1\}
$$

一个合格的哈希函数要满足三条：

- **确定性**：同一个输入永远得到同一个输出。
- **均匀性**：不同的输入要尽可能均匀地铺满整个值域，减少冲突。
- **高效性**：计算是 $O(1)$ 常数级。

最常见的是**取模**。比如取 $h(x) = x \bmod 7$，那么 $\{11, 13, 5, 2, 21\}$ 会映射到 $\{4, 6, 5, 2, 0\}$，值域从 $21$ 直接缩到 $7$。哈希函数设计得好不好，往往就是哈希优劣的分水岭。

## 核心公式 / 状态定义与转移方程

哈希表的核心矛盾：因为 $|U| \gg M$（值域远大于表长），由**鸽巢原理**，必然存在两个不同的键 $k_1 \neq k_2$ 满足 $h(k_1) = h(k_2)$，这就是**哈希冲突**。例如取 $h(x) = x \bmod 7$ 时，$6$ 和 $13$ 都落到 $6$ 号位置。

开放式探测的探测序列一般写作：

$$
h_i(k) = \big(h(k) + d_i\big) \bmod M, \qquad i = 0, 1, 2, \dots
$$

其中 $d_i$ 是探测增量。**线性探测**取 $d_i = i$，**二次探测**取 $d_i = i^2$，**双重哈希**则把增量交给第二个哈希函数，$h_i(k) = (h_1(k) + i \cdot h_2(k)) \bmod M$。

**负载因子** $\alpha = n / M$（$n$ 是已存元素数）是衡量哈希表拥挤程度的关键量：$\alpha$ 越接近 1，冲突越频繁。

## 逐行代码解析

哈希表的实现可以拆成「设计哈希函数」和「处理冲突」两块，下面按模块说明。

### 模块一：哈希函数

- 输入：任意键（整数、字符串、浮点数都行）。
- 输出：$[0, M-1]$ 内的一个下标。
- 要点：整数常用取模；字符串常用多项式哈希（把串看成进制数再取模）；关键是「均匀 + 常数时间」。原笔记特别提醒：连浮点数和字符串都能先**哈希到整数**，再套用整数哈希的思想。

### 模块二：拉链法（separate chaining）

思想：哈希表的每个位置挂一条链表，冲突的元素都挂在同一个位置的链表上。

```text
[0] -> NULL
[1] -> (key1) -> (key2) -> NULL
[2] -> NULL
[3] -> (key3) -> NULL
```

- **插入**：算出 $h(k)$，在该链表头（或尾部）插入。
- **查询**：算出 $h(k)$，遍历这条链表找 key。
- **删除**：在链表中删掉对应结点。
- 复杂度：期望 $O(1 + \alpha)$，最坏 $O(n)$（全部撞到同一个桶）。
- 优点：实现简单、删除方便；缺点：链表有指针开销，**缓存不友好**。
- `std::unordered_map` 在 GCC 下用的就是拉链法（每个桶挂链表）。

### 模块三：开放地址法（open addressing）

思想：所有元素都存在表数组**本身**里，冲突了就按规则探测下一个空位。

1. **线性探测** $h_i(k) = (h(k) + i) \bmod M$：撞了就往后找一格。问题是**一次聚集**——连续占用块越滚越大，后续插入探测步数暴增。
2. **二次探测** $h_i(k) = (h(k) + i^2) \bmod M$：冲突后跳 $1, 4, 9, 16, \dots$ 步。缓解一次聚集，但可能出现**二次聚集**（同哈希值的元素走同一条探测路径）。
3. **双重哈希** $h_i(k) = (h_1(k) + i \cdot h_2(k)) \bmod M$：用第二个哈希函数决定探测步长，效果最好，接近理想均匀分布。

- **删除要点**：开放地址法**不能直接删**（会截断探测链），必须用**懒删除标记**（tombstone，墓碑标记）。
- 优点：无指针开销、缓存友好，适合静态或读多写少的场景；缺点：删除麻烦，负载因子高时性能急剧下降（一般要求 $\alpha < 0.7$）。

### 模块四：再哈希（rehash）

当负载因子超过阈值时，新建一个更大的表（通常翻倍），把所有元素重新哈希进去。触发条件一般是 $\alpha > 0.75$（或自定义阈值）。单次扩容 $O(n)$，均摊到每次插入是 $O(1)$。`unordered_map` 与 `vector` 都会在容量不足时自动扩容。

## 复杂度分析

| 冲突方案 | 期望单次操作 | 最坏 | 删除 | 缓存友好度 |
|---|---|---|---|---|
| 拉链法 | $O(1 + \alpha)$ | $O(n)$ | 容易 | 较差 |
| 线性探测 | $O(1/(1-\alpha))$ | $O(n)$ | 需墓碑 | 好 |
| 二次 / 双重哈希 | 接近 $O(1)$ | $O(n)$ | 需墓碑 | 好 |

空间为 $O(n + M)$：$n$ 个元素加上 $M$ 个桶。再哈希把插入的均摊代价保持在 $O(1)$。

## 适用场景

- **去重 / 判重**、统计出现次数、键值映射（`unordered_map`、`unordered_set`）。
- **字符串哈希**：把字符串映射成整数，做 $O(1)$ 判等、子串哈希比较。
- **离散化 / 坐标压缩**：把大范围下标映射到小区间。
- 与并查集、Trie 结合：把浮点数、字符串这类键先哈希成整数再处理。

## 常见陷阱与注意事项

1. **哈希函数分布不均**：取模若用「常见因子」（如 $10$ 的幂）会让低位信息集中，冲突激增，$M$ 取大质数更稳。
2. **开放地址法直接删除**：会截断探测链导致后续查询失败，必须打墓碑标记。
3. **负载因子过高**：$\alpha$ 逼近 1 时探测步数暴涨，需要及时再哈希扩容。
4. **哈希被卡**：固定哈希函数在竞赛里可能被构造数据针对（如 `unordered_map` 被卡成 $O(n)$），必要时换随机种子 / 自定义哈希。
5. **最坏复杂度**：哈希只是**期望** $O(1)$，严格最坏是 $O(n)$，需要确定性最坏保证时得用平衡树。

## 对比与扩展

| 维度 | 哈希表 | 平衡树（`map` / `set`） | Trie |
|---|---|---|---|
| 单次操作 | 期望 $O(1)$ | $O(\log n)$ | $O(\|S\|)$ |
| 有序性 | 无序 | 有序，支持前驱后继 | 按字典序 |
| 最坏 | $O(n)$ | $O(\log n)$ | $O(\|S\|)$ |
| 适用 | 纯判重 / 映射 | 需要有序 | 前缀相关 |

扩展方向：**字符串哈希**（子串判等、最长公共子串）、**随机化哈希**抗卡、**std::unordered_map 的自定义哈希**，以及工程里的布隆过滤器等近似结构。$AKB144$, '数据结构', array['数据结构', '哈希', '哈希函数', '哈希冲突', '拉链法', '开放地址法'], 'col-ds-other-overview', null, 'knowledge'),
('Xesir', 'col-ds-heap--xesir', '堆（手写模拟堆） · Xesir', $AKB145$## 算法原理

堆（Heap）是一种满足特定**偏序关系**的完全二叉树，主要用于快速取得一组元素中的最大值或最小值。按维护目标不同，分为**小根堆**和**大根堆**。

需要注意，堆只保证**父子之间**的大小关系，并不保证所有元素整体有序。所以除了堆顶以外，不能直接确定其他元素的排名。

在小根堆里，任何结点的值都不大于它两个孩子的值，于是**根（堆顶）就是全局最小值**；大根堆反过来，堆顶是全局最大值。它可以用数组存完全二叉树：下标 $u$ 的左孩子是 $2u$，右孩子是 $2u+1$，父亲是 $\lfloor u/2 \rfloor$。下面这份模板还用 `ph` / `hp` 两个映射数组支持「修改 / 删除第 $k$ 个插入的数」。

## 核心操作详解

| 操作 | 实现方式 | 复杂度 |
|---|---|---|
| 取得最小值或最大值 | 访问堆顶 | $O(1)$ |
| 插入元素 | 放到数组末尾，再向上调整 | $O(\log n)$ |
| 删除堆顶 | 用末尾元素覆盖堆顶，再向下调整 | $O(\log n)$ |
| 修改任意元素 | 修改后分别尝试向上、向下调整 | $O(\log n)$ |
| 建堆 | 从后向前进行向下调整 | $O(n)$ |

核心动作只有两个：**向上调整 `up`**（新元素偏小 / 偏大时，和父亲比较并交换，一路浮上去）和**向下调整 `down`**（用末尾元素顶替堆顶后，和较小的孩子交换，一路沉下去）。

## 逐行代码解析

### 全局数组与映射

```cpp
int a[100010],ph[100010],hp[100010];int idx=0,ans=0;
```

- `a` 是按完全二叉树顺序存的堆数组（下标从 $1$ 开始）。
- `ph[k]` 记录「第 $k$ 个插入的元素在堆数组里的下标」，`hp[i]` 是反向映射「堆数组下标 $i$ 是第几个插入的」。
- `idx` 是堆数组当前大小（元素个数），`ans` 是「插入序号」计数器。

### 交换：swp

```cpp
void swp(int x,int y){
    swap(ph[hp[x]],ph[hp[y]]);swap(hp[x], hp[y]);swap(a[x],a[y]);
}
```

- 交换堆数组下标 $x, y$ 处的元素时，必须同时维护两张映射表，否则「第 $k$ 个插入的数」就指错位置了。
- 三步分别同步 `ph`、`hp`、`a`。

### 向上调整：up

```cpp
void up(int u){
    while(u/2&&a[u/2]>a[u]){
        swp(u,u/2);
        u/=2;
    }
}
```

- 当 `u` 不是根（`u/2` 有效）且父亲比当前大时，与父亲交换，然后 `u` 移到父亲位置继续。
- 这是小根堆的写法，用于插入后把新元素浮到合适位置。

### 向下调整：down

```cpp
void down(int u){
    int t=u;
    if(u*2<=idx&&a[t]>a[u*2]){
        t=u*2;
    }
    if(u*2+1<=idx&&a[t]>a[u*2+1]){
            t=u*2+1;
        }
    if(u!=t){
        swp(t,u);
            down(t);
    }
}
```

- `t` 先记当前结点，然后在左、右孩子里找出比它更小的那个（注意两次比较用的都是 `t`，所以选的是三者中最小）。
- 若最小值 `t` 不是 `u` 自己，就交换并递归向下继续调整。

### 主函数：操作分发

```cpp
int main()
{
int n;cin>>n;
for(int i=1;i<=n;i++){
    string t;cin>>t;int k,x;
    if(t=="I"){
        cin>>x;a[++idx]=x;hp[idx]=++ans;ph[ans]=idx;up(idx);
    }else if(t=="PM"){
        cout<<a[1]<<endl;          
    }else if(t=="DM"){
        swp(1,idx);idx--;down(1);
    }else if(t=="D"){
        cin>>k;k=ph[k];swp(k,idx);idx--;up(k);down(k);
    }else if(t=="C"){
        cin>>k>>x;k=ph[k];a[k]=x;up(k);down(k);
    }
}
return 0;
}
```

- `I x`：新元素放到末尾 `a[++idx]`，登记映射 `hp[idx]=++ans; ph[ans]=idx`，再向上调整。
- `PM`：输出堆顶 `a[1]`（最小值）。
- `DM`：把末尾元素换到堆顶、`idx--` 删掉末尾，再向下调整。
- `D k`：借 `ph[k]` 定位第 $k$ 个插入的数，换到末尾删除，再对换过来的位置同时 `up` / `down`（只会有一边生效）。
- `C k x`：把第 $k$ 个插入的数改成 $x$，同样 `up(k); down(k)` 双向调整。

## 复杂度分析

- 取堆顶 $O(1)$；插入、删除、修改都是沿树高走一趟，$O(\log n)$。
- 从空堆逐个插入建堆是 $O(n \log n)$；若用「从后向前的 `down`」建堆则可做到 $O(n)$。
- 存储 $O(n)$：`a` 三件套加两张映射数组。

## 适用场景

- 动态维护最值：不断插入 / 删除，却只想随时拿到最大 / 最小。
- 堆排序、Top-K 问题、Dijkstra / Prim 的候选点维护、哈夫曼树。
- 需要**随机删除 / 修改第 $k$ 个插入的数**时，就得像本模板一样手写堆并维护映射（普通 `priority_queue` 做不到）。

## 常见陷阱与注意事项

1. **下标从 1 开始**：`u/2`、`u*2`、`u*2+1` 的父子关系依赖 $1$ 号根；用 $0$ 号会算错。
2. **映射要一起换**：只要交换了 `a[x]`、`a[y]`，就必须同步 `ph` / `hp`，否则「第 k 个插入的数」全部错位。
3. **删除末尾的版本**：`DM` / `D` 用「末尾覆盖 + `idx--`」删除，别真去搬移数组。
4. **`up` 与 `down` 都要试**：修改某个元素后它可能该上浮也可能该下沉，同时调两个才稳妥。
5. **大小根方向**：把 `>` 改成 `<` 就能从小根堆变大根堆，比较方向写错会得到反的最值。

## 对比与扩展

| 实现方式 | 取最值 | 插入 / 删除 | 能否删除任意元素 |
|---|---|---|---|
| 手写堆（本条目） | $O(1)$ | $O(\log n)$ | 能（靠 `ph` / `hp`） |
| `priority_queue` | $O(1)$ | $O(\log n)$ | 不能，只能删堆顶 |
| 平衡树 / `multiset` | $O(1)$ / $O(\log n)$ | $O(\log n)$ | 能，且支持前驱后继 |

扩展方向：**可并堆**（左偏树、配对堆）、**对顶堆**（维护动态中位数，对应 `ds-dual-heap`）、以及堆优化 Dijkstra。一般场景直接用 STL 的 `priority_queue` 即可，需要随机删改时才手写。$AKB145$, '数据结构', array['数据结构', '堆', '优先队列', '向上调整', '向下调整'], null, null, 'knowledge'),
('Xesir', 'col-ds-hld-segtree--xesir', '树链剖分线段树（路径与子树操作） · Xesir', $AKB146$## 算法原理

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
- 这份实现维护的是点权；边权题要额外处理 LCA 位置的归属。$AKB146$, '数据结构', array['数据结构', '线段树', '树链剖分', '重链', '路径修改', '子树查询'], 'col-hub-ds-segtree', null, 'knowledge'),
('stripe-python', 'col-ds-index-tree-block-list--stripe-python', '索引树优化块状链表 · stripe-python', $AKB147$> 本文由 stripe-python 授权合并，保留原文结构与表述。
众所周知，块状链表实现平衡树是 $O(n\sqrt{n})$ 的，且不用一些手段卡不过[加强版](https://www.luogu.com.cn/problem/P6136)，那么有没有什么科技可以让块链达到 $O(n \log n)$ 呢？

有的兄弟，有的。在 Python 的第三方库 Sorted Containers 里实现了一种块状链表，通过建索引树倍增优化查找过程，使得单次操作的复杂度降到了均摊 $O(\log n)$。

这种块链**跑的飞快**，在 mmap 快读加持下直接跑到平衡树加强版的[次优解](https://www.luogu.com.cn/record/230047823)，C++ 的最优解。下面我们来讲解索引树优化块状链表的方法。其实这玩意就是单层跳表。

## 实现

**阅读这里的 Python 代码需要一定的 Python 基础和 Pythonic 技巧。** 如果您不会 Python，可以直接看 C++ 版实现。

首先你要下载 `sortedcontainers` 库，然后打开 `sortedlist.py` 阅读源码。

## 内部结构

先找到 `SortedList` 类，我们看看它的 `__init__` 函数：

```python
def __init__(self, iterable=None, key=None):
    assert key is None
    self._len = 0
    self._load = self.DEFAULT_LOAD_FACTOR
    self._lists = []
    self._maxes = []
    self._index = []
    self._offset = 0

    if iterable is not None:
        self._update(iterable)
```

参考这篇[知乎回答](https://www.zhihu.com/question/593450942)，我们来看看这些变量都是什么：

- `_len`：列表的长度；
- `_load`：类似于块长，当块长大于二倍时分裂，小于一半时合并。`sortedcontainers` 里的默认块长 `DEFAULT_LOAD_FACTOR` 是 $1000$，本蒟蒻实测 C++ 取 $340$ 效率较好。
- `_lists`：就是块状链表，由于 `list` 的插入删除常数很小，直接用 `list` 套 `list` 实现，它里面的每个列表都要有序。
- `_maxes`：块内最大值。这样我们可以二分找到元素所属块。
- `_index`：索引树，我们稍后讲解。
- `_offset`：偏移量，与索引树的层数有关。

分析完这些后，我们可以写出 C++ 版的代码：

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 340;
	int len, load, offset;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR), offset(0) {}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}
};
```

## 索引树

索引树的构建方法是，以这些块的长度为叶子节点，自顶向上两两合并。例如对于 `[[1, 2, 3], [4, 5], [6, 7, 8, 9], [10, 11, 12, 13, 14]]`，我们建立的索引树如图：

![](https://cdn.luogu.com.cn/upload/image_hosting/jjo90mbu.png)

这是个 Leafy Tree。因为这玩意是个满二叉树，可以堆式存储，而 `_offset` 维护的就是叶子节点的开始下标，在这里就是 $3$。

我们写出 C++ 版本的建树代码：

```cpp
std::vector<int> parent(const std::vector<int>& a) {
    int n = a.size();
    std::vector<int> res(n >> 1);
    for (int i = 0; i < (n >> 1); i++) res[i] = a[i << 1] + a[i << 1 | 1];
    return res;
}
void build_index() {
    std::vector<int> row0;
    for (const auto& v : lists) row0.emplace_back(v.size());
    if (row0.size() == 1) return index = row0, offset = 0, void();
    std::vector<int> row1 = parent(row0);
    if (row0.size() & 1) row1.emplace_back(row0.back());
    if (row1.size() == 1) {
        index.emplace_back(row1[0]);
        for (int i : row0) index.emplace_back(i);
        return offset = 1, void();
    }
    int dep = 1 << (std::__lg(row1.size() - 1) + 1), u = row1.size();
    for (int i = 1; i <= dep - u; i++) row1.emplace_back(0);
    std::vector<std::vector<int>> tree = {row0, row1};
    while (tree.back().size() > 1) tree.emplace_back(parent(tree.back()));
    for (int i = tree.size() - 1; i >= 0; i--) index.insert(index.end(), tree[i].begin(), tree[i].end());
    offset = (dep << 1) - 1;
}
```

### Python 版本建树

```python
def _build_index(self):
    row0 = list(map(len, self._lists))

    if len(row0) == 1:
        self._index[:] = row0
        self._offset = 0
        return

    head = iter(row0)
    tail = iter(head)
    row1 = list(starmap(add, zip(head, tail)))

    if len(row0) & 1:
        row1.append(row0[-1])

    if len(row1) == 1:
        self._index[:] = row1 + row0
        self._offset = 1
        return

    size = 2 ** (int(log(len(row1) - 1, 2)) + 1)
    row1.extend(repeat(0, size - len(row1)))
    tree = [row0, row1]

    while len(tree[-1]) > 1:
        head = iter(tree[-1])
        tail = iter(head)
        row = list(starmap(add, zip(head, tail)))
        tree.append(row)

    reduce(iadd, reversed(tree), self._index)
    self._offset = size * 2 - 1
```

首先建叶子层使用了 `map` 函数，它类似于 C++ 中的 `std::for_each`，对于每个范围内的元素作 `len` 操作，这样就得到了叶子节点。接下来这几行代码：

```python
head = iter(row0)
tail = iter(head)
row1 = list(starmap(add, zip(head, tail)))
```

`zip` 的作用是把 `head` 和 `tail` 压到一起，由于这里 `head` 和 `tail` 指向同一个迭代器，因此 `zip(head, tail)` 是两两交替的。`starmap` 函数是 `map` 的二元版本，通过这种操作，我们就得到了倒数第二层。之后建树同理。

```cpp
reduce(iadd, reversed(tree), self._index)
```

通过一行代码就实现了将 `tree` 中的元素翻转后，不断加到 `_index` 上。

### 位置操作

这里的位置操作有两种，分别是 `loc` 和 `pos`。`loc` 操作是将形如第几个块的第几个元素转换为整个列表的第几个元素，`pos` 则相反。我们先来看 `pos` 操作：

```python
def _pos(self, idx):
    if idx < 0:
        last_len = len(self._lists[-1])

        if (-idx) <= last_len:
            return len(self._lists) - 1, last_len + idx

        idx += self._len

        if idx < 0:
            raise IndexError('list index out of range')
    elif idx >= self._len:
        raise IndexError('list index out of range')

    if idx < len(self._lists[0]):
        return 0, idx

    _index = self._index

    if not _index:
        self._build_index()

    pos = 0
    child = 1
    len_index = len(_index)

    while child < len_index:
        index_child = _index[child]

        if idx < index_child:
            pos = child
        else:
            idx -= index_child
            pos = child + 1

        child = (pos << 1) + 1

    return (pos - self._offset, idx)
```

不用看那堆异常处理，直接看循环部分。当 `idx` 小于左子树大小时进左子树找，否则减去左子树大小并进右子树找，这和 BST 的查询操作是一致的。我们来分析一下复杂度，不妨设我们分了 $b$ 块，那么满二叉树上的一条根链为 $O(\log b)$ 级别。当 $b=O(\sqrt{n})$ 时，查询复杂度为 $O(\log n)$。再来看看 `_loc` 函数：

```python
def _loc(self, pos, idx):
    if not pos:
        return idx

    _index = self._index

    if not _index:
        self._build_index()

    total = 0

    # Increment pos to point in the index to len(self._lists[pos]).

    pos += self._offset

    # Iterate until reaching the root of the index tree at pos = 0.

    while pos:

       # Right-child nodes are at odd indices. At such indices
       # account the total below the left child node.

       if not pos & 1:
          total += _index[pos - 1]

          # Advance pos to the parent node.

       pos = (pos - 1) >> 1

   return total + idx
```

就是借助索引树来倍增跳。复杂度分析与上面相同，为 $O(\sqrt{n})$。写出 C++ 代码：

```cpp
std::pair<int, int> pos(int idx) {
    if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
    if (index.empty()) build_index();
    int p = 0, n = index.size();
    for (int i = 1; i < n; i = p << 1 | 1) {
        if (idx < index[i]) p = i;
        else idx -= index[i], p = i + 1;
    } return std::make_pair(p - offset, idx);
}

int loc(int pos, int idx) {
    if (pos == 0) return idx;
    if (index.empty()) build_index();
    int tot = 0;
    for (pos += offset; pos; pos = (pos - 1) >> 1) {
        if (!(pos & 1)) tot += index[pos - 1];
    } return tot + idx;
}
```

## 插入

找到 `add` 函数：

```python
def add(self, value):
    _lists = self._lists
    _maxes = self._maxes

    if _maxes:
        pos = bisect_right(_maxes, value)

        if pos == len(_maxes):
            pos -= 1
            _lists[pos].append(value)
            _maxes[pos] = value
        else:
            insort(_lists[pos], value)

            self._expand(pos)
    else:
        _lists.append([value])
        _maxes.append(value)

    self._len += 1
```

- 首先当块链为空时，直接在末尾加入即可。
- 否则我们二分找到 `val` 所属块。这里 `bisect_right` 的行为类似于 `std::upper_bound`，返回下标。
  - 若 `val` 无后继，说明它直接放到最后一个块的末尾即可，同时更新块内最值。
  - 否则，在块内插入 `val`，并且维护块链性质。

写出 C++ 版代码：

```cpp
void add(const T& val) {
    if (!maxes.empty()) {
        int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
        if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
        else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
        expand(pos);
    } else {
        lists.emplace_back(1, val), maxes.emplace_back(val);
    } len++;
}
```

### expand 操作

```python
def _expand(self, pos):
    _load = self._load
    _lists = self._lists
    _index = self._index

    if len(_lists[pos]) > (_load << 1):
        _maxes = self._maxes

        _lists_pos = _lists[pos]
        half = _lists_pos[_load:]
        del _lists_pos[_load:]
        _maxes[pos] = _lists_pos[-1]

        _lists.insert(pos + 1, half)
        _maxes.insert(pos + 1, half[-1])

        del _index[:]
    else:
        if _index:
            child = self._offset + pos
            while child:
                _index[child] += 1
                child = (child - 1) >> 1
            _index[0] += 1
```

这个函数有两条逻辑。首先当块长大于二倍 `load` 时，执行分裂操作，把这块从中间分成两块，然后清空索引树（这里一定要清空，本蒟蒻被这个卡了 4h）。不分裂且建好索引树时，我们把这个块到根节点链上的值都加一。C++ 版如下：

```cpp
void expand(int pos) {
    if ((int) lists[pos].size() > (load << 1)) {
        std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
        lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
        maxes[pos] = lists[pos].back();
        lists.insert(lists.begin() + pos + 1, half);
        maxes.insert(maxes.begin() + pos + 1, half.back());
        index.clear();
    } else if (!index.empty()) {
        for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]++;
        index[0]++;
    }
}
```

## 删除

找到 `discard` 函数：

```python
def discard(self, value):
    _maxes = self._maxes

    if not _maxes:
        return

    pos = bisect_left(_maxes, value)

    if pos == len(_maxes):
        return

    _lists = self._lists
    idx = bisect_left(_lists[pos], value)

    if _lists[pos][idx] == value:
        self._delete(pos, idx)
```

在二分找到 `value` 后调用了 `_delete` 函数，找到它：

```python
def _delete(self, pos, idx):
    _lists = self._lists
    _maxes = self._maxes
    _index = self._index

    _lists_pos = _lists[pos]

    del _lists_pos[idx]
    self._len -= 1

    len_lists_pos = len(_lists_pos)

    if len_lists_pos > (self._load >> 1):
        _maxes[pos] = _lists_pos[-1]

        if _index:
            child = self._offset + pos
            while child > 0:
                _index[child] -= 1
                child = (child - 1) >> 1
                _index[0] -= 1
     elif len(_lists) > 1:
        if not pos:
            pos += 1

        prev = pos - 1
        _lists[prev].extend(_lists[pos])
        _maxes[prev] = _lists[prev][-1]

        del _lists[pos]
        del _maxes[pos]
        del _index[:]

        self._expand(prev)
    elif len_lists_pos:
        _maxes[pos] = _lists_pos[-1]
    else:
        del _lists[pos]
        del _maxes[pos]
        del _index[:]
```

一个大分讨的结构：

- 若块长大于一半的 `load`，更新块内的最大值，然后把在索引树上把该块到根节点的路径值减一；
- 否则，若块数大于 $1$，将该块合并到上一块，若当前块为第一块就合并到下一块。由于这样完了也会导致块长大于二倍 `load`，执行 `expand` 操作；
- 否则，若删除此元素后列表不为空，直接维护块内最大值；
- 否则，清空列表。

C++ 实现：

```cpp
bool erase(const T& val) {
    if (maxes.empty()) return false;
    int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    if (pos == (int) maxes.size()) return false;
    int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
    if (lists[pos][idx] != val) return false;

    lists[pos].erase(lists[pos].begin() + idx), len--;
    int n = lists[pos].size();
    if (n > (load >> 1)) {
        maxes[pos] = lists[pos].back();
        if (!index.empty()) {
            for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]--;
            index[0]--;
        }
    } else if (lists.size() > 1) {
        if (!pos) pos++;
        int pre = pos - 1;
        lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
        maxes[pre] = lists[pre].back();
        lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
        index.clear(), expand(pre);
    } else if (n > 0) {
        maxes[pos] = lists[pos].back();
    } else {
        lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
        index.clear();
    } return true;
}
```

## 查询第 kkk 小

kth 操作在 Python 里是重载的 `[]` 运算符，找到 `__getitem__` 函数：

```python
def __getitem__(self, index):
    _lists = self._lists

    if isinstance(index, slice):
        start, stop, step = index.indices(self._len)

        if step == 1 and start < stop:
            # Whole slice optimization: start to stop slices the whole
            # sorted list.

            if start == 0 and stop == self._len:
                return reduce(iadd, self._lists, [])

            start_pos, start_idx = self._pos(start)
            start_list = _lists[start_pos]
            stop_idx = start_idx + stop - start

            # Small slice optimization: start index and stop index are
            # within the start list.

            if len(start_list) >= stop_idx:
                return start_list[start_idx:stop_idx]

            if stop == self._len:
                stop_pos = len(_lists) - 1
                stop_idx = len(_lists[stop_pos])
            else:
                stop_pos, stop_idx = self._pos(stop)

            prefix = _lists[start_pos][start_idx:]
            middle = _lists[(start_pos + 1):stop_pos]
            result = reduce(iadd, middle, prefix)
            result += _lists[stop_pos][:stop_idx]

            return result

        if step == -1 and start > stop:
            result = self._getitem(slice(stop + 1, start + 1))
            result.reverse()
            return result

        # Return a list because a negative step could
        # reverse the order of the items and this could
        # be the desired behavior.

        indices = range(start, stop, step)
        return list(self._getitem(index) for index in indices)
    else:
        if self._len:
            if index == 0:
                return _lists[0][0]
            elif index == -1:
                return _lists[-1][-1]
        else:
            raise IndexError('list index out of range')

        if 0 <= index < len(_lists[0]):
            return _lists[0][index]

        len_last = len(_lists[-1])

        if -len_last < index < 0:
            return _lists[-1][len_last + index]

        pos, idx = self._pos(index)
        return _lists[pos][idx]
```

前面那一大坨是 Python 的切片索引，不用管它。就是用 `pos` 函数找到哪个块和块内索引直接返回即可。C++ 实现：

```cpp
T operator[] (int idx) {
    auto pir = pos(idx);
    return lists[pir.first][pir.second];
}
```

## 查询排名

Python 里有两种排名：`bisect_left` 和 `bisect_right`，对应 C++ 中的 `std::lower_bound` 与 `std::upper_bound`。我们找到这两个东西：

```python
def bisect_left(self, value):
    _maxes = self._maxes

    if not _maxes:
        return 0

    pos = bisect_left(_maxes, value)

    if pos == len(_maxes):
        return self._len

    idx = bisect_left(self._lists[pos], value)
    return self._loc(pos, idx)

def bisect_right(self, value):
    _maxes = self._maxes

    if not _maxes:
        return 0

    pos = bisect_right(_maxes, value)

    if pos == len(_maxes):
        return self._len

    idx = bisect_right(self._lists[pos], value)
    return self._loc(pos, idx)
```

用对应的二分函数找到哪个块和它在块内的位置，用 `loc` 函数转换。C++ 实现：

```cpp
int lower_bound(const T& val) {
    if (maxes.empty()) return 0;
    int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    if (pos == (int) maxes.size()) return len;
    return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
}
int upper_bound(const T& val) {
    if (maxes.empty()) return 0;
    int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    if (pos == (int) maxes.size()) return len;
    return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
}
```

基于这个东西，我们可以用 `upper_bound(x) - lower_bound(x)` 来实现计数功能。加点剪枝：

```cpp
int count(const T& val) {
    if (maxes.empty()) return 0;
    int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    if (l == (int) maxes.size()) return 0;
    int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
    if (r == (int) maxes.size()) return len - loc(l, x);
    int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
    if (l == r) return y - x;
    return loc(r, y) - loc(l, x);
}
bool contains(const T& val) {
    if (maxes.empty()) return false;
    int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
    if (pos == (int) maxes.size()) return false;
    int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
    return lists[pos][idx] == val;
}
```

这样我们就实现了一个功能比较完整的有序列表了。

## 复杂度分析

首先设我们分成了 $b$ 块。

在修改时，分裂合并由均摊分析可得，总复杂度不超过 $O(n)$。而更新索引树是 $O(\log b)$ 的。瓶颈在插入删除为 $O(b)$。但是众所周知 `std::vector` 的插入删除常数很小，在 $10^6$ 数据下约是 $\dfrac{1}{500}$ 级别，因此我们可以认为 $O(b)$ 跑的比 $O(\log b)$ 还快，这样复杂度就是 $O(\log n)$ 了。Sorted Containers 文档里也是这么写的：

```python
"""
Runtime complexity: `O(log(n))` -- approximate.
"""
```

对于查询操作，二分显然是 $O(\log b)$ 的，而 `pos` 和 `loc` 都在 $O(\log b)$ 层的索引树上操作，复杂度也是 $O(\log n)$。由均摊分析，建立索引树的次数不超过 $O(b)$ 次。

因此，你可以认为索引树优化块状链表的整体复杂度为 $O(\log n)$。

不知道这个东西能不能可持久化。

## 模板

这是一份完整的 `sorted_vector` 模板：

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 340;
	int len, load, offset;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;

	void expand(int pos) {
		if ((int) lists[pos].size() > (load << 1)) {
			std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
			lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
			maxes[pos] = lists[pos].back();
			lists.insert(lists.begin() + pos + 1, half);
			maxes.insert(maxes.begin() + pos + 1, half.back());
			index.clear();
		} else if (!index.empty()) {
			for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]++;
			index[0]++;
		}
	}

	std::vector<int> parent(const std::vector<int>& a) {
		int n = a.size();
		std::vector<int> res(n >> 1);
		for (int i = 0; i < (n >> 1); i++) res[i] = a[i << 1] + a[i << 1 | 1];
		return res;
	}
	void build_index() {
		std::vector<int> row0;
		for (const auto& v : lists) row0.emplace_back(v.size());
		if (row0.size() == 1) return index = row0, offset = 0, void();
		std::vector<int> row1 = parent(row0);
		if (row0.size() & 1) row1.emplace_back(row0.back());
		if (row1.size() == 1) {
			index.emplace_back(row1[0]);
			for (int i : row0) index.emplace_back(i);
			return offset = 1, void();
		}
		int dep = 1 << (std::__lg(row1.size() - 1) + 1), u = row1.size();
		for (int i = 1; i <= dep - u; i++) row1.emplace_back(0);
		std::vector<std::vector<int>> tree = {row0, row1};
		while (tree.back().size() > 1) tree.emplace_back(parent(tree.back()));
		for (int i = tree.size() - 1; i >= 0; i--) index.insert(index.end(), tree[i].begin(), tree[i].end());
		offset = (dep << 1) - 1;
	}

	std::pair<int, int> pos(int idx) {
		if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
		if (index.empty()) build_index();
		int p = 0, n = index.size();
		for (int i = 1; i < n; i = p << 1 | 1) {
			if (idx < index[i]) p = i;
			else idx -= index[i], p = i + 1;
		} return std::make_pair(p - offset, idx);
	}

	int loc(int pos, int idx) {
		if (pos == 0) return idx;
		if (index.empty()) build_index();
		int tot = 0;
		for (pos += offset; pos; pos = (pos - 1) >> 1) {
			if (!(pos & 1)) tot += index[pos - 1];
		} return tot + idx;
	}
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR), offset(0) {}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}

	void clear() {
		len = 0, offset = 0;
		lists.clear(), maxes.clear(), index.clear();
	}

	void add(const T& val) {
		if (!maxes.empty()) {
			int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
			if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
			else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
			expand(pos);
		} else {
			lists.emplace_back(1, val), maxes.emplace_back(val);
		} len++;
	}

	bool erase(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		if (lists[pos][idx] != val) return false;

		lists[pos].erase(lists[pos].begin() + idx), len--;
		int n = lists[pos].size();
		if (n > (load >> 1)) {
			maxes[pos] = lists[pos].back();
			if (!index.empty()) {
				for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]--;
				index[0]--;
			}
		} else if (lists.size() > 1) {
			if (!pos) pos++;
			int pre = pos - 1;
			lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
			maxes[pre] = lists[pre].back();
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear(), expand(pre);
		} else if (n > 0) {
			maxes[pos] = lists[pos].back();
		} else {
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear();
		} return true;
	}

	T operator[] (int idx) {
		auto pir = pos(idx);
		return lists[pir.first][pir.second];
	}

	int lower_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int upper_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int count(const T& val) {
		if (maxes.empty()) return 0;
		int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (l == (int) maxes.size()) return 0;
		int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
		if (r == (int) maxes.size()) return len - loc(l, x);
		int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
		if (l == r) return y - x;
		return loc(r, y) - loc(l, x);
	}
	bool contains(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		return lists[pos][idx] == val;
	}
};
```

如果要自定义比较顺序，需要重载运算符。

## 应用

理论上这种优化方法适用于所有块状链表。所以这里放几个块链题：

- [P4008 [NOI2003] 文本编辑器](https://www.luogu.com.cn/problem/P4008)
- [P2042 [NOI2005] 维护数列](https://www.luogu.com.cn/problem/P2042)
- [P3391 【模板】文艺平衡树](https://www.luogu.com.cn/problem/P3391)
- [P2596 [ZJOI2006] 书架](https://www.luogu.com.cn/problem/P2596)$AKB147$, '数据结构', array['块状链表', '索引树', '分块', '平衡树'], 'col-hub-ds-block', null, 'knowledge'),
('Xesir', 'col-ds-linked-list--xesir', '链表（数组模拟双链表） · Xesir', $AKB148$## 算法原理

链表是一种用「指针」把元素串起来的数据结构，像链条一样一节扣一节。它的特点是**插入和删除特别方便，但查找和随机读取很吃亏**。

- **单向链表**：每个结点有**数据域**（存值）和**指针域**（指向下一个结点）。
- **双向链表**：指针域有左右（上一个 / 下一个）之分，能把前驱、自身、后继串起来。

在 OI 里我们很少真的 `new` 结点，而是用**数组模拟**：用 `e[i]` 存第 $i$ 个结点的值，`ne[i]` 存后继下标，`pr[i]` 存前驱下标，靠「下标当指针」来串链。这样做内存连续、常数小、不用管释放。

## 数据结构图示

数组模拟的双链表，每个位置存三样东西：

```text
索引 i :   0      1      2      3   ...
e[i]   :   -     val1   val2   val3
ne[i]  :   1      2      3      ...
pr[i]  :   -      0      1      2
```

其中 $0$ 号当作**左哨兵（头结点）**，$1$ 号当作**右哨兵（尾结点）**，真正的元素从 $2$ 号往后放，`idx` 指向下一个可用的空位。操作时只改这几个下标，不搬动任何元素。

## 逐行代码解析

下面是数组模拟双链表的完整模板，按模块拆开讲。

### 全局数组与索引

```cpp
int idx=2;int e[1000010],ne[1000010],pr[1000010];
```

- `e` 存值，`ne` 存后继下标，`pr` 存前驱下标。
- `idx` 从 `2` 开始，把 $0$ 和 $1$ 留给两个**哨兵**，省得每次特判空表。
- 数组开到 $10^6$ 量级，够大多数题目用。

### 插入：add

```cpp
void add(int k,int x){
    e[idx]=x;ne[idx]=ne[k];pr[ne[k]]=idx;ne[k]=idx;pr[idx]=k;idx++;
}
```

- 作用：把值为 `x` 的新结点插到下标 `k` **后面**。
- 先给新结点填值 `e[idx]=x`，再把它的后继接成原来的 `ne[k]`，同时把原来的后继的前驱改成新结点。
- 最后让 `k` 的后继指向新结点、新结点的前驱指向 `k`，并让 `idx` 前移一格。
- 这四个指针更新是「先接后断」，顺序不能乱，否则会丢失结点。

### 删除：del

```cpp
void del(int k){
    ne[pr[k]]=ne[k];
    pr[ne[k]]=pr[k];
}
```

- 作用：删除下标 `k` 这个结点。
- 让 `k` 前驱的后继直接跳过 `k`，指向 `k` 的后继；再让 `k` 后继的前驱指回 `k` 的前驱。
- 删掉的结点不回收，下标也就废了——数组模拟链表一般不复用下标。

### 主函数：操作分发

```cpp
int main(){
    ne[0] = 1;pr[1] = 0;
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        int k,x;string c;
        cin>>c;
        if(c=="L"){
            cin>>x;
            add(0,x);
        }
        else if(c=="R"){
            cin>>x;
            add(pr[1],x);
        }
        else if(c=="D"){
            cin>>k;
            del(k+1);
        }
        else if(c=="IL"){
            cin>>k>>x;
            add(pr[k+1],x);
        }
        else if(c=="IR"){
            cin>>k>>x;
            add(k+1,x);
        }
    }
    for(int i=ne[0];i!=1;i=ne[i]){
        cout<<e[i]<<" ";
    }
    return 0;
}
```

- 初始化：`ne[0] = 1; pr[1] = 0;` 把头尾两个哨兵互连，构成一条空链。
- 五种操作映射：`L` 在左哨兵后插入（最左）；`R` 在尾哨兵的前驱 `pr[1]` 后插入（最右）。
- `k` 是「第 k 个插入的数」，因为哨兵占了 $0,1$、元素从 $2$ 开始，所以实际下标是 `k+1`：`D` 删 `k+1`；`IL` 在 `k+1` 的**前驱**后插入（等价于插到它左边）；`IR` 在 `k+1` 后插入。
- 遍历输出：从 `ne[0]` 开始，遇到右哨兵 `1` 停，沿着 `ne` 一路走，天然就是从左到右的顺序。

## 复杂度分析

- 已定位到结点时，插入 / 删除只改常数个下标，时间 $O(1)$。
- 「第 k 个插入的数」由下标 `k+1` 直接映射，定位也是 $O(1)$，无需从链头遍历。
- 遍历整条链输出是 $O(n)$。
- 空间 $O(n)$，即三个长度 $n$ 的数组。

## 适用场景

- 需要**频繁在中间插入 / 删除**，且元素位置能通过下标随时定位（如本题的「第 k 个插入的数」）。
- 双向链表是很多高级结构的底座：邻接表、**反悔贪心的互斥选择**（选点后悔）、LRU 缓存、链表上的模拟。
- 当元素数量大、又不想承受指针 `new/delete` 的开销时，数组模拟是首选。

## 常见陷阱与注意事项

1. **指针更新顺序**：`add` 里必须先接好新结点的后继、再改原后继的前驱，最后改前驱 / 自身的指针；顺序颠倒会丢结点。
2. **哨兵与下标偏移**：哨兵占了 $0,1$，元素从 $2$ 号开始，`k` 与真实下标差 $1$，删 / 插时别忘 `k+1`。
3. **空表判断**：有了双哨兵，遍历条件写成 `i != 1`（遇到右哨兵停），不要再写 `i != 0`。
4. **数组越界**：`idx` 只增不减，删除也不回收，操作次数多时数组要开够。
5. **别用 `vector` 存链表再 `erase`**：`vector::erase` 是 $O(n)$ 搬移，想 $O(1)$ 删除就用数组模拟。

## 对比与扩展

| 维度 | 数组模拟链表 | 指针链表（`new` 结点） |
|---|---|---|
| 内存 | 连续数组，缓存友好 | 结点分散，指针跳转 |
| 分配 / 释放 | 无需，下标自增 | 需要 `new` / `delete` |
| 常数 | 小 | 较大 |
| 删除后复用 | 一般不复用 | 可 `delete` 回收 |
| 适用 | OI 竞赛 | 工程代码 |

扩展方向：**邻接表**（链式前向星）就是数组模拟链表的经典用法；**双向链表 + 堆** 组合出反悔贪心的互斥选择模型；再往上就是 LRU、跳表等工程结构。$AKB148$, '数据结构', array['数据结构', '链表', '双向链表', '数组模拟', '指针'], 'col-ds-other-overview', null, 'knowledge'),
('Fohen', 'col-ds-mo-team--fenfeng', '莫队 · Fohen', $AKB149$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

## 分块的拓展——莫队

当我们要处理非强制在线的问题时，可以尝试使用莫队解决。

先考虑如下例题：

### 例题 $5$：[P1494 [国家集训队] 小 Z 的袜子](https://www.luogu.com.cn/problem/P1494)

>有一个序列，每次询问一个区间 $[l,r]$ 内随机挑出两个位置使得这两个位置的权值相等的概率

（数据保证区间长度、询问次数、值域 $\le 50000$）

发现这个概率其实就是区间 $[l,r]$ 内权值相等的位置的对数再除以总情况数 $\frac{(r-l+1)(r-l)}{2}$，于是只需要回答区间内权值相等的位置的对数就好了。

假设我们现在知道了区间 $[l,r]$ 内这个问题的答案，同时知道了这个区间内每种权值的出现次数（值域较小，用桶维护就好），考虑如何推出区间 $[l,r+1]$ 的答案。假设原序列第 $r+1$ 个位置的值为 $x$，那么把这个数加进来后，答案就会加上 $[l,r]$ 区间内 $x$ 的出现次数，统计完答案后，我们再把这个区间内 $x$ 的出现次数 $+1$。然后，我们就从 $[l,r]$ 区间的信息推到了 $[l,r+1]$ 的信息。如果要从 $[l,r]$ 推到 $[l-1,r]$ 也是同理。

再考虑如何从 $[l,r]$ 推到 $[l,r-1]$。假设序列第 $r$ 个位置的值为 $x$，我们只需要减去 $[l,r-1]$ 内 $x$ 的出现次数就好了。具体来说，我们先让 $x$ 的出现次数 $-1$，然后让答案减去 $x$ 剩余的出现次数。如果要从 $[l,r]$ 推到 $[l+1,r]$ 也是同理。

现在我们将区间的变化分为了 $4$ 种情况。实际上，如果我们已经知道了区间 $[l,r]$ 的信息，想要推到任意一个区间 $[l',r']$ 的信息，将以上四种操作结合起来就好了。不过这样的复杂度肯定是错的，思考如何优化。

我们在进行操作前先将序列分成若干块，设序列长度为 $n$，每块长度为 $B$，则共有 $\lceil \frac{n}{B} \rceil$ 个块。我们将询问离线下来，按照一定的规则排序：第一关键字为左端点所属的块，第二关键字为右端点的位置。这样排完序后，左端点所属的块一样的询问就被放在了一起，考虑对这些左端点所属的块一样的询问进行如上操作的时间复杂度：因为第二关键字为右端点位置，所以这些放在一起的询问的右端点是单调不降的，也就是说只会执行最多 $\operatorname{O}(n)$ 次右端点向右移动一个位置的操作；而两次询问间左端点移动的幅度一定不会超过 $\operatorname{O}(B)$ 次（都在同一个块内，距离不会太远）。因为单次操作的复杂度都是 $\operatorname{O}(1)$ 的，所以对这些操作（假设这些左端点所属块相同的询问有 $m$ 个）的复杂度总和为 $\operatorname{O}(n+mB)$。进一步思考总复杂度，发现当左端点所属块不同时，右端点最多会移动 $\operatorname{O}(n)$ 次，而左端点所属的块最多只会发生 $\operatorname{O}(\lceil \frac{n}{B} \rceil)$ 次。设共有 $q$ 次询问，则总复杂度为 $\operatorname{O}(qB + n \lceil \frac{n}{B} \rceil)$，发现 $B$ 取 $\operatorname{O}(\sqrt{n})$ 时总时间复杂度为 $\operatorname{O}((n+q)\sqrt{n})$，且空间复杂度为值域，可以通过。

以上所讨论的解法就是莫队的思想，这种分块的思想将看似暴力的 “一位位移动区间” 优化到了 $\operatorname{O}(n\sqrt{n})$ 级别的复杂度，也是一种常用的根号算法，适用于离线且 “维护一个区间的信息容易而维护更多情况较为麻烦” 的题目，这时莫队是一种较为简单且正确的解法。接下来，将通过几道例题总结莫队常用的处理技巧。比如带修、回滚等。

### 例题 $6$：[P1903 [国家集训队] 数颜色 / 维护队列](https://www.luogu.com.cn/problem/P1903)

> 有一个长度为 $n$ 的序列，支持两种操作：单点修改和询问区间内有几种不同的数。

（数据保证 $n \le 133333$，操作次数 $\le 133333$，值域 $\le 10^6$） 

带修莫队模板题。

发现值域不是很大，我们依然可以桶来维护一个区间内每个数的出现次数。将一个位置移出/加入当前区间时，修改这个桶，如果一个值的出现次数从 $1$ 修改到 $0$ 就让答案 $-1$，如果一个值的出现次数从 $0$ 修改到 $1$ 就让答案 $+1$。

如果没有修改的话就可以直接用莫队做了，但这道题加上了单点修改。如果没有修改，我们只需考虑左端点的位置和右端点的位置两维，并根据左端点进行分块，将一个块内的统一处理，复杂度就正确了。而现在的问题带上了修改，也就是说不同时间的序列是不同的，于是我们可以把当前操作的时间视作第三维，把每次询问看成一个三元组 $(l,r,t)$，分别代表区间的左右端点和当前询问在操作序列上对应的时间。

我们考虑如何对这个三元组进行一次 “操作”。如果是左右端点进行 $+1$ 或 $-1$，那么其实和二维的情况一样。接下来讨论如何对第三维进行 $+1$ 或 $-1$ 的修改，我们将题目中所有的修改操作也离线下来，如果此次时间 $+1$ 或 $-1$ 后 “跨过” 了某次修改操作，那么需要加上/去掉这次修改造成的影响——如果这次修改的位置在 $[l,r]$ 外，则直接修改序列上这个位置的值，如果在区间 $[l,r]$ 内，则还需考虑桶和答案的变化。

接下来的问题是如何对这些三元组排序使得暴力执行这 $6$ 种操作改变三元组的时间复杂度是正确的。我们还是对序列分块，排序时把区间左端点所属的块当成第一关键字，右端点所属的块当成第二关键字，询问的时间当成第三关键字。

分析这样做的复杂度，设块长为 $B$，块的数量为 $T= \lceil \frac{n}{B} \rceil$，询问次数为 $q$。假设连续几次操作的前两个关键字都一样（左端点和右端点都属于同样的两个块里），那么这些操作的时间是递增的，而左右端点每次最多操作 $\operatorname{O}(B)$ 次，设总共有 $m$ 次这样的询问，则复杂度为 $\operatorname{O}(mB + q)$。再考虑排序后当前这个询问的三元组和上个三元组的左端点所属块一样，而右端点所属块不同且递增，所以对于每一个确定的左端点所属块像这种直接大幅操作右端点（让右端点去到更右边的块里）的次数最多为 $T$ 次，而这些操作加起来右端点会移动 $\operatorname{O}(n)$ 次，且每次都要把第三维移回来，这一部分加起来是 $\operatorname{O}(Tn)$，所以这部分（在左端点所属块确定的情况下右端点所属块改变）时间复杂度的总和为 $\operatorname{O}(Tn)$。最后考虑改变左端点所属块的情况，每一次都会让第二维和第三维移回来，这部分加起来是 $\operatorname{O}(Tn)$ 的，且每次都会让右端点重新开始一次刚刚提到的过程，也就是 $\operatorname{O}(T^2n)$ 的。最后加起来，大概是 $\operatorname{O}(T^2n + qB)$，尽量平衡两部分，发现块长 $B$ 取 $\operatorname{O}(n^{\frac{2}{3}})$ 时最优，复杂度为 $\operatorname{O}((n+q)n^{\frac{2}{3}})$，实际上肯定跑不满，可以通过。

其实处理带修莫队的方法非常简单暴力——两维不够就再加一维，但复杂度又非常巧妙地正确了。但有时并不是所有的信息都能直接用较低的复杂度进行对加入/删除的维护，为了解决这种问题，回滚莫队出现了。详见这题：

### 例题 $7$：[P5906 【模板】回滚莫队&不删除莫队](https://www.luogu.com.cn/problem/P5906)

>给你一个长度为 $n$ 的序列，支持询问一个区间内两个相同元素之间距离的最大值。

（数据保证 $n \le 2 \times 10^5$，询问次数 $\le 2 \times 10^5$）

发现这道题需要我们维护的是一个较为复杂的信息，考虑用莫队进行维护。既然要用莫队，必然要考虑向区间中加入一个位置和删除一个位置。首先题目需要维护的东西只和两个值是否相等有关系，所以可以离散化，于是值域变为了 $2 \times 10^5$，可以对一个区间用两个桶维护一个元素出现的最早的位置和最晚的位置。

考虑如何将 $[l,r]$ 的信息推到 $[l,r+1]$ 去。其实很简单，设序列上第 $r + 1$ 个位置的值离散化后为 $x$，直接让 $x$ 最晚出现的位置等于 $r+1$，如果 $x$ 之前没有出现过，就让最早出现的位置也等于 $r+1$ 就好了，答案就是原来的答案与 $x$ 最早出现的位置与 $r + 1$ 的差值的最大值。同样的，也能用类似的方法把 $[l,r]$ 区间的信息推到 $[l-1,r]$。

那么如何删掉一个位置的影响呢？好像在目前的基础上很难维护——如果删掉一个区间最右边的位置，那这个值最后一次出现的位置将变为原来这个值倒数第二次出现的位置，可倒数第二或者继续往前的位置我们并未全部维护，直接这样做是不行的。

似乎卡住了？总结一下刚刚的想法，这个问题如果满足区间只会加入一个数的话将会很好做，但根据我们原来的莫队做法这是不可能的。我们希望有一种数据结构，既能实现莫队的功能，而且满足只会添加一个位置，同时复杂度也是正确的，这就是回滚莫队的功能。

还是将询问都离线下来，以左端点所属的块为第一关键字、右端点的位置为第二关键字排序，这样左端点所属块一样的询问会被放到一起，我们把这些左端点所属块一样的询问划分为一组。我们考虑如何处理这一组内的所有询问，因为一组内的右端点总是单调不降的，所以不会删掉一个位置，直接维护就好。

那左端点呢？我们发现一组内所有询问的左端点都在同一个块中，和这个块的右端点的距离也只有 $\operatorname{O}(B)$（$B$ 为块长），所以可以每次都从这个块的右端点一个一个添加位置直到这次询问的左端点。设这一组的左端点所属的块的右端点为 $L$，那我们就要维护 $[L,r']$ 区间内的答案（$r'$ 表示当前这一组执行过的上一次询问的右端点），对一个新的询问 $[l,r]$，因为排过序，所以一定有 $r' \le r$，且分块的性质保证了 $l \le L$，所以可以只用添加就求出 $[l,r]$ 区间的答案，注意向左添加位置时，因为添加的位置我们不能保存下来（否则可能会使下次询问时必须删除某个位置的影响），所以要单开一个桶记录一些信息，并在回答询问后清空这个桶，重新维护 $[L,r]$ 的信息，以便于回答下一个询问。对于每一组我们都会重构——重新记录左端点为 $L'$ 的区间的答案。

这样的话，对于每一个组，我们可以进行重构，对于一个询问，我们可以只用添加位置就求出答案，总复杂度在块长为 $\sqrt{n}$ 时最优，达到 $\operatorname{O}((n+q)\sqrt{n})$。具体证明就不写了，和例题 $5$ 差不多（好像算法各流程的复杂度都是差不多的，但回滚莫队把复杂度跑得很满，常数大很多）。

### 一些关于定块长的技巧

考虑最普通的分块算法，设我们对原序列分块时的块长为 $B$，序列长度为 $n$，询问次数为 $q$，那么复杂度为 $\operatorname{O}(n \lceil \frac{n}{B} \rceil + qB)$，在 $n$ 与 $q$ 接近时直接将块长定位 $\operatorname{O}(\sqrt{n})$ 级别就是最优的。但如果 $n$ 和 $q$ 差距较大呢？这种情况下可以考虑平衡两部分的复杂度，从而达到最优，简单来说就是让 $n \lceil \frac{n}{B} \rceil = qB$。简单解一下，发现 $B$ 取 $\operatorname{O}(\frac{n}{\sqrt{q}})$ 级别时最优。

以上就是关于莫队的一些常用思想和技巧。其实，还有很多拓展（比如树上莫队，或者维护一个区间的信息时使用更多较为复杂的方法），但本质上都是一样的——本质是暴力添加/删除，但是通过固定一个端点的范围来限制复杂度。$AKB149$, '数据结构', array['莫队', '回滚莫队', '带修莫队', '分块'], null, null, 'knowledge'),
('Xesir', 'col-ds-mo-team--xesir', '莫队（普通莫队 / 带修莫队） · Xesir', $AKB150$## 算法原理

莫队，是国家集训队队长莫涛发明的一种解决区间查询等问题的算法，一般需要离线操作。其基于双指针思想，通过分块维护区间查询，并动态转移。

假设可以在 $O(k)$ 复杂度内从 $[l,r]$ 转移到相邻区间，分块可以实现 $O(n\sqrt q)$ 的复杂度，即根号复杂度。实际情况中 $O(k)$ 一般为 $O(1)$ 或 $O(\log n)$。

### 普通莫队

考虑我们可以用较小的复杂度从一个区间 $[l_i,r_i]$ 转移到下一个区间 $[l_j,r_j]$，每次转移复杂度是 $O(|l_i-l_j|+|r_i-r_j|)$。

想法很不错，但这极度依赖数据性质。如果数据的查询区间是「左右横跳」的，相邻查询跨度极大，此时这种转移是 $O(n^2)$ 的，与暴力无异，直接喜提 TLE。莫队的思想就是优化处理查询的顺序，使其跳转次数尽可能少。

很容易想到的一种优化是以 $l$ 为第一关键词、$r$ 为第二关键词分别升序排序。显而易见，这种贪心也是可以构造数据卡掉的，直接拉完了。

然而加上分块之后，这个问题立刻迎刃而解。将每个元素分块后，设第 $i$ 个元素所在的块编号 $b_i$，按照 $b_l$ 为第一关键词、$b_r$ 为第二关键词分别升序排序。

对于 $l$，每次跳跃距离不会超过块长 $B$；对于 $r$，每个块区间总移动距离不会超过 $n$。由此可得总跳跃复杂度为 $O\left(qB+\dfrac{n^2}{B}\right)$，$B$ 取 $\sqrt{\dfrac{n^2}{q}}$ 时取得最小复杂度，即均摊 $O(n\sqrt q)$。这个根号复杂度显然是很优的，且不会退化，可以通过 $10^5$ 数据。

观察到每次转移块时，$r$ 都要经过一段很长的位移，其中大部分位移是不必要的。于是我们可以使用**奇偶化排序**，这是一个常数优化：当 $l$ 相等时，若 $b_l$ 为奇数则按 $b_r$ 升序排序，否则按降序排序。这样在 $r$ 回滚时可以顺带计算出路径上的答案，可以将时间优化一倍。

莫队需要实现两个核心函数：$add(p)$ 与 $del(p)$，分别表示将当前区间纳入或移出区间，并维护代价。这两个函数的内部逻辑因题而异。

### 带修莫队

注：带修莫队能维护的修改操作必须满足可撤销性，且添加和撤销都是 $O(1)$，否则不能直接用带修莫队维护。

刚才的莫队很好地维护了静态区间查询，但是如果区间是动态的呢？如 P1903 添加了修改操作，这一操作无疑会对答案产生影响，普通莫队不再可做。这时候，我们要考虑维护修改。

注意到每个询问是基于当前进行过的修改来统计答案，若我们想离线询问，则必须将修改也离线。这样每个查询可以对应一个三元组 $(l,r,t)$，其中新增的 $t$ 是时间轴，便于确定当前查询在哪些修改之后。这时候我们在普通莫队基础上把 $t$ 作为第三关键字排序。

排完之后，$t$ 就可以完全当做等同于 $l,r$ 的第三维来被莫队维护，每次移动时间轴时添加与撤销修改即可。

## 逐行代码解析

原文只给了几个关键片段，完整程序需要自己补上 `add` / `del` 以及读入。

### 模块一：双指针转移主循环

```cpp
	for(int i=1;i<=m;i++){
	    while(L>q[i].l)Add(--L);
	    while(R<q[i].r)Add(++R);
	    while(L<q[i].l)Del(L++);
	    while(R>q[i].r)Del(R--);
	    ans[q[i].id]=nowAns;
	    //nowAns 表示“当前答案”
	    //是 Add 和 Del 函数的重点维护对象
	}
```

四个 `while` 分别负责左端点左扩、右端点右扩、左端点右缩、右端点左缩。扩张时先动指针再 `Add`（`--L` / `++R`），收缩时先 `Del` 掉当前元素再动指针（`L++` / `R--`），顺序反了会把不该删的元素删掉。询问按排序后的顺序处理，答案通过 `q[i].id` 放回原位置。

### 模块二：带修莫队的三关键字排序

```cpp
bool cmp(query a,query b){
	if(a.l/B==b.l/B){
		if(a.r/B==b.r/B){
			if((a.r/B)&1) return a.t<b.t;
			else return a.t>b.t;
		}else{
			if((a.l/B)&1) return a.r<b.r;
			else return a.r>b.r;
		}
	}else return a.l<b.l;
}
```

第一关键字是 $l$ 所在块，第二关键字是 $r$ 所在块，第三关键字才是时间 $t$；每一层都带奇偶化，让指针回滚时能顺路处理。

### 模块三：时间轴的添加与撤销

```cpp
		while(T<cnt[i].t){
			int p=xg[++T].fi;
			if(L<=p&&p<=R){
				del(a[p]);add(xg[T].se);
			}
			swap(a[p],xg[T].se);
		}
```

`xg` 存修改操作 `(位置, 新值)`。若修改位置落在当前区间内，先删旧值再加新值；无论是否在区间内，都要 `swap` 把原值换回 `xg`，这样时间轴回退时再 `swap` 一次就能撤销——这正是要求修改可撤销且 $O(1)$ 的原因。

### 模块四：把操作离线成询问和修改

```cpp
		if(ch=='Q'){
			b.id=++mq;b.t=mr;
			cnt.pb(b);
		}else xg[++mr]={b.l,b.r};
```

读入时用 `mr` 记录当前已经发生了多少次修改，询问的 `t` 就取这个值，表示它只受前 `mr` 次修改影响。

## 复杂度分析

- 普通莫队：总跳跃复杂度 $O\left(qB+\dfrac{n^2}{B}\right)$，$B=\sqrt{\dfrac{n^2}{q}}$ 时约 $O(n\sqrt q)$；单次转移代价为 $O(k)$，若 `add` / `del` 是 $O(1)$，整体就是 $O(n\sqrt q)$。
- 带修莫队：一般块长取 $B=O(n^{2/3})$，这是在 $n$ 与 $q$ 同阶下的最优选择，此时复杂度约 $O(n^{5/3})$。
- 空间：存询问、修改、答案数组，$O(n+q)$。

## 适用场景

- 询问可离线，且区间信息能在 $O(1)$ 或 $O(\log n)$ 内从相邻区间转移过来。
- 普通莫队：静态区间计数、区间众数、区间不同数个数等。
- 带修莫队：在普通莫队基础上加入单点修改，且修改可 $O(1)$ 撤销。
- 回滚莫队：原文这一节只留了名字（~~滚木~~），没有展开。

## 常见陷阱与注意事项

- `add` / `del` 的指针移动顺序必须与「先扩张后收缩」的写法配套，`Del(L++)` 和 `Del(R--)` 传进去的是被删元素。
- 左右端点初始值通常是 `L=1, R=0`（空区间），不要一上来就 `R=1` 把第一个元素算重。
- 带修莫队必须先保证修改可撤销；不可撤销的赋值类修改要另想办法。
- 时间轴前进/回退都要 `swap`，只前进不交换会让后续撤销拿到错误的值。
- 奇偶化排序只是常数优化，写错方向不会影响正确性，但会显著变慢。
- 块长不是固定的 $\sqrt n$：普通莫队取 $\sqrt{n^2/q}$，带修莫队取 $n^{2/3}$。$AKB150$, '数据结构', array['数据结构', '莫队', '分块', '双指针', '离线', '带修莫队'], null, null, 'knowledge'),
('Fohen', 'col-ds-mo-team-modify--fenfeng', '带修莫队 · Fohen', $AKB151$## 算法原理

带修莫队（Mo's Algorithm with Updates）是普通莫队的扩展，用于处理**带修改的区间查询**。普通莫队只能离线回答静态数组上的区间查询；一旦允许在询问之间穿插修改（例如单点改值），修改会改变数组本身，先前按静态数组排好的询问顺序所依赖的数组状态便不再成立，普通莫队随之失效。

带修莫队的核心思想是**给每个询问增加一维“时间”**。把所有修改也当作事件离线下来，并按发生顺序编号；一个询问之前已经执行了多少条修改，就是它的时间戳 $t$。于是每个询问由二元组 $(l, r)$ 扩展为三元组 $(l, r, t)$，含义是“在第 $t$ 条修改执行完毕后，区间 $[l, r]$ 上的答案”。

排序时把 $t$ 当作与 $l$、$r$ 并列的第三关键字：先按 $l$ 所在块号、再按 $r$ 所在块号、最后按 $t$ 排序（配合奇偶优化）。这样相邻询问在三个维度上都尽量接近，三个指针的整体移动次数被均摊到可接受的量级。

处理时维护三个指针 $L$、$R$、$T$，分别表示当前区间左端点、右端点与当前时间（已应用的修改条数）。移动 $L$、$R$ 与普通莫队一致；移动 $T$ 时，对每一条被应用或撤销的修改执行相应操作。关键前提是**每条修改必须可撤销，且应用与撤销都是 $O(1)$**，否则无法直接用带修莫队维护。为此常用 `swap` 技巧，使修改天然可逆（见「逐行代码解析」）。

## 核心公式 / 状态定义与转移方程

**状态定义**：三元组 $(l, r, t)$，表示当前已维护区间 $[l, r]$，且已应用前 $t$ 条修改。记该状态下的答案为 $\text{ans}$。

**转移**（从当前状态移动到目标询问 $(l', r', t')$）：

- 扩展区间：$l \leftarrow l-1$（加入 $a_l$）、$r \leftarrow r+1$（加入 $a_r$）；
- 收缩区间：$l \leftarrow l+1$（删除 $a_l$）、$r \leftarrow r-1$（删除 $a_r$）；
- 时间前进：$t \leftarrow t+1$，应用第 $t$ 条修改；
- 时间后退：$t \leftarrow t-1$，撤销第 $t$ 条修改。

设第 $t$ 条修改为 $(p_t, v_t)$，含义是把 $a_{p_t}$ 改为 $v_t$。利用 `swap` 技巧，应用与撤销统一为同一操作：

$$\text{swap}\bigl(a_{p_t},\ v_t\bigr)$$

执行前 $v_t$ 存“要写入的新值”，执行后 $a_{p_t}$ 变为新值、$v_t$ 保存旧值；再执行一次即可无损撤销。若修改位置 $p_t\in[l,r]$，还需同步更新答案：先删去旧值的贡献，再加入新值的贡献。

**分块参数**：块长取 $B=n^{2/3}$。此时三个指针的总移动量

$$O\left(qB+\frac{n^2}{B}+q\frac{n^2}{B^2}\right)$$

在 $q$ 与 $n$ 同阶时三项平衡，总复杂度为 $O(n^{5/3})$。

## 逐行代码解析

以下为资料中的核心代码片段（未构成完整可运行程序，故以伪代码形式呈现）。其中 `B` 为块长，`cnt` 为询问数组（命名易与计数数组混淆），`xg` 为修改数组（`fi` 存位置、`se` 存新值），`L`、`R`、`T` 分别为左右端点与时间指针。

### 三关键字排序比较器

```cpp
bool cmp(query a, query b) {
    if (a.l / B == b.l / B) {                     // l 在同一块
        if (a.r / B == b.r / B) {                 // r 也在同一块
            if ((a.r / B) & 1) return a.t < b.t;  // 奇数 r 块: t 升序
            else return a.t > b.t;                // 偶数 r 块: t 降序
        } else {
            if ((a.l / B) & 1) return a.r < b.r;  // 奇数 l 块: r 升序
            else return a.r > b.r;                // 偶数 l 块: r 降序
        }
    } else return a.l < b.l;                      // l 不同块: 按块号升序
}
```

- 三个关键字依次是 $l$ 块号、$r$ 块号、$t$，让相邻询问在三个维度上都尽量接近。
- 奇偶优化：相邻块的 $r$（或 $t$）排序方向相反，减少指针跨块时的折返移动。
- `& 1` 用于判断块号奇偶；注意 $t$ 的排序方向取决于 **$r$ 块号**的奇偶，而不是 $l$ 块号。

### 读入与离线化

```cpp
for (int i = 1; i <= n; i++) cin >> a[i];        // 读入初始数组
for (int i = 1; i <= m; i++) {
    query b; char ch;
    cin >> ch >> b.l >> b.r;
    if (ch == 'Q') {                             // 询问: 记录之前已有的修改数 t
        b.id = ++mq; b.t = mr;
        cnt.pb(b);
    } else xg[++mr] = {b.l, b.r};                // 修改: 记入修改数组
}
sort(cnt.begin(), cnt.end(), cmp);               // 三关键字排序
```

- 用字符 `ch` 区分询问（`Q`）与修改；询问与修改统一离线读入。
- 询问的 $t$ 记录的是它**之前已经出现的修改条数** `mr`，而不是询问编号。
- 修改记入 `xg` 数组，下标 $1 \dots mr$ 即时间轴；`id` 用于排序后把答案写回原顺序。

### 左右端点的双指针移动

```cpp
while (L > cnt[i].l) add(a[--L]);                // 左指针左移: 加入新位置
while (R < cnt[i].r) add(a[++R]);                // 右指针右移: 加入新位置
while (L < cnt[i].l) del(a[L++]);                // 左指针右移: 删除旧位置
while (R > cnt[i].r) del(a[R--]);                // 右指针左移: 删除旧位置
```

- 与普通莫队一致，先扩展、后收缩，避免出现 $L > R + 1$ 的非法空区间。
- `add` / `del` 是题目相关的增量维护函数，分别处理“加入 / 移除一个元素”对答案的贡献。

### 时间轴的移动（应用 / 撤销修改）

```cpp
while (T < cnt[i].t) {                           // 时间前进: 应用修改
    int p = xg[++T].fi;                          // 第 T 条修改的位置
    if (L <= p && p <= R) { del(a[p]); add(xg[T].se); }  // 位置在区间内才更新答案
    swap(a[p], xg[T].se);                        // 旧值存入 xg[T].se
}
while (T > cnt[i].t) {                           // 时间后退: 撤销修改
    int p = xg[T].fi;
    if (L <= p && p <= R) { del(a[p]); add(xg[T].se); }
    swap(a[p], xg[T--].se);
}
res[cnt[i].id] = ans;                            // 答案写回原询问位置
```

- 只有当被修改的位置 $p$ 落在当前区间 $[L, R]$ 内时，才需要更新答案；否则只需改数组。
- `swap(a[p], xg[T].se)` 是关键：一次交换既写入新值，又把旧值存回 `xg[T].se`，撤销时再交换一次即可还原。
- 前进用 `++T` 先取新时间、后退用 `T--` 先还原当前时间，注意 $T$ 的边界方向不要写反。

## 复杂度分析

设块长为 $B$，数组长度与操作数都与 $n$ 同阶，询问数为 $q$。排序耗时 $O(q\log q)$；三个指针的移动量分三部分计算：

- **左指针 $l$**：同一块内每次移动不超过 $B$，$q$ 个询问总移动量 $O(qB)$。
- **右指针 $r$**：对每个 $l$ 块（共 $n/B$ 个），$r$ 在整个数轴上至多扫过 $n$，总移动量 $O\left(\frac{n}{B}\cdot n\right)=O\left(\frac{n^2}{B}\right)$。
- **时间指针 $t$**：对每个 $l$ 块与 $r$ 块的组合（共 $\left(\frac{n}{B}\right)^2$ 个），$t$ 沿时间轴至多扫过 $q$，总移动量 $O\left(q\cdot\frac{n^2}{B^2}\right)$。

总移动量 $O\left(qB+\frac{n^2}{B}+q\frac{n^2}{B^2}\right)$。当 $q$ 与 $n$ 同阶时，令 $B=n^{2/3}$，三项分别化为 $n^{5/3}$、$n^{4/3}$、$n^{5/3}$，由最大项主导：

$$O\left(n^{5/3}\right)$$

因此带修莫队的时间复杂度为 $O(n^{5/3})$（排序的 $O(q\log q)$ 被其支配）。空间复杂度为 $O(n+q)$：初始数组 $O(n)$，询问数组与修改数组各 $O(q)$。

## 适用场景

带修莫队适用于**离线**、**带修改**的区间查询，且需满足以下前提：

- 所有询问可离线重排（无强制在线要求）；
- 加入 / 删除单个元素、应用 / 撤销单条修改都能在 $O(1)$ 内完成；
- 每条修改可撤销，可用 `swap` 技巧无损还原旧值。

典型应用是带修改的区间颜色统计，如「数颜色」类问题（洛谷 P1903）：支持单点改色与区间不同颜色个数查询。若修改不可撤销、或增删元素代价超过 $O(1)$，则应改用回滚莫队、二次离线莫队或树套树等其它结构。

## 常见陷阱与注意事项

- **修改必须可撤销且 $O(1)$**：这是带修莫队的硬性前提，若某条修改无法在 $O(1)$ 内撤销，就不能直接套用本算法。
- **块长取 $n^{2/3}$ 而非 $\sqrt{n}$**：带修莫队多了时间维，沿用普通莫队的 $\sqrt{n}$ 会让时间指针 $t$ 退化为瓶颈，复杂度达不到最优。
- **`swap` 是撤销的关键**：前进时 `swap(a[p], xg[T].se)` 会把旧值自动存回修改数组；漏掉这步或只做单向赋值，撤销时就无法还原旧值。
- **修改位置落在区间内才更新答案**：只有当 $L \le p \le R$ 时更新答案；即使 $p$ 在区间外，也必须执行 `swap` 以改变数组本身。
- **指针移动顺序**：先扩展后收缩，保证收缩时被删除的元素确实在区间内；时间前进用 `++T`、后退用 `T--`，方向写反会导致状态错乱。
- **询问的时间戳是“之前的修改条数”**：读入时用 `b.t = mr`（当前修改计数），而不是询问编号，二者容易混淆。

## 对比与扩展

- **带修莫队 vs 普通莫队**：普通莫队处理静态区间查询，状态为 $(l, r)$，块长 $\sqrt{n}$，复杂度 $O(n\sqrt{n})$；带修莫队增加时间维，状态为 $(l, r, t)$，块长 $n^{2/3}$，复杂度 $O(n^{5/3})$。带修莫队是普通莫队在时间维上的自然推广。
- **带修莫队 vs 回滚莫队**：两者都面向“带修改”或“难撤销”的区间问题，但思路不同——带修莫队要求修改可撤销，用时间维离线维护；回滚莫队不处理时间维，只做扩展不做收缩、在块间回滚，适合删除操作难以 $O(1)$ 维护的场景（如并查集）。
- **带修莫队 vs 三维莫队**：带修莫队本质上是三维莫队（对 $l$、$r$、$t$ 三维分块）的特例；维度更多时可将分块继续扩展，复杂度中的指数也随之上升。
- **扩展：树上带修莫队**：先用欧拉序把树链问题转化为区间问题，再叠加时间维，即可处理树上路径的带修改查询。
- **扩展：莫队二次离线**：当增量更新需要 $O(\log n)$ 时（如区间逆序对数），二次离线可把复杂度从 $O(n\sqrt{n}\log n)$ 降到 $O(n\sqrt{n}+n\log n)$。$AKB151$, '数据结构', array['数据结构', '莫队', '分块', '离线查询', '区间修改'], 'col-hub-ds-block', null, 'knowledge'),
('world-needs-sunday', 'col-ds-mo-team', '普通莫队', $AKB152$## 算法原理

莫队（Mo's Algorithm）是一种基于分块的离线区间查询算法。其核心策略是"离线重排+双指针增量"：不逐个回答查询，而是先将所有查询按照特定规则排序，然后用两个指针[l, r]表示当前已维护的区间，通过移动指针来增量地加入或移除元素，从而在两次查询之间复用已有的计算结果。每次指针移动只增减一个元素，若加入/删除单个元素的代价为 $O(1)$，则总复杂度取决于指针的总移动量。

分块大小s取 $\sqrt{n}$。将数轴[1, n]划分为若干长度为s的块（第i块覆盖 $[i \cdot s,\; (i+1) \cdot s - 1]$）。排序规则为：先按查询左端点l所在的块号（l/s）升序排列，同一块内再按右端点r排序。这样左指针在块内移动最多s步，跨块时最多2s步，m个查询共 $m \cdot s$ 次左移；右指针在同一块内单调移动最多n步，共 $(\sqrt{n})$ 个块（即 $n/s = \sqrt{n}$ 个块），总计 $n \cdot (n/s) = n \cdot \sqrt{n}$ 次右移。总移动量为 $O(m \cdot s + n \cdot n/s)$，取 $s = \sqrt{n}$ 时两者均为 $O(n \cdot \sqrt{n})$（当m与n同阶时），达到最优。

奇偶性优化（parity optimization）进一步减少右指针的移动距离。标准排序中同一块内右端点始终升序，导致右指针在块间切换时需要从块末尾回到块开头再前进。奇偶优化让奇数块内r按降序排列、偶数块内r按升序排列，这样右指针在块间切换时无需"折返跑"，直接延续上一块的终点继续移动。实测可减少约一半的右指针移动量。代码中 `if (al & 1) return this->r > b.r; else return this->r < b.r;` 即实现了此优化。

双指针的移动顺序至关重要。四个while循环的顺序为：先扩展（expand left, expand right）再收缩（shrink left, shrink right）。即先将l向左扩展、r向右扩展，再收缩l、收缩r。这一顺序保证了在收缩前区间已经包含了目标范围，避免出现 $l > r + 1$ 的非法状态。具体来说，若先收缩l（l++），则可能l越过r导致区间为空，此时my_pop会移除本不在区间内的元素；而先扩展确保了在收缩时被移除的元素确实在当前区间内。代码中 `s = sqrt(n) + 1` 的+1是为了避免n=0时除零错误。

## 数据结构图示

```
分块排序示意 (s = sqrt(n), 设 n=16, s=4):

块号:  |--- 块0 (l/s=0) ---|--- 块1 (l/s=1) ---|--- 块2 (l/s=2) ---|--- 块3 ---|
位置:  1  2  3  4            5  6  7  8          9 10 11 12         13 14 15 16

查询排序 (奇偶优化):
  块0 (偶数块): q1(r=3), q2(r=6), q3(r=8)     <- r 升序 -->
  块1 (奇数块): q5(r=12), q4(r=9)            <- r 降序 <--
  块2 (偶数块): q7(r=10), q8(r=15)           <- r 升序 -->
  块3 (奇数块): q10(r=16), q9(r=14)          <- r 降序 <--

双指针移动示意:
  当前 [l,r] = [3, 6], 目标 [l',r'] = [5, 9]

  步骤1: 扩展左  l: 3->2 (push [2])      [l=2, r=6]
  步骤2: 扩展右  r: 6->9 (push [7,8,9])  [l=2, r=9]
  步骤3: 收缩左  l: 2->5 (pop [2,3,4])  [l=5, r=9]  ✓ 到达目标
  (步骤4: 收缩右 r 不需移动, r已=9)

  关键: 先扩展后收缩, 确保收缩时元素一定在区间内
```

## 核心操作详解

**query结构体与排序**：`query` 包含 l, r, idx 三个字段。`operator<` 实现莫队排序：先取 `al = this->l / s` 和 `bl = b.l / s`，若块号不同则按块号升序；若同块则按奇偶性决定r的排序方向——`al & 1` 为真（奇数块）时r降序，为假（偶数块）时r升序。`idx` 用于将排好序的答案写回原始顺序。

**my_push(i)**：向当前区间加入位置i的元素A[i]。维护的是各元素出现次数的平方和 `cur`。操作模式为"先减旧贡献，修改计数，再加新贡献"：$\text{cur} \mathrel{-}= \text{cnt}[A[i]]^2$（移除旧的平方贡献），$\text{cnt}[A[i]]{+}{+}$（计数增加），$\text{cur} \mathrel{+}= \text{cnt}[A[i]]^2$（加上新的平方贡献）。这一模式适用于任何以计数为自变量的贡献函数。

**my_pop(i)**：从当前区间移除位置i的元素A[i]，是my_push的逆操作：$\text{cur} \mathrel{-}= \text{cnt}[A[i]]^2$，$\text{cnt}[A[i]]{-}{-}$，$\text{cur} \mathrel{+}= \text{cnt}[A[i]]^2$。同样遵循"减旧贡献、改计数、加新贡献"模式。

**主循环**：初始化 `l=1, r=0`（空区间）。对排序后的每个查询，执行四个while循环调整指针：`while (B[i].l < l) my_push(--l)`（向左扩展）、`while (B[i].r > r) my_push(++r)`（向右扩展）、`while (B[i].l > l) my_pop(l++)`（向左收缩）、`while (B[i].r < r) my_pop(r--)`（向右收缩）。调整完毕后 `ans[B[i].idx] = cur` 记录答案。注意四个循环的顺序是先扩展后收缩。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<algorithm>
#include<iostream>
#include<vector>
#include<cmath>
/*洛谷P2709*/
using namespace std;
int n, m, k, s;          // n=数组长度, m=查询数, k=颜色范围, s=块大小
long long cur = 0;        // 当前区间的答案 (各颜色出现次数的平方和)
vector<int> cnt;          // cnt[c] = 颜色c在当前区间中的出现次数
vector<int> A;            // A[1..n] = 输入数组 (颜色序列)
vector<long long> ans;    // ans[i] = 第i个查询的答案

```

- `n`、`m`、`k` 分别是数组长度、查询数、颜色上限；`s` 是块大小，声明为全局变量是因为排序比较器 `operator<` 里也要用到。
- `cur` 存当前 `[l,r]` 区间的答案（各颜色出现次数平方和），累加可达 `n^2`，所以用 `long long`。
- `cnt` 按下标「颜色」计数，`A` 按下标「位置」存颜色，两个数组下标含义不同，容易搞混。
- `ans` 按原始查询编号存答案，配合排序后 `idx` 还原。

### query结构体与排序

```cpp
struct query
{
	int l, r, idx;        // l=左端点, r=右端点, idx=原始查询编号
	bool operator< (query& b)
	{
		int al = this->l / s;  // 当前查询左端点所在块号
		int bl = b.l / s;      // 比较对象左端点所在块号
		if (al != bl) return al < bl;  // 不同块: 按块号升序
		else
		{
			// 同块: 奇偶优化
			// 奇数块 (al&1==1): r降序, 避免块间折返
			// 偶数块 (al&1==0): r升序
			if (al & 1) return this->r > b.r;  // 奇数块 r降序
			else return this->r < b.r;         // 偶数块 r升序
		}
	}
};
vector<query> B;          // 查询数组

```

- `al = l / s` 是整数除法，得到左端点所在块号；块号不同先比块号，让左指针尽量在块内局部移动。
- 同块再按 `r` 排序；奇偶优化让相邻块的 `r` 方向相反，减少右指针在块间切换时的折返。
- `al & 1` 等价 `al % 2` 判奇偶：奇数块 `r` 降序、偶数块 `r` 升序，这个方向容易记反。
- `idx` 记录原始编号，排序打乱顺序后仍能把答案写回正确位置。

### my_push / my_pop（核心增量）

```cpp
void my_push(int i)       // 加入位置i的元素 A[i]
{
	// 模式: 减旧贡献 -> 改计数 -> 加新贡献
	cur -= (long long)cnt[A[i]] * cnt[A[i]];  // 减去旧的 cnt^2
	cnt[A[i]]++;                               // 计数+1
	cur += (long long)cnt[A[i]] * cnt[A[i]];  // 加上新的 cnt^2
}
void my_pop(int i)        // 移除位置i的元素 A[i]
{
	// my_push 的逆操作
	cur -= (long long)cnt[A[i]] * cnt[A[i]];  // 减去旧的 cnt^2
	cnt[A[i]]--;                               // 计数-1
	cur += (long long)cnt[A[i]] * cnt[A[i]];  // 加上新的 cnt^2
}

```

- 两者都是「减旧贡献 -> 改计数 -> 加新贡献」三步，唯一区别是 `cnt` 的 `++` 与 `--`。
- 下标是颜色 `A[i]` 而非位置 `i`；先把 `cnt[A[i]]` 强转 `long long` 再平方，避免 `int` 相乘溢出。
- `push` 与 `pop` 完全对称，任何一步符号或顺序写错都会让 `cur` 永久错乱。

### main：读入与初始化

```cpp
int main()
{
	cin >> n >> m >> k;
	s = sqrt(n) + 1;       // 块大小 = sqrt(n) + 1 (+1 避免除零)
	A.resize(n + 1, 0);
	B.resize(m + 1);
	ans.resize(m + 1, 0);
	cnt.resize(k + 1, 0);  // 颜色范围 [1, k]
	for (int i = 1;i <= n;i++) cin >> A[i];  // 读入颜色序列
	for (int i = 1;i <= m;i++)
	{
		cin >> B[i].l >> B[i].r;  // 读入查询区间
		B[i].idx = i;              // 记录原始编号 (排序后需还原)
	}
	sort(B.begin() + 1, B.end());  // 莫队排序 (跳过B[0]空位)

```

- 所有数组统一从下标 1 开始用，所以 `resize` 成 `n+1` / `m+1` / `k+1`，留出 0 号位。
- `s` 必须在 `sort` 之前算好，因为 `operator<` 里要用它除出块号。
- `cnt` 按颜色上限 `k` 而非 `n` 分配，因为它的下标是颜色值而不是位置。
- `B[i].idx = i` 是最后答案还原的关键，漏写会导致输出顺序错乱。

### main：排序与双指针主循环

```cpp
	int l = 1;int r = 0;  // 初始空区间 [1, 0]
	for (int i = 1;i <= m;i++)
	{
		// 四个while循环: 先扩展后收缩
		// 顺序关键: 先expand再shrink, 避免l > r+1的非法状态
		while (B[i].l < l) my_push(--l);  // 扩展左: l向左移, push新元素
		while (B[i].r > r) my_push(++r);  // 扩展右: r向右移, push新元素
		while (B[i].l > l) my_pop(l++);   // 收缩左: l向右移, pop旧元素
		while (B[i].r < r) my_pop(r--);   // 收缩右: r向左移, pop旧元素
		ans[B[i].idx] = cur;              // 记录答案到原始位置
	}
	for (int i = 1;i <= m;i++) cout << ans[i] << endl;  // 按原始顺序输出
	return 0;
}
```

- `sort` 从 `B.begin()+1` 开始，跳过没用的 `B[0]`；`l=1`、`r=0` 表示空区间，`r` 是「已包含的最右位置」。
- 四个 `while` 必须先扩展（左、右）后收缩（左、右），否则可能 `l > r+1`，让 `pop` 移除区间外元素。
- `--l` / `++r` 是先移动指针再 `push` 新位置，`l++` / `r--` 是先 `pop` 当前位置再移动，自增自减位置别写反。
- 答案写回 `ans[B[i].idx]`，最后按 `1..m` 原始顺序输出。

## 复杂度分析

时间复杂度为 $O((n + m) \cdot \sqrt{n})$，具体分解如下：

左指针移动量：在同一块内，左指针最多移动s步（块大小）；跨块时最多移动2s步。m个查询的左指针总移动量为 $O(m \cdot s) = O(m \cdot \sqrt{n})$。

右指针移动量：在同一块内（同一块的所有查询），右指针单调移动（升序或降序），最多移动n步。共有 $n/s = \sqrt{n}$ 个块，因此右指针总移动量为 $O(n \cdot (n/s)) = O(n \cdot \sqrt{n})$。

取 $s = \sqrt{n}$ 时，总移动量为 $O(m \cdot \sqrt{n} + n \cdot \sqrt{n}) = O((m+n) \cdot \sqrt{n})$。每次移动的增量更新（my_push/my_pop）为 $O(1)$，因此总时间复杂度为 $O((n+m) \cdot \sqrt{n})$。排序为 $O(m \cdot \log m)$。

空间复杂度为 $O(n + m)$：cnt数组 $O(k)$，A数组 $O(n)$，查询和答案数组各 $O(m)$。

## 适用场景

莫队算法适用于离线区间查询场景，且区间答案可以 $O(1)$ 增量维护（即加入或删除单个元素时可以在 $O(1)$ 内更新答案）。典型应用包括：区间不同数个数（维护每种颜色的计数，答案为非零计数种类数）、区间众数（维护计数后取最大值）、区间元素出现次数的平方和（P2709小B的询问，本代码所解）、区间逆序对数等。莫队不适用于需要在线回答查询的场景，也不适用于加入/删除元素代价高于 $O(1)$ 的查询。

## 常见陷阱与注意事项

- **块大小 $s = \sqrt{n} + 1$**：`+1` 是为了在n=0时避免除零错误。若不写+1，当n=0时 `l / s` 会除以0导致未定义行为。s的取值直接影响复杂度，$s = \sqrt{n}$ 是理论最优分块。
- **排序必须使用奇偶性优化**：奇偶优化（奇数块r降序、偶数块r升序）可显著减少右指针的折返移动，实测可提速30%-50%。若不使用奇偶优化，右指针在块间切换时需从当前块末尾回到下一块开头再前进，浪费大量移动。
- **四个while循环的顺序**：必须先扩展（expand left, expand right）后收缩（shrink left, shrink right）。若先收缩，则可能 $l > r$ 导致区间为空，此时my_pop会移除不在区间内的元素，产生错误答案。例如若先执行 `while (B[i].l > l) my_pop(l++)`，当目标l远大于当前l时，l会越过r，后续的push会基于错误的cnt状态。
- **cur的维护模式**：$\text{cur} \mathrel{-}= \text{cnt}^2;\; \text{cnt}{+}{+};\; \text{cur} \mathrel{+}= \text{cnt}^2$ 这一"减旧贡献、改计数、加新贡献"的模式适用于任何以计数为自变量的贡献函数f(cnt)。若答案定义为 $\sum f(\text{cnt}_i)$，则push时 $\text{cur} \mathrel{-}= f(\text{cnt});\; \text{cnt}{+}{+};\; \text{cur} \mathrel{+}= f(\text{cnt})$，pop时对称。本代码中 $f(x) = x^2$。
- **答案的idx还原**：排序打乱了查询顺序，必须用 `B[i].idx` 将答案写回原始位置 `ans[B[i].idx]`，最后按1..m顺序输出。若忘记idx则答案顺序错误。
- **cnt数组的大小**：cnt的下标是颜色值A[i]而非位置i，因此 `cnt.resize(k+1)` 按颜色范围k分配。若颜色值可能为0或超过k则需离散化。

## 对比与扩展

- **普通莫队 vs 带修莫队（Mo's with updates）**：带修莫队在查询中引入修改操作，通过增加第三维时间戳，将块大小调整为 $n^{2/3}$，排序按(块号, r块号, 时间)三关键字排列。复杂度从 $O(n \cdot \sqrt{n})$ 升为 $O(n^{5/3})$。
- **普通莫队 vs 树上莫队（Mo's on trees）**：树上莫队利用欧拉序（DFS序）将树链查询转化为区间查询，再套用普通莫队。欧拉序的入栈+出栈特性使得一条链上的节点恰好在区间中出现一次（LCA除外）。
- **普通莫队 vs 三维莫队（3D Mo's）**：当查询有三个维度（如时间、左端点、右端点）时，使用三维分块，块大小取 $n^{2/3}$，复杂度为 $O(n^{5/3})$。带修莫队本质上是三维莫队的特例。
- **普通莫队 vs 回滚莫队（Rollback Mo's）**：当删除操作难以 $O(1)$ 维护（如并查集的删除），使用回滚莫队：只做扩展不做收缩，通过记录修改历史在块间回滚到初始状态。复杂度仍为 $O(n \cdot \sqrt{n} \cdot \alpha)$。
- **扩展：莫队二次离线**：当增量更新需要 $O(\log n)$ 时（如维护区间逆序对），利用莫队二次离线将复杂度从 $O(n \cdot \sqrt{n} \cdot \log n)$ 降为 $O(n \cdot \sqrt{n} + n \cdot \log n)$。
- **扩展：最优块长 $B = n/\sqrt{q}$**：固定块长 $\sqrt{n}$ 只是 $q \approx n$ 时的特例。更一般地，设查询数为 $q$、块长为 $B$，则左指针总移动 $O(q \cdot B)$，右指针总移动 $O(n \cdot n/B)$，总移动量为 $O(qB + n^2/B)$。令两项相等解出最优块长 $B = n/\sqrt{q}$，此时总移动量最小，均摊复杂度为 $O(n\sqrt{q})$。当 $q$ 远小于 $n$（稀疏查询）时，$n/\sqrt{q}$ 明显大于 $\sqrt{n}$，仍用固定 $\sqrt{n}$ 反而更慢。

```
// 最优块长：B = n / sqrt(q)（q 为查询数，n 为序列长度）
// 排序仍按 l/B 分块，同块内按 r（配合奇偶优化）排序
```$AKB152$, '数据结构', array['数据结构', '莫队', '分块', '离线查询', '区间查询'], null, null, 'knowledge'),
('Xesir', 'col-ds-monoqueue-1d--xesir', '滑动窗口（单调队列） · Xesir', $AKB153$## 算法原理

> 给定一个长度为 $n$ 的数组和一个宽度为 $k$ 的窗口，窗口从左到右滑动，输出窗口在每个位置时的最小值和最大值。

比如数组为 `[1 3 -1 -3 5 3 6 7]`、$k=3$：

| 窗口位置 | 最小值 | 最大值 |
|---|---|---|
| [1 3 -1] -3 5 3 6 7 | -1 | 3 |
| 1 [3 -1 -3] 5 3 6 7 | -3 | 3 |
| 1 3 [-1 -3 5] 3 6 7 | -3 | 5 |
| 1 3 -1 [-3 5 3] 6 7 | -3 | 5 |
| 1 3 -1 -3 [5 3 6] 7 | 3 | 6 |
| 1 3 -1 -3 5 [3 6 7] | 3 | 7 |

本质上就是维护一个**单调队列**。求最小值时注意到：$-1 < 1 < 3$，而 $-1$ 的位置比 $1, 3$ 更靠后，所以 $-1$ 一旦进队，$1$ 和 $3$ 就**再也不可能**成为之后窗口的最小值——因为它们会比 $-1$ 先滑出窗口。于是可以放心地把它们从队尾弹掉。

由此得到一个**单调不降的队列**：队首就是当前窗口的最小值；窗口右移、队首滑出区间时再 `head++` 弹出。求最大值同理，维护一个**单调不增**的队列即可。

关键在于「**队尾弹掉比新元素更差、且更早过期的元素**」，这样每个元素最多进队一次、出队一次。

## 逐行代码解析

下面一份代码同时求最小值和最大值：先跑一遍单调不降队列求最小值，重置队头队尾后再跑一遍单调不增队列求最大值。

### 数组与指针初始化

```cpp
int h[1000010],q[1000010];
int hh,tt=-1;
```

- `h` 存数组元素，`q` 存**下标**（不是值，方便判断是否滑出窗口）。
- `hh` 是队头指针，`tt` 是队尾指针；初始 `hh = 0, tt = -1` 表示空队列。

### 求最小值：单调不降队列

```cpp
for(int i=1;i<=n;i++){
    if(hh<=tt&&i-q[hh]>=k){
        hh++;
    }
    while(hh<=tt&&h[q[tt]]>=h[i]){
        tt--;
    }
    q[++tt]=i;
    if(i >= k) cout << h[q[hh]] << ' ';
}
```

- `if(hh<=tt && i-q[hh]>=k) hh++;`：队首下标与当前位置相距 $\ge k$，说明它已经滑出窗口，把它弹掉。这里用 `if` 而非 `while`，因为每次最多滑出一个。
- `while(hh<=tt && h[q[tt]] >= h[i]) tt--;`：新元素更小，队尾那些「又大又靠前」的元素就废了，从队尾一路弹掉，保证队列值单调不降。
- `q[++tt]=i;`：把当前下标压入队尾。
- `if(i >= k) cout << h[q[hh]];`：窗口填满后，队首即最小值。

### 求最大值：单调不增队列

```cpp
hh=0;tt=-1;cout<<endl;
for(int i=1;i<=n;i++){
     if(hh<=tt&&i-q[hh]>=k){
         hh++;
     }
     while(hh<=tt&&h[q[tt]]<=h[i]){
         tt--;
     }
     q[++tt]=i;
     if(i >= k) cout << h[q[hh]] << ' ';
 }
```

- 重置 `hh = 0; tt = -1;` 清空队列，再跑第二遍。
- 与求最小值唯一的差别：队尾弹掉条件是 `h[q[tt]] <= h[i]`（更小的反而被弹掉），于是队列单调不增，队首变最大值。

## 复杂度分析

- 每个下标最多入队一次、出队一次，两趟扫描合计仍是线性：时间 $O(n)$。
- 空间 $O(n)$，即元素数组 `h` 加队列数组 `q`。
- 相比「每个窗口重新扫 $k$ 个」的 $O(nk)$ 暴力，单调队列把求最值降到了均摊 $O(1)$。

## 适用场景

- **滑动窗口最值**：固定长度窗口的区间 min / max。
- **DP 优化**：形如 $f_i = \min_{j \in [i-k, i-1]} f_j + w_i$ 的转移，用单调队列把内层循环从 $O(k)$ 降成 $O(1)$（如多重背包单调队列优化、单调队列优化 DP）。
- **限长区间查询**：任何「窗口右移、只需队首信息」的滑窗类问题。

## 常见陷阱与注意事项

1. **队列存下标还是值**：必须存**下标**，否则无法判断队首是否滑出窗口。
2. **弹出条件写反**：求最小值用 `h[q[tt]] >= h[i]`（后者更优就弹），求最大值用 `<=`，方向搞反会得到相反的结果。
3. **滑出判断用 `if` 而非 `while`**：一次右移最多有一个队首过期，用 `while` 虽不致命但语义不清晰。
4. **输出时机**：`if(i >= k)` 才输出，前 $k-1$ 个位置窗口还没填满。
5. **两趟之间要重置**：求完最小值记得把 `hh`、`tt` 复位成空队列，再跑最大值那趟。

## 对比与扩展

| 维度 | 单调队列 | 线段树 / ST 表 | 暴力 |
|---|---|---|---|
| 单次查询 | 均摊 $O(1)$ | $O(\log n)$ / $O(1)$ | $O(k)$ |
| 总复杂度 | $O(n)$ | $O(n \log n)$（建树） | $O(nk)$ |
| 是否需离线 | 滑动扫描即可 | 查询式 | 滑动即可 |
| 支持修改 | 不直接支持 | 支持 | 支持 |

扩展方向：**二维滑动窗口最值**（行列各扫一遍，对应 `ds-monoqueue-2d`）、**单调栈**（本质相同，只是只在一端操作，对应 `ds-monostack-histogram`）、以及**单调队列优化 DP**。$AKB153$, '数据结构', array['数据结构', '单调队列', '滑动窗口', '区间最值', '双端队列'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-monoqueue-1d', '单调队列（一维 / 二维滑动窗口）', $AKB154$## 算法原理

单调队列（Monotonic Queue）是一种特殊的双端队列，其内部元素始终保持单调递增或单调递减。它是解决**滑动窗口最值**问题的最优数据结构：给定长度为 $n$ 的数组 $A$ 和窗口大小 $k$，窗口从左到右滑动，求每个窗口位置的最大值和最小值。

核心思想是维护一个单调双端队列，队列中存储元素的值和下标，且队列的值始终保持单调性：

- **求最大值**：维护**单调递减**队列，队首始终是当前窗口的最大元素
- **求最小值**：维护**单调递增**队列，队首始终是当前窗口的最小元素

对每个新元素 $A[i]$ 的处理分为三步：
1. **队首出窗**：检查队首下标是否已滑出窗口（`i - 队首下标 >= k`），若过期则弹出队首
2. **维护单调性**：从队尾弹出所有不满足单调性的元素。对于最大值队列，弹出所有 $\leq A[i]$ 的队尾；对于最小值队列，弹出所有 $\geq A[i]$ 的队尾
3. **入队**：将 `(A[i], i)` 从队尾入队

当窗口填满（$i \geq k$）后，队首即为当前窗口的最值。

正确性的关键在于：当一个新元素入队时，所有比它更小（对最大值队列）或更大（对最小值队列）的队尾元素都**不可能成为未来任何窗口的最值**——因为新元素更"优"（更大或更小）且更晚过期（下标更大），所以可以安全弹出。这保证了队列长度远小于窗口大小，每个元素最多入队出队各一次，均摊 $O(1)$。

本模板同时维护最大值和最小值两个队列，实际中可按需只使用一个。

## 核心公式

设数组为 $A[1..n]$，窗口大小为 $k$，单调队列为 $Q$（存储 `(值, 下标)` 对）。

**队首出队条件**（下标超出窗口范围）：

$$
\text{若 } i - Q.\text{front}().\text{second} \geq k: \quad Q.\text{pop\_front()}
$$

**队尾维护（最大值队列，单调递减）**：

$$
\text{while } Q \text{ 非空 且 } Q.\text{back}().\text{first} \leq A[i]: \quad Q.\text{pop\_back()}
$$

**队尾维护（最小值队列，单调递增）**：

$$
\text{while } Q \text{ 非空 且 } Q.\text{back}().\text{first} \geq A[i]: \quad Q.\text{pop\_back()}
$$

**入队**：

$$
Q.\text{push\_back}((A[i],\; i))
$$

**窗口最值**（当 $i \geq k$ 时有效）：

$$
\text{窗口最大值} = Q_{\max}.\text{front}().\text{first}, \quad \text{窗口最小值} = Q_{\min}.\text{front}().\text{first}
$$

## 数据结构图示

```
输入示例：A = [1,3,-1,-3,5,3,6,7], k = 3
下标：     1 2  3  4 5 6 7 8

=== 逐步执行（以最大值队列为例，单调递减） ===

i=1, A[1]=1:
  队首出窗: 队列为空, 跳过
  维护: 队列为空, 直接入
  入队: [(1,1)]
  i<3, 不记录

i=2, A[2]=3:
  队首出窗: 2-1=1 < 3, 不出
  维护: 1 <= 3 → 弹出 → 队空
  入队: [(3,2)]
  i<3, 不记录

i=3, A[3]=-1:
  队首出窗: 3-2=1 < 3, 不出
  维护: 3 > -1 → 不弹
  入队: [(3,2), (-1,3)]
  i>=3, 窗口最大值 = 队首值 = 3  ✓ (窗口[1,3]=[1,3,-1], max=3)

i=4, A[4]=-3:
  队首出窗: 4-2=2 < 3, 不出
  维护: -1 > -3 → 不弹
  入队: [(3,2), (-1,3), (-3,4)]
  i>=3, 窗口最大值 = 3  ✓ (窗口[2,4]=[3,-1,-3], max=3)

i=5, A[5]=5:
  队首出窗: 5-2=3 >= 3 → 弹出队首(3,2)
         队列变为 [(-1,3), (-3,4)]
         5-3=2 < 3 → 停止出窗
  维护: -3 <= 5 → 弹出 → [(-1,3)]
       -1 <= 5 → 弹出 → []
  入队: [(5,5)]
  i>=3, 窗口最大值 = 5  ✓ (窗口[3,5]=[-1,-3,5], max=5)

i=6, A[6]=3:
  队首出窗: 6-5=1 < 3, 不出
  维护: 5 > 3 → 不弹
  入队: [(5,5), (3,6)]
  i>=3, 窗口最大值 = 5  ✓ (窗口[4,6]=[-3,5,3], max=5)

i=7, A[7]=6:
  队首出窗: 7-5=2 < 3, 不出
  维护: 3 <= 6 → 弹出 → [(5,5)]
       5 <= 6 → 弹出 → []
  入队: [(6,7)]
  i>=3, 窗口最大值 = 6  ✓ (窗口[5,7]=[5,3,6], max=6)

i=8, A[8]=7:
  队首出窗: 8-7=1 < 3, 不出
  维护: 6 <= 7 → 弹出 → []
  入队: [(7,8)]
  i>=3, 窗口最大值 = 7  ✓ (窗口[6,8]=[3,6,7], max=7)

=== 最终结果 ===
窗口最大值: [3, 3, 5, 5, 6, 7]   (共 n-k+1 = 6 个)
窗口最小值: [-1, -3, -3, -3, 3, 3]
```

## 核心操作详解

### 初始化：双端队列

- **数据结构**：`deque<pair<int,int>> que_max, que_min`，C++ STL 的双端队列，支持 $O(1)$ 头尾增删。
- **存储内容**：每个元素是 `(值, 下标)` 对。值用于比较维护单调性，下标用于判断是否出窗。
- **关键细节**：也可以只存下标，值从原数组读取（节省空间但多一次数组访问）。竞赛中常用存值的方式，减少代码出错点。

### 三步处理流程（每个元素）

1. **队首出窗**：`if(i - que.front().second >= k) que.pop_front()`
   - 窗口是左闭右开还是闭区间？窗口为 $[i-k+1, i]$，共 $k$ 个元素。当队首下标 $\leq i-k$ 时出窗，即 `i - 下标 >= k`。
   - 为什么用 `>=` 而不是 `>`：`i - idx >= k` 表示队首下标距当前已达到窗口大小，确实已滑出。若用 `>` 会多保留一个过期元素。

2. **维护单调性**：`while(!que.empty() && que.back().first <= A[i]) que.pop_back()`（最大值队列）
   - 弹出所有不可能成为未来窗口最值的队尾元素。新元素比队尾更"优"且更晚过期，队尾永远不可能再成为最值。
   - 注意是 `<=` 还是 `<`：含等号时，相等元素弹出旧的保留新的，更安全（新的出窗更晚）。不含等号时，相等元素共存，队列可能稍长但不影响正确性。

3. **入队**：`que.emplace_back(A[i], i)`
   - 将当前元素加入队尾。此时队列仍保持单调性。

### 记录结果

- **时机**：`if(i >= k)` 时，窗口已填满 $k$ 个元素，队首即为当前窗口最值。
- **结果**：`que_max.front().first` 是最大值，`que_min.front().first` 是最小值。
- **结果数量**：共 $n - k + 1$ 个窗口的结果。

## 逐行代码解析

下面把完整程序按「入口 → 读入 → 数据结构 → 主循环 → 输出」拆成 5 个模块；所有模块的代码块按顺序拼接起来就是完整程序（注释已标注各步含义）。

### 模块 1：头文件与 main 入口

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
```

- `bits/stdc++.h` 是万能头，一次包含 `vector`、`deque`、`pair`、`iostream` 等所需头文件，竞赛常用。
- `using namespace std;` 省略 `std::` 前缀，让 `vector`、`deque`、`cin`、`cout` 可以直接书写。

### 模块 2：读入与数组初始化

```cpp
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n,k;
    cin >> n >> k;                         // n: 数组长度, k: 窗口大小
    vector<int> A(n + 1,0);                // 原数组（1-based）
    for(int i = 1;i <= n;i++) cin >> A[i];
```

- 关闭同步流并解绑 `cin`/`cout`，避免读入大数组时超时。
- `A` 开 `n + 1` 且下标从 `1` 开始（1-based），窗口范围是 `[i-k+1, i]`，出窗判断更直观。

### 模块 3：结果数组与单调队列

```cpp
    vector<int> mymax;                     // 存每个窗口的最大值
    vector<int> mymin;                     // 存每个窗口的最小值
    deque<pair<int,int>> que_max;          // 最大值队列（单调递减）
    deque<pair<int,int>> que_min;          // 最小值队列（单调递增）
```

- `deque<pair<int,int>>`：STL 双端队列，存 `(值, 下标)` 对；`front()`/`back()`/`pop_front()`/`pop_back()`/`emplace_back()` 全部 $O(1)$。
- `que_max` 和 `que_min` 是两个独立队列，分别维护最大/最小，逻辑完全对称，只是比较方向相反（`<=` vs `>=`）。

### 模块 4：主循环（出窗 + 维护单调 + 入队 + 记录）

```cpp
    for(int i = 1;i <= n;i++)
    {
        // === 第一步：队首出窗 ===
        if(!que_max.empty())
        {
            int idx = que_max.front().second;
            if(i - idx >= k) que_max.pop_front();
        }
        if(!que_min.empty())
        {
            int idx = que_min.front().second;
            if(i - idx >= k) que_min.pop_front();
        }

        // === 第二步：维护单调性（弹出队尾） ===
        while(!que_max.empty() && que_max.back().first <= A[i]) que_max.pop_back();
        que_max.emplace_back(A[i] , i);    // 第三步：入队

        while(!que_min.empty() && que_min.back().first >= A[i]) que_min.pop_back();
        que_min.emplace_back(A[i] , i);    // 第三步：入队

        // === 记录结果（窗口填满后） ===
        if(i >= k)
        {
            mymax.emplace_back(que_max.front().first);
            mymin.emplace_back(que_min.front().first);
        }
    }
```

- 队首出窗用 `if` 而非 `while`：每次 `i` 只增 `1`，最多一个元素过期出窗。
- `i - idx >= k` 用 `>=` 而非 `>`：`>=` 才表示队首下标已滑出窗口，用 `>` 会多保留一个过期元素。
- 维护单调性用 `while`：可能要连续弹出多个队尾；`que_max` 弹 `<=`（递减）、`que_min` 弹 `>=`（递增），方向弄反会导致队列无序。
- 先弹队尾再入队，顺序不能颠倒；`i >= k` 时窗口才填满 `k` 个元素，此时 `front()` 必非空、可安全取值。

### 模块 5：输出结果

```cpp
    for(int i : mymin) cout << i << " ";   // 先输出所有窗口最小值
    cout << endl;
    for(int i : mymax) cout << i << " ";   // 再输出所有窗口最大值
    return 0;
}
```

- 先输出所有窗口最小值、再输出所有窗口最大值，符合题目常见格式，可按需调换。
- 结果数量为 `n - k + 1` 个窗口。

## 复杂度分析

- **时间复杂度**：$O(n)$。遍历 $n$ 个元素，每个元素最多入队一次、出队一次（不管是从队首弹出还是队尾弹出），均摊 $O(1)$。两个队列总操作次数不超过 $2n$。
- **空间复杂度**：$O(k)$。队列大小最多为窗口大小 $k$（当数组严格单调时，队列长度等于当前窗口长度）。结果数组 `mymax` 和 `mymin` 各为 $O(n-k+1)$，总空间 $O(n)$。若只需实时输出不保存结果，空间为 $O(k)$。

与其他方法对比：

| 方法 | 时间 | 空间 | 特点 |
|---|---|---|---|
| 单调队列 | $O(n)$ | $O(k)$ | 最优，固定窗口大小 |
| 优先队列（堆） | $O(n \log n)$ | $O(n)$ | 支持动态窗口，但弹出懒删除 |
| ST 表 | 预处理 $O(n \log n)$，查询 $O(1)$ | $O(n \log n)$ | 支持任意区间查询 |
| 暴力法 | $O(nk)$ | $O(1)$ | 小数据可用 |

## 适用场景

固定大小的一维滑动窗口最值查询，是单调队列最基础也是最核心的应用。在此基础上可扩展到：
- **DP 优化**：多重背包单调队列优化、长度不超过 $m$ 的最大子段和、各种"在窗口内取最值"的 DP 转移优化
- **二维扩展**：两阶段单调队列求 `K×K` 子矩阵最值（见「二维滑动窗口最值」）
- **子数组问题**：满足条件的最短/最长子数组（配合双指针 + 单调队列）
- **数据流问题**：滑动窗口中位数、滑动窗口平均值等变体

本模板是单调队列的标准入门写法，掌握后可快速推导各种变体。

## 常见陷阱与注意事项

1. **队首出窗条件用 `>=` 而非 `>`**：`i - idx >= k` 表示队首下标距当前已达到窗口大小，已滑出窗口。若用 `>` 会多保留一个过期元素，导致结果错误。
2. **队尾弹出的方向**：`que_max` 弹出 $\leq$ 当前值的（保持递减，队首最大）；`que_min` 弹出 $\geq$ 当前值的（保持递增，队首最小）。方向弄反会导致队列无序，结果错误。
3. **入队顺序**：先弹出队尾不满足单调性的元素，再入队当前元素。顺序不能颠倒（否则新元素可能被自己弹出，或者队列不单调）。
4. **窗口填满的判断**：`i >= k` 表示窗口已有 $k$ 个元素，开始记录结果。注意数组下标从 $1$ 开始时窗口范围为 $[i-k+1, i]$；若从 $0$ 开始则为 $[i-k+1, i]$，判断条件为 `i >= k-1`。
5. **`deque` 的使用**：双端队列支持 $O(1)$ 的头尾操作，用 `std::deque` 或手写数组模拟均可。手写数组模拟在竞赛中有时更快（无 STL 开销），但 `deque` 更简洁不易错。
6. **同时维护最大最小的开销**：本模板同时维护两个队列，时间空间常数都是两倍。如果只需要一个方向，只需保留对应队列。
7. **值 vs 下标存储**：队列存 `(值, 下标)` 还是只存下标？存值的好处是比较时不用再访问数组（代码更直观），存下标的好处是节省内存（尤其当值的类型很大时）。竞赛中存值更常见。
8. **未校验 $1 \le k \le n$**：当 $k > n$ 或 $k \le 0$ 时，上述逻辑会破坏（如 `i >= k` 永远不成立导致无结果，或出窗条件失效）。通常题目保证输入合法，可默认假设 $1 \le k \le n$；若需稳健处理，应在读入后加判断（如 `if(k <= 0 || k > n)` 特判或调整）。

## 对比与扩展

与优先队列（堆）维护窗口最值相比：单调队列每个元素只入队出队各一次，均摊 $O(1)$；而堆的弹出是懒删除（过期元素还在堆中），最坏 $O(n \log n)$。单调队列在固定窗口最值问题上严格优于堆。

与 ST 表相比：单调队列是**在线**的（边读边处理），且空间更优（$O(k)$ vs $O(n \log n)$）。但 ST 表支持任意区间的 $O(1)$ 查询，适用范围更广。如果只需要滑动窗口最值，单调队列更合适；如果有多种查询需求，ST 表更灵活。

**扩展方向**：
- **二维滑动窗口最值**：先逐行做一维滑动窗口，再逐列做一维滑动窗口（见「二维滑动窗口最值（两阶段单调队列）」），总时间 $O(MN)$
- **多重背包单调队列优化**：将 DP 状态转移方程变形为"窗口内取最值"的形式，用单调队列将 $O(nmk)$ 优化到 $O(nm)$
- **最大子段和（长度受限）**：前缀和 + 单调队列维护窗口最小前缀和，$O(n)$ 求解长度不超过 $m$ 的最大子段和
- **单调栈**：单调队列的"近亲"，维护单调性但只在一端操作，用于求每个元素的下一个更大/更小元素、直方图最大矩形等
- **双端单调队列的其他应用**：满足条件的最短子数组、和至少为 K 的最短子数组（前缀和 + 单调队列）等

## 附：二维滑动窗口最值（两阶段单调队列）

> 本文是一维滑动窗口最值的扩展。若对单调队列的基本操作不熟悉，请先阅读「一维滑动窗口最值（单调队列基础模板）」。

给定一个 $M \times N$ 的矩阵和一个窗口大小 `big`，求每个 `big × big` 子矩阵内的最大值和最小值。这是经典的**二维滑动窗口最值**问题。

最直接的做法是暴力枚举每个窗口的所有 `big × big` 个元素，复杂度为 $O(M \cdot N \cdot \text{big}^2)$，当 big 较大时无法通过。更优的方法是**两阶段单调队列**：把二维问题拆解为两个一维问题。

- **阶段一（行方向）**：对矩阵的每一行，用一维单调队列求出长度为 `big` 的滑动窗口最值，结果存入临时矩阵 `tmp`。此时 `tmp[i][j]` 表示第 $i$ 行中以 $j$ 结尾的、长度为 `big` 的窗口内的最值。
- **阶段二（列方向）**：对 `tmp` 矩阵的每一列，再用一维单调队列求出长度为 `big` 的滑动窗口最值，结果覆盖回 `tmp`。此时 `tmp[i][j]` 表示以 $(i,j)$ 为右下角的 `big × big` 子矩阵的最值。

为什么两阶段是对的？考虑任意一个 `big × big` 窗口：先对每一行求行内窗口最值（得到 big 个行最值），再对这些行最值求列窗口最值——得到的就是整个二维窗口的最值。最值操作具有"可结合性"：$\max(\max(a,b), \max(c,d)) = \max(a,b,c,d)$。行方向先压缩、列方向再压缩，等价于直接求二维窗口的最值。

本代码用 `bool k` 参数统一了最大值和最小值的逻辑：`k=true` 求最小值（递增队列），`k=false` 求最大值（递减队列），通过 `cmp(a, b, k)` 函数动态切换比较方向，避免了写两套几乎相同的代码。

### 核心公式

设原矩阵为 $A[1..M][1..N]$，窗口大小为 $K = \text{big}$。

**阶段一：行方向一维滑动窗口**

$$
\text{tmp}[i][j] = \min_{t = j-K+1}^{j} A[i][t] \quad (\text{或 } \max)
$$

其中 $j \geq K$ 时才有意义，$j < K$ 时为前缀最值。

**阶段二：列方向一维滑动窗口**

$$
\text{ans}[i][j] = \min_{t = i-K+1}^{i} \text{tmp}[t][j] \quad (\text{或 } \max)
$$

**合并后的二维窗口最值**：

$$
\text{ans}[i][j] = \min_{\substack{x \in [i-K+1,\, i] \\ y \in [j-K+1,\, j]}} A[x][y] \quad (\text{或 } \max)
$$

**单调队列的维护不变性**（以求最小值为例）：

设队列为 $Q = [q_1, q_2, \dots, q_m]$（按下标递增排列），对应值为 $v_1, v_2, \dots, v_m$，则队列满足：

$$
v_1 \leq v_2 \leq \dots \leq v_m \quad (\text{单调递增})
$$

每次右端加入新元素 $a$ 时，弹出队尾所有 $\geq a$ 的元素再入队：

$$
\text{while } v_m \geq a \text{ 且 } Q \text{ 非空}: \quad \text{pop\_back}; \quad \text{push\_back}(a)
$$

左端超出窗口范围时出队：

$$
\text{if } j - q_1 \geq K: \quad \text{pop\_front}
$$

窗口最值为队首元素：

$$
\text{window\_min} = v_1
$$

### 数据结构图示

```
输入示例：M=4, N=5, big=2（求 2×2 窗口最小值）

  原矩阵 A:
      j=1  j=2  j=3  j=4  j=5
  i=1   3    1    4    2    5
  i=2   2    4    1    3    2
  i=3   5    2    3    1    4
  i=4   1    3    2    4    1

  === 阶段一：每行做一维滑动窗口（窗口大小 2，求最小值） ===

  第 1 行 [3,1,4,2,5]:
    j=2: min(3,1)=1   que: [1(值1)]
    j=3: min(1,4)=1   que: [1(值1), 3(值4)]
    j=4: min(4,2)=2   que: [4(值2)]  (1 出窗，弹出 3 后入 4)
    j=5: min(2,5)=2   que: [4(值2), 5(值5)]

  tmp 矩阵（每行窗口最小值）:
      j=1  j=2  j=3  j=4  j=5
  i=1   3    1    1    2    2
  i=2   2    2    1    1    2
  i=3   5    2    2    1    1
  i=4   1    1    2    2    1

  === 阶段二：每列做一维滑动窗口（窗口大小 2，求最小值） ===

  第 2 列 [1, 2, 2, 1]:
    i=2: min(1,2)=1   que: [1(值1), 2(值2)]
    i=3: min(2,2)=2   que: [2(值2), 3(值2)]  (1 出窗)
    i=4: min(2,1)=1   que: [4(值1)]  (2,3 弹出后入 4)

  最终 ans 矩阵（2×2 窗口最小值）:
      j=1  j=2  j=3  j=4  j=5
  i=1   3    1    1    2    2
  i=2   2    1    1    1    2
  i=3   2    2    1    1    1
  i=4   1    1    2    1    1

  验证：以 (3,3) 为右下角的 2×2 窗口 = A[2..3][2..3]
        = [[4,1],[2,3]]，最小值 = 1 ✓
        ans[3][3] = 1 ✓
```

### 核心操作详解

#### cmp(a, b, k) — 统一比较函数

- **作用**：根据 `k` 的值切换比较方向，统一最大值和最小值的单调队列逻辑。
- **参数**：`a` 新元素值，`b` 队尾元素值，`k` 方向标志。
- **返回值**：`k=true` 时返回 `a <= b`（求最小值，维护递增队列）；`k=false` 时返回 `a >= b`（求最大值，维护递减队列）。
- **关键细节**：用函数指针或 lambda 也可以，但 `bool` 开关更轻量，且避免了模板/函数对象的代码膨胀。注意是 `<=` 和 `>=`（含等号），这意味着相等元素时旧的会被弹出，保留最新的——这在窗口滑动时更安全（下标更大的元素出窗更晚）。

#### 阶段一：行方向单调队列

- **数据结构**：`vector<pair<int,int>> que_x(N+2)`，存储 `(下标, 值)` 对，`x_l` 和 `x_r` 为左右指针（左闭右开）。
- **算法步骤**：对每一行 $i$，从左到右遍历列 $j$：
  1. 若队首元素下标 $j - \text{下标} \geq \text{big}$（出窗），`++x_l` 弹出队首。
  2. 若 `cmp(A[i][j], 队尾值, k)` 为真，弹出队尾（保持单调性），直到队列为空或不满足比较条件。
  3. 将 `(j, A[i][j])` 入队。
  4. `tmp[i][j] = 队首值`（当前窗口的最值）。
- **关键细节**：每行独立处理，行与行之间不共享状态。`que_x` 在每行开始时自动通过 `x_l=x_r=0` 重置（注意：代码中 `x_l, x_r` 是在 `for(i)` 内声明的，每行都会重新初始化为 0，但 `que_x` 数组本身不会清空——不过因为单调队列是"覆盖写入"，旧数据不会被读取，所以没问题）。

#### 阶段二：列方向单调队列

- **数据结构**：`vector<pair<int,int>> que_y(M+2)`，与阶段一结构相同。
- **算法步骤**：对每一列 $j$，从上到下遍历行 $i$：
  1. 若队首元素下标 $i - \text{下标} \geq \text{big}$（出窗），`++y_l` 弹出队首。
  2. 若 `cmp(tmp[i][j], 队尾值, k)` 为真，弹出队尾（保持单调性）。
  3. 将 `(i, tmp[i][j])` 入队。
  4. `tmp[i][j] = 队首值`（覆盖写入，此时即为二维窗口最值）。
- **关键细节**：阶段二直接在 `tmp` 上覆盖写入，节省了一个矩阵的空间。因为列方向的处理是按行递增的，读取 `tmp[i][j]` 时用的是阶段一的结果（还没被覆盖），写入后的值只在后续行的同列处理中被使用，不冲突。

#### 主函数：分别求最小值和最大值

- **调用方式**：`fn(M, N, true, big, n_min)` 求最小值矩阵；`fn(M, N, false, big, n_max)` 求最大值矩阵。
- **关键细节**：两次调用 `fn` 是完全独立的，分别使用各自的 `tmp` 矩阵。`n_min` 和 `n_max` 在 `main` 中声明，通过引用传递给 `fn` 填充结果。

### 逐行代码解析

#### 全局变量与比较函数 cmp

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<vector<int>> A;                         // 原矩阵（全局，fn 中直接访问）

bool cmp(int a,int b,bool k)
{
    return k ? a <= b : a >= b;                // k=true: 递增(求min); k=false: 递减(求max)
}
```

- `A` 是全局矩阵：`fn` 直接访问全局 `A`，减少参数传递（竞赛常见写法；工程代码建议改为参数传递）。
- `cmp` 是比较方向开关：`a` 是新元素、`b` 是队尾元素；`k=true`（求 min）时返回 `a <= b` 维护递增队列，`k=false`（求 max）时返回 `a >= b` 维护递减队列。
- `<=`/`>=` 含等号：相等时旧元素被弹出、保留新元素（新元素下标更大、出窗更晚），滑动时更安全。

#### fn · 阶段一（行方向单调队列）

```cpp
void fn(int M,int N,bool k,int big,vector<vector<int>>& tmp)
{
    tmp.resize(M + 1, vector<int>(N + 1));     // 初始化结果矩阵
    vector<pair<int, int>> que_x(N + 2);       // 行方向单调队列（存(下标,值)）

    // === 阶段一：每行做行方向滑动窗口 ===
    for (int i = 1; i <= M; i++)
    {
        int x_l = 0, x_r = 0;                   // 队列左右指针（左闭右开）
        for (int j = 1; j <= N; j++)
        {
            int a = A[i][j];
            // 1. 队首出窗
            if (x_l != x_r && j - que_x[x_l].first >= big) ++x_l;
            // 2. 维护单调性：弹出队尾不满足条件的元素
            while (x_l != x_r && cmp(a, que_x[x_r - 1].second, k)) --x_r;
            // 3. 新元素入队
            que_x[x_r++] = pair<int, int>(j, a);
            // 4. 队首即为当前窗口最值
            tmp[i][j] = que_x[x_l].second;
        }
    }
```

- `tmp.resize(M+1, vector<int>(N+1))`：结果矩阵在 `fn` 内部初始化，通过引用 `&tmp` 返回。
- `que_x(N+2)`：手写双端队列，用数组 + 左右指针 `x_l`/`x_r` 模拟（左闭右开）；开 `N+2` 因为队列最多装一行全部 `N` 个元素。
- `x_l`、`x_r` 在 `for(i)` 内声明，每行重置为 0（队列重置），`que_x` 数组复用于每一行（覆盖写入，旧数据不会被读取）。
- 队首出窗条件 `j - que_x[x_l].first >= big`：下标差达到 `big` 时队首已滑出窗口；`x_l != x_r` 保证队列非空再访问队首/队尾。

#### fn · 阶段二（列方向单调队列）

```cpp
    vector<pair<int, int>> que_y(M + 2);       // 列方向单调队列

    // === 阶段二：每列做列方向滑动窗口 ===
    for (int j = 1; j <= N; j++)
    {
        int y_l = 0, y_r = 0;                   // 队列左右指针
        for (int i = 1; i <= M; i++)
        {
            int a = tmp[i][j];                   // 读取阶段一的结果
            // 1. 队首出窗
            if (y_l != y_r && i - que_y[y_l].first >= big) ++y_l;
            // 2. 维护单调性
            while (y_l != y_r && cmp(a, que_y[y_r - 1].second, k)) --y_r;
            // 3. 新元素入队
            que_y[y_r++] = pair<int, int>(i, a);
            // 4. 覆盖写入 tmp（此时 tmp[i][j] 是二维窗口最值）
            tmp[i][j] = que_y[y_l].second;
        }
    }
}
```

- `que_y(M+2)` 与阶段一同构，存 `(下标, 值)`，开 `M+2` 因为队列最多装一列全部 `M` 个元素。
- 阶段二直接在 `tmp` 上覆盖写入、省一个矩阵空间：列按行从上到下处理，读 `tmp[i][j]` 时它仍是阶段一的结果（尚未被覆盖），写完后才变成二维结果；同一列的上行已被覆盖但不影响下行读取。
- `pair<int,int>` 存 `(下标, 值)`：下标用于判断是否出窗、值用于比较；也可只存下标再回矩阵读值（少拷贝、多一次访问），各有利弊。
- 出窗 / 维护单调性逻辑与阶段一完全一致，只是方向换成列（`j` 固定、`i` 递增）。

#### main · 读入与求最小值矩阵

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int M, N, big;
    cin >> M >> N >> big;
    A.resize(M + 1, vector<int>(N + 1));
    for (int i = 1; i <= M; i++)
    {
        for (int j = 1; j <= N; j++)
        {
            cin >> A[i][j];
        }
    }
    cout << '\n';
    vector<vector<int>> n_min, n_max;
    fn(M, N, true, big, n_min);                 // 求最小值矩阵
    for (int i = 1; i <= M; i++)
    {
        for (int j = 1; j <= N; j++)
        {
            cout << n_min[i][j] << ' ';
        }
        cout << '\n';
    }
```

- `ios::sync_with_stdio(false)` + `cin.tie(nullptr)` 加速 IO。
- 矩阵下标从 1 开始（`1..M`、`1..N`），与常规 0-based 不同，输入输出需对应。
- `n_min`、`n_max` 在 `main` 声明，通过引用传给 `fn` 填充；`fn(M, N, true, big, n_min)` 求最小值矩阵。
- 输出格式：先输出最小值矩阵、空行、再输出最大值矩阵。

#### main · 求最大值矩阵与输出

```cpp
    cout << '\n';
    fn(M, N, false, big, n_max);                // 求最大值矩阵
    for (int i = 1; i <= M; i++)
    {
        for (int j = 1; j <= N; j++)
        {
            cout << n_max[i][j] << ' ';
        }
        cout << '\n';
    }
    return 0;
}
```

- `fn(M, N, false, big, n_max)` 求最大值矩阵；两次调用完全独立、各自使用各自的 `tmp`，只需要其一时可只调用一次。
- `i=1` 行和 `j=1` 列的结果是前缀最值（窗口不足 `big`），有效二维窗口从 `(big, big)` 位置开始。

### 复杂度分析

- **时间复杂度**：阶段一逐行处理，每行每个元素入队一次、出队一次（均摊 $O(1)$），共 $O(M \cdot N)$。阶段二逐列处理，同理 $O(M \cdot N)$。总时间复杂度为 $O(M \cdot N)$。与暴力法的 $O(M \cdot N \cdot \text{big}^2)$ 相比，当 `big` 较大时优势巨大。
- **空间复杂度**：原矩阵 $O(M \cdot N)$，临时矩阵 `tmp` $O(M \cdot N)$，行队列 $O(N)$，列队列 $O(M)$。总空间复杂度为 $O(M \cdot N)$。若允许修改原矩阵，可以省去 `tmp`，空间降为 $O(M+N)$（仅队列）。

与其他二维 RMQ 方法对比：

| 方法 | 预处理时间 | 查询时间 | 空间 | 适用场景 |
|---|---|---|---|---|
| 二维 ST 表 | $O(MN \log M \log N)$ | $O(1)$ | $O(MN \log M \log N)$ | 静态矩阵、多次任意查询 |
| 两阶段单调队列 | $O(MN)$ | 一次求出所有窗口 | $O(MN)$ | 固定窗口大小、全矩阵查询 |
| 暴力法 | - | $O(\text{big}^2)$ 每个窗口 | $O(MN)$ | 小窗口或数据量小 |

### 适用场景

固定大小的二维滑动窗口最值查询、图像卷积中的最大/最小池化（Max/Min Pooling）、矩阵中寻找满足条件的子矩形、二维直方图相关问题。特别适合"求所有 `K×K` 窗口的最值"这类输出规模为 $O(MN)$ 的问题——两阶段单调队列的总时间与输出规模同阶，是理论最优的。

### 常见陷阱与注意事项

1. **窗口不足 big 的位置**：`i < big` 或 `j < big` 的位置，`tmp[i][j]` 存储的是前缀最值（窗口大小不足 big），不是完整二维窗口的结果。使用时需注意从 `(big, big)` 开始才是有效的 `big × big` 窗口最值。
2. **cmp 的等号方向**：代码用 `<=` 和 `>=`（含等号），相等时旧元素被弹出、保留新元素。这是安全的——新元素下标更大，出窗更晚，不会导致错误。但如果用 `<` 和 `>`（不含等号），相等元素会同时保留，不影响正确性但队列可能稍长。
3. **阶段二覆盖写入的安全性**：`tmp[i][j]` 在阶段二中先读后写，因为列处理是按行从上到下的，读取时 `tmp[i][j]` 仍是阶段一的结果（尚未被覆盖）。如果改成其他顺序（如从下往上），则需要额外空间。
4. **全局变量 A**：`A` 作为全局变量被 `fn` 访问，虽然方便但不利于多线程或多次调用。若需要同时处理多个矩阵，应改为参数传递。
5. **手写队列的边界**：`x_l != x_r` 表示队列非空。`que_x[x_r-1]` 是队尾，`que_x[x_l]` 是队首。数组大小为 `N+2`，足够容纳一行所有元素（最多 $N$ 个）。
6. **big = 1 的情况**：窗口大小为 1 时，最值就是元素本身，两阶段单调队列仍正确（每个元素入队出队各一次），但有额外常数开销。可以特判优化。
7. **矩阵下标的起始**：代码从 1 开始（`1..M`, `1..N`），与 C++ 常规的 0-based 不同。使用时需注意输入输出的下标对应关系。

### 对比与扩展

与二维 ST 表相比：两阶段单调队列在固定窗口大小、全矩阵查询时更优（线性时间、更少空间），但不支持任意位置任意大小的查询。二维 ST 表预处理后支持 $O(1)$ 任意查询，但预处理和空间开销更大。选择取决于查询模式：查询次数多、窗口大小多变 → ST 表；固定窗口、全矩阵输出 → 两阶段单调队列。

扩展方向包括：① **一维单调队列**（本算法的基础，单个数组的滑动窗口最值，见「一维滑动窗口最值（单调队列基础模板）」）；② **二维单调队列的滚动优化**：若只需最后一行的结果或空间紧张，可以用滚动数组进一步压缩空间；③ **多维扩展**：三维及以上的滑动窗口最值，可以用同样的"逐维压缩"思想，$d$ 维问题做 $d$ 次一维单调队列，总时间 $O(d \cdot n^d)$；④ **带修改的动态维护**：若矩阵元素可修改，单调队列不再适用，需用线段树套线段树等高级数据结构；⑤ **单调栈求最大矩形**：与单调队列思想同源（维护单调性），用于求直方图最大矩形、二维最大全 1 子矩阵等问题。$AKB154$, '数据结构', array['数据结构', '单调队列', '滑动窗口', '双端队列', '区间最值', '基础模板'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-monostack-histogram', '栈（单调栈 / 前缀最值栈）', $AKB155$## 算法原理

单调栈是一种在栈的基础上维护**单调性**（递增或递减）的数据结构。核心思想是：当新元素破坏了栈的单调性时，弹出栈顶元素，直到栈重新满足单调性为止。每个元素最多入栈一次、出栈一次，因此总时间复杂度为 $O(n)$。

**直方图最大矩形问题**：给定 $n$ 个非负整数 $h_1, h_2, \ldots, h_n$，表示直方图中 $n$ 个宽度为 1 的柱子的高度，求能画出的最大矩形的面积。

### 核心思想

对于每个柱子 $h_i$，以它的高度作为矩形高度时，矩形能向左右扩展多远？关键在于找到 $h_i$ 两侧**第一个比 $h_i$ 矮**的柱子位置：

- **左边界** $L_i$：$h_i$ 左侧第一个高度小于 $h_i$ 的位置
- **右边界** $R_i$：$h_i$ 右侧第一个高度小于 $h_i$ 的位置
- **以 $h_i$ 为高的最大矩形面积** $= h_i \times (R_i - L_i - 1)$

单调栈（递增栈）在一次遍历中同时完成左右边界的求解：

1. 遍历每个柱子，维护一个**单调递增栈**（栈底到栈顶高度递增）
2. 当遇到比栈顶矮的柱子时，栈顶柱子的**右边界**就确定了（当前位置）
3. 弹出栈顶后，新的栈顶就是被弹柱子的**左边界**
4. 弹出时计算矩形面积并更新答案

### 两种实现风格

| | 实现A（带值栈） | 实现B（纯索引栈） |
|---|---|---|
| 栈存储内容 | 值 + 索引（`sk_num` + `sk_idx`） | 仅索引（`sk_idx`），值从原数组查询 |
| 宽度计算 | `i - sk_idx[top]`（存的就是左边界） | `i - sk_idx[newtop] - 1`（新栈顶是左边界） |
| 哨兵策略 | `init()` 在栈底放 $-10^9$ 哨兵 | 在数组末尾追加 $-10^9$ 哨兵 |
| 空栈处理 | 哨兵保证栈不为空 | 需要特判 `if (id)` 分支 |

## 数据结构图示

### 直方图示例

以数组 $h = [2, 1, 5, 6, 2, 3]$ 为例，直方图如下：

```
索引:  1   2   3   4   5   6
      ┌───┐               
      │   │       ┌───┐   
      │   │       │   │   
      │   │   ┌───┤   │   
      │   │   │   │   │   
      │   │   │   │   │   ┌───┐
      │   │   │   │   │   │   │
      └───┘   └───┘   └───┘   └───┘
高度:  2   1   5   6   2   3
```

最大矩形面积为 $10$（高度 $5$、宽度 $2$，即第 3、4 根柱子的范围）。

### 实现A 的栈状态变化

栈中存储 `(值, 索引)`，栈底有哨兵 $(-10^9, 0)$：

```
操作            栈状态（从底到顶）         弹出时计算
─────────────────────────────────────────────────────
init()         [(-1e9,0)]
add(2, 1)      [(-1e9,0), (2,1)]         无弹出
add(1, 2)      [(-1e9,0), (1,1)]         弹 (2,1): 2*(2-1)=2,  new_idx=1
add(5, 3)      [...(1,1), (5,3)]         无弹出
add(6, 4)      [...(5,3), (6,4)]         无弹出
add(2, 5)      [...(1,1), (2,3)]         弹 (6,4): 6*(5-4)=6
                                         弹 (5,3): 5*(5-3)=10  ← 最大
add(3, 6)      [...(2,3), (3,6)]         无弹出
add(-1e9, 7)   [(-1e9,0)]               弹 (3,6): 3*(7-6)=3
                                         弹 (2,3): 2*(7-3)=8
                                         弹 (1,1): 1*(7-1)=6
```

最终答案：$10$。

### 实现B 的栈状态变化

栈中仅存储索引，值从数组 $A$ 查询，数组末尾追加哨兵 $-10^9$：

```
操作            栈状态（索引）       弹出时计算
─────────────────────────────────────────────────
A = [_,2,1,5,6,2,3,-1e9]
i=1  A[1]=2    [1]                无弹出
i=2  A[2]=1    [2]                弹 idx=1: 栈空, w=2-1=1, 2*1=2
i=3  A[3]=5    [2,3]              无弹出
i=4  A[4]=6    [2,3,4]            无弹出
i=5  A[5]=2    [2,5]              弹 idx=4: 栈非空, w=5-3-1=1, 6*1=6
                                    弹 idx=3: 栈非空, w=5-2-1=2, 5*2=10  ← 最大
i=6  A[6]=3    [2,5,6]            无弹出
i=7  A[7]=-1e9 [7]               弹 idx=6: 栈非空, w=7-5-1=1, 3*1=3
                                    弹 idx=5: 栈非空, w=7-2-1=4, 2*4=8
                                    弹 idx=2: 栈空, w=7-1=6, 1*6=6
```

最终答案：$10$，与实现A 一致。

## 核心操作详解

### 初始化（实现A）

在栈底放置一个极小值哨兵 $-10^9$，保证后续 `while` 循环时栈底不会被弹出，避免空栈特判。

### 入栈 `add(x, i)`（实现A）

1. 记录 `new_idx = i`（默认左边界为当前索引）
2. **弹栈循环**：当 `x < sk_num[栈顶]` 时，弹出栈顶，计算面积 $h \times (i - \text{左边界})$，并继承被弹元素的左边界 `new_idx = sk_idx[栈顶]`
3. 入栈 `(x, new_idx)`，其中 `new_idx` 可能小于 $i$（因为继承了被弹元素的位置，表示当前柱子可以向左延伸）

### 入栈（实现B）

1. **弹栈循环**：当 `A[i] < A[sk_idx[栈顶]]` 时，弹出栈顶索引 `top_idx`，取高度 `h = A[top_idx]`
2. **宽度计算**：
   - 若栈非空：$w = i - \text{sk\_idx[新栈顶]} - 1$（新栈顶是被弹元素左侧第一个更矮的柱子）
   - 若栈空：$w = i - 1$（被弹元素可以延伸到最左边）
3. 入栈当前索引 $i$

### 终止哨兵

两种实现都在末尾追加一个极小值（$-10^9$），强制弹出栈中所有剩余元素，完成最终计算。

## 逐行代码解析

### 实现A：带值栈（`sk_num` + `sk_idx`）

```cpp
const int nmax = 1e6 + 10;
int sk_num[nmax], sk_idx[nmax], id;
// sk_num: 栈值数组（存储柱子高度）
// sk_idx: 栈索引数组（存储柱子位置 + 继承的左边界）
// id: 栈顶指针（指向下一个空位）
```

```cpp
void init()
{
    id = 0;
    sk_num[id] = -1e9;  // 哨兵：极小值，保证不被弹出
    sk_idx[id] = 0;     // 哨兵位置：0（下标从1开始，0表示左边界起点）
    ++id;               // id 现在指向位置 1
}
```

```cpp
long long add(int x, int i)
{
    long long ans = 0;
    int new_idx = i;    // 默认左边界 = 当前索引
    // 弹栈循环：当前值比栈顶小时，弹出并计算面积
    while(x < sk_num[id - 1])
    {
        // 面积 = 栈顶高度 * (当前索引 - 栈顶存储的左边界)
        ans = max(ans, (long long)sk_num[id - 1] * (i - sk_idx[id - 1]));
        new_idx = sk_idx[id - 1];  // 继承被弹元素的左边界
        --id;                      // 弹栈
    }
    sk_num[id] = x;       // 入栈：当前高度
    sk_idx[id] = new_idx; // 入栈：左边界（可能 < i，因为继承了被弹元素的位置）
    ++id;
    return ans;
}
```

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int t;
    cin >> t;
    while (t--)
    {
        int n;
        long long ans = 0;
        cin >> n;
        init();
        for (int i = 1; i <= n; i++)
        {
            int x;
            cin >> x;
            ans = max(add(x, i), ans);  // 每次入栈时更新最大面积
        }
        ans = max(add(-1e9, n + 1), ans);  // 哨兵：强制弹出所有剩余元素
        cout << ans << '\n';
    }
    return 0;
}
```

### 实现B：纯索引栈（仅 `sk_idx`）

```cpp
int sk_idx[nmax], id;  // 仅存索引，值从 A[] 查询
```

```cpp
// 主循环中直接处理
for (int i = 1; i <= n + 1; i++)  // n+1 是哨兵位置
{
    // 当 A[i] 比栈顶柱子矮时，弹出并计算面积
    while (id && A[i] < A[sk_idx[id - 1]])
    {
        int top = A[sk_idx[id - 1]];  // 被弹柱子的高度
        --id;                         // 弹栈
        if (id)                       // 栈非空：左边界 = 新栈顶索引
            ans = max((long long)(i - sk_idx[id - 1] - 1) * top, ans);
        else                          // 栈空：左边界 = 0，宽度 = i-1
            ans = max((long long)(i - 1) * top, ans);
    }
    sk_idx[id++] = i;  // 入栈当前索引
}
```

**核心差异**：

- 实现A 的 `new_idx` 机制：被弹元素的左边界被"继承"到新入栈的元素上，因此宽度计算为 $i - \text{sk\_idx[栈顶]}$（减号右边直接就是左边界）
- 实现B 的"新栈顶"机制：弹出后，新栈顶就是被弹元素左侧第一个更矮的柱子，宽度为 $i - \text{sk\_idx[新栈顶]} - 1$（需要再减 1，因为新栈顶本身不计入宽度）

## 复杂度分析

### 时间复杂度

每个元素恰好入栈一次、出栈一次，`while` 循环的总执行次数不超过 $n$ 次（均摊分析），因此总时间复杂度为 $O(n)$。

### 空间复杂度

- 栈数组 `sk_num` + `sk_idx`（或仅 `sk_idx`）：$O(n)$
- 实现B 额外使用 `vector<int> A`：$O(n)$
- 总空间复杂度：$O(n)$

## 适用场景

- **直方图最大矩形**：经典应用，求直方图中最大矩形面积
- **每日温度**：找右侧第一个更大的元素
- **接雨水**：单调栈可在 $O(n)$ 内解决
- **柱状图最大矩形扩展**：如最大子矩阵、最大全 1 子矩阵等
- **下一个更大/更小元素**：在一维序列中找每个元素右侧第一个比它大/小的元素位置

**不适用场景**：
- 需要随机访问或区间查询的问题（栈只支持栈顶操作）
- 需要动态修改后重新查询的场景（单调栈是离线结构，不支持高效修改）

## 常见陷阱与注意事项

1. **哨兵值的选择**：必须选择比所有可能的柱子高度都小的值（如 $-10^9$），否则哨兵可能被意外弹出导致错误。若柱子高度可能为 0，哨兵不能用 0。

2. **空栈特判（实现B）**：实现B 没有哨兵保护，弹出后必须检查 `if (id)` 分支处理空栈情况。忘记特判会导致宽度计算错误（访问 `sk_idx[-1]` 越界）。

3. **数据类型溢出**：面积 $h \times w$ 中，$h$ 和 $w$ 均可能达到 $10^6$，乘积达到 $10^{12}$，超过 `int` 范围。必须使用 `long long` 存储面积和答案。

4. **`new_idx` 的继承逻辑（实现A）**：`new_idx` 初始为 $i$，但在弹栈过程中不断更新为被弹元素的 `sk_idx`。这个继承机制确保了当前柱子的左边界正确延伸到被弹柱子的位置。忘记更新 `new_idx` 会导致左边界错误。

5. **宽度公式差异**：两种实现的宽度公式不同：
   - 实现A：$w = i - \text{sk\_idx[栈顶]}$（栈顶存储的就是左边界）
   - 实现B：$w = i - \text{sk\_idx[新栈顶]} - 1$（新栈顶是左边界，需减 1）

6. **下标从 1 还是 0 开始**：实现A 的哨兵 `sk_idx = 0` 表示下标从 1 开始，位置 0 是左边界起点。如果改用 0-indexed，需要相应调整哨兵位置和宽度公式。

## 对比与扩展

### 两种实现对比

| 维度 | 实现A（带值栈） | 实现B（纯索引栈） |
|---|---|---|
| 空间 | 2 个数组 | 1 个数组 + 原数组 |
| 哨策略 | `init()` 在栈底放哨兵 | 数组末尾追加哨兵值 |
| 空栈处理 | 哨兵保证永不出栈 | 需 `if (id)` 特判 |
| 宽度公式 | $i - \text{左边界}$（直接） | $i - \text{新栈顶} - 1$（间接） |
| `new_idx` | 需要，维护继承关系 | 不需要，查询原数组即可 |
| 可读性 | 逻辑更显式 | 代码更简洁 |
| 通用性 | 适合不需要保留原数组的场景 | 适合已有原数组的场景 |

### 与其他数据结构对比

| 数据结构 | 适用问题 | 时间复杂度 | 与单调栈的关系 |
|---|---|---|---|
| 单调栈 | 找两侧第一个更小/大元素 | $O(n)$ | — |
| 单调队列 | 滑动窗口最值 | $O(n)$ | 均维护单调性，队列支持尾部弹出（滑动窗口） |
| ST 表 | 静态区间最值 | $O(n \log n)$ 预处理 + $O(1)$ 查询 | ST 表支持任意区间查询，但不支持在线性时间找"第一个更小" |
| 对顶堆 | 动态第 $k$ 小 | $O(\log n)$ 单次 | 对顶堆维护动态集合，单调栈是一次性离线处理 |
| 前缀最值栈 | 栈内最大值查询 | $O(1)$ 单次 | 前缀最值栈是单调栈的特例（只维护前缀 max，不需要弹出时计算） |

### 扩展

- **二进制优化单调栈**：对于重复询问的场景，可以用倍增预处理单调栈的跳跃指针，实现 $O(1)$ 查询"跳过多少个更矮的柱子"
- **二维扩展**：将直方图最大矩形扩展到矩阵中的最大全 1 子矩阵，对每一行枚举"以该行为底的高度"后转化为直方图问题
- **单调栈 + 离线**：将询问按位置排序，用单调栈在线性时间内回答所有"右侧第一个更大元素"类询问

## 附：前缀最值栈（栈内最大值查询）

前缀最值栈是在普通栈的基础上，额外维护一个辅助数组 `sk_big`，其中 `sk_big[i]` 记录从栈底到第 $i$ 个位置的元素最大值。这样不仅入栈、出栈均为 $O(1)$，还能 $O(1)$ 查询栈内当前所有元素的最大值。

#### 核心思想

普通栈只能 $O(1)$ 访问栈顶元素，查询栈内最大值需要遍历整个栈（$O(n)$）。前缀最值栈的关键观察是：

- **入栈时**：新元素 $x$ 入栈后，栈内最大值要么不变（$x \le$ 之前的最大值），要么更新为 $x$（$x >$ 之前的最大值）。即 $\text{sk\_big}[id] = \max(\text{sk\_big}[id-1], x)$
- **出栈时**：弹出栈顶只需将指针前移一位，`sk_big` 自动回到上一个位置的最大值，无需任何额外操作

这一思路本质上是"前缀和"思想在栈上的推广——不是求和，而是求前缀最大值。

#### 核心不变量

1. `sk_num[i]` 存储第 $i$ 个入栈的元素（$i$ 从 $0$ 开始）
2. `sk_big[i]` 存储从栈底到位置 $i$ 的所有元素最大值
3. `id` 指向栈顶的下一个空位，栈顶元素是 `sk_num[id - 1]`，栈内最大值是 `sk_big[id - 1]`

### 数据结构图示

#### 整体结构

```
  sk_num (元素栈)        sk_big (前缀最大值栈)
  ───────────────         ───────────────────
  索引  值                索引  值
  ┌───┬───┐              ┌───┬───┐
  │ 0 │ 3 │ ← 栈底        │ 0 │ 3 │ ← max(3) = 3
  │ 1 │ 1 │              │ 1 │ 3 │ ← max(3,1) = 3
  │ 2 │ 4 │ ← 栈顶        │ 2 │ 4 │ ← max(3,1,4) = 4
  └───┴───┘              └───┴───┘
         ↑                        ↑
        id = 3                   id = 3

  栈顶元素 = sk_num[id-1] = sk_num[2] = 4
  栈内最大 = sk_big[id-1] = sk_big[2] = 4
```

#### 操作过程示意

以依次入栈 $3, 1, 4$，再出栈一次为例：

```
入栈 3:
  sk_num: [3]          sk_big: [3]          id = 1
  sk_big[0] = 3（首个元素，直接赋值）

入栈 1:
  sk_num: [3, 1]       sk_big: [3, 3]       id = 2
  sk_big[1] = max(sk_big[0], 1) = max(3, 1) = 3

入栈 4:
  sk_num: [3, 1, 4]    sk_big: [3, 3, 4]    id = 3
  sk_big[2] = max(sk_big[1], 4) = max(3, 4) = 4

查询: 栈顶 = sk_num[2] = 4, 最大值 = sk_big[2] = 4  ✓

出栈 (--id):
  sk_num: [3, 1, 4]    sk_big: [3, 3, 4]    id = 2
  （数据仍在内存中，但 id 前移，逻辑上栈只有 [3, 1]）

查询: 栈顶 = sk_num[1] = 1, 最大值 = sk_big[1] = 3  ✓
  （最大值是 3，不是已"删除"的 4）
```

#### 出栈恢复特性

```
出栈前: sk_big: [3, 3, 4]  id = 3  最大值 = 4
出栈后: sk_big: [3, 3, 4]  id = 2  最大值 = 3

sk_big[1] = 3 自动成为新的最大值，无需重新计算。
这是因为 sk_big[i] 本身就记录了"从栈底到位置 i 的最大值"，
出栈只是缩小了有效范围，前缀最大值自动回退。
```

### 核心操作详解

#### 1. 入栈 `push(x)`

```cpp
sk_num[id] = x;
if (id > 0) sk_big[id] = max(sk_big[id - 1], x);
else sk_big[id] = x;
++id;
```

- 将 $x$ 存入 `sk_num[id]`
- 若栈非空（`id > 0`），`sk_big[id]` 取前一个位置的最大值与 $x$ 的较大者
- 若栈为空（`id == 0`），`sk_big[0]` 直接等于 $x$（第一个元素）
- 指针 `id` 后移一位

#### 2. 出栈 `pop()`

```cpp
--id;
```

仅将指针 `id` 前移一位。`sk_num` 和 `sk_big` 中的数据仍在内存中，但逻辑上已不属于栈。下一次入栈会覆盖这些位置。出栈后，新的栈内最大值自动变为 `sk_big[id - 1]`，无需任何计算。

#### 3. 查询栈顶

```cpp
sk_num[id - 1]
```

$O(1)$ 读取栈顶元素。

#### 4. 查询栈内最大值

```cpp
sk_big[id - 1]
```

$O(1)$ 读取前缀最大值数组的栈顶位置。由于 `sk_big[i]` 记录了从栈底到位置 $i$ 的最大值，`sk_big[id - 1]` 就是当前栈内所有元素的最大值。

### 逐行代码解析

以下按模块拆分完整实现，各代码块按顺序拼接后与 `.cpp` 完全一致。

#### 全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
const int nmax = 1e5;                 // 统一管理数组大小
int sk_num[nmax], sk_big[nmax];       // 元素栈 / 前缀最大值栈
int id = 0;                           // 栈指针，指向栈顶的下一个空位
```

- `sk_num`：元素栈，存储实际入栈的值；`sk_big`：前缀最大值栈，`sk_big[i]` = 从栈底到位置 $i$ 的元素最大值
- `id`：栈指针，指向栈顶的下一个空位，初始为 0 表示空栈
- `nmax = 1e5` 统一管理数组大小，最多支持 $10^5$ 次入栈；操作数更多时需调大或改用 `vector` 动态扩容

#### main 与读入

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int t;
	cin >> t;
	while (t--)
	{
		int op;
		cin >> op;
```

- `ios::sync_with_stdio(false)` 关闭与 C 标准 IO 的同步，`cin.tie(nullptr)` 解绑，加速读入
- 读入操作次数 $t$，每次循环读入一个操作类型 `op`，按 `1` 入栈 / `2` 出栈 / `3` 查询进入不同分支

#### 入栈操作（op == 1）

```cpp
		if (op == 1)
		{
			int x;
			cin >> x;
			sk_num[id] = x;                                    // 存入元素栈
			if (id > 0) sk_big[id] = max(sk_big[id - 1], x);   // 非空：与上一个前缀最大值比较
			else sk_big[id] = x;                               // 空栈：直接赋值
			++id;                                              // 指针后移
		}
```

- 把 $x$ 存入 `sk_num[id]`；栈非空时 `sk_big[id] = max(sk_big[id-1], x)`，栈空时 `sk_big[id] = x`
- 必须与 `sk_big[id-1]`（前一个位置的前缀最大值）比较，不能误写为 `sk_num[id-1]`（前一个元素）
- 最后 `++id` 后移指针；此处未检查 `id < nmax`，入栈超过 $10^5$ 次会越界

#### 出栈操作（op == 2）

```cpp
		else if (op == 2) --id;
```

- 仅 `--id` 前移指针，逻辑上弹出栈顶；旧数据仍留内存，下次入栈会覆盖
- 出栈后栈内最大值自动回退为 `sk_big[id-1]`，无需重新计算
- 未检查 `id > 0`，空栈出栈会使 `id` 变负，后续查询会越界

#### 查询操作（op == 3）与收尾

```cpp
		else if (op == 3)
		{
			cout << "当前栈顶元素为: " << sk_num[id - 1] << '\n';
			cout << "栈内最大元素为: " << sk_big[id - 1] << '\n';
		}
	}
	return 0;
}
```

- 栈顶元素 = `sk_num[id-1]`，栈内最大值 = `sk_big[id-1]`，均为 $O(1)$ 直接索引
- 未检查 `id > 0`，空栈查询会访问 `sk_num[-1]` 越界
- 末尾的 `}` 依次收尾 while 循环与 main 函数，`return 0;` 正常结束

### 复杂度分析

| 操作 | 时间 | 空间 | 说明 |
|---|---|---|---|
| 入栈 | $O(1)$ | $O(1)$ | 一次赋值 $+$ 一次 `max` $+$ 指针自增 |
| 出栈 | $O(1)$ | $O(0)$ | 仅指针自减 |
| 查询栈顶 | $O(1)$ | $O(0)$ | 数组直接索引 |
| 查询最大值 | $O(1)$ | $O(0)$ | 前缀最大值数组直接索引 |
| 总空间 | — | $O(n)$ | 两个数组各 $n$ 个元素 |

所有操作均为 $O(1)$，空间 $O(n)$。与朴素做法（每次查询遍历栈，$O(n)$）相比，用空间换时间，将最值查询从 $O(n)$ 降为 $O(1)$。

### 适用场景

**适用**：
- 需要在栈操作的同时查询栈内最值（最大值或最小值）
- 括号匹配、表达式求值等需要回溯的场景，同时需要跟踪最值
- 滑动窗口类问题中栈结构的变体
- 单调栈问题的辅助分析

**不适用**：
- 需要查询区间最值（非栈内最值）：应使用 ST 表或线段树
- 需要查询第 $k$ 大/小：应使用对顶堆或平衡树
- 元素需要随机访问或中间插入/删除：应使用平衡树或链表
- 需要维护最小值而非最大值：将 `max` 改为 `min` 即可，原理相同

### 常见陷阱与注意事项

1. **空栈越界**
   - 出栈时若栈已空（`id == 0`），`--id` 会使 `id` 变为 $-1$，后续访问 `sk_num[id-1]` 越界
   - 查询时若栈空，`sk_num[id-1]` = `sk_num[-1]` 越界
   - 应在出栈和查询前检查 `id > 0`

2. **数组大小不足**
   - `nmax = 1e5` 仅支持 $10^5$ 次入栈，若操作次数更多需调大
   - 建议用 `const int nmax` 统一管理，或改用 `vector` 动态扩容

3. **前缀最值的维护方向**
   - `sk_big[i]` 是从栈底到位置 $i$ 的最大值，不是从位置 $i$ 到栈顶的最大值
   - 入栈时必须与 `sk_big[id-1]`（前一个位置的最大值）比较，不能与 `sk_num[id-1]`（前一个元素的值）比较

4. **出栈后数据残留**
   - 出栈只是移动 `id` 指针，`sk_num` 和 `sk_big` 中的旧数据仍在内存
   - 若入栈次数少于之前的最大 `id`，不会有问题（新数据会覆盖）
   - 但若在入栈前查询了尚未覆盖的位置，会读到旧数据——因此查询始终用 `sk_big[id-1]`

5. **`max` 与 `min` 的选择**
   - 维护最大值用 `max`，维护最小值用 `min`
   - 若需要同时维护最大值和最小值，开三个数组：`sk_num`、`sk_big`（前缀 max）、`sk_sml`（前缀 min）

### 对比与扩展

| 对比维度 | 前缀最值栈 | 朴素栈 | 单调栈 | 对顶堆 |
|---|---|---|---|---|
| 入栈 | $O(1)$ | $O(1)$ | $O(1)$ 均摊 | $O(\log n)$ |
| 出栈 | $O(1)$ | $O(1)$ | $O(1)$ 均摊 | $O(\log n)$ |
| 查询最值 | $O(1)$ | $O(n)$ | $O(1)$（栈顶） | $O(1)$ |
| 维护内容 | 栈内全局最值 | 仅栈顶 | 单调性（局部最值） | 第 $k$ 小 |
| 支持随机删除 | 否 | 否 | 否 | 否 |
| 空间 | $O(n)$ | $O(n)$ | $O(n)$ | $O(n)$ |
| 实现难度 | 低 | 最低 | 中 | 低 |

**扩展**：
- **双辅助数组**：同时维护 `sk_big`（前缀 max）和 `sk_sml`（前缀 min），即可 $O(1)$ 查询栈内最大值和最小值
- **前缀和栈**：类似地，维护 `sk_sum[i]` = 从栈底到位置 $i$ 的元素之和，可 $O(1)$ 查询栈内元素总和
- **多维辅助信息**：可以同时维护最值、求和、异或和等多种前缀信息，每次入栈只需 $O(1)$ 更新
- **与单调栈的区别**：前缀最值栈维护的是"栈内全局最值"，单调栈维护的是"从栈底到栈顶的单调性"——两者目的不同，单调栈用于解决"下一个更大/更小元素"类问题
- **与对顶堆的关系**：对顶堆用两个堆维护第 $k$ 小，前缀最值栈用一个辅助数组维护最值，都是"用额外空间换取查询效率"的思路$AKB155$, '数据结构', array['数据结构', '单调栈', '栈', '直方图', '最大矩形'], null, null, 'knowledge'),
('Fohen', 'col-ds-odt--fenfeng', '珂朵莉树（ODT） · Fohen', $AKB156$## 算法原理

珂朵莉树（Old Driver Tree，ODT）得名于 Codeforces 896C 题面中的人物珂朵莉。它常被称为"骗分神器"：本质是一种基于 `set` 的暴力区间维护结构，核心思想非常质朴——把值相同的一段连续下标合并成一个三元组 $(l, r, v)$，统一放进 `set` 中维护。

这种结构之所以成立，关键在于题目需要同时满足两个前提：**存在"区间赋值 / 区间推平"（assign）操作**，且**数据具有一定随机性**。

- **为什么快**：每次 assign 都会把 $[l,r]$ 内大量零碎的区间删除、合并成一个大区间，使 `set` 中的区间段数急剧下降。在操作随机分布的前提下，`set` 内的平均区间数量可以维持在 $O(\log n)$ 级别。
- **为什么好用**：每个节点是一个具象的区间 $[l, r, v]$，面对"区间第 $k$ 小""区间 $k$ 次方和"这类线段树极难维护的操作，珂朵莉树只需要暴力遍历对应的区间段即可，几乎零思考成本。
- **风险所在**：如果出题人构造特殊数据（例如完全没有推平操作，或反复在单点位置交替修改使区间碎裂），区间数量会退化到 $O(n)$，单次操作退化为 $O(n)$，整体退化为 $O(n^2)$，极易被卡常或 TLE。

## 核心公式 / 状态定义与转移方程

**状态定义**：珂朵莉树把下标区间 $[1, n]$ 划分成若干互不相交的连续段，每个段用一个三元组 $(l, r, v)$ 表示，含义是"下标 $l$ 到 $r$ 的所有元素值都等于 $v$"。整棵树即一个 `set<Node>`，所有段按左端点 $l$ 严格递增排列，并始终覆盖 $[1, n]$。任意两个相邻段的值都不相同，否则它们本应被合并成一个段——这是"按值合并"这一核心思想的不变量。

**split 的分裂转移**（把包含 $pos$ 的段切开，返回以 $pos$ 为左端点的段）：

$$[l,\ r,\ v]\ \xrightarrow{\ \mathrm{split}(pos)\ }\ [l,\ pos-1,\ v]\ \cup\ [pos,\ r,\ v]$$

**assign 的推平转移**（把 $[l, r]$ 内所有段替换为单一区间）：

$$\mathrm{assign}(l,\ r,\ x):\quad [l,\ r]\ \text{内所有段}\ \longrightarrow\ [l,\ r,\ x]$$

**区间 $k$ 次方和（模 $M$）的统计**：利用"同段同值"把逐点累加折叠成逐段累加，每段只需算一次幂再乘段长：

$$S = \sum_{[L,R,v]} (R-L+1)\cdot v^{ex},\qquad \text{答案为}\ S \bmod M$$

## 逐行代码解析

### 节点定义与 set 容器（含初始化）

```cpp
struct Node {
    int l, r;
    mutable long long v;

    bool operator<(const Node &other) const {
        return l < other.l;
    }
};

set<Node> odt;

// 最简单的单点装入初始化
for (int i = 1; i <= n; ++i) {
    odt.insert({i, i, a[i]});
}
```

- `Node` 记录区间左端点 `l`、右端点 `r` 与公共权值 `v`；重载 `operator<` 只按 `l` 比较，使 `set` 按左端点有序。
- `v` 声明为 `mutable long long`：`set` 的元素是只读的，直接通过迭代器改 `v` 会编译报错，`mutable` 允许在只读上下文中修改该成员。
- 初始化把每个位置 $i$ 单独作为一个区间 `{i, i, a[i]}` 插入，形成 $n$ 个单点区间；单次插入 $O(\log n)$，共 $O(n\log n)$。

### split：区间分裂

```cpp
auto split(int pos) {
    if (pos > n) return odt.end();

    // 找到第一个左端点 >= pos 的区间
    auto it = odt.lower_bound({pos, -1, 0});
    if (it != odt.end() && it->l == pos) {
        return it;
    }

    // 真正的目标区间在 it 的前一个
    --it;
    int l = it->l, r = it->r;
    long long v = it->v;

    // 先删除原区间，再插入切分后的两个区间
    odt.erase(it);
    odt.insert({l, pos - 1, v});
    return odt.insert({pos, r, v}).first;
}
```

- `pos > n` 时越界，直接返回 `end()` 作为哨兵，避免对 `end()` 做 `--`。
- `lower_bound({pos, -1, 0})` 找到第一个 `l >= pos` 的区间；若其 `l` 恰好等于 `pos`，说明该区间已以 `pos` 为左端点，直接返回。
- 否则包含 `pos` 的区间在 `it` 前一个，`--it` 后取出原 `[l, r, v]`；先 `erase` 原区间，再插入 `[l, pos-1, v]` 与 `[pos, r, v]`。
- `insert` 返回 `pair<iterator, bool>`，`.first` 是插入元素的迭代器，正是以 `pos` 为左端点的新区间。

### assign：区间推平

```cpp
void assign(int l, int r, long long x) {
    auto itr = split(r + 1);
    auto itl = split(l);

    // 删除 [itl, itr) 内的所有旧区间
    odt.erase(itl, itr);

    // 插入合并后的大区间
    odt.insert({l, r, x});
}
```

- 必须"先 `split(r + 1)` 再 `split(l)`"：若先切 $l$，返回的 `itl` 可能在后续 `split(r + 1)` 时因所属区间被删除、重构而失效，导致 RE。
- `split(r + 1)` 保证 $r$ 恰好是某区间的右端点，`split(l)` 保证 $l$ 恰好是某区间的左端点，于是 `[itl, itr)` 精确覆盖 $[l, r]$。
- `erase(itl, itr)` 删除左闭右开区间内的所有旧段，再插入合并后的大区间 `[l, r, x]`。

### add：区间加

```cpp
void add(int l, int r, long long val) {
    auto itr = split(r + 1);
    auto itl = split(l);

    for (auto it = itl; it != itr; ++it) {
        it->v += val; // 由于使用了 mutable，可以直接修改
    }
}
```

- 同样先切出 `[itl, itr)`，再暴力遍历其中每个区间段，把公共权值整体加 `val`。
- 直接 `it->v += val` 依赖 `mutable`；没有 `mutable` 时需先取出值、`erase` 旧段再 `insert` 新值。

### query_kth：区间第 k 小

```cpp
long long query_kth(int l, int r, int k) {
    auto itr = split(r + 1);
    auto itl = split(l);

    vector<pair<long long, int>> elements;
    for (auto it = itl; it != itr; ++it) {
        elements.push_back({it->v, it->r - it->l + 1});
    }

    sort(elements.begin(), elements.end());

    for (auto &[val, cnt] : elements) {
        k -= cnt;
        if (k <= 0) return val;
    }
    return -1;
}
```

- 把 $[l, r]$ 内的每个段 `(值, 长度)` 收集进 `vector`，按值排序后即为升序。
- 逐个段累加长度，当 `k` 减到 $\le 0$ 时，当前段的值就是第 $k$ 小。
- `return -1` 是 `k` 超过区间长度时的哨兵，正常 $k$ 不会走到。

### query_power_sum：区间 k 次方和

```cpp
long long query_power_sum(int l, int r, long long ex, long long mod) {
    auto itr = split(r + 1);
    auto itl = split(l);

    long long sum = 0;
    for (auto it = itl; it != itr; ++it) {
        long long len = it->r - it->l + 1;
        sum = (sum + len * qpow(it->v % mod, ex, mod)) % mod;
    }
    return sum;
}
```

- 每个段的贡献是"段长 × 段值 $ex$ 次方"，因为段内所有元素值相同，只需算一次幂再乘长度。
- `qpow` 是外部快速幂函数，负责算 `base^ex mod mod`；`it->v` 先 `% mod` 再求幂，防止溢出。
- 累加时随时 `% mod`，保持 `sum` 不溢出。

## 复杂度分析

**时间复杂度**：

- 初始化：把 $n$ 个单点区间逐个插入 `set`，每次 $O(\log n)$，共 $O(n\log n)$。
- 单次 `split`：两次 `lower_bound` / `insert`，均为 $O(\log n)$，故 $O(\log n)$。
- 单次 `assign`：两次 `split` 加一次 `erase(itl, itr)` 与一次 `insert`，为 $O(\log n + \text{被删段数})$。
- 随机数据下：每次 assign 会把大量小段合并，`set` 内段数始终维持在期望 $O(\log n)$（源资料亦给出 $O(\log\log n)$ 的提法），因此单次操作期望 $O(\log n)$。
- 最坏情况：构造数据使段数退化到 $O(n)$，单次操作 $O(n)$，$q$ 次操作整体 $O(nq)$；当 $q$ 与 $n$ 同阶时为 $O(n^2)$。

**空间复杂度**：`set` 中最多同时存在 $O(n)$ 个区间段，每个段存一个 `Node`，故为 $O(n)$。

## 适用场景

珂朵莉树适合两类题目：一类是明确包含"区间赋值 / 区间推平"操作、且数据随机或部分分不卡的题（典型代表是 CF896C 原题）；另一类是需要在短时间内"骗"到部分分的场合。

- **适合**：频繁区间推平 + 随机数据；需要维护"区间第 $k$ 小""区间 $k$ 次方和""区间加"等组合操作但数据不强；追求实现简单、十几行搞定。
- **不适合**：完全没有 assign 操作（段数无法被压缩）；出题人构造了反复在单点位置交替修改的数据；正赛强数据且要求严格复杂度保证。此时应改用线段树 / 平衡树 / 分块等有确定复杂度的结构。

## 常见陷阱与注意事项

1. **split 的调用顺序**：assign、add、查询中必须**先 `split(r + 1)` 再 `split(l)`**。若先切 $l$，返回的 `itl` 会在后续 `split(r + 1)` 时因所属区间被删除、重构而失效，引发未定义行为（常见 RE）。
2. **`mutable` 不能省**：`set` 的迭代器解引用得到的是 `const Node&`，直接写 `it->v = ...` 会编译失败；`mutable long long v` 正是为了允许在只读上下文中修改 $v$。
3. **`operator<` 只按 `l` 比较**：若同时比较 $r$ 或 $v$，`set` 的去重语义会被破坏，导致区间合并出错。
4. **`lower_bound({pos, -1, 0})` 的临时对象**：用 `-1`、`0` 占位 $r$、$v$ 不影响"按 $l$ 查找"，因为比较只看 `l`。
5. **退化风险**：没有推平保证或遇到构造数据时会退化到 $O(n^2)$，不要把珂朵莉树当作唯一正解提交。
6. **溢出与外部依赖**：`add` 累加后 $v$ 可能超出 `int`，故 $v$ 用 `long long`；`query_power_sum` 依赖外部快速幂 `qpow(base, ex, mod)`，需自行定义，且先 `it->v % mod` 再求幂防止溢出。

## 对比与扩展

- **与线段树对比**：线段树维护的是树形递归区间，修改/查询均为严格的 $O(\log n)$，不依赖随机性；珂朵莉树依赖"随机 + 推平"，复杂度是期望意义下的，最坏 $O(n)$，但代码量少得多，且能轻松维护线段树很难维护的"区间第 $k$ 小""区间 $k$ 次方和"。
- **与分块对比**：分块单次 $O(\sqrt n)$ 是确定的、无退化；珂朵莉树在随机数据下往往更快（期望 $O(\log n)$），但没有保证。
- **与平衡树维护区间对比**：珂朵莉树本质是"按值合并的区间集合"，与 `set` / 平衡树维护的"区间"是同一类思想，只是珂朵莉树把合并后的同值段作为一个整体节点，省去了维护平衡的负担。
- **扩展方向**：CF896C 是珂朵莉树的源头例题；珂朵莉树也常与线段树、树状数组配合处理更复杂的区间信息，另有"可持久化珂朵莉树"的讨论（不常见，主要停留在概念层面）。$AKB156$, '数据结构', array['数据结构', '珂朵莉树', 'ODT', '区间推平', '随机化', '暴力'], 'col-ds-other-overview', null, 'knowledge'),
('Xesir', 'col-ds-odt--xesir', '珂朵莉树（ODT） · Xesir', $AKB157$## 算法原理

珂朵莉树起源于 Codeforces 896C，因题面背景中的人物珂朵莉而得名。~~名称诡异程度堪比主席树~~

在 OI 圈中，它常被称为「**骗分神器**」。它是基于一些关联式容器（如 `set`）的**暴力区间维护结构**，本质非常质朴，即**将值相同的一整段连续下标合并为一个三元组 $[l,r,v]$**，统一放进 `set` 中维护。

它的关键前提是：**题目中包含「区间赋值 / 区间推平」（assign）操作，且数据具有一定随机性**。

- **为什么快**：每次区间赋值都会把大量零碎的区间删掉，合并为一个大区间，从而使得 `set` 中的区间段数急剧减少。可以证明，在操作随机分布的前提下，`set` 内的平均区间数量仅为 $O(\log n)$ 级别。
- **通用性极强**：由于每个节点是一个具象的区间 $[l,r,v]$，面对求区间第 $k$ 小、区间 $x$ 次方和等线段树极难维护的「诡异操作」，珂朵莉树只需要暴力遍历对应区间段，写起来几乎零思考成本。
- **缺点与不适用性**：如果出题人构造特殊数据（例如完全没有推平操作，或者反复在单点位置交替修改使区间碎裂），区间的数量将退化至 $O(n)$，单次操作退化为 $O(n)$，整体复杂度变为 $O(n^2)$。因此对于没有随机保证或无区间推平的正赛题，直接使用有被卡常或 TLE 的风险。所以一般不要考虑将珂朵莉树作为唯一正解。

## 逐行代码解析

### 模块一：节点定义与初始化

每个节点记录区间的左端点 $l$、右端点 $r$ 以及区间内的公共权值 $v$。为了能在 `set` 中快速按区间左端点查找，重载小于号按 $l$ 排序。

```cpp
struct Node {
    int l, r;
    mutable long long v;

    bool operator<(const Node &other) const {
        return l < other.l;
    }
};

set<Node> odt;
```

权值成员变量通常需要加上 `mutable` 关键字，这样在遍历 `set` 的迭代器为只读（`const`）时，依然可以直接修改节点的值而无需先删除再插入。

初始时，可以把每个元素都单独作为一个区间插入：

```cpp
// 最简单的单点装入初始化
for (int i = 1; i <= n; ++i) {
    odt.insert({i, i, a[i]});
}
```

### 模块二：`split`（区间分裂）

`split(pos)` 的含义是：找到包含位置 $pos$ 的那个区间 $[l,r,v]$，将其切分为两个独立的子区间：

$$
[l,\ pos-1,\ v]\quad\text{与}\quad[pos,\ r,\ v]
$$

并返回以 $pos$ 为左端点的那个区间的迭代器。这是后续一切区间操作的基石。

```cpp
auto split(int pos) {
    if (pos > n) return odt.end();

    // 找到第一个左端点 >= pos 的区间
    auto it = odt.lower_bound({pos, -1, 0});
    if (it != odt.end() && it->l == pos) {
        return it;
    }

    // 真正的目标区间在 it 的前一个
    --it;
    int l = it->l, r = it->r;
    long long v = it->v;

    // 先删除原区间，再插入切分后的两个区间
    odt.erase(it);
    odt.insert({l, pos - 1, v});
    return odt.insert({pos, r, v}).first;
}
```

`lower_bound` 按左端点找到第一个 $\ge pos$ 的区间；如果它的左端点正好等于 `pos`，说明不需要切。否则目标区间在它前面一个，取出后删掉，再插入 `[l, pos-1]` 和 `[pos, r]` 两段，返回后者的迭代器。

### 模块三：`assign`（区间推平）

区间赋值是将 $[l,r]$ 内的所有数全部变成 $x$。

```cpp
void assign(int l, int r, long long x) {
    auto itr = split(r + 1);
    auto itl = split(l);

    // 删除 [itl, itr) 内的所有旧区间
    odt.erase(itl, itr);

    // 插入合并后的大区间
    odt.insert({l, r, x});
}
```

**非常关键的代码细节**：在调用 `split` 截取边界时，**必须先 `split(r + 1)`，再 `split(l)`**。如果先切 $l$，返回的迭代器可能会在后续切 $r+1$ 时因为所属区间的删除与重构而失效，引发未定义行为（RE）。

### 模块四：其他操作的暴力实现

只要把边界分出来，剩下的操作直接拿迭代器从 `itl` 遍历到 `itr` 暴力统计。

```cpp
void add(int l, int r, long long val) {
    auto itr = split(r + 1);
    auto itl = split(l);

    for (auto it = itl; it != itr; ++it) {
        it->v += val; // 由于使用了 mutable，可以直接修改
    }
}
```

区间第 $k$ 小则把涉及的每个段的信息取出塞进 `vector`，按值排序后累加元素个数：

```cpp
long long query_kth(int l, int r, int k) {
    auto itr = split(r + 1);
    auto itl = split(l);

    vector<pair<long long, int>> elements;
    for (auto it = itl; it != itr; ++it) {
        elements.push_back({it->v, it->r - it->l + 1});
    }

    sort(elements.begin(), elements.end());

    for (auto &[val, cnt] : elements) {
        k -= cnt;
        if (k <= 0) return val;
    }
    return -1;
}
```

区间 $k$ 次方和同理，遍历每一段，把「段长 $\times$ 段值的 $k$ 次方」累加（原文调用了 `qpow` 快速幂，该函数未在本节给出）：

```cpp
long long query_power_sum(int l, int r, long long ex, long long mod) {
    auto itr = split(r + 1);
    auto itl = split(l);

    long long sum = 0;
    for (auto it = itl; it != itr; ++it) {
        long long len = it->r - it->l + 1;
        sum = (sum + len * qpow(it->v % mod, ex, mod)) % mod;
    }
    return sum;
}
```

## 复杂度分析

- 在纯随机数据下，每次操作的期望时间复杂度为 $O(\log\log n)$ 或 $O(\log n)$。
- 每次 `split` 是一次 `set` 的 `lower_bound` 加至多两次插入/删除，单次 $O(\log n)$；暴力遍历的段数取决于当前 `set` 中的区间数量。
- 没有推平操作、或数据被刻意构造使区间碎裂时，区间数量退化至 $O(n)$，单次操作退化为 $O(n)$，整体复杂度变为 $O(n^2)$。
- 空间：`set` 中至多 $O(n)$ 个区间，$O(n)$。

## 适用场景

- 题目里有**区间赋值 / 区间推平**，且数据随机或部分分保证随机。
- 需要维护的操作花里胡哨（区间第 $k$ 小、区间 $k$ 次方和、区间加），线段树标记推不动，但暴力遍历区间段就能算。
- 赛场时间紧张，想先写一个不到 40 行的珂朵莉树骗到大部分甚至全部分数。
- **不适合**：没有推平操作、数据不随机、或者要求严格复杂度的正赛题。

珂朵莉树的核心魅力在于：**将线段树需要耗费巨大心力去推导、打标记的高难度操作，退化为人类最直观的暴力迭代**。

## 常见陷阱与注意事项

- `assign` / `add` 等区间操作必须**先 `split(r + 1)` 再 `split(l)`**，顺序反了迭代器会失效。
- `v` 要加 `mutable`，否则通过迭代器改不了值，只能删了重插。
- `split` 中 `pos > n` 要返回 `end()`；`lower_bound({pos, -1, 0})` 的临时节点只用于比较左端点。
- `erase(itl, itr)` 是左闭右开，右边界必须是 `split(r+1)` 得到的迭代器。
- 初始时如果每个元素单独成段，`set` 大小为 $n$；没有推平操作时它不会自动变小。
- 区间第 $k$ 小要用「段值 + 段长」排序累加，不能把每段只当一个元素。
- 数据不随机时复杂度会退化到 $O(n^2)$，别把它当唯一正解。$AKB157$, '数据结构', array['数据结构', '珂朵莉树', 'ODT', '区间推平', '随机数据', '暴力'], 'col-ds-other-overview', null, 'knowledge'),
('stripe-python', 'col-ds-offline-2d-count--stripe-python', '离线二维数点 · stripe-python', $AKB158$> 本文由 stripe-python 授权合并，保留原文结构与表述。
最近 % 你赛出了好几个这样的问题。

## 算法思想

将询问离线，按一个端点排序，用另一维作扫描线统计答案。统计时，按题目选择权值 / 序列树状数组或线段树，复杂度为 $O(n\log n)$ 级别。

## 例题

## P10814 【模板】离线二维数点

板子题。注意到 $ans_{l,r}=ans_{1,r}-ans_{1,l-1}$，考虑对每个前缀 $[1,x]$ 统计答案。按 $x$ 排序，此时询问有序，类似双指针地顺次加点，则只需要统计当前 $\le num$ 的个数。使用**权值树状数组**。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 2e6 + 5;

int n, m, l, r, x, a[N], ans[N];
int tot;
struct node {
	int x, num, id, typ;
	bool operator< (const node& a) const {return x < a.x;}
} q[N << 1];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {for (; x < N; x += lowbit(x)) tr[x] += c;}
int ask(int x) {int res = 0; for (; x; x -= lowbit(x)) res += tr[x]; return res;}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= m; i++) {
		cin >> l >> r >> x;
		q[++tot] = node{l - 1, x, i, -1};
		q[++tot] = node{r, x, i, 1};
	}
	sort(q + 1, q + tot + 1);
	for (int i = 1, j = 1; i <= tot; i++) {
		for (; j <= q[i].x; j++) add(a[j], 1);
		ans[q[i].id] += q[i].typ * ask(q[i].num);
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P2163 [SHOI2007] 园丁的烦恼

类板子题的二维版本。由二维前缀和，有

$q(x_1,y_1,x_2,y_2)=ans_{x_2,y_2}-ans_{x_1-1,y_2}-ans_{x_2,y_1-1}+ans_{x_1-1,y_1-1}$于是拆成四段，转化为二维数点问题。仍然使用**权值树状数组**。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 5e5 + 5, M = 1e7 + 5;

int n, m, tot, ans[N];
struct pos {
	int x, y;
	bool operator< (const pos& x) const {return y < x.y;}
} a[N];
struct node {
	int r, l, id, typ;
	bool operator< (const node& x) const {return l < x.l;}
} q[N << 2];

int tr[M];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {for (; x < M; x += lowbit(x)) tr[x] += c;}
int ask(int x) {int res = 0; for (; x >= 1; x -= lowbit(x)) res += tr[x]; return res;}

void _main() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) cin >> a[i].x >> a[i].y;
	for (int i = 1; i <= m; i++) {
		int x1, y1, x2, y2;
		cin >> x1 >> y1 >> x2 >> y2;
		//x1++, y1++, x2++, y2++;
		q[++tot] = node{x2, y2, i, 1};
		if (x1 >= 1) q[++tot] = node{x1 - 1, y2, i, -1};
		if (y1 >= 1) q[++tot] = node{x2, y1 - 1, i, -1};
		if (x1 >= 1 && y1 >= 1) q[++tot] = node{x1 - 1, y1 - 1, i, 1};
	}
	sort(a + 1, a + n + 1), sort(q + 1, q + tot + 1);
	for (int i = 0, j = 1, k = 1; i <= n; i++) {
		for (; j <= n && a[j].y == i; j++) add(a[j].x + 1, 1);
		debug(q[k].l);
		for (; k <= tot && q[k].l == i; k++) ans[q[k].id] += q[k].typ * ask(q[k].r + 1);
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P1972 [SDOI2009] HH的项链

这里无法进行前缀和，将询问按右端点排序。扫描时注意到我们只关注最右边的颜色，利用该性质，删掉左边的颜色并加入新颜色即可。于是使用**序列树状数组**。实现的时候开一个 $vis$ 数组记录上一个颜色。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 1e6 + 5;

int n, m, a[N], vis[N], ans[N];
struct node {
	int l, r, id;
} q[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void update(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int query(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res += tr[x];
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	cin >> m;
	for (int i = 1; i <= m; i++) cin >> q[i].l >> q[i].r, q[i].id = i;
	sort(q + 1, q + m + 1, [](const node& x, const node& y) -> bool {
		return x.r < y.r;
	});
	int nxt = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = nxt; j <= q[i].r; j++) {
			if (vis[a[j]]) update(vis[a[j]], -1);
			vis[a[j]] = j, update(j, 1);
		}
		ans[q[i].id] = query(q[i].r) - query(q[i].l - 1);
		nxt = q[i].r + 1;
	}
	for (int i = 1; i <= m; i++) cout << ans[i] << '\n';
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P4113 [HEOI2012] 采花

与上一题极其相似，这一次关注的是最右的两个颜色。实现时，开两个数组 $vis_1,vis_2$，关注上两个颜色。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 2e6 + 5;
// 这里省略了快读

int n, c, m, a[N], ans[N];
struct node {
	int l, r, id;
} q[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void update(int x, int c) {
	for (; x <= n; x += lowbit(x)) tr[x] += c;
}
int query(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res += tr[x];
	return res;
}

int mp[N], vis1[N], vis2[N];

void _main() {
	read(n), read(c), read(m);
	for (int i = 1; i <= n; i++) read(a[i]);
	for (int i = 1; i <= m; i++) read(q[i].l), read(q[i].r), q[i].id = i;
	sort(q + 1, q + m + 1, [](const node& x, const node& y) -> bool {
		return x.r < y.r;
	});
	int nxt = 1;
	for (int i = 1; i <= m; i++) {
		for (int j = nxt; j <= q[i].r; j++) {
			if (!vis1[a[j]]) vis1[a[j]] = j;
			else {
				if (!vis2[a[j]]) {
					update(vis1[a[j]], 1);
				} else {
					update(vis2[a[j]], 1);
					update(vis1[a[j]], -1);
					vis1[a[j]] = vis2[a[j]];
				}
				vis2[a[j]] = j;
			}
		}
		ans[q[i].id] = query(q[i].r) - query(q[i].l - 1);
		nxt = q[i].r + 1;
	}

	for (int i = 1; i <= m; i++) write(ans[i]), putchar('\n');
	flush();
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```

## P4303 [AHOI2006] 基因匹配

如果元素不重复，LCS 可以转化为 LIS 在 $O(n \log V)$ 时间内使用二维数点求解。见 [P1439 【模板】最长公共子序列](https://www.luogu.com.cn/problem/P1439)。

由于本题每个元素的出现次数严格 $=5$，那么对 $a$ 排序，此时 $b$ 变为 LIS 问题，使用权值树状数组记录前缀 $\max$。贪心一下，发现转移等价时 $j$ 最大最优，倒序枚举 $j$ 即可。

```cpp
#include <bits/stdc++.h>
using namespace std;

const int N = 1e5 + 5;

int n, a[N], b[N];
vector<int> pos[N];

int tr[N];
constexpr int lowbit(int x) {return x & -x;}
void add(int x, int c) {
	for (; x < N; x += lowbit(x)) tr[x] = max(tr[x], c);
}
int ask(int x) {
	int res = 0;
	for (; x != 0; x -= lowbit(x)) res = max(res, tr[x]);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= 5 * n; i++) cin >> a[i], pos[a[i]].emplace_back(i);
	for (int i = 1; i <= 5 * n; i++) cin >> b[i];
	// 变LIS，二维数点权值前缀max
	for (int i = 1; i <= 5 * n; i++) {
		for (int j = 4; j >= 0; j--) {
			int x = pos[b[i]][j];
			add(x, ask(x - 1) + 1);
		}
	}
	cout << ask(5 * n);
} signed main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr), cout.tie(nullptr), cerr.tie(nullptr);

	int t = 1; for (/*cin >> t*/; t--; ) _main();
	return 0;
}
```$AKB158$, '数据结构', array['离线', '二维数点', '树状数组', '扫描线'], 'col-ds-other-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-other-overview', '其他数据结构总览（dsu on tree / 哈希表 / 链表 / ODT / 离线二维数点）', $AKB159$## 算法原理

本页是「其他数据结构」的二级栏目索引，收纳不便归入线段树、树状数组、平衡树等大类的专题结构：dsu on tree、哈希表、链表、珂朵莉树（ODT）、离线二维数点。

**学习顺序**：按题目需要选读，彼此之间没有强依赖；哈希表与链表是通用基础，dsu on tree 与离线二维数点偏技巧。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 用哪篇 |
|---|---|
| 子树信息合并、不带修的树上统计 | dsu on tree |
| 需要均摊 $O(1)$ 的键值映射 | 哈希表（哈希函数与冲突处理） |
| 需要 $O(1)$ 插入删除的序列维护 | 链表（数组模拟双链表） |
| 区间推平 + 随机数据 | 珂朵莉树（ODT） |
| 静态二维矩形计数、可离线 | 离线二维数点 |

## 逐行代码解析

本页是索引入口，不重复贴代码；各子页给出对应实现与逐行解析。

## 复杂度分析

- dsu on tree：$O(n\log n)$ 级别（按轻重儿子合并）。
- 哈希表：期望 $O(1)$，最坏受冲突影响。
- 链表：插入/删除 $O(1)$，查找 $O(n)$。
- ODT：随机数据下均摊优秀，最坏可退化。
- 离线二维数点：按一维排序 + 树状数组，$O((n+q)\log n)$。

## 适用场景

- 子树统计且不需要修改（dsu on tree）。
- 需要自定义键的映射（哈希表）。
- 频繁插入删除的序列（链表）。
- 区间赋值类操作（ODT）。
- 静态矩形计数（离线二维数点）。

## 常见陷阱与注意事项

- dsu on tree 要区分「保留重儿子」与「清空轻儿子」的时机。
- 哈希表要防卡哈希，必要时用双哈希或随机化。
- 数组模拟链表要处理好头尾哨兵。
- ODT 只适合随机数据，构造数据会退化。
- 离线二维数点注意坐标离散化与查询拆分后的符号。

## 对比与扩展

- dsu on tree vs 线段树合并：前者适合只查询、后者适合可合并信息。
- 哈希表 vs `std::map`：前者期望更快，后者有序。
- ODT vs 分块：数据随机时 ODT 更短，构造数据用分块更稳。$AKB159$, '数据结构', array['数据结构', '总览', 'dsu on tree', '哈希表', 'ODT', '离线二维数点'], null, null, 'knowledge'),
('Fohen', 'col-ds-persistent-overview--fenfeng', '可持久化数据结构（总纲） · Fohen', $AKB160$## 算法原理

可持久化（Persistence）指数据结构能够**访问其历史版本**的能力：每次修改后，旧版本仍然存在、可被读取，而不是被覆盖销毁。这一特性类似于游戏的存档系统——玩家在挑战 BOSS 前存下版本 A，挑战后进入版本 B，同时仍能随时回读版本 A 的状态，甚至从 A 重新出发产生新的分支。

按版本操作的限制强弱，可持久化分为两类：

- **部分可持久化**：所有历史版本均可查询，但只允许在最新版本上修改。
- **完全可持久化**：所有历史版本均可查询，也允许基于任意历史版本修改，从而形成版本树。

朴素思路是每次修改都完整复制一份新结构，时间与空间均为 $O(nq)$：当 $n=10^5$、为每个前缀各建一棵线段树时，总节点数可达 $10^5 \times 2 \times 10^5 = 2 \times 10^{10}$，即使每个节点只存少量字段也会占用数百 GB 内存，不可接受。因此，所有高效方案都围绕同一个精髓展开：**新旧版本共享不变的部分，只新建被改变的部分**。

## 核心公式 / 状态定义与转移方程

本知识点是多种实现方法的总纲，没有统一的转移方程；其核心是刻画「版本」这一状态，以及各方案的时间与空间代价上界。设结构规模为 $n$，共执行 $q$ 次修改，$m$ 为某个节点被修改的次数。

**路径复制**：树形结构（如线段树、Trie）上的一次单点修改，只会影响从根到叶的一条路径，长度为 $O(\log n)$。因此每产生一个新版本，只需新建路径上的节点并复用其余子树，新增空间为

$$
O(\log n)
$$

总空间为 $O(n + q\log n)$。

**胖节点**：每个节点内部维护一个带版本号的历史记录列表，每次修改在列表尾部追加一条记录，空间增量 $O(1)$；查询时在列表中二分出目标版本最近的一条有效值，代价 $O(\log m)$。

**离线处理**：把所有操作按时间建成一棵操作树，DFS 遍历时进入节点执行修改、离开节点撤销修改，从而用普通结构配合可逆操作维护当前版本，总时间 $O((n+q)\log n)$，总空间 $O(n+q)$。

**朴素复制**：每次完整复制，时间与空间均为 $O(nq)$，仅作为对比基准。

## 逐行代码解析

以下为三种思路的伪代码（思想步骤），并非可直接编译的 C++ 实现。

### 路径复制

```
// 基于旧版本节点 old，在区间 [l, r] 上修改位置 pos，返回新版本节点
function 修改(old, l, r, pos):
    cur = 复制(old)                 // 关键：先整体复制旧节点（值 + 左右子指针）
    if l == r:
        更新 cur 的值                // 到达叶节点，修改真正生效
        return cur
    mid = (l + r) / 2
    if pos <= mid:
        cur.left = 修改(old.left, l, mid, pos)      // 递归新建左路径
        // cur.right 仍指向 old.right，与旧版本共享
    else:
        cur.right = 修改(old.right, mid + 1, r, pos) // 递归新建右路径
        // cur.left 仍指向 old.left，与旧版本共享
    重新计算 cur 的值                // 回溯维护聚合信息
    return cur
```

- 第 3 行 `cur = 复制(old)` 是精髓：新节点先完整继承旧节点的值和左右子指针，保证未修改一侧自动指向旧版本的子树。
- 第 4~6 行处理叶节点，是修改真正落地的位置。
- 第 8~13 行只沿修改位置所在的那一侧递归新建节点，另一侧保持不变，实现共享。
- 第 14 行回溯时重新聚合当前节点的值，使整条路径上的信息正确。

### 胖节点

```
// 节点内保存 (值, 版本号) 的历史列表
function 修改(节点 u, 新值 v, 版本号 t):
    u.history.append((v, t))        // 追加记录，不复制任何节点

function 查询(节点 u, 版本号 t):
    在 u.history 中二分最后一个版本号 <= t 的记录
    return 该记录的值
```

- 修改只做一次追加，空间增量 $O(1)$，无需复制节点。
- 查询需要按版本号二分，多出一个 $O(\log m)$ 的因子，其中 $m$ 是该节点的修改次数。

### 离线处理

```
// 每个版本是操作树上的一个节点，DFS 维护当前版本状态
function dfs(版本 node):
    执行 node 对应的修改操作          // 进入时应用
    回答 node 上的所有询问
    for 每个子版本 child:
        dfs(child)                   // 递归到子版本
    撤销 node 的修改操作             // 离开时回退（要求操作可逆）
```

- 进入节点时执行修改、离开时撤销，等价于在 DFS 栈上维护当前版本。
- 不构造任何持久化结构，仅依赖普通数据结构与可逆操作；但要求所有操作可预先知道且可逆。

## 复杂度分析

设结构规模为 $n$，共 $q$ 次修改，$m$ 为某节点的修改次数，各方案对比如下：

| 方案 | 单次修改时间 | 单次查询时间 | 总空间 |
| :--- | :---: | :---: | :---: |
| 朴素复制 | $O(n)$ | $O(\log n)$ | $O(nq)$ |
| 路径复制 | $O(\log n)$ | $O(\log n)$ | $O(n + q\log n)$ |
| 胖节点 | $O(1)$ | $O(\log m)$ | $O(n + q)$ |
| 离线处理 | 均摊 $O(\log n)$ | 均摊 $O(\log n)$ | $O(n + q)$ |

补充说明：路径复制每产生一个新版本新增 $O(\log n)$ 个节点，$q$ 次修改累计 $O(n + q\log n)$ 空间；胖节点每次修改仅追加 $O(1)$ 空间，总空间 $O(n + q)$，但查询比路径复制多一个 $O(\log m)$ 因子。离线处理本身不产生持久化副本，时间取决于普通结构维护与撤销的代价。

## 适用场景

- **版本回溯**：需要查询任意历史版本的状态，例如「查询第 $t$ 次修改后的某个值」。
- **强制在线**：题目要求每个回答依赖上一个回答，无法预先离线时，必须使用真正的持久化结构。
- **区间第 $k$ 小 / 主席树**：把每个前缀建成一个版本，利用版本差分在 $O(\log n)$ 内回答区间查询。
- **可持久化数组、可持久化并查集、可持久化 Trie**：分别用于历史版本的数组访问、连通性查询、最大异或和查询。
- **离线处理**：适合询问量极大、操作可逆、且所有操作可预先知道的问题。

## 常见陷阱与注意事项

- **空间要预留充分**：路径复制每次修改新增 $O(\log n)$ 个节点，预分配应按 $O(n + q\log n)$ 上界，否则会越界。
- **必须先复制再修改**：路径复制中新节点要先整体继承旧节点（含左右子指针），再改路径上的子指针，否则未修改一侧的子树不会被正确共享。
- **均摊结构不能直接路径复制**：非均摊数据结构均可通过路径复制实现可持久化；均摊结构（如并查集、Splay）需重构实现，否则摊还分析被历史版本破坏。
- **离线要求操作可逆**：加减可相互抵消，而取最值等不可逆操作无法简单撤销。
- **强制在线会卡掉离线做法**：一旦询问依赖上次答案，操作树无法预先构建。
- **胖节点的对数因子**：查询多出的 $O(\log m)$ 在部分场景下可能影响性能，故竞赛中路径复制更常用。

## 对比与扩展

- **路径复制 vs 胖节点 vs 离线**：路径复制最通用、查询无额外对数因子，是竞赛首选；胖节点实现简单、空间增量更小，但查询带 $O(\log m)$；离线无需持久化、空间 $O(n+q)$，但要求可逆且可预知。
- **可持久化数组**：以可持久化线段树实现，支持在任意历史版本上单点修改与单点查询。
- **可持久化并查集**：在可持久化结构上维护连通性，用于历史版本的连通性查询。
- **可持久化 Trie**：把「只新建路径节点」的思想用于 Trie，支持历史版本上的最大异或和查询。
- **主席树**：可持久化线段树的典型应用，把前缀 $[1..i]$ 作为第 $i$ 个版本，通过版本差分回答区间第 $k$ 小。
- **路径复制 vs 胖节点的适用对象**：路径复制依赖「从根到修改点存在一条唯一路径」，只有树形结构（线段树、Trie 等）能保证单次修改只新建 $O(\log n)$ 个节点；而链表、数组等非树形结构没有根到叶的路径，修改常需重建整段区间，无法靠路径复制实现共享。此时改用胖节点——在每个位置维护带版本号的记录列表，每次修改只追加一条记录，空间增量 $O(1)$，从而覆盖非树形结构这一路径复制触及不到的场景。

```
// 非树形结构（数组/链表）用胖节点：每个位置维护 (值, 版本号) 列表，查询时二分
function 修改(位置 i, 新值 v, 版本号 t):
    a[i].history.append((v, t))   // 只追加一条记录，不复制整段结构
```$AKB160$, '数据结构', array['可持久化', '历史版本', '路径复制', '数据结构'], null, null, 'knowledge'),
('Xesir', 'col-ds-persistent-overview--xesir', '可持久化数据结构（总纲） · Xesir', $AKB161$## 算法原理

在数据结构领域，**可持久化**指的是能够**访问数据结构的历史版本**的能力。

想象你在玩 RPG 游戏，打 BOSS 前存了一个存档（版本 A），打完后进入新状态（版本 B）。如果游戏允许你随时读取存档 A 查看当时的属性，甚至从 A 重新开始打，那么这个存档系统就是「可持久化」的。

在编程中，可持久化分为两种：

- **部分可持久化**：所有历史版本都允许查询，但仅允许修改最新版本。
- **完全可持久化**：所有历史版本都允许查询，也允许基于任意历史版本进行修改（产生新分支）。

## 逐行代码解析

### 模块一：朴素思路（完整复制）

最直接的想法：每次对数据结构进行一次修改（如插入一个数），就**完整复制**一份全新的数据结构。

当然这个显然是低效的，时间和空间复杂度都是 $O(nq)$。

> 假设数组长度 $n=10^5$，我们为每个前缀建一棵线段树，总共 $10^5$ 棵树。每棵线段树有约 $2\times 10^5$ 个节点，总节点数约为 $10^5\times 2\times 10^5=2\times 10^{10}$ 个。即使每个节点只存 $3$ 个整数（左右儿子 + 权值），内存也高达数百 GB，这显然是不可接受的。

因此，需要更高效的算法。

### 模块二：路径复制

这是最常用的可持久化实现。

仔细分析单点修改操作：在树形结构（如线段树、Trie 树）中，一次修改（如插入一个值）**只会影响从根节点到对应叶子节点路径上的节点**，而其他大部分节点（兄弟子树）完全不受影响。

因此，我们不需要复制整棵树，只需：

1. **新建**被修改路径上的所有节点（约 $O(\log n)$ 个）。
2. **复用**（直接指向）旧版本中未发生变化的子树节点。

这样一来，每生成一个新版本，仅增加 $O(\log n)$ 个新节点。总空间复杂度从 $O(n\times\text{size})$ 骤降到 $O(n\log n)$，完全在可接受范围内。

**可持久化的精髓**：新旧版本共用不变的部分，只新建改变的部分。

以可持久化权值线段树的单点修改为例，核心就是「复制旧节点 → 改当前节点 → 只递归一侧」：

```cpp
int update(int pre, int l, int r, int pos, int val) {
    tr[++tot] = tr[pre];          // 复制旧节点
    int cur = tot;
    tr[cur].wh += val;            // 只改被影响的信息
    if (l == r) return cur;
    int mid = (l + r) >> 1;
    if (pos <= mid) tr[cur].ls = update(tr[pre].ls, l, mid, pos, val);
    else tr[cur].rs = update(tr[pre].rs, mid + 1, r, pos, val);
    return cur;
}
```

`tr[++tot] = tr[pre]` 把旧版本的这个节点整个搬过来（连同左右儿子指针），然后只改 `wh`；接着只往包含 `pos` 的那一侧递归，另一侧的指针保持指向旧版本的子树——这就是「复用不变部分」。

> 实际上所有非均摊的数据结构都可以通过路径复制方式实现可持久化。对于均摊数据结构，则需要重构其实现方式才能可持久化，如可持久化并查集。

### 模块三：胖节点

另一种通用的持久化思路是让每个节点「变胖」，即节点内部用一个**历史记录列表**存储所有历史值，每个值附带一个**版本时间戳**。

修改时，不复制任何节点，直接在对应节点的列表尾部追加新值；查询时，根据目标版本号在列表中二分查找最近的有效值。

这种方法每次修改只需 $O(1)$ 的额外空间，但查询会多一个 $O(\log m)$（$m$ 为该节点的修改次数）的二分开销。它实现简单且适用于链表、数组等非树形结构，但在算法竞赛中不如路径复制常用，因为查询的额外对数因子在某些场景下会影响性能。

### 模块四：离线处理（操作树）

如果**所有询问可以预先知道**，可持久化问题有时可以转化为离线问题来解决。核心思路是：将所有操作按时间顺序构建成一棵**操作树**（每个版本作为树上的一个节点），通过 DFS 遍历这棵树，进入节点时执行修改操作，离开时**撤销**该操作，从而维护当前版本的状态。

这种方式不需要任何持久化数据结构，只用普通数据结构配合「可撤销」操作即可。但它要求所有操作必须离线预知，且修改操作必须是**可逆**的（如加减法可相互抵消）。实际情况中题目有可能通过强制在线（每个询问依赖于上一个的答案）卡掉。

时间复杂度通常为 $O((n+q)\log n)$，空间复杂度为 $O(n+q)$，适合询问量极大且操作可逆的场景。

## 复杂度分析

具体复杂度取决于选用的实现方式：

- **朴素完整复制**：时间 $O(nq)$，空间 $O(nq)$，只适合极小的数据。
- **路径复制**：每个版本新增 $O(\log n)$ 个节点，建 $n$ 个版本的时间与空间均为 $O(n\log n)$；单次查询通常 $O(\log n)$。
- **胖节点**：每次修改额外空间 $O(1)$，查询多一个 $O(\log m)$ 的二分。
- **离线操作树**：时间 $O((n+q)\log n)$，空间 $O(n+q)$，但要求离线且修改可逆。

## 适用场景

- 需要访问历史版本：可持久化数组、可持久化线段树（主席树）、可持久化 Trie（历史最大异或和）。
- 需要基于任意历史版本产生分支：完全可持久化，如可持久化并查集。
- 询问强制在线、不能离线撤销时，路径复制是主力方案。
- 询问可以全部预知、修改可逆、且不怕离线时，操作树 + 撤销往往更省空间。
- 「路径复制」不仅适用于线段树，还适用于：**可持久化数组**（通过可持久化线段树实现）、**可持久化并查集**（用于历史版本连通性查询）、**可持久化 Trie**（用于最大异或和的历史查询）。

## 常见陷阱与注意事项

- 路径复制只对**非均摊**结构自然成立；并查集这类带路径压缩的均摊结构不能直接复制，需要按秩合并等改造。
- 复制节点时要把旧节点的所有字段都搬过来，漏掉儿子指针会把兄弟子树弄丢。
- 新版本必须返回新的根，调用方要用返回值更新版本数组，不能还指旧根。
- 胖节点的查询依赖版本时间戳有序，历史列表必须保持单调。
- 离线操作树的「撤销」必须严格可逆；赋值类修改不能直接撤销，需要记录旧值。
- 强制在线的题目不能把询问离线，操作树方案会直接失效。
- 空间估算要按「版本数 $\times\log n$」来算，节点池开小了会越界。$AKB161$, '数据结构', array['数据结构', '可持久化', '历史版本', '路径复制', '胖节点', '离线'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-persistent-segtree-3919', '可持久化线段树（单点修改单点查询 P3919）', $AKB162$## 算法原理

可持久化线段树（Persistent Segment Tree）的核心思想是"只新建修改路径上的节点，其余节点与旧版本共享"。普通线段树的单点修改会沿根到叶走一条 $O(\log n)$ 长度的路径，沿途修改 $O(\log n)$ 个节点；可持久化线段树在这条路径上为每个节点创建一个新副本，而路径之外的的所有节点直接复用旧版本中的指针。因此每次修改只花费 $O(\log n)$ 的时间和 $O(\log n)$ 的空间，就能得到一个"完整的新版本"——新版本的根指向新创建的路径节点，而那些未修改的子树指针仍指向旧版本的节点。

从版本共享的角度看，新版本与父版本之间共享了 $O(n - \log n)$ 个节点（即整棵树除去修改路径上的 $\log n$ 个节点后，其余全部共享）。这意味着创建一个新版本的额外空间开销仅为 $O(\log n)$ 个节点，而非 $O(n)$。m次修改后总节点数为 $O(n + m \cdot \log n)$。这种"版本间共享不可变子树"的设计是函数式数据结构（Functional Data Structure）的典型范式：节点一旦创建便不可变，修改操作返回新的结构而保留旧结构。

本模板（P3919版本）处理的是"单点修改、单点查询"的场景，即每次修改将位置i的值覆盖为k（overwrite语义）。这与下方"普通模板"的增量累加（nd[rt].val += k）有本质区别：P3919是覆盖式赋值，叶节点直接 `nd[rt].val = k`，路径上每个内部节点的val需要重新计算为左右子之和；而普通模板是增量更新，路径上每个节点都累加k。此外，P3919的查询操作（op==2）虽然不修改数据，但会执行 `root[rt_idx++] = root[v]`，即在版本链中创建一个与版本v完全相同的新版本号——这是因为P3919的题面要求每个操作（无论修改还是查询）都产生一个递增的版本号，查询操作复制的版本保证版本号连续。

空间复杂度为 $O(n + m \cdot \log n)$：初始建树使用 $O(n)$ 个节点（线段树共约2n个节点，此模板手动建根层故约4n），每次修改新增 $O(\log n)$ 个节点（路径长度），m次修改共 $m \cdot \log n$ 个。代码中 `nd.resize(n * 4 + m * ceil(log2(n)))` 正是按此上界预分配。

## 数据结构图示

```
节点共享示意 (修改位置 i=2, 覆盖值 k):

版本0 (旧):    [1,4] -------- [3,4] -------- [5,8] -------- ...
                 |                |
版本1 (新):    [1,4]*-------- [3,4]*-------- [5,8] -------- ...
                                                              |
                                                  (其余子树指针共享旧版本)

  * = 新建节点    无标记 = 直接复用旧版本指针

路径细节 (修改 i=2, 范围 [1,8]):
  版本0:  root0 -> [1,8] -> [1,4] -> [1,2] -> [2,2]      (修改路径)
                           -> [3,4]                       (共享)
                  -> [5,8]                                (共享)

  版本1:  root1 -> [1,8]* -> [1,4]* -> [1,2]* -> [2,2]*  (全部新建)
                              -> [3,4]                    (共享版本0)
                   -> [5,8]                               (共享版本0)

版本链 (P3919 特有: 查询也产生版本号):
  版本0: 初始数组
  版本1: 修改操作 insert(0, n, i, k)       -> root[1]
  版本2: 查询操作 root[2] = root[查询版本]  -> root[2] (复制)
  版本3: 修改操作 insert(版本号, n, i, k)  -> root[3]
```

## 核心操作详解

**init(rt, l, r, A)**：递归建树。若l==r为叶节点，直接赋值 `nd[rt].val = A[l]`。否则取mid，先 `++nd_idx` 分配左孩子下标并递归建左子树，再 `++nd_idx` 分配右孩子下标并递归建右子树，最后 `nd[rt].val = 左.val + 右.val` 回溯求和。注意son_l和son_r初始化为-1，建树后才被赋值为有效下标。

**init(n, m)（重载）**：顶层的初始化入口。读取数组A[1..n]，`root.resize(m+1)` 为最多m+1个版本预留根节点空间，`nd.resize(n*4 + m*ceil(log2(n)))` 按空间上界预分配所有节点。然后手动建根层：取mid=(1+n)/2，分别递归init左子树和右子树，最后 `root[0].val = 左.val + 右.val`。`++rt_idx` 使版本指针前进到1（版本0已建好）。

**insert(rt, old, l, r, i, k)**：核心修改函数（递归版）。第一步 `nd[rt] = nd[old]` 将旧节点整体复制到新节点（包括val和两个子指针）。若l==r（叶节点），执行覆盖赋值 `nd[rt].val = k` 并返回。否则取mid：若i在左半，则 `++nd_idx` 分配新左孩子，递归 `insert(新左, 旧左, l, mid, i, k)`，右指针保留旧版本的（共享）；若i在右半则对称处理。最后 `nd[rt].val = 左.val + 右.val` 回溯更新。关键点：只有修改路径上的节点被新建，另一侧的子指针直接从old复制过来，指向旧版本的节点。

**insert(old, n, i, k)（重载）**：顶层修改入口。`root[rt_idx] = root[old]` 复制旧版本根节点。然后根据i与mid的关系，分配新子节点并递归。最后更新根val并 `++rt_idx`。注意顶层init手动建了根层（root[0]有son_l和son_r），所以insert的重载也需要手动处理根层的分裂，而非直接调用递归insert。

**myget(rt, l, r, i)**：递归单点查询。若i不在[l,r]范围内返回0；若l==r返回叶节点值；否则取mid，按i所在半区递归左或右子树。

**myget(ver, n, i)（重载）**：顶层查询入口。在版本ver的根上，按i与mid的关系递归左或右子树。

## 逐行代码解析

### 全局变量与结构体

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷3919*/
struct node
{
	long long val;       // 节点维护的值 (区间和或单点值)
	int son_l, son_r;    // 左右孩子下标, 初始化为-1表示空
	node() :val(0), son_l(-1), son_r(-1) {}
};
int rt_idx = 0;   // 当前版本号 (root数组的写入位置)
int nd_idx = 0;    // 节点分配计数器 (nd数组的写入位置)
vector<node> root; // root[v] = 版本v的根节点 (存储根层信息)
vector<node> nd;   // 所有线段树节点的存储池
```

- `node` 存 `val`（区间和或单点值，用 `long long` 防求和溢出）和 `son_l/son_r` 左右孩子下标；构造函数把两个孩子初始化为 `-1` 表示空节点。
- `rt_idx` 是版本号指针（`root` 数组的写入位置），`nd_idx` 是节点分配计数器；`root[v]` 存版本 v 的"超级根"，`nd` 是所有线段树节点的存储池。
- 这些全局变量是整份代码的核心状态：建树/修改/查询都靠 `nd_idx` 分配新节点、靠 `rt_idx` 递增版本号，跨函数共享。

### init 建树

```cpp
// 递归建树: 在nd[rt]处建区间[l,r]的子树
void init(int rt, int l, int r, const vector<long long>& A)
{
	if (l == r) nd[rt].val = A[l]; // 叶节点: 直接赋值
	else
	{
		int mid = (l + r) >> 1;
		nd[rt].son_l = ++nd_idx;           // 分配左孩子下标
		init(nd[rt].son_l, l, mid, A);      // 递归建左子树
		nd[rt].son_r = ++nd_idx;           // 分配右孩子下标
		init(nd[rt].son_r, mid + 1, r, A);  // 递归建右子树
		nd[rt].val = nd[nd[rt].son_l].val + nd[nd[rt].son_r].val; // 回溯求和
	}
}
// 顶层建树: 读入数组, 预分配空间, 建版本0
void init(int n, int m)
{
	vector<long long> A(n + 1);
	root.resize(m + 1);                              // 预留 m+1 个版本
	nd.resize(n * 4 + m * ceil(log2(n)));            // 预分配节点池 (空间上界)
	for (int i = 1; i <= n; i++) cin >> A[i];
	int l = 1, r = n;
	int mid = (l + r) >> 1;
	// 手动建根层: root[0] 是一个特殊的根节点, 分别建左右子树
	root[rt_idx].son_l = ++nd_idx;
	init(root[rt_idx].son_l, l, mid, A);
	root[rt_idx].son_r = ++nd_idx;
	init(root[rt_idx].son_r, mid + 1, r, A);
	root[rt_idx].val = nd[root[rt_idx].son_l].val + nd[root[rt_idx].son_r].val;
	++rt_idx; // rt_idx 从 0 变为 1, 版本0已建好
}
```

- 递归版 `init(rt,l,r,A)`：`l==r` 时把叶节点直接赋值为 `A[l]`；否则拆成 `[l,mid]` 和 `[mid+1,r]`，先 `++nd_idx` 分配左孩子递归建左，再分配右孩子递归建右，最后回溯 `val=左+右`。
- 重载版 `init(n,m)`：读入 `A[1..n]`，`root.resize(m+1)` 预留版本、`nd.resize(n*4+m*ceil(log2(n)))` 按空间上界预分配节点池。
- 关键点：顶层手动建"根层"——`root[0]` 自身不参与递归，而是分别建 `[1,mid]` 与 `[mid+1,n]` 两棵子树，再把 `root[0].val` 求和，最后 `++rt_idx` 使版本 0 就绪。
- 易错：`n=1` 时 `mid=(1+1)>>1=1`，右区间变成 `[2,1]`（空区间），会进入 `init` 的 `else` 分支不断递归分配节点并越界——这是"手动根层分裂"写法在 `n=1` 上的边界缺陷。

### insert 修改

```cpp
// 递归修改: 基于旧节点old, 在新节点rt处创建修改路径
void insert(int rt, int old, int l, int r, int i, long long k)
{
	nd[rt] = nd[old]; // 关键: 先整体复制旧节点 (val + 两个子指针)
	if (l == r)       // 叶节点: 覆盖赋值
	{
		nd[rt].val = k; // P3919 是覆盖语义, 不是 += 
		return;
	}
	int mid = (l + r) >> 1;
	if (i <= mid)    // 修改在左半: 新建左孩子, 右孩子共享旧版本
	{
		nd[rt].son_l = ++nd_idx;                    // 分配新左孩子
		insert(nd[rt].son_l, nd[old].son_l, l, mid, i, k); // 递归左
		// nd[rt].son_r 保持从 old 复制来的值 (共享旧版本右子树)
	}
	else            // 修改在右半: 新建右孩子, 左孩子共享旧版本
	{
		nd[rt].son_r = ++nd_idx;
		insert(nd[rt].son_r, nd[old].son_r, mid + 1, r, i, k);
	}
	nd[rt].val = nd[nd[rt].son_l].val + nd[nd[rt].son_r].val; // 回溯求和
}
// 顶层修改: 基于版本old, 创建新版本
void insert(int old, int n, int i, long long k)
{
	int l = 1; int r = n;
	int mid = (l + r) >> 1;
	root[rt_idx] = root[old]; // 复制旧版本根节点
	if (i <= mid)  // 修改在左半
	{
		root[rt_idx].son_l = ++nd_idx;                       // 新建根的左孩子
		insert(root[rt_idx].son_l, root[old].son_l, l, mid, i, k); // 递归
		// root[rt_idx].son_r 共享旧版本
	}
	else          // 修改在右半
	{
		root[rt_idx].son_r = ++nd_idx;
		insert(root[rt_idx].son_r, root[old].son_r, mid + 1, r, i, k);
	}
	root[rt_idx].val = nd[root[rt_idx].son_l].val + nd[root[rt_idx].son_r].val; // 回溯
	++rt_idx; // 版本号+1
}
```

- 递归版 `insert(rt,old,l,r,i,k)`：先 `nd[rt]=nd[old]` 把旧节点整体复制到新节点（含 `val` 和两个子指针），再判断是否叶节点。
- `l==r` 时执行覆盖赋值 `nd[rt].val=k`（P3919 是覆盖语义，不是 `+=`）并返回。
- 非叶时按 `i<=mid` 决定走左/右：只新建被修改那一侧的子节点并递归，另一侧子指针保留从 `old` 复制来的值，实现与旧版本共享。
- 回溯 `val=左+右` 重新求和；重载版 `insert(old,n,i,k)` 同样手动处理根层分裂，最后 `++rt_idx` 生成新版本号。

### myget 查询

```cpp
// 递归单点查询: 在nd[rt]子树中查询位置i的值
long long myget(int rt, int l, int r, int i)
{
	if (i < l || i > r) return 0;   // 不在范围内
	if (l == r) return nd[rt].val;  // 叶节点: 返回值
	int mid = (l + r) >> 1;
	if (i <= mid) return myget(nd[rt].son_l, l, mid, i);      // 在左半
	else return myget(nd[rt].son_r, mid + 1, r, i);           // 在右半
}
// 顶层单点查询: 在版本ver中查询位置i的值
long long myget(int ver, int n, int i)
{
	int l = 1, r = n;
	int mid = (l + r) >> 1;
	if (i <= mid) return myget(root[ver].son_l, l, mid, i);  // 手动处理根层分裂
	else return myget(root[ver].son_r, mid + 1, r, i);
}
```

- 递归版 `myget(rt,l,r,i)`：先做 `i<l || i>r` 的越界保护返回 0，`l==r` 返回叶节点值，否则按 `mid` 分左右递归。
- 重载版 `myget(ver,n,i)`：在版本 `ver` 的根上手动按 `mid` 分裂，选 `son_l` 或 `son_r` 递归。
- 易错：正确导航下不会访问到 `son=-1` 的叶节点子指针；若导航出错会 `nd[-1]` 越界，所以叶节点必须在 `l==r` 处直接返回。

### main

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int N, M;
	cin >> N >> M;
	init(N, M); // 建版本0
	for (int i = 1; i <= M; i++)
	{
		int v, op;
		cin >> v >> op;        // v = 基于的版本号, op = 操作类型
		if (op == 1)          // 修改操作: 基于版本v修改位置idx为k
		{
			int idx;
			long long k;
			cin >> idx >> k;
			insert(v, N, idx, k); // 创建新版本
		}
		else                  // 查询操作: 查版本v的位置x的值
		{
			int x;
			cin >> x;
			cout << myget(v, N, x) << '\n';
			// P3919 特有: 查询也要产生新版本号
			// root[rt_idx++] = root[v] 复制版本v作为新版本
			root[rt_idx++] = root[v];
		}
	}
	return 0;
}
```

- 读 `N、M` 后 `init(N,M)` 建版本 0；循环 M 次，每次读 `v`（基于的版本号）和 `op`。
- `op==1` 读 `idx、k`，调用 `insert(v,N,idx,k)` 创建新版本；`op==2` 读 `x`，输出 `myget(v,N,x)` 后执行 `root[rt_idx++]=root[v]` 复制版本 v 作为新版本号。
- 易错：P3919 要求查询也产生递增版本号，`root[rt_idx++]=root[v]` 不能省略，否则后续版本号错位。
- 易错：`root` 只 `resize` 到 `m+1`，但 `rt_idx` 从 1 涨到 `m+1`，写入下标最大为 `m`（`root[0..m]` 共 m+1 个），恰好不越界。

## 复杂度分析

时间复杂度：建树 $O(n)$（递归建n个叶节点和n-1个内部节点）；单次修改 $O(\log n)$（沿修改路径递归 $\log n$ 层）；单次查询 $O(\log n)$（沿查询路径递归 $\log n$ 层）。m次操作总时间 $O(n + m \cdot \log n)$。

空间复杂度：$O(n + m \cdot \log n)$。初始建树约使用4n个节点（含根层手动分配），每次修改新增 $\log n$ 个节点（修改路径长度），m次修改共 $m \cdot \log n$ 个。代码中 `nd.resize(n * 4 + m * ceil(log2(n)))` 按此上界预分配。

## 适用场景

可持久化线段树适用于需要访问历史版本的数据场景，包括：版本回溯（P3919——查询任意历史版本的单点值）、区间第k小（主席树/Chairman Tree——将每个前缀作为一个版本，利用版本差分查询区间第k小）、可持久化数组（函数式数组，支持在任意历史版本上修改和查询）、历史区间求和等。P3919本版是"单点修改单点查询"的最基础形态，是理解可持久化线段树的入门模板。

## 常见陷阱与注意事项

- **空间预分配必须足够大**：`nd.resize(n * 4 + m * ceil(log2(n)))` 是空间上界。若m次操作中修改次数较多，空间不足会导致越界。注意ceil(log2(n))在n=1时为0，可能导致空间不足，实际使用时常取n*40作为保险上界。
- **查询操作也会创建新版本**：P3919题面要求每个操作（含查询）都产生递增版本号，因此 `root[rt_idx++] = root[v]` 不可省略。若省略则版本号不连续，后续基于版本号的修改/查询会错位。
- **nd[rt] = nd[old] 的顺序**：必须先复制旧节点再判断是否为叶节点。若先判断叶节点直接赋值则跳过了复制，导致内部节点的子指针未正确共享。
- **根层手动分裂**：此模板的init和insert的重载版本都手动处理了根层的mid分裂（因为root[0]是一个特殊的"超级根"节点），这与标准模板直接从根递归不同，容易在移植时遗漏。
- **son_l/son_r初始化为-1**：空孩子用-1表示，递归查询时若碰到-1会导致越界。建树时所有内部节点的子指针都被赋值，叶节点的子指针保持-1（不使用），myget在叶节点处直接返回不会访问子指针。

## 对比与扩展

- **P3919（覆盖式）vs 普通模板（增量式）**：P3919的叶节点执行 `nd[rt].val = k`（覆盖），适合"将位置i改为k"的语义；普通模板执行 `nd[rt].val += k`（增量累加），适合"将位置i增加k"的语义。两者的路径回溯也不同：P3919回溯时 `val = 左+右`（因为叶被覆盖），普通模板路径上每个节点都 += k（因为增量沿路径传播）。
- **可持久化线段树 vs 可持久化树状数组（BIT）**：线段树更通用，支持任意区间查询和单点修改的历史版本；BIT仅适合前缀和类操作，但常数更小、代码更短。
- **扩展：主席树（Chairman Tree）**：基于可持久化线段树，将数组前缀[1..i]作为第i个版本，利用版本i和版本i-1的差分在 $O(\log n)$ 内查询区间 $[l,r]$ 的第k小值。
- **扩展：可持久化Trie**：将同样的"只新建路径节点"思想应用于Trie，支持历史版本上的异或最大值查询等。
- **扩展：可持久化平衡树**：利用Treap（非旋转式）实现可持久化平衡树，支持历史版本上的插入/删除/排名查询。$AKB162$, '数据结构', array['数据结构', '可持久化线段树', '历史版本', '单点修改', 'P3919'], 'col-ds-persistent-overview', null, 'knowledge'),
('Xesir', 'col-ds-persistent-segtree-kth--xesir', '主席树（可持久化权值线段树 · 区间第 k 小） · Xesir', $AKB163$## 算法原理

~~GOC学了主席树感觉自己又行了，于是夺舍了DS~~

主席树，即可持久化权值线段树，用于维护区间第 $k$ 小值。

### 前置知识

要理解本节内容，你需要先掌握：

1. **权值线段树**（见上文）：用于维护值域频次。
2. **可持久化思想**（见下文）：通过路径复制保存历史版本。

将「权值线段树」与「可持久化思想」结合，就得到了大名鼎鼎的**主席树**。它主要用于解决**静态区间第 $k$ 小**问题。

> 为啥叫「主席树」？因为发明者叫黄嘉泰，缩写是 HJT，和某位历史人物的缩写一样，于是江湖人称「主席树」。~~什么石山命名法~~

### 经典问题：静态区间第 $k$ 小

> 给定长度为 $n$ 的序列 $a$，$m$ 次询问，每次询问子区间 $[l,r]$ 中的第 $k$ 小值。$(n,m\le 2\times 10^5)$

### 前缀和思想的运用

我们为数组的每个前缀 $[1,i]$ 建立一棵权值线段树，记为 $T_i$。$T_i$ 表示前 $i$ 个数中，每个值出现的次数频次统计。

关键性质（可减性）：

$$
\text{区间 }[l,r]\text{ 中值 }x\text{ 的出现次数}
=T_r.\text{count}(x)-T_{l-1}.\text{count}(x)
$$

也就是说，将版本 $T_r$ 与版本 $T_{l-1}$ 对应节点的权值相减，得到的就是区间 $[l,r]$ 的权值线段树。

### 查询算法（两棵树同时递归）

查询 $[l,r]$ 的第 $k$ 小：

1. 同时传入根节点 `u = rt[r]`（版本 $r$）和 `v = rt[l-1]`（版本 $l-1$）。
2. 计算左子树差值：`left_cnt = tr[tr[u].l].sum - tr[tr[v].l].sum`，这代表区间内落在左值域的元素个数。
3. 若 `k <= left_cnt`，则第 $k$ 小在左子树，递归左子树。
4. 否则，第 $k$ 小在右子树，递归右子树，并将 `k` 减去 `left_cnt`。

## 逐行代码解析

原文给了两份模板：第一份是带离散化的标准写法，第二份是动态开点值域写法。这里按第一份（页面所附代码）拆解。

### 模块一：结点定义与空树

```cpp
struct node {
    int l, r;        // 左右儿子编号（注意不是区间端点！）
    int sum;         // 该节点值域区间内数字个数
} tr[N << 5];        // 一般开 N*20 到 N*40

int build(int l, int r) {
    int p = ++cnt;
    if (l == r) {
        tr[p].sum = 0;
        return p;
    }
    int mid = (l + r) >> 1;
    tr[p].l = build(l, mid);
    tr[p].r = build(mid + 1, r);
    tr[p].sum = tr[tr[p].l].sum + tr[tr[p].r].sum;
    return p;
}
```

`l`、`r` 存的是**左右儿子的编号**，不是区间端点，这是动态开点的标志。`build` 先建一棵全部为 $0$ 的空树，作为版本 $0$ 的根；每个节点占用一个新编号 `++cnt`。

### 模块二：`update`（路径复制）

```cpp
int update(int pre, int l, int r, int x) {
    int p = ++cnt;
    tr[p] = tr[pre];   // 复制旧节点
    tr[p].sum++;       // 插入新数，频次+1
    if (l == r) return p;
    int mid = (l + r) >> 1;
    if (x <= mid) {
        tr[p].l = update(tr[pre].l, l, mid, x);
    } else {
        tr[p].r = update(tr[pre].r, mid + 1, r, x);
    }
    return p;
}
```

先把旧节点整个复制过来，再把 `sum` 加一；然后只沿包含 `x` 的那一侧递归，把新儿子接回当前节点，另一侧原封不动地指向旧版本的子树。这样每插入一个数只新增 $O(\log n)$ 个节点，新旧版本共享未修改的部分——这就是「路径复制」。

### 模块三：双版本查询

```cpp
int query(int u, int v, int l, int r, int k) {
    if (l == r) return l;
    int mid = (l + r) >> 1;
    int left_cnt = tr[tr[u].l].sum - tr[tr[v].l].sum;
    if (k <= left_cnt) {
        return query(tr[u].l, tr[v].l, l, mid, k);
    } else {
        return query(tr[u].r, tr[v].r, mid + 1, r, k - left_cnt);
    }
}
```

`u` 是右端点版本 $T_r$ 的当前节点，`v` 是左端点前一个版本 $T_{l-1}$ 的当前节点。两者左儿子的 `sum` 相减，就是区间 $[l,r]$ 内落在左值域的数的个数；据此决定往哪边走，往右走时把 `k` 减去 `left_cnt`。走到叶子返回的值是离散化后的下标。

### 模块四：主函数（离散化 + 建版本）

```cpp
    sort(b + 1, b + n + 1);
    int len = unique(b + 1, b + n + 1) - b - 1;

    rt[0] = build(1, len);
    for (int i = 1; i <= n; i++) {
        int x = lower_bound(b + 1, b + len + 1, a[i]) - b;
        rt[i] = update(rt[i - 1], 1, len, x);
    }
```

先把原数组复制到 `b` 并排序去重，`len` 是不同值的个数；值域被压到 $[1,len]$。版本 $0$ 是空树，之后每个前缀都在前一个版本上插入一个数，得到 `rt[i]`。

```cpp
    while (m--) {
        int l, r, k;
        scanf("%d%d%d", &l, &r, &k);
        int pos = query(rt[r], rt[l - 1], 1, len, k);
        printf("%d\n", b[pos]);
    }
```

查询时传 `rt[r]` 和 `rt[l-1]`，得到离散化下标后再用 `b[pos]` 还原成原值。

第二份模板（原文叫「蒟蒻GOC模版」）不离散化，直接在 $-INF\sim INF$ 的值域上动态开点：

```cpp
    for (int i = 1; i <= n; i++) {
        int c; cin >> c;
        hjt.rt[i] = hjt.update(hjt.rt[i-1], -INF, INF, c, 1);
    }
```

它的 `update` 多了一个 `val` 参数，插入时 `tr[cur].wh += val`；查询逻辑与上面完全一致。优点是省掉离散化，缺点是树高固定为 $\log(2\cdot INF)$、常数更大。

## 复杂度分析

- 建空树：$O(len)$。
- 建立所有版本：每个数插入一次，每次新增 $O(\log len)$ 个节点，共 $O(n\log n)$。
- 单次查询：两棵树同步向下走一条路径，$O(\log len)$。
- 空间：节点数约为 $n(\log n+1)$，所以数组一般开到 `N << 5`（即 $N\times 32$）。

## 适用场景

- **静态**区间第 $k$ 小 / 第 $k$ 大（本模板）。
- 区间内某值出现次数、区间内不超过 $x$ 的数的个数等「可减」的频次统计。
- 找区间内出现次数超过一半的数（配合一些额外判断）。
- 带修区间第 $k$ 小：需要树状数组套主席树。
- 可持久化数组：把权值线段树的下标换成位置即可。

## 常见陷阱与注意事项

- **空间大小**：动态开点 + 持久化，节点数约为 $N\times(\log_2 N+1)$，通常开 `N << 5`（即 $N\times 32$）保险。
- **离散化**：若值域较大（如 $10^9$）且 $n$ 只有 $2\times 10^5$，务必先离散化再建树，以压缩树高和空间。
- **双版本递归**：查询时一定要同时传入 $T_r$ 和 $T_{l-1}$ 的根节点，减法操作才能正确反映区间信息。
- **儿子存的是编号**：`tr[p].l` 和 `tr[p].r` 存的是节点编号（指针），而不是区间端点值，这是动态开点的特征。
- `update` 里必须 `tr[p] = tr[pre]` 复制旧节点，漏掉这一步会把兄弟子树弄丢。
- 查询前要保证 $1\le k\le r-l+1$，否则会走到空节点。
- 版本 $0$ 的空树也要建出来，`rt[0]` 要指向这棵空树，否则查询 $T_{l-1}$ 时读到的是不存在的节点，结果会错。

## 练习题推荐

~~这次真得切紫了~~

1. [可持久化线段树 2](https://www.luogu.com.cn/problem/P3834)（就是上面那个板子题）
2. [KUR-Couriers](https://www.luogu.com.cn/problem/P3567)（找出现次数超过一半的数）
3. [神秘数](https://www.luogu.com.cn/problem/P4587)（进阶题，练练手）
4. [Dynamic Rankings](https://www.luogu.com.cn/problem/P2617)（树状数组套主席树 ~~禁止套娃~~）$AKB163$, '数据结构', array['数据结构', '主席树', '可持久化', '权值线段树', '区间第k小', '离散化'], 'col-ds-persistent-overview', null, 'knowledge'),
('stripe-python', 'col-ds-persistent-segtree-template--stripe-python', '可持久化线段树学习笔记 · stripe-python', $AKB164$> 本文由 stripe-python 授权合并，保留原文结构与表述。
感觉将主席树的很多教程都不讲权值线段树，然后本蒟蒻花了半天时间理解主席树维护的线段树和区间线段树有什么区别。

## 权值线段树

普通线段树解决的问题：

1. 对序列上一段区间做修改；
2. 对序列上一段区间查询信息。

而权值线段树把这个序列变成了值域，相当于维护原序列的出现次数。那么权值线段树对值域做维护，自然也就能支持对值域的操作。我造了一个板子题 [SPN D-Struct 02](https://www.luogu.com.cn/problem/U449821)，下面写写这题题解：

对值域建立线段树，每个节点维护总和，对于操作 1 / 2，把沿路节点的和加上或减去 $h$。对于操作 3，在权值线段树上二分，若左节点总和 $\ge k$，则意味着 $k$ 大值在左子树取得，否则在右子树处取得且要将 $k$ 减去左节点总和。对于操作 4，仿照普通线段树把 $[l,r]$ 区间节点的总和加起来即可。使用动态开点复杂度 $O(q \log V)$。code：

```cpp
template <class T, int N>
class WeightedSegmentTree {
private:
	int cnt, root, ch[2][N << 1];
	T val[N << 1];

	int new_node() {
		int cur = ++cnt;
		val[cnt] = 0, ch[0][cnt] = ch[1][cnt] = 0;
		return cur;
	}

	void update(int p, const T& v, int l, int r, int& rt) {
		if (!rt) rt = new_node();
		val[rt] += v;
		if (l == r) return;
		int mid = (l + r) >> 1;
		if (p <= mid) update(p, v, l, mid, ch[0][rt]);
		else update(p, v, mid + 1, r, ch[1][rt]);
	}

	T query(int tl, int tr, int l, int r, int rt) {
		if (tl <= l && r <= tr) return val[rt];
		int mid = (l + r) >> 1;
		T res(0);
		if (tl <= mid) res += query(tl, tr, l, mid, ch[0][rt]);
		if (tr > mid) res += query(tl, tr, mid + 1, r, ch[1][rt]);
		return res;
	}

	int kth(const T& k, int l, int r, int rt) {
		if (l == r) return l;
		int mid = (l + r) >> 1;
		if (val[ch[0][rt]] >= k) return kth(k, l, mid, ch[0][rt]);
		return kth(k - val[ch[0][rt]], mid + 1, r, ch[1][rt]);
	}

public:
	WeightedSegmentTree() : cnt(0), root(0) {}

	void update(int p, const T& v) {update(p, v, 0, N, root);}
	T query(int l, int r) {return query(l, r, 0, N, root);}
	int kth(const T& k) {return kth(k, 0, N, root);}
};
```

## 可持久化的作用

现在让我们扩展一下这个问题：查询区间第 $k$ 小。

区间问题有一个 trick：$[l,r]=[1,r]-[1,l-1]$。于是我们开 $n$ 个权值线段树，第 $i$ 棵维护序列前缀 $[1,i]$，然后在第 $l-1$ 和第 $r$ 棵里递归查找第 $k$ 小……

然而稍微分析一下，空间 $O(nV)$ 已经爆炸，时间也不优。

如何优化？注意到，我们每次只加入一个数，这个操作的性质是很好的。考虑代码

```cpp
void update(int p, const T& v, int l, int r, int& rt) {
  if (!rt) rt = new_node();
  val[rt] += v;
  if (l == r) return;
  int mid = (l + r) >> 1;
  if (p <= mid) update(p, v, l, mid, ch[0][rt]);
  else update(p, v, mid + 1, r, ch[1][rt]);
}
```

根据线段树基础知识，这个过程复杂度是 $O(\log V)$ 意味着被修改的节点也只有 $O(\log V)$ 个。那为什么不在原树上单独引入节点来存储信息呢？比如说我们在 $V=8$ 的权值线段树中插入一个数字 $3$，则修改的节点为 $[1,8],[1,4],[3,4],[3,3]$，把这些节点变成新的就行。

![](https://cdn.luogu.com.cn/upload/image_hosting/fr4zzxjv.png)

这幅图里，绿色节点为原树的节点，红色节点为新建节点。注意到，绿色节点是一棵完整的树。而如果以 `+[1,8]` 为根：

![](https://cdn.luogu.com.cn/upload/image_hosting/w63rybvm.png)

这也是一棵完整的树。因此这个方法是正确的。

现在网上很多教程是先引入可持久化的，本蒟蒻认为应该先引入这种利用重复节点的思想，再发现这个东西可以实现可持久化。这里解释一下，可持久化指的是能够保存历史版本的数据结构，而这种方法的确能够保存历史版本。

事实上，不基于均摊的树形数据结构，比如线段树、FHQ-Treap、AVL、字典树、左偏树都可以用这种方法可持久化。

## 例题

## P3834 【模板】可持久化线段树 2

就是上文提的区间第 $k$ 小问题。这个题要注意几个点：

1. 离散化。
2. 可持久化线段树显然不能用完全二叉树的方法存储，使用动态开点即可。
3. 开大空间，主席树空间是 $O(V+n\log V)$ 的，对于这题保险起见要开 $4 \times 10^6$。当然你可以用指针写。

```cpp
const int N = 2e5 + 5;
// 开N*20为4e6

int n, m, q, a[N], l, r, k, d[N], mp[N];  // 这里m是值域

int cnt, roots[N], sum[N * 20], ls[N * 20], rs[N * 20];
int build(int l, int r) {
	int p = ++cnt;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	return ls[p] = build(l, mid), rs[p] = build(mid + 1, r), p;
}
int copy(int rt) {   // 复制原树节点
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], sum[p] = sum[rt], p;
}
int update(int x, int l, int r, int rt) {
	int p = copy(rt); sum[p]++;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, l, mid, ls[p]);
	else rs[p] = update(x, mid + 1, r, rs[p]);
	return p;
}
int query(int l, int r, int k, int rt1, int rt2) {
	int mid = (l + r) >> 1, num = sum[ls[rt2]] - sum[ls[rt1]];
	if (l == r) return l;
	if (k <= num) return query(l, mid, k, ls[rt1], ls[rt2]);
	else return query(mid + 1, r, k - num, rs[rt1], rs[rt2]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i], d[i] = a[i];
	sort(d + 1, d + n + 1);
	m = unique(d + 1, d + n + 1) - d - 1;
	for (int i = 1; i <= n; i++) {
		int val = lower_bound(d + 1, d + m + 1, a[i]) - d;
		mp[val] = a[i], a[i] = val;
	}
	roots[0] = build(1, m);
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], 1, m, roots[i - 1]);
	while (q--) {
		cin >> l >> r >> k;
		cout << mp[query(1, m, k, roots[l - 1], roots[r])] << '\n';
	}
}
```

## P4137 Rmq Problem / mex

这题可以 bitset 配合莫队水过。不过使用可持久化权值线段树是高贵的在线做法。

首先 $\operatorname{mex} \in [0,n+1]$，这题不用离散化。对于每一个 $a_i$，在权值线段树上维护它最后一次出现的位置，开 $n$ 棵权值线段树，第 $i$ 棵维护序列的 $[1,i]$ 前缀，查询在 $[1,r]$ 中找最小的且最后一次出现位置小于 $l$ 的数，在第 $r$ 棵线段树上二分求解即可。复杂度 $O((n+q) \log n)$。

```cpp
const int N = 2e5 + 5;

int n, q, a[N], l, r;

int cnt, roots[N], last[N * 20], ls[N * 20], rs[N * 20];
int copy(int rt) {
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], last[p] = last[rt], p;
}
int update(int x, int c, int l, int r, int rt) {
	int p = copy(rt);
	if (l == r) return last[p] = c, p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, c, l, mid, ls[p]);
	else rs[p] = update(x, c, mid + 1, r, rs[p]);
	last[p] = min(last[ls[p]], last[rs[p]]);
	return p;
}
int query(int x, int l, int r, int rt) {
	if (l == r) return l;
	int mid = (l + r) >> 1;
	if (last[ls[rt]] < x) return query(x, l, mid, ls[rt]);
	else return query(x, mid + 1, r, rs[rt]);
}

void _main() {
	cin >> n >> q;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], i, 0, n + 1, roots[i - 1]);
	while (q--) {
		cin >> l >> r;
		cout << query(l, 0, n + 1, roots[r]) << '\n';
	}
}
```

## P4587 [FJOI2016] 神秘数

从暴力开始思考，先对 $[l,r]$ 区间排序，设当前值域为 $[1,V]$，扫一遍区间，若 $a_i>V+1$，此时 $V+1$ 会被跳过而表示不出来，故答案为 $V+1$，否则令 $V \gets a_i+V$ 并继续扫描。

然后我们开 $n$ 棵权值线段树，模拟上述过程，因为 $V$ 每次至少增加一倍，复杂度为 $O(q \log n \log \sum a)$，是正确的。

```cpp
const int N = 2e5 + 5;
int n, q, a[N], l, r;

int cnt, roots[N], sum[N << 5], ls[N << 5], rs[N << 5];
int copy(int rt) {
	int p = ++cnt;
	return ls[p] = ls[rt], rs[p] = rs[rt], sum[p] = sum[rt], p;
}
int update(int x, int c, int l, int r, int rt) {
	int p = copy(rt); sum[p] += c;
	if (l == r) return p;
	int mid = (l + r) >> 1;
	if (x <= mid) ls[p] = update(x, c, l, mid, ls[p]);
	else rs[p] = update(x, c, mid + 1, r, rs[p]);
	return p;
}
int query(int tl, int tr, int l, int r, int rt1, int rt2) {
	if (tl <= l && r <= tr) return sum[rt1] - sum[rt2];
	int mid = (l + r) >> 1, res = 0;
	if (tl <= mid) res += query(tl, tr, l, mid, ls[rt1], ls[rt2]);
	if (tr > mid) res += query(tl, tr, mid + 1, r, rs[rt1], rs[rt2]);
	return res;
}

void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	for (int i = 1; i <= n; i++) roots[i] = update(a[i], a[i], 1, 1e9, roots[i - 1]);
	cin >> q;
	while (q--) {
		cin >> l >> r;
		int res = 1;
		while (true) {
			int val = query(1, res, 1, 1e9, roots[r], roots[l - 1]);
			if (val >= res) res = val + 1;
			else break;
		} cout << res << '\n';
	}
}
```$AKB164$, '数据结构', array['可持久化线段树', '主席树', '权值线段树'], 'col-ds-persistent-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-persistent-segtree-template', '可持久化线段树（单点修改区间求和 普通模板）', $AKB165$## 算法原理

本模板与P3919版本共享相同的可持久化核心思想——"只新建修改路径上的节点，其余节点与旧版本共享"。可持久化线段树的关键洞察在于：一次单点修改只影响从根到叶的 $O(\log n)$ 个节点，因此只需为这 $\log n$ 个节点创建新副本，其余子树指针直接复用旧版本。新版本与父版本共享 $O(n - \log n)$ 个节点，额外空间开销仅为 $O(\log n)$。

本模板与P3919版本的关键区别在于修改语义。P3919是"覆盖式赋值"（point assign）：叶节点执行 `nd[rt].val = k`，内部节点回溯时 `val = 左.val + 右.val` 重新从子节点求和。而本模板是"增量累加"（point add）：在修改路径上的每个节点（包括内部节点和叶节点）都执行 `nd[rt].val += k`。这一差异的本质原因是：在"区间求和"语义下，位置i增加k意味着所有范围包含i的节点（即整条根到叶路径上的每个节点）的区间和都应增加k。因此沿路径每个节点直接 += k 即可正确维护区间和，无需在回溯时从子节点重新求和。

从实现细节看，本模板的insert递归函数在复制旧节点后立即 `nd[rt].val += k`，然后判断是否为叶节点（若是则return，因为增量已经施加），否则递归进入包含i的那一侧子树创建新节点。注意本模板的insert末尾没有 `nd[rt].val = 左+右` 的回溯语句——因为增量k已经沿路径逐层施加，每个节点的val已经正确反映了"+k"后的区间和。相比之下，P3919的insert末尾必须有 `nd[rt].val = 左+右`，因为叶节点被覆盖为k（不是+k），内部节点的val必须从子节点重新计算才能反映覆盖后的正确和。

本模板的查询操作（myget）支持任意区间[ml, mr]的求和，采用标准线段树区间查询的三分支递归：完全不相交返回0、完全包含返回节点val、部分相交则递归左右子树求和。查询操作不创建新版本（与P3919不同），因此本模板的版本号仅在修改时递增。空间预分配使用经验上界 `nd.resize(n * 40)`，即假设最多n个初始节点加m次修改各 $\log n$ 个新节点，n*40是一个足够宽松的常数上界。

## 数据结构图示

```
增量累加示意 (位置 i 增加 k, 范围 [1,8]):

版本0 (旧):  [1,8]v -------- [1,4]v -------- [5,8]v -------- [3,4]v ...
                |                |                |
版本1 (新):  [1,8]*+k ------ [1,4]*+k ------ [5,8]v --------- [3,4]v ...
                                                               |
                                                   (含i的路径上每节点 +=k, 其余共享)

  * = 新建节点    v = 共享旧版本    +k = 该节点 val += k

路径细节 (位置 i=3, 增加 k, 范围 [1,8]):
  版本0:  root0 -> [1,8]v  -> [1,4]v  -> [3,4]v  -> [3,3]v   (含i=3的路径)
                          -> [1,2]v                      (不含i, 共享)
                 -> [5,8]v                               (不含i, 共享)

  版本1:  root1 -> [1,8]*+k -> [1,4]*+k -> [3,4]*+k -> [3,3]*+k (路径上全部新建并 +=k)
                             -> [1,2]v                        (共享版本0)
                  -> [5,8]v                                   (共享版本0)

区间查询示意 (在版本1查询 [2,5] 的和):
  [1,8]*  -> 部分相交, 递归左右
    [1,4]* -> 部分相交, 递归左右
      [1,2]v -> 完全包含 [2,5], 返回 val
      [3,4]* -> 完全包含 [2,5], 返回 val
    [5,8]v -> 部分相交, 递归左右
      [5,6]v -> 完全包含, 返回 val
      [7,8]v -> 不相交, 返回 0
  (全区间 [1,n] 查询时直接返回根 val, 小优化)
```

## 核心操作详解

**init(rt, l, r, A)**：递归建树。若l==r为叶节点赋值A[l]；否则分配左右孩子下标（`++nd_idx`），递归建子树，回溯 `val = 左.val + 右.val`。与P3919完全相同。

**init(n, m)（重载）**：顶层建树。`nd.resize(n * 40)` 预分配经验上界（比P3919的 `n*4 + m*ceil(log2(n))` 更宽松但更简单）。手动建根层：取mid，分配左右孩子递归建树，回溯求和。`++rt_idx` 前进到版本1。

**insert(rt, old, l, r, i, k)**：核心修改函数（递归版）。`nd[rt] = nd[old]` 复制旧节点。`nd[rt].val += k` 对当前节点施加增量。若l==r则return（叶节点，增量已施加）。否则取mid：若i在左半，分配新左孩子并递归（右子树共享）；若i在右半，分配新右孩子并递归（左子树共享）。注意末尾无需回溯求和——因为沿路径每层都已 += k。关键点：与P3919的 `nd[rt].val = k`（仅叶覆盖）+ `val = 左+右`（内部回溯）不同，本模板是 `nd[rt].val += k`（路径每层都加）。

**insert(old, n, i, k)（重载）**：顶层修改入口。`root[rt_idx] = root[old]` 复制旧根，`root[rt_idx].val += k` 施加增量。按i与mid关系分配新子节点并递归。`++rt_idx` 版本号递增。

**myget(rt, l, r, ml, mr)**：标准区间查询递归。三分支：`l > mr || r < ml`（不相交）返回0；`ml <= l && mr >= r`（完全包含）返回 `nd[rt].val`；否则取mid递归左+右之和。

**myget(ver, n, ml, mr)（重载）**：顶层查询入口。若 `ml==1 && mr==n`（全区间查询）直接返回 `root[ver].val`（小优化，避免递归）。否则手动分裂根层，递归左+右子树之和。

## 逐行代码解析

### 全局变量与节点结构

```cpp
#include<bits/stdc++.h>
using namespace std;
struct node
{
	long long val;       // 节点维护的区间和
	int son_l,son_r;     // 左右孩子下标, -1表示空
	node():val(0),son_l(-1),son_r(-1){}
};
int rt_idx = 0;   // 当前版本号
int nd_idx = 0;    // 节点分配计数器
vector<node> root; // 各版本的根节点
vector<node> nd;   // 节点存储池
```

- `node` 结构体：`val` 存区间和（`long long`，防止区间和溢出），`son_l/son_r` 是左右孩子在 `nd` 池中的下标，构造时初始化为 `-1` 表示空。
- `rt_idx` 是当前版本号，`nd_idx` 是节点分配计数器（新节点下标从 1 开始递增）。
- `root` 存每个版本的根节点，`nd` 是全局节点池；两者都是 `vector<node>`，靠下标引用节点，不持有指针。

### 建树 init（递归建树 + 顶层建树）

```cpp
// 递归建树: 在 nd[rt] 处建区间 [l,r]
void init(int rt,int l,int r,const vector<long long>& A)
{
	if(l == r) nd[rt].val = A[l]; // 叶节点赋值
	else
	{
		int mid = (l + r) >> 1;
		nd[rt].son_l = ++nd_idx;          // 分配左孩子
		init(nd[rt].son_l,l,mid,A);        // 递归建左子树
		nd[rt].son_r = ++nd_idx;          // 分配右孩子
		init(nd[rt].son_r,mid + 1,r,A);   // 递归建右子树
		nd[rt].val = nd[nd[rt].son_l].val + nd[nd[rt].son_r].val; // 回溯求和
	}
}
// 顶层建树: 读入数组, 预分配, 建版本0
void init(int n,int m)
{
	vector<long long> A(n + 1);
	root.resize(m + 1);
	nd.resize(n * 40);   // 经验上界, 比 P3919 的 n*4+m*log(n) 更宽松
	for(int i = 1;i <= n;i++) cin >> A[i];
	int l = 1,r = n;
	int mid = (l + r) >> 1;
	// 手动建根层
	root[rt_idx].son_l = ++nd_idx;
	init(root[rt_idx].son_l,l,mid,A);
	root[rt_idx].son_r = ++nd_idx;
	init(root[rt_idx].son_r,mid+1,r,A);
	root[rt_idx].val = nd[root[rt_idx].son_l].val + nd[root[rt_idx].son_r].val;
	++rt_idx; // 版本0建好, rt_idx -> 1
}
```

- 递归 `init(rt,l,r,A)`：`l==r` 时叶节点直接 `nd[rt].val = A[l]`；否则按 `mid=(l+r)>>1` 分治，先 `++nd_idx` 分配孩子下标再递归，回溯时 `val = 左.val + 右.val`。
- 顶层 `init(n,m)`：`root.resize(m+1)` 预留版本槽、`nd.resize(n*40)` 预分配节点池，读入 `A[1..n]`。
- 建版本 0 时手动建根层（左右孩子递归建树后回溯求和），最后 `++rt_idx` 使版本号前进到 1（下一次修改写入 `root[1]`）。
- 边界：下标一律 1-based（`A` 大小为 `n+1`、叶节点取 `A[l]`）；右区间左端点是 `mid+1`，别写成 `mid`。

### 修改 insert（递归修改 + 顶层修改）

```cpp
// 递归修改: 基于旧节点 old, 在新节点 rt 处创建增量路径
void insert(int rt,int old,int l,int r,int i,long long k)
{
	nd[rt] = nd[old];  // 关键: 先整体复制旧节点 (val + 两个子指针)
	nd[rt].val += k;    // 增量累加: 当前节点区间包含i, 区间和增加k
	if(l == r) return;  // 叶节点: 增量已施加, 直接返回 (无需回溯)
	int mid = (l + r) >> 1;
	if(i <= mid)        // 修改在左半: 新建左孩子, 右孩子共享
	{
		nd[rt].son_l = ++nd_idx;
		insert(nd[rt].son_l,nd[old].son_l,l,mid,i,k);
		// nd[rt].son_r 从 old 复制, 共享旧版本右子树
	}
	else                // 修改在右半: 新建右孩子, 左孩子共享
	{
		nd[rt].son_r = ++nd_idx;
		insert(nd[rt].son_r,nd[old].son_r,mid + 1,r,i,k);
	}
	// 注意: 末尾无 nd[rt].val = 左+右, 因为 +=k 已沿路径逐层施加
}
// 顶层修改: 基于版本 old, 创建新版本
void insert(int old,int n,int i,long long k)
{
	int l = 1;int r = n;
	int mid = (l + r) >> 1;
	root[rt_idx] = root[old];  // 复制旧版本根
	root[rt_idx].val += k;     // 根节点也 += k
	if(i <= mid)               // 修改在左半
	{
		root[rt_idx].son_l = ++nd_idx;
		insert(root[rt_idx].son_l,root[old].son_l,l,mid,i,k);
	}
	else                       // 修改在右半
	{
		root[rt_idx].son_r = ++nd_idx;
		insert(root[rt_idx].son_r,root[old].son_r,mid + 1,r,i,k);
	}
	++rt_idx; // 版本号递增
}
```

- 递归 `insert`：先 `nd[rt] = nd[old]` 整体复制旧节点（val 与两个子指针），再对当前节点 `val += k`——因为所有区间包含 i 的节点，其区间和都应增加 k。
- `i <= mid` 时只新建左孩子、右孩子沿用旧指针共享；否则对称处理右半，另一侧保持共享，未修改的子树被复用。
- 叶节点 `l==r` 时直接 `return`（增量已施加），函数末尾没有回溯求和：与 P3919 的覆盖式不同，这是增量式实现的关键。
- 顶层 `insert`：把 `root[rt_idx]` 复制自 `root[old]` 并 `val += k`，按 i 与 mid 关系只新建一侧子树，最后 `++rt_idx` 版本号递增。

### 查询 myget（递归查询 + 顶层查询）

```cpp
// 递归区间查询: 在 nd[rt] 子树中查询 [ml,mr] 的和
long long myget(int rt,int l,int r,int ml,int mr)
{
	if(l > mr || r < ml) return 0;              // 完全不相交
	if(ml <= l && mr >= r) return nd[rt].val;   // 完全包含: 直接返回
	int mid = (l + r) >> 1;
	return myget(nd[rt].son_l,l,mid,ml,mr) + myget(nd[rt].son_r,mid + 1,r,ml,mr); // 部分相交: 递归求和
}
// 顶层区间查询: 在版本 ver 中查询 [ml,mr] 的和
long long myget(int ver,int n,int ml,int mr)
{
	if(ml == 1 && mr == n) return root[ver].val; // 全区间优化: 直接返回根值
	else
	{
		int l = 1,r = n;
		int mid = (l + r) >> 1;
		// 手动分裂根层, 递归左右子树求和
		return myget(root[ver].son_l,l,mid,ml,mr) + myget(root[ver].son_r,mid + 1,r,ml,mr);
	}
}
```

- 递归 `myget` 采用标准三分支：完全不相交（`l>mr || r<ml`）返回 0；完全包含（`ml<=l && mr>=r`）直接返回 `nd[rt].val`；部分相交则递归左右子树求和。
- 不相交判断用 `||`（任一条件成立即不相交），包含判断用 `&&`（两个边界都要满足），这两个符号方向容易写反。
- 顶层 `myget` 全区间 `ml==1 && mr==n` 时直接返回根值（小优化，避免递归）；否则手动分裂根层后递归左右。
- 查询不创建新版本，版本号只在修改时递增。

### main

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	int N,M;
	cin >> N >> M;
	init(N,M); // 建版本0
	for(int i = 1;i <= M;i++)
	{
		int v,op;
		cin >> v >> op;        // v = 基于的版本号, op = 操作类型
		if(op == 1)            // 修改: 基于版本v, 位置idx增加k
		{
			int idx;
			long long k;
			cin >> idx >> k;
			insert(v,N,idx,k); // 创建新版本
		}
		else                  // 查询: 在版本v中查询区间[x,y]的和
		{
			int x,y;
			cin >> x >> y;
			cout << myget(v,N,x,y) << '\n';
			// 注意: 查询不创建新版本 (与 P3919 不同)
		}
	}
	return 0;	
} 
```

- `ios::sync_with_stdio(false)` 关同步、`cin.tie(nullptr)` 解绑，加速大量输入输出。
- 先 `init(N,M)` 建版本 0，再循环处理 M 个操作。
- `op==1` 是修改：读入版本 v、位置 idx、增量 k，调用 `insert(v,N,idx,k)` 创建新版本；`op==2`（else 分支）是查询：在版本 v 查询区间 [x,y] 并输出。
- `k` 与 `val` 用 `long long`，避免大增量/区间和溢出；版本号 v 从 0 开始（版本 0 是最初状态）。

## 复杂度分析

时间复杂度：建树 $O(n)$；单次修改 $O(\log n)$（沿修改路径递归 $\log n$ 层，每层 $O(1)$）；单次区间查询 $O(\log n)$（标准线段树区间查询最多访问 $O(\log n)$ 个节点）。m次操作总时间 $O(n + m \cdot \log n)$。

空间复杂度：$O(n + m \cdot \log n)$。初始建树约4n个节点，每次修改新增 $\log n$ 个节点。代码使用 `nd.resize(n * 40)` 作为经验上界，n*40对于n个初始节点加m次修改（m次各 $\log n$ 个新节点）在多数竞赛数据范围内足够。

## 适用场景

本模板适用于需要历史版本的区间求和场景，包括：历史区间和查询（在任意版本上查询某区间的和）、可持久化数组（将单点查询视为区间[i,i]的特例）、增量式版本管理（每次修改是"增加k"而非"覆盖为k"，适合累加统计）。与P3919的"覆盖式"不同，本模板的"增量式"更适合需要逐步累加的统计场景，如按时间线累加贡献的历史和查询。

## 常见陷阱与注意事项

- **增量式 vs 覆盖式的混淆**：本模板的 `nd[rt].val += k` 是增量累加，每次修改是"位置i增加k"。若题目要求"位置i改为k"（覆盖语义），则必须使用P3919的 `nd[rt].val = k` + 回溯求和方式，否则结果错误。
- **insert末尾无回溯求和**：本模板的递归insert末尾没有 `nd[rt].val = 左+右`，因为增量k沿路径逐层施加后每个节点已正确。若误加此行不会出错（因为左+右也等于原值+k），但浪费一次计算。若误删 `nd[rt].val += k` 则区间和维护错误。
- **空间预分配 n*40**：这是一个经验值而非严格上界。当n较小但m很大时（如n=10, m=10^6），n*40=400可能不足以容纳 $4n + m \cdot \log(n)$ 个节点，导致越界。建议根据实际数据范围精确计算或使用更大的上界。
- **全区间查询优化**：`myget` 重载中 `ml==1 && mr==n` 时直接返回 `root[ver].val`，这一优化依赖根节点val维护了整个区间的和。若修改逻辑有误导致根val不正确，则全区间查询也会出错。
- **查询不创建新版本**：与P3919不同，本模板的查询操作不执行 `root[rt_idx++] = root[v]`。版本号仅在修改时递增。若题目要求查询也产生版本号则需补充此行。
- **n=1 时无限递归**：当 n=1 时，顶层 `init(n,m)` 手动分裂根层会递归出 `l=2, r=1` 的非法区间，而递归 `init` 的终止条件只有 `l==r`，无法收敛，导致无限递归/栈溢出。建议在建树/修改/查询入口对 n==1 单独特判，或假设输入 n≥2。

## 对比与扩展

- **增量式（本模板）vs 覆盖式（P3919）**：增量式 `val += k` 沿路径每层累加，末尾无回溯；覆盖式 `val = k` 仅叶赋值，内部回溯 `val = 左+右`。增量式适合"加"语义，覆盖式适合"赋值"语义。两者共享相同的可持久化框架（复制旧节点+共享未修改子树）。
- **可持久化线段树 vs 可持久化BIT**：线段树支持任意区间查询（区间和、区间最值等），更通用；BIT仅支持前缀和类操作，但常数更小、代码更短，适合仅需前缀和的场景。
- **扩展：主席树（Chairman Tree）**：将离散化后的权值线段树持久化，前缀[1..i]作为版本i，通过版本i与版本l-1的差分在线段树上二分，可在 $O(\log n)$ 内查询区间 $[l,r]$ 的第k小值。
- **扩展：可持久化并查集**：利用可持久化数组记录fa数组的历史版本，支持回退到历史版本的并查集操作。
- **扩展：可持久化分块**：将分块思想持久化，适用于修改和查询复杂度可以放宽到 $O(\sqrt{n})$ 的场景。$AKB165$, '数据结构', array['数据结构', '可持久化线段树', '历史版本', '区间求和'], 'col-ds-persistent-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-prefix-diff-overview', '前缀和与差分总览（一维 / 二维 / 树上）', $AKB166$## 算法原理

本页是「前缀和与差分」的二级栏目索引。前缀和负责把区间查询降到 $O(1)$，差分负责把区间修改降到 $O(1)$，两者互为逆运算；二阶前缀和/二阶差分再用树状数组把「改」与「查」都压到 $O(\log n)$。

**学习顺序**：一维前缀和 → 一维差分 → 二维前缀和与差分 → 树上前缀和与差分 → 二阶前缀和/二阶差分（需要先会树状数组）。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 用哪篇 |
|---|---|
| 静态数组区间和 | 一维前缀和（区间和查询） |
| 多次区间加、最后统一查询 | 一维差分（区间加·批量更新） |
| 子矩阵和 | 二维前缀和与差分 |
| 子矩阵加、最后统一查询 | 二维前缀和与差分（同一页下半部分） |
| 树上路径点权和 | 树上前缀和与差分 |
| 树上路径点权修改 | 树上前缀和与差分（同一页下半部分） |
| 修改与查询交替、需要二阶量 | 二阶前缀和 / 二阶差分（树状数组维护） |

## 逐行代码解析

本页只做导航，不重复贴代码；各子页都有完整实现与逐行解析，页面会自动渲染对应 `.cpp`。

## 复杂度分析

- 一维/二维前缀和：预处理 $O(n)$ 或 $O(nm)$，查询 $O(1)$。
- 一维/二维差分：修改 $O(1)$，还原 $O(n)$ 或 $O(nm)$。
- 树上版本：一次 DFS 预处理，路径操作转为 $O(1)$ 组合或 $O(\log n)$ 查询。
- 二阶前缀和/二阶差分：树状数组维护，单次修改与查询均 $O(\log n)$。

## 适用场景

- 静态区间/子矩阵求和。
- 多次区间修改后一次性求值（差分）。
- 树上路径统计、路径修改。
- 「区间加等差数列 + 单点查询」等需要二阶差分的场景。

## 常见陷阱与注意事项

- 差分数组的右端点要写 `r+1`，越界时按数组上限处理。
- 二维差分四个角的正负号容易写反。
- 树上前缀和与树差分依赖 LCA，注意根节点与 `dep` 的处理。
- 二阶前缀和/二阶差分需要两棵树状数组，修改时两棵要同步。
- 负数取模与 `long long` 溢出要按题目范围判断。

## 对比与扩展

- 前缀和 vs 线段树：静态用前缀和，动态用线段树/树状数组。
- 差分 vs 线段树懒标记：离线批量修改用差分更轻。
- 可扩展到高维前缀和（SOS DP）与树上差分结合 LCA 的路径统计。$AKB166$, '数据结构', array['前缀和', '差分', '总览', '学习路线', '二阶前缀和'], null, null, 'knowledge'),
('Xesir', 'col-ds-prefix-sum-1d--xesir', '一维前缀和 · Xesir', $AKB167$## 算法原理

> 给定一个序列 a，有 m 次询问，每次询问 [l,r] 区间内的元素和。

先思考最朴素的暴力做法：每次遍历 $[l,r]$ 并累加得到答案。最坏情况下复杂度 $O(nm)$，必爆无疑。如果要优化，就必须减少重复计算。

我们注意到 $[l,r]=[1,r]-[1,l-1]$，而 $[1,i]$ 的区间和是很好维护的。定义 $h$ 为 $a$ 的前缀和数组，$h[i]$ 为 $[1,i]$ 区间和，即 $h[i]=a[1]+a[2]+\dots+a[i]$，那么只需要 $O(n)$ 就可以预处理出 $h$ 数组，后续每次查询仅需 $O(1)$ 时间。

## 核心公式 / 状态定义与转移方程

前缀和定义：

$$
h[i] = \sum_{k=1}^{i} a[k] = a[1] + a[2] + \dots + a[i]
$$

递推计算：

$$
h[i] = h[i-1] + a[i]
$$

区间和查询：

$$
\sum_{k=l}^{r} a[k] = h[r] - h[l-1]
$$

- 数组下标从 1 开始，`a[0]` 默认为 0，这样 $l=1$ 时 $h[0]=0$ 公式仍成立，不需要特判。

## 逐行代码解析

### 模块一：读入并原地求前缀和

```cpp
#include <bits/stdc++.h>
using namespace std;
int a[100010];
int main()
{
    int n,m;
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        cin>>a[i];
        a[i]+=a[i-1];
    }
```

- 读入的同时顺手做 `a[i]+=a[i-1]`，原地把 `a` 变成前缀和数组，省下一个数组。
- 下标从 1 开始，`a[0]` 作为全局变量默认为 0，充当前缀和的起点。

### 模块二：区间查询

```cpp
    for(int i=1;i<=m;i++){
        int l,r;cin>>l>>r;
        cout<<a[r]-a[l-1]<<endl;
    }
    return 0;
}
```

- `a[r] - a[l-1]` 就是 $[l,r]$ 的区间和，单次 $O(1)$。
- 因为 `a` 被原地改成了前缀和，原始数值不再保留。

## 复杂度分析

- **预处理**：$O(n)$，一次线性累加。
- **单次查询**：$O(1)$，$m$ 次查询总代价 $O(n+m)$。
- **空间复杂度**：$O(n)$，本代码只开了一个数组。

## 适用场景

- **多次区间和查询、几乎不修改**：预处理 $O(n)$ 后单次查询 $O(1)$，适合查询次数远大于 $n$ 的静态数据。
- **静态数组**：数据读入后整体不变。
- **不适用**：需要单点修改或区间修改时，前缀和每次要 $O(n)$ 重算，应改用树状数组或线段树。

## 常见陷阱与注意事项

1. **数组下标从 1 开始**：`a[0]=0`，避免 $l=1$ 时越界；若从 0 开始就需要特判。
2. **数据类型溢出**：前缀和累加可能超过 `int` 范围，务必用 `long long`。本代码用的是 `int`，数据大时要留意。
3. **原地修改 vs 额外数组**：本代码原地修改 `a`，省空间但丢了原始数据；要保留就开两个数组。
4. **不支持动态修改**：改 `a[i]` 会让所有 $h[j]\,(j\ge i)$ 都要更新，单次 $O(n)$。
5. **适用范围**：只对可叠加、可抵消的运算有效（加法、异或等），求区间最值不适用。

## 对比与扩展

- **前缀异或和**：异或满足 $x\oplus x=0$，区间异或也可用前缀和思想，$\text{xor}(l,r)=h[r]\oplus h[l-1]$。
- **二维前缀和**：扩展到矩阵可求子矩阵和。
- **前缀和优化 DP**：很多 DP 转移里含区间求和，用前缀和能把 $O(n)$ 的转移压到 $O(1)$，总复杂度从 $O(n^2)$ 降到 $O(n)$。$AKB167$, '数据结构', array['前缀和', '一维', '区间和', '预处理', '数据结构'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-prefix-sum-1d', '一维前缀和（区间和查询）', $AKB168$## 算法原理

一维前缀和（Prefix Sum）是最基础的预处理技巧之一：给定一个长度为 $n$ 的数组 $a$，预处理出前缀和数组 $S$，使得 $S[i]$ 表示 $a[1] + a[2] + \cdots + a[i]$（即前 $i$ 个元素的和）。预处理后，可以在 $O(1)$ 时间内回答任意区间 $[l, r]$ 的和。

### 核心公式

前缀和定义：

$$S[i] = \sum_{k=1}^{i} a[k] = a[1] + a[2] + \cdots + a[i]$$

递推计算：

$$S[i] = S[i-1] + a[i]$$

区间和查询（$[l, r]$ 区间内所有元素之和）：

$$\sum_{k=l}^{r} a[k] = S[r] - S[l-1]$$

### 为什么从 1 开始编号

代码中数组下标从 1 开始，`A[0] = 0`（`vector` 默认初始化为 0）。这样做的好处是：
- 当 $l = 1$ 时，$S[l-1] = S[0] = 0$，公式仍然成立，不需要特判。
- 边界情况统一处理，代码更简洁。

## 数据结构图示

### 构造过程示意

以数组 $a = [0, 3, 1, 4, 2, 5]$（下标从 1 开始，$a[0] = 0$ 为哨兵）为例，演示前缀和数组 $S$ 的构造过程：

```
原始数组 a:
  下标:   0   1   2   3   4   5
  值:     0   3   1   4   2   5

逐步构造前缀和 S:

i=1:  S[1] = S[0] + a[1] = 0 + 3 = 3
  S = [0, 3, _, _, _, _]
       ↑   ↑
      0→1 累加

i=2:  S[2] = S[1] + a[2] = 3 + 1 = 4
  S = [0, 3, 4, _, _, _]
          ↑   ↑
         3→4 累加

i=3:  S[3] = S[2] + a[3] = 4 + 4 = 8
  S = [0, 3, 4, 8, _, _]
              ↑   ↑
             4→8 累加

i=4:  S[4] = S[3] + a[4] = 8 + 2 = 10
  S = [0, 3, 4, 8, 10, _]
                  ↑    ↑
                 8→10 累加

i=5:  S[5] = S[4] + a[5] = 10 + 5 = 15
  S = [0, 3, 4, 8, 10, 15]
                       ↑   ↑
                      10→15 累加

最终前缀和 S:
  下标:   0    1    2    3    4     5
  值:     0    3    4    8   10    15
         └──┬──┴┬──┴┬──┴┬───┴┬────┘
           3   1    4    2     5    ← 对应 a[i] 的值
```

每个 $S[i]$ 都是前 $i$ 个元素的累加和，数组从左到右逐步"堆积"。

### 区间查询示意

查询 $\text{sum}(2, 4)$ 即 $a[2] + a[3] + a[4] = 1 + 4 + 2 = 7$：

```
S 数组:  [0, 3, 4, 8, 10, 15]
               ↑          ↑
           S[l-1]=4    S[r]=10

  sum(2, 4) = S[4] - S[1] = 10 - 3 = 7
                          = 1+4+2 = 7 ✓

图示:
  a:      [_, 3, 1, 4, 2, 5]
               └──┬──┘
                  7  ← 区间 [2,4] 的和

  S[4] = 3+1+4+2 = 10  ──┐
  S[1] = 3        ──┤    ├→ 10 - 3 = 7
  减去后剩下: 1+4+2 = 7 ──┘
```

理解要点：$S[r]$ 包含了前 $r$ 项的和，$S[l-1]$ 包含了前 $l-1$ 项的和，两者相减恰好剩下第 $l$ 到第 $r$ 项的和。

### 几何直观

把数组元素想象成柱状图的高度，前缀和就是"从左到右不断累加的总面积"：

```
a = [3, 1, 4, 2, 5] 的柱状图：

    █
    █     █
    █  █  █     █
    █  █  █  █  █
    █  █  █  █  █
    └──┴──┴──┴──┘
    1  2  3  4  5

S[3] = 3+1+4 = 8 对应前 3 根柱子的总面积。
sum(2,4) = S[4] - S[1] = 10 - 3 = 7 对应第 2~4 根柱子的面积。
```

## 逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int N, T;
    cin >> N >> T;
    vector<long long> A(N + 1);         // 下标 0~N，A[0] = 0
    for(int i = 1; i <= N; i++) cin >> A[i];
    for(int i = 1; i <= N; i++) A[i] += A[i - 1];   // 递推求前缀和
    for(int i = 1; i <= T; i++)
    {
        int l, r;
        cin >> l >> r;
        cout << A[r] - A[l - 1] << '\n';            // 区间和 = S[r] - S[l-1]
    }
    return 0;
}
```

逐段分析：

- **`vector<long long> A(N + 1)`**：开 $N+1$ 空间，下标从 0 到 $N$。`A[0]` 默认为 0，作为前缀和的起点。
- **`for(int i = 1; i <= N; i++) cin >> A[i]`**：读入原始数组，存入 $A[1] \sim A[N]$。
- **`A[i] += A[i - 1]`**：原地构造前缀和。执行后 `A[i]` 不再是原值，而是前 $i$ 项和。$O(n)$ 时间。
- **`A[r] - A[l - 1]`**：区间和查询，$O(1)$ 时间。

### 使用 long long 的原因

前缀和可能很大：若每个元素为 $10^9$，$n = 10^5$，总和可达 $10^{14}$，超出 `int`（约 $2 \times 10^9$）范围。使用 `long long` 避免溢出。

## 复杂度分析

| 操作 | 时间 |
|---|---|
| 构造前缀和数组 | $O(n)$ |
| 单次区间和查询 | $O(1)$ |
| 单点修改（不支持） | $O(n)$（需重新计算后续前缀和） |

预处理 $O(n)$，之后每次区间和查询 $O(1)$，$q$ 次查询总代价 $O(n + q)$。

## 适用场景

- **多次区间和查询、几乎不修改**：预处理 $O(n)$ 后单次查询 $O(1)$，适合 $q$ 远大于 $n$ 的静态数据
- **静态数组**：数据读入后整体不变
- **不适用**：需要单点修改或区间修改时，前缀和每次要 $O(n)$ 重算，应改用树状数组或线段树

## 常见陷阱与注意事项

1. **数组下标从 1 开始**
   - 前缀和数组通常从下标 1 开始，`S[0] = 0`，避免 $l=1$ 时越界。
   - 若从 0 开始，公式变为 `sum(l, r) = S[r] - (l > 0 ? S[l-1] : 0)`，需特判。

2. **数据类型溢出**
   - 前缀和累加可能超过 `int` 范围，务必使用 `long long`。
   - 判断依据：元素最大值 × 元素个数是否超过 `int` 上限（约 $2 \times 10^9$）。

3. **原地修改 vs 额外数组**
   - 本代码原地修改 `A`，节省空间但丢失原始数据。
   - 若需保留原始数组，应开两个数组：`a[]` 存原值，`s[]` 存前缀和。

4. **不支持动态修改**
   - 若修改 $a[i]$，所有 $S[j]$（$j \ge i$）都要更新，$O(n)$ 时间。
   - 动态修改+区间查询应使用**树状数组**或**线段树**。

5. **适用范围**
   - 前缀和只对**可叠加、可抵消**的运算有效：加法、减法、异或（自身逆运算）。
   - 不适用于求区间最大值、最小值（需用 ST 表或线段树）。

## 扩展应用

### 前缀异或和

异或满足：$x \oplus x = 0$，因此区间异或和也可用前缀和思想：

$$\text{xor}(l, r) = S[r] \oplus S[l-1]$$

### 二维前缀和

扩展到二维矩阵，可求子矩阵和。详见二维前缀和知识点。

### 前缀和优化 DP

许多 DP 转移方程中包含区间求和，可用前缀和将 $O(n)$ 的转移优化为 $O(1)$，总复杂度从 $O(n^2)$ 降至 $O(n)$。$AKB168$, '数据结构', array['数据结构', '前缀和', '一维', '区间查询', '预处理', '数学'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-prefix-sum-2d', '二维前缀和与差分', $AKB169$## 算法原理

二维前缀和是一维前缀和的扩展：给定一个 $n \times m$ 的矩阵 $a$，预处理出前缀和矩阵 $S$，使得 $S[i][j]$ 表示以 $(1,1)$ 为左上角、$(i,j)$ 为右下角的子矩阵中所有元素之和。预处理后，可以在 $O(1)$ 时间内回答任意子矩阵的和。

### 核心公式

前缀和矩阵定义：

$$S[i][j] = \sum_{x=1}^{i} \sum_{y=1}^{j} a[x][y]$$

### 递推构造（容斥原理）

$$S[i][j] = a[i][j] + S[i-1][j] + S[i][j-1] - S[i-1][j-1]$$

**容斥解释**：
- $a[i][j]$：当前格的值
- $+ S[i-1][j]$：加上上方矩形的和
- $+ S[i][j-1]$：加上左方矩形的和
- $- S[i-1][j-1]$：左上角重叠部分被加了两次，减去一次

### 子矩阵和查询

求以 $(x_1, y_1)$ 为左上角、$(x_2, y_2)$ 为右下角的子矩阵和：

$$\text{sum}(x_1, y_1, x_2, y_2) = S[x_2][y_2] - S[x_1-1][y_2] - S[x_2][y_1-1] + S[x_1-1][y_1-1]$$

**容斥解释**：
- $S[x_2][y_2]$：从 $(1,1)$ 到 $(x_2,y_2)$ 的大矩形
- $- S[x_1-1][y_2]$：减去上半部分（$x_1-1$ 行及以上）
- $- S[x_2][y_1-1]$：减去左半部分（$y_1-1$ 列及以左）
- $+ S[x_1-1][y_1-1]$：左上角被减了两次，加回来一次

## 数据结构图示

### 构造过程示意（容斥原理）

以 $3 \times 3$ 矩阵为例，演示 $S[2][2]$ 的计算：

```
原始矩阵 a:             前缀和矩阵 S:
   j=0  1  2  3            j=0  1  2  3
i=0  0  0  0  0          i=0  0  0  0  0
i=1  0  1  2  3          i=1  0  ?  ?  ?
i=2  0  4  5  6          i=2  0  ?  ?  ?
i=3  0  7  8  9          i=3  0  ?  ?  ?
```

逐步计算，按行优先顺序：

```
计算 S[1][1]:
  S[1][1] = a[1][1] + S[0][1] + S[1][0] - S[0][0]
          = 1 + 0 + 0 - 0 = 1

  S[1][1] 就是左上角 1×1 区域的和 = 1 ✓
  ┌─────┐
  │ 1   │
  └─────┘

计算 S[1][2]:
  S[1][2] = a[1][2] + S[0][2] + S[1][1] - S[0][1]
          = 2 + 0 + 1 - 0 = 3

  S[1][2] 是第 1 行前 2 列的和 = 1+2 = 3 ✓
  ┌──────────┐
  │ 1   2    │
  └──────────┘
   a[1][2]=2  +  S[1][1]=1  =  3

计算 S[2][1]:
  S[2][1] = a[2][1] + S[1][1] + S[2][0] - S[1][0]
          = 4 + 1 + 0 - 0 = 5

  S[2][1] 是第 1 列前 2 行的和 = 1+4 = 5 ✓
  ┌─────┐
  │ 1   │
  │ 4   │
  └─────┘

计算 S[2][2]:
  S[2][2] = a[2][2] + S[1][2] + S[2][1] - S[1][1]
          = 5 + 3 + 5 - 1 = 12

  验证: 1+2+4+5 = 12 ✓
```

**容斥图解 S[2][2]**：

```
        上矩形 S[1][2] = 3
        ┌─────────────┐
        │ 1     2     │
  左矩形 ├─────┬───────┤
S[2][1]=5│ 1   │  5    │  ← a[2][2] = 5
        │ 4   │       │
        └─────┴───────┘
          重叠 S[1][1]=1
          （被加了两次）

S[2][2] = a[2][2] + S[1][2] + S[2][1] - S[1][1]
        =    5    +    3    +    5    -    1   = 12
```

上方矩形 + 左方矩形 = 包含了左上重叠区域两次，所以要减去一次。

### 子矩阵和查询示意

查询以 $(2, 2)$ 为左上角、$(3, 3)$ 为右下角的子矩阵和：

```
S 矩阵:
     j=0   1    2    3
i=0  0    0    0    0
i=1  0    1    3    6
i=2  0    5   12   21
i=3  0   12   27   45

查询 (x1=2, y1=2) → (x2=3, y2=3):

  S[x2][y2] = S[3][3] = 45
    ┌─────────────────┐
    │ 1    2     3    │
    │ 4    5     6    │
    │ 7    8     9    │
    └─────────────────┘

  - S[x1-1][y2] = S[1][3] = 6
    ┌─────────────────┐
    │ 1    2     3    │  ← 减去这一行
    │ ─ ─ ─ ─ ─ ─ ─ │
    │ 4    5     6    │
    │ 7    8     9    │
    └─────────────────┘

  - S[x2][y1-1] = S[3][1] = 12
    ┌──┬──────────────┐
    │1 │  2     3     │
    │4 │  5     6     │  ← 减去这一列
    │7 │  8     9     │
    └──┴──────────────┘

  + S[x1-1][y1-1] = S[1][1] = 1
    ┌──┬──────────────┐
    │1 │  2     3     │
    ├──┼──────────────┤  ← 加回这个角（被减了两次）
    │4 │  5     6     │
    │7 │  8     9     │
    └──┴──────────────┘

结果: 45 - 6 - 12 + 1 = 28
验证: 5+6+8+9 = 28 ✓
```

公式记忆口诀：**大四角减上矩形、减左矩形、加回左上角**。

### 最终前缀和矩阵完整示例

```
原矩阵 a(3×3):          前缀和 S(3×3):
   1  2  3                 1   3   6
   4  5  6        →        5  12  21
   7  8  9                12  27  45

每个 S[i][j] 是左上 i×j 矩形的总和。
S[3][3] = 1+2+3+4+5+6+7+8+9 = 45 ✓
```

## 逐行代码解析

### 头文件与初始化

```cpp
#include<bits/stdc++.h>                        // 万能头，一次性包含所有标准库
using namespace std;                           // 使用 std 命名空间
int main()
{
    ios::sync_with_stdio(false);               // 关闭 C 与 C++ 流同步，加速 cin
    cin.tie(nullptr);cout.tie(nullptr);        // 解绑 cin/cout，避免读入前刷新输出
    int N,M,T;                                 // N 行、M 列、T 次查询
    cin >> N >> M >> T;                        // 读入规模与查询次数
    vector<vector<long long>> A(N + 1,vector<long long>(M + 1)); // 开 (N+1)×(M+1) 数组，第 0 行/列默认 0
```

- **开 `(N+1) × (M+1)` 的二维数组**：第 0 行和第 0 列均为 0（`vector` 默认初始化），这样当 $x_1=1$ 或 $y_1=1$ 时，$S[x_1-1][\cdot]$ 或 $S[\cdot][y_1-1]$ 自动为 0，无需特判。
- **用 `long long` 而非 `int`**：$n = m = 10^3$、每个元素 $10^9$ 时总和可达 $10^{15}$，`int` 会溢出。
- **`ios::sync_with_stdio(false)` + `cin.tie(nullptr)`**：关同步、解绑输入输出，是 C++ 读入加速的标配。

### 读入矩阵

```cpp
    for(int i = 1;i <= N;i++)                  // 行下标 1~N
    {
        for(int j = 1;j <= M;j++)              // 列下标 1~M
        {
            cin >> A[i][j];                    // 读入原始矩阵值
        }
    }
```

- **下标从 1 开始**：与一维前缀和同理，第 0 行第 0 列留作哨兵边界。
- **此时 `A[i][j]` 仍是原始值**：还没做前缀和，下一步才原地递推。

### 构造前缀和（原地递推）

```cpp
    for(int i = 1;i <= N;i++)
    {
        for(int j = 1;j <= M;j++)
        {
            A[i][j] = A[i][j] + A[i - 1][j] + A[i][j - 1] - A[i - 1][j - 1]; // 容斥：上 + 左 - 左上
        }
    }
```

- **递推式** $S[i][j] = a[i][j] + S[i-1][j] + S[i][j-1] - S[i-1][j-1]$：当前格 + 上方 + 左方 − 左上（重叠部分被加了两次，减去一次）。
- **按行优先遍历，计算顺序正确**：算 $(i,j)$ 时 $A[i-1][j]$（上一行同列）、$A[i][j-1]$（同行前一列）、$A[i-1][j-1]$（左上方）都已经是前缀和值；按行优先或列优先遍历均正确。
- **原地修改**：原始矩阵被覆盖，若需保留原始值应另开一个二维数组。

### 查询子矩阵和

```cpp
    for(int i = 1;i <= T;i++)
    {
        int x1,y1,x2,y2;
        //保证(x1,y1)是左上角，(x2,y2)是右下角 
        cin >> x1 >> y1 >> x2 >> y2;
        cout << A[x2][y2] - A[x1 - 1][y2] - A[x2][y1 - 1] + A[x1 - 1][y1 - 1] << '\n'; // 容斥查询 O(1)
    }
    return 0;
}
```

- **查询公式** $\text{sum} = S[x_2][y_2] - S[x_1-1][y_2] - S[x_2][y_1-1] + S[x_1-1][y_1-1]$：大矩形 − 上矩形 − 左矩形 + 左上角（被减了两次，加回来一次）。
- **单次查询 $O(1)$**：只做 4 次加减与一次下标运算，$T$ 次查询总代价 $O(nm + T)$。
- **坐标约定**：$(x_1,y_1)$ 是左上角、$(x_2,y_2)$ 是右下角，要求 $x_1 \le x_2,\ y_1 \le y_2$；若输入不保证顺序需先 `swap` 调整。

## 复杂度分析

| 操作 | 时间 |
|---|---|
| 构造前缀和矩阵 | $O(nm)$ |
| 单次子矩阵和查询 | $O(1)$ |
| 空间 | $O(nm)$ |

预处理 $O(nm)$，之后每次子矩阵和查询只需容斥的 4 次加减，$q$ 次查询总代价 $O(nm + q)$。

## 适用场景

- **多次子矩阵求和、矩阵不变**：预处理 $O(nm)$ 后单次查询 $O(1)$，是二维静态查询的标配
- **配合差分使用**：二维差分 + 二维前缀和还原，可把 $q$ 次子矩阵加的总代价降到 $O(nm + q)$
- **不适用**：矩阵需要频繁单点修改时，应改用二维树状数组或线段树套线段树

## 常见陷阱与注意事项

1. **下标从 1 开始**
   - 与一维前缀和同理，二维前缀和也从 $(1,1)$ 开始，第 0 行和第 0 列为 0。
   - 好处：边界查询（如 $x_1=1$ 或 $y_1=1$）无需特判。

2. **容斥公式别记错**
   - 构造：$+$ 上方 $+$ 左方 $-$ 左上
   - 查询：$-$ 上矩形 $-$ 左矩形 $+$ 左上矩形
   - 记忆技巧：两次加了重叠区域就减，两次减了重叠区域就加。

3. **数据类型**
   - 二维前缀和数值更大：$n = 10^3, m = 10^3$，每个元素 $10^9$，总和可达 $10^{15}$，必须用 `long long`。

4. **原地修改**
   - 本代码原地修改矩阵，原始值丢失。若需保留原始矩阵，应开两个二维数组。

5. **不支持动态修改**
   - 修改一个元素需要更新其后所有前缀和，$O(nm)$ 时间。
   - 动态修改 + 子矩阵查询应使用二维树状数组或二维线段树。

6. **坐标约定**
   - $(x_1, y_1)$ 是左上角，$(x_2, y_2)$ 是右下角，保证 $x_1 \le x_2, y_1 \le y_2$。
   - 若输入不保证顺序，需先 `swap` 调整。

7. **空矩阵越界**
   - 当矩阵本身为空（$n=0$ 或 $m=0$）或查询区间为空（$x_1 > x_2$ 或 $y_1 > y_2$）时，公式会访问越界下标或得到无意义结果，读入后应先特判（约定输入合法）。

## 扩展应用

### 二维差分

二维前缀和的逆操作是二维差分。子矩阵 $(x_1, y_1) \sim (x_2, y_2)$ 加 $w$：

$$d[x_1][y_1] \mathrel{+}= w, \quad d[x_1][y_2+1] \mathrel{-}= w, \quad d[x_2+1][y_1] \mathrel{-}= w, \quad d[x_2+1][y_2+1] \mathrel{+}= w$$

还原时先做行前缀和，再做列前缀和（或先列后行）。

### 更高维前缀和

前缀和可扩展到三维甚至更高维，容斥项数量为 $2^k$（$k$ 为维度）。三维前缀和构造有 8 项（加 3 个面、减 3 条棱、加 1 个角）。

### 前缀和优化 DP

二维前缀和常用于二维 DP 中快速求子矩阵和，将转移从 $O(nm)$ 优化为 $O(1)$。

## 附：二维差分（子矩阵加·批量更新）

二维差分是二维前缀和的逆运算。给定一个 $n \times m$ 的矩阵 $a$，构造差分矩阵 $d$，使得 $d$ 的二维前缀和恰好还原出 $a$。差分矩阵的核心价值在于：**一次子矩阵加操作可以从 $O(nm)$ 降为 $O(1)$**。

#### 核心思想

在一维差分中，区间 $[l, r]$ 加 $k$ 只需修改两个端点：$d[l] \mathrel{+}= k$，$d[r+1] \mathrel{-}= k$。二维差分将这一思想推广到子矩阵：子矩阵 $(x_1, y_1) \sim (x_2, y_2)$ 加 $k$ 只需修改四个角点。

#### 差分与前缀和的关系

差分和前缀和互为逆运算：

$$\text{差分} = \text{前缀和的逆} \quad \Longleftrightarrow \quad \text{前缀和} = \text{差分的还原}$$

即：对差分矩阵做二维前缀和，就得到原矩阵；对原矩阵做差分，就得到差分矩阵。

### 核心公式

#### 差分矩阵构造

给定原矩阵 $a$（下标从 $1$ 开始），差分矩阵 $d$ 定义为：

$$d[i][j] = a[i][j] - a[i-1][j] - a[i][j-1] + a[i-1][j-1]$$

**容斥解释**：
- $a[i][j]$：当前格的值
- $- a[i-1][j]$：减去上方矩形的和（因为差分本质是"当前值 $-$ 前缀和"）
- $- a[i][j-1]$：减去左方矩形的和
- $+ a[i-1][j-1]$：左上角重叠部分被减了两次，加回一次

#### 子矩阵修改（核心操作）

对子矩阵 $(x_1, y_1) \sim (x_2, y_2)$（左上角到右下角）整体加 $k$：

$$d[x_1][y_1] \mathrel{+}= k$$
$$d[x_1][y_2+1] \mathrel{-}= k$$
$$d[x_2+1][y_1] \mathrel{-}= k$$
$$d[x_2+1][y_2+1] \mathrel{+}= k$$

**容斥解释**：四个修改点的作用是让差分矩阵的前缀和"恰好只在目标子矩阵内增加 $k$"。

#### 前缀和还原

所有修改完成后，对 $d$ 做二维前缀和还原原矩阵：

$$a[i][j] = d[i][j] + a[i-1][j] + a[i][j-1] - a[i-1][j-1]$$

注意此处的 $a[i-1][j]$、$a[i][j-1]$、$a[i-1][j-1]$ 已经是前缀和还原后的值（按行优先顺序遍历）。

### 数据结构图示

#### 差分构造过程示意

以 $3 \times 3$ 矩阵 $a$ 为例（下标从 $1$ 开始，第 0 行/列为 0），仅 $a[2][2] = 5$，其余为 $0$：

```
原矩阵 a:                差分矩阵 d:
   j=0  1  2  3             j=0  1  2  3
i=0  0  0  0  0           i=0  0  0  0  0
i=1  0  0  0  0           i=1  0  0  0  0
i=2  0  0  5  0    →      i=2  0  0  5 -5
i=3  0  0  0  0           i=3  0  0 -5  5
```

从后向前遍历（$i = 3 \to 1$，$j = 3 \to 1$），公式 $d[i][j] = a[i][j] - a[i-1][j] - a[i][j-1] + a[i-1][j-1]$：

```
d[3][3] = 0 - 0 - 0 + 5 =  5
d[3][2] = 0 - 5 - 0 + 0 = -5
d[2][3] = 0 - 0 - 5 + 0 = -5
d[2][2] = 5 - 0 - 0 + 0 =  5
（第 1 行和第 1 列的差分值均为 0，省略）
```

**验证**（对 $d$ 做前缀和还原）：

```
a[2][2] = d[2][2] + a[1][2] + a[2][1] - a[1][1] = 5 + 0 + 0 - 0 = 5  ✓
a[2][3] = d[2][3] + a[1][3] + a[2][2] - a[1][2] = -5 + 0 + 5 - 0 = 0  ✓
a[3][3] = d[3][3] + a[2][3] + a[3][2] - a[2][2] = 5 + 0 + 0 - 5 = 0  ✓
```

#### 子矩阵修改示意

从全零 $3 \times 3$ 矩阵开始，对子矩阵 $(1,1) \sim (2,2)$ 加 $3$。四个角点修改：

```
修改前 d (全零):          修改后 d:
   j=1  2  3                 j=1  2  3  4
i=1  0  0  0               i=1  3  0 -3  0   ← d[1][1] += 3, d[1][3] -= 3
i=2  0  0  0      →        i=2  0  0  0  0
i=3  0  0  0               i=3 -3  0  3  0   ← d[3][1] -= 3, d[3][3] += 3
```

**还原后**（对 $d$ 做前缀和）：

```
   j=1  2  3
i=1  3  3  0    ← (1,1)-(2,2) 区域全部 +3
i=2  3  3  0
i=3  0  0  0    ← 子矩阵外部不受影响
```

#### 四角点容斥图解

```
    (x1,y1)          (x1,y2+1)
      +k               -k
      ┌──────────────────┐
      │                  │
      │   子矩阵区域      │
      │   (全部 +k)      │
      │                  │
      └──────────────────┘
    (x2+1,y1)       (x2+1,y2+1)
      -k               +k

四个角点修改使得：
- 前缀和到子矩阵内部：净效果 +k（正确）
- 前缀和到子矩阵外部：净效果 0（正确，因为修改互相抵消）
```

### 逐行代码解析

#### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	int n, m, q;
	cin >> n >> m >> q;
	vector<vector<long long>> A(n + 2, vector<long long>(m + 2));
```

- 万能头 `bits/stdc++.h` 加 `using namespace std`，省去逐个 include 和 `std::` 前缀。
- 读入行数 $n$、列数 $m$ 与操作次数 $q$，矩阵下标约定从 $(1,1)$ 开始。
- 开 $(n+2) \times (m+2)$ 的二维数组，多开一行一列给 $x_2+1$、$y_2+1$ 使用，避免越界。
- 元素用 `long long`，防止多次累加后溢出。

#### 读入原矩阵

```cpp
	for (int i = 1; i <= n; i++)
	{
		for (int j = 1; j <= m; j++)
		{
			cin >> A[i][j];
		}
	}
```

- 从 $(1,1)$ 读到 $(n,m)$，第 $0$ 行、第 $0$ 列保持为 $0$，为差分公式提供边界。
- 循环上界是 $n$、$m$，正好覆盖整个矩阵，不遗漏也不越界。

#### 原地差分构造

```cpp
	for (int i = n; i >= 1; i--)
	{
		for (int j = m; j >= 1; j--)
		{
			A[i][j] = A[i][j] - A[i - 1][j] - A[i][j - 1] + A[i - 1][j - 1];
		}
	}
```

- 原地把 $A$ 从原矩阵转为差分矩阵，公式 $d[i][j] = a[i][j] - a[i-1][j] - a[i][j-1] + a[i-1][j-1]$。
- 必须从右下到左上遍历：若从前向后，$A[i-1][j]$、$A[i][j-1]$ 已被改成差分值，后续计算会全部错误。

#### 子矩阵修改

```cpp
	while (q--)
	{
		int x1, y1, x2, y2;
		long long k;
		//(x1,y1)为左上角的点，(x2,y2)为右下角的点。
		cin >> x1 >> y1 >> x2 >> y2 >> k ;
		A[x1][y1] += k;
		A[x1][y2 + 1] -= k;
		A[x2 + 1][y1] -= k;
		A[x2 + 1][y2 + 1] += k;
	}
```

- $(x_1,y_1)$ 为左上角、$(x_2,y_2)$ 为右下角，只改四个角点，单次修改 $O(1)$。
- $k$ 可正可负，负值等价于子矩阵整体减去 $|k|$。
- $x_2+1$、$y_2+1$ 可能等于 $n+1$、$m+1$，依赖数组多开的一行一列才不会越界。

#### 前缀和还原与输出

```cpp
	for (int i = 1; i <= n; i++)
	{
		for (int j = 1; j <= m; j++)
		{
			A[i][j] = A[i][j] + A[i - 1][j] + A[i][j - 1] - A[i - 1][j - 1];
			cout << A[i][j] << ' ';
		}
		cout << '\n';
	}
	return 0;
}
```

- 从前向后遍历做二维前缀和，把差分矩阵还原成修改后的原矩阵并输出。
- 方向与构造相反：此时 $A[i-1][j]$、$A[i][j-1]$ 已经是还原后的值，可直接引用。
- 公式 $a[i][j] = d[i][j] + a[i-1][j] + a[i][j-1] - a[i-1][j-1]$。
- 每行末尾 `cout << '\n'` 换行，最后 `return 0` 正常结束。

### 复杂度分析

| 操作 | 时间 | 空间 |
|---|---|---|
| 构造差分矩阵 | $O(nm)$ | $O(nm)$ |
| 单次子矩阵修改 | $O(1)$ | $O(1)$ |
| 前缀和还原 | $O(nm)$ | $O(nm)$ |
| 总计（$q$ 次修改） | $O(nm + q)$ | $O(nm)$ |

对比暴力做法（每次修改遍历整个子矩阵 $O(nm)$），$q$ 次修改从 $O(q \cdot nm)$ 降为 $O(nm + q)$，在 $q$ 较大时优势显著。

### 适用场景

**适用**：
- 离线批量子矩阵加修改，最后一次性还原（如棋盘染色、矩阵叠加）
- 修改次数多但只需要最终结果的场景
- 与二维前缀和配合使用的区间统计问题

**不适用**：
- 需要实时查询（修改和查询交替进行）：应使用二维树状数组或二维线段树
- 动态修改后立即查询某点/某子矩阵的值
- 需要支持撤销操作的场景

### 常见陷阱与注意事项

1. **差分构造的遍历方向**
   - 构造差分：必须从后向前（$i$ 从 $n$ 到 $1$，$j$ 从 $m$ 到 $1$）
   - 前缀和还原：必须从前向后（$i$ 从 $1$ 到 $n$，$j$ 从 $1$ 到 $m$）
   - 方向搞反会导致引用到已修改的值，结果全部错误

2. **数组越界**
   - 子矩阵修改涉及 $d[x_2+1][y_2+1]$，需要多开一行一列
   - 建议开 $(n+2) \times (m+2)$，避免 $x_2 = n$ 或 $y_2 = m$ 时越界

3. **数据溢出**
   - 修改值 $k$ 和累加值都可能很大，应使用 `long long`
   - 若矩阵元素 $\le 10^9$ 且修改次数 $\le 10^5$，累加值可达 $10^{14}$，`int` 必溢出

4. **坐标约定**
   - $(x_1, y_1)$ 是左上角，$(x_2, y_2)$ 是右下角，保证 $x_1 \le x_2$ 且 $y_1 \le y_2$
   - 若输入不保证顺序，需先 `swap` 调整

5. **原地修改的副作用**
   - 本代码原地修改，原始矩阵丢失
   - 若需保留原始矩阵，应开两个数组分别存储

6. **与一维差分的对应关系**
   - 一维差分：$d[l] \mathrel{+}= k$，$d[r+1] \mathrel{-}= k$（2 个点）
   - 二维差分：4 个角点修改（容斥原理的二维推广）
   - $k$ 维差分：$2^k$ 个角点修改

### 对比与扩展

| 对比维度 | 二维差分 | 二维前缀和 | 一维差分 |
|---|---|---|---|
| 核心操作 | 子矩阵加 $O(1)$ | 子矩阵查询 $O(1)$ | 区间加 $O(1)$ |
| 构造方向 | 从后向前 | 从前向后 | 从后向前 |
| 还原方向 | 从前向后 | — | 从前向后 |
| 角点数 | 4（容斥） | 4（容斥） | 2 |
| 复杂度 | $O(nm + q)$ | $O(nm)$ | $O(n + q)$ |
| 支持动态查询 | 否 | 否 | 否 |

**与二维前缀和的关系**：二者互为逆运算。差分用于"修改"，前缀和用于"查询"。很多问题需要两者配合：先用差分批量修改，再用前缀和还原查询。

**更高维差分**：三维差分需要修改 $2^3 = 8$ 个角点，公式类似容斥原理。实际竞赛中三维差分极少使用，通常用差分嵌套代替。

**动态版本**：若需要支持"修改 $+$ 查询"交替进行，应使用二维树状数组（二维 BIT），支持 $O(\log n \cdot \log m)$ 的单点修改和子矩阵查询。$AKB169$, '数据结构', array['数据结构', '前缀和', '二维', '子矩阵', '区间查询', '容斥原理', '数学'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-prefix-sum-tree', '树上前缀和与差分', $AKB170$## 算法原理

树上前缀和是一维前缀和在树结构上的推广。给定一棵以 $S$ 为根的有根树，每个节点有权值 $A[i]$，定义树上前缀和：

$$\text{sum}[u] = \sum_{v \in \text{path}(S \to u)} A[v]$$

即从根 $S$ 到节点 $u$ 的路径上所有节点权值之和。预处理后，可以在 $O(\log n)$ 时间内回答任意两点路径上的权值之和。

路径和查询的关键在于 LCA（最近公共祖先）。对于查询 $(a, b)$，设 $\text{lca} = \text{LCA}(a, b)$，则：

- **一般情况**（$\text{lca} \ne S$）：路径 $a \to b$ 的权值和为 $\text{sum}[a] + \text{sum}[b] - \text{sum}[\text{lca}] - \text{sum}[\text{fa}[\text{lca}]]$，因为两条根到节点的路径在 LCA 及其父节点处重叠。
- **LCA 为根**（$\text{lca} = S$）：路径 $a \to b$ 的权值和为 $\text{sum}[a] + \text{sum}[b] - \text{sum}[\text{lca}]$，因为根没有父节点，只需减去一次根的权值。

本代码同时实现了倍增 LCA（Binary Lifting），通过预处理 $O(n \log n)$ 的跳表实现 $O(\log n)$ 的 LCA 查询。

## 数据结构图示

### 树上前缀和的构造

```
        树结构 (根 S=1, 括号内为点权):
                    1(A=10)
                   /       \
                2(A=20)    3(A=30)
               /      \
            4(A=40)  5(A=50)

        DFS 从根开始，sum[i] = sum[fa] + A[i]:

                    1(sum=10)
                   /       \
                2(sum=30)  3(sum=40)
               /      \
            4(sum=70)  5(sum=80)

        前缀和数组:
        下标:   1    2    3    4    5
        sum:   10   30   40   70   80
```

### 路径和查询示意

```
查询 find_sum(4, 5):
  LCA(4, 5) = 2, lca != S(=1)

  sum[4] = 70  (1→2→4: 10+20+40)
  sum[5] = 80  (1→2→5: 10+20+50)
  sum[lca=2] = 30
  sum[fa[lca]=1] = 10

  路径 4→5 的权值和 = 70 + 80 - 30 - 10 = 110
  验证: 40+20+50 = 110 ✓

  图解:
  1(10) ─ 2(20) ─ 4(40)
           └──── 5(50)

  sum[4] 包含: 10+20+40     ──┐
  sum[5] 包含: 10+20+50     ──┤
  减去 sum[2]: 10+20        ──┤  被加了两次
  减去 sum[1]: 10           ──┘  也被加了两次
  剩余: 40 + 50 + 20 = 110 ✓
```

```
查询 find_sum(3, 4):
  LCA(3, 4) = 1 = S

  sum[3] = 40  (1→3: 10+30)
  sum[4] = 70  (1→2→4: 10+20+40)
  sum[lca=1] = 10

  路径 3→4 的权值和 = 40 + 70 - 10 = 100
  验证: 30+10+20+40 = 100 ✓

  图解:
  3(30) ─ 1(10) ─ 2(20) ─ 4(40)

  sum[3] 包含: 10+30          ──┐
  sum[4] 包含: 10+20+40       ──┤
  减去 sum[1]: 10             ──┘  被加了两次
  剩余: 30 + 20 + 40 + 10 = 100 ✓
```

### 倍增跳表结构

```
ST[i][k] 表示从节点 i 向上跳 2^k 步到达的祖先

ST[4][0] = fa[4] = 2     (跳 1 步)
ST[4][1] = ST[ST[4][0]][0] = ST[2][0] = 1  (跳 2 步)
ST[4][2] = ST[ST[4][1]][1] = ST[1][1] = S  (跳 4 步，超出根回到 S)

跳表:
节点  ST[][0]  ST[][1]  ST[][2]
 1      1        1        1    (根指向自身)
 2      1        1        1
 3      1        1        1
 4      2        1        1
 5      2        1        1
```

## 核心操作详解

### DFS 预处理前缀和

```cpp
int dfs(int rt, int rh)
{
    int ans = rh;
    h[rt] = rh;
    for (int i : edges[rt])
    {
        if (fa[i]) continue;
        fa[i] = rt;
        sum[i] = sum[rt] + A[i];
        ans = max(dfs(i, rh + 1), ans);
    }
    return ans;
}
```

DFS 遍历树，计算每个节点的深度 `h[rt]`、父节点 `fa[rt]` 和前缀和 `sum[rt]`。返回最大深度用于确定倍增跳表的大小。

### 倍增跳表初始化

```cpp
ST[i][0] = fa[i];                    // 跳 1 步 = 父节点
ST[i][k] = ST[ST[i][k-1]][k-1];      // 跳 2^k 步 = 跳 2^(k-1) 后再跳 2^(k-1)
```

倍增预处理：$ST[i][k]$ 表示从节点 $i$ 向上跳 $2^k$ 步到达的节点。

### LCA 查询

```cpp
int find_fa(int a, int b)
{
    if (h[a] < h[b]) swap(a, b);       // 保证 a 更深
    int tmp = h[a] - h[b];
    for (int i = 0; i <= sz; i++)      // 将 a 跳到与 b 同一深度
    {
        if (tmp & 1) a = ST[a][i];
        tmp >>= 1;
    }
    if (a == b) return a;              // b 是 a 的祖先

    for (int i = sz; i >= 0; i--)      // 两人同时向上跳
    {
        if (ST[a][i] != ST[b][i])
        {
            a = ST[a][i];
            b = ST[b][i];
        }
    }
    return fa[a];                      // 最终 a, b 的父节点就是 LCA
}
```

三步法：深度对齐 → 判断祖先关系 → 二分跳跃找 LCA。

### 路径和查询

```cpp
long long find_sum(int a, int b)
{
    int g_fa = find_fa(a, b);
    if (g_fa != S)
        return sum[a] + sum[b] - sum[g_fa] - sum[fa[g_fa]];
    return sum[a] + sum[b] - sum[g_fa];
}
```

当 LCA 不是根时，需要额外减去 `sum[fa[lca]]`，因为 `sum[a]` 和 `sum[b]` 都包含了从根到 LCA 的路径（含 LCA 及其所有祖先），减去 `sum[lca]` 消除 LCA 以下的重叠，再减去 `sum[fa[lca]]` 消除 LCA 以上根路径的重复。当 LCA 是根时，根的父节点指向自身（`fa[S] = S`），如果也减去 `sum[fa[S]] = sum[S]` 会多减一次根权值，因此需特判。

## 逐行代码解析

以下按代码逻辑阶段拆成 6 个模块：全局变量 → `dfs` 预处理 → `init` 跳表 → `find_fa`(LCA) → `find_sum`(路径和) → `main`(读入与查询)。各模块代码块按顺序拼接即完整 `.cpp`。

### 全局变量与头文件

```cpp
#include<bits/stdc++.h>
using namespace std;
int N, M, S, sz;                 // N:节点数 M:查询数 S:根节点 sz:跳表最大层数
vector<long long> A, sum;        // A:点权 sum:树上前缀和（long long 防溢出）
vector<vector<int>> edges, ST;   // edges:邻接表 ST:倍增跳表
vector<int> fa, h;               // fa:父节点 h:深度
```

- `N`：节点数，`M`：查询数，`S`：根节点，`sz`：倍增跳表最大层数。
- `A` 存点权、`sum` 存树上前缀和，两者都用 `long long`，路径点权和可能超过 `int` 上限。
- `ST[i][k]` 表示从节点 `i` 向上跳 $2^k$ 步到达的祖先；`fa`、`h` 分别存父节点与深度。

### dfs：预处理前缀和、深度与父节点

```cpp
int dfs(int rt, int rh)
{
    int ans = rh;
    h[rt] = rh;                        // 记录当前节点深度
    for (int i : edges[rt])
    {
        if (fa[i]) continue;           // 已访问（fa[i] != 0），跳过父节点回边
        fa[i] = rt;                    // 记录父节点
        sum[i] = sum[rt] + A[i];       // 前缀和 = 父节点前缀和 + 当前点权
        ans = max(dfs(i, rh + 1), ans); // 递归子树，取最大深度
    }
    return ans;
}
```

- 无向树用 `fa[i] != 0` 判断是否已访问，避免沿父边回走（隐含节点从 1 开始编号）。
- 递归时先记父节点再算 `sum[i] = sum[rt] + A[i]`，保证前缀和自上而下累加。
- 返回值 `ans` 是整棵树的最大深度，供 `init()` 计算跳表层数 `sz`。

### init：初始化数组与倍增跳表

```cpp
void init()
{
    fa.resize(N + 1, 0);
    h.resize(N + 1, 0);
    sum.resize(N + 1, 0);
    fa[S] = S, sum[S] = A[S];                  // 根父节点指向自身，根前缀和 = 自身点权
    int q = dfs(S, 1);                         // 从根 DFS，返回最大深度
    sz = 1;
    while (q > ((long long)1 << sz)) ++sz;     // 求最小 sz 使 2^sz >= q
    ST.resize(N + 1, vector<int>(sz + 1, S));  // 跳表先全部初始化为 S（越界回根）
    for (int i = 1; i <= N; i++) ST[i][0] = fa[i]; // 跳 1 步 = 父节点
    for (int k = 1; k <= sz; k++)
    {
        for (int i = 1; i <= N; i++)
        {
            ST[i][k] = ST[ST[i][k - 1]][k - 1]; // 跳 2^k = 跳两次 2^(k-1)
        }
    }
}
```

- `fa[S] = S` 是跳表的终止哨兵：根再往上跳仍停在根，避免越界。
- 先填 `ST[i][0] = fa[i]`，再用 `ST[i][k] = ST[ST[i][k-1]][k-1]` 递推整张跳表。
- `while (q > (1LL << sz)) ++sz` 保证 $2^{\text{sz}} \ge \text{maxDepth}$，深度对齐时跳跃步数才够用。

### find_fa：倍增求 LCA

```cpp
int find_fa(int a, int b)
{
    if (h[a] < h[b]) swap(a, b);   // 保证 a 更深
    int tmp = h[a] - h[b];         // 深度差
    for (int i = 0; i <= sz; i++)  // 按二进制拆深度差，把 a 抬到与 b 同层
    {
        if (tmp & 1) a = ST[a][i];
        tmp >>= 1;
    }
    if (a == b) return a;          // b 是 a 的祖先（或 a == b）

    for (int i = sz; i >= 0; i--)  // 从高到低同时上跳，避免越过 LCA
    {
        if (ST[a][i] != ST[b][i])
        {
            a = ST[a][i];
            b = ST[b][i];
        }
    }
    return fa[a];                  // 最终 a、b 的父节点就是 LCA
}
```

- 深度对齐循环 `i <= sz`：用 `tmp & 1` 判断第 $i$ 位是否为 1，每轮 `tmp >>= 1`，逐位跳跃。
- 第二个循环从 `sz` 递减：仅当 `ST[a][i] != ST[b][i]` 才一起跳，保证不会越过 LCA。
- 循环结束后 `a`、`b` 停在 LCA 的两个子节点处，返回 `fa[a]` 即 LCA。

### find_sum：路径点权和查询

```cpp
long long find_sum(int a, int b)
{
    int g_fa = find_fa(a, b);       // LCA
    if (g_fa != S) return sum[a] + sum[b] - sum[g_fa] - sum[fa[g_fa]];
    return sum[a] + sum[b] - sum[g_fa]; // LCA 为根：只减一次 sum[lca]
}
```

- LCA 非根：`sum[a] + sum[b] - sum[g_fa] - sum[fa[g_fa]]`，去掉两条根路径在 LCA 及其祖先处的重复累加。
- LCA 为根：只减 `sum[g_fa]`；因 `fa[S] = S`，若再减 `sum[fa[S]]` 会多减一次根权值。
- 返回类型与 `sum` 一致为 `long long`，避免中间结果溢出。

### main：读入、预处理与回答查询

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    //N:点的数量,M:测试案例数量,S:根节点
    cin >> N >> M >> S;
    A.resize(N + 1);
    edges.resize(N + 1);
    for (int i = 1; i <= N; i++) cin >> A[i]; // 读入点权
    for (int i = 1; i < N; i++)               // 树有 N-1 条边
    {
        int a, b;
        cin >> a >> b;
        edges[a].emplace_back(b);             // 无向边，双向建图
        edges[b].emplace_back(a);
    }
    init();                                    // 预处理前缀和 + 跳表

    while (M--)                                // 回答 M 次查询
    {
        int a, b;
        cin >> a >> b;
        cout << find_sum(a, b) << '\n';
    }
    return 0;
}
```

- 读入点权后读 $N-1$ 条无向边，双向加入邻接表。
- `init()` 完成 DFS 与跳表预处理，随后循环回答 $M$ 次路径和查询。
- 关闭 C/C++ 输入输出同步并解除 `cin`/`cout` 绑定，加速大数据读写。

## 复杂度分析

### 时间复杂度

| 操作 | 复杂度 | 说明 |
|---|---|---|
| DFS 预处理 | $O(n)$ | 每个节点访问一次 |
| 倍增跳表初始化 | $O(n \log n)$ | $n$ 个节点，$\log n$ 层 |
| 单次 LCA 查询 | $O(\log n)$ | 深度对齐 + 二分跳跃 |
| 单次路径和查询 | $O(\log n)$ | LCA 查询 + $O(1)$ 计算 |
| 总体（$M$ 次查询） | $O(n \log n + M \log n)$ | 预处理 + $M$ 次查询 |

### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 倍增跳表 `ST` | $O(n \log n)$ | $n \times (\log n + 1)$ 的二维数组 |
| 邻接表 `edges` | $O(n)$ | $n-1$ 条边 |
| 其他数组 | $O(n)$ | `A`, `sum`, `fa`, `h` |
| **总计** | $O(n \log n)$ | 倍增跳表占主导 |

## 适用场景

1. **树上路径权值和查询**：静态树，多次查询两点间路径上所有节点权值之和
2. **树上距离查询**：若边权代替点权，可查询两点间路径的边权之和
3. **子树和查询**：通过 DFS 序 + 前缀和可扩展到子树权值和
4. **结合差分做树上路径修改**：树上差分 + LCA 可实现路径加 + 单点查询

**不适用场景**：
- 需要动态修改点权 → 应使用树链剖分 + 线段树/树状数组
- 仅需查询子树和 → DFS 序 + 一维前缀和更简单，$O(1)$ 查询
- 树结构频繁变化（加边/删边）→ LCT（Link-Cut Tree）

## 常见陷阱与注意事项

1. **根节点的父节点处理**
   - `fa[S] = S`（指向自身）作为倍增跳表的终止哨兵
   - 路径和公式中必须特判 `lca == S`，否则 `sum[fa[S]] = sum[S]` 会多减一次根权值

2. **前缀和类型用 `long long`**
   - 树上路径可能很长，权值累加可能超过 `int` 范围
   - `sum` 数组必须声明为 `long long`

3. **无向边需双向建图**
   - `edges[a].push_back(b)` 和 `edges[b].push_back(a)` 都要写
   - DFS 用 `fa[i] != 0` 判断已访问，避免重复遍历

4. **倍增跳表层数计算**
   - `sz` 必须满足 $2^{\text{sz}} \ge \text{maxDepth}$，否则跳跃不足
   - 代码中 `while (q > (1LL << sz)) ++sz` 正确处理了这一点

5. **深度对齐时的位运算**
   - `for (int i = 0; i <= sz; i++)` 中用 `tmp & 1` 判断是否需要跳 $2^i$ 步
   - 每次检查后 `tmp >>= 1`，注意循环范围必须覆盖 `sz`

6. **LCA 查询的边界情况**
   - $a = b$ 时直接返回 $a$（深度对齐后 `a == b`）
   - $a$ 是 $b$ 的祖先时，深度对齐后 `a == b` 也正确返回

7. **链状树递归 DFS 易栈溢出**
   - 退化成一条链的树（深度 $n$）递归 DFS 可能爆栈，需改用迭代 DFS 或增大栈空间

## 对比与扩展

| 方法 | 预处理 | 查询 | 空间 | 特点 |
|---|---|---|---|---|
| **倍增 LCA（本算法）** | $O(n \log n)$ | $O(\log n)$ | $O(n \log n)$ | 在线查询，实现简洁 |
| Tarjan LCA | $O(n + M \cdot \alpha)$ | 离线 | $O(n)$ | 离线查询，理论更快 |
| 重链剖分 LCA | $O(n)$ | $O(\log n)$ | $O(n)$ | 可结合线段树做路径修改 |
| 欧拉序 + ST 表 | $O(n \log n)$ | $O(1)$ | $O(n \log n)$ | $O(1)$ 查询，常数较大 |

### 扩展

- **树上前缀和 + 树上差分**：路径加操作 $(a, b, w)$ 可转化为 `diff[a] += w, diff[b] += w, diff[lca] -= w, diff[fa[lca]] -= w`，最后 DFS 求子树和还原
- **边权版本**：将边权下放为子节点点权，路径和公式相同；注意 LCA 处的点权不属于路径
- **树链剖分**：支持动态修改点权的路径和查询，时间 $O(\log^2 n)$ 每次操作

## 附：树上点差分（路径点权修改）

树上点差分是一维差分在树结构上的推广。给定一棵以 $S$ 为根的有根树，每个节点有初始权值 $A[i]$。需要支持**路径修改**：对路径 $a \to b$ 上所有节点的权值加 $k$，最后统一查询每个节点的最终权值。

#### 核心思想

一维差分通过"加左减右"实现区间修改，树上差分类似地利用 LCA 实现"路径修改"到"单点修改"的转化。关键公式：

对于路径 $a \to b$ 上所有节点加 $k$，设 $\text{lca} = \text{LCA}(a, b)$：

$$\text{diff}[a] \mathrel{+}= k, \qquad \text{diff}[b] \mathrel{+}= k, \qquad \text{diff}[\text{lca}] \mathrel{-}= k, \qquad \text{diff}[\text{fa}[\text{lca}]] \mathrel{-}= k$$

当 $\text{lca} = S$（即 LCA 为根节点）时，$\text{fa}[\text{lca}]$ 不存在，只需三处修改：

$$\text{diff}[a] \mathrel{+}= k, \qquad \text{diff}[b] \mathrel{+}= k, \qquad \text{diff}[\text{lca}] \mathrel{-}= k$$

#### 为什么这样修改？

树上差分的还原方式是**DFS 求子树和**：每个节点的差分值向父节点累加。理解公式的关键在于分析每个节点被累加的次数：

- 节点 $a$ 和 $b$ 各自 $+k$：它们的祖先路径上的节点都会通过子树和获得 $+k$
- 但路径 $a \to b$ 经过 LCA，LCA 的子树同时包含 $a$ 和 $b$，因此 LCA 会被累加两次（$+2k$），需要减去一次（$-k$）
- LCA 的父节点同样通过两条子路径累加了两次，也需要减去一次（$-k$）
- 当 LCA 是根时，根没有父节点，只有根被多算了一次，减一次即可

#### 还原操作

所有修改完成后，对差分数组做一次 DFS 子树和累加：

$$\text{diff}[u] \mathrel{+}= \sum_{v \in \text{children}(u)} \text{diff}[v]$$

最终每个节点的权值为 $\text{diff}[i] + A[i]$（差分累加值 + 初始权值）。

#### 复杂度分析

| 操作 | 时间 | 说明 |
|---|---|---|
| DFS 预处理 | $O(n)$ | 求深度、父节点 |
| 倍增跳表初始化 | $O(n \log n)$ | $n$ 个节点，$\log n$ 层 |
| 单次路径修改 | $O(\log n)$ | LCA 查询 + $O(1)$ 差分 |
| DFS 还原子树和 | $O(n)$ | 每个节点访问一次 |
| 总体（$M$ 次修改） | $O(n \log n + M \log n)$ | 预处理 + $M$ 次修改 + 还原 |

### 数据结构图示

#### 树结构示例

```
树结构 (根 S=1, 括号内为初始点权 A):
            1(A=10)
           /       \
        2(A=20)    3(A=30)
       /      \
    4(A=40)  5(A=50)

节点编号:  1    2    3    4    5
初始权值A: 10   20   30   40   50
```

#### 差分修改过程

**操作 1：路径 4→5 上所有节点加 $k=100$**

```
路径 4→5: 4 → 2 → 5 (LCA(4,5) = 2, lca != S)

差分操作:
  diff[4] += 100      (端点 a)
  diff[5] += 100      (端点 b)
  diff[2] -= 100      (LCA 减一次)
  diff[fa[2]=1] -= 100 (LCA 父节点减一次)

diff 数组初始全 0:
  下标:   1     2     3     4     5
  diff:  -100  -100    0   +100  +100

图解 (虚线 = 路径 4→5):
            1(-100)
           /       \
        2(-100)    3(0)
       /      \
    4(+100)  5(+100)
```

#### DFS 子树和还原

```
DFS 从根开始，子节点先递归，回溯时累加:

dfs_arr(4): 无子节点 → diff[4] = 100
dfs_arr(5): 无子节点 → diff[5] = 100
dfs_arr(2): diff[2] += diff[4] + diff[5]
           → diff[2] = -100 + 100 + 100 = 100
dfs_arr(3): 无子节点 → diff[3] = 0
dfs_arr(1): diff[1] += diff[2] + diff[3]
           → diff[1] = -100 + 100 + 0 = 0

还原后 diff (即每个节点的修改量):
  下标:    1    2    3    4    5
  diff:    0   100   0  100  100

最终权值 = A[i] + diff[i]:
  节点:   1      2       3      4       5
  最终权值: 10+0  20+100  30+0  40+100  50+100
         = 10   120    30    140     150

验证: 路径 4→2→5 的权值确实各加了 100 ✓
      节点 1, 3 不在路径上，权值不变 ✓
```

#### LCA 为根的情况

**操作 2：路径 3→4 上所有节点加 $k=50$**

```
路径 3→4: 3 → 1 → 2 → 4 (LCA(3,4) = 1 = S)

差分操作 (lca = S, 只减一次):
  diff[3] += 50       (端点 a)
  diff[4] += 50       (端点 b)
  diff[1] -= 50       (LCA = 根，只减一次，不减 fa)

图解 (虚线 = 路径 3→1→2→4):
            1(-50)
           /       \
        2(0)     3(+50)
       /      \
    4(+50)    5(0)
```

#### 倍增跳表结构

```
ST[i][k] 表示从节点 i 向上跳 2^k 步到达的祖先

ST[4][0] = fa[4] = 2     (跳 1 步)
ST[4][1] = ST[ST[4][0]][0] = ST[2][0] = 1  (跳 2 步)
ST[4][2] = ST[ST[4][1]][1] = ST[1][1] = S  (跳 4 步，超出根回到 S)

跳表:
节点  ST[][0]  ST[][1]  ST[][2]
 1      1        1        1    (根指向自身)
 2      1        1        1
 3      1        1        1
 4      2        1        1
 5      2        1        1
```

### 核心操作详解

#### DFS 预处理（深度与父节点）

```cpp
int dfs(int rt, int rh)
{
    int ans = rh;
    h[rt] = rh;
    for (int i : edges[rt])
    {
        if (fa[i]) continue;
        fa[i] = rt;
        ans = max(dfs(i, rh + 1), ans);
    }
    return ans;
}
```

DFS 遍历树，计算每个节点的深度 `h[rt]` 和父节点 `fa[rt]`。返回最大深度用于确定倍增跳表的大小。与树上前缀和不同，此处的 DFS 不计算前缀和，只建立树结构信息。

#### 倍增跳表初始化

```cpp
ST[i][0] = fa[i];                    // 跳 1 步 = 父节点
ST[i][k] = ST[ST[i][k-1]][k-1];      // 跳 2^k 步 = 跳 2^(k-1) 后再跳 2^(k-1)
```

倍增预处理：$ST[i][k]$ 表示从节点 $i$ 向上跳 $2^k$ 步到达的节点。根节点 `fa[S] = S`，跳表指向自身作为哨兵。

#### LCA 查询

```cpp
int find_fa(int a, int b)
{
    if (h[a] < h[b]) swap(a, b);       // 保证 a 更深
    int tmp = h[a] - h[b];
    for (int i = 0; i <= sz; i++)      // 将 a 跳到与 b 同一深度
    {
        if (tmp & 1) a = ST[a][i];
        tmp >>= 1;
    }
    if (a == b) return a;              // b 是 a 的祖先

    for (int i = sz; i >= 0; i--)      // 两人同时向上跳
    {
        if (ST[a][i] != ST[b][i])
        {
            a = ST[a][i];
            b = ST[b][i];
        }
    }
    return fa[a];                      // 最终 a, b 的父节点就是 LCA
}
```

三步法：深度对齐（位运算逐位跳）→ 判断祖先关系 → 二分跳跃找 LCA。

#### 路径差分修改

```cpp
void find_arr(int a, int b, long long k)
{
    int t_fa = find_fa(a, b);
    arr[a] += k;
    arr[b] += k;
    arr[t_fa] -= k;
    if (t_fa != S) arr[fa[t_fa]] -= k;
}
```

核心差分操作：端点 $a, b$ 各加 $k$，LCA 减 $k$，LCA 父节点减 $k$（当 LCA 不是根时）。当 LCA 是根时，`fa[S] = S`，如果也减去 `arr[fa[S]] = arr[S]` 会导致根被多减一次，因此必须特判。

#### DFS 子树和还原

```cpp
void dfs_arr(int rt, int f)
{
    for (int i : edges[rt])
    {
        if (i == f) continue;
        dfs_arr(i, rt);
        arr[rt] += arr[i];
    }
}
```

后序 DFS：先递归子节点，回溯时将子节点的差分值累加到当前节点。这等价于对每个节点求子树和，将差分操作的效果传播到正确的路径上。

### 逐行代码解析

#### 全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
int N, M, S, sz;
vector<long long> A, arr;
vector<vector<int>> edges, ST;
vector<int> fa, h;
```

- `N` 节点数、`M` 修改次数、`S` 根节点、`sz` 倍增跳表最大层数。
- `A` 存初始点权、`arr` 存差分值，二者都用 `long long`，因为多次路径累加可能超出 `int`。
- `edges` 是邻接表（无向边需双向建图），`ST` 是倍增跳表，`fa` 记父节点，`h` 记深度。

#### 预处理（dfs 与 init）

```cpp
int dfs(int rt, int rh)
{
    int ans = rh;
    h[rt] = rh;
    for (int i : edges[rt])
    {
        if (fa[i]) continue;       // 已访问（fa[i] != 0）
        fa[i] = rt;
        ans = max(dfs(i, rh + 1), ans);
    }
    return ans;
}

void init()
{
    fa.resize(N + 1, 0);
    h.resize(N + 1, 0);
    arr.resize(N + 1, 0);
    fa[S] = S;                     // 根的父节点指向自身（哨兵）
    int q = dfs(S, 1);
    sz = 1;
    while (q > ((long long)1 << sz)) ++sz;   // 计算跳表层数
    ST.resize(N + 1, vector<int>(sz + 1, S));
    for (int i = 1; i <= N; i++) ST[i][0] = fa[i];
    for (int k = 1; k <= sz; k++)
    {
        for (int i = 1; i <= N; i++)
        {
            ST[i][k] = ST[ST[i][k - 1]][k - 1];
        }
    }
}
```

- `dfs` 用 `fa[i] != 0` 判断是否访问过，边遍历边记录深度 `h` 与父节点 `fa`，返回值是整棵树的最大深度 `q`。
- `fa[S] = S` 让根指向自身作哨兵，倍增跳表在"跳过根"时停在根，不会越界。
- `while (q > ((long long)1 << sz)) ++sz` 保证 $2^{\text{sz}} \ge q$，跳表层数足以覆盖任意深度差。
- 倍增递推 `ST[i][k] = ST[ST[i][k-1]][k-1]`：跳 $2^k$ 步 = 先跳 $2^{k-1}$ 步再跳 $2^{k-1}$ 步。

#### 路径修改（find_fa 与 find_arr）

```cpp
int find_fa(int a, int b)
{
    if (h[a] < h[b]) swap(a, b);       // 保证 a 更深
    int tmp = h[a] - h[b];
    for (int i = 0; i <= sz; i++)      // 将 a 跳到与 b 同一深度
    {
        if (tmp & 1) a = ST[a][i];
        tmp >>= 1;
    }
    if (a == b) return a;              // b 是 a 的祖先

    for (int i = sz; i >= 0; i--)      // 两人同时向上跳
    {
        if (ST[a][i] != ST[b][i])
        {
            a = ST[a][i];
            b = ST[b][i];
        }
    }
    return fa[a];                      // 最终 a, b 的父节点就是 LCA
}

void find_arr(int a, int b, long long k)
{
    int t_fa = find_fa(a, b);
    arr[a] += k;
    arr[b] += k;
    arr[t_fa] -= k;
    if (t_fa != S) arr[fa[t_fa]] -= k;   // LCA 不是根时才减父节点
}
```

- `find_fa` 三步求 LCA：先把较深的 `a` 按二进制位抬到与 `b` 同深，再同步向上跳到父节点不同处，最后 `fa[a]` 即 LCA。
- 深度对齐用 `tmp & 1` 逐位判断该位要不要跳，比逐级上跳快，复杂度 $O(\log n)$。
- `find_arr` 按公式改四处：端点 `a, b` 各 `+k`，LCA `-k`，LCA 的父节点 `-k`。
- `if (t_fa != S)` 是根特判：LCA 为根时 `fa[S] = S`，再减 `arr[fa[S]]` 会多减一次根，必须跳过。

#### 子树和还原（dfs_arr）

```cpp
void dfs_arr(int rt, int f)
{
    for (int i : edges[rt])
    {
        if (i == f) continue;       // 跳过父节点（避免回退）
        dfs_arr(i, rt);
        arr[rt] += arr[i];          // 子树和累加
    }
}
```

- 后序 DFS：先递归子节点，回溯时把子节点差分值累加到当前节点，等价于对每个节点求子树和。
- 这里用 `i == f` 判断父节点而非预处理里的 `fa[i]`，因为传入父节点 `f` 更直观，也避免与 `fa` 数组混淆。
- 还原后 `arr[i]` 是节点 `i` 的累计修改量，最终权值还要再加初始权值 `A[i]`。

#### 主函数 main

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    //N:点的数量,M:修改案例数量,S:根节点
    cin >> N >> M >> S;
    A.resize(N + 1);
    edges.resize(N + 1);
    for (int i = 1; i <= N; i++) cin >> A[i];
    for (int i = 1; i < N; i++)
    {
        int a, b;
        cin >> a >> b;
        edges[a].emplace_back(b);
        edges[b].emplace_back(a);
    }
    init();
    while (M--)
    {
        int a, b;
        long long k;
        cin >> a >> b >> k;
        find_arr(a, b, k);
    }
    dfs_arr(S, S);
    for (int i = 1; i <= N; i++) cout << arr[i] + A[i] << ' ';
    return 0;
}
```

- 依次读入 `N, M, S`、初始权值 `A` 和 `N-1` 条无向边（双向 `emplace_back`），再 `init()` 预处理。
- `while (M--)` 处理 $M$ 次修改：读入路径端点 `a, b` 与增量 `k`，调用 `find_arr` 打差分标记。
- 修改全部结束后 `dfs_arr(S, S)` 一次性还原子树和（根以自身作父节点哨兵）。
- 最后输出 `arr[i] + A[i]`：差分累计修改量加上初始权值，才是最终点权。

### 复杂度分析

#### 时间复杂度

| 操作 | 复杂度 | 说明 |
|---|---|---|
| DFS 预处理 | $O(n)$ | 每个节点访问一次 |
| 倍增跳表初始化 | $O(n \log n)$ | $n$ 个节点，$\log n$ 层 |
| 单次路径修改 | $O(\log n)$ | LCA 查询 $O(\log n)$ + 差分 $O(1)$ |
| DFS 还原子树和 | $O(n)$ | 每个节点访问一次 |
| 总体（$M$ 次修改） | $O(n \log n + M \log n)$ | 预处理 + $M$ 次修改 + 还原 |

#### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 倍增跳表 `ST` | $O(n \log n)$ | $n \times (\log n + 1)$ 的二维数组 |
| 邻接表 `edges` | $O(n)$ | $n-1$ 条边 |
| 其他数组 | $O(n)$ | `A`, `arr`, `fa`, `h` |
| **总计** | $O(n \log n)$ | 倍增跳表占主导 |

### 适用场景

1. **树上路径批量修改**：对树上多条路径的所有节点加值，最后统一查询。例如统计每条边/点被多少条路径覆盖
2. **访问次数统计**：多次路径查询后统计每个节点被覆盖的次数（如运输路线经过的城市次数）
3. **树上染色问题**：对路径上所有节点染色，最后统计颜色分布
4. **结合树上前缀和**：树上差分修改 + 树上前缀和查询，实现"先修改后查询"的完整流程

**不适用场景**：
- 需要在线查询（边修改边查询）→ 应使用树链剖分 + 线段树/树状数组
- 仅需单次路径修改 → 直接 DFS 遍历路径即可，$O(n)$
- 需要路径修改 + 路径查询 → 树链剖分 + 线段树，$O(\log^2 n)$ 每次操作

### 常见陷阱与注意事项

1. **LCA 为根时的特判**
   - `fa[S] = S`（指向自身）作为倍增跳表的终止哨兵
   - 差分公式中必须特判 `lca == S`，否则 `arr[fa[S]] = arr[S]` 会导致根被多减一次 $k$
   - 正确做法：LCA 为根时只减 `arr[lca]` 一次，不减 `arr[fa[lca]]`

2. **差分数组类型用 `long long`**
   - 多次路径修改累加可能超过 `int` 范围
   - `arr` 数组和修改值 `k` 都必须声明为 `long long`

3. **DFS 还原时区分访问方式**
   - 预处理 DFS 用 `fa[i] != 0` 判断访问（因为 `fa` 数组在 init 中初始化）
   - 还原 DFS 用 `i == f` 判断父节点（避免与 `fa` 数组混淆）
   - 两种 DFS 的访问判断方式不同，不可混用

4. **倍增跳表层数计算**
   - `sz` 必须满足 $2^{\text{sz}} \ge \text{maxDepth}$，否则跳跃不足
   - 代码中 `while (q > (1LL << sz)) ++sz` 正确处理了这一点

5. **最终输出需加初始权值**
   - 差分数组只记录修改量，最终权值 = `arr[i] + A[i]`
   - 容易忘记加初始权值 `A[i]`，导致输出错误

6. **无向边需双向建图**
   - `edges[a].push_back(b)` 和 `edges[b].push_back(a)` 都要写
   - 还原 DFS 从根开始，必须确保树结构正确

7. **链状树的递归深度与编号约定**
   - 树退化成一条链时，递归 DFS 深度可达 $n$，$n$ 较大时可能栈溢出，应改迭代或用显式栈（或增大栈空间）
   - 预处理用 `fa[i] != 0` 判断已访问，隐含"节点编号从 1 起、0 不是合法节点"的约定，输入需保证编号从 1 开始

### 对比与扩展

| 方法 | 修改 | 还原 | 查询 | 特点 |
|---|---|---|---|---|
| **树上点差分（本算法）** | $O(\log n)$ | $O(n)$ | 不支持在线 | 离线批量修改，实现简洁 |
| 树链剖分 + 线段树 | $O(\log^2 n)$ | — | $O(\log^2 n)$ | 在线修改 + 在线查询 |
| 树上边差分 | $O(\log n)$ | $O(n)$ | 不支持在线 | 差分对象为边权，还原方式不同 |

#### 树上点差分 vs 树上边差分

| 对比项 | 点差分 | 边差分 |
|---|---|---|
| 修改对象 | 路径上所有**节点**权值 | 路径上所有**边**权值 |
| 差分公式 | $+a, +b, -\text{lca}, -\text{fa}[\text{lca}]$ | $+a, +b, -2 \cdot \text{lca}$ |
| 还原方式 | DFS 子树和，`diff[u] += diff[children]` | DFS 子树和，`diff[u]` 代表 $u \to \text{fa}[u]$ 的边 |
| LCA 处理 | LCA 点权需修改，需特判根 | LCA 不在路径边中，无需特判根 |

#### 扩展

- **树上边差分**：将边权下放为子节点点权（每条边赋给深度较深的端点），路径修改公式变为 $+a, +b, -2 \cdot \text{lca}$，还原后 `diff[u]` 代表边 $u \to \text{fa}[u]$ 的修改量
- **树链剖分**：支持在线路径修改 + 路径查询，时间 $O(\log^2 n)$ 每次操作，适合需要实时查询的场景
- **LCT（Link-Cut Tree）**：支持动态加边删边的路径修改与查询，适合动态树问题$AKB170$, '数据结构', array['数据结构', '前缀和', '树上', 'LCA', '倍增', '路径查询'], 'col-ds-prefix-diff-overview', null, 'knowledge'),
('stripe-python', 'col-ds-rmq-linear--stripe-python', '线性 RMQ · stripe-python', $AKB171$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 前言

RMQ 算法大概是这样的：

| 算法 | 预处理 | 查询 | 空间 | 码量 |
| --- | --- | --- | --- | --- |
| ST 表 | $O(n \log n)$ | $O(1)$ | $O(n \log n)$ | 小 |
| 树状数组 | $O(n)$ | $O(\log^2 n)$ | $O(n)$ | 小 |
| 线段树 | $O(n)$ | $O(\log n)$ | $O(n)$ | 中 |
| 平衡树 | $O(n)$ | $O(\log n)$ | $O(n)$ | 大 |
| 分块 | $O(n)$ | $O(\sqrt{n})$ | $O(n)$ | 大 |
| Sqrt Tree | $O(n \log \log n)$ | $O(1)$ | $O(n)$ | 大 |
| Four Russian | $O(n \log \log n)$ | $O(1)$ | $O(n \log \log n)$ | 大 |
| 线性 RMQ | $O(n)$ | $O(1)$ | $O(n)$ | 中 |

本文介绍的线性 RMQ 科技，具有常数小，预处理严格线性，查询严格常数复杂度等优势。摘自 [OI-Wiki](https://oi-wiki.org/topic/rmq/#%E5%9F%BA%E4%BA%8E%E7%8A%B6%E5%8E%8B%E7%9A%84%E7%BA%BF%E6%80%A7-rmq-%E7%AE%97%E6%B3%95)。

## 原理

把原序列分成 $O(\dfrac{n}{\log n})$ 块，每块长度 $\log n$，跑一次 ST 表，复杂度 $O(\dfrac{n}{\log n} \times \log n) = O(n)$。

记录块中的前后缀最值 $pre$ 和 $suf$。

记查询的 $l,r$ 分别属于 $bl,br$，若 $bl<br$，则答案在 $\max(\max_{i \in (bl,br)} a_i, suf_{bl}, pre_{br})$。

当 $bl=br$ 时，考虑状态压缩。

> 作者注：在大部分题目中，这种情况暴力 $O(\log n)$ 去扫已经足够优秀。

把 $a_{[1,r]}$ 插入单调栈中，则 $\max_{i \in [l,r]} a_i$ 就是单调栈中第一个下标 $\ge l$ 的值。这也是单调栈离线解决 RMQ 问题的基本思想。

状压记录每个数是否在单调栈中，使用速度非常快的 `__builtin_ctz` 函数即可实现 $O(1)$ 查询。

```cpp
template <class T, class Cmp = std::less<T>>
class RMQ {
private:
	Cmp cmp = Cmp();
	std::function<T(const T&, const T&)> func;

	int n, block;
	T a[N], st[__lg(N) + 1][N], pre[N], suf[N];
	int belong[N], pos[N];
	long long f[N];

	inline void build_st() {
		int cur = 0, id = 1;
		pos[0] = -1;
		for (int i = 1; i <= n; i++) {
			st[0][id] = func(st[0][id], a[i]);
			belong[i] = id;
			if (belong[i - 1] != belong[i]) pos[i] = 0;
			else pos[i] = pos[i - 1] + 1;
			if (++cur == block) cur = 0, id++;
		}
		if (n % block == 0) id--;
		for (int i = 1; i <= __lg(id); i++) {
			for (int j = 1; j + (1 << i) - 1 <= id; j++) {
				st[i][j] = func(st[i - 1][j], st[i - 1][j + (1 << (i - 1))]);
			}
		}
	}

	inline void build_subpre() {
		for (int i = 1; i <= n; i++) {
			if (belong[i] != belong[i - 1]) pre[i] = a[i];
			else pre[i] = func(pre[i - 1], a[i]);
		}
		for (int i = n; i >= 1; i--) {
			if (belong[i] != belong[i + 1]) suf[i] = a[i];
			else suf[i] = func(suf[i + 1], a[i]);
		}
	}

	inline void build_block() {
		static int stk[N], top;
		for (int i = 1; i <= n; i++) {
			if (belong[i] != belong[i - 1]) top = 0;
			else f[i] = f[i - 1];
			while (top > 0 && a[stk[top]] <= a[i]) {
				f[i] &= ~(1LL << pos[stk[top--]]);
			}
			stk[++top] = i;
			f[i] |= (1LL << pos[i]);
		}
	}

	void init(const T* _a) {
		func = [&](const T& x, const T& y) -> T {
			return cmp(x, y) ? y : x;
		};
		for (int i = 1; i <= n; i++) a[i] = _a[i];
		block = 63;  // 按需调整
		build_st(), build_subpre(), build_block();
	}

public:
	RMQ() {}
	RMQ(const T* _a, int _n) : n(_n) {init(_a);}

	int query(int l, int r) const {
		int bl = belong[l], br = belong[r];
		if (bl == br) return a[l + __builtin_ctzll(f[r] >> pos[l])];
		if (br - bl == 1) return func(suf[l], pre[r]);
		int k = __lg(br - bl - 1);
		return func(
			func(suf[l], pre[r]),
			func(st[k][bl + 1], st[k][br - (1 << k)])
		);
	}
};
```

个人感觉这种方法码量不大，容易记忆，比笛卡尔树 + LCA + 加减 $1$ RMQ 的 $O(n)$ 预处理 $O(1)$ 常数小且好写，配合 DFS 序求 LCA 可以实现线性处理常数查询，是值得学习的科技。$AKB171$, '数据结构', array['RMQ', '线性RMQ', 'ST表', '笛卡尔树'], 'col-ds-rmq-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-rmq-overview', 'RMQ 总览（ST 表 / 线性 RMQ）', $AKB172$## 算法原理

本页是「RMQ（区间最值查询）」的二级栏目索引：静态区间最值的标准做法是 ST 表（倍增预处理），线性 RMQ 则用四毛子/笛卡尔树等技巧把预处理或查询进一步优化。

**学习顺序**：先看 ST 表标准版（手动预处理对数表），再看内建函数求对数的写法，最后看线性 RMQ。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 用哪篇 |
|---|---|
| 静态区间最值，标准写法 | ST表（标准版1 - 手动预处理对数表） |
| 想少写预处理、用内建函数 | ST表（标准版2 - 内建函数求对数） |
| 需要线性预处理或更优查询 | 线性 RMQ |

ST 表核心转移：$st[i][j]=\min/\max(st[i][j-1],\ st[i+2^{j-1}][j-1])$，查询用两个长度为 $2^{\lfloor\log_2 len\rfloor}$ 的重叠区间合并。

## 逐行代码解析

本页是索引入口，不重复贴代码；三篇子页各自给出完整实现与逐行解析，页面自动渲染对应 `.cpp`。

## 复杂度分析

- ST 表：预处理 $O(n\log n)$，单次查询 $O(1)$，空间 $O(n\log n)$。
- 线性 RMQ：预处理可做到 $O(n)$ 或 $O(n\log n)$ 的不同变体，查询 $O(1)$；具体以各子页声明为准。

## 适用场景

- 静态数组的区间最大/最小值、区间 gcd 等可重复贡献（幂等）运算。
- 需要大量查询且不修改数组的场景。
- 作为 LCA、笛卡尔树等算法的预处理组件。

## 常见陷阱与注意事项

- ST 表只适用于「可重复贡献」的运算；区间和不能直接用两个重叠区间合并。
- `log` 表的边界与 `n=1` 要单独检查。
- 空间为 $n\log n$，$n$ 较大时注意内存。
- 查询时右端点偏移量 `r - 2^k + 1` 容易算错。
- 线性 RMQ 的常数与实现细节较多，先确认题目是否真的需要。

## 对比与扩展

- ST 表 vs 线段树：静态查询 ST 表更快，带修改则用线段树。
- ST 表 vs 分块/稀疏表变体：按查询次数与空间限制取舍。
- 可扩展到二维 ST 表、区间 gcd/lcm 等幂等运算。$AKB172$, '数据结构', array['RMQ', 'ST表', '总览', '学习路线', '稀疏表'], null, null, 'knowledge'),
('Fohen', 'col-ds-scapegoat-tree--fenfeng', '替罪羊树 · Fohen', $AKB173$## 算法原理

替罪羊树（Scapegoat Tree）是一种**重量平衡树**（weight-balanced tree），其核心思路非常直接：**平时不调整结构，等树变得"太不平衡"时，直接抓出罪魁祸首的整棵子树推倒重建**。

大多数平衡树（AVL、红黑树、Splay、Treap 等）会在每次插入或删除后小心翼翼地通过旋转来维持平衡，代码复杂且容易写错。替罪羊树则选择了一条截然不同的路：插入、删除时先按普通二叉搜索树（BST）的方式操作，**不做任何平衡调整**；等某棵子树的大小失衡到一定程度，就把导致失衡的那棵子树——也就是"**替罪羊**"——整个中序遍历后重新建成一棵完全平衡的树，这就是它名字的由来。

替罪羊树用一个参数 $\alpha$（平衡因子）来刻画"失衡"。对树上每个节点 $b$，设 $\text{sz}(b)$ 为以 $b$ 为根的子树大小，$\text{sz}(\text{ls}(b))$、$\text{sz}(\text{rs}(b))$ 分别为左右子树的大小。若存在节点 $b$ 满足

$$\max\bigl(\text{sz}(\text{ls}(b)),\ \text{sz}(\text{rs}(b))\bigr) > \alpha \cdot \text{sz}(b)$$

即某棵子树的大小超过了整棵子树大小的 $\alpha$ 倍，就认为以 $b$ 为根的子树"失衡"，这棵子树就是替罪羊，需要被重构。

重构分两步：**中序遍历**把替罪羊子树中的所有节点按升序收集进数组（BST 的中序序列天然有序），**二分建树**取数组中点作为新根、左右递归建树，得到一棵完全平衡的子树。单次重构的代价为 $O(\lvert T \rvert)$，其中 $\lvert T \rvert$ 是替罪羊子树的大小。

插入时先按普通 BST 插入新节点，再从插入点**自底向上回溯**，检查路径上是否存在失衡节点；找到（最深的）失衡节点后，就对它的整棵子树重构。删除有两种常见实现：**惰性删除**（不真正删节点，只把节点标记为已删除，等有效节点比例过低时触发重构）与**真正删除**（按 BST 方式删节点，再像插入一样回溯检查并重构），本代码采用后者。

## 核心公式 / 状态定义与转移方程

**状态定义**：每个节点 $b$ 存储键值 $\text{cnt}$（本代码沿用这一命名，`cnt` 即键值而非重复计数）、左右儿子 $\text{ls}$、$\text{rs}$、子树大小 $\text{sz}$，以及节点自存下标 $\text{u}$（恒等于其数组下标）。整棵树以根下标 $\text{rot}$ 标识，空节点用下标 0 表示（$\text{u}=0,\ \text{sz}=0$）。

**子树大小递推**（每个节点代表一个键值，本代码不做重复计数，重复键值以多个独立节点存在）：

$$\text{sz}(b) = \text{sz}(\text{ls}(b)) + \text{sz}(\text{rs}(b)) + 1$$

**平衡判定**：节点 $b$ 平衡当且仅当

$$\max\bigl(\text{sz}(\text{ls}(b)),\ \text{sz}(\text{rs}(b))\bigr) \le \alpha \cdot \text{sz}(b)$$

整棵树平衡当且仅当每个节点都满足上式。插入/删除后自底向上回溯，第一个不满足该式（即最深失衡）的节点就是替罪羊。

**重构转移**：设替罪羊子树的中序节点序列为 $A[0 \ldots m-1]$，重建时取 $mid=\lfloor (l+r)/2 \rfloor$ 作为根，递归处理区间 $[l, mid-1]$ 与 $[mid+1, r]$；当 $l>r$ 时返回空节点 0。重建后的子树完全平衡，高度为 $O(\log m)$。

## 逐行代码解析

下面是完整实现（洛谷 P3369「普通平衡树」的六种操作）。字段 `cnt` 存键值、`u` 存节点自存下标、`sz` 为子树大小、`ls/rs` 为左右儿子。

### 模块一 · 头文件、全局数组与节点结构

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=4e5+10;
const double ALPHA=0.75;
int tot=0,rot=0;
struct bst{
    int u,cnt;
    int ls,rs;
    int sz;
    bst():u(0),cnt(0),ls(0),rs(0),sz(0){}
    bst(int b,int x):u(b),cnt(x),ls(0),rs(0),sz(1){}
} wcj[N];
```

- `#define int long long` 把 `int` 全局替换为 `long long`，因此主函数必须写成 `signed main`，否则返回值类型冲突。
- 结构体字段 `cnt` 存键值、`u` 存节点自存下标（恒等于数组下标）、`ls/rs` 为左右儿子、`sz` 为子树大小；本代码不设重复计数，重复键值以多个独立节点存在。
- `wcj` 是定长数组（$N=4\times10^5+10$），下标即节点编号；`wcj[0]` 由默认构造函数初始化成全 0，作为空节点，`wcj[b].u==0` 即表示节点 $b$ 为空。
- 全局 `tot` 记录已分配节点数、`rot` 记录根下标；`ALPHA=0.75` 是平衡因子，落在经验最优区间 $0.7 \sim 0.8$ 内。

### 模块二 · 查找与平衡判定

```cpp
int cxsearch(int b,int v){
    if(wcj[b].u==0||wcj[b].cnt==v) return wcj[b].u;
    if(v<wcj[b].cnt) return cxsearch(wcj[b].ls,v);
    else return cxsearch(wcj[b].rs,v);
}
bool isping(int b){           //判断子树是否平衡
    if(b==0) return true;
    int lsz=wcj[wcj[b].ls].sz;
    int rsz=wcj[wcj[b].rs].sz;
    return max(lsz,rsz)<=ALPHA*wcj[b].sz;
}
```

- `cxsearch` 沿 BST 性质递归下探：命中键值 $v$ 或走到空节点即返回节点下标；本代码中它未被主流程调用，仅作为查找原语保留。
- `isping` 判定子树是否平衡：空节点恒平衡；否则取左右子树大小，返回 $\max(\text{lsz},\text{rsz}) \le \alpha \cdot \text{sz}$，与"核心公式"中的失衡判据一一对应。
- 平衡因子 $\alpha$ 越大越接近普通 BST，越小重构越频繁；`ALPHA=0.75` 是常见的折中取值。

### 模块三 · 中序遍历与重建

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

- `findnode` 中序遍历把子树内所有节点编号按键值升序收集进 `son` 向量，BST 的中序序列天然有序。
- `build` 取区间中点作根、左右递归建树，并沿途重算 `sz`，建出完全平衡的子树；`l>r` 时返回 0（空节点）。
- `rebuild` 先收集节点、清空各节点的左右儿子指针，再整体二分重建，并把新根写回引用参数 `b`（`b` 即被重构子树的根下标）。
- 这三个函数合起来实现"推倒重建"：单次重构代价为 $O(m)$，$m$ 为替罪羊子树大小。

### 模块四 · 插入与删除

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

- `crinsert` 走到空位（`wcj[b].u==0`）就 `tot++` 新建节点；否则按 BST 方向递归插入，返回后更新 `sz` 并检查 `isping`，失衡即 `rebuild`。
- `scdelete` 按"未找到 / 去左 / 去右 / 命中"四分：命中时若只有一个儿子则直接接上另一个儿子；双儿子则取右子树最小键值覆盖当前键值，再递归删除该后继。
- 插入/删除都沿递归**自底向上回溯**，返回路径上每个节点都重算 `sz` 并判失衡，最深失衡节点会最先被重构。
- `return wcj[b].u` 返回节点下标，调用处 `rot=crinsert(rot,x)` 把新根写回全局 `rot`，保持根指针正确。

### 模块五 · 查排名与查第 k 小

```cpp
int queryless(int b,int x){
    if(b==0) return 0;
    if(x<=wcj[b].cnt) return queryless(wcj[b].ls,x);
    else return wcj[wcj[b].ls].sz+1+queryless(wcj[b].rs,x);
}
int kth(int b,int k){
    if(k<=wcj[wcj[b].ls].sz) return kth(wcj[b].ls,k);
    else if(k==wcj[wcj[b].ls].sz+1) return wcj[b].cnt;
    else return kth(wcj[b].rs,k-wcj[wcj[b].ls].sz-1);
}
```

- `queryless(b,x)` 返回「键值 $<x$ 的节点个数」：沿键值下探，向左走不累加，向右走累加左子树大小 +1，故排名 $=\text{queryless}(\text{rot},x)+1$。
- `kth(b,k)` 按子树大小二分：$k \le \text{sz}(\text{ls})$ 走左子树，$k = \text{sz}(\text{ls})+1$ 命中当前键值，否则走右子树并把 $k$ 减掉左子树大小 +1。
- 两个函数都只沿一条到叶子的路径递归，树高 $O(\log n)$，故均摊/期望 $O(\log n)$。

### 模块六 · 前驱、后继与主函数

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
int houjiji(int b,int x){
    int ans=LLONG_MAX;
    while(b!=0){
        if(wcj[b].cnt>x){
            ans=wcj[b].cnt;
            b=wcj[b].ls;
        }else{
            b=wcj[b].rs;
        }
    }
    return ans;
}
signed main(){
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n;cin>>n;
    while(n--){
        int opt,x;cin>>opt>>x;
        if(opt==1) rot=crinsert(rot,x);
        else if(opt==2) rot=scdelete(rot,x);
        else if(opt==3) cout<<queryless(rot,x)+1<<'\n';
        else if(opt==4) cout<<kth(rot,x)<<'\n';
        else if(opt==5) cout<<qianququ(rot,x)<<'\n';
        else if(opt==6) cout<<houjiji(rot,x)<<'\n';
    }
    return 0;
}
```

- `qianququ` 迭代下探，维护「$<x$ 的键值中的最大者」作为前驱；`houjiji` 对称地维护「$>x$ 的键值中的最小者」作为后继；无解时分别返回 `LLONG_MIN` / `LLONG_MAX`。
- `main` 实现 P3369 六种操作：1 插入、2 删除、3 查排名、4 查第 $k$ 小、5 前驱、6 后继。
- 每次插入/删除后 `rot` 都被赋值为新的根下标，保证下一次操作作用在最新树上。
- `#define int long long` 下主函数用 `signed main`，避免 `long long main` 非法。

## 复杂度分析

- **单次重构**：中序遍历 + 二分重建均为 $O(m)$，$m$ 为替罪羊子树大小；最坏一次重构可达 $O(n)$。
- **均摊复杂度**：替罪羊树的复杂度是**均摊**的，很大程度上取决于 $\alpha$ 的取值。插入、删除均摊 $O(\log n)$，查找 $O(\log n)$。虽然单次操作可能因触发重构而变慢，但把重构代价摊到足够多次的插入/删除上，所有操作的均摊代价都是 $O(\log n)$。
- **空间复杂度**：$O(n)$。`wcj` 是定长数组（$N=4\times10^5+10$），每个节点是定长结构体，惰性删除之外不额外分配；`rebuild` 中临时用到的 `vector<int> son` 最多 $O(n)$ 且随调用结束释放。
- 参数 $\alpha$ 的经验最优区间为 $0.7 \sim 0.8$；$\alpha$ 越大越接近普通 BST（退化为链则查找变 $O(n)$），$\alpha$ 越小重构越频繁、常数越大。

## 适用场景

- **入门与理解平衡树**：替罪羊树不写旋转、不维护平衡因子，用"重构"这一直观操作代替平衡调整，实现简单、常数小，适合作为理解平衡树思想的切入点。
- **动态有序集合**：需要同时支持插入、删除、查排名、查第 $k$ 小、前驱后继的题目，典型如洛谷 P3369「普通平衡树」。
- **不适用**：需要**区间操作**、**完全可持久化**的场景（替罪羊树不支持）；对均摊复杂度敏感、可能被构造数据针对性卡掉的场合也应换严格平衡树（AVL/红黑树）或 `std::set`。

## 常见陷阱与注意事项

- **$\alpha$ 的取值**：$\alpha$ 过大（接近 1）树近乎普通 BST，易退化；$\alpha$ 过小（接近 0.5）重构过于频繁、常数大。经验取 $0.7 \sim 0.8$，本代码用 $0.75$。
- **均摊而非最坏**：单次插入/删除可能因触发重构而达到 $O(n)$，单次操作的峰值时间不保证 $O(\log n)$，只有均摊下才是 $O(\log n)$。
- **空节点必须全 0**：`crinsert` 依赖 `wcj[b].u==0` 判空、`isping` 依赖 `wcj[0].sz==0`，全局数组的默认构造恰好满足这一点；若改用动态分配需显式初始化 0 号位。
- **`#define int long long` 的连锁**：主函数必须写 `signed main`，且 `LLONG_MIN` / `LLONG_MAX` 用作前驱/后继的"无穷"哨兵，值域应与实际键值保持距离。
- **被卡风险**：重量平衡树的均摊分析依赖 $\alpha$ 与操作序列，某些构造数据可能使重构频繁触发、常数骤增，竞赛中作为正解时应评估数据强度。
- **删除的两种实现**：本代码是"真正删除"；若改用"惰性删除"，需额外维护有效节点计数，并在有效比例过低时触发重构，两者复杂度结论相同但代码结构不同。

## 对比与扩展

| 结构 | 是否旋转 | 复杂度 | 主要优势 | 主要代价 |
|---|---|---|---|---|
| 替罪羊树 | 否（重构） | 均摊 $O(\log n)$ | 实现简单、常数小、直观 | 均摊非最坏，不支持区间/可持久化 |
| 旋转 Treap | 是 | 期望 $O(\log n)$ | 思路直观 | 需写旋转 |
| FHQ-Treap | 否（分裂合并） | 期望 $O(\log n)$ | 代码短、可持久化 | 随机化，最坏退化 |
| Splay | 是（伸展） | 均摊 $O(\log n)$ | 区间操作强 | 常数较大 |
| AVL / 红黑树 | 是 | 严格 $O(\log n)$ | 最坏有保证 | 平衡调整复杂 |

- **与旋转平衡树对比**：替罪羊树用"整棵子树重建"代替旋转，免去旋转的边界处理；缺点是单次操作可能被重构拖慢，只有均摊保证。
- **与 FHQ-Treap 对比**：FHQ-Treap 靠 Split/Merge 组合完成所有操作、天然可持久化；替罪羊树不支持区间操作、也无法高效可持久化。
- **扩展方向**：**惰性删除 + 定期重构**可把删除也摊还到 $O(\log n)$；重量平衡的思想还被用于 KD 树等"按子树重量判平衡并重构"的数据结构。
- **前置/相关**：需先掌握 BST 与中序遍历；平衡树入门可先看「平衡树」总述，进阶可对比 Splay 与 FHQ-Treap。$AKB173$, '数据结构', array['平衡树', '替罪羊树', '重量平衡树', '重构', '均摊分析'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('Xesir', 'col-ds-scapegoat-tree--xesir', '替罪羊树 · Xesir', $AKB174$## 算法原理

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
- 代码里的 `cnt` 是键值不是计数，和某些教材的写法不同。$AKB174$, '数据结构', array['数据结构', '平衡树', '替罪羊树', '重量平衡', '重构', '平衡因子'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('Xesir', 'col-ds-segtree-basic--xesir', '朴素线段树（区间加 + 区间求和） · Xesir', $AKB175$## 算法原理

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
- 原文教学版的结构体叫 `goc`，实际模板里叫 `wcj`、外层叫 `aqtw`，看代码时别被命名绕晕。$AKB175$, '数据结构', array['数据结构', '线段树', '懒标记', '区间修改', '区间求和'], 'col-hub-ds-segtree', null, 'knowledge'),
('world-needs-sunday', 'col-ds-segtree-basic', '线段树基础模板（区间加法+区间求和 P3372）', $AKB176$## 算法原理

线段树（Segment Tree）是一种基于分治思想的二叉树数据结构，用于维护区间上的可合并信息。它将整个区间 [1, n] 递归地二分为两个子区间，直到每个叶子节点对应一个长度为 1 的单元区间。树的根节点（通常编号为 1）维护整个区间 [1, n] 的聚合信息（本模板中为区间和）；对于任意节点 rt，其左子节点编号为 `rt<<1`（即 2*rt），维护区间 [l, mid]；右子节点编号为 `(rt<<1)+1`（即 2*rt+1），维护区间 [mid+1, r]，其中 `mid=(l+r)/2`。由于每次二分区间长度减半，树的高度为 $O(\log n)$，这是线段树能够高效支持区间操作的根本原因。

如果每次区间修改都把所有叶子节点更新一遍，复杂度将退化到 $O(n)$。Lazy Propagation（延迟标记）是解决这一问题的关键技巧：当一个修改操作完全覆盖某节点 rt 所代表的区间时，我们只更新该节点的 tree 值并在 lazy 数组上"记账"，不再继续向下递归到叶子。`lazy[rt]` 表示"rt 的子树中所有节点都还需要加上 lazy[rt]，但目前尚未真正下传"。只有当后续操作需要访问 rt 的子节点时，才通过 `my_down` 函数把 lazy 标记下传给两个孩子，并把自身的 lazy 清零。这样每次修改至多影响 $O(\log n)$ 个节点，从而保证单次操作 $O(\log n)$。

线段树的四个核心操作紧密配合：build（建树）自底向上初始化每个节点的区间和；pushdown（my_down）在访问子节点前把父节点的延迟标记下传，保证子节点 tree 值的正确性；update（my_add）在修改时先 pushdown，若完全覆盖则打标记返回，否则递归两个孩子并在返回时 pushup（用孩子值更新自身）；query（my_get）同样先 pushdown，再根据区间相交情况决定返回、合并或递归。pushdown 必须在 update 和 query 递归前都调用，否则子节点的 tree 值会因为没有应用父节点的历史修改而出错。

本模板在建树前先从输入读入原数组 `a[1..n]`，叶子节点的初始值取自 `tree[rt]=a[l]`。因此它支持任意初始序列（如洛谷 P3372 的读入要求），不再假定初始序列为 1,2,3,...,n。

## 数据结构图示

```
                 [1,8] rt=1  sum=36
                /              \
        [1,4] rt=2            [5,8] rt=3
        /        \             /        \
   [1,2] rt=4  [3,4] rt=5  [5,6] rt=6  [7,8] rt=7
    /    \      /    \       /    \       /    \
 [1]rt=8 [2]rt=9 [3]rt=10 [4]rt=11 [5]rt=12 [6]rt=13 [7]rt=14 [8]rt=15
```

> 上图为 n=8 时的结构示意，根节点 sum 的值为 $\sum_{i=1}^{8} a[i]$（图中以输入为 1..8 时 sum=36 为例）。

Lazy 标记下传示例：对 [1,8] 全区间加 k 后，根节点 rt=1 被完全覆盖，直接执行 $\text{tree}[1] \leftarrow \text{tree}[1] + 8k$ 和 $\text{lazy}[1] \leftarrow \text{lazy}[1] + k$，子节点不变。下次查询 [1,4] 时调用 `my_down(1,1,8)`，把 lazy[1] 下传：

```
   my_down(1,1,8):  mid=4
     tree[2] += lazy[1]*(4-1+1) = 4k   lazy[2] += k
     tree[3] += lazy[1]*(8-4)   = 4k   lazy[3] += k
     lazy[1] = 0
```

之后 rt=2、rt=3 的 tree 已正确，可继续向下递归。

## 核心操作详解

### init(rt, l, r) / init(n)

- **作用**：建树 / 分配数组并启动建树。
- **参数**：rt 当前节点编号，l,r 当前区间，n 总规模。
- **算法步骤**：若 `l==r` 为叶子，赋初值 `tree[rt]=a[l]`（原数组对应位置）；否则取 `mid=(l+r)/2`，递归建左子 [l,mid] 和右子 [mid+1,r]，回溯时 `tree[rt]=tree[左]+tree[右]`。`init(n)` 负责把 lazy 开 4n+1 并初始化为 0、tree 开 4n+1 并初始化为 0，然后从 `init(1,1,n)` 开始。
- **关键细节**：数组必须开 4n 而非 2n。原因是当 n 不是 2 的幂时，线段树最后一层会有大量"空缺"，按 `rt<<1` 编号会导致最大节点编号接近 $4n$。开 $4n+1$ 才能保证不越界。

### my_down(i, l, r)

- **作用**：将节点 i 的 lazy 标记下传给左右子节点。
- **参数**：i 节点编号，l,r 区间。
- **算法步骤**：若 `lazy[i]==0` 或 `l==r`（叶子无需下传）直接返回；`mid=(l+r)/2`；左子区间长度 $mid-l+1$，对左子执行 $\text{tree}[i \ll 1] \leftarrow \text{tree}[i \ll 1] + \text{lazy}[i] \times (mid-l+1)$ 和 $\text{lazy}[i \ll 1] \leftarrow \text{lazy}[i \ll 1] + \text{lazy}[i]$；右子区间长度 $r-mid$，同理；最后 `lazy[i]=0`。
- **关键细节**：tree 的增量必须是"lazy × 区间长度"，因为 lazy 表示"每个元素都要加 lazy"，区间和的增量就是 $\text{lazy} \times \text{len}$。lazy 是累加的（+=）而不是覆盖。

### my_get(rt, l, r, nl, nr)

- **作用**：查询区间 [nl,nr] 的和。
- **参数**：rt,l,r 当前节点，nl,nr 查询区间。
- **算法步骤**：先 `my_down` 保证子节点正确；若 [l,r] 与 [nl,nr] 不相交返回 0；若 [l,r] 被 [nl,nr] 完全包含返回 `tree[rt]`；否则取 mid 递归左右子并相加。
- **关键细节**：进入函数第一行就 my_down，因为后续可能要读子节点的 tree，必须先把父标记下传。

### my_add(rt, l, r, nl, nr, k)

- **作用**：区间 [nl,nr] 每个元素加 k。
- **算法步骤**：先 `my_down`；不相交返回；若完全包含，执行以下更新后返回（打标记不下传）：

  $$\text{tree}[rt] \leftarrow \text{tree}[rt] + (r-l+1) \times k$$

  $$\text{lazy}[rt] \leftarrow \text{lazy}[rt] + k$$

  否则递归左右子，回溯 `tree[rt]=tree[左]+tree[右]`（pushup）。
- **关键细节**：完全包含时只更新自己并打标记，子节点保持旧值——这就是 lazy 的核心；回溯的 pushup 保证父节点区间和正确。

## 逐行代码解析

### 全局变量

```cpp
#include<bits/stdc++.h>
/*洛谷3372*/
using namespace std;
vector<long long> tree, lazy, a;
```

- `tree`、`lazy`、`a` 是三个全局 `vector<long long>`，分别存节点区间和、延迟标记、原数组；用 `long long` 防止区间和多次累加后溢出 int。
- `#include<bits/stdc++.h>` 万能头 + `using namespace std`，让 `vector`、`cin/cout` 可直接使用。

### init（建树）

```cpp
void init(int rt, int l, int r)
{
	if (l == r)
	{
		tree[rt] = a[l];                       // 叶子：初值=原数组 a[l]
		return;
	}
	int mid = (l + r) >> 1;
	init(rt << 1, l, mid);                    // 建左子 [l,mid]
	init((rt << 1) + 1, mid + 1, r);          // 建右子 [mid+1,r]
	tree[rt] = tree[rt << 1] + tree[(rt << 1) + 1]; // pushup：区间和=左+右
}
void init(int n)
{
	lazy.assign(4 * n + 1, 0);   // lazy 初始化为 0（加法单位元）
	tree.assign(n * 4 + 1, 0);   // tree 大小 4n+1，初始化为 0
	init(1, 1, n);               // 从根开始建树
}
```

- 两个重载：`init(rt,l,r)` 递归建树，`init(n)` 负责分配数组并启动 `init(1,1,n)`。
- `tree[rt]=a[l]` 是叶子赋初值：叶子初值取原数组 `a[l]`，因此支持任意初始序列（如 P3372 读入的数组）。
- `assign(4*n+1,0)` / `assign(n*4+1,0)` 把 lazy、tree 全置 0，避免垃圾值被当成下传标记或干扰区间和；数组必须开 4n 而非 2n，因为 n 非 2 的幂时节点编号会接近 4n。
- `mid=(l+r)>>1`，左子区间 [l,mid]、右子 [mid+1,r]；回溯 `tree[rt]=左+右` 完成 pushup。

### my_down（下传 lazy）

```cpp
void my_down(int i, int l, int r)
{
	if (lazy[i] == 0 || l == r) return;      // 无标记或叶子，无需下传
	int mid = (l + r) >> 1;
	lazy[i << 1] += lazy[i];                              // 左子标记累加
	tree[i << 1] += (long long)(mid - l + 1) * lazy[i];   // 左子和 += lazy*左子长度
	lazy[(i << 1) + 1] += lazy[i];                        // 右子标记累加
	tree[(i << 1) + 1] += (long long)(r - mid) * lazy[i]; // 右子和 += lazy*右子长度
	lazy[i] = 0;                          // 清空自身标记
}
```

- 先判断 `lazy[i]==0 || l==r`：无标记或叶子节点无需下传，直接返回。
- tree 增量是 `lazy × 区间长度`（不是 lazy 本身），因为 lazy 表示"每个元素都要加"，区间和增量 = lazy×len。
- 左子长度 `mid-l+1`、右子长度 `r-mid`，二者之和恰为 `r-l+1`；`(long long)` 强转避免 `lazy×长度` 超过 int。
- lazy 用 `+=` 累加而非覆盖，最后把自身 `lazy[i]=0` 清空。

### my_get（区间查询）

```cpp
long long my_get(int rt, int l, int r, const int& nl, const int& nr)
{
	my_down(rt, l, r);                        // 关键：先下传标记
	if (l > nr || r < nl) return 0;           // 不相交
	else if (nl <= l && nr >= r) return tree[rt];   // 完全包含
	else
	{
		int mid = (l + r) >> 1;
		return my_get(rt << 1, l, mid, nl, nr) + my_get((rt << 1) + 1, mid + 1, r, nl, nr); // 左右子相加
	}
}
```

- 进入第一行就 `my_down`：因为后面要读子节点的 tree，必须先下传父标记保证子节点正确。
- 三段式判断：不相交返回 0、完全包含直接返回 tree、部分相交递归左右子并相加。
- 不相交条件是 `l>nr || r<nl`，两个边界方向别写反；`const int&` 传参避免拷贝。

### my_add（区间加法）

```cpp
void my_add(int rt, int l, int r, const int& nl, const int& nr, const long long& k)
{
	my_down(rt, l, r);                        // 先下传
	if (l > nr || r < nl) return;             // 不相交
	if (nl <= l && nr >= r)                   // 完全包含：打标记
	{
		tree[rt] += (long long)(r - l + 1) * k;   // 区间和 += k*长度
		lazy[rt] += k;                            // 标记累加
		return;
	}
	int mid = (l + r) >> 1;
	my_add(rt << 1, l, mid, nl, nr, k);                // 递归左子
	my_add((rt << 1) + 1, mid + 1, r, nl, nr, k);      // 递归右子
	tree[rt] = tree[rt << 1] + tree[(rt << 1) + 1];    // pushup
}
```

- 完全包含分支只更新 `tree[rt] += k×长度` 和 `lazy[rt] += k` 后 return，不递归子节点——这正是 lazy 的核心，误递归会退化到 $O(n)$。
- 部分相交时递归左右子，回溯 `tree[rt]=左+右` 做 pushup，保证父节点区间和正确。
- k 用 `const long long&` 传引用，修改值可能较大，需用 long long 类型。

### main

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);   // 快读
	int n, m;
	cin >> n >> m;
	a.assign(n + 1, 0);                    // 原数组 a 大小 n+1，下标 1..n
	for (int i = 1; i <= n; i++) cin >> a[i];   // 读入原数组
	init(n);
	for (int i = 0; i < m; i++)
	{
		int op;
		cin >> op;
		if (op == 1)                       // 区间加
		{
			int x, y;
			long long k;
			cin >> x >> y >> k;
			my_add(1, 1, n, x, y, k);
		}
		else                              // 区间求和
		{
			int x, y;
			cin >> x >> y;
			cout << my_get(1, 1, n, x, y) << '\n';
		}
	}
	return 0;
}
```

- 读入 n,m 后先 `a.assign(n+1,0)` 分配原数组，再循环读入 `a[1..n]`，然后 `init(n)` 建树，最后循环处理 m 次操作。
- `op==1` 读 x,y,k 调 `my_add` 做区间加；否则读 x,y 调 `my_get` 输出区间和。
- `ios::sync_with_stdio(false)` 关闭与 stdio 同步、`cin.tie(nullptr)` 解除 cin 与 cout 的绑定，加速 IO 避免大数据超时。

## 复杂度分析

- **建树 init**：每个节点访问且仅访问一次，共约 $2n-1$ 个节点，复杂度 $O(n)$。
- **修改 my_add / 查询 my_get**：递归路径沿树高 $O(\log n)$ 下降。由于区间操作在每一层至多访问 4 个节点（左右各延伸的边界节点 + 完全包含的内部节点），总访问节点数 $O(\log n)$。单次操作 $O(\log n)$。
- **空间**：tree、lazy 各开 $4n+1$。当 n 非 2 的幂时，按 `rt<<1` 编号会使最大下标接近 $4n$，故需 $4n$ 而非 $2n$。空间 $O(4n) = O(n)$。
- **总复杂度**：m 次操作 $O((n + m) \log n)$。

## 适用场景

适用于"区间加法修改 + 区间求和查询"的静态序列问题，如洛谷 P3372。它是所有 lazy 线段树的入门模板，掌握后可推广到区间最值、区间赋值、双标记（乘法线段树）等变体。当操作只有单点修改 + 区间查询时，树状数组（BIT）代码更短、常数更小，是更优选择；一旦涉及区间修改，lazy 线段树则是标准解法。

## 常见陷阱与注意事项

1. **数组大小必须开 4n 而非 2n**：n 非 2 的幂时编号会接近 $4n$，开 $2n$ 会导致越界 RE。
2. **my_down 必须在 update 和 query 递归子节点之前调用**，否则子节点 tree 值未应用父标记，结果错误。
3. **lazy 数组必须初始化为 0**（加法单位元），否则会把垃圾值当下传标记。
4. **tree 增量是 lazy×区间长度，不是 lazy 本身**：$\text{tree}[\text{child}] \leftarrow \text{tree}[\text{child}] + \text{lazy} \times \text{len}$，漏乘长度是常见错误。
5. **tree 和 k 必须用 long long**：$n=10^5$、$k=10^4$ 时区间和可达 $10^9$，多次累加会爆 int。
6. **完全包含分支不要误递归子节点**：本模板在该分支只更新 tree 和 lazy 后 return，若误更新子节点会退化到 $O(n)$。

## 对比与扩展

- **与树状数组（BIT）对比**：BIT 只支持可差分的操作（前缀和可逆），区间加+区间查需两棵 BIT，代码极短但灵活性差；线段树支持任意可合并信息（最值、GCD、历史最值等），适用面广得多。
- **与平衡树/Splay 对比**：线段树下标固定，不支持动态插入删除；若需动态维护有序序列，应使用平衡树或 FHQ Treap。
- **扩展方向**：(1) 区间赋值（覆盖型 lazy，需额外标记区分"未赋值"）；(2) 双标记乘法线段树（见 ds-segtree-mul）；(3) 离散化线段树处理大值域（见 ds-segtree-discretize）；(4) 可持久化线段树（主席树）支持历史版本查询；(5) 李超树维护线段/函数最值；(6) 线段树合并解决树上权值统计。$AKB176$, '数据结构', array['数据结构', '线段树', '区间修改', '区间求和', 'lazy标记', 'P3372'], 'col-hub-ds-segtree', null, 'knowledge'),
('Xesir', 'col-ds-segtree-combined--xesir', '缝合线段树（区间加/乘/赋值 + 区间求和/最值） · Xesir', $AKB177$## 算法原理

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
- 代码使用了 `#pragma GCC optimize` 系列和自定义 `IO` 命名空间，本地调试时如果编译器不支持这些 pragma，可以按需处理。$AKB177$, '数据结构', array['数据结构', '线段树', '区间赋值', '区间乘法', '多标记', '区间最值'], 'col-hub-ds-segtree', null, 'knowledge'),
('Fohen', 'col-ds-segtree-discretize--fenfeng', '离散化+线段树（大值域少查询） · Fohen', $AKB178$## 算法原理

很多 OI 算法用「值域」作为数组下标，例如树状数组、权值线段树、主席树等。但实际数据中的值域往往很大（常见 $10^9$，甚至更大），直接按值域大小开数组必然导致空间爆掉。离散化（Discretization）就是用来解决这个问题的。

离散化的本质是**压缩值域**：当值域很大、但实际用到的数很少时，把所有出现的值收集起来，排序去重后，用一个较小的编号（排名）代替原值，从而把值域从 $O(V)$ 压缩到 $O(n)$ 级别。一般题面中 $n \le 10^5$ 而 $V \le 10^9$ 甚至更大，因此这是一个很大的优化：既避免开不下的大数组，又保留元素之间的大小关系。

例如原数组如下：

```text
a = [1, 100, 10000, 100, 1]
```

如果直接按值域 $10000$ 开数组，浪费巨大。离散化后：

```text
排序去重: [1, 100, 10000]
映射编号: 1->1, 100->2, 10000->3
离散化后: [1, 2, 3, 2, 1]
```

与「不离散化」相对的是直接用原值（下标就是元素本身）。一般情况下，离散化后写代码更省空间，也更容易套用需要「以值域作下标」的数据结构。

需要强调：离散化会**丢失原值的绝对信息**（例如「两数之差」「两数之积」无法直接从离散化后的编号还原）。因此离散化只在**只需要相对大小关系、不需要绝对权值**时使用，否则需要额外维护原值（见下文「逆映射还原」）。

## 核心公式 / 状态定义与转移方程

设原数组为 $a$，把它复制到数组 $b$ 并排序去重后，$b$ 的长度为 $len$。保序离散化把每个原值 $x$ 映射为它在 $b$ 中的排名：

$$\text{rank}(x) = i \quad \text{其中} \quad b[i] = x$$

实现上就是「排序去重 + 二分定位」：用 `lower_bound` 在 $b$ 中定位 $x$，得到 $1 \sim len$ 的编号。这样得到的编号**保留了原值的大小关系**（$x < y \Rightarrow \text{rank}(x) < \text{rank}(y)$），可以继续用于比较、二分等操作。

若离散化后需要输出原值，则额外维护逆映射数组 $rev$：

$$rev[i] = b[i],\quad 1 \le i \le len$$

查询得到编号 $id$ 后，用 $rev[id]$ 即可还原成原值。

若不关心大小关系、只需判断两个值是否相等，可用哈希表直接建立「原值 → 编号」的映射，免去排序（见下文）。

## 逐行代码解析

### 保序离散化（sort + unique + lower_bound）

```cpp
sort(b + 1, b + n + 1);
int len = unique(b + 1, b + n + 1) - b - 1;
for (int i = 1; i <= n; i++)
    a[i] = lower_bound(b + 1, b + len + 1, a[i]) - b;
```

- 先把副本 $b$ 排序，`unique` 去重后 `len` 是不重复元素的个数。
- 对原数组 $a$ 的每个元素，用 `lower_bound` 找到它在去重数组中的排名，并写回 $a$。
- 排名以 $1$ 起（`b[1]` 是最小值，对应排名 $1$），因此后续可直接套用「以值域作下标」的数据结构。

### 哈希表映射（无序、免排序）

```cpp
unordered_map<int, int> mp;
int tot = 0;
for (int i = 1; i <= n; i++) {
    if (!mp.count(a[i])) mp[a[i]] = ++tot;
    a[i] = mp[a[i]];
}
```

- 每个值首次出现时分配一个新编号 `++tot`，之后复用同一编号。
- 不要求排序，建表 $O(n)$、单次查询 $O(1)$ 均摊；缺点是丢失了大小关系，无法回答「第 $k$ 小」这类依赖顺序的问题。

### 逆映射还原

```cpp
for (int i = 1; i <= len; i++) rev[i] = b[i];
```

- 第 $i$ 个编号对应的原值就是去重数组的第 $i$ 项，查询得到编号后直接 `rev[id]` 还原。

## 复杂度分析

- **保序离散化**：排序 $O(n \log n)$，`unique` $O(n)$，对每个元素做一次 `lower_bound` 共 $O(n \log n)$，整体 $O(n \log n)$。
- **哈希表映射**：建表 $O(n)$，单次查询 $O(1)$ 均摊，整体 $O(n)$；代价是丢失顺序信息。
- **空间复杂度**：去重数组 $b$、逆映射 `rev`、哈希表 `mp` 均为 $O(n)$。

离散化后的值域规模与「实际用到的不同值的个数」同阶，因此为值域开辟的数据结构（线段树、树状数组、主席树等）也从 $O(V)$ 降到 $O(n)$。

## 适用场景

- **树状数组 / 线段树以下标为值域**：值域很大但数据量小时，先离散化才能开数组；
- **权值线段树 / 主席树**：维护值域频次，必须先把值域压缩；
- **逆序对统计**：值域大时，离散化后用树状数组求逆序对；
- **扫描线**：矩形面积并、周长并等，端点坐标需要离散化；
- **二维数点**：把 $x$、$y$ 坐标分别压缩到 $O(n)$ 后套数据结构。

一句话判断：**只关心顺序时，离散化无损；关心数值本身时，先想清楚丢失的信息如何补回。**

## 常见陷阱与注意事项

1. **离散化丢失绝对信息**：「两数之差」「两数之积」等无法从编号还原，需要绝对权值的场合要额外维护原值（逆映射 `rev`）。
2. **区间离散化漏空隙**：维护区间 $[l, r]$ 时只离散化端点，会漏掉相邻端点之间的「空隙」；应在端点集合中额外加入 $l-1$ 或 $r+1$，或改用左闭右开表示，保证连续性。
3. **忘记逆映射**：查的是编号、输出却要原值，容易只返回 `rank` 而没还原。
4. **保序与哈希的取舍**：哈希映射不保序，不能做二分、不能求「第 $k$ 小」；需要比较大小时用保序离散化。
5. **排名起点要统一**：`lower_bound - b` 得到的是 $1$ 起排名；若代码里混用 $0$ 起 / $1$ 起下标，会整体错位。

## 对比与扩展

| 方式 | 是否保序 | 适用场景 |
| :--- | :--- | :--- |
| `sort + unique + lower_bound` | 是 | 需要比较大小、二分 |
| 哈希表映射 | 否 | 只需判断相等 |
| 区间离散化 | 是 | 线段覆盖、区间问题 |
| 二维坐标压缩 | 是 | 平面点集、扫描线 |

- **保序离散化 vs 哈希映射**：保序离散化保留大小关系，可用于二分与「第 $k$ 小」；哈希映射建表更快且无序，适合只判断相等的场景。
- **区间离散化 vs 点离散化**：点离散化只保留端点，会丢间隙；区间离散化额外补入中间点，适用于需要「真实区间长度 / 是否被完全覆盖」的问题（典型如大值域上的线段树）。
- **二维坐标压缩**：对 $x$、$y$ 坐标各自独立离散化后再套扫描线或二维数据结构，而不是把 $(x,y)$ 当成整体编号。$AKB178$, '数据结构', array['数据结构', '离散化', '保序离散化', '区间离散化', '坐标压缩', '哈希表'], 'col-hub-ds-segtree', null, 'knowledge'),
('world-needs-sunday', 'col-ds-segtree-discretize', '离散化+线段树（大值域少查询）', $AKB179$## 算法原理

当值域极大（如 $n=10^9$）但实际操作次数 m 很小时，直接对 [1,n] 建线段树需要 $O(n)$ 空间，显然不可行。离散化是标准应对手段，但朴素离散化（点离散化）只保留查询端点本身，会丢失端点之间连续区间的信息。例如查询 [1, 10^9] 的和，若只离散化出 {1, 10^9} 两个点，中间 $10^9-2$ 个值就被忽略了。本模板采用"区间离散化"（又称"段离散化"）：不仅保留每个关键点作为一个长度为 1 的段，还在相邻关键点 dis[i] 与 dis[j] 之间若有间隔（`dis[i]+1 < dis[j]`）时，额外创建一个段表示连续区间 [dis[i]+1, dis[j]-1]。这样整个 [1,n] 被划分成若干"操作粒度一致"的段，段数至多 $2m+2$，可控。

线段树建立在这些"段"之上：树节点 rt 不再代表下标区间 [l,r]，而是代表"段区间"——第 l 段到第 r 段。每个段 i 有真实的值域范围 [myleft[i], myright[i]]，存储在两个并行数组中。树节点 rt 的区间和增量（lazy 下传时）必须用真实值域长度 $\text{myright}[mid] - \text{myleft}[l] + 1$ 计算，而非段数 $mid-l+1$，因为不同段代表的真实长度不同（点段长度 1，间隙段长度可能上亿）。这是与基础模板唯一本质区别。

本模板还有一个关键优化：初始时位置 i 的值为 i（即序列为 1,2,...,n）。线段树只维护"操作带来的增量"（op=1 的区间加 k 的累计和），初始的等差数列和在查询时用等差求和公式 $\text{getsum}(l,r) = \frac{(l+r) \times (r-l+1)}{2}$ 现场计算。这样建树时无需初始化 tree（全 0 即可），查询结果 = $\text{getval}(\text{增量}) + \text{getsum}(\text{初始})$。这与基础模板中"叶子 `tree[rt]=l`"对应同一类问题，但离散化版本通过把初始和剥离出来，避免了在大值域上初始化。

四个操作的配合：init 读取所有操作，收集端点去重，构建 myleft/myright 段表并分配线段树数组；down 用真实段长度下传 lazy；insert（区间加）和 getval（查询增量）的边界判断都用 `myleft[l]/myright[r]` 而非 l/r；查询时主程序额外加上 getsum。由于段边界均由操作端点构成，任何 [ml,mr] 查询/修改都能精确分解为若干完整段，递归时大多命中"完全包含"或"不相交"分支。

## 数据结构图示

设 n=10，操作端点为 {3,7}。加入左右边界 0 与 n 后排序去重得 `dis={0,3,7,10}`。构建段：

```
段1: [0,0]    (点，左边界 0)
段2: [1,2]    (0与3之间的间隙，因为 0+1<3)
段3: [3,3]    (点)
段4: [4,6]    (3与7之间的间隙)
段5: [7,7]    (点)
段6: [8,9]    (7与10之间的间隙)
段7: [10,10]  (点)

myleft  = [_, 0, 1, 3, 4, 7, 8, 10]   (下标0为占位)
myright = [_, 0, 2, 3, 6, 7, 9, 10]
```

共 7 段，线段树建在 [1,7] 上（段编号），但每段真实长度不同：

```
              [段1..段7] rt=1
             /              \
      [段1..段4] rt=2      [段5..段7] rt=3
       /        \           /        \
   [段1,段2]  [段3,段4]  [段5,段6]  [段7,段7]
   rt=4       rt=5       rt=6       rt=7
    /    \      /    \       /    \
 段1    段2  段3    段4    段5    段6     段7
 真实    真实  真实   真实   真实   真实    真实
 [0,0]  [1,2] [3,3] [4,6]  [7,7] [8,9]   [10,10]
 长度1  长度2 长度1 长度3  长度1 长度2    长度1
```

down 下传示例：rt=2（段1..段4，真实范围 [0,6]，mid=段2 即真实 [1,2]）的 lazy=k 下传到 rt=4（段1,段2，真实 [0,2]）：

```
tree[4] += k * (myright[mid] - myleft[l] + 1)
         = k * (myright[2] - myleft[1] + 1) = k*(2-0+1) = 3k
         （若误用段数 k*(mid-l+1) = k*(2-1+1) = 2k，漏掉真实长度 1）

但对 rt=5（段3,段4，真实 [3,6]）：
tree[5] += k * (myright[r] - myleft[mid+1] + 1)
         = k * (myright[4] - myleft[3] + 1) = k*(6-3+1) = 4k
         （若误用 r-mid = 4-2 = 2，只得 2k，漏掉段4的真实长度3）
```

可见用段数代替真实长度会在间隙段上严重出错。

## 核心操作详解

### getsum(l, r)

- **作用**：计算初始等差数列 [l,r] 的和 = $\frac{(l+r)(r-l+1)}{2}$。
- **参数**：l,r 真实值域端点。
- **算法步骤**：直接套等差求和公式 $(\text{首项}+\text{末项}) \times \text{项数} / 2$。
- **关键细节**：用 `unsigned long long` 防止 $10^9$ 级别相乘溢出。这是"剥离初始值"的关键，使线段树只需维护增量，建树时 tree 全 0 即可。

### init(n, m)

- **作用**：读入所有操作，构建离散段表，分配线段树。
- **参数**：n 值域上界，m 操作数。
- **算法步骤**：(1) 收集端点 `dis={0,n}` 并加入每个操作的 l,r；(2) `sort`+`unique` 去重；(3) 遍历 dis，对每个点加一个长度 1 段 `[dis[i],dis[i]]`，若与下一点有间隙（`dis[i]+1 < dis[j]`）则加一个间隙段 `[dis[i]+1, dis[j]-1]`；(4) 按 cnt 用 `assign` 分配并清零 tree、lazy 为 `4*cnt+1`。
- **关键细节**：`myleft/myright[0]=(0,0)` 占位使段从下标 1 开始；dis 收集的左右边界是 0 与 n。cnt 即段数 sz，返回给主程序。

### down(i, l, r)

- **作用**：下传 lazy，用真实段长度。
- **参数**：i 节点，l,r 段区间。
- **算法步骤**：`lazy[i]==0` 或 `l==r` 返回；`mid=(l+r)/2`；左子真实长度 = $\text{myright}[mid] - \text{myleft}[l] + 1$，对左子执行 $\text{tree}[i \ll 1] \leftarrow \text{tree}[i \ll 1] + \text{lazy}[i] \times \text{左长度}$ 和 $\text{lazy}[i \ll 1] \leftarrow \text{lazy}[i \ll 1] + \text{lazy}[i]$；右子真实长度 = $\text{myright}[r] - \text{myleft}[mid+1] + 1$，同理；`lazy[i]=0`。
- **关键细节**：这是与基础模板唯一本质区别——长度用 $\text{myright}/\text{myleft}$ 而非下标差。左子覆盖段 [l,mid]，真实范围 $[\text{myleft}[l],\; \text{myright}[mid]]$；右子覆盖段 [mid+1,r]，真实范围 $[\text{myleft}[mid+1],\; \text{myright}[r]]$。

### insert(rt, l, r, ml, mr, k)

- **作用**：对真实值域 [ml,mr] 区间加 k。
- **参数**：rt,l,r 段节点，ml,mr 真实值域边界，k 增量。
- **算法步骤**：先 `down`；若 `myleft[l] > mr` 或 `myright[r] < ml`（真实值域不相交）返回；若 `ml<=myleft[l]` 且 `mr>=myright[r]`（真实值域完全包含）则执行以下更新后返回：

  $$\text{tree}[rt] \leftarrow \text{tree}[rt] + k \times (\text{myright}[r] - \text{myleft}[l] + 1)$$

  $$\text{lazy}[rt] \leftarrow \text{lazy}[rt] + k$$

  否则递归左右子并 pushup。
- **关键细节**：边界判断全部基于真实值域 myleft/myright，而非段编号 l/r。

### getval(rt, l, r, ml, mr)

- **作用**：查询真实值域 [ml,mr] 的增量和。
- **算法步骤**：先 `down`；不相交返回 0；完全包含返回 `tree[rt]`；否则递归左右子相加。
- **关键细节**：只返回增量，主程序需额外加 `getsum(ml,mr)` 得到完整答案。

## 逐行代码解析

代码按「模块」拆分：全局定义 → 构建段表 → lazy 下传 → 区间加/查询 → 主程序。各模块代码按顺序拼接后与 `codePath` 指向的 `.cpp` 完全一致（仅补充行尾 `//` 讲解注释）。

### 头文件、结构体与全局变量

```cpp
#include<bits/stdc++.h>
/*洛谷P13825*/
using namespace std;
struct T
{
	int op, l, r, k;
};
inline unsigned long long getsum(int l, int r)
{
	return ((unsigned long long)l + r) * ((unsigned long long)r - l + 1) / 2;
}
vector<unsigned long long> tree, lazy;
vector<T> A;
vector<int> myleft, myright;   // myleft[i]/myright[i]：第 i 段的真实左右端点
```

- `T` 记录一次操作：op 为操作类型（1=区间加，其余=查询），l/r 为值域边界，k 为增量。
- `getsum(l,r)` 用等差求和公式算初始序列 [l,r] 的和，`unsigned long long` 应对 $10^9$ 级值域相乘（可达 $10^{18}$）。
- `tree/lazy` 是线段树的节点值和懒标记；`myleft[i]/myright[i]` 是段表核心：第 i 段代表真实值域 [myleft[i], myright[i]]。

### init：读入 + 区间离散化构建段表

```cpp
int init(int n, int m)
{
	vector<int> dis;
	dis.reserve(2 * m + 2);
	A.assign(m + 1, {});
	dis.emplace_back(0);   // 收集 0 和 n 两个端点
	dis.emplace_back(n);
	for (int i = 1; i <= m; i++)
	{
		cin >> A[i].op;
		if (A[i].op == 1)
		{
			cin >> A[i].l >> A[i].r >> A[i].k;
			dis.emplace_back(A[i].l);
			dis.emplace_back(A[i].r);
		}
		else
		{
			cin >> A[i].l >> A[i].r;
			dis.emplace_back(A[i].l);
			dis.emplace_back(A[i].r);
		}
	}
	sort(dis.begin(), dis.end());
	dis.erase(unique(dis.begin(), dis.end()), dis.end());   // 去重

	int cnt = 0;
	if (!myleft.empty()) myleft.clear();   // 支持重复调用（多组数据），避免残留
	if (!myright.empty()) myright.clear();
	myleft.reserve(2 * dis.size() + 2);
	myright.reserve(2 * dis.size() + 2);
	myleft.emplace_back(0);   // 下标 0 占位，使段编号从 1 开始
	myright.emplace_back(0);
	for (int i = 0; i < dis.size(); i++)
	{
		int j = i + 1;
		myleft.emplace_back(dis[i]);      // 点段 [dis[i],dis[i]]
		myright.emplace_back(dis[i]);
		if (j < dis.size() && dis[i] + 1 < dis[j])   // 与下一点存在间隙
		{
			myleft.emplace_back(dis[i] + 1);         // 间隙段 [dis[i]+1, dis[j]-1]
			myright.emplace_back(dis[j] - 1);
			++cnt;
		}
		++cnt;
	}
	tree.assign(cnt * 4 + 1, 0);
	lazy.assign(cnt * 4 + 1, 0);
	return cnt;    // 返回段数
}
```

- 先离线读入全部操作存入 A，同时把 0、n 及所有操作端点收集到 dis；`sort`+`unique` 是标准离散化去重流程。
- 这是「区间离散化」的核心：对每个离散点建一个长度 1 的点段；若它与下一个点之间有间隙（`dis[i]+1 < dis[j]`），额外建一个间隙段覆盖整个连续空白，保证整个值域被段覆盖。
- `myleft/myright[0]=(0,0)` 占位使段编号从 1 起，与线段树节点编号对齐；`cnt` 即段数 sz，返回给主程序用于建树范围 [1, sz]。
- `dis.reserve`、`myleft/myright` 的 `clear`+`reserve`，以及 `A`/`tree`/`lazy` 改用 `assign`，都是为支持 init 被多次调用（多组数据）且不残留脏数据。
- 段数与操作数同阶，树数组按 `cnt*4+1` 分配并清零。

### down：lazy 下传（用真实段长度）

```cpp
void down(int i, int l, int r)
{
	if (lazy[i] == 0 || l == r) return;
	int mid = (l + r) >> 1;
	tree[i << 1] += lazy[i] * (myright[mid] - myleft[l] + 1);           // 左子真实长度
	lazy[i << 1] += lazy[i];
	tree[(i << 1) | 1] += lazy[i] * (myright[r] - myleft[mid + 1] + 1); // 右子真实长度
	lazy[(i << 1) | 1] += lazy[i];
	lazy[i] = 0;
}
```

- 无懒标记或叶子（`l==r`）直接返回；否则取 `mid=(l+r)>>1` 把 [l,r] 拆成左右两段区间。
- 与基础模板唯一本质区别：长度用真实值域端点差 `myright[mid]-myleft[l]+1`（左子）与 `myright[r]-myleft[mid+1]+1`（右子），而非段数 `mid-l+1`，否则间隙段的真实长度被忽略，结果严重错误。
- 左子覆盖段 [l,mid]，真实范围 [myleft[l], myright[mid]]；右子覆盖段 [mid+1,r]，真实范围 [myleft[mid+1], myright[r]]。

### insert / getval：区间加与查询增量

```cpp
void insert(int rt, int l, int r, int ml, int mr, int k)
{
	down(rt, l, r);
	if (myleft[l] > mr || myright[r] < ml) return;   // 真实值域不相交
	if (ml <= myleft[l] && mr >= myright[r])         // 真实值域完全包含
	{
		tree[rt] += (unsigned long long)k * (myright[r] - myleft[l] + 1);
		lazy[rt] += k;
		return;
	}
	int mid = (l + r) >> 1;
	insert(rt << 1, l, mid, ml, mr, k);
	insert((rt << 1) | 1, mid + 1, r, ml, mr, k);
	tree[rt] = tree[rt << 1] + tree[(rt << 1) | 1];   // pushup
}
unsigned long long getval(int rt, int l, int r, int ml, int mr)
{
	down(rt, l, r);
	if (myleft[l] > mr || myright[r] < ml) return 0;
	if (ml <= myleft[l] && mr >= myright[r]) return tree[rt];
	int mid = (l + r) >> 1;
	return getval(rt << 1, l, mid, ml, mr) + getval((rt << 1) | 1, mid + 1, r, ml, mr);
}
```

- 两者结构同基础模板：先 `down`，再按「不相交 / 完全包含 / 部分重叠」三分支处理。
- 所有边界比较都换成真实值域：`myleft[l] > mr` 判断段 l 的左端是否超过查询右界，`myright[r] < ml` 判断段 r 的右端是否小于查询左界。
- insert 完全包含时增量用真实长度 `(unsigned long long)k * (myright[r]-myleft[l]+1)`，并把 k 累加到 `lazy[rt]`；否则递归左右子后 pushup。
- getval 只返回「增量」，主程序需额外加 `getsum(ml,mr)` 得到完整答案。

### main：回放操作

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n, m;
	cin >> n >> m;
	int sz = init(n, m);
	for (int i = 1; i <= m; i++)
	{
		if (A[i].op == 1) insert(1, 1, sz, A[i].l, A[i].r, A[i].k);
		else cout << getval(1, 1, sz, A[i].l, A[i].r) + getsum(A[i].l, A[i].r) << '\n';   // 查询 = 增量 + 初始等差和
	}
	return 0;
}
```

- 先 `init` 得到段数 sz（建树范围为段区间 [1, sz]），再回放离线读入的操作。
- op=1 调 `insert` 做区间加；op=2（查询）输出 `getval(增量) + getsum(初始等差和)`。
- `getsum` 现场计算初始值之和，避免在大值域上初始化初始树；漏加 getsum 会只返回增量部分。

## 复杂度分析

- **预处理 init**：收集 $2m+2$ 个端点，排序去重 $O(m \log m)$；构建段表 $O(m)$；段数 cnt 至多 $2 \times (2m+2) \approx 4m$。
- **线段树空间** $O(4 \cdot \text{cnt}) = O(m)$。
- **insert / getval** 单次 $O(\log \text{cnt}) = O(\log m)$：树高 $O(\log m)$，每层至多 4 个节点。
- **总复杂度**：m 次操作 $O(m \log m)$，远优于对 [1,n] 直接建树的 $O(n)$。
- **对比**：当 $n=10^9$、$m=10^5$ 时，空间从 $4 \times 10^9$（不可行）降至 $4 \times 10^5$（可行），时间从 $O(n)$ 降至 $O(m \log m)$。

## 适用场景

适用于值域极大（$10^9$ 级别）但操作次数较少（$10^5$ 级别）的离线区间修改/查询问题。它是"离线 + 离散化"思想的典型应用：所有操作预先读入，根据端点构建紧凑的段表，再套用标准 lazy 线段树。若问题需要在线（操作不预先知道）或值域与操作数同阶，则无需离散化，直接用普通线段树即可。动态开点线段树（按需建节点）是处理大值域在线问题的另一种方案，但常数和空间通常不如离线离散化。

## 常见陷阱与注意事项

1. **必须用"区间离散化"而非"点离散化"**：只保留端点会丢失间隙区间的值，导致查询结果偏小。间隙段是本模板的灵魂。
2. **down / insert / getval 中的区间长度必须用 $\text{myright}-\text{myleft}+1$**，不能写成下标差 $mid-l+1$，否则间隙段的真实长度被忽略，结果严重错误。
3. **边界判断也要用真实值域**：`myleft[l] > mr` 而非 `l > mr`，因为段编号与真实值域不是一一线性映射。
4. **tree、lazy、getsum 要用 unsigned long long / long long**：间隙段长度可达 $10^9$，乘以 k 后可能达 $10^{18}$，超出 int 甚至需要警惕 long long 上限。
5. **myleft/myright[0] 占位使段从 1 开始**，下标与线段树节点编号对齐；忘记占位会导致段编号错位。
6. **查询结果要加 getsum（初始等差和）**：本模板只维护增量，漏加 getsum 会只返回增量部分。若初始序列不是等差数列，需相应替换 getsum。
7. **端点收集务必加入 0 和 n**：保证整个值域被段覆盖，否则边界段外的查询出错。

## 对比与扩展

- **与普通线段树对比**：离散化版用"段"代替"点"，下标含义从"位置"变为"段编号"，长度计算随之改变；但本质仍是同一棵 lazy 线段树，down/insert/getval 的骨架完全一致。
- **与动态开点线段树对比**：动态开点适合在线、随机访问的大值域，按需创建节点，空间 $O(q \log n)$；离线离散化空间 $O(m)$ 更紧凑，但需要预先知道所有操作。两者各有适用场景。
- **与树状数组+离散化对比**：BIT 也可离散化，但同样只能处理可差分操作；线段树可处理最值、双标记等更复杂情形。
- **扩展方向**：(1) 结合双标记（乘法+加法）处理大值域的乘加问题；(2) 二维离散化 + 二维线段树；(3) 离线询问的莫队算法可作为另一种大值域替代方案；(4) 将"段"思想用于扫描线、矩形面积并等问题。

### 保序离散化通用写法与变体

上文用的是针对本模板的「区间离散化」：`sort`+`unique` 之后还要补间隙段，以保留段长。而更通用的**保序离散化**只做「排序去重 + 二分定位」，把每个元素映射为它的排名（$1$ 起）：

```
sort(dis.begin(), dis.end());
dis.erase(unique(dis.begin(), dis.end()), dis.end());
int id(int x) { return lower_bound(dis.begin(), dis.end(), x) - dis.begin() + 1; }
```

这样 $x$ 被映射为它在有序数组中的排名，保留相对大小关系（保序），常用于权值线段树、树状数组、扫描线等只关心「谁大谁小」的场景。两种写法要分清：本模板的区间离散化保留段长与间隙，映射后仍能还原真实长度；保序离散化则只保留顺序、丢弃元素间的绝对距离。

- **哈希表离散化**：当元素无需保持顺序、或需频繁反向查值（由排名找回原值）时，可用 `unordered_map` 免去排序，建表 $O(n)$、查值 $O(1)$ 均摊；但需另存反向映射（`map[x]=id` 与 `val[id]=x`），且无法回答「第 k 小」这类依赖顺序的问题。
- **二维坐标分别离散化**：二维问题（矩形面积并、二维偏序等）通常对 $x$、$y$ 坐标**各自独立**离散化，得到两个排名后再套扫描线或二维线段树，而不是把 $(x,y)$ 当成整体编号。
- **使用边界（离散化会丢什么）**：离散化本质是丢弃「绝对数值」、只留「相对顺序」。凡依赖绝对值的运算都会出错：需要区间长度/面积/体积的题（须像本模板一样补段长）；需要「第 k 小」但中间有间隙的题（须配合段离散化或值域线段树）；以及相邻差、比例、距离等依赖原值本身的运算。一句话判断：**只关心顺序，离散化无损；关心数值本身，先想清楚丢失的信息如何补回。**$AKB179$, '数据结构', array['数据结构', '线段树', '离散化', '大值域'], 'col-hub-ds-segtree', null, 'knowledge'),
('Fohen', 'col-ds-segtree-dynamic--fenfeng', '动态开点线段树 · Fohen', $AKB180$## 算法原理

普通线段树通过 `rt<<1`、`rt<<1|1` 给左右儿子固定编号，因此必须在一开始就开好 $4n$ 大小的数组。当数组长度 $n$ 高达 $10^9$ 时，$4n$ 个节点本身就会把内存撑爆（MLE）。

然而这类问题的另一个关键约束是：虽然 $n$ 很大，但操作次数 $m$ 往往只有 $10^5$ 量级。也就是说，整棵线段树中绝大多数区间根本不会被访问到，真正"有意义"的区间只有 $O(m \log n)$ 个。动态开点的核心思想正是**按需建点**——不在建树时一次性开出全部节点，而是"访问到哪个区间，才创建哪个区间对应的节点"。

实现上，动态开点不再用 `u<<1` 推导儿子编号，而是：

1. 用一个计数器 `tot` 统一分配新节点编号；
2. 每个节点记录左右儿子的编号 `lc`、`rc`（初始为 `-1` 表示尚未创建）；
3. 递归进入某个儿子之前，先判断该儿子是否已创建，若没有就用 `build` 现场 `++tot` 建点并挂到父节点的 `lc`/`rc` 上。

由于每次操作沿树高下降，至多访问 $O(\log V)$ 个节点、新增 $O(\log V)$ 个节点，总节点数 $O(m \log V)$，远小于 $4n$。

本题的初始序列是 $a_i = i$（值域 $[1, V]$，其中 $V = \text{INF} = 10^9 + 10$），因此任意区间 $[l, r]$ 的初始和可直接由等差数列求和得到，动态开点时无需另存原数组——新建节点的初值在 `build` 时当场算出来即可。

## 核心公式 / 状态定义与转移方程

为叙述方便，下文用 $S_u$ 表示代码里的 `wh`（区间和），$A_u$ 表示 `addz`（加法懒标记），$L_u, R_u$ 表示 `l, r`（管辖区间端点），$lc_u, rc_u$ 表示 `lc, rc`（左右儿子编号）。

每个节点 $u$ 维护的状态：

- $L_u, R_u$：节点管辖的区间 $[L_u, R_u]$。
- $lc_u, rc_u$：左右儿子的节点编号，$-1$ 表示尚未创建。
- $S_u$：区间和。
- $A_u$：加法懒标记，表示该区间每个元素还需再加 $A_u$。

**pushup（fixtree）**：用儿子更新父亲。

$$S_u = S_{lc_u} + S_{rc_u}$$

**pushdown（banzai）**：把懒标记下传给儿子。令 $v$ 为 $lc_u$ 或 $rc_u$：

$$S_v \leftarrow S_v + A_u \times (R_v - L_v + 1)$$

$$A_v \leftarrow A_v + A_u$$

下传完成后 $A_u \leftarrow 0$。

**区间加（完全覆盖时）**：

$$S_u \leftarrow S_u + k \times (R_u - L_u + 1), \quad A_u \leftarrow A_u + k$$

**动态开点的初始值**：初始序列 $a_i = i$，新建节点 $[l, r]$ 的初始和为

$$\sum_{i=l}^{r} i = \frac{r(r+1)}{2} - \frac{(l-1)\,l}{2}$$

## 逐行代码解析

### 头文件与快读快写

```cpp
#include<bits/stdc++.h>
#define int unsigned long long
using namespace std;
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `#define int unsigned long long` 把 `int` 全部替换为 `unsigned long long`，应对值域 $10^9$ 下区间和可达 $10^{18}$ 量级的溢出风险；相应地 `main` 必须写成 `signed main`，否则会与 `int` 宏定义冲突。
- `read`/`write` 是手写快读快写，`(ch^48)` 把字符数字转成数值，`x=(x<<1)+(x<<3)` 等价于 `x*10`。
- 用 `getchar`/`putchar` 而非 `cin/cout`，避免大输入输出下超时。

### 常量与节点结构

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
```

- `INF = 1e9+10` 是值域上界；根区间为 $[1, \text{INF}]$，动态开点只需在值域内按需建点。
- `wcj[N]` 预开 $5 \times 10^6 + 10$ 个节点，对应 $m = 10^5$ 次操作、每次新增 $O(\log V)$ 个节点的上界。
- `l/r` 存节点管辖区间端点，`lc/rc` 存左右儿子编号（初始 `-1` 表示未创建），`wh` 存区间和，`addz` 存加法懒标记。

### fixtree 与 banzai（pushup / pushdown）

```cpp
	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=wcj[u].lc, rc=wcj[u].rc;//记录左右儿子的指针。由于动态开点，原来 u<<1,u<<1|1 的用法不再生效
        wcj[u].wh = wcj[lc].wh + wcj[rc].wh;
    }

	void banzai(int p){
		if(wcj[p].l==-1||wcj[p].r==-1) return;
		int lc=wcj[p].lc, rc=wcj[p].rc;
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

- `fixtree` 是 pushup：父亲的区间和 = 左右儿子区间和之和；`l==-1` 是空节点保护，避免递归到未创建节点时越界。
- `banzai` 是 pushdown：先算出左右儿子的区间长度 `lenL/lenR`，再按"懒标记 × 长度"把 `addz[p]` 累加到儿子，最后清零 `addz[p]`。
- 懒标记的增量必须是 $A \times \text{len}$ 而不是 $A$ 本身——懒标记表示"每个元素都要加"，区间和的增量要乘上元素个数。
- 下传前先判 `addz != 0`，避免无标记时做无谓的累加。

### init 与 build（初始化与动态建点）

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

- `init` 把根节点（编号 1）置为"空"，随后在 `main` 里立刻用 `build(1, INF, ...)` 把它改写成真正的根区间 $[1, \text{INF}]$。
- `build` 是动态开点的唯一入口：`++tot` 分配新编号，写入区间端点和初值，儿子指针置 `-1`，返回新节点编号供父节点挂接。
- 新建节点的初值 `x` 由"初始序列"决定，本题在调用处直接传入等差数列求和结果，无需读取原数组。

### plustree（区间加）

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

- 完全覆盖 `obl<=l && r<=obr` 时只更新 `wh += k×长度`、`addz += k` 后返回，不下传——这正是懒标记的核心，避免递归到叶子退化到 $O(n)$。
- 进入子节点前判 `lc/rc == -1`，若未创建则现场 `build`：左区间初值 `mid(mid+1)/2 - (l-1)l/2`、右区间初值 `r(r+1)/2 - mid(mid+1)/2`，即 $\sum_{i=l}^{mid} i$ 与 $\sum_{i=mid+1}^{r} i$。
- 递归前先 `banzai(u)` 把父亲的懒标记下传，保证子节点区间和正确；递归后 `fixtree(u)` 用儿子回传父亲。
- 新节点编号取自 `tot`（`build` 返回后 `tot` 已自增），挂到 `wcj[u].lc/rc` 上，取代固定编号 `u<<1`。

### findxigema 与 main（区间求和与主函数）

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
} lzx;

signed main(){
	int n,m;
	n=read(); m=read(); 
	lzx.init();
	lzx.build(1,INF,(INF*(INF+1)/2));
	while(m--){
		int c,x,y,k;
		c=read();
		if(c==1){
			x=read(); y=read(); k=read();
			lzx.plustree(1,1,INF,x,y,k);
		}else{
			x=read(); y=read();
			int ans = lzx.findxigema(1,1,INF,x,y);
			write(ans);
			putchar('\n');
		}
	}
    return 0; 
}
```

- `findxigema` 是区间求和：空节点返回 0，完全覆盖直接返回 `wh`，否则同样按需建点、下传懒标记后递归左右儿子并累加。
- 查询也要按需建点：因为懒标记可能停留在某个"半创建"节点上，只有保证结构完整才能正确下传。
- 根节点初值 `INF*(INF+1)/2` 即 $\sum_{i=1}^{\text{INF}} i$，对应初始序列 $a_i=i$。
- `c==1` 是区间加 `[x,y]+=k`，否则是区间求和 `[x,y]`；`n` 读入后未使用，值域由 `INF` 决定。

## 复杂度分析

- **时间**：每次区间加 / 区间求和都沿树高下降，深度为 $O(\log V)$（$V = \text{INF}$ 为值域大小）。每层常数时间，单次操作 $O(\log V)$；$m$ 次操作共 $O(m \log V)$。
- **空间**：每个操作至多新增 $O(\log V)$ 个节点（每层最多左右各建一个），总节点数 $O(m \log V)$；每个节点 $O(1)$，故空间 $O(m \log V)$。代码预开 `N = 5e6+10` 个节点的数组。
- **与普通线段树对比**：普通线段树需要 $O(V)$（约 $4V$）空间，在 $V = 10^9$ 时不可行；动态开点把空间压到与操作次数相关的 $O(m \log V)$。

## 适用场景

- 值域 / 下标范围极大（如 $10^9$）但有效操作点稀疏（如 $10^5$）的区间问题。
- 无法或不想预先离散化，或需要在原始值域上直接维护区间结构时。
- 作为可持久化线段树（主席树）、线段树合并、权值线段树等技巧的共同基础——它们都依赖"按需建点"。

## 常见陷阱与注意事项

1. 儿子编号从 `u<<1`/`u<<1|1` 换成 `lc/rc` 指针后，递归与 pushup/pushdown 都要用 `wcj[u].lc`、`wcj[u].rc`，不能再用移位公式（源码注释也专门强调）。
2. 访问子节点前必须判 `lc/rc == -1` 并按需 `build`，否则会读未初始化的节点，导致越界或错误答案。
3. 懒标记下传的增量要乘区间长度 $R_v - L_v + 1$，漏乘会让区间和少算。
4. 动态开点的初始值必须与"初始序列"一致：本题初始 $a_i=i$，初值用等差数列求和公式；换一道题初值不同，公式也要跟着换。
5. 数组要按 $O(m \log V)$ 预开足够大（本题 `5e6+10`），开小会越界。
6. `#define int unsigned long long` 之后 `main` 必须写 `signed main`，否则编译报错。

## 对比与扩展

- **与普通线段树**：普通线段树预开 $4n$、儿子编号固定、常数小，适合 $n$ 已知且不大；动态开点按需建点、常数略大，适合大值域稀疏数据。
- **与离散化线段树**：离散化把坐标压到 $O(m)$，空间更省，但需要先读入全部坐标离线处理；动态开点可在线处理、无需预处理，代价是常数略大（源码也提到这一点）。
- **扩展方向**：可持久化线段树（主席树）在动态开点基础上，每次修改只新建一条 $O(\log V)$ 的路径并保留历史版本；线段树合并利用动态开点的节点指针实现两棵树的合并；权值线段树把下标从"位置"换成"值"，同样依赖动态开点。$AKB180$, '数据结构', array['数据结构', '线段树', '动态开点', '大值域', '区间求和'], 'col-hub-ds-segtree', null, 'knowledge'),
('Xesir', 'col-ds-segtree-dynamic--xesir', '动态开点线段树 · Xesir', $AKB181$## 算法原理

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
- 查询里也会开点，所以一次查询之后节点数可能增加，估算空间时要把查询操作也算进去。$AKB181$, '数据结构', array['数据结构', '线段树', '动态开点', '大值域', '指针', '区间求和'], 'col-hub-ds-segtree', null, 'knowledge'),
('Xesir', 'col-ds-segtree-mul--xesir', '乘法线段树（区间加 + 区间乘 + 区间求和） · Xesir', $AKB182$## 算法原理

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
- 输入时把 `a[i]` 和修改的 `k` 都先对 `q` 取模，可以减少中间溢出的风险。$AKB182$, '数据结构', array['数据结构', '线段树', '区间乘法', '区间加法', '双标记', '懒标记'], 'col-hub-ds-segtree', null, 'knowledge'),
('world-needs-sunday', 'col-ds-segtree-mul', '乘法线段树（区间乘法+区间加法双标记 P3373）', $AKB183$## 算法原理

乘法线段树在普通线段树（区间加+区间求和）的基础上，额外支持"区间乘法"操作，对应洛谷 P3373。它仍采用二叉树结构与 lazy 延迟标记思想：根节点 rt=1 维护 [1,n]，节点 rt 的左子 `rt<<1` 维护 [l,mid]，右子 `(rt<<1)+1` 维护 [mid+1,r]。但由于同时存在乘法和加法两种修改，需要维护两个 lazy 标记：`mul_lazy`（乘法标记，初值 1）和 `sum_lazy`（加法标记，初值 0）。任意节点 rt 维护的值可形式化地看作 $\text{tree}[rt] = (\text{原始值} \times \text{mul\_lazy}[rt] + \text{sum\_lazy}[rt] \times \text{len}) \bmod m$，即"先乘后加"的复合变换。

两种标记必须按"先乘后加"的顺序复合，这是整个算法的核心。考虑一个已有标记 $(\text{mul},\; \text{sum})$（表示"先乘 mul 再加 $\text{sum} \times \text{len}$"）的节点，又收到一个新的乘法 k：新变换为 $(\text{原值} \times \text{mul} + \text{sum} \times \text{len}) \times k = \text{原值} \times (\text{mul} \times k) + (\text{sum} \times k) \times \text{len}$，因此新标记变为 $(\text{mul} \times k,\; \text{sum} \times k)$——即乘法标记和加法标记都要乘以 k。若收到的是新的加法 k：新变换为 $\text{原值} \times \text{mul} + \text{sum} \times \text{len} + k \times \text{len} = \text{原值} \times \text{mul} + (\text{sum}+k) \times \text{len}$，标记变为 $(\text{mul},\; \text{sum}+k)$——只有加法标记变化。这正是代码中 `add_mul` 要写 `sum_lazy[rt] = sum_lazy[rt]*k` 而 `add_sum` 不动 mul_lazy 的原因。

pushdown（my_down）的下传顺序同样必须"先乘后加"。设父节点标记为 $(M,\; S)$，下传给子节点（子节点原标记 $(m,\; s)$，原值 v，长度 len）。若先传乘法 M：子标记变为 $(m \times M,\; s \times M)$，值变为 $v \times M$。再传加法 S：子标记变为 $(m \times M,\; s \times M + S)$，值变为 $v \times M + S \times \text{len}$。最终子节点表示 $\text{原值} \times (m \times M) + (s \times M + S) \times \text{len}$，与"先应用父的乘 M 再应用父的加 S"语义一致。若顺序反过来先传加再传乘，加法标记会被错误地多乘一次 M，结果出错。

四个操作配合如下：建树读入数组并对 m 取模；my_down 在访问子节点前按"先乘后加"下传双标记；add_sum（区间加）和 add_mul（区间乘）在完全覆盖时分别只更新 sum_lazy 或同时更新 mul_lazy 与 sum_lazy；myget 查询前同样 my_down。所有运算都对 m 取模，防止溢出。注意 my_down 在 add_sum/add_mul/myget 中都在判断"完全包含/不相交"之前调用，保证子节点 tree 值是最新的。

## 数据结构图示

```
                 [1,8] rt=1   (mul=1, sum=0)
                /              \
        [1,4] rt=2            [5,8] rt=3
        /        \             /        \
   [1,2] rt=4  [3,4] rt=5  [5,6] rt=6  [7,8] rt=7
    /    \      /    \       /    \       /    \
 [1]rt=8 [2]rt=9 [3]rt=10 [4]rt=11 [5]rt=12 [6]rt=13 [7]rt=14 [8]rt=15
```

双标记下传示例：对 [1,8] 先区间乘 2，再区间加 3。根节点 rt=1 标记变为 `mul=2, sum=3`。下次访问子节点时 `my_down(1)`：

```
my_down(1):  先传 mul_lazy=2
  子 rt=2: mul_lazy[2] *= 2; tree[2] *= 2; sum_lazy[2] *= 2;
  子 rt=3: mul_lazy[3] *= 2; tree[3] *= 2; sum_lazy[3] *= 2;
  mul_lazy[1] = 1;
再传 sum_lazy=3
  子 rt=2: sum_lazy[2] += 3; tree[2] += 3*(mid-l+1);
  子 rt=3: sum_lazy[3] += 3; tree[3] += 3*(r-mid);
  sum_lazy[1] = 0;
```

关键：传乘法时 `sum_lazy` 也要乘 2，否则后续加法会少乘。数学上 $(v \times 2 + 0) \times 1 + 3 \times \text{len} = v \times 2 + 3 \times \text{len}$，等价于先乘 2 再加 3；若 sum_lazy 不乘，则变成 $v \times 2 + 0 + 3 \times \text{len}$ 对加法部分正确，但当子节点自身已有 sum_lazy 时就会出错。

## 核心操作详解

### init(rt, l, r, m, A) / init(n, m)

- **作用**：建树。叶子读 A[l]，内部节点为左右子和对 m 取模。
- **参数**：rt,l,r 节点与区间，m 模数，A 输入数组。
- **算法步骤**：`init(n,m)` 分配 tree(4n+1)、mul_lazy(4n+1,初值1)、sum_lazy(4n+1,初值0)；读入 A 并对 m 取模；调用 `init(1,1,n,m,A)` 递归建树，回溯时 $\text{tree}[rt] = (\text{tree}[\text{左}] + \text{tree}[\text{右}]) \bmod m$。
- **关键细节**：mul_lazy 必须初始化为 1（乘法单位元），sum_lazy 初始化为 0（加法单位元）。若 mul_lazy 初值为 0，所有值都会被乘成 0。

### my_down(rt, l, r, mid, m)

- **作用**：下传双标记，先乘后加。
- **参数**：rt 节点，l,r 区间，mid 中点，m 模数。
- **算法步骤**：若 `l==r` 返回。先下传乘法标记（若 `mul_lazy[rt]!=1`），对左右子 child 分别执行：
  - $\text{mul\_lazy}[\text{child}] \leftarrow \text{mul\_lazy}[rt] \times \text{mul\_lazy}[\text{child}] \bmod m$
  - $\text{tree}[\text{child}] \leftarrow \text{tree}[\text{child}] \times \text{mul\_lazy}[rt] \bmod m$
  - $\text{sum\_lazy}[\text{child}] \leftarrow \text{sum\_lazy}[\text{child}] \times \text{mul\_lazy}[rt] \bmod m$

  然后置 `mul_lazy[rt]=1`。再下传加法标记（若 `sum_lazy[rt]!=0`），对左右子分别执行：
  - $\text{sum\_lazy}[\text{child}] \leftarrow (\text{sum\_lazy}[rt] + \text{sum\_lazy}[\text{child}]) \bmod m$
  - $\text{tree}[\text{child}] \leftarrow (\text{tree}[\text{child}] + \text{sum\_lazy}[rt] \times \text{len}) \bmod m$

  然后置 `sum_lazy[rt]=0`。
- **关键细节**：len 对左子是 $mid-l+1$，右子是 $r-mid$。乘法标记同时作用于三个量（mul_lazy、tree、sum_lazy），缺一不可。

### add_sum(rt, l, r, ml, mr, m, k)

- **作用**：区间 [ml,mr] 每个元素加 k。
- **算法步骤**：不相交返回；先 `my_down`；若完全包含，执行以下更新后返回：

  $$\text{tree}[rt] \leftarrow (\text{tree}[rt] + k \times (r-l+1)) \bmod m$$

  $$\text{sum\_lazy}[rt] \leftarrow (\text{sum\_lazy}[rt] + k) \bmod m$$

  否则递归左右子并 pushup。
- **关键细节**：只更新 sum_lazy，不动 mul_lazy（加法不影响已有的乘法标记）。

### add_mul(rt, l, r, ml, mr, m, k)

- **作用**：区间 [ml,mr] 每个元素乘 k。
- **算法步骤**：不相交返回；先 `my_down`；若完全包含，执行以下三步更新后返回：

  $$\text{tree}[rt] \leftarrow \text{tree}[rt] \times k \bmod m$$

  $$\text{mul\_lazy}[rt] \leftarrow \text{mul\_lazy}[rt] \times k \bmod m$$

  $$\text{sum\_lazy}[rt] \leftarrow \text{sum\_lazy}[rt] \times k \bmod m$$

  否则递归左右子并 pushup。
- **关键细节**：sum_lazy 也要乘 k，这是最易错点。因为 $(\text{原值} \times \text{mul} + \text{sum} \times \text{len}) \times k = \text{原值} \times (\text{mul} \times k) + (\text{sum} \times k) \times \text{len}$。

### myget(rt, l, r, ml, mr, m)

- **作用**：查询区间 [ml,mr] 的和对 m 取模。
- **算法步骤**：不相交返回 0；`my_down`；完全包含返回 `tree[rt]`；否则递归左右子相加取模。
- **关键细节**：先 my_down 再判断完全包含，保证返回的 $\text{tree}[rt]$ 已应用所有历史标记。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h> 
using namespace std;
vector<long long> tree;
vector<long long> mul_lazy;   // 乘法标记，初值 1
vector<long long> sum_lazy;   // 加法标记，初值 0
```

- 三个全局数组分别存区间和（tree）、乘法标记（mul_lazy）、加法标记（sum_lazy），都用 long long 防止取模前的中间乘积溢出。
- mul_lazy 与 sum_lazy 的初值（1 和 0）由 init(n,m) 里 resize 设定，这里只声明。

### init（建树）

```cpp
void init(int rt,int l,int r,int m,const vector<long long>& A)
{
	if(l == r)
	{
		tree[rt] = A[l];        // 叶子读入初值
		return;
	}
	int mid = (l + r) >> 1;
	init(rt << 1,l,mid,m,A);
	init((rt << 1) + 1,mid + 1,r,m,A);
	tree[rt] = (tree[rt << 1] + tree[(rt << 1) + 1]) % m;  // pushup 取模
}
void init(int n,int m)
{
	vector<long long> A(n + 1);
	tree.resize(4 * n + 1);
	mul_lazy.resize(4 * n + 1 , 1);   // 乘法单位元 1
	sum_lazy.resize(4 * n + 1 , 0);   // 加法单位元 0
	for(int i = 1;i <= n;i++)
	{
		cin >> A[i];
		A[i] %= m;                    // 输入即取模
	}
	init(1,1,n,m,A);
}
```

- 两个 init 是重载：外层 `init(n,m)` 分配三个 4n+1 数组并读入 A，内层 `init(rt,l,r,m,A)` 递归建树、回溯时 pushup 取模。
- `mul_lazy.resize(4*n+1,1)` 是关键：乘法单位元为 1，写成 0 会导致全树归零；sum_lazy 的加法单位元为 0。
- 输入 A[i] 读入后立即 `%m`，避免后续运算溢出。

### my_down（标记下传）

```cpp
void my_down(int rt,int l,int r,int mid,int m)
{
	if(l == r) return;
	if(mul_lazy[rt] != 1)              // 有乘法标记：先下传
	{
		// 左子：mul、tree、sum 三者都乘以 mul_lazy[rt]
		mul_lazy[rt << 1] = (mul_lazy[rt] * mul_lazy[rt << 1]) % m;
		tree[rt << 1] = (tree[rt << 1] * mul_lazy[rt]) % m;
		sum_lazy[rt << 1] = (sum_lazy[rt << 1] * mul_lazy[rt]) % m;
		// 右子同理（(rt<<1)|1 等价于 (rt<<1)+1）
		mul_lazy[(rt << 1) | 1] = (mul_lazy[rt] * mul_lazy[(rt << 1) | 1]) % m;
		tree[(rt << 1) | 1] = (tree[(rt << 1) | 1] * mul_lazy[rt]) % m;
		sum_lazy[(rt << 1) | 1] = (sum_lazy[(rt << 1) | 1] * mul_lazy[rt]) % m;
		mul_lazy[rt] = 1;              // 清空为单位元
	}
	if(sum_lazy[rt] != 0)              // 有加法标记：后下传
	{
		// 左子：sum 累加，tree 加 sum*左子长度
		sum_lazy[rt << 1] = (sum_lazy[rt] + sum_lazy[rt << 1]) % m;
		tree[rt << 1] = (tree[rt << 1] + sum_lazy[rt] * (mid - l + 1)) % m;
		// 右子：长度为 r-mid
		sum_lazy[(rt << 1) | 1] = (sum_lazy[rt] + sum_lazy[(rt << 1) | 1]) % m;
		tree[(rt << 1) | 1] = (tree[(rt << 1) | 1] + sum_lazy[rt] * (r - mid)) % m;
		sum_lazy[rt] = 0;
	}
}
```

- 这是全模板最核心的函数：两个 if 块的顺序不可交换，必须先处理乘法标记，再处理加法标记。
- 乘法块中 `sum_lazy[child] *= mul_lazy[rt]` 是最易漏的一行——它把子节点原有的加法标记也按比例放大，因为后续的乘法应作用在"加法之前"。
- 左子长度为 `mid-l+1`，右子为 `r-mid`；`(rt<<1)|1` 等价于 `(rt<<1)+1`。

### add_sum / add_mul（区间加与区间乘）

```cpp
void add_sum(int rt,int l,int r,int ml,int mr,int m,long long k)
{
	if(r < ml || l > mr) return;
	int mid = (l + r) >> 1;
	my_down(rt,l,r,mid,m);                 // 先下传
	if(ml <= l && mr >= r)                 // 完全包含
	{
		tree[rt] = (tree[rt] + k * (r - l + 1)) % m;
		sum_lazy[rt] = (sum_lazy[rt] + k) % m;   // 只动加法标记
		return;
	}
	add_sum(rt << 1,l,mid,ml,mr,m,k);
	add_sum((rt << 1) | 1,mid + 1,r,ml,mr,m,k);
	tree[rt] = (tree[rt << 1] + tree[(rt << 1) | 1]) % m;  // pushup
}
void add_mul(int rt,int l,int r,int ml,int mr,int m,long long k)
{
	if(r < ml || l > mr) return;
	int mid = (l + r) >> 1;
	my_down(rt,l,r,mid,m);
	if(ml <= l && mr >= r)
	{
		tree[rt] = (tree[rt] * k) % m;
		mul_lazy[rt] = (mul_lazy[rt] * k) % m;
		sum_lazy[rt] = (sum_lazy[rt] * k) % m;   // 关键：加法标记也要乘
		return;
	}
	add_mul(rt << 1,l,mid,ml,mr,m,k);
	add_mul((rt << 1) | 1,mid + 1,r,ml,mr,m,k);
	tree[rt] = (tree[rt << 1] + tree[(rt << 1) | 1]) % m;
}
```

- 两者骨架相同："不相交直接返回 → 先 my_down → 完全包含就地更新并 return → 否则递归后 pushup"。
- add_sum 只改 `sum_lazy`（加法不影响已有乘法标记）；add_mul 同时改 `mul_lazy` 和 `sum_lazy`，其中 `sum_lazy[rt] *= k` 最易错。
- 区别原因：乘法会影响"已登记但未下传的加法"，而加法不会影响乘法。

### myget（区间查询）

```cpp
long long myget(int rt,int l,int r,int ml,int mr,int m)
{
	if(r < ml || l > mr) return 0;
	int mid = (l + r) >> 1;
	my_down(rt,l,r,mid,m);
	if(ml <= l && mr >= r) return tree[rt];
	return (myget(rt << 1,l,mid,ml,mr,m) + myget((rt << 1) | 1,mid + 1,r,ml,mr,m)) % m;
}
```

- 查询结构同普通线段树，区别仅在 my_down 多了 mid 和 m 参数。
- 先 my_down 再判断完全包含，保证返回的 tree[rt] 已应用所有历史标记。

### main（读入与操作分发）

```cpp
int main()
{
	int n,q;
	long long m;
	cin >> n >> q >> m;
	init(n,m);
	for(int i = 1;i <= q;i++)
	{
		int op;
		cin >> op;
		if(op == 1)          // 区间乘
		{
			int x,y;
			long long k;
			cin >> x >> y >> k;
			add_mul(1,1,n,x,y,m,k);
		}
		else if(op == 2)     // 区间加
		{
			int x,y;
			long long k;
			cin >> x >> y >> k;
			add_sum(1,1,n,x,y,m,k);
		}
		else                 // 区间查询
		{
			int x,y;
			cin >> x >> y;
			cout << myget(1,1,n,x,y,m) << '\n';
		}
	}
	return 0;
}
```

- 主程序根据 op 分发：op=1 区间乘、op=2 区间加、op=3 区间查询。
- 先读入 n、q 与模数 m 并建树，再逐条处理 q 个操作。

## 复杂度分析

- **建树** $O(n)$：每个节点访问一次。
- **add_sum / add_mul / myget** 单次 $O(\log n)$：树高 $O(\log n)$，每层至多 4 个节点。由于双标记，my_down 常数约为普通线段树的 2~3 倍，但渐进复杂度不变。
- **空间** $O(4n)$：tree、mul_lazy、sum_lazy 各 $4n+1$，共约 $12n$。
- **总复杂度**：q 次操作 $O((n + q) \log n)$。

## 适用场景

适用于同时需要区间乘法和区间加法的序列维护问题（洛谷 P3373）。它是理解"多标记 lazy 线段树"的典型例子，掌握"先乘后加"的复合规则后，可推广到更多标记组合（如区间赋值+区间加、历史最值等）。若题目只有单种区间操作，使用普通线段树或 BIT 即可，无需引入双标记的复杂性。

## 常见陷阱与注意事项

1. **mul_lazy 必须初始化为 1**（乘法单位元），写成 0 会导致所有值被乘成 0；sum_lazy 初始化为 0。
2. **my_down 必须先下传乘法标记再下传加法标记**，顺序反了会导致加法标记被多乘一次。
3. **乘法标记下传时必须同时作用于子节点的 mul_lazy、tree、sum_lazy 三个量**，漏掉 sum_lazy 是最常见错误。
4. **add_mul 中 `sum_lazy[rt] = sum_lazy[rt]*k` 不可省略**；add_sum 中不要误改 mul_lazy。
5. **所有运算都要对 m 取模**，且 k 读取后最好先取模，防止中间结果溢出 long long（当 m 接近 $10^9$ 时两数相乘可达 $10^{18}$，long long 仍可承载，但三数相乘需小心）。
6. **my_down 中判断 `mul_lazy[rt] != 1` 和 `sum_lazy[rt] != 0`** 是优化，避免无意义运算；但即使省略判断逻辑仍正确。

## 对比与扩展

- **与普通线段树对比**：双标记的难点在于标记的复合顺序，本质上是在维护一个仿射变换（affine transformation）$x \to a \cdot x + b$ 的复合。普通线段树只有加法，相当于 $a$ 恒为 $1$ 的退化情形。
- **与矩阵乘法线段树对比**：可将每个元素视为向量 $(值,\; 1)$，每次操作是 $2 \times 2$ 矩阵 $\begin{bmatrix} a & b \\ 0 & 1 \end{bmatrix}$，标记复合即矩阵乘法，能统一处理加、乘、赋值，但常数更大。乘法线段树可看作矩阵法的特例优化。
- **扩展方向**：(1) 区间赋值标记（需额外 bool 区分是否赋值，赋值优先级最高）；(2) 历史最值线段树（维护历史最大/最小，需额外历史标记）；(3) 多项式标记推广到更高次；(4) 结合离散化处理大值域（见 ds-segtree-discretize）。$AKB183$, '数据结构', array['数据结构', '线段树', '区间乘法', '区间加法', '双标记', 'P3373'], 'col-hub-ds-segtree', null, 'knowledge'),
('Fohen', 'col-ds-segtree-weight--fenfeng', '权值线段树 · Fohen', $AKB184$## 算法原理

普通线段树以「数组下标（位置）」作为线段树的下标：叶子节点保存该位置上的具体数值，内部节点维护区间内的最大值、和等聚合信息。权值线段树则把下标换成「值域」（即数值的取值范围）：叶子节点对应一个具体的数值，保存「这个数值在数组中出现了多少次」，内部节点保存它所管辖的值域区间内所有数字出现次数的总和。

以数组 $a = [3, 1, 4, 1, 5, 9]$、值域 $1 \sim 9$ 为例：先统计频次，$1$ 出现 $2$ 次、$3$ 出现 $1$ 次、$4$ 出现 $1$ 次、$5$ 出现 $1$ 次、$9$ 出现 $1$ 次。于是权值线段树的叶子节点 $1$ 存 $2$，叶子 $3$、$4$、$5$、$9$ 各存 $1$，没有出现的值（如 $2$、$6$）存 $0$。

这样建树的动机在于：很多与「数值大小」有关的全局统计，本质都是「数一数值域某个区间里有多少个数」。线段树把值域二分，天然支持快速回答这类计数；而「全局第 $k$ 小」又恰好可以通过「比较左半值域的计数与 $k$ 的大小」在树上二分定位。具体做法是从根出发：看左子树的计数值 $sum$，若它大于等于 $k$，说明第 $k$ 小落在值域较小的一半里，往左递归；否则第 $k$ 小在右半值域，此时把 $k$ 减去左半计数再往右递归；走到叶子时，叶子对应的值就是答案。单次查询的时间复杂度为 $O(\log V)$，其中 $V$ 是值域大小。

## 核心公式 / 状态定义与转移方程

设离散化后的值域为 $[1, n]$（$n$ 为不同数值的个数）。用 $sum[u]$ 表示节点 $u$ 管辖的值域区间 $[l, r]$ 内所有元素出现次数的总和；叶子节点的 $sum$ 即该数值的出现次数。

- **节点计数合并（pushup）**：节点计数等于左右子树计数之和

  $$sum[u] = sum[2u] + sum[2u + 1]$$

- **插入（单点更新）**：对数值 $pos$ 的出现次数加 $1$，沿根到叶子的路径对每个经过的节点执行 $sum[u] \leftarrow sum[u] + 1$。

- **查询值 $x$ 的排名**：排名等于「比 $x$ 小的元素个数再加 $1$」，即值域区间 $[1, x-1]$ 的计数和加 $1$

  $$\text{rank}(x) = \left( \sum_{v < x} cnt[v] \right) + 1$$

- **查询全局第 $k$ 小**：设当前节点左子树计数为 $sum[2u]$。若 $sum[2u] \ge k$，则第 $k$ 小在左子树；否则令 $k \leftarrow k - sum[2u]$ 后进入右子树。

## 逐行代码解析

> 本知识点来源资料未提供完整可运行的实现代码，以下为权值线段树核心操作的伪代码说明。

### 结构定义与全局数组

```cpp
// sum[u]：节点 u 管辖值域区间内元素出现次数的总和
// 离散化后值域压缩为 [1, n]
sum[1..4n]          // 节点计数数组，开 4n 避免越界
val[1..n]           // 离散化位置 -> 原数值的映射（查询时反查答案）
```

- `sum` 是线段树的节点数组：叶子 `sum[pos]` 即数值 `pos` 的出现次数，内部节点为左右子节点计数之和。
- `val` 保存离散化位置与原数值的对应关系：树上二分找到的只是离散化位置，必须经 `val` 映射回原始数值再输出。
- 计数数组开 $4n$ 而非 $2n$：当 $n$ 不是 $2$ 的幂时，按完全二叉树编号的最大下标会接近 $4n$。

### 插入（单点 +1）

```cpp
insert(pos):                       // 把离散化位置 pos 的出现次数 +1
    update(1, 1, n, pos, 1)

update(u, l, r, pos, delta):
    sum[u] = sum[u] + delta        // 沿途每个节点计数都累加 delta
    if l == r: return              // 到达叶子，结束
    mid = (l + r) / 2
    if pos <= mid:
        update(左儿子, l, mid, pos, delta)
    else:
        update(右儿子, mid+1, r, pos, delta)
```

- 插入本质是「单点加 $1$」：从根走到 `pos` 所在的叶子，路径上每个节点的 `sum` 都加 $1$，表示管辖区间内多了一个数。
- 单点更新的复杂度等于树高 $O(\log n)$，这是权值线段树支持高频插入的前提。
- 若需要「删除一个数」或「给某个值加多次」，只需把 `delta` 换成 $-1$ 或对应增量，框架不变。

### 查询全局第 k 小（树上二分）

```cpp
kth(u, l, r, k):                    // 在值域 [l, r] 内找第 k 小
    if l == r: return l              // 叶子：该值即答案
    mid = (l + r) / 2
    if sum[左儿子] >= k:             // 左半值域已有至少 k 个数
        return kth(左儿子, l, mid, k)
    else:
        return kth(右儿子, mid+1, r, k - sum[左儿子])   // k 减掉左半计数
```

- 核心是「看左子树计数」：左子树 `sum` 表示值域较小一半里有多少个数，用它与 $k$ 比较即可判断第 $k$ 小落在哪一半。
- 进入右子树前必须执行 $k \leftarrow k - sum[\text{左儿子}]$：右子树内的第 $k$ 小相对右半值域要去掉左半已经占用的名额，漏减会定位错误。
- 整个过程沿一条根到叶的路径下降，单次 $O(\log n)$；求第 $k$ 大同理，只需把「左子树」换成「右子树」、比较关系取反。

### 查询值的排名

```cpp
rank(x):                            // 值 x 的排名 = 比 x 小的元素个数 + 1
    return query(1, 1, n, 1, x-1) + 1

query(u, l, r, ql, qr):             // 统计值域区间 [ql, qr] 内的元素总数
    if ql <= l and r <= qr: return sum[u]        // 完全覆盖
    mid = (l + r) / 2
    res = 0
    if ql <= mid: res += query(左儿子, l, mid, ql, qr)
    if qr >  mid: res += query(右儿子, mid+1, r, ql, qr)
    return res
```

- 排名即「小于 $x$ 的元素个数再加 $1$」，对应查询值域区间 $[1, x-1]$ 的计数和，再整体加 $1$。
- `query` 是标准的区间计数：完全覆盖直接返回 `sum[u]`，部分相交则递归左右子并相加。
- 若要判定「某值出现次数是否超过总数一半（众数判定）」，只需比较 `query(1, 1, n, x, x)` 与总元素数的一半即可。

## 复杂度分析

- **插入（单点更新）**：沿树高 $O(\log V)$ 的路径每层 $O(1)$，单次 $O(\log V)$；离散化后值域为 $n$，即 $O(\log n)$。
- **查询第 $k$ 小 / 查询排名**：同样是沿一条根到叶的路径或做一次区间计数，单次 $O(\log V)$。
- **建树**：若按值域直接建树为 $O(V)$；若逐元素插入建树，$n$ 个元素每个 $O(\log V)$，总 $O(n \log V)$。
- **空间**：`sum` 数组开 $4V$，即 $O(V)$；离散化后为 $O(4n) = O(n)$。若采用动态开点，空间按实际访问到的节点数计，约为 $O(n \log V)$。

## 适用场景

- 查询整个数组的**全局第 $k$ 小 / 第 $k$ 大**：这是权值线段树最直接的应用，在树上二分即可。
- 查询某个值 $x$ 在数组中的**排名**（小于 $x$ 的元素个数再加 $1$）。
- 判定数组中是否存在**出现次数超过一半的众数**。
- 值域可离散化、只需「按数值统计」的离线统计问题。
- 当只有单点计数与前缀排名需求时，权值树状数组代码更短、常数更小，是更轻量的替代；但当核心操作是「树上二分找第 $k$ 小」时，权值线段树的结构更直观。

## 常见陷阱与注意事项

1. **必须先离散化**：原始值域可能达 $10^9$，直接按值域开数组会爆内存；离散化把值域压缩到 $n$ 后空间才是 $O(n)$。
2. **结果要映射回原值**：树上二分找到的是离散化位置 `pos`，输出前必须经 `val[pos]` 还原成原始数值，否则返回的是下标而非答案。
3. **右子树递归前必须执行 `k -= sum[left]`**：漏掉这一步会把「右半值域里的排名」当成「全局排名」，导致答案偏大。
4. **叶子存的是「次数」而非「数值」**：这是权值线段树与普通线段树的本质区别，多个相同元素在叶子处合并为一个计数。
5. **`sum` 可能溢出 int**：当 $n$ 很大时计数总和可达 $n$，若还需累加更多操作，用 `long long` 更安全。
6. **动态开点常数更大**：不想离散化或值域稀疏时可用动态开点，写起来更灵活但常数略大，常规题优先离散化。

## 对比与扩展

- **与普通线段树对比**：普通线段树下标是「数组位置」，叶子存该位置的数值；权值线段树下标是「值域」，叶子存该数值的出现次数，回答的是全局计数与排名类问题。
- **与权值树状数组（BIT）对比**：两者都维护值域频次，BIT 代码更短；但权值线段树把「树上二分」写得直观，更适合教学与扩展。
- **与平衡树对比**：平衡树支持动态插入删除并在线回答第 $k$ 小；权值线段树偏静态（或需配合可持久化），且值域需可离散化。
- **扩展方向**：可持久化权值线段树即**主席树**，用于静态区间第 $k$ 小（参见 ds-persistent-segtree-template）；动态开点权值线段树处理超大稀疏值域；线段树合并用于树上权值统计。离散化细节参见 ds-segtree-discretize。$AKB184$, '数据结构', array['数据结构', '线段树', '权值线段树', '第k小', '离散化'], 'col-hub-ds-segtree', null, 'knowledge'),
('Xesir', 'col-ds-segtree-weight--xesir', '权值线段树 · Xesir', $AKB185$## 算法原理

### 本质：下标从「位置」变成「值」

普通线段树的下标是数组的位置（比如 `a[1]`、`a[2]`），叶子节点存的是该位置上的具体数值，内部节点维护的是区间内的最大值、和或其它信息。

**权值线段树**则反过来：它的下标是**值域**（即数值的取值范围），叶子节点存储的是「这个数值在数组中出现了多少次」，内部节点存储的是它所管辖的值域区间内所有数字出现的总次数。

举个例子，对于数组 `a = [3, 1, 4, 1, 5, 9]`：

- 统计频次：`1` 出现 $2$ 次，`3` 出现 $1$ 次，`4` 出现 $1$ 次，`5` 出现 $1$ 次，`9` 出现 $1$ 次。
- 权值线段树的叶子节点（假设值域 $1\sim 9$）中：节点 `1` 存 $2$，节点 `3` 存 $1$，节点 `4` 存 $1$……没有出现的值（如 `2`、`6`）存 $0$。

### 能做什么（全局统计）

权值线段树最擅长的就是解决**全局排名统计**类问题，比如：

- 查询整个数组的第 $k$ 小（或第 $k$ 大）元素。
- 查询某个值 $x$ 在数组中的排名（即小于 $x$ 的元素个数加 $1$）。
- 查询数组中是否有超过一半次数的众数。

注意它维护的是「一个集合」的频次，所以天然只能回答**全局**问题；要查任意子区间 $[l,r]$ 的第 $k$ 小，需要可持久化版本（主席树）或树套树。

## 核心公式 / 状态定义

设值域为 $[1,V]$，节点 $u$ 管辖 $[l,r]$，定义

$$
\text{sum}[u]=\#\{i\mid l\le a_i\le r\}
$$

即落在该值域区间内的元素个数。查询第 $k$ 小时，从根出发比较左子树的计数：

$$
\text{left\_sum}=\text{sum}[\text{lc}(u)]
$$

- 若 $k\le \text{left\_sum}$，往左子树走；
- 否则往右子树走，并令 $k\leftarrow k-\text{left\_sum}$。

## 逐行代码解析

原文这一节只讲思想，没有配套完整程序，这里给出两个最核心的片段（完整实现由你自己写）。

### 模块一：插入（单点更新）

对于数组中的每个数 `x`，找到它离散化后的位置 `pos`，在权值线段树上对 `pos` 进行单点加 $1$（表示这个值出现了一次）。更新时沿路径修改节点的 `sum` 值。

```cpp
void insert(int u, int l, int r, int pos) {
    sum[u] ++;                       // 这个值域区间多了一个数
    if (l == r) return;              // 叶子：频次 +1 完毕
    int mid = (l + r) >> 1;
    if (pos <= mid) insert(lc[u], l, mid, pos);
    else insert(rc[u], mid + 1, r, pos);
}
```

`sum[u]` 在进入节点时就加一，所以从根到叶子的整条路径都会被更新；叶子节点的 `sum` 就是该值的出现次数。

### 模块二：查询全局第 $k$ 小

算法就是在线段树上进行二分（从根出发）：

1. 看左子树的 `sum`（即值域较小的一半里有多少个数）。
2. 若 `left_sum >= k`，说明第 $k$ 小在左子树，往左递归。
3. 否则，说明第 $k$ 小在右子树，往右递归，并将 `k` 减去 `left_sum`。
4. 走到叶子节点时，该叶子对应的值就是答案。

```cpp
int kth(int u, int l, int r, int k) {
    if (l == r) return l;            // 叶子即答案（离散化后的值）
    int mid = (l + r) >> 1;
    int left_sum = sum[lc[u]];
    if (k <= left_sum) return kth(lc[u], l, mid, k);
    else return kth(rc[u], mid + 1, r, k - left_sum);
}
```

单次查询时间复杂度为 $O(\log V)$，其中 $V$ 是值域大小。返回的是离散化后的下标，最后还要映射回原值。

### 模块三：离散化（必要步骤）

实际数据中的值域可能很大（如 $10^9$），不可能开这么大的数组。通用的做法是**离散化**：把原数组排序去重，用 `lower_bound` 把每个数换成它在去重数组中的名次。这样值域就被压缩到了 $m$（不同数的个数），线段树的空间只需 $O(m)$。

插入时用的是名次，查询第 $k$ 小得到的是名次，最后用 `b[pos]` 还原成原值。

**动态开点（选学优化）**：如果不想预先离散化，或者值域虽大但数据稀疏，可以采用动态开点。这种方式写起来灵活，但常数略大。

## 复杂度分析

- 插入一个数：从根走到对应的值域叶子，$O(\log V)$。
- 查询全局第 $k$ 小：同样只走一条路径，$O(\log V)$。
- 查询排名：本质是统计「小于 $x$ 的数的个数」，沿值域走一遍，$O(\log V)$。
- 空间：静态开点是 $O(V)$；离散化后值域压到 $m$，空间 $O(m)$；动态开点则是 $O(m\log V)$ 个节点。

## 适用场景

- 只需要维护**全局**频次：全局第 $k$ 小、全局排名、全局众数。
- 值域可以离散化，或者值域本身不大。
- 作为主席树、树套树、线段树合并等结构的组成部分——权值线段树是它们的基础。
- 需要「动态维护一个集合，支持插入删除、查第 $k$ 小」时，权值线段树（或树状数组 + 二分、平衡树）都可以；权值线段树的优势是常数稳定、易于合并。

## 常见陷阱与注意事项

- 叶子节点代表的是**值**，不是数组位置；这是权值线段树与普通线段树最根本的区别。
- 权值线段树只能回答全局问题。想查区间 $[l,r]$ 的第 $k$ 小，必须用可持久化权值线段树（主席树）做版本相减，或者树套树。
- 查询第 $k$ 小前要保证 $1\le k\le$ 元素总数，否则会走到空节点或死递归。
- 重复元素靠 `sum` 计数，不能先去重再建树，否则频次信息就丢了。
- 离散化后查询返回的是名次，别忘了映射回原值。
- 静态开点要按值域大小开够；动态开点则要按「插入次数 $\times\log V$」估算节点池。$AKB185$, '数据结构', array['数据结构', '线段树', '权值线段树', '第k小', '排名', '离散化'], 'col-hub-ds-segtree', null, 'knowledge'),
('world-needs-sunday', 'col-ds-splay', 'Splay树（伸展树）', $AKB186$## 算法原理

Splay树是一种自平衡二叉搜索树（BST），其核心思想是"局部性"（access locality）：最近被访问的节点很可能在不久后再次被访问。因此Splay在每次查找、插入、删除操作之后，都会通过"伸展"操作（splay）将刚刚操作的节点旋转到根的位置。BST性质要求左子树所有值小于根、右子树所有值大于根；splay操作在保持BST性质的前提下，通过一系列旋转把目标节点提升到根，同时缩短沿途路径。由于频繁访问的节点被"拉"到靠近根的位置，后续访问的成本就会降低。

单纯使用单旋（rot）将节点逐层上移会导致严重的退化问题。考虑一条向右倾斜的链状BST，若每次都从最深处节点单旋到根，树的结构几乎不变（仅相当于把链整体翻转），访问复杂度退化为 $O(n)$。Sleator和Tarjan在原始论文中证明：当目标节点x与其父y、祖父z呈"同向"（zig-zig，即x和y同为左孩子或同为右孩子）时，如果直接单旋x，树的形状几乎不变；正确的做法是"先旋父y再旋x"（从上往下旋），这样能将路径长度大致减半。而当x与y呈"异向"（zig-zag，即x是左孩子而y是右孩子，或反之）时，需要"先旋x再旋x"（即标准的双旋，类似于AVL树中的LR/RL旋转）。

具体而言，splay函数中的双旋判定为 $$(\text{tree}[y].\text{son}[0] == x) \oplus (\text{tree}[z].\text{son}[0] == y)$$：当异或结果为真（x和y处于不同方向，即zig-zag）时先调用 `rot(x)`；当异或结果为假（x和y处于同方向，即zig-zig）时先调用 `rot(y)`。无论哪种情况，最后都会再执行一次 `rot(x)`。这种"先旋父再旋自己"的同向双旋策略是防止链退化的关键，也是Splay与朴素单旋BST的根本区别。

Splay的均摊 $O(\log n)$ 复杂度基于势能函数（potential function）分析。定义势能 $\Phi(T) = \sum_u \log_2(\text{size}(u))$，其中 size(u) 为节点u的子树大小（含自身），$\log_2(\text{size}(u))$ 称为节点u的"秩"（rank）。Splay定理（Access Lemma）证明：将节点x伸展到根的均摊代价至多为 $3(r'(x) - r(x)) + 1$，其中r(x)是伸展前x的秩，r'(x)是伸展后的秩（此时x为根，$r'(x) = r(T)$即整棵树的秩）。由于 $r'(x) = r(T)$ 是固定上界，一串操作中秩的变化求和后大量项相互抵消（telescoping），总均摊代价为 $O(n \cdot \log n + m \cdot \log n)$，即每次操作均摊 $O(\log n)$。此外，哨兵节点（-INF和+INF）在初始化时插入，保证前驱/后继查找不会越界：任何元素的前驱至少是-INF，后继至少是+INF，从而 `get_pre` 和 `get_suc` 始终能返回有效的节点下标。

## 数据结构图示

```
单旋 rot(x) 示意 (此处展示右旋, 即 x 是 y 的左孩子 k=0):

  旋转前 (右旋):            旋转后:
        y                      x
       / \                    / \
      x   C      -->         A   y
     / \                        / \
    A   B                      B   C

  k = (tree[y].son[1] == x) = 0  (x 是左孩子)
  tree[y].son[0] = tree[x].son[1]   (B 变为 y 的左孩子)
  tree[x].son[1] = y                (y 变为 x 的右孩子)
  tree[z].son[...] = x             (x 接替 y 在 z 中的位置)


双旋策略 (splay):

  zig-zig (同向, x和y都是左孩子):
    旋转前:        先旋y:         再旋x:
        z             z              x
       /             /                \
      y             x                  z
       \             \                /
        x             y              y
                       \            /
                        (子树)    (子树)

  zig-zag (异向, x是左孩子, y是右孩子):
    旋转前:        先旋x:         再旋x:
        z             z              x
         \             \            / \
          y             x          z   y
         /               \
        x                 y

  判定: (tree[y].son[0]==x) ^ (tree[z].son[0]==y)
    结果为 true  -> 异向 (zig-zag) -> 先 rot(x)
    结果为 false -> 同向 (zig-zig) -> 先 rot(y)
```

## 核心操作详解

**upsz(x)**：更新节点x的子树大小。$\text{sz} = \text{sz}_{\text{左子树}} + \text{sz}_{\text{右子树}} + \text{cnt}$。其中cnt是该值的出现次数（允许重复元素）。注意tree[0]代表空节点，其sz必须为0，这样空子树贡献为0。

**rot(x)**：单旋，将x上移一层、y下移一层。通过 $k = (\text{tree}[y].\text{son}[1] == x)$ 判断x是y的哪个孩子：k=1表示x是右孩子（需左旋），k=0表示x是左孩子（需右旋）。$k \oplus 1$ 则给出另一个方向。x的内侧子树（靠近y的那棵）被移交给给y，y成为x的孩子，x接替y在z中的位置。旋转后调用 upsz(y)、upsz(x) 更新大小。

**splay(x, k)**：将x旋转到k的下方（k=0时到根）。循环条件 $\text{tree}[x].\text{fa} \neq k$。若有祖父z且z≠k，则用异或判定同向/异向决定先旋谁。最后必定执行一次 rot(x)。若k==0则更新全局root。

**find(v)**：从root出发沿BST性质向下走，$\text{tree}[x].\text{son}[v > \text{tree}[x].\text{val}]$ 利用比较结果直接作为方向索引（0=左，1=右）。走到值为v的节点或走到底为止，然后splay到根。find之后root要么是v本身，要么是离v最近的节点。

**get_pre(v) / get_suc(v)**：前驱/后继。先find(v)把v或最近节点旋到根。若root的值已经小于v则root即前驱；否则进入左子树一直往右走到底（左子树中的最大值）。后继对称。哨兵-INF保证最小元素也有前驱。

**del(v)**：经典删除。先取pre=get_pre(v)、suc=get_suc(v)，然后 `splay(pre,0); splay(suc,pre)`。此时pre为根、suc为pre的右孩子。由于 $\text{pre} < v < \text{suc}$ 且v唯一，v必定是suc的左孩子（$\text{tree}[\text{suc}].\text{son}[0]$）。若 $\text{cnt} > 1$ 则减少计数，否则直接将suc的左孩子置空。最后splay保持局部性。

**getrk(v)**：排名查询。find(v)后，若 $\text{root.val} < v$（v不在树中，root是最大的<v的节点），则排名 $= \text{sz}_{\text{左子树}} + \text{root.cnt}$（所有 $\leq$ root 的元素个数=v之前元素个数）；若 $\text{root.val} \geq v$（v在树中），则排名 $= \text{sz}_{\text{左子树}}$（严格小于v的元素个数）。

**getval(k)**：第k小查询。`k+=1` 跳过-INF哨兵。沿树下行：若 $\text{sz}_{\text{左子树}} + \text{cnt} < k$，说明答案在右子树，k减去 $\text{sz}_{\text{左子树}} + \text{cnt}$ 后向右走；若 $\text{sz}_{\text{左子树}} \geq k$，说明答案在左子树，向左走；否则当前节点即为答案。最后splay到根。

**insert(v)**：从root向下搜索v。若找到则cnt++；否则新建节点，挂到p的对应方向。无论哪种情况最后都splay(x,0)把新插入或已存在节点旋到根。

## 逐行代码解析

### 模块一 · 头文件与结构体定义

```cpp
#include<bits/stdc++.h> 
using namespace std;
struct sytree
{
	int fa;        // 父节点下标
	int son[2];    // son[0]=左孩子, son[1]=右孩子
	int val;       // 节点存储的值
	int sz;        // 子树大小 (含自身, 含重复计数)
	int cnt;       // 该值的出现次数
	sytree(int a)  // 构造函数
	{
		son[0] = 0; son[1] = 0;
		val = a;
		cnt = 1;
		fa = 0;
		sz = 1;
	}
};
vector<sytree> tree;  // tree[0] 是哨兵空节点, 必须保证 sz=0, cnt=0
int root = 0;         // 全局根节点下标, 0表示空树
```

- 结构体存 `fa / son[2] / val / sz / cnt` 五个字段：父节点、左右孩子、值、子树大小、同值计数；构造函数把单节点初始化为 `son=0, fa=0, cnt=1, sz=1`。
- `tree` 是动态 vector，下标即节点编号；`tree[0]` 是空哨兵节点，其 `sz`、`cnt` 必须为 0，否则 `upsz` 访问空子树时会把空节点当成大小为 1 的节点而算错。
- `root=0` 表示空树，真实节点从下标 1 开始，0 号位永远不存真实数据。

### 模块二 · upsz 与 rot（维护大小 + 单旋）

```cpp
inline void upsz(int x)//修改大小 
{
	// 子树大小 = 左子树 + 右子树 + 自身重复次数
	// tree[0].sz 必须为0, 否则空子树会贡献错误值
	tree[x].sz = tree[tree[x].son[0]].sz + tree[tree[x].son[1]].sz + tree[x].cnt;
}
void rot(int x) //旋转 
{
	int y = tree[x].fa;         // y 是 x 的父节点
	int z = tree[y].fa;         // z 是 y 的父节点 (x 的祖父)
	int k = tree[y].son[1] == x; // k=1: x是右孩子(左旋); k=0: x是左孩子(右旋)
	// x 的内侧子树移交给 y
	tree[y].son[k] = tree[x].son[k ^ 1];   // y的k方向孩子 = x的(k^1)方向孩子
	tree[tree[y].son[k]].fa = y;          // 更新该子树的父指针
	// y 下移成为 x 的孩子
	tree[x].son[k ^ 1] = y;               // x 的 (k^1) 方向孩子 = y
	tree[y].fa = x;                        // y 的父 = x
	// x 接替 y 在 z 中的位置
	tree[z].son[tree[z].son[1] == y] = x; // z 中原来指向 y 的位置改为指向 x
	tree[x].fa = z;                        // x 的父 = z
	upsz(y), upsz(x);                     // 先更新下层 y, 再更新上层 x
}
```

- `upsz` 用 `左子树sz + 右子树sz + cnt` 重算节点大小；`tree[0].sz` 必须是 0，空子树才贡献 0。
- `k = (tree[y].son[1] == x)` 判定 x 是左还是右孩子（k=1 右孩子→左旋，k=0 左孩子→右旋），`k^1` 取反方向。
- 旋转分三步：x 的内侧子树移交给 y、y 下移成为 x 的孩子、x 接替 y 在祖父 z 中的位置，每步都同步维护 `fa` 指针。
- `upsz(y), upsz(x)` 顺序不能反：先更新下层的 y，再更新上层的 x。

### 模块三 · splay（伸展核心）

```cpp
void splay(int x, int k)//将x移动到k下面 
{
	while (tree[x].fa != k)
	{
		int y = tree[x].fa;
		int z = tree[y].fa;
		if (z != k) // 存在祖父, 可做双旋判定
		{
			// 异或为真: x和y方向不同 (zig-zag) -> 先旋 x
			// 异或为假: x和y方向相同 (zig-zig) -> 先旋 y
			(tree[y].son[0] == x) ^ (tree[z].son[0] == y) ? rot(x) : rot(y);//同向旋转y,异向旋转x
		}
		rot(x); // 最后必定再旋一次 x
	}
	if (k == 0) root = x; // 若目标是根则更新全局根
}
```

- 循环条件 `tree[x].fa != k`：把 x 一路旋到 k 的正下方，k=0 表示旋到根。
- 只有存在祖父 z 且 `z != k` 时才做双旋判定，用异或区分 zig-zig 与 zig-zag。
- 异或为真（x 与 y 方向不同，zig-zag）先 `rot(x)`；为假（同向，zig-zig）先 `rot(y)`；最后都再补一次 `rot(x)`。
- 循环结束后若 `k==0` 更新 `root=x`，保证全局根指针与结构一致。

### 模块四 · find 与前驱/后继

```cpp
void find(int v)//找到v，并且将x移动到根节点 
{
	int x = root;
	// v > tree[x].val 为真(1)走右, 为假(0)走左; 同时检查不等于v且子节点存在
	while (tree[x].son[v > tree[x].val] && tree[x].val != v) x = tree[x].son[v > tree[x].val];
	splay(x, 0);
}
int get_pre(int v) //找到v的前驱 
{
	find(v);            // v 或最近节点旋到根
	int x = root;
	if (tree[x].val < v) return x; // 若 root 已经 < v, root 即前驱
	x = tree[x].son[0];           // 否则进左子树
	while (tree[x].son[1]) x = tree[x].son[1]; // 左子树中一直往右走到底
	return x;
}
int get_suc(int v)//找到v的后继 
{
	find(v);
	int x = root;
	if (tree[x].val > v) return x; // 若 root 已经 > v, root 即后继
	x = tree[x].son[1];           // 否则进右子树
	while (tree[x].son[0]) x = tree[x].son[0]; // 右子树中一直往左走到底
	return x;
}
```

- `find` 用 `v > tree[x].val` 作方向下标（真=右 1、假=左 0）沿 BST 下行，命中 v 或走到空边即停，然后 `splay(x,0)` 旋到根。
- find 后 root 要么是 v 本身，要么是离 v 最近的节点（前驱或后继），前驱/后继查询都复用这一点。
- `get_pre`：root 值已 < v 时 root 即前驱；否则进左子树一路向右走到底，取左子树中的最大值。
- `get_suc` 对称：root 值已 > v 时 root 即后继；否则进右子树一路向左走到底；-INF/+INF 哨兵保证永远有解。

### 模块五 · del / getrk / getval（删除、排名、第 k 小）

```cpp
void del(int v)//删除v 
{
	int pre = get_pre(v);  // 前驱 (因哨兵存在必定有值)
	int suc = get_suc(v);  // 后继
	splay(pre, 0); splay(suc, pre);
	//将pre当根节点，suc作为pre的右孩子，目的是因为v是树中唯一满足pre < v < suc,所以v一定是suc的左孩子
	int tmp = tree[suc].son[0];
	if (tree[tmp].cnt > 1)  // 重复元素: 仅减少计数
	{
		--tree[tmp].cnt;
		splay(tmp, 0);
	}
	else                    // 唯一元素: 直接摘除
	{
		tree[suc].son[0] = 0;
		splay(suc, 0);
	}
}
int getrk(int v)//找到v的排名 
{
	find(v);
	// 若 root.val < v (v不在树中): 排名 = 左子树sz + root.cnt (所有<=root的个数)
	// 若 root.val >= v (v在树中):  排名 = 左子树sz (严格<v的个数)
	return tree[root].val < v ? tree[tree[root].son[0]].sz + tree[root].cnt : tree[tree[root].son[0]].sz;
}
int getval(int k)//找到第k小的数 
{
	int x = root;
	k += 1; // +1 跳过 -INF 哨兵 (哨兵占第1名)
	while (true)
	{
		int t = tree[x].son[0]; // 左子树
		if (tree[t].sz + tree[x].cnt < k) // 答案在右子树
		{
			k -= tree[t].sz + tree[x].cnt; // 减去左子树和自身的元素数
			x = tree[x].son[1];
		}
		else
		{
			if (tree[t].sz >= k) x = tree[x].son[0]; // 答案在左子树
			else break; // 左子树sz < k <= 左子树sz+cnt, 当前节点即答案
		}
	}
	splay(x, 0);
	return tree[x].val;
}
```

- `del` 先取 pre/suc 再 `splay(pre,0); splay(suc,pre)`，使 pre 为根、suc 为 pre 右孩子；因 pre<v<suc 且 v 唯一，v 必是 suc 的左孩子。
- 若 `cnt>1` 只 `--cnt`，否则把 suc 左孩子置 0 摘除节点；两种分支最后都 splay 到根，维持局部性并顺带修正沿途 sz。
- `getrk`：find 后若 `root.val < v`（v 不在树）返回 `左子树sz+cnt`（所有 ≤root 即 <v 的元素个数），否则返回 `左子树sz`（严格 <v 的个数）。
- `getval`：`k+=1` 跳过 -INF 哨兵；`左子树sz+cnt < k` 时向右走并减掉，否则看左子树是否够 k，都不满足则当前节点就是答案。

### 模块六 · insert 与 main（插入 + 主流程）

```cpp
void insert(int v)//添加元素 
{
	int x = root, p = 0;
	while (x && tree[x].val != v) // 沿BST向下搜索v
	{
		p = x;
		x = tree[x].son[v > tree[x].val];
	}
	if (x) tree[x].cnt++; // 已存在: 增加计数
	else
	{
		x = tree.size();  // 新节点下标 = 当前vector大小
		tree[p].son[v > tree[p].val] = x; // 挂到父节点p的对应方向
		tree.emplace_back(v);             // 在vector末尾构造新节点
		tree[x].fa = p;                   // 设置父指针
	}
	splay(x, 0); // 旋到根, 保证局部性
}
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	tree.emplace_back(0);              // tree[0] = 空哨兵节点
	tree[0].sz = 0, tree[0].cnt = 0;   // 空节点大小和计数必须为0
	insert(-0x3f3f3f3f);               // 左哨兵 -INF
	insert(0x3f3f3f3f);                // 右哨兵 +INF
	int n;
	cin >> n;
	for (int i = 1; i <= n; i++)
	{
		int op, x;
		cin >> op >> x;
		switch (op)
		{
		case 1: insert(x); break;                 // 插入
		case 2: del(x); break;                     // 删除
		case 3: cout << getrk(x) << '\n'; break;   // 查排名
		case 4: cout << getval(x) << '\n'; break;  // 查第k小
		case 5: cout << tree[get_pre(x)].val << '\n'; break; // 前驱
		case 6: cout << tree[get_suc(x)].val << '\n'; break; // 后继
		}
	}
	return 0;
}
```

- `insert` 沿 BST 向下找 v：找到就 `cnt++`，否则以 `tree.size()` 为新下标、`emplace_back` 构造并挂到父节点 p 的对应方向。
- 每次 insert 都 `splay(x,0)` 把新插入或已存在节点旋到根，维持访问局部性。
- `main` 先 `emplace_back(0)` 建立空哨兵并显式置 `sz=0, cnt=0`，再插入 -INF/+INF 两个哨兵，保证前驱/后继永不出界。
- switch 按 op 分发 6 种操作；前驱/后继输出的是 `tree[get_pre(x)].val`（取节点值），排名与第 k 小直接输出函数返回值。

## 复杂度分析

Splay树每次操作的均摊时间复杂度为 $O(\log n)$。这一结论基于Sleator-Tarjan的势能分析：定义势能函数 $\Phi(T) = \sum_u \log_2(\text{size}(u))$，其中size(u)是节点u的子树大小。Access Lemma证明，将节点x伸展到根的实际代价加上势能变化不超过 $3 \cdot \log_2(\text{size}(T)) + 1 = O(\log n)$。在一串m次操作中，初始势能为0、最终势能不超过 $n \cdot \log_2(n)$，因此总实际代价 $\leq$ 总均摊代价 + 初始势能 $= O((m+n) \cdot \log n)$，每次操作均摊 $O(\log n)$。

空间复杂度为 $O(n)$，每个节点存储fa、son[2]、val、sz、cnt共5个整型字段。注意vector动态增长，tree[0]占用一个空节点位。

## 适用场景

Splay树适用于需要动态维护有序序列并支持排名查询、前驱后继查找、插入删除的场景。由于其独特的"最近访问优先"特性，Splay在访问局部性强的数据上表现优于严格平衡树。更重要的是，Splay是Link-Cut Tree（LCT）的基础数据结构——LCT利用Splay维护实链剖分，支持动态森林上的链查询、连通性判断、换根等操作。此外，Splay天然支持split/merge操作（通过splay到边界后断开/连接），适用于需要序列分割合并的场景。

## 常见陷阱与注意事项

- **必须初始化哨兵节点**：`insert(-0x3f3f3f3f)` 和 `insert(0x3f3f3f3f)` 必须在main开头执行，否则 `get_pre(最小元素)` 或 `get_suc(最大元素)` 会因找不到前驱/后继而出错。
- **tree[0]空节点的sz和cnt必须为0**：代码注释标注"可能有问题"正是因为此点。upsz函数会访问 `tree[tree[x].son[0]].sz`，当son[0]=0（空）时取到tree[0].sz，若不为0则子树大小计算错误。main中 `tree[0].sz = 0, tree[0].cnt = 0` 显式修正了这一点。
- **rot后必须调用upsz**：旋转改变了子树结构，若忘记更新sz则后续的排名查询和第k小查询全部出错。代码中 `upsz(y), upsz(x)` 先更新下层y再更新上层x，顺序不能反。
- **getval中的k+=1**：由于插入了-INF哨兵，最小的真实元素排名为2（第1名是-INF），因此查询第k小实际要找第k+1名。
- **del中v必须是suc的左孩子**：这一前提依赖于"v在树中唯一存在且pre<v<suc"的BST性质。若树中不存在v，get_pre和get_suc仍会返回最近的节点，但del的逻辑前提不成立，可能导致误删。
- **getval(k)越界会死循环与哨兵值域冲突**：`getval` 用 `while(true)` 无兜底退出，k 越界（过大或过小）时会在空节点上反复原地打转，应假设 k 合法或先判断 `1 <= k <= 元素总数`；另外哨兵取 `±0x3f3f3f3f`（约 $1.06\times10^9$），插入值若逼近该上界会与 +INF 冲突，值域应远离哨兵或改用更大的哨兵（如 `±0x7fffffff`）。

## 对比与扩展

- **Splay vs AVL**：AVL严格保持平衡因子 $\leq 1$，查询性能稳定 $O(\log n)$ 但旋转频繁、常数大；Splay不严格平衡但代码简洁、均摊 $O(\log n)$，且自带局部性优化。
- **Splay vs Treap**：Treap通过随机堆优先级保证平衡，期望 $O(\log n)$，实现简单且支持可持久化；Splay无法高效可持久化（旋转会破坏版本结构），但均摊分析更紧。
- **Splay vs 红黑树**：红黑树是工业级平衡树（STL的map/set底层），保证 $O(\log n)$ 最坏复杂度但实现极其复杂；Splay实现简单，适合竞赛使用。
- **扩展：LCT（Link-Cut Tree）**：基于Splay维护动态树，支持link/cut/makeroot/链查询等操作，是Splay最重要的应用延伸。
- **扩展：序列Splay**：将Splay按序列下标组织，利用splay到根+子树拼接实现区间反转、区间移动等操作。$AKB186$, '数据结构', array['数据结构', '平衡树', 'Splay', '伸展树', '自平衡BST'], 'col-ds-balanced-tree-overview', null, 'knowledge'),
('Fohen', 'col-ds-sqrt-tree--fenfeng', 'Sqrt Tree · Fohen', $AKB187$> 本文由 Fohen 授权合并，正文保留原文结构与表述；原文为《浅谈常用的分块算法》，本页按分块类型拆分。

## Sqrt Tree

暴论：$Sqrt \ Tree$ 是区间 $rmq$ 的最优算法（至少是蒟蒻目前的认知范围中的最优解）。

先看一下 $Sqrt \ Tree$ 的基本思想，为了方便讲解，这里我们把 $rmq$ 需要解决的问题设为求区间最大值。首先可以把序列分成若干个块，再求出每一块内的最大值，并用 $st$ 表维护两两块之间的最大值，然后对每个块求出块内的前缀最大值和后缀最大值。这样进行预处理的空间复杂度和时间复杂度都是 $\operatorname{O}(n)$ 的，完成这个预处理后，对于一次跨过多个块的询问，我们就可以 $\operatorname{O}(1)$ 回答了。具体来说，对于跨过的整块部分，就可以回答这些连续的整块中的最大值，而散块部分，一定是某个块的前缀或后缀，直接统计、回答就好了。

但是如果遇到询问区间在一个块内的情况，那这个询问区间也许就不能拆成若干段前缀和后缀了，这时复杂度便退化为了 $\operatorname{O}(\sqrt{n})$，不是很优。我们希望所有的询问区间都能看成 “跨过块” 的区间，于是再把已经分出的块内再进行分块。具体来说，我们可以把长度为 $n$ 的序列看成长度为 $n$ 的块，然后把长度为 $n$ 的块分成 $\sqrt{n}$ 块，每块长度为 $\sqrt{n}$，再把每个长为 $\sqrt{n}$ 的块分成 $\sqrt{\sqrt{n}}$ 长度的块，$\cdot\cdotp\cdotp\cdotp\cdotp\cdotp$，直到某一层，我们能把每一个上一层的块分成若干个长度为 $1$ 的块。这样看似增加了复杂度，实际上保证了不会出现像刚刚那样整个询问都在某一个块内的情况——这种情况一旦发生，就会使复杂度从 $\operatorname{O}(1)$ 退化为 $\operatorname{O}(B)$（$B$ 表示这个块的块长）。

于是，我们对于每一个上一层块分成的若干下一层的块，维护这些块内的前缀最大值和后缀最大值，并对这些由同一个上一层块分成的块之间用 $st$ 表维护两两块之间的最大值（同一个上一层块保证了块的数量是 $\sqrt{n}$，保证了 $st$ 表预处理的复杂度）。我们发现，如果把一个块看成点，并与分成它的上一层块连边，整个结构会变为一棵树，树高为 $\operatorname{O}(\log \log n)$，根节点为原序列，叶子节点为长度为 $1$ 的块，除叶子节点外一个节点的 $\sqrt{n}$ 个儿子就是这个块分成的 $\sqrt{n}$ 个块，很显然，建树的时间复杂度是 $\operatorname{O}(n \log\log n)$ 的。接下来考虑如何在这棵树上快速进行查询：

假设我们要询问的区间是 $[l,r](r>l)$，那么一定有一个深度 $d$，满足在前 $d-1$ 层块中，$l$ 和 $r$ 所属同一个块，而在第 $d$ 层的块中，$l$ 和 $r$ 不再属于同一个块。如果我们可以快速知道一组询问的 $d$，就可以直接找到第 $d$ 层，并把 $[l,r]$ 根据第 $d$ 层的块分成整块部分和散块部分，这些都是预处理过的，可以直接回答。如何快速求出 $d$ 呢？回想我们用 $st$ 表求 $rmq$ 时，为了快速求出一个 $k$ 满足 $l+2^k-1 \le r  \land r - 2 ^ k + 1 \ge l \land [l,l+2^k-1] \cup [r-2^k+1,r]=[l,r]$，我们使用了查找二进制最高位的 $1$ 的方法来解决，于是这里也可以试着考虑二进制。

我们在原序列的后面添 $0$，直到序列的长度变为 $2$ 的若干次幂，这样序列的长度仍是 $\operatorname{O}(n)$ 的。这样处理后，对于一次询问的 $l$ 和 $r$，我们可以快速求出 $l$ 和 $r$ 的二进制从哪一位开始不同。虽然我们每次分成块的数量是 $\sqrt{n}$，但是因为 $2$ 的若干次幂开根后仍是 $2$ 的若干次幂，所以还是可以通过预处理使得可以根据 $l$ 和 $r$ 最高的不同位求出哪一层开始 $l$ 和 $r$ 不再属于同一块。于是，我们对于一组询问，就可以直接询问满足 $l$ 和 $r$ 第一次不属于同一块的那一层，并根据那一层中预处理出的 $st$ 表以及前缀/后缀最大值 $\operatorname{O}(1)$ 求出答案。

这样做预处理是 $\operatorname{O}(n\log\log n)$，单次查询是 $\operatorname{O}(n)$ 的，而空间复杂度是 $\operatorname{O}(n)$ 的 ~~碾压 st 表~~。

### 例题 $21$：[P3793 由乃救爷爷](https://www.luogu.com.cn/problem/P3793)

>给你一个序列，若干次询问区间最大值。所有数据随机生成。

（数据保证序列长度、询问次数 $\le 2\times 10^7$ ）

板子题。

因为数据是纯随机的，所以可以用单层分块莽过去。不过用 $Sqrt \ Tree$ 更加正确，而且这就是板子。

到这里为止，$Sqrt \ Tree$ 的优势还不是很明显，光论时间复杂度，与 $st$ 表的差距并不大（甚至常数可能大于 $st$ 表），于是我们尝试用 $Sqrt \ Tree$ 解决一些更加 “复杂” 的操作，比如用 $st$ 表无法实现的带修。

先看单点修改。有一个很暴力的做法，就是直接对每一层的消息进行修改，这样明显是 $\operatorname{O}(n+\sqrt{n}+\sqrt{\sqrt{n}}+\sqrt{\sqrt{\sqrt{n}}}+\cdot\cdot\cdotp+1)=\operatorname{O}(n)$，非常不优。

思考这个暴力的过程，发现复杂度的开支主要在于对于第一层的修改，因为 $st$ 表实在不是很优，想要优化，就要把维护两两块之间的 $st$ 表优化掉。

我们可以把一个块看成一个点，那么就可以把第二层块之间的 $st$ 表转化为任意一个能维护 $\operatorname{O}(\sqrt{n})$ 个数中的区间最大值的数据结构，而且在询问时能快速回答，最好是 $\operatorname{O}(1)$ 回答。这不就是 $Sqrt \ Tree$ 能解决的问题吗？于是，我们把每个第二层的块看成一个点，共 $\operatorname{O}(\sqrt{n})$ 个点，每个点的权值即为一个第二层块内的最大值，两个第二层块之间的最大值，即为对应的两个点之间的最大值，用 $Sqrt \ Tree$ 可以 $\operatorname{O}(1)$ 维护。一次单点修改的复杂度便被优化到了 $\operatorname{O}(\sqrt{n}+\sqrt{\sqrt{n}}+\sqrt{\sqrt{\sqrt{n}}}+\cdot\cdot\cdotp+1)=\operatorname{O}(\sqrt{n})$，查询的复杂度仍是 $\operatorname{O}(1)$ 的。当然，也可以统一一下，把每一层两块之间的查询都用我们新建出来的第二个 $Sqrt \ Tree$ 来做，这样修改时除了要修改第二层，还要不断往下面递归修改，但原树就不再需要维护 $st$ 表或其他用来查询两块之间最大值的数据结构了，仍然是 $\operatorname{O}(\sqrt{n})$ 的。

又可以解决一道题了：

### 例题 $22$：[P11750 「TPOI-1D」谢谢您。](https://www.luogu.com.cn/problem/P11750)

>给你一个长度为 $n$ 的序列 $a$ 和一个长度为 $m$ 的对应 $a$ 的区间序列 $[l_i,r_i]$，有 $q$ 次询问，每次需要对于区间序列中下标 $\in [L,R]$ 的所有区间，回答 $k$ 在 $a$ 序列上的这些区间中出现次数的最大值。

（数据范围保证 $n,m,q \le 2\times 10^5$，$\forall 1\le i\le n, \ a_i \le n$）

发现询问的最外层是对区间序列上的一个区间中的所有区间取最大值，先考虑处理最外层。我们可以对区间序列进行序列分块，于是一次询问 $(L,R,k)$ 就被根据 $[L,R]$ 拆成了整块部分和散块部分，最后再对这两部分取最大值就行了。

我们把拆成的整块部分和散块部分离线下来处理，于是问题变为了：设 $B$ 为序列分块的块长，$T = \lceil\frac{n}{B}\rceil$ 为序列分块的块数，$\operatorname{O}(qT)$ 次询问一个整块内包含的所有区间中某个数出现次数的最大值，$\operatorname{O}(qB)$ 次询问一个区间内某个数的出现次数，最后将这些全部取最大值。

先看整块。发现对于有包含关系的两个区间，被包含的那个区间一定是不优于包含它的那个区间的，于是可以不考虑。把这个块包含的剩下的区间按左端点的位置排序，排完序后会变成若干个左端点依次递增且右端点依次递增的区间序列。

考虑用一种类似于莫队的方式处理这些区间。每次从上一个区间移动到下一个区间，并在过程中统计当前区间每个数的出现次数。这里直接移动就是对的，因为左右端点的移动次数都是 $\operatorname{O}(n)$ 的。当当前区间与下一个区间序列上的区间相等时，想办法更新答案，发现 $a$ 序列共有 $n$ 种权值，这就导致很多时候一个区间相较于上一个区间序列上的区间，大部分权值的出现次数并未发生改变，如果我们只对出现次数发生了改变的数进行统计，复杂度就会大大降低。

实际上，因为一次移动区间的左右端点只会影响一个数在区间中的出现次数，而一共 $\operatorname{O}(n)$ 次移动也最多只会影响 $\operatorname{O}(n)$ 个位置，所以，我们在从一个区间移动到下一个区间序列中的区间时，记录哪些数的出现次数发生了改变，并在到达下一个区间时，只对这些更改了出现次数的数进行统计（把所有这种情况下某个数的出现次数取最大值就是这个数在块内区间的出现次数最大值），而其他在移动过程中出现次数未发生改变的数，就一定在这之前就被统计过了。对于每一个整块都进行这样的过程，明显复杂度是 $\operatorname{O}(Tm)$ 的。

接下来看散块部分如何回答。设 $\operatorname{f}(l,r,x)$ 表示一次散块询问：序列 $a$ 中 $[l,r]$ 内有多少个 $x$。我们可以把所有 $x$ 相同的三元组放到一起处理，然后考虑根号分治，具体来说，设 $tot_i$ 表示数 $i$ 在序列 $a$ 中出现的次数，分别讨论 $tot_i > \sqrt{n}$ 以及 $tot_i \le \sqrt{n}$ 两种情况。

如果 $tot_i > \sqrt{n}$，此时满足这种条件的不同的 $i$ 最多只有 $\sqrt{n}$ 个。于是，我们对于每个满足条件的数 $i$ 可以较为暴力地求解。具体来说，我们可以把一次询问区间中 $i$ 的出现次数拆解为两个前缀中的出现次数相减，于是，我们只需维护一个前缀内每个数的出现次数就行了，因为复杂度要求不高，我们可以在一个数组中直接对 $i$ 每一次出现的位置 $+1$，然后把这个数组前缀和起来，这样每次就能 $\operatorname{O}(1)$ 解决询问了。最终这部分复杂度为 $\operatorname{O}(n\sqrt{n})$。

如果 $tot_i \le \sqrt{n}$，其实和刚刚那种情况十分类似，但是因为这样的不同的 $i$ 数量很多，不再能暴力前缀和了。思考我们刚刚用前缀和解决了什么问题，其实就是单点修改和前缀求和，并且单次询问能做到 $\operatorname{O}(1)$。然后就会发现，这不就是 $Sqrt \ Tree$ 吗？我们把 $Sqrt \ Tree$ 中原本维护的每块中的前缀/后缀最大值改为维护每块中的前缀/后缀和，把原来维护的两个块之间的最大值改为维护两个块之间的和就行了，这样修改后 $Sqrt \ Tree$ 仍然是修改 $\operatorname{O}(\sqrt{n})$ 查询 $\operatorname{O}(1)$ 的，于是我们愉快地用 $Sqrt \ Tree$ 替换掉正常的前缀和，因为 $a$ 序列一个位置只有一个值，也就只能被一个数用到，所以这部分的总时间复杂度为 $\operatorname{O}(n\sqrt{n})$。

另外，发现每次原来的询问都会产生最多两段连续的区间序列上的下标区间，并对这些区间内的所有区间进行求解，所以并不用记录全部 $\operatorname{O}(qB)$ 组询问，只需记录 $\operatorname{O}(q)$ 组 “询问段” 就行了。

分析复杂度。整块部分是 $\operatorname{O}((m+q)T)$ 的，散块部分是 $\operatorname{O}(n\sqrt{n}+qB)$，在 $n,m,q$ 同阶的情况下，理论上 $B$ 取 $\operatorname{O}(\sqrt{m})$ 时最优，此时时间复杂度为 $\operatorname{O}(n\sqrt{n})$，可以通过。

$Sqrt \ Tree$ 的用处并不只有这些，比如，我们能通过一些方法实现比较简单的区间修改，以区间覆盖为例，我们有两种处理方法，一种需要 $\operatorname{O}(\sqrt{n}\log\log n)$ 的时间进行区间修改，查询还是只需 $\operatorname{O}(1)$ 的，另一种修改需要 $\operatorname{O}(\sqrt{n})$，但查询退化成了 $\operatorname{O}(\log\log n)$。

先看第一种。我们回忆在线段树中做这种区间操作的方法：我们会对线段树上的每个节点维护一个懒标记，这个懒标记记录着还未下传的这个点子树内所有节点的修改，这样在修改时，如果区间覆盖了当前这个点代表的区间，就不用继续下传了，而是直接修改懒标记。$Sqrt \ Tree$ 也是树形结构，是否也能仿照这种方法维护修改呢？我们还是可以对一个点打上懒标记，但因为一个点的儿子很多，导致正常的下传复杂度很高，于是我们强制让懒标记不下传。具体来说，我们只对 $Sqrt \ Tree$ 上的第二层点（也就是每个大小 $\sqrt{n}$ 的块）记录懒标记，对于一次修改的区间，我们能类似于序列分块地把这个区间拆成 $\operatorname{O}(\sqrt{n})$ 个整块以及总长度为 $\operatorname{O}(\sqrt{n})$ 的散块，对于整块的部分，我们对这个 $\sqrt{n}$ 的块对应的树上的第二层的点打上懒标记，并更新这些块记录的信息，注意这里的懒标记是不用下传的；对于散块，因为这些散块最多属于两个不同的二层点，所以可以对这些散块部分所属的 $\sqrt{n}$ 长度的块也就是树上的二层点的子树进行重构，在重构过程中，我们遍历这个点在 $Sqrt \ Tree$ 上子树内所有的点，重新在考虑之前尚未处理的懒标记的情况下计算这些点的所有信息，重构的复杂度是 $\operatorname{O}(\sqrt{n}\log\log n)$（每层的长度和都为 $\sqrt{n}$，整棵树共有 $\log\log n$ 层）。当然，我们还需对上面为了解决单点修改而构造出的第二棵维护每两个二层点之间的信息的 $Sqrt \ Tree$ 进行操作，但因为第二棵 $Sqrt \ Tree$ 每层的长度和只有 $\sqrt{n}$，这并不大，所以可以直接暴力对第二棵 $Sqrt \ Tree$ 进行重构，更新每个点的各种信息，这样做的时间复杂度也是单次 $\operatorname{O}(\sqrt{n}\log\log n)$。这样修改完后，查询依旧是好做的，分为两种情况：如果一次查询跨过了多个二层块，就统计最左边的散块部分对应的块内后缀信息、最右边的散块部分对应的块内前缀信息以及一段整块的信息（在第二棵 $Sqrt \ Tree$ 上询问）；如果一次询问完全在一个二层块的子树内，就要在原先的基础上处理这个询问所属二层块的尚未处理的懒标记，把这些未处理的懒标记也计算进最终的结果中。

再看第二种处理方式。我们依旧可以记录懒标记，但不同于刚刚那种，这次我们允许在任意一个点上打上懒标记。对于一次区间 $[l,r]$ 的修改，我们可以用和查询类似的方法求出从哪一层开始 $l$ 和 $r$ 跨过了一个以上的块，并根据这一层分块把 $[l,r]$ 拆成整块和散块两部分。整块部分就只需遍历每个块打上懒标记，而对于散块部分则暴力修改块内的前缀、后缀信息，同时如果有第二层块的修改，要记得更新第二棵 $Sqrt \ Tree$。但我们发现，即便做完这些后，对于散块部分，本质上并没有做出修改——我们并没有记录懒标记或是重构子树，这导致如果某次询问到了这个散块所属块的子树中去，那么只修改单层的前/后缀和等信息就不够了。于是递归处理，每次把散块部分递归下去，在某一层拆成新的整块和散块，如此重复，直到原操作区间 $[l,r]$ 中的每一个位置的某个祖先都被打上懒标记。为了不在下传懒标记时浪费过多时间，我们只好对每次询问暴力枚举询问区间拆成的整块和散块的祖先块，并把所有这些祖先块中的懒标记都考虑进对答案的影响中去。看一下复杂度，对于一层的修改，复杂度为这一层的块数 $+$ 块长，所以每一层加起来即为 $\operatorname{O}(\sqrt{n} + \sqrt{\sqrt{n}} + \sqrt{\sqrt{\sqrt{n}}} + \cdot\cdot\cdotp)=\operatorname{O}(\sqrt{n})$，而回答询问时要遍历所有的祖先，时间复杂度即为 $Sqrt \ Tree$ 的深度 $\operatorname{O}(\log\log n)$。

以上就是 $Sqrt \ Tree$ 常用的操作，容易看出，$Sqrt \ Tree$ 对比其他 $rmq$ 算法有几大优势：

- 空间开销小，只有 $\operatorname{O}(n\log\log n)$。
- 询问复杂度低，能通过复杂的操作和平衡优化到 $\operatorname{O}(1)$，在带修的情况下还能做到 $\operatorname{O}(1)$ 查询区间的好像真的没什么了。
- 可以做很多事情，比如单点、区间上的修改。

但同时，$Sqrt \ Tree$ 优秀的复杂度来自于这个算法每一步的巧妙平衡和优化，这使得最终整个 $Sqrt \ Tree$ 的完全版极度复杂，甚至显得不是很优雅，但确实达到了一个很优的时空复杂度。至于代码难度，不在此文的考虑范围内。

$rmq$ 在许多问题中都有应用，而使用 $Sqrt \ Tree$ 可以降低求解 $rmq$ 这一个部分的时间复杂度，以便平衡问题中其他部分的复杂度。即便如此，适配 $Sqrt \ Tree$ 的应用还是很少，下面这题只是用 $Sqrt \ Tree$ 来实现 $rmq$ 的部分，与 $Sqrt \ Tree$ 本身的性质关联不大，所以较为简略的介绍：

### 例题 $23$：[P8571 [JRKSJ R6] Dedicatus545](https://www.luogu.com.cn/problem/P8571)

>给你 $n$ 个字符串，$m$ 次询问下标处于区间 $[l,r]$ 内的字符串在下标为 $k$ 的字符串中出现次数的最大值

（数据保证 $n,m \le 10^5$，字符串长度和 $\le 5\times 10^5$）

这种有关 “一个字符串在另一个字符串中出现” 的问题，较优的思路有两种：正向考虑，使用 $SAM$；把子串转化为后缀的前缀，使用 $SA$，这里主要介绍 $SA$ 的做法。先把 $n$ 个字符串拼接起来，相邻两个字符串之间要隔着一个间隔符，然后对这个拼接起来的字符串后缀排序。基于后缀排序的特性，我们可以这样求出包含一个字符串 $s_i$ 的所有后缀的前缀：先确定以 $s_i$ 在拼接串中的左端点开始的后缀在后缀排序后的编号，那么一个后缀 $suf$ 只要与这个后缀的 $lcp \ge lenth_{s_i}$（$lenth_{s_i}$ 表示 $s_i$ 的长度），就说明 $s_i$ 在 $suf$ 的前缀中出现过。

对于每个原串 $s_i$，我们可以通过二分较为快速地求出一个区间 $[L_i,R_i]$ 满足排序后编号在这个区间内的后缀都以 $s_i$ 为前缀，换句话说，这些后缀与 $s_i$ 原本所处的后缀的 $lcp \le lenth_{s_i}$。

我们可以提前预处理出一个排序后的后缀 $suf_i$ 在原拼接串中所属的字符串的编号 $c_i$，一个原字符串 $s_i$ 在 $s_j$ 中的出现次数即为 $s_i$ 对应的后缀 $suf_k$ 的区间 $[L_k,R_k]$ 中 $c$ 值 $=j$ 的个数。进一步的，我们可以把题目中的一次询问 $(l,r,k)$ 转化为：编号从 $l$ 到 $r$ 的每个原字符串对应的后缀的区间 $[L,R]$ 中 $c$ 值 $=k$ 的个数的最大值。“某个数在区间序列里的一段区间中出现次数的最大值”，我们发现，这个简化后的问题不就是例题 $19$ 吗？于是我们对剩下的部分做一遍例题 $19$ 的解法，就能通过了。

时间复杂度也是基于例题 $19$ 的，因为这题中字符串长度总和与 $n,m$ 的量级有一定差别，所以较于例题 $19$ 需要调整块长，经过一定调整后便能做到 $\operatorname{O}(n\sqrt{S})$，其中 $S$ 表示字符串长度和，再加上后缀排序以及二分的部分，总时间复杂度即为 $\operatorname{O}(n\sqrt{S}+S\log S)$，可以通过。$AKB187$, '数据结构', array['Sqrt Tree', '分块', 'RMQ'], 'col-hub-ds-block', null, 'knowledge'),
('Xesir', 'col-ds-st-table-1--xesir', 'ST表（倍增预处理与 O(1) 查询） · Xesir', $AKB188$## 算法原理

ST 表（Sparse Table，稀疏表）是一种处理**静态区间查询**的数据结构。它最经典的用途是解决 **RMQ** 问题：给定一个不会修改的序列，多次查询区间最大值 / 最小值。

它能做到 $O(n \log n)$ 预处理、单次 $O(1)$ 查询——是的，你没听错，是 $O(1)$。所以 ST 表非常适合「静态 + 大量查询」的场景。事实上，任意**可重复贡献问题**（区间最值、区间 gcd 等）都能用 ST 表维护，下面以 RMQ 为例讲解。

> ST 表**不支持修改**；需要大量修改的题要用线段树等结构。

核心思想是**倍增**：任意区间长度都能写成若干个 $2$ 的幂之和（即二进制分解），所以只要预先算好所有「长度为 $2$ 的幂」的区间答案，就能用常数个已算好的块拼出任意长度的查询。

## 核心公式 / 状态定义与转移方程

定义 $f[i][j]$ 表示从位置 $i$ 开始、长度为 $2^j$ 的区间最大值：

$$
f[i][j] = \max\{a_i, a_{i+1}, \dots, a_{i + 2^j - 1}\}
$$

- **边界**：$j = 0$ 时区间长度为 $1$，$f[i][0] = a_i$。
- **转移**：长度为 $2^j$ 的区间可以平均分成两个长度为 $2^{j-1}$ 的区间——$[i,\ i + 2^{j-1} - 1]$ 和 $[i + 2^{j-1},\ i + 2^j - 1]$，于是

$$
f[i][j] = \max\big(f[i][j-1],\ f[i + 2^{j-1}][j-1]\big)
$$

**查询** 区间 $[l, r]$，长度 $len = r - l + 1$，取 $k = \lfloor \log_2 len \rfloor$（保证 $2^k \le len$），用两个长度为 $2^k$ 的块覆盖它：

- 左端开始的块：$[l,\ l + 2^k - 1]$；
- 右端结束的块：$[r - 2^k + 1,\ r]$。

两块可能**重叠**，但一定完整覆盖 $[l, r]$，于是

$$
\max(l, r) = \max\big(f[l][k],\ f[r - 2^k + 1][k]\big)
$$

重叠不影响结果，靠的是 $\max$ 是**幂等运算**（$\max(x, x) = x$）。

## 逐行代码解析

### 预处理：倍增建表

```cpp
for(int j=1;j<=lg[n];j++){
	for(int i=1;i+(1<<j)-1<=n;i++){
		f[i][j]=max(f[i][j-1],f[i+(1<<(j-1))][j-1]);
	}
}
```

- 外层枚举幂次 $j$，从小到大（这样 $j-1$ 层的答案已经就绪）。
- 内层枚举起点 $i$，循环上界 `i + (1<<j) - 1 <= n` 保证长度为 $2^j$ 的区间不越界。
- 转移 `f[i][j] = max(f[i][j-1], f[i + (1<<(j-1))][j-1])`：两个半段拼成整段。
- `lg` 是预处理的**对数表**，`lg[n]` 是 $\lfloor \log_2 n \rfloor$，即最大的合法 $j$。

### 查询：两段重叠拼合

```cpp
for(int i=1;i<=m;i++){
	int l=read(),r=read();
	int x=lg[r-l+1];
	int res=max(f[l][x],f[r-(1<<x)+1][x]);
	write(res);putchar('\n');
}
```

- 读入区间长度 `len = r - l + 1`，查对数表得到 $k = \text{lg}[len]$。
- 用左段 `f[l][x]` 与右段 `f[r-(1<<x)+1][x]` 取 max，即为答案。
- 查询只用两次取数，$O(1)$，与区间长度无关。

## 复杂度分析

- 预处理：$j$ 有 $\log n$ 层，每层线性填表，$O(n \log n)$。
- 查询：两次取值 + 一次 max，$O(1)$。
- 空间：$f$ 是 $n \times \log n$ 的表，$O(n \log n)$；对数表 `lg` 额外 $O(n)$。

## 适用场景

- **静态 RMQ**：数组不变，反复询问区间最大 / 最小值。
- 任何**可重复贡献**的区间运算：区间 gcd、区间按位或 / 与、区间最大值。
- **LCA 的 RMQ 写法**：对欧拉序建 ST 表，区间最浅深度结点即为 LCA。
- 需要「不改 + 大量查询」的场合，比线段树查询更快（$O(1)$ vs $O(\log n)$）。

## 常见陷阱与注意事项

1. **只能用于幂等 / 可重复贡献运算**：区间重叠被算两次仍正确的运算才可用，比如 $\max$、$\min$、$\gcd$。**区间和不行**——重叠部分会重复计入导致 WA。
2. **不支持修改**：一旦数组改动，整张表都要重建。
3. **边界与对数表**：`lg` 必须预处理到 $n$，$k$ 取 $\lfloor \log_2 len \rfloor$，取大了会越界。
4. **预处理顺序**：$j$ 必须由小到大，否则用到的 $j-1$ 层还没算好。
5. **内存**：$n$ 很大时 $n \log n$ 的表可能爆空间（如 $n = 10^7$），此时考虑 `vector` 动态开或分块。

## 对比与扩展

| 维度 | ST 表 | 线段树 | 树状数组 |
|---|---|---|---|
| 预处理 | $O(n \log n)$ | $O(n)$ | $O(n)$ |
| 单次查询 | $O(1)$ | $O(\log n)$ | $O(\log n)$（仅可减信息） |
| 单点修改 | 不支持 | $O(\log n)$ | $O(\log n)$ |
| 空间 | $O(n \log n)$ | $O(n)$ | $O(n)$ |
| 适用 | 静态 RMQ | 动态区间问题 | 前缀和类 |

扩展方向：**二维 ST 表**、**ST 表求 LCA**（对应 `graph-lca-doubling` 的另一种实现），以及需要修改时改用**线段树**（对应 `ds-segtree-basic`）。$AKB188$, '数据结构', array['数据结构', 'ST表', 'RMQ', '倍增', '区间最值'], 'col-ds-rmq-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-st-table-1', 'ST表（标准版1 - 手动预处理对数表）', $AKB189$## 算法原理

ST表（Sparse Table，稀疏表）是基于**倍增**思想（也叫 binary lifting，二进制 lifting）的静态区间查询数据结构，专门解决不可修改数组的区间最值问题（Range Minimum/Maximum Query，RMQ）。倍增的核心是：任意一个区间长度都能表示为若干个 2 的幂次之和（这其实就是二进制分解），因此只要预先算出所有"长度为 2 的幂"的区间的答案，就能在常数次拼合内回答任意长度的查询。具体地，设 $\text{st}[i][j]$ 表示从下标 `i` 开始、长度为 $2^j$ 的区间（即 $[i, i + 2^j - 1]$）的最值，则查询区间 `[l, r]`（长度 $\text{len} = r - l + 1$）时，令 $k = \lfloor \log_2 \text{len} \rfloor$，把区间拆成两段：从 `l` 起长度 $2^k$ 的左段 $[l, l + 2^k - 1]$，和到 `r` 结束长度 $2^k$ 的右段 $[r - 2^k + 1, r]$。这两段可能重叠，但重叠不影响结果——这正是 ST 表能在 $O(1)$ 完成查询的关键。

预处理用递推：$$\text{st}[i][j] = \max(\text{st}[i][j-1],\; \text{st}[i + 2^{j-1}][j-1])$$。直观理解：长度 $2^j$ 的区间可以拆成两个长度 $2^{j-1}$ 的子区间——前半 $[i, i + 2^{j-1} - 1]$ 与后半 $[i + 2^{j-1}, i + 2^j - 1]$，分别对应 $\text{st}[i][j-1]$ 和 $\text{st}[i + 2^{j-1}][j-1]$，取两者最值即得 $\text{st}[i][j]$。由于 `j` 从小到大递推，子区间的答案已经算好，整张表可在 $O(n \log n)$ 时间内建立。注意第二维 `j` 的上界是 $\lfloor \log_2 N \rfloor$，因为 $2^j$ 不能超过 N。

**为什么查询是 O(1)**：因为 max/min 是**幂等运算**（idempotent），即 $\max(x, x) = x$。查询时两段子区间可以重叠，重叠部分被算两次但取 max 后仍正确。这一点对和、积等非幂等运算不成立——若要求和，两段重叠区域的元素会被计算两次。所以 ST 表只适用于 max、min、gcd、按位或等幂等运算；对于求和则必须用前缀和或线段树。本版本的特别之处在于用**手动预处理的幂次表 T 配合 lower_bound 二分查找**来计算 $\lfloor \log_2 x \rfloor$，不依赖编译器内建函数，可移植性更好但代码稍长。

## 数据结构图示

设原数组 `a = [3, 1, 4, 1, 5, 9, 2, 6]`（下标 1~8），ST 表 $\text{st}[i][j]$ 存储从 `i` 起长度 $2^j$ 区间的最大值：

```
j=0 (长度1):  st[1][0]=3  st[2][0]=1  st[3][0]=4  st[4][0]=1
              st[5][0]=5  st[6][0]=9  st[7][0]=2  st[8][0]=6

j=1 (长度2):  st[1][1]=max(3,1)=4   st[2][1]=max(1,4)=4
              st[3][1]=max(4,1)=4   st[4][1]=max(1,5)=5
              st[5][1]=max(5,9)=9   st[6][1]=max(9,2)=9
              st[7][1]=max(2,6)=6

j=2 (长度4):  st[1][2]=max(st[1][1], st[3][1])=max(4,4)=4
              st[2][2]=max(st[2][1], st[4][1])=max(4,5)=5
              st[3][2]=max(st[3][1], st[5][1])=max(4,9)=9
              st[4][2]=max(st[4][1], st[6][1])=max(5,9)=9
              st[5][2]=max(st[5][1], st[7][1])=max(9,6)=9

j=3 (长度8):  st[1][3]=max(st[1][2], st[5][2])=max(4,9)=9

表的形式（行=起点i，列=长度2^j）：
       j=0  j=1  j=2  j=3
i=1 :   3    4    4    9
i=2 :   1    4    5    -
i=3 :   4    4    9    -
i=4 :   1    5    9    -
i=5 :   5    9    9    -
i=6 :   9    9    -    -
i=7 :   2    6    -    -
i=8 :   6    -    -    -

查询 [2,7] 的最大值 (len=6, 2^k<=6 最大 k=2, 2^2=4):
  左段: st[2][2] = max[a[2..5]] = 5
  右段: st[7-4+1][2] = st[4][2] = max[a[4..7]] = 9
  ans = max(5, 9) = 9
  (两段 [2,5] 与 [4,7] 重叠 [4,5]，但 max 幂等无影响)
```

辅助表 T 存 2 的幂，用于 get_h 求 log2：
```
T = [1, 2, 4, 8, 16, 32, 64, ...]  (直到 10^9)
索引: 0   1  2  3   4   5   6  ...
get_h(6): lower_bound(T, 6) 找到第一个 >=6 的元素 T[3]=8
          ans=3, 但 1<<3 = 8 != 6，所以 ans -= 1 => 2
          即 floor(log2(6)) = 2 ✓
```

## 核心操作详解

### init() — 预处理幂次表 T
```cpp
void init() {
    for (int i = 1, k = 1; k <= 1000000000; ++i, k <<= 1)
        T.emplace_back(k);
}
```
预先把 $2^0, 2^1, 2^2, \ldots, 2^{30}$（约 $10^9$）依次存入 `T`，形成一个有序的"2 的幂"表。这样后续 `get_h` 可以用二分在 T 上快速查找。$10^9$ 足够覆盖竞赛常见的 N 上限。预处理只做一次，开销可忽略。

### get_h(i) — 求 $\lfloor \log_2 i \rfloor$
```cpp
int get_h(int i) {
    int ans = lower_bound(T.begin(), T.end(), i) - T.begin();
    if (1 << ans != i) ans -= 1;
    return ans;
}
```
在有序表 T 上做 `lower_bound`，找到第一个 `>= i` 的位置 `ans`。此时 $T[\text{ans}] = 2^{\text{ans}}$。若 $2^{\text{ans}} = i$（i 本身就是 2 的幂），则 $\lfloor \log_2 i \rfloor = \text{ans}$；否则 $2^{\text{ans}} > i$，真正答案应是 $\text{ans} - 1$（因为 $2^{\text{ans}-1} < i < 2^{\text{ans}}$，故 $\lfloor \log_2 i \rfloor = \text{ans}-1$）。这一 off-by-one 的修正非常关键。复杂度 $O(\log |T|) = O(\log \log N)$，实际可视为 $O(1)$。

### 建表双重循环
```cpp
for (int j = 1; j <= h; j++) {
    int k = 1 << j;          // 区间长度 2^j
    int t = j - 1;           // 上一层的 j
    for (int i = 1; i + k - 1 <= N; i++)
        A[i][j] = max(A[i][j - 1], A[i + (1 << t)][j - 1]);
}
```
外层枚举区间长度层级 `j`（从小到大保证子问题已解），内层枚举起点 `i`。`A[i][j]` 由两个长度 $2^{j-1}$ 的子区间拼成：左半 $A[i][j-1]$ 覆盖 $[i, i+2^{j-1}-1]$，右半 $A[i + 2^{j-1}][j-1]$ 覆盖 $[i+2^{j-1}, i+2^j-1]$。内层循环条件 `i + k - 1 <= N` 保证区间不越界。

### 查询
```cpp
int sz = r - l + 1;
int mh = get_h(sz);
write(max(A[l][mh], A[r - (1 << mh) + 1][mh]));
```
先求区间长度 `sz`，再算 $\text{mh} = \lfloor \log_2 \text{sz} \rfloor$，使得 $2^{\text{mh}} \leq \text{sz}$ 但 $2^{\text{mh}+1} > \text{sz}$。然后取两段长度均为 $2^{\text{mh}}$ 的区间：左段从 `l` 起覆盖 $[l, l+2^{\text{mh}}-1]$，右段以 `r` 结尾覆盖 $[r-2^{\text{mh}}+1, r]$。两段并集必覆盖整个 $[l, r]$（因为 $2^{\text{mh}} > \text{sz}/2$，两段各自长度过半必相交），取 max 即得答案。整个查询只做两次数组访问 + 一次 max，是真正的 $O(1)$。

## 逐行代码解析

下面把整份代码按「头文件与全局变量 → init → get_h → 快速读写 → main」拆成 5 个模块。各模块的代码按顺序拼接后与 `.cpp` 完全一致，`//` 注释为讲解性补充。

### 模块 1：头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<vector<int>> A;          // ST 表，A[i][j] = max[a[i..i+2^j-1]]
vector<int> T;                  // 预处理的 2 的幂次表
```

- `A` 是二维 ST 表，`A[i][j]` 存从下标 `i` 起、长度 $2^j$ 区间的最大值。
- `T` 是递增的 2 的幂序列（$2^0,2^1,\ldots$），供 `get_h` 用二分求 $\lfloor\log_2 x\rfloor$。
- `bits/stdc++.h` 与 `using namespace std` 是竞赛常用头文件/命名空间，省去逐个声明头文件。

### 模块 2：init() — 预处理幂次表 T

```cpp
void init()
{
	for(int i = 1,k = 1;k <= 1000000000;++i,k <<= 1) T.emplace_back(k);  // 依次放入 2^0,2^1,...,2^29
}
```

- 循环变量 `k` 从 $1=2^0$ 开始，每轮左移一位翻倍，直到 $k > 10^9$ 停止。
- 上界 $10^9$ 实际压入的是 $2^0$~$2^{29}$（共 30 个元素），$2^{30} > 10^9$ 不包含；覆盖竞赛常见 N 上限，若 N 更大需同步放大此上界。
- 只执行一次，开销 $O(\log N)$，可忽略。

### 模块 3：get_h(i) — 求 $\lfloor \log_2 i \rfloor$

```cpp
int get_h(int i)
{
	int ans = lower_bound(T.begin(),T.end(),i) - T.begin();  // 找 T 中第一个 >= i 的元素下标
	if(1 << ans != i) ans -= 1;  // 若 i 不是 2 的幂，回退一层
	return ans;                  // 此时 2^ans <= i < 2^(ans+1)
}
```

- `lower_bound` 返回第一个 `>= i` 的元素下标 `ans`，此时 $T[ans]=2^{ans}$。
- 若 $2^{ans}=i$（`i` 恰为 2 的幂）则直接返回 `ans`；否则 `i` 介于 $2^{ans-1}$ 与 $2^{ans}$ 之间，`ans -= 1` 修正 off-by-one。
- 这种"先找上界再回退"只需一次二分加一次比较，复杂度 $O(\log|T|)=O(\log\log N)$，实际可视为 $O(1)$。

### 模块 4：read()/write() — 快速读写

```cpp
inline int read()
{
	int x = 0,f = 1;char ch = getchar();
	while(ch < '0' || ch > '9')   // 跳过非数字字符
	{
		if(ch == '-') f = -1;     // 处理负号
		ch = getchar();
	}
	while(ch >= '0' && ch <= '9') // 读入数字
	{
		x = x * 10 + ch - 48;
		ch = getchar();
	}
	return x * f;
}
inline void write(int x)
{
    static char buf[12];
    int p=0;
    if(x<0){putchar('-');x=-x;}
    if(x==0) buf[p++]='0';
    while(x){buf[p++]=x%10+48;x/=10;}  // 逆序存数字字符
    while(p--) putchar(buf[p]);        // 正序输出
}
```

- `read()` 用 `getchar` 逐字符读入，避免 `cin` 关闭同步前的慢速；`f` 记录负号，读到数字时 `x = x*10 + ch-48` 累加。
- `ch-48` 把数字字符转成数值（字符 `'0'` 的 ASCII 码是 48）。
- `write()` 用 `%10` 逆序把每一位存进 `buf`，再倒序输出；`x==0` 特判避免空循环漏打 `0`。
- 负号分支先输出 `-`，再对 `x` 取反后按正数处理。

### 模块 5：main() — 读入、建表与查询

```cpp
int main()
{
	init();                          // 建 T 表
	int N = read();int M = read();   // N 个数，M 次查询
	int h = get_h(N);                // h = floor(log2(N))
	A.resize(N + 1,vector<int>(h + 1));  // 二维表 (N+1) x (h+1)
	for(int i = 1;i <= N;i++) A[i][0] = read(); // j=0 层：长度1即原值
	for(int j = 1;j <= h;j++)         // 逐层递推
	{
		int k = 1 << j;               // 当前层区间长度 2^j
		int t = j - 1;                // 子区间层数
		for(int i = 1;i + k - 1 <= N;i++) A[i][j] = max(A[i][j - 1] , A[i + (1 << t)][j - 1]); // 拼接左右两半
	}
	for(int i = 1;i <= M;i++)         // 处理每次查询
	{
		int l = read();
		int r = read();
		int sz = r - l + 1;           // 区间长度
		int mh = get_h(sz);           // 最大的 k 使 2^k <= sz
		write(max(A[l][mh] , A[r - (1 << mh) + 1][mh])); // 左段从 l 起，右段到 r 结束
		putchar('\n');
	}
	return 0;
}
```

- `A.resize(N+1, vector<int>(h+1))`：行下标 1~N 用 N+1 行，列下标 0~h 用 h+1 列，少一维会越界。
- 外层循环必须枚举层级 `j`（小到大），内层枚举起点 `i`，保证 $A[i][j-1]$、$A[i+2^{j-1}][j-1]$ 先算好。
- 内层终止条件 `i + k - 1 <= N` 保证区间右端 $i+2^j-1$ 不超过 N。
- 查询先算 `sz = r - l + 1` 与 `mh = get_h(sz)`，再取左段 `A[l][mh]` 与右段 `A[r-(1<<mh)+1][mh]` 的 max，两段可重叠。

## 复杂度分析

- **时间预处理**：建表双重循环，外层 $h = \lfloor \log_2 N \rfloor$ 层，内层至多 N 个起点，总计 $O(N \log N)$。`init` 建 T 表 $O(\log N)$ 可忽略。
- **时间查询**：`get_h` 是 $O(\log |T|) = O(\log \log N)$ 的二分查找（实际极快，可视为 $O(1)$），两次数组访问 + 一次 max，整体 $O(1)$。M 次查询共 $O(M)$。
- **空间**：ST 表 A 是 `(N+1) × (h+1)` 的二维数组，共 $O(N \log N)$ 整数。T 表 $O(\log N)$ 可忽略。这是 ST 表相对线段树的主要"空间代价"。
- **为何查询 O(1) 成立**：核心是 max 运算的幂等性——$\max(x, x) = x$，因此两个子区间重叠不会影响结果。若改用求和（非幂等），重叠区域会被算两次，必须保证不重叠，则两段长度之和不能超过 sz，但 $2 \cdot 2^k > \text{sz}$（因为 $2^k > \text{sz}/2$），无法不重叠，所以 ST 表无法支持求和的 $O(1)$ 查询。

## 适用场景

- **静态 RMQ**：数组建立后不修改，需要大量区间最值查询，是 ST 表最经典的用途。
- **离线大批量查询**：M 很大、且不要求在线更新时，$O(1)$ 单次查询远胜线段树的 $O(\log n)$。
- **需要幂等运算的区间查询**：max、min、gcd、按位或、按位与等满足 $\text{op}(x,x)=x$ 的运算都可用 ST 表。
- **对常数敏感**：ST 表查询只做两次数组访问 + 一次运算，无递归、无 lazy，常数极小。

## 常见陷阱与注意事项

- **get_h 的 off-by-one 修正**：`if (1 << ans != i) ans -= 1;` 这一步不可省略。若省略，对于非 2 的幂的 `i`，会返回 $\lfloor \log_2 i \rfloor + 1$，导致查询时 $2^{\text{mh}} > \text{sz}$，下标 $r - 2^{\text{mh}} + 1$ 可能小于 `l`，逻辑错误甚至越界。
- **A 数组维度必须 (N+1) × (h+1)**：下标从 1 用到 N，所以行数 N+1；`j` 从 0 用到 `h`，所以列数 h+1。少开一维会越界。
- **建表外层是 j 不是 i**：必须先枚举长度层级 `j`（小到大），再枚举起点 `i`，保证 $A[i][j-1]$ 与 $A[i+2^{j-1}][j-1]$ 已算好。若把循环顺序写反会读到未初始化的值。
- **内层循环终止条件 `i + k - 1 <= N`**：保证区间右端 $i + 2^j - 1$ 不超过 N。若写成 `i <= N` 会越界访问。
- **查询两段可重叠**：这是 ST 表正确性的核心，但只对幂等运算成立。不要把 ST 表用于求和、积等非幂等运算。
- **不支持修改**：若数组需要动态修改，必须改用线段树或树状数组。ST 表一旦建好就是只读的。
- **T 表大小**：`init` 把 2 的幂一直填到 $10^9$，足够覆盖 $N \leq 10^9$。若 N 更大需扩大上界。
- **输入与 IO 边界**：未处理 `N=0`（空数组，`h = get_h(0) = -1` 得负维度导致越界）、`read()` 未判 EOF 会在读入失败时死循环、`write()` 对 `INT_MIN` 取负会溢出；建议约定输入满足 $N, M \ge 1$ 且数值不取 `INT_MIN`，或自行加上对应判断。

## 对比与扩展

- **与线段树对比**：ST 表查询 $O(1)$ 但不支持修改；线段树查询 $O(\log n)$ 但支持单点/区间修改。静态场景用 ST 表，动态场景用线段树。
- **与树状数组对比**：BIT 维护可减信息（如和），$O(\log n)$ 查询；ST 表维护幂等信息（如 max），$O(1)$ 查询但只静态。两者适用问题类型不同。
- **版本 2 的改进**：本版本手动建 T 表 + 二分求 log，可移植但代码长；版本 2 用 `__builtin_clz` 内建函数，一行求出 $\lfloor \log_2 x \rfloor$，代码更短、常数更小，但依赖 GCC。
- **支持任意幂等运算**：把 `max` 换成 `min`、`gcd`、`|`、`&` 即可，只要满足 $\text{op}(x, x) = x$。例如区间 gcd 查询、区间按位或查询。
- **二维 ST 表**：将 ST 表扩展到二维，$\text{st}[i][j][k_1][k_2]$ 存子矩阵的最值，预处理 $O(nm \log n \log m)$，查询 $O(1)$，但空间常数大。
- **笛卡尔树 + LCP**：把 RMQ 转化为 LCA 问题，配合笛卡尔树可在 $O(n)$ 预处理 + $O(1)$ 查询（带欧拉序 + ST 表），是更优的 RMQ 理论算法。$AKB189$, '数据结构', array['数据结构', 'ST表', 'RMQ', '倍增', '区间最值'], 'col-ds-rmq-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-st-table-2', 'ST表（标准版2 - 内建函数求对数）', $AKB190$## 算法原理

ST表（Sparse Table，稀疏表）是基于**倍增**思想（也叫 binary lifting，二进制 lifting）的静态区间查询数据结构，专门解决不可修改数组的区间最值问题（Range Minimum/Maximum Query，RMQ）。倍增的核心是：任意一个区间长度都能表示为若干个 2 的幂次之和（这其实就是二进制分解），因此只要预先算出所有"长度为 2 的幂"的区间的答案，就能在常数次拼合内回答任意长度的查询。具体地，设 $\text{st}[i][j]$ 表示从下标 `i` 开始、长度为 $2^j$ 的区间（即 $[i, i + 2^j - 1]$）的最值，则查询区间 $[l, r]$（长度 $\text{len} = r - l + 1$）时，令 $k = \lfloor \log_2 \text{len} \rfloor$，把区间拆成两段：从 `l` 起长度 $2^k$ 的左段 $[l, l + 2^k - 1]$，和到 `r` 结束长度 $2^k$ 的右段 $[r - 2^k + 1, r]$。这两段可能重叠，但重叠不影响结果——这正是 ST 表能在 $O(1)$ 完成查询的关键。

预处理用递推：$$\text{st}[i][j] = \max(\text{st}[i][j-1],\; \text{st}[i + 2^{j-1}][j-1])$$。直观理解：长度 $2^j$ 的区间可以拆成两个长度 $2^{j-1}$ 的子区间——前半 $[i, i + 2^{j-1} - 1]$ 与后半 $[i + 2^{j-1}, i + 2^j - 1]$，分别对应 $\text{st}[i][j-1]$ 和 $\text{st}[i + 2^{j-1}][j-1]$，取两者最值即得 $\text{st}[i][j]$。由于 `j` 从小到大递推，子区间的答案已经算好，整张表可在 $O(n \log n)$ 时间内建立。注意第二维 `j` 的上界是 $\lfloor \log_2 N \rfloor$，因为 $2^j$ 不能超过 N。

**为什么查询是 $O(1)$**：因为 max/min 是**幂等运算**（idempotent），即 $\max(x, x) = x$。查询时两段子区间可以重叠，重叠部分被算两次但取 max 后仍正确。这一点对和、积等非幂等运算不成立——若要求和，两段重叠区域的元素会被计算两次。所以 ST 表只适用于 max、min、gcd、按位或等幂等运算；对于求和则必须用前缀和或线段树。本版本与版本 1 的核心算法完全相同，唯一区别在于用 GCC 内建函数 `__builtin_clz` 直接在硬件层面计算 $\lfloor \log_2 x \rfloor$，省去了手动预处理幂次表 T 和 lower_bound 二分查找，代码更短、常数更小。

**`__builtin_clz` 与 $\lfloor \log_2 x \rfloor$ 的关系**：`__builtin_clz(x)` 返回 32 位无符号整数 `x` 的二进制表示中前导 0 的个数。设 `x` 的最高位的 1 位于第 $p$ 位（从 0 开始，最低位为第 0 位），则比 $p$ 高的位（第 $p+1$ 到 第 31 位）全为 0，共 $31 - p$ 个前导 0。因此 $\text{\_\_builtin\_clz}(x) = 31 - p$，于是 $31 - \text{\_\_builtin\_clz}(x) = 31 - (31 - p) = p = \lfloor \log_2 x \rfloor$。例如 $x = 6$（二进制 `110`，最高位的 1 在第 2 位），32 位下为 `0...0110`，前导 0 共 29 个，$\text{\_\_builtin\_clz}(6) = 29$，$31 - 29 = 2 = \lfloor \log_2 6 \rfloor$ ✓。这一映射在硬件层面通常被编译为单条 `BSR` 或 `LZCNT` 指令，比手动二分快得多。

## 数据结构图示

设原数组 `a = [3, 1, 4, 1, 5, 9, 2, 6]`（下标 1~8），ST 表 $\text{st}[i][j]$ 存储从 `i` 起长度 $2^j$ 区间的最大值：

```
j=0 (长度1):  st[1][0]=3  st[2][0]=1  st[3][0]=4  st[4][0]=1
              st[5][0]=5  st[6][0]=9  st[7][0]=2  st[8][0]=6

j=1 (长度2):  st[1][1]=max(3,1)=4   st[2][1]=max(1,4)=4
              st[3][1]=max(4,1)=4   st[4][1]=max(1,5)=5
              st[5][1]=max(5,9)=9   st[6][1]=max(9,2)=9
              st[7][1]=max(2,6)=6

j=2 (长度4):  st[1][2]=max(st[1][1], st[3][1])=max(4,4)=4
              st[2][2]=max(st[2][1], st[4][1])=max(4,5)=5
              st[3][2]=max(st[3][1], st[5][1])=max(4,9)=9
              st[4][2]=max(st[4][1], st[6][1])=max(5,9)=9
              st[5][2]=max(st[5][1], st[7][1])=max(9,6)=9

j=3 (长度8):  st[1][3]=max(st[1][2], st[5][2])=max(4,9)=9

表的形式（行=起点i，列=长度2^j）：
       j=0  j=1  j=2  j=3
i=1 :   3    4    4    9
i=2 :   1    4    5    -
i=3 :   4    4    9    -
i=4 :   1    5    9    -
i=5 :   5    9    9    -
i=6 :   9    9    -    -
i=7 :   2    6    -    -
i=8 :   6    -    -    -

查询 [2,7] 的最大值 (len=6, 2^k<=6 最大 k=2, 2^2=4):
  左段: st[2][2] = max[a[2..5]] = 5
  右段: st[7-4+1][2] = st[4][2] = max[a[4..7]] = 9
  ans = max(5, 9) = 9
  (两段 [2,5] 与 [4,7] 重叠 [4,5]，但 max 幂等无影响)
```

`__builtin_clz` 的位级工作示意：
```
x = 6 的 32 位表示:
位:  31 30 29 28 ... 5  4  3  2  1  0
     0  0  0  0      0  0  0  1  1  0
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^      <- 29 个前导 0 (位 31..3)
                                  ^^  <- 最高位的 1 在第 2 位

__builtin_clz(6) = 29
31 - 29 = 2  =  floor(log2(6))  ✓

x = 8 的 32 位表示:
位:  31 30 29 28 ... 4  3  2  1  0
     0  0  0  0      0  0  1  0  0
     ^^^^^^^^^^^^^^^^^^^^^^^^         <- 28 个前导 0 (位 31..4)
                              ^      <- 最高位的 1 在第 3 位

__builtin_clz(8) = 28
31 - 28 = 3  =  floor(log2(8))  ✓
```

## 核心操作详解

### get_h(i) — 求 $\lfloor \log_2 i \rfloor$（内建函数版）
```cpp
inline int get_h(int i) {
    return 31 - __builtin_clz((unsigned)i);
}
```
核心只有一行。`__builtin_clz((unsigned)i)` 计算 `i` 的 32 位无符号表示中前导 0 的个数。设 `i` 最高位的 1 在第 $p$ 位（0-indexed），则前导 0 共 $31 - p$ 个，于是 $31 - \text{\_\_builtin\_clz}(i) = 31 - (31 - p) = p = \lfloor \log_2 i \rfloor$。强转 `(unsigned)` 是为了在 `i` 为负时也按无符号位模式计算（虽然本场景 `i` 都是正数，但这是安全惯例）。相比版本 1 的 lower_bound 二分，此版本是真正的 $O(1)$ 单条指令，常数极小。注意 `__builtin_clz(0)` 的行为未定义，所以调用前必须保证 `i >= 1`。

### 建表双重循环
```cpp
for (int j = 1; j <= h; j++) {
    int k = 1 << j;          // 区间长度 2^j
    int t = j - 1;           // 上一层的 j
    for (int i = 1; i + k - 1 <= N; i++)
        A[i][j] = max(A[i][j - 1], A[i + (1 << t)][j - 1]);
}
```
与版本 1 完全一致。外层枚举区间长度层级 `j`（从小到大保证子问题已解），内层枚举起点 `i`。`A[i][j]` 由两个长度 $2^{j-1}$ 的子区间拼成：左半 $A[i][j-1]$ 覆盖 $[i, i+2^{j-1}-1]$，右半 $A[i + 2^{j-1}][j-1]$ 覆盖 $[i+2^{j-1}, i+2^j-1]$。内层循环条件 `i + k - 1 <= N` 保证区间不越界。

### 查询
```cpp
int sz = r - l + 1;
int mh = get_h(sz);
write(max(A[l][mh], A[r - (1 << mh) + 1][mh]));
```
与版本 1 完全一致。先求区间长度 `sz`，再算 $\text{mh} = \lfloor \log_2 \text{sz} \rfloor$，使得 $2^{\text{mh}} \leq \text{sz}$ 但 $2^{\text{mh}+1} > \text{sz}$。然后取两段长度均为 $2^{\text{mh}}$ 的区间：左段从 `l` 起覆盖 $[l, l+2^{\text{mh}}-1]$，右段以 `r` 结尾覆盖 $[r-2^{\text{mh}}+1, r]$。两段并集必覆盖整个 $[l, r]$（因为 $2^{\text{mh}} > \text{sz}/2$，两段各自长度过半必相交），取 max 即得答案。整个查询只做两次数组访问 + 一次 max + 一次 `__builtin_clz`，是真正的 $O(1)$。

## 逐行代码解析

### 头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<vector<int>> A;          // ST 表，A[i][j] = max[a[i..i+2^j-1]]
vector<int> T;                  // 声明但本版本未使用（保留以兼容）
```

- `A` 是 ST 表本体，`A[i][j]` 存从下标 `i` 起、长度 $2^j$ 区间的最大值；行下标用 $1..N$，列下标用 $0..h$。
- `T` 是版本 1 预处理幂次表留下的声明，本版本已完全不用（仅保留兼容），不占实际空间、可删除。

### get_h — 内建函数求 $\lfloor \log_2 i \rfloor$

```cpp
inline int get_h(int i)         // 一行求 floor(log2(i))
{
    return 31 - __builtin_clz((unsigned)i);
    // __builtin_clz 返回前导 0 个数；31-之 即最高位 1 的位置 = log2
}
```

- 核心：`__builtin_clz((unsigned)i)` 返回 32 位无符号 `i` 的前导 0 个数，`31 - 之` 即最高位 1 所在的位置 $p$，恰好等于 $\lfloor \log_2 i \rfloor$。
- 强转 `(unsigned)` 是安全惯例（即使 `i` 为负也按无符号位模式计算）；调用前必须保证 `i ≥ 1`，因为 `__builtin_clz(0)` 是未定义行为。
- 该函数通常被编译为单条 `BSR`/`LZCNT` 指令，严格 $O(1)$、常数极小（验证：x=1→0、x=6→2、x=8→3）。
- 相比版本 1 的 `init` + `lower_bound` + off-by-one 修正，无预处理、无修正；代价是依赖 GCC/Clang，MSVC 需改用 `_BitScanReverse`。

### read — 快速读入

```cpp
inline int read()               // 快速读入
{
    int x = 0,f = 1;char ch = getchar();
    while(ch < '0' || ch > '9')   // 跳过非数字
    {
        if(ch == '-') f = -1;
        ch = getchar();
    }
    while(ch >= '0' && ch <= '9') // 累加数字
    {
        x = x * 10 + ch - 48;
        ch = getchar();
    }
    return x * f;
}
```

- 第一个 `while` 跳过空白与符号，遇到 `-` 置符号位 `f = -1`，用于读取负数。
- 第二个 `while` 逐位累加，`x = x * 10 + ch - 48` 把字符数字（ASCII 码减 48）转成整数值。
- `f` 默认 1，最后 `return x * f` 统一处理正负号。

### write — 快速输出

```cpp
inline void write(int x)         // 快速输出
{
    static char buf[12];
    int p=0;
    if(x<0){putchar('-');x=-x;}
    if(x==0) buf[p++]='0';
    while(x){buf[p++]=x%10+48;x/=10;}
    while(p--) putchar(buf[p]);
}
```

- 负数先输出 `-` 再取反；`x == 0` 必须特判，否则 `while(x)` 直接跳过、什么也不输出。
- `while` 把 `x` 的各位从低位到高位逆序写入 `buf`，最后 `while(p--)` 反向输出，得到正确的数字顺序。
- `buf[12]` 足够容纳 `int` 的至多 10 位十进制 + 负号。

### main — 读入与建表

```cpp
int main()
{
    int N = read();int M = read(); // N 个数，M 次查询
    int h = get_h(N);              // h = floor(log2(N))
    A.resize(N + 1,vector<int>(h + 1)); // 二维表 (N+1) x (h+1)
    for(int i = 1;i <= N;i++) A[i][0] = read(); // j=0 层即原值
    for(int j = 1;j <= h;j++)      // 逐层递推
    {
        int k = 1 << j;            // 当前层区间长度 2^j
        int t = j - 1;             // 子区间层数
        for(int i = 1;i + k - 1 <= N;i++) // 起点遍历，保证不越界
            A[i][j] = max(A[i][j - 1] , A[i + (1 << t)][j - 1]); // 拼接左右两半 2^(j-1) 子区间
    }
```

- `h = get_h(N)` 即 $\lfloor \log_2 N \rfloor$，是第二维的上界（$2^j$ 不能超过 $N$）。
- `A.resize(N + 1, vector<int>(h + 1))`：行开 $0..N$、列开 $0..h$；列必须开到 `h` 而不是 `h-1`，否则最后一层越界。
- $j=0$ 层直接读入原值；外层先枚举长度层 `j`（小到大），保证 `A[i][j-1]` 与 `A[i+(1<<t)][j-1]` 都已算好。
- 内层终止条件 `i + k - 1 <= N`（`k = 2^j`）保证区间右端 $i + 2^j - 1$ 不越界，写成 `i <= N` 会越界。

### main — 区间查询

```cpp
    for(int i = 1;i <= M;i++)      // 处理每次查询
    {
        int l = read();
        int r = read();
        int sz = r - l + 1;         // 区间长度
        int mh = get_h(sz);         // 最大的 k 使 2^k <= sz
        write(max(A[l][mh] , A[r - (1 << mh) + 1][mh])); // 左段从 l 起，右段到 r 结束取 max
        putchar('\n');
    }
    return 0;
}
```

- `sz = r - l + 1` 是区间长度；`mh = get_h(sz)` 使 $2^{mh} \le sz$ 且 $2^{mh+1} > sz$。
- 左段 `A[l][mh]` 覆盖 $[l, l+2^{mh}-1]$，右段 `A[r-(1<<mh)+1][mh]` 覆盖 $[r-2^{mh}+1, r]$，两者并集覆盖整个 $[l,r]$。
- 两段可能重叠，但 `max` 是幂等运算（$\max(x,x)=x$），重叠不影响结果——这是查询 $O(1)$ 成立的关键。
- 单次查询只做两次数组访问 + 一次 `max` + 一次 `__builtin_clz`，严格 $O(1)$。

## 复杂度分析

- **时间预处理**：建表双重循环，外层 $h = \lfloor \log_2 N \rfloor$ 层，内层至多 N 个起点，总计 $O(N \log N)$。无 `init` 预处理步骤。
- **时间查询**：`get_h` 编译为单条 `BSR`/`LZCNT` 指令，严格 $O(1)$；两次数组访问 + 一次 max，整体 $O(1)$。M 次查询共 $O(M)$。相比版本 1 省去了 lower_bound 的 $O(\log \log N)$ 二分。
- **空间**：ST 表 A 是 `(N+1) × (h+1)` 的二维数组，共 $O(N \log N)$ 整数。虽然声明了 `vector<int> T` 但本版本未使用，不占实际空间（可删除）。
- **为何查询 O(1) 成立**：核心是 max 运算的幂等性——$\max(x, x) = x$，因此两个子区间重叠不会影响结果。若改用求和（非幂等），重叠区域会被算两次，必须保证不重叠，但 $2 \cdot 2^k > \text{sz}$（因为 $2^k > \text{sz}/2$），无法不重叠，所以 ST 表无法支持求和的 $O(1)$ 查询。

## 适用场景

- **静态 RMQ**：数组建立后不修改，需要大量区间最值查询，是 ST 表最经典的用途。
- **离线大批量查询**：M 很大、且不要求在线更新时，$O(1)$ 单次查询远胜线段树的 $O(\log n)$。
- **需要幂等运算的区间查询**：max、min、gcd、按位或、按位与等满足 $\text{op}(x,x)=x$ 的运算都可用 ST 表。
- **竞赛快速实现**：相比版本 1，本版本代码更短、常数更小，是竞赛中的首选写法（只要环境支持 GCC）。

## 常见陷阱与注意事项

- **`__builtin_clz(0)` 未定义行为**：传入 0 会导致未定义结果（部分 CPU 上 `LZCNT` 返回 32，但 `BSR` 不写结果）。本代码中 `get_h` 的调用者 `sz = r - l + 1 >= 1`、`N >= 1`，保证不会传 0；若其他场景需处理 0 必须特判。
- **强转 (unsigned) 的必要性**：若 `i` 是负数，作为 `int` 传给 `__builtin_clz` 行为依赖实现；强转 `unsigned` 后按位模式计算，结果明确。本场景 `i` 都是正数，但这是良好习惯。
- **A 数组维度必须 (N+1) × (h+1)**：下标从 1 用到 N，所以行数 N+1；`j` 从 0 用到 `h`，所以列数 h+1。少开一维会越界。
- **建表外层是 j 不是 i**：必须先枚举长度层级 `j`（小到大），再枚举起点 `i`，保证 $A[i][j-1]$ 与 $A[i+2^{j-1}][j-1]$ 已算好。若把循环顺序写反会读到未初始化的值。
- **内层循环终止条件 `i + k - 1 <= N`**：保证区间右端 $i + 2^j - 1$ 不超过 N。若写成 `i <= N` 会越界访问。
- **查询两段可重叠**：这是 ST 表正确性的核心，但只对幂等运算成立。不要把 ST 表用于求和、积等非幂等运算。
- **不支持修改**：若数组需要动态修改，必须改用线段树或树状数组。ST 表一旦建好就是只读的。
- **依赖 GCC 内建函数**：`__builtin_clz` 是 GCC/Clang 扩展，MSVC 需用 `_BitScanReverse` 替代；若需跨编译器可移植，回到版本 1 的手动表法。
- **`write` 对 `INT_MIN` 取负溢出**：`x = -x` 在 `x` 为 `-2147483648`（即 INT_MIN）时是未定义行为（其相反数无法表示为 `int`）。竞赛数据通常不会给到 INT_MIN，可假设输入合法；若需严谨可特判 INT_MIN 直接输出字符串或用 `long long` 中转。

## 对比与扩展

- **与版本 1 对比**：算法完全相同，仅 `get_h` 实现不同。版本 2 用 `__builtin_clz` 一行替代版本 1 的 `init` + `lower_bound` + off-by-one 修正，代码更短、更不易错、常数更小（单指令 vs 二分）。竞赛中优先选版本 2。
- **与线段树对比**：ST 表查询 $O(1)$ 但不支持修改；线段树查询 $O(\log n)$ 但支持单点/区间修改。静态场景用 ST 表，动态场景用线段树。
- **与树状数组对比**：BIT 维护可减信息（如和），$O(\log n)$ 查询；ST 表维护幂等信息（如 max），$O(1)$ 查询但只静态。两者适用问题类型不同。
- **支持任意幂等运算**：把 `max` 换成 `min`、`gcd`、`|`、`&` 即可，只要满足 $\text{op}(x, x) = x$。例如区间 gcd 查询、区间按位或查询。
- **相关内建函数**：`__builtin_ctz(x)` 返回末尾 0 个数（用于 lowbit 风格的算法）；`__builtin_popcount(x)` 返回 1 的个数；`__lg(x)` 直接返回 $\lfloor \log_2 x \rfloor$（GCC 提供，等价于 `31 - __builtin_clz`）。
- **二维 ST 表**：将 ST 表扩展到二维，$\text{st}[i][j][k_1][k_2]$ 存子矩阵的最值，预处理 $O(nm \log n \log m)$，查询 $O(1)$，但空间常数大。
- **笛卡尔树 + LCP**：把 RMQ 转化为 LCA 问题，配合笛卡尔树可在 $O(n)$ 预处理 + $O(1)$ 查询（带欧拉序 + ST 表），是更优的 RMQ 理论算法。$AKB190$, '数据结构', array['数据结构', 'ST表', 'RMQ', '倍增', '区间最值', '__builtin_clz'], 'col-ds-rmq-overview', null, 'knowledge'),
('Xesir', 'col-ds-trie--xesir', '字典树（Trie） · Xesir', $AKB191$## 算法原理

> 维护一个字符串集合，支持两种操作：`I x` 向集合里插入字符串 $x$；`Q x` 询问字符串 $x$ 在集合里出现了多少次。

C++ 里字符串比对是 $O(n)$ 级别（要逐字符比），所以「每次查询都遍历所有串」的暴力做法会到 $O(qn^2)$，无法接受。于是需要**字典树（Trie，前缀树）**这种能高效存储和查询字符串的结构。

字典树把若干字符串的**公共前缀合并到同一条路径**上，每条边代表一个字符，从根走到某个结点就拼出一个前缀。这样一来，插入和查询都只需要沿着目标串的字符**逐层下行**一次。

插入过程（从左到右生成一个个结点）：

1. 先建一个根结点 `root`，所有字符串都从这里出发。
2. 插入 `abc`：树里还没有任何边，直接为 `a → b → c` 建一条链，并在 `c` 打记号表示「某个串到此结束」。
3. 插入 `ab`：走到 `a`、`b` 时结点已存在，直接在 `b` 上补一个结束标记即可。
4. 插入 `ad`：`a` 已存在，只为 `a` 补一个子结点 `d`。
5. 同理依次插入 `bc`、`cab`、`cae`，每一步别忘了在结尾打标记。

查询就是「顺着字符走」：

- 查 `abc`：从根依次走到 `a → b → c`，在 `c` 处发现结束标记，判定 `abc` 存在。
- 查 `ae`：走到 `a` 后发现没有 `e` 子结点，判定不存在。
- 查 `ca`：能一路走到 `ca`，但它**没有结束标记**——这时标记就发挥作用了。只有当查询到的最后一个字符是标记结点，才算这个串真的存在；否则只能说 `ca` 是树中某串的**前缀**。

## 逐行代码解析

模板用二维数组做「孩子表」：`ti[p][c]` 表示结点 $p$ 走字符 $c$ 到达的子结点编号，`cnt[p]` 表示以结点 $p$ 结尾的字符串个数。

### 数组与索引

```cpp
int ti[100010][26],cnt[100010];int idx;
```

- `ti[p][c]` 是结点 `p` 对应字符 `c`（`c` 用 `0~25` 编码）的子结点下标；值为 `0` 表示这条边还不存在。
- `cnt[p]` 统计「以结点 `p` 结尾」的字符串个数，就是那个「结束标记」。
- `idx` 是新结点分配器，从 `0` 开始递增；`0` 号被根结点占用。

### 插入：insert

```cpp
void insert(string s) {
    int p = 0;
    for(auto i : s) {
        if(ti[p][i - 'a'] == 0) {
            ti[p][i - 'a'] = ++ idx;
        }
        p = ti[p][i - 'a'];
    }
    cnt[p] ++;
}
```

- `int p = 0;` 从根结点出发。
- 逐字符走：若这条边不存在（`ti[p][i-'a'] == 0`），就新建一个结点 `++idx` 并接上；然后 `p` 走到子结点。
- 走完整串后 `cnt[p]++`，在末尾结点打一个「字符串结尾」的标记（计数器）。

### 查询：query

```cpp
int query(string s) {
    int p = 0;
    for(auto i : s) {
        if(ti[p][i - 'a'] == 0) {
            return 0;
        }
        p = ti[p][i - 'a'];
    }
    return cnt[p];
}    
```

- 同样从根出发逐字符下行。
- 途中若某条边不存在，说明该串从未被插入，直接返回 `0`。
- 走完返回 `cnt[p]`：只有结尾结点了才是真正的「出现过」，否则 `cnt[p] == 0` 同样返回 `0`（此时该串只是某个更长串的前缀）。

### 主函数：读入与分发

```cpp
int main()
{
    int n;cin>>n;
        for(int i=1;i<=n;i++){
            char q;string x;cin>>q>>x;
            if(q=='I'){
                insert(x);
            }else{
                cout<<query(x)<<endl;
            }
        }
        
return 0;
}
```

- 读入操作数 `n`，每行读一个操作符 `q` 和一个字符串 `x`。
- `I` 走插入，`Q` 走查询并输出出现次数。

## 复杂度分析

- 单次插入 / 查询只沿字符串走一遍，时间 $O(|S|)$，$|S|$ 为串长，与集合大小无关。
- 空间 $O(\text{结点总数} \times 26)$：结点总数不超过所有串的字符数之和。
- 相比暴力的 $O(qn^2)$，字典树把每次操作降到了线性。

## 适用场景

- **字符串集合的插入 / 查询 / 计数**，尤其是大量「前缀相关」的操作（前缀计数、前缀匹配）。
- **01 字典树**：把整数按二进制位插入，求最大异或对（对应 `ds-trie-01-max-xor`）。
- **AC 自动机**的前置结构；**单词查找 / 补全**、**去重统计**等。

## 常见陷阱与注意事项

1. **忘记打结尾标记**：不打 `cnt` 就无法区分「完整串」和「只是前缀」，查询会误判。
2. **字符映射**：`i - 'a'` 只适用于小写字母；含大写、数字、空格要另设映射并调整第二维大小。
3. **数组开不够**：结点数正比于所有串的字符总数，$10^6$ 字符量级时二维数组要相应放大。
4. **根结点编号**：根固定为 `0`，新结点从 `1` 号开始，`ti` 初值 `0` 天然充当「边不存在」的哨兵。
5. **多组数据要清空**：`ti` / `cnt` / `idx` 在每组数据前都要重置，否则会串味。

## 对比与扩展

| 维度 | 字典树（Trie） | 哈希表 | 暴力比对 |
|---|---|---|---|
| 单次插入 / 查询 | $O(\|S\|)$ | 期望 $O(\|S\|)$ | $O(n\|S\|)$ |
| 前缀查询 | 天然支持 | 不支持 | 需额外判 |
| 空间 | 结点数 × 字符集 | $O(n)$ | $O(n)$ |
| 有序性 | 按字符字典序 | 无序 | 无序 |

扩展方向：**01 字典树**求最大异或；**可持久化 Trie** 支持区间异或查询；**AC 自动机**在 Trie 上建 fail 指针做多模式串匹配。$AKB191$, '数据结构', array['数据结构', '字典树', 'Trie', '字符串', '前缀'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-trie', '字典树（Trie 与 01-Trie 最大异或）', $AKB192$## 一、算法原理

### 1.1 核心思想

如果有 $n$ 个字符串需要频繁做"查询某个前缀出现了多少次"的操作，朴素做法是每次线性扫描所有字符串——$O(n \times |S|)$。字典树把这 $n$ 个字符串的**公共前缀合并到同一条路径上**，使得插入和查询都只需遍历一次目标串的字符序列。

### 1.2 定义

字典树是一棵多叉树（通常字符集为 26 个字母或更大）：

- **根节点**（本实现编号为 1）代表"空前缀"
- 每条边上标一个字符
- 从根到某节点的路径上的字符序列 = 该节点代表的字符串前缀
- 每个节点维护一个 `cnt`：**有多少个插入的字符串以此节点为前缀终点**（即经过此节点的字符串数）

### 1.3 关键性质

1. **公共前缀共享路径**：`"apple"` 和 `"app"` 共享 `a → p → p` 三层节点
2. `cnt` 的语义是"经过此节点的字符串总数"，所以查询前缀 `"app"` 返回的就是 `app` 终点的 `cnt`
3. 插入一个字符串 $s$ 时，路径上每个节点的 `cnt` 都 +1

## 二、数据结构图示

### 2.1 插入 "ab", "abc", "ab", "ac" 后的 Trie

```
           [1] root
          /   \
        a/     \a
        /       \
      [2]       [3]
      cnt=3     cnt=1
      / \         |
    b/   \c      \c
    /     \       \
  [4]     [6]     [7]
  cnt=3   cnt=0   cnt=1
  / \
c/   \(end)
/
[5]
cnt=1
```

- `root [1]`：空串，不存 `cnt`（或视为 0）
- `a [2]`：3 个字符串以 `a` 开头 → `cnt=3`（"ab", "abc", "ab"）
- `ab [4]`：3 个字符串以 `ab` 开头 → `cnt=3`
- `abc [5]`：1 个字符串以 `abc` 开头 → `cnt=1`
- `ac [7]`：1 个字符串以 `ac` 开头 → `cnt=1`

### 2.2 查询过程示例

查询 `"ab"`：`root → a(2) → b(4)`，返回 `tree_arr[4].cnt = 3`。
查询 `"ad"`：`root → a(2)`，从节点 2 找不到 `d` 的边 → 返回 0。

## 三、核心操作详解

### 3.1 insert(str) — 插入字符串

```
cur = 1 (root)
for each ch in str:
    nxt = tree_arr[cur].find(ch)   // 在 cur 的子边中找 ch
    if nxt == -1:                  // 没找到 → 新建节点
        nxt = ++idx
        tree_arr[cur].add(ch, nxt)
    tree_arr[nxt].cnt++            // 经过此节点的字符串数 +1
    cur = nxt
```

每插入一个字符，要么沿着已有边走，要么新建一条边。`cnt` 在"经过"时递增，保证查前缀时终点 `cnt` = 以该前缀开头的字符串总数。

### 3.2 find(str) — 查询前缀出现次数

```
cur = 1 (root)
for each ch in str:
    cur = tree_arr[cur].find(ch)
    if cur == -1: return 0         // 路径断了 → 前缀不存在
return tree_arr[cur].cnt           // 返回终点节点的 cnt
```

逐字符下行，任一步找不到边就返回 0；全部走完返回终点 `cnt`。

### 3.3 clear() — 清空 Trie

```
for i = idx downto 0:
    tree_arr[i].son.clear()
    tree_arr[i].cnt = 0
idx = 1                            // 重置为只有 root
```

从最高编号节点往下清，只清用过的节点（idx 以内），不遍历整个数组。重置 `idx = 1` 使 root 复活。

### 3.4 动态扩容机制

```cpp
if (idx >= tree_arr.size() - 1)
    tree_arr.insert(tree_arr.end(), new_cap, node{});
```

当节点编号逼近数组容量上限时，一次性追加 `new_cap = 128` 个空节点。批量扩容比逐个 `push_back` 更高效（减少重分配次数）。

## 四、逐行代码解析

### 4.1 node 结构

```cpp
struct node
{
	int cnt;
	unordered_map<char, int> son;
	node() :cnt(0) {}
	int find(char ch)
	{
		auto it = son.find(ch);
		return it == son.end() ? -1 : it->second;
	}
	void add(char ch, int rt) { son.emplace(ch, rt); }
};
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `int cnt;` | 经过此节点的字符串数 |
| 3 | `unordered_map<char, int> son;` | 子边映射：字符 → 子节点编号。用 `unordered_map` 而非 `int[26]`，字符集不限于小写字母，支持任意字符 |
| 4 | `node() :cnt(0) {}` | 构造函数初始化 `cnt` 为 0，`son` 默认空 |
| 5-9 | `find(ch)` | 在子边中查找字符 `ch`，找到返回子节点编号，找不到返回 -1 |
| 10 | `add(ch, rt)` | 添加一条边 `ch → rt` |

### 4.2 strtree 结构

```cpp
struct strtree
{
	int idx;
	vector<node> tree_arr;
	strtree(int big) :idx(1) { tree_arr.resize(big); }
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `int idx;` | 当前最大已分配节点编号。root 是 1，`idx` 从 1 开始 |
| 3 | `vector<node> tree_arr;` | 节点数组，下标即节点编号 |
| 4 | `strtree(int big) :idx(1) { tree_arr.resize(big); }` | 预分配 `big` 个节点空间，`idx` 从 1 开始（0 不用） |

### 4.3 insert 函数

```cpp
void insert(const string& str)
{
	int cur = 1;
	for (char ch : str)
	{
		int nxt = tree_arr[cur].find(ch);
		if (nxt == -1)
		{
			if (idx >= tree_arr.size() - 1) tree_arr.insert(tree_arr.end(), new_cap, node{});
			nxt = ++idx;
			tree_arr[cur].add(ch, nxt);
		}
		++tree_arr[nxt].cnt;
		cur = nxt;
	}
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `int cur = 1;` | 从 root 开始 |
| 4 | `int nxt = tree_arr[cur].find(ch);` | 在当前节点的子边中找 `ch` |
| 5-10 | `if (nxt == -1)` | 找不到 → 扩容检查 + 新建节点 + 添加边 |
| 6 | `if (idx >= tree_arr.size() - 1)` | 容量检查：`idx` 离数组末尾只剩 1 的余量时触发扩容 |
| 7 | `tree_arr.insert(tree_arr.end(), new_cap, node{});` | 批量追加 128 个空节点 |
| 8 | `nxt = ++idx;` | 分配新节点编号（先自增再赋值） |
| 9 | `tree_arr[cur].add(ch, nxt);` | 在当前节点添加边 |
| 12 | `++tree_arr[nxt].cnt;` | 新节点或已有节点的 `cnt` 都 +1 |
| 13 | `cur = nxt;` | 下行到子节点 |

### 4.4 find 函数

```cpp
int find(const string& str)
{
	int cur = 1;
	for (char ch : str)
	{
		cur = tree_arr[cur].find(ch);
		if (cur == -1) return 0;
	}
	return tree_arr[cur].cnt;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `int cur = 1;` | 从 root 开始 |
| 4 | `cur = tree_arr[cur].find(ch);` | 沿字符边下行 |
| 5 | `if (cur == -1) return 0;` | 任一字符找不到边 → 前缀不存在，返回 0 |
| 7 | `return tree_arr[cur].cnt;` | 走完全程 → 返回终点 `cnt` |

### 4.5 clear 函数

```cpp
void clear()
{
	for (int i = idx; i >= 0; i--)
	{
		tree_arr[i].son.clear();
		tree_arr[i].cnt = 0;
	}
	idx = 1;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 3 | `for (int i = idx; ...)` | 从最高编号往下清，只遍历用过的节点 |
| 5 | `tree_arr[i].son.clear();` | 清空子边映射 |
| 6 | `tree_arr[i].cnt = 0;` | 重置计数 |
| 8 | `idx = 1;` | 重置为只有 root 可用 |

### 4.6 main 函数

```cpp
strtree tree(sz);
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int t;
	cin >> t;
	while (t--)
	{
		int n, q;
		cin >> n >> q;
		tree.clear();
		for (int i = 1; i <= n; i++)
		{
			string str;
			cin >> str;
			tree.insert(str);
		}
		for (int i = 1; i <= q; i++)
		{
			string str;
			cin >> str;
			cout << tree.find(str) << '\n';
		}
	}
	return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `strtree tree(sz);` | 全局 Trie 对象，预分配 $10^5 + 10$ 个节点 |
| 8 | `tree.clear();` | 每组测试前清空 |
| 10-14 | 插入 $n$ 个字符串 | |
| 16-20 | 查询 $q$ 个前缀 | 输出每个前缀的出现次数 |

## 五、复杂度分析

| 操作 | 时间复杂度 | 说明 |
|------|------------|------|
| `insert(s)` | $O(\|s\|)$ | 每字符一次 `unordered_map` 查找/插入，均摊 $O(1)$ |
| `find(s)` | $O(\|s\|)$ | 每字符一次 `unordered_map` 查找 |
| `clear()` | $O(\text{节点总数})$ | 只清用过的节点 |

**空间复杂度**：$O(N \times \bar{|s|})$，其中 $N$ 为字符串总数，$\bar{|s|}$ 为平均长度。每个节点有一个 `unordered_map`，常数因子比数组版大。

**与数组版 Trie 的对比**：

| 维度 | 数组版 `int son[maxN][26]` | 本版 `unordered_map` |
|------|--------------------------|---------------------|
| 单次操作 | $O(\|s\|)$（直接下标） | $O(\|s\|)$（哈希查找） |
| 空间 | $O(\text{maxN} \times 26 \times 4)$ 字节 | $O(\text{实际节点数})$ |
| 字符集 | 固定 26 | 任意字符 |
| 常数 | 小 | 较大（哈希开销） |
| 适用场景 | 字符集小且固定 | 字符集大或不确定 |

## 六、适用场景

| 场景 | 说明 |
|------|------|
| 前缀计数 | 统计以某前缀开头的字符串个数（本代码的直接功能） |
| 字符串检索 | 判断某字符串是否在集合中（终点 `cnt > 0`） |
| 自动补全 | 找到前缀节点后遍历子树，列出所有候选词 |
| 词频统计 | 重复插入同一字符串，`cnt` 自然累加 |
| 最长公共前缀 | 两字符串在 Trie 上的公共路径长度 |
| AC 自动机 | Trie + BFS 构造 fail 指针，多模式串匹配 |

## 七、常见陷阱与注意事项

### 1. `unordered_map` 的常数因子

`unordered_map` 虽然均摊 $O(1)$，但常数比数组大 3-5 倍。如果字符集确定且小（如 26 个小写字母），改用 `int son[26]` 数组版更快。

### 2. `cnt` 的语义：是"经过"不是"终点"

本实现中 `cnt` 记录的是**经过此节点的字符串数**，不是"在此节点结束的字符串数"。如果要统计"以某字符串为完整单词的次数"，需要额外维护一个 `end_cnt` 字段，在插入结束时 +1。

### 3. clear 只清用过的节点

`clear()` 从 `idx` 往下清，不遍历整个 `tree_arr`。如果忘记重置 `idx = 1`，旧节点的残留边会污染下一组数据。

### 4. 扩容条件用 `>=` 不是 `>`

`if (idx >= tree_arr.size() - 1)` 确保在 `idx` 到达最后一个可用位置之前就扩容。如果用 `>`，当 `idx == size - 1` 时再 `++idx` 会变成 `size`，越界。

### 5. `emplace` 不会覆盖已有键

`son.emplace(ch, rt)` 在键已存在时不会更新值。由于 `find` 先于 `add` 调用，已存在的边不会走到 `add` 分支，所以没有问题。但如果重构代码时改变了调用顺序，需注意这个语义。

### 6. 全局对象 vs 局部对象

本代码的 `tree` 是全局对象，构造函数在 `main` 之前执行，预分配 $10^5 + 10$ 个 `node`。如果放局部变量且 $n$ 很大，栈空间可能不够——全局或堆分配更安全。

### 7. `unordered_map` 的迭代器稳定性

`unordered_map` 在 rehash 时迭代器失效。本代码不跨调用持有迭代器，没有问题。但如果后续扩展需要遍历子节点做 DFS，应先收集到 `vector` 再递归。

## 八、对比与扩展

### 8.1 三种 Trie 实现对比

| 维度 | 数组版 `int[26]` | `unordered_map` 版（本代码） | `map` 版 |
|------|-----------------|---------------------------|---------|
| 单次操作 | $O(\|s\|)$ | $O(\|s\|)$ | $O(\lvert s\rvert \log \lvert\Sigma\rvert)$ |
| 空间 | $O(\text{maxN} \times 26)$ | $O(\text{实际节点})$ | $O(\text{实际节点})$ |
| 字符集 | 固定 26 | 任意 | 任意（有序） |
| 常数 | 最小 | 中等 | 较大 |
| 适用 | 竞赛首选 | 字符集不确定 | 需要有序遍历 |

### 8.2 扩展方向

| 扩展 | 说明 |
|------|------|
| AC 自动机 | Trie + BFS 构造 fail 指针，支持多模式串同时匹配 |
| 可持久化 Trie | 每次插入保存历史版本，支持按版本查询前缀 |
| 01-Trie | 字符集为 $\{0, 1\}$，用于异或最值等问题 |
| Trie + 贪心 | 01-Trie 上按位贪心求最大异或和 |
| 后缀自动机 (SAM) | 更强的字符串处理结构，支持子串计数等 |

## 附：01-Trie — 最大异或和（按位贪心）

#### 1.1 问题背景

给定一个整数数组 $a_1, a_2, \ldots, a_n$，对每个查询整数 $x$，求 $\max_{i} (a_i \oplus x)$。朴素做法是对每个查询遍历所有数，复杂度 $O(nq)$，当 $n, q \ge 10^5$ 时完全不可行。

#### 1.2 核心思想：按位贪心

异或的性质是**相同为 0，不同为 1**。要让 $a_i \oplus x$ 最大，就要让高位尽可能是 1：

- 最高位如果能取到 1，**无论后面的低位是什么，都比最高位为 0 的任何情况更大**
- 这是按位贪心的正确性基础：从最高位到最低位，每一位优先选能让当前位为 1 的路径

#### 1.3 数据结构：01-Trie

把每个整数的二进制位（从最高位到最低位）依次插入一棵二叉树：

- 每个节点只有 0、1 两条边（对应二进制位的值）
- 根节点代表"没有任何位"
- 从根到叶子的路径 = 一个整数的二进制表示
- 每条路径长度固定 = 总位数（本代码用 32 位，即 int 的位数）

查询时，从最高位开始：
- 如果当前位的**相反**边存在 → 走过去，答案的这一位是 1
- 如果不存在 → 只能走相同边，这一位是 0

### 二、数据结构图示

#### 2.1 插入 5, 2, 7 后的 01-Trie（4 位示意）

5 = 0101，2 = 0010，7 = 0111（从最高位 bit3 到最低位 bit0）

```
                 [1] root
              0 /
               /
             [2]  bit3 = 0
           0 /   \ 1
            /     \
          [3]     [4]  bit2 = 0 / 1
        1 /         \ 1
         /           \
       [5]           [6]  bit1 = 1 / 1
      0/             0/ \1
      /              /   \
    [7]            [8]  [9]  bit0 = 0 / 1
     2              5     7
   (0010)         (0101) (0111)
```

三个数的二进制路径：

| 数 | 二进制 | 路径 |
|----|--------|------|
| 2 | 0010 | root → 0 → 0 → 1 → 0 |
| 5 | 0101 | root → 0 → 1 → 0 → 1 |
| 7 | 0111 | root → 0 → 1 → 1 → 1 |

> 注意：bit2 层的 0 分支（节点 3）和 1 分支（节点 4）各自往下走。节点 3 只有一条路径（对应数 2），节点 4 分出两条路径（对应数 5 和数 7）。

#### 2.2 查询 x = 6（0110）的最大异或

从最高位（bit3）开始逐位贪心：

| 位 | x 的这一位 | 期望走（相反） | 实际走 | 原因 | ans 累计 |
|----|-----------|--------------|--------|------|----------|
| 3 | 0 | 1 | 0 | root 的 1 边不存在，只能走 0 | 0 |
| 2 | 1 | 0 | 0 | 节点 2 的 0 边（节点 3）存在 ✓ | 0 + 4 = 4 |
| 1 | 1 | 0 | 1 | 节点 3 的 0 边不存在，只能走 1 | 4 |
| 0 | 0 | 1 | 0 | 节点 5 的 1 边不存在，只能走 0 | 4 |

最终 $\text{ans} = 4$，对应 $2 \oplus 6 = 0010 \oplus 0110 = 0100 = 4$ ✓

**关键直觉**：高位优先，每一位的决策都是"不可逆"的——一旦高位确定走哪条路，低位无论如何都弥补不了高位的差距。

### 三、核心操作详解

#### 3.1 insert(num) — 插入一个整数

```
cur = 1 (root)
for i = 31 downto 0:       // 从最高位到最低位
    k = (num >> i) & 1     // 取出第 i 位
    if tree[cur].son[k] == 0:
        tree[cur].son[k] = ++idx   // 不存在则新建节点
    cur = tree[cur].son[k]         // 沿边下行
```

与普通 Trie 完全类似，只是字符集只有 `{0, 1}` 两个。32 位 int，每数插入走 32 层。

#### 3.2 find(num) — 查询与 num 的最大异或值

```
cur = 1 (root)
ans = 0
for i = 31 downto 0:
    desired = 1 - ((num >> i) & 1)   // 期望走相反的位
    if tree[cur].son[desired] != 0:
        ans += (1 << i)               // 这一位能取 1，加到答案
        cur = tree[cur].son[desired]
    else:
        cur = tree[cur].son[1 - desired]  // 没有相反边，只能走相同边
return ans
```

**贪心策略**：每一位优先走**相反**的边（让异或结果的这一位为 1），没有相反边就退而求其次走相同边（这一位为 0）。

#### 3.3 为什么是 31  downto 0

`int` 是 32 位有符号整数，从最高位（第 31 位，符号位）到最低位（第 0 位）。本代码假设所有数都是非负整数，第 31 位始终为 0，但仍然从 31 开始遍历以保证统一处理。

如果题目中都是非负数，也可以从第 30 位开始（跳过符号位），节省一层。但写 31 更通用，代码也更简洁。

### 四、逐行代码解析

#### 4.1 全局定义

```cpp
const int sz = 1e5 * 31 + 10;
struct node
{
	int son[2];
	node() { son[0] = 0, son[1] = 0; }
};
node tree[sz];
int idx = 1;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `const int sz = 1e5 * 31 + 10;` | 节点总数上界：$10^5$ 个数 × 31 位（实际 32 位，但根节点 1 个，每数新增最多 32 个，所以 $10^5 \times 31 + 10$ 留有余量） |
| 2-5 | `struct node { int son[2]; ... };` | 每个节点只有 0、1 两条边，用 `int son[2]` 数组存子节点编号。0 表示"不存在" |
| 4 | `node() { son[0] = 0, son[1] = 0; }` | 构造函数初始化为 0（无儿子） |
| 6 | `node tree[sz];` | 全局节点数组 |
| 7 | `int idx = 1;` | 当前最大已分配节点编号。root 是 1，从 1 开始（0 表示"空"） |

#### 4.2 insert 函数

```cpp
void insert(int num)
{
	int cur = 1;
	for (int i = 31; i >= 0; --i)
	{
		int k = ((num >> i) & 1) ? 1 : 0;
		if (tree[cur].son[k] == 0) tree[cur].son[k] = ++idx;
		cur = tree[cur].son[k];
	}
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `int cur = 1;` | 从 root 开始 |
| 3 | `for (int i = 31; i >= 0; --i)` | 从最高位（第 31 位）到最低位（第 0 位） |
| 5 | `int k = ((num >> i) & 1) ? 1 : 0;` | 取出第 $i$ 位的值（0 或 1）。`(num >> i) & 1` 本身就是 0 或 1，三元运算符是冗余保险 |
| 6 | `if (tree[cur].son[k] == 0) tree[cur].son[k] = ++idx;` | 第 $k$ 条边不存在 → 新建节点，分配新编号 |
| 7 | `cur = tree[cur].son[k];` | 沿第 $k$ 条边下行 |

#### 4.3 find 函数

```cpp
int find(int num)
{
	int cur = 1;
	int ans = 0;
	for (int i = 31; i >= 0; --i)
	{
		int k = ((num >> i) & 1) ? 0 : 1;
		if (tree[cur].son[k] == 0) k = k ? 0 : 1;
		else ans += (1 << i);
		cur = tree[cur].son[k];
	}
	return ans;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 3 | `int ans = 0;` | 最大异或值，初始为 0 |
| 5 | `int k = ((num >> i) & 1) ? 0 : 1;` | 期望走的边 = num 第 $i$ 位的**相反值**。num 这一位是 1 就想走 0，是 0 就想走 1 |
| 6 | `if (tree[cur].son[k] == 0) k = k ? 0 : 1;` | 期望边不存在 → 翻转 $k$，只能走相同边。`k ? 0 : 1` 等价于 `1 - k` |
| 7 | `else ans += (1 << i);` | 期望边存在 → 这一位异或结果为 1，加到答案中 |
| 8 | `cur = tree[cur].son[k];` | 沿最终选择的边下行 |
| 10 | `return ans;` | 返回最大异或值 |

**第 6 行的翻转技巧**：`k = k ? 0 : 1` 是一个三元运算翻转。写成 `k = 1 - k` 更直观，效果完全相同。

#### 4.4 main 函数

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n, q;
	cin >> n >> q;
	for (int i = 1; i <= n; i++)
	{
		int x;
		cin >> x;
		insert(x);
	}
	for (int i = 1; i <= q; i++)
	{
		int x;
		cin >> x;
		cout << find(x) << '\n';
	}
	return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 5 | `int n, q;` | n 个数，q 个查询 |
| 7-11 | 插入 n 个数 | 逐个插入 01-Trie |
| 13-17 | 处理 q 个查询 | 对每个 x 输出 max(a_i ^ x) |

### 五、复杂度分析

| 操作 | 时间复杂度 | 说明 |
|------|------------|------|
| `insert(x)` | $O(31)$ | 32 位 int，每数走 32 层，每层 $O(1)$ |
| `find(x)` | $O(31)$ | 同上 |
| 总时间 | $O((n+q) \times 31)$ | 31 是常数，等价于 $O(n+q)$ |
| 空间 | $O(n \times 31)$ | 最坏每个数占 32 个新节点 |

**与朴素做法对比**：

| 方法 | 时间 | 适用场景 |
|------|------|---------|
| 朴素（暴力） | $O(nq)$ | $n, q$ 极小（如 $n, q \le 1000$） |
| 01-Trie | $O(31(n+q))$ | $n, q \le 10^5$，标准解法 |

**空间上界感受**：$n = 10^5$ 时，节点数约 $10^5 \times 31 = 3.1 \times 10^6$，每个节点 2 个 int = 8 字节，总内存约 25 MB，完全在限制内。

### 六、适用场景

| 场景 | 说明 |
|------|------|
| 最大异或对 | 数组中选两个数，使异或值最大 |
| 子数组最大异或 | 前缀异或 + 01-Trie，经典题 |
| 带插入的最大异或查询 | 动态插入元素，查询当前最大值 |
| 树上路径异或 | DFS + 01-Trie，求两点路径异或最大值 |
| 01-Trie 上合并 | 可持久化或子树合并，处理更复杂的问题 |

### 七、常见陷阱与注意事项

#### 1. 位数范围：31 还是 30

`int` 是 32 位有符号数，最高位是符号位。如果题目保证所有数都是非负整数，从第 30 位开始（共 31 位有效数据）也正确。但写 31 更通用，不会因为题目出现负数而出错——只是符号位那一层永远走 0 边，不影响结果。

#### 2. 节点编号从 1 开始，0 表示空

`son[0]` 和 `son[1]` 的初始值都是 0，0 不代表"第 0 号节点"，而是"这条边不存在"。这就是为什么 `idx` 从 1 开始——把 0 留作空标记。

#### 3. 开数组大小别忘了乘位数

`sz = 1e5 * 31 + 10` 是标准估算。如果写成 `sz = 1e5 + 10`，数组会越界 RE。经验法则：**节点数 = 元素数 × 位数**。

#### 4. 贪心的前提：高位优先

按位贪心的正确性依赖于"高位的权重大于所有低位之和"。这在二进制中天然成立（$2^i > 2^{i-1} + 2^{i-2} + \cdots + 2^0$）。如果换做其他进制（如三进制），需要确认高位权重是否仍大于低位总和。

#### 5. find 函数的"翻转"写法

`k = k ? 0 : 1` 等价于 `k = 1 - k`。两种写法都对，但 `1 - k` 更直观。代码用三元运算符是个人风格，不影响正确性。

#### 6. 不能处理负数（除非你知道自己在做什么）

如果数组中有负数，符号位（第 31 位）为 1。直接套用代码会把符号位也参与异或，结果可能不符合预期。处理负数需要特别设计（比如整体偏移 + 用 33 位等）。

#### 7. 多组测试要清空 Trie

本代码是单组测试的模板。如果有多组测试，需要像普通 Trie 那样实现 `clear()` 函数，或使用 `vector` 动态分配。全局数组不清空会导致上一组数据残留。

### 八、对比与扩展

#### 8.1 普通 Trie vs 01-Trie

| 维度 | 普通 Trie（unordered_map 版） | 01-Trie（本代码） |
|------|----------------------------|-----------------|
| 字符集 | 任意字符 | {0, 1} |
| 子边存储 | `unordered_map<char, int>` | `int son[2]` 数组 |
| 单次操作 | $O(\|S\|)$ | $O(31)$ |
| 常数 | 较大（哈希开销） | 很小（数组下标） |
| 空间 | 按需分配 | 预分配固定大小 |
| 适用 | 字符串前缀查询 | 二进制位操作、异或最值 |

#### 8.2 扩展方向

| 扩展 | 说明 |
|------|------|
| 子数组最大异或 | 前缀异或数组 + 01-Trie，经典模板题 |
| 可持久化 01-Trie | 每次插入保留历史版本，支持区间查询最大异或 |
| 树上路径异或 | DFS 记录根到各节点的异或值 + 01-Trie，求两节点路径最大异或 |
| 01-Trie + 启发式合并 | 子树合并求子树内最大异或对 |
| 带删除的 01-Trie | 每个节点加 `cnt` 计数，删除时减计数，为 0 时视为不存在 |
| 异或最小生成树 | Borůvka 算法 + 01-Trie 加速求最小异或边 |$AKB192$, '数据结构', array['数据结构', '字典树', 'Trie', '前缀树', '前缀匹配', '哈希表'], null, null, 'knowledge'),
('Xesir', 'col-ds-uf-basic--xesir', '并查集（路径压缩基础版） · Xesir', $AKB193$## 算法原理

并查集（DSU，Disjoint Set Union）是一种非常实用的数据结构，在图论里常用来判断环和连通性，比如最小生成树就离不开它。

经典模板题：

> 有 $n$ 个数，编号 $1 \sim n$，最开始每个数各自在一个集合中。要进行 $m$ 个操作，共两种：
> - `M a b`：把编号 $a$ 和 $b$ 所在的两个集合合并（若已在同一集合则忽略）；
> - `Q a b`：询问 $a$ 和 $b$ 是否在同一集合中。

一个朴素想法是直接建边，每个 `M` 就给 $a, b$ 连一条边——但这样每次 `Q` 都要遍历整个连通块，超时。

关键观察：对集合中的点来说，若 $a, b$ 在同一集合，则 `Q a b` 与 `Q a c` 等价，因此每个集合只需要找一个**代表元**即可。我们用 `h` 数组维护每个元素的「父节点」，初始时每个元素自成一个集合，父节点指向自己（`h[x] = x`）。

**怎么选代表元？** 沿着父指针一路往上找根，找到后**顺手把路径上所有点直接挂到根上**——这就是**路径压缩**，相当于把长链压成星形，之后的查询就变成 $O(1)$ 了。

## 数据结构图示

并查集的过程（以 `h` 数组表示父指针）：

```text
1) 初始：每个点自成集合        h[x] = x
   0    1    2    3

2) 合并 0,1 与 2,3            h[1]=0,  h[3]=2
   0    2
   |    |
   1    3

3) 合并 0,2                  h[2]=0（3 暂时不动）
   0
  / \
 1   2
     |
     3

4) 查 3 所在集合：h[3]=2 → h[2]=0 → h[0]=0
   确认根是 0，并把路径上的 3 直接挂到 0
```

第 4 步「查找时把沿途结点改挂到根」正是路径压缩，单次查询的均摊代价因此降得极低。

## 逐行代码解析

### 全局数组

```cpp
int h[100010],cnt[100010];
```

- `h[x]` 是 $x$ 的父节点；`h[x] == x` 时 $x$ 就是所在集合的根（代表元）。
- `cnt[x]` 记录以 $x$ 为根的集合大小，方便回答「某集合里有多少点」。

### 查找：gen（带路径压缩）

```cpp
int gen(int x){
    if(h[x]!=x){
        h[x]=gen(h[x]);
    }
    return h[x];
}
```

- 若 `h[x] != x`，说明 $x$ 不是根，递归去找它的父节点 `h[x]` 的根。
- 回溯时把结果写回 `h[x]`：这一句就是**路径压缩**，把 $x$ 直接接到根上。
- 找到根后返回 `h[x]`。函数名 `gen` 即 generate / 找根之意。

### 主函数：初始化与操作分发

```cpp
int main()
{
    int n,m;cin>>n>>m;
    for(int i=1;i<=n;i++){
        h[i]=i;cnt[i]=1;
    }
    while(m--){
        string q;int a,b;cin>>q>>a;
        if(q=="C"){
            cin>>b;
            if(gen(a)!=gen(b))cnt[gen(b)]+=cnt[gen(a)];
            h[gen(a)]=gen(b);
        }else if(q=="Q1"){
            cin>>b;
            if(gen(a)==gen(b))cout<<"Yes"<<endl;
            else cout<<"No"<<endl;
        }else{
            cout<<cnt[gen(a)]<<endl;
        }
    }
    //for(int i=1;i<=n;i++){
       // cout<<h[gen(i)]<<" "<<cnt[gen(i)]<<" "<<gen(i);
   // }
return 0;
}
```

- 初始化：`h[i]=i; cnt[i]=1;`，每个点自成一棵只含自身的树。
- `C a b`（合并）：先用 `gen(a) != gen(b)` 判断是否真的跨集合，若是则把 $a$ 所在集合的大小并到 $b$ 的根上，再令 `h[gen(a)] = gen(b)` 把 $a$ 的根挂到 $b$ 的根下。
- `Q1 a b`（询问同集合）：比较两个根的返回值，相等输出 `Yes`，否则 `No`。
- 其余分支（`Q2` 之类）输出 `cnt[gen(a)]`，即 `a` 所在集合的大小。
- 末尾那段注释掉的 `for` 是调试用的遍历输出。

## 复杂度分析

- 只做路径压缩、不按秩合并时，单次操作的均摊复杂度为 $O(\alpha(n))$，其中 $\alpha$ 是反阿克曼函数，增长极慢，实际可视为常数。
- 空间 $O(n)$，即 `h` 与 `cnt` 两个数组。
- $m$ 次操作的总额外开销可忽略，整体近似线性。

## 适用场景

- **连通性判断**：无向图两点是否连通、划分连通块。
- **Kruskal 最小生成树**：用并查集判加入某条边是否成环。
- **维护集合信息**：集合大小、合并历史；配合「带权并查集」还能维护到根的距离 / 相对关系。
- **哈希思想推广**：浮点数、字符串可以先哈希成整数再并查集（源笔记原话：思路可推广到浮点数和字符串，哈希到整数就行）。

## 常见陷阱与注意事项

1. **合并方向**：`h[gen(a)] = gen(b)` 是「把 a 的根挂到 b 的根下」；若要先合并集合大小，需在改父指针**之前**完成，顺序错了计数会丢。
2. **必须先找根再合并**：写成 `h[a] = b` 会让树退化，破坏集合结构。
3. **不带路径压缩会退化**：只按「根挂根」不压缩，链可能变长；本模板在 `gen` 里压缩了，所以即使偶尔成链也能被迅速压平。
4. **多组数据要重置**：`h` / `cnt` 每轮开头都要重新初始化成 `h[i]=i`。
5. **字符串键**：对字符串直接 `gen` 是不行的，需要先建立「字符串 → 整数」的映射。

## 对比与扩展

| 版本 | 优化手段 | 单次复杂度 |
|---|---|---|
| 基础（本条目） | 仅路径压缩 | 均摊 $O(\alpha(n))$ |
| 按秩 / 按大小合并 | 仅按秩合并 | $O(\log n)$ |
| 两者结合 | 路径压缩 + 按秩合并 | 均摊 $O(\alpha(n))$ |

扩展方向：**带权并查集**（维护相对关系，如 `ds-uf-weighted-food` 的食物链）、**扩展域并查集**（`ds-uf-extended-domain`，拆点表示关系）、以及 Kruskal 等图论应用。$AKB193$, '数据结构', array['数据结构', '并查集', '路径压缩', '连通性', '集合合并'], 'col-ds-uf-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-uf-basic', '并查集（基础 - 仅路径压缩）', $AKB194$## 算法原理

并查集（Disjoint Set Union, DSU）是一种用于维护不相交集合的数据结构，核心支持两种操作：**查找**（查询某元素属于哪个集合）和**合并**（将两个集合合为一个）。在实现上，并查集采用**森林表示法**：每个集合用一棵树表示，树根作为该集合的"代表元"。数组 `A[i]` 记录节点 `i` 的父节点，当 `A[i] == i` 时 `i` 即为根节点。初始时每个元素自成一个集合，其父节点指向自身。

**路径压缩**（Path Compression）是本实现采用的唯一优化策略。在 `find` 操作中，从待查节点沿着父指针向上追溯至根节点后，递归回溯时将路径上的每个节点直接指向根节点。这一过程使树的结构趋于扁平化——长链被压缩为星形结构。虽然单次 `find` 可能需要遍历较长的路径，但由于路径上所有节点都会被重新指向根，后续对这些节点的查询将变为 $O(1)$。这种"一次性多花时间，后续受益"的均摊思想是路径压缩高效的本质。

合并操作 `unity(a, b)` 采用最朴素策略：将 `b` 所在树的根直接指向 `a` 所在树的根，即 `A[find(b)] = find(a)`。这种写法不维护树的深度信息，可能产生退化的长链。然而由于路径压缩的存在，即使偶尔形成长链，也会在后续查询中被迅速压平。

仅使用路径压缩而不配合按秩合并时，单次操作的均摊时间复杂度为 $O(\alpha(n))$，其中 α 是反阿克曼函数——在所有实际数据规模下 $\alpha(n) \leq 4$，可视为常数。但缺少按秩合并使得常数因子略大，实测（洛谷 P3367）耗时 2.09s，而配合按秩合并版本为 1.90s。

## 数据结构图示

路径压缩前后对比——一条链被压平为星形结构：

```
压缩前（find(1) 触发）:          压缩后:

    5                              5
    |                            / | \ \ \
    4                           1  2  3 4  (全部直接指向根)
    |
    3
    |
    2
    |
    1

节点:  1 -> 2 -> 3 -> 4 -> 5     1 -> 5, 2 -> 5, 3 -> 5, 4 -> 5
A[]:   A[1]=2 A[2]=3 A[3]=4      A[1]=5 A[2]=5 A[3]=5 A[4]=5
       A[4]=5 A[5]=5              A[5]=5
```

合并操作示意：

```
合并前:                          合并后 unity(a, b):

  树A (根=a)        树B (根=b)       树 (根=a)
  a                 b               a
 / \               / \             / | \
1   2             3   4           1  2  b
                                     / \
                                    3   4

A[find(b)] = find(a)  即  A[b] = a
```

## 核心操作详解

### init(n) —— 初始化

**功能**：为 `n` 个元素各自创建独立集合。

**参数**：`n` — 元素总数。

**算法步骤**：
1. 将数组 `A` 大小调整为 `n + 1`（下标从 1 开始）。
2. 遍历 `i` 从 1 到 `n`，令 `A[i] = i`，即每个元素的父节点初始指向自身，各自成为独立集合的根。

**关键细节**：必须将每个元素初始化为自身的父节点，否则 `find` 会访问未定义的内存。

### find(i) —— 查找（带路径压缩）

**功能**：返回元素 `i` 所在集合的根节点（代表元），同时压缩查找路径。

**参数**：`i` — 待查找的元素编号。

**算法步骤**：
1. 判断 `A[i] != i`（即 `i` 不是根节点）。
2. 若不是根，递归调用 `find(A[i])` 找到根节点，并将 `A[i]` 直接更新为根节点。
3. 返回 `A[i]`（此时已是根节点）。

**关键细节**：递归实现天然完成路径压缩——递归深入时找到根，回溯时逐层将 `A[i]` 指向根。这是最简洁的写法，仅两行核心代码。

### unity(a, b) —— 合并

**功能**：将元素 `a` 和 `b` 所在的两个集合合并为一个。

**参数**：`a`、`b` — 两个元素编号。

**算法步骤**：
1. 调用 `find(b)` 获取 `b` 所在集合的根 `rb`。
2. 调用 `find(a)` 获取 `a` 所在集合的根 `ra`（注意：由于先 `find(b)`，`find(a)` 中可能触发路径压缩）。
3. 执行 `A[rb] = ra`，将 `b` 的根挂到 `a` 的根下。

**关键细节**：仅一行 `A[find(b)] = find(a)`，无按秩合并逻辑。合并方向固定为"b 的根挂到 a 的根下"，可能导致树的不平衡。

## 逐行代码解析

以下按逻辑阶段把代码拆成 5 个模块，模块代码按顺序拼接即得到完整 `.cpp`。

### 全局变量与头文件

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷P3367 时间2.09s*/
vector<int> A;
int n;
```

- `vector<int> A;`：父节点数组，`A[i]` 存储节点 `i` 的父节点编号，根节点满足 `A[i] == i`。
- `#include<bits/stdc++.h>` 与 `using namespace std;` 是竞赛常用的万能头与命名空间，省去逐个包含头文件。
- 注意：这里的全局 `int n;` 会被下方 `init(int n)` 的同名形参遮蔽，`main` 中实际使用局部变量 `N`，全局 `n` 并未被用到。

### init(n) —— 初始化

```cpp
void init(int n)
{
    A.resize(n + 1);
    for(int i = 1;i <= n;i++) A[i] = i;
}
```

- `A.resize(n + 1);`：下标从 1 开始使用，数组大小设为 `n + 1`，保证访问 `A[n]` 不越界。
- `for(int i = 1;i <= n;i++) A[i] = i;`：每个元素初始化为自身的父节点，即各自独立成集。
- 初始化是正确性前提：若 `A[i]` 未被赋值，`find` 会沿未初始化的父指针误判甚至越界。

### find(i) —— 查找（带路径压缩）

```cpp
int find(int i)
{
    if(A[i] != i)
    {
        A[i] = find(A[i]);
    }
    return A[i];
}
```

- `if(A[i] != i)`：判断当前节点是否为根；若 `A[i] == i` 则 `i` 就是根，跳过压缩直接返回。
- `A[i] = find(A[i]);`：递归查找父节点的根，回溯时把当前节点直接指向根——这是路径压缩的核心。
- `return A[i];`：返回根节点编号，此时 `A[i]` 已被压缩为根。

### unity(a, b) —— 合并

```cpp
void unity(int a,int b)
{
    A[find(b)] = find(a);
}
```

- `A[find(b)] = find(a);`：先找 `b` 的根、再找 `a` 的根，把 `b` 的根的父节点设为 `a` 的根，完成合并。
- 等号右侧的 `find(a)` 在 `find(b)` 之后求值，先执行的 `find(b)` 可能已触发路径压缩，使后续 `find(a)` 更快。
- 该写法不含按秩合并，合并方向固定为"b 的根挂到 a 的根下"，可能使树退化成长链。

### main —— 读入与处理

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int N,M;
    cin >> N >> M;
    init(N);
    for(int i = 1;i <= M;i++)
    {
        int op,a,b;
        cin >> op >> a >> b;
        if(op == 1) unity(a,b);
        else
        {
            if(find(a) == find(b)) cout << "Y" << '\n';
            else cout << "N" << '\n';
        }
    }
    return 0;
}
```

- `ios::sync_with_stdio(false);` 与 `cin.tie(nullptr); cout.tie(nullptr);` 关闭与 stdio 的同步并解绑输入输出，加速大量 `cin/cout`。
- `cin >> N >> M; init(N);` 读入元素数与操作数，并用 `N` 初始化集合。
- `for(int i = 1;i <= M;i++)`：循环处理 M 次操作，`op == 1` 走合并分支，否则走查询分支。
- `if(find(a) == find(b)) cout << "Y" << '\n'; else cout << "N" << '\n';`：两元素根相同则连通输出 `Y`，否则输出 `N`。

## 复杂度分析

- **时间复杂度**：均摊 $O(\alpha(n))$ 每次。仅使用路径压缩时，$\alpha(n)$ 为反阿克曼函数，在 $n \leq 10^{80}$ 范围内 $\alpha(n) \leq 4$，可视为常数。但缺少按秩合并，常数因子略大。实测洛谷 P3367 耗时 2.09s（对比带秩优化版 1.90s，差距约 10%）。
- **空间复杂度**：$O(n)$，仅需一个父节点数组 `A`。

## 适用场景

- 简单的连通性判断问题（如"两点是否连通"）。
- Kruskal 最小生成树算法中的环检测。
- 等价类划分问题（如等价关系的传递闭包）。
- 对常数性能要求不高的场景，或追求代码极简的竞赛题。
- 元素间无需维护额外关系（距离、权值等）的纯连通性问题。

## 常见陷阱与注意事项

- **忘记初始化**：必须确保 `init` 中将每个元素设为自身的父节点。若使用全局数组且未初始化，`A[i]` 默认为 0，`find` 会死循环或越界。
- **find 必须递归或用循环模拟路径压缩**：仅查找不压缩的朴素并查集退化为 $O(n)$ 链。
- **合并前无需检查是否同集**：`unity` 中即使 `a` 和 `b` 已在同一集合，执行 `A[find(b)] = find(a)` 也只是让根指向自身，无害但浪费一次 find。
- **数组大小**：下标从 1 开始时数组大小至少为 `n + 1`，避免越界。
- **递归深度与栈溢出**：无按秩合并时，链式合并可能使树退化成长链，`find` 的递归深度达到 $O(n)$，在大规模数据下有栈溢出风险；建议配合按秩合并、改用迭代实现 `find`，或增大递归栈空间。

## 对比与扩展

- **基础版 vs 带秩优化版**：基础版代码更简洁（unity 仅一行），但缺少按秩合并导致树可能退化。带秩优化版增加 `rt` 数组维护树高近似值，合并时将矮树挂到高树下，实测提速约 10%（2.09s → 1.90s）。竞赛中通常直接使用带秩版本，性能更稳定。
- **扩展方向**：
  - **带权并查集**：在 `A[]` 之外维护 `d[]` 或 `k[]` 数组记录节点到根的权值/距离，支持关系推理。
  - **扩展域并查集**：将每个元素拆分为多个"域"以处理对立关系（如敌人的敌人是朋友）。
  - **可撤销并查集（Rollback DSU）**：不使用路径压缩（改为按秩合并），支持撤销最近的合并操作，用于回溯场景。
  - **DSU on Tree**：利用轻重链剖分在树上做离线统计，常用于子树查询问题。$AKB194$, '数据结构', array['数据结构', '并查集', '路径压缩', '连通性'], 'col-ds-uf-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-uf-extended-domain', '扩展域并查集（P1892）', $AKB195$## 算法原理

扩展域并查集（又称种类并查集）通过将每个元素拆分为多个"域"来处理多种对立关系。本题（洛谷 P1892 / 团伙）中，N 个人之间存在两种关系：朋友（F）和敌人（E）。朋友关系具有传递性（朋友的朋友是朋友），敌人关系满足"敌人的敌人是朋友"。最终需要统计有多少个独立的团伙。

**核心思想——域的拆分**：为每个元素 `i` 分配两个域：**自身域** `i`（下标 1 到 n）和**敌人域** `i + n`（下标 n+1 到 2n）。自身域代表"这个人本身"，敌人域代表"这个人的敌人集合"。数组大小为 2n，是普通并查集的两倍。

**朋友操作**：当 `p` 和 `q` 是朋友时，直接合并两者的自身域：`unity(p, q)`。这表示 p 和 q 属于同一团伙，符合朋友关系的传递性。

**敌人操作**：当 `p` 和 `q` 是敌人时，需要执行两次合并：`unity(p, q + n)` 和 `unity(q, p + n)`。第一次合并表示"p 与 q 的敌人是朋友"（即 p 和 q 的敌人属于同一团伙）；第二次合并表示"q 与 p 的敌人是朋友"（对称性）。这两次合并共同编码了"敌人的敌人是朋友"的逻辑——若 A 是 B 的敌人，B 是 C 的敌人，则 A 和 C 通过各自的敌人域被间接关联到同一团伙。

**为什么需要两次对称合并**：敌对关系是双向的——A 敌视 B 意味着 B 也敌视 A。仅执行 `unity(p, q+n)` 而不执行 `unity(q, p+n)` 会导致不对称：p 知道自己的敌人包括 q 的团伙，但 q 不知道自己的敌人包括 p 的团伙。后续若有第三个元素 r 与 q 是敌人，r 需要通过 `unity(r, q+n)` 与 p 建立间接联系，但如果只做了一半的合并，这种传递可能断裂。

**统计团伙数量**：处理完所有关系后，遍历下标 1 到 n（仅自身域），统计满足 $A[i] = i$（即 i 是根节点）的元素个数。每个根节点代表一个独立的团伙。

## 数据结构图示

2n 数组布局——每个元素拆为自身域和敌人域：

```
下标:   1    2    3   ...   n  | n+1  n+2  n+3  ...  2n
        |---- 自身域 -------| |-- 敌人域 -----------|
         1    2    3         1+n  2+n  3+n
        自身  自身  自身       敌人  敌人  敌人

元素 i 的自身域:  i        (1 <= i <= n)
元素 i 的敌人域:  i + n    (n+1 <= i+n <= 2n)
```

朋友操作 `unity(p, q)`：

```
合并前:  p (自身域)     q (自身域)     p+n (敌人域)    q+n (敌人域)
         各自独立

合并后:  p --- q  (同一团伙)
         p+n    q+n  (敌人域不受影响)
```

敌人操作 `unity(p, q+n)` + `unity(q, p+n)`：

```
合并前:  p (自身域)     q (自身域)     p+n (敌人域)    q+n (敌人域)
         各自独立

合并后:  p --- q+n     q --- p+n
         (p 与 q的敌人 同团)  (q 与 p的敌人 同团)

传递效果: 若 A敌B, B敌C, 则:
  第1步: unity(A,B+n), unity(B,A+n)  -> A与B+n同团, B与A+n同团
  第2步: unity(B,C+n), unity(C,B+n)  -> B与C+n同团, C与B+n同团
  推导:  A与B+n同团, C与B+n同团 => A与C同团 (敌人的敌人是朋友!)
```

## 核心操作详解

### init(n) —— 初始化

**功能**：为 `n` 个元素各自创建独立集合，包括自身域和敌人域。

**参数**：`n` — 元素（人）总数。

**算法步骤**：
1. 将数组 `A` 大小调整为 `n * 2 + 1`（下标 1 到 2n）。
2. 遍历 `i` 从 1 到 `n * 2`，令 $A[i] = i$——所有自身域和敌人域初始化为独立集合。

**关键细节**：数组大小必须是 **2n**，而非 n。下标 1 到 n 为自身域，n+1 到 2n 为敌人域。若数组大小不足，敌人域操作会越界。

### find(i) —— 查找

**功能**：返回元素 `i` 所在集合的根节点。

**参数**：`i` — 待查找的元素编号（可为自身域或敌人域下标）。

**算法步骤**：
1. 判断 $A[i] = i$（是否为根）。
2. 若是根，返回 `i`。
3. 若不是根，递归调用 `find(A[i])` 返回根节点。

**关键细节**：本实现使用**不带路径压缩**的朴素递归查找。对于本题 N ≤ 1000 的规模，朴素查找已足够快。若 N 较大，应改为带路径压缩版本 `return A[i] == i ? i : A[i] = find(A[i]);` 以保证 $O(\alpha(n))$ 的均摊复杂度。

### unity(a, b) —— 合并

**功能**：将元素 `a` 和 `b` 所在的集合合并为一个。

**参数**：`a`、`b` — 两个元素编号（可为自身域或敌人域下标）。

**算法步骤**：
1. 调用 `find(b)` 获取 `b` 所在集合的根。
2. 调用 `find(a)` 获取 `a` 所在集合的根。
3. 执行 $A[\text{find}(b)] = \text{find}(a)$——将 `b` 的根挂到 `a` 的根下。

**关键细节**：与基础并查集的 unity 完全相同。合并方向为"b 的根挂到 a 的根下"，无按秩合并。关键在于调用时传入的下标——朋友操作传入自身域下标，敌人操作传入交叉的域下标。

## 逐行代码解析

下面按函数与逻辑阶段把代码拆成 5 个模块，各模块按顺序拼接即得完整 `.cpp`（仅新增 `//` 行尾注释，注释与空白不影响代码）。

### 模块一：头文件与全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷1892*/
vector<int> A;
```

- 要点 1：`vector<int> A;` 是父节点数组，后续在 `init` 里被调整为 `2n+1` 大小，同时容纳自身域（下标 1~n）和敌人域（下标 n+1~2n）。
- 要点 2：用 `vector` 而非定长数组，是为了按实际人数 `n` 动态分配 `2n+1` 的空间，避免数组大小写死。
- 要点 3：`/*洛谷1892*/` 是题源标记注释，不参与运行。

### 模块二：init(n) 初始化

```cpp
void init(int n)
{
    A.resize(n * 2 + 1);
    for(int i = 1;i <= n * 2;i++) A[i] = i;
}
```

- 要点 1：`A.resize(n * 2 + 1);` 是**关键**——数组大小必须为 `n * 2 + 1`，为 n 个自身域 + n 个敌人域共 2n 个元素预留空间（下标 1~2n 有效，下标 0 闲置）。
- 要点 2：`for(int i = 1;i <= n * 2;i++) A[i] = i;` 初始化 1 到 2n 的所有元素为自身父节点，自身域与敌人域一开始都各自独立成集。
- 要点 3：循环上界是 `n * 2` 而不是 `n`——若只初始化到 n，敌人域下标 n+1~2n 的 `A[i]` 未被赋值，后续 `find` 会读到错误值。

### 模块三：find(i) 查找

```cpp
int find(int i)
{
    return A[i] == i ? i : find(A[i]);
}
```

- 要点 1：朴素递归查找——`A[i] == i` 说明 i 就是根，直接返回；否则沿父指针 `A[i]` 递归向上找根。
- 要点 2：三元运算符简洁表达"是根则返回，否则递归找根"，等价于 `if(A[i]==i) return i; else return find(A[i]);`。
- 要点 3：本实现**不带路径压缩**，最坏单次 $O(n)$。对 N ≤ 1000 的本题足够；大规模数据建议改为 `return A[i] == i ? i : A[i] = find(A[i]);` 以获得 $O(\alpha(n))$ 均摊复杂度。

### 模块四：unity(a, b) 合并

```cpp
void unity(int a,int b)
{
    A[find(b)] = find(a);
}
```

- 要点 1：标准合并——先取 `find(b)` 得到 b 所在集合的根，再取 `find(a)` 得到 a 的根，把 b 的根挂到 a 的根下。
- 要点 2：赋值方向固定为 `A[find(b)] = find(a)`（b 挂到 a 下），与基础并查集完全相同；真正决定"合并哪两个域"的是调用方传入的下标。
- 要点 3：无按秩合并，合并方向固定，树可能退化成链；本题规模下不影响正确性。

### 模块五：main 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n,m;
    cin >> n >> m;
    init(n);
    for(int i = 0;i < m;i++)
    {
        char op;
        int p,q;
        cin >> op >> p >> q;
        if(op == 'F') unity(p,q);
        else
        {
            unity(p,q + n);
            unity(q,p + n);
        }
    }
    int ans = 0;
    for(int i = 1;i <= n;i++) if(i == A[i]) ++ans;
    cout << ans;
    return 0;
}
```

- 要点 1：`if(op == 'F') unity(p,q);` 是**朋友操作**——直接合并两个自身域，表示 p 和 q 属于同一团伙，符合朋友关系的传递性。
- 要点 2：`unity(p,q + n);` 是**敌人操作第一步**——合并 p 的自身域与 q 的敌人域，表示"p 与 q 的敌人是朋友"。
- 要点 3：`unity(q,p + n);` 是**敌人操作第二步**——合并 q 的自身域与 p 的敌人域，表示"q 与 p 的敌人是朋友"。这两步必须同时执行，才能保证敌对关系的对称性。
- 要点 4：`for(int i = 1;i <= n;i++) if(i == A[i]) ++ans;` 是**统计团伙数**——只遍历自身域（1 到 n），统计根节点个数；不能遍历到 2n，否则敌人域中的根会被误算成独立团伙。这里直接检查 `A[i] == i` 即能正确识别根；更严谨的写法是 `if(find(i) == i)`。

## 复杂度分析

- **时间复杂度**：本实现使用朴素 find（无路径压缩、无按秩合并），单次查找最坏 $O(n)$，总时间 $O(mn)$。对于 N ≤ 1000 的本题足够。若改用路径压缩，则均摊 $O(\alpha(n))$ 每次，总时间 $O(m \cdot \alpha(n))$。
- **空间复杂度**：$O(2n) = O(n)$。数组大小为 2n+1，是普通并查集的两倍——每个元素需要自身域和敌人域两个位置。

## 适用场景

- **团伙/阵营问题**：元素间存在朋友和敌人两种对立关系，需要统计独立团伙数量（如 P1892 团伙）。
- **关押罪犯（P1525）**：二分图判定问题，将罪犯的对立关系用扩展域编码，二分答案后检查可行性。
- **食物链的替代解法**：食物链问题（P2024）也可用 3 个域（自身、猎物、天敌）的扩展域并查集解决，数组大小 3n。
- **二元关系传递问题**：任何"非此即彼"的二元关系（如黑白染色、正反阵营），都可以用 2 域扩展域并查集处理。
- **矛盾检测**：当"敌人的敌人是朋友"这一约束被违反时，可以通过检查同一域内是否有矛盾来检测。

## 常见陷阱与注意事项

- **数组大小必须为 2n**：最常见的错误是数组只开 n+1，导致敌人域操作 `unity(p, q+n)` 越界。数组大小必须至少为 `2n + 1`。
- **敌人操作必须对称**：必须同时执行 `unity(p, q+n)` 和 `unity(q, p+n)`。只做一个方向会导致不对称——p 知道自己的敌人但 q 不知道，后续传递关系可能断裂。
- **统计时只看自身域**：最终统计团伙数时，只遍历下标 1 到 n（自身域），不能遍历到 2n——敌人域中的根节点不代表独立团伙。
- **find 未做路径压缩**：本实现的 find 是朴素递归，大规模数据下可能 TLE。建议改为带路径压缩版本：`return A[i] == i ? i : A[i] = find(A[i]);`。
- **统计根节点时应先 find**：代码中 `if(i == A[i])` 直接检查 `A[i]`，在有路径压缩时可能不准确（因为某些中间节点的 `A[i]` 未更新）。更安全的写法是 `if(find(i) == i)`。
- **域的语义一致性**：扩展到 k 个域时（如食物链的 3 域），需确保每个域的语义定义一致——域 0 = 自身，域 1 = 猎物，域 2 = 天敌等，不能混用。

## 对比与扩展

- **扩展域 vs 带权并查集**：两者都能解决食物链等关系推理问题。扩展域通过"空间换逻辑"——将关系编码为不同的数组下标（2n 或 3n 数组），代码直观但空间更大。带权并查集通过"权值编码"——用一个额外的 `d[]` 数组记录关系（模 k），代码紧凑但需要推导权值公式。对于二元关系（敌/友），扩展域更直观；对于多元循环关系（食物链的 3 类），带权更紧凑。
- **扩展域 vs 基础并查集**：基础并查集只能处理"同/不同集合"的二元连通性。扩展域通过虚拟节点（敌人域）将对立关系转化为连通性问题，功能更强但空间翻倍。
- **扩展方向**：
  - **k 域扩展域并查集**：将 2 域推广到 k 域，处理 k 类关系。如食物链可用 3 域（n 自身、2n 猎物、3n 天敌），数组大小 3n。
  - **带权 + 扩展域混合**：某些复杂问题可能同时需要权值和域拆分。
  - **可撤销扩展域并查集**：不使用路径压缩（改为按秩合并），支持回溯操作。用于需要回退关系加入的场景。
  - **线段树分治 + 扩展域**：在时间维度上分治处理"某时间段内的关系是否矛盾"。$AKB195$, '数据结构', array['数据结构', '并查集', '扩展域并查集', '敌对关系', '团伙问题'], 'col-ds-uf-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-uf-overview', '并查集总览（基础 / 按秩 / 扩展域 / 带权）', $AKB196$## 算法原理

本页是「并查集」的二级栏目索引，把基础实现、按秩合并、扩展域与带权并查集收在同一入口下，具体推导与代码分别在各子页。

**学习顺序**：先看「并查集（基础）」掌握 `find` / `union` 与路径压缩；再补「按秩优化」理解复杂度；最后按题型选「扩展域」或「带权」。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 用哪篇 |
|---|---|
| 只维护连通性（朋友关系） | 并查集（基础 - 仅路径压缩） |
| 想控制树高、保证复杂度 | 并查集（带秩优化） |
| 敌人的敌人是朋友、种类关系 | 扩展域并查集（P1892） |
| 边权/相对关系可累加 | 带权并查集（食物链 P2024） |
| 带权并查集的另一道模板 | 带权并查集（蓝桥杯 1156） |

## 逐行代码解析

本页是索引入口，不重复贴代码；每个子页都给出了对应实现的逐行解析与完整 `.cpp`。

## 复杂度分析

按子条目而定：基础并查集配合路径压缩为均摊 $O(\log n)$；再配合按秩（启发式合并）可降到均摊 $O(\alpha(n))$。

## 适用场景

- 动态连通性维护、Kruskal 求最小生成树
- 关系推理（敌人/朋友、种类并查集）
- 带权路径上的相对量维护（食物链、蓝桥 1156）

## 常见陷阱与注意事项

- 只写路径压缩、不写按秩合并时，不能声称复杂度是 $O(\alpha(n))$。
- 扩展域并查集要开双倍或三倍点，别把 `i` 与 `i+n` 写混。
- 带权并查集的边权在路径压缩时要同步累加，`find` 里不能只改父指针。
- 多组数据记得重置 `fa` 与 `d` 数组。
- 递归 `find` 在链很长时有栈风险，必要时改迭代。

## 对比与扩展

- 与 DFS/BFS 求连通块相比，并查集支持在线加边。
- 与「种类并查集」相比，扩展域是更通用的建模方式。
- 可扩展到可撤销并查集（按秩合并、不能路径压缩）与可持久化并查集。$AKB196$, '数据结构', array['并查集', '总览', '学习路线', '路径压缩', '带权并查集'], null, null, 'knowledge'),
('world-needs-sunday', 'col-ds-uf-rank', '并查集（带秩优化）', $AKB197$## 算法原理

并查集（Disjoint Set Union, DSU）用于维护不相交集合的合并与查询。本实现在基础路径压缩之上额外引入**按秩合并**（Union by Rank）优化，两者结合使单次操作的时间复杂度达到理论最优的 $O(\alpha(n))$。

**秩（Rank）**是对树高的一种近似度量。严格来说，秩并非树的真实高度——因为路径压缩会不断降低树高，而 `rt` 数组中的秩值不会因路径压缩而减小。秩更准确的含义是"如果不进行路径压缩，这棵树的高度上界"。初始时每个节点秩为 1，合并时将秩较小的树挂到秩较大的树下。当两棵树秩相等时，任选一棵作为新根，其秩加 1。这一策略保证树的秩始终不低于真实高度，从而控制树的深度增长极其缓慢。

**路径压缩 + 按秩合并的协同效应**是并查集性能的核心。单独使用路径压缩时，合并方向随机可能导致长链，虽然查询时会被压缩，但首次查询代价较高。加入按秩合并后，树的高度被严格控制在 $O(\log n)$ 以内，即使没有路径压缩，单次查询也只需 $O(\log n)$。两种优化叠加后，单次操作的均摊复杂度降至 $O(\alpha(n))$，其中 α 为反阿克曼函数——对于任何实际数据规模（$n \leq 10^{80}$），$\alpha(n) \leq 4$，本质上已是常数时间。

**反阿克曼函数的来源**可以这样直观理解：按秩合并保证树高至多为 $O(\log n)$，路径压缩在每次查询后将路径压平。两者的交互使得树高增长极其缓慢——要使树高增加 1，需要指数级的合并操作。这种"双层防护"使得 $\alpha(n)$ 增长比 $\log^* n$ 还要慢。实测洛谷 P3367 耗时 1.90s，比纯路径压缩版（2.09s）快约 10%。

## 数据结构图示

按秩合并示例（两棵秩不同的树合并）：

```
合并前:                          合并后 (rt[ra]=3 > rt[rb]=2):

  树A (根=ra, rt=3)    树B (根=rb, rt=2)      树 (根=ra, rt=3 不变)
      ra                     rb                     ra
     / | \                  / \                   / | \ \
    1  2  3                4   5                 1 2 3 rb
                                                    / \
                                                   4   5
  矮树(rb)挂到高树(ra)下，ra的秩不变
```

两棵秩相同的树合并（秩各增 1）：

```
合并前:                          合并后 (rt[ra]=rt[rb]=2):

  树A (根=ra, rt=2)    树B (根=rb, rt=2)       树 (根=ra, rt=3)
      ra                     rb                     ra
     / \                    / \                   / | \
    1   2                  3   4                 1  2 rb
                                               / \
                                              3   4
  rb挂到ra下，ra的秩 +1 变为 3
```

路径压缩 + 按秩合并的协同效果：

```
初始链: 1->2->3->4->5->6 (rt[6]=6, 无按秩合并时可能出现)

经find(1)路径压缩后:
        6
     / | | | \
     1 2 3 4 5   (所有节点直接指向根)

若有按秩合并，初始就不太可能形成这样的长链
```

## 核心操作详解

### init(n) —— 初始化

**功能**：为 `n` 个元素各自创建独立集合，并初始化秩数组。

**参数**：`n` — 元素总数。

**算法步骤**：
1. 将数组 `A` 大小调整为 `n + 1`，`rt` 大小调整为 `n + 1` 并初始化为 1。
2. 遍历 `i` 从 1 到 `n`，令 `A[i] = i`，每个元素自成独立集合。

**关键细节**：`rt` 数组必须初始化为 1（表示初始每棵"树"高度为 1）。若初始化为 0，会导致秩比较逻辑失效——两棵秩为 0 的树合并后秩仍为 1，与初始值不一致。

### find(i) —— 查找（带路径压缩）

**功能**：返回元素 `i` 所在集合的根节点，同时压缩查找路径。

**参数**：`i` — 待查找的元素编号。

**算法步骤**：
1. 判断 `A[i] != i`（即 `i` 不是根节点）。
2. 若不是根，递归调用 `find(A[i])` 找到根节点，并将 `A[i]` 直接更新为根节点。
3. 返回 `A[i]`（此时已是根节点）。

**关键细节**：与基础版完全相同的递归路径压缩实现。路径压缩不更新 `rt` 值——这是有意为之，因为 `rt` 是树高的上界近似，保持其值不变不影响正确性，反而简化了实现。

### unity(a, b) —— 合并（按秩）

**功能**：按秩合并元素 `a` 和 `b` 所在的两个集合。

**参数**：`a`、`b` — 两个元素编号。

**算法步骤**：
1. 调用 `find(a)` 和 `find(b)` 分别获取两棵树的根 `ra` 和 `rb`。
2. 若 `ra == rb`（已在同一集合），直接返回。
3. 比较两棵树的秩 `rt[ra]` 和 `rt[rb]`：
   - 若 `rt[ra] > rt[rb]`：将 `rb` 挂到 `ra` 下（`A[rb] = ra`），`ra` 的秩不变。
   - 若 `rt[ra] < rt[rb]`：将 `ra` 挂到 `rb` 下（`A[ra] = rb`），`rb` 的秩不变。
   - 若 `rt[ra] == rt[rb]`：任选一棵作为新根（本实现选择 `A[rb] = ra`），被挂向的树 `ra` 的秩加 1（`++rt[ra]`）。

**关键细节**：秩的比较必须使用根节点的秩（`rt[ra]` 和 `rt[rb]`），而非原始元素的秩。秩相等时才增加——因为两棵等高树合并后高度必增 1，而矮树挂高树不改变高树的高度。

## 逐行代码解析

### 全局变量

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷P3367 时间1.90s*/
vector<int> A;
vector<int> rt;
int n;
```

- `A` 是父节点数组，`A[i]` 指向 `i` 的父节点；根节点的 `A[i] == i`。
- `rt` 是秩数组，`rt[i]` 记录以 `i` 为根的树的秩（未经路径压缩时的树高上界），非根节点的 `rt` 值无意义。
- 全局 `int n;` 从未被使用（见下方 `init` 形参说明），是遗留的死代码。

### init(n) —— 初始化

```cpp
void init(int n)
{
    A.resize(n + 1);
    rt.resize(n + 1,1);
    for(int i = 1;i <= n;i++) A[i] = i;
}
```

- `A.resize(n + 1)` / `rt.resize(n + 1,1)`：开 `n + 1` 格，只使用下标 `1..n`（0 号位废弃），与元素从 1 编号对应。
- `rt.resize(n + 1,1)`：秩初始化为 1。每个元素初始为独立单节点树，高度为 1；若初始化为 0，会让秩比较逻辑失去一致性。
- `for(int i = 1;i <= n;i++) A[i] = i;`：遍历 `1..n`，令每个元素父节点指向自己，各自独立成集合。
- 这里的 `n` 是形参（实参为 `main` 里的 `N`），遮蔽了全局 `int n;`——全局那个因此成了死代码。

### find(i) —— 查找（带路径压缩）

```cpp
int find(int i)
{
    if(A[i] != i)
    {
        A[i] = find(A[i]);
    }
    return A[i];
}
```

- `if(A[i] != i)`：判断 `i` 是否为根节点；不是根才继续。
- `A[i] = find(A[i]);`：递归找到根，并把 `i` 的父节点直接更新为根（路径压缩）。
- `return A[i];`：返回时 `A[i]` 已是根节点。
- 路径压缩不更新 `rt`：这是刻意为之，`rt` 是"未经路径压缩时的树高上界"，保持不变不影响正确性。

### unity(a, b) —— 合并（按秩）

```cpp
void unity(int a,int b)
{
    int ra = find(a);
    int rb = find(b);
    if(ra == rb) return;
    if(rt[ra] != rt[rb])
    {
        if(rt[ra] > rt[rb]) A[rb] = ra;
        else A[ra] = rb;
    }
    else
    {
        A[rb] = ra;
        ++rt[ra];
    }
}
```

- `int ra = find(a); int rb = find(b);`：先分别找到两棵树的根，注意两个 `find` 调用都会触发路径压缩。
- `if(ra == rb) return;`：已在同一集合则无需合并，避免自环（`A[root] = root` 虽无害但浪费）。
- 秩不同（`if(rt[ra] != rt[rb])`）：`rt[ra] > rt[rb]` 时把 `rb` 挂到 `ra` 下，否则把 `ra` 挂到 `rb` 下；矮树挂高树，高树的秩不变。
- 秩相等（`else`）：把 `rb` 挂到 `ra` 下并 `++rt[ra]`——两棵等高树合并后新树高度必 +1。

### main —— 读入与回答

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int N,M;
    cin >> N >> M;
    init(N);
    for(int i = 1;i <= M;i++)
    {
        int op,a,b;
        cin >> op >> a >> b;
        if(op == 1) unity(a,b);
        else
        {
            if(find(a) == find(b)) cout << "Y" << '\n';
            else cout << "N" << '\n';
        }
    }
    return 0;
}
```

- `ios::sync_with_stdio(false)` 与 `cin.tie(nullptr); cout.tie(nullptr);`：关闭与 C 标准 IO 的同步、解绑 cin/cout，加速输入输出。
- 读入 `N` 个元素、`M` 次操作后，`init(N)` 初始化 `1..N`。
- `for(int i = 1;i <= M;i++)`：循环处理 `M` 次操作。
- `op == 1` 时合并 `a`、`b`；否则查询两者是否同根，输出 `Y` / `N`。

## 复杂度分析

- **时间复杂度**：$O(\alpha(n))$ 每次。路径压缩 + 按秩合并共同保证单次均摊操作为反阿克曼函数时间。$\alpha(n) \leq 4$ for $n \leq 10^{80}$，可视为常数。实测洛谷 P3367 耗时 1.90s（比纯路径压缩版 2.09s 快约 10%）。
- **空间复杂度**：$O(n)$，需要两个数组 `A`（父节点）和 `rt`（秩），各 $O(n)$。

## 适用场景

- 连通性判断（如图的连通分量计数）。
- Kruskal 最小生成树算法中的环检测——需要在排序的边集上反复合并，按秩合并保证效率稳定。
- 动态连通性问题（如离线处理的网络连通性）。
- 等价关系判定与等价类合并。
- 需要频繁合并且对常数敏感的场合（比基础版更推荐）。
- 作为更高级并查集（带权、扩展域）的基础框架。

## 常见陷阱与注意事项

- **rt 必须初始化为 1（或非零值）**：若初始化为 0，两棵初始秩为 0 的树合并后秩变为 1，但后续新元素仍是 0，秩比较逻辑不一致。标准做法是初始化为 1。
- **秩比较必须用根节点的秩**：`rt[ra]` 和 `rt[rb]`，而非 `rt[a]` 和 `rt[b]`。非根节点的 `rt` 值是过时的，不代表当前树高。
- **路径压缩不更新 rt**：这是正确的做法。`rt` 是"未经路径压缩时的树高上界"，保持不变不影响合并的正确性——它只是可能略微高估树高，但这只会让合并更保守，不影响渐近复杂度。
- **合并前检查是否同集**：`if(ra == rb) return;` 虽非必需（不检查也只是 `A[root] = root`），但避免无意义操作，且在带权并查集中若不检查会导致权值更新错误。

## 对比与扩展

- **基础版 vs 带秩优化版**：基础版 `unity` 仅一行 `A[find(b)] = find(a)`，代码极简但不控制树高。带秩版增加 `rt` 数组和条件判断，代码稍长但树高受控，性能提升约 10%（2.09s → 1.90s）。竞赛中推荐直接使用带秩版本。
- **按秩合并 vs 按大小合并**：按大小（将小集合挂到大集合下）也能保证 $O(\alpha(n))$ 的均摊复杂度，且实现更简单（`sz[ra] > sz[rb]` 比较）。两种方式渐近复杂度相同，常数差异可忽略。
- **扩展方向**：
  - **带权并查集**：在 `A[]` 和 `rt[]` 之外增加 `d[]` 或 `k[]` 数组，维护节点到根的权值/距离，支持关系推理（如食物链、排队距离等）。
  - **扩展域并查集**：将每个元素拆为多个域，处理对立关系。
  - **可撤销并查集（Rollback DSU）**：放弃路径压缩（只用按秩合并），使操作可逆。按秩合并不改变未操作路径上的节点，因此可以精确撤销。用于分治、线段树分治等需要回溯的场景。
  - **DSU on Tree**：在树上利用重链剖分做启发式合并，解决子树查询类问题（如统计子树中不同颜色数）。$AKB197$, '数据结构', array['数据结构', '并查集', '路径压缩', '按秩合并', '连通性'], 'col-ds-uf-overview', null, 'knowledge'),
('world-needs-sunday', 'col-ds-uf-weighted-food', '带权并查集（扩展题目 - 食物链P2024）', $AKB198$## 算法原理

食物链问题（NOI 2024 / 洛谷 P2024）是带权并查集的经典应用。题目给出 N 只动物和 K 条陈述，每条陈述声明"X 和 Y 是同类"或"X 吃 Y"。三种动物构成环形食物链：A 吃 B，B 吃 C，C 吃 A。需要判断有多少条陈述是假话。

**模 3 算术编码关系**是本算法的核心。为每个节点维护一个权值 `d[x]`，表示 `x` 到其所在并查集根节点的"食物链距离"。该距离对 3 取模后有三种含义：
- $d[x] \bmod 3 = 0$：x 与根**同类**
- $d[x] \bmod 3 = 1$：根**吃** x（x 是根的猎物，x 比根低一级）
- $d[x] \bmod 3 = 2$：x 比根低两级（根的猎物的猎物，即根被 x 的同类所吃）

这种编码完美捕捉了环形食物链的传递性：因为 A→B→C→A 是 3 步循环，距离每增加 1 就"降一级"，模 3 后恰好回到起点。

**两个元素之间的关系**可以通过权值差计算。设根为 R，则 X 与 Y 的关系为 $(d[Y] - d[X]) \bmod 3$：
- 结果为 0：X 与 Y 同类
- 结果为 1：X 吃 Y（Y 比 X 低一级）
- 结果为 2：Y 吃 X（X 比 Y 低一级）

这一公式的正确性源于食物链的传递性：X 到根的距离 d[X]，Y 到根的距离 d[Y]，两者之差正好反映 X 和 Y 之间的食物链层级差。

**谎言检测**：当新陈述涉及的 X 和 Y 已在同一集合时，可以通过权值差验证陈述的真伪。op==1（同类）时检查 $d[X] \bmod 3 \neq d[Y] \bmod 3$；op==2（X 吃 Y）时检查 $(d[Y] - d[X]) \bmod 3 = 1$。若验证失败，则该陈述为假话。当 X 和 Y 不在同一集合时，陈述被直接接受（无法证伪），此时需要合并两个集合并设置合适的权值偏移。

## 数据结构图示

食物链关系与 d 值编码：

```
环形食物链:  A --吃--> B --吃--> C --吃--> A (循环)

若根 R 为某一种动物，则:
  R (d=0, 同类)  --吃-->  猎物 (d=1)  --吃-->  猎物的猎物 (d=2)  --吃--> R

  d[x]%3=0: x 与根同类
  d[x]%3=1: 根吃 x
  d[x]%3=2: x 吃根 (因为 d=2 的动物吃 d=0 的动物)

两元素关系: rel(X,Y) = (d[Y] - d[X]) % 3
  = 0: 同类    = 1: X吃Y    = 2: Y吃X
```

合并与权值更新示意（op==2，X 吃 Y）：

```
合并前 (X, Y 在不同集合):
  集合1 (根=rx):    X ---> rx          d[X]=a, d[rx]=0
  集合2 (根=ry):    Y ---> ry          d[Y]=b, d[ry]=0

合并后 (A[ry]=rx, X 吃 Y):
  X ---> rx <--- ry <--- Y
         d[ry] = (d[X] - d[Y] + 4) % 3 = (a - b + 1) % 3

  验证: d[Y]_new = d[Y] + d[ry] = b + (a - b + 1) = a + 1 (mod 3)
        (d[Y]_new - d[X]) % 3 = (a+1 - a) % 3 = 1  ✓  (X 吃 Y 成立)
```

路径压缩时 d 值的累加：

```
压缩前:  X -> old -> ... -> root
         d[X]=a (X 到 old 的关系)
         d[old]=b (old 到 root 的关系, 递归 find 后已更新)

压缩后:  X ---------> root
         d[X] = (a + b) % 3    (关系传递: X->old->root)
```

## 核心操作详解

### init(n) —— 初始化

**功能**：为 `n` 个动物各自创建独立集合，权值初始化为 0。

**参数**：`n` — 动物总数。

**算法步骤**：
1. `A` 数组大小 `n + 1`，每个 `A[i] = i`（自身为根）。
2. `d` 数组大小 `n + 1`，全部初始化为 0（到自身关系为同类）。

**关键细节**：`d` 数组使用 `long long` 类型，虽然运算中始终 mod 3，但中间计算（如 `d[old] + d[idx]`）在路径压缩前可能较大，使用 `long long` 更安全。

### find(idx) —— 查找（带路径压缩 + 权值累加）

**功能**：返回元素 `idx` 所在集合的根节点，同时压缩路径并更新权值 `d[]`。

**参数**：`idx` — 待查找的元素编号。

**算法步骤**：
1. 判断 `idx != A[idx]`（不是根）。
2. 若不是根，保存旧父 `old = A[idx]`。
3. 递归调用 `find(A[idx])` 找到根并压缩路径，将 `A[idx]` 更新为根。
4. 执行 $d[\text{idx}] = (d[\text{old}] + d[\text{idx}]) \bmod 3$——将旧父到新根的权值累加到当前节点。
5. 返回 `A[idx]`（根节点）。

**关键细节**：权值累加公式 $d[\text{idx}] = (d[\text{old}] + d[\text{idx}]) \bmod 3$ 的含义：`d[idx]`（旧值）是 `idx` 到旧父 `old` 的关系，`d[old]`（递归后已更新）是 `old` 到新根的关系。两者相加（模 3）即为 `idx` 到新根的关系。与蓝桥 1156 的距离累加类似，但这里是在模 3 下运算。

### 合并逻辑（内联于 main）—— 同类合并 / 捕食合并

本实现未将合并封装为函数，而是根据操作类型在 `main` 中内联处理。

**op==1（X 和 Y 同类）**：
1. 调用 `find(X)` 和 `find(Y)` 获取根 `rx` 和 `ry`。
2. 若 `rx == ry`（已在同一集合）：检查 $d[X] \bmod 3 \neq d[Y] \bmod 3$，若不同则谎言计数 `++cnt`。
3. 若 `rx != ry`（不同集合）：合并 $A[r_y] = r_x$，设置 $d[r_y] = (d[X] - d[Y] + 3) \bmod 3$。

**op==2（X 吃 Y）**：
1. 调用 `find(X)` 和 `find(Y)` 获取根 `rx` 和 `ry`。
2. 若 `rx == ry`（已在同一集合）：检查 $(d[Y] - d[X] + 3) \bmod 3 \neq 1$，若不等于 1 则谎言计数 `++cnt`。
3. 若 `rx != ry`（不同集合）：合并 $A[r_y] = r_x$，设置 $d[r_y] = (d[X] - d[Y] + 4) \bmod 3$。

**关键细节**：合并方向固定为 `ry` 挂到 `rx` 下（$A[r_y] = r_x$），因此需要设置 `d[ry]`（ry 到 rx 的关系权值）。注意没有使用按秩合并。

## 逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷P2024*/
vector<int> A;
vector<long long> d;
void init(int n)
{
    A.resize(n + 1);
    for(int i = 1;i <= n;i++) A[i] = i;
    d.resize(n + 1,0);
}
int find(int idx)
{
    if(idx != A[idx])
    {
        int old = A[idx];
        A[idx] = find(A[idx]);
        d[idx] = (d[old] + d[idx]) % 3;
    }
    return A[idx];
}
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int N,K;
    int cnt = 0;
    cin >> N >> K;
    init(N);
    for(int i = 1;i <= K;i++)
    {
        int op,X,Y;
        cin >> op >> X >> Y;
        if(X > N || Y > N)
        {
            ++cnt;
            continue;
        }
        int rx = find(X);int ry = find(Y);
        if(op == 1)
        {
            if(rx == ry)
            {
                if(d[X] % 3 != d[Y] % 3) ++cnt;
            }
            else
            {
                A[ry] = rx;
                d[ry] = (d[X] - d[Y] + 3) % 3;
            }
        }
        else
        {
            if(rx == ry)
            {
                if((d[Y] - d[X] + 3) % 3 != 1) ++cnt;
            }
            else
            {
                A[ry] = rx;
                d[ry] = (d[X] - d[Y] + 4) % 3;
            }
        }
    }
    cout << cnt;
    return 0;
}
```

**逐行解析**：

- `vector<long long> d;`：权值数组，`d[x]` 记录 x 到其根的食物链关系权值（模 3 语义）。
- `d.resize(n + 1, 0);`：权值初始化为 0——每个节点初始与自身同类。
- `int old = A[idx];`：保存旧父节点编号（与蓝桥 1156 同理，必须在递归前保存）。
- `A[idx] = find(A[idx]);`：递归查找根并执行路径压缩。
- $d[\text{idx}] = (d[\text{old}] + d[\text{idx}]) \bmod 3$：**核心权值累加**。`d[idx]`（旧值）= idx 到 old 的关系；`d[old]`（递归后已更新）= old 到根的关系。两者相加模 3 = idx 到根的关系。
- `if(X > N || Y > N) { ++cnt; continue; }`：**边界检查**——编号超过 N 的动物不存在，直接判定为假话。
- `if(d[X] % 3 != d[Y] % 3) ++cnt;`：**同类验证**。若 X 和 Y 同类，它们到根的关系权值应相等（mod 3）。不等则矛盾，为假话。
- $d[r_y] = (d[X] - d[Y] + 3) \bmod 3$：**同类合并的权值设置**。ry 挂到 rx 下，需设置 ry 到 rx 的关系。合并后要求 $d[Y]_{\text{new}} = d[Y] + d[r_y] \equiv d[X] \pmod{3}$，因此 $d[r_y] = (d[X] - d[Y]) \bmod 3$。加 3 是为处理 C++ 中负数取模的问题（如 $d[X]=0, d[Y]=2$ 时，$0-2=-2$，$(-2+3) \bmod 3=1$）。
- `if((d[Y] - d[X] + 3) % 3 != 1) ++cnt;`：**捕食验证**。X 吃 Y 要求 $(d[Y] - d[X]) \bmod 3 = 1$。若不满足则为假话。加 3 同样是处理负数。
- $d[r_y] = (d[X] - d[Y] + 4) \bmod 3$：**捕食合并的权值设置**。ry 挂到 rx 下，需设置 ry 到 rx 的关系使 X 吃 Y 成立。合并后要求 $(d[Y]_{\text{new}} - d[X]) \bmod 3 = 1$，即 $d[Y] + d[r_y] - d[X] \equiv 1 \pmod{3}$，因此 $d[r_y] = (1 + d[X] - d[Y]) \bmod 3 = (d[X] - d[Y] + 1) \bmod 3$。`+4 = +3（处理负数）+ 1（捕食偏移）`。例如 $d[X]=0, d[Y]=2$ 时，$d[r_y] = (0-2+4) \bmod 3 = 2 \bmod 3 = 2$。验证：$d[Y]_{\text{new}} = 2+2 = 4 \equiv 1 \pmod{3}$，$(1-0) \bmod 3 = 1$ ✓。

### 模运算的数学推导

**同类合并 $d[r_y] = (d[X] - d[Y] + 3) \bmod 3$ 的推导**：

合并后 ry 成为 rx 的子节点。Y 的新权值为 $d[Y]_{\text{new}} = d[Y] + d[r_y]$。要求 X 和 Y 同类，即 $d[X] \bmod 3 = d[Y]_{\text{new}} \bmod 3$：
```
d[X] ≡ d[Y] + d[ry]  (mod 3)
d[ry] ≡ d[X] - d[Y]  (mod 3)
d[ry] = (d[X] - d[Y] + 3) % 3    // +3 确保 C++ 中非负
```

**捕食合并 $d[r_y] = (d[X] - d[Y] + 4) \bmod 3$ 的推导**：

要求 X 吃 Y，即 $(d[Y]_{\text{new}} - d[X]) \bmod 3 = 1$：
```
(d[Y] + d[ry] - d[X]) % 3 == 1
d[ry] ≡ 1 + d[X] - d[Y]  (mod 3)
d[ry] = (d[X] - d[Y] + 1 + 3) % 3 = (d[X] - d[Y] + 4) % 3   // +3 确保非负, +1 是捕食偏移
```

**C++ 负数取模陷阱**：在 C++ 中，$(-1) \bmod 3$ 的结果是 $-1$ 而非 $2$（C++11 起保证截断向零）。因此所有涉及减法的模运算都必须先加模数（3）再取余，确保结果非负。这是 `+3` 和 `+4`（= +3 + 1）存在的根本原因。

## 复杂度分析

- **时间复杂度**：$O(\alpha(n))$ 每次操作。路径压缩使均摊查找接近常数。每条陈述的处理包括两次 `find` 和常数次模运算，总时间 $O(K \cdot \alpha(n))$。
- **空间复杂度**：$O(n)$，需要两个数组 `A`（父节点）和 `d`（权值），各 $O(n)$。未使用按秩合并的 `rt` 数组。

## 适用场景

- **关系推理问题**：需要维护元素间的相对关系（同类/捕食/敌对），而非简单的连通性。
- **食物链 / 关押罪犯**：经典的多类关系传递问题，可用模运算编码。
- **带约束的合并问题**：每次合并不仅要连通，还要满足特定的关系约束。
- **假话/矛盾检测**：在动态加入关系的过程中，实时判断新关系是否与已有信息矛盾。
- 任何可以用"权值差模 k"来编码 k 类循环关系的问题。

## 常见陷阱与注意事项

- **边界检查不可遗漏**：`X > N || Y > N` 必须在 `find` 之前检查。若先 `find` 再检查，可能访问越界内存导致 RE。
- **自捕食检查**：虽然本题中 `X == Y` 时 op==2（X 吃 X 自己）应该判为假话，但代码中未显式检查——因为当 X==Y 时 rx==ry，$(d[Y]-d[X]+3) \bmod 3 = 0 \neq 1$，会正确判为假话。这是隐式正确的。
- **模运算中的负数处理**：C++ 中负数取模结果为负。所有形如 $(a - b) \bmod m$ 的表达式必须改为 $(a - b + m) \bmod m$ 或 $(a - b + k \cdot m) \bmod m$（k 为确保非负的常数）。这是 `+3` 和 `+4` 的来源，遗漏会导致错误。
- **find 必须先保存旧父**：`int old = A[idx]` 必须在 `A[idx] = find(A[idx])` 之前，否则 `old` 会变成根，`d[old]` 就变成了根的权值（始终为 0），导致权值累加失效。
- **合并方向一致性**：本实现固定将 ry 挂到 rx 下（`A[ry] = rx`）。若改为 `A[rx] = ry`，则权值公式需相应调整（计算 d[rx] 而非 d[ry]）。
- **不要忘记 find 后再读取 d**：`d[X]` 和 `d[Y]` 只有在 `find(X)` 和 `find(Y)` 之后才是最新的（路径压缩后更新过）。

## 对比与扩展

- **食物链（模 3 带权）vs 蓝桥 1156（距离带权）**：两者都是带权并查集，但权值语义不同。蓝桥 1156 的 `k[]` 是绝对距离（整数累加），食物链的 `d[]` 是模 3 的关系编码。蓝桥 1156 查询距离差，食物链检测关系矛盾。
- **带权并查集 vs 扩展域并查集**：食物链问题也可以用扩展域并查集解决——将每个动物拆为 3 个域（自身、猎物、天敌），但代码量更大（3n 数组）。带权并查集只需一个额外的 `d[]` 数组，更紧凑。
- **扩展方向**：
  - **模 k 带权并查集**：将模 3 推广到模 k，处理 k 类循环关系。
  - **带权 + 按秩合并**：本实现未使用按秩合并，加入后可进一步优化常数。
  - **离线处理**：对于"某时刻关系是否成立"的查询，可结合时间线分治。
  - **可撤销带权并查集**：不使用路径压缩，改为按秩合并 + 权值维护，支持回溯。用于需要撤销操作的回溯搜索场景。$AKB198$, '数据结构', array['数据结构', '并查集', '带权并查集', '食物链', '关系推理'], 'col-ds-uf-overview', null, 'knowledge');

do $$
declare
    v_missing text;
begin
    select string_agg(distinct s.author_name, '、') into v_missing
    from _akb_seed_columns s
    left join public.profiles p on p.nickname = s.author_name
    where p.id is null;

    if v_missing is not null then
        raise exception '缺少作者 profile：%', v_missing;
    end if;
end $$;

insert into public.columns (
    owner_id, column_key, column_name, content, tags, category, parent_key,
    relations, difficulty, kind, status
)
select
    p.id, s.column_key, s.column_name, s.content, s.tags, s.category,
    s.parent_key, '[]'::jsonb, s.difficulty, s.kind, 'published'
from _akb_seed_columns s
join public.profiles p on p.nickname = s.author_name
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    content = excluded.content,
    tags = excluded.tags,
    category = excluded.category,
    parent_key = excluded.parent_key,
    difficulty = excluded.difficulty,
    kind = excluded.kind,
    status = 'published',
    updated_at = now();

drop table if exists _akb_seed_columns;

commit;
