---
title: "理解GC日志"
date: 2018-12-24T19:03:40+08:00
draft: false
author: "瞿广"
originallink: ""
summary: "这里填写文章文章摘要。"
tags: ["java","JVM"]
categories: ["Tech"]
---

 理解GC日志，基于jdk1.7,一步步看懂GC日志
<!--more-->
## GC日志查看
可以通过在java命令种加入参数来指定对应的gc类型，打印gc日志信息并输出至文件等策略。


GC的日志是以替换的方式(>)写入的，而不是追加(>>)，如果下次写入到同一个文件中的话，以前的GC内容会被清空。

 

对应的参数列表

```
-XX:+PrintGC 输出GC日志  
-XX:+PrintGCDetails 输出GC的详细日志  
-XX:+PrintGCTimeStamps 输出GC的时间戳（以基准时间的形式）  
-XX:+PrintGCDateStamps 输出GC的时间戳（以日期的形式，如 2013-05-04T21:53:59.234+0800）  
-XX:+PrintHeapAtGC 在进行GC的前后打印出堆的信息  
-Xloggc:../logs/gc.log 日志文件的输出路径  
``` 


这里使用如下的参数来进行日志的打印：

```
-XX:+PrintGCDateStamps -XX:+PrintGCDetails -Xloggc:./gclogs  
```

对于新生代回收的一行日志，其基本内容如下：

```
2014-07-18T16:02:17.606+0800: 611.633: [GC 611.633: [DefNew: 843458K->2K(948864K), 0.0059180 secs] 2186589K->1343132K(3057292K), 0.0059490 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]  
``` 

 

其含义大概如下：


2014-07-18T16:02:17.606+0800（当前时间戳）: 611.633（时间戳）: [GC（表示Young GC） 611.633: [DefNew（单线程Serial年轻代GC）: 843458K（年轻代垃圾回收前的大小）->2K（年轻代回收后的大小）(948864K（年轻代总大小）), 0.0059180 secs（本次回收的时间）] 2186589K（整个堆回收前的大小）->1343132K（整个堆回收后的大小）(3057292K（堆总大小）), 0.0059490 secs（回收时间）] [Times: user=0.00（用户耗时） sys=0.00（系统耗时）, real=0.00 secs（实际耗时）]  


 

老年代回收的日志如下：

Java代码  收藏代码
2014-07-18T16:19:16.794+0800: 1630.821: [GC 1630.821: [DefNew: 1005567K->111679K(1005568K), 0.9152360 secs]1631.736: [Tenured:  
2573912K->1340650K(2574068K), 1.8511050 secs] 3122548K->1340650K(3579636K), [Perm : 17882K->17882K(21248K)], 2.7854350 secs] [Times: user=2.57 sys=0.22, real=2.79 secs]  
 

 

gc日志中的最后貌似是系统运行完成前的快照：

```
Heap  
 def new generation   total 1005568K, used 111158K [0x00000006fae00000, 0x000000073f110000, 0x0000000750350000)  
  eden space 893888K,  12% used [0x00000006fae00000, 0x0000000701710e90, 0x00000007316f0000)  
  from space 111680K,   3% used [0x0000000738400000, 0x000000073877c9b0, 0x000000073f110000)  
  to   space 111680K,   0% used [0x00000007316f0000, 0x00000007316f0000, 0x0000000738400000)  
 tenured generation   total 2234420K, used 1347671K [0x0000000750350000, 0x00000007d895d000, 0x00000007fae00000)  
   the space 2234420K,  60% used [0x0000000750350000, 0x00000007a2765cb8, 0x00000007a2765e00, 0x00000007d895d000)  
 compacting perm gen  total 21248K, used 17994K [0x00000007fae00000, 0x00000007fc2c0000, 0x0000000800000000)  
   the space 21248K,  84% used [0x00000007fae00000, 0x00000007fbf92a50, 0x00000007fbf92c00, 0x00000007fc2c0000)  
No shared spaces configured.  
 
```
 

GC日志的离线分析

