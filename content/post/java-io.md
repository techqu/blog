---
title: "Java Io"
date: 2018-12-27T18:05:02+08:00
draft: true
author: "瞿广"
originallink: ""
summary: "这里填写文章文章摘要。"
tags: ["java"]
categories: ["Tech","geektime"]
---

 Java 提供了哪些IO方式？NIO如何实现多路复用？

首先、传统的java.io包，它基于流模型实现，提供了，比如File抽象、输入输出流等。交互方式是同步、阻塞的方式。也就是说，在读取输入流或者写入输出流时，在写、读动作完成之前，线程会一直阻塞在那里，它们之间的调用时可靠的线性顺序。

<!--more-->

简单、直观，但是io效率和扩展性存在局限性。

第二、在Java1.4中引入了NIO框架（java.nio）,提供了Channel、Selector、Buffer等新的抽象，可以构建多路复用的、同步非阻塞IO程序，同时提供了更接近操作系统底层的高性能数据操作方式。

第三、在Java7中，NIO有了进一步的改进，也就是NIO2，引入了异步非阻塞IO方式，也有很多人叫它AIO（Asynchronous IO）。异步IO操作基于事件和回调机制，可以简单理解为，应用操作直接返回，而不会阻塞在那里，当后台处理完成，操作系统会通知相应线程进行后续工作。
