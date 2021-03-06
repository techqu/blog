---
title:       "《数据结构与算法之美》-高级篇"
date: 2018-11-18T15:03:48+08:00
lastmod: 2018-11-18T15:03:48+08:00
draft: false
keywords: []
description: ""
author:      "瞿广"
tags:        ["数据结构","算法"]
categories:  ["Tech"]
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
  enable: true
  options: ""

sequenceDiagrams: 
  enable: true
  options: ""

---

本文是极客时间中数据结构与算法课程的笔记，包含一些高级算法和实际场景



<!--more-->


## 贪心算法：如何使用贪心算法实现Huffman压缩编码？

贪心算法有很多经典应用。比如霍夫曼编码（Huffman Coding）、Prim和Kruskal最小生成树算法、还有Dijkstra单源最短路径算法。

## 分治算法：谈一谈大规模计算框架MapReduce中的分治思想

分治算法（divide and conquer）的核心思想其实就是四个字，分而治之，也就是将原问题划分成n个规模较小，并且结构与原问题相似的子问题，递归地解决这些子问题，然后再合并其结果，就得到原问题的解。

## 回溯算法
深度优先搜索算法利用的是回溯算法思想。它除了用来知道深度优先搜索这种经典的算法设计之外，还可以用在很多实际的软件开发场景中，比如正则表达式匹配、编译原理重的语法分析等。

除此之外，很多经典的数学问题都可以用回溯算法解决，比如数独、八皇后、0-1背包、图的着色、旅行商问题、全排列等等。

## 动态规划
动态规划比较适合用来求解最优问题，比如求最大值、最小值等等。他可以非常显著地降低时间复杂度，提高代码的执行效率。

- 0-1背包问题
- 0-1背包问题升级版

## 拓扑排序
## 最短路径：地图软件是如何计算最优出行路径的？
## 位图：如何实现网页爬虫中的URL去重功能？
BitMap。因为，布隆过滤器本身就是基于位图的，是对位图的一种改进。

问题：我们有一千万个整数，整数的范围在1到1亿之间。如何快速查找某个整数是否在1千万个整数中呢？
## 概率统计：如何利用朴素贝叶斯算法过滤垃圾短信？

1. 基于黑名单的过滤器
2. 基于规则的过滤器
3. 基于概率统计的过滤器

## 向量空间：如何实现一个简单的音乐推荐系统？

- 找到跟你口味偏好相似的用户，把他们爱听的歌曲推荐给你；
- 找出跟你喜爱的歌曲特征相似的歌曲，把这些歌曲推荐给你。

## B+树：MySQL数据库索引是如何实现的？
## 并行算法：如何利用并行处理提高算法的执行效率?

## 算法实战一：剖析Redis常用数据类型和对应的数据结构

### 列表（list）
我们先来看列表。列表这种数据类型支持存储一组数据。这种数据类型对应两种实现方法，一种是**压缩列表**，另一种是**双向循环链表**

当列表中存储的数据量比较小的时候，列表就可以采用压缩列表的方式实现。具体需要同时满足下面两个条件：

- 列表中保存的单个数据（有可能是字符串类型的）小于64字节；
- 列表中数据个数少于512个。

### 字典（hash）

字典类型用来存储一组数据对。每个数据对又包含键值两部分。字典类型也有两种实现方式。一种是我们刚刚讲到的**压缩列表**，一种是**散列表**。

只有当存储的数据量比较小的情况下，Redis才使用压缩列表来实现字典类型。具体需要满足两个条件：

- 字典中保存的键和值得大小都要小于64字节；
- 字典中键值堆的个数要小于512个。

### 集合（set）
集合这种数据类型用来存储一组不重复的数据。这种数据类型也有两种实现方法，一种是基于**有序数组**，另一种是基于**散列表。**

### 有序集合（sortedset）


### 数据持久化

两种思路：

1. 清除原有的存储结构，只将数据存储到磁盘中。我们需要从磁盘还原数据到内存的时候，再重新将数据组织成原来的数据结构。实际上，Redis就是采用的这种持久化思路。

    不过这种方式有一定的弊端。那就是数据从硬盘还原到内存的过程，会耗用比较多的时间。
    
2. 保留原有的存储格式，将数据按照原有的格式存储在磁盘中。我们拿散列表这样的数据结构来举例。我们可以将散列表的大小、每个数据被散列到的槽的编号等信息，都保存在磁盘中。有了这些信息，我们从磁盘中将数据还原到内存的时候，就可以避免重新计算哈希值。

## 算法实战二：剖析搜索引擎背后的经典数据结构和算法

搜索引擎大致可以分为四个部分：**搜集、分析、索引、查询**。

- 其中，搜集，就是我们常说的利用爬虫爬取网页。
- 分析，主要负责网页内容抽取、分词，构建临时索引，计算 PageRank 值这几部分工作。
- 索引，主要负责通过分析阶段得到的临时索引，构建倒排索引。
- 查询，主要负责响应用户的请求，根据倒排索引获取相关网页，计算网页排名，返回查询结果给用户。

搜索引擎把整个互联网看作数据结构中的有向图，把每个页面看作一个顶点。如果某个页面中包含另外一个页面的链接，那我们就在两个顶点之间连一条有向边。我们可以利用图的遍历搜索算法，来遍历整个互联网中的网页。

