---
id: math-oi-foundations
title: 'OI 中的数学基础'
category: '数学'
subcategory: '数学基础'
tags: ['数学基础', '数论', '组合数学', '索引']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: C
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---

> 原文由 stripe-python 授权合并。原文章 markdown 超过 400K，单页加载与渲染都很慢，因此按主题拆分为下列条目，正文（含全部例题）已随各条目迁出，本页只保留索引与原文参考资料。

## 拆分索引

**数论与数论计数**

- `math-congruence-basics` 同余与模运算（快速幂 / 乘法逆元 / Modint）
- `math-prime-theory` 质数理论基础（判定 / 筛法 / 算术基本定理）
- `math-gcd-theory` 最大公约数与扩展欧几里得
- `math-euler-phi` 欧拉函数
- `math-number-theory-theorems` 数论常用定理：费马小定理与扩展欧拉定理
- `math-block-division` 整除分块（数论分块）
- `math-01-fractional` 0/1 分数规划

**组合数学**

- `math-counting-principles` 计数原理：加法与乘法原理 / 抽屉原理
- `math-inclusion-exclusion` 容斥原理（含 min-max 容斥与斯特林反演）
- `math-combinatorics` 组合数学（排列 / 组合 / 进阶模型）
- `math-derangement` 错位排列（错排）
- `math-catalan` Catalan 数
- `math-stirling` 斯特林数与贝尔数
- `math-partition` 分拆数（整数拆分）
- `math-counting-misc` 计数杂项：排列计数与图论计数
- `math-probability` 概率论与期望

**数学杂项与线性代数**

- `math-sequences` 数列：等差、等比与递推求和
- `math-bit-operation` 位运算
- `math-bit-operation-advanced` 位运算进阶：01-Trie 与 bitset
- `math-gauss-elimination` 高斯消元
- `math-linear-algebra` 线性代数（向量 / 线性变换 / 广义矩阵乘法）
- `math-lagrange-interpolation` 插值法（Lagrange / Newton）

**跨学科**

- `graph-congruence-shortest-path` 同余最短路

## 原文说明

## 0. 前言

为什么要写这篇文章呢？因为教练让我们选一个专题写博客然后交流。

为什么选数学呢？因为线段树分块都被选走了，而数学专题没人选，并且可以把写过的笔记拼起来（

本文章涉及数论 & 组合数学两个部分，还包含一些数学杂项，整体内容比较简单。

## 注意事项及约定

