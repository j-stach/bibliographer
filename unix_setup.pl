
use strict;
use warnings;
use File::Basename;
use Cwd;

# Script for setting up program on Linux and MacOS systems
# Run this using 'sudo' or add the desired components manually -- see README for more details


# Create an alias so bibliographer can be called elegantly, regardless of the current directory
my $program_file = getcwd()."/src/main.pl";
print "Program file located at $program_file\n";
my $alias = "bibliographer='perl $program_file'";
print "The alias should be: $alias\n";

my $shell = $ENV{'SHELL'};
print "Is your shell $shell? (Y/n) ";

my $response = <STDIN>;
if ($response =~ qr/(Y\n|y\n|^\n)/) {
	print "Coolio!\n";
} else {
	print "Unable to create alias for 'bibliographer'. Please add the alias '$alias' to your shell's configuration file.\n";
}

# Directory for holding unformatted bibliographies
my $raw_dir = "./raw_bibs/";
# Directory for holding saved formatted bibliographies upon export
my $save_dir = "./saved_bibs/";

unless (-d $raw_dir) {
	mkdir $raw_dir or die "Failed to create directory. Please add '$raw_dir' to the root directory.\n $!";
	print "Created raw directory: $raw_dir\n";
}
unless (-d $save_dir) {
	mkdir $save_dir or die "Failed to create directory. Please add '$raw_dir' to the root directory.\n $!";
	print "Created raw directory: $save_dir\n";
}
