package MLA;

use strict;
use warnings;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($name_pattern $author_pattern $year_pattern $date_pattern $page_range_pattern $newspaper_page_range_pattern\
$location_pattern $url_pattern $thesis_type_pattern $article_title_pattern $book_title_pattern $journal_name_pattern\
$publisher_name_pattern $website_name_pattern $institution_name_pattern $journal_citation_pattern $book_citation_pattern\
$newspaper_citation_pattern $magazine_citation_pattern $website_citation_pattern $conference_citation_pattern $thesis_citation_pattern);


# -- Name
our $name_pattern = qr/(?<family>\pL[\pL'\p{Pd}\s]*),\s+(?<first>(\p{Lu}\.\s?)+|(\p{Lu}[\pL'\p{Pd}]*))/;
#test_name_pattern();

# -- Author
our $author_pattern = qr/(?<primary>$name_pattern)(,\sand\s(?<secondary>$name_pattern)|(?<others>\set\sal))?/;
#test_author_pattern();

# -- Year
our $year_pattern = qr/(\p{Nd}{4})/;
#test_year_pattern();

# -- Date
our $date_pattern = qr/((?<day>\p{Nd}{1,2}(-\p{Nd}{1,2})?)\s)?(?<month>\p{Lu}[\p{Ll}]*\.?)\s(?<year>$year_pattern)/;
#test_date_pattern();

# -- Page Range
our $page_range_pattern = qr/pp\. (?<start>\p{Nd}+)(\p{Pd}(?<end>\p{Nd}+))?/;
#test_page_range_pattern();

# -- Newspaper Page Range
our $newspaper_page_range_pattern = qr/p\. (?<start>\p{Lu}\p{Nd}+)(\p{Pd}(?<end>\p{Lu}\p{Nd}+))?/;

