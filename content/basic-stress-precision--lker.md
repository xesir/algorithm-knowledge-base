---
id: basic-stress-precision
title: '对拍（浮点误差与精度比较）'
category: 基础算法
subcategory: 对拍
subSubcategory: ''
tags: ["对拍", "浮点误差", "eps", "cin.clear", "SPJ"]
timeComplexity: '视数据组数与单次运行时间'
spaceComplexity: '视被测程序'
level: A
codePath: '基础算法\对拍\精度误差对拍\control--lker.cpp'
verified: 2026-10-20
source: 'lker'
---

## 算法原理

`system` 语句是逐字比较。在面对允许精度误差或者带有 SPJ 的题目时，我们不能再让 `cmp` / `fc` 去比文件，而要在 `control.cpp` 里自己把两个答案读进来，按误差阈值判断。

关键是从两份输出里分别读入数据：先 `freopen` 重定向到 `bf.out`，读入并记录答案；再重定向到 `mine.out`，读入并记录答案，最后比较。

但是，重定向后 `cin` 中可能会残留一些状态，因此每次读入后都要清空，防止出现错误读取：

```cpp
cin.clear()
```

这里以 [P1429 平面最近点对（加强版）](https://www.luogu.com.cn/problem/P1429) 为例。答案是实数，输出允许一定误差，所以把控制器的比较从「文件逐字相等」换成「差值不超过 `eps`」。

### 控制器怎么改成数值比较

1. 前三条 `system` 和普通对拍完全一样，照旧造数据、跑暴力、跑正解；
2. 用 `freopen("bf.out","r",stdin)` 把标准输入指向暴力输出，`cin>>bf` 读回答案，读完后 `cin.clear()`；
3. 再把标准输入指向 `mine.out`，同样读回 `mn` 并 `cin.clear()`；
4. 判断 `fabs(mn-bf)>eps`：超差就当出错，否则继续。

## 逐行代码解析

### 阈值与主循环

```cpp
#include<bits/stdc++.h>
using namespace std;
#define eps 1e-3
int main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./bf");
        system("./mine");
```

- `eps` 是「我们能接受的精度阈值」，本例取 $1\times10^{-3}$。题目若要求保留 4 位小数，通常取 `1e-3` ~ `1e-6` 都合理；取得太小会把浮点误差当错误，取得太大又会放过真错。
- 前三条 `system` 与普通对拍一致，顺序仍是「造数据 → 暴力 → 正解」。

### 从两份输出里读答案

```cpp
        double bf,mn;
        freopen("bf.out","r",stdin);
        cin>>bf;
        cin.clear();
        freopen("mine.out","r",stdin);
        cin>>mn;
        cin.clear();
```

- `freopen` 可以反复调用，把 `stdin` 重新指向另一个文件，这样就不用开 `ifstream`，直接 `cin` 即可。
- 第一次读完后如果不清状态，`cin` 可能还带着读到文件尾的 `eofbit` / `failbit`，第二次读就会直接失败、`mn` 保持初值。所以 `cin.clear()` 是**必需**的，不是可选项。
- 两份答案分别存在 `bf`、`mn` 里，变量名故意和文件名呼应，读代码时不容易串。

### 比较与退出

```cpp
        if(fabs(mn-bf)>eps)
        {
            cout<<"WA/RE/MLE on test "<<++ti<<"\n";
            break;
        }
        else cout<<"AC on test"<<++ti<<"\n";
        if(ti==10)
            break;
    }
    return 0;
}
```

- 用 `fabs(mn-bf)>eps` 而不是 `mn!=bf`：浮点数几乎不可能逐位相等，直接比会 100% 误报。
- 出错即 `break`，保住这一轮的 `data.out`；`ti==10` 是轮数上限，按需修改。
- 如果答案有多个数（比如输出 $k$ 个实数），就循环读 $k$ 次、逐个比，或者把整行读成字符串再自己解析。

### 配套的暴力与数据

`bf.cpp` 的核心就是把所有点对两两枚举（保证正确，不保证复杂度）：

```cpp
    db mn=(db)1e20;
    for(int i=1;i<=n;i++)
        for(int j=1;j<=n;j++)
            if(i!=j&&sgn(dis(i,j)-mn)<0)
                mn=dis(i,j);
    mn=sqrt(mn);
    printf("%.4lf",mn);
```

`data.cpp` 生成 $n$ 个坐标在 $[0,10^9]$ 内的点：

```cpp
    mt19937 rd(getpid());
    int n=rd()%(200000-1)+2;
    cout<<n<<"\n";
    for(int i=1;i<=n;i++)
    {
        int x=rd()%(N+1);
        int y=rd()%(N+1);
        cout<<x<<" "<<y<<"\n";
    }
```

- 暴力和正解都用 `freopen` 固定读写 `data.out` / `bf.out` / `mine.out`，与控制器约定一致。
- `sgn` 判号是为了避免浮点误差导致的「差一点点却判成更小」，两边的 `sgn` 写法要一致。

## 复杂度分析

对拍开销由「组数 × 每组三份程序的运行时间」决定。本例暴力是 $O(n^2)$，所以 `data.cpp` 把 $n$ 控制在 $2\times10^5$ 以内仍然偏大——真正跑对拍时可以把上界调小到几千，换取更多组数。

## 适用场景

- 答案是实数、题目允许相对/绝对误差的题（几何、概率、数值计算）。
- 多解题只要求输出任意一组合法方案的题（此时不能比数值，要写 checker，见「SPJ 与构造题对拍」）。
- 输出带行末空格、换行差异导致 `cmp` 误报的题。

## 常见陷阱

- **忘记 `cin.clear()`**：第二次读入直接失败，`mn` 保持未初始化值，于是「每次都 WA」或「每次都 AC」，对拍完全失真。
- **`eps` 取错**：取 $10^{-8}$ 时浮点误差会频繁误报；取 $10^{-1}$ 时真错误会被放过。一般取「题目要求精度」的 1~10 倍。
- **相对误差题写成绝对误差**：答案本身很大时（如 $10^9$ 量级），绝对误差阈值几乎必然误报，应按题目要求写成 $\dfrac{|a-b|}{\max(1,|b|)}$ 形式的相对误差。
- **两份程序输出格式不同**：一个输出 `1.2345`、另一个输出 `1.234500`，用 `cin` 读成 `double` 后再比才不会误伤。
- **`freopen` 后还在用 `cout`**：控制器自己的输出会被写进被重定向的文件里，注意别把调试输出混进 `bf.out`。

## 对比与扩展

- 普通整数题直接用 `cmp` / `fc` 比文件更省事，只有在「答案不唯一 / 允许误差」时才需要把比较搬进 `control.cpp`。
- 如果输出是一整张矩阵，可以逐元素读入比较，并在出错时把第一处不同的下标打印出来，定位会快很多。
- 与「SPJ 与构造题对拍」的区别：那里比的是**方案合法性**，这里比的是**数值接近程度**。
