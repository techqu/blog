---
title: "Tomcat Netty-Servlet规范和Servlet容器"
date: 2019-09-12T11:20:46+08:00
lastmod: 2019-09-12T11:20:46+08:00
draft: false
keywords: []
description: ""
tags: []
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

浏览器发给服务端的是一个HTTP格式的请求，HTTP服务器收到这个请求 后，需要调用服务端程序来处理，所谓的服务端程序就是你写的Java类，一般来说不同的请求需要由不同的 Java类来处理。

那么问题来了，HTTP服务器怎么知道要调用哪个Java类的哪个方法呢。
<!--more-->

最直接的做法是在HTTP服务器代码 里写一大堆if else逻辑判断:如果是A请求就调X类的M1方法，如果是B请求就调Y类的M2方法。但这样做明 显有问题，因为HTTP服务器的代码跟业务逻辑耦合在一起了，如果新加一个业务方法还要改HTTP服务器的代码。


那该怎么解决这个问题呢?我们知道，面向接口编程是解决耦合问题的法宝，于是有一伙人就定义了一个接口，各种业务类都必须实现这个接口，这个接口就叫Servlet接口，有时我们也把实现了Servlet接口的业务 类叫作Servlet。

但是这里还有一个问题，对于特定的请求，HTTP服务器如何知道由哪个Servlet来处理呢?Servlet又是由谁 来实例化呢?显然HTTP服务器不适合做这个工作，否则又和业务类耦合了。

于是，还是那伙人又发明了Servlet容器，Servlet容器用来加载和管理业务类。HTTP服务器不直接跟业务类 打交道，而是把请求交给Servlet容器去处理，Servlet容器会将请求转发到具体的Servlet，如果这个Servlet 还没创建，就加载并实例化这个Servlet，然后调用这个Servlet的接口方法。因此 **Servlet接口其实是Servlet 容器跟具体业务类之间的接口**。下面我们通过一张图来加深理解。

![geektime-servlet-http-server](/img/geektime-servlet-http-server.png)

图的左边表示HTTP服务器直接调用具体业务类，它们是紧耦合的。再看图的右边，HTTP服务器不直接调用 业务类，而是把请求交给容器来处理，容器通过Servlet接口调用业务类。因此Servlet接口和Servlet容器的 出现，达到了HTTP服务器与业务类解耦的目的。

而Servlet接口和Servlet容器这一整套规范叫作Servlet规范。Tomcat和Jetty都按照Servlet规范的要求实现了 Servlet容器，同时它们也具有HTTP服务器的功能。作为Java程序员，如果我们要实现新的业务功能，只需要实现一个Servlet，并把它注册到Tomcat(Servlet容器)中，剩下的事情就由Tomcat帮我们处理了。
接下来我们来看看Servlet接口具体是怎么定义的，以及Servlet规范又有哪些要重点关注的地方呢?

### Servlet接口

 Servlet接口定义了下面五个方法:
 ```java
   public interface Servlet {

      void init(ServletConfig config) throws ServletException;

      ServletConfig getServletConfig();

      void service(ServletRequest req, ServletResponse res)throws ServletException, IOException;

      String getServletInfo();

      void destroy();
  }
 ```

其中最重要是的service方法，具体业务类在这个方法里实现处理逻辑。这个方法有两个参数: ServletRequest 和 ServletResponse。ServletRequest 用来封装请求信息，ServletResponse用来封装响应信息，因此 **本质上这两个类是对通信协议的封装**。

比如HTTP协议中的请求和响应就是对应了`HttpServletRequest`和`HttpServletResponse`这两个类。你可以通过HttpServletRequest来获取所有请求相关的信息，包括请求路径、Cookie、HTTP头、请求参数等。此外， 我在专栏上一期提到过，我们还可以通过`HttpServletRequest`来创建和获取Session。而 `HttpServletResponse`是用来封装HTTP响应的。

