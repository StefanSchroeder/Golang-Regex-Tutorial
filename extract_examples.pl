#
# Extract golang code from Markdown tutorial.
#
# Author: Stefan Schroeder, 2012-09-08
use strict;

my $i = 0;
my $in = 0;
my $e = "";
my $section = "";

my $code = <<EOT;
package main

import "fmt"
import "regexp"

func main() {
EXAMPLES
}
EOT

while(<>)
{
	if(m/^\t/ and $section eq '')
	{
		$i++;
		$section .= $_;
	}
	elsif(m/^\t/)
	{
		$section .= $_;
	}
	else
	{
		$in = 0;
		if($section)
		{
			$e .= "{ // $i \n" . $section . "} // $i \n" if ($i != 1);
			$section = '';
		}
	}
}

$code =~ s/EXAMPLES/$e/;

print $code;

		