可以使用一些离线的工具来对GC日志进行分析，比如sun的gchisto(https://java.net/projects/gchisto)，gcviewer（https://github.com/chewiebug/GCViewer ），这些都是开源的工具，用户可以直接通过版本控制工具下载其源码，进行离线分析

## GC 堆
1、GC 分为两种：Minor GC、Full GC ( 或称为 Major GC )。

2、Minor GC 是发生在新生代中的垃圾收集动作，所采用的是复制算法。

    a、新生代几乎是所有 Java 对象出生的地方，即 Java 对象申请的内存以及存放都是在这个地方。
    b、Java 中的大部分对象通常不需长久存活，具有朝生夕灭的性质。
    c、当一个对象被判定为 “死亡” 的时候，GC 就有责任来回收掉这部分对象的内存空间。
    d、新生代是 GC 收集垃圾的频繁区域。
    e、当对象在 Eden（+from） 出生后，在经过一次 Minor GC 后，如果对象还存活，并且能够被另外一块 Survivor 区域        
        所容纳( 这里应为 to 区域 )，则使用复制算法将这些仍然还存活的对象复制到另外一块 Survivor 区域 ( 即 to 区域 ) 中，
    f、 然后清理所使用过的 Eden 以及 Survivor 区域 ( 即 from 区域 )，并且将这些对象的年龄设置为1，
    g、以后对象在 Survivor 区每熬过一次 Minor GC，就将对象的年龄 + 1，
    h、当对象的年龄达到某个值时 ( 默认是 15 岁，可以通过参数 -XX:MaxTenuringThreshold 来设定 )，这些对象就会成为    
            老年代。
    j、但这也不是一定的，对于一些较大的对象 ( 即需要分配一块较大的连续内存空间 ) 则是直接进入到老年代。

3、Full GC 是发生在老年代的垃圾收集动作，所采用的是标记-清除算法。

1. 老年代里面的对象几乎个个都是在 Survivor 区域中熬过来的，它们是不会那么容易就 “死掉” 了的。
1. Full GC 发生的次数不会有 Minor GC 那么频繁，并且做一次 Full GC 要比进行一次 Minor GC 的时间更长。
1. 标记-清除算法收集垃圾的时候会产生许多的内存碎片 ( 即不连续的内存空间 )，
1. 此后需要为较大的对象分配内存空间时，若无法找到足够的连续的内存空间，就会提前触发一次 GC 的收集动作。


## GC 日志1
![gc-log](/img/gc-log1.png)

1、“33.125：”和“100.667：”代表了GC发生的时间，这个数字的含义是从Java虚拟机启动以来经过的秒数。

2、“[GC”和“[Full GC”说明了这次垃圾收集的停顿类型，而不是用来区分新生代GC还是老年代GC的。
    “Full”，说明这次GC是发生了Stop-The-World的，例如下面这段新生代收集器ParNew的日志也会出
现“[Full GC”（这一般是因为出现了分配担保失败之类的问题，所以才导致STW）。如果是调用System.gc（）方
法所触发的收集，那么在这里将显示“[Full GC（System）”。[Full GC 283.736：[ParNew：261599K-＞261599K（261952K），0.0000288 secs]

3、DefNew”、“Tenured”、“Perm”表示GC发生的区域，这里显示的区域名称与使用的GC收集器
是密切相关的，

-  “DefNew”：Serial收集器中的新生代名为“Default New Generation”
-  “ParNew”：ParNew收集器，新生代，意为“Parallel New Generation”。
-  “PSYoungGen”： Parallel Scavenge收集器
-  老年代和永久代同理，名称也是由收集器决定的。Tenured表示老年代

4、“3324K-＞152K（3712K）”是“GC前该内存区域已使用容量-＞GC后该内存区域已使用容量（该内存区域总容量）”。

5、方括号之外“3324K-＞152K（11904K）”表示“GC前Java堆已使用容量-＞GC后Java堆已使用容量（Java堆总容量）”。

6、“0.0025925 secs”表示该内存区域GC所占用的时间，单位是秒。

7、“[Times：user=0.01 sys=0.00，real=0.02 secs]”

- user：用户态消耗的CPU时间
- sys：内核态消耗的CPU时间
- real：操作从开始到结束所经过的墙钟时间（Wall Clock Time）
CPU时间与墙钟时间的区别是，墙钟时间包括各种非运算的等待耗时，例如等待磁盘I/O、等待线程阻塞，而CPU时间不包括这些耗时，但当系统有多CPU或者多核的话，多线程操作会叠加这些CPU时间，所以读者看到user或sys时间超过real时间是完全正常的。

## GC 日志2

```java
public static void main(String[] args) {   
     Object obj = new Object();   
     System.gc();  
     System.out.println(); 
     obj = new Object();   
     obj = new Object();   
     System.gc();  
     System.out.println();
}
```

> 设置 JVM 参数为 -XX:+PrintGCDetails，使得控制台能够显示 GC 相关的日志信息，执行上面代码，下面是其中一次执行的结果。

![gc-log](/img/gc-log2-1.png)
![gc-log](/img/gc-log2-2.png)


## GC 日志3
```java
/** 
  -Xms60m 
  -Xmx60m 
  -Xmn20m 
  -XX:NewRatio=2 ( 若 Xms = Xmx, 并且设定了 Xmn, 那么该项配置就不需要配置了 ) 
  -XX:SurvivorRatio=8 
  -XX:PermSize=30m  (PermSize=30m; support was removed in 8.0)
  -XX:MaxPermSize=30m (MaxPermSize=30m; support was removed in 8.0)
  -XX:+PrintGCDetails
  */
public static void main(String[] args) {
     newTest().doTest();
}

public void doTest(){
     Integer M = new Integer(1024* 1024* 1);  //单位, 兆(M)
     byte[] bytes = new byte[1* M]; //申请 1M 大小的内存空间
     bytes = null;  //断开引用链
     System.gc();   //通知 GC 收集垃圾
     System.out.println();
     bytes = new byte[1* M];  //重新申请 1M 大小的内存空间
     bytes = new byte[1* M];  //再次申请 1M 大小的内存空间
     System.gc();
     System.out.println();
}
```


按上面代码中注释的信息设定 jvm 相关的参数项，并执行程序，下面是一次执行完成控制台打印的结果：

    [ GC [ PSYoungGen:  1351K -> 288K (18432K) ]  1351K -> 288K (59392K), 0.0012389 secs ]  [ Times: user=0.00 sys=0.00, real=0.00 secs ]
    [ Full GC (System)  [ PSYoungGen:  288K -> 0K (18432K) ]  [ PSOldGen:  0K -> 160K (40960K) ]  288K -> 160K (59392K)  [ PSPermGen:  2942K -> 2942K (30720K) ],  0.0057649 secs ] [ Times:  user=0.00  sys=0.00,  real=0.01 secs ] 
    [ GC [ PSYoungGen:  2703K -> 1056K (18432K) ]  2863K -> 1216K(59392K),  0.0008206 secs ]  [ Times: user=0.00 sys=0.00, real=0.00 secs ]
    [ Full GC (System)  [ PSYoungGen:  1056K -> 0K (18432K) ]  [ PSOldGen:  160K -> 1184K (40960K) ]  1216K -> 1184K (59392K)  [ PSPermGen:  2951K -> 2951K (30720K) ], 0.0052445 secs ]  [ Times: user=0.02 sys=0.00, real=0.01 secs ] 
    Heap PSYoungGen     
     total 18432K, used 327K [0x00000000fec00000, 0x0000000100000000, 0x0000000100000000)  
     eden space 16384K, 2% used [0x00000000fec00000,0x00000000fec51f58,0x00000000ffc00000)  
     from space 2048K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x0000000100000000)  
     to   space 2048K, 0% used [0x00000000ffc00000,0x00000000ffc00000,0x00000000ffe00000) 
     PSOldGen        total 40960K, used 1184K [0x00000000fc400000, 0x00000000fec00000, 0x00000000fec00000)  
       object space 40960K, 2% used [0x00000000fc400000,0x00000000fc5281f8,0x00000000fec00000) 
     PSPermGen       total 30720K, used 2959K [0x00000000fa600000, 0x00000000fc400000, 0x00000000fc400000)  
       object space 30720K, 9% used [0x00000000fa600000,0x00000000fa8e3ce0,0x00000000fc400000)



1. 堆中新生代的内存空间为 18432K ( 约 18M )，eden 的内存空间为 16384K ( 约 16M)，from / to survivor 的内存空间为 2048K ( 约 2M)。

1. 新生代 = eden + from + to = 16 + 2 + 2 = 20M，可见新生代的内存空间确实是按 Xmn 参数分配得到的。

1.  SurvivorRatio = 8，因此，eden = 8/10 的新生代空间 = 8/10 * 20 = 16M。from = to = 1/10 的新生代空间 = 1/10 * 20 = 2M。

1. 堆信息中新生代的 total 18432K 是这样来的： eden + 1 个 survivor = 16384K + 2048K = 18432K，即约为 18M。因为 jvm 每次只是用新生代中的 eden 和 一个 survivor，因此新生代实际的可用内存空间大小为所指定的 90%。因此可以知道，这里新生代的内存空间指的是新生代可用的总的内存空间，而不是指整个新生代的空间大小。

1. 另外，可以看出老年代的内存空间为 40960K ( 约 40M )，堆大小 = 新生代 + 老年代。因此在这里，老年代 = 堆大小 – 新生代 = 60 – 20 = 40M。

1. 最后，这里还指定了 PermSize = 30m，PermGen 即永久代 ( 方法区 )，它还有一个名字，叫非堆，主要用来存储由 jvm 加载的类文件信息、常量、静态变量等。

1. 回到 doTest() 方法中，可以看到代码在第 17、21、22 这三行中分别申请了一块 1M 大小的内存空间，并在 19 和 23 这两行中分别显式的调用了 System.gc()。从控制台打印的信息来看，每次调 System.gc()，是先进行 Minor GC，然后再进行 Full GC。

1. 第 19 行触发的 Minor GC 收集分析：
从信息 PSYoungGen :  1351K -> 288K，可以知道，在第 17 行为 bytes 分配的内存空间已经被回收完成。
引起 GC 回收这 1M 内存空间的因素是第 18 行的 bytes = null;   bytes 为 null 表明之前申请的那 1M 大小的内存空间现在已经没有任何引用变量在使用它了，
并且在内存中它处于一种不可到达状态 ( 即没有任何引用链与 GC Roots 相连 )。那么，当 Minor GC 发生的时候，GC 就会来回收掉这部分的内存空间。

1. 第 19 行触发的 Full GC 收集分析：
在 Minor GC 的时候，信息显示 PSYoungGen :  1351K -> 288K，再看看 Full GC 中显示的 PSYoungGen :  288K -> 0K，可以看出，Full GC 后，新生代的内存使用变成0K 了 
刚刚说到 Full GC 后，新生代的内存使用从 288K 变成 0K 了，那么这 288K 到底哪去了 ? 难道都被 GC 当成垃圾回收掉了 ? 当然不是了。我还特意在 main 方法中 new 了一个 Test 类的实例，这里的 Test 类的实例属于小对象，它应该被分配到新生代内存当中，现在还在调用这个实例的 doTest 方法呢，GC 不可能在这个时候来回收它的。
接着往下看 Full GC 的信息，会发现一个很有趣的现象，PSOldGen:  0K  -> 160K，可以看到，Full GC 后，老年代的内存使用从 0K 变成了 160K，想必你已经猜到大概是怎么回事了。**当 Full GC 进行的时候，默认的方式是尽量清空新生代 ( YoungGen )，因此在调 System.gc() 时，新生代 ( YoungGen ) 中存活的对象会提前进入老年代。**

1. 第 23 行触发的 Minor GC 收集分析：
从信息 PSYoungGen :  2703K -> 1056K，可以知道，在第 21 行创建的，大小为 1M 的数组被 GC 回收了。在第 22 行创建的，大小也为 1M 的数组由于 bytes 引用变量还在引用它，因此，它暂时未被 GC 回收。

1. 第 23 行触发的 Full GC 收集分析：
在 Minor GC 的时候，信息显示 PSYoungGen :  2703K -> 1056K，Full GC 中显示的 PSYoungGen :  1056K -> 0K，以及 PSOldGen:  160K -> 1184K，可以知道，新生代 ( YoungGen ) 中存活的对象又提前进入老年代了。