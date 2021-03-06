---
title: "《趣谈网络协议》- Udp Tcp"
date: 2019-07-25T14:38:50+08:00
lastmod: 2019-07-25T14:38:50+08:00
draft: false
keywords: []
description: ""
tags: ["网络协议","《趣谈网络协议》"]
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

传输层里比较重要的两个协议，一个是 TCP，一个是
UDP。对于不从事底层开发的人员来讲，或者对于开发应用的人来讲，最常用的就是这两个协议。由于
面试的时候，这两个协议经常会被放在一起问

<!--more-->

## UDP
tcp所谓的建立连接，是为了在客户端和服务端维护连接，而建立一定的数据结构来维护双方交互的状态，
用这样的数据结构来保证所谓的面向连接的特性.

例如，TCP 提供可靠交付。通过 TCP 连接传输的数据，无差错、不丢失、不重复、并且按序到达。我们
都知道 IP 包是没有任何可靠性保证的，一旦发出去，就像西天取经，走丢了、被妖怪吃了，都只能随它
去。但是 TCP 号称能做到那个连接维护的程序做的事情，这个下两节我会详细描述。而UDP 继承了 IP
包的特性，不保证不丢失，不保证按顺序到达。


再如，TCP 是面向字节流的。发送的时候发的是一个流，没头没尾。IP 包可不是一个流，而是一个个的
IP 包。之所以变成了流，这也是 TCP 自己的状态维护做的事情。而UDP 继承了 IP 的特性，基于数据报
的，一个一个地发，一个一个地收。

还有TCP 是可以有拥塞控制的。它意识到包丢弃了或者网络的环境不好了，就会根据情况调整自己的行
为，看看是不是发快了，要不要发慢点。UDP 就不会，应用让我发，我就发，管它洪水滔天。
因而TCP 其实是一个有状态服务，通俗地讲就是有脑子的，里面精确地记着发送了没有，接收到没有，
发送到哪个了，应该接收哪个了，错一点儿都不行。而UDP 则是无状态服务。通俗地说是没脑子的，天
真无邪的，发出去就发出去了。

我们可以这样比喻，如果 **MAC 层定义了本地局域网的传输行为，IP 层定义了整个网络端到端的传输行
为，**这两层基本定义了这样的基因：网络传输是以包为单位的，二层叫帧，网络层叫包，传输层叫段。
我们笼统地称为包。包单独传输，自行选路，在不同的设备封装解封装，不保证到达。基于这个基因，
生下来的孩子 UDP 完全继承了这些特性，几乎没有自己的思想

当我发送的 UDP 包到达目标机器后，发现 MAC 地址匹配，于是就取下来，将剩下的包传给处理 IP 层的代码。把 IP 头取下来，发现目标 IP 匹配，接下来
呢？这里面的数据包是给谁呢？

发送的时候，我知道我发的是一个 UDP 的包，收到的那台机器咋知道的呢？所以在 IP 头里面有个 8 位
协议，这里会存放，数据里面到底是 TCP 还是 UDP，当然这里是 UDP。于是，如果我们知道 UDP 头
的格式，就能从数据里面，将它解析出来。解析出来以后呢？数据给谁处理呢？

处理完传输层的事情，内核的事情基本就干完了，里面的数据应该交给应用程序自己去处理，可是一台
机器上跑着这么多的应用程序，应该给谁呢？

无论应用程序写的使用 TCP 传数据，还是 UDP 传数据，都要监听一个端口。正是这个端口，用来区分
应用程序，要不说端口不能冲突呢。两个应用监听一个端口，到时候包给谁呀？所以，按理说，无论是
TCP 还是 UDP 包头里面应该有端口号，根据端口号，将数据交给相应的应用程序。

![udp](/img/geektime-network-protocol-udp.png)

### UDP 的三大使用场景

- 第一，需要资源少，在网络情况比较好的内网，或者对于丢包不敏感的应用。 DHCP 就是基于 UDP 协议的。一般的获取 IP 地址都是内网请求，而且一次获取不到IP 又没事，过一会儿还有机会。
- 第二，不需要一对一沟通，建立连接，而是可以广播的应用。
- 第三，需要处理速度快，时延低，可以容忍少数丢包，但是要求即便网络拥塞，也毫不退缩，一往无前的时候.


## TCP
它之所以这么复杂，那是因为它秉承的是“性恶论”。它天然认为网络环境是恶劣的，丢包、乱序、重传，拥塞都是常
有的事情，一言不合就可能送达不了，因而要从算法层面来保证可靠性。

TCP 包头格式

![tcp](/img/geektime-network-protocol-tcp.png)

为什么要给包编号呢？当然是为了解决乱序的问题。不编好号怎么确认哪个应该先
来，哪个应该后到呢

确认序号。发出去的包应该有确认，要不然我怎么知道对方有没有收到呢？如果没有收
到就应该重新发送，直到送达

接下来有一些状态位。例如 SYN 是发起一个连接，ACK 是回复，RST 是重新连接，PSH表示有 DATA数据传输，，FIN 是结束连接
等。TCP 是面向连接的，因而双方要维护连接的状态，这些带状态位的包的发送，会引起双方的状态变更。


### TCP 的三次握手

我们也常称为**“请求 -> 应答 -> 应答之应答”**的三个回合


三次握手除了双方建立连接外，主要还是为了沟通一件事情，就是TCP 包的序号的问题

