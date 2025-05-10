#! /usr/bin/env perl

package Weasel;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw/ weasel_print / ],
};

##################

sub weasel_print {

    $| = 1; 										#enable stdout autoflush
    my $speed = 0.005; 								# sleep interval
    my $destination = shift @_ || die("No input");  # the final sentence
    my $sentence = "";								# place holder

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

##################

# always truly end a module
1;
