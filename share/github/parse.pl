#!/usr/bin/env perl

use strict;
use warnings;

use JSON::XS;
use Data::Dumper;

use encoding "utf-8";

open(IN, "<:encoding(ISO-8859-1)", "data-head.txt");
open(OUT, ">:encoding(UTF-8)", "output.txt");

my %dups;

my $i = 1;
while (my $line = <IN>) {
    my $page = decode_json($line);

    foreach my $repo (@$page) {

        # Skip forks
        next if $repo->{fork};

        # Check for repos with the same name
        next if exists $dups{$repo->{name}};

        my $abstract = '';

        $abstract .= "<i>Owner</i>: $repo->{owner}->{login}<br>";
        $abstract .= "<i>Description</i>: $repo->{description}<br>";

        my @output = (
            $repo->{name},          # Title
            'A',                    # Type
            '',                     # Redirect
            '',                     # Other uses
            '',                     # Categories
            '',                     # References
            '',                     # See also
            '',                     # Further reading
            '',                     # External links
            '',                     # Disambiguation
            '',                     # Images
            $abstract,              # Abstract
            $repo->{html_url},      # Source URL
        );

        print OUT join("\t", @output) . "\n";

        $dups{$repo->{name}} = undef;
    }
}
