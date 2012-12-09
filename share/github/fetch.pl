#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;

my $CLIENT_ID = $ENV{GITHUB_FATHEAD_CLIENT_ID};
my $CLIENT_SECRET = $ENV{GITHUB_FATHEAD_CLIENT_SECRET};

my $ua = LWP::UserAgent->new;

my @repos;

my $last_seen = 0;
my $done = 0;

while (!$done) {

    my $URL = "https://api.github.com/repositories?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET";

    $URL .= "&since=$last_seen" if $last_seen != 0;

    my $res = $ua->get($URL);

    next if !$res->is_success;

    my $link = $res->header('Link');

    if ($link =~ m/since=(\d+)>/) {
        $last_seen = $1;
    }

    my $page = decode_json($res->content);

    if (@$page == 0) {
        $done = 1;
    }

    push (@repos, @$page);

    warn $last_seen;

    check_rate_limit($res->header('X-RateLimit-Remaining'));

}

print encode_json(\@repos);

sub check_rate_limit {
    my $remaining = shift @_;

    warn $remaining;

    if ($remaining < 2) {

        warn "Rate limit: $remaining requests remaining.";

        while ($remaining < 2) {
            sleep 60;

            my $res = $ua->get("https://api.github.com/rate_limit?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET");

            next if !$res->is_success;

            $remaining = $res->header('X-RateLimit-Remaining');
        }
    }
}
