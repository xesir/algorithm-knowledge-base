-- ============================================================
-- 后台上传：2026QB 济南集训《外培高阶科技与凸优化衍义》分板块入库
-- 作者：GhostSilver
-- 方式：直接调用 public.admin_publish_column(jsonb)（不走工单、不走审批）
-- 前置：phase20-guard-overwrites.sql 已执行；作者 GhostSilver 已 active
-- 说明：8 个知识点板块；分类 / 标签 / 关系 / parent_key 与站点既有条目一致。
-- 可重复执行：每个板块自动判断
--   - column_key 不存在 → mode=insert；
--   - 已存在 → 读取当前 updated_at，改用 mode=update + expected_updated_at。
--   所以重复执行不会报「column_key 已存在」，也不会覆盖他人更新。
-- 在 Supabase SQL Editor 整段执行。
-- ============================================================

-- ---------- 执行前检查 ----------
select nickname, status, role
from public.profiles
where nickname = 'GhostSilver';

select column_key, column_name, status, updated_at
from public.columns
where column_key like 'sub-admin-ghost-%'
order by column_key;

select column_key, column_name
from public.columns
where column_key in (
    'col-hub-dp', 'col-hub-math', 'col-hub-ds',
    'col-ds-segtree-basic', 'col-dp-linear-overview',
    'col-math-gcd-lcm', 'col-math-quick-pow-basic', 'col-math-sieve',
    'col-ds-block-decomposition', 'col-ds-st-table-1', 'col-ds-rmq-overview'
)
order by column_key;