你可以看到接口中还有两个跟生命周期有关的方法`init`和`destroy`，这是一个比较贴心的设计，Servlet容器在 加载Servlet类的时候会调用init方法，在卸载的时候会调用`destroy`方法。我们可能会在init方法里初始化一些资源，并在destroy方法里释放这些资源，比如Spring MVC中的DispatcherServlet，就是在init方法里创建了自己的Spring容器。

你还会注意到`ServletConfig`这个类，ServletConfig的作用就是封装Servlet的初始化参数。你可以在web.xml 给Servlet配置参数，并在程序里通过getServletConfig方法拿到这些参数。

我们知道，有接口一般就有抽象类，抽象类用来实现接口和封装通用的逻辑，因此Servlet规范提供了 `GenericServlet`抽象类，我们可以通过扩展它来实现Servlet。虽然Servlet规范并不在乎通信协议是什么，但 是大多数的Servlet都是在HTTP环境中处理的，因此Servet规范还提供了HttpServlet来继承GenericServlet， 并且加入了HTTP特性。这样我们通过继承HttpServlet类来实现自己的Servlet，只需要重写两个方法: doGet和doPost。

### Servlet容器

我在前面提到，为了解耦，HTTP服务器不直接调用Servlet，而是把请求交给Servlet容器来处理，那Servlet 容器又是怎么工作的呢?接下来我会介绍Servlet容器大体的工作流程，一起来聊聊我们非常关心的两个话 题:Web应用的目录格式是什么样的，以及我该怎样扩展和定制化Servlet容器的功能。

#### 工作流程
当客户请求某个资源时，HTTP服务器会用一个ServletRequest对象把客户的请求信息封装起来，然后调用 Servlet容器的service方法，Servlet容器拿到请求后，根据请求的URL和Servlet的映射关系，找到相应的Servlet，如果Servlet还没有被加载，就用反射机制创建这个Servlet，并调用Servlet的init方法来完成初始化，接着调用Servlet的service方法来处理请求，把ServletResponse对象返回给HTTP服务器，HTTP服务器 会把响应发送给客户端。同样我通过一张图来帮助你理解。

![geektime-http-servlet-server.png](/img/geektime-http-servlet-server.png)

#### Web应用
Servlet容器会实例化和调用Servlet，那Servlet是怎么注册到Servlet容器中的呢?一般来说，我们是以Web 应用程序的方式来部署Servlet的，而根据Servlet规范，Web应用程序有一定的目录结构，在这个目录下分 别放置了Servlet的类文件、配置文件以及静态资源，Servlet容器通过读取配置文件，就能找到并加载 Servlet。Web应用的目录结构大概是下面这样的:
```
 | -  MyWebApp
      | -  WEB-INF/web.xml        -- 配置文件，用来配置Servlet等
      | -  WEB-INF/lib/           -- 存放Web应用所需各种JAR包
      | -  WEB-INF/classes/       -- 存放你的应用类，比如Servlet类
      | -  META-INF/              -- 目录存放工程的一些信息

```
 
Servlet规范里定义了 ServletContext 这个接口来对应一个Web应用。Web应用部署好后，Servlet 容器在启动时会加载Web应用，并为每个Web应用创建唯一的ServletContext 对象。你可以把 ServletContext 看成是一个全局对象，一个Web应用可能有多个Servlet，这些Servlet可以通过全局的ServletContext来共享数据，这些 数据包括Web应用的初始化参数、Web应用目录下的文件资源等。由于 ServletContext 持有所有 Servlet 实例，你还可以通过它来实现Servlet请求的转发。

#### 扩展机制

不知道你有没有发现，引入了Servlet规范后，你不需要关心Socket网络通信、不需要关心HTTP协议，也不需要关心你的业务类是如何被实例化和调用的，因为这些都被Servlet规范标准化了，你只要关心怎么实现 的你的业务逻辑。这对于程序员来说是件好事，但也有不方便的一面。所谓规范就是说大家都要遵守，就会 千篇一律，但是如果这个规范不能满足你的业务的个性化需求，就有问题了，因此设计一个规范或者一个中间件，要充分考虑到可扩展性。Servlet规范提供了两种扩展机制: **Filter和Listener**。

