---
title: "怎样阅读spring源码"
date: 2019-07-12T11:51:07+08:00
lastmod: 2019-07-12T11:51:07+08:00
draft: false
keywords: []
description: ""
tags: ["spring","java"]
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

给不知道如何阅读spring源码的同学一点借鉴

<!--more-->

一、链接：https://www.zhihu.com/question/21346206/answer/101789659

建议不要硬着头皮看spring代码，本身的代码800多m，就是不上班开始看也不知道什么时候看完。基本原理其实就是通过反射解析类及其类的各种信息，包括构造器、方法及其参数，属性。然后将其封装成bean定义信息类、constructor信息类、method信息类、property信息类，最终放在一个map里，也就是所谓的container，池等等，其实就是个map。

建议还是多看看底层的知识。评论：先搞清楚原理，然后下载源码Debug一个小例子，跟进代码，理解容器、控制反转和依赖注入。

二、链接：https://www.zhihu.com/question/21346206/answer/173940450

As far as I'm concerned, 阅读好项目源代码，有几个前提条件要做好：

1. 知道该项目的用途，是干什么的
2. 了解该项目的架构，包含什么模块，各模块是干什么的
3. 英文水平最低限度：阅读无障碍

回归正题：怎么阅读Spring源码？

1. Spring Framework 是一个开源框架，能帮助企业快速搭建一栈式（Full Stack）企业级项目应用框架。
2. Spring Framework 项目架构图：


![spring-framework.webp](/img/spring-framework.webp)

3. 上面的图展示出，Spring框架包含了非常多的功能，不能漫无目的，一股脑地阅读，这样很容易头晕。了解完Spring架构、模块以及模块对应的功能后，可以针对性阅读部分源码。逐一攻破。
4. 另外Spring在代码设计中运用了大量的设计模式，可以用事件驱动去学习一下设计模式。

三、链接：https://www.zhihu.com/question/21346206/answer/88486078

建议在这个页面[code4craft/tiny-spring](https://github.com/code4craft/tiny-spring)下载下来所有step1--step10所有的项目，全部导入到工程，看看作者是怎样一步步把spring整个框架搭起来的，一步步顺着spring的功能完善代码，顺便学学spring类的组织结构，学到很多，等学完后头脑很清晰，确实受益匪浅。debug断点运行是我针对这个项目学习最好的方式，相信你也一样

四、先懂原理，后有针对性的看代码知识准备：了解基础知识，不要上来就阅读代码，打好基础可以做到事半功倍的效果找开始的地方：做什么事情都要知道从那里开始，读程序也不例外

- 分层次阅读：在阅读代码的时候不要一头就扎下去，这样往往容易只见树木不见森林，阅读代码比较好的方法有一点象二叉树的广度优先的遍历。
- 重复阅读：一次就可以将所有的代码都阅读明白的人是没有的。反复的去阅读同一段代码有助于得代码的理解。

