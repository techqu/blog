---
title: "欢迎使用hugo,markdown语法说明"
date: 2018-12-20T10:58:38+08:00
draft: false
author: "瞿广"
originallink: ""
summary: "这里填写文章文章摘要。"
tags:        ["java", "volatile","synchronized","多线程","并发"]
categories:  ["Tech"]
---

# H1
##  标题2
### 标题3
#### 标题四

> 这是区块引用， 这是区块引用
>
> 这是区块引用
 这是区块引用

## 这是一个标题。

> ## 这是一个标题。
> 
> 1.   这是第一行列表项。
> 2.   这是第二行列表项。
> 
> 给出一些例子代码：
> 
>     return shell_exec("echo $input | $markdown_script");

##  无序列表，使用星号、加号、或者减号
*   Red
*   Green
*   Blue

##  有序列表
1.   Red
1.   Green
1.   Blue



##  调整好缩进的无序列表
*   调整好缩进的无序列表，调整好缩进的无序列表，调整好缩进的无序列表，调整好缩进的无序列表，
    调整好缩进的无序列表，调整好缩进的无序列表，调整好缩进的无序列表，
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
    
### 分割线    



---------------------------------------

### 链接
This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.

### 强调

**single asterisks**


### 图片
![Alt text](/img/home-bg-09.jpg)

### 代码块
```java
public class a{
       public static void main (String args[]){
       }
}
```

inline html 测试
```html
<table>
    <tr>
        <td>header1</td>
        <td>header2</td>
        <td>header3</td>
    </tr>
    <tr>
        <td>内容1</td>
            <td>内容2</td>
            <td>内容3</td>
        </tr>
</table>

```
<table>
    <tr>
        <td>header1</td>
        <td>header2</td>
        <td>header3</td>
    </tr>
    <tr>
        <td>内容1</td>
            <td>内容2</td>
            <td>内容3</td>
        </tr>
</table>