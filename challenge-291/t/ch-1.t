#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-291/t/ch-1.t - Test for Perl Weekly Challenge #291 Task 1: Middle Index.

=head1 SYNOPSIS

    # run all tests
    yath challenge-291/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-291/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #291 Task 1: Middle Index,
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

    Input: @ints = (2, 3, -1, 8, 4)
    Output: 3

=cut

tests example_1 => sub {
    plan(1);
    is($run->(2, 3, -1, 8, 4), 3, 'Example 1');
};

=head2 example_2

    Input: @ints = (1, -1, 4)
    Output: 2

=cut

tests example_2 => sub {
    plan(1);
    is($run->(1, -1, 4), 2, 'Example 2');
};

=head2 example_3

    Input: @ints = (2, 5)
    Output: -1

=cut

tests example_3 => sub {
    plan(1);
    is($run->(2, 5), -1, 'Example 3');
};

=head2 empty_input

    Input: @ints = ()
    Output: -1

=cut

tests empty_input => sub {
    plan(1);
    is($run->(), -1, 'Empty input');
};

done_testing();
