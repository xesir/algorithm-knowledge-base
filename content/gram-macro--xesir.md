---
id: gram-macro
title: '宏孩儿（#define、typedef 与 using）'
category: 语法技巧
subcategory: 宏与别名
subSubcategory: ''
tags: ["宏", "#define", "typedef", "using", "条件编译", "模板别名"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

头文件下三兄贵：`#define`、`using` 与 `typedef`，都能给一段代码起个「外号」。它们的本领相近，脾气却差很远。

先分清辈分：

- `#define` 属于**预处理器**。它在编译之前工作，做的事就是**纯文本替换**——把 `A` 无脑换成 `B`，替换完再交给编译器。它没有作用域、没有类型、不懂语法。
- `typedef` 是 C++98 的**类型别名**写法，有类型、有作用域，交给编译器处理。
- `using` 是 C++11 的新写法，同样是类型别名，但更灵活，还能做**模板别名**（`typedef` 做不到）。

一句话总结：`#define` 是「暴力的文本替换」，`typedef` / `using` 是「编译器认可的真别名」。能用后者就别用前者，这是老生常谈但依然有人记不住的忠告。

## 逐行代码解析

### 常用宏

```cpp
#define int long long              // 一键开 long long
#define For(i,x,y) for(int i=x;i<=y;i++)
#define all(x) x.begin(), x.end()  // 遍历神器
#define lowbit(x) (x & -x)         // 树状数组必备
#define ls dio[u].lc
#define rs dio[u].rc 
#define mid ((l+r)>>1)             // 线段树/二分常用
#define fi first
#define se second
#define pb push_back
#define vi vector<int>
#define PII pair<int, int>         // 单纯省字
```

- `#define int long long` 是最出圈的宏：全局把 `int` 偷换成 64 位，代价是常数变大、`main` 得写成 `signed main()`。
- 参数宏两侧的括号不能省：`#define lowbit(x) (x & -x)` 里那对括号是保命的，否则 `lowbit(a+b)` 展开后会跟着运算符优先级错位。
- `#define mid ((l+r)>>1)` 同理，双保险括号是为了不被外层运算符「吃掉」。

### 条件编译

```cpp
#ifdef LOCAL
    freopen("in.txt", "r", stdin);
#endif
```

- `#ifdef LOCAL` 表示「只有定义了 `LOCAL` 宏才编译这段」，本地调试时加 `-DLOCAL`，提交时去掉。
- 这是把调试代码和正式代码合进一份文件里的经典技巧。

### 可变参数宏（C++11）

```cpp
#define debug(...) fprintf(stderr, __VA_ARGS__)
debug("x = %d, y = %d\n", x, y);
```

- `__VA_ARGS__` 接住 `...` 里的全部参数，宏也能像函数一样接不定参数。
- 注意它依然是文本替换，报错位置会以展开后为准，调试时容易懵。

### typedef vs using

- `typedef` 是 C++98 的老写法，`using` 是 C++11 的新写法，更灵活。
- `using` 支持**模板别名**（`typedef` 不支持）：

```cpp
template<class T> using vec = vector<T>;           // using 模板别名
template<class T> using pii = pair<T, T>;
```

- 函数指针别名：

```cpp
typedef void (*Func)(int);                         // 老
using Func = void(*)(int);                         // 新（更直观）
```

- 函数指针别名这组对比最能说明问题：`using` 把新名字放左边、类型放右边，一眼能看出谁是谁；`typedef` 的嵌套括号则要反应半天。

## 复杂度分析

三者都是**编译期**的东西，运行期一条指令都不多。

- `#define` 的开销在预处理阶段：文本替换，宏越大、用得越多，编译越慢，但生成的代码与手写等价。
- `typedef` / `using` 只是给类型起别名，不生成任何代码，运行期开销为零。
- 真正要算「代价」的是可维护性：`#define` 无作用域、纯文本替换，一旦和同名变量撞上，报错信息会变得面目全非。

## 适用场景

- `#define`：`For` / `all` / `lowbit` 这类短小的代码片段替换，以及 `#ifdef` 条件编译。
- `typedef` / `using`：给类型起别名，让 `long long`、`pair<int,int>` 这类冗长类型变短。
- `using`：需要模板别名时是唯一选择。
- 定义常量时，优先 `const` / `constexpr` 而不是 `#define`。

## 常见陷阱与注意事项

1. **宏是文本替换，不是函数**：`#define sq(x) x*x` 在 `sq(a+b)` 下会展开成 `a+b*a+b`，参数和整体都要加括号。
2. **宏没有作用域**：一旦 `#define` 了，后面所有代码都受影响，容易和其他库撞名，必要时用 `#undef` 撤销。
3. **宏不能当变量用**：调试器看不到它，断点打进去也是一团展开后的代码，实际赛场能不用就不用。~~网赛用一用还是很方便的~~
4. **`#define int long long` 的连带后果**：开了它 `main` 要写 `signed main()`，而且全局常数变大，卡常题慎用。
5. **`typedef` 写不出模板别名**：`template<class T> typedef vector<T> vec;` 是非法的，只能改用 `using`。
6. **`#pragma once` 与头文件守卫**：`#pragma once` 比 `#ifndef/#define/#endif` 简洁，但老式守卫在跨文件同名时更稳，别一味图省事。

## 对比与扩展

| 维度 | `#define` | `typedef` | `using` |
|---|---|---|---|
| 处理阶段 | 预处理器（文本替换） | 编译器 | 编译器 |
| 有作用域 | 否 | 是 | 是 |
| 支持模板别名 | — | 否 | 是 |
| 可调试性 | 差 | 好 | 好 |

扩展：

- `constexpr` 定义常量，类型安全、可调试、能参与编译期计算，是 `#define` 常量的现代替代。
- `#undef` 用于「用完即撤」，避免宏污染扩散。
- `#pragma once` 是目前大多数编译器都支持的头文件去重方案。
