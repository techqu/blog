---
title: "《透视HTTP协议》-常说的“四层”和“七层”到底是什么?"
date: 2019-02-20T15:29:44+08:00
lastmod: 2019-08-20T15:29:44+08:00
draft: false
keywords: []
description: ""
tags: ["《透视HTTP协议》"]
categories: []
author: "CSDN-JeremyZJM"

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
在上一讲中，我简单提到了TCP/IP协议，它是HTTP协议的下层协议，负责具体的数据传输工作。并且还特别说了，TCP/IP协议是一个“有层次的协议栈”。

<!--more-->

### TCP/IP网络分层模型



![geektime-http-protocol-tcp-ip](/img/geektime-http-protocol-tcp-ip.png)

我们来仔细地看一下这个精巧的积木架构，注意它的层次顺序是“从下往上”数的，所以第一层就是最下面 的一层。

- **第一层叫“链接层”(link layer)**，负责在以太网、WiFi这样的底层网络上发送原始数据包，工作在网卡这个层次，使用MAC地址来标记网络上的设备，所以有时候也叫MAC层。
- **第二层叫“网际层”或者“网络互连层”(internet layer)**，IP协议就处在这一层。因为IP协议定义了“IP 地址”的概念，所以就可以在“链接层”的基础上，用IP地址取代MAC地址，把许许多多的局域网、广域网 连接成一个虚拟的巨大网络，在这个网络里找设备时只要把IP地址再“翻译”成MAC地址就可以了。
- **第三层叫“传输层”(transport layer)**，这个层次协议的职责是保证数据在IP地址标记的两点之间“可靠”地传输，是TCP协议工作的层次，另外还有它的一个“小伙伴”UDP。

    TCP是一个有状态的协议，需要先与对方建立连接然后才能发送数据，而且保证数据不丢失不重复。而UDP 则比较简单，它无状态，不用事先建立连接就可以任意发送数据，但不保证数据一定会发到对方。两个协议 的另一个重要区别在于数据的形式。TCP的数据是连续的“字节流”，有先后顺序，而UDP则是分散的小数 据包，是顺序发，乱序收。

    关于TCP和UDP可以展开讨论的话题还有很多，比如最经典的“三次握手”和“四次挥手”，一时半会很难 说完，好在与HTTP的关系不是太大，以后遇到了再详细讲解。

- **协议栈的第四层叫“应用层”(application layer)**，由于下面的三层把基础打得非常好，所以在这一层 就“百花齐放”了，有各种面向具体应用的协议。例如Telnet、SSH、FTP、SMTP等等，当然还有我们的 HTTP。

MAC层的传输单位是帧(frame)，IP层的传输单位是包(packet)，TCP层的传输单位是段 (segment)，HTTP的传输单位则是消息或报文(message)。但这些名词并没有什么本质的区分，可以 统称为数据包。


### OSI七层网络模型分别是哪七层？各运行那些协议？

OSI，全称是“开放式系统互联通信参考模型”(Open System Interconnection Reference Model)。

TCP/IP发明于1970年代，当时除了它还有很多其他的网络协议，整个网络世界比较混乱。

这个时候国际标准组织(ISO)注意到了这种现象，感觉“野路子”太多，就想要来个“大一统”。于是设计出了一个新的网络分层模型，想用这个新框架来统一既存的各种网络协议。

OSI模型分成了七层，部分层次与TCP/IP很像，从下到上分别是:

1. 第一层:物理层，网络的物理形式，例如电缆、光纤、网卡、集线器等等; 
2. 第二层:数据链路层，它基本相当于TCP/IP的链接层;
3. 第三层:网络层，相当于TCP/IP里的网际层;
4. 第四层:传输层，相当于TCP/IP里的传输层;
5. 第五层:会话层，维护网络中的连接状态，即保持会话和同步; 
6. 第六层:表示层，把数据转换为合适、可理解的语法和语义; 
7. 第七层:应用层，面向具体的应用传输数据。


![img/geektime-http-protocol-osi-mapping.png](/img/geektime-http-protocol-osi-mapping.png)



对比一下就可以看出，TCP/IP是一个纯软件的栈，没有网络应有的最根基的电 缆、网卡等物理设备的位置。而OSI则补足了这个缺失，在理论层面上描述网络更加完整。OSI的分层模型在四层以上分的太细，而TCP/IP实际应用时的会话管理、编码转换、压缩等和具体应用经常联系的很紧密，很难分开。例如，HTTP协议就同时包含了连接管理和数据格式定义。

到这里，你应该能够明白一开始那些“某某层”的概念了。

所谓的“四层负载均衡”就是指工作在传输层上，基于TCP/IP协议的特性，例如IP地址、端口号等实现对后 端服务器的负载均衡。

所谓的“七层负载均衡”就是指工作在应用层上，看到的是HTTP协议，解析HTTP报文里的URI、主机名、 资源类型等数据，再用适当的策略转发给后端服务器。



### TCP/IP协议栈的工作方式

HTTP协议的传输过程就是这样通过协议栈逐层向下，每一层都添加本层的专有数据，层层打包，然后通过 下层发送出去。

接收数据是则是相反的操作，从下往上穿过协议栈，逐层拆包，每层去掉本层的专有头，上层就会拿到自己
的数据。

但下层的传输过程对于上层是完全“透明”的，上层也不需要关心下层的具体实现细节，所以就HTTP层次 来看，它不管下层是不是TCP/IP协议，看到的只是一个可靠的传输链路，只要把数据加上自己的头，对方就能原样收到。


![img/geektime-http-protocol-work.png](/img/geektime-http-protocol-work.png)

全景图

![network-osi](/img/network-osi.gif)

| 层 | 协议 |
| ---- | --- |
| 应用层 | DHCP · DNS · FTP · Gopher · HTTP · IMAP4 · IRC · NNTP · XMPP · POP3 · SIP · SMTP ·SNMP · SSH · TELNET · RPC · RTCP · RTP · RTSP · SDP · SOAP · GTP · STUN · NTP · SSDP|
| 表示层 |	HTTP/HTML · FTP · Telnet · ASN.1（具有表示层功能）|
|会话层	| ADSP · ASP · H.245 · ISO-SP · iSNS · NetBIOS · PAP · RPC · RTCP · SMPP · SCP · SSH · ZIP · SDP（具有会话层功能）|
| 传输层	| TCP · UDP · TLS · DCCP · SCTP ·RSVP · PPTP |
| 网络层	| IP (IPv4 · IPv6) · ICMP · ICMPv6 · IGMP · IS-IS · IPsec · BGP · RIP · OSPF · ARP · RARP |
|数据链路层|	Wi-Fi(IEEE 802.11) · WiMAX(IEEE 802.16) · ATM · DTM · 令牌环 · 以太网路 ·FDDI · 帧中继 · GPRS · EVDO · HSPA · HDLC · PPP · L2TP · ISDN · STP|
|物理层|	以太网路卡 · 调制解调器 · 电力线通信(PLC) · SONET/SDH（光同步数字传输网） ·G.709（光传输网络） · 光导纤维 · 同轴电缆 · 双绞线|


