#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;
use FileHandle;

my $CLIENT_ID = $ENV{GITHUB_FATHEAD_CLIENT_ID};
my $CLIENT_SECRET = $ENV{GITHUB_FATHEAD_CLIENT_SECRET};

my $ua = LWP::UserAgent->new;

my $fh = FileHandle->new;

$fh->open("> $ARGV[0]");
$fh->autoflush(1);

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

    if ($res->content eq '[]') {
        $done = 1;
    }

    print $fh $res->content . "\n";

    warn $last_seen;

    check_rate_limit($res->header('X-RateLimit-Remaining'));

}

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
