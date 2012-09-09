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

The FindString-function ...

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

THe dot.

		// Will print 'Hello'. (Leftmost match).
		// '.' matches any character.
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
		result_slice := re1.FindAllString(s, -1) // negative: all
		// Prints [ex ec e ]. The last item is 'e' and a space.
		fmt.Printf("%v", result_slice)
		result_slice = re1.FindAllString(s, 2) // find 2 or less matches
		// Prints [ex ec]. 
		fmt.Printf("%v", result_slice)

## Literal Special Characters ##

		// Finding one backslash '\'. It must be escaped twice
		// in the regex and once in the string.
		re5, _ := regexp.Compile(`C:\\\\`)
		if re5.MatchString("Working on drive C:\\") == true {
			fmt.Printf("Matches.")
		} else {
			fmt.Printf("No match.")
		}

		fmt.Printf("\n----------------------\n");

		// Similiarly for the other special characters that are relevant
		// for constructing regular expressions: .+*?()|[]{}^$
		// Note the reversed logic compared to the previous example.
		re6, _ := regexp.Compile(`\.`)
		if re6.MatchString("Short.") == true {
			fmt.Printf("Has a dot.") // <-
		} else {
			fmt.Printf("Has no dot.")
		}

		fmt.Printf("\n----------------------\n");

		re7, _ := regexp.Compile(`\$`)
		if len(re7.FindString("He paid $150 for that software.")) != 0 {
			fmt.Printf("Found $-symbol.") // <-
		} else {
			fmt.Printf("No $$$.")
		}

## Simple Repetition ##

Finding words. A word is a set of characters of type \w.
'+' means: 1 or more of this.

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
	
If you want your regular ex

		re1, _ = regexp.Compile(`(?i)^n`)     // Do we have an 'N' or 'n' at the beginning?
		fmt.Printf("%v ", re1.MatchString(s)) // true again, case insensitive

The dollar symbol $ denotes an 'end-of-line'.

		s := "All is well that ends well"
		re1, _ := regexp.Compile(`well$`)
		fmt.Printf("%v ", re1.MatchString(s)) // true
	
		re1, _ = regexp.Compile(`well`)
		fmt.Printf("%v ", re1.MatchString(s)) // true, but matches with first
										      // occurrence of 'well'
		re1, _ = regexp.Compile(`ends$`)
		fmt.Printf("%v ", re1.MatchString(s)) // false, not at end of line.

		// '$' ends-with.
		s := "All is well that ends well"
		//    012345678901
		re1, _ := regexp.Compile(`well$`)
		fmt.Printf("%v ", re1.MatchString(s)) // true
		fmt.Printf("%v", re1.FindStringIndex(s)) // Prints [22 26]
	
		re1, _ = regexp.Compile(`well`)
		fmt.Printf("%v ", re1.MatchString(s)) // true, but matches with first
						      // occurrence of 'well'
		fmt.Printf("%v", re1.FindStringIndex(s)) // Prints [7 11]
	
		re1, _ = regexp.Compile(`ends$`)
		fmt.Printf("%v ", re1.MatchString(s)) // false, not at end of line.


		// '\b' word boundary
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

## Character Classes ##

		// [uio] is a "character class". Any of the characters in the
		// squar brackets will do.
		// So this will match 'Hullo', 'Hillo', and 'Hollo' 
		re1, _ := regexp.Compile(`H[uio]llo`)
		// Will print 'Hullo'.
		fmt.Printf(re1.FindString("Hello Regular Expression. Hullo again."))

		// Negated character class. Will match all strings 'H.llo', where the
		// dot is _not_ 'o', 'i' or 'u'. Thus will not match 
		// "Hullo", "Hillo", "Hollo", but it will match "Hallo" and even "H9llo".
		re2, _ := regexp.Compile(`H[^uio]llo`)
		fmt.Printf("%v ", re2.MatchString("Hillo")) // false
		fmt.Printf("%v ", re2.MatchString("Hallo")) // true
		fmt.Printf("%v ", re2.MatchString("H9llo")) // true

EOL, BOL, unicode

