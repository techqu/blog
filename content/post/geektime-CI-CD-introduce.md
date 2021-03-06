---
title: "《持续交付》"
date: 2019-04-19T15:23:49+08:00
lastmod: 2019-04-19T15:23:49+08:00
draft: false
keywords: []
description: ""
tags: ["devops"]
categories: ["Tech"]
author: "瞿广"

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: false
toc: true
autoCollapseToc: true
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

## 持续交付到底有什么价值

持续交付是软件研发人员，如何将一个好点子，以最快的速度交付给用户的方法。我们可以把 “持续交付”定义为“一套软件工程方法论和许许多多的最佳实践的集合”。

### 持续集成、持续交付和持续部署的关系

我们通常会把软件研发工作拆解，拆分成不同模块或不同团队后进行编码，编码完成后，进行集成构建和测试。这个从编码到构建再到测试的反复持续过程，就叫作“持续集成”。

这个在“持续集成”之后，获取外部对软件的反馈再通过“持续集成”进行优化的过程就叫作“持续交付”，它是“持续集成”的自然延续。

而“持续部署”就是将可交付产品，快速且安全地交付用户使用的一套方法和系统，它是“持续交付”的最后“一公里”。


持续交付的价值不仅仅局限于简单地提高产品交付的效率，它还通过统一标准、规范流程、工具化、自动化等等方式，影响着整个研发生命周期。

## 影响持续交付的因素有哪些？

与绝大多数理论分析一样，影响持续交付的因素也可归结为:人(组织和文化)，事(流程)， 物(架构)。

## 持续交付和Devops
DevOps 的概念一直在向外延伸，包括了:运营和用户，以及快速、良好、及时的 反馈机制等内容，已经超出了“持续交付”本身所涵盖的范畴。而持续交付则一直被视作 DevOps的核心实践之一被广泛谈及。

### 认识DevOps
目前，人们对DevOps的看法，可以大致概括为DevOps是一组技术，一个职能、一种文 化，和一种组织架构四种。

- 第一，DevOps是一组技术，包括:自动化运维、持续交付、高频部署、Docker等内容。
- 第二，DevOps是一个职能，这也是我在各个场合最常听到的观点。
- 第三，DevOps是一种文化，推倒Dev与Ops之间的阻碍墙。
- 第四，DevOps是一种组织架构，将Dev和Ops置于一个团队内，一同工作，同化目标，以 达到 DevOps文化地彻底贯彻。

## 一切的源头，代码分支策略的选择

### 谈谈主干开发（TBD）

主干开发是一个源代码控制的分支模型，开发者在一个称为 “trunk” 的分支(Git 称
master) 中对代码进行协作，除了发布分支外没有其他开发分支。

### 谈谈特性分支开发
和主干开发相对的是 “特性分支开发” 。在这个大类里面，我会给你分析Git Flow、GitHub Flow 和 GitLab Flow这三个常用的模型。


#### Git Flow

#### GitHub Flow
GitHub Flow 是 GitHub 所使用的一种简单流程。该流程只使用master和特性分支，并借助 GitHub 的 pull request 功能。

在 GitHub Flow 中，master 分支中包含稳定的代码，它已经或即将被部署到生产环境。
任何开发人员都不允许把未测试或未审查的代码直接提交到 master 分支。对代码的任何 修改，包括Bug 修复、热修复、新功能开发等都在单独的分支中进行。不管是一行代码的 小改动，还是需要几个星期开发的新功能，都采用同样的方式来管理。

GitHub Flow 的好处在于非常简单实用，开发人员需要注意的事项非常少，很容易形成习惯。当 需要修改时，只要从 master 分支创建新分支，完成之后通过 pull request 和相关的代码审查， 合并回 master 分支就可以了

#### GitLab Flow
上面提到的GitHub Flow，适用于特性分支合入master后就能马上部署到线上的这类项目，但并不是所有团队都使用GitHub或使用pull request功能，而是使用开源平台GitLab，特别是对于公 司级别而言，代码作为资产，不会随意维护在较公开的GitHub上

GitLab Flow 针对不同的发布场景，在GitHub Flow(特性分支加master分支)的基础上做了改 良，额外衍生出了三个子类模型

带生产分支

1. 无法控制准确的发布时间，但又要求不停集成的。 
2. 需要创建一个production分支来放置发布的代码。

带环境分支

1. 要求所有代码都在逐个环境中测试通过。 
2. 需要为不同的环境建立不同的分支。

带发布分支

