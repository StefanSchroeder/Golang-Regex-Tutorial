# 第二部分：高级用法 #

## 捕获分组 ##

有时你用正则匹配一个字符串，但其实只是想留意之中的某一小段内容。而在前一章我们一直都停留在匹配到的*整个的*字符串上。

		//[[cat] [sat] [mat]]
		re, err := regexp.Compile(`.at`)
		res := re.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", res)

你可以使用括号来捕捉你真正需要的那部分，而不是整个正则匹配到的全部内容。

		//[[cat c] [sat s] [mat m]]
		re, err := regexp.Compile(`(.)at`) // want to know what is in front of 'at'
		res := re.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", res)

你可以有多个捕获分组。

		// 结果是 [[ex e x] [ec e c] [e  e  ]]
		s := "Nobody expects the Spanish inquisition."
		re1, err := regexp.Compile(`(e)(.)`) // Prepare our regex
		result_slice := re1.FindAllStringSubmatch(s, -1)
		fmt.Printf("%v", result_slice)

*FindAllStringSubmatch* 这个方法对每一个捕获都返回一个数组，其中第一个元素是整个的匹配结果，接下来的元素是每个匹配到的分组的结果。最后每一个这样的数组再全部包进一个外层的数组里。

如果你有一个可选的捕获分组在一个字符串中没有出现，结果数组里会包含一个空的字符串的壳儿。换句话说，结果数组的元素数量总是分组数量再加上一。

	s := "Mr. Leonard Spock"
	re1, err := regexp.Compile(`(Mr)(s)?\. (\w+) (\w+)`)
	result:= re1.FindStringSubmatch(s)

	for k, v := range result {
		fmt.Printf("%d. %s\n", k, v)
	}
	// Prints
	// 0. Mr. Leonard Spock
	// 1. Mr
	// 2.
	// 3. Leonard
	// 4. Spock

你不能把捕获分组进行部分叠加。比如下面的例子我们想让第一个正则匹配 'expects the'，另外一个匹配 'the Spanish'，这里括号要分开用才行。
助记法：最后开始的，最先闭合。这里的在 'the' 之前开启的括号要在其之后是闭合的。

	s := "Nobody expects the Spanish inquisition."
	re1, err := regexp.Compile(`(expects (...) Spanish)`)
	// Wanted regex1          --------------
	// Wanted regex2                   --------------
	result:= re1.FindStringSubmatch(s)

	for k, v := range result {
		fmt.Printf("%d. %s\n", k, v)
	}
	// 0. expects the Spanish
	// 1. expects the Spanish
	// 2. the

*FindStringSubmatchIndex* 函数...

## 命名捕获 ##

仅仅把匹配到的内容存入数组中的序列里会略显不便，会出现两个问题。

首先，当你在正则的某处插入一个新的分组时，在其后的分组在结果数组中的索引值肯定会增加。这是件麻烦事儿。

其次，正则本身也许是在运行时拼成的，这可能会包含很多超出我们控制的括号。也就是说我们不知道我们精心拼成的括号匹配到的内容的索引是多少。

为了解决这个问题，_named matches_ 应运而生。允许给匹配的内容取一个符号化的名称用来到匹配的结果中进行查询。

    re := regexp.MustCompile("(?P<first_char>.)(?P<middle_part>.*)(?P<last_char>.)")
    n1 := re.SubexpNames()
    r2 := re.FindAllStringSubmatch("Super", -1)[0]

    md := map[string]string{}
    for i, n := range r2 {
        fmt.Printf("%d. match='%s'\tname='%s'\n", i, n, n1[i])
        md[n1[i]] = n
    }
    fmt.Printf("The names are  : %v\n", n1)
    fmt.Printf("The matches are: %v\n", r2)
    fmt.Printf("The first character is %s\n", md["first_char"])
    fmt.Printf("The last  character is %s\n", md["last_char"])

在该例中字符串 'Super' 使用一个由三部分组成的正则进行匹配：

一个单字符(.)，命名为 'first_char'。

一个中间由一串字符组成的部分，命名为 'middle_part'。

