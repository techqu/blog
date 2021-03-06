---
title: "《MYSQL实战45讲》-笔记"
date: 2018-12-19T17:32:22+08:00
lastmod: 2019-05-22T22:27:38+08:00
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

MYSQL实战45讲-极客时间笔记

<!--more-->


## 基础架构：一条SQL查询语句是如何执行的

### mysql架构组成

MySQL的逻辑架构图

![mysql-framework](/img/mysql-framework.png)

 - server端
    - 连接器：管理连接、权限验证
    - 分析器：词法分析、语法分析
    - 优化器：执行计划生成、索引选择
    - 执行器：操作引擎、返回结果
 - 存储引擎：存储数据，提供读写接口


![img/MySQL-Architecture.png](/img/MySQL-Architecture.png)

## 日志系统：一条SQL更新语句是如何执行的

```
mysql> create table T(ID int primary key, c int);

mysql> update T set c=c+1 where ID=2;

```
### InnodDB redo log 

如果每次的更新操作都需要写进磁盘，然后磁盘也要找到对应的那条记录，然后再更新，整个过程IO成本、查找成本都很高。为了解决这个问题，MySQL的设计者就用了类似酒店掌柜粉板的思路来提升更新效率。

具体来说，当有一条记录需要更新的时候，InnoDB引擎就会把记录写到redo log（粉板）里面，并更新内存，这个时候更新就算完成了。同时，InnoDB引擎会在适当的时候，将这个操作记录更新到磁盘里面，而这个更新往往是在系统比较空闲的时候，这就像打烊以后掌柜做的事。


 - WAL技术：Write-Ahead Logging，先写日志，再写磁盘
 - 当有一条记录需要更新的时候，InnoDB引擎就会先把记录写到redo log里，并更新内存。其它合适时间再写入磁盘


有了redo log，Inno DB就可以保证即使数据库发生异常重启，之前提交的记录都不会丢失，这个能力称为**crash-safe**

### MYSQL binlog（归档日志）

redo log是 InnoDB 引擎特有的日志，而Server层也有自己的日志，称为binlog。

### 不同点

 1. redo log是InnoDB引擎特有的，binlog是MYSQL的Server层实现的，所有引擎都能用
 2. redo log是物理日志，记录的是“在某个数据页上做了什么修改”；binlog是逻辑日志，记录的是这个语句的原始逻辑。
 3. redo log是循环写的，空间固定会用完；binlog是可以追加写入的，写到一定大小会切换到下一个文件，不会覆盖以前的日志。

我们来看执行器和InnoDB引擎在执行这个简单的 update 语句时的内部流程。

1. 执行器先找引擎取 ID=2 这一行。 ID 是主键，引擎直接用树搜索找到这一行。如果ID=2 这一行所在的数据页本来就在内存中，就直接返回给执行器；否则，需要先从磁盘读入内存，然后再返回。
2. 执行器拿到引擎给的行数据，把这个值加上 1 ，比如原来是 N ， 现在就是 N+1 ，得到新的一行数据，再调用引擎接口写入这行新数据。
3. 引擎将这行数据更新到内存中，同时将这个更新操作记录到 redo log里面，此时 redo log处于 prepare状体啊。然后告知执行期执行完成了，随时可以提交事务。
4. 执行器生成这个操作的binlog，并把binlog写入磁盘。
5. 执行器调用引擎的提交事务接口，引擎把刚刚写入的redo log改成 提交（commit）状态，更新完成。


### redolog两阶段提交

 - 简单说，redo log 和binlog都可以用于表示事务的提交状态，而两阶段提交就是让这两个状态保持逻辑上的一致。
 
## 事务隔离：为什么你改了我还看不见

 - ACID
 - 可能出现的问题：脏读、不可重复读、幻读

### SQL标准的事务隔离级别

 - 读未提交
 - 读已提交
 - 可重复读
 - 串行化

### 事务隔离的实现
### 事务的启动方式
## 深入浅出索引(上)
### 索引的常见类型
### InnoDB的索引类型
### 索引维护
## 深入浅出索引(下)

- 回到主键索引树搜索的过程，称为回表

### 覆盖索引

- 由于覆盖索引可以减少书的搜索次数，显著提升查询性能，所以使用覆盖索引是一个常用的性能优化手段

### 最左前缀原则

 - 第一原则是，如果通过调整顺序，可以少维护一个索引，那么这个顺序往往需要优先考虑采用的。

### 索引下推

- mysql5.6之后引入索引下推优化（index condition pushdown），可以在索引遍历过程中，对索引中包含的字段先做判断，直接过滤调不满足条件的记录，减少回表次数


### MySQL中explain的type类型

**注：由上至下，效率越来越高**

