---
title: "《MYSQL实战45讲》- 行锁、死锁、事务"
date: 2019-03-14T17:23:42+08:00
lastmod: 2019-03-14T17:23:42+08:00
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

<!--more-->




## 行锁

MySQL的行锁是在引擎层由各个引擎自己实现的。比如MyISAM引擎就不支持行锁。不支持行锁意味着并发控制只能使用表锁，对于这种引擎的表，同一张表上任何时刻只能有一个更新在执行，这就会影响到业务并发度。

顾名思义，行锁就是针对数据表中行记录的锁。这很好理解，比如事务A更新了一行，而这时候事务B也要更新同一行，则必须等事务A的操作完成后才能进行更新。

### 两阶段锁

**在InnoDB事务中，行锁是在需要的时候才加上的，但并不是不需要了就立刻释放，而是要等到事务结束时才释放。这个就是两阶段锁协议。**

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

 - 读未提交，一个事务还没提交时，它做的变更就能被别的事务看到。
 - 读已提交，一个事务提交之后，它做的变更才会被其他事务看到。
 - 可重复读，一个事务执行过程中看到的数据，总是跟这个事务在启动时看到的数据是一致的。当然在可重复读隔离级别下，未提交变更对其他事务也是不可见的。
 - 串行化，当出现读写锁冲突的时候，后访问的事务必须等前一个事务执行完成，才能继续执行。


## 乐观锁和MVCC的区别

在数据库中，并发控制是指在多个用户、进程、线程同时对数据库进行操作时，如何保证事务的一致性和隔离性，同时最大程度地并发。

当多个用户、进程、线程同时对数据库进行操作时，会出现3种冲突情形：

1. 读-读，不存在任何问题
2. 读-写，有隔离性问题，可能遇到脏读（读到未提交的数据），幻影读等。
3. 写-写，可能丢失更新

要解决冲突，一种办法就是锁，即基于锁的并发控制，比如2PL，这种方式开销比较高，而且无法完全避免死锁。

多版本并发控制（MVCC）是一种用来解决读-写冲突的无锁并发控制，也就是为了事务分配单向增长的时间戳，为每个修改保存一个版本，版本与事务时间戳关联，读操作只读该事务开始前的数据库的快照。这样在读操作不用阻塞写操作，写操作不用阻塞读操作的同时，避免了脏读和不可重复读。

乐观并发控制（OCC）是一种用来解决写-写冲突的无锁并发控制，认为事务间争用没有那么多，所以先进行修改，在提交事务前，检查一下事务开始后，有没有新的提交改变，如果没有就提交，如果有就放弃并重试。乐观并发控制类似自旋锁。乐观并发控制适用于低数据争用，写冲突比较少的环境。

多版本并发控制可以结合基于锁的并发控制来解决写-写冲突，即 MVCC+2PL，也可以结合乐观并发控制来解决写-写冲突。

