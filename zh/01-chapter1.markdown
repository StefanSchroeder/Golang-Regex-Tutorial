# 第一部分：基础知识 #

## 简单匹配 ##

你想知道一个字符串和一个正则表达式是否匹配。如果字符串参数与用 *Compile* 函数编译好的正则匹配的话，*MatchString* 函数就会返回 'true'.

	package main

	import (
		"fmt"
		"regexp"
	)

	func main() {
		r, err := regexp.Compile(`Hello`)

		if err != nil {
			fmt.Printf("There is a problem with your regexp.\n")
			return
		}

		// Will print 'Match'
		if r.MatchString("Hello Regular Expression.") == true {
			fmt.Printf("Match ")
		} else {
			fmt.Printf("No match ")
		}
	}

*Compile* 函数是 regexp 包的核心所在。 每一个正则必由 *Compile* 或其姊妹函数 *MustCompile* 编译后方可使用。*MustCompile* 除了正则在不能正确被编译时会抛出异常外，使用方法和 *Compile* 几乎相同。因为 *MustCompile* 的任何错误都会导致一个异常，所以它无需返回表示错误码的第二个返回值。这就使得把 *MustCompile* 和匹配函数链在一起调用更加容易。像下面这样：
（但考虑性能因素，要避免在一个循环里重复编译正则表达式的用法）

	package main

	import (
		"fmt"
		"regexp"
	)

	func main() {
		if regexp.MustCompile(`Hello`).MatchString("Hello Regular Expression.") == true {
			fmt.Printf("Match ") // 会再次打印 'Match'
		} else {
			fmt.Printf("No match ")
		}
	}


这句不合法的正则

		var myre = regexp.MustCompile(`\d(+`)

会导致错误：

	panic: regexp: Compile(`\d(+`): error parsing regexp: missing argument to repetition operator: `+`

	goroutine 1 [running]:
	regexp.MustCompile(0x4de620, 0x4, 0x4148e8)
		go/src/pkg/regexp/regexp.go:207 +0x13f


*Compile* 函数的第二个参数会返回一个错误值。 在本教程中我通常都忽略这第二个参数，因为我写的所有正则都棒棒哒  ;-)。如果你写的正则也是字面量当然也可能没有问题，但是如果是在运行时从输入获取的值作为正则表达式，那你最好还是检查一下返回的这个错误值。

本教程接下来为了简洁会略过所有错误返回值的检查。

下面这个正则会匹配失败：

	r, err := regexp.Compile(`Hxllo`)
	// Will print 'false'
	fmt.Printf("%v", r.MatchString("Hello Regular Expression."))

## CompilePOSIX/MustCompilePOSIX ##

*CompilePOSIX* 和 *MustCompilePOSIX* 方法运行着的是一个略为不同的引擎。这两个里面采用的是 POSIX ERE (extended regular expression) 引擎。从 Go 语言的视角看它们采用了严格的规则集合，也就是 *egrep* 所支持的标准。因此 Go 的标准 re2 引擎支持的某些细节在 POSIX 版本中是没有的，比如 *\A*.

	s := "ABCDEEEEE"
	rr := regexp.MustCompile(`\AABCDE{2}|ABCDE{4}`)
	rp := regexp.MustCompilePOSIX(`\AABCDE{2}|ABCDE{4}`)
	fmt.Println(rr.FindAllString(s, 2))
	fmt.Println(rp.FindAllString(s, 2))

这里只有 *MustCompilePOSIX* 函数会解析失败，因为 POSIX ERE 中不支持 *\A*。

还有，POSIX 引擎更趋向最左最长(_leftmost-longest_)的匹配。在初次匹配到时并不会返回，而是会检查匹配到的是不是最长的匹配。 比如：

	s := "ABCDEEEEE"
	rr := regexp.MustCompile(`ABCDE{2}|ABCDE{4}`)
	rp := regexp.MustCompilePOSIX(`ABCDE{2}|ABCDE{4}`)
	fmt.Println(rr.FindAllString(s, 2))
	fmt.Println(rp.FindAllString(s, 2))

