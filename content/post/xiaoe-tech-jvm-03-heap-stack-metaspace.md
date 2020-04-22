---
title: "JVM的分代模型与垃圾回收机制"
subtitle:    "《从 0 开始带你成为JVM实战高手》-学习笔记-03"
date: 2019-12-25T14:12:44+08:00
lastmod: 2019-12-25T14:12:44+08:00
draft: false
keywords: []
description: ""
tags: ['JVM']
categories: ["Tech"]
author: "瞿广"
image:       ""
---

上一篇文章给大家分析了JVM中的几块内存区域分别都是干什么的，今天的文章就给大家初步介绍一下垃圾回收的概念。

<!--more-->
### 一、JVM分代模型：年轻代、老年代、永久代


```java
public class Kafka {
    public static void main (String[] args) {
        loadReplicasFromDisk();
    }
    private static void loadReplicasFromDisk)() {
        ReplicaManager replicaManager = new ReplicaManager();
        replicaManager.load();
    }
}
```


#### 2、大部分对象都是存活周期极短的,少数对象是长期存活的
#### 4、JVM分代模型：年轻代和老年代

相信看完这篇文章，大家就一定看明白了，什么样的对象是短期存活的对象，什么样的对象是长期存在的对象，然后如何分别存在于年轻代和老年代里。

那么为什么需要这么区分呢？

因为这跟垃圾回收有关，对于年轻代里的对象，他们的特点是创建之后很快就会被回收，所以需要用一种垃圾回收算法

对于老年代里的对象，他们的特点是需要长期存在，所以需要另外一种垃圾回收算法，所以需要分成两个区域来放不同的对象。


### 二、你的对象在JVM内存中如何分配？如何流转的？

#### 2、大部分正常对象都优先在新生代分配内存

如果新生代我们预先分配的内存空间，几乎都被全部对象给占满了！此时假设我们代码继续运行，他需要在新生代里去分配一个对象，怎么办？发现新生代里内存空间都不够了！

这个时候，就会触发一次新生代内存空间的垃圾回收，新生代内存空间的垃圾回收，也称之为“**Minor GC**”，有的时候我们也叫“**Young GC**”，他会尝试把新生代里那些没有人引用的垃圾对象，都给回收掉。

#### 4、长期存活的对象会躲过多次垃圾回收

那么此时JVM就有一条规定了

如果一个实例对象在新生代中，成功的在15次垃圾回收之后，还是没被回收掉，就说明他已经15岁了。

这是对象的年龄，每垃圾回收一次，如果一个对象没被回收掉，他的年龄就会增加1。

所以如果上图中的那个“ReplicaFetcher”对象在新生代中成功躲过10多次垃圾回收，成为一个“老年人”，那么就会被认为是会长期存活在内存里的对象。

然后他会被转移到Java堆内存的老年代中去，顾名思义，老年代就是放这些年龄很大的对象。

#### 总结

先理解对象优先分配在新生代

新生代如果对象满了，会触发Minor GC回收掉没有人引用的垃圾对象

如果有对象躲过了十多次垃圾回收，就会放入老年代里

如果老年代也满了，那么也会触发垃圾回收，把老年代里没人引用的垃圾对象清理掉


### 二、JVM的垃圾回收机制


#### 2、被哪些变量引用的对象是不能回收的？

JVM中使用了一种可达性分析算法来判定哪些对象是可以被回收的，哪些对象是不可以被回收的。

这个算法的意思，就是说对每个对象，都分析一下有谁在引用他，然后一层一层往上去判断，看是否有一个GC Roots。

一句话总结：**只要你的对象被方法的局部变量、类的静态变量给引用了，就不会回收他们。**


#### 3、Java中对象不同的引用类型

分别是强引用、软引用、弱引用和虚引用

1.强引用(StrongReference)


```java
public class Kafka {
    public static ReplicaManager replicaManager = new ReplicaManager();
}
```

这个就是最普通的代码，一个变量引用一个对象，只要是强引用的类型，那么垃圾回收的时候绝对不会去回收这个对象的。

当内存空间不足时，Java虚拟机宁愿抛出OutOfMemoryError错误，使程序异常终止，也不会靠随意回收具有强引用的对象来解决内存不足的问题

2.软引用(SoftReference)

```java
public class kafka {
    public static SoftReference<ReplicaManager> replicaManager = 
                    new SoftReference<ReplcaManager>(new ReplicaManager());

}
```

就是把“ReplicaManager”实例对象用一个“SoftReference”软引用类型的对象给包裹起来了，此时这个“replicaManager”变量对“ReplicaManager”对象的引用就是软引用了。

正常情况下垃圾回收是不会回收软引用对象的，但是如果你进行垃圾回收之后，发现内存空间还是不够存放新的对象，内存都快溢出了

此时就会把这些软引用对象给回收掉，哪怕他被变量引用了，但是因为他是软引用，所以还是要回收。


也就是说，垃圾收集线程会在虚拟机抛出OutOfMemoryError之前回收软引用对象，而且虚拟机会尽可能优先回收长时间闲置不用的软引用对象。对那些刚构建的或刚使用过的**"较新的"软对象会被虚拟机尽可能保留**，这就是引入引用队列ReferenceQueue的原因。


3.弱引用(WeakReference)

```java
public class kafka {
    public static WeakReference<ReplicaManager> replicaManager = 
                    new WeakReference<ReplcaManager>(new ReplicaManager());

}
```

你这个弱引用就跟没引用是类似的，如果发生垃圾回收，就会把这个对象回收掉。

虚引用，这个大家其实暂时忽略他也行，因为很少用。


#### 4、finalize()方法的作用


假设有一个ReplicaManager对象要被垃圾回收了，那么假如这个对象重写了Object类中的finialize()方法



此时会先尝试调用一下他的finalize()方法，看是否把自己这个实例对象给了某个GC Roots变量，比如说代码中就给了ReplicaManager类的静态变量。



如果重新让某个GC Roots变量引用了自己，那么就不用被垃圾回收了。



不过说实话，这个东西没必要过多解读，因为其实平时很少用，就是给大家梳理出来这些细节，让大家清楚而已。