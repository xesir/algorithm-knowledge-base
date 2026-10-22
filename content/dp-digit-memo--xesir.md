---
id: dp-digit-memo
title: '数位 DP — 按位填数与记忆化搜索'
category: 动态规划
subcategory: 数位DP
subSubcategory: ''
tags: ["数位DP", "记忆化搜索", "按位枚举", "区间转前缀", "前导零", "windy数", "手机号码"]
timeComplexity: 'O(len·状态数·10)'
spaceComplexity: 'O(len·状态数)'
level: A
codePath: '动态规划\数位DP记忆化搜索\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

数位 DP 是一类专门处理**与数字的每一位有关**的计数 / 最值问题的算法。它的套路极其固定，一旦你理解了「按位枚举 + 记忆化搜索」的框架，再花里胡哨的限制也不过是往状态里加几个维度的事。

### 核心思想：区间转前缀

数位 DP 通常解决「$[L, R]$ 中有多少个数满足某个性质」这样的问题。我们不会直接统计区间，而是定义函数 `solve(x)` 表示 $[0, x]$ 中满足条件的个数，然后答案就是：

$$
\text{ans} = \text{solve}(R) - \text{solve}(L-1)
$$

所以任务就变成：给定一个上界 `x`，统计从 `0` 到 `x` 的所有整数中有多少个符合条件。

### 通用框架：记忆化搜索按位填数

我们从最高位（通常是十进制最高位）开始，一位一位地填数字。搜索过程中需要维护几个**通用的状态**：

- `pos`：当前处理到第几位（从高位往低位，或从低往高，常见从高位）。
- `tight`（或 `limit`）：布尔值，表示此前填的数字是否已经**贴住了上界**。如果 `tight=true`，则当前位最大只能填上界的对应位；否则可以填 `0~9`。
- `started`（或 `leadZero`）：布尔值，表示是否已经开始填写**非前导零**的数字。因为数字可以有不同长度，前导零不参与某些限制（如相邻数字差的限制、数字出现次数的统计等）。
- 其他状态视题目而定。

**关键点**：

- **记忆化的条件**：只有当 `!tight && !started` 时才缓存结果。
- **前导零的处理**：如果 `started=false` 且继续填 0，通常不更新「上一个数字」等状态，否则会错误地把前导零当成普通数字。直到第一次填非零数字，才真正「开始」一个数。

### 常见附加状态

除了 `pos, tight, started`，每道题还会加入一些特定的限制信息：

- **上一个数字**：用于处理相邻数字差、连续相同等。
- **连续相同长度**：如要求至少出现三个相邻相同数字。
- **数字出现情况**：如是否出现过 4 或 8，某些数字的个数。
- **模数余数**：如果要求数字能被某个数整除，维护当前已填数字构成的数模某个数的余数。
- **自动机状态**：如果限制了不能出现某个子串（如「13」），可以将已填的后缀压成 AC 自动机节点。

**原则**：状态维度要尽量少，但必须保证未来决策所需的信息完整。如果少了某个信息，不同历史会导致不同的合法后继，那就必须加进来。

## 核心公式 / 状态定义与转移方程

**状态定义**：一个状态由「当前位 `pos`」加上若干限制维度组成，通用部分为 `(pos, tight, started)`（或等价的 `is_limited` / `is_leading_zero`），再加题目特有的维度。

**转移**：在当前位置枚举可填数字 `i`（`0 ~ upper_bound`）：

$$
\text{upper\_bound} = \begin{cases} \text{digits}[pos], & \text{tight} = \text{true} \\ 9, & \text{tight} = \text{false} \end{cases}
$$

$$
\text{ans} = \sum_{i=0}^{\text{upper\_bound}} \text{dfs}(pos-1,\ \ldots,\ \text{new\_tight},\ \text{new\_started})
$$

其中 `new_tight = tight && (i == digits[pos])`，`new_started = started || (i != 0)`。

**记忆化条件**：仅当 `!tight && !started` 时把 `ans` 存入 `dp`，因为带上界的路径只走一次、复用率低。

## 逐行代码解析

下面把整章涉及的代码按顺序拆开讲。

### 模块一：通用框架模板

```cpp
int digits; // 存储 N 的各位数字
long long dp[...]; // 记忆化数组，维度根据状态而定
// dfs 函数
long long dfs(int pos, ..., bool is_limited, bool is_leading_zero) {
	// 1. 递归基：所有位都填完了
	if (pos == 0) return 1; // 或其他基本情况
	// 2. 记忆化：在特定条件下查表
	if (!is_limited && !is_leading_zero && dp[pos][...] != -1) {
		return dp[pos][...];
	}
	long long ans = 0;
	int upper_bound = is_limited ? digits[pos] : 9; // 确定当前位的上限
	// 3. 循环遍历当前位可以填的数字
	for (int i = 0; i <= upper_bound; ++i) {
		// ... 检查 i 是否合法 ...
		ans += dfs(pos - 1, ..., new_is_limited, 		new_is_leading_zero);
	}
	// 4. 记录状态
	if (!is_limited && !is_leading_zero) {
		dp[pos][...] = ans;
	}
	return ans;
}
long long solve(long long n) {
	if (n < 0) return 0;
	if (n == 0) return 1; // 0 是一个满足条件的数（如果题目允许）
	// 1. 将 n 转换为数位数组
	int len = 0;
	while (n > 0) {
		digits[++len] = n % 10;
		n /= 10;
	}
	// 2. 初始化 DP 数组
	memset(dp, -1, sizeof(dp));
	// 3. 从最高位开始 DFS
	// 注意：digits 数组是反的，所以从 len 开始
	return dfs(len, ..., true, true);
}
// 主程序入口
long long result = solve(R) - solve(L - 1);
```