将打印：

	[ABCDEE]    <- 第一个可接受的匹配
	[ABCDEEEE]  <- 但是 POSIX 想要更长的匹配

只有当你有一些特殊需求时，POSIX 函数也许才会是你的不二之选。

## 字符分类 ##

字符类别 '\w' 代表所有 [A-Za-z0-9_] 包含在内的字符。 助记法：'word'。

	r, err := regexp.Compile(`H\wllo`)
	// Will print 'true'.
	fmt.Printf("%v", r.MatchString("Hello Regular Expression."))

字符类别 '\d' 代表所有数字字符。

	r, err := regexp.Compile(`\d`)
	// Will print 'true':
	fmt.Printf("%v", r.MatchString("Seven times seven is 49."))
	// Will print 'false':
	fmt.Printf("%v", r.MatchString("Seven times seven is forty-nine."))

字符类别 '\s' 代表以下任何空白：TAB, SPACE, CR, LF。或者更确切的说是 [\t\n\f\r ]。

	r, err := regexp.Compile(`\s`)
	// Will print 'true':
	fmt.Printf("%v", r.MatchString("/home/bill/My Documents"))

使用字符类别表示方法的大写形式表示相反的类别。所以 '\D' 代表任何不属于 '\d' 类别的字符。

	r, err := regexp.Compile(`\S`) // Not a whitespace
	// Will print 'true', obviously there are non-whitespaces here:
	fmt.Printf("%v", r.MatchString("/home/bill/My Documents"))

检查一个字符串是不是包含单词字符以外的字符：

	r, err := regexp.Compile(`\W`) // Not a \w character.

	fmt.Printf("%v", r.MatchString("555-shoe")) // true: has a non-word char: The hyphen
	fmt.Printf("%v", r.MatchString("555shoe")) // false: has no non-word char.

## 匹配的内容中有什么？ ##

*FindString* 函数会查找一个字符串。当你使用一个字面量的字符串作为正则时，结果自然就是该字符串本身。只有当你使用模式以及分类时，结果才会更加有趣。

	r, err := regexp.Compile(`Hello`)
	// 会打印 'Hello'
	fmt.Printf(r.FindString("Hello Regular Expression. Hullo again."))

当 FindString 找不到和正则表达式匹配的字符串时，它会返回空白字符串。要知道空白字符串也算是一次有效匹配的结果。

	r, err := regexp.Compile(`Hxllo`)
	// 什么都不打印 (也就是空字符串)
	fmt.Printf(r.FindString("Hello Regular Expression."))

FindString 会在首次匹配后即返回。如果你想尽可能多地匹配你就需要 *FindAllString()* 函数，这个后面会讲到。

### 特殊字符 ###

句点 '.' 匹配任意字符。

	// 会打印出 'cat'
	r, err := regexp.Compile(`.at`)
	fmt.Printf(r.FindString("The cat sat on the mat."))

'cat' 是第一个匹配。

	// 更多的点号
	s:= "Nobody expects the Spanish inquisition."
	//          -- --     --
	r, err := regexp.Compile(`e.`)
	res := r.FindAllString(s, -1) // negative: all matches
	// 打印 [ex ec e ]。最后一个元素是 'e' 和一个空白字符
	fmt.Printf("%v", res)
	res = r.FindAllString(s, 2) // find 2 or less matches
	// 打印 [ex ec]
	fmt.Printf("%v", res)

## 特殊字符的字面量 ##

查找 '\\'：在字符串里 '\\' 需要转义一次，而在正则里就要转义两次。

	r, err := regexp.Compile(`C:\\\\`)
	if r.MatchString("Working on drive C:\\") == true {
		fmt.Printf("Matches.") // <---
	} else {
		fmt.Printf("No match.")
	}

查找一个字面量的句点：

	r, err := regexp.Compile(`\.`)
	if r.MatchString("Short.") == true {
		fmt.Printf("Has a dot.") // <---
	} else {
		fmt.Printf("Has no dot.")
	}

其它用来组成正则表达式的特殊字符也基本这样用： .+*?()|[]{}^$

如查找一个字面量的美元符号：

	r, err := regexp.Compile(`\$`)
	if len(r.FindString("He paid $150 for that software.")) != 0 {
		fmt.Printf("Found $-symbol.") // <---
	} else {
		fmt.Printf("No $$$.")
	}

