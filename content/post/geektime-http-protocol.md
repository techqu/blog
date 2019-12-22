---
title: "《透视HTTP协议》-https"
date: 2019-08-22T13:57:16+08:00
lastmod: 2019-08-22T13:57:16+08:00
draft: false
keywords: []
description: ""
tags: ["透视HTTP协议"]
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

<!--more-->
什么是HTTPS?

HTTPS凭什么就能做到机密性、完整性这些安全特性呢?

秘密就在于HTTPS名字里的“S”，它把HTTP下层的传输协议由TCP/IP换成了SSL/TLS，由“HTTP over TCP/IP”变成了“HTTP over SSL/TLS”，让HTTP运行在了安全的SSL/TLS协议上(可参考第4讲和第5讲)， 收发报文不再使用Socket API，而是调用专门的安全接口

![protocol-http](/img/geektime-http-protocol-ssl.png)

### SSL/TLS
你可以看到，实验环境使用的TLS是1.2，客户端和服务器都支持非常多的密码套件，而最后协商选定的 是“ECDHE-RSA-AES256-GCM-SHA384”。

这么长的名字看着有点晕吧，不用怕，其实TLS的密码套件命名非常规范，格式很固定。基本的形式是“密 钥交换算法+签名算法+对称加密算法+摘要算法”，比如刚才的密码套件的意思就是:

“握手时使用ECDHE算法进行密钥交换，用RSA签名和身份认证，握手后的通信使用AES对称算法，密钥长 度256位，分组模式是GCM，摘要算法SHA384用于消息认证和产生随机数。”

### OpenSSL

说到TLS，就不能不谈到OpenSSL，它是一个著名的开源密码学程序库和工具包，几乎支持所有公开的加密 算法和协议，已经成为了事实上的标准，许多应用软件都会使用它作为底层库来实现TLS功能，包括常用的 Web服务器Apache、Nginx等。