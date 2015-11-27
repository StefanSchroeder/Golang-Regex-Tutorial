# 第三部分：示例 Cookbook #

## grep ##

这个 grep 工具用来在文本文件中搜索匹配一个正则表达式。读取到的每行文本都会和命令行中给定的正则进行匹配，匹配到的行会被打印出来。

	package main

	import (
		"flag"
		"regexp"
		"bufio"
		"fmt"
		"os"
	)

	func grep(re, filename string) {
	    regex, err := regexp.Compile(re)
	    if err != nil {
			return // there was a problem with the regular expression.
	    }

	    fh, err := os.Open(filename)
	    f := bufio.NewReader(fh)

	    if err != nil {
			return // there was a problem opening the file.
	    }
	    defer fh.Close()

	    buf := make([]byte, 1024)
	    for {
			buf, _ , err = f.ReadLine()
			if err != nil {
				return
			}

			s := string(buf)
			if regex.MatchString(s) {
				fmt.Printf("%s\n", string(buf))
			}
	    }
	}

	func main() {
		flag.Parse()
		if flag.NArg() == 2 {
			grep(flag.Arg(0), flag.Arg(1))
		} else {
			fmt.Printf("Wrong number of arguments.\n")
		}
	}
	 	
如果你不知道 grep 为何物，可以在命令行里运行 'man grep' 一下。

## 搜索替换 ##

这个工具是上面 grep 工具的升级版。它在搜索匹配一个模式的同时会用其它内容替换掉匹配到的内容。显然我们是在对上面已有的 grep 版本基础上进行一些二次加工。

用法： ./replacer old new filename

	 	
	package main

	import (
		"flag"
		"regexp"
		"bufio"
		"fmt"
		"os"
	)

	func replace(re, repl, filename string) {
	    regex, err := regexp.Compile(re)
	    if err != nil {
			return // there was a problem with the regular expression.
	    }

	    fh, err := os.Open(filename)
	    f := bufio.NewReader(fh)

	    if err != nil {
			return // there was a problem opening the file.
	    }
	    defer fh.Close()

	    buf := make([]byte, 1024)
	    for {
			buf, _ , err = f.ReadLine()
			if err != nil {
				return
			}

			s := string(buf)
			result := regex.ReplaceAllString(s, repl)
			fmt.Print(result + "\n")
	    }
	}

	func main() {
		flag.Parse()
		if flag.NArg() == 3 {
			repl(flag.Arg(0), flag.Arg(1), flag.Arg(2))
		} else {
			fmt.Printf("Wrong number of arguments.\n")
		}
	}
	 	
## 验证电子邮件地址 ##

RFC2822 对于电子邮件的格式定义的过于宽松，以至于很难用简单的正则表达式验证一个邮件地址是否合规。很有趣啊。大多数情况下尽管你的程序会对邮件地址做一些预设，但是我发现下面这条正则对所有的情况都是实地有效的：

	(\w[-._\w]*\w@\w[-._\w]*\w\.\w{2,3})

邮件地址必须以一个字符 \w 开头，接下来是任何数量的包含了破折号、英文句点以及下划线在内的字符。同时，在 @ 之前的最后一个字符必须又是一个“正常的”字符才行。对于域名部分我们也是同样的规则，但域名的后缀部分必须只由2到3个字符组成。这个规则基本可以覆盖大多数的情况。如果你碰到一个和这个正则不匹配的邮件地址，那很可能是故意拼凑起来逗你玩儿的，忽略即可。

