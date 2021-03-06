---
title: "分布式事务-2PC(二阶段提交)"
date: 2019-01-14T14:53:02+08:00
lastmod: 2019-01-14T14:53:02+08:00
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




2PC(二阶段提交)方案：强一致性

### 方案简介

二阶段提交协议（Two-phase Commit，即 2PC）是常用的分布式事务解决方案，即将事务的提交过程分为两个阶段来进行处理：**准备阶段**和**提交阶段**。事务的发起者称**协调者**，事务的执行者称**参与者**。

在分布式系统里，每个节点都可以知晓自己操作的成功或者失败，却无法知道其他节点操作的成功或失败。

当一个事务跨多个节点时，为了保持事务的原子性与一致性，而引入一个协调者来统一掌控所有参与者的操作结果，并指示它们是否要把操作结果进行真正的提交或者回滚（rollback）。

二阶段提交的算法思路可以概括为：参与者将操作成败通知协调者，再由协调者根据所有参与者的反馈情报决定各参与者是否要提交操作还是中止操作。

核心思想就是对每一个事务都采用先尝试后提交的处理方式，处理后所有的读操作都要能获得最新的数据，因此也可以将二阶段提交看作是一个强一致性算法。




### 处理流程

简单一点理解，可以把协调者统一协调跟班小弟的任务执行。

#### 阶段 1：准备阶段


准备阶段有如下三个步骤：

- 协调者向所有参与者发送事务内容，询问是否可以提交事务，并等待所有参与者答复。
- 各参与者执行事务操作，将 undo 和 redo 信息记入事务日志中（但不提交事务）。
- 如参与者执行成功，给协调者反馈 yes，即可以提交；如执行失败，给协调者反馈 no，即不可提交。

#### 阶段 2：提交阶段

如果协调者收到了参与者的失败消息或者超时，直接给每个参与者发送回滚(rollback)消息；否则，发送提交(commit)消息。

### 可能的情况
参与者根据协调者的指令执行提交或者回滚操作，释放所有事务处理过程中使用的锁资源。(注意：必须在最后阶段释放锁资源) 接下来分两种情况分别讨论提交阶段的过程。

```sequence
协调者->参与者A: ready?
Note left of 协调者: 2PC（准备阶段）
参与者A-->参与者A: 执行事务操作
协调者->参与者B: ready?
参与者B-->参与者B: 执行事务操作
协调者->参与者C: ready?
参与者C-->参与者C: 执行事务操作
参与者A-->协调者:yes
参与者B-->协调者:yes
参与者C-->协调者:yes

Note left of 协调者: 2pc（提交阶段）
协调者->>参与者A: commit
参与者A-->参与者A: 提交事务
协调者->>参与者B: commit
参与者B-->参与者B: 提交事务
协调者->>参与者C: commit
参与者C-->参与者C: 提交事务
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:ack

```


#### 情况 1，当所有参与者均反馈 yes，提交事务，如上图：

- 协调者向所有参与者发出正式提交事务的请求（即 commit 请求）。
- 参与者执行 commit 请求，并释放整个事务期间占用的资源。
- 各参与者向协调者反馈 ack(应答)完成的消息。
- 协调者收到所有参与者反馈的 ack 消息后，即完成事务提交。

```sequence
协调者->参与者A: ready?
Note left of 协调者: 2PC（准备阶段）
参与者A-->参与者A: 执行事务操作
协调者->参与者B: ready?
参与者B-->参与者B: 执行事务操作
协调者->参与者C: ready?
参与者C-->参与者C: 执行事务操作
参与者A-->协调者:yes
参与者B-->协调者:no
参与者C-->协调者:yes

Note left of 协调者: 2pc（提交阶段）
协调者->>参与者A: rollback
参与者A-->参与者A: 回滚事务
协调者->>参与者B: rollback
参与者B-->参与者B: 回滚事务
协调者->>参与者C: rollback
参与者C-->参与者C: 回滚事务
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:ack

```

#### 情况 2，当任何阶段 1 一个参与者反馈 no，中断事务，如上图：
- 协调者向所有参与者发出回滚请求（即 rollback 请求）。
- 参与者使用阶段 1 中的 undo 信息执行回滚操作，并释放整个事务期间占用的资源。
- 各参与者向协调者反馈 ack 完成的消息。
- 协调者收到所有参与者反馈的 ack 消息后，即完成事务中断。






![2pc](/img/2PC.png)
### 方案总结

2PC 方案实现起来简单，实际项目中使用比较少，主要因为以下问题：

**性能问题**：所有参与者在事务提交阶段处于同步阻塞状态，占用系统资源，容易导致性能瓶颈。

**可靠性问题**：如果协调者存在单点故障问题，如果协调者出现故障，参与者将一直处于锁定状态。

**数据一致性问题**：在阶段 2中，如果发生局部网络问题，一部分事务参与者收到了提交消息，另一部分事务参与者没收到提交消息，那么就导致了节点之间数据的不一致。


### 两阶段提交无法解决的问题

当协调者出错，同时参与者也出错时，两阶段无法保证事务执行的完整性。

考虑协调者再发出commit消息之后宕机，而唯一接收到这条消息的参与者同时也宕机了。那么即使协调者通过选举协议产生了新的协调者，这条事务的状态也是不确定的，没人知道事务是否被已经提交。






