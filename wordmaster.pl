#!/usr/bin/perl

use strict;
use warnings;

open(my $fh, '<', '/home/ijz/.irssi/scripts/words.txt') or die "$!\n";

my $pattern = shift;

while(<$fh>) {
    chomp;
    print "$_\n" if /$pattern/;
}

close($fh);

