
use v5.36;
use Cwd;
use Getopt::Long;
use File::Basename;
use lib dirname($0);

use Test;
use Help;

use MLA;

# Setup raw/save directory access
my $dir = dirname($0);
my $root = dirname($dir);
my $raw_dir = $root.'/raw_bibs/';
my $save_dir = $root.'/saved_bibs/';
	

my @style;
sub style { my ($style) = @_; push @style, $style; }
sub check_style {
	if (@style == 0) { return 0 } 
	elsif (@style == 1) { return 1 }
	elsif (@style > 1) {
		my $count = @style;
		print "Multiple CITATION_STYLE flags detected: $count found. Please submit only one citation style.\n";
		return 2
	}
}

my $help;
my $test;

GetOptions (
	'test|T' => \$test,
	'help|H' => \$help,
	
	# VERSION
	# VERBOSE / QUIET
	# CONFIG
	# FIX

	'MLA' => sub { &style("MLA") },
);

my $command; 
my @args;

if (!$test && !$help) {
	command();
} 
elsif ($test) { &Test::test } # CHANGE TEST TO PERFORM COMMAND-SPECIFIC UNIT TESTING
elsif ($help) { &Help::help } # CHANGE HELP TO PROVIDE COMMAND-SPECIFIC HELP DOCUMENTATION

sub command {
	if (@ARGV) {
		($command, @args) = @ARGV;
		run_command();
	} else { &Help::help }
}

sub run_command {
	if ($command eq 'convert') {
		if (@args == 1 || @args == 2) {
			my ($file, $new) = @args;
			convert($file, $new)
		} elsif (@args == 0) { print "ERROR: 'convert' expected filename argument.\n"; }
		else { print "ERROR: 'convert' should have 1 or 2 arguments: @args found.\n"; }		
	} elsif ($command eq 'export') {
		if (@args == 1 || @args == 2) {
			my ($file, $new) = @args;
			export($file, $new)
		} elsif (@args == 0) { print "ERROR: 'export' expected bibliography name argument.\n"; }
		else { print "ERROR: 'export' should have 1 or 2 arguments: @args found.\n"; }		
	} else {
		print "Command not recognized. Use --help to view available commands.\n";
	}
}



sub convert {
	my ($file, $new) = @_;
	if (check_style() == 1) {
		my $style = $style[0];
		print "Convert $file to $style"; if ($new) { print " and save as $new"; } print "\n";
	} elsif (check_style() == 0) {
		print "Convert $file to raw"; if ($new) { print " and save as $new"; } print "\n";
	}
}

sub export {
	my ($raw, $new) = @_;
	if (check_style() == 1) {
		my $style = $style[0]; 
		print "Convert $raw to $style"; if ($new) { print " and save as $new"; } print "\n";
	} elsif (check_style() == 0) { print "Cannot export as raw. Please provide a CITATION_STYLE flag.\n"; }
}


sub find_filename {
	my ($filename) = @_;
	if ($filename =~ /\.rtf$/) {
		my $cwd = getcwd();
		if (-e "$cwd/$filename") {
			my $file = "$cwd/$filename";
			print "$filename found in $cwd\n";
			return $file
		}
		elsif ($filename =~ "/" && (-e "$filename")) {
			print "File path $filename found. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response eq ('y' || 'Y' || "\n")) { return $filename }
			else { print "ERROR: $filename could not be located.\n"; }
		}
		elsif (-e "$save_dir/$filename") {
			my $file = "$save_dir/$filename";
			print "$filename found in bibliographer save directory. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response eq ('y' || 'Y' || "\n")) { return $file }
			else { print "ERROR: $filename could not be located.\n"; }
		} else { print "ERROR: $filename could not be located.\n"; }
	} else { print "ERROR: File to be read ($filename) must have '.rtf' file extension.\n"; }
}

sub find_rawfile {
	my ($rawfile) = @_;
	my $raw = "$raw_dir/$rawfile.raw.txt";
	if (-e "$raw") {
		print "$rawfile found.\n";
		return $raw
	} else { print "ERROR: $raw could not be found.\n"; }
}

# FILE HANDLER SUBS
# open filename
# new filename
# open rawfile
# new rawfile

# IDENTIFY FORMAT TYPE or PARSE USING REGEX FROM UNKNOWN FORMATTING

# CONVERT TO RAW BIBLIOGRAPHY

# FORMAT RAW AS STYLE




# Raw file formatting:
# Type: [] Authors: {} Title: [] Publication: [] Institution: [] Date: [] Pages: [] 
# where [] is a single field, and {} can be multiple



