#! /usr/bin/env perl

use strict;
use warnings;

use Text::ParseWords qw(shellwords);        # effectively our parser
use Term::ReadLine;                         # the readline functionality
use Cwd;                                    # for pwd builting

#
# see
# https://stackoverflow.com/questions/13332908/termreadline-i-need-to-hit-the-up-arrow-twice-to-retrieve-history
# for a necessary hack to fix this readline implementation
#

#################
# the built-ins #
#################


# the cmds that must be run in the parent process to make any sense
# builtins can be special (required) or regular (standard)
# run `type cmd` to find whether a cmd is builtin.

# the hash which we look in later
my %builtins = (
    exit        => \&psh_exit,
    bye         => \&psh_exit,
    cd          => \&psh_cd,
    chdir       => \&psh_cd,
    help        => \&psh_help,
    pwd         => \&psh_pwd,
    echo        => \&psh_echo,
    printenv    => \&psh_printenv,
    cat         => \&psh_cat,
    tac         => \&psh_tac,
    mv          => \&psh_mv,
    rm          => \&psh_rm,
    ls          => \&psh_ls,
);

# the function definitions

### TODO
# built-ins:
# ls
#
# the fixmes...


sub psh_ls {

    ### FIXME
    # only <.*> if -a
    
    foreach my $f (<* .*>) {
        print "$f\n";
    }
    return 1;
}

#
sub psh_rm {
    shift;
    print @_;
    unlink @_;
    return 1;
}

sub psh_mv {
    shift;

    my ($org, $dest) = @_;
        
    print "file not found\n" unless (-e $org);

    if (-d $dest) {
        my $base = $org;
        # sub out the head part of the directory
        $org =~ s#.*/##;
        $dest .= "/$base";
    }

    rename($org, $dest) || print("problem while moving");
    return 1;
}

sub psh_cat {
    shift;
    @ARGV = @_; 
    print <>;
    print "meow\n";
    return 1;
}

sub psh_tac {
    shift;
    foreach my $a (@_) {
        open(my $fh, $a);
        my @in = <$fh>;
        print reverse @in;
    }
    return 1;
}

sub psh_printenv {
    foreach my $key (sort keys %ENV) {
        print("$key=$ENV{$key}\n");
    }
    return 1;
}

# FIXME
sub psh_echo {
    shift;
    print("@_\n");
    return 1;
}

sub psh_pwd {
    print Cwd::getcwd() . "\n";
    return 1;
}

# exit the shell
sub psh_exit {
    print("later alligator\n");
    return 0;
}

# change directory
sub psh_cd {
    #print;
    shift;
    if(!chdir $_[0]) {
        warn("$!");
    }
    return 1;
}

# print a help message
sub psh_help {
    print("a silly little shell written in perl.");
}

# what other builtins will be nice to have and not too difficult to implement?
# for fun & learning lets do pwd and echo...
# mv, rm, see learning perl chapter

#####################

# some superfluous colouring
my $green = "\e[32m";
my $cyan = "\e[36m";
my $bold = "\e[1m";
my $reset = "\e[0m";

################
# the executor #
################

# the functions to run the commands (builtin or otherwise):
sub psh_execute {

    my @args = @_;
    
    #print("args = " . @args. "\n");
    
    my $cmd = $args[0];

    #print("cmd = ".$cmd."\n");
    
    #shift(@args);

    if (exists $builtins{$cmd}) {
        # dereference the builtin & pass the args sans the cmd
        return $builtins{$cmd}->(@args);
    }

    # if not in the builtins, we reach here
    return psh_launch(@args);
}

# to run the simple (non-built-in, to-be-child) commands
sub psh_launch {

    my $pid;

    # clone the process and create a child running the requested command
    if (!defined($pid = fork())) {
        die("$!");
    } elsif ($pid == 0) {
        # the child:
        exec(@_) or exit();
        # do we need to catch output so should we use open() instead of exec()?
    } else {
        # the parent:

        # if not a background process then
        waitpid($pid, 0);
    }

    return 1;
}

#
# FIXME 
# need to implement pipes & redirects & backgrounding...
# ie other processes besides simple commands & builtins.
#

##############
# subsystems #
##############

# to enable tab-completion of file names in pwd:
sub complete {
    my ($text, $start, $end) = @_;
    return grep { /^$text/ } (glob('*'));
}

# wildcard handling
#...

# send to the bg
# if the input starts with 'bg' or ends with '&'
# then don't wait for the exec

####################
# main subroutines #
####################

# the loop to read in from the shell:
sub loop {

    my $line;           # the user input

    # the command table:
    my @args;           # the user input, split

    my $status = 1;     # whether we keep running or not..

    # set-up the readline
    my $term = Term::ReadLine->new('psh');
    $term->Attribs->{completion_function} = \&complete;

    # define the prompt
    my $prompt = "$cyan$bold>$reset $green";

    do {
        # display the prompt
        $line = $term->readline($prompt);

        # exit the loop if line undef or EOF
        last unless defined $line;

        if ($line =~ /\S/) {            # if line is non-whitespace
            chomp($line);               # clean up new line characters

            $term->addhistory($line) if $line !~ /\S||\n/; # pretty sure this should be lower case s

            # the parser:
            # split the line using usual shell structures
            @args = shellwords($line);

            ###
            # a debug
            #foreach my $arg (@args) {
            #   print($arg."\n");
            #}
            ###
            # so shellwords will split and capture pipes, redirects, bgs...
            # so it's up to us to do the right things with these...
            ###

            # the executor:
            $status = psh_execute(@args);
        }
    } while $status;
}

sub main {

    # clear the screen
    system("clear");

    # an unnecessary welcome message
    show_welcome();

    # main loop
    loop();
    

    # exit successfully
    return;
}

########################
# an unwelcome welcome #
########################

sub show_welcome {
    
    # a custom module (see installion notes therein)
    use Weasel;

    # could be implement some kind of concurrency here?
    # so that prompt is available while animatiom plays...

    my $user = $ENV{USER} || getpwuid($<);
    my $string = "welcome, $user, to p-shell!";
    my $breaker = "-" x length($string);

    print("$green$bold");
    print("$breaker\n");    # or weasel_print?
    Weasel::weasel_print($string);
    print("$breaker\n");    # or weasel_print?
    print("$reset");
}

######

main();
