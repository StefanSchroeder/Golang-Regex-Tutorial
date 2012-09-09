# Part 1: The basics #

## Simple Matching ##

You want to know if a string matches a simple regular expression.

 	package main
 	import ( "regexp"
 		     "fmt" )
 	
 	func main() {
 		re1, _ := regexp.Compile(`Hello`)
 	
 		// Will print 'Match'
 		if re1.MatchString("Hello Regular Expression.") == true {
 			fmt.Printf("Match ")
 		} else {
 			fmt.Printf("No match ")
 		}
 	}

The Compile-function returns in its second argument an error code. In this tutorial I will usually discard it, because of course all my regexes are perfect ;-).

For the rest of this tutorial the enclosing main function will always be assumed.

This regular expression will not match:

	re2, _ := regexp.Compile(`Hxllo`)
	// Will print 'false'
	fmt.Printf("%v ", re2.MatchString("Hello Regular Expression."))

Character class '\w' represents any character from the class [a-z0-9_].

	re3, _ := regexp.Compile(`H\wllo`)
	// Will print 'true'. 
	fmt.Printf("%v ", re3.MatchString("Hello Regular Expression."))

Character class '\d' represents any numeric digit.

	re4, _ := regexp.Compile(`H\dllo`)
	// Will print 'false'. .
	fmt.Printf("%v ", re4.MatchString("Hello Regular Expression."))

The FindString-function finds a string. When you use a literal string, the result will obviuosly be the string itself. Only when you start using patters and classes the result will be more interesting.

		re1, _ := regexp.Compile(`Hello`)
		// Will print 'Hello'
		fmt.Printf(re1.FindString("Hello Regular Expression. Hullo again."))
	
		// Careful: The empty string might be the result of a proper match.
		if len(re1.FindString("Hello Regular Expression. Hullo again.")) == 0 {
			fmt.Printf("Match has zero-length == No match\n")
		} else {
			fmt.Printf("Matches!\n")
		}

		// Will print nothing (=the empty string)
		re2, _ := regexp.Compile(`Hxllo`)
		fmt.Printf(re2.FindString("Hello Regular Expression."))


## Special Characters ##

The dot '.' matches any character.

		// Will print 'Hello'. (Leftmost match).
		re3, _ := regexp.Compile(`H.llo`)
		fmt.Printf(re3.FindString("Hello Regular Expression."))

		// Prints [ex e x]
		s := "Nobody expects the Spanish inquisition."
		re1, _ := regexp.Compile(`(e)(.)`) // Prepare our regex
		result_slice := re1.FindStringSubmatch(s)
		fmt.Printf("%v", result_slice)

		// more dot.
		s:= "Nobody expects the Spanish inquisition."
		//          -- --     --
		re1, _ := regexp.Compile(`e.`)
		result_slice := re1.FindAllString(s, -1) // negative: all matches
		// Prints [ex ec e ]. The last item is 'e' and a space.
		fmt.Printf("%v", result_slice)
		result_slice = re1.FindAllString(s, 2) // find 2 or less matches
		// Prints [ex ec]. 
		fmt.Printf("%v", result_slice)

## Literal Special Characters ##

Finding one backslash '\'. It must be escaped twice in the regex and once in the string.

		re5, _ := regexp.Compile(`C:\\\\`)
		if re5.MatchString("Working on drive C:\\") == true {
			fmt.Printf("Matches.")
		} else {
			fmt.Printf("No match.")
		}

Finding a literal dot:

		re6, _ := regexp.Compile(`\.`)
		if re6.MatchString("Short.") == true {
			fmt.Printf("Has a dot.") // <-
		} else {
			fmt.Printf("Has no dot.")
		}

The other special characters that are relevant for constructing regular expressions work in a similar fashion: .+*?()|[]{}^$

Finding a literal dollar symbol:

		re7, _ := regexp.Compile(`\$`)
		if len(re7.FindString("He paid $150 for that software.")) != 0 {
			fmt.Printf("Found $-symbol.") // <-
		} else {
			fmt.Printf("No $$$.")
		}

## Simple Repetition ##

Finding words. A word is a set of characters of type \w.
The plus symbol '+' signifies a repetition:

		s := "Eenie meenie miny moe."
		re1, _ := regexp.Compile(`\w+`)
		result_slice := re1.FindAllString(s, -1)
		// Prints [Eenie meenie miny moe]
		fmt.Printf("%v", result_slice)

