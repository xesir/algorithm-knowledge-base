---
id: str-ac-automaton
title: 'AC 自动机'
category: 字符串
subcategory: 字符串匹配
subSubcategory: ''
tags: ["字符串", "AC自动机", "多模式匹配", "Trie", "fail指针", "拓扑排序"]
timeComplexity: 'O(∑|s_i|·26 + |t|)'
spaceComplexity: 'O(∑|s_i|·26)'
level: A
codePath: '字符串\AC自动机\Untitled1--xesir.cpp'
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

AC 自动机（Aho–Corasick Automaton）是解决**多模式串匹配**问题的经典算法。你可以把它理解为 **“Trie 树上的 KMP”**：Trie 树负责存储所有模式串，而 fail 指针则借用了 KMP 中失配跳转的思想，让文本串只需扫描一遍，就能同时找出所有模式串的出现情况。

### 从暴力到 AC 自动机

假设有 $k$ 个模式串和一个文本串，如果用 KMP 逐个匹配，每次都要从头扫描文本串，总复杂度是 $O(k \times (n + m))$。当 $k$ 很大时（比如 $10^5$），这显然不可接受。

AC 自动机的思路是：**先把所有模式串建成一棵 Trie 树，然后在这棵树上一次性扫描文本串**。这样每个字符只处理一次，总复杂度降到 $O(\sum |s_i| + |t|)$，其中那多出来的一个 $26$ 常数，下面讲路径压缩时会看到是怎么冒出来的。

### 建 Trie 树

把所有模式串插入一棵普通的 Trie 树。Trie 的每个节点代表一个**状态**，即某个模式串的前缀；节点之间的边代表状态转移。

假设模式串集合为 `{he, she, his, hers}`，建出来的 Trie 里，带颜色的节点是模式串的结尾，需要标记出来。本代码用 `val[u]` 记录「节点 $u$ 是第几个模式串的结尾」，再用 `rev[x]` 做一次编号到节点的反查——因为模式串可能重复，重复的那几个会被塞到同一个 Trie 节点上，光靠 `val` 只能记住其中一个。

### fail 指针

fail 指针是 AC 自动机的灵魂。它的定义是：**节点 $u$ 的 fail 指针指向另一个节点 $v$，使得 $v$ 所代表的字符串是 $u$ 所代表字符串的最长后缀，且 $v$ 是某个模式串的前缀**。

简单说：**fail 指针指向“当前状态的最长后缀状态”**。

以 `{he, she, his, hers}` 的 Trie 为例：

- 节点 `she` 的 `h`（路径 s→h）所代表的字符串是 `sh`。它的最长后缀（同时也是某个模式串的前缀）是 `h`，所以它的 fail 指向根节点的 `h`。
- 节点 `hers` 的 `s`（路径 h→e→r→s）代表的字符串是 `hers`。它的最长后缀是 `s`（`she` 的结尾），而 `s` 也是 `she` 的前缀，所以它的 fail 指向根节点的 `s`。
- 其他 fail 指针同理。

**为什么跳 fail 是对的？** 这与 KMP 里 `j = nxt[j]` 是同一件事。设当前已经沿着文本串走到了节点 $u$，说明文本串当前这个后缀等于 $u$ 所代表的字符串。如果文本串的下一个字符接不上 $u$ 的某个儿子，那么任何以「$u$ 的串 + 新字符」为后缀的模式串都不可能成立；能成立的只可能是更短的后缀，也就是 $u$ 的某个后缀状态接上新字符。fail 指针给出的是**最长的那个后缀状态**，从它开始尝试，既不漏解（更短的后缀都是 fail 链上的祖先），也最省事（最长的那条能接上就不用再退）。

fail 指针通过 **BFS（广度优先搜索）** 按层构建。核心递推关系是：

> 设当前节点为 $u$，字符 $c$ 对应的子节点为 $v = ch[u][c]$。
> 则 `fail[v] = ch[fail[u]][c]`。

用人话说就是：**$v$ 的 fail 指针，等于 $u$ 的 fail 指针沿着字符 $c$ 走一步到达的节点**。