1. 用于对外界发布软件的项目，同时需要维护多个发布版本。 
2. 尽可能晚地从master拉取发布分支。
3. Bug的修改应先合并到master，然后cherry pick到release分支


特性分支的优点：
1. 不同功能可以在独立的分支上做开发，消除了功能稳 定前彼此干扰的问题。
2. 容易保证主干分支的质量:只要不把没开发好的特性 分支合入主干分支，那么主干分支就不会带上有问题的 功能。

特性分支的缺点：
1. 如果不及时做merge，那么 把特性分支合到主干分支会比 较麻烦。
2. 如果要做CI/CD，需要对不同 分支配备不同的构建环境。


|序号|情况|适合的分支策略|
| --- | --- | --- |
|1|开发团队系统设计和开发能力强。 有一套有效的特性切换的实施机制，保证上线后无需修改代 码就能够修改系统行为。 需要快速迭代，想获得CI/CD所有好处。|主干开发|
|2|不具备主干开发能力。有预定的发布周期。需要执行严格的发布流程。|Git Flow|
|3|不具备主干开发能力。 随时集成随时发布:分支集成后经过代码评审和自动化测 试，就可以立即发布的应用。|GitHub Flow|
|4|不具备主干开发能力。 无法控制准确的发布时间，但又要求不停集成。|GitLab Flow(带 生产分支)|
|5|不具备主干开发能力。需要逐个通过各个测试环境验证。|GitLab Flow(带 环境分支)|
|6|不具备主干开发能力。需要对外发布和维护不同版本。|GitLab Flow(带 发布分支)|

## 手把手教你依赖管理

### Maven

Maven 的依赖仲裁原则如下。

第一原则: 最短路径优先原则。 比如，A 依赖了 B和C，而 B 也依赖了 C，那么 Maven 会使 用 A 依赖的 C 的版本，因为它的路径是最短的。

第二原则: 第一声明优先原则。 比如，A 依赖了 B和C，B 和 C 分别依赖了 D，那么 Maven 会使用 B 依赖的 D 的版本，因为它是最先声明的。

Maven 最佳实践：

1. 生产环境尽量不使用 SNAPSHOT或者是带有范围的依赖版本，可以减少上线后的不确定 性，我们必须保证，测试环境的包和生产环境是一致的。
2. 将 POM分成多个层次的继承关系
3. 在父模块多使用 dependencyManagement 来定义依赖，子模块在使用该依赖时，就可以不 用指定依赖的版本，这样做可以使多个子模块的依赖版本高度统一，同时还能简化子模块配 置。
4. 对于一组依赖的控制，可以使用BOM(Bill of Materials) 进行版本定义。一般情况下，框架 部门有一个统一的BOM 来管理公共组件的版本，当用户引用了该BOM后，在使用框架提供 的组件时无需指定版本。即使使用了多个组件，也不会有版本冲突的问题，因为框架部门的 专家们已经在BOM中为各个组件配置了经过测试的稳定版本。 BOM是一个非常有用的工具，因为面对大量依赖时，作为用户你不知道具体应该使用它们 的哪些版本、这些版本之间是否有相互依赖、相互依赖是否有冲突，使用BOM 就可以让用 户规避这些细节问题了。
5. 对于版本相同的依赖使用 properties 定义，可以大大减少重复劳动，且易于改动。上面的 pom.xml 片段，就是使用了 properties 来定义两个一样的版本号的依赖。
6. 不要在在线编译环境中使用 mvn install 命令，否则会埋下很多意想不到并且非常难以排查的 坑:该命令会将同项目中编译产生的jar包缓存在编译系统本地，覆盖mvn仓库中真正应该被 引用的jar包。
7. 禁止变更了代码不改版本号就上传到中央仓库的行为。否则，会覆盖原有版本，使得一个版 本出现二义性的问题。

## 代码回滚

### 1. 个人分支回滚



```shell
$ git checkout feature-x   
$ git reset --hard  C3的HASH值
```

如果feature-x已经push到远端代码平台了，则远端分支也需要回滚：

```shell
$ git push -f origin  feature-x
```

### 第二，集成分支上线前回滚

针对图2中集成分支上线前的情况说明：

假定走特性分支开发模式，上面的commit都是特性分支通过merge request合入 master 产生的commit。

集成后，测试环境中发现C4和C6的功能有问题，不能上线，需马上回滚代码，以便 C5 的功能上线。

团队成员可以在 GitLab 上找到C4和C6合入master的合并请求，然后点击 revert 。如图4所示。