
use v5.14;
use Getopt::Long;
use File::Basename;
use lib dirname($0);

use MLA;

# Setup raw/save directory access
my $dir = dirname($0);
my $root = dirname($dir);
my $raw_dir = $root.'/raw_bibs/';
my $save_dir = $root.'/saved_bibs/';
	
# Set the program state
my $state = 'main';
	

	
my @style;
sub style { my ($arg) = @_; push @style, $arg; }
sub check_style {
	if (@style > 1 || @style == 0) { 
		my $style_count = @style;
		print "Expected exactly 1 CITATION_STYLE flag. $style_count found.\n";
	       	return 0;	
	} else { return 1; }
}

	#### TO DO ####
my @option;
sub option {}
sub check_option {}

my $help;
my $test;
my $convert;
my $export;

GetOptions (
# Need to make these options mutually exclusive and check for multiples before calling subroutines
	'test|T' => \&test,
	'help|H' => \&help,
	'convert|C=s{1,2}' => \$convert,
	'export|X=s{1,2}' => \&export,

	'MLA' => sub { &style("MLA") },
	'RAW' => sub { &style("RAW") },
) or help();

	#### TO DO ####
	# if (check_option()) {}
if ($convert) {&convert()}


sub test {
	# Test the libs
	my $msg = "Hello, Sexy\n";
	
	if ($msg =~ $MLA::name_pattern) {
		print "$msg";
	}
	
	# Test the dirs
	if (-d $save_dir && -d $raw_dir) {
		print "Save directory detected: $save_dir\n";
		print "Raw directory detected: $raw_dir\n";
	} else {
		print "Save/Raw directories not found. Have you set up your program correctly?\n";
	}

	# Write more comprehensive testing in the Test module to be run to ensure proper setup for libs
}

