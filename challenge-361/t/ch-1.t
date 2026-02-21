#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-361/t/ch-1.t - Test for Perl Weekly Challenge #361 Task 1: Zeckendorf Representation.

=head1 SYNOPSIS

    # run all tests
    yath challenge-361/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-361/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #361 Task 1: Zeckendorf Representation,
by Tim King L<https://github.com/JTimothyKing>.

A Zeckendorf representation is the unique way to write any positive integer as a sum of non‑consecutive Fibonacci numbers.
You can break every positive integer into Fibonacci numbers without using two Fibonacci numbers that sit next to each
other in the Fibonacci sequence. This decomposition is always unique, as is guaranteed by Zeckendorf’s Theorem.

You are given a positive integer (<= 100). Write a script to return Zeckendorf Representation of the given integer
as a comma-separated list of Fibonacci numbers sorted in descending order.

=cut

my $challenge_dir = path($RealBin)->parent;
my $run;

before_case initialize_case => sub {$run = undef;};

my $task = PwcTask->new($challenge_dir, "ch-1");
for my $case ($task->language_cases) {
    diag "Adding case for ", $case->name;
    case $case->name => sub {$run = $case->prepare};
}

=head1 TESTS

=head2 example_1

    Input: $int = 4
    Output: 3,1

4 => 3 + 1 (non-consecutive fibonacci numbers)

=cut

tests example_1 => sub {
    plan(1);
    is($run->(4), '3,1', 'Example 1');
};

=head2 example_2

    Input: $int = 12
    Output: 8,3,1

12 => 8 + 3 + 1

=cut

tests example_2 => sub {
    plan(1);
    is($run->(12), '8,3,1', 'Example 2');
};

=head2 example_3

    Input: $int = 20
    Output: 13,5,2

20 => 13 + 5 + 2

=cut

tests example_3 => sub {
    plan(1);
    is($run->(20), '13,5,2', 'Example 3');
};

=head2 example_4

    Input: $int = 96
    Output: 89,5,2

96 => 89 + 5 + 2

=cut

tests example_4 => sub {
    plan(1);
    is($run->(96), '89,5,2', 'Example 4');
};

=head2 example_5

    Input: $int = 100
    Output: 89,8,3

100 => 89 + 8 + 3

=cut

tests example_5 => sub {
    plan(1);
    is($run->(100), '89,8,3', 'Example 5');
};

done_testing();
