---
title: "线上系统部署时如何设置JVM内存大小"
subtitle:    ""
date: 2019-12-28T08:51:05+08:00
lastmod: 2019-12-28T08:51:05+08:00
draft: false
keywords: []
description: ""
tags: ["JVM"]
categories: ["Tech"]
author: "瞿广"
image:       ""
---

如果你不合理的设置内存，就会导致新生代内存不充足，然后导致很多对象不停的迁移到老年代去，最后导致老年代也要不停的进行垃圾回收。

最后这频繁的垃圾回收，就会极大的影响系统的性能。

<!--more-->

#### 2、跟JVM内存相关的几个核心参数图解

本文就不涉及到任何原理性的东西了，直接开始逐步给大家讲解JVM的参数如何设置。

在JVM内存分配中，有几个参数是比较核心的，如下所示。



-Xms：Java堆内存的大小

-Xmx：Java堆内存的最大大小

-Xmn：Java堆内存中的新生代大小，扣除新生代剩下的就是老年代的内存大小了

-XX:PermSize：永久代大小

-XX:MaxPermSize：永久代最大大小

> JDK 1.8以后的版本，那么这俩参数被替换为了-XX:MetaspaceSize和-XX:MaxMetaspaceSize。


-Xss：每个线程的栈内存大小


初始大小和最大值，通常来说，都会设置为完全一样的大小。

### 二、每日百万交易的支付系统，如何设置JVM堆内存大小


当然，其实一个完整的支付系统还包含很多东西。

比如还要负责对账以及跟合作商户之间的资金清算，支付系统得包含应用管理、账户管理、渠道管理、支付交易、对账管理、清算管理、结算管理，等各种功能模块，但是我们这里就关注最核心的支付流程即可。

如果每日百万交易，那么大家可以想象一下，在我们的JVM的角度来看，就是每天会在JVM中创建上百万个支付订单对象

所以我们的支付系统，其实他的压力有很多方面，包括高并发访问、高性能处理请求、大量的支付订单数据需要存储，等等技术难点。

但是抛开这些系统架构层面的东西，单单是在JVM层面，我们的支付系统最大的压力，就是每天JVM内存里会频繁的创建和销毁100万个支付订单，所以这里就牵扯到一个核心的问题。

- 我们的支付系统需要部署多少台机器？

- 每台机器需要多大的内存空间？

- 每台机器上启动的JVM需要分配多大的堆内存空间？

- 给JVM多大的内存空间才能保证可以支撑这么多的支付订单在内存里的创建，而不会导致内存不够直接崩溃？

这就是我们本文要考虑的核心问题。


#### 5、支付系统每秒钟需要处理多少笔支付订单


要解决线上系统最核心的一个参数，也就是JVM堆内存大小的合理设置，我们首先第一个要计算的，就是 **每秒钟我们的系统要处理多少笔支付订单**。

假设每天100万个支付订单，那么一般用户交易行为都会发生在每天的高峰期，比如中午或者晚上。

假设每天高峰期大概是几个小时，用100万平均分配到几个小时里，那么大概是每秒100笔订单左右，咱们就以每秒100笔订单来计算一下好了。

假设我们的支付系统部署了3台机器，每台机器实际上每秒大概处理30笔订单。


#### 6、每个支付订单处理要耗时多久？

下一个问题，咱们必须要搞明白的一个事儿，就是每个支付订单大概要处理多长时间？

如果用户发起一次支付请求，那么支付需要在JVM中创建一个支付订单对象，填充进去数据，然后把这个支付订单写入数据库，还可能会处理一些其他的事情

咱们就假设一次支付请求的处理，包含一个支付订单的创建，大概需要1秒钟的时间。

那么大体上你的脑子里可以出现的一个流动的模型，应该是每台机器一秒钟接收到30笔支付订单的请求，然后在JVM的新生代里创建了30个支付订单的对象，做了写入数据库等处理

接着1秒之后，这30个支付订单就处理完毕，然后对这些支付订单对象的引用就回收了，这些订单在JVM的新生代里就是没人引用的垃圾对象了。

接着再是下一秒来30个支付订单，重复这个步骤。

#### 7、每个支付订单大概需要多大的内存空间？


```java
public class PlayOrder {
    private Integer userId;
    private Long orderTime;
    private Integer orderId;
}
```

