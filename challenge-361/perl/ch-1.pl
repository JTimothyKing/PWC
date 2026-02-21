#!/usr/bin/perl
use v5.38;
use warnings;

say join(',', zeckendorf($ARGV[0]));

# Return the Zeckendorf representation of $n as a list of Fibonacci numbers
# in descending order, using the greedy algorithm.
sub zeckendorf {
    my ($n) = @_;

    # Build the Fibonacci sequence up to $n.
    my @fibs = (1, 2);
    push @fibs, $fibs[-2] + $fibs[-1] while $fibs[-1] + $fibs[-2] <= $n;

    # Subtract the largest possible Fibonacci numbers from $n until we reach 0.
    my @result;
    for my $fib (reverse @fibs) {
        if ($fib <= $n) {
            push @result, $fib;
            $n -= $fib;
            last unless $n > 0;
        }
    }

    if ($n < 0) {
        # This should never happen.
        die "Error: Negative remainder after subtraction, something went wrong.\n";
    }

    return @result;
}

__END__