# -- Location
our $location_pattern = qr/(((\p{Lu}[\p{L}'\p{Pd}]*)+(,\s+)?)+)/;
#test_location_pattern();

# -- URL
our $url_pattern = qr/(http(s)?:\/\/)?([\p{Nd}\p{L}]+\.[\p{L}\p{Nd}\p{Pd}_]+\.[\p{L}\p{Nd}]+(\/[\p{L}\p{Nd}\p{Pd}&\+\?=_']*)*)/;
#test_url_pattern();

# -- Thesis Type
our $thesis_type_pattern = qr/[\p{L}\.'\s]+/;

# -- Article Title
our $article_title_pattern = qr/"((?:[^"]|"")*\p{Po}+)"/;
#test_article_title_pattern();

# -- Book Title
our $book_title_pattern = qr/((\p{Lu}[\p{Lu}\p{Ll}\p{Pd}']*)\s?(((\p{Lu}[\p{Lu}\p{Ll}\p{Pd}']*)|([\p{Ll}\p{Pd}'\p{N}]*))\s?)*)+/;
#test_book_title_pattern();

# -- Journal Name
our $journal_name_pattern = qr/\b(\p{Lu}[\pL\p{Pd}&'\.\s]*(, vol\. \p{Nd}+, no\. \p{Nd}+)?)/;
#test_journal_name_pattern();

# -- Publisher Name
our $publisher_name_pattern = qr/(((\p{Lu}[\pL\p{Pd}'\.]*)+(,??\s)??)+)/;
#test_publisher_name_pattern();

# -- Website Name
our $website_name_pattern = qr/(([\p{L}\p{Nd}\p{Pd}_']+([\.,\s]*?)*)*)/;
#test_website_name_pattern();

# -- Institution Name
our $institution_name_pattern = qr/(((\p{Lu}|\p{Ll})[\p{Ll}\p{Pd}'\.]*(,??\s)?)+)/;
#test_institution_name_pattern();

# -- Journal Citation Format
our $journal_citation_pattern = qr/(?<authors>$author_pattern)\.\s+(?<title>$article_title_pattern)\s+(?<journal>$journal_name_pattern),\s+(?<year>$year_pattern),\s+(?<pages>$page_range_pattern)\./;
#test_journal_citation_pattern();

# -- Book Citation Format
our $book_citation_pattern = qr/(?<authors>$author_pattern)\.\s+(?<title>$book_title_pattern)\.\s+(?<publisher>$publisher_name_pattern),\s+(?<year>$year_pattern)(,\s+(?<pages>$page_range_pattern))?\./;
#test_book_citation_pattern();

# -- Newspaper Article Citation Format
our $newspaper_citation_pattern = qr/((?<authors>$author_pattern)\.\s+)?(?<title>$article_title_pattern)\s+(?<newspaper>$publisher_name_pattern),\s+(?<date>$date_pattern),\s+(?<pages>$newspaper_page_range_pattern)\./;
#test_newspaper_citation_pattern();

# -- Magazine Article Citation Format
our $magazine_citation_pattern = qr/((?<authors>$author_pattern)\.\s+)?(?<title>$article_title_pattern)\s+(?<magazine>$publisher_name_pattern),\s+((?<issue>vol\.\s\p{Nd}+,\sno\.\s\p{Nd}+),\s+)?(?<date>$date_pattern),\s+(?<pages>$page_range_pattern)\./;
#test_magazine_citation_pattern();

# -- Website Citation Format
our $website_citation_pattern = qr/((?<authors>$author_pattern)\.\s+)?(?<title>$article_title_pattern)\s+(?<website>$website_name_pattern)(,\s+(?<publisher>$publisher_name_pattern))?,\s+(?<date>$date_pattern),\s+(?<url>$url_pattern)(\.\s+Accessed\s(?<retrieval_date>$date_pattern))?\./;
#test_website_citation_pattern();

# -- Conference Paper Citation Format
our $conference_citation_pattern = qr/(?<authors>$author_pattern)\.\s+(?<title>$article_title_pattern)\s+(?<conference>$institution_name_pattern),\s+(?<dates>$date_pattern),\s+(?<location>$location_pattern)\./;
#test_conference_citation_pattern();

# -- Dissertation/Thesis Citation Format
our $thesis_citation_pattern = qr/(?<authors>$author_pattern)\.\s+(?<title>$article_title_pattern)\s+(?<type>$thesis_type_pattern),\s+(?<institution>$institution_name_pattern),\s+(?<year>$year_pattern)\./;
#test_thesis_citation_pattern();


## --- Test functions for MLA regex patterns -- ##

## -- Test regex components

sub test_name_pattern {
	my $test_name_1 = "Van Halen, Eddie";
	my $test_name_2 = "von Neumann, Johannes";
	my $test_name_3 = "Smith, Adam";
	my $test_name_4 = "Tolkien, J. R. R.";
	
	my @test_names = ($test_name_1, $test_name_2, $test_name_3, $test_name_4);
	
	foreach my $test_name (@test_names) {
		if ($test_name =~ $name_pattern) {
			my $first_name = $+{first};
			my $last_name = $+{family};
			print "$first_name $last_name is an author\n";
		} else {
			print "$test_name is not an author\n";
		}
	}
}

sub test_author_pattern {
	my $test_author_1 = "Lennon, John, and McCartney, Paul";
	my $test_author_2 = "Crosby, David et al.";
	my $test_author_3 = "Van Halen, Eddie";
	
	my @test_authors = ($test_author_1, $test_author_2, $test_author_3);
	
	foreach my $author (@test_authors) {
		if ($author =~ $author_pattern) {
			my $author_1 = $+{primary};
			my $author_2 = $+{secondary};
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

sub test_article_title_pattern {
	my $test_article_title_1 = '"Article Title."';
	my $test_article_title_2 = '"Article (123 *** NH-) Title??"';
	
	my @test_article_titles = ($test_article_title_1, $test_article_title_2);
	
	foreach my $test_article_title (@test_article_titles) {
		if ($test_article_title =~ $article_title_pattern) {
			print "'$1' is an article title\n";
		} else {
			print "$test_article_title is not an article title\n";
		}
	}
}

sub test_book_title_pattern {
	my $test_title_1 = "Title of a Book";
	my $test_title_2 = "N'N-Dimethyltryptamine";
	my $test_title_3 = "dgfhhh fgh sfgh";
	
	my @test_titles = ($test_title_1, $test_title_2, $test_title_3);
	
	foreach my $title (@test_titles) {
		if ($title =~ $book_title_pattern) {
			print "'$title' is a good title!\n";
		} else {
			print "'$title'... Who named this book?\n";
		}
	}
}

sub test_journal_name_pattern {
	my $test_journal_name_1 = "Nature";
	my $test_journal_name_2 = "Alzheimer's & Dementia";
	my $test_journal_name_3 = "Journal of Bullshit-Science";
	my $test_journal_name_4 = "Proc. Nat'l. Acad. Sci.";
	
	my @test_journal_names = ($test_journal_name_1, $test_journal_name_2, $test_journal_name_3, $test_journal_name_4);
	
	foreach my $test_journal (@test_journal_names) {
		if ($test_journal =~ $journal_name_pattern) {
			print "$test_journal is a proper journal\n";
		} else {
			print "$test_journal is a rag\n";
		}
	}
}

sub test_publisher_name_pattern {
	my $test_publisher_1 = "Med. Sci. Pub."; 
	my $test_publisher_2 = "Some Moneygrubbers' Company";
	my $test_publisher_3 = "Publishers, Inc.";
	
	my @test_publishers = ($test_publisher_1, $test_publisher_2, $test_publisher_3);
	
	foreach my $publisher (@test_publishers) {
		if ($publisher =~ $publisher_name_pattern) {
			print "'$publisher' makes books\n";
		} else {
			print "'$publisher'... Who are these guys?\n";
		}
	}
}

sub test_website_name_pattern {
	my $test_website_1 = "Google";
	my $test_website_2 = "sketchy-website";
	my $test_website_3 = "some website, allegedly";
	
	my @test_websites = ($test_website_1, $test_website_2, $test_website_3);
	
	foreach my $website (@test_websites) {
		if ($website =~ $website_name_pattern) {
			print "All gucci\n";
		} else {
			print "'$website' failed to parse\n";
		}
	}
}

sub test_institution_name_pattern {
	my $test_institution_1 = "University of Bullshit";
	my $test_institution_2 = "Inst. Med. Sci.";
	my $test_institution_3 = "Research, Inc.";
	
	my @test_institutions = ($test_institution_1, $test_institution_2, $test_institution_3);
	
	foreach my $institution (@test_institutions) {
		if ($institution =~ $institution_name_pattern) {
			print "All gucci\n";
		} else {
			print "'$institution' failed to parse\n";
		}
	}
}

sub test_year_pattern {
	my $test_year_1 = "2023";
	my $test_year_2 = "1776";
	my $test_year_3 = "123";
	my @test_years = ($test_year_1, $test_year_2, $test_year_3);
	
	foreach my $year (@test_years) {
		if ($year =~ $year_pattern) {
			print "$1 was a good year\n";
		} else {
			print "No one published in $year\n";
		}
	}
}

sub test_date_pattern {
	my $test_date_1 = "4 July 1776";
	my $test_date_2 = "5 Nov. 2008";
	my $test_date_3 = "15 September 1993";
	
	my @test_dates = ($test_date_1, $test_date_2, $test_date_3);
	
	foreach my $date (@test_dates) {
		if ($date =~ $date_pattern) {
			print "$date\n";
		} else {
			print "When was that?\n";
		}
	}
}

sub test_page_range_pattern {
	my $test_range_1 = "pp. 1-100";
	my $test_range_2 = "pp. 69-420";
	
	my @test_ranges = ($test_range_1, $test_range_2);
	
	foreach my $range (@test_ranges) {
		if ($range =~ $page_range_pattern) {
			my $start = $+{start};
			my $end = $+{end};
			print "First pg: $start, Last pg: $end\n";
		} else {
			print "Invalid range\n";
		}
	}
}

sub test_location_pattern {
	my $test_location_1 = "Birmingham, Alabama";
	my $test_location_2 = "College Park, MD, USA";
	my $test_location_3 = "Some Research Station, Antarctica";
	
	my @test_locations = ($test_location_1, $test_location_2, $test_location_3);
	
	foreach my $location (@test_locations) {
		if ($location =~ $location_pattern) {
			print "$location is all gucci\n";
		} else {
			print "'$location' failed to parse\n";
		} 
	}
}

sub test_url_pattern {
	my $test_url_1 = "https://www.google.com/?search";
	my $test_url_2 = "http://w3.sketchy-website.sus/?search=bla_bla_bla+bla_bla-4206969";
	my $test_url_3 = "www.facebook.com";
	my $test_url_4 = "some website, allegedly";
	
	my @test_urls = ($test_url_1, $test_url_2, $test_url_3, $test_url_4);
	
	foreach my $url (@test_urls) {
		if ($url =~ $url_pattern) {
			print "All gucci\n";
		} else {
			print "'$url' failed to parse\n";
		}
	}
}


## -- Test Citation Patterns

sub test_journal_citation_pattern {
	my $test_citation_1 = 'Smith, John. "The Article Title." Some Journal, vol. 1, no. 1, 2023, pp. 1-100.';
	my $test_citation_2 = 'Smith, John, and Doe, Jane. "The Article Title." Some Journal, vol. 1, no. 1, 2023, pp. 1-100.';
	my $test_citation_3 = 'Smith, John et al. "The Article Title." Some Journal, vol. 1, no. 1, 2023, pp. 10.';
	
	my @test_citations = ($test_citation_1, $test_citation_2, $test_citation_3);
	
	foreach my $citation (@test_citations) {
		if ($citation =~ $journal_citation_pattern) {
			print "All gucci\n";
			my $authors = $+{authors};
			my $title = $+{title};
			my $journal = $+{journal};
			my $year = $+{year};
			my $pages = $+{pages};
			if ($authors =~ $author_pattern) {
				my @author_names;
	
				my $author_1 = $+{primary};
				my $author_2 = $+{secondary};
				my $others = $+{others};
		       		if ($author_1 =~ $name_pattern) {
					my $first_name = $+{first};
					my $last_name = $+{family};
					my @name = ($first_name, $last_name);
					push @author_names, @name;
				}
				if ($author_2 =~ $name_pattern) {
					my $first_name = $+{first};
					my $last_name = $+{family};
					my @name = ($first_name, $last_name);
					push @author_names, @name;
				}
				if ($others) {
					my $other_authors = "and others";
					push @author_names, $other_authors;
				}
				foreach my $author_name (@author_names) {
					print "$author_name ";
				}
				print "\n";
			}
			print "Authors: $authors Title: $title Journal: $journal Year: $year Pages: $pages\n";
		} else {
			print "Whoops, '$citation' doesn't parse\n";
		}
	}
}

sub test_book_citation_pattern {
	my $test_book_1 = "Smith, John, and Doe, Jane. That Book With the Title. Some Moneygrubbers, 2023, pp. 69-420.";
	my $test_book_2 = "Smith, John et al. N'N-Dimethyltryptamine. Med. Sci. Pub., 1999, pp. 1-100.";
	my $test_book_3 = "Smith, John. Book Title 2. Publishers, Inc., 2000.";
	
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

sub test_newspaper_citation_pattern {
	my $test_newspaper_1 = 'Smith, John. "Headline--Catchy subtitle." Clickbait Rag, 1 January 2023, p. A1.';
	my $test_newspaper_2 = 'Smith, John, and Doe, Jane. "We wrote this together!" Duet News, 20 March 1999, p. B2-C1.';
	my $test_newspaper_3 = '"Anonymous Article." Your Typical Paper, 10 September 2000, p. D4.';
	
	my @test_newspapers = ($test_newspaper_1, $test_newspaper_2, $test_newspaper_3);
	
	foreach my $paper (@test_newspapers) {
		if ($paper =~ $newspaper_citation_pattern) {
			print "All gucci\n";
		} else {
			print "'$paper' failed to parse\n";
		}
	}
}

sub test_magazine_citation_pattern {
	my $test_magazine_1 = 'Doe, John. "Who Am I?" Philosophy Today, vol. 1, no. 21, 1 January 2001, pp. 1.';
	my $test_magazine_2 = 'Smith, John, and Doe, Jane. "We wrote this together!" Duet Magazine, 23 March 2002, pp. 20-22.';
	my $test_magazine_3 = '"Anonymous Article." Clandestine Magazine, November 2005, pp. 34-35.';
	
	my @test_magazines = ($test_magazine_1, $test_magazine_2, $test_magazine_3);
	
	foreach my $magazine (@test_magazines) {
		if ($magazine =~ $magazine_citation_pattern) {
			print "All gucci\n";
		} else {
			print "'$magazine' failed to parse\n";
		}
	}
}

sub test_website_citation_pattern {
	my $test_website_1 = q{"Webpage Title." Ye Olde Website, May 1999, www.old-website.com/webpage_title.};
	my $test_website_2 = q{Smith, John. "John's Homepage." John's Homepage, Squarespace.com, 1 Jan 2023, www.johnspage.com/John's_Homepage.};
	my $test_website_3 = q{"Google results." Google, Alphabet, Inc., June 2023, www.google.com/?search=search_query_3. Accessed 12 March 2023.};
	
	my @test_websites = ($test_website_1, $test_website_2, $test_website_3);
	
	foreach my $website (@test_websites) {
		if ($website =~ $website_citation_pattern) {
			print "All gucci\n"; 
			my $authors = $+{authors};
			my $title = $+{title};
			my $website = $+{website};
			my $publisher = $+{publisher};
			my $date = $+{date};
			my $url = $+{url};
			my $retrieval_date = $+{retrieval_date};
			print "Authors: $authors\nTitle: $title\nSite: $website\nPublisher: $publisher\nDate: $date\nURL: $url\nRetrieved: $retrieval_date\n";
		} else {
			print "'$website' failed to parse\n";
		}
	}
}

sub test_conference_citation_pattern {
	my $test_paper_1 = q{Smith, John. "A Presentation on a Thing." Conference of Thing-Studiers, 1-10 June 2023, London, UK.};
	my $test_paper_2 = q{Smith, John. "Bla bla bla." Univeristy of Something I Guess, 3 March 2000, Boringland, Yawn.};
	my $test_paper_3 = q{Smith, John. "Why won't these parse?" Confusing Institution, 10-12 June 2001, Annapolis, Maryland, USA.};
	
	my @test_papers = ($test_paper_1, $test_paper_2, $test_paper_3);
	
	foreach my $paper (@test_papers) {
		if ($paper =~ $conference_citation_pattern) {
			print "All gucci\n";
			my $authors = $+{authors};
			my $title = $+{title};
			my $conference = $+{conference};
			my $dates = $+{dates};
			my $location = $+{location};
			print "Authors: $authors\nTitle: $title\nConference: $conference\nDates: $dates\nLocation: $location\n";
		} else {
			print "'$paper' failed to parse\n";
		}
	}
}

sub test_thesis_citation_pattern {
	my $test_thesis_1 = q{Smith, John. "My Theory About Something." PhD diss., University of Somewhere, 2001.};
	my $test_thesis_2 = q{Doe, Jane. "A Summary of Stuff." Master's Thesis, National Things Institute, 2020.};
	
	my @test_theses = ($test_thesis_1, $test_thesis_2);
	
	foreach my $thesis (@test_theses) {
		if ($thesis =~ $thesis_citation_pattern) {
			print "All gucci\n";
			my $authors = $+{authors};
			my $title = $+{title};
			my $type = $+{type};
			my $institution = $+{institution};
			my $year = $+{year};
			print "Author: $authors\nTitle: $title\nThesis type: $type\nInstitution: $institution\nYear: $year\n";
		} else {
			print "'$thesis' failed to parse\n";
		}
	}
}

1;