Filter是过滤器，这个接口允许你对请求和响应做一些统一的定制化处理，比如你可以根据请求的频率来限制访问，或者根据国家地区的不同来修改响应内容。过滤器的工作原理是这样的:Web应用部署完成后， Servlet容器需要实例化Filter并把Filter链接成一个FilterChain。当请求进来时，获取第一个Filter并调用 doFilter方法，doFilter方法负责调用这个FilterChain中的下一个Filter。

Listener是监听器，这是另一种扩展机制。当Web应用在Servlet容器中运行时，Servlet容器内部会不断的发生各种事件，如Web应用的启动和停止、用户请求到达等。 Servlet容器提供了一些默认的监听器来监听这些事件，当事件发生时，Servlet容器会负责调用监听器的方法。当然，你可以定义自己的监听器去监听你 感兴趣的事件，将监听器配置在web.xml中。比如Spring就实现了自己的监听器，来监听ServletContext的 启动事件，目的是当Servlet容器启动时，创建并初始化全局的Spring容器。

到这里相信你对Servlet容器的工作原理有了深入的了解，只有理解了这些原理，我们才能更好的理解 Tomcat和Jetty，因为它们都是Servlet容器的具体实现。后面我还会详细谈到Tomcat和Jetty是如何设计和实现Servlet容器的，虽然它们的实现方法各有特点，但是都遵守了Servlet规范，因此你的Web应用可以在这 两个Servlet容器中方便的切换。

### 本期精华

今天我们学习了什么是Servlet，回顾一下，Servlet本质上是一个接口，实现了Servlet接口的业务类也叫 Servlet。Servlet接口其实是Servlet容器跟具体Servlet业务类之间的接口。Servlet接口跟Servlet容器这一整 套规范叫作Servlet规范，而Servlet规范使得程序员可以专注业务逻辑的开发，同时Servlet规范也给开发者 提供了扩展的机制Filter和Listener。

最后我给你总结一下Filter和Listener的本质区别: 

- **Filter是干预过程的，它是过程的一部分，是基于过程行为的**。
- **Listener是基于状态的，任何行为改变同一个状态，触发的事件是一致的**。


---

### 04-实战:纯手工打造和运行一个Servlet

作为Java程序员，我们可能已经习惯了使用IDE和Web框架进行开发，IDE帮我们做了编译、打包的工作，而 Spring框架在背后帮我们实现了Servlet接口，并把Servlet注册到了Web容器，这样我们可能很少有机会接触 到一些底层本质的东西，比如怎么开发一个Servlet?如何编译Servlet?如何在Web容器中跑起来?

今天我们就抛弃IDE、拒绝框架，自己纯手工编写一个Servlet，并在Tomcat中运行起来。一方面进一步加深 对Servlet的理解;另一方面，还可以熟悉一下Tomcat的基本功能使用。

主要的步骤有:

1. 下载并安装Tomcat。 
2. 编写一个继承HTTPServlet的Java类。 
3. 将Java类文件编译成Class文件。 
4. 建立Web应用的目录结构，并配置web.xml。 
5. 部署Web应用。
6. 启动Tomcat。 
7. 浏览器访问验证结果。 
8. 查看Tomcat日志。

下面你可以跟我一起一步步操作来完成整个过程。Servlet 3.0规范支持用注解的方式来部署Servlet，不需要 在web.xml里配置，最后我会演示怎么用注解的方式来部署Servlet。

#### 1. 下载并安装Tomcat
最新版本的Tomcat可以直接在官网上下载，根据你的操作系统下载相应的版本
#### 2. 编写一个继承HTTPServlet的Java类
javax.servlet包提供了实现Servlet接口的GenericServlet抽象类。这是一个比较方便的类，可以通过扩展它来创建Servlet。但是大多数的Servlet都在HTTP环境中处理请求，因此Serve规范还提供了HttpServlet来扩展GenericServlet并且加入了HTTP特性。我们通过继承HttpServlet类来实现自己的 Servlet 只需要重写两个方法: **doGet和doPost。**

