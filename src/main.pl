
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

	if ($line =~ $MLA::book_citation_pattern) { 
		my @citation = ("Type: [Book]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	}

	elsif ($line =~ $MLA::journal_citation_pattern) { 
		my @citation = ("Type: [Journal]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $journal = $+{journal}) { push @citation, "Journal: [$journal]" }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	}

	elsif ($line =~ $MLA::magazine_citation_pattern) { 
		my @citation = ("Type: [Magazine]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $magazine = $+{magazine}) { push @citation, "Magazine: [$magazine]" }
		if (my $issue = $+{issue}) { push @citation, "Issue: [$issue]" }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	} 

	elsif ($line =~ $MLA::website_citation_pattern) { 
		my @citation = ("Type: [Website]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $website = $+{website}) { push @citation, "Website: [$website]" }
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
		if (my $url = $+{url}) { push @citation, "URL: [$url]" }
		if (my $access_date = $+{retrieval_date}) { push @citation, "Accessed: [$access_date]" }
			else { push @citation, "Accessed: [".&File::get_current_date."]" }
		# Finder::try_get_web_info()
		return build_citation(@citation);
	}

	elsif ($line =~ $MLA::thesis_citation_pattern) { 
		my @citation = ("Type: [Thesis]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $thesis_type = $+{type}) { push @citation, "Thesis: [$thesis_type]"}
		if (my $institution = $+{institution}) { push @citation, "Institution: [$institution]"}
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	}

	elsif ($line =~ $MLA::newspaper_citation_pattern) { 
		my @citation = ("Type: [Newspaper]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $newspaper = $+{newspaper}) { push @citation, "Newspaper: [$newspaper]"}
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	}

	elsif ($line =~ $MLA::conference_citation_pattern) { 
		my @citation = ("Type: [Conference]");
		if (my $authors = &MLA::pull_authors($+{authors})) { push @citation, "Authors: {$authors}" }
		if (my $title = $+{title}) { push @citation, "Title: [$title]" }
		# MLA::trim_title()
		if (my $conference = $+{conference}) { push @citation, "Conference: [$conference]" }
		if (my $location = $+{location}) { push @citation, "Location: [$location]" }
		if (my $date = $+{dates}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_citation(@citation);
	}
	# IF NO fmt IDENTIFIED, ATTEMPT TO MATCH USING GENERIC PATTERNS AND COMPLETE MISSING INFO
	# if raw info can't be pulled, needs to abort with a warning and preserve the original string
}


sub raw_to_mla {
	my ($file) = @_;
	open my $fh, '>', $file or die "Unable to edit file.";	
	my @references;
	while (my $line = <$fh>) {
		if ($line =~ qr{^Type: \[(?<type>.*?)\]}) { 
			my $type = $+{type};
			my $authors; if ($line =~ qr{\bAuthors: \{(?<authors>.*?)\}}) { $authors = $+{authors} }
			my @authors; # get individual authors as a list
			my $title; if ($line =~ qr{\bTitle: \[(?<title>.*?)\]}) { $title = $+{title} }

			my $publisher; if ($line =~ qr{\bPublisher: \[(?<publisher>.*?)\]}) { $publisher = $+{publisher} } 
			my $journal; if ($line =~ qr{\bJournal: \[(?<journal>.*?)\]}) { $journal = $+{journal} }
			
			my $magazine; if ($line =~ qr{\bMagazine: \[(?<magazine>.*?)\]}) { $magazine = $+{magazine} }
			my $issue; if ($line =~ qr{\bIssue: \[(?<issue>.*?)\]}) { $issue = $+{issue} }
			
			my $website; if ($line =~ qr{\bWebsite: \[(?<website>.*?)\]}) { $website = $+{website} }
			my $url; if ($line =~ qr{\bURL: \[(?<url>.*?)\]}) { $url = $+{url} }
			my $access; if ($line =~ qr{\bAccessed: \[(?<access>.*?)\]}) { $access = $+{access} }

			my $newspaper; if ($line =~ qr{\bNewspaper: \[(?<newspaper>.*?)\]}) { $newspaper = $+{newspaper} }

			my $thesis; if ($line =~ qr{\bThesis: \[(?<thesis>.*?)\]}) { $thesis = $+{thesis} }
			my $institution; if ($line =~ qr{\bInstitution: \[(?<institution>.*?)\]}) { $institution = $+{institution} }
			my $location; if ($line =~ qr{\bLocation: \[(?<location>.*?)\]}) { $location = $+{location} }
			
			my $date; if ($line =~ qr{\bDate: \[(?<date>.*?)\]}) { $date = $+{date} }
			my $pages; if ($line =~ qr{\bPages: \[(?<pages>.*?)\]}) { $pages = $+{pages} }

			if ($type =~ /Book/) {
				# create string
				# append fields to string in proper order and format
			}

			elsif ($type =~ /Journal/) {
			
			}

			elsif ($type =~ /Magazine/) {  
			
			}

			elsif ($type =~ /Website/) {

			}

			elsif ($type =~ /Thesis/) {

			}

			elsif ($type =~ /Newspaper/) {
			
			}

			elsif ($type =~ /Conference/) {
			
			}

			else { die "Raw file corrupted. Type $type not recognized." }
		}

		# push to temp array @references, to make for easy ordering?
	}
	# reorder references according to parameters
	# print each element of the array to a new line in the new file
}