这个递推能成立，是因为 $v$ 代表的串是「$u$ 的串 + $c$」。$v$ 的后缀必须形如「$u$ 的某个后缀 + $c$」；按 fail 的定义要取其中最长的，而 $u$ 的最长后缀就是 `fail[u]`，所以只要看 `fail[u]` 能不能接上 $c$。能接上，`ch[fail[u]][c]` 就是答案；接不上也不用担心，因为下一层的路径压缩会保证 `ch[fail[u]][c]` 这个位置**永远有值**（要么是真儿子，要么已经被压到了更短的后缀状态）。

### 路径压缩

构建 fail 时，如果节点 $u$ 没有字符 $i$ 的子节点，就直接把 $c[u][i]$ 指向 $c[fail[u]][i]$：

```text
c[u][i] = c[fail[u]][i];   // 空儿子直接连到 fail 的对应儿子
```

它的含义是：**如果节点 $u$ 没有字符 $i$ 对应的子节点，就直接把 $u$ 的 $i$ 儿子指向 `fail[u]` 的 $i$ 儿子**。

这样做的好处是：匹配时**不需要 while 循环跳 fail**，直接一步走到正确的节点。本质上相当于**并查集的路径压缩**——把“不存在的边”直接连到“最终会到达的节点”上。经过路径压缩后，Trie 树就变成了一张 **Trie 图**，每个节点对每个字符都有明确的转移，匹配时只需 $O(1)$ 跳转。

这里有个顺序上的小讲究：BFS 是按深度一层层来的，轮到 $u$ 的时候，`fail[u]` 的深度一定比 $u$ 小，它的 26 个转移**已经全部压好了**。所以 `c[u][i] = c[fail[u]][i]` 拿到的就是一个「已经正确」的转移，不需要再沿链回溯。

### 匹配过程

有了 fail 指针和路径压缩，匹配就非常简单了：每扫描一个字符，就从当前节点走一步，走到哪个节点，就在哪个节点上记录一次“经过”。

注意这里**只在当前节点打标记，不沿 fail 链往上跳**。这一点很关键：文本串扫到某个位置时，所有「以这个位置结尾」的模式串，正好对应当前节点在 fail 树上的整条祖先链。打标记只记了链底，剩下的交给拓扑统计去上传。

### 拓扑排序

如果只打标记，我们只知道**哪些节点被经过了**。但要统计**每个模式串出现了多少次**，还需要沿着 fail 链把标记“上传”给更长的后缀。

**为什么需要拓扑排序？**

fail 指针构成了一棵 **fail 树**。每个节点的 fail 指向它的父节点（fail 指针指向的节点是当前节点的后缀）。如果我们每次匹配到一个节点，就暴力沿着 fail 链一直跳到根，复杂度会退化成 $O(|t| \times \text{树高})$，最坏是 $O(|t| \times \sum |s_i|)$，不可接受。

**正确的做法**是：只在当前节点 `ans[p]++`，然后**在 fail 树上做一次拓扑排序**，把子节点的 `ans` 累加到父节点上。`ind` 数组记录的就是 fail 树上的入度：构建 fail 时每设置一个 `fail[v] = u`，就让 `ind[u]++`。这样拓扑排序后，**每个节点的 `ans` 值就是该节点代表的字符串在整个文本串中出现的次数**。

### last 指针（后缀链接优化）

路径压缩解决了“匹配时跳转慢”的问题，但在某些场景下（比如需要找所有匹配的模式串），跳 fail 链仍然可能经过很多**非单词结尾节点**，效率不高。

**last 指针**的定义是：**从节点 $u$ 开始，沿着 fail 链跳到的第一个是单词结尾的节点**。递推式一行搞定：

```text
last[v] = val[fail[v]] ? fail[v] : last[fail[v]];
```

这样，匹配时只需要沿 `last` 链跳，每次跳到的节点**一定对应一个模式串**，不会空跳。

> **注意**：last 指针是一个**常数优化**，对复杂度没有理论上的改进，但在实际运行中效果明显。本代码没有用 last，而是直接用拓扑排序一次性统计，思路更省心。

## 核心公式 / 状态定义与转移方程

**状态定义**：

