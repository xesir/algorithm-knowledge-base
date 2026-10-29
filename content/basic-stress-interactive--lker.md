---
id: basic-stress-interactive
title: '对拍（交互题）'
category: 实用工具
subcategory: 调试
subSubcategory: 对拍
tags: ["对拍", "交互题", "grader", "checker", "随机数据"]
timeComplexity: '视数据组数与单次运行时间'
spaceComplexity: '视被测程序与 grader'
level: A
codePath: '基础算法\对拍\交互题对拍\grader--lker.cpp'
verified: 2026-10-20
source: 'lker'
---

## 算法原理

许多交互题虽然有 grader，但是不会自动生成数据。对于交互题，对拍思路是：

1. 按照一般交互题的方式，将 `grader.cpp` 和 `mine.cpp` 一起编译，生成一个可执行文件；注意，`grader.cpp` 中需要添加 `freopen`（或直接打开文件流），这样才能读取随机数据；
2. 再运行这个可执行文件和随机数据生成器；
3. 最后读取输出并编写 checker。

如果下发的 grader 已经包括自动判题的功能，那么我们可以从题目中复制一份下来，然后做简单修改（**不要直接在原来的 grader 中魔改**）。你可以使用原来的 grader 进行判题，也可以自己另外编写一个 checker，并将它和这个 grader 链接在一起。