- 若无特殊说明，本文中使用符号 $\oplus$ 表示按位异或，$\&$ 表示按位与，$|$ 表示按位或，$\sim$ 表示按位取反。
- 本文代码中出现的 `modint` 或 `mint` 是笔者编写的自动取模工具，代码可见 [this](https://www.luogu.me/paste/6wwixwot)。
- 本文代码中出现的 `BigInteger` 是笔者编写的高精度整数，代码可见 [this](https://www.luogu.com.cn/article/rz9ubds1)。
- **本文有大量例题。对于较难的例题，用 `*` 标出，没有看懂可以先跳过。**
- [《OI 中的数学基础》例题题单](https://www.luogu.com.cn/training/875199)。题目按在文章中的出现顺序排序，分成了五个部分。
- **本文存在一些较难的章节，用 `*` 标出。初学者可以先跳过。**

## 更新

- 2025-08-06 第一版：通过洛谷审核。
- 2025-10-05 第二版：调整文章结构，优化目录，重构分拆数部分，新增大量例题并修复一些 Bug。

## 参考资料

## 参考资料

**第 1 章**

- 1.2.1 [模意义下的整数乘法](https://oi-wiki.org/math/binary-exponentiation/#%E6%A8%A1%E6%84%8F%E4%B9%89%E4%B8%8B%E7%9A%84%E6%95%B4%E6%95%B0%E4%B9%98%E6%B3%95)——OI Wiki。
- 1.2.2 [快速幂，光速幂及O(1)逆元](https://zhuanlan.zhihu.com/p/646773254)——秋钧。
- 1.2.2 [同一底数与同一模数的预处理快速幂](https://oi-wiki.org/math/binary-exponentiation/#%E5%90%8C%E4%B8%80%E5%BA%95%E6%95%B0%E4%B8%8E%E5%90%8C%E4%B8%80%E6%A8%A1%E6%95%B0%E7%9A%84%E9%A2%84%E5%A4%84%E7%90%86%E5%BF%AB%E9%80%9F%E5%B9%82)——OI Wiki。
- 1.3.3 [题解 P3811 【模板】乘法逆元](https://www.luogu.com.cn/article/olb3kk4e)——Rising_Date。

**第 2 章**

- 2.2.2 [Miller–Rabin 素性测试](https://oi-wiki.org/math/number-theory/prime/#millerrabin-%E7%B4%A0%E6%80%A7%E6%B5%8B%E8%AF%95)——OI Wiki。
- 2.4.3 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 3 章**

- 3.1.3 [Stein 算法的优化](https://oi-wiki.org/math/number-theory/gcd/#stein-%E7%AE%97%E6%B3%95%E7%9A%84%E4%BC%98%E5%8C%96)——OI Wiki。
- 3.1.3 [P5435](https://www.luogu.com.cn/article/t7bd37d3)——Maysoul。
- 3.4 《信息学奥林匹克竞赛实战笔记》。

**第 4 章**

- 4.2 《信息学奥林匹克竞赛实战笔记》。

**第 5 章**

- 5.1 [费马小定理](https://oi-wiki.org/math/number-theory/fermat/#%E8%B4%B9%E9%A9%AC%E5%B0%8F%E5%AE%9A%E7%90%86)——OI Wiki。

**第 6 章**

- 6.1 [数论分块](https://oi-wiki.org/math/number-theory/sqrt-decomposition/)——OI Wiki。
- 6.1 [数论分块](https://zhuanlan.zhihu.com/p/643870541)——Standard。

**第 7 章**

- 7.2.2 [等差数列](https://baike.baidu.com/item/%E7%AD%89%E5%B7%AE%E6%95%B0%E5%88%97/1129192)——百度百科。
- 7.2.3 [等比数列求和公式](https://baike.baidu.com/item/%E7%AD%89%E6%AF%94%E6%95%B0%E5%88%97%E6%B1%82%E5%92%8C%E5%85%AC%E5%BC%8F/7527367)——百度百科。
- 7.2.3 [分治(等比数列求和) - 约数之和 - AcWing 97](https://blog.csdn.net/njuptACMcxk/article/details/108019553)——njuptACMcxk。
- 7.2.4 [信奥常见数列详解](https://www.luogu.com.cn/article/oudldvmw)——Nostopathy。
- 7.3 [抽屉原理](https://oi-wiki.org/math/combinatorics/drawer-principle/)——OI Wiki。

**第 8 章**

- 8.1 [容斥原理](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/)——OI Wiki。
- 8.3 [容斥原理一般化](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E5%AE%B9%E6%96%A5%E5%8E%9F%E7%90%86%E4%B8%80%E8%88%AC%E5%8C%96)——OI Wiki。

**第 9 章**

- 9.1.3 [圆排列](https://oi-wiki.org/math/combinatorics/combination/#%E5%9C%86%E6%8E%92%E5%88%97)——OI Wiki。
- 9.2.2 [二项式定理](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%AE%9A%E7%90%86)——OI Wiki。
- 9.2.3 [组合数性质 | 二项式推论](https://oi-wiki.org/math/combinatorics/combination/#%E7%BB%84%E5%90%88%E6%95%B0%E6%80%A7%E8%B4%A8--%E4%BA%8C%E9%A1%B9%E5%BC%8F%E6%8E%A8%E8%AE%BA)——OI Wiki。
- 9.3.2 [插板法](https://oi-wiki.org/math/combinatorics/combination/#%E6%8F%92%E6%9D%BF%E6%B3%95)——OI Wiki。
- 9.3.2 [不定方程非负整数解计数](https://oi-wiki.org/math/combinatorics/inclusion-exclusion-principle/#%E4%B8%8D%E5%AE%9A%E6%96%B9%E7%A8%8B%E9%9D%9E%E8%B4%9F%E6%95%B4%E6%95%B0%E8%A7%A3%E8%AE%A1%E6%95%B0)——OI Wiki。

**第 10 章**

- 10.1.1 [排名](https://oi-wiki.org/math/permutation/#%E6%8E%92%E5%90%8D)——OI Wiki。
- 10.1.2 [题解：CF1553E Permutation Shift](https://www.luogu.com.cn/article/lexsfrlf)——hh弟中弟。
- 10.2 [exLucas 算法](https://oi-wiki.org/math/number-theory/lucas/#exlucas-%E7%AE%97%E6%B3%95)——OI Wiki。
- 10.3 《算法竞赛进阶指南》——李煜东。

**第 11 章**

- 11.2 [二项式反演](https://oi-wiki.org/math/combinatorics/combination/#%E4%BA%8C%E9%A1%B9%E5%BC%8F%E5%8F%8D%E6%BC%94)——OI Wiki。
- 11.3 [容斥原理 & 二项式反演](https://www.cnblogs.com/2huk/p/18169274)——2huk。
- 11.3 [二项式反演学习笔记](https://www.cnblogs.com/XuYueming/p/18397758)——XuYueming。

**第 12 章**

- 12.2 [错位排列](https://www.luogu.com.cn/article/8k18otus)——xzyg。

**第 13 章**

- 13.1 DeepSeek。
- 13.1 [简单格路计数相关](https://www.cnblogs.com/Sktn0089/p/19183743)——Sktn0089。
- 13.2 [常见形式](https://oi-wiki.org/math/combinatorics/catalan/#%E5%B8%B8%E8%A7%81%E5%BD%A2%E5%BC%8F)——OI Wiki。

**第 14 章**

- 14.1 & 14.2 [斯特林数](https://oi-wiki.org/math/combinatorics/stirling/)——OI Wiki。
- 14.3 [二项式反演与斯特林反演](https://www.cnblogs.com/UKE-Automation/p/19688555)——UKE_Automation。
- 14.4.3 [斯特林数入门](https://zhuanlan.zhihu.com/p/160779987)——Hongzy。

**第 15 章**

- 15.1 & 15.2 [贝尔数](https://oi-wiki.org/math/combinatorics/bell/)——OI Wiki。
- 15.3 [贝尔数](https://www.cnblogs.com/HeNuclearReactor/p/18552275.html)——NuclearReactor。

**第 16 章**

- 16.1 & 16.2 [分拆数](https://www.luogu.me/article/ed1zhztr)——LYH_cpp。
- 16.3 [组合数学（2）分拆数](https://zhuanlan.zhihu.com/p/530925152)——卷心汪汪队。

**第 18 章**

- 18.1 & 18.2 & 18.3 & 18.4 《深入浅出程序设计竞赛（进阶篇）》——洛谷。

**第 19 章**

- 19.2 [遍历所有掩码的子掩码](https://oi-wiki.org/math/binary-set/#%E9%81%8D%E5%8E%86%E6%89%80%E6%9C%89%E6%8E%A9%E7%A0%81%E7%9A%84%E5%AD%90%E6%8E%A9%E7%A0%81)——OI Wiki。
- 19.2 [高维前缀和 (SOSDP) ](https://www.cnblogs.com/jiangchen4133/p/18741715.html)——Aurora-JC。

**第 20 章**

- 20.1 [字典树 (Trie) ](https://oi-wiki.org/string/trie/#%E7%BB%B4%E6%8A%A4%E5%BC%82%E6%88%96%E5%92%8C)——OI Wiki。

**第 21 章**

- 21.2 [分数规划](https://oi-wiki.org/misc/frac-programming/)——OI Wiki。

**第 22 章**

- 22.1 DeepSeek。
- 22.3 [高斯消元法解异或方程组](https://oi-wiki.org/math/numerical/gauss/#%E9%AB%98%E6%96%AF%E6%B6%88%E5%85%83%E6%B3%95%E8%A7%A3%E5%BC%82%E6%88%96%E6%96%B9%E7%A8%8B%E7%BB%84)——OI Wiki。

**第 23 章**

- 23.1 & 23.2《深入浅出程序设计竞赛（进阶篇）》——洛谷。
- 23.3 [关于广义矩阵乘法常见误区的一点纠正](https://www.cnblogs.com/qkhm/p/20055514/ddp)——qkhm。

**第 24 章**

- 24.1 DeepSeek。
- 24.2 & 24.3 [插值](https://oi-wiki.org/math/numerical/interp/)——OI Wiki。
- 24.3 [离散泰勒公式，牛顿插值法，以及那些奇怪的数列](https://www.bilibili.com/video/BV1GvoaYbExs/)——科技3D视界。

**第 25 章**

- 25.2 [浅谈同余最短路](https://www.luogu.com.cn/article/boecnq71)——Exp10re。
