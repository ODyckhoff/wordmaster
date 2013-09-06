#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw( :config posix_default bundling no_ignore_case );
our( @words, $type, $raw );

GetOptions ( "type|t=s" => \$type,
             "raw|r=s"    => \$raw,
           );

$type = $type || 'search';

open( my $fh, '<', '/home/ijz/.irssi/scripts/words.txt' ) or die "$!\n";

while( <$fh> ) {
    chomp;
    $words[$. - 1] = $_;
}

close( $fh );

if( $type eq 'search' ) {
    # Simple search of the word list.

    if( $raw ) {
        foreach my $word ( @words ) {
            print $word, "\n" if $word =~ /$raw/;
        }
    }
}
