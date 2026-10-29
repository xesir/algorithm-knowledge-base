---
id: basic-kittengen
title: 'KittenGen 本地数据生成器'
category: '实用工具'
subcategory: '调试'
tags: ["数据生成器","KittenGen","对拍","Python"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
你是否有过这样的经历：出完一个题，写好了 std 和 maker，然后上讨论区求助“求生成数据模板”……

你是否有过这样的经历：出了一道图论题，图要卡掉 SPFA。用 C++ 写了 $114514$ 小时……

如果你有以上困扰的话，那么欢迎使用 `KittenGen`。

## KittenGen 是什么

一个基于 Python3 的 Flask 框架搭建的本地化数据生成器。在运行时，它将本机作为服务器提供 web 服务。

之前我发布过[文章](https://www.luogu.com.cn/article/wz3ql1y6)，写的是 KittenGen1.0 版本。这个版本的 KittenGen 在我拿到机房用以后还发现了一些问题，比如 32 位电脑编译命令不对，python 版本过旧，均已在 KittenGen2.0 版本修复。

在评论区有大佬指出 HydroOJ 也有自动造数据功能。但经本人实测，这个造数据跑的时间太长会 TLE，输出太多还会 OLE，总之不好用。但是在本地跑就没有这种问题。

## 如何使用 KittenGen

首先你要有一个 Python3 环境，下载好 pip。可以直接去[官网](http://www.python.org/)下载。

打开 cmd，输入：

```cmd
pip install -U KittenGen
```

上述操作可能会比较慢，推荐使用清华镜像源：

```cmd
pip install -U KittenGen -i https://pypi.tuna.tsinghua.edu.cn/simple
```

如果顺利的话，你就会看到下面这样的提示信息：

![](https://cdn.luogu.com.cn/upload/image_hosting/333a1k0w.png)

下载完成后，输入：

```cpp
python -m KittenGen
但是 KittenGen 也会存在一些小 BUG，欢迎各位大佬指出，感激不尽！
```
