---
title: "java内存溢出分析工具：jmap使用实战"
date: 2019-08-19T17:49:12+08:00
lastmod: 2019-08-19T17:49:12+08:00
draft: false
keywords: []
description: ""
tags: ["jvm"]
categories: ["Tech"]
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
java内存溢出分析工具：jmap使用实战
<!--more-->

在一次解决系统tomcat老是内存撑到头，然后崩溃的问题时，使用到了jmap。 
1. 使用命令 

在环境是linux+jdk1.5以上，这个工具是自带的，路径在`JDK_HOME/bin/`下 

```
jmap -histo pid>a.log
```

2. 输出结果摘要 

```
Size    Count   Class description 
------------------------------------------------------- 
353371288       9652324 char[] 
230711112       9612963 java.lang.String 
139347160       114865  byte[] 
76128096        3172004 java.util.Hashtable$Entry 
75782280        3157595 com.test.util.IPSeeker$IPLocation 
25724272        9115    java.util.Hashtable$Entry[] 
9319968 166428  org.apache.tomcat.util.buf.MessageBytes 
8533856 32889   int[] 
```
发现有大量的String和自定义对象`com.test.util.IPSeeker$IPLocation`存在，检查程序发现此处果然存在内存溢出。修改程序上线后再次用jmap抓取内存数据： 

```
146881712   207163  byte[] 
98976352    354285  char[] 
42595272    53558   int[] 
11515632    479818  java.util.HashMap$Entry 
9521896 59808   java.util.HashMap$Entry[] 
8887392 370308  com.test.bean.UnionIPEntry 
8704808 155443  org.apache.tomcat.util.buf.MessageBytes 
8066880 336120  java.lang.String 
```
内存溢出问题消除。 
注意：这个jmap使用的时候jvm是处在假死状态的，只能在服务瘫痪的时候为了解决问题来使用，否则会造成服务中断。
 
 其中：
[C is a char[]
[S is a short[]
[I is a int[]
[B is a byte[]
[[I is a int[][]


## 案例二

 jmap命令可以获得运行中的jvm的堆的快照，从而可以离线分析堆，以检查内存泄漏，检查一些严重影响性能的大对象的创建，检查系统中什么对象最多，各种对象所占内存的大小等等

jmap （linux下特有，也是很常用的一个命令）

观察运行中的jvm物理内存的占用情况。

参数如下：

- -heap ：打印jvm heap的情况
- -histo： 打印jvm heap的直方图。其输出信息包括类名，对象数量，对象占用大小。
- -histo：live ： 同上，但是只答应存活对象的情况
- -permstat： 打印permanent generation heap情况

命令使用：

`jmap -heap 3409`

可以观察到New Generation（Eden Space，From Space，To Space）,tenured generation,Perm Generation的内存使用情况

输出内容：

`jmap -histo 3409 | jmap -histo:live 3409`

可以观察heap中所有对象的情况（heap中所有生存的对象的情况）。包括对象数量和所占空间大小。

输出内容：

写个脚本，可以很快把占用heap最大的对象找出来，对付内存泄漏特别有效。

如果结果很多，可以用以下命令输出到文本文件。

`jmap -histo 3409 | jmap -histo:live 3409 &gt; a.txt`

常用选项：

```
-dump:format=b,file=<filename> pid    # dump堆到文件,format指定输出格式，live指明是活着的对象,file指定文件名
-finalizerinfo  # 打印等待回收对象的信息
-heap           # 打印heap的概要信息，GC使用的算法，heap的配置及wise heap的使用情况,可以用此来判断内存目前的使用情况以及垃圾回收情况
-histo[:live]   # 打印堆的对象统计，包括对象数、内存大小等等 （因为在dump:live前会进行full gc，因此不加live的堆大小要大于加live堆的大小 ）
-permstat       # 打印classload类装载器和 jvm heap长久层的信息. 包含包括每个装载器的名字，活跃，地址，父装载器，和其总共加载的类大小。另外,内部String的数量和占用内存数也会打印出来. 
-F              # 强制，强迫.在pid没有相应的时候使用-dump或者-histo参数. 在这个模式下,live子参数无效.  
-J              # 传递参数给jmap启动的jvm. ，如：-J-Xms256m
```

实例：
Jmap

`[root@tomcat01 ~]# jmap 13614`

```
Attaching to process ID 13614, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 24.55-b03
0x0000000000400000      7K      /aliyun/java-1.7.0/bin/java
0x0000003666400000      91K     /lib64/libgcc_s-4.4.7-20120601.so.1
0x0000003d7e400000      153K    /lib64/ld-2.12.so
0x0000003d7ec00000      1881K   /lib64/libc-2.12.so
0x0000003d7f000000      142K    /lib64/libpthread-2.12.so
0x0000003d7f400000      22K     /lib64/libdl-2.12.so
0x0000003d7f800000      46K     /lib64/librt-2.12.so
0x0000003d7fc00000      585K    /lib64/libm-2.12.so
0x0000003d80c00000      111K    /lib64/libresolv-2.12.so
0x0000003d82000000      461K    /lib64/libfreebl3.so
0x0000003d83000000      42K     /lib64/libcrypt-2.12.so
0x00007f42de29b000      257K    /aliyun/java-1.7.0/jre/lib/amd64/libjpeg.so
0x00007f42de4d6000      477K    /aliyun/java-1.7.0/jre/lib/amd64/libt2k.so
0x00007f42de755000      512K    /aliyun/java-1.7.0/jre/lib/amd64/libfontmanager.so
0x00007f42de9ce000      36K     /aliyun/java-1.7.0/jre/lib/amd64/headless/libmawt.so
0x00007f42debd5000      755K    /aliyun/java-1.7.0/jre/lib/amd64/libawt.so
0x00007f43047d4000      26K     /lib64/libnss_dns-2.12.so
0x00007f4304f2b000      250K    /aliyun/java-1.7.0/jre/lib/amd64/libsunec.so
0x00007f4305172000      774K    /aliyun/apr/lib/libapr-1.so.0.5.0
0x00007f43053a4000      658K    /usr/local/apr/lib/libtcnative-1.so.0.1.34
0x00007f43055bc000      44K     /aliyun/java-1.7.0/jre/lib/amd64/libmanagement.so
0x00007f4305ac4000      112K    /aliyun/java-1.7.0/jre/lib/amd64/libnet.so
0x00007f4305cdb000      89K     /aliyun/java-1.7.0/jre/lib/amd64/libnio.so
0x00007f432840d000      120K    /aliyun/java-1.7.0/jre/lib/amd64/libzip.so
0x00007f4328628000      64K     /lib64/libnss_files-2.12.so
0x00007f432883e000      214K    /aliyun/java-1.7.0/jre/lib/amd64/libjava.so
0x00007f4328a69000      63K     /aliyun/java-1.7.0/jre/lib/amd64/libverify.so
0x00007f4328cf8000      14786K  /aliyun/java-1.7.0/jre/lib/amd64/server/libjvm.so
0x00007f4329b61000      103K    /aliyun/java-1.7.0/lib/amd64/jli/libjli.so
```

jhat也可以监控jvm

可以参考如下博文：

https://www.cnblogs.com/myna/p/7590620.html