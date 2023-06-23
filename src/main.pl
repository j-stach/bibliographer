
use v5.36;
use Cwd;
use Getopt::Long;
use File::Basename;
use lib dirname($0);

use File;

use Test;
use Help;

use Fmt;
use MLA;

my $version = "version 0.1 2023";

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
	'test|t' => \$test,
	'help|h' => \$help,
	'version|v'=> sub { print "$version\n" },

	# VERBOSE works like it usually does
	# QUIET / QUICK will execute command without prompting for additional user input
	# STRICT will not export if all patterns cannot be identified and all information is not present

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
		print "Command not recognized. Use --help or run without arguments to view available commands.\n";
		# FIX (command?) attempts to retrieve missing citation info
	}
}

sub convert {
	my ($filename, $new) = @_;
	if (my $file = &File::find_filename($filename)) {
		if (&check_style == 1) {
			my $new_fmt = $style[0];
			print "Convert $filename to $new_fmt"; if ($new) { print " and save as $new.rtf"; } print "\n";
		} elsif (&check_style == 0) {
			print "Convert $filename to raw"; if ($new) { print " and save as $new.raw.txt"; } print "\n";
		}
	}
}

sub export {
	my ($rawfile, $new) = @_;
	if (my $file = &File::find_rawfile($rawfile)) {
		if (&check_style == 1) {
			my $new_fmt = $style[0]; 
			print "Convert $rawfile to $new_fmt"; if ($new) { print " and save as $new.rtf"; } print "\n";
		} elsif (&check_style == 0) { print "Cannot export as raw. Please provide a CITATION_STYLE flag.\n"; }
	}
}



