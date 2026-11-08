-- ============================================================
-- AKB 专栏种子：题目 / 基础算法
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：44 行
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
('stripe-python', 'col-prob-atcoder-abc355e--stripe-python', 'Guess the Sum · stripe-python', $AKB409$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC355E](https://www.luogu.com.cn/problem/AT_abc355_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $a_i$，长度为 $2^n$。你可以给出 $i,j$，设 $x=2^i \times j,y=2^i \times(j+1)-1$，向交互库询问 $\left(\sum \limits_{i=x}^y a_i\right) \bmod 100$。
>
> 给出 $l,r$，通过最少询问次数求出 $\left(\sum \limits_{i=l}^r a_i\right) \bmod 100$。
>
> $n \le 18$。

:::::success[题解]
这个询问形式比较奇怪，我们画一下合法区间：

![](https://cdn.luogu.com.cn/upload/image_hosting/4zudg6ym.png)

发现这是一个倒着的线段树。于是考虑把询问像线段树一样拆成 $\log 2^n$ 段，然后喜提 WA。

错误原因在于，本题询问的信息具有可减性。因此，我们采用前缀和 trick，记 $s_i$ 为 $a_i$ 的前缀和，询问即求 $s_r-s_{l-1}$。因为是 0-index，我们让 $s$ 向后移动一位，去求 $s_{r+1}-s_l$。

我们考虑如下策略：从 $l$ 开始，不断扩展当前区间直到包含 $r$，在求和时要判断当前区间是加还是减。基于此，我们可以进行图论建模，用最短路来确定策略。对于合法区间 $[l,r]$，连边 $l \leftrightarrow r+1$，则询问即 $l$ 到 $r+1$ 的最短路。

容易用一次 BFS 记录最短路径，然后从 $r+1$ 倒推回来，判一下询问端点即可确定加减。复杂度 $O(n2^n)$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e5 + 5;
int n, l, r, pre[N], vis[N];
vector<int> e[N];

void bfs(int s, int t) {
    queue<int> q;
    q.emplace(s), pre[s] = -1, vis[s] = true;
    while (!q.empty()) {
        int u = q.front(); q.pop();
        if (u == t) return;
        for (int v : e[u]) {
            if (vis[v]) continue;
            q.emplace(v), pre[v] = u, vis[v] = true;
        }
    }
} 

void _main() {
    cin >> n >> l >> r;
    for (int i = 0; i <= n; i++) {
        for (int j = 0; j < (1 << (n - i)); j++) {
            int x = j * (1 << i), y = (j + 1) * (1 << i) - 1;
            e[y + 1].emplace_back(x), e[x].emplace_back(y + 1);
        }
    }
    r++, bfs(l, r);
    mint res = 0;
    for (int i = r, j = -1; i != -1; j = i, i = pre[i]) {
        if (j == -1) continue;
        int x = min(i, j), y = max(i, j), k = lg(y - x);
        cout << "? " << k << ' ' << (x >> k ) << endl;
        mint v; cin >> v;
        if (i < j) res += v;
        else res -= v;
    } 
    cout << "! " << res << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB409$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc154d--stripe-python', 'A + B > C ? · stripe-python', $AKB410$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC154D](https://www.luogu.com.cn/problem/AT_arc154_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以给出 $i,j,k$，向交互库查询 $p_i+p_j > p_k$ 是否正确。
>
> 还原这个排列。
>
> $n \le 2 \times 10^3$，满分询问次数 $2.5 \times 10^4$。

:::::success[题解]
如果我们能找到一个 $1$，那么就有 $p_i+1>p_k \iff p_i \ge p_k$。

考虑得到 $p_i$ 的逆排列 $q_i$，那么就可以对 $q$ 进行基于比较的排序。次数为 $n\log n$。

问题转化为找到 $1$，而这是容易的。考虑增量法，令 $p_x=1$，若 $p_x+p_x >p_y$ 就令 $x \gets y$，$n-1$ 轮询问。

总询问次数 $n+n\log n$。注意比较卡常，需要使用 std::stable_sort 或者手写排序。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
int n, a[N], b[N];
bool ask(int i, int j, int k) {
    cout << "? " << i << ' ' << j << ' ' << k << endl;
    string s; cin >> s;
    return s == "Yes";
}

void _main() {
    cin >> n;
    int p = 1;
    for (int i = 2; i <= n; i++) {
        if (ask(p, p, i)) p = i;
    }
    iota(b + 1, b + n + 1, 1);
    stable_sort(b + 1, b + n + 1, [&](int x, int y) -> bool {
        return !ask(x, p, y);
    });
    for (int i = 1; i <= n; i++) a[b[i]] = i;
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB410$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc179c--stripe-python', 'Beware of Overflow · stripe-python', $AKB411$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC179C](https://www.luogu.com.cn/problem/AT_arc179_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个正整数 $k$ 和长为 $n$ 的序列 $a_i$。保证 $|a_i| \le k, \left|\sum \limits_{i=1}^n a_i\right| \le k$。你可以进行如下两种操作：
>
> - 选择 $i,j$，删去 $a_i,a_j$ 并加入 $a_i+a_j$，要求 $|a_i+a_j| \le k$；
> - 选择 $i,j$，查询 $a_i<a_j$ 是否成立。
>
> 构造一组操作，使得最终序列中仅剩 $1$ 个数。
>
> $n \le 10^3$，满分操作次数 $2.5 \times 10^4$，交互库非自适应。

:::::success[题解]
容易发现在不知道任何信息的情况下做操作一是找死。

注意到操作次数为 $n \log n$ 级别，考虑利用操作二将序列排序。

接下来，考虑每轮选择最小值和最大值相加，可以讨论正负证明合法。重复 $n-1$ 轮即可。

此时需要修正序列的有序性，考虑二分找插入位置，然后暴力模拟，复杂度可以接受。操作次数为 $2 n \log n$，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
bool ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int a; cin >> a;
    return a;
}
int add(int x, int y) {
    cout << "+ " << x << ' ' << y << ' ' << endl;
    int a; cin >> a;
    return a;
} 
int n;

void _main() {
    cin >> n;
    deque<int> a(n);
    iota(a.begin(), a.end(), 1);
    stable_sort(a.begin(), a.end(), ask);
    for (int i = 1; i < n; i++) {
        int x = a.front(), y = a.back(), z = add(x, y);
        a.pop_front(), a.pop_back();
        a.insert(lower_bound(a.begin(), a.end(), z, ask), z);
    }
    cout << "!" << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB411$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-pakencamp-2025-day2-h--stripe-python', 'Sunk Islands · stripe-python', $AKB412$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[PAKENCAMP_2025_DAY2_H](https://www.luogu.com.cn/problem/AT_pakencamp_2025_day2_h)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一棵 $n$ 个点的无根树。你可以给出点集 $S$，询问 $S$ 的导出子图的直径点数。
>
> 还原树的形态。
>
> $n=256$，满分询问次数 $4600$。交互库非自适应。
>
> Bonus：询问次数 $3000$。

:::::success[题解]

取树上独立集 $S$，询问 $S \cup \{x\}$ 可以确定 $x$ 在树上的相对位置：

- 答案为 $1$，则 $x$ 与 $S$ 中任意点无边。
- 答案为 $2$，则 $S$ 中存在唯一点与 $x$ 有边。
- 答案为 $3$，则 $S$ 中存在两个点与 $x$ 有边。

考虑增量法。我们维护前缀森林，并确定新点 $x$ 的位置。

对森林黑白染色，取所有黑点和所有白点作为独立集。对独立集 $S$，若 $x $ 与 $S$ 中的点有连边，则将 $S$ 从中点处划分为两个不交子集 $S_1,S_2$ 递归下去。

考虑一条边会在 $\log n$ 次询问中产生贡献，均摊下来询问次数 $n \log n$。将加点顺序和 $S$ 的顺序随机打乱，实现后的询问次数约为 $3500$。

注意到 $S \cup \{x\}$ 的答案为 $2$ 时，$S_1$ 和 $S_2$ 有且仅有一个子集需要递归。我们先递归一侧，若 $S_1 \{x\}$ 的答案不为 $1$ 就没有必要询问 $S_2 \cup \{x\}$ 了。添加剪枝后询问次数约为 $2900$，可以通过。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 300;
int ask(vector<int> a) {
    cout << "? " << a.size() << ' ';
    for (int i : a) cout << i << ' ';
    cout << endl;
    int x; cin >> x;
    return x;
}
void answer(vector<int> u, vector<int> v) {
    cout << "! ";
    for (int i = 0; i < (int)u.size(); i++) cout << u[i] << ' ' << v[i] << ' ';
    cout << endl;
} 

vector<int> e[N];
int col[N];
void dfs(int u, int fa) {
    for (int v : e[u]) {
        if (v == fa) continue;
        col[v] = col[u] ^ 1, dfs(v, u);
    }
}

bool work(vector<int> a, int x) {
    if (a.empty()) return false;
    vector<int> b = a; b.emplace_back(x);
    int val = ask(b);
    if (val == 1) return false;
    if (a.size() == 1) {
        int y = a[0];
        e[x].emplace_back(y), e[y].emplace_back(x);
        return true;
    }
    shuffle(a.begin(), a.end(), rand32);
    int mid = a.size() / 2;
    vector<int> l(a.begin(), a.begin() + mid), r(a.begin() + mid, a.end());
    bool f1 = work(l, x);
    if (val == 2 && f1) return true;
    return work(r, x) | f1;
}

void _main() {
    int N, L; cin >> N >> L;
    vector<int> v;
    for (int i = 1; i <= N; i++) v.emplace_back(i);
    shuffle(v.begin(), v.end(), rand32);
    for (int i = 1; i < N; i++) {
        fill(col + 1, col + N + 1, -1);
        for (int j = 0; j < i; j++) if (col[v[j]] == -1)
            col[v[j]] = 0, dfs(v[j], -1);
        vector<int> a, b;
        for (int j = 0; j < i; j++) {
            if (col[v[j]] == 0) a.emplace_back(v[j]);
            else b.emplace_back(v[j]);
        }
        work(a, v[i]), work(b, v[i]);
    }
    vector<int> p, q;
    for (int u = 1; u <= N; u++)
        for (int v : e[u]) 
            if (u < v) p.emplace_back(u), q.emplace_back(v);
    answer(p, q);
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB412$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1061f--stripe-python', 'Lost Root · stripe-python', $AKB413$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1061F](https://www.luogu.com.cn/problem/CF1061F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 已知一棵 $n$ 个节点的满 $k$ 叉树，交互库隐藏了所有节点的标号。一次询问给出 $a,b,c$，交互库回答 $b$ 是否在 $a \to c$ 的简单路径上。
>
> 找到根节点的标号。
>
> $n \le 1500$，$2 \le k < n$，满分询问次数 $60n$，交互库非自适应。

:::::success[题解]
注意到满 $k$ 叉树的直径中点一定是根节点。

先考虑怎么找直径。我们发现直接随机两个点有 $\frac{1}{2} \times \frac{1}{4}=\frac{1}{8}$ 的概率找到直径。而且可以通过 $n-2$ 次询问知道路径上的节点，也就知道了路程长度。

实际上直径的路径长可以通过 $n,k$ 算出来。故期望 $8$ 轮就能找到一条直径。

剩下的事情是简单的，考虑枚举路径上的每一个点，计算该点到两个直径端点的距离，如果相等就找到了根。一个优化是，我们只取直径上的点就能找到路径长度。

期望询问次数 $8n+2\log^2 n $，足以通过。
:::::

:::::info[代码]

```cpp line-numbers
const double eps = 1e-6;
bool ask(int a, int b, int c) {
    cout << "? " << a << ' ' << b << ' ' << c << endl;
    string s; cin >> s;
    return s == "Yes";
}
void answer(int x) {cout << "! " << x << endl, exit(0);}

int n, k;
vector<int> path(int u, int v) {
    vector<int> vec = {u, v};
    for (int i = 1; i <= n; i++) {
        if (i == u || i == v) continue;
        if (ask(u, i, v)) vec.emplace_back(i);
    } return vec;
}
int len(int u, int v) {return path(u, v).size();}

void _main() {
    cin >> n >> k;
    int h = log(n * (k - 1) + 1) / log(k) - 1 + eps, u, v;
    while (true) {
        do u = rand32() % n + 1, v = rand32() % n + 1;
        while (u == v);
        if (len(u, v) == 2 * h + 1) break;
    }
    vector<int> vec = path(u, v);
    for (int i : vec) {
        if (i == u || i == v) continue;
        int c1 = 0, c2 = 0;
        for (int j : vec) {
            if (ask(i, j, u)) c1++;
            if (ask(i, j, v)) c2++;
        }
        if (c1 == c2) answer(i);
    }
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB413$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1114e--stripe-python', 'Arithmetic Progression · stripe-python', $AKB414$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1114E](https://www.luogu.com.cn/problem/CF1114E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，$a_i$ 在升序排序以后是一个等差数列。你可以向交互库提出如下两种询问：
>
> 1. 给出 $p$，查询 $a_p$。
> 2. 给出 $x$，查询是否 $\exists i, a_i > x$。
>
> 还原等差数列的首项和公差。
>
> $n \le 10^6$，$0 \le a_i \le 10^9$，满分询问次数 $60$，交互库非自适应。

:::::success[题解]
操作二很容易想到猜数模型，所以我们二分最大值，操作次数 $\log V=30$ 次。记最大值为 $m$。

设公差为 $d$，此时我们发现一个性质：$\forall i, d \mid (m-a_i)$。这启示我们可以将剩下 $30$ 次单点询问用于确定 $d$，只需询问 $30$ 个 $a_i$ 取 $\gcd$ 即可。

本题中，我们随机取 $30$ 个 $a_i$，具有极高的正确率。通过一些数论方法可以证明这个东西的错误率在 $10^{-9}$ 左右，完全可以通过。
:::::

:::::info[代码]

```cpp line-numbers
int n;
int ask(int x) {
    cout << "? " << x << endl;
    int u; cin >> u;
    return u;
}
bool query(int x) {
    cout << "> " << x << endl;
    int u; cin >> u;
    return u;
}

void _main() {
    cin >> n;
    int l = 0, r = 1e9, mx = 0;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (query(mid)) l = mid + 1;
        else mx = mid, r = mid - 1;
    }
    int T = 30, d = 0;
    while (T--) {
        int x = ask(rand32() % n + 1);
        d = gcd(d, mx - x);
    }
    cout<< "! " << mx - (n - 1) * d << ' ' << d << endl;
} s
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB414$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1354g--stripe-python', 'Find a Gift · stripe-python', $AKB415$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1354G](https://www.luogu.com.cn/problem/CF1354G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 现有 $n$ 个盒子，恰有 $k$ 个盒子中有礼物，其余盒子中只有石头。石头的重量相同，且严格大于所有类型的礼物。
>
> 你可以给出两个不交的下标集合 $S,T$，交互库比较 $S$ 中盒子的总重量和 $T$ 中盒子的总重量并返回。
>
> 找到标号最小的礼物盒。
>
> 多测，$\sum n \le 10^3$，$1 \le k \le \textcolor{red}{\frac{n}{2}}$，满分询问次数 $50$，交互库非自适应。

:::::success[题解]

注意到 $2k \le n$ 且交互库非自适应，这意味着，我们随机一个位置，有 $\frac{1}{2}$ 的概率得到石头。

考虑随 $T$ 个位置两两比较，取重量最大的位置作为石头盒 $p$，错误率 $2^{-T}$。

这样，我们将某个位置与 $p$ 进行比较，就能判定这个位置是否是礼物。特判位置 $1$ 是礼物后，考虑如下倍增：

![](https://cdn.luogu.com.cn/upload/image_hosting/ok7v7w95.png)

在第 $k$ 轮倍增时，我们已经认定前 $2^{k-1}$ 个盒子都是石头。如图对将 $[1,2^{k-1}]$ 与 $(2^{k-1},2^{k}]$ 进行比较，若二者不等，则石头必定在 $(2^{k-1},2^k]$ 中，否则继续倍增。询问次数 $\log n$。

找到石头所在的区间 $[l,r]$ 后，考虑二分答案 $m$，只要判定 $[l,m]$ 中是否有石头。这是简单的，我们取前 $m-l+1$ 个盒子与 $[l,m]$ 进行比较即可，正确性由倍增保证。

综上，总询问次数 $2\log n+T$，实现取 $T=25$ 稳定通过。

:::::

:::::info[代码]

```cpp line-numbers
int n, k;

int ask(vector<int> a, vector<int> b) {
    set<int> s(a.begin(), a.end()), c;
    for (int i : b) if (s.count(i)) c.emplace(i); 
    vector<int> x, y;
    for (int i : a) if (!c.count(i)) x.emplace_back(i);
    for (int i : b) if (!c.count(i)) y.emplace_back(i);
    if (x.empty()) return y.empty() ? 0 : -1;
    if (y.empty()) return 1; 
    cout << "? " << x.size() << ' ' << y.size() << '\n';
    for (int i : x) cout << i << ' ';
    cout << '\n'; for (int i : y) cout << i << ' ';
    cout << endl;
    string r; cin >> r;
    return r == "FIRST" ? 1 : r == "SECOND" ? -1 : 0;
}

void _main() {
    cin >> n >> k;
    int p = rand32() % n + 1;
    for (int T = 25; T--; ) {
        int q = rand32() % n + 1;
        if (ask({p}, {q}) == -1) p = q;
    }
    if (p != 1 && ask({1}, {p}) == -1) 
        return cout << "! " << 1 << endl, void(); 
    auto check = [&](int l, int r) -> bool {
        vector<int> x, y;
        for (int i = 1; i <= r - l + 1; i++) x.emplace_back(i);
        for (int i = l; i <= r; i++) y.emplace_back(i);
        return ask(x, y) == 0;
    };
    int l = 2, len = 1, r = -1;
    while (r <= n) {
        r = l + len - 1;
        if (r > n) {r = n; break;}
        if (!check(l, r)) break;
        l = r + 1, len *= 2;
    }
    int lo = l, hi = r, res = -1;
    while (lo <= hi) {
        int mid = (lo + hi) >> 1;
        if (check(lo, mid)) lo = mid + 1;
        else hi = mid - 1, res = mid;
    }
    cout << "! " << res << endl;
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB415$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1365g--stripe-python', 'Secure Password · stripe-python', $AKB416$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1365G](https://www.luogu.com.cn/problem/CF1365G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个序列 $a_i$，长度为 $n$。记 $\text{OR}$ 为按位或，你可以给出一个集合 $S$，交互库返回 $\text{OR}_{i \in S} \text{ }a_i$。
>
> 设序列 $b_i=\text{OR}_{j \ne i} \text{ }a_j$，还原序列 $b_i$。
>
> $n \le 10^3$，$0 \le a_i < 2^{63}$，满分询问次数 $13$。

:::::success[题解]
首先，或运算有可重复贡献的性质，但是没有可减性，所以本题很难从运算本身还原序列。

设每一轮询问的集合为 $S_1,S_2,\cdots,S_k$，将问题转化为：构造一种询问方式，使得对于每个 $i$ 都可以选出若干集合，使得其并集为 $U \setminus \{i\}$。由可重复贡献性可以说明正确性。

考虑毒药模型。对于位置 $i$，将其拆成二进制后分组，然后对于二进制下第 $d$ 位为 $0/1$ 的位分别询问一次。这样 $b_i$ 即二进制取反后将对应答案组合的结果。

上述做法的询问次数为 $2 \log n$，无法通过。但是一个进步在于，我们只要找到一种编码方式，将位置 $i$ 映射为二进制数 $f(i)$，然后对 $f(i)$ 执行上面的操作即可。

有一个精妙的构造：通过钦定 $\text{popcount}$ 来编码。具体地，注意到 ${13 \choose 6} > n$，因此找出 $[0,2^{13})$ 中 $\text{popcount}=6$ 的所有二进制数，然后做上面的操作。询问次数就压到了 $13$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 1005;
u64 n, b[N];
u64 ask(vector<int>& vec) {
    if (vec.empty()) return 0;
    cout << "? " << vec.size() << '\n';
    for (int i : vec) cout << i << ' ';
    cout << endl;
    u64 x; cin >> x;
    return x;
}

void _main() {
    cin >> n;
    vector<int> x;
    for (int s = 0; s < (1 << 13); s++) {
        if (popcount(s) == 6) x.emplace_back(s);
    }
    for (int d = 0; d < 13; d++) {
        vector<int> vec;
        for (int i = 1; i <= n; i++) {
            if (x[i] >> d & 1) vec.emplace_back(i);
        }
        u64 v = ask(vec);
        for (int i = 1; i <= n; i++) {
            if (!(x[i] >> d & 1)) b[i] |= v;
        }
    }
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << b[i] << ' ';
    cout << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB416$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1375f--stripe-python', 'Integer Game · stripe-python', $AKB417$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1375F](https://www.luogu.com.cn/problem/CF1375F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 现有一个游戏：初始时有三个正整数 $a,b,c$，且 $a,b,c$ 互不相同。
>
> 每一轮中，先手选择一个 $y$，后手需要选择一个正整数将其加上 $y$，并且不能连续两轮选择同一个数。如果 $a,b,c$ 中存在两个数相同，则后手失败。若 $10^3$ 轮后，后手仍然没有失败，则先手失败。
>
> 你需要与交互库博弈，并且可以自由选择先后手，请击败交互库。

:::::success[题解]
考虑一种必胜局面。不妨设 $a<b<c$，并假设上一轮后手操作了 $c$。此时先手给出一个 $y$ 使得 $a+y=b \land b+y=c$，则先手胜。胜利条件即 $a,b,c$ 成等差数列。

于是我们作为先手，尝试构造一个 $y$ 使得局面必然变成等差数列。观察对手的选择：

- 若后手将 $y$ 加到 $a$ 上：新局面为 $b,c,a+y$，列方程 $a+y-c=c-b$ 得 $y=2c-b-a$。
- 若后手将 $y$ 加到 $b$ 上：新局面为 $a,c,b+y$，列方程 $b+y-c=c-a$ 得 $y=2c-b-a$。

于是我们给出 $y=2c-b-a$，如果后手加给 $a,b$ 就形成杀棋。

那么后手只能加 $c$。此时我们再给出一个 $y$，后手就无法行动了，因为规则禁止加 $c$。这样我们在 $O(1)$ 步内即可战胜后手。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
int x[5];
void _main() {
    cin >> x[1] >> x[2] >> x[3];
    cout << "First" << endl;
    while (true) {
        vector<int> y = {x[1], x[2], x[3]};
        sort(y.begin(), y.end());
        int a = y[0], b = y[1], c = y[2], d = 2 * c - b - a;
        if (b - a == c - b) d = b - a;
        cout << d << endl;
        int p; cin >> p;
        if (p == 0) break;
        x[p] += d;
    }
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB417$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1438f--stripe-python', 'Olha and Igor · stripe-python', $AKB418$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1438F](https://www.luogu.com.cn/problem/CF1438F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一棵高为 $h$ 的满二叉树，节点有标号且隐藏。一次询问给出 $u,v,w$，询问以 $w$ 为根时 $u,v$ 两点的 LCA 标号。
>
> 还原根节点的标号。
>
> $3 \le h \le 18$，满分询问次数 $\le 2^h+419$，4 秒，250 MB。

:::::success[题解]

考虑随机 $u,v,w$ 并分析每个点作为 LCA 的概率。

对于点 $x$，当且仅当 $u,v,w$ 分居 $x$ 的三棵子树时，$x$ 会被作为回答。粗略估计一下，忽略常数以后的概率是
$$
p_x=\dfrac{(2^{h-d})^2 (2^h-2^{h-d})}{(2^h)^3}
$$
其中 $d$ 是节点 $x$ 的深度，定义域 $d \in [2,h)$。将上式展开
$$
\begin{aligned}
p_x&=\dfrac{(2^{h-d})^2 (2^h-2^{h-d})}{(2^h)^3}\\
&= \dfrac{2^{4h-3d}}{2^{3h}}
\end{aligned}
$$
可以发现 $p_x$ 关于 $d$ 单调减，且下降速度很快。

考虑用 $420$ 次询问随机 $u,v,w$，并取出最大和次大，这两个点有极大概率是根的左右儿子。确定左右儿子以后是简单的，枚举每个点，以一个儿子定根去询问即可。

:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e5 + 5;
int ask(int u, int v, int w) {
    cout << "? " << u << ' ' << v << ' ' << w << endl;
    int x; cin >> x;
    return x;
}
void answer(int x) {
    cout << "! " << x << endl;
    exit(0);
}
int h, n, cnt[N], p[N];

void _main() {
    cin >> h; n = (1 << h) - 1;
    for (int T = 420; T--; ) {
        int u, v, w;
        do u = rand32() % n + 1, v = rand32() % n + 1, w = rand32() % n + 1;
        while (u == v || u == w || v == w);
        cnt[ask(u, v, w)]++;
    }
    iota(p + 1, p + n + 1, 1);
    sort(p + 1, p + n + 1, [](int u, int v) -> bool {
        return cnt[u] > cnt[v];
    });
    int x = p[1], y = p[2];
    for (int i = 1; i <= n; i++) {
        if (i == x || i == y) continue;
        if (ask(y, i, x) == i) answer(i);
    }
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB418$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1503b--stripe-python', '3-Coloring · stripe-python', $AKB419$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1503B](https://www.luogu.com.cn/problem/CF1503B)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 现有一个 $n \times n$ 的网格和无限多的 $1,2,3$。
>
> 你需要与交互库博弈。每一轮交互库选择一个 $a \in [1,3]$，则你需要给出一个 $b \ne a$，然后选择一个空格子放置一个 $b$。
>
> 如果存在相邻两个格子放有相同数，则交互库胜利。否则 $n^2$ 轮后网格被填满，玩家胜利。你需要扮演玩家并战胜交互库。
>
> $n \le 100$。

::::::success[题解]
集合划分 + 网格图，考虑黑白染色 trick。将点染色以后可以划分为两个集合 $S,T$。

- 若交互库给出 $a=2$，则选择 $S$ 中任意点染 $1$，或者选择 $T$ 中任意点染 $3$。
- 若交互库给出 $a=1$，则选择 $T$ 中任意点染 $3$，如果用光就选择 $S$ 中任意点染 $2$。
- 若交互库给出 $a=3$，则选择 $S$ 中任意点染 $1$，如果用光就选择 $T$ 中任意点染 $2$。

用两个队列存 $S,T$，复杂度 $O(n^2)$。

::::::

::::info[代码]

```cpp line-numbers
int n;
queue<pair<int, int>> s, t;

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            if ((i + j) & 1) s.emplace(i, j);
            else t.emplace(i, j);
        }
    }
    for (int i = 1; i <= n * n; i++) {
        int a; cin >> a;
        if (a == 2) {
            if (s.empty()) {
                auto [x, y] = t.front(); t.pop();
                cout << 3 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = s.front(); s.pop();
                cout << 1 << ' ' << x << ' ' << y << endl;
            }
        } else if (a == 1) {
            if (t.empty()) {
                auto [x, y] = s.front(); s.pop();
                cout << 2 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = t.front(); t.pop();
                cout << 3 << ' ' << x << ' ' << y << endl;
            }
        } else {
            if (s.empty()) {
                auto [x, y] = t.front(); t.pop();
                cout << 2 << ' ' << x << ' ' << y << endl;
            } else {
                auto [x, y] = s.front(); s.pop();
                cout << 1 << ' ' << x << ' ' << y << endl;
            }
        }
    }
} 
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB419$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1534d--stripe-python', 'Lost Tree · stripe-python', $AKB420$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1534D](https://www.luogu.com.cn/problem/CF1534D)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个大小为 $n$ 的树。你可以给出 $u$，向交互库询问 $u$ 到所有点的距离。
>
> 还原这棵树。
>
> $n \le 2 \times 10^3$，满分询问次数 $\lceil n/2\rceil$。

:::::success[题解]
钦定 $1$ 号点为根，则可以通过一次询问得到所有点的深度。

注意到询问次数与 $n/2$ 有关，考虑将树按照深度黑白染色。

这样一来，深度为奇 / 偶的点的数目总有一个在 $n/2$ 以内。我们将这些点全部询问一次即可得到答案。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 2005;
int n, a[N], d[N];
vector<int> e[N];
void add(int u, int v) {e[u].emplace_back(v), e[v].emplace_back(u);}
void ask(int x) {
    cout << "? " << x << endl;
    for (int i = 1; i <= n; i++) cin >> a[i];
}
void dfs(int u, int fa) {
    sort(e[u].begin(), e[u].end()), e[u].erase(unique(e[u].begin(), e[u].end()), e[u].end());
    for (int v : e[u]) {
        if (v == fa) continue;
        cout << u << ' ' << v << '\n';
        dfs(v, u);
    }
}

void _main() {
    cin >> n, ask(1);
    int cnt = 0;
    for (int i = 1; i <= n; i++) cnt += a[i] & 1;
    copy(a + 1, a + n + 1, d + 1);
    if (2 * cnt < n) {
        for (int u = 2; u <= n; u++) {
            if (!(d[u] & 1)) continue;
            ask(u);
            for (int v = 1; v <= n; v++) {
                if (a[v] == 1) add(u, v);
            }
        }
    } else {
        for (int i = 1; i <= n; i++) {
            if (d[i] == 1) add(1, i);
        }
        for (int u = 2; u <= n; u++) {
            if (d[u] & 1) continue;
            ask(u);
            for (int v = 1; v <= n; v++) {
                if (a[v] == 1) add(u, v);
            }
        }
    }
    cout << "!\n", dfs(1, -1), cout << endl;
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB420$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1583d--stripe-python', 'Omkar and the Meaning of Life · stripe-python', $AKB421$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1583D](https://www.luogu.com.cn/problem/CF1583D)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以给出数组 $a_1,a_2,\cdots,a_n$，满足 $a_i \in [1,n]$。交互库得到数组 $b_i=a_i+p_i$，然后找到最小的 $k$ 满足 $b_k$ 在 $b$ 中出现一次，并将 $k$ 返回你的程序，若不存在返回 $0$。
>
> 还原这个排列。
>
> $n \le 100$，满分询问次数 $2n$。

:::::success[题解：$2n-2$ 次询问]
由于次数是 $2n$，我们考虑先用 $n$ 次询问确定一个位置，然后再递推确定剩余位置。

假设我们要确定位置 $i$，则令 $a_i \gets n$，交互库即得到 $b_i=p_i+n$。我们枚举 $v \in [1,n)$，并令 $a_j \gets v, j \ne i$，那么交互库得到 $b_j=p_i+v$。

- 若 $p_i \ne n$，那么如果我们猜中了 $p_i=v$，排列必然有一个位置满足 $p_j=n$，所以在枚举到这个 $v$ 时就得到答案。
- 若 $p_i=n$，则将所有 $v$ 问完都没有答案。

因为交互库返回的是 $k_{\min}$，我们应该先确定 $p_n$，否则后面的情况无法确定。

我们考虑确定 $v$ 的位置，那么只需令 $a$ 形如 $[n+1-v,n+1-v,\cdots,n+1-v,n+1-p_i]$，询问结果就是 $v$ 的下标，读者自证不难。

稍微卡一下无效询问，询问次数不超过 $2n-2$。

:::::

::::info[代码]

```cpp line-numbers
const int N = 105;
int n, a[N], p[N];
int ask() {
    cout << "? ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
    int x; return cin >> x, x;
}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << p[i] << ' ';
    cout << endl, exit(0);
}

void _main() {
    cin >> n, p[n] = n;
    for (int v = 1; v < n; v++) {
        fill(a + 1, a + n, v), a[n] = n;
        int x = ask();
        if (x != 0) {p[n] = v; break;}
    }
    for (int v = 1; v <= n; v++) {
        if (p[n] == v) continue;
        fill(a + 1, a + n, n + 1 - v), a[n] = n + 1 - p[n];
        int x = ask(); p[x] = v;
    }
    answer();
} 
```

::::

::::::success[题解：$n$ 次询问]
我们考虑在第一阶段直接求出 $\ge p_n$ 的所有数。这里我们换一个更好的构造方式：令 $a=[1,1,\cdots,1+v]$。

- 对于 $i<n$，有 $b_i=p_i+1$。
- 对于 $i=n$，有 $b_n=p_n+v+1$。

如果交互库返回的 $k \ne 0$，可得 $p_k+1=p_n+v+1$，得 $p_k=p_n+v$。反之我们有 $p_n=n-v+1$。

完成第一阶段后，我们求出 $<p_n$ 的所有元素。仍然枚举 $v$ 并确定其位置，令 $a=[1+v,1+v,\cdots,1+v,1]$ 即可，得到一个 $k$。同理得 $p_k=p_n-v$。

询问次数严格 $n$ 次。
::::::

::::info[代码]

```cpp line-numbers
const int N = 105;
int n, a[N], p[N];
int ask() {
    cout << "? ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
    int x; return cin >> x, x;
}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << p[i] << ' ';
    cout << endl, exit(0);
}

void _main() {
    cin >> n, p[n] = 1;
    for (int v = 1; v < n; v++) {
        fill(a + 1, a + n, 1), a[n] = 1 + v;
        int k = ask();
        if (k == 0) {
            p[n] = n - v + 1;
            break;
        } 
        p[k] = v;
    }
    for (int i = 1; i < n; i++) {
        if (p[i] > 0) p[i] += p[n];
    } 
    for (int v = 1; v < p[n]; v++) {
        fill(a + 1, a + n, 1 + v), a[n] = 1;
        int k = ask(); p[k] = p[n] - v;
    }
    answer();
} 
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB421$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1762d--stripe-python', 'GCD Queries · stripe-python', $AKB422$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1762D](https://www.luogu.com.cn/problem/CF1762D)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个 $0 \sim n-1$ 的排列 $a_i$。你可以给出 $i,j$，向交互库询问 $\gcd(i,j)$。
>
> 找到两个位置 $x,y$，使得 $a_x =0\lor a_y=0$ 成立。
>
> 多测，$\sum n \le 2 \times 10^4$，满分询问次数 $2n$，交互库非自适应。

:::::success[题解]
增量法。由 $\gcd(0,x)=x$，我们考虑三个数 $a,b,c$ 并询问 $\gcd(a,b),\gcd(a,c)$：

- 若 $\gcd(a,b)=\gcd(a,c)$，则 $a \ne 0$；
- 若 $\gcd(a,b)<\gcd(b,c)$，则 $b \ne 0$；
- 若 $\gcd(a,b)>\gcd(b,c)$，则 $c \ne 0$。

维护候选集合 $S$，加入一个数使用上述方法排除，直到剩下的 $|S|=2$ 即可。询问次数 $2n-4$。
:::::

:::::info[代码]

```cpp line-numbers
int n;
int ask(int i, int j) {
    cout << "? " << i << ' ' << j << endl;
    int x; cin >> x;
    return x;
}
void answer(int i, int j) {
    cout << "! " << i << ' ' << j << endl;
    int x; cin >> x;
}

void _main() {
    cin >> n;
    deque<int> q = {1, 2};
    for (int i = 3; i <= n; i++) {
        int x = ask(q[0], q[1]), y = ask(q[0], i);
        if (x == y) q.pop_front(), q.emplace_back(i);
        else if (x < y) q.pop_back(), q.emplace_back(i);
    }
    answer(q[0], q[1]);
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB422$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-2164g--stripe-python', 'Pointless Machine · stripe-python', $AKB423$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF2164G](https://www.luogu.com.cn/problem/CF2164G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一棵大小为 $n$ 的无根树。你可以给出一个 $1 \sim n$ 的排列 $p$，交互库对于每个 $1 \le i \le n$ 回答 $\{p_1,p_2,\cdots,p_i\}$ 的导出子图的边数。所有询问结束后交互库才会给出回答。
>
> 还原这棵树。
>
> 多测，$\sum n \le 5 \times 10^4$，满分询问次数 $31$，交互库非自适应。

:::::success[题解]
考虑毒药模型。对于第 $k$ 位，按照二进制下第 $k$ 位将所有节点分成两个集合 $V_0,V_1$。

我们进行如下两次询问：

- 构造排列 $p_0$，将 $V_0$ 放在前面，$V_1$ 放在后面。对于 $u \in V_1$，由于其前面包含了整个 $V_0$，因此通过差值可以求出 $V_0$ 中 $u$ 的邻居数目。
- 构造排列 $p_1$，将 $V_1$ 放在前面，$V_0$ 放在后面，原因同上。

经过上述询问，我们可以知道每个节点有多少个二进制第 $k$ 位不同的邻居，记为 $f(u,k)$。

考虑额外询问一次 $p=[n,n-1,\cdots,1]$，求出 $u$ 有多少个大于它的邻居。配合 $\max f(u,k)=1$ 的条件即可确定 $u$ 是否是叶子。

因此考虑拓扑排序还原树。对于零入度点 $u$，只需按位还原其邻居 $v$。

计算一下上述做法的询问次数为 $16 \times 2+1=33$ 次，无法通过。

考虑转三进制拆分。如果可行，询问次数就变成了 $10 \times 3+1=31$ 次，恰好通过。

这确实是可行的，我们给出如下三种排列：

- $p_0=[V_1,V_2,V_0]$；
- $p_1=[V_2,V_0,V_1]$；
- $p_2=[V_0,V_1,V_2]$。

多作一次差就能得到 $f(u,k)$。处理邻居时，我们无法直接拆位，因此记录一下累计偏移量，每次乘 $3^k$ 加入即可。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 5e4 + 5;
const int pw[] = {1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049, 177147};
int n, k, pos[N], cnt[N], off[N];
vector<vector<int>> a;
vector<vector<int>> q;
vector<vector<int>> val;
vector<int> s[N];
vector<array<int, 3>> b[N];
vector<pair<int, int>> e;

void addq(int i, int a, int b, int c) {
    vector<int> cur;
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == a) cur.emplace_back(u);
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == b) cur.emplace_back(u);
    for (int u = 1; u <= n; u++) 
        if (u / pw[i] % 3 == c) cur.emplace_back(u);
    q.emplace_back(cur);
}
void ask() {
    cout << q.size() << '\n';
    for (auto i : q) {
        for (auto u : i) cout << u << ' ';
        cout << '\n';
    } cout << flush;
    a.assign(q.size(), vector<int>(n + 1));
    for (int i = 0; i < (int)q.size(); i++) {
        for (int j = 1; j <= n; j++) cin >> a[i][j];
    }
}

bool vis[N];
void bfs() {
    queue<int> q;
    e.clear(), fill(vis + 1, vis + n + 1, 0);
    auto isleaf = [&](int u) -> bool {
        int v = u + off[u];
        if (v < 1 || v > n || u == v || vis[v]) return false;
        if (cnt[u] != (v > u ? 1 : 0)) return false;
        for (int i = 0; i < k; i++) {
            int d1 = u / pw[i] % 3, d2 = v / pw[i] % 3;
            if (s[u][i] != (v < u && d1 == d2 ? 1 : 0)) return false;
            for (int d = 0; d < 3; d++) {
                if (d == d1) continue;
                if (b[u][i][d] != (d2 == d ? 1 : 0)) return false;
            }
        } return true;
    };
    for (int i = 1; i <= n; i++) {
        if (isleaf(i)) q.emplace(i);
    }
    while (!q.empty()) {
        int u = q.front(), v = u + off[u]; q.pop();
        if (vis[u] || !isleaf(u)) continue;
        e.emplace_back(u, v), vis[u] = true;
        off[v] -= u - v;
        if (u > v) cnt[v]--;
        for (int i = 0; i < k; i++) {
            int d1 = u / pw[i] % 3, d2 = v / pw[i] % 3;
            if (d1 == d2) s[v][i] -= u < v;
            else b[v][i][d1]--;
        } 
        if (!vis[v] && isleaf(v)) q.emplace(v);
    }
}

void _main() {
    cin >> n; q.clear();
    for (int i = 0; pw[i] <= n; i++) addq(i, 1, 2, 0), addq(i, 2, 0, 1), addq(i, 0, 1, 2);
    k = q.size() / 3, q.emplace_back();
    for (int i = 1; i <= n; i++) q.back().emplace_back(n - i + 1);
    ask();
    val.assign(q.size(), vector<int>(n + 1));
    for (int i = 0; i < (int)q.size(); i++) {
        fill(pos, pos + n + 1, 0);
        for (int j = 0; j < n; j++) pos[q[i][j]] = j + 1;
        for (int u = 1; u <= n; u++) val[i][u] = a[i][pos[u]] - a[i][pos[u] - 1];
    }
    for (int i = 1; i <= n; i++) b[i].assign(k, {0, 0, 0});
    fill(off + 1, off + n + 1, 0);
    for (int i = 1; i <= n; i++) s[i].assign(k, 0);
    for (int u = 1; u <= n; u++) {
        for (int i = 0; i < k; i++) {
            int d = u / pw[i] % 3;
            int q0 = 3 * i + d, q1 = 3 * i + (d + 1) % 3, q2 = 3 * i + (d + 2) % 3;
            int e1 = val[q0][u] - val[q1][u], e2 = val[q1][u] - val[q2][u];
            b[u][i][(d + 1) % 3] = e1, b[u][i][(d + 2) % 3] = e2;
            off[u] += e1 * ((d + 1) % 3 - d) * pw[i] + e2 * ((d + 2) % 3 - d) * pw[i];
            s[u][i] = val[q2][u];
        }
        cnt[u] = val.back()[u];
    }
    bfs();
    for (auto& i : e) cout << i << '\n';
    cout << flush;
} 
```

:::::

## 还原图 / 图找点

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB423$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-2178e--stripe-python', 'Flatten or Concatenate · stripe-python', $AKB424$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF2178E](https://www.luogu.com.cn/problem/CF2178E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，$a_i$ 由以下方式生成：
>
> - 初始时有两个序列 $a=b=[2^k]$。
> - 每轮中，可以选择 $a$ 或 $b$ 序列中的最大值 $x$，将 $x$ 替换为两个 $x/2$，需要保证 $x$ 为偶数。
> - 或者选择将 $a,b$ 拼接起来，并将 $a,b$ 都替换为拼接后结果。
>
> 你可以向交互库询问一个区间的和。
>
> 求出 $a_i$ 中的最大值。
>
> 多测，$\sum n \le 10^5$，满分询问次数 $300$。

:::::success[题解]
首先我们发现拼接操作是诈骗，取一个足够大的 $k$ 可以做到和拼接同样的效果。

因此只考虑替换。可以发现，这个操作不会改变序列的和。

假设当前序列的总和为 $s$。则我们只需找到一个 $i$ 使得前 $i$ 个数的和为 $s/2$，就可以将数组分成两部分，然后分治求解。$i$ 可以通过二分找到。询问次数大概是 $n \log^2 n$ 的，无法通过。

一个关键的观察是：最大值一定出现在长度更短的一侧。因为操作强制选最大值，所以最大值只会不变或除二，单调不降。因此选择较短的一侧递归即可，次数 $\log^2 n$。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
int ask(int l, int r) {
    cout << "? " << l << ' ' << r << endl;
    int u; cin >> u;
    return u;
}
int n;

int solve(int l, int r, int sum) {
    if (l == r) return sum;
    int lo = l, hi = r, p = -1;
    while (lo <= hi) {
        int mid = (lo + hi) >> 1, val = ask(l, mid);
        if (val == sum / 2) {p = mid; break;}
        if (val < sum / 2) lo = mid + 1;
        else hi = mid - 1; 
    }
    if (p - l + 1 <= r - p) return solve(l, p, sum >> 1);
    return solve(p + 1, r, sum >> 1);
}

void _main() {
    cin >> n;
    int x = solve(1, n, ask(1, n));
    cout << "! " << x << endl;
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB424$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-2179f--stripe-python', 'Blackslex and Another RGB Walking · stripe-python', $AKB425$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF2179F](https://www.luogu.com.cn/problem/CF2179F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一个 $n$ 个点 $m$ 条边的连通二分图，需要为每个节点染 `rgb` 中的一种颜色。
> - B：接到 $q$ 次询问，给出一个节点所有邻居的颜色集合，需要回答一个邻居，使得向这个邻居行动后离节点 $1$ 更近。
>
> $n,m,q \le 10^5$。

:::::success[题解]
先考虑 A。我们从 $1$ 开始 BFS 出一棵最短路树，然后用颜色来标记这棵最短路树的一些信息。不难发现可以用深度 $\bmod 3$ 来记录，分别染色为 `rgb` 即可。

对于 B，我们得到颜色集合 $S$。若 $|S|=1$，任意走一个邻居即可；否则必有 $|S|=2$。此时我们找到缺失的颜色，即当前节点颜色。

根据当前节点的颜色，我们可以知道向什么颜色走可以拉近距离。例如当前节点颜色为 `r` 时，根据染色规则我们应该往 `b` 走。

A & B 复杂度均为 $O(n+m)$。
:::::

:::::info[代码]
A：

```cpp line-numbers
int n, m, vis[N], dis[N];
vector<int> e[N];
void bfs(int u) {
    queue<int> q;
    q.emplace(u), dis[u] = 0, vis[u] = true;
    while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) {
            if (!vis[v]) dis[v] = dis[u] + 1, q.emplace(v), vis[v] = true;
        }
    }
}

