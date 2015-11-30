# 第一部分：基础知识 #

## 简单匹配 ##

你想知道一个字符串和一个正则表达式是否匹配，如果字符串参数与用 *Compile* 函数编译好的正则匹配的话，*MatchString* 函数就会返回 'true'.

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
			fmt.Printf("Match ") // Will print 'Match' again
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

	[ABCDEE]    <- first acceptable match
	[ABCDEEEE]  <- But POSIX wants the longer match

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
	 	
## What's in a Match? ##

The *FindString*-function finds a string. When you use a literal string, the result will obviously be the string itself. Only when you start using patterns and classes the result will be more interesting.
	 	
	r, err := regexp.Compile(`Hello`)
	// Will print 'Hello'
	fmt.Printf(r.FindString("Hello Regular Expression. Hullo again."))
	 	
When FindString does not find a string that matches the regular expression, it will return the empty string. Be aware that the empty string might also be the result of a valid match.
	 	
	r, err := regexp.Compile(`Hxllo`)
	// Will print nothing (=the empty string)
	fmt.Printf(r.FindString("Hello Regular Expression."))
	 	
FindString returns after the first match. If you are interested in more possible matches you would use *FindAllString()*, see below.

### 特殊字符 ###

句点 '.' 匹配任意字符。
	 	
	// 会打印出 'cat'.
	r, err := regexp.Compile(`.at`)
	fmt.Printf(r.FindString("The cat sat on the mat."))
	 	
'cat' 是第一个匹配。
	 	
	// more dot.
	s:= "Nobody expects the Spanish inquisition."
	//          -- --     --
	r, err := regexp.Compile(`e.`)
	res := r.FindAllString(s, -1) // negative: all matches
	// Prints [ex ec e ]. The last item is 'e' and a space.
	fmt.Printf("%v", res)
	res = r.FindAllString(s, 2) // find 2 or less matches
	// Prints [ex ec]. 
	fmt.Printf("%v", res)
	 	
## 特殊字符的字面量 ##

查找 '\'：在字符串里 '\' 需要跳脱一次，而在正则里就要跳脱两次。
	 	
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
		fmt.Printf("Found $-symbol.") // <-
	} else {
		fmt.Printf("No $$$.")
	}
	 	
## 简单的重复模式 ##

The *FindAllString*-function returns an array with all the strings that matched. FindAllString takes two arguments, a string and the maximum number of matches that shall be returned. If you definitely want all matches use '-1'.

Finding words. A word is a sequence of characters of type \w. The plus symbol '+' signifies a repetition:
	 	
	s := "Eenie meenie miny moe."
	r, err := regexp.Compile(`\w+`)
	res := r.FindAllString(s, -1)
	// Prints [Eenie meenie miny moe]
	fmt.Printf("%v", res)
	 	
In contrast to wildcards used on the commandline for filename matching, the '\*' does not symbolize 'any character', but the repetition of the previous character (or group). While the '+' requires at least a single occurence of its preceding symbol, the '*' is also satisfied with 0 occurences. This can lead to strange results.
	 	
	s := "Firstname Lastname"
	r, err := regexp.Compile(`\w+\s\w+`)
	res := r.FindString(s)
	// Prints Firstname Lastname
	fmt.Printf("%v", res)
	 	
But if this is some user supplied input, there might be two spaces:
	 	
	s := "Firstname  Lastname"
	r, err := regexp.Compile(`\w+\s\w+`)
	res := r.FindString(s)
	// Prints nothing (the empty string=no match)
	fmt.Printf("%v", res)
	 	
We allow any number (but at least one) of spaces with '\s+':
	 	
	s := "Firstname  Lastname"
	r, err := regexp.Compile(`\w+\s+\w+`)
	res := r.FindString(s)
	// Prints Firstname  Lastname
	fmt.Printf("%v", res)
	 	
If you read a text file in INI-style, you might want to be permissive regarding spaces around the equal-sign.
	 	
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
	 	
We saw that 'well' matched. To figure out, where exactly the regexp matched, let's have a look at the indexes. The *FindStringIndex*-function returns an array with two entries. The first entry is the index (starting from 0, of course) where the regular expression matched. The second is the index _in front of which_ the regexp ended. 
	 	
	s := "All is well that ends well"
	//    012345678901234567890123456
	//              1         2
	r, err := regexp.Compile(`well$`)
	fmt.Printf("%v", r.FindStringIndex(s)) // Prints [22 26]
	
	r, err = regexp.Compile(`well`)
	fmt.Printf("%v ", r.MatchString(s)) // true, but matches with first
	  					    // occurrence of 'well'
	fmt.Printf("%v", r.FindStringIndex(s)) // Prints [7 11], the match starts at 7 and end before 11.
	
	r, err = regexp.Compile(`ends$`)
	fmt.Printf("%v ", r.MatchString(s)) // false, not at end of line.
	 	
You can find a word boundary with '\b'. The *FindAllStringIndex*-function captures all the hits for a regexp in a container array.
	 	
	s := "How much wood would a woodchuck chuck in Hollywood?"
	//    012345678901234567890123456789012345678901234567890
	//              10        20        30        40        50
	//             -1--         -2--                    -3--
	// Find words that *start* with wood
	r, err := regexp.Compile(`\bwood`)              //    1      2
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13] [22 26]]
	
	// Find words that *end* with wood
	r, err = regexp.Compile(`wood\b`)               //   1      3 
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13] [46 50]]

	// Find words that *start* and *end* with wood
	r, err = regexp.Compile(`\bwood\b`)             //   1
	fmt.Printf("%v", r.FindAllStringIndex(s, -1)) // [[9 13]]
	 	
