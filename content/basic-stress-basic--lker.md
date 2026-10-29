---
id: basic-stress-basic
title: '对拍（四件套与执行流程）'
category: 实用工具
subcategory: 调试
subSubcategory: 对拍
tags: ["对拍", "stress test", "随机数据", "暴力程序", "调试"]
timeComplexity: '视数据组数与单次运行时间'
spaceComplexity: '视被测程序'
level: A
codePath: '基础算法\对拍\传统四件套\control--lker.cpp'
verified: 2026-10-20
source: 'lker'
---

## 算法原理

对拍是 OI 赛制中常用的一种验证自己程序是否正确的工具，尤其是在样例强度不足的情况下。对拍可以帮助我们找到绝大多数边界条件，并辅助程序调试。

一份对拍程序通常包括下面四个部分：

- 一份我们自己编写的代码 `mine.cpp`；
- 一份我们保证正确的暴力程序 `bf.cpp` 作为参考，和我们编写的正解使用同一份数据进行测试，以判断正解是否正确工作。因此，这里的暴力程序不需要保证复杂度，但一定要保证正确；
- 一份随机数据生成器 `data.cpp`，用来生成大量数据，满足对拍的需要（因为赛事下发的大样例可能比较弱）；
- 一份代码 `control.cpp`，用来自动执行这些代码，并比较它们的输出文件是否一致。

除了 `control.cpp` 之外的另外三个 `.cpp` 文件都采用文件读写。我们先把四个代码文件全部编译一遍，再运行 `control.cpp`。`control.cpp` 会先执行 `data.cpp`，生成一份输入文件 `data.out`；再自动执行 `bf.cpp` 和 `mine.cpp`，生成 `bf.out` 和 `mine.out` 两份输出，并比较它们是否一致。

如果一致，我们就继续对拍；如果不一致，程序会自动退出。此时，我们直接查看 `data.out` 这份输入，看看是哪里写挂了即可。

这里我们主要介绍一下 `control.cpp` 会用到的命令：

```cpp
system(" ")
```

它可以执行引号中的命令。我们会用到下面几种形式：

```cpp
system("./name") 
```

运行一个叫作 `name` 的可执行文件。

```cpp
system("cmp -s bf.out mine.out")
```

在 NOI Linux 环境下，对比 `bf.out` 和 `mine.out` 文件是否一致。一致时返回 `0`，不一致时返回 `1`。

如果在 Windows 环境下，我们会使用 `fc` 命令进行对比：

```cpp
system("fc bf.out mine.out")
```

在 Windows 环境下运行某个文件时，可以使用下面的形式：

```cpp
system("name")
```

直接填入可执行文件的文件名即可。

~~不过考试正式环境下根本不会用到这句吧。~~

### 四件套的执行顺序

1. `data` 写出 `data.out`；
2. `bf` 读 `data.out`，写 `bf.out`；
3. `mine` 读 `data.out`，写 `mine.out`；
4. `control` 比较两份输出：一致就继续下一轮，不一致就停下。

这里以 [P3396 哈希冲突](https://www.luogu.com.cn/problem/P3396) 为例，给出四份代码。

## 逐行代码解析

下面把 `control.cpp` 拆成三块讲，三块按顺序拼起来就是完整程序。

### 头文件与主循环骨架

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./bf");
        system("./mine");
```

- `ti` 记已经跑过的数据组数，同时也用来控制什么时候收工。
- `while(1)` 是死循环——对拍本来就要一直跑到出错为止，退出条件写在循环体内部。
- 三行 `system` 严格按「造数据 → 跑暴力 → 跑正解」的顺序执行；顺序不能反，否则 `mine` 会读到上一轮的 `data.out`。

### 比较与退出

```cpp
        if(system("cmp -s bf.out mine.out"))
        {
            cout<<"WA/RE/MLE on test "<<++ti<<"\n";
            break;
        }
        else cout<<"AC on test"<<++ti<<"\n";
        if(ti==10)//这里的ti是数据组数,你希望拍多少组由你决定
            break;
    }
    return 0;
}
```

- `system("cmp -s ...")` 返回的是命令的**退出码**：文件一致时为 `0`，不一致时为非 `0`。所以写进 `if` 里，「非 0 即出错」正好对应 `if` 为真的分支。
- 出错时先 `++ti` 再打印，编号从 1 开始；随后 `break` 跳出死循环。
- 出错就 `break` 还有一个隐藏好处：`data.out` 不会再被下一轮覆盖，我们可以直接打开它，用这组数据复现问题。
- `ti==10` 是人为设定的轮数上限，想拍多少组改这个数即可。

### 另外三份文件

`mine.cpp`（这里是一份分块预处理的正解）：

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
const int M=505;
int f[M][M];
int a[N];
int main()
{
    freopen("data.out","r",stdin);
    freopen("mine.out","w",stdout);
    int n,m;
    cin>>n>>m;
    for(int i=1;i<=n;i++)
        cin>>a[i];
    int lim=(int)sqrt(n);
    for(int i=1;i<=n;i++)
        for(int j=1;j<=lim;j++)
            f[i%j][j]+=a[i];
    while(m--)
    {
        char cmd;
        cin>>cmd;
        int x,y;
        cin>>x>>y;
        if(cmd=='A')
        {
            if(x<=lim) cout<<f[y][x]<<"\n";
            else{
                int sum=0;
                for(int i=y;i<=n;i+=x)
                    sum+=a[i];
                cout<<sum<<"\n";
            }
        }else{
            for(int j=1;j<=lim;j++)
                f[x%j][j]+=(y-a[x]);
            a[x]=y;
        }
    }
    return 0;
}
```

