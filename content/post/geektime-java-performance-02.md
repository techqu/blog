---
title: "《Java性能调优实战》模块二 · Java编程性能调优 (10讲)"
date: 2019-08-05T20:34:10+08:00
lastmod: 2019-08-04T20:34:10+08:00
draft: false
keywords: []
description: ""
tags: ["Java性能调优实战"]
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





从第二个模块开始，学习Java编程的性能优化。

<!--more-->


## 03-字符串性能优化不容小觑，百M内存轻松存储几十G数据

String对象作为Java语 言中重要的数据类型，是内存中占据空间最大的一个对象。高效地使用字符串，可以提升系统的整体性能。


String对象的不可变性，正是这个特性实现了字符串常量池，通过减少同一个值的字符串 对象的重复创建，进一步节约内存。
但也是因为这个特性，我们在做长字符串拼接时，需要显示使用StringBuilder，以提高字符串的拼接性能。 最后，在优化方面，我们还可以使用intern方法，让变量字符串对象重复使用常量池中相同值的对象，进而 节约内存。

## 04-慎重使用正则表达式
String对象优化时，提到了Split()方法，该方法使用的正则表达式可能引起回溯问题
## 05-ArrayList还是LinkedList？使用不当性能差千倍
## 06-Stream如何提高遍历集合效率？
## 07-深入浅出HashMap的设计与优化
## 08-网络通信优化之IO模型：如何解决高并发下IO瓶颈？
## 09-网络通信优化之序列化：避免使用Java序列化
## 10-网络通信优化之通信协议：如何优化RPC网络通信？
## 11-答疑课堂：深入了解NIO的优化实现原理
## 12-多线程之锁优化（上）：深入了解Synchronized同步锁的优化方法
## 13-多线程之锁优化（中）：深入了解Lock同步锁的优化方法