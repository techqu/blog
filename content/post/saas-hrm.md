---
title: "传统Saas项目实例"
date: 2019-07-15T10:32:05+08:00
lastmod: 2019-07-15T10:32:05+08:00
draft: false
keywords: []
description: ""
tags: ["saas"]
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

一个实际的saas项目的例子

<!--more-->

## 一、初识SaaS

### 云服务的三种模式 iaas、Paas、Saas


## 二、系统架构

![saas-hrm-structure](/img/saas-hrm-structure.png)


### 分布式ID生成器

## 三、SaaS系统用户权限设计
### 多租户SaaS平台的数据库方案

### 多租户是什么
多租户技术(Multi-TenancyTechnology)又称多重租赁技术:是一种软件架构技术，是实现如何在多用户环境下 (此处的多用户一般是面向企业用户)共用相同的系统或程序组件，并且可确保各用户间数据的隔离性。简单讲: 在一台服务器上运行单个应用实例，它为多个租户(客户)提供服务。从定义中我们可以理解:多租户是一种架 构，目的是为了让多用户环境下使用同一套程序，且保证用户间数据隔离。那么重点就很浅显易懂了，多租户的重 点就是同一套程序下实现多用户数据的隔离

### 需求分析
传统软件模式，指将软件产品进行买卖，是一种单纯的买卖关系，客户通过买断的方式获取软件的使用权，软件的
源码属于客户所有，因此传统软件是部署到企业内部，不同的企业各自部署一套自己的软件系统
Saas模式，指服务提供商提供的一种软件服务，应用统一部署到服务提供商的服务器上，客户可以根据自己的实际 需求按需付费。用户购买基于WEB的软件，而不是将软件安装在自己的电脑上，用户也无需对软件进行定期的维护 与管理


在SaaS平台里需要使用共用的数据中心以单一系统架构与服务提供多数客户端相同甚至可定制化的服务，并且仍可 以保障客户的数据正常使用。由此带来了新的挑战，就是如何对应用数据进行设计，以支持多租户，而这种设计的 思路，是要在数据的共享、安全隔离和性能间取得平衡。


### 多租户的数据库方案分析

目前基于多租户的数据库设计方案通常有如下三种:

- 独立数据库 
- 共享数据库、独立 Schema 
- 共享数据库、共享数据表

#### 独立数据库


独立数据库:每个租户一个数据库。

- 优点:为不同的租户提供独立的数据库，有助于简化数据模型的扩展设计，满足不同租户的独特需求;如果 出现故障，恢复数据比较简单。
- 缺点: 增多了数据库的安装数量，随之带来维护成本和购置成本的增加

这种方案与传统的一个客户、一套数据、一套部署类似，差别只在于软件统一部署在运营商那里。由此可见此方案
用户数据隔离级别最高，安全性最好，但是成本较高

#### 共享数据库、独立 Schema

共享数据库、独立 Schema:即多个或所有的租户使用同一个数据库服务(如常见的ORACLE或MYSQL数据库)， 但是每个租户一个Schema。

- 优点: 为安全性要求较高的租户提供了一定程度的逻辑数据隔离，并不是完全隔离;每个数据库可支持更多 的租户数量。
- 缺点: 如果出现故障，数据恢复比较困难，因为恢复数据库将牵涉到其他租户的数据; 如果需要跨租户统计 数据，存在一定困难。

这种方案是方案一的变种。只需要安装一份数据库服务，通过不同的Schema对不同租户的数据进行隔离。由于数 据库服务是共享的，所以成本相对低廉。
##### 共享数据库、共享数据表 
共享数据库、共享数据表:即租户共享同一个Database，同一套数据库表(所有租户的数据都存放在一个数据库
的同一套表中)。在表中增加租户ID等租户标志字段，表明该记录是属于哪个租户的。 

- 优点:所有租户使用同一套数据库，所以成本低廉。
- 缺点:隔离级别最低，安全性最低，需要在设计开发时加大对安全的开发量，数据备份和恢复最困难。
这种方案和基于传统应用的数据库设计并没有任何区别，但是由于所有租户使用相同的数据库表，所以需要做好对每个租户数据的隔离安全性处理，这就增加了系统设计和数据管理方面的复杂程度。


采用共享数据库、共享数据表的方式设计


### 数据库设计与建模

#### 数据库设计的三范式

三范式: 
1. 第一范式(1NF):确保每一列的原子性(做到每列不可拆分)
2. 第二范式(2NF):在第一范式的基础上，非主字段必须依赖于主字段(一个表只做一件事)
3. 第三范式(3NF):在第二范式的基础上，消除传递依赖
反三范式:
反三范式是基于第三范式所调整的，没有冗余的数据库未必是最好的数据库，有时为了提高运行效率，就必须降低
范式标准，适当保留冗余数据。