下面以 [P15652 排列游戏](https://www.luogu.com.cn/problem/P15652) 为例。

首先一定要先执行下面的命令：

```cpp
g++ perm.cpp grader.cpp -o perm -std=c++14
```

将二者一起编译。因为现在的 grader 已经给出了判题功能，所以我们稍微修改一下就可以了。同样地，按照题目要求，我们在文件夹中放置一个 `perm.h` 文件。

这里的主要逻辑是：grader 调用 `data`，然后读取 `data.out` 中的数据，再调用 `perm` 函数（实际执行 `perm.cpp`），最后检查 `perm` 返回的结果。

### 三个文件各管什么

- `perm.h`：声明交互接口，`perm.cpp` 与 `grader.cpp` 都包含它；
- `perm.cpp`：只实现题目要求的 `init` 和 `perm`，通过 `query` 询问；
- `grader.cpp`：负责造数据（调 `data`）、读数据、提供 `query` 的实现、并在最后校验答案。

## 逐行代码解析

下面把 `grader.cpp` 拆成三块，三块按顺序拼起来就是完整程序。

### 接口与询问实现

```cpp
#include <bits/stdc++.h>
#include "perm.h"
using namespace std;

namespace grader {
    int n;
    vector<int> p;

    int ask(const vector<int> &a) {
        vector<int> vis(n);
        for (int x : a) {
            if (x < 0 || x >= n) return -1;
            vis[x] = 1;
        }
        for (int i = 0; i < n; i++)
            if (!vis[i]) return i;
        return n;
    }

    int query(int l, int r) {
        if (l < 0 || l > r || r >= n) return -1;
        return ask(vector<int>(p.begin() + l, p.begin() + r + 1));
    }
}

int query(int l, int r) {
    return grader::query(l, r);
}
```

- `grader::n`、`grader::p` 保存当前这组数据，`check()` 每验一组就重新赋值。
- `ask(a)` 求「集合 `a` 里没有出现的最小非负整数」：先标记出现过哪些数，再从 0 往上找第一个没被标记的；全部出现则返回 `n`。下标越界直接返回 `-1`，这是一种防御式写法。
- `query(l,r)` 先做区间合法性检查，再把 `p[l..r]` 交给 `ask`——这就是题面里选手能调用的询问。
- 最外层再包一个 `query`，把 `grader` 命名空间里的实现暴露给 `perm.cpp`，对应 `perm.h` 中的函数声明。

### 校验：先看是不是排列，再看所有询问是否一致

```cpp
bool check(const vector<int> &p) {
    int n = p.size();
    grader::n = n, grader::p = p;
    vector<int> q = perm(n), vis(n);
    if ((int)q.size() != n) return false;

    for (int x : q) {
        if (x < 0 || x >= n || vis[x]) return false;
        vis[x] = 1;
    }
    for (int l = 0; l < n; l++)
        for (int r = l + 1; r < n; r++) {
            vector<int> a(p.begin() + l, p.begin() + r + 1);
            vector<int> b(q.begin() + l, q.begin() + r + 1);
            if (grader::ask(a) != grader::ask(b)) return false;
        }
    return true;
}
```

- 先把本组数据塞进 `grader`，再调用选手的 `perm(n)` 拿答案。
- 第一层校验：长度必须是 $n$，且每个数在 $[0,n)$ 内、互不重复——也就是必须是一个排列。
- 第二层校验：对所有 $l<r$，原排列和答案排列在同一段区间上的 `mex` 必须相同。这正是题目「询问结果完全一致」的定义。
- 这里是 $O(n^3)$ 的暴力比较（$O(n^2)$ 个区间 × $O(n)$ 求 mex），只适合对拍用的小数据。

### 主程序：反复造数据、逐组判题

```cpp
int main(int argc, char **argv) {
    int rounds = argc > 1 ? atoi(argv[1]) : 10000;
    bool ok = rounds > 0;

    for (int T = 1; T <= rounds && ok; T++) {
        if (system("./data > data.out")) {
            ok = false;
            break;
        }

        ifstream fin("data.out");
        int c, t;
        if (!(fin >> c >> t)) {
            ok = false;
            break;
        }
        init(c, t);

        while (t-- && ok) {
            int n;
            if (!(fin >> n) || n < 2) {
                ok = false;
                break;
            }

            vector<int> p(n), vis(n);
            for (int &x : p) fin >> x;
            if (!fin) {
                ok = false;
                break;
            }

            for (int x : p) {
                if (x < 0 || x >= n || vis[x]) {
                    ok = false;
                    break;
                }
                vis[x] = 1;
            }
            if (ok) ok = check(p);
        }
    }

    cout << (ok ? "Passed\n" : "Failed\n");
    return !ok;
}
```

- `rounds` 从命令行参数读，默认 10000 轮；`main` 的返回值用 `!ok`，这样失败时进程退出码非 0，方便脚本判断。
- `system("./data > data.out")` 直接让生成器把数据写进 `data.out`，省掉在 `data.cpp` 里写 `freopen`。返回值非 0 说明生成器本身崩了。
- 读进来的 `c`、`t` 交给选手的 `init(c,t)`，对应题面的初始化参数。
- 每组数据先校验读入的 `p` 本身是不是合法排列——**数据生成器也要被验**，否则生成器出错会把选手的正确程序误判成 WA。
- 全部通过打印 `Passed`，否则 `Failed`；没有做「第几组挂了」的定位，需要定位可以自己加计数输出。

### 选手侧与数据生成器

`perm.h` 只放接口声明：

```cpp
#ifndef PERM_H
#define PERM_H

#include <vector>

void init(int c, int t);
std::vector<int> perm(int n);
int query(int l, int r);

#endif
```

`perm.cpp` 只实现 `init` 和 `perm`，通过 `query` 询问：

```cpp
void init(int c, int t) {}

vector<int> perm(int n) {
    vector<int> pre(n), suf(n);
    int pos = n - 1;
    for (int i = 0; i < n - 1; i++) {
        pre[i] = query(i + 1, n - 1);
        if (!pre[i]) {
            pos = i;
            for (int j = n - 1; j > i; j--) suf[j] = query(0, j - 1);
            break;
        }
    }

    vector<int> ans(n, -1), vis(n);
    ans[0] = pre[0], ans[n - 1] = suf[n - 1];
    vis[ans[0]] = vis[ans[n - 1]] = 1;
    for (int i = 1; i < n - 1; i++) {
        if (pre[i] != pre[i - 1]) ans[i] = pre[i], vis[ans[i]] = 1;
        if (suf[i] != suf[i + 1]) ans[i] = suf[i], vis[ans[i]] = 1;
    }

    for (int l = 0, r = n - 1, i = n - 1;; i--) {
        while (i >= 0 && vis[i]) i--;
        if (i < 0) break;
        while (l < pos && ans[l] != -1) l++;
        while (r > pos && ans[r] != -1) r--;
        if (pre[l] > suf[r]) ans[l] = i;
        else ans[r] = i;
        vis[i] = 1;
    }
    return ans;
}
```

`data.cpp` 负责生成若干组排列：

```cpp
    mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
    int c = 0, t = 20;
    cout << c << ' ' << t << '\n';

    for (int T = 1; T <= t; T++) {
        int n = T <= 3 ? T + 1 : rng() % 79 + 2;
        vector<int> p(n);
        iota(p.begin(), p.end(), 0);
        if (T == 2) reverse(p.begin(), p.end());
        else shuffle(p.begin(), p.end(), rng);

        cout << n << '\n';
        for (int i = 0; i < n; i++)
            cout << p[i] << " \n"[i == n - 1];
    }
```

- `perm.h` 的头文件保护不能省，`perm.cpp` 与 `grader.cpp` 都会包含它。
- `data.cpp` 把 $c$、$t$ 写在第一行，后面依次是每组数据，和 `grader` 的读取顺序严格对应。
- 前 3 组固定用很小的 $n$（并且第 2 组是逆序），先把边界情况覆盖掉，再随机放大。

## 复杂度分析

对拍的总开销是「轮数 × 每组数据规模下 grader 的判题时间」。这里的 `check` 是 $O(n^3)$，所以 `data.cpp` 把 $n$ 限制在 80 以内。真正交题的 grader 通常有更高效的判题方式，不要照搬这里的暴力校验。

## 适用场景

- 交互题本地验证：题目只给 grader、不给数据生成器时，自己补一个 `data.cpp` 和驱动逻辑。
- 需要「多次询问、询问结果必须一致」这类一致性校验的题。
- 想批量测试选手函数在不同数据下的表现，而不只是跑官方几个样例。

## 常见陷阱

- **编译顺序**：必须 `g++ perm.cpp grader.cpp -o perm` 一起编译，单独编 `perm.cpp` 会缺 `query` 的实现，链接失败。
- **直接修改原 grader**：题目下发的 grader 是判题基准，改了就没法保证和官方一致。一定复制一份再改。
- **数据生成器不合法**：`grader` 里那段「检查 `p` 是不是排列」就是防这个的；自己的生成器一定要满足题面约束。
- **交互次数超限**：真实题目对 `query` 的次数有上限，本地对拍时也要顺手统计一下，别只验答案对不对。
- **`data.cpp` 与 `data.out` 的通道**：本例用 `system("./data > data.out")` 重定向，若改成 `freopen`，`grader` 里的读取方式要同步改。
- **Windows 环境**：`system("./data")` 在 Windows 下要写成 `system("data")`。

## 对比与扩展

- 与「SPJ 与构造题对拍」的区别：交互题的 checker 必须和 grader 链接在一起，因为它要复用 `query` 的实现去模拟交互过程。
- 若题目自带完整的自动判题 grader，最省事的做法是只补 `data.cpp` + 外层循环，不重写 checker。
- 想定位是第几组挂的，可以在 `check` 失败时打印当前 $T$ 和 $n$，比只打印 `Failed` 有用得多。
