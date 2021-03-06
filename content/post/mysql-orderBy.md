---
title: "《MYSQL实战45讲》- Order By"
date: 2019-03-20T08:49:19+08:00
lastmod: 2019-03-20T08:49:19+08:00
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

在你开发应用时，一定会遇到需要根据指定的字段来显式结果的需求。

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


按照字段name排序，可能在内存中完成，也可能在内存中完成，也可能需要使用外部排序，这取决于排序所需的内存和参数 `sort_buffer_size`

`sort_buffer_size`，就是MySQL为排序开辟的内存（sort_buffer）的大小。如果要排序的数据量小于`sort_buffer_size`，排序就在内存中完成。但如果排序数据量太大，内存放不下，则不得不利用磁盘临时文件辅助排序。

## rowid 排序

单行数据量过大的情况

新的算法放入sort_buffer的字段，只有要排序的列（即name字段）的主键id，最后通过主键id回到原表中取出city、name和age三个字段返回给客户端。

> **双路排序**：Mysql4.1之前是使用双路排序，字面的意思就是两次扫描磁盘，最终得到数据，读取行指针和ORDER BY列，对他们进行排序，然后扫描已经排好序的列表，按照列表中的值重新从列表中读取对数据输出。也就是从磁盘读取排序字段，在buffer进行排序，再从磁盘读取其他字段。文件的磁盘IO非常耗时的，所以在Mysql4.1之后，出现了第二种算法，就是单路排序。

> **单路排序**：从磁盘读取查询所需要的所有列，按照ORDER BY在buffer对它进行排序，然后扫描排序后的列表进行输出，它的效率更快一些，避免了第二次读取数据。并且把随机IO变成了顺序IO，但是它会使用更多的空间，因为它把每一行都保存在了内存里。

> 但是，问题来了，有可能单路排序算法一次拿不出数据，那么就还比双路排序更消耗IO，效率更慢！


## 全字段排序 VS rowid 排序

如果MySQL实在是担心排序内存太小，会影响排序效率，才会采用 rowid 排序算法，这样排序过程中一次可以排序更多行，但是需要再回到原表去取数据。

如果MySQL认为内存足够大，会优先选择全字段排序，把需要的字段都放到 sort_buffer 中，这样排序后就会直接从内存里面返回查询结果了，不用再回到原表去取数据。

这也就体现了MySQL的一个设计思想：**如果内存够，就要多利用内存，尽量减少磁盘访问**


如果保证从 city 这个索引上取出来的行，天然就是按照name递增排序的话，是不是就可以不用再排序了呢?

确实是这样的，所以我们可以在这个市民表上创建一个city 和 name 的联合索引，对应的 SQL 语句：

```sql
alter table t add index city_user(city, name);
```
在这个索引里，我们依然可以用树搜索的方式定位到第一个满足city=“杭州”的记录，并且额外确保了，接下来按顺序取“下一条记录”的遍历过程中，只要city的值是杭州，name 的值就一定是有序的。

这样整个查询过程的流程就变成了：

1. 从索引（city，name）找到第一个满足city=“杭州”条件的主键id；
2. 到主键 id 索引取出整行，取 name、city、age三个字段的值，作为结果集的一部分直接返回；
3. 从索引（city，name）取下一个记录主键id；
4. 重复步骤2、3，直到查到第1000条记录，或者是不满足city=‘杭州’条件时循环结束

可以看到，这个查询过程不需要临时表，也不需要排序。

使用explain语句来印证一下，可以看到 Extra字段中没有 Using filesort了，也就是不需要排序了。而且由于（city，name）这个联合索引本身有序，所以这个查询也不用把4000行全都读一遍，只要找到满足条件的前1000条记录就可以退出了。