### 建模工具
对于数据模型的建模，最有名的要数PowerDesigner，PowerDesigner是在中国软件公司中非常有名的，其易用 性、功能、对流行技术框架的支持、以及它的模型库的管理理念，都深受设计师们喜欢。他的优势在于:不用在使 用create table等语句创建表结构，数据库设计人员只关注如何进行数据建模即可，将来的数据库语句，可以自动 生成



## 四、权限管理与jwt鉴权

### 什么是RBAC
RBAC(全称:Role-Based Access Control)基于角色的权限访问控制，作为传统访问控制(自主访问，强制访 问)的有前景的代替受到广泛的关注。在RBAC中，权限与角色相关联，用户通过成为适当角色的成员而得到这些 角色的权限。这就极大地简化了权限的管理。在一个组织中，角色是为了完成各种工作而创造，用户则依据它的责 任和资格来被指派相应的角色，用户可以很容易地从一个角色被指派到另一个角色。角色可依新的需求和系统的合 并而赋予新的权限，而权限也可根据需要而从某角色中回收。角色与角色的关系可以建立起来以囊括更广泛的客观 情况。
访问控制是针对越权使用资源的防御措施，目的是为了限制访问主体(如用户等) 对访问客体(如数据库资源等) 的访问权限。企业环境中的访问控制策略大部分都采用基于角色的访问控制(RBAC)模型，是目前公认的解决大 型企业的统一资源访问控制的有效方法

### 基于RBAC的设计思路
基于角色的访问控制基本原理是在用户和访问权限之间加入角色这一层，实现用户和权限的分离，用户只有通过激
活角色才能获得访问权限。通过角色对权限分组，大大简化了用户权限分配表，间接地实现了对用户的分组，提高
了权限的分配效率。且加入角色层后，访问控制机制更接近真实世界中的职业分配，便于权限管理。


![saas-hrm-rbac](/img/saas-hrm-rbac.png)


在RBAC模型中，角色是系统根据管理中相对稳定的职权和责任来划分，每种角色可以完成一定的职能。用户通过 饰演不同的角色获得角色所拥有的权限，一旦某个用户成为某角色的成员，则此用户可以完成该角色所具有的职 能。通过将权限指定给角色而不是用户，在权限分派上提供了极大的灵活性和极细的权限指定粒度。

### 表结构分析

![saas-hrm-rbac-tb1](/img/saas-hrm-rbac-tb1.png)

**一个用户拥有若干角色，每一个角色拥有若干权限。这样，就构造成“用户-角色-权限”的授权模型。在这种模型 中，用户与角色之间，角色与权限之间，一般者是多对多的关系。**

### 需求分析
####  SAAS平台的基本元素
- SAAS平台管理员:负责平台的日常维护和管理，包括用户日志的管理、租户账号审核、租户状态管理、租户费用 的管理，要注意的是平台管理员不能对租户的具体业务进行管理
- 企业租户:指访问SaaS平台的用户企业，在SaaS平台中各租户之间信息是独立的。 
- 租户管理员:为租户角色分配权限和相关系统管理、维护。 
- 租户角色:根据业务功能租户管理员进行角色划分，划分好角色后，租户管理员可以对相应的角色进行权限分配 租户用户:需对租户用户进行角色分配，租户用户只能访问授权的模块信息。


在应用系统中，权限是以什么样的形式展现出来的?对菜单的访问，页面上按钮的可见性，后端接口的控制，都要
进行充分考虑 

  前端

- 前端菜单:根据是否有请求菜单权限进行动态加载 （菜单权限）
- 按钮:根据是否具有此权限点进行显示/隐藏的控制（功能权限）

  后端

- 前端发送请求到后端接口，有必要对接口的访问进行权限的验证（api权限）

#### 权限设计进阶

针对这样的需求，在有些设计中可以将菜单，按钮，后端API请求等作为资源，这样就构成了基于RBAC的另一种授
权模型(用户-角色-权限-资源)。在SAAS-HRM系统的权限设计中我们就是才用了此方案

![saas-hrm-rbac-tb2](/img/saas-hrm-rbac-tb2.png)


针对此种权限模型，其中权限究竟是属于菜单，按钮，还是API的权限呢?那就需要在设计数据库权限表的时候添 加类型加以区分(如权限类型 1为菜单 2为功能 3为API)。

![saas-hrm-rbac-tb3](/img/saas-hrm-rbac-tb3.png)

## 常见的认证机制

### HTTP Basic Auth

