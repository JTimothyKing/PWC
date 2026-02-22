#!/usr/bin/perl
use v5.38;
use warnings;

use List::Util qw(reduce all);

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
    my $candidate = reduce { $party[$a][$b] ? $b : $a } 0 .. $n - 1;

    # Phase 2: verify the candidate.
    # The candidate must not know anyone, and everyone must know the candidate.
    my $valid = all { $_ == $candidate || (!$party[$candidate][$_] && $party[$_][$candidate]) } 0 .. $n - 1;

    return $valid ? $candidate : -1;
}

__END__

