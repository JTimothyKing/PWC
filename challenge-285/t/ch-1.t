#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-285/t/ch-1.t - Test for Perl Weekly Challenge #285 Task 1: No Connection.

=head1 SYNOPSIS

    # run all tests
    yath challenge-285/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-285/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #285 Task 1: No Connection,
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

    Input: B C
           D B
           C A
    Output: A

=cut

tests example_1 => sub {
    plan(1);
    my $input = <<~'END';
        B C
        D B
        C A
    END
    is($run->with_stdin($input)->(), "A", 'Example 1');
};

=head2 example_2

    Input: A Z
    Output: Z

=cut

tests example_2 => sub {
    plan(1);
    my $input = <<~'END';
        A Z
    END
    is($run->with_stdin($input)->(), "Z", 'Example 2');
};

done_testing();
