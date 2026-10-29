---
id: prob-cf-1365g
title: 'Secure Password'
oj: 'Codeforces'
problemId: 'CF1365G'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 基础算法
tags: ['题解']
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
knowledgePoints: []
---

> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

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

见原文正文中的说明。