因此今天我们创建一个Java类去继承HTTPServlet类，并重写doGet和doPost方法。首先新建一个名为 `MyServlet.java`的文件，敲入下面这些代码:
```java
  import java.io.IOException;
  import java.io.PrintWriter;
  import javax.servlet.ServletException;
  import javax.servlet.http.HttpServlet;
  import javax.servlet.http.HttpServletRequest;
  import javax.servlet.http.HttpServletResponse;
 
  public class MyServlet extends HttpServlet {
      @Override
      protected void doGet(HttpServletRequest request, HttpServletResponse response)
              throws ServletException, IOException {
        System.out.println("MyServlet 在处理get()请求..."); 
        PrintWriter out = response.getWriter(); 
        response.setContentType("text/html;charset=utf-8"); 
        out.println("<strong>My Servlet!</strong><br>");
}
      @Override
      protected void doPost(HttpServletRequest request, HttpServletResponse response)
              throws ServletException, IOException {
        System.out.println("MyServlet 在处理post()请求..."); 
        PrintWriter out = response.getWriter(); 
        response.setContentType("text/html;charset=utf-8"); 
        out.println("<strong>My Servlet!</strong><br>");
} }
```
这个Servlet完成的功能很简单，分别在doGet和doPost方法体里返回一段简单的HTML。

#### 3. 将Java文件编译成Class文件
下一步我们需要把MyServlet.java文件编译成Class文件。你需要先安装JDK，这里我使用的是JDK 10。接着 你需要把Tomcat lib目录下的servlet-api.jar拷贝到当前目录下，这是因为servlet-api.jar中定义了Servlet接 口，而我们的Servlet类实现了Servlet接口，因此编译Servlet类需要这个JAR包。接着我们执行编译命令:
  javac -cp ./servlet-api.jar MyServlet.java
编译成功后，你会在当前目录下找到一个叫MyServlet.class的文件。

#### 4. 建立Web应用的目录结构
我们在上一期学到，Servlet是放到Web应用部署到Tomcat的，而Web应用具有一定的目录结构，所有我们 按照要求建立Web应用文件夹，名字叫MyWebApp，然后在这个目录下建立子文件夹，像下面这样:

```
  MyWebApp/WEB-INF/web.xml
  MyWebApp/WEB-INF/classes/MyServlet.class
```

然后在web.xml中配置Servlet，内容如下:

```xml
    <?xml version="1.0" encoding="UTF-8"?>
  <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
    http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
    version="4.0"
    metadata-complete="true">
      <description> Servlet Example. </description>
      <display-name> MyServlet Example </display-name>
      <request-character-encoding>UTF-8</request-character-encoding>
      <servlet>
        <servlet-name>myServlet</servlet-name>
        <servlet-class>MyServlet</servlet-class>
    </servlet>
      <servlet-mapping>
        <servlet-name>myServlet</servlet-name>
        <url-pattern>/myservlet</url-pattern>
      </servlet-mapping>
  </web-app>
```
你可以看到在web.xml配置了Servlet的名字和具体的类，以及这个Servlet对应的URL路径。请你注意，
servlet和servlet-mapping这两个标签里的servlet-name要保持一致。

#### 5. 部署Web应用
Tomcat应用的部署非常简单，将这个目录MyWebApp拷贝到Tomcat的安装目录下的webapps目录即可。

#### 6. 启动Tomcat
找到Tomcat安装目录下的bin目录，根据操作系统的不同，执行相应的启动脚本。如果是Windows系统，执 行startup.bat.;如果是Linux系统，则执行startup.sh。
#### 7. 浏览访问验证结果

在浏览器里访问这个URL:http://localhost:8080/MyWebApp/myservlet， 你会看到:

> My Servlet!

这里需要注意，访问URL路径中的MyWebApp是Web应用的名字，myservlet是在web.xml里配置的Servlet 的路径。

#### 8. 查看Tomcat日志
打开Tomcat的日志目录，也就是Tomcat安装目录下的logs目录。Tomcat的日志信息分为两类 :

