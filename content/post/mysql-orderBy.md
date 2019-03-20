---
title: "Mysql OrderBy"
date: 2019-03-20T08:49:19+08:00
lastmod: 2019-03-20T08:49:19+08:00
draft: false
keywords: []
description: ""
tags: []
categories: ["极客时间笔记","MySQL"]
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

需要根据指定的字段来显式结果的需求。
<!--more-->


假设这个表的部分定义是这样的：

```
CREATE TABLE `t` (
  `id` int(11) NOT NULL,
  `city` varchar(16) NOT NULL,
  `name` varchar(16) NOT NULL,
  `age` int(11) NOT NULL,
  `addr` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `city` (`city`)
) ENGINE=InnoDB;
```
SQL可以这么写：

```
select city,name,age from t where city='杭州' order by name limit 1000  ;
```

## 全字段排序

MYSQL会给每一个线程分配一块内存用于排序，称为 sort_buffer。

执行流程如下：

1. 初始化 sort_buffer，确定放入 name、city、age 这三个字段；
2. 从索引city找到第一个满足 city="杭州"条件的主键id，也就是图中的 ID_X；
3. 到主键id索引取出整行，取name、city、age三个字段的值，存入 sort_buffer中；
4. 从索引city取下一个记录的主键id；
5. 重复步骤3、4 直到city的值不满足查询条件为止，对应的主键id也就是途中的ID_Y;
6. 对sort_buffer中的数据按照字段name做快速排序；
7. 按照排序结果取前1000行返回给客户端。


## rowid 排序

单行数据量过大的情况

新的算法放入sort_buffer的字段，只有要排序的列（即name字段）的主键id，最后通过主键id回到原表中取出city、name和age三个字段返回给客户端。


## 全字段排序 VS rowid 排序

如果MySQL实在是担心排序内存太小，会影响排序效率，才会采用 rowid 排序算法，这样排序过程中一次可以排序更多行，但是需要再回到原表去取数据。

如果MySQL认为内存足够大，会优先选择全字段排序，把需要的字段都放到 sort_buffer 中，这样排序后就会直接从内存里面返回查询结果了，不用再回到原表去取数据。

这也就体现了MySQL的一个设计思想：**如果内存够，就要多利用内存，尽量减少磁盘访问**


如果保证从 city 这个索引上取出来的行，天然就是按照name递增排序的话，是不是就可以不用再排序了呢?

确实是这样的