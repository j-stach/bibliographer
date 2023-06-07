
use v5.36;
use Cwd;
use Getopt::Long;
use File::Basename;
use lib dirname($0);

use File;

use Test;
use Help;

use RAW;
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
		print "Command not recognized. Use --help to view available commands.\n";
		# FIX (command?) attempts to retrieve missing citation info
	}
}

sub convert {
	my ($filename, $new) = @_;
	if (my $file = &File::find_filename($filename)) {
		if (check_style($file) == 1) {
			my $new_fmt = $style[0];
			my $fmt = id_fmt($file);
			print "$filename format is $fmt\n";
			print "Convert $filename to $new_fmt"; if ($new) { print " and save as $new.rtf"; } print "\n";
		} elsif (check_style() == 0) {
			print "Convert $filename to raw"; if ($new) { print " and save as $new.raw.txt"; } print "\n";
		}
	}
}

sub export {
	my ($rawfile, $new) = @_;
	if (my $file = &File::find_rawfile($rawfile)) {
		if (check_style() == 1) {
			my $new_fmt = $style[0]; 
			print "Convert $rawfile to $new_fmt"; if ($new) { print " and save as $new.rtf"; } print "\n";
		} elsif (check_style() == 0) { print "Cannot export as raw. Please provide a CITATION_STYLE flag.\n"; }
	}
}




sub fmt_to_raw {
	my ($file, $rawname) = @_;
	my $rawfile;

	if ($rawname) {	$rawfile = $rawname; } else { $rawfile = &File::get_filename($file); }
	my $raw = "$raw_dir$rawfile.raw.txt";

	while (-e "$raw") {
		print "$raw already exists, overwrite? (y/N) "; 
		my $response = <STDIN>;
		if ($response !~ /^y\n$|^Y\n$/) {
			print "Enter new bibliography name: ";
			my $newname = <STDIN>;
			chomp $newname;
			$raw = "$raw_dir$newname.raw.txt";
		} else { last; }
	}

	open my $rf, '>', $raw or die "Unable to create rawfile: $!\n";
	close $rf;
	
	if (open my $fh, '<', $file) {
		while (my $line = <$fh>) {
			my $raw_info = pull_raw_info($line);
			open my $rf, '>>', $raw;
			print $rf $raw_info;
		}
		close $fh;
		return 1;
	} else {
		print "ERROR: Failed to read $file\n";
		return 0;
	}	
} # TEST ME!


# MOVE THIS SUPERFUNCTION INTO FORMAT MODULE
sub pull_raw_info {
	my ($line) = @_;
	my $medium; my $authors; my $title; my $publication; my $institution; my $location; my $date; my $pages;

	# MAY WANT TO INCLUDE OTHER VARIABLES THEN BUILD RAW CITATION FROM THERE, AFTER GETTING MISSING INFO
	# OTHER VARIABLES TO INCLUDE, DOI, etc.
	# DEFINE AND INITIALIZE WITHIN IF BLOCK? THEN PUSH TO CITATION VARIABLE AND BUILD STRING FROM THERE
	# CONSULT STYLE GUIDES TO DETERMINE WHAT FIELDS ARE REQUIRED FOR EACH TYPE OF MEDIUM

	if ($line =~ $MLA::book_citation_pattern) { 
		$medium = "Book";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title}; 	# TITLE NEEDS TO STRIP BOUNDARY QUOTES AND ITALICS, AND FULL STOP BEFORE PASSING AS RAW
		$institution = $+{publisher};
		$date = $+{year};
		$pages = $+{pages};
	}
	elsif ($line =~ $MLA::journal_citation_pattern) { 
		$medium = "Journal";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{journal};
		$date = $+{year};
		$pages = $+{pages};
	}
	elsif ($line =~ $MLA::magazine_citation_pattern) { 
		$medium = "Magazine";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{issue};
		$institution = $+{magazine};
		$date = $+{date};
		$pages = $+{pages};
	} 
	elsif ($line =~ $MLA::website_citation_pattern) { 
		$medium = "Website";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{website};
		$institution = $+{publisher};
		$date = $+{date};
		$pages = $+{url}." Accessed: ".$+{retrieval_date};
	}
	elsif ($line =~ $MLA::thesis_citation_pattern) { 
		$medium = "Thesis";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{type};
		$institution = $+{institution};
		$date = $+{year};
		$pages = $+{pages};
	}
	elsif ($line =~ $MLA::newspaper_citation_pattern) { 
		$medium = "Newspaper";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{newspaper};
		$date = $+{year};
		$pages = $+{pages};
	}
	elsif ($line =~ $MLA::conference_citation_pattern) { 
		$medium = "Conference";
		$authors = &MLA::pull_authors($+{authors});
		$title = $+{title};
		$publication = $+{conference};
		$institution = $+{location};
		$date = $+{dates};
		$pages = $+{pages};
	}
	# GET MISSING INFO IF ANY ARE EMPTY
	# IF NO fmt IDENTIFIED, ATTEMPT TO MATCH USING GENERIC PATTERNS AND COMPLETE MISSING INFO
	# if raw info can't be pulled, needs to abort with a warning and preserve the original string
	return "Type: [$medium]; Authors: {$authors}; Title: [$title]; Publication: [$publication]; Institution: [$institution]; Date: [$date]; Pages: [$pages];";
} # TEST ME!
my $test_pull_book_info = "Smith, John, and Doe, Jane. That Book With the Title. Some Moneygrubbers, 2023, pp. 69-420.";
my $test_pull_journal_info = 'Smith, John, and Doe, Jane. "The Article Title." Some Journal, vol. 1, no. 1, 2023, pp. 1-100.';
print pull_raw_info($test_pull_journal_info);







# FORMAT RAW AS STYLE
# raw_to_fmt
	# use regex to parse the raw file and reacquire fields
	# then based on type, insert raw info into formatter string
	# and push formatted string into array of strings
	# then append the bibliography file with each line in the array
	# for now, will not have ordering capability which will be left up to the user to organize
sub raw_to_fmt {
	my ($file) = @_;
	open my $fh, '>', $file or die "Unable to edit file.";	
	while (my $line = <$fh>) {
		my $type;
		if ($line =~ qr{^Type: \[(?<type>.*?)\]}) { $type = $+{type} }
	}
}




