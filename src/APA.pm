package APA;

use strict;
use warnings;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($name_pattern $author_pattern $year_pattern $page_range_pattern\
$book_title_pattern $publisher_name_pattern $book_citation_pattern);


# -- Name
our $name_pattern = qr/(?<family>\pL[\pL'\p{Pd}\s]*),\s+(?<first>(\p{Lu}\.\s?)+)/;
#test_name_pattern();

# -- Author
our $author_pattern = qr/(?<primary>$name_pattern)(?<others>(,\s($name_pattern)){0,5})?((,\s\.\.\.)|(,\s&\s))?(?<final>$name_pattern)?/;
test_author_pattern();

# -- Year
our $year_pattern = qr/(\p{Nd}{4})/;
#test_year_pattern();

# -- Page Range
our $page_range_pattern = qr/pp\. (?<start>\p{Nd}+)(\p{Pd}(?<end>\p{Nd}+))?/;
#test_page_range_pattern();

# -- Book Title
our $book_title_pattern = qr/((\p{Lu}[\p{Lu}\p{Ll}\p{Pd}']*)\s?(((\p{Lu}[\p{Lu}\p{Ll}\p{Pd}']*)|([\p{Ll}\p{Pd}'\p{N}]*))\s?)*)+/;
#test_book_title_pattern();

# -- Publisher Name
our $publisher_name_pattern = qr/(((\p{Lu}[\pL\p{Pd}'\.]*)+(,??\s)??)+)/;
#test_publisher_name_pattern();

# -- Book Citation Format
our $book_citation_pattern = qr/(?<authors>$author_pattern)\.?\s+\((?<year>$year_pattern)\)\s+(?<title>$book_title_pattern)(\s+\((?<pages>$page_range_pattern)\))?\.\s+(?<publisher>$publisher_name_pattern)\./;
#test_book_citation_pattern();


#### APA PATTERN TESTS ####

sub test_author_pattern {
	my $test_author_1 = "Lennon, J., & McCartney, P.";
	my $test_author_2 = "White, S., Dwarf, D., Dwarf, G., Dwarf, H., Dwarf, S., Dwarf, B., ... Dwarf, D.";
	my $test_author_3 = "Van Halen, E.";
	
	my @test_authors = ($test_author_1, $test_author_2, $test_author_3);
	
	foreach my $author (@test_authors) {
		if ($author =~ $author_pattern) {
			my $author_1 = $+{primary};
			my $author_2 = $+{final};
			my $others = $+{others};
		       	if ($author_1 =~ $name_pattern) {
				my $first_name_1 = $+{first};
				my $last_name_1 = $+{family};
				print "Author found: $first_name_1 $last_name_1\n";
			}
			if ($author_2 =~ $name_pattern) {
				my $first_name_2 = $+{first};
				my $last_name_2 = $+{family};
				print "Author found: $first_name_2 $last_name_2\n";
			} 
			if ($others) {
				print "and others\n";
			} 
		} else {
			print "Couldn't parse $author\n";
		}
	}

}

sub test_book_citation_pattern {
	my $test_book_1 = "Smith, J., & Doe, J. (2023). That Book With the Title (pp. 1-100). Some Moneygrubbers.";
	my $test_book_2 = "White, S., Dwarf, D., Dwarf, G., Dwarf, H., Dwarf, S., Dwarf, B., ... Dwarf, D. (1812). Ethics of Industry. Grimm Publishing.";
	my $test_book_3 = "Smith, J. (2023). A Book. Publishers, Inc.";
	
	my @test_books = ($test_book_1, $test_book_2, $test_book_3);
	
	foreach my $book (@test_books) {
		if ($book =~ $book_citation_pattern) {
			print "All gucci\n";
			my $publisher = $+{publisher};
			my $title = $+{title};
			my $year = $+{year};
			my $pages = $+{pages};
			print "Title: $title Publisher: $publisher Year: $year Pages: $pages\n";
		} else {
			print "'$book' failed to parse\n";
		}
	}
}


1;
