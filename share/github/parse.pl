#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;

use encoding "utf-8";

my $CLIENT_ID = $ENV{GITHUB_FATHEAD_CLIENT_ID};
my $CLIENT_SECRET = $ENV{GITHUB_FATHEAD_CLIENT_SECRET};

my $ua = LWP::UserAgent->new;

open(IN, "<:encoding(ISO-8859-1)", "data-head.txt");
open(OUT, ">:encoding(UTF-8)", "output.txt");

my %repos;

my $dup_count = 0;

my $i = 1;
while (my $line = <IN>) {
    my $page = decode_json($line);

    foreach my $repo (@$page) {

        # Skip forks
        next if $repo->{fork};

        # Check for repos with the same name
        if (exists $repos{$repo->{name}}) {
            $dup_count++;

            # Decide which repo to favor based on the number of watchers
            my $checked = check_existing($repo);

            if ($checked == 1) {
                next;
            }
            else {
                delete $repos{$repo->{name}};
            }
        }

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

        my $out_line = join("\t", @output) . "\n";

        $repos{$repo->{name}} = {
            out_line => $out_line,
            url => $repo->{url}
        };
    }
}

foreach my $key (keys %repos) {
    print OUT $repos{$key}->{out_line};
}

sub check_existing {
    my $repo = shift;

    warn "Running check_existing on $repo->{name}.";

    my $new_url = "$repo->{url}?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET";
    my $new_repo_full = decode_json(call_github_api($new_url));

    my $old_url = "$repos{$repo->{name}}->{url}?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET";
    my $old_repo_full = decode_json(call_github_api($old_url));

    return 1 if ref($old_repo_full) ne "HASH" or ref($new_repo_full) ne "HASH";

    if ($new_repo_full->{watchers_count} > $old_repo_full->{watchers_count}) {
        return 0;
    }

    return 1;

}

sub call_github_api {
    my $url = shift;

    my $res = $ua->get($url);

    if (!$res->is_success) {
        sleep 10;
        $res = $ua->get($url);

        return if !$res->is_success;
    }

    my $remaining = $res->header('X-RateLimit-Remaining');

    if ($remaining < 2) {

        warn "Rate limit: $remaining requests remaining.";

        while ($remaining < 2) {
            sleep 60;

            my $res = $ua->get("https://api.github.com/rate_limit?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET");

            next if !$res->is_success;

            $remaining = $res->header('X-RateLimit-Remaining');
        }
    }

    return $res->content;
}
