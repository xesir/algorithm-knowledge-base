---
id: math-combinatorics
title: '组合数学（排列 / 组合 / 进阶模型）'
category: '数学'
subcategory: '组合数学'
tags: ['排列组合', '组合数', '多重集', 'exLucas']
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-29
source: 'stripe-python'
---


> 本文由 stripe-python 授权合并；原文篇幅较大，现按主题拆分为以下小栏目。其他作者版本（world-needs-sunday / Fohen / Xesir）保持原样。

## 分栏目录

| 小栏目 | 内容 |
|---|---|
| [排列与组合基础](#sub-admin-math-combinatorics-basic) | 排列、组合、二项式定理、组合数性质与计算方法（定义 / 递推 / 逆元 / Lucas / exLucas） |
| [经典模型](#sub-admin-math-combinatorics-models) | 捆绑法、插板法、不定方程、球盒模型等经典计数模型 |
| [基础例题](#sub-admin-math-combinatorics-examples-basic) | 第 9 章配套例题（P1313、ABC167E、P1771、P3223 等） |
| [排列进阶与 exLucas](#sub-admin-math-combinatorics-advanced) | 康托展开、对换、exLucas、多重集的组合数 |
| [进阶例题](#sub-admin-math-combinatorics-examples-advanced) | 第 10 章配套例题（P5367、P3014、CF1553E、P4778 等） |
| [专题笔记](#sub-admin-math-combinatorics-notes) | 排列组合专题笔记（圆排列、Lehmer 码、置换、组合恒等式、球盒模型等） |
| [计数基础](#sub-admin-math-combinatorics-counting-basics) | 《OI 中的计数基础》中的排列组合部分（排列、组合、二项式定理、组合恒等式、经典模型） |

## 阅读建议

- 先看「排列与组合基础」与「经典模型」，再按需进入例题；
- 进阶内容（康托展开、exLucas、多重集组合数）在「排列进阶与 exLucas」；
- 两篇附录保留原文结构，适合系统复习或查阅。

> 本页只保留分栏索引；完整推导、代码与例题在对应小栏目中。
