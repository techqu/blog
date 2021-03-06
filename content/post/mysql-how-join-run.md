---
title: "《MYSQL实战45讲》-Join语句是怎么执行的"
date: 2019-02-22T22:27:38+08:00
lastmod: 2019-02-22T22:27:38+08:00
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




## 1 准备工作：

```
CREATE TABLE `t2` (
  `id` int(11) NOT NULL,
  `a` int(11) DEFAULT NULL,
  `b` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `a` (`a`)
) ENGINE=InnoDB;

drop procedure idata;
delimiter ;;
create procedure idata()
begin
  declare i int;
  set i=1;
  while(i<=1000)do
    insert into t2 values(i, i, i);
    set i=i+1;
  end while;
end;;
delimiter ;
call idata();

create table t1 like t2;
insert into t1 (select * from t2 where id<=100)

```
简单解释：

- dll 表名T1, 字段：id,a,b
- dll 表名T2, 字段：id,a,b
- id和a上有索引，b上无索引
- 往T2插入1000行数据，t1插入100行

## 2 三种方法
## 2.1 Index Nested-Loop Join(驱动表上有索引)

```sql
selec * from t1 straight_join t2 on (t1.a = t2.a)
```
straight_join

> TRAIGHT_JOIN is similar to JOIN, except that the left table is always read before the right table. 
> This can be used for those (few) cases for which the join optimizer puts the tables in the wrong order

意思就是说STRAIGHT_JOIN功能同join类似，但能让左边的表来驱动右边的表，能改表优化器对于联表查询的执行顺序。

因此：t1是驱动表，t2是被驱动表

### 执行流程：

1. 从表 t1 中读入一行数据R；
2. 从数据行 R 中，取出 a 字段到表 t2 里去查找；
3. 取出表 t2 中满足条件的行，更 R 组成一行，作为结果集的一部分；
4. 重复执行步骤 1 和 3 ，知道 t1 的末尾循环结束。

在形式上，这个过程就跟我们写成程序时的嵌套查询类似，并且**可以用上被驱动表的索引，所以我们成为“Index Nested-Loop Join”，简称NLJ**

### 流程分析

在这个流程中：

1. 对驱动表t1做了全表扫描，这个过程需要扫描100行；
2. 而对于每一行R，根据a字段去表t2查找，走的是树搜索过程，由于我们构造的数据都是一一对应的，因此每次的搜索过程都只扫描一行，也是总共扫描100行
3. 所以，整个执行流程，总扫描行数是200行。

### 如果不使用join:

1. 执行select * from t1，查出t1的所有数据，100行
2. 循环遍历这100行：
    - 从每一行R取出字段a的值$R.a;
    - 执行select * from t2 where a=$R.a;
    - 把返回结果和R构成结果集的一行。

可以看到，在这个查询过程，也是扫描了200行，但是总共执行了101条语句，**比直接join多了100次交互**。除此之外，**客户端还要自己拼接SQL语句。**

显然，这么做还不如直接join好。

### 问题二：怎么选择驱动表？

**在这个join语句执行过程中，驱动表是走全表扫描，而被驱动表是走树搜索。**

假设被驱动表的行数是M。每次在被驱动表一行数据，要先搜索索引a，再搜索主键索引。每次搜索一棵树近似复杂度是以 2 为底的M的对数，记为log2M，所以再被驱动表上查一行的时间复杂度是 2*log2M。

### 结论：

1. 使用join语句，性能比强行拆成多个单表执行sql语句的性能要好。
2. 如果使用join语句的话，需要让小表做驱动表

但是，需要注意，这个结论的前提是 **可以使用被驱动表的索引**

## 2.2 Simple Nested-loop join

我们现在把sql语句改成这样

```sql
select * from t1 straight_join t2 on (t1.a = t2.b)
```
由于表t2的字段b上没有索引，因此再用图2的执行流程时，每次到t2去匹配的时候，就要做一次全表扫描

这时，每次t2去匹配的时候，就要做一次全表扫描。这个sql请求就要扫描表t2多大100次，总共扫描100*1000=10万行。

当然MYSQL没有使用这个方法，而是下面的 `Block Nested-Loop Join`

## 2.3 Block Nested-Loop Join(被驱动表上没有可用的索引)

这时候，被驱动表上没有可用的索引，算法的流程是这样的：

1. 把表t1的数据读入线程内存`join_buffer`中，由于我们这个语句中写的是select *，因此是把整个t1放入了内存；
2. 扫描表t2，把表t2的每一行取出来，跟`join_buffer`中的数据做对比，满足join条件的，作为结果集的一部分返回。