-- ---------- 写入 8 个板块（自动 insert / update） ----------
do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-convex-slope",
  "author_name": "GhostSilver",
  "column_name": "外培 · 凸性、切线对偶与斜率优化",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 离散凸函数的一阶差分与几何直观；\n- Legendre–Fenchel 对偶变换与截距极值；\n- 外培 10.06 模拟赛 T3《补贴很爽》（fare）的凸壳切线二分。\n\n## 凸性的数学本质与离散序列\n\n连续情形：定义在凸集上的实值函数 $f(x)$ 若对任意 $x_1,x_2$ 与 $\\lambda\\in[0,1]$ 满足\n\n$$f(\\lambda x_1+(1-\\lambda)x_2)\\le \\lambda f(x_1)+(1-\\lambda)f(x_2),$$\n\n则称 $f$ 为凸函数。几何意义是：函数图像上任意两点连成的割线始终位于图像上方。\n\n竞赛中更常见的是整数集合上的离散序列 $f:\\{1,2,\\dots,n\\}\\to\\mathbb{R}$。令一阶差分\n\n$$\\Delta f(i)=f(i)-f(i-1),$$\n\n若 $\\Delta f(i)\\le \\Delta f(i+1)$，则 $f$ 为（下）凸函数；差分单调不增则称为上凸函数。\n\n凸函数最关键的性质是**局部极值即全局极值**，因此在凸曲面上做三分或二分切线不会陷入伪极值。\n\n## 核心公式 / 状态定义与转移方程\n\nLegendre–Fenchel 变换（凸共轭）：对下凸函数 $f(x)$，给定切线斜率 $k$，\n\n$$f^*(k)=\\sup_x\\,(kx-f(x)).$$\n\n对偶反演定理：若 $f$ 是闭下凸函数，则 $(f^*)^*=f$。原空间中的凸壳与对偶空间中的直线族可以无损互转。\n\n斜率优化中的常见 DP\n\n$$dp[i]=\\min_{j<i}\\bigl(dp[j]+A[i]B[j]+C[i]\\bigr)$$\n\n把决策点写成 $(x_j,y_j)=(B[j],dp[j])$，把当前阶段写成斜率 $k_i=-A[i]$，则求 $\\min_j \\bigl(dp[j]-(-A[i])B[j]\\bigr)$ 就是在对偶空间中求凸包在斜率 $k_i$ 处的切线截距。这也是李超线段树与单调队列维护凸壳能够统一的理论基石。\n\n## 外培实战：补贴很爽（Fare）\n\n有一条包含 $1,2,\\dots,n$ 个站点的道路，两站之间距离为 $d_i$，通行费为 $w_i$。在站点 $i$ 上车支付基础费 $u_i$，在 $i$ 下车支付 $v_i$。国家设定的补贴单价为非负整数 $K$，乘客从 $l$ 站上车、在 $r$ 站下车（$l<r$）的自费金额为\n\n$$\\operatorname{Cost}(l,r;K)=u_l+v_r+\\sum_{i=l+1}^{r}w_i-K\\sum_{i=l+1}^{r}d_i.$$\n\n给出 $q$ 次独立询问，每次给定区间 $[L,R]$，求最大的非负整数 $K$，使得区间内任意行程的费用均非负：\n\n$$\\forall L\\le l<r\\le R,\\quad \\operatorname{Cost}(l,r;K)\\ge 0.$$\n\n数据范围：$n,q\\le 5\\times 10^5$。\n\n令 $D_i=\\sum_{j=1}^{i}d_j$，$W_i=\\sum_{j=1}^{i}w_j$，则\n\n$$\\operatorname{Cost}(l,r;K)=(u_l-W_l+K D_l)+(v_r+W_r-K D_r)\\ge 0.$$\n\n移项得到\n\n$$K\\le \\frac{(v_r+W_r)+(u_l-W_l)}{D_r-D_l}.$$\n\n记 $P_l=(D_l,\\,-(u_l-W_l))$，$Q_r=(D_r,\\,v_r+W_r)$，上式右侧正是 $P_l$ 与 $Q_r$ 两点连线的斜率。问题转化为：在区间 $[L,R]$ 内找所有 $l<r$ 的点对中连线斜率的最小值。\n\n利用静态区间分治（类似猫树/线段树的分治结构）：对当前区间 $[lo,hi]$ 与中点 $mid$，任意跨中点的点对满足 $l\\le mid<r$；左侧点集落在上凸壳上，右侧点集落在下凸壳上。分别建壳后二分切线，线段树维护分治节点的前缀/后缀答案，整题做到 $O((n+q)\\log^2 n)$。\n\n```cpp\n// fare.cpp 中的凸包构建与切线判定核心\ninline i128 cross(int a, int b, int c, bool upper) {\n    i64 ya = upper ? yl(a) : yr(a);\n    i64 yb = upper ? yl(b) : yr(b);\n    i64 yc = upper ? yl(c) : yr(c);\n    return (i128)(D[b] - D[a]) * (yc - ya) - (i128)(yb - ya) * (D[c] - D[a]);\n}\n\n// 判定从 l1 到 r1 的斜率是否严格小于从 l2 到 r2 的斜率\ninline bool slopeLess(int l1, int r1, int l2, int r2) {\n    return (i128)(yr(r1) - yl(l1)) * (D[r2] - D[l2]) < (i128)(yr(r2) - yl(l2)) * (D[r1] - D[l1]);\n}\n\n// 在单侧凸壳上二分寻找切点斜率\nint tangentLeft(const vector<int> &h, int r) {\n    int l = 0, t = (int)h.size() - 1;\n    while (l < t) {\n        int m = (l + t) / 2;\n        if (slopeLess(h[m + 1], r, h[m], r)) l = m + 1;\n        else t = m;\n    }\n    int x = h[l];\n    i64 num = yr(r) - yl(x), den = D[r] - D[x];\n    return (int)min<i64>(KMAX, num / den);\n}\n```\n\n## 复杂度分析\n\n分治树每一层对每个点只进入一次凸壳，建壳与二分为 $O(n\\log n)$；每次询问沿 $O(\\log n)$ 个分治节点取答案，单次 $O(\\log n)$。总复杂度 $O((n+q)\\log^2 n)$，空间 $O(n\\log n)$。\n\n## 常见陷阱与注意事项\n\n- 叉积与斜率比较必须用 128 位整数，$D$ 与 $y$ 的乘积会超过 64 位。\n- 由于 $l<r$，$D_r-D_l>0$ 恒成立，比较斜率时可以直接交叉相乘而不用讨论分母符号。\n- $K$ 要求非负整数，切线截距算出的实数上界要向下取整，并与 $0$ 取 $\\max$。\n- 上凸壳/下凸壳的方向容易写反：左侧取上凸壳、右侧取下凸壳，才能让连线斜率最小。\n- 分治区间跨中点时，左右点集的横坐标天然有序，不要再排序破坏下标关系。\n\n## 对比与扩展\n\n斜率优化、凸壳二分、李超线段树、WQS 二分都可以放到「凸共轭 + 切线截距」的统一框架里理解：区别只在于维护凸壳的数据结构、以及切线斜率是否单调。把问题化成点与斜率之后，先问「斜率单调吗、插入有序吗」，再决定用单调队列、二分、李超树还是分治。",
  "category": "动态规划",
  "tags": [
    "凸优化",
    "斜率优化",
    "凸壳",
    "对偶",
    "外培"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-dp"
    },
    {
      "type": "related",
      "target": "col-ds-segtree-basic"
    }
  ],
  "parent_key": "col-hub-dp"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-wqs-lagrange",
  "author_name": "GhostSilver",
  "column_name": "外培 · WQS 二分与拉格朗日松弛本质",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 凸对偶与拉格朗日松弛（Lagrangian Relaxation）的理论闭环；\n- 识别破坏最优子结构的罪魁祸首：约束贴标签法；\n- 10.06 模拟赛 T4《二区兄弟》的奇偶匹配与状态压缩解耦；\n- 整数三点共线陷阱与决策平移边界。\n\n## 从拉格朗日松弛看 WQS 二分\n\n面对「恰好选 $k$ 个特殊元素」的题目，模板化的 WQS 二分（带权二分 / Alien's Trick）是给特殊元素的代价加上 $\\lambda$ 再二分 $\\lambda$。真正需要理解的是它来自拉格朗日松弛：\n\n$$\\text{原问题：}\\min_{x\\in X} f(x)\\quad \\text{s.t. } g(x)=k,$$\n\n引入乘子 $\\lambda$ 后\n\n$$L(x,\\lambda)=f(x)+\\lambda\\bigl(g(x)-k\\bigr),$$\n\n固定 $\\lambda$ 的子问题\n\n$$\\min_{x\\in X}\\bigl(f(x)+\\lambda g(x)\\bigr)$$\n\n不再受「总数必须等于 $k$」的硬约束，往往退化为贪心、树形 DP 或最小生成树。\n\n## 核心公式 / 状态定义与转移方程\n\n松弛后的最优值是关于 $k$ 的凸（或凹）函数 $F(k)$。在平面 $(g(x),f(x))$ 上，引入单价 $\\lambda$ 后寻找最优点，等价于找一条斜率为 $-\\lambda$ 的支持线去切凸壳，切点截距就是子问题答案。\n\nWQS 二分的适用前提不是「题目长得像模板」，而是：\n\n1. 被约束指标的真实最优值曲线 $F(k)$ 具有凸性；\n2. 对固定 $\\lambda$ 的子问题可以高效求解；\n3. 能通过比较「选了多少个」来调整 $\\lambda$。\n\n## 外培思维迁移：给破坏者贴上价格标签\n\n外培资料《从 WQS 二分的思维模型推导本题思路》给出了一条思维链条：\n\n> 所谓松弛，就是给破坏最优子结构的罪魁祸首贴上价格标签。\n\n破坏者不一定表现为「选了多少个物品」，也可能表现为带后效性的回退动作，例如：\n\n- 带权网络中「一旦触发警报就强制遣返起点 $1$」；\n- 树形结构中「选取的边数导致局部子树状态呈现特定奇偶性」。\n\n只要原问题关于被约束指标的曲线具有凸性，就可以把破坏者变成惩罚项，再用二分单价逼近目标 $k$。\n\n## 外培实战：二区兄弟（约束解耦）\n\n给定以 $1$ 为根的 $n$ 个结点的带权树，选取恰好 $K$ 条边得到森林 $F$。对每个结点 $u$，令 $F_u$ 为原树 $u$ 的子树内保留的森林。记 $E_u,O_u$ 分别为 $F_u$ 中包含偶数条边、奇数条边的匹配数量，要求对每个结点 $u$ 都有\n\n$$\\lvert E_u-O_u\\rvert=1.$$\n\n求保留边权值和的最大值。$n\\le 3000$。\n\n记 $U_x=E_x-O_x$。把匹配差值写成 $-1$ 的幂次后，有容斥递推\n\n$$U_x=\\prod_{y\\in son(x)}U_y\\left(1-\\sum_{\\substack{y\\in son(x)\\\\(x,y)\\in F}}S_y\\right),\\qquad S_y\\in\\{-1,1\\}.$$\n\n要满足 $\\lvert U_x\\rvert=1$，必须保证 $\\sum_y S_y\\in\\{0,2\\}$。\n\n直接把差值记进状态，值域高达 $O(n)$，树形背包会退化到 $O(n^3)$ 以上。讲义给出的突破口是随机 $\\pm1$ 游走引理：\n\n**引理（随机 $\\pm1$ 游走最大值界）** 总和为 $O(1)$ 的随机 $\\pm1$ 游走前缀和，其期望最大绝对值仅为 $O(\\sqrt n)$，且满足集中不等式\n\n$$\\Pr\\left[M\\ge \\max\\left(\\sum s_i,0\\right)+t\\right]\\le 2\\exp\\left(-\\frac{t^2}{4n}\\right).$$\n\n因此只要在转移前对每个结点的儿子顺序做一次伪随机打乱（shuffle），状态值域就被压缩到 $O(\\sqrt n)$，总复杂度降到 $O(n^{5/2})$。再对选边数 $K$ 做 WQS 带权二分，复杂度还能进一步下降。\n\n## 整数域上的三点共线陷阱与边界规范\n\n编写 WQS 二分最容易爆零的暗礁是三点共线：存在多个决策点具有完全相同的斜率 $\\lambda$。\n\n- 若二分目标是刚好取到 $k$，而 DP 为打破平局默认选择「尽量少选特殊边」，那么共线段上二分找到的计数永远可能小于 $k$；\n- $\\lambda$ 稍微增大，切点滑向左端点；稍微减小，切点滑向右端点，导致永远命不中 $cnt=k$。\n\n统一对策：**DP 平局时的贪心偏好必须与二分边界更新方向严格同向**。\n\n1. 若二分寻找使 $cnt\\ge k$ 的最小 $\\lambda$，则 DP 遇到权值相等时必须优先转移 $cnt$ 较大的方案；\n2. 还原答案必须用 $dp[n]-k\\cdot\\lambda$，不能用 $dp[n]-cnt\\cdot\\lambda$；共线段上各点切线截距相等，只有用目标 $k$ 还原才能扣掉正确的松弛罚款。\n\n## 复杂度分析\n\n设随机打乱后状态值域为 $O(\\sqrt n)$，单次树形背包为 $O(n\\sqrt n)$ 量级；外层 WQS 二分 $O(\\log V)$ 次，总复杂度约 $O(n^{5/2}\\log V)$（讲义给出的主结论是 $O(n^{5/2})$ 级别的降维）。空间为 $O(n\\sqrt n)$。\n\n## 常见陷阱与注意事项\n\n- 先确认 $F(k)$ 的凸性；曲线不凸时 WQS 二分不成立。\n- 平局偏好与二分方向必须一致，否则共线段上计数不单调。\n- 还原答案用目标 $k$，不要用 DP 返回的 $cnt$。\n- 二分上下界要覆盖所有可能的单价，且用整数二分避免精度问题。\n- 随机打乱只改变儿子顺序，不改变树的父子关系；不要影响题目要求的匹配定义。\n\n## 对比与扩展\n\nWQS 二分、斜率优化、凸壳二分共享同一套「凸对偶 + 切线截距」语言。区别是 WQS 二分把「个数约束」变成单价，斜率优化把「转移代价」变成斜率。遇到「恰好 / 至少选 k 个」且内层可贪心或可树形 DP 的题，先试 WQS；遇到「转移含 i、j 乘积」的题，先试斜率优化。",
  "category": "动态规划",
  "tags": [
    "WQS二分",
    "拉格朗日松弛",
    "带权二分",
    "凸性",
    "外培"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-dp"
    },
    {
      "type": "related",
      "target": "col-dp-linear-overview"
    }
  ],
  "parent_key": "col-hub-dp"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-slope-trick",
  "author_name": "GhostSilver",
  "column_name": "外培 · Slope Trick：凸折线函数的对顶堆维护",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 连续凸折线的代数表述与拐点（Critical Points）多重集；\n- 对顶堆维护：加绝对值函数、平移与前缀极值；\n- 经典模型：序列保序单调化与 Codeforces 713C；\n- 树上 Slope Trick 与可并堆（Leftist Heap）进阶。\n\n## 数据结构图示\n\nSlope Trick 维护的是凸折线 $f(x)$ 的一阶导数跳变点。一个下凸折线可以由四要素唯一确定：\n\n1. 某一基准点 $x_0$ 处的极小值 $f(x_0)$；\n2. 斜率为 $0$ 的平坦谷底区间 $[L,R]$；\n3. 斜率小于 $0$ 的拐点多重集 $S_L$（左侧大根堆）；\n4. 斜率大于 $0$ 的拐点多重集 $S_R$（右侧小根堆）。\n\n```\n            slope -2      slope 0        slope +2\n      \\        |            ____            |\n       \\       |       ____/    \\____       |\n        \\______|______/               \\______|\n           SL 拐点   L      R        SR 拐点\n```\n\n## 核心操作详解\n\n### 操作一：加上 $\\lvert x-a\\rvert$\n\n$\\lvert x-a\\rvert$ 的导数在 $x<a$ 时为 $-1$，在 $x>a$ 时为 $+1$。给当前函数加上它，等价于在 $a$ 左侧所有区域斜率减 $1$、右侧加 $1$，也就是向拐点系统中注入一个新拐点 $a$。\n\n- 若 $a$ 落在当前谷底 $[L,R]$：把 $a$ 分别插入左堆 $S_L$ 与右堆 $S_R$，最小值不变；\n- 若 $a<L$：新最优点向左漂移，最小值增加 $L-a$；弹出 $L$ 压入右堆，再把 $a$ 两次压入左堆；\n- 若 $a>R$：对称处理。\n\n### 操作二：前缀最小值 $g(x)=\\min_{y\\le x}f(y)$\n\n由于 $f$ 下凸，越过谷底后函数单调递增。取前缀最小值相当于把所有 $x>R$ 的斜率强制削平为 $0$，在数据结构上就是**直接清空右侧小根堆 $S_R$**。\n\n### 操作三：左右滑动与伸缩\n\n若转移形如 $g(x)=\\min_{x-b\\le y\\le x-a}f(y)$，几何上相当于把谷底向左平移 $a$、向右平移 $b$，即谷底被拉伸为长度增加 $b-a$ 的平坦区间。用全局偏移量（Lazy Tag）给左堆元素加 $a$、右堆元素加 $b$ 即可。\n\n> 讲义按「四类原子操作」组织；除上面三类外，常见的还有「整体加上一次函数」，它只改变最小值基准，不改变拐点集合。\n\n## 核心公式 / 状态定义与转移方程\n\n序列单调化模型：给定序列 $a_1,\\dots,a_n$，每次可以把一个数 $\\pm1$，要求变成严格递增序列 $b$，最小化操作次数。\n\n令 $a'_i=a_i-i$，严格递增化为非严格递增 $b'_1\\le\\cdots\\le b'_n$。设 $dp[i][x]$ 表示前 $i$ 个数调整完毕、且第 $i$ 个数不超过 $x$ 的最小代价：\n\n$$dp[i][x]=\\min_{y\\le x}dp[i-1][y]+\\lvert x-a'_i\\rvert.$$\n\n这就是标准 Slope Trick：先做前缀最小值（清空右堆），再加绝对值函数（按左堆顶更新最小值并插入拐点）。\n\n## 逐行代码解析\n\n```cpp\n#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    ios::sync_with_stdio(false);\n    cin.tie(nullptr);\n    int n;\n    if (!(cin >> n)) return 0;\n    priority_queue<long long> q;\n    long long ans = 0;\n    for (int i = 1; i <= n; i++) {\n        long long a;\n        cin >> a;\n        a -= i; // 转化为非严格递增\n        q.push(a);\n        if (q.top() > a) {\n            ans += q.top() - a;\n            q.pop();\n            q.push(a);\n        }\n    }\n    cout << ans << \"\\n\";\n    return 0;\n}\n```\n\n- $a\\leftarrow a-i$ 把严格递增转成非严格递增，避免处理相等元素的额外讨论。\n- 大根堆维护左堆拐点；堆顶是当前谷底左端点。\n- 当堆顶大于 $a$ 说明新拐点落在谷底左侧，最小值增加 `q.top() - a`，并做一次拐点替换。\n- 全程只用一个小根/大根堆，时间复杂度 $O(n\\log n)$，空间 $O(n)$。\n\n## 复杂度分析\n\n每个元素最多入堆、出堆各一次，单次 $O(\\log n)$；总时间 $O(n\\log n)$，空间 $O(n)$。\n\n## 适用场景\n\n- DP 的第二维是连续或很大的数值变量，但代价函数是凸的分段一次函数；\n- 转移中反复出现加 $\\lvert x-a\\rvert$、取前缀/后缀最小值、整体平移；\n- 树上 DP 中儿子合并后需要维护凸折线（可并堆/左偏树）。\n\n## 常见陷阱与注意事项\n\n- 严格递增转非严格递增要减 $i$，不是减 $1$。\n- 最小值累加要用 64 位整数。\n- 清空右堆只适用于取前缀最小值；取后缀最小值时清空左堆。\n- 谷底区间 $[L,R]$ 的边界要同步维护，否则加绝对值时判断会错。\n- 平移操作必须用全局偏移量，不能真的遍历堆。\n\n## 对比与扩展\n\n与普通 DP 相比，Slope Trick 把「枚举状态值」变成「维护导数跳变点」，把 $O(nV)$ 压到 $O(n\\log n)$。与李超线段树相比，Slope Trick 只适用于凸折线且转移是「加绝对值/取最值」的特定形态，但常数和码量都更小。",
  "category": "动态规划",
  "tags": [
    "SlopeTrick",
    "凸折线",
    "对顶堆",
    "DP优化",
    "外培"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-dp"
    },
    {
      "type": "related",
      "target": "col-dp-linear-overview"
    }
  ],
  "parent_key": "col-hub-dp"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-binary-gcd",
  "author_name": "GhostSilver",
  "column_name": "外培 · Binary GCD：硬件级消灭除法常数",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 欧几里得除法在现代 CPU 架构下的流水线惩罚；\n- Stein 算法的移位、减法与位运算重构；\n- `__builtin_ctz` 硬件指令加速；\n- 外培课件重点推荐：单题压常数通过洛谷 P5435。\n\n## 痛点：被取模运算拖垮的 CPU 流水线\n\n求最大公约数是最常见的数论原语：\n\n```cpp\nlong long gcd(long long a, long long b) {\n    return b == 0 ? a : gcd(b, a % b);\n}\n```\n\n渐进复杂度是 $O(\\log\\min(a,b))$，但现代处理器上隐藏着性能陷阱：\n\n- 64 位整数除法/取模（如 x86 的 `idiv`）通常需要 15–80 个时钟周期，而加减与按位运算只要 1 个周期；\n- 辗转相除的步数不固定，破坏流水线与分支预测。\n\n在 P5435 这类需要上百万次区间 gcd 查询的卡常题中，朴素 gcd 会 TLE，Binary GCD 常能带来 3–5 倍常数级提速。\n\n## 核心公式 / 状态定义与转移方程\n\nStein 算法（Binary GCD）完全剔除除法与取模，只用移位和减法：\n\n1. 若 $a=0$ 或 $b=0$，则 $\\gcd(a,b)=a+b$；\n2. 若 $a,b$ 均为偶数：$\\gcd(a,b)=2\\gcd(a/2,b/2)$；\n3. 若 $a$ 偶、$b$ 奇：$\\gcd(a,b)=\\gcd(a/2,b)$；对称地 $a$ 奇、$b$ 偶时 $\\gcd(a,b)=\\gcd(a,b/2)$；\n4. 若 $a,b$ 均为奇数：利用更相减损术 $\\gcd(a,b)=\\gcd(\\lvert a-b\\rvert,\\min(a,b))$。\n\n两个奇数相减的结果必为偶数，下一步可以立即右移除 $2$，规模快速下降。\n\n## 逐行代码解析\n\n```cpp\n#include <algorithm>\n\n// 32 位无符号整型极致常数 Binary GCD\ninline unsigned int binary_gcd(unsigned int a, unsigned int b) {\n    if (!a || !b) return a | b;\n    int shift = __builtin_ctz(a | b); // 记录两数公共的 2 因子幂次\n    a >>= __builtin_ctz(a);          // 剥离 a 的所有 2 因子，使 a 为奇数\n\n    do {\n        b >>= __builtin_ctz(b);      // 剥离 b 的所有 2 因子，使 b 为奇数\n        if (a > b) std::swap(a, b);  // 保持 a <= b\n        b -= a;                      // 两奇相减，结果必为偶数或 0\n    } while (b);\n    return a << shift;               // 恢复公共的 2 因子\n}\n\n// 64 位整型对应版本\ninline unsigned long long binary_gcd64(unsigned long long a, unsigned long long b) {\n    if (!a || !b) return a | b;\n    int shift = __builtin_ctzll(a | b);\n    a >>= __builtin_ctzll(a);\n    do {\n        b >>= __builtin_ctzll(b);\n        if (a > b) std::swap(a, b);\n        b -= a;\n    } while (b);\n    return a << shift;\n}\n```\n\n- `__builtin_ctz` / `__builtin_ctzll` 直接对应 x86 的 `TZCNT`/`BSF`，ARM 上可映射到 `RBIT + CLZ`，单周期完成「末尾连续 0 的个数」。\n- `shift` 记录两数公共的 $2$ 因子幂次，循环结束再左移还原。\n- 循环内 `b -= a` 后 `b` 必为偶数，下一轮 `b >>= ctz(b)` 至少右移一位，实测单次调用循环不超过二十余次。\n- 全程没有除法/取模，指令吞吐接近硬件极限。\n\n## 复杂度分析\n\n每次循环至少消掉一个 $2$ 因子或让两数规模明显下降，时间 $O(\\log\\min(a,b))$，但常数远小于取模版本；空间 $O(1)$。\n\n## 适用场景\n\n- 高频 gcd 查询、卡常题（如 P5435）；\n- 需要避免除法指令的嵌入式/竞赛环境；\n- 与倍增、筛法、数论分块配合的底层原语。\n\n## 常见陷阱与注意事项\n\n- 必须特判 $a=0$ 或 $b=0$，否则 `ctz(0)` 是未定义行为。\n- 使用无符号整型；有符号右移与 `ctz` 的语义容易出错。\n- 公共 $2$ 因子只能还原一次，`shift` 不要在多处重复左移。\n- 64 位版本要用 `__builtin_ctzll`，不要误用 32 位版本。\n- 平台不支持内建函数时需提供回退实现（循环右移），否则编译不过。\n\n## 对比与扩展\n\n与欧几里得算法相比，Binary GCD 用更多次减法换取没有除法；在最坏情况下迭代次数略多，但常数优势明显。与 `std::gcd` 相比，它在卡常场景更稳；日常代码直接用标准库即可。",
  "category": "数学",
  "tags": [
    "BinaryGCD",
    "Stein算法",
    "卡常",
    "位运算",
    "数论"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-math"
    },
    {
      "type": "related",
      "target": "col-math-gcd-lcm"
    }
  ],
  "parent_key": "col-hub-math"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-fast-pow-block",
  "author_name": "GhostSilver",
  "column_name": "外培 · 光速幂：O(1) 吞吐高频指数查询",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 大规模询问场景下的常规快速幂瓶颈；\n- Baby-Step Giant-Step 阈值分块思想；\n- 预处理 $O(\\sqrt P)$ 与单次严格 $O(1)$ 查询；\n- 考场工程实现与模数溢出防御。\n\n## 痛点：$O(Q\\log P)$ 在千万级询问下的极限崩塌\n\n给定固定底数 $a$ 和模数 $P$，随后 $Q$ 次独立询问，每次给定大指数 $k$，要求输出 $a^k\\bmod P$。其中 $P\\le 10^9$，$Q\\le 10^7$。\n\n逐次快速幂的总代价约\n\n$$T_{\\text{total}}=O(Q\\log P)\\approx 10^7\\times 30=3\\times 10^8$$\n\n次乘法；在 1 秒时限下，乘法和取模的常数开销必然导致超时。光速幂（分块快速幂）就是为此准备的卡常科技。\n\n## 核心公式 / 状态定义与转移方程\n\n光速幂与 BSGS（Baby-Step Giant-Step）同源，核心是平方根分块平衡：\n\n取步长 $B=\\lceil\\sqrt P\\rceil$（$P\\le 10^9$ 时约 $31623$，常用 $32768=2^{15}$ 或 $65536=2^{16}$）。任意 $0\\le k<P$ 可唯一写成\n\n$$k=j\\cdot B+i,\\qquad 0\\le i<B,\\quad 0\\le j\\le\\lceil P/B\\rceil.$$\n\n由指数加法同态性，\n\n$$a^k=a^{jB+i}\\equiv (a^B)^j\\cdot a^i\\pmod P.$$\n\n预处理两张表：\n\n- 小步表 $T_1[i]=a^i\\bmod P$，$0\\le i<B$；\n- 大步表 $T_2[j]=(a^B)^j=a^{jB}\\bmod P$，$0\\le j\\le\\lceil P/B\\rceil$。\n\n查询时\n\n$$\\text{Ans}=T_2[j]\\cdot T_1[i]\\bmod P.$$\n\n## 逐行代码解析\n\n```cpp\n#include <vector>\n\ntemplate <long long Mod>\nstruct FastPow {\n    static constexpr int B = 65536; // 选取 2^16 作为分块基底，支持位运算极速寻址\n    long long t1[B];\n    long long t2[B];\n\n    void init(long long base) {\n        base %= Mod;\n        t1[0] = 1;\n        for (int i = 1; i < B; i++) {\n            t1[i] = (t1[i - 1] * base) % Mod;\n        }\n        long long big_base = (t1[B - 1] * base) % Mod; // base^B\n        t2[0] = 1;\n        for (int j = 1; j < B; j++) {\n            t2[j] = (t2[j - 1] * big_base) % Mod;\n        }\n    }\n\n    // 严格 O(1) 且完全消除除法指令的极速查询\n    inline long long query(unsigned long long k) const {\n        unsigned int i = k & (B - 1); // k % B\n        unsigned int j = k >> 16;     // k / B\n        return (t2[j] * t1[i]) % Mod;\n    }\n};\n```\n\n- `B` 取 $2$ 的幂，`k & (B-1)` 与 `k >> 16` 分别替代取模与整除。\n- `t1` 存 $a^i$，`t2` 存 $(a^B)^j$，查询一次模乘即可。\n- `base %= Mod` 防止底数溢出；`t1[B-1]*base` 求 $a^B$。\n- 该实现假定 $k<2^{32}$（因为 `t2` 只有 $B$ 项，`j=k>>16` 必须小于 $B$）；本题 $k<P\\le10^9$ 满足。\n\n## 复杂度分析\n\n预处理 $O(B+P/B)=O(\\sqrt P)$（取 $B\\approx\\sqrt P$）；单次查询 1 次整除、1 次取模、1 次模乘，严格 $O(1)$。空间为两张长度 $B$ 的数组，约几 MB 以内。实测千万次询问可从 1.2 秒压到 0.08 秒以下。\n\n## 适用场景\n\n- 固定底数、固定模数、海量指数询问；\n- 树上倍增、递推数列、组合计数中反复求同一底数的幂；\n- 与数论分块、BSGS 同源的平方根平衡场景。\n\n## 常见陷阱与注意事项\n\n- 底数先取模；模数为 1 时答案恒为 0，要特判。\n- 指数范围必须小于 $B^2$；超过时要改用多级分块或扩展大步表。\n- 取 $B=2^{16}$ 时数组是静态成员，注意内存与栈/全局限制。\n- `t1[B-1] * base` 可能超过 32 位，乘法用 64 位。\n- 预处理只做一次；多组数据共用同一底数时不要重复初始化。\n\n## 对比与扩展\n\n常规快速幂单次 $O(\\log P)$，光速幂用 $O(\\sqrt P)$ 预处理换 $O(1)$ 查询；询问次数越多越划算。与 BSGS 的区别是：BSGS 用两张表反解离散对数，光速幂直接用两张表拼出幂值。",
  "category": "数学",
  "tags": [
    "光速幂",
    "BSGS",
    "分块",
    "快速幂",
    "卡常"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-math"
    },
    {
      "type": "related",
      "target": "col-math-quick-pow-basic"
    }
  ],
  "parent_key": "col-hub-math"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-linear-sieve",
  "author_name": "GhostSilver",
  "column_name": "外培 · 线性筛：积性函数与高阶序列构造",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 欧拉线性筛「每个合数只被其最小质因子筛去」的本质；\n- 外培真题：在 $O(n)$ 时间内对所有 $1\\le i\\le n$ 求解 $i^k$；\n- 常见积性函数（$\\mu,\\varphi,d,\\sigma$）的统一线性递推模板；\n- 杜教筛与 min25 筛的前置小表基石。\n\n## 线性筛的核心不变量\n\n埃氏筛的瓶颈是同一个合数会被多个质因子重复标记，复杂度带 $\\log\\log n$ 的冗余。欧拉线性筛通过严格的循环不变量做到绝对 $O(n)$：\n\n> 任何一个合数 $x$，有且仅有在其最小质因子 $p$ 遍历到 $x/p$ 时被标记并筛去一次。\n\n代码里由一句控制语句守护：\n\n```cpp\nif (i % primes[j] == 0) break;\n```\n\n证明：当遍历到 $i\\bmod p_j=0$ 时，$p_j$ 是 $i$ 的因子，也是 $i$ 的最小质因子。如果继续用更大的质数 $p_{j+1}$ 去筛 $x'=i\\cdot p_{j+1}$，则 $x'$ 的最小质因子显然是 $p_j$ 而不是 $p_{j+1}$，它将来必然会在外层 $i'=x'/p_j$ 处被 $p_j$ 重新筛掉，破坏线性复杂度。因此必须在此处中断。\n\n## 核心公式 / 状态定义与转移方程\n\n外培真题：给定 $n,k$（$n,k$ 同阶，最高 $10^7$），要求在严格 $O(n)$ 内对所有 $1\\le i\\le n$ 求出 $i^k\\bmod P$。\n\n关键观察：$f(i)=i^k$ 是完全积性函数，\n\n$$(x\\cdot y)^k=x^k\\cdot y^k.$$\n\n在线性筛遍历中：\n\n- 若 $i$ 为质数：直接调用快速幂计算 $i^k$。由素数定理，$\\le n$ 的质数约 $n/\\ln n$ 个，这部分总代价 $O\\!\\left(\\frac{n}{\\ln n}\\log k\\right)=O(n)$（当 $k\\approx n$）；\n- 若 $x=i\\cdot p_j$ 为合数：利用完全积性直接转移\n\n$$x^k=(i\\cdot p_j)^k=i^k\\cdot p_j^k\\pmod P,$$\n\n只需 1 次模乘，单次转移 $O(1)$。\n\n## 逐行代码解析\n\n```cpp\n#include <vector>\n\nvoid precompute_powers(int n, long long k, long long mod, std::vector<long long> &pw) {\n    pw.assign(n + 1, 0);\n    std::vector<int> primes;\n    std::vector<bool> is_prime(n + 1, true);\n    pw[1] = 1;\n\n    for (int i = 2; i <= n; i++) {\n        if (is_prime[i]) {\n            primes.push_back(i);\n            pw[i] = qpow(i, k, mod); // 仅质数计算快速幂，总耗时 O(n)\n        }\n        for (int p : primes) {\n            if (i * p > n) break;\n            is_prime[i * p] = false;\n            pw[i * p] = (pw[i] * pw[p]) % mod; // 完全积性 O(1) 转移\n            if (i % p == 0) break;\n        }\n    }\n}\n```\n\n- 只对质数调用 `qpow`，合数全部用完全积性 $O(1)$ 转移。\n- `pw[1] = 1` 是空积的约定。\n- `if (i % p == 0) break;` 保证每个合数只被最小质因子筛一次。\n- `i * p` 在 $n\\le10^7$ 时不会溢出 `int`；更大范围要开 `long long`。\n\n## 常见积性函数统一递推\n\n| 函数 | 数学定义 | 质数处取值 | 同质因子倍增转移（$i\\bmod p=0$） |\n|---|---|---|---|\n| 莫比乌斯函数 $\\mu(n)$ | 无平方因子奇偶性 | $\\mu(p)=-1$ | $\\mu(i\\cdot p)=0$ |\n| 欧拉函数 $\\varphi(n)$ | 互质数个数 | $\\varphi(p)=p-1$ | $\\varphi(i\\cdot p)=\\varphi(i)\\cdot p$ |\n| 约数个数 $d(n)$ | 因子总数 | $d(p)=2$ | 记录最小质因子次数 $c_i$：$d(i\\cdot p)=d(i)/(c_i+1)\\cdot(c_i+2)$ |\n| 约数和 $\\sigma(n)$ | 因子之和 | $\\sigma(p)=p+1$ | 记录质因子等比和 $g_i$：$\\sigma(i\\cdot p)=\\sigma(i)/g_i\\cdot(g_i\\cdot p+1)$ |\n\n掌握这套方法论后，遇到任何定义新颖的积性函数，只要完成因式分解并套用最小质因子转移法则，都能在 $O(n)$ 内线性处理。\n\n## 复杂度分析\n\n每个合数只被筛一次，质数处快速幂总代价 $O(n)$，总时间 $O(n)$；空间为 `pw`、`primes`、`is_prime` 三个长度 $O(n)$ 的数组。\n\n## 适用场景\n\n- 需要预处理积性函数前缀和、杜教筛/min25 筛的小表；\n- 需要一次性求出所有 $i^k$、$i!$ 之类的完全积性量；\n- 多组询问共用同一上界 $n$ 的数论题。\n\n## 常见陷阱与注意事项\n\n- `break` 条件写错会退化成 $O(n\\log\\log n)$ 甚至重复筛。\n- 记录最小质因子次数/等比和时，数组要与 `pw` 同步维护。\n- 模数可能为 1 或很小，快速幂与转移都要先取模。\n- `i*p` 的溢出范围要按 $n$ 选择整型。\n- 1 的处理要单独约定（$\\mu(1)=1$，$\\varphi(1)=1$，$d(1)=1$）。\n\n## 对比与扩展\n\n埃氏筛适合只需质数表且 $n$ 不大的场景；线性筛多维护几个数组即可同时求积性函数。杜教筛、min25 筛都依赖这里的小表作为递归边界。",
  "category": "数学",
  "tags": [
    "线性筛",
    "积性函数",
    "欧拉函数",
    "数论",
    "外培"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-math"
    },
    {
      "type": "related",
      "target": "col-math-sieve"
    },
    {
      "type": "related",
      "target": "col-math-gcd-lcm"
    }
  ],
  "parent_key": "col-hub-math"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-operation-blocking",
  "author_name": "GhostSilver",
  "column_name": "外培 · 操作分块：时间维度的根号重构与优雅回滚",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- 动态复杂约束与可撤销数据结构的天然张力；\n- 时间操作分块的「静态骨架 + 动态外挂」双分治哲学；\n- 经典图论连通性维护与可撤销并查集（Rollback DSU）；\n- 平方根平衡参数调优实战。\n\n## 痛点：在线动态修改与复杂数据结构的矛盾\n\n只有静态询问时，可以用离线缩点、重构树、路径压缩并查集等高效算法。一旦加入动态加边、删边、边权修改，并且要求实时回答，常规做法（LCT、动态树）码量大、常数大、极易写挂。\n\n更麻烦的是，路径压缩并查集、凸包维护等结构是**不可撤销**的，或者极难支持删除。操作分块（Operation Blocking / Time-Chunking）提供了一种暴力但极具实战威力的降维方案。\n\n## 核心公式 / 状态定义与转移方程\n\n把操作序列按时间分成若干个大小为 $B$ 的块，总操作数 $M$，共约 $M/B$ 个块。对当前块的时间区间 $[L,R]$（长度至多 $B$）：\n\n1. **分类全图元素**：\n   - 静态元素：在整个 $[L,R]$ 内从未被修改操作触碰过的元素；\n   - 动态元素：在 $[L,R]$ 内至少被修改过一次的元素。由于块长为 $B$，动态元素总数不超过 $B$。\n2. **分治求解**：\n   - 进入块时，把所有静态元素一次性构造成静态全局底座（如全部加入并查集、缩点建图）；\n   - 遍历块内每个时刻，把当前有效的动态元素用可撤销数据结构临时插入底座；\n   - 立即回答当前询问；\n   - 把刚插入的 $O(B)$ 条动态元素逐一撤销，恢复到纯净底座，供下一个询问复用。\n3. **块末更新**：处理完当前块后清空底座，暴力应用所有修改，进入下一块。\n\n## 数据结构图示\n\n```\n块 [L, R]（长度 <= B）\n┌──────────────────────────────────────────┐\n│ 静态底座：块内从未被修改的元素（一次构建） │\n│                                          │\n│ 时刻 t1：临时插入动态元素 -> 回答 -> 回滚 │\n│ 时刻 t2：临时插入动态元素 -> 回答 -> 回滚 │\n│ ...                                      │\n└──────────────────────────────────────────┘\n块末：清空底座，暴力应用本块所有修改\n```\n\n## 核心操作详解\n\n### 可撤销并查集（Rollback DSU）\n\n为了支持动态边临时加入与撤销，并查集**严禁路径压缩**（路径压缩破坏历史父子关系，无法撤销），必须使用按秩合并（Union by Rank / Size）。按秩合并保证树高 $O(\\log n)$，每次合并用一个栈记录修改的节点，回滚单次 $O(1)$。\n\n```cpp\n#include <vector>\n\nstruct RollbackDSU {\n    std::vector<int> parent;\n    std::vector<int> sz;\n    struct History { int u, v; bool merged; };\n    std::vector<History> hist;\n\n    RollbackDSU(int n) : parent(n + 1), sz(n + 1, 1) {\n        for (int i = 1; i <= n; i++) parent[i] = i;\n    }\n\n    int find(int x) {\n        while (x != parent[x]) x = parent[x];\n        return x;\n    }\n\n    bool unite(int u, int v) {\n        u = find(u); v = find(v);\n        if (u == v) {\n            hist.push_back({u, v, false});\n            return false;\n        }\n        if (sz[u] < sz[v]) std::swap(u, v);\n        parent[v] = u;\n        sz[u] += sz[v];\n        hist.push_back({u, v, true});\n        return true;\n    }\n\n    // 回滚单次合并操作\n    void undo() {\n        auto h = hist.back();\n        hist.pop_back();\n        if (h.merged) {\n            sz[h.u] -= sz[h.v];\n            parent[h.v] = h.v;\n        }\n    }\n};\n```\n\n- `find` 用循环且不做路径压缩，保证父子关系可回滚。\n- `unite` 无论是否真的合并都压入历史记录，`undo` 通过 `merged` 区分。\n- 合并时按 `sz` 小的挂到大的下面，树高 $O(\\log n)$。\n\n## 复杂度分析\n\n设点数 $N$、操作数 $M$、块大小 $B$：\n\n- 共 $M/B$ 个块；每块重建底座 $O(N+M)$（或 $O(M\\log N)$）；\n- 块内每个询问暴力处理至多 $B$ 条动态边，撤销 $O(B\\log N)$；\n- 总复杂度\n\n$$T(N,M)=O\\!\\left(\\frac{M}{B}(N+M)\\right)+O(MB\\log N).$$\n\n对 $B$ 求导可得均衡点\n\n$$B\\approx\\sqrt{\\frac{N+M}{\\log N}}.$$\n\n实际取 $B\\approx\\sqrt M$ 或 $\\sqrt{N+M}$ 即可获得较好的均摊效果。\n\n## 适用场景\n\n- 动态图连通性、动态加删边、动态维护生成树/二分图染色；\n- 数据结构不支持删除，但操作序列可以离线分块；\n- 询问与修改交织、单次修改影响范围大（如边权修改）。\n\n## 常见陷阱与注意事项\n\n- 用了路径压缩就无法正确回滚；必须按秩合并。\n- 历史栈要记录「未合并」的情况，否则 `undo` 次数对不上。\n- 块末清空底座后要暴力重放本块修改，不能漏。\n- 动态元素集合要及时清空，避免跨块污染。\n- 块大小 $B$ 需要按 $N,M$ 调参；固定值可能退化。\n\n## 对比与扩展\n\n操作分块与莫队、值域分块、根号重构同属平方根平衡思想：用 $O(\\sqrt M)$ 的暴力换取「复杂结构不可撤销」问题的可做性。相比 LCT，它码量小、常数稳，是省选考场上 30 分钟写完并稳拿全分的实用武器。",
  "category": "数据结构",
  "tags": [
    "操作分块",
    "可撤销并查集",
    "根号重构",
    "回滚",
    "图论"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-ds"
    },
    {
      "type": "related",
      "target": "col-ds-block-decomposition"
    }
  ],
  "parent_key": "col-hub-ds"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;

