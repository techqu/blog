---
title: "mysql-行锁+间隙锁（next-key lock）"
date: 2020-01-10T21:27:38+08:00
lastmod: 2020-01-10T21:27:38+08:00
draft: false
keywords: []
description: ""
tags: ["MySQL"]
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
本文主要介绍了幻读带来的问题 ，以及 mysql给出的解决办法，即 next-key lock。
<!--more-->

### 幻读

#### 1-1：什么是幻读？

幻读是指在同一个事务中，存在前后两次查询同一个范围的数据，但是第二次查询却看到了第一次查询没看到的行。

比如：事务在插入已经检查过不存在的记录时，惊奇的发现这些数据已经存在了。

注意，幻读出现的场景

第一：事务的隔离级别为可重复读，且是当前读

第二：幻读仅专指新插入的行

#### 1-2：幻读带来的问题？
一是，对行锁语义的破坏
二是，破坏了数据一致性

#### 1-3：怎么避免幻读？

存储引擎采用加间隙锁的方式来避免出现幻读

#### 1-4：为啥会出现幻读？

行锁只能锁定存在的行，针对新插入的操作没有限定

#### 1-5：间隙锁是啥？它怎么避免出现幻读的？它引入了什么新的问题？

间隙锁，是专门用于解决幻读这种问题的锁，它锁的了行与行之间的间隙，能够阻塞新插入的操作
间隙锁的引入也带来了一些新的问题，比如：降低并发度，可能导致死锁。

注意，读读不互斥，读写/写读/写写是互斥的，但是间隙锁之间是不冲突的，间隙锁会阻塞插入操作


### 为什么需要间隙锁

我们给所有行加锁的时候，这一行还不存在，不存在也就加不上锁。

也就是说，即使把所有的记录都加上锁，还是阻止不了新插入的记录，这也是为什么“幻读”会被单独拿出来解决的原因。

产生幻读的原因是，行锁只能锁住行，但是新插入记录这个动作，要更新的是记录之间的“间隙”。因此，为了解决幻读问题，InnoDB 只好引入新的锁，也就是间隙锁 (Gap Lock)。

### Mysql中的间隙锁

下表中（见图一），id为主键，number字段上有非唯一索引的二级索引，有什么方式可以让该表不能再插入number=5的记录？

图一
![img/mysql-gap-lock-01](/img/mysql-gap-lock-01.webp)

根据上面生活中的例子，我们自然而然可以想到，只要控制几个点，number=5**之前**不能插入记录，number=5现有的记录**之间**不能再插入新的记录，number=5**之后**不能插入新的记录，那么新的number=5的记录将不能被插入进来。

那么，mysql是如何控制number=5之前，之中，之后不能有新的记录插入呢（防止幻读）？
答案是用间隙锁，在RR级别下，mysql通过间隙锁可以实现锁定number=5之前的间隙，number=5记录之间的间隙，number=5之后的间隙，从而使的新的记录无法被插入进来。

### 间隙是怎么划分的？

注：为了方面理解，我们规定（id=A,number=B）代表一条字段id=A,字段number=B的记录，（C，D）代表一个区间，代表C-D这个区间范围。

图一中，根据number列，我们可以分为几个区间：（无穷小，2），（2，4），（4，5），（5，5），（5,11），（11，无穷大）。
只要这些区间对应的两个临界记录中间可以插入记录，就认为区间对应的记录之间有间隙。
例如：区间（2，4）分别对应的临界记录是（id=1,number=2），（id=3，number=4），这两条记录中间可以插入（id=2,number=3）等记录，那么就认为（id=1,number=2）与（id=3，number=4）之间存在间隙。

很多人会问，那记录（id=6，number=5）与（id=8，number=5）之间有间隙吗？
答案是有的，（id=6，number=5）与（id=8，number=5）之间可以插入记录（id=7，number=5），因此（id=6,number=5）与（id=8,number=5）之间有间隙的，

### 间隙锁锁定的区域