void _main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int i = 1, u, v; i <= m; i++) {
        cin >> u >> v;
        e[u].emplace_back(v), e[v].emplace_back(u);
    }
    fill(vis + 1, vis + n + 1, 0), bfs(1);
    for (int i = 1; i <= n; i++) cout << "rgb"[dis[i] % 3];
    cout << '\n';
}
```

B：

```cpp line-numbers
int q;
string s;
void _main() {
    for (cin >> q; q--; ) {
        int d; string s; cin >> d >> s;
        set<char> st = {'r', 'g', 'b'};
        for (char c : s) {
            if (st.count(c)) st.erase(c);
        }
        if (st.size() == 2) {
            cout << 1 << '\n';
        } else {
            char x = *st.begin(), y = (x == 'r' ? 'b' : x == 'b' ? 'g' : 'r');
            cout << s.find(y) + 1 << '\n';
        }
    }
}
```

:::::

### 【未完成】[CF1033E Hidden Bipartite Graph](https://www.luogu.com.cn/problem/CF1033E)

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB425$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-loj-6669--stripe-python', 'Nauuo and Binary Tree · stripe-python', $AKB426$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[LOJ6669](https://loj.ac/p/6669)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个大小为 $n$ 的二叉树，根节点为 $1$。可以向交互库询问树上两点间距离。
>
> 求出每个点的父亲。
>
> $n \le 3 \times 10^3$，满分询问次数 $3 \times 10^4$。

:::::success[题解]
可以先通过 $n-1$ 次询问求出每个点的深度。这样询问两点距离还能知道其 LCA 的深度。

将节点按深度升序排序，我们就获得了一个层序遍历。不妨直接扫描这个序列，对于每个点 $x$ 找到其父亲。

这里直接暴力是 $O(n^2)$ 的，我们可以对树进行重链剖分。每次询问 $x$ 和重链底的距离，求出其 LCA 深度以后对应到重链上的具体节点。

因为本题是二叉树，我们可以直接进入 LCA 的另一棵子树去递归，重复上述流程即可。

操作次数为 $n \log n$ 级别，且重剖带 $1/2$ 常数。每次枚举点并暴力树剖，时间复杂度 $O(n^2)$，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3005;
int n, dep[N], fa[N], sz[N], son[N], bot[N], ch[2][N];
vector<int> vec[N];
int ask(int u, int v) {
    if (u == v) return 0;
    cout << "? " << u << ' ' << v << endl;
    int x; cin >> x;
    return x;
}

#define ls ch[0][u]
#define rs ch[1][u]
void dfs(int u) {
    sz[u] = 1, bot[u] = u, son[u] = 0;
    for (int v : {ls, rs}) {
        if (v == 0) continue;
        dfs(v), sz[u] += sz[v];
        if (sz[v] > sz[son[u]]) son[u] = v;
    }
    if (son[u]) bot[u] = bot[son[u]];
}
void solve(int x) {
    int u = 1;
    while (true) {
        int d = (dep[x] + dep[bot[u]] - ask(x, bot[u])) / 2;
        while (dep[u] < d) u = son[u];
        if (dep[u] == dep[x] - 1) break;
        u = (ls != son[u] ? ls : rs);
    }
    fa[x] = u;
    if (ls == 0) ls = x;
    else rs = x;
}

void _main() {
    cin >> n;
    for (int i = 2; i <= n; i++) {
        dep[i] = ask(1, i);
        vec[dep[i]].emplace_back(i);
    }
    for (int i = 1; i <= n; i++) {
        dfs(1);
        for (int x : vec[i]) solve(x);
    }
    cout << "! ";
    for (int i = 2; i <= n; i++) cout << fa[i] << ' ';
    cout << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB426$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10243--stripe-python', '[THUSC 2021] 种树 · stripe-python', $AKB427$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10243](https://www.luogu.com.cn/problem/P10243)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一棵 $n$ 个点的无标号树，需要传递一个二进制串。
> - B：已知这个二进制串，需要还原这棵树。
>
> $n \le 70$，满分要求 bit 数 $\le 128$。

:::::success[题解]
括号序和树的形态之间形成了双射，故考虑求出括号序。但是直接做需要 $2n-2$ 个 bit，无法通过。

继续压缩信息，发现括号序的问题是不合法序列也会被算入。我们可以用合法括号序的字典序来记录一个括号序列，求字典序和从字典序还原都是[经典问题](https://oi-wiki.org/topic/bracket/#%E5%AD%97%E5%85%B8%E5%BA%8F%E8%AE%A1%E7%AE%97)。由于 $H_{n-1} \le 2^{128}$ 可以通过。

于是做完了，复杂度 $O(n^2)$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 150;
u128 f[N][N];
bool init;
void work() {
    if (init) return;
    f[0][0] = 1;
    for (int i = 1; i <= 140; i++) {
        f[i][0] = f[i - 1][1];
        for (int j = 1; j <= i; j++) 
            f[i][j] = f[i - 1][j - 1] + f[i - 1][j + 1];
    }
    init = true;
}

u128 encoder(int n, const int* p) {
    vector<vector<int>> e(n + 5);
    for (int i = 2; i <= n; i++) e[p[i]].emplace_back(i);
    string s;
    function<void(int)> dfs = [&](int u) -> void {
        for (int v : e[u]) s += '(', dfs(v), s += ')';
    };
    dfs(1), work();
    u128 rnk = 0;
    for (int i = 0, pre = 0; i < (int)s.size(); i++) {
        int j = (int)s.size() - i - 1;
        if (s[i] == '(') pre++;
        else rnk += f[j][pre + 1], pre--;
    }
    return rnk;
}
void decoder(int n, u128 M, int* p) {
    work();
    u128 rnk = M;
    string s;
    for (int i = 0, pre = 0; i < 2 * (n - 1); i++) {
        int j = 2 * (n - 1) - i - 1;
        u128 v = f[j][pre + 1];
        if (rnk < v) s += '(', pre++;
        else s += ')', pre--, rnk -= v;
    }
    int u = 1, v = 2;
    stack<int> st; st.emplace(1);
    p[1] = 0;
    for (char c : s) {
        if (c == '(') p[v] = u, st.emplace(v), u = v++;
        else st.pop(), u = st.top();
    }
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB427$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10384--stripe-python', '「HOI R1」杂交选种 · stripe-python', $AKB428$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10384](https://www.luogu.com.cn/problem/P10384)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 现有 $n$ 个个体，每个个体的基因型为 $\tt{AA}, \tt{Aa}, \tt{aa}$ 之一。每次操作可以向交互库询问一个个体的性状，或者令交互库将两个个体杂交，不能自交。杂交次数不能超过 $T$。
>
> 还原原本的基因序列。
>
> $n \le 2 \times 10^4$，满分要求 $T=4.5 \times 10^5$，交互库非自适应。

:::::success[题解]
考虑 Subtask 3 的做法，先一遍扫描扫出 $\tt{aa}$，然后用这个 $\tt{aa}$ 与其他含有 $\tt{A}$ 的个体杂交 $22$ 次，若杂交结果出现 $\tt{aa}$ 则确定为 $\tt{Aa}$，否则认定为 $\tt{AA}$，错误率极低。可以获得 [25 分](https://www.luogu.com.cn/record/269213539)。

这启示我们设法造出一个 $\tt{aa}$。如果允许自交，一个简单的做法就是扫一遍序列，然后将所有元素多次自交，这样 $\tt{Aa}$ 就有 $1/4$ 的概率造出 $\tt{aa}$。

本题不允许自交，那么我们有一种替代方法是让 $\tt{Aa}$ 与其后代杂交。具体地，我们随机一个个体先与当前个体杂交，则我们有 $\tt{AA} \times \tt{Aa} \to \tt{Aa}$，然后用 $\tt{Aa}$ 与 $\tt{Aa}$ 杂交即可。

由于上述策略错误率较高，我们用一个 vector 记录下其所有后代，并且随机一个后代进行杂交。

进行一些调参，将后代杂交重复 $12$ 次，得到 $\tt{aa}$ 以后的杂交上界根据当前杂交次数决定。这样可以通过本题，进行 $10$ 次提交测试中有 $4$ 次可以 AC。
:::::

:::::info[代码]

```cpp line-numbers
vector<string> guess(int n) {
    int cur = n;
    auto mix = [&](int u, int v) -> int {return cross(u, v), ++cur;};
    vector<string> res(n, "AA");
    vector<int> a(n + 5);
    for (int i = 1; i <= n; i++) a[i] = (query(i) == 'a');
    auto work = [&](int p, int lim) -> void {
        for (int i = 1; i <= n; i++) {
            if (a[i] == 1) {
                res[i - 1] = "aa";
            } else {
                int T = lim;
                while (T--) {
                    int x = mix(p, i);
                    if (query(x) == 'A') continue;
                    res[i - 1] = "Aa";
                    break;
                }
            }
        }
    };
    int p = find(a.begin(), a.end(), 1) - a.begin(); 
    if (p != (int)a.size()) return work(p, 22), res;
    for (int i = 1; i <= n; i++) {
        int x = rand32() % n + 1, T = 12;
        while (x == i) x = rand32() % n + 1;
        vector<int> son = {x};
        while (T--) {
            int idx = rand32() % son.size();
            int now = mix(son[idx], i);
            if (query(now) == 'a') return work(now, (4.5e5 - cur + n) / n), res;
            son.emplace_back(now), son.emplace_back(now);
        }
    }
    return res;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB428$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10539--stripe-python', '[APIO2024] 魔术表演 · stripe-python', $AKB429$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10539](https://www.luogu.com.cn/problem/P10539)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一个正整数 $x$，需要传递一棵节点数为 $n$ 的树。
> - B：已知传输的树，还原 $x$。
>
> 通信过程中，至多 $\lfloor \frac{n-2}{2} \rfloor$ 条边会被交互库删除。
>
> $1 \le x \le 10^{18}$，满分要求 $n \le 5000$。

:::::success[题解]
感觉这个题有一万种做法。下面给出一个思维难度小，且比较奶龙的做法。

考虑拆二进制位。对于节点 $u$，随机一个 $d_u \in [0,60)$，然后用 $u$ 维护 $x$ 二进制下第 $d_u$ 位。

直接连边可能会有一些度数上的问题，会被交互库识别并卡掉。考虑对于 $3 \le u \le 5000$，随机 $a_u,b_u$ 为其两个备选父亲，二进制为 $1$ 则连边 $a_u \to u$，否则连边 $b_u \to u$。

只要 $n=5000$，上述做法大概率能得到树，且不会被卡掉。

随机数生成器使用相同种子，可以保证 $d_u,a_u,b_u$ 都一致。B 收到树以后简单还原即可。
:::::

:::::info[代码]
A:

```cpp line-numbers
const int N = 5005;
using node = pair<int, int>;
static mt19937 rand32(2026);
static int d[N], a[N], b[N];

vector<pair<int, int>> Alice() {
    const int n = 5000;
    for (int i = 3; i <= n; i++) {
        d[i] = rand32() % 60;
        do a[i] = rand32() % (i - 1) + 1, b[i] = rand32() % (i - 1) + 1;
        while (a[i] == b[i]);
    }
    vector<node> e;
    i64 x = setN(n);
    for (int i = 3; i <= n; i++) {
        if (x >> d[i] & 1) e.emplace_back(a[i], i);
        else e.emplace_back(b[i], i);
    }
    e.emplace_back(1, 2);
    return e;
}
```

B：

```cpp line-numbers
const int N = 5005;
using node = pair<int, int>;
static mt19937 rand32(2026);
static int d[N], a[N], b[N], has[N];

i64 Bob(vector<node> V) {
    const int n = 5000;
    for (int i = 3; i <= n; i++) {
        d[i] = rand32() % 60;
        do a[i] = rand32() % (i - 1) + 1, b[i] = rand32() % (i - 1) + 1;
        while (a[i] == b[i]);
    }
    for (auto [u, v] : V) {
        if (u == a[v]) has[v] = 1;  
        if (v == a[u]) has[u] = 1;
    }
    i64 x = 0;
    for (int i = 3; i <= n; i++) {
        if (has[i]) x |= 1LL << d[i];
    } return x;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB429$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10786--stripe-python', '[NOI2024] 百万富翁 · stripe-python', $AKB430$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10786](https://www.luogu.com.cn/problem/P10786)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以进行 $T$ 次并行询问，并行询问包含至多 $S$ 个单独问题 $(i,j)$，若 $p_i>p_j$ 返回 $i$，否则返回 $j$。
>
> 找出排列中最大值出现的位置。
>
> - 测试点 #1：$n=10^3$，满分要求 $T=1,S=499500$；
> - 测试点 #2：$n=10^6$，满分要求 $T=8,S=1099944$。
>
> 交互库自适应。

:::::success[题解]

首先测试点 #1 就是检查你题目读懂了没有，懂了以后直接把所有 $i<j$ 的 $(i,j)$ 都问一遍即可。一次询问，询问大小为 $\frac{n(n-1)}{2}=499500$。

对于测试点 #2，一个直接的想法是分治，每层二分一下，会形成一个类似线段树的结构，要询问 $20$ 次。注意到题目要求我们把询问减少到 $8$ 次，考虑一个类似 $k$ 叉线段树的策略，每层分 $k$ 块，块内按照 #1 那样两两询问，这样可以得到 $k$ 个胜者进入下一层。

可以用 Turán 定理说明上述策略的最优性。因此恰当的块长一定可以得到最优询问次数。

那么现在这题实际上转化为一个提答题：确定一个长为 $8$ 的序列 $a$ 表示每层的块长。

我自己做的时候直接乱搞出来了。下面叙述正解，可以发现，将 $n$ 个人分 $k$ 块的询问次数为
$$
f(n,k)=(k-n\bmod k)\times \binom{\left\lfloor \frac{n}{k} \right\rfloor}{2}+(n\bmod k)\times \binom{\left\lfloor \frac{n}{k} \right\rfloor+1}{2}
$$

则序列 $a$ 的询问次数为
$$
g(a)=\sum_{i=0}^7 f(a_i,a_{i+1})
$$
对策略进行 DP。设 $dp_{n,k} $ 表示第 $n$ 层，分 $k$ 块的最小代价，枚举下一层分 $k' $ 块可以做到 $O(Tn^2)$，本地需要较长时间。

注意到 $f(n,k)$ 是一个与 $\left\lfloor \frac{n}{k} \right\rfloor$ 有关的式子，所以大量 DP 状态的答案是重复的。考虑数论分块优化 DP，那么复杂度降到 $O(Tn\sqrt{n})$，本机 <1s 即可跑出答案。

:::::

::::info[代码]

这是 DP 代码。

```cpp line-numbers
#define int long long
const int N = 1e6 + 5;
int f(int x) {return x * (x - 1) / 2;}
int g(int x, int y) {return (y - (x % y)) * f(x / y) + x % y * f(x / y + 1);}
int dp[10][N];
int dfs(int n, int k) {
	if (dp[k][n]) return dp[k][n];
	if (k == 1) return f(n);
	vector<int> vec;
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		if (l > 1) vec.emplace_back(l);
		if (r > l) vec.emplace_back(r);
	}
	dp[k][n] = 1e18;
	for (int x : vec) {
		int v = dfs(x, k - 1) + g(n, x);
		if (v < dp[k][n]) dp[k][n] = v;
	}
	return dp[k][n];
}
void out(int n, int k) {
	if (k == 1) return cout << 1, void();
	vector<int> vec;
	for (int l = 1, r; l <= n; l = r + 1) {
		r = min(n, n / (n / l));
		if (l > 1) vec.emplace_back(l);
		if (r > l) vec.emplace_back(r);
	}
	for (int x : vec) {
		if (dp[k][n] == dfs(x, k - 1) + g(n, x)) {
			cout << x << ", ", out(x, k - 1);
			break;
		}
	}
}

