---
title: "分布式事务-TCC事务：最终一致性"
date: 2019-01-15T10:53:02+08:00
lastmod: 2019-01-15T10:53:02+08:00
draft: false
keywords: []
description: ""
tags: ["分布式"]
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
  enable: true
  options: ""

sequenceDiagrams: 
  enable: true
  options: ""

---

<!--more-->




## TCC 事务：最终一致性
方案简介

>TCC（Try-Confirm-Cancel）的概念，最早是由 Pat Helland 于 2007 年发表的一篇名为《Life beyond Distributed s:an Apostate’s Opinion》的论文提出。

TCC事务机制相对于传统事务机制（X/Open XA Two-Phase-Commit），其特征在于它不依赖资源管理器(RM)对XA的支持，而是通过对（由业务系统提供的）业务逻辑的调度来实现分布式事务。

对于业务系统中一个特定的业务逻辑S，其对外提供服务时，必须接受一些不确定性，即对业务逻辑执行的一次调用仅是一个临时性操作，调用它的消费方服务M保留了后续的取消权。如果M认为全局事务应该rollback，它会要求取消之前的临时性操作，这将对应S的一个取消操作；而当M认为全局事务应该commit时，它会放弃之前临时性操作的取消权，这对应S的一个确认操作。

每一个初步操作，最终都会被确认或取消。因此，针对一个具体的业务服务，TCC事务机制需要业务系统提供三段业务逻辑：初步操作Try、确认操作Confirm、取消操作Cancel。

TCC事务机制中的业务逻辑（Try），从执行阶段来看，与传统事务机制中业务逻辑相同。但从业务角度来看，却不一样。TCC机制中的Try仅是一个初步操作，它和后续的确认一起才能真正构成一个完整的业务逻辑。可以认为

```	
[传统事务机制]的业务逻辑 = [TCC事务机制]的初步操作（Try） + [TCC事务机制]的确认逻辑（Confirm）。
```

TCC 事务的 Try、Confirm、Cancel 可以理解为 SQL 事务中的 Lock、Commit、Rollback。



{{% admonition type="note" title="TCC" details="false" %}}

Try 操作作为一阶段，负责资源的检查和预留。

- 完成所有业务检查( 一致性 ) 。
- 预留必须业务资源( 准隔离性 ) 。

Confirm 操作作为二阶段提交操作，执行真正的业务。

- 真正执行业务
- 不作任何业务检查
- 只使用Try阶段预留的业务资源
- Confirm操作满足幂等性

Cancel 是预留资源的取消。

- 释放Try阶段预留的业务资源
- Cancel操作满足幂等性

{{% /admonition %}}




### 处理流程

为了方便理解，下面以电商下单为例进行方案解析，这里把整个过程简单分为扣减库存，订单创建 2 个步骤，库存服务和订单服务分别在不同的服务器节点上。

```sequence
主业务逻辑->库存服务: 检查、预留库存
Note left of 主业务逻辑: TCC（Try阶段）
库存服务-->库存服务: 更新库存为98,\n冻结库存为2
主业务逻辑->订单服务: 创建订单
订单服务-->订单服务: 创建订单、\n订单状态为待确认
库存服务-->主业务逻辑:执行成功
订单服务-->主业务逻辑:执行成功


Note left of 主业务逻辑: TCC（Confirm阶段）

主业务逻辑->库存服务: 确认提交
库存服务-->库存服务: 冻结库存减2
主业务逻辑->订单服务: 确认提交
订单服务-->订单服务: 更新订单状态为成功
库存服务-->主业务逻辑:执行成功
订单服务-->主业务逻辑:执行成功
```




#### ①Try 阶段

从执行阶段来看，与传统事务机制中业务逻辑相同。但从业务角度来看，却不一样。

TCC 机制中的 Try 仅是一个初步操作，它和后续的确认一起才能真正构成一个完整的业务逻辑，TCC 事务机制以初步操作（Try）为中心的，确认操作（Confirm）和取消操作（Cancel）都是围绕初步操作（Try）而展开。


假设商品库存为 100，购买数量为 2，这里检查和更新库存的同时，冻结用户购买数量的库存，同时创建订单，订单状态为待确认。

因此，Try 阶段中的操作，其保障性是最好的，即使失败，仍然有取消操作（Cancel）可以将其执行结果撤销。


#### ②Confirm / Cancel 阶段

根据 Try 阶段服务是否全部正常执行，继续执行确认操作（Confirm）或取消操作（Cancel）。 

Confirm 和 Cancel 操作满足幂等性，如果 Confirm 或 Cancel 操作执行失败，将会不断重试直到执行完成。


Confirm：当 Try 阶段服务全部正常执行， 执行确认业务逻辑操作，这里使用的资源一定是 Try 阶段预留的业务资源。在 TCC 事务机制中认为，如果在 Try 阶段能正常的预留资源，那 Confirm 一定能完整正确的提交。



