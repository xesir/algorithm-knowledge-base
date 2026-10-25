---
id: prob-qbxt-multiple
title: '倍数很爽'
oj: 'QBXT 国庆集训模拟赛'
problemId: '-'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 数学
tags: ["数论", "中国剩余定理", "exgcd", "构造", "分类讨论"]
timeComplexity: 'O(n² log A)'
spaceComplexity: 'O(n)'
codePath: '题目专辑\数学\倍数很爽\代码--xesir.cpp'
level: A
verified: 2026-10-20
source: 'Xesir'
---

## 题目描述

给定长为 $n$ 的正整数序列 $a_i$。

你需要找到 $1\le i<j<k\le n$ 满足：

存在 $1\le L\le 10^{18}$，使得对于所有满足 $L\le w\le L+4$ 的 $w$，其为 $a_i,a_j,a_k$ 中其中至少一者的倍数。

给出符合条件的 $i,j,k,L$ 或报告无解。

### 输入格式

第一行一个正整数 $n$。

接下来一行 $n$ 个正整数，第 $i$ 个表示 $a_i$。

### 输出格式

如果无解，仅输出一行 `NO`。

否则在第一行输出 `YES`。

接下来一行三个整数，分别表示 $i,j,k$。

接下来一行一个整数，表示 $L$。你给出的 $L$ 需要保证 $1\le L\le 10^{18}$。

### 数据范围

测试数据满足 $1\le n\le 10^3$，$1\le a_i\le 10^9$。

| 子任务编号 | 特殊性质 | 分值 |
| :---: | :--- | :---: |
| $1$ | $n\le 5$，$a_i\le 10$ | $5$ |
| $2$ | $a_1=2$ | $10$ |
| $3$ | $a_1=3$ | $15$ |
| $4$ | $1\le a_i\le 10^6$ | $50$ |
| $5$ | 无特殊性质 | $20$ |

## 样例

### 样例 1

**输入：**

```
5
2 3 4 5 6
```

**输出：**

```
YES
1 2 4
2
```

**解释：**

$a_1=2,\;a_2=3,\;a_4=5$，区间是 $[2,6]$。其中 $2,4,6$ 是 $2$ 的倍数，$3$ 是 $3$ 的倍数，$5$ 是 $5$ 的倍数，五个数全被覆盖。

### 样例 2

**输入：**

```
5
11 45 14 19198 10
```

**输出：**

```
NO
```

## 解题思路

### 把问题翻译成「用 3 个数覆盖 5 个连续整数」

题目要求的东西，等价于：

- 挑三个数；
- 一个数 $d$ 能「覆盖」区间内的某些位置，指的是这些位置是 $d$ 的倍数；
- 要求 $[L,L+4]$ 这 $5$ 个位置全部被覆盖。

换句话说是「三个数的倍数集合，能否盖住长度 $5$ 的窗口」。

### 大于 $4$ 的数最多只能覆盖 $1$ 个位置

若 $d\ge 5$，它在长度为 $5$ 的区间里最多出现一次（相邻两个倍数至少差 $5$，正好等于窗长时也可能只落一个）。三个这样的数最多覆盖 $3$ 个位置，必然漏掉 $2$ 个。

所以：**只要三个数全都 $\ge 5$，一定无解。**

### $3$ 和 $4$ 最多覆盖 $2$ 个位置，且必然留漏洞

- $d=3$：窗口内要么出现 $2$ 次（如 $L,L+3$，或 $L+1,L+4$），要么 $1$ 次；
- $d=4$：同理，$2$ 次的形态是 $L,L+4$ 或 $L+1$，或 $L+2$ 之类，总之最多 $2$ 次。

三个数总共最多覆盖 $2+2+2=6\ge 5$，看似有戏，但仔细看覆盖形态：

以 $d=3$ 覆盖 $L,L+3$ 为例，剩下 $L+1,L+2,L+4$。其中 $L+1$ 与 $L+2$ 是**连续整数**，互质，不可能被同一个数同时整除，所以至少要用两个不同的数去补，加上已经用掉的一个，正好三个——可 $L+4$ 还需要被覆盖，而它和 $L+1$ 相差 $3$、和 $L+2$ 相差 $2$，与「补两个连续数」的要求冲突。

