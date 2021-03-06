---
title: "《MYSQL实战45讲》- 深入浅出索引"
date: 2019-03-16T15:25:44+08:00
lastmod: 2019-03-16T15:25:44+08:00
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
  enable: false
  options: ""

sequenceDiagrams: 
  enable: false
  options: ""

---

简单来说，索引的出现其实就是为了提高数据查询的效率，就像书的目录一样。
<!--more-->

## 索引的常见模型

可以用于提高读写效率的数据结构很多，这里先介绍三种常见的、也比较简单的数据结构，他们分别是哈希表、有序数组和搜索树。

- 哈希表这种结构适用于只有等值查询的场景。
- 而有序数组在等值查询和范围查询场景中的性能就都非常优秀。但是，在需要更新数据的时候就麻烦了，你往中间插入一个记录就必须得挪动后面所有的记录，成本太高。所以，有序数组索引只适用于静态存储引擎。
- 二叉搜索树

  - 为了维持O(log(N))的查询复杂度，你就需要保持这棵树是平衡二叉树
  - 二叉树是搜索效率中最高的，但是实际上大多数的数据库存储却不使用二叉树。其原因是，索引不止存在内存中，还要写到磁盘上。一颗100万节点的平衡二叉树，树高20，一次查询可能需要访问20个数据块。为了让一个查询尽量少读磁盘，就必须让查询过程访问尽量少的数据块。那么我们就要使用N叉树。N取决于数据块的大小。

## InnoDB的索引模型

每一个索引在InnoDB里面对应一棵B+树

假设，我们有一个主键列为ID的表，表中有字段k，并且在k上有索引。

```sql

mysql> create table T(
id int primary key, 
k int not null, 
name varchar(16),
index (k))engine=InnoDB;

```
表中 R1~R5 的 (ID,k) 值分别为 (100,1)、(200,2)、(300,3)、(500,5) 和 (600,6)，两棵树的示例示意图如下。

![InnoDB的索引组织结构](/img/InnoDB-index.png)

根据叶子节点的内容，索引类型分为主键索引和非主键索引。

**主键索引的叶子节点存的是整行数据。**在InnoDB里，主键索引也被称为聚簇索引（clustered index）

**非主键索引的叶子节点内容是主键的值。**在InnoDB里，非主键索引也被称为二级索引（secondary index）

 基于主键索引和普通索引的查询有什么区别？

- 主键查询方式，则只需要搜索ID这棵B+树；
- 普通索引查询方式，则需要先搜索k索引树，得到ID的值为500，再到ID索引树搜索一次。这个过程称为**回表**。


## 索引维护

B+树为了维护索引有序性，在插入新值的时候需要做必要的维护。更糟糕的是，如果所在的数据页已经满了，根据B+树的算法，这时候需要申请一个新的数据页，然后挪动部分数据过去。这个过程称为**页分裂**。这种情况下，性能自然会受影响。

除了性能外，页分裂操作还影响数据页的利用率。原本放在一个页的数据，现在分到两个页中，整体空间利用率降低大约50%。当然有分裂就有合并。当相邻两个页由于删除了数据，利用率很低之后，会将数据页做合并。合并的过程，可以认为是分裂过程的逆过程。

自增主键的插入数据模式，正符合了我们前面提到的递增插入的场景。每次插入一条新纪录，都是追加操作，都不涉及挪动其他记录，也不会触发叶子节点的分裂。

而有业务逻辑的字段做主键，则往往不容易保证有序插入，这样写数据成本相对较高。

**显然，主键长度越小，普通索引的叶子节点就越小，普通索引占用的空间也就越小。**

## 覆盖索引


回到主键索引树搜索的过程，我们称为回表。由于查询结果所需要的数据只在主键索引上有，所以不得不回表。

如果执行的语句是`select ID from T where k between 3 and 5`，这时只需要查ID的值，而ID的值已经在k索引树上了，因此可以直接提供查询结果，不需要回表。也就是说，在这个查询里面，索引k已经“覆盖了”我们的查询需求，我们称为覆盖索引。

**由于覆盖索引可以减少树的搜索次数，显著提升查询性能，所以使用覆盖索引是一个常用的性能优化手段**

## 最左前缀原则

```sql
CREATE TABLE `tuser` (
  `id` int(11) NOT NULL,
  `id_card` varchar(32) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `ismale` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_card` (`id_card`),
  KEY `name_age` (`name`,`age`)
) ENGINE=InnoDB

