---
id: basic-template-header
title: '自用头文件'
category: 基础算法
subcategory: 实用工具
subSubcategory: ''
tags: ["模板", "头文件", "快读", "快写", "宏定义"]
timeComplexity: '视具体实现'
spaceComplexity: '视具体实现'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

~~！？史子合并？！~~

这就是一份「自用竞赛模板」：把每次写题都要敲的开头攒成一块，比赛时复制粘贴，省下敲 `#include` 和快读快写的功夫。

它干的事主要有三件：

- 用**万能头** `bits/stdc++.h` 一口气把常用 STL 全包进来；
- 用一批**宏定义**给常用写法起短名字（`fi` / `se` / `pb` / `lowbit` 等），并且用 `#define int long long` 从源头堵住爆 `int` 的坑；
- 配上一套**快读 `read` / 快写 `write`**，在数据量大、`cin`/`cout` 顶不住的时候救场。

下面的代码原样取自源笔记，分模块拆开讲解。

## 逐行代码解析

### 宏定义块

```cpp
#include<bits/stdc++.h>
#define endl '\n'//交互题去掉
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
#define pb push_back
#define vi vector<int>
//#define v2 vector<vector<int>>
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
//const int N=1e5+10;
//int cnt=0;
//int a[N];
inline int read();
inline void write(int x);
```

- `#include<bits/stdc++.h>`：万能头，把 STL 全家桶一次引入。
- `#define endl '\n'`：`endl` 会顺带 flush，换成 `'\n'` 能快不少；**但交互题必须去掉**（交互要靠 flush 把输出推给对方）。
- `#define fi first` / `#define se second`：少打几个字符。
- `#define lowbit(x) (x&(-x))`：树状数组的低位提取惯用写法。
- `#define int long long`：把 `int` 全局替换成 `long long`，防溢出神器；代价是常数和内存都会涨，**有被卡的风险**，而且从此 `main` 得写成 `signed main()`。
- `#define pb push_back` / `#define vi vector<int>`：常用容器 / 操作缩写。
- 注释里的 `v2`、`N`、`cnt`、`a[N]` 是留着的备用声明，用不到就保持注释。
- 最后两行是对 `read` / `write` 的**前置声明**，让 `main` 里能直接调用（定义都写在后面）。

### 主函数 main

```cpp
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
	//int n;cin>>n;
    return 0;
}
```

- `signed main()`：因为上面 `int` 被替换成了 `long long`，标准要求的 `int main` 得显式写成 `signed main()`，否则报错。
- 注释里的 `freopen` 是本地读文件调试用，**提交前记得保持注释状态**。
- `ios::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr);`：解除 `cin`/`cout` 与 C 标准 IO 的同步，加速输入输出。
- `return 0;`：正常结束。

### 快读 read

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
```

- `int x=0,f=1;`：`x` 存数值，`f` 存符号。
- 第一个 `while`：跳过所有非数字字符，遇到 `-` 记下负号。
- 第二个 `while`：逐位累加，`(x<<1)+(x<<3)` 就是 `x*10`，`ch^48` 等价于 `ch-'0'` 把字符转成数字。
- `return x*f;`：带上符号返回。
- `inline` 提示编译器内联，减少函数调用开销。

### 快写 write

```cpp
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- 开头先处理负数：打一个 `-`，再取相反数。
- `if(x>9) write(x/10);`：递归处理高位，再打当前最低位，这样数字就是**正序**输出。
- `putchar(x%10+'0');`：把最低位数字转回字符输出。
- 注意 `write` 只支持整数，输出完不会自动换行，需要换行得自己补。

## 复杂度分析

各部分与「你的程序内容」无关，本身复杂度都很低：

- **快读 `read`**：与读入的字符数成正比，设一次读入的数字有 $d$ 位，则为 $O(d)$。
- **快写 `write`**：按位递归输出，位数 $d$，递归深度 $O(d)$，总时间 $O(d)$。
- **宏定义 / `main`**：均为 $O(1)$。
- 整体不改变算法复杂度，因此本知识点标注为**视具体实现**。

## 适用场景

- **竞赛一键模板**：比赛时复制粘贴，省去反复敲开头。
- **卡常 / 大数据量输入**：`cin`/`cout` 太慢时，改用这套快读快写。
- **防溢出**：`#define int long long` 让所有 `int` 都变大，省得逐个改。

## 常见陷阱与注意事项

1. **`#define int long long` 之后必须写 `signed main()`**：直接写 `int main()` 会报错；同时常数和内存都会变大，别在卡常题上无脑开。
2. **`#define endl '\n'` 交互题要去掉**：交互题依赖 flush，换成 `'\n'` 会导致输出没及时推给对方。
3. **解除同步后别混用两种 IO**：`ios::sync_with_stdio(false)` 之后再用 `scanf`/`printf` 与 `cin`/`cout` 混读混写会出问题；要用快读快写就统一用。
4. **`freopen` 提交前务必备注**：留着重定向会读不到标准输入、直接 RE/WA。
5. **`write` 不自动换行、只吃整数**：需要换行要自己补 `putchar('\n')`。
6. **末尾输出别忘 flush**：程序正常结束会自动 flush，但如果中途用 `_exit` 之类强退要注意。

## 对比与扩展

| 输入输出方式 | 写法 | 速度 | 备注 |
|---|---|---|---|
| `cin` / `cout` | 最简单 | 慢（解除同步后中等） | 代码短，适合小数据 |
| `scanf` / `printf` | 格式化 | 较快 | C 风格，格式符要小心 |
| `getchar` 快读 / `putchar` 快写 | 如上模板 | 快 | 数据量大时首选 |
| `fread` 整块读入 | 手写缓冲区 | 最快 | 代码更长，题解模板常见 |

扩展方向：把 `read` 重载成支持 `long long` / `double` / 字符串，或改用 `fread` 版本进一步提速；宏那部分也可以按个人习惯增删。若要参考同作者的自动机 / 字符串模板，可对照相关知识点。
