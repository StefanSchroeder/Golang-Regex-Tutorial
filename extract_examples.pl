#
# Extract golang code from Markdown tutorial.
#
# Author: Stefan Schroeder, 2012-09-08
use strict;

my $i = 0;
my $e = "";
my $section = "";
my $insection = 0;
my $marker = "\t \t";

my $code = <<EOT;
```go
package main

import "fmt"
import "regexp"

func main() {
EXAMPLES
}
```
EOT

while(<>)
{
	if(m/$marker/)
	{
		$insection = ($insection + 1) % 2;
		if ($insection)
		{
			$i++;
		}
		else
		{
			$e .= "{ // $i \n" . $section . "} // $i \n";
			$section = '';
		}
	}
	elsif($insection)
	{
		$section .= $_;
	}
}

$code =~ s/EXAMPLES/$e/;

if ($code =~ /strings\./)
{
	$code =~ s/package main\n/package main\nimport "strings"\n/;
}

print $code;

