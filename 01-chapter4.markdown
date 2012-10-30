# Part 4: Alternatives #

## Splitting up a line into tokens ##

If literal strings separate the fields in your input you don't need to use regexps.
	 	
		s := "abc,def,ghi"
		r, err := regexp.Compile(`[^,]+`) // everything that is not a comma
		res:= r.FindAllString(s, -1)
		// Prints [abc def ghi] 
		fmt.Printf("%v", res)
	 	

The *Split*-function in the *strings*-package serves the same purpose and the syntax is more readable

	 	
		s := "abc,def,ghi"
		res:= strings.Split(s, ",")
		// Prints [abc def ghi] 
		fmt.Printf("%v", res)
	 	

## Testing if a specific substring exists in your string ##

The MatchString-function allows you to find a literal string in another string.

	 	
		s := "OttoFritzHermanWaldoKarlSiegfried"
		r, err := regexp.Compile(`Waldo`)
		res:= r.MatchString(s)
		// Prints true 
		fmt.Printf("%v", res)
	 	

But you can avoid the regexp if you use the *strings.Index*-function to retrieve the index of your substring in the string. Index returns -1 if the substring is not present. 

	 	
		s := "OttoFritzHermanWaldoKarlSiegfried"
		res:= strings.Index(s, "Waldo")
		// Prints true
		fmt.Printf("%v", res != -1)
	 	

## Removing Spaces

Whenever you are reading text from a file or from the user you probably want to discard spaces at the beginnning and at the end of the line.

You could use regexps to accomplish that:

	 	
		s := "  Institute of Experimental Computer Science  "
		r, err := regexp.Compile(`\s*(.*)\s*`)
		res:= r.FindStringSubmatch(s)
		// <Institute of Experimental Computer Science  >
		fmt.Printf("<%v>", res[1])
	 	

The first attempt to remove the spaces failed - only the spaces at the head of the string have been removed, the next piece .* was greedy and captured the rest - but I don't bother to figure out the correct regexp for this task, because I know *strings.TrimSpace*.

	 	
		s := "  Institute of Experimental Computer Science  "
		// <Institute of Experimental Computer Science>
		fmt.Printf("<%v>", strings.TrimSpace(s))
	 	

TrimSpace removes the spaces at the beginning and the end; lookup the documentation of the strings package, there are a few more functions in the Trim-family.
