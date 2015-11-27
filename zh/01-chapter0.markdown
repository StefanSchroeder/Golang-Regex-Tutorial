## 简介 ##

这篇短小的教程是想教你一些使用 Go 语言正则表达式的基础知识。但它既不是 Go 语言更不是正则的入门教程。本教程所针对的是那些已经对两者都有所了解且希望对这两者的结合使用进行实践的读者。它使用 cookbook 的方式，每一个例子尽可完整，完全可以复制粘贴。

文章使用 Markdown 的排版。

在这个第一版里我打算仅仅讲一下 regexp 包里处理字符串的函数，因为我觉得这是最常见的用法。regexp 包大约有四十个函数，所以你最好读一下该包的文档。

[第一部分：基础知识](01-chapter1.markdown)： 正则表达式使用的基础。

[第二部分：高级](01-chapter2.markdown)： 相对复杂些的正则。

[第三部分：Cookbook](01-chapter3.markdown)： 一些示例程序。

[第四部分：换个思路](01-chapter4.markdown)： 有时正则并非最佳方案。

*参考文档：*

[regexp 包官方文档](http://golang.org/pkg/regexp/) （译注：翻墙吧，骚年）

[re2 正则库](https://code.google.com/p/re2/)

[Russ Cox 收集的有关正则表达式的入口页](http://swtch.com/~rsc/regexp/)

Mark McGranaghan 创建的一个很棒的 Go 语言程序例子的网站。这里也有一页 
[关于正则的页面](https://gobyexample.com/regular-expressions)

Rob Pike 有话说：关于 [用正则进行词法分析和解析（lexing and parsing）](http://commandcenter.blogspot.ch/2011/08/regular-expressions-in-lexing-and.html).

如果碰到有关 Go 的问题，你自己解决不了了，你可以去
[Golang-Nuts 邮件列表](https://groups.google.com/group/golang-nuts)。 
当然你也许已经知道这个了。

[Perl 正则教程](http://perldoc.perl.org/perlretut.html) 去寻找点灵感吧。（译注：作为一个 Perler，我很欣慰 ^_^）

> Version 0.1 Initial.

> This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.

作者：Stefan Schroeder

