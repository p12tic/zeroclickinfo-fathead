#!/usr/bin/env perl

use strict;
use warnings;

use XML::Simple qw(:strict);
use Data::Dumper;

my $xs = XML::Simple->new;
my $iana = $xs->XMLin('port-numbers.iana', ForceArray => 1, KeyAttr => 0);

my $records = $iana->{record};
my %results;

for my $record (@{$records}) {
    if (exists $record->{number} and exists $record->{protocol}) {
        $results{$record->{number}[0]} =
                (exists $results{$record->{number}[0]} ?
                    "$results{$record->{number}[0]}<br>" : '')
                . "[$record->{protocol}[0]] $record->{number}[0]"
                . (exists $record->{description} and $record->{description}[0] ne '' ?
                    " - $record->{description}[0]" : '');
    }
}

open my $output, '>', 'output.txt';
map {
        print $output join "\t", (
            $_,                                  # title
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
            $results{$_},                        # abstract
            "https://www.iana.org/protocols\n"   # source_url
        );
} keys %results;
close $output;