void _main() {
	cout << dfs(1000000, 8) << endl;
	out(1000000, 8);
}
```

在运行后的输出如下：

```cpp
1099944
500000, 250000, 125000, 62500, 20833, 3472, 183, 1
```

写到交互程序中即可。

```cpp line-numbers
int work1() {
	vector<int> a, b;
	for (int i = 0; i < 1000; i++) {
		for (int j = i + 1; j < 1000; j++) a.emplace_back(i), b.emplace_back(j);
	}
	auto c = ask(a, b);
	vector<int> cnt(1000, 0);
	for (int i : c) cnt[i]++;
	for (int i = 0; i < 1000; i++) {
		if (cnt[i] >= 999) return i;
	}
	throw -1;
}
const int a[] = {1000000, 500000, 250000, 125000, 62500, 20833, 3472, 183, 1};
int richest(int N, int T, int S) {
	if (N == 1000 && T == 1 && S == 499500) return work1();
	vector<int> q;
	for (int i = 0; i < N; i++) q.emplace_back(i);
	for (int x = 1; x < 9; x++) {
		vector<int> u, v;
		for (int i = 0, l = 0, r; i < a[x]; i++, l = r) {
			r = l + a[x - 1] / a[x];
			if (i < a[x - 1] % a[x]) r++;
			for (int j = l; j < r; j++) {
				for (int k = j + 1; k < r; k++) u.emplace_back(q[j]), v.emplace_back(q[k]);
			}
		}
		auto w = ask(u, v);
		vector<int> cnt(N);
		for (int i = 0; i < (int) w.size(); i++) {
			if (w[i] == u[i]) cnt[v[i]]++;
			else cnt[u[i]]++;
		}
		vector<int> nxt;
		for (int i = 0; i < (int) q.size(); i++) {
			if (!cnt[q[i]]) nxt.emplace_back(q[i]);
		}
		q = nxt;
	}
	return q[0];
}
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB430$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p11647--stripe-python', '【MX-X8-T6】「TAOI-3」俄罗斯蓝猫 · stripe-python', $AKB431$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P11647](https://www.luogu.com.cn/problem/P11647)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个长度为 $n$ 的非负整数序列 $a_0 \sim a_{n-1}$，保证 $a_i$ 在 $[0,10^{18}]$ 中随机生成。
>
> 你可以进行 $A$ 次询问，每次询问可以给出不超过 $B$ 个二元组 $(x_i,y_i)$，交互库返回 $a_{x_i}+a_{y_i}$ 构成的集合。
>
> 还原这个序列。
>
> 多测，$T=20$，$5 \le n \le 500$，满分要求 $A \le 2$，$B \le n-1$，$x_i \ne y_i$，每个 $(x_i,y_i)$ 在所有询问中至多出现 $1$ 次。3 秒，496 MB。

