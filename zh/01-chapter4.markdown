# 第四部分：换个思路 #

## 把一句话分词 ##

如果输入部分字面量是字符串，你则不必使用正则。
	 	
		s := "abc,def,ghi"
		r, err := regexp.Compile(`[^,]+`) // everything that is not a comma
		res := r.FindAllString(s, -1)
		// Prints [abc def ghi] 
		fmt.Printf("%v", res)
	 	

*strings* 包里面的 *Split* 函数就是用来做这个的，而且语法更可读。
	 	
		s := "abc,def,ghi"
		res:= strings.Split(s, ",")
		// Prints [abc def ghi] 
		fmt.Printf("%v", res)
	 	

## 验证在一个字符串里是否存在一个指定的子字符串 ##

使用 *MatchString* 函数可以在一个字符串里查找另一个字面量的字符串。

	 	
		s := "OttoFritzHermanWaldoKarlSiegfried"
		r, err := regexp.Compile(`Waldo`)
		res := r.MatchString(s)
		// Prints true 
		fmt.Printf("%v", res)
	 	

但是使用 *strings.Index* 函数可以在字串中获取匹配到子串的索引。当不匹配时则返回的索引为-1。

	 	
		s := "OttoFritzHermanWaldoKarlSiegfried"
		res:= strings.Index(s, "Waldo")
		// Prints true
		fmt.Printf("%v", res != -1)
	 	

## 删除空格

每当你读一些来自文件或是用户的文本时，你可能都想忽略那些句子开头和末尾的空格。

你可以用正则来搞定：
	 	
		s := "  Institute of Experimental Computer Science  "
		r, err := regexp.Compile(`\s*(.*)\s*`)
		res:= r.FindStringSubmatch(s)
		// <Institute of Experimental Computer Science  >
		fmt.Printf("<%v>", res[1])
	 	
首次移除空格大作战以失败告终。只有字符串开头前面的空格被删除了，接下来的 .* 这个片段是贪婪匹配，所以它会捕获余下的全部内容。但是对于这样的任务我不想继续折腾正则了，因为我知道还有 *strings.TrimSpace* 这个东东。
	 	
		s := "  Institute of Experimental Computer Science  "
		// <Institute of Experimental Computer Science>
		fmt.Printf("<%v>", strings.TrimSpace(s))
	 	

TrimSpace 删除了开头和结尾的空格。翻阅 *strings* 包的文档会发现 Trim 家族还有其它一些函数。 
