#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);
use Path::Tiny;

=head1 NAME

challenge-286/t/ch-2.t - Test for Perl Weekly Challenge #286 Task 2: Order Game.

=head1 SYNOPSIS

    # run all tests
    yath challenge-286/t/ch-2.t

    # run single test or case
    T2_WORKFLOW=tag yath challenge-286/t/ch-2.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #286 Task 2: Order Game,
by Tim King L<https://github.com/JTimothyKing>.

=cut

my $root_dir = path($RealBin)->parent;
my ($source, $run) = @ARGV;

before_case initialize_case => sub {
    $source = undef;
    $run = undef;
};

sub run {
    my $output = qx{@$run @_};
    chomp $output;
    return $output;
}

=head1 CASES

=head2 perl

Test the Perl solution for this task.

=cut

case perl => sub {
    diag "Testing Perl solution";
    $source = $root_dir->child('perl', 'ch-2.pl');
    diag "Using source $source";
    $run = [ 'perl', $source ];
};

=head2 csharp

Test the C# solution for this task.

=cut

case csharp => sub {
    diag "Testing C# solution";

    $source = $root_dir->child('csharp', 'ch-2', 'ch-2.cs');
    diag "Using source $source";

    my $proj = $source->parent->child('ch-2.csproj');
    diag "Building C# project $proj";
    system(
        qw[dotnet build --configuration Release --framework net8.0], $proj
    ) == 0 or die "Failed to build project $proj";

    my $dll = $source->parent->child(qw[bin Release net8.0 ch-2.dll]);
    die "Failed to build DLL $dll" unless -f $dll;
    diag "Using binary $dll";
    $run = [ qw[dotnet], "$dll" ];
};

=head1 TESTS

=head2 example_1

    Input: @ints = (2, 1, 4, 5, 6, 3, 0, 2)
    Output: 1

=cut

tests example_1 => sub {
    plan(1);
    is(
        run(2, 1, 4, 5, 6, 3, 0, 2),
        1,
        'Example 1'
    );
};

=head2 example_2

    Input: @ints = (0, 5, 3, 2)
    Output: 0

=cut

tests example_2 => sub {
    plan(1);
    is(
        run(0, 5, 3, 2),
        0,
        'Example 2'
    );
};

=head2 example_3

    Input: @ints = (9, 2, 1, 4, 5, 6, 0, 7, 3, 1, 3, 5, 7, 9, 0, 8)
    Output: 2

=cut

tests example_3 => sub {
    plan(1);
    is(
        run(9, 2, 1, 4, 5, 6, 0, 7, 3, 1, 3, 5, 7, 9, 0, 8),
        2,
        'Example 3'
    );
};

=head2 empty_list

    Input: @ints = ()
    Output: (no output)

=cut

tests empty_list => sub {
    plan(1);
    is(
        run(),
        '',
        'Empty list'
    );
};

=head2 single_element

    Input: @ints = (9)
    Output: 9

=cut

tests single_element => sub {
    plan(1);
    is(
        run(9),
        9,
        'Single element'
    );
};

=head2 two_elements

    Input: @ints = (9, 8)
    Output: 8

=cut

tests two_elements => sub {
    plan(1);
    is(
        run(9, 8),
        8,
        'Two elements'
    );
};

=head2 three_elements

    Input: @ints = (9, 8, 7)
    Output: 7

The third element is an odd element in the first round. It should be
taken itself as a result in that round.

=cut

tests three_elements => sub {
    plan(1);
    is(
        run(9, 8, 7),
        7,
        'Three elements'
    );
};

=head2 four_elements

    Input: @ints = (9, 8, 7, 6)
    Output: 6

=cut

tests four_elements => sub {
    plan(1);
    is(
        run(9, 8, 7, 6),
        7,
        'Four elements'
    );
};

=head2 six_elements

    Input: @ints = (9, 8, 7, 6, 5, 4)
    Output: 4

The result of min(5, 4) is an odd element in the second round. It
should be taken itself as a result in that round.

=cut

tests six_elements => sub {
    plan(1);
    is(
        run(9, 8, 7, 6, 5, 4),
        4,
        'Six elements'
    );
};

done_testing();
