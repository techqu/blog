---
title: "《深入拆解Java虚拟机》-课程目录"
date: 2019-08-04T15:32:03+08:00
lastmod: 2019-08-04T15:32:03+08:00
draft: false
keywords: []
description: ""
tags: []
categories: ["Tech","geektime"]
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

整个专栏将分为四大模块:基本原理、高效实现、代码优化、虚拟机黑科技

<!--more-->


1. 基本原理：剖析 Java 虚拟机的运行机制，逐一介绍 Java 虚拟机的设计决策以及工程实现；
2. 高效实现：探索 Java 编译器，以及内嵌于 Java 虚拟机中的即时编译器，帮助你更好地理解 Java 语言特性，继而写出简洁高效的代码；
3. 代码优化：介绍如何利用工具定位并解决代码中的问题，以及在已有工具不适用的情况下，如何打造专属轮子；
4. 虚拟机黑科技：介绍甲骨文实验室近年来的前沿工作之一 GraalVM。包括如何在 JVM 上高效运行其他语言；如何混搭这些语言，实现 Polyglot；如何将这些语言事前编译（Ahead-Of-Time，AOT）成机器指令，单独运行甚至嵌入至数据库中运行。

我希望借由这四个模块 36 个案例，帮助你理解 Java 虚拟机的运行机制，掌握诊断手法和调优方式。最重要的，是激发你学习 Java 虚拟机乃至其他底层工作、前沿工作的热情。

知识框架图

![memo](https://static001.geekbang.org/resource/image/41/77/414248014bf825dd610c3095eed75377.jpg)
模块一 基本原理
java代码是怎么运行的？
java的基本类型
JVM是如何加载Java类的？
JVM是如何执行方法调用的？
JVM是如何执行方法调用的？
JVM是如何处理异常的?
JVM是如何实现反射的？
JVM构造对象的步骤都有哪些？
什么是垃圾收集？
JVM是如何实现同步的？
Java内存模型是什么？
JVM的安全点是什么？

模块二 高效实现
javac是如何编译Java源代码的?
如何使用注解解释器？
解释器如何触发即时编译？
即时编译器与常规的静态编译器有哪些不同？

模块三 代码优化
模块四 黑科技