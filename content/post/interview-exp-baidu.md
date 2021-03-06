---
title: "5年经验Java程序员帝都面试20天，拿下数个offer，最终选择了百度"
date: 2019-02-13T07:56:41+08:00
lastmod: 2019-02-13T07:56:41+08:00
draft: false
keywords: []
description: ""
tags: ["面试"]
categories: ["Tech"]
author: "来源于网络"

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

从事Java开发也有5年经验了，7月初来到帝都，开启面试经历，前后20天左右，主面互联网公司，一二线大公司或者是融资中的创业公司都面试过，拿了一些offer，其中包括奇虎360，最后综合决定还是去百度了。


<!--more-->


首先不同面试官面试风格一定不同，我这里就是总结这些天面试Java开发过程中的大多数问题，综合分类有Java基础，框架，多线程，网络通信，数据库以及设计模式，算法等几个模块。

一名3年工作经验的Java程序员应该具备的技能，这可能是Java程序员们比较关心的内容。我这里要说明一下，以下列举的内容不是都要会的东西----但是如果你掌握得越多，最终能得到的评价、拿到的薪水势必也越高。




## 一、Java基础

1、String类为什么是final的。

2、HashMap的源码，实现原理，底层结构。

3、反射中，Class.forName和classloader的区别

  >Java中class.forName()和classLoader都可用来对类进行加载。
  class.forName()前者除了将类的.class文件加载到jvm中之外，还会对类进行解释，执行类中的static块。
  而classLoader只干一件事情，就是将.class文件加载到jvm中，不会执行static中的内容,只有在newInstance才会去执行static块。
  Class.forName(name, initialize, loader)带参函数也可控制是否加载static块。并且只有调用了newInstance()方法采用调用构造函数，创建类的对象。
  参考文章：https://blog.csdn.net/qq_27093465/article/details/52262340


4、session和cookie的区别和联系，session的生命周期，多个服务部署时session管理。

5、Java中的队列都有哪些，有什么区别。

6、Java的内存模型 JMM 以及GC算法

7、Java7、Java8的新特性(baidu问的,好BT)

8、Java数组和链表两种结构的操作效率，在哪些情况下(从开头开始，从结尾开始，从中间开始)，哪些操作(插入，查找，删除)的效率高

9、Java内存泄露的问题调查定位：jmap，jstack的使用等等


## 二、多线程

这也是必问的一块了。因为三年工作经验，所以基本上不会再问你怎么实现多线程了，会问得深入一些比如说Thread和Runnable的区别和联系、多次start一个线程会怎么样、线程有哪些状态。当然这只是最基本的，出乎意料地，几次面试几乎都被同时问到了一个问题，问法不尽相同，总结起来是这么一个意思：

假如有Thread1、Thread2、Thread3、Thread4四条线程分别统计C、D、E、F四个盘的大小，所有线程都统计完毕交给Thread5线程去做汇总，应当如何实现？

聪明的网友们对这个问题是否有答案呢？不难，java.util.concurrent下就有现成的类可以使用。

**另外，线程池也是比较常问的一块，常用的线程池有几种？这几种线程池之间有什么区别和联系？线程池的实现原理是怎么样的？**实际一些的，会给你一些具体的场景，让你回答这种场景该使用什么样的线程池比较合适。

最后，虽然这次面试问得不多，但是多线程同步、锁这块也是重点。

synchronized和ReentrantLock的区别、synchronized锁普通方法和锁静态方法、死锁的原理及排查方法等等，关于多线程，我在之前有些过文章总结过多线程的40个问题，可以参看40个Java多线程问题总结。

## 三、IO

再次补充IO的内容，之前忘了写了。

IO分为File IO和Socket IO，File IO基本上是不会问的，问也问不出什么来，平时会用就好了，另外记得File IO都是阻塞IO。

Socket IO是比较重要的一块，要搞懂的是阻塞/非阻塞的区别、同步/异步的区别，借此理解阻塞IO、非阻塞IO、多路复用IO、异步IO这四种IO模型，Socket IO如何和这四种模型相关联。

这是基本一些的，深入一些的话，就会问NIO的原理、NIO属于哪种IO模型、NIO的三大组成等等，这有些难，当时我也是研究了很久才搞懂NIO。提一句，NIO并不是严格意义上的非阻塞IO而应该属于多路复用IO，面试回答的时候要注意这个细节，讲到NIO会阻塞在Selector的select方法上会增加面试官对你的好感。

