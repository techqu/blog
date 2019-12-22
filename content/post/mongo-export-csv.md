---
title: "Mongo Export Csv"
date: 2019-01-29T15:01:21+08:00
lastmod: 2019-01-29T15:01:21+08:00
draft: false
keywords: ["mongo","excel"]
description: ""
tags: ["mongo","工具使用"]
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


mongo 上查询数据，导出excel，并解决Mac上的Excel在导入CSV文件不支持utf-8的问题

<!--more-->




## 一、导出方法

控制台命令如下：

```sh
mongo localhost:27017/cdd-prejudication /path/to/query.js > xxx.csv
```

query.js 是根据你的mongo查询语句编写，主要是在后面用 `for`循环打印输出的字段，用逗号分割，这样就能拼成csv文件

我的query.js如下：

```javascript
db.getCollection('cdd-prejudication.pengyuan_phoneNoCheck_rsp')
.aggregate(
  [
    {$unwind:'$response.returnValue.cisReport'},
    {$project:{reportID:'$response.returnValue.cisReport.reportID',username:'$username',idCard:'$idCard'}}
  ])
.forEach(
    function(document) {
        print("\t"+document.reportID + "," + document.username + ",\t" + document.idCard+"");
    }
)

```
根据自己的需要自行编写




## 二、问题
### 1.csv文件会中文乱码（Mac上的Excel在导入CSV文件不支持utf-8）


```
vim 源文件
```
 

使用查看文件编码
`:set fileencoding`

通过Mac上的iconv工具将文件编码由UTF8转为GB18030

```
iconv -f UTF8 -t GB18030 源文件.csv >新文件.csv
```


### 2. 科学计数法问题

- 解决办法：
只要把数字字段后面加上显示上看不见的字符即可，字符串前面或者结尾加上制表符"\t".




## 三、aggregation $unwind例子

需要解析数组，必须使用mongo的 [Aggregation Pipeline](https://docs.mongodb.com/manual/aggregation/#aggregation-pipeline)命令了

有如下结构的数据：

```
{ "_id" : 1, "item" : "ABC1", sizes: [ "S", "M", "L"] }
```
下面的 aggregation $unwind 将数组遍历

```
db.inventory.aggregate( [ { $unwind : "$sizes" } ] )
```

返回结果，变成了三条

```
{ "_id" : 1, "item" : "ABC1", "sizes" : "S" }
{ "_id" : 1, "item" : "ABC1", "sizes" : "M" }
{ "_id" : 1, "item" : "ABC1", "sizes" : "L" }
```