# Part 4: Alternatives #

## Splitting up a line into tokens ##

If literal strings separate the fields in your input you don't need to use regexps.

```go
s := "abc,def,ghi"
r, err := regexp.Compile(`[^,]+`) // everything that is not a comma
res := r.FindAllString(s, -1)
// Prints [abc def ghi] 
fmt.Printf("%v", res)
``` 	

The *Split*-function in the *strings*-package serves the same purpose and the syntax is more readable

```go
s := "abc,def,ghi"
res:= strings.Split(s, ",")
// Prints [abc def ghi] 
fmt.Printf("%v", res)
```

As a convenience the Standard library also provides the *Fields* function in the strings-package,
that splits a string at white space:

```go
fmt.Printf("Fields are: %q", strings.Fields("  Frodo Thorin  Dwalin   "))
```

yields:

		Fields are: ["Frodo" "Thorin" "Dwalin"]
		
You can even provide a more sophisticated function the variant *FieldsFunc*. It takes
your string and a function as parameter. The function must accept a rune as a parameter.

## FieldsFunc-Example

Suppose you want to process comma separated values (good ol' CSV). The naive implementation
with *Split* would work in most cases, but sometimes you have commas embedded in a single field.
Typically the user then uses quotes to protect that field (and thus the comma inside) from being split.

This example uses a global boolean (boo!) to keep track of quoting (obviously there is more than one
way to break this), but it works for simple cases.

```go
package main
import (
	"fmt"
	"strings"
)
var inQuotes = false
func main() {
	s := " 1 , 4, \" xx,yy \", 5 "
	f := func(c rune) bool {
		if c== '"' {
			inQuotes = !inQuotes
		}
		if inQuotes == false && c == ',' {
			return true
		}
		return false
	}
	for k, v := range strings.FieldsFunc(s, f) {
		fmt.Printf ("%v: %v\n", k, v)
	}
}
```

Prints:

	0:  1 
	1:  4
	2:  " xx,yy "
	3:  5 

As an exercise you might want to delete the quotes (Hint: *Trim* is your friend.)


## Testing if a specific substring exists in your string ##

The *MatchString*-function allows you to find a literal string in another string.

```go 	
s := "OttoFritzHermanWaldoKarlSiegfried"
r, err := regexp.Compile(`Waldo`)
res := r.MatchString(s)
// Prints true 
fmt.Printf("%v", res)
```	

But you can avoid the regexp if you use the *strings.Index*-function to retrieve the index of your substring in the string. Index returns -1 if the substring is not present. 

```go	 	
s := "OttoFritzHermanWaldoKarlSiegfried"
res:= strings.Index(s, "Waldo")
// Prints true
fmt.Printf("%v", res != -1)
``` 	

## Removing Spaces

Whenever you are reading text from a file or from the user you probably want to discard spaces at the beginnning and at the end of the line.

You could use regexps to accomplish that:

```go	 	
s := "  Institute of Experimental Computer Science  "
r, err := regexp.Compile(`\s*(.*)\s*`)
res:= r.FindStringSubmatch(s)
// <Institute of Experimental Computer Science  >
fmt.Printf("<%v>", res[1])
``` 	

The first attempt to remove the spaces failed - only the spaces at the head of the string have been removed, the next piece .* was greedy and captured the rest - but I don't bother to figure out the correct regexp for this task, because I know *strings.TrimSpace*.

```go	
s := "  Institute of Experimental Computer Science  "
// <Institute of Experimental Computer Science>
fmt.Printf("<%v>", strings.TrimSpace(s))
``` 	

TrimSpace removes the spaces at the beginning and the end; lookup the documentation of the strings package, there are a few more functions in the Trim-family.
