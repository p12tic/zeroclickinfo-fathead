#!/usr/bin/env perl

use strict;
use warnings;

use XML::Simple qw(:strict);

my $xs = XML::Simple->new;
my $iana = $xs->XMLin('port-numbers.iana', ForceArray => 1, KeyAttr => 0);

my $records = $iana->{record};

open my $output, '>', 'output.txt';
for my $record (@{$records}) {
    if (exists $record->{number} and exists $record->{protocol}) {
        my $result = "[$record->{protocol}[0]] $record->{number}[0]"
                    . (exists $record->{description} and $record->{description}[0] ne '' ?
                        " - $record->{description}[0]" : '')
                    . "\n";
        print $output join "\t", (
            $record->{number}[0],                # title
            "A",                                 # type
            "",                                  # redirect
            "",                                  # otheruses
            "services",                          # categories
            "",                                  # references
            "",                                  # see_also
            "",                                  # further_reading
            "",                                  # external_links
            "",                                  # disambiguation
            "",                                  # images
            $result,                             # abstract
            "https://www.iana.org/protocols\n"   # source_url
        );
    }
}
close $output;