例如，A 连上 B 之后，发送了 1、2、3 三个包，但是发送 3 的时候，中间丢了，或者绕路了，于是重新
发送，后来 A 掉线了，重新连上 B 后，序号又从 1 开始，然后发送 2，但是压根没想发送 3，但是上次
绕路的那个 3 又回来了，发给了 B，B 自然认为，这就是下一个包，于是发生了错误。


每个连接都要有不同的序号。这个序号的起始序号是随着时间变化的，可以看成一个 32 位的计数
器，每 4ms 加一，如果计算一下，如果到重复，需要 4 个多小时，那个绕路的包早就死翘翘了，因为我
们都知道 IP 包头里面有个 TTL，也即生存时间


在连接建立的过程中，双方的状态变化时序图就像这样


![tcp-status](/img/geektime-network-protocol-tcp-status.png)




一开始，客户端和服务端都处于 CLOSED 状态。

先是服务端主动监听某个端口，处于 LISTEN 状态。

然后客户端主动发起连接 SYN，之后处于 SYN-SENT 状态。

服务端收到发起的连接，返回 SYN，并且ACK 客户端的 SYN，之后处于 SYN-RCVD 状态。

客户端收到服务端发送的 SYN 和 ACK 之后，发送ACK 的 ACK，之后处于 ESTABLISHED 状态，因为它一发一收成功了。

服务端收到 ACK 的 ACK 之后，处于 ESTABLISHED 状态，因为它也一发一收了


>seq和ack号存在于TCP报文段的首部中，seq是序号，ack是确认号，大小均为4字节。

>**seq：**占 4 字节，序号范围[0，2^32-1]，序号增加到 2^32-1 后，下个序号又回到 0。TCP 是面向字节流的，通过 TCP 传送的字节流中的每个字节都按顺序编号，而报头中的序号字段值则指的是本报文段数据的第一个字节的序号。

>**ack：**占 4 字节，期望收到对方下个报文段的第一个数据字节的序号。


简单总结一下：**每次发送时都需要有一个新的发送序号SEQ，并把确认序号ACK设置为接收到的发送序号SEQ+1**


### TCP 的四次挥手

TCP 协议专门设计了几个状态来处理这些问题。我们来看断开连接的时候的状态时序图

![tcp-close](/img/geektime-netwok-protocol-tcp-close.png)

断开的时候，我们可以看到，当 A 说“不玩了”，就进入 FIN_WAIT_1 的状态，B 收到“A 不玩”的消
息后，发送知道了，就进入 CLOSE_WAIT 的状态。

A 收到“B 说知道了”，就进入 FIN_WAIT_2 的状态，如果这个时候 B 直接跑路，则 A 将永远在这个状
态。TCP 协议里面并没有对这个状态的处理，但是 Linux 有，可以调整 tcp_fin_timeout 这个参数，设
置一个超时时间。

如果 B 没有跑路，发送了“B 也不玩了”的请求到达 A 时，A 发送“知道 B 也不玩了”的 ACK 后，从
FIN_WAIT_2 状态结束，按说 A 可以跑路了，但是最后的这个 ACK 万一 B 收不到呢？则 B 会重新发一
个“B 不玩了”，这个时候 A 已经跑路了的话，B 就再也收不到 ACK 了，因而 TCP 协议要求 A 最后等
待一段时间 TIME_WAIT，这个时间要足够长，长到如果 B 没收到 ACK 的话，“B 说不玩了”会重发
的，A 会重新发一个 ACK 并且足够时间到达 B。

A 直接跑路还有一个问题是，A 的端口就直接空出来了，但是 B 不知道，B 原来发过的很多包很可能还
在路上，如果 A 的端口被一个新的应用占用了，这个新的应用会收到上个连接中 B 发过来的包，虽然序
列号是重新生成的，但是这里要上一个双保险，防止产生混乱，因而也需要等足够长的时间，等到原来
B 发送的所有的包都死翘翘，再空出端口来。

等待的时间设为 2MSL，MSL是Maximum Segment Lifetime，报文最大生存时间，它是任何报文在网
络上存在的最长时间，超过这个时间报文将被丢弃。因为 TCP 报文基于是 IP 协议的，而 IP 头中有一个
TTL 域，是 IP 数据报可以经过的最大路由数，每经过一个处理他的路由器此值就减 1，当此值为 0 则数
据报将被丢弃，同时发送 ICMP 报文通知源主机。协议规定 MSL 为 2 分钟，实际应用中常用的是 30
秒，1 分钟和 2 分钟等。

还有一个异常情况就是，B 超过了 2MSL 的时间，依然没有收到它发的 FIN 的 ACK，怎么办呢？按照
TCP 的原理，B 当然还会重发 FIN，这个时候 A 再收到这个包之后，A 就表示，我已经在这里等了这么
长时间了，已经仁至义尽了，之后的我就都不认了，于是就直接发送 RST，B 就知道 A 早就跑了。


### TCP 状态机

将连接建立和连接断开的两个时序状态图综合起来，就是这个著名的 TCP 的状态机。学习的时候比较建
议将这个状态机和时序状态机对照着看，不然容易晕

![tcp-statemachine](/img/geektime-network-protocol-tcp-statemachine.png)
在这个图中，加黑加粗的部分，是上面说到的主要流程，其中阿拉伯数字的序号，是连接过程中的顺
序，而大写中文数字的序号，是连接断开过程中的顺序。加粗的实线是客户端 A 的状态变迁，加粗的虚
线是服务端 B 的状态变迁。