## 简单的重复模式 ##

*FindAllString* 函数返回匹配到的所有字符串的一个数组。FindAllString 需要两个参数，一个字符串正则以及需要返回的匹配内容的最大数量，如果你确定需要所有的匹配内容时就传 '-1' 给它。

查找字词。一个词就是字符类型 \w 的一个序列。加号 '+' 可以表示重复：

	s := "Eenie meenie miny moe."
	r, err := regexp.Compile(`\w+`)
	res := r.FindAllString(s, -1)
	// 打印 [Eenie meenie miny moe]
	fmt.Printf("%v", res)

和在命令行下作为文件名字通配符不同，'\*' 并不表示“任意字符”，而是表示它前面的一个字符（或分组）的重复次数。'+' 需要它前面的字符至少出现一次，'*' 在零次时也是满足的。这个可能会导致匪夷所思的结果。

	s := "Firstname Lastname"
	r, err := regexp.Compile(`\w+\s\w+`)
	res := r.FindString(s)
	// Prints Firstname Lastname
	fmt.Printf("%v", res)

但是如果是有些用户输入的内容可能会有两个空格：

	s := "Firstname  Lastname"
	r, err := regexp.Compile(`\w+\s\w+`)
	res := r.FindString(s)
	// 打印为空 (空字符串说明没有匹配到)
	fmt.Printf("%v", res)

使用 '\s+' 我们可以允许任意数量（但至少一个）的空白字符：

	s := "Firstname  Lastname"
	r, err := regexp.Compile(`\w+\s+\w+`)
	res := r.FindString(s)
	// Prints Firstname  Lastname
	fmt.Printf("%v", res)

如果你读取一个 INI 配置格式的文本文件，你也许会宽松地对待等号两侧的空白字符。

	s := "Key=Value"
	r, err := regexp.Compile(`\w+=\w+`)
	res := r.FindAllString(s, -1)
	// OK, prints Key=Value
	fmt.Printf("%v", res)

现在让我们在等号两边加上空格。

	s := "Key = Value"
	r, err := regexp.Compile(`\w+=\w+`)
	res := r.FindAllString(s, -1)
	// 失败了，什么都没有打印出来，因为 \w 不匹配空格
	fmt.Printf("%v", res)

于是我们用 '\s*' 来允许一些空格（包括没有空格的情况）：

	s := "Key = Value"
	r, err := regexp.Compile(`\w+\s*=\s*\w+`)
	res := r.FindAllString(s, -1)
	fmt.Printf("%v", res)

Go 的正则模式支持更多的和 '?' 结合使用的模式。

## 锚点和边界 ##

插入符号 ^ 标记“行的开始”。

	s := "Never say never."
	r, err1 := regexp.Compile(`^N`)        // Do we have an 'N' at the beginning?
	fmt.Printf("%v ", r.MatchString(s)) // true
	t, err2 := regexp.Compile(`^n`)        // Do we have an 'n' at the beginning?
	fmt.Printf("%v ", t.MatchString(s)) // false

美元符号 $ 标记“行的结束”。

	s := "All is well that ends well"
	r, err := regexp.Compile(`well$`)
	fmt.Printf("%v ", r.MatchString(s)) // true

	r, err = regexp.Compile(`well`)
	fmt.Printf("%v ", r.MatchString(s)) // true, but matches with first
	   					        // occurrence of 'well'
	r, err = regexp.Compile(`ends$`)
	fmt.Printf("%v ", r.MatchString(s)) // false, not at end of line.

我们看到 'well' 匹配到了。为了找到正则确切匹配到的位置，我们可以看一下索引。*FindStringIndex* 函数返回带有两个元素。第一个元素是正则表达式开始匹配到的位置的索引（当然是从0开始的）。第二个元素是正则匹配结束的下一个位置的索引。

	s := "All is well that ends well"
	//    012345678901234567890123456
	//              1         2
	r, err := regexp.Compile(`well$`)
	fmt.Printf("%v", r.FindStringIndex(s)) // 打印 [22 26]

	r, err = regexp.Compile(`well`)
	fmt.Printf("%v ", r.MatchString(s))    // true, 但是这回匹配第一次出现的 'well'
	fmt.Printf("%v", r.FindStringIndex(s)) // Prints [7 11], the match starts at 7 and end before 11.

	r, err = regexp.Compile(`ends$`)
	fmt.Printf("%v ", r.MatchString(s))    // false, 'ends' 并不是在结尾处