- `c[u][i]`：节点 $u$ 沿字符 $i$（`idx` 映射到 $0\sim 25$）的转移目标，路径压缩后每个位置都非空；
- `val[u]`：节点 $u$ 是第几个模式串的结尾（不是结尾则为 0）；
- `rev[x]`：第 $x$ 个模式串最终落在的 Trie 节点编号，重复模式串靠它共用答案；
- `fail[u]`：节点 $u$ 的最长后缀状态；
- `ans[u]`：节点 $u$ 被经过的次数，拓扑后变成「$u$ 代表的串在文本串中的出现次数」；
- `ind[u]`：fail 树上的入度，即有多少个节点的 fail 指向 $u$；
- `cxc[x]`：第 $x$ 个模式串的最终答案。

**转移与递推**（其中 $v = c[u][i]$ 是真实存在的儿子）：

$$fail[v] = c[fail[u]][i]$$

**路径压缩**（当 $c[u][i]$ 为空时）：

$$c[u][i] = c[fail[u]][i]$$

**匹配**（$p$ 从根 0 出发，$t_j$ 是文本串第 $j$ 个字符）：

$$p \leftarrow c[p][t_j], \qquad ans[p] \leftarrow ans[p] + 1$$

**统计**（fail 树上从叶子向根累加）：

$$ans[fail[u]] \leftarrow ans[fail[u]] + ans[u]$$

**答案回填**：若 `val[u]` 非 0，则 `cxc[val[u]] = ans[u]`。

**last 指针**（可选优化）：

$$last[v] = \begin{cases} fail[v], & val[fail[v]] \ne 0 \\ last[fail[v]], & \text{否则} \end{cases}$$

## 逐行代码解析

下面按 4 个模块拆开讲，按顺序拼接就是 `Untitled1--xesir.cpp` 的完整内容。

### 模块一：头文件、结构体定义与建 Trie

```cpp
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=1e6+10;
//int cnt=0;
//int a[N];
struct AC{
	int c[N][26],val[N],fail[N],ans[N],ind[N],rev[N],cxc[N];
	int rot=0,cnt=0;
	int idx(char a){
		return (int)(a-'a');
	}
	void insert(string s,int x){
		int nrt=rot,len=s.size();
		for(int i=0;i<len;i++){
			int id=idx(s[i]);
			if(!c[nrt][id]) c[nrt][id]=++cnt;
			nrt=c[nrt][id];
		}
		if(!val[nrt]) val[nrt]=x;
		rev[x]=val[nrt];
	}
```

- `c[N][26]` 是 Trie 的转移数组，每个节点存 26 个儿子；`val` 记模式串编号，`fail` 存 fail 指针，`ans` 记经过次数，`ind` 是 fail 树入度，`rev` 做编号反查，`cxc` 回填答案。
- `#define int long long` 把所有 `int` 换成 64 位整数，省得担心计数溢出；代价是 `c[N][26]` 的内存直接翻倍，$N=10^6$ 时单这一个数组就要 200 MB 量级，空间紧的题要自己掂量。
- `rot=0` 是根节点，`cnt` 从 0 开始给新节点发号；`idx` 把 `'a'~'z'` 映射到 $0\sim 25$，所以这套模板只吃小写字母。
- `insert` 就是普通 Trie 插入：边不存在就新建 `++cnt`，一路走到串尾。
- `if(!val[nrt]) val[nrt]=x;` 只在节点第一次被标记时写编号，避免重复模式串互相覆盖；`rev[x]=val[nrt];` 再把「第 $x$ 个串」映射到那个真正被标记的节点，重复串就都指到同一处了。

### 模块二：建 fail 指针（BFS + 路径压缩）

```cpp
	void build(){
		queue<int> q;
		for(int i=0;i<26;i++){
			if(c[rot][i]){
				fail[c[rot][i]]=rot;
				q.push(c[rot][i]);
				ind[rot]++;
			}
		}
		while(q.size()){
			int x=q.front();q.pop();
			for(int i=0;i<26;i++){
				if(c[x][i]){
					fail[c[x][i]]=c[fail[x]][i];
					q.push(c[x][i]);
					ind[fail[c[x][i]]]++;
				}else c[x][i]=c[fail[x]][i];
			}
		}
	}
```