## 字符分类 ##

Instead of a literal character you can require a set (or class) of characters at any location. In this example [uio] is a "character class". Any of the characters in the square brackets will satisfy the regexp. Thus, this regexp will match 'Hullo', 'Hillo', and 'Hollo' 
	 	
	r, err := regexp.Compile(`H[uio]llo`)
	// Will print 'Hullo'.
	fmt.Printf(r.FindString("Hello Regular Expression. Hullo again."))
	 	
A negated character class reverses the match of the class. In this case it Will match all strings 'H.llo', where the dot is *not* 'o', 'i' or 'u'. It will not match "Hullo", "Hillo", "Hollo", but it will match "Hallo" and even "H9llo".
	 	
	r, err := regexp.Compile(`H[^uio]llo`)
	fmt.Printf("%v ", r.MatchString("Hillo")) // false
	fmt.Printf("%v ", r.MatchString("Hallo")) // true
	fmt.Printf("%v ", r.MatchString("H9llo")) // true
	 	
## POSIX 字符分类 ##

The Golang regexp library implements the POSIX character classes. These are simply
aliases for frequently used classes that are given are more readable name. The classes are:
(https://re2.googlecode.com/hg/doc/syntax.html)

	[:alnum:]	alphanumeric (≡ [0-9A-Za-z])
	[:alpha:]	alphabetic (≡ [A-Za-z])
	[:ascii:]	ASCII (≡ [\x00-\x7F])
	[:blank:]	blank (≡ [\t ])
	[:cntrl:]	control (≡ [\x00-\x1F\x7F])
	[:digit:]	digits (≡ [0-9])
	[:graph:]	graphical (≡ [!-~] == [A-Za-z0-9!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~])
	[:lower:]	lower case (≡ [a-z])
	[:print:]	printable (≡ [ -~] == [ [:graph:]])
	[:punct:]	punctuation (≡ [!-/:-@[-`{-~])
	[:space:]	whitespace (≡ [\t\n\v\f\r ])
	[:upper:]	upper case (≡ [A-Z])
	[:word:]	word characters (≡ [0-9A-Za-z_])
	[:xdigit:]	hex digit (≡ [0-9A-Fa-f])

Note that you have to wrap an ASCII character class in []. Furthmore note that whenever we speak about alphabet we are only
talking about the 26 letters in ASCII range 65-90, not including letters with diacritical marks.

Example: Find a sequence of a lower case letter, a punctuation character, a space (blank) and a digit:

	r, err := regexp.Compile(`[[:lower:]][[:punct:]][[:blank:]][[:digit:]]`)
	if r.MatchString("Fred: 12345769") == true {
		                 ----
		fmt.Printf("Match ") // 
	} else {
		fmt.Printf("No match ")
	}

I never use those, because they require more typing, but they might actually be a good idea in 
projects with many developers where not everybody is as well versed in regular expressions as you are.

## Unicode 字符分类 ##

Unicode is organized in blocks, typically grouped by topic or language. In this chapter
I give some examples, because it's next to impossible to cover all of them (and it doesn't 
really help). Refer to [complete unicode list of the
re2 engine](https://code.google.com/p/re2/wiki/Syntax "unicode blocks of re2").

### 示例：希腊语 ###

We start with a simple example from the Greek code block.

	r, err := regexp.Compile(`\p{Greek}`)

	if r.MatchString("This is all Γςεεκ to me.") == true {
		fmt.Printf("Match ") // Will print 'Match'
	} else {
 		fmt.Printf("No match ")
	}
	
On the Windows-1252 codepage there is a mu, but it
doesn't qualify, because \p{Greek} covers only 
http://en.wikipedia.org/wiki/Greek_and_Coptic
the range U+0370..U+03FF.

	if r.MatchString("the µ is right before ¶") == true {
		fmt.Printf("Match ") 
	} else {
 		fmt.Printf("No match ") // Will print 'No match'
	}

Some extra cool letters from the Greek and Coptic
codepage that qualify as 'Greek' although they are
probably Coptic, so be careful.

	if r.MatchString("ϵ϶ϓϔϕϖϗϘϙϚϛϜ") == true {
		fmt.Printf("Match ") // Will print 'Match'
	} else {
		fmt.Printf("No match ") 
	}
	
### 示例：布莱叶盲文（Braille）###
	
You have to use a font that supports [Braille](http://en.wikipedia.org/wiki/Braille "Braille").
I have my doubts that this is useful unless combined with a Braille capable printer, but there you go.

	r2, err := regexp.Compile(`\p{Braille}`)
	if r2.MatchString("This is all ⢓⢔⢕⢖⢗⢘⢙⢚⢛ to me.") == true {
		fmt.Printf("Match ") // Will print 'Match'
	} else {
		fmt.Printf("No match ")
	}

### 示例：彻罗基语（Cherokee）###

You have to use a font that supports Cherokee (e.g. Code2000).
The story of the Cherokee script is definitely worth [reading about](http://en.wikipedia.org/wiki/Cherokee#Language_and_writing_system "Cherokee").

	r3, err := regexp.Compile(`\p{Cherokee}`)
	if r3.MatchString("This is all ᏯᏰᏱᏲᏳᏴ to me.") == true {
		fmt.Printf("Match ") // Will print 'Match'
	} else {
		fmt.Printf("No match ")
	}

## Alternatives ##

You can provide alternatives using the pipe-symbol '|' to allow two (or more) different possible matches. If you want to allow alternatives only in parts of the regular expression, you can use parentheses for grouping.
	 	
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
	 	

