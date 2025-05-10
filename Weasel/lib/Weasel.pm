package Weasel;

use 5.036000;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Weasel ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
weasel_print	
);

our $VERSION = '0.01';

sub weasel_print {

    $| = 1; 						# enable stdout autoflush
    my $speed = 0.005; 					# sleep interval
    my $destination = shift @_ || die("No input");  	# the final sentence
    my $sentence = "";					# place holder

    # all printable ascii characters (including spaces):
    my @chars = map { chr($_) } (32..126);

    # create initial string of random characters
    for(my $i = 0; $i < length($destination); ++$i) {
        substr($sentence, $i, 1) = $chars[rand @chars];
    }

	# generate an 'animation':
    while ($sentence ne $destination) {
        for(my $i = 0; $i < length($destination); ++$i) {
            if (substr($destination, $i ,1) ne substr($sentence, $i, 1)) {
                substr($sentence, $i, 1) = $chars[rand @chars];
            }
        }
        print("$sentence\r");
        select(undef, undef, undef, $speed);		# sleep, decimal seconds
    }
    print("$sentence\n");
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

#######
# POD #
#######

=head1 NAME

Weasel - Perl program to print an animation, of sorts. 

=head1 SYNOPSIS

  use Weasel;

=head1 DESCRIPTION

This utility prints an animation akin to the Weasel evolutionary program,
but it isn't. Carridge return over a string of random characters until they
match the parsed input string.

=head1 AUTHOR

Pearl Lee, E<lt>pearl@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 by Pearl Lee

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.36.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
