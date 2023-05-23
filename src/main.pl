use v5.36;
use lib '.';
use MLA;


my $msg = "Hey, Stud\n";

if ($msg =~ $MLA::name_pattern) {
	print "$msg";
}

# Open the program,

# Take in a formatted bibliography, pattern match it, & export it as raw citation info to an organized text file (bibliograpy_name.raw.txt)
# If one of the authors is "and others", then use some API to retrieve the authors, excluding the author that is saved

# Alternatively, submit raw citation info one at a time and pass them into the correct order into a new or existing raw file

# Select a citation style, copy the raw file, rewrite the raw copy in the chosen style, then save it as a formatted bibliography (rich text or html)