do $do$
declare
    v_payload jsonb := $akb${
  "mode": "insert",
  "column_key": "sub-admin-ghost-cattree",
  "author_name": "GhostSilver",
  "column_name": "外培 · 猫树：静态结合律半群严格 O(1) 区间合并",
  "description": "2026QB 济南集训 · 外培高阶科技与凸优化衍义",
  "content": "## 内容提要\n\n- ST 表的不可突破瓶颈：幂等性（$x\\circ x=x$）的局限；\n- 猫树（CatTree）的静态满二叉分治结构与前后缀预处理；\n- 硬件级 LCA 深度定位：`__builtin_clz` 的位运算魔法；\n- 静态区间矩阵乘法、线性基与背包合并的极致加速。\n\n## 痛点：ST 表做不了不可重复贡献信息\n\nST 表预处理 $O(n\\log n)$、查询严格 $O(1)$，但成立前提是信息运算符 $\\circ$ 必须满足可重复贡献性（幂等性）：\n\n$$x\\circ x=x.$$\n\n例如 $\\min,\\max,\\gcd$、按位与/或。只有满足幂等性，才能把区间 $[l,r]$ 拆成两个有重叠的子区间并直接合并结果。\n\n如果 $\\circ$ 是不可重复贡献的结合律半群呢？\n\n- 区间矩阵乘法：$A\\times A\\ne A$；\n- 区间线性基合并：插入重复元素会产生不可逆影响；\n- 区间背包卷积：无法容忍重叠子集；\n- 区间非空最大子段和维护。\n\n常规做法只能用线段树，单次查询 $O(\\log n)$ 次合并。若单次合并代价为 $M$，$O(Q\\cdot M\\log n)$ 在 $Q=10^6$ 时会严重 TLE。猫树正是为击碎这一限制而生的静态数据结构。\n\n## 数据结构图示\n\n```\n满二叉树节点管理区间 [L, R]，mid = (L + R) / 2\n\n        ←── 后缀预处理 ──┐        ┌── 前缀预处理 ──→\n   [L ................ mid] [mid+1 ................ R]\n   Suf[l] = A[l]∘...∘A[mid]     Pre[r] = A[mid+1]∘...∘A[r]\n```\n\n对树上每一层的节点区间 $[L,R]$：\n\n1. 不向上递归合并，而是在本节点内部以 $mid$ 为界；\n2. 向左计算后缀：对所有 $L\\le l\\le mid$，存储区间 $[l,mid]$ 的信息；\n3. 向右计算前缀：对所有 $mid<r\\le R$，存储区间 $[mid+1,r]$ 的信息。\n\n满二叉树高度为 $\\lceil\\log_2 n\\rceil$，每层恰好覆盖全序列一次，因此预处理 $O(n\\log n\\cdot \\text{MergeCost})$，空间 $O(n\\log n)$。\n\n## 核心公式 / 状态定义与转移方程\n\n对任意查询 $[l,r]$（$l\\le r$），在满二叉树中必存在唯一最深节点，使 $[l,r]$ 包含在其管理区间内且跨过其中点（$l=r$ 时落在叶子）。该节点正是叶子 $l$ 与叶子 $r$ 的最近公共祖先（LCA），答案由该节点左侧后缀与右侧前缀一次无重叠拼接得到：\n\n$$\\operatorname{Query}(l,r)=\\operatorname{Suf}_{\\mathrm{LCA}}[l]\\circ \\operatorname{Pre}_{\\mathrm{LCA}}[r].$$\n\n完全二叉树的叶编号直接对应下标，求两个叶子的 LCA 层数等价于求 $l\\oplus r$ 的最高位：\n\n$$\\operatorname{Depth}(l,r)=\\text{TreeHeight}-31-\\texttt{\\_\\_builtin\\_clz}(l\\oplus r).$$\n\n一条 `__builtin_clz` 指令即可在单周期内定位 LCA 层级。\n\n## 逐行代码解析\n\n```cpp\n#include <vector>\n#include <cmath>\n\ntemplate <typename T, typename Op>\nstruct CatTree {\n    int n, sz, levels;\n    std::vector<std::vector<T>> data;\n    Op op;\n\n    CatTree(const std::vector<T> &arr, Op op) : op(op) {\n        n = arr.size();\n        levels = (n <= 1) ? 1 : (32 - __builtin_clz(n - 1));\n        sz = 1 << levels;\n        data.assign(levels, std::vector<T>(sz));\n\n        for (int lv = 0; lv < levels; lv++) {\n            int len = 1 << (levels - lv);\n            int half = len >> 1;\n            for (int st = 0; st < sz; st += len) {\n                int mid = st + half;\n                if (mid - 1 < n) {\n                    data[lv][mid - 1] = arr[mid - 1];\n                    for (int i = mid - 2; i >= st; i--) {\n                        if (i < n) data[lv][i] = op(arr[i], data[lv][i + 1]);\n                    }\n                }\n                if (mid < n) {\n                    data[lv][mid] = arr[mid];\n                    for (int i = mid + 1; i < st + len && i < n; i++) {\n                        data[lv][i] = op(data[lv][i - 1], arr[i]);\n                    }\n                }\n            }\n        }\n    }\n\n    // 严格 O(1) 查询任意结合律区间合并\n    inline T query(int l, int r) const {\n        if (l == r) return data.back()[l];\n        int lv = levels - 1 - (31 - __builtin_clz(l ^ r));\n        return op(data[lv][l], data[lv][r]);\n    }\n};\n```\n\n- `levels` 是满二叉树层数，`sz` 是叶子容量。\n- 每层以 `mid` 为界分别向左做后缀、向右做前缀。\n- `query` 用 `l ^ r` 的最高位定位 LCA 所在层，再一次 `op` 合并。\n- `l == r` 直接返回叶子值，避免 `clz(0)`。\n\n## 复杂度分析\n\n预处理 $O(n\\log n\\cdot \\text{MergeCost})$，空间 $O(n\\log n)$；单次查询 $O(1)$（一次结合律合并 + 一次位运算）。对比线段树的 $O(\\log n)$ 次合并，在矩阵、线性基、背包等重合并场景收益巨大。\n\n## 适用场景\n\n- 静态区间查询 + 不可重复贡献的结合律信息（矩阵乘、置换群、线性基、背包卷积、最大子段和）；\n- 查询次数极大、合并代价高的题目；\n- 需要严格 $O(1)$ 查询且不修改的区间问题。\n\n## 常见陷阱与注意事项\n\n- 猫树只适用于静态数据；有修改要用线段树或分块。\n- `op` 必须满足结合律，且不能依赖重复贡献。\n- `n=1` 时 `levels` 要特判为 1，避免 `clz(0)`。\n- `l ^ r` 的层号计算容易差 1，写完后用小数据对拍。\n- 空间是 $O(n\\log n)$，`n` 很大时注意内存；可以按层压缩。\n\n## 对比与扩展\n\nST 表要求幂等，猫树只要求结合律；线段树支持修改但查询带 $\\log$，猫树不支持修改但查询严格 $O(1)$。三者可以按「是否修改、是否幂等、合并代价」三问来选型。",
  "category": "数据结构",
  "tags": [
    "猫树",
    "结合律半群",
    "RMQ",
    "LCA",
    "数据结构"
  ],
  "kind": "knowledge",
  "difficulty": null,
  "relations": [
    {
      "type": "parent-child",
      "target": "col-hub-ds"
    },
    {
      "type": "related",
      "target": "col-ds-st-table-1"
    },
    {
      "type": "related",
      "target": "col-ds-rmq-overview"
    }
  ],
  "parent_key": "col-hub-ds"
}$akb$::jsonb;
    v_updated_at timestamptz;
