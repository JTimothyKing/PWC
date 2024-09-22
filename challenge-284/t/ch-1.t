#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-284/t/ch-1.t - Test for Perl Weekly Challenge #284 Task 1: Lucky Integer.

=head1 SYNOPSIS

    # run all tests
    yath challenge-284/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=tag yath challenge-284/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #284 Task 1: Lucky Integer,
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

    Input: @ints = (2, 2, 3, 4)
    Output: 2

=cut

tests example_1 => sub {
    plan(1);
    is($run->with_stdin('@ints = (2, 2, 3, 4)')->(), 2, 'Example 1');
};

=head2 example_2

    Input: @ints = (1, 2, 2, 3, 3, 3)
    Output: 3

=cut

tests example_2 => sub {
    plan(1);
    is($run->with_stdin('@ints = (1, 2, 2, 3, 3, 3)')->(), 3, 'Example 2');
};

=head2 example_3

    Input: @ints = (1, 1, 1, 3)
    Output: -1

=cut

tests example_3 => sub {
    plan(1);
    is($run->with_stdin('@ints = (1, 1, 1, 3)')->(), -1, 'Example 3');
};

done_testing();
