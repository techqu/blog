---
title: "《趣谈网络协议》- Https"
date: 2019-08-23T11:44:25+08:00
lastmod: 2019-08-23T11:44:25+08:00
draft: false
keywords: []
description: ""
tags: ["《趣谈网络协议》"]
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

<!--more-->

### 对称加密

### 非对称加密

### 数字证书
不对称加密也有有同样的问题，如何将不对称加密的公钥给对方呢？一种是放在一个公网的地址上，让对方下载；另一个就是在建立连接的时候传给对方。

这两种方法有相同的问题，那就是，作为一个普通网民，你怎么鉴别别人给你的公钥是对的。

例如，我搭建了一个网站cliu8site，可以通过这个命令先创建私钥。

{{< highlight bash>}}
openssl genrsa -out cliu8siteprivate.key 1024
{{< /highlight >}}
然后，再根据这个私钥，创建对应的公钥。

{{< highlight bash>}}
openssl rsa -in cliu8siteprivate.key -pubout -outcliu8sitepublic.pem
{{< /highlight >}}

这个是时候就需要权威部门的介入了。这个由权威部门颁发的称为证书。

证书里有公钥，证书的所有者；发布机构和证书有效期。生成证书需要发起一个证书请求，然后将这个请求发给一个权威机构去认证，这个权威机构我们称为CA（Certficate Authority）

权威机构给证书签名的命令是这样的。

{{< highlight bash>}}
openssl x509 -req -in cliu8sitecertificate.req -CA cacertificate.pem -CAkey caprivate.key -out cliu8sitecertificate.pem
{{< /highlight >}}

这个命令会返回 Signature ok,而 cliu8sitecertificate.pem就是签过名的证书。CA用自己的私钥给网站的公钥签名，就相当于给这个网站背书，形成了这个网站的证书。

我们来看这个证书的内容

{{< highlight bash>}}
openssl x509 -in cliu8sitecertificate.pem -noout -text 
{{< /highlight >}}

- Issuer:证书是谁颁发的
- Subject:证书颁发给谁
- Validity: 证书期限
- Public-key：公钥内容
- Signature Alogrithm：是签名算法

这下好了，你不是从网站上得到一个公钥，而是会得到一个证书，这个证书有个发布机构CA，你只要得到这个发布机构CA的公钥，去解密网站证书的签名，如果解密成功了，Hash也对的上，就说明这个网站的公钥没有问题。

### https的工作模式

**公钥私钥用于传输对称加密的秘钥，而真正的双方大数据量的通信都是通过对称加密进行的。**

如下图所示

![img/geektime-network-https.jpg](/img/geektime-network-https.jpg)

当你登录一个外卖网站的时候，由于是HTTPS，客户端会发送Client Hello消息到服务器，以明文传输TLS版本信息、加密套件候选列表、压缩算法候选列表等信息。另外，还会有一个随机数，在协商加密密钥的时候使用。

然后，外卖网站返回Server Hello消息，告诉客户端，服务器选择使用的协议版本、加密套件、压缩算法等，还有一个随机数，用于后续的密钥协商。

然后外卖网站会给你一个服务器端的证书，然后说：“Server Hello Done”，我这里就这些信息了。

你当然不信这个证书，于是从自己信任的CA仓库中，拿CA的证书里面的公钥去解密外卖网站的证书。如果能够成功，则说明外卖网站是可信的。

这个过程中，你可能会不断往上追溯CA、CA的CA等，反正直到一个授信的CA就可以了。

证书验证完毕之后，觉得这外卖网站可信，于是客户端计算产生随机数字Pre-master,发送Client Key Exchange，用证书中的公钥加密，再发送给服务器，服务器可以通过私钥解密出来。

到目前为止，无论是客户端还是服务端，都有了三个随机数，分别是：自己的对端的，以及刚生成的Pre-Master随机数。通过这三个随机数，可以在客户端和服务器产生相同的对称密钥。

有了对称密钥，客户端就可以说：“Change Cipher Spec，咱们以后都采用协商的通信密钥和加密算法进行加密通信了”

然后发送一个 Encrypted Handshake Message，将已经商定好的参数等，采用协商密钥进行加密，发送给服务器用于数据与握手验证。

同样，服务器也可以发送Change Cipher Spec，说：“没问题，咱们以后都采用协议的通信密钥和加密算法进行加密通信”，并且也发送 Encrypted Handshake Message的消息试试。当双方握手结束之后，就可以通过对称密钥进行加密传输了。

这个过程除了加密解密之外，其他的过程和HTTP是一样的，过程也非常复杂。

上面的过程只包含了HTTPS的单向认证，也即客户端验证服务端的证书，是大部分的场景，也可以在更加严格安全要求的情况下，启用双向认证，双方互相验证证书。