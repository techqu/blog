---
title: "OSI七层网络模型分别是哪七层？各运行那些协议？"
date: 2019-02-20T15:29:44+08:00
lastmod: 2019-02-20T15:29:44+08:00
draft: false
keywords: []
description: ""
tags: []
categories: ["网络协议"]
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

<!--more-->

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


> 原文：https://blog.csdn.net/JeremyZJM/article/details/78184775 
