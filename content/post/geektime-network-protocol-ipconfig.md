---
title: "《趣谈网络协议》-Ipconfig"
date: 2019-01-16T18:51:01+08:00
lastmod: 2019-01-16T18:51:01+08:00
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
从一行查看IP地址的命令开始讲解，
Window上是ipconfig，Linux上是ifconfig，和 ip addr

<!--more-->



```shell
root@test:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:c7:79:75 brd ff:ff:ff:ff:ff:ff
    inet 10.100.122.2/24 brd 10.100.122.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fec7:7975/64 scope link 
       valid_lft forever preferred_lft forever
```

这个命令显示了这台机器上所有的网卡。大部分的网卡都会有一个IP地址，当然，这不是必须的。

 如上，`10.100.122.2`就是一个IP地址。这个地址被点分割为四个部分，每个部分8个bit，所以IP地址总共是32位。这样产生的IP地址的数量很快就不够用了。因为不够用，于是就有了IPv6，也就是上面的输出结果里面`inet6 fe80::f816:3eff:fec7:7975/64`。这个有128位，现在看是够用了。

本来就不够用的IP地址就不够，还被分成了5类。

![ip](/img/ip.jpg)
在网络地址中，至少在当时设计的时候，对于 A、B、 C 类主要分两部分，前面一部分是**网络号**，后面一部分是**主机号**。


![ip](/img/ip-category.jpg)

## 无类型域间选路（CIDR）


{{% admonition type="note" title="CIDR" %}}
为了方便表示IP和子网掩码 大佬们想到了一个简单的方法：IP/子网掩码位数 （CIDR表示法）

举例 ：IP为192.168.0.0 子网掩码为255.255.255.0 用CIDR法表示


- step1：先将子网掩码由二进制转换为十进制
- 11111111.11111111.11111111.00000000
- setp2：CIDR表示为：192.168.0.0/24

{{% /admonition %}}

这种方式打破了原来设计的几类地址的做法，将 32 位的 IP 地址一分为二，前面是**网络号**，后面是**主机号**。


伴随CIDR存在的，一个是广播地址（10.100.122.255），另一个是子网掩码（255.255.255.0）。如果发送这个地址，所有 10.100.122 网络里面的机器都可以收到。

在最初的网络里，网络根据ip地址分为的三种类型 而 形成的三个网域 ,这三个网域内的各个机器可以进行方便的访问 但是这一个网域内的机器数目太过庞大 也不便于管理 为了将网域分为更小的范围 ,人们想出来了一种解决方案，正是靠子网掩码来将一个大网域划分为更多的小网域

**子网掩码的计算**：根据IP的网络ID和主机ID就可以得出子网掩码,将网络ID所在的位置全部化为1 将主机ID所在的位数全部化为0

将子网掩码和 IP 地址进行 AND 计算。前面三个 255，转成二进制都是 1。1 和任何数值取 AND，都是原来数值，因而前三个数不变，为 10.100.122。后面一个 0，转换成二进制是 0，0 和任何数值取 AND，都是 0，因而最后一个数变为 0，合起来就是 10.100.122.0。这就是
网络号，将子网掩码和 IP 地址按位计算 AND，就可得到网络号。

## 子网切分

  将主机ID借一位到网络ID上，就可实现切分为两个子网

## 超网划分：

在某些情况下，我们需要将多个小网络合并成一个大网络，每个网络主机ID变多，
网络ID变少，原来的主机ID位向网络ID位借位。其目的是节约路由器的记录数

```
举例：
220.78.10101000.0   168
220.78.10101001.0   169
220.78.10101010.0   170
220.78.10101011.0   171
220.78.10101100.0   172
220.78.10101101.0   173
220.78.10101110.0   174
220.78.10101111.0   175
```
这8个IP地址就可以合并为一个ip来节省路由器的资源，加快访问速度,`220.78.168.0/21`  




## 公有IP和私有IP
{{% admonition type="note" %}}
- publicIP：这种IP地址可以直接连接至Internet
- privateIP：这种ip地址不能直接连接到internet，主要用于规划局域网内的规划

私有IP分别在ABC三类当中各保留一段作为私有ip网段

- classA: 10.0.0.0 -- 10.255.255.255
- classB: 172.16.0.0 --- 172.31.255.255
- classC:192.168.0.0 -- 192.168.255.255

这三段中的ip的地址是无法上网的，只能限于内部网络使用
{{% /admonition %}}
　　与私有IP地址对应的是公有地址（Public address），由Inter NIC（Internet Network Information Center 因特网信息中心）负责。这些IP地址分配给注册并向Inter NIC提出申请的组织机构。通过它直接访问因特网。  　　

　　私有IP的出现是为了解决公有IP地址不够用的情况。从A、B、C三类IP地址中拿出一部分作为私有IP地址，这些IP地址不能被路由到Internet骨干网上，Internet路由器也将丢弃该私有地址。如果私有IP地址想要连至Internet，需要将私有地址转换为公有地址。这个转换过程称为网络地址转换（Network Address Translation，NAT），通常使用路由器来执行NAT转换。

范围如下：

