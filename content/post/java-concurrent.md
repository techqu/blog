---
title: "《Java并发编程实战》-内容简介"
date: 2019-03-27T17:31:24+08:00
lastmod: 2019-03-27T17:31:24+08:00
draft: false
keywords: []
description: ""
tags: []
categories: []
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

这些年，我们的CPU、内存、I/O设备都在不断迭代，不断朝着更快的方向努力。但是在这个快速发展的过程中，又一个**核心矛盾一直存在，就是这三者的速度差异**。
<!--more-->

## 01| 可见性、原子性和有序性问题：并发编程Bug的源头

为了合理利用CPU的高性能，平衡这三者的速度差异，计算机体系机构、操作系统、编译程序都做出了贡献，主要体现为：

1. CPU增加了缓存，以均衡与内存的速度差异；
2. 操作系统增加了进程、线程、以分时复用CPU，进而均衡CPU与I/O设备的速度差异；
3. 编译程序优化指令执行次序，使得缓存能够得到更加合理地利用。


### 源头之一：缓存导致的可见性问题

共享内存和工作内存

一个线程对共享变量的修改，另外一个线程能够立刻看到，我们称为**可见性。**

### 源头之二：线程切换带来的原子性问题

一个 count+=1 操作，至少需要三条CPU指令。

我们把一个或者多个操作在CPU执行的过程中不被中断的特性称为**原子性**。CPU能保证的原子操作是CPU指令级别的，而不是高级语言的操作符。因此，很多时候我们需要在高级语言层面来保证操作的原子性。

### 源头之一：编译优化带来的有序性问题

有序性指的是程序按照代码的先后顺序执行。编译器为了优化性能，有时会改变程序中语句的先后顺序。

#### 双重检查锁定

**当 instance 为 null 时，两个线程可以并发地进入 if 语句内部。**然后，一个线程进入 synchronized 块来初始化 singleton ，而另一个线程则被阻断。当第一个线程退出 synchronized 块时，等待着的线程进入并创建另一个 Singleton 对象。注意：当第二个线程进入 synchronized 块时，它并没有检查 instance 是否非 null。 

为处理上面的问题，我们需要对 singleton 进行第二次检查。这就是“双重检查锁定”名称的由来

```java
//懒汉式单例
public class Singleton {
  static Singleton instance;
  static Singleton getInstance(){
    if (instance == null) {
      synchronized(Singleton.class) {
        if (instance == null)
          instance = new Singleton();
        }
    }
    return instance;
  }
}
```

最后，需要加 volatile 关键字 防止指令重排序。

## 02|java 内存模型：看Java如何解决可见性和有序性

### 什么是Java内存模型

导致可见性的原因是缓存，导致有序性的原因是编译优化，那解决可见性、有序性最直接的办法就是**按需禁用缓存以及编译优化**

Java内存模型规范了JVM如何提供按需禁用缓存和编译优化的办法。具体来说，这些方法包括 **volatile、synchronized 和 final**三个关键字，以及六项 **Happens-Before规则。**

### 使用volatile的困惑

### Happens-Before 规则

真正要表达的是：**前面一个操作的结果对后续操作是可见的**

比较正式的说法是：Happens-Before 约束了编译器的优化行为，虽允许编译器优化，但是要求编译器优化后一定遵守 Happens-Before 规则。

1. 程序的顺序性规则
2. volatile 变量规则
3. 传递性
4. 管程中锁的规则
5. 线程 start（）规则
6. 线程 join（）规则
### 被忽视的final