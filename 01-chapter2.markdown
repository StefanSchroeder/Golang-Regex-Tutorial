# Part 2: Advanced #

## Groups ##

Sometimes you want to match against a string, but want to peek at a particular slice only. In the previous chapter we always looked at the *entire* matching string.
	 	
		//[[cat] [sat] [mat]]
		re, err := regexp.Compile(`.at`)
		res := re.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", res)
	 	
Parentheses allow to capture that piece of the string that you are actually interested in, instead of the entire regex.
	 	
		//[[cat c] [sat s] [mat m]]
		re, err := regexp.Compile(`(.)at`) // want to know what is in front of 'at'
		res := re.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", res)
	 	
You can have more than one group.
	 	
		// Prints [[ex e x] [ec e c] [e  e  ]]
		s := "Nobody expects the Spanish inquisition."
		re1, err := regexp.Compile(`(e)(.)`) // Prepare our regex
		result_slice := re1.FindAllStringSubmatch(s, -1)
		fmt.Printf("%v", result_slice)
	 	
The *FindAllStringSubmatch*-function will, for each match, return an array with the entire match in the first field and the content of the groups in the remaining fields. The arrays for all the matches are then captured in a container array.

If you have an optional group that does not appear in the string, the resulting array will have an empty string in its cell, in other words, the number of fields in the resulting array always matches the number of groups plus one.
	 	
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
	 	
You cannot have partially overlapping groups. If we wanted the first regexp to match 'expects the' and the other to match 'the Spanish', the parentheses would be interpreted differently. Motto is: Last opened, first closed. The parentheses that is opened for 'the' is closed after 'the'.   
	 	
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

The *FindStringSubmatchIndex*-function ...

## Named matches ##

It is somewhat awkward that the matches are simply stored in sequence in arrays. Two different kinds of problems arise.

First, when you insert a new group somewhere in your regular expression all the array indexes in the following matches must be incremented. That's a nuisance.

Second, the string might be constructed at runtime and may contain a number of parentheses that is beyond our control. That means that we don't know at which index our nicely constructed parentheses match. 

To resolve this issue _named matches_ were introduced. They allow to give a symbolic name to the match that can be used to look up the result.

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

In this example the string 'Super' is matched against a regexp that has three parts:

A single character (.) which is named 'first_char'. 
	
A middle part composed of a sequence of characters, named 'middle_part'

A last character (.), consequently named 'last_char'.

To simplify the usage of the results, we store all the names in n1 and zip them together with the match result r2 into  a new map in which we store the results as values for the named variables in a map named _md_.

Note that the entire string 'Super' has the empty-string as a pseudo-key. 

The sample prints

	0. match='Super'	name=''
	1. match='S'	name='first_char'
	2. match='upe'	name='middle_part'
	3. match='r'	name='last_char'
	The names are  : [ first_char middle_part last_char]
	The matches are: [Super S upe r]
	The first character is S
	The last  character is r


# Advanced Repetition #

## Non-matching capture/group repetition #

If a complex regular expressions has several groups you might arrive at a situation where we use parentheses for grouping but are not the least interested in the captured string. To discard the match of a group you can make it a 'non-capturing group' with (?:regex). The question mark and colon tell the compiler to use the pattern for matching but not to store it.

Without a non-capturing group:
	 	
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
	 	
With a non-capturing group:
	 	
	s := "Mrs. Leonora Spock"
	re1, err := regexp.Compile(`Mr(?:s)?\. (\w+) (\w+)`)
	result:= re1.FindStringSubmatch(s)
	for k, v := range result {
		fmt.Printf("%d. %s\n", k, v)
	}
	// 0. Mrs. Leonora Spock
	// 1. Leonora
	// 2. Spock
	 	
## How many exactly? ##

The number of required repetitions might be well known. If you know how many instances you need of parts of your regexp we will need {}.
	 	
	s := "11110010101111100101001001110101"
	re1, err := regexp.Compile(`1{4}`)
	res := re1.FindAllStringSubmatch(s,-1)
	fmt.Printf("<%v>", res)
	// <[[1111] [1111]]>
	
	res2 := re1.FindAllStringIndex(s,-1)
	fmt.Printf("<%v>", res2)
	// <[[0 4] [10 14]]>
	 	
The {} syntax is rarely used. One of the reasons being that in many (all?) cases you can rewrite the regexp by simply writing out the number of repetitions literally. [I can see that you might not want to do that for, say, 120.] Only when you have very specific requirements (like {123,130}) you will want to use {}.

    (ab){3} == (ababab)
    (ab){3,4} == (ababab(ab)??)

> Side note: ?? stands for "zero or one x, prefer zero".

