---
id: ds-persistent-segtree-kth
title: '主席树（可持久化权值线段树 · 区间第 k 小）'
category: 数据结构
subcategory: 可持久化数据结构
subSubcategory: '可持久化线段树'
tags: ["数据结构", "主席树", "可持久化", "权值线段树", "区间第k小", "离散化"]
timeComplexity: '建版本 O(n log n)，单次查询 O(log n)'
spaceComplexity: 'O(n log n)'
level: A
codePath: '数据结构\可持久化线段树\主席树\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

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
4. [Dynamic Rankings](https://www.luogu.com.cn/problem/P2617)（树状数组套主席树 ~~禁止套娃~~）
