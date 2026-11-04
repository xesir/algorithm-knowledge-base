---
id: basic-tricks-median
title: '中位数问题的 01 转化 trick'
category: 基础算法
subcategory: 优化技巧
tags: ["中位数", "01转化", "二分答案", "线段树", "trick"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: B
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

很多与中位数有关的问题，直接维护中位数很困难。常用套路是：**二分答案 $x$，把数组转化成 01 串或 $+1/-1$ 串**：

- 大于等于 $x$ 的数记为 $1$，否则记为 $0$（或 $-1$）；
- 判断某个子数组的中位数是否 $\ge x$，只需要看这个 01 串中 $1$ 的数量是否足够；
- 如果 $1$ 的数量大于等于 $0$ 的数量（或区间和 $\ge0$），就说明中位数至少是 $x$。

这样就把“中位数”转成了“区间和/01 计数”，可以用前缀和、线段树、树状数组等维护。

## 核心公式 / 状态定义与转移方程

- 判定中位数 $\ge x$：令 $b_i=[a_i\ge x]$，若区间内 $1$ 的数量 $\ge$ 区间长度的一半，则中位数 $\ge x$。
- 用 $+1/-1$ 时：令 $b_i=+1$（$a_i\ge x$）或 $-1$（$a_i<x$），区间和 $\ge0$ 等价于中位数 $\ge x$。
- 若要求“中位数恰好为 $x$”，通常二分最后一个满足条件的 $x$。
- 排序操作转 01：区间内 $1$ 的个数为 $cnt$，升序排序后前 $len-cnt$ 个为 $0$、后 $cnt$ 个为 $1$；降序反过来。

## 逐行代码解析

### 二分中位数 + 二维前缀和

以“the Median of the Median of the Median”为例：二分答案 $x$，把每个数转成 $+1/-1$，用二维前缀和维护所有子数组的和；再对所有子数组的和做一次同样的转化，判断总和是否 $\ge0$。

```cpp
int s1[N][N];
int s[N], b[N][N];

void solve() {
    int n;
    cin >> n;
    vector<long long> a(n + 1);
    for (int i = 1; i <= n; i++) cin >> a[i];

    long long l = 0, r = *max_element(a.begin() + 1, a.end()), ans = 0;
    auto check = [&](long long x) -> bool {
        s[0] = 0;
        for (int i = 1; i <= n; i++) {
            int num = (a[i] <= x ? 1 : -1);
            s[i] = s[i - 1] + num;
        }
        for (int i = 1; i <= n; i++)
            for (int j = i; j <= n; j++)
                b[i][j] = (s[j] - s[i - 1] >= 0 ? 1 : -1);

        for (int i = 1; i <= n; i++)
            for (int j = 1; j <= n; j++)
                s1[i][j] = s1[i - 1][j] + s1[i][j - 1] - s1[i - 1][j - 1] + b[i][j];

        int sum = 0;
        for (int i = 1; i <= n; i++)
            for (int j = i; j <= n; j++) {
                int c = (s1[j][j] - s1[i - 1][j] - s1[j][i - 1] + s1[i - 1][i - 1] >= 0 ? 1 : -1);
                sum += c;
            }
        return sum >= 0;
    };

    while (l <= r) {
        long long mid = (l + r) / 2;
        if (check(mid)) {
            r = mid - 1;
            ans = mid;
        } else {
            l = mid + 1;
        }
    }
    cout << ans;
}
```

- `check(x)` 先把原数组转成 $+1/-1$，用一维前缀和求所有子数组的和，再转成 $+1/-1$ 放进二维数组。
- 二维前缀和用于快速求“所有子数组的和”这一层的区间和。
- 二分最小的可行 $x$，就是答案。
- 注意：原文这里把 $a_i\le x$ 记为 $1$、否则记为 $-1$，所以 `check(x)` 表示“中位数不超过 $x$”；二分找最小的 $x$，与前面“$a_i\ge x$ 记为 $1$”的叙述方向相反，本质等价。
- 代码是原文节选，`N`、`i64` 等宏/类型按你的模板补齐。

### 排序 + 线段树

以 P2824 [HEOI2016/TJOI2016] 排序为例：二分答案 $x$，把 $\ge x$ 设为 $1$、否则设为 $0$。每次排序操作变成：

1. 查询区间内 $1$ 的个数 $cnt$；
2. 升序：前 $len-cnt$ 个改为 $0$，后 $cnt$ 个改为 $1$；降序反过来。

用线段树支持区间赋值和区间求和。最后判断第 $q$ 位是否为 $1$，调整二分边界。

```cpp
struct SegTree {
    int n;
    std::vector<int> sum, tag;
    SegTree(int n_): n(n_) {
        sum.assign(4 * n, 0);
        tag.assign(4 * n, -1);
    }
    void pull(int o) {
        sum[o] = sum[o * 2] + sum[o * 2 + 1];
    }
    void apply(int o, int l, int r, int v) {
        sum[o] = v * (r - l + 1);
        tag[o] = v;
    }
    void push(int o, int l, int r) {
        if (tag[o] != -1) {
            int m = (l + r) / 2;
            apply(o * 2, l, m, tag[o]);
            apply(o * 2 + 1, m + 1, r, tag[o]);
            tag[o] = -1;
        }
    }
    void build(int o, int l, int r, const std::vector<int>& a) {
        tag[o] = -1;
        if (l == r) { sum[o] = a[l]; return; }
        int m = (l + r) / 2;
        build(o * 2, l, m, a);
        build(o * 2 + 1, m + 1, r, a);
        pull(o);
    }
    void build(const std::vector<int>& a) { build(1, 1, n, a); }
    int query(int o, int l, int r, int L, int R) {
        if (R < l || r < L) return 0;
        if (L <= l && r <= R) return sum[o];
        push(o, l, r);
        int m = (l + r) / 2;
        return query(o * 2, l, m, L, R) + query(o * 2 + 1, m + 1, r, L, R);
    }
    int query_sum(int x, int y) { return query(1, 1, n, x, y); }
    void update(int o, int l, int r, int L, int R, int v) {
        if (R < l || r < L) return;
        if (L <= l && r <= R) { apply(o, l, r, v); return; }
        push(o, l, r);
        int m = (l + r) / 2;
        update(o * 2, l, m, L, R, v);
        update(o * 2 + 1, m + 1, r, L, R, v);
        pull(o);
    }
    void update(int x, int y, int v) { update(1, 1, n, x, y, v); }
    int query_point(int p) {
        return query(1, 1, n, p);
    }
};

void solve() {
    int n, m, q;
    std::cin >> n >> m;
    std::vector<int> a(n + 1);
    std::vector<int> op(m + 1), L(m + 1), R(m + 1);
    for (int i = 1; i <= n; i++) std::cin >> a[i];
    for (int i = 1; i <= m; i++) std::cin >> op[i] >> L[i] >> R[i];
    std::cin >> q;

    SegTree seg(n);
    auto check = [&](int x) -> bool {
        std::vector<int> b(n + 1);
        for (int i = 1; i <= n; i++) b[i] = (a[i] >= x ? 1 : 0);
        seg.build(b);
        for (int i = 1; i <= m; i++) {
            int cnt = seg.query_sum(L[i], R[i]);
            if (op[i] == 0) {
                seg.update(L[i], R[i] - cnt, 0);
                seg.update(R[i] - cnt + 1, R[i], 1);
            } else {
                seg.update(L[i], L[i] + cnt - 1, 1);
                seg.update(L[i] + cnt, R[i], 0);
            }
        }
        return seg.query_point(q);
    };

    int l = 1, r = n, ans = 1;
    while (l <= r) {
        int mid = (l + r) / 2;
        if (check(mid)) {
            ans = mid;
            l = mid + 1;
        } else {
            r = mid - 1;
        }
    }
    std::cout << ans;
}
```

- 线段树维护 01 串的区间和与区间赋值。
- 排序操作被拆成“查询 $1$ 的个数 + 两段区间赋值”。
- 二分答案的单调性：$x$ 越大，01 串中 $1$ 越少，第 $q$ 位越容易是 $0$。
- 以上为原文实现的节选；`std::` 前缀、头文件等按你的模板补齐。

### Range Sort Query

ABC237G 允许两种排序方向，并要求找出值为 $x$ 的位置。做法是：

- 第一次把 $\ge x$ 设为 $1$、否则 $0$，跑完所有排序；
- 第二次把 $>x$ 设为 $1$、否则 $0$，再跑一遍；
- 两次结果只有值为 $x$ 的位置不同，比对两次数组即可找到答案。

```cpp
void solve() {
    int n, m, q;
    std::cin >> n >> m >> q;
    std::vector<int> a(n + 1);
    std::vector<int> op(m + 1), L(m + 1), R(m + 1);
    for (int i = 1; i <= n; i++) std::cin >> a[i];
    for (int i = 1; i <= m; i++) std::cin >> op[i] >> L[i] >> R[i];

    SegTree seg(n);
    std::vector<int> b(n + 1);
    for (int i = 1; i <= n; i++) b[i] = (a[i] >= q ? 1 : 0);

    auto work = [&](std::vector<int>& x) -> void {
        for (int i = 1; i <= m; i++) {
            int cnt = seg.query_sum(L[i], R[i]);
            if (op[i] == 1) {
                seg.update(L[i], R[i] - cnt, 0);
                seg.update(R[i] - cnt + 1, R[i], 1);
            } else {
                seg.update(L[i], L[i] + cnt - 1, 1);
                seg.update(L[i] + cnt, R[i], 0);
            }
        }
        for (int i = 1; i <= n; i++) x[i] = seg.query_point(i);
    };

    seg.build(b);
    work(b);
    std::vector<int> c(n + 1);
    for (int i = 1; i <= n; i++) c[i] = (a[i] > q ? 1 : 0);
    seg.build(c);
    work(c);
    for (int i = 1; i <= n; i++) {
        if (b[i] != c[i]) {
            std::cout << i << '\n';
            return;
        }
    }
}
```

### Median Pyramid Hard

AGC006D 的 01 金字塔：每个格子由下面三个格子的多数决定。二分答案 $x$，把 $\ge x$ 设为 $1$、否则 $0$。观察发现，最顶端的值取决于最底层中“离中心最近的两个连续相同数字”：

- 从中心向两边找第一个连续两个 $1$ 或连续两个 $0$；
- 若先找到两个 $1$，顶端为 $1$；先找到两个 $0$，顶端为 $0$；
- 若整层是交替的 `a b a b ...`，顶端等于最左边的数字。

这样每次 `check` 只需要 $O(n)$，总复杂度 $O(n\log V)$。

```cpp
void solve() {
    int n;
    std::cin >> n;
    std::vector<int> a(n * 2);
    for (int i = 1; i <= n * 2 - 1; i++) std::cin >> a[i];

    int l = 1, r = 2 * n - 1, ans = 0;
    auto check = [&](int x) -> bool {
        for (int i = 0; i < n - 1; i++) {
            if ((a[n + i] > x && a[n + i + 1] > x) ||
                (a[n - i] > x && a[n - i - 1] > x)) return false;
            if ((a[n + i] <= x && a[n + i + 1] <= x) ||
                (a[n - i] <= x && a[n - i - 1] <= x)) return true;
        }
        return a[1] <= x;
    };

    while (l <= r) {
        int mid = (l + r) / 2;
        if (check(mid)) {
            r = mid - 1;
            ans = mid;
        } else {
            l = mid + 1;
        }
    }
    std::cout << ans;
}
```

## 复杂度分析

- QOJ 中位数：二分 $O(\log V)$，每次二维前缀和 $O(n^2)$，总 $O(n^2\log V)$，空间 $O(n^2)$。
- P2824 排序：二分 $O(\log n)$，每次线段树 $O((n+m)\log n)$，总 $O((n+m)\log^2 n)$。
- ABC237G：两次线段树模拟，$O((n+m)\log n)$。
- AGC006D：二分 $O(\log V)$，每次 $O(n)$，总 $O(n\log V)$。

## 适用场景

- 题目要求“子数组的中位数”“中位数的中位数”“排序后第 $k$ 位”等。
- 操作只与“大于等于某个数”有关，且可以把值转成 01。
- 需要维护区间排序、区间 01 计数、区间赋值。
- 单峰/单调的判定问题，可以用二分答案 + 01 转化。

## 常见陷阱与注意事项

1. **二分方向**：把 $\ge x$ 设为 $1$ 还是 $>x$ 设为 $1$，会影响“第 $q$ 位是 $1$ 时移动哪边”，要按题意推。
2. **中位数的定义**：长度为偶数时，中位数可能取中间两个的较小/较大/平均；题目通常会有明确定义，先看清。
3. **`+1/-1` 与 `1/0` 的区别**：`+1/-1` 看区间和 $\ge0$；`1/0` 看 $1$ 的个数是否过半。两者等价但边界不同。
4. **排序操作的区间边界**：`cnt` 个 $1$ 放在后面（升序）还是前面（降序），不要写反。
5. **线段树的懒标记**：区间赋值要下传，查询/更新前先 `push`。
6. **二维前缀和的空间**：$n$ 较大时二维数组可能 MLE，注意题目范围。
7. **二分的答案范围**：$l,r$ 要覆盖所有可能的中位数，通常取最小值到最大值。

## 对比与扩展

- **01 转化 vs 直接维护中位数**：直接维护需要平衡树/对顶堆，代码复杂；01 转化把问题变成计数/排序，配合线段树更通用。
- **二分答案 vs 整体二分**：单组询问用二分答案；多组询问且操作可离线时可以用整体二分。
- **线段树 vs 树状数组**：排序操作需要区间赋值，线段树更合适；只做单点修改/区间求和可以用树状数组。
- **同类题**：QOJ the Median of the Median of the Median、P2824 排序、ABC237G Range Sort Query、AGC006D Median Pyramid Hard。
