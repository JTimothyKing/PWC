#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-289/t/ch-1.t - Test for Perl Weekly Challenge #289 Task 1: Third Maximum.

=head1 SYNOPSIS

    # run all tests
    yath challenge-289/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-289/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #289 Task 1: Third Maximum,
by Tim King L<https://github.com/JTimothyKing>.

=cut

my $challenge_dir = path($RealBin)->parent;
my $run;

before_case initialize_case => sub { $run = undef; };

my $task = PwcTask->new($challenge_dir, "ch-1");
for my $case ($task->language_cases) {
    diag "Adding case for ", $case->name;
    case $case->name => sub { $run = $case->prepare };
}

=head1 TESTS

=head2 example_1

    Input: @ints = (5, 6, 4, 1)
    Output: 4

The first distinct maximum is 6.
The second distinct maximum is 5.
The third distinct maximum is 4.

=cut

tests example_1 => sub {
    plan(1);
    is($run->(5, 6, 4, 1), 4, 'Example 1');
};

=head2 example_2

    Input: @ints = (4, 5)
    Output: 5

In the given array, the third maximum doesn't exist therefore returns the maximum.

=cut

tests example_2 => sub {
    plan(1);
    is($run->(4, 5), 5, 'Example 2');
};

=head2 example_3

    Input: @ints =  (1, 2, 2, 3)
    Output: 1

The first distinct maximum is 3.
The second distinct maximum is 2.
The third distinct maximum is 1.

=cut

tests example_3 => sub {
    plan(1);
    is($run->(1, 2, 2, 3), 1, 'Example 3');
};

=head2 empty_list

    Input: @ints = ()
    Output: undef

=cut

tests empty_list => sub {
    plan(1);
    is($run->(), '', 'Empty list');
};

=head2 single_element

    Input: @ints = (1)
    Output: 1

=cut

tests single_element => sub {
    plan(1);
    is($run->(1), 1, 'Single element');
};

done_testing();
