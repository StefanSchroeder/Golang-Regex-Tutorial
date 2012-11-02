# Part 1: The basics #

## Simple Matching ##

You want to know if a string matches a regular expression. The *MatchString*-function returns 'true' if the string-argument matches the regular expression that you prepared with *Compile*.

	package main

	import (
		"fmt"
		"regexp"
	)

	func main() {
		r, err := regexp.Compile(`Hello`)

		if err != nil {
			fmt.Printf("There is a problem with you regexp.\n")
			return
		}

		// Will print 'Match'
		if r.MatchString("Hello Regular Expression.") == true {
			fmt.Printf("Match ")
		} else {
			fmt.Printf("No match ")
		}
	}

*Compile* is the heart of the regexp-package. Every regular expression must be prepared with it before use.

The *Compile*-function returns in its second argument an error value. In this tutorial I will usually discard it, because of course all my regexes are perfect ;-). You might get away with that if your regexps are literals, but if the regexp is derived from input at runtime you definitely want to check the error value.

For the rest of this tutorial the evaluation of the error value is skipped for brevity.

This regular expression will not match:
	 	
	r, err := regexp.Compile(`Hxllo`)
	// Will print 'false'
	fmt.Printf("%v", r.MatchString("Hello Regular Expression."))
	 	
## Character classes ##

Character class '\w' represents any character from the class [A-Za-z0-9_], mnemonic: 'word'. Personally I restrict filenames to that class. 
	 	
	r, err := regexp.Compile(`H\wllo`)
	// Will print 'true'. 
	fmt.Printf("%v", r.MatchString("Hello Regular Expression."))
	 	
Character class '\d' represents any numeric digit.
	 	
	r, err := regexp.Compile(`\d`)
	// Will print 'true':
	fmt.Printf("%v", r.MatchString("Seven times seven is 49."))
	// Will print 'false':
	fmt.Printf("%v", r.MatchString("Seven times seven is forty-nine."))
	 	
Character class '\s' represents any of the following whitespaces: TAB, SPACE, CR, LF. Or more precisely [\t\n\f\r ].
	 	
	r, err := regexp.Compile(`\s`)
	// Will print 'true':
	fmt.Printf("%v", r.MatchString("/home/bill/My Documents"))
	 	
Character classes can be negated by using the uppercase '\D', '\S', '\W'. Thus, '\D' is any character that is *not* a '\d'. 
	 	
	r, err := regexp.Compile(`\S`) // Not a whitespace
	// Will print 'true', obviously there are non-whitespaces here:
	fmt.Printf("%v", r.MatchString("/home/bill/My Documents"))
	 	
Check a filename for validity (Note: Using my definition of valid, see above. Different filesystems/encodings will cause different kinds of problems when you use anything else. Did you know that '\n' is a valid character in filenames according to Posix? [D. Wheeler paper on Posix filenames](http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html).)
	 	
	// FIXME This is nonsense.
	r, err := regexp.Compile(`\W`) // Not a \w character.
	// Will print 'false', there are no non-word characters here:
	fmt.Printf("%v", r.MatchString("my_extraordinary_but_valid_filename.txt"))
	 	
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

### Special Characters ###

The dot '.' matches any character. 
	 	
	// Will print 'cat'.
	r, err := regexp.Compile(`.at`)
	fmt.Printf(r.FindString("The cat sat on the mat."))
	 	
'cat' was the first match.
	 	
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
	 	
## Literal Special Characters ##

Finding one backslash '\': It must be escaped twice in the regex and once in the string.
	 	
	r, err := regexp.Compile(`C:\\\\`)
	if r.MatchString("Working on drive C:\\") == true {
		fmt.Printf("Matches.") // <---
	} else {
		fmt.Printf("No match.")
	}
	 	
Finding a literal dot:
	 	
	r, err := regexp.Compile(`\.`)
	if r.MatchString("Short.") == true {
		fmt.Printf("Has a dot.") // <---
	} else {
		fmt.Printf("Has no dot.")
	}
	 	
The other special characters that are relevant for constructing regular expressions work in a similar fashion: .+*?()|[]{}^$

Finding a literal dollar symbol:
	 	
	r, err := regexp.Compile(`\$`)
	if len(r.FindString("He paid $150 for that software.")) != 0 {
		fmt.Printf("Found $-symbol.") // <-
	} else {
		fmt.Printf("No $$$.")
	}
	 	
## Simple Repetition ##

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
	 	

Now  let's add some spaces around the equal sign.

	 	
	s := "Key = Value"
	r, err := regexp.Compile(`\w+=\w+`)
	res := r.FindAllString(s, -1)
	// FAIL, prints nothing, the \w does not match the space.
	fmt.Printf("%v", res)
	 	
Therefore we allow a number of spaces (including possibly 0) with '\s*':
	 	
	s := "Key = Value"
	r, err := regexp.Compile(`\w+\s*=\s*\w+`)
	res := r.FindAllString(s, -1)
	fmt.Printf("%v", res)
	 	
The Go-regexp pattern supports a few more patterns constructed with '?'.

## Anchor and Boundaries ##

The caret symbol ^ denotes a 'begin-of-line'.
	 	
	s := "Never say never."
	r, err1 := regexp.Compile(`^N`)        // Do we have an 'N' at the beginning?
	fmt.Printf("%v ", r.MatchString(s)) // true
	t, err2 := regexp.Compile(`^n`)        // Do we have an 'n' at the beginning?
	fmt.Printf("%v ", t.MatchString(s)) // false
	 	
The dollar symbol $ denotes an 'end-of-line'.
	 	
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
	 	
## Character Classes ##

Instead of a literal character you can require a set (or class) of characters at any location. In this example [uio] is a "character class". Any of the characters in the square brackets will satisfy the regexp. Thus, this regexp will match 'Hullo', 'Hillo', and 'Hollo' 
	 	
	r, err := regexp.Compile(`H[uio]llo`)
	// Will print 'Hullo'.
	fmt.Printf(r.FindString("Hello Regular Expression. Hullo again."))
	 	
A negated character class reverses the match of the class. In this case it Will match all strings 'H.llo', where the dot is *not* 'o', 'i' or 'u'. It will not match "Hullo", "Hillo", "Hollo", but it will match "Hallo" and even "H9llo".
	 	
	r, err := regexp.Compile(`H[^uio]llo`)
	fmt.Printf("%v ", r.MatchString("Hillo")) // false
	fmt.Printf("%v ", r.MatchString("Hallo")) // true
	fmt.Printf("%v ", r.MatchString("H9llo")) // true
	 	
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
	 	

