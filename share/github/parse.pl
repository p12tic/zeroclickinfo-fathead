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

        my $description = $repo->{description};

        next if !$description;

        # Lowercase the first letter unless it's part of an abbreviation
        my $first_is_abbr = 0;

        if ($description =~ m/^[A-Z0-9]{2,}\b/) {
            $first_is_abbr = 1;
        }

        $description = lcfirst($description) unless $first_is_abbr;

        $description =~ s/\.$//;

        my $owner = $repo->{owner}->{login};

        $abstract .= "Software description: $description (created by $owner).";

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