begin
    select c.updated_at into v_updated_at
    from public.columns c
    where c.column_key = v_payload->>'column_key';

    if found then
        v_payload := jsonb_set(v_payload, '{mode}', to_jsonb('update'::text), true);
        v_payload := jsonb_set(v_payload, '{expected_updated_at}', to_jsonb(v_updated_at), true);
    end if;

    perform public.admin_publish_column(v_payload);
    raise notice 'ok: %', v_payload->>'column_key';
end;
$do$;


-- ---------- 执行后验证 ----------
select column_key, column_name, category, kind, tags, parent_key, status,
       length(content) as content_len, source_ticket_id, updated_at
from public.columns
where column_key like 'sub-admin-ghost-%'
order by column_key;

select column_key, column_name, author_name, category, kind, tags, relations, updated_at
from public.published_columns
where column_key like 'sub-admin-ghost-%'
order by column_key;

-- 关系目标是否都存在（应返回 0 行）
select c.column_key, r->>'target' as missing_target
from public.columns c
cross join lateral jsonb_array_elements(coalesce(c.relations, '[]'::jsonb)) r
where c.column_key like 'sub-admin-ghost-%'
  and r->>'target' <> ''
  and not exists (
      select 1 from public.columns t where t.column_key = r->>'target'
  );
