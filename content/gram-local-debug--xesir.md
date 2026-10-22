---
id: gram-local-debug
title: '本地调试'
category: 语法技巧
subcategory: 调试技巧
subSubcategory: ''
tags: ["调试", "assert", "返回码", "对拍", "sanitizer", "Dev-C++"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

调试是 OI 里最耗时的环节之一。你可能花 20 分钟写代码，然后花 2 小时找 bug。熟练掌握调试工具和技巧，能把 2 小时压到 20 分钟。~~从入门到放弃~~

调试的本质是**缩小嫌疑范围**：先分清是「编译错」「运行错（RE）」还是「答案错（WA）」，再针对性地二分排查——要么二分代码（注释法），要么二分数据（对拍）。本篇按「工具 → 断言 → 检查错误 → 看返回码 → 个人技巧」的顺序梳理一遍。

## 逐行代码解析

### Dev-C++ 相关功能

Dev-C++ 虽然年代久远，但依然是很多 OI 选手的入门 IDE，NOI Linux 环境下也会用到 Dev。

**常用调试功能**：

- **设置断点（F4 / Toggle Breakpoint）**：在行号左侧点击，程序运行到断点时会暂停，方便观察变量值。
- **单步执行（F7 / Step Into，F8 / Step Over）**：逐行执行代码，观察程序流向。
- **查看变量（Add Watch）**：右键变量 → Add Watch，在调试窗口实时跟踪变量变化。
- **查看调用栈（Call Stack）**：函数嵌套调用时，查看当前执行到哪一层。
- **条件断点**：断点右键 → 设置条件（如 `i == 5`），只有条件满足时才触发。

**编译器选项**：

- `-O2`：开启优化，释放版本用；调试时建议关闭，否则变量可能被优化掉，无法查看。
- `-g`：生成调试信息，调试时必须开。
- `-Wall -Wextra`：开启所有警告，很多 bug 在警告阶段就能发现（比如未使用的变量、符号比较警告）。

### assert（断言）

- 定义：`assert(condition);` 若 `condition` 为 `false`，程序会终止并输出错误位置。
- 实用用法：

```cpp
#include <cassert>
assert(n > 0);                    // 如果 n <= 0，程序崩溃并报错
assert(vec.size() > i);           // 防越界
```

- 可在 `#define NDEBUG` 后禁用所有 `assert`，提交时避免 RE（通常在 `#include <cassert>` 前定义）。
- 适合在调试阶段检查「不应该发生」的情况，如数组下标、指针非空等。
- **不能**用于 OJ 题目的正常逻辑判断（因为 RE 会判错）。

### try-catch 与 throw（异常处理）

- 定义：`throw` 抛出异常，`try-catch` 捕获并处理。
- 实用用法：

```cpp
try {
    if (x < 0) throw runtime_error("x 不能为负数");
    // 正常逻辑
} catch (const exception &e) {
    cerr << "错误: " << e.what() << '\n';
}
```

- OI 适用性：**几乎不用**！OJ 评测不关心异常处理，反而增加代码复杂度和运行开销。但了解它能帮助理解一些库函数的报错机制（如 `vector::at()` 抛出的 `out_of_range`）。

### 防溢出

- 整数溢出：`int` 范围约 $2\times10^9$，`long long` 约 $9\times10^{18}$。乘法前先估算，必要时用 `__int128`：

```cpp
__int128 prod = (__int128)a * b;   // 防止 a*b 爆 long long
```

- 检查结果溢出：可用 `__builtin_add_overflow(a, b, &res)`、`__builtin_sub_overflow(a, b, &res)`、`__builtin_mul_overflow(a, b, &res)`，溢出返回 `true`，否则返回 `false` 并将结果存入 `res`。

### 防类型混乱

- 隐式类型转换隐患：

```cpp
unsigned int a = 5;
int b = -1;
if (a > b) { ... }   // 这里 b 被转为 unsigned，变成巨大正数，条件为假！
```

- 解法：避免 `unsigned` 与 `signed` 混用，或强制转型。
- 浮点数比较用 `eps`：

```cpp
const double eps = 1e-9;
if (fabs(a - b) < eps) { ... }   // 而非 a == b
```

### 防越界（指针 / 迭代器）

- 使用迭代器时，确保 `it != vec.end()` 再解引用。
- 使用 `vector` 时，`reserve()` 预分配空间，避免 `push_back` 导致迭代器失效。
- 用 `if (l > r) return;` 提前处理空区间，防止递归无限。
- 数组越界：开数组时多开 $5 \sim 10$ 个（`const int N = 100000 + 10;`），减少意外越界导致的 RE。
- 使用 `vector` 的 `at()` 代替 `[]` 可检查越界（但会降低效率，仅调试时可用）。

### 程序异常返回码（RE 信息识别）

在本地运行程序时，操作系统会返回退出码，对应不同的错误类型：

| 返回码 | 常见原因 | 对应信号 | 典型场景 |
|--------|---------|---------|---------|
| `-1073741819`（Windows）/ `11`（Linux） | 段错误（Segmentation Fault） | SIGSEGV | 数组越界、访问空指针、栈溢出 |
| `-1073741571`（Windows）/ `8`（Linux） | 浮点异常（Floating Point Exception） | SIGFPE | 除以零、取模零 |
| `-1073741676`（Windows）/ `6`（Linux） | 非法指令（Illegal Instruction） | SIGILL | 调用不存在的函数、指令错乱 |
| `-1073740791`（Windows）/ `4`（Linux） | 总线错误（Bus Error） | SIGBUS | 内存未对齐（较罕见） |
| `0` | 正常退出 | — | 程序运行成功 |

**识别方法**：

- Windows 下的 Dev-C++ 会显示「程序返回 -1073741819」之类的提示。
- Linux 下 `./a.out` 运行后用 `echo` 打印退出码查看返回值，或用 `dmesg | tail` 查看内核日志。
- 常见 RE 的快速定位：
  - **段错误**：大概率是数组越界或递归爆栈（递归深度大时要注意，可改非递归或增大栈空间）。
  - **浮点异常**：检查所有除法、取模的分母是否为 0。
  - **溢出**：`long long` 不够时用 `__int128`，或调整算法避免大数。

### 个人调试技巧

**输出调试（printf 大法）**：

- 在关键位置输出变量值，观察程序流向。
- 使用 `cerr` 而非 `cout`，因为 `cerr` 不缓冲且仅在调试窗口显示（不会生成到输出文件中），可避免忘删输出错乱 WA。（但还是建议最后检查一遍删掉，毕竟 `cerr` 也耗时间，容易 TLE）

```cpp
cerr << "x = " << x << ", y = " << y << '\n';
```

- 配合 `#ifdef LOCAL` 控制调试输出，提交时自动屏蔽：

```cpp
#ifdef LOCAL
    cerr << "n = " << n << '\n';
#endif
```

**二分定位 bug**：

- 如果程序在某个位置出错，用二分法注释掉代码段，逐步缩小范围。
- 例如在 `solve()` 函数中，先检查输入是否正确，再检查核心逻辑，最后检查输出。

**对拍（与暴力程序对比）**：

- 写一个暴力解法（慢但绝对正确），用随机数据生成器，对比两者输出。
- 脚本自动化：

```cpp
while true; do
    ./gen > in.txt
    ./std < in.txt > ans.txt
    ./my < in.txt > out.txt
    diff ans.txt out.txt || break
done
```

**使用 valgrind（Linux）**：

- 检测内存泄漏和越界：

```cpp
valgrind --tool=memcheck ./a.out
```

- 虽然 OI 环境不一定有，但本地调试时非常强大。

**检查 undefined behavior**：

- C++ 中很多行为是未定义的（如 `i++ + ++i`），使用 `-fsanitize=undefined` 编译可检测：

```cpp
g++ -fsanitize=undefined -g -o a a.cpp
```

**注释法**：

- 把疑似出错的代码段注释掉，看程序是否还 RE。
- 如果 RE 消失，说明问题在注释掉的这段里，再逐步放回。

### 调试流程建议

1. 编译时开 `-Wall -Wextra -g`，处理所有警告。
2. 运行小样例，用 `cerr` 输出中间关键变量。
3. 若 RE，检查数组大小、递归深度、除零。
4. 若 WA，写暴力对拍，定位差异点。
5. 若问题复杂，用二分注释法缩小范围。
6. 最后清理调试代码，提交。

## 复杂度分析

调试技巧本身不改变算法复杂度，但改变的是**你自己的时间**：

- `cerr` 输出一次是 $O(1)$，但会占用运行时间，大量输出可能让程序 TLE。
- 对拍的成本 = 暴力程序复杂度 × 数据组数，暴力要「慢但绝对正确」，别把它写复杂。
- `-fsanitize=undefined` 会给程序加一层检查，运行变慢（常数变大），只适合本地调试。
- `assert` 在 `NDEBUG` 下会被完全去掉，对正式提交零开销。

## 适用场景

- 编译报错 / 警告：开 `-Wall -Wextra`，先把警告清零。
- 运行崩溃（RE）：看返回码定位段错误 / 浮点异常，检查数组、递归、除零。
- 答案错误（WA）：`cerr` 输出中间变量，或用对拍找反例。
- 疑难杂症：二分注释法缩小范围，`-fsanitize` 查未定义行为，`valgrind` 查越界和泄漏。

## 常见陷阱与注意事项

1. **忘删调试输出**：`cout` 的调试输出会被 OJ 判 WA，用 `cerr` 或 `#ifdef LOCAL` 包起来更安全（但也别忘清理）。
2. **调试时别开 `-O2`**：被优化掉的变量在调试器里看不到，调试用 `-O0 -g`。
3. **`assert` 带副作用**：`assert(f(x))` 里的函数调用在 `NDEBUG` 下也会消失，别把有副作用的语句塞进 `assert`。
4. **数组尺寸留足余量**：开数组多开 5~10 个（`const int N = 100000 + 10;`），越界往往就差那么一两个。
5. **递归深度**：深递归会爆栈（本地表现为段错误），必要时改迭代或加大栈空间。
6. **`freopen` 影响调试**：本地开了重定向后，忘了改回去会导致「没有输出」，注意区分是没输出还是输出到了文件。

## 对比与扩展

| 现象 | 首选手段 |
|---|---|
| 编译警告 | `-Wall -Wextra` |
| WA | `cerr` 输出 / 对拍 |
| RE（段错误） | 查数组越界、递归深度、空指针 |
| RE（浮点异常） | 查除零 / 取模零 |
| 未定义行为 | `-fsanitize=undefined` |
| 内存泄漏 / 越界 | `valgrind` |

扩展：

- **对拍自动化**：把 `gen` / `std` / `my` 三个程序用脚本串起来循环跑，一有差异就停，比手搓样例高效得多。
- **`__builtin_*_overflow`**：比「算完再判断是否溢出」更可靠，能在溢出发生的当下就抓住。
- **调试与算法分离**：把调试输出全部塞进 `#ifdef LOCAL`，正式提交时一行 `-DLOCAL` 都不带，干净利落。
