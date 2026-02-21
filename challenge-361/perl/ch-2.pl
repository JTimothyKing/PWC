#!/usr/bin/perl
use v5.38;
use warnings;

# Read the matrix from stdin, one row per line, values space-separated.
my @party = map { [ split ] } <STDIN>;

say find_celebrity(@party);

# Find the celebrity using a two-phase O(n) algorithm:
#   1. Narrow down to a single candidate by eliminating non-celebrities.
#   2. Verify the candidate is known by everyone and knows nobody.
sub find_celebrity {
    my @party = @_;
    my $n = scalar @party;

    # Phase 1: find the candidate.
    # If A knows B, A is not the celebrity. If A doesn't know B, B is not the celebrity.
    my $candidate = 0;
    for my $i (1 .. $n - 1) {
        $candidate = $i if $party[$candidate][$i];
    }

    # Phase 2: verify the candidate.
    for my $i (0 .. $n - 1) {
        next if $i == $candidate;
        # The candidate must not know $i, and $i must know the candidate.
        return -1 if $party[$candidate][$i] || !$party[$i][$candidate];
    }

    return $candidate;
}

__END__