$d=4$ 的情形同理：它留下的空位里总包含两个连续整数，而剩下的两个数既要覆盖这两个连续数、还要顺带覆盖第五个位置，做不到。

所以：**三个数全都 $\ge 3$ 也无解。**

### 结论

答案必须包含 $1$ 或 $2$：

- 含 $1$：$1$ 整除一切，直接全覆盖；
- 只含 $2$（不含 $1$）：$2$ 只能覆盖偶数位置，奇数位置要靠另外两个数。

这也解释了为什么子任务 $2,3$ 直接给了 $a_1=2$、$a_1=3$ 两档——它们正好卡在「有解 / 无解」的分界上。

### 含 $1$ 的构造

$1$ 出现在位置 $p$，那么 $L=1$ 即可。另外两个下标只要不重复、顺序合法就行，代码取了 $p$ 附近连续三个位置，越界时改取 $p-2,p-1,p$。

### 只含 $2$ 的构造：三条同余式

$2$ 能覆盖的是偶数位置。取 $L$ 为偶数，则 $L,L+2,L+4$ 都是 $2$ 的倍数，剩下 $L+1$ 和 $L+3$ 两个奇数需要被另外两个数整除。

设这两个数是 $a_i,a_j$（都必须是奇数，因为奇数位置不可能被偶数整除）。写成同余式：

$$L\equiv 0 \pmod 2,\qquad L\equiv -1 \pmod {a_i},\qquad L\equiv -3 \pmod {a_j}$$

前两条合并起来有解的条件是 $\gcd(a_i,a_j)\mid(-1)-(-3)=2$。而 $a_i,a_j$ 都是奇数，$\gcd$ 也是奇数，因此只能 $\gcd(a_i,a_j)=1$——**这就是为什么代码要枚举「互质的两个奇数」**。

### 代码里的变量替换：对 $L+1$ 解 CRT

直接对 $L$ 写同余式会让常数项是 $-1,-3$，不便处理。令 $x=L+1$，三条式子变成

$$x\equiv 1 \pmod 2,\qquad x\equiv 0 \pmod {a_i},\qquad x\equiv -2 \pmod {a_j}$$

这样第一项是 $0$、第二项是 $-2$、第三项是 $1$，正好对应代码里 `cys[]={0,-2,1}`、`cyn[]={a_i,a_j,2}` 的填法，最后把 CRT 解出的 $x$ 减 $1$ 就得到 $L$。

### 复杂度

枚举一对互质奇数 $O(n^2)$，每次跑一遍三元 CRT（$O(\log A)$ 级别的扩展欧几里得），总复杂度 $O(n^2\log A)$。$n\le 10^3$ 完全可以接受。

## 逐行代码解析

### 头文件与全局数组：为什么用 `__int128`

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int __int128
typedef __int128 ll;
const int N=1e3+10,INF=1000000000000000000LL;
int n;int a[N],cys[]={0,0,-2,1},cyn[]={0,0,0,2};
```

- `#define int __int128` 把全局的 `int` 换成 128 位整数。原因是 CRT 里的模数乘积 $M=a_i\cdot a_j\cdot 2$ 最大可达 $2\times10^{18}$，而中间还要做 `ai*Mi` 这种两个 $10^{18}$ 量级的乘法，`long long` 会溢出。
- `INF=1e18` 是题目要求的 $L$ 上界，用来筛掉过大的解。
- `cys` 是常数组（方程右端），`cyn` 是模数数组，下标从 $1$ 开始，第 $0$ 位只是占位。

### 欧几里得与逆元

```cpp
ll gcdo(ll a, ll b) {
    while (b != 0) {
        ll temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
ll exgcd(ll a, ll b, ll &x, ll &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    ll d = exgcd(b, a % b, y, x);
    y -= (a / b) * x;
    return d;
}
ll inv(ll a, ll m) {
    ll x, y;
    ll d = exgcd(a, m, x, y);
    if (d != 1) return -1;
    return (x % m + m) % m;
}
```

