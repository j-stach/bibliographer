
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

sub build_citation {
	my (@citation) = @_;
	my $raw_citation;
	foreach my $field (@citation) {
		$raw_citation .= $field."; "
	}
	chop $raw_citation;
	return $raw_citation;
}

sub pull_raw_info {
	my ($line) = @_;

	# CONSULT STYLE GUIDES TO DETERMINE WHAT FIELDS ARE REQUIRED FOR EACH TYPE OF MEDIUM
	# MLA::trim_title()
	# Crossref::try_get_info() 
	# missing_info() collects missing info into array and calls at end of function to query crossref api
	# Crossref::try_get_web_info()
	# &File::get_current_date

	if ($line =~ $MLA::book_citation_pattern) { 
		my @citation = ("Type: [Book]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
			# else { try_get_info('publisher') }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		return build_citation(@citation);
	}
	elsif ($line =~ $MLA::journal_citation_pattern) { 
		my @citation = ("Type: [Journal]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $journal = $+{journal}) { push @citation, "Journal: [$journal]" }
			# else { try_get_info('journal') }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
			# else { try_get_info('pages') }
		return build_citation(@citation);
	}
	elsif ($line =~ $MLA::magazine_citation_pattern) { 
		my @citation = ("Type: [Magazine]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $magazine = $+{magazine}) { push @citation, "Magazine: [$magazine]" }
			# else { try_get_info('magazine') }
		if (my $issue = $+{issue}) { push @citation, "Issue: [$issue]" }
			# else { try_get_info('issue') }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
			# else { try_get_info('pages') }
		return build_citation(@citation);
	} 
	elsif ($line =~ $MLA::website_citation_pattern) { 
		my @citation = ("Type: [Website]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_web_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_web_info('title') }
		if (my $website = $+{website}) { push @citation, "Website: [$website]" }
			# else { try_get_web_info('website') }
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
			# else { try_get_web_info('publisher') }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
			# else { try_get_web_info('date') }
		if (my $url = $+{url}) { push @citation, "URL: [$url]" }
		if (my $access_date = $+{retrieval_date}) { push @citation, "Accessed: [$access_date]" }
			# else { &get_current_date }
		return build_citation(@citation);
	}
	elsif ($line =~ $MLA::thesis_citation_pattern) { 
		my @citation = ("Type: [Thesis]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $thesis_type = $+{type}) { push @citation, "Thesis: [$thesis_type]"}
			# else { try_get_info('thesis_type') }
		if (my $institution = $+{institution}) { push @citation, "Institution: [$institution]"}
			# else { try_get_info('institution') }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
			# else { try_get_info('pages') }
		return build_citation(@citation);
	}
	elsif ($line =~ $MLA::newspaper_citation_pattern) { 
		my @citation = ("Type: [Newspaper]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $newspaper = $+{newspaper}) { push @citation, "Newspaper: [$newspaper]"}
			# else { try_get_info('newspaper') }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
			# else { try_get_info('pages') }
		return build_citation(@citation);
	}
	elsif ($line =~ $MLA::conference_citation_pattern) { 
		my @citation = ("Type: [Conference]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
			# else { try_get_info('authors') }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
			# else { try_get_info('title') }
		if (my $conference = $+{conference}) { push @citation, "Conference: [$conference]" }
			# else { try_get_info('conference') }
		if (my $location = $+{location}) { push @citation, "Location: [$location]" }
			# else { try_get_info('location') }
		if (my $date = $+{dates}) { push @citation, "Date: [$date]" }
			# else { try_get_info('date') }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
			# else { try_get_info('pages') }
		return build_citation(@citation);
	}
	# IF NO fmt IDENTIFIED, ATTEMPT TO MATCH USING GENERIC PATTERNS AND COMPLETE MISSING INFO
	# if raw info can't be pulled, needs to abort with a warning and preserve the original string
}



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