Confirm 阶段也可以看成是对 Try 阶段的一个补充，**Try+Confirm 一起组成了一个完整的业务逻辑**。

Cancel：当 Try 阶段存在服务执行失败， 进入 Cancel 阶段


Cancel 取消执行，释放 Try 阶段预留的业务资源，上面的例子中，Cancel 操作会把冻结的库存释放，并更新订单状态为取消。

在TCC事务模型中，Confirm/Cancel业务可能会被重复调用，其原因很多。比如，全局事务在提交/回滚时会调用各TCC服务的Confirm/Cancel业务逻辑。执行这些Confirm/Cancel业务时，可能会出现如网络中断的故障而使得全局事务不能完成。因此，故障恢复机制后续仍然会重新提交/回滚这些未完成的全局事务，这样就会再次调用参与该全局事务的各TCC服务的Confirm/Cancel业务逻辑






### 对比2PC两阶段提交
经常在网络上看见有人介绍TCC时，都提一句，”TCC是两阶段提交的一种”。其理由是TCC将业务逻辑分成try、confirm/cancel在两个不同的阶段中执行。其实这个说法，是不正确的。可能是因为既不太了解两阶段提交机制、也不太了解TCC机制的缘故，于是将两阶段提交机制的prepare、commit两个事务提交阶段和TCC机制的try、confirm/cancel两个业务执行阶段互相混淆，才有了这种说法。

两阶段提交（Two Phase Commit，下文简称2PC），简单的说，是将事务的提交操作分成了prepare、commit两个阶段。其事务处理方式为：

1、 在全局事务决定提交时，a）逐个向RM发送prepare请求；b）若所有RM都返回OK，则逐个发送commit请求最终提交事务；否则，逐个发送rollback请求来回滚事务；

2、 在全局事务决定回滚时，直接逐个发送rollback请求即可，不必分阶段。
* 需要注意的是：2PC机制需要RM提供底层支持（一般是兼容XA），而TCC机制则不需要。

TCC（Try-Confirm-Cancel），则是将业务逻辑分成try、confirm/cancel两个阶段执行，具体介绍见TCC事务机制简介。其事务处理方式为：

1、 在全局事务决定提交时，调用与try业务逻辑相对应的confirm业务逻辑；

2、 在全局事务决定回滚时，调用与try业务逻辑相对应的cancel业务逻辑。
可见，TCC在事务处理方式上，是很简单的：要么调用confirm业务逻辑，要么调用cancel逻辑。这里为什么没有提到try业务逻辑呢？因为try逻辑与全局事务处理无关。

当讨论2PC时，我们只专注于事务处理阶段，因而只讨论prepare和commit，所以，可能很多人都忘了，使用2PC事务管理机制时也是有业务逻辑阶段的。正是因为业务逻辑的执行，发起了全局事务，这才有其后的事务处理阶段。实际上，使用2PC机制时————以提交为例————一个完整的事务生命周期是：begin -> 业务逻辑 -> prepare -> commit。

再看TCC，也不外乎如此。我们要发起全局事务，同样也必须通过执行一段业务逻辑来实现。该业务逻辑一来通过执行触发TCC全局事务的创建；二来也需要执行部分数据写操作；此外，还要通过执行来向TCC全局事务注册自己，以便后续TCC全局事务commit/rollback时回调其相应的confirm/cancel业务逻辑。所以，使用TCC机制时————以提交为例————一个完整的事务生命周期是：begin -> 业务逻辑(try业务) -> commit(comfirm业务)。

综上，我们可以从执行的阶段上将二者一一对应起来：

1.  2PC机制的业务阶段 等价于 TCC机制的try业务阶段；
2. 2PC机制的提交阶段（prepare & commit） 等价于 TCC机制的提交阶段（confirm）；
3. 2PC机制的回滚阶段（rollback） 等价于 TCC机制的回滚阶段（cancel）。

因此，可以看出，虽然TCC机制中有两个阶段都存在业务逻辑的执行，但其中try业务阶段其实是与全局事务处理无关的。认清了这一点，当我们再比较TCC和2PC时，就会很容易地发现，TCC不是两阶段提交，而只是它对事务的提交/回滚是通过执行一段confirm/cancel业务逻辑来实现，仅此而已。

{{% admonition type="note" title="方案总结" details="false" %}}
TCC 事务机制相对于传统事务机制（X/Open XA Two-Phase-Commit）,有以下优点：

- 性能提升：具体业务来实现控制资源锁的粒度变小，不会锁定整个资源。 
- 数据最终一致性：基于 Confirm 和 Cancel 的幂等性，保证事务最终完成确认或者取消，保证数据的一致性。
- 可靠性：解决了 XA 协议的协调者单点故障问题，由主业务方发起并控制整个业务活动，业务活动管理器也变成多点，引入集群。

缺点： 

TCC 的 Try、Confirm 和 Cancel 操作功能要按具体业务来实现，业务耦合度较高，提高了开发成本。

{{% /admonition %}}