- 根的所有儿子先入队，fail 直接指向根；每有一个这样的儿子，就给根的入度 `ind[rot]++`（在 fail 树里，根是它们的父节点）。
- `while` 是标准 BFS：取队首 $x$，枚举它的 26 个字符位。
- `if(c[x][i])` 分支：这是真实的 Trie 儿子，按递推式 `fail[c[x][i]] = c[fail[x]][i]` 定 fail，然后把儿子入队，同时给 `fail[儿子]` 的入度加一。
- `else` 分支：空儿子做路径压缩 `c[x][i] = c[fail[x]][i]`。**这一行必须留在 else 里**——真实儿子是不能被覆盖成 fail 转移的，否则 Trie 结构当场就没了。
- 整个 build 结束后，`c` 已经不再是纯粹的 Trie，而是一张每格都有值的 Trie 图。

### 模块三：匹配打标记 + fail 树上拓扑统计

```cpp
	void query(string s){
		int nrt=rot,len=s.size();
		for(int i=0;i<len;i++){
			int id=idx(s[i]);
			nrt=c[nrt][id];
			ans[nrt]++;
		}
	}
	void topo(){
		queue<int>q;
		for(int i=1;i<=cnt;i++){
			if(ind[i]==0)q.push(i);
		}
		while(!q.empty()){
			int tmp=q.front();
			q.pop();
			if(val[tmp]) cxc[val[tmp]]=ans[tmp];
			int x=fail[tmp];
			ind[x]--,ans[x]+=ans[tmp];
			if(ind[x]==0) q.push(x);
		}
		return;
	}
```

- `query` 全程只有一步转移 `nrt=c[nrt][id]`，没有 while、没有跳 fail——这就是路径压缩换来的 $O(|t|)$。
- `ans[nrt]++` 记录的是「节点被经过」，不是「模式串出现」。文本串短、模式串长的时候，走到的绝大多数节点根本不是结尾。
- `topo` 先把 fail 树上所有入度为 0 的节点（即叶子）入队，然后逐个弹出：`if(val[tmp]) cxc[val[tmp]]=ans[tmp];` 在这一刻，`tmp` 的所有 fail 树后代都已经把贡献加完了，所以这就是最终次数。
- `int x=fail[tmp]; ind[x]--,ans[x]+=ans[tmp];` 把 `tmp` 的标记交给父节点，并消掉一条入边；父节点入度归零就入队。
- 循环起点是 `i=1`，根（编号 0）不参与初始入队；但根会在入度被消到 0 时由 `q.push(x)` 补进来。根一旦被弹出，`x=fail[0]=0`，会执行 `ind[0]--` 和 `ans[0]+=ans[0]`，把 `ans[0]` 翻倍。因为根上不带 `val`，这一下不影响任何答案，属于「看着吓人但其实无害」的写法。

### 模块四：主函数

```cpp
} zmy;
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
	int n;cin>>n;
	for(int i=1;i<=n;i++){
		string s;cin>>s;
		zmy.insert(s,i);
	}
	zmy.build();
	string s;cin>>s;
	zmy.query(s);
	zmy.topo();
	for(int i=1;i<=n;i++){
		cout<<zmy.cxc[zmy.rev[i]]<<'\n';
	}
    return 0;
}
```

- 开头 `} zmy;` 收掉结构体定义，顺手声明了一个全局对象 `zmy`，后面全部调用都走它；`read`、`write` 只留了声明没写实现，本题用 `cin`/`cout` 就够，不影响编译。
- `#define int long long` 会把 `main` 前面的 `int` 也替换掉，导致返回类型不合标准；`signed` 等价于 `int` 且不会被宏替换，所以这里写 `signed main()`。
- 读入 $n$ 后逐个插入模式串，编号就是读入顺序 $1 \sim n$。
- `build()` 建 fail 与路径压缩，`query(s)` 扫文本串打标记，`topo()` 上传统计。三步的顺序不能换。
- 输出时用 `cxc[zmy.rev[i]]`：`rev[i]` 找到第 $i$ 个模式串对应的 Trie 节点，`cxc` 取该节点的累计次数。直接写 `cxc[i]` 是错的，`i` 是输入编号而不是节点编号。

