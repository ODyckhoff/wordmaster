#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw( :config posix_default bundling no_ignore_case );
our( @words, $type, $raw, $data, $known, $whole, $ends, $starts );

GetOptions ( "type|t=s"        => \$type,
             "raw|r=s"         => \$raw,
             "data|d=s"        => \$data,
             "known|k=s"       => \$known,
             "whole|w"         => \$whole,
             "starts-with|s=s" => \$starts,
             "ends-in|e=s"     => \$ends,
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

if( $type eq 'codeword' ) {
    # Codeword subroutine.
    $whole = 1;

    my %unknown = ();

    # Parse input
    $known =~ s/[\W]//g; # Sanitise known letters. Get rid of commas if there are any, etc.

    # Get positions of unknown letters and their numbers.
    my $length = length( $data );

    my $tmp = $data;

    my @heads = ();
    my $head;
    my $tail;
    my $pos = 0;
    my $slot = 0;

    while ( ( my $index = index( $tmp, ']' ) ) != -1 ) {  # Find the end of a number marking.
        

        $head = substr( $tmp, 0, $index + 1 ); # Last character should be ']'.
        push( @heads, ($head =~ /^([a-zA-Z]+)/ ? $1 : '' ) );
        $tail = substr( $tmp, $index + 1 );

        my $numindex = index( $head, '[' ); # Find the beginning of the number marking.
        my $num = substr( $head, $numindex + 1, -1 );

        $pos += $numindex + 1;

        $unknown{$slot} = $num;
        $slot++;
        $tmp = $tail;
    }

    my %counts = ();

    foreach my $key ( sort { $a <=> $b }  keys %unknown ) {

        my $value = $unknown{$key};
        push( @{ $counts{$value} }, $key );
        
    }

    # Build regular expression.

    my $regex;
    my $subtract = 0;
    foreach my $position ( sort { $a <=> $b } keys %unknown ) {
        my $subregex;
        if( $position == 0 ) {
            $subregex = '([^' . $known . '])';
        }
        else {
            my @tmparr = @{ $counts{ $unknown{ $position } } };
            my $countindex;
            if( @tmparr ) {
                ( $countindex ) = grep { $tmparr[$_] eq $position } 0 .. ( scalar( @tmparr ) - 1);
            }
            if( scalar( @tmparr ) > 1 && $countindex > 0 ) {
                $subregex = '\\' . ( $tmparr[0] + 1 );
                $subtract++;
            }
            else {
                for( my $i = 1; $i <= $position - $subtract; $i++ ) {
                    $subregex .= '\\' . $i . '|';
                }
                $subregex =~ s/\|$//;
                $subregex = '(?!' . ( $position > 1 ?  '(' . $subregex . ')' : $subregex ) . ')([^' . $known . '])';
            }
        }
        $regex .= $heads[$position] . $subregex;
    }
    $regex .= $tail;

    if( $whole ) {
        $regex = '^' . $regex . '$';
    }

    foreach my $word ( @words ) {
        print $word, "\n" if $word =~ /$regex/;
    }
}