如果用过Netty，可能会问一些Netty的东西，毕竟这个框架基本属于当前最好的NIO框架了（Mina其实也不错，不过总体来说还是比不上Netty的），大多数互联网公司也都在用Netty。

## 四、JDK源码

要想拿高工资，JDK源码不可不读。上面的内容可能还和具体场景联系起来，JDK源码就是实打实地看你平时是不是爱钻研了。过程中被问了不少JDK源码的问题，其中最刁钻的一个问了，String的hashCode方法是怎么实现的，幸好平时String源代码看得多，答了个大概。JDK源码其实没什么好总结的，纯粹看个人，总结一下比较重要的源码：

（1）List、Map、Set实现类的源代码

（2）ReentrantLock、AQS的源代码

（3）AtomicInteger的实现原理，主要能说清楚CAS机制并且AtomicInteger是如何利用CAS机制实现的

> CAS是英文单词Compare And Swap的缩写，翻译过来就是比较并替换。CAS机制当中使用了3个基本操作数：内存地址V，旧的预期值A，要修改的新值B。更新一个变量的时候，只有当变量的预期值A和内存地址V当中的实际值相同时，才会将内存地址V对应的值修改为B。

> 缺点 1.CPU开销较大，2.不能保证代码块的原子性，3.ABA问题

（4）线程池的实现原理

（5）Object类中的方法以及每个方法的作用

这些其实要求蛮高的，去年一整年基本把JDK中重要类的源代码研究了个遍，真的花费时间、花费精力，当然回头看，是值得的----不仅仅是为了应付面试。

## 五、框架

1、struts1和struts2的区别

2、struts2和springMVC的区别

3、spring框架中需要引用哪些jar包，以及这些jar包的用途

4、srpingMVC的原理

5、springMVC注解的意思

6、spring中beanFactory和ApplicationContext的联系和区别

7、spring注入的几种方式

8、spring如何实现事物管理的

9、springIOC和AOP的原理

10、hibernate中的1级和2级缓存的使用方式以及区别原理

11、spring中循环注入的方式

## 六、数据库

数据库十有八九也都会问到。一些基本的像union和union all的区别、left join、几种索引及其区别就不谈了，比较重要的就是数据库性能的优化，如果对于数据库的性能优化一窍不通，那么有时间，还是建议你在面试前花一两天专门把SQL基础和SQL优化的内容准备一下。

- 字段类型
- 日志（binlog、redolog）
- 索引
- 事务
- 锁
- 复制

## 七、数据结构和算法分析

数据结构和算法分析，对于一名程序员来说，会比不会好，而且在工作中绝对能派上用场。数组、链表是基础，栈和队列深入一些但也不难，树挺重要的，比较重要的树AVL树、红黑树，可以不了解它们的具体实现，但是要知道什么是二叉查找树、什么是平衡树，AVL树和红黑树的区别。记得某次面试，某个面试官和我聊到了数据库的索引，他问我：

你知道索引使用的是哪种数据结构实现吗？

答到用的Hash表吧，答错。他又问，你知道为什么要使用树吗？答到因为Hash表可能会出现比较多的冲突，在千万甚至是上亿级别的数据面前，会大大增加查找的时间复杂度。而树比较稳定，基本保证最多二三十次就能找到想要的数据，对方说不完全对，最后我们还是交流了一下这个问题，我也明白了为什么要使用树。

## 八、Java虚拟机

出乎意料，Java虚拟机应该是很重要的一块内容，结果在这几家公司中被问到的概率几乎为0。要知道，去年可是花了大量的时间去研究Java虚拟机的，光周志明老师的《深入理解Java虚拟机：JVM高级特性与最佳实践》，就读了不下五遍。

言归正传，虽然Java虚拟机没问到，但我觉得还是有必要研究的，就简单地列一个提纲吧，谈谈Java虚拟机中比较重要的内容：

（1）Java虚拟机的内存布局

（2）GC算法及几种垃圾收集器

（3）类加载机制，也就是双亲委派模型

（4）Java内存模型

（5）happens-before规则

（6）volatile关键字使用规则


也许面试无用，但在走向大牛的路上，不可不会，这个是面试了几家公司最后经过整合写出了这些面试题，面试就决定了你的薪资，一定要好好对待，这些问题可能不会问到，但是程序员技多不压身，最后收到了百度的offer，薪资还不错，把这些面试题分享出来希望能帮助那些打算跳槽的人~~