- A: 10.0.0.0~10.255.255.255,即10.0.0.0/8
- B:172.16.0.0~172.31.255.255,即172.16.0.0/12
- C:192.168.0.0~192.168.255.255,即192.168.0.0/16

这五类地址中，还有一类 D 类是 **组播地址**。使用这一类地址，属于某个组的机器都能收到。这有点类似在公司里面大家都加入了一个邮件组。发送邮件，加入这个组的都能收到。组播地址在后面讲述 VXLAN 协议的时候会提到。

在 IP 地址的后面有个 scope，对于 eth0 这张网卡来讲，是 global，说明这张网卡是可以对外的，可以接收来自各个地方的包。对于 lo 来讲，是 host，说明这张网卡仅仅可以供本机相互通信。

**lo 全称是loopback，又称环回接口**，往往会被分配到 127.0.0.1 这个地址。这个地址用于本机通信，经过内核处理后直接返回，不会在任何网络中出现。

## MAC 地址
在 IP 地址的上一行是` link/ether fa:16:3e:c7:79:75 brd ff:ff:ff:ff:ff:ff，`这个被称为**MAC地址**，是一个网卡的物理地址，用十六进制，6 个 byte 表示。

它的唯一性设计是为了组网的时候，不同的网卡放在一个网络里面的时候，可以不用担心冲突。从硬件角度，保证不同的网卡有不同的标识。

所以，MAC 地址的通信范围比较小，局限在一个子网里面。例如，从 `192.168.0.2/24` 访问 `192.168.0.3/24` 是可以用 MAC 地址的。一旦跨子网，即从 `192.168.0.2/24` 到 `192.168.1.2/24`，MAC 地址就不行了，需要 IP 地址起作用了。

## 网络设备的状态标识
解析完了 MAC 地址，我们再来看 `<BROADCAST,MULTICAST,UP,LOWER_UP>` 是干什么的？这个叫作**net_device flags**，**网络设备的状态标识**。

- **UP** 表示网卡处于启动的状态
- **BROADCAST** 表示这个网卡有广播地址，可以发送广播包；
- **MULTICAST** 表示网卡可以发送多播包；
- **LOWER_UP** 表示 L1 是启动的，也即网线插着呢。
- **MTU1500** 是指什么意思呢？是哪一层的概念呢？最大传输单元 MTU 为 1500，这是以太网的默认值。

MTU 是二层 MAC 层的概念。MAC 层有 MAC 的头，以太网规定连 MAC 头带正文合起来，不允许超过 1500 个字节。正文里面有 IP 的头、TCP 的头、HTTP 的头。如果放不下，就需要分片来传输。

`qdisc pfifo_fast` 是什么意思呢？qdisc 全称是 **queueing discipline**,中文叫**排队规则**。内核如果需要通过某个网络接口发送数据包，它都需要按照为这个接口配置的 qdisc（排队规则）把数据包加入队列。

---
## 子网切分的例子

1. 已知：

  - IP地址：172.16.100.200
  - 子网掩码：255.255.224.0

2. 用CIDR表示：

```
  step1：将子网掩码由二进制转换为十进制
              255.255.224.0
              11111111.11111111.11100000.00000000
  step2：CIDR表示为
              172.16.100.200/19
```

3. 网络ID是多少

```
step1：将IP地址由二进制转换为十进制
            10101100.00010000.01100100.11001000
step2：将二进制的IP地址与二进制的子网掩码进行运算 子网掩码为1时保留原IP位 否则为0
            1 0 1 0 1 1 0 0 .0 0 0 1 0 0 0 0. 0 1 1 0 0 1 0 0. 1 1 0 0 1 0 0 0
            1 1 1 1 1 1 1 1. 1 1 1 1 1 1 1 1. 1 1 1 0 0 0 0 0. 0 0 0 0 0 0 0 0
        =   1 0 1 0 1 1 0 0 .0 0 0 1 0 0 0 0. 0 1 1 0 0 0 0 0. 0 0 0 0 0 0 0 0
step3:将二进制的结果转换为十进制
            172.16.96.0/19
```

4. 网络主机数有多少

```
num=2^(32-19)-2
```

5. 网络主机的范围是多少

```
step1：将长度为子网掩码为1的数IP记录下来（即网络ID）
            1 0 1 0 1 1 0 0 .0 0 0 1 0 0 0 0. 0 1 1 x x x x x . x x x x x x x x
            1 1 1 1 1 1 1 1. 1 1 1 1 1 1 1 1. 1 1 1 
step2：将x全部变为0即最小值 将x全部变为1即最大值
            1 0 1 0 1 1 0 0 .0 0 0 1 0 0 0 0. 0 1 1 0 0 0 0 0.0
            1 0 1 0 1 1 0 0 .0 0 0 1 0 0 0 0. 0 1 1 x 1 1 1 1 .255
step3：将二进制的结果转换为十进制（ip的最后一组不能为0和255）
            最小值：172.16.96.1
            最大值：172.16.177.254
```

## 附

课程所有协议

![所有协议](/img/geektime-network-protocol.png)

> 参考文章：https://time.geekbang.org/column/article/7772