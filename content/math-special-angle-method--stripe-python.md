---
id: math-special-angle-method
title: '特殊角法进阶'
category: '数学'
subcategory: '数学基础'
tags: ["特殊角","几何","三角","数学基础"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
众所周知，特殊角法是初中几何的降维打击。其在初中的主要体现为 12345 模型。本文对特殊角进一步探究，使之可以适应所有题型。

## 初步探究

这是本文发布前，笔者关于特殊系的一些探究。

| 角度 | 对边 | 临边 | 斜边 |
| --- | --- | --- | --- |
| $\alpha$ | $a$ | $b$ | $c$ |
| $\dfrac{\alpha}{2}$ | $\sqrt{c-b}$ | $\sqrt{c+b}$ | $\sqrt{2c}$ |
| $\dfrac{90\degree-\alpha}{2}$ | $\sqrt{c-a}$ | $\sqrt{c+a}$ | $\sqrt{2c}$ |
| $2\alpha$ | $2ab$ | $2b^2-c^2$ | $c^2$ |
| $45\degree-\alpha$ | $b-a$ | $b+a$ | $\sqrt{2}c$ |

由 $\alpha$ 推导出来的其余角度构成一个特殊角系，例如初中常用的 $37 \degree$ 系与 $23 \degree$ 系如下：

| 角度 | 对边 | 邻边 | 斜边 |
| --- | --- | --- | --- |
| $37 \degree$ | $3$ | $4$ | $5$ |
| $18.5 \degree$ | $1$ | $3$ | $\sqrt{10}$ |
| $26.5 \degree$ | $1$ | $2$ | $\sqrt{5}$ |
| $74 \degree$ | $24$ | $7$ | $25$ |
| $8 \degree$ | $1$ | $7$ | $5\sqrt{2}$ |

| 角度 | 对边 | 邻边 | 斜边 |
| --- | --- | --- | --- |
| $23 \degree$ | $5$ | $12$ | $13$ |
| $11.5 \degree$ | $1$ | $5$ | $\sqrt{26}$ |
| $33.5 \degree$ | $2$ | $3$ | $\sqrt{13}$ |
| $46 \degree$ | $120$ | $119$ | $169$ |
| $22 \degree$ | $7$ | $17$ | $13\sqrt{2}$ |

然而，这种方法有一个致命的缺陷：**不同特殊角系不可混用。** 在市一模中，笔者班级同学就是将 $60 \degree - 37 \degree$ 当作 $23\degree$ 导致错误。

## 进阶探究

本文意在解决这个问题。

我们先改掉角度表示法，用角度近似是为了方便，然而在混用特殊角系时会造成歧义。我们用三元组 $(a,b,c)$ 表示三角比为 $a:b:c$ 的角。

则上文可写作

$$
\dfrac{(3,4,5)}{2}=(1,3,\sqrt{10})\\
\dfrac{(4,3,5)}{2}=(1,2,\sqrt{5})\\
2(3,4,5)=(24,7,25)\\
\dfrac{\pi}{4}-(3,4,5)=(1,7,5\sqrt{2})
$$

接下来是重点。我们用这种表示法来实现不同特殊角混用。

$$
(a_1,b_1,c_1)+(a_2,b_2,c_2)=(a_1b_2+a_2b_1,b_1b_2-a_1a_2,c_1c_2)\\
(a_1,b_1,c_1)-(a_2,b_2,c_2)=(a_1b_2-a_2b_1,b_1b_2+a_1a_2,c_1c_2)\\
$$

最后附上几个做题常见的东西：

（2020中考）

$(4,3,5)-(2,3,\sqrt{13})=(6, 17, 5 \sqrt{13})$（2025靶向二）

$(24,7,25)-(3,2,\sqrt{13})=(27, 86, 25 \sqrt{13})$其他可能用的：

$$
(3,4,5)-(2,3,\sqrt{13})=(1, 18, 5 \sqrt{13})\\
(2,3,\sqrt{13})-(1,3,\sqrt{10})=(3, 11, \sqrt{130})\\
(2,3,\sqrt{13})-(1,2,\sqrt{5})=(1, 8, \sqrt{65})
$$

## 代码实现

python 写了一个简单的包，基于 sympy。如果你要探究其他角度，直接跑代码就可以。

```python
import sympy as sp

class Angle(object):
    def __init__(self, a, b, c):
        self.a, self.b, self.c = a, b, c
        # assert a * a + b * b == c * c

    def __repr__(self):
        return f'Angle(a={self.a}, b={self.b}, c={self.c})'

    def latex(self) -> str:
        return f'({sp.latex(self.a)}, {sp.latex(self.b)}, {sp.latex(self.c)})'

    def coangle(self) -> 'Angle':
        # pi/2-alpha
        a, b, c = self.a, self.b, self.c
        return Angle(b, a, c)

    def double(self) -> 'Angle':
        # 2alpha
        a, b, c = self.a, self.b, self.c
        return Angle(2 * a * b, 2 * b * b - c * c, c * c)

    def half(self) -> 'Angle':
        # alpha/2
        a, b, c = self.a, self.b, self.c
        return Angle(sp.sqrt(c - b), sp.sqrt(c + b), sp.sqrt(2 * c))

    def cohalf(self) -> 'Angle':
        # (pi/2-alpha)/2
        a, b, c = self.a, self.b, self.c
        return Angle(sp.sqrt(c - a), sp.sqrt(c + a), sp.sqrt(2 * c))

    def __add__(self, beta: 'Angle') -> 'Angle':
        # alpha + beta
        a1, b1, c1 = self.a, self.b, self.c
        a2, b2, c2 = beta.a, beta.b, beta.c
        return Angle(a1 * b2 + a2 * b1, b1 * b2 - a1 * a2, c1 * c2)

    def __sub__(self, beta: 'Angle') -> 'Angle':
        # alpha + beta
        a1, b1, c1 = self.a, self.b, self.c
        a2, b2, c2 = beta.a, beta.b, beta.c
        return Angle(a1 * b2 - a2 * b1, b1 * b2 + a1 * a2, c1 * c2)

degree30 = Angle(1, sp.sqrt(3), 2)
degree45 = Angle(1, 1, sp.sqrt(2))
```
