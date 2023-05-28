
package Test;


use strict;
use warnings;

use File::Basename;
use lib dirname($0);
use MLA;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(test);


my $dir = dirname($0);
my $root = dirname($dir);
my $raw_dir = $root.'/raw_bibs/';
my $save_dir = $root.'/saved_bibs/';

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

1;
