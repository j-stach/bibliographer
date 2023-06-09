
use strict;
use warnings;
use Cwd;

# Script for setting up program on Linux and MacOS systems
# Run this using 'sudo' or add the desired components manually -- see README for more details



# Directory for holding unformatted bibliographies
my $raw_dir = "./raw_bibs/";
# Directory for holding saved formatted bibliographies upon export
my $save_dir = "./saved_bibs/";

unless (-d $raw_dir) {
	mkdir $raw_dir or die "Failed to create directory: $!\nPlease add '$raw_dir' to the root directory.\n";
	print "Created raw directory: $raw_dir\n";
}
unless (-d $save_dir) {
	mkdir $save_dir or die "Failed to create directory: $!\nPlease add '$save_dir' to the root directory.\n";
	print "Created save directory: $save_dir\n";
}



# Add an alias for bibliographer to the shell configuration file
my $program_file = getcwd()."/src/main.pl";
my $program = "'perl $program_file'";

my $shell_path = $ENV{'SHELL'};
if ($shell_path =~ m{/bin/([^/]+)$}) {
	my $shell = $1;
	if (my $config = find_shell_config($shell)) {
		if (modify_config($shell, $config)) {
			print "Setup successful. Restart your shell for changes to take effect.\n";
		} else {
			print shell_config_error();
		}
	}
} else {
	print "ERROR: Shell could not be identified.";
	print shell_config_error();
}

sub find_shell_config {
	my ($shell) = @_;
	my %local_config_files = (
		'bash' => "$ENV{HOME}/.bashrc",
		'zsh' => "$ENV{HOME}/.zshrc",
		'fish' => "$ENV{HOME}/.config/fish/config.fish",
		'tcsh' => "$ENV{HOME}/.tcshrc",
		'ksh' => "$ENV{HOME}/.kshrc",
		'csh' => "$ENV{HOME}/.cshrc",
	);
	my %global_config_files = (
		'bash' => '/etc/bash.bashrc',
		'zsh' => '/etc/zsh/zshrc',
		'fish' => '/etc/fish/config.fish',
		'tcsh' => '/etc/tcsh.cshrc',
		'csh' => '/etc/csh.cshrc',
	);
	# Configure the user shell instead of the global default. Change this?
	if (exists $global_config_files{$shell}) {
		my $config = $global_config_files{$shell};
		if (-e $config) {
			print "Config file found at $config\n";
			return $config;
		} else {
			print "ERROR: Shell configuration file not found.\n";
		}
	} elsif (exists $local_config_files{$shell}) {
		my $config = $local_config_files{$shell};
		if (-e $config) {
			print "Config file found at $config\n";
			return $config;
		} else {
			print "ERROR: Shell configuration file not found.\n";
		}
	} else {
		print "ERROR: Shell configuration file not found.\n";
		print shell_config_error();
	}
}

sub modify_config {
	my ($shell, $config) = @_;
	my $alias = generate_alias($shell);
	if (check_config($config, $alias) == 0) {
		print "Alias not present, adding to $config.\n";
		add_alias($config, $alias);
	}
	if (check_config($config, $alias) == 0) {
		print "ERROR: Failed to add alias.\n";
		return 0;
	} else { 
		print "Alias is present in $config\n";
		return 1; 
	}
}

sub generate_alias {
	my ($shell) = @_;
	my %aliases = (
		'bash' => 'bibliographer='.$program,
		'zsh' => 'bibliographer='.$program,
		'fish' => 'bibliographer '.$program,
		'tcsh' => 'bibliographer '.$program,
		'ksh' => 'bibliographer='.$program,
		'csh' => 'bibliographer '.$program,
		
	);
	if (exists $aliases{$shell}) {
		my $alias = $aliases{$shell};
		return $alias;
	}
}

sub check_config {
	my ($config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	if (open my $fh, '<', $config) {
		while (my $line = <$fh>) {
			return 1 if $line eq $alias_line;
		}
		close $fh;
		return 0;
	} else {
		print "ERROR: Failed to read $config\n";
		return 0;
	}	
}

sub add_alias {
	my ($config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	open my $fh, '>>', $config or die "ERROR: Failed to modify $config\n$!";
	print $fh $alias_line;
	close $fh;
}

sub shell_config_error {
	return qq{ERROR: Unable to create alias for 'bibliographer'.\nERROR: Please add the alias for $program to your shell's configuration file.\n};
}


