## Introduction ##

This small tutorial tries to teach you the basics of using regular expressions with Go. It is neither an introduction into Go, nor an introduction into regular expressions. The intended audience consists of developers that already have a concept of both and want to see how these go together in practice. It sports a cookbook approach. Every example is supposed to be complete, ready for copy-and-paste.

The text was written in Markdown.

In the first version I am going to cover only functions from the regexp-package that deal with strings, because I feel that this is the most common use. The regexp-package has some forty functions; make sure you read the package documentation.

[Part 1: The Basics](01-chapter1.markdown): The basics of using regular expressions.

[Part 2: Advanced](01-chapter2.markdown): More sophisticated regular expressions.

[Part 3: Cookbook](01-chapter3.markdown): A few examples programs.

[Part 4: Alternatives](01-chapter4.markdown): When regexps are not the right solution.

*References:*

[Official documentation of the regexp package](http://golang.org/pkg/regexp/)

[re2 regular expression library](https://code.google.com/p/re2/)

[Russ Cox' entry page for things regular expressions](http://swtch.com/~rsc/regexp/)

Mark McGranaghan set up a nice website with Go examples. There is also a 
[page on regular expressions](https://gobyexample.com/regular-expressions)

Rob Pike has more to say about [Regular expressions in lexing and parsing](http://commandcenter.blogspot.ch/2011/08/regular-expressions-in-lexing-and.html).

If you have a Go related problem that you cannot solve alone, you want to go to
[Golang-Nuts mailing list](https://groups.google.com/group/golang-nuts). 
But you probably already knew that.

[Perl regexp tutorial](http://perldoc.perl.org/perlretut.html) For inspiration.

> Version 0.1 Initial.

> This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.

Written by Stefan Schroeder.

