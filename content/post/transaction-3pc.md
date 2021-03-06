---
title: "分布式事务-3PC(三阶段提交)"
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





## 方案简介

三阶段提交协议，是二阶段提交协议的改进版本，与二阶段提交不同的是，**引入超时机制**。同时在协调者和参与者中都引入超时机制。


3PC把2PC的准备阶段一分为二，这样三阶段提交就有CanCommit、preCommit、DoCommit三个阶段，在第一阶段询问所有参与者是否可以执行事务操作，并不在本阶段执行事务操作，当协调者收到所有参与者都返回yes时，在第二阶段才执行事务操作，然后在第三阶段执行commit或rollback.

插入了一个 preCommit 阶段，使得原先在二阶段提交中，参与者在准备之后，由于协调者发生崩溃或错误，而导致参与者处于无法知晓是否提交或者中止的“不确定状态”所产生的可能相当长的延时的问题得以解决。




## 处理流程

### 阶段 1：canCommit

协调者向参与者发送 commit 请求，参与者如果可以提交就返回 yes 响应(参与者不执行事务操作)，否则返回 no 响应：
- 协调者向所有参与者发出包含事务内容的 canCommit 请求，询问是否可以提交事务，并等待所有参与者答复。
- 参与者收到 canCommit 请求后，如果认为可以执行事务操作，则反馈 yes 并进入预备状态，否则反馈 no。

### 阶段 2：preCommit

协调者根据阶段 1 canCommit 参与者的反应情况来决定是否可以进行基于事务的 preCommit 操作。根据响应情况，有以下两种可能。

```sequence
协调者->参与者A: CanCommit
Note left of 协调者: 2PC（准备阶段-CanCommit）
参与者A-->参与者A: 检查是否可以提交
协调者->参与者B: CanCommit
参与者B-->参与者B: 检查是否可以提交
协调者->参与者C: CanCommit
参与者C-->参与者C: 检查是否可以提交
参与者A-->协调者:yes
参与者B-->协调者:yes
参与者C-->协调者:yes

Note left of 协调者: 2PC（准备阶段-preCommit）
协调者->参与者A: preCommit
参与者A-->参与者A: 执行事务操作
协调者->参与者B: preCommit
参与者B-->参与者B: 执行事务操作
协调者->参与者C: preCommit
参与者C-->参与者C: 执行事务操作
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:ack

Note left of 协调者: 2PC（提交阶段-doCommit）
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

情况 1：阶段 1 所有参与者均反馈 yes，参与者预执行事务，如上图： 

- 协调者向所有参与者发出 preCommit 请求，进入准备阶段。
- 参与者收到 preCommit 请求后，执行事务操作，将 undo 和 redo 信息记入事务日志中（但不提交事务）。
- 各参与者向协调者反馈 ack 响应或 no 响应，并等待最终指令。


```sequence
协调者->参与者A: CanCommit
Note left of 协调者: 2PC（准备阶段-CanCommit）
参与者A-->参与者A: 检查是否可以提交
协调者->参与者B: CanCommit
参与者B-->参与者B: 检查是否可以提交
协调者->参与者C: CanCommit
参与者C-->参与者C: 检查是否可以提交
参与者A-->协调者:yes
参与者B-->协调者:yes
参与者C-->协调者:no

Note left of 协调者: 2PC（准备阶段-preCommit）
协调者->参与者A: abort
参与者A-->参与者A: 中断事务
协调者->参与者B: abort
参与者B-->参与者B: 中断事务
协调者->参与者C: abort
参与者C-->参与者C: 中断事务
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:ack

```

情况 2：阶段 1 任何一个参与者反馈 no，或者等待超时后协调者尚无法收到所有参与者的反馈，即中断事务，如上图：

- 协调者向所有参与者发出 abort 请求。
- 无论收到协调者发出的 abort  请求，或者在等待协调者请求过程中出现超时，参与者均会中断事务。

### 阶段 3：do Commit

该阶段进行真正的事务提交，也可以分为以下两种情况。

情况 1：阶段 2 所有参与者均反馈 ack 响应，执行真正的事务提交，如上图： 

- 如果协调者处于工作状态，则向所有参与者发出 do Commit 请求。
- 参与者收到 do Commit 请求后，会正式执行事务提交，并释放整个事务期间占用的资源。
- 各参与者向协调者反馈 ack 完成的消息。
- 协调者收到所有参与者反馈的 ack 消息后，即完成事务提交。


```sequence
Title: 阶段 2 任何一个参与者反馈 no
协调者->参与者A: CanCommit
Note left of 协调者: 2PC（准备阶段-CanCommit）
参与者A-->参与者A: 检查是否可以提交
协调者->参与者B: CanCommit
参与者B-->参与者B: 检查是否可以提交
协调者->参与者C: CanCommit
参与者A-->协调者:yes
参与者B-->协调者:yes
参与者C-->参与者C: 检查是否可以提交

