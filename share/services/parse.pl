#!/usr/bin/env perl

use strict;
use warnings;

use XML::Simple qw(:strict);

my $xs = XML::Simple->new;
my $iana = $xs->XMLin('port-numbers.iana', ForceArray => 1, KeyAttr => 0);

my $records = $iana->{record};

map {
    print "[$_->{protocol}[0]] $_->{number}[0]"
        . (exists $_->{description} and $_->{description}[0] ne '' ?
            " - $_->{description}[0]" : '')
        . "\n"
        if exists $_->{number} and exists $_->{protocol};
} @{$records};