| type | 含义 |
| --- | --- |
|  ALL              |  全表扫描 |
|  index            |  索引全扫描 |
|  range            |  索引范围扫描，常用语<,<=,>=,between等操作 |
|  ref                |  使用非唯一索引扫描或唯一索引前缀扫描，返回单条记录，常出现在关联查询中 |
|  eq_ref           |  类似ref，区别在于使用的是唯一索引，使用主键的关联查询 |
|  const/system  |  单条记录，系统会把匹配行中的其他列作为常数处理，如主键或唯一索引查询 |
|  null                |  MySQL不访问任何表或索引，直接返回结果 |

 
## 全局锁和表锁

### 全局锁的典型使用场景是，做全库逻辑备份

### 表级锁

 1. 表锁 lock tables ... read/write ,一般不使用
 2. 元数据锁（meta data lock，MDL）MYSQL5.5引入MDL
    -  当对一个表做增删改查操作的时候，加MDL读锁；
    -  当要对表做结构变更操作的时候，加MDL写锁；

## 行锁
- 两阶段锁协议
- 死锁和死锁检测

## 事务到底是隔离的还是不隔离的

 - “快照”在MVCC里是怎么工作的
 - InnoDB利用了“所有数据都有多个版本”的这个特性，实现了“秒级创建快照”的能力

## 普通索引和唯一索引，应该如何选择

- 从普通索引和唯一索引的选择开始，分享了数据的查询和更新过程，然后说明了change buffer的机制以及应用场景，最后讲到了索引选择的实践。
- 由于唯一索引用不上change buffer的优化机制，因此如果业务可以接受，从性能角度出发，建议优先考虑非唯一索引。


### change buffer 和 redolog 对比

redolog 用的WAL技术，更新操作记录在日志里，是为了减少当前读写磁盘，优化的是这次更新的读写操作。

> 出自：[02 | 日志系统：一条SQL更新语句是如何执行的？](https://time.geekbang.org/column/article/68633)



chang buffer是把更新操作记录在内存里，是为了减少后续查询读磁盘，优化的是后续的读操作。

> 出自：[09 | 普通索引和唯一索引，应该怎么选择？](https://time.geekbang.org/column/article/70848)


## in和OR对比的结论：

1.in或or在字段有添加索引的情况下，查询很快，两者查询速度没有什么区别；

2.in或or在字段没有添加索引的情况下,所连接的字段越多(1or2or3or4or......)，or比in的查询效率低很多




## 18|为什么这些SQL语句逻辑相同，性能却差异巨大？

案例一：条件字段函数操作

**对索引字段做函数操作，可能会破坏索引值的有序性，因此优化器就决定放弃走树搜索功能**

比如对 t_modified 字段加了 month（）函数操作，导致了全索引扫描。无法使用索引的快速定位能力了。


 案例二： 隐式类型转换

 按理三： 隐式字符编码转换


## 19 | 为什么我只查一行的语句，也执行这么慢？
表级：

1. 查询长时间不返回。是使用 show processlist 命令查看 Wait for table metadata lock
2. 等flush。所以，出现 Waiting for table flush 状态的可能情况是：有一个 flush tables 命令被别的语句堵住了，然后它又堵住了我们的 select 语句。

行级别：

3. 等行锁
4. 查询慢

## 20 | 幻读是什么，幻读有什么问题？
## 21 | 为什么我只改一行的语句，锁这么多？
## 22 | MySQL有哪些“饮鸩止渴”提高性能的方法？
## 23 | MySQL是怎么保证数据不丢的？
## 24 | MySQL是怎么保证主备一致的？
## 25 | MySQL是怎么保证高可用的？
## 26 | 备库为什么会延迟好几个小时？
## 27 | 主库出问题了，从库怎么办？
## 28 | 读写分离有哪些坑？
## 29 | 如何判断一个数据库是不是出问题了？
## 30 | 答疑文章（二）：用动态的观点看加锁
## 31 | 误删数据后除了跑路，还能怎么办？
## 32 | 为什么还有kill不掉的语句？
## 33 | 我查这么多数据，会不会把数据库内存打爆？
## 34 | 到底可不可以使用join？
## 35 | join语句怎么优化？
## 36 | 为什么临时表可以重名？
## 37 | 什么时候会使用内部临时表？
## 38 | 都说InnoDB好，那还要不要使用Memory引擎？
## 39 | 自增主键为什么不是连续的？
## 40 | insert语句的锁为什么这么多？
## 41 | 怎么最快地复制一张表？
## 42 | grant之后要跟着flush privileges吗？
## 43 | 要不要使用分区表？
## 44 | 答疑文章（三）：说一说这些好问题
## 45 | 自增id用完怎么办？
## 结束语 | 点线网面，一起构建MySQL知识网络