:::::success[题解]

由于 $a_i$ 在大值域中随机，不妨认为 $a_i$ 和 $a_i+a_j$ 都不重。

用图论语言刻画，第 $i$ 次询问 $(x,y)$ 相当于建一条 $x \leftrightarrow y$ 的无向边，并将边染上颜色 $i$。如果这个图存在自同构，则必然无法确定答案。

这样就能说明询问单链 / 单环 / 菊花必然不可行，同时表明构造的思路就是破坏对称性。

考虑对着平凡构造调整。做如下两次询问：

- $Q_1$：询问 $(0,1),(0,2),\cdots,(0,n-1)$ 构成一个菊花。
- $Q_2$：询问 $(1,2),(2,3),\cdots,(1,n-1)$ 构成一个环。

这个构造显然会爆。将 $Q_1,Q_2$ 中的 $(0,n-1)$ 和 $(1,2)$ 交换，那么 $Q_1$ 变成菊花带一个三元环，$Q_2$ 变成链上挂一个节点 $0$。下面给出 $n=5$ 时的图：

![](https://cdn.luogu.com.cn/upload/image_hosting/iydvngmx.png)

三元环和环上的点都不能轮换，故该图无自同构。

设两次询问得到的集合为 $S_1,S_2$，我们枚举 $x \in S_1$ 表示 $a_1+a_2=x$，再枚举 $y \in S_2$ 表示 $a_0+a_{n-1}=y$。将 $S_1 \setminus \{x\}$ 和 $S_2 \setminus \{y\}$ 作为下面求解的依据。

记 $s_1=\sum S_1 , s_2 = \sum S_2$，根据定义
$$
\begin{aligned}
s_1&=(n-2)a_0+\sum_{i=1}^{n-2} a_i\\
s_2&=2\left(\sum_{i=1}^{n-1} a_i\right)-(a_1+a_2)\
\end{aligned}
$$
再设 $s=\sum \limits_{i=1}^{n-1} a_i$，代入得 $s_1=(n-2)a_0+s-a_{n-1}$ 和 $s_2=2s-x$。枚举 $x,y$ 后联立 $a_0+a_{n-1}=y$ 得到三个方程，可以解得

$$
a_0=\dfrac{s_1-s+y}{n-1}
$$

这里可以加若干剪枝，即 $a_0$ 非负且 $a_0$ 是整数。

求出 $a_0$ 后再解方程求出 $a_1,a_2$，进而顺着环推一圈，检查最后得到的 $a_{n-1}$ 是否为 $y-a_0$ 即可。

单次 check 是 $O(n^2)$ 的，所以总复杂度似乎是 $O(n^4)$ 的。不过注意到枚举的 $x,y$ 正确率为 $\frac{1}{n}$，那么期望复杂度就是 $O(n^3)$。

::::::

::::::info[代码]

```cpp line-numbers
vector<i64> game(int n) {
    vector<i64> a(n);
    vector<int> x1 = {1}, y1 = {2};
    for (int i = 1; i < n-1; i++) x1.emplace_back(0), y1.emplace_back(i);
    vector<i64> S1 = ask(x1, y1);
    vector<int> x2 = {0, 1}, y2 = {n - 1, n - 1};
    for (int i = 2; i < n-1; i++) x2.emplace_back(i), y2.emplace_back(i+1);
    vector<i64> S2 = ask(x2, y2);
    i128 s1 = accumulate(S1.begin(), S1.end(), i128(0));
    i128 s2 = accumulate(S2.begin(), S2.end(), i128(0));
    auto check = [&](i64 x, i64 y) -> bool {
        set<i64> T1, T2(S2.begin(), S2.end());
        for (i64 v : S1) {
            if (v == x) continue;
            if (v < a[0]) return false;
            T1.emplace(v - a[0]);
        }
        for (i64 a1 : T1) {
            auto chk = [&]() -> bool {
                a[1] = a1, a[2] = x - a[1];
                if (!T1.count(a[2])) return false;
                set<i64> K1 = T1, K2 = T2;
                K1.erase(a[1]), K1.erase(a[2]), K2.erase(y);
                if (!K2.count(a[1] + a[n-1])) return false;
                K2.erase(a[1] + a[n-1]);
                for (int i = 3; i < n - 1; i++) {
                    bool fl = false;
                    for (i64 ai : K1) {
                        if (!K2.count(ai + a[i-1])) continue;
                        K1.erase(ai), K2.erase(ai + a[i-1]);
                        a[i] = ai; fl = true; break;
                    }
                    if (!fl) return false;
                }
                if (K2.count(a[n-2] + a[n-1])) return true;
            };
            if (chk()) return true;
        }
        return false;
    };
    for (i64 x : S1) for (i64 y : S2) {
        if ((s2 - y + x) & 1) continue;
        i128 num = s1 - x + y - (s2 - y + x) / 2;
        if (num < 0 || num % (n - 1)) continue;
        a[0] = num / (n - 1), a[n-1] = y - a[0];
        if (a[n-1] < 0) continue;
        if (check(x, y)) return a;
    } 
    return {};
}
```

::::::

### 【未完成】[CF1292E Rin and The Unknown Flower](https://www.luogu.com.cn/problem/CF1292E)

## 还原树 / 树找点

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB431$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p12202--stripe-python', '[COI 2022] 回文子串 / Madioničar · stripe-python', $AKB432$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P12202](https://www.luogu.com.cn/problem/P12202)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个字符串 $S$，长为 $n$。你可以向交互库询问一个子串是否回文。
>
> 找出最长回文子串长度。
>
> $n \le 10^5$，满分询问次数 $2n$，交互库非自适应。

:::::success[题解]

$n \log n$ 显然，枚举回文中心然后二分长度即可。

Manacher 似乎可以做到 $4n$，但并没有什么启示。

我们考虑优化 $n \log n$ 的暴力：考虑最优性剪枝，记当前答案为 $x$，每次只询问比 $x$ 大的长度，这可以直接暴力扩展。由于 $x$ 最多移动 $n$ 次，询问次数就是严格 $n$ 次。奇偶分别问一次，次数 $2n$。 

:::::

::::info[代码]

```cpp line-numbers
bool ask(int l, int r) {
	cout << "? " << l << ' ' << r << endl;
	int x; cin >> x;
	return x;
}
void answer(int n) {
	cout << "! " << n << endl;
	exit(0);
}

int n;
void _main() {
	cin >> n;
	int x = 0, y = 0;
	for (int i = 1; i <= n; i++) {
		for (int j = x + 1; 1 <= i - j && i + j <= n; j++) {
			if (!ask(i - j, i + j)) break;
			x++;
		}
		for (int j = y + 1; 1 <= i - j && i + j + 1 <= n; j++) {
			if (!ask(i - j, i + j + 1)) break;
			y++;
		}
	}
	if (y == 0) answer(2 * x + 1);
	else answer(max(2 * x + 1, 2 * y + 2));
}
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB432$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p12446--stripe-python', '[COTS 2025] 答好位 / Vrsta · stripe-python', $AKB433$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P12446](https://www.luogu.com.cn/problem/P12446)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个 $1 \sim n$ 的排列 $p_i$。你可以进行 $K$ 次询问，给出 $l,r$ 得到区间 $[l,r]$ 中次大值的下标。
>
> 询问结束后，交互库进行 $Q$ 次询问，给出 $l,r$，你需要回答区间 $[l,r]$ 中次大值的下标。
>
> $n \le 512$，满分要求 $K=Q=2048 $，交互库非自适应。

:::::success[题解]

题意等价于 $K$ 次询问，还原所有区间的次大值下标。我们先打表观察区间次大的结构。这里以 $p=[4,7,3,6,1,5,8,2]$ 为例：

![](https://cdn.luogu.com.cn/upload/image_hosting/qzls7855.png)

**性质** 每个下标 $x$ 所在的区域必然为若干矩形。

**证明** 考虑区间 $[l_0,r_0]$，设其最大值下标为 $y$，次大值下标为 $x$，不妨设 $y<x$。易知 $l \in [l_0,y]$ 且 $r \in [x, r_0]$ 的 $[l,r]$ 的次大值位置全为 $y$。在二维平面上，这恰好是矩形 $[l_0,y] \times [x,r_0]$。

基于此编一个做法：考察全局区间 $[1,n]$，先询问得到次大值 $y$，并设法得到最大值 $x$。根据上述结论，$[1,y] \times [x,n]$ 的矩形可以被填好：

![](https://cdn.luogu.com.cn/upload/image_hosting/pqvn3tib.png)

更一般地，考虑分治处理，设计递归状态为处理区间 $[l,r]$，且已知区间 $\max$ 的位置为 $y$。对 $[l,r]$ 询问即得 $x$，将 $[l,y] \times [x,r]$ 填好。

此时相当于挖去右上角的一个矩形，问题规约到左上角和右下角的三角形区域，即 $[l,x)$ 和 $(y,r]$。

![](https://cdn.luogu.com.cn/upload/image_hosting/7y61m0qe.png)

我们分析两个区域的最大值位置：

- $[l,y)$ 区域：由于 $x \in [l,y)$，故最大值还是 $x$。
- $(x,r]$ 区域：由于 $y \in (x,r]$ 且 $y$ 是原本的次大值，故 $y$ 是新的最大值。

这表明，我们确实可以递归解决问题。判重以后这个部分只需要 $2n$ 次询问。

下面只要解决初始找全局 $\max$ 的问题。考虑增量法，初始维护 $[x,x]$，并将右端点 $r$ 不断扩展。当 $r \gets r+1$ 且次大值发生突变时，说明新加入的 $r$ 恰为全局 $\max$，对 $l$ 的扩展同理，询问次数 $n$。

总询问次数为 $3n$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 605;
int n, q, ans[N][N], vis[N][N];
int ask(int l, int r) {
    cout << "? " << l << ' ' << r << endl;
    int x; cin >> x;
    return x;
}

void solve(int l, int r, int y) {
    if (l == r) return;
    if (vis[l][r]) return;
    vis[l][r] = true;
    int x = ask(l, r);
    auto [lo, hi] = minmax(x, y);
    for (int i = l; i <= lo; i++)
        for (int j = hi; j <= r; j++) ans[i][j] = x;
    solve(l, hi - 1, lo), solve(lo + 1, r, hi);
} 

void _main() {
    cin >> n;
    int x = ask(1, n), l = x, r = x, y = -1;
    while (r < n && y == -1) if (ask(l, ++r) == x) y = r;
    while (l > 1 && y == -1) if (ask(--l, r) == x) y = l; 
    solve(1, n, y);
    cout << "!" << endl, cin >> q;
    for (int l, r; q--; ) cin >> l >> r, cout << ans[l][r] << endl;
} 
```
:::::

### 【未完成】[QOJ18206 Guess the Permutation](https://qoj.ac/problem/18206)

> 这是一道交互题。
>
> 交互库隐藏了一个 $0 \sim n$ 的排列 $p_i$，一次询问给出 $i,j$，交互库返回 $k$ 满足 $p_k=|p_i-p_j|$。
>
> 还原这个排列。
>
> 多测，$T \le 100$，$n \le 10^3$，满分询问次数 $1024$，交互库自适应。

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB433$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p12509--stripe-python', '通信题 · stripe-python', $AKB434$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P12509](https://www.luogu.com.cn/problem/P12509)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> 现有两个至多有一个位置不同的 01 串 $S,T$。
>
> - A：已知 $S$，需要传递一个非负整数 $x$，满足 $x < 2^{20}$。
> - B：已知 $T$ 和 $x$，需要输出两个串不同的位置。特别地，若 $S=T$，应输出 0。
>
> $n \le 10^6$。

:::::success[题解]
A 传递的 $x$ 一定要包含 $S$ 的某些信息。简单来说，A 是加密的过程，B 是解密的过程。

我们有很巧妙的构造：记 $f(S)$ 为 $S$ 所有 $1$ 的下标异或和，则 A 直接传递 $x=f(S)$ 即可。

在 B 这里，因为 $n-1$ 位都不会变动，所以两次异或可以直接消去，最后剩下的那个位置就是不同的位置。形式化地说，我们求出 $f(T) \oplus x$ 并输出。

A & B 复杂度 $O(n)$。
:::::

:::::info[代码]

```cpp line-numbers
int f(const string& s) {
    int n = s.size(), res = 0;
    for (int i = 0; i < n; i++) {
        if (s[i] == '1') res ^= i + 1;
    } return res;
}
int Alice(string s) {return f(s);}
int Bob(string t, int x) {return f(t) ^ x;}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB434$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14012--stripe-python', '[POCamp 2023] 枫树 / Maple Tree · stripe-python', $AKB435$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14012](https://www.luogu.com.cn/problem/P14012)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库有一个大小为 $n$ 的无根树，边带权。保证任意两点距离不同，且节点度数 $\le 3$。你可以给出 $a,b,c$，向交互库查询 $\text{dis}(a,b)<\text{dis}(a,c)$ 是否成立。
>
> 还原树的形态。
>
> $n \le 10^3$，满分询问次数 $2 \times 10^4$，交互库非自适应。

:::::success[题解]
不妨将 $1$ 作为根。令 $a=1$ 后一次查询相当于比较 $b,c$ 的深度，于是可以将所有点按照深度升序排序。

这得到的是一个拓扑序。考虑按拓扑序增量构造，一次加点就是加叶子，只需确定叶子的父亲。

另一个重要观察是，可以通过一次询问排除一半子树。具体地，对于叶子 $x$ 和边 $(u,v)$，询问 $\text{dis}(u,x)$ 和 $\text{dis}(v,x)$ 可以确定 $x$ 在 $u$ 子树还是 $v$ 子树中。

注意到树是三度化的，这恰好为边分治提供了条件。于是我们用边分治挂叶子，一次加点可以做到 $\log n$ 次询问。这样总询问次数就是 $2n \log n$ 的了，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 1005;
int n, p[N], sz[N], vis[N];
vector<int> e[N];
bool ask(int x, int y, int z) {
    cout << "? " << y << ' ' << z << ' ' << x << endl;
    char c; cin >> c;
    return c == 'A';
}

void dfs1(int u, int fa) {
    sz[u] = 1;
    for (int v : e[u]) {
        if (v == fa || vis[v]) continue;
        dfs1(v, u), sz[u] += sz[v];
    }
}
void dfs2(int u, int fa) {
    vis[u] = true;
    for (int v : e[u]) {
        if (v == fa || vis[v]) continue; 
        dfs2(v, u);
    }
}
void solve(int x, int u) {
    dfs1(u, -1); int c = sz[u];
    if (c == 1) {
        e[u].emplace_back(x), e[x].emplace_back(u);
        return;
    }
    int p = -1, q = -1, mw = 1e9;
    function<void(int, int)> dfs = [&](int u, int fa) -> void {
        for (int v : e[u]) {
            if (v == fa || vis[v]) continue;
            int w = max(sz[v], c - sz[v]);
            if (w < mw) p = u, q = v, mw = w;
            dfs(v, u);
        }
    };
    dfs(u, -1);
    if (ask(x, p, q)) dfs2(q, p), solve(x, p);
    else dfs2(p, q), solve(x, q);
}

void _main() {
    cin >> n;
    iota(p + 1, p + n + 1, 1);
    stable_sort(p + 2, p + n + 1, [](int x, int y) -> bool {
        return ask(1, x, y);
    });
    for (int i = 2; i <= n; i++) {
        fill(vis + 1, vis + n + 1, 0);
        solve(p[i], 1);
    }
    cout << "!\n";
    for (int u = 1; u <= n; u++) 
        for (int v : e[u]) if (u < v) cout << u << ' ' << v << '\n';
    cout << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB435$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p15652--stripe-python', '[省选联考 2026] 排列游戏 · stripe-python', $AKB436$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P15652](https://www.luogu.com.cn/problem/P15652)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以向交互库询问一个区间的 $\operatorname{mex}$。
>
> 还原这个排列。只要你给出的排列和正确排列每个区间的 $\operatorname{mex}$ 相等即认为答案正确。
>
> $n \le 3 \times 10^4$，满分询问次数 $n$。

:::::success[题解]

在排列中，区间 $\operatorname{mex}$ 等于补集 $\min$。形式化地
$$
\operatorname{mex} \limits_{i=l}^r p_i=\min\left\{\min_{i=1}^{l-1} p_i, \min _{i=r+1}^n p_i\right\}
$$
我们发现只有前后缀 $\min$ 是有用的，知道这 $2n$ 个信息后其他询问可以直接拼出来，所以先做 $2n$ 次询问。

询问完成后，在前后缀 $\min$ 产生突变的位置，我们可以确定答案。而两个已确定数中间只需要比它大即可，可以任意填入。

考虑缩减操作次数。我们发现问到 $0$ 以后前后缀 $\min$ 一定是 $0$，可以省略询问。猜数模型，二分求出 $0$，次数 $n+\log n$。

进一步，可以先问前缀 $\min$ 直到出现 $0$，此时我们就确定了 $0$ 的位置，从后面再开始问，次数压缩到 $n$。

:::::

::::info[代码]

```cpp line-numbers
vector<int> perm(int n) {
    vector<int> pre(n), suf(n), res(n, -1);
    int pos0 = n - 1;
    for (int i = 0; i < n - 1; i++) {
        pre[i] = query(i + 1, n - 1);
        if (pre[i] == 0) {pos0 = i; break;}
    }
    for (int i = n - 1; i > pos0; i--) suf[i] = query(0, i - 1);
    for (int i = 0; i < n - 1; i++) {
        if (i == 0 || pre[i] != pre[i - 1]) res[i] = pre[i];
    }
    for (int i = n - 1; i >= 1; i--) {
        if (i == n - 1 || suf[i + 1] != suf[i]) res[i] = suf[i];
    }
    set<int> q;
    vector<int> vis(n);
    for (int i = 0; i < n; i++) if (res[i] != -1) vis[res[i]] = 1;
    for (int i = 0; i < n; i++) if (!vis[i]) q.emplace(i);
    for (int l = -1, r = 0; r < n; r++) {
        if (res[r] == -1) continue;
        if (l == -1) {l = r; continue;}
        int low = max(res[l], res[r]);
        for (int i = l + 1; i < r; i++) {
            assert(!q.empty());
            auto it = q.upper_bound(low);
            assert(it != q.end());
            res[i] = *it;
            q.erase(it);
        }
        l = r;
    }
    return res;
}
```

::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB436$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p16536--stripe-python', '[THUPC 2026 决赛] 流光解密 · stripe-python', $AKB437$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P16536](https://www.luogu.com.cn/problem/P16536)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和一棵节点数为 $n$ 的数。交互库逐边地给出这棵树，你需要在线地将给出的边定向。
> - B：已知这棵树，还原 $k$。
>
> 交互库非自适应，即树的形态不会随交互流程改变。
>
> 多测，$T \le 10^4$，$n \le 30$，$1 \le k \le 2^{n-1}$。

:::::success[题解]

注意到 $k \le 2^{n-1}$，考虑拆二进制，即我们需要用边的方向表示 $k-1$ 的二进制位。

我们为每个点赋一个点权，节点 $i$ 的权值定义为 $k-1$ 在二进制下第 $i-2$ 位，节点 $1$ 的权值为 $0$。

对于边 $u,v$，不妨设 $u<v$，我们约定 $u \to v$ 的边权为 $0$，$v \to u$ 的边权为 $1$。

这样定向相当于给边赋权。考虑将边权设为两个节点的异或和。B 收到树后，从节点 $1$ 开始 DFS，做一遍树上前缀和即可得到 $k-1$。

:::::

:::::info[代码]

A：

```cpp line-numbers
int n, k;
void _main() {
    cin >> n >> k, k--;
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        if (u > v) swap(u, v);
        int a = k >> (u - 2) & 1, b = k >> (v - 2) & 1;
        if (a ^ b) cout << v << ' ' << u << endl;
        else cout << u << ' ' << v << endl;
    }
}
```

B：

```cpp line-numbers
const int N = 40;
int n, k;
vector<pair<int, int>> e[N];