- `gcdo` 是迭代版 $\gcd$，用来判断两个奇数是否互质。
- `exgcd` 是递归版扩展欧几里得，注意它先把参数写成 `(y, x)` 再回代 `y -= (a/b)*x`，这是省略临时变量的常见写法。
- `inv` 求模逆：只有在 $\gcd(a,m)=1$ 时逆元才存在，所以不互质时返回 `-1`。`(x % m + m) % m` 是把可能为负的解搬到 $[0,m)$。

### 三元 CRT

```cpp
ll crt(ll a[], ll m[], ll k) {
    ll M = 1, res = 0;
    for(int i=1;i<=k;i++) a[i]=(a[i]%m[i]+m[i])%m[i];
    for (ll i = 1; i <= k; i++) M *= m[i];
    for (ll i = 1; i <= k; i++) {
        ll mi = m[i], ai = a[i];
        ll Mi = M / mi;
        ll invMi = inv(Mi,mi);
        res = (res + ai * Mi % M * invMi % M) % M;
    }
    res=(res%M+M)%M;
    return res;
}
```

- 第一个循环把常数项统一成非负，避免负数取模的坑。
- `M` 是所有模数乘积，`Mi=M/mi`，`invMi` 是 $M_i$ 在模 $m_i$ 下的逆元。
- 每一项贡献 $a_i\cdot M_i\cdot M_i^{-1}$，累加后对 $M$ 取模，得到最小非负解。
- 注意 `ai * Mi % M * invMi % M` 的运算顺序：每步都先取模，才不至于连 `__int128` 也扛不住。

