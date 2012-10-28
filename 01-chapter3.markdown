# Part 3: Cookbook #

## grep ##

The grep-tool searches for (regular) expressions in text files. Every single line is read and if the line matches the pattern provided on the command line, that line is printed.
	 	
	package main

	import (
		"flag"
		"regexp"
		"bufio"
		"fmt"
		"os"
	)

	func grep(re, filename string) {
	    regex, _ := regexp.Compile(re)

	    fh, err := os.Open(filename)
	    f := bufio.NewReader(fh)

	    if err != nil {
			return // there was a problem opening the file.
	    }
	    defer fh.Close()

	    buf := make([]byte, 1024)
	    for {
			buf, _ , err = f.ReadLine()
			if err != nil {
				return
			}

			s := string(buf)
			if regex.MatchString(s) {
				fmt.Printf("%s\n", string(buf))
			}
	    }
	}

	func main() {
		flag.Parse()
		if flag.NArg() == 2 {
			grep(flag.Arg(0), flag.Arg(1))
		} else {
			fmt.Printf("Wrong number of arguments.\n")
		}
	}
	 	
If you don't know what grep does, search 'man grep'.


## Search and Replace ##

This tool is an improved version of grep. It does not only search for a pattern, but also replaces the pattern with something else. We will obviously want to build on the existing grep solution.

Usage: ./replacer old new filename

	 	
	package main

	import (
		"flag"
		"regexp"
		"bufio"
		"fmt"
		"os"
	)

	func replace(re, repl, filename string) {
	    regex, _ := regexp.Compile(re)

	    fh, err := os.Open(filename)
	    f := bufio.NewReader(fh)

	    if err != nil {
			return // there was a problem opening the file.
	    }
	    defer fh.Close()

	    buf := make([]byte, 1024)
	    for {
			buf, _ , err = f.ReadLine()
			if err != nil {
				return
			}

			s := string(buf)
			result := regex.ReplaceAllString(s, repl)
			fmt.Print(result + "\n")
	    }
	}

	func main() {
		flag.Parse()
		if flag.NArg() == 3 {
			repl(flag.Arg(0), flag.Arg(1), flag.Arg(2))
		} else {
			fmt.Printf("Wrong number of arguments.\n")
		}
	}
	 	
## Verifying an email-address ##

Interestingly the RFC 2822 which defines the format of email-addresses is pretty permissive.
That makes it hard to come up with a simple regular expression. In most cases though your 
application can make some assumptions about addresses and I found this one sufficient for
all practical purposes:

	(\w[-._\w]*\w@\w[-._\w]*\w\.\w{2,3})

It must start with a character of the \w class. Then we can have any number of characters including the hyphen, the '.' and the underscore. We want the last character before the @ to be a 'regular' character again. We repeat the same pattern for the domain, only that the suffix (part behind the last dot) can be only 2 or 3 characters. This will cover most cases. If you come across an email address that does not match this regexp it has probably deliberately been setup to annoy you and you can therefore ignore it.