一是运行日志，它主要记录运行过程中的一些信息，尤其是一些异常错误日志信息;

二是访问日志，它记录访问的时 间、IP地址、访问的路径等相关信息。 这里简要介绍各个文件的含义。

- catalina.***.log

    主要是记录Tomcat启动过程的信息，在这个文件可以看到启动的JVM参数以及操作系统等日志信息。
- catalina.out

    catalina.out是Tomcat的标准输出(stdout)和标准错误(stderr)，这是在Tomcat的启动脚本里指定的， 如果没有修改的话stdout和stderr会重定向到这里。所以在这个文件里可以看到我们在MyServlet.java程序 里打印出来的信息: MyServlet在处理get()请求...
- localhost.**.log

    主要记录Web应用在初始化过程中遇到的未处理的异常，会被Tomcat捕获而输出这个日志文件。
- localhost_access_log.**.txt

    存放访问Tomcat的请求日志，包括IP地址以及请求的路径、时间、请求协议以及状态码等信息。
- manager.***.log/host-manager.***.log

    存放Tomcat自带的manager项目的日志信息。

用注解的方式部署Servlet 为了演示用注解的方式来部署Servlet，我们首先修改Java代码，给Servlet类加上@WebServlet注解，修改后的代码如下。

```java
  import java.io.IOException;
  import java.io.PrintWriter;
  import javax.servlet.ServletException;
  import javax.servlet.annotation.WebServlet;
  import javax.servlet.http.HttpServlet;
  import javax.servlet.http.HttpServletRequest;
  import javax.servlet.http.HttpServletResponse;
  @WebServlet("/myAnnotationServlet")
  public class AnnotationServlet extends HttpServlet {
      @Override
      protected void doGet(HttpServletRequest request, HttpServletResponse response)
       throws ServletException, IOException {

      System.out.println("AnnotationServlet 在处理get()请求..."); 
      PrintWriter out = response.getWriter(); 
      response.setContentType("text/html; charset=utf-8"); 
      out.println("<strong>Annotation Servlet!</strong><br>");
}
      @Override
      protected void doPost(HttpServletRequest request, HttpServletResponse response)
              throws ServletException, IOException {
      System.out.println("AnnotationServlet 在处理post()请求..."); 
      PrintWriter out = response.getWriter(); 
      response.setContentType("text/html; charset=utf-8"); 
      out.println("<strong>Annotation Servlet!</strong><br>");
} }
```
这段代码里最关键的就是这个注解，它表明两层意思:第一层意思是AnnotationServlet这个Java类是一个 Servlet，第二层意思是这个Servlet对应的URL路径是myAnnotationServlet。

 ```
 @WebServlet("/myAnnotationServlet")
 ```

创建好Java类以后，同样经过编译，并放到MyWebApp的class目录下。这里要注意的是，你需要删除原来的web.xml，因为我们不需要web.xml来配置Servlet了。然后重启Tomcat，接下来我们验证一下这个新的 AnnotationServlet有没有部署成功。在浏览器里输 入:http://localhost:8080/MyWebApp/myAnnotationServlet
 
> Annotation Servlet!

这说明我们的AnnotationServlet部署成功了。可以通过注解完成web.xml所有的配置功能，包括Servlet初始化参数以及配置Filter和Listener等。

#### 本期精华

通过今天的学习和实践，相信你掌握了如何通过扩展HttpServlet来实现自己的Servlet，知道了如何编译 Servlet、如何通过web.xml来部署Servlet，同时还练习了如何启动Tomcat、如何查看Tomcat的各种日志， 并且还掌握了如何通过注解的方式来部署Servlet。我相信通过专栏前面文章的学习加上今天的练习实践， 一定会加深你对Servlet工作原理的理解。之所以我设置今天的实战练习，是希望你知道IDE和Web框架在背后为我们做了哪些事情，这对于我们排查问题非常重要，因为只有我们明白了IDE和框架在背后做的事情， 一旦出现问题的时候，我们才能判断它们做得对不对，否则可能开发环境里的一个小问题就会折腾我们半 天。