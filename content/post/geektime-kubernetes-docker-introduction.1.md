---
title: "《深入剖析Kubernetes》-k8s网络"
date: 2019-11-27T15:12:03+08:00
lastmod: 2019-11-28T15:12:03+08:00
draft: false
keywords: ["Docker的实现原理","容器","Docker"]
description: ""
tags: ["docker","容器"]
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


Kubernetes 的网络模型假定了所有 Pod 都在一个可以直接连通的扁平的网络空间中，这在 GCE 里面是现成的网络模型，Kubernetes 假定这个网络已经存在。而在私有云里搭建 Kubernetes 集群，就不能假定这个网络已经存在。我们需要自己实现这个网络假设，将不同节点的 Docker 容器之间的互相访问先打通，然后运行 Kubernetes。比如使用 Flannel。

<!--more-->
## 总览

 - 同一个 Pod 的多个容器之间：网卡 io
 - 各 Pod 之间的通讯：Overlay Network(覆盖网络)
 - Pod 与 Service 之间的通讯： 各节点的 Iptables规则（IPVS）

 Flannel 是 CoreOS 团队针对 kubernetes 设计的网络规划服务，简单来说，它的功能是让集群中的不同节点主机创建的 Docker 容器都具有全集群唯一的虚拟 IP 地址。

 etcd 之 Flannel 提供说明:

 - 存储管理 Flannel 可分配的 Ip 地址段资源
 - 监控 etcd 中每个 Pod 的实际地址，并在内存中建立维护 Pod 节点路由表

## 详述
 同一个 Pod 内部通讯：同一个 Pod 共享同一个网络命名空间，共享一个 Linux 协议栈

> Docker 项目会默认在宿主机上创建一个名叫 docker0 的网桥，凡是连接在 docker0 网桥上的容器，就可以通过它来进行通信。

### Pod1 至 Pod2


 - Pod1 与 Pod2 在同一台机器，由 Docker0 网桥直接转发请求至 Pod2，不需要经过 Flannel

同一个宿主机上的不同容器通过 docker0 网桥进行通信的流程如图：

 ![img/geektime-k8s-docker0.png](/img/geektime-k8s-docker0.png)

当一个容器试图连接到另外一个宿主机时,如图：

 ![img/geektime-k8s-docker0-2.png](/img/geektime-k8s-docker0-2.png)



 - Pod1 与 Pod2 不在同一台主机，Pod 的地址是与 docker0 在同一个网段的，但 docker0 网段与宿主机网卡是两个完全不同的 IP 网段，并且不同 Node 之间的通讯只能通过宿主机的物理网卡进行，将 Pod 的 IP 和所在 Node 的 IP 关联起来，通过这个关联让 Pod 可以互相访问

![img/geektime-flannel-udp.png](/img/geektime-flannel-udp.png)

Flannel UDP 模式性能不好，Flannel 后来支持的VXLAN 模式，逐渐成为了主流的容器网络方案。

 Pod 至 Service 的网络：目前基于性能考虑，全部为 iptables 维护和转发

 Pod 到外网：Pod 向外网发送请求，查找路由表，转发数据包到宿主机的网卡，宿主机网卡完成路由选择后，iptables 执行 Masquerade，把源 IP更改为宿主机网卡的 IP，然后向外网服务器发送请求。（SNAT 动态转换）

 外网访问 Pod：Service