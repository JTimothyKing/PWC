#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-285/t/ch-2.t - Test for Perl Weekly Challenge #285 Task 2: Making Change.

=head1 SYNOPSIS

    # run all tests
    yath challenge-285/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-285/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #285 Task 2: Making Change,
by Tim King L<https://github.com/JTimothyKing>.

=cut

my $challenge_dir = path($RealBin)->parent;
my $run;

before_case initialize_case => sub { $run = undef; };

my $task = PwcTask->new($challenge_dir, "ch-2");
for my $case ($task->language_cases) {
    diag "Adding case for ", $case->name;
    case $case->name => sub { $run = $case->prepare };
}

=head1 TESTS

=head2 example_1

    Input: 9
    Output: 2

=cut

tests example_1 => sub {
    plan(1);
    is($run->with_stdin(9)->(), 2, 'Example 1');
};

=head2 example_2

    Input: 15
    Output: 6

=cut

tests example_2 => sub {
    plan(1);
    is($run->with_stdin(15)->(), 6, 'Example 2');
};

=head2 example_3

    Input: 100
    Output: 292

=cut

tests example_3 => sub {
    plan(1);
    is($run->with_stdin(100)->(), 292, 'Example 3');
};

done_testing();
