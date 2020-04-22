---
title: "Eureka"
subtitle:    ""
date: 2020-03-02T17:41:01+08:00
lastmod: 2020-03-02T17:41:01+08:00
draft: false
keywords: []
description: ""
tags: []
categories: ["Tech"]
author: "瞿广"
image:       ""
---

<!--more-->

打算手动编译eureka源码，一步一步试错，记录下来


```
FAILURE: Build failed with an exception.

* Where:
Build file '/Users/quguang/githubRep/eureka/build.gradle' line: 10

* What went wrong:
Plugin [id: 'nebula.netflixoss', version: '3.6.0'] was not found in any of the following sources:

- Gradle Core Plugins (plugin is not in 'org.gradle' namespace)
- Plugin Repositories (could not resolve plugin artifact 'nebula.netflixoss:nebula.netflixoss.gradle.plugin:3.6.0')
  Searched in the following repositories:
    Gradle Central Plugin Repository

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 3s
```

升级到最新的gradle，仍然报错