`bf.cpp`（保证正确、不保证复杂度的暴力）：

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int a[N];
int main()
{
    freopen("data.out","r",stdin);
    freopen("bf.out","w",stdout);
    int n,m;
    cin>>n>>m;
    for(int i=1;i<=n;i++)
        cin>>a[i];
    while(m--)
    {
        char cmd;int x,y;
        cin>>cmd>>x>>y;
        if(cmd=='A')
        {
            int sum=0;
            for(int i=1;i<=n;i++)
                if(i%x==y) sum+=a[i];
            cout<<sum<<"\n";
        }
        else a[x]=y;
    }
    return 0;
}
```

`data.cpp`（随机数据生成器，生成方法见「随机数据生成」几条）：

```cpp
#include<bits/stdc++.h>
#include<unistd.h>
using namespace std;
int main()
{
    freopen("data.out","w",stdout);
    mt19937 rd(getpid());
    int n=rd()%(150000)+1;
    int m=rd()%(150000)+1;
    cout<<n<<" "<<m<<"\n";
    for(int i=1;i<=n;i++)
        cout<<rd()%(1000)+1<<" ";
    cout<<"\n";
    for(int i=1;i<=m;i++)
    {
        char opt=rd()%2?'A':'C';
        if(n==1) opt='C';
        cout<<opt<<" ";
        if(opt=='A')
        {
            int x=rd()%(n-1)+1;//p上界是开区间
            int y=rd()%x;//y下届取0(闭),上界取x(开)
            cout<<x<<" "<<y;
        }
        else{
            int x=rd()%(n)+1;
            int y=rd()%(1000)+1;
            cout<<x<<" "<<y;
        }
        cout<<"\n";
    }
    return 0;
}
```

- 四份程序里只有 `control.cpp` 用标准输入输出，其余三份都用 `freopen` 把读写重定向到文件——这是四个进程互相传递数据的唯一通道。
- `data.cpp` 的 `data.out` 是**输入**文件名，`bf`/`mine` 的 `bf.out`、`mine.out` 是**输出**文件名，三者别写混。

## 复杂度分析

对拍本身没有固定复杂度，开销由「跑了多少组 × 每组三份程序的运行时间」决定，其中暴力程序通常是瓶颈。所以对拍时要把暴力写简单、把数据规模压小，宁可多拍几组小的，也不要一组大到跑不完。

## 适用场景

- 样例太弱、手搓边界又想不到的时候，用对拍批量试探。
- 正解跑得对但心里没底：写一份朴素暴力做参照，让机器替你验证。
- 赛前自测：把常错题型（区间、取模、多测、图论边界）都挂上对拍。
- 不适合：题目本身有 SPJ / 交互 / 多解（见「精度误差与 SPJ 对拍」「交互题对拍」两条），以及暴力都无法在可接受时间内跑完的题。

## 常见陷阱

- **Windows 与 Linux 的命令不一样**：Linux 下是 `system("./data")`、`cmp -s`，Windows 下要写 `system("data")`、`system("fc bf.out mine.out")`。交题环境是 NOI Linux，本地是 Windows 的话两边要分开写。
- **`cmp` 的返回值**：一致返回 `0`，非 0 才是出错。写成 `if(!system(...))` 就正好反了。
- **忘记 `freopen` 或文件名写错**：四个进程会读到空文件，于是「永远 AC」，对拍完全失效。
- **暴力程序本身写错**：暴力和正解一起错，对拍永远发现不了。暴力要尽量直白，宁可慢。
- **数据范围造错**：比如本题的 `p` 上界是开区间、`y` 的取值是 `[0,x)`，`data.cpp` 里若造出越界数据，两边都可能 UB，比出来的结果没有意义。
- **出错后不要继续跑**：一旦 `break` 才保住出错的 `data.out`；如果循环不退出，现场就被下一轮覆盖了。
- `#include<unistd.h>` 与 `getpid()` 是 Linux 专有；在 Windows 下编译会直接报错，需要换种子。

## 对比与扩展

- 四件套的另一种组织方式是用 shell 脚本 / `bat` 脚本串起来，省掉写 `control.cpp` 的功夫，本质和本文一样。
- 如果想对拍「多测 + 大数据」，可以给 `data.cpp` 加一个从命令行读规模参数的功能，先拍小数据找错，再放大数据卡常。
- 对拍只能告诉你「这组数据答案不一样」，不能告诉你「谁错了」。定位仍然要靠单步调试或把 `data.out` 手动喂给两份程序。
