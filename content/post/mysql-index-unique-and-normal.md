---
title: "《MYSQL实战45讲》- 唯一索引和普通索引"
date: 2019-03-16T15:26:14+08:00
lastmod: 2019-03-16T15:26:14+08:00
draft: false
keywords: []
description: ""
tags: ["MySQL","MYSQL实战45讲"]
categories: ["Tech"]
author: "瞿广"

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: false
toc: true
autoCollapseToc: false
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
  enable: false
  options: ""

sequenceDiagrams: 
  enable: false
  options: ""

---
在不同的业务场景下，应该选择普通索引，还是唯一索引呢？接下来，我们就从这两种索引对查询语句和更新语句的性能影响来进行分析。
<!--more-->

## 查询过程

假设，执行查询的语句是 `select id from T where k=5`.这个查询语句在索引树上查找的过程，先是通过B+树从树根开始，按层搜索到叶子节点。然后可以认为数据页内部通过二分法来定位记录。

- 对于普通索引来说，查找到满足条件的第一个记录（5，500），需要查找下一个记录，直到碰到第一个不满足k=5条件的记录。
- 对于唯一索引来说，由于索引定义了唯一性，查找到第一个满足条件的记录后，就会停止继续检索。

因为引擎是按页读写的，所以说，当找到k=5的记录的时候，它所在的数据页就都在内存里了。对于普通索引要多做的那一次“查找和判断下一条记录”的操作，就只需要一次指针查找和一次计算。

> InnoDB的数据是按数据页为单位来读写的。也就是说，当需要读一条记录的时候，并不是将这个记录本身从磁盘读出来，而是以页为单位，将其整体读入内存。在InnoDB中，每个数据页的大小默认是16KB。

我们之前计算过，对于整型字段，一个数据页可以放近千个key，刚好跨数据页取下一个记录的概率会很低。所以，我们计算平均性能差异时，仍可以认为这个操作成本对于现在的CPU来说可以忽略不计。

## 更新过程

## 索引选择和实践

普通索引和唯一索引在查询能力上是没差别的，主要考虑的是对更新性能的影响。所以我建议你尽量选择普通索引。

如果所有的更新后面，都马上伴随着对这个记录的查询，那么你应该关闭 change buffer。而在其他情况下，change buffer 都能提升更新性能。

## change buffer 和 redo log