sub help { 
print "\
BIBLIOGRAPHER -- HELP DOCUMENTATION
    Bibliographer is a CLI tool for quickly converting rich-text formatted bibliography files from one citation style to another.

OPTIONS
    -H, --help
        Displays this help documentation.

    -T, --test
    	Run integration testing to ensure the program has been set up correctly.

    -C (or --convert) <filename.rtf> [<new_filename>] --CITATION_STYLE
    	Converts filename.rtf into the new CITATION_STYLE, overwriting it in the process. 
	If <new_filename> is provided, the reformatted bibliography will be saved as ./saved_bibs/new_filename.rtf instead.
	If --RAW is selected as the CITATION_STYLE, the original file will not be modified,
	and the raw bibliography info will be saved as ./raw_bibs/filename.raw.txt
        If <new_filename> is provided, the raw bibliography will be saved as ./raw_bibs/new_filename.raw.txt instead.

    -X (or --export) <bibliography_name> [<new_filename>] --CITATION_STYLE
        Exports ./raw_bibs/bibliography_name.raw.txt formatted to CITATION_STYLE as ./saved_bibs/bibliography_file.rtf
        If <new_filename> is provided, it will be exported as ./saved_bibs/new_filename.rtf instead.

CITATION_STYLE
    --MLA (Modern Language Association)
    --RAW (For converting a formatted file to an unformatted bibliography)

EXAMPLES
    \$> bibliographer --convert filename.rtf new_file --RAW
    	This extracts the citation info from filename.rtf and saves it as ./raw_bibs/new_file.raw.txt without formatting the citations.

    \$> bibliographer -C filename.rtf --MLA	 or	bibliographer --MLA --convert filename.rtf
    	These overwrite filename.rtf in the MLA citation style.

    \$> bibliographer -X bibliography --MLA
    	This searches ./raw_bibs/ for bibliography.raw.txt and exports it to ./saved_bibs/bibliography.rtf in the MLA citation style.
\n"; }

sub convert {
	if (check_style()) {
		my $style = @style[0];
		print "$style\n";
	}
}

sub export {}




# Raw file formatting:
# Type: [] Authors: {} Title: [] Publication: [] Institution: [] Date: [] Pages: [] 
# where [] is a single field, and {} can be multiple


# CLI Program:
# $> bibliographer --new (-N) <bibliography_name>
# (Creates a new raw file then enters editor mode)
#
# $> bibliographer --convert (-C) <bibliography_file.rtf> (--<CITATION_STYLE> <new_filename.rtf>)
# (Converts the rtf file into .raw.txt)
# (If one of the authors' names returns as "et al.", then use an external API to attempt to retrieve the other authors)
# (Then if there is a citation style argument it converts the raw into the new style)
# (If there is a new file name it saves as that filename, otherwise it overwrites the existing file with the newly formatted rtf)
# 
# $> bibliographer --edit (-E) <bibliography_name>
# (Loads the bibliography_name.raw.txt file and enters Editor Mode)
#
# $> bibliographer --export (-X(o)) <bibliography_name> --<CITATION_STYLE> (<new_filename.rtf>)
# (Exports the raw file with the specified name as the specified citation style to bibliography_name.rtf)
# (If -Xo is selected, opens the export option editor to allow the citation style rules to be modified)
# (If a new filename is specified, it will export the bibliography to that name, if a file of that name does not already exist in that directory)
# (If the filename exists, it will add a digit _0 to the end of the filename and try again, adding 1 until it succeeds, then print the path to that file to output)

# Universals:
# (Applicable at every level of loop within Editor Mode)
# $ > --cancel (-Z) 
# (Cancels the current operation and exits to the outer loop)
# $ > --done (-D) 
# (Ends the current operation and moves to the next stage of the loop, saving the changes)
# $ > --help (-H)
# (Lists the operations available at the current level, with a brief synopsis of instructions for the current stage)

# Editor Mode:
# bibliography > --show (-S) (<CITATION_#>)
# (Prints the full list of citations in order, with an ordering number in front of the citation)
# (If citation number is provided, shows the full citation indicated by that number)
# bibliography > --add (-A) <MEDIUM> (<CITATION_#>)
# (Starts the Citation Adder for the selected citation medium)
# (If a citation number is provided, it adds the citation at that position and moves the following ones down, instead of adding it to the end of the list)
# bibliography > --edit (-E) <CITATION_#>
# (Opens the Citation Editor for the citation indicated by the citation number)
# bibliography > --move (-M(s)) <First Citation #> (--swap) <Second Citation #>
# (Either swaps citations, or moves the first citation to the position indicated by the second and pushes others down)
# bibliography > --remove (-R(a, p)) <CITATION_#>
# (Deletes the citation indicated by the ordering number and moves the following ones up, -Ra removes all, -Rp opens the Citation Adder to replace the citation)

# Citation Adder:
# Opens Author Adder,
# Opens Title Adder,
# And so on, for each field applicable to the chosen medium

# Citation Editor:
# Citation (#) > --show (-S) 
# (Shows the full raw citation that is currently selected)
# 
# Citation (#) > --author <Author Name> --remove (-R(a))
# (Removes 'Author Name' from the citation, if present. -Ra removes all authors from the citation if author name is not specified)
# Citation (#) > --author <Author Name> --edit (-E) <New Name>
# (Replaces the indicated author with a new name, without changing ordering)
# Citation (#) > --author --add (-A)
# (Opens Author Adder for adding multiple authors sequentially)
# Citation (#) > --author --move (-M(s, b, a)) (<First Author> (--swap, --before, --after) <Second Author>)
# (If author names are provided, either swaps authors, or moves to before or after the second author)
# 
# Citation (#) > --title --edit (-E) <The New Title>
# (And so on for each field of the citation)
# (For convenience, prints out the fields to be changed before prompting for replacements)

# Author Adder:
# Add Author (1) > Family Name(s): 
# (Submit the last or family name of the author and press enter)
# Add Author (1) > Given Name(s):
# (Submit the first of given names of the author and press enter)
# Add Author (2) > Family Name(s): --NA
# (Enter --NA into the family field if the author does not have a family name)
# Add Author (2) > Given Name(s): --done
# (Enter --done into either field to exit Author Adder and save the author list to the citation)