- 递归基 `pos == 0` 时返回 1，表示这条路径填出了「一个合法数字」。
- 记忆化前先查表，`!is_limited && !is_leading_zero` 才查 / 存，避免把与上界绑定的状态缓存下来。
- `digits` 通过 `n % 10` 从低位到高位填，所以 `digits[1]` 是最低位，`solve` 里要从 `len`（最高位）开始 DFS。
- 这就是「模板」：真正的题目只需替换成自己的状态维度和合法性检查。

### 模块二：例题一 windy 数

> **题意**：不含前导零且相邻两个数字之差至少为 2 的正整数称为 windy 数，统计区间 $[a,b]$ 内的 windy 数个数。$a,b \le 10^{18}$。

**状态设计**：

- `pos`：当前处理到第几位（从高位到低位）。
- `tight`：是否贴住上界。
- `last`：上一位填的数字（0~9），用于判断相邻差。
- `started`：是否已经开始（前导零判断）。

**转移**：在当前位置尝试填数字 `d`（`0~lim`）。

- 如果 `started=false` 且 `d=0`，则仍未开始，`last` 保持为某个不影响判断的值（例如 0，但要小心别和真实数字 0 混淆，可在转移时特判）。
- 如果 `started=true` 或 `d!=0`，则检查 `abs(d - last) >= 2`（若是第一个非零数字，无需检查，因为前面没有数字）。
- 更新 `nstarted = started || (d != 0)`，`nlast = d`（仅当 `nstarted` 为真才更新）。

**递归基**：填完所有位后返回 1（只要每一步都合法，就算一个）。**记忆化**：对 `pos, last, started` 缓存。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[30][2][30][2],N[30];
int dqw;
int dfs(int w,int is_limited,int qianyiwei,int qdz){
    if(dp[w][is_limited][qianyiwei][qdz]!=-1) return dp[w][is_limited][qianyiwei][qdz];
    if(w==dqw+1) return 1;
    dp[w][is_limited][qianyiwei][qdz]=0;
    for(int i=0;i<10;i++){
        if(abs(qianyiwei-i)<2&&qdz!=1) continue;
        if(is_limited&&i>N[w]) continue;
        dp[w][is_limited][qianyiwei][qdz]+=dfs(w+1,is_limited&&(i==N[w]),i,qdz&&(i==0));
    }
    return dp[w][is_limited][qianyiwei][qdz];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	 for(int i=0;i<x.size();i++){
	           N[i+1]=x[i]-48;
	       }
	 dqw=x.size();
	 return dfs(1,1,0,1);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
	cout<<solve(r)-solve(l);
}
```

- `qianyiwei` 就是 `last`（上一位数字），`qdz` 是 `started` 的反向标记：`qdz=1` 表示「还在前导零阶段」，`qdz=0` 表示已经开始了。
- `abs(qianyiwei-i)<2 && qdz!=1`：只有已经开始（`qdz!=1`）时才检查相邻差至少 2；前导零阶段不检查。
- `qdz&&(i==0)`：只要一直填 0，`qdz` 就一直为 1（仍未开始）。
- `solve` 里把字符串从高位到低位拷进 `N`（`N[i+1] = x[i]-48`），`dqw = x.size()` 是位数，从 `dfs(1,1,0,1)` 开始。
- 主函数把 `a` 减一，用 `solve(b) - solve(a-1)` 得到区间计数。

### 模块三：例题二 手机号码

> **题意**：统计 11 位手机号码中，**至少出现 3 个相邻相同数字**，且**不能同时出现 4 和 8** 的号码个数。号码无前导零，区间 $[L,R]$ 均为 11 位数。

**状态设计**：

- `pos`：当前位。
- `tight`：是否贴住上界。
- `last`：上一位数字（用于判断连续）。
- `started`：由于固定 11 位，第一位不能是 0，所以 `started` 可省（但代码中仍保留，用于通用）。
- `same`：当前连续相同数字的长度（最多到 3，再大也截断为 3，因为超过 3 仍满足「至少 3」）。
- `has4`、`has8`：是否出现过 4 / 8。

**转移**：枚举数字 `d`，先检查 `tight` 边界。

- 更新 `nsame`：如果 `d == last`，则 `nsame = min(3, same+1)`，否则 `nsame = 1`（通常把第一个数字的 `same` 设为 1）。
- 更新 `has4` 和 `has8`。
- 如果 `has4 && has8` 同时为 true，则该分支直接跳过（不合法）。
- 递归到下一位。

**递归基**：最后一位填完，检查 `same >= 3`（4、8 同时出现已在转移中过滤），满足返回 1，否则 0。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[20][2][20][2][4][4],N[20];
int dqw;
int dfs(int w,int tit,int hyw,int qdz,int mp3,int k84){
    if(dp[w][tit][hyw][qdz][mp3][k84]!=-1) return dp[w][tit][hyw][qdz][mp3][k84];
    if(w==dqw+1){
		if(mp3>=3) return 1;
		else return 0;
	}
    dp[w][tit][hyw][qdz][mp3][k84]=0;
    for(int i=0;i<10;i++){
        if(tit&&i>N[w]) continue;
        int nk84=k84,nmp3=mp3;
        if(i==8) nk84=k84|2;
        if(i==4) nk84=k84|1;
        if(mp3<3){
			if(i==hyw&&!qdz) nmp3=mp3+1;
			else nmp3=1;
		}
        if(nk84==3) continue;
        dp[w][tit][hyw][qdz][mp3][k84]+=dfs(w+1,tit&&(i==N[w]),i,qdz&&(i==0),nmp3,nk84);
    }
    return dp[w][tit][hyw][qdz][mp3][k84];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	for(int i=0;i<(int)x.size();i++){
	    N[i+1]=x[i]-'0';
	}
	dqw=x.size();
	return dfs(1,1,0,1,1,0);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
    int cnt=solve(r)-solve(l);
	cout<<cnt;
}
```

