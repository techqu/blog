---
title:       "《数据结构与算法之美》-高级篇"
date: 2018-11-18T15:03:48+08:00
lastmod: 2018-11-18T15:03:48+08:00
draft: false
keywords: []
description: ""
author:      "瞿广"
tags:        ["数据结构","算法"]
categories:  ["Tech","极客时间笔记","数据结构与算法"]
# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: false
toc: true
autoCollapseToc: true
postMetaInFooter: true
hiddenFromHomePage: false
# You can also define another contentCopyright. e.g. contentCopyright: "This is another copyright."
contentCopyright: false
reward: false
mathjax: false
mathjaxEnableSingleDollar: false
mathjaxEnableAutoNumber: false

# You unlisted posts you might want not want the header or footer to show
hideHeaderAndFooter: false

# You can enable or disable out-of-date content warning for individual post.
# Comment this out to use the global config.
#enableOutdatedInfoWarning: false

flowchartDiagrams:
  enable: true
  options: ""

sequenceDiagrams: 
  enable: true
  options: ""

---

本文是极客时间中数据结构与算法课程的笔记，包含一些高级算法和实际场景



<!--more-->


## 贪心算法：如何使用贪心算法实现Huffman压缩编码？

贪心算法有很多经典应用。比如霍夫曼编码（Huffman Coding）、Prim和Kruskal最小生成树算法、还有Dijkstra单源最短路径算法。

## 分治算法：谈一谈大规模计算框架MapReduce中的分治思想

分治算法（divide and conquer）的核心思想其实就是四个字，分而治之，也就是将原问题划分成n个规模较小，并且结构与原问题相似的子问题，递归地解决这些子问题，然后再合并其结果，就得到原问题的解。

## 回溯算法
深度优先搜索算法利用的是回溯算法思想。它除了用来知道深度优先搜索这种经典的算法设计之外，还可以用在很多实际的软件开发场景中，比如正则表达式匹配、编译原理重的语法分析等。

除此之外，很多经典的数学问题都可以用回溯算法解决，比如数独、八皇后、0-1背包、图的着色、旅行商问题、全排列等等。

## 动态规划
动态规划比较适合用来求解最优问题，比如求最大值、最小值等等。他可以非常显著地降低时间复杂度，提高代码的执行效率。

- 0-1背包问题
- 0-1背包问题升级版

## 拓扑排序
## 最短路径：地图软件是如何计算最优出行路径的？
## 位图：如何实现网页爬虫中的URL去重功能？
BitMap。因为，布隆过滤器本身就是基于位图的，是对位图的一种改进。

问题：我们有一千万个整数，整数的范围在1到1亿之间。如何快速查找某个整数是否在1千万个整数中呢？
## 概率统计：如何利用朴素贝叶斯算法过滤垃圾短信？

1. 基于黑名单的过滤器
2. 基于规则的过滤器
3. 基于概率统计的过滤器

## 向量空间：如何实现一个简单的音乐推荐系统？

- 找到跟你口味偏好相似的用户，把他们爱听的歌曲推荐给你；
- 找出跟你喜爱的歌曲特征相似的歌曲，把这些歌曲推荐给你。

## B+树：MySQL数据库索引是如何实现的？
## 并行算法：如何利用并行处理提高算法的执行效率?