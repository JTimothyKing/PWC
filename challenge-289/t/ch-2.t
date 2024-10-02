#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);

use PwcTask;
use Path::Tiny;
use List::Util qw(pairs);
use List::MoreUtils qw(frequency);

=head1 NAME

challenge-289/t/ch-2.t - Test for Perl Weekly Challenge #289 Task 2: Jumbled Letters.

=head1 SYNOPSIS

    # run all tests
    yath challenge-289/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath challenge-289/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #289 Task 2: Jumbled Letters,
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

=head2 lorem_ipsum

Feeds a paragraph of Lorem Ipsum text to the program, and verifies
that each word of the output is a jumbled version of the corresponding
input word, with the first and last letters unchanged.

=cut

tests lorem_ipsum => sub {
    plan(1);

    my $input = <<~'END';
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
    veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
    commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
    velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
    cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id
    est laborum.
    END

    my $output = $run->with_stdin($input)->();

    # Split into word and non-word bits.
    my @input = split /\b/, $input;
    my @output = split /\b/, $output;

    is(
        \@output,
        [ map {
            /\W/ ? $_ : validator('matches_jumbled', $_ => _matches_jumbled($_))
        } @input ],
    );
};

sub _matches_jumbled {
    my ($expected) = @_;
    return sub {
        my %params = @_;
        my $got = $params{got};

        # return true only if the first letters match, last letters match,
        # and the letters have the same frequency distribution.
        return 0 unless defined $got;
        return 0 unless substr($got, 0, 1) eq substr($expected, 0, 1);
        return 0 unless substr($got, -1, 1) eq substr($expected, -1, 1);

        my %expected_letters = frequency split //, $expected;
        my %got_letters = frequency split //, $got;
        return 0 unless keys %expected_letters == keys %got_letters;
        for my $letter (keys %expected_letters) {
            return 0 unless defined $got_letters{$letter};
            return 0 unless $expected_letters{$letter} == $got_letters{$letter};
        }

        return 1;
    }
}

done_testing();
