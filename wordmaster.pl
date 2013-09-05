#!/usr/bin/perl

use strict;
use warnings;

open(my $fh, '<', './words.txt') or die "$!\n";

my $pattern = shift;

while(<$fh>) {
    chomp;
    print "$_\n" if /$pattern/;
}

close($fh);