一个结尾的字符(.)，因此命名为 'last_char'。

为了简化匹配结果的使用，我们把所有的捕获命名都存在 n1 中，然后和匹配的结果 r2 一一对应后存储到一个新的叫 _md_ 的 map，其中匹配结果是作为捕获命名的值。

注意整个字符串 'Super' 这个值用的是空字符这样一个伪键。

该例子会打印出：

    0. match='Super'    name=''
    1. match='S'    name='first_char'
    2. match='upe'    name='middle_part'
    3. match='r'    name='last_char'
    The names are  : [ first_char middle_part last_char]
    The matches are: [Super S upe r]
    The first character is S
    The last  character is r

# 重复：高级篇 #

## 非匹配捕获／分组重复 ##

如果一个复杂的正则表达式有多个分组，你可能会碰到使用括号进行分组但是对捕获到的内容并不需要关心的情况。这时你可以使用 (?:regex) 这样一个“非捕获分组”的方式丢弃一组匹配到的内容。问号加上冒号会告诉编译器用这个模式匹配但是不要作保存。

不包括非捕获分组：

	s := "Mrs. Leonora Spock"
	re1, err := regexp.Compile(`Mr(s)?\. (\w+) (\w+)`)
	result:= re1.FindStringSubmatch(s)
	for k, v := range result {
		fmt.Printf("%d. %s\n", k, v)
	}
	// 0. Mrs. Leonora Spock
	// 1. s
	// 2. Leonora
	// 3. Spock

带有一个非捕获分组：

	s := "Mrs. Leonora Spock"
	re1, err := regexp.Compile(`Mr(?:s)?\. (\w+) (\w+)`)
	result:= re1.FindStringSubmatch(s)
	for k, v := range result {
		fmt.Printf("%d. %s\n", k, v)
	}
	// 0. Mrs. Leonora Spock
	// 1. Leonora
	// 2. Spock

## 到底是多少？ ##

你可能非常清楚需要重复的具体次数。当你知道一个正则中你需要的部分有具体多少个实例的时候我们就需要 {}。

	s := "11110010101111100101001001110101"
	re1, err := regexp.Compile(`1{4}`)
	res := re1.FindAllStringSubmatch(s,-1)
	fmt.Printf("<%v>", res)
	// <[[1111] [1111]]>

	res2 := re1.FindAllStringIndex(s,-1)
	fmt.Printf("<%v>", res2)
	// <[[0 4] [10 14]]>

{} 的语法并不是很常用。其中一个原因是很多或是也许所有的情形下你都会通过简单地重复写出这些重复的部分来修改正则表达式。[但是假如重复的数量是120次的话，我觉得你应该就不愿意这么写了吧] 仅当你有非常明确的需求（比如 {123,130}）时你才会想使用 {}。

    (ab){3} == (ababab)
    (ab){3,4} == (ababab(ab)??)

> 注：?? 表示 “零个或是一个，更倾向零个”。

{} 的通用模式是 x{n,m}。这里 'n' 是 x 出现的最小数量，'m' 是出现的最大数量。

Go-regexp 包支持 {} 家族中略多一些的模式。

# 标志项 #

regexp 包有如下的标志项可用 [引自文档]：

* i	区分大小写 （默认不区分）
* m	多行模式： ^ 和 $ 匹配整个文本的开头／结尾的同时也匹配每行的开头和结尾（默认不匹配）
* s	让 . 匹配 \n （默认不匹配）
* U	非贪婪：对 x* 和 x*?， x+ 和 x+? 等模式进行切换（默认是关闭的）

标志项的语法是 xyz（设置）或 -xyz（清除）或是 xy-z（设置 xy，清除 z）。

## 区分大小写 ##

也许你已经知道有些字符存在两种形式：大写和小写。[ 你也许会说：“我当然知道这个，大家都知道！” 好吧，如果你觉得这问题有点儿吹毛求疵那你看下这些特例的大小写问题：a, $, 本, ß, Ω。好了，我们别把问题复杂化了，还是先只考虑英语的情况吧。]