- `k84` 用两个二进制位记录出现过哪些数：`8` 置 `|2`、`4` 置 `|1`，所以 `nk84 == 3` 就代表**同时出现过 4 和 8**，直接 `continue` 剪掉。
- `mp3` 是连续相同的长度，且用 `if(mp3<3)` 截断，最大只记到 3（再大也不用区分）。
- `i==hyw && !qdz`：只有不是前导零（`!qdz`）时才可能与前一位相同、累加连续长度。
- 递归基判断 `mp3>=3`，即出现过至少 3 个相邻相同数字，满足则计 1。

## 复杂度分析

状态数为 `位数 × 2 × 2 × 其他状态数`，每一位枚举 10 个数字，所以单次 `solve` 的复杂度大约是：

$$
O(\text{len} \times \text{状态数} \times 10)
$$

其中 `len` 是上界的位数，通常 $\le 19$（`long long` 范围）。因此数位 DP **非常快，与上界大小无关，只与位数和状态数有关**。

- 时间复杂度：$O(\text{len} \times \text{状态数} \times 10)$。
- 空间复杂度：$O(\text{len} \times \text{状态数})$（记忆化数组）。

## 适用场景

- 统计区间 $[L, R]$ 内满足「**数位层面**限制」的数的个数（相邻差、数位和、是否含某些数字等）。
- 数位上的最值问题（在限制下最大化 / 最小化某个数位相关量）。
- 上界极大（如 $10^{18}$ 甚至大整数）时，暴力枚举不可行、但位数很小，正是数位 DP 的用武之地。

## 常见陷阱与注意事项

1. **前导零**：前导零不算入数字，但长度固定时（如 11 位手机号）前导零就是非法首位，所以可以直接限制第一位从 1~9 枚举，省去 `started`。
2. **0 是否算数**：如果统计区间包含 0，需要单独处理，因为 `solve(0)` 应返回 1（或 0，取决于定义）。通常 `solve(-1)=0`，`solve(0)=1`（若 0 满足条件）。
3. **记忆化的时机**：只在 `!tight` 和 `!started` 时记忆化，否则状态与具体上界绑定，复用率低。
4. **状态维度爆炸**：不要随意加维度，先想清楚是否真的需要。如果某个信息只在递归基中用到，可以用数学计算代替（如数位和）。
5. **源里 windy 代码的写法（照搬未改）**：`dp` 维度里带了 `is_limited` 这一维，也就是说贴界 / 不贴界两种情形分开记忆化，并没有走「只在 `!tight` 时缓存」的教科书优化。因为贴界的路径本身只有一条、状态数很少，这样写依然正确且够快，这里按**原样搬运**，不改成标准写法。
6. **windy 的 0 计数**：递归基对所有合法路径都返回 1，等价于把数字 0 也算作 windy 数；但答案用 `solve(b) - solve(a-1)` 相减时这个多算的 1 会被抵消，所以不影响结果。
7. **区间转前缀的边界**：主函数统一用 `a--` 后 `solve(R) - solve(L-1)`，注意 `L` 为 0 / 1 时的边界。

**最后**：数位 DP 是竞赛中性价比极高的知识点——代码模板固定，思维难度主要在**把题目限制翻译成状态和转移**。只要你能画出状态转移图，剩下的就是套模板。建议先把这两个例题的代码看懂，然后自己动手写一遍，再找几道变式（如「不含 4 且不含 62」「数字和能被 9 整除」等）练手。记住：**数位 DP 的复杂度只与位数和状态数有关，与数字大小无关**，所以遇到 $10^{18}$ 甚至 $10^{100}$（大整数）时，它都是你的好伙伴。
