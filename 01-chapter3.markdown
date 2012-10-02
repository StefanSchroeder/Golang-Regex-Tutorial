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

This tool is an improved version of grep. It does not only search for a pattern, but can also replace the pattern with something else. We will obviously want to build on the existing grep solution.

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