你可以使用 '\b' 查找一个单词的边界。*FindAllStringIndex* 函数会捕获一个正则中所有命中的位置，以一个数组容器的形式返回。

	s := "How much wood would a woodchuck chuck in Hollywood?"
	//    012345678901234567890123456789012345678901234567890
	//              10        20        30        40        50
	//             -1--         -2--                    -3--
	// 查找以 wood 开头的词
	r, err := regexp.Compile(`\bwood`)              //    1      2
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13] [22 26]]

	// 查找以 wood 结尾的词
	r, err = regexp.Compile(`wood\b`)               //   1      3
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13] [46 50]]

	// 查找以 wood 开头并以其结尾的词
	r, err = regexp.Compile(`\bwood\b`)             //   1
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13]]

## 字符分类 ##

你可以在任何位置获取一组（或类）字符串，而不是一个单个的字面量字符。在本例中[uio] 就是一个“字符串分类”。在方括号中的任意字符都满足该正则表达式。所以，这个正则会匹配到 'Hullo'，'Hillo'，以及 'Hollo'。

	r, err := regexp.Compile(`H[uio]llo`)
	// Will print 'Hullo'.
	fmt.Printf(r.FindString("Hello Regular Expression. Hullo again."))

一个排除在外的字符分类会对分类的匹配取反。这时该正则就会匹配所有 'H.llo' 中的点号 *不* 是 'o', 'i' 或者 'u'的字符串。它不会匹配 "Hullo", "Hillo", "Hollo"，但是会匹配 "Hallo" 甚至是 "H9llo"。

	r, err := regexp.Compile(`H[^uio]llo`)
	fmt.Printf("%v ", r.MatchString("Hillo")) // false
	fmt.Printf("%v ", r.MatchString("Hallo")) // true
	fmt.Printf("%v ", r.MatchString("H9llo")) // true

## POSIX 字符分类 ##

