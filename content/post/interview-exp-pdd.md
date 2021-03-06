---
title: "最新拼多多技术部面试题：幻读+分段锁+死锁+Spring Cloud+秒杀"
date: 2019-02-13T08:30:08+08:00
lastmod: 2019-02-13T08:30:08+08:00
draft: false
keywords: []
description: ""
tags: ["面试", "面经"]
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

<!--more-->

## 一面

1. 简短自我介绍
1. 事务的ACID，其中把事务的隔离性详细解释一遍
1. 脏读、幻影读、不可重复读
1. 红黑树、二叉树的算法
1. 平常用到哪些集合类？ArrayList和LinkedList区别？HashMap内部数据结构？ConcurrentHashMap分段锁？
1. jdk1.8中，对hashMap和concurrentHashMap做了哪些优化
1. 如何解决hash冲突的，以及如果冲突了，怎么在hash表中找到目标值
1. synchronized 和 ReentranLock的区别？
1. ThreadLocal？应用场景？
1. Java GC机制？GC Roots有哪些？
1. MySQL行锁是否会有死锁的情况？

## 二面

1. 乐观锁和悲观锁了解吗？JDK中涉及到乐观锁和悲观锁的内容？
1. Nginx负载均衡策略？
1. Nginx和其他负载均衡框架对比过吗？
1. Redis是单线程？
1. Redis高并发快的原因？
1. 如何利用Redis处理热点数据
1. 谈谈Redis哨兵、复制、集群
1. 工作中技术优化过哪些？JVM、MySQL、代码等都谈谈

## 三面

1. Spring Cloud用到什么东西？如何实现负载均衡？服务挂了注册中心怎么判断？
1. 网络编程nio和netty相关，netty的线程模型，零拷贝实现
1. 分布式锁的实现你知道的有哪些？具体详细谈一种实现方式
1. 高并发的应用场景，技术需要涉及到哪些？怎样来架构设计？
1. 接着高并发的问题，谈到了秒杀等的技术应用：kafka、redis、mycat等
1. 最后谈谈你参与过的项目，技术含量比较高的，相关的架构设计以及你负责哪些核心编码