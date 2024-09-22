#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

challenge-284/t/ch-2.t - Test for Perl Weekly Challenge #284 Task 2: Relative Sort.

=head1 SYNOPSIS

    # run all tests
    yath challenge-284/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-284/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #284 Task 2: Relative Sort,
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

    Input: @list1 = (2, 3, 9, 3, 1, 4, 6, 7, 2, 8, 5)
           @list2 = (2, 1, 4, 3, 5, 6)
    Output: (2, 2, 1, 4, 3, 3, 5, 6, 7, 8, 9)

=cut

tests example_1 => sub {
    plan(1);
    my $input = <<~'END';
        @list1 = (2, 3, 9, 3, 1, 4, 6, 7, 2, 8, 5)
        @list2 = (2, 1, 4, 3, 5, 6)
    END
    is($run->with_stdin($input)->(), "(2, 2, 1, 4, 3, 3, 5, 6, 7, 8, 9)", 'Example 1');
};

=head2 example_2

    Input: @list1 = (3, 3, 4, 6, 2, 4, 2, 1, 3)
           @list2 = (1, 3, 2)
    Output: (1, 3, 3, 3, 2, 2, 4, 4, 6)

=cut

tests example_2 => sub {
    plan(1);
    my $input = <<~'END';
        @list1 = (3, 3, 4, 6, 2, 4, 2, 1, 3)
        @list2 = (1, 3, 2)
    END
    is($run->with_stdin($input)->(), "(1, 3, 3, 3, 2, 2, 4, 4, 6)", 'Example 2');
};

=head2 example_3

    Input: @list1 = (3, 0, 5, 0, 2, 1, 4, 1, 1)
           @list2 = (1, 0, 3, 2)
    Output: (1, 1, 1, 0, 0, 3, 2, 4, 5)

=cut

tests example_3 => sub {
    plan(1);
    my $input = <<~'END';
        @list1 = (3, 0, 5, 0, 2, 1, 4, 1, 1)
        @list2 = (1, 0, 3, 2)
    END
    is($run->with_stdin($input)->(), "(1, 1, 1, 0, 0, 3, 2, 4, 5)", 'Example 3');
};

done_testing();