可以看到，在这个过程中，对表t1和t2都做了一次全表扫描，因此总的扫描行数是1100.由于`join_buffer`是以无序数组的方式组织的，因此对表t2中的每一行，都要做100次判断，总共需要在内存中做的判断次数是：100*1000=10万行。

前面我们说过，如果使用`Simple Nested-Loop Join`算法进行查询，扫描行数也是10万行。因此，从时间复杂度上来说，这两个算法是一样的。但是Block Nested-Loop Join算法的这10万次判断是内存操作，速度上会快很多，性能也更好

接下来，我们来看一下，在这种情况下，应该选择哪个表做驱动表。

假设小表的行数据是N，大表的行数是M，那么在这个算法里：

1. 两个表都做一次全表扫描，所以总的扫描行数是M+N；
2. 内存中的判断次数是M*N

可以看到，调换这两个算式重的M和N没有区别，因此这时候选择大表还是小表做驱动表，执行耗时是一样的。

然后，你可能马上就会问了，这个例子里t1才100行，要是表t1是一个大表，`join_buffer`放不下怎么办呢？

`join_buffer` 的大小是由`join_buffer_size`设定的，默认值是256k。如果放不下t1的所有数据的话，策略很简单，就是分段放。我把`join_buffer_size`改成1200，再执行：

#### 过程就变成了：

1. 扫描表t1，顺序读取数据行放入`join_buffer`中，放完第88行`join_buffer`满了，继续第二步
2. 扫描表t2，把t2中的每一行取出来，跟`join_buffer`中的数据做对比，满足join条件的，作为结果集的一部分返回；
3. 清空`join_buffer`
4. 继续扫描表t1，顺序读取最后的12行数据放入`join_buffer`中，继续执行第2步

这个流程才体现出了这个算法名字中“Block”的由来，表示“分块去join”

可以看到，这时候由于表t1被分成两次放入`join_buffer`中，导致表t2会被扫描两次，但是判断等值条件的次数还是不变的，（88+12）*1000=10万次。

#### 我们再来看，这种情况下驱动表的选择问题。

假设，驱动表的数据行数是N，需要分K段才能完成算法流程，被驱动表的数据行数是M。

注意，这里的 K 不是常数，N 越大 K 就会越大，因此把 K 表示为λ*N，显然λ的取值范围是 (0,1)。

所以，在这个算法的执行过程中：

- 扫描行数是 `N+λ*N*M`；
- 内存判断 `N*M` 次。

显然，内存判断次数是不受选择哪个表作为驱动表影响的。而考虑到扫描行数，在 M 和 N 大小确定的情况下，N 小一些，整个算式的结果会更小。

当然，你会发现，在 N+λ*N*M 这个式子里，λ才是影响扫描行数的关键因素，这个值越小越好。

刚刚我们说了 N 越大，分段数 K 越大。那么，N 固定的时候，什么参数会影响 K 的大小呢？（也就是λ的大小）答案是 `join_buffer_size`。`join_buffer_size `越大，一次可以放入的行越多，分成的段数也就越少，对被驱动表的全表扫描次数就越少。

这就是为什么，你可能会看到一些建议告诉你，如果你的 join 语句很慢，就把 `join_buffer_size` 改大。


## 3.最后回答开篇

理解了MYSQL执行join的两种算法，我们来回答文章开头的两个问题：

### 第一个问题：能不能用join语句？

1. 如果可以使用Index Nested-Loop Join算法，也就是说可以用上被驱动表的索引，其实是没问题的。
2. 如果使用Block Nested-Loop Join算法，扫描行数就会过多。尤其是在大表上的join操作，这样可能要扫描被驱动表很多次，会占用大量的系统资源。所以这种join尽量不要用

所以你在判断要不要使用 join 语句时，就是看 explain 结果里面，Extra 字段里面有没有出现“Block Nested Loop”字样。

### 第二个问题是：如果要是用join，应该选择大表做驱动表还是用小表做驱动表

1. 如果是Index Nested-Loop Join算法，应该选择小表做驱动表；
2. 如果是Block Nested-Loop Join算法：
    - 在`join_buffer_size`足够大的时候，是一样的；
    - 在`join_buffer_size`不够大的时候（这种情况更常见），应该选择小表做驱动表。

所以这个问题的结论是，**总是应该使用小表做驱动表**

如何定义“小表”

1. 加入了限定条件，相对小的表
2. select的字段少一些的，`join_buffer`需要放入的数据也小一些

所以，更准确的说，**在决定哪个表做驱动表的时候，应该是两个表按照各自的条件过滤，过滤完成之后，计算参与join的各个字段的总数据量，数据量小的那个表，就是“小表”，应该作为驱动表**

