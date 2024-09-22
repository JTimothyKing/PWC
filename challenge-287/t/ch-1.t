#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-287/t/ch-1.t - Test for Perl Weekly Challenge #287 Task 1: Strong Password.

=head1 SYNOPSIS

    # run all tests
    yath challenge-287/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-287/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #287 Task 1: Strong Password,
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

    Input: a
    Output: 5

=cut

tests example_1 => sub {
    plan(1);
    is($run->('a'), 5, 'Example 1');
};

=head2 example_2

    Input: aB2
    Output: 3

=cut

tests example_2 => sub {
    plan(1);
    is($run->('aB2'), 3, 'Example 2');
};

=head2 example_3

    Input: PaaSW0rd
    Output: 0

=cut

tests example_3 => sub {
    plan(1);
    is($run->('PaaSW0rd'), 0, 'Example 3');
};

=head2 example_4

    Input: Paaasw0rd
    Output: 1

=cut

tests example_4 => sub {
    plan(1);
    is($run->('Paaasw0rd'), 1, 'Example 4');
};

=head2 example_5

    Input: aaaaa
    Output: 2

=cut

tests example_5 => sub {
    plan(1);
    is($run->('aaaaa'), 2, 'Example 5');
};

done_testing();
