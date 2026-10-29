---
id: gram-io-tips
title: '输入输出相关冷知识'
category: 实用工具
subcategory: IO
subSubcategory: IO冷知识
tags: ["输入输出", "快读快写", "fread", "freopen", "卡常", "sync_with_stdio"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

OI 中 IO 效率往往决定程序的生死，尤其是大数据量时——同样的算法，别人 `scanf` 全过，你用没关同步的 `cin` 却全 T 掉。原因很简单：C++ 的 `cin` / `cout` 默认与 C 的 `stdio` **保持同步**，每次 IO 都要协调两边缓冲区，白白多花时间。

所以 IO 优化的主线就一句话：**减少同步、减少刷新、减少调用次数**。把同步关掉（`sync_with_stdio(false)`）、把 `endl` 换成 `'\n'`（不主动刷新）、大数据改用 `getchar` / `fread` 批量读，速度就能一节一节往上爬。

## 逐行代码解析

### 各 IO 方式对比

| 方式 | 速度 | 适用场景 | 优点 | 缺点 |
|------|------|---------|------|------|
| `cin` / `cout`（默认） | 慢 | 小数据（$10^5$ 以内） | 简洁，类型安全 | 慢，同步消耗大 |
| `cin` / `cout` + `ios::sync_with_stdio(false); cin.tie(nullptr);` | 快（竞赛最常用） | 常规数据（$10^6$） | 简洁，可关闭同步 | 不能与 `stdio` 混用 |
| `scanf` / `printf` | 较快 | 常规数据 | 简单，效率稳定 | 格式串繁琐，类型不安全 |
| `getchar()` / `putchar()` 快读快写 | 极快 | 大数据（$10^7$） | 极速，可自定义 | 实现麻烦，仅支持基本类型 |
| `fread` / `fwrite` | 最快 | 极限数据（$10^8$） | 批量读写，速度最快 | 代码冗长，需自己解析 |

- 一般做题默认用 `ios::sync_with_stdio(false)` 加 `'\n'` 就够了。

### 关闭同步流

```cpp
ios::sync_with_stdio(false);
cin.tie(nullptr);
cout.tie(nullptr);
```

- 让 C++ 流不再与 C 标准流同步，大幅提升 `cin` / `cout` 速度，但**不能再和 `scanf` / `printf` 混用**，混用会乱序。

### 使用 '\n' 而非 endl

- `endl` 会刷新缓冲区，拖慢速度；`'\n'` 不会。大数据输出时差异明显。
- 记住：`endl` = 换行 + 刷新，多出来的刷新就是白送的时间。

### 一次性输出

- 用 `std::ostringstream` 或直接 `string` 拼接，最后 `cout << str`，减少 IO 调用次数：

```cpp
string out;
out += to_string(ans);
out += '\n';
cout << out;
```

- 每次 `cout <<` 都可能触碰缓冲区，先拼成一个大字符串再输出，调用次数从 $n$ 降到 1。

### 快读模板（getchar 版本）

```cpp
inline int read() {
    int x = 0, f = 1; char ch = getchar();
    while (ch < '0' || ch > '9') { if (ch == '-') f = -1; ch = getchar(); }
    while (ch >= '0' && ch <= '9') { x = (x << 1) + (x << 3) + (ch ^ 48); ch = getchar(); }
    return x * f;
}
inline void write(int x) {
    if (x < 0) putchar('-'), x = -x;
    if (x > 9) write(x / 10);
    putchar(x % 10 + '0');
}
```

- `read` 用 `x = (x<<1) + (x<<3) + (ch^48)` 等价于 `x = x*10 + (ch-'0')`，位运算更快。
- `write` 是递归版，先把高位输出完再输出末位，天然正序。

### fread 批量读入（终极优化）

```cpp
const int BUFSIZE = 1 << 20;
char buf[BUFSIZE], *p1 = buf, *p2 = buf;
#define getchar() (p1 == p2 && (p2 = (p1 = buf) + fread(buf, 1, BUFSIZE, stdin), p1 == p2) ? EOF : *p1++)
```

- 一次 `fread` 把一大块数据读进缓冲区，`getchar` 从缓冲区取字符，系统调用次数骤减。
- 搭配上面的 `read()` 使用，适合 $10^7$ 以上输入。

### 文件读入 / 输出

- **重定向（最常用）**：

```cpp
freopen("data.in", "r", stdin);
freopen("data.out", "w", stdout);
```

之后所有 `cin` / `scanf` 和 `cout` / `printf` 都会从文件读写，OJ 提交时无需删除（OJ 没有对应文件就会回落到标准输入输出，CCF_NOI 系列基本通用要求）。

- **本地调试开关**：

```cpp
#ifdef LOCAL
    freopen("in.txt", "r", stdin);
    freopen("out.txt", "w", stdout);
#endif
```

编译时加 `-DLOCAL`，提交时去掉即可。

- **`ifstream` / `ofstream`**（面向对象方式）：

```cpp
ifstream fin("data.in");
ofstream fout("data.out");
fin >> x;
fout << x;
```

速度不如重定向，一般不用于 OI。

## 复杂度分析

IO 优化的「复杂度」体现在调用次数上：

- 默认 `cin` / `cout` 因为同步，相当于每次 IO 都带一个不小的常数因子。
- 关同步后，逻辑上仍是「读 $n$ 个数字」，但常数大幅缩小；`scanf` 与关同步的 `cin` 数量级相当。
- `getchar` 快读把每个字符的获取降到一次函数调用（乃至一次缓冲区访问），$O(1)$ 处理一位数字。
- `fread` 把 $O(n)$ 次系统调用压到 $O(n / \text{BUFSIZE})$，这是质变。

所以本质上优化的是**常数**，不改变算法复杂度，但在卡常题里常数就是生死。

## 适用场景

- 小数据：默认 `cin` / `cout` 直接用，别为了省事牺牲可读性。
- 常规数据（$10^6$ 级）：关同步 + `'\n'`，这是最常用的组合。
- 大数据（$10^7$ 级）：上 `getchar` 快读模板。
- 极限数据（$10^8$ 级）：`fread` 批量读入。
- 需要文件输入输出 / 本地调试时：`freopen` 或 `#ifdef LOCAL` 开关。

## 常见陷阱与注意事项

1. **关同步后别混用 `stdio`**：`ios::sync_with_stdio(false)` 之后再用 `scanf` / `printf` 可能乱序，二选一。
2. **`endl` 拖速度**：输出量大时 `endl` 的刷新开销很明显，统一用 `'\n'`。
3. **`#define getchar()` 的副作用**：重定义 `getchar` 后 `cin` / `scanf` 也会受影响，通常只在纯快读程序里这么干。
4. **`freopen` 的文件名**：写错文件名不会报错，程序会静默读空 / 写到别处，本地测试时务必核对。
5. **`__int128` 无法直接 IO**：`cin` / `cout` / `printf` 都不支持，要读字符串自己转，或扩展快读模板。
6. **输出末行换行**：有些 OJ 对行尾敏感，最好每行都以 `'\n'` 收尾。

## 对比与扩展

| 需求 | 推荐方案 |
|---|---|
| 省事 | 默认 `cin` / `cout` |
| 竞赛通用 | 关同步 + `'\n'` |
| 大数据 | `getchar` 快读 / `putchar` 快写 |
| 极限数据 | `fread` / `fwrite` |
| 文件 IO | `freopen` |

扩展：

- **`getchar_unlocked` / `putchar_unlocked`**（Linux 下非线程安全、但更快）：单线程程序里配合快读能再快一截。
- **`__int128` 的读写**：先读字符串再手写转换，或写成支持 `__int128` 的快读扩展。
- **`cout` 的 `rdbuf` 替换**：可挂自定义缓冲区，但很少用，了解即可。