我们前面介绍过两种图的遍历方法，深度优先和广度优先。搜索引擎采用的是广度优先搜索策略。具体点讲的话，那就是，我们先找一些比较知名的网页（专业的叫法是权重比较高）的链接（比如新浪主页网址、腾讯主页网址等），作为种子网页链接，放入到队列中。爬虫按照广度优先的策略，不停地从队列中取出链接，然后取爬取对应的网页，解析出网页里包含的其他网页链接，再将解析出来的链接添加到队列中。

### 搜集
#### 1.待爬取网页链接文件：links.bin
#### 2.网页判重文件：bloom_filter.bin
#### 3.原始网页存储文件：doc_raw.bin

爬虫在爬取网页的过程中，涉及的四个重要的文件，我就介绍完了。其中，links.bin 和 bloom_filter.bin 这两个文件是爬虫自身所用的。另外的两个（doc_raw.bin、doc_id.bin）是作为搜集阶段的成果，供后面的分析、索引、查询用的。

### 分析
#### 1.抽取网页文本信息
#### 2.分词并创建临时索引
### 索引
索引阶段主要负责将分析阶段产生的临时索引，构建成倒排索引。倒排索引（ Inverted index）中记录了每个单词以及包含它的网页列表。文字描述比较难理解，我画了一张倒排索引的结构图，你一看就明白。
### 查询




## 算法实战三：剖析高性能队列Disruptor背后的数据结构和算法

Disruptor,它是一种内存消息队列。从功能来讲，它其实有点儿类似Kafka。不过，和Kafka不同的是，Disruptor是线程之间用于消息传递的队列。它在Apache Storm、Camel、Log4J2 等很多知名项目中都有应用。

### 基于循环队列的“生产者-消费者模型”

实际上，循环队列这种数据结构，就是我们今天要讲的内存消息队列的雏形。

### 基于加锁的并发“生产者-消费者模型”

### 基于无锁的并发“生产者-消费者模型”

## 算法实战四：剖析微服务接口鉴权限流背后的数据结构和算法

### 如何实现快速鉴权？
1. 如何实现精确匹配规则
  字符串匹配算法，规则不会经常变动，所以为了加快匹配速度，我们可以按照字符串的大小给规则排序
2. 如何实现前缀匹配规则
    Trie树非常世界用来做前缀匹配。所以，针对这个需求，我们可以将每个用户的规则集合，组织成Trie树这种数据结构。
3. 如何实现模糊匹配规则
    比如*，**。我们采用回溯算法，拿请求URL跟每条规则逐一进行模糊匹配。优化：组合使用精确匹配、前缀匹配和模糊匹配，最后在模糊匹配规则中查找

### 如何实现精准限流？

最简单的限流算法叫**固定时间窗口限流算法**

改造：滑动时间窗口限流算法

更加平滑的限流算法。比如

- 令牌桶算法，按照一定的速率生成固定的令牌个数
- 漏桶算法：其实很简单，可以粗略的认为就是注水漏水过程，往桶中以一定速率流出水，以任意速率流入水，当水超过桶流量则丢弃，因为桶容量是不变的，保证了整体的速率

## 算法实战五：如何用学过的数据结构和算法实现一个短网址系统？

短网址服务其实非常简单，就是把一个长的网址转化成一个短的网址。作为一名软件工程师，你是否思考过，这样一个简单的功能，是如何实现的？

浏览器会先访问短网址服务，通过短网址服务，通过短网址获取到原始地址，再通过原始网址访问到页面。

### 如何通过哈希算法生成短网址？

我们学过MD5、SHA等哈希算法，但是我们并不需要这些复杂的哈希算法，我们不需要考虑反向解密的难度，所以我们只需要关心哈希算法的计算速度和冲突概率。

MurmurHash算法，非加密hash算法

1. 如何让短网址更短。
  我们可以将10进制的哈希值，转化成更高进制的哈希值，这样就更短了。在网址URL中，常用的合法字符有0~9、a~z、A~Z这样62个字符。为了让哈希值表示起来尽可能短，我们可以将10进制的哈希值转化成62进制。
2. 如何解决哈希冲突问题？
  一旦冲突，就会导致两个原始网址被转化为同一个短网址。
  一般情况下，我们会保存短网址跟原始网址之间的关系，以便后续用户在访问短网址的时候，可以根据对应关系，查找到原始网址。假设存在了MYSQL里。存新的短地址之前，先从库里确定之前有没有生成过重复的，原始地址是否相同，相同则在原始网址后拼接特殊标记，再生成短网址。之后用户访问短网址时，检测到有特殊标志，先去掉再返回原始网址。
3. 如何优化哈希算法生成短网址的性能？
  优化SQL语句次数的方法：
  1. 索引，或者干脆加唯一索引
  2. 布隆过滤器。当有新的短网址生成的时候，我们先拿这个新生成的短网址，在布隆过滤器中查找。如果查找的结果是不存在，那就说明这个新生成的短网址并没有冲突。这个时候，我们只需要再执行写入短网址和对应原始网页的 SQL 语句就可以了。通过先查询布隆过滤器，总的 SQL 语句的执行次数减少了。

### 如何通过ID生成器生成短网址？

我们维护一个 ID 自增的 ID 生成器，给每个原始网址分配一个 ID 号码，并且同样转成 62 进制表示法，拼接到短网址服务的域名之后，形成最终的短网址。

1. 相同的原始网址可能会对应不同的短网址

2. 如何实现高性能的ID生成器
