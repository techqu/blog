---
title: "线程间通信"
date: 2018-12-19T17:32:22+08:00
draft: false
tags:        ["java", "volatile","synchronized","多线程","并发"]
categories:  ["Tech"]
---

 《java并发编程的艺术》-4.3线程间通信


- volatile可以用来修饰字段（成员变量），就是告知程序**任何对该变量的访问均需要从共享内存中获取，而对它的改变必须同步刷新回共享内存**，它能保证所有线程对变量访问的可见性
- synchronized可以修饰方法或者以同步块的形式来进行使用，**它主要确保多个线程在同一个时刻，只能有一个线程处于方法或者同步块中**，它保证了线程对变量访问的可见性和排他性

<!--more-->

#### 4.3.2 等待\通知机制

#### 4.3.3 等待通知的经典范式

#### 4.3.4 管道输入、输出流

#### 4.3.5 Thread.join()

```java
public class a{
       public static void main (String args[]){
       }
}
```
#### 4.3.6 ThreadLocal