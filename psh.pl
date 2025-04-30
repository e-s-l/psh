# /usr/bin/env perl

use strict;
use warnings;

use Text::ParseWords qw(shellwords);
use Term::ReadLine;


# the built-in commands:
sub psh_exit {
	print("later alligator\n");
	return 0;
}

sub psh_cd {
	if(!chdir $_[1]) {
		warn("$!");
	}
	return 1;
}

sub psh_help {
	print("a silly little shell written in perl.");
}

# the functions to run the commands (builtin or otherwise):
sub psh_launch {

	my $pid;

	# clone the process and create a child running the requested command
	if (!defined($pid = fork())) {
		die("$!");
	} elsif ($pid == 0) {
		# the child:
		exec(@_) or exit();
	} else {
		# the parent:
		waitpid($pid, 0);
	}

	return 1;
}

sub psh_execute {

	my @args = @_;

	# the cmds that must be run in the parent process to make any sense
	my %builtins = (
		exit => \&psh_exit,
		cd   => \&psh_cd,
		help => \&psh_help,
	);

	if (exists $builtins{$args[0]}) {
		return $builtins{$args[0]}->(@args);
	}

	# if not in the builtins, we reach here
	return psh_launch(@args);
}

# to enable tab-completion of file names in pwd:
sub complete {
	my ($text, $start, $end) = @_;
	return grep { /^$text/ } (glob('*'));
}

# the loop to read in from the shell:
sub loop {

	my $line;			# the user input
	my @args;			# the user input, split
	my $status = 1;		# whether we keep running or not..

	# set-up the readline
	my $term = Term::ReadLine->new('psh');
	$term->Attribs->{completion_function} = \&complete;

	# some superfluous colouring
	my $green = "\e[32m";
	my $cyan = "\e[36m";
	my $bold = "\e[1m";
	my $reset = "\e[0m";

	# define the prompt
	my $prompt = "$cyan$bold> $reset$green$bold";

	do {
		# display the prompt
		$line = $term->readline($prompt);

		# exit the loop if line undef or EOF
		last unless defined $line;

		if ($line =~ /\S/) {
			chomp($line);				# clean up new line characters
			$term->addhistory($line);

			# split the line using usual shell structures
			@args = shellwords($line);

			$status = psh_execute(@args);
		}
	} while $status;
}

sub main {

	# clear the screen
	print("\e[2J\e[H");
	STDOUT->flush();

	# main loop
	loop();
	
	# exit successfully
	return;
}

main();