void dfs(int u, int fa, int p) {
    if (u > 1 && p) k |= 1 << (u - 2);
    for (auto [v, w] : e[u]) 
        if (v != fa) dfs(v, u, p ^ w);
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int i = 1, u, v; i < n; i++) {
        cin >> u >> v;
        e[u].emplace_back(v, u > v), e[v].emplace_back(u, u > v);
    }
    k = 0, dfs(1, -1, 0);
    cout << k + 1 << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB437$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p7109--stripe-python', '滴水不漏 · stripe-python', $AKB438$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P7109](https://www.luogu.com.cn/problem/P7109)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个长为 $n$ 的序列 $a_i$，其中 $a_i$ 表示第 $i$ 个水杯中水的体积，第 $i$ 个水杯容量为 $i$。你可以给出 $i,j$，交互库将第 $i$ 个水杯中的水倒到第 $j$ 个水杯，并回答是否倒满。操作之间不独立。
>
> 还原原本的序列。
>
> $n \le 10^3$，满分询问次数 $2 \times 10^4$，交互库非自适应。

:::::success[题解]
考虑如下情景：当前需要确定 $x$ 水杯中水的体积，且 $[1,x)$ 的水杯均已清空。可以想到猜数模型，二分体积 $v$，然后倒水 $x \to v$，根据是否倒满来判断，判断以后再撤销操作。

我们依次确定每个水杯。如果能够做到这一点，询问次数就是 $2n \log n$ 且跑不满。

考虑用一个特殊水杯 $t$ 存多余的水。我们每次确定 $i$ 后将水导入，如果倒满就再次二分得到剩余水量，然后令 $t \gets t-1$。同时还要记录一下 $t$ 被倒入多少水，这样减一下就是答案。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 1005;
int n, a[N];
bool ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int u; cin >> u;
    return u;
}