## Anchor and Boundaries ##

The caret symbol ^ denotes a 'begin-of-line'.

		s := "Never say never."
		re1, _ := regexp.Compile(`^N`)        // Do we have an 'N' at the beginning?
		fmt.Printf("%v ", re1.MatchString(s)) // true
	
		re1, _ = regexp.Compile(`^n`)         // Do we have an 'n' at the beginning?
		fmt.Printf("%v ", re1.MatchString(s)) // false
	
		re1, _ = regexp.Compile(`(?i)^n`)     // Do we have an 'N' or 'n' at the beginning?
		fmt.Printf("%v ", re1.MatchString(s)) // true again, case insensitive

The last regular expression introduced a new concept: (?i) denotes case-insensitivity. (See next section.)

The dollar symbol $ denotes an 'end-of-line'.

		s := "All is well that ends well"
		re1, _ := regexp.Compile(`well$`)
		fmt.Printf("%v ", re1.MatchString(s)) // true
	
		re1, _ = regexp.Compile(`well`)
		fmt.Printf("%v ", re1.MatchString(s)) // true, but matches with first
										      // occurrence of 'well'
		re1, _ = regexp.Compile(`ends$`)
		fmt.Printf("%v ", re1.MatchString(s)) // false, not at end of line.

We saw that 'well' matched. To figure out, where exactly the regexp matched, let's have a look at the indexes.

		s := "All is well that ends well"
		//    012345678901234567890123456
		//              1         2
		re1, _ := regexp.Compile(`well$`)
		fmt.Printf("%v", re1.FindStringIndex(s)) // Prints [22 26]
	
		re1, _ = regexp.Compile(`well`)
		fmt.Printf("%v ", re1.MatchString(s)) // true, but matches with first
						 					  // occurrence of 'well'
		fmt.Printf("%v", re1.FindStringIndex(s)) // Prints [7 11]
	
		re1, _ = regexp.Compile(`ends$`)
		fmt.Printf("%v ", re1.MatchString(s)) // false, not at end of line.

You can find a word boundary with '\b'.

		s := "How much wood would a woodchuck chuck in Hollywood?"
		//    012345678901234567890123456789012345678901234567890
		//              10        20        30        40        50
		//             -1--         -2--                    -3--
		// Find words that *start* with wood
		re1, _ := regexp.Compile(`\bwood`)              //    1      2
		fmt.Printf("%v", re1.FindAllStringIndex(s, -1)) // [[9 13] [22 26]]
	
		// Find words that *end* with wood
		re1, _ = regexp.Compile(`wood\b`)               //   1      3 
		fmt.Printf("%v", re1.FindAllStringIndex(s, -1)) // [[9 13] [46 50]]
	
		// Find words that *start* and *end* with wood
		re1, _ = regexp.Compile(`\bwood\b`)             //   1
		fmt.Printf("%v", re1.FindAllStringIndex(s, -1)) // [[9 13]]


## Flags ##

The regexp package knows the following flags:

* i	case-insensitive (default false)
* m	multi-line mode: ^ and $ match begin/end line in addition to begin/end text (default false)
* s	let . match \n (default false)
* U	ungreedy: swap meaning of x* and x*?, x+ and x+?, etc (default false)

Flag syntax is xyz (set) or -xyz (clear) or xy-z (set xy, clear z).

## Character Classes ##

Instead of a literal character you can require a set (or class) of characters at any location. In this example [uio] is a "character class". Any of the characters in the square brackets will satisfy the regexp. Thus, this regexp will match 'Hullo', 'Hillo', and 'Hollo' 
		
		re1, _ := regexp.Compile(`H[uio]llo`)
		// Will print 'Hullo'.
		fmt.Printf(re1.FindString("Hello Regular Expression. Hullo again."))

A negated character class reverses the match of the class. Will match all strings 'H.llo', where the dot is *not* 'o', 'i' or 'u'. It will not match "Hullo", "Hillo", "Hollo", but it will match "Hallo" and even "H9llo".

		re2, _ := regexp.Compile(`H[^uio]llo`)
		fmt.Printf("%v ", re2.MatchString("Hillo")) // false
		fmt.Printf("%v ", re2.MatchString("Hallo")) // true
		fmt.Printf("%v ", re2.MatchString("H9llo")) // true

EOL, BOL, unicode

