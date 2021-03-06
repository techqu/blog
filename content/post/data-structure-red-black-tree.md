---
title: "《数据结构与算法之美》-红黑树"
date: 2019-04-12T17:04:30+08:00
lastmod: 2019-04-12T17:04:30+08:00
draft: false
keywords: []
description: ""
tags:        ["数据结构","算法"]
categories:  ["Tech"]
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
很多书籍里，但凡讲到平衡二叉查找树，就会拿红黑树作为例子。不仅如此，如果你有一定的开发经验，你会发现，在工程中，很多用到平衡二叉查找树的地方都会用红黑树。你有没有想过，

Java TreeMap实现了SortedMap接口，也就是说会按照key的大小顺序对Map中的元素进行排序，key大小的评判可以通过其本身的自然顺序（natural ordering），也可以通过构造时传入的比较器（Comparator）。

TreeMap底层通过红黑树（Red-Black tree）实现，也就意味着containsKey(), get(), put(), remove()都有着log(n)的时间复杂度。其具体算法实现参照了《算法导论》。

<!--more-->

## 什么是“平衡二叉查找树”？

平衡二叉树的严格定义是这样的：二叉树中任意一个节点的左右子树的高度相差不能大于1.从这个定义来看，完全二叉树、满二叉树其实都是平衡二叉树，但是非完全二叉树也有可能是平衡二叉树。

所以，**平衡二叉查找树中“平衡”的意思，其实就是让整棵树左右看起来比较“对称”、比较“平衡”，不要出现左子树很高、右子树很矮的情况。这样就能让整棵树的高度相对来说低一些，相应的插入、删除、查找等操作的效率高一些**

## 如何定义一棵“红黑树”

满足这几个要求：

- 根节点是黑色的；
- 每个叶子节点都是黑色的空节点（NIL），也就是说，叶子节点不存储数据；（为了简化代码）
- 任何相邻的节点都不能同时为红色，也就是说，红色节点是被黑色节点隔开的；
- 每个节点，从该节点到达叶子节点的所有路径，都包含相同数目的黑色节点；

## 实现红黑树的基本思想

红黑树的平衡过程跟魔方复原非常神似，大概过程就是：遇到什么样的节点排布，我们就对应怎么去调整

调整策略就像数学公式一样，而公式是推导出来的。

在插入、和删除节点的过程中，第三、第四点要求可能会被破坏。而我们要讲的平衡调整，实际上就是要把被破坏的第三、第四点恢复过来。

两种重要的操作，左旋、右旋，都是围绕某个点的操作。

红黑树规定，插入的节点必须是红色的。而且，二叉查找树中新插入的节点都是放在叶子节点上。因此有两种特殊情况：

- 如果插入节点的父节点是黑色的，那我们什么都不用做，它仍然满足红黑树的定义。
- 如果插入的节点是根节点，那我们直接改变它的颜色，把它变成黑色就可以了。

除此之外的其他情况都会违背红黑树的定义，于是我们就需要调整，调整的过程包含两种基础操作：**左右旋转**和**改变颜色**

### 其他参考

- [史上最清晰的红黑树讲解（上）](https://www.cnblogs.com/CarpenterLee/p/5503882.html)
- [从2-3树到 红黑树](https://blog.csdn.net/fei33423/article/details/79132930)