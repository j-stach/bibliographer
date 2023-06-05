
use v5.36;
use Cwd;
use Getopt::Long;
use File::Basename;
use lib dirname($0);

use Test;
use Help;

use RAW;
use MLA;

my $version = "version 0.1 2023";

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
	'test|t' => \$test,
	'help|h' => \$help,
	'version|v'=> sub { print "$version\n" },

	# VERBOSE / QUIET
	# CONFIG (command?) or separate file, for holding configuration parameters and API keys
	# FIX (command?) attempts to retrieve missing citation info
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
	}
}



sub convert {
	my ($filename, $new) = @_;
	if (my $file = find_filename($filename)) {
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
	if (my $file = find_rawfile($rawfile)) {
		if (check_style() == 1) {
			my $new_fmt = $style[0]; 
			print "Convert $rawfile to $new_fmt"; if ($new) { print " and save as $new.rtf"; } print "\n";
		} elsif (check_style() == 0) { print "Cannot export as raw. Please provide a CITATION_STYLE flag.\n"; }
	}
}


sub find_filename {
	my ($filename) = @_;
	if ($filename =~ /\.rtf$/) {
		my $cwd = getcwd();
		if (-e "$cwd/$filename") {
			my $file = "$cwd"."$filename";
			print "$filename found in $cwd\n";
			return $file
		}
		elsif ($filename =~ "/" && (-e "$filename")) {
			print "File path $filename found. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response =~ /^y\n$|^Y\n$|^\n$/) { return $filename }
			else { print "ERROR: $filename could not be located.\n"; exit }
		}
		elsif (-e "$save_dir/$filename") {
			my $file = "$save_dir"."$filename";
			print "$filename found in bibliographer save directory. Use it? (Y/n) ";
			my $response = <STDIN>;
			if ($response =~ /^y\n$|^Y\n$|^\n$/) { return $file }
			else { print "ERROR: $filename could not be located.\n"; exit }
		} else { print "ERROR: $filename could not be located.\n"; exit }
	} else { print "ERROR: File to be read ($filename) must have '.rtf' file extension.\n"; exit }
}

sub find_rawfile {
	my ($rawfile) = @_;
	my $raw = "$raw_dir"."$rawfile.raw.txt";
	if (-e "$raw") {
		print "$rawfile found.\n";
		return $raw
	} else { print "ERROR: $raw could not be found.\n"; exit }
}


# IDENTIFY FORMAT TYPE or PARSE USING REGEX FROM UNKNOWN FORMATTING
sub id_fmt {
	my ($file) = @_;
	open my $fh, '<', $file or die "Unable to open file.";
	while (my $line = <$fh>) {
		if ($line =~ $MLA::book_citation_pattern ||
		$line =~ $MLA::journal_citation_pattern || 
		$line =~ $MLA::magazine_citation_pattern || 
		$line =~ $MLA::website_citation_pattern || 
		$line =~ $MLA::thesis_citation_pattern || 
		$line =~ $MLA::newspaper_citation_pattern || 
		$line =~ $MLA::conference_citation_pattern ) { return "MLA";}
	# ADD OTHER CITATION STYLES HERE
	}
	close $fh;
	return "Unknown format";
} # NEEDS DEBUGGING!

# brute_parse 
	# using flexible regex pattern, attempt to locate elements from the citation according to generics
	# use crossref api to identify medium type

# CONVERT TO RAW BIBLIOGRAPHY

sub get_filename {
	my ($file) = @_;
	my $filename_pattern = qr{/?(?<filename>[\.\p{L}\p{Nd}]+)\.rtf$};
	my $filename;
	if ($file =~ $filename_pattern) {
		$filename = $+{filename};
	}
} # TEST ME!

# fmt_to_raw
	# for each line, id_medium based on style, then use matching regex to extract fields
	# create a collection of the fields, 
	# then if any are missing, or "and others" is triggered for authors, attempt to retreive using crossref api
	# (if crossref fails, warn that a fix should be attempted later)
	# push refs of each collection to a new bibliography array as they are created
	# create a new file in raw dir, and print each collection to the file in a "raw" formatted line
sub fmt_to_raw {
	my ($file, $rawname) = @_;
	my $fmt = id_fmt($file);

	my $rawfile;
	if ($rawname) {	
		$rawfile = $rawname;
	} else {
		$rawfile = get_filename($file);
	}
	my $raw = "$raw_dir"."$rawfile.raw.txt";

	if (-e "$raw") {
		print "$raw already exists, overwrite? (y/N) "; 
		my $response = <STDIN>;
		if ($response !~ /^y\n$|^Y\n$/) {
			print "Enter new bibliography name: ";
			my $newname = <STDIN>;
			$raw = "$raw_dir"."$newname.raw.txt";
			# IF RAW STILL EXISTS, REDO THE LOOP
		}
	}

	open my $rf, '>', $raw or die "Unable to create rawfile: $!\n"; # NEEDS TO PASS ERROR, DOES "$!" APPLY ?
	close $rf;
	
	if (open my $fh, '<', $file) {
		while (my $line = <$fh>) {
			my $raw_info = pull_raw_info($line, $fmt);
			open my $rf, '>>', $raw;
			print $rf $raw_info;
		}
		close $fh;
		return 0;
	} else {
		print "ERROR: Failed to read $file\n";
		return 0;
	}	


}


# Raw file formatting:
# Type: [] Authors: {} Title: [] Publication: [] Institution: [] Location: [] Date: [] Pages: [] 
sub pull_raw_info {
	my ($line, $fmt) = @_;
	my $medium = id_medium($line, $fmt);
	my @authors; my $title; my $publication; my $institution; my $location; my $date; my $pages;

	if ($fmt eq "MLA") {
		if ($line =~ $MLA::book_citation_pattern) { 
			@authors = $+{authors}; 
			$title = $+{title};
			$institution = $+{publisher};
			$date = $+{year};
			$pages = $+{pages};
		}
		elsif ($line =~ $MLA::journal_citation_pattern) { return "journal" }
		elsif ($line =~ $MLA::magazine_citation_pattern) { return "magazine" } 
		elsif ($line =~ $MLA::website_citation_pattern) { return "website" }
		elsif ($line =~ $MLA::thesis_citation_pattern) { return "thesis" }
		elsif ($line =~ $MLA::newspaper_citation_pattern) { return "newspaper" }
		elsif ($line =~ $MLA::conference_citation_pattern) { return "conference" }
	}
	return "Type: [$medium]; Authors: [@authors]; Title: [$title]; Publication: [$publication]; Institution: [$institution]; Date: [$date]; Pages: [$pages];";
} # TEST ME!
my $test_pull_book_info = "Smith, John, and Doe, Jane. That Book With the Title. Some Moneygrubbers, 2023, pp. 69-420.";
my $test_pull_journal_info = 'Smith, John, and Doe, Jane. "The Article Title." Some Journal, vol. 1, no. 1, 2023, pp. 1-100.';
print pull_raw_info($test_pull_book_info, "MLA");

sub id_medium {
	my ($line, $fmt) = @_;
	if ($fmt eq "MLA") {
		if ($line =~ $MLA::book_citation_pattern) { return "book" }
		elsif ($line =~ $MLA::journal_citation_pattern) { return "journal" }
		elsif ($line =~ $MLA::magazine_citation_pattern) { return "magazine" } 
		elsif ($line =~ $MLA::website_citation_pattern) { return "website" }
		elsif ($line =~ $MLA::thesis_citation_pattern) { return "thesis" }
		elsif ($line =~ $MLA::newspaper_citation_pattern) { return "newspaper" }
		elsif ($line =~ $MLA::conference_citation_pattern) { return "conference" }
		else { 
			print qq{WARNING: "$line" could not be parsed\n};
			return "unknown" 
		}	
	}
	elsif ($fmt eq "RAW") {
		# PATTERN MATCHING FOR RAW	
	}
	else { print "ERROR: Style not recognized.\n" }
}






# FORMAT RAW AS STYLE
# raw_to_fmt
	# use regex to parse the raw file and reacquire fields
	# then based on type, insert raw info into formatter string
sub raw_to_fmt {
	my ($file) = @_;
	open my $fh, '>', $file or die "Unable to edit file.";	
}






# ORDERING ? Some reference lists are ordered alphabetically while others are dependent upon their order of appearance in manuscript
# May need to expand the program to accomodate entire manuscript, and change in-text references as well

