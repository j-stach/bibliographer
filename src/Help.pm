
package Help;

use strict;
use warnings;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(help);

sub help { 
print "\
BIBLIOGRAPHER -- HELP DOCUMENTATION
    Bibliographer is a CLI tool for quickly converting rich-text formatted bibliography files from one citation style to another.

OPTIONS
    -h, --help
        Displays this help documentation.

    -t, --test
    	Run integration testing to ensure the program has been set up correctly.

    -v, --version
    	Displays the version number and year.

COMMANDS
    convert <filename.rtf> [<new_filename>] [--CITATION_STYLE]
    	Converts filename.rtf into the new CITATION_STYLE, overwriting it in the process. 
	If <new_filename> is provided, the reformatted bibliography will be saved as ./saved_bibs/new_filename.rtf instead.
	If no CITATION_STYLE is provided, the original file will not be modified,
	and the raw bibliography info will be saved as ./raw_bibs/filename.raw.txt
        If <new_filename> is provided, the raw bibliography will be saved as ./raw_bibs/new_filename.raw.txt instead.

    export <bibliography_name> [<new_filename>] --CITATION_STYLE
        Exports ./raw_bibs/bibliography_name.raw.txt formatted to CITATION_STYLE as ./saved_bibs/bibliography_file.rtf
        If <new_filename> is provided, it will be exported as ./saved_bibs/new_filename.rtf instead.

CITATION_STYLE
    --MLA (Modern Language Association)

EXAMPLES
    \$> bibliographer convert filename.rtf new_file
    	This extracts the citation info from filename.rtf and saves it as ./raw_bibs/new_file.raw.txt without formatting the citations.

    \$> bibliographer convert filename.rtf --MLA
    	This overwrites filename.rtf in the MLA citation style.

    \$> bibliographer export bibliography --MLA
    	This searches ./raw_bibs/ for bibliography.raw.txt and exports it to ./saved_bibs/bibliography.rtf in the MLA citation style.
\n"; }


1;
