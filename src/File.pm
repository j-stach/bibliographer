package File;

use strict;
use warnings;

use Cwd;
use File::Basename;
use lib dirname($0);

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($raw_dir $save_dir find_filename find_rawfile get_filename get_current_date);

# Setup raw/save directory access
our $dir = dirname($0);
our $root = dirname($dir);
our $raw_dir = $root.'/raw_bibs/';
our $save_dir = $root.'/saved_bibs/';


sub find_filename {
	my ($filename) = @_;
	if ($filename =~ /\.rtf$/) {
		my $cwd = getcwd()."/";
		if (-e "$cwd$filename") {
			my $file = "$cwd$filename";
			print "$filename found in $cwd\n";
			return $file
		}
		elsif ($filename =~ "/" && (-e "$filename")) {
			print "File path $filename found. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response =~ /^y\n$|^Y\n$|^\n$/) { return $filename }
			else { print "ERROR: $filename could not be located.\n"; exit }
		}
		elsif (-e "$save_dir$filename") {
			my $file = "$save_dir$filename";
			print "$filename found in bibliographer save directory. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response =~ /^y\n$|^Y\n$|^\n$/) { return $file }
			else { print "ERROR: $filename could not be located.\n"; exit }
		} else { print "ERROR: $filename could not be located.\n"; exit }
	} else { print "ERROR: File to be read ($filename) must have '.rtf' file extension.\n"; exit }
}

sub find_rawfile {
	my ($rawfile) = @_;
	my $raw = "$raw_dir$rawfile.raw.txt";
	if (-e "$raw") {
		print "$rawfile found.\n";
		return $raw
	} else { print "ERROR: $raw could not be found.\n"; exit }
}

sub get_filename {
	my ($file) = @_;
	my $filename_pattern = qr{/?(?<filename>[\.\p{L}\p{Nd}]+)\.rtf$};
	my $filename;
	if ($file =~ $filename_pattern) {
		$filename = $+{filename};
	}
} # TEST ME!

sub get_current_date {
	my ($sec, $min, $hour, $day, $mon, $year) = localtime();
	$year += 1900;
	my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
	my $month = $months[$mon];
	return "$day $month $year";
}

1;
