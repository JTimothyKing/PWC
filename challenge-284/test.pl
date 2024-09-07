#!/usr/bin/perl
use v5.38;

use FindBin qw($RealBin);
use lib "$RealBin/..";
use PwcTest;

# This script runs a test on a program with the input and output cases
# for the corresponding problem.
# Run it this way: perl test.pl <language>/<task>-<name>.sh ...
# multiple programs can be tested at once by listing them all.

my %tasks = (
    1 => {
        name => 'Lucky Integer',
        cases => [
            {
                input => "\@ints = (2, 2, 3, 4)\n",
                output => "2\n",
            },
            {
                input => "\@ints = (1, 2, 2, 3, 3, 3)\n",
                output => "3\n",
            },
            {
                input => "\@ints = (1, 1, 1, 3)\n",
                output => "-1\n",
            },
        ],
    },
    2 => {
        name => 'Relative Sort',
        cases => [
            {
                input => "\@list1 = (2, 3, 9, 3, 1, 4, 6, 7, 2, 8, 5)\n"
                    . "\@list2 = (2, 1, 4, 3, 5, 6)\n",
                output => "(2, 2, 1, 4, 3, 3, 5, 6, 7, 8, 9)\n",
            },
            {
                input => "\@list1 = (3, 3, 4, 6, 2, 4, 2, 1, 3)\n"
                    . "\@list2 = (1, 3, 2)\n",
                output => "(1, 3, 3, 3, 2, 2, 4, 4, 6)\n",
            },
            {
                input => "\@list1 = (3, 0, 5, 0, 2, 1, 4, 1, 1)\n"
                    . "\@list2 = (1, 0, 3, 2)\n",
                output => "(1, 1, 1, 0, 0, 3, 2, 4, 5)\n",
            },
        ],
    },
);

my $tester = PwcTest->new(
    tasks => \%tasks,
    root_dir => $RealBin,
);
$tester->test_program($_) for @ARGV;

__END__
