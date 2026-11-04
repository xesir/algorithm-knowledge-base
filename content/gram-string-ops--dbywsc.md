---
id: gram-string-ops
title: '字符串常用操作'
category: 实用工具
subcategory: 语法技巧
tags: ["字符串", "STL", "string", "语法", "输入输出"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-11-04
source: 'dbywsc'
---

## 算法原理

C++ 的 `std::string` 封装了字符数组的大部分操作，配合 `cin` / `cout`、`getline` 和 STL 算法，可以完成竞赛中绝大多数字符串处理。

常见操作可以分成几类：

- 读入：`cin >> s` 读一个单词，`getline(cin, s)` 读一整行；
- 遍历：下标遍历、范围遍历、找最大值/最小值；
- 修改：插入、删除、替换、拼接；
- 查找：`find`、`rfind`、`find_first_of`；
- 截取：`substr`；
- 转换：`stoi` / `stoll` / `to_string`；
- 字符判断：`isdigit`、`isalpha`、`isalnum`、`islower`、`isupper`、`tolower`、`toupper`。

## 核心公式 / 状态定义与转移方程

- `s.size()` / `s.length()`：字符串长度，返回无符号类型，和 `int` 比较时注意符号。
- `s[i]`：下标从 $0$ 开始；越界是未定义行为。
- `s.substr(pos, len)`：从 `pos` 开始截取 `len` 个字符；`len` 省略时截到末尾。
- `s.find(t)`：返回第一次出现的位置，找不到返回 `string::npos`（不是 $-1$，虽然常和 $-1$ 比较）。
- `s.insert(pos, t)`：在 `pos` 前插入；`s.erase(pos, len)`：从 `pos` 起删除 `len` 个。
- `s.replace(pos, len, t)`：把从 `pos` 起 `len` 个字符替换成 `t`。
- `stoi(s)` / `stoll(s)`：字符串转 `int` / `long long`；`to_string(x)`：数字转字符串。

## 逐行代码解析

### 循环读入

```cpp
char ch;
while (cin >> ch) {
    cout << ch;
}
```

- `cin >> ch` 会跳过空白字符，逐字符读入直到输入结束。
- 若要保留空格/换行，用 `getline(cin, s)`。

```cpp
string a, b;
while (cin >> a >> b) {
    // 处理一对字符串
}
```

- 适合没有固定组数的多测输入；`cin` 在读到 EOF 时返回假，循环结束。

### 遍历找最值

```cpp
char maxn = 0, minn = 127;
int idx = 0, idx2 = 0;
for (int i = 0; i < (int)s.size(); i++) {
    if (s[i] > maxn) {
        maxn = s[i];
        idx = i;
    }
    if (s[i] < minn) {
        minn = s[i];
        idx2 = i;
    }
}
```

- 找第一个最大值/最小值：用严格大于/小于，只在第一次出现时更新。
- 找最后一个最大值/最小值：用大于等于/小于等于，最后一次出现时更新。
- `s.size()` 是无符号类型，循环变量用 `int` 时建议先转换，避免符号比较警告。

### 插入

```cpp
s.insert(idx, str);      // 在 s 的第 idx 个字符前插入 str
s.insert(idx + 1, str);  // 在 s 的第 idx 个字符后插入 str
```

- `insert(pos, t)` 的 `pos` 是下标，范围 $0\sim size$；`pos == size` 表示末尾插入。

### 删除

```cpp
s.erase(idx, len);   // 从 idx 起删除 len 个字符
```

- 若 `len` 省略，删除从 `idx` 到末尾。
- 删除后字符串长度变小，后续下标要重新计算。

### 查找

```cpp
size_t p = s.find(str);
if (p != string::npos) {
    cout << p << '\n';
}
```

- `find` 返回第一次出现的位置；找不到返回 `string::npos`。
- `rfind` 从后往前找；`find_first_of` 找任意一个字符第一次出现。

### 替换

```cpp
s.replace(start, len, str);   // 把 [start, start+len) 替换成 str
```

- `start` 是下标，`len` 是要替换的长度。
- 替换后字符串长度可能变化。

### 截取

```cpp
string t = s.substr(start, len);   // 从 start 起截取 len 个字符
string u = s.substr(start);        // 截取到末尾
```

- `start` 不能越界；`len` 超过剩余长度时只截到末尾。

### 拼接

```cpp
string ans;
for (int i = 1; i <= n; i++) {
    ans = s[i] + ans;   // 头插，最终顺序会反过来
}
```

```cpp
string ans;
for (int i = 1; i <= n; i++) {
    ans = ans + s[i];   // 尾插，保持原顺序
}
```

- `ans = s[i] + ans` 是头插，适合逆序构造；`ans += s[i]` 是尾插。
- 大量拼接时 `+=` 通常比反复 `ans = ans + ...` 更高效。

### 字符串转数字

```cpp
string s;
cin >> s;
int x = stoi(s);        // 转 int
long long y = stoll(s); // 转 long long
```

- `stoi` / `stoll` 会跳过前导空格，遇到非数字停止；转换失败会抛异常。
- 也可以用手写 `for` 逐位累加，避免异常开销。

### 数字转字符串

```cpp
int x;
cin >> x;
string s = to_string(x);
```

- `to_string` 支持整数、浮点数；浮点数的格式由实现决定。

### 大小写转换

```cpp
char c = 'a';
if (islower(c)) c = toupper(c);   // 小写转大写
if (isupper(c)) c = tolower(c);   // 大写转小写
```

- `tolower` / `toupper` 返回 `int`，赋给 `char` 时注意转换。
- 只对字母有效，其他字符原样返回。

### 整行读入

```cpp
string s;
getline(cin, s);
```

- `getline` 读入一整行，保留空格。
- 如果前面用了 `cin >>`，缓冲区里可能残留换行符，先 `cin.ignore()` 再 `getline`。

### 字符判断

```cpp
if (isdigit(c)) { /* 数字字符 */ }
if (isalpha(c)) { /* 字母 */ }
if (isalnum(c)) { /* 字母或数字 */ }
```

- 这些函数接收 `unsigned char` 或 `EOF`；传负的 `char` 可能未定义，必要时先转 `unsigned char`。

## 复杂度分析

- `size` / 下标访问：$O(1)$。
- `find` / `rfind`：最坏 $O(nm)$（朴素匹配）；`substr` / `insert` / `erase` / `replace`：$O(n)$。
- 拼接 `+=`：均摊 $O(1)$（按容量增长）；反复 `ans = ans + ...` 可能 $O(n^2)$。
- 字符串转数字 / 数字转字符串：$O(\text{长度})$。

## 适用场景

- 读入单词、整行、逐字符处理。
- 统计字符出现次数、找最大/最小字符、判断回文。
- 插入、删除、替换、截取子串。
- 字符串与数字互转。
- 大小写转换、字符类型判断。
- 构造答案字符串、逆序拼接。

## 常见陷阱与注意事项

1. **`cin >> s` 不读空格**：需要整行用 `getline`；`cin >>` 后接 `getline` 要先 `cin.ignore()`。
2. **`s.size()` 是无符号类型**：和 `int` 比较时可能出现符号问题；循环用 `(int)s.size()` 或 `size_t`。
3. **`find` 找不到返回 `string::npos`**：不要直接和 $-1$ 比较，虽然 `npos` 通常是最大值；用 `!= string::npos`。
4. **下标越界**：`s[i]` 不检查边界；`substr` / `erase` / `replace` 的 `pos` 要在合法范围。
5. **`insert` / `erase` 后下标变化**：修改后旧下标可能失效，重新计算。
6. **`tolower` / `toupper` 返回 `int`**：赋给 `char` 时显式转换；参数用 `unsigned char`。
7. **`stoi` 异常**：输入不合法会抛异常；竞赛中可手写转换或先判断。
8. **大量字符串拼接**：`ans = ans + s` 可能 $O(n^2)$，用 `ans += s` 或 `reserve`。

## 对比与扩展

- **`string` vs `char[]`**：`string` 自动管理内存、支持动态长度；`char[]` 更快但容易越界。
- **`cin >>` vs `getline`**：前者按空白分割，后者读整行；混合使用时注意缓冲区。
- **`find` vs KMP**：`find` 是朴素匹配，最坏 $O(nm)$；需要线性匹配时用 KMP / Z 函数。
- **`to_string` vs `sprintf`**：`to_string` 更现代、类型安全；`sprintf` 格式控制更强。
- **讲义练习**：循环读入、字符串最值、插入/删除/查找/替换/截取、字符串与数字互转、大小写转换。