```
这个最左前缀可以是联合索引的最左N个字段，也可以是字符串索引的最左M个字符。

**在建立联合索引的时候，如何安排索引内的顺序。**

- 比如，当有了（a,b）这个联合索引后，一般就不需要单独在a上建立索引了。**第一原则是，如果通过调整顺序，可以少维护一个索引，那么这个顺序往往就是需要优先考虑采用的。**
- 那么，如果既有联合查询，又有基于a、b各自的查询？查询条件里面只有b的语句，是无法使用（a，b）这个联合索引，这时候你不得不维护另外一个索引，也就是说你需要同时维护（a，b）、（b）两个索引。**这时候，我们要考虑的原则就是空间了**.比如name字段比age字段大，就建立一个（name，age）的联合索引和一个（age）的单字段索引。

## 索引下推


**MySQL5.6引入的索引下推优化，可以在索引遍历过程中，对索引中包含的字段先做判断，直接过滤掉不满足条件的记录，减少回表次数。**


```sql
mysql> select * from tuser where name like '张 %' and age=10 and ismale=1;
```

根据前缀索引规则，所以这个语句在搜索索引树的时候，只能用“张”，找到第一个满足条件的记录ID3.

但是由于索引下推，InnoDB在(name,age)索引内部就判断了age是否等于10，对于不等于10的记录，直接判断跳过。



## 总结：

一：

1. 索引的作用：提高数据查询效率
2. 常见索引模型：哈希表、有序数组、搜索树
3. 哈希表：键 - 值(key - value)。
4. 哈希思路：把值放在数组里，用一个哈希函数把key换算成一个确定的位置，然后把value放在数组的这个位置
5. 哈希冲突的处理办法：链表
6. 哈希表适用场景：只有等值查询的场景
7. 有序数组：按顺序存储。查询用二分法就可以快速查询，时间复杂度是：O(log(N))
8. 有序数组查询效率高，更新效率低
9. 有序数组的适用场景：静态存储引擎。
10. 二叉搜索树：每个节点的左儿子小于父节点，父节点又小于右儿子
11. 二叉搜索树：查询时间复杂度O(log(N))，更新时间复杂度O(log(N))
12. 数据库存储大多不适用二叉树，因为树高过高，会适用N叉树
13. InnoDB中的索引模型：B+Tree
14. 索引类型：主键索引、非主键索引
主键索引的叶子节点存的是整行的数据(聚簇索引)，非主键索引的叶子节点内容是主键的值(二级索引)
15. 主键索引和普通索引的区别：主键索引只要搜索ID这个B+Tree即可拿到数据。普通索引先搜索索引拿到主键值，再到主键索引树搜索一次(回表)
16. 一个数据页满了，按照B+Tree算法，新增加一个数据页，叫做页分裂，会导致性能下降。空间利用率降低大概50%。当相邻的两个数据页利用率很低的时候会做数据页合并，合并的过程是分裂过程的逆过程。
17. 从性能和存储空间方面考量，自增主键往往是更合理的选择。

思考题：

- 如果删除，新建主键索引，会同时去修改普通索引对应的主键索引，性能消耗比较大。
- 删除重建普通索引貌似影响不大，不过要注意在业务低谷期操作，避免影响业务。

二：

1. 回表：回到主键索引树搜索的过程，称为回表
2. 覆盖索引：某索引已经覆盖了查询需求，称为覆盖索引，例如：select ID from T where k between 3 and 5
3. 在引擎内部使用覆盖索引在索引K上其实读了三个记录，R3~R5(对应的索引k上的记录项)，但对于MySQL的Server层来说，它就是找引擎拿到了两条记录，因此MySQL认为扫描行数是2
4. 最左前缀原则：B+Tree这种索引结构，可以利用索引的"最左前缀"来定位记录
5. 只要满足最左前缀，就可以利用索引来加速检索。
6. 最左前缀可以是联合索引的最左N个字段，也可以是字符串索引的最左M个字符
7. 第一原则是：如果通过调整顺序，可以少维护一个索引，那么这个顺序往往就是需要优先考虑采用的。
8. 索引下推：在MySQL5.6之前，只能从根据最左前缀查询到ID开始一个个回表。到主键索引上找出数据行，再对比字段值。
9. MySQL5.6引入的索引下推优化，可以在索引遍历过程中，对索引中包含的字段先做判断，直接过滤掉不满足条件的记录，减少回表次数