### 快读快写与主函数开头

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
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
```

- `read` 用 `(x<<1)+(x<<3)` 代替 `x*10`，`ch^48` 代替 `ch-'0'`，是常见的读入加速写法；这里的 `int` 已被宏替换成 `__int128`，所以能直接读大数。
- `write` 递归输出每一位，`x` 为 `__int128` 时同样适用。
- 因为用了 `freopen` 绑定文件，`cin/cout` 的同步开关注释掉也无所谓——但代码里仍然用 `cout` 输出 `YES/NO`，二者混用是安全的（都在同一套标准流上）。

```cpp
signed main(){
	freopen("multiple.in","r",stdin);
	freopen("multiple.out","w",stdout);
	//ios::sync_with_stdio(0);
	//cin.tie(0);cout.tie(0);
	n=read();int mi=LLONG_MAX,mic=0;
	if(n<3){
		cout<<"NO\n";return 0;
	}
	for(int i=1;i<=n;i++) a[i]=read();
```

- `signed main` 是因为前面 `#define int __int128`，真正的 `main` 必须显式写 `signed`。
- `freopen` 是模拟赛的文件读写要求。
- `n<3` 直接无解：选不出三个不同的下标。
- `mi` 记录最小值、`mic` 记录它第一次出现的位置——后面「只含 $2$」的分支要用这个位置来排输出顺序。

### 含 $1$ 的分支

```cpp
	for(int i=1;i<=n;i++){
		if(a[i]==1){
			cout<<"YES\n";
			if(n==3) cout<<"1 2 3\n1";
			else if(i+2>n){
				write(i-2);putchar(' ');write(i-1);putchar(' ');write(i);putchar('\n');write(1);
			}
			else{
				//cout<<i<<" "<<i+1<<" "<<i+2<<"\n"<<1;
				write(i);putchar(' ');write(i+1);putchar(' ');write(i+2);putchar('\n');write(1);
			}
			return 0;
		}
		if(mi>a[i]) mi=a[i],mic=i;
	}
```

- 找到 $1$ 就直接输出，$L=1$（$1$ 整除任何整数）。
- 另外两个下标取 $i,i+1,i+2$；如果 $i+2$ 越界，改取 $i-2,i-1,i$。
- `n==3` 时只有一个选择，单独处理。
- 注意这个循环顺带维护了 `mi/mic`，所以「含 $1$」的检查与「求最小值」合并成了一趟。

### 只含 $2$ 的分支：枚举互质奇数对

```cpp
	if(mi>2){
		cout<<"NO\n";return 0;
	}
	for(int i=1;i<=n;i++){
		for(int j=1;j<=n;j++){
			if(a[i]%2==1&&a[j]%2==1&&gcdo(a[i],a[j])==1){
				cyn[1]=a[i],cyn[2]=a[j];cyn[3]=2;
				cys[1]=0;cys[2]=-2;cys[3]=1;
				int u=crt(cys,cyn,3);u--;
				if(u>INF) continue;
```

- `mi>2` 说明最小元素都超过 $2$，前面已经证明无解。
- 双重循环枚举所有有序对 $(i,j)$，要求都是奇数且互质。
- 填入三条同余式：$x\equiv0\pmod{a_i}$、$x\equiv-2\pmod{a_j}$、$x\equiv1\pmod2$。
- `u = crt(...) - 1` 得到 $L$；`u > INF` 时这个解超过 $10^{18}$，换下一对（同一个同余类里更大的解只会更大，所以这一对彻底没戏）。

### 输出三个下标：保证递增

```cpp
				cout<<"YES\n";
				if(j>i) swap(i,j);
				//write(i-2);putchar(' ');write(i-1);putchar(' ');write(i);putchar('\n');write(1);
				if(mic<j){
					//cout<<mic<<" "<<j<<" "<<i<<"\n"<<u;
					write(mic);putchar(' ');write(j);putchar(' ');write(i);putchar('\n');write(u);
				}
				else if(mic<i){
					//cout<<j<<" "<<mic<<" "<<i<<"\n"<<u;
					write(j);putchar(' ');write(mic);putchar(' ');write(i);putchar('\n');write(u);
				}
				else{
					//cout<<j<<" "<<i<<" "<<mic<<"\n"<<u;
					write(j);putchar(' ');write(i);putchar(' ');write(mic);putchar('\n');write(u);
				}
				return 0;
```

- 先 `swap` 让 $i>j$，此时三个候选位置是 $\text{mic},j,i$，只有一个大小关系未知。
- 三个分支分别处理 $\text{mic}<j$、$j\le\text{mic}<i$、$\text{mic}\ge i$，保证输出严格递增。
- 找到第一组合法解就 `return 0`，后面的不用再枚举。

## 复杂度分析

枚举互质对是 $O(n^2)$，每对做一次三元 CRT，扩展欧几里得是 $O(\log A)$，总计 $O(n^2\log A)$。$n\le10^3$ 时约 $10^6$ 次 CRT，可以过。空间只有几个长度 $10^3$ 的数组，$O(n)$。

## 常见陷阱与注意事项

- **必须开 `__int128`**：$M$ 可达 $2\times10^{18}$，中间乘积 $a_iM_i$ 到 $10^{36}$，`long long` 会静默溢出。
- **`signed main`**：`#define int __int128` 后 `main` 必须写成 `signed`。
- **只含 $2$ 时要求两个数互质**：$\gcd(a_i,a_j)\mid2$ 且两者都奇，所以 $\gcd$ 只能为 $1$；漏判会解出伪解。
- **$L\ge 1$**：代码只检查了上界 `u>INF`，若 CRT 解出 $u=0$ 则 $L=0$ 不合法（本题实际不会触发，因为含 $1$ 的分支已经提前返回）。
- **下标的顺序**：三个下标必须严格递增，`swap` 加三个分支就是为这一点服务的。
- **`freopen` 的文件名**：交题时要按题目要求改成对应文件名。

## 对比与扩展

- 与「P1450 硬币购物」的关系：那道题用容斥处理上限，本题用 CRT 拼条件，都是把「多个同余 / 约束」合成一个解。
- 核心结论「只有 $1,2$ 有用」来自覆盖能力分析，这类「先排除大部分情况、再对剩下的小情况精确处理」是构造题常见套路。
- 若 $n$ 放大到 $10^5$，$O(n^2)$ 的枚举就不行了，需要按奇偶把数分成两类，再用哈希或桶去匹配互质对。