如果你明确地想忽略大小写的情况，或者说你想在一个正则或是其中的一部分允许大小写，那就使用 'i' 标志符。

		s := "Never say never."
		r, err := regexp.Compile(`(?i)^n`)   // 是否是以 'N' 或 'n' 开头？
		fmt.Printf("%v", r.MatchString(s))   // true, 不区分大小写

在现实世界中我们很少会去匹配一个不区分大小写的正则。通常我们都倾向于先把整个字符串转换成大写或者小写，然后再去只匹配这一种情形：

		sMixed := "Never say never."
		sLower := strings.ToLower(sMixed)         // 不要忘记 import "strings" 包
		r, err := regexp.Compile(`^n`)
		fmt.Printf("%v ", r.MatchString(sMixed))  // false, N != n
		fmt.Printf("%v ", r.MatchString(sLower))  // true,  n == n

## 贪婪匹配 vs 非贪婪匹配 ##

如前所见，正则表达式可能包含重复的部分。在大多情况下，对于给定的字符串会有不止一种可行方案的正则。

比如，使用正则 '.*' （包括单引号部分），对下面的字符串匹配的结果是怎样的?

    'abc','def','ghi'

你可能只是想取到 *'abc'* 部分，但是却非如此。正则表达式默认情况下是 _贪婪的_。它们在能匹配的情况下会尽可能多的去取字符。所以这里答案是  *'abc','def','ghi'*，因为中间部分的引号也是和 "." 匹配的！如下：

		r, err := regexp.Compile(`'.*'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc','def','ghi'>

如果想确认进行最短可能匹配（即非贪婪），你要在正则表达式后面加上特殊符合 '?'。

		r, err := regexp.Compile(`'.*?'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc'>

没有捷径可以让你写一条匹配 'abc','def' 的这样的正则。

你可以使用 U 这个标志项把正则表达式的行为恢复到默认非贪婪的模式。

		r, err := regexp.Compile(`(?U)'.*'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc'>

在你的正则里你可以前后相继地在这两个行为之间进行切换。

## 点号是否匹配换行符？ ##

当我们有一个多行字符串（也就是包含换行符 '\n' 的字符串）你可以使用 (?s) 标志符控制是否让 '.' 匹配
换行符。默认是不匹配。哪位能贡献一个更合理的用例吗？

		r, err := regexp.Compile(`a.`)
		s := "atlanta\narkansas\nalabama\narachnophobia"
		res := r.FindAllString(s, -1)
		fmt.Printf("<%v>", res)
		// <[at an ar an as al ab am ar ac]>

这时如果使用 (?s) 标志符，换行符就会在结果中保留。

		r, err := regexp.Compile(`(?s)a.`)
		s := "atlanta\narkansas\nalabama\narachnophobia"
		res := r.FindAllString(s, -1)
		fmt.Printf("<%v>", res)
		// Prints
		// <[at an a
		// ar an as al ab am a
		// ar ac]>

## 要不要 ^/$ 匹配换行符？ ##

对于多行文本，你可以通过'(?m)' 这个标志符来控制 '^' 或者 '$' 是否匹配换行符。默认是不匹配。('^' 表示行的起始符 BOL=Begin-of-line, '$' 表示行的结尾符 EOL=End-of-line)

		r, err1 := regexp.Compile(`a$`) // without flag
		s := "atlanta\narkansas\nalabama\narachnophobia"
		//    01234567 890123456 78901234 5678901234567
		//                                            -
		res := r.FindAllStringIndex(s,-1)
		fmt.Printf("<%v>\n", res)
		// 1 match
		// <[[37 38]]>

		t, err2 := regexp.Compile(`(?m)a$`) // with flag
		u := "atlanta\narkansas\nalabama\narachnophobia"
		//    01234567 890123456 78901234 5678901234567
		//          --                 --             -
		res2 := t.FindAllStringIndex(u,-1)
		fmt.Printf("<%v>", res2)
		// 3 matches
		// <[[6 7] [23 24] [37 38]]>

