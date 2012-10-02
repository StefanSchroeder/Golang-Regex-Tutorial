# Part 2: Advanced #

## Groups ##

Parentheses allow to capture that piece of the string that you are actually interested in, instead of the entire regex.

		//[[cat] [sat] [mat]]
		re3, _ := regexp.Compile(`.at`)
		result_slice := re3.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", result_slice)

		//[[cat c] [sat s] [mat m]]
		re3, _ := regexp.Compile(`(.)at`)
		result_slice := re3.FindAllStringSubmatch("The cat sat on the mat.", -1)
		fmt.Printf("%v", result_slice)

You can have more than one group.

		// Prints [[ex e x] [ec e c] [e  e  ]]
		s := "Nobody expects the Spanish inquisition."
		re1, _ := regexp.Compile(`(e)(.)`) // Prepare our regex
		result_slice := re1.FindAllStringSubmatch(s, -1)
		fmt.Printf("%v", result_slice)

The *FindAllStringSubmatch*-function will, for each match, return an array with the entire match in the first field and the content of the groups in the remaining fields. The arrays for all the matches are then captured in a container array.


## Advanced Repetition ##

+* again 

{1,2}

## Backreferences ##
Ha! The re2-engine that Go uses does not support back references. But, honestly, I have never used them anyway.

## Case sensitivity ##

You might already know that some characters exist in two cases: Upper and lower. [Now you might say: "Of course I know that, everybody knows that!" Well, if you think that this is trivial then consider the upper/lowercase question is these few cases: a, $, 本, ß, Ω. Ok, let's not complicate things and only consider English.]

If you explicitly want to ignore the case, in other words, if you want to permit both cases for a regexp or a part of it, you use the 'i' flag.

		s := "Never say never."
		re1, _ = regexp.Compile(`(?i)^n`)     // Do we have an 'N' or 'n' at the beginning?
		fmt.Printf("%v ", re1.MatchString(s)) // true, case insensitive

Matching against a case-insensitive regexp is rarely done is the real world. Usually we prefer to convert the entire string to either upper or lower case in the first place and then match only against that case:

		sMixed := "Never say never."
		sLower := strings.ToLower(s) // don't forget to import "strings"
		re1, _ := regexp.Compile(`^n`)
		fmt.Printf("%v ", re1.MatchString(s))      // false, N != n
		fmt.Printf("%v ", re1.MatchString(sLower)) // true,  n == n