HTTP Basic Auth简单点说明就是每次请求API时都提供用户的username和password，简言之，Basic Auth是配合 RESTful API 使用的最简单的认证方式，只需提供用户名密码即可，但由于有把用户名密码暴露给第三方客户端的 风险，在生产环境下被使用的越来越少。因此，在开发对外开放的RESTful API时，尽量避免采用HTTP Basic Auth

### Cookie Auth

Cookie认证机制就是为一次请求认证在服务端创建一个Session对象，同时在客户端的浏览器端创建了一个Cookie 对象;通过客户端带上来Cookie对象来与服务器端的session对象匹配来实现状态管理的。默认的，当我们关闭浏 览器的时候，cookie会被删除。但可以通过修改cookie 的expire time使cookie在一定时间内有效

### OAuth

OAuth(开放授权)是一个开放的授权标准，允许用户让第三方应用访问该用户在某一web服务上存储的私密的资 源(如照片，视频，联系人列表)，而无需将用户名和密码提供给第三方应用。 OAuth允许用户提供一个令牌，而 不是用户名和密码来访问他们存放在特定服务提供者的数据。每一个令牌授权一个特定的第三方系统(例如，视频 编辑网站)在特定的时段(例如，接下来的2小时内)内访问特定的资源(例如仅仅是某一相册中的视频)。这样， OAuth让用户可以授权第三方网站访问他们存储在另外服务提供者的某些特定信息，而非所有内容

![saas-hrm-oauth](/img/saas-hrm-oauth.png)

这种基于OAuth的认证机制适用于个人消费者类的互联网产品，如社交类APP等应用，但是不太适合拥有自有认证 权限管理的企业应用。

### Token Auth

使用基于 Token 的身份验证方法，在服务端不需要存储用户的登录记录。大概的流程是这样的:

1. 客户端使用用户名跟密码请求登录
2. 服务端收到请求，去验证用户名与密码
3. 验证成功后，服务端会签发一个 Token，再把这个 Token 发送给客户端
4. 客户端收到 Token 以后可以把它存储起来，比如放在 Cookie 里
5. 客户端每次向服务端请求资源的时候需要带着服务端签发的 Token
6. 服务端收到请求，然后去验证客户端请求里面带着的 Token，如果验证成功，就向客户端返回请求的数据

![saas-hrm-token-auth](/img/saas-hrm-token-auth.png)

Token Auth的优点

- 支持跨域访问: Cookie是不允许垮域访问的，这一点对Token机制是不存在的，前提是传输的用户认证信息通 过HTTP头传输.
- 无状态(也称:服务端可扩展行):Token机制在服务端不需要存储session信息，因为Token 自身包含了所有登 录用户的信息，只需要在客户端的cookie或本地介质存储状态信息.
- 更适用CDN: 可以通过内容分发网络请求你服务端的所有资料(如:javascript，HTML,图片等)，而你的服 务端只要提供API即可.
- 去耦: 不需要绑定到一个特定的身份验证方案。Token可以在任何地方生成，只要在你的API被调用的时候，你 可以进行Token生成调用即可.
- 更适用于移动应用: 当你的客户端是一个原生平台(iOS, Android，Windows 8等)时，Cookie是不被支持的 (你需要通过Cookie容器进行处理)，这时采用Token认证机制就会简单得多。 CSRF:因为不再依赖于Cookie，所以你就不需要考虑对CSRF(跨站请求伪造)的防范。
- 性能: 一次网络往返时间(通过数据库查询session信息)总比做一次HMACSHA256计算 的Token验证和解析 要费时得多.
- 不需要为登录页面做特殊处理: 如果你使用Protractor 做功能测试的时候，不再需要为登录页面做特殊处理. 基于标准化:你的API可以采用标准化的 JSON Web Token (JWT). 这个标准已经存在多个后端库(.NET, Ruby, Java,Python, PHP)和多家公司的支持(如:Firebase,Google, Microsoft).

## HRM中的TOKEN签发与验证

### 什么是JWT

JSON Web Token(JWT)是一个非常轻巧的规范。这个规范允许我们使用JWT在用户和服务器之间传递安全可靠的 信息。在Java世界中通过JJWT实现JWT创建和验证。


## 第5章 权限管理与Shiro入门

### 基于JWT的API鉴权

#### 基于拦截器的token与鉴权
如果我们每个方法都去写一段代码，冗余度太高，不利于维护，那如何做使我们的代码看起来更清爽呢?我们可以
将这段代码放入拦截器去实现
#### Spring中的拦截器
Spring为我们提供了`org.springframework.web.servlet.handler.HandlerInterceptorAdapter`这个适配器，继承此 类，可以非常方便的实现自己的拦截器。他有三个方法:**分别实现预处理、后处理(调用了Service并返回 ModelAndView，但未进行页面渲染)、返回处理(已经渲染了页面)**

