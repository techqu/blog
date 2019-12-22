---
title: "《趣谈网络协议》- 文件下载"
date: 2019-09-11T14:38:50+08:00
lastmod: 2019-09-11T14:38:50+08:00
draft: false
keywords: []
description: ""
tags: ["网络协议","《趣谈网络协议》"]
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
  enable: false
  options: ""

sequenceDiagrams: 
  enable: false
  options: ""

---

 
 如果你想下载一个电影，一般会通过什么方式？

<!--more-->

最简单的方式就是 HTTP 进行下载。但是文件稍大点，下载速度就会奇慢无比。

FTP，文件传输协议。采用两个 TCP 连接来传输一个文件

控制连接:服务器以被动的方式，打开端口 21，客户端主动发起连接。该连接将命令从客户端传给服务器，并传回服务器的应答。

### p2p 是什么？

但是无论是 HTTP 的方式，还是 FTP 的方式，都有一个比较大的缺点，就是难以解决单一服务器的带宽压力，因为它们都是使用的传统的客户端服务器的方式。

后来，一种创新的、称为 P2P 的方式流行起来。P2P 就是 peer-to-peer。资源开始并不集中的存储在某些设备上，而是分散的存储在多台设备上，我们称为 peer种子（.torrent）文件
announce（tracker URL）和文件信息

文件信息里有这些内容
- info 区：这里指定的是该种子有几个文件、文件有多长、目录结构、以及目录和文件的名字
- Name 字段：指定顶层目录的名字
- 每个段的大小：BitTorrent（简称 BT）协议把一个文件分成很多个小段，然后分段下载。
- 段哈希值：将整个种子中，每个段的 SHA-1 哈希值拼在一起

下载时，BT 客户端首先解析.torrent 文件，得到 tracker 地址，然后连接 tracker 服务器。tracker 服务器回应下载者的请求，将其他下载者（包括发布者）IP 提供给下载者。下载者再连接其他下载者，根据.torrent 文件，两边分别对方告知自己已经有的块，然后交换对方没有的数据。此时不需要其他服务器的参与，并分散了单个线路上的数据流量，因此减轻了服务器的负担。

下载者每得到一个块，需要算出下载块的 Hash 验证码，并与.torrent 文件中的对比。

但是有个问题就是 tracer 是中心化的，这个服务器是用来登记有哪些用户在请求哪些资源。

### 去中心化网络（DHT）

彻底非中心化

于是，后来就有了一种叫作 DHT（Distributed Hash Table）的去中心化网络。每个加入这个 DHT 网络的人，都要负责存储这个网络里的资源信息和其他成员的联系信息，相当于所有人一起构成了一个庞大的分布式数据库。

有一种著名的 DHT 协议，叫 Kademlia 协议，这个和区块链的概念一样，很抽象。

任何一个 BitTorrent 启动之后，它都有两个角色。一个是 peer，监听一个 TCP 端口，用来上传和下载文件，这个角色表明，我这里有某个文件。另一个角色 DHT node，监听一个 UDP 的端口，通过这个角色，这个节点加入了一个 DHT 的网络