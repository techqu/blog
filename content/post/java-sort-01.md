---
title: "Java排序算法"
date: 2019-08-17T19:48:51+08:00
lastmod: 2019-08-17T19:48:51+08:00
draft: false
keywords: []
description: ""
tags: []
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

总结简单的排序算法

有个不错的网站，动画演示各种算法：[visualgo](https://visualgo.net/zh/sorting)
<!--more-->

## 冒泡排序

{{< highlight java "linenos=inline,hl_lines=8 15-17,linenostart=10" >}}

import java.util.Arrays;

public class BubbleSort {

    static int[] array = {1, 4, 2, 8, 20, 23, 12};

    public static void main(String[] args) {
        int[] b = sort(array);
        System.out.println(Arrays.toString(b));
    }

    public static int[] sort(int[] array) {
        int n = array.length;
        boolean flag = false;
        for (int i = 0; i < n; i++) {
            int s = n - i - 1;
            System.out.println(s);
            for (int j = 0; j < s; j++) {
                if (array[j] > array[j + 1]) {
                    int tmp = array[j];
                    array[j] = array[j + 1];
                    array[j + 1] = tmp;
                    flag = true;
                }
            }
            if (!flag) {
                break;
            }
        }
        return array;
    }
}
{{< /highlight >}}




## 插入排序

```java 
package com.techqu.sort;

import java.util.Arrays;

public class InsertSort {

    static int[] array = {1, 4, 2, 8, 20, 23, 12};

    public static void main(String[] args) {
        int[] b = sort(array);
        System.out.println(Arrays.toString(b));

    }

    public static int[] sort(int[] array) {
        int n = array.length;
        for (int i = 1; i < n; i++) {
            int value = array[i];
            int j = i - 1;
            for (; j > 0; j--) {
                if (value < array[j]) {
                    array[j + 1] = array[j];//数据移动
                } else {

                    break;
                }
            }
            array[j + 1] = value;//插入数据
        }
        return array;
    }
}

```

## 选择排序

```java
package com.techqu.sort;

import java.util.Arrays;

public class SelectSort {

    static int[] array = {1, 4, 2, 8, 20, 23, 12};

    public static void main(String[] args) {

        int[] b = sort(array);
        System.out.println(Arrays.toString(b));

    }

    public static int[] sort(int[] array) {
        int n = array.length;

        for (int i = 0; i < n - 1; i++) {
            System.out.println(Arrays.toString(array));
            int min_index = i;
            for (int j = i + 1; j < n; j++) {

                System.out.println(array[min_index] + "," + array[j]);
                if (array[min_index] > array[j]) {
                    min_index = j;
                }

            }
            if (i != min_index) {
                int tmp = array[i];
                array[i] = array[min_index];
                array[min_index] = tmp;
            }

        }
        return array;

    }

}

```