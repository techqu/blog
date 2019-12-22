---
title: "分布式事务-MQ事务：最终一致性"
date: 2019-01-15T10:53:02+08:00
lastmod: 2019-01-15T10:53:02+08:00
draft: true
keywords: []
description: ""
tags: []
categories: []
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



MQ 事务：最终一致性

## 方案简介

基于 MQ 的分布式事务方案其实是对本地消息表的封装，将本地消息表基于 MQ 内部，其他方面的协议基本与本地消息表一致。

## 处理流程

>下面主要基于 RocketMQ 4.3 之后的版本介绍 MQ 的分布式事务方案。

在本地消息表方案中，保证事务主动方发写业务表数据和写消息表数据的一致性是基于数据库事务，RocketMQ 的事务消息相对于普通 MQ，相对于提供了 2PC 的提交接口，方案如下：

正常情况：事务主动方发消息


这种情况下，事务主动方服务正常，没有发生故障，发消息流程如下：

- 图中 1：发送方向 MQ 服务端(MQ Server)发送 half 消息。
- 图中 2：MQ Server 将消息持久化成功之后，向发送方 ack 确认消息已经发送成功。
- 图中 3：发送方开始执行本地事务逻辑。
- 图中 4：发送方根据本地事务执行结果向 MQ Server 提交二次确认（commit 或是 rollback）。
- 图中 5：MQ Server 收到 commit 状态则将半消息标记为可投递，订阅方最终将收到该消息；MQ Server 收到 rollback 状态则删除半消息，订阅方将不会接受该消息。

异常情况：事务主动方消息恢复


在断网或者应用重启等异常情况下，图中 4 提交的二次确认超时未到达 MQ Server，此时处理逻辑如下：
- 图中 5：MQ Server 对该消息发起消息回查。
- 图中 6：发送方收到消息回查后，需要检查对应消息的本地事务执行的最终结果。
- 图中 7：发送方根据检查得到的本地事务的最终状态再次提交二次确认。
- 图中 8：MQ Server基于 commit/rollback 对消息进行投递或者删除。

介绍完 RocketMQ 的事务消息方案后，由于前面已经介绍过本地消息表方案，这里就简单介绍 RocketMQ 分布式事务： 

事务主动方基于 MQ 通信通知事务被动方处理事务，事务被动方基于 MQ 返回处理结果。

如果事务被动方消费消息异常，需要不断重试，业务处理逻辑需要保证幂等。 

如果是事务被动方业务上的处理失败，可以通过 MQ 通知事务主动方进行补偿或者事务回滚。

方案总结

{{% admonition type="note"  details="false" %}}

相比本地消息表方案，MQ 事务方案优点是： 

消息数据独立存储 ，降低业务系统与消息系统之间的耦合。
吞吐量由于使用本地消息表方案。

缺点是： 

一次消息发送需要两次网络请求(half 消息 + commit/rollback 消息) 。
业务处理服务需要实现消息状态回查接口。


{{% /admonition %}}