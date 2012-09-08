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


## Special Characters ##

## Simple Repetition ##

## Anchor and Boundaries ##

## Character Classes ##

EOL, BOL, unicode