## 复杂度分析

| 阶段 | 时间复杂度 | 说明 |
|---|---|---|
| 建 Trie | $O(\sum \lvert s_i\rvert)$ | 每个字符走一步 |
| 构建 fail | $O(\sum \lvert s_i\rvert \times 26)$ | 每个节点枚举 26 个字符位，顺带做路径压缩 |
| 匹配 | $O(\lvert t\rvert)$ | 文本串每个字符一步转移，不跳链 |
| 拓扑统计 | $O(\sum \lvert s_i\rvert)$ | fail 树每个节点恰好进出队一次 |
| 总计 | $O(\sum \lvert s_i\rvert \times 26 + \lvert t\rvert)$ | 关于输入规模线性 |

**空间**：由转移数组主导。节点数约为 $\sum \lvert s_i\rvert$，每个节点 26 个转移，故为 $O(\sum \lvert s_i\rvert \times 26)$。再叠加 `#define int long long` 的 8 字节，$N=10^6$ 时 `c[N][26]` 约 208 MB，其余几个数组各 8 MB，总内存接近 250 MB，多数题的 128 MB 限制是过不去的，需要按实际数据量把 `N` 调小。

## 适用场景

- **多模式串出现次数统计**：给一堆单词和一个长文本，问每个单词各出现几次——本篇代码就是干这个的。
- **敏感词过滤 / 关键词高亮**：把词库建成 AC 自动机，文本扫一遍就能标出所有命中位置（要输出位置的话，在 `query` 里沿 fail 链或 `last` 链收集即可）。
- **AC 自动机 + DP**：把「已匹配的后缀」压成自动机节点，在状态机上跑计数 DP，比如统计长度为 $n$ 且不含任何给定子串的串有多少个。
- **fail 树上的树上问题**：fail 指针天然构成一棵树，子树求和、树上差分、dfs 序 + 树状数组都能往上套。
- **不适合**：只有一两个模式串时，KMP 更短更稳；只查前缀时 Trie 就够了，不必上 fail。

## 常见陷阱与注意事项

1. **路径压缩的写法**：`c[x][i] = c[fail[x]][i]` 必须写在 `else` 分支里，**不能**把 `v` 替换成 `c[fail[x]][i]` 之后还去更新 `fail[v]`——那样等于给一个不存在的节点设 fail，整棵树就乱了。
2. **入度统计的时机**：每执行一次 `fail[c[x][i]] = c[fail[x]][i]`，就要 `ind[fail[c[x][i]]]++`；根的儿子入队时也要 `ind[rot]++`。漏一个，拓扑就永远等不到那个节点，答案静默变 0。
3. **根节点的处理**：根节点的 fail 指针指向自己。本代码根是 0，`fail[0]` 靠全局数组默认值 0 实现自指，没有显式赋值；根的子节点 fail 默认指向根，BFS 初始化时全部入队。
4. **重复模式串**：用 `val` 记录编号、`rev` 反向映射，同一个 Trie 节点可能对应多个模式串。若图省事直接 `val[节点]=i` 覆盖，前面那个串的答案就丢了。
5. **数组大小**：`c` 数组大小应为「节点数 × 26」，节点数约为 $\sum \lvert s_i\rvert$，不要开小；开大了又会被 64 位 `int` 撑爆内存。
6. **`#define int long long` 的连带影响**：所有 `int` 变成 64 位，`c[N][26]` 等数组内存翻倍；`main` 必须写成 `signed main`。
7. **输出时要过 `rev`**：`cxc` 的下标是节点编号，题目问的是「第几个串」，中间隔着 `rev` 这一层，别直接拿输入编号去索引。
8. **`query` 只打标记**：少写 `topo` 就直接输出，得到的是「有多少个前缀被走过」，不是出现次数；把 `ans` 当答案交上去会得到一堆莫名其妙的数。
9. **字符集假设**：`idx` 只做 `a-'a'`，输入里混进大写字母或数字就会越界写数组。换字符集时要把 `26` 和 `idx` 一起改。
