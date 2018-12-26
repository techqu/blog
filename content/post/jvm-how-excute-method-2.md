---
title: "JVM是如何执行方法调用的？（下）"
date: 2018-12-26T11:45:43+08:00
draft: false
author: "瞿广"
originallink: ""
summary: "这里填写文章文章摘要。"
tags: ["java"]
categories: ["Tech"]
---
>《极客时间-深入拆解java虚拟机》笔记

### 1.虚方法调用
Java里所有非私有实例方法调用都会被编译成invokevirtual指令，接口方法调用都会编译成invokeinterface指令。这两种指令，均属于Java虚拟机中的虚方法调用
### 2.方法表
### 3.内联缓存
### 4.总结实战
