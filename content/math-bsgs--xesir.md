---
id: math-bsgs
title: 'BSGS 大步小步算法'
category: 数学
subcategory: 数论基础
subSubcategory: '同余与模运算'
tags: ["数学", "数论", "BSGS", "离散对数", "高次同余方程", "分块", "哈希表"]
timeComplexity: 'O(√p)'
spaceComplexity: 'O(√p)'
level: A
codePath: '数学\数论基础\BSGS\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

大步小步算法（Baby-Step Giant-Step，BSGS）用于解决高次同余方程问题，典型的分块思想运用，复杂度 $O(\sqrt p)$。

**问题：** 给定整数 $a,b,p$ 且 $a \perp p$，求使 $a^x \equiv b \pmod p$ 的最小非负整数 $x$。

**思路：** 暴力枚举是绝对不可行的，我们考虑压缩搜索空间。

由扩展欧拉定理 $a^x \equiv a^{x \mod \varphi(p)} \pmod p$ 可以得到 $a^x$ 在模 $p$ 意义下的最小循环节为 $\varphi(p)$。而 $\varphi(p)$ 的最大值是 $p-1$，故我们只需要在 $[0,p]$ 中判断即可。

显然暴力判断 $[0,p]$ 的复杂度是 $O(p)$ 也不够优，对于 $p \le 10^9$ 数据我们需要更优的解法。这时候我们要用到分块思想。令 $m=\lfloor \sqrt p \rfloor$，设 $x=im-j$，其中 $1 \le i \le m,0 \le j \le m-1$。

则有 $a^{im-j} \equiv b \pmod p$，即 $(a^m)^i \equiv ba^j \pmod p$。于是转换为最小化 $i$ 下最大化 $j$。

- 先枚举 $j$（Baby Step），将 $\{ba^j, j\}$ 作为键值对存入哈希表中，重复时取更大的。
- 后枚举 $i$（Giant Step），查找哈希表中键为 $a^{mi}$ 的元素，第一次找到即为最小值。

枚举 $j$ 和 $i$ 的复杂度都是 $O(\sqrt p)$，故总体复杂度也是 $O(\sqrt p)$，可以接受。

## 核心公式

| 内容 | 公式 |
|---|---|
| 原方程 | $a^x \equiv b \pmod p$ |
| 循环节 | 最小循环节为 $\varphi(p)$，答案只需在 $[0,p]$ 内找 |
| 设块长 | $m = \lceil \sqrt p \rceil$，$x = im - j$ |
| 变形 | $(a^m)^i \equiv b a^j \pmod p$ |
| 枚举范围 | $1 \le i \le m$，$0 \le j \le m-1$ |

## 逐行代码解析

### 模块一：预处理与边界

```cpp
int bsgs(int a,int b,int p){
    h.clear();
    if(__gcd(a,p)!=1) return -1;
	a%=p,b%=p;
	if(b==1) return 0;
```

- `h.clear()`：哈希表是全局或外部维护的，每次调用前必须清空，否则上一组的 $\{ba^j, j\}$ 会污染答案。
- `__gcd(a,p) != 1` 直接返回 `-1`：BSGS 要求 $a \perp p$，不互质时逆元/循环节性质都不成立。
- `a %= p, b %= p` 先把底数和目标压回模范围内。
- `b == 1` 时 $x = 0$ 就是最小非负解，直接返回，省掉后面的枚举。

### 模块二：Baby Step，把 $ba^j$ 存表

```cpp
	int m=ceil(sqrt(p)),t=b,k=ksm(a,m,p);
	h[b]=0;
	for(int j=1;j<m;j++){
		t=t*a%p;h[t]=j;
	}
```

- `m = ceil(sqrt(p))` 是块长，`k = a^m mod p` 后面 Giant Step 要用。
- `h[b] = 0` 对应 $j=0$：$ba^0 = b$。
- 循环从 $j=1$ 到 $m-1$，每次 `t = t * a % p` 递推得到 $b a^j$，把下标 `j` 存进哈希表。
- 题目要求“最小化 $i$ 下最大化 $j$”，所以同一个键后写入的更大 $j$ 会覆盖先前的值（代码里是直接赋值）。

### 模块三：Giant Step，查表得答案

```cpp
	t=1;
	for(int i=1;i<=m;i++){
		t=t*k%p;
		if(h.count(t)) return i*m-h[t];
	}
	return -1;
}
```

- `t` 从 $1$ 开始，每轮乘一次 $a^m$，第 $i$ 轮就是 $(a^m)^i$。
- 一旦哈希表里存在这个键，说明 $(a^m)^i \equiv b a^j$，返回 $x = im - j$。
- 从 $i=1$ 开始从小到大枚举，第一次命中就是最小的 $i$；同一 $i$ 下存的是最大的 $j$，对应最小的 $x$。
- 全部枚举完还没命中，说明在 $[0,p]$ 内无解，返回 `-1`。

## 复杂度分析

- 时间复杂度：Baby Step 枚举 $O(\sqrt p)$ 次，Giant Step 枚举 $O(\sqrt p)$ 次，哈希表单次期望 $O(1)$，总计 $O(\sqrt p)$。
- 空间复杂度：哈希表最多存 $O(\sqrt p)$ 个键值对。
- 原文口径就是 $O(\sqrt p)$，适用于 $p \le 10^9$ 的数据。

## 适用场景

- 求解 $a^x \equiv b \pmod p$ 的最小非负整数解（离散对数）。
- 模数 $p$ 是质数、且 $a$ 与 $p$ 互质时最标准；不互质时这套写法直接返回 `-1`，需要 exBSGS 另做处理。
- 需要枚举“指数型”状态、但指数范围达到 $10^9$ 级别的计数/判定问题。
- 与哈希表结合，是“空间换时间”的典型分块模型。

## 常见陷阱

1. **忘记清空哈希表**：多组数据时上一组的残留会让答案直接错掉。
2. **没有判断 $\gcd(a,p)=1$**：不互质时方程可能仍有解，但本实现会误报无解。
3. **`b == 1` 的特判漏掉**：$x=0$ 是合法解，漏判会在某些数据上返回 `-1` 或错误值。
4. **块长取整方式**：`ceil(sqrt(p))` 与 `floor(sqrt(p))` 都能过，但枚举范围要与块长配套，混用容易漏掉边界。
5. **哈希表覆盖顺序**：要求同一键保留更大的 $j$，如果先存大 $j$ 再被小 $j$ 覆盖，答案就不是最小的 $x$。
6. **返回值可能超过 $p$**：$im-j$ 的理论范围要自己核对，必要时对 $\varphi(p)$ 取最小表示。
7. **`int` 溢出**：`t * a`、`t * k` 在 $p$ 接近 $10^9$ 时会爆 `int`，应转 `long long`。

---
> BSGS 的本质就是“把 $x$ 拆成 $im-j$，一半存表、一半查表”。想清楚为什么这么拆能把 $O(p)$ 压到 $O(\sqrt p)$，比背代码有用得多。