根据检索条件向左寻找最靠近检索条件的记录值A，作为左区间，向右寻找最靠近检索条件的记录值B作为右区间，即锁定的间隙为（A，B）。
图一中，where number=5的话，那么间隙锁的区间范围为（4,11）；

### 间隙锁的目的是为了防止幻读，其主要通过两个方面实现这个目的：

（1）防止间隙内有新数据被插入

（2）防止已存在的数据，更新成间隙内的数据（例如防止numer=3的记录通过update变成number=5）

### innodb自动使用间隙锁的条件：

 （1）必须在RR级别下

 （2）检索条件必须有索引（没有索引的话，mysql会全表扫描，那样会锁定整张表所有的记录，包括不存在的记录，此时其他事务不能修改不能删除不能添加）

**接下来，通过实际操作观察下间隙锁的作用范围**



####  案例一

````sql
session 1:
start  transaction ;
select  * from news where number=4 for update ;

session 2:
start  transaction ;
insert into news value(2,4);#（阻塞）
insert into news value(2,2);#（阻塞）
insert into news value(4,4);#（阻塞）
insert into news value(4,5);#（阻塞）
insert into news value(7,5);#（执行成功）
insert into news value(9,5);#（执行成功）
insert into news value(11,5);#（执行成功）
````

检索条件number=4,向左取得最靠近的值2作为左区间，向右取得最靠近的5作为右区间，因此，session 1的间隙锁的范围（2，4），（4，5），如下图所示：

![img/mysql-gap-lock-02](/img/mysql-gap-lock-02.webp)


间隙锁锁定的区间为（2，4），（4，5），即记录（id=1,number=2）和记录（id=3,number=4）之间间隙会被锁定，记录（id=3,number=4）和记录（id=6,number=5）之间间隙被锁定。

因此记录（id=2,number=4），（id=2,number=2），（id=4,number=4），（id=4,number=5）正好处在（id=3,number=4）和（id=6,number=5）之间，所以插入不了，需要等待锁的释放，而记录(id=7,number=5)，（id=9,number=5），（id=11,number=5）不在上述锁定的范围内，因此都会插入成功。

#### 案例二

````sql
session 1:
start  transaction ;
select  * from news where number=13 for update ;

session 2:
start  transaction ;
insert into news value(11,5);#(执行成功)
insert into news value(12,11);#(执行成功)
insert into news value(14,11);#(阻塞)
insert into news value(15,12);#(阻塞)
update news set id=14 where number=11;#(阻塞)
update news set id=11 where number=11;#(执行成功)
````

检索条件number=13,向左取得最靠近的值11作为左区间，向右由于没有记录因此取得无穷大作为右区间，因此，session 1的间隙锁的范围（11，无穷大），如下图所示：

![img/mysql-gap-lock-03](/img/mysql-gap-lock-03.webp)


此表中没有number=13的记录的，innodb依然会为该记录左右两侧加间隙锁，间隙锁的范围（11，无穷大）。

有人会问，为啥update news set id=14 where number=11会阻塞，但是update news set id=11 where number=11却执行成功呢？

间隙锁采用在指定记录的前面和后面以及中间的间隙上加间隙锁的方式避免数据被插入，此图间隙锁锁定的区域是（11，无穷大），也就是记录（id=13,number=11）之后不能再插入记录，update news set id=14 where number=11这条语句如果执行的话，将会被插入到（id=13,number=11）的后面，也就是在区间（11，无穷大）之间，由于该区间被间隙锁锁定，所以只能阻塞等待，而update news set id=11 where number=11执行后是会被插入到（id=13,number=11）的记录前面，也就不在（11，无穷大）的范围内，所以无需等待，执行成功。

#### 案例三

````sql
session 1:
start  transaction ;
select  * from news where number=5 for update;