int solve(int x, int lim) {
    if (lim == x) {
        if (ask(x, x)) return x;
        lim--;
    }
    if (lim <= 0) return 0;
    int l = 1, r = lim, res = 0;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (ask(x, mid)) l = mid + 1, res = mid;
        else r = mid - 1;
        ask(mid, x); 
    } return res;
}

void _main() {
    cin >> n;
    int t = n, sum = 0;
    for (int i = 1; i <= n; i++) {
        if (i == t) {
            a[t] = solve(t, t) - sum;
            break;
        }
        int cur = solve(i, i);
        a[i] = cur;
        while (cur > 0 && i < t) {
            if (ask(i, t)) {
                int x = solve(i, cur);
                a[t] = t - (cur - x) - sum;
                t--, sum = 0, cur = x;
            } else {
                sum += cur, cur = 0;
            }
        }
        if (t <= i) break;
    }
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB438$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p7356--stripe-python', '「PMOI-1」游戏 · stripe-python', $AKB439$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P7356](https://www.luogu.com.cn/problem/P7356)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 你需要与交互库博弈，交互库持有黑棋，你持有白棋，棋子只能下到坐标点上。
>
> 初始时，交互库第一步一定下在 $(0,0)$，之后双方轮流落子或 pass，直到局面上出现横竖斜任意方向连续的 `黑白白白`，则你胜利。设落子在 $(x,y)$，要求 $0 \le x, y \le 100$。
>
> 多测，$T \le 10^3$，满分胜利步数 $4$。

::::::success[题解]
关键在于注意到下面这种结构是一步杀：

![](https://cdn.luogu.com.cn/upload/image_hosting/gxn7vw1w.png)

此时黑棋如果堵左边，白棋下在右边即可，反之下在左边。

基于此，考虑第一步下在这个位置：

![](https://cdn.luogu.com.cn/upload/image_hosting/itgodemb.png)

如果黑棋不堵的话，白棋下在 $(3,3)$ 即一步杀。否则黑的落点必为 $(1,1),(2,2),(4,4)$ 之一。我们不用关心黑的落点，直接将局面下成这样：

![](https://cdn.luogu.com.cn/upload/image_hosting/vhtzadh0.png)

此时白棋威胁 $(0,2)$ 处的一步杀。我们分类讨论黑棋的堵法：

- 堵 $(0,1)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/c5b80tvu.png)

- 堵 $(0,2)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/1z0a6llj.png)

- 堵 $(0,4)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/3bhs3cdg.png)

分类讨论并模拟即可。
::::::

::::::info[代码]

```cpp line-numbers
int x, y;
void O(int x, int y) {cout << x << ' ' << y << endl;}
void I() {cin >> x >> y;}
void _main() {
    O(2, 2), I();
    if (x == y && (x == 1 || x == 3 || x == 4)) {
        O(3, 0), I();
        if (x == 1 && y == 0) {
            O(4, 0), I();
            if (x == 2 && y == 0) O(5, 0);
            else O(2, 0);
        } else if (x == 2 && y == 0) {
            O(2, 3), I();
            if (x == 2 && y == 1) O(2, 4);
            else O(2, 1);
        } else if (x == 4 && y == 0) {
            O(1, 3), I();
            if (x == 3 && y == 1) O(0, 4);
            else O(3, 1);
        } else {
            O(2, 0), I();
            if (x == 1 && y == 0) O(4, 0);
            else O(1, 0);
        }
    } else {
        O(3, 3), I();
        if (x == 1 && y == 1) O(4, 4);
        else O(1, 1);
    }
} 
```

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB439$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p8320--stripe-python', '『JROI-4』Sunset · stripe-python', $AKB440$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P8320](https://www.luogu.com.cn/problem/P8320)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个排列 $p_i$，长度为 $n$。你可以向交互库提出如下两种询问：
>
> 1. 给出 $k$，记 $p_i$ 的**当前**前缀 $\max$ 数组为 $m_i$，求 $m$ 前缀 $[1,k]$ 中的颜色数。
> 2. 给出 $k$，令 $p_k \gets 0$。
>
> 还原这个排列。
>
> $n \le 500$，满分询问次数 $\le 5500$，交互库非自适应。

:::::success[题解]
思考题目给出的操作，考虑到二操作不可逆，因此其意义仅仅是确定 $k$ 位置上的数字后，清除其影响。

注意到询问次数接近 $n \log n$，考虑依次用二分确定每一个数字。

接下来考虑前缀 $\max$ 颜色数的性质。我们发现：当前缀 $\max$ 越过最大值后，颜色数始终不会改变。

基于此，考虑猜数模型，二分出当前 $\max$ 的位置，然后将这个位置清零，再继续进行询问。

询问次数为 $n \log n$ 级别。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 505;
int n, a[N];
int ask(int x) {
    cout << "? 1 " << x << endl;
    int u; cin >> u;
    return u;
}
void reset(int x) {cout << "? 2 " << x << endl;}
void answer() {
    cout << "! ";
    for (int i = 1; i <= n; i++) cout << a[i] << ' ';
    cout << endl;
}

void _main() {
    cin >> n;
    for (int k = 1, v = n; k <= n; k++, v--){
        int mx = ask(n), l = 1, r = n, p = -1;
        while (l <= r) {
            int mid = (l + r) >> 1;
            if (ask(mid) == mx) r = mid - 1, p = mid;
            else l = mid + 1;
        }
        a[p] = v, reset(p);
    } answer();
} 
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB440$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p8494--stripe-python', '[IOI 2022] 最罕见的昆虫 · stripe-python', $AKB441$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P8494](https://www.luogu.com.cn/problem/P8494)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个序列 $a_i$，长度为 $n$。交互库会维护一个多重集合 $S$，你可以进行以下三种操作，每种操作至多 $T$ 次：
>
> - 给出 $i$，令 $S \gets S \cup \{a_i\}$。
> - 给出 $i$，令 $S \gets S \setminus \{a_i\}$。
> - 求 $S$ 中众数的出现次数。
>
> 要求 $S$ 中元素的下标两两不同。
>
> 求出原序列中出现最少的元素的出现次数。
>
> $n \le 2 \times 10^3$，满分要求 $T = 3n$。

:::::success[题解]

我们先扫描一遍序列求出颜色数：令 $i=1,2,\cdots,n$ 并加入 $a_i$，若众数次数 $\ge 2$ 则说明有重，将其弹出，否则新增一种颜色。设颜色数为 $c$。

特判 $c=1$ 和 $c=n$ 的平凡情形。一般情况考虑二分答案 $x$ 转判定。

受求颜色数的启发，给出如下流程：顺序扫描序列并加入 $a_i$，若众数次数 $>x$ 则将其弹出。设操作结束后集合大小为 $k$，答案不小于 $x$ 当且仅当 $k\ge cx$。注意 check 前清空集合。

直接做的操作次数为 $n \log n$，可以获得 [47.5pts](https://qoj.ac/submission/2568813)。

考察上述判定过程：

- 若 $k\ge cx$：此次 check 时加入的元素永久保留，不必清空 $S$。
- 若 $k<cx$：此次 check 时排除的元素永久放弃，不必在之后 check 时考虑。

用两个数组记录两类元素，一轮二分规模折半，询问次数 $\sum \limits_{i \ge 0} \dfrac{n}{2^i} \approx 2n$，加上初始求 $c$ 大约是 $3n$。可以获得 [99.95pts](https://qoj.ac/submission/2568915)。

需要卡常。一些常数优化：

- 当 $k \ge cx$ 时结束 check 过程；
- 二分上界设为 $\lfloor \frac{n}{c} \rfloor$；
- 初始轮剩余的元素永久保留；
- 奇数轮将 $\text{mid}$ 加 $1$。

提交后可以通过本题。

:::::

:::::info[代码]

```cpp line-numbers
int min_cardinality(int n) {
    int c = 0;
    vector<int> p, q, in(n), out(n);
    #define add move_inside
    #define del move_outside
    #define ask press_button
    for (int i = 0; i < n; i++) {
        add(i);
        if (ask() > 1) del(i);
        else c++, p.emplace_back(i);
    }
    if (c == 1) return n;

    for (int i : p) in[i] = true;
    auto check = [&](int x) -> bool {
        int cnt = 0; 
        p.clear(), q.clear();
        for (int i = 0; i < n; i++) {
            if (out[i]) continue;
            if (in[i]) {
                if (++cnt >= c * x) return true;
                continue;
            }
            add(i);
            if (ask() > x) del(i), q.emplace_back(i); 
            else cnt++, p.emplace_back(i);
            if (cnt >= c * x) return true;
        }
        return false;
    };
    int l = 1, r = n / c, res = -1;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (check(mid)) {
            res = mid, l = mid + 1;
            for (int i : p) in[i] = true;
        } else {
            r = mid - 1;
            for (int i : p) del(i);
            for (int i : q) out[i] = true;
        }
    } return res;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB441$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p9165--stripe-python', '「INOH」Round 1 - 意外 · stripe-python', $AKB442$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P9165](https://www.luogu.com.cn/problem/P9165)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一个长为 $100$ 的数组 $a_i$，需要传递一个数组 $b_i$。
> - B：已知 $b_i$，还原原本的 $a_i$。
>
> 在通信过程中，每个数字有 $50\%$ 的概率被交互库替换为为无效值。
>
> 满分要求 $b_i$ 的长度 $\le 750$。

:::::success[题解]
考虑如下加密方式：构造序列 $a_i$ 的 GF

$$
f(x)=\sum_{i=0}^{99} a_i x^i
$$

传输若干 $f(x)$。当 B 收到 $f(x)$ 后通过 Lagrange 插值即可得到 $f(x)$ 的系数表示，从而还原 $a_i$。

取 $x=0,1,\cdots,149$ 并将每个 $f(x)$ 复制 $5$ 次传输，当 B 收到后，如果某个位置出现超过两次，则认为这是正确值。并且 B 只需要 $100$ 个点值就能插值，故正确率极高。 
:::::

:::::info[代码]

```cpp line-numbers
const int N = 105;

vector<int> Encode(vector<int> vec) {
    vector<int> a(750);
    for (int x = 0; x < 150; x++) {
        mint xp = 1, y = 0;
        for (int i = 0; i < 100; i++, xp *= x) y += vec[i] * xp;
		for (int i = 0; i < 5; i++) a[x + 150 * i] = y.val;
    } 
	return a;
}

mint x[N], y[N], f[N], m[N], px[N];
vector<int> Decode(vector<int> vec) {
	memset(f, 0, sizeof(f)), memset(m, 0, sizeof(m)), memset(px, 0, sizeof(px));
    int n = 0;
    for (int i = 0; i < 150; i++) {
		map<int, int> mp;
		for (int j = 0; j < 5; j++) mp[vec[i + 150 * j]]++;
		for (auto [k, v] : mp) 
			if (v >= 2) {
				x[n] = i, y[n] = k, n++; 
				break;
			}
		if (n >= 100) break;
	}
    m[0] = 1;
    for (int i = 0; i < n; i++) {
        for (int j = i; j >= 0; j--) m[j + 1] += m[j], m[j] *= -x[i];
    }
    for (int i = 0; i < n; i++) {
		px[i] = 1;
		for (int j = 0; j < n; j++) {
			if (i != j) px[i] *= x[i] - x[j];
		}
	}
	for (int i = 0; i < n; i++) {
		mint t = y[i] / px[i], k = m[n];
		for (int j = n - 1; j >= 0; j--) f[j] += k * t, k = k * x[i] + m[j];
	}
    vector<int> res(100);
    for (int i = 0; i < 100; i++) res[i] = f[i].val;
    return res;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB442$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p9219--stripe-python', '「TAOI-1」Antipathy World · stripe-python', $AKB443$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P9219](https://www.luogu.com.cn/problem/P9219)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个序列 $a_i$，长度为 $n$。你可以给出 $i,j$，向交互库查询 $|a_i-a_j|$。
>
> 找出 $x$ 使得 $\forall i \ne x, a_x \ge 2a_i$。
>
> 多测，$T \le 25$，$n \le 5 \times 10^4$，满分询问次数 $\lfloor n/2\rfloor+2$。

:::::success[题解]
注意到询问次数与 $n/2$ 有关，考虑分组询问。对于 $i=1,3,\cdots$，我们询问 $i,i+1$，得到 $\lfloor n/2\rfloor$ 个答案。

这样一来，我们一定会得到一个最大差。设其位置为 $p$，则 $x$ 就在这一组或者没有问到的数里面。分类讨论一下：

- 若 $n$ 为偶数：则 $x \in \{p,p+1\}$，再任找一个 $y$，比较 $|a_p-a_y|$ 和 $|a_{p+1}-a_y|$ 即可。
- 若 $n$ 为奇数：则 $x \in \{p,p+1,n\}$，我们询问 $|a_p-a_n|$ 和 $|a_{p+1}-a_n|$，然后根据三个数的大小关系容易得到 $x$。

容易发现操作次数恰好为 $\lfloor n/2\rfloor+2$。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 5e4 + 5;
int n, k, a[N];
int ask(int x, int y) {
    cout << "? " << x << ' ' << y << endl;
    int u; cin >> u;
    return u;
}

void _main() {
    cin >> n >> k;
    fill(a + 1, a + n + 1, 0);
    for (int i = 1; i < n; i += 2) a[i] = ask(i, i + 1);
    int p = max_element(a + 1, a + n + 1) - a;
    if (n & 1) {
        int x = ask(p, n), y = ask(p + 1, n);
        if (x > a[p] && y > a[p]) cout << "! " << n << endl;
        else if (x > y) cout << "! " << p << endl;
        else cout << "! " << p + 1 << endl;
    } else {
        int x = 1;
        if (p == 1) x = 3;
        if (ask(p, x) > ask(p + 1, x)) cout << "! " << p << endl;
        else cout << "! " << p + 1 << endl;
    }
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB443$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p9599--stripe-python', '[JOI Open 2018] 木琴 / Xylophone · stripe-python', $AKB444$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P9599](https://www.luogu.com.cn/problem/P9599)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个 $1\sim n$ 的排列 $a_i$。保证 $1$ 所在位置小于 $n$ 所在位置。你可以向交互库询问区间极差。
>
> 还原这个排列。
>
> $n \le 5 \times 10^3$，满分询问次数 $10^4$。

:::::success[题解]

询问 $(i,i+1)$ 可以得到差分数组 $|d_i|=|a_i-a_{i-1}|$。

询问 $(i-1,i,i+1)$ 得到 $k$ 分讨：

- 若 $a_{i-1} <a_i<a_{i+1}$，则 $k=a_{i+1}-a_{i-1}$。    
  注意到 $d_{i+1}+d_i=k$ 且 $d_{i+1} >0 \land d_i >0$。
- 若 $a_{i-1}>a_i>a_{i+1}$，则 $k=a_{i-1}-a_{i+1}$。    
  注意到 $-d_{i+1}-d_i=k$ 且 $d_{i+1} < 0 \land d_i < 0$。
- 若 $a_{i-1}<a_i>a_{i+1}$，则 $d_i > 0 \land d_{i+1}<0$。
  - 若 $a_{i-1}<a_{i+1}$，则 $k=a_i-a_{i-1}=d_i$。
  - 若 $a_{i+1}<a_{i-1}$，则 $k=a_i-a_{i+1}=-d_{i+1}$。
- 若 $a_{i-1}>a_i<a_{i+1}$，则 $d_i< 0 \land d_{i+1}>0$。
  - 若 $a_{i-1}>a_{i+1}$，则 $k=a_{i-1}-a_i=-d_i$。
  - 若 $a_{i+1}>a_{i-1}$，则 $k=a_{i+1}-a_i=d_{i+1}$。

综上所述，当且仅当 $k=|d_i|+|d_{i+1}|$ 时 $d_id_{i+1}>0$。

钦定 $a_1=C \land d_2=\pm |d_2|$ 递推出 $a_1 \sim a_n$，则最小值对应 $1$，进而排列得以还原。在两种情况中取 $\text{pos}(1)<\text{pos}(n)$ 的那种即可。

询问次数 $2n-3$。

:::::

:::::info[代码]
```cpp line-numbers
#define ask query
int d[N], f[N], a[N];
void solve(int N) {
    for (int i = 2; i <= N; i++) d[i] = ask(i-1, i);
    for (int i = 2; i < N; i++) 
        f[i] = (ask(i-1, i+1) == d[i] + d[i+1]);
    for (int i = 2; i < N; i++) {
        if (f[i]) d[i+1] = d[i] > 0 ? d[i+1] : -d[i+1];
        else d[i+1] = d[i] > 0 ? -d[i+1] : d[i+1];
    }
    for (int i = 2; i <= N; i++) a[i] = a[i-1] + d[i];
    int p = min_element(a + 1, a + N + 1) - a;
    for (int i = 1; i <= p; i++) a[i] += 1 - a[p];
    for (int i = p+1; i <= N; i++) a[i] = a[i-1] + d[i];
    int x1 = find(a + 1, a + N + 1, 1) - a;
    int xn = find(a + 1, a + N + 1, N) - a;
    if (x1 > xn)  
        for (int i = 1; i <= N; i++) a[i] = N - a[i] + 1;
    for (int i = 1; i <= N; i++) answer(i, a[i]);
}
```
:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB444$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('Xesir', 'col-prob-qbxt-pea--xesir', '植物很爽 · Xesir', $AKB445$## 题目描述

你在玩植物大战僵尸。

你的草坪有 $n$ 行，每行有 $a_i$ 个格子。

你想要给每个格子种植双发射手和三线射手其中的一种。

- 如果某个格子种植了双发射手，则它会为本行提供 $2$ 的火力。
- 如果某个格子种植了三线射手，则它会为本行和相邻的两行（如果有的话）各提供 $1$ 的火力。

一行的总火力是所有植物为该行提供火力的总和。你想要最大化总火力最小的行的总火力。你需要给出这个值。

### 输入格式

第一行一个正整数 $n$。

接下来一行 $n$ 个正整数，第 $i$ 个表示 $a_i$。

### 输出格式

输出一行一个整数，表示总火力最小的行的总火力最大值。

### 数据范围

测试数据满足 $1\le n\le 10^6$，$0\le a_i\le 10^9$。

请使用快速的读写方式。子任务 $4$ 内有 $5$ 组数据。

| 子任务编号 | 特殊性质 | 分值 |
| :---: | :--- | :---: |
| $1$ | $n\le 5$，$a_i\le 10$ | $15$ |
| $2$ | $n\le 100$，$a_i\le 100$ | $20$ |
| $3$ | $n\le 1000$，$a_i\le 4000$ | $15$ |
| $4$ | $n=10^6$，$a_i$ 在范围内独立均匀随机 | $10$ |
| $5$ | $n\le 100$ | $10$ |
| $6$ | 无特殊性质 | $30$ |

## 样例

### 样例 1

**输入：**

```
5
2 3 4 5 6
```

**输出：**

```
7
```

### 样例 2

**输入：**

```
7
11 45 14 19 19 8 10
```

**输出：**

```
27
```

## 解题思路

### 先写出每行火力的表达式

设第 $i$ 行放了 $x_i$ 株三线射手，那么双发射手就是 $a_i-x_i$ 株。

第 $i$ 行的火力来自三部分：

- 本行的双发射手：$2(a_i-x_i)$；
- 本行的三线射手（照顾自己这一行）：$x_i$；
- 上、下两行的三线射手：$x_{i-1}+x_{i+1}$。

合起来

$$f_i=2(a_i-x_i)+x_i+x_{i-1}+x_{i+1}=2a_i-x_i+x_{i-1}+x_{i+1}$$

### 全放三线时每行火力最大

把 $x_i=a_i$ 全部代入，得到

$$c_i=a_{i-1}+a_i+a_{i+1}$$

（边界按不存在的行取 $0$）。代码里就是在读入时顺手做 `c[i-1]+=a[i]; c[i]+=a[i]; c[i+1]+=a[i]`，等价于对每个 $a_i$ 向它自己和左右各投一份。

这个 $c_i$ 是「理想上界」：只要把某个三线改成双发，本行 $+1$、上下两行各 $-1$，总和不变，但分布变了。所以**全三线是最均匀地互相「借」火力的状态**。

### 二分答案

「最大化最小值」是二分的经典信号。二分一个 $k$，判断能否让每行火力都 $\ge k$。

判断时从全三线出发（此时每行是 $c_i$），从左往右扫：

- 若 $b_i\ge k$，本行已达标，不动它；
- 若 $b_i<k$，只能把本行的一些三线改成双发（这是唯一能给本行加火力的手段，因为别处的三线已经全放了）。每改一株，本行 $+1$，上下两行各 $-1$。

需要补的缺口是 $\Delta=k-b_i$，于是要求上下两行都有 $\Delta$ 的余量：

$$b_{i-1}-\Delta\ge k,\qquad b_{i+1}-\Delta\ge k$$

满足就执行 $b_{i-1}\mathrel{-}=\Delta,\;b_{i+1}\mathrel{-}=\Delta,\;b_i\mathrel{+}=\Delta$；不满足说明这个 $k$ 做不到。

### 为什么扫完还要再检查一遍

因为修改 $b_i$ 时会扣掉 $b_{i+1}$，而 $i+1$ 在**后面**才会被处理，它的缺口会在那里补；但 $b_{i-1}$ 已经被处理过了，扣掉之后就没人再管它。

所以最后统一再扫一遍，确认没有哪一行被扣到 $k$ 以下。

### 复杂度

单次 check 是 $O(n)$，二分区间上界取 $3\sum a_i$，共 $O(\log(3\sum a))$ 轮，总复杂度 $O(n\log(3\sum a))$。$n=10^6$ 时需要配合快速读写。

## 逐行代码解析

### 全局数组与快读快写

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e6+10;
int a[N],c[N],b[N];int ans=-1,n,jsq=0;
```

- `#define int long long`：$a_i$ 到 $10^9$、$n$ 到 $10^6$，$\sum a_i$ 可达 $10^{15}$，火力必然超 `int`。
- `a` 存每行格子数，`c` 存全三线时的火力，`b` 是 check 里的工作数组。
- `ans=-1` 是哨兵：如果连 $k=0$ 都不行（本题不会发生），输出 $-1$。
- `jsq` 是调试用的计数器，实际没用上。

```cpp
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

- 手写快读用 `getchar` 逐字符转数字，$10^6$ 级别的输入下比 `cin` 快很多。
- `(x<<1)+(x<<3)` 就是 `x*10`，`ch^48` 就是 `ch-'0'`。
- `write` 递归输出十进制位，`x` 为 `long long` 时同样可用。

### check 函数

```cpp
bool check(int k){
	for(int i=1;i<=n;i++) b[i]=c[i];
	for(int i=1;i<=n;i++){
		if(b[i]+a[i]<k) return false;
		if(b[i]<k){
		//	if(b[i+1]-k+b[i]>=k&&b[]) 
			if((i==1||b[i-1]-k+b[i]>=k)&&(i==n||b[i+1]-k+b[i]>=k)){
				b[i+1]-=k-b[i];b[i-1]-=k-b[i];b[i]+=k-b[i];
			}
			else return false;
		}
	}
	for(int i=1;i<=n;i++) if(b[i]<k) return false;
	return true;
}
```

- `b[i]=c[i]`：每组 check 都从「全三线」这个最均匀的状态重新开始。
- `if(b[i]+a[i]<k) return false`：本行最多还能把 $a_i$ 株三线改成双发，每改一株给本行 $+1$，所以 $b_i+a_i$ 是本行能达到的上限，达不到就直接判死。
- `i==1` / `i==n` 的短路是为了避开越界的 $b_0$ 和 $b_{n+1}$。
- `b[i-1]-k+b[i]>=k` 等价于 $b_{i-1}\ge k+(k-b_i)$，即「扣掉缺口后仍然不低于 $k$」。
- 三个赋值合起来：上下各行扣 $\Delta$、本行补 $\Delta$，总量守恒。
- 最后的重扫就是前面说的「回头检查」。

### 主函数：建 `c` 数组 + 二分

```cpp
signed main(){
	freopen("pea.in","r",stdin);
	freopen("pea.out","w",stdout);
	n=read();
	int l=0,r=0;
	for(int i=1;i<=n;i++){
		a[i]=read();
		r+=a[i]*3;
		c[i-1]+=a[i];c[i]+=a[i];c[i+1]+=a[i];
	}
```

- `signed main` 配合 `#define int long long`。
- `r` 取 $3\sum a_i$：任何一行最多拿到「自己行全三线 $a_i$ + 上下各 $a_{i\pm1}$」，总量不超过 $3\sum a_i$，是个安全的上界。
- `c[i-1] += a[i]` 这类写法一次性把 $a_i$ 摊到 $i-1,i,i+1$ 三格，等价于 $c_j=\sum_{|i-j|\le1}a_i$。注意 $c_0$ 和 $c_{n+1}$ 也会被写，但后面不会用到（数组开够就行）。

```cpp
	while(l<=r){
		int mid=(l+r)/2;
		if(check(mid)) ans=mid,l=mid+1;
		else r=mid-1;
		//jsq++;
		//if(jsq>N){
		//	cout<<"kkkk"<<l<<" "<<r<<" "<<ans;
		//}
		//cout<<l<<" "<<r<<"\n";
	}
	write(ans);
	return 0;
}
```

- 标准二分：可行就记录并把左端点右移，不可行就把右端点左移。
- `ans` 保存最后一次可行的 $k$，循环结束后直接输出。
- 注释掉的几行是调试残留，删掉不影响。

## 复杂度分析

每组数据 check 是两次 $O(n)$ 扫描，二分约 $\log_2(3\times10^{15})\approx52$ 轮，总 $O(n\log(3\sum a))$。$n=10^6$ 时约 $10^8$ 次简单运算，卡常后可过。空间是三个长度 $10^6$ 的数组，$O(n)$。

## 常见陷阱与注意事项

- **不开 `long long` 会溢出**：$\sum a_i$ 能到 $10^{15}$，$c_i$ 也是这个量级。
- **check 里忘了重置 `b`**：每轮必须 `b[i]=c[i]`，否则上一轮的结果会污染下一轮。
- **边界短路不能省**：$i=1$ 时访问 $b_0$、$i=n$ 时访问 $b_{n+1}$，虽然数组开得下，但语义上是错的。
- **少了最后的重扫**：只扫一遍会漏掉「被后面扣到 $k$ 以下」的行。
- **二分上界**：取 $3\sum a_i$ 是保守但安全的选择，取小了会漏掉最优解。
- **`freopen` 的文件名**：按题目要求修改，交题前务必检查。

## 对比与扩展

- 与「P1450 硬币购物」的关系：那道题用容斥消约束，本题用二分把「最大化最小值」转成「判定可行性」，都是把优化问题变成判定问题。
- 「局部调整 + 邻居买单」这种贪心，和「区间加 / 差分」是同一类思想：每次只改一个位置，把代价摊给相邻位置。
- 若题目改成「最大化总火力最小值的行数」，就不能简单二分了，需要额外记录方案。$AKB445$, '基础算法', array['二分答案', '贪心', '构造', '前缀和思想'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-11116--stripe-python', 'Yearning for Yonder · stripe-python', $AKB446$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ11116](https://qoj.ac/problem/11116)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一棵大小为 $n$ 的带权树，树的形态从 Prufer 序列随机，边权从 $[1,k]$ 随机，$k$ 隐藏且保证 $k \le 10^4$。可以向交互库询问树上两点距离。
>
> 还原这棵树。
>
> $n \le 10^5$，满分询问次数 $7n$，交互库非自适应。

:::::success[题解]
首先我们可以用 $2n$ 次询问找到原树的直径，并且根据距离判断出每个点是在直径上，还是在子树中。

可以将这些点划分到直径下挂的子树中，分治求解。

由于树从 Prufer 序列随机，直径上点数的期望为 $O(\sqrt{n})$，由递归式 $T(n)=\sqrt{n} \times T(\sqrt{n})+O(n)$ 得 $T(n)=O(n \log \log n)$。

由于我们知道了直径端点到子树中每个点的距离，询问次数可以变成 $n$ 次，可以通过本题。

这里有一点细节，我们详细说明一下怎么算出距离。设分治的根节点为 $r$，当前子树中距 $r$ 最远的点为 $u$，$v$ 是我们枚举到的节点。

此时，路径 $r \to u$ 是一条主链。对于点 $v$，它到主链上会有一个投影点，记为 $w$，那么我们需要求 $d(r,w)$。列出方程：

- $d(r,w)+d(v,w)=d(r,v)$；
- $d(r,w)+d(u,w)=d(u,v)$；
- $d(r,w)+d(u,w)=d(r,u)$。

解得 $d(r,w)=\frac{d(r,v)+d(r,u)-d(u,v)}{2}$。根据这个值可以就判断 $v$ 点所属的子树了。
::::: 

:::::info[代码]

```cpp line-numbers
const int N = 1e5 + 5;
int ask(int u, int v) {
    if (u == v) return 0;
    cout << "? " << u << ' ' << v << endl;
    int x; cin >> x;
    return x;
}
int n;
vector<tuple<int, int, int>> e;

using node = pair<int, int>;
void solve(int rt, vector<node>& s) {
    if (s.empty()) return;
    sort(s.begin(), s.end());
    auto [d, u] = s.back();
    vector<int> t(s.size());
    for (int i = 0; i < (int)s.size(); i++) t[i] = ask(u, s[i].second);
    map<int, int> path;
    map<int, vector<node>> sub;
    path[0] = rt;
    for (int i = 0; i < (int)s.size(); i++) {
        auto [d1, v] = s[i];
        int x = (d1 + d - t[i]) / 2;
        if (x == d1) path[d1] = v;
        else sub[x].emplace_back(d1 - x, v);
    }
    int cur = rt, pre = 0;
    for (auto& [d1, v] : path) {
        if (d1 == 0) continue;
        e.emplace_back(cur, v, d1 - pre);
        cur = v, pre = d1;
    }
    for (auto& [x, vec] : sub) solve(path[x], vec);
}

void _main() {
    cin >> n, e.clear();
    vector<node> s0;
    for (int i = 2; i <= n; i++) s0.emplace_back(ask(1, i), i);
    solve(1, s0);
    cout << "! ";
    for (auto& [u, v, w] : e) cout << u << ' ' << v << ' ' << w << ' ';
    cout << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB446$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-141--stripe-python', '8 染色 · stripe-python', $AKB447$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ141](http://qoj.ac/problem/141/statement/default)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一个 $n$ 个点 $m$ 条边的无向图 $G$，并且得知 $G$ 的一个 $8$ 染色方案。可以传输一个 01 串 $S$。
> - B：已知 $n$ 个点 $m$ 条边的无向图 $G$，并且收到 $S$。要求构造一个 $8$ 染色方案。
>
> $n \le 2 \times 10^5$，$m \le 5 \times 10^5$，满分要求 $|S| \le 2.5 \times 10^5$，时限 0.45s，空限 20MB。

:::::success[题解]

A 和 B 先不断删去度数 $<8$ 的点，得到新图 $G'$。只要 A 给 B 提示了 $G'$ 的 $8$ 染色，B 是容易按逆拓扑序贪心构造的。

记 $G'$ 的点数为 $n'$，根据握手定理 $2m=\sum d_u \ge 8n'$，得 $n' \le \frac{m}{4}$。

如果每个颜色占 3bit，总的 bit 数就是 $\frac{3}{4} m =3.75 \times 10^5$，只能获得 41.3pts。

我们注意到 $2$ 染色是容易的。考虑将 $8$ 种颜色两两分组，然后传递 $4$ 个组的标号。bit 数为 $\frac{1}{2}m$ 符合要求。

可以证明，每一组在 $G'$ 中的导出子图都是二分图，因此可以黑白染色，于是 B 就得到了 $G'$ 的 $8$ 染色。

注意精细实现，否则会被卡常卡空间。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 2e5 + 5;
static int n, m, deg[N];
static bitset<N> del;
static vector<int> e[N];

vector<int> Alice(int N, int M, vector<int> U, vector<int> V, vector<int> C) {
	n = N, m = M;
    for (int i = 0; i < m; i++) {
        int u = U[i] + 1, v = V[i] + 1;
        e[u].emplace_back(v), e[v].emplace_back(u);
        deg[u]++, deg[v]++;
    }
    queue<int> q;
    for (int i = 1; i <= n; i++) if (deg[i] < 8) q.emplace(i), del[i] = true;
	while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) 
            if (--deg[v] < 8 && !del[v]) q.emplace(v), del[v] = true;
    }
    vector<int> vec;
    for (int i = 1; i <= n; i++) if (!del[i]) 
		vec.emplace_back(C[i - 1] >> 2 & 1), vec.emplace_back(C[i - 1] >> 1 & 1);
    return vec;
}
```

B：

```cpp line-numbers
const int N = 2e5 + 5;
static int n, m, deg[N];
static bitset<N> del;
static i16 typ[N], col[N];
static vector<int> e[N];

void dfs(int u, int t) {
    for (int v : e[u]) {
        if (col[v] != -1 || typ[v] != t) continue;
        col[v] = col[u] ^ 1, dfs(v, t);
    }
}

vector<int> Bob(int N, int M, vector<int> U, vector<int> V, vector<int> X) {
    n = N, m = M;
    for (int i = 0; i < m; i++) {
        int u = U[i] + 1, v = V[i] + 1;
        e[u].emplace_back(v), e[v].emplace_back(u);
        deg[u]++, deg[v]++;
    }
	stack<int> st; queue<int> q;
    for (int i = 1; i <= n; i++) if (deg[i] < 8) 
		q.emplace(i), del[i] = true, st.emplace(i);
	while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : e[u]) 
            if (--deg[v] < 8 && !del[v]) 
				q.emplace(v), del[v] = true, st.emplace(v);
    }
	fill(col + 1, col + n + 1, -1), fill(typ + 1, typ + n + 1, -1);
    for (int i = 1, p = 0; i <= n; i++) {
        if (del[i]) continue;
		typ[i] = X[p] * 4 + X[p + 1] * 2, p += 2;
    }
    for (int c : {0, 2, 4, 6}) {
        for (int i = 1; i <= n; i++) 
			if (col[i] == -1 && typ[i] == c) col[i] = 0, dfs(i, c);
        for (int i = 1; i <= n; i++) 
			if (typ[i] == c) col[i] += c;
    }
	while (!st.empty()) {
		int u = st.top(); st.pop();
		int mask = (1 << 8) - 1;
		for (int v : e[u]) 
			if (col[v] != -1) mask &= ~(1 << col[v]);
		col[u] = ctz(mask);
	}
    return vector<int>(col + 1, col + n + 1);
}
```

:::::

### 【未完成】[CF1442F Differentiating Games](https://www.luogu.com.cn/problem/CF1442F)

## 博弈型

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB447$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-15314--stripe-python', 'Menji, we miss you! · stripe-python', $AKB448$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ15314](https://qoj.ac/problem/15314/)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 给出一棵节点数为 $n$ 的有根树，根节点为 $1$，保证节点儿子数目 $\le 2$。交互库有一个隐藏的点 $x$。你可以给出 $u,k$，向交互库查询 $\text{dis}(u,x) \le k$ 是否成立。
>
> 找出点 $x$。
>
> 多测，$T \le 100$，$n \le 3 \times 10^4$，满分询问次数 $40$，交互库自适应。

:::::success[题解]
考虑猜数模型，通过询问 $\text{dis}(1,x)$ 可以在 $\log n$ 次询问内得到节点 $x$ 的深度。

得到深度 $d$ 以后，可以询问 $(u,d-d_u)$ 来确定 $x \in \text{subtree}(u)$ 是否成立。考虑通过搜子树的方法找到 $x$。

可以得到一个候选集合 $S$。记 $f_u=\sum \limits_{v \in \text{subtree}(u)} [v \in S]$。有结论：必然存在子树 $u$ 使得 $f_u \ge \frac{2}{3} |S|$。由二叉树的结构易证。

考虑维护集合 $S$，每次取一个 $f_u$ 最接近 $\frac{1}{2} |S|$ 的子树继续递归，那么询问次数为 $\log_{1.5} n \approx 1.7 \log n$。总询问次数约 $2.7 \log n$ 且完全跑不满，可以通过。
:::::

:::::info[代码]

```cpp line-numbers
const int N = 3e4 + 5;
bool ask(int u, int k) {
    cout << "? " << u << ' ' << k << endl;
    int x; cin >> x;
    return x;
}
int n, dn, f[N], sz[N], dfn[N], dep[N];
vector<int> e[N];

void dfs1(int u) {
    sz[u] = 1, dfn[u] = ++dn;
    for (int v : e[u]) dep[v] = dep[u] + 1, dfs1(v), sz[u] += sz[v]; 
}
void dfs2(int u) {
    for (int v : e[u]) dfs2(v), f[u] += f[v];
}

void _main() {
    cin >> n;
    for (int i = 1; i <= n; i++) e[i].clear();
    for (int v = 2, u; v <= n; v++) cin >> u, e[u].emplace_back(v);
    dn = 0, dfs1(1);
    int l = 0, r = n, d = -1;
    while (l <= r) {
        int mid = (l + r) >> 1;
        if (ask(1, mid)) d = mid, r = mid - 1;
        else l = mid + 1;
    }
    vector<int> vec;
    for (int i = 1; i <= n; i++) 
        if (dep[i] == d) vec.emplace_back(i);
    while (vec.size() > 1) {
        fill(f, f + n + 1, 0);
        for (int u : vec) f[u] = 1;
        dfs2(1);
        int u = 1, v = -1, t = vec.size() / 2;
        while (true) {
            int h = 0;
            for (int v : e[u]) if (f[v] > f[h]) h = v;
            if (f[h] <= t) {
                v = h; break;
            } u = h;
        }
        if (abs(f[u] - t) > abs(f[v] - t)) swap(u, v);
        vector<int> nxt;
        if (ask(u, d - dep[u])) {
            for (int x : vec) if (dfn[u] <= dfn[x] && dfn[x] <= dfn[u] + sz[u] - 1) 
                nxt.emplace_back(x);
        } else {
            for (int x : vec) if (!(dfn[u] <= dfn[x] && dfn[x] <= dfn[u] + sz[u] - 1)) 
                nxt.emplace_back(x);
        }
        vec.swap(nxt);
    }
    cout << "! " << vec[0] << endl;
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB448$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-17760--stripe-python', 'Telepathy · stripe-python', $AKB449$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ17760](http://qoj.ac/problem/17760)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和一个大小为 $k$ 的集合 $S$。保证 $S \subseteq \{1,2,\cdots,n\}$ 且 $k < \frac{n}{2}$。
>
>   必须选择一个正整数 $x$ 使得 $x \in [1,n] \land x \notin S$，令 $T = S \cap \{x\}$。
>
> - B：已知 $n,k$ 和大小为 $k+1$ 的集合 $T$。找出 $T \setminus S$，即 A 加的数字。
>
> 多测，$n \le 10^6$，$\sum n \le 3 \times 10^6$。

:::::success[题解]

在最坏情况下，有 $2 \nmid n$ 且 $2k+1=n$，故只需解决这一情况，其余情形可以通过加元素转化到这种情况。

考虑如下转化：对于 $[1,n]$ 中的每个数 $x$，若 $x \in S$ 则令 $a_x=1$，否则令 $a_x=-1$。记 $f(x)=\sum \limits_{i=1}^n a_i$，画出 $x - f(x)$ 的图像：

![](https://cdn.luogu.com.cn/upload/image_hosting/f24zqf6b.png)

容易发现如下性质：

- $f(n)=-1$。
- $f$ 存在唯一的循环位移，使得 $\forall i \in [1,n), f(i) \ge 0$。也即图中将坐标系移动到最低谷点的操作。

这个实际上是 Raney 引理的构造。

忽略 $f(n)$，则 $f(1) \sim f(n-1)$ 相当于一个合法括号序列。考虑用括号序列的结构给 $S$ 构造双射。

考虑 A 的策略。我们可以找到那个多出来的右括号 $-1$，也即寻找 $f(x)$ 在 $[1,n]$ 上第一个达到最小值的位置 $x$，并且将 $x$ 加入 $S$。

考虑 B 的策略。我们去找循环位移的起点，即寻找 $f(x)$ 在 $[1,n]$ 上最后一个达到最小值的位置 $x$。根据唯一性，A 添加的数字就是 $x+1$。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 2e6 + 5;
int n, k, a[N], s[N];

void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k; i++) cin >> s[i];
    int m = 2 * n - 2 * k - 1;
    fill(a + 1, a + m + 1, -1);
    for (int i = 1; i <= k; i++) a[s[i]] = 1;
    for (int i = n + 1; i <= m; i++) a[i] = 1;
    int f = 0, mf = 0, x = 0;
    for (int i = 1; i <= m; i++) {
        f += a[i];
        if (f < mf) mf = f, x = i;
    }
    for (int i = 1; i <= k; i++) cout << s[i] << ' ';
    cout << x << '\n';
}
```

B：

```cpp line-numbers
const int N = 2e6 + 5;
int n, k, a[N], t[N];

void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k + 1; i++) cin >> t[i];
    int m = 2 * n - 2 * k - 1;
    fill(a + 1, a + m + 1, -1);
    for (int i = 1; i <= k + 1; i++) a[t[i]] = 1;
    for (int i = n + 1; i <= m; i++) a[i] = 1;
    int f = 0, mf = 0, x = 0;
    for (int i = 1; i <= m; i++) {
        f += a[i];
        if (f <= mf) mf = f, x = i;
    } cout << x + 1 << '\n';
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB449$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-18404--stripe-python', 'Dangerous Data · stripe-python', $AKB450$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ18404](http://qoj.ac/problem/18404)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知 $n,k$ 和大小为 $n+k$ 的集合 $S$，保证 $S \subseteq [1,10^6]$。可以传递一个长为 $k$ 的序列 $a_i$，要求 $a_i \in [0,2^{20})$。
> - B：已知 $n,k$ 和长为 $k$ 的序列 $a_1 \sim a_k$，以及大小为 $n$ 的集合 $T$。保证 $T \subseteq S$，你需要找出 $S \setminus T$，即缺失的 $k$ 个数字。
>
> $n \le 10^5$，$k \le 10$。

:::::success[题解]

取质数 $p \in (10^6,2^{20})$，将所有数在 $\mathbb{Z}_p$ 下运算。代码取 $p=10^6+3$。

考虑构造多项式 $F(x)=\prod\limits_{v \in S} (vx+1)$，并将 $F \bmod x^{k+1}$ 的系数传递给 B。

$F$ 的组合意义是：在 $S$ 中取出所有大小为 $k$ 的子集，统计子集元素之积的总和作为 $f_k$。可以说明 $f_0 \sim f_{n+k}$ 与 $S$ 构成双射。

B 收到 $F \bmod x^{k+1}$ 后，构造 $T$ 的对应多项式 $G(x)=\prod\limits_{v \in T} (vx+1)$，将 $G$ 除掉就得到
$$
\begin{aligned}
H(x)&=\prod_{v \in (S \setminus T)} (vx+1)\\
H&\equiv \dfrac{F}{G} \pmod {x^{k+1}}
\end{aligned}
$$
又因为 $H$ 的次数不会超过 $k$，故直接有 $H=F \times G^{-1}$ 成立。

得到 $H$ 以后，令 $H(x)=0$ 求根即为 $S \setminus T$。

多项式运算使用暴力即可，复杂度 $O(nk)$。

:::::

:::::info[代码]

A：

```cpp line-numbers
const int N = 1.1e5;
int n, k, a[N];
mint f[20];

void _main() {
    cin >> n >> k;
    f[0] = 1;
    for (int p = 1, x; p <= n + k; p++) {
        cin >> x;
        for (int i = k; i >= 1; i--) f[i] += f[i - 1] * x;
    } 
    for (int i = 1; i <= k; i++) cout << f[i] << ' ';
}
```

B：

```cpp line-numbers
const int N = 1.1e5;
int n, k;
mint f[20], g[20], gi[20], h[20];

mint H(mint x) {
    mint res = 0;
    for (int i = k; i >= 0; i--) res = res * x + h[i];
    return res;
}
void _main() {
    cin >> n >> k;
    for (int i = 1; i <= k; i++) cin >> f[i];
    f[0] = g[0] = gi[0] = 1;
    for (int p = 1, x; p <= n; p++) {
        cin >> x;
        for (int i = k; i >= 1; i--) g[i] += g[i - 1] * x;
    } 
    for (int i = 1; i <= k; i++) 
        for (int j = 1; j <= i; j++) gi[i] -= g[j] * gi[i - j]; 
    for (int i = 0; i <= k; i++)
        for (int j = 0; i + j <= k; j++) h[i + j] += f[i] * gi[j];
    for (int i = 1; i <= 1e6; i++)
        if (H(mint(-1) / i) == 0) cout << i << ' ';
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB450$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-5309--stripe-python', 'Guess Cycle Length · stripe-python', $AKB451$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ5309](https://qoj.ac/problem/5309)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 交互库隐藏了一个大小为 $n$ 的环，环上节点的编号是一个 $1 \sim n$ 的排列。你初始位于某个点，每次询问给出一个非负整数 $x$，向后走 $x$ 步并从交互库得知当前节点编号。
>
> 还原环的大小，即找出 $n$。
>
> $n \le 10^9$，满分询问次数 $\le 10^4$，交互库非自适应。

:::::success[题解]
注意到如果从起点走 $x,y$ 步后节点编号相同，则 $n \mid (x-y)$。

考虑 BSGS。设置一个阈值 $B$，先向后跳 $1,2,\cdots,B$ 步，并将步数和节点编号对应插入一个哈希表。再跳 $B,2B,\cdots,B^2$ 步。若 $n \le B$ 则可以直接在第一轮得到答案，否则找到哈希表中第一个出现的数可以计算出答案。

上述做法是确定性的，$B=\sqrt{n}$ 最优，此时询问次数约 $2 \times \sqrt{10^9} \approx 6 \times 10^4$，无法通过。

结论：$k$ 个 $[1,n]$ 内的随机变量，最大值的期望为 $\frac{k}{k+1}n$。

我们随机进行以下流程若干轮：从 $[1,10^9]$ 中随机一个正整数 $x$，并记录走 $x$ 步后的节点标号。由于交互库非自适应，我们找出编号的 $\max$ 记为 $m$，则用 $m$ 来估计 $n$ 的数量级。

这样 $m \to n$ 的距离大大缩小了，考虑在这段距离上 BSGS。跑完 Baby Step 后，可以从起点开始，找到最接近 $m$ 的 $B$ 的倍数 $kB$，然后从 $kB$ 开始重复 Giant Step。

经过简单调参即可通过，注意一些细节。
:::::

:::::info[代码]

```cpp line-numbers
#define int long long
const int N = 1e9, B = 2000;
int walk(int x) {
    cout << "walk " << x << endl;
    int a; cin >> a;
    return a;
}
void guess(int x) {
    cout << "guess " << x << endl;
    exit(0);
}

void _main() {
    int m = 0;
    for (int i = 1; i <= 3000; i++) chkmax(m, walk(rand32() % N + 1));
    umap<int, int> mp;
    int x = -1;
    for (int i = 1; i <= B; i++) {
        x = walk(1), chkmax(m, x);
        if (mp.find(x) != mp.end()) guess(i - mp[x]);
        mp[x] = i;
    }
    int d = max(B, m / B * B);
    if (d > B) x = walk(d - B);
    while (true) {
        if (mp.find(x) != mp.end() && d > mp[x]) guess(d - mp[x]);
        x = walk(B), d += B;
    }
}
```

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB451$, '基础算法', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-uoj-454--stripe-python', '【UER #8】打雪仗 · stripe-python', $AKB452$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[UOJ454](https://uoj.ac/problem/454)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道通信题。
>
> - A：已知一个长为 $2n$ 的 01 串 $S$。
> - B：有 $n$ 个下标 $p_1,p_2,\cdots,p_n$。输出这 $n$ 个下标上的字符。
>
> 两个程序之间可以通信，每轮通信只能传输一个 bit。
>
> $n \le 1000$，满分通信次数 $\le 1335$。

:::::success[题解]
核心是平衡规划思想。

注意到 $m \approx \frac{4}{3}{n}$，这启示我们考虑三等分。将字符串切成三段以后，B 可以知道哪一段包含的 $p_i$ 最多，然后将这个信息传输给 A。A 直接将整段传输过去，次数为 $\frac{2n}{3}$。

剩下 $\frac{4n}{3}$ 个位置中，我们注意到 A 发送的字符数上界为 $n-\frac{n}{3}=\frac{2n}{3}$，于是直接让 B 将位置信息压成一个 01 串传给 A，A 再把信息传送回去即可。

A 的通信次数为 $\frac{4n}{3}$，B 的通信次数为 $\frac{4n}{3}+2$，均可通过。
:::::

:::::info[代码]
A：

```cpp line-numbers
const int N = 2005;
int n, m, k, L[4], R[4];
char s[N];
ifstream fin;

void _main() {
    fin.open("alice.in"), fin >> n >> m >> (s + 1), fin.close();
	L[1] = 1, R[1] = 2 * n / 3, L[2] = R[1] + 1, R[2] = 4 * n / 3, L[3] = R[2] + 1, R[3] = 2 * n;
	char c1, c2; cin >> c1 >> c2;
	if (c1 == '0' && c2 == '1') k = 1;
	else if (c1 == '1' && c2 == '0') k = 2;
	else k = 3;
	for (int i = L[k]; i <= R[k]; i++) cout << s[i];
	cout << flush;
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		char c; cin >> c;
		if (c == '1') cout << s[i];
	}
	cout << flush;
}
```

B：

```cpp line-numbers
const int N = 2005;
int n, m, p[N], L[4], R[4], cnt[4];
bool need[N];
char s[N];
ifstream fin;
ofstream fout;

void _main() {
    fin.open("bob.in"), fout.open("bob.out");
	fin >> n >> m;
	for (int i = 1; i <= n; i++) fin >> p[i], need[p[i]] = 1;
	fin.close();
	L[1] = 1, R[1] = 2 * n / 3, L[2] = R[1] + 1, R[2] = 4 * n / 3, L[3] = R[2] + 1, R[3] = 2 * n;
	for (int k = 1; k <= 3; k++) {
		for (int i = L[k]; i <= R[k]; i++) cnt[k] += need[i];
	}
	int k = max_element(cnt + 1, cnt + 4) - cnt;
	if (k == 1) cout << "01" << flush;
	else if (k == 2) cout << "10" << flush;
	else cout << "11" << flush;
	for (int i = L[k]; i <= R[k]; i++) {
		char c; cin >> c;
		if (need[i]) s[i] = c;
	}
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		cout << need[i];
	} cout << flush;
	for (int i = 1; i <= 2 * n; i++) {
		if (L[k] <= i && i <= R[k]) continue;
		if (need[i]) {
			char c; cin >> c;
			s[i] = c;
		}
	} 
	for (int i = 1; i <= n; i++) fout << s[p[i]];
	fout << flush, fout.close();
}
```

:::::

### 【未完成】[QOJ16236 Two-Way Communication](https://qoj.ac/problem/16236)

### 【未完成】[CF1406E Deleting Numbers](https://www.luogu.com.cn/problem/CF1406E)

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB452$, '基础算法', array['题解'], null, '暂未评定', 'problem');

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
