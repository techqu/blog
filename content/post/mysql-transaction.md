---
title: "《MYSQL实战45讲》- 行锁、死锁、事务隔离"
date: 2019-03-14T17:23:42+08:00
lastmod: 2019-03-14T17:23:42+08:00
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

<!--more-->

## 行锁

MySQL的行锁是在引擎层由各个引擎自己实现的。比如MyISAM引擎就不支持行锁。不支持行锁意味着并发控制只能使用表锁，对于这种引擎的表，同一张表上任何时刻只能有一个更新在执行，这就会影响到业务并发度。

顾名思义，行锁就是针对数据表中行记录的锁。这很好理解，比如事务A更新了一行，而这时候事务B也要更新同一行，则必须等事务A的操作完成后才能进行更新。

### 两阶段锁

在InnoDB事务中，行锁是在需要的时候才加上的，但并不是不需要了就立刻释放，而是要等到事务结束时才释放。这个就是两阶段锁协议。

结论：**如果你的事务中需要锁多个行，要把最可能造成锁冲突、最可能影响并发度的锁尽量往后放**

## 死锁和死锁检测

事务A和事务B在互相等待对方的资源释放，就是进入了死锁状态。当出现死锁状态以后，有两种策略：

- 一种策略是，直接进入等待，知道超时。这个超时时间可以通过参数`innodb_lock_wait_timeout`来设置。
- 另一种策略是，发起死锁检测，发现死锁后，主动回滚死锁链条中的某个事务，让其他事务得以继续执行。将参数`innodb_deadlock_detect`设置为on，表示开启这个逻辑。

两种策略都有问题：

- 第一种策略：超时时间不能太短，也不能太长
- 第二种策略：判断期间比较消耗CPU资源

如何解决由这种热点行更新导致的性能问题呢？

  - 如果你能确保这个业务一定不会出现死锁，可以临时把死锁检测关掉
  - 控制并发度，比如同一行同时最多只有10个线程在更新，那么死锁检测的成本很低。在客户端做这个限制，如果有多个客户端也还是限制不住。因此这个控制要在数据库服务端做，可以在中间件做，或者修改MySQL源码。
  - 从设计上优化，比如将一行拆分成逻辑上的多行来减少锁冲突。比如账户余额，可以放在多条记录上，等于多行的和。每次做增加的时候，随机选取一行来加。这样冲突概率会减少到原来的n分之一。

## 事务

 - ACID
 - 可能出现的问题：脏读、不可重复读、幻读

### SQL标准的事务隔离级别

 - **读未提交**，一个事务还没提交时，它做的变更就能被别的事务看到。
 - **读已提交**，一个事务提交之后，它做的变更才会被其他事务看到。
 - **可重复读**，一个事务执行过程中看到的数据，总是跟这个事务在启动时看到的数据是一致的。当然在可重复读隔离级别下，未提交变更对其他事务也是不可见的。
 - **串行化**，当出现读写锁冲突的时候，后访问的事务必须等前一个事务执行完成，才能继续执行。
 
 其中“读提交”和“可重复读”比较难理解，用一个例子说明这几种隔离级别。

 ```sql

 mysql> create table T(c int) engine=InnoDB;
insert into T(c) values(1);

 ```

 ![mysql-transaction](/img/mysql-transaction.png)

我们来看看在不同的隔离级别下，事务A会有哪些不同的返回结果，也就是图里面V1、V2、V3的返回值分别是什么。

- 若隔离级别是“读未提交”，则V1的值就是2.这时候事务B虽然还没有提交，但是结果已经被A看到了。因此，V2、V3也都是2.
- 若隔离级别是“读已提交”，则V1的值是1，V2的值是2.事务B的更新在提交后才能被A看到，所以 V3 的值是2
- 若隔离级别是“可重复读”，则V1的值是1，V2的值是1，V3的值是2。遵循的就是这个要求：事务在执行期间看到的数据前后必须是一致的。
- 若隔离级别是“串行化”，则V1的值是1，V2的值是1，V3的值是2。因为在事务B执行“将1改成2”的时候，会被锁住。直到事务A提交后，事务B才可以继续执行。

实现原理：

在实现上，数据库里面会创建一个视图，访问的时候以视图的逻辑结果为准。

- 在“可重复读”隔离级别下，这个视图实在事务启动时创建的，整个事务存在期间都用这个视图；
- 在“读提交”隔离级别下，这个视图是在每个SQL语句开始执行的时候创建的；
- “读未提交”隔离级别下直接返回记录上的最新值，没有视图概念；
- 而“串行化”隔离级别下直接用加锁的方式来避免并行访问；

Oracle数据库的默认隔离级别其实就是“读提交”，因此对于一些从Oracle迁移到MySQL的应用，为保证数据库隔离界别的一致，你一定要记得将MySQL的隔离级别设置为“读提交”

配置事务的隔离级别

```sql
mysql> show variables like 'transaction_isolation';

+-----------------------+----------------+

| Variable_name | Value |

+-----------------------+----------------+

| transaction_isolation | READ-COMMITTED |

+-----------------------+----------------+

```

事务隔离的实现：每条记录在更新的时候都会同时记录一条回滚操作。同一条记录在系统中可以存在多个版本，这就是数据库的多版本并发控制（MVCC）。

回滚日志什么时候删除？系统会判断当没有事务需要用到这些回滚日志的时候，回滚日志会被删除。

什么时候不需要了？当系统里没有比这个回滚日志更早的read-view的时候。

为什么尽量不要使用长事务？长事务意味着系统里面存在很老的事务视图，在这个事务提交之前，回滚记录都要保留，这会导致大量占用存储空间。除此之外，长事务还占用锁资源，可能会拖垮库。

事务启动方式：

1. 显式启动事务语句，begin或者start transaction，提交 commit，回滚 rollback；
2. set autocommit=0，该命令会把这个线程的自动提交关掉。这样只要执行一个select语句，事务就会启动，并不会自动提交，直到主动commit或rollback或断开连接。

建议使用第一种方式，如果考虑多一次交互问题，可以使用 `commit work and chain` 语法。在autocommit=1的情况下使用begin显式启动事务，如果执行commit则提交事务。如果执行commit work and chain 则提交事务并自动启动下一个事务。


可以在information_schema库的innodb_trx这个表中查询长事务，比如下面这个语句，用来查找持续时间超过60s的事务。

```sql
select * from information_schema.innodb_trx where TIME_TO_SEC(timediff(now(),trx_started))>60
```