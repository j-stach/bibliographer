
package Fmt;

use strict;
use warnings;
use File::Basename;
use lib dirname($0);
use File;

use MLA;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(fmt_to_raw raw_to_fmt);


## -- Subroutines for pulling raw info from styled references

sub get_style {
	my ($file) = @_;
	if (open my $fh, '<', $file) {
		while (my $line = <$fh>) {
			if (&MLA::is_MLA($line)) { return "MLA" }

			else { die "$file is formatted in an unknown style, unable to retrieve raw info." }
		}
		close $fh;
	} else {
		die "ERROR: Unable to read $file\n";
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

	my $style = get_style($file);
	
	if (open my $fh, '<', $file) {
		while (my $line = <$fh>) {
			my $raw_info = pull_raw_info($line, $style);
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

sub build_raw_citation {
	my (@citation) = @_;
	my $raw_citation;
	foreach my $field (@citation) {
		$raw_citation .= $field."; "
	}
	chop $raw_citation; chop $raw_citation;
	$raw_citation .= "\n";
	return $raw_citation;
}

sub pull_raw_info {
	my ($line, $style) = @_;

	# CONSULT STYLE GUIDES TO DETERMINE WHAT FIELDS ARE REQUIRED FOR EACH TYPE OF MEDIUM

	if ($line =~ ${$style."::book_citation_pattern"}) { 
		my @citation = ("Type: [Book]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	}

	elsif ($line =~ ${$style."::journal_citation_pattern"}) { 
		my @citation = ("Type: [Journal]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $journal = $+{journal}) { push @citation, "Journal: [$journal]" }
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	}

	elsif ($line =~ ${$style."::magazine_citation_pattern"}) { 
		my @citation = ("Type: [Magazine]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $magazine = $+{magazine}) { push @citation, "Magazine: [$magazine]" }
		if (my $issue = $+{issue}) { push @citation, "Issue: [$issue]" }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	} 

	elsif ($line =~ ${$style."::website_citation_pattern"}) { 
		my @citation = ("Type: [Website]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $website = $+{website}) { push @citation, "Website: [$website]" }
		if (my $publisher = $+{publisher}) { push @citation, "Publisher: [$publisher]" }
		if (my $date = $+{date}) { push @citation, "Date: [$date]" }
		if (my $url = $+{url}) { push @citation, "URL: [$url]" }
		if (my $access_date = $+{retrieval_date}) { push @citation, "Accessed: [$access_date]" }
			else { push @citation, "Accessed: [".&File::get_current_date."]" }
		# Finder::try_get_web_info()
		return build_raw_citation(@citation);
	}

	elsif ($line =~ ${$style."::thesis_citation_pattern"}) { 
		my @citation = ("Type: [Thesis]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $thesis_type = $+{type}) { push @citation, "Thesis: [$thesis_type]"}
		if (my $institution = $+{institution}) { push @citation, "Institution: [$institution]"}
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	}

	elsif ($line =~ ${$style."::newspaper_citation_pattern"}) { 
		my @citation = ("Type: [Newspaper]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $newspaper = $+{newspaper}) { push @citation, "Newspaper: [$newspaper]"}
		if (my $date = $+{year}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	}

	elsif ($line =~ ${$style."::conference_citation_pattern"}) { 
		my @citation = ("Type: [Conference]");
		if (my $authors = eval $style.'::pull_authors($+{authors})') { push @citation, "Authors: {$authors}" }
		if (my $title = eval $style.'::trim_title($+{title})') { push @citation, "Title: [$title]" }
		if (my $conference = $+{conference}) { push @citation, "Conference: [$conference]" }
		if (my $location = $+{location}) { push @citation, "Location: [$location]" }
		if (my $date = $+{dates}) { push @citation, "Date: [$date]" }
		if (my $pages = $+{pages}) { push @citation, "Pages: [$pages]" }
		# Finder::try_get_info() 
		return build_raw_citation(@citation);
	}
}


## -- Subroutines for formatting raw info into styled references

our $raw_author_name_pattern = qr{Given:\((?<given>.*?)\) Family:\((?<family>.*?)\)};
sub author_array_from_string {
	my ($author_string) = @_;
	my @authors = m/\[$raw_author_name_pattern\]/g;
	return @authors
}

sub raw_to_fmt {
	my ($file, $style, $new) = @_;
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
			my $conference; if ($line =~ qr{\bConference: \[(?<conference>.*?)\]}) { $conference = $+{conference} }
			
			my $date; if ($line =~ qr{\bDate: \[(?<date>.*?)\]}) { $date = $+{date} }
			my $pages; if ($line =~ qr{\bPages: \[(?<pages>.*?)\]}) { $pages = $+{pages} }


			# CONSULT STYLE GUIDES TO DETERMINE WHAT FIELDS ARE REQUIRED FOR EACH TYPE OF MEDIUM
	
			if ($type =~ /Book/) {
				my $reference = eval $style.'::new_book_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Journal/) {
				my $reference = eval $style.'::new_journal_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Magazine/) {  
				my $reference = eval $style.'::new_magazine_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Website/) {
				my $reference = eval $style.'::new_website_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Thesis/) {
				my $reference = eval $style.'::new_thesis_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Newspaper/) {
				my $reference = eval $style.'::new_newspaper_citation(@authors, $title)';
				push @references, $reference;
			}
			elsif ($type =~ /Conference/) {
				my $reference = eval $style.'::new_conference_citation(@authors, $title)';
				push @references, $reference;
			}

			else { die "Raw file corrupted. Type $type not recognized." }
		}
	}
	# reorder references according to parameters
	# print each element of the array to a new line in the new file
}



1;