参与者C-->协调者:yes

Note left of 协调者: 2PC（准备阶段-preCommit）
协调者->参与者A: preCommit
参与者A-->参与者A: 执行事务操作
协调者->参与者B: preCommit
参与者B-->参与者B: 执行事务操作
协调者->参与者C: preCommit
参与者C-->参与者C: 执行事务操作
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:no

Note left of 协调者: 2PC（提交阶段-doCommit）
协调者->>参与者A: abort
参与者A-->参与者A: 回滚事务
协调者->>参与者B: abort
参与者B-->参与者B: 回滚事务
协调者->>参与者C: abort
参与者C-->参与者C: 回滚事务
参与者A-->协调者:ack
参与者B-->协调者:ack
参与者C-->协调者:ack

```

情况 2：阶段 2 任何一个参与者反馈 no，或者等待超时后协调者尚无法收到所有参与者的反馈，即中断事务，如上图：

- 如果协调者处于工作状态，向所有参与者发出 abort 请求。
- 参与者使用阶段 1 中的 undo 信息执行回滚操作，并释放整个事务期间占用的资源。
- 各参与者向协调者反馈 ack 完成的消息。
- 协调者收到所有参与者反馈的 ack 消息后，即完成事务中断。

注意：进入阶段 3 后，无论协调者出现问题，或者协调者与参与者网络出现问题，都会导致参与者无法接收到协调者发出的 do Commit 请求或 abort 请求。此时，参与者都会在等待超时之后，继续执行事务提交。

### 方案总结

优点：相比二阶段提交，三阶段提交降低了阻塞范围，在等待超时后协调者或参与者会中断事务。避免了协调者单点问题，阶段 3 中协调者出现问题时，参与者会继续提交事务。

缺点：数据不一致问题依然存在，当在参与者收到 preCommit 请求后等待 do commit 指令时，此时如果协调者请求中断事务，而协调者无法与参与者正常通信，会导致参与者继续提交事务，造成数据不一致。




### 三阶段提交协议和两阶段提交协议的不同

对于协调者(Coordinator)和参与者(Cohort)都设置了超时机制（在2PC中，只有协调者拥有超时机制，即如果在一定时间内没有收到cohort的消息则默认失败）。

在2PC的准备阶段和提交阶段之间，插入预提交阶段，使3PC拥有CanCommit、PreCommit、DoCommit三个阶段。
PreCommit是一个缓冲，保证了在最后提交阶段之前各参与节点的状态是一致的





{{% admonition type="note" title="wiki" details="false" %}}

  三阶段提交是“非阻塞”协议。

  三阶段提交在两阶段提交的第一阶段与第二阶段之间插入了一个准备阶段，使得原先在两阶段提交中，参与者在投票之后，由于协调者发生崩溃或错误，而导致参与者处于无法知晓是否提交或者中止的“不确定状态”所产生的可能相当长的延时的问题得以解决。 
  
  举例来说，假设有一个决策小组由一个主持人负责与多位组员以电话联络方式协调是否通过一个提案，以两阶段提交来说，主持人收到一个提案请求，打电话跟每个组员询问是否通过并统计回复，然后将最后决定打电话通知各组员。
  要是主持人在跟第一位组员通完电话后失忆，而第一位组员在得知结果并执行后老人痴呆，那么即使重新选出主持人，也没人知道最后的提案决定是什么，也许是通过，也许是驳回，不管大家选择哪一种决定，都有可能与第一位组员已执行过的真实决定不一致，老板就会不开心认为决策小组沟通有问题而解雇。

  三阶段提交即是引入了另一个步骤，主持人打电话跟组员通知请准备通过提案，以避免没人知道真实决定而造成决定不一致的失业危机。
  为什么能够解决二阶段提交的问题呢？

  回到刚刚提到的状况，在主持人通知完第一位组员请准备通过后两人意外失忆，即使没人知道全体在第一阶段的决定为何，全体决策组员仍可以重新协调过程或直接否决，不会有不一致决定而失业。

  那么当主持人通知完全体组员请准备通过并得到大家的再次确定后进入第三阶段，
  当主持人通知第一位组员请通过提案后两人意外失忆，这时候其他组员再重新选出主持人后，
  仍可以知道目前至少是处于准备通过提案阶段，表示第一阶段大家都已经决定要通过了，此时便可以直接通过。

  {{% /admonition %}}


  了解了2PC和3PC之后，我们可以发现，无论是二阶段提交还是三阶段提交都无法彻底解决分布式的一致性问题。**Google Chubby的作者Mike Burrows说过， there is only one consensus protocol, and that’s Paxos” – all other approaches are just broken versions of Paxos. 意即世上只有一种一致性算法，那就是Paxos，**所有其他一致性算法都是Paxos算法的不完整版。后面的文章会介绍这个公认为难于理解但是行之有效的Paxos算法。