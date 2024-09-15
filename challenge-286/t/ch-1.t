#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw($RealBin);
use Path::Tiny;

=head1 NAME

challenge-286/t/ch-1.t - Test for Perl Weekly Challenge #286 Task 1: Self Spammer.

=head1 SYNOPSIS

    # run all tests
    yath challenge-286/t/ch-1.t

    # run single test or case
    T2_WORKFLOW=tag yath challenge-286/t/ch-1.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #286 Task 1: Self Spammer,
by Tim King L<https://github.com/JTimothyKing>.

=cut

my $root_dir = path($RealBin)->parent;
my ($source, $run) = @ARGV;

before_case initialize_case => sub {
    $source = undef;
    $run = undef;
};

=head1 CASES

=head2 perl

Test the Perl solution for this task.

=cut

case perl => sub {
    diag "Testing Perl solution";
    $source = $root_dir->child('perl', 'ch-1.pl');
    diag "Using source $source";
    $run = [ 'perl', $source ];
};

=head2 csharp

Test the C# solution for this task.

=cut

case csharp => sub {
    diag "Testing C# solution";

    $source = $root_dir->child('csharp', 'ch-1', 'ch-1.cs');
    diag "Using source $source";

    my $proj = $source->parent->child('ch-1.csproj');
    diag "Building C# project $proj";
    system(
        qw[dotnet build --configuration Release --framework net8.0], $proj
    ) == 0 or die "Failed to build project $proj";

    my $dll = $source->parent->child(qw[bin Release net8.0 ch-1.dll]);
    die "Failed to build DLL $dll" unless -f $dll;
    diag "Using binary $dll";
    $run = [ qw[dotnet], "$dll" ];
};

=head1 TESTS

=head2 random_word

Tests that running the solution chooses a random word from the solution's
source.

=cut

tests random_word => sub {
    my $num_words_in_source = 0;
    my %words_seen = map {
        $num_words_in_source++;
        s/^[\N{U+FEFF}]//; # remove BOM if present
        ($_ => 0)
    } split ' ', $source->slurp_utf8;
    diag "Found $num_words_in_source words in the source";

    my $num_unique_words = %words_seen;
    diag "Found $num_unique_words unique words in the source";

    my $num_iterations = $num_words_in_source * 3;
    diag "Running program $num_iterations times";
    for my $iter_num (1 .. $num_iterations) {
        my $output = qx{@$run};
        chomp $output;
        ok(exists $words_seen{$output},
            "Word '$output' is in the source, iteration $iter_num");
        $words_seen{$output}++;
    }

    my $max_words_not_seen = int($num_unique_words / 5) + 1;
    my $num_words_not_seen = scalar(grep { $_ == 0 } values %words_seen);
    diag "Found $num_words_not_seen words not seen";
    ok($num_words_not_seen <= $max_words_not_seen,
        "Found $num_words_not_seen words not seen, expected at most $max_words_not_seen");
};

done_testing();