session 2:
start  transaction ;
insert into news value(4,4);#(阻塞)
insert into news value(4,5);#(阻塞)
insert into news value(5,5);#(阻塞)
insert into news value(7,11);#(阻塞)
insert into news value(9,12);#(执行成功)
insert into news value(12,11);#(阻塞)
update news set number=5 where id=1;#(阻塞)
update news set id=11 where number=11;#(阻塞)
update news set id=2 where number=4 ;#（执行成功）
update news set id=4 where number=4 ;#（阻塞）
````
检索条件number=5,向左取得最靠近的值4作为左区间，向右取得11为右区间，因此，session 1的间隙锁的范围（4，5），（5，11），如下图所示：

![img/mysql-gap-lock-04](/img/mysql-gap-lock-04.webp)


有人会问，为啥`insert into news value(9,12)`会执行成功？间隙锁采用在指定记录的前面和后面以及中间的间隙上加间隙锁的方式避免数据被插入，（id=9,number=12）很明显在记录（13,11）的后面，因此不再锁定的间隙范围内。

为啥`update news set number=5 where id=1`会阻塞？
number=5的记录的前面，后面包括中间都被封锁了，你这个`update news set number=5 where id=1`根本没法执行，因为innodb已经把你可以存放的位置都锁定了，因为只能等待。

同理，`update news set id=11 where number=11`由于记录（id=10,number=5）与记录（id=13,number=11）中间的间隙被封锁了，你这句sql也没法执行，必须等待，因为存放的位置被封锁了。

**案例四：**
```sql
session 1:
start  transaction;
select * from news where number>4 for update;

session 2:
start  transaction;
update news set id=2 where number=4 ;#(执行成功)
update news set id=4 where number=4 ;#(阻塞)
update news set id=5 where number=5 ;#(阻塞)
insert into news value(2,3);#(执行成功)
insert into news value(null,13);#(阻塞)
```
检索条件number>4,向左取得最靠近的值4作为左区间，向右取无穷大，因此，session 1的间隙锁的范围（4，无穷大），如下图所示：

![img/mysql-gap-lock-05](/img/mysql-gap-lock-05.webp)


session2中之所以有些阻塞，有些执行成功，其实就是因为插入的区域被锁定，从而阻塞。

### next-key锁

next-key锁其实包含了记录锁和间隙锁，即锁定一个范围，并且锁定记录本身，InnoDB默认加锁方式是next-key 锁。
上面的案例一session 1中的sql是：`select * from news where number=4 for update `;
next-key锁锁定的范围为间隙锁+记录锁，即区间（2，4），（4，5）加间隙锁，同时number=4的记录加记录锁。



### 加锁规则总结

我总结的加锁规则里面，包含了两个“原则”、两个“优化”和一个“bug”。

**原则 1**：加锁的基本单位是 next-key lock。希望你还记得，next-key lock 是前开后闭区间。

**原则 2**：查找过程中访问到的对象才会加锁。

**优化 1**：索引上的等值查询，给唯一索引加锁的时候，next-key lock 退化为行锁。

**优化 2**：索引上的等值查询，向右遍历时且最后一个值不满足等值条件的时候，next-key lock 退化为间隙锁。

**一个 bug**：唯一索引上的范围查询会访问到不满足条件的第一个值为止。

### 其他案例
案例一：等值查询间隙锁

根据原则 1，加锁单位是 next-key lock，session A 加锁范围就是 (5,10]；同时根据优化 2，这是一个等值查询 (id=7)，而 id=10 不满足查询条件，**next-key lock 退化成间隙锁**，因此最终加锁的范围是 (5,10)。


案例二：非唯一索引等值锁

案例三：主键索引范围锁

案例四：非唯一索引范围锁

案例五：唯一索引范围锁 bug

案例六：非唯一索引上存在"等值"的例子

案例七：limit 语句加锁

delete 语句明确加了 limit  的限制，因此在遍历之后，满足条件的语句已经有两条，循环就结束了。

对我们实践的指导意义就是，在删除数据的时候尽量加 limit。这样不仅可以控制删除数据的条数，让操作更安全，还可以减小加锁的范围。

案例八：一个死锁的例子

>作者：xdd_mdd

>链接：https://www.jianshu.com/p/bf862c37c4c9

>来源：简书

>著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。