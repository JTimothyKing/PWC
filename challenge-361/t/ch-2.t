#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-361/t/ch-2.t - Test for Perl Weekly Challenge #361 Task 2: TASK NAME HERE.

=head1 SYNOPSIS

    # run all tests
    yath challenge-361/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-361/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #361 Task 2: TASK NAME HERE,
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

    Input:
    Output:

=cut

tests example_1 => sub {
    plan(1);
    is($run->(), undef, 'Example 1');
};

done_testing();
