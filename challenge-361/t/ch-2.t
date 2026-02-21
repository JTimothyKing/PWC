#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-361/t/ch-2.t - Test for Perl Weekly Challenge #361 Task 2: Find Celebrity.

=head1 SYNOPSIS

    # run all tests
    yath challenge-361/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-361/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #361 Task 2: Find Celebrity,
by Tim King L<https://github.com/JTimothyKing>.

You are given a binary matrix (m x n) where 0 represents that person A doesn't know person B,
and 1 represents that person A does know person B.

A celebrity is someone who everyone knows but who knows nobody.

Write a script to find the celebrity, return -1 when none found.

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

    Input: @party = (
                [0, 0, 0, 0, 1, 0],  # 0 knows 4
                [0, 0, 0, 0, 1, 0],  # 1 knows 4
                [0, 0, 0, 0, 1, 0],  # 2 knows 4
                [0, 0, 0, 0, 1, 0],  # 3 knows 4
                [0, 0, 0, 0, 0, 0],  # 4 knows NOBODY
                [0, 0, 0, 0, 1, 0],  # 5 knows 4
           );
    Output: 4

=cut

tests example_1 => sub {
    plan(1);
    my $input = <<~'END';
        0 0 0 0 1 0
        0 0 0 0 1 0
        0 0 0 0 1 0
        0 0 0 0 1 0
        0 0 0 0 0 0
        0 0 0 0 1 0
    END
    is($run->with_stdin($input)->(), '4', 'Example 1');
};

=head2 example_2

    Input: @party = (
                [0, 1, 0, 0],  # 0 knows 1
                [0, 0, 1, 0],  # 1 knows 2
                [0, 0, 0, 1],  # 2 knows 3
                [1, 0, 0, 0]   # 3 knows 0
           );
    Output: -1

=cut

tests example_2 => sub {
    plan(1);
    my $input = <<~'END';
        0 1 0 0
        0 0 1 0
        0 0 0 1
        1 0 0 0
    END
    is($run->with_stdin($input)->(), '-1', 'Example 2');
};

=head2 example_3

    Input: @party = (
                [0, 0, 0, 0, 0],  # 0 knows NOBODY
                [1, 0, 0, 0, 0],  # 1 knows 0
                [1, 0, 0, 0, 0],  # 2 knows 0
                [1, 0, 0, 0, 0],  # 3 knows 0
                [1, 0, 0, 0, 0]   # 4 knows 0
           );
    Output: 0

=cut

tests example_3 => sub {
    plan(1);
    my $input = <<~'END';
        0 0 0 0 0
        1 0 0 0 0
        1 0 0 0 0
        1 0 0 0 0
        1 0 0 0 0
    END
    is($run->with_stdin($input)->(), '0', 'Example 3');
};

=head2 example_4

    Input: @party = (
                [0, 1, 0, 1, 0, 1],  # 0 knows 1, 3, 5
                [1, 0, 1, 1, 0, 0],  # 1 knows 0, 2, 3
                [0, 0, 0, 1, 1, 0],  # 2 knows 3, 4
                [0, 0, 0, 0, 0, 0],  # 3 knows NOBODY
                [0, 1, 0, 1, 0, 0],  # 4 knows 1, 3
                [1, 0, 1, 1, 0, 0]   # 5 knows 0, 2, 3
           );
    Output: 3

=cut

tests example_4 => sub {
    plan(1);
    my $input = <<~'END';
        0 1 0 1 0 1
        1 0 1 1 0 0
        0 0 0 1 1 0
        0 0 0 0 0 0
        0 1 0 1 0 0
        1 0 1 1 0 0
    END
    is($run->with_stdin($input)->(), '3', 'Example 4');
};

=head2 example_5

    Input: @party = (
                [0, 1, 1, 0],  # 0 knows 1 and 2
                [1, 0, 1, 0],  # 1 knows 0 and 2
                [0, 0, 0, 0],  # 2 knows NOBODY
                [0, 0, 0, 0]   # 3 knows NOBODY
           );
    Output: -1

=cut

tests example_5 => sub {
    plan(1);
    my $input = <<~'END';
        0 1 1 0
        1 0 1 0
        0 0 0 0
        0 0 0 0
    END
    is($run->with_stdin($input)->(), '-1', 'Example 5');
};

=head2 example_6

    Input: @party = (
                [0, 0, 1, 1],  # 0 knows 2 and 3
                [1, 0, 0, 0],  # 1 knows 0
                [1, 1, 0, 1],  # 2 knows 0, 1 and 3
                [1, 1, 0, 0]   # 3 knows 0 and 1
           );
    Output: -1

=cut

tests example_6 => sub {
    plan(1);
    my $input = <<~'END';
        0 0 1 1
        1 0 0 0
        1 1 0 1
        1 1 0 0
    END
    is($run->with_stdin($input)->(), '-1', 'Example 6');
};

done_testing();
