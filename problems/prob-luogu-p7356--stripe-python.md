---
id: prob-luogu-p7356
title: '「PMOI-1」游戏'
oj: '洛谷'
problemId: 'P7356'
difficulty: '暂未评定'
cfRating: 'NaN'
category: 基础算法
tags: ['题解']
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
knowledgePoints: []
---

> 本题解由 stripe-python 授权合并，保留原文讲解与代码；原题面/样例/数据范围未收录，统一标注为「暂无」，可点上方原题链接查看。

## 题目描述

暂无（原题：[P7356](https://www.luogu.com.cn/problem/P7356)）。

### 输入格式

暂无

### 输出格式

暂无

### 数据范围

暂无

## 样例

暂无

## 解题思路

> 这是一道交互题。
>
> 你需要与交互库博弈，交互库持有黑棋，你持有白棋，棋子只能下到坐标点上。
>
> 初始时，交互库第一步一定下在 $(0,0)$，之后双方轮流落子或 pass，直到局面上出现横竖斜任意方向连续的 `黑白白白`，则你胜利。设落子在 $(x,y)$，要求 $0 \le x, y \le 100$。
>
> 多测，$T \le 10^3$，满分胜利步数 $4$。

::::::success[题解]
关键在于注意到下面这种结构是一步杀：

![](https://cdn.luogu.com.cn/upload/image_hosting/gxn7vw1w.png)

此时黑棋如果堵左边，白棋下在右边即可，反之下在左边。

基于此，考虑第一步下在这个位置：

![](https://cdn.luogu.com.cn/upload/image_hosting/itgodemb.png)

如果黑棋不堵的话，白棋下在 $(3,3)$ 即一步杀。否则黑的落点必为 $(1,1),(2,2),(4,4)$ 之一。我们不用关心黑的落点，直接将局面下成这样：

![](https://cdn.luogu.com.cn/upload/image_hosting/vhtzadh0.png)

此时白棋威胁 $(0,2)$ 处的一步杀。我们分类讨论黑棋的堵法：

- 堵 $(0,1)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/c5b80tvu.png)

- 堵 $(0,2)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/1z0a6llj.png)

- 堵 $(0,4)$ 则有如下杀法：

![](https://cdn.luogu.com.cn/upload/image_hosting/3bhs3cdg.png)

分类讨论并模拟即可。
::::::

::::::info[代码]

```cpp line-numbers
int x, y;
void O(int x, int y) {cout << x << ' ' << y << endl;}
void I() {cin >> x >> y;}
void _main() {
    O(2, 2), I();
    if (x == y && (x == 1 || x == 3 || x == 4)) {
        O(3, 0), I();
        if (x == 1 && y == 0) {
            O(4, 0), I();
            if (x == 2 && y == 0) O(5, 0);
            else O(2, 0);
        } else if (x == 2 && y == 0) {
            O(2, 3), I();
            if (x == 2 && y == 1) O(2, 4);
            else O(2, 1);
        } else if (x == 4 && y == 0) {
            O(1, 3), I();
            if (x == 3 && y == 1) O(0, 4);
            else O(3, 1);
        } else {
            O(2, 0), I();
            if (x == 1 && y == 0) O(4, 0);
            else O(1, 0);
        }
    } else {
        O(3, 3), I();
        if (x == 1 && y == 1) O(4, 4);
        else O(1, 1);
    }
} 
```

::::::

## 逐行代码解析

原文以完整代码给出实现，未逐行拆解；实现见上节代码块。

## 复杂度分析

见原文正文中的说明。

## 常见陷阱与注意事项

见原文正文中的说明。

## 对比与扩展

见原文正文中的说明。
