---
id: math-nested-radical
title: '嵌套根式化简'
category: '数学'
subcategory: '数学基础'
tags: ["嵌套根式","根号","代数","数学基础"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## Example 0

求 $\sqrt{a \pm \sqrt{b}}$ 的值和判别式。

注意到，要把这个根号开出来，可以把根号里面化为完全平方式。于是作**换元，令**

$a=m^2+n^2, \sqrt{b}=2mn$则

$\text{原式} = \sqrt{m^2+n^2 \pm 2mn}=\sqrt{(m \pm n)^2}=m \pm n$由 $\sqrt{b}=2mn$ 得 $4m^2n^2=b$

再次换元，令 $x=m^2,y=n^2$，则有如下方程组：

$$
\left\{\begin{matrix} x+y=a
 \\4xy=b

\end{matrix}\right.
$$

消元，整理得

$-x^2+ax-\dfrac{1}{4}b=0$由一元二次方程的判别式得

$\Delta=a^2-4 \times (-1) \times (-\dfrac{1}{4}b)=a^2-b$由一元二次方程的求根公式得

$$
x_1=\dfrac{-a+\sqrt{\Delta}}{-2}=\dfrac{a-\sqrt{\Delta}}{2},
x_2=\dfrac{-a-\sqrt{\Delta}}{-2}=\dfrac{a+\sqrt{\Delta}}{2}
$$

所以原方程组有两组解为

$$
\left\{\begin{matrix} x_1=\dfrac{a-\sqrt{\Delta}}{2}, x_2=\dfrac{a+\sqrt{\Delta}}{2}
 \\y_1=\dfrac{a+\sqrt{\Delta}}{2}, y_2=\dfrac{a-\sqrt{\Delta}}{2}

\end{matrix}\right.
$$

注意到，$x$ 取 $x_1$ 或 $x_2$ 不影响最终结果，不妨令

$$
x=\dfrac{a+\sqrt{\Delta}}{2},
y=\dfrac{a-\sqrt{\Delta}}{2}
$$

则

$m=\sqrt{x}=\sqrt{\dfrac{a+\sqrt{\Delta}}{2}}, n=\sqrt{y}=\sqrt{\dfrac{a-\sqrt{\Delta}}{2}}$回代可得

$\text{原式} = \sqrt{\dfrac{a+\sqrt{\Delta}}{2}} \pm \sqrt{\dfrac{a-\sqrt{\Delta}}{2}}, \Delta=a^2-b$### 结论

$\sqrt{a \pm \sqrt{b}}=\sqrt{\dfrac{a+\sqrt{\Delta}}{2}} \pm \sqrt{\dfrac{a-\sqrt{\Delta}}{2}}, \Delta=a^2-b$当且仅当 $\Delta \ge 0$ 且为完全平方数时可开根。

特别地，如果 $b$ 为完全平方数，判别式无效。

## Example 1

这是卷子上的题。求 $\sqrt{5+2\sqrt{6}}$ 和 $\sqrt{7-2\sqrt{10}}$ 的值。

解：

因为 $\sqrt{5+2\sqrt{6}}=\sqrt{5+\sqrt{24}}$

所以 $\Delta=5^2-24=1$

所以 $\sqrt{5+2\sqrt{6}}=\sqrt{\dfrac{5+1}{2}}+\sqrt{\dfrac{5-1}{2}}=\sqrt{3}+\sqrt{2}$

因为 $\sqrt{7-2\sqrt{10}}=\sqrt{7+\sqrt{40}}$

所以 $\Delta=7^2-40=9$

所以 $\sqrt{7-2\sqrt{10}}=\sqrt{\dfrac{7+3}{2}}-\sqrt{\dfrac{7-3}{2}}=\sqrt{5}-\sqrt{2}$

看上去秒杀。但是我们在考试中偶尔也会遇到这类特别奇葩的题目：

## Example 2

这是那张卷子上的压轴题。求 $\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}$ 的值。

第一反应是开 $\sqrt{10+2\sqrt{5}}$，然而开不开。

只能考虑换元。

### 方法 1：代数换元

令

$p=\sqrt{4-\sqrt{10+2\sqrt{5}}}, q=\sqrt{4+\sqrt{10+2\sqrt{5}}}$注意到 $p^2+q^2$ 可以消掉 $\sqrt{10+2\sqrt{5}}$，$pq$ 则可以在根号下应用平方差公式。

则

$p^2+q^2=4-\sqrt{10+2\sqrt{5}}+4+\sqrt{10+2\sqrt{5}}=8$同时

$pq=\sqrt{(4-\sqrt{10+2\sqrt{5}})(4+\sqrt{10+2\sqrt{5}})}$ $=\sqrt{4^2-(\sqrt{10+2\sqrt{5}})^2}$ $=\sqrt{16-10-2\sqrt{5}}$ $=\sqrt{6-2\sqrt{5}}$对 $\sqrt{6-2\sqrt{5}}$ 应用上面的公式，得 $pq=\sqrt{5}-1$。

所以

$(p+q)^2=p^2+q^2+2pq=8+2(\sqrt{5}-1)=6+2\sqrt{5}$又因为 $\text{原式} \ge 0$，所以

$\text{原式}=p+q=\sqrt{6+2\sqrt{5}}$对 $\sqrt{6+2\sqrt{5}}$ 应用上面的公式，得 $\text{原式}=\sqrt{5}+1$。

### 方法 2：逆用公式

作一个不一样的换元。

令

$\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}=\sqrt{a+\sqrt{b}}$则

$\sqrt{4-\sqrt{10+2\sqrt{5}}}+\sqrt{4+\sqrt{10+2\sqrt{5}}}=\sqrt{\dfrac{a+\sqrt{a^2-b}}{2}}+ \sqrt{\dfrac{a-\sqrt{a^2-b}}{2}}$考虑在等式两边构造同构：

$\sqrt{\dfrac{8+2\sqrt{10+2\sqrt{5}}}{2}}+\sqrt{\dfrac{8-2\sqrt{10+2\sqrt{5}}}{2}}=\sqrt{\dfrac{a+\sqrt{a^2-b}}{2}}+ \sqrt{\dfrac{a-\sqrt{a^2-b}}{2}}$得到 $a=8, \sqrt{a^2-b}=2\sqrt{10+2\sqrt{5}}$

解得 $b=24-8\sqrt{5}$

则 $\text{原式}=\sqrt{8+\sqrt{24-8\sqrt{5}}}$

对 $\sqrt{24-8\sqrt{5}}$ 应用公式得 $\sqrt{24-8\sqrt{5}}=2\sqrt{5}-2$。

则 $\text{原式}=\sqrt{6+2\sqrt{5}}$

对 $\sqrt{6+2\sqrt{5}}$ 应用公式，得 $\text{原式}=\sqrt{5}+1$。

## Example 3

来一道逆用公式的模板题。求 $\dfrac{\sqrt{2}}{2}(\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}})$ 的值。

显然我们可以对 $\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}}$ 进行代数换元法。但是逆用公式更为快捷。

$\text{原式} = \dfrac{1}{\sqrt{2}}(\sqrt{4+\sqrt{7}}+\sqrt{4-\sqrt{7}}) = \sqrt{\dfrac{4+\sqrt{7}}{2}}+\sqrt{\dfrac{4-\sqrt{7}}{2}}$不难看出 $\sqrt{\dfrac{4+\sqrt{7}}{2}}+\sqrt{\dfrac{4-\sqrt{7}}{2}}$ 是公式的标准形式。

令 $\text{原式}  = \sqrt{a+\sqrt{b}}$，则 $a=4, \sqrt{a^2-b} = \sqrt{7}$，解得 $b=9$。

所以 $\text{原式} = \sqrt{4+\sqrt{9}} = \sqrt{7}$
