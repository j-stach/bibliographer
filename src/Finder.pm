package Finder;

use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(check_connection);


sub check_connection {
	my @apis = ('http://api.crossref.org/', ); # WorldCat Search, and Scopus
	foreach my $url (@apis) {
		unless (get($url)) { print "$url not available.\n" }
	}
}

# try_get_info() 

# missing_info() collects missing info into array and calls at end of function to query crossref api

# try_get_web_info()


	
1;
