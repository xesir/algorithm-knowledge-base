-- ============================================================
-- AKB 专栏种子：题目 / 数学
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：81 行
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
('stripe-python', 'col-prob-atcoder-abc236e--stripe-python', 'x Distinct Multiples · stripe-python', $AKB524$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC236E](https://www.luogu.com.cn/problem/AT_abc236_h)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$ 和序列 $d_1 \sim d_n$。对满足以下条件的序列 $a_1 \sim a_n$ 计数：
>
> - $\forall i \in [1,n], a_i \in [1,m]$。
> - $\forall i \in [1,n], d_i \mid a_i$。
> - $a_i$ 互不相同。
>
> $n \le 16$，$m \le 10^{18}$，2 秒，1024 MB。

::::::success[题解]

对互不相同的条件容斥。枚举划分 $P$，每个等价类内部 $a$ 值相同，容斥系数 $\prod\limits_{S \in P} (-1)^{|S|-1} (|S|-1)!$。

:::::info[集合划分容斥]

考虑下面的模型：有 $n$ 个变量 $a_1 \sim a_n$，其中 $a_i \in S_i$ 且 $a_i$ 互不相同，对 $a_1 \sim a_n$ 计数。

对互不相同进行容斥。考虑建图，若 $a_i=a_j$ 则连边 $i \leftrightarrow j$，连通块内部的点值都相同，不同连通块之间无限制。

对无向图 $G=(V,E)$，设 $C(E)$ 为 $G$ 的集合划分，$F(P)$ 为划分 $P$ 对应的方案数，答案即为
$$
\sum_{E} (-1)^{|E|} F(C(E))=\sum_{P} F(P) \sum_{C(E)=P}(-1)^{|E|}
$$
设 $P=\{S_1,S_2,\cdots,S_m\}$，只要在每个 $S_i$ 内部连边并构成连通图。则容斥系数
$$
 \sum_{C(E)=P}(-1)^{|E|}=\prod_{S \in P} \sum_{G_S \text{连通}} (-1)^{|E(G_S)|}
$$
问题转化为，对 $k$ 个点的无向图，求所有连通边集 $E$ 的 $(-1)^{|E|}$ 之和，记作 $g_k$。

设 $f_k$ 为 $k$ 个点任意无向图的 $(-1)^{|E|}$ 之和，则
$$
f_k=\sum_{i=0}^{\binom{k}{2}} \binom{\binom{k}{2}}{i} (-1)^i=0^{\binom{k}{2}}
$$
故 $k \ge 2$ 时 $f_k=0$，只有 $f_0=f_1=1$。$f$ 的 EGF 为
$$
F=\sum_{k \ge 0} f_k \dfrac{x^k}{k!}=1+x
$$
根据多项式 $\exp$ 的组合意义：
$$
F=\exp G \implies G=\ln F
$$
由 Taylor 展开
$$
G=\sum_{k \ge 1} (-1)^{k-1} \dfrac{x^k}{k}
$$
提取系数得
$$
\left[\dfrac{x^k}{k!}\right]G=\dfrac{(-1)^{k-1}}{k} \implies g_k=(-1)^{k-1}(k-1)!
$$
将 $g_k$ 代入容斥系数，得到最终结论
$$
\boxed{\sum_{P} F(P) \prod_{S \in P} (-1)^{|S|-1} (|S|-1)!}
$$
:::::

记 $\underset{i\in S}{\text{lcm } } d_i=\text{lcm}(S)$。强制点集 $S$ 内 $a$ 值均为 $x$，则必有 $\text{lcm}(S) \mid x$，从而方案数为
$$
F(P)=\prod_{S \in P}\left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
答案为
$$
\sum_{P}\prod_{S \in P}(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
利用排除 $\min S$ 转移的 trick，容易 $O(2^n \log V)$ 地求出单个 $S$ 的贡献值 $f_S=(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor$。

构造集合幂级数 $F$，令 $G=\exp F$，则 $[x^U] G$ 即为所求。使用子集卷积 exp 做到 $O(n^2 2^n)$。

总复杂度 $O(n^2 2^n+2^n \log V)$。[代码](https://atcoder.jp/contests/abc236/submissions/79499553)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB524$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-abc236ex--stripe-python', 'Distinct Multiples · stripe-python', $AKB525$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC236EX](https://www.luogu.com.cn/problem/AT_abc236_h)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$ 和序列 $d_1 \sim d_n$。对满足以下条件的序列 $a_1 \sim a_n$ 计数：
>
> - $\forall i \in [1,n], a_i \in [1,m]$。
> - $\forall i \in [1,n], d_i \mid a_i$。
> - $a_i$ 互不相同。
>
> $n \le 16$，$m \le 10^{18}$，2 秒，1024 MB。

::::::success[题解]

对互不相同的条件容斥。枚举划分 $P$，每个等价类内部 $a$ 值相同，容斥系数 $\prod\limits_{S \in P} (-1)^{|S|-1} (|S|-1)!$。

:::::info[集合划分容斥]

考虑下面的模型：有 $n$ 个变量 $a_1 \sim a_n$，其中 $a_i \in S_i$ 且 $a_i$ 互不相同，对 $a_1 \sim a_n$ 计数。

对互不相同进行容斥。考虑建图，若 $a_i=a_j$ 则连边 $i \leftrightarrow j$，连通块内部的点值都相同，不同连通块之间无限制。

对无向图 $G=(V,E)$，设 $C(E)$ 为 $G$ 的集合划分，$F(P)$ 为划分 $P$ 对应的方案数，答案即为
$$
\sum_{E} (-1)^{|E|} F(C(E))=\sum_{P} F(P) \sum_{C(E)=P}(-1)^{|E|}
$$
设 $P=\{S_1,S_2,\cdots,S_m\}$，只要在每个 $S_i$ 内部连边并构成连通图。则容斥系数
$$
 \sum_{C(E)=P}(-1)^{|E|}=\prod_{S \in P} \sum_{G_S \text{连通}} (-1)^{|E(G_S)|}
$$
问题转化为，对 $k$ 个点的无向图，求所有连通边集 $E$ 的 $(-1)^{|E|}$ 之和，记作 $g_k$。

设 $f_k$ 为 $k$ 个点任意无向图的 $(-1)^{|E|}$ 之和，则
$$
f_k=\sum_{i=0}^{\binom{k}{2}} \binom{\binom{k}{2}}{i} (-1)^i=0^{\binom{k}{2}}
$$
故 $k \ge 2$ 时 $f_k=0$，只有 $f_0=f_1=1$。$f$ 的 EGF 为
$$
F=\sum_{k \ge 0} f_k \dfrac{x^k}{k!}=1+x
$$
根据多项式 $\exp$ 的组合意义：
$$
F=\exp G \implies G=\ln F
$$
由 Taylor 展开
$$
G=\sum_{k \ge 1} (-1)^{k-1} \dfrac{x^k}{k}
$$
提取系数得
$$
\left[\dfrac{x^k}{k!}\right]G=\dfrac{(-1)^{k-1}}{k} \implies g_k=(-1)^{k-1}(k-1)!
$$
将 $g_k$ 代入容斥系数，得到最终结论
$$
\boxed{\sum_{P} F(P) \prod_{S \in P} (-1)^{|S|-1} (|S|-1)!}
$$
:::::

记 $\underset{i\in S}{\text{lcm } } d_i=\text{lcm}(S)$。强制点集 $S$ 内 $a$ 值均为 $x$，则必有 $\text{lcm}(S) \mid x$，从而方案数为
$$
F(P)=\prod_{S \in P}\left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
答案为
$$
\sum_{P}\prod_{S \in P}(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor
$$
利用排除 $\min S$ 转移的 trick，容易 $O(2^n \log V)$ 地求出单个 $S$ 的贡献值 $f_S=(-1)^{|S|-1}  (|S|-1)! \left\lfloor \dfrac{m}{\text{lcm}(S)} \right\rfloor$。

构造集合幂级数 $F$，令 $G=\exp F$，则 $[x^U] G$ 即为所求。使用子集卷积 exp 做到 $O(n^2 2^n)$。

总复杂度 $O(n^2 2^n+2^n \log V)$。[代码](https://atcoder.jp/contests/abc236/submissions/79499553)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB525$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-abc240g--stripe-python', 'Teleporting Takahashi · stripe-python', $AKB526$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC240G](https://www.luogu.com.cn/problem/AT_abc240_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有无限大的三维网格，你初始位于 $(0,0,0)$，每步必须移动到某个相邻格点。求 $n$ 次移动后位于 $(x,y,z)$ 的路径数。
>
> $n,|x|,|y|,|z| \le 10^7$，3 秒，1024 MB。

:::::success[题解]

考虑一维情形，求移动 $n$ 步走到 $x_0$ 的路径数。相当于对
$$
\sum_{i=1}^n x_i=x_0,x_i \in \{-1,1\}
$$
的序列 $x_i$ 计数。令 $y_i=\frac{x_i+1}{2}$，则
$$
\sum_{i=1}^n y_i=\dfrac{x_0+n}{2}, y_i \in \{0,1\}
$$
故合法的 $y$ 双射 $x$，方案数 $\dbinom{n}{\frac{x_0+n}{2}}$。

考虑二维情形，难点在于 $(x,y)$ 不独立。套路地将坐标系旋转 $45\degree$，令 $(x,y) \to (x+y,x-y)$，则新的 $x',y'$ 独立，将两个组合数乘起来即可。

考虑三维情形。我们枚举 $x$ 方向上走了 $i$ 步，转化为“1+2”，将三个组合数乘起来再配上系数 $\dbinom{n}{i}$ 求和即可。

复杂度 $O(n)$。[代码](https://atcoder.jp/contests/abc240/submissions/79491819)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB526$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-abc267g--stripe-python', 'Increasing K Times · stripe-python', $AKB527$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC267G](https://www.luogu.com.cn/problem/AT_abc267_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出长为 $n$ 的序列 $a_i$，求有多少个 $1 \sim n$ 的排列 $p_i$ 满足 $\text{asc}(a_{p_i})=k$。$\text{asc}$ 为上升数目。
>
> $n \le 5\times 10^3$，2 秒，1024 MB。

:::::success[题解]

题目相当于求 $a_i$ 有多少个重排的上升数目恰为 $k$。考虑计数本质不同的重排，答案乘上 $\prod c_i!$ 即可，其中 $c_i$ 是第 $i$ 种数的出现次数。

考虑使用插入 DP 解决问题，计数顺序是从小到大插入、

- 用 $f_{n,k}$ 表示当前已经插入了 $1 \sim n$ 中的数字，上升的数目恰为 $k$ 的方案数。

- 用刷表法转移，即从 $f_{n,k}$ 转移到 $f_{n+1,k'}$。我们一次性插入所有数字 $n+1$，设其有 $c$ 个，讨论转移系数。

  - 记 $m$ 为序列长度，考虑序列 $x_1,x_2,\cdots,x_{m+1}$，其满足 $\sum \limits_{i=1}^{m+1} x_i=c$。$x_i$ 的组合意义是第 $i$ 个空位中插入了几个 $n+1$。

  - 由于所有插入的数都相同，只要讨论非零的 $x_i$ 对 $k'$ 的贡献：

    - 在原序列中，共有 $k$ 个上升空位，贡献为 $0$。
    - 在原序列中，共有 $m-1-k$ 个下降空位，贡献为 $1$。
    - 插入开头，形成一个下降，贡献为 $0$。
    - 插入结尾，形成一个上升，贡献为 $1$。

    综上，考虑枚举总贡献量 $i$，转移系数就是 $x_1 \sim x_{m-k}$ 中恰有 $i$ 个非零元素的方案数。

  - 考虑分步计数：

    - 先钦定 $i$ 个元素非零，方案数 $\dbinom{m-k}{i}$。

    - 设选出的变量为 $y_1 \sim y_i$，其余变量强制为 $0$。$x_{m-k+1} \sim x_{m+1}$ 的变量记为 $z_1 \sim z_{k+1}$。

    - 再使用不定方程模型的技巧计算。即令 $y'_i=y_i-1$，方程变为 $\left(\sum \limits_{j=1}^i y'_i\right)+\left(\sum\limits_{j=1}^{k+1} z_i \right)=c-i$。这是一个 $i+k+1$ 个变量的不定方程正整数解计数，方案数
      $$
      \binom{(c-i)+(i+k-1)-1}{(i+k+1)-1}=\binom{c+k}{i+k}
      $$

  - 综上所述，转移式 $f_{n,k} \to \dbinom{m-k}{i} \dbinom{c+k}{i+k}f_{n+1,k+1}$。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $f_{n,k} \prod c_i!$。

直观感受复杂度是 $O(n^3)$ 的。不过注意到 $i \le c$ 时转移才有意义，故 $i$ 的总枚举次数是 $\sum c_i=n$，因此复杂度只有 $O(n^2)$。[代码](https://atcoder.jp/contests/abc267/submissions/76748988)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB527$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-abc268g--stripe-python', 'Random Student ID · stripe-python', $AKB528$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC268G](https://www.luogu.com.cn/problem/AT_abc268_g)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个字符串 $S_i$，字符集 $\Sigma=\{{\tt{a}},{\tt{b}},\cdots,{\tt{z}}\}$。从 $\Sigma$ 的 $26!$ 种排列中随机选取一个，并按照该顺序定义字典序。
>
> 对每个 $i$ 求出 $S_i$ 的字典序排名期望。
>
> $\sum |S_i| \le 5 \times 10^5$，3 秒，1024 MB。

:::::success[题解]

设所有字符串中，是 $S_i$ 的前缀的有 $a$ 个，$S_i$ 是真前缀的有 $b$ 个，其余串有 $c=n-a-b$ 个。

显然这 $a$ 个串必然 $\le S_i$，这 $b$ 个串必然 $>S_i$，而剩余 $c$ 个串各有 $\frac{1}{2}$ 的概率 $< S_i$。

注意期望的线性性不要求事件独立，可以直接拆成
$$
\mathbb{E}[r_i]=a \times 1+b \times 0+c \times \dfrac{1}{2}=\boxed{a+\frac{c}{2}}
$$
只要求出 $a,b$，哈希或 Trie 均容易实现。复杂度 $O(L)$。[代码](https://www.luogu.com.cn/article/oq1br2ra)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB528$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-abc295e--stripe-python', 'Kth Number · stripe-python', $AKB529$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ABC295E](https://www.luogu.com.cn/problem/AT_abc295_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$，值域为 $[0,m]$。对于每个 $a_i=0$ 的位置 $i$，独立等概率地选择 $x \in [1,m]$ 令 $a_i \gets x$。求第 $k$ 小数的期望值。
>
> $k,n,m \le 2 \times 10^3$，4 秒，1024 MB。

::::::success[题解]

01 转化 trick。观察如下代数式
$$
\sum_{a} a_k=\sum_{a}\sum_{i=1}^{m} [i \le a_k] = \sum_{i=1}^m \sum_a [i \le a_k]
$$
考虑枚举 $i \in [1,m]$，对 $i \le a_k$ 的 $a$ 序列计数。不妨计数 $a_k<i$ 的 $a$ 序列数目。

设初始空位有 $c$ 个，原本 $<i$ 的数有 $x$ 个。枚举最终 $<i$ 的位置的数目 $j$，进行分步计数：

- 从 $c$ 个空位中选择 $j-x$ 个，方案数 $\dbinom{c}{j-x}$。
- 给 $j-x$ 个空位填入 $1 \sim i-1$ 中的数，方案数 $(i-1)^{j-x}$。
- 给 $c-(j-x)$ 个空位填入 $i \sim m$ 中的数，方案数 $(m-i+1)^{c-j+x}$。

由乘法原理合并，写出答案式
$$
\boxed{\sum_{i=1}^m\left( m^c-\sum_{j =\max(x,k)}^{c+x} \binom{c}{j-x}(i-1)^{j-x}(m-i+1)^{c-j+x}\right)}
$$
除以 $m^c$ 即为期望。复杂度 $O(nm)$。

:::::info[01 转化]

代数表达是下面的式子
$$
\sum_{i=1}^n a_i=\sum_{i=1}^n \sum_{j \ge 1} [a_i \ge j]=\sum_{j \ge 1} \sum_{i=1}^n [a_i\ge j]
$$
组合意义就是枚举 $j$，将 $\ge j$ 的数视作 $1$，$<j$ 的数视作 $0$，求 01 序列总和。

对于排序 / kth / 中位数相关的题目，考察 $0/1$ 的行为，一般会比考察所有数的行为简单很多。

:::::

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB529$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-agc005d--stripe-python', '~K Perm Counting · stripe-python', $AKB530$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[AGC005D](https://www.luogu.com.cn/problem/AT_agc005_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$，对满足 $\forall i \in [1,n], |a_i-i| \ne k$ 的 $1\sim n$ 的排列 $a_i$ 计数。
>
> $n \le 2\times 10^3$，2 秒，256 MB。

:::::success[题解]

将 $(i,a_i)$ 拍到二维平面上，约束即 $y=x- k$ 和 $y=x+k$ 两条直线上不能有点。 

考虑容斥，钦定 $m$ 个位置突破限制，剩余 $n-m$ 个位置随意排列，容斥系数 $(-1)^m (n-m)!$。

约束转化为，选择 $m$ 个点位于 $y=x\pm k$ 上，要求横纵坐标两两不同。我们将横纵坐标相同的点连边，则 $m$ 个点构成图的独立集。可以发现图的形态是若干条链：

![](https://cdn.luogu.com.cn/upload/image_hosting/npwddpef.webp)

我们从长为 $n$ 的链上取大小为 $k$ 的独立集，转化为在 $k$ 个选点间插入 $k-1$ 个未选点，剩余点随意，方案数 $\boxed{\dbinom{n-k+1}{k}}$。

设每条链的长度为 $b_i$，则单链的 OGF 为
$$
F_i=\sum_{k \ge 0} \binom{b_i-k+1}{k} x^k
$$
将 $O(n)$ 个 $F$ 暴力卷积后，取 $x^m$ 项系数即为容斥 $m$ 的答案。

复杂度 $O(n^2)$。[代码](https://atcoder.jp/contests/agc005/submissions/79590009)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB530$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-agc005f--stripe-python', 'Many Easy Problems · stripe-python', $AKB531$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[AGC005F](https://www.luogu.com.cn/problem/AT_agc005_f)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个节点的无根树。对 $k=1,2,\cdots,n$ 求出：选择 $k$ 个关键点的虚树点数之和，对 NTT 模数取模。
>
> $n \le 2\times 10^5$，5 秒，512 MB。

:::::success[题解]

将贡献拆到节点上。对点集 $S$ 和节点 $u \notin S$，点 $u$ 不属于 $S$ 的虚树，当且仅当删去 $u$ 后 $S$ 仍然连通。

设删去 $u$ 后子树大小分别为 $a_1 \sim a_m$，则 $u$ 对 $\text{ans}_k$ 的贡献为
$$
\binom{n}{k}-\sum_{i=1}^m \binom{a_i}{k}
$$
对 $a_i$ 开桶进行优化。记 $a_i=x$ 的 $(u,i)$ 对有 $c_x$ 个，那么 $x$ 对 $\text{ans}_k$ 的负贡献写作
$$
\sum_{x=1}^n c_x \binom{x}{k}=\sum_{x=1}^n \dfrac{c_x \times x!}{k!(x-k)!}
$$
其中 $\frac{1}{k!}$ 是常数，剩余部分视作 $c_x \times x!$ 和 $\frac{1}{x!}$ 的差卷积。用正贡献 $n \binom{n}{k}$ 减去即为答案。

复杂度 $O(n \log n)$。[代码](https://atcoder.jp/contests/agc005/submissions/79595197)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB531$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-agc006c--stripe-python', 'Rabbit Exercise · stripe-python', $AKB532$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[AGC006C](https://www.luogu.com.cn/problem/AT_agc006_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 数轴上有 $n$ 个物体，第 $i$ 个物体初始位于 $x_i$ 位置。
>
> 进行 $k$ 轮操作，每轮操作包含 $m$ 次跳跃。第 $i$ 次跳跃中，标号为 $a_i$ 的物体会等概率地选择 $a_i-1$ 或 $a_i+1$ 作为 $x$，跳跃到关于 $x$ 对称的位置，其中 $1<a_i<n$。
>
> 进行 $k$ 轮操作后，对每个物体求出最终坐标的期望值。浮点精度要求 $10^{-9}$。
>
> $n,m \le 10^5$，$k \le 10^{18}$，2 秒，256 MB。 

:::::success[题解]

考虑期望递推。设 $f_i$ 为当前时刻物体 $i$ 的期望位置，对 $x$ 进行变换时：

- 选定 $i-1$ 对称：$f_i \gets 2f_{i-1}-f_i$，概率 $\frac{1}{2}$。
- 选定 $i+1$ 对称：$f_i \gets 2f_{i+1}-f_i$，概率 $\frac{1}{2}$。

从而转移式为
$$
\begin{aligned}
f_i &\gets \dfrac{1}{2}(2f_{i-1}-f_i)+\dfrac{1}{2}(2f_{i+1}-f_i)\\
&= f_{i+1}+f_{i-1}-f_i
\end{aligned}
$$
我们得到单轮操作的转移。根据经典结论，取 $f$ 的差分 $d_i=f_i-f_{i-1}$，则对 $f_i$ 操作等价于交换 $d_i,d_{i+1}$。

不妨维护 $d$ 序列，模拟一轮操作可以得到对 $d$ 的置换，对置换做 $k$ 次幂即为最终的 $d$ 数组。

复杂度 $O(m+n \log k)$。[代码](https://atcoder.jp/contests/agc006/submissions/79264939)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB532$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-agc030d--stripe-python', 'Inversion Sum · stripe-python', $AKB533$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[AGC030D](https://www.luogu.com.cn/problem/AT_agc030_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$ 和 $m$ 次可选操作 $(x_i,y_i)$。对每个 $i=1,2,\cdots,m$ 依次选择交换 $a_{x_i},a_{y_i}$ 或不操作。
>
> 求 $2^m$ 种操作方案中，最终序列 $a_i$ 的逆序对数之和。
>
> $n,m \le 3 \times 10^3$，3 秒，1024 MB。

:::::success[题解]

不妨将问题视作求逆序对数的期望，乘上 $2^m$ 即为答案。

注意到 $n^2$ 的状态数可以接受，考虑在 DP 中记录每对 $(i,j)$ 的情况：

- 设 $f_{i,j}$ 为当前时刻 $a_i>a_j$ 的**条件概率**。

- 转移依次考虑每个 $(x,y)$ 操作：

  - 若 $x \ne i \land y \ne j$：$f_{i,j}$ 不变。
  - 若 $x=i \land y \ne j$：$f_{x,j} \gets \dfrac{f_{x,j}+f_{y,j}}{2}$。因为 $(x,j)$ 有 $\frac{1}{2}$ 的概率继承原状态，$\frac{1}{2}$ 的概率交换 $a_x,a_y$ 后继承 $(y,j)$ 的状态。
  - 若 $x\ne i \land y=j$：$f_{i,y} \gets \dfrac{f_{i,y}+f_{i,x}}{2}$。
  - 若 $x=i \land y=j$：$f_{x,y} \gets \dfrac{f_{x,y}+f_{y,x}}{2}$。

  注意 $(x,y)$ 的地位相同，故上述转移需要交换 $x,y$ 后再做一次。

- DP 初值为 $f_{i,j}=[a_i > a_j]$。

- 答案为 $m$ 轮转移后的 $2^m\sum \limits_{i<j} f_{i,j}$。

注意到每轮转移只会修改 $O(n)$ 个位置，总复杂度 $O(n^2+nm)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB533$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc118e--stripe-python', 'Avoid Permutations · stripe-python', $AKB534$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC118E](https://www.luogu.com.cn/problem/AT_arc118_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 定义一个 $1 \sim n$ 的排列 $p_i$ 的权值为：从 $(0,0)$ 出发，每次只能向右或向上移动，不经过所有 $(i,p_i)$ 点，最终到达 $(n+1,n+1)$ 的格路数目。
>
> 给出一个长为 $n$ 的序列 $a_i$，其中若干位置不确定。求所有填入数字使得 $a$ 成为排列的方案中，所有排列的权值之和。
>
> $n \le 200$，2 秒，1024 MB。

:::::success[题解]

直观的思路是对于每个排列统计格路的数目，但没有前途。

考虑**切换计数主体**。我们考察一条 $(0,0) \to (n+1,n+1)$ 的格路，并计算有多少个合法排列满足路径不经过任意 $(i,p_i)$。

用钦定至少的组合意义容斥，钦定路径点集的一个子集 $S$，强制 $p_i$ 满足 $S$ 中点的限制，容斥系数 $(-1)^{|S|}$。

将 $S$ 按照一定顺序排序，考虑 $S$ 中的相邻点对 $(x_1,y_1), (x_2,y_2)$。根据格路的性质，必有 $x_1<x_2 \land y_1 < y_2$。

我们带着容斥系数 DP：

- 记 $f_{s,x,y,k}$ 为满足以下条件时，从 $(0,0)$ 走到 $(x,y)$ 的格路中，带容斥系数的方案数之和：
  - 当前位于 $(x,y)$。
  - 在 $(0,0) \to (x,y)$ 的格路上，已经钦定了 $k$ 个点。需要说明的是，这里的 $k$ 个点必须在 $a_i$ 中是不确定的。
  - 为了维护 $x_1 <x_2 \land y_1<y_2$ 性质，我们用 $s$ 记录上一次决策：
    - $s=0$：可以任意在 $(x,y)$ 处进行钦定。
    - $s=1$：上一次钦定后只向右走，因此当前位置不能钦定。
    - $s=2$：上一次钦定后只向上走，因此当前位置不能钦定。
- 转移考虑刷表，从 $f_{s,x,y,k}$ 转移到 $f_{s',x',y',k'}$。
  - 不钦定 $(x,y)$：讨论清楚 $s\to s'$ 的对应关系后，由 $(x,y)$ 转移到 $(x+1,y)$ 和 $(x,y+1)$ 即可。
  - 钦定 $(x,y)$：此时需要判断是否可以钦定这个点，需要同时满足下列要求：
    - $1 \le x,y \le n$。
    - 若 $a_x \ne 1$，则 $a_x=y$。
    - 若 $a_x=-1$，则 $y$ 没有在 $a_i$ 中出现过。
      如果满足上述限制则可以钦定，此时 $k'=k+[a_x =-1]$。转移为讨论钦定后向右还是向上走，因此：
    - $f_{1,x+1,y,k' } \gets (-1) f_{0,x,y,k}$。
    - $f_{2,x,y+1,k'} \gets (-1) f_{0,x,y,k}$。
      注意转移时带的容斥系数 $-1$。
- DP 初值为 $f_{0,0,0,0}=1$。
- 记 $m$ 为未确定位置的数目，则答案为 $\sum\limits_{k=0}^m (m-k)!\sum\limits_{s \in \{0,1,2\}} f_{s,n+1,n+1,k}$。这个式子的组合意义是：考虑枚举 $k$ 个位置被钦定，剩余 $m-k$ 个位置全排列，再乘上 $(0,0) \to (n+1,n+1)$ 钦定 $k$ 个位置带容斥系数的方案数。

总复杂度 $O(n^3)$。[代码](https://atcoder.jp/contests/arc118/submissions/76108227)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB534$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc139d--stripe-python', 'Priority Queue 2 · stripe-python', $AKB535$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC139D](https://www.luogu.com.cn/problem/AT_arc139_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定多重集 $S=\{a_1,a_2,\cdots,a_n\}$，保证 $a_i \in [1,m]$。重复 $k$ 次以下操作：
>
> - 选定 $i \in [1,m]$ 加入 $S$，并从 $S$ 中删去第 $x$ 小元素。
>
> 求所有 $m^k$ 种操作方案的 $\sum\limits_{i \in S} i$ 之和。
>
> $n,m,k \le 2\times 10^3$，2 秒，1024 MB。

:::::success[题解]

根据 01 转化 trick 有
$$
\sum_{i\in S} i=\sum_{i \in S} \sum_{j=1}^m [j \le i]=\sum_{j=1}^m \sum_{i \in S} [i \ge j]
$$
枚举 $j \in [1,m]$，计算 $i \in S \land i \ge j$ 的 $i$ 的贡献。

我们将 $\ge j$ 的数视作 $1$，$<j$ 的数视作 $0$。设当前集合中 $1$ 的数目为 $c$，分析 $c$ 的变化：

- 若操作加入 $1$：
  - 若 $x \le n-c$ 则删去 $0$，$c \gets c+1$。
  - 若 $x>n-c$ 则删去 $1$，$c$ 不变。
- 若操作加入 $0$：
  - 若 $x \le n-c+1$ 则删去 $0$，$c$ 不变。
  - 若 $x>n-c+1$ 则删去 $1$，$c \gets c-1$。

设初始有 $p$ 个数 $\ge j$，操作过程中加入 $q$ 个 $\ge j$ 的数。根据上述讨论，$c$ 的取值与操作顺序无关。记 $r=n-x+1$ 则：

- 若 $p \le r$，则 $c$ 单增且 $\le r$，故 $c=\min(p+q,r)$。
- 若 $p>r$，则 $c$ 单减且 $\ge r$，故 $c=\max(p-(k-q),r)$。

对每个 $j \in [1,m]$，容易求出 $p$ 的取值后枚举 $q$，讨论贡献系数：

- 选出的 $k$ 个数中恰有 $q$ 个数 $\ge j$，方案数 $\binom{k}{q}$。
- $\ge j$ 的 $m-j+1$ 个数任取，方案数 $(m-j+1)^q$。
- $<j$ 的 $j-1$ 个数任取，方案数 $(j-1)^{k-q}$。

综上，答案式子为
$$
\boxed{\sum_{j=1}^m \sum_{q=0}^k \binom{k}{q}(m-j+1)^q (j-1)^{k-q} \times c}
$$
对 $a_i$ 排序后双指针维护 $p$，复杂度 $O(n\log n+mk)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB535$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc170c--stripe-python', 'Prefix Mex Sequence · stripe-python', $AKB536$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC170C](https://www.luogu.com.cn/problem/AT_arc170_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n,m$ 和长为 $n$ 的 01 串 $S$。求满足以下条件的非负整数序列 $a_1,a_2,\cdots,a_n$ 的数目：
>
> - $a_i \in [0,m]$。
> - $S_i=\tt{1}$ 是 $a_i=\operatorname{mex}(a_1,a_2,\cdots,a_{i-1})$ 的充要条件。
>
> $n \le 5000$，$m \le 10^9$，2 秒，1024 MB。

:::::success[题解]

直观的想法是考虑记录 $f_{i,j}$ 为已确定前 $i$ 个数，且当前前缀 $\operatorname{mex}$ 为 $j$ 时的方案数。但是 $j \to j'$ 通过这些信息无法转移。

考虑修改状态并重新推导转移系数：

- 记 $f_{i,k}$ 为满足如下条件时，前缀 $a_1 \sim a_i$ 的填数方案数：
  - 前缀 $a_1 \sim a_i$ 中恰有 $k$ 个不同数字。
  - 前缀 $a_1 \sim a_i$ 合法。
- 转移考虑填表，由 $f_{i-1,k}$ 转移到 $f_{i,k'}$。此时的 $k'$ 容易维护。
  - 若 $S_i=\tt{1}$，则 $a_i$ 作为前缀 $\operatorname{mex}$ 在之前没有出现，转移系数 $1$。转移式 $f_{i,k+1} \gets f_{i-1,k}$。
  - 若 $S_i=\tt{0}$：
    - 填入已出现的数字：填入任意数字都不会是 $\operatorname{mex}$，转移系数 $k$。转移式 $f_{i,k} \gets k \times f_{i-1,k}$。
    - 填入未出现的数字：共有 $m+1-k$ 个可用数字，除去恰为 $\operatorname{mex}$ 的那个，转移系数 $m-k$。转移式 $f_{i,k+1}\gets (m-k)f_{i-1,k}$。
  - 注意特判 $m<k$ 的情形。
- DP 初值为 $f_{0,0}=1$。
- 答案为 $\sum\limits_{k=1}^n f_{n,k}$。

复杂度 $O(n^2)$。[代码](https://atcoder.jp/contests/arc170/submissions/76114030)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB536$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc174e--stripe-python', 'Existence Counting · stripe-python', $AKB537$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC174E](https://www.luogu.com.cn/problem/AT_arc174_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$ 和长为 $n$ 的序列 $b_i$。考虑每个 $k=1,2,\cdots,m$，对满足下列条件长为 $n$ 的序列 $a_i$ 计数：
>
> - $\forall i \in [1,n], a_i \in [1,m]$。
> - $a$ 的所有元素互不相同。
> - $\exists i \in [1,n], a_i=k$。
> - $a$ 的字典序不大于序列 $b$。
>
> 保证 $b_i \in [1,m]$ 且 $b$ 的元素互不相同。
>
> $n,m \le 3 \times 10^5$，4 秒，1024 MB。

:::::success[题解]

设 $f_k$ 为数字 $k$ 的答案。我们枚举 $i=1 \to n$，钦定 $\forall j<i, a_j=b_j$ 且 $a_i<b_i$。人话就是钦定 LCP，考虑这种序列对每个 $f_k$ 的贡献。

设 $b_1 \sim b_{i-1}$ 组成集合 $S$，可填入 $a_i$ 的数有 $c$ 个，则 $c$ 是 $x \notin S \land x<b_i$ 的 $x$ 的数目。用权值树状数组维护即可。

对 $k$ 分类讨论：

- 若 $k \in S$，$a_i$ 的填法为 $c$，而 $a_{i+1} \sim a_n$ 随意填，$f_k \gets c \times A_{m-i}^{n-i}$。
- 若 $k \notin S$：
  - 将 $k$ 扔到后 $n-i$ 个位置，$a_i$ 的填法为 $c$，有 $f_k \gets c \times A_{m-i-1}^{n-i-1} \times (n-i)$，其中 $n-i$ 是选出 $k$ 所在位置的方案数。
  - 若 $k<a_i$，可以将 $k$ 填到 $a_i$，于是 $f_k \gets A_{m-i-1}^{n-i}$。

用两个差分树状数组维护 $k \in S$ 和 $k \notin S$ 的 $f_k$，支持区间加单点查询。扫描到 $b_i$ 时其从 $\notin S$ 的数组移动到 $\in S$ 的数组里。

注意特判 $a=b$ 的情况，令 $k \in S$ 的 $f_k \gets 1$。

复杂度 $O(n \log m)$。[代码](https://atcoder.jp/contests/arc174/submissions/79453271)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB537$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc183c--stripe-python', 'Not Argmax · stripe-python', $AKB538$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC183C](https://www.luogu.com.cn/problem/AT_arc183_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对 $1 \sim n$ 的排列 $p_i$，给定 $m$ 条限制 $(l_i,r_i,x_i)$，表示 $\max \limits_{k \in [l_i,r_i]} p_k \ne p_{x_i}$。求满足所有限制的排列数目。
>
> $n \le 500$，$m \le 10^5$，2 秒，1024 MB。

:::::success[题解]

注意到我们只关心相对大小，考虑最值分治式 DP：

- 设 $f_{l,r}$ 为 $[l,r]$ 区间的合法方案数。注意我们仅关心相对大小。

- 转移枚举 $k$ 并钦定 $k$ 为 $[l,r]$ 的区间 $\max$ 位置。先判定 $k$ 是否合法：

  - 若 $x_i=k$ 且 $[l_i,r_i] \subseteq [l,r]$ 必不合法。容易验证其余情况都合法。

  转移将 $[l,k)$ 和 $(k,r]$ 进行合并。只要重新钦定大小顺序，保证同组排名不变，选法数 $\binom{r-l}{k-l}$。转移方程
  $$
  \boxed{f_{l,r}=\sum_{k \in [l,r]} \binom{r-l}{k-1}f_{l,k-1} \times f_{k+1,r}}
  $$

- DP 初值为 $f_{i,i-1}=f_{i,i}=1$。注意特判 $l_i=r_i$ 的情形，不存在合法排列。

- 答案为 $f_{1,n}$。

预处理 $S_k=\{[l_i,r_i] \mid x_i=k\}$，只要判定 $\exists [l',r'] \in S_k, [l',r'] \subseteq [l,r]$。对每个 $S_k$ 递推出 $a_x=\min \limits_{l_i \ge x} r_i$，查询 $(l,r)$ 判断 $a_l \le r$ 是否成立即可。

复杂度 $O(m+n^3)$。[代码](https://atcoder.jp/contests/arc183/submissions/79639704)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB538$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc197e--stripe-python', 'Four Square Tiles · stripe-python', $AKB539$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC197E](https://www.luogu.com.cn/problem/AT_arc197_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,H,W$，保证 $H,W \le 3n-1$。你需要将 $4$ 个 $n \times n$ 的正方形放置在 $H \times W$ 的网格上，方形不能相互覆盖，求合法摆放方案数。
>
> 认为两种方案不同，当且仅当存在一个方格在一种方案中被方形覆盖，另一个方案中未被覆盖。
>
> 多测，$T \le 2 \times 10^5$，$n,H,W \le 10^9$，2 秒，1024 MB。

:::::success[题解]

注意到 $H,W \le 3n-1$，故四个方形的排布必然如下图所示：

![](https://cdn.luogu.com.cn/upload/image_hosting/jtn2oigo.webp?x-oss-process=image/resize,m_lfit,w_300)

变量 $x_i,y_i$ 满足 $x_i \in [n, H-n+1] \land y_i \in [n,H-w+1]$。

不妨令 $x_i \gets x_i-n+1, y_i \gets y_i-n+1$，则新的范围为 $x_i \le H-2n+2$ 且 $y_i \le W-2n+2$，设这两个值为 $h,w$。由题目得到如下约束：

- $x_i \in [1,h] \land y_i \in [1,w]$。
- $x$ 轴不相交：$x_1 < x_2 \land x_4 < x_3$。
- $y$ 轴不相交：$y_1<y_4 \land y_2<y_3$。
- 方形 $1,3$ 不交：$x_3 \le x_1 \land y_3 \le y_1$ 不成立。
- 方形 $2,4$ 不交：$x_2 \le x_4 \land y_2 \ge y_4$ 不成立。

容易发现 $x,y$ 两维独立，对一维情形进行讨论即可。我们做一个二元容斥：

- 总方案数：由 $1 \le x_1 < x_2 \le h$ 得方案数 $\dbinom{h}{2}^2$。

- 突破一个限制：满足 $x_1< x_2 \land x_4<x_3 \land x_3 \le x_1$。枚举 $x_1=i$，则 $1 \le x_4 < x_3 \le i \land x_2>i$，方案数
  $$
  \sum_{i=1}^h \binom{h}{2}(n-i)=\binom{h+1}{4}
  $$

- 突破两个限制：满足 $x_1<x_2 \land x_4 < x_3 \land x_3 \le x_1 \land x_2 \le x_4$。画数轴可以发现这个条件是矛盾的，方案数 $0$。

由乘法原理合并独立的两维，答案式子
$$
\boxed{\binom{h}{2}^2 \binom{w}{2}^2 -2 \binom{h+1}{4} \binom{w+1}{4}}
$$
复杂度 $O(1)$。[代码](https://atcoder.jp/contests/arc197/submissions/79451904)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB539$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc207a--stripe-python', 'Affinity for Artifacts · stripe-python', $AKB540$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC207A](https://www.luogu.com.cn/problem/AT_arc207_a)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个任务，第 $i$ 个任务的成本为 $a_i$。
>
> 你初始持有变量 $x$，以任意顺序执行所有任务。执行第 $i$ 个任务时，$x \gets x-a_i$，并对 $a_j \ge 1$ 令 $a_j \gets a_j-1$。
>
> 求最终 $x \ge 0$ 的执行顺序数目。
>
> $n \le 10^2$，$a_i,x \le 10^9$，2 秒，1024 MB。

:::::success[题解]

设第 $i$ 个任务是第 $p_i$ 个被执行的，约束即为
$$
\sum_{i=1}^n \max(0,a_i-p_i+1) \le x
$$
直接对着 DP 需要记录 $\sum a_i$ 级别的信息。我们转换视角，考虑任务节省的成本。设 $k=\left(\sum \limits_{i=1}^n a_i\right) -x$，只要
$$
\sum_{i=1}^n \min(a_i,p_i-1) \ge k
$$
若 $k>\binom{n}{2}$ 无解，$k \le 0$ 答案为 $n!$，这样值域就降到 $O(n^2)$ 级别。

将 $i \to p_i$ 描述为二分图匹配，边权为 $\min(a_i,p_i-1)$，转化为对权值 $\ge k$ 的完美匹配计数。

将 $a_i$ 和 $p_i-1$ 丢到同一个数组 $b$ 中降序排序，则边权由位置靠右的点决定。设计延迟钦定配对 DP：

- 设 $f_{i,x,y,s}$ 为满足如下条件时，完美匹配的方案数：
  - 仅考虑 $b_1 \sim b_i$。
  - 当前有 $x$ 个左部点失配，$y$ 个右部点失配。
  - 已匹配边的边权和为 $s$。
- 转移时根据点的类型分讨。下面以 $b_{i+1}$ 是左部点为例说明，右部点转移同理。
  - 令 $b_{i+1}$ 暂时失配，转移 $f_{i,x,y,s} \to f_{i+1,x+1,y,s}$。
  - 令 $b_{i+1}$ 与之前某个右部点匹配，转移  $f_{i,x,y,s} \times y \to f_{i+1,x,y-1,s+b_{i+1}}$。
- DP 初值为 $f_{0,0,0,0}=1$。
- 答案为 $\sum \limits_{j=k}^{\binom{n}{2}} f_{2n,0,0,j}$。

不难发现，由于 $b_1 \sim b_i$ 的类型确定，状态中 $x,y$ 只需记录一维，另一维可以预处理后算出来。复杂度 $O(n^4)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB540$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc215d--stripe-python', 'cresc. · stripe-python', $AKB541$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC215D](https://www.luogu.com.cn/problem/AT_arc215_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$，求满足以下条件的非负整数序列 $s_1\sim s_n$ 的数目：
>
> - $s_1 \ge s_2 \ge \cdots \ge s_n$。
> - 存在序列 $a_1 \sim a_{n+1}$，满足 $a_i \in [0,m]$ 且 $\forall i \in [1,n], s_i=a_i+a_{i+1}$。
>
> $n,m \le 10^7$，2 秒，1024 MB。

:::::success[题解]

将 $s_i$ 的定义式代入合法条件
$$
a_1+a_2 \ge a_2+a_3 \ge a_3+a_4 \ge \cdots \ge a_n+a_{n+1}
$$
可以得到 $a_i$ 的约束条件：

- $a_1 \ge a_3 \ge a_5 \ge  \cdots $。
- $a_2 \ge a_4 \ge a_6 \ge \cdots$。

直接对 $a_1 \sim a_{n+1}$ 计数是错的，因为 $a \leftrightarrow s$ 不是双射。

注意到对确定的 $s_1 \sim s_n$，合法的一族 $a$ 形如 $[a_1 + \delta,a_2-\delta,a_3+\delta,\cdots]$。钦定代表元为 $\delta$ 取极限值的序列 $a$，则 $a$ 有下列约束：

- $a_1=m \lor a_x=0$。其中 $x$ 为最大的偶数下标。

消除平移后得到 $a \leftrightarrow s$ 的双射。设奇数下标数目为 $p=\left\lceil \frac{n+1}{2} \right\rceil$，偶数下标数目为 $q=\left\lfloor \frac{n+1}{2} \right\rfloor$，奇偶位置独立，可以分类计数：

- $a_1=m$ 时：
  - 奇数位对值域 $[0,m]$，长为 $p-1$ 的不降序列计数，方案数 $\dbinom{m+p-1}{m}$。
  - 偶数位对值域 $[0,m]$，长为 $q$ 的不降序列计数，方案数 $\dbinom{m+q}{m}$。
- $a_x=0$ 时，同理可得方案数 $\dbinom{m+p}{m}\dbinom{m+q-1}{m}$。
- $a_1 =m \land a_x=0$ 时，同理可得方案数 $\dbinom{m+p-1}{m}\dbinom{m+q-1}{m}$。

二元容斥即可得到答案。复杂度 $O(n+m)$。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB541$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc230a--stripe-python', 'Meeting on Tree · stripe-python', $AKB542$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC230A](https://www.luogu.com.cn/problem/AT_arc230_a)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个节点的无根树。对 $S \subseteq V$，设 $f(S)=\min\limits_{u \in T} \sum\limits_{v \in S} \text{dis}(u,v)$，求所有 $S$ 的 $f$ 值之和。
>
> $n \le 3 \times 10^5$，2 秒，1024 MB。

:::::success[题解]

将贡献拆到每条边上。设删去某条边后形成两个连通块 $P,Q$，记 $x=|P|,y=|Q|$，枚举 $|S \cap P|=i$ 与 $|S \cap Q|=j$，则这条边至少被经过 $\min(i,j)$ 次。取带权重心即可取到下界。

从而 $(x,y)$ 对答案的贡献为
$$
f(x,y)=\sum_{i=0}^x \sum_{j=0}^y \min(i,j) \binom{x}{i}\binom{y}{j}
$$
答案为所有 $f$ 值求和，其中 $x+y=n$。有一个[ $O(n^{1.5})$ 做法](https://www.luogu.com.cn/article/j1bbafyd)，下面讲如何推式子。

利用恒等式 $\min(i,j)=\frac{i+j-|i-j|}{2}$ 代入得
$$
f(x,y)= \dfrac{1}{2} \sum_{i=0}^x \sum_{j=0}^y (i+j) \binom{x}{i}\binom{y}{j}-\dfrac{1}{2}\sum_{i=0}^x \sum_{j=0}^y |i-j| \binom{x}{i}\binom{y}{j}
$$
根据组合恒等式 $\sum \limits_{i=0}^x i \dbinom{x}{i}=x2^{x-1}$ 且 $\sum \limits_{j=0}^y \dbinom{y}{j}=2^y$，于是关于 $i$ 的求和部分
$$
\sum_{i=0}^x \sum_{j=0}^y i \binom{x}{i}\binom{y}{j}=x2^{x-1}2^y=x2^{x+y-1}
$$
同理可得关于 $j$ 的求和部分为 $y2^{x+y-1}$。于是第一个和式的值为 $\boxed{n2^{n-1}}$。

对于第二个和式，令 $k=i-j$ 由范德蒙德卷积
$$
\begin{aligned}
&\sum_{i=0}^x \sum_{j=0}^y |i-j| \binom{x}{i}\binom{y}{j}\\
=&\sum_{k=-y}^{x} |k| \binom{x+y}{y+k}\\
=&\sum_{u=0}^{x+y} |u-y| \binom{x+y}{u}\\
=&\sum_{u=0}^{y} (y-u) \binom{x+y}{u}+\sum_{u=y+1}^{x+y} (u-y)\binom{x+y}{u}
\end{aligned}
$$
对于左侧，根据吸收恒等式及递推公式化简
$$
\begin{aligned}
&\sum_{u=0}^{y} y \binom{x+y}{u}-\sum_{u=0}^{y} u \binom{x+y}{u}\\
=&y\sum_{u=0}^y \binom{n}{u}-n\sum_{u=0}^{y-1} \binom{n-1}{u}\\
=& \boxed {y \binom{n-1}{y} - (x-y) \sum_{u=0}^{y-1} \binom{n-1}{u}}
\end{aligned}
$$
右半段根据对称性，只要将 $x,y$ 互换即可。

预处理组合数下指标前缀和即可做到 $O(n)$。注意 $\times \frac{1}{2}$ 等细节。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB542$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc230d--stripe-python', 'Min Max Matrix · stripe-python', $AKB543$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC230D](https://www.luogu.com.cn/problem/AT_arc230_d)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m,k$，对满足下列条件的 $n \times m$ 矩阵 $a_{i,j}$ 计数：
>
> - $\forall i\in [1,n]\land j \in [1,m], a_{i,j} \in [1,k]$。
> - $\min \limits_{i \in [1,n]} \max\limits_{j \in [1,m]} a_{i,j}=\max \limits_{j \in [1,m]} \min \limits_{i \in [1,n]} a_{i,j}$。
>
> $n,m \le 200$，$k \le 10^8$，4 秒，1024 MB。

::::::success[题解]

设 $X=\min \limits_{i \in [1,n]} \max\limits_{j \in [1,m]} a_{i,j}, Y=\max \limits_{j \in [1,m]} \min \limits_{i \in [1,n]} a_{i,j}$。

**性质** 对任意矩阵，必有 $X \ge Y$ 成立。

**证明** 取任意位置 $(i,j)$，有 $\min\limits_{i' \in [1,n]} a_{i',j} \le a_{i,j} \le \max\limits_{j'\in [1,m]} a_{i,j'}$ 恒成立。

从而 $\forall i \in [1,n], \max\limits_{j \in [1,m]}\min\limits_{i' \in [1,n]} a_{i',j} \le \max\limits_{j' \in [1,m]} a_{i,j'}$。对右侧取 $\min$ 得 $\max\limits_{j \in [1,m]}\min\limits_{i' \in [1,n]} a_{i',j} \le \min\limits_{i \in [1,n]}\max\limits_{j' \in [1,m]} a_{i,j'}$，即证 $Y \le X$。

枚举 $X=Y=t$，设 $f(x,y)$ 为 $X \ge x \land Y \le y$ 的矩阵数，二元容斥求出答案
$$
\sum_{t=1}^k \left(f(t,t)-f(t+1,t)-f(t,t-1)+f(t+1,t-1)\right)
$$
拆开 $X \ge x \land Y \le y$ 的合法条件得

- $\forall i\in [1,n],  \exists j \in [1,m],a_{i,j} \ge x$。
- $\forall j\in [1,m], \exists i \in [1,n],a_{i,j} \le y$。

对行列独立容斥，钦定突破限制的行号集合 $S \subseteq [1,n]$，列号集合 $T \subseteq [1,m]$ 使得：

- 对 $i \in S$ 满足 $\forall j \in [1,m], a_{i,j} < x$。
- 对 $j \in T$ 满足 $\forall i \in [1,n], a_{i,j}>y$。
- 对 $i \notin S \land j \notin S$ 的 $a_{i,j}$ 无限制。

容斥系数 $(-1)^{|S|} (-1)^{|T|}=(-1)^{|S|+|T|}$。对 $(i,j)$ 位置分讨：

- 若 $i \in S \land j \in T$，则 $a_{i,j} \in (y,x)$，方案数 $\max(0,x-y-1)$。
- 若 $i \in S \land j \notin T$，则 $a_{i,j} \in [1,x)$，方案数 $x-1$。
- 若 $i \notin S \land j \in T$，则 $a_{i,j} \in (y,k]$，方案数 $k-y$。
- 若 $i \notin S \land j\notin T$，则 $a_{i,j} \in [1,k]$，方案数 $k$。

特判 $x-y<1$。直接枚举 $|S|=p, |T|=q$ 得到方案数
$$
f(x,y)=\sum_{p=0}^n \sum_{q=0}^m (-1)^{p+q} \binom{n}{p} \binom{m}{q} (x-y-1)^{pq} (x-1)^{p(m-q)} (k-y)^{(n-p)q} k^{(n-p)(m-q)}
$$
复杂度 $O(nmk)$ 无法通过。根据二项式定理化简 $f$ 有
$$
\begin{aligned}
f(x,y)&=\sum_{p=0}^n (-1)^p\binom{n}{p} \sum_{q=0}^m (-1)^{q} \binom{m}{q} \left((x-y-1)^{p}\right)^{q} \left((x-1)^{p}\right)^{m-q} \left((k-y)^{n-p}\right)^q (k^{n-p})^{m-q}\\
&=\sum_{p=0}^n (-1)^p\binom{n}{p}  \sum_{q=0}^m  \binom{m}{q} \left((-1)(x-y-1)^{p} (k-y)^{n-p}\right)^q \left((x-1)^{p}k^{n-p}\right)^{m-q}\\
&=\boxed{\sum_{p=0}^n  (-1)^p\binom{n}{p} \left((x-1)^{p}k^{n-p}-(x-y-1)^{p} (k-y)^{n-p}\right)^{m}}
\end{aligned}
$$
复杂度 $O(nk \log m)$ 可以通过 [CF2048G](https://www.luogu.com.cn/problem/CF2048G)。

**观察** $f(x,y)$ 是关于 $x,y$ 的 $n\times m$ 次多项式。

求答案形如 $\sum f(t,t)$，前缀和后次数 $+1$。我们求出前 $nm+2$ 个 $f$ 后，用 Lagrange 插值线性求出 $t$ 处的点值即可。

:::::info[Lagrange 插值]

**问题** 给定 $n+1$ 个点 $(x_0,y_0) \sim (x_n,y_n)$，确定 $n$ 次多项式 $f$ 使得 $\forall i \in [0,n], f(x_i)=y_i$。

Lagrange 插值给出公式
$$
f(x)=\boxed{\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-x_j}{x_i-x_j}}
$$
将 $x$ 代入可以 $O(n^2)$ 求点值。对于多点求值问题，可以暴力多项式除法算出系数做到 $O(n^2)-O(n)$。

特别地，若横坐标满足 $x_i=i$，代入插值公式
$$
\begin{aligned}
f(x)&=\sum_{i=0}^n y_i \prod_{j \ne i} \dfrac{x-j}{i-j}\\\
&=\sum_{i=0}^n \dfrac{y_i}{x-i}\prod_{j=0}^n (x-j) \prod_{j \ne i} \dfrac{1}{i-j}\\
&=\boxed{\sum_{i=0}^n \dfrac{y_i}{x-i} \times \dfrac{(-1)^{n-i}}{i!(n-i)!}\prod_{j=0}^n (x-j)}
\end{aligned}
$$
线性预处理 $\prod\limits_{j=0}^n (x-j)$ 及 $x-i$ 的逆元和阶乘逆，可以 $O(n)$ 单点求值。注意特判 $x \in [0,n]$ 的情形。

:::::

复杂度 $O(n^2m \log m)$ 可以通过本题。[代码](https://www.luogu.com.cn/article/1gcq46ur)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB543$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-arc231e--stripe-python', 'Odd Inversion · stripe-python', $AKB544$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ARC231E](https://www.luogu.com.cn/problem/AT_arc231_e)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$，对满足下列条件的 $b_1 \sim b_n$ 计数：
>
> - $\forall i \in [1,n], 1 \le b_i \le a_i$。
> - $b$ 的逆序对数为奇数。
>
> 多测，$\sum n \le 4 \times 10^5$，$a_i \le 10^9$，2 秒，1024 MB。

:::::success[题解]

设 $\text{inv}(b)$ 为偶数的序列有 $c_0$ 个，奇数的序列为 $c_1$ 个。则总方案数
$$
c_0+c_1=\prod_{i=1}^n a_i
$$
转为求解 $c_0-c_1$ 后解方程得到答案。考虑递推：

- 设 $f_i$ 为仅考虑 $b_1 \sim b_i$ 时 $c_0-c_1$ 的值。

- 转移讨论 $b_i$ 的取值：

  - 若 $b_i=b_{i-1}$，则删去 $i-1$ 和 $i$ 后奇偶性不变，转移 $a_{i-1}f_{i-2} \to f_i$。
  - 若 $b_i \ne b_{i-1}$，对 $\max(b_{i-1},b_i) \le a_{i-1}$ 的序列，将 $i-1$ 和 $i$ 交换后奇偶性 flip 故成对抵消。只需计数 $\max(b_{i-1},b_i)>a_{i-1}$ 的部分，转移 $(a_i-a_{i-1}) f_{i-1} \to f_i$。

  将两部分合并得二阶递推
  $$
  \boxed{f_i=(a_i-a_{i-1})f_{i-1}+a_{i-1}f_{i-2}}
  $$

- 初值为 $f_0=0, f_1=a_1$。

- 答案为 $c_0+c_1=f_n$。

复杂度 $O(n)$。[代码](https://atcoder.jp/contests/arc231/submissions/79797002)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB544$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-dwacon6th-prelims-c--stripe-python', 'Cookie Distribution · stripe-python', $AKB545$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[DWACON6TH_PRELIMS_C](https://www.luogu.com.cn/problem/AT_dwacon6th_prelims_c)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$ 和长为 $k$ 的序列 $a_i$。重复 $k$ 次操作，第 $i$ 次操作任意选择 $a_i$ 个位置 $p_1 \sim p_{a_i}$，并将 $b_{p_x} \gets b_{p_x}+1$。求所有情况下 $\prod b_i$ 的总和。
>
> $n \le 10^3$，$k \le 20$，2.52 秒，1024 MB。

::::::success[题解]

形如 $\sum \prod b_i$ 的计数问题，可以考虑 [Product Trick](https://codeforces.com/blog/entry/98624)。

我们考察 $\prod b_i$ 的组合意义：有 $n$ 个盒子，第 $i$ 次操作选择 $a_i$ 盒子扔进一个颜色为 $i$ 的球，最后盒子里有 $b_i$ 个球。$\prod b_i$ 即为从每个盒子中选择一个球的方案数。

切换计数主体。设最终 $x_i$ 个盒子选择的球为颜色 $i$，必有 $\sum x_i=n$ 且 $x_i \le a_i$。下面构造 $x_1 \sim x_k$ 对应的操作方案。

- 将 $n$ 种盒子分配给 $k$ 种颜色，使得颜色 $i$ 被 $x_i$ 个位置钦定。方案数 $\dbinom{n}{x_1,x_2,\cdots,x_k}$。注意第一步的组合意义是分配盒子标号，相当于确定了这 $x_i$ 个位置的具体内容。
- 对于第 $i$ 次操作，其需要选择 $a_i$ 个盒子。
  - 必须选择 $x_i$ 个特定盒子满足第一步钦定，方案数 $1$。
  - 在剩余 $n-x_i$ 个盒子中，随意选择 $a_i-x_i$ 个位置，方案数 $\dbinom{n-x_i}{a_i-x_i}$。

由乘法原理合并得到

$$
\binom{n}{x_1,x_2,\cdots,x_k} \prod_{i=1}^k\binom{n-x_i}{a_i-x_i}=\boxed{n!\prod_{i=1}^k \dfrac{1}{x_i!} \binom{n-x_i}{a_i-x_i}}
$$

:::::success[代数推导]

下面给出这个式子的代数推导方法。

注意到 $\prod\limits_{j=1}^{n} b_j=\prod\limits_{j=1}^{n} \sum\limits_{i=1}^k A_{j,i}$，其中 $A_{j,i} \in \{0,1\}$ 表示第 $i$ 次操作是否选择 $j$，且 $\sum\limits_{j=1}^n A_{j,i}=a_i$。

对 $\prod\limits_{i=1}^{n} \sum\limits_{j=1}^k A_{j,i}$ 使用乘法分配律，设我们从第 $j$ 个括号中选择第 $c_j$ 项，则 $c_j \in [1,k]$ 且答案式变为
$$
\sum_{A}\sum_{c_1 \sim c_n} \prod_{j=1}^n A_{j,c_j}=\sum_{c_1 \sim c_n} \sum_{A }\prod_{j=1}^n A_{j,c_j}
$$
对固定的 $c_1 \sim c_n$，乘积 $\prod\limits_{j=1}^n A_{j,c_j}=1$ 的充要条件为 $\forall j \in [1,n], A_{j,c_j}=1$。记 $x_i=\sum \limits_{j=1}^n [c_j=i]$，则 $x_i$ 个位置强制 $A_{j,c_j}=1$ 且剩余位置自选，从而
$$
\sum_{A }\prod_{j=1}^n A_{j,c_j}=\prod_{i=1}^k \binom{n-x_i}{a_i-x_i}
$$
只要乘上 $c_1 \sim c_n$ 的选法数目。这是多重组合数的定义，系数为 $\dbinom{n}{x_1,x_2,\cdots,x_k}$。

:::::

这个形式是容易 DP 的：

- 设 $f_{i,j}$ 为满足如下条件时，所有 $x_1 \sim x_i$ 序列的 $\prod\limits_{k=1}^i \dfrac{1}{x_k!} \dbinom{n-x_k}{a_k-x_k}$ 之和：
  - 仅考虑 $x_1 \sim x_i$。
  - $\sum \limits_{k=1}^i x_k=j$。
- 转移枚举 $x_{i} \in [0,a_i]$，刷表 $\dfrac{1}{x_i!} \dbinom{n-x_i}{a_i-x_i} \times f_{i-1,j} \to f_{i,j+x_i}$。
- DP 初值为 $f_{0,0}=1$。
- 答案为 $n! \times f_{k,n}$。

DP 状态数 $O(nk)$，转移枚举量 $a_i \le n$，总复杂度 $O(n^2k)$ 可以通过。[代码](https://www.luogu.com.cn/article/6e101rnl)。

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB545$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-jsc2019-qual-f--stripe-python', 'Candy Retribution · stripe-python', $AKB546$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[JSC2019_QUAL_F](https://www.luogu.com.cn/problem/AT_jsc2019_qual_f)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$。对满足下列条件的长为 $n$ 的序列 $a_i$ 计数：
>
> - $\forall i \in [1,n], a_i \ge 0$。
>
> - $\sum \limits_{i=1}^n a_i \in [l,r]$。
> - 将 $a$ 降序排序后，$a_m=a_{m+1}$。
>
> $n,m,l,r \le 3 \times 10^5$，2 秒，1024 MB。

:::::success[题解]

不妨令 $a_i \gets a_i+1$ 转而计数正整数序列。令 $m \gets n-m$ 转为升序排序后 $a_m=a_{m+1}$。

先将 $[l,r]$ 差分成 $[1,r] \setminus [1,l)$，变成总和有一个上限 $r$。

做一个单步容斥，用总数减去 $a_m<a_{m+1}$ 的序列数。枚举总和 $k $ 得到总数 $\sum \limits_{k=1}^r \dbinom{k+n-1}{n-1}=\dbinom{r+n}{n}$。

枚举排序后 $a_m=x$，排列被分成两段，$1 \sim m$ 段的值域为 $[1,x]$，而 $m+1 \sim n$ 段的值域为 $(x,n]$。

再来一次单步容斥：钦定 $1 \sim m$ 段的值域为 $[1,x]$，然后减掉钦定为 $[1,x-1]$ 的方案数，则 $a_m=x$ 的限制可以丢掉。

问题转化为，计数恰有 $m$ 个数 $\le a$，$n-m$ 个数 $\ge b$，总和不超过 $r$ 的序列。这个可以容斥也可以 GF 启动，下面是熔池观点。

**钦定至少** $i$ 个位置 $>a$，由二项式反演，容斥系数 $(-1)^i \dbinom{m}{i}$。

令钦定的 $i$ 个位置减去 $a$，选定的 $\ge b$ 的位置减去 $b$，总和为 $r'=r-m-i \times a-(n-m)b$。剩余选法为 $\dbinom{r'+n}{n}$。

答案即为
$$
f(a,b)=\binom{n}{m}\sum_{i=0}^{m} (-1)^i \binom{m}{i} \binom{r'+n}{n}
$$
其中 $r' \ge 0 \implies i \le \dfrac{*}{a}$，$*$ 是 $O(n)$ 级别的常数。

在外层循环枚举 $x$ 得到 $a,b$，内层循环枚举 $i$，根据 $i$ 的合法条件可知，这属于调和型枚举，复杂度是 $O(n \log n)$ 可以通过。[代码](https://www.luogu.com.cn/article/uwatuto9)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB546$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-atcoder-mujin-pc-2018-f--stripe-python', 'チーム分け · stripe-python', $AKB547$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[MUJIN_PC_2018_F](https://www.luogu.com.cn/problem/AT_mujin_pc_2018_f)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个元素，你需要将每个元素分到某组中，要求 $i$ 所在组的大小不超过 $a_i$。求合法分组方案数。
>
> $n \le 10^3$，2 秒，1024 MB。

::::::success[题解]

单组限制只关心 $a_i$ 最小的元素。对 $a_i$ 降序排序，考虑按下标逐个加入并计算贡献。

在加入 $i$ 时，如果不记录当前的分组情况，贡献系数难以计算。为此，我们将不决策也作为一种转移，考虑下面的 DP 状态：

- 设 $f_{i,j}$ 为满足下列条件的合法分组方案数。
  - 仅考虑 $1 \sim i$，但不需决定 $1 \sim i$ 的全部归属。
  - $1 \sim i$ 中恰有 $j$ 个元素无归属。
- 转移时仅有两种决策：
  - 第 $i$ 个元素无归属，转移 $f_{i,j} \to f_{i+1,j+1}$。
  - 第 $i$ 个元素新开一组，并从 $j$ 个未决策元素中取出若干加入这一组。枚举 $k \in [0,a_i)$，转移 $f_{i,j} \times \binom{j}{k} \to f_{i+1,j-k} $。
- DP 初值为 $f_{0,0}=1$。
- 答案为 $f_{n,0}$。

复杂度 $O(n^3)$，可以通过原题。

:::::info[延迟钦定 DP]

本题通过**延迟钦定**的组合意义，解决了贡献系数无法计算的问题。我们将本题的模型进行抽象：

- 对每个组合对象决策某种属性。
- 将决策划分为两部分，确定部分不会影响贡献系数，待定部分还会影响贡献系数。待定到确定的转化是单向的。
- 确定部分等价，待定部分的决策等价。
- 考虑在 DP 状态中记录待定部分的信息，每个对象的决策变为，进入待定部分或进行确定性决策。在确定性决策时，处理待定部分的贡献。

:::::

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB547$, '数学', array['题解'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-cf-1126c', 'XOR Problem', $AKB548$## 题目描述

Codeforces Round 1126 (Div. 1 + Div. 2) 的 C 题。

给定一个整数 $n$。定义数组 $a$ 的「美丽度」为 $|a|-f(a)$，其中 $|a|$ 是数组长度，$f(a)$ 是异或为 $0$ 的非空子数组数量。形式化地说，$f(a)$ 是满足 $1\le l\le r\le |a|$ 且 $a_l\oplus a_{l+1}\oplus\cdots\oplus a_r=0$ 的二元组 $(l,r)$ 的数量。

在所有元素均为 $0$ 到 $n$ 之间的整数、且美丽度最大的数组中，找出长度最大的一个并输出。

### 输入格式

第一行一个整数 $t$，表示测试用例数量。接下来每个测试用例一行，包含一个整数 $n$。

### 输出格式

对于每个测试用例，先输出一行一个整数 $k$——数组长度；再输出一行 $k$ 个整数 $a_1,a_2,\dots,a_k$（$0\le a_i\le n$）。若存在多个合适的数组，输出任意一个。

### 数据范围

- $1\le t\le 10^4$
- $1\le n\le 2\times 10^5$，且所有测试用例的 $n$ 之和不超过 $2\times 10^5$
- 保证所有测试用例输出的 $k$ 之和不超过 $10^6$

---

## 样例

### 样例 1

**输入：**

```
2
1
2
```

**输出（本代码实现实测）：**

```
3
1 0 1
7
1 2 1 0 1 2 1
```

**解释：** 本题允许输出任意合法数组，官方样例给出的输出是 `3 / 1 1 1` 与 `7 / 2 2 1 0 2 0 1`，与上面不同但同样合法。

- $n=1$ 时本代码输出 $a=[1,0,1]$：异或为 $0$ 的子数组只有 $(l,r)=(1,3)$ 和 $(2,2)$ 两个，美丽度 $3-2=1$，达到最大值。
- $n=2$ 时输出 $a=[1,2,1,0,1,2,1]$：前缀异或依次为 $0,1,3,2,2,3,1,0$，值 $0,1,2,3$ 各出现两次，异或为 $0$ 的子数组共 $4$ 个，美丽度 $7-4=3$，达到最大值。

---

## 解题思路

看到「子数组异或为 $0$」，第一反应是转前缀异或。设前缀异或 $p_0=0$，$p_i=a_1\oplus\cdots\oplus a_i$，则

$$
a_l\oplus\cdots\oplus a_r=0 \iff p_{l-1}=p_r
$$

于是异或为 $0$ 的子数组数量完全由前缀异或序列中每个值的出现次数决定：若某个值出现 $c$ 次，它贡献 $\binom{c}{2}$ 个子数组。

再观察逐个添加元素时美丽度怎么变：新加一个元素使新前缀值为 $x$，而 $x$ 之前已出现 $c$ 次。长度加 $1$，异或为 $0$ 的子数组数增加 $c$，美丽度变化为 $1-c$：

- $c=0$：美丽度 $+1$；
- $c=1$：美丽度不变，但长度增加；
- $c\ge 2$：美丽度下降。

因此最优策略是：**每个前缀异或值最多出现两次**——第一次出现赚 $1$ 点美丽度，第二次出现拉长长度，第三次开始亏损。

接下来确定可用前缀值的范围。元素都在 $0$ 到 $n$ 之间，设 $M$ 为大于 $n$ 的最小 $2$ 的幂（即 $2^{m+1}$，其中 $2^m\le n<M$）。所有元素都小于 $M$，异或不会产生更高位，所以所有前缀异或只能落在 $0,1,\dots,M-1$ 这 $M$ 个值里。每个值最多贡献 $1$ 点美丽度，故美丽度上界为 $M-1$；要让长度最大，应让每个值都出现两次：前缀序列共 $2M$ 个数（含 $p_0=0$），数组长度为 $2M-1$。

剩下唯一的问题：能不能让这 $M$ 个值各出现两次，同时保证相邻前缀异或（即数组元素）不超过 $n$？容易先想到按 $0,1,2,\dots,M-1$ 正序再倒序写回，但从 $M-1$ 跳回 $0$ 时相邻异或是 $M-1$，可能大于 $n$，非法。于是改用格雷码：标准格雷码 $g(i)=i\oplus(i\gg 1)$ 相邻两项只差一个二进制位，相邻异或是 $2$ 的幂。对 $0$ 到 $M-1$ 的格雷码，相邻异或最大为 $M/2=2^m\le n$，全部合法。

### 关键洞察

美丽度每步只增 $1-c$，所以「上界」来自**可用前缀值的个数**（$M$ 个），「最长长度」来自**每个值恰好出现两次**；格雷码恰好同时满足「每个值经过一次、相邻异或不超过 $n$」两个构造需求。

### 为什么这样是对的

- **合法性**：正序格雷码相邻异或最大 $M/2=2^m\le n$，倒序同理；正序末项与倒序首项相同，拼接处异或为 $0$，同样合法。所以所有数组元素都在 $0$ 到 $n$ 之间。
- **最优性（美丽度）**：任何数组的前缀值都落在 $M$ 个值之内，每个值最多贡献 $1$ 点美丽度，故美丽度 $\le M-1$；本构造中每个值恰好出现两次，$\binom{2}{2}=1$，总贡献恰为 $M$，美丽度 $(2M-1)-M=M-1$，达到上界。
- **最长性**：达到上界时每个值最多出现两次，全部出现两次时前缀长度 $2M$、数组长度 $2M-1$，不能再长。

---

## 逐行代码解析

### 读入与求 s

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
	ios::sync_with_stdio(false);
	cin.tie(nullptr); cout.tie(nullptr);
	int t;
	cin >> t;
	while (t--)
	{
		int n;
		cin >> n;
		int s = 1;
		while (s <= n) s <<= 1;
		
```

- `while (s <= n) s <<= 1;`：求**大于 $n$ 的最小 $2$ 的幂** $s$（思路里的 $M$）。是 `s <= n` 才左移，保证 $s>n$ 且 $s\le 2n$。

### 求长度并构造前缀序列 p

```cpp
int len = 2 * s - 1;
		vector<int> p(2 * s);
		for (int i = 0; i < s; i++) p[i] = i ^ (i >> 1);
		for (int i = 0; i < s; ++i) p[s + i] = p[s - 1 - i];
		
```

- `len = 2*s - 1`：前缀序列共 $2s$ 个数（每个值出现两次），数组元素是相邻异或，共 $2s-1$ 个。
- `p[i] = i ^ (i >> 1)`：生成 $0\sim s-1$ 的标准格雷码。
- `p[s+i] = p[s-1-i]`：把格雷码**倒序接在后面**，构成 $g_0,\dots,g_{s-1},g_{s-1},\dots,g_0$，每个值恰好出现两次；拼接处 $p[s-1]=p[s]$，异或为 $0$，合法。

### 输出答案

```cpp
cout << len << '\n';
		for (int i = 1; i < 2 * s; ++i) cout << (p[i - 1] ^ p[i]) << ' ';
		cout << '\n';
	}
	return 0;
}
```

- 第 $i$ 个元素 = 相邻前缀异或 $a_i = p_{i-1} \oplus p_i$，由格雷码性质保证落在 $[0,n]$。

## 复杂度分析

- **时间复杂度**：每个测试用例求 $s$ 只需 $O(\log n)$ 次循环，生成前缀与输出各 $O(s)$，而 $s$ 是大于 $n$ 的最小 $2$ 的幂、满足 $s\le 2n$，故单组 $O(n)$；全部测试用例合计 $O(\sum n)$。
- **空间复杂度**：前缀数组 $p$ 大小 $2s\le 4n$，即 $O(n)$。

---

## 常见陷阱与注意事项

1. **$M$ 的取值方向**：必须取「大于 $n$ 的最小 $2$ 的幂」。若取「不超过 $n$ 的最大 $2$ 的幂」，可用前缀值少一半，美丽度上界算错，构造出来的数组达不到最优。
2. **长度是 $2M-1$ 不是 $2M$**：前缀序列（含 $p_0=0$）有 $2M$ 个数，数组元素是相邻异或，只有 $2M-1$ 个；多输出一个会违反「每个值至多出现两次」的最优结构。
3. **输出的是相邻前缀异或，不是格雷码本身**：$p$ 只是中间量，如果直接把 $p$ 当数组输出，元素可能超过 $n$（如 $g_{M-1}=M-1>n$ 的情况），且异或为 $0$ 的子数组计数完全不对。
4. **倒序拼接的位置**：倒序必须从 $g_{M-1}$ 开始写（代码里 `p[s+i] = p[s-1-i]`，$i=0$ 时就是 $g_{s-1}$），既保证拼接处异或为 $0$，也保证每个值恰好出现两次；从 $g_{M-2}$ 开始写会漏掉一次出现，破坏结构。
5. **元素允许为 $0$**：题面明确 $0\le a_i\le n$，判断合法性时不要把 $0$ 当成非法元素而误改构造。
6. **输出量大，需要快速 IO**：$t$ 可达 $10^4$、$\sum k$ 可达 $10^6$，用 `ios::sync_with_stdio(false)` 与 `cin.tie(nullptr)`，否则可能超时。
7. **多测无需清空**：本代码每组的 $p$ 都是局部重新分配的 `vector`，不存在残留；若改写为全局数组要注意每组重置长度。

---

## 对比与扩展

- **「子数组异或为 $0$」套路**：一律先转前缀异或、再看每个值出现次数，美丽度这类目标就变成「出现次数」的优化问题。本专辑中《异或方程》《XOR排序》同样是前缀异或思想的变形。
- **格雷码构造**：格雷码相邻项只差一个二进制位，因此「相邻异或必须不超过某上界」的构造可以直接套用二进制反射格雷码。本专辑中《格雷码》（P5657，CSP-S 2019）是格雷码的生成式考察，可互相印证。
- **构造型问题的通用流程**：先证上界（这里用「每个前缀值最多贡献 $1$ 点美丽度」得出 $M-1$），再构造达到上界的方案，最后证明构造合法；先想「每个值最多出现两次」这类全局约束，往往比直接拼数组简单。$AKB548$, '数学', array['前缀异或', '格雷码', '构造', '异或'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1342e--stripe-python', 'Placing Rooks · stripe-python', $AKB549$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1342E](https://www.luogu.com.cn/problem/CF1342E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$。你需要在 $n \times n$ 的棋盘上放置 $n$ 个车，满足：
>
> - 所有空格子都能被至少一个车攻击。
> - 恰好有 $k$ 对车可以互相攻击。
>
> 求合法方案数。
>
> $n \le 2 \times 10^5$，$k \le \binom{n}{2}$，2 秒，500 MB。

:::::success[题解]

注意到行列的地位相同，下文只对行的形态讨论，由对称性答案 $\times 2$ 即可。

**性质** 满足空格子都能被攻击，则每行恰有一个车。

**证明** 反证法显然。

进一步，恰有 $k$ 对车互相攻击，当且仅当 $n$ 个车恰好占据 $n-k$ 个不同列。可以从 $k=0$ 开始归纳证明。

只要从 $n$ 个列中选出 $k$ 个，并将 $n$ 个有标号球放入 $n-k$ 个有标号盒子。答案为
$$
\boxed{\binom{n}{k} {n\brace n-k} (n-k)!}
$$
若 $k>n$ 无解。注意特判 $k=0$ 的情形，答案为 $n!$。

使用第二类斯特林数的通项公式，复杂度 $O(n \log n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB549$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1485f--stripe-python', 'Copy or Prefix Sum · stripe-python', $AKB550$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1485F](https://www.luogu.com.cn/problem/CF1485F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $b_i$。计数序列 $a_1 \sim a_n$ 满足：
>
> - $\forall i \in [1,n], b_i=a_i$ 或 $b_i=\sum \limits_{k=1}^i a_k$。
>
> 多测，$\sum n \le 2 \times 10^5$，$|b_i| \le 10^9$，2 秒，250 MB。

:::::success[题解]

容易列得朴素 DP：

- 设 $f_{i,j}$ 为满足下列条件的方案数：

  - 仅考虑 $a_1 \sim a_i$。
  - $\sum \limits_{k=1}^i a_k=j$。

- 转移枚举 $a_{i+1}$ 的取值。

  - 取 $b_{i+1}=a_{i+1}$，转移 $f_{i,j} \to f_{i+1,j+b_{i+1}}$。
  - 取 $b_{i+1}=\sum \limits_{k=1}^{i+1} a_k$，转移 $f_{i,j} \to f_{i+1,b_{i+1}}$。

  注意特判转移重叠的情形。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $\sum \limits_{j} f_{n,j}$。

对 $f$ 滚动数组，考察上述转移：

- $f_{j} \to f'_{j+b_{i+1}}$ 是全局平移。
- $f_j\to f'_{b_{i+1}}$ 是总和对单点加法。

用哈希表维护 $f$ 数组，记录偏移量与 $\sum f$ 即可。复杂度 $O(n \log n)$。[代码](https://www.luogu.com.cn/article/juk9r4qy)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB550$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1620g--stripe-python', 'Subsequences Galore · stripe-python', $AKB551$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1620G](https://www.luogu.com.cn/problem/CF1620G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个字符串 $A_i$，保证字符集为 $\tt{a \sim z}$，且 $A_i$ 内部每个字符按照字符集顺序升序排列。
>
> 对 $S \subseteq \{1,2,\cdots,n\}$，记 $f(S)$ 为 $\exists x \in S, B$ 是 $A_x$ 的子序列的本质不同字符串 $B$ 的数目。对每个 $S$ 求出 $f(S)$。
>
> $n \le 23$，$|A_i | \le 2 \times 10^4$，10 秒，1000 MB。

:::::success[题解]

设 $g(S)$ 为 $\forall x \in S,B$ 是 $A_x$ 的子序列的本质不同字符串 $B$ 的数目。$g$ 的组合意义是钦定至少。

考察 $g$ 的计算方法。由于每个字符串形如 $\tt{aa\cdots abb \cdots b\cdots zz \cdots z}$，设 $\text{cnt}(S,c)$ 为字符串 $S$ 中字符 $c$ 的出现次数，则 $B$ 是 $A_i$ 子序列的充要条件是 $\forall c\in \Sigma, \text{cnt}(B,c) \le \text{cnt}(A_i,c)$。 从而 $g$ 由乘法原理合并得
$$
g(S)=\prod_{c\in \Sigma} \left(1+\min_{i \in S} \text{cnt}(A_i,c)\right)
$$
朴素计算 $g$ 是 $O(|\Sigma| n2^n)$ 的。设
$$
\begin{aligned}
g_c(S)&=1+\min_{i \in S} \text{cnt}(A_i,c)\\
g(S)&=\prod_{c \in \Sigma} g_c(S)
\end{aligned}
$$
此时 $g_c$ 可以通过排除特殊元素的方法进行转移
$$
g_c(S)=\min(g_c(S \setminus \{x\}), 1+\text{cnt}(A_x,c)), x =\min S
$$
边界 $g_c(\varnothing)=+\infty$，优化到 $O(|\Sigma| 2^n)$。

$g \to f$ 的转化只要枚举 $T \subseteq S$，容斥系数 $(-1)^{|T|-1}$。形式化地
$$
f(S)=\sum_{T \subseteq S} (-1)^{|T|-1} g(T)
$$

记 $g_0(T)=(-1)^{|T|-1} g(T)$，对 $G_0$ 做一个高维前缀和得到 $F$ 即可。

复杂度 $O(nL+|\Sigma| 2^n+n2^n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB551$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-1942g--stripe-python', 'Bessie and Cards · stripe-python', $AKB552$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF1942G](https://www.luogu.com.cn/problem/CF1942G)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $a$ 张 $0$ 卡，$b$ 张 $1$ 卡，$c$ 张 $2$ 卡和 $5$ 张特殊卡。
>
> 抽牌开始时，从牌顶抽取前 $5$ 张牌，可以丢弃 $k$ 卡抽取接下来 $k$ 张牌。若抽到全部 $5$ 张特殊卡则获胜。
>
> 所有卡互不相同，$(a+b+c+5)!$ 种牌堆等可能出现，求获胜概率。
>
> 多测，$\sum a,\sum b,\sum c \le 2\times 10^5$，2 秒，250 MB。

:::::success[题解]

抽到 $1$ 卡以后立刻丢掉抽下一张，那么 $1$ 卡的作用可以忽略。$0$ 卡和特殊卡都视作 $-1$，$2$ 卡视作 $+1$，则前缀和到达 $-5$ 的时刻停止抽卡，获胜条件取决于这时候是否集齐特殊卡。

可以用格路计数转化条件，抽到 $-1$ 令 $y \gets y+1$，抽到 $+1$ 令 $x \gets x+1$，则牌堆可以刻画为 $(5,0)$ 出发的格路，触碰 $y=x$ 则停止游走。

枚举触碰点为坐标 $k \ge 5$，只要计数 $(5,0) \to (k,k-1)$ 的不越过 $y=x$ 的格路。将终点关于 $y=x+1$ 对称，由单线反射容斥得
$$
\binom{2k-6}{k-1}-\binom{2k-6}{k}
$$
限制为前 $2k$ 张牌必须集齐 $5$ 张特殊卡，方案数 $\binom{2k}{5}$。剩余 $a-(k-5)$ 个 $-1$ 卡和 $c-(k-5)$ 个 $+1$ 卡随意排列，方案数 $\binom{a+c-2k+10}{a-k+5}$。

故合法方案数为
$$
\boxed{\sum_{k=5}^n \binom{k}{5}\binom{a+c-2k+10}{c-k}\left(\binom{2k-6}{k-1}-\binom{2k-6}{k}\right)}
$$
注意加上始终不碰到 $y=x$ 的方案数，计算方法和上面类似，这里不赘述。

除以总数 $\binom{a+c+5}{a,c,5}$ 得到答案。复杂度 $O(n)$。[代码](https://codeforces.com/problemset/submission/1942/392128555)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB552$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-626f--stripe-python', 'Group Projects · stripe-python', $AKB553$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF626F](https://www.luogu.com.cn/problem/CF626F)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$。你需要将 $n$ 个有标号元素划分为若干无标号组。组内权值定义为 $\max-\min$，要求总权值 $\le k$。求方案数。
>
> $n \le 200$，$k \le 10^3$，$1 \le a_i \le 500$，2 秒，250 MB。

:::::success[题解]

将 $a_i$ 升序排序后逐个加点。可以列得延迟钦定 DP：

- 设 $f_{i,x,S}$ 为满足下列条件的合法方案数：
  - 仅考虑 $a_1 \sim a_i$。
  - 现有 $x$ 个未确定 $\max$ 的组。
  - 当前可确定的权值和为 $S$。即确定部分权值和，加上待定部分 $-\min$ 的和。
- 转移 $f_{i-1,x,S} \to f_{i,x',S'}$，讨论 $a_i$ 的归属：
  - 钦定为某个待定组的 $\max$，移除待定部分，转移 $x \times f_{i-1,x,S} \to f_{i,x-1,S+a_i}$。
  - 加入某个待定组，转移 $x \times f_{i-1,x,S} \to f_{i,x,S}$。
  - 新开一个确定组，转移 $f_{i-1,x,S} \to f_{i,x,S}$。
  - 新开一个待定组，转移 $f_{i-1,x,S} \to f_{i,x+1,S-a_i}$。
- DP 初值为 $f_{0,0,0}=1$。
- 答案为 $\sum \limits_{S=0}^k f_{n,0,S}$。

第三维 $S \in [-nV, k]$，故复杂度 $O(n^3 V)$ 无法通过。

考虑**微元贡献法** $a_r-a_l=\sum\limits_{i=l+1}^r (a_i-a_{i-1})$，令 $i$ 决策后立刻计算微元 $a_i-a_{i-1}$ 的贡献。

令 $S'=S+x(a_i-a_{i-1})$，再转移到 $f_{i,x',S'}$ 只需保留 $S' \ge 0$ 的部分即可。

复杂度 $O(n^2 k)$ 足以通过。[代码](https://codeforces.com/contest/626/submission/393052506)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB553$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-930e--stripe-python', 'Coins Exhibition · stripe-python', $AKB554$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF930E](https://www.luogu.com.cn/problem/CF930E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有长为 $k$ 的 01 串 $a_1 \sim a_k$。给定 $n$ 条限制，形如：
>
> - $a_l \sim a_r$ 中至少有一个 $0$。
> - $a_l \sim a_r$ 中至少有一个 $1$。
>
> 求合法的 $a$ 的数目。
>
> $k \le 10^9$，$n \le 2\times 10^5$，2 秒，256 MB。

:::::success[解法一]

将 $n$ 条限制的端点离散化形成 $m$ 段，以新段为主体 DP：

- 设 $f_{0/1,i,j}$ 为满足下列要求的合法方案数：

  - 已确定第 $1 \sim i$ 段填入的数。
  - 第 $i$ 段的末尾数字填 $0/1$。
  - 与 $x_i$ 最近的异色点位于第 $j$ 段之中。

- 转移考虑填入 $x_i+1 \sim x_{i+1}$，分讨填数方案：

  - 全填 $0$，转移 $f_{0,i,j} \to f_{0,i+1,j}$ 和 $f_{1,i,j} \to f_{0,i+1,i}$。
  - 全填 $1$，转移 $f_{1,i,j} \to f_{1,i+1,j}$ 和 $f_{0,i,j} \to f_{1,i+1,i}$。
  - $0/1$ 均有，设第 $i$ 段长为 $m$，则需要确定 $m-1$ 个数并减掉全部同色，贡献系数 $2^{m-1}-1$，转移 $(2^{m-1}-1) \times f_{0/1,i,j} \to f_{0/1,i+1,i+1}$。

  我们需要排除不合法的转移。例如限制是 $\exists i \in [l,r], a_i=0$，否定掉 $\forall i \in [l,r],a_i=1$ 即 $f_{1,r,1 \sim l-1}$ 对应的方案。将 $l-1$ 也丢进去离散化，然后前缀清零即可。

- DP 初值为 $f_{0/1,0,0}=1$。

- 答案为 $\dfrac{1}{2}\sum \limits_{j} f_{0/1,m,j} $，除二是因为多算了 $a_0$ 的贡献。

复杂度是 $O(n^2)$ 的。我们将 $i$ 维度滚动数组，观察转移为：

- $f_{0/1,j} \to f_{0/1,j}$ 相当于直接复制，可以忽略。
- $f_{1/0,j} \to f_{0/1,i}$ 是将 $\sum \limits_{j} f_{1/0,j}$ 贡献到每个 $f_{0/1,i}$，用两个变量 $s_{0/1}$ 维护对 $j$ 维度求和的结果。
- $(2^{m-1}-1) \times f_{0/1,j} \to f_{0/1,i+1}$ 同样只需维护出 $\sum \limits_{j} f_{0/1,j}$ 即可转移。
- $f_{0/1,1 \sim l-1} \gets 0$ 是前缀清空，而 $l-1$ 的值单调，用一个指针记录全零前缀的结尾位置。维护 $s_{0/1}$ 是容易的。

复杂度 $O(n \log n)$，瓶颈在离散化。

:::::

:::::success[解法二]

考虑容斥。约定限制为二元组 $(v_i,S_i)$，其中 $S_i=[l_i,r_i]$ 表示这段区间存在 $v_i$。所有限制构成全集 $U$。

枚举子集 $T \subseteq U$，钦定 $T$ 中的限制被突破，容斥系数 $(-1)^{|T|}$。组合意义是某些区间为全 $0/1$，那么异色线段不能有交，形式化地 $\forall i,j \in T \land v_i \ne v_j, S_i \cap S_j=\varnothing$。

设线段并构成点集 $A=\bigcup \limits_{i \in T} S_i$。对位置 $i$ 若 $i \in A$ 则 $i$ 被限制，贡献为 $1$，否则贡献为 $2$。方案数 $2^{k-|A|}$。于是答案式
$$
\sum_{T \subseteq S} (-1)^{|T|} 2^{k-|A|}=2^k \sum_{T \subseteq S} (-1)^{|T|} \left(2^{-1}\right)^{|A|}
$$
将 $S_i$ 按照左端点排序，扔掉包含关系的同色区间。考虑带着容斥系数，以限制为主体 DP：

- 设 $f_i$ 为钦定 $i \in T$ 时 $(-1)^{|T|} \left(2^{-1}\right)^{|A|}$ 的和。
- 枚举上一个被钦定的限制 $j<i$，令 $f_j$ 贡献到 $f_i$。对 $S_i$ 和 $S_j$ 分讨：
  - 若 $S_i \cap S_j=\varnothing$，容斥系数 $-1$，贡献系数 $(2^{-1})^{|S_i|}$，则 $-(2^{-1})^{|S_i|}f_j \to f_i$。
  - 若 $S_i \cap S_j\ne \varnothing$，要求 $v_i \ne v_j$。取差集 $S'=\{i \mid i \in S_i \land i \notin S_j\}$，容斥系数 $-1$，贡献系数 $(2^{-1})^{|S'|}$，则 $-(2^{-1})^{r_i-r_j} f_j \to f_i$。
- DP 初值为 $f_i=-(2^{-1})^{|S_i|}$。
- 答案为 $2^k\left(1+\sum \limits_{i=1}^n f_i\right)$。$+1$ 是 $T=\varnothing$ 的贡献。

注意到 $S_i \cap S_j=\varnothing$ 的 $j$ 是一段前缀，二分出 $j$ 的分界点，对 $f$ 施前缀和优化即可。复杂度 $O(n \log n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB554$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-cf-938e--stripe-python', 'Max History · stripe-python', $AKB555$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[CF938E](https://www.luogu.com.cn/problem/CF938E)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的序列 $a_i$。定义序列 $a$ 的权值为，取出 $a_i$ 的所有前缀 $\max$ 为 $b_1 \sim b_k$，求和 $\sum \limits_{i=1}^{k-1} b_i$。
>
> 求 $a$ 的所有 $n!$ 种重排的权值之和。
>
> $n \le 10^6$，3 秒，250 MB。

:::::success[题解]

不妨计数所有重排的前缀 $\max$ 总和，将答案减去 $n! \times \max \limits_{i=1}^n a_i$。

将贡献拆到每个 $a_i$ 上。设 $\ge a_i$ 的数有 $k$ 个，则 $a_i$ 成为前缀 $\max$ 当且仅当 $a_i$ 是这 $k$ 个数中位置最靠前的。

事件发生的概率恰为 $\frac{1}{k}$，且所有事件独立，可得贡献 $n! \times \frac{1}{k} \times a_i$，排序后直接统计即可。

复杂度 $O(n \log n)$。[代码](https://www.luogu.com.cn/article/4m3uvjaw)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB555$, '数学', array['题解'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-cf-diss-quack-array-game', 'diss_quack and Array Game — 01博弈·进位悬崖·批量折半优化', $AKB556$## 题目描述

给定一个长度为 $n$ 的正整数数组 $a$。Alice 和 Bob 用这个数组做游戏。

**游戏开始前**，Alice 可以给任意元素加 1，每次加 1 消耗一步操作。加的次数不限。

**游戏开始后**，Bob 和 Alice 轮流操作，Bob 先手：

- **Bob 的回合**：选任意两个下标 $i, j$ 交换 $a_i$ 和 $a_j$（可以 $i = j$，即不动）
- **Alice 的回合**：若 $a_1$ 是偶数，她找到最大的 $j \le |a|$ 使得 $a_i$ 对所有 $i \le j$ 都是偶数，然后对所有 $i \le j$ 执行 $a_i := a_i / 2$；否则她执行 $a_1 := a_1 - 1$。如果任何元素变为 0，它自动从数组中删除。

游戏在数组为空时结束。Alice 想最小化她的总操作数（初始加 1 的次数 + 游戏中她的回合数），Bob 想最大化。双方最优博弈下 Alice 的操作数是多少？

### 题意统一表述

将游戏重新表述为更清晰的形式：

- **Alice 阶段**：可以给任意 $a_i$ 加 1，每加 1 花费 1 步，次数不限。目标是最小化总花费。
- **Bob 阶段**：每一轮规则是**强制的**——只要当前还有偶数，这一轮就把**所有偶数同时折半**（奇数原地不动）；只有当剩下的数全是奇数时，这一轮才选一个数减 1。打到 0 的数退场。目标是全部变 0。

**关键体会**：Bob 的流程几乎没有自由度——轮数由"垫完之后的数组"**唯一决定**。所以整个问题变成 Alice 如何垫数，让"花费 + 轮数"最小。

## 输入格式

- 第一行：$t$（$1 \le t \le 10^4$）— 测试组数
- 每组：
  - 第一行：$n$（$1 \le n \le 10^5$）— 数组长度
  - 第二行：$a_1, a_2, \ldots, a_n$（$1 \le a_i \le 10^5$）

保证所有测试组的 $n$ 之和不超过 $10^5$。

## 输出格式

每组输出一个整数——Alice 在双方最优博弈下的操作数。

## 数据范围

- $1 \le t \le 10^4$
- $1 \le n \le 10^5$

## 样例

### 样例验证

以下用思路文档中的手算案例验证算法正确性：

| 输入 | 输出 | 验证过程 |
|------|------|---------|
| `{3, 4}` | 5 | 最优在 $L=2$：垫 $3 \to 4$（付 1），前 2 轮共同折半 $(4,4) \to (2,2) \to (1,1)$，之后各减 1 消场。总 $= 2 + (1 + g[1]) + (0 + g[1]) = 2 + 2 + 1 = 5$ |
| `{15}` | 6 | $L=1$：付 1 垫到 16，$1 + 1 + g[8] = 6$（$L=2,3,4$ 都是 6，形成平台） |
| `{1, 1}` | 2 | 全是奇数，批量无用，$L=0$：$1 + 1 = 2$ |
| `{5, 5}` | 8 | $g[5] + g[5] = 4 + 4 = 8$；垫到 $(6,6)$ 反而 $2 + 7 = 9$ 更差 |

## 解题思路

### 一、单个数要打多少轮：g 表

只有一个数 $x$ 时，它的操作序列是固定的：奇数只能减 1，偶数折半。定义：

$$g[0] = 0, \quad g[x] = \begin{cases} g[x-1] + 1, & x \text{ 为奇} \\ g[x/2] + 1, & x \text{ 为偶} \end{cases}$$

闭式：

$$g(x) = \lfloor \log_2 x \rfloor + \text{popcount}(x)$$

直观理解：二进制里每个 1 都要付一次"减 1"（popcount 次），每降一个二进制位付一次"折半"（最高位位置 $= \lfloor \log_2 \rfloor$ 次）。

| $x$ | 1 | 2 | 3 | 4 | 5 | 7 | 8 | 12 | 15 | 16 |
|-----|---|---|---|---|---|---|---|----|----|----|
| $g$ | 1 | 2 | 3 | 3 | 4 | 5 | 4 | 5  | 7  | 5  |

两个直接推论：

1. $a_i \le 10^5 < 2^{17}$，所以 $g \le 16 + 17 = 33$。这是后面一切剪枝的**锚点**。
2. 打表范围开 $2^{18}$：查询下标是"垫完再移位"的值，上界 $10^5 + 2^{17}$ 移位后不超过 $2^{17}$，开 $2^{18}$ 富余。

### 二、保底方案（L = 0）

什么都不垫，各打各的：

$$\text{ans}_0 = \sum_{i} g(a_i)$$

这是全局保底，也是后面论证"超过 34 必弃"的参照物。

### 三、批量折半：把 L 轮"团购"出来

规则里最值钱的一条：一轮能**同时折半所有偶数**。要想连续 $L$ 轮都享受这个团购，必须保证这 $L$ 轮里不出现奇数 $\Leftrightarrow$ Alice 把每个数都垫成 $2^L$ 的倍数。

**结构定理**（整题的骨架）：

设 Alice 垫完得到 $a_i'$，前 $Q$ 轮是"全员共同折半"（第 $Q+1$ 轮起出现奇数），则：

1. 前 $Q$ 轮全员都是偶数 $\Leftrightarrow$ 所有 $a_i'$ 都是 $2^Q$ 的倍数
2. $Q$ 轮之后进入"逐个结算"：全奇 $\to$ 减 1 某个数 $\to$ 它变偶 $\to$ 下一轮只折它一个……每一轮至多只有一个数在动，且每个数的个人操作序列和它单独打时一模一样
3. 总轮数 $= Q + \sum_i g(a_i' \gg Q)$，与结算顺序**无关**

第 3 点成立的原因：逐个结算阶段每轮服务的恰好是一个数的"个人脚本"里的一步，脚本是确定的（奇减偶半），没人能插队共享，所以轮数就是各人脚本长度之和。

于是答案结构定型：

$$\text{ans} = \min_{L} \left[ L + \sum_i \left( \underbrace{c_i^1}_{\text{垫付}} + \underbrace{g\!\left((a_i + c_i^1) \gg L\right)}_{\text{单打}} \right) \right]$$

三个细节：

- $L$ 只加一次（记为 $c^2 = L$），因为它是全员共享的团购轮，这是批量唯一的收益来源
- 若垫到 $2^L$ 倍数后有的数折半仍是偶数，共同折分会自动延长——那笔账恰好等于更高一档 $L'$ 以相同垫付算出的值，被外层枚举覆盖
- $L$ 的枚举范围 $0 \sim 17$：$2^{17} > 10^5$，再高的档垫付就要超过 $2^{17} - 10^5 \gg 33$，必被 $L=0$ 支配

### 四、固定 L 后，每个数是一本独立小账

选定 $L$ 后，数与数之间不再互相影响，每个数独立选垫付终点：

- $c^1$：垫到某个 $2^L$ 的倍数（最近的是 $(k - a_i \bmod k) \bmod k$，$k = 2^L$）
- 折半后剩 $(a_i + c^1) \gg L$，单打花 $g$
- 本数小账 $= c^1 + g(\cdot)$，全局求和后 $+ L$

注意终点不必是最近倍数——这就引出第五节。

### 五、垫到最近倍数就够了吗？不——进位悬崖

把 $g$ 拆成两项看涨价逻辑：

- $\lfloor \log_2 \rfloor$：数值翻倍才 +1，慢涨
- popcount：遇到连续进位一次跌掉"末尾连续 1 的个数"，**骤跌**

所以"多垫几块钱"反而更便宜的场景真实存在：

| 数 | 二进制 | $g$ | 说明 |
|----|--------|-----|------|
| 15 | 01111 | 7 | — |
| 16 | 10000 | 5 | 付 1 省 2 ✓ |
| 62 | 111110 | 10 | — |
| 64 | 1000000 | 7 | 付 2 省 3 ✓ |

悬崖的本质：形如 $\ldots x\,0\,\underbrace{11\ldots1}_{k} \to \ldots x\,1\,\underbrace{00\ldots0}_{k}$ 的进位，把末尾一串 1 收拢成一个 1。悬崖遍地都是，2 的幂只是"popcount 归 1"的最大号悬崖——比如 62 的最优落点是 64，而 30、46 这类数的就近悬崖（32、48）甚至不是 2 的幂。**悬崖位置没有公式可枚举，所以只能把窗口内的倍数格点挨个算一遍。**

### 六、窗口为什么这么小：三条剪枝定理

固定 $L$，从最近倍数开始按步长 $k$ 往上跳（每跳一格，移位后的值恰好 +1，多付 $k$ 块）。三个终止条件：

**① 34 界（保底剪枝）**

单数任何方案都有保底对照——$L=0$ 档最多 33 轮。所以"额外垫付增量 $\ge 34$"的候选必败。形式化：被跳过的候选账 $\ge 34 + g(\cdot) \ge 35$，而本档 $cnt = 0$ 的账 $\le c^1 + 33$，同档比较差至少 2，弃之无悔。代码即 `if (k * cnt >= 34) break;`。

**② 2 的幂封顶**

移位后的值到达 2 的幂时 popcount 已见底为 1，$\lfloor \log_2 \rfloor$ 只涨不跌，之后不存在更优落点，break。代码判的是原值 $t$，因为 $k \mid t$ 且 $k$ 是 2 的幂，$t$ 是 2 的幂 $\Leftrightarrow t \gg L$ 是 2 的幂，等价。

**③ 高档接管**

本档窗口之外更远的悬崖，全部以更便宜的价格出现在某个更高 $L$ 档的最近倍数上（128 的方案 $\equiv$ 高一档的 64），所以窗口只兜近处、外层 $L$ 只到 17。

三者合起来，每数每档循环步数 $\le 34 / 2^L + 1$，整个窗口机制才既正确又飞快。

### 七、L = 0 的统一处理

代码里 `check(0)` 直接进循环：$k = 1$ 时每个数天然是"1 的倍数"，$c^1 \equiv 0$，窗口变成"纯 $+j$ 找悬崖"（比如 $15 \to 16$ 不借助任何批量就能赚到）。**一套代码覆盖两件事，不用特判。**

### 八、算法流程与复杂度

1. 预处理 $g$ 表到 $2^{18}$
2. 对 $L = 0 \ldots 17$：每个数 $c^1 \to$ 候选（最近倍数）$\to$ 按步长 $k$ 跳格点，遇 2 的幂或增量 $\ge 34$ 停，取 min 累加，最后 $+ L$
3. 输出 18 个档位的最小值

复杂度：预处理 $O(2^{18})$；每组询问 $\sum_L n(1 + 34/2^L) \approx 50n$。

## 逐行代码解析

### 全局变量与 g 表预处理

```cpp
const long long sz = (long long)1 << 18;
int g[sz + 10];
vector<long long> a;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `const long long sz = (1LL) << 18;` | g 表大小 $2^{18} = 262144$。用 `long long` 防止 `1 << 18` 在 32 位环境下的潜在问题 |
| 2 | `int g[sz + 10];` | g 表，下标 $0 \sim 2^{18}$，加 10 的余量防越界。元素值最大 33，`int` 足够 |
| 3 | `vector<long long> a;` | 全局数组，用 `long long` 因为 $a_i + c^1$ 可能超过 `int` 范围（$10^5 + 2^{17} \approx 2.3 \times 10^5$，实际不超 int，但用 long long 更安全） |

### main 函数中的 g 表初始化

```cpp
g[0] = 0;
for (int i = 1; i <= sz; i++)
{
    if (i & 1) g[i] = g[i - 1] + 1;
    else g[i] = g[i >> 1] + 1;
}
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `g[0] = 0;` | 边界：0 的操作数为 0 |
| 3 | `if (i & 1) g[i] = g[i - 1] + 1;` | 奇数：先减 1 变偶数，再走 $g[i-1]$ 的路径 |
| 4 | `else g[i] = g[i >> 1] + 1;` | 偶数：直接折半，走 $g[i/2]$ 的路径 |

这就是 $g(x) = \lfloor \log_2 x \rfloor + \text{popcount}(x)$ 的递推实现。

### check 函数：固定 L 的总花费

```cpp
long long check(int L, int n)
{
    long long k = (long long)1 << L;
    long long c2 = L;
    long long sum13 = 0;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 1 | `long long k = (1LL) << L;` | $k = 2^L$，批量折半的步长 |
| 2 | `long long c2 = L;` | $c^2 = L$，全员共享的团购轮数 |
| 3 | `long long sum13 = 0;` | $\sum (c^1 + c^3)$，所有元素的"垫付 + 单打"之和 |

### check 函数：每个数的窗口搜索

```cpp
    for (int i = 1; i <= n; i++)
    {		
        long long c1 = (a[i] % k) ? (k - (a[i] % k)) : 0;
        long long c3 = g[(a[i] + c1) >> L];
        long long sum = c1 + c3;
        int cnt = 1;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `c1 = (a[i] % k) ? (k - (a[i] % k)) : 0;` | 垫到最近 $2^L$ 倍数的花费。若 $a_i$ 已经是倍数则 $c^1 = 0$ |
| 3 | `c3 = g[(a[i] + c1) >> L];` | 折半后的单打花费。`(a[i]+c1) >> L` $= (a_i + c^1) / 2^L$ |
| 4 | `sum = c1 + c3;` | 本数小账的初始值（最近倍数方案） |
| 5 | `int cnt = 1;` | 窗口搜索计数器，从第 1 格开始跳 |

```cpp
        while (true)
        {
            long long tc1 = c1 + ((long long)1 << L) * cnt;
            long long tc3 = g[((a[i] + c1) >> L) + cnt];
            sum = min(tc1 + tc3, sum);
            if (!((a[i] + tc1) & (a[i] + tc1 - 1)) || (((long long)1 << L) * cnt >= 34)) break;
            cnt++;
        }
        sum13 += sum;
```

| 行 | 代码 | 解析 |
|----|------|------|
| 2 | `tc1 = c1 + ((1LL) << L) * cnt;` | 跳到第 cnt 个更远的 $2^L$ 倍数，多付 $k \times \text{cnt}$ |
| 3 | `tc3 = g[((a[i]+c1) >> L) + cnt];` | 跳完之后的单打。移位值恰好 $+ \text{cnt}$（因为多垫了 $k \times \text{cnt}$，移位后恰好多 cnt） |
| 4 | `sum = min(tc1 + tc3, sum);` | 取更小的账 |
| 5 | `if (!((a[i]+tc1) & (a[i]+tc1-1)) \|\| (k*cnt >= 34)) break;` | 两个终止条件（见下） |
| 6 | `cnt++;` | **必须自增**，否则死循环 |
| 8 | `sum13 += sum;` | 累加到全局 |

**第 5 行的两个 break 条件**：

1. `!(t & (t-1))`：$t = a_i + tc^1$ 是 2 的幂 $\Rightarrow$ popcount 已达最小值 1，再跳只会 $\lfloor \log_2 \rfloor$ 涨，不会更优。这是**剪枝定理②**
2. `k * cnt >= 34`：额外垫付超过 34，就算 $g$ 降到 0 也比保底差。这是**剪枝定理①**

### main 函数：枚举 L 取最小值

```cpp
    while (t--)
    {
        int n;
        cin >> n;
        a.assign(n + 1, 0);
        for (int i = 1; i <= n; i++) cin >> a[i];
        long long ans = LLONG_MAX;
        for (int i = 0; i <= 17; i++) ans = min(ans, check(i, n));
        cout << ans << '\n';
    }
```

| 行 | 代码 | 解析 |
|----|------|------|
| 5 | `ans = LLONG_MAX;` | 初始化为最大值 |
| 6 | `for (int i = 0; i <= 17; i++) ans = min(ans, check(i, n));` | 枚举 $L = 0 \sim 17$，取最小值。$L = 0$ 是保底（不垫，各打各的） |

## 复杂度分析

| 维度 | 复杂度 | 说明 |
|------|--------|------|
| 预处理 | $O(2^{18})$ | g 表初始化，约 $2.6 \times 10^5$ 次操作 |
| 每组查询 | $O(18 \times n \times (34/2^L + 1))$ | 18 个 L 档位，每数每档窗口步数 $\le 34/2^L + 1$ |
| 总计 | $\approx O(50n)$ | $\sum_{L=0}^{17} (1 + 34/2^L) \approx 50$，约 $50n$ 次操作 |
| 空间 | $O(2^{18} + n)$ | g 表 $2^{18}$ 个 int + 输入数组 |

**规模感受**：$n = 10^5$，约 $5 \times 10^6$ 次操作，2 秒内轻松通过。

**为什么 $L$ 只到 17**：$2^{17} = 131072 > 10^5$，所以 $L = 17$ 时 $c^1 \le 2^{17} - 10^5 \approx 31072$，已经远超 34 界。更高的 $L$ 只会让垫付更大，必被 $L=0$ 支配。

## 常见陷阱与注意事项

> 以下是实际调试过程中踩过的**全部坑**，按踩坑顺序排列。这道题花了一整天，每个坑都是血泪教训。

### 坑 1：cnt 忘自增 → 死循环

| 项目 | 内容 |
|------|------|
| 症状 | 程序卡死或 TLE |
| 原因 | `while(true)` 循环里忘了写 `cnt++`，永远卡在第一格 |
| 修法 | 在 `break` 条件判断之后、循环末尾明确写 `cnt++` |

### 坑 2：sum13 = c1 + c3 直接覆盖 → 答案异常小

| 项目 | 内容 |
|------|------|
| 症状 | 输出比正确答案小很多 |
| 原因 | 写成 `sum13 = c1 + c3` 而非 `sum13 += best`，每次循环覆盖了之前累加的结果 |
| 修法 | 用局部 `sum` 变量存当前数的最优值，最后 `sum13 += sum` 累加到全局 |

### 坑 3：逐格爬到 2 的幂 → TLE

| 项目 | 内容 |
|------|------|
| 症状 | 超时 |
| 原因 | 如果只判 2 的幂但不加 34 界剪枝，当 $L$ 较大时步长 $k = 2^L$ 很大，窗口内格点少没问题；但 $L = 0$ 时步长 $k = 1$，从 $a_i$ 爬到最近的 2 的幂可能要爬几十甚至上百格 |
| 修法 | 加上 `k * cnt >= 34` 的 34 界剪枝，将窗口锁定在 $\le 34/k + 1$ 步 |

### 坑 4：x >> L + cnt 优先级雷 → WA

| 项目 | 内容 |
|------|------|
| 症状 | 答案错误 |
| 原因 | C++ 中 `+` 的优先级**高于** `>>`，所以 `x >> L + cnt` 被解析为 `x >> (L + cnt)` 而非 `(x >> L) + cnt` |
| 修法 | 老实加括号：`(x >> L) + cnt`。或者写成 `g[(a[i] + c1) >> L] + cnt` 时注意先移位再加 |

### 坑 5：g 表开小或 int 溢出 → RE/WA

| 项目 | 内容 |
|------|------|
| 症状 | 运行时错误或答案错误 |
| 原因 | g 表只开到 $10^5$ 或 $2^{17}$，但查询下标可能达到 $2^{17}$ 级别（垫付后的值移位）；或者 `1 << L` 在 `L = 17` 时如果 `1` 是 `int` 可能溢出（实际上 $2^{17}$ 不溢出，但写法不规范） |
| 修法 | 表开 $2^{18}$；位移用 `(long long)1 << L` 或 `1LL << L`；`a` 数组用 `long long` |

### 坑 6：2 的幂判断写错

| 项目 | 内容 |
|------|------|
| 症状 | 剪枝错误，漏掉最优解或 TLE |
| 原因 | 用 `x & (x - 1) == 0` 不加括号，被解析为 `x & ((x-1) == 0)` |
| 修法 | 加括号：`(t & (t-1)) == 0`，或取反：`!(t & (t-1))` |

### 坑 7：L = 0 时 k = 1 的退化

| 项目 | 内容 |
|------|------|
| 症状 | 如果对 $L = 0$ 特判跳过，会漏掉"不垫但找悬崖"的优化（如 $15 \to 16$ 不需要批量折半也能省 2） |
| 原因 | 误以为 $L = 0$ 无意义 |
| 修法 | $L = 0$ 时 $k = 1$，每个数天然是"1 的倍数"，$c^1 = 0$，窗口变成纯找悬崖。**一套代码覆盖 $L = 0$ 和 $L > 0$，不用特判。** |

### 坑 8：long long vs int 混用

| 项目 | 内容 |
|------|------|
| 症状 | 隐式转换导致精度丢失 |
| 原因 | `a` 数组用 `int`，但 `a[i] + c1` 可能接近 $2.3 \times 10^5$（不超 int），但 `a[i] + tc1`（跳格后）可能更大 |
| 修法 | `a` 数组、`c1`、`tc1`、`sum`、`sum13`、`ans` 全部用 `long long`。g 表用 `int`（值最大 33）。`sz` 用 `long long` 防止 `1 << 18` 的类型问题 |

### 坑 9：break 条件的顺序

| 项目 | 内容 |
|------|------|
| 症状 | 如果先判 `cnt++` 再判 break，会多跳一格 |
| 原因 | 逻辑顺序混乱 |
| 修法 | 正确顺序：先算 `tc1`、`tc3` 并取 min $\to$ 再判 break 条件 $\to$ 最后 `cnt++`。这样当前格的账已经入 min，break 时不丢失 |

### 坑 10：{5, 5} 口算成 11（正确是 8）

| 项目 | 内容 |
|------|------|
| 症状 | 手算验证错误，导致怀疑代码 |
| 原因 | $g[5] = 4$，两个 5 各打各的 $= 4 + 4 = 8$。如果误以为 $g[5] = 5$ 或忘了"不垫才是最优"，会算成 $5 + 5 = 10$ 或 $11$ |
| 修法 | 垫到 $(6, 6)$ 反而 $2 + g[3] + g[3] = 2 + 3 + 3 = 8$……实际上 $g[6] = g[3] + 1 = 4$，所以 $2 + 4 + 4 = 10$ 更差。$L = 0$ 的 $8$ 才是最优。**不是所有数都值得垫**——这正是枚举 $L$ 取 min 的意义 |

### 坑 11：高档接管的直觉验证

| 项目 | 内容 |
|------|------|
| 症状 | 不理解为什么窗口只兜近处就行 |
| 原因 | 128 的最优方案（垫到 128）在 $L = 1$ 档看起来很远（步长 2，要跳 64 格），但在 $L = 7$ 档它就是最近倍数（$c^1 = 0$）。所以远处的悬崖自然被高档接管 |
| 修法 | 不需要修法——这是正确性保证。理解"高档接管"定理后自然放心 |

## 对比与扩展

### 暴力 vs 本算法

| 维度 | 暴力枚举 | 本算法 |
|------|---------|--------|
| 思路 | 枚举每个数垫到哪个值 | 枚举 $L$ + 窗口搜索 |
| 时间 | $O(n \times \max(a_i))$ | $O(50n)$ |
| $n = 10^5$ | $10^{10}$（超时） | $5 \times 10^6$（秒过） |

### 核心思想提炼

这道题的灵魂是两件事的**独立取优**：

1. **每个数花小钱跳到附近的进位悬崖**——窗口 $\le 34$ 管这个
2. **全体凑出 $L$ 轮共享折半**——外层枚举 $0 \sim 17$ 管这个

窗口的三个边界——34 保底、2 的幂封顶、高档接管——分别由三条定理保证砍得安全。这不是题解语言，是自己推导出来的剪枝条件。$AKB556$, '数学', array['博弈论', '数论', '贪心', '位运算', '进位悬崖', '批量折半'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-cf-gcd-treasury', 'GCD Treasury — 质因子枚举 + 数论结论', $AKB557$## 题目描述

### 原题

贪婪的海盗 Dimash 发现了一个宝库，里面有 $n$ 堆硬币，编号从 $1$ 到 $n$。第 $i$ 堆恰好有 $a_i$ 枚硬币。

海盗有一个数字 $x$，他可以用这个数字从宝库中偷取硬币。偷取过程如下：

1. 他选择一个下标 $1 \le i \le n$，满足 $a_i > 0$ 且 $\gcd(a_i, x) \neq 1$。如果没有这样的下标，海盗停止。
2. 设 $g = \gcd(a_i, x)$。海盗从第 $i$ 堆偷走恰好 $g$ 枚硬币，之后 $a_i$ 减少 $g$。
3. 最后，他将 $x$ 设置为 $g$，并继续偷取硬币。

你的任务是帮助海盗偷取尽可能多的硬币。求出可以从宝库中偷取的最大硬币数。

### 输入格式

每个测试包含多个测试用例。

- 第一行：测试用例数 $t$（$1 \le t \le 10^4$）
- 每个测试用例：
  - 第一行：两个整数 $n, x$（$1 \le n, x \le 3 \cdot 10^5$）
  - 第二行：$n$ 个整数 $a_1, a_2, \dots, a_n$（$1 \le a_i \le 3 \cdot 10^5$）

保证所有测试用例的 $n$ 之和不超过 $3 \cdot 10^5$。

### 输出格式

对于每个测试用例，输出一个整数——可以偷取的最大硬币数。

---

### 数据范围

- $1 \le t \le 10^4$
- $1 \le n, x \le 3 \times 10^5$，$1 \le a_i \le 3 \times 10^5$
- 所有测试用例的 $n$ 之和不超过 $3 \times 10^5$

## 样例

### 样例 1

**输入：**
```
3
3 6
4 9 8
2 5
10 15
1 2
1
```

**输出：**
```
12
25
0
```

**解释：**

- **第 1 组**：初始 $x=6$。质因子为 $2$ 和 $3$。
  - 选 $p=2$：能被 2 整除的堆有 4 和 8，总和 $4+8=12$。
  - 选 $p=3$：能被 3 整除的堆有 9，总和为 $9$。
  - 最大值为 $12$。
  - 具体偷法：先偷第 1 堆（gcd(4,6)=2，偷完剩 0，x=2），再偷第 3 堆（gcd(8,2)=2，偷完剩 0），共偷 $4+8=12$。

- **第 2 组**：初始 $x=5$。质因子只有 $5$。
  - 两堆都能被 5 整除，总和 $10+15=25$。

- **第 3 组**：初始 $x=2$，但 $a_1=1$，gcd(1,2)=1，无法偷取，答案为 $0$。

---

## 解题思路：核心洞察——从模拟到结论

这道题的难点在于从「模拟偷取过程」的表象中提炼出简洁的数论结论。下面逐步推导。

### 洞察一：同一堆可以一口气偷完

假设当前 $x$ 为某个值，选中了第 $i$ 堆，设 $g = \gcd(a_i, x)$。

偷走 $g$ 个硬币后，第 $i$ 堆剩余 $a_i - g$，新的 $x$ 变为 $g$。

下一次再偷同一堆时：
$$\gcd(a_i - g,\ g) = g$$

因为 $a_i$ 是 $g$ 的倍数（$g$ 整除 $a_i$），所以 $a_i - g$ 仍然是 $g$ 的倍数，因此 gcd 还是 $g$。

> **结论**：在把同一堆偷完之前，$x$ 始终保持为 $g$ 不变。每一堆要么完全偷光，要么根本不碰。

### 洞察二：x 非严格单调递减

偷完一堆后，去偷另一堆 $a_j$，新的 $x$ 为：
$$x' = \gcd(a_j,\ \text{旧 } x)$$

由于最大公因数不可能超过其中任何一个数，因此：
$$x' \le \text{旧 } x$$

即 $x$ 在整个过程中**非严格单调递减**。它可能保持不变，也可能变小，但永远不会变大。

### 洞察三：最终状态的性质

假设最终停止时 $x = d$，那么：

1. **$d$ 是初始 $x$ 的因子**：因为每一步新的 $x$ 都是上一步 $x$ 的因子。
2. **$d$ 整除所有被偷过的 $a_i$**：每次偷取后 $x = \gcd(a_i, \text{旧 }x)$，它一定整除 $a_i$。后续的 $x$ 作为一系列 gcd 的结果，会继续整除之前所有被偷过的 $a_i$。

> **结论**：所有被偷的堆都是 $d$ 的倍数，其中 $d$ 是初始 $x$ 的某个大于 1 的因子。

### 洞察四：反向构造——选定 d 就能偷光所有 d 的倍数

反过来思考：如果选定初始 $x$ 的一个因子 $d > 1$，只去偷那些 $a_i$ 是 $d$ 的倍数的堆，能不能全部偷完？

答案是可以。证明如下：

- 初始 $x$ 是 $d$ 的倍数（因为 $d \mid x$）。
- 对于任意满足 $d \mid a_i$ 的堆，有 $\gcd(a_i, x) \ge d > 1$，所以可以开始偷。
- 偷完后新的 $x = \gcd(a_i, x)$ 仍然是 $d$ 的倍数（因为 $d$ 同时整除 $a_i$ 和旧 $x$，所以整除它们的最大公因数）。
- 因此可以继续偷其他 $d$ 的倍数的堆，直到全部偷光。

> **结论**：最大偷取量 =
> $$\max_{d \mid x,\ d > 1} \left( \sum_{i:\ d \mid a_i} a_i \right)$$

### 洞察五：只需枚举质因子

上面的结论要求枚举 $x$ 的所有因子 $d$。但可以进一步优化：

若 $d$ 是合数，它一定有某个质因子 $p$。那么：
$$\{i : d \mid a_i\} \subseteq \{i : p \mid a_i\}$$

即「能被 $d$ 整除的数」一定是「能被 $p$ 整除的数」的子集。因此选 $p$ 能偷的堆一定包含选 $d$ 能偷的堆，总收益不会更小。

> **最终结论**：只需要枚举初始 $x$ 的所有**不同质因子** $p$，计算所有能被 $p$ 整除的 $a_i$ 之和，取最大值即可。
> $$\text{答案} = \max_{p \mid x,\ p\text{ 为质数}} \left( \sum_{i:\ p \mid a_i} a_i \right)$$

---

## 算法流程

### 步骤

1. 对初始 $x$ 进行质因数分解，得到所有不同的质因子。
2. 对每个质因子 $p$，遍历数组 $a$，累加所有能被 $p$ 整除的 $a_i$。
3. 取所有质因子对应的总和的最大值，即为答案。

### 为什么不需要考虑多个质因子的组合？

一个自然的疑问是：如果先选质因子 $p$ 偷一批，再让 $x$ 缩小到另一个质因子 $q$，能不能偷到更多？

答案是不能。因为：

- 初始 $x$ 是 $p$ 的倍数。选 $p$ 偷完所有 $p$ 的倍数后，$x$ 仍然是 $p$ 的倍数（因为每次偷完后的新 $x$ 都是旧 $x$ 的因子，而旧 $x$ 是 $p$ 的倍数）。
- 此时 $x$ 仍然是 $p$ 的倍数，所以不可能变成 $q$（除非 $q=p$）。
- 换句话说，一旦选定了初始的质因子方向，后续的 $x$ 始终是该质因子的倍数，无法切换到另一个独立的质因子。

因此最优策略就是**选定一个质因子，偷光它的所有倍数**，不存在跨质因子的更优策略。

---

## 逐行代码解析

### 读入与数组

```cpp
#include<bits/stdc++.h>
using namespace std;

int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    
    int t;
    cin >> t;
    while (t--)
    {
        int n, x;
        cin >> n >> x;
        vector<int> A(n + 1);           // 1-based 存储数组
        for(int i = 1; i <= n; i++)
            cin >> A[i];
        
        long long ans = 0;              // 答案可能很大，用 long long
        
        
```

- `A` 用 1-based 存；`ans` 用 `long long`——总和可达 $3\times10^5 \times 3\times10^5 = 9\times10^{10}$，`int` 会溢出。

### 枚举 x 的质因子

```cpp
// 枚举 x 的质因子
        for (int i = 2; i * i <= x; i++)
        {
            if (x % i == 0)             // i 是 x 的一个质因子
            {
                while (x % i == 0)      // 去掉所有 i 的因子
                    x /= i;
                
                long long tmp = 0;
                for (int j = 1; j <= n; j++)
                {
                    if (A[j] % i == 0)  // 能被 i 整除的堆都可以被偷光
                    {
                        tmp += A[j];
                    }
                }
                ans = max(ans, tmp);
            }
        }
        
        
```

- `i*i <= x` 是质因数分解的标准上界，只枚举到 $\sqrt{x}$。
- `while (x % i == 0) x /= i`：把因子 $i$ 除干净，保证每个质因子只处理一次。
- 内层扫一遍 $A$，把**能被 $i$ 整除的堆**全部累加进 `tmp`（这些堆能被一次性偷光），再和 `ans` 取 `max`。

### 处理剩余质因子与输出

```cpp
// 处理剩余的质因子（当 x 本身是质数时）
        if (x > 1)
        {
            long long tmp = 0;
            for (int j = 1; j <= n; j++)
            {
                if (A[j] % x == 0)
                {
                    tmp += A[j];
                }
            }
            ans = max(ans, tmp);
        }
        
        cout << ans << '\n';
    }
    return 0;
}
```

- `x > 1` 说明除完后还剩下**一个大质因子**（或 $x$ 本身就是质数），也要按同样方式累加、取 `max`。
- 每个测试用例输出 `ans` 后进入下一组；注意 `x` 在循环里已被除干净，不影响后续用例。

## 复杂度分析

### 时间复杂度

设 $x$ 的不同质因子个数为 $k$。

- 质因数分解：$O(\sqrt{x})$
- 每个质因子遍历一次数组：$O(k \cdot n)$
- 总时间：$O(t \cdot (\sqrt{x} + k \cdot n))$

由于 $x \le 3 \cdot 10^5$，其不同质因子的个数 $k$ 最多为多少呢？

最小的几个质数相乘：$2 \times 3 \times 5 \times 7 \times 11 \times 13 \times 17 = 510510 > 3 \cdot 10^5$，所以 $k \le 6$。

因此实际运行效率很高，完全可以通过时限。

### 空间复杂度

$O(n)$，用于存储数组 $a$。

---

## 常见陷阱与注意事项

### 1. 数据溢出
总和最大可达 $3 \cdot 10^5 \times 3 \cdot 10^5 = 9 \times 10^{10}$，远超 `int` 范围（约 $2 \times 10^9$）。必须使用 `long long` 存储答案和中间累加值。

### 2. 遗漏最后一个质因子
质因数分解的循环到 $i^2 \le x$ 就停止了，如果最后 $x > 1$，说明剩余的 $x$ 本身是一个质数，必须单独处理。例如 $x = 14$，循环处理完 $2$ 后 $x$ 变为 $7$，此时 $i^2 = 9 > 7$，循环结束，但 $7$ 也是质因子。

### 3. 质因子去重
如果 $x$ 有多个相同的质因子（如 $x = 12 = 2^2 \times 3$），同一个质因子只需处理一次。代码中通过 `while (x % i == 0) x /= i` 去掉所有因子 $i$，确保每个质因子只累加一次。

### 4. 初始答案为 0
如果所有 $\gcd(a_i, x) = 1$（即没有能被任何质因子整除的堆），答案就是 $0$，符合题意。

### 5. 为什么不用考虑合数因子
合数因子对应的集合是其某个质因子对应集合的子集，因此收益不可能更大。枚举质因子已经足够。

### 6. 为什么不用考虑多个质因子的组合
选定一个质因子开始偷后，$x$ 始终是该质因子的倍数，无法切换到另一个独立的质因子。因此不存在跨质因子的更优策略。

### 7. 1-based vs 0-based
代码中使用了 1-based 存储（`vector<int> A(n + 1)`），与题目描述一致，减少下标转换错误。

---

## 一句话核心

**最大偷取量 = 枚举初始 $x$ 的所有不同质因子 $p$，计算所有能被 $p$ 整除的 $a_i$ 之和，取最大值。**$AKB557$, '数学', array['数论', 'GCD', '质因数分解', '枚举', '贪心', '结论题'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-dmy5826--stripe-python', '余数 · stripe-python', $AKB558$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[DMY5826](https://newoj.daimayuan.top/p/5826?tid=6acf6a9477933484e04dbb34)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $l,r$，取序列 $a=[l,l+1,\cdots,r]$。将 $a_i$ 任意排列，构造函数
> $$
> f(x)= ((x \bmod a_1) \bmod a_2) \cdots \bmod a_{r-l+1}\quad x\in \mathbb{Z}
> $$
> 对所有 $(r-l+1)!$ 种排列，求本质不同的函数数目。
>
> $l,r \le 2 \times 10^6$，1 秒，512 MB。

:::::success[题解]

记 $n=r-l+1$。显然只要关心 $a_1 \sim a_n$ 的所有前缀 $\min$，最后一个位置必为 $l$。

下面以 $f(x)=((x \bmod 6) \bmod 4) \bmod 3$ 举例说明。由于 $a_1=6$，$f$ 必有 $6$ 的周期，输出序列为
$$
0,1,2,0,0,1,\quad 0,1,2,0,0,1,\quad\cdots
$$
考察 $g(x)=f(x \bmod a)$ 的性质。$g$ 循环节长度变为 $a$，且循环节恰为 $f$ 的前 $a$ 项输出。举例：

- 只有$\bmod 3$：输出为 $012|012|\cdots$。
- 加入$\bmod 4$：输出变为 $0120 |0120 |\cdots$。
- 加入$\bmod 6$：输出变为 $012001 |012001 |\cdots$。

**性质** 将循环节按 $0$ 分块，每块都是从 $0$ 开始的连续递增整数，且第一块必然是 $0,1,\cdots,l-1$。

**举例** $f$ 的输出序列划分为 $012 |0 |01$。

这个条件是充分的。换言之，任意满足上述条件的循环节分块，必能对应到合法的 $f$。构造是将总长和非零块起点降序排序作为 $a$。

我们将问题转化为，对循环节计数，第一块长度为 $l$，之后每块长度 $\in [1,l]$，总长 $\le r$。

可以使用简单递推算出长为 $n$ 的循环节序列数 $f_n$。枚举最后一块长为 $i$ 则
$$
f_n=\sum_{i=1}^l f_{n-i}
$$
初值 $f_l=1$。维护前 $l$ 项和做到线性。

注意到同一个函数可能拥有多个周期，考虑使用最小正周期去重。设 $g_n$ 为最小周期恰为 $n$ 的函数数目，于是
$$
f_n=\sum_{d \mid n} g_d \iff \boxed{g_n=f_n -\sum_{d \mid n \land d<n} g_d}
$$
约数容斥可以枚举 $n$ 的真倍数直接减，过程是调和型枚举。

答案即为 $\sum \limits_{i=l}^r g_i$。总复杂度 $O(n \log n)$。[代码](https://www.cnblogs.com/stripe-python/p/23332840)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB558$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-hdu-5909--stripe-python', 'Tree Cutting · stripe-python', $AKB559$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[HDU5909](https://acm.hdu.edu.cn/showproblem.php?pid=5909)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵 $n$ 个点的树，第 $i$ 个节点的点权为 $a_i$。对每个 $k=0,1,\cdots,m-1$ 求出，点权异或和为 $k$ 的连通块数目。
>
> 多测，$T \le 10$，$n \le 10^3$，$m \le 2^{10}$，2 秒，128 MB。

:::::success[题解]

容易得到树形背包式 DP：

- 记 $f_{u,S}$ 为满足以下条件的连通块 $C$ 数目：
  - $C \subseteq \text{subtree}(u)$。
  - $u \in C$。
  - $\bigoplus\limits_{v \in C} a_v =S$。
- 树形 DP 转移是逐子树加，对儿子 $v$ 进行讨论：
  - 不选择 $v$，则 $f'_{u,S} \gets f_{u,S}$。
  - 选择 $v$，枚举 $T$ 的转移为 $f'_{u,S \oplus T} \gets f_{u,S} f_{v,T}$。
- DP 初值为 $f_{u,a_u}=1$。
- $k$ 的答案为 $\sum\limits_{u \in T} f_{u,k}$。

注意到 $u$ 处的转移是对所有儿子做对称差卷积。设集合幂级数 $F_u(x)=\sum\limits_{S} f_{u,S} x^S$，从而
$$
F_u=x^{a_u}\prod_{v \in \text{son}(u)} (1+F_v)
$$
乘法是对称差卷积。$k$ 的答案即为 $[x^k]\sum\limits_{u \in T} F_u$。

对所有 $F$ 施加 $\text{FWT}$ 变换，卷积化为对位乘法。由 $\text{FWT}$ 的线性性，我们可以求出 $\sum\limits_{u \in T} \text{FWT}(F_u)$ 再做逆变换，总复杂度 $O(nm+m\log m)$。

一个细节是对初值 $x^{a_u}$ 做 $\text{FWT}$。根据 $\phi(S,T)=(-1)^{|S \cap T|}$ 的构造，我们直接对每个位置赋值即可，复杂度 $O(m)$。[代码](https://www.luogu.me/paste/s3gwkitd)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB559$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10004--stripe-python', '[集训队互测 2023] Permutation Counting 2 · stripe-python', $AKB560$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10004](https://www.luogu.com.cn/problem/P10004)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n$，对于所有 $0 \le x,y < n$ 求有多少个 $1\sim n$ 的排列 $p_i$ 满足：
>
> - $\sum \limits_{i=1}^{n-1} [p_i<p_{i+1}]=x$。
> - $\sum \limits_{i=1}^{n-1} [q_i<q_{i+1}]=x$。
>
> $q_i$ 是 $p_i$ 的逆排列，即 $q_{p_i}=i$。
>
> $n \le 500$，5 秒，512 MB。

:::::success[题解]

如果只对 $p$ 有限制，常见做法是容斥。本题中 $p$ 与 $q$ 地位相同，因此可以同时对两维进行容斥。

设原问题的答案为 $f(x,y)$。我们钦定 $p$ 中至少有 $a$ 个上升、$q$ 中至少有 $b$ 个上升，将满足这一条件的方案数记为 $g(a,b)$。有
$$
f(x,y)=\sum_{a=x}^{n-1} \sum_{b=y}^{n-1} (-1)^{a-x} (-1)^{b-y} \dbinom{a}{x} \dbinom{b}{y} g(a,b).
$$

容斥系数 $(-1)^{a-x} (-1)^{b-y} \dbinom{a}{x} \dbinom{b}{y}$ 是超集二元二项式反演给出的。

接下来分析 $g$ 的组合意义。转二维平面分析，即考虑点 $(i,p_i)$。$p$ 的限制作用在纵轴，$q$ 的限制作用在横轴。

我们钦定的每个上升实际上将平面划分为若干个矩形。纵轴上切出 $n-a$ 段，横轴上切出 $n-b$ 段，矩形总数为 $(n-a)(n-b)$。只需在这些区域内选出 $n$ 个点，且要求没有空行和空列，记这个问题的答案为 $g_0(n-a,n-b)$。

类似第二类斯特林数的推导，可以容斥掉不存在空行空列的限制。记：

- $g_0(x,y)$ 为将 $n$ 个点放入 $x \times y$ 个不同区域中，且不存在空行空列的方案数。
- $h(x,y)$ 为 $n$ 个点放入 $x \times y$ 个不同区域中，允许空行空列的方案数。

$h \to g_0$ 的转化是子集二元二项式反演，容斥系数 $(-1)^{x-a} (-1)^{y-b} \dbinom{x}{a} \dbinom{y}{b} $。

考虑计算 $h(x,y)$。这相当于将 $n$ 个无标号球放入 $xy$ 个有标号盒的方案数，即
$$
h(x,y)=\binom{xy+n-1}{n}
$$
因此由 $h \to g_0 \to g \to f$ 即可得到 $f$。$h \to g_0$ 和 $g \to f$ 都需要做二元二项式反演，复杂度 $O(n^4)$。

考虑优化。将 $g \to f$ 的式子拆开：
$$
\begin{aligned}
f(x,y)&=\sum_{a=x}^{n-1} \sum_{b=y}^{n-1} (-1)^{x-i} (-1)^{y-j} \dbinom{a}{x} \dbinom{b}{y} g(a,b)\\
&=\boxed{\sum_{a=x}^{n-1}  (-1)^{x-i} \dbinom{a}{x}\sum_{b=y}^{n-1}  (-1)^{y-j}\dbinom{b}{y} g(a,b)}
\end{aligned}
$$
可以先枚举 $a,y$ 求出 $\sum\limits_{b=y}^{n-1}  (-1)^{y-j}\dbinom{b}{y} g(a,b)$，再枚举 $a,x$ 做外层求和，复杂度即为 $O(n^3)$。$h \to g_0$ 同理。[代码](https://qoj.ac/submission/2887240)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB560$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p10185--stripe-python', '[YDOI R1] Necklace · stripe-python', $AKB561$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P10185](https://www.luogu.com.cn/problem/P10185)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 种颜色的球，第 $i$ 种颜色的球有 $a_i$ 个，所有 $\sum a_i$ 个球互不相同。
>
> 你需要从中取出若干，设第 $i$ 种颜色取 $c_i$ 个，要求 $c_i \ge 1$，则权值为 $\sum (v_i)^{c_i}$。求所有取球方案的权值和。
>
> $n \le 2 \times 10^5$，$a_i \le 10^9$，1 秒，512 MB。

:::::success[题解]

设 $m=\sum a_i$。考虑对每个 $i$ 枚举 $c_i=j$，则 $i$ 的贡献为：

- 剩余 $m-a_i$ 个球任取，方案数 $2^{m-a_i}$。
- 从 $a_i$ 个互相区分的球里取 $j$ 个，方案数 $\binom{a_i}{j}$。

从而答案式
$$
\sum_{i=1}^n \sum_{j=1}^{a_i} 2^{m-a_i}\binom{a_i}{j}(v_i)^j
$$
由二项式定理 $\sum\limits_{j=0}^{a_i} \dbinom{a_i}{j} (v_i)^j 1^{a_i-j}=(v_i+1)^{a_i}$。于是化简为
$$
\boxed{\sum_{i=1}^n  2^{m-a_i}\left((v_i+1)^{a_i}-1\right)}
$$
复杂度 $O(n \log V)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB561$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p11164--stripe-python', '[BalkanOI 2023] Permutations · stripe-python', $AKB562$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P11164](https://www.luogu.com.cn/problem/P11164)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $1\sim n$ 的排列 $p_i$。$q$ 次询问给出 $l,r$，求满足下列条件的 $1\sim n$ 的排列数目：
>
> - 排列的前缀为 $p_l \sim p_r$。
> - 排列的 LDS 长度 $\le 2$。LDS 为最长下降子序列。
>
> $n , q \le 3 \times 10^5$，2 秒，250 MB。

:::::success[题解]

先考虑没有前缀限制怎么做，打表发现答案数列的前几项是 $1,1,2,5,14,42,\cdots$，猜测答案为 Catalan 数 $C_n$。

我们尝试将合法排列和格路计数的模型建立双射。

首先考虑从排列构造格路。我们求出前缀最大值 $s_i=\max \limits_{j=1}^i p_i$，然后将 $(i,s_i)$ 画在平面上，先向上再向右走即可。因为 $s_i \ge i$ 必成立，所以这是一条始终在 $y=x$ 上方的格路。

接着考虑从格路构造排列。先求出每个横坐标对应的高度 $s_i$。对于 $s_i>s_{i-1}$ 的位置 $i$，必有 $p_i=s_i$，即 $p_i$ 是前缀最大值。对于非前缀最大值，我们让它们按照严格递增的顺序，依次填入剩下的空位。

在这个构造中，前缀最大值和非前缀最大值构成的子序列都是递增的。由 Dilworth 定理，$\text{LDS} \le 2$ 当且仅当排列可以被划分为至多两个递增子序列。可以看到，这确实是满足要求的。

现在我们强制排列的前缀为 $a_1,a_2,\cdots,a_k$，这相当于固定了格路的前半段。先假设我们会判定无解，下面按有解讨论。

记 $m=\max\limits_{i=1}^k a_i$，此时格路的起点变成 $(k,m)$。对于 $<m$ 的非前缀最大值，它们已经被钦定了相对顺序，即按严格递增填入空位，故不会产生贡献。我们只要关注 $>m$ 的数。用格路计数的语言来刻画，就是说从 $(k,m)$ 出发不越过 $y=x$ 走到 $(n,n)$ 的格路数目。

用单线反射容斥来算，总方案数 $\dbinom{2n-m-k}{n-k}$，将起点关于 $y=x-1$ 作对称，不合法方案数转化成 $(m+1,k-1) \to (n,n)$ 的朴素格路计数。问题的答案是
$$
\boxed{\binom{2n-m-k}{n-k}-\binom{2n-m-k}{n-m-1}}
$$
原题中 $k=r-l+1$，$m$ 是区间 $\max$。现在的难点在于判无解，这是一个和数数没有关系的纯 ds 题。

设 $[l,r]$ 的区间 $\operatorname{mex}$ 为 $x$，将 $x$ 加到 $p_r$ 后面，则前缀不合法当且仅当序列 $p_l,p_{l+1},\cdots,p_r,x$ 的 $\text{LDS}>2$。等价于下列两个条件至少有一个成立：

- $\exists l \le i<j<k \le r, p_i>p_j>p_k$。
- $\exists l \le i<j \le r, p_i>p_j>x$。

根据区间 $\operatorname{mex}$ 等于补集 $\min$ 的经典结论，$x$ 可以用前后缀 $\min$ 算出来。对上面两个条件分别讨论：

- 第一个条件：我们用单调栈求出 $f_j=\max\limits_{i<j\land  p_i >p_j} i$ 和 $g_j=\min\limits_{j < k\land p_j>p_k} k$。条件转化为 $\exists j \in [l,r], [f_j,g_j] \subseteq [l,r]$。

  这等价于 $\exists i \in [l,r],l \le \min(i,f_i) \land \max(i,g_i) \le r$。由 $i \ge f_i, i \le g_i$ 可以发现 $i \in [l,r]$ 的条件没有用。因此只要判断 $\forall i, [f_i,g_i] \subseteq [l,r]$ 成立。

  将 $(f_i,g_i)$ 画到二维平面上，询问变成 2-side 矩形数点，扫描线，维护 $x$ 坐标历史 $\max$ 直接判定即可。

- 第二个条件：仍用单调栈求得 $f_j$，条件转化为 $\exists j \in [l,r], l \le f_j \land p_j>x$。我们写成 $\max\limits_{i \in [l,r]\land f_i \ge l} p_i>x$。

  将 $(i,f_i)$ 画到二维平面上，询问是 3-side 矩形求 $\max$，扫描线，树状数组支持单点修改后缀 $\max$ 即可。

视 $n,q$ 同阶，判定部分 $O(n \log n)$，计数部分 $O(n)$。[代码](https://www.luogu.com.cn/article/somcbl4c)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB562$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p11362--stripe-python', '[NOIP2024] 遗失的赋值 · stripe-python', $AKB563$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P11362](https://www.luogu.com.cn/problem/P11362)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个整数变量 $x_i \in [1,v]$，其中 $m$ 个位置上的值给定。你需要选择一组 $a_1 \sim a_{n-1}$ 和 $b_1 \sim b_{n-1}$，值域为 $[1,v]$，满足 $\forall x_i=a_i, x_{i+1}=b_i$。
>
> 求合法序列对 $(a,b)$ 的数目，将 $x_i$ 未给定的位置赋值后可以满足限制。
>
> 多测，$T \le 10$，$n,v \le 10^9$，$m \le 10^5$。

:::::success[题解]

首先特判给定值矛盾的情形，答案为 $0$。

注意到 $m$ 个给定位置将值域分成了 $m+1$ 个独立段，考虑对这些段分别计数，将贡献相乘即为所求。

设某段为 $x_1 \sim x_k$，且 $x_1,x_k$ 的值给定。总方案数为 $v^{2(k-2)}$，我们对不合法的情况计数。

容易发现，这种情况下不合法，当且仅当根据 $a,b$ 的限制一路推到 $x_k$ 与给定值冲突，列出约束条件：

- $a_1=x_1$，方案数 $1$。
- $\forall i \in [1,k-2], b_i=a_{i+1}$，方案数 $v^{k-2}$。
- $b_k \ne x_k$，方案数 $v-1$。

综上，$x_1 \sim x_k$ 对合法方案的贡献为 $\boxed{v^{2(k-2)}-v^{k-2}(v-1)}$，累乘即为答案。复杂度 $O(m \log n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB563$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p13011--stripe-python', '【MX-X13-T6】「KDOI-12」能做到的也只不过是静等缘分耗尽的那一天。 · stripe-python', $AKB564$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P13011](https://www.luogu.com.cn/problem/P13011)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对于 $1 \sim n$ 的排列 $p_i$，建立其大根笛卡尔树，并断开每个点与其右儿子（如果存在）的连边，记最后所成的森林为 $T(p)$。
>
> 给出 $q$ 次询问 $n,x,y$，求所有 $1 \sim n$ 的排列中，有多少种 $p$ 满足：在 $T(p)$ 上节点 $x,y$ 位于同一颗树中。
>
> $n \le 5 \times 10^6$，$q \le 10^6$，2 秒，512 MB。

:::::success[题解]

考虑刻画合法的充要条件。

若 $x=y$ 答案显然为 $n!$，否则不妨设 $x<y$。

首先，$p_x>p_y$ 是不合法的，原因是 $y \to x$ 必然要经过一条右链。

进一步，如果 $(x,y)$ 中间有更高的数也是不合法的，如下图所示。此时 $x,y$ 会被区间 $\max$ 划分到两个子树中，而 $y$ 位于右子树。

![](https://cdn.luogu.com.cn/upload/image_hosting/c2tg28co.png)

我们考虑 $x$ 的左侧。注意到，若 $x$ 左侧存在一个更高的数 $z$，则 $x,y$ 都会被 $z$ 划分到其右子树中，且 $(x,y)$ 中间不会被打断，也即 $y \to x$ 全为左链，这是合法的。

![](https://cdn.luogu.com.cn/upload/image_hosting/eyqij8kv.png)

另一种情况是，$x$ 左侧有一个 $(p_x,p_y)$ 之间的数 $z$。

![](https://cdn.luogu.com.cn/upload/image_hosting/znmvbdls.png)

此时 $x \to z$ 全为左链，但 $x$ 被划分到 $z$ 的右子树中，也即 $y \to x$ 经过右链，这不合法。

最后一种情况是，$x$ 左侧所有数都不在 $(p_x,p_y)$ 中。容易说明，$x,y$ 要么被同时划分进右子树，要么 $x$ 被划分进 $y$ 的左子树，这是合法的。

形式化地，合法的排列 $p_i$ 同时满足以下条件：

- $p_x<p_y$。
- $\forall i \in (x,y), p_i <p_y$。
- $\exists z <x, p_z >p_y, \forall i \in (z,x), p_i \notin (p_x,p_y)$ 或 $\forall i \in[1,x), p_i \notin (p_x,p_y)$。

考虑枚举 $p_x=a,p_y=b$，枚举并钦定 $z$ 为满足条件的最大的 $z$。分析排列的结构：

- $1 \sim z-1$ 段：可以任取。
- $z$：可以取 $(b,n]$ 中的数。
- $z+1 \sim x-1$ 段：可以取 $[1,a)$ 中的数。
- $x$：可以取 $\{a\}$ 中的数。
- $x+1 \sim y-1$ 段：可以取 $[1,b)$ 中的数。
- $y$：可以取 $\{b\}$ 中的数。
- $y+1 \sim n$ 段：可以任取。

我们依次决定 $[1,a), [1,b), (b,n]$ 中数的归属，每段的方案数都是一个排列数。于是这种情况的方案数为
$$
S_2=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-(x-z-1)-1}^{y-x-1} A_{n-3-(x-z-1)-(y-x-1)}^{n-y+z-1}
$$
通过类似的讨论，可以得到另一种情况的方案数为
$$
S_1=\sum_{a=1}^n \sum_{b=a+1}^n A_{a-1}^{x-1} A_{b-1-(x-1)-1}^{y-x-1}A_{n-2-(x-1)-(y-x-1)}^{n-y}
$$
答案即为 $S_1+S_2$。至此 $O(qn^3)$。

开始大力推式子。首先，将 $S_2$ 中的排列数都变成组合数，并且对 $a$ 求和可以得到一个组合数上指标前缀和的形式：
$$
\begin{aligned}
S_2&=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-(x-z-1)-1}^{y-x-1} A_{n-3-(x-z-1)-(y-x-1)}^{n-y+z-1}\\
&=\sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)A_{a-1}^{x-z-1} A_{b-1-x+z}^{y-x-1} A_{n-y+z-1}^{n-y+z-1}\\
&= \sum_{a=1}^n \sum_{b=a+1}^n\sum_{z=1}^{x-1} (n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{a-1}{x-z-1}\binom{b-1-x+z}{y-x-1}\\
&= \sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{b-1-x+z}{y-x-1} \sum_{a=1}^{b-1}  \binom{a-1}{x-z-1}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \binom{b-1-x+z}{y-x-1} \binom{b-1}{x-z}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!(x-z-1)!(y-x-1)! \dfrac{(b-1-x+z)!}{(y-x-1)!(b-y+z)!} \times \dfrac{(b-1)!}{(x-z)!(b-1-x+z)!}\\
&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!\dfrac{(b-1)!}{(b-y+z)!(x-z)}
\end{aligned}
$$
至此 $O(qn^2)$。

继续推。首先利用组合数上指标前缀和的结论化简 $S_1$ 有
$$
\begin{aligned}
S_1&=\sum_{a=1}^n \sum_{b=a+1}^n A_{a-1}^{x-1} A_{b-1-(x-1)-1}^{y-x-1}A_{n-2-(x-1)-(y-x-1)}^{n-y}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! \sum_{a=x}^{b-1} A_{a-1}^{x-1}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! (x-1)!\sum_{a=x}^{b-1} \binom{a-1}{x-1}\\
&=\sum_{b=y}^n A_{b-x-1}^{y-x-1} (n-y)! (x-1)!\binom{b-1}{x}\\
&=\sum_{b=y}^n \frac{(b-x-1)!}{(b-y)!}  (n-y)! (x-1)! \frac{(b-1)!}{x!(b-x-1)!}\\
&= \dfrac{(n-y)!}{x} \sum_{b=y}^n \dfrac{(b-1)!}{(b-y)!}\\
&= \dfrac{(n-y)!(y-1)!}{x}  \sum_{b=y}^n \binom{b-1}{y-1}\\
&= \dfrac{(n-y)!(y-1)!}{x}\binom{n}{y}\\
&= \boxed{\dfrac{n!}{xy}}
\end{aligned}
$$
接着化简 $S_2$。考虑使用组合恒等式
$$
\sum_{b=k+1}^n (n-b) \binom{b-1}{k}=\binom{n}{k+2}
$$
其组合意义为：从 $n$ 个元素中取出 $k+2$ 个，枚举并钦定倒数第二个元素所在的位置 $b$。

将这个恒等式代入 $S_2$ 得
$$
\begin{aligned}
S_2&=\sum_{z=1}^{x-1} \sum_{b=1}^n(n-b)(n-y+z-1)!\dfrac{(b-1)!}{(b-y+z)!(x-z)}\\
&=\sum_{z=1}^{x-1} (n-y+z-1)!\sum_{b=1}^n(n-b)\dfrac{(b-1)!}{(b-y+z)!(x-z)!}\\
&=\sum_{z=1}^{x-1} (n-y+z-1)! \dfrac{(y-z-1)!}{x-z} \sum_{b=1}^n(n-b)\binom{b-1}{y-z-1}\\
&= \sum_{z=1}^{x-1} (n-y+z-1)! \dfrac{(y-z-1)!}{x-z} \binom{n}{y-z+1}\\
&= \sum_{z=1}^{x-1} (n-y+z-1)!  \dfrac{(y-z-1)!}{x-z} \dfrac{n!}{(y-z+1)! (b-y+z-1)!}\\
&= \sum_{z=1}^{x-1}  \dfrac{n!}{(x-z)!(y-z)!(y-z+1)!}
\end{aligned}
$$
至此 $O(qn)$。模拟赛时止步于此。

考虑将求和式彻底拆开。令 $k=x-z,d=y-x$，于是
$$
\begin{aligned}
S_2&= \sum_{k=1}^{x-1} \dfrac{1}{k(k+d)(k+d+1)}
\end{aligned}
$$
使用裂项的技巧：
$$
\begin{aligned}
S_2&= \sum_{k=1}^{x-1} \dfrac{1}{k(k+d)(k+d+1)}\\
&= \sum_{k=1}^{x-1} \left(\dfrac{1}{d(d+1)} \left(\dfrac{1}{k}-\dfrac{1}{k+d} \right)-\dfrac{1}{d+1} \left(\dfrac{1}{k+d}-\dfrac{1}{k+d+1}\right)\right)\\
&= \boxed{-\dfrac{n!(x-1)}{y(y-x+1)^2}+\dfrac{n!}{(y-x)(y-x+1)} (H_{x-1}+H_{y-x}-H_{y-1})}
\end{aligned}
$$
其中 $H_n$ 为调和级数 $H_n=\sum \limits_{i=1}^n i^{-1}$。

至此，使用线性逆元预处理 $H_n$ 和阶乘，复杂度 $O(q+n)$。[代码](https://www.luogu.com.cn/article/yumpahmx)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB564$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p13275--stripe-python', '[NOI2025] 集合 · stripe-python', $AKB565$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P13275](https://www.luogu.com.cn/problem/P13275)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $2^n$ 的序列 $a_0 \sim a_{2^n-1}$。记 $f(S)=\underset{i \in S}{\text{and }} i$，特别地 $f(\varnothing)=2^n-1$。求
> $$
> \sum_{P, Q} [P \cap Q=\varnothing][f(P)=f(Q)] \prod_{i \in (P \cup Q)} a_i
> $$
> 其中 $P,Q \subseteq \{0,1,\cdots,2^n-1\}$。
>
> 多测，$T \le 3$，$n \le 20$，2 秒，512 MB。

:::::success[题解]

钦定 $S \subseteq f(P) \land T \subseteq f(Q)$。枚举 $f(P)=f(Q)=W$，则 $(S,T)$ 的容斥系数为 $(-1)^{| S\triangle W|} (-1)^{|T \triangle W|}=(-1)^{|S|+|T|}$。

::::success[证明]

注意到
$$
\begin{aligned}
|S \triangle W|&\equiv |S| + |W |\pmod 2\\
|T \triangle W|&\equiv |T| + |W |\pmod 2
\end{aligned}
$$
从而
$$
\begin{aligned}
|S \triangle W|+|T \triangle W| &\equiv|S|+|T|+2|W| \pmod 2\\
|S \triangle W|+|T \triangle W| &\equiv|S|+|T| \pmod 2\\
\end{aligned}
$$
故有 $(-1)^{|S \triangle W|+|T \triangle W|}=(-1)^{|S|+|T|}$ 成立，证毕。

::::

系数与 $W$ 无关，而 $ W \subseteq (S \cap T)$，则 $(S,T)$ 的容斥系数为 $2^{|S \cap T|} (-1)^{|S|+|T|}$。

设 $f(P) \subseteq S \land f(Q) \subseteq T$ 时的权值和为 $q(S,T)$。讨论 $i \in [0,2^n)$ 的选择：

- 若 $S\nsubseteq i \land T \nsubseteq i$，不能放入 $P$ 或 $Q$，系数为 $1$。
- 若 $S\subseteq i \land T \nsubseteq i$，可以放入 $P$ 或不放，系数为 $a_i+1$。
- 若 $S\nsubseteq i \land T \subseteq i$，可以放入 $Q$ 或不放，系数为 $a_i+1$。
- 若 $S\subseteq i \land T \subseteq i$，可以放入 $P$，放入 $Q$ 或不放，系数为 $2a_i+1$。

由乘法原理合并得到 $q(S,T)$。这样
$$
\begin{aligned}
q(S,T)&=\prod_{S\subseteq i \land T \nsubseteq i} (a_i+1) \prod_{S\nsubseteq i \land T \subseteq i} (a_i+1) \prod_{S\subseteq i \land T \subseteq i} (2a_i+1)\\
&=\prod_{S\subseteq i} (a_i+1) \prod_{T \subseteq i} (a_i+1) \prod_{(S \cup T) \subseteq i} \dfrac{2a_i+1}{(a_i+1)^2}
\end{aligned}
$$
使用高维后缀积预处理
$$
\begin{aligned}
f_S&=\prod_{S \subseteq i} (a_i+1)\\\
g_S&=\prod_{S \subseteq i} \dfrac{2a_i+1}{(a_i+1)^2}
\end{aligned}
$$
从而 $q(S,T)=f_S f_T g_{S \cup T}$。答案式
$$
\begin{aligned}
\sum_{S,T} 2^{|S \cap T|} (-1)^{|S|+|T|} q(S,T)&= \sum_{S,T} 2^{|S \cap T|} (-1)^{|S|+|T|}  f_S f_T g_{S \cup T}
\end{aligned}
$$
利用二元容斥 $|S \cap T|=|S|+|T|-|S \cup T|$ 将 $2^{|S \cap T|}$ 拆开
$$
\begin{aligned}
&\sum_{S,T\subseteq U} 2^{|S \cap T|} (-1)^{|S|+|T|}  f_S f_T g_{S \cup T}\\
=&\sum_{S,T\subseteq U} 2^{|S|+|T|-|S \cup T|} (-1)^{|S|+|T|}f_S f_T g_{S \cup T}\\
=&\sum_{S,T\subseteq U} (-2)^{|S|} f_S \times  (-2)^{|T|} f_T \times  2^{-|S \cup T|} g_{S \cup T}\\
=&\sum_{W\subseteq U} 2^{-|W|} g_{W} \sum_{S \cup T = W}  (-2)^{|S|} f_S \times  (-2)^{|T|} f_T
\end{aligned}
$$
构造集合幂级数 $F=\sum \limits_{S \subseteq U} (-2)^{|S|} f_S$，乘法为并卷积，从而
$$
\sum_{W\subseteq U} 2^{-|W|} g_{W} \sum_{S \cup T = W}  (-2)^{|S|} f_S \times  (-2)^{|T|} f_T=\boxed{\sum_{W\subseteq U} 2^{-|W|} g_{W}[x^W] F^2}
$$
注意处理 $a_i \equiv -1$ 的情形：使用[除零扩域](https://www.luogu.com.cn/article/d3vw3m09)的 trick，将每个数记作 $a \times 0^b$ 的形式，乘除均有良定义。

总复杂度 $O(n2^n)$。[代码](https://qoj.ac/submission/2887280)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB565$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14254--stripe-python', '分割（divide） · stripe-python', $AKB566$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14254](https://www.luogu.com.cn/problem/P14254)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定一棵节点数为 $n$ 的有根树，根节点为 $1$，设第 $i$ 个节点的深度为 $d_i$。对满足以下条件的序列 $a_1 \sim a_k$ 计数：
>
> - $a_1 \sim a_k$ 互不相同。
> - $\forall i\in [1,k), 1<d_{a_i} \le d_{a_{i+1}}$。
> - 对每个 $a_i$，断开 $a_i$ 到父亲的边形成 $k+1$ 棵子树，第 $i$ 棵子树的根为 $a_i$，第 $k+1$ 棵子树的根为 $1$。设第 $i$ 棵子树的 $d$ 值组成集合 $S_i$，要求
>   $$
>   S_1=\bigcap_{i=2}^{k+1} S_i
>   $$
>
> $k < n \le 10^6$，1 秒，512 MB。

:::::success[题解]

可以观察到下面两个结论：

**性质 1** $S_i$ 必然是一段区间 $[l_i,r_i]$。其中 $l_i=d_{a_i}$ 且 $r_i=\max\limits_{j \in \text{subtree}(a_i)} d_j$。

**性质 2** 所有 $a_i$ 的深度相同。

**证明** 考虑反证，若 $d_{a_1}<d_{a_k}$，则 $l_1 < l_k$ 从而 $l_1$ 不在交集中，序列不合法。

根据观察，$a$ 序列的合法条件可以转化为 $r_1=\min \limits_{i=2}^{k+1} r_i$，且 $a_1 \sim a_k$ 同深度。分讨 $\min$ 取到的位置：

- 若 $r_1=\min\limits_{i=2}^k r_i$，则 $r_{k+1} \ge r_1$。对同层节点的 $r$ 值降序排序并枚举 $r_1$，则合法的 $r_i$ 构成一段前缀。

  设 $>r_1$ 的值有 $x$ 个，$=r_1$ 的值有 $y$ 个，注意 $y \ge 2$。枚举 $=r_1$ 的数选择 $i$ 个，方案数为
  $$
  \sum_{i=1}^{y-1} \binom{y-1}{i}\binom{x}{k-1-i}=\binom{x+y-1}{k-1}-\binom{x}{k-1}
  $$
  系数 $y \times (k-1)!$，其中 $y$ 是 $a_1$ 的方案数，$(k-1)!$ 是带序系数。化简是范德蒙德卷积，也可以从单步容斥的组合意义直接得到。

  满足 $r_{k+1} \ge r_1$ 只要 $\ge r_1$ 的部分存在一个未选择节点，即 $x+y>k$。故跳过 $x+y \le k$ 的部分即可。

- 若 $r_1=r_{k+1}$ 且 $\forall i \in [2,k], r_i> r_1$，必有 $x \ge k-1$。而 $r_1=r_{k+1}$ 说明 $>r_1$ 的点全部选中，那么 $x \le k-1$。综上，这种情况成立当且仅当 $x=k-1$。

  $a_2 \sim a_k$ 的选法为 $1$，系数 $y \times (k-1)!$ 即为方案数。

综上，按照深度进行枚举，复杂度 $O(n \log n)$。[代码](https://www.luogu.me/paste/5tv587tp)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB566$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14364--stripe-python', '[CSP-S 2025] 员工招聘 · stripe-python', $AKB567$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14364](https://www.luogu.com.cn/problem/P14364)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 和长为 $n$ 的 01 串 $S$。考虑 $1\sim n$ 的排列 $p_i$，初始有变量 $x=0$，依次对 $i=1,2,\cdots,n$ 执行：
>
> - 若 $S_i=0$ 或 $x \ge c_{p_i}$，令 $x\gets x+1$。
>
> 求最终 $x \le n-m$ 的 $p_i$ 数目。
>
> $n,m \le 500$，2 秒，512 MB。

:::::success[解法一]

考虑从左到右填入的计数顺序。

注意到 $c_i \le x$ 的 $i$ 行为相同，$c_i>x$ 的 $i$ 行为相同，且转化具有单向性，故设计延迟钦定 DP：

- 设 $f_{i,x,y}$ 为满足下列条件的合法方案数：

  - 仅决策 $p_1\sim p_i$。
  - $x$ 为考虑到 $i$ 时变量的值。
  - 前缀 $1\sim i$ 中预留 $y$ 个 $c_i>x$ 的位置，这些位置的具体值待定。

- 转移令 $f_{i-1,x,y} \to f_{i,x',y'}$。对 $S_i$ 分讨：

  - 若 $S_i=0$，必然有 $x'=x+1$。此时 $c_i=x'$ 的 $i$ 移除待定部分，枚举原待定部分 $c_i=x'$ 的数目 $z \in [0,y]$，则 $y' \gets y-z$。贡献系数为：

    - 选出 $z$ 个数在原待定部分，方案数 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z}$。
    - 令 $z$ 个数任意排列，方案数 $z!$。

    设 $a_x$ 为 $c_i \le x$ 的 $i$ 的数目。讨论 $c_{p_i}$ 与 $x'$ 的大小关系：

    - 钦定 $c_{p_i} \le x'$，已用掉 $(i-1)-(y-z)$ 个 $\le x'$ 的数，可用的数目为 $a_{x+1}-(i-1-(y-z))$。

      转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z} z!(a_{x+1}-(i-1-y+z))f_{i-1,x,y} \to f_{i,x+1,y-z}$。

    - 钦定 $c_{p_i}>x'$，将 $p_i$ 扔进待定部分，转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z}z! f_{i-1,x,y} \to f_{i,x+1,y-z+1}$。

  - 若 $S_i=1$，只要讨论 $c_{p_i}$ 与 $x$ 的大小关系。

    - 若 $c_{p_i} \le x$，则 $x'=x+1$。枚举 $z$ 个 $i$ 移出待定部分，贡献系数同理。已用掉 $(i-1)-y$ 个 $\le x$ 的数，可用数目 $a_x-(i-1-y)$。

      转移 $\binom{\text{cnt}_{x+1}}{z} \binom{y}{z} z!(a_x-(i-1-y)) f_{i-1,x,y} \to f_{i,x+1,y-z}$。

    - 若 $c_{p_i} >x$，则 $x'=x$，将 $p_i$ 扔进待定部分，直接转移 $f_{i-1,x,y} \to f_{i,x,y+1}$。

- DP 初值为 $f_{0,0,0}=1$。

- 答案为 $\sum \limits_{x=0}^{n-m} (n-a_x)!f_{n,x,n-a_x}$，系数 $(n-a_x)!$ 表示令待定部分随意排列。

注意到 $\sum \text{cnt}=n$，故 $z$ 的总枚举次数正确，复杂度 $O(n^3)$。注意常数问题，[代码](https://qoj.ac/submission/3058467)。

:::::

:::::success[解法二]

取集合 $U=\{i \mid S_i=1\}$，设 $S \subseteq U$ 为 $x$ 不变的位置集合，只要 $|S|\ge m$。对位置 $i$ 分讨：

- 若 $i \in S$，要求 $c_i>\sum \limits_{j < i} [j \notin S]$。
- 若 $i \notin U \setminus S$，要求 $c_i \le \sum\limits_{j<i} [j \notin S]$。

限制 $c_i > *$ 是困难的，将其容斥为 $1-[c_i \le *]$。钦定 $T \subseteq S$ 满足：

- 若 $i \in T$，要求 $c_i \le \sum\limits_{j<i} [j \notin S]$。
- 若 $i \in S \setminus T$，$c_i$ 无限制。

容斥系数 $(-1)^{|T|}$。

这里 $(T,S \setminus T, U \setminus S)$ 构成 $U$ 的划分。对划分情况进行 DP：

- 设 $f_{i,u,v}$ 为满足下列情况的合法方案数：

  - 仅考虑 $1 \sim i$ 位置。
  - $|S|=u$ 且 $|T|=v$。
  - 仅考虑 $T$ 和 $U \setminus S$ 位置上填入的数。

- 转移时逐个加 $i$，令 $f_{i-1,u,v} \to f_{i,u',v'}$。

  - 若 $S_i=0$ 则 $i\notin S$，转移 $f_{i-1,u,v} \to f_{i,u,v}$。

  - 若 $S_i=1$，此时 $x=i-1-u$。剩余 $\le x$ 的点数为 $q=\sum \limits_{i=1}^n [c_i \le x]-|T|-|U \setminus S|$。

    其中 $|T|=v$，$|U\setminus S|=|U|-|S|=\sum \limits_{j <i} [S_j=1]-u$。容易预处理后算出转移系数 $q$。

    - 令 $i$ 加入 $U \setminus S$，需要 $c_i \le x$，转移 $q \times f_{i-1,u,v} \to f_{i,u,v}$。
    - 令 $i$ 加入 $T$，需要 $c_i \le x$，转移 $q \times f_{i-1,u,v} \to f_{i,u+1,v+1}$。
    - 令 $i$ 加入 $S \setminus T$，无限制，转移 $f_{i-1,u,v} \to f_{i,u+1,v}$。

- DP 初值为 $f_{0,0,0}=1$。

- 算答案时枚举 $(u,v)$ 满足 $u \ge m$。容斥系数 $(-1)^v$，剩余 $|S \setminus T|$ 个位置任意排列，方案数 $\left(n-|U|+u-v\right)!$。则答案式为
  $$
  \sum_{u=m}^n \sum_{v=0}^u (-1)^v\left(n-|U|+u-v\right)! f_{n,u,v}
  $$

复杂度 $O(n^3)$。[代码](https://qoj.ac/submission/3058752)。

带着容斥系数 DP，将 $(-1)^v$ 放到 DP 值里面就是第一篇题解的做法了。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB567$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14514--stripe-python', '[NFLSPC #8] 如何区分北京东路和北京东路 · stripe-python', $AKB568$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14514](https://www.luogu.com.cn/problem/P14514)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出一个长为 $n$ 的序列 $a_i$。进行 $k$ 次操作，每次操作随机选择一个 $i$，令 $\forall j \ne i, a_j \gets a_j+\frac{a_i}{n-1}$，并且 $a_i \gets 0$。对每个 $i$ 求出 $k$ 次操作后 $a_i$ 的期望值。
>
> $n \le 10^6$，$k \le 10^9$，1 秒，128 MB。

:::::success[题解]

考虑期望递推。设 $f_i$ 为当前时刻 $a_i$ 的期望值。对于一次操作：

- 选定 $i$，则 $a_i \gets 0$。
- 选定 $j$，其中 $j \ne i$，则 $a_i \gets a_i+\frac{f_j}{n-1}$。

故单次操作的转移式为
$$
f_i \gets \sum_{j \ne i} \dfrac{1}{n} \times  \left(f_i+\dfrac{f_j}{n-1}\right)
$$
注意到操作不改变 $\sum a_i$，必有 $S=\sum \limits_{i=1}^n f_i$ 为定值。代入转移式
$$
\begin{aligned}
f_i&\gets\dfrac{n-1}{n}\left(f_{i}+\dfrac{1}{n-1}\sum_{j \ne i} f_j\right)\\
&=\dfrac{n-1}{n} f_i+\dfrac{1}{n(n-1)} \sum_{j \ne i} f_j\\
&=\dfrac{n-1}{n} f_i + \dfrac{S-f_i}{n(n-1)}\\
&= \dfrac{n-2}{n-1} f_i+\dfrac{S}{n(n-1)}
\end{aligned}
$$
解一阶线性递推得到
$$
f_i=\boxed{\dfrac{S}{n}+\left(a_i-\dfrac{S}{n}\right) \left(\dfrac{n-2}{n-1}\right)^k}
$$
::::info[一阶线性递推]

**问题** 给定递推公式 $a_{n+1}=pa_n+q$，其中 $p \ne 0 \land p\ne 1$，求 $a_n$ 的通项公式。

构造不动点 $x$ 满足 $x=px+q$，解得 $x=\dfrac{q}{1-p}$。

对递推式进行变形：
$$
\begin{aligned}
a_{n+1}&=pa_n+q\\
a_{n+1}-x &= pa_n+q-x\\
a_{n+1}-x &= p(a_n-x)
\end{aligned}
$$
记 $b_n=a_n-x$，上式给出 $b_{n+1}=p \times b_n$，从而 $b_n=b_1 p^{n-1}$。因此 $a_n$ 的通项为
$$
a_n=(a_1-x) p^{n-1}+x
$$
::::

复杂度 $O(n +\log k)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB568$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14568--stripe-python', '【MX-S12-T3】排列 · stripe-python', $AKB569$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14568](https://www.luogu.com.cn/problem/P14568)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对 $1 \sim n$ 的排列 $p_i$，对每个位置 $i$ 给出下列四种限制之一：
>
> - $p_i < \min \limits_{j < i } p_j$。
> - $p_i > \max \limits_{j < i } p_j$。
> - $p_i < \min \limits_{j > i} p_j$。
> - $p_i > \max \limits_{j > i} p_j$。
>
> 求排列 $p_i$ 的数目。
>
> $n \le 5 \times 10^3$，2 秒，512 MB。

:::::success[题解]

注意到我们只关心元素的相对大小。尝试按位置考虑，从左到右依次决定 $p_i$ 在 $p_1 \sim p_i$ 中的排名。

设当前考虑 $p_i$，其排名为 $x$。对四种限制进行分讨：

- $p_i$ 是前缀 $\min$：$p_i$ 在前缀的排名必为 $x=1$。
- $p_i$ 是前缀 $\max$：$p_i$ 在前缀的排名必为 $x=i$。
- $p_i$ 是后缀 $\min$：未来的所有排名必须 $>x$，相当于抬高了排名的下界。
- $p_i$ 是后缀 $\max$：未来的所有排名必须 $<x$，相当于压低了排名的上界。

我们发现，随着 $i$ 的增加，可用的排名区间 $[l,r]$ 不断收缩。设 $k=r-l+1$，观察四种限制对 $k$ 的影响：

- $p_i$ 是前缀 $\min$ 或 $\max$：上下界不变，总数 $+1$，故 $k \gets k+1$。
- $p_i$ 是后缀 $\min$：选定 $x \in [l,r]$，则下界变为 $x+1$，上界随着总数 $+1$。任取 $x \in [l,r]$ 时 $k'$ 可以取遍 $1 \sim k$，且 $k'$ 与 $x$ 双射。
- $p_i$ 是后缀 $\max$：同理 $k'$ 取遍 $1 \sim k$。

上述讨论说明，我们不必将 $[l,r]$ 放入 DP 状态，直接将 $k$ 作为 DP 的第二维即可转移。

值得说明的是，仅用 $k$ 转移可能会忽略一些情况。例如，前缀 $\min$ 强制 $x=1$，但如果当前下界 $l>1$ 就不可能选到 $x=1$。我们发现这种矛盾是静态的，即后缀 $\min$ 之后又出现前缀 $\min$，当作无解判掉即可。

现在可以列出插入 DP：

- 记 $f_{i,k}$ 为处理完 $p_1 \sim p_i$ 后，当前 $k=r-l+1$ 的方案数。
- 转移时考察 $i$ 位置的限制类型：
  - $p_i$ 是前缀 $\min$ 或前缀 $\max$：$f_{i-1,k-1} \to f_{i,k}$。
  - $p_i$ 是后缀 $\min$ 或后缀 $\max$：$f_{i-1,k'} \to f_{i,k}$。其中 $k' \in [k,i]$。
- DP 初值为 $f_{0,1}=1$。
- 答案为 $\sum \limits_{k=1}^{n+1} f_{n,k}$。

瓶颈在 $f_{i,k}=\sum\limits_{k' \in [k,i]}f_{i-1,k'} $ 这个转移，对 $f$ 施加后缀和优化，复杂度 $O(n^2)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB569$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14636--stripe-python', '[NOIP2025] 清仓甩卖 · stripe-python', $AKB570$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14636](https://www.luogu.com.cn/problem/P14636)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个物品，价值为 $a_i$。你需要确定物品体积 $w_i \in \{1,2\}$，对于总体积为 $m$ 的 01 背包问题，使得下述策略在当前方案下取到最优解：
>
> - 将物品按性价比 $\frac{a_i}{w_i}$ 为第一关键字降序，按 $a_i$ 为第二关键字降序，按 $i$ 为第三关键字升序排序。
> - 依次考虑所有物品。若 $m \ge w_i$ 则选择 $i$ 并令 $m \gets m-w_i$，否则跳过。
>
> 求所有 $2^n$ 种方案中，合法的 $w_1 \sim w_n$ 数目。
>
> 多测，$n \le 5\times 10^3$，$\sum n \le 5 \times 10^4$，1 秒，512 MB。

:::::success[题解]

对贪心错误的情况计数。分析选择序列，取到劣解的情形只有以下两种：

- 在前面选了一个 $1$ 物品 $x$，面对某个 $2$ 物品 $y$ 时只剩 $1$ 的体积，从而在最后选择 $1$ 物品 $z$ 且价值 $a_x+a_z<a_y$。
- 在前面选了一个 $1$ 物品 $x$，面对某个 $2$ 物品 $y$ 时只剩 $1$ 的体积，且 $y$ 后面全是 $2$ 物品，价值 $a_x<a_y$。

认为情形二的 $z=n+1$ 且 $a_z=0$，将分讨统一为一种。

将物品按 $a_i$ 降序排序，枚举 $(x,y)$ 满足性价比 $\frac{a_y}{2}<a_x$ 且价值 $a_y>a_x$。容易发现枚举 $(x,y)$ 不重不漏。描述限制为：

- $x \to y$ 的选择过程中不存在 $1$ 物品。
- $y$ 前面的所有物品体积和恰为 $m-1$。

根据第一个条件，分段对 $w_i$ 序列分析：

- $1 \sim y-1$ 段：无约束 $w_i\in \{1,2\}$。
- $y$ 位置：$w_y=2$。
- $y+1\sim x-1$ 段：
  - 若 $w_i=1$ 则 $i$ 的性价比高于 $y$，扔到 $y$ 前面，合法。
  - 若 $w_i=2$ 则 $i$ 的性价比在 $x\sim y$ 之间，扔到 $y$ 后面，合法。
- $x$ 位置：$w_x=1$。
- $x+1 \sim n$ 段：
  - 若 $a_i>\frac{a_y}{2}$ 则必须 $w_i=2$，否则 $i$ 被扔到 $x \to y$ 过程中作为 $1$ 物品不合法。
  - 若 $a_x+a_i \ge a_y$ 则必须 $w_i=2$，否则 $i$ 不能作为合法的 $z$。
  - 其余情况 $w_i \in \{1,2\}$ 无限制，都能成为合法的 $z$。

设 $y+1 \sim x-1$ 段 $1$ 物品的数目为 $p$，$ 1\sim y-1$ 段 $1$ 物品的数目为 $q$。选择过程 $1\to y$ 的体积和恰为 $m-1$，得到方程
$$
p+q+2(y-1-q)+1=m-1\\
\implies p-q+2y=m
$$
枚举 $q$ 则 $p=m+q-2y$，选法数 $\dbinom{y-1}{q}\dbinom{x-y-1}{p}$。由范德蒙德卷积
$$
\sum_{q=0}^{y-1}\dbinom{y-1}{q}\dbinom{x-y-1}{m+q-2y}=\boxed{\binom{x-2}{m-y-1}}
$$
另一部分贡献系数来源于 $a_i<\frac{a_y}{2} \land a_x+a_i < a_y$ 的 $i$ 的数目 $c$，选法数 $\boxed{2^c}$。

实际上，由于 $a_x>\frac{a_y}{2}$，只要 $a_i < a_y-a_x$ 就合法，循环枚举 $x,y$ 用双指针维护 $c$ 即可。

总复杂度 $O(n^2)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB570$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p14666--stripe-python', '[KenOI 2025] 游走题 · stripe-python', $AKB571$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P14666](https://www.luogu.com.cn/problem/P14666)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定节点数为 $n$ 的有根树 $T$，根节点为 $1$。给定起点 $s$，从 $s$ 开始游走，每次走向任意相邻节点。
>
> 设当前点为 $u$，游走过程为：
>
> - 若下一步走到 $u$ 的父亲 $f$，断开 $(u,f)$ 边。
> - 若 $u$ 没有出边停止游走。
>
> 求所有不同的游走方案的步数之和。称两个游走方案不同，当且仅当经过的节点集合不同。
>
> $n \le 10^6$，1 秒，512 MB。

:::::success[题解]

考虑 $s=1$ 的性质 C。注意到只有返祖边被删除，故游走终点必为节点 $1$。考虑树形 DP：

- 设 $f_u$ 表示 $u \to u$ 的不同游走方案的步数和，$g_u$ 表示 $u \to u$ 的不同游走方案数。

- 枚举 $v \in \text{son}(u)$，考虑树形 DP 转移：

  - 每个 $v$ 子树都必须进入，且子树方案独立，由乘法原理 $g_u=\prod\limits_{v \in \text{son}(u)} g_v$。

  - 考察进入 $v$ 子树对 $f$ 的贡献：

    - 边 $u \to v$ 和 $v\to u$ 各经过一次，总贡献 $2g_u$。
    - 对于除 $v$ 外的其余子树，方案独立，由乘法原理贡献为 $\prod\limits_{w \in \text{son}(u) \land v \ne w} g_w=\dfrac{g_u}{g_v}$。

    综上，得到 $f$ 的转移方程
    $$
    f_u=\sum_{v \in \text{son}(u)} \left(f_v \dfrac{g_u}{g_v}+2g_u\right)=\sum_{v \in \text{son}(u)} \dfrac{g_u}{g_v}(f_v+2g_v)
    $$

扩展到 $s \ne 1$ 的情况。取出 $s \to 1$ 的根链，可以发现游走过程分为两个区域：

- 根链上的子树：游走进入后，必须全部遍历才能返回，复用 $g,f$ 的转移即可。

- 根链上的节点 $u$：走向父亲前，$u$ 可以选择性的进入分支子树，故 $u$ 处的转移为：

  - 每个 $v$ 子树进入或不进入，由独立性 $g_u=\prod\limits_{v \in \text{son}(u)} (g_v+c_v)$。指示变量 $c_v \in \{0,1\}$ 表示 $v$ 是否在主链上。

  - 考察进入 $v$ 子树对 $f$ 的贡献：

    - 若 $c_v=1$，边 $(u,v)$ 被经过 $2$ 次，步数 $f_v+2g_v$。
    - 若 $c_v=0$，走过 $v \to u$ 后边就会断开，只能经过一次边 $(u,v)$，步数 $f_v+g_v$。

    最终转移还要乘上排除 $v$ 子树的方案数，得到
    $$
    f_u=\sum\limits_{v \in \text{son}(u)} \dfrac{g_u}{g_v+c_v}(f_v+g_v+c_vg_v)
    $$

- 注意对根节点特判，答案为 $f_1$。

观察到上述转移需要求 $g_v+c_v$ 的逆元，若 $g_v \equiv -1$ 可能爆掉。考虑节点 $u$ 的儿子序列 $v_1 \sim v_k$，预处理 $g_{v_i}+c_{v_i}$ 的前后缀积，求 $\dfrac{g_u}{g_v+c_v}$ 转而用前后缀积拼起来即可。

复杂度 $O(n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB571$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p16415--stripe-python', '【MX-X28-T4】「FAOI-R12」落花雨 · stripe-python', $AKB572$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P16415](https://www.luogu.com.cn/problem/P16415)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的 01 串 $S$。若 $|S| \ge 2$ 可以选择相邻数 $x,y$，删去 $x,y$ 后插入新数 $x \text{ nor } y$。求任意次操作后可以得到的不同 01 串数目。
>
> 多测，$\sum n \le 10^6$，2 秒，512 MB。

:::::success[题解]

枚举最终串 $T$ 并判定 $S \to T$ 是否合法。判定条件是，将 $S$ 划分为 $|T|$ 个非空子串，使得子串内经 $\text{nor}$ 合并后可以变为对应的单个 $0$ 或 $1$。

通过打表观察，若 $n \ge 4$ 则任意串都能变为单 $0$ 和 $1$，无法变换的串只有以下 $10$ 种：

- 无法变为 $0$：`1`、`00`、`010`；
- 无法变成 $1$：`0`、`01`、`10`、`11`、`000`、`101`、`111`。

考虑可行性 DP，设 $f_i$ 表示 $S$ 的 $(i,n]$ 后缀是否匹配 $T$ 的后缀。在 $T$ 的前端添加字符 $c \in \{0,1\}$ 时，有转移
$$
f_i \gets \bigvee_{j>i \land S(i,j]\to c} f_j
$$
从右向左加所有字符，若 $f_0=1$ 则 $T$ 合法。内层 DP 是 NFA，可以状压 $\{i \mid f_i=1\}$ 转化为 DFA。

根据性质，长度 $\ge 4$ 的串必然存在合法划分，故 $f_j \to f_i$ 对 $i \le j-4$ 恒成立，只保留最大的 $j\sim j-3$ 就能转移。故 DFA 的节点可以构造为二元组 $(m,X)$：

- $m=\max\limits_{f_i=1} i$。
- $X=[f_{i-3},f_{i-2},f_{i-1},f_i]$，用 $4$ 位二进制数状压。

内层 NFA 的状态数为 $n \times 2^4$，转移 $(m,X) \to (m',X')$ 可以枚举 $10$ 种特殊情况 $O(1)$ 算出。

设计如下外层 DP：

- 设 $g_{m,X}$ 表示走到状态 $(m,X)$ 的路径数。
- 转移枚举 $c \in \{0,1\}$ 并得到出边 $(m',X')$，令 $g_{m,X} \to g_{m',X'}$。
- DP 初值为 $g_{n,1}=1$。表示仅 $f_n=1$ 从而 $X=1$。
- 答案为 $f_0=1$ 的所有 $g$ 的和，即 $m \ge 4$ 或者 $m<4$ 且 $X$ 的对应位为 $1$。

状态数 $16 \times n$，转移 $2 \times 10$，总复杂度 $O(20 \times 16 \times n)$，注意常数问题。[代码](https://www.luogu.com.cn/article/w8w4uuj7)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB572$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p16416--stripe-python', '【MX-X28-T5】「FAOI-R12」单人旅行 · stripe-python', $AKB573$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P16416](https://www.luogu.com.cn/problem/P16416)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $n$ 的三个序列 $a_i,b_i,c_i$。考虑 $1 \sim n$ 的排列 $p_i$，依次对 $i=1,2,\cdots,n$ 执行如下操作：
>
> - 令 $t_i=\text{mex}\{c_{p_i},t_1,t_2,\cdots,t_{i-1}\}$。
>
> 定义排列 $p$ 的权值为 $\prod \limits_{i=1}^n (a_it_i+b_i)$，求所有排列的权值和。
>
> $n \le 5 \times 10^3$，$c_i \le 10^9$，2 秒，512 MB。

:::::success[题解]

设 $M_i=\{t_1,t_2,\cdots,t_{i-1}\}$，必有 $M_i=[1,i] \setminus \{x_i\}$，其中 $x_i$ 是当前 $\text{mex}$。对 $c_i$ 和 $x_i$ 的相等关系分讨：

- 若 $c_i\ne x_i$，则 $t_i=x_i$ 且 $x_{i+1}=i+1$。
- 若 $c_i=x_i$，则 $t_i=i+1$ 且 $x_{i+1}=x_i$。

令全集 $U=\{1,2,\cdots,n\}$，枚举 $S \subseteq U$ 满足：

- 对 $i \in S$，要求 $c_i \ne x_i$。
- 对 $i \in U \setminus S$，要求 $c_i = x_i$。

将 $[c_i \ne x_i]$ 容斥为 $1-[c_i =x_i]$。钦定 $T \subseteq S$ 使得：

- 对 $i\in T$，要求 $c_i = x_i$。
- 对 $i\in S \setminus T$ 无限制。

容斥系数 $(-1)^{|T|}$。可以发现 $(T,S \setminus T, U \setminus S)$ 构成对全集 $U$ 的划分，带着容斥系数进行 DP：

- 设 $f_{i,j}$ 为满足下列条件时，带容斥系数 $(-1)^{|T|}$ 的合法权值和：

  - 仅考虑 $1 \sim i$。
  - 第 $i$ 个位置实际上满足 $c_i \ne x_i$，则 $x_{i+1}=i+1$。
  - 序列 $c$ 中消耗了 $j$ 个带限制元素，即约束 $c_i=x_i$ 的 $c_i$。
  - 仅考虑 $T$ 和 $U \setminus S$ 位置上填入的数。

- 转移时，枚举连续 $k$ 个位置划入 $U \setminus S$，接下来第 $i+k+1$ 个位置划入 $T$ 或 $S \setminus T$。

  - 对于位置 $i+1 \sim i+k$：

    - $x$ 恒为 $i+1$，产生的 $t$ 分别为 $i+2 \sim i+k+1$。权值积 $\prod \limits_{u=1}^k \left(a_{i+u} (i+u+1)+b_{i+u}\right)$。

    - 选定 $k$ 个 $=i+1$ 的数随意排列，方案数 $\dbinom{\text{cnt}_{i+1}}{k}k!$。

    转移系数 $q=k!\dbinom{\text{cnt}_{i+1}}{k}\prod \limits_{u=1}^k \left(a_{i+u} (i+u+1)+b_{i+u}\right)$。

    特别地，若 $i+k=n$，直接将 $q \times f_{i,j}$ 累加到 $\text{ans}_{j+k}$ 中并跳出循环，表示最后一个位置落在 $U \setminus S$ 中。

  - 对于位置 $i+k+1$，产生的 $t$ 为 $i+1$，贡献系数 $w=a_{i+k+1}(i+1) + b_{i+k+1}$。

    - 划入 $T$，转移 $qw(\text{cnt}_{i+1}-k)(-1)f_{i,j} \to f_{i+k+1,j+k+1} $。其中 $\text{cnt}_{i+1}-k$ 是选法数，$-1$ 是容斥系数。
    - 划入 $S \setminus T$，转移 $qw\times f_{i,j} \to f_{i+k+1, j+k}$。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $\sum \limits_{j=0}^n (n-j)!(\text{ans}_j+f_{n,j})$。系数 $(n-j)!$ 是 $|S \setminus T|$ 个元素任意排列的方案数。

注意 $\sum \text{cnt}_i=n$，从而总复杂度 $O(n^2)$。[代码](https://www.luogu.com.cn/article/3yi78w7h)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB573$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p16958--stripe-python', '[SCCPC 2026] 括号序列 · stripe-python', $AKB574$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P16958](https://www.luogu.com.cn/problem/P16958)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定合法括号串 $S$，求有多少合法括号串 $T$ 满足 $|T| \le |S|$ 且 $T$ 的字典序不大于 $S$。
>
> 多测，$\sum |S| \le 10^6$，2 秒，1024 MB。

:::::success[题解]

我们将括号串转化成格路。将左括号视作 $x \gets x+1$，右括号视作 $y \gets y+1$，则长为 $2n$ 的合法括号串双射到 $(0,0) \to (n,n)$ 的不跨越 $y=x$ 的格路。

特判 $T$ 是 $S$ 前缀的情形后，枚举并钦定 LCP。具体地，我们枚举 $S$ 的第 $i$ 位，在格路上钦定这样一个结构：

![](https://cdn.luogu.com.cn/upload/image_hosting/8q4ivnal.png)

在 LCP 之后 $T$ 不受字典序限制，枚举 $|T|=m$，则 $T$ 对应 $(x+1,y) \to (m,m)$ 的格路。由单线反射容斥，将终点关于 $y=x+1$ 作对称可得
$$
\binom{m-(x+1)+m-y}{m-y}-\binom{m-1-(x-1)+m+1-y}{m+1-y}
$$
转而枚举 $m-y=k$，整理得到 $(x,y)$ 处的贡献为
$$
\boxed{\sum_{k=0}^{n-y} \left(\binom{2k+y-x-1}{k}-\binom{2k+y-x-1}{k+1}\right)}
$$
我们记
$$
f(a,b)=\sum_{k=0}^b \binom{2k+a}{k}
$$
则 $(x,y)$ 处的贡献可以写作 $f(y-x-1,n-y)-f(y-x-3,n-y+1)$。

瓶颈在于 $f$ 的计算，暴力可以得到 $O(n^2)$ 做法。注意到 $f$ 的形式是一堆组合数加和，类比组合数下指标前缀和的莫队做法，我们考虑 $a,b$ 移动对 $f$ 的影响。$b$ 的移动是简单的：
$$
\begin{aligned}
f(a,b+1)&=f(a,b)+\binom{2(b+1)+2}{b+1}\\
f(a,b-1)&=f(a,b)-\binom{2b+a}{b}
\end{aligned}
$$
我们需要观察 $a \gets a\pm 1$ 的影响。可以对 $a \in [-8,-1], b\in [0,8]$ 进行打表：

```plain
0       0       0       0       0       0       0       0       1
0       0       0       0       0       0       0       1       10
0       0       0       0       0       0       1       9       54
0       0       0       0       0       1       8       44      209
0       0       0       0       1       7       35      155     650
0       0       0       1       6       27      111     441     1728
0       0       1       5       20      76      286     1078    4081
0       1       4       14      49      175     637     2353    8788
```

注意到以下等式成立：$441+637=1078$，$1278+2353=4081$，对其他位置验证也满足规律，猜测有
$$
f(a,b)=f(a-1,b)+f(a+1,b-1)
$$
而 $f(a+1,b-1) \to f(a+1,b)$ 是容易的。从而
$$
\boxed{\begin{aligned}
f(a,b)&=f(a-1,b)+f(a+1,b)-\binom{2b+a+1}{b}\\
f(a-1,b)&= f(a+1,b)-f(a,b)+\binom{2b+a+1}{b}
\end{aligned}}
$$
维护 $f(a,b)$ 和 $f(a+1,b)$ 后可以递推 $f(a-1,b)$，从而 $a \gets a-1$ 解决。对 $a \gets a+1$ 可以逆用上式同理求得。

注意到 $S$ 的枚举过程中，只有 $x \gets x+1$ 和 $y \gets y+1$ 两种操作，对应的移动是 $b \gets b- 1$ 和 $a \gets a\pm 1$，且指针移动总次数 $O(n)$。故直接维护两个 $f$ 值的复杂度就是线性。

复杂度 $O(n)$。[代码](https://qoj.ac/submission/2887256)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB574$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p17140--stripe-python', '[NOI 2026] 线段 · stripe-python', $AKB575$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P17140](https://www.luogu.com.cn/problem/P17140)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 条线段 $[l_i,r_i]$，保证 $[l_i,r_i] \subseteq [1,m]$。定义线段集合 $S \subseteq \{1,2,\cdots,n\}$ 是优美的，当且仅当 $[l_u,r_u] \cap [l_v,r_v] \ne \varnothing$ 时连边 $u \leftrightarrow v$ 形成一棵树。
>
> 给定 $k \le n$，对 $i=1,2,\cdots,k$ 求出，$|S|=i$ 的优美集合数目。
>
> 多测，$T \le 20$，$n \le 3\times 10^3$，$m \le 10^3$，$\sum k \le 200$，4 秒，512 MB。

:::::success[题解]

树是连通无环图，区间图是弦图。综合两个性质得到充要条件：

- 连通：$S$ 的并集是连续线段。
- 无环：不存在某个点的覆盖次数 $\ge 3$。

将线段按左端点升序排序后逐个加入，按照条件设计 DP：

- 设 $f_{i,j,x,y}$ 为满足下列条件的合法方案数：

  - 仅考虑前 $i$ 条线段。
  - $|S|=j$。
  - 当前最大右端点位于 $x$，次大右端点位于 $y$。值 $=0$ 表示不存在。

- 若不加入 $[l_i,r_i]$ 转移 $f_{i-1,j,x,y} \to f_{i,j,x,y}$。加入 $[l_i,r_i]$ 的转移条件可画图分析：

  ![image.png](https://cdn.luogu.com.cn/upload/image_hosting/hrbcfp0t.webp)

  不难发现 $l_i>x$ 则不连通，$l_i\le y$ 则成环。特判 $x=0$，只要 $l_i \in (y,x]$ 就有转移
  $$
  f_{i-1,j,x,y} \to f_{i,j+1,x',y'}
  $$
  其中 $x',y'$ 为集合 $\{x,y,r_i\}$ 的最大 / 次大值。由 $r_i >y$ 可以写作
  $$
  f_{i-1,j,x,y} \to f_{i,j+1,\max(x,r_i),\min(x,r_i)}
  $$

- DP 初值为 $f_{0,0,0,0}=1$。

- 答案为 $\text{ans}_j=\sum\limits_{x,y} f_{n,x,y}$。

对 $i$ 维度滚动数组，$j$ 倒序枚举，时间 $O(nm^2k)$ 空间 $O(m^2k)$ 无法通过。

对 $y$ 维度动态维护前缀和
$$
s_{j,x}=\sum_{y<l_i} f_{j,x,y}
$$
转移变为
$$
f_{j+1,\max(x,r_i),\min(x,r_i)} \gets s_{j,x}
$$
注意到 $l_i$ 单调不降，当 $l_i$ 增加时更新 $s_{j,x} \gets f_{j,x,y}$ 即可。特判 $x=0$ 的相关转移。

显然 $y \le x$，空间可以折半，时间 $O(nmk)$ 空间 $O(m^2k)$，经卡常可以通过。[代码](https://qoj.ac/submission/3189361)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB575$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p1758--stripe-python', '[NOI2009] 管道取珠 · stripe-python', $AKB576$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P1758](https://www.luogu.com.cn/problem/P1758)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定两个长为 $n,m$ 的栈 $A,B$，第 $i$ 次操作任选一个栈，将其栈顶弹出并加入结果序列，直到 $A,B$ 均为空。
>
> 设本质不同的结果序列数目为 $k$，得到第 $i$ 种序列的方法数为 $a_i$，求 $\sum a_i^2$。
>
> $n,m \le 500$，2 秒，125 MB。

:::::success[题解]

根据 Product Trick，$\sum a_i \times a_i$ 可以视作进行两次操作，所得的结果序列相同的方案数。

对着这个组合意义进行 DP：

- 记 $f_{x,y,z}$ 为满足如下条件时，两次操作的结果序列相同的方案数：
  - 两次操作均取出 $x$ 个元素。
  - 第一次操作取出 $A$ 的前 $y$ 个元素。
  - 第二次操作取出 $A$ 的前 $z$ 个元素。
- 转移讨论两次操作中取 $A$ 或者 $B$，转移满足取出元素相同，对四种情形简单讨论即可。
- DP 初值为 $f_{0,0,0}=1$。
- 答案为 $f_{n+m,n,n}$。

时空复杂度 $O(n^3)$，将 $x$ 维度滚动数组即可满足空间限制。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB576$, '数学', array['题解'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-luogu-p17723', 'P17723 [SCP-S 2026] 函数 func', $AKB577$## 题目描述

给定一个长度为 $n$ 的非负整数序列 $a$。

对于非空的非负整数集合 $S=\{s_1,s_2,\dots,s_k\}$，定义两个函数：

- $OR(S)=s_1\lor s_2\lor\cdots\lor s_k$，即集合中所有元素按位或的结果（$\lor$ 表示按位或）；
- $MEX(S)=\min\{x\in\mathbb{N}\mid x\notin S\}$，即不在 $S$ 中的最小非负整数。

对区间 $[l,r]$，设 $S=\{a_l,a_{l+1},\dots,a_r\}$，定义 $f(l,r)=OR(S)\lor MEX(S)$。

求 $\sum_{1\le l\le r\le n}f(l,r)$，答案对 $2^{64}$ 取模。

### 输入格式

本题输入量较大，请使用较快的输入方式。

第一行一个正整数 $n$；第二行 $n$ 个非负整数 $a_1,a_2,\dots,a_n$。

### 输出格式

输出一行一个非负整数，表示所有区间的价值之和对 $2^{64}$ 取模后的结果。

### 数据范围

- $1\le n\le 2\times 10^6$；
- $0\le a_i<2^{30}$。

| 测试点编号 | $n\le$ | $a_i<$ | 特殊性质 |
|---|---|---|---|
| 1 | 10 | 4 | |
| 2 | 100 | 2¹⁰ | |
| 3 | 1000 | 2²⁰ | |
| 4 | 3000 | | |
| 5~6 | 5000 | 2³⁰ | |
| 7 | 2×10⁴ | | ✓ |
| 8 | 5×10⁴ | | |
| 9~10 | 10⁵ | | |
| 11 | | 2¹⁰ | |
| 12 | 2×10⁵ | 2²⁰ | |
| 13 | | 2³⁰ | |
| 14 | 5×10⁵ | | |
| 15 | 10⁶ | 2¹⁰ | ✓ |
| 16 | 1.5×10⁶ | 2²⁰ | |
| 17~20 | 2×10⁶ | 2³⁰ | |

特殊性质：$a_i$ 在对应取值范围内独立、均匀随机生成。原题样例 4~7 见选手目录文件，不在本页收录。

---

## 样例

### 样例 1

**输入：**

```
3
0 1 2
```

**输出（本代码实测，与官方一致）：**

```
13
```

**解释：** 6 个区间的价值分别为 $f(1,1)=1$、$f(2,2)=1$、$f(3,3)=2$、$f(1,2)=3$、$f(2,3)=3$、$f(1,3)=3$，和为 $13$。以 $[1,2]$ 为例：$S=\{0,1\}$，$OR=1$，$MEX=2$，$f=1\lor 2=3$。

### 样例 2

**输入：**

```
4
1 0 1 3
```

**输出（本代码实测，与官方一致）：**

```
24
```

**解释：** 长度为 1 的四个区间价值依次为 $1,1,1,3$，其余六个区间价值均为 $3$，总和 $1+1+1+3+6\times3=24$。

### 样例 3

**输入：**

```
10
536870912 0 1 2 3 536870912 1073741823 0 0 1
```

**输出（本代码实测，与官方一致）：**

```
35970351152
```

---

## 解题思路

看到「对所有区间求和 + 按位或 + MEX」，直接对每个区间算两遍再相加会错：某一位上 $OR$ 和 $MEX$ 同时为 $1$ 时，加法会产生进位多算。例如 $OR=111_2=7$、$MEX=1$ 时，$7\lor 1=7$，但直接相加 $7+1=8$，多算了 $1$。所以先拆位，用恒等式

$$
OR\lor MEX = OR + (MEX\ \&\ \lnot OR)
$$

逐位验证（第 $b$ 位上，或运算的结果只由「$OR_b$ 或 $MEX_b$ 为 1」决定，而加法式中 $OR$ 已贡献 $OR_b$，只需在 $OR_b=0$ 且 $MEX_b=1$ 时额外补 $2^b$）：

| $OR_b$ | $MEX_b$ | 或结果 | $OR$ 部分贡献 | $MEX\ \&\ \lnot OR$ 需补 |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 | $2^b$ |
| 1 | 0 | 1 | $2^b$ | 0 |
| 1 | 1 | 1 | $2^b$ | 0 |

于是把答案分成两部分：

$$
\sum f(l,r)=\underbrace{\sum_b 2^b\cdot\#\{区间:OR_b=1\}}_{第一部分}
+\underbrace{\sum_b 2^b\cdot\#\{区间:OR_b=0,\ MEX_b=1\}}_{第二部分}
$$

**第一部分（OR 的贡献）**：固定第 $b$ 位，$OR_b=0$ 当且仅当区间内每个数第 $b$ 位都是 $0$，即区间完全落在某个「第 $b$ 位全 0 连续段」内部。所有区间分成 $OR_b=1$ 与 $OR_b=0$ 两类且互补，总区间数 $\frac{n(n+1)}{2}$ 减去所有全 0 段的 $\frac{len(len+1)}{2}$ 之和（一个长 $len$ 的全 0 段内部正好有 $\frac{len(len+1)}{2}$ 个子区间），剩下的就是 $OR_b=1$ 的区间数，乘 $2^b$ 入答案。扫描时用「找到全 0 段 → 跳段」完成，每位 $O(n)$ 共 $O(30n)$。

**第二部分（MEX 补充的贡献）**：固定第 $b$ 位，同时要求 $OR_b=0$ 且 $MEX_b=1$，逐步推导：

1. 由 $OR_b=0$：区间内所有数第 $b$ 位都是 0。而 $2^b$ 的二进制是最高位（第 $b$ 位）为 1 的数，因此 **$2^b$ 不可能出现在区间里**；$MEX$ 是不在集合里的最小非负整数，集合缺了 $2^b$ 这个数，于是 $MEX\le 2^b$。
2. 由 $MEX_b=1$：$MEX$ 的第 $b$ 位为 1，说明 $MEX\ge 2^b$（二进制里第 $b$ 位为 1 的最小非负整数是 $2^b$）。
3. 两步夹逼得 $\boxed{MEX=2^b}$，值被完全确定，不再是模糊的「某个 MEX」。

再由 MEX 的等价条件：$MEX=2^b$ 当且仅当**$0,1,\dots,2^b-1$ 全部出现**且 $2^b$ 不出现（小于 $2^b$ 的数都在集合里，$2^b$ 本身不在）。其中「$2^b$ 不出现」已由 $OR_b=0$ 自动保证。所以第二部分统计的就是：每个全 0 段内部「包含全部 $2^b$ 个目标小整数」的区间数，乘 $2^b$；当 $2^b>n$ 时区间长度装不下 $2^b$ 个不同数字，贡献恒为 0（所以 $b$ 只需到 $\lfloor\log_2 n\rfloor$）。

**双指针统计（段内数区间）**：固定段内左端点 $ml$，随右端点增大，窗口包含的数字只增不减，一旦满足「包含全部 $0..k-1$」（$k=2^b$）之后继续扩右端点依然满足。因此每个 $ml$ 存在**最小合法右端点** $r_0$，右端点取 $r_0..r$ 一共 $r-r_0+1$ 个都合法。$ml$ 右移一格会删掉一个元素，窗口包含的数字只减不增，所以新的 $r_0$ 只会右移、不会回退——反证：若 $r_0$ 会变小，右指针就得向左回退重新扫描，每个元素会被反复访问，复杂度退化成接近 $O(段长\times k)$ 的灾难。右指针不回退，每个元素至多加入、删除各一次，段内统计是 $O(段长)$。

**时间戳按需清零**：上面每个「全 0 段 × 每个 $b$」都要调一次 `fn`，若每次把 `vis[0..k-1]` 全清零是 $O(k)$——段数可到 $O(n)$ 个、$k$ 可达 $O(n)$，总代价最坏 $O(n^2)$，直接超时。改用全局时间戳 `ntime`：每次调用 `fn` 先 `++ntime` 标记「新的一轮」；访问 $x$ 时若 `tim[x]\ne ntime` 才把 `vis[x]` 重置为 0 并盖上当前时间戳。真正访问过多少个位置就重置多少个，每个元素每次调用至多被重置一次，均摊 $O(1)$，总复杂度保住 $O(n\log n)$。

### 关键洞察

$OR_b=0$ 与 $MEX_b=1$ 两个条件把 MEX 夹逼成精确值 $2^b$，把「算 MEX」这种全局性问题化归为「全 0 段内用双指针数包含 $0..2^b-1$ 的区间」——每一层位只做线性扫描。

---

## 逐行代码解析

### 模块一：全局数组与快读快写

```cpp
#include<bits/stdc++.h>
using namespace std;
vector<int> a,vis,tim;
int ntime;
inline int read()
{
	long long x = 0, f = 1; char ch = getchar();
	while (ch < '0' || ch>'9') { if (ch == '-') f = -1; ch = getchar(); }
	while (ch >= '0' && ch <= '9') { x = x * 10 + ch - 48; ch = getchar(); }
	return x * f;
}
inline void write(unsigned long long x)
{
	static char buf[30];
	int p = 0;
	if (x == 0) buf[p++] = '0';
	while (x) { buf[p++] = x % 10 + 48; x /= 10; }
	while (p--) putchar(buf[p]);
}
```

- `n\le 2\times10^6` 输入输出量大，用 `getchar/putchar` 手写快读快写；`write` 以 `unsigned long long` 接收，答案在 $2^{64}$ 内自然溢出后仍是合法的非负余数。
- `vis` 是「目标数字出现次数」、`tim` 是「上次被访问的时间戳」，两者配合实现按需清零；`ntime` 是全局时间戳计数器。

### 模块二：`init` 与时间戳重置 `update`

```cpp
void init(int n)
{
	a.assign(n + 1, 0);
	int big = 1;
	while (big < n + 1) big <<= 1;
	vis.assign(big, 0);
	tim.assign(big, 0);
	ntime = 0;
}

inline void update(int x)
{
	if (tim[x] != ntime)
	{
		tim[x] = ntime;
		vis[x] = 0;
	}
}
```

- `big` 取「不小于 $n+1$ 的最小 2 的幂」作 `vis/tim` 大小：目标数字最大 `k-1`，而 `k=2^b\le n`，所以下标不会越界；比 $k$ 大的 $a_i$ 在 `fn` 里会被 `a[mr] < k` 过滤，绝不访问。
- `update(x)`：只有在真正访问 $x$ 时才做「旧值重置」，用时间戳区分「这次调用已访问」与「上次调用的脏值」，避免每次 `fn` 全量清零。

### 模块三：`fn` 双指针统计段内合法区间

```cpp
unsigned long long fn(int l, int r, int k)
{
	++ntime;
	unsigned long long p = 0;
	int cnt = 0;
	int mr = l - 1;

	for (int ml = l; ml <= r; ++ml)
	{
		while (mr < r && cnt < k)
		{
			++mr;
			if (a[mr] < k)
			{
				update(a[mr]);
				if (vis[a[mr]] == 0) ++cnt;
				++vis[a[mr]];
			}
		}

		if (cnt == k) p += (unsigned long long)r - mr + 1;

		if (mr >= ml && a[ml] < k)
		{
			--vis[a[ml]];
			if (vis[a[ml]] == 0) --cnt;
		}
	}
	return p;
}
```

- `fn(l, r, k)` 返回全 0 段 $[l,r]$ 内「包含全部 $0..k-1$」的子区间个数，其中 $k=2^b$。
- 外层枚举左端点 `ml`，内层 `while` 扩张右端点 `mr` 直到窗口集齐 $k$ 个目标数字或撞段尾；由于「包含性」单调，$mr$ 全程不回退。
- `cnt==k` 时，右端点取 $mr..r$ 都合法，贡献 `r-mr+1`；随后把 `a[ml]` 移出窗口（出现次数减 1，减到 0 时 `cnt` 减 1），供下一轮左端点使用。
- `if (a[mr] < k)` 的过滤：只统计目标数字，比 $k$ 大的元素对 MEX 条件无影响，跳过。
- `(unsigned long long)r - mr + 1` 显式提升避免有符号运算隐患。

### 模块四：`main` 按位枚举两部分贡献

```cpp
int main()
{
	int n;
	unsigned long long ans = 0;
	n = read();
	init(n);
	for (int i = 1; i <= n; i++) a[i] = read();
	for (int b = 0; b <= 30; b++)
	{
		unsigned long long cnt = (unsigned long long)n * (n + 1) / 2;
		int k = 1 << b;
		for (int l = 1; l <= n; l++)
		{
			if (!(a[l] & k))
			{
				int r = l;
				while (r < n && !(a[r + 1] & k)) ++r;

				unsigned long long len = r - l + 1;
				cnt -= len * (len + 1) / 2;

				if (k <= n)
				{
					unsigned long long t = fn(l, r, k);
					ans += t * k;
				}

				l = r;
			}
		}
		ans += cnt * k;
	}
	write(ans);
	return 0;
}
```

- 外层 `for b=0..30` 按位处理；$b=30$ 时所有数第 30 位都是 0（$a_i<2^{30}$），第一部分贡献为 0、第二部分 `k>n` 跳过，多跑一次无副作用。
- 内层扫描：遇到第 $b$ 位为 0 的位置，先向右扩展出整个全 0 段 $[l,r]$，`cnt` 减去该段内部子区间数（第一部分容斥）；若 `k<=n` 再调 `fn` 加第二部分贡献；最后 `l = r` 配合循环的 `++l` 跳段（若写成 `l=r+1` 会漏一个位置）。
- `ans += cnt * k`：第一部分贡献——「OR 第 $b$ 位为 1 的区间数 × 2^b」。
- `write(ans)`：$ans$ 用 `unsigned long long` 自然对 $2^{64}$ 取模，全程不额外取模。

---

## 复杂度分析

- **时间复杂度**：第一部分每个 $b$ 扫一遍序列，$O(30n)$。第二部分每个 $b$（$2^b\le n$，至多 $\lfloor\log_2 n\rfloor$ 个）在全 0 段内做双指针，每个元素至多加入、删除各一次，时间戳让 `update` 均摊 $O(1)$，合计 $O(n\log n)$。总计 $O(n\log n)$，$n\le 2\times 10^6$ 可行。
- **空间复杂度**：$a$ 为 $O(n)$，`vis/tim` 大小为不超过 $2(n+1)$ 的 2 的幂，均 $O(n)$。

---

## 常见陷阱与注意事项

1. **加法进位多算**：$OR$ 与 $MEX$ 同一位都为 1 时直接相加会进位；必须先拆位，用 $OR\lor MEX=OR+(MEX\ \&\ \lnot OR)$ 分成两部分独立统计。
2. **跳段写法**：段结束后写 `l = r`，让 `for` 的 `++l` 落到下一段开头；写 `l = r + 1` 会因循环再 `+1` 漏掉 $r+1$ 这个位置。
3. **`vis/tim` 大小**：取不小于 $n+1$ 的最小 2 的幂；`fn` 里只访问满足 `a[mr] < k <= n < big` 的元素，不会越界——依赖 `a[mr] < k` 的过滤，别忘了。
4. **时间戳按需清零**：`update` 在加入和删除前都要调用，否则 `vis` 里残留上一次 `fn` 调用的旧值，`cnt` 直接算错；删 $a[ml]$ 时 `mr >= ml` 保证它本次一定被加入过。
5. **溢出与类型**：答案对 $2^{64}$ 取模 = `unsigned long long` 自然溢出；`p += (unsigned long long)r - mr + 1`、`ans += t * k` 都要保证提升为 `unsigned long long` 再算。
6. **$b$ 的上界**：$a_i<2^{30}$，枚举到 $b=30$ 多跑一轮无害（贡献为 0）；第二部分 `k<=n` 才调 `fn`，避免 $2^b>n$ 时的无效统计。
7. **数据随机性只是部分测试点的性质**：特殊性质仅保证部分测试点 $a_i$ 随机；做法本身对任意数据成立，不要依赖随机性。

---

## 对比与扩展

- **按位拆贡献**：与 XOR 排序、异或方程等题库内位运算题同属「逐位独立 + 容斥计数」套路；「$OR_b$ 为 0 的区间」= 全 0 连续段内子区间，是位运算题的常见几何化。
- **MEX 的位级刻画**：本体的核心手法是「$MEX_b=1$ 且 $2^b$ 不在集合内 $\Rightarrow MEX=2^b$」的夹逼；凡涉及 MEX 与位运算混合的题，都可以尝试把 MEX 的第 $b$ 位翻译成「包含 $0..2^b-1$」的判定。
- **双指针 + 时间戳清零**：多测/多次调用中避免 $O(k)$ 清零的时间戳技巧，也适用于并查集、莫队等需要反复重置辅助数组的场景；双指针的「右指针不回退」依赖于段内包含性的单调。
- **相关知识点**：区间按位统计的模板套路可与本库「滑动窗口/单调队列」类知识点互相印证；题目本身定位为 SCP-S 级别的位运算综合题。$AKB577$, '数学', array['按位统计', '双指针', '时间戳', '位运算', 'MEX', '贡献统计'], null, '提高', 'problem'),
('Xesir', 'col-prob-luogu-p3758--xesir', 'P3758 [TJOI2017] 可乐 · Xesir', $AKB578$## 题目描述

加里敦星球的人们特别喜欢喝可乐。因而，他们的敌对星球研发出了一个可乐机器人，并且放在了加里敦星球的 $1$ 号城市上。

这个可乐机器人有三种行为：停在原地，去下一个相邻的城市，自爆。它每一秒都会随机触发一种行为。现在给加里敦星球城市图，在第 $0$ 秒时可乐机器人在 $1$ 号城市，问经过了 $t$ 秒，可乐机器人的行为方案数是多少？

### 输入格式

第一行输入两个正整数 $N$，$M$。$N$ 表示城市个数，$M$ 表示道路个数。

接下来 $M$ 行每行两个整数 $u$，$v$，表示 $u$，$v$ 之间有一条道路。保证两座城市之间只有一条路相连，且没有任何一条道路连接两个相同的城市。

最后一行是一个整数 $t$，表示经过的时间。

### 输出格式

输出可乐机器人的行为方案数，答案可能很大，请输出对 $2017$ 取模后的结果。

### 数据范围

- 对于 $20\%$ 的数据，保证 $t \le 1000$。
- 对于 $100\%$ 的数据，保证 $1 < t \le 10^6$，$1 \le N \le 30$，$0 < M < 100$，$1 \le u, v \le N$。

## 样例

### 样例 1

**输入：**

```
3 2
1 2
2 3
2
```

**输出：**

```
8
```

**解释：**

- $1 \to$ 爆炸。
- $1 \to 1 \to$ 爆炸。
- $1 \to 2 \to$ 爆炸。
- $1 \to 1 \to 1$。
- $1 \to 1 \to 2$。
- $1 \to 2 \to 1$。
- $1 \to 2 \to 2$。
- $1 \to 2 \to 3$。

## 解题思路

非常经典的矩阵快速幂题目。

设 $dp_{i,j}$ 为运行 $i$ 秒后停留在 $j$ 节点的方案数。为了维护爆炸状态，设 $0$ 号节点表示爆炸，并为每个点（包括 $0$）添加一条与 $0$ 相连的边——一旦走到 $0$，就再也不会离开。

每个点能从自身和与之相邻的点转移过来（为了统一，给每个点添加自环），所以

$$dp_{i,j}=\sum_{k\in S_j} dp_{i-1,k}$$

其中 $S_j$ 是 $j$ 的邻域（含自己）。

直接递推是 $O(tN^2)$ 的，而 $t$ 可以到 $10^6$，会超时。于是考虑构造递推矩阵——

~~你这个时候就会发现根本不用构造，递推矩阵就是该图邻接矩阵，于是做完了~~

把「自环 + 与 $0$ 连通」的图写成邻接矩阵 $A$，那么「走 $t$ 步的方案数」就是 $A^t$，用快速幂即可。初始状态是一个只有第 $1$ 位为 $1$ 的行向量，最后把 $A^t$ 第 $1$ 行的所有元素求和就是答案（爆炸后停在哪里都算一种方案）。

### 把三种行为统一成「走一条边」

机器人每秒只有三种动作，看起来要分三种情况讨论。但换个角度看：

- 「停在原地」= 沿着一条**自环**走一步；
- 「去相邻城市」= 沿着一条**原图的边**走一步；
- 「自爆」= 走进一个**只进不出**的特殊点。

于是只要做两件事，三种行为就变成了同一种操作——「在扩展图上走一条边」：

1. 给每个点补一条自环；
2. 新增 $0$ 号点表示爆炸，从每个点向 $0$ 连边，并且只给 $0$ 自己补自环（进入后无法离开）。

这样一来，「$t$ 秒后的行为方案数」就是「扩展图上从 $1$ 出发走恰好 $t$ 步的路径条数」，而后者有一个现成的结论。

### 关键性质：恰好 $k$ 步路径数 = 邻接矩阵的 $k$ 次幂

设扩展图的邻接矩阵为 $A$（$A_{uv}=1$ 表示 $u\to v$ 有边）。用归纳法看 $A^2$：

$$(A^2)_{uv}=\sum_{w}A_{uw}A_{wv}$$

求和号里的每一项恰好对应「$u\to w\to v$ 这条两步路径是否存在」，所以 $(A^2)_{uv}$ 就是 $u$ 到 $v$ 的**恰好两步**路径条数。同理 $A^k$ 的第 $u$ 行第 $v$ 列就是恰好 $k$ 步的路径条数。

初始状态是「第 $0$ 秒在 $1$ 号点」，用一个只有第 $1$ 位为 $1$ 的行向量 $e_1$ 表示，那么 $e_1A^t$ 的第 $v$ 位就是「$t$ 秒后停在 $v$ 的方案数」。

而题目问的是**总方案数**，不限定最后停在哪，所以要把 $0\sim n$ 全部加起来——这就是代码里那个 `for(int i=0;i<=n;i++) ans+=res[1][i]` 的来源。

### 手算样例

样例是 $3$ 个点、两条边 $1-2$、$2-3$，$t=2$。扩展图有 $0,1,2,3$ 四个点，边为：

- 自环：$0\to0,\;1\to1,\;2\to2,\;3\to3$；
- 爆炸边：$1\to0,\;2\to0,\;3\to0$；
- 原图边：$1\to2,\;2\to1,\;2\to3,\;3\to2$。

注意 $0$ 只有自环、没有出边通向别的点，所以「爆炸后不可能再回到城市」。

从 $1$ 出发走两步，按第一步落点分类：

| 第一步 | 第二步可选的目标 | 条数 |
|---|---|---|
| $1\to1$ | $0,\,1,\,2$ | $3$ |
| $1\to0$ | $0$ | $1$ |
| $1\to2$ | $0,\,1,\,2,\,3$ | $4$ |

合计 $3+1+4=8$，与样例输出一致。

## 逐行代码解析

### 头文件、别名与矩阵乘法

```cpp
#include <bits/stdc++.h>
using namespace std;
const int mod=2017,N=50;
#define pb push_back
#define vi vector<int>
#define v2 vector<vector<int>>
v2 mtxi(int n){
    v2 c(n,vi(n,0));
    for(int i=0;i<n;i++) c[i][i]=1;
    return c;
}
v2 muljz(v2 a,v2 b){
    int m=a.size(),p=a[0].size(),n=b[0].size();
    v2 c(m,vi(n,0));
    for(int i=0;i<m;i++){
        for(int k=0;k<p;k++){
            if(a[i][k]==0) continue;
            for(int j=0;j<n;j++) c[i][j]=(c[i][j]%mod+a[i][k]*b[k][j]%mod)%mod;
        }
    }
    return c;
}
```

- `v2` 就是二维 `vector`，用它存矩阵，省去手写数组维度。
- `mtxi(n)` 造 $n$ 阶单位矩阵，快速幂的初值要用。
- `muljz` 是标准的 $i$-$k$-$j$ 三重循环乘法：外层固定 `a[i][k]`，内层沿 `j` 累加，这样对缓存更友好。
- `if(a[i][k]==0) continue;` 跳过零元，稀疏矩阵下能省掉大量无谓乘法。
- 每一步乘完立刻 `%mod`，避免中间结果溢出。

### 矩阵快速幂

```cpp
v2 ksmjz(v2 a,int k){
    int n=a.size();
    v2 res=mtxi(n);
    while(k){
        if(k&1) res=muljz(res,a);
        a=muljz(a,a);
        k>>=1;
    }
    return res;
}
```

- `res` 初始为单位矩阵，对应「走 $0$ 步」。
- `while(k)` 按二进制拆指数：当前位为 $1$ 就把 `a` 乘进 `res`，然后 `a` 自乘、指数右移一位。
- 循环次数是 $O(\log t)$，每次乘法 $O(N^3)$，总复杂度 $O(N^3\log t)$。

### 建图：自环 + 爆炸点

```cpp
signed main(){
    ios::sync_with_stdio(0);
    cin.tie(0);cout.tie(0);
    int n,m,t,ans=0;cin>>n>>m;
    v2 x(n+1,vi(n+1,0)),y(n+1,vi(n+1,0));
    x[1][1]=1;
    for(int i=0;i<=n;i++) y[i][i]=1,y[i][0]=1;
    while(m--){
        int u,v;cin>>u>>v;
        //u--;v--;
        y[u][v]=y[v][u]=1;
    }
```

- 矩阵开成 $(n+1)\times(n+1)$，多出来的第 $0$ 号下标就是「爆炸」状态。
- `x[1][1]=1`：初始向量只在 $1$ 号城市有 $1$ 种方案。
- `y[i][i]=1` 给每个点加自环（原地停留），`y[i][0]=1` 表示任何点下一秒都能爆炸并进入 $0$ 号点。
- `y[0][0]=1` 也在循环里一并设好：进入爆炸状态后就永远停在 $0$，不会再产生新方案。
- `//u--;v--;` 是原文留下的注释，说明题目给的是 $1$ 下标，正好直接拿来用。

### 乘出答案并累加

```cpp
    cin>>t;
    v2 res=muljz(x,ksmjz(y,t));
    for(int i=0;i<=n;i++) ans=(ans%mod+res[1][i]%mod);
    cout<<ans%mod;
    return 0;
}
```

- `ksmjz(y,t)` 得到「走 $t$ 步」的转移矩阵，再乘上初始向量 `x` 得到最终分布。
- 累加第 $1$ 行的所有列：机器人可能停在 $0\sim n$ 的任意位置，每一种都是一种行为方案。
- 注意 `x` 是 $1\times (n+1)$ 的矩阵，`res` 也是，所以取 `res[1][i]` 这一行。

## 复杂度分析

矩阵快速幂是 $O(N^3\log t)$，其中 $N\le 30$、$t\le 10^6$，完全跑得动。空间上存两个 $(N+1)\times(N+1)$ 的矩阵，$O(N^2)$。

## 常见陷阱与注意事项

- **爆炸状态必须自环**：只写 `y[i][0]=1` 而不写 `y[0][0]=1`，机器人下一秒会从「爆炸」回到别处，答案偏大。
- **答案要累加整行**：只取 `res[1][0]` 会漏掉「没有爆炸」的方案。
- **下标从 $1$ 开始**：题目的城市编号是 $1\sim N$，矩阵也要开到 $n+1$，别把 $0$ 号爆炸点和 $1$ 号城市搞混。
- **取模位置**：`a[i][k]*b[k][j]` 可能到 $10^{18}$ 级别，必须在乘完立刻取模。
- **`signed main`**：代码里有 `#define int long long` 一类的宏时，`main` 要写成 `signed main`；本题没有该宏，但保留写法不影响运行。

## 对比与扩展

- 与「P1450 硬币购物」的关系：那道题用容斥把「数量上限」转成无上限，本题用矩阵把「时间维」转成矩阵幂，都是「把难处理的维度消掉」的思路。
- 图上「走恰好 $k$ 步的方案数」是邻接矩阵幂的经典应用，配合自环还能处理「原地等待」。
- 如果 $t$ 更大、$N$ 也更松，可以把矩阵换成稀疏矩阵乘法，或者用多项式特征值一类的手段。$AKB578$, '数学', array['矩阵快速幂', '矩阵乘法', '图论计数', '动态规划'], null, '普及+/提高−', 'problem'),
('stripe-python', 'col-prob-luogu-p4260--stripe-python', '[Code+#3] 博弈论与概率统计 · stripe-python', $AKB579$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P4260](https://www.luogu.com.cn/problem/P4260)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有两个变量 $a,b$，初始 $a=b=0$。进行 $n+m$ 轮操作，一轮操作中：
>
> - 令 $a \gets a+1, b \gets \max(0,b-1)$。概率为 $p$。
> - 令 $a \gets \max(0,a-1), b \gets b+1$。概率为 $1-p$。
>
> 且第一类操作恰好发生 $n$ 次。求 $a$ 的期望。
>
> 进行 $q$ 次询问，每轮询问均给出 $n,m,p$ 并输出答案。
>
> $q,n+m \le 2.5 \times 10^5$，1 秒，125 MB。

::::::success[题解]

容易发现 $p$ 是搞笑的，求出 $\sum a$ 后除以 $\binom{n+m}{n}$ 即为所求。

设第一类操作进行 $x$ 次，第二类操作进行 $y$ 次。忽略与 $0$ 取 $\max$ 的限制，则 $a=x-y$。

设全过程 $a=0$ 时 $-1$ 共进行 $k$ 次，最终 $a=n+k-m$。只要算出 $k$ 对应的方案数即可。

做一个单步容斥，即 $[x=k]=[x \le k]-[x \le k-1]$。根据分析，至多 $k$ 次的充要条件为，任意时刻 $y-x \le k$。

将 $(x,y)$ 拍到二维平面上，问题转化为从 $(0,0)$ 走到 $(n,m)$，不越过 $y=x+k$ 的格路数目。由单线反射容斥，将终点关于 $y=x+k+1$ 做对称可得
$$
\binom{n+m}{n}-\binom{n+m}{m-k-1}
$$
至少转恰好是作差，则 $\text{ans}_k=\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}$。求和即为答案。

- 若 $n \ge m$，那么

  $$
  \begin{aligned}
  \text{ans}&=\sum_{k=0}^m (n+k-m) \left(\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}\right)\\
  &=\sum_{i=0}^m (n-i) \left(\dbinom{n+m}{i}-\dbinom{n+m}{i-1}\right)\\
  &=\sum_{i=0}^m (n-i) \dbinom{n+m}{i}-\sum_{i=0}^{m-1} (n-i-1)\dbinom{n+m}{i}\\
  &=\boxed{\sum_{i=0}^{m-1} \binom{n+m}{i}+(n-m) \binom{n+m}{m}}
  \end{aligned}
  $$

  第二步为换元 $i=m-k$，第三步后面的和式 $i \gets i-1$，第四步为对位相减。

- 若 $n \le m$，同理化简得
  $$
  \begin{aligned}
  \text{ans}&=\sum_{k=m-n}^{m} (n+k-m) \left(\dbinom{n+m}{m-k}-\dbinom{n+m}{m-k-1}\right)\\
  &=\boxed{\sum_{i=0}^{n-1} \binom{n+m}{i}}
  \end{aligned}
  $$

问题转化为 $q$ 次询问组合数下指标前缀和，莫队解决即可，复杂度 $O(n\sqrt{q})$。

:::::info[组合数下指标前缀和]

模板题：[AT_tenka1_2014_final_d 高橋君](https://www.luogu.com.cn/problem/AT_tenka1_2014_final_d)。

> 进行 $q$ 次询问，给定 $n,m$，求
> $$
> f(n,m)=\left(\sum_{i=0}^m \binom{n}{i}\right) \bmod (10^9+7)
> $$
> $q \le 10^5$，$0 \le n,m \le 10^5$，6 秒，256 MB。

考察莫队思想，只要 $n,m$ 移动后 $f(n,m)$ 可以由原本的值 $O(1)$ 递推得到。事实上：

- $f(n,m+1)=f(n,m)+\dbinom{n}{m+1}$。
- $f(n,m-1)=f(n,m)-\dbinom{n}{m}$。
- $f(n+1,m)=2f(n,m)-\dbinom{n}{m}$。
- $f(n-1,m)=\dfrac{f(n,m)+\binom{n-1}{m}}{2}$。

前两条转移显然，后两条由组合数递推式裂项可得。

利用莫队构造，我们可以在 $O(n \sqrt{q})$ 的复杂度内**离线**解决组合数下指标前缀和的问题。

事实上这个问题也存在 $O(q+m \log^2 m)$ 的离线解法，参见 <https://www.luogu.com.cn/article/xypg20ht>。

:::::

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB579$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p4590--stripe-python', '[TJOI2018] 游园会 · stripe-python', $AKB580$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P4590](https://www.luogu.com.cn/problem/P4590)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定长为 $k$ 的字符串 $S$。对每个 $i=0,1,\cdots,k$，求出满足如下要求的本质不同字符串 $T$ 数目：
>
> - $T$ 的字符集为 $\{\tt{N},\tt{O},\tt{I}\}$。
> - $|T|=n$。
> - $\tt{NOI}$ 不是 $T$ 的子串。
> - $\text{LCS}(S,T)=i$。
>
> $n \le 10^3$，$k \le 15$，6 秒，250 MB。

:::::success[题解]

前三条限制是容易压进 DP 状态的。我们发现 $\text{LCS}$ 难以刻画，因为直接去算两个串的 LCS 都需要 dp。

不妨考察用于计算 LCS 的 dp。记 $f_{i,j}$ 为 $T[1:i]$ 与 $S[1:j]$ 的 LCS 长度，转移为
$$
f_{i,j}=\max(f_{i-1,j},f_{i,j-1}, f_{i-1,j-1} +[T[i]=S[j]])
$$
对同一行的 $f$，根据经典结论有 $f_{i,j}-f_{i,j-1} \in \{0,1\}$，从而考虑状压差分数组，状态数是 $O(2^k)$ 的。我们将差分数组代表的 01 串作为 DFA 的节点。

这样，内层 DFA 的建立过程即为：枚举节点编码 $\text{mask}$，将其还原为 DP 数组 $f_i$，再枚举出边字符 $c$，按照 DP 规则进行转移，得到新的 DP 数组 $f'_i$。将其压缩成 $\text{mask}'$ 并记录转移边。

建立 LCS 的 DFA 后，设计如下外层 DP：

- 记 $f_{i,j,\text{mask}}$ 为满足如下条件时，合法的 $T$ 的数目：
  - $|T|=i$。
  - $T$ 的末位匹配了 $\tt{NOI}$ 的前 $j$ 位。
  - $T$ 在内层 DFA 上的对应节点为 $\text{mask}$。
- 转移 $f_{i,j,\text{mask}} \to f_{i,j',\text{mask}'}$。枚举出边字符 $c$，分别更新 $j'$ 和 $\text{mask}'$，其中 $\text{mask}'$ 由内层 DFA 走出边得到。对 $j' \ge 3$ 的转移忽略。
- DP 初值为 $f_{0,0,0}=1$，其中 $\text{mask}=0$ 为内层 DFA 起点的编码。
- 答案为 $\text{ans}_k=\sum \limits_{\text{popcount}(\text{mask})=k} \sum\limits_{j=0 }^2 f_{n,j,\text{mask}}$。利用 $\text{popcount}$ 的原因是，$\text{mask}$ 中 $1$ 的数目恰好等价于 $\text{LCS}(S,T)$。

时空复杂度 $O(2^kn)$。进一步对 $f$ 的第一维滚动数组，空间优化到 $O(2^k)$。 

实际上，对内层 DFA 的状态进行搜索，只保留有效节点，可以得到 $O(|\Sigma| n)$ 的复杂度，$|\Sigma|$ 为 DFA 有效状态数。这里 $O(2^k)$ 的状压足以通过本题。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB580$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p4609--stripe-python', '[FJOI2016] 建筑师 · stripe-python', $AKB581$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P4609](https://www.luogu.com.cn/problem/P4609)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $n,a,b$，求有多少个 $1 \sim n$ 的排列 $p_i$ 满足前缀最大值的数目恰为 $a$，后缀最大值的数目恰为 $b$。
>
> 多测，$T \le 2 \times 10^5$，$n \le 5 \times 10^3$，$a,b \le 100$，1 秒，250 MB。

:::::success[题解]

我们注意到，$n$ 一定是前后缀最大值。因此填入 $n$ 后排列被分成两部分，左边包含恰好 $a-1$ 个前缀最大值，右边包含恰好 $b-1$ 个后缀最大值。

以左边为例，记前缀最大值的位置为 $p$，下一个前缀最大值的位置为 $q$，则将 $[p,q)$ 称为一个块。右边同理定义。根据定义，左边的块必须由块内最大值升序排序，右边必须降序排序。

考虑如何构造一个块。通过观察，我们发现一个块和一个圆排列构成双射。对于一个圆排列，我们总可以从最大值处断开，并将其作为块的起始或结尾。因此，剩余 $n-1$ 个元素划分为 $(a-1)+(b-1)=a+b-2$ 个块的方案数对应着第一类斯特林数的组合意义。

现在我们得到了这些块，只需确定块的排列顺序，而这是简单的。只需从 $a+b-2$ 个块中选出 $a-1$ 个放到左边，然后按照两边的排序规则排序即可。因此我们得到了本题的答案
$$
\boxed{\binom{a+b-2}{a-1}\begin{bmatrix}
n-1 \\
a+b-2
\end{bmatrix}}
$$
直接递推即可，复杂度 $O(na+T)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB581$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p5389--stripe-python', '[Cnoi2019] 数学课 · stripe-python', $AKB582$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P5389](https://www.luogu.com.cn/problem/P5389)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有长为 $n$ 的数列 $a_i=1+2+\cdots+i$。独立地以概率 $p_i,p_j$ 分别选出两个元素 $a_i,a_j$，并等概率地选出整数 $x \in [1,a_i], y \in [1,a_j]$，求 $x>y$ 的概率。
>
> 其中，$p_i=\dfrac{3i(i+1)}{n(n+1)(n+2)}$。$n$ 可能为 $+\infty$。
>
> $1 \le n \le 10^{18}$，或者 $n=+\infty$。1 秒，125 MB。

:::::success[题解]

注意到 $x,y$ 的地位完全相同，很自然地 $P(x<y)=P(x>y)$。那么由对称性我们只需计算 $\dfrac{1-P(x=y)}{2}$。

考虑枚举 $i,j$，然后直接列出答案式

$$
P(x=y)=\sum_{i=1}^n \sum_{j=1}^n p_ip_j \dfrac{\min(a_i,a_j)}{a_ia_j}
$$

我们发现 $\dfrac{p_i}{a_i}$ 是一个不变量，具体地：

$$
\dfrac{p_i}{a_i}=\dfrac{3i(i+1)}{n(n+1)(n+2)} \times \dfrac{2}{i(i+1)}=\dfrac{6}{n(n+1)(n+2)}
$$

记这一常数为 $C$，代入以后大力推式子

$$
\begin{aligned}
P(x=y)&=C^2\sum_{i=1}^n \sum_{j=1}^n \min(a_i,a_j)\\
&=C^2 \sum_{i=1}^n \left(\sum_{j=1}^i a_j+\sum_{j=i+1}^n a_i\right)\\
&=C^2 \sum_{i=1}^n \left(\sum_{j=1}^i \dfrac{j(j+1)}{2}+(n-i)\dfrac{i(i+1)}{2}\right)\\
&=C^2 \sum_{i=1}^n \left(\dfrac{i(i+1)(i+2)}{6}+\dfrac{i(i+1)(n-i)}{2}\right)\\
&= C^2  \sum_{i=1}^n \left(\dfrac{ni(i+1)}{2}+\dfrac{(1-i)i(i+1)}{3}\right)\\
&=C^2 \left(\dfrac{3n+2}{6}\sum_{i=1}^n i(i+1)-\dfrac{1}{3} \sum_{i=1}^n i^2 (i+1)\right)\\
&= C^2 \left(\dfrac{3n+2}{6}\times \dfrac{n(n+1)(n+2)}{3}  -\dfrac{1}{3} \times \dfrac{n(n+1)(3n^2+7n+2)}{12}\right)\\
&=\dfrac{C^2n(n+1)^2(n+2)}{12}\\
&= \dfrac{n(n+1)^2(n+2)}{12}\times  \dfrac{36}{n^2(n+1)^2(n+2)^2}\\
&=\boxed{\dfrac{3}{n(n+2)}}
\end{aligned}
$$

这里用到了一些熟知结论：

- $\sum \limits_{i=1}^n i =\dfrac{n(n+1)}{2}$。
- $\sum \limits_{i=1}^n i^2=\dfrac{n(n+1)(n+2)}{6}$。
- $\sum\limits_{i=1}^n i^3=\dfrac{n^2(n+1)^2}{4}$。

题目保证 $n,n+2$ 非零，故 $n$ 有限的情况可以 $O(\log p)$ 解决。

事实上，$\lim\limits_{n \to +\infty} \dfrac{3}{n(n+2)}=0$，故 $n$ 为正无穷的情形答案就是 $\dfrac{1}{2}$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB582$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p6475--stripe-python', '[NOI Online #2 入门组] 建设城市 · stripe-python', $AKB583$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P6475](https://www.luogu.com.cn/problem/P6475)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m,x,y$。求满足以下条件的正整数序列 $a_1 \sim a_{2n}$ 的数目：
>
> - $a_i \in [1,m]$。
> - $a_1 \le a_2 \le \cdots \le a_n$。
> - $a_{n+1} \ge a_{n+2} \ge \cdots \ge a_{2n}$。
> - $a_x=a_y$。
>
> $n,m \le 10^5$，1 秒，128 MB。

:::::success[题解]

::::info[不降序列计数]

**问题** 对值域 $[l,r]$，长为 $n$ 的不降序列 $a_1 \sim a_n$ 计数。

我们令 $a_i \gets a_i+i$，则值域变为 $[l+1,r+n]$，只要对递增序列 $a_1 \sim a_n$ 计数。

考虑从 $[l+1,r+n]$ 中取出 $n$ 个数，这些数自动升序排序，从而方案数 $\dbinom{r-l+n}{n}=\dbinom{r-l+n}{r-l}$。

::::

考虑枚举 $a_x=a_y=k$，对 $x,y$ 的位置分类讨论：

- $x \le n \le y$：序列分为 $[1,x),(x,n], (n,y), (y,2n]$ 四段分步计数：

  - $[1,x)$ 段：$[1,x)$ 段：对值域 $[1,k]$，长为 $x-1$ 的不降序列计数，方案数 $\dbinom{k-1+x-1}{k-1}$。
  - $(x,n]$ 段：对值域 $[k,m]$，长为 $n-x$ 的不降序列计数，方案数 $\dbinom{m-k+n-x}{m-k}$。
  - $(n,y)$ 段：对值域 $[k,m]$，长为 $y-n-1$ 的不升序列计数，方案数 $\dbinom{m-k+y-n-1}{m-k}$。
  - $(y,2n]$ 段：对值域 $[1,k]$，长为 $2n-y$ 的不升序列计数，方案数 $\dbinom{k-1+2n-y}{k-1}$。
    将四段的方案数相乘得到答案

  $$
  \boxed{\sum_{k=1}^{m} \binom{k+x-2}{k-1} \binom{m-k+n-x}{m-k} \binom{m-k+y-n-1}{m-k} \binom{k+2n-y-1}{k-1}}
  $$

- $x,y \le n$：序列分为 $[1,x), (x,y), (y,n], (n,2n]$ 四段分步计数：

  - $[1,x)$ 段：对值域 $[1,k]$，长为 $x-1$ 的不降序列计数，方案数 $\dbinom{k-1+x-1}{k-1}$。
  - $(x,y)$ 段：方案数为 $1$。
  - $(y,n]$ 段：对值域 $[k,m]$，长为 $n-y$ 的不降序列计数，方案数 $\dbinom{m-k+n-y}{m-k}$。
  - $(n,2n]$ 段：对值域 $[1,m]$，长为 $n$ 的不升序列计数，方案数 $\dbinom{m-1+n}{m-1}$。
    将四段的方案数相乘得到答案

  $$
  \boxed{\binom{n+m-1}{m-1} \sum_{k=1}^{m} \binom{k+x-2}{k-1} \binom{m-k+n-y}{m-k}}
  $$

  对于 $x,y \ge n$ 的情形同理。

复杂度 $O(m)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB583$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p7044--stripe-python', '「MCOI-03」括号 · stripe-python', $AKB584$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P7044](https://www.luogu.com.cn/problem/P7044)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 定义一个括号串的 $0$ 级权值为，将括号串修改为合法的最小操作次数。一次操作可以在任意位置插入或删除括号。
>
> 定义一个括号串的 $k$ 级权值为所有子串 $k-1$ 级权值之和。
>
> 给定长为 $n$ 的括号串，求出 $k$ 级权值。
>
> $n,k \le 10^6$，1 秒，500 MB。

:::::success[题解]

设子串 $[l,r]$ 的 $0$ 级权值对最终答案的贡献系数为 $f_{l,r}$，初始 $f_{1,n}=1$。每轮迭代 $[l,r]$ 对 $[l',r'] \subseteq [l,r]$ 有贡献，执行 $k$ 轮转移：
$$
f_{l,r} \gets \sum_{x=1}^l \sum_{y=r}^n f_{x,y}
$$
预处理 $a_i$ 为第 $i$ 个括号的匹配位置，将贡献拆到字符上：

- 若 $i$ 失配，只要 $i \in [l,r]$ 就产生贡献，答案加上 $\sum\limits_{l=1}^i \sum\limits_{r=i}^n f_{l,r}$。
- 若 $i$ 是左括号且与 $j=a_i$ 匹配，此时 $i \in [l,r] \land j \notin [l,r]$ 有贡献，答案加上 $\sum \limits_{l=1}^i \sum\limits_{r=i}^{a_i-1} f_{l,r}$。
- 若 $i$ 是右括号同理。

我们考虑 $f_{l,r}$ 的组合意义，考察一组转移序列：

- $1 \le l_1 \le l_2 \le \cdots \le l_k \le l$。等价于 $x_1+x_2+\cdots+x_{k+1}=l-1$ 的非负整数解计数，方案数 $\dbinom{l-1+k}{k}$。
- $n \ge r_1 \ge r_2 \cdots \ge r_k \ge r$。同理可得方案数 $\dbinom{n-r+k}{k}$。
- 由于 $l \le r$ 恒成立，两部分相互独立。

从而
$$
\boxed{f_{l,r}=\binom{l+k-1}{k} \binom{n-r+k}{k}}
$$
对统计答案的部分，设 $g_{x,y}$ 为 $f_{l,r}$ 的二维前缀和，那么
$$
\begin{aligned}
g_{x,y}&=\sum_{l=1}^x \sum_{r=1}^y f_{l,r}\\
&=\sum_{l=1}^ x \binom{l+k-1}{k} \sum_{r=1}^y \binom{n-r+k}{k}\\
&= \binom{x+k}{k+1} \left(\binom{n+k}{k+1}-\binom{n+k-y}{k+1}\right)
\end{aligned}
$$
预处理组合数即可 $O(1)$ 计算单个 $g$，总复杂度 $O(n+k)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB584$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p7154--stripe-python', '[USACO20DEC] Sleeping Cows P · stripe-python', $AKB585$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P7154](https://www.luogu.com.cn/problem/P7154)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个左部点 $a_i$ 和 $n$ 个右部点 $b_i$。若 $a_i \le b_j$ 则连边 $i \to j$。
>
> 称二分图的一个匹配是极大的，当且仅当任意失配的左部点无法与失配的右部点匹配。对极大匹配计数。
>
> $n \le 3 \times 10^3$，1 秒，256 MB。

:::::success[题解]

刻画极大匹配的性质：

- 若左部点 $i$ 失配，则 $a_i \le b_j$ 的 $j$ 必须匹配。
- 若右部点 $j$ 失配，则 $a_i \le b_j$ 的 $i$ 必须匹配。

我们将 $a_i,b_j$ 扔到一个数组 $x$ 里升序排序，数值相同则左部点在前。此时，失配的右部点全部位于失配的左部点的左侧。

为叙述简便，下文称最终失配的点**被放弃**，最终得到匹配，但当前失配的点**被保留**。

考虑延迟钦定 DP：

- 设 $f_{0/1,i,j}$ 为满足下列条件时，合法匹配的数目：
  - 仅考虑 $x_1 \sim x_i$。
  - 当前有 $j$ 个保留的左部点失配。
  - 指示变量 $0/1$ 表示，$x_1 \sim x_i$ 中是否存在被放弃的左部点。
- 加入 $x_{i+1}$ 时对决策进行讨论：
  - 若 $i+1$ 是左部点：
    - 放弃 $x_{i+1}$，转移 $f_{0/1,i,j} \to f_{1,i+1,j}$。
    - 保留 $x_{i+1}$，转移 $f_{0/1,i,j} \to f_{0/1,i+1,j+1}$。
  - 若 $i+1$ 是右部点：
    - 令 $x_{i+1}$ 匹配某个左部点，转移 $j \times f_{0/1,i,j} \to f_{0/1,i,j-1}$。
    - 放弃 $x_{i+1}$，要求过去不存在放弃的左部点，转移 $f_{0,i,j} \to f_{0,i+1,j}$。
- DP 初值为 $f_{0,0,0}=1$。
- 答案为 $f_{0/1,2n,0}$。

复杂度 $O(n^2)$。本题给出了二分图匹配计数的延迟钦定 DP 套路。[代码](https://qoj.ac/submission/3015605)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB585$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p8321--stripe-python', '『JROI-4』沈阳大街 2 · stripe-python', $AKB586$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P8321](https://www.luogu.com.cn/problem/P8321)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定两个长为 $n$ 的序列 $a_i,b_i$，保证 $a_i$ 单调不降，$a_n \ge \min \limits_{i=1}^n b_i$。对 $1 \sim n$ 的排列 $p_i$，定义权值为
> $$
> \prod_{i=1}^n \min(a_i,b_{p_i})
> $$
> 每种排列等概率出现，求权值的期望。
>
> $n \le 5 \times 10^3$，1 秒，512 MB。

:::::success[题解]

考虑建 $n$ 阶完全二分图，边 $(i,j)$ 的边权为 $\min(a_i,b_j)$，一组匹配的权值为匹配边边权的乘积，问题即对所有完美匹配的权值求和。

将 $a_i,b_i$ 扔到同一个数组 $x$ 里降序排序。对于 $x_i \to x_j$ 的匹配，边权确定为 $x_j$。

考虑延迟钦定配对 DP：

- 设 $f_{i,j}$ 为满足下列条件时，合法匹配的权值和：

  - 仅考虑 $x_1 \sim x_i$。
  - 恰好匹配了 $j$ 对点。

- 注意到左右部点的地位相同，直接考察决策：

  - 令 $x_{i+1}$ 暂时失配，转移 $f_{i,j} \to f_{i+1,j}$。

  - 令 $x_{i+1}$ 与前缀中某个数匹配。预处理 $c_i$ 为 $x_1 \sim x_i$ 中与 $x_{i+1}$ 不同部的点数，转移 $f_{i,j} \times x_{i+1} \times (c_i-j) \to f_{i+1,j+1}$。

    系数 $x_{i+1}$ 是权值，$c_i-j$ 是选法数。

- DP 初值为 $f_{1,0}=1$。

- 答案为 $f_{2n,n}$，除以 $n!$ 得到期望。

复杂度 $O(n^2)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB586$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p8329--stripe-python', '[ZJOI2022] 树 · stripe-python', $AKB587$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P8329](https://www.luogu.com.cn/problem/P8329)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给出 $N$。对于每个 $n=2,3,\cdots,N$ 求出满足如下限制的有标号有根树对 $(T_1,T_2)$ 的数目：
>
> - $T_1$ 的根节点为 $1$，且 $f_i<i$。
> - $T_2$ 的根节点为 $n$，且 $f_i>i$。
> - $T_1,T_2$ 的叶子集合无交集且并集为全集。
>
> $N \le 500$，2 秒，1024 MB。

:::::success[题解]
记全集 $U=\{1,2,\cdots,n\}$，枚举 $T_1$ 的叶子集合 $S$ 和 $T_2$ 的叶子集合 $T$。记构造 $T_1$ 的方案数为 $f(S)$，构造 $T_2$ 的方案数为 $g(T)$。可以发现 $T_1,T_2$ 的构造是独立的，则答案为

$$
\sum_ {S \cap T =\varnothing \land S \cup T=U} f(S) g(T)
$$

考虑做 FMT 状物，对 $f,g$ 做超集反演。定义 $F(A)$ 为叶子集合 $\subseteq A$ 时构造 $T_1$ 的方案数，$G(B)$ 同理。答案转化为

$$
\begin{aligned}
&\sum_ {S \cap T =\varnothing \land S \cup T=U} \left(\sum_{S \subseteq A} (-1)^{|A|-|S|} F(A)\right) \left(\sum_{T \subseteq B} (-1)^{|B|-|S|} G(B)\right)\\
&=\sum_{A,B \subseteq U} F(A) G(B) \sum_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|-|S|} (-1)^{|B|-|U \setminus S|}\\
&=\sum_{A,B \subseteq U} F(A) G(B) \sum_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|+|B|-|U|}
\end{aligned}
$$

对于容斥系数 $\sum\limits_ {S \subseteq A \land (U \setminus S) \subseteq B} (-1)^{|A|+|B|-|U|}$，分析其组合意义：

- 根据 $S \subseteq A \land (U \setminus S) \subseteq B$ 知 $U \subseteq (A \cup B)$，也即 $A\cup B=U$。
- 当 $A \cup B=U$ 时，由二元容斥 $|A|+|B|-|U|=|A|+|B|-|A \cup B|=|A \cap B|$，故容斥系数为 $(-1)^{|A \cap B|}$ 乘上满足 $S \subseteq A \land (U \setminus S) \subseteq B$ 的 $S$ 数目。
- 考虑元素 $x \in U$，分析 $x$ 的贡献：
  - $x \in A \land x \notin B$：必有 $x \in S$，方案数 $1$。
  - $x \in B \land x \notin A$：必有 $x \in (U \setminus S)$，方案数 $1$。
  - $x \in A \land x \in B$：$x \in S$ 或者 $x \in (U \setminus S)$ 均可，方案数 $2$。
  - $x \notin A \land x \notin B$：由 $A \cup B=U$ 知这种情况不可能出现。
- 综上所述，容斥系数 $(-1)^{|A \cap B|} 2^{|A \cap B|}=\boxed{(-2)^{|A \cap B|}}$。

现在答案转化为 $\sum \limits_{A \cup B=U} (-2)^{|A \cap B|} F(A) G(B)$。接下来考虑推导 $F,G$ 的表达式，我们仍然从组合意义的角度来说明：

- 由 $F$ 的定义式 $F(A) =\sum \limits_{A \subseteq S} f(S)$ 知 $F$ 的组合意义是**钦定至少**，即钦定 $A$ 中的节点一定是叶子，其余节点不作要求。
- 考虑从小到大加入节点 $i=2,3,\cdots,n$：
  - 在无限制时，有 $i-1$ 个父亲可以选择。
  - 钦定后，在 $[1,i)$ 中且钦定为叶子的节点不能作为 $i$ 的父亲，方案数 $i-1-|A \cap [1,i)|$。
- $G$ 的推导同理，只是节点的加入顺序不同。

根据上述分析，$F,G$ 的表达式为

$$
F(A)=\sum_{i=1}^n \left(i-1-|A \cap [1,i)|\right)\\
G(B)=\sum_{i=1}^n \left(n-i-|B \cap (i,n]|\right)
$$

我们发现 $F,G$ 可以拆成每个 $i$ 的贡献之和，且这个贡献值只与 $A$ 的前缀信息和 $B$ 的后缀信息有关。考虑带着容斥系数 DP：

- 记 $f_{i,x,y}$ 为满足下列条件的 $(-2)^{|A \cap B| } F(A) G(B)$ 之和：
  - 已确定节点 $[1,i]$ 在 $A$ 中的分布情况，并将 $A \setminus [1,i]$ 归入集合 $B$。
  - $|A \cap [1,i)|=x$。
  - $|B \cap (i,n]|=y$。
- 转移考虑刷表，从 $f_{i,x,y} $ 转移到 $f_{i+1,x',y'}$。转移系数由贡献和容斥系数两部分组成：
  - 贡献系数：
    - $F$ 的系数为 $(i+1-1-|A \cap [1,i]|)=i-x$。
    - $G$ 的系数为 $n-(i+1)-|B \cap (i+1,n]|$，即 $n-i-1-y'$。
    - 总系数 $(i-x)(n-i-1-y')$。
  - 容斥系数：根据 $|A \cup B|$ 的奇偶性变化确定。
- 讨论 $i+1$ 的归属：
  - 当 $i +1 \in (A \setminus B)$ 时：
    - $x'=x+1$ 且 $y'=y$。
    - $|A \cup B|$ 不变，转移系数 $1 \times (i-x) \times (n-i-1-y)$。
  - 当 $i+1 \in (B \setminus A)$ 时：
    - $x'=x$ 且 $y'=y-1$。
    - $|A \cup B|$ 不变，转移系数 $1 \times (i-x) \times (n-i-y)$。
  - 当 $i+1 \in (A \cap B)$ 时：
    - $x'=x+1$ 且 $y'=y-1$。
    - $|A \cup B|$ 增加 $1$，转移系数 $-2 \times (i-x)\times (n-i-y)$。
- DP 初值为 $f_{0,0,y}=1$，注意在转移时特判 $i=0$ 和 $i=n-1$ 的情形。
- 答案为 $\sum \limits_{x=0}^n f_{n,x,0}$。

在外层枚举 $n$，做一次 DP 的复杂度为 $O(n^3)$，总复杂度 $O(N^4)$，可以获得 [60 分](https://www.luogu.com.cn/record/278852527)。这个做法的问题在于，贡献系数依赖 $n$ 导致不枚举 $n$ 难以转移。

考虑记 $z=n-i-y$，然后将 DP 状态改写为 $f_{i,x,z}$，此时贡献系数简化为 $(i-x)z'$，与 $n$ 无关。

枚举 $i$ 时直接对所有 $f_{i,x,z}$ 做一轮转移。由于 $i=n-1$ 无法直接特判，考虑在计算答案时手动模拟最后一轮的转移，这样即可求出所有 $n$ 的答案。

复杂度 $O(N^3)$。[代码](https://qoj.ac/submission/2887248)。
:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB587$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-luogu-p9131--stripe-python', '[USACO23FEB] Problem Setting P · stripe-python', $AKB588$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P9131](https://www.luogu.com.cn/problem/P9131)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个集合 $S_i \subseteq [0,m)$。对满足 $S_{i_1} \subseteq S_{i_2}  \subseteq \cdots \subseteq S_{i_k}$ 的下标序列 $i_1 \sim i_k$ 计数。
>
> $n \le 10^5$，$m \le 20$，2 秒，512 MB。

:::::success[题解]

设 $f_S$ 表示以 $S$ 结尾的方案数。将相同集合缩起来，转移
$$
f_S \gets \left(\sum_{i=1}^k \binom{k}{i}i!\right)\sum_{T \subset S} f_T
$$
转移系数 $h_S=\sum\limits_{i=1}^k \binom{k}{i}i!$ 是内部选法数，其中 $k$ 是 $S$ 的出现次数。

直接枚举子集，复杂度 $O(3^m)$ 无法通过，[代码](https://qoj.ac/submission/3139426)。

转移 $f_S \gets h_S \sum \limits_{T \subset S} f_T$ 是**半在线 FMT**。按 $|S|$ 分层枚举，每层必然由之前的层贡献，做 $m$ 次 FMT 可以做到 $O(m^2 2^m)$。

下面介绍 $O(m2^m)$ 的算法。维护辅助数组
$$
g_{k,S}=\sum_{T \subseteq S} [T \cap [k,m)=S \cap [k,m)] f_T
$$
用人话说，$T$ 与 $S$ 在高 $k$ 位上完全相同，低于 $k$ 的数值不受限制。则 $g$ 满足逐维递推
$$
g_{k+1,S} = \left\{\begin{matrix}
g_{k,S} & k\notin S \\
g_{k,S}+g_{k,S \setminus \{k\}} & k\in S
\end{matrix}\right.
$$
边界 $g_{0,S}=f_S$。枚举并钦定 $i=\max (S \setminus T)$，则 $S$ 与 $T$ 的高 $i$ 位相同且低位无限制。按 $\max (S \setminus T)$ 分类不重不漏，于是
$$
\sum \limits_{T \subset S} f_T=\sum_{i \in S} g_{i, S \setminus \{i\}}
$$
计算完 $f$ 后立刻更新 $g$，枚举 $k$ 并递推即可。 

时空复杂度 $O(m2^m)$。[代码](https://qoj.ac/submission/3139589)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB588$, '数学', array['题解'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-p17555-construction-master', 'P17555 「WWOI R4」构造大师 — 模3分类与双射构造', $AKB589$## 题目描述

给定正整数 $n, k$（$1 \le k \le n-1$，$n$ 为奇数），构造两个数组 $a_1, a_2, \dots, a_n$ 和 $b_1, b_2, \dots, b_n$，使得三个集合：

$$
\begin{aligned}
S_1 &= \{(a_i + a_{i+1}) \bmod 3n \mid 1 \le i \le n\},\quad a_{n+1}=a_1 \\
S_2 &= \{(a_i + b_i) \bmod 3n \mid 1 \le i \le n\} \\
S_3 &= \{(b_i + b_{i+k}) \bmod 3n \mid 1 \le i \le n\},\quad b_{i+n}=b_i
\end{aligned}
$$

满足 $|S_1 \cup S_2 \cup S_3| = 3n$。

若不存在输出 `No`，否则输出 `Yes` 和两个数组。

### 输入格式

一行两个正整数 $n, k$。

### 输出格式

第一行 `Yes` 或 `No`。
第二行 $n$ 个整数表示数组 $a$。
第三行 $n$ 个整数表示数组 $b$。

---

### 数据范围

- $3 \le n \le 10^6$，且 $n$ 为奇数
- $1 \le k \le n-1$
- 本题采用捆绑测试：$n \le 7$ 占 20 分，$k = 1$ 占 30 分，无特殊性质占 50 分
- $a_i, b_i$ 可输出 $-10^9 \sim 10^9$ 范围内的整数；多种合法答案输出任意一种即可

## 样例

> 本题原题**未提供样例**。以下示例由本文档自造，并已校验 $|S_1 \cup S_2 \cup S_3| = 3n$ 且所有整数均在 $-10^9 \sim 10^9$ 内。

### 样例输入

```
3 1
```

### 样例输出

```
Yes
0 3 6
1 4 7
```

**校验**：$n = 3$，$k = 1$，$3n = 9$。

- $S_1 = \{(0+3), (3+6), (6+0)\} \bmod 9 = \{3, 0, 6\}$
- $S_2 = \{(0+1), (3+4), (6+7)\} \bmod 9 = \{1, 7, 4\}$
- $S_3 = \{(1+4), (4+7), (7+1)\} \bmod 9 = \{5, 2, 8\}$

三个集合互不相交，并集恰为 $\{0,1,\dots,8\}$，共 $9 = 3n$ 个元素，构造合法。

## 一、解题思路：核心洞察——并集达到 3n 的条件

模 $3n$ 一共有 $3n$ 个剩余类，而每个集合 $S_1, S_2, S_3$ 最多只有 $n$ 个元素。

如果 $|S_1 \cup S_2 \cup S_3| = 3n$，那么必然：

1. **每个集合大小恰好为 $n$**（不能有重复元素）
2. **三个集合两两不交**
3. **合起来恰好覆盖全部 $3n$ 个剩余类**

> 直觉：三个各最多 $n$ 个元素的集合，要让并集达到 $3n$，必须各占三分之一且互不重叠。

---

## 二、按模 3 自然三分

模 $3n$ 的所有剩余类，按模 $3$ 的余数恰好分成三类，每类正好 $n$ 个：

| 类别 | 元素 | 个数 |
|---|---|---|
| 余 0 | $0, 3, 6, \dots, 3n-3$ | $n$ |
| 余 1 | $1, 4, 7, \dots, 3n-2$ | $n$ |
| 余 2 | $2, 5, 8, \dots, 3n-1$ | $n$ |

**构造目标**：让 $S_1$ 占满余 $0$ 类，$S_2$ 占满余 $1$ 类，$S_3$ 占满余 $2$ 类。

这样自然两两不交，且并集大小恰好 $3n$。

---

## 三、构造 a 数组：让 S₁ 占满余 0 类

### 3.1 约束分析

$S_1 = \{(a_i + a_{i+1}) \bmod 3n\}$。

要让 $S_1$ 全部落在余 $0$ 类，必须对所有 $i$：

$$a_i + a_{i+1} \equiv 0 \pmod{3}$$

即：

$$a_{i+1} \equiv -a_i \pmod{3}$$

### 3.2 推导出全部 a_i 同余

$$a_{i+2} \equiv -a_{i+1} \equiv a_i \pmod{3}$$

每隔两个位置，模 3 余数相同。因为 $n$ 是奇数，从任意位置出发每次加 $2$，可以走遍所有位置。因此**所有 $a_i$ 模 3 同余**。

设 $a_i \equiv r \pmod{3}$，则相邻和模 3 为 $2r$。要让它等于 $0$，必须 $r = 0$。

**结论：所有 $a_i$ 都必须是 3 的倍数。**

### 3.3 具体构造

取最简单的形式：

$$a_i = 3(i-1),\quad i = 1, 2, \dots, n$$

即 $a = (0, 3, 6, \dots, 3n-3)$。

验证 $S_1$：

- 对 $i = 1, \dots, n-1$：$a_i + a_{i+1} = 3(i-1) + 3i = 3(2i-1)$
- 对 $i = n$：$a_n + a_1 = 3(n-1) + 0 = 3(n-1)$

### 3.4 为什么恰好占满余 0 类

因为 $n$ 是奇数，$2$ 与 $n$ 互质，所以映射 $i \mapsto 2i-1 \pmod{n}$ 是**双射**（取遍 $0, 1, \dots, n-1$ 的所有值）。

因此 $S_1 = \{3 \cdot 0, 3 \cdot 1, \dots, 3 \cdot (n-1)\}$，恰好占满余 0 类的 $n$ 个元素。

---

## 四、构造 b 数组：让 S₂ 占满余 1 类

### 4.1 约束分析

$S_2 = \{(a_i + b_i) \bmod 3n\}$。

$a_i$ 都是 3 的倍数，所以 $a_i + b_i \equiv b_i \pmod{3}$。

要让 $S_2$ 全部落在余 1 类，只需：

$$b_i \equiv 1 \pmod{3}$$

### 4.2 具体构造

取对称形式：

$$b_i = 3(i-1) + 1,\quad i = 1, 2, \dots, n$$

即 $b = (1, 4, 7, \dots, 3n-2)$。

验证 $S_2$：

$$a_i + b_i = 3(i-1) + \bigl(3(i-1) + 1\bigr) = 6(i-1) + 1 = 3 \cdot 2(i-1) + 1$$

同样，因为 $n$ 是奇数，$i \mapsto 2(i-1) \pmod{n}$ 是双射，所以 $S_2$ 恰好取遍 $1, 4, 7, \dots, 3n-2$，占满余 1 类。

---

## 五、验证 S₃：自动占满余 2 类

### 5.1 模 3 验证

$b_i \equiv 1 \pmod{3}$，所以：

$$b_i + b_{i+k} \equiv 1 + 1 = 2 \pmod{3}$$

$S_3$ 的所有元素都落在余 2 类。

### 5.2 双射性验证

把 $b_i = 3(i-1) + 1$ 代入：

$$
\begin{aligned}
b_i + b_{i+k}
&= 3(i-1) + 1 + 3\bigl((i+k-1) \bmod n\bigr) + 1 \\
&= 3\Bigl((i-1) + \bigl((i+k-1) \bmod n\bigr)\Bigr) + 2
\end{aligned}
$$

模 $n$ 看括号里的内容：

$$(i-1) + (i+k-1) = 2i + k - 2 \pmod{n}$$

这仍是 $i$ 的仿射函数。因为 $n$ 是奇数，$2$ 与 $n$ 互质，映射仍是双射。

因此 $S_3$ 恰好取遍 $2, 5, 8, \dots, 3n-1$，占满余 2 类。

---

## 六、最终结论

$$
\begin{aligned}
S_1 &= \{0, 3, 6, \dots, 3n-3\} \quad \text{（余 0 类，共 $n$ 个）} \\
S_2 &= \{1, 4, 7, \dots, 3n-2\} \quad \text{（余 1 类，共 $n$ 个）} \\
S_3 &= \{2, 5, 8, \dots, 3n-1\} \quad \text{（余 2 类，共 $n$ 个）}
\end{aligned}
$$

三者两两不交，且并集恰好为模 $3n$ 的全部剩余类。

**答案恒为 Yes**，对任意奇数 $n$ 和任意 $1 \le k \le n-1$ 都有解。

$k$ 的值不影响构造！它在 $S_3$ 中只是常数平移，不会破坏双射性。

---

## 七、代码解析

### 读入与直接输出 YES

```cpp
#include<bits/stdc++.h>
using namespace std;
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    
    int n, k;
    cin >> n >> k;
    
    cout << "YES\n";
    
    
```

- 读入 $n,k$ 后**直接输出 YES**——因为下面的构造总能把并集铺满 $0..3n-1$。
- `k` 读入但完全不用：答案与 $k$ 无关，这是本题最反直觉的一点。

### 构造 a、b 数组

```cpp
// a_i = 3 * i  (0-indexed)
    for (int i = 0; i < n; i++) cout << 3 * i << ' ';
    cout << '\n';
    
    // b_i = 3 * i + 1  (0-indexed)
    for (int i = 0; i < n; i++) cout << i * 3 + 1 << ' ';
    
    return 0;
}
```

- $a_i = 3i$ 占满余 $0$ 类，$b_i = 3i+1$ 占满余 $1$ 类；两者的 $+$ 运算自动覆盖余 $2$ 类（$S_3$），并集恰为 $[0,3n-1]$。
- 代码极其简洁——核心是数学推导，代码只是输出公式结果。

## 八、复杂度分析

| 维度 | 复杂度 |
|---|---|
| 时间 | $O(n)$（输出两个数组） |
| 空间 | $O(1)$（无需额外空间） |

---

## 九、关键思想总结

> **一句话**：把模 $3n$ 的剩余类按模 $3$ 分成三份，让三个集合各占一份，用 $a_i=3(i-1)$ 和 $b_i=3(i-1)+1$ 的线性构造保证每份恰好填满。
>
> 三层思维跳跃：
> 1. **并集条件 → 三分**：$|S_1 \cup S_2 \cup S_3| = 3n$ 必然推出各占 $n$ 个且不交
> 2. **模 3 分类**：最自然的三分方式是按模 3 余数分
> 3. **双射保证全覆盖**：$n$ 是奇数 $\Rightarrow 2$ 与 $n$ 互质 $\Rightarrow$ 仿射映射是双射 $\Rightarrow$ 每类恰好取遍 $n$ 个元素
>
> 这是一道非常典型的「构造题」：答案形式极其简单，但找到答案需要深刻的数学洞察。核心技巧是**利用结构对称性（模 3 分类）+ 双射性（数论保证）**来完成构造。

---

## 十、常见陷阱与注意事项

1. **误以为 k 有影响**：$k$ 在 $S_3$ 中只是常数平移，不影响双射性，对构造完全无关
2. **忽略 n 为奇数的条件**：如果 $n$ 是偶数，$2$ 与 $n$ 不互质，映射不是双射，此构造失效
3. **模 3n vs 模 3**：构造用模 3 控制分类，用模 n 的双射保证每类恰好填满，两层嵌套的模结构是关键
4. **循环边界**：$S_1$ 有 $a_{n+1}=a_1$ 的循环条件，$S_3$ 有 $b_{i+n}=b_i$ 的循环条件，都需要验证环回的情况
5. **不要输出 No**：题目中 $n$ 一定是奇数且 $1 \le k \le n-1$，恒有解，直接输出 Yes$AKB589$, '数学', array['构造', '数学', '模运算', '双射', '数论', '奇偶性'], null, '普及+/提高−', 'problem'),
('world-needs-sunday', 'col-prob-p17611-xor-equation', 'P17611 Not a Polynomial Equation — 异或方程的高低位分离', $AKB590$## 题目描述

给定 $n,m$ 以及 $n+1$ 个整数 $a_0, a_1, \dots, a_n$。

求方程：

$$a_0 + a_1 x + a_2 (x \oplus 2) + a_3 (x \oplus 3) + \cdots + a_n (x \oplus n) = 0$$

的**任意一个**位于 $[1, m]$ 范围内的整数解；若不存在，输出 $-1$。

其中 $\oplus$ 表示按位异或。

### 输入格式

第一行一个正整数 $T$，表示数据组数。

下面 $T$ 行，每行共 $n+3$ 个整数，依次为 $n, m, a_0, a_1, \dots, a_n$。

### 输出格式

共 $T$ 行，每行输出一个不超过对应的 $m$ 的正整数或 $-1$。

### 数据范围与约定

本题开启捆绑测试。

| 子任务 | 分值 | $n \le$ | $m \le$ | $\lvert a_i \rvert \le$ | $T$ |
|--------|------|---------|---------|----------------------|-----|
| 1 | 5 | 1 | $10^3$ | 100 | $=1$ |
| 2 | 15 | 10 | | | |
| 3 | 20 | $10^9$ | $\le 10^3$ | | |
| 4 | 25 | 50 | $10^6$ | | |
| 5 | 35 | 100 | $2^{31}-1$ | $10^{18}$ | $10^3$ |

对于所有的数据：$0 \le n \le 100$，$\lvert a_i \rvert \le 10^{18}$，$1 \le m \le 2^{31}-1$，$1 \le T \le 10^3$。

---

## 样例

### 样例 1

**输入：**
```
2
2 10 1 -2 1
1 5 0 1
```

**输出：**
```
1
0
```

> 注意：输出的 x 必须在 [1, m] 范围内，所以第二组答案不是 0，而是 -1。

---

## 一、解题思路：题意分析与复杂度瓶颈

### 题目抽象

求 $x \in [1, m]$，使得：

$$\sum_{i=0}^{n} a_i \cdot (x \oplus i) = 0$$

其中 $x \oplus 0 = x$（这一项就是 $a_0 \cdot x$）。

### 矛盾点

| 方面 | 情况 |
|------|------|
| 暴力枚举 x | $O(T \cdot m \cdot n) \approx 10^3 \times 2^{31} \times 100 \approx 2 \times 10^{14}$，绝对超时 |
| 直接解方程 | 异或运算打乱了多项式结构，无法用代数方法直接化简 |

### 破局点：抓住 $n$ 很小的特点

注意到 $n \le 100$，而 $2^7 = 128 > 100$。

这意味着：**所有 $i \in [0, n]$ 在二进制下最多占据低 7 位**。

> 这是整个题目的关键突破口。$n$ 很小 → $i$ 的位数很少 → 可以做高低位分离。

---

## 二、核心思想：高低位分离

### 拆分方式

令 $x = 128k + y$，其中：

- $k$：高位部分（$k \ge 0$，二进制从第 7 位开始）
- $y$：低 7 位部分（$0 \le y < 128$）

### 为什么异或可以这样拆？

异或（XOR）是**按位运算，不产生进位**。

- $128k$ 在二进制下低 7 位全是 0（因为 $128 = 2^7$）
- $i \le 100 < 128$ 在二进制下高位置（第 7 位及以上）全是 0

两者的二进制位在空间上**完全错开，互不干扰**。

因此得到**核心等式**：

$$x \oplus i = (128k + y) \oplus i = 128k + (y \oplus i)$$

> 理解：高位部分 $128k$ 和 $i$ 没有重叠的位，所以异或后高位不变；低位部分 $y$ 和 $i$ 正常异或。

---

## 三、方程化简

将 $x \oplus i = 128k + (y \oplus i)$ 代入原方程：

$$
\begin{aligned}
a_0 + a_1(128k + y) + a_2[128k + (y \oplus 2)] + \cdots + a_n[128k + (y \oplus n)] &= 0 \\
128k \cdot (a_1 + a_2 + \cdots + a_n) + \left[a_0 + a_1 y + a_2 (y \oplus 2) + \cdots + a_n (y \oplus n)\right] &= 0
\end{aligned}
$$

整理为：

$$\boldsymbol{128k \cdot S + F(y) = 0}$$

其中：

| 符号 | 定义 | 说明 |
|------|------|------|
| $S$ | $a_1 + a_2 + \cdots + a_n$ | 所有非零次项系数之和（**不包含 $a_0$**） |
| $F(y)$ | $a_0 + \sum_{i=1}^{n} a_i \cdot (y \oplus i)$ | 当低 7 位取 $y$ 时的"常数项" |

### 关键点

- $y$ 只有 128 种可能（0 ~ 127），可以**全部枚举**
- 对每个 $y$，$F(y)$ 是已知常数，方程变成关于 $k$ 的**一元一次方程**
- 解出 $k$ 后，$x = 128k + y$，检查是否在 $[1, m]$ 范围内

---

## 四、分类讨论求解

### 情况 1：$S = 0$

方程变为 $0 \cdot k + F(y) = 0$，即 $F(y) = 0$。

- 若 $F(y) \neq 0$：无解，跳过这个 $y$
- 若 $F(y) = 0$：$k$ 可以取任意非负整数
  - 为了找一个合法解，取最小的 $x$：
    - 如果 $y \ge 1$，取 $k = 0$，则 $x = y$
    - 如果 $y = 0$，取 $k = 1$，则 $x = 128$（因为 $x$ 必须 $\ge 1$）
  - 判断 $x$ 是否在 $[1, m]$ 范围内

### 情况 2：$S \neq 0$

解出 $k$：

$$k = \frac{-F(y)}{128 \cdot S}$$

需要满足两个条件：

1. **整除条件**：$-F(y)$ 必须能被 $128 \cdot S$ 整除（$k$ 必须是非负整数）
2. **范围条件**：$x = 128k + y$ 必须满足 $1 \le x \le m$

遍历所有 128 个 $y$，找到第一个合法的 $x$ 即可。

> 注意：题目只要求"任意一个"解，所以找到第一个就可以返回。

---

## 五、算法流程

```
对每组测试数据：
  1. 读入 n, m, a[0..n]
  2. 计算 S = a[1] + a[2] + ... + a[n]
  3. 特判 n == 0：
     - 若 a[0] == 0，输出 1（任意 x 都满足，但最小正整数是 1）
     - 否则输出 -1
  4. 预处理 F(y)：枚举 y ∈ [0, 127]
     F(y) = a[0] + a[1]*y + a[2]*(y^2) + ... + a[n]*(y^n)
  5. 分类讨论求解：
     - S == 0：找 F(y) == 0 的 y，计算最小合法 x
     - S != 0：找 F(y) 能被 128*S 整除的 y，解出 k 验证范围
  6. 找到解输出，否则输出 -1
```

---

## 六、逐行代码解析

### 头文件

```cpp
#include<bits/stdc++.h>
using namespace std;
```
- 引入全部标准库。

### check 函数签名

```cpp
__int128 check(const vector<__int128>& dp, int m, int n, __int128 sum)
{
```
- `check` 函数：根据预处理的 dp 数组（即 F(y)）和 sum（即 S），求解合法的 x
- 返回值类型是 `__int128`，因为中间结果可能很大
- 参数：
  - `dp`：大小为 128 的数组，`dp[i] = F(i)`
  - `m`：x 的上界
  - `n`：方程的阶数（本题中未在函数内使用，作为参数保留）
  - `sum`：系数和 S

### check：S = 0 分支

```cpp
    if (sum == 0)
    {
        for (int i = 0; i < 128; i++)
        {
            if (dp[i] == 0)
            {
                __int128 ans = i;
                if (ans < 1) ans += 128;
                if (ans >= 1 && ans <= m) return ans;
            }
        }
        return -1;
    }
```
- **情况 1：S = 0**
- 遍历所有 128 个 y 值（即 i）
- 如果 `dp[i] == 0`（即 F(y) = 0）：
  - `ans = i`：先尝试 k = 0，即 x = y
  - 如果 `ans < 1`（即 y = 0，x 必须 ≥ 1），加 128 取 k = 1
  - 检查是否在 [1, m] 范围内，合法则直接返回
- 遍历完都没找到，返回 -1

### check：S ≠ 0 分支

```cpp
    else
    {
        for (int i = 0; i < 128; i++)
        {
            if ((-dp[i]) % (128 * sum) == 0)
            {
                __int128 ans = -dp[i] / sum + i;
                if (ans >= 1 && ans <= m)
                {
                    return ans;
                }
            }
        }
        return -1;
    }
}
```
- **情况 2：S ≠ 0**
- 遍历所有 128 个 y 值
- 判断整除：`(-dp[i]) % (128 * sum) == 0`
  - 即 $-F(y)$ 能被 $128S$ 整除，保证 $k$ 是整数
- 计算 `ans = -dp[i] / sum + i`
  - 注意：这里是 `-dp[i] / sum`，不是 `(-dp[i]) / (128 * sum) * 128`
  - 推导：$k = \frac{-F(y)}{128S}$，所以 $128k = \frac{-F(y)}{S}$
  - 因此 $x = 128k + y = \frac{-F(y)}{S} + y$
  - 这样写更简洁，且少一次乘法
- 检查 x 是否在 [1, m] 范围内，合法则返回
- 遍历完都没找到，返回 -1

### write：__int128 输出

```cpp
inline void write(__int128 x)
{
    static char buf[42];
    int p = 0;
    if (x < 0) { putchar('-'); x = -x; }
    if (x == 0) buf[p++] = '0';
    while (x) { buf[p++] = x % 10 + 48; x /= 10; }
    while (p--) putchar(buf[p]);
    putchar('\n');
}
```
- `__int128` 的输出函数（C++ 标准库不支持直接输出 __int128）
- 用 `putchar` 逐位输出
- 处理负数和零的特殊情况
- `static char buf[42]`：静态缓冲区，42 位足够存下 __int128 的最大值

### main：输入输出加速与多测

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int t;
    cin >> t;
    while (t--)
    {
```
- 输入输出加速
- 多组测试数据

### 读入 n、m 与变量声明

```cpp
        int n, m;
        __int128 sum = 0;
        cin >> n >> m;
        vector<long long> A(n + 1);
        vector<__int128> dp(128, 0);
```
- `n, m`：用 int 足够（n ≤ 100，m ≤ 2^31-1 但 m 是 int 存不下... 应该用 long long）
- `sum`：系数和 S，用 __int128 防止溢出
- `A`：系数数组，用 long long 读入（a_i 最大 10^18，long long 刚好）
- `dp`：F(y) 数组，大小 128，用 __int128

### 读入系数并求 sum

```cpp
        for (int i = 0; i <= n; i++)
        {
            cin >> A[i];
            if (i != 0) sum += A[i];
        }
```
- 读入系数
- 同时计算 sum = a_1 + a_2 + ... + a_n（不包含 a_0）

### n = 0 特判

```cpp
        if (n == 0)
        {
            if (A[0] == 0) write(1);
            else write(-1);
        }
```
- 特判 n = 0 的情况
- 方程变为 a_0 = 0
  - 若 a_0 = 0：任意 x 都满足，输出最小正整数 1
  - 若 a_0 ≠ 0：无解，输出 -1
- **为什么要特判？** 因为后面的代码有 `A[1] * i`，n=0 时 A[1] 越界

### 预处理 F(y) 并调用 check

```cpp
        else
        {
            for (int i = 0; i < 128; i++)
            {
                dp[i] += A[0];
                dp[i] += (__int128)A[1] * i;
                for (int j = 2; j <= n; j++)
                {
                    dp[i] += (__int128)A[j] * (i ^ j);
                }
            }

            write(check(dp, m, n, sum));
        }
    }
    return 0;
}
```
- 预处理 F(y)，对每个 y（即 i）：
  - 加上常数项 $a_0$
  - 加上 $a_1 \cdot y$：题目中 $a_1$ 对应的是 $x$（不是 $x \oplus 1$），代入 $x = 128k + y$ 得 $a_1 x = 128k \cdot a_1 + a_1 y$，因此 F(y) 中这一项为 $a_1 \cdot y$
  - 从 $a_2$ 到 $a_n$：$a_j \cdot (y \oplus j)$，即第 $j$ 项系数乘以「y 异或 j」

---

## 七、复杂度分析

### 时间复杂度：$O(T \cdot 128 \cdot n)$

- 每组数据预处理 F(y)：$128 \times n$ 次运算
- check 函数：128 次循环
- 总运算量：$T \times 128 \times n \approx 10^3 \times 128 \times 100 = 1.28 \times 10^7$
- 远远小于 $10^8$，轻松通过

### 空间复杂度：$O(n + 128)$

- 系数数组 A：$O(n)$
- dp 数组：$O(128) = O(1)$
- 空间非常优秀

---

## 八、常见陷阱与注意事项

### 1. 数据类型溢出（最致命！）

$|a_i| \le 10^{18}$，$n \le 100$，$y \le 127$。

计算 $F(y)$ 时，单项最大值约为 $10^{18} \times 128 \approx 1.28 \times 10^{20}$，总和可能达到 $10^{22}$。

而 `long long` 的上限只有约 $9 \times 10^{18}$，**完全不够用**。

**必须使用 `__int128`** 来存储 dp 数组和 sum。

### 2. 乘法时的强制类型转换

```cpp
// 错误：A[j] 是 long long，(i ^ j) 是 int，乘法在 long long 下进行，会溢出
dp[i] += A[j] * (i ^ j);

// 正确：先把 A[j] 转为 __int128，再乘
dp[i] += (__int128)A[j] * (i ^ j);
```

C++ 的乘法运算在**赋值前**就完成了。如果两个操作数都是 long long，结果也是 long long（已经溢出了），再赋值给 __int128 也救不回来。

### 3. 第一项 a₁x 的特殊性

题目中 $a_1$ 对应的是 $x$，不是 $x \oplus 1$。

- $a_1 x$ 展开后是 $a_1 (128k + y) = 128k \cdot a_1 + a_1 y$
- 所以 F(y) 中是 $a_1 \cdot y$，不是 $a_1 \cdot (y \oplus 1)$

不要想当然地以为所有项都是 $a_i (x \oplus i)$，要看清题目！

### 4. n = 0 的边界情况

当 n = 0 时，方程只有 $a_0 = 0$。

- 代码中如果没有特判，后面的 `A[1] * i` 会数组越界（RE）
- 必须单独处理 n = 0 的情况

### 5. S 的定义不包含 a₀

$S = a_1 + a_2 + \cdots + a_n$，**不包含 $a_0$**。

因为原方程中只有 $a_1 x, a_2(x \oplus 2), \dots$ 这些项含有 $x$（即含有 $128k$），$a_0$ 是纯常数项。

如果不小心把 $a_0$ 加进去了，结果会全错。

### 6. 负数除法与取模

C++ 中负数除法是**向零取整**，负数取模的结果符号与被除数一致。

但用 `(-dp[i]) % (128 * sum) == 0` 判断整除是安全的：
- 只要余数为 0，不管正负，都说明能整除
- 算出的 x 可能是负数，用 `if (x >= 1 && x <= m)` 过滤即可

### 7. __int128 的输入输出

- `cin` / `cout` **不支持** `__int128`
- 输入：用 `long long` 读入，再赋值给 `__int128`（因为 $a_i \le 10^{18}$，long long 刚好能存）
- 输出：手写 `write` 函数，用 `putchar` 逐位输出
- 本题答案 x ≤ 2^31-1，其实可以直接强转成 `long long` 再输出，但写个通用的 write 函数更稳妥

### 8. 编译器兼容性

- Visual Studio (MSVC) **不支持** `__int128`
- 本地调试请使用 MinGW (GCC) 或 Clang
- 在线评测（洛谷、Codeforces 等）都使用 GCC，支持 __int128

---

## 九、核心要点总结

1. **题型特征**：范围极大（$m \sim 2^{31}$）+ 小参数（$n \le 100$）+ 按位运算（异或）
2. **核心技巧**：**高低位分离** — 找到比 n 大的最小 2 的幂（128），把 x 拆成高位和低位
3. **关键等式**：$x \oplus i = 128k + (y \oplus i)$（当 $i < 128$ 时）
4. **方程化简**：原方程 → $128k \cdot S + F(y) = 0$，枚举 y 解一元一次方程
5. **分类讨论**：S = 0 时看 F(y) 是否为 0；S ≠ 0 时解 k 并验证整除和范围
6. **数据类型**：必须用 `__int128`，乘法前要强制类型转换
7. **边界特判**：n = 0 单独处理，防止数组越界$AKB590$, '数学', array['数学', '位运算', '异或', '高低位分离', '枚举', '__int128'], null, '普及+/提高−', 'problem'),
('world-needs-sunday', 'col-prob-p5657-gray-code', 'P5657 [CSP-S 2019] 格雷码 — 递归构造与位运算公式', $AKB591$## 题目描述

通常，人们习惯将所有 $n$ 位二进制串按照字典序排列，例如所有 2 位二进制串按字典序从小到大排列为：00，01，10，11。

**格雷码（Gray Code）** 是一种特殊的 $n$ 位二进制串排列法，它要求**相邻的两个二进制串间恰好有一位不同**，特别地，第一个串与最后一个串也算作相邻。

所有 2 位二进制串按格雷码排列的一个例子为：00，01，11，10。

$n$ 位格雷码不止一种，下面给出其中一种格雷码的**生成算法**：

1. 1 位格雷码由两个 1 位二进制串组成，顺序为：`0`，`1`。
2. $n+1$ 位格雷码的前 $2^n$ 个二进制串，可以由依此算法生成的 $n$ 位格雷码（总共 $2^n$ 个 $n$ 位二进制串）按顺序排列，再在每个串前加一个前缀 `0` 构成。
3. $n+1$ 位格雷码的后 $2^n$ 个二进制串，可以由依此算法生成的 $n$ 位格雷码（总共 $2^n$ 个 $n$ 位二进制串）按**逆序**排列，再在每个串前加一个前缀 `1` 构成。

综上，$n+1$ 位格雷码，由 $n$ 位格雷码的 $2^n$ 个二进制串按顺序排列再加前缀 `0`，和按逆序排列再加前缀 `1` 构成，共 $2^{n+1}$ 个二进制串。

另外，对于 $n$ 位格雷码中的 $2^n$ 个二进制串，我们按上述算法得到的排列顺序将它们从 $0 \sim 2^n - 1$ 编号。

按该算法，2 位格雷码可以这样推出：

- 已知 1 位格雷码为 `0`，`1`。
- 前两个格雷码为 `00`，`01`。后两个格雷码为 `11`，`10`。
- 合并得到 `00`，`01`，`11`，`10`，编号依次为 0 ~ 3。

同理，3 位格雷码可以这样推出：

- 已知 2 位格雷码为：`00`，`01`，`11`，`10`。
- 前四个格雷码为：`000`，`001`，`011`，`010`。
- 后四个格雷码为：`110`，`111`，`101`，`100`。
- 合并得到：`000`，`001`，`011`，`010`，`110`，`111`，`101`，`100`，编号依次为 0 ~ 7。

现在给出 $n$，$k$，请你求出按上述算法生成的 $n$ 位格雷码中的 $k$ 号二进制串。

### 输入格式

仅一行两个整数 $n$，$k$，意义见题目描述。

### 输出格式

仅一行一个 $n$ 位二进制串表示答案。

### 数据范围

- 对于 $50\%$ 的数据：$n \le 10$
- 对于 $80\%$ 的数据：$k \le 5 \times 10^6$
- 对于 $95\%$ 的数据：$k \le 2^{63} - 1$
- 对于 $100\%$ 的数据：$1 \le n \le 64,\ 0 \le k < 2^n$

---

## 样例

### 样例 1

**输入：**
```
3 5
```

**输出：**
```
111
```

**解释：**
3 位格雷码第 5 号（从 0 开始）为 `111`。
序列：000(0), 001(1), 011(2), 010(3), 110(4), 111(5), 101(6), 100(7)

### 样例 2

**输入：**
```
2 3
```

**输出：**
```
10
```

---

## 一、解题思路：核心洞察——「左正右倒」的递归结构

题目已经明确给出了格雷码的生成算法，其核心可以用八个字概括：

> **左半正序，右半逆序**

以 3 位格雷码为例：

```
前半（前缀0）：000  001  011  010   ← 2位格雷码正序
后半（前缀1）：110  111  101  100   ← 2位格雷码逆序
```

这是一个典型的**递归分治**结构。要找第 $k$ 个格雷码，我们不需要生成全部 $2^n$ 个码，只需要从最高位开始，逐层判断 $k$ 在哪一半：

- 如果 $k$ 在**左半部分**（$k < 2^{n-1}$）：当前位是 `0`，低位编号不变（正序）
- 如果 $k$ 在**右半部分**（$k \ge 2^{n-1}$）：当前位是 `1`，低位编号需要**整体翻转**（逆序）

**关键问题**：右半部分「逆序」意味着低位编号如何变化？

对于 $n$ 位格雷码，右半部分的低位（$n-1$ 位）是左半部分的逆序。编号的对应关系为：

$$k' = (2^{n-1} - 1) - (k - 2^{n-1}) = 2^n - 1 - k$$

即：右半部分第 $m$ 个位置，对应左半部分第 $(2^{n-1}-1-m)$ 个位置。

---

## 二、解法一：递归实现

### 思路

根据上面的分析，我们可以直接写出递归函数：

- 从最高位开始，判断 $k$ 落在左半还是右半
- 左半：输出 `0`，递归处理剩余低位，$k$ 不变
- 右半：输出 `1`，递归处理剩余低位，$k$ 变为 $2^n - 1 - k$
- 当 $n = 0$ 时递归结束

### 递归代码

```cpp
#include <bits/stdc++.h>
using namespace std;

void dfs(int n, unsigned long long k) {
    if (n == 0) return;
    unsigned long long half = 1ULL << (n - 1);
    if (k < half) {
        cout << 0;
        dfs(n - 1, k);
    } else {
        cout << 1;
        dfs(n - 1, (half << 1) - 1 - k);
    }
}

int main() {
    int n;
    unsigned long long k;
    cin >> n >> k;
    dfs(n, k);
    return 0;
}
```

### 模拟验证（k = 5, n = 3）

| 层级 | half | k < half? | 输出 | 新的 k |
|------|------|-----------|------|--------|
| n=3  | 4    | 5 < 4? 否 | 1    | 8-1-5 = 2 |
| n=2  | 2    | 2 < 2? 否 | 1    | 4-1-2 = 1 |
| n=1  | 1    | 1 < 1? 否 | 1    | 2-1-1 = 0 |
| n=0  | —    | 结束     | —    | — |

输出：`111` ✓

---

## 三、解法二：迭代 + 状态传递（你写的版本）

### 从递推到迭代

递归虽然直观，但我们可以进一步发现规律：每次进入右半部分，低位的编号被翻转。这种翻转会逐层传递下去。

我们用变量 $t$ 记录**当前层的"基准状态"**（即：如果当前位是 0，应该输出什么）：

- 初始时 $t = 0$（最高位的基准是 0）
- 如果当前位 $k$ 的二进制是 `1`（在右半）：输出 $t \oplus 1$（翻转基准），然后更新 $t = 1$（下一层的基准变成 1）
- 如果当前位 $k$ 的二进制是 `0`（在左半）：输出 $t$（保持基准），然后更新 $t = 0$（下一层的基准变成 0）

### 状态传递表

| k 的当前位 | 输出 | 下一层的 t | 含义 |
|-----------|------|-----------|------|
| 1 | t ^ 1 | 1 | 进入右半，翻转输出；下一层基准变为 1 |
| 0 | t | 0 | 留在左半，原样输出；下一层基准变为 0 |

### 模拟验证（k = 5 = 101, n = 3）

| i (位) | k 的第 i 位 | 动作 | 输出位 | t 更新为 |
|--------|------------|------|--------|----------|
| 2 (最高位) | 1 | 翻转 t | 0 ^ 1 = **1** | 1 |
| 1 | 0 | 不翻转 | **1** | 0 |
| 0 (最低位) | 1 | 翻转 t | 0 ^ 1 = **1** | 1 |

输出：`111` ✓

---

## 四、解法三：位运算公式 $g = k \oplus (k \gg 1)$

### 神奇的公式

格雷码有一个著名的位运算公式：

$$g = k \oplus (k \gg 1)$$

即：**格雷码的第 $k$ 个值，等于 $k$ 与 $k$ 右移一位的异或**。

### 为什么是对的？

我们的迭代代码中，$t$ 始终保存着**上一位（更高一位）的值**：

- 当前位输出 = $t$（上一位的值）$\oplus$（当前位是否为 1）
- 这正好等价于：$g_i = k_{i+1} \oplus k_i$

从最高位到最低位逐位看：

| 格雷码的位 | 等于 |
|-----------|------|
| $g_{n-1}$ | $k_{n-1}$（最高位不变） |
| $g_{n-2}$ | $k_{n-1} \oplus k_{n-2}$ |
| $g_{n-3}$ | $k_{n-2} \oplus k_{n-3}$ |
| ... | ... |
| $g_0$ | $k_1 \oplus k_0$ |

这正是 $k \oplus (k \gg 1)$ 的逐位含义！

### 一行代码版本

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    unsigned long long n, k;
    cin >> n >> k;
    unsigned long long g = k ^ (k >> 1);
    // 从高位到低位输出 n 位
    for (int i = n - 1; i >= 0; i--) {
        cout << ((g >> i) & 1);
    }
    return 0;
}
```

> **注意**：当 $n = 64$ 时，$k$ 可能达到 $2^{64} - 1$，需要使用 `unsigned long long` 类型。

---

## 五、三种解法对比

| 解法 | 思路 | 代码量 | 时间 | 空间 | 直观性 |
|------|------|--------|------|------|--------|
| 递归 | 左正右倒，逐位判断 | 短 | $O(n)$ | $O(n)$ 栈 | ★★★★★ 最直观 |
| 迭代+状态传递 | 用 t 记录基准，逐位推进 | 中 | $O(n)$ | $O(1)$ | ★★★☆☆ 需理解 t 的含义 |
| 位运算公式 | $g = k \oplus (k \gg 1)$ | 最短 | $O(n)$ | $O(1)$ | ★☆☆☆☆ 公式需记忆 |

---

## 六、逐行代码解析

以下是你写的迭代版本代码的详细解析：

### 头文件

```cpp
#include<bits/stdc++.h>
using namespace std;
```
- 引入全部标准库头文件，使用标准命名空间。

### main 与输入输出加速

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
```
- 关闭 C++ 流与 C 流的同步，解除 cin 与 cout 的绑定，加速输入输出。
- 本题 $n \le 64$，输出最多 64 位，优化并非必须，但是好习惯。

### 变量声明

```cpp
    unsigned long long n, k, t = 0;
    cin >> n >> k;
```
- 定义变量：
  - `n`：格雷码的位数
  - `k`：要求的编号（第 $k$ 个格雷码）
  - `t`：状态变量，表示**上一位的值**（即当前位的"基准"），初始为 0
- 使用 `unsigned long long` 是因为 $n$ 可达 64，$k$ 最大为 $2^{64} - 1$，有符号 `long long` 只能到 $2^{63} - 1$。

### 逐位处理循环

```cpp
    for (int i = n - 1; i >= 0; i--)
    {
```
- 从最高位（第 $n-1$ 位）到最低位（第 0 位）逐位处理。
- 格雷码的输出顺序是从高位到低位，所以循环从高位开始。

### 构造掩码

```cpp
        unsigned long long j = ((unsigned long long)1 << i);
```
- 构造掩码：只有第 $i$ 位是 1，其余位是 0。
- `(unsigned long long)1` 确保移位在 64 位无符号整数上进行，避免溢出。

### k 的第 i 位为 1（右半）

```cpp
        if (k & j)
        {
            cout << (t ^ 1);
            t = 1;
        }
```
- 如果 $k$ 的第 $i$ 位是 1（在右半部分）：
  - 输出 `t ^ 1`：将基准翻转（因为右半部分是逆序的）
  - 更新 `t = 1`：下一位的基准变为 1

### k 的第 i 位为 0（左半）

```cpp
        else
        {
            cout << t;
            t = 0;
        }
    }
```
- 如果 $k$ 的第 $i$ 位是 0（在左半部分）：
  - 直接输出 `t`（保持基准不变，正序）
  - 更新 `t = 0`：下一位的基准变为 0

### 返回

```cpp
    return 0;
}
```

---

## 七、复杂度分析

### 时间复杂度：$O(n)$

- 循环从高位到低位共执行 $n$ 次
- 每次循环内只有位运算和输出操作，均为 $O(1)$
- 总时间复杂度为 $O(n)$

### 空间复杂度：$O(1)$

- 只使用了常数个变量（`n`, `k`, `t`, `i`, `j`）
- 递归解法的空间复杂度为 $O(n)$（递归栈深度）

---

## 八、常见陷阱与注意事项

### 1. 数据类型溢出（最重要！）

$n$ 可以达到 64，$k$ 最大为 $2^{64} - 1$，超出了有符号 `long long` 的范围（$2^{63} - 1$）。

- **必须使用 `unsigned long long`** 存储 $k$
- 移位时要注意：`1 << 63` 在 32 位 int 上是未定义行为，必须先转为 64 位类型

```cpp
// 错误：1 是 int，移位可能溢出
unsigned long long j = 1 << i;

// 正确：先转为 unsigned long long
unsigned long long j = (unsigned long long)1 << i;
// 或
unsigned long long j = 1ULL << i;
```

### 2. n = 64 时的特殊情况

当 $n = 64$ 时，$2^{64}$ 无法用任何 64 位整数表示（包括 `unsigned long long`）。

- 递归解法中计算 `half = 1ULL << (n-1)` 是安全的，因为 $n-1$ 最大为 63
- 但计算 `(half << 1) - 1` 时，当 n=64，`half << 1` 会溢出变为 0，再减 1 得到 `ULLONG_MAX`，恰好是 $2^{64} - 1$，结果正确（无符号整数的溢出是定义良好的模运算）

### 3. 位运算公式的简洁性

如果你能记住 $g = k \oplus (k \gg 1)$ 这个公式，代码会非常简洁。但建议同时理解递归构造的原理，这样即使忘记公式也能推导出来。

### 4. 输出位数

题目要求输出恰好 $n$ 位二进制串，即使高位是 0 也要输出。循环必须从 $n-1$ 位到 0 位，确保输出正好 $n$ 位。

### 5. 「逆序」的正确理解

右半部分是逆序，不是简单的按位取反。编号的对应关系是：

$$k' = 2^{n-1} - 1 - (k - 2^{n-1}) = 2^n - 1 - k$$

不要误以为只需要翻转最低位或做其他简化操作。

### 6. 递归与迭代的选择

- 递归代码更直观，容易写对
- 迭代代码效率略高（无栈开销），但需要理解状态传递
- 本题 $n \le 64$，递归深度最多 64，栈完全够用，两种方式均可
- 但位运算公式法是最优的，代码最短且效率最高

### 7. 格雷码与二进制的区别

| 编号 k | 二进制 | 格雷码 |
|--------|--------|--------|
| 0 | 000 | 000 |
| 1 | 001 | 001 |
| 2 | 010 | 011 |
| 3 | 011 | 010 |
| 4 | 100 | 110 |
| 5 | 101 | 111 |
| 6 | 110 | 101 |
| 7 | 111 | 100 |

注意观察：格雷码相邻两个数恰好只有一位不同，包括 7 和 0（首尾相连）。

---

## 九、核心要点总结

1. **格雷码生成**：左半正序加前缀 0，右半逆序加前缀 1
2. **递归思路**：判断 k 在哪一半，右半则翻转低位编号递归
3. **迭代思路**：用 `t` 记录上一位的值，当前位为 1 则翻转输出
4. **位运算公式**：$g = k \oplus (k \gg 1)$，一行搞定
5. **数据类型**：必须用 `unsigned long long`，小心 64 位溢出
6. **核心直觉**：「正倒交替」是理解格雷码递归构造的钥匙$AKB591$, '数学', array['格雷码', '数学', '位运算', '递归', '构造', 'CSP-S'], null, '普及−', 'problem'),
('world-needs-sunday', 'col-prob-particle-motion', '粒子运动（动量守恒模拟优化）', $AKB592$## 题目描述

有 $n+2$ 个点排成一排，编号为 $0 \sim n+1$。对于第 $i$ 号点有两个整数 $a_i, b_i$，其中 $0 \le i \le n+1$。规定初始时 $a_0 = b_0 = a_{n+1} = b_{n+1} = 0$。

设你当前在第 $x$ 号点，当前的移动方向为 $y$，初始时 $x=0, y=1$（向右）。

你将按如下方式移动，直到 $x, y$ 某一次变化后满足 $x=0, y=-1$（从左端离开）或 $x=n+1, y=1$（从右端离开）：

- **若 $y=1$（向右）**：首先将 $x$ 增加 1，此时若 $a_x > 0$ 则将 $y$ 变成 $-1$（转向左），否则 $y$ 不变，最后再将 $a_x$ 减少 1
- **若 $y=-1$（向左）**：首先将 $x$ 减少 1，此时若 $b_x > 0$ 则将 $y$ 变成 $1$（转向右），否则 $y$ 不变，最后再将 $b_x$ 减少 1

问最后结束时 $x$ 会在第几号点（事实上了最后 $x$ 仅可能为 $0$ 或 $n+1$）。

### 输入格式

本题有多组测试数据。

- 第一行：正整数 $T$，表示测试数据组数
- 对于每组数据：
  - 第一行：正整数 $n$
  - 接下来 $n$ 行：每行两个非负整数 $a_i, b_i$（$1 \le i \le n$）

### 输出格式

对每组测试数据输出一行一个整数，表示最后结束时 $x$ 的编号（$0$ 或 $n+1$）。

### 数据范围

- $1 \le T \le 10$
- $1 \le n \le 10^6$
- $0 \le a_i, b_i \le 10^9$（$1 \le i \le n$）

## 样例

> 本题来源与官方样例暂未考证。以下示例由本文档自造，并已用按题面规则独立编写的模拟器逐组对拍验证。

### 样例输入

```
2
3
0 1
2 0
0 1
2
0 0
0 0
```

### 样例输出

```
0
3
```

**第一组**（$n = 3$，$a = [0,2,0]$，$b = [1,0,1]$）的移动过程：

| 步骤 | 方向 $y$ | 移动后 $x$ | 是否转向 | 该点计数变化 | 步骤后状态 |
|---|---|---|---|---|---|
| 1 | 向右 | 1 | 否（$a_1 = 0$） | $a_1: 0 \to -1$ | $x=1,\ y=1$ |
| 2 | 向右 | 2 | 是（$a_2 = 2 > 0$） | $a_2: 2 \to 1$ | $x=2,\ y=-1$ |
| 3 | 向左 | 1 | 是（$b_1 = 1 > 0$） | $b_1: 1 \to 0$ | $x=1,\ y=1$ |
| 4 | 向右 | 2 | 是（$a_2 = 1 > 0$） | $a_2: 1 \to 0$ | $x=2,\ y=-1$ |
| 5 | 向左 | 1 | 否（$b_1 = 0$） | $b_1: 0 \to -1$ | $x=1,\ y=-1$ |
| 6 | 向左 | 0 | — | — | 从左端离开，答案为 0 |

**第二组**（$n = 2$，四个计数全为 0）：全程向右且不触发转向，走到 $x = n+1 = 3$ 后从右端离开，答案为 3。

## 解题思路

### 第一步：暴力模拟的问题

直接按题意模拟每一步移动，时间复杂度可能高达 $O(\sum a_i + \sum b_i)$，在 $a_i, b_i$ 达到 $10^9$ 时显然超时。必须找到一种不逐步模拟的方法。

### 第二步：物理类比——动量守恒

观察移动规则的本质：

- **向右移动**到达点 $i$ 时：若 $a_i > 0$ 则转向左（消耗 1 次 $a_i$），$a_i$ 减 1
- **向左移动**到达点 $i$ 时：若 $b_i > 0$ 则转向右（消耗 1 次 $b_i$），$b_i$ 减 1

这和物理学中的**动量**非常相似：

- 粒子从点 0 出发，具有 **1 单位向右的初始动量**
- 经过每个点 $i$ 时：
  - $a_i$ 表示该点能**消耗的向右动量**（每次转向左消耗 1 单位）
  - $b_i$ 表示该点能**提供的向右动量**（每次转向右获得 1 单位）
- 粒子能否通过点 $i$，取决于到达该点时的动量是否足够"冲破"$a_i$ 的阻碍

### 第三步：动量公式推导

设粒子到达点 $i$ 时的动量为 $q_i$（正表示向右，负表示向左）：

$$q_i = q_{i-1} - a_i + b_i$$

- $q_{i-1} - a_i$：到达点 $i$ 后，先与 $a_i$ 次反弹对抗（每次消耗 1 动量并转向），剩余动量
- $+ b_i$：点 $i$ 的 $b_i$ 次反弹会把粒子重新推向右边，补充动量

**关键判断**：如果在某点 $i$，到达时的动量 $q_{i-1} \le a_i$，说明粒子的向右动量不足以冲破 $a_i$ 的阻碍，最终会被反弹回左侧，从点 0 离开。

如果粒子能通过所有 $n$ 个点（即所有点都满足 $q_{i-1} > a_i$），则从点 $n+1$ 离开。

### 第四步：算法流程

1. 初始动量 $q = 1$（向右）
2. 从 $i = 1$ 到 $n$ 遍历每个点：
   - 若 $q \le a_i$：粒子无法通过，最终从左端离开，答案为 $0$，标记结束
   - 否则更新动量 $q = q - a_i + b_i$
3. 若所有点都通过，答案为 $n+1$

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

- `read()`：手写快速读入整数，比 `scanf`/`cin` 更快，适合 $n \le 10^6$ 的大数据量
- `write()`：手写快速输出 `long long`，逆序存入 `buf` 后逆序输出

### 主逻辑

```cpp
int main()
{
    int T = read();
    while (T--)
    {
        int n = read();
        long long q = 1;       // 初始动量：1 单位向右
        int ans = -1;           // -1 表示尚未确定答案
        for(int i = 1; i <= n; i++)
        {
            long long a = read(), b = read();
            if (ans != -1) continue;  // 已确定答案，跳过剩余输入（但仍需读入）
            if (q <= a) ans = 0;       // 动量不足以通过点 i，从左端离开
            q = q - a + b;             // 更新动量
        }
        if (ans == -1) write(n + 1);   // 所有点都通过，从右端离开
        else write(0);
        putchar('\n');
    }
    return 0;
}
```

- `long long q = 1`：初始动量为 1。注意必须用 `long long`，因为 $a_i, b_i$ 可达 $10^9$，累加后可能溢出 `int`
- `if (ans != -1) continue`：一旦确定粒子从左端离开，后续点的输入仍需读入（否则输入流错乱），但不再处理逻辑
- `if (q <= a) ans = 0`：动量不足以冲破 $a_i$，标记答案为 0（左端离开）
- `q = q - a + b`：动量更新公式。先消耗 $a$（与 $a$ 次反弹对抗），再获得 $b$（被 $b$ 次反弹推回右边）

## 复杂度分析

### 时间复杂度

| 操作 | 复杂度 | 说明 |
|---|---|---|
| 遍历 $n$ 个点 | $O(n)$ | 每个点 $O(1)$ 处理 |
| **总计** | $O(n)$ | 线性时间 |

与暴力模拟的 $O(\sum a_i + \sum b_i)$ 相比，从指数级降为线性。

### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 动量 $q$ | $O(1)$ | 单变量维护 |
| **总计** | $O(1)$ | 不需要存储数组，流式处理 |

## 常见陷阱与注意事项

1. **数据类型溢出**
   - $a_i, b_i$ 可达 $10^9$，累加后动量 $q$ 可能超过 `int` 范围（$2 \times 10^9$）
   - 必须使用 `long long` 存储动量 $q$

2. **判断条件是 $q \le a$ 而非 $q < a$**
   - 当 $q = a$ 时，粒子恰好消耗完所有动量，无法继续向右，最终从左端离开
   - 只有 $q > a$ 时才能通过该点

3. **确定答案后仍需读完输入**
   - `if (ans != -1) continue` 跳过了逻辑处理，但 `read()` 仍在执行
   - 若不读完输入，后续测试数据的输入流会错乱

4. **初始动量为 1 而非 0**
   - 粒子从点 0 出发向右移动，具有 1 单位初始动量
   - $a_0 = b_0 = 0$，点 0 不影响动量

5. **动量可能变为负数**
   - $q = q - a + b$ 中，若 $a$ 远大于 $b$，$q$ 可能变为负数
   - 但一旦 $q \le a$ 就已标记答案，后续不再更新 $q$，因此不会影响结果

## 对比与扩展

| 方法 | 时间 | 空间 | 特点 |
|---|---|---|---|
| **动量守恒（本算法）** | $O(n)$ | $O(1)$ | 物理类比，流式处理 |
| 暴力模拟 | $O(\sum a_i + \sum b_i)$ | $O(n)$ | 逐步模拟，超时 |
| 前缀和预判 | $O(n)$ | $O(n)$ | 预处理前缀和数组，思路类似但空间更大 |

### 扩展

- **物理类比思维**：本题的核心思想是将"反复反弹"的过程类比为"动量消耗与补充"，这种将模拟问题转化为守恒量分析的方法在竞赛中非常实用
- **类似问题**：弹球碰撞、光线反射等涉及"方向反转"的模拟问题，都可以尝试用守恒量（动量、能量）来简化分析
- **流式处理**：不需要存储整个数组，逐个读入并处理，空间复杂度降为 $O(1)$$AKB592$, '数学', array['模拟', '贪心', '动量守恒', '物理类比', '优化'], null, '暂未评定', 'problem'),
('Xesir', 'col-prob-qbxt-multiple--xesir', '倍数很爽 · Xesir', $AKB593$## 题目描述

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
- 若 $n$ 放大到 $10^5$，$O(n^2)$ 的枚举就不行了，需要按奇偶把数分成两类，再用哈希或桶去匹配互质对。$AKB593$, '数学', array['数论', '中国剩余定理', 'exgcd', '构造', '分类讨论'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-14621--stripe-python', 'Tearing Paper · stripe-python', $AKB594$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ14621](https://qoj.ac/problem/14621)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 定义 $(0,0) \to (n,m)$ 的格路是合法的，当且仅当矩形 $[a,c] \times [b,d]$ 在格路同侧。求合法格路数目。
>
> 多测，$T \le 10^4$，$n \le 10^3$，$m \le 10^6$，1 秒，256 MB。

:::::success[题解]

考虑分别计数不越过射线 $x \le c \land y=b$ 和 $x=a \land y \le d$ 的格路数目，二者相加即为所求。

![](https://cdn.luogu.com.cn/upload/image_hosting/glnce3df.webp)

以 $x=a \land y \le d$ 的计数为例，枚举 $i \le a$，将格路拆成 $(0,0) \to (i,d)$ 和 $(i,d+1) \to (n,m)$ 两部分。

![](https://cdn.luogu.com.cn/upload/image_hosting/757yaw88.webp)

特判 $(0,0) \to (a,d) \to (a+1,d) \to (n,m)$ 的情形。可列得答案式
$$
\boxed{\sum_{i=0}^a \binom{i+d}{i}\binom{n-i+m-(d+1)}{n-i}}
$$
对于 $x \le c \land y=b$ 同理求解，单测复杂度 $O(n+m)$ 无法通过。

注意到 $n,m$ 不同阶，正难则反，枚举跨过 $y=b$ 的位置 $i$，将不合法格路拆成 $(0,0) \to (i,b)$ 和 $(i,b+1) \to (n,m)$ 两部分：

![](https://cdn.luogu.com.cn/upload/image_hosting/o0liykgl.webp)

根据减法原理得到
$$
\boxed{\binom{n+m}{n} - \sum_{i=0}^{c-1} \binom{i+b}{i} \binom{n-i+m-(b+1)}{n-i}}
$$
必有 $a,c \le n$，总复杂度 $O(m+Tn)$ 可以通过。[代码](https://qoj.ac/submission/3142249)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB594$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-19066--stripe-python', 'Historical Hits · stripe-python', $AKB595$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ19066](https://qoj.ac/problem/19066)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个二元组 $(a_i,b_i)$。你需要将 $n$ 个二元组随机打乱，然后进行如下操作：
>
> - 维护集合 $S$，按打乱后的顺序依次考虑每个 $i$，若 $\forall x \in S, x \notin [\min(a_i,b_i),\max(a_i,b_i)]$ 则令 $S \gets S \cup \{a_i\}$。
>
> 求 $|S|$ 的期望值。保证 $\forall i\ne j, a_i \ne a_j$ 且 $a_i \ne b_j$。
>
> $n \le 3 \times 10^3$，2 秒，1024 MB。

:::::success[题解]

考虑两个位置 $i,j$，若 $a_j \in [\min(a_i,b_i),\max(a_i,b_i)]$ 则连边 $i \to j$，表示 $i$ 可以阻止 $j$ 加入。在一般图上考虑问题，DP 状态需要记可达性等信息，状态数不可接受。

这启发我们利用区间的性质。对 $a_i$ 离散化后对 $n$ 个二元组按 $a_i$ 升序排序，则 $i \to j$ 对应的 $j$ 在新序列中构成连续段 $[x_i,y_i]$。容易证明 $i \in [x_i,y_i]$。

对 $k \in S$，所有覆盖 $k$ 的区间 $k \in [x_j,y_j]$ 都会失效。我们将一个极大空区间作为状态进行 DP：

- 记 $f_{l,r}$ 为满足下列条件时 $\Delta |S|$ 的期望：

  - $l-1 \in S \land r+1 \in S$。
  - $\forall k\in [l,r], k\notin S$。

  显然对 $|S|$ 有影响的 $i$ 必满足 $[x_i,y_i] \subseteq [l,r]$，故 $f_{l,r}$ 与外界独立。

- 区间 DP 转移考虑枚举断点 $k$。设 $c_{l,r}$ 为 $[x_i,y_i] \subseteq [l,r]$ 的 $i$ 的数目，特判 $c_{l,r}=0$ 后进行讨论：

  - 取出 $k$ 的概率为 $\frac{1}{c_{l,r}}$。
  - 根据 DP 的组合意义，$k$ 是 $[l,r]$ 内部首先处理的位置，故 $k$ 必然能成功加入 $S$。
  - $k$ 加入 $S$ 后，原区间 $[l,r]$ 分裂为 $[l,k)$ 和 $(k,r]$。

  综上所述，我们有转移式
  $$
  \boxed{f_{l,r}=1+\dfrac{1}{c_{l,r}} \sum_{k \in [l,r]\land [x_k,y_k] \subseteq [l,r]} (f_{l,k-1}+f_{k+1,r})}
  $$

- DP 初值为 $f_{l,r}=0$。

- 答案为 $f_{1,n}$。

复杂度 $O(n^3)$ 无法通过。观察转移条件，利用区间 DP 转移顺序的特殊性对其进行优化。

我们增量维护所有合法的 $k$。考虑 $r \to r+1$ 时，新增的 $k$ 必有 $y_k=r \land l \le x_k$。将 $k$ 挂在 $y_k$ 处，令 $c_{l,r}$ 继承 $c_{l,r-1}$ 后枚举 $k$ 进行转移。对后面的求和式，令
$$
p_{l,r}=\sum_{k \in [l,r] \land [x_k,y_k] \subseteq [l,r]} f_{l,k-1}\\
q_{l,r}=\sum_{k \in [l,r] \land [x_k,y_k] \subseteq [l,r]} f_{k+1,r}\\
$$
内层对 $r$ 扫描线维护 $p$，对 $l$ 扫描线维护 $q$，最后再计算每个 $f_{l,r}$ 即可。

复杂度 $O(n^2)$。[代码](https://qoj.ac/submission/2958060)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB595$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-qoj-20297--stripe-python', 'Legendary Game · stripe-python', $AKB596$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[QOJ20297](https://qoj.ac/problem/20297)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,k$，对满足下列条件的长为 $n$ 的序列 $a_i$ 计数：
>
> - $a_i \in [1,2n+k]$。
> - $\forall a_i \in [1,n], a_{i+1} >n$。
> - $\forall a_i \in (n+k,2n+k], a_{i+1} \le n+k$。
>
> 除以 $A_{2n+k}^n$ 后输出。
>
> $n \le 10^6$，$k \le 100$，1 秒，256 MB。

:::::success[题解]

我们称 $[1,n]$ 为一类数，$(n,n+k]$ 为二类数，$(n+k,2n+k]$ 为三类数。设三种数在最终序列中出现 $c_1,c_2,c_3$ 次，则我们只关心每个位置的数字类型是否合法，最终令每类数自由排列，系数 $\dbinom{k}{c_2}\dbinom{n}{c_1} \dbinom{n}{c_3}c_1!c_2!c_3!$。

注意到 $k$ 的范围很小，考虑枚举 $x=c_2$。这 $x$ 个二类数将序列切分为 $x+1$ 段，每段内部必然是一 & 三交替的。枚举 $c_1$ 或 $c_3$ 的复杂度过大，我们转而关注每段长度的奇偶性。

枚举 $x+1$ 段中存在 $y$ 个奇数段，再钦定 $y$ 个奇数段中恰有 $z$ 个满足：一类数比三类数多一个。选法数 $\dbinom{x+1}{y} \dbinom{y}{z}$。可以求得 $c_1-c_3=z-(y-z)$，联立 $c_1+c_2+c_3=n$ 可解出 $c_1,c_3$ 得到系数。

对于偶数段，存在 `1313...` 和 `3131...` 两种排列方式，枚举 $x+1-y$ 个偶数段中有 $w$ 个非空，选法数 $\dbinom{x+1-y}{w}$，贡献系数 $2^w$。

还有一个系数是，将 $n-x$ 个元素划分为 $x+1$ 段，恰有 $y$ 个奇数段和 $w$ 个非空偶段的方案数。设奇数段长 $2a_i+1$，偶数段长 $2b_i$，可列得不定方程
$$
\sum_{i=1}^y (2a_i+1)+\sum_{i=1}^w 2b_i=n-x
$$
未知量的范围是 $a_i \ge 0$ 且 $b_i \ge 1$。令 $b_i'=b_i-1$，代入化简得
$$
\sum_{i=0}^y a_i+\sum_{i=1}^w b_i'=\dfrac{n-x-y-2w}{2}
$$
这是 $y+w$ 个变量的不定方程解计数问题，答案为 $\dbinom{\frac{n-x-y-2w}{2}+y+w-1}{y+w-1}$。注意特判 $y=0 \land w=0$ 的情形，所有段都是空段，方案数为 $1$。

综上，给出本题的答案式子
$$
\boxed{\dbinom{k}{c_2}\dbinom{n}{c_1} \dbinom{n}{c_3}c_1!c_2!c_3!\dbinom{x+1}{y} \dbinom{y}{z}\dbinom{x+1-y}{w}\dbinom{\frac{n-x-y-2w}{2}+y+w-1}{y+w-1}}
$$
复杂度 $O(k^4)$。[代码](https://qoj.ac/submission/3017580)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB596$, '数学', array['题解'], null, '暂未评定', 'problem'),
('world-needs-sunday', 'col-prob-xor-sort', 'XOR 排序（简单版）— 对齐块分段判定', $AKB597$## 题目描述

对于由 $m$ 个正整数组成的数组 $b$，定义 $f(b)$ 如下：

称 $b$ 可以被 $k$-排序，若能通过任意多次执行以下操作把 $b$ 变成非降序：

- 选择两个下标 $i, j$（$0 \le i < j \le m-1$），满足 $i \oplus j \le k$（条件作用在**下标**上，与元素值无关）
- 交换 $b_i$ 和 $b_j$

$f(b)$ 定义为使 $b$ 可被 $k$-排序的**最小非负整数** $k$。

给定长度为 $n$ 的正整数数组 $a$（下标从 0 开始）。本版 $q = 0$，即只需对初始状态求出 $f(a)$。$\oplus$ 表示按位异或。

### 输入格式

- 第一行：$t$ 组数据
- 每组：
  - 第一行：$n$ 和 $q$（本版 $q = 0$）
  - 第二行：$n$ 个整数 $a_0, a_1, \ldots, a_{n-1}$

保证 $\sum n \le 10^6$，$1 \le a_i \le 10^9$。

### 输出格式

每组输出 1 个整数（$q+1 = 1$），即 $f(a)$。

### 数据范围

- $\sum n \le 10^6$，$1 \le a_i \le 10^9$
- 本版 $q = 0$，即只需对初始状态求 $f(a)$

## 样例

### 样例输入

```
3
3 0
2 3 4
2 0
1000000000 999999999
6 0
2 5 3 4 1 6
```

### 样例输出

```
0
1
4
```

> 第一组已经有序；第二组只需交换 $a_0, a_1$（$0 \oplus 1 = 1$）；第三组可用下标对 $(0,1)$ 与 $(0,4)$，故 $f(a) = \max(0 \oplus 1,\ 0 \oplus 4) = 4$。

## 解题思路

### 第一步：答案只能是 0 或 2 的幂

这是全题的钥匙。考察一次"交换下标 $i, j$"的操作，若 $i \oplus j$ 不是 2 的幂，设它最高的 1 位是 $2^b$，可以用**三次 XOR 恰为 $2^b$ 的交换**把它替换掉：

```
原始交换：i ↔ j  （XOR = i⊕j，最高位 2^b）
分解为：
  1. 交换 i ↔ (i+2^b)   XOR = 2^b
  2. 交换 (i+2^b) ↔ j    XOR ≤ 2^b
  3. 交换 i ↔ (i+2^b)   XOR = 2^b  （恢复中间点）
```

整体效果仍是"只交换了 $i$ 和 $j$ 上的元素"，且每步 XOR $\le 2^b \le i \oplus j$。

因此任何 $k$-排序方案都可以改写成"只使用 XOR 为 2 的幂的交换"的方案。设实际用到的最大幂是 $2^b$，则 $f(b) \le 2^b$。对最小的 $k$ 取等——**$f(b)$ 必然是 2 的某个幂，或者数组本身已有序时为 0**。

### 第二步：$k = 2^x$ 时的块结构

$i \oplus j \le 2^x < 2^{x+1}$ 意味着 $i$ 和 $j$ 在第 $x$ 位及以上完全相同，所以它们必然落在同一个**以 $2^{x+1}$ 对齐、长度为 $2^{x+1}$ 的连续块**里。反过来，块内任意两个下标的异或值都 $< 2^{x+1}$，其最高位 $\le 2^x$。

两边合起来：

> 当 $k = 2^x$ 时，数组被切成若干长度为 $2^{x+1}$ 的连续对齐块（最后一块可能不满），**块内元素可以任意重排，块与块之间绝对无法交换**。

### 第三步：判定条件

既然块内自由、块间冻结，"$k = 2^x$ 能排序"当且仅当：

$$\max(\text{块 } j) \le \min(\text{块 } j+1) \quad \text{对所有相邻块}$$

因为块内可以任意排列（排好内部），剩下的唯一要求是前一块的最大值不超过后一块的最小值。反过来，若某处 $\max(\text{前}) > \min(\text{后})$，这两个数永远无法跨块相遇，排序必然失败。

### 第四步：不同 $k$ 对应的块结构

| $k$ | 块大小 | 块内自由度 | 块间要求 |
|---|---|---|---|
| $0$ | 无（无法交换） | — | 数组本身必须已有序 |
| $1 = 2^0$ | $2$ | 相邻两项可交换 | 每对位置之间 $\max \le \min$ |
| $2 = 2^1$ | $4$ | 4 元素块内任意排列 | 相邻 4 块之间 $\max \le \min$ |
| $4 = 2^2$ | $8$ | 8 元素块内任意排列 | 相邻 8 块之间 $\max \le \min$ |
| $2^x$ | $2^{x+1}$ | 块内任意排列 | 相邻块之间 $\max \le \min$ |

$k$ 越大块越大、越容易满足。从小到大枚举 $x$，第一个通过的 $x$ 就是答案。

### 第五步：算法流程

1. **特判**：若数组本身已非降序，直接输出 $0$
2. **逐层检查**：从 $k = 1$（即 $2^0$）开始，块大小取 $2k$，线性扫描维护"到当前块为止的全局最大值 $\text{nmax}$"，逐块检查当前块的每个元素是否 $\ge \text{nmax}$
3. **第一次通过的 $k$ 就是答案**，输出 $k$
4. 理论上 $x$ 最大到 $\lceil \log_2 n \rceil - 1$ 必然通过（块大小 $\ge n$，只有一个块，块间条件为空）

## 逐行代码解析

### check 函数

```cpp
bool check(int k, int n, const vector<int>& A)
{
    int gap = k * 2;          // 块大小 = 2k = 2^{x+1}
    int nmax = INT_MIN;       // 前面所有块的全局最大值
    for (int i = 0; i < n;)
    {
        int j = i + gap;      // 当前块的右边界（开区间）
        int tmin = INT_MAX, tmax = INT_MIN;
        for (int l = i; l < min(j, n); l++)  // 遍历当前块
        {
            tmin = min(tmin, A[l]);
            tmax = max(tmax, A[l]);
        }
        if (tmin < nmax) return false;  // 当前块最小值 < 前面块最大值 → 失败
        nmax = tmax;                      // 更新全局最大值
        i = min(j, n);                    // 跳到下一块
    }
    return true;
}
```

- `gap = k * 2`：$k = 2^x$ 时块大小为 $2^{x+1} = 2k$
- `nmax`：维护前面所有块的最大值，不需要对每块单独求 min——"当前块每个元素 $\ge \text{nmax}$"与"$\max(\text{前块}) \le \min(\text{当前块})$"完全等价
- `tmin < nmax`：当前块存在元素比前面所有块的最大值还小，说明跨块逆序，判定失败

### 主函数

```cpp
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(nullptr); cout.tie(nullptr);
    int t;
    cin >> t;
    while (t--)
    {
        int n, q;
        cin >> n >> q;
        vector<int> A(n);
        for (int i = 0; i < n; i++) cin >> A[i];
```

标准读入，关闭同步流以应对大数据量。

```cpp
        if (is_sorted(A.begin(), A.end())) cout << 0 << '\n';
        else
        {
            int k = 1;
            while (!check(k, n, A)) k <<= 1;
            cout << k << '\n';
        }
    }
    return 0;
}
```

- `is_sorted` 特判 $k = 0$：数组本身已有序时答案为 0，不能靠块判定得出（否则会把"块长 2 且块间有序"误判成 $k = 0$）
- `k = 1; while (!check(k, n, A)) k <<= 1`：从 $k = 2^0 = 1$ 开始，逐位左移（$k = 1, 2, 4, 8, \ldots$），第一个通过 check 的就是答案

## 复杂度分析

### 时间复杂度

| 操作 | 复杂度 | 说明 |
|---|---|---|
| is_sorted 特判 | $O(n)$ | 一次线性扫描 |
| check 函数（每层） | $O(n)$ | 每层线性扫描整个数组 |
| 总层数 | $O(\log n)$ | $k$ 从 1 到 $\le 2^{\lceil \log_2 n \rceil}$ |
| **总计** | $O(n \log n)$ | $\log n$ 层 $\times$ 每层 $O(n)$ |

### 空间复杂度

| 数据 | 空间 | 说明 |
|---|---|---|
| 数组 A | $O(n)$ | 长度 $n$ |
| **总计** | $O(n)$ | 线性空间 |

## 常见陷阱与注意事项

1. **必须特判 $k = 0$**
   - `is_sorted` 判断不能省略，否则会把"块长 2 且块间有序但块内逆序"的情况误判为 $k = 0$
   - $k = 0$ 意味着无法做任何交换（$i \oplus j \le 0$ 要求 $i = j$），数组本身必须已有序

2. **块大小是 $2k$ 不是 $k$**
   - $k = 2^x$ 对应块大小 $2^{x+1} = 2k$
   - 代码中 `gap = k * 2` 容易写成 `gap = k` 导致整层判定错误

3. **下标从 0 开始**
   - 题目使用零基索引，块的对齐方式以 $2^{x+1}$ 为周期
   - 若误用 1-based 下标，块边界会偏移

4. **答案上限**
   - $n = 10^6$ 时答案最多是 $2^{19} \approx 5 \times 10^5$，`int` 足够
   - 但 $k <<= 1$ 最终可能到 $2^{20}$，仍在 `int` 范围内

5. **输入输出的速度**
   - $\sum n \le 10^6$，必须关闭同步流 `ios::sync_with_stdio(false)`

6. **最后一块可能不满**
   - `min(j, n)` 处理了最后一块不足 `gap` 长度的情况
   - 遗漏会导致数组越界

## 对比与扩展

| 方法 | 时间 | 空间 | 特点 |
|---|---|---|---|
| **逐层检查（本算法）** | $O(n \log n)$ | $O(n)$ | 简单直观，无需数据结构 |
| 线段树维护（困难版） | $O(n \log n)$ 预处理 + $O(\log^2 n)$ 每次更新 | $O(n)$ | 支持 $q$ 次单点更新 |
| 暴力枚举 $k$ | $O(n \cdot \max k)$ | $O(n)$ | $k$ 可能到 $10^9$，超时 |

### 扩展

- **困难版 D2**：将"每层 $O(n)$ 重扫"换成用线段树按块维护 max/min 与块间约束，单点更新后从叶子往上重算，思路一脉相承
- **XOR 交换的分解技巧**：任何 XOR 交换可分解为三次 $2$ 的幂的交换，这一技巧在其他 XOR 相关问题中也有应用
- **对齐分块思想**：$i \oplus j \le 2^x$ 等价于"$i, j$ 在同一个 $2^{x+1}$ 对齐块内"，这种将位运算条件转化为分块结构的思路在位运算题中非常实用$AKB597$, '数学', array['位运算', 'XOR', '分块', '排序判定', '贪心', '二进制'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-xxs0103--stripe-python', '局部函数 · stripe-python', $AKB598$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[XXS0103](https://oj.xinxingshe.cn:444/d/xxs/p/NOIP260103)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 记 $U=\{0,1,2,3\}$。现有 $n$ 个变量 $x_i \in U$，初始 $x_i=a_i$ 且 $x_0=x_{n+1}=0$。另给定 $n$ 个二元函数 $g_i : U^2 \to U$。
>
> 考虑 $1\sim n$ 的排列 $p_i$，对 $i=1,2,\cdots,n$ 依次执行如下操作：
>
> - 记 $k=p_i$，令 $x_k \gets g_k(x_{k-1},x_{k+1})$。
>
> 对所有排列 $p$，求可得 $x_1 \sim x_n$ 最终序列的数目。
>
> $n \le 2 \times 10^5$，2 秒，512 MB。

:::::success[题解]

一个基本的刻画是，考虑相邻项 $u,v$，若 $x_u$ 的更新时刻早于 $x_v$ 则连边 $u \to v$，建图是有向链。

取任意拓扑序均可得到唯一的 $x_1 \sim x_n$。考虑 $O(4^n)$ 枚举 $x_1 \sim x_n$，根据上述刻画设计内层 DP：

- 设 $f_{0/1,i}$ 为满足下列条件时，是否存在合法定向方案：
  - $i$ 向右的边方向为 $0/1$。
  - 仅考虑 $x_0 \sim x_i$。
- 转移分讨 $f_{0/1,i-1} \to f_{0/1,i}$ 是否可行，只要根据 $a_i,x_i$ 和 $g_i$ 判定。
- DP 初值为 $f_{{\tt{R}},0}=1$。
- 答案为 $f_{{\tt{L}},n}$。

只要记录 $(x_{i-1},x_i,f_{0,i-1}, f_{1,i-1})$ 四元组，内层 DP 就能建模为 DFA，状态信息量 $4^2 \times 2^2=64$。考虑外层 DP：

- 设 $f_{u,v,f_0,f_1,i}$ 为满足下列条件的方案数：
  - $x_{i-1}=u \land x_i=v$。
  - $f_{0/1,i-1}=f_{0/1}$。
  - 仅考虑 $x_0 \sim x_i$。
- 转移枚举 $x_{i+1}$ 的取值，可算出新的 $(u',v',f_0',f_1')$，转移 $f_{u,v,f_0,f_1,i-1} \to f_{u',v',f_0',f_1',i}$ 即可。
- DP 初值为 $f_{0,v,0,1,0}=1$。
- 答案为 $\sum\limits_{u,f_1} f_{u,0,1,f_1,n}$。

复杂度 $O(k^3 n)$，其中 $k=4$。[代码](https://www.cnblogs.com/stripe-python/p/23186973)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB598$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3365--stripe-python', '马戏表演 · stripe-python', $AKB599$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3365](https://www.zhengruioi.com/problem/3365)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n,m$。对 $1 \sim n$ 的排列 $p_i$，设 $c_i$ 表示 $p_i$ 成为了多少个区间 $\max$，形式化地 $c_i=\sum \limits_{i \in [l,r]} \left[\max \limits_{j=l}^r a_j=a_i\right]$。
>
> 求 $\forall i \in [1,n], c_i \le m$ 的 $p$ 的数目。
>
> $n \le 10^7$，$m \le \binom{n+1}{2}$，2 秒，512 MB。

:::::success[题解]

我们在大根笛卡尔树上 DP。枚举 $\max$ 的位置为 $x$，则 $c_x=x(n+1-x)$。

**性质** 若 $c_x \le m$，则 $[1,x)$ 和 $(x,n]$ 中更短的一侧必然合法。

**证明** 不妨设 $2x\le n$ 且 $i \in [1,x)$，只要证 $i(x-i) < c_x$。放缩 $i(x-i) < x^2$， 又有 $x(n+1-x) > x^2+x > x^2$ 即证。

设 $f_n$ 为长为 $n$ 的合法排列数目。若 $\left\lceil \dfrac{n}{2}\right\rceil\left(\left\lfloor \dfrac{n}{2} \right\rfloor+1\right) \le m$ 则排列必然合法，$f_n=n!$。否则按照性质进行 DP：

- 枚举最大值的位置 $x$，钦定 $2x \le n$，由对称性答案 $\times 2$ 即可。
- 从 $n$ 个数中选 $x-1$ 个数放在左侧，方案数 $A_n^{x-1}$。
- 右侧 $n-x$ 个数只关心相对大小，视作排列计数，答案为 $f_{n-x}$。

从而转移方程为
$$
f_n=2 \times \sum_{2x \le n \land x(n+1-x) \le m} A_n^{x-1} f_{n-x}
$$
拆开排列数推式子：
$$
\begin{aligned}
f_n&=2\sum_{2x \le n} [x(n+1-x) \le m] \dfrac{n!}{(n-x+1)!}f_{n-x}\\
&= \boxed{2\dfrac{n!}{n}\sum_{2x \le n} [x(n+1-x) \le m] \dfrac{f_{n-x}}{(n-x)!}}
\end{aligned}
$$
满足 $2x \le n \land x(n+1-x) \le m$ 的 $x$ 是一段前缀，可以解不等式 $O(1)$ 求出，维护 $\dfrac{f_n}{n!}$ 的前缀和即可。使用线性逆元并预处理阶乘，复杂度 $O(n)$。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB599$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3382--stripe-python', '冒泡排序 / bubble · stripe-python', $AKB600$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3382](https://www.zhengruioi.com/problem/3382)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 对长为 $n$ 的排列 $a_i$，定义一轮双向冒泡排序为：
>
> - 顺次枚举 $i=1,2,\cdots,n-1$，若 $a_i>a_{i+1}$ 则交换 $(i,i+1)$。
> - 顺次枚举 $i=n-1,n-2,\cdots,1$，若 $a_i>a_{i+1}$ 则交换 $(i,i+1)$。
>
> 给定 $n,k$，求 $k$ 轮双向冒泡后变为递增的排列 $a$ 数目。
>
> $n,k \le 10^4$，1 秒，512 MB。

:::::success[题解]

**结论** 设 $f(a)=\max \limits_{i=1}^n \sum\limits_{j<i} [a_j>i]$，则排列 $a$ 合法的充要条件为 $f(a) \le k$。

**证明** 根据排序网络的 01 原理，任取阈值 $x$，将 $\le x$ 的数视作 $0$，$>x$ 的数视作 $1$，则 $a$ 合法等价于 01 序列在 $k$ 轮双向冒泡后有序。

设 $q_x$ 为前 $x$ 位中 $1$ 的数目，则后 $n-x$ 位中恰有 $q_x$ 个 $0$。分讨可得，一轮双向冒泡令 $q_x \gets \max(0,q_x-1)$。

只要 $\forall x, q_x \le k$。定义 $f(a)=\max \limits_{i=1}^n q_i$ 则 $f(a) \le k$，证毕。

下面对 $f(a) \le k$ 的排列计数。将 $i \to a_i$ 描述为二分图匹配，从小到大扫描，设计延迟钦定配对 DP：

- 设 $f_{i,j}$ 为满足下列条件的合法方案数：

  - 仅考虑标号为 $1\sim i$ 的左右部点。
  - 恰好匹配了 $j$ 对点。

- 转移 $f_{i-1,j} \to f_{i,j'}$，加入左右部点 $i$，分讨匹配方式：

  - 将两点都加入待定部分，转移 $f_{i-1,j} \to f_{i,j}$。
  - 将左部点 $i$ 配给待定右部点，令右部点待定，转移 $q \times f_{i-1,j} \to f_{i,j+1}$。系数 $q=i-1-j$ 为上一步的失配点对数。
  - 将右部点 $i$ 配给待定左部点，令左部点待定，转移 $q \times f_{i-1,j} \to f_{i,j+1}$。
  - 将左右部点 $i$ 直接匹配，转移 $f_{i-1,j} \to f_{i,j+1}$。
  - 将左部点 $i$ 配给待定右部点，同时将右部点 $i$ 配给待定左部点，转移 $q^2 \times f_{i-1,j}\to f_{i,j+2}$。

  前 $i$ 个位置中，有 $j$ 个位置的数字 $\le i$，那么 $q_i=i-j$。只保留 $q_i \le k$ 的状态即可满足约束。

- DP 初值为 $f_{0,0}=1$。

- 答案为 $f_{n,n}$。

复杂度 $O(n^2)$，对 $j$ 维度滚动数组即可空间线性。[代码](https://www.cnblogs.com/stripe-python/p/23220077)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB600$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3554--stripe-python', '抽卡 · stripe-python', $AKB601$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3554](https://www.zhengruioi.com/problem/3554)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 种卡，每种卡有三种颜色，共 $3n$ 张不同卡牌。一轮抽卡包含 $m$ 次独立抽取：
>
> - 前 $m-1$ 次抽卡中，抽到第 $i$ 种卡的概率为 $p_i$，抽取失败的概率为 $1-\sum \limits_{i=1}^n p_i$。
> - 最后一次抽卡中，抽到第 $i$ 种卡的概率为 $q_i$，抽取失败的概率为 $1-\sum \limits_{i=1}^n q_i$。
> - 抽到某种卡后，等可能性地获得三种颜色之一。
>
> 求集齐 $3n$ 种不同卡牌的轮数期望，保证期望存在。
>
> $\textcolor{red}{n \le 9}$，$m \le 64$，1 秒，512 MB。

:::::success[题解]

设第 $i$ 张卡牌的抽取时间为 $t_i$，题目即求 $E(\max t_i)$。由 max-min 容斥：
$$
E\left(\max_{i \in U} t_i\right)=\sum_{S \subseteq U}(-1)^{|S|-1} E\left(\min_{i \in S} t_i\right)
$$
组合意义是，配上 $(-1)^{|S|-1}$ 的容斥系数，转而计算 $S$ 中任意卡牌被抽取的期望轮数。

设 $p=\sum \limits_{i \in S}\frac{1}{3}p_i$，$q=\sum\limits_{i \in S} \frac{1}{3}q_i$，单步容斥得一轮成功的概率为 $1-(1-p)^{m-1}(1-q)$。由几何分布，期望轮数
$$
E\left(\min_{i \in S} t_i\right)=\boxed{\dfrac{1}{1-(1-p)^{m-1}(1-q)}}
$$
直接枚举 $S$ 的复杂度为 $O(8^n)$，无法通过。利用颜色的对称性，可以用四进制数编码 $S$，枚举每种卡牌在 $S$ 中出现的次数，对应系数为 $\binom{3}{\text{cnt}}$。

复杂度 $O(4^n)$。[代码](https://www.zhengruioi.com/submission/1094623)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB601$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3643--stripe-python', '覆色 · stripe-python', $AKB602$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3643](https://www.zhengruioi.com/problem/3643)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 现有 $n$ 个格子，你需要进行 $m$ 次操作，第 $i$ 次操作选择两个相邻格子，将其颜色染为 $i$。
>
> 求 $m$ 次操作后，所有格子均染色的不同颜色序列数，注意颜色序列与操作过程无关。
>
> $n \le 4 \times 10^3$，$m \le 10^8$，2 秒，256 MB。

:::::success[题解]

设颜色序列为 $a_1 \sim a_n$，则 $a$ 合法的充要条件为：

- $\forall i \in [1,n], a_i \in [1,m]$ 且 $m$ 出现。
- 每种颜色形成段长为 $1$ 或 $2$ 的颜色段。
- 若某段的数值大于两边，则长度必为 $2$。认为 $a_0=a_{n+1}=0$。

必要性易证。充分性考虑先染 $1$ 段，再让 $2$ 段覆盖，未出现的颜色都可以放在 $m$ 的位置让 $m$ 覆盖掉。

问题转化为 $a$ 序列计数。令 $f_{n,k}$ 为恰有 $k$ 个峰值的 $1 \sim n$ 的排列数目，视 $p_0=p_{n+1}=0$。枚举颜色段数 $x$ 和峰值段数 $y$，分步计数：

- 从 $[1,m)$ 中选 $x-1$ 种颜色，方案数 $\binom{m-1}{x-1}$。
- 将颜色段的排名视作 $1 \sim x$ 的排列，钦定 $y$ 个峰值，方案数 $f_{x,y}$。
- 序列恰有 $n-x$ 个 $2$ 段，其中 $y$ 个是峰值段，剩余 $n-x-y$ 个非峰值段。从 $x-y$ 个非峰值段中任取若干，钦定为 $2$ 段，方案数 $\binom{x-y}{n-x-y}$。

综上，求出 $f$ 的答案为
$$
\boxed{\sum_{x=1}^{n} \binom{m-1}{x-1} \sum_{y=1}^n \binom{x-y}{n-x-y}f_{x,y}}
$$
下面考虑 $f$ 的求解。我们只关心局部相对大小，考虑从小到大插入 DP：

- 转移在 $1 \sim n-1$ 的排列中插入当前 $\max$，进行分讨：
  - 插入到峰值邻位：峰值数不变。由于峰点互不相邻，插入位置 $2k$ 个，转移 $2k \times f_{n,k} \to  f_{n+1,k}$。
  - 插入后成为新峰值：峰值数 $+1$，插入位置 $n+1-2k$ 个，转移 $(n+1-2k)\times f_{n,k} \to f_{n+1,k+1}$。
- DP 初值为 $f_{1,1}=1$。

利用 $\binom{m-1}{x-1}=\frac{1}{(x-1)!}(m-1)^{\underline{x-1}}$，枚举 $x$ 的过程中递推出组合数，总复杂度 $O(n^2)$。[代码](https://www.zhengruioi.com/submission/1114017)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB602$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3652--stripe-python', '特征值 · stripe-python', $AKB603$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3652](https://www.zhengruioi.com/problem/3652)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $m,k$。对数组 $a_1 \sim a_n$，定义 $f(a)$ 为：一次操作选定 $i \in [1,n]$，令 $a_i \gets a_i \pm 1$，使得 $m \mid \sum \limits_{i=1}^n a_i$ 的最小操作次数。
>
> 对数组 $a_1 \sim a_n$，定义特征值 $F(a)=\min\limits_{[l,r] \subseteq [1,n]} f(a_l \sim a_r)$。对每个 $n=1,2,\cdots,m-1$ 求出，所有长为 $n$ 的序列 $a_i$ 满足 $a_i \in [0,m)$ 的 $F^k(a)$ 之和。
>
> 多测，$T \le 20$，$m \le 2\times 10^5$，$k \le 10^9$，1 秒，128 MB。

:::::success[题解]

设 $S=\sum \limits_{i=1}^n a_i$，则 $f(a)=\min(S \bmod m, m - S \bmod m)$。代入 $F$ 的定义后，两个 $\min$ 可以拆掉，变为
$$
\begin{aligned}
F(a)&=\min\left(\min_{[l,r] \subseteq [1,n]} \left(\sum_{i=l}^r a_i\right) \bmod m, \min_{[l,r] \subseteq [1,n]} \left( \left(\sum_{i=l}^r a_i\right)-\left(\sum_{i=l}^r a_i\right) \bmod m\right)\right)\\
&=\min\left(\min_{[l,r] \subseteq [1,n]} (p_r-p_{l-1}) \bmod m, \min_{[l,r] \subseteq [1,n]} \left(p_r-p_{l-1}-(p_r-p_{l-1}) \bmod m\right)\right)
\end{aligned}
$$
其中 $p_n=\left(\sum \limits_{i=1}^n a_i\right) \bmod m$。注意到 $p_1 \sim p_n$ 和 $a_1 \sim a_n$ 是双射，转而对 $p$ 计数。

考虑枚举 $x=F(a)$ 并计数 $p_1 \sim p_n$ 的数目，乘上 $x^k$ 作为答案。不妨将恰好容斥为选择至少，记 $c(x,n)$ 为 $F(a) \ge x$ 的 $a_1 \sim a_n$ 的数目，则 $n$ 的答案为
$$
\text{ans}_n=\sum_{x=0}^n x^k (c(x,n)-c(x+1,n))
$$
下面考虑 $c$ 的求法。由 $F(a) \ge x$ 可列得约束：
$$
\forall 0\le i<j\le n,\left\{\begin{matrix}
 (p_j-p_i) \bmod m &\ge x\\
 p_j-p_i-(p_j-p_i) \bmod m &\ge x
\end{matrix}\right.
$$
令 $i=0$ 可得 $p_j \in [x,m-x]$，条件转化为 $\forall i<j, |p_i-p_j| \ge x$。

取升序序列 $s_1 \sim s_n$，满足下列两个条件：

- $\forall i\in [1,n),s_{i+1}-s_i \ge x$。
- $\forall i\in [1,n], s_i \in [x,m-x]$。

可以证明 $p_1 \sim p_n$ 的升序排列和 $s_1 \sim s_n$ 是双射。对 $s$ 计数后乘系数 $n!$ 即可。

令 $t_i=s_i-x \times i$，则 $t_i \in [0,m-x(n+1)]$ 且 $t_i \ge t_{i+1}$。令 $u=m-x(n+1)$，由不降序列计数，答案为
$$
c(x,n)=\binom{u+n}{n}n!
$$
合法条件为 $u \ge 0$，解得 $x \le \frac{m}{n+1}$。外层循环枚举 $n$，内层枚举 $x$ 到 $\frac{m}{n+1}$ 是调和型枚举。 

注意预处理 $x^k$ 的值，总复杂度 $O(m \log k+m \log m)$。[代码](https://www.zhengruioi.com/submission/1113700)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB603$, '数学', array['题解'], null, '暂未评定', 'problem'),
('stripe-python', 'col-prob-zr-3695--stripe-python', '字典 · stripe-python', $AKB604$> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[ZR3695](https://www.zhengruioi.com/problem/3695)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 给定 $n$ 个字符串 $S_i$，字符集 $\Sigma=\{{\tt{a}},{\tt{b}},\cdots,{\tt{z}}\}$。从 $\Sigma$ 的 $26!$ 种排列中随机选取一个，并按照该顺序定义字典序。
>
> 对每个 $i$ 求出 $S_i$ 的字典序排名方差。
>
> $\sum |S_i| \le 5 \times 10^5$，3 秒，1024 MB。

:::::success[题解]

考虑使用 $\text{Var}(X)=\mathbb E[(X-\mathbb E [X])^2]$ 计算方差，下文讨论 $X$ 相对均值的波动。

枚举下标对 $(i,j)$，设 $S_i$ 与 $S_j$ 在 LCP 后第一个字符为 $f(i,j)=(x,y)$。忽略 $S_i$ 或 $S_j$ 是对方前缀的情形，因为常数不影响方差。

连边 $x \to y$，边权 $w(x,y)=\sum \limits_{i=1}^n \sum \limits_{j=1}^n [f(i,j)=(x,y)]$。若 $y<x$ 则相对均值贡献 $+\frac{w}{2}$，否则贡献 $-\frac{w}{2}$。 

取两条边，设波动分别为 $u,v$，方差
$$
\mathbb E[(u+v)^2]=\mathbb E[u^2]+2\mathbb E[uv]+\mathbb E[v^2]
$$
考察边 $e_1,e_2$ 的位置关系：

- 取同一条边 $a \to b$：乘积项期望 $\frac{w^2}{4}$。
- 取不共点边 $a \to b, c\to d$：事件独立，同号与异号概率相同，期望 $0$。
- 取三角状 $a \to b, a \to c$：枚举 $6$ 种排列可算得，同号 $4$ 种异号 $2$ 种，期望 $\frac{4-2}{6}\times\frac{w_1w_2}{4}=\frac{w_1w_2}{12}$。
- 取三点链 $a \to b, b\to c$：枚举 $6$ 种排列可算得，同号 $2$ 种异号 $4$ 种，期望 $\frac{2-4}{6} \times \frac{w_1w_2}{4}=-\frac{w_1w_2}{12}$。

直接将这些值相加就是方差，不过复杂度不可接受，还需要进一步推导。

定义节点 $x$ 的出边权和减去入边权和为 $b_x$。我们发现 $T=\frac{1}{12} \sum \limits_{x \in V} b_x^2$ 其实就几乎算完了。因为 $b_x^2$ 的组合意义是将 $x$ 的两条关联边相乘，同进同出均正，而一进一出为负，恰好与上面讨论的规则相同。

唯一算漏的地方是取同一条边两次时贡献 $\frac{3w^2}{12}$，但 $T$ 中只计入了 $2w^2$。补上 $S=\sum \limits_{e \in E} w^2(e)$ 就完全正确了：
$$
\boxed {\text{Var}(r)=\dfrac{S+T}{12}}
$$
只要求出每个 $i$ 对应的 $S+T$ 即可。

维护矩阵 $D_{x,y}=w(x,y)-w(y,x)$，从而
$$
\begin{aligned}
b_x&=\sum_{y} D_{x,y}\\
S&=\sum_{x < y} D^2_{x,y}\\
T&=\sum_{x} b_x^2
\end{aligned}
$$
对 $S_1 \sim S_n$ 建立 Trie 树，逐位读入 $S_i$ 转移。设当前转移边为字符 $x$，枚举兄弟边 $y$，动态维护
$$
D_{x,y} \gets D_{x,y} + \text{sz}_{\delta(u,y)}\\
D_{y,x} \gets D_{y,x} - \text{sz}_{\delta(u,y)}
$$
在终止状态计算答案即可，容易做到 $O(L |\Sigma|^2)$。

优化是简单的，维护 $b_x$ 后对于 $D$ 的单点修改容易 $O(1)$ 更新 $S,T$。注意修改后要撤销而非清空，复杂度才是对的。

总复杂度 $O(L |\Sigma|)$。[代码](https://www.cnblogs.com/stripe-python/p/23348906)。

:::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。$AKB604$, '数学', array['题解'], null, '暂未评定', 'problem');

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
