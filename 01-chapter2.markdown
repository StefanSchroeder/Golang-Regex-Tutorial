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

The *FindAllStringSubmatch*-function will, for each match, return an array with the entire match in the first field and the content of the groups in the remaining field. The arrays for all the matches are then captured in a container array.


## Advanced Repetition ##

{1,2}

## Backreferences ##
Ha! The re2-engine that Go uses does not support back references. But, honestly, I have never used them anyway.

## Case sensitivity ##

You might already know that some characters exist in two cases: Upper and lower. And now you might say: "Of course I know that, everybody knows that!" Well, if you think that this is trivial and a foregone conclusion, then consider the upper/lowercase question is these few cases: a, $, 本, ß, Ω. Ok, let's not complicate things and only consider English.