1. 在preHandle中，可以进行编码、安全控制等处理; 
2. 在postHandle中，有机会修改ModelAndView; 
3. 在afterCompletion中，可以根据ex是否为null判断是否发生了异常，进行日志记录。

###  签发用户API权限
在系统微服务的 `com.ihrm.system.controller.UserController` 修改签发token的登录服务添加API权限


### 3.3 拦截器中鉴权



### Shiro安全框架

 什么是Shiro

 Apache Shiro是一个强大且易用的Java安全框架,执行身份验证、授权、密码和会话管理。使用Shiro的易于理解的
API,您可以快速、轻松地获得任何应用程序,从最小的移动应用程序到最大的网络和企业应用程序。
Apache Shiro 的首要目标是易于使用和理解。安全有时候是很复杂的，甚至是痛苦的，但它没有必要这样。框架 应该尽可能掩盖复杂的地方，露出一个干净而直观的 API，来简化开发人员在使他们的应用程序安全上的努力。以 下是你可以用 Apache Shiro 所做的事情:
验证用户来核实他们的身份
对用户执行访问控制，如:
判断用户是否被分配了一个确定的安全角色
判断用户是否被允许做某事
在任何环境下使用 Session API，即使没有 Web 或 EJB 容器。 在身份验证，访问控制期间或在会话的生命周期，对事件作出反应。 聚集一个或多个用户安全数据的数据源，并作为一个单一的复合用户“视图”。 启用单点登录(SSO)功能。
为没有关联到登录的用户启用"Remember Me"服务
 
4.1.2 与Spring Security的对比
Shiro:
Shiro较之 Spring Security，Shiro在保持强大功能的同时，还在简单性和灵活性方面拥有巨大优势。

1. 易于理解的 Java Security API;
2. 简单的身份认证(登录)，支持多种数据源(LDAP，JDBC，Kerberos，ActiveDirectory 等); 
3. 对角色的简单的签权(访问控制)，支持细粒度的签权;
4. 支持一级缓存，以提升应用程序的性能;
5. 内置的基于 POJO 企业会话管理，适用于 Web 以及非 Web 的环境;
6. 异构客户端会话访问;
7. 非常简单的加密 API;
8. 不跟任何的框架或者容器捆绑，可以独立运行

Spring Security:
除了不能脱离Spring，shiro的功能它都有。而且Spring Security对Oauth、OpenID也有支持,Shiro则需要自己手
动实现。Spring Security的权限细粒度更高。

![saas-hrm-JWT和Shiro认证授权的比较](/img/saas-hrm-JWT和Shiro认证授权的比较.png)

## 第7章 POI报表的入门

POI报表的概述

在企业级应用开发中，Excel报表是一种最常见的报表需求。Excel报表开发一般分为两种形式: 为了方便操作，基于Excel的报表批量上传数据
通过java代码生成Excel报表。 在Saas-HRM系统中，也有大量的报表操作，那么接下来的课程就是一起来学习企业级的报表开发。


![saas-hrm-excel0307](/img/saas-hrm-excel0307.png)


 常见excel操作工具

 Java中常见的用来操作Excl的方式一般有2种:JXL和POI。

- JXL只能对Excel进行操作,属于比较老的框架，它只支持到Excel 95-2000的版本。现在已经停止更新和维护。 
- POI是apache的项目,可对微软的Word,Excel,Ppt进行操作,包括office2003和2007,Excl2003和2007。poi现在 一直有更新。所以现在主流使用POI。

POI结构说明

- HSSF提供读写Microsoft Excel XLS格式档案的功能。 
- XSSF提供读写Microsoft Excel OOXML XLSX格式档案的功能。 
- HWPF提供读写Microsoft Word DOC格式档案的功能。 
- HSLF提供读写Microsoft PowerPoint格式档案的功能。 
- HDGF提供读Microsoft Visio格式档案的功能。 
- HPBF提供读Microsoft Publisher格式档案的功能。 
- HSMF提供读Microsoft Outlook格式档案的功能。

## 第9章 文件上传与PDF报表入门

常见PDF报表的制作方式

目前世面上比较流行的制作PDF报表的工具如下:

1. iText PDF:iText是著名的开放项目，是用于生成PDF文档的一个java类库。通过iText不仅可以生成PDF或rtf 的文档，而且可以将XML、Html文件转化为PDF文件。
2. Openoffice:openoffice是开源软件且能在windows和linux平台下运行，可以灵活的将word或者Excel转化 为PDF文档。
3. Jasper Report:是一个强大、灵活的报表生成工具，能够展示丰富的页面内容，并将之转换成PDF


## 第11章 刷脸登录

## 第12章 代码生成器原理分析