Golang regexp 库实现了 POSIX 字符分类。这不过就是给常用的类别取个可读性更好的别名。这些分类有：
(https://github.com/google/re2/blob/master/doc/syntax.txt)

	[:alnum:]	字母和数字(alphanumeric) (≡ [0-9A-Za-z])
	[:alpha:]	字母(alphabetic) (≡ [A-Za-z])
	[:ascii:]	ASCII      (≡ [\x00-\x7F])
	[:blank:]	空字符(blank) (≡ [\t ])
	[:cntrl:]	控制字符(control) (≡ [\x00-\x1F\x7F])
	[:digit:]	数字字符(digits) (≡ [0-9])
	[:graph:]	图形符号(graphical) (≡ [!-~] == [A-Za-z0-9!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~])
	[:lower:]	小写字母(lower case) (≡ [a-z])
	[:print:]	可打印字符(printable) (≡ [ -~] == [ [:graph:]])
	[:punct:]	标点符号(punctuation) (≡ [!-/:-@[-`{-~])
	[:space:]	空格字符(whitespace) (≡ [\t\n\v\f\r ])
	[:upper:]	大写字母(upper case) (≡ [A-Z])
	[:word:]	文字字符(word characters) (≡ [0-9A-Za-z_])
	[:xdigit:]	十六进制(hex digit) (≡ [0-9A-Fa-f])

注意你必须把一个 ASCII 字符用 [] 包起来。而且还要注意无论何时我们说到字母的时候我们仅仅是在指 ASCII 从65-90范围内的26个字母，
不包括那些带有变音符的字母。

例子：查找一个包含一个小写字母、一个标点符号、一个空格（空白字符）以及一个数字的序列：

	r, err := regexp.Compile(`[[:lower:]][[:punct:]][[:blank:]][[:digit:]]`)
	if r.MatchString("Fred: 12345769") == true {
		                 ----
		fmt.Printf("Match ") //
	} else {
		fmt.Printf("No match ")
	}

我从来不用这些，因为它们需要打更多的字。但是在一些很多程序员一起工作的项目中，而且并不是每个人都像你一样
对正则表达式游刃有余的话，使用 POSIX 的写法也许也不失是一个好主意。

## Unicode 字符分类 ##

Unicode 是以区块（block）来组织的，典型地以主题或者语言进行分组。在本章我给出一些例子，因为完全覆盖到全部那是
不可能的（况且也无甚用处）。参见 [re2 引擎完整 unicode 字符列表](https://code.google.com/p/re2/wiki/Syntax "unicode blocks of re2").

### 示例：希腊语 ###

我们以一个希腊语代码块的简单例子开始。

	r, err := regexp.Compile(`\p{Greek}`)

	if r.MatchString("This is all Γςεεκ to me.") == true {
		fmt.Printf("Match ") // 会打印出 'Match'
	} else {
 		fmt.Printf("No match ")
	}

在 Windows-1252 代码页有个 mu，但是没有被认定为希腊语。因为 \p{Greek} 仅仅覆盖 U+0370 到 U+03FF 的部分 http://en.wikipedia.org/wiki/Greek_and_Coptic 。

	if r.MatchString("the µ is right before ¶") == true {
		fmt.Printf("Match ")
	} else {
 		fmt.Printf("No match ") // 会打印出 'No match'
	}

有些来自希腊语和科普特语（Coptic）代码页的特别酷的字母被认定为希腊语，而实际上
可能是科普特语，要注意。

	if r.MatchString("ϵ϶ϓϔϕϖϗϘϙϚϛϜ") == true {
		fmt.Printf("Match ") // Will print 'Match'
	} else {
		fmt.Printf("No match ")
	}

### 示例：布莱叶盲文（Braille）###

你必须使用一种支持布莱叶盲文的字体。 [布莱叶盲文](http://en.wikipedia.org/wiki/Braille "布莱叶盲文")

我怀疑这得配合一个支持布莱叶盲文的打印机才会有用，但这个就随你了。

	r2, err := regexp.Compile(`\p{Braille}`)
	if r2.MatchString("This is all ⢓⢔⢕⢖⢗⢘⢙⢚⢛ to me.") == true {
		fmt.Printf("Match ") // 会打印出 'Match'
	} else {
		fmt.Printf("No match ")
	}

### 示例：彻罗基语（Cherokee）###

你必须使用一种支持彻罗基语的字体（比如 Code2000）。
彻罗基语言的故事绝对值得一读。[去读](http://en.wikipedia.org/wiki/Cherokee#Language_and_writing_system "彻罗基语").

	r3, err := regexp.Compile(`\p{Cherokee}`)
	if r3.MatchString("This is all ᏯᏰᏱᏲᏳᏴ to me.") == true {
		fmt.Printf("Match ") // 会打印出 'Match'
	} else {
		fmt.Printf("No match ")
	}

## 择一匹配 ##

你可以使用管道符号 '|' 允许两个或多个不同的可能来提供可选择性的匹配。如果你只是想对正则表达式中的某些部分进行可选择性的匹配，你可以使用括号来进行分组。

	r, err1 := regexp.Compile(`Jim|Tim`)
	fmt.Printf("%v", r.MatchString("Dickie, Tom and Tim")) // true
	fmt.Printf("%v", r.MatchString("Jimmy, John and Jim")) // true

	t, err2 := regexp.Compile(`Santa Clara|Santa Barbara`)
	s := "Clara was from Santa Barbara and Barbara was from Santa Clara"
	//                   -------------                      -----------
	fmt.Printf("%v", t.FindAllStringIndex(s, -1))
	// [[15 28] [50 61]]

	u, err3 := regexp.Compile(`Santa (Clara|Barbara)`) // Equivalent
	v := "Clara was from Santa Barbara and Barbara was from Santa Clara"
	//                   -------------                      -----------
	fmt.Printf("%v", u.FindAllStringIndex(v, -1))
	// [[15 28] [50 61]]


