---
id: str-match-overview
title: '字符串匹配总览（KMP / Sunday / AC 自动机 / Manacher）'
category: '字符串'
subcategory: '字符串匹配'
tags: ['字符串匹配', 'KMP', 'AC自动机', 'Manacher', '总览']
timeComplexity: '按子条目而定'
spaceComplexity: '按子条目而定'
level: A
noCode: true
hub: true
verified: '2026-11-01'
---

## 算法原理

本页是「字符串匹配」的二级栏目索引：单模式匹配用 KMP/Sunday，多模式匹配用 AC 自动机，回文子串用 Manacher。

**学习顺序**：KMP → Sunday → Manacher → AC 自动机。

## 核心公式 / 状态定义与转移方程

**按需求选子栏目**：

| 需求 | 子条目 |
|---|---|
| 单模式串匹配、求 next | KMP 字符串匹配算法 |
| 单模式串匹配、平均更快 | Sunday 字符串匹配算法 |
| 多模式串同时匹配 | AC 自动机 |
| 最长回文子串 | Manacher 算法 |

KMP 的核心是 `next` 数组（失配后模式串回跳）；AC 自动机在 Trie 上建 fail 指针。

## 逐行代码解析

本页只做导航，不重复贴代码；各子页给出 next/fail 构造与逐行解析。

## 复杂度分析

- KMP：$O(n+m)$。
- Sunday：平均 $O(n/m)$ 级别，最坏 $O(nm)$。
- Manacher：$O(n)$。
- AC 自动机：建树 $O(\sum|s|)$，匹配 $O(n+\text{命中数})$。

## 适用场景

- 子串查找、周期/前缀函数。
- 多模式串敏感词、统计出现次数。
- 回文相关（最长回文、回文划分预处理）。

## 常见陷阱与注意事项

- next 数组下标从 0 还是从 1 开始要统一。
- KMP 求「所有出现位置」时失配后要继续跳 next。
- Manacher 要插入分隔符处理奇偶回文。
- AC 自动机建 fail 时用 BFS，注意根节点转移。
- 多组数据要清空 Trie 与 fail。

## 对比与扩展

- KMP vs Sunday：后者在随机文本上常数更小。
- AC 自动机 vs 后缀自动机：前者多模式匹配，后者处理单串子串结构。
- 可扩展到 Z 函数、后缀数组、后缀自动机。
