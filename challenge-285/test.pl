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
        name => 'No Connection',
        cases => [
            {
                input => "B C\nD B\nC A\n",
                output => "A",
            },
            {
                input => "A Z\n",
                output => "Z",
            },
        ],
    },
    2 => {
        name => 'Making Change',
        cases => [
            {
                input => "9",
                output => "2",
            },
            {
                input => "15",
                output => "6",
            },
            {
                input => "100",
                output => "292",
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
