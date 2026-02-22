#!/usr/bin/perl
use v5.38;
use warnings;

use List::Util qw(reduce);

say join(',', zeckendorf($ARGV[0])->@*);

# Return the Zeckendorf representation of $n as an arrayref of Fibonacci numbers
# in descending order, using the greedy algorithm.
sub zeckendorf {
    my ($n) = @_;

    # Build the Fibonacci sequence up to $n using an unfold from [1, 2].
    my @fibs = reverse grep { $_ <= $n }
        map { $_->[0] } generate([1, 2], sub { [$_[0][1], $_[0][0] + $_[0][1]] }, $n);

    # Greedily subtract the largest fitting Fibonacci number until we reach 0,
    # threading a [$remaining, \@result] accumulator tuple through the fold.
    my $acc = reduce {
        my ($remaining, $result) = @$a;
        $b <= $remaining
            ? [$remaining - $b, [@$result, $b]]
            : $a;
    } [$n, []], @fibs;

    return $acc->[1];
}

# Unfold a sequence from a seed tuple by repeatedly applying a generator function.
# Stops when the first element of the current tuple exceeds $limit.
# This is the dual of reduce() (fold). Where reduce() consumes a sequence and
# collapses it into a single value, generate() expands a seed out into a sequence.
sub generate {
    my ($seed, $func, $limit) = @_;
    my @seq;
    my $current = $seed;
    while ($current->[0] <= $limit) {
        push @seq, $current;
        $current = $func->($current);
    }
    return @seq;
}

__END__
