---
title: "kubernetes Install"
date: 2019-09-15T10:45:17+08:00
lastmod: 2019-09-15T10:45:17+08:00
draft: false
keywords: []
description: ""
tags: ["kubernetes"]
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
公司服务器上的 k8s 集群不给自己玩了，所以打算在本地mac 上装 kubernestes 集群 ，记录下使用 docker 的 mac 客户端 安装 kubernetets 的过程


<!--more-->

前半部分内容来自 https://github.com/AliyunContainerService/k8s-for-docker-desktop

### 一、Docker Desktop for Mac/Windows 开启 Kubernetes

1. 需安装 Docker Desktop 的 Mac 或者 Windows 版本，如果没有请下载[下载 Docker CE最新版本](https://hub.docker.com/?overlay=onboarding)

2. 为 Docker daemon 配置镜像加速，参考[阿里云镜像服务（需登录）](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors) 或中科大镜像加速地址 https://docker.mirrors.ustc.edu.cn

3. 可选操作: 为 Kubernetes 配置 CPU 和 内存资源，建议分配 4GB 或更多内存。

    ![docker-enable-k8s-resource](/img/docker-enable-k8s-resource.png)


4. 预先从阿里云Docker镜像服务下载 Kubernetes 所需要的镜像, 可以通过修改 images.properties 文件加载你自己需要的镜像

```
./load_images.sh
```
5. 开启 Kubernetes，并等待 Kubernetes 开始运行

    ![docker-enable-k8s](/img/docker-enable-k8s.png)

> TIPS：如果在Kubernetes部署的过程中出现问题，可以通过docker desktop应用日志获得实时日志信息：
```
pred='process matches ".*(ocker|vpnkit).*"
  || (process in {"taskgated-helper", "launchservicesd", "kernel"} && eventMessage contains[c] "docker")'
/usr/bin/log stream --style syslog --level=debug --color=always --predicate "$pred"
```



### 二、多个k8s集群kubectl使用

多个k8s集群最简单分别访问方法:只适用于 mac||linux ；win实现方法也大同小异

1. 如果没有kubectl，需要下载kubectl命令 ：
   - 1.8版本：curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/darwin/amd64/kubectl
   - 1.9版本：curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.1/bin/darwin/amd64/kubectl

2. +执行权限 && 命令移到环境变量目录里
```
    chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
```

3. 查看.kube目录在不在；没则创建，有就AssertionError略过
```
    python -c "import os;assert str(os.path.exists('$HOME/.kube/')) is 'False'" && mkdir $HOME/.kube
```
4. 把k8s的kubectl配置文件config重命名成config_xx后放入本地的$HOME/.kube/目录下
```
    cp config_xx $HOME/.kube/
```

5. alias本地kubectl命令;添加以下别名函数

```
sudo vim /etc/bashrc
```

```
    function kubectl-ali {
    cat $HOME/.kube/config_xx > $HOME/.kube/config
    kubectl $*
    }

    function kubectl-test {
    cat $HOME/.kube/config_xxx > $HOME/.kube/config
    kubectl $*
    }
```



6. 终端测试
```
    kubectl-ali get node

   kubectl-test  get node
```

