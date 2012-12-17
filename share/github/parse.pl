#!/usr/bin/env perl

use strict;
use warnings;

use JSON::XS;
use Data::Dumper;

use DateTime::Format::ISO8601;

open(IN, '<', 'data-head.txt');
open(OUT, '>', 'output.txt');

my %dups;

my $i = 1;
while (my $line = <IN>) {
    my $page = decode_json($line);

    foreach my $repo (@$page) {

        # Skip forks
        next if $repo->{fork};

        # Check for repos with the same name
        next if check_dups($repo);

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
            $repo->{description},   # Abstract
            $repo->{html_url},      # Source URL
        );

        print OUT join("\t", @output);

        $dups{$repo->{name}} = {
            forks_count => $repo->{forks_count},
            watchers_count => $repo->{watchers_count},
            updated_at => $repo->{updated_at}
        };

        warn Dumper \%dups;
    }
}

sub check_dups {
    my $repo = shift;

    if (exists $dups{$repo->{name}}) {
        my $original = $dups{$repo->{name}};

        my $orig_score = 0;
        my $new_score = 0;

        # +1 to the repo with more watchers

        my $watch_cmp = $original->{watchers_count} cmp $repo->{watchers_count};

        if ($watch_cmp == -1) {
            $orig_score++;
        }
        elsif ($watch_cmp == 1) {
            $new_score++;
        }

        # +1 to the repo with more forks

        my $fork_cmp = $original->{forks_count} cmp $repo->{forks_count};

        if ($fork_cmp == -1) {
            $orig_score++;
        }
        elsif ($fork_cmp == 1) {
            $new_score++;
        }

        # +1 to the repo that has been updated most recently

        my $orig_dt = DateTime::Format::ISO8601->parse_datetime($original->{updated_at});
        my $new_dt = DateTime::Format::ISO8601->parse_datetime($repo->{updated_at});

        my $update_cmp = DateTime->compare($orig_dt, $new_dt);

        if ($update_cmp == -1) {
            $orig_score++;
        }
        elsif ($update_cmp == 1) {
            $new_score++;
        }

        # If the new repo isn't the winner, keep the old one
        my $winner = $orig_score cmp $new_score;

        if ($winner == 1) {
            delete $dups{$repo->{name}};
            return 0;
        } else {
            return 1;
        }
    }

    return 0;
}

