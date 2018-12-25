---
title: "Jvm How Execute Method 1"
date: 2018-12-25T22:52:53+08:00
draft: false
author: "瞿广"
originallink: ""
summary: "这里填写文章文章摘要。"
tags: ["java"]
categories: ["Tech"]
---

> JVM是如何执行方法调用的？（上）

## 一、重载与重写
 同一个类中出现多个名字相同，并且参数类型相同的方法，那么他们的参数类型必须不同。这些方法之间的关系，我们称为重载。

    小知识：这个限制可以通过字节码工具绕开。
    也就是说，在编译完成之后，我们可以再向 class 文件中添加方法名和参数类型相同，而返回类型不同的方法。
    当这种包括多个方法名相同、参数类型相同，而返回类型不同的方法的类，出现在 Java 编译器的用户类路径上时，它是怎么确定需要调用哪个方法的呢？
    当前版本的 Java 编译器会直接选取第一个方法名以及参数类型匹配的方法。
    并且，它会根据所选取方法的返回类型来决定可不可以通过编译，以及需不需要进行值转换等。
## 二、JVM 的静态绑定和动态绑定

### 1.Java虚拟机是怎么识别方法的。
Java虚拟机识别方法的关键在于类名、方法名以及方法描述符（method descirptor）
方法描述符，它是由方法的参数类型以及返回类型所构成。在同一个类中，如果同时出现多个名字相同且描述符也相同的方法，那么Java虚拟机会在类的验证阶段报错。



```java
interface 客户 {
  boolean isVIP();
}

class 商户 {
  public double 折后价格 (double 原价, 客户 某客户) {
    return 原价 * 0.8d;
  }
}

class 奸商 extends 商户 {
  @Override
  public double 折后价格 (double 原价, 客户 某客户) {
    if (某客户.isVIP()) {                         // invokeinterface
      return 原价 * 价格歧视 ();                    // invokestatic
    } else {
      return super. 折后价格 (原价, 某客户);          // invokespecial
    }
  }
  public static double 价格歧视 () {
    // 咱们的杀熟算法太粗暴了，应该将客户城市作为随机数生成器的种子。
    return new Random()                          // invokespecial
           .nextDouble()                         // invokevirtual
           + 0.8d;
  }
}

```
## 三、调用指令的符号引用
