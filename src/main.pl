
use v5.36;
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
	
# Set the program state
my $state = 'main';
	
	
my @style;
sub style { my ($style) = @_; push @style, $style; }
sub check_style {
	if (@style > 1 || @style == 0) { 
		my $count = @style;
		print "Expected exactly 1 CITATION_STYLE flag. $count found.\n";
	       	return 0	
	} else { return 1 }
} # MODIFY TO ENABLE 0 STYLE SELECTION, TO ELIMINATE NEED FOR "RAW" TYPE

my @options;
sub option { my ($ref) = @_; push @options, $ref; }
sub check_options {
	if (scalar @options > 1) {
		my $count = scalar @options;
		print "Maximum of 1 option permitted. $count found.\n";
		return 0
	} else { return 1 }
} # CONSIDER USING REGEX OVER @ARGV FOR COMMANDS, AND RESERVING OPTIONS FOR MINOR FUNCTIONALITY ALTERATIONS

my $help;
my $test;
my @convert;
my @export;

GetOptions (
	'test|T' => sub { $test = 1; option($test) },
	'help|H' => sub { $help = 1; option($help) },
	'convert|C=s{1,2}' => \@convert,
	'export|X=s{1,2}' => \@export,

	'MLA' => sub { &style("MLA") },
	'RAW' => sub { &style("RAW") },
) or &Help::help;

if (@convert) { option(\@convert) }
if (@export) { option(\@export) }

if (scalar @options == 0) { &Help::help }

if (check_options()) {
	if ($help) { &Help::help }
	elsif ($test) { &Test::test }
	elsif (@convert) {
		my $file = $convert[0]; my $new = $convert[1];
		convert($file, $new)
	}
	elsif (@export) {
		my $raw = $export[0]; my $new = $export[1];
		export($raw, $new)
	}
}

# ADD HELP COMMAND TO VIEW OVERALL HELP DOCUMENTATION
# CHANGE HELP OPTION TO PREVENT COMMAND FROM EXECUTING AND INSTEAD DISPLAY MORE DETAILED INSTRUCTIONS
# DISPLAY OVERALL HELP WHEN RUN WITHOUT COMMANDS



sub convert {
	my ($file, $new) = @_;
	if (check_style()) {
		my $style = $style[0];
		print "Convert $file to $style";
		if ($new) { print " and save as $new"; }
		print "\n";
	} # MODIFY TO ENABLE CONVERSION TO RAW TYPE WHEN CITATION_STYLE IS NOT PROVIDED
}

sub export {
	my ($raw, $new) = @_;
	if (check_style() == 1 && $style[0] !~ "RAW") {
		my $style = $style[0];
		print "Convert $raw to $style";
		if ($new) { print " and save as $new"; }
		else { $new = $raw; }
		print "\n";
	} elsif ($style[0] =~ "RAW") { print "$raw is already in raw format.\n"; }
} # MODIFY TO REMOVE "RAW" TYPE AND REQUIRE CITATION_TYPE


# FILE HANDLER SUBS

# IDENTIFY FORMAT TYPE or PARSE USING REGEX FROM UNKNOWN FORMATTING

# CONVERT TO RAW BIBLIOGRAPHY

# FORMAT RAW AS STYLE




# Raw file formatting:
# Type: [] Authors: {} Title: [] Publication: [] Institution: [] Date: [] Pages: [] 
# where [] is a single field, and {} can be multiple