The general pattern for {} is x{n,m}. 'n' is the minimum number of occurrences and 'm' is the maximum number of occurences.

The Go-regexp package supports a few more patterns in the {} familiy.

# Flags #

The regexp package knows the following flags [quote from documentation]:

* i	case-insensitive (default false)
* m	multi-line mode: ^ and $ match begin/end line in addition to begin/end text (default false)
* s	let . match \n (default false)
* U	ungreedy: swap meaning of x* and x*?, x+ and x+?, etc (default false)

Flag syntax is xyz (set) or -xyz (clear) or xy-z (set xy, clear z).

## Case sensitivity ##

You might already know that some characters exist in two cases: Upper and lower. [Now you might say: "Of course I know that, everybody knows that!" Well, if you think that this is trivial then consider the upper/lowercase question is these few cases: a, $, 本, ß, Ω. Ok, let's not complicate things and only consider English.]

If you explicitly want to ignore the case, in other words, if you want to permit both cases for a regexp or a part of it, you use the 'i' flag.
	 	
		s := "Never say never."
		r, err := regexp.Compile(`(?i)^n`)     // Do we have an 'N' or 'n' at the beginning?
		fmt.Printf("%v", r.MatchString(s)) // true, case insensitive
	 	
Matching against a case-insensitive regexp is rarely done is the real world. Usually we prefer to convert the entire string to either upper or lower case in the first place and then match only against that case:
	 	
		sMixed := "Never say never."
		sLower := strings.ToLower(sMixed) // don't forget to import "strings"
		r, err := regexp.Compile(`^n`)
		fmt.Printf("%v ", r.MatchString(sMixed))  // false, N != n
		fmt.Printf("%v ", r.MatchString(sLower))  // true,  n == n
	 	
## Greedy vs. Non-Greedy ##

As we saw before, regular expressions may contain repetition symbols. In some cases, there is actually more than one solution possible for a regexp to match a given string.

E.g. given the regexp '.*' (including the quotes), how would this match against:

    'abc','def','ghi'

You are probably expecting to retrieve *'abc'*. Not so. By default, regular expressions are _greedy_. They will take as many characters as possible to match the regexp. Thus the answer is *'abc','def','ghi'*, because the quotes in between also match the dot "."! Like here:
	 	
		r, err := regexp.Compile(`'.*'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc','def','ghi'>
	 	
To identify the shortest possible match (=non-greedy) you add the special character '?' to your regular expression.
	 	
		r, err := regexp.Compile(`'.*?'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc'>
	 	
There is no easy way that would allow you to specify a regexp that would match 'abc','def'.

You can revert the behavior of the regular expression to make being non-greedy the default with the flag U
	 	
		r, err := regexp.Compile(`(?U)'.*'`)
		res := r.FindString(" 'abc','def','ghi' ")
		fmt.Printf("<%v>", res)
		// Will print: <'abc'>
	 	
It is possible to switch back and forth between the two behaviors inside your regexp. (FIXME Example)

## Shall Dot Match Newline? ##

When we have a multiline string (=a string that contains newlines '\n') you can control
if the '.' matches against the newline character using the (?s) flag. Default is false. Could someone please provide a sensible use-case?
	 	
		r, err := regexp.Compile(`a.`)
		s := "atlanta\narkansas\nalabama\narachnophobia"
		res := r.FindAllString(s, -1)
		fmt.Printf("<%v>", res)
		// <[at an ar an as al ab am ar ac]>
	 	
Now using the the (?s) flag, the newline is kept in the result.
	 	
		r, err := regexp.Compile(`(?s)a.`)
		s := "atlanta\narkansas\nalabama\narachnophobia"
		res := r.FindAllString(s, -1)
		fmt.Printf("<%v>", res)
		// Prints
		// <[at an a
		// ar an as al ab am a
		// ar ac]>
	 	
Clear out multi-line comments in css file

		s := `/* multi line
		comment with
		url("http://commented1.test.com/img.jpg") */
		body {
		  background: #ffffff url("actual1.png") no-repeat right top;
		}
		/* single line commented out url("http://commented2.test.com/img.jpg") *//* back to back comment */
		.test-img {
		  background-image: url("http://test.com/actual2.png");
		}`

		re := regexp.MustCompile(`(?s)(?:/\*.*?\*/)?((?:[^/]|/[^*])*)`)
		results := re.FindAllStringSubmatch(s, -1)
		for _, v := range results {
			if v[1] != "" {
				fmt.Printf("%s", v[1])
			}
		}

## Shall ^/$ Match at a Newline? ##

When we have a multiline string you can control
if the '^' (BOL=Begin-of-line) or '$' (EOL=End-of-line) matches *at* the newline character with the flag '(?m)'. Default is false.
	 	
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
	 	
