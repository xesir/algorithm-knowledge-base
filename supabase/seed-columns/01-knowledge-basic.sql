-- ============================================================
-- AKB 专栏种子：知识点 / 基础算法
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：53 行
-- ============================================================
begin;

drop table if exists _akb_seed_columns;
create temp table _akb_seed_columns (
    author_name text not null,
    column_key text not null,
    column_name text not null,
    content text not null,
    category text,
    tags text[],
    parent_key text,
    difficulty text,
    kind text not null
) on commit drop;

insert into _akb_seed_columns (
    author_name, column_key, column_name, content, category, tags, parent_key, difficulty, kind
) values
('world-needs-sunday', 'col-basic-astar', 'A* 启发式搜索', $AKB1$## 算法原理

**一句话结论**：A*（A-star）是「带启发函数的 Dijkstra」——选择下一个扩展状态时，不只比较从起点到它的实际代价 $g(n)$，还加上对它到目标的剩余代价的估计 $h(n)$，按 $f(n)=g(n)+h(n)$ 从小到大扩展，从而优先探索「看起来更有希望尽快到达目标」的状态。

**与 Dijkstra、贪心搜索的关系**：

- Dijkstra 只按 $g(n)$（起点到当前点的实际代价）排序，相当于启发函数恒为 0（$h \equiv 0$）的 A*；它保证最优，但会以起点为圆心比较均匀地向四周扩散，扩展大量与目标无关的状态。
- 贪心搜索只按 $h(n)$ 排序，方向性最强、速度最快，但**不保证最优**。
- A* 取两者之长：$g$ 保证「走过的代价不被忽略」，$h$ 提供「朝目标前进的方向感」。所以 A* 比贪心更稳，比 Dijkstra 更有方向性。

**启发函数的核心性质——可采纳性（admissible）**：$h(n)$ 必须是从 $n$ 到目标 $T$ 的剩余代价的**下界**，即对任意从 $n$ 到 $T$ 的路径，真实剩余代价 $cost(n,T)$ 满足 $h(n) \le cost(n,T)$。启发式可以低估、**绝不能高估**：高估会把某条路径的 $f$ 值算得虚高，真正的最优路径被错误地排在队列后面，导致 A* 错过最优解；低估只会让搜索多扩展一些状态、变慢一点，但答案依然正确。

**更强且常用的性质——一致性（consistency / 单调性）**：对每条边 $(u,v,w)$，要求 $h(u) \le w + h(v)$。直观理解：从 $u$ 到目标的估计代价，不应该大于「先走一步到 $v$、再从 $v$ 估计到目标」的代价。若启发函数满足一致性，则普通 A* 中每个状态**第一次被弹出优先队列时**就已经是最优，可以放心使用关闭集、不需要重复扩展。第 K 短路中取 $h(v)=dist(v,T)$（反向最短路），边权非负时满足一致性；不过 K 短路本身要求同一点到达多次，所以用计数器 `cnt` 而不用布尔关闭集。

**本知识点的主战场——第 K 短路（洛谷 T105289【模板】A*）**：求从 $S$ 到 $T$ 的第 $K$ 短路长度，允许重复经过点和边，每条第 K 短路至少含一条边，不存在输出 -1。做法分两步：

1. **求启发函数**：建反向图，从 $T$ 跑一次 Dijkstra，得到每个 $v$ 到 $T$ 的最短距离 $h(v)=dist(v,T)$。任何从 $v$ 到 $T$ 的路径长度都不可能小于它，所以是可采纳下界。
2. **A* 搜索**：优先队列按 $f(v)=dist(S,v)+h(v)$ 排序；一个点可以多次入队、多次弹出，用计数器 $cnt[v]$ 记录弹出次数。**第 $K$ 次弹出终点 $T$ 时，当前 $f$ 值就是第 $K$ 短路长度**。

**正确性直觉**：$f(v)=dist(S,v)+h(v)$ 是「经过 $v$ 到达 $T$ 的某条完整路径长度」的下界，优先队列永远先扩展「完整路径下界更小」的状态。当 $T$ 第 $K$ 次被弹出时，已经找到了 $K$ 条到达 $T$ 的路径，且所有尚未发现路径的前缀 $f$ 值都不小于当前值，不可能再产生更短的第 $K$ 条路径，因此当前值即第 $K$ 短路。

## 核心公式 / 状态定义与转移方程

**评价函数**：

$$f(n) = g(n) + h(n)$$

- $g(n)$：起点 $S$ 到当前状态 $n$ 的**实际代价**；
- $h(n)$：状态 $n$ 到目标 $T$ 的**预估剩余代价**（启发函数）；
- $f(n)$：经过 $n$ 到目标的**总代价估计**，是优先队列的排序键。

**可采纳性**：$h(n) \le cost(n,T)$。**一致性**：$h(u) \le w(u,v) + h(v)$。

**常见启发函数（网格图）**：

- 四方向、每步代价 1：曼哈顿距离 $h=\lvert x_n-x_T \rvert + \lvert y_n-y_T \rvert$（真实最少步数的下界）；
- 八方向、每步代价 1：切比雪夫距离 $h=\max(\lvert x_n-x_T \rvert,\ \lvert y_n-y_T \rvert)$（此时欧氏距离可能大于它，会高估，不能用）；
- 八方向、对角代价 $\sqrt{2}$：欧氏距离可采纳。

**第 K 短路的状态定义与转移**（本代码的实现）：

- 状态：当前到达的节点 $v$；$h(v)=dist(v,T)$ 由**反向图从 $T$ 出发的 Dijkstra** 一次性求出。
- 初始：`que.emplace(g[s], s)`，即 $f(S)=0+h(S)=g[S]$。
- 弹出：`w = que.top().first` 是 $f(d)=dist(S,d)+h(d)$，**不是**单纯的 $dist(S,d)$。
- 转移（扩展邻居 $to$，边权 $to\_w$）：

```text
先求实际距离  dist(S,d)   = w - h(d)
再求新实际    dist(S,to)  = w - h(d) + to_w
新的 f 值     f(to)       = w - h(d) + to_w + h(to)
```

对应代码 `long long nf = w - g[d] + to_w + g[to];`（这里的 `g` 数组即启发函数 $h$）。**必须先减去当前点的启发值、再加新点的启发值**，否则前驱的预测值会被错误累加（见陷阱 2）。

- 计数：`if (cnt[d] >= k) continue; ++cnt[d];`——每个点最多需要前 $K$ 次到达；`cnt[d] == k && d == t` 时返回 `w`（因 $h(T)=0$，此时 $w=dist(S,T)$ 即第 $K$ 短路长度）。
- 空路径处理：$S=T$ 时，初始状态 $(0,S)$ 代表「一条边都不走」的空路径，而题目要求每条路径至少含一条边。读入后 `if (S == T) ++K;`，让空路径占用一次计数但不被返回，第 $K+1$ 次弹出 $T$ 才对应真正的第 $K$ 条非空路径。

**手算示例**：$N=4$，边：$1\to2\ (1)$、$1\to3\ (3)$、$2\to3\ (1)$、$2\to4\ (4)$、$3\to4\ (1)$，求 $1\to4$ 的第 2 短路。

- 反向图 Dijkstra（从 4 出发）：$h(4)=0$，$h(3)=1$，$h(2)=\min(4,\ 1+1)=2$，$h(1)=\min(2+1,\ 1+3)=3$。
- A* 弹出序列（括号内为 f 值）：$(3, 1)$ → 入队 $(3,2)、(4,3)$；弹出 $(3,2)$ → 入队 $(3,3)、(5,4)$；弹出 $(3,3)$ → 入队 $(3,4)$；弹出 $(3,4)$：$cnt[4]=1$；弹出 $(4,3)$ → 入队 $(4,4)$；弹出 $(4,4)$：$cnt[4]=2=K$，返回 4。
- 验证：到 4 的路径有 $1\to2\to3\to4=3$、$1\to3\to4=4$、$1\to2\to4=5$，第 2 短路确实是 4。该输入经本代码实测输出 4。

## 逐行代码解析

代码拆成 4 个模块，按顺序拼接即完整程序。

### 模块 1 全局变量与初始化

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<vector<pair<int, int>>> edges,re_edges;
vector<long long> g;
vector<unsigned int> cnt;
void init(int n)
{
	edges.assign(n + 1, {});
	re_edges.assign(n + 1, {});
	g.assign(n + 1, LLONG_MAX >> 2);
	cnt.assign(n + 1, 0);
}
```

- `edges` 存原图、`re_edges` 存反向图：反向图用于从 $T$ 出发求每个点到 $T$ 的最短距离。
- `g[v]` 就是启发函数 $h(v)=dist(v,T)$；`cnt[v]` 是节点 $v$ 已弹出的次数（K 短路中一个点要弹出多次，不能用 bool 关闭）。
- `LLONG_MAX >> 2` 作为无穷大：右移 2 位留出加法余量，防止 `w + to_w` 时溢出。
- `init(n)` 统一建图与清空；多组数据时每轮都要调用，否则残留上次的边和计数。

### 模块 2 反向 Dijkstra 求启发函数

```cpp
void dij(int n, int s, vector<vector<pair<int, int>>>& e, vector<long long>& arr)
{
	vector<bool> vis(n + 1, false);
	priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<pair<long long, int>>> que;
	que.emplace(0, s);
	arr[s] = 0;
	while (!que.empty())
	{
		long long w = que.top().first;
		int d = que.top().second;
		que.pop();
		if (vis[d]) continue;
		vis[d] = true;
		for (pair<int, int>& i : e[d])
		{
			int to = i.first;
			int to_w = i.second;
			if (vis[to]) continue;
			if (arr[to] > w + to_w)
			{
				arr[to] = w + to_w;
				que.emplace(arr[to], to);
			}
		}
	}
}

```

- 标准堆优化 Dijkstra：小根堆按距离排序，第一次弹出即最短路，`vis` 标记不再处理。
- 调用方式是 `dij(N, T, re_edges, g)`：从终点 $T$ 出发、在**反向图**上跑，得到的 `g[v]` 恰好等于原图中 $v\to T$ 的最短距离。
- 必须在反图上跑而不是正图：正图从 $S$ 跑出来的是 $dist(S,v)$（已付出的代价），不是剩余代价，不能充当 $h(v)$。
- 边权需非负；负权图的最短路 Dijkstra 不适用。

### 模块 3 A* 主循环

```cpp
long long A(int s,int t, int k,vector<vector<pair<int, int>>>& e, vector<long long>& g)
{
	priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<pair<long long, int>>> que;
	que.emplace(g[s], s);
	while (!que.empty())
	{
		long long w = que.top().first;
		int d = que.top().second;
		que.pop();
		if (cnt[d] >= k) continue;
		++cnt[d];
		if (cnt[d] == k && d == t) return w;
		for (pair<int, int>& i : e[d])
		{
			int to = i.first;
			int to_w = i.second;
			if (cnt[to] >= k) continue;
			que.emplace(w - g[d] + to_w + g[to] , to);
		}
	}
	return -1;
}
```

- 初始入队 `(g[s], s)`：起点实际距离为 0，$f(S)=h(S)=g[S]$。
- `w` 是 $f(d)=dist(S,d)+h(d)$，已包含当前点的启发值；转移时 `w - g[d]` 先还原出实际距离 $dist(S,d)$，加 `to_w` 得到 $dist(S,to)$，再加 `g[to]` 得到新的 $f(to)$——正是「减前驱预测、加新预测」。
- `cnt[d] >= k` 两个位置各有一道剪枝：弹出前，第 $K+1$ 次到达某点不再处理；入队前，已有 $K$ 条路径到 $to$ 就不再扩展它。对任意中间点，超过 $K$ 条路径无助于得到更优的第 $K$ 条到 $T$ 的路径。
- `cnt[d] == k && d == t` 时直接返回 `w`：此时 $h(T)=0$，$w$ 就是第 $K$ 短路长度。
- 队列清空仍未返回，说明到 $T$ 的路径不足 $K$ 条，返回 -1（不可达 $T$ 时所有状态都带着 $INF/4$ 级别的启发值，最终同样走到这里返回 -1）。

### 模块 4 主函数

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int N, M;
	cin >> N >> M;
	init(N);
	for (int i = 1; i <= M; i++)
	{
		int a, b, w;
		cin >> a >> b >> w;
		edges[a].emplace_back(b, w);
		re_edges[b].emplace_back(a, w);
	}
	int S, T, K;
	cin >> S >> T >> K;
	if (S == T) ++K;
	dij(N, T, re_edges, g);
	cout << A(S, T, K, edges, g);
	return 0;
}
```

- 每条边 $(a,b,w)$ 在两个图中各存一条：原图 `a→b`，反向图 `b→a`（权值相同）。
- `if (S == T) ++K;`：跳过「长度为 0 的空路径」。不能用 `w == 0` 判断跳过——边权可以为 0 时（如自环 `1→1` 权 0），合法的非空路径长度也可能恰为 0，会被误伤。
- 顺序：先 `++K` 再跑 A*（Dijkstra 不受 K 影响，先后皆可；`++K` 必须在搜索前完成）。

## 复杂度分析

- **反向 Dijkstra**：一次堆优化最短路，$O((N+M)\log N)$。
- **A* 主循环**：每个节点最多弹出 $K$ 次，每次弹出扩展其全部出边；堆中元素量级为 $O(KM)$，总时间 $O(KM\log(KM))$，也可粗略写成 $O(K(N+M)\log(KN))$。
- **总体**：$O((N+M)\log N + KM\log(KM))$，适合 $K$ 不太大的情形；$K$ 很大时堆会爆炸。
- **空间**：正反两图 $O(N+M)$；堆最坏存 $O(KM)$ 个状态（同一节点多次入队）；整体 $O(N+M+KM)$。
- 与朴素做法对比：直接对每条路径排序枚举是指数级；A* 借助启发函数把搜索方向收束在「可能成为前 K 短」的分支上，实际运行远快于最坏界。

## 适用场景

- **网格地图寻路**：迷宫/地图从起点到终点，状态是坐标 $(x,y)$，$g$ 为已走步数；四方向用曼哈顿距离、允许斜走用切比雪夫距离（代价均为 1）作 $h$。A* 最经典直观的应用。
- **数字华容道 / 拼图类**：状态空间极大，普通 BFS/Dijkstra 容易扩展爆炸。用 A*：状态是当前棋盘排列；$g$ 是已移动步数；$h$ 是「每个数字当前位置到目标位置的曼哈顿距离之和」——每个数字至少要走曼哈顿距离那么多步，所以 $h$ 是可采纳下界（不高估）。还可使用**错位数**（不在位的数字个数，更弱更快）或**线性冲突**（更强更接近真实距离）作启发，原则只有一个：保证不高估。
- **第 K 短路**：反向 Dijkstra 求 $h(v)=dist(v,T)$，优先队列按 $f$ 扩展，第 $K$ 次弹出终点即答案（本代码模板）。
- **不要用**：$K$ 非常大——队列可能爆炸，改用 Eppstein 算法、可持久化左偏树、Yen 算法等；只求普通最短路——Dijkstra 足够且更简单；**边权可能为负**——反向 Dijkstra 失效，需换 Bellman-Ford 系列或放弃该启发函数。

## 常见陷阱与注意事项

1. **启发函数高估**：$h$ 必须是不高估的剩余代价下界；八方向网格中把欧氏距离当 $h$（每步代价 1 时欧氏会大于切比雪夫）会破坏最优性。
2. **f 值累加错误**：直接写 `que.emplace(w + to_w + g[to], to)` 会多算一个 $h(d)$（前驱预测值未删），导致部分路径 $f$ 虚高、队列顺序错误；正确做法是 `w - g[d] + to_w + g[to]`。**写错的后果**：$h$ 被重复累加，效果等价于把启发函数放大，轻则多扩展状态变慢，重则破坏「$f$ 是完整路径下界」的性质、错过真正的第 K 短路。
3. **启发函数方向写反**：必须从 $T$ 在**反向图**上跑最短路得到 $dist(v,T)$；从 $S$ 正向跑出来的是 $dist(S,v)$，不是剩余代价。
4. **S=T 时空路径**：起点即终点时，初始状态 $(0,S)$ 代表「一条边都不走」的空路径，长度恒为 0、会在第 1 次弹出 T 时就抢占「最短」的位子，而题目要求每条路径至少含一条边，所以读入后 `if (S == T) ++K;` 让空路径占掉一次计数、不参与答案。**不能靠判断 `w == 0` 跳过**：若 $S=T$ 且存在 0 权边（例：自环 `1→1` 权 0、或 0 权回路），合法的非空路径长度也可能恰为 0，判 `w==0` 会把这些合法路径一并误杀；`++K` 空出的只是「真正的空路径」这一条。
5. **K 短路误用 vis 关闭节点**：一个点要弹出多次（第 1、2、… 次到达对应不同路径），必须用 `cnt[v]` 计数而非布尔 `vis`。
6. **不可达处理**：$g[S]$ 仍是 INF 说明 $S$ 到不了 $T$。本实现不提前判断，A* 主循环中不可达状态都带着 $INF/4$ 级启发值、每个点弹出满 $K$ 次后队列清空，最终返回 -1——正确性不受影响，代价是多扩展了不可达的状态。若图里大量点不可达 $T$，优化方向有二：入队前加「$g[to]$ 不可达则不扩展」的剪枝，或在 `A()` 开头判断 `g[s]` 仍是 INF 就提前 `return -1`（纯效率优化，非正确性问题；本代码未加）。
7. **负权边**：反向最短路用了 Dijkstra，边权为负时结果不可信；需负权环/负权边的图换 Bellman-Ford 或 SPFA 系列。
8. **无穷大取值**：INF 要用 `LLONG_MAX >> 2` 这类留余量的值，避免 `w + to_w` 溢出；路径长度全程用 `long long`。
9. **多组数据未清空**：`edges`、`re_edges`、`g`、`cnt` 都要重初始化，统一走 `init(n)`。
10. **队列里存的是 f 不是 g**：入队键永远是 $f$；单存 $g$ 就退化成 Dijkstra，失去方向性。

## 对比与扩展

**三种搜索范式对比**：

| 算法 | 排序依据 | 最优性 | 特点 |
|---|---|---|---|
| Dijkstra | g(n) | 保证 | 均匀扩散，扩展量最大 |
| 贪心搜索 | h(n) | 不保证 | 方向感最强，速度最快 |
| A* | g(n)+h(n) | h 可采纳时保证 | 兼顾方向与最优，扩展量居中 |

**K 短路的其他解法**（$K$ 很大时）：Eppstein 算法将 K 短路归约为「最短路树上加非树边的变换」；可持久化左偏树（可持久化可并堆）维护候选路径集合。二者都是 $O(K\log K)$ 级别扩展的进阶做法，但实现复杂；本模板以理解 $f=g+h$ 的启发式思想为重。

**网格启发式选择速查**：四方向代价 1 → 曼哈顿；八方向代价 1 → 切比雪夫；八方向且斜边代价为 $\sqrt{2}$ → 欧氏距离。原则始终是「取真实剩余代价的下界」。

**一句话记忆**：反向 Dijkstra 求「每个点到终点的最短路」作启发函数；优先队列存 $f=dist(S,v)+h(v)$；第 $K$ 次弹出终点即第 $K$ 短路；$S=T$ 时 `++K` 跳过空路径。$AKB1$, '基础算法', array['A*', '启发式搜索', '第K短路', 'Dijkstra', '优先队列'], 'col-hub-basic-search', null, 'knowledge'),
('Xesir', 'col-basic-base-conversion--xesir', '进制转换 · Xesir', $AKB2$## 算法原理

> 自己看代码吧，我觉得没什么难理解的（疑似失去所有耐心和肝力）。

进制转换分两步走：先把 $n$ 进制的字符串转成十进制整数，再把十进制整数转成 $m$ 进制字符串。下面这份很短的实现里，`decin(n, sl)` 把 $n$ 进制串转十进制，`decout(m, sum)` 把十进制数转 $m$ 进制串。

- **转十进制**：从最低位（字符串末尾）开始，按位取值乘上 $n^i$ 累加。大于等于 `'A'` 的字母位用 `sl[i]-55` 换成数值（`'A'` 对应 10），数字位用 `sl[i]-48`。
- **转 $m$ 进制**：不断取余数 `n % m` 作为当前最低位，再 `n /= m`，最后把结果翻转。余数小于 10 直接转字符，否则 `+55` 转成字母。

## 逐行代码解析

### 模块一：n 进制串 → 十进制

```cpp
int decin(int n,string sl){
    int sum=0;vector<int> v;
    for(int i=sl.size()-1;i>=0;i--){
            if(sl[i]<65){
                v.push_back(sl[i]-48);
            }else{
                v.push_back(sl[i]-55);
            }
        }
        for(int i=0;i<v.size();i++){
            
            sum+=v[i]*pow(n,i);
        }
        return sum;
}
```

- 倒序遍历字符串，从末位（最低位）开始取数。
- `sl[i]-48` 处理数字字符 0~9，`sl[i]-55` 处理 `A` 及以上的大写字母（`'A'` = 65，减 55 得 10）。
- 第 $i$ 位的权重是 $n^i$，用 `pow(n,i)` 计算后乘上该位的值累加。

### 模块二：十进制 → m 进制串

```cpp
string decout(int m,int n){
    int u;string rl;
    while(n){
        u=n%m;
        if(u<10){
            rl+=u+48;
        }else{
            rl+=u+55;
        }
        n/=m;
    }
    reverse(rl.begin(),rl.end());
    return rl;
}
```

- 不断 `n % m` 取当前最低位，`n /= m` 往高位走，直到 `n` 变成 0。
- 余数 `u<10` 用 `u+48` 转成数字字符，否则 `u+55` 转成字母。
- 因为是从低位往高位生成的，最后要 `reverse` 回高位在前。

### 模块三：main 调用

```cpp
int main()
{
    long long n,m,sum=0;string sl;cin>>n>>sl>>m;
    sum=decin(n,sl);
    string re=decout(m,sum);
    cout<<re;
    return 0;
}
```

- 读入 $n$（原进制）、`sl`（$n$ 进制字符串）、$m$（目标进制）。
- 先用 `decin` 转成十进制中间值 `sum`，再用 `decout` 转成 $m$ 进制输出。

## 复杂度分析

- **时间复杂度**：$O(L)$，$L$ 为数字位数。`decin` 遍历一遍输入串，`decout` 的输出位数与 $L$ 同数量级。
- **空间复杂度**：$O(L)$，用于中间数组 `v` 和结果串 `rl`。

## 适用场景

- 给定进制互转的小规模题，比如把 $n$ 进制数转成 $m$ 进制输出。
- 进制只到 36（用 `A`~`Z` 表示 10~35）的场景，因为代码用 `+55` / `-55` 对应大写字母。

## 常见陷阱与注意事项

1. **权重用 `pow`**：`pow` 返回 `double`，位数一多会丢精度，大数场景建议改用高精度或整数快速幂。
2. **只认大写字母**：`sl[i]-55` 只覆盖 `A`~`Z`；若输入有小写字母要先转成大写。
3. **`decout` 没处理 0**：输入 0 时 `while(n)` 不进入循环，会返回空串；使用前最好特判 `n == 0`。
4. **翻转别忘**：`decout` 是从低位往高位生成的，不 `reverse` 得到的就是倒序结果。
5. **进制范围**：`n`、`m` 建议在 2~36 之间；小于 2 的进制没有意义。

## 对比与扩展

- **位数与类型**：想省事可以用 `std::stoi` / `sprintf` 之类，但它们只覆盖常见进制，且长度受 `int` / `long long` 限制。
- **高精度结合**：超大数的进制转换要先上高精度，否则中间十进制值会溢出。
- **扩展**：任意进制的小数转换、负数进制、以 $2^n$ 为基的进制可用位运算快速拆分与合并。$AKB2$, '基础算法', array['进制转换', '任意进制', '字符串', '枚举', '基础算法'], null, null, 'knowledge'),
('dbywsc', 'col-basic-bfs--dbywsc', 'BFS 广度优先搜索 · dbywsc', $AKB3$## 算法原理

BFS 按“距离由近到远”的顺序遍历状态空间，通常用队列实现：

1. 起点入队；
2. 取队首；
3. 枚举它能到达的下一状态；
4. 未访问的状态入队；
5. 队列为空或找到目标时停止。

BFS 适合边权相同（或边权为 1）的最短路。状态不只是坐标，还可以带方向、剩余次数、持有状态等附加信息。

### 状态设计：CF2041D Drunken Maze

题目在普通迷宫上增加了“不能连续往同一个方向走超过 $k$ 步”的限制。此时状态需要记录：

$$
\{x,\ y,\ last,\ cnt\}
$$

- $x,y$：当前位置；
- $last$：上一步的方向；
- $cnt$：在当前方向上已经连续走了多少步；
- 另外用 `dis` 记录步数。

初始状态为 $\{start_x,start_y,-1,0\}$。转移时枚举四个方向：

- 如果新方向与 `last` 相同，则 `cnt+1`，若超过限制则不能走；
- 如果方向不同，则 `cnt=1`。

`vis` 也要记录这四个属性，否则同一坐标不同方向/连续步数的状态会被错误去重。

### 状态压缩

直接开四维 `vis[x][y][last][cnt]` 在 $n,m$ 较大时容易 MLE。可以把状态编码成一个整数：

$$
id=((x\cdot m+y)\cdot4+last)\cdot4+cnt.
$$

这样 `vis` 只需要一维数组。编码时要保证每一维的进制足够大，避免不同状态撞在一起。

## 核心公式 / 状态定义与转移方程

- 状态：$(x,y,last,cnt)$。
- 转移：
  - 若 $d=last$：$cnt'=cnt+1$，要求 $cnt'\le k$；
  - 否则：$cnt'=1$；
  - 新状态 $(x',y',d,cnt')$，距离 $dis+1$。
- 访问标记：`vis[id]`，`id=((x*m+y)*4+d)*4+cnt`。
- 答案：第一次到达终点时的 `dis`；队列空仍未到达则无解。

## 逐行代码解析

```cpp
struct state {
    int x, y, last, cnt, dis;
};

int bfs(state start, int n, int m, vector<vector<char>>& G, int ex, int ey) {
    vector<int> vis(n * m * 4 * 4 + 1, 0);
    auto compress = [&](int x, int y, int d, int cnt) -> int {
        return (((x - 1) * m + (y - 1)) * 4 + d) * 4 + cnt;
    };

    queue<state> q;
    q.push(start);
    while (!q.empty()) {
        auto u = q.front();
        q.pop();
        if (u.x == ex && u.y == ey) return u.dis;

        for (int d = 0; d < 4; d++) {
            int nx = u.x + dx[d];
            int ny = u.y + dy[d];
            if (nx < 1 || nx > n || ny < 1 || ny > m || G[nx][ny] == '#') continue;

            int cnt = u.cnt;
            if (d == u.last) {
                if (u.cnt == 3) continue;   // 以 k=3 为例
                cnt++;
            } else {
                cnt = 1;
            }

            int id = compress(nx, ny, d, cnt);
            if (!vis[id]) {
                vis[id] = 1;
                q.push({nx, ny, d, cnt, u.dis + 1});
            }
        }
    }
    return -1;
}
```

- `state` 保存坐标、上一步方向、连续步数、距离。
- `vis` 用一维数组，`compress` 把四维状态压成一个整数。
- 坐标从 $1$ 开始，编码时先减 $1$；若直接用 `x*m+y`，`vis` 按 `n*m*4*4` 开会略小，可能越界。
- 同方向时检查连续步数上限；不同方向时重置为 $1$。
- 第一次到达终点就是最短步数；队列空返回 $-1$。
- 代码是原文节选，`dx` / `dy` 方向数组按你的模板补齐。

## 复杂度分析

- 状态数：$O(nm\cdot4\cdot k)$。
- 每个状态枚举四个方向，转移 $O(1)$，总时间 $O(nmk)$。
- 空间：`vis` 为 $O(nmk)$，队列最坏 $O(nmk)$。
- 若 $k$ 很小（如本题 $k\le3$），状态数约为 $O(nm)$。

## 适用场景

- 迷宫最短路、网格 BFS。
- 状态需要带方向、连续步数、剩余次数、持有物品等附加信息。
- 边权相同的最短路。
- 多源 BFS、01 BFS（边权 0/1）等变体。

## 常见陷阱与注意事项

1. **`vis` 只记坐标**：带方向/连续步数的状态必须把这些维度一起记，否则会错误去重。
2. **状态编码进制不够**：`cnt` 的上界、方向数、坐标范围要留够，否则不同状态可能编码相同。
3. **连续步数边界**：是“不能超过 $k$”还是“不能达到 $k$”，要看题目；代码里用 `u.cnt == 3` 是以 $k=3$ 为例。
4. **起点/终点标记**：起点和终点可能不是 `.`，判断障碍时不要把它们误判。
5. **队列元素过多**：状态数大时 BFS 可能 MLE，优先压缩状态或剪枝。
6. **多测清空**：`vis` 和队列在多组数据间要清空。
7. **方向数组**：`dx/dy` 要和题目坐标方向一致，尤其是行列从 0 还是 1 开始。

## 对比与扩展

- **BFS vs DFS**：BFS 求最短路、按层扩展；DFS 强调可达性、适合回溯/枚举。
- **普通 BFS vs 状态 BFS**：普通 BFS 状态是坐标；状态 BFS 把附加信息放进状态，`vis` 也要相应扩展。
- **BFS vs Dijkstra**：边权全 1 用 BFS；边权非负且不同用 Dijkstra；边权只有 0/1 用 0-1 BFS。
- **状态压缩**：四维 `vis` 可以压成一维整数，也可以使用 `map`/`set`，但数组编码通常更快。$AKB3$, '基础算法', array['BFS', '状态压缩', '迷宫', '队列', '搜索'], 'col-hub-basic-search', null, 'knowledge'),
('Fohen', 'col-basic-bfs--fenfeng', 'BFS 广度优先搜索 · Fohen', $AKB4$## 算法原理

广度优先搜索（BFS）是一种按照“距离由近到远”的顺序遍历状态空间的方法。它用一个队列维护待扩展的状态，逐层向外推进：

1. 将起点加入队列，并标记为已访问；
2. 每次取出队首状态；
3. 枚举它能一步到达的所有下一状态；
4. 把尚未访问过的状态加入队尾并标记；
5. 重复上述过程，直到队列为空或找到目标。

BFS 最重要的性质是：在所有边权相同的图中（通常指每走一步代价都是 $1$），BFS 第一次到达某个状态时，得到的就是起点到它的最短距离。因此普通 BFS 特别适合状态转移代价相同的搜索问题，例如迷宫最短路、连通块统计、层次遍历等。

## 核心公式 / 状态定义与转移方程

设 $dist[u]$ 表示从起点到状态 $u$ 的最短距离，$v$ 是 $u$ 能一步到达的邻接状态。当所有边的代价均为 $1$ 时，状态转移为：

$$
dist[v] = dist[u] + 1
$$

并且 $v$ 只有在**第一次被到达**时才入队，这正是“第一次到达即最短”的保证。

对于 01BFS（边权 $w \in \{0, 1\}$），改为松弛形式：

$$
dist[v] = \min(dist[v],\, dist[u] + w)
$$

其中 $w = 0$ 的边让新状态插入队首立即扩展，$w = 1$ 的边让新状态插入队尾按普通 BFS 处理。

对于多源 BFS，令所有源点的 $dist$ 初值均为 $0$ 并同时入队，转移方程不变，最终 $dist[x]$ 表示 $x$ 到“最近源点”的距离。

## 逐行代码解析

下面是 BFS 的通用伪代码（示意状态转移过程，并非完整可运行程序）：

```cpp
// 初始化
queue<State> q;
visited[start] = true;
dist[start] = 0;
q.push(start);

// 主循环：按层扩展
while (!q.empty()) {
    State u = q.front(); q.pop();
    for (每个能由 u 一步到达的 v) {
        if (visited[v]) continue;   // 已入过队，跳过
        visited[v] = true;          // 入队时立即标记
        dist[v] = dist[u] + 1;      // 第一次到达即最短距离
        q.push(v);
    }
}
```

要点：

- `visited` 与 `dist` 分离：`visited` 标记是否已入队，`dist` 记录最短距离。
- 必须在**入队时**标记 `visited`，而不是出队时；否则同一状态可能被多个前驱重复入队，既浪费时间也容易出错。
- 队列先进先出的特性保证出队顺序按距离非递减，这正是逐层遍历的来源。

01BFS 的核心差别只在入队方向（用双端队列 `deque` 代替普通队列）：

```cpp
if (dist[u] + w < dist[v]) {   // 发现更短距离才松弛
    dist[v] = dist[u] + w;
    if (w == 0) q.push_front(v);   // 0 边：插入队首立即扩展
    else        q.push_back(v);    // 1 边：插入队尾按正常 BFS 处理
}
```

## 复杂度分析

- **图 $G=(V,E)$**：每个状态最多入队一次，每条边最多被枚举一次，时间复杂度 $O(V+E)$；队列与 `dist`、`visited` 数组共占用 $O(V)$ 空间。
- **$n\times m$ 网格**：状态数 $V=nm$，每格最多 4 条出边，等价于 $O(nm)$ 时间、$O(nm)$ 空间。
- **多源 BFS / 01BFS**：本质上仍是每个状态、每条边处理常数次，复杂度保持线性于“状态数 + 边数”；01BFS 使用双端队列也不改变渐进复杂度。

## 适用场景

- 无权图或网格图上的最短路径（每步代价为 $1$）。
- 连通块统计与 Flood Fill（泛洪填充）。
- 树的层次遍历、计算每个节点的深度。
- 多源 BFS：求每个点到若干源点中最近一个的距离（例如 $01$ 矩阵中每个位置到最近的 `1` 的曼哈顿距离）。
- 01BFS：边权仅为 $0$ 或 $1$ 的最短路问题。
- 状态可枚举、单步代价为 $1$ 的隐式图搜索。

## 常见陷阱与注意事项

1. **入队时标记，而非出队时**：出队才标记会让同一节点被多个前驱重复入队，浪费时空且易产生错误结果。
2. **只有边权相同才保证最短**：普通 BFS 要求每步代价相同；一旦边权不等，就不能再用“第一次到达即最短”，应改用 Dijkstra 或 SPFA。
3. **多源 BFS 要同时入队**：必须把所有源点以 `dist = 0` 一起入队再统一扩展；若对每个源点单独跑一遍 BFS，复杂度会退化。
4. **01BFS 按松弛而非仅访问判断**：应写成“发现更短距离就更新”，不能只用一个 `visited` 布尔值判断是否处理过，否则可能漏掉更优路径；$0$ 边入队首、$1$ 边入队尾。
5. **网格注意越界与障碍**：方向数组要成对、正确，扩展前先判断边界和障碍。
6. **记录路径需前驱数组**：用 `pre` 记录“从哪来”，结束后从终点回溯到起点再反转。
7. **复杂度过高时换思路**：若逐源点 BFS 导致 $O((nm)^2)$，优先考虑多源 BFS 等技巧。

## 对比与扩展

| 算法 | 适用 | 时间复杂度 | 特点 |
|---|---|---|---|
| 单向 BFS | 无权图 / 网格最短路 | $O(V+E)$ | 按层扩展，第一次到达即最短 |
| DFS | 连通性、排列组合枚举、回溯 | $O(V+E)$ | 一条路走到底，不保证最短路 |
| Dijkstra | 非负权图最短路 | $O((V+E)\log V)$ | 优先队列贪心松弛 |
| 双向 BFS | 无权图且起终点已知 | $O(V+E)$ | 两端同时扩展，常数更优 |
| 01BFS | 边权仅为 $0/1$ | $O(V+E)$ | 双端队列：$0$ 边队首、$1$ 边队尾 |
| 多源 BFS | 多个源点的最短路 | $O(V+E)$ | 所有源点同时入队 |

扩展方向：

- **双向 BFS**：起点与终点同时向外扩展，两个搜索前沿相遇即得到答案。
- **01BFS 到边权 $2$**：可将边权 $2$ 拆成两条边权 $1$ 的边来维护，但拆点逻辑较复杂，在复杂度限制宽松的题目中往往不如 Dijkstra。
- **A\* 搜索**：在 BFS 基础上引入启发函数（如曼哈顿距离），优先扩展更接近目标的状态，适合大规模网格。
- **层次遍历的延伸**：BFS 按层访问的性质，也是 Dinic 分层图构建、AC 自动机 fail 指针按层构建等算法的底层工具。$AKB4$, '基础算法', array['搜索', '广度优先搜索', '最短路', '无权图', '队列'], 'col-hub-basic-search', null, 'knowledge'),
('Xesir', 'col-basic-bfs--xesir', 'BFS 广度优先搜索 · Xesir', $AKB5$## 算法原理

广度优先搜索（**BFS**）是一种按照"距离由近到远"的顺序遍历状态空间的方法。它通常使用队列维护待扩展状态：

1. 将起点加入队列；
2. 每次取出队首状态；
3. 枚举它能够到达的下一状态；
4. 将尚未访问过的状态加入队尾；
5. 重复直到队列为空或找到目标。

BFS 最重要的性质是：在**所有边权相同的图**中，BFS 第一次到达某个状态时，得到的就是起点到它的最短距离。这里的"边权相同"通常指每走一步代价都是 $1$。因此普通 BFS 特别适合状态转移代价相同的搜索问题，如迷宫最短路、处理连通块、层次遍历等。

## 逐行代码解析

### BFS 基本模板

```cpp
void bfs(int start) {
    queue<int> q;

    q.push(start);
    visited[start] = true;
    dist[start] = 0;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v : graph[u]) {
            if (visited[v]) continue;

            visited[v] = true;
            dist[v] = dist[u] + 1;
            q.push(v);
        }
    }
}
```

- 起点先入队，同时打上标记、距离置 0。
- 每次取队首 `u`，枚举它的所有邻点 `v`；已访问的 `continue` 跳过。
- **在入队时就标记**：`visited[v] = true`、`dist[v] = dist[u] + 1`，再 `q.push(v)`。
- 特别注意：应当在**入队时**标记访问，而不是出队时标记。若等出队才标记，同一个节点会被多个前驱重复加入队列，既浪费时间，也容易造成错误。

### 迷宫问题

**问题模型：** 给定一个网格

- `.` 表示可以通行；
- `#` 表示障碍物；
- 每次可以向上、下、左、右移动一格；
- 求起点到终点是否存在路径，或求最短步数。

把每个网格格子看作图中的一个节点，相邻且可以通行的格子之间连一条边。由于每移动一格的代价都为 $1$，所以可以直接使用 BFS。

```cpp
//最常见的迷宫，变式见A5034
#include <bits/stdc++.h>
using namespace std;
char h[700][700];
int st[150][150];
int n;
int dx[]={0,1,0,-1};int dy[]{1,0,-1,0};
void bfs(int ha,int la,int hb,int lb){
    queue<pair<int,int>> a;
    a.push({ha,la});
    while(a.size()){
        auto t=a.front();a.pop();
        if(t.first==hb&&t.second==lb){
            return;
        }
        for(int i=0;i<4;i++){
            int nx=dx[i]+t.first,ny=dy[i]+t.second;
            if(nx<1||nx>n||ny<1||ny>n){
                continue;
            }
            if(st[nx][ny]==-1&&h[nx][ny]=='.'){
                a.push({nx,ny});st[nx][ny]=st[t.first][t.second]+1;
            }
        }
    }
}
int main()
{
    int tk;cin>>tk;
    while(tk--){
        cin>>n;
            for(int i=1;i<=n;i++){
                for(int j=1;j<=n;j++){
                    cin>>h[i][j];st[i][j]=-1;
                }
            }
            int ha;int la;int hb;int lb;cin>>ha>>la>>hb>>lb;
            st[ha+1][la+1]=1;
            bfs(ha+1,la+1,hb+1,lb+1);
           if(st[hb+1][lb+1]!=-1&&h[ha+1][la+1]!='#')cout<<"YES"<<endl;
           else cout<<"NO"<<endl;
    }
    
return 0;
}
```

- `st` 既当访问标记又当距离：初值 `-1` 表示没到过，`st[nx][ny] = st[当前] + 1` 记录步数。
- `dx` / `dy` 是四方向偏移，越界就 `continue`。
- 到达终点直接 `return`（这里只判可达性，最短距离其实已经记在 `st` 里）。
- 读入的起点坐标在 main 里统一 `+1`（从 0 基转 1 基），扩展时也用同一套坐标。

### 记录最短路径

有时候题面不仅要求最短路径长度，还要求输出路径上的所有点。

设 `pre[x][y]` 表示到达 `(x,y)` 之前所在的位置。可以用一个坐标二元组记录：

```cpp
vector<vector<pair<int, int>>> pre(n, vector<pair<int, int>>(m, {-1, -1}));
```

访问新位置时：

```cpp
pre[nx][ny] = {x, y};
```

BFS 结束后，从终点不断沿 `pre` 回溯到起点，再将路径反转即可。

```cpp
vector<pair<int, int>> path;

if (dist[tx][ty] != -1) {
    int x = tx, y = ty;

    while (!(x == sx && y == sy)) {
        path.push_back({x, y});
        tie(x, y) = pre[x][y];
    }

    path.push_back({sx, sy});
    reverse(path.begin(), path.end());
}
```

- `pre[x][y]` 记录的是到达 `(x,y)` 的**前驱位置**。
- 扩展新位置时写 `pre[nx][ny] = {x, y}`。
- 回溯是从终点往回走，`path` 里是逆序的，最后 `reverse` 一把得到从起点到终点的正序路径。

### 泛洪填充

> 令 `1` 表示细胞，`0` 表示空地，上下左右相邻的细胞属于同一个区域，求区域数。

等价于给定一个网格，统计其中有多少个连通区域。解法是扫描整个网格：当前位置已访问就跳过；属于某个新连通块就把答案加一，从该位置开始 BFS，把整块全部标记。这类过程称为**泛洪填充**（Flood Fill）。BFS 只是实现泛洪的一种方式，也可以使用 DFS。

```cpp
//变式见P1362(C12),P1363(C12),P1364(C12)
#include <bits/stdc++.h>
using namespace std;
int cnt=0; 
int dx[]={-1,0,1,0};
int dy[]={0,-1,0,1};
char h[700][700]; 
int n,m;
void bfs(int x,int y) {
    queue<pair<int,int>> q; 
    q.push({x,y});          
    h[x][y]='0';        
    while (!q.empty()) {
        auto t=q.front(); 
        q.pop();                 
        for (int i=0;i<4;i++) {
            int nx=t.first+dx[i];
            int ny=t.second+dy[i];
            if(nx<1||nx>n||ny<1||ny>m||h[nx][ny]=='0')continue;
                q.push({nx,ny});      
                h[nx][ny]='0';    
        }
    }
}

int main() {
    cin>>n>>m;
    for (int i=1;i<=n;i++) {
        for(int j=1;j<=m;j++){
            cin>>h[i][j];
        }
    }
    for (int i=1;i<=n;i++) {
        for (int j=1;j<=m;j++) {
            if (h[i][j]!='0') {
                cnt++;
                bfs(i,j); 
            }
        }
    }
    cout<<cnt<<endl;
    return 0;
}
```

- 泛洪用 `h[x][y]='0'` **直接涂色**标记（起点和扩展点都涂成 `'0'`），省掉一个 visited 数组；BFS 里 `h[nx][ny]=='0'` 就跳过。
- main 双层循环扫过所有格子，`h[i][j]!='0'` 说明是没被涂过的新块，`cnt++` 并从这里 `bfs` 涂整块。
- 注意 main 的判断条件与 BFS 里的涂色要一致。

如果要统计当前连通块大小，可以在 BFS 中维护计数：

```cpp
int size = 0;

while (!q.empty()) {
    auto [x, y] = q.front();
    q.pop();
    ++size;

    // 扩展相邻位置
}
```

- 在出队（每个节点恰好被处理一次）时 `++size`，循环结束时 `size` 就是这一块的大小。

### 多源 BFS

> 给定一个 $01$ 矩阵，求每个位置到最近的 `1` 的曼哈顿距离。

如果对每个 `0` 分别做一次 BFS，最坏复杂度为 $O((nm)^2)$，通常无法接受。这时可以用**多源 BFS**：将所有 `1` 同时作为起点，一起放入同一个队列，同时向外扩展，其余同正常 BFS 即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
int n,m;
int h[1010][1010],st[1010][1010];
int dx[]={1,0,-1,0},dy[]={0,1,0,-1};
queue<pair<int,int>> q;
void bfs(){
    while(q.size()){
        auto t=q.front();q.pop();
        for(int i=0;i<4;i++){
            int nx=t.first+dx[i],ny=t.second+dy[i];
            if(nx<1||nx>n||ny<1||ny>m) continue;
            if(h[nx][ny]==1||st[nx][ny]!=0) continue;
            st[nx][ny]=st[t.first][t.second]+1;
            q.push({nx,ny});
        }
    }
}
int main(){
    ios::sync_with_stdio(0);
        cin.tie(0);
        cout.tie(0);
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        string a;cin>>a;
        for(int j=0;j<a.size();j++){
            h[i][j+1]=a[j]-48;
            
        }
        
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            if(h[i][j]==1)q.push({i,j});
        }
    }
    bfs();
    for(int i=1;i<=n;i++){
            for(int j=1;j<=m;j++){
                cout<<st[i][j]<<" ";
            }
            cout<<endl;
        }
}
```

- `q` 是全局队列；main 里把所有 `h[i][j]==1` 的点**一次性全部入队**，这就是"多源"。
- BFS 里 `st` 初值为 0，遇到 `h==1`（源）或 `st!=0`（已访问）就 `continue`，`st[nx][ny]=st[t]+1`。
- 于是每个非源点只会被"最近的源"先访问到，`st` 即为它到最近 `1` 的曼哈顿距离。

### 01BFS

普通 BFS 要求每条边的代价相同。如果边的权值可能是 `0` 或 `1`，就不能简单地认为"走一步距离加一"。一些经典模型如：经过普通道路代价为 $1$；改变方向、破坏墙壁或使用传送门代价为 $0$。这时候就要用到 **01BFS**，它专门处理边权为 `0` 和 `1` 的图论 / 迷宫问题。

普通 BFS 使用队列 `queue`，只支持在末尾添加元素，实在是太拉了。01BFS 就不一样了，它的底层是**双端队列** `deque`，可以在首尾添加与删除元素，显然能实现的功能要比 BFS 强。

逻辑非常简单：`0` 边扩展没有代价，直接把它添加到**队首**立即扩展；反之 `1` 边扩展有代价，按正常 BFS 逻辑加到**队尾**。这样就在保持 BFS"第一次到时即最短距离"性质的同时处理了 `0/1` 边权，复杂度还是 $O(n)$（$n$ 为状态空间数），非常优秀。

代码也不难写，这里先只给特殊处理部分：

```cpp
if (dist[u] + w < dist[v]) {
    dist[v] = dist[u] + w;

    if (w == 0) {
        q.push_front(v);
    } else {
        q.push_back(v);
    }
}
```

- **注：** 01BFS 应在发现更短距离时进行松弛，一般不能仅使用 `visited` 判断是否处理过。
- 补充：对于存在边权为 `2` 的图也可以用 01BFS 解决，方法是将 `2` 边权拆点变成两条边权 `1` 维护。拆点的逻辑一般比较复杂，在一些复杂度限制低的题目中还不如 Dijkstra。01BFS 还是只留给 `0-1` 图比较好。

## 复杂度分析

- **图 $G=(V,E)$**：每个状态最多入队一次，每条边最多被枚举一次，时间复杂度 $O(V+E)$；队列与 `visited` / `dist` 数组共占用 $O(V)$ 空间。
- **$n \times m$ 网格**：状态数 $V=nm$，每格最多 4 条出边，等价于 $O(nm)$ 时间、$O(nm)$ 空间。
- **多源 BFS / 01BFS**：本质上仍是每个状态、每条边处理常数次，复杂度保持线性；01BFS 换成双端队列不改变渐进复杂度。

## 适用场景

- 无权图或网格图上的最短路径（每步代价为 $1$）。
- 连通块统计与泛洪填充（Flood Fill）。
- 树的层次遍历、计算每个节点的深度。
- 多源 BFS：求每个点到若干源点中最近一个的距离（如 $01$ 矩阵中每个位置到最近 `1` 的曼哈顿距离）。
- 01BFS：边权仅为 `0` 或 `1` 的最短路问题。
- 状态可枚举、单步代价为 $1$ 的隐式图搜索。

## 常见陷阱与注意事项

1. **入队时标记，而非出队时**：出队才标记会让同一节点被多个前驱重复入队，浪费时空且易产生错误结果。
2. **只有边权相同才保证最短**：普通 BFS 要求每步代价相同；一旦边权不等，就不能再用"第一次到达即最短"，应改用 Dijkstra 或 SPFA。
3. **多源 BFS 要同时入队**：必须把所有源点以 `dist = 0` 一起入队再统一扩展；若对每个源点单独跑一遍 BFS，复杂度会退化。
4. **01BFS 按松弛而非仅访问判断**：应写成"发现更短距离就更新"，不能只用一个 `visited` 布尔值判断是否处理过；`0` 边入队首、`1` 边入队尾。
5. **网格注意越界与障碍**：方向数组要成对、正确，扩展前先判断边界和障碍。
6. **记录路径需前驱数组**：用 `pre` 记录"从哪来"，结束后从终点回溯到起点再反转。
7. **起点坐标的 0 基 / 1 基换算**：迷宫模板里读入后统一 `+1`，接线时别漏，否则会错位。

## 对比与扩展

| 算法 | 适用 | 时间复杂度 | 特点 |
|---|---|---|---|
| 单向 BFS | 无权图 / 网格最短路 | $O(V+E)$ | 按层扩展，第一次到达即最短 |
| DFS | 连通性、排列枚举、回溯 | $O(V+E)$ | 一条路走到底，不保证最短路 |
| Dijkstra | 非负权图最短路 | $O((V+E)\log V)$ | 优先队列贪心松弛 |
| 双向 BFS | 无权图且起终点已知 | $O(V+E)$ | 两端同时扩展，常数更优 |
| 01BFS | 边权仅为 $0/1$ | $O(V+E)$ | 双端队列：$0$ 边队首、$1$ 边队尾 |
| 多源 BFS | 多个源点的最短路 | $O(V+E)$ | 所有源点同时入队 |

扩展方向：

- **双向 BFS**：起点与终点同时向外扩展，两个搜索前沿相遇即得到答案。
- **01BFS 到边权 $2$**：可将边权 $2$ 拆成两条边权 $1$ 的边来维护，但拆点逻辑较复杂，在复杂度限制宽松的题目中往往不如 Dijkstra。
- **A\* 搜索**：在 BFS 基础上引入启发函数（如曼哈顿距离），优先扩展更接近目标的状态，适合大规模网格。
- **层次遍历的延伸**：BFS 按层访问的性质，也是 Dinic 分层图构建、AC 自动机按 fail 指针按层构建等算法的底层工具。

一句话总结：BFS 的核心是"用队列按距离由近到远逐层扩展"，边权相同时第一次到达即最短；配合多源与 01BFS 两种变形，能覆盖一大类无权 / 小边权最短路问题。$AKB5$, '基础算法', array['搜索', '广度优先搜索', '最短路', '队列', '泛洪填充', '01BFS'], 'col-hub-basic-search', null, 'knowledge'),
('world-needs-sunday', 'col-basic-bfs-bidirectional', '双向 BFS（双向广度优先搜索）', $AKB6$## 算法原理

双向 BFS 是对普通单源 BFS 的优化，核心思想是**从起点和终点同时开始 BFS**，当两个搜索前沿相遇时立即返回答案。

### 单向 BFS 的瓶颈

普通 BFS 从起点出发，逐层扩展，直到访问到终点。设起点到终点的最短路径长度为 $d$，则单向 BFS 需要扩展半径为 $d$ 的整个"圆"内的所有节点，访问量约为 $O(d^2)$（网格图上）。

### 双向 BFS 的优化

双向 BFS 从起点和终点各扩展一步，两个搜索前沿相向而行。当两个前沿在中间某处相遇时，即可得到最短路径。此时每侧只需扩展半径约 $d/2$ 的区域，总访问量约为 $O((d/2)^2) \times 2 = O(d^2/2)$，理论减半。

实际上优化幅度取决于图的形状：在"狭长通道"型地图中，单向 BFS 扩展的扇形区域远大于路径本身，双向 BFS 可减少大量无效扩展。

### 实现关键：vis 三值标记

本代码用一个 `vis` 数组同时区分两个 BFS 的访问区域：

| vis 值 | 含义 |
|---------|------|
| 0 | 未访问 |
| 1 | 起点侧 BFS 访问 |
| 2 | 终点侧 BFS 访问 |

当扩展到的邻居 `vis[tx][ty]` 与当前点 `vis[cur]` **相同**时（都为 1 或都为 2），说明是同一侧已访问过的点，跳过。当两者**相加为 3**（$1 + 2 = 3$）时，说明两侧 BFS 相遇，找到最短路径。

## 核心公式/状态定义与转移方程

### 距离定义

设 $A[x][y]$ 为点 $(x,y)$ 到其对应源点（起点或终点）的距离：

$$A[x][y] = \begin{cases} 0 & \text{if } (x,y) \text{ 是起点或终点} \\ A[\text{prev}][\text{prev}] + 1 & \text{otherwise} \end{cases}$$

### 相遇条件

当从当前点 $(x_1, y_1)$（vis 值为 $v_1$）扩展到邻居 $(x_2, y_2)$（vis 值为 $v_2$）时：

$$\text{相遇} \iff v_1 + v_2 = 3 \quad (v_1 \in \{1, 2\},\; v_2 \in \{2, 1\})$$

### 最短路径长度

相遇时：

$$d = A[x_1][y_1] + A[x_2][y_2] + 1$$

其中 $A[x_1][y_1]$ 是当前点到其源点的距离，$A[x_2][y_2]$ 是邻居到其源点的距离，$+1$ 是连接两者的这条边。

### 正确性

BFS 按层扩展，两个搜索前沿各自维护到源点的最短距离。当两个前沿首次相遇时，相遇点恰好将最短路径分成两段，两段各自是最短的（BFS 性质保证），因此拼接后即为全局最短。

## 逐行代码解析

### 全局变量与方向数组

```cpp
vector<vector<char>> T;
int f_x[4] = { 1,-1,0,0 };
int f_y[4] = { 0,0,1,-1 };
```

- `T`：网格地图，`'#'` 不可走，`'.'` 可走
- `f_x/f_y`：四方向偏移（下、上、右、左）

### BFS 函数签名

```cpp
int bfs(pair<int,int> begin_pos, pair<int,int> end_pos, int n, int m)
```

参数为起点、终点、网格行列数，返回最短路径长度（不可达返回 -1）。

### 初始化

```cpp
vector<pair<int, int>> que(n * m + 10);
int l = 0, r = 0;
vector<vector<short>> vis(n + 1, vector<short>(m + 1, 0));
vector<vector<int>> A(n + 1, vector<int>(m + 1, INT_MAX));
```

- `que`：手写队列，容量 `n*m+10` 保证不溢出
- `vis`：三值标记数组（0=未访问，1=起点侧，2=终点侧）
- `A`：距离数组，初始为 `INT_MAX`

### 双源入队

```cpp
que[r++] = begin_pos;
vis[begin_pos.first][begin_pos.second] = 1;
A[begin_pos.first][begin_pos.second] = 0;

que[r++] = end_pos;
vis[end_pos.first][end_pos.second] = 2;
A[end_pos.first][end_pos.second] = 0;
```

将起点（vis=1，距离=0）和终点（vis=2，距离=0）先后入队。两个源点在同一个队列中，BFS 交替扩展（实际上是按入队顺序逐个出队）。

### 主循环

```cpp
while (l < r)
{
    pair<int, int> tmp = que[l++];
```

标准 BFS 出队，`l` 为队头指针，`r` 为队尾指针。

### 邻居扩展与跳过条件

```cpp
for (int i = 0; i < 4; i++)
{
    int tx = tmp.first + f_x[i];
    int ty = tmp.second + f_y[i];
    if (tx < 1 || tx > n || ty < 1 || ty > m 
        || vis[tmp.first][tmp.second] == vis[tx][ty] 
        || T[tx][ty] == '#') continue;
```

跳过条件（短路求值顺序）：
1. 越界检查
2. 同侧已访问：`vis[cur] == vis[neighbor]`（都为 1 或都为 2）
3. 障碍物检查

### 相遇检测

```cpp
if (vis[tmp.first][tmp.second] + vis[tx][ty] == 3)
{
    return A[tmp.first][tmp.second] + A[tx][ty] + 1;
}
```

vis 和为 3（$1+2$ 或 $2+1$）说明两侧相遇，返回 `当前点距离 + 邻居距离 + 1`。

### 标记与入队

```cpp
vis[tx][ty] = vis[tmp.first][tmp.second];
A[tx][ty] = A[tmp.first][tmp.second] + 1;
que[r++] = pair<int, int>(tx, ty);
```

将邻居标记为**与当前点相同侧**（vis 值继承），距离=当前距离+1，入队。

### 主函数

```cpp
if (a == b) cout << 0;
else cout << bfs(a, b, n, m);
```

特判起点等于终点的情况，避免误返回 -1。

## 复杂度分析

### 时间复杂度

$$T(n, m) = O(n \times m)$$

每个格子最多被访问一次（被某一侧标记后不再被同侧扩展）。与单向 BFS 的渐进复杂度相同，但常数更小——双向扩展使搜索范围从半径 $d$ 的圆缩小为两个半径 $d/2$ 的圆。

### 空间复杂度

$$S(n, m) = O(n \times m)$$

队列、vis 数组、距离数组各占 $O(nm)$。vis 用 `short` 节省空间（值域仅 0/1/2）。

### 与单向 BFS 的对比

| 指标 | 单向 BFS | 双向 BFS |
|------|----------|----------|
| 渐进复杂度 | $O(nm)$ | $O(nm)$ |
| 实际访问量 | 扩展半径 $d$ 的圆 | 扩展两个半径 $d/2$ 的圆 |
| 最优情况 | — | 起点终点距离远时优化显著 |
| 最差情况 | — | 起点终点相邻时退化（两圆重叠） |

## 适用场景

### 适用

- **无权图/网格图最短路**：求两点间最少步数
- **起点终点已知的单源单汇最短路**：不同于 Dijkstra 需要单源到所有点，双向 BFS 只需两点的最短路
- **网格规模大但路径长度有限**：如 $1000 \times 1000$ 网格中两点距离 50，双向 BFS 只需扩展约 $2 \times 50^2 = 5000$ 个格子
- **迷宫问题**：求起点到出口的最短步数

### 不适用

- **带权图**：边权不等时 BFS 不保证最短，应用 Dijkstra
- **需要所有点到起点距离**：双向 BFS 只给出两点的距离，不提供完整的距离数组
- **起点或终点不固定**：如多源最短路应从所有源同时单向 BFS
- **需要路径还原**：本代码只返回距离，不记录路径（可扩展 prev 数组实现）

## 常见陷阱与注意事项

1. **起点等于终点**：必须在调用 BFS 前特判，否则可能返回 -1（因为两个源点入队后，BFS 不会检测到"相遇"——它们的 vis 值 1+2=3 但不是通过扩展相遇的）

2. **vis 数组类型**：用 `short` 而非 `bool`，因为需要存储 0/1/2 三个值。`bool` 只能 0/1，会导致同侧判断和相遇检测出错

3. **同侧跳过条件**：`vis[cur] == vis[neighbor]` 必须在相遇检测之前判断，否则会把同侧点误判为相遇。短路求值中越界检查在最前面，避免数组越界

4. **队列容量**：手写队列容量设为 `n*m+10`，确保所有格子入队不溢出。若用 `std::queue` 无此问题但速度略慢

5. **距离初始化**：`A` 数组初始为 `INT_MAX`，未访问点的距离保持 `INT_MAX`。相遇时只读取已被赋值的点，不会访问到 `INT_MAX`

6. **起点终点不可达**：BFS 遍历完所有可达格子后队列空，返回 -1。调用方需处理 -1 的情况

7. **方向数组顺序**：不影响正确性，但影响扩展顺序。本代码按下、上、右、左顺序，可根据具体题目调整

## 对比与扩展

| 算法 | 适用图 | 时间复杂度 | 特点 |
|------|--------|------------|------|
| 单向 BFS | 无权图/网格 | $O(V+E)$ | 简单通用，扩展完整圆 |
| 双向 BFS | 无权图/网格 | $O(V+E)$ | 两源相向扩展，常数更优 |
| Dijkstra | 非负权图 | $O((V+E)\log V)$ | 支持任意非负边权 |
| A* 搜索 | 带启发函数 | 取决于启发函数 | 启发函数指导下定向搜索 |

### 扩展方向

- **路径还原**：增加 `prev` 数组记录前驱节点，相遇后从两端回溯拼接路径
- **双向 Dijkstra**：将双向 BFS 推广到带权图，两侧各用优先队列扩展，相遇时取最小
- **A\* 搜索**：在 BFS 基础上引入启发函数（如曼哈顿距离），优先扩展更接近终点的节点，适合大规模网格
- **多源 BFS**：多个源点同时入队，求所有点到最近源点的距离——这是双向 BFS 的"多向"推广$AKB6$, '基础算法', array['基础算法', '搜索', 'BFS', '双向BFS', '最短路', '网格图'], 'col-hub-basic-search', null, 'knowledge'),
('stripe-python', 'col-basic-big-integer-library--stripe-python', 'BigInteger 3.0 大整数库 · stripe-python', $AKB7$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 更新

在一年前，我编写了 [BigInteger2 项目](https://www.luogu.com.cn/article/p6un33cl)。BigInteger3.0 对 BigInteger2 进行了重构，主要更新是将动态分配空间改为 std::vector 自动分配空间，并将实现精细化。

由于之后的更新不希望文章重新审核，因此可到 [剪贴板](https://www.luogu.com.cn/paste/cm3zdwy5) 查看。

```cpp
/*
  BigInteger.h (Version 3.0)
  stripe-python https://www.luogu.com.cn/user/928879
 */

#ifndef BIGINTEGER_H
#define BIGINTEGER_H
#define BIGINTERGER_VERSION (3.0)

#include <algorithm>
#include <cmath>
#include <climits>
#include <chrono>
#include <cstdint>
#include <functional>
#include <iomanip>
#include <sstream>
#include <random>
#include <vector>
#if __cplusplus >= 202002L
#include <compare>
#endif

class ZeroDivisionError : public std::exception {
public:
	const char* what() const throw() {return "Division is zero";}
};
class FFTLimitExceededError : public std::exception {
public:
	const char* what() const throw() {return "FFT limit exceeded";}
};
class NegativeRadicandError : public std::exception {
public:
	const char* what() const throw() {return "Radicand is negative";}
};

// The constants
using digit_t = int64_t;
constexpr int WIDTH = 8;
constexpr digit_t BASE = 1e8;
constexpr int FFT_LIMIT = 8;
constexpr int NEWTON_DIV_MIN_LEVEL = 8;
constexpr int NEWTON_DIV_LIMIT = 32;
constexpr int NEWTON_SQRT_LIMIT = 48;
constexpr int NEWTON_SQRT_MIN_LEVEL = 6;
static_assert(NEWTON_DIV_MIN_LEVEL < NEWTON_DIV_LIMIT);
static_assert(NEWTON_SQRT_MIN_LEVEL < NEWTON_SQRT_LIMIT);

struct BigInteger {
protected:
	std::vector<digit_t> digits;
	bool flag;
	BigInteger(const std::vector<digit_t>& v)
	: digits(v.begin(), v.end()), flag(true) {trim();}

	BigInteger& trim() {  // Remove the leading zeros
		while (digits.size() > 1U && digits.back() == 0) digits.pop_back();
		return *this;
	}
	digit_t operator[] (int x) const {return x < (int) digits.size() ? digits[x] : 0;}

	BigInteger& build_binary(const std::vector<bool>&);

	static BigInteger fft_mul(const BigInteger&, const BigInteger&);
	BigInteger newton_inv(int n) const;
	BigInteger sqrt_normal() const;
	BigInteger newton_invsqrt() const;
public:
	BigInteger() : flag(true) {digits.emplace_back(0);}
	BigInteger(const BigInteger& x) {*this = x;}
	BigInteger(const int64_t& x) {*this = x;}
	BigInteger(const std::string& s) {*this = s;}
	BigInteger(const std::vector<bool>& v) {*this = v;}

	BigInteger& operator= (const BigInteger&);
	BigInteger& operator= (const int64_t&);
	BigInteger& operator= (const std::string&);
	BigInteger& operator= (const std::vector<bool>&);

	std::string to_string() const;
	int64_t to_int64() const;
	std::vector<bool> to_binary() const;
#ifdef __SIZEOF_INT128__
	BigInteger& from_int128(const __int128&);
	__int128 to_int128() const;
#endif  // __SIZEOF_INT128__

	// I/O operations
	friend std::ostream& operator<< (std::ostream& out, const BigInteger& x) {
		if (!x.flag) out << '-';
		out << x.digits.back();
		int n = x.digits.size();
		for (int i = n - 2; i >= 0; i--) out << std::setw(WIDTH) << std::setfill('0') << x.digits[i];
		return out;
	}
	friend std::istream& operator>> (std::istream& in, BigInteger& x) {
		std::string s;
		return in >> s, x = s, in;
	}

	bool zero() const {return digits.size() == 1 && digits[0] == 0;}
	bool operator! () const {return digits.size() != 1 || digits[0] != 0;}
	bool positive() const {return flag && !zero();}
	bool negative() const {return !flag;}
	int _digit_len() const {return digits.size();}

	BigInteger _move_l(int) const;
	BigInteger _move_r(int) const;

	int compare(const BigInteger&) const;
	bool operator== (const BigInteger&) const;
#if __cplusplus >= 202002L
	std::strong_ordering operator<=> (const BigInteger&) const;
#else
	bool operator< (const BigInteger&) const;
	bool operator> (const BigInteger&) const;
	bool operator!= (const BigInteger&) const;
	bool operator<= (const BigInteger&) const;
	bool operator>= (const BigInteger&) const;
#endif   // __cplusplus >= 202002L

	BigInteger operator- () const;
	BigInteger operator~ () const;
	BigInteger abs() const;

	BigInteger& operator+= (const BigInteger&);
	BigInteger operator+ (const BigInteger&) const;
	BigInteger& operator++ ();
	BigInteger operator++ (int);

	BigInteger& operator-= (const BigInteger&);
	BigInteger operator- (const BigInteger&) const;
	BigInteger& operator-- ();
	BigInteger operator-- (int);

	BigInteger& operator*= (const BigInteger&);
	BigInteger operator* (const BigInteger&) const;
	BigInteger square() const;
	BigInteger& operator*= (int32_t);
	BigInteger operator* (const int32_t&) const;

	BigInteger half() const;
	BigInteger& operator/= (int64_t);
	BigInteger operator/ (const int64_t&) const;
	std::pair<BigInteger, BigInteger> divmod(const BigInteger&) const;
	BigInteger operator/ (const BigInteger&) const;
	BigInteger& operator/= (const BigInteger&);
	BigInteger operator% (const BigInteger&) const;
	BigInteger& operator%= (const BigInteger&);
	bool mod2() const {return digits[0] & 1;}

	BigInteger pow(int64_t) const;
	BigInteger pow(int64_t, const BigInteger&) const;

	BigInteger sqrt() const;
	BigInteger root(const int64_t&) const;

	BigInteger gcd(BigInteger) const;
	BigInteger lcm(const BigInteger&) const;

	BigInteger operator<< (const int64_t&) const;
	BigInteger operator>> (const int64_t&) const;
	BigInteger& operator<<= (const int64_t&);
	BigInteger& operator>>= (const int64_t&);

	BigInteger operator& (const BigInteger&) const;
	BigInteger operator| (const BigInteger&) const;
	BigInteger operator^ (const BigInteger&) const;
	BigInteger& operator&= (const BigInteger&);
	BigInteger& operator|= (const BigInteger&);
	BigInteger& operator^= (const BigInteger&);
};

BigInteger& BigInteger::operator= (const BigInteger& x) {
	flag = x.flag, digits = std::vector<digit_t>(x.digits.begin(), x.digits.end());
	return *this;
}
BigInteger& BigInteger::operator= (const int64_t& x) {
	if (x == LLONG_MIN) return *this = "-9223372036854775808";
	digits.clear(), flag = (x >= 0), digits.reserve(4);
	if (x == 0) return digits.emplace_back(0), *this;
	int64_t n = std::abs(x);
	do {digits.emplace_back(n % BASE), n /= BASE;} while (n);
	return *this;
}
BigInteger& BigInteger::operator= (const std::string& s) {
	digits.clear(), flag = true, digits.reserve(s.size() / WIDTH + 1);
	if (s.empty() || s == "-") return *this = 0;
	int n = s.size(), i = 0;
	while (i < n && s[i] == '-') flag ^= 1, i++;
	for (int j = s.size() - 1; j >= i; j -= WIDTH) {
		int start = std::max(i, j - WIDTH + 1), len = j - start + 1;
		digits.emplace_back(std::stoll(s.substr(start, len)));
	}
	return trim();
}
BigInteger& BigInteger::build_binary(const std::vector<bool>& v) {
	BigInteger k = 1;
	for (int i = v.size() - 1; i >= 0; i--, k += k) {
		if (v[i]) *this += k;
	}
	return *this;
}
BigInteger& BigInteger::operator= (const std::vector<bool>& v) {
	*this = 0;
	if (v.empty()) return *this;
	if (!v[0]) return build_binary(v);
	int n = v.size();
	std::vector<bool> b(n);
	for (int i = 0; i < n; i++) b[i] = v[i] ^ 1;
	build_binary(b);
	return *this = ~(*this);
}

std::string BigInteger::to_string() const {  // Convert to std::string
	std::stringstream stream;
	return stream << *this, stream.str();
}
int64_t BigInteger::to_int64() const {   // Convert to int64_t
	int64_t res = 0;
	for (int i = digits.size() - 1; i >= 0; i--) res = res * BASE + digits[i];
	return res;
}
std::vector<bool> BigInteger::to_binary() const {
	if (zero()) return {0};
	std::vector<bool> res;
	if (flag) {
		for (BigInteger x = *this; !x.zero(); x = x.half()) res.emplace_back(x.mod2());
		res.emplace_back(0);
	} else {
		for (BigInteger x = ~(*this); !x.zero(); x = x.half()) res.emplace_back(x.mod2() ^ 1);
		res.emplace_back(1);
	}
	std::reverse(res.begin(), res.end());
	return res;
}

#ifdef __SIZEOF_INT128__
// Support the operations of __int128
BigInteger& BigInteger::from_int128(const __int128& x) {  // Build from __int128
	digits.clear(), flag = (x >= 0), digits.reserve(8);
	if (x == 0) return digits.emplace_back(0), *this;
	__int128 n = (x < 0 ? -x : x);
	do {digits.emplace_back(n % BASE), n /= BASE;} while (n);
	return *this;
}
__int128 BigInteger::to_int128() const {  // Convert to __int128
	__int128 res = 0;
	for (int i = digits.size() - 1; i >= 0; i--) res = res * BASE + digits[i];
	return res;
}
#endif  // __SIZEOF_INT128__

BigInteger BigInteger::_move_l(int x) const {
	std::vector<digit_t> res(x, 0);
	for (const digit_t& i : digits) res.emplace_back(i);
	return res;
}
BigInteger BigInteger::_move_r(int x) const {
	return std::vector<digit_t>(digits.begin() + x, digits.end());
}

int BigInteger::compare(const BigInteger& x) const {
	if (flag && !x.flag) return 1;
	if (!flag && x.flag) return -1;
	int sgn = (flag && x.flag ? 1 : -1);
	int n = digits.size(), m = x.digits.size();
	if (n > m) return sgn;
	if (n < m) return -sgn;
	for (int i = n - 1; i >= 0; i--) {
		if (digits[i] > x.digits[i]) return sgn;
		if (digits[i] < x.digits[i]) return -sgn;
	} return 0;
}
bool BigInteger::operator== (const BigInteger& x) const {return compare(x) == 0;}
#if __cplusplus >= 202002L
std::strong_ordering BigInteger::operator<=> (const BigInteger& x) const {
	int type = compare(x);
	if (type == 0) return std::strong_ordering::equal;
	return type > 0 ? std::strong_ordering::greater : std::strong_ordering::less;
}
#else
bool BigInteger::operator< (const BigInteger& x) const {return compare(x) < 0;}
bool BigInteger::operator> (const BigInteger& x) const {return compare(x) > 0;}
bool BigInteger::operator!= (const BigInteger& x) const {return compare(x) != 0;}
bool BigInteger::operator<= (const BigInteger& x) const {return compare(x) <= 0;}
bool BigInteger::operator>= (const BigInteger& x) const {return compare(x) >= 0;}
#endif   // __cplusplus >= 202002L

BigInteger BigInteger::operator- () const {
	BigInteger res = *this;
	return res.flag ^= 1, res;
}
BigInteger BigInteger::operator~ () const {return -(*this) - 1;}
BigInteger BigInteger::abs() const {
	BigInteger res = *this;
	return res.flag = true, res;
}

BigInteger& BigInteger::operator+= (const BigInteger& x) {
	if (x.negative()) return *this -= x.abs();
	if (this->negative()) return *this = x - this->abs();
	(flag ^= x.flag) ^= 1;
	int n = std::max(digits.size(), x.digits.size()) + 1;
	digit_t carry = 0;
	for (int i = 0; i < n; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] += x[i] + carry;
		if (digits[i] >= BASE) carry = 1, digits[i] -= BASE;
		else carry = 0;
	}
	return trim();
}
BigInteger BigInteger::operator+ (const BigInteger& x) const {
	return BigInteger(*this) += x;
}
BigInteger& BigInteger::operator++ () {return *this += 1;}
BigInteger BigInteger::operator++ (int) {
	BigInteger t = *this;
	return *this += 1, t;
}

BigInteger& BigInteger::operator-= (const BigInteger& x) {
	if (x.negative()) return *this += x.abs();
	if (this->negative()) return *this = -(x + this->abs());
	flag = (*this >= x);
	int n = std::max(digits.size(), x.digits.size());
	digit_t carry = 0;
	for (int i = 0; i < n; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] = flag ? (digits[i] - x[i] - carry) : (x[i] - digits[i] - carry);
		if (digits[i] < 0) digits[i] += BASE, carry = 1;
		else carry = 0;
	} return trim();
}
BigInteger BigInteger::operator- (const BigInteger& x) const {
	return BigInteger(*this) -= x;
}
BigInteger& BigInteger::operator-- () {return *this -= 1;}
BigInteger BigInteger::operator-- (int) {
	BigInteger t = *this;
	return *this -= 1, t;
}

namespace __FFT {  // FFT implementation for faster multiplication
	constexpr long long FFT_BASE = 1e4;
	constexpr double PI2 = 6.283185307179586231995927;
	constexpr double PI6 = 18.84955592153875869598778;
	constexpr int RBASE = 1023;  // The frequency of recalculate the unit roots, must be 2^k-1
	struct complex {
		double real, imag;
		complex(double x = 0.0, double y = 0.0) : real(x), imag(y) {}
		complex operator+ (const complex& other) const {return complex(real + other.real, imag + other.imag);}
		complex operator- (const complex& other) const {return complex(real - other.real, imag - other.imag);}
		complex operator* (const complex& other) const {return complex(real * other.real - imag * other.imag,
			real * other.imag + other.real * imag);}
		complex& operator+= (const complex& other) {return real += other.real, imag += other.imag, *this;}
		complex& operator-= (const complex& other) {return real -= other.real, imag -= other.imag, *this;}
		complex& operator*= (const complex& other) {return *this = *this * other;}
		inline complex conj() const {return complex(imag, -real);}
	};
	template <const int n> inline void fft(complex* a) {
		const int n2 = n >> 1, n4 = n >> 2;
		complex w(1.0, 0.0), w3(1.0, 0.0);
		const complex wn(std::cos(PI2 / n), std::sin(PI2 / n)), wn3(std::cos(PI6 / n), std::sin(PI6 / n));
		for (int i = 0; i < n4; i++, w *= wn, w3 *= wn3) {
			if (!(i & RBASE)) w = complex(std::cos(PI2 * i / n), std::sin(PI2 * i / n)), w3 = w * w * w;
			complex x = a[i] - a[i + n2], y = a[i + n4] - a[i + n2 + n4];
			y = y.conj(), a[i] += a[i + n2], a[i + n4] += a[i + n2 + n4];
			a[i + n2] = (x - y) * w, a[i + n2 + n4] = (x + y) * w3;
		} fft<n2>(a), fft<n4>(a + n2), fft<n4>(a + n2 + n4);
	}
	template <> inline void fft<0>(complex*) {}
	template <> inline void fft<1>(complex*) {}
	template <> inline void fft<2>(complex* a) {complex x = a[0], y = a[1]; a[0] += y, a[1] = x - y;}
	template <> inline void fft<4>(complex* a) {
		complex a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], x = a0 - a2, y = a1 - a3;
		y = y.conj(), a[0] += a2, a[1] += a3, a[2] = x - y, a[3] = x + y;
		fft<2>(a);
	}
	template <const int n> inline void ifft(complex* a) {
		const int n2 = n >> 1, n4 = n >> 2;
		ifft<n2>(a), ifft<n4>(a + n2), ifft<n4>(a + n2 + n4);
		complex w(1.0, 0.0), w3(1.0, 0.0);
		const complex wn(std::cos(PI2 / n), -std::sin(PI2 / n)), wn3(std::cos(PI6 / n), -std::sin(PI6 / n));
		for (int i = 0; i < n4; i++, w *= wn, w3 *= wn3) {
			if (!(i & RBASE)) w = complex(std::cos(PI2 * i / n), -std::sin(PI2 * i / n)), w3 = w * w * w;
			complex p = w * a[i + n2], q = w3 * a[i + n2 + n4];
			complex x = a[i], y = p + q, x1 = a[i + n4], y1 = p - q;
			y1 = y1.conj(), a[i] += y, a[i + n4] += y1, a[i + n2] = x - y, a[i + n2 + n4] = x1 - y1;
		}
	}
	template <> inline void ifft<0>(complex*) {}
	template <> inline void ifft<1>(complex*) {}
	template <> inline void ifft<2>(complex* a) {complex x = a[0], y = a[1]; a[0] += y, a[1] = x - y;}
	template <> inline void ifft<4>(complex* a) {
		ifft<2>(a);
		complex p = a[2], q = a[3], x = a[0], y = p + q, x1 = a[1], y1 = p - q;
		y1 = y1.conj(), a[0] += y, a[1] += y1, a[2] = x - y, a[3] = x1 - y1;
	}
	inline void dft(complex* a, int n) {
		if (n <= 1) return;
		switch (n) {
			case 1<<2:fft<1<<2>(a);break;
			case 1<<3:fft<1<<3>(a);break;
			case 1<<4:fft<1<<4>(a);break;
			case 1<<5:fft<1<<5>(a);break;
			case 1<<6:fft<1<<6>(a);break;
			case 1<<7:fft<1<<7>(a);break;
			case 1<<8:fft<1<<8>(a);break;
			case 1<<9:fft<1<<9>(a);break;
			case 1<<10:fft<1<<10>(a);break;
			case 1<<11:fft<1<<11>(a);break;
			case 1<<12:fft<1<<12>(a);break;
			case 1<<13:fft<1<<13>(a);break;
			case 1<<14:fft<1<<14>(a);break;
			case 1<<15:fft<1<<15>(a);break;
			case 1<<16:fft<1<<16>(a);break;
			case 1<<17:fft<1<<17>(a);break;
			case 1<<18:fft<1<<18>(a);break;
			case 1<<19:fft<1<<19>(a);break;
			case 1<<20:fft<1<<20>(a);break;
			case 1<<21:fft<1<<21>(a);break;
			throw FFTLimitExceededError();
		}
	}
	inline void idft(complex* a, int n) {
		if (n <= 1) return;
		switch (n) {
			case 1<<2:ifft<1<<2>(a);break;
			case 1<<3:ifft<1<<3>(a);break;
			case 1<<4:ifft<1<<4>(a);break;
			case 1<<5:ifft<1<<5>(a);break;
			case 1<<6:ifft<1<<6>(a);break;
			case 1<<7:ifft<1<<7>(a);break;
			case 1<<8:ifft<1<<8>(a);break;
			case 1<<9:ifft<1<<9>(a);break;
			case 1<<10:ifft<1<<10>(a);break;
			case 1<<11:ifft<1<<11>(a);break;
			case 1<<12:ifft<1<<12>(a);break;
			case 1<<13:ifft<1<<13>(a);break;
			case 1<<14:ifft<1<<14>(a);break;
			case 1<<15:ifft<1<<15>(a);break;
			case 1<<16:ifft<1<<16>(a);break;
			case 1<<17:ifft<1<<17>(a);break;
			case 1<<18:ifft<1<<18>(a);break;
			case 1<<19:ifft<1<<19>(a);break;
			case 1<<20:ifft<1<<20>(a);break;
			case 1<<21:ifft<1<<21>(a);break;
			throw FFTLimitExceededError();
		}
	}
}

BigInteger BigInteger::fft_mul(const BigInteger& a, const BigInteger& b) {
	int n = a.digits.size(), m = b.digits.size();
	int least = (n + m) << 1, lim = 1;
	while (lim < least) lim <<= 1;

	__FFT::complex* arr = new __FFT::complex[lim];
	for (int i = 0; i < n; i++) {
		arr[i << 1].real = a.digits[i] % 10000LL;
		arr[i << 1 | 1].real = a.digits[i] / 10000LL % 10000LL;
	}
	for (int i = 0; i < m; i++) {
		arr[i << 1].imag = b.digits[i] % 10000LL;
		arr[i << 1 | 1].imag = b.digits[i] / 10000LL % 10000LL;
	}
	__FFT::dft(arr, lim);
	for (int i = 0; i < lim; i++) arr[i] *= arr[i];
	__FFT::idft(arr, lim);

	std::vector<digit_t> res(n + m + 1);
	digit_t carry = 0;
	double inv = 0.5 / lim;
	for (int i = 0; i <= n + m; i++) {
		carry += digit_t(arr[i << 1].imag * inv + 0.5);
		carry += digit_t(arr[i << 1 | 1].imag * inv + 0.5) * 10000LL;
		res[i] += carry % BASE, carry /= BASE;
	}
	delete[] arr;
	return res;
}

BigInteger BigInteger::operator* (const BigInteger& x) const {
	if (zero() || x.zero()) return BigInteger();
	int n = digits.size(), m = x.digits.size();
	if (1LL * n * m >= FFT_LIMIT) {
		BigInteger res = fft_mul(*this, x);
		return res.flag = !(flag ^ x.flag), res;
	}  // When n * m < FFT_LIMIT, using normal multiplication
	std::vector<digit_t> res(n + m + 1);
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			res[i + j] += digits[i] * x.digits[j];
			res[i + j + 1] += res[i + j] / BASE, res[i + j] %= BASE;
		}
	}
	BigInteger u(res);
	return u.flag = !(flag ^ x.flag), u;
}
BigInteger& BigInteger::operator*= (const BigInteger& x) {
	return *this = *this * x;
}
BigInteger BigInteger::square() const {  // Calculate the square, faster than a * a
	if (zero()) return BigInteger();
	int n = digits.size();
	if (1LL * n * n < FFT_LIMIT) {  // When n * n < FFT_LIMIT, using normal multiplication
		std::vector<digit_t> res((n << 1) + 1);
		for (int i = 0; i < n; i++) {
			for (int j = 0; j < n; j++) {
				res[i + j] += digits[i] * digits[j];
				res[i + j + 1] += res[i + j] / BASE, res[i + j] %= BASE;
			}
		}
		return res;
	}
	int least = n << 2, lim = 1;
	while (lim < least) lim <<= 1;

	__FFT::complex* arr = new __FFT::complex[lim];
	for (int i = 0; i < n; i++) {
		arr[i << 1].real = arr[i << 1].imag = digits[i] % 10000LL;
		arr[i << 1 | 1].real = arr[i << 1 | 1].imag = digits[i] / 10000LL % 10000LL;
	}
	__FFT::dft(arr, lim);
	for (int i = 0; i < lim; i++) arr[i] *= arr[i];
	__FFT::idft(arr, lim);

	std::vector<digit_t> res((n << 1) + 1);
	digit_t carry = 0;
	double inv = 0.5 / lim;
	for (int i = 0; i <= (n << 1); i++) {
		carry += digit_t(arr[i << 1].imag * inv + 0.5);
		carry += digit_t(arr[i << 1 | 1].imag * inv + 0.5) * 10000LL;
		res[i] += carry % BASE, carry /= BASE;
	}
	delete[] arr;
	return res;
}

BigInteger& BigInteger::operator*= (int32_t x) {
	if (x == 0 || zero()) return *this = 0;
	if (x < 0) flag ^= 1, x = -x;
	digit_t carry = 0;
	for (int i = 0; i < (int) digits.size() || carry != 0; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] = digits[i] * x + carry;
		carry = digits[i] / BASE, digits[i] %= BASE;
	}
	return trim();
}
BigInteger BigInteger::operator* (const int32_t& x) const {
	return BigInteger(*this) *= x;
}

BigInteger BigInteger::half() const {
	BigInteger res = *this;
	for (int i = digits.size() - 1; i >= 0; i--) {
		if ((res[i] & 1) && i > 0) res.digits[i - 1] += BASE;
		res.digits[i] >>= 1;
	}
	return res.trim();
}
BigInteger& BigInteger::operator/= (int64_t x) {
	if (x == 0) throw ZeroDivisionError();
	if (zero()) return *this;
	if (x < 0) flag ^= 1, x = -x;
	digit_t cur = 0;
	for (int i = digits.size() - 1; i >= 0; i--) {
		cur = cur * BASE + digits[i];
		digits[i] = flag ? (cur / x) : (-cur / -x);
		cur %= x;
	}
	return trim();
}
BigInteger BigInteger::operator/ (const int64_t& x) const {
	return BigInteger(*this) /= x;
}

BigInteger BigInteger::newton_inv(int n) const {  // Solve BASE^n / x
	if (zero()) throw ZeroDivisionError();
	int sz = digits.size();
	if (std::min(sz, n - sz) <= NEWTON_DIV_MIN_LEVEL) {
		std::vector<digit_t> a(n + 1);
		a[n] = 1;
		return BigInteger(a).divmod(*this).first;
	}
	int k = (n - sz + 2) >> 1, k2 = k > sz ? 0 : sz - k;
	BigInteger x = _move_r(k2);
	int n2 = k + x.digits.size();
	BigInteger y = x.newton_inv(n2), a = y + y, b = (*this) * y * y;
	return a._move_l(n - n2 - k2) - b._move_r(2 * (n2 + k2) - n) - 1;
}
std::pair<BigInteger, BigInteger> BigInteger::divmod(const BigInteger& x) const {
	BigInteger a = abs(), b = x.abs();
	if (b == 0) throw ZeroDivisionError();
	if (a < b) return std::make_pair(0, flag ? a : -a);
	int n = a.digits.size(), m = b.digits.size();

	if (std::min(n, n - m) > NEWTON_DIV_LIMIT) {
		int k = n - m + 2, k2 = std::max(0, m - k);
		BigInteger b2 = b._move_r(k2);
		if (k2 != 0) b2 += 1;
		int n2 = k + b2.digits.size();
		BigInteger u = a * b2.newton_inv(n2), q = u._move_r(n2 + k2), r = (*this) - q * b;
		while (r >= b) q += 1, r -= b;
		q.flag = !(flag ^ x.flag), r.flag = flag;
		return std::make_pair(q, r);
	}

	int32_t t = BASE / (x.digits.back() + 1);
	a *= t, b *= t, n = a.digits.size(), m = b.digits.size();
	BigInteger q = 0, r = 0;
	q.digits.resize(n);
	for (int i = n - 1; i >= 0; i--) {
		r = r * BASE + a.digits[i];
		digit_t d1 = r[m], d2 = r[m - 1], d = (d1 * BASE + d2) / b.digits.back();
		r -= b * d;
		while (r.negative()) r += b, d--;
		q.digits[i] = d;
	}
	q.trim(), q.flag = !(flag ^ x.flag), r.flag = flag;
	return std::make_pair(q, r / t);
}

BigInteger BigInteger::operator/ (const BigInteger& x) const {
	return divmod(x).first;
}
BigInteger& BigInteger::operator/= (const BigInteger& x) {
	return *this = divmod(x).first;
}
BigInteger BigInteger::operator% (const BigInteger& x) const {
	return divmod(x).second;
}
BigInteger& BigInteger::operator%= (const BigInteger& x) {
	return *this = divmod(x).second;
}

BigInteger BigInteger::pow(int64_t b) const {
	BigInteger a = *this, res = 1;
	for (; b; b >>= 1) {
		if (b & 1) res *= a;
		a = a.square();
	} return res;
}
BigInteger BigInteger::pow(int64_t b, const BigInteger& p) const {
	BigInteger a = *this % p, res = 1;
	for (; b; b >>= 1) {
		if (b & 1) res = res * a % p;
		a = a.square() % p;
	} return res;
}

BigInteger BigInteger::sqrt_normal() const {
	BigInteger x0 = BigInteger(BASE)._move_l((digits.size() + 2) >> 1);
	BigInteger x = (x0 + *this / x0).half();
	while (x < x0) std::swap(x, x0), x = (x0 + *this / x0).half();
	return x0;
}
BigInteger BigInteger::newton_invsqrt() const {	  // Solve BASE^2k / sqrt(x)
	int n = digits.size(), n2 = n + (n & 1), k2 = (n2 + 2) / 4 * 2;
	if (n <= NEWTON_SQRT_MIN_LEVEL) return BigInteger(1)._move_l(n2 << 1) / this->_move_l(n2 << 1).sqrt_normal();

	BigInteger x2k(std::vector<digit_t>(digits.begin() + n2 - k2, digits.end()));
	BigInteger s = x2k.newton_invsqrt()._move_l((n2 - k2) / 2);
	BigInteger x2 = (s + s + s).half() - (s * s * s * *this).half()._move_r(n2 << 1);
	BigInteger rx = BigInteger(1)._move_l(n2 << 1) - *this * x2.square(), delta = 1;

	if (rx.negative()) {
		for (; rx.negative(); delta += delta) {
			BigInteger t = (x2 + x2 - delta + delta.square()) * (*this);
			x2 -= delta, rx += t;
		}
	} else {
		while (true) {
			BigInteger t = (x2 + x2 + delta) * delta * (*this);
			if (t > rx) break;
			x2 += delta, rx -= t, delta += delta;
		}
	}
	for (; delta.positive(); delta = delta.half()) {
		BigInteger t = (x2 + x2 + delta) * delta * (*this);
		if (t <= rx) x2 += delta, rx -= t;
	}
	return x2;
}
BigInteger BigInteger::sqrt() const {
	if (negative()) throw NegativeRadicandError();
	if (digits.size() <= NEWTON_SQRT_LIMIT) return sqrt_normal();
	int n = digits.size(), n2 = (n & 1) ? n + 1 : n;
	BigInteger res = (*this * newton_invsqrt())._move_r(n2), r = *this - res.square(), delta = 1;
	while (true) {
		BigInteger dr = (res + res + delta) * delta;
		if (dr > r) break;
		r -= dr, res += delta, delta += delta;
	}
	for (; delta > 0; delta = delta.half()) {
		BigInteger dr = (res + res + delta) * delta;
		if (dr <= r) r -= dr, res += delta;
	}
	return res;
}

BigInteger BigInteger::root(const int64_t& m) const {
	if (m <= 0 || (m % 2 == 0 && negative())) throw NegativeRadicandError();
	if (m == 1 || zero()) return *this;
	if (m == 2) return sqrt();
	int n = digits.size();
	if (n <= m) {
		digit_t l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			if (BigInteger(mid).pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		return l;
	}
	if (n <= m * 2) {
		BigInteger res;
		res.digits.resize(2, 0);
		digit_t l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			res.digits[1] = mid;
			if (res.pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		res.digits[1] = l, l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			res.digits[0] = mid;
			if (res.pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		res.digits[0] = l;
		return res.trim();
	}
	int t = n / m / 2;
	BigInteger s = (_move_r(t * m).root(m) + 1)._move_l(t);
	BigInteger res = (s * (m - 1) + *this / s.pow(m - 1)) / m;
	digit_t l = std::max<digit_t>(res.digits[0] - 100, 0), r = std::min(res.digits[0] + 100, BASE - 1);
	while (l < r) {
		digit_t mid = (l + r + 1) >> 1;
		res.digits[0] = mid;
		if (res.pow(m) <= *this) l = mid;
		else r = mid - 1;
	}
	return res.digits[0] = l, res.trim();
}

BigInteger BigInteger::gcd(BigInteger b) const {
	BigInteger a = *this;
	if (a < b) std::swap(a, b);
	if (b == 0) return a;
	int64_t t = 0;
	while (!a.mod2() && !b.mod2()) a = a.half(), b = b.half(), t++;
	while (b.positive()) {
		if (!a.mod2()) a = a.half();
		else if (!b.mod2()) b = b.half();
		else a -= b;
		if (a < b) std::swap(a, b);
	}
	return a * BigInteger(2).pow(t);
}
BigInteger BigInteger::lcm(const BigInteger& x) const {
	return *this / gcd(x) * x;
}

BigInteger BigInteger::operator<< (const int64_t& x) const {return *this * BigInteger(2).pow(x);}
BigInteger BigInteger::operator>> (const int64_t& x) const {return *this / BigInteger(2).pow(x);}
BigInteger& BigInteger::operator<<= (const int64_t& x) {return *this *= BigInteger(2).pow(x);}
BigInteger& BigInteger::operator>>= (const int64_t& x) {return *this /= BigInteger(2).pow(x);}

BigInteger __helper(const BigInteger& x, const BigInteger& y, const std::function<bool(bool, bool)>& op) {
	std::vector<bool> a = x.to_binary(), b = y.to_binary();
	int n = a.size(), m = b.size(), lim = std::max(n, m);
	std::vector<bool> res(lim);
	for (int i = 0; i < lim; ++i) res[i] = op(i < n ? a[i] : 0, i < m ? b[i] : 0);
	return res;
}
BigInteger BigInteger::operator& (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a & b;});
}
BigInteger BigInteger::operator| (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a | b;});
}
BigInteger BigInteger::operator^ (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a ^ b;});
}
BigInteger& BigInteger::operator&= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a & b;});
}
BigInteger& BigInteger::operator|= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a | b;});
}
BigInteger& BigInteger::operator^= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a ^ b;});
}

BigInteger factorial(int32_t n) {
	BigInteger res = 1;
	for (int32_t i = 2; i <= n; i++) res *= i;
	return res;
}
BigInteger i_random(int32_t n) {
	std::mt19937 e(std::chrono::system_clock::now().time_since_epoch().count());
	std::uniform_int_distribution<unsigned> u0(0, 9), u1(1, 9);
	std::string s;
	s += u0(e) ^ 48;
	for (int32_t i = 2; i <= n; i++) s += u1(e) ^ 48;
	return s;
}

BigInteger i_gcd(const BigInteger& a, const BigInteger& b) {return a.gcd(b);}
BigInteger i_lcm(const BigInteger& a, const BigInteger& b) {return a.lcm(b);}
BigInteger i_sqrt(const BigInteger& a) {return a.sqrt();}
BigInteger i_root(const BigInteger& a, int64_t x) {return a.root(x);}
BigInteger i_pow(const BigInteger& a, int64_t b) {return a.pow(b);}
BigInteger i_pow(const BigInteger& a, int64_t b, const BigInteger& p) {return a.pow(b, p);}
#endif  // BIGINTEGER_H
```

## 操作文档

BigInteger 3.0 版本支持多种操作。下面的复杂度分析中，$w=8, w'=4$。

## 初始化

- `BigInteger()`：创建一个新的 `BigInteger`，默认值为 $0$。
- `BigInteger(const BigInteger& x)`：创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为 $x$ 的长度。
- `BigInteger(int64_t x)`：创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\log x)$。
- `BigInteger(const std::string& s)`：从字符串创建一个新的 `BigInteger`，时间复杂度 $O(n)$，其中 $n$ 为字符串长度。合法的字符串必须由若干个 `-` 号后接若干数字字符组成。
- `BigInteger(const std::vector<bool>& v)`：从二进制表示创建一个新的 `BigInteger`，时间复杂度 $O(n^2)$，其中 $n$ 为二进制表示长度。
- `BigInteger.from_int128(__int128 x)`：`static` 型函数，从 `__int128` 类型创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\log x)$。在不支持 `__int128` 的环境中，`BigInteger` 无此操作。

## I / O

- `std::cin >> x`：输入一个 `BigInteger` 的值，时间复杂度 $O(n)$，其中 $n$ 为字符串长度。合法输入与从字符串初始化 `BigInteger` 的要求相同。
- `std::cout << x`：输出一个 `BigInteger` 的值，时间复杂度 $O(n)$，其中 $n$ 为此整数的长度。

## 类型转换

- `a.to_string()`：返回值为 `std::string` 类型，返回 `a` 转换为字符串后的结果。时间复杂度 $O(n)$，其中 $n$ 为此整数的长度。
- `a.to_int64()`：返回值为 `int64_t` 类型，返回 `a` 转换为 64 位整数后的结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。若结果发生溢出，则行为未定义。
- `a.to_binary()`：返回值为 `std::vector<bool>` 类型，返回 $a$ 的二进制表示，时间复杂度 $O(n^2)$，其中 $n$ 为此整数的长度
- `a.to_int128()`：返回值为 `__int128` 类型，返回 `a` 转换为 128 位整数后的结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。若结果发生溢出，则行为未定义。在不支持 `__int128` 的环境中，`BigInteger` 无此操作。

## 基本运算

- `a.zero()`：判断 $a$ 是否为 $0$，时间复杂度 $O(1)$。
- `!a`：判断 $a$ 是否不为 $0$，时间复杂度 $O(1)$。
- `a.positive()`：判断 $a$ 是否为正数，时间复杂度 $O(1)$。**$0$ 不是正数。**
- `a.negative()`：判断 $a$ 是否为负数，时间复杂度 $O(1)$。
- `a.compare(const BigInteger& b)`：返回 $a$ 与 $b$ 比较的结果，返回值为 `int` 类型。若 $a<b$ 返回 $-1$，$a=b$ 返回 $0$，$a>b$ 返回 $1$。时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a <=> b, a <= b, a < b, a == b, a != b, a > b, a >= b`：返回 $a$ 与 $b$ 比较的对应结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。
- `-a`：返回 $-a$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `~a`：返回 $-a-1$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `a.abs()`：返回 $|a|$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `a + b`：返回 $a+b$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。支持 `a += b` 原地加法。
- `a - b`：返回 $a-b$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。支持 `a -= b` 原地减法。
- `a * b`：返回 $a \times b$，时间复杂度 $O(\dfrac{n \log n}{w'})$，其中 $n$ 为两整数的长度的较大值。当 $n <$ `8 * FFT_LIMIT` 时，采用 $O(\dfrac{n^2}{w^2})$ 竖式乘法计算。`FFT_LIMIT` 默认为 $8$。特别地，当 `b` 为 `int32_t` 类型时时间复杂度为 $O(\dfrac{n}{w})$，且支持原地乘法。$n > 2^{20}$ 时抛出 `FFTLimitExceededError` 异常。
- `a.square()`：返回 $a^2$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度，快于 `a * a`。
- `a.half()`：返回 $\lfloor \dfrac{a}{2} \rfloor$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度，快于 `a / 2`。
- `a / b`：返回 $\lfloor \dfrac{a}{b} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w'})$，其中 $n$ 为两整数的长度的较大值。当 $n <$ `8 * NEWTON_DIV_LIMIT` 时，采用 $O(\dfrac{n^2}{w})$ 竖式乘法计算。`NEWTON_DIV_LIMIT` 默认为 $32$。特别地，当 `b` 为 `int64_t` 类型时时间复杂度为 $O(\dfrac{n}{w})$，且支持原地除法。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a % b`：返回 $a \bmod b$，时间复杂度与 `a / b` 一致。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a.divmod(b)`：返回一个 `std::pair`，分别为 $(\lfloor \dfrac{a}{b} \rfloor, a \bmod b)$，时间复杂度与 `a / b` 一致，但 $b$ 为 `int64_t` 类型时无优化。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a.mod2()`：返回 $a \bmod 2$，时间复杂度 $O(1)$。
- `a.pow(b)` 或 `i_pow(a, b)`：返回 $a^b$，时间复杂度 $O(\dfrac{nb \log nb}{w})$，其中 $n$ 为此整数的长度。$b$ 应为 `int64_t` 类型。
- `a.pow(b, p)` 或 `i_pow(a, b, p)`：返回 $a^b \bmod p$，时间复杂度 $O(\dfrac{nb \log nb}{w})$，其中 $n$ 为此整数的长度。$b$ 应为 `int64_t` 类型，$p$ 为 `BigInteger` 类型。
- `a.sqrt()` 或 `i_sqrt(a)`：返回 $\lfloor \sqrt{a} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w})$，其中 $n$ 为此整数的长度。$a<0$ 时抛出 `NegativeRadicandError` 异常。
- `a.root(x)` 或 `i_root(a, x)`：返回 $\lfloor \sqrt[x]{a} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w})$，其中 $n$ 为此整数的长度。$x \le 0$ 时抛出 `NegativeRadicandError` 异常。$2 \mid x$ 且 $a < 0$ 时抛出 `NegativeRadicandError` 异常。
- `a.gcd(b) `或 `i_gcd(a, b)`：返回 $\gcd(a,b)$，时间复杂度 $O(\dfrac{n^2}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a.lcm(b)` 或 `i_lcm(a, b)`：返回 $\operatorname{lcm}(a,b)$，时间复杂度 $O(\dfrac{n^2}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a << x`：返回 $a \times 2^x$，时间复杂度 $O(\dfrac{(n+x) \log(n+x)}{w'})$，其中 $n$ 为此整数的长度。
- `a >> x`：返回 $\lfloor \dfrac{a}{2^x} \rfloor$，时间复杂度 $O(\dfrac{(n-x) \log(n-x)}{w'})$，其中 $n$ 为此整数的长度。
- `a & b`：返回 $a,b$ 的按位与，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。
- `a | b`：返回 $a,b$ 的按位或，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。
- `a ^ b`：返回 $a,b$ 的按位异或，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。

## 其他函数

- `factorial(n)`：返回值为 `BigInteger` 类型，返回 $n!$，时间复杂度 $O(\dfrac{n^2}{w})$。
- `i_random(n)`：返回长度为 $n$ 的随机 `BigInteger`，时间复杂度 $O(n)$。

## 内部函数

此部分函数不建议使用。

- `a._digit_len()`：返回 $\lfloor \dfrac{n}{w} \rfloor$，其中 $n$ 为此整数的长度，时间复杂度 $O(1)$。
- `a._move_l(x)`：返回 $|n \times 10^{wx}|$，时间复杂度 $O(\dfrac{n}{w}+x)$，其中 $n$ 为此整数的长度。
- `a._move_r(x)`：返回 $|\lfloor \dfrac{n}{10^{wx}} \rfloor|$，时间复杂度 $O(\dfrac{n}{w}-x)$，其中 $n$ 为此整数的长度。
- `__FFT::dft(a, n)`：将长度为 $n$ 的 `__FFT::complex[]` 类型的 `a` 数组作 DFT 变换，时间复杂度 $O(n\log n)$。要求 $n$ 是不大于 $2^{21}$ 的 $2$ 的幂。
- `__FFT::idft(a, n)`：将长度为 $n$ 的 `__FFT::complex[]` 类型的 `a` 数组作 IDFT 变换，时间复杂度 $O(n\log n)$。要求 $n$ 是不大于 $2^{21}$ 的 $2$ 的幂。
- `__helper(a, b, f)`：将 $a,b$ 按位执行 `f` 运算，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。`f` 应当为一个形如 `bool f(bool, bool)` 的函数。

## 优缺点

优点：

- 高度封装，几乎支持 `int` 类型所有操作，无需手写。
- 速度快，大部分操作已优化到一个较优秀的复杂度。
- 代码长度较短。

缺点：

- 位运算速度较慢。
- 不支持超大位数整数的乘除法。具体地，位数大于 $2^{20}=1048576$ 时抛出 `FFTLimitExceededError` 异常。
- 偶尔出现的 bug。

## 疑问

Q1: 为什么不支持超大位数整数的乘除法？

A1: 因为 FFT 采用分块计算单位根的方法，提升效率的同时牺牲了稳定性。由于 BigInteger 的设计目的是服务 OI 竞赛，一般不会有超过 $10^6$ 位大整数。若您需要更大位数的整数，可将 `__FFT::RBASE` 改为 $63$，它可以支持 $3 \times 10^7$ 位数的整数。

Q2: 为什么运算符不实现为自由函数？

A2: 如果实现为自由函数，`BigInteger` 内部的 `digits` 需要声明为 `public`，会造成不安全。您可以通过显式类型转换或者将 `BigInteger` 写到运算符左边来避免问题。

Q3: 为什么 `BigInteger`  的操作函数带 `i_` 前缀？

A3: 表明这个函数用于操作 `BigInteger` 类型。未来计划实现 `BigDecimal` 类型，用 `d_` 前缀来标识。

## 感谢

感谢为此项目作出贡献的用户，排名按字典序。

- @[bcdmwSjy](https://www.luogu.com.cn/user/514727)
- @[kkkkkse05](https://www.luogu.com.cn/user/340145)
- @[konyakest](https://www.luogu.com.cn/user/482660)
- @[Noiers](https://www.luogu.com.cn/user/1402616)
- @[Xudongning](https://www.luogu.com.cn/user/1636821)$AKB7$, '基础算法', array['大整数', '高精度', 'BigInteger', '库'], 'col-basic-high-precision', null, 'knowledge'),
('dbywsc', 'col-basic-binary-search--dbywsc', '二分查找与二分答案 · dbywsc', $AKB8$## 算法原理

二分的前提是**单调性**：待查找的集合（或答案的可能取值）能按某个方向排成有序序列，使得“判断某个位置是否满足条件”之后，可以确定答案只可能在左半边或右半边。

### 二分查找

给定长度为 $n$ 且单调不减的数组 $a$，询问 $x$ 第一次出现的位置。朴素做法从 $1$ 扫到 $n$，单次 $O(n)$；利用单调性可以每次把区间缩小一半：

- 取 $mid=\left\lfloor\dfrac{l+r}{2}\right\rfloor$；
- 若 $a_{mid}\ge x$，说明 $mid$ 及其右边都不可能是“第一次出现”的更优位置，令 $r=mid-1$；
- 若 $a_{mid}<x$，说明 $mid$ 及其左边都太小，令 $l=mid+1$。

当 $a_{mid}=x$ 时先记录 $ans=mid$，再继续往左找，最终得到的就是第一次出现的位置；若从未记录，则不存在，输出 $-1$。

### 两个常用边界

- `lower_bound(x)`：第一个**大于等于** $x$ 的位置；
- `upper_bound(x)`：第一个**大于** $x$ 的位置。

两者相减就是等于 $x$ 的元素个数。C++ 的 `std::lower_bound` / `std::upper_bound` 已经实现好，作用在有序区间上，复杂度 $O(\log n)$。

### 二分答案

有些问题很难直接算出答案，但可以很快判断“某个答案是否可行”。如果可行性随答案单调变化，就可以二分答案：

- 答案区间 $[L,R]$；
- 每次取 $mid$，用 `check(mid)` 判断是否可行；
- 根据可行性移动 $L$ 或 $R$。

例如“锯片高度越高，能获得的木材越少”：高度 $x$ 可行则更低的高度也可行，于是可以二分最高的可行高度。

### 浮点二分

实数域上同样可以二分。由于浮点数无法精确表示，通常设定精度 `EPS`，当区间长度小于 `EPS` 时停止；若要保留六位小数，`EPS` 取 $10^{-7}$ 左右即可。

## 核心公式 / 状态定义与转移方程

- 闭区间二分的中间点：$mid=\left\lfloor\dfrac{l+r}{2}\right\rfloor$，更稳妥的写法是 `l + (r - l) / 2`，避免 `l + r` 溢出。
- 查找第一个满足条件的位置：
  - 条件为真：$r=mid-1$，并记录 $ans=mid$；
  - 条件为假：$l=mid+1$。
- 查找最后一个满足条件的位置：把记录答案的时机和移动方向反过来。
- 二分答案的可行性：若 `check(mid)` 为真，则所有比 $mid$ 更“容易”的答案也为真；利用这个单调性缩小区间。
- 浮点二分终止条件：$r-l<\text{EPS}$。

## 逐行代码解析

### 闭区间二分查找

```cpp
int l = 1, r = n, ans = -1;
while (l <= r) {
    int mid = (l + r) / 2;
    if (a[mid] >= x) {
        if (a[mid] == x) ans = mid;
        r = mid - 1;
    } else {
        l = mid + 1;
    }
}
```

- 区间始终是闭区间 $[l,r]$，所以循环条件是 `l <= r`。
- `a[mid] >= x` 时，答案只可能在 $mid$ 及其左边；等于时先记录，再继续往左找第一次出现。
- `a[mid] < x` 时，$mid$ 及左边都不可能是答案，直接令 `l = mid + 1`。
- 循环结束后 `ans` 就是第一次出现的位置，未更新则为 $-1$。

### 二分答案框架

```cpp
int l = L, r = R, ans = -1;
while (l <= r) {
    int mid = (l + r) / 2;
    if (check(mid)) {
        ans = mid;
        l = mid + 1;   // 找最大的可行答案
    } else {
        r = mid - 1;
    }
}
```

- `check(mid)` 必须是单调的：可行之后一直可行，或不可行之后一直不可行。
- 想找“最大可行”时，可行就记录并往右；想找“最小可行”时，可行就记录并往左。
- `ans` 初始值要按题目语义设置；无解时输出约定的值。

### 浮点二分

```cpp
double l = L, r = R;
while (r - l >= EPS) {
    double mid = (l + r) / 2;
    if (check(mid)) {
        r = mid;
    } else {
        l = mid;
    }
}
```

- 浮点二分不需要 `ans`，循环结束时 `l` 或 `r` 就是近似答案。
- `EPS` 要比题目要求的精度更小；保留六位小数时通常取 $10^{-7}$。
- 若函数在区间内单调，`check(mid)` 为真就保留左半区间，否则保留右半区间；具体方向按题意调整。

## 复杂度分析

- 二分查找：每次区间长度减半，时间 $O(\log n)$，空间 $O(1)$。
- 二分答案：二分次数 $O(\log V)$（$V$ 为答案值域），每次 `check` 为 $O(T)$，总时间 $O(T\log V)$。
- 浮点二分：二分次数 $O(\log((R-L)/\text{EPS}))$，每次 `check` 的时间另算。

## 适用场景

- 有序数组中的查找、计数、前驱/后继。
- “最大值最小 / 最小值最大”类问题：把最优化转成可行性判定。
- 答案具有单调性的贪心/模拟题，例如砍树、跳石头、木材加工。
- 实数域求根、求平均值/最优比率等需要逼近答案的问题。
- 需要快速求“等于某个值的元素个数”时，用 `lower_bound` / `upper_bound`。

## 常见陷阱与注意事项

1. **区间开闭要统一**：闭区间写 `l <= r`、`r = mid - 1`；左闭右开写 `l < r`、`r = mid`。两套不能混用。
2. **`l + r` 溢出**：`int mid = (l + r) / 2` 在 $l,r$ 很大时可能溢出，写成 `l + (r - l) / 2`。
3. **`lower_bound` 与 `upper_bound` 混淆**：前者第一个 $\ge x$，后者第一个 $>x$；数等于 $x$ 的个数是两者之差。
4. **二分答案的 `check` 不单调**：如果可行性不是单调的，二分答案会得到错误结果；先证明单调性。
5. **边界答案没覆盖**：答案可能是 $L$ 或 $R$，循环条件和初始区间要能取到端点。
6. **浮点精度**：`EPS` 太大精度不够，太小可能死循环；按题目精度要求选，必要时限制二分次数。
7. **浮点比较不要用 `==`**：用 `fabs(a - b) < EPS`。
8. **答案类型**：答案可能超过 `int`，计数类题目用 `long long`。

## 对比与扩展

- **二分查找 vs 哈希表**：哈希表平均 $O(1)$ 查找，但需要额外空间且无序；二分查找 $O(\log n)$，空间 $O(1)$，还能直接支持前驱/后继。
- **二分答案 vs 贪心**：二分答案把“求最优”转成“判定可行”，适合最优值难以直接构造、但判定很容易的问题；贪心则是直接构造。
- **二分 vs 三分**：单峰函数求极值用三分；二分要求单调，三分要求单峰。
- **STL**：`std::lower_bound` / `std::upper_bound` 只要求区间有序；`std::binary_search` 只判断是否存在。
- **讲义练习**：A-B 数对、ABC077C、ABC143D、ABC130D、砍树、跳石头、木材加工、ABC146C、ABC312C、数的三次方根、绳子、ABC248D、ABC119D、ABC212C、ABC174E、P1462、ABC149E。题号以原讲义为准，部分题号可能因平台不同而有差异，做题时按题名检索。$AKB8$, '基础算法', array['二分', '二分查找', '二分答案', '浮点二分', '单调性'], 'col-hub-basic-search', null, 'knowledge'),
('dbywsc', 'col-basic-bubble-select-sort--dbywsc', '基础排序（冒泡 / 快速 / 归并） · dbywsc', $AKB9$## 算法原理

排序算法把一组数据按指定顺序排列。衡量排序算法通常看三点：

- 时间复杂度；
- 空间复杂度；
- **稳定性**：相等的元素在排序后相对顺序是否保持不变。

冒泡、归并是稳定排序；快速排序在随机化划分下通常不稳定。

### 冒泡排序

从第一个元素开始，比较相邻两个元素，如果前面大于后面就交换。每一轮会把当前未排序部分的最大值“冒”到末尾；如果某一轮没有发生交换，说明已经有序，可以提前结束。

### 快速排序

快速排序基于分治：

1. 选一个基准数；
2. 把数组划分成“小于等于基准”“等于基准”“大于基准”三部分；
3. 递归左右两部分。

三路划分可以把与基准相等的元素集中到中间，避免全相同数组退化。随机选择基准可以降低被卡的概率。平均复杂度 $O(n\log n)$，最坏仍是 $O(n^2)$；C++ 的 `std::sort` 使用内省排序，最坏也能做到 $O(n\log n)$。

### 归并排序

归并排序同样基于分治：

1. 把数组从中间分成两半；
2. 递归排序左右两半；
3. 合并两个有序数组。

合并时用双指针，每次取较小者放入临时数组；相等时优先取左边，保证稳定性。时间复杂度 $O(n\log n)$，空间 $O(n)$。

归并排序还可以顺便求**逆序对**：合并左右两半时，若右边当前元素小于左边当前元素，则左边从当前位置到末尾的所有元素都与它构成逆序对，贡献为 `mid - i + 1`。

## 核心公式 / 状态定义与转移方程

- 冒泡排序比较次数：最坏 $\dfrac{n(n-1)}{2}$，时间 $O(n^2)$，空间 $O(1)$，稳定。
- 快速排序：
  - 划分后递归：$T(n)=T(L)+T(R)+O(n)$；
  - 平均 $O(n\log n)$，最坏 $O(n^2)$，空间 $O(\log n)$（递归栈），通常不稳定。
- 归并排序：
  - $T(n)=2T(n/2)+O(n)=O(n\log n)$；
  - 空间 $O(n)$，稳定。
- 逆序对贡献：合并时若 `a[j] < a[i]`，则 `a[i..mid]` 都与 `a[j]` 构成逆序对，贡献 `mid - i + 1`。

## 逐行代码解析

### 冒泡排序（带提前退出）

```pseudocode
Input. An Array A consisting of n elements.
Output. A sorted in nondecreasing order stably.
Method.
need_sort <- True
while need_sort
    need_sort <- False
    for i <- 1 to n - 1
        if A[i] > A[i + 1]
            need_sort <- True
            Swap A[i] and A[i + 1]
```

- 外层 `while` 控制轮数；如果一轮没有交换，`need_sort` 保持假，提前结束。
- 内层只比较相邻元素，严格逆序才交换，因此稳定。
- 最坏（完全逆序）需要 $\dfrac{n(n-1)}{2}$ 次交换。

### 快速排序（三路划分）

```pseudocode
Input. An Array A of n elements.
Output. A sorted in nondecreasing order.
function quick_sort(Arr, len)
    if len <= 1 return
    pivot <- Arr[rand() % len]
    i <- 0, j <- 0, k <- len
    while i < k
        if Arr[i] < pivot
            Swap Arr[i] and Arr[j]
            i <- i + 1
            j <- j + 1
        else if pivot < Arr[i]
            k <- k - 1
            Swap Arr[i] and Arr[k]
        else
            i <- i + 1
    quick_sort(Arr, j)
    quick_sort(Arr + k, len - k)
```

- `[0,j)` 是小于基准的部分，`[j,i)` 是等于基准的部分，`[k,len)` 是大于基准的部分。
- 遇到小于基准就换到前面；遇到大于基准就换到后面；等于基准就跳过。
- 递归只处理小于和大于两部分，等于基准的已经就位。
- 三路划分让全相同数组变成 $O(n)$，但最坏情况仍可能 $O(n^2)$。

### 归并排序

```pseudocode
Input. An Array A of n elements.
Output. A sorted in nondecreasing order stably.
function merge_sort(Arr, l, r)
    if l >= r return
    mid <- (l + r) / 2
    merge_sort(Arr, l, mid)
    merge_sort(Arr, mid + 1, r)
    i <- l, j <- mid + 1, k <- l
    while i <= mid and j <= r
        if Arr[i] <= Arr[j]
            tmp[k] <- Arr[i]
            i <- i + 1
        else
            tmp[k] <- Arr[j]
            j <- j + 1
        k <- k + 1
    while i <= mid
        tmp[k] <- Arr[i]
        i <- i + 1
        k <- k + 1
    while j <= r
        tmp[k] <- Arr[j]
        j <- j + 1
        k <- k + 1
    for p <- l to r
        Arr[p] <- tmp[p]
```

- 先递归左右两半，再把两个有序段合并。
- `Arr[i] <= Arr[j]` 时取左边，保证相等元素的相对顺序不变，因此稳定。
- 合并需要 $O(n)$ 的临时数组。

### 逆序对计数

```pseudocode
function merge_count(Arr, l, r)
    if l >= r return 0
    mid <- (l + r) / 2
    ans <- merge_count(Arr, l, mid) + merge_count(Arr, mid + 1, r)
    i <- l, j <- mid + 1, k <- l
    while i <= mid and j <= r
        if Arr[i] <= Arr[j]
            tmp[k] <- Arr[i]; i <- i + 1
        else
            tmp[k] <- Arr[j]; j <- j + 1
            ans <- ans + (mid - i + 1)
        k <- k + 1
    ...
    return ans
```

- 当右边元素更小时，左边从 `i` 到 `mid` 的所有元素都大于它，都会与它构成逆序对。
- 逆序对计数与归并排序共用同一套合并框架，只多一行贡献计算。

## 复杂度分析

| 算法 | 最坏时间 | 平均时间 | 空间 | 稳定性 |
|---|---|---|---|---|
| 冒泡排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 |
| 快速排序（三路） | $O(n^2)$ | $O(n\log n)$ | $O(\log n)$ | 不稳定 |
| 归并排序 | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 |
| `std::sort`（内省排序） | $O(n\log n)$ | $O(n\log n)$ | $O(\log n)$ | 不稳定 |
| `std::stable_sort` | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 |

## 适用场景

- 冒泡排序：教学、理解交换与稳定性；实际竞赛很少直接使用。
- 快速排序：一般排序、需要原地排序的场合；竞赛中直接用 `std::sort`。
- 归并排序：需要稳定排序、求逆序对、合并两个有序序列。
- `std::sort`：绝大多数竞赛排序场景。
- `std::stable_sort`：需要保持相等元素原顺序时。

## 常见陷阱与注意事项

1. **冒泡排序忘记提前退出**：没有交换时继续扫完，复杂度严格 $O(n^2)$；加上 `need_sort` 可以在近似有序时更快。
2. **快速排序基准选得不好**：固定选第一个元素可能被有序/逆序数据卡到 $O(n^2)$；随机基准或三路划分更稳。
3. **归并排序忘记把临时数组写回**：合并完必须把 `tmp[l..r]` 写回 `Arr[l..r]`。
4. **归并排序的稳定性**：合并时相等元素要优先取左边，否则不稳定。
5. **逆序对贡献的方向**：只有右边元素更小时才统计左边剩余元素；方向写反会多算/少算。
6. **递归深度**：快速排序最坏递归深度 $O(n)$，可能爆栈；随机化/三路划分可缓解。
7. **`std::sort` 不稳定**：需要稳定时用 `std::stable_sort`。
8. **排序对象较大**：比较函数应传引用，避免复制；比较器必须满足严格弱序。

## 对比与扩展

- **冒泡 vs 选择 vs 插入**：三者都是 $O(n^2)$；冒泡和插入稳定，选择不稳定；插入排序在近似有序时表现较好。
- **快速排序 vs 归并排序**：快排原地、平均常数小，但不稳定且最坏 $O(n^2)$；归并稳定、最坏 $O(n\log n)$，但需要 $O(n)$ 额外空间。
- **归并排序 vs 树状数组求逆序对**：归并排序一遍合并即可统计，常数小；树状数组适合带修改或值域较小的场景。
- **`std::sort` vs `std::stable_sort`**：前者更快，后者稳定；需要稳定时不要用 `std::sort` 代替。
- **讲义练习**：A2096、C1014、P1124、P1126、C1105、YL1040E4、G1125。题号以原讲义为准。$AKB9$, '基础算法', array['排序', '冒泡排序', '快速排序', '归并排序', '逆序对', '稳定性'], null, null, 'knowledge'),
('Fohen', 'col-basic-bubble-select-sort--fenfeng', '冒泡排序与选择排序 · Fohen', $AKB10$## 算法原理

冒泡排序与选择排序是最基础的两种比较排序，时间复杂度都是 $O(n^2)$，实现直观、代码简短，常作为排序入门。二者的共同思路是**通过若干轮扫描，每轮确定一个元素的位置**，重复 $n-1$ 轮后整个序列有序。

### 冒泡排序

冒泡排序的核心是**相邻元素两两比较、逆序就交换**：

1. 升序排序时，从前往后遍历，若 $a_j > a_{j+1}$ 就交换它们；
2. 一轮扫描后，最大的元素被一路"冒泡"到末尾，末位确定；
3. 接着对前 $n-1$ 个元素重复扫描，每轮少比较一个；
4. 重复直到只剩一个元素，排序完成。

因为只在 $a_j > a_{j+1}$（严格大于）时交换，相等元素不会互换位置，所以冒泡排序是**稳定**排序。

### 选择排序

选择排序的核心是**每轮选出待排序区间的最小值，放到区间开头**：

1. 第 $i$ 轮（$i = 1, 2, \dots, n-1$）在区间 $[i, n]$ 中找到最小元素的下标；
2. 把该最小元素与位置 $i$ 上的元素交换；
3. 位置 $i$ 被确定，待排序区间缩小到 $[i+1, n]$。

每轮只做一次交换，但"找最小"需要 $n-i$ 次比较。由于一次交换可能跳过多个相等元素，一般实现下**不稳定**（改用链表可以使其稳定，但实践中很少使用）。

> 说明：朋友资料中"冒泡排序"一节的代码实际是"每次把当前最小值换到最前"的交换式写法，行为上等价于选择排序；教科书冒泡排序是"相邻比较、每轮把最大值冒到末尾"。本页代码原样保留朋友资料，二者都能正确排序，差异详见「常见陷阱与注意事项」。

## 核心公式 / 状态定义与转移方程

### 比较次数

设序列长度为 $n$，两种算法每轮的比较次数都构成等差数列，总比较次数相同：

$$\text{比较次数} = (n-1) + (n-2) + \cdots + 1 = \frac{n(n-1)}{2}$$

交换次数则不同：

| 算法 | 交换策略 | 最好交换次数 | 最坏交换次数 |
|------|---------|------------|------------|
| 冒泡排序 | 每遇逆序就交换 | $0$（已有序） | $\dfrac{n(n-1)}{2}$ |
| 选择排序 | 每轮至多一次 | $n-1$ | $n-1$ |

### 排序不变式

- 冒泡排序：第 $k$ 轮结束后，末尾 $k$ 个元素是全局最大的 $k$ 个且已就位。
- 选择排序：第 $i$ 轮结束后，前 $i$ 个元素是全局最小的 $i$ 个且已就位。

### 稳定性

- 冒泡排序稳定：相等元素因"严格大于才交换"而保持相对顺序。
- 选择排序不稳定：一次交换可能跨越多个元素，破坏相等元素的相对顺序。

## 逐行代码解析

### 头文件与命名空间

```cpp
#include <bits/stdc++.h>
using namespace std;
```

- `bits/stdc++.h` 是竞赛常用万能头，一次引入几乎所有标准库；
- `using namespace std` 省去每个标准库名字前的 `std::` 前缀。

### 冒泡排序函数（交换式写法）

```cpp
void bubbleSort(int v[], int n)
{
    for(int i=1;i<=n;i++){
        for(int j=i+1;j<=n;j++){
            if(v[i]>v[j])swap(v[i],v[j]);
        }
    }
}
```

- 外层 `i` 表示"正在确定的位置"，从 $1$ 遍历到 $n$；
- 内层 `j` 从 `i+1` 扫到 `n`，只要 $v[i] > v[j]$ 就交换；
- 一轮内层循环后，`v[i]` 成为区间 $[i, n]$ 的最小值；
- 这种"把最小值换到最前"的写法等价于选择排序，与教科书"相邻交换"的冒泡不同。

### 选择排序函数

```cpp
void selectionSort(int a[], int n)
{
    for (int i=1;i<n;i++) {
        int zz=i;
        for (int j=i+1;j<=n;j++) {
          if(a[j]<a[zz]) zz=j;
        }
        swap(a[i],a[zz]);
      }
}
```

- 变量 `zz` 记录当前区间 $[i, n]$ 中最小值所在的下标，初始设为 `i`；
- 内层 `j` 扫描 $[i+1, n]$，遇到更小的元素就把下标更新到 `zz`；
- 一轮结束后 `swap(a[i], a[zz])` 把最小值换到位置 `i`；
- 外层到 `i < n` 即止：只剩最后一个元素时它必已就位。

### 主函数

```cpp
int main()
{
    int n;cin>>n;
    int v[n+10], a[n+10];
    for(int i=1;i<=n;i++){
        cin>>v[i];
        a[i]=v[i];
    }
    bubbleSort(v, n);
    selectionSort(a, n);
    for(int i=1;i<=n;i++){
        cout<<v[i]<<" ";
    }
    cout<<'\n';
    for(int i=1;i<=n;i++){
        cout<<a[i]<<" ";
    }
    return 0;
}
```

- 下标从 $1$ 到 $n$，数组多开 `n+10` 留出余量；
- 读入后把同一份数据复制到 `v` 和 `a`，分别用两种算法排序；
- 依次输出两种排序结果，中间用换行分隔。

## 复杂度分析

### 时间复杂度

两种算法都是双重循环，总比较次数为 $\dfrac{n(n-1)}{2}$：

$$T(n) = O(n^2)$$

| 算法 | 最好 | 平均 | 最坏 |
|------|------|------|------|
| 冒泡排序 | $O(n)$（加提前退出标志） | $O(n^2)$ | $O(n^2)$ |
| 选择排序 | $O(n^2)$ | $O(n^2)$ | $O(n^2)$ |

本页代码未加"提前退出"优化，冒泡排序同样恒为 $O(n^2)$；选择排序无论输入如何都要完成全部比较，恒为 $O(n^2)$。

### 空间复杂度

两种算法都只用到常数个辅助变量（下标 `i`、`j`、`zz`），原地排序：

$$S(n) = O(1)$$

### 稳定性小结

| 算法 | 稳定性 |
|------|--------|
| 冒泡排序 | 稳定 |
| 选择排序 | 不稳定 |

## 适用场景

- **小规模数据**：$n$ 在几百以内时，$O(n^2)$ 与 $O(n \log n)$ 的差异可忽略，且代码简单不易错；
- **教学与理解排序思想**：二者是理解"比较、交换、稳定性"的最佳起点；
- **几乎有序的序列（冒泡）**：加"提前退出"优化后接近 $O(n)$；
- **交换代价高的场景（选择）**：选择排序每轮至多交换一次，总交换次数 $O(n)$，适合"移动昂贵"的假设场景。

不适用：大规模数据（$n > 10^4$）应改用快速排序、归并排序、堆排序等 $O(n \log n)$ 算法；需要稳定排序时不要用选择排序。

## 常见陷阱与注意事项

1. **下标边界**
   - 本页代码下标从 $1$ 开始，选择排序外层条件是 `i < n`（最后一个元素无需再选）；
   - 若改为 0 基下标，外层应写成 `i < n-1`。

2. **冒泡排序的两种写法别混**
   - 朋友资料中标注"冒泡排序"的代码是"每轮把最小值换到最前"，等价于选择排序；
   - 教科书冒泡排序是"相邻元素比较、每轮把最大值冒到末尾"，即 `if(v[j] > v[j+1]) swap(v[j], v[j+1])`；
   - 二者都能正确排序，但前者不是严格意义的冒泡排序，做题或面试时需按题意写对。

3. **稳定性**
   - 冒泡排序稳定（严格大于才交换）；选择排序不稳定；
   - 需要保持相等元素相对顺序时选冒泡、插入或归并，不要用选择排序。

4. **提前退出优化**
   - 冒泡排序若某轮没有发生任何交换，说明已有序，可提前退出，最好情况降到 $O(n)$；
   - 选择排序无法提前退出，恒为 $O(n^2)$。

5. **变长数组与栈空间**
   - 代码里 `int v[n+10]` 是变长数组（GCC 扩展），$n$ 很大时可能爆栈；
   - 数据规模大时应改用 `vector` 或全局数组。

## 对比与扩展

| 排序算法 | 平均时间 | 最坏时间 | 空间 | 稳定性 | 特点 |
|---------|---------|---------|------|--------|------|
| 冒泡排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 | 实现最简单，可提前退出 |
| 选择排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 不稳定 | 交换次数最少（$O(n)$） |
| 插入排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 | 基本有序时接近 $O(n)$ |
| 归并排序 | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 | 分治，稳定 $O(n\log n)$ |
| 快速排序 | $O(n\log n)$ | $O(n^2)$ | $O(\log n)$ | 不稳定 | 实际最快，需防退化 |
| 堆排序 | $O(n\log n)$ | $O(n\log n)$ | $O(1)$ | 不稳定 | 原地 $O(n\log n)$，常数较大 |

### 扩展

- **`std::sort`**：C++ 标准库采用内省排序（快排 + 堆排 + 插入排序混合），竞赛中直接调用，不必手写冒泡或选择；
- **稳定性总览**：基数、计数、插入、冒泡、归并是稳定排序；选择、堆、快速、希尔不是稳定排序；
- **选择排序的稳定化**：改用链表等结构可以使其稳定，但会失去数组随机访问的便捷，实践中几乎不用；
- **提前退出**：冒泡排序加"本轮无交换即停止"的标志位，是它唯一能在部分有序输入上优于选择排序的地方。$AKB10$, '基础算法', array['冒泡排序', '选择排序', '排序', '稳定性', '基础算法'], null, null, 'knowledge'),
('Xesir', 'col-basic-bubble-select-sort--xesir', '基础排序（冒泡 / 选择 / 归并 / 计数） · Xesir', $AKB11$## 算法原理

排序是基础算法中的一个重要部分，先导入一个基本概念：**稳定性**。

稳定性是指相等的元素经过排序之后相对顺序是否发生了改变，拥有稳定性这一特性的算法会让原本有相等键值的纪录维持相对次序。如果一个排序算法是稳定的，当有两个相等键值的纪录 R 和 S，且在原本的列表中 R 出现在 S 之前，那么在排序过的列表中 R 也将会是在 S 之前。

基数排序、计数排序、插入排序、冒泡排序、归并排序是**稳定**排序；选择排序、堆排序、快速排序、希尔排序**不是**稳定排序。

### 冒泡排序

最简单的排序算法，复杂度 $O(n^2)$，稳定。思路非常粗暴：比如要升序排列，就从前往后遍历，如果 $a>b$ 就交换。一轮下来最后一个就确定了，接着对前 $n-1$ 个也这么排。这个应该是大多数人最早接触的排序了。

### 选择排序

选择排序是一种简单直观的排序算法。它的工作原理是每次找出第 $i$ 小的元素，然后将这个元素与数组第 $i$ 个位置上的元素交换。复杂度 $O(n^2)$，一般情况下不稳定（使用链表可以使其稳定，~~真的有人用吗~~）。

### 归并排序

归并排序是非常重要的排序算法，不仅本身高效稳定，其思想也被广泛运用到其他进阶算法中。它基于分治思想，将数组分段排序后合并，复杂度 $O(n\log n)$。

递归实现时，由于 $l\sim mid$ 和 $mid+1\sim r$ 两段已分别有序，只需要两个指针就可以合并成一个有序区间。归并排序同样可以顺便算逆序对的数量，只需要每次比较时统计即可。

### 计数排序

计数排序是一种不基于比较的排序，设 $k$ 为值域则复杂度 $O(n+k)$，$k$ 较小时可视作 $O(n)$。方法很简单：设要排序的数组为 $a$，添加一个数组 $c$，其中 $c[x]$ 表示 $a$ 中 $x$ 出现的次数。遍历 $a$ 并令 `c[a[i]]++`，最后遍历 $c$ 按顺序（从前往后为升序，反之降序）输出即可。

按这种思路下的计数排序不稳定，可以通过前缀和思想使其稳定。

## 逐行代码解析

### 冒泡排序

```cpp
#include <bits/stdc++.h>

using namespace std;

int main(){
    int n;cin>>n;int v[n+10];
    for(int i=1;i<=n;i++){
        cin>>v[i];
    }
    for(int i=1;i<=n;i++){
        for(int j=i+1;j<=n;j++){
            if(v[i]>v[j])swap(v[i],v[j]);
        }
    }
    for(int i=1;i<=n;i++){
        cout<<v[i]<<" ";
    }
    return 0;
}
```

- 下标从 1 开始，数组开 `n+10` 留余量。
- 这份标着「冒泡」的代码其实是「每轮把当前最小值换到最前」的交换式写法，行为上等价于选择排序；教科书冒泡是相邻比较、每轮把最大值冒到末尾。

### 选择排序

```cpp
#include <bits/stdc++.h>
using namespace std;
int a[1010];
signed main(){
    int n;cin>>n;
    for(int i=1;i<=n;i++) cin>>a[i];
    for (int i=1;i<n;i++) {
        int zz=i;
        for (int j=i+1;j<=n;j++) {
          if(a[j]<a[zz]) zz=j;
        }
        swap(a[i],a[zz]);
      }
    for(int i=1;i<=n;i++) cout<<a[i]<<" ";
}
```

- `zz` 记录区间 $[i,n]$ 中最小值的下标，初始设为 `i`。
- 内层遇到更小的元素就把下标更新到 `zz`，一轮结束把最小值换到位置 `i`。
- 外层到 `i<n` 即止：只剩最后一个元素时它必已就位。

### 归并排序

```cpp
#include <bits/stdc++.h>
using namespace std;
void guibin(int q[], int l, int r)
{
    if(l >= r) return ;

    int mid = l + r >> 1;

    int k = 0, i = l, j = mid + 1, tmp[r - l + 1];
    while(i <= mid && j <= r)
        if(q[i] <= q[j]) tmp[k++] = q[i++];
        else {tmp[k++] = q[j++];}
    while(i <= mid) tmp[k++] = q[i++];
    while(j <= r) tmp[k++] = q[j++];

    for(k = 0, i = l; i <= r; k++, i++) q[i] = tmp[k];
}
int s[100010];int tmp[100010];
int main()
{
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>s[i];
    }
    cout<<guibin(s,1,n);
    return 0;
}
```

- `mid = l + r >> 1` 取中点：`>>` 的优先级低于 `+`，等价于 `(l + r) / 2`。
- 两个 `while` 把两段剩余元素搬进临时数组，最后整体写回 `q`。
- 合并时 `<=` 取左段元素，保证稳定。

### 归并排序求逆序对

```cpp
long long guibin(int q[], int l, int r)
{
    if(l >= r) return 0;

    int mid = l + r >> 1;

    long long ans= guibin(q, l, mid )+guibin(q, mid + 1, r);

    int k = 0, i = l, j = mid + 1, tmp[r - l + 1];
    while(i <= mid && j <= r)
        if(q[i] <= q[j]) tmp[k++] = q[i++];
        else {tmp[k++] = q[j++];ans+=mid-i+1;}
    while(i <= mid) tmp[k++] = q[i++];
    while(j <= r) tmp[k++] = q[j++];

    for(k = 0, i = l; i <= r; k++, i++) q[i] = tmp[k];
    return ans;
}
```

- 当 `q[j] < q[i]` 时，左段 `q[i..mid]` 这 `mid-i+1` 个元素都与 `q[j]` 构成逆序对，一次性累加到答案。
- 返回值改成 `long long`，防止逆序对数超过 `int`。

### 计数排序

代码太简单就不给了，看思想就明白了（源笔记配的是一张动画图）。

## 复杂度分析

| 算法 | 时间复杂度 | 空间 | 稳定性 |
|---|---|---|---|
| 冒泡排序 | $O(n^2)$ | $O(1)$ | 稳定 |
| 选择排序 | $O(n^2)$ | $O(1)$ | 不稳定 |
| 归并排序 | $O(n\log n)$ | $O(n)$ | 稳定 |
| 计数排序 | $O(n+k)$ | $O(k)$ | 前缀和版稳定 |

## 适用场景

- **小规模数据**：$n$ 几百以内时 $O(n^2)$ 也够用，代码简单不易错。
- **需要稳定且高效**：直接上归并排序。
- **值域很小**：计数排序可以做到近似线性。
- **逆序对计数**：在归并排序里顺手统计即可。

## 常见陷阱与注意事项

1. **冒泡 / 选择的两种写法别混**：源笔记里标「冒泡」的其实是交换式选择排序，做题或面试时要按题意写对。
2. **下标边界**：选择排序外层是 `i<n`，改成 0 基下标要写 `i<n-1`。
3. **`mid = l + r >> 1` 的优先级**：`>>` 比 `+` 低，别把 `(l+r)/2` 写成 `l+r>>1` 之外再套括号弄错。
4. **逆序对计数开 `long long`**：$n=10^5$ 时逆序对数可达 $5\times10^9$，`int` 会爆。
5. **变长数组**：`int tmp[r-l+1]` 是 GCC 扩展，$n$ 很大时可能爆栈，可改成 `vector` 或全局数组。
6. **计数排序的稳定性**：直接计数输出的版本不稳定，用前缀和定位可以稳定。

## 对比与扩展

| 排序算法 | 平均时间 | 最坏时间 | 空间 | 稳定性 |
|---|---|---|---|---|
| 冒泡排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 |
| 选择排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 不稳定 |
| 归并排序 | $O(n\log n)$ | $O(n\log n)$ | $O(n)$ | 稳定 |
| 计数排序 | $O(n+k)$ | $O(n+k)$ | $O(k)$ | 稳定（前缀和版） |
| 快速排序 | $O(n\log n)$ | $O(n^2)$ | $O(\log n)$ | 不稳定 |

扩展方向：`std::sort`（内省排序，快排 + 堆排 + 插入排序混合）在竞赛中直接调用即可；需要稳定排序时用归并；值域小用计数 / 基数排序。归并的「分治 + 合并」思想还会出现在 CDQ 分治、归并求逆序对等进阶算法里。$AKB11$, '基础算法', array['排序', '冒泡排序', '选择排序', '归并排序', '计数排序'], null, null, 'knowledge'),
('world-needs-sunday', 'col-basic-combination-dfs', 'DFS 生成组合（选/不选 + 剪枝）', $AKB12$## DFS 生成组合（选/不选 + 剪枝）

## 一、算法原理

### 1.1 什么是组合

从 $n$ 个不同元素中取出 $m$ 个元素（$0 \le m \le n$），不考虑顺序地组成一组，叫做从 $n$ 个不同元素中取出 $m$ 个元素的一个**组合**（Combination）。

组合数记作：

$$C(n, m) = \binom{n}{m} = \frac{n!}{m! \cdot (n-m)!}$$

例：从 5 个数中选 3 个，组合数为 $C(5, 3) = 10$。具体组合为：`1 2 3`、`1 2 4`、`1 2 5`、`1 3 4`、`1 3 5`、`1 4 5`、`2 3 4`、`2 3 5`、`2 4 5`、`3 4 5`。

**排列 vs 组合的核心区别**：
- 排列：顺序有关，`1 2 3` 和 `2 1 3` 是不同的排列
- 组合：顺序无关，`1 2 3` 和 `2 1 3` 是同一个组合（组合中元素天然递增）

### 1.2 "选/不选"的二进制决策模型

生成组合的经典思路是：**逐个考虑每个元素，对每个元素决定"选"还是"不选"**。

以 $n=5, m=3$ 为例，我们依次考虑数字 1、2、3、4、5：

- 考虑数字 1：有两种选择 → 选 1 / 不选 1
- 考虑数字 2：有两种选择 → 选 2 / 不选 2
- ...
- 考虑数字 5：有两种选择 → 选 5 / 不选 5

这形成了一棵**二叉决策树**，每个节点代表"考虑到第 $k$ 个数字，已经选了 $idx-1$ 个"的状态。

但不是所有路径都有效：只有恰好选了 $m$ 个元素的路径才是合法组合。

### 1.3 关键变量

| 变量 | 类型 | 含义 |
|------|------|------|
| `tmp[idx]` | `vector<int>` | 存储已选中的第 $idx$ 个元素（按升序存放） |
| `k` | `int` | 当前正在考虑第几个数字（从 1 到 n） |
| `idx` | `int` | 已经选了 $idx-1$ 个，下一个要放在第 $idx$ 位 |
| `m` | `int` | 总共要选多少个 |
| `n` | `int` | 总共有多少个数字 |

### 1.4 决策树示意（以 n=3, m=2 为例）

```
                考虑k=1, 已选idx=1
               /                  \
           选1                    不选1
            |                      |
    考虑k=2, idx=2          考虑k=2, idx=1
      /        \              /        \
   选2         不选2         选2       不选2
    |           |            |          |
  k=3,idx=3  k=3,idx=2    k=3,idx=2  k=3,idx=1
  ✓输出     /    \        /    \      (剪枝：剩1个要选1个，
        选3    不选3    选3    不选3    不能不选3)
         |      |        |      |
       ✓输出  ✗m=1     ✗m=1   ✗m=0
```

最终输出：`1 2`（选1选2）、`1 3`（选1不选2选3）、`2 3`（不选1选2选3），共 $C(3,2)=3$ 种 ✓

> 注意右下分支"不选1→不选2"时，剩1个数字（k=3）要选2个（m-idx+1=2），不够，所以会被剪枝，不能走"不选3"的分支。

## 二、核心公式/状态定义与转移方程

### 2.1 状态定义

**状态**：`dfs(k, idx, m, n)` 表示"正在考虑第 $k$ 个数字，已经选了 $idx-1$ 个，总共要从 $n$ 个中选 $m$ 个"。

**终止条件**：当 `idx == m + 1` 时，说明已经选够了 $m$ 个元素，得到一个合法组合，输出结果并返回。

### 2.2 两种决策（状态转移）

对于当前数字 $k$，有两种选择：

#### 决策 1：选 k（如果还没选满）

条件：`idx <= m`（还没选够 m 个）

动作：
1. `tmp[idx] = k`（把 $k$ 放到已选序列的第 $idx$ 位）
2. 递归：`dfs(k + 1, idx + 1, m, n)`（考虑下一个数字，已选数量 +1）

#### 决策 2：不选 k（如果剩下的数还够选）

条件：`n - k + 1 > m - idx + 1`（剩余可用数字 > 还需要选的数字）

> **为什么要这个条件？** 这是**剪枝**（Pruning）。如果不选当前数字 $k$，那么还需要从剩下的 $n-k$ 个数字中选 $m-(idx-1)$ 个。如果剩下的数字不够（即 $n-k < m-(idx-1)$），那么"不选"这条路必然走不通，直接剪掉。

动作：
1. 什么都不存（不选 $k$）
2. 递归：`dfs(k + 1, idx, m, n)`（考虑下一个数字，已选数量不变）

### 2.3 剪枝条件推导

我们来推导"不选"的剪枝条件：

- 在考虑数字 $k$ 时，已经选了 $idx-1$ 个
- 还需要选：$need = m - (idx - 1) = m - idx + 1$ 个
- 剩余可用数字（包括当前的 $k$）：$remain = n - k + 1$ 个
- 如果不选 $k$，则只能从后面的 $n - k$ 个数字中选 $need$ 个
- 要使"不选"可行，必须满足：$n - k \ge need$
- 即：$n - k \ge m - idx + 1$
- 变形：$n - k + 1 > m - idx + 1$（严格大于，因为去掉了k本身）

> **直觉理解**：如果剩下的数字刚好够选（`n - k + 1 == m - idx + 1`），那么当前数字必须选，没有"不选"的余地——否则后面不够凑。

### 2.4 组合数公式验证

不考虑剪枝时，每个数字有 2 种选择，总共有 $2^n$ 条路径。

经过剪枝后，只有恰好选了 $m$ 个的路径有效，数量为 $C(n, m)$，与组合数公式一致 ✓

## 三、逐行代码解析

### 3.1 全局变量与初始化

```cpp
vector<int> tmp;
void init(int m)
{
    tmp.assign(m + 1, 0);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `vector<int> tmp;` | 存储当前选中的元素，`tmp[idx]` 是第 $idx$ 个选中的数（下标从1开始） |
| 3-5 | `init(int m)` | 初始化函数，分配 $m+1$ 的空间（因为要选 m 个） |
| 4 | `tmp.assign(m + 1, 0)` | tmp 初始化为 $m+1$ 个 0 |

> **为什么不需要 vis 数组？** 因为组合是按顺序考虑的（从 1 到 n 逐个考虑），每个数字只考虑一次，天然不会重复选择。这和排列中需要标记已用元素不同。

### 3.2 DFS 核心函数

```cpp
void dfs(int k, int idx, int m, int n)
{
    if (idx == m + 1)
    {
        for (int i = 1; i <= m; i++) cout << tmp[i] << ' ';
        cout << '\n';
        return;
    }
    // 选择,没有满
    if (idx <= m)
    {
        tmp[idx] = k;
        dfs(k + 1, idx + 1, m, n);
    }
    // 不选择，剩余可填写 > 剩余需要填写
    if (n - k + 1 > m - idx + 1) dfs(k + 1, idx, m, n);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `void dfs(int k, int idx, int m, int n)` | $k$=当前考虑第几个数，$idx$=已选个数+1，$m$=要选几个，$n$=总共有几个 |
| 3 | `if (idx == m + 1)` | 终止条件：已经选够了 $m$ 个（$idx-1 == m$） |
| 5-6 | `for (...) cout << tmp[i] << ' ';` | 输出当前组合 |
| 7 | `return;` | 返回上一层 |
| 10 | `if (idx <= m)` | 还没选满时，可以选择当前数字 |
| 12 | `tmp[idx] = k;` | **记录**：把数字 $k$ 放入已选序列的第 $idx$ 位 |
| 13 | `dfs(k + 1, idx + 1, m, n);` | **递归选的分支**：考虑下一个数，已选位置+1 |
| 16 | `if (n - k + 1 > m - idx + 1)` | **剪枝条件**：剩余可用 > 还需选，才可以不选 |
| 16 | `dfs(k + 1, idx, m, n);` | **递归不选的分支**：考虑下一个数，已选位置不变 |

> **注意**：组合的 DFS 不需要显式的"回溯恢复"。为什么？
> 
> - `tmp[idx]` 在"选"的分支中被写入，但"不选"分支根本不用改 tmp
> - 当"选"的分支返回后，继续执行"不选"分支时，`tmp[idx]` 里存的旧值会不会有问题？
> - 答案是**不会**：因为"不选"分支不会访问 `tmp[idx]`（idx 不变），而如果后续"选"了别的数字，会直接覆盖 `tmp[idx]` 的值
> - 这是组合 DFS 比排列 DFS 少一步回溯的原因

### 3.3 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n, m;
    cin >> n >> m;
    init(m);
    dfs(1, 1, m, n);
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2-3 | 快速 IO | 加速输入输出 |
| 4-5 | `int n, m; cin >> n >> m;` | 读入总数 n 和要选的个数 m |
| 6 | `init(m);` | 初始化 tmp 数组（大小 m+1） |
| 7 | `dfs(1, 1, m, n);` | 从第 1 个数字开始考虑，已选 0 个（idx=1 表示下一个放第1位） |

### 3.4 执行示例（n=4, m=2）

```
dfs(1, 1, 2, 4)：考虑k=1，已选0个
├─ 选1：tmp[1]=1 → dfs(2, 2, 2, 4)
│   ├─ 选2：tmp[2]=2 → dfs(3, 3, 2, 4)
│   │   └─ idx==3 → 输出 "1 2"，返回
│   └─ 不选2？剩3个(2,3,4)需选1个 → 可以不选 → dfs(3, 2, 2, 4)
│       ├─ 选3：tmp[2]=3 → dfs(4, 3, 2, 4)
│       │   └─ idx==3 → 输出 "1 3"，返回
│       └─ 不选3？剩2个(3,4)需选1个 → 可以不选 → dfs(4, 2, 2, 4)
│           ├─ 选4：tmp[2]=4 → dfs(5, 3, 2, 4)
│           │   └─ idx==3 → 输出 "1 4"，返回
│           └─ 不选4？剩1个(4)需选1个 → 不够！剪掉
└─ 不选1？剩4个(1,2,3,4)需选2个 → 可以不选 → dfs(2, 1, 2, 4)
    ├─ 选2：tmp[1]=2 → dfs(3, 2, 2, 4)
    │   ├─ 选3：tmp[2]=3 → dfs(4, 3, 2, 4)
    │   │   └─ idx==3 → 输出 "2 3"，返回
    │   └─ 不选3？剩2个(3,4)需选1个 → 可以不选 → dfs(4, 2, 2, 4)
    │       ├─ 选4：tmp[2]=4 → dfs(5, 3, 2, 4)
    │       │   └─ idx==3 → 输出 "2 4"，返回
    │       └─ 不选4？剩1个需选1个 → 剪掉
    └─ 不选2？剩3个(2,3,4)需选2个 → 可以不选 → dfs(3, 1, 2, 4)
        ├─ 选3：tmp[1]=3 → dfs(4, 2, 2, 4)
        │   ├─ 选4：tmp[2]=4 → dfs(5, 3, 2, 4)
        │   │   └─ idx==3 → 输出 "3 4"，返回
        │   └─ 不选4？剩1个需选1个 → 剪掉
        └─ 不选3？剩2个(3,4)需选2个 → 不够！剪掉
```

最终输出 6 个组合：1 2、1 3、1 4、2 3、2 4、3 4，即 $C(4,2)=6$ ✓

## 四、复杂度分析

### 4.1 时间复杂度

$$O(m \times C(n, m))$$

**推导**：
- 共有 $C(n, m)$ 个不同的组合（叶子节点）
- 每个组合需要 $O(m)$ 的时间输出（打印 $m$ 个数）
- 搜索过程中，剪枝大大减少了无效路径
- 总节点数约为 $2 \times C(n, m)$（每个组合对应一条路径，路径上有 n 个节点，但剪枝后平均减少很多）

更精确地说，搜索树的总节点数为 $C(n+1, m)$（卡特兰式的组合恒等式），但量级上仍是组合级。

### 4.2 空间复杂度

$$O(n + m)$$

**推导**：
- `tmp` 数组：$O(m)$（存选中的 m 个元素）
- 递归栈深度：最深为 $n$ 层（逐个考虑 n 个数字），$O(n)$
- 总空间：$O(n + m)$

### 4.3 不同规模的参考

| n | m | C(n, m) | 可行性 |
|---|---|---------|--------|
| 10 | 5 | 252 | 瞬间 |
| 20 | 10 | 184,756 | < 1 秒 |
| 30 | 15 | 155,117,520 | 数秒到十几秒 |
| 40 | 20 | 137,846,528,820 | 不现实 |

当组合数超过 $10^8$ 时，暴力枚举通常不现实，需要数学方法直接求第 k 个组合或计数。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **组合枚举** | 枚举所有 C(n, m) 种选择方式，小规模问题暴力验证 |
| **子集枚举** | 当 m 不固定（枚举所有子集）时，去掉 m 的限制即可，共 $2^n$ 个子集 |
| **组合型回溯题** | 如组合求和、子集划分、01背包暴力搜索等的基础模板 |
| **字典序组合** | 本代码天然按字典序生成组合（数字从小到大考虑，选优先于不选） |
| **带剪枝的组合搜索** | 在"选/不选"框架上加入各种剪枝条件（如和的限制、重量限制等） |

## 六、常见陷阱与注意事项

### 6.1 剪枝条件写错（最常见错误）

剪枝条件是 `n - k + 1 > m - idx + 1`，很容易写错。

**记忆方法**：
- 左边 `n - k + 1`：从当前数字 $k$ 到 $n$，还有多少个数字可以选（包括 $k$）
- 右边 `m - idx + 1`：还需要选多少个（已经选了 idx-1 个，还需要 m-(idx-1) 个）
- 要"不选" $k$，就意味着剩下的 n-k 个数要能凑够 m-idx+1 个
- 即 `n - k >= m - idx + 1`，等价于 `n - k + 1 > m - idx + 1`

> **简化记忆**：剩的 > 要的，才能不选。剩的 == 要的，必须全选。

### 6.2 idx 的含义容易搞混

`idx` 表示"下一个选中的元素放在第几位"，也就是"已经选了 idx-1 个"。

- `idx = 1`：一个都没选，下一个放第 1 位
- `idx = m + 1`：已经选了 m 个，选够了（终止条件）

容易搞反成"已选 idx 个"，导致终止条件和剪枝都写错。建议写代码前先明确变量含义。

### 6.3 组合的输出天然有序

因为我们按 1→n 的顺序考虑数字，且"选"的分支先执行，所以生成的组合：
- 每个组合内部的数字是**升序**的（如 `1 3 4`）
- 组合之间按**字典序**排列

这是组合的标准形式。如果想要降序，把数字从 n 到 1 倒着考虑即可。

### 6.4 为什么不需要回溯 tmp

排列中需要恢复 `vis[i]`，因为同一层的不同分支共享 vis 数组。

组合中：
- "选"的分支写入 `tmp[idx]`，然后递归
- 递归返回后，"不选"分支不访问 `tmp[idx]`
- 即使同一层有多次"选"（实际不会，因为每层每个数字只考虑一次），也会被覆盖

所以组合 DFS 不需要显式回溯，代码比排列更简洁。

### 6.5 有重复元素的组合去重

如果元素中有重复值，简单的"选/不选"会生成重复组合。处理方法：
1. 先排序
2. 如果当前元素与前一个相同，且前一个没选，则跳过当前元素（避免重复）

### 6.6 枚举所有子集（m 不固定）

如果不限制选几个，要枚举所有 $2^n$ 个子集，去掉 m 的限制即可：

- 终止条件改成 `k > n`（考虑完所有数字）
- 去掉剪枝条件（不限制选几个）
- 每次到叶子都输出当前 tmp（长度为 idx-1）

### 6.7 另一种写法：枚举位置

还有一种组合 DFS 的写法是"枚举每个位置选谁"，类似排列但加了递增限制：

```cpp
void dfs(int pos, int start) {
    if (pos > m) { output(); return; }
    for (int i = start; i <= n; i++) {
        tmp[pos] = i;
        dfs(pos + 1, i + 1); // 下一个必须比i大
    }
}
```

这种写法更直观（像排列但加了单调性约束），但剪枝不如"选/不选"模型自然。两种写法等价，选一个自己习惯的即可。

## 七、对比与扩展

### 7.1 排列 DFS vs 组合 DFS

| 维度 | 排列 DFS | 组合 DFS（选/不选） |
|------|----------|-------------------|
| 顺序 | 有关 | 无关 |
| 模型 | 枚举每个位置放谁 | 枚举每个数字选不选 |
| 每步分支数 | $n-k+1$（递减） | 2（选/不选） |
| 关键辅助 | `vis[]` 标记数组 | 不需要 vis |
| 回溯操作 | 恢复 `vis[i] = false` | 不需要显式回溯 |
| 剪枝 | 通常不需要 | "剩余不够"剪枝 |
| 结果数 | $n!$ | $C(n, m)$ |
| 输出格式 | 排列（顺序敏感） | 递增序列（天然去重） |

### 7.2 选/不选模型 vs 枚举位置模型

| 维度 | 选/不选模型 | 枚举位置模型 |
|------|------------|-------------|
| 递归参数 | 当前考虑第几个数 k，已选个数 idx | 当前填第几个位置 pos，最小可选值 start |
| 分支方式 | 二叉（选/不选） | 多叉（枚举可选数字） |
| 剪枝方式 | 剩的不够就不能不选 | 可选范围上界 = n - (m - pos) |
| 代码风格 | 简洁，两个 if | 一个 for 循环，更像排列 |
| 适用扩展 | 子集型 DP、01背包思路 | 排列组合统一思路 |
| 总节点数 | 约 2×C(n,m) | 约 C(n,m)（叶子）+ 内部节点 |

两种模型生成的组合完全一样，只是思考角度不同。

### 7.3 组合数的计算方法

| 方法 | 适用场景 | 时间复杂度 |
|------|----------|-----------|
| 直接公式 $n!/(m!(n-m)!)$ | n 很小（n ≤ 20），用 long long | $O(n)$ |
| 递推 $C(n,m) = C(n-1,m-1) + C(n-1,m)$ | 杨辉三角，取模预处理 | $O(n^2)$ |
| 阶乘 + 逆元（取模） | n 较大，模数为质数 | $O(n)$ 预处理，$O(1)$ 查询 |
| Lucas 定理 | n 很大，模数小且为质数 | $O(\log_p n)$ |

### 7.4 扩展：求第 k 个组合

当 $n$ 很大时，不能枚举所有组合。可以用"逐位确定"的方法：

- 第 1 位：如果选 1，则剩下 n-1 个数中选 m-1 个，有 C(n-1, m-1) 种
  - 如果 k ≤ C(n-1, m-1)，则第 1 位是 1，继续确定下一位
  - 否则 k -= C(n-1, m-1)，第 1 位不是 1，尝试 2
- 重复直到确定所有 m 位

时间复杂度 $O(n)$（每次确定一位，最多 n 次）。

### 7.5 扩展：子集枚举与位运算

枚举所有 $2^n$ 个子集时，除了 DFS，还可以用**位运算**直接枚举：

```cpp
for (int mask = 0; mask < (1 << n); mask++) {
    // mask 的二进制表示中，第 i 位为 1 表示选第 i 个元素
    for (int i = 0; i < n; i++)
        if (mask & (1 << i))
            cout << i+1 << ' ';
    cout << '\n';
}
```

位运算写法更简洁，且没有递归栈开销，但只适用于 $n \le 20$（$2^{20} \approx 10^6$）的情况。

### 7.6 一句话总结

组合 DFS 的"选/不选"模型是回溯法的另一经典模板，核心是对每个元素做二选一的决策，用剪枝跳过不可能的路径。相比排列 DFS，它不需要 vis 数组和显式回溯，代码更简洁。掌握"选/不选"的思路后，子集、01背包、组合求和等一大批问题都能迎刃而解，剪枝条件的推导也是优化搜索的基本功。$AKB12$, '基础算法', array['基础算法', '搜索', '组合', 'DFS', '回溯', '递归', '剪枝'], 'col-hub-basic-search', null, 'knowledge'),
('dbywsc', 'col-basic-dfs--dbywsc', 'DFS 深度优先搜索 · dbywsc', $AKB13$## 算法原理

DFS（深度优先搜索）沿着一条路一直走，走不通再回溯，换下一条路。它强调“可达性”，不强调最短路；通常用递归实现。

DFS 的核心是**可达性 + 回溯**。思考 DFS 时从四个角度入手：

1. 初始状态怎么表示？
2. 边界情况怎么处理？
3. 如何从当前状态走向下一状态？
4. 何时需要回溯？

把每个状态看成一个点，状态之间的转移就是点与点之间的移动；回溯就是撤销当前选择，回到上一层。

### 走迷宫

从起点出发，向四个方向递归；走过的格子打标记，避免重复走。每个格子最多访问一次，时间复杂度 $O(nm)$。DFS 只回答“能不能到”，不保证最短；最短路要用 BFS。

### 全排列

有 $n$ 个位置，每个位置放一个未使用过的数。递归到第 $i$ 位时枚举所有未使用的数，放进去、标记、递归下一层、再撤销标记。方案数是 $n!$，时间复杂度 $O(n!)$。

### 组合输出

从 $1\sim n$ 中选 $m$ 个数，按升序输出组合。为了避免重复，递归时记录“上一个选的数”，下一层只从它后面选。组合数远小于排列数。

### 自然数的拆分

把 $n$ 拆成若干个正整数之和，按字典序输出。递归时记录当前剩余值、上一个选的数，保证不重复；时间复杂度与拆分数 $p(n)$ 和方案长度有关。

### 烤鸡

枚举每个配料的用量，满足总和与价格约束。每层枚举一个范围，递归到最后一层判断；方案数上限约为 $3^{10}$，直接 DFS 可过。

### 八皇后

在 $n\times n$ 棋盘上放 $n$ 个皇后，要求任意两个不在同一行、同一列、同一对角线。

逐行 DFS：第 $i$ 行放一个皇后，枚举列 $j$，检查列、主对角线、副对角线是否被占用：

- 主对角线用 `i + j` 标记；
- 副对角线用 `i - j + n` 标记（避免负数）。

放好后标记，递归下一行，回溯时撤销。由于剪枝很强，实际搜索量远小于 $n!$。

### NP 相关概念

- **P**：可以在多项式时间内解决的决策问题。
- **NP**：不一定能多项式时间解决，但给定一个解可以在多项式时间内验证的决策问题。
- **#P**：计算 NP 问题解的个数。
- **NP-complete**：NP 中最难的一类，解决它就能解决所有 NP 问题。
- **NP-Hard**：至少和 NP-complete 一样难，但不一定属于 NP。
- **#P-complete**：#P 中最难的一类。

八皇后计数是一个 #P-complete 问题；这也是为什么只能用搜索/剪枝，而没有已知多项式算法。

## 核心公式 / 状态定义与转移方程

- DFS 框架：

```text
dfs(state):
    if state is boundary:
        record answer / return
    for each next_state:
        if valid(next_state) and not visited:
            mark(next_state)
            dfs(next_state)
            unmark(next_state)   // 回溯
```

- 全排列：每层枚举未使用的数，方案数 $n!$。
- 组合：每层从上一个数之后枚举，避免重复。
- 八皇后：列用 `vis_col[j]`，主对角线用 `vis_diag1[i+j]`，副对角线用 `vis_diag2[i-j+n]`。
- 剪枝：当前代价已经不可能优于已知答案时提前返回（最优性剪枝）；当前状态已经不合法时提前返回（可行性剪枝）。

## 逐行代码解析

### 全排列

```cpp
void dfs(int dep) {
    if (dep == n + 1) {
        for (int i = 1; i <= n; i++) cout << a[i] << ' ';
        cout << '\n';
        return;
    }
    for (int i = 1; i <= n; i++) {
        if (used[i]) continue;
        used[i] = true;
        a[dep] = i;
        dfs(dep + 1);
        used[i] = false;   // 回溯
    }
}
```

- `dep` 是当前填到第几位；到 `n+1` 说明填完，输出方案。
- 每层枚举未使用的数，标记后递归，返回后撤销标记。
- 时间复杂度 $O(n!)$。

### 组合

```cpp
void dfs(int dep, int last) {
    if (dep == m + 1) {
        for (int i = 1; i <= m; i++) cout << a[i] << ' ';
        cout << '\n';
        return;
    }
    for (int i = last + 1; i <= n; i++) {
        a[dep] = i;
        dfs(dep + 1, i);
    }
}
```

- `last` 是上一个选的数，下一层只从 `last+1` 开始，保证升序且不重复。
- 不需要 `used` 数组，因为组合不关心顺序。

### 八皇后

```cpp
void dfs(int row) {
    if (row == n + 1) {
        ans++;
        return;
    }
    for (int col = 1; col <= n; col++) {
        if (vis_col[col] || vis_d1[row + col] || vis_d2[row - col + n]) continue;
        vis_col[col] = vis_d1[row + col] = vis_d2[row - col + n] = true;
        dfs(row + 1);
        vis_col[col] = vis_d1[row + col] = vis_d2[row - col + n] = false;
    }
}
```

- 逐行放皇后，每行只放一个，天然避免行冲突。
- 列、主对角线、副对角线分别用三个数组标记。
- 放好后递归下一行，回溯时撤销三个标记。

## 复杂度分析

- 走迷宫：每个格子最多访问一次，$O(nm)$。
- 全排列：$O(n!)$。
- 组合：$O\binom{n}{m}$。
- 自然数拆分：与拆分数和方案长度有关。
- 八皇后：最坏 $O(n!)$，但剪枝后远小于此。
- 空间：递归栈深度 + 标记数组，通常 $O(n)$ 或 $O(nm)$。

## 适用场景

- 需要枚举所有方案/排列/组合。
- 需要判断可达性，而不需要最短路径。
- 状态空间较小，或剪枝后实际搜索量可接受。
- 需要回溯撤销选择的问题：八皇后、数独、棋盘覆盖。
- 记忆化搜索的基础（DFS + 记录表）。

## 常见陷阱与注意事项

1. **忘记回溯**：标记后不撤销，后续分支会被错误阻塞。
2. **剪枝时机太晚**：能在进入递归前判断的，不要等到下一层；最优性剪枝要尽早。
3. **全排列/组合的重复**：组合要用 `last` 限制顺序，排列要用 `used` 数组。
4. **八皇后的对角线下标**：`row-col` 可能为负，要加偏移 $n$。
5. **递归深度**：状态链很长时可能爆栈；可以改迭代或手动开栈。
6. **搜索顺序**：先枚举更有希望的分支，能更早更新答案、增强剪枝。
7. **多测清空**：标记数组、答案在多组数据间要清空。
8. **DFS 不保证最短路**：最短路用 BFS；DFS 只保证可达。

## 对比与扩展

- **DFS vs BFS**：DFS 一条路走到底，适合枚举/回溯；BFS 按层扩展，适合最短路。
- **DFS vs 记忆化搜索**：DFS 会重复搜索相同状态；记忆化把算过的状态存起来，避免重复。详见 [记忆化搜索](#dp-memo-search)。
- **剪枝 vs 记忆化**：剪枝去掉不可能的分支，记忆化避免重复状态；两者可以同时使用。
- **讲义练习**：TW2112 走迷宫、A5001 全排列、A5002 组合的输出、C1033 自然数的拆分、A2022 烤鸡、A5007 八皇后、A5017 小猫爬山、YL1076D8 空调温度、TW2014 斐波那契、A5005 滑雪、P1114 跳台阶、P1115 走方格、YL1023B4 一维分型图、A5006 棋盘问题、A3119 字母组合、A5022 靶型数独。题号以原讲义为准。$AKB13$, '基础算法', array['DFS', '回溯', '剪枝', '全排列', '八皇后', '记忆化搜索'], 'col-hub-basic-search', null, 'knowledge'),
('Fohen', 'col-basic-dfs--fenfeng', 'DFS 深度优先搜索 · Fohen', $AKB14$## 算法原理

深度优先搜索（Depth First Search，DFS）是一种沿着某条路径**尽可能深入**、走到无路可走再回退的搜索方式，俗称"不撞南墙不回头"。它通常用**递归**实现：每进入一层，就固定住当前的部分状态，再向更深处继续试探，直到触及终止条件才返回。

DFS 的运作方式和树的递归遍历同构：在二叉树上，先序、中序、后序三种遍历本质上都是 DFS，区别只在于**访问节点的时机**不同（先访问再深入、深入左子树后再访问、左右都深入后再访问）。这也解释了为什么 DFS 天然适合用递归书写。

一次完整的 DFS 由三个要素构成：

1. **终止条件（边界）**：递归到底、当前状态已经是一个完整解，或已经无路可走时返回。
2. **枚举分支（状态扩展）**：在当前状态下，枚举所有"可行"的下一步。
3. **回溯（恢复现场）**：从一个分支返回后，撤销该分支所做的修改，让同一层的其他分支能干净地继续。

以"输出 $1 \sim n$ 的全排列"为例：第 $k$ 位从尚未使用的数中选一个填入，递归填第 $k+1$ 位，填满 $n$ 位就是一个排列；返回时撤销"已使用"标记，换下一个数。这正是 DFS + 回溯的经典形态。

## 核心公式 / 状态定义与转移方程

**状态定义**：DFS 的"状态"即当前递归参数，它完整描述"已经走到了哪一步、之前做过哪些选择"。例如全排列中，状态可记作 $\text{dfs}(k)$，表示"前 $k-1$ 位已经填好，现在要填第 $k$ 位"。

**状态转移**：从状态 $S$ 出发，枚举所有合法后继 $S'$，对每个后继递归进入更深一层；到达叶子（终止条件）时得到一个完整解。其递归框架可写为：

$$
\text{dfs}(S) = \bigcup_{S' \in \text{next}(S)} \text{dfs}(S'), \qquad S \text{ 是叶子时直接记录结果并返回}
$$

对全排列，状态转移可写成：

$$
\text{dfs}(k) \to \bigcup_{\substack{1 \le i \le n \\ i \text{ 尚未使用}}} \text{dfs}(k+1)
$$

选择 $i$ 时"标记已用 → 递归深入 → 撤销标记"，就是回溯的标准写法；$n$ 个元素的全排列共有 $n! = n \times (n-1) \times \cdots \times 1$ 种，对应搜索树的叶子数。

## 逐行代码解析

下面给出 DFS 的**通用递归模板**（伪代码，非完整可运行程序）：

```cpp
void dfs(状态 s) {
    if (到达终止条件) {          // ① 边界：当前状态已是一个完整解
        记录 / 输出结果;
        return;                  //    递归到底，返回上一层
    }
    for (枚举 s 的所有合法后继 s') {   // ② 枚举分支
        做出选择 / 打标记;       //    进入该分支前所做的修改
        dfs(s');                 // ③ 递归深入
        撤销选择 / 恢复现场;     // ④ 回溯，供同层其他分支复用
    }
}
```

逐条解释：

- **① 终止条件**：决定递归何时停止。全排列中是"已填满 $n$ 位"，此时输出并 `return`。
- **② 枚举分支**：当前状态下的合法选择集合。全排列中是"所有尚未使用的数字 $i$"。
- **③ 递归深入**：带着新状态进入下一层，是"不撞南墙不回头"的体现。
- **④ 回溯**：返回后撤销本分支的修改（如把"已使用"标记改回"未使用"），否则后续分支会看到被污染的状态。

以全排列为例的伪代码：

```cpp
void dfs(int k, int n) {
    if (k > n) {                  // 已填满 n 位
        输出当前排列;
        return;
    }
    for (int i = 1; i <= n; i++) {
        if (i 已被使用) continue; // 剪枝：跳过不可用的分支
        标记 i 已使用;
        把 i 放入第 k 位;
        dfs(k + 1, n);            // 递归填下一位
        恢复 i 未使用;            // 回溯
    }
}
```

"自然数拆分"（把 $n$ 拆成若干正整数之和）同理：状态为"当前剩余值 $rest$ 与上一次选的加数 $last$"，枚举下一个加数（不小于 $last$ 以避免重复计数），$rest$ 减到 $0$ 即得到一个拆分。

## 复杂度分析

DFS 没有与问题无关的统一复杂度，须**视具体实现与问题规模**而定：

| 形态 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 图 / 树遍历（每个点、每条边各访问一次） | $O(V+E)$ | $O(V)$（访问标记 + 递归栈） |
| 枚举 / 回溯（如全排列） | $O(n \times n!)$（叶子数乘单解开销） | $O(n)$（递归栈深度） |
| 指数级状态空间搜索 | 指数级，高度依赖剪枝 | 视搜索树深度 |

空间上，DFS 的瓶颈主要是**递归栈深度**：树退化成链时最深可达 $O(n)$；图遍历还需 $O(V)$ 的访问标记数组。因此递归版 DFS 在深度很大的问题上可能栈溢出，需改用迭代（手工栈）或调大栈空间。

## 适用场景

- **图 / 树的遍历与连通性**：判断两点是否可达、求连通块、生成树、环检测、拓扑排序。
- **枚举与回溯**：全排列、组合、子集、自然数拆分等"穷举所有解"的小规模问题。
- **存在性 / 计数问题**：是否存在一条路径、共有多少种方案。
- **记忆化搜索的前置**：在 DFS 框架上加一个"记忆数组"，就得到自顶向下的动态规划。
- **二叉树的前 / 中 / 后序遍历**：本质都是 DFS。

## 常见陷阱与注意事项

1. **忘记回溯**：递归返回后未撤销标记，导致同层其他分支看到"已用尽"的假象，只能得到一个解（全排列只输出第一个排列就是典型表现）。
2. **递归栈溢出**：链式深度的图 / 树会栈溢出，应改用迭代（手工栈）或增大栈空间。
3. **重复访问**：图遍历应在**进入节点时**标记访问，而不是等到出栈；无向图还要避免"原地返回父节点"造成的死循环。
4. **缺少剪枝**：枚举型 DFS 若不提前排除非法分支，搜索树会爆炸式增长；越早"撞到边界"回退，越省时间。
5. **字典序要求**：若要按字典序输出，须保证枚举顺序有序（全排列里 $i$ 从小到大枚举即可）。
6. **状态定义要能唯一描述局面**：递归参数必须完整包含"已做的选择"，否则回溯时无法正确恢复现场。

## 对比与扩展

**DFS vs BFS**

| 维度 | DFS | BFS |
|---|---|---|
| 数据结构 | 递归栈（或手工栈） | 队列 |
| 遍历顺序 | 沿一条路走到底再回退 | 按"距离由近到远"逐层扩展 |
| 首次到达 | 不保证最短 | 边权相同的图上首次到达即最短 |
| 适用 | 存在性、枚举、拓扑、连通块 | 最短路、层次遍历、最少步数 |

**手写 DFS vs `next_permutation`**：手写 DFS 更灵活，能在递归中加剪枝、记录中间状态；`next_permutation` 只用于"生成全排列"这一件事，代码更短但扩展性差。

**扩展方向**：

- **迭代式 DFS**：用手工栈替换递归，规避栈溢出。
- **剪枝 / 迭代加深（IDDFS）**：限制深度并逐层加大，兼顾深搜的空间与"找最优"。
- **记忆化搜索**：DFS + 记忆数组，把重复子状态缓存，退化为自顶向下 DP。
- **启发式搜索（A*）**：在搜索中加入估价函数，缩小搜索空间。

一句话总结：DFS 的核心是"递归深入 + 枚举分支 + 回溯恢复现场"，它既是图 / 树遍历的基础，也是回溯、记忆化搜索等大量算法的起点。$AKB14$, '基础算法', array['搜索', '深度优先搜索', '回溯', '递归', '枚举'], 'col-hub-basic-search', null, 'knowledge'),
('Xesir', 'col-basic-dfs--xesir', 'DFS 深度优先搜索 · Xesir', $AKB15$## 算法原理

~~你们要的爆搜来了~~

搜索是算法领域的核心基础，中心思想是 ~~骗分~~ 通过系统性遍历或策略性探索问题的解空间，从海量可能性中精准找到符合条件的目标解，通俗地说就是遍历所有情况找答案 ~~暴力出奇迹~~。考场上如果没思路，先敲个暴力拿部分分往往是不错的选择，而暴力算法往往就是用搜索实现（当然别忘了剪枝，不然 TLE 向你招手）。搜索不只是纯粹的暴力，许多 ~~并不~~ 高阶的算法如图论、DP 等都需要搜索，所以这是 OI 最最最重要的基础！原笔记还附了[搜索宗宗主](https://ylcourt.cn/user-home?username=qx003&uid=fc23579637fa4b6fbaaa9fef831afad1)的主页，图论里的 DFS 另见 [oi.wiki/graph/dfs](https://oi.wiki/graph/dfs/)。

DFS 即**深度优先搜索**（Depth First Search），顾名思义就是一直向更深的节点走，也就是俗称的"不撞南墙不回头"，其运作方式类似中序遍历，通常采用**递归**方式实现。

光说理解不了，还是看几个模板罢：下面用「全排列」和「自然数拆分」两个经典例题来体会 DFS 的形态。

## 逐行代码解析

### 全排列 · 全局变量与状态数组

```cpp
#include <bits/stdc++.h>
using namespace std;
int h[700];
bool st[700];
```

- `h[]` 存当前正在填的排列；`st[i]` 标记数字 $i$ 是否已被用过。
- 数组开到 700，是给 $n$ 留足空间，避免越界。

### 全排列 · dfs 递归函数

```cpp
//一般实现方式
void dfs(int x,int n){
    if(x==n+1){
        for(int i=1;i<=n;i++){
            cout<<"    "<<h[i];
        }
        cout<<endl;
        return;
    }
    for(int i=1;i<=n;i++){
        if(!st[i]){
            st[i]=true;
            h[x]=i;
            dfs(x+1,n);
            st[i]=false;
        }
    }
}
```

- `x` 表示当前要填第几位；当 `x == n+1` 时说明 $n$ 位已经填满，输出当前排列后 `return`。
- 枚举 $1 \sim n$，只有 `st[i]` 为假（没用过）才可选：`st[i]=true` 标记已用，`h[x]=i` 记下本位，递归填下一位，回来后 `st[i]=false` **恢复现场**（回溯）。
- 数字从小到大枚举，输出的排列天然按字典序。

### 全排列 · main 函数

```cpp
int main()
{
    int n;cin>>n;
    dfs(1,n);
return 0;
}
```

- 读入 $n$，从第 1 位开始搜索。

### 用 next_permutation 求全排列

```cpp
int main() {
    vector<int> nums = {1,2,3};//这里加序列，单增
    do {
        for (int x : nums) cout << x << " "; // 输出当前排列
        cout << endl;
    } while (next_permutation(nums.begin(), nums.end())); // 循环找下一个排列
    return 0;
}
```

- `next_permutation` 直接把 `nums` 变成"下一个字典序排列"，`do…while` 保证初始排列也被输出一次。
- 默认使用 `<` 比较字典序，也可以传 `cmp` 自定义，写成 `next_permutation(beg, end, cmp)`。
- 反向功能是 `prev_permutation`（找前一个字典序排列）。前提是序列**单增**，否则只能枚举出从当前状态起的部分排列。

### 自然数拆分

```cpp
#include <bits/stdc++.h>
using namespace std;
int h[700];
bool st[700];
void dfs(int x,int n){
    if(x==n+1){
        for(int i=1;i<=n;i++){
            cout<<"    "<<h[i];
        }
        cout<<endl;
        return;
    }
    for(int i=1;i<=n;i++){
        if(!st[i]){
            st[i]=true;
            h[x]=i;
            dfs(x+1,n);
            st[i]=false;
        }
    }
}
int main()
{
    int n;cin>>n;
    dfs(1,n);
return 0;
}
```

- 自然数拆分与全排列同源：同样是"枚举 → 标记 → 递归 → 回溯"的框架。
- 注意：原笔记这一段的示例代码与上面的全排列模板**逐字相同**（直接复用了那一份）。要真正做拆分（把 $n$ 拆成若干正整数之和、按不降序去重计数），状态应改成"剩余值 / 上一个加数"再枚举加数，具体实现交给本人。

## 复杂度分析

DFS 没有与问题无关的统一复杂度，得**视具体实现与问题规模**而定：

- **枚举 / 回溯型**（如全排列）：搜索树叶子数为 $n!$，每个叶子输出 $O(n)$，总时间 $O(n \times n!)$；递归深度 $O(n)$，空间 $O(n)$（另有 `h` / `st` 各 $O(n)$）。
- **图 / 树遍历型**：每个点、每条边各访问一次，时间 $O(V+E)$，空间 $O(V)$（访问标记 + 递归栈）。
- 空间瓶颈主要是**递归栈深度**：链状图会退化到 $O(n)$ 深，深度过大可能爆栈。

## 适用场景

- **枚举所有方案**：全排列、组合、子集、自然数拆分等规模较小的"穷举所有解"问题。
- **图 / 树遍历**：判断连通性、求连通块、环检测、拓扑排序、生成树。
- **存在性 / 计数**：是否存在一条路径、共有多少种方案。
- **记忆化搜索的前置**：在 DFS 框架上加记忆数组，就得到自顶向下的 DP。
- 二叉树的前 / 中 / 后序遍历，本质都是 DFS。

## 常见陷阱与注意事项

1. **忘记回溯**：递归返回后没撤销 `st[]`，同层其他分支就看不到可用数字，全排列只会输出第一个排列。
2. **递归栈溢出**：深度很大的图 / 树（尤其链状）会爆栈，需要改成迭代（手工栈）或调大栈空间。
3. **重复访问**：图遍历要在**进入节点时**标记，无向图还要避免"原地回到父节点"造成死循环。
4. **字典序要求**：要按字典序输出时，枚举顺序必须有序（全排列里 $i$ 从小到大枚举即可）。
5. **缺少剪枝**：别忘了剪枝，不然 TLE 向你招手 ~~暴力出奇迹~~。
6. **`next_permutation` 的前提**：序列必须单增，否则只能枚举出从当前状态起的后续排列。

## 对比与扩展

| 维度 | DFS | BFS |
|---|---|---|
| 数据结构 | 递归栈（或手工栈） | 队列 |
| 遍历顺序 | 一条路走到底再回退 | 按距离由近到远逐层扩展 |
| 首次到达 | 不保证最短 | 边权相同时首次到达即最短 |
| 适用 | 存在性、枚举、拓扑、连通块 | 最短路、层次遍历、最少步数 |

- **手写 DFS vs `next_permutation`**：手写更灵活，能在递归里加剪枝、记录中间状态；`next_permutation` 只干"生成全排列"这一件事，代码更短但扩展性差。
- **扩展方向**：迭代式 DFS（手工栈，规避爆栈）、迭代加深（IDDFS）、记忆化搜索（DFS + 记忆数组 → 自顶向下 DP）、启发式搜索（A\*）。

一句话总结：DFS 的核心是"递归深入 + 枚举分支 + 回溯恢复现场"，既是图 / 树遍历的基础，也是回溯、记忆化搜索等大量算法的起点。$AKB15$, '基础算法', array['搜索', '深度优先搜索', '回溯', '递归', '全排列'], 'col-hub-basic-search', null, 'knowledge'),
('world-needs-sunday', 'col-basic-digit-power-cycle-self', '按数位分层扩张幂周期算法（洛谷 P1050）', $AKB16$## 算法原理

本算法解决洛谷 P1050 问题：给定大整数 $A$（可达 $100$ 位）和 $k$，求最小的正整数 $t$，使得 $A^{t+1} \equiv A \pmod{10^k}$，即 $A$ 的幂次在末 $k$ 位上的循环长度。由于 $A$ 的位数远超基本数据类型，且 $t$ 本身可能是极大的数，无法用普通取模快速幂直接求解，需要采用逐位提升（Hensel lifting）策略。

算法的核心是按数位从低到高逐位确定循环节。维护一个不变量：`tg = A^ans`（在模 $10^k$ 意义下），且 $A \cdot \text{tg} \equiv A \pmod{10^i}$，即 `ans` 是前 $i$ 位的一个合法循环长度。初始时 `ans = 1`，`tg = A`，显然 $A \cdot A = A^2 \equiv A \pmod{10^0}$（模 $1$ 恒成立）。

提升到第 $i+1$ 位时，需要找到最小的 $j \in [1, 10]$ 使得 $A \cdot \text{tg}^j$ 在第 $i$ 位上与 $A$ 匹配。其数学依据是：由于 $A \cdot \text{tg} \equiv A \pmod{10^i}$，可设 $A \cdot \text{tg} = A + c \cdot 10^i$，则利用 $(1 + c \cdot 10^i)^j \equiv 1 + j \cdot c \cdot 10^i \pmod{10^{i+1}}$（二项式展开中高阶项被 $10^{i+1}$ 整除），$A \cdot \text{tg}^j$ 在第 $i$ 位的值随 $j$ 线性变化，$j \in [1, 10]$ 恰好覆盖该位的全部 $10$ 种可能。找到匹配的 $j$ 后，更新 $\text{ans} \leftarrow \text{ans} \times j$，$\text{tg} \leftarrow \text{tg}^j$，不变量提升到 $i+1$ 位。

实现上，`mul(a, b, k)` 是截断到末 $k$ 位的高精度乘法（相当于模 $10^k$），`add(j)` 实现大数 `ans` 乘以小整数 $j$ 的全精度运算（因为 `ans` 可能非常大，不能截断）。每位提升时先检查 $j=1$（即当前 `tg` 已使该位匹配），若匹配则直接 `continue` 不累乘；否则逐个尝试 $j=2, \ldots, 10$，用 `newtg` 从 `tg` 起反复乘 `tg` 递推得到 $\text{tg}^j$，找到匹配后更新。

## 核心公式

问题目标（求最小循环长度 $t$）：
$$A^{t+1} \equiv A \pmod{10^k}$$

不变量（提升到第 $i$ 位时成立）：
$$\text{tg} = A^{\text{ans}} \pmod{10^k}, \quad A \cdot \text{tg} \equiv A \pmod{10^i}$$

Hensel 提升的线性近似（设 $A \cdot \text{tg} = A + c \cdot 10^i$）：
$$(1 + c \cdot 10^i)^j \equiv 1 + j \cdot c \cdot 10^i \pmod{10^{i+1}}$$

逐位找最小 $j$：
$$j = \min \{ j \in [1, 10] : (A \cdot \text{tg}^j)_i = (A)_i \}$$

状态更新：
$$\text{ans} \leftarrow \text{ans} \times j, \quad \text{tg} \leftarrow \text{tg}^j \pmod{10^k}$$

## 逐行代码解析

### 头文件与 num 结构体

```cpp
#include<bits/stdc++.h>
using namespace std;
/*洛谷P1050*/
struct num
{
	int v[105];                    // 低位在前存储十进制位
	num() { memset(v, 0, sizeof(v));}
};
```

- `v[105]` 低位在前存储十进制位，使竖式乘法的进位方向（低位→高位）与数组下标递增方向一致，简化实现；`105` 位足以容纳 $k \le 100$ 的输入。
- 构造函数 `num()` 用 `memset` 把 105 个 `int` 全部清零，避免局部变量未初始化产生脏数据。

### read：读入大整数

```cpp
// 读入大整数，逆序存储（低位在前）
void read(num& tmp)
{
	char ch = getchar();
	int idx = 0;
	while (ch <= '9' && ch >= '0')
	{
		tmp.v[idx++] = ch - 48;
		ch = getchar();
	}
	reverse(tmp.v, tmp.v + idx);   // 逆序：低位在前
}
```

- 用 `getchar()` 逐字符读入，`ch - 48` 把 ASCII 数字转为 0~9；循环条件 `ch <= '9' && ch >= '0'` 判断是否为数字字符。
- 先正序读入、再 `reverse`，保证低位在前；若忘记逆序，后续乘法的进位方向会完全错乱。
- `read` 在遇到非数字字符（换行/空格）时停止，随后由 `scanf` 读走后面的 $k$。

### mul：截断到末 k 位的高精度乘法

```cpp
// 截断到末 k 位的高精度乘法（等价于模 10^k）
struct num mul(num& a, num& b, int k)
{
	num ans;
	for (int i = 0; i < k; i++)
	{
		for (int j = 0; j < k; j++)
		{
			if(i + j < k) ans.v[i + j] += a.v[i] * b.v[j];
		}
	}
	for (int i = 0; i < k; i++)
	{
		ans.v[i + 1] += ans.v[i] / 10;
		ans.v[i] %= 10;
	}
	return ans;
}
```

- 第三参数 `k` 控制只保留末 $k$ 位（`if(i + j < k)` 丢弃高位），等价于模 $10^k$ 运算——提升第 $i$ 位时只需关注末 $k$ 位。
- 双重循环做竖式乘法，乘积累加到 `ans.v[i+j]`，随后的单循环统一处理进位（`/10` 与 `%10`）。
- 进位写 `ans.v[i+1]` 时最大下标为 $k$（$i=k-1$），仍在 `v[105]` 内，不会越界。
- 返回值为新对象（值传递），因此 `newtg = mul(newtg, tg, k)` 里 `newtg` 同时作输入输出也安全。

### 全局变量与 add：大数乘小整数

```cpp
int ans[200];
int n = 1;
void add(int j)
{
	int tmp[200];
	memset(tmp, 0, sizeof(tmp));
	for (int i = 0; i < n; i++) tmp[i] = ans[i] * j;
	int i = 0;
	while (i < n || tmp[i] != 0)
	{
		tmp[i + 1] += tmp[i] / 10;
		tmp[i] %= 10;
		++i;
	}
	n = i;
	for (int i = 0; i < n; i++) ans[i] = tmp[i];
}
```

- `ans[200]` 是全精度大数（循环长度 $t$），`n` 记录当前位数；$t$ 可能远超 $10^k$，必须用大数存储。
- `add` 实现大数乘小整数 $j$：先逐位乘 $j$ 存入 `tmp`，再用 `while` 循环统一进位并自动扩长。
- `while (i < n || tmp[i] != 0)` 保证所有进位都被处理，循环退出时 `i` 恰为新的位数，`n = i` 记录之。
- `tmp` 每次 `memset` 清零，避免上次调用的残留。

### main：逐位提升主流程

```cpp
int main()
{
	int k;
	num A;
	read(A);
	scanf("%d", &k);

	num tg = A;
	ans[0] = 1;
	for (int i = 0; i < k; i++)
	{
		bool fg = false;
		num tmp = mul(A,tg,k);
		if (tmp.v[i] == A.v[i]) continue;
		else
		{
			num newtg = tg;
			for (int j = 2; j <= 10; j++)
			{
				newtg = mul(newtg, tg, k);
				if (mul(A, newtg, k).v[i] == A.v[i])
				{
					add(j);
					fg = true;
					tg = newtg;
					break;
				}
			}
			if (!fg)
			{
				printf("-1");
				return 0;
			}
		}
	}
	n -= 1;
	while (n >= 0)
	{
		putchar(ans[n] + 48);
		--n;
	}
	return 0;
}
```

- `tmp = mul(A, tg, k)` 后比较 `tmp.v[i] == A.v[i]`，先处理 $j=1$：当前 `tg` 已使第 $i$ 位匹配时直接 `continue`，`ans` 与 `tg` 保持不变。
- 否则 `newtg` 从 `tg` 起反复乘 `tg`，递推得到 $\text{tg}^2, \text{tg}^3, \ldots, \text{tg}^j$；找到第 $i$ 位匹配后 `add(j)` 更新 `ans`、`tg = newtg`。
- `for (int j = 2; j <= 10; j++)` 上界 $10$ 恰好覆盖该位全部 $10$ 种取值；若 $j=2\sim10$ 都不匹配则无解，输出 `-1`。
- 末尾 `n -= 1` 把「位数」转成「最高位下标」，再从高位到低位 `putchar(ans[n] + 48)` 输出答案。

## 复杂度分析

每位提升最多尝试 $10$ 个 $j$ 值，每次尝试需计算一次 `mul`（$O(k^2)$）和一次验证 `mul`（$O(k^2)$）。$k$ 位共需 $k$ 轮提升，因此总时间复杂度为 $O(10k \cdot k^2) = O(10k^3)$。对于 $k = 100$，约 $10^7$ 量级基本运算，可在时限内完成。`add` 的复杂度为 $O(|\text{ans}|)$（`ans` 的位数），远小于 $O(k^2)$，不构成瓶颈。空间上 `num` 结构体为 $O(k)$，`ans` 数组为 $O(200)$，总空间复杂度为 $O(k)$。

## 适用场景

超大整数（$100$ 位以上）的幂末位循环长度问题、同余周期问题、普通取模快速幂无法承载的大数场景。适用于需要逐位确定解的 Hensel 提升类问题。

## 常见陷阱与注意事项

1. **`j` 的范围必须是 $1 \sim 10$**：第 $i$ 位有 $10$ 种可能值（$0 \sim 9$），$j$ 从 $1$ 到 $10$ 恰好覆盖。若 $j$ 上界不足 $10$ 可能遗漏解，若超过 $10$ 则产生冗余计算（$j$ 和 $j+10$ 在该位等价）。
2. **$j=1$ 的特殊处理**：当该位已匹配时 `continue` 不累乘。若误将 $j=1$ 也执行 `add(1)`，虽然 `ans * 1 = ans` 不改变值，但 `tg = tg^1 = tg` 也不变，逻辑正确但多余。关键是不能遗漏 $j=1$ 的检查。
3. **`tg` 和 `newtg` 的引用安全**：`newtg = mul(newtg, tg, k)` 中 `newtg` 同时作为输入和输出。由于 `mul` 返回新对象（值传递），不会出现引用被修改后再读取的问题。但若改为引用传递则需注意。
4. **`add` 中 `n` 的修正**：`add` 的进位循环 `while (i < n || tmp[i] != 0)` 在最后一次进位为零时仍会执行一轮使 `i` 多走一步，导致 `n` 偏大 $1$。输出前 `n -= 1` 修正此偏差。
5. **无解情况**：若某位 $j=1 \sim 10$ 均无法匹配（当 $A$ 与 $10$ 不满足特定条件时），返回 $-1$。题目通常保证有解，但在推广场景中需处理。
6. **大整数读入的逆序**：`read` 先正序读入再 `reverse`，确保低位在前。若忘记逆序则乘法进位方向错误，结果完全不对。
7. **数组越界风险**：`read` 用 `tmp.v[idx++]` 逐字符写入但未判 `idx` 上限，输入超过 105 位会越界写；`add` 固定 `ans[200]`/`tmp[200]` 且进位循环无位数上限校验，`n` 超过 200 时同样越界。本题约定 $A \le 100$ 位、$k \le 100$ 不会触发，推广时应加 `idx < 105`、`n < 200` 之类的上限判断。

## 对比与扩展

与参考模板版本相比，本实现将 $j=1$ 情形单独提取为 `continue`，逻辑更清晰但代码稍长。模板版本将 $j=1$ 纳入统一循环（`for(j=1;j<=10;j++)`），更简洁但语义略隐晦。两种写法在数学上完全等价。与暴力枚举循环节（枚举 $t = 1, 2, \ldots$ 直到 $A^{t+1} \equiv A$）相比，逐位提升将指数级搜索降为多项式级。扩展方向包括：处理 $A$ 与 $10$ 不互质的情形（需分离 $2$ 和 $5$ 的因子）、推广到任意进制基 $B$ 的幂周期问题、以及利用 Euler 定理和 Carmichael 函数分析循环节的理论上界。$AKB16$, '基础算法', array['基础算法', '数位提升', 'Hensel提升', '大整数', '幂周期', 'P1050'], null, null, 'knowledge'),
('world-needs-sunday', 'col-basic-divide-conquer-closest-pair', '最近点对（平面最小点对，分治）', $AKB17$## 最近点对（平面最小点对，分治）

## 一、算法原理

### 1.1 问题描述

**平面最近点对问题**：给定平面上 $n$ 个点，找出距离最近的两个点之间的距离。

暴力做法：枚举所有点对，计算距离取最小值。时间复杂度 $O(n^2)$。

当 $n = 10^5$ 时，$n^2 = 10^{10}$，暴力完全超时。我们需要更高效的算法。

### 1.2 分治思想

分治算法的核心是"分而治之"，三步框架：

1. **划分（Divide）**：将点集按 x 坐标排序后，从中间切成左右两半
2. **解决（Conquer）**：递归求左半部分的最小距离和右半部分的最小距离，取较小值记为 $d$
3. **合并（Merge）**：检查是否存在跨越中线的点对，其距离小于 $d$，如果有则更新 $d$

关键难点在**合并步骤**——如何高效检查跨越中线的点对？

### 1.3 带状区域与鸽巢原理

假设左右两半的最小距离是 $d$，那么跨越中线的最近点对一定满足：两个点分别在中线两侧，且它们到中线的 x 方向距离都小于 $d$（否则 x 方向的差就已经 ≥ d，距离不可能更小）。

因此只需考虑**带状区域**内的点：x 坐标在 $[mid_x - d, mid_x + d]$ 范围内的点。

带状区域里有多少个点？如果有很多，合并又退化成 $O(n^2)$ 了。

**鸽巢原理救场**：在带状区域内，任取一个点 $p$，在它的 y 方向 $d$ 范围内（即 $[p.y - d, p.y + d]$），最多有多少个点？

- 把这个 $2d \times d$ 的矩形（中线左右各 $d$，上下各 $d$ 的一半）切成 6 个 $d/2 \times 2d/3$ 的小矩形
- 每个小矩形内最多只能有 1 个点（否则左右两半各自的最小距离就会小于 $d$，矛盾）
- 所以总共最多 6 个点

也就是说，**对于带状区域中的每个点，只需要和它后面（y 更大的）最多 6 个点比较距离**，就一定不会漏掉最近点对。

这样合并阶段的时间复杂度是 $O(n)$（每个点常数次比较），加上划分的开销，总复杂度 $O(n \log n)$。

### 1.4 算法流程

```
         按 x 排序的点集
              │
     ┌────────┴────────┐
   左半部分          右半部分
     │                  │
  递归求 d1          递归求 d2
     └────────┬────────┘
              │
         d = min(d1, d2)
              │
    取中线附近 x 距离 ≤ d 的点（带状区域）
              │
    按 y 排序，每个点与后面最多6个点比较
              │
         更新最小距离 d
              │
            返回 d
```

### 1.5 本代码的巧妙之处

本实现不是在每一层都单独对带状区域按 y 排序（那样总复杂度会变成 $O(n \log^2 n)$），而是**在归并排序的过程中顺便完成 y 坐标的排序**：

- 递归返回时，左右两半已经各自按 y 排好序了
- 合并时用归并排序的 merge 步骤，把两半按 y 合并成一个有序序列
- 同时在归并过程中，顺手把距离中线 ≤ d 的点筛选到 tmp2 中
- 这样每一层都是 $O(n)$，总复杂度严格 $O(n \log n)$

### 1.6 关键变量

| 变量 | 类型 | 作用 |
|------|------|------|
| `A[i]` | `pair<long long, long long>` | 第 i 个点（first=x, second=y） |
| `d_2` | `long long` | 当前找到的最小距离的平方（避免开方，减少精度损失） |
| `tmp1[]` | 点数组 | 归并排序的辅助数组（存按 y 排序的结果） |
| `tmp2[]` | 点数组 | 带状区域内的点（按 y 升序） |
| `mid_x` | `long long` | 中线的 x 坐标（左半部分最右点的 x） |

## 二、核心公式/状态定义与转移方程

### 2.1 距离公式

两点 $a(x_1, y_1)$ 和 $b(x_2, y_2)$ 的距离平方：

$$dist^2(a, b) = (x_1 - x_2)^2 + (y_1 - y_2)^2$$

整个算法中都用距离平方进行比较，避免开方运算：
- 减少浮点运算，提高速度
- 避免浮点精度误差
- 最后输出答案时再开一次根号

### 2.2 分治递归式

设 $T(n)$ 为 $n$ 个点的最近点对问题的时间复杂度：

$$T(n) = 2 \cdot T(\frac{n}{2}) + O(n)$$

- $2 \cdot T(n/2)$：递归处理左右两半
- $O(n)$：归并排序 + 带状区域查找

根据主定理（Master Theorem），$a=2, b=2, f(n)=O(n)$，满足 $f(n) = \Theta(n^{\log_b a})$，所以：

$$T(n) = O(n \log n)$$

### 2.3 带状区域的鸽巢原理

**定理**：在宽度为 $2d$ 的带状区域中（中线两侧各 $d$），如果已知左右两半内部的最小距离 ≥ d，那么在任意 $d \times 2d$ 的矩形内，最多有 6 个点。

**证明**：
- 将 $d \times 2d$ 的矩形（高为 d，宽为 2d，中线在中间）分成 6 个 $d/2 \times 2d/3$ 的小矩形
- 每个小矩形的对角线长：$\sqrt{(d/2)^2 + (2d/3)^2} = \sqrt{d^2/4 + 4d^2/9} = \sqrt{25d^2/36} = 5d/6 < d$
- 如果某个小矩形内有 2 个点，它们的距离 < d，与"左右两半各自最小距离 ≥ d"矛盾
- 因此每个小矩形最多 1 个点，6 个小矩形最多 6 个点

**推论**：带状区域内按 y 排序后，每个点只需和后面最多 6 个点比较距离。

### 2.4 归并排序的副作用

`solve(l, r)` 有两个作用：
1. **返回值**：返回区间 $[l, r]$ 中 x 坐标的最大值（即最右点的 x）
2. **副作用**：将 $A[l..r]$ 按 y 坐标升序排序（归并排序）

返回值 `mid_x` 用作中线位置，副作用提供按 y 排序的序列用于带状区域筛选。

> 这是本代码最精巧的设计：一个函数同时完成了"求最小距离"、"归并排序按 y 排"、"返回中线 x 坐标"三件事。

### 2.5 带状区域筛选条件

对于点 $p$，如果它到中线的 x 方向距离的平方 ≤ 当前最小距离平方：

$$(p.x - mid\_x)^2 \le d\_2$$

则 $p$ 在带状区域内，加入 `tmp2`。

> 注意：这里比较的是**平方**，避免开方。

## 三、逐行代码解析

### 3.1 全局变量与初始化

```cpp
vector<pair<long long, long long>> A, tmp1, tmp2;
long long d_2;

void init(int n)
{
    A.assign(n + 1, pair<long long, long long>{});
    tmp1.assign(n + 1, pair<long long, long long>{});
    tmp2.assign(n + 1, pair<long long, long long>{});
    d_2 = LLONG_MAX;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `vector<pair<...>> A, tmp1, tmp2;` | A：点数组；tmp1：归并辅助数组；tmp2：带状区域点集 |
| 2 | `long long d_2;` | 最小距离的平方（全局变量，递归中不断更新） |
| 5-7 | `A.assign(n+1, ...);` | 三个数组都分配 n+1 空间（下标从 1 开始） |
| 8 | `d_2 = LLONG_MAX;` | 初始化为 long long 的最大值 |

> 为什么用 `long long`？坐标值可能很大，平方后会爆 int。而且 `LLONG_MAX` 是 long long 的最大值。

### 3.2 dist_2 —— 计算距离平方

```cpp
inline long long dist_2(const pair<long long, long long>& a, const pair<long long, long long>& b)
{
    return (a.first - b.first) * (a.first - b.first) 
         + (a.second - b.second) * (a.second - b.second);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `inline long long dist_2(...)` | inline 内联函数，减少函数调用开销 |
| 2-3 | `return (x1-x2)^2 + (y1-y2)^2` | 欧氏距离的平方 |

> 全程用距离平方比较，最后才开方。这样既快又避免浮点误差。

### 3.3 find_min —— 带状区域内找最近点对

```cpp
void find_min(int n)
{
    for (int i = 1; i < n; i++)
    {
        for (int j = i + 1; j < n; j++)
        {
            long long k = tmp2[j].second - tmp2[i].second;
            if (k * k > d_2) break;
            d_2 = min(d_2, dist_2(tmp2[i], tmp2[j]));
        }
    }
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `for (int i = 1; i < n; i++)` | 枚举每个点作为第一个点 |
| 4 | `for (int j = i + 1; j < n; j++)` | 枚举 i 后面的点作为第二个点 |
| 5 | `long long k = tmp2[j].y - tmp2[i].y;` | y 方向的差（tmp2 按 y 升序，所以差非负） |
| 6 | `if (k * k > d_2) break;` | 如果 y 方向差的平方已经 > d_2，距离肯定更大，直接 break |
| 7 | `d_2 = min(d_2, dist_2(...));` | 计算实际距离平方，更新最小值 |

> **为什么可以 break？** 因为 tmp2 按 y 升序排列，j 越大 y 越大，y 方向差也越大。当 y 差的平方超过 d_2 时，后面的 j 只会更大，不用再看了。
>
> **复杂度**：由鸽巢原理，每个 i 对应的内层循环最多执行 6 次，所以总时间 O(n)。

### 3.4 solve —— 分治主函数（递归边界）

```cpp
long long sovle(int l, int r)
{
    if (l == r) return A[l].first;
    if (l + 1 == r)
    {
        long long nxt = A[r].first;
        d_2 = min(d_2, dist_2(A[l], A[r]));
        if (A[l].second > A[r].second) swap(A[l], A[r]);
        return nxt;
    }
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `if (l == r) return A[l].first;` | 只有一个点：返回它的 x 坐标（这个点的 x） |
| 3 | `if (l + 1 == r)` | 两个点的边界情况 |
| 5 | `long long nxt = A[r].first;` | 先保存右点的 x（后面 swap 会改变顺序） |
| 6 | `d_2 = min(d_2, dist_2(A[l], A[r]));` | 计算两点距离，更新全局最小 |
| 7 | `if (A[l].y > A[r].y) swap(A[l], A[r]);` | 按 y 坐标升序排列（归并排序的叶子） |
| 8 | `return nxt;` | 返回右点的 x（即两个点中较大的 x = 区间最右点的 x） |

> **关键点**：
> - 函数返回值是区间 $[l, r]$ 中**最大的 x 坐标**（最右点的 x）
> - 副作用是将 $A[l..r]$ **按 y 升序排序**
> - 同时更新全局最小距离 `d_2`
> - 注意保存 nxt 的时机——在 swap 之前，因为 swap 后 A[r] 就不一定是原来的右点了

### 3.5 solve —— 递归划分

```cpp
    int mid = l + (r - l) / 2;
    long long mid_x = sovle(l, mid);
    long long nxt = sovle(mid + 1, r);
```

| 行 | 代码 | 解析 |
|----|------|------|
| 10 | `int mid = l + (r - l) / 2;` | 中间位置（防止 l+r 溢出） |
| 11 | `long long mid_x = sovle(l, mid);` | 递归处理左半，返回左半最大 x = 中线位置 |
| 12 | `long long nxt = sovle(mid + 1, r);` | 递归处理右半，返回右半最大 x = 整个区间最大 x |

> 递归返回后：
> - `A[l..mid]` 已按 y 升序排列
> - `A[mid+1..r]` 已按 y 升序排列
> - `d_2` 已更新为左右两半中的最小距离平方
> - `mid_x` 是中线 x 坐标（左半最右点的 x）

### 3.6 solve —— 归并合并（核心）

```cpp
    int id_l = l, id_r = mid + 1;
    int idx_tmp1 = l, idx_tmp2 = 1;
    while (id_l <= mid && id_r <= r)
    {
        if (A[id_l].second <= A[id_r].second)
        {
            tmp1[idx_tmp1++] = A[id_l];
            long long k = A[id_l].first - mid_x;
            if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_l];
            id_l++;
        }
        else
        {
            tmp1[idx_tmp1++] = A[id_r];
            long long k = A[id_r].first - mid_x;
            if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_r];
            id_r++;
        }
    }
```

| 行 | 代码 | 解析 |
|----|------|------|
| 14 | `int id_l = l, id_r = mid + 1;` | 左右两个指针，各指向左右两半的起始位置 |
| 15 | `int idx_tmp1 = l, idx_tmp2 = 1;` | tmp1 的写入位置（归并结果），tmp2 的写入位置（带状区域） |
| 16 | `while (id_l <= mid && id_r <= r)` | 归并排序的经典 while 循环 |
| 18 | `if (A[id_l].y <= A[id_r].y)` | 哪边 y 更小就先放哪边 |
| 20 | `tmp1[idx_tmp1++] = A[id_l];` | 放入 tmp1（归并排序结果） |
| 21 | `long long k = A[id_l].x - mid_x;` | 计算该点到中线的 x 方向距离 |
| 22 | `if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_l];` | 如果在带状区域内，加入 tmp2 |
| 23 | `id_l++;` | 左指针右移 |
| 26-31 | `else` 分支 | 右半同理，操作完全对称 |

> 这是整个算法最精彩的部分：**一次归并同时做了三件事**：
> 1. 把左右两半按 y 合并成有序序列（写回 tmp1）
> 2. 顺便筛选出带状区域内的点（写入 tmp2）
> 3. tmp2 天然就是按 y 升序的（因为归并过程本身就是按 y 排序的）
>
> 一石三鸟，效率拉满。

### 3.7 solve —— 处理剩余元素

```cpp
    while (id_l <= mid)
    {
        tmp1[idx_tmp1++] = A[id_l];
        long long k = A[id_l].first - mid_x;
        if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_l];
        id_l++;
    }
    while (id_r <= r)
    {
        tmp1[idx_tmp1++] = A[id_r];
        long long k = A[id_r].first - mid_x;
        if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_r];
        id_r++;
    }
```

归并排序的标准收尾：把左右两半中没走完的剩余元素依次放入。操作和上面一样，每个元素都要检查是否在带状区域内。

### 3.8 solve —— 写回与带状区域查找

```cpp
    for (int i = l; i <= r; i++) A[i] = tmp1[i];
    find_min(idx_tmp2);
    return nxt;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 77 | `for (int i = l; i <= r; i++) A[i] = tmp1[i];` | 把归并结果写回 A（现在 A[l..r] 按 y 升序） |
| 78 | `find_min(idx_tmp2);` | 在带状区域 tmp2 中找最近点对，更新 d_2 |
| 79 | `return nxt;` | 返回整个区间的最大 x（右半的最大 x） |

> `idx_tmp2` 是 tmp2 中实际元素的个数（下一个写入位置 - 1），传给 find_min 作为数组大小。

### 3.9 main 函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    cin >> n;
    init(n);
    for (int i = 1; i <= n; i++) cin >> A[i].first >> A[i].second;
    sort(A.begin() + 1, A.end());
    sovle(1, n);
    double ans = sqrt(d_2);
    cout << fixed << setprecision(4) << ans;
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 8 | `sort(A.begin() + 1, A.end());` | 按 x 坐标升序排序（pair 默认先比 first 再比 second） |
| 9 | `sovle(1, n);` | 调用分治主函数，结果存在全局变量 d_2 中 |
| 10 | `double ans = sqrt(d_2);` | 最后开一次方，得到实际距离 |
| 11 | `cout << fixed << setprecision(4) << ans;` | 保留 4 位小数输出 |

## 四、复杂度分析

### 4.1 时间复杂度

$$O(n \log n)$$

**详细推导**：

| 步骤 | 复杂度 | 说明 |
|------|--------|------|
| 初始排序 | $O(n \log n)$ | 按 x 坐标排序 |
| 递归划分 | $O(n \log n)$ | T(n) = 2T(n/2) + O(n) |
| 每层归并 | $O(n)$ | 总共 log n 层 |
| 每层带状区域查找 | $O(n)$ | 每个点常数次比较（鸽巢原理保证） |
| **总计** | $O(n \log n)$ | 主定理 |

### 4.2 空间复杂度

$$O(n)$$

- 三个数组 A、tmp1、tmp2，都是 $O(n)$
- 递归栈深度 $O(\log n)$，可忽略
- 总计 $O(n)$

### 4.3 不同写法的复杂度对比

| 实现方式 | 时间复杂度 | 说明 |
|----------|-----------|------|
| 暴力枚举 | $O(n^2)$ | n ≤ 1000 可用 |
| 分治 + 每层单独 sort | $O(n \log^2 n)$ | 好写但稍慢，也能过大多数题 |
| 分治 + 归并排序（本代码） | $O(n \log n)$ | 最优，代码稍复杂 |
| 随机化 + 哈希 | $O(n)$ 期望 | 理论最优，竞赛中极少用 |

### 4.4 常见数据规模参考

| n | 暴力 O(n²) | 分治 O(n log n) |
|---|-----------|----------------|
| 1000 | ~100万（轻松） | ~1万（杀鸡用牛刀） |
| 1万 | ~1亿（紧张） | ~14万（轻松） |
| 10万 | ~100亿（超时） | ~170万（轻松） |
| 100万 | 不可能 | ~2000万（1秒左右） |

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **平面最近点对** | 经典应用，求平面 n 个点中最近的两点距离 |
| **最接近点对计数** | 稍作修改可统计有多少对点距离等于最小值 |
| **n ≥ 10000** | 暴力超时，必须用分治或其他优化 |
| **多维最近点对** | 高维（如三维）也有类似的分治思路，但带状区域更复杂 |
| **计算几何基础题** | 很多计算几何题需要先求最近点对作为子问题 |

## 六、常见陷阱与注意事项

### 6.1 整数溢出

**最常见错误**：坐标用 int，距离平方用 int。

坐标范围如果是 $10^9$，平方后就是 $10^{18}$，远超 int 范围。

**正确做法**：坐标用 `long long`，距离平方也用 `long long`。

### 6.2 距离平方 vs 实际距离

全程用距离平方比较，最后再开方。不要在中间开方——浮点运算有精度损失，而且慢。

### 6.3 排序方向

- 初始按 **x 升序**排序（pair 默认排序就是先 x 后 y，没问题）
- 归并过程中按 **y 升序**合并
- 方向搞反了也能用，只要统一就行，但最好按标准来

### 6.4 tmp2 的下标从 1 开始

代码中 `tmp2[idx_tmp2++]` 从下标 1 开始写入，`find_min` 也从 1 开始遍历。这和整体的 1-based 风格一致。

注意不要和 0-based 混用。

### 6.5 带状区域的判断条件

```cpp
long long k = A[id_l].first - mid_x;
if (k * k <= d_2) tmp2[idx_tmp2++] = A[id_l];
```

这里 `k` 可能是负数（点在中线左边），但平方后就一样了。用 `k * k` 而不是 `abs(k)` 是为了避免调用 `abs` 函数，直接乘更快。

### 6.6 find_min 中的 break 条件

```cpp
long long k = tmp2[j].second - tmp2[i].second;
if (k * k > d_2) break;
```

y 方向差的平方 > d_2 时 break。这是基于"距离 = sqrt(x² + y²) > y 差"的性质——如果 y 差已经比 d 大了，总距离肯定更大。

注意是 `>` 不是 `>=`：等于 d_2 时距离可能正好等于 d（x 差为 0），还需要比较。

### 6.7 重复点的处理

如果有两个完全相同的点（坐标一样），最近距离就是 0，算法会正确处理（dist_2 = 0，之后 d_2 不会再变小）。

如果题目保证没有重点，或者需要统计不同点对，注意调整逻辑。

### 6.8 solve 返回值的含义

`solve(l, r)` 返回的是区间 $[l, r]$ 中**最大的 x 坐标**，不是最小距离！

最小距离存在全局变量 `d_2` 中。这是本代码的设计特点，容易搞混。

- 返回值：区间最大 x（用于确定中线位置）
- 副作用 1：A[l..r] 按 y 排序
- 副作用 2：更新全局最小距离 d_2

### 6.9 为什么不用返回最小距离

因为 d_2 是全局的，每次发现更小的距离就更新。如果用返回值传递最小距离，代码会更清晰但稍长一些。两种风格都可以，本代码用全局变量更简洁。

## 七、对比与扩展

### 7.1 暴力 vs 分治

| 维度 | 暴力枚举 | 分治算法 |
|------|----------|----------|
| 时间复杂度 | $O(n^2)$ | $O(n \log n)$ |
| n=1万 | ~1亿（紧） | ~14万（轻松） |
| n=10万 | 超时 | ~170万（轻松） |
| 代码量 | 5 行 | 约 80 行 |
| 适用场景 | n ≤ 1000 | 任意规模 |

### 7.2 归并排序式 vs 每层 sort 式

| 维度 | 归并排序式（本代码） | 每层 sort 式 |
|------|---------------------|-------------|
| 时间复杂度 | $O(n \log n)$ | $O(n \log^2 n)$ |
| 代码复杂度 | 较复杂（归并+筛选合二为一） | 简单（递归后直接 sort） |
| 实际速度 | 更快 | 稍慢（但大多数题也能过） |
| 推荐程度 | 竞赛标准写法 | 适合快速写对 |

每层 sort 式的核心代码大概是：
```cpp
// 伪代码示意
double solve(int l, int r) {
    if (r - l <= 3) return brute_force(l, r);
    int mid = (l + r) / 2;
    double mid_x = p[mid].x;
    double d = min(solve(l, mid), solve(mid+1, r));
    // 筛选带状区域
    vector<Point> strip;
    for (int i = l; i <= r; i++)
        if (abs(p[i].x - mid_x) < d) strip.push_back(p[i]);
    // 按 y 排序
    sort(strip.begin(), strip.end(), cmp_y);
    // 每个点和后面6个比较
    for (int i = 0; i < strip.size(); i++)
        for (int j = i+1; j < strip.size() && strip[j].y - strip[i].y < d; j++)
            d = min(d, dist(strip[i], strip[j]));
    return d;
}
```
这种写法更直观，适合入门理解。

### 7.3 扩展：最近点对的编号

如果题目要求输出最近点对的**编号**（而不仅仅是距离），需要：
- 每个点保存原始下标
- 更新 d_2 的同时记录是哪两个点
- 注意归并排序时不要丢失编号信息

### 7.4 扩展：平面最远点对

最远点对（直径）不能直接用分治，通常用旋转卡壳算法，时间复杂度也是 $O(n \log n)$。

### 7.5 扩展：三维最近点对

三维也有分治解法，但带状区域变成了"带状体"，每个点需要比较的邻居更多（约 15 个），实现更复杂。竞赛中较少考察。

### 7.6 扩展：k 近邻

找每个点的 k 个最近邻，可以用 kd-tree 或其他数据结构。最近点对是 k=1 的特殊情况。

### 7.7 一句话总结

平面最近点对是分治算法的经典应用，核心是"按 x 划分 + 递归求解 + 带状区域合并"。鸽巢原理保证了合并阶段每个点只需常数次比较，配合归并排序在合并时顺便完成 y 排序，总复杂度达到理论最优的 $O(n \log n)$。理解带状区域和鸽巢原理是掌握这个算法的关键——为什么跨越中线的点对不会太多？答案就在那 6 个小矩形里。$AKB17$, '基础算法', array['基础算法', '分治', '最近点对', '最小点对', '计算几何', '归并排序', '平面几何'], 'col-hub-basic-divide', null, 'knowledge'),
('world-needs-sunday', 'col-basic-divide-conquer-merge-inversion', '归并排序求逆序对（分治）', $AKB18$## 算法原理

逆序对是数组中满足 $i < j$ 且 $a[i] > a[j]$ 的数对 $(i, j)$。统计逆序对是分治思想的经典应用：将数组对半切分，递归统计左半部分的逆序对和右半部分的逆序对，再在合并阶段统计跨越左右两部分的逆序对。

三步分治框架：

1. **分**：将区间 $[l, r]$ 分成 $[l, \text{mid}]$ 和 $[\text{mid}+1, r]$
2. **治**：递归处理左右两半，各自返回内部的逆序对数
3. **合**：在归并合并时，当右半的元素 $a[\text{id2}]$ 被选中放到左半元素 $a[\text{id1}]$ 前面时，说明 $a[\text{id1}] \sim a[\text{mid}]$ 都比 $a[\text{id2}]$ 大，它们与 $a[\text{id2}]$ 构成了 $\text{mid} - \text{id1} + 1$ 个逆序对

归并合并保证了左右两半各自已经有序，因此一旦 $a[\text{id2}] < a[\text{id1}]$，左半剩余的所有元素也都大于 $a[\text{id2}]$，可以批量计数。

## 核心公式/状态定义与转移方程

逆序对总数：

$$\text{inv}(l, r) = \text{inv}(l, \text{mid}) + \text{inv}(\text{mid}+1, r) + \text{cross}(l, \text{mid}, r)$$

其中 $\text{cross}(l, \text{mid}, r)$ 是合并阶段统计的跨越逆序对：

$$\text{cross}(l, \text{mid}, r) = \sum_{\text{id2}=\text{mid}+1}^{r} (\text{mid} - \text{id1} + 1) \quad \text{（当 } a[\text{id2}] < a[\text{id1}] \text{ 时累加）}$$

递归边界：

$$\text{inv}(l, l) = 0$$

合并时使用稳定排序（$\le$ 而非 $<$），保证相等元素不产生逆序对：

$$a[\text{id1}] \le a[\text{id2}] \Rightarrow \text{取左半元素，不累加}$$
$$a[\text{id1}] > a[\text{id2}] \Rightarrow \text{取右半元素，累加 } \text{mid} - \text{id1} + 1$$

## 逐行代码解析

```cpp
#include<bits/stdc++.h>
using namespace std;
int n;
vector<int> A;
vector<int> tmp;
```

- `A`：原始数组，下标从 1 开始。
- `tmp`：辅助数组，用于归并合并时暂存排序结果。

```cpp
long long fn(int l, int r)
{
    if (l == r) return 0;
```

递归入口。当区间只剩一个元素时，逆序对数为 0，直接返回。返回类型用 `long long`，因为逆序对数量可达 $\binom{n}{2} \approx 5 \times 10^9$（$n = 10^5$ 时），超出 `int` 范围。

```cpp
    long long ans = 0;
    int mid = l + ((r - l) >> 1);
    ans += fn(l, mid);
    ans += fn(mid + 1, r);
```

计算中点 `mid`（用 `l + ((r-l)>>1)` 避免溢出），递归处理左右两半，累加各自内部的逆序对。

```cpp
    int idx = l, id1 = l, id2 = mid + 1;
    while (id1 != mid + 1 && id2 != r + 1)
    {
        if (A[id1] <= A[id2]) tmp[idx++] = A[id1++];
        else
        {
            tmp[idx++] = A[id2++];
            ans += mid - id1 + 1;
        }
    }
```

双指针归并合并。`id1` 指向左半当前元素，`id2` 指向右半当前元素。

- `A[id1] <= A[id2]`：左半元素较小或相等，取左半元素，不产生逆序对。
- `A[id1] > A[id2]`：右半元素较小，取右半元素。此时左半从 `id1` 到 `mid` 的所有元素都大于 `A[id2]`（因为左半已有序），共 `mid - id1 + 1` 个元素与 `A[id2]` 构成逆序对。

```cpp
    while(id1 != mid + 1) tmp[idx++] = A[id1++];
    while (id2 != r + 1) tmp[idx++] = A[id2++];
```

将左半或右半剩余的元素直接追加到 `tmp` 末尾。剩余元素不再产生逆序对。

```cpp
    for (int i = l; i <= r; i++) A[i] = tmp[i];
    return ans;
}
```

将排序结果从 `tmp` 拷回原数组 `A`，保证上层递归调用时左右两半各自有序。返回该区间的逆序对总数。

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    cin >> n;
    A.resize(n + 1, 0);
    tmp.resize(n + 1, 0);
    for (int i = 1; i <= n; i++) cin >> A[i];
    cout << fn(1, n);
    return 0;
}
```

读入数组（下标从 1 开始，`A[0] = 0` 不参与计算），调用 `fn(1, n)` 输出逆序对总数。

### 演示示例

以 $a = [3, 1, 4, 2, 5]$ 为例：

```
fn(1, 5):
  分: mid = 3, 左 [3, 1, 4], 右 [2, 5]
  递归左 fn(1, 3):
    分: mid = 2, 左 [3, 1], 右 [4]
    递归左 fn(1, 2):
      分: mid = 1, 左 [3], 右 [1]
      合并: 1 < 3 → 逆序对 +1, 排序后 [1, 3]
      返回 1
    递归右 fn(3, 3): 返回 0
    合并 [1, 3] 和 [4]: 无逆序对, 排序后 [1, 3, 4]
    返回 1
  递归右 fn(4, 5):
    分: mid = 4, 左 [2], 右 [5]
    合并: 2 <= 5 → 无逆序对, 排序后 [2, 5]
    返回 0
  合并 [1, 3, 4] 和 [2, 5]:
    id1=1, id2=4
    1 <= 2 → 取 1
    3 > 2 → 逆序对 +2 (mid-id1+1 = 3-2+1 = 2), 取 2
    3 <= 5 → 取 3
    4 <= 5 → 取 4
    取 5
    逆序对 +2
  排序后 [1, 2, 3, 4, 5]
  返回 1 + 0 + 2 = 3

最终结果: 3
```

逆序对为 $(3,1)$, $(3,2)$, $(4,2)$，共 3 个。

## 复杂度分析

### 时间复杂度

递归树深度为 $O(\log n)$，每层合并的总工作量为 $O(n)$（所有区间的合并长度之和为 $n$），因此总时间复杂度为：

$$T(n) = 2T(n/2) + O(n) = O(n \log n)$$

### 空间复杂度

辅助数组 `tmp` 大小为 $O(n)$，递归栈深度为 $O(\log n)$，总空间复杂度为 $O(n)$。

### 逆序对数量上界

$n$ 个元素的数组最多有 $\binom{n}{2} = \frac{n(n-1)}{2}$ 个逆序对（完全逆序时）。当 $n = 10^5$ 时，最多约 $5 \times 10^9$ 个，超出 `int` 范围（约 $2.1 \times 10^9$），因此返回类型用 `long long`。

## 适用场景

1. **逆序对计数**：直接统计数组中逆序对的数量，是归并排序最经典的应用
2. **逆序数相关排序指标**： Kendall tau 距离、数组有序度评估
3. **树状数组/线段树的替代方案**：当不需要在线修改时，归并排序是离线统计逆序对的简洁方案
4. **求排列的奇偶性**：逆序对数的奇偶性决定排列的奇偶性，用于某些组合数学问题

**不适用场景**：
- 需要在线修改并实时查询逆序对数 → 应使用树状数组或线段树
- 只需要判断是否有逆序对（即是否有序）→ 直接检查相邻元素即可，$O(n)$

## 常见陷阱与注意事项

1. **返回类型必须用 `long long`**
   - $n = 10^5$ 的完全逆序数组有约 $5 \times 10^9$ 个逆序对，超出 `int` 上限
   - 这是本题最容易犯的错误

2. **合并时用 $\le$ 而非 $<$**
   - `A[id1] <= A[id2]`：相等元素不构成逆序对，优先取左半元素（稳定排序）
   - 若写成 `A[id1] < A[id2]`：相等元素会被当作逆序对，导致多算

3. **`mid - id1 + 1` 的含义**
   - 当 `A[id2]` 被选中时，左半从 `id1` 到 `mid` 的所有元素都比 `A[id2]` 大
   - 数量为 `mid - id1 + 1`，不要误写成 `mid - id1` 或 `r - id1`

4. **辅助数组 `tmp` 必须拷回原数组**
   - 合并结果写入 `tmp` 后，必须拷回 `A[l..r]`，否则上层递归的合并会出错
   - 常见错误是忘记拷回，或拷回范围写错

5. **数组下标从 1 开始**
   - 本代码下标从 1 开始，`A[0] = 0` 不参与计算
   - 若从 0 开始，递归调用改为 `fn(0, n-1)`

6. **中点计算防溢出**
   - 使用 `l + ((r - l) >> 1)` 而非 `(l + r) / 2`
   - 虽然在此题中 `l, r` 不会太大，但这是良好的编程习惯

## 对比与扩展

| 方法 | 时间复杂度 | 空间复杂度 | 是否需要离散化 | 特点 |
|---|---|---|---|---|
| **归并排序（本算法）** | $O(n \log n)$ | $O(n)$ | 否 | 离线统计，代码简洁 |
| 树状数组 | $O(n \log n)$ | $O(n)$ | 是（值域大时） | 支持在线修改 |
| 线段树 | $O(n \log n)$ | $O(n)$ | 是（值域大时） | 支持在线修改和区间查询 |
| 朴素双重循环 | $O(n^2)$ | $O(1)$ | 否 | 仅适用于 $n$ 很小的情况 |

### 扩展

- **逆序对与排列奇偶性**：逆序对数为偶数时排列为偶排列，奇数时为奇排列。这在某些组合数学问题中有应用
- **Kendall tau 距离**：两个排列之间的 Kendall tau 距离就是它们之间的逆序对数
- **多维逆序对**：三维偏序问题（如 $(a_i, b_i, c_i)$ 的偏序计数）可以用 CDQ 分治解决，是归并排序求逆序对的二维扩展
- **归并排序本身**：去掉 `ans` 的累加，本代码就是一个标准的归并排序实现，时间复杂度 $O(n \log n)$，是稳定排序$AKB18$, '基础算法', array['基础算法', '分治', '归并排序', '逆序对', '排序'], 'col-hub-basic-divide', null, 'knowledge'),
('Fohen', 'col-basic-doubling--fenfeng', '倍增（思想） · Fohen', $AKB19$## 算法原理

倍增（Doubling）是一种「用预处理换取加速」的算法思想：提前把**成倍规模**的信息算好并存储，查询时再通过**二进制拆分**，把任意规模的多次操作合并成若干次已经预处理好的「一步」。

核心分两步：

1. **预处理**：若某种转移「跳一步」可以方便地执行，那么「跳 $2$ 步」等于「跳 $1$ 步再跳 $1$ 步」，「跳 $4$ 步」等于「跳 $2$ 步再跳 $2$ 步」，依此类推。于是可以自底向上预处理出所有 **$2$ 的幂次步**的结果。
2. **查询**：要执行「跳 $x$ 步」（$x$ 为任意非负整数）时，把 $x$ 写成二进制，只对其中为 $1$ 的位执行对应的「跳 $2^k$ 步」，最后把结果拼起来。$x$ 的二进制至多有 $\lfloor \log_2 x \rfloor + 1$ 位，所以查询次数从 $O(x)$ 降到 $O(\log x)$。

「倍增」得名于 $2$ 的幂次：绝大多数场景取 $k=2$，步长按 $2$ 倍增长（$1,2,4,8,\dots$），故下面只讨论 $2$ 的幂次倍增。更一般地，基数 $k$ 可以是任意整数，但 $k=2$ 实现最自然、与二进制拆分最契合。

## 核心公式 / 状态定义与转移方程

**状态定义**：设 `jump[i][k]` 表示「从状态（或节点）$i$ 出发，跳 $2^k$ 步后到达的状态（或节点）」。

当 $k \ge 1$ 时，「跳 $2^k$ 步」等价于「先跳 $2^{k-1}$ 步，再跳 $2^{k-1}$ 步」：

$$
2^k = 2^{k-1} + 2^{k-1}
$$

由此得到递推式（转移方程）：

$$
\text{jump}[i][k] = \text{jump}[\text{jump}[i][k-1]][k-1]
$$

边界条件：$k=0$ 时 `jump[i][0]` 就是「跳 $1$ 步」的结果，通常由题目的转移函数直接给出。

预处理完成后，「跳 $x$ 步」只需枚举 $x$ 二进制中为 $1$ 的位：若 $x$ 的第 $k$ 位为 $1$，就把当前位置 $i$ 更新为 `jump[i][k]`。例如 $x=13=(1101)_2$，等价于先跳 $1$ 步、再跳 $4$ 步、再跳 $8$ 步；因为每一步都是「跳固定步数」的复合，先后顺序不影响结果。

## 逐行代码解析

> 下面是伪代码，用于表达思想步骤，不依赖具体语言与题目；实际应用时需按题目定义 `jump[i][0]` 与状态合并方式。

```cpp
// 预处理：计算从 i 跳 2^k 步到达的状态
for k in 1 .. LOG:                    // LOG = 最大幂次，约 log2(N) 上取整
    for i in 1 .. N:
        jump[i][k] = jump[ jump[i][k-1] ][ k-1 ]

// 查询：从 cur 出发，跳 x 步
cur = 起点
for k in 0 .. LOG:
    if x 的第 k 位为 1:
        cur = jump[cur][k]            // 累加"跳 2^k 步"的贡献
```

- 预处理段按 $k$ 从小到大逐层递推：先算好「跳 $1$ 步」，再算「跳 $2$ 步」「跳 $4$ 步」…… 每一层只依赖上一层，复杂度 $O(N \log N)$。
- 查询段把 $x$ 按位拆开，只对为 $1$ 的位执行跳跃，单次查询 $O(\log x)$。
- 若查询的不是「到达哪个状态」而是「路径上的最值 / 和」等聚合信息，可把 `jump` 换成带信息的状态（如 `max[i][k]`），递推时同时合并信息即可（前提是该聚合满足结合律）。

## 复杂度分析

倍增本身是一种思想，复杂度没有统一公式，取决于状态数量 $N$ 与查询次数 $Q$。常见形态（如树上倍增、ST 表）为：

- **预处理**：$N$ 个状态、每个状态算 $\log N$ 层，共 $O(N \log N)$。
- **单次查询**：二进制拆分只需 $O(\log x)$ 次跳跃，即 $O(\log N)$。
- **空间**：需要存 $N \times \log N$ 的状态表，$O(N \log N)$。

若最大跳跃次数不超过 $n$，则「预处理 $O(n \log n)$、单次查询 $O(\log n)$、空间 $O(n \log n)$」是倍增最典型的一组指标。

## 适用场景

当「某种转移可以执行很多次，且多次转移可以合并（两个相邻转移能合成一个更大的转移）」时，就可以用倍增优化。典型应用：

- **函数快速迭代**：求函数 $f$ 迭代 $x$ 次后的结果 $f^{(x)}(a)$（如求 $a^b \bmod p$、某个置换的 $x$ 次幂）。
- **树上向上跳跃 / 求 LCA**：预处理每个节点向上 $2^k$ 级祖先，在线查询最近公共祖先。
- **倍增求路径信息**：维护向上跳 $2^k$ 步区间内的最值、和、$\gcd$ 等聚合信息。
- **具有结合律的区间操作**：如 ST 表求静态区间最值，预处理 $O(n \log n)$、查询 $O(1)$。

## 常见陷阱与注意事项

1. **状态合并必须满足结合律**：倍增本质是「分块再拼起来」，只有当「跳 $a$ 步」与「跳 $b$ 步」能无副作用地合并时，二进制拆分才正确；不满足结合律或信息无法合并的操作不能直接倍增。
2. **边界与越界**：`jump[i][0]` 必须正确初始化；跳出的状态（如树根之上、数组末尾之外）要按题意约定为哨兵（如 $0$ 或根自身），避免查询时访问越界。
3. **层数要取够**：$k$ 的范围必须覆盖 $\lfloor \log_2 x_{\max} \rfloor$，少一层就会在最大步数上出错。
4. **拆分顺序**：由于每一步都是「跳固定 $2^k$ 步」的纯函数复合，位处理的先后顺序不影响最终结果；但若涉及带副作用的累积，则不能随意重排。
5. **空间开销**：状态表是 $O(N \log N)$，当 $N$ 很大时要提前评估内存，必要时滚动数组或只保留需要的层。

## 对比与扩展

| 方法 | 预处理 | 单次查询 | 特点 |
|---|---|---|---|
| 直接逐步模拟 | 无 | $O(x)$ | 实现简单，步数大时太慢 |
| 倍增（$2$ 的幂次拆分） | $O(N \log N)$ | $O(\log N)$ | 通用、在线、稳定 |
| 离线 Tarjan 等 | 视算法 | $O(1)$ 均摊 | 需一次性读入所有询问 |

扩展方向：

- **树上倍增 LCA**：令 `jump[i][0]` 为父节点，套用上述递推即可在线求最近公共祖先。
- **ST 表**：`st[i][k]` 表示以 $i$ 开头、长度 $2^k$ 的区间最值，是倍增思想在「区间信息」上的体现。
- **二进制拆分优化多重背包**：把物品数量按 $1,2,4,\dots$ 拆成若干「物品组」，本质也是二进制拆分思想。
- **快速幂 / 快速乘**：指数按二进制拆分，可看作对「乘一次」这种转移做倍增。$AKB19$, '基础算法', array['倍增', '二进制拆分', 'LCA', 'ST 表', '函数迭代'], null, null, 'knowledge'),
('Xesir', 'col-basic-doubling--xesir', '倍增（思想） · Xesir', $AKB20$## 算法原理

倍增是一种通过预处理 $k^n$ 规模的信息，将连续多次操作合并处理的算法思想。绝大多数情况下 $k$ 取 $2$，所以下面只讲 $2$ 的幂次倍增。

用大白话说：与其一步一步慢慢挪，不如先把「跳 1 步、跳 2 步、跳 4 步……」这些成倍长度的结果提前算好，任意长度再拆成二进制的几块拼起来。举个栗子，要跳 $13$ 步，而 $13=(1101)_2$，那就只要跳 $1$ 步、跳 $4$ 步、跳 $8$ 步，拼起来就完事了，不用真的挪 $13$ 次。

倍增一般先预处理若干个 $2$ 的幂次步的结果，再利用**二进制拆分**快速完成任意长度的操作。假设 `jump[i][k]` 表示从节点 `i` 出发，跳 `2^k` 步后到达的节点。

当某种转移可以进行很多次，且多个转移可以合并时，就可以考虑用倍增思想优化。

## 核心公式 / 状态定义与转移方程

状态定义：`jump[i][k]` 表示从节点 `i` 出发、跳 $2^k$ 步后到达的节点。

由 $2^k = 2^{k-1} + 2^{k-1}$，可以得到递推式：

$$
jump[i][k] = jump[\,jump[i][k-1]\,][k-1]
$$

也就是「跳 $2^k$ 步」等于「先跳 $2^{k-1}$ 步，再跳 $2^{k-1}$ 步」。边界情况 $k=0$ 时，`jump[i][0]` 就是「跳 1 步」的结果，通常由题目的转移直接给出。

预处理后，跳任意 `x` 步时，只需要查看 `x` 的二进制表示，跳过其中为 `1` 的位即可。

## 逐行代码解析

倍增是思想而非固定算法，下面给的是伪代码，用于表达步骤，实际应用时要按题目定义 `jump[i][0]`。

### 预处理

```cpp
// 按 k 从小到大逐层递推
for (int k = 1; k <= LOG; k++)                 // LOG 约等于 log2(n) 上取整
    for (int i = 1; i <= n; i++)
        jump[i][k] = jump[jump[i][k-1]][k-1];  // 跳 2^k 步 = 跳两个 2^(k-1) 步
```

- 每一层只依赖上一层，先算好「跳 1 步」，再算「跳 2 步」「跳 4 步」……
- 循环顺序必须先 `k` 后 `i`：算 `jump[i][k]` 时要用到所有 `jump[·][k-1]`，先 `k` 后 `i` 才能保证上一层已经就绪。

### 查询

```cpp
int cur = s;                             // 起点
for (int k = 0; k <= LOG; k++)
    if ((x >> k) & 1)                    // x 的第 k 位为 1
        cur = jump[cur][k];              // 跳 2^k 步
```

- 把 `x` 按二进制拆开，只对为 `1` 的位跳一次，单次查询 $O(\log x)$。
- 每一步都是「跳固定 $2^k$ 步」的复合，先后顺序不影响最终落点。

## 复杂度分析

若最大跳跃次数不超过 `n`，通常：

- 预处理 $O(n \log n)$；
- 单次查询 $O(\log n)$；
- 空间复杂度 $O(n \log n)$。

## 适用场景

当某种转移可以进行很多次，且多个转移可以合并时，可以使用倍增思想进行优化，例如：

- 函数快速迭代；
- 树上向上跳跃（如求 LCA）；
- 倍增求路径信息；
- 某些具有结合性质的区间操作（如 ST 表）。

## 常见陷阱与注意事项

1. `jump[i][0]` 必须按题意正确初始化，它是所有递推的地基。
2. 层数 `LOG` 要覆盖 $\lfloor \log_2 x_{\max} \rfloor$，少一层就会在最大步数上出错。
3. 只有「跳 $a$ 步」和「跳 $b$ 步」能无副作用地合并（满足结合律）时，二进制拆分才成立。
4. 跳出的状态（树根之上、数组末尾之外）要按题意约定成哨兵，避免越界。
5. 状态表是 $O(n \log n)$ 的，`n` 大时要提前评估内存，必要时滚动数组。

## 对比与扩展

| 方法 | 预处理 | 单次查询 | 特点 |
|---|---|---|---|
| 直接逐步模拟 | 无 | $O(x)$ | 好写，步数一大就慢 |
| 倍增 | $O(n \log n)$ | $O(\log n)$ | 通用、在线、稳定 |

扩展方向：树上倍增求 LCA、ST 表求静态区间最值、多重背包的二进制拆分、快速幂（可看作对「乘一次」这种转移做倍增）。$AKB20$, '基础算法', array['倍增', '二进制拆分', 'LCA', 'ST 表', '函数迭代'], null, null, 'knowledge'),
('Fohen', 'col-basic-greedy--fenfeng', '贪心（思想） · Fohen', $AKB21$## 算法原理

贪心算法大概是算法世界里最符合人类直觉的策略之一：**每一步都只做当前看来最优的选择，期望这些局部最优最终拼出全局最优解**。它的思想非常朴素——在每一步决策时只考虑当前状态下的最优选择，而不考虑该选择对未来的影响。

形式化地说，贪心求解就是维护一个状态 $s$，每步在可行动作集合 $A(s)$ 中挑一个按局部评价函数 $f$ 最优的动作 $a$，执行后进入新状态 $s' = g(s, a)$，直到满足终止条件为止。

贪心的优点十分突出：

- **实现简单**：代码通常很短、可读性强，思维上非常直观。
- **复杂度低**：多数贪心只需一次排序加一次线性扫描，复杂度接近 $O(n \log n)$ 甚至 $O(n)$。

但它有一个根本局限：**贪心并不总是正确的**。只有同时满足下面两个性质，贪心才保证能得到全局最优解：

1. **贪心选择性质**：存在一个最优解包含当前贪心选择，即「局部最优选择不会被未来否定」。
2. **最优子结构**：做出贪心选择后，剩余子问题的最优解与已做选择合并，仍是原问题的最优解。

因此使用贪心前必须**证明其正确性**（常用交换论证、归纳、反证等），否则贪心只是「看起来对」。贪心也是许多高阶算法的核心思想（Dijkstra、Kruskal、Prim、Huffman 编码、LIS 的二分优化等），常与 DP、图论、数据结构配合出现，是必须掌握的基础能力。

## 核心公式 / 状态定义与转移方程

贪心没有统一的状态转移方程（那是 DP 的特征），它的「核心公式」通常表现为**局部最优判据**与**问题特有的目标函数**。通用的选择框架可以写成：

$$
a^{*} = \arg\max_{a \in A(s)} f(a), \qquad s' = g(s, a^{*})
$$

其中 $A(s)$ 是状态 $s$ 下的可行动作集合，$f(a)$ 是局部评价函数，$g$ 是状态转移函数。

针对具体问题，判据往往来自对目标函数的代数化简。以「排队打水」为例，设排队顺序为 $p_1, p_2, \dots, p_n$，总等待时间为：

$$
T = \sum_{j=1}^{n} \sum_{k=1}^{j-1} t_{p_k} = \sum_{k=1}^{n} (n-k)\, t_{p_k}
$$

系数 $(n-k)$ 随位置递减，因此让打水时间 $t$ 小的人靠前能令 $T$ 最小——这就是「按打水时间升序」这一贪心策略的公式来源。

证明贪心正确性最常用的工具是**交换论证**：若最优解中存在一对「更差的局部选择」，交换它们不会使解变差，就说明贪心选择可被嵌入某个最优解。仍以排队打水为例，相邻两人 $i$ 排在 $j$ 前且 $t_i > t_j$ 时，交换两人顺序只影响这两人的等待时间：交换前 $j$ 等待 $t_i$，交换后 $i$ 等待 $t_j$，总等待时间减少 $t_i - t_j > 0$；反复消除逆序即得升序最优。

## 逐行代码解析

贪心是思想类知识点，这里给出伪代码与思想步骤，而非完整可运行程序。

```cpp
// 贪心算法通用骨架（伪代码）
sort(candidates, cmp);            // ① 按局部最优规则排序（或建堆）
ans = 0;
state = init();                   // ② 初始化答案与当前状态
for (auto &x : candidates) {
    if (can_choose(x, state)) {   // ③ 判断 x 是否可行（满足约束）
        ans += value(x);          // ④ 累加贡献
        state = update(state, x); // ⑤ 更新状态
    }
}
return ans;
```

- ① 排序（或建堆）是贪心规则的落地形式，体现「局部最优」的次序。
- ③ 可行性判断是边界条件所在，最容易出错。
- ⑤ 状态更新决定后续选择是否仍然合法，漏掉会导致结果错误。

反悔贪心在「先选上、发现更优再替换」的思路下扩展为：

```cpp
// 反悔贪心骨架（伪代码）：先选上，冲突且更优时替换
priority_queue q;                 // 维护之前决策的代价/贡献
for (auto &x : candidates) {
    choose(x);                    // 先贪心选上 x
    if (需要反悔 && x 可替换堆顶) {
        pop(q);                   // 放弃之前贡献最小的决策
    }
    push(q, x);
}
return ans;
```

- 反悔贪心先把元素按贪心选入，当新元素与已有决策冲突且更优时，用堆维护的代价把最差的那个「替换」出来，借助代数恒等性消除后效性。

## 复杂度分析

贪心的复杂度由「排序 / 建堆」和「扫描」两部分决定，没有统一值：

| 环节 | 典型复杂度 | 说明 |
|---|---|---|
| 排序 | $O(n \log n)$ | 大多数贪心按某种关键字排序 |
| 堆维护 | $O(n \log n)$ | 合并果子、反悔贪心常用优先队列 |
| 线性扫描 | $O(n)$ | 排序后一遍遍历 |
| 总时间 | 视具体实现 | 常见 $O(n \log n)$，数据已有序或无需堆时为 $O(n)$ |
| 空间 | 视具体实现 | 通常 $O(n)$（存输入 / 堆），少数 $O(1)$ |

## 适用场景

### 适用

- 满足**贪心选择性质**与**最优子结构**、局部最优可拼出全局最优的问题。
- 区间问题：区间选点、区间调度、区间分组、区间覆盖。
- 编码 / 合并问题：哈夫曼编码、合并果子。
- 排序后贪心：排队打水、货仓选址、活动安排。
- 反悔贪心：决策可替换且可量化、带后效性或资源冲突的场景（任务调度、股票买卖、互斥选择）。

### 不适用

- 0/1 背包这类「性价比贪心失效」的问题（需 DP）。
- 需要全局视野、局部选择会阻塞更优解的复杂约束问题（除非引入反悔机制）。

## 常见陷阱与注意事项

1. **没证明就贪心**：贪心看似直觉正确，反例却很多。0/1 背包按性价比选会失败，因为一个「体积大但性价比略高」的物品可能挤掉真正的组合最优。用前必须证明贪心选择性质与最优子结构。
2. **排序规则选错方向**：区间调度（选最多不重叠区间）按**右端点**升序；区间分组按**左端点**升序；方向错了策略就不成立。
3. **端点是否可重合**：判断「不重叠」时用 $\ge$ 还是 $>$ 取决于题意（端点重合是否允许），写错会差一个计数。
4. **局部评价函数算错**：排队打水中的系数 $(n-k)$ 若漏掉，排序关键字就会出错。
5. **反悔贪心的替换代价**：互斥选择里新权值 $val_l + val_r - val_x$ 必须精确反映「退选 $x$、改选 $l+r$」的净变化，否则反悔逻辑失效。
6. **状态更新遗漏**：选完一个元素后忘记更新状态，会让后续的可行性判断（当前覆盖位置、已用总时间等）失效。

## 对比与扩展

| 方法 | 核心思路 | 是否回溯 | 复杂度 |
|---|---|---|---|
| 贪心 | 每步局部最优，落子无悔 | 否 | 通常 $O(n \log n)$ |
| 反悔贪心 | 先选上，更优时替换 | 有限回退 | 通常 $O(n \log n)$ |
| 动态规划 | 记录所有状态，全局最优 | 通过状态覆盖 | 视状态空间 |
| 搜索 / 回溯 | 枚举所有可能 | 是 | 指数级 |

贪心思想在其他算法中的体现：

- **最短路与最小生成树**：Dijkstra 每次松弛当前距离起点最近的点，Kruskal / Prim 每次选当前最小的可连通边，都是贪心选择性质的直接应用。
- **LIS 的二分优化**：维护「每个长度的最小末尾」本质是贪心——让每个长度的末尾尽可能小，未来更容易接上更大的数。
- **Dilworth 定理**：导弹拦截第二问中，一个序列最少的不上升子序列覆盖数等于其最长上升子序列长度，说明贪心与组合数学有深层联系。
- **网络流反向边**：反向边的设计运用了反悔贪心思想——先按贪心增广，再通过反向边撤回之前的流量。$AKB21$, '基础算法', array['贪心', '基础算法', '区间问题', '反悔贪心', '最优子结构'], null, null, 'knowledge'),
('Xesir', 'col-basic-greedy--xesir', '贪心（一般模型与区间问题） · Xesir', $AKB22$## 算法原理

贪心大概是算法世界里**最符合人类直觉**的做法：每一步都挑当前看起来最优的那个，指望这些局部最优拼出全局最优。你去水果店想用 20 块钱买到最多的苹果，多半直接拿单价最便宜的那种，而不会先拿贵的再换——这就是贪心。

它的代码往往极好写，复杂度也接近线性，思维上非常直观。但**贪心并不总是对的**：只有证明了正确性的贪心才可以放心使用，否则就是在赌命。常见的证明套路有两类：

- **交换论证 / 邻项交换**：先假设存在一个最优解，若它和贪心选择不一致，就把两者交换，证明答案不会变差。反复交换，就能把最优解「改造」成贪心解。排队打水、合并果子都用它。
- **贪心选择性质（反证 + 归纳）**：证明「当前这一步最优的选择，一定存在于某个最优解中」，再把已覆盖的部分去掉，对剩下的子问题归纳。

**什么时候该想贪心？** 题目要最优化（最小 / 最大），且决策之间没有难以消除的后效性——即当前怎么选，不会影响后续还能怎么选；即便有影响，也能被排序或交换「抹平」。如果后效性消不掉，通常就得转向反悔贪心或 DP。

## 核心公式 / 状态定义与转移方程

**排队打水**：设排队顺序为 $p_1, p_2, \dots, p_n$，第 $p_j$ 个人的等待时间是前面所有人打水时间之和 $\sum_{k=1}^{j-1} t_{p_k}$，于是总等待时间为

$$
T = \sum_{j=1}^{n} \sum_{k=1}^{j-1} t_{p_k} = \sum_{k=1}^{n} (n - k)\, t_{p_k}
$$

系数 $(n-k)$ 随排名递减，所以**打水快的人要排前面**，按 $t_i$ 升序即得最优。

**货仓选址**：目标 $f(x) = \sum_{i=1}^{n} |x - x_i|$ 是凸函数，「斜率」为（左侧点数）$-$（右侧点数）。它从 $-n$ 单调增到 $n$，斜率由负变正的位置就是**中位数**：$n$ 为奇数取 $x_{(n+1)/2}$，偶数取 $x_{n/2}$ 或 $x_{n/2+1}$ 均可。

## 逐行代码解析

下面把源笔记里的几个经典模型按模块拆开，每块给出对应的代码与要点。

### 合并果子（小根堆维护最小的两堆）

> 有 $n$ 堆果子，每堆 $a_i$ 个。每次合并任意两堆，消耗为两堆之和。求合并成一堆的最小总体力。

每次取当前**最小的两堆**合并，把小根堆顶弹出两个、求和累加、再压回，重复 $n-1$ 次。

```cpp
#include <bits/stdc++.h>
using namespace std;
priority_queue<int,vector<int>,greater<int>> fruit;
int main(){
    int n,ans=0;cin>>n;
    for(int i=1;i<=n;i++){
        int x;cin>>x;fruit.push(x);
    }
    while(fruit.size()>1){
        int a=fruit.top();fruit.pop();
        int b=fruit.top();fruit.pop();
        ans+=a+b;fruit.push(a+b);
    }
    cout<<ans;
}
```

- 本质是**哈夫曼树**：合并过程对应一棵二叉树，总消耗等于所有非叶结点权值和，带权路径长度最小。
- 正确性由交换论证保证：设 $a \le b \le c$，把 $a,b$ 放到最底层互为兄弟、和最小的两堆先合并，总消耗不会变差。
- `while (fruit.size() > 1)` 循环 $n-1$ 轮，每轮两次 `pop`、一次 `push`，复杂度 $O(n \log n)$。

### 排队打水（按耗时升序）

> $n$ 个人同时到达打水，第 $i$ 个人耗时 $t_i$。求一种顺序使所有人总等待时间最小。

按 $t_i$ 从小到大排队即可。下面这段代码把「多台机器分流」的写法也揉进来了：用小根堆维护每个人的累计时间，每次把当前最短的人放到累计时间最小的机器上。

```cpp
#include <bits/stdc++.h>
using namespace std;
priority_queue<int,vector<int>,greater<int>> fruit;
int n,r;
int ans[5010][5010];pair<int,int> t[5010];
int mil(){
    int miw=1e9,b=1;
    for(int i=1;i<=r;i++){
        if(miw>t[i].first){
            miw=t[i].first,b=i;
        }
    }
    return b;
}
int main(){
    long long cnt=0;cin>>n>>r;
    for(int i=1;i<=n;i++){
        int x;cin>>x;fruit.push(x);
    }
    while(fruit.size()){
        int a=fruit.top();fruit.pop();
        int i=mil();
        ans[i][t[i].second+1]=a+ans[i][t[i].second];
        t[i].first=ans[i][t[i].second+1];t[i].second++;
        cnt+=ans[i][t[i].second];
    }
    cout<<cnt;
}
```

- 核心是「短作业优先」：交换相邻的 $i,j$（$t_i > t_j$）后，其他人的等待时间不变，两人贡献从 $2t_i + t_j$ 变为 $2t_j + t_i$，差值 $t_i - t_j > 0$，说明交换后更优。
- 多机模型：升序排序后，每个人分配给当前累计时间最小的机器（源笔记注明「读者自证不难」）。

### 货仓选址（取中位数）

> 数轴上有 $n$ 家商店，位置 $x_1 \le \dots \le x_n$，选货仓位置 $x$ 使 $\sum |x - x_i|$ 最小。

排序后取中位数，再用双指针从两端向中间累加距离差。

```cpp
#include <bits/stdc++.h>
using namespace std;
vector<int> a(100010,40010);
int main() {
    int n,ans=0;
    cin>>n;
    for(int i=1;i<=n;i++){
        int b;cin>>b;//cout<<b;
        a[i]=b;
    }
    sort(a.begin()+1,a.end());
    //for(int i=1;i<=n;i++){
       // cout<<a[i];
   // }
    for(int i=1;i<=n/2;i++){
        ans+=(a[n-i+1]-a[i]);
    }
    cout<<ans<<endl;
    return 0;
}
```

- 第 $i$ 小与第 $n-i+1$ 小配成一对，`ans += a[n-i+1] - a[i]`，累加 $\lfloor n/2 \rfloor$ 对正好等于到中位数的距离和。
- 排序后单次扫描，复杂度 $O(n \log n)$。

### 导弹拦截（LIS 与 Dilworth）

> 一套系统每次拦截高度不能高于上一次；求（1）一套最多拦多少枚，（2）拦下全部最少要几套。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
int a[100010],f[100010];
vector<int> h,s;
signed main()
{
    int n=0,ans=0;
    int t;
    while(cin>>t){
        n++;a[n]=t;f[n]=1;
        h.push_back(t);
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<i;j++){
            if(a[j]>a[i]) f[i]=max(f[i],f[j]+1);
        }
    }
    for(int i=1;i<=n;i++){
        ans=max(ans,f[i]);
    }
    cout<<ans<<endl;
    for(int i=0;i<h.size();i++){
        int k=-1;
        for(int j=0;j<s.size();j++){
            if((k==-1||s[j]<s[k])&&h[i]<=s[j]) k=j;
        }
        if(k==-1) s.push_back(h[i]);
        else s[k]=h[i];
    }
    cout<<s.size();
    return 0;
}
```

- 问题一：最长**不上升**子序列长度，DP 转移 `if(a[j] > a[i]) f[i] = max(f[i], f[j] + 1)`。
- 问题二：用 Dilworth 定理——最少的不上升子序列覆盖数等于最长**严格上升**子序列长度，代码里贪心地用「能接住且最低」的系统去接，`s.size()` 即为答案。
- 源程序用 `#define int long long`，因此 `main` 写成 `signed main`。

### 区间选点 / 最大不相交区间

> 选最少的点，使每个闭区间 $[l_i, r_i]$ 都被覆盖；或选出最多的两两不重叠区间。

两者是同一类贪心（按右端点排序），源笔记给出的是一份「排序后线性扫描」的模板：

```cpp
#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> PII;
vector<PII> s;
void merge(vector<PII> &s) {
    vector<PII> res;
    sort(s.begin(),s.end());
    if(s.empty()){
        s=res;
        return;
    }
    int l=s[0].first,r=s[0].second;
    for(int i=1;i<s.size();i++){
        int a=s[i].first,b=s[i].second;
        if(a<=r){
            l=max(l,a);
            r=min(r,b);
        }else{
            res.push_back({l,r});
            l=a;
            r=b;
        }
    }
    res.push_back({l,r});
    s=res;
}
int main(){
    int n;cin>>n;
    for(int i=1;i<=n; i ++){
        int a,b;cin>>a>>b;
        s.push_back({a,b});
    }
    merge(s);
    cout<<s.size()<<endl;
}
```

- 策略要点：按右端点 $r_i$ 升序，`pos` 记当前最右选点，遇到 `pos < l_i` 就在 $r_i$ 放点并更新 `pos`；「最大不相交区间」判据是 `l_i >` 上一个选中区间的右端点。
- 解释：按右端点排序后第一个被选中的区间「让出的右侧空间最大」，替换成别的区间都不会更优，因此选它不亏。
- 该模板排序后线性扫描一遍，复杂度 $O(n \log n)$。

### 区间分组（小根堆维护各组的末尾右端点）

> 把 $n$ 个闭区间分成尽量少的组，使同组内区间两两不重叠。

```cpp
#include <bits/stdc++.h>
using namespace std;
vector<pair<int,int>> s;
priority_queue<int,vector<int>,greater<int>>h;
int main() {
    int n;cin>>n;
    for(int i=0;i<n;i++){
        int a,b;cin>>a>>b;
        s.push_back({a,b});
    }
    sort(s.begin(),s.end());
    for(int i=0;i<n;i++){
        int l=s[i].first,r=s[i].second;
        if(h.empty()||h.top()>=l){
            h.push(r);
        }else{
            h.pop();
            h.push(r);
        }
    }
    cout<<h.size()<<endl;
    return 0;
}
```

- 按左端点 $l_i$ 升序；小根堆存「每组最后一个区间的右端点」。
- 若堆顶（最小右端点）`>= l`，说明当前区间和**所有**已有组的末尾区间都重叠，必须新建一组；否则接到右端点最小的那组后面。
- 堆大小就是最少组数，复杂度 $O(n \log n)$。

### 区间覆盖（每次挑右端点最远的）

> 用尽量少的区间覆盖目标区间 $[s, t]$，无解则输出无解信息。

```cpp
#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> PII;
vector<PII> s;
void merge(vector<PII> &s) {
    vector<PII> res;
    sort(s.begin(),s.end());
    if(s.empty()){
        s=res;
        return;
    }
    int l=s[0].first,r=s[0].second;
    for(int i=1;i<s.size();i++){
        int a=s[i].first,b=s[i].second;
        if(a<=r){
            l=max(l,a);
            r=min(r,b);
        }else{
            res.push_back({l,r});
            l=a;
            r=b;
        }
    }
    res.push_back({l,r});
    s=res;
}
int main(){
    cout<<1;
}
```

- 策略要点：按左端点升序，从 $s$ 出发，在所有 $l_i \le pos$ 的区间里挑右端点最远的一个，把 $pos$ 更新为它的右端点，直到 $pos \ge t$ 或无区间可选。
- 贪心选择性质：把最优解里右端点较小的区间替换成当前右端点更大的，不会缩小已覆盖范围，也不会限制后续选择。
- 源笔记此处仅给出主函数骨架，完整的双指针扫描按上面的策略补全即可（扫描总复杂度 $O(n \log n)$）。

## 典型例题：反悔贪心

普通贪心「落子无悔」，但很多题存在**后效性 / 资源冲突**（时间限制、容量限制、相邻互斥），前面的选择会堵死后面的更优解。反悔贪心的思路是：先按大方向贪心地选上，若后续发现更优，就通过特定操作把之前的选择「换出来」。它一般用堆维护历史决策，复杂度 $O(n \log n)$。

### 任务调度

> 每个任务有耗时 $t_i$（通常为 1）、截止时间 $d_i$、收益 $p_i$，求截止前完成的最大总收益。

按 $d_i$ 升序，用小根堆存已选任务的收益：能塞下就直接加入；塞不下且 $p_i >$ 堆顶，就弹出收益最小的那个、换入 $p_i$。总任务数不变但收益单调增，且新集合仍满足截止限制。

### 利润问题

> 已知未来 $n$ 天股价 $a_i$，每天可买一股、卖一股或不动，求最大利润。

小根堆存历史买入价。遇到 $a_i >$ 堆顶就累加 $a_i - $ 堆顶，并把 $a_i$ **压两次**（一次当卖出、一次预留反悔），再弹出原堆顶。依据是 $a_j - a_i + a_i - a_k = a_j - a_k$，把多次买卖合并成一次更长的买卖。

### 互斥选择

> 在环形 / 线性序列中选 $k$ 个互不相邻的点，使点权和最大（或最小）。

用双向链表 + 大根堆。取出堆顶 $x$ 累加，删掉左右邻居 $l, r$，把 $x$ 的权值改成 $val_l + val_r - val_x$ 放回堆。之后若再选到该点，总贡献为 $val_x + (val_l + val_r - val_x) = val_l + val_r$，等价于「退选 $x$、改选 $l + r$」。

### 合法括号串

> 每个位置填左括号得 $a$、右括号得 $b$，求权值和最大的合法括号串（保证 $n$ 为偶数）。

先全部填右括号，建大根堆。对 $1 \le i \le n/2$，把前 $2i-1$ 个位置里未入队的 $a_i - b_i$ 入队，然后累加堆顶并弹出。合法括号串要求每个前缀左括号数 $\ge$ 右括号数且两者相等，于是每次改掉「代价最小」的那个位置即可。

> 补充：网络流中反向边的设计正是反悔贪心思想的体现。

## 复杂度分析

| 模型 | 主要操作 | 时间复杂度 | 空间复杂度 |
|---|---|---|---|
| 合并果子 | 小根堆 | $O(n \log n)$ | $O(n)$ |
| 排队打水 | 排序 + 堆 | $O(n \log n)$ | $O(n)$ |
| 货仓选址 | 排序 | $O(n \log n)$ | $O(n)$ |
| 导弹拦截 | DP / 贪心扫描 | $O(n^2)$ 或 $O(n \log n)$ | $O(n)$ |
| 区间选点 / 覆盖 | 排序 + 扫描 | $O(n \log n)$ | $O(n)$ |
| 区间分组 | 排序 + 小根堆 | $O(n \log n)$ | $O(n)$ |
| 反悔贪心 | 堆 + 链表 | $O(n \log n)$ 或 $O(k \log n)$ | $O(n)$ |

一句话：贪心算法本体是线性的，代价几乎都花在**排序**或**堆**上。

## 适用场景

- 目标是最优化，且能证明「当前最优 = 全局最优的一部分」。
- 经典模型：合并果子、排队打水、货仓选址、区间选点 / 覆盖 / 分组、导弹拦截。
- 带时限 / 容量 / 相邻互斥的调度类问题，用反悔贪心（堆 + 链表）改写。
- 贪心常作为高级算法的前置（如 Kruskal、Huffman、Prim），也会在 CSP 里和其他算法配合出现。

## 常见陷阱与注意事项

1. **没证明就乱用**：贪心最容易「看着对、实际上错」，拿不到正确性证明时先想 DP 或对拍。
2. **排序关键字选错**：区间问题排序关键字（左端点还是右端点）决定了策略是否正确，选错位置会直接 WA。
3. **区间边界开闭**：`a <= r` 还是 `a < r` 取决于题目是闭区间还是开区间，务必看清。
4. **反悔堆的维护**：反悔贪心要保证「换进去的元素能覆盖被换出的选择」，写错堆顶弹出 / 压入次数就失去反悔能力。
5. **数据范围**：`ans` 可能超过 `int`，涉及累加时用 `long long`（源程序里 `#define int long long` 就是干这个的）。

## 对比与扩展

| 维度 | 贪心 | DP |
|---|---|---|
| 决策 | 每步直接定，不回头看 | 枚举所有状态转移 |
| 正确性依赖 | 必须证明贪心选择性质 | 只要状态 / 转移正确即可 |
| 复杂度 | 通常 $O(n \log n)$ | 视状态数，常更高 |
| 后效性 | 要求可消除或不存在 | 天然处理 |

扩展方向：**反悔贪心**（把「后悔」做成可撤销的堆操作）、**邻项交换排序**（用偏序 / 交换论证定制比较函数）、以及贪心与数据结构（堆、链表、并查集）的组合。$AKB22$, '基础算法', array['贪心', '区间问题', '反悔贪心', '交换论证', '排序'], null, null, 'knowledge'),
('stripe-python', 'col-basic-greedy-block-building--stripe-python', '积木大赛类贪心 · stripe-python', $AKB23$> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 序列版本

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P1969 [NOIP 2013 提高组] 积木大赛](https://www.luogu.com.cn/problem/P1969)、[P5019 [NOIP 2018 提高组] 铺设道路](https://www.luogu.com.cn/problem/P5019)、[P3078 [USACO13MAR] Poker Hands S](https://www.luogu.com.cn/problem/P3078)。

发现操作瓶颈在最大数。因为比它小的数都到 $0$ 时，最大数不会变成 $0$，需要进行额外操作。

对于位置 $i$，若 $a_i > a_{i-1}$，那么必然要支付 $a_i-a_{i-1}$ 的代价。注意到这个代价与相对位置无关，可以直接统计一遍。注意这样子消不掉 $a_1$，最后要加回来。答案的式子

$a_1+\sum_{i=2}^{n} \max(a_i-a_{i-1},0)$```cpp
const int N = 1e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	int res = a[1];
	for (int i = 2; i <= n; i++) res += max(0, a[i] - a[i - 1]);
	cout << res;
}
```

### 变式

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$，或者将下标为奇数 / 偶数的元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P6631 [ZJOI2020] 序列](https://www.luogu.com.cn/problem/P6631)。

## 环上版本

> 给你长度为 $n$ 的首尾相接的环 $a$。一次操作将一个环上的子区间所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 2 \times 10^5, a_i \ge 0$。

原题链接：[AT_arc136_c [ARC136C] Circular Addition](https://www.luogu.com.cn/problem/AT_arc136_c)。

根据上面那题的启发，猜想答案是

$\sum_{i=1}^{n} \max(a_i-a_{(i + 1) \bmod n +1},0)$不难发现这是错的。但是可以往差分上想。由于这是个环，一次操作实际上使得差分数组一个点减一，一个点加一。则答案的下界为

$p=\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}|$显然这不是答案。记 $q= \max a$，一次操作最多只会使得 $q \gets q -1$。当 $q>p$ 时，答案下界为 $q$。

猜想答案为 $\max(p,q)$。下面给出贪心方案。

设一个全为 $\max a$ 的极长连续段为最大区间。

1. 当 $p<q$ 时，注意到 $0 \notin a$，则一次操作将整个环减少一，此时 $q \gets q -1$，$p$ 不变。重复操作至 $p=q$。

:::success[为什么 $0 \notin a$]

考虑反证法。显然 $p \ge \max a - \min a$，当 $0 \in a$ 时取等号，此时 $p \ge q$，矛盾。

:::

1. 当 $p>q$ 时，一次操作选取一个最大区间减一，则 $p \gets p-1$，$q$ 最多减一。重复操作至 $p=q$。

现在只需给出 $p=q$ 时的操作方案。

- 当最大区间的数目为 $1$ 时，一次操作将其减一，$p \gets p-1, q \gets q-1$；
- 当最大区间的数目不为 $1$ 时，可以推出 $0 \notin a$。找到一个最短的包含所有 $\max a$ 的区间，重复操作直到 $p=q=0$。

综上所述，答案为

$\max(\max_{i=1}^{n} a_i,\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}| )$```cpp
const int N = 2e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	long long p = 0;
	for (int i = 1; i <= n; i++) p += abs(a[i] - a[(i + 1) % n + 1]);
	cout << max<long long>(*max_element(a + 1, a + n + 1), p / 2);
}
```

## 树上版本

> 给你节点数为 $n$ 的无根树，点 $i$ 的权值为 $a_i$。一次操作将一条树链上的所有点权减 $1$。
>
> 求点权全变成 $0$ 的最少操作数。
>
> $n \le 3 \times 10^6, a_i \ge 0$。

原题链接：[P7246 手势密码](https://www.luogu.com.cn/problem/P7246)。

记 $(u,v)$ 表示对从 $u$ 到 $v$ 的树链进行一次操作。对于下图

![](https://cdn.luogu.com.cn/upload/image_hosting/r03khxgv.png)

可以发现，$(x,y), (r,r)$ 和 $(x,r),(y,r)$ 的作用效果是相同的。但是后者的路径可以向上延伸两次，前者只能延伸一次，所以子树决策 $(x,r),(y,r)$ 一定不劣。

所以在决策等效时，子树向根提供的路径数越多越好。

第二点，考虑路径什么时候“拐弯”。比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/z1hqy87m.png)

如果按照子树决策的思路，$(x,x),(y,y),(z,z)$ 三条路径各自都可以向 $r$ 延伸。在 $r$ 处，可以考虑将两条延伸至此的路径拼接，即变为 $(x,y),(z,z)$，则 $(x,x),(y,y)$ 的代价合并。

这样就可以 DFS 了。记当前节点为 $u$，设

$$
s=\sum_{v \in \operatorname{son}(u)} f(v)\\
m=\max_{v \in \operatorname{son}(u)} f(v)
$$

则不满足最优决策时，$u$ 子树内的代价下界为 $\max(\lfloor \dfrac{s}{2} \rfloor,s-m)$。设其为 $l_0$。

为了保证向上延伸的路径尽量多，考虑瓶颈。$a_u$ 显然是一个瓶颈，因为不能减成负数。子树和 $s-a_u$ 也是瓶颈。所以代价下界 $l=\max(0,\min(l_0,a_u,s-a_u))$。向上延伸的路径数就是 $a_u-l$。

别忘了更新答案。对于节点 $u$，不难发现贡献为 $a_u-s$。因为要满足 $l$ 的限制，贡献具体是 $\max(a_u-s+l,0)-l$。

```cpp
int opt, n, seed, a[N], u[N], v[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
long long ans;
long long dfs(int u, int fa) {
	long long s = 0, m = 0;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		long long x = dfs(v, u);
		s += x, m = max(m, x);
	}
	long long l = max(0LL, min({1LL * a[u], s - a[u], s / 2, s - m}));
	ans += max(0LL, a[u] - s + l) - l;
	return a[u] - l;
}

void _main() {
	cin >> opt;
	if (opt == 1) {
		cin >> n;
		for (int i = 1; i <= n; i++) cin >> a[i];
		for (int i = 1; i < n; i++) cin >> u[0] >> v[0], add_edge(u[0], v[0]), add_edge(v[0], u[0]);
	} else {
		cin >> seed >> n;
		Generate::n = n, Generate::seed = seed, Generate::RS(a, u, v);
		for (int i = 1; i < n; i++) add_edge(u[i], v[i]), add_edge(v[i], u[i]);
	}
	dfs(1, -1);
	cout << ans;
}
```

## 基环树版本

> 给你节点数为 $n$ 的基环树，点 $i$ 的权值为 $a_i$。一次操作将一条简单路径上的所有点权减 $1$。
>
> 求点权全变成 $0$ 的最少操作数。
>
> $n \le 3 \times 10^6, a_i \ge 0$。

不会。$AKB23$, '基础算法', array['积木大赛', '贪心', '差分', '区间'], 'col-basic-greedy', null, 'knowledge'),
('stripe-python', 'col-basic-greedy-snow-shoveling--stripe-python', '铲雪类贪心 · stripe-python', $AKB24$> 本文由 stripe-python 授权合并，保留原文结构与表述。
“铲雪”类问题出自本人的模拟赛，这类题目的一般形式如：给你序列 $a$，一次操作将一个特定结构中所有元素减 $1$，求元素全变成 $0$ 的最少操作数。

本文可能并不会给出严谨的正确性证明，更多的是叙述做法。

## 序列版本

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P1969 [NOIP 2013 提高组] 积木大赛](https://www.luogu.com.cn/problem/P1969)、[P5019 [NOIP 2018 提高组] 铺设道路](https://www.luogu.com.cn/problem/P5019)、[P3078 [USACO13MAR] Poker Hands S](https://www.luogu.com.cn/problem/P3078)。

发现操作瓶颈在最大数。因为比它小的数都到 $0$ 时，最大数不会变成 $0$，需要进行额外操作。

对于位置 $i$，若 $a_i > a_{i-1}$，那么必然要支付 $a_i-a_{i-1}$ 的代价。注意到这个代价与相对位置无关，可以直接统计一遍。注意这样子消不掉 $a_1$，最后要加回来。答案的式子

$a_1+\sum_{i=2}^{n} \max(a_i-a_{i-1},0)$:::

```cpp
const int N = 1e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	int res = a[1];
	for (int i = 2; i <= n; i++) res += max(0, a[i] - a[i - 1]);
	cout << res;
}
```

### 变式

> 给你长度为 $n$ 的数组 $a$。一次操作将一个子区间上所有元素减 $1$，或者将下标为奇数 / 偶数的元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 10^5, a_i \ge 0$。

原题链接：[P6631 [ZJOI2020] 序列](https://www.luogu.com.cn/problem/P6631)。


定义第一类操作为“直线”，二三类操作为“跳线”。

只有直线是简单的。加入跳线以后，考虑向相邻位置转移。

从两个数开始考虑：

1. 若 $a_1,a_2 >0$，从 $a_1$ 开始一条直线。
2. 若 $a_1>0,a_2=0$，从 $a_1$ 开始一条跳线。
3. 若 $a_1=0$，跳过决策。

考虑推广到 $n$ 个数，证明上述决策最优即可。后两条决策是比较显然的，只需理解直线一定不劣于跳线。

设一段连续极长的非 $0$ 区间 $[l,r]$，有 $a_{r+1}=0$，直线不能向后延伸。如果用跳线，最优方案是从与 $r$ 奇偶性相同的点延伸一条跳线，代价至少为 $2$。而使用一次直线覆盖 $[l,r]$ 的代价加上一次跳线的代价恰为 $2$，证毕。


```cpp
const int N = 1e5 + 5;
int n, a[N];

void _main() {
	cin >> n; a[n + 1] = 0;
	for (int i = 1; i <= n; i++) cin >> a[i];
	long long res = 0, x = 0, y = 0, nxt = 0, z = 0;
	for (int i = 1; i <= n; i++) {
		int d = x + y - a[i + 1];
		if (d > 0) {
			if (x < d) y += x - d, d = x;
			if (y < d) x += y - d, d = y;
			x -= d, y -= d, a[i + 1] -= d, z = d;
		}
		a[i + 1] -= x + y, res += a[i];
		int h = min(a[i], a[i + 1]);
		x += h, a[i] -= h, a[i + 1] -= h, nxt += a[i];
		a[i + 1] += z, res -= z, z = 0, swap(y, nxt);
	} cout << res << '\n';
}
```

## 环上版本

> 给你长度为 $n$ 的首尾相接的环 $a$。一次操作将一个环上的子区间所有元素减 $1$。
>
> 求元素全变成 $0$ 的最少操作数。
>
> $n \le 2 \times 10^5, a_i \ge 0$。

原题链接：[AT_arc136_c [ARC136C] Circular Addition](https://www.luogu.com.cn/problem/AT_arc136_c)。

根据上面那题的启发，猜想答案是

$\sum_{i=1}^{n} \max(a_i-a_{(i + 1) \bmod n +1},0)$不难发现这是错的。但是可以往差分上想。由于这是个环，一次操作实际上使得差分数组一个点减一，一个点加一。则答案的下界为

$p=\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}|$显然这不是答案。记 $q= \max a$，一次操作最多只会使得 $q \gets q -1$。当 $q>p$ 时，答案下界为 $q$。

猜想答案为 $\max(p,q)$。下面证明充分性。

设一个全为 $\max a$ 的极长连续段为最大区间。

1. 当 $p<q$ 时，注意到 $0 \notin a$，则一次操作将整个环减少一，此时 $q \gets q -1$，$p$ 不变。重复操作至 $p=q$。


考虑反证法。显然 $p \ge \max a - \min a$，当 $0 \in a$ 时取等号，此时 $p \ge q$，矛盾。


1. 当 $p>q$ 时，一次操作选取一个最大区间减一，则 $p \gets p-1$，$q$ 最多减一。重复操作至 $p=q$。

现在只需给出 $p=q$ 时的操作方案。

- 当最大区间的数目为 $1$ 时，一次操作将其减一，$p \gets p-1, q \gets q-1$；
- 当最大区间的数目不为 $1$ 时，可以推出 $0 \notin a$。找到一个最短的包含所有 $\max a$ 的区间，重复操作直到 $p=q=0$。

综上所述，答案为

$\max(\max_{i=1}^{n} a_i,\dfrac{1}{2}\sum_{i=1}^{n} |a_i-a_{(i + 1) \bmod n +1}| )$::::

```cpp
const int N = 2e5 + 5;
int n, a[N];
void _main() {
	cin >> n;
	for (int i = 1; i <= n; i++) cin >> a[i];
	long long p = 0;
	for (int i = 1; i <= n; i++) p += abs(a[i] - a[(i + 1) % n + 1]);
	cout << max<long long>(*max_element(a + 1, a + n + 1), p / 2);
}
```

## 树上版本

> 给你节点数为 $n$ 的无根树，点 $i$ 的权值为 $a_i$。一次操作将一条树链上的所有点权减 $1$。
>
> 求点权全变成 $0$ 的最少操作数。
>
> $n \le 3 \times 10^6, a_i \ge 0$。

原题链接：[P7246 手势密码](https://www.luogu.com.cn/problem/P7246)。

记 $(u,v)$ 表示对从 $u$ 到 $v$ 的树链进行一次操作。对于下图

![](https://cdn.luogu.com.cn/upload/image_hosting/r03khxgv.png)

可以发现，$(x,y), (r,r)$ 和 $(x,r),(y,r)$ 的作用效果是相同的。但是后者的路径可以向上延伸两次，前者只能延伸一次，所以子树决策 $(x,r),(y,r)$ 一定不劣。

所以在决策等效时，子树向根提供的路径数越多越好。

第二点，考虑路径什么时候“拐弯”。比如：

![](https://cdn.luogu.com.cn/upload/image_hosting/z1hqy87m.png)

如果按照子树决策的思路，$(x,x),(y,y),(z,z)$ 三条路径各自都可以向 $r$ 延伸。在 $r$ 处，可以考虑将两条延伸至此的路径拼接，即变为 $(x,y),(z,z)$，则 $(x,x),(y,y)$ 的代价合并。

这样就可以 DFS 了。记当前节点为 $u$，设

$$
s=\sum_{v \in \operatorname{son}(u)} f(v)\\
m=\max_{v \in \operatorname{son}(u)} f(v)
$$

则不满足最优决策时，$u$ 子树内的代价下界为 $\max(\lfloor \dfrac{s}{2} \rfloor,s-m)$。设其为 $l_0$。

为了保证向上延伸的路径尽量多，考虑瓶颈。$a_u$ 显然是一个瓶颈，因为不能减成负数。子树和 $s-a_u$ 也是瓶颈。所以代价下界 $l=\max(0,\min(l_0,a_u,s-a_u))$。向上延伸的路径数就是 $a_u-l$。

别忘了更新答案。对于节点 $u$，不难发现贡献为 $a_u-s$。因为要满足 $l$ 的限制，贡献具体是 $\max(a_u-s+l,0)-l$。

```cpp
int opt, n, seed, a[N], u[N], v[N];
int tot = 0, head[N];
struct Edge {
	int next, to;
} edge[N << 1];
inline void add_edge(int u, int v) {
	edge[++tot].next = head[u], edge[tot].to = v, head[u] = tot;
}
long long ans;
long long dfs(int u, int fa) {
	long long s = 0, m = 0;
	for (int j = head[u]; j != 0; j = edge[j].next) {
		int v = edge[j].to;
		if (v == fa) continue;
		long long x = dfs(v, u);
		s += x, m = max(m, x);
	}
	long long l = max(0LL, min({1LL * a[u], s - a[u], s / 2, s - m}));
	ans += max(0LL, a[u] - s + l) - l;
	return a[u] - l;
}

void _main() {
	cin >> opt;
	if (opt == 1) {
		cin >> n;
		for (int i = 1; i <= n; i++) cin >> a[i];
		for (int i = 1; i < n; i++) cin >> u[0] >> v[0], add_edge(u[0], v[0]), add_edge(v[0], u[0]);
	} else {
		cin >> seed >> n;
		Generate::n = n, Generate::seed = seed, Generate::RS(a, u, v);
		for (int i = 1; i < n; i++) add_edge(u[i], v[i]), add_edge(v[i], u[i]);
	}
	dfs(1, -1);
	cout << ans;
}
```$AKB24$, '基础算法', array['铲雪', '积木大赛', '贪心', '区间操作'], 'col-basic-greedy', null, 'knowledge'),
('Xesir', 'col-basic-high-precision--xesir', '高精度算法（大整数加减乘除模板） · Xesir', $AKB25$## 算法原理

高精度计算（Arbitrary-Precision Arithmetic），也被称作**大整数（bignum）计算**：利用字符串来实现大整数加减乘除。

C++ 里 `int` 最大约 $2^{31}-1$，`long long` 也就 $9\times10^{18}$，题目里的数字一大就没法存，只能自己用字符串/数组模拟竖式。一般处理的数据在 $10^{500}$ 以下（准确地说，在 $10^{200}\sim10^{500}$ 之间），超过 $10^{1000}$ 会有压位提示。

> 高精度部分由蒟蒻 **RedStone** 友情提供qwq（所以下文都是以 RedStone 的码风及思路来写辣awa）。~~我是个蒟蒻 代码又臭又长~~，所以高精度除高精度就交给拖更王 GOC 辣。下文「存储」等板块主要介绍思想，代码较少；如果只是需要模板，翻到本板块最下方拿。

### 存储：为什么要倒序

正常来说，数字存储「应该」从数组的低位开始对吧~~（笑）~~。所以我们输入输出时要**倒序处理**，让下标 0 对应个位，方便从低位往高位处理进位。倒序有多种方法：倒序数组存储、指针倒序遍历或者 `reverse()`；下面先给数组倒序处理，模板里用的是指针倒序遍历。

> 插一句，string 可以当做一个 char 数组使用，只不过 char 数组定长、string 不定长，所以使用 char 数组也是可以的。

### 运算：加、减、乘、除

加法与减法最简单，可以借鉴竖式的思想，从最低位一位一位处理。**需要注意：负数、进位、借位。**

- **负数处理**：分类讨论正负号（正正、正负、负正、负负），把异号情形变号后转换成同号运算，最后再补上结果的正负。比如 $a+(-b)=a-b$、$a-(-b)=a+b$ 的道理能明白吧。
- **进位处理**：逢 10 进 1；加法取较短长度，最后若还有进位要 `c[i+1]++`。
- **借位处理**：和进位差不多，但取较长的那个，绝对值相减，不够就向前借 1 当 10，最后判断正负。

乘法还是列竖式，实质上就是 $a\times b_i\times 10^i$ 之和。因为我们用的是整数数组，所以可以**乘完之后再统一相加处理进位**，怎么开心怎么来。

除法也是列竖式长除法，本质是逐次减法的过程。为了减少冗余运算，先算出被除数长度 $l_a$ 与除数长度 $l_b$，从下标 $l_a-l_b$ 开始、**从高位到低位**计算商（这与手工计算时把第一次乘法的最高位与被除数最高位对齐的做法是一样的）。

## 核心操作详解

- 加法逐位：`sum = carry + a[i] + b[i]`，`c[i] = sum % 10`，`carry = sum / 10`。
- 减法逐位：不够减则 `a[i] += 10; a[i+1] -= 1;`，再 `c[i] = a[i] - b[i]`。
- 乘法：第 $i$ 位乘第 $j$ 位，结果累加到结果的第 $i+j$ 位。
- 除法试商：`r = r*10 + (c-'0')`，`d = r / b`，`r %= b`，最后去掉前导 0。

## 逐行代码解析

### 存储与倒序

```cpp
const int MaxN=500;	//最多500位

int a[MaxN],b[MaxN];	//处理后的倒序数组
int c[MaxN];		//答案数组
string s1,s2;		//原字符串

cin>>s1>>s2;
int len1=s1.size(),len2=s2.size();
for(int i=0;i<len1;i++) a[i]=s1[len1-1-i]-'0';
for(int i=0;i<len2;i++) b[i]=s2[len2-1-i]-'0';
//倒序存储
```

- 下标 0 存个位、下标 1 存十位……，这样进位方向与数组下标增长方向一致。
- `s[len-1-i]` 把字符串的高位放到数组的高位，`- '0'` 把字符转成数值。

### 进位处理

```cpp
int len=min(len1,len2);//取较短长度
//sum为当前位的和，carry为上一位进上来的数字
//对于每一位i：
	int sum=carry;
	sum+=a[i]+b[i];
	sum%=10;
	carry=sum/10;
	c[i]=sum;
```

```cpp
if(carry) c[i+1]++;//最高位如果还有进位，要单独补一位
```

- 加法只需循环到较短长度，剩下的高位要么是原数的高位、要么被最后的进位补上。
- 口诀：先算 `sum`，再取模留本位的值、取整除留给下一位。

### 借位处理

```cpp
int len=max(len1,len2);//取较长长度
//对于每一位i：
if(a[i]<b[i]){
	a[i]+=10;
	a[i+1]--;
}
c[i]=a[i]-b[i];
```

```cpp
while(c[maxl]==0&&maxl>0) maxl--;//去除前导0
```

- 减法取较长长度，逐位相减，不够就借位。
- 注意**前导 0**：如果两数正好相等（差为 0），要留一个 0，所以 `maxl>0` 是必须的。

### 模板其一：BigInt namespace（RedStone 版）

完整模板，整段拿走即可：

```cpp
namespace BigInt{
	string readString(){
	    string s;
	    char ch=getchar();
	    while(ch==' '||ch=='\n'||ch=='\r') ch=getchar();
	    while(ch!=' '&&ch!='\n'&&ch!='\r'){
	        s+=ch;
	        ch=getchar();
	    }
	    return s;
	}
	
    string trim(string s){
        if(s.empty()||s=="0") return "0";
        int pos=0;
        while(pos<(int)s.size()&&s[pos]=='0') pos++;
        if(pos==(int)s.size()) return "0";
        return s.substr(pos);
    }
    int compare(string a,string b){
        a=trim(a),b=trim(b);
        if(a.size()!=b.size()) return a.size()<b.size()?-1:1;
        if(a<b) return -1;
        if(a>b) return 1;
        return 0;
    }
    
    string add(string a,string b){
        string res;
        int i=a.size()-1,j=b.size()-1,carry=0;
        while(i>=0||j>=0||carry){
            int sum=carry;
            if(i>=0) sum+=a[i--]-'0';
            if(j>=0) sum+=b[j--]-'0';
            res+=sum%10+'0';
            carry=sum/10;
        }
        reverse(res.begin(),res.end());
        return trim(res);
    }
    string sub(string a,string b){
        string res;
        int i=a.size()-1,j=b.size()-1,borrow=0;
        while(i>=0){
            int da=a[i--]-'0';
            int db=(j>=0?b[j--]-'0':0);
            int diff=da-db-borrow;
            if(diff<0) diff+=10,borrow=1;
            else borrow=0;
            res+=diff+'0';
        }
        reverse(res.begin(),res.end());
        return trim(res);
    }
    string mul(string a,string b){
        if(a=="0"||b=="0") return "0";
        int la=a.size(),lb=b.size();
        vector<int> res(la+lb,0);
        for(int i=la-1;i>=0;i--){
            for(int j=lb-1;j>=0;j--){
                int m=(a[i]-'0')*(b[j]-'0');
                int sum=m+res[i+j+1];
                res[i+j+1]=sum%10;
                res[i+j]+=sum/10;
            }
        }
        string ans;
        for(int x:res) if(!(ans.empty()&&x==0)) ans+=x+'0';
        return ans.empty()?"0":ans;
    }
    pair<string,int> divmod(string a,int b){
        string q;
        long long r=0;
        bool lead=true;
        for(char c:a){
            r=r*10+(c-'0');
            int d=r/b;
            r%=b;
            if(!lead||d!=0){
                q+=d+'0';
                lead=false;
            }
        }
        if(q.empty()) q="0";
        return {q,(int)r};
    }
    
    struct Int{
        string s;
        bool neg;
        Int(string num="0"){
            neg=false;
            if(num.empty()){s="0"; return;}
            int st=0;
            if(num[0]=='-'){
                neg=true;
                st=1;
            }
            if(num[0]=='+') st=1;
            s=trim(num.substr(st));
            if(s=="0") neg=false;
        }
        Int(long long num){
            neg=false;
            string tmp=to_string(num);
            if(tmp[0]=='-'){
                neg=true;
                s=trim(tmp.substr(1));
            }else{
                s=trim(tmp);
            }
        }
        string str(){
            if(neg&&s!="0") return "-"+s;
            return s;
        }
    };
    
    Int add(Int a,Int b){
        if(a.neg==b.neg){
            string res=::BigInt::add(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }
        int c=compare(a.s,b.s);
        if(c==0) return Int("0");
        if(c>0){
            string res=::BigInt::sub(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }else{
            string res=::BigInt::sub(b.s,a.s);
            if(b.neg) return Int("-"+res);
            return Int(res);
        }
    }
    Int sub(Int a,Int b){
        if(a.neg!=b.neg){
            Int t=b;
            t.neg=!t.neg;
            return add(a,t);
        }
        int c=compare(a.s,b.s);
        if(c==0) return Int("0");
        if(c>0){
            string res=::BigInt::sub(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }else{
            string res=::BigInt::sub(b.s,a.s);
            if(!a.neg) return Int("-"+res);
            return Int(res);
        }
    }
    Int mul(Int a,Int b){
        if(a.s=="0"||b.s=="0") return Int("0");
        string res=::BigInt::mul(a.s,b.s);
        if((a.neg&&!b.neg)||(!a.neg&&b.neg)) return Int("-"+res);
        return Int(res);
    }
    Int div(Int a,int b){
        if(b==0) return Int("0");
        int ab;
        if(b>0) ab=b;
        else ab=-b;
        pair<string,int> p=divmod(a.s,ab);
        string q=p.first;
        if((a.neg&&b>0)||(!a.neg&&b<0)) return Int("-"+q);
        return Int(q);
    }
    int mod(Int a,int b){
	    if(b==0) return 0;
	    int ab=b>0?b:-b;
	    auto [q,r]=divmod(a.s,ab);
	    return a.neg?-r:r;
	}
}
```

- `readString()`：专为高精度写的字符串快读，返回一个字符串。
- `trim(str)`：去除前导 $0$，返回处理后的字符串。
- `compare(str_a,str_b)`：比较两个字符串的绝对值，返回 $-1$ 表示 `str_b` 大，`1` 表示 `str_a` 大，`0` 表示一样大。
- `add` / `sub` / `mul`：分别是加、减、乘的底层实现，本质是绝对值运算，返回字符串结果。
- `divmod(str_a,str_b)`：除法底层实现（除以低精度 int），返回一个 `pair<string,int>`，`first` 是商、`second` 是余数。
- `Int` 结构体：`s` 存绝对值，`neg` 是负号标签；`str()` 把它转成可输出的字符串。
- `Int` 版的 `add/sub/mul/div/mod`：可以看作对外接口，主要处理负号，内部调用上面的底层实现。

`mod` 里用到了 **C++17** 的结构化绑定：

```cpp
auto [q,r]=divmod(a.s,ab);
//  ├─┘  ├─┘  ├────────────┘
//  │    │    └── 函数返回 pair<string,int>
//  │    └─────── 把 pair.first 赋值给 q
//  └──────────── 把 pair.second 赋值给 r
```

由于目前竞赛多用 **C++14**，等价写法是：

```cpp
pair<string,int> p=divmod(a.s,ab);	//这里pair<string,int>可替换为auto
string q=p.first;
int r=p.second;
```

### 食用方法

```cpp
using namespace BigInt;

Int a("12345678901234567890");	// 从字符串创建
Int b(12345);			// 从整数创建
Int c("-987654321");		// 负数也可以
Int d;				// 默认是0
//读入可采用Int str(readString());很简便吧？就和正常快读一样用就行。

Int x,y;
int z;
add(x,y);	//加法
sub(x,y);	//减法
mul(x,y);	//乘法
div(x,z);	//除法
mod(x,z);	//余数
//以上这些都是有返回值的哦
//可以使用形如Int result=add(x,y);来获取其值

cout<<result.str();	//输出
```

- 因为用 `namespace` 打包，如果担心函数名冲突而不写 `using namespace BigInt;`，那在调用 `add/sub/mul/div/mod` 之前都要加上 `BigInt::`，例：`BigInt::Int a(114514);`。
- 所有这些运算都有返回值，可以用 `Int result = add(x,y);` 接住，再用 `result.str()` 输出。

### 模板其二：高精度除高精度（GOC 版）

GOC 的代码比较抽象，看不懂优先用上面的 BigInt 模板。高除高的原理：每次在被除数中截取与除数等长的部分，将除转化为多次减法，直到截取的部分小于除数为止，减的次数就是这一位的商；剩下的继续参与运算，最后剩下的 `a` 就是余数。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
#define fi first
#define se second
#define endl '\n'
const int N=1145;//依据数据范围调整
const int J=4;
bool strbdx(string a,string b){//比较高精度数(字符串形式)的大小，a>=b返回true
	int n=(int)a.size(),m=(int)b.size();
	if(n!=m) return n>m;
	for(int i=0;i<n;i++){
		if(a[i]!=b[i]) return a[i]>b[i];
	}
	return true;
}
string gjdplus(string a,string b){//高精度加法
	vector<int> c;
	int u,t=0;
	while((int)a.size()<(int)b.size()) a='0'+a;
		//TODO
	while((int)a.size()>(int)b.size()) b='0'+b;
	for(int i=(int)a.size()-1,j=(int)b.size()-1;i>=0&&j>=0;i--,j--){
		//int aa=a[i],bb=b[j];
		//if(i<0) i=0;
		//if(j<0) j=0;
		u=a[i]-48+b[j]-48;
		u+=t;t=0;
		t=u/10,u%=10;
		c.push_back(u);
	}
	if(t>0) c.push_back(t);
	string d;
	for(int i=0;i<(int)c.size();i++){
		char u=c[i]+48;
		d=u+d;
	}
	return d;
}
string gjdsub(string a,string b){//高精度减法
	int n=(int)a.size(),m=(int)b.size();
	bool f=false;
	if(!strbdx(a,b)) swap(a,b),f=true;
	vector<int> c;
	while(m<n) m++,b='0'+b;
	int u,t=0;
	for(int i=(int)a.size()-1,j=(int)b.size()-1;i>=0&&j>=0;i--,j--){
		u=a[i]-48-(b[j]-48);
		u-=t;t=0;
		while(u<0){
			u+=10;t++;
		}
		c.push_back(u);
	}
	int qd=true;
	string d;
	for(int i=0;i<(int)c.size();i++){
		if(c[i]==0){
			if(qd) continue;
		}else dq=false;
		char u=c[i]+48;
		d=u+d;
	}
	if(f) d='-'+d;
	return d; 
}
string gjdmion(string a,int b){//高精度乘单精度
	int sum[N]={0};
	int n=(int)a.size();
	for(int i=0;i<n;i++){
		sum[i+1]=a[n-i-1]-'0';
	}
	for(int i=1;i<=n;i++){
		sum[i]*=b;
	}
	for(int i=1;i<=n+J;i++){//J是单精度数的最高位数，如1145有4位，则积不超过n+4位
		if(sum[i]>=10){
			sum[i+1]+=sum[i]/10;
			sum[i]%=10;
		}
	}
	int idx=0;
	for(int i=n+J;i>=1;i--){
		if(sum[i]!=0){
			idx=i;break;
		}
	}
	string res="";
	for(int i=idx;i>=1;i++){
		res+=(char)(sum[i]+48);
	}
	return res;
}
string gjdmulti(string a,string b){//高精度乘高精度
	string res="0";
	reverse(b.begin(),b.end());
	for(int i=0;i<(int)b.size();i++){
		string xdm=gjdmion(a,b[i]-'0');
		for(int j=1;j<=i;j++) xdm+='0';
		res=gjdplus(res,xdm);
	}
	return res;
}
string gjdfloat(int a,int b,int n){//单精度除单精度，保留n位高精度商
	string res="";
	res+=(a/b)+'0';int t=a%b;res+='.';
	while(n--){
		t*=10;
		res+=(t/b)+'0';
		t%=b;
	}
	return res;
}
pair<string,int> gjdsionblt(string s,int b){//高精度数除以单精度数，返回商与余数
	pair<string,int> ans;
	ans.fi="";ans.se=0;
	int a[N]={0};int c[N]={0};
	for(int i=0;i<(int)s.size();i++) a[i]=s[i]-'0';
	int t=0;
	for(int i=0;i<(int)s.size();i++){
		t=t*10+a[i];
		if(t>=b){
			c[i]=t/b;
			t=t%b;
		}else c[i]=0;
	}
	int idx=0;
	for(int i=0;i<(int)s.size();i++){
		if(c[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<(int)s.size();i++){
		ans.fi+=(char)(c[i]+'0');
	}
	ans.se=t;
	return ans;
}
void cpy(int x[],int y[],int hyw){//将x数组内容复制到y数组中,右偏移hyw位,该函数服务于高除高
	for(int i=1;i<=x[0];i++){
		y[i+hyw]=x[i];
	}
	y[0]=x[0]+hyw;
}
bool cmp(int x[],int y[]){//比较高精度数(字数组形式)的大小，x>=y返回true
	if(x[0]>y[0]) return true;
	else if(x[0]<y[0]) return false;
	else{
		for(int i=1;i<=x[0];i++){
			if(x[i]!=y[i]) return x[i]>y[i];
		}
	}
	return true;
}
pair<string,string> gjdivisi(string s1,string s2){//高精度除高精度，返回商与余数
	pair<string,string> ans={"",""};
	int a[N]={0},b[N]={0},c[N]={0};
	a[0]=s1.size(),b[0]=s2.size();//x[0]表示x数组有效长度
	if(a[0]<b[0]||(a[0]==b[0]&&s1<s2)){
		ans={"0",s1};return ans;
	}
	c[0]=a[0]-b[0]+1;
	for(int i=1;i<=a[0];i++) a[i]=s1[i-1]-'0';
	for(int i=1;i<=b[0];i++) b[i]=s2[i-1]-'0';
	int t[2*N]={0};//b的临时移位
	for(int i=1;i<=c[0];i++){
		memset(t,0,sizeof(t));
		cpy(b,t,i-1);
		a[0]=t[0];
		while(cmp(a,t)){
			for(int j=a[0];j>=1;j++){
				if(a[j]<t[j]&&j!=1){
					a[j]+=10;a[j-1]--;
				}
				a[j]-=t[j];
			}
			c[i]++;
		}
	}
	int idx=0;//处理前导0
	for(int i=1;i<=c[0];i++){
		if(c[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<=c[0];i++){
		ans.fi+=(char)(c[i]+'0');
	}
	idx=0;
	for(int i=1;i<=a[0];i++){
		if(a[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<=a[0];i++){
		ans.se+=(char)(a[i]+'0');
	}
	return ans;
}
signed main() {
    //按题意调用
    return 0;
}
```

- `gjdplus` / `gjdsub`：字符串形式的高精加 / 减，`strbdx` 负责比大小。
- `gjdmion` / `gjdmulti`：高精乘单精 / 高精乘高精，`J` 是单精度数的最高位数。
- `gjdivisi`：高精除高精，用 `cmp` + `cpy`（把除数右移 `i-1` 位）逐位试商。
- 这段是原笔记的原始代码，里面留了未删掉的临时注释标记以及个别变量名笔误，只做搬运、不改实现，使用前请自行核对。

## 复杂度分析

| 运算 | 复杂度 | 说明 |
|---|---|---|
| 加法 / 减法 | $O(n)$ | 每位数处理一次，$n$ 为较长数位 |
| 高精 × 高精 | $O(n \cdot m)$ | 双重循环，$n$、$m$ 为两个数的位数 |
| 高精 ÷ 低精 | $O(n)$ | 从高位到低位逐位试商 |
| 高精 ÷ 高精（朴素） | 最坏 $O(n \cdot m)$ 以上 | 「试商 + 反复减法」，位数大时代价高 |

空间复杂度 $O(n+m)$，用于存储处理数组与结果。固定数组版本（如 `MaxN=500`、`N=1145`）只支持相应位数以内的大整数。

## 适用场景

1. **大整数运算**：数字超过 `long long` 范围的加减乘。
2. **阶乘、幂运算**：结果很大的数学题。
3. **斐波那契数列**：第几十项就会超过 `long long`。
4. **组合数计算**：大数阶乘与组合数。
5. **高精度求余、高精度除法**：在本实现基础上扩展。

## 常见陷阱与注意事项

1. **前导 0 处理**：结果高位可能有多余的 0，要 `while(idx>0 && !tmp[idx]) idx--;`，`idx>0` 保证结果就是 0 时至少留一位。
2. **字符串与数组方向相反**：字符串高位在前，运算数组低位在前，输入要反转、输出还要反转回来。搞反方向是高精度最常见的 bug。
3. **乘法的位数位置**：第 $i$ 位 × 第 $j$ 位 → 结果加到第 $i+j$ 位，不是 $i+j+1$。
4. **memset 清零**：全局数组会保留上一次运算的结果，每次运算前要 `memset` 清零，忘了必错。
5. **乘法溢出**：200 位 × 200 位时某一位最多累加 $200 \times 9 \times 9 = 16200$，`int` 够用；几万位的乘法就可能溢出，需要 `long long` 或边乘边进。
6. **减法的负数问题**：本实现只处理 $a \ge b$；$a < b$ 时要交换两数、算 $b-a$、再加负号。
7. **0 的特判**：加法加 0 等于本身可直接返回；乘法乘 0 等于 0，必须特判。
8. **数组大小要足够**：加法结果最多 $\max(n,m)+1$ 位，乘法最多 $n+m$ 位，开小会越界。
9. **输入前导 0**：若输入形如 `"00123"`，位数判断会出错，比较和运算前最好先 `trim`。
10. **浮点 `pow` 不可靠**：旁边进制转换那类用 `pow` 算权重的思路，位数一多会丢精度，大数场景要用高精或整数快速幂。

## 对比与扩展

- **模板选择**：日常用 BigInt namespace 版就够了（接口清晰、自带负号处理）；需要高精除高精时再上 GOC 版。
- **压位高精度**：每个数组元素存多位（如 9 位），减少运算次数、提高常数。
- **FFT 优化乘法**：用快速傅里叶变换把乘法优化到 $O(n \log n)$。
- **高精度取模**：从高位到低位逐位取模。
- **负数 / 小数高精度**：统一处理正负号；小数本质和整数一样，只是记住小数点位置。
- 延伸阅读：[OI Wiki · 高精度](https://oi.wiki/math/bignum/)。$AKB25$, '基础算法', array['高精度', '大整数', '字符串模拟', '竖式运算', '进位借位'], null, null, 'knowledge'),
('Fohen', 'col-basic-high-precision-div--fenfeng', '高精度除法与取模 · Fohen', $AKB26$## 算法原理

高精度除法解决的问题是：当被除数（甚至除数）大到 `long long` 也存不下时，如何计算商和余数。基本思路仍然是**用字符串存储大整数，模拟人工列竖式除法的过程**。

竖式长除法本质上是一个**逐次减法的过程**：每一步从高位取数、试商、更新余数。与加减乘"从低位向高位处理"不同，**除法必须从最高位开始向最低位遍历**——因为高位的商先确定，余下的余数再与低位拼接继续运算。

按除数的大小，高精度除法分为两种情形：

1. **除以低精度（除数是普通整数）**：除数能用 `int` 存下，逐位试商即可，实现简单，复杂度 $O(n)$；
2. **除以高精度（除数也是大整数）**：每次在被除数中截取与除数等长的部分，把"除"转化为"多次减"，直到截取的部分小于除数为止；减的次数就是这一位的商，剩下的余数继续参与下一位运算，最后剩下的就是总余数。

本页代码实现第一种（除以低精度）的完整可运行程序；第二种的原理与复杂度在「对比与扩展」中说明。

## 核心公式 / 状态定义与转移方程

### 除以低精度：逐位试商的迭代式

设被除数 $a = d_0 d_1 \cdots d_{n-1}$（$d_0$ 为最高位），除数为 $b$，维护一个"当前余数" $r$。从最高位到最低位，对第 $i$ 位执行：

$$
r \leftarrow 10r + d_i,\qquad q_i = \left\lfloor \frac{r}{b} \right\rfloor,\qquad r \leftarrow r \bmod b
$$

- $r \leftarrow 10r + d_i$：把当前余数"左移"一位，再拼上新的数字位；
- $q_i$：第 $i$ 位的商，即当前余数能容纳多少个 $b$；
- $r \leftarrow r \bmod b$：更新余数，供下一位继续使用。

去掉商 $q_0 q_1 \cdots q_{n-1}$ 的前导零后得到最终商，最后的 $r$ 就是余数。由于每步都先取模，$r$ 始终满足 $0 \le r < b$，因此 $10r + d_i < 10b + 9$，这也是代码里 $r$ 用 `long long` 存储的原因。

### 除以高精度：逐次减法

设被除数 $a$、除数 $b$（同为高精度）。商的每一位 $c_i$（$c_i \in [0,9]$）通过把 $b$ 左移对齐到对应位置后反复相减得到，减的次数就是 $c_i$。形式化地：

$$
a = b \times \left(\sum_i c_i \cdot 10^{\,k-i}\right) + r,\qquad 0 \le r < b
$$

其中 $k$ 是商的最高位下标，$r$ 是最终余数。

## 逐行代码解析

### 头文件与命名空间

```cpp
#include <bits/stdc++.h>
using namespace std;
```

- `bits/stdc++.h` 是竞赛常用的万能头文件，一次引入几乎所有标准库；
- `using namespace std` 省略标准库名字前的 `std::` 前缀，代码更简洁。

### 核心函数：高精度除以低精度

```cpp
// 高精度除以低精度：返回 pair<商, 余数>
pair<string,int> divmod(string a,int b){
    string q;          // 商
    long long r=0;     // 当前余数
    bool lead=true;    // 是否仍处于前导零阶段
    for(char c:a){
        r=r*10+(c-'0');   // 余数左移一位，拼上当前数字位
        int d=r/b;        // 试商：当前余数能容纳多少个 b
        r%=b;             // 更新余数
        if(!lead||d!=0){  // 跳过前导零：已有非零商或当前位商非零才记录
            q+=d+'0';
            lead=false;
        }
    }
    if(q.empty()) q="0";  // 商为 0 时也要保留一个 "0"
    return {q,(int)r};
}
```

- `r=r*10+(c-'0')` 是"余数左移 + 拼低位"的核心操作，对应公式里的 $r \leftarrow 10r + d_i$；
- `int d=r/b` 得到这一位的商，`r%=b` 得到这一位之后的余数；
- `lead` 标志用来跳过商的前导零：只有当"已经有非零商"或"当前位商非零"时才把 `d` 写入 `q`；
- 循环结束后若 `q` 仍为空，说明商就是 0，需要显式返回 `"0"`，否则会得到空串。

### 主函数

```cpp
int main(){
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    string a;
    int b;
    cin >> a >> b;
    pair<string,int> p = divmod(a, b);
    cout << p.first << '\n';   // 商
    cout << p.second << '\n';  // 余数
    return 0;
}
```

- 读入被除数字符串 `a` 与低精度除数 `b`；
- 调用 `divmod(a, b)` 一次性得到商与余数，用 `pair` 拆开；
- 分别输出商与余数；`ios::sync_with_stdio(false)` 用于加速输入输出。

## 复杂度分析

### 时间复杂度

除以低精度时，只需从最高位到最低位遍历一遍被除数，每位做常数次乘、除、取模运算：

$$T(n) = O(n)$$

其中 $n$ 是被除数的位数。

| 除法类型 | 时间复杂度 | 说明 |
|---------|-----------|------|
| 除以低精度 | $O(n)$ | 每位试商一次 |
| 除以高精度 | $O(n \cdot m)$ | 每位至多减 9 次，每次减法 $O(m)$，$m$ 为除数位数 |

### 空间复杂度

只需要一个存储商的字符串（长度 $O(n)$）和常数个变量：

$$S(n) = O(n)$$

## 适用场景

- **大整数除以普通整数**：如求一个大阶乘、大幂除以某个小整数的商与余数；
- **高精度取模**：很多题目只关心大数对某个小整数的余数，`divmod` 的余数部分即可胜任；
- **进制转换**：把大整数不断除以目标进制并记录余数，就是"除基取余"的进制转换过程；
- **高精度输出的预处理**：配合乘、加实现更复杂的大整数运算。

不适用：当除数本身也是大整数（超过 `int` 范围）时，需要改用"除以高精度"的逐次减法实现。

## 常见陷阱与注意事项

1. **遍历方向与加减乘相反**
   - 加减乘从低位向高位处理，除法必须**从最高位向最低位**处理；
   - 搞反方向会让商从低位开始拼，结果完全错误。

2. **前导零**
   - 商的最高位可能为 0（被除数位数小于除数位数时整个商就是 0），需要用 `lead` 标志或去前导零逻辑处理；
   - 商恰好为 0 时不能返回空串，必须返回 `"0"`。

3. **余数用 `long long`**
   - 每步 `r = r*10 + d_i` 中，虽然 `r < b`，但 `r*10` 可能超过 `int` 上限（$b$ 接近 $10^9$ 时），故 `r` 要用 `long long`；
   - 除数 $b$ 本身应保持在 `int` 可表示范围内，且不能为 0。

4. **除数不能为 0**
   - 除数为 0 时程序会除零崩溃，应在调用前特判或保证数据合法。

5. **除以高精度的细节**
   - 逐次减法实现里，每次减完要处理**借位**，循环方向、前导零都要格外小心；`i++` 与 `i--` 这类方向性笔误极易造成死循环。

## 对比与扩展

| 维度 | 除以低精度 | 除以高精度 |
|------|-----------|-----------|
| 除数范围 | `int` 内 | 任意大整数 |
| 核心操作 | 逐位试商 | 截取 + 逐次减法 |
| 时间复杂度 | $O(n)$ | $O(n \cdot m)$ |
| 实现难度 | 简单 | 较高，易错 |

### 扩展

- **符号处理**：负数的高精度除法可以先对绝对值做 `divmod`，再按"同号得正、异号得负"确定商的符号；余数的符号通常与被除数保持一致；
- **压位高精度**：每个数组元素存多位十进制（如 4 位），减少遍历次数，常数更小；
- **除以高精度**：原理是把每一位商通过"反复减去除数"求出来，配合高精度减法即可实现；
- **与其他高精度运算的关系**：除法与取模常和加法、乘法配合，用于进制转换、大数判整除、高精度 gcd 等场景。$AKB26$, '基础算法', array['高精度', '除法', '取模', '大整数', '字符串'], 'col-basic-high-precision', null, 'knowledge'),
('world-needs-sunday', 'col-basic-high-precision', '高精度算法 — 字符串大整数的比较、加、减、乘', $AKB27$## 算法原理

### 什么是高精度

C++ 中 `int` 最多存约 20 亿（$2^{31}-1$），`long long` 最多存约 $9 \times 10^{18}$。当题目中的数字超过这些范围时，就需要用**高精度**算法来处理。

高精度的核心思想是：**用数组或字符串来存储大整数的每一位，然后模拟人工列竖式的方式进行运算。**

### 存储方式

使用字符串存储大整数，高位在前，低位在后。例如 `"12345"` 表示数字 12345，`s[0] = '1'` 是万位，`s[4] = '5'` 是个位。

运算时需要将字符串反转存入整型数组，让下标 0 对应个位，方便从低位往高位处理进位：

```
字符串 "12345"
  → 数组 A[0]=5, A[1]=4, A[2]=3, A[3]=2, A[4]=1
  （下标表示位数：0=个位，1=十位，2=百位，...）
```

### 全局数组说明

| 数组 | 用途 |
|------|------|
| `A[nmax]` | 存储第一个数的各位数字（低位在前） |
| `B[nmax]` | 存储第二个数的各位数字（低位在前） |
| `tmp[nmax]` | 存储运算结果（低位在前） |

> 使用全局数组可以避免每次函数调用都重新分配空间，配合 `memset` 清零即可复用。

---

## 一、高精度比较

### 核心思想

比较两个正整数的大小，遵循两条规则：

1. **位数多的数更大**：位数不同时，直接比较长度
2. **位数相同时从高位到低位逐位比较**：第一位不同的位置就能决定大小

### 算法流程

1. 如果 `a.size() != b.size()`，位数多的数大，直接返回
2. 从左到右（高位到低位）逐位比较
3. 遇到不同的位，数字大的那个数整体就大
4. 全部相同则两数相等

### 返回值约定

| 返回值 | 含义 |
|--------|------|
| 1 | a > b |
| 0 | a == b |
| -1 | a < b |

### 注意事项

- 比较是从左往右（高位到低位），不需要反转字符串
- 如果字符串有前导零，比较前需要先去除，否则位数判断会出错

---

## 二、高精度加法

### 核心思想

模拟人工列竖式加法：从个位开始，对应位相加，满十进一。

### 算法流程

1. 将两个字符串反转存入数组 `A` 和 `B`（低位在前）
2. 从第 0 位（个位）到最高位，逐位相加：`tmp[i] = A[i] + B[i]`
3. 统一处理进位：从低位到高位，`tmp[i+1] += tmp[i] / 10`，`tmp[i] %= 10`
4. 去掉前导零（从结果数组末尾往前找第一个非零位）
5. 反转回字符串（高位在前）返回

### 为什么统一处理进位而不是边加边进？

两种方式都可以：

- **边加边进**：每加完一位就立即处理进位，逻辑更贴近手工计算
- **统一进位**：先把所有位加完，再统一从低位往高位进位，代码更简洁

两种方式结果完全一致，时间复杂度也相同。统一进位的写法更简洁，因为不需要在循环里同时处理加法和进位。

### 边界处理

- 如果其中一个数是 `"0"`，直接返回另一个数
- 结果最多有 `max(na, nb) + 1` 位（最高位可能进位）
- 结果为 0 时要保证输出是 `"0"` 而不是空字符串

---

## 三、高精度减法

### 核心思想

模拟人工列竖式减法：从个位开始，对应位相减，不够减就向高位借 1 当 10。

### 前提条件

本实现只处理 **a >= b** 的情况，结果为非负数。如果 a < b，需要交换两数并在结果前加负号（本代码返回 `"undef"` 标记）。

### 算法流程

1. 先比较大小，确保 a >= b
2. 将两个字符串反转存入数组 `A` 和 `B`（低位在前）
3. 从第 0 位（个位）开始逐位相减：
   - 如果 `A[i] >= B[i]`，直接相减：`tmp[i] = A[i] - B[i]`
   - 如果 `A[i] < B[i]`，需要借位：`A[i] += 10`，`A[i+1] -= 1`，然后相减
4. 去掉前导零
5. 反转回字符串返回

### 借位的理解

借位操作：

```
A[i] += 10;    // 向高位借 1，本位加 10
A[i+1] -= 1;   // 高位减 1
```

这等价于手工计算中的"借 1 当 10"。注意借位是修改 `A` 数组，会影响高位的计算。

### 边界处理

- 如果 a == b，直接返回 `"0"`
- 如果 a < b，返回 `"undef"`（调用方需要自行处理负数）
- 结果最多有 `max(na, nb)` 位（减法不会增加位数）
- 结果为 0 时要保证输出是 `"0"`

---

## 四、高精度乘法

### 核心思想

模拟人工列竖式乘法：用第二个数的每一位去乘第一个数的每一位，结果累加到对应位置，最后统一处理进位。

### 关键性质

- n 位数 × m 位数的结果最多有 **n + m 位**
- 第 i 位 × 第 j 位的结果，应该加到结果的第 **i + j** 位上（因为个位×个位=个位，十位×个位=十位，以此类推）

$$
\text{第 } i \text{ 位} \times \text{第 } j \text{ 位} \rightarrow \text{结果第 } i+j \text{ 位}
$$

### 算法流程

1. 如果其中一个数是 `"0"`，直接返回 `"0"`
2. 将两个字符串反转存入数组 `A` 和 `B`（低位在前）
3. 双重循环逐位相乘：`tmp[i + j] += A[i] * B[j]`
4. 统一处理进位：从低位到高位，`tmp[i+1] += tmp[i] / 10`，`tmp[i] %= 10`
5. 去掉前导零
6. 反转回字符串返回

### 为什么可以先乘完再统一进位？

因为乘法的每一位结果可能是 0~81（9×9），即使累加多次，只要不超过 `int` 的范围就不会出错。最后统一进位时，从低位往高位走，每一位的进位都被正确地加到高位上。

> 注意：如果位数非常多（比如几万位），中间结果可能溢出 int，这时需要用 long long 或边乘边进。对于 200 位以内的乘法，int 完全够用。

### 边界处理

- 乘数为 0 时直接返回 0（否则会得到一串 0）
- 结果最多有 `na + nb` 位
- 结果为 0 时要保证输出是 `"0"`

---

## 四种运算对比

| 运算 | 时间复杂度 | 结果最多位数 | 方向 | 特殊处理 |
|------|------------|--------------|------|----------|
| 比较 | $O(n)$ | - | 高位→低位 | 先比位数 |
| 加法 | $O(n+m)$ | $\max(n,m)+1$ | 低位→高位 | 进位 |
| 减法 | $O(n+m)$ | $\max(n,m)$ | 低位→高位 | 借位、负数判断 |
| 乘法 | $O(n \cdot m)$ | $n+m$ | 低位→高位 | 进位、0 特判 |

---

## 逐行代码解析

### 高精度比较

```cpp
int cmp(const string& a, const string& b)
{
    // 位数不同：位数多的数大
    if (a.size() != b.size()) return a.size() > b.size() ? 1 : -1;
    // 位数相同：从高位到低位逐位比较
    for (int i = 0; i < a.size(); i++)
    {
        if (a[i] == b[i]) continue;
        return a[i] > b[i] ? 1 : -1;
    }
    return 0;  // 全部相等
}
```

### 高精度加法

```cpp
string add(const string& a, const string& b)
{
    if (a == "0") return string(b);   // 特判：加 0 等于本身
    else if (b == "0") return string(a);

    int na = a.size();
    int nb = b.size();
    memset(A, 0, max(na, nb) * sizeof(int));  // 清零
    memset(B, 0, max(na, nb) * sizeof(int));
    memset(tmp, 0, (max(na, nb) + 2) * sizeof(int));

    // 字符串 → 数组（反转，低位在前）
    for (int i = na - 1; i >= 0; i--) A[na - 1 - i] = a[i] - '0';
    for (int i = nb - 1; i >= 0; i--) B[nb - 1 - i] = b[i] - '0';

    // 逐位相加
    for (int i = 0; i < max(na, nb); i++) tmp[i] = A[i] + B[i];

    // 统一进位
    for (int i = 0; i < max(na, nb); i++)
    {
        tmp[i + 1] += tmp[i] / 10;
        tmp[i] %= 10;
    }

    // 去掉前导零（从后往前找第一个非零位）
    int idx = max(na, nb) + 1;
    while (idx > 0 && !tmp[idx]) idx--;

    // 数组 → 字符串（反转回高位在前）
    string s = "";
    s.reserve(idx + 1);
    for (int i = idx; i >= 0; i--) s += to_string(tmp[i]);
    return s;
}
```

### 高精度减法

```cpp
string sub(const string& a, const string& b)
{
    int c = cmp(a, b);
    if (c == 0) return "0";      // 相等，差为 0
    if (c < 0) return "undef";   // a < b，本函数不处理负数

    int na = a.size();
    int nb = b.size();
    memset(A, 0, max(na, nb) * sizeof(int));
    memset(B, 0, max(na, nb) * sizeof(int));
    memset(tmp, 0, (max(na, nb) + 1) * sizeof(int));

    // 字符串 → 数组（反转，低位在前）
    for (int i = na - 1; i >= 0; i--) A[na - 1 - i] = a[i] - '0';
    for (int i = nb - 1; i >= 0; i--) B[nb - 1 - i] = b[i] - '0';

    // 逐位相减，不够减就借位
    for (int i = 0; i < max(na, nb); i++)
    {
        if (A[i] < B[i])
        {
            A[i] += 10;    // 借 1 当 10
            A[i + 1] -= 1; // 高位减 1
        }
        tmp[i] = A[i] - B[i];
    }

    // 去掉前导零
    int idx = max(na, nb);
    while (idx > 0 && !tmp[idx]) idx--;

    // 数组 → 字符串
    string s = "";
    s.reserve(idx + 1);
    for (int i = idx; i >= 0; i--) s += to_string(tmp[i]);
    return s;
}
```

### 高精度乘法

```cpp
string mull(const string& a, const string& b)
{
    if (a == "0" || b == "0") return "0";  // 特判：乘 0 等于 0

    int na = a.size();
    int nb = b.size();
    memset(A, 0, na * sizeof(int));
    memset(B, 0, nb * sizeof(int));
    memset(tmp, 0, (na + nb + 2) * sizeof(int));

    // 字符串 → 数组（反转，低位在前）
    for (int i = na - 1; i >= 0; i--) A[na - 1 - i] = a[i] - '0';
    for (int i = nb - 1; i >= 0; i--) B[nb - 1 - i] = b[i] - '0';

    // 逐位相乘，结果累加到 i+j 位
    for (int i = 0; i < na; i++)
    {
        for (int j = 0; j < nb; j++)
        {
            tmp[i + j] += A[i] * B[j];
        }
    }

    // 统一进位
    for (int i = 0; i < na + nb; i++)
    {
        tmp[i + 1] += tmp[i] / 10;
        tmp[i] %= 10;
    }

    // 去掉前导零
    int idx = na + nb + 1;
    while (idx > 0 && !tmp[idx]) idx--;

    // 数组 → 字符串
    string s = "";
    s.reserve(idx + 1);
    for (int i = idx; i >= 0; i--) s += to_string(tmp[i]);
    return s;
}
```

---

## 复杂度分析

### 时间复杂度

| 运算 | 复杂度 | 说明 |
|------|--------|------|
| 比较 | $O(n)$ | 最多比较 n 位 |
| 加法 | $O(n + m)$ | 每位处理一次 |
| 减法 | $O(n + m)$ | 每位处理一次 |
| 乘法 | $O(n \cdot m)$ | 双重循环，n 位 × m 位 |

### 空间复杂度

$O(n + m)$，用于存储三个数组 `A`、`B`、`tmp`。

> 本实现使用固定大小的全局数组 `nmax = 200`，最多支持 200 位以内的大整数运算。如果需要更大位数，可以增大 `nmax` 或改用 `vector<int>` 动态分配。

---

## 适用场景

1. **大整数运算**：数字超过 `long long` 范围的加减乘
2. **阶乘、幂运算**：结果很大的数学题
3. **斐波那契数列**：第几十项就会超过 long long
4. **组合数计算**：大数阶乘和组合数
5. **高精度求余、高精度除法**：在本实现基础上扩展

---

## 常见陷阱与注意事项

### 1. 前导零处理

运算结果的高位可能有多余的零，需要去掉。但要注意：如果结果就是 0，不能把所有零都去掉，必须保留一个 `"0"`。

```cpp
while (idx > 0 && !tmp[idx]) idx--;  // idx > 0 保证最后至少留一位
```

### 2. 字符串和数组的方向

- 字符串：高位在前（左高右低）
- 运算数组：低位在前（下标 0 是个位）

两者方向相反，输入时要反转，输出时还要反转回来。搞反方向是高精度最常见的 bug。

### 3. 乘法的位数位置

第 i 位 × 第 j 位 → 结果加到第 i+j 位。不是 `i+j+1`，也不是 `i+j-1`，就是 `i+j`。

可以这样验证：个位 × 个位 = 个位（0 × 0 = 0），个位 × 十位 = 十位（0 × 1 = 1）。

### 4. memset 清零

每次运算前都要用 `memset` 把数组清零，因为全局数组会保留上一次运算的结果。忘记清零会导致结果错误。

### 5. 乘法溢出

普通 int 版高精度乘法，位数不能太多。200 位 × 200 位时，中间某一位最多累加 $200 \times 9 \times 9 = 16200$，远小于 int 上限，没问题。但如果是几万位的乘法，中间结果可能溢出 int，需要改用 long long 或边乘边进位。

### 6. 减法的负数问题

本实现的减法只处理 a >= b 的情况。如果 a < b，需要：
1. 交换 a 和 b
2. 计算 b - a
3. 在结果前面加负号

### 7. 0 的特判

- 加法：加 0 等于本身，可以直接返回
- 乘法：乘 0 等于 0，必须特判。否则如果不特判，结果数组全是 0，去前导零后也能得到 `"0"`，但会浪费时间。

### 8. 数组大小要足够

- 加法：结果最多 `max(n, m) + 1` 位
- 乘法：结果最多 `n + m` 位

数组开小了会越界。本实现中 `tmp` 数组留了 `+2` 的余量，比较安全。

### 9. 输入字符串的前导零

如果输入的字符串有前导零（比如 `"00123"`），位数判断会出错。比较和运算前最好先去除前导零。本实现假设输入没有前导零。

---

## 扩展方向

1. **高精度除法**：用减法模拟除法，或用二分 + 乘法
2. **高精度取模**：从高位到低位逐位取模
3. **压位高精度**：每个数组元素存多位（如 9 位），减少运算次数
4. **FFT 优化乘法**：用快速傅里叶变换将乘法优化到 $O(n \log n)$
5. **负数高精度**：处理正负号，统一用绝对值运算
6. **小数高精度**：处理小数点位置，本质和整数高精度一样$AKB27$, '基础算法', array['高精度', '大整数', '字符串', '模拟', '进位', '借位'], null, null, 'knowledge'),
('stripe-python', 'col-basic-interactive-models--stripe-python', '交互与通信题经典模型（猜数 / 毒药 / Hamming） · stripe-python', $AKB28$> 本文由 stripe-python 授权合并，保留原文结构与表述；原文为《通信交互选做》的"经典模型"部分，具体题目另立题目条目。

[联合编译原理简述](https://www.luogu.com.cn/article/h1vpd8sb)。

感觉本质构造选做。

## 经典模型

### 猜数模型

> 这是一道交互题。
>
> 交互库隐藏了一个数字 $x$。你可以向交互库猜测一个数字 $y$，交互库会回答 $x$ 与 $y$ 的大小关系。
>
> 还原 $x$。

:::::success[做法]
考虑二分 $x$，每次根据交互库的询问缩减范围即可。询问次数 $\log V$。

根据评分方式和实际情况的不同，有时也会选择倍增 / 三分 / 优选法等做法。
:::::

### 毒药模型

> 这是一道交互题。
>
> 现有 $n$ 杯水，其中恰有一杯有毒。你可以给出一个集合 $S$，交互库回答将 $S$ 中的水混合后是否有毒。
>
> 求出有毒的水的编号。

:::::success[做法]
考虑二进制分组，每个 $S$ 询问二进制下该位为 $1$ 的所有水，这样就能得到答案的一个二进制位。询问次数 $\log n$。

根据评分方式和实际情况的不同，有时也会选择三进制分组等编码方式。
:::::

### Hamming 码

> 这是一道通信题。
>
> - A：已知 $n$ 个 bit，需要传输若干 bit。
> - B：还原原本的 $n$ 个 bit。
>
> 通信过程中交互库会修改至多 $1$ 个 bit。

:::::success[题解]
考虑毒药模型。

传输 $\log n$ 个纠错码，并且将纠错码的位置放在 $2$ 的幂，原数据放在非 $2$ 的幂。计算出所有 $1$ 的下标异或和，然后将第 $2^i$ 个 bit 设置为异或和二进制下第 $i$ 位。

B 收到信息后，计算出所有 $1$ 的下标异或和。若这个值为 $0$ 则无错误，否则异或和的值直接指示了错误出现的位置，将这个 bit 翻转。

如果你认为上面的说法看不懂，推荐 [3b1b 的视频](https://www.bilibili.com/video/BV1WK411N7kz)。
:::::

## 信息论入门

这里是一些非常浅显的理解，主要用于快速入门。

对于随机变量 $X$，记 $p_i$ 为 $X=i$ 的概率，则定义其**信息熵**为

$$
H(x)=-\sum p_i \log_2 p_i
$$

信息熵描述的是存储数据的所用的 bit 数的下界。一些例子：

- 01 随机变量：信息熵为 $1$；
- 在 $[1,n] \cap \mathbb{N}$ 上的随机变量：信息熵为 $\log_2 n$；
- 掷骰子，但掷出 $1 \sim 5$ 的概率为 $10\%$，掷出 $6$ 的概率为 $50\%$：信息熵约为 $2.16$。

对于两个随机变量 $X,Y$，其共同的信息熵为 $H(X,Y)$，则：

- 若 $X,Y$ 独立，则 $H(X,Y)=H(X)+H(Y)$；
- 若 $X,Y$ 完全不独立，则 $H(X,Y)=H(X)=H(Y)$；
- 一般地，记 $p_{i,j}$ 为 $X=i,Y=j$ 的概率，则 $H(X,Y)=\sum p_{i,j} \log_2 p_{i,j}$。

定义互信息 $I(X,Y)=H(X)+H(Y)-H(X,Y)$，用于衡量 $X,Y$ 之间的相关程度。

对于一类交互问题，可以用信息熵对可行决策进行估价，选择最优决策。

## 还原序列 / 序列找点

:::::warning[注意]{open}
一定要看好是序列还是排列！！！

一定要看好是序列还是排列！！！

一定要看好是序列还是排列！！！

同机房大佬在 d2t1 中由于没看到排列，获得 15pts 遗憾翻出队线，默哀。
:::::


## 附：还原序列 / 还原树 / 还原图 / 博弈型 专题导语（《通信交互选做》· stripe-python）

## 还原序列 / 序列找点

:::::warning[注意]{open}
一定要看好是序列还是排列！！！

一定要看好是序列还是排列！！！

一定要看好是序列还是排列！！！

同机房大佬在 d2t1 中由于没看到排列，获得 15pts 遗憾翻出队线，默哀。
:::::

## 还原树 / 树找点

## 还原图 / 图找点

## 博弈型$AKB28$, '基础算法', array['交互题', '通信题', '信息论', 'Hamming 码'], 'col-basic-tricks-overview', null, 'knowledge'),
('world-needs-sunday', 'col-basic-interval-merge', '区间合并（合并重叠/相邻区间）', $AKB29$## 算法原理

区间合并问题：给定 $n$ 个区间 $[l_i, r_i]$，将所有存在重叠或相邻的区间合并，输出互不相交的最终区间集合。

### 贪心策略：按左端点排序 + 单次扫描

**核心思路**：将所有区间按左端点升序排序，然后从左到右扫描，维护一个当前合并区间 $[L, R]$：

1. 若下一个区间的左端点 $\le R$（即与当前区间重叠或相邻），则扩展 $R \leftarrow \max(R, r_i)$
2. 若下一个区间的左端点 $> R$（即不重叠），则当前区间合并完毕，输出 $[L, R]$，开始新的合并

**为什么按左端点排序？** 排序后，所有可能有重叠关系的区间在数组中是连续相邻的。从左到右扫描时，当前合并区间的左端点 $L$ 一定是所有尚未处理的区间中左端点最小的。只需不断向右扩展 $R$ 即可。

### 哨兵技巧

本代码在末尾添加 `(INF, INF)` 作为哨兵区间，确保最后一个合并区间在循环中被输出，避免循环后额外处理。

## 核心公式/状态定义与转移方程

状态定义：

$$L = \text{当前合并区间的左端点}, \quad R = \text{当前合并区间的右端点}$$

初始化：

$$L = +\infty, \quad R = -\infty \quad (\text{哨兵值，确保第一个区间触发新合并})$$

排序规则（按左端点升序）：

$$l_i < l_j \;\Rightarrow\; i \text{ 排在 } j \text{ 前}$$

转移方程（扫描每个区间 $A[i] = [l_i, r_i]$）：

$$\text{若 } l_i \le R \;\Rightarrow\; R \leftarrow \max(R, r_i) \quad (\text{扩展右端点})$$

$$\text{若 } l_i > R \;\Rightarrow\; \text{输出 } [L, R],\; L \leftarrow l_i,\; R \leftarrow r_i \quad (\text{开始新区间})$$

## 逐行代码解析

### 排序 + 哨兵

```cpp
sort(A.begin() + 1, A.end());        // pair 默认按 first（左端点）升序
A.emplace_back(INF, INF);             // 哨兵：确保最后一个合并区间被输出
```

- `pair` 默认按 `.first`（左端点）排序，左端点相同则按 `.second`（右端点）排序。
- 哨兵 `(INF, INF)` 的左端点为 $+\infty$，必定 $> R$，触发最后一个合并区间输出。

### 核心扫描逻辑

```cpp
int L = INF, R = -INF;               // 哨兵初始值
int cnt = 0;
vector<pair<int,int>> ans(n + 1);
for(int i = 1; i <= n + 1; i++) {     // n+1：包含哨兵
    if(A[i].first <= R)               // 左端点 <= R → 重叠或相邻
        R = max(A[i].second, R);      // 扩展右端点
    else {                             // 不重叠 → 当前区间合并完毕
        ans[cnt].first = L;           // 存入结果
        ans[cnt].second = R;
        ++cnt;
        L = A[i].first;               // 开始新区间
        R = A[i].second;
    }
}
```

- `L = INF, R = -INF`：确保第一个区间 `A[1].first <= R` 不成立（因为 $R = -\infty$），从而走 `else` 分支，正确初始化 `[L, R] = A[1]`。
- `ans` 从下标 0 开始存，但输出从 `ans[1]` 开始（`ans[0]` 是哨兵产生的无效区间 `[INF, -INF]`）。
- `cnt - 1` 是实际合并后的区间数（减去哨兵触发的多余一次）。

### 输出逻辑

```cpp
cout << "合并后会 " << cnt - 1 << " 区间" << '\n';
for(int i = 1; i < cnt; i++) {
    cout << "长度为:" << ans[i].second - ans[i].first + 1
         << "  L = " << ans[i].first << "  R = " << ans[i].second << '\n';
}
```

- `cnt - 1`：哨兵触发了最后一次 `else`，多了一个无效区间，所以要减 1。
- 长度公式 `R - L + 1`：假设区间是整数端点且闭区间。

### 输入格式

```
T          ← 测试组数
n          ← 每组区间数
l1 r1      ← 区间1的左右端点
l2 r2
...
ln rn
```

## 复杂度分析

| 维度 | 复杂度 | 说明 |
|---|---|---|
| 排序 | $O(n \log n)$ | 按左端点排序 |
| 扫描 | $O(n)$ | 单次线性遍历 |
| 总时间 | $O(n \log n)$ | 排序占主导 |
| 空间 | $O(n)$ | 存储区间和结果数组 |

## 适用场景

### 适用

- **合并重叠区间**：最直接的用途，如日程表合并、时间段去重
- **区间去重**：多个区间可能完全包含或部分重叠，合并后得到不交集
- **覆盖区域计算**：计算若干区间的总覆盖长度（合并后累加每个区间长度）
- **数据清洗**：日志时间段的合并去重

### 不适用

- **选最多不重叠区间**：那是区间调度问题（按右端点排序）
- **最少区间覆盖**：用最少区间覆盖目标段（不同贪心策略）
- **区间带权合并**：需要更复杂的数据结构

## 常见陷阱与注意事项

1. **排序方向**
   - 必须**按左端点升序**排序。如果按右端点排序会导致合并错误。
   - `pair` 默认按 `.first` 排序，所以直接 `sort` 即可。

2. **"重叠"的定义**
   - 本代码 `A[i].first <= R` 表示左端点 $\le$ 当前右端点即认为重叠（包含相邻）。
   - 如果题目要求严格重叠（相邻不算），改为 `A[i].first < R`。

3. **哨兵的正确使用**
   - `(INF, INF)` 确保最后一个合并区间在循环内被输出。
   - 不加哨兵时，循环结束后需要额外输出最后一个 `[L, R]`。
   - `cnt - 1` 减去哨兵触发的多余一次。

4. **ans[0] 是无效的**
   - 由于哨兵初始化 `L=INF, R=-INF`，第一个区间走 `else` 分支时 `ans[0] = [INF, -INF]`，是无效的。
   - 输出从 `ans[1]` 开始。

5. **区间端点的含义**
   - `R - L + 1` 假设整数闭区间。如果区间是实数或半开半闭，长度公式需调整。

6. **空输入处理**
   - 当 $n = 0$ 时，哨兵仍会触发一次输出。需要特判或确保 $n \ge 1$。

## 对比与扩展

### 区间三兄弟对比

| 问题 | 目标 | 排序依据 | 策略 | 复杂度 |
|---|---|---|---|---|
| 区间调度 | 选最多不重叠区间 | 右端点升序 | 贪心选，更新 `from` | $O(n \log n)$ |
| 区间合并 | 合并重叠/相邻区间 | 左端点升序 | 扫描扩展 `R` | $O(n \log n)$ |
| 区间覆盖 | 最少区间覆盖目标 | 左端点升序 | 贪心延伸覆盖 | $O(n \log n)$ |

### 区间覆盖问题

给定目标区间 $[S, T]$ 和若干线段，选出最少的线段覆盖 $[S, T]$。策略：按左端点排序，每次在能覆盖当前位置的线段中选右端点最远的，逐步推进。与区间合并形似但目标不同。

### 总覆盖长度计算

合并后，每个不重叠区间的长度之和即为总覆盖长度：

$$\text{总覆盖} = \sum_{i=1}^{k} (R_i - L_i + 1)$$

若不合并直接计算会重复计算重叠部分。$AKB29$, '基础算法', array['基础算法', '贪心', '区间合并', '区间问题', '排序', '扫描'], 'col-basic-greedy', null, 'knowledge'),
('world-needs-sunday', 'col-basic-interval-scheduling', '区间调度（选最多不重叠区间）', $AKB30$## 算法原理

区间调度问题是贪心算法的经典应用：给定 $n$ 个区间 $[l_i, r_i]$，选出尽可能多的区间使它们**互不重叠**（注意：端点可以重合，即一个区间的终点等于另一个区间的起点是允许的）。

### 贪心策略：按右端点排序

**核心选择**：每次选择**结束最早**且与已选区间不冲突的区间。

**为什么按右端点排序？** 贪心的关键在于"留下尽可能多的空间给后续区间"。一个区间结束越早，剩余的时间轴越长，后续可选区间就越多。按右端点升序排序后，依次扫描，每遇到一个 `A[i].first >= from`（起点 $\ge$ 上一个选中区间的终点）的区间就选中它，并更新 `from` 为其右端点。

### 正确性证明（交换论证法）

假设最优解 $OPT$ 选了 $k$ 个区间，贪心解 $GREEDY$ 也选了 $k$ 个区间。我们可以证明贪心不会比最优解差：

1. 设贪心选的第 $i$ 个区间为 $g_i$，最优解选的第 $i$ 个为 $o_i$
2. 由于贪心每次选右端点最小的，故 $r_{g_i} \le r_{o_i}$（贪心的结束时间不会晚于最优解的对应区间）
3. 因此贪心留下的剩余空间 $\ge$ 最优解留下的空间
4. 即贪心能选的区间数 $\ge$ 最优解，矛盾

所以贪心解的区间数 = 最优解的区间数。

## 核心公式/状态定义与转移方程

状态定义：

$$\text{from} = \text{当前已选区间中最后一个的右端点}$$

初始化：

$$\text{from} = -\infty, \quad \text{cnt} = 0$$

排序规则（按右端点升序，右端点相同按左端点升序）：

$$r_i < r_j \;\Rightarrow\; i \text{ 排在 } j \text{ 前}$$

转移方程（扫描每个区间 $A[i] = [l_i, r_i]$）：

$$\text{若 } l_i \ge \text{from} \;\Rightarrow\; \text{选中 } A[i],\; \text{from} \leftarrow r_i,\; \text{cnt} \leftarrow \text{cnt} + 1$$

## 逐行代码解析

### 比较函数（自定义仿函数）

```cpp
struct cmp {
    bool operator() (pair<int,int>& a, pair<int,int>& b) {
        if(a.second != b.second) return a.second < b.second;  // 右端点升序
        return a.first < b.first;                              // 右端点相同，左端点升序
    }
};
```

- 优先按右端点排序（核心贪心策略）。
- 右端点相同时，左端点小的排前面（不影响正确性，但使输出更稳定）。

### 主函数核心逻辑

```cpp
sort(A.begin() + 1, A.end(), cmp());              // 按右端点排序
int from = -0x3f3f3f3f, cnt = 0;                  // from 初始化为极小值
for(int i = 1; i <= n; i++) {
    if(A[i].first >= from) {                       // 起点不早于上次终点 → 不重叠
        from = A[i].second;                        // 更新为当前区间的右端点
        ++cnt;                                      // 选中计数
    }
}
cout << cnt << '\n';
```

- `from` 跟踪最后一个选中区间的右端点。
- `A[i].first >= from`：当前区间起点 $\ge$ 上次选中区间终点，端点可以重合（"$\ge$" 而非 "$>$"）。
- 选中后立即更新 `from`，后续区间必须与这个新区间不重叠。

### 输入格式

```
T          ← 测试组数
n          ← 每组区间数
l1 r1      ← 区间1的左右端点
l2 r2
...
ln rn
```

## 复杂度分析

| 维度 | 复杂度 | 说明 |
|---|---|---|
| 排序 | $O(n \log n)$ | 按右端点排序 |
| 扫描 | $O(n)$ | 单次线性遍历 |
| 总时间 | $O(n \log n)$ | 排序占主导 |
| 空间 | $O(n)$ | 存储区间数组 |

## 适用场景

### 适用

- **选最多不重叠区间**：经典区间调度问题
- **活动安排问题**：给定若干活动的时间段，选最多能参加的活动
- **教室/会议室调度**：有限的资源上安排最多任务
- **任务调度（无优先级）**：每个任务有固定时间段，最大化完成任务数

### 不适用

- **需要最大覆盖长度**：不是选最多区间，而是覆盖最长总长度（需要不同策略）
- **带权区间调度**：每个区间有权值，求最大权和（需要 DP 而非贪心）
- **区间有依赖关系**：选 A 必须先选 B（需要图论建模）

## 常见陷阱与注意事项

1. **端点可以重合**
   - 题目说"起点可以相交"，即 `A[i].first >= from` 用 $\ge$ 而非 $>$。
   - 如果题目要求严格不重叠（端点也不能重合），改为 `>`。

2. **排序规则的方向**
   - 必须**按右端点升序**。按左端点排序是错误的，反例：`[1,100], [2,3], [4,5]`，按左端点排序会先选 `[1,100]`，只能选 1 个；按右端点排序会选 `[2,3], [4,5]`，共 2 个。

3. **from 的初始值**
   - 初始化为极小值 `-0x3f3f3f3f`，确保第一个区间一定能被选中。
   - 不能用 0 初始化（区间端点可能为负数）。

4. **右端点相同时的排序**
   - 右端点相同不影响正确性（选哪个都行），但左端点升序可以选到"更短"的区间，在需要还原路径时更直观。

## 对比与扩展

### 区间调度 vs 区间合并 vs 区间覆盖

| 问题 | 目标 | 策略 | 复杂度 |
|---|---|---|---|
| 区间调度 | 选最多不重叠区间 | 按右端点排序，贪心选 | $O(n \log n)$ |
| 区间合并 | 合并所有重叠/相邻区间 | 按左端点排序，扫描合并 | $O(n \log n)$ |
| 区间覆盖 | 用最少区间覆盖目标段 | 按左端点排序，贪心延伸 | $O(n \log n)$ |

### 带权区间调度

如果每个区间有权值 $w_i$，要求选不重叠区间使权值和最大，贪心失效，需要 DP：

$$dp[i] = \max(dp[i-1],\; dp[p[i]] + w_i)$$

其中 $p[i]$ 是右端点 $< l_i$ 的最后一个区间（二分查找）。复杂度 $O(n \log n)$。

### 多机调度

如果有 $k$ 台机器（不是 1 台），选最多不重叠区间变为**区间图着色问题**：最少需要多少台机器才能安排所有区间？答案是最大冲突数，用优先队列（小根堆维护当前正在进行的活动的结束时间）即可求解。$AKB30$, '基础算法', array['基础算法', '贪心', '区间调度', '区间问题', '排序', '不重叠区间'], 'col-basic-greedy', null, 'knowledge'),
('world-needs-sunday', 'col-basic-meet-in-middle-binary-search', '折半搜索（Meet in the Middle）— 二分查找版', $AKB31$## 折半搜索（Meet in the Middle）— 二分查找版

## 一、算法原理

### 1.1 问题背景

**子集和计数问题**：给定 $n$ 个正整数 $a_1, a_2, \dots, a_n$ 和一个上限 $m$，求有多少个子集的元素之和不超过 $m$。

暴力做法：DFS 枚举所有 $2^n$ 个子集，判断每个子集的和是否 $\le m$。时间复杂度 $O(2^n)$。

当 $n=40$ 时，$2^{40} \approx 10^{12}$，暴力完全不可能。

### 1.2 折半搜索的核心思想

**"分而治之"地枚举**：将 $n$ 个元素分成**前后两半**，每半约 $n/2$ 个元素。

- 前半部分（约 $n/2$ 个元素）：枚举所有 $2^{n/2}$ 个子集的和，存入数组
- 后半部分（约 $n/2$ 个元素）：枚举所有 $2^{n/2}$ 个子集的和，与前半部分配对

这样每半的搜索量从 $2^n$ 降到 $2^{n/2}$，剩下的问题是**如何高效合并两部分的结果**。

### 1.3 二分查找合并法

合并思路：
1. 把前半部分的所有子集和存入数组 `tmp`，然后排序
2. 枚举后半部分的每个子集和 $s$，在前半部分中找有多少个数 $\le m - s$
3. 因为 `tmp` 已排序，每次查询用 `upper_bound` 二分查找，$O(\log 2^{n/2}) = O(n)$

总时间复杂度：
- 枚举：$O(2^{n/2} + 2^{n/2}) = O(2^{n/2})$
- 排序前半部分：$O(2^{n/2} \log 2^{n/2}) = O(n \cdot 2^{n/2})$
- 后半部分枚举 + 二分：$O(2^{n/2} \times n)$
- 总计：$O(n \cdot 2^{n/2})$

当 $n=40$ 时，$40 \times 2^{20} \approx 4 \times 10^7$，完全可以在 1 秒内跑完 ✓

### 1.4 算法流程示意

```
n 个元素，分成两半（前 n/2 个 + 后 n/2 个）
        │
        ├─ 前半部分 DFS ─→ 所有子集和 → 存入 tmp 数组 → 排序
        │                                    │
        └─ 后半部分 DFS ─→ 每个子集和 s ────┤
                                            │
                                     upper_bound(tmp, m-s)
                                            │
                                     累加计数 → 答案
```

### 1.5 关键变量

| 变量 | 类型 | 作用 |
|------|------|------|
| `A[k]` | `vector<long long>` | 存储输入的第 $k$ 个元素（下标从1开始） |
| `tmp` | `vector<long long>` | 存储前半部分所有子集和 |
| `cnt` | `long long` | 最终答案（满足条件的子集总数） |
| `tmp_sz` | `int` | 前半部分的元素个数 = n/2 |

## 二、核心公式/状态定义与转移方程

### 2.1 折半搜索复杂度公式

将 $n$ 个元素分成两半，每半约 $n/2$ 个：

$$T(n) = O(2^{n/2}) + O(2^{n/2} \cdot \frac{n}{2}) + O(2^{n/2} \cdot \frac{n}{2}) = O(n \cdot 2^{n/2})$$

对比纯暴力 $O(2^n)$，当 $n=40$ 时：
- 暴力：$2^{40} \approx 10^{12}$（不可行）
- 折半搜索：$40 \times 2^{20} \approx 4 \times 10^7$（轻松通过）

**效率提升**：约 $2^{n/2} / n$ 倍，$n$ 越大优势越明显。

### 2.2 DFS 状态定义

**`dfs1(k, n, sum, m)`**：枚举前半部分（第 1 到 n 个元素），从第 $k$ 个元素开始，当前已选和为 $sum$，上限为 $m$。

终止条件：`k > n` → 当前子集和为 `sum`，加入 `tmp` 数组。

**决策（每个元素选/不选）**：
1. **不选**第 $k$ 个元素：`dfs1(k + 1, n, sum, m)`
2. **选**第 $k$ 个元素（如果不超过 m）：`dfs1(k + 1, n, sum + A[k], m)`

> 注意：这里的"选/不选"模型和组合 DFS 完全一样，只是不需要记录选中了哪些元素，只需要记录和。

### 2.3 二分查找计数

前半部分子集和排序后，对于后半部分的每个子集和 $s$，满足条件的前半部分子集和数量为：

$$\text{count} = \text{upper\_bound}(tmp, m - s) - tmp.begin()$$

`upper_bound` 返回第一个大于 $m-s$ 的元素位置，该位置的下标就是 $\le m-s$ 的元素个数。

### 2.4 剪枝条件

```cpp
if (sum + A[k] <= m) dfs1(k + 1, n, sum + A[k], m);
```

如果选了第 $k$ 个元素后和已经超过 $m$，就不继续递归了。这是子集和问题中的基本剪枝，虽然在最坏情况下（所有元素都很小）没有帮助，但在元素较大时能剪掉不少分支。

## 三、逐行代码解析

### 3.1 全局变量

```cpp
vector<long long>A, tmp;
long long cnt;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `vector<long long>A, tmp;` | A：输入数组；tmp：前半部分所有子集和 |
| 2 | `long long cnt;` | 答案计数器 |

> 为什么用 `long long`？当 $n=40$ 时，子集总数为 $2^{40} \approx 10^{12}$，超过 `int` 范围（约 $2 \times 10^9$），必须用 `long long`。

### 3.2 dfs1 —— 枚举前半部分子集和

```cpp
void dfs1(int k, int n, long long sum, long long m)
{
    if (k > n)
    {
        tmp.emplace_back(sum);
        return;
    }
    dfs1(k + 1, n, sum, m);
    if (sum + A[k] <= m) dfs1(k + 1, n, sum + A[k], m);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `void dfs1(int k, int n, long long sum, long long m)` | $k$=当前考虑第几个元素，$n$=考虑到第几个为止，$sum$=当前和，$m$=上限 |
| 3-6 | `if (k > n) { tmp.emplace_back(sum); return; }` | 终止：所有元素考虑完，把当前和加入 tmp |
| 8 | `dfs1(k + 1, n, sum, m);` | **不选**第 k 个元素，直接考虑下一个 |
| 9 | `if (sum + A[k] <= m)` | 剪枝：选了之后不超过 m 才继续 |
| 9 | `dfs1(k + 1, n, sum + A[k], m);` | **选**第 k 个元素，加上 A[k] 继续 |

> **注意顺序**：先"不选"再"选"。顺序不影响结果（所有子集都会被枚举到），但影响 tmp 中元素的顺序。

### 3.3 find —— 二分查找

```cpp
int find(long long i)
{
    return upper_bound(tmp.begin(), tmp.end(), i) - tmp.begin();
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1-3 | `int find(long long i)` | 查找 tmp 中 ≤ i 的元素个数 |
| 2 | `upper_bound(tmp.begin(), tmp.end(), i)` | 返回第一个 > i 的迭代器 |
| 2 | `- tmp.begin()` | 迭代器相减得到下标，即 ≤ i 的元素个数 |

> `upper_bound` 要求数组**有序**，所以在调用前必须先 sort。

### 3.4 dfs2 —— 枚举后半部分并计数

```cpp
void dfs2(int k, int n, long long sum, long long m)
{
    if (k > n)
    {
        cnt += find(m - sum);
        return;
    }
    dfs2(k + 1, n, sum, m);
    if (sum + A[k] <= m) dfs2(k + 1, n, sum + A[k], m);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 3-6 | `if (k > n) { cnt += find(m - sum); return; }` | 终止：当前和为 sum，在前半部分中找有多少个 ≤ m-sum 的，加到答案 |
| 8 | `dfs2(k + 1, n, sum, m);` | 不选第 k 个元素 |
| 9 | `if (sum + A[k] <= m)` | 剪枝 |
| 9 | `dfs2(k + 1, n, sum + A[k], m);` | 选第 k 个元素 |

`dfs2` 和 `dfs1` 的结构几乎完全一样，唯一区别是终止时的动作：
- `dfs1`：把 sum 存入 tmp
- `dfs2`：用 sum 去 tmp 中查询，累加到 cnt

### 3.5 fn —— 主逻辑

```cpp
long long fn(int n, long long m)
{
    tmp.clear();
    cnt = 0;
    int tmp_sz = n / 2;
    tmp.reserve((long long)1 << tmp_sz);
    dfs1(1, tmp_sz, 0, m);
    sort(tmp.begin(), tmp.end());
    dfs2(tmp_sz + 1, n, 0, m);
    return cnt;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 3-4 | `tmp.clear(); cnt = 0;` | 初始化，清空上次数据 |
| 5 | `int tmp_sz = n / 2;` | 前半部分元素个数（向下取整） |
| 6 | `tmp.reserve(1 << tmp_sz);` | 预分配空间，避免 vector 多次扩容，提升效率 |
| 7 | `dfs1(1, tmp_sz, 0, m);` | 枚举前半部分（第1到第tmp_sz个） |
| 8 | `sort(tmp.begin(), tmp.end());` | 排序，为二分查找做准备 |
| 9 | `dfs2(tmp_sz + 1, n, 0, m);` | 枚举后半部分（第tmp_sz+1到第n个），同时计数 |
| 10 | `return cnt;` | 返回答案 |

> **对半分的选择**：这里前半部分取 n/2 个（向下取整），后半部分取 n-n/2 个。两半各约一半，总复杂度最优。如果分得不均衡（比如 1/3 和 2/3），复杂度会由较大的那一半决定，效率会下降。

### 3.6 main 函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    long long m;
    cin >> n >> m;
    A.assign(n + 1, 0);
    for (int i = 1; i <= n; i++) cin >> A[i];
    cout << fn(n, m);
    return 0;
}
```

快速 IO + 读入数据 + 调用 fn 输出答案，标准模板。

### 3.7 执行示例（n=4, m=5, A=[2,3,1,4]）

前半部分（前2个元素：2, 3）的子集和：
```
不选2不选3 → 0
选2不选3 → 2
不选2选3 → 3
选2选3 → 5
```
tmp = [0, 2, 3, 5] → 排序后：[0, 2, 3, 5]

后半部分（后2个元素：1, 4）的子集和：
- sum=0：找 ≤ 5 的 → 4个（全部）→ cnt += 4
- sum=1：找 ≤ 4 的 → 3个（0,2,3）→ cnt += 3 → cnt=7
- sum=4：找 ≤ 1 的 → 1个（0）→ cnt += 1 → cnt=8
- sum=5：找 ≤ 0 的 → 1个（0）→ cnt += 1 → cnt=9

答案：9 个子集满足和 ≤ 5 ✓

## 四、复杂度分析

### 4.1 时间复杂度

$$O(n \cdot 2^{n/2})$$

**详细分解**：

| 步骤 | 复杂度 | 说明 |
|------|--------|------|
| 前半部分 DFS | $O(2^{n/2})$ | 枚举 2^(n/2) 个子集 |
| 排序前半部分 | $O(2^{n/2} \cdot n/2)$ | 2^(n/2) 个元素排序 = O(k log k)，其中 k=2^(n/2) |
| 后半部分 DFS + 二分 | $O(2^{n/2} \cdot n/2)$ | 每个子集一次二分，单次 O(n/2) |
| **总计** | $O(n \cdot 2^{n/2})$ | 排序和二分查询是瓶颈 |

### 4.2 空间复杂度

$$O(2^{n/2})$$

主要是 tmp 数组存储前半部分的所有子集和，共 $2^{n/2}$ 个元素。递归栈深度为 $O(n)$，可以忽略。

### 4.3 不同 n 的规模参考

| n | 2^n（暴力） | n·2^(n/2)（折半搜索） | 可行性 |
|---|-------------|----------------------|--------|
| 20 | 1,048,576 | ~10万 | 都轻松 |
| 30 | ~10亿 | ~500万 | 暴力超时，折半轻松 |
| 40 | ~1万亿 | ~4000万 | 暴力不可能，折半 1-2 秒 |
| 50 | ~1千万亿 | ~6亿 | 折半也有点紧 |

折半搜索通常用于 $n \approx 30 \sim 45$ 的子集类问题。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **子集和计数** | 经典应用：求有多少个子集的和 ≤ m 或 = m |
| **最大子集和（不超过m）** | 二分查找改为找最大的 ≤ m-s 的值 |
| **n≈40 的子集类问题** | 纯暴力 2^40 完全不行，折半搜索是标配解法 |
| **两部分组合的问题** | 任何可以拆成"两半独立搜索 + 合并答案"的问题 |
| **背包类问题（物品数少但价值大）** | 当 n≤40 且容量很大（无法DP）时，折半搜索是替代方案 |

## 六、常见陷阱与注意事项

### 6.1 数据类型溢出

**最常见错误**：用 `int` 存答案或子集和。

- $n=40$ 时有 $2^{40} \approx 10^{12}$ 个子集，远超 `int` 范围
- 每个元素如果很大，子集和也会爆 `int`

**正确做法**：`cnt`、`sum`、`tmp` 数组都用 `long long`。

### 6.2 reserve 预分配

```cpp
tmp.reserve((long long)1 << tmp_sz);
```

不要省略这行。$2^{20}$ 约 100 万，vector 自动扩容会有多次内存拷贝，预分配可以显著提速。

> 注意 `1 << tmp_sz` 中 1 是 int，如果 tmp_sz >= 31 会溢出。需要强转：`(long long)1 << tmp_sz`。本代码中 tmp_sz = n/2，n 最多 40 左右，tmp_sz 约 20，不会溢出，但加上强转更安全。

### 6.3 空集也算一个子集

代码中 `sum=0`（什么都不选）也会被计入。如果题目要求"非空子集"，答案要减 1。

### 6.4 两半要尽量均衡

如果前半部分 k 个，后半部分 n-k 个，总复杂度为 $O(n \cdot 2^{\max(k, n-k)})$。

- 均衡分（k = n/2）：$\max = n/2$，最优
- 不均衡（k = n/4）：$\max = 3n/4$，复杂度 $O(n \cdot 2^{3n/4})$，差很多

**一定要对半分**，差 1 个没关系，但不能差太多。

### 6.5 upper_bound vs lower_bound

- `upper_bound(x)`：第一个 > x 的位置 → **≤ x 的个数**
- `lower_bound(x)`：第一个 ≥ x 的位置 → **< x 的个数**

如果题目是"和小于 m"（严格小于），用 `lower_bound(m - sum)`。
如果题目是"和小于等于 m"，用 `upper_bound(m - sum)`。

本代码是"不超过 m"（≤ m），所以用 `upper_bound`，正确。

### 6.6 剪枝的效果

`if (sum + A[k] <= m)` 这个剪枝在元素较大时很有用，但在元素都很小时几乎没效果（所有子集和都不超过 m）。

**优化技巧**：如果元素顺序随意，可以把大的元素放前面，这样剪枝更早生效，搜索树更小。

### 6.7 为什么 dfs1 和 dfs2 分开写

代码中 dfs1 和 dfs2 结构几乎一样，只是终止动作不同。能不能合并成一个函数？

可以，比如传一个引用参数表示是"存储"还是"查询"。但分开写更清晰，且没有性能损失（编译器会内联）。竞赛中通常分开写，不容易出错。

### 6.8 排序哪一半

代码中排序前半部分，枚举后半部分时二分。能不能反过来？

可以，效果一样。通常排序较小的那一半（如果两半不一样大），排序时间更短。但因为两半差不多大，所以无所谓。

## 七、对比与扩展

### 7.1 暴力枚举 vs 折半搜索

| 维度 | 暴力 DFS | 折半搜索 |
|------|----------|----------|
| 时间复杂度 | $O(2^n)$ | $O(n \cdot 2^{n/2})$ |
| n=30 | ~10亿（超时） | ~500万（轻松） |
| n=40 | ~1万亿（不可能） | ~4000万（1-2秒） |
| 空间 | $O(n)$ 递归栈 | $O(2^{n/2})$ 存子集和 |
| 代码量 | 十几行 | 三十几行 |
| 适用 n | n ≤ 20 | n ≤ 45 |

### 7.2 二分查找版 vs 双指针版

| 维度 | 二分查找版 | 双指针版 |
|------|-----------|----------|
| 合并方式 | 枚举一半，另一半二分 | 两个排序数组，双指针 |
| 时间 | $O(n \cdot 2^{n/2})$ | $O(2^{n/2})$ |
| 排序次数 | 排序一半 | 排序两半 |
| 代码结构 | 两个 dfs 函数结构不同 | 同一个 dfs 函数，对称 |
| 适用场景 | 通用，查询灵活 | 计数类问题更快 |
| 易写程度 | 稍简单（一个 dfs 存，一个查） | 稍简洁（共用 dfs） |

详细对比见「折半搜索（双指针版）」知识点。

### 7.3 扩展：求子集和等于 k 的方案数

把 `upper_bound(m - sum)` 改成：
```cpp
cnt += upper_bound(tmp.begin(), tmp.end(), k - sum) 
     - lower_bound(tmp.begin(), tmp.end(), k - sum);
```
即等于 k-sum 的元素个数。

### 7.4 扩展：最大子集和（不超过 m）

把 cnt 改成记录最大值：
```cpp
// dfs2 终止时
auto it = upper_bound(tmp.begin(), tmp.end(), m - sum);
if (it != tmp.begin()) {
    --it;
    ans = max(ans, sum + *it);
}
```

### 7.5 扩展：子集和方案数（带权/多维）

如果每个元素有多个属性（比如重量和价值），折半搜索同样适用：
- 前半部分枚举所有（重量, 价值）对
- 按重量排序，预处理前缀最大价值
- 后半部分枚举每个状态，在前半部分中二分查找重量限制，取最大价值

这是"多维背包 + 折半搜索"的经典应用。

### 7.6 一句话总结

折半搜索（Meet in the Middle）是对付 $n \approx 40$ 子集类问题的标配武器，核心思想是"分两半枚举 + 高效合并"，把指数复杂度从 $2^n$ 砍到 $2^{n/2}$。二分查找版是最通用的实现方式，思路清晰、写法直观，适合所有需要"在前半部分中查找满足条件的数量/最大值"的场景。掌握折半搜索后，很多看似不可行的暴力题都能"柳暗花明又一村"。$AKB31$, '基础算法', array['基础算法', '搜索', '折半搜索', 'Meet in the Middle', 'DFS', '二分查找', '子集和'], 'col-hub-basic-search', null, 'knowledge'),
('world-needs-sunday', 'col-basic-meet-in-middle-two-pointer', '折半搜索（Meet in the Middle）— 双指针合并版', $AKB32$## 折半搜索（Meet in the Middle）— 双指针合并版

## 一、算法原理

### 1.1 问题与折半思想回顾

**子集和计数问题**：给定 $n$ 个正整数 $a_1, a_2, \dots, a_n$ 和上限 $m$，求有多少个子集的元素之和不超过 $m$。

**折半搜索核心**：将 $n$ 个元素分成前后两半，分别枚举所有子集和，再合并统计。

- 前半部分子集和存入 `tmp1`
- 后半部分子集和存入 `tmp2`
- 统计满足 $x + y \le m$ 的 $(x, y)$ 对数，其中 $x \in tmp1$，$y \in tmp2$

二分查找版和双指针版的**前半部分和后半部分的枚举完全一样**，区别只在于**合并统计的方式**。

### 1.2 双指针合并的核心思想

把两个数组都排序后，利用单调性用双指针在线性时间内统计答案。

**具体做法**：
1. 将 `tmp1` 升序排序，`tmp2` 升序排序
2. 指针 $i$ 从 `tmp1` 的左端（最小）开始向右走
3. 指针 $j$ 从 `tmp2` 的右端（最大）开始向左走
4. 对于每个 $i$，找到最大的 $j$ 使得 `tmp1[i] + tmp2[j] <= m`
5. 此时 `tmp2[0..j]` 共 $j+1$ 个元素都满足条件，加到答案中

**为什么可以这样做？**
- `tmp1` 升序：$i$ 增大时，`tmp1[i]` 增大
- 要保持 `tmp1[i] + tmp2[j] <= m`，当 `tmp1[i]` 增大时，`tmp2[j]` 必须减小
- 所以 $j$ 只能向左移动（单调不增），不会回头
- 总移动次数：$i$ 走 $|tmp1|$ 步，$j$ 走 $|tmp2|$ 步，总计 $O(2^{n/2})$

### 1.3 双指针 vs 二分查找的效率对比

| 合并方式 | 时间复杂度 | 说明 |
|----------|-----------|------|
| 二分查找版 | $O(n \cdot 2^{n/2})$ | 每个元素一次二分，O(n) per query |
| 双指针版 | $O(2^{n/2})$ | 线性扫描一遍 |

看起来差了一个 $n$ 倍，但实际中：
- $n=40$ 时，$n=40$ 倍听起来很多，但实际运行时间差距没那么大（二分查找的常数很小）
- 双指针版需要排序**两个**数组，二分查找版只排序一个
- 两者在实际竞赛中都能通过，双指针稍快一些

### 1.4 算法流程示意

```
n 个元素
   │
   ├─ 前半部分 DFS → tmp1（所有子集和）→ 排序 ↑
   │                                              │ 双指针
   └─ 后半部分 DFS → tmp2（所有子集和）→ 排序 ↑  合并
                                                           │
                                                       答案 cnt
```

### 1.5 关键变量

| 变量 | 类型 | 作用 |
|------|------|------|
| `A[k]` | `vector<long long>` | 输入数组 |
| `tmp1` | `vector<long long>` | 前半部分所有子集和 |
| `tmp2` | `vector<long long>` | 后半部分所有子集和 |
| `cnt` | `long long` | 答案（满足条件的子集总数） |
| `i, j` | `int` | 双指针，i 在 tmp1 从左向右，j 在 tmp2 从右向左 |

## 二、核心公式/状态定义与转移方程

### 2.1 复杂度公式

**双指针版总时间复杂度**：

$$T(n) = O(n \cdot 2^{n/2})$$

总复杂度的瓶颈在排序阶段，双指针合并本身只需 $O(2^{n/2})$。因此两种写法的总复杂度都是 $O(n \cdot 2^{n/2})$，双指针版只是常数更小一些。

> **结论**：双指针版比二分查找版快，但没有量级上的差距。竞赛中写哪个都行，看个人习惯。

### 2.2 DFS 状态定义

```cpp
void dfs(int k, int n, long long sum, long long m, vector<long long>& tmp)
```

**状态**：从第 $k$ 个元素开始考虑，到第 $n$ 个为止，当前和为 $sum$，上限为 $m$，结果存入 `tmp`。

**终止条件**：`k > n` → `tmp.push_back(sum)`

**转移**：
1. 不选第 $k$ 个：`dfs(k + 1, n, sum, m, tmp)`
2. 选第 $k$ 个（如果和不超过 m）：`dfs(k + 1, n, sum + A[k], m, tmp)`

> 这个 dfs 函数通过引用参数 `tmp` 来区分是枚举前半部分还是后半部分，比二分查找版的两个 dfs 函数更简洁。

### 2.3 双指针计数公式

`tmp1` 和 `tmp2` 都升序排序后：

- $i$ 从 0 开始（tmp1 最小端），遍历到末尾
- $j$ 从 `tmp2.size() - 1` 开始（tmp2 最大端）
- 对于每个 $i$，j 左移直到 `tmp1[i] + tmp2[j] <= m`
- 此时 tmp2[0..j] 都满足条件，共 $j+1$ 个

$$\text{cnt} = \sum_{i=0}^{|tmp1|-1} (j_i + 1)$$

其中 $j_i$ 是对应第 $i$ 个元素时 j 的位置。

### 2.4 双指针单调性证明

**证明 j 单调不增**：

当 $i$ 增大时，`tmp1[i]` 增大（因为 tmp1 升序）。

设 $i_1 < i_2$，对应 $j_1$ 和 $j_2$。

- `tmp1[i1] + tmp2[j1] <= m`（$j_1$ 的定义）
- `tmp1[i2] >= tmp1[i1]`（升序）
- 假设 $j_2 > j_1$，则 `tmp2[j2] >= tmp2[j1]`（升序）
- 那么 `tmp1[i2] + tmp2[j2] >= tmp1[i1] + tmp2[j1] <= m`
- 但这不能直接说明矛盾...

换个思路：$j$ 的定义是"最大的满足条件的位置"。

当 i 增大（tmp1[i] 变大），能配对的 tmp2 最大值只会更小或相等，所以 j 不会右移。

即 $i_1 < i_2 \implies j_1 \ge j_2$ ✓

这保证了 j 只会向左移动，总移动步数不超过 |tmp2|。

## 三、逐行代码解析

### 3.1 全局变量

```cpp
vector<long long>A;
```

输入数组，全局变量方便 dfs 访问。

### 3.2 dfs —— 枚举子集和（通用版）

```cpp
void dfs(int k, int n, long long sum, long long m, vector<long long>& tmp)
{
    if (k > n)
    {
        tmp.emplace_back(sum);
        return;
    }
    dfs(k + 1, n, sum, m, tmp);
    if (sum + A[k] <= m) dfs(k + 1, n, sum + A[k], m, tmp);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `void dfs(int k, int n, long long sum, long long m, vector<long long>& tmp)` | 最后一个参数 tmp 是引用，用于存储结果 |
| 3-6 | `if (k > n) { tmp.emplace_back(sum); return; }` | 终止：把当前和加入 tmp |
| 8 | `dfs(k + 1, n, sum, m, tmp);` | **不选**第 k 个元素 |
| 9 | `if (sum + A[k] <= m)` | 剪枝：选了之后不超过 m 才继续 |
| 9 | `dfs(k + 1, n, sum + A[k], m, tmp);` | **选**第 k 个元素 |

> 相比二分查找版的 dfs1 + dfs2 两个函数，这里通过引用参数 `tmp` 实现了一个通用的枚举函数，代码更简洁。

### 3.3 fn —— 主逻辑

```cpp
long long fn(int n, long long m)
{
    long long cnt = 0;
    int tmp_sz = n / 2;
    vector<long long> tmp1, tmp2;
    dfs(tmp_sz + 1, n, 0, m, tmp2);
    dfs(1, tmp_sz, 0, m, tmp1);

    sort(tmp1.begin(), tmp1.end());
    sort(tmp2.begin(), tmp2.end());

    int j = tmp2.size() - 1;
    for (int i = 0; i < tmp1.size(); i++)
    {
        while (j >= 0 && tmp1[i] + tmp2[j] > m) --j;
        cnt += j + 1;
    }
    return cnt;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 3 | `long long cnt = 0;` | 答案计数器初始化为 0 |
| 4 | `int tmp_sz = n / 2;` | 前半部分元素个数 |
| 5 | `vector<long long> tmp1, tmp2;` | 两个数组分别存两半的子集和 |
| 6 | `dfs(tmp_sz + 1, n, 0, m, tmp2);` | 枚举**后半部分**（tmp_sz+1 到 n），存入 tmp2 |
| 7 | `dfs(1, tmp_sz, 0, m, tmp1);` | 枚举**前半部分**（1 到 tmp_sz），存入 tmp1 |
| 9-10 | `sort(tmp1...); sort(tmp2...);` | 两个数组都排序，为双指针做准备 |
| 12 | `int j = tmp2.size() - 1;` | j 从 tmp2 的右端（最大值）开始 |
| 13 | `for (int i = 0; i < tmp1.size(); i++)` | i 从 tmp1 的左端开始，逐个遍历 |
| 15 | `while (j >= 0 && tmp1[i] + tmp2[j] > m) --j;` | 如果当前和超过 m，j 左移（找更小的 tmp2[j]） |
| 16 | `cnt += j + 1;` | tmp2[0..j] 都满足条件，共 j+1 个，加到答案 |
| 17 | `return cnt;` | 返回答案 |

> **注意第 6-7 行的顺序**：先枚举后半部分存入 tmp2，再枚举前半部分存入 tmp1。顺序不影响最终结果，只是两个数组的名字交换一下而已。

### 3.4 双指针执行示例

以 `tmp1 = [0, 2, 3, 5]`，`tmp2 = [0, 1, 4, 5]`，`m = 5` 为例：

```
初始：j = 3 (tmp2[3]=5), cnt = 0

i=0 (tmp1[0]=0):
  0 + 5 = 5 <= 5 → 不移动 j
  cnt += 3+1 = 4 → cnt = 4

i=1 (tmp1[1]=2):
  2 + 5 = 7 > 5 → j-- → j=2 (tmp2[2]=4)
  2 + 4 = 6 > 5 → j-- → j=1 (tmp2[1]=1)
  2 + 1 = 3 <= 5 → 停止
  cnt += 1+1 = 2 → cnt = 6

i=2 (tmp1[2]=3):
  3 + 1 = 4 <= 5 → 不移动 j
  cnt += 1+1 = 2 → cnt = 8

i=3 (tmp1[3]=5):
  5 + 1 = 6 > 5 → j-- → j=0 (tmp2[0]=0)
  5 + 0 = 5 <= 5 → 停止
  cnt += 0+1 = 1 → cnt = 9

答案：9 ✓
```

### 3.5 main 函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    long long m;
    cin >> n >> m;
    A.assign(n + 1, 0);
    for (int i = 1; i <= n; i++) cin >> A[i];
    cout << fn(n, m);
    return 0;
}
```

标准输入输出模板。

## 四、复杂度分析

### 4.1 时间复杂度

$$O(n \cdot 2^{n/2})$$

**详细分解**：

| 步骤 | 复杂度 | 说明 |
|------|--------|------|
| 枚举前半部分 | $O(2^{n/2})$ | DFS 枚举所有子集 |
| 枚举后半部分 | $O(2^{n/2})$ | DFS 枚举所有子集 |
| 排序 tmp1 | $O(\frac{n}{2} \cdot 2^{n/2})$ | k 个元素排序 = O(k log k) |
| 排序 tmp2 | $O(\frac{n}{2} \cdot 2^{n/2})$ | 同上 |
| 双指针合并 | $O(2^{n/2})$ | i 和 j 各走一遍 |
| **总计** | $O(n \cdot 2^{n/2})$ | 排序是瓶颈 |

### 4.2 空间复杂度

$$O(2^{n/2})$$

tmp1 和 tmp2 各存 $2^{n/2}$ 个元素，总计 $O(2^{n/2})$。递归栈 $O(n)$ 可忽略。

### 4.3 与二分查找版的对比

| 维度 | 二分查找版 | 双指针版 |
|------|-----------|----------|
| 排序次数 | 1 次（只排前半） | 2 次（两半都要排） |
| 合并复杂度 | $O(n \cdot 2^{n/2})$ | $O(2^{n/2})$ |
| 总复杂度 | $O(n \cdot 2^{n/2})$ | $O(n \cdot 2^{n/2})$ |
| 实际速度 | 稍慢 | 稍快（常数更小） |
| dfs 函数数 | 2 个（dfs1 存 + dfs2 查） | 1 个（通用版，引用参数） |
| 代码长度 | 稍长 | 稍短 |
| 灵活度 | 高（可查第 k 大、可查范围等） | 低（只适合计数类） |

> **一句话总结**：纯计数问题双指针版更快更简洁；如果需要更复杂的查询（如找最大值、查某个值是否存在），用二分查找版更灵活。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **子集和计数** | 双指针版是最快的实现方式之一 |
| **两数之和/两数接近** | 在两个数组中配对，双指针是经典套路 |
| **n≈40 的子集类问题** | 折半搜索的标准应用 |
| **合并两个有序数组的统计** | 只要两个数组都有序，且有单调性，就能用双指针 |

## 六、常见陷阱与注意事项

### 6.1 j 的初始位置

```cpp
int j = tmp2.size() - 1;
```

j 要从 tmp2 的**最右端**（最大元素）开始。

容易写错成 `j = 0`，那就完全反了。

### 6.2 while 循环的条件

```cpp
while (j >= 0 && tmp1[i] + tmp2[j] > m) --j;
```

注意是 `>` 还是 `>=`：
- 题目要求"和 ≤ m"：`> m` 时 j 左移（正确）
- 题目要求"和 < m"：`>= m` 时 j 左移

根据题意灵活调整。

### 6.3 cnt += j + 1

j 是下标，满足条件的是 tmp2[0] 到 tmp2[j]，共 **j+1** 个元素。

经常有人写成 `cnt += j`，漏掉了 +1，答案少算。

### 6.4 两个数组都要排序

双指针要求**两个数组都有序**。只排一个是不行的。

排序方向可以都是升序，也可以都是降序，只要对应地调整指针方向即可。本代码用升序。

### 6.5 tmp1 和 tmp2 的大小可以不一样

前半部分 n/2 个元素，后半部分 n-n/2 个元素，所以 tmp1.size() 和 tmp2.size() 可能差 1（当 n 为奇数时）。这不影响双指针的正确性。

### 6.6 空集也算

tmp1 和 tmp2 中都包含 0（什么都不选的情况），所以最终答案包含了"空集"。如果题目要求非空子集，答案减 1。

### 6.7 long long 不能省

- $n=40$ 时答案可达 $2^{40} \approx 10^{12}$，必须用 `long long`
- 子集和也可能很大，`sum` 和 `tmp` 都要用 `long long`

### 6.8 为什么先枚举后半部分

代码中先 `dfs(tmp_sz+1, n, ..., tmp2)` 再 `dfs(1, tmp_sz, ..., tmp1)`，顺序反过来也完全没问题。

哪个先枚举不影响结果，只是 tmp1 和 tmp2 交换名字而已。

## 七、对比与扩展

### 7.1 两种折半搜索实现对比

| 维度 | 二分查找版 | 双指针版 |
|------|-----------|----------|
| 核心操作 | 枚举一半 + 另一半二分 | 两边都排好序 + 双指针扫描 |
| dfs 函数 | 2 个（结构略有不同） | 1 个（通用，引用参数） |
| 排序次数 | 1 次 | 2 次 |
| 合并时间 | $O(n \cdot 2^{n/2})$ | $O(2^{n/2})$ |
| 总时间 | $O(n \cdot 2^{n/2})$ | $O(n \cdot 2^{n/2})$ |
| 代码简洁度 | 稍复杂 | 更简洁 |
| 灵活性 | 高（支持各种查询） | 较低（只适合计数） |
| 适用问题 | 通用 | 计数类最优 |

### 7.2 双指针的其他应用场景

双指针是一种非常通用的技巧，不止用于折半搜索：

| 应用 | 说明 |
|------|------|
| 两数之和（有序数组） | 两端向中间靠，找和为目标值的两个数 |
| 三数之和 | 固定一个数，另外两个用双指针 |
| 合并两个有序数组 | 两个指针各走各的 |
| 判断子序列 | 一个指针遍历长串，一个指针走短串 |
| 滑动窗口 | 左右指针维护窗口 |

双指针的核心是**利用单调性减少重复计算**，把 $O(n^2)$ 降到 $O(n)$。

### 7.3 扩展：求有多少对和 = k

把双指针的判定条件改一下：

```cpp
// 需要统计和 == k 的对数
int j1 = tmp2.size() - 1; // > k 的边界
int j2 = tmp2.size() - 1; // >= k 的边界
for (int i = 0; i < tmp1.size(); i++) {
    while (j1 >= 0 && tmp1[i] + tmp2[j1] > k) j1--;
    while (j2 >= 0 && tmp1[i] + tmp2[j2] >= k) j2--;
    cnt += j1 - j2;
}
```

或者更简单：`upper_bound - lower_bound`（这时候二分查找版更方便）。

### 7.4 扩展：最接近目标和的子集和

双指针也可以找最大值：

```cpp
long long ans = 0;
int j = tmp2.size() - 1;
for (int i = 0; i < tmp1.size(); i++) {
    while (j >= 0 && tmp1[i] + tmp2[j] > m) j--;
    if (j >= 0) ans = max(ans, tmp1[i] + tmp2[j]);
}
```

### 7.5 扩展：三分数组

当 n 更大时（比如 n=60），可以把数组分成三份，复杂度降到 $O(n^2 \cdot 3^{n/3})$，但实现更复杂，竞赛中很少用。折半搜索是最实用的。

### 7.6 一句话总结

双指针版折半搜索通过"两半都排序 + 双指针线性扫描"实现合并，代码更简洁、常数更小，是子集和计数问题的最优实现之一。理解双指针的单调性原理是关键——i 增大时 j 单调不增，保证了线性时间复杂度。掌握两种折半搜索实现（二分 + 双指针）后，遇到 n≈40 的子集类问题就能游刃有余。$AKB32$, '基础算法', array['基础算法', '搜索', '折半搜索', 'Meet in the Middle', 'DFS', '双指针', '子集和'], 'col-hub-basic-search', null, 'knowledge'),
('world-needs-sunday', 'col-basic-permutation-dfs', 'DFS 生成全排列（回溯法）', $AKB33$## DFS 生成全排列（回溯法）

## 一、算法原理

### 1.1 什么是全排列

从 $n$ 个不同元素中取出 $n$ 个元素，按照一定的顺序排成一列，叫做这 $n$ 个元素的一个**全排列**（Permutation）。

$n$ 个不同元素的全排列总数为：

$$P(n, n) = n! = n \times (n-1) \times (n-2) \times \dots \times 1$$

例：$n=3$ 时，全排列共有 $3!=6$ 种：`1 2 3`、`1 3 2`、`2 1 3`、`2 3 1`、`3 1 2`、`3 2 1`。

### 1.2 DFS + 回溯的核心思想

生成全排列的过程可以看作**逐步填充每个位置**的过程：

- 第 $1$ 个位置：可以选 $1, 2, \dots, n$ 中的任意一个（共 $n$ 种选择）
- 第 $2$ 个位置：从剩下的 $n-1$ 个数中选一个（共 $n-1$ 种选择）
- ...
- 第 $k$ 个位置：从剩下的 $n-k+1$ 个数中选一个
- 第 $n$ 个位置：只剩 $1$ 个数

这天然形成了一棵**递归搜索树**：每个节点代表"当前已填好前 $k$ 个位置"的状态，每个分支代表选择一个未使用的数填入下一个位置。

**回溯（Backtracking）**：当我们填完所有位置（到达叶子节点）后，需要"撤销"最后一步的选择，回到上一层继续尝试其他选择，直到穷举所有可能。

### 1.3 关键变量

| 变量 | 类型 | 作用 |
|------|------|------|
| `tmp[k]` | `vector<int>` | 存储当前排列的第 $k$ 个位置的数值 |
| `vis[i]` | `vector<bool>` | 标记数字 $i$ 是否已被使用（`true`=已用，`false`=未用） |
| `k` | `int` | 当前正在填充第几个位置（递归深度） |

### 1.4 搜索树示意（以 n=3 为例）

```
                    填第1位
        /            |            \
      选1           选2           选3
       |             |             |
    填第2位        填第2位        填第2位
    /    \        /    \        /    \
  选2    选3    选1    选3    选1    选2
   |      |      |      |      |      |
  填3位  填3位  填3位  填3位  填3位  填3位
   |      |      |      |      |      |
 1 2 3  1 3 2  2 1 3  2 3 1  3 1 2  3 2 1
```

每一条从根到叶的路径对应一个排列，共 $3!=6$ 个叶子节点。

## 二、核心公式/状态定义与转移方程

### 2.1 状态定义

**状态**：`dfs(k, n)` 表示"已经填好了前 $k-1$ 个位置，现在要填第 $k$ 个位置，总共有 $n$ 个元素"。

**终止条件**：当 $k > n$ 时，说明所有位置都已填好，得到一个完整排列，输出结果并返回。

### 2.2 状态转移

对于第 $k$ 个位置，我们枚举所有可能的选择 $i$（$1 \le i \le n$）：

- 如果 `vis[i] == false`（数字 $i$ 未被使用）：
  1. 标记 `vis[i] = true`（使用 $i$）
  2. `tmp[k] = i`（将 $i$ 放入第 $k$ 位）
  3. 递归调用 `dfs(k + 1, n)`（填下一个位置）
  4. `vis[i] = false`（回溯：撤销选择，恢复状态）

### 2.3 排列数公式验证

每层递归的选择数：

| 层数 k | 可选数量 | 说明 |
|--------|----------|------|
| 第1层 | $n$ | 所有数都可用 |
| 第2层 | $n-1$ | 已用1个数 |
| 第3层 | $n-2$ | 已用2个数 |
| ... | ... | ... |
| 第n层 | $1$ | 只剩1个数 |

总叶子节点数 = $n \times (n-1) \times (n-2) \times \dots \times 1 = n!$，与排列数公式一致 ✓

## 三、逐行代码解析

### 3.1 全局变量与初始化

```cpp
vector<int> tmp;
vector<bool> vis;
void init(int n)
{
    tmp.assign(n + 1, 0);
    vis.assign(n + 1, false);
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `vector<int> tmp;` | 存储当前排列，`tmp[k]` 表示第 $k$ 位的数字（下标从1开始） |
| 2 | `vector<bool> vis;` | 访问标记数组，`vis[i]` 表示数字 $i$ 是否已被使用 |
| 4-7 | `init(int n)` | 初始化函数，给两个向量分配大小为 $n+1$ 的空间（下标从1开始方便使用） |
| 6 | `tmp.assign(n + 1, 0)` | tmp 初始化为 $n+1$ 个 0 |
| 7 | `vis.assign(n + 1, false)` | vis 初始化为 $n+1$ 个 `false`（全部未使用） |

> **为什么用 n+1 的空间？** 因为数字是从 1 到 n，下标直接对应数字，不用做偏移转换，代码更简洁。

### 3.2 DFS 核心函数

```cpp
void dfs(int k, int n)
{
    if (k > n)
    {
        for (int i = 1; i <= n; i++) cout << tmp[i] << ' ';
        cout << '\n';
        return;
    }
    for (int i = 1; i <= n; i++)
    {
        if (vis[i]) continue;
        vis[i] = true;
        tmp[k] = i;
        dfs(k + 1, n);
        vis[i] = false;
    }
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `void dfs(int k, int n)` | $k$ = 当前填第几位，$n$ = 总元素数 |
| 3 | `if (k > n)` | 终止条件：已填完所有 $n$ 个位置 |
| 5-6 | `for (...) cout << tmp[i] << ' ';` | 输出当前排列（即一个完整的答案） |
| 7 | `return;` | 回溯到上一层 |
| 9 | `for (int i = 1; i <= n; i++)` | 枚举第 $k$ 位的所有可能选择 |
| 11 | `if (vis[i]) continue;` | 如果数字 $i$ 已被使用，跳过 |
| 12 | `vis[i] = true;` | **标记**：使用数字 $i$ |
| 13 | `tmp[k] = i;` | **记录**：将 $i$ 放入第 $k$ 位 |
| 14 | `dfs(k + 1, n);` | **递归**：去填第 $k+1$ 位 |
| 15 | `vis[i] = false;` | **回溯**：撤销选择，恢复 $i$ 为未使用状态（关键！） |

> **回溯的本质**：递归返回后，必须把 `vis[i]` 改回 `false`，这样在同一层的下一次循环中，$i$ 才能被其他分支重新使用。这就是"恢复现场"。

### 3.3 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    cin >> n;
    init(n);
    dfs(1, n);
    return 0;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2-3 | 快速 IO | 加速输入输出，排列数多时输出量很大 |
| 4-5 | `int n; cin >> n;` | 读入排列的元素个数 |
| 6 | `init(n);` | 初始化 tmp 和 vis 数组 |
| 7 | `dfs(1, n);` | 从第 1 位开始填 |

### 3.4 执行示例（n=3 的前几步）

1. `dfs(1, 3)`：$k=1$，枚举 $i=1,2,3$
   - $i=1$：`vis[1]=true`, `tmp[1]=1` → 调用 `dfs(2, 3)`
     - `dfs(2, 3)`：$k=2$，枚举 $i=1$（跳过）, $i=2, 3$
       - $i=2$：`vis[2]=true`, `tmp[2]=2` → 调用 `dfs(3, 3)`
         - `dfs(3, 3)`：$k=3$，枚举 $i=1$（跳过）, $i=2$（跳过）, $i=3$
           - $i=3$：`vis[3]=true`, `tmp[3]=3` → 调用 `dfs(4, 3)`
             - `dfs(4, 3)`：$k=4 > 3$，输出 `1 2 3`，返回
           - 回溯：`vis[3]=false`
         - 返回 `dfs(3,3)`，循环结束，返回
       - 回溯：`vis[2]=false`
       - $i=3$：`vis[3]=true`, `tmp[2]=3` → 调用 `dfs(3, 3)`
         - ...（输出 `1 3 2`）
       - 回溯：`vis[3]=false`
     - 返回 `dfs(2,3)`，循环结束，返回
   - 回溯：`vis[1]=false`
   - $i=2$：...（继续生成 `2 1 3`、`2 3 1`）
   - ...

## 四、复杂度分析

### 4.1 时间复杂度

$$O(n \times n!)$$

**推导**：
- 共有 $n!$ 个不同的排列（叶子节点）
- 每个排列需要 $O(n)$ 的时间输出（打印 $n$ 个数）
- 搜索过程中每个节点都要做一次循环枚举，总节点数约为 $e \times n!$（调和级数近似）
- 综合起来为 $O(n \times n!)$

### 4.2 空间复杂度

$$O(n)$$

**推导**：
- `tmp` 数组：$O(n)$
- `vis` 数组：$O(n)$
- 递归栈深度：最深为 $n$ 层（$k$ 从 1 到 n），$O(n)$
- 总空间：$O(n)$

### 4.3 不同 n 的规模参考

| n | n!（排列数） | 大约输出量 | 可行性 |
|---|-------------|-----------|--------|
| 5 | 120 | 约 600 个数字 | 瞬间完成 |
| 8 | 40,320 | 约 32 万个数字 | < 1 秒 |
| 10 | 3,628,800 | 约 3600 万个数字 | 数秒 |
| 12 | 479,001,600 | 约 58 亿个数字 | 不现实 |

> **注意**：全排列的数量增长极快（阶乘级），通常 $n \le 10$ 时还能枚举出所有排列，$n$ 更大时一般只需要计数或求第 k 个排列，而不是全部生成。

## 五、适用场景

| 场景 | 说明 |
|------|------|
| **全排列生成** | 枚举所有排列，用于暴力搜索、小规模问题验证 |
| **排列型回溯题** | 如 N皇后、全排列 II（有重复元素）、排列计数等经典回溯问题的基础模板 |
| **暴力枚举顺序** | 当需要尝试所有可能的操作顺序时，排列枚举是最直接的方法 |
|  **字典序排列** | 本代码按 1→n 的顺序枚举，生成的排列天然按字典序输出 |
| **数组元素排列** | 将数组元素而非 1~n 进行排列时，只需把 `tmp[k] = i` 改为 `tmp[k] = a[i]` |

## 六、常见陷阱与注意事项

### 6.1 忘记回溯（最常见错误）

```cpp
// 错误：没有恢复 vis[i]
vis[i] = true;
tmp[k] = i;
dfs(k + 1, n);
// 漏掉了 vis[i] = false;
```

如果不恢复 `vis[i]`，第一个分支用完所有数后，后面的分支会因为所有数都被标记为已用而直接跳过，只能生成第一个排列。

### 6.2 tmp 数组不需要回溯

注意代码中只恢复了 `vis[i]`，没有把 `tmp[k]` 改回 0。为什么？

因为 `tmp[k]` 会在同一层的下一次循环中被**直接覆盖**（`tmp[k] = i`），旧值不影响结果。而 `vis[i]` 会影响更深层的判断，所以必须恢复。

### 6.3 下标从 0 还是从 1 开始

本代码使用 1-based（数字和位置都从1开始），符合数学直觉。如果要改成 0-based：
- `init(n)` 改为 `tmp.assign(n, 0); vis.assign(n, false);`
- 循环 `for (int i = 0; i < n; i++)`
- 输出也是 `for (int i = 0; i < n; i++)`

### 6.4 有重复元素的情况

如果元素中有重复值，简单的 vis 数组会生成重复排列。此时需要：
1. 先对数组排序
2. 同一层中，如果当前元素与前一个相同且前一个未被使用，则跳过（去重）

### 6.5 输出顺序

本代码按**字典序**输出排列，因为循环 `i` 从小到大枚举。如果想逆序输出，把循环改成 `for (int i = n; i >= 1; i--)` 即可。

### 6.6 不需要传 n 也可以

因为 `tmp` 和 `vis` 都是全局的，大小已知。可以用 `tmp.size() - 1` 代替 `n`，但传参更清晰。

### 6.7 非递归实现

全排列也可以用 `next_permutation` 库函数（C++ STL）非递归生成：

```cpp
vector<int> a(n);
for (int i = 0; i < n; i++) a[i] = i + 1;
do {
    for (int x : a) cout << x << ' ';
    cout << '\n';
} while (next_permutation(a.begin(), a.end()));
```

但手写 DFS 版本更灵活，可以在递归过程中加剪枝、记录中间状态等。

## 七、对比与扩展

### 7.1 排列 vs 组合（DFS 写法对比）

| 维度 | 排列 DFS | 组合 DFS |
|------|----------|----------|
| 核心问题 | 顺序有关，选谁放第几位 | 顺序无关，选不选 |
| 关键变量 | `vis[]` 标记已用元素 | `idx` 记录已选个数 |
| 每步选择 | 枚举所有未用元素（n种） | 选 / 不选（2种） |
| 终止条件 | `k > n`（填满n个位置） | `idx == m+1`（选了m个） |
| 结果数量 | $n!$ | $C(n, m)$ |
| 剪枝 | 通常不需要 | 有"剩余不够"的剪枝 |

### 7.2 手写 DFS vs next_permutation

| 维度 | 手写 DFS | `next_permutation` |
|------|----------|-------------------|
| 代码量 | 约 15 行核心 | 2-3 行 |
| 灵活性 | 高（可加剪枝、自定义顺序、记录路径） | 低（只能按字典序） |
| 适用范围 | 排列型回溯题、需要过程信息 | 只需要生成排列 |
| 效率 | 稍慢（递归函数调用开销） | 稍快（底层迭代实现） |
| 初始要求 | 无 | 需要先排序才能生成全部排列 |

### 7.3 扩展：求第 k 个排列

当 $n$ 较大时（如 $n=20$），不可能生成所有排列再找第 $k$ 个。可以用"逐位确定"的方法：

- 第 1 位：每个数字开头有 $(n-1)!$ 个排列，用 $k / (n-1)!$ 确定第一位
- 第 2 位：在剩余数字中重复上述过程
- ...

时间复杂度 $O(n^2)$，远优于 $O(n!)$。

### 7.4 扩展：排列数计数（不取模 / 取模）

- **不取模**：$n!$ 增长极快，$20! \approx 2.4 \times 10^{18}$ 刚好能放进 `unsigned long long`
- **取模**：用递推 $fact[i] = fact[i-1] \times i \bmod MOD$ 预处理，$O(n)$

### 7.5 一句话总结

DFS 生成全排列是回溯法的经典入门模板，核心是"枚举选择 → 标记使用 → 递归深入 → 撤销标记"四步走。掌握这个模板后，N皇后、子集、组合等一大批回溯问题都能快速上手。理解 `vis` 数组的作用和回溯时的"恢复现场"，是写对所有回溯题的关键。$AKB33$, '基础算法', array['基础算法', '搜索', '排列', 'DFS', '回溯', '递归'], 'col-hub-basic-search', null, 'knowledge'),
('stripe-python', 'col-basic-problem-solving-patterns--stripe-python', '做题套路与结论汇总 · stripe-python', $AKB34$> 本文由 stripe-python 授权合并，保留原文结构与表述。
这里记录一些做题时学到的结论 & 套路 & 注意事项。

1. 区间 $[l,r]$ 内的下标 $x$ 在该区间翻转后的下标是 $l+r-x$。
2. 维护 $01$ 序列的时候，可以维护所有 $0/1$ 的下标。
3. 一个数 $v \ge 1$ 在 $O(\log \log v)$ 次开方下取整后变为 $1$。
4. 不刻意卡的 $O(\dfrac{n}{w})$ 比 $O(\log n)$ 快很多。
5. 带修莫队的块长取 $1.7n^{0.667}$ 更快。
6. bitset 优化埃氏筛比线性筛快。
7. $\operatorname{mex}$ 的值最多是 $n+1$。
8. `std::multiset` 删元素要用 `erase(find(val))`。
9. 写出类似 `for (int i = 1; i <= k; i++) v = x[v];` 的代码时都可以倍增优化到 $O(\log k)$。
10. 点权最短路和边权没什么区别。
11. 当 $x \oplus y=\gcd(x,y)=z$ 时，必有 $x-y=z$。UVA12716。
12. 经过一个点的最小环等价于次短路问题。
13. 多项式哈希的线性性：有 $\sum_{i=1}^{n} k \times s_i \times B^{n-i}+\sum_{i=1}^{n} b \times B^{n-i}=k \times h_n+b$。因此可以上线段树维护。
14. 最小化 $\text{最大}+\text{次大}$ 时，绝大部分是枚举最大找最小的次大。
15. 求 $\sum (a_i \bmod M)$ 时，不妨求 $\sum a_i+kM$。ABC378-E。
16. 删点 / 覆盖问题可以倒序做变成加点 / 去覆盖。
17. 设计 dp 时，可以考虑用两维的特征压成一维记录。P5664。
18. 环上问题可以倒着想，例如 $\max$ 变成 $\max(\max, \sum-\min)$。
19. 将奇形怪状的东西放到棋盘里，对棋盘进行黑白染色。则两种颜色的个数为 $\lfloor \dfrac{nm}{2} \rfloor$ 与 $\lceil \dfrac{nm}{2} \rceil$。
20. 类似 $2b=a+c$ 的三元组统计，考虑求多项式卷积。ABC392-G。
21. $\max(x,y)=\dfrac{x+y+|x-y|}{2}$。
22. 满足 $x_i>0, \sum_{i=1}^{n} x_i=1$ 的

$x_1+x_1x_2+x_1x_2x_3+\cdots=\sum_{i=1}^{n} \prod_{j=1}^{i} a_j$的最小值为 $3^{\frac{n}{3}}$。

1. 对于双端点询问 $[l,r]$，若有 $[1,r]-[1,l-1]$ 可变为单端点询问。
2. 对于四端点询问 $[l_1,r_1,l_2,r_2]$，若有 $[1,r]-[1,l-1]$ 可变为双端点询问 $[r_1,r_2]-[l_1-1,r_2]-[r_1,l_2-1]+[l_1-1,l_2-1]$。
3. 用 Dijkstra 求最短路，要求松弛函数 $f(dis_v,w)$ 满足两个条件：$f(dis_v,w) \ge dis_v$ 且关于 $dis_v$ 单调递增。
4. 树上问题对一条路径的边权异或，可以化边为点，等价于对端点异或。
5. 随机排列的 LIS 长度是 $O(\sqrt{n})$ 级别的。
6. 折半警报器 / 二进制警报器：P7603。
7. 将题目转化为最短哈密顿路时，往往考虑变成欧拉回路。
8. 二分图博弈的结论：存在一个点属于所有最大匹配先手必胜（且作为起点），否则先手必败。P4617。结合黑白染色。
9. dsu on tree：先 dfs 轻儿子并清空，再 dfs 重儿子不清空，然后再加入所有亲儿子的信息，复杂度为 $O(n \log n)$。
10. 对小于 / 大于某数的计数，如果小于 = 大于，考虑转化为 $\frac{\text{总数}-\text{等于}}{2}$。CF1227F2。$AKB34$, '基础算法', array['套路', '结论', '技巧', '杂项'], 'col-basic-tricks-overview', null, 'knowledge'),
('world-needs-sunday', 'col-basic-quickselect-kth', '快速选择（Quickselect — 找第 k 小）', $AKB35$## 算法原理

快速选择（Quickselect）是快速排序的"半边"版本：利用划分（partition）确定 pivot 的最终位置，然后**只递归包含第 $k$ 小的那一半**，丢弃另一半。这使得平均时间从排序的 $O(n \log n)$ 降到了 $O(n)$。

### 核心思路

对于数组 $A[l..r]$ 中找第 $k$ 小（$k$ 是下标，从 $l$ 开始计）：

1. **选 pivot**：从 $A[l]$、$A[r]$、$A[\lfloor (l+r)/2 \rfloor]$ 中取中位数（三数取中法），避免最坏情况
2. **划分**：双指针从两端向中间扫描，把 $\leq$ pivot 的放左边、$\geq$ pivot 的放右边
3. **分支**：划分结束后，左段为 $[l, \text{mr}]$，右段为 $[\text{ml}, r]$，中间 $[\text{mr}+1, \text{ml}-1]$ 全是 pivot 值
   - 若 $k \leq \text{mr}$：第 $k$ 小在左段，递归左段
   - 若 $k \geq \text{ml}$：第 $k$ 小在右段，递归右段
   - 否则：$k$ 落在中间的 pivot 区，直接返回 pivot 值

### 三数取中法

pivot 的选择决定算法效率：

| pivot 选择 | 平均时间 | 最坏时间 | 风险 |
|---|---|---|---|
| 取首元素 | $O(n)$ | $O(n^2)$ | 有序数组退化 |
| 随机取 | $O(n)$ | $O(n^2)$（概率极低） | 需要随机数生成器 |
| **三数取中** | $O(n)$ | $O(n^2)$（概率极低） | 简单且实用，本算法采用 |

三数取中法取 $A[l]$、$A[r]$、$A[\text{mid}]$ 的中位数作为 pivot，有效避免有序或逆序数组的退化。

## 核心公式/状态定义与转移方程

### 划分不变量

划分结束后，数组被分成三段：

$$\underbrace{A[l] \cdots A[\text{mr}]}_{\leq q} \quad \underbrace{A[\text{mr}+1] \cdots A[\text{ml}-1]}_{= q} \quad \underbrace{A[\text{ml}] \cdots A[r]}_{\geq q}$$

其中 $q$ 是 pivot 值，$\text{ml}$ 和 $\text{mr}$ 是划分后的边界。

### 递归转移

$$\text{fast\_k}(l, r, k) = \begin{cases} \text{fast\_k}(l, \text{mr}, k) & \text{若 } k \leq \text{mr} \\ \text{fast\_k}(\text{ml}, r, k) & \text{若 } k \geq \text{ml} \\ q & \text{否则（} k \text{ 落在 pivot 区）} \end{cases}$$

### 划分过程示意

以数组 $A = [0, 3, 1, 4, 2, 5, 0]$（下标从 1 开始）找第 3 小为例：

```
初始:  [3, 1, 4, 2, 5, 0]   (下标 1..6)
       l=1                r=6

三数取中: A[l]=3, A[r]=0, A[mid]=A[3]=4
  → 中位数是 3，pivot q = 3

划分（双指针 ml=1, mr=6）:
  ┌─ A[ml]=3, 不 < q=3, ml 停在 1
  │  A[mr]=0, 不 > q=3, mr 停在 6... 不对，0 < 3 所以 mr 继续走？
  └─ 实际: A[mr]=0, 0 < 3 → 0 不 > 3, mr 停在 6
     交换 A[1] 和 A[6]: [0, 1, 4, 2, 5, 3]
     ml=2, mr=5
     A[ml]=1 < 3, ml→3; A[ml]=4 不 < 3, ml 停在 3
     A[mr]=5 > 3, mr→4; A[mr]=2 不 > 3, mr 停在 4
     交换 A[3] 和 A[4]: [0, 1, 2, 4, 5, 3]
     ml=4, mr=3, ml > mr → 退出

结果:  [0, 1, 2] [4, 5, 3]
       ≤q (l..mr=3)  ≥q (ml=4..r)
       中间无 pivot 区

k=3, mr=3 → k <= mr, 递归左段 [0, 1, 2]
  l=1, r=3, q = getnum(1,3) = 中位数(1, 2, 1) = 1... 
  实际三数取中: A[1]=0, A[3]=2, A[2]=1 → 中位数 1
  划分后: [0] [1] [2], ml=2, mr=1
  k=3 > mr=1, k=3 >= ml=2 → 递归右段 [2]
  l=2, r=3, q = getnum(2,3) = 中位数(1, 2, 1)... 
  → 最终找到 A[3] = 2

第 3 小 = 2 ✓
```

## 逐行代码解析

### 快速输入输出

```cpp
inline int read()
{
    int x = 0, f = 1; char ch = getchar();
    while (ch < '0' || ch>'9') { if (ch == '-') f = -1; ch = getchar(); }
    while (ch >= '0' && ch <= '9') { x = x * 10 + ch - 48; ch = getchar(); }
    return x * f;
}
inline void write(long long x)
{
    static char buf[30];
    int p = 0;
    if (x < 0) { putchar('-'); x = -x; }
    if (x == 0) buf[p++] = '0';
    while (x) { buf[p++] = x % 10 + 48; x /= 10; }
    while (p--) putchar(buf[p]);
}
```

手写 `read`/`write` 比标准 `cin`/`cout` 快 5-10 倍，适合大数据量（$n \le 10^6$ 级别）。

### 三数取中

```cpp
int getnum(int l, int r)
{
    int a = A[l], b = A[r], c = A[l + (r - l) / 2];
    if (a >= b)
    {
        if (b >= c) return b;        // a >= b >= c → 中位数 b
        else
        {
            if (a >= c) return c;    // a >= c > b → 中位数 c
            else return a;           // c > a >= b → 中位数 a
        }
    }
    else
    {
        if (a >= c) return a;        // b > a >= c → 中位数 a
        else
        {
            if (b >= c) return c;    // b >= c > a → 中位数 c
            else return b;           // c > b > a → 中位数 b
        }
    }
}
```

通过 6 次比较找三个数的中位数。逻辑展开为分支判断，无额外函数调用开销。

### 划分 + 递归

```cpp
int fast_k(int l, int r, int k)
{
    if (l == r) return A[l];         // 递归基：只剩一个元素
    int ml = l, mr = r;
    int q = getnum(l, r);            // 三数取中选 pivot
    while (ml <= mr)
    {
        while (A[ml] < q) ++ml;      // 左指针找 >= q 的
        while (A[mr] > q) --mr;      // 右指针找 <= q 的
        if (ml <= mr) swap(A[ml++], A[mr--]);  // 交换并移动
    }
    // 划分结束: [l..mr] <= q, [mr+1..ml-1] == q, [ml..r] >= q
    if (k <= mr) return fast_k(l, mr, k);    // 第 k 小在左段
    if (k >= ml) return fast_k(ml, r, k);    // 第 k 小在右段
    return q;                                 // k 落在 pivot 区
}
```

关键点：
- `while (A[ml] < q)` 而非 `<=`：遇到等于 pivot 的元素会停下并交换，使得 pivot 值的元素均匀分布到两侧，中间可能形成 pivot 区
- `if (ml <= mr)` 而非 `<`：允许 `ml == mr` 时也交换（虽然交换自己，但两个指针会各自前进一步），确保循环正确推进
- 三分支递归：左段、右段、pivot 区，只递归其中一个，平均每次规模减半

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n, k;
    n = read(), k = read();
    A.resize(n + 1);
    for (int i = 1; i <= n; i++) A[i] = read();
    write(fast_k(1, n, k));
    return 0;
}
```

- 下标从 1 开始，`A[0]` 不使用（`resize` 初始化为 0）
- `k` 是目标排名（1-based：$k=1$ 最小，$k=n$ 最大）

## 复杂度分析

### 时间复杂度

| 情况 | 时间 | 说明 |
|---|---|---|
| 平均 | $O(n)$ | 每次划分约减半，$n + n/2 + n/4 + \cdots \le 2n$ |
| 最坏 | $O(n^2)$ | 每次只减 1 个元素，三数取中使概率极低 |

平均情况推导：设每次划分后保留 $p$ 比例的元素，则 $T(n) = T(pn) + O(n)$。若 $p \approx 1/2$，则 $T(n) = n + n/2 + n/4 + \cdots \le 2n = O(n)$。

### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 数组 A | $O(n)$ | 原地修改 |
| 递归栈 | $O(\log n)$ | 平均递归深度 |
| **总计** | $O(n)$ | 数组主导 |

## 适用场景

- **无序数组找第 $k$ 小/大**：经典 Top-K 问题，$O(n)$ 比排序后取 $O(n \log n)$ 更快
- **求中位数**：$k = \lceil n/2 \rceil$，比排序更高效
- **求前 $k$ 小的元素**：配合划分，可以把前 $k$ 小的元素放到数组前 $k$ 个位置（不一定有序）
- **数据流中位数**：配合堆或直接用快速选择，处理静态数据
- **不适合动态数据**：数组会被原地修改，若需要保持原序需要拷贝

## 常见陷阱与注意事项

1. **原地修改**
   - 快速选择会**打乱原数组**，元素位置会被交换
   - 若需要保持原数组，必须先拷贝一份

2. **$k$ 的语义是下标还是排名**
   - 代码中 $k$ 是**下标**（1-based），$k=1$ 表示最小，$k=n$ 表示最大
   - 有些实现中 $k$ 是 0-based，需要根据题目要求调整

3. **最坏情况退化**
   - 三数取中虽大幅降低最坏情况概率，但并非完全避免
   - 若对最坏情况有严格要求，应使用 BFPRT（Median of Medians），保证 $O(n)$

4. **等于 pivot 的元素处理**
   - `A[ml] < q` 和 `A[mr] > q` 使用严格不等号，等于 pivot 的元素会被交换到两侧
   - 若用 `<=` 和 `>=`，等于 pivot 的元素会集中在一侧，可能导致退化

5. **`ml <= mr` 而非 `ml < mr`**
   - 当 `ml == mr` 时仍需交换（虽然交换自己），目的是让两个指针各自前进一步，否则会死循环

6. **整数溢出**
   - `l + (r - l) / 2` 而非 `(l + r) / 2`：避免大数相加溢出
   - 虽然 32 位下 `l + r` 不会溢出，但这是好习惯

## 对比与扩展

| 方法 | 平均时间 | 最坏时间 | 空间 | 特点 |
|---|---|---|---|---|
| **快速选择（本算法）** | $O(n)$ | $O(n^2)$ | $O(n)$ | 简单高效，原地修改 |
| 排序后取第 $k$ | $O(n \log n)$ | $O(n \log n)$ | $O(n)$ | 简单但慢，不破坏原序（需拷贝） |
| BFPRT（Median of Medians） | $O(n)$ | $O(n)$ | $O(n)$ | 最坏线性，但常数大 |
| 堆（维护大小为 $k$ 的堆） | $O(n \log k)$ | $O(n \log k)$ | $O(k)$ | 适合动态数据流 |
| 桶排序（值域小时） | $O(n + V)$ | $O(n + V)$ | $O(V)$ | 值域 $V$ 小时最快 |

### 扩展

- **BFPRT 算法**：将数组每 5 个分一组，取每组中位数的中位数作为 pivot，保证最坏 $O(n)$
- **C++ `nth_element`**：标准库的快速选择实现，`std::nth_element(first, nth, last)` 将第 $n$ 小的元素放到第 $n$ 个位置
- **Top-K 问题**：快速选择的划分可以直接把前 $k$ 小的元素放到数组前 $k$ 个位置（不保证有序），配合一次排序即可得到有序的前 $k$ 小
- **快速排序**：快速选择是快速排序的"半递归"版本——快速排序递归两半，快速选择只递归一半$AKB35$, '基础算法', array['分治', '快速选择', 'Quickselect', 'Top-K', '三数取中', '划分', '无序数组'], 'col-hub-basic-divide', null, 'knowledge'),
('world-needs-sunday', 'col-basic-radix-sort-k', 'k 进制基数排序', $AKB36$## 算法原理

基数排序（Radix Sort）是一种**非比较型**排序算法。它不通过元素间的比较来决定顺序，而是将每个数按"位"分解，从低位到高位依次进行**稳定排序**（通常是计数排序），最终得到有序序列。

### k 进制基数排序

传统的基数排序以 10 为基数（十进制），逐位排序。而 **k 进制基数排序**将每个数视为 k 进制数，按 k 进制的"位"进行排序。每次排序只看当前位的数字（范围 $0 \sim k-1$），用计数排序完成。

### 为什么从低位到高位

基数排序必须**从最低位到最高位**排序。原因是：高位比低位更重要，因此低位先排好序后，在排高位时，计数排序的稳定性会保留低位已排好的顺序。如果从高位开始排，就不能利用稳定性传递低位信息。

### 核心思想

1. 将所有数转为 k 进制表示
2. 对第 0 位（最低位）做计数排序
3. 对第 1 位做计数排序（稳定性保留第 0 位的顺序）
4. 重复直到最高位
5. 最终序列有序

## 核心公式

### 轮数计算

设 $n$ 个数中最大值为 $V_{\max}$，基数为 $k$，则排序轮数为：

$$
d = \lceil \log_k(V_{\max} + 1) \rceil
$$

代码中用除法代替对数：

$$
d = 1 + \left\lfloor \frac{V_{\max}}{k} \right\rfloor + \left\lfloor \frac{V_{\max}}{k^2} \right\rfloor + \cdots
$$

实际实现是不断除以 $k$ 直到为 0，统计轮数 $m$。

### 第 i 位的提取

$$
\text{digit}_i(x) = \left\lfloor \frac{x}{k^i} \right\rfloor \bmod k
$$

### 负数处理

代码用异或 `^ (1u << 31)` 将有符号整数映射为无符号整数：
- 最高位（符号位）翻转：负数变为大正数，正数仍为小正数
- 排序完成后再异或回来还原

## 算法步骤

### 预处理阶段（init 函数）

1. 将所有数异或 `(1 << 31)`，转为无符号整数（处理负数）
2. 找最大值 $V_{\max}$
3. 计算排序轮数 $m$：不断除以 $k$ 直到为 0

### 排序阶段（base_sort 函数）

对每一位 $i = 0, 1, \ldots, m-1$：

1. **计数**：统计每个位值（$0 \sim k-1$）出现的次数
2. **前缀和**：将计数数组转为前缀和，得到每个位值对应的输出位置
3. **放置**：从后往前遍历原数组，根据当前位值放入对应位置（保证稳定性）
4. **复制**：将临时数组复制回原数组
5. **进位**：`base *= k`，准备处理下一位

## 逐行代码解析

### 全局变量

```cpp
int n;                          // 元素个数
unsigned int m, k;              // 排序轮数 / 基数
vector<int> A;                  // 原始数组（有符号）
vector<unsigned int> tmp, cnt;  // 临时数组 / 计数数组
```

### init 函数：预处理

```cpp
void init(vector<unsigned int>& val)
{
    for (int i = 0; i < n; i++)
        val[i] = (unsigned int)A[i] ^ ((unsigned int)1 << 31);  // 负数映射
    unsigned int nmax = 0;
    tmp.assign(n, 0);
    cnt.assign(k, 0);
    for (int i = 0; i < n; i++) nmax = max(nmax, val[i]);  // 找最大值
    m = 1;
    while (nmax >= k)   // 计算轮数
    {
        nmax /= k;
        ++m;
    }
}
```

**关键点**：
- `^ ((unsigned int)1 << 31)`：将 int 的符号位翻转。负数最高位为 1，异或后变 0（变成小的无符号数）；正数最高位为 0，异或后变 1（变成大的无符号数）。这样负数 < 正数的顺序在无符号比较中得以保持
- `m` 的计算：最大值 $V_{\max}$ 除以 $k$ 的次数加 1，即 $V_{\max}$ 的 k 进制位数

### base_sort 函数：基数排序主体

```cpp
void base_sort()
{
    vector<unsigned int> val(n, 0);
    init(val);
    unsigned int base = 1;
    for (int i = 0; i < m; i++)           // 枚举每一位
    {
        for (int j = 0; j < k; j++) cnt[j] = 0;              // 清空计数
        for (int j = 0; j < n; j++) cnt[val[j] / base % k]++; // 统计当前位
        for (int j = 1; j < k; j++) cnt[j] += cnt[j - 1];     // 前缀和
        for (int j = n - 1; j >= 0; j--)                      // 逆序放置（保证稳定）
        {
            tmp[cnt[val[j] / base % k] - 1] = val[j];
            --cnt[val[j] / base % k];
        }
        for (int j = 0; j < n; j++) val[j] = tmp[j];          // 复制回原数组
        base *= k;                                             // 进位
    }
    for (int i = 0; i < n; i++)
        A[i] = val[i] ^ ((unsigned int)1 << 31);               // 还原为有符号
}
```

**逐段解读**：

| 代码段 | 含义 |
|--------|------|
| `val[j] / base % k` | 提取第 $i$ 位的数字（$0 \sim k-1$） |
| `cnt[j] += cnt[j-1]` | 前缀和，cnt[v] 变为"位值 $\le v$ 的元素个数" |
| `j = n-1; j >= 0; j--` | **逆序遍历**是保证稳定性的关键 |
| `tmp[cnt[...] - 1] = val[j]` | 根据前缀和确定的位置放入临时数组 |
| `--cnt[...]` | 放置一个后，该位值的下一个位置前移 |
| `base *= k` | 下一位的权重 |

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    cin >> n >> k;
    A.assign(n, 0);
    for (int i = 0; i < n; i++) cin >> A[i];
    base_sort();
    for (int i = 0; i < n; i++) cout << A[i] << ' ';
    return 0;
}
```

输入 $n$ 个数和基数 $k$，排序后输出。

## 复杂度分析

### 时间复杂度

$$
T(n, k, d) = O(d \cdot (n + k))
$$

其中 $d$ 是最大值的 k 进制位数，$k$ 是基数。

- 当 $k = n$ 时，$d \approx \log_n V_{\max}$，此时 $T = O((n + k) \log_n V_{\max}) = O(n \log_n V_{\max})$
- 当 $k$ 较大时（如 $k = 256$），轮数 $d$ 减少，但每次计数排序的常数增大
- 当 $k$ 较小时（如 $k = 2$），轮数 $d$ 增多，但每次计数排序很快

### 空间复杂度

$$
S(n, k) = O(n + k)
$$

- 临时数组 `tmp`：$O(n)$
- 计数数组 `cnt`：$O(k)$

## k 的选择策略

| k 值 | 轮数 d | 每轮代价 | 总代价 | 适用场景 |
|------|--------|---------|--------|---------|
| $k = 2$ | 最多（32轮） | $O(n+2)$ | $O(32n)$ | 数据范围小 |
| $k = 256$ | 4轮（32位整数） | $O(n+256)$ | $O(4n)$ | 通用排序，**最常用** |
| $k = 65536$ | 2轮 | $O(n+65536)$ | $O(2n)$ | 内存充足时最快 |
| $k = n$ | $\log_n V_{\max}$ | $O(2n)$ | $O(n \log_n V_{\max})$ | 理论最优 |

竞赛中 $k = 256$ 是最常用的选择，因为：
- 4 轮即可完成 32 位整数排序
- 计数数组仅需 256 个元素，缓存友好
- 每轮的 $n + 256$ 代价中，256 的常数可忽略

## 排序过程演示

以数组 `A = [3, 1, 4, 2, 5]`，$k = 3$ 为例（简化演示，不考虑负数处理）：

**最大值 5，轮数 m = 2（5 >= 3 → 5/3=1 >= 3? 否 → m=2）**

**第 0 轮（base = 1）：**

| 元素 | x % 3 |
|------|-------|
| 3 | 0 |
| 1 | 1 |
| 4 | 1 |
| 2 | 2 |
| 5 | 2 |

计数：cnt = [1, 2, 2] → 前缀和：cnt = [1, 3, 5]

逆序放置：
- 5 (位2) → tmp[4] = 5, cnt[2] = 4
- 2 (位2) → tmp[3] = 2, cnt[2] = 3
- 4 (位1) → tmp[2] = 4, cnt[1] = 2
- 1 (位1) → tmp[1] = 1, cnt[1] = 1
- 3 (位0) → tmp[0] = 3, cnt[0] = 0

结果：`[3, 1, 4, 2, 5]`（第 0 位已有序）

**第 1 轮（base = 3）：**

| 元素 | x/3 % 3 |
|------|---------|
| 3 | 1 |
| 1 | 0 |
| 4 | 1 |
| 2 | 0 |
| 5 | 1 |

计数：cnt = [2, 3, 0] → 前缀和：cnt = [2, 5, 5]

逆序放置：
- 5 (位1) → tmp[4] = 5
- 2 (位0) → tmp[1] = 2
- 4 (位1) → tmp[3] = 4
- 1 (位0) → tmp[0] = 1
- 3 (位1) → tmp[2] = 3

结果：`[1, 2, 3, 4, 5]` ✅ 有序

## 适用场景

1. **整数排序**：基数排序只能用于可按位分解的键值（如整数、字符串），不能用于浮点数
2. **大数据量排序**：当 $n$ 很大时，基数排序的 $O(d \cdot n)$ 优于比较排序的 $O(n \log n)$
3. **固定范围整数**：如 IP 地址排序、学号排序等
4. **需要稳定排序的场景**：基数排序的每一轮都是稳定排序，最终结果也是稳定的
5. **竞赛中的选择**：当需要比 `std::sort` 更快地排序大量整数时

## 常见陷阱与注意事项

1. **必须从低位到高位**：从高位开始排会丢失低位信息，无法保证正确性
2. **计数排序的稳定性**：每一轮的计数排序必须是**稳定的**。代码中逆序遍历（`j = n-1` 到 `0`）是保证稳定性的关键——相同位值的元素保持原来的相对顺序
3. **负数处理**：直接对负数取模或除法在 C++ 中行为不确定。代码用异或符号位的方式将所有数映射为无符号数，排序后再还原
4. **k 的选择**：$k$ 太小（如 2）轮数过多；$k$ 太大（如 $n$）计数数组太大。$k = 256$ 是 32 位整数的最佳选择
5. **整数溢出**：`base *= k` 在多轮后可能溢出。当 $k = 256$ 时，4 轮后 `base = $256^4 = 2^{32}$`，正好是 `unsigned int` 上限，不会溢出
6. **init 中的 m 计算**：当最大值为 0 时，`m = 1`，会执行一轮（实际上不需要排序，但执行一轮也不会出错）

## 与比较排序的对比

| 特性 | 比较排序（如 std::sort） | k 进制基数排序 |
|------|------------------------|---------------|
| 时间复杂度 | $O(n \log n)$ | $O(d(n+k))$ |
| 适用类型 | 任意可比较类型 | 仅限可按位分解的类型（整数等） |
| 稳定性 | std::sort 不稳定 | 稳定 |
| 空间 | $O(\log n)$（栈） | $O(n+k)$ |
| 常数 | 较小 | 中等 |
| 大 n 优势 | $\log n$ 增长 | $d$ 近似常数（$k=256$ 时 $d=4$） |

当 $n = 10^6$ 时：
- `std::sort`：约 $10^6 \times 20 = 2 \times 10^7$ 次比较
- 基数排序（$k=256$）：约 $4 \times 10^6$ 次操作

基数排序快约 5 倍。

## 扩展：字符串基数排序

基数排序也可用于字符串排序：将每个字符视为一个"位"，从最后一位字符开始向前排序。但由于字符串长度可变，需要处理空位（短的字符串在高位用 0 补齐）。$AKB36$, '基础算法', array['基础算法', '排序', '基数排序', '非比较排序', '计数排序', '位运算'], 'col-basic-bubble-select-sort', null, 'knowledge'),
('world-needs-sunday', 'col-basic-regret-greedy', '反悔贪心', $AKB37$## 算法原理

**一句话结论**：反悔贪心 = 先按某种局部贪心策略做决策，同时保留「撤销/替换之前决策」的通道；当发现新的选择更优时，用数据结构快速找到并撤销之前最差的决策，使当前局面重新变优。

**与普通贪心的区别**：

- 普通贪心：当前看起来最优就定死，不回头；
- 反悔贪心：当前先做一个不坏的选择，但允许以后"后悔"，把之前的某个决策替换掉。

**常见维护方式**：小根堆 / 大根堆、懒删除、双向链表 + 堆、状态数组、专门的「反悔代价」堆。本知识点的例题用「三个堆 + 状态数组」。

**例题模型**（USACO12FEB Cow Coupons G / 洛谷 P3045「牛券」；题号与出处来自思路笔记）：有 $N$ 件物品，第 $i$ 件原价 $P_i$、优惠价 $C_i$（保证 $C_i\le P_i$），你最多有 $K$ 张优惠券、总预算 $M$，每件最多买一次（用券花 $C_i$，不用券花 $P_i$），求最多能买多少件。

**普通贪心为什么不够**：

- $K=0$ 时普通贪心成立：没有优惠券则每件只花 $P_i$，按原价从小到大依次买即可（反证：把已买的便宜物品换成更贵的物品，总花费只增不减，不可能买到更多件）。
- $K\ge1$ 时单一价格排序失效。反例：5 件物品 $(P_i,C_i)=(2,1),(5,3),(50,40),(50,40),(100,20)$，预算 $M=100$、$K=1$。只按优惠价从小到大买：用券买 $(2,1)$ 花 1，原价买 $(5,3)$ 花 5、$(50,40)$ 花 50，共 56，剩 44，只买 3 件；更优方案是用券买 $(100,20)$ 花 20，再原价买 $(2,1)$、$(5,3)$、$(50,40)$ 共 77，能买 4 件。
- 「省得最多」也不一定好：物品 $(10000,100)$ 用券省 9900，但券后仍要掏 100；预算 100 时买它只得 1 件，不如买多件便宜货。**件数最大化看的是实际现金支出，不是账面优惠金额**——这是本题的核心观察。

**核心概念：反悔代价**。已用券物品 $i$ 实际花了 $C_i$；若把它的券收回、改成原价购买，需要补差价

$$d_i=P_i-C_i$$

由 $C_i\le P_i$ 知 $d_i\ge0$，收回券只会让已花现金变多、不会变少。$d_i$ 就是「收回这张券的代价」。

**两种「多买一件」的方案**（设当前已买若干件、券已用满 $K$ 张）：

- **方案 A（不用券）**：从未买物品中取原价最小者 $a$，新增花费 $P_a$；
- **方案 B（换券）**：从未买物品中取优惠价最小者 $b$ 用券买，但券已满，必须从已用券物品中收回一张——收回 $d_i$ 最小那张最划算；新增花费 $C_b+\min_i d_i$。

每次比较两者取较小者；若较小者都超过剩余预算，说明无法再多买一件，直接停止。

**正确性证明（不变量法）**。维护不变量：

> 在已买到 $t$ 件的所有方案中，当前方案的总花费最小。

- **券未满时**：直接用券买优惠价最小的 $b$，新增 $C_b$。因为 $C_b$ 是所有未买物品优惠价的最小值，且 $C_i\le P_i$ 蕴涵 $C_b\le C_a\le P_a$（$a$ 为原价最小者），所以 $C_b$ 就是「多买一件」的最小可能新增花费，不变量保持。
- **券已满时**：多买一件只有两类途径——原价买某件未买物品（最小 $P_a$），或收回一张旧券给新物品用券（最小 $C_b+\min_i d_i$）。两者取较小值即全局最小的新增花费。选择后总花费仍然是在「件数 +1」的所有方案中最小，不变量保持。
- **终止正确**：当前最小的新增花费都超过剩余预算时，任何方式都不可能再多买一件，故当前件数即最大件数。

本题的反悔点很典型：**反悔的不是"买不买"，而是"优惠券用在哪件物品上"**——被收回券的物品仍然已购买、只是改成原价，件数不减、只调整花费结构。

## 核心公式 / 状态定义与转移方程

**状态定义**（三个小根堆 + 状态数组）：

- 堆 $A$ 存 `(P[i], i)`：未买物品的**原价**小根堆，服务方案 A；
- 堆 $B$ 存 `(C[i], i)`：未买物品的**优惠价**小根堆，服务方案 B 的新物品；
- 堆 $T$ 存 `(P[i]-C[i], i)`：**当前已用券物品的反悔代价**小根堆；堆大小 = 当前用券数量；
- `vis[i]`：物品 $i$ 是否已购买（不区分原价还是用券）。

**反悔代价**：$d_i=P_i-C_i$（$C_i\le P_i$ 保证非负）。

**转移方程**（设 $a$ 为 A 顶物品、$b$ 为 B 顶物品）：

1. 券未满（`(int)T.size() < K`）：用券买 $b$，新增花费 $C_b$；`T.emplace(P[b]-C[b], b)`。
2. 券已满比较：

```text
if (P[a] < C[b] + T.top().first)   方案 A：原价买 a，新增 P[a]
else                               方案 B：换券，新增 C[b] + T.top().first
```

方案 B 的动作：新物品 $b$ 用券（`T.emplace(P[b]-C[b], b)`）、弹出 $T$ 顶（收回差价最小的旧券），用券数量保持 $K$ 不变。

3. 每轮结束：`if (w > M) break; else ++cnt;`——当前选的是「多买一件」的最小新增花费，最小者都超支则永远无法再多买。

**懒删除**：A、B 中会残留已买物品的旧条目，取堆顶后检查 `vis`，已买就弹出跳过：

```text
while (!A.empty() && vis[A.top().second]) A.pop();
while (!B.empty() && vis[B.top().second]) B.pop();
```

T 不需要大规模懒删除：T 中每个已用券物品恰好一条记录，收回券时直接 `T.pop()` 弹出该记录。

**手算示例（§算法原理的反例走一遍）**：$K=1,\ M=100$，物品 $(2,1),(5,3),(50,40),(50,40),(100,20)$。

- 券未满：用券买 B 顶 $(2,1)$，花 1，T 存差价 $(1, \text{物品}1)$。
- 券已满，比：A 顶 = $(5,3)$ 原价 5；B 顶 = $(5,3)$ 优惠价 3；换券成本 $3 + \min d_i = 3+1=4 < 5$ → 方案 B：买 $(5,3)$ 花 4（含收回物品 1 的券差价 1），T 换成差价 $(2, \text{物品}2)$。
- 再比：A 顶 $(50,40)$ 原价 50 vs 换券 $40 + 2 = 42$ → 方案 B，花 42（累计 47）。
- 再比：A 顶 $(50,40)$ 原价 50 vs 换券 $40 + 2 = 42$ → 方案 B，花 42（累计 89）。
- 再比：A 顶 $(100,20)$ 原价 100 vs 换券 $20 + 2 = 22$ → 方案 B，花 22（累计 111 > 100）→ 停止。共买 4 件。

本代码实测该输入输出 4。附加一组：$K=5,\ M=10$，三件 $(5,1)$ → 全用券买 3 件，实测输出 3。

## 逐行代码解析

代码拆成 4 个模块，按顺序拼接即完整程序。

### 模块 1 全局变量与初始化

```cpp
#include<bits/stdc++.h>
using namespace std;
priority_queue<pair<int,int>,vector<pair<int,int>>,greater<pair<int,int>>> A,B,T;
vector<int> P,C;
vector<bool> vis;
void init(int n)
{
	P.assign(n + 1,0);
	C.assign(n + 1,0);
	vis.assign(n + 1,false);
}

```

- 三个全局优先队列都是 `greater` 的小根堆：A 按键 $P_i$、B 按键 $C_i$、T 按键差价 $P_i-C_i$ 排序。
- `P`、`C` 用 `vector<int>` 存价格（输入保证不越 int），`vis` 标记已买。
- `init(n)` 统一分配并清零，多组数据时避免残留。

### 模块 2 读入与建堆

```cpp
int main()
{
	ios::sync_with_stdio(false);
	int N,K;
	long long M;
	cin >> N >> K >> M;
	init(N);
	for(int i = 1;i <= N;i++)
	{
		cin >> P[i] >> C[i];
		A.emplace(P[i],i);
		B.emplace(C[i],i);
	}
	
	
```

- 每件物品同时进入 A（原价键）和 B（优惠价键）两个堆——同一物品在两个堆中各有一条记录，这是后面必须懒删除的原因。
- T 初始为空：还没有任何物品用券。
- `w` 累计花费（`long long`，防溢出）、`cnt` 计已买件数（`int`）。

### 模块 3 主循环：懒删除 + 两种方案比较

```cpp
long long w = 0;
	int cnt = 0;
	while(!A.empty() && !B.empty())
	{
		int id_a = A.top().second;
		if(vis[id_a])
		{
			A.pop();
			continue;
		}
		
		int id_b = B.top().second;
		if(vis[id_b])
		{
			B.pop();
			continue;
		}
		
		if((int)T.size() < K)
		{
			B.pop();
			vis[id_b] = true;
			w += C[id_b];
			T.emplace(P[id_b] - C[id_b] , id_b);
		}
		else
		{
			//2种选择   1，选择原价 w += P[id_a]    2,选择优惠价 w += C[id_b] + T.top().first;
			if(P[id_a] < C[id_b] + T.top().first)
			{
				A.pop();
				vis[id_a] = true;
				w += P[id_a];
			}
			else
			{
				B.pop();
				vis[id_b] = true;
				w += C[id_b] + T.top().first;
				T.pop();
				T.emplace(P[id_b] - C[id_b],id_b);
			}
		}
		
		if(w > M) break;
		else ++cnt;
	}
	
```

- 先取 A 顶 `id_a`，若 `vis[id_a]` 已买则弹出 `continue`；B 顶同理——堆不能删中间元素，只能等旧条目浮到堆顶再懒删。
- 券未满分支：用券买 B 顶，`w += C[id_b]`，把差价压入 T。
- 券已满分支：比较 `P[id_a]` 与 `C[id_b] + T.top().first`；方案 A 原价买 A 顶（不动 T）；方案 B 换券（`w += C[id_b] + T.top().first`；`T.pop()` 收回旧券、`T.emplace(...)` 存入新券，用券数保持 K）。
- 注意方案 B 中被收回券的旧物品**仍然已买**，只是改为原价——它的代码动作只有「从 T 弹出」，`vis` 不变。
- 每轮最后 `w > M` 就 break——最小新增花费都超支，别的方案更不可能买得起。

### 模块 4 输出

```cpp
cout << cnt;
	return 0;
}
```

- 输出已买件数。答案 `cnt` 的上限是 $N$，用 `int` 即可。

## 复杂度分析

- **建堆**：$N$ 个元素分别进 A、B 两个堆，$O(N\log N)$。
- **主循环**：每件物品最多被购买一次；A、B 中每条记录（每堆 $N$ 条）最多被弹出一次，各 $O(N\log N)$；T 中每次换券弹一条压一条，共 $O(N\log N)$ 次堆操作；`vis` 查询 $O(1)$。总时间 $O(N\log N)$。
- **常数量级**：三个堆合计约 $4N$ 条记录、每条记录进出各至多一次，常数很小，$N=10^5$ 量级轻松通过。
- **空间**：P/C/vis 各 $O(N)$，三个堆合计 $O(N)$ 条记录，总 $O(N)$。

## 适用场景

**反悔贪心的通用模板（六步）**：

1. 先确定一个局部贪心策略；
2. 为每个已做决策记录「反悔代价」；
3. 用堆维护最小/最大反悔代价；
4. 新决策到来时，比较「直接做新决策的代价」与「撤销某个旧决策并做新决策的代价」；
5. 选择更优者；
6. 用懒删除维护已失效的堆元素。

**经典变形题（思路点名的四类，掌握模板后同套路迁移）**：工作安排、建筑抢修、最低加油次数、股票买卖反悔类——共同套路都是「当前先选，之后用堆后悔；后悔的代价要能被快速取出」。

**不要用**：没有后悔维度的纯贪心直接普通贪心（如 K=0 的按价购买）；「反悔代价」难以量化的场景（堆要求的可比较数值不存在时）；决策间有复杂依赖、撤销一个会影响一串的场景（不如直接 DP/网络流）。

## 常见陷阱与注意事项

1. **$K=0$ 未特判会访问空堆**：`T.size() < K` 为假进入 else，`T.top()` 对空堆取值是未定义行为。本代码依赖题目保证 $K\ge1$；若题目可能给 $K=0$，必须先特判（此时问题退化为纯按原价买：只走 A 堆，取原价最小的未买物品买到超支为止，思路笔记给了完整特判流程，此处只提示方向、不改代码）。
2. **「省得最多」的直觉陷阱**：件数最大化看实际现金支出，不是账面优惠金额；$(10000,100)$ 省 9900 但券后仍花 100，预算 100 时不如买一堆便宜货。
3. **按优惠价一直买的错觉**：券只有 $K$ 张，不能全用券；券用在哪会改变实际现金支出，必须靠换券比较来分配。
4. **反悔对象弄错**：本题反悔的是「优惠券用在哪」，不是「买不买」——被收回券的物品仍留在已买集合，只是改原价，件数不减。
5. **A、B 堆顶不一定是同一物品**：A 顶是原价最小、B 顶是优惠价最小，可能是两件不同的物品；比较的是两个方案各自的最小新增花费，各贡献 1 件，可以直接比。
6. **忘了懒删除**：A、B 里的旧条目必须靠 `vis` 检查弹出跳过，否则会把已买物品再算一遍。
7. **T 不记编号**：只存差价弹出时无法对应物品；存 `(P[i]-C[i], i)` 才稳妥通用（本题只用差价，但保留编号是通用写法）。
8. **券不一定用光**：用券数量至多 $\min(K,\text{最终买到的件数})$；预算只够 2 件时 $K=5$ 也只能用 2 张，代码里 T 未满即停止是正确行为。
9. **`w` 溢出**：累计花费用 `long long`；`P_i-C_i` 在 int 范围内但求和会溢出。
10. **「先买后踢最贵」的陷阱方案**：先买下新物品、超预算再踢已买最贵——净件数不变、又要在同件数状态下反复调整，破坏「买之前就比较新增花费」的简洁性，还需要第四个「已买物品实际花费最大」的大根堆。三个堆 + 事前比较的写法更清晰，不需要第四堆。
11. **常数与性能**：所有堆上记录进出各至多一次，常数小；不要画蛇添足把懒删除换成手写删除节点（复杂度与代码量双涨）。
12. **差价非负的前提**：$C_i\le P_i$ 是 $d_i\ge0$、反悔代价有意义的前提；题面若不保证要先排序检查。

## 对比与扩展

**与普通贪心对比**：

| 维度 | 普通贪心 | 反悔贪心 |
|---|---|---|
| 决策方式 | 当前最优定死，不回头 | 先做不坏的选择，留反悔通道 |
| 数据结构 | 往往排序即可 | 需要堆维护反悔代价 |
| 正确性工具 | 交换论证/反证 | 「同规模最小花费」不变量 |
| 适用 | $K=0$ 等无后悔维度的问题 | 优惠券分配、抢占式调度类 |

**两种实现思路的取舍**：

- **事前比较（本代码）**：买之前比较方案 A/B 的新增花费取较小者，反悔通过「收回最小差价旧券」完成；只需三个堆。
- **先买后踢（被否定的思路）**：先买新物品、超支再踢掉已买最贵——同一件事多绕一圈，还要维护第四个大根堆；在本模型的更优性论证下不必要。

**懒删除 vs 精确删除**：最小堆不支持任意中间元素删除，A/B 只能懒删除（`vis` + 堆顶跳过）；T 因「每个用券物品恰好一条记录、只从顶部收回」而天然精确。这个搭配是本题实现取舍的要点。

**本题的模板映射（把例题抽象回六步模板）**：

| 反悔贪心概念 | 本题对应 |
|---|---|
| 已做决策 | 某件物品用了优惠券 |
| 反悔代价 | $P_i-C_i$ |
| 反悔通道 | 差价小根堆 T |
| 直接新决策 | 原价买当前原价最小物品 |
| 撤销旧决策并新决策 | 收回最小差价旧券，给新物品用券 |
| 懒删除 | A、B 中已买物品弹出跳过 |
| 状态数组 | `vis` 标记已购买 |

**变形题名与迁移**：工作安排（抢占式调度反悔）、建筑抢修（时限下最大完成数）、最低加油次数、股票买卖反悔类——把「决策」换成这些题自己的对象、把「反悔代价」换成每题的量化值，六步模板原样套用；这些题名来自思路笔记，具体题号与题面未在本条目展开。$AKB37$, '基础算法', array['反悔贪心', '贪心', '堆', '懒删除', '优惠券', '不变量'], 'col-basic-greedy', null, 'knowledge'),
('world-needs-sunday', 'col-basic-shell-sort', '希尔排序（Shell Sort）', $AKB38$## 算法原理

希尔排序（Shell Sort）是插入排序的改进版本，由 Donald Shell 于 1959 年提出。核心思想是**先将整个数组按某个间隔（gap）分组，对每组做插入排序；然后逐步缩小间隔，重复分组排序；直到间隔为 1 时，整个数组已"基本有序"，最后做一次插入排序即可完成。**

### 插入排序的问题

普通插入排序的时间复杂度为 $O(n^2)$，在数组基本有序时接近 $O(n)$。但如果数组初始逆序很多，每个元素需要移动很多步，效率很低。

### 希尔排序的优化思路

希尔排序通过**大间隔的插入排序**先将数组变得"基本有序"，最后 gap=1 时再做一次完整的插入排序。由于前面的大间隔排序已经大幅减少了逆序对数量，最后一步插入排序的移动次数很少。

### 分组方式

以 `gap = n/2` 为例，下标为 `i` 的元素与下标为 `i + gap` 的元素在同一组：

- 第 0 组：`arr[0], arr[gap], arr[2*gap], ...`
- 第 1 组：`arr[1], arr[gap+1], arr[2*gap+1], ...`
- ...
- 第 gap-1 组：`arr[gap-1], arr[2*gap-1], ...`

每组内部做插入排序。由于间隔大，元素可以"一步跨越"很长距离，快速移动到大致正确的位置。

### 增量序列

本代码使用**希尔原始增量**：$gap = \lfloor n/2 \rfloor, \lfloor n/4 \rfloor, \lfloor n/8 \rfloor, ..., 1$。即每次 gap 减半。

不同的增量序列会影响时间复杂度，详见「对比与扩展」章节。

## 核心公式/状态定义与转移方程

### 增量序列

$$gap_k = \left\lfloor \frac{n}{2^k} \right\rfloor$$

其中 $k = 1, 2, 3, ...$，直到 $gap_k = 1$。

### 排序过程不变式

经过第 $k$ 轮（增量为 $gap_k$）排序后，数组满足：**对任意 $i$，$arr[i] \le arr[i + gap_k]$**（当 $i + gap_k < n$ 时）。即每间隔 $gap_k$ 的子数组是有序的。

当 $gap = 1$ 时，不变式退化为"整个数组有序"，即排序完成。

### 时间复杂度分析

希尔排序的时间复杂度取决于增量序列的选择：

| 增量序列 | 时间复杂度 |
|---------|-----------|
| 希尔原始（$n/2^k$） | $O(n^2)$ 最坏 |
| Hibbard（$2^k - 1$） | $O(n^{3/2})$ |
| Knuth（$(3^k - 1)/2$） | $O(n^{3/2})$ |
| Sedgewick | $O(n^{4/3})$ |

本代码使用的希尔原始增量在最坏情况下为 $O(n^2)$，但实际运行效率远好于普通插入排序，平均约为 $O(n^{1.3})$。

## 逐行代码解析

### 函数签名

```cpp
void shellsort(vector<int>& arr)
```

接收一个 `vector<int>` 的引用，原地排序，无返回值。

### 增量循环

```cpp
int n = arr.size();
for (int gap = n / 2; gap > 0; gap /= 2)
{
```

外层循环控制增量 gap，初始为 `n/2`，每次减半，直到 gap = 1。共 $\log_2 n$ 轮。

### 分组插入排序

```cpp
    for (int i = gap; i < n; i++)
    {
        int j = i - gap;
        int tmp = arr[i];
```

- `i` 从 `gap` 开始遍历到末尾（类似插入排序中从第 2 个元素开始）
- `j = i - gap` 是当前元素在同一组中的前一个位置
- `tmp = arr[i]` 暂存当前元素，为后移腾位置

这部分与插入排序高度相似，只是将插入排序中的 `1` 替换为 `gap`。

### 元素后移（插入核心）

```cpp
        while (j >= 0 && tmp < arr[j])
        {
            arr[j + gap] = arr[j];
            j -= gap;
        }
        arr[j + gap] = tmp;
```

- 向前（间隔 gap）查找插入位置
- 若 `arr[j] > tmp`，则将 `arr[j]` 后移 gap 位
- `j -= gap` 继续往前比较
- 找到位置后，将 `tmp` 放入 `arr[j + gap]`

与插入排序的唯一区别：步长从 1 变成了 gap。

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int n;
    cin >> n;
    vector<int> A(n);
    for (int i = 0; i < n; i++) cin >> A[i];
    shellsort(A);
    for (int i = 0; i < n; i++) cout << A[i] << ' ';
    return 0;
}
```

标准输入输出，读取 n 个整数，排序后输出。

## 复杂度分析

### 时间复杂度

最坏：$O(n^2)$（希尔原始增量，逆序数组）

平均：约 $O(n^{1.3})$

最好：$O(n \log n)$（数组已有序时，每轮只需比较不需移动）

**为什么平均更快**：大 gap 时每组元素少，插入排序快；gap 逐渐缩小时数组已接近有序，插入排序接近 $O(n)$。多轮排序的总工作量小于单次 $O(n^2)$ 插入排序。

### 空间复杂度

$$O(1)$$

仅用了几个辅助变量（gap, i, j, tmp），原地排序。

### 稳定性

希尔排序是**不稳定**的排序算法。因为相同值的元素可能在不同 gap 轮次中被移动到不同位置，相对顺序可能改变。

## 适用场景

### 适用

- **中等规模数据排序**：n 在几千到几万之间，希尔排序实现简单且性能不错
- **内存受限环境**：原地排序，空间复杂度 $O(1)$
- **教学与面试**：理解插入排序优化思路的经典案例
- **接近有序的数组**：gap 缩小时数组已基本有序，最后一步接近 $O(n)$

### 不适用

- **大规模数据**：n > $10^5$ 时应使用快速排序、归并排序等 $O(n \log n)$ 算法
- **需要稳定排序**：希尔排序不稳定，相同元素相对顺序可能改变
- **对性能要求极高的生产环境**：通常用 std::sort（内省排序）而非手写希尔排序

## 常见陷阱与注意事项

1. **数组下标从 0 开始**：代码中 `arr` 是 0-based，gap 分组从 `i = gap` 开始。如果你的数组是 1-based，需要相应调整边界

2. **gap 终止条件**：外层循环条件是 `gap > 0`，当 `gap = 1` 时执行最后一轮完整的插入排序。如果写成 `gap > 1`，会漏掉最后一步

3. **while 循环的 j 边界**：`j >= 0` 必须在 `tmp < arr[j]` 之前判断（短路求值），否则 j 为负数时会越界访问 `arr[j]`

4. **暂存变量 tmp**：必须先保存 `arr[i]` 的值再开始后移，否则后移过程中会覆盖原始值

5. **增量序列选择**：希尔原始增量（n/2 递减）实现最简单但性能一般。竞赛中如需更好性能可改用 Knuth 序列或 Sedgewick 序列

6. **稳定性**：不要在需要保持相等元素相对顺序的场景使用希尔排序。需要稳定排序应选择归并排序或直接插入排序

7. **与直接插入排序的关系**：gap=1 时希尔排序退化为普通插入排序。可以说插入排序是希尔排序的特例

## 对比与扩展

| 排序算法 | 平均时间 | 最坏时间 | 空间 | 稳定性 | 特点 |
|---------|---------|---------|------|--------|------|
| 插入排序 | $O(n^2)$ | $O(n^2)$ | $O(1)$ | 稳定 | 小数据、基本有序时快 |
| 希尔排序 | $O(n^{1.3})$ | $O(n^2)$ | $O(1)$ | 不稳定 | 插入排序的增量改进版 |
| 归并排序 | $O(n \log n)$ | $O(n \log n)$ | $O(n)$ | 稳定 | 稳定的 $O(n \log n)$ 排序 |
| 快速排序 | $O(n \log n)$ | $O(n^2)$ | $O(\log n)$ | 不稳定 | 实际最快的通用排序 |
| 堆排序 | $O(n \log n)$ | $O(n \log n)$ | $O(1)$ | 不稳定 | 原地 $O(n \log n)$，常数较大 |
| k 进制基数排序 | $O(n \times k)$ | $O(n \times k)$ | $O(n)$ | 稳定 | 非比较排序，整数专用 |

### 增量序列扩展

希尔排序的性能很大程度上取决于增量序列的选择：

**希尔原始增量**（本代码使用）：
$$gap_k = \lfloor n / 2^k \rfloor$$
实现最简单，但最坏 $O(n^2)$。

**Knuth 序列**：
$$gap_k = (3^k - 1) / 2$$
从大到小取小于 n 的值。时间复杂度约 $O(n^{1.5})$，竞赛常用。

**Sedgewick 序列**：
$$gap_k = 9 \times 4^k - 9 \times 2^k + 1 \quad \text{或} \quad 4^k - 3 \times 2^k + 1$$
时间复杂度约 $O(n^{4/3})$，性能更优但实现复杂。

### 扩展思考

希尔排序是**第一个突破 $O(n^2)$ 时间复杂度的排序算法**（虽然其最优增量序列的复杂度分析至今未完全解决）。它的核心思想——**通过预处理使数组接近有序，再用简单排序收尾**——启发了许多更高级的排序优化思路。$AKB38$, '基础算法', array['基础算法', '排序', '希尔排序', '插入排序', '增量序列'], 'col-basic-bubble-select-sort', null, 'knowledge'),
('world-needs-sunday', 'col-basic-sqrt-decomposition', '根号分治（无向图三元环计数）', $AKB39$## 算法原理

**一句话结论**：根号分治（sqrt decomposition）不是某一类固定算法，而是**复杂度分析的方法论**——设一个阈值 $B$，把对象按某种「规模」分成两类：一类数量多但单次处理便宜（暴力），一类数量少但单次处理贵（集中处理），让两部分复杂度在 $B=\sqrt{m}$ 处平衡，通常得到 $O(m\sqrt m)$。

**要解决的问题（例题）**：给定 $n$ 个点、$m$ 条边的简单无向图，数三元环个数。三元环指三个点 $u,v,w$，三条边 $(u,v)$、$(v,w)$、$(w,u)$ 都存在；三元环由点集决定，不区分边顺序。

**暴力起点**：枚举所有三点组检查三边是否齐全，$O(n^3)$。稀疏图里绝大多数三点组没有环，绝大部分枚举是无效的，需要换起点。

**从枚举边出发的思路**：固定一条真实边 $(u,v)$，第三个点 $w$ 必须同时与 $u,v$ 相邻，即 $w\in N(u)\cap N(v)$。于是枚举每条边、求两端邻接表交集。单条边代价是遍历度数较小的一端并在另一端 $O(1)$ 查询，即 $\min(\deg u,\deg v)$；总代价

$$S=\sum_{(u,v)\in E}\min(\deg u,\deg v)$$

**根号分治分析这个和**：取阈值 $B=\sqrt m$。

- 小边（$\min\le B$）：每条贡献不超过 $B$，共 $m$ 条，总贡献 $mB=O(m\sqrt m)$——单次便宜，允许暴力。
- 大边（$\min>B$，两端度数都 $>B$）：称度数 $>B$ 的点为「大点」，由度数和 $2m$ 可知大点个数 $k$ 满足 $k\cdot B\le 2m$，即 $k=O(\sqrt m)$；大边只在大点之间，每个大点作为较小端对应的另一端也只有 $O(\sqrt m)$ 个，总贡献 $O(\sqrt m)\cdot\sum\deg(x)=O(m\sqrt m)$——单次贵，但数量少，可集中处理。

两者平衡得 $S=O(m\sqrt m)$。这就是根号分治的典型模式：**小规模暴力打，大规模利用数量少，两边一凑就有根号**。

**为什么度数定向的做法是对的（不漏不重）**：把每条无向边按全序「先比度数、再比编号」定向为小点指向大点。一个三元环的三个点按全序排列为 $x<y<z$ 时，三条边定向后必然恰为 $x\to y$、$x\to z$、$y\to z$——每个三元环只以「最外点 $x$：一条二步路径 $x\to y\to z$ 加上标记确认 $x\to z$」这一种形式被统计一次，既不会漏也不会重复，因此答案就是满足「$x$ 指向 $y$、$y$ 指向 $z$、且 $x$ 也指向 $z$」的 $(x,y,z)$ 数。

**「分治」体现在哪**：代码里根本没有「大点/小点」集合，但复杂度证明中按度数把每个点分两种情况讨论——度数大则出邻居度数更大、把度数总和摊下去使出度受限于 $\sqrt{2m}$；度数小则出度不超过度数自然也小。**阈值 $\sqrt m$ 藏在分析里，代码通过「度数定向」这条规则隐式实现了分治**。这正是根号分治的重要特征：它不必是显式的数据分组。

## 核心公式 / 状态定义与转移方程

**规模度量与阈值**：本题的规模度量是「边的两端度数较小值」$\min(\deg u,\deg v)$；阈值 $B=\sqrt m$。

**定向规则（全序）**：对于边 $(u,v)$，若 $\deg u>\deg v$，或 $\deg u=\deg v$ 且 $u>v$，则交换 $u,v$，最终定向为 $u\to v$。即「全序小的点指向全序大的点」，全序先比度数、再比编号：

```text
if (deg[u] > deg[v] || (deg[u] == deg[v] && u > v)) swap(u, v);
out[u].push_back(v);
```

**出度上界引理**：设点 $u$ 的出度为 $d$，出邻居 $v_1,\dots,v_d$ 由定向规则满足 $(\deg v_i, v_i)>(\deg u,u)$，故 $\deg v_i\ge\deg u$，$d\cdot\deg u\le\sum\deg v_i\le 2m$。于是：

- 若 $\deg u\ge\sqrt{2m}$：$d\le 2m/\deg u\le\sqrt{2m}$；
- 若 $\deg u<\sqrt{2m}$：$d\le\deg u<\sqrt{2m}$。

所以每个点的出度是 $O(\sqrt m)$。

**计数转移**（对每个起点 $u$）：

- 先给 $u$ 的所有出邻打时间戳：`vis[j] = tim`；
- 再枚举 $u\to v$、$v\to w$，若 `vis[w] == tim` 则 $(u,v,w)$ 构成三元环，答案加一。

每个三元环只在其全序最外点 $x$ 处被统计一次。

**枚举总代价**：$\sum_u \text{outdeg}(u) + \sum_{u\to v}\text{outdeg}(v)$。第一项 $=m$；第二项中每个 $v$ 作为终点出现 $\text{indeg}(v)$ 次：

$$\sum_{u\to v}\text{outdeg}(v)=\sum_v \text{outdeg}(v)\cdot\text{indeg}(v)\le O(\sqrt m)\sum_v \text{indeg}(v)=O(m\sqrt m)$$

**手算示例**：$n=4$，边 $(1,2),(2,3),(3,1),(3,4)$。度数：$\deg=(2,2,3,1)$。

- 定向：$(1,2)$ 度同、编号小者出 → $1\to2$；$(2,3)$ → $2\to3$；$(3,1)$：$\deg 3=3>2$ 交换 → $1\to3$；$(3,4)$：$\deg 3=3>1$ 交换 → $4\to3$。出边表：$1:[2,3]$，$2:[3]$，$3:[]$，$4:[3]$。
- 计数：$u=1$，给 2、3 打时间戳 1；走 $1\to2$，$2$ 的出边到 3，`vis[3]==tim` → 计数 1（三角形 1,2,3）；走 $1\to3$，3 无出边。其余 $u$ 加不出新环。答案 1。

经本代码实测：该输入输出 1。附加两组：$n=5$ 六条边（1-2-3 与 1-4-5 两个三角形）输出 2；$n=3$ 全连三角形输出 1。

## 逐行代码解析

代码拆成 3 个模块，按顺序拼接即完整程序。

### 模块 1 全局变量与初始化

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> deg,vis;
vector<pair<int,int>> edges;
vector<vector<int>> A;
int tim = 0;
void init(int n, int m)
{
	edges.assign(m + 1, {});
	deg.assign(n + 1, 0);
	vis.assign(n + 1, 0);
	tim = 0;
	A.assign(n + 1, vector<int>());
}

```

- `deg` 存每个点的度数、`vis` 是带时间戳的标记数组、`edges` 按边下标 $1\sim m$ 存边、`A` 是定向后的出边表。
- `edges.assign(m + 1, {})`：边下标 1 到 m，容量必须是 $m+1$（若是「每个点一个邻接表」则要 $n+1$，两种容量千万别混）。
- `vis.assign(n + 1, 0)` + `tim = 0`：时间戳标记的准备，避免每轮清空数组的 $O(n)$ 开销。

### 模块 2 读入、定向建出边表

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n, m;
	cin >> n >> m;
	init(n, m);
	for (int i = 1; i <= m; i++)
	{
		cin >> edges[i].first >> edges[i].second;
		++deg[edges[i].first];
		++deg[edges[i].second];
	}

	//如果都成两个方向的边，然后再记录是否根据顺序重复等等等等常数会爆炸。
	//所以说能不要的就先不要了，就记录所有满足deg[u] > deg[v] || (deg[u] == deg[v] && u > v)的边。
	//然后就搜索u，那可以从u找到v，v找到w。这样子这个过程就没有额外的消耗了。然后再加上时间戳，就可以把常数加到一个可以接受的地步。
	for (int i = 1; i <= m; i++)
	{
		int u = edges[i].first;
		int v = edges[i].second;
		if (deg[u] > deg[v] || (deg[u] == deg[v] && u > v)) swap(u, v);
		A[u].emplace_back(v);
	}

	
```

- 先读入全部边并顺手累计度数——定向前必须知道所有点的完整度数，所以边要存下来，不能边读边定向。
- 定向规则一行：`deg[u] > deg[v] || (deg[u] == deg[v] && u > v)` 时交换，保证 `u` 是全序更小的端点；然后只建单向边 `A[u].push_back(v)`，不要双向都建（双向会让每个三元环被重复计数）。
- 注释里记录了选这个写法的动机：双向记录 + 记录顺序去重会让常数爆炸；只保留满足定向条件的边再加上时间戳，常数才可控。

### 模块 3 时间戳计数主循环

```cpp
long long cnt = 0;
	for (int i = 1; i <= n; i++)
	{
		++tim;
		for (int j : A[i]) vis[j] = tim;

		for (int j : A[i])
		{
			for (int w : A[j])
			{
				if (vis[w] == tim) ++cnt;
			}
		}
	}
	cout << cnt;
	return 0;

}
```

- `++tim` 每个 $u$ 换一个新时间戳，等价于「一键清空标记」。
- 第一遍遍历 $A[u]$ 给所有出邻打标；第二遍再遍历 $A[u]$，对每个 $v$ 枚举其出邻 $w$——这枚举的是「$u\to v\to w$ 的长度 2 路径」，配上前一步的标记就等价于查询「$u\to w$ 是否存在」。
- 内层枚举的一定是 $v$ 的出表（而非 $u$ 的邻接表），否则既慢又容易错。
- `long long cnt`：三角形个数可能达到 $O(m\sqrt m)$ 级别，超 int。

## 复杂度分析

- **时间**：$O(m\sqrt m)$。用出度上界引理：每个点出度 $O(\sqrt m)$；主循环总代价 $\sum\text{outdeg}(u)+\sum_{u\to v}\text{outdeg}(v)\le m+O(\sqrt m)\cdot m=O(m\sqrt m)$。若用「枚举边 + 交集」的视角，同样由小边/大边的根号分类得到 $S=O(m\sqrt m)$，两种理解殊途同归。
- **空间**：$O(n+m)$——`deg/vis` 各 $n+1$、边数组与出边表共 $O(m+n)$。
- **数值**：答案量级 $O(m\sqrt m)$（如 $m=10^5$ 时约 $3\times10^7$ 量级），`int` 勉强但习惯上用 `long long` 更安全。

## 适用场景

- **无向图三元环计数**：本模板直接套用（$n,m$ 十万元素级稀疏图）。
- **度数不平衡图的统计**：一切「两端邻接表求交」的边统计问题，都可用根号分治分析：单条边代价是 $\min(\deg u,\deg v)$，总和 $O(m\sqrt m)$。
- **广义根号分治**：把「规模」换成出现次数、区间长度、数值大小等，凡是「小规模暴力 + 大规模数量少」能平衡的问题都可套用该分析法。
- **不要用 / 换做法**：图较稠密且 $n$ 中等时，bitset 存邻接 + 每条边 `&` 再 `count()` 是 $O(mn/64)$、代码更短，但空间 $O(n^2/64)$，大稀疏图不如根号分治；需要应对删边/动态修改时本模板不适用。

## 常见陷阱与注意事项

1. **定向条件写反**：必须是度数小的指向度数大的（度同时比编号小的）——写成大指小全盘皆错，会漏统计或重复统计。
2. **双向都建边**：出边表只存单向；双向会让同一路径从两个方向各算一次。
3. **内层遍历错了表**：找第三个点应枚举「$v$ 的出边」再回查 $u$ 的标记；枚举 $u$ 的邻接表会既不快又出错。
4. **用编号比较代替全序**：去重条件若写成 `w > max(u,v)` 之类，与定向使用的「先度数后编号」全序不一致，结果会错；用定向出边表 + 标记数组可完全避开显式去重条件。
5. **`edges` 容量用错**：按边存开 $m+1$，按点存邻接表开 $n+1$，两种下标空间混用会越界。
6. **`unordered_set` 求交**：没有 `operator[]`（`vis[j][w]` 是编译错误），且哈希常数大；判断邻接用「标记数组 + 时间戳」是 $O(m\sqrt m)$ 的最优实现，既快又免清空。
7. **`int` 存答案**：三元环个数可达 $O(m\sqrt m)$，务必 `long long`。
8. **先定向后度才能定**：必须先把所有边读齐、度数统计完整，再统一定向；边读边定向会因为度数不全而定向错误。
9. **bitset 别乱套**：bitset 邻接矩阵 $O(mn/64)$ 只适合中等稠密图，空间 $O(n^2/64)$；稀疏大图老老实实用根号分治。

## 对比与扩展

**两种等价理解**：

| 视角 | 特点 |
|---|---|
| 枚举边求邻接表交集 | 思路直接，但需要 $O(1)$ 邻接查询（哈希/矩阵/bitset） |
| 按度数定向 + 时间戳标记 | 代码简洁、只建单向出边表、无需额外结构 |

两者依赖同一个结论：定向后出度 $O(\sqrt m)$，因此度数定向写法更推荐。

**与数论分块的区别**：都带「分块分析」的味道但不是一回事——数论分块利用 $\lfloor n/i\rfloor$ 只有 $O(\sqrt n)$ 种取值、把连续区间合并处理；根号分治是按阈值把对象分成小规模/大规模两类分别设计算法。前者作用于「函数值域的分段」，后者作用于「对象的规模分层」。

**根号分治的三条主线**：找一个规模度量 → 取阈值 $B=\sqrt m$ 分小/大 → 分别估计让两部分平衡。阈值取 $\sqrt m$ 不是玄学：小边代价 $mB$ 与大边代价 $m\cdot(2m/B)$ 恰好在 $B=\sqrt m$ 处相遇。

**扩展方向**：三元环计数的进一步应用常见于「社交网络三角计数」「竞赛图/无向图环结构统计」等；更大环（四元环）的计数有对应技巧但不属于本模板的直接推广（本模板的核心仍是「度数定向 + 根号分析」这个思维框架）。$AKB39$, '基础算法', array['根号分治', '三元环', '图论', '度数定向', '复杂度平衡'], null, null, 'knowledge'),
('world-needs-sunday', 'col-basic-ternary-search', '三分法（求单峰函数极值）', $AKB40$## 算法原理

解决的问题：在区间 $[L,R]$ 上求**单峰函数**的极值点横坐标。典型应用是洛谷 P3382 类模板题：给定一个 $n$ 次多项式，且保证其在 $[L,R]$ 上先增后减（存在唯一极大值点），求该极大值点的横坐标。

核心思想：二分查找靠「中点与目标比较」排除一半区间，但求极值时**没有目标值可比较**——单点信息无法判断极值在哪一侧。三分法改成取两个等分点：

$$
m_1=L+\frac{R-L}{3},\qquad m_2=L+\frac{2(R-L)}{3}
$$

比较 $f(m_1)$ 与 $f(m_2)$：

- 若 $f(m_1)<f(m_2)$：$m_1,m_2$ 都在上升段，或 $m_1$ 在上升段、$m_2$ 已越过峰值。无论哪种情况，**极大值点都在 $m_1$ 的右侧**（严格证明见下），于是舍去左段，令 $L=m_1$；
- 若 $f(m_1)\ge f(m_2)$：对称地，极大值点在 $m_2$ 的左侧，舍去右段，令 $R=m_2$。

每轮区间长度乘 $\frac{2}{3}$，直至 $R-L$ 小于精度阈值，取中点输出。

**为什么舍去是安全的**：设极大值点为 $x_0$。若 $f(m_1)<f(m_2)$，反证：假设 $x_0<m_1$，则 $m_1$ 在**下降段**上（$x_0$ 左侧上升、右侧下降），由 $m_1<m_2$ 且两者都在下降段推出 $f(m_1)>f(m_2)$，与条件矛盾。故 $x_0>m_1$，左段 $[L,m_1]$ 可以放心舍去。$f(m_1)\ge f(m_2)$ 一侧同理。这个论证只用到了「单峰」——先严格递增、后严格递减，不要求可导。

模板（求极大值；极小值把比较方向反过来即可）：

```
while (R - L > eps):
    m1 = L + (R - L) / 3
    m2 = L + (R - L) / 3 * 2
    if f(m1) < f(m2): L = m1
    else:             R = m2
输出 (L + R) / 2
```

## 核心公式 / 状态定义与转移方程

**区间状态**：$[L,R]$ 始终满足「极大值点 $x_0\in[L,R]$」，这是三分法的不变量。初始为题目给定的区间；每轮按比较结果收缩到 $[m_1,R]$ 或 $[L,m_2]$。

**两点位置**：

$$
m_1=L+\frac{R-L}{3},\qquad m_2=L+\frac{2(R-L)}{3}
$$

**收缩规则**（求极大值）：

$$
L\gets m_1\ \ (\text{当 } f(m_1)<f(m_2)),\qquad R\gets m_2\ \ (\text{否则})
$$

**目标函数**（本代码的多项式求值）：

$$
f(x)=\sum_{i=0}^{n}k_i x^i
$$

代码用递推求值：`t` 依次取 $1,x,x^2,\dots$，每步 `ans += t * k[i]`，一次乘一次加累加出 $f(x)$。

**迭代次数**：每轮区间缩到原来的 $\frac{2}{3}$，达到精度 $eps$ 需要的轮数

$$
k=\left\lceil \log_{3/2}\frac{R-L}{eps} \right\rceil
$$

如区间长 $1$、$eps=10^{-8}$，约 $\log_{1.5}10^8\approx 45$ 轮；区间更大或精度更高时也就 60~100 轮，常数极小。

## 逐行代码解析

### 模块一：全局系数数组与多项式求值 `fn`

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<long double> k;
long double fn(long double x,int n)
{
	long double t = 1,ans  = 0;
	for (int i = 0; i <= n; i++)
	{
		ans += t * k[i];
		t *= x;
	}
	return ans;
}
```

- `k[i]` 存 $x^i$ 的系数：`k[0]` 是常数项、`k[1]` 是一次项系数、`k[n]` 是最高次项系数；读入时按「从高次到低次」倒序存（见模块二）。
- `fn` 里 `t` 维护 $x^i$ 的幂：初始 `t=1`，每轮 `ans += t*k[i]` 累加一项、`t *= x` 升到下一幂次，整体就是霍纳式逐项累加。
- 全程 `long double`：多项式的值可能很大或很小，`long double` 比 `double` 多几位有效数字，求极值点更稳；一般题目 `double` 也够，但 `long double` 没有额外代价。

### 模块二：`main` 读入与三分循环

```cpp
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int n;
	long double L, R;
	cin >> n >> L >> R;
	k.assign(n + 1, 0);
	for (int i = n; i >= 0; i--) cin >> k[i];
	while (R - L > 1e-8)
	{
		long double l = L + (R - L) / 3;
		long double r = L + (R - L) / 3 * 2;
		if (fn(l, n) < fn(r, n)) L = l;
		else R = r;
	}
	cout << (L + R) / 2;
	return 0;
}
```

- `for (int i = n; i >= 0; i--) cin >> k[i];`：题目按 $a_n,a_{n-1},\dots,a_0$ 给系数，倒序读入后 `k[i]` 恰好是 $x^i$ 的系数，与 `fn` 的约定对齐。
- `long double l = L + (R - L) / 3;` 与 `r = L + (R - L) / 3 * 2`：两个三等分点。`/ 3 * 2` 乘除同级从左到右，等价于 $L+\frac{2(R-L)}{3}$，语义正确。
- `if (fn(l, n) < fn(r, n)) L = l; else R = r;`：三分核心比较——左点低于右点说明极值在右，舍左段；否则舍右段。
- `while (R - L > 1e-8)`：区间长度未达到 $10^{-8}$ 就继续收缩；循环条件**必须是大步继续**（`>` 而非 `<=`），写反会变成「区间足够小时才循环」，直接死循环或一次不跑。
- `cout << (L + R) / 2;`：默认输出 6 位有效数字。这类题只要求答案与标准值的绝对/相对误差不超过 $10^{-5}$，6 位有效数字已经覆盖，无需额外 `fixed << setprecision`。

## 复杂度分析

- **时间复杂度**：每轮收敛 $\frac{2}{3}$，轮数 $O(\log_{3/2}((R-L)/eps))$；每次调用 `fn` 是 $O(n)$。总复杂度 $O(n\log((R-L)/eps))$，实际轮数只有几十轮，极快。
- **空间复杂度**：只存系数数组 $k$，$O(n)$。

## 适用场景

- **单峰函数的极值**：凸函数（求极小）、凹函数（求极大）、以及不光滑但单峰的折线函数——三分不要求可导，只要求先单调增后单调减（或反之）。
- **导数难求或不可导的最优化**：表达式复杂、求导再解方程成本高时，直接三分求数值解最省事。
- 不适用：区间上有多个极值（多峰函数）——三分会把真极值所在段舍掉；此时需要模拟退火、爬山 + 随机重启等全局方法。

## 常见陷阱与注意事项

1. **循环条件写反**：`while (R - L > 1e-8)` 是「区间不够小就继续」；写成 `<=` 语义完全相反，常见症状是死循环或直接输出初值。
2. **极小值与极大值的比较方向**：求极大用 `f(l) < f(r) → L = l`；求极小要把不等号反过来（`f(l) > f(r) → L = l`）。方向记混会在上升段/下降段上做出相反的收缩。
3. **系数顺序**：题目给的是 $a_n\to a_0$，必须倒序存入；不倒序会让 `k[i]` 张冠李戴，函数值全错但三分照样「收敛」到一个假极值。
4. **eps 与题目精度匹配**：eps 取答案要求精度的 $10^{-3}$ 倍左右即可（如要求 $10^{-5}$ 用 $10^{-8}$）；eps 过大精度不足，过小徒增轮数，`long double` 下推到 $10^{-12}$ 以下还可能因精度耗尽而不收敛。
5. **输出格式**：默认浮点输出是 6 位有效数字，能满足 $10^{-5}$ 以内的误差要求；只有当题目明确要求「保留 $k$ 位小数」时，才加 `fixed << setprecision(k)`。
6. **两端点的初始化**：`L、R` 必须保证极值点在区间内部；若极值恰好在端点或区间外，三分的收缩仍会收敛到端点，但前提判断可能失效，要先确认题面保证。
7. **对非单峰函数误用三分**：多峰函数上三分可能丢掉全局极值。判断不了单峰性时，先用足量采样观察函数形状，或改用随机化方法。

## 对比与扩展

| 方法 | 利用的信息 | 适用对象 | 每轮收敛 |
|---|---|---|---|
| 二分查找 | 中点与目标值的比较 | 单调判别式问题 | $\frac{1}{2}$ |
| 三分法 | 两个三等分点互相比较 | 单峰函数极值 | $\frac{2}{3}$ |
| 牛顿法 | 一阶/二阶导数 | 光滑可导函数 | 二次收敛 |

- **三分与二分的关系**：二分排除一半、有明确目标值；三分排除三分之一、没有目标值只能靠两点互相比较。两者都是「保持不变量（解仍在区间内）、按每轮信息收缩」的区间分治。
- **分数规划 / 凸函数优化**里三分常作子过程；「三分套三分」可推广到二维凸函数（外层三分 $x$、内层三分 $y$）。
- **相关知识点**：本库「模拟退火」系列（`basic-random-sa-point` 等）解决的是**多峰/无单峰保证**场景下的全局优化，与三分各管一段；「快速幂 / 多项式求值」可给本知识点提供更快的霍纳求值方式。$AKB40$, '基础算法', array['三分法', '单峰函数', '浮点二分', '数值方法', '多项式求值'], 'col-hub-basic-divide', null, 'knowledge'),
('stripe-python', 'col-basic-tricks-dp--stripe-python', 'DP 与计数技巧合集（耳分解 / 补集转化 / 贡献拆解） · stripe-python', $AKB41$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 14. $(★★★★)$ 耳分解 DP

> > *补充定义和性质：*  
> > *对于一个（强）连通图 $G$，其「耳」是一条**简单路径**（这也被称作「开耳」）或**简单环**。*  
> > *一张图是「可耳分解」的，当且仅当可以每次从中删去一个耳，并且最终所有边都被删除。这一过程被称作「耳分解」。*  
> > 1. *一张**有向图**是「可耳分解」的，当且仅当它**强连通**。*  
> > 2. *一张**无向图**是「可耳分解」的，当且仅当它**边双联通***。
> >
> > ***如果要对于一个图的强连通（边双连通）子图求解，可以考虑对其耳分解。***

### 例 14-1. [Luogu P5776. Quare](https://www.luogu.com.cn/problem/P5776)
> 给定一个 $n$ 点 $m$ 边无向带权图，最大化其边双连通子图的边权和。  
> $1\le n\le 12,1\le m\le 40$。

考虑用状压 dp 逐渐加入耳。

记 $f_{S,i,j}$ 表示点集 $S$ 加入耳分解，且不完整的那个耳的最后一个节点为 $i$，该耳最后连向 $j$ 的最小代价。

然后直接做即可。

时间复杂度 $O(2^nn^3)$。

---

## 17. $(★★★)$ 基于决策强制性的 DP 状态

> ***正常的描述决策的 DP 状态为 $\bm{f_{i,0/1}}$ 表示决策 $\bm i$ 选或不选，有时出于一些特殊原因，这样设状态反而不太好做，可以改用 $\bm{f_{i,0/1}}$ 表示决策 $\bm i$ 是否强制选（不选）。***

### 例 17-1. [CF808G. Anthem of Berland](https://codeforces.com/problemset/problem/808/G)

> 给定两个小写字母构成的字符串 $s,t$，其中 $s$ 还可能有字符 $\texttt ?$，将每个 $\texttt ?$ 替换为一个任意小写字母后，最大化 $t$ 匹配 $s$ 的次数。  
> $1\le |s|,|t|\le 10^5,1\le |s|\cdot|t|\le 10^7$。

考虑描述一个前缀的后缀是否被 $t$ 匹配，记 $f_{i,0/1}$ 表示 $s$ 的最后 $|t|$ 个字符是否被 $t$ 匹配的最大匹配次数。

这个应该也是好做的，本题先用来感受一下决策强制性的 dp 状态。

考虑换一种 dp 状态含义：$f_{i,0/1}$ 表示 $s$ 的最后 $|t|$ 个字符是否**强制**被 $t$ 匹配的最大匹配次数。

$\gdef\bd{\text{bd}}$

记长度为 $i$ 的前缀的 border 长度为 $\bd_i$。

对于 $f_{i,0}$，显然有 $f_{i,0}=\max\{f_{i-1,0},f_{i,1}\}$。

对于 $f_{i,1}$，我们初始有 $f_{i,1}=f_{i-m,0}+1$，然后可以容易地转移，有 $f_{i,1}\upd{max}\max\limits_{j\in S}\{f_{i-m+j,1}\}+1$，其中 $S=\{\bd_m,\bd_{\bd_m},\bd_{\bd_{\bd_m}},\cdots\}$。

匹配可以直接暴力匹配，时间复杂度 $O(|s|\cdot|t|)$。

### 例 17-2. [Luogu P8352. 小 N 的独立集](https://www.luogu.com.cn/problem/P8352)

> 给定一棵 $n$ 个节点的树，每个节点需要钦定一个点权 $[1,k]$，对于所有 $k^n$ 种不同情况，求最大权独立集为 $[1,nk]$ 的分别有多少种情况。答案对 $10^9+7$ 取模。  
> $1\le n\le 10^3,1\le k\le 5$。

首先最朴素的 dp 为 $f_{x,0/1}$ 表示节点 $x$ 的子树，是否选 $x$ 的最大权独立集。时间复杂度 $O(nk^n)$。

注意到由于 $k$ 非常小，$nk$ 仍然是一个很小的数字，我们考虑 dp of dp，将 $f_{x,0/1}$ 作为状态，设 $f_{x,i,j}$ 表示 $x$ 的子树中 $f_{x,0}=i,f_{x,1}=j$ 的方案数。

枚举 $x$ 的儿子 $y$，枚举状态 $(i,j,p,q)=(f_{x,0},f_{x,1},f_{y,0},f_{y,1})$ 对应的答案。那么有转移式 $f_{x,i+\max\{p,q\},j}\upd+f_{x,i,j}\cdot f_{y,p,q}$。时间复杂度 $O(n^4k^4)$，并且远达不到。

但这仍然无法解决题目。

我们考虑改变 $f_{x,0/1}$ 的含义：$f_{x,0/1}$ 表示节点 $x$ 的子树，是否**强制不选** $x$ 的最大权独立集。

强制不选只会影响节点 $x$ 的差值，故有 $0\le f_{x,0}-f_{x,1}\le k$。那么可以重新设 $f_{x,i,j}$ 表示 $x$ 的子树中 $f_{x,0}=i+j,f_{x,1}=i$ 的方案数。

同理枚举 $x$ 的儿子 $y$，枚举状态 $(i+j,i,p+q,p)=(f_{x,0},f_{x,1},f_{y,0},f_{y,1})$ 对应的答案。那么有转移式 $f_{x,i+p+q,\max\{j-q,0\}}\upd+f_{x,i,j}\cdot f_{y,p,q}$。

时间复杂度 $O(n^2k^4)$。

### 练习 17
- [Luogu P9090. G64](https://www.luogu.com.cn/problem/P9090)

---

## 18. $(★★)$ 补集转化

> ***限制某一个子集的条件时，可以考虑其补集。***
>
> *常见的补集转化如：独立集 & 点覆盖。*

### 例 18-1. [Luogu P9036. 挑战 NPC Ⅲ](https://www.luogu.com.cn/problem/P9036)

> 求一个 $n$ 点 $m$ 边的无向图中大小恰好为 $n-k$ 独立集数量。将答案对 $998244353$ 取模。  
> $1\le n\le 10^5,0\le m\le 10^5,0\le k\le\min\{n-1,18\}$。

原问题可以转化为大小恰好为 $k$ 的点覆盖计数。

首先，对于一个度数 $>k$ 的节点，我们必然是会选择的，否则为了覆盖与它相连的边，我们必须把这些边另外的 $>k$ 的点都选中，这就和恰好选 $k$ 个矛盾了。

其次，进一步地，我们这样剩下来所要覆盖的边的条数不超过 $k^2$，如果超过了，自然就无解。

这样的话，我们就剩下了 $O(k^2)$ 条边。

记 $a_i$ 表示节点 $i$ 被选的状态：
- $0$ 表示未确定。
- $1$ 表示一定被选入点覆盖集。
- $2$ 表示一定不被选入点覆盖集。

考虑爆搜。记 $\text{dfs}(x,r)$ 表示已经选择了 $x$ 个点加入点覆盖集，还剩下 $r$ 个点没有被确定。

那么，首先找到一条没有被覆盖的边 $(u,v)$。
- 若所有边当前已经被恰好覆盖了，那么只要让剩下还没选的随便选即可，即答案加上 $\binom{r}{k-x}$。
- 若 $a_u=a_v=2$，那么这是不合法的，直接跳出。
- 若 $a_u=0,a_v=2$，那么令 $a_u=1$，进入 $\text{dfs}(x+1,r-1)$。
- 若 $a_u=2,a_v=0$，那么令 $a_v=1$，进入 $\text{dfs}(x+1,r-1)$。
- 若 $a_u=a_v=0$，那么依次地：
  - 令 $a_u=a_v=1$，进入 $\text{dfs}(x+2,r-2)$。
  - 令 $a_u=1,a_v=2$，进入 $\text{dfs}(x+1,r-2)$。
  - 令 $a_u=2,a_v=1$，进入 $\text{dfs}(x+1,r-2)$。

最后注意处理重边的情况。

时间复杂度为 $O(T(k)k^2)$，其中 $T(k)=2T(k-1)+T(k-2)$，大约为 $O(2^kk^2)$，跑不满。

此外还有一种做法。

我们继续考虑每个点的度数。

- 若 $\max\{\deg_i\}\le 2$，那么图包含环或链，这是容易处理的。
- 若 $\max\{\deg_i\}>2$，那么递归时每次选择度数最大的往下做。

这样就可以做到 $T(k)=T(k-1)+T(k-3)$。

### 练习 18
- [Luogu P9257. Mędrcy](https://www.luogu.com.cn/problem/P9257)

## 33. $(★★★)$ 贡献和转积的一次项系数

> ***对于一些不好计算的贡献和，如果乘积是容易算的，可以考虑将原贡献 $\bm w$ 变为一次多项式 $\bm{wx+1}$，最后取一次项的系数即可。***

### 例 33-1. [Luogu P6624. 作业题](https://www.luogu.com.cn/problem/P6624)

> 给定 $n$ 点 $m$ 边的无向带权图，编号为 $i$ 的边的边权为 $w_i$，定义其生成树 $T=\{e_i\}$ 的价值 $f(T)=\left(\sum\limits_{i=1}^{n-1}w_{e_i}\right)\cdot\gcd\limits_{i=1}^{n-1}\{w_{e_i}\}$。求 $\sum f(T)$。  
> $1\le n\le 30,1\le m\le\frac{n(n-1)}2,1\le w_i\le 152501$。

首先欧拉反演化简一下式子：

$$
\begin{aligned}
&\sum f(T)\\
=&\sum\limits_{T}\left(\sum\limits_{i=1}^{n-1}w_{e_i}\right)\cdot\gcd\limits_{i=1}^{n-1}\{w_{e_i}\}\\
=&\sum\limits_{T}\left(\sum\limits_{i=1}^{n-1}w_{e_i}\right)\cdot\sum_{d\mid w_{e_i}}\varphi(d)\\
=&\sum\limits_d\varphi(d)\sum\limits_{\substack{T\\d\mid w_{e_i}}}\sum\limits_{i=1}^{n-1}w_{e_i}
\end{aligned}
$$

此时内部需要计算一个所有生成树边权和的和。

矩阵树定理可以处理边权积的和，如何转化？

考虑 $\trick{33}$，将原来的边权 $w_i$ 变为一个关于 $x$ 的一次多项式 $w_ix+1$，这样的话我们求得的乘积是一个多项式，而一次项的系数恰好就是 $\sum w_i$！

于是我们考虑计算在 $\bmod\ x^2$ 意义下的多项式即可。

这里补充一下一次多项式的四则运算：
- $(ax+b)\pm(cx+d)\equiv(a\pm c)x+(b\pm d)\pmod{x^2}$。
- $(ax+b)(cx+d)\equiv(ad+bc)x+bd\pmod{x^2}$，这里二次项直接消掉了。
- 对于 $(ax+b)(cx+d)^{-1}$，设 $(cx+d)^{-1}=px+q$，则 $(cx+d)(px+q)\equiv(cq+dp)x+dq\equiv1\pmod{x^2}$，由于我们最后只剩下了常数项，所以一次项系数必然为 $0$，即 $cq+dp=0,dq=1$，这样就有 $q=\dfrac1d,p=-\dfrac c{d^2}$，即 $px+q=-\dfrac c{d^2}x+\dfrac 1d$，然后就可以做乘法了。

此外还有一个小优化是，我们对于一个枚举的 $d$，如果边数不足 $n-1$ 条，显然就不用管。

时间复杂度大约为 $O(n^2\sum d(w_i))$。

---

## 34. $(★★★★)$ 数位 DP 优化贡献计算

> ***当个数和值域都很小，而答案可能很大时，可以考虑用数位 DP 处理答案的每一数位上的情况。***

### 例 34-1. [CF1290F. Making Shapes](https://codeforces.com/problemset/problem/1290/F)

> 给定 $n$ 个互不共线的向量 $(x_i,y_i)$，选用任意多个向量（每个向量均可重复使用），拼接形成一个多边形，要求：
>
> - 存在一个顶点和原点重合；
> - 这是一个凸多边形；
> - 多边形上的任意一个点的横纵坐标范围都在 $[0,m]$ 内。
>
> 求有多少种本质不同的合法多边形，答案对 $998244353$ 取模。
>
> $1\le n\le 5$，$1\le m\le 10^9$，$0\le |x_i|,|y_i|\le 4$，$(x_i,y_i)\neq(0,0)$。

首先，一种选择向量的方式和一种凸包是一一对应的。设向量 $(x_i,y_i)$ 选择了 $c_i$ 次，则答案等价于合法的序列 $c$ 数量，并有 $\sum\limits_{i=1}^nc_ix_i=\sum\limits_{i=1}^nc_iy_i=0$。

由于还有多边形坐标的限制，所以考虑拆开正负的贡献，也就是有 $0\le\sum\limits_{x_i>0}c_ix_i=\sum\limits_{x_i<0}-c_ix_i\le m\land 0\le\sum\limits_{y_i>0}c_iy_i=\sum\limits_{y_i<0}-c_iy_i\le m$。

接下来考虑如何计数。注意到 $n,a_i$ 都很小，利用 $\trick{34}$，一位一位考虑。

把 $c_i$ 拆成二进制位，则设 $f_{i,a,b,c,d,0/1,0/1}$ 表示当前状态下合法的序列 $c$ 数量，其中每一维分别表示：

- 已经确定了最低的 $i$ 位；
- 当前 $\sum\limits_{x_k>0}c_kx_k$ 贡献了 $a$ 的进位；
- 当前 $\sum\limits_{x_k<0}-c_kx_k$ 贡献了 $b$ 的进位；
- 当前 $\sum\limits_{y_k>0}c_ky_k$ 贡献了 $c$ 的进位；
- 当前 $\sum\limits_{y_k<0}-c_ky_k$ 贡献了 $d$ 的进位；
- 当前是否满足 $\left(\sum\limits_{x_k>0}c_kx_k\right)\bmod 2^i\le m\bmod 2^i$；
- 当前是否满足 $\left(\sum\limits_{y_k>0}c_ky_k\right)\bmod 2^i\le m\bmod 2^i$。

然后枚举 $c$ 内每个数第 $i+1$ 位上的值即可。

设 $t$ 为进位数，则时间复杂度为 $O(t^42^n\log m)$，而 $t\le n\cdot |x_i|=20$。

### 练习 34

- [HDU6953 Another thief in a Shop](https://acm.hdu.edu.cn/showproblem.php?pid=6953)

---

## 40. $(★★)$ 钦定不操作元素

> ***对于序列内元素的操作，可以考虑钦定不操作的元素处理一些问题。***

### 例 40-1. [ZR3287. 旋转排列问题](https://zhengruioi.com/problem/3287)

> 给定一个 $1\sim n$ 的排列 $a$。每次操作可以选择一个 $x$，并将 $a_1$ 取出，插入到 $a_x$ 的后面一个。求有多少种长度为 $m$ 的操作序列 $x_1,x_2,\cdots,x_m$，使得最终的 $a$ 满足 $a_i=i$。答案对 $998244353$ 取模。
>
> $2\le n,m\le 5000$。

考虑 dp。设 $f_{i,j}$ 表示操作了 $i$ 次，钦定了 $j$ 个元素此后不再操作，对应的合法操作序列个数。

发现我们可以钦定的这 $j$ 个元素可以形成 $a$ 的一个递增后缀，也就是我们把状态内的“钦定 $j$ 个元素”变成“钦定最后 $j$ 个元素”。

于是我们可以考虑第一个元素的情况进行转移。

- 如果钦定第一个元素做最后一次操作，那么可以转移 $f_{i+1,j+1}\upd+f_{i,j}$。
- 如果不是最后一次操作，那么只会插入到下标为 $1\sim n-j$ 的后面一个，也就是有转移 $f_{i+1,j}\upd+(n-j)f_{i,j}$。

时间复杂度 $O(n^2)$。

---

## 41. $(★★★)$ 模糊答案考虑二进制位

> ***当要求输出答案只需要满足形如不超过两倍实际答案之类限制的时候，考虑将利用二的幂次缩小值域。***

### 例 41-1. [ZR3254. 树上中位数](https://zhengruioi.com/problem/3254)

> 给定一棵 $n$ 个节点的树，每个节点有点权 $a_i$，设点对 $(u,v)\ (u\le v)$ 的权值为其唯一简单路径上所有点权构成的可重集合 $S$ 中第 $\left\lceil\frac{|S|}2\right\rceil$ 小的数。求所有点对的权值和 $x_0$。你输出的答案 $x$ 只需要保证 $x_0\le x\le 2x_0$ 即可。
>
> $1\le a_i\le n\le 5\times 10^5,2\sec,512\text{ MB}$。

将值在 $[2^{k-1},2^{k+1}-2]$ 内的数变为 $2^{k+1}-2$，发现此时的答案不超过原答案两倍。而且一件很好的事情是，点权只剩 $\log ⁡n$ 种了。

于是我们可以直接枚举中位数求解答案。使用长剖可以做到时间复杂度 $O(n\log ⁡n)$。

---

## 42. $(★★★)$ 绝对众数与摩尔投票
> > *补充性质：*  
> > 1. *一个序列有且仅有一个绝对众数。*
> > 2. *对于一个区间 $[l,r]$，在 $[l,\text{mid}]$ 和 $[\text{mid}+1,r]$ 中至少一个区间的绝对众数和 $[l,r]$ 相同。*
> > 3. *一个序列的所有前缀共有 $\log$ 个本质不同的绝对众数。*
> > 4. *一个序列的所有子段共有 $\log$ 个本质不同的绝对众数。*
> > 5. *摩尔投票的信息是一个二元组，具有结合律。*
> >
> > ***遇到绝对众数时，可以考虑其性质，或者维护摩尔投票信息。***

### 例 42-1. [ARC159F. Good Division](https://atcoder.jp/contests/arc159/tasks/arc159_f)

> 一个数列 $a$ 是好的，当且仅当可以若干次删除相邻两个值不同元素后，序列为空。  
> 现给定一个长度为 $2n$ 的序列 $a$，将其划分为若干个非空子段，要求每一段都是好的。问这 $2^{2n-1}$ 种划分方法中有多少种是合法的。答案对 $998244353$ 取模。  
> $1\le n\le 5\times 10^5$，$1\le a_i\le 2n$，$5\sec$。

显然一个好的序列当且仅当不存在绝对众数。

设 $\operatorname{abmode}(l,r)$ 表示 $a[l:r]$ 的绝对众数，若不存在，则 $\operatorname{abmode}(l,r)=0$。

那么就容易有暴力 dp。设 $f_i$ 表示前 $i$ 个数的答案，则 $f_i=\sum\limits_{j=1}^{i-1}[\operatorname{abmode}(2j+1,2i)=0]f_j$。对于一个区间 $[l,r]$，其所有子区间本质不同的绝对众数最多只有 $\log$ 种。考虑枚举绝对众数，则上式可以变为：
$$
f_i=\sum\limits_{j=1}^{i-1}f_j-\sum\limits_k\sum\limits_{j=1}^{i-1}[\operatorname{abmode}(2j+1,2i)=k]f_j
$$
考虑分治。

在区间 $[l,r]$ 时，考虑计算 $f[l:\text{mid}]$ 对 $f[\text{mid}+1:r]$ 的贡献。假设枚举了绝对众数 $k$，那么可以将 $a_i=k$  的位置变为 $1$，$a_i\neq k$ 的位置变为 $-1$，然后在这个区间内做一个前缀和，设为 $s_{k,i}$，那么对于 $i\in[\text{mid}+1,r]$，转移式子可以写作：
$$
f_i\stackrel+\gets\sum\limits_{j=l}^{\text{mid}}f_j-\sum\limits_k\sum\limits_{j=l}^{\text{mid}}[s_{k,i}>s_{k,j}]f_j
$$
需要枚举的 $k$ 是可以直接预处理 $[l,\text{mid}]$ 的后缀和 $[\text{mid}+1,r]$ 的前缀。然后后面这个 $s_{k,i}>s_{k,j}$ 的限制可以 BIT 维护。这样子是 $T(n)=2T\left(\dfrac n2\right)+O(n\log^2n)$ 的，即 $O(n\log^3n)$。

然而注意到 $s_k$ 的值域范围很小，于是可以直接预处理一个 $g_k$ 出来：
$$
g_{k,i}=\sum\limits_k\sum\limits_{j=l}^{\text{mid}}[s_{k,j}\le i]f_j
$$
于是时间复杂度变为 $T(n)=2T\left(\dfrac n2\right)+O(n\log n)$，即 $O(n\log^2n)$。

### 例 42-2. [Luogu P8496. 众数](https://www.luogu.com.cn/problem/P8496)

> 初始给定编号为 $1\sim n$ 的序列，分别给出初始有的 $l_i$ 个元素，序列可以为空。$q$ 次操作，维护这些序列：
>
> - $\texttt1\ x\ y$：在 $x$ 号序列末尾插入 $y$。
> - $\texttt2\ x$：删除 $x$ 号序列末尾的数字。
> - $\texttt3\ m\ x_1\ x_2\ \cdots\ x_m$：询问将 $x_1,x_2,\cdots,x_m$ 号序列拼接起来得到的序列的**绝对众数**，或报告不存在。
> - $\texttt4\ x_1\ x_2\ x_3$：新建一个编号为 $x_3$ 的序列，由 $x_1,x_2\ (x_1\neq x_2)$ 号序列的元素顺次拼接得到。
>
> 保证操作合法，操作 4 的 $x_3$ 此前未使用，且此后序列 $x_1,x_2$ 不再使用。
>
> $1\le n,q,\sum m,\sum l_i\le 5\times10^5$，$1\le x,y,x_i\le n+q$，$1\sec$，$1\text{ GB}$。

加入序列、删除序列、合并序列，显然可以对每个序列开一棵平衡树直接维护。

考虑询问。由于求的是绝对众数，可以维护摩尔投票的信息 $(\text{cur},\text{cnt})$，分别表示当前钦定的绝对众数，以及它还可以被抵消的次数。它有结合律，所以依旧可以放到平衡树上维护。查询时将每个序列的摩尔投票信息合并即可。

具体地，设两对信息为 $(x_0,y_0),(x_1,y_1)$，则定义他们的合并为：

$$
(x_0,y_0)+(x_1,y_1)=\begin{cases}
(x_0,y_0+y_1)&(x_0=x_1)\\
(0,0)&(y_0=y_1)\\
(x_0,y_0-y_1)&(y_0>y_1)\\
(x_1,y_1-y_0)&(y_0<y_1)
\end{cases}
$$

最后需要检查是不是绝对众数，对每个序列开一个值域线段树来计数就可以了。合并序列的时候值域线段树也可以直接合并。

时间复杂度 $O((n+q)\log(n+q))$。

### 练习 42
- [Luogu P11882. 彩虹糖 / Skittlez](https://www.luogu.com.cn/problem/P11882)

---

## 43. $(★★★☆)$ 延迟贡献

> ***如果可以将所有决策划分成「确定不再贡献的」和「可能再贡献的」两部分，dp 时可以考虑钦定一些位置，但此时不计算贡献，等到后续转移时再进行计算。***

### 例 43-1. [Luogu P14364. 员工招聘](https://www.luogu.com.cn/problem/P14364)

> 有 $n$ 个人，他们会按照一个排列 $p$ 在 $n$ 天内每天依次前往应聘。给定一个长度为 01 序列 $s$，若 $s_i=0$ 表示任意一人在第 $i$ 天应聘时都会失败；$s_i=1$ 表示任意一人在第 $i$ 天应聘时都会成功。
>
> 同时有一个长度为 $n$ 的非负整数序列 $c$，若第 $i$ 个人暂未前往应聘，但此时已经有 $c_i$ 个人失败，则他会放弃，即他应聘那天自动视为失败。
>
> 求所有能成功应聘至少 $m$ 人的排列方案数。对 $998244353$ 取模。
>
> $1\le m\le n\le 500$，$s_i\in\{0,1\}$，$0\le c_i\le n$。

设前若干天已经有 $x$ 人失败，由于 $x$ 单调不降，因此当前 $c_i\le x$ 人是确定失败的，而 $c_i>x$ 的人不确定是否能够成功。

于是考虑 dp，设 $f_{i,j,k}$ 表示对于前 $i$ 天，当前有 $j$ 人失败，且当前有 $k$ 个位置的人 $c>j$，此时只考虑前 $i$ 天 $c\le j$ 的人的排列方案数。可以发现这 $k$ 个人暂时还没有造成贡献，需要后续转移的时候计算。

下面设 $\text{cnt}_i$ 表示 $c=i$ 的人数，$\text{sum}_i$ 表示 $c\le i$ 的人数。

讨论第 $i+1$ 天的人是成功还是失败：

- $s_{i+1}=0$，此时必然失败。

  讨论第 $i+1$ 天的人 $p_{i+1}$ 对应的 $c_{p_{i+1}}$ 和 $j+1$ 的大小。**然后这时，将 $\boldsymbol{k}$ 个人中满足 $\boldsymbol{c=j+1}$ 的算入贡献**。枚举这 $k$ 个人中有 $x\ (x\in[0,k])$ 个满足 $c=j+1$。
  
  - $c_{p_{i+1}}>j+1$，这时对于前 $i+1$ 个人，有 $k-x+1$ 个满足 $c>j+1$（因为需要加上当前这个人）。转移时需要乘上从 $k$ 个已钦定位置中选择 $x$ 个位置，以及从 $\text{cnt}_{j+1}$ 个人中选择 $x$ 个人任意排列的组合数，即：
    $$
    f_{i+1,j+1,k-x+1}\upd+ f_{i,j,k}\cdot\binom kx\cdot\binom{\text{cnt}_{j+1}}x\cdot x!
    $$
  
  - $c_{p_{i+1}}\le j+1$，这时对于前 $i+1$ 个人，有 $k-x$ 个满足 $c>j+1$。转移除了要乘以上一种情况的系数外，还需要乘一个第 $i+1$ 天可能的人，即满足 $c\le j+1$ 且前面没出现过的人总数。有转移：
    $$
    f_{i+1,j+1,k-x}\upd+ f_{i,j,k}\cdot\binom kx\cdot\binom{\text{cnt}_{j+1}}x\cdot x!\cdot(\text{sum}_{j+1}-i+k-x)
    $$
  
- $s_{i+1}=1$，此时有可能成功。于是对 $c_{p_{i+1}}$ 和 $j$ 进行讨论。

  - $c_{p_{i+1}}>j$，这时必然成功，$j$ 不变，直接转移：
    $$
    f_{i+1,j,k+1}\upd+ f_{i,j,k}
    $$

  - $c_{p_{i+1}}\le j$，这时直接放弃，$j$ 变为 $j+1$。和 $s_{i+1}=0\land c_{p_{i+1}}\le j+1$ 的情况类似，除了乘上排列组合数的系数外，还需要乘上满足 $c\le j$ 且前面没出现过的人的总数。有：
    $$
    f_{i+1,j+1,k-x}\upd+ f_{i,j,k}\cdot\binom kx\cdot\binom{\text{cnt}_{j+1}}x\cdot x!\cdot(\text{sum}_j-i+k)
    $$

于是答案即为 $\sum\limits_{i=0}^{n-m}f_{n,i,n-\text{sum}_i}\cdot(n-\text{sum}_i)!$，即还剩下没算贡献的再任意排列一下。

由于一定有 $x\le\text{cnt}_{j+1}$，所以均摊下来的时间复杂度为 $O(n^3)$。

---

## 44. $(★★☆)$ 可行决策转排列决策

> ***如果初始状态下的某些决策，在后续状态下因为其他决策影响，导致该决策不合法或没有影响，可以考虑事先钦定所有决策的顺序，然后依次执行当前仍旧合法的决策。***

### 例 44-1. [ARC114E. Paper Cutting 2](https://atcoder.jp/contests/arc114/tasks/arc114_e)

> 给定一张 $h\times w$ 的网格，有且仅有 $(x_0,y_0)$ 和 $(x_1,y_1)$ 两个格子被涂黑。设当前的剩余网格大小为 $p\times q$，则每次可以从 $p-1$ 条横线和 $q-1$ 条竖线中，等概率随机选出一条线，并沿其将网格切开，并保留两个黑格子都在的那张网格上，否则操作结束。求期望可以进行的操作次数，对 $998244353$ 取模。
>
> $1\le h,w\le 10^5$，$1\le x_0,x_1\le h$，$1\le y_0,y_1\le w$。

这个纸张缩小的限制很烦，因为我们有的初始能做的决策到后面不合法了。考虑运用 $\trick{44}$，将操作转化为：初始横纵一共 $h+w-2$ 条直线，随机一个长度为 $h+w-2$ 的排列，然后依次切当前可以切的直线，不合法的操作忽略。

根据期望的线性性，期望操作次数等于每条线被切割的概率之和。

然后对于极小的可切出的矩形，其四侧的直线，由于整体上互不影响，于是可以分开考虑。对于一条直线，如果它排在另外 $k$ 条之后切，就会产生 $\dfrac 1{k+1}$ 的贡献。于是四侧分别枚举并求和即可。时间复杂度 $O(h+w)$。

### 例 44-2. [ARC165E. Random Isolation](https://atcoder.jp/contests/arc165/tasks/arc165_e)

> 给定一棵 $n$ 个点的无根树。每次操作，将所有大小 $\ge k$ 的连通块中分别等概率随机删去一个点，直到不存在这样的连通块为止。求期望操作次数，对 $998244353$ 取模。
>
> $1\le k<n\le 100$。

由于多次操作一个点是没有意义的，而且操作需要的约束和上一题类似。于是我们可以将操作过程同样地刻画：生成一个排列出来，然后按照排列依次看这个点，如果所在连通块大小 $>k$ 就删，否则不管。那么原问题的答案，就是这个排列上被操作的点的个数的期望。

考虑一个以 $x$ 为根的连通块，大小为 $i$，如果说这样一个连通块会产生，那么和该块相邻的 $j$ 个点都需要在 $x$ 之前删掉。这 $i+j$ 个点以外的点都没有影响。那么对于这些点，总共有 $(i+j)!$ 种排列，而 $j$ 个点先删的有 $i!j!$ 种，故概率为 $\dfrac{i!j!}{(i+j)!}=\dfrac1{\binom{i+j}{j}}$。

于是考虑 dp，设 $f_{u,i,j}$ 表示以 $u$ 为根的连通块大小为 $i$，与之相邻的有 $j$ 个点的连通块数。这里为了方便操作，$j$ 是不考虑 $u$ 的父亲的，于是可以树上背包转移。设 $u$ 的儿子为 $v$，对应枚举的大小和相邻点数为 $x,y$，则有：
$$
f_{u,i+x,j+y}\overset+{\gets}f_{u,i,j}\cdot f_{v,x,y}
$$
初值 $f_{u,1,0}=1$。由于 $u$ 不选任何儿子也是会有相邻点的，于是还有 $f_{v,0,1}=1$。

最终计算的答案，就是将所有的连通块产生的贡献加起来，即：
$$
\sum\limits_{i=1}^n\sum\limits_{x=k+1}^{\text{sz}_i}\sum\limits_{y=0}^{\text{sz}_i-x}\dfrac{f_{i,x,y}}{\binom{x+y+[i\neq1]}{y+[i\neq 1]}}
$$
里面有个 $[i\neq 1]$ 是在特判前面没考虑的父亲。

时间复杂度 $O(n^2k^2)$。

---

## 45. $(★★☆)$ 斐波那契数列的二级结论

> > *下面约定 $f$ 为斐波那契数列，并定义 $f_0=0,f_{-1}=1,\cdots$。常用的二级结论：*
> > 1. *$f_n=\dfrac{1}{\sqrt 5}\left(\left(\dfrac{1+\sqrt5}2\right)^n-\left(\dfrac{1-\sqrt5}2\right)^n\right)$。*
> > 2. *$f_{2n}=f^2_{n+1}-f^2_{n-1}$。*
> > 3. *$f_{2n+1}=f^2_{n+1}+f^2_n$。*
> > 4. *$\gcd(f_n,f_m)=f_{\gcd(n,m)}$。*
> > 5. *$f_n=f_{n-1}f_1+f_{n-2}f_2$。可以拓展到广义斐波那契数列 $g$，即 $g_n=f_{n-1}g_1+f_{n-2}g_2$。*
> > 6. *$f_{n+m}=f_{n+1}f_m+f_nf_{m-1}$。*
> > 7. *$f_{2n}=\sum\limits_{i=1}^nf_{2i-1}$。*
> > 8. *$f_nf_{n+1}=\sum\limits_{i=1}^nf_i^2$。*
> > 9. *$f_n^2=f_{n-1}f_{n+1}+(-1)^{n-1}$。*
> > 10. *$\sum\limits_{i=1}^nf_i=f_{n+2}-f_2$。*
> >
> > ……
> >
> > 这些性质读者都可以尝试用定义和归纳证明。
>
> ***遇到斐波那契数列时，可以考虑它的一些二级结论。***

### 例 45-1. [Luogu P3986. 斐波那契数列](https://www.luogu.com.cn/problem/P3986)

> 定义数列 $g_0=a,g_1=b\ (a,b>0)$，对于 $n\ge 2$，$g_n=g_{n-1}+g_{n-2}$。给定正整数 $k$，问有多少组可能的 $(a,b)$，使得 $k$ 出现在该数列内。答案对 $10^9+7$ 取模。
>
> $1\le k\le 10^9$。

根据二级结论，问题即求 $f_na+f_{n+1}b=k$ 的正整数解的对数。

由于斐波那契数列增长极快，因此这个 $n$ 很小。直接依次枚举 $n$ 做 exgcd 的板子（求正整数解对数，具体可以看 [P5656](https://www.luogu.com.cn/problem/P5656)）就可以了。

时间复杂度 $O(\log k)$。

### 例 45-2. [CF446C. DZY Loves Fibonacci Numbers](https://codeforces.com/problemset/problem/446/C)

> 给定一个长度为 $n$ 的正整数序列 $a$，维护：
> - $\texttt1\ l\ r$：对于所有的 $i\in [l,r]$，执行 $a_i\upd+ f_{i-l+1}$。
> - $\texttt2\ l\ r$：求 $\left(\sum\limits_{i=l}^ra_i\right)\bmod(10^9+9)$。
>
> $1\le n,m\le 3\times10^5$，$1\le a_i\le 10^9$，$4\sec$，$250\text{ MB}$。

本题做法很多，下面给出一种。

对于一次操作，位置 $i\in[l,r]$ 被加上了 $f_{i-l+1}=f_{i+1}f_{-l+1}+f_if_{-l}$，那么可以用两个标记 $s,t$ 维护区间内的每个点 $i$ 分别加了多少个 $f_i$ 和 $f_{i+1}$。处理到一个节点，做 $s\upd+f_{-l+1}$，$t\upd+f_{-l}$ 就可以了。

时间复杂度 $O(m\log n)$。

### 练习 45
- [Luogu P1306. 斐波那契公约数](https://www.luogu.com.cn/problem/P1306)
- [Luogu P4834. 萨塔尼亚的期末考试](https://www.luogu.com.cn/problem/P4834)$AKB41$, '基础算法', array['DP 技巧', '补集转化', '数位 DP', '计数'], 'col-basic-tricks-overview', null, 'knowledge'),
('stripe-python', 'col-basic-tricks-ds--stripe-python', '数据结构技巧合集（倍增并查集 / 单侧递归线段树 / BIT 倍增） · stripe-python', $AKB42$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 4. $(★★★)$ 倍增优化并查集

> ***当对两个区间内的点顺次合并时，由于并查集的合并满足结合律，因此可以类似 st 表地倍增优化连边。***

### 例 4-1. [Luogu P3295. 萌萌哒](https://www.luogu.com.cn/problem/P3295)

> 一个长度为 $n$ 的正整数 $S$，有 $m$ 个形如 $S[l_{i_1}:r_{i_1}]=S[l_{i_2}:r_{i_2}]$ 的要求，求满足所有要求的互不相同的 $S$ 有多少个。  
> $1\le l_{i_1},r_{i_1},l_{i_2},r_{i_2}\le n\le 10^5,1\le m\le 10^5,r_{i_1}-l_{i_1}=r_{i_2}-l_{i_2}$。

由于并查集的合并满足结合律，因此考虑将区间 $[l,r]$ 类似 st 表地，拆成 $[l,l+2^k-1],[r-2^k+1,r]$ 两个长度为 $2^k$ 的区间。于是我们可以开 $\log n$ 个并查集，第 $j$ 个就是 $\text{fa}_{i,j}$，表示区间 $[i,i+2^k-1]$ 的父亲区间。

于是我们可以处理完后从上往下传信息（即继续拆分区间合并）即可。最后传到 $\text{fa}_{i,0}$ 时，记有 $c$ 个不同的父亲，由于第一位不能取 $0$，答案即为 $9\times 10^{c-1}$。时间复杂度 $O(n\log n\ \alpha(n))$。

### 练习 4
- [Luogu P12736. 圣诞灯链 Christmas chain](https://www.luogu.com.cn/problem/P12736)

---

## 11. $(★★★)$ 单侧递归线段树

> ***线段树区间合并信息不能直接做而需要满足一定关系时，可以考虑递归合并。***

### 例 11-1. [Luogu P4198. 楼房重建](https://www.luogu.com.cn/problem/P4198)

> 在平面的横坐标为 $i\in[1,n]$ 的地方，有线段 $(i,0)-(i,H_i)$，初始 $H_i=0$。$m$ 次修改，每次修改一个 $H_i$，并查询从 $(0,0)$ 最多能看到多少线段。  
> $1\le n,m\le10^5,1\le H_i\le 10^9$。

单侧递归线段树模板。

考虑用线段树维护答案，但是上传信息不好处理。

下面令 $\text{maxl}_S$ 表示区间 $S$ 中最多可看到的楼房数量，$\text{maxs}_S$ 表示区间 $S$ 中的最大斜率。

首先对于区间 $[l,r]$，其左区间的信息一定是会在这个区间里（由题意可得）。

考虑递归处理右区间的情况，并传入该区间的值所必须要大于的最小值 $x$。

- 若 $l=r$，则返回 $[a_r>x]$；
- 将区间划分成 $L,R$ 两段：
  - 若 $\text{maxs}_L\le x$，那么 $L$ 不会对答案有贡献，递归处理 $R$；
  - 若 $\text{maxs}_L>x$，那么递归处理 $L$，并加上 $R$ 的贡献。

若中途遇到一些不会对答案产生贡献的情况就不用考虑，直接跳出即可。

时间复杂度 $O(n\log^2n)$。

---

## 13. $(★★★)$ 直方图转笛卡尔树

> ***在一个直方图上操作时，可以考虑将其横向划分成若干个极大的矩形，建立笛卡尔树。***

### 例 13-1. [Luogu P6453. PERIODNI](https://www.luogu.com.cn/problem/P6453)

> 给定一个宽 $n$ 高分别为 $a_i$ 的格点直方图，要求在格子内放入恰好 $k$ 颗棋子，要求任意两颗棋子如果共行（列），棋子之间应当有超过 $1$ 个极长连续段。求放置方案数，对 $10^9+7$ 取模。  
> $1\le n,k\le 500,1\le a_i\le 10^6$。

考虑一个直方图：
$$
\rule{10px}{10px}\rule{10px}{40px}\rule{10px}{30px}\rule{10px}{50px}\rule{10px}{10px}\rule{10px}{30px}\rule{10px}{20px}
$$
对其进行横向划分：

$$
\def\red{\color{red}}
\def\org{\color{orange}}
\def\ord{\color{orangered}}
\def\yel{\color{gold}}
\def\grn{\color{limegreen}}
\def\skb{\color{skyblue}}
\def\blu{\color{blue}}
\def\pur{\color{purple}}
\def\pnk{\color{pink}}
\def\wht{\color{white}}
\def\r#1#2{\rule{#1px}{#2px}}
\begin{array}{c}
\quad\red\r{10}{10}\quad\ord\r{10}{20}\quad\quad\quad\\[-3.5pt]
\quad\org\r{30}{10}\quad\yel\r{10}{10}\quad\\[-3.5pt]
\quad\org\r{30}{10}\quad\grn\r{20}{10}\\[-3.5pt]
\skb\r{70}{10}
\end{array}
$$
从下往上，根据它们的相连关系，可以建出笛卡尔树。

然后考虑 dp。设 $f_{x,i}$ 表示以 $x$ 为根的子树放了 $i$ 颗棋子的方案数，$g_{x,i}$ 表示以 $x$ 为根的子树但不包含 $x$，放了 $j$ 颗棋子的方案数。记 $\text{lson}_x,\text{rson}_x$ 分别表示 $x$ 的左右儿子，$h_x,w_x$ 分别为节点 $x$ 对应的矩形的高、宽，则有：
$$
g_{x,i}=\sum\limits_{j=0}^if_{\text{lson}_i,j}\cdot f_{\text{rson}_i,i-j}\\
f_{x,i}=\sum\limits_{j=0}^i\binom{h_x}{i-j}\cdot\binom{w_x-j}{i-j}\cdot(i-j)!\cdot g_{x,j}
$$
时间复杂度 $O(nk^2+n^2)$。

### 练习 13
- [AGC041 F. Histogram Rooks](https://atcoder.jp/contests/agc041/tasks/agc041_f)

---

## 15. $(★★☆)$ BIT 倍增

> ***当要做二分套 BIT 时，有的时候由于有很多重复计算的部分，因此可以利用其转成一个 BIT 上倍增的过程。***

### 例 15-1. [Luogu P6619. 冰火战士](https://www.luogu.com.cn/problem/P6619)
> 有两个二元组集合 $A,B$，会进行共 $q$ 次插入和删除二元组 $(x,y)$ 的操作，每次操作完都要钦定一个 $k$，令 $f(k)=\sum\limits_{\substack{(x,y)\in A\\x\le k}}y,g(k)=\sum\limits_{\substack{(x,y)\in B\\x\ge k}}y,w(k)=\min\left(f(k),g(k)\right)$，输出 $2w_{\max}(k)$ 和 $\max\{k\mid w(k)=w_{\max}(k)\}$。  
> $1\le q\le 2\times10^6,1\le x,\sum y\le 2\times 10^9$。

首先一个简单的观察是 $w(k)$ 是一个单峰函数，但是有不变的段，不能三分。

不难想到可以先二分出一个 $k_0$ 满足 $f(k_0)<g(k_0),f(k_0+1)\ge g(k_0+1)$，再找到 $k_1=\max\{k\mid g(k)=g(k_1+1)\}$。这样答案必然是 $k_0,k_1$ 中的一个。

这个过程直接二分套 BIT 是 $O(q\log^2q)$ 的，考虑优化。

注意到我们在计算前后缀和时有很多重复使用的段。由于 BIT 的节点 $x$ 存的是 $[x-\text{lowbit}(x)+1,x]$ 的信息，所以按二进制位从高到低枚举，这样倍增就和原来的二分等价了。中间求前缀和的过程我们就直接记一个当前的和，然后累加即可。

时间复杂度 $O(q\log q)$。

---

## 26. $(★★☆)$ 分块 ST 表

> ***当因为空间、时间等问题 st 表无法直接处理时，可以考虑分块后再上 st 表处理。***

### 例 26-1. [Luogu P3793. 由乃救爷爷](https://www.luogu.com.cn/problem/P3793)

> 给定长度为 $n$ 的正整数序列 $a$，$m$ 次询问，每次询问给定区间 $[l,r]$，求 $\max\limits_{i=l}^r\{a_i\}$。  
> $1\le n,m\le 2\times 10^7,0\le a_i< 2^{31},5\sec,500\text{ MB}$，数据随机。

虽然是四毛子板子，但是可以考虑一个更为简洁的东西，也是官方做法。

普通的 st 表在这里的瓶颈在于空间 $O(n\log n)$ 开不下。

考虑按块长 $B$ 分块，这样一个询问就可以拆成后缀最大值、块间最大值、前缀最大值三个子问题。我们预处理块间 st 表和块内的前后缀最大值即可。

空间复杂度 $O\left(\dfrac nB\log\dfrac nB\right)$，时间复杂度 $O\left(\dfrac nB\log\dfrac nB+q\right)$，取 $B=\log n$ 时为 $O(n)$。

当然，询问会有区间在同一块内的情况。这种情况期望下是 $O\left(\dfrac{B^2}n\right)$ 的。结合上述内容 $B$ 可以取 $[\log n,\sqrt n]$，对应的期望时间复杂度为 $O(n)$ 到 $O(m)$ 左右。

### 例 26-2. [Luogu P11750. 谢谢您。](https://www.luogu.com.cn/problem/P11750)

> 给定一个长度为 $n$ 的正整数序列 $a$，和 $m$ 个区间 $[l_i,r_i]$。$q$ 次询问 $x,y,k$，求 $\max\limits_{i=x}^y\left\{\sum\limits_{j=l_i}^{r_i}[a_j=k]\right\}$。
>
> $1\le n,m,q\le 2\times10^5$，$1\le a_i,k\le n$，$1\le l_i\le r_i\le n$，$1\le x\le y\le m$，$1\sec,64\text{ MB}$。

下面令 $m$ 个给定的区间为「关键区间」，$q$ 个询问的区间为「询问区间」。

看到出现次数，考虑根号分治。设 $c_k=\sum\limits_{i=1}^n[a_i=k]$。

- $c_k>\sqrt n$，此时最多只有 $\sqrt n$ 个 $k$ 满足这样的要求。

  对于这种情况，将每个询问 $(l,r,k)$ 挂在 $k$ 上，枚举所有符合要求的 $k$，直接前缀和处理每个关键区间内 $k$ 的出现次数，然后 $O(m)$ 分块预处理每个块内的最大值，这样每次询问可以做到 $O(\sqrt m)$。总时间复杂度为 $O((n+m)\sqrt n+q\sqrt m)$。

- $c_k\le\sqrt n$，这种情况比较难处理。

  考虑将每个询问 $(l,r,k)$ 挂在 $k$ 出现的所有位置上。然后从 $1$ 到 $n$ 扫描线，设当前扫到 $i$。

  考虑维护一个激活关键区间的序列 $b$，初始全 $0$。若一个关键区间满足 $i\in[l_j,r_j]$，则将这个区间激活，在 $b$ 上体现为执行 $b_j\gets r_j$。然后处理每个挂在 $i$ 上的询问区间 $[l,r]$，查询 $r_{\max}=\max\limits_{j=l}^r\{b_j\}$。若 $r_{\max}\ge i$，那么代表着该询问的答案至少可以更新为 $[i,r_{\max}]$ 中 $k$ 的出现次数。

  然后得到的这个 $r_{\max}$ 再在 $k$ 出现的所有位置构成的序列上二分一下就可以的得到当前询问得到的 $k$ 的出现次数，就可以更新答案。可以发现我们这样更新答案一定是可以取到最终答案的。

  对于每种 $k$ 来说，其每个位置都要询问。如果用线段树维护 $b$，那么可以做到的时间复杂度为 $O(m\log m+q\sqrt n(\log m+\log\sqrt n))$，这不太能要。

  $b_j\gets r_j$ 可以看作 $b_j\gets\max(b_j,r_j)$，所以考虑维护 st 表进行更新。但直接暴力更新肯定没道理。
  将 $b$ 分块，维护块内以及块间的 st 表。那么对于块内，如果需要修改维护 $[p,p+2^d)$ 的最大值的位置，则必然满足 $p\le j<p+2^d$，即 $j-2^d<p\le j$。也就是一种 $d$ 的贡献至多为 $2^d$，所以总贡献为 $O(\sum 2^d)=O(2^{\log\sqrt m})=O(\sqrt m)$。块间是同理的。这样就是修改 $O(\sqrt m)$，查询 $O(1)$。

  那么这样时间复杂度就变成 $O(m\sqrt m+q\sqrt n\log\sqrt n)$。

剩余的工夫就是大力卡常了。

---

## 38. $(★)$ Trie 交换子树

> ***可以通过 Trie 上交换子树来实现序列值域上的一些操作。***

### 例 38-1. [AGC044C. Strange Dance](https://www.luogu.com.cn/problem/AT_agc044_c)

> 编号为 $0\sim 3^n$ 的人围成一圈。现在有一个操作序列 $S$，有两种操作：
>
> - $S_i=\tt S$：表示对于第 $x$ 个人，他会走到第 $y$ 个位置，其中 $y$ 是 $x$ 三进制下每个数位 $\tt 12$ 翻转后得到的数。
> - $S_i=\tt R$：表示对于第 $x$ 个人，他会走到第 $(x+1)\mod 3^n$ 个位置。
>
> 问最后每个人所在的位置。
>
> $1\le n\le 12,1\le |S|\le 2\times 10^5$。

考虑把问题放到 trie 上处理，这里我们**从低到高**建树。

发现其实 $\tt S$ 对应着将每个节点的 $1,2$ 两个儿子交换，我们可以打懒标记处理。

而 $\tt R$ 操作，我们考虑从最低位向高位处理。发现对于同一个节点的三个儿子，我们容易想到轮换儿子，而变成 $0$ 的子树还需要处理进位，这一点我们递归下去即可。

时间复杂度 $O(3^n+n|S|)$。

### 例 38-2. [CF1515H. Phoenix and Bits](https://codeforces.com/problemset/problem/1515/H)

> 给定大小为 $n$ 的集合，$q$ 次操作或查询：
>
> - $\texttt{1}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位与 $z$。
> - $\texttt{2}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位或 $z$。
> - $\texttt{3}\ x\ y\ z$：将大小在 $[x,y]$ 的数按位异或 $z$。
> - $\texttt{4}\ x\ y$：查询 $[x,y]$ 内有多少个不同的数。
>
> $1\le n\le 2\times10^5,1\le q\le 10^5$。

考虑使用动态开点权值线段树，但本质和 01 trie 类似。

对区间操作时，我们利用线段树分裂截出来这段，最后再合并回去。

xor 我们可以利用同上一个例题一样，直接交换左右子树即可。

对于 and，我们可以用 xor 和 or 代替。具体地，令 $S=2^{20}-1$，有 $x\text{\ and\ }y=((x\text{ xor }S)\text{ or }(y\text{ xor }S))\text{ xor }S$。

接下来只要考虑 or 即可。

我们相当于要对两个子树进行合并（只有一个子树是显然的），那么之间线段树合并即可。

时间复杂度 $O(n\log^2V)$，实际还有一点细节。

---$AKB42$, '基础算法', array['数据结构技巧', '倍增并查集', '线段树', 'BIT'], 'col-basic-tricks-overview', null, 'knowledge'),
('stripe-python', 'col-basic-tricks-graph--stripe-python', '图论建模技巧合集（倍增 Floyd / 分层图 / 环相关） · stripe-python', $AKB43$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 3. $(★★)$ 倍增 Floyd

> ***当钦定路径要经过 $\bm k$ 条边时，由于 Floyd 用到的运算（$\bm{min}$ 和 $\exbm +$）满足结合律，因此可以矩阵加速，其他满足结合律的递推运算也适用。***

### 例 3-1. [Luogu P2886. Cow Relays G](https://www.luogu.com.cn/problem/P2886)

> 给定 $n$ 个点 $m$ 条边的无向带权图，求从 $s$ 到 $t$ 经过恰好 $k$ 条边的最短路。  
> $1\le k\le 10^6,1\le m\le 100,1\le n\le 200$。

首先补充一下 $\trick{3}$ 的具体内容。

将 Floyd 的转移方程改写为 $f'_{i,j}=\min\{f'_{i,j},f_{i,k}+f_{k,j}\}$，则做 $k$ 遍就相当于经过 $k$ 条边。

于是可以将 $f$ 看做矩阵，使用矩阵快速幂加速。

时间复杂度 $O(n^3\log k)$。

### 例 3-2. [Luogu P6190. 魔法](https://www.luogu.com.cn/problem/P6190)

> 给定 $n$ 个点 $m$ 条边的有向带权图，从 $1$ 走到 $n$，走的过程中可以使用最多 $k$ 次魔法，每次魔法可以将某一次走的边的权值取负（该次走过这条边后恢复），求 $1$ 走到 $n$ 的最短路。  
> $1\le n\le 100,1\le m\le 2500,1\le k\le 10^6$。

首先 $k=0$ 直接 Floyd。

对于 $k=1$，我们枚举改变权值的边 $(u,v,w)$，有转移方程 $f_{i,j}=\min\{f_{i,j},f_{i,u}+f_{v,j}-w\}$。

而 $k>1$，先考虑朴素 dp。记 $f_{i,j,p}$ 表示从 $i$ 走到 $j$ 花费 $p$ 次的最短路，有转移方程 $f_{i,j,p}=\min\limits_{x+y=p}\{f_{i,k,x}+f_{k,j,y}\}$。

直接暴力肯定不行的。

考虑 $k=1$ 的 $f$，我们跑 $p$ 遍就是 $f_{i,j,2^p}$，于是直接矩阵快速幂即可。时间复杂度 $O(n^3\log k)$。

### 练习 3

- [Luogu P4159. 迷路](https://www.luogu.com.cn/problem/P4159)
- [Luogu P6772. 美食家](https://www.luogu.com.cn/problem/P6772)

---

## 5. $(★☆)$ 图转生成树

> ***当决策、操作或查询在无向图上不好做时，可以考虑在其生成树（森林）上做。***

### 例 5-1. [Luogu P4494. 反色游戏](https://www.luogu.com.cn/problem/P4494)

> 给定 $n$ 个点 $m$ 条边的无向图，节点为黑白两色，每次可以选择任意一条边，将边的两个端点反转颜色。求对于 $\forall i\in[1,n]$，删去第 $i$ 个点和其相连的总共 $d_i$ 条边后，在所有 $2^{m-d_i}$ 种决策中，可以所有节点变成白色的决策数量。  
> $1\le n,m\le 10^5$，无重边自环。

首先，由于操作不会改变黑色节点奇偶性，故一个连通块内黑色节点个数为奇数就无解。

先考虑不删除点的情况。

直接在图上不太好做，考虑利用 $\trick{5}$，如果拉出来一棵生成树，就可以再利用 $\trick{25}$，在树上从叶子节点往上做出唯一的决策。对于每条非树边无论是否决策都是这样的，故只有一个连通块时方案数为 $2^{m-n+1}$。拓展到 $c$ 个连通块就是 $2^{m-n+c}$。

接下来有分类讨论和建圆方树两种做法，这边给出分讨的做法。

我们讨论删除的点对答案有无解造成的影响。
- 该点是孤立点，直接判即可。
- 该点是割点，要判所有新出现的连通块以及未影响到的连通块是否有解。
- 该点不是割点，则判所在连通块的变化即可。

时间复杂度 $O(n)$。

### 例 5-2. [Luogu P11360. 管道](https://www.luogu.com.cn/problem/P11360)

> 给定 $n$ 点 $m$ 边的图，求每个极大连通子图内的所有桥。  
> $1\le n\le 10^5,1\le m\le 6\times 10^6,\textbf{16 MB}$。

显然正常的 tarjan 没法做了。

我们考虑一个图内的生成树，发现桥一定是没有被非树边覆盖的树边。于是我们只要在生成树上做路径覆盖，未被覆盖的边就是树边，这个树上差分可以做到。

但是空间仍然不够。发现非树边不会构成环——若构成环，那么必然有删去后对我们操作没有影响的边。

于是我们只要 $O(n)$ 条边。时间复杂度 $O(m\alpha(n)+n\log n)$。

---

## 6. $(★☆)$ 图上连边二元组

> ***给定的二元组可以考虑转化为在图上连边。***  

### 例 6-1. [ABC155 F. Perils in Parallel](https://atcoder.jp/contests/abc155/tasks/abc155_f)

> 有 $n$ 个具有初始位置 $a_i$ 和初始状态 $b_i\in\{0,1\}$ 的电灯，同时有 $m$ 个开关，第 $i$ 个开关可以将所有 $a_j\in[l_i,r_i]$ 的电灯取反。构造一组选定开关的方案，使得最后有 $\forall i\in[1,n],b_i=0$。  
> $1\le n\le 10^5,1\le m\le 2\times 10^5,1\le a_i\le 10^9,1\le l_i,r_i\le 10^9,0\le b_i\le 1$。

考虑对 $b_i$ 异或差分，这样区间修改就变成了单点修改，最后要求仍旧是一样的。

考虑连无向边 $(l_i,r_i)$，这样就变成在图上选边，将边的两个端点取反。利用 $\trick{5\ \&\ 25}$，在其生成森林上从叶子节点往上做即可。时间复杂度 $O(n)$。

### 例 6-2. [CF1815C. Between](https://codeforces.com/problemset/problem/1815/C)

> 给定正整数 $n,m$ 和 $m$ 个二元组 $(a_i,b_i)\ (1\le a_i\neq b_i\le n)$，构造一个尽可能长的序列 $p$，要求满足：
> - $1\le p_i\le n$。
> - 存在恰好一个 $p_i=1$。
> - 对于 $\forall i\in[1,m]$，满足对于 $\forall x,y\in[1,|p|]\land x<y\land p_x=p_y=a_i$，有 $\sum\limits_{k=x}^y[p_k=b_i]\ge1$。
>
> 给出一个尽可能长的构造，或报告序列长度可以无限长。  
> $1\le n\le 1500,1\le m\le3000$。

设 $c_i$ 为 $i$ 出现次数，则对于二元组 $(x,y)$，有 $c_x\le c_y+1$。考虑二元组连边 $b_i\dedge 1 a_i$，bfs 一遍可以得到每个 $c_i$ 的最大值。

然后构造。令 $d_i$ 表示出现次数为 $i+1$ 的数构成的序列。令 $s(l,r)=d_r,d_{r-1},\cdots,d_l$，那么有构造 $s(x,1),1,s(x,1),s(x,2),s(x,3),\cdots,s(x,x)$。

时间复杂度 $O(nm)$。

### 练习 6
- [Luogu P1954. 航空管理](https://www.luogu.com.cn/problem/P1954)

---

## 7. $(★★★)$ 图上分治

> ***对于在图上诸如删（留）点、边的操作求某个东西时，可以利用分治避免没有受影响的部分重复计算。***

### 例 7-1. [XYD19310. 先驱者](https://xinyoudui.com/ac/contest/777001C8D00052502C078F6/problem/19310)

> 给定 $n$ 个节点的无向带权图，定义 $d(p,x,y)$ 为 $x$ 到 $y$ 途中不经过 $p$ 的最短路（特别地，若 $p=x$ 或 $p=y$，则为 $x$ 到 $y$ 的最短路；若不存在路径，则定义为 $-1$）。求 $\sum\limits_{p=1}^n\sum\limits_{x=1}^n\sum\limits_{y=1}^nd(p,x,y)$。  
> $1\le n\le 500,4\sec$。

暴力 Floyd 是 $O(n^4)$ 的，显然跑不过去。

注意到在去掉一个点的时候，有很多没有被影响到的点对 $(x,y)$ 是被重复计算的。

考虑分治，记 $\text{sol}(l,r)$ 表示 $p\in [l,r]$ 时的全源最短路。这样当 $l=r$ 时就可以直接累加答案。钦定一定经过 $[l,\text{mid}]$，然后跑 $k\in[l,\text{mid}]$ 的 Floyd，进入 $\text{sol}(\text{mid}+1,r)$ 即可（反之亦然）。时间复杂度 $O(n^3\log n)$。

### 例 7-2. [Luogu P5631. 最小mex生成树](https://www.luogu.com.cn/problem/P5631)

> 给定 $n$ 个点 $m$ 条权值为 $w_i$ 的边构成的无向连通图。求其生成树构成的边集的 $\text{mex}$ 的最小值。  
> $1\le n\le 10^6,1\le m\le 2\times 10^6,0\le w\le10^5,2\sec$。

注意到 $w$ 范围较小，暴力可以考虑枚举答案，加入剩余的边看合法性。时间复杂度 $O(wm\cdot\alpha(n))$。

注意到在枚举的时候很多东西重复算了，考虑分治。记 $\text{sol}(l,r)$ 表示边权范围在 $[l,r]$ 的不选的答案。那么当 $l=r$ 时如果节点之间连通，那么答案就是 $r$。钦定选 $[l,\text{mid}]$ 的边，用并查集维护，然后进入 $\text{sol}(\text{mid}+1,r)$（反之亦然）。由于要回溯，使用可撤销并查集即可。时间复杂度 $O(w\log w\log n)$。

---

## 8. $(★)$ DAG 分层图

> ***对一个 DAG 建的分层图的正（反）图仍然是一个 DAG。***

### 例 8-1. [Luogu P3119. Grass Cownoisseur G](https://www.luogu.com.cn/problem/P3119)

> 给定 $n$ 点 $m$ 边的有向图，最大化从 $1$ 开始走最后回到 $1$ 经过的不同节点数量，中途允许逆向通过某条边最多一次。  
> $1\le n,m\le 10^5$。

首先显然地缩点成 DAG，然后考虑构建分层图。

对于原图的 $u\to v$，我们在新图中，可以构建 $u_1\to v_1\to u_2\to v_2$，这样一次逆行后不会出现第二次逆行。

DAG 分层后能否直接 dp 呢？

由于对于每一层都是一个 DAG，并且跨层之后不会回到原来的层，因此它依旧是一个 DAG，可以直接在上面 dp。

时间复杂度 $O(n+m)$。

---

## 10. $(★)$ （质）因数虚点连边

> ***当图上路径与点权因数有关时，可以和考虑将该点连向其点权的（质）因数。***

### 例 10-1. [CF1775D. Friendly Spiders](http://codeforces.com/problemset/problem/1775/D)

> 给定 $n$ 个点权为 $a_i$ 的节点 $i$，$i$ 与 $j$ 可以连接边权为 $1$ 的无向边当且仅当 $\gcd(a_i,a_j)\neq1$。求 $s$ 到 $t$ 的最短路，并给出一个可行路径。  
> $1\le n,a_i\le 3\times 10^5$。

直接 bfs 是会炸的，考虑优化。

我们可以建立质数虚点，将 $i$ 连向 $a_i$ 所有的质因子，然后就可以跑 bfs 了。

时间复杂度 $O(n\log n)$。

---

## 16. $(★★)$ 生成树异或环

> ***一个无向图中的任意环可以用若干个其生成树上非树边 $\bm{(u,v)}$ 及 $\bm{u,v}$ 的树上路径所构成的环进行异或并得到。***

### 例 16-1. [Luogu P4151. 最大 XOR 路径](https://www.luogu.com.cn/problem/P4151)
> 给定 $n$ 点 $m$ 边无向带权（$w$）连通图，求一条 $1\to n$ 路径（不一定是简单路径），使得异或和最大。  
> $1\le n\le 5\times10^4,1\le m\le 10^5,1\le w\le 10^{18}$。

原问题等价于一条 $1\to n$ 的简单路径异或上若干个简单环。因为显然你可以在路径上行走时拐向前往某个环绕一圈再原路走回来，这样中间拐的那一段就异或没了。

上述的简单路径可以是任意的，因为如果有更优路径就可以将其和原有路径构成一个环并异或掉。

根据 $\trick{16}$，我们可以取原图的任意生成树，将非树边与其覆盖路径构成的环的异或权值扔进线性基，这样只要在线性基上查询最大异或和即可。

时间复杂度 $O(n+m\log w)$。

### 例 16-2. [CF19E. Fairy](https://codeforces.com/problemset/problem/19/E)

>  给定 $n$ 点 $m$ 边无向图，求删除一条边后该图变成二分图的所有方案。  
>  $1\le n,m\le 10^4$。  
>  **请思考线性做法。**

显然答案是所有奇环的交，但这显然不是很可做。

我们称其覆盖的路径构成的是奇环的非树边为「奇边」，类似地有「偶边」。

根据 $\trick{16}$，我们注意到任意奇环都可以通过若干个奇边对应的的奇环异或并得到。而且，奇边被加入答案当且仅当只存在这一条奇边。

接下来考虑树边的情况。

若一条树边同时被奇边和偶边覆盖，那么一定不会是答案边。原因是奇边对应的奇环和偶边对应的偶环可以异或得到一个奇环，删去这条树边并没有影响。

也就是说，答案就是恰好被所有奇边覆盖的树边。

容易想到维护路径上的边权：给奇边覆盖的树边 $+1$，给偶边覆盖的树边 $-1$，这样边权最终恰好为奇边数量的边就是答案。

如果生成树是 dfs 树，那么非树边就都是返祖边，就可以搜索的时候处理。

时间复杂度 $O(n+m)$。

### 练习 16
- [Luogu P3733. 八纵八横](https://www.luogu.com.cn/problem/P3733)

---

## 19. $(★★)$ 无向边定向

> ***当在无向图上解决问题时，可以考虑给无向边定向。***

### 19-1. [Luogu P1989. 无向图三元环计数](https://www.luogu.com.cn/problem/P1989)

经典题。

定向 $u\to v$ 当且仅当 $(\deg_u,u)<(\deg_v,v)$。然后枚举点 $u$，将 $u\to v$ 的 $v$ 打上标记，枚举所有 $v\to w$，若 $w$ 打上标记则计数。时间复杂度 $O(m\sqrt m)$。

证明也是容易且经典的。

首先对于一条边 $(u_i,v_i)$，贡献为 $\dout_{v_i}$。

- 若 $\deg_v\le\sqrt m$，因为 $\dout_v\le\deg_v$，所以 $\dout_v=O(\sqrt m)$。
- 若 $\deg_v>\sqrt m$，依照连边规则，只有 $\deg_i>\sqrt m$ 的 $i$ 才可能向其连边，由于这是 $O(\sqrt m)$ 级别的，所以 $\dout_v=O(\sqrt m)$。

故时间复杂度为 $O\left(\sum\limits_{i=1}^m\dout_{v_i}\right)=O(m\sqrt m)$。

## 20. $(★★★)$ 有向环求交

> ***求有向环的交时，可以考虑先定一个主环，然后从后往前记录每个点不经过环上的边所能够达到的最远点，两点之间的点必然不合法，最终可以线性求出。***

### 例 20-1. [CF982F. The Meeting Place Cannot Be Changed](https://codeforces.com/problemset/problem/982/F)

> 给定 $n$ 点 $m$ 边无向图，求所有环的交，输出交集中的一个节点即可，无解输出 `-1`。  
> $2\le n\le 10^5,1\le m\le 5\times 10^5$。

首先补充一下 $\trick{20}$ 的具体内容。

我们在图中随便找到一个环，作为**主环**。如何求交是困难的，考虑把不交的去掉。对于主环上的每个点，记录其**不经过环上的边**所能够达到的最远点，将两点之间的点标记为不合法。直接做是 $O(n^2)$ 的。

但是注意到一件事情，我们倒着做，对于一个点 $u$，经过非主环边走到了下一个节点 $v$，而节点 $v$ 已经搜过了，并且 $v$ 所达到的最远点一定是 $u$ 向 $v$ 走下去所能够达到的，因此无需重复搜索。然后我们断开环差分即可。

但是，非主环边可能有向前走后向后回退的情况，如依次几个点 $A\route C\route B\route D\route A$，若存在非主环上路径 $A\route E\route F\route D$，并且有 $B\to E,F\to C$。这种情况下，显然有环 $B\to E\route F\to C\route B$，删去这个环上的点，并不能保证**同时不存在**环 $A\route E\route F\route D\route A$ 和主环 $A\route C\route B\route D\route A$，因此这种情况无解。

也就是说，我们在选出一个答案点时，**事先认为有解**，最后判一下答案合法性即可。

时间复杂度 $O(n)$。

### 练习 20
- [Luogu P11812. 精确打击 / Kontrmanifestacja](https://www.luogu.com.cn/problem/P11812)

---

## 21. $(★★)$ 无向环交上限二

> ***对于一个无向图中若存在多于一个简单环，则这些环点集的交的大小不超过二。***

我忘记有啥例题了，有知道的可以私我。

---

## 23. $(★★)$ 无向图网络流

> ***无向图可以直接跑网络流。***

### 例 23-1. [Luogu P1674. Secret Milking Machine G](https://www.luogu.com.cn/problem/P1674)

> 给定一张 $n$ 点 $m$ 边的无向带权（$w$）图，求出 $t$ 条 $1$ 到 $n$ 的路径，并最小化这些路径上权值最大的边。  
> $2\le n\le 200,1\le m\le 4\times10^4,1\le T\le 200,1\le w\le 10^6$。

首先不难想到二分答案。

然后我们考虑网络流建模：设二分的当前答案为 $k$，利用 $\trick{22}$，将 $\le k$ 的边权设为 $1$，$>k$ 的设为 $0$，这样其实等价于保留所有权值 $\le k$ 的边。然后我们只要判定该图的最大流是否 $\ge t$ 即可。

可这是无向图啊？这怎么跑网络流？

考虑一个有向图，我们建模时是有 $u\bedge w0 v$，其中 $v\dedge0u$ 是用于回流的。网络流增广的时候不会同时走两个方向，反边用于存储反流，而无向图中的这个反边仍然具有这个作用，因此是可以直接跑最大流的。

时间复杂度 $O(nm\log w)$。

---$AKB43$, '基础算法', array['图论建模', '倍增 Floyd', '分层图', '生成树'], 'col-basic-tricks-overview', null, 'knowledge'),
('stripe-python', 'col-basic-tricks-math--stripe-python', '数学与位运算技巧合集（GCD log / 曼哈顿互化 / 抽屉原理） · stripe-python', $AKB44$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 1. $(★)$ GCD log

>  ***一个数最多做 log 次改变其值的 gcd。***

### 例 1.1 [HDU 5869. Different GCD Subarray Query](https://acm.hdu.edu.cn/showproblem.php?pid=5869)

> 给定长度为 $n$ 的正整数序列 $a$，$q$ 次查询，每次查询给定 $l,r$，求 $a_{l\sim r}$ 的所有子段的互不相同的 gcd 个数。  
> $1\le n,q\le 10^5,1\le a_i\le 10^6$。

由于在固定一个 $l$ 时，对于所有 $r$，互不相同的 $\gcd\limits_{i=l}^r\{a_i\}$ 是 $\log V$ 级别的。于是我们考虑预处理出来这些块，然后把询问离线下来用 BIT 维护处理即可。

时间复杂度 $O(n\log n\log V)$。

### 例 1.2 [QOJ 9426. Relearn through Review](https://qoj.ac/problem/9426)

> 给定长度为 $n$ 的正整数序列，可以最多一次对某个区间 $[l,r]$ 内的数 $a_{l\sim r}$ 都 $+k$，最大化 $\gcd\{a_i\}$。  
> $1\le n\le 3\times 10^5,1\le k,a_i\le 10^{18}$。

暴力枚举是 $O(n^2)$ 的。考虑到前缀 gcd 是单调不升的，可以划分成若干个块。而每一块显然只要钦定对块首进行枚举计算即可。由于块数是 $\log n$ 级别的，故时间复杂度 $O(n\log^2n)$。

### 练习 1
- [Luogu P5502. 最大公约数](https://www.luogu.com.cn/problem/P5502)
- [CF1632D. New Year Concert](https://codeforces.com/problemset/problem/1632/D)

---

## 2. $(★☆)$ 奇（偶）数位反转

> ***当要对 01 String 进行相邻同项操作时，可以考虑对奇（偶）数位取反，转化为相邻异项操作。***

### 例 2-1. [Atcoder TKPPC6-2 B. Replace to Order](https://atcoder.jp/contests/tkppc6-2/tasks/tkppc6_2_b)

> 给定长度为 $n$ 的由 `AB` 组成的字符串 $S,T$，对 $S$ 进行任意次操作，每次选择一个子串 `AA`（`BB`），将其翻转为 `BB`（`AA`）。求从 $S$ 变成 $T$ 的最小操作次数，或报告无解。  
> $2\le n\le 2\times 10^5$。

考虑翻转偶数位，这样操作就变成了每次交换相邻的 `AB`（`BA`）。于是贪心地钦定考虑每个 `A` 的相对顺序下位置变化即可。时间复杂度 $O(n)$。

### 例 2-2. [QOJ 9565. Birthday Gift](https://qoj.ac/problem/9565)

> 给定长度为 $n$ 的由 $\tt012$ 构成的字符串，对其进行任意次操作，每次可以将一个 $\tt2$ 改成 $\tt0$ 或 $\tt1$，或者删去一个子串 $\tt00$ 或 $\tt11$。最小化操作后字符串的长度。  
> $1\le n\le 2\times 10^5$。

考虑翻转偶数位，这样第二个操作就变成了删去一个子串 $\tt01$ 或 $\tt10$。那么最后整个串一定是全 $\tt0$ 或全 $\tt1$ 的形式。

设字符串原来 $\tt0,1,2$ 的个数为 $c_0,c_1,c_2$。由于删子串的操作不会改变 $|c_0-c_1|$，因此对 $c_2$ 和 $|c_0-c_1|$ 的大小关系讨论即可。时间复杂度 $O(n)$。

### 练习 2
- [AGC040 C. Neither AB nor BA](https://atcoder.jp/contests/agc040/tasks/agc040_c)
- [AGC004 F. Namori](https://atcoder.jp/contests/agc004/tasks/agc004_f)
- [Luogu P10367. Żarówki](https://www.luogu.com.cn/problem/P10367)
- [Luogu P10068. Line Town](https://www.luogu.com.cn/problem/P10068)
- [QOJ 7509. 01tree](https://qoj.ac/problem/7509)

---

## 12. $(★★)$ 曼哈顿与切比雪夫互化

> ***当坐标系内涉及曼哈顿距离（切比雪夫距离）但是不好做时，可以考虑将坐标系旋转 $\textbf{\textit{45\degree}}$ 转化成切比雪夫距离（曼哈顿距离）。***

### 例 12-1. [Luogu P3964. 松鼠聚会](https://www.luogu.com.cn/problem/P3964)

> 平面上有 $n$ 个点 $(x_i,y_i)$，选择一个点 $(x,y)$，最小化 $\sum\limits_{i=1}^n\max\{|x-x_i|,|y-y_i|\}$。  
> $1\le n\le10^5,0\le |x_i|,|y_i|\le 10^9$。

切比雪夫距离不太好做，考虑转化为曼哈顿距离。

重建坐标系，令 $(x',y')=\left(\dfrac{x+y}2,\dfrac{x-y}2\right)$，则原坐标系的切比雪夫距离，就是新坐标系的曼哈顿距离。

然后就随便做了。

时间复杂度 $O(n\log n)$。

### 例 12-2. [Atcoder Code Festival 2017 QualA D. Four Coloring](https://www.luogu.com.cn/problem/AT_code_festival_2017_quala_d)

> 构造一个 $n\times m$ 的含有 `RYGB` 四种颜色的网格，使得所有曼哈顿距离恰好为 $d$ 的一对网格颜色互不相同。  
> $1\le n,m\le 500,1\le d\le n+m-2$

很容易往黑白染色上想，但是 $d$ 为偶数时似乎没有什么前途。

重建坐标系，令 $(x',y')=(x+y,x-y)$，则原坐标系的曼哈顿距离，就是新坐标系的切比雪夫距离。

然后可以对每 $d\times d$ 划出来，内部填入一种颜色，外部交替形如下：
$$
\def\red{\color{red}\rule{10px}{10px}}
\def\yel{\color{yellow}\rule{10px}{10px}}
\def\grn{\color{limegreen}\rule{10px}{10px}}
\def\blu{\color{skyblue}\rule{10px}{10px}}
\begin{aligned}
\red\yel\red\yel\red\yel\red\yel\\[-6.5pt]
\blu\grn\blu\grn\blu\grn\blu\grn\\[-6.5pt]
\red\yel\red\yel\red\yel\red\yel\\[-6.5pt]
\blu\grn\blu\grn\blu\grn\blu\grn\\[-6.5pt]
\red\yel\red\yel\red\yel\red\yel\\
\end{aligned}
$$
时间复杂度 $O(nm)$。

### 练习 12
- [Luogu P5098. Cave Cows 3 ](https://www.luogu.com.cn/problem/P5098)
- [Luogu P3439. MAG-Warehouse](https://www.luogu.com.cn/problem/P3439)
- [Luogu P2906. Cow Neighborhoods G](https://www.luogu.com.cn/problem/P2906)
- [Luogu P5193. 炸弹](https://www.luogu.com.cn/problem/P5193)
- [Luogu P4648. pairs 动物对数](https://www.luogu.com.cn/problem/P4648)
- [Luogu P7561. 道路の建設案 \(Road Construction\)](https://www.luogu.com.cn/problem/P7561)

---

## 22. $(★★☆)$ 序列值域转 01

> ***存在一个阈值 $\bm x$，要对 $\exbm{≤x}$ 的和 $\exbm{>x}$ 的操作时，可以考虑将 $\exbm{≤x}$ 的变为 $\bm 0$，$\exbm{>x}$ 的变为 $\bm 1$。***

### 例 22-1. [Luogu P2824. 排序](https://www.luogu.com.cn/problem/P2824)

> 给定一个 $1\sim n$ 的排列，$m$ 次操作，每次可以对一个下标区间在 $[l,r]$ 的数进行升序（降序）排序，所有操作结束后查询位置 $q$ 上的数。  
> $1\le n,m\le 10^5,1\le q\le n$。

正常的排序显然是不行的，考虑 $\trick{22}$，若转化成 $01$ 序列的排序，那么我们可以直接统计 $01$ 个数后区间覆盖。

将操作离线下来，考虑二分答案。假设现在二分的答案为 $\text{mid}$，那么我们就把 $\le\text{mid}$ 的设为 $0$，$>\text{mid}$ 的设为 $1$，然后用线段树维护过程，最终位置 $q$ 的数为 $0$ 就是合法的。

时间复杂度 $O(m\log^2n)$。

---

## 32. $(★☆)$ 精度舍弃

> ***在某些情况下，计算时可以舍弃对最终答案没有较大影响的、精度较高的数。***

### 例 32-1. [Luogu P11918. 考试 / Egzamin](https://www.luogu.com.cn/problem/P11918)

> 一共 $n$ 道小题，第 $i$ 小题有 $p_i$ 的概率答对，$1-p_i$ 的概率答错。答对加一分，打错扣一分。每道题可以自由选择是否作答，最大化答对至少 $t$ 道题的概率。精度 $10^{-6}$。  
> $1\le t\le n\le 5\times10^4,0\le p_i\le 1$，$p_i$ 的精度为 $10^{-9}$。

首先有一件显然的事情是我们降序 $p_i$ 后会选择一段前缀。

然后我们有一个朴素的 dp，$f_{i,j}$ 表示前 $i$ 个小题得 $j$ 分的概率。转移方程 $f_{i,j}=f_{i-1,j-1}\cdot p_i+f_{i-1,j+1}
\cdot(1-p_i)$。

直接做是 $O(n^2)$ 的。那我们实际发现，由于一次选择是二项分布的，然后随着 $n$ 的增长，会呈现一个正态分布，那么区间两侧会有相当一部分概率很小的状态，那么由于这里对答案已经没有影响了，我们钦定一个 $\varepsilon$ 直接舍弃 $\le\varepsilon$ 的即可。然后状态数就够了。沉石鱼惊旋说状态数是在 $O(n\sqrt{\ln\varepsilon^{-1}})$ 级别的。

### 例 32-2. [CF618G. Combining Slimes](https://codeforces.com/problemset/problem/618/G)
> 给定一个长度为 $n$ 的网格。现在在网格上做操作。每次从右端向左压入一个数，有 $m$ 的概率为 $1$，$1-m$ 的概率为 $2$。当有两个相邻的 $x$ 时，会向左合并成一个 $x+1$。求直到无法操作时网格所有数之和的期望。精度需要 $10^{-4}$ 的相对误差。
>
> $1\le n\le 10^9$，$10^{-9}\le m\le 1$。

首先根据期望的线性性，答案即为所有格子的期望之和。

设 $a_{i,j}$ 表示对于一个长度为 $i$ 的网格，其最左侧的数为 $j$ 的概率。那么转移需要前两个都出现 $j-1$，即有 $a_{i,j}=a_{i,j-1}\cdot a_{i-1,j-1}$。

设 $p_{i,j}$ 表示对于一个长度为 $i$ 的网格，其最左侧的数为 $j$，且 $j$ 不会被合并的概率。那么左侧第二个数必须不能是 $j$，所以有 $p_{i,j}=a_{i,j}\cdot(1-a_{i-1,j})$。

设 $f_{i,j}$ 表示最终的网格中**最右侧** $i$ 位中最左侧的数为 $j$ 时的期望和。考虑最终网格内数的情况。由于每次都会尽可能合并，因此对于相邻的两个数 $x,y$，一定满足 $x>y\lor x=1$。

于是当 $j\neq 1$ 时，可以直接枚举这 $i$ 位中左边第二个数 $k\ (k<j)$ 求期望，可以得到转移方程：

$$
f_{i,j}=j+\dfrac{\sum\limits_{k=1}^{j-1}f_{i-1,k}\cdot p_{i-1,k}}{\sum\limits_{k=1}^{j-1}p_{i-1,k}}
$$

当 $j=1$ 时就可能有 $k>j$ 了。但这时 $j$ 之后第一个压入的数一定为 $2$。

于是再 dp。设 $b_{i,j}$ 表示对于一个长度为 $i$ 的网格，第一次压入的数为 $2$，且最左侧的数为 $j$ 的概率。由于我们只关心左侧第一个数，所以有 $b_{i,j}=b_{i,j-1}\cdot a_{i-1,j-1}$。

和上面同理，设 $q_{i,j}$ 表示对于一个长度为 $i$ 的网格，第一次压入的数为 $2$，且最左侧的数为 $j$，且它不会被合并的概率。同理有 $q_{i,j}=b_{i,j}\cdot(1-a_{i-1,j})$。

于是这时 $f_{i,j}$ 的转移也是同理的，即为：

$$
f_{i,j}=j+\dfrac{\sum\limits_{k=2}^{m}f_{i-1,k}\cdot q_{i-1,k}}{\sum\limits_{k=2}^{m}q_{i-1,k}}
$$

于是最终的答案即为 $\sum\limits_{i=1}^np_{n,i}\cdot f_{n,i}$。

非常漂亮的 dp！可是时间复杂度全爆了！！！

注意到题目要求的精度并不高，进一步发现：
- 当 $j$ 足够大的时候，dp 值很小，可以忽略不计。
- 当 $i$ 足够大时，$p_{n,i}$ 几乎不变化。

于是考虑钦定一个阈值 $k=50$，对于所有 dp 的第二维，我们只计算到下标 $k$。而最终的答案计算，我们也只需要求出 $\sum\limits_{i=1}^np_{k,i}\cdot f_{n,i}$。

于是我们现在只需要处理出 $f_{n,[1,k]}$ 就好了。矩阵快速幂加速计算即可。

时间复杂度 $O(k^3\log n)$。

---

## 35. $(★★★)$ 抽屉原理转化
> ***当存在类似 $\bm{\le\dfrac 1k\times s}$ 之类约束的方案限制时，可以考虑转化为构造 $\bm{k}$ 种不受该约束的方案，其受约束的权值和恰好为 $\bm{s}$。***

### 例 35-1. [CF2057G. Secret Message](https://codeforces.com/problemset/problem/2057/G)

> 给定一个 $n\times m$ 的由 $\tt\#$ 和 $\tt .$ 构成的矩阵，设所有 $\tt\#$ 连通块的大小和为 $s$，周长和为 $p$。要求构造一种标记不超过 $\dfrac15(s+p)$ 个 $\tt\#$ 格的方案，满足对于所有 $\tt\#$ 格，其要么被标记，要么有一个与其有一条公共边的格子被标记。
>
> $1\le n\times m\le 2\times10^6$。

这个题目限制给的 $\dfrac 15$ 很奇怪。

考虑 $\trick{35}$：如果我们不考虑这个限制的情况下构造出了 $5$ 种合法方案，并且这些方案的 $|S|$ 之和恰为 $s+p$，根据抽屉原理，其中必然存在至少一个方案满足 $|S|\le\dfrac15(s+p)$。

这也太牛了！那我们怎么找到这五个方案呢？

考虑一种十字形的密铺：

$$
\def\sq{\rule{10px}{10px}}
\def\sq{\rule{10px}{10px}}
\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\\[-3px]
\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\\[-3px]
\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\\[-3px]
\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\\[-3px]
\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\\[-3px]
\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\\[-3px]
\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\red\sq\blue\sq\red\sq\\[-3px]
\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\blue\sq\red\sq\red\sq\\[-3px]
\red\sq\red\sq\red\sq\blue\sq\red\sq\blue\sq\blue\sq\blue\sq\red\sq\\[-3px]
$$

发现，如果我们选择了所有十字形中心，那么剩余未被影响到的格子就会在边上，我们在另外选择这些点即可。

注意到这些十字形中心的坐标 $(i,j)$ 满足 $(i+2j)\bmod5$ 同余，所以我们按照这种方式五染色，就能得到 $5$ 种合法方案了！

时间复杂度 $O(nm)$。

---

## 39. $(★★)$ 弦交错判相交

> ***可以通过圆所截出的弦是否相交（即在圆上的端点是否交错），来判断圆内是否有直线相交。***

### 例 39-1. [ABC263Ex. Intersection 2](https://atcoder.jp/contests/abc263/tasks/abc263_h)

> 给定 $n$ 条互不平行或重合的直线 $a_ix+b_iy+c_i=0$，$n$ 条直线总共会有 $\dfrac{n(n-1)}2$ 个交点（包含在同一个位置的点，即相同位置算不同的点），求距离原点第 $k$ 近的交点的欧几里得距离。
>
> $2\le n\le 5\times 10^4,1\le k\le \dfrac{n(n-1)}2,0\le|a_i|,|b_i|,|c_i|\le 10^3$。

考虑二分答案 $r$，此时问题就变成了圆 $x^2+y^2=r^2$ 内的交点数量。

运用 $\trick{39}$，就变成了圆内相交弦的对数。

将所有圆上的交点求出来后极角排序并离散化，按照更小的端点升序排序弦，做扫描线，用 BIT 维护区间内更大的端点的个数即为相交弦数量。

时间复杂度 $O(n\log n\log V)$。

### 例 39-2. [CF607E. Cross Sum](https://codeforces.com/problemset/problem/607/E)

> 给定 $n$ 条互不重合的直线 $y=\dfrac{k_i}{1000}x+\dfrac{b_i}{1000}$，两条不平行的直线之间会有一个交点（相同位置的交点多次计数），求距离点 $\left(\dfrac p{1000},\dfrac q{1000}\right)$ 前 $k$ 近的交点的欧几里得距离之和。
>
> $2\le n\le 5\times 10^4 $，$1\le k\le\min\left\{3\times10^7,\dfrac{n(n-1)}{2}\right\}$，$0\le|k_i|,|b_i|,|p|,|q|\le10^6$。

同上一题类似，二分后转化成圆上端点的情况。

由于交点数只要到 $m$，可以使用线段树套 vector 维护。

时间复杂度 $O(n\log n\log V+m)$。

---$AKB44$, '基础算法', array['数学技巧', '位运算', '曼哈顿距离', '抽屉原理'], 'col-basic-tricks-overview', null, 'knowledge'),
('dbywsc', 'col-basic-tricks-median--dbywsc', '中位数问题的 01 转化 trick · dbywsc', $AKB45$## 算法原理

很多与中位数有关的问题，直接维护中位数很困难。常用套路是：**二分答案 $x$，把数组转化成 01 串或 $+1/-1$ 串**：

- 大于等于 $x$ 的数记为 $1$，否则记为 $0$（或 $-1$）；
- 判断某个子数组的中位数是否 $\ge x$，只需要看这个 01 串中 $1$ 的数量是否足够；
- 如果 $1$ 的数量大于等于 $0$ 的数量（或区间和 $\ge0$），就说明中位数至少是 $x$。

这样就把“中位数”转成了“区间和/01 计数”，可以用前缀和、线段树、树状数组等维护。

## 核心公式 / 状态定义与转移方程

- 判定中位数 $\ge x$：令 $b_i=[a_i\ge x]$，若区间内 $1$ 的数量 $\ge$ 区间长度的一半，则中位数 $\ge x$。
- 用 $+1/-1$ 时：令 $b_i=+1$（$a_i\ge x$）或 $-1$（$a_i<x$），区间和 $\ge0$ 等价于中位数 $\ge x$。
- 若要求“中位数恰好为 $x$”，通常二分最后一个满足条件的 $x$。
- 排序操作转 01：区间内 $1$ 的个数为 $cnt$，升序排序后前 $len-cnt$ 个为 $0$、后 $cnt$ 个为 $1$；降序反过来。

## 逐行代码解析

### 二分中位数 + 二维前缀和

以“the Median of the Median of the Median”为例：二分答案 $x$，把每个数转成 $+1/-1$，用二维前缀和维护所有子数组的和；再对所有子数组的和做一次同样的转化，判断总和是否 $\ge0$。

```cpp
int s1[N][N];
int s[N], b[N][N];

void solve() {
    int n;
    cin >> n;
    vector<long long> a(n + 1);
    for (int i = 1; i <= n; i++) cin >> a[i];

    long long l = 0, r = *max_element(a.begin() + 1, a.end()), ans = 0;
    auto check = [&](long long x) -> bool {
        s[0] = 0;
        for (int i = 1; i <= n; i++) {
            int num = (a[i] <= x ? 1 : -1);
            s[i] = s[i - 1] + num;
        }
        for (int i = 1; i <= n; i++)
            for (int j = i; j <= n; j++)
                b[i][j] = (s[j] - s[i - 1] >= 0 ? 1 : -1);

        for (int i = 1; i <= n; i++)
            for (int j = 1; j <= n; j++)
                s1[i][j] = s1[i - 1][j] + s1[i][j - 1] - s1[i - 1][j - 1] + b[i][j];

        int sum = 0;
        for (int i = 1; i <= n; i++)
            for (int j = i; j <= n; j++) {
                int c = (s1[j][j] - s1[i - 1][j] - s1[j][i - 1] + s1[i - 1][i - 1] >= 0 ? 1 : -1);
                sum += c;
            }
        return sum >= 0;
    };

    while (l <= r) {
        long long mid = (l + r) / 2;
        if (check(mid)) {
            r = mid - 1;
            ans = mid;
        } else {
            l = mid + 1;
        }
    }
    cout << ans;
}
```

- `check(x)` 先把原数组转成 $+1/-1$，用一维前缀和求所有子数组的和，再转成 $+1/-1$ 放进二维数组。
- 二维前缀和用于快速求“所有子数组的和”这一层的区间和。
- 二分最小的可行 $x$，就是答案。
- 注意：原文这里把 $a_i\le x$ 记为 $1$、否则记为 $-1$，所以 `check(x)` 表示“中位数不超过 $x$”；二分找最小的 $x$，与前面“$a_i\ge x$ 记为 $1$”的叙述方向相反，本质等价。
- 代码是原文节选，`N`、`i64` 等宏/类型按你的模板补齐。

### 排序 + 线段树

以 P2824 [HEOI2016/TJOI2016] 排序为例：二分答案 $x$，把 $\ge x$ 设为 $1$、否则设为 $0$。每次排序操作变成：

1. 查询区间内 $1$ 的个数 $cnt$；
2. 升序：前 $len-cnt$ 个改为 $0$，后 $cnt$ 个改为 $1$；降序反过来。

用线段树支持区间赋值和区间求和。最后判断第 $q$ 位是否为 $1$，调整二分边界。

```cpp
struct SegTree {
    int n;
    std::vector<int> sum, tag;
    SegTree(int n_): n(n_) {
        sum.assign(4 * n, 0);
        tag.assign(4 * n, -1);
    }
    void pull(int o) {
        sum[o] = sum[o * 2] + sum[o * 2 + 1];
    }
    void apply(int o, int l, int r, int v) {
        sum[o] = v * (r - l + 1);
        tag[o] = v;
    }
    void push(int o, int l, int r) {
        if (tag[o] != -1) {
            int m = (l + r) / 2;
            apply(o * 2, l, m, tag[o]);
            apply(o * 2 + 1, m + 1, r, tag[o]);
            tag[o] = -1;
        }
    }
    void build(int o, int l, int r, const std::vector<int>& a) {
        tag[o] = -1;
        if (l == r) { sum[o] = a[l]; return; }
        int m = (l + r) / 2;
        build(o * 2, l, m, a);
        build(o * 2 + 1, m + 1, r, a);
        pull(o);
    }
    void build(const std::vector<int>& a) { build(1, 1, n, a); }
    int query(int o, int l, int r, int L, int R) {
        if (R < l || r < L) return 0;
        if (L <= l && r <= R) return sum[o];
        push(o, l, r);
        int m = (l + r) / 2;
        return query(o * 2, l, m, L, R) + query(o * 2 + 1, m + 1, r, L, R);
    }
    int query_sum(int x, int y) { return query(1, 1, n, x, y); }
    void update(int o, int l, int r, int L, int R, int v) {
        if (R < l || r < L) return;
        if (L <= l && r <= R) { apply(o, l, r, v); return; }
        push(o, l, r);
        int m = (l + r) / 2;
        update(o * 2, l, m, L, R, v);
        update(o * 2 + 1, m + 1, r, L, R, v);
        pull(o);
    }
    void update(int x, int y, int v) { update(1, 1, n, x, y, v); }
    int query_point(int p) {
        return query(1, 1, n, p);
    }
};

void solve() {
    int n, m, q;
    std::cin >> n >> m;
    std::vector<int> a(n + 1);
    std::vector<int> op(m + 1), L(m + 1), R(m + 1);
    for (int i = 1; i <= n; i++) std::cin >> a[i];
    for (int i = 1; i <= m; i++) std::cin >> op[i] >> L[i] >> R[i];
    std::cin >> q;

    SegTree seg(n);
    auto check = [&](int x) -> bool {
        std::vector<int> b(n + 1);
        for (int i = 1; i <= n; i++) b[i] = (a[i] >= x ? 1 : 0);
        seg.build(b);
        for (int i = 1; i <= m; i++) {
            int cnt = seg.query_sum(L[i], R[i]);
            if (op[i] == 0) {
                seg.update(L[i], R[i] - cnt, 0);
                seg.update(R[i] - cnt + 1, R[i], 1);
            } else {
                seg.update(L[i], L[i] + cnt - 1, 1);
                seg.update(L[i] + cnt, R[i], 0);
            }
        }
        return seg.query_point(q);
    };

    int l = 1, r = n, ans = 1;
    while (l <= r) {
        int mid = (l + r) / 2;
        if (check(mid)) {
            ans = mid;
            l = mid + 1;
        } else {
            r = mid - 1;
        }
    }
    std::cout << ans;
}
```

- 线段树维护 01 串的区间和与区间赋值。
- 排序操作被拆成“查询 $1$ 的个数 + 两段区间赋值”。
- 二分答案的单调性：$x$ 越大，01 串中 $1$ 越少，第 $q$ 位越容易是 $0$。
- 以上为原文实现的节选；`std::` 前缀、头文件等按你的模板补齐。

### Range Sort Query

ABC237G 允许两种排序方向，并要求找出值为 $x$ 的位置。做法是：

- 第一次把 $\ge x$ 设为 $1$、否则 $0$，跑完所有排序；
- 第二次把 $>x$ 设为 $1$、否则 $0$，再跑一遍；
- 两次结果只有值为 $x$ 的位置不同，比对两次数组即可找到答案。

```cpp
void solve() {
    int n, m, q;
    std::cin >> n >> m >> q;
    std::vector<int> a(n + 1);
    std::vector<int> op(m + 1), L(m + 1), R(m + 1);
    for (int i = 1; i <= n; i++) std::cin >> a[i];
    for (int i = 1; i <= m; i++) std::cin >> op[i] >> L[i] >> R[i];

    SegTree seg(n);
    std::vector<int> b(n + 1);
    for (int i = 1; i <= n; i++) b[i] = (a[i] >= q ? 1 : 0);

    auto work = [&](std::vector<int>& x) -> void {
        for (int i = 1; i <= m; i++) {
            int cnt = seg.query_sum(L[i], R[i]);
            if (op[i] == 1) {
                seg.update(L[i], R[i] - cnt, 0);
                seg.update(R[i] - cnt + 1, R[i], 1);
            } else {
                seg.update(L[i], L[i] + cnt - 1, 1);
                seg.update(L[i] + cnt, R[i], 0);
            }
        }
        for (int i = 1; i <= n; i++) x[i] = seg.query_point(i);
    };

    seg.build(b);
    work(b);
    std::vector<int> c(n + 1);
    for (int i = 1; i <= n; i++) c[i] = (a[i] > q ? 1 : 0);
    seg.build(c);
    work(c);
    for (int i = 1; i <= n; i++) {
        if (b[i] != c[i]) {
            std::cout << i << '\n';
            return;
        }
    }
}
```

### Median Pyramid Hard

AGC006D 的 01 金字塔：每个格子由下面三个格子的多数决定。二分答案 $x$，把 $\ge x$ 设为 $1$、否则 $0$。观察发现，最顶端的值取决于最底层中“离中心最近的两个连续相同数字”：

- 从中心向两边找第一个连续两个 $1$ 或连续两个 $0$；
- 若先找到两个 $1$，顶端为 $1$；先找到两个 $0$，顶端为 $0$；
- 若整层是交替的 `a b a b ...`，顶端等于最左边的数字。

这样每次 `check` 只需要 $O(n)$，总复杂度 $O(n\log V)$。

```cpp
void solve() {
    int n;
    std::cin >> n;
    std::vector<int> a(n * 2);
    for (int i = 1; i <= n * 2 - 1; i++) std::cin >> a[i];

    int l = 1, r = 2 * n - 1, ans = 0;
    auto check = [&](int x) -> bool {
        for (int i = 0; i < n - 1; i++) {
            if ((a[n + i] > x && a[n + i + 1] > x) ||
                (a[n - i] > x && a[n - i - 1] > x)) return false;
            if ((a[n + i] <= x && a[n + i + 1] <= x) ||
                (a[n - i] <= x && a[n - i - 1] <= x)) return true;
        }
        return a[1] <= x;
    };

    while (l <= r) {
        int mid = (l + r) / 2;
        if (check(mid)) {
            r = mid - 1;
            ans = mid;
        } else {
            l = mid + 1;
        }
    }
    std::cout << ans;
}
```

## 复杂度分析

- QOJ 中位数：二分 $O(\log V)$，每次二维前缀和 $O(n^2)$，总 $O(n^2\log V)$，空间 $O(n^2)$。
- P2824 排序：二分 $O(\log n)$，每次线段树 $O((n+m)\log n)$，总 $O((n+m)\log^2 n)$。
- ABC237G：两次线段树模拟，$O((n+m)\log n)$。
- AGC006D：二分 $O(\log V)$，每次 $O(n)$，总 $O(n\log V)$。

## 适用场景

- 题目要求“子数组的中位数”“中位数的中位数”“排序后第 $k$ 位”等。
- 操作只与“大于等于某个数”有关，且可以把值转成 01。
- 需要维护区间排序、区间 01 计数、区间赋值。
- 单峰/单调的判定问题，可以用二分答案 + 01 转化。

## 常见陷阱与注意事项

1. **二分方向**：把 $\ge x$ 设为 $1$ 还是 $>x$ 设为 $1$，会影响“第 $q$ 位是 $1$ 时移动哪边”，要按题意推。
2. **中位数的定义**：长度为偶数时，中位数可能取中间两个的较小/较大/平均；题目通常会有明确定义，先看清。
3. **`+1/-1` 与 `1/0` 的区别**：`+1/-1` 看区间和 $\ge0$；`1/0` 看 $1$ 的个数是否过半。两者等价但边界不同。
4. **排序操作的区间边界**：`cnt` 个 $1$ 放在后面（升序）还是前面（降序），不要写反。
5. **线段树的懒标记**：区间赋值要下传，查询/更新前先 `push`。
6. **二维前缀和的空间**：$n$ 较大时二维数组可能 MLE，注意题目范围。
7. **二分的答案范围**：$l,r$ 要覆盖所有可能的中位数，通常取最小值到最大值。

## 对比与扩展

- **01 转化 vs 直接维护中位数**：直接维护需要平衡树/对顶堆，代码复杂；01 转化把问题变成计数/排序，配合线段树更通用。
- **二分答案 vs 整体二分**：单组询问用二分答案；多组询问且操作可离线时可以用整体二分。
- **线段树 vs 树状数组**：排序操作需要区间赋值，线段树更合适；只做单点修改/区间求和可以用树状数组。
- **同类题**：QOJ the Median of the Median of the Median、P2824 排序、ABC237G Range Sort Query、AGC006D Median Pyramid Hard。$AKB45$, '基础算法', array['中位数', '01转化', '二分答案', '线段树', 'trick'], 'col-basic-tricks-overview', null, 'knowledge'),
('world-needs-sunday', 'col-basic-tricks-overview', '优化技巧总览（DP / 数据结构 / 图论 / 数学 / 序列 / 套路）', $AKB46$## 算法原理

本页是「优化技巧」的二级栏目索引：收纳跨题型的通用技巧与结论，按方向分成 DP、数据结构、图论、数学、序列、做题套路与交互模型七篇。

**学习顺序**：先看「做题套路与结论汇总」建立框架，再按当前薄弱方向补对应合集。

## 核心公式 / 状态定义与转移方程

**按方向选子栏目**：

| 方向 | 子条目 |
|---|---|
| 通用解题流程与结论 | 做题套路与结论汇总 |
| DP / 计数技巧 | DP 与计数技巧合集（耳分解 / 补集转化 / 贡献拆解） |
| 数据结构技巧 | 数据结构技巧合集（倍增并查集 / 单侧递归线段树 / BIT 倍增） |
| 图论建模技巧 | 图论建模技巧合集（倍增 Floyd / 分层图 / 环相关） |
| 数学与位运算技巧 | 数学与位运算技巧合集（GCD log / 曼哈顿互化 / 抽屉原理） |
| 序列与实现技巧 | 序列与实现技巧合集（离线倒序 / 值域随机映射 / 分部分做法） |
| 交互/通信题 | 交互与通信题经典模型（猜数 / 毒药 / Hamming） |

## 逐行代码解析

本页只做导航，不重复贴代码；各合集页按「技巧条目」组织，每条给出适用条件与实现要点。

## 复杂度分析

按具体技巧而定；合集页会标注每条技巧的复杂度与优化幅度。

## 适用场景

- 正解想到但复杂度过高，需要降复杂度。
- 题目形式不常规，需要建模/转化。
- 交互题、通信题等特殊题型。

## 常见陷阱与注意事项

- 技巧有适用前提，先验证条件再套用。
- 合集是索引，不能替代对原题的分析。
- 同一技巧在不同题型下实现细节不同。
- 交互题注意刷新缓冲区与询问次数上限。
- 结论类技巧要能说明正确性，不能只背结果。

## 对比与扩展

- 技巧合集 vs 单点知识：前者横向串联，后者纵向深入。
- 遇到新技巧时优先补进对应合集，而不是新开散页。$AKB46$, '基础算法', array['技巧合集', '优化', '套路', '总览', '学习路线'], null, null, 'knowledge'),
('stripe-python', 'col-basic-tricks-sequence--stripe-python', '序列与实现技巧合集（离线倒序 / 值域随机映射 / 分部分做法） · stripe-python', $AKB47$> 本文由 stripe-python 授权合并，正文保留原文结构与表述；原文为《Some Simple Tricks》，本页按主题合并其中若干条技巧。

## 9. $(☆)$ 括号串拼接

> ***两个合法括号串拼接时，新串较原来会多出一个子串 `)(`。***

### 例 9-1. [CF1726C. Jatayu's Balanced Bracket Sequence](http://codeforces.com/problemset/problem/1726/C)

> 给定长度为 $2n$ 的合法括号串 $S$，第 $i$ 个字符可以看作编号为 $i$ 的节点，存在无向边 $(x,y)$ 当且仅当 $S[x:y]$ 是一个合法括号串。求该图连通块个数。  
> $1\le n\le 10^5$。

首先对于 $\texttt{((...))}$ 的串，每一对括号之间都是互不影响的。连通块个数会减一当且仅当两个合法括号串拼接产生。而两个合法括号串拼接时中间恰好会多出来一个子串 `)(`。因此记 $S$ 中 `)(` 的数量为 $c$，答案为 $n-c$。时间复杂度 $O(n)$。

---

## 24. $(★)$ 大小调整取等

> ***假设任意选择某个集合，其权值既可能大于，也可能小于一个给定值，如果可以通过调整将权值 $\boldsymbol{\pm 1}$，则可以取到等号。***

### 例 24-1. [CF1658F Juju and Binary String](https://codeforces.com/problemset/problem/1658/F)

> 给定一个长度为 $n$ 的 $\tt01$ 串，要求取最少的不相交子串，要求：
> - 取出的子串长度和为 $m$。
> - 这些子串总的 $\tt0$ 个数和总的 $\tt1$ 个数的比值和原串相同。
>
> 给出一种可行方案，或报告无解。  
> $1\le m\le n\le 2\times10^5$。

设 $s$ 中 $\tt 1$ 的个数为 $c_1$，则选取的子串的 $\tt 1$ 个数和为 $c=\dfrac{c_1m}n$，故 $n\nmid c_1m$ 则无解。

考虑 $\trick{24}$。也就是有一个搞笑的事情是，你在取的过程中一定是 $>c$ 和 $<c$ 的情况都有的，而对于这两种情况，他们中间必然是对 $\tt 1$ 的个数进行 $\pm1$ 的调整，所以一定会出现 $=c$ 的情况。因此答案上界为 $2$。

时间复杂度 $O(n)$。

---

## 25. $(★)$ 从叶向根

> ***对于树上的操作，可以考虑从叶子节点向上操作。***

### 例 25-1. [Luogu P11762. 走亲访友](https://www.luogu.com.cn/problem/P11762)

> 给定一个 $n$ 点 $m$ 边的无向连通图（无自环、重边），你需要构造一组满足下面要求的路径：
> - 起点为 $s$，终点不限。
> - 对于走过的每一组边 $(u_i,v_i)$，你需要额外决定 $p_i\in\{0,1\}$，满足：
>   1. $p_i=0$ 表示删除这条边，且不能再使用，即之后不能再次经过这条边；$p_i=1$ 表示不删除这条边，可以经过多次。
>   2. 如果 $i>1$，那么 $u_i=v_{i-1}$。即使 $p_i=0$，也需要满足这条限制。
> - 路径的长度不能超过 $k$。
> - 最后未删除的边组成一棵 $n$ 个节点的树。
>
> 保证存在一个合法的方案。  
> $1\le u_i,v_i,s\le n\le 1000,1\le m\le\dfrac{n(n-1)}2,k\ge n+m$。

首先可以容易得到一个上限为 $2m$ 的做法：直接暴力 dfs，搜到一个非树边就返回并清除该边。

这个看起来没什么前途，因为我们的瓶颈在于每条边都要来回走，中间浪费了很多。

但是给了我们启示，发现它是一个欧拉回路。

于是就考虑能否将我们走的路径构成欧拉回路。

但是显然，图中的奇度点较多，如何处理？

考虑 $\trick{5}$ ，将在图上的决策转化为生成树上。然后再利用 $\trick{25}$，我们可以从叶子开始从下往上给树边加重边。由于一条边会对两个节点的度数贡献，所以最后到根节点的时候根的度数一定是偶数。

然后我们跑欧拉回路即可。

由于每条树边最多被加一次重边，所以最坏路径长度为 $2(n-1)+m-(n-1)=m+n-1$，恰好在限制范围内。

时间复杂度 $O(n+m)$。

---

## 27. $(★☆)$ 操作离线倒序

> ***当操作直接做比较困难时，可以考虑离线下来倒着做。***

### 例 27-1. [Luogu P2391. 白雪皑皑](https://www.luogu.com.cn/problem/P2391)

> 给定长度为 $n$ 的序列 $a$，初始 $a_i=0$。$m$ 次操作，每次操作给定区间 $[l,r]$ 和正整数 $x$，将 $a_{l\sim r}$ 全改为 $x$。求最后每个位置上的数。  
> $1\le n\le 10^6,1\le m\le 10^7,1\le x\le 2\times 10^9$。

直接维护显然会爆。

由于我们只关心最后的数，所以我们考虑把操作离线下来，倒过来做。

对于一个区间 $[l,r]$，若答案都未确定，那么 $x$ 就是这些数的最终答案。而此后我们都不需要管这些数了。直接用链表或并查集维护即可。

由于每个数只会访问一次，故时间复杂度为 $O(n+m)$ 或 $O(n\log n+m)$。

### 例 27-2. [Luogu P11674. Reachable Pairs G](https://www.luogu.com.cn/problem/P11674)

> 给定 $n$ 点 $m$ 边的无向图，并给定一个长度 $n$ 的 $\tt01$ 串 $s$，表示进行 $n$ 次操作。对于第 $i$ 次操作，若 $s_i=0$，则在图中删去点 $i$；若 $s_i=1$，则在图中删去点 $i$ 的同时给每个原来与其相连的节点之间两两加边。每次操作后，都查询两两可达的节点对数。  
> $1\le n\le 2\times10^5,0\le m\le 4\times10^5,s_i\in\{0,1\}$。

维护删点是不好做的，但是维护加点是更为容易的。考虑离线下来倒着做。

更进一步地，我们将节点黑白染色，黑色代表当前不存在该节点，白色反之。

那我们只需要加边维护连通块内白点数量就可以了。并查集容易做到。时间复杂度 $O(n\alpha (n)+m)$。

### 练习 27
- [Luogu P9715. 头](https://www.luogu.com.cn/problem/P9715)
- [Luogu P6351. Hard Choice](https://www.luogu.com.cn/problem/P6351)

## 28. $(★)$ 权值减下标

> ***对于一些和序列递增相关的东西，可以考虑将权值减去下标。***

### 例 28-1. [CF2009G1 Yunli's Subarray Queries (easy version)](https://codeforces.com/problemset/problem/2009/G1)

> 给定长度为 $n$ 的正整数序列 $a_i$ 和正整数 $k$，$q$ 次询问，每次查询一个区间 $[l,r]$，问使得存在 $i\in[l,r-k+1]$ 有对于 $\forall j\in[i,i+k),a_j+1=a_{j+1}$ 的最少修改次数。  
> $1\le k,a_i\le n\le 2\times10^5,1\le q\le 2\times10^5,\bm{r-l+1=k}$。

令 $a'_i=a_i-i$，那么问题等价于使得一个区间存在长度至少为 $k$ 的颜色段的最少操作次数。滑动窗口预处理即可。

时间复杂度 $O(n+q)$。

### 例 28-2. [Luogu P11833. 推箱子](https://www.luogu.com.cn/problem/P11833)

> 数轴上给定 $n$ 个依次排列的箱子，每个单位时间内可以移动一个箱子一个单位长度，而第 $i$ 个箱子要在开始移动后的 $t_i$ 个单位时间内从初始的 $a_i$ 移动到 $b_i$，问能否达成要求。$T$ 组数据。  
> $1\le T\le 6,1\le n\le 2\times10^5,1\le a_i,b_i\le 10^9,0\le t_i\le 10^{16}$，并且满足 $\forall i\in[1,n),a_i<a_{i+1},b_i<b_{i+1}$。

首先有一个显然的贪心是按 $t_i$ 升序做。

考虑维护这样的过程。对于正在移动的第 $i$ 个箱子，当前位置到目标位置 $b_i$ 间必然有很多箱子，我们当然选择尽量少的移动它们——即将需要移动的箱子区间 $[l,r]$ 位置变为 $b_i,b_i+1,b_i+2,\cdots$。找到这个右界，我们可以线段树二分，而修改我们自然可以修改为等差数列，线段树标记即可。

当然，为了更加简便，可以将 $a_i,b_i\upd{--}i$，这样就可以直接用线段树区间覆盖，更为简便。

时间复杂度 $O(Tn\log n)$。

---

## 29. $(★★★)$ 值域随机映射

> ***遇到一些和值域关系不大的题时可以考虑将值域随机重新映射。***

### 例 29-1. [CF1746F. Kazaee](https://codeforces.com/problemset/problem/1746/F)

> 给定长度为 $n$ 的序列 $a$，$m$ 次操作，每次操作可以单点修改，或给定区间 $[l,r]$ 查询是否对于 $\forall k\in[l,r],\ k\left|\sum\limits_{i=l}^r[a_i=a_k]\right.$。  
> $1\le n,m\le 3\times10^5,1\le a_i\le 10^9,3\sec$。

这个东西看着就很带修莫队，但是并不太能做。

考虑查询操作所满足的要求。将这个条件弱化，也就是变成一个必要不充分条件，有 $k\left|\sum\limits_{i=l}^ra_i\right.$，因为考虑对于每个数 $i$，其贡献了出现次数 $c_i$ 次，即 $\sum i\cdot c_i$，由于 $k\mid c_i$，所以 $k\left|\sum\limits_{i=l}^ra_i\right.$ 一定满足。

显然直接判这个条件是只会有错误判为正确的情况的。这种情况的原因在于会出现 $k\mid i,k\nmid c_i$ 的情况。注意到值本身对我们来说没有任何作用。利用 $\trick{29}$，将每个数 $x$ 重新映射到一个值域内的另一个数 $y$。原先错误的概率为 $\dfrac1k$，假设重新映射 $x$ 次，那么概率就是 $\dfrac1{k^x}$，非常小。考虑最坏 $k=2$，所以取 $x=\log V\approx30$ 就足够了。

时间复杂度 $O(n\log^2n)$。

---

## 30. $(★★★)$ 分部分做法

> ***一些问题直接用某种做法并不好做，但是在一定次数的某种做法后会满足某些性质，并使用另一种做法。***

### 例 30-1. [CF1704E. Count Seconds](https://codeforces.com/problemset/problem/1704/E)

> 给定 $n$ 点 $m$ 边的 DAG，点 $i$ 初始有点权 $a_i$。每个单位时刻内，会首先令 $S=\{i\mid a_i>0\}$，然后对于每个 $x\in S$，$a_x\upd{--}1$，接着对于 $\forall(x,y)\in E,a_y\upd+1$。求出所有 $a_i=0$ 的最早时刻，答案对 $998244353$ 取模。  
> $1\le n,m\le 10^3,1\le a_i\le 10^9$。

一个直接的想法是 dp，设 $f_i$ 表示点 $i$ 变成 $0$ 的最早时刻，这样就有初始 $f_i=a_i$，$\forall (i,j)\in E,f_j\upd+f_i$。

但是你注意到有的点会随着时间的流逝先 $=0$，又 $>0$，又 $=0$。

对于 DAG，源点到汇点的最长路 $\le n$，走过这条最长路之后，所有的点都一定被流动到了点权——换句话说，最多 $n$ 个时间单位之后，这种情况不会再出现了。于是 $n$ 次模拟后，我们就可以直接 dp 了。

时间复杂度 $O(n^2)$。

### 例 30-2. [Luogu P8179. Tyres](https://www.luogu.com.cn/problem/P8179)

> 有 $n$ 种轮胎，需要用这些轮胎共跑 $m$ 圈。对于第 $i$ 种轮胎，它跑的第 $j$ 圈（对每种轮胎单独计数）的代价为 $a_i+b_i(j-1)^2$，每相邻两圈使用了不同的轮胎，则需要增加 $t$ 的代价。求最小代价。
>
> $1\le n,b_i\le 500$，$0\le t\le 500$，$1\le m\le 2\times 10^5$，$1\le a_i\le 10^9$。

当 $t=0$ 时显然是可以用堆贪心的。

$t>0$ 时由于多了换胎的代价，所以无法贪心。

首先考虑朴素 dp。设 $f_{i,j}$ 表示前 $i$ 种轮胎，总共已经跑了 $j$ 圈的最小代价。

设 $w_i(x)=\sum\limits_{j=1}^x(a_i+b_i(j-1)^2)$，有转移方程 $f_{i,j}=\min\left\{f_{i-1,j},f_{i-1,0}+w_i(j),\min\limits_{k=1}^j\{f_{i-1,j-k}+w_i(k)+t\}\right\}$。把 $w_i(x)$ 拆开后可以 $O(nm^2)$ 转移。

考虑如何优化。利用 $\trick{30}$，尝试对于一种轮胎，寻找到一个 $k$ 满足第 $k$ 圈的代价不优于第 $1$ 圈的代价，即 $a_i+t\le a_i+b_i(k-1)^2$。这样对于 $\ge k$ 的圈是单调上升的，可以直接贪心。

注意到 $k=\lceil\sqrt t\rceil+1$ 一定满足上述不等式，故对于 $<k$ 的进行 dp，对 $\ge k$ 进行贪心，最后合并答案即可。

时间复杂度 $O(n^2t+m\log n)$。

---

## 31. $(★★☆)$ 最值分治

> **对于序列内的一个数成为区间最值的极长区间，以该数为分界点，较短的那一段的长度和是 $\bm{O(n\log n)}$ 级别的。**

### 例 31-1. [CF1777F Comfortably Numb](https://codeforces.com/problemset/problem/1777/F)

> 给定长度为 $n$ 的正整数序列 $a$，求 $\max\limits_{1\le l\le r\le n}\left\{\max\limits_{i=l}^r\{a_i\}\oplus\bigoplus\limits_{i=l}^ra_i\right\}$。  
> $1\le n\le 2\times10^5,1\le a_i\le 10^9$。

考虑一个数 $a_i$ 成为区间最大数的极长区间 $[l_i,r_i]$，根据 $\trick{31}$，我们考虑枚举 $[l_i,i],[i,r_i]$ 中较短的一段，然后使用 01 Trie 处理即可。

下面来补充证明一下 $\trick{31}$ 的正确性。对于一个序列，我们全局最大值会贡献至多 $\dfrac n2$，对于被这个数划分成的两段，段内的最大值对应的极长区间显然不会跨越这个分界点，因此两侧的段最多贡献 $2\cdot\dfrac n4$。以此类推，就是 $\dfrac n2+2\cdot\dfrac n4+4\cdot\dfrac n8+\cdots=\dfrac n2\log n=O(n\log n)$。

时间复杂度 $O(n\log n\log a_i)$。

---

## 36. $(★★)$ 前缀和或差分转化操作
> ***可以考虑用前缀和或差分转化看似无从下手的操作。***

### 例 36-1. [AGC052 B. Tree Edges XOR](https://atcoder.jp/contests/agc052/tasks/agc052_b)

> 给定一棵 $n$ 个节点的树，第 $i$ 条边的边权为 ${w_1}_i$。现可以任意次操作，每次可以选择一条边，将所有与其相邻的边异或上该边的权值。问是否可以将所有 ${w_1}_i$ 变为 ${w_2}_i$。
>
> $1\le n\le 10^5,1\le w_{1_i},w_{2,i}\le2^{30}$，$n$ 为奇数。

模拟一下变换，发现前缀异或和是一个交换状物。

将节点 $x$ 的权值 $w'_i$ 设为根到 $x$ 的路径上的边权异或和。那么原来对一条边的操作，就等价于交换相邻节点的权值。于是我们直接比较 $\{w'_i\}$ 和 $\{{w_1}_i\}$ 是否相同即可。

注意由于根的问题，我们最后需要对所有节点异或上 $\left(\bigoplus{w_1}_i\right)\oplus\left(\bigoplus{w_2}_i\right)$（这也是为什么 $n$ 只能是奇数的原因）。

时间复杂度 $O(n)$。

### 例 36-2. [Luogu P7962. 方差](https://www.luogu.com.cn/problem/P7962)

> 给定一个长度为 $n$ 的单调不降的序列 $a$。任意次操作，每次可以选择一个 $i\in(1,n)$，执行 $a_i\gets a_{i-1}+a_{i+1}-a_i$。最小化 $a$ 的方差。输出最小值 $\times n^2$ 的结果。
>
> $1\le n\le 10^4$，$1\le a_i\le 600$，$1\le n\times a_i\le 5\times10^5$。

考虑将 $a$ 序列差分，令 $d_i=a_{i+1}-a_i$。那么这个操作等价于交换了 $d_{i-1}$ 和 $d_i$。于是考虑 $a$ 的方差 $s^2$ 取到最小值时，$d$ 满足的性质。

事实上可以得到结论，$s^2\to\min$ 时，$d$ 会呈一个单谷的状态。证明推荐阅读 [这篇题解](https://www.luogu.com.cn/article/4csmcz4o)。然后可以进一步 dp。上述题解中也有说明。由于该题的后半部分不是我们要阐述的重点，故不多详细展开。

---

## 37. $(★★★☆)$ 操作过程按位划分

> ***对于一些操作过程，可以考虑某一种操作对状态造成的影响，由此以某种特征状态对过程进行划分处理。***

### 例 37-1. [AGC061E. Increment or XOR](https://atcoder.jp/contests/agc061/tasks/agc061_e)

> 有一个非负整数变量 $x$，初值为给定的 $s$。另外有长度为 $n$ 的序列 $y$ 和 $c$。进行任意顺序、任意多次的以下操作之一：
>
> - $x\gets x+1$，花费代价为给定的常数 $a$。
> - $x\gets x\oplus y_i$，花费代价为 $c_i$。
>
> 求 $x$ 从 $s$ 变为 $t$ 的最小代价，或报告无解。
>
> $1\le n\le 8,0\le s,t,y_i<2^{40},0\le a\le 10^5,0\le c_i\le 10^{16}$。

考虑 $+1$ 操作带来的影响。

在二进制下，$+1$ 操作会使得末尾的一段极长的 $1$ 全部变成 $0$，并且更高一位变为 $1$。那么对于最低的若干位，它值的变化是 $s\to 0\to t$ 的。这样子的话我们只要考虑 $x$ 最低若干位初始是 $s$ 和 $0$ 的情况，而最终结果就是 $0$ 和 $t$。

于是可以设计状态 $f_{i,p,q,S}\ (p,q\in\{0,1\})$，表示对于最低的 $0\sim i-1$ 位，初值是 $s/0$，终值是 $t/0$，过程中所有实际异或的 $y_i$ 下标集合为 $S$ 的最小代价。

初值有 $f_{0,p,q,S}=\sum\limits_{i\in S}c_i+q\cdot a$。

考虑转移过程。首先最简单地，若对于第 $i$ 位，它是匹配的，则有 $f_{i+1,p,q,S}\gets f_{i,p,q,S}$。

接下来考虑产生新进位的情况。

我们首先从 $p$ 开始，做一次操作后，有第 $i$ 位为 $1$（更高的位不影响）；然后进行若干次进位操作，仍然保证第 $i$ 位为 $1$（更高的位不影响）；最后做一次操作，保证进到第 $i$ 位的时候满足了 $q$。

也就是有 $f_{i+1,p,q,\bigoplus\limits_{j=0}^kS_j}\upd{min}f_{i,p,1,S_0}+\left(\sum\limits_{j=1}^{k-1}f_{i,1,1,S_j}\right)+f_{i,1,q,S_k}$。可以类似 Dijkstra，每次取出未使用过的最小的 $f_{i,p,1,S}$ 转移即可。

最终答案就是 $\min\{f_{40,0,0,S}\}$。时间复杂度 $O(2^{2n}\log V)$。

### 例 37-2. [UOJ 659. Picks loves segment tree IX](https://uoj.ac/problem/659)

> 给定长度为 $n$ 的，对于非负整数变量 $v$ 的操作序列。其中有四种操作：
>
> - $\texttt{| }x$：$v\upd{or}x$。
> - $\texttt{\& }x$：$v\upd{and}x$。
> - $\texttt{∧ }x$：$v\upd{xor}x$。
> - $\texttt{+ }x$：$v\upd{+}x\pmod{2^{32}}$，此时保证 $x=1$。
>
> $q$ 次询问，每次给出 $v,l,r,t$，求对 $v$ 依次进行下标为 $[l,r]$ 的操作后，二进制下从低到高第 $t+1$ 位的值。
>
> **强制在线。**
>
> $1\le l\le r\le n\le 10^5,1\le q\le 6\times 10^5,0\le x,v<2^{32},0\le t<32$，$2\sec$。

同上一题一样，考虑 $+1$ 的影响后，我们可以对低位 $0$ 的个数划分状态。

记 $f_{k,i}$ 表示第 $i$ 次操作前最低的 $k+1$ 位都是 $0$，这些位同时第一次回到全 $0$ 的操作次数。这个有一个好处是，我们可以直接跳 $f_{k,i}$ 忽略掉 $+1$ 操作了。

那考虑如何计算最低 $k+1$ 位同时归零的时间。设 $g_{k,i}$ 表示一开始最低 $k+1$ 位呈现为 $100\cdots00$ 的形式，进行下标为 $[i,g_{k_i}-1]$ 操作后，最低 $k+1$ 位第一次全部同时变为 $0$，即呈现 $000\cdots00$ 的形式。

求 $f,g$ 都是容易的。

考虑答案求解。$g$ 是可以直接暴力跳的，而对于 $f$，我们建树后上树剖+二分即可。

时间复杂度 $O(n\log^2 V)$。

---$AKB47$, '基础算法', array['实现技巧', '离线', '差分', '随机化'], 'col-basic-tricks-overview', null, 'knowledge'),
('Fohen', 'col-basic-two-pointer--fenfeng', '双指针（思想） · Fohen', $AKB48$## 算法原理

双指针是一种通过同时维护两个下标、在线性遍历中减少重复计算的算法思想。两个指针通常表示区间的左右端点，也可以分别指向两个序列中的当前位置。当指针满足某种单调移动规律时，就不必反复枚举已经处理过的位置，从而把朴素的 $O(n^2)$ 双重枚举优化到接近 $O(n)$。

按指针的移动方向与作用，双指针常见有三种形态：

- **同向双指针**：两个指针从左到右同方向移动，右指针负责向右扩展区间，左指针在区间不满足条件时向右收缩，常用于维护满足条件的连续区间，也就是滑动窗口。
- **相向双指针**：两个指针分别从序列两端向中间移动，通过端点值的大小关系决定移动哪个指针，通常要求数组有序，常用于查找与配对问题。
- **双序列指针**：分别在两个序列上维护当前位置，比较所指元素后推进对应指针，常用于合并、匹配、求交集。

三种形态的共同点是**单调性**：每个指针只朝一个方向移动、不回退，因此整体扫描保持线性，而不是像双重枚举那样反复回到已处理过的位置。

## 核心公式 / 状态定义与转移方程

双指针没有统一的递推公式，其核心在于维护「可行窗口」或「两个位置」，关键是窗口信息的增量更新与指针移动的决策条件。以滑动窗口（同向双指针）为例，可作如下状态描述：

- 设窗口为区间 $[l, r]$，记 $f(l, r)$ 表示该区间是否满足条件。
- **右指针扩展**：$r \leftarrow r + 1$，将元素 $a_r$ 加入窗口并更新窗口信息。
- **左指针收缩**：当 $f(l, r)$ 不成立时，$l \leftarrow l + 1$，将元素 $a_l$ 移出窗口并更新窗口信息。
- **答案维护**：每次窗口合法时，用窗口长度 $r - l + 1$ 或对应的贡献值更新答案。

对相向双指针，决策条件通常形如 $a_l + a_r \le W$（$W$ 为目标上限）：成立时两侧指针同时相向移动，否则只移动其中一侧。对双序列指针，则按两个序列当前元素 $S_i$ 与 $T_j$ 的比较结果决定推进 $i$ 还是 $j$。

由于每个指针都单调前进，总移动次数有界，双序列指针的整体推进次数满足

$$
i + j \le n + m
$$

其中 $n$、$m$ 分别为两个序列的长度。

## 逐行代码解析

双指针是思想而非固定算法，下面给出三种形态的思想步骤（伪代码），可根据具体问题改写。

同向双指针（滑动窗口）：

```cpp
int l = 0, ans = 0;
for (int r = 0; r < n; r++) {
    将 a[r] 加入窗口，更新窗口信息;        // 右指针扩展
    while (窗口不满足条件) {                // 不合法则收缩左指针
        将 a[l] 移出窗口，更新窗口信息;
        l++;
    }
    ans = max(ans, r - l + 1);              // 用当前合法窗口更新答案
}
```

- 右指针 `r` 每个位置只被访问一次，负责扩展；左指针 `l` 只前进不回退，负责收缩。
- 收缩用 `while` 而非 `if`：一次右移可能让窗口连续多次不合法，需要反复收缩直到重新合法。

相向双指针（有序数组配对）：

```cpp
sort(a, a + n);                              // 通常需要先排序
int l = 0, r = n - 1;
while (l <= r) {
    if (a[l] + a[r] 满足条件) { 处理配对; l++; r--; }
    else { 处理单个元素; r--; }              // 视问题决定移动哪一侧
}
```

- 排序后两端分别指向最小与最大元素，利用 $a_l + a_r$ 与目标值的大小关系，每次排除掉不可能再参与配对的端点。
- 终止条件 `l <= r`：两指针相遇后区间为空，注意等号处的边界处理。

双序列指针：

```cpp
int i = 0, j = 0;
while (i < n && j < m) {
    if (S[i] 与 T[j] 匹配) { 记录或统计; i++; j++; }
    else { i++; }                            // 视问题决定推进哪个指针
}
```

- 两个指针各自向前推进，常用于判断子序列、合并有序序列、求交集。
- 任一序列到达末尾即结束，未处理完的部分按问题要求收尾。

## 复杂度分析

- **时间复杂度**：视具体实现。同向双指针中左右指针各至多移动 $n$ 次，为 $O(n)$；相向双指针扫描为 $O(n)$，若需先排序则为 $O(n \log n)$；双序列指针为 $O(n + m)$。
- **空间复杂度**：视具体实现。滑动窗口若用哈希表记录窗口内元素出现次数，通常为 $O(n)$ 或 $O(1)$，取决于记录方式与值域大小。

## 适用场景

- 求最长或最短的满足条件的连续子段（如最长无重复字符子串），用同向双指针（滑动窗口）。
- 有序数组中的两数之和、两数配对、回文判定、去重等，用相向双指针。
- 合并两个有序序列、判断一个序列是否为另一个的子序列、求两个有序集合的交集，用双序列指针。
- 链表环检测、寻找链表中点等，用快慢指针（同向不同速，属双指针家族，详见相关知识点）。

## 常见陷阱与注意事项

1. 明确两个指针分别表示什么含义，避免用错指针更新状态。
2. 确认指针移动方向，若指针发生回退，算法会退化为 $O(n^2)$ 的双重枚举。
3. 移动指针后及时更新区间信息，加入或移出元素要同步维护计数、和等统计量。
4. 注意空区间、单元素区间以及指针越界，例如相向双指针中 `l++` / `r--` 后要正确判断 `l <= r` 的边界。
5. 双指针通常依赖数据或条件的单调性，并非所有区间问题都能直接套用；不满足单调性时应考虑二分、线段树等其它工具。

## 对比与扩展

| 变体 | 指针方向 | 典型应用 | 时间复杂度 |
|---|---|---|---|
| 同向双指针（滑动窗口） | 同向 | 最长无重复子串、最短覆盖子串 | $O(n)$ |
| 相向双指针 | 相向 | 两数之和、回文判定、纪念品分组 | $O(n)$（需排序时为 $O(n \log n)$） |
| 双序列指针 | 各自向前 | 合并有序序列、判断子序列 | $O(n + m)$ |
| 快慢指针 | 同向不同速 | 链表环检测、寻找中点 | $O(n)$ |

**扩展方向**：

- **滑动窗口**是同向双指针最典型的一种应用，常与哈希表、前缀和结合处理区间最值。
- **快慢指针**把「同向」扩展为「同向不同速」，用于环检测与寻找链表中点。
- 双指针可与二分、单调队列、差分等结合，解决更复杂的区间与计数问题。$AKB48$, '基础算法', array['基础算法', '双指针', '滑动窗口', '对撞指针', '双序列指针'], null, null, 'knowledge'),
('Xesir', 'col-basic-two-pointer--xesir', '双指针（思想） · Xesir', $AKB49$## 算法原理

双指针是一种通过维护两个下标，在线性遍历中减少重复计算的技巧。两个指针通常表示区间的左右端点，也可以分别指向两个序列中的当前位置。当指针满足某种单调移动规律时，就不必反复枚举已经处理过的位置。

按指针的移动方向与作用，双指针常见有三种形态：

### 同向双指针

两个指针从左到右移动，右指针不断向右扩展区间，如果区间不满足条件，就移动左指针，记录每次满足条件时的答案。常用于维护一个满足条件的连续区间，例如求最长的不重复子串、最长满足条件的区间等。

### 相向双指针

两个指针分别从序列两端向中间移动，通过判断端点值来决定指针移动。通常需要数组有序，常用于查找问题。

### 双序列指针

分别维护两个有序序列的当前位置，比较两个指针指向的元素，统计对应元素答案并移动对应指针，直到某个序列处理完毕。一般用于合并、匹配或求交集。

## 逐行代码解析

### 同向双指针：UVA11572 唯一的雪花

**题目大意**：给定一个长度为 `n` 的序列，求最长的不包含重复元素的连续子段长度。

**核心思路**：维护一个窗口 `[left, right]`，用哈希表记录窗口内每个元素出现的次数。右指针 `right` 不断向右扩展，将新元素加入窗口；如果发现窗口内出现重复元素（即 `mp[a[right]] > 1`），就移动左指针 `left` 收缩窗口，直到重复元素被移除。每次窗口合法时，用 `right - left + 1` 更新答案。

```cpp
#include<cstdio>
#include<map>
using namespace std;
map<int,int> snow;
int T,n,ans,last,a;
int main()
{
	for(scanf("%d",&T);T--;printf("%d\n",ans))
	{
		snow.clear();
		scanf("%d",&n);
		last=ans=0;
		for(int i=1;i<=n;i++)
		{
			scanf("%d",&a);
			if(snow[a]>last)last=snow[a];
			printf("%d\n",snow[a]);
			ans=max(ans,i-last);
			snow[a]=i;
		}
	}
	return 0;
}
```

- 这份代码（来源于洛谷题解）用 `last` 记录「左边界禁区」——上一个重复位置，而不是显式地移动左指针，效果等价于收缩窗口。
- 滑动窗口中运用的就是同向双指针。

### 相向双指针：P1094 纪念品分组

**题目简介**：有 `n` 件纪念品，每件有价格。要求分组，每组**最多两件**，且每组价格之和不能超过上限 `w`，求最少分组数。

**核心思路**：先观察到，尽量将当前最贵与最便宜的纪念品配对总是更优的，故先将价格从小到大排序。左指针 `l` 指向最便宜的，右指针 `r` 指向最贵的。每次尝试把最便宜和最贵的分在一组：若 `price[l] + price[r] <= w`，说明可以凑一组，`l++`、`r--`、组数加 1；否则最贵的只能单独一组，`r--`、组数加 1。

```cpp
#include <bits/stdc++.h>
using namespace std;
int a[30001];
int main()
{
    int w,n;
    cin>>w>>n;
    for(int i=1;i<=n;i++)
    {
        cin>>a[i];
    }
    sort(a+1,a+n+1);
    int l=1,r=n;
    int cnt=0;
    while(l<=r)
    {
        if(a[l]+a[r]<=w)
        {
            cnt++;
            l++;
            r--;
        }
        else
        {
            cnt++;
            r--;
        }
    }
    cout<<cnt;
    return 0;
}
```

- 每次循环 `cnt` 必加 1：无论能否配对，最贵的那件都要占掉一组。
- `while(l<=r)` 让两个指针相遇（只剩同一件）时也能被处理到。

### 双序列指针：P8697 最长子序列

**题目简介**：给定两个字符串 `S` 和 `T`，判断 `T` 中有多少个字符能按顺序在 `S` 中匹配到（即 `T` 是 `S` 的子序列），输出能匹配的连续前缀长度。

**核心思路**：指针 `i` 遍历字符串 `S`（被匹配的母串），指针 `j` 遍历字符串 `T`（要匹配的子串），每轮 `i` 前进一位。每次比较 `S[i]` 和 `T[j]`，如果相等，说明 `T[j]` 被成功匹配，`j` 前进一位、答案加 1；当 `i` 或 `j` 到达末尾时结束。

```cpp
#include<stdio.h>
#include<string>
#include<iostream>
using namespace std;
int ans;
string s,t;
signed main()
{
	cin>>s>>t;
	for(int i=0,j=0;i<s.size()and j<t.size();i++)
		if(s[i]==t[j])j++,ans++;
	printf("%d",ans);
	return 0;
}
```

- `and` 是 C++ 的替代运算符，等价于 `&&`。
- `i` 只前进不回退，`j` 只在匹配成功时前进，整体保持线性。

## 复杂度分析

- **同向双指针**：左右指针各至多移动 $n$ 次，为 $O(n)$。
- **相向双指针**：扫描为 $O(n)$；若需先排序则为 $O(n\log n)$（如 P1094）。
- **双序列指针**：两个指针各自前进，为 $O(n+m)$。
- **空间复杂度**：视具体实现。滑动窗口若用哈希表记录窗口内元素出现次数，通常为 $O(n)$ 或 $O(1)$，取决于记录方式与值域大小。

## 适用场景

- 求最长或最短的满足条件的连续子段（如最长无重复字符子串），用同向双指针（滑动窗口）。
- 有序数组中的两数之和、两数配对、回文判定、去重等，用相向双指针。
- 合并两个有序序列、判断一个序列是否为另一个的子序列、求两个有序集合的交集，用双序列指针。
- 链表环检测、寻找链表中点等，用快慢指针（同向不同速，属于双指针家族）。

## 常见陷阱与注意事项

1. 明确两个指针分别表示什么，避免用错指针更新状态。
2. 确认指针移动方向，若指针发生回退，算法会退化为 $O(n^2)$ 的双重枚举。
3. 移动指针后及时更新区间信息，加入或移出元素要同步维护计数、和等统计量。
4. 注意空区间、单元素区间以及指针越界，例如相向双指针里 `l++` / `r--` 后要正确判断 `l <= r` 的边界。
5. 双指针通常依赖数据或条件的单调性，不是所有区间问题都能直接使用；不满足单调性时，应考虑二分、线段树等其它工具。

## 对比与扩展

| 变体 | 指针方向 | 典型应用 | 复杂度 |
|---|---|---|---|
| 同向双指针（滑动窗口） | 同向 | 最长无重复子串、最短覆盖子串 | $O(n)$ |
| 相向双指针 | 相向 | 两数之和、回文判定、纪念品分组 | $O(n)$（需排序时 $O(n\log n)$） |
| 双序列指针 | 各自向前 | 合并有序序列、判断子序列 | $O(n+m)$ |
| 快慢指针 | 同向不同速 | 链表环检测、寻找中点 | $O(n)$ |

- **滑动窗口**是同向双指针最典型的一种应用，常与哈希表、前缀和结合处理区间问题。
- **快慢指针**把「同向」扩展为「同向不同速」，用于环检测与寻找链表中点。
- 双指针可与二分、单调队列、差分等结合，解决更复杂的区间与计数问题。$AKB49$, '基础算法', array['双指针', '滑动窗口', '对撞指针', '双序列指针', '基础算法'], null, null, 'knowledge'),
('world-needs-sunday', 'col-basic-two-pointer-cycle', '链表环检测（Floyd 快慢指针）', $AKB50$## 算法原理

Floyd 快慢指针算法（又称"龟兔赛跑"算法）是双指针技术中的经典应用，用于在有向链 / 函数图（functional graph）中检测是否存在环，并在存在环时找出环的入口节点。算法核心是利用两个速度不同的指针：**慢指针**（slow）每步走 1 步，**快指针**（fast）每步走 2 步。

**环检测原理**：若链上无环，快指针会先到达链尾（本实现中 `to[fast] == 0` 表示到达终点）；若存在环，快慢指针最终会在环内某点相遇。这一结论的直觉是：快指针比慢指针每步多走 1 步，在环内两者的距离每步缩小 1，必定在有限步内追上（相遇）。

**环入口定位原理**：设起点到环入口的距离为 $a$，环长为 $c$，相遇点到环入口的距离为 $b$（沿环方向）。相遇时慢指针走了 $a + b$ 步，快指针走了 $a + b + k \cdot c$ 步（$k$ 为快指针多绕的圈数，$k \geq 1$）。由于快指针速度是慢指针的两倍：

$$2(a + b) = a + b + k \cdot c \implies a = k \cdot c - b$$

即 $a \equiv -b \pmod{c}$，等价于 $a \equiv c - b \pmod{c}$。因此，将一个指针重置到起点 $s$，另一指针留在相遇点，两者以相同速度（每步 1 格）前进，经过 $a$ 步后必然在环入口相遇。

本实现使用后继数组 `to[]` 表示链结构（`to[u] = v` 表示节点 `u` 的下一个节点为 `v`，`to[u] = 0` 表示终点），适用于输入保证构成一条链子（含或不含环）的场景。

## 数据结构图示

有环链表示例（`s = 1`，入口为节点 3）：

```
链结构:    1 → 2 → 3 → 4 → 5 → 6
                    ↑              │
                    └──────────────┘

to[]:  to[1]=2  to[2]=3  to[3]=4  to[4]=5  to[5]=6  to[6]=3

       起点到入口: a = 2 (1→2→3)
       环长:       c = 4 (3→4→5→6→3)
```

快慢指针运动过程：

```
Step 0:  slow=1, fast=1          (起点)
Step 1:  slow=2, fast=3          (slow走1步, fast走2步)
Step 2:  slow=3, fast=5
Step 3:  slow=4, fast=3          (fast绕了一圈)
Step 4:  slow=5, fast=5          (相遇！)

相遇点 = 5, 环入口 = 3
  b = 2 (入口3 → 4 → 5, 相遇点距入口2步)
  a = 2, c = 4, k = 1
  验证: a = k*c - b = 1*4 - 2 = 2 ✓

入口定位:
  fast 重置到 s=1, slow 留在 5
  Step 1: fast=2, slow=6
  Step 2: fast=3, slow=3        (在入口相遇！)
```

无环链示例：

```
链结构:  1 → 2 → 3 → 4 → 0(终点)

to[]:  to[1]=2  to[2]=3  to[3]=4  to[4]=0

Step 0: slow=1, fast=1
Step 1: slow=2, fast=3
Step 2: slow=3, fast=0          (fast到达终点 → 无环)
```

## 核心操作详解

### 环检测（Phase 1）

**功能**：判断链上是否存在环，若存在则找到快慢指针的相遇点。

**算法步骤**：
1. 初始化 `slow = s`，`fast = s`（均从起点出发）。
2. 循环：`slow` 每次走 1 步（`slow = to[slow]`），`fast` 每次走 2 步（`fast = to[to[fast]]`）。
3. 若 `fast == 0`（快指针走到终点），说明无环，输出"无环"。
4. 若 `fast == slow`（快慢指针相遇），说明有环，进入 Phase 2。

**关键细节**：使用 `do...while` 循环确保至少执行一步（因为初始时 `fast == slow == s`，若用 `while` 会立即误判为相遇）。

### 环入口定位（Phase 2）

**功能**：在确认有环后，找到环的入口节点。

**算法步骤**：
1. 将 `fast` 重置到起点 `s`，`slow` 保持在相遇点不动。
2. 两者以相同速度（每步 1 格）前进：`fast = to[fast]`，`slow = to[slow]`。
3. 当 `fast == slow` 时，当前位置即为环入口。

**关键细节**：根据公式 $a = k \cdot c - b$，从起点走 $a$ 步到达入口，从相遇点走 $a$ 步也到达入口（因为 $a \equiv c - b \pmod{c}$），因此两者必然在入口相遇。

## 逐行代码解析

按逻辑阶段把程序拆成 4 个模块；将各模块的代码块按顺序拼接，即还原为完整程序。

### 模块 1 · 头文件与 main 入口

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int T;
	cin >> T;
	while (T--)
	{
```

- `#include<bits/stdc++.h>` 万能头配合 `using namespace std;`：竞赛常用写法，一次引入标准库、省去 `std::` 前缀。
- `ios::sync_with_stdio(false)` 关闭 C++ 流与 C 标准 IO 的同步；`cin.tie(nullptr)` / `cout.tie(nullptr)` 解除 cin/cout 绑定，避免每次输入前刷新输出，加速读写。
- `cin >> T; while (T--)`：读入测试组数，每组数据独立处理。

### 模块 2 · 读入并建立后继数组 to

```cpp
		//n是节点总数，s是入口，保证n-1个输入并且组成一个链子，判断是否带环
		int n, s;
		cin >> n >> s;
		vector<int> to(n + 1, 0);
		for (int i = 1;i < n;i++)
		{
			int u, v;
			cin >> u >> v;
			to[u] = v;
		}
```

- `int n, s;`：`n` 为节点总数，`s` 为链的起点编号。
- `vector<int> to(n + 1, 0);`：后继数组 `to[u] = v` 表示 `u` 的下一个是 `v`。开成 `n + 1` 并初始化为 0，`to[0]` 恒为 0，供快指针走两步时安全访问 `to[to[fast]]`。
- `for (int i = 1;i < n;i++)`：共读入 `n - 1` 条边；`to[u] = v` 建立后继关系，若有环则最后一个节点的 `to` 指回链上某已有节点。

### 模块 3 · Phase 1 环检测（快慢指针相遇）

```cpp
		int fast = s, slow = s;
		do
		{
			slow = to[slow];
			fast = to[to[fast]];
		}
		while (fast != 0 && slow != fast);
```

- `int fast = s, slow = s;`：快慢指针均从起点 `s` 出发。
- `do...while` 保证至少移动一次：初始 `fast == slow == s`，若用 `while` 会在第一步就误判为"相遇"。
- `slow = to[slow]` 慢指针每步走 1 步；`fast = to[to[fast]]` 快指针每步走 2 步。
- 循环条件 `fast != 0 && slow != fast`：`fast != 0` 表示尚未到终点、`slow != fast` 表示尚未相遇，二者都成立才继续；任一不满足即退出。

### 模块 4 · Phase 2 定位环入口并输出

```cpp
		if (fast == 0) cout << "无环" << '\n';
		else
		{
			fast = s;
			while (fast != slow)
			{
				fast = to[fast];
				slow = to[slow];
			}
			cout << "有环，环入口为：" << fast << '\n';
		}
	}

	return 0;
}
```

- `if (fast == 0)`：快指针走到终点，说明链上无环，输出"无环"。
- `fast = s;`：Phase 2 把快指针重置到起点，慢指针停留在相遇点不动。
- `while (fast != slow)`：两指针以相同速度各走 1 步，依据 $a \equiv c - b \pmod{c}$ 必然在环入口相遇。
- `cout << "有环，环入口为：" << fast;`：此时 `fast` 即为环入口节点编号。

## 复杂度分析

- **时间复杂度**：$O(n)$。Phase 1 中，慢指针在相遇前最多走 $n$ 步（环长加起点到入口的距离之和不超过 $n$）；Phase 2 中，两指针从起点和相遇点各走最多 $a$ 步到达入口，$a \leq n$。总计线性。
- **空间复杂度**：$O(n)$，需存储后继数组 `to[]`，大小为 $n + 1$。

## 适用场景

- 判断链表 / 函数图是否存在环。
- 找到环的入口节点（如求循环节、判断重复模式）。
- 竞赛中常见的"给定 $n$ 个节点 $n - 1$ 条边，判断是否带环并求入口"问题。
- 可扩展到任意"后继图"结构（如 $f(x)$ 映射下的轨道周期检测）。

## 常见陷阱与注意事项

- **`do...while` vs `while`**：初始 `fast == slow == s`，若用 `while (fast != slow)` 会在第一步就退出，误判为有环。必须用 `do...while` 确保至少执行一次移动后再判断。
- **终点判断**：本实现用 `to[x] == 0` 表示终点，快指针走两步时需注意 `to[to[fast]]` 可能访问 `to[0]`，因此 `to` 数组大小应至少为 `n + 1`，且 `to[0]` 初始为 0（构成自环安全终止）。
- **多组数据**：每组测试用例需重新初始化 `to` 数组，使用 `vector` 配合构造可自动管理。
- **环入口不等于相遇点**：相遇点是快慢指针在 Phase 1 交汇的位置，环入口需要 Phase 2 再走若干步才能找到，两者通常不同。
- **输入保证构成链子**：本实现假设 $n - 1$ 条边恰好构成一条链（可能有环）。**图不保证连通、编号不连续时，光凭边的数量无法判断是否有环**——此时需改用 DFS 三色染色或并查集判环（见下方对比表）。

## 对比与扩展

| 方法 | 时间复杂度 | 空间复杂度 | 特点 |
|---|---|---|---|
| **Floyd 快慢指针** | $O(n)$ | $O(1)$（不含存储） | 两阶段，常数极小，最经典 |
| Hash 集合法 | $O(n)$ | $O(n)$ | 遍历并记录访问节点，首次重复即入口，简单但空间大 |
| DFS 染色法 | $O(n + m)$ | $O(n)$ | 适用于一般图，递归栈深度有限制 |

**扩展方向**：
- **Brent 算法**：快指针不逐步走，而是以指数增长的步长前进，减少比较次数，理论上比 Floyd 更快（常数更优），但实现稍复杂。
- **一般有向图判环**：使用 DFS 三色标记法（白/灰/黑）或 Kahn 拓扑排序，可处理任意结构的图。
- **环长计算**：在 Phase 1 相遇后，让一个指针原地绕环一圈并计数，即可得到环长 $c$。
- **函数迭代周期检测**：将 $f(x)$ 视为后继函数，$\rho$-算法（Pollard's rho）中利用 Floyd 环检测寻找因子分解中的碰撞。
- **其他双指针应用**：对撞指针（如两数之和、回文判定）、同向指针（如滑动窗口、原地去重）都是双指针家族的经典变体。$AKB50$, '基础算法', array['基础算法', '双指针', '快慢指针', 'Floyd', '环检测', '龟兔赛跑'], null, null, 'knowledge'),
('world-needs-sunday', 'col-hub-basic-divide', '分治总述', $AKB51$## 算法原理

分治是把问题**劈成若干规模更小的同类子问题**，分别求解后合并答案。本页收「分治思想」这一族，成员为：

- **归并类**：归并排序求逆序对（`basic-divide-conquer-merge-inversion`）、最近点对（`basic-divide-conquer-closest-pair`）。
- **二分类**：三分法求单峰函数极值（`basic-ternary-search`）、快速选择求第 $k$ 小（`basic-quickselect-kth`）——二者都是「每次砍掉一部分搜索空间」。
- **按规模分治**：根号分治（`basic-sqrt-decomposition`），按参数大小分成两套做法，复杂度取平衡点。

## 核心公式 / 状态定义与转移方程

- 归并求逆序对：合并左右两段时，右段元素出队即产生「左段剩余元素个数」个逆序对。
- 三分法：在 $[l,r]$ 上取 `m1 = l+(r-l)/3`、`m2 = r-(r-l)/3`，比较 `f(m1)`、`f(m2)` 后舍弃一侧。
- 快速选择：按基准值划分后，只递归包含第 $k$ 小的一侧，期望 $O(n)$。
- 根号分治：阈值 $B=\sqrt n$；参数 $\le B$ 暴力、$>B$ 预处理/整体处理，两部分复杂度都控制在 $O(n\sqrt n)$。

## 逐行代码解析

本页是总述页，不附实现。各子条目给出完整模板：归并的合并统计、三分的区间收缩、快速选择的划分、根号分治的双分支写法。

## 复杂度分析

- 归并排序 / 逆序对：$O(n\log n)$。
- 最近点对：$O(n\log n)$（先按 $x$ 分治，再按 $y$ 扫描带宽）。
- 三分法：$O(\log_{1.5} n)$ 次函数求值（精度迭代）。
- 快速选择：期望 $O(n)$，最坏 $O(n^2)$。
- 根号分治：$O(n\sqrt n)$ 量级。

## 适用场景

- 答案可以由左右两半合并得到，且合并代价可控 → 分治。
- 函数单峰（凸/凹）求极值 → 三分。
- 只需要第 $k$ 小、不需要完全排序 → 快速选择。
- 参数规模差异大、大参数与小参数需要的做法不同 → 根号分治。
- 不适合：子问题之间不独立、无法合并答案，或递归深度过大。

## 常见陷阱与注意事项

- 分治的合并步骤漏掉跨区间贡献（最近点对的带宽扫描最容易漏）。
- 三分法用于非单峰函数，结果无意义。
- 快速选择的划分写错，导致递归区间不缩小而死循环。
- 根号分治的阈值不取 $\sqrt n$，两侧复杂度失衡。
- 递归边界写成 `l < r` 还是 `l <= r` 与具体实现不符。

## 对比与扩展

分治与倍增、分块、CDQ 分治同源：分治强调「拆子问题」，倍增强调「预处理 $2^k$ 的信息」，分块强调「按块整体处理」。归并思想还可以扩展成 CDQ 分治处理偏序问题。学习顺序建议：归并/二分 → 三分与快速选择 → 根号分治 → CDQ 分治。$AKB51$, '基础算法', array['分治', '二分', '根号分治', '总述'], null, null, 'knowledge'),
('world-needs-sunday', 'col-hub-basic-search', '搜索总述', $AKB52$## 算法原理

搜索是在**状态空间**上枚举可行解的过程。两种基本形态：

- **DFS（深度优先）**：沿一条路径走到底再回溯，天然适合「按位/按位置逐个决策」的枚举（`basic-dfs`），以及排列、组合的生成（`basic-permutation-dfs`、`basic-combination-dfs`）。
- **BFS（广度优先）**：按层扩展，第一次到达即最短路（边权为 1 时）；双向 BFS 从起点与终点同时扩展（`basic-bfs`、`basic-bfs-bidirectional`）。

当状态数太大时，用**折半搜索**把枚举量从 $2^n$ 降到 $2^{n/2}$，再在两侧结果上做二分或双指针匹配（`basic-meet-in-middle-binary-search`、`basic-meet-in-middle-two-pointer`）。

## 核心公式 / 状态定义与转移方程

- DFS：`dfs(step, state)` → 枚举 `step` 的所有取值 → 递归 → 撤销。
- BFS：队列中存状态，`dis[v] = dis[u] + 1`，首次访问即最短。
- 双向 BFS：两端轮流扩展，相遇时 `dis = du + dv`。
- 折半搜索：把 $n$ 个元素劈成两半，各自枚举 $2^{n/2}$ 个和，排序后用二分/双指针配对。

## 逐行代码解析

本页是总述页，不附实现。各子条目给出完整模板：DFS 的回溯与剪枝、BFS 的访问标记、双向 BFS 的两端队列、折半搜索的枚举与匹配。

## 复杂度分析

- DFS：$O(\text{状态数}\times\text{转移数})$，通常配合剪枝。
- BFS：$O(V+E)$，$V$ 为状态数、$E$ 为转移数。
- 双向 BFS：$O(b^{d/2})$，$b$ 为分支因子、$d$ 为最短步数。
- 折半搜索：枚举 $O(2^{n/2})$，排序 $O(2^{n/2}\log 2^{n/2})$，匹配 $O(2^{n/2}\log 2^{n/2})$ 或 $O(2^{n/2})$。

## 适用场景

- 状态数在 $10^6\sim10^7$、需要枚举所有方案或找最优 → DFS + 剪枝。
- 求最少步数、状态转移代价相同 → BFS。
- 状态空间大但答案深度浅 → 双向 BFS。
- $n\le 40$ 且答案可由两部分组合 → 折半搜索。
- 不适合：状态数超过搜索可承受范围，且没有可用的剪枝/记忆化；此时应改 DP 或数学方法。

## 常见陷阱与注意事项

- DFS 忘记回溯（撤销现场），导致后续分支状态被污染。
- BFS 入队时没有立即标记访问，同一状态被重复入队。
- 双向 BFS 两端扩展层数不平衡，退化成一端 BFS。
- 折半搜索枚举后进行匹配时下标越界或没有去重。
- 递归深度过大爆栈；必要时改迭代或手动开栈。

## 对比与扩展

搜索与 DP 是互补的：状态可压缩、有重叠子问题时用 DP 更快；搜索适合状态难以用下标描述的题。BFS 与最短路同源（边权为 1），折半搜索可以看成「meet in the middle 的枚举版」。学习顺序建议：DFS/BFS 基础 → 排列组合生成 → 双向 BFS → 折半搜索。$AKB52$, '基础算法', array['搜索', 'DFS', 'BFS', '折半搜索'], null, null, 'knowledge'),
('world-needs-sunday', 'col-hub-basic', '基础算法总述', $AKB53$## 算法原理

基础算法是不依赖复杂数据结构、靠**问题建模与策略选择**解决问题的一类方法。它覆盖的范围比单个模板宽：贪心、双指针、排序、搜索、分治、倍增、离散化、离线操作、随机化、高精度、进制转换、数位提升，以及对拍、计时、模板头等竞赛工程手段。

判断一道题是否落在本大类，可以看它是否满足下面任意一条：

- 每一步都能用一个局部规则决定，且该规则可以证明不会让全局变差（贪心）。
- 需要在一个序列上维护两个或多个位置的关系，且移动具有单调性（双指针、单调队列的思想源头）。
- 搜索空间可以按层或按区间切开，切开后子问题互不影响（分治、倍增）。
- 数据本身很大，但只关心相对大小或数位结构（离散化、高精度、进制转换、数位提升）。

本大类的知识点通常作为其他大类的“零件”出现，例如排序是二分的预处理、离散化是线段树的前置、对拍是验证所有代码正确性的手段。

## 核心公式 / 状态定义与转移方程

基础算法没有统一的转移方程，但有一条通用的分析链：

1. **写出暴力**：先明确枚举对象、枚举顺序和判定条件。
2. **找冗余**：观察哪些枚举结果被重复计算，或哪些候选永远不可能成为答案。
3. **换维护方式**：用排序、前缀信息、指针单调性、分治合并或随机采样消掉冗余。
4. **证明不变量**：说明每一步之后“仍未排除的候选集合”始终包含最优解。

凡是能把这四步写清楚的题，基本都能落到本大类的某个具体方法上。

## 逐行代码解析

本篇是大类总述，不附具体实现。各子分类的模板代码、逐行注释与边界处理在对应知识点页中，例如排序、二分、双指针、对拍脚本等条目。

## 复杂度分析

基础算法的复杂度通常由“枚举量 × 单次判定代价”决定：

- 排序类：比较排序下界为 $O(n\log n)$，计数/基数排序在值域可控时可做到线性。
- 双指针与单调性：指针总移动次数为 $O(n)$，单次移动均摊 $O(1)$。
- 分治：复杂度由递归式决定，常见为 $O(n\log n)$ 或 $O(n\log^2 n)$。
- 搜索与对拍：指数级搜索要配合剪枝或 meet-in-the-middle；对拍本身不改变算法复杂度，只用于验证。

具体量级以各子条目的代码为准。

## 适用场景

- 需要快速判断一道题“该用什么套路”时，先在本大类里找建模方式。
- 作为其他算法的预处理：排序、离散化、前缀信息、随机化。
- 作为工程保障：对拍、计时、模板头、快速输入输出。
- 不适合：问题本身需要维护复杂区间信息（转数据结构）、需要多阶段最优决策（转动态规划）、需要图结构建模（转图论）。

## 常见陷阱与注意事项

- 贪心只凭直觉、不证明交换论证，反例往往藏在小数据里。
- 双指针移动条件写反，导致指针越界或漏掉合法区间。
- 二分边界与 `mid` 取整方向不匹配，出现死循环。
- 离散化忘记去重，或把原值映射后仍按原值比较。
- 高精度进位、前导零、负数符号处理不完整。
- 对拍只测随机大数据，忽略 $n=1$、全相同、极值等边界。

## 对比与扩展

基础算法与后续大类的关系是“工具与场景”：动态规划用排序与离散化压缩状态，数据结构用双指针与分治思想设计维护方式，图论用搜索与并查集做连通性判断。掌握本大类的判断链，比记住单个模板更重要。$AKB53$, '基础算法', array['基础算法', '总述', '学习路线'], null, null, 'knowledge');

do $$
declare
    v_missing text;
begin
    select string_agg(distinct s.author_name, '、') into v_missing
    from _akb_seed_columns s
    left join public.profiles p on p.nickname = s.author_name
    where p.id is null;

    if v_missing is not null then
        raise exception '缺少作者 profile：%', v_missing;
    end if;
end $$;

insert into public.columns (
    owner_id, column_key, column_name, content, tags, category, parent_key,
    relations, difficulty, kind, status
)
select
    p.id, s.column_key, s.column_name, s.content, s.tags, s.category,
    s.parent_key, '[]'::jsonb, s.difficulty, s.kind, 'published'
from _akb_seed_columns s
join public.profiles p on p.nickname = s.author_name
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    content = excluded.content,
    tags = excluded.tags,
    category = excluded.category,
    parent_key = excluded.parent_key,
    difficulty = excluded.difficulty,
    kind = excluded.kind,
    status = 'published',
    updated_at = now();

drop table if exists _akb_seed_columns;

commit;