接着我们来计算一下，每个支付订单对象大概需要多大的内存空间？

之前的文章里有一个思考题， 已经教过大家这个怎么计算了，其实不考虑别的，你就直接根据支付订单类中的实例变量的类型来计算就可以了。

比如说支付订单类如下所示，你只要记住一个Integer类型的变量数据是4个字节，Long类型的变量数据是8个字节，还有别的类型的变量数据占据多少字节

百度一下都可以查到，然后就可以计算出每个支付订单对象大致占据多少字节。

一般来说，比如支付订单这种核心类，你就按20个实例变量来计算，然后一般大概一个对象也就在几百字节的样子

我们算他大一点好了，就算一个支付订单对象占据500字节的内存空间，不到1kb。

那么30个支付订单，大概占据的内存空间是30 * 500字节 = 15000字节，大概其实也就15kb而已。其实是非常非常小的。

#### 9、让支付系统运行起来分析一下

直到有一刻，发现可能新生代里都有几十万个对象了，此时占据了几百MB的空间了，可能新生代空间就快满了。

然后就会触发Minor GC，就把新生代里的垃圾对象都给回收掉了，腾出内存空间，然后继续来在内存里分配新的对象。

这就是这个业务系统的运行模型。

#### 10、对完整的支付系统内存占用需要进行预估

其实如果你要估算的话，可以把之前的计算结果扩大10倍~20倍。也就是说，**每秒钟除了在内存里创建支付订单对象，还会创建其他数十种对象**。

#### 11、支付系统的JVM堆内存应该怎么设置？


常见的机器配置是**2核4G，或者是4核8G**。

如果我们用2核4G的机器来部署，那么还是有点紧凑的，因为机器有4G内存，但是 **机器本身也要用一些内存空间，最后你的JVM进程最多就是2G内存**

然后这2G还得分配**方法区、栈内存、堆内存几块区域**，那么堆内存可能最多就是个1G多的内存空间。

然后堆内存还分为**新生代和老年代**，你的老年代总需要放置系统的一些长期存活的对象吧，怎么也得给几百MB的内存空间，那么新生代可能也就几百MB的内存了。

这样的话，大家可以看到，我们上述的核心业务流程，只不过仅仅是针对一个支付订单对象来分析的，但是实际上如果扩大10倍~20倍换成对完整系统的预估之后，我们看到，大致每秒会占据1MB左右的内存空间。

那么如果你新生代就几百MB的内存空间，是不是会导致运行几百秒之后，新生代内存空间就满了？此时是不是就得触发Minor GC了？

其实如果这么频繁的触发Minor GC，会影响线上系统的性能稳定性，具体原因后续再说。

这里大家首先要明白的一点，就是频繁触发GC一定不是什么好事儿。

因此你可以考虑采用4核8G的机器来部署支付系统，那么你的JVM进程至少可以给4G以上内存，新生代在里面至少可以分配到2G内存空间

这样子就可以做到可能新生代每秒多1MB左右的内存，但是需要将近半小时到1小时才会让新生代触发Minor GC，这就大大降低了GC的频率。

> 举个例子：机器采用4核8G，然后-Xms和-Xmx设置为3G，给整个堆内存3G内存空间;-Xmn设置为2G，给新生代2G内存空间。

而且假设你的业务量如果更大，你可以考虑不只部署3台机器，可以横向扩展部署5台机器，或者10台机器，这样每台机器处理的请求更少，对JVM的压力更小。

### 三、每日百万交易的支付系统，JVM栈内存与永久代大小又该如何设置？


#### 7、如何合理设置永久代大小？

话说回来，如何合理设置永久代大小呢？

其实一般永久代刚开始上线一个系统，没太多可以参考的规范，但是一般你设置个几百MB，大体上都是够用的

因为里面主要就是存放一些类的信息，后面也会用专门的案例给大家分析，什么样的系统容易出现永久代内存溢出。



#### 8、如何合理设置栈内存大小

其实这个栈内存大小设置，一般也不会特别的去预估和设置的，一般默认就是比如512KB到1MB，就差不多够了。

这就是每个线程自己的栈内存空间，用来存放线程执行方法期间的各种布局变量的。后面也会用专门的案例演示，栈内存什么时候会